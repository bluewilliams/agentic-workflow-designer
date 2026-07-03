# Sonnet 5 and Sonnet 5 [1M] model support

Workflow: verify-instructions-sonnet5 (unit B). Branch: main. Status: finalized, committable.

```awd:record
{"slug": "sonnet-5-models", "status": "current", "date": "2026-07-03", "files": ["index.html", "tests.html"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

The MODELS array offers Sonnet 5 and Sonnet 5 [1M] (family `sonnet-5`, full API id `claude-sonnet-5`) alongside Fable 5, Opus 4.8, Sonnet 4.6, and Haiku; every model picker (default-model dropdown, per-node config picker, custom-agent form) lists them via the generic MODELS read. `taskModelMap` routes both variants to the valid Task base alias `sonnet`; `isLongContextModel`/`modelContextNote` generalize to `sonnet-5-1m` by the `-1m` suffix with zero special-casing, so prose formats emit `model="sonnet"` plus the 1M intent note and the SDK emits the full `claude-sonnet-5` id with no note.

## Why and scope

Sonnet 5 is the newest Sonnet and reportedly strong; users should be able to select it (and its 1M variant) for any node. Non-goals: no changes to the 1M note machinery (it must generalize by the existing `-1m` suffix convention), no default-model change, no removal of Sonnet 4.6.

## Requirements

1. Both variants MUST appear everywhere models are offered. (Tests: offers Sonnet 5 and Sonnet 5 [1M] in the default-model dropdown / in the per-node model picker (config panel reads MODELS) / in the custom-agent model dropdown)
2. Mappings MUST be correct with zero special-casing. (Tests: should return correct label, id and family for Sonnet 5 (and 1M variant); B: Sonnet 5 and Sonnet 5 [1M] both map to the sonnet base alias for the Task param)
3. SDK full id, prose base alias + 1M note. (Tests: should use sonnet shorthand for Sonnet 5; should emit a base model param plus the 1M prose note for Sonnet 5 [1M]; B: SDK keeps the full claude-sonnet-5 id and emits no 1M note for the 1M variant)
4. Labels house-style; Explain via existing helpers. (Label pinned by the mapping test; Explain rows verified generic at the Verifier gate - they read the same helpers)
5. Pin migrations: none existed (no test pinned the full model list or dropdown length - verified by the Skeptic gate); 8 new pins added instead.

## Approach and decisions

- Two MODELS rows inserted above the sonnet-4.6 pair (newest-first within the family grouping) + two taskModelMap keys - the ONLY required logic touch; everything else (3 dropdowns, 4 emitters, preset/restore paths, node subtitle) reads MODELS generically. Planner verified no value/family switch exists anywhere (family feeds only getModelFamily -> node subtitle).
- Primary risk named: omitting the taskModelMap keys would make getTaskModelParam fall back to getModelId and emit `claude-sonnet-5` as an invalid Task param - guarded by a dedicated mapping test.
- No existing test pins the full model list or dropdown length, so no pin migrations needed - five new tests instead (labels/ids/family, mapping, prose emission incl. the 1M note, SDK id, dropdown presence).

## Success criteria

- A user can select Sonnet 5 or Sonnet 5 [1M] on any node and every export format emits a valid, correct model reference.
- No existing model's behavior changes.

## Spec quality check

- [x] Each requirement testable and unambiguous
- [x] Scope bounded (Non-goals stated)
- [x] No open clarifications remain (id + placement assumptions confirmed at the plan gate)
- [x] Every scenario names a verifying test
- [x] Success criteria measurable

## Task checklist

- [x] Orchestrator grounding (MODELS array + taskModelMap + modelContextNote anchors from dogfood-run-fixes)
- [x] Plan unit B (small, mechanical, but verify every model-consuming site)
- [x] Skeptic review of unit B plan passes
- [x] MODELS entries + taskModelMap + any per-node picker sites (pickers read MODELS generically - no per-picker edits needed)
- [x] Tests incl. deliberate pin migrations (no full-list pin existed; 6 new pins added)
- [x] Code review passes (both-units gate)
- [x] Verifier gate passes (delivery verified by execution - real emissions generated and asserted for both variants)
- [x] Full suite green via ./run-tests.sh (1447/1447, deterministic across two runs)
- [x] Finalize: record, index entry, timeline line, run report

## Verify

- `./run-tests.sh` -> PASS 1447/1447 at run end (unit B contributed +6 at the 1398 baseline; run-level matrix added per-node picker and custom-agent dropdown pins for Sonnet 5; zero regressions).
- Content-lint grep on changed files -> exit 1; no em dashes in the diff.

## History

- 2026-07-03: created (by sonnet-5-models)

## Current state / next action

Run-level Tester PASSED (1427 -> 1447; all five reviewer gaps closed; regression confirmation green for dogfood-run-fixes and sidebar-collapse). Next: Verifier gate "Delivery verified?" (cycle 1 of 3) - proves the delivery by execution.

## Outcome

Sonnet 5 and Sonnet 5 [1M] are selectable on every node and in every picker; all export formats emit valid, correct model references (base alias + 1M note in prose, full API id in SDK). Three data edits in index.html, zero logic changes, 8 test pins. Both gates cycle 1 for this unit.

## Gotchas / non-obvious

- The 1M intent note legitimately contains the literal `/model sonnet[1m]` (a Claude Code example) - tests must assert the absence of the Task-param form `model="sonnet[1m]"`, never the bare string (the Verifier initially tripped on this, same lesson as the opus variant in dogfood-run-fixes).

## Built with (provenance)

Workflow `verify-instructions-sonnet5` (custom, built via the designer's own serializeWorkflow API and imported): fork(Planner A, Planner B) -> per-plan Skeptic gates (max 3) -> Implementer B -> Implementer A -> Reviewer gate (max 3) -> Tester -> Verifier gate (revise -> Implementer A, max 3) -> delivery. Memory + durable records + grounding ON; models opus; run live by Claude (Fable) as orchestrator - third dogfood run.

## Links

- Grounds on / touches: grounds on `.workflow/dogfood-run-fixes.md` (taskModelMap / isLongContextModel / modelContextNote machinery, including the bare-string-vs-param-form test gotcha); amended no other records.
- Branch: main (uncommitted delivery for the director). Sibling unit: `.workflow/verification-instructions.md` (same run).
```awd:run
{"workflow": "verify-instructions-sonnet5", "repo": "agentic-workflow-designer", "steps": [{"slug": "planner-verification-instructions", "status": "done"}, {"slug": "planner-sonnet-5-models", "status": "done"}, {"slug": "skeptic-review-sonnet-5-plan", "status": "done"}, {"slug": "skeptic-review-verification-plan", "status": "done"}, {"slug": "implementer-sonnet-5", "status": "done"}, {"slug": "implementer-verification-instructions", "status": "done"}, {"slug": "reviewer", "status": "done"}, {"slug": "tester", "status": "done"}, {"slug": "verifier-delivery", "status": "done"}], "gates": [{"slug": "sonnet-5-plan-sound", "cycles": 1, "final": "Passed"}, {"slug": "verification-plan-sound", "cycles": 2, "final": "Passed"}, {"slug": "review-passed", "cycles": 1, "final": "Approved"}, {"slug": "delivery-verified", "cycles": 1, "final": "Verified"}], "notes": "FIRST REVISE CYCLE in dogfood history: Skeptic blocked plan A cycle 1 on a real five-format parity gap (genClaudePrompt omitted); planner re-spawn recovered its full plan from its memory file, fixed in one pass, delta-scoped re-review passed cycle 2. Fork pipelined honestly (unit B implemented while unit A was still in plan review). TWO harness dead-spawns (instant return, zero tools) recovered via one re-run each - memory files checked first, no trace either time. First Verifier gate: independent execution harness, adversarial probes, honest traced-not-executed caveats. 1398 -> 1447 tests."}
```
