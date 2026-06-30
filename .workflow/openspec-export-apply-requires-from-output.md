# OpenSpec export: derive apply.requires from the output node's connections

Branch: main. Status: current.

## Why and scope

`buildOpenSpecSchema` always emits an `apply:` block (OpenSpec's terminal phase), but it hardcoded `apply.requires` to the LAST artifact in topological order. That is wrong whenever the terminal actually depends on a non-last step: a designer workflow whose output node hangs off a mid-chain agent, or a foreign schema whose `apply.requires: [review]` gates on a mid-chain step while the chain continues to a later step. On re-export, such intent was silently rewritten to "the last step." This derives `apply.requires` from the work artifacts that actually feed the output node(s), so the terminal gate is faithful and round-trips.

The output node's CONFIG already flowed into `apply.instruction` (format -> deliverable line: commit/PR/report/docs). This change only corrects `apply.requires` (which steps gate apply). No new node, no new config, no change to our format - `apply` remains an OpenSpec-format concept the exporter generates from our output node.

Non-goals: changing `tracks` (still the last artifact's doc - a separate concern); adding apply config to the designer UI; the lossless awd:meta round-trip (already lossless via the embedded canvas - this is about the human/CLI-facing schema and foreign re-export).

## Requirements

- R1 - `apply.requires` lists the work artifacts that feed the output node(s), resolved through parallel/decision routers (via `openSpecUpstreamWork`), deduped. [test: "apply.requires reflects the output node connections, not just the last topo step"]
- R2 - Falls back to the last artifact when no output node is wired (or nothing feeds it). [unchanged behavior; covered by existing apply/linear tests staying green]
- R3 - Common case unchanged: when the output node feeds the last step (normal linear workflow), `apply.requires` is identical to before. [verified: all prior OpenSpec apply tests pass]
- R4 - Foreign round-trip: importing a schema whose apply gates on a mid-chain step, then re-exporting, preserves it. [test: "a divergent foreign apply (gated on a mid-chain step) round-trips through import + re-export"]

## Approach and decisions

- Reuse `openSpecUpstreamWork(outputNode.id)` - the same router-resolving helper the artifacts use for their `requires` - so apply's gate is computed exactly like every other dependency, just for the output node(s). `apply.requires = unique(outputs.flatMap(openSpecUpstreamWork).map(idOf).filter(Boolean))`, fallback `[lastId]`.
- This aligns the export with our own model: the output node(s) ARE the apply phase, so apply's prerequisites should be what connects to the output node - not a positional guess. The old lastId heuristic happened to be right only when the output fed the last step.
- `tracks` left as `lastId.md` (out of scope; tracks is the progress-checklist file, a separate question).

## Surface area (file -> role)

- `index.html` `buildOpenSpecSchema`: `apply.requires` now derived from `openSpecUpstreamWork` over the output nodes (fallback to last artifact); the apply emit loops over the derived list instead of pushing a single `lastId`.
- `tests.html`: 2 tests in the "OpenSpec schema export" describe (divergent designer workflow; divergent foreign round-trip).

## Task checklist

- [x] Derive `apply.requires` from output-node upstream work (router-resolved, deduped, fallback to last)
- [x] Emit the derived list in the apply block
- [x] Test: designer workflow where output feeds a non-last step
- [x] Test: divergent foreign schema round-trips (mid-chain apply preserved)
- [x] Confirm common/linear case unchanged (no regression)
- [x] This record + `_index` + `_timeline`

## Verify

`./run-tests.sh` -> 1153/1153 (was 1151; +2). Linear/common case: `openSpecUpstreamWork(output)` = [last step] = old `lastId`, so identical output - no existing apply test changed. Divergent designer case: output feeds Implementer (Validate is last) -> `apply.requires: [implementer]`, not validate. Divergent foreign case: import a schema with `apply.requires:[build]` (chain build->verify), re-export -> `apply.requires:[build]` preserved (not rewritten to verify).

## Spec quality check (finalize)

- [x] Every requirement has a verifying test (or a stated unchanged-behavior guarantee)
- [x] Scope bounded; non-goals stated (tracks, UI, awd:meta untouched)
- [x] No open clarifications
- [x] Verify section records real results (1153/1153 + the three cases)
- [x] Common case byte-identical (no regression); only divergent terminals change
- [x] Finalized for commit

## Outcome

`apply.requires` now mirrors what actually feeds the output node, so a terminal that depends on a mid-chain step (a designer fork-to-output, or a foreign schema whose apply gates on a mid-chain review) is exported and round-tripped faithfully instead of being rewritten to the last step. Closes the foreign round-trip loop for the apply gate. Common linear workflows are unchanged.

## Built with (provenance)

Authored directly after analyzing why a re-exported foreign schema would lose its divergent apply. Verified via the headless suite (1153/1153) including a foreign import-then-re-export round-trip.
