# External-review hardening: CI test gate, panel build, escaping, shared preamble

Context: no work item (an outside agent's ranked review of the repo, director-approved items only where risk stays near zero). Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- CI enforces the suite: `.github/workflows/pages.yml` runs `./run-tests.sh --verbose` as a `test` job on push and pull_request; the Pages `deploy` job `needs: test`, so a red suite can never reach the live site. The self-heal job is guarded to DEPLOY failures only (`needs.deploy.result == 'failure'`) - a red suite must never be "healed" into a redeploy loop - and the concurrency group is per-ref so PR runs and main deploys cannot cancel each other.
- `updateConfig` builds the node panel into an array and assigns `innerHTML` exactly ONCE (was ~32 `innerHTML +=` appends: O(n^2) full reserialize/reparse per fragment and the classic silent-listener-drop hazard). Test-pinned via an instance accessor spy counting assignments.
- `configSelect` escapes its unknown-value fallback label (`escHtml`): the fallback renders user data - a config value possibly from an imported workflow JSON someone shared - into innerHTML. Known options stay trusted constants; the one dynamic caller (reviewLoopBackTo) already escaped its own labels.
- The four prompt generators emit the workflow-level hint preamble through ONE shared `pushSharedHints(p, format, includeEffort)` (was four hand-kept copies of the 12-hint sequence with per-generator variable prefixes; adding a hint meant four lockstep edits and the cross-format parity tests policed the drift). `format` feeds consumeRecordsHint; Claude.ai passes `includeEffort: false` (deliberate, pre-existing: no per-step effort mechanism there). Net -49 lines. A structural test pins that all four generators call it.

## Why and scope

An outside agent's review ranked five improvements; the director approved proceeding only where risk is near-nonexistent. Items 1 (CI), 3 (panel build), and 5 (escaping) were mechanical. Item 2 (preamble consolidation) was accepted ONLY under the byte-identity discipline: a snapshot harness hashed every preset x generator x toggle-combo output (17 x 5 x 3 = 255 cases) before and after, via git stash for the before-state - ALL outputs byte-identical. (First comparison failed everywhere including the untouched SDK, which exposed the harness's own flaw: preset workflow names are randomly generated and flow into memory paths; pinning the name made both runs deterministic.) Item 4 (decomposing 700-line functions) deliberately declined: green output-tested functions get decomposed on-touch, not by campaign.

## History

- 2026-08-07: created - all four accepted items landed; suite 1587 -> 1588 (+escaping/panel/structural pins), consolidation proven byte-identical across 255 cases (by direct session)
