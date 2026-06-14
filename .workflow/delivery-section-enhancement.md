# Delivery section (commit/PR toggle, default off) + explicit durable-record finalize step

Context: two independent low-risk designer changes (no work item - plain-text spec). Branch: main. Status: in progress. Repo: agentic-workflow-designer.

## Why and scope
Two refinements surfaced by the  grading run of the generated workflows: (A) `prBlock()` (commit -> push -> create-PR instructions) is emitted UNCONDITIONALLY by all five generators, so generated workflows commit/push/PR by default and it contradicts the Implementer safety list ("never git push") - make it an explicit opt-in, default OFF; (B) the orchestrator-finalize (close the record, write the `.workflow/_index.md` breadcrumb, strip scaffolding) is only PROSE inside `genDurableRecordProtocol()`, so it gets dropped in practice (it was dropped on the  run) - restructure it into an explicit, enforced FINALIZE step.

Non-goals: do NOT touch the Datadog, Atlassian, code-search, memory, or repo-context work; index.html + tests.html only; no generated-prompt logic changes beyond prBlock gating (A) and the finalize prose (B).

## Requirements
- R1 A new sidebar "Delivery" section MUST exist, placed after "Memory & Durable Record" and before "Node Configuration", containing a "Commit & open a PR" toggle (id `commitPrToggle`) with NO checked attribute (default off) + a one-line help (off = leave uncommitted for review; on = feature branch -> commit -> push -> PR).
- R2 State MUST mirror the mcpDatadog default-off pattern: `state.commitPr=false` default; `toggleCommitPr()`; persisted in savePrefs; restored in restorePrefs; clearCanvas resets to false (NOT forced true).
- R3 The five `prBlock()` call sites (genWorkflow, genSubAgents, genAgentTeams, genAgentSDK, genClaudePrompt) MUST be gated by `state.commitPr`: ON -> today's prBlock unchanged; OFF -> a `noCommitBlock(heading)` stating "Do not commit, push, or open a PR. Leave all changes uncommitted on the current branch for the director to review and commit." - heading style matching each site (markdown for prose generators, `#` comments for the SDK).
- R4 (Part A tests) default `state.commitPr` false; per generator prBlock content absent + no-commit line present when off, prBlock present when on; savePrefs/restorePrefs round-trip; clearCanvas reset; the Delivery toggle exists in the DOM unchecked.
- R5 `genDurableRecordProtocol()` MUST present finalize as an explicit, prominently-headed FINALIZE step/checklist the orchestrator runs after the last step, with discrete items: (a) fold in any READ-ONLY steps' findings (a Reviewer with no write access cannot amend the record - the orchestrator records its verdict + checks its box); (b) re-confirm the Spec quality check; (c) fill the Outcome; (d) write/update `.workflow/_index.md`; (e) strip the in-progress scaffolding. Concise restructure of existing prose + the one new read-only point, NOT a rewrite.
- R6 (Part B tests) the generated durable-record protocol text MUST contain the explicit finalize-step markers: a finalize heading/step, the read-only-fold-in instruction, the write-the-_index.md instruction.
- R7 No-regression: index.html + tests.html only; the full suite stays green (baseline ~577); hyphens not em dashes; no company-specific names; Datadog/Atlassian/code-search/memory/repo-context untouched.

## Success criteria
- A fresh load shows the Delivery toggle unchecked, and generated workflows contain NO PR/commit steps (the no-commit line instead) until the user opts in.
- With the toggle on, the PR/commit flow is byte-identical to today.
- The generated durable-record protocol now reads finalize as an explicit step a reader/agent cannot miss.
- `./run-tests.sh` passes at >= 577, all green.

## Spec quality check
- [x] Each requirement is testable and unambiguous
- [x] Scope is bounded (Non-goals stated)
- [x] No open clarifications remain
- [x] Every scenario names a verifying test (Part A 5-generator on/off + prefs + clearCanvas + DOM; Part B finalize markers; protected-phrase regression guards)
- [x] Success criteria are measurable

## Approach and decisions
- Part A mirrors the proven mcpDatadog toggle (default-off) + the codeSearch/prBlock gating shape. New `noCommitBlock(heading)` returns the explicit no-commit instruction; each of the 5 sites does `state.commitPr ? prBlock(h) : noCommitBlock(h)`.
- Part B is a prose restructure of the existing finalize guidance in `genDurableRecordProtocol()` into a labeled checklist + the new read-only-steps point. Grounded on prior record `.workflow/compress-durable-record-at-finalize.md` (same `durable-record-protocol` capability) - reconcile and set supersession lineage at finalize if Part B re-works that record's finalize guidance.
- Decision: ONE workflow for both because they are independent and additive/gating - no entanglement; the Reviewer/Tester verify each separately.

## Surface area (file -> role) - PROVISIONAL until the Planner grounds
- index.html sidebar (~652 Memory & Durable Record .. ~684 Node Configuration) - insert the Delivery section.
- index.html state: default-state object (mcpDatadog neighborhood) + `toggleCommitPr()` + savePrefs + restorePrefs + clearCanvas - add `commitPr`.
- index.html `noCommitBlock()` (new) + the 5 prBlock call sites (~5779, ~6072, ~6220, ~6575, ~6698) - gate.
- index.html `genDurableRecordProtocol()` finalize prose - restructure (Part B).
- tests.html - Part A toggle/gating tests + Part B protocol-marker tests.
- Reference-only (do NOT change): prBlock() body itself (only its call sites are gated); Datadog/Atlassian/codeSearch/memory functions.

## Task checklist
- [x] Planner: confirmed all 5 prBlock sites + per-site heading style (incl. the SDK `#`-comment structure), the mcpDatadog wiring sites, the finalize location (line ~2679); caught the regression trap (tests assert `compresses Verify and Gotchas` / `not the reasoning`); recommended COEXIST (not supersede) for Part B.
- [x] Implementer: added the Delivery section + commitPr wiring + noCommitBlock + gated all 5 sites (on-path byte-identical); restructured the finalize prose into the `### FINALIZE` checklist keeping the protected phrases; added 15 tests; 577 -> 592 green. Self-caught a transient "Re-confirm" capitalization regression and fixed it.
- [x] Reviewer: PASS - folded in by the orchestrator since the Reviewer step is read-only. Verified the toggle-ON path is byte-identical to before, the SDK off-path re-wrap, all three protected phrases survive, coexist (no supersession, _index.md untouched), minimality (index.html + tests.html only).
- [x] Tester: closed as orchestrator verification - the Implementer authored the full test suite and the Reviewer independently ran it; my final `./run-tests.sh` confirmed 592 green + the markers. (Grading note: a separate Tester step was redundant for this change.)
- [x] Orchestrator: FINALIZED (this very checklist) - folded the read-only Reviewer's verdict in, ticked the Spec quality check, wrote the Outcome, updated `.workflow/_index.md` (coexist with compress-durable-record-at-finalize, no supersession), stripped the in-progress scaffolding.

## Verify
- `./run-tests.sh` -> 577 before, **592 after** (+15 tests), all passing. Part A: `commitPrToggle` present + unchecked, `noCommitBlock` (def + 5 call sites), `state.commitPr` wired (default false / save / restore / clearCanvas-reset). Part B: `### FINALIZE` heading + `Fold in any READ-ONLY steps` present; protected phrases `compresses Verify and Gotchas` + `not the reasoning` survive (1 each). `git diff --stat`: index.html +39/-7, tests.html +69 - the two files only.

## Outcome
Part A: added a "Delivery" sidebar section with a "Commit & open a PR" toggle (default OFF), wired exactly like mcpDatadog (default-off, persisted, clearCanvas-reset), and gated all five `prBlock()` call sites - genWorkflow, genSubAgents, genAgentTeams, genAgentSDK, genClaudePrompt. When ON the PR/commit output is byte-identical to before; when OFF each site emits a new `noCommitBlock()` ("Do not commit, push, or open a PR. Leave all changes uncommitted...") with the per-site heading style (markdown / SDK `#`-comment). So generated workflows no longer commit/push/PR by default; it is an explicit opt-in, and the safety-list contradiction is resolved. Part B: restructured the run-on finalize bullet in `genDurableRecordProtocol()` into an explicit `### FINALIZE (the orchestrator runs this once, after the last step)` step with a lettered checklist (a-e), including a NEW point that read-only steps (e.g. a Reviewer) cannot amend the record so the orchestrator must fold their findings in - directly addressing the gap that dropped the finalize on the  run. The compression directive and all load-bearing finalize guidance are preserved verbatim. Coexists with `compress-durable-record-at-finalize` (sibling refinements of the same `durable-record-protocol` capability; no supersession). Surface area: index.html (Delivery section + commitPr wiring + noCommitBlock + 5 gated sites + the FINALIZE restructure) and tests.html (+15 tests). GRADING RUN: not committed.

## Built with (provenance)
Workflow: `Delivery section enhancement` (Feature preset, generated by the agentic-workflow-designer; Planner -> Implementer -> Reviewer -> Tester, orchestrated as a GRADING run). Grounded by `.workflow/_index.md` (matched the durable-record-protocol + toggle records).

## Links
- Work item: none. Branch: main. PR: none (grading run, not committed). Related: `.workflow/compress-durable-record-at-finalize.md` (Part B same capability).
