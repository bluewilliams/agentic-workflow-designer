# Autosave snapshot stays in sync with toggle changes

Work: stop the auto-saved workflow snapshot from overriding just-toggled settings on reload. Branch: main. Status: complete, uncommitted (awaiting director commit).

## Why and scope

Toggles (memory, Durable record, MCP, commit, clarify) are persisted in TWO places: `awd_prefs` (written by savePrefs on every toggle) and the auto-saved workflow snapshot `awd_autosave` (written by the debounced autoSaveWorkflow, which serializes the whole workflow including the toggles). On page load the order is restorePrefs() then restoreAutoSave(), so the snapshot is applied last and wins. Toggling a setting updated prefs but never refreshed the snapshot, so a stale snapshot (e.g. saved while Durable was off) overrode the just-checked toggle on the next reload. Symptom: "I check Durable Record, refresh, and it unchecks every time" - reproduced on the deployed build, which had an autosave snapshot present (the local file did not, which is why it looked fine there).

Non-goals: removing toggles from the snapshot (the snapshot intentionally carries full workflow config so loading restores everything); changing the load order.

## Requirements

- R1: A toggle change MUST refresh the autosave snapshot so it cannot go stale relative to prefs.
  - Given a workflow with nodes and memory on, When Durable record is toggled on, Then savePrefs triggers autoSaveWorkflow and the snapshot serializes durableRecord = true, so a reload restores it checked. (test: toggling Durable Record refreshes the autosave snapshot)

## Approach and decisions

- Routed the refresh through savePrefs(): added a single autoSaveWorkflow() call at the end of savePrefs, after its `_restoring` guard. Chose this central point over editing each toggle handler because every toggle already flows through savePrefs, so one call covers them all and cannot be missed; the `_restoring` guard means it does not fire during restore. Chose keeping toggles IN the snapshot (and re-syncing on change) over stripping them out, per the director: the snapshot is meant to restore the full in-progress config, so the right fix is to keep it current, not to narrow it.
- Kept autoSaveWorkflow's existing 1s debounce, so there is a small race (toggle then reload within 1s leaves the snapshot briefly stale). Acceptable: normal use toggles then regenerates/reloads well after 1s, and the debounce matches the existing canvas-autosave behavior.

## Surface area (file -> role)

- index.html savePrefs(): one added autoSaveWorkflow() call (after the try/catch, inside the `_restoring`-guarded body) so any pref/toggle change refreshes the snapshot.
- tests.html: export parity for autoSaveWorkflow/toggleDurableRecord/toggleMemory; new "Autosave stays in sync with toggle changes" suite (1 test).

## Verify

- Command: `./run-tests.sh`. Result: 648/648 passed (baseline 647, +1, no regressions).
- Browser (served local fixed build): created a workflow, toggled Durable on, let the autosave fire -> snapshot durableRecord became true; reloaded -> box stayed checked. The pre-fix build reset it every reload.

## Gotchas / non-obvious

- Toggles live in BOTH awd_prefs and the awd_autosave snapshot; on load restoreAutoSave runs after restorePrefs and wins. Any future toggle must keep both in sync (savePrefs now does this) or the snapshot will override prefs again.
- The bug only manifests when an autosave snapshot exists (a workflow with nodes). A fresh page with no workflow has no snapshot, so the toggle persists via prefs alone - which is why it could not be reproduced without first building a workflow.

## Outcome

savePrefs now calls autoSaveWorkflow, so a toggle change refreshes the auto-saved workflow snapshot and a stale snapshot can no longer override a just-saved toggle on reload. Verified by a regression test and a live browser repro. Fixes the Durable Record checkbox unchecking itself on refresh.

## Built with (provenance)

Produced directly (no sub-agent fan-out), diagnosed live in the browser via the Chrome tools: reproduced the reset on the deployed build, traced it to awd_autosave overriding awd_prefs on load, fixed at the savePrefs choke point, added a regression test, and re-verified the fix in the browser.
