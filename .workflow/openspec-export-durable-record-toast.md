# OpenSpec export: durable-record expectation toast

Branch: main. Status: current.

## Why and scope

The three memory/record toggles (Enable workflow memory, Ground in prior records, Keep a durable record) drive only the five prompt generators; the OpenSpec export is a separate code path that builds the schema purely from structural data and calls none of the `gen*` protocols. So all three are silent no-ops on the export. The surprising one is **Keep a durable record**: it is literally "the write side," so a user who turns it on most plausibly expects the schema run to *produce* a `.workflow/{slug}.md`. It does not - an OpenSpec run leaves one record per step (the role-aware templates), which is OpenSpec's native handoff, not our single flywheel doc.

This change closes that expectation gap with a one-line signal: when the durable-record toggle is on at export time, the success toast says so, and the help modal documents the distinction. Messaging only - the export behavior is unchanged.

Non-goals: changing what the export produces; carrying the durable record into OpenSpec (it fights OpenSpec's generate-once-per-doc model - deferred, see below); messaging the memory or grounding toggles (memory is ephemeral `~/.claude` scratch that does not belong in a portable artifact; grounding is the read side, tracked as a real feature in backlog #9, not a messaging tweak).

## Requirements

- R1 - When the durable-record toggle is ON, the OpenSpec export success toast appends a note that the export uses OpenSpec's per-step records, not the single `.workflow` durable record. [test: "openSpecExportToast: durable-on message appends the per-step-records note"]
- R2 - When the toggle is OFF, the toast is the plain success line with no note (no nag for users who never opted in). [test: "openSpecExportToast: durable-off message is the plain success line"]
- R3 - The help modal's OpenSpec subsection documents the distinction in prose so it is durable, not just a transient toast. [verified: help-modal paragraph added under "OpenSpec export"]
- R4 - Additive + removable; core untouched. The message builder lives inside the removable OpenSpec block and is a pure function. [verified: `openSpecExportToast` sits in the `// === ... OpenSpec schema export ===` block; export logic and `buildOpenSpecSchema` unchanged]

## Approach and decisions

- Extracted the message selection into a pure, testable helper `openSpecExportToast(name, durable)` rather than branching inline, so the wording is unit-tested without asserting on the DOM toast (which would be brittle). `exportOpenSpecSchema` calls `showToast(openSpecExportToast(s.name, state.durableRecord), state.durableRecord ? 7000 : undefined)` - the longer note gets a longer dwell (7s); the plain line uses the default duration.
- Durable-only messaging. Memory is ephemeral scratch (no place in a portable schema), and grounding is the read side with a real argument for *inclusion* (backlog #9), not a "set expectations" note. Listing every internal toggle in the toast would read as over-explaining; the toast targets the one genuine surprise.
- Why not carry the durable record across (the rejected alternative): OpenSpec is document-per-artifact, generate-once, ordered by a `requires` DAG. Our durable record is a single mutable read/update doc with `_index`/`_timeline` breadcrumbs - there is no native OpenSpec slot for running state. Grafting it on would blur the boundary we drew (we author for OpenSpec, we do not reimplement its runtime). The per-step record templates the export already emits are the OpenSpec-native way to get the same handoff value.

## Surface area (file -> role)

- `index.html` REMOVABLE OpenSpec block: new pure helper `openSpecExportToast(name, durable)`; `exportOpenSpecSchema` calls it for the success toast.
- `index.html` help modal: one paragraph under "OpenSpec export" stating the durable-record toggle does not flow into the export and why.
- `tests.html`: 2 tests in the "OpenSpec schema export" describe + `openSpecExportToast` bridged to `win`.

## Task checklist

- [x] Pure helper `openSpecExportToast(name, durable)` in the removable OpenSpec block
- [x] `exportOpenSpecSchema` uses it (7s dwell when durable, default otherwise)
- [x] Help-modal paragraph documenting the distinction
- [x] Bridge `openSpecExportToast` to `win` in tests.html
- [x] Tests (2): durable-off plain line / no note; durable-on appends the per-step-records note
- [x] This record + `_index` + `_timeline` entries

## Verify

`./run-tests.sh` -> 1134/1134 (was 1132; +2). The helper is pure (string in, string out) so the two tests pin the exact wording for both toggle states; the export path and `buildOpenSpecSchema` are unchanged and still covered by the existing 26 OpenSpec tests.

## Spec quality check (finalize)

- [x] Every requirement is testable and has a verifying test or a stated verification
- [x] Scope bounded; non-goals stated (incl. why grounding is deferred to backlog #9)
- [x] No open clarifications
- [x] Verify section records real results (1134/1134)
- [x] Additive + removable; export behavior byte-identical (messaging-only)
- [x] Finalized for commit

## Outcome

A user who enables Keep a durable record and exports an OpenSpec schema now gets an accurate one-line heads-up (toast) plus a documented note (help modal) that the run leaves OpenSpec's per-step records, not our `.workflow` flywheel doc. Pure helper, two tests, core untouched. The read-side cross-tool bridge (letting OpenSpec runs benefit from prior `.workflow/` records) is parked as backlog #9.

## Built with (provenance)

Authored directly across a design conversation that started from the question "will OpenSpec create our durable document during its run?" - verified by reading the export path (no `gen*` protocol calls) and the headless test suite.
