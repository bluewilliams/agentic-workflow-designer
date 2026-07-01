# Workflow Management one-row (Handoff into Export) + tooltip consistency pass

Branch: main. Status: current. UI polish (markup only, no behavior change).

## Why and scope

Three small UI improvements, driven by real observations:
1. The Workflow Management buttons wrapped to two rows (Save / Clone / Export / Handoff, then Import). Fold Handoff into the existing Export dropdown so it fits one row.
2. The Clone button had NO tooltip and an unclear label - even the author forgot what it does. Add a tooltip that explains it.
3. Tooltip coverage was inconsistent (undo/redo had tooltips; the Select/Connect/Delete mode buttons, Auto Layout, Fit, zoom, and the output tabs did not). Do a focused consistency pass for onboarding.

Non-goals: renaming Clone to a longer label (would re-break the one-row we just achieved); a Save split-button (more UI machinery than the Export-dropdown reuse is worth); blanket-tooltipping every control (noise + maintenance - skip self-evident and inline-documented ones).

## Changes (each verifiable)

- C1 - Handoff is now a menu item in the Export dropdown (Export -> Workflow JSON / OpenSpec schema / Handoff package); the standalone Handoff button is removed. Workflow Management fits one row: Save . Clone . Export . Import. [verified: screenshot]
- C2 - The Clone button has a tooltip: "Save a copy: renames the current workflow to (copy) so your next Save creates a new workflow, leaving the original untouched." Label kept short (Clone), so the row stays one line. [verified: markup]
- C3 - Toolbar mode buttons (Select/Connect/Delete) have tooltips including their 1/2/3 keyboard shortcuts - the keybindings were VERIFIED to exist (index.html keydown handler maps '1'/'2'/'3' to setMode) before claiming them. [verified: code + markup]
- C4 - View buttons (Auto Layout, Fit, +/- zoom) and the five output tabs (Workflow / Sub-Agents / Agent Teams / Agent SDK / Claude.ai) have concise tooltips; the tab tooltips are condensed from the help modal's tab descriptions. [verified: markup]
- C5 - Self-evident controls (Save, Import) and inline-documented ones (memory/MCP toggles, Auto Workflow, Generate Refine/Plan Prompt) deliberately NOT tooltipped. [decision]
- C6 - Help modal + README references to the Handoff button updated to "Export -> Handoff package". [verified: grep]

## Approach and decisions

- **Handoff belongs in Export** because it IS an export (a resume `.md` package). Folding it into the existing dropdown reuses a widget already there, adds zero new interaction pattern, and is the biggest one-row win. Considered a Save split-button for Clone; rejected as more machinery than the payoff.
- **Clarity over relabeling for Clone**: the label was fine for width but unclear; a tooltip fixes the meaning at zero width cost. A longer "Save Copy" label would have re-broken the single row - the whole point of the change.
- **Scoped tooltip pass, not blanket**: add a tooltip where the label/icon alone does not convey purpose, or where a keyboard shortcut exists; skip the obvious and the inline-documented. Match the existing "(shortcut)" style. Verified shortcuts before claiming them (no false affordances).

## Surface area (file -> role)

- index.html: Export menu markup (added the Handoff package `role="menuitem"` calling `exportHandoffFile();closeExportMenu()`; removed the standalone Handoff button; Export button title mentions Handoff); Clone button `title`; toolbar mode/view button `title`s; output-tab `title`s; two help-modal references to Handoff's new location.
- README.md: the Handoff bundle section now says "Export -> Handoff package"; the Agent Library section unaffected.
- No JS logic changed; no tests added (title attributes + a dropdown-item relocation are behavior-inert - the existing 1172 tests still pass unchanged).

## Task checklist

- [x] Fold Handoff into the Export dropdown; remove the standalone button; Export title mentions it
- [x] Clone tooltip (kept short label to preserve one row)
- [x] Toolbar mode-button tooltips with verified 1/2/3 shortcuts
- [x] View-button + output-tab tooltips (tabs condensed from help modal)
- [x] Skip self-evident / inline-documented controls
- [x] Update help modal + README Handoff references
- [x] This record + `_index` + `_timeline`

## Verify

`./run-tests.sh` -> 1172/1172 (unchanged - markup/title-only, behavior-inert). Screenshots confirmed: Workflow Management renders on one row (Save . Clone . Export . Import), and the open Export menu shows Workflow JSON / OpenSpec schema / Handoff package. Keyboard shortcuts for the mode tooltips were confirmed against the keydown handler. Content-lint grep empty.

## Spec quality check (finalize)

- [x] Each change is stated and verified (screenshot / grep / code check)
- [x] Scope bounded; non-goals stated (no relabel, no split-button, no blanket tooltips)
- [x] No open clarifications
- [x] Verify records real results (1172/1172 + screenshots)
- [x] Behavior-inert (markup only); no regression surface
- [x] Finalized for commit

## Outcome

Workflow Management fits one clean row with Handoff folded into Export (where it belongs, being an export), Clone finally explains itself via a tooltip, and the toolbar mode/view buttons plus the output tabs have consistent, shortcut-aware tooltips for onboarding - while the genuinely obvious and already-inline-documented controls were left alone.

## Built with (provenance)

Authored directly across a UI-review conversation (screenshots of the wrapping button row and the Custom Agents palette). Verified by re-screenshotting the one-row result + the Export menu, and a code check that the 1/2/3 mode shortcuts exist.
