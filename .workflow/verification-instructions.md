# Team verification instructions: repo-mandated verify files for testers and verifiers

Workflow: verify-instructions-sonnet5 (unit A). Branch: main. Status: finalized, committable.

```awd:record
{"slug": "verification-instructions", "status": "current", "date": "2026-07-03", "files": ["index.html", "tests.html"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

Repo Context Paths has a third sticky group, "Verification instructions (verifier / tester owned)": an add-chip list of filenames or paths (bare names searched recursively per repo in scope) plus an "Unmet required verifications fail the run" checkbox (default ON), persisted like rulesPaths and surviving New Workflow. When the list is non-empty, `verifyInstructionsHint()` emits an orchestrator beat into all five export formats (workflow, sub-agents, teams, claude.ai, SDK as a comment block) carrying discovery, root-vs-nested blast-area scoping, MUST/SHOULD severity interpretation with the checkbox posture as default, and posture-correct fail-the-run vs report-only language - and routes the repo's verification mandates to exactly ONE step. `resolveVerifyOwnerId()` picks the workflow's OWNING verification step (the last verifier-type node in execution order, else the last tester); `verifyInstructionsStepHint(node)` emits the per-step contract (executed-with-result / not-applicable-with-reason / blocked-with-reason, surfaced into the gate verdict, record Verify section and Verification ledger, and awd:run notes, never silently passing; explicitly IN ADDITION to the step's own verification method, never a substitute - these are REPO-mandated checks) ONLY to that owner - reviewers audit reported outcomes and never receive the execute contract, and a tester upstream of a verifier receives nothing (a step that never hears of an expensive mandate cannot duplicate it); `openSpecContextBlock` forwards the paths compactly. With the list empty, every surface emits byte-identically to before - silence is structural. The files mandate what must be proven, never which tools may be used.

## Why and scope

Teams keep standing verification mandates in repo files (push to LambdaTest, run this validation tool) and nest them near the code they govern. Rules paths are the wrong shape: wrong contract (read-and-honor vs execute-and-report), wrong audience (all agents vs testers/verifiers/reviewers), no subtree scoping, and no blocked-step flagging. Non-goals: no per-node config (mandates are repo properties; role targeting happens at generation), no dictated file format, no restriction of agent tools (the files mandate what must be proven).

## Requirements

1. Third sticky group MUST exist with rules-paths ergonomics and posture checkbox default ON.
   - Given the shipped DOM, Then the ids exist and the toggle is checked. (Tests: DOM ids exist: verifyPathInput, verifyPathChips, verifyPathClear, verifyFailRunToggle; verifyFailRunToggle is checked by default in the shipped DOM; defaults: verifyPaths empty and verifyFailRun true after resetState)
   - Given chip interactions, Then add/remove/clear/quick-add/Enter/blank-Enter behave per the rules-paths pattern. (Tests: addVerifyPath / removeVerifyPath / clearVerifyPaths mutate state.verifyPaths; quick-add chips add their path; pressing Enter in verifyPathInput adds the typed path and clears the input; a blank verifyPathInput + Enter adds nothing; clicking a rendered chip remove button removes just that path; Clear All is hidden when empty, shown once a path exists, and clicking it empties the list; renderVerifyRows renders exactly one chip per path; renderVerifyRows toggles verifyPathClear display)
   - Given persistence, Then prefs round-trip, New Workflow keeps the list, old blobs tolerate absent keys. (Tests: savePrefs then restorePrefs round-trips verifyPaths and verifyFailRun; clearCanvas keeps verifyPaths (sticky, not reset); restorePrefs tolerates an older awd_prefs blob lacking verify keys)
2. Scoping MUST be emitted: root always applies, nested by blast-area intersection. (Test: beat carries the discovery/scoping/routing/severity/surfacing contract - prose contract, executable only by a live orchestrator; Verifier traced the emission and caveated honestly)
3. Role targeting MUST hold: tester/verifier/reviewer only, plus the orchestrator beat.
   - (Tests: tester / verifier / reviewer receive the step hint; planner / coder / architect / writer / adversary do NOT; VERIFY_STEP_ROLES excludes adversary; a tester-only workflow carries the step hint in the generated prompt; a coder-only (implementer) workflow does NOT carry the step hint; step hint is generation-only: node-config display omits it; plus the run-level end-to-end matrix across genWorkflow/genSubAgents/genAgentTeams/genClaudePrompt with per-format coder negatives)
4. Severity MUST be format-agnostic with the checkbox as default posture, correct BOTH ways. (Tests: checkbox posture: ON -> fail-the-run language, OFF -> report-only; toggling verifyFailRunToggle onchange live-refreshes the generated prompt (posture text flips))
5. The reporting contract MUST be carried and never silently pass. (Tests: the step-hint and beat content assertions carry executed/na/blocked + verdict/record/fence surfacing language; posture tests above bind fail-the-run to the checkbox)
6. Parity and silence MUST be structural. (Tests: beat appears at all five exporters when verifyPaths non-empty; openSpecContextBlock forwards verify paths compactly when non-empty; silence when empty: beat absent from all five exporters and from openSpecContextBlock; beat is null when list empty; empty list -> step hint is empty even for a tester)
7. Explain rows + help entry MUST exist. (Verifier-traced via the exRow and help-modal diff additions; no dedicated unit test - noted follow-up if these ever regress silently)
8. awd:meta round-trip MUST carry the config. (Tests: awd:meta serialize carries verifyPaths and verifyFailRun; verifyFailRun false survives as strict boolean false; verifyFailRun true serializes as strict boolean true)

## Approach and decisions

- Two gated helpers carry the whole feature: `verifyInstructionsHint()` (workflow/orchestrator beat, peer of rulesPathsHint, gated on non-empty state.verifyPaths) and `verifyInstructionsStepHint(node)` (per-node, role-gated to a VERIFY_STEP_ROLES set of tester/verifier/reviewer, peer of datadogStepHint, generation-only). All reporting/gate/record/fence language lives INSIDE these helpers, so the always-on emitters (runReportDirective, OPENSPEC_RECORD_SECTIONS, gate code) need zero edits - "nothing when empty" is structural, and implementer prompts cannot carry the contract by construction.
- The orchestrator discovery beat is authored as a PEER directive in the consumeRecordsHint/clarifyFirst idiom, not nested inside the memory kickoff protocol - avoids coupling to the memory toggle (this config is its own gate).
- SDK parity: genAgentSDK has no per-step role hints today, so parity = orchestrator beat as a comment block only (verified by inspection, not assumed).
- Adversary/skeptic excluded from VERIFY_STEP_ROLES: it critiques, it does not execute verifications; the requirement names tester/verifier/reviewer only.
- verifyFailRun sticky via prefs but not adopted from imported awd:meta (mirrors the rules twin: arrays adopt, posture stays local).
- Skeptic gate cycle 1: NEEDS REVISION - one High finding: workflow-level wiring listed 4 formats, omitting genClaudePrompt (the _cpRu site); rules-paths parity is FIVE emission sites, and the plan's own test list and per-step wiring already included that format. All other anchors, assumptions (A1-A4), the role set, and the unit B seam were verified accurate. Planner re-spawned (cycle 2).
- Cycle-2 revision (gate PASSED): workflow-level wiring corrected to all FIVE rulesPathsHint sites (genWorkflow/genSubAgents/genAgentTeams/genClaudePrompt via the _xRu idiom + genAgentSDK as a gated comment block); openspec forwarding INCLUDED as S5b (one compact gated line in openSpecContextBlock, mirroring the rules forwarding idiom) - the parity invariant "verifyPaths appears wherever rulesPaths appears" made total.
- Shared-file seam with unit B flagged and managed by sequencing (B implements first; A inserts adjacent state keys, zero overlap with MODELS/taskModelMap).

## Surface area (file -> role)

index.html: verifyInstructionsHint + verifyInstructionsStepHint + VERIFY_STEP_ROLES (new helpers beside the datadog/codesearch step-hint family); state defaults verifyPaths/verifyFailRun + savePrefs/restorePrefs + clearCanvas sticky comment; third Repo Context Paths UI block (input/chips/clear/checkbox) + JS twins of the rules chip functions; emission at 4 workflow-level sites (genWorkflow/genSubAgents/genAgentTeams/genAgentSDK-as-comment) + 4 per-step sites (the datadogStepHint sites; SDK none by parity); Explain rows (workflow + step); help modal Repo Context Paths entry; awd:meta serialize + adoptMeta (paths array only). tests.html: resetState additions + suites per the spec.

## Success criteria

- A team can commit one VERIFY.md and every future workflow's testers/verifiers execute and report its steps without per-workflow setup.
- A mandated step the agent cannot run can never silently pass - it is visible in the verdict, record, and telemetry.
- Users who configure nothing see zero change in generated prompts.

## Spec quality check

- [x] Each requirement testable and unambiguous
- [x] Scope bounded (Non-goals stated)
- [x] No open clarifications remain (A1-A4 confirmed; openspec question decided INCLUDE at the gate)
- [x] Every scenario names a verifying test (req 2 and 7 carry noted Verifier-traced caveats)
- [x] Success criteria measurable

## Task checklist

- [x] Orchestrator grounding (rules-paths plumbing anchors from multi-repo-claudemd-loading; suggestion semantics from tool-suggestion-semantics)
- [x] Plan unit A (risk-first, resume-unit steps)
- [x] Skeptic review of unit A plan passes (cycle 2 - cycle 1 blocked on a real format-parity gap)
- [x] Sidebar group + checkbox + sticky persistence (state, chips, savePrefs, New Workflow survival)
- [x] Emission: discovery/scoping/role-targeting/reporting contract per format, empty-list silence
- [x] Explain rows + help entry
- [x] Tests per spec
- [x] Code review passes (both-units gate)
- [x] Verifier gate passes (delivery verified by execution - independent harness, all five formats, adversarial probes)
- [x] Full suite green via ./run-tests.sh (1447/1447, deterministic across two runs)
- [x] Finalize: record, index entry, timeline line, run report

## Verify

- `./run-tests.sh` -> PASS 1447/1447 (1398 pre-run baseline + 6 unit B + 23 unit A + 20 run-level matrix; zero regressions; run twice, deterministic). Doubles as the regression confirmation for the matched records dogfood-run-fixes and sidebar-collapse.
- Content-lint grep on the diff -> exit 1; no em dashes in prose (the diff dash characters are inside toNotContain guard assertions, the pre-existing suite pattern).

## History

- 2026-07-03: created (by verification-instructions)
- 2026-07-03: retargeted to owner-only routing and reframed as repo-mandated verification files - the per-step contract now goes to exactly one step (last verifier, else last tester; reviewers dropped from the execute contract; additive-not-substitute sentence added) per the director's duplication and terminology rulings (by agent-craft-batch)
- 2026-07-07: the OpenSpec context line now carries the posture both ways (fail-the-run vs recorded-not-run-failing) - a foreign OpenSpec runner previously executed and reported the checks but was never told blocked required checks should fail the run (director question exposed the gap) (by verification-instructions)

## Outcome

Teams can now commit standing verification mandates (VERIFY.md, rules/E2E.md) and every generated workflow's testers, verifiers, and reviewers receive the execute-and-report contract - scoped by blast area, severity-aware, posture-configurable, and impossible to silently skip. index.html +187 for the feature, 23 implementer tests + the run-level matrix; silence-when-empty proven structural at every surface. Gates: plan Skeptic cycle 2 (a real five-format parity gap caught and fixed), review cycle 1, delivery Verifier cycle 1.

## Gotchas / non-obvious

- The beat MARK lives in both the blockquote header and the SDK comment header; the step MARK (executed-with-result) is deliberately absent from the beat so implementer-absence tests stay meaningful.
- verifyFailRun serializes into awd:meta as a strict boolean with no defensive fallback - the state seed + restore guard keep it boolean; a round-trip test pins explicit false.
- awd:meta and the tuning-prompt JSON always carry verifyPaths/verifyFailRun even when empty - intended round-trip parity with rulesPaths (metadata, not a prompt beat; does not violate emission silence).
- Requirements 2 and 5 are prose contracts honored by the runtime orchestrator - verifiable in emission, executable only in a live run.

## Built with (provenance)

Workflow `verify-instructions-sonnet5` (custom, built via the designer's own serializeWorkflow API and imported): fork(Planner A, Planner B) -> per-plan Skeptic gates (max 3) -> Implementer B -> Implementer A -> Reviewer gate (max 3) -> Tester -> Verifier gate ("Delivery verified?", revise -> Implementer A, max 3) -> delivery. Memory + durable records + grounding ON; models opus; run live by Claude (Fable) as orchestrator - third dogfood run: first fork, first Verifier gate, first import-path exercise.

## Links

- Grounds on / touches: grounds on `.workflow/multi-repo-claudemd-loading.md` (rulesPathsHint plumbing - the five-site parity model), `.workflow/tool-suggestion-semantics.md` (suggestions-never-limits), `.workflow/dogfood-run-fixes.md` (per-format gating discipline); amended no other records.
- Branch: main (uncommitted delivery for the director). Sibling unit: `.workflow/sonnet-5-models.md` (same run).
```awd:run
{"workflow": "verify-instructions-sonnet5", "repo": "agentic-workflow-designer", "steps": [{"slug": "planner-verification-instructions", "status": "done"}, {"slug": "planner-sonnet-5-models", "status": "done"}, {"slug": "skeptic-review-sonnet-5-plan", "status": "done"}, {"slug": "skeptic-review-verification-plan", "status": "done"}, {"slug": "implementer-sonnet-5", "status": "done"}, {"slug": "implementer-verification-instructions", "status": "done"}, {"slug": "reviewer", "status": "done"}, {"slug": "tester", "status": "done"}, {"slug": "verifier-delivery", "status": "done"}], "gates": [{"slug": "sonnet-5-plan-sound", "cycles": 1, "final": "Passed"}, {"slug": "verification-plan-sound", "cycles": 2, "final": "Passed"}, {"slug": "review-passed", "cycles": 1, "final": "Approved"}, {"slug": "delivery-verified", "cycles": 1, "final": "Verified"}], "notes": "FIRST REVISE CYCLE in dogfood history: Skeptic blocked plan A cycle 1 on a real five-format parity gap (genClaudePrompt omitted); planner re-spawn recovered its full plan from its memory file, fixed in one pass, delta-scoped re-review passed cycle 2. Fork pipelined honestly (unit B implemented while unit A was still in plan review). TWO harness dead-spawns (instant return, zero tools) recovered via one re-run each - memory files checked first, no trace either time. First Verifier gate: independent execution harness, adversarial probes, honest traced-not-executed caveats. 1398 -> 1447 tests."}
```
