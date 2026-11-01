# One notion of the run: unconnected agents never run, and every feature picks the last Verifier from the same connected set

Context: no work item (director direction, 2026-11-01). Branch: main (uncommitted delivery for the director). Status: finalized, committable (left uncommitted for the director). Workflow: one-notion-of-the-run.

```awd:record
{"slug": "one-notion-of-the-run", "status": "current", "date": "2026-11-01", "files": ["index.html (resolveVerifyOwnerId, validateWorkflow, explainAgentNode, explainWorkflow, verifyStatusHtml, the advisor rule j, the evalReachableIds comment)", "tests.html (describe: One notion of the run; the frozen eval describe)"], "verify": ["./run-tests.sh", "./run-tests.sh --verbose"], "superseded_by": null}
```

[Current behavior](#current-behavior) · [Why and scope](#why-and-scope) · [Requirements](#requirements) · [Approach and decisions](#approach-and-decisions) · [Surface area](#surface-area-file---role) · [Task checklist](#task-checklist) · [Verify](#verify) · [Pre-registered eval](#pre-registered-eval) · [Risks](#risks--trade-offs) · [Gotchas](#gotchas--non-obvious) · [Verification ledger](#verification-ledger) · [Found bugs](#found-bugs) · [Outcome](#outcome) · [History](#history)

## Current behavior

One connected set defines the run: `evalReachableIds` (every node reachable, in either direction, from an Input that has at least one edge; when no Input has an edge, every node that has an edge; when the canvas has no edges at all, every node: the two later rules were added by strays-never-run on 2026-11-01). The verification-mandates owner (`resolveVerifyOwnerId`) picks the last Verifier in execution order from that set, else the last Tester, else none, so a stray unconnected Verifier or Tester never owns the mandates and the owner is the same node as the pre-registered eval's executor whenever a connected Verifier exists. The Workflow Review warns by name for every agent that has edges but no connection to an Input ("is not connected to an Input node, so it never runs"); a fully loose agent keeps only the existing not-connected-to-anything warning. Explain says why: the Verifier's step rows, its config-panel status line, the advisor rule (j), and the workflow rows name the owner and the executor, and a stray Verifier's rows say it is not connected to the run (with inline notes alone arming the mandates too). Every generated format is byte-identical to before for a workflow whose agents are all connected.

## Why and scope

Two features each need "the Verifier that runs last" and compute it differently, so a stray Verifier dragged from the palette can own the verification mandates while the connected Verifier executes the eval. One shared notion of which agents belong to the run removes the disagreement and tells the director about agents that will never run. Non-goals: no change to where Add eval places nodes; no new sidebar setting; no change to how the eval executor is chosen today.

## Requirements

1. The Workflow Review MUST warn, by name, for every agent node with no connection to any Input node (reachable along edges in either direction), because it never runs. Given an agent with edges only to other unconnected nodes, When the review runs, Then a warning names it. Given every agent connected, Then no such warning. (Tests: should name each agent of a stray chain exactly once with the never-runs warning; should drop the never-runs warning once the stray chain is connected to the run, even against the edge direction; should give a fully loose agent only the not-connected-to-anything entry, never a second never-runs entry; should never raise the never-runs warning on any preset; eval E1 to E4)
2. The verification-mandates owner MUST be chosen from the agents connected to an Input, preference order kept: the last connected Verifier in execution order, else the last connected Tester, else none. Given a stray unconnected Verifier beside a connected one, Then the connected one owns. Given only a stray Verifier, Then the last connected Tester owns. (Tests: should route the mandates to the connected Verifier, not a stray Verifier that sorts later, in every generated format; should route the mandates to the connected Tester when the only Verifier is stray; should give no step the mandates when every Verifier and Tester is stray; eval E5 to E8)
3. When both a pre-registered eval and verification mandates are configured, the eval executor and the mandates owner MUST be the same node whenever a connected Verifier exists. (Tests: should make the mandates owner the eval executor whenever a connected Verifier exists, and leave the owner to a Tester when none does; eval E9, E10)
4. For a workflow in which every agent is connected, the generated output in all five formats MUST be byte-identical to today's. (Tests: should generate the same output in all five formats for every plain preset as before the change; eval E11, plus the Verifier's full-text probe of 1035 generations with zero diffs)
5. Explain MUST name the mandates owner consistently with the eval executor in both rows, and a stray Verifier's own row MUST say it is not the owner because it is not connected to the run. (Tests: should tell a stray Verifier in its own Explain rows that it never runs; should tell a stray Verifier it is not connected to the run when only inline notes arm the mandates; should name the owner and the executor by label in the workflow Explain rows; should tell a stray Verifier in its status line that it never runs; eval E12, E13)
6. Tests MUST cover the warning, the owner choice with a stray Verifier, the agreement with the eval executor, the byte-identity of the presets, and the Explain rows. (Tests: the 21-test describe "One notion of the run" and the frozen eval block; eval E14)

## Success criteria

- A director who leaves a Verifier unwired sees it named in the Workflow Review before generating.
- The verification mandates and the eval always land on the same Verifier when one is wired in.
- Every existing preset generates the same text as before in all five formats.

## Spec quality check

- [x] Each requirement is testable and unambiguous (planner, 2026-11-01: the no-Input canvas reads as "the linked nodes are the run", decided below)
- [x] Scope is bounded (Non-goals stated)
- [x] No open clarifications remain (Q1 answered by the director)
- [x] Every scenario names a verifying test (or a noted follow-up) (eval E1-E17; the Tester adds the non-eval tests E14 asks for)
- [x] Success criteria are measurable
- [x] Independent verification ran (see Verification ledger)

## Approach and decisions

- Director approval of the plan (2026-11-01): approved as is, no modifications.
- Gate Objective met? cycle 1 (2026-11-01): NOT VERIFIED on E14 (no byte-identity test outside the eval block: the orchestrator had briefed the Tester not to duplicate E11, contradicting the frozen criterion) and on requirement 5 with inline-notes-only mandates (the plan's out-of-scope note did not remove the requirement). Director decision: fix both rather than accept the gap; the eval is not edited.
- Director decision on the Eval Author's open question Q1 (2026-11-01): requirement 5's "both rows" includes the workflow-level Explain rows as well as the two step rows, so criterion E13 stays (question -> yes -> E13).

- Planner (2026-11-01): the run is `evalReachableIds()` (undirected reachability to any Input; with no Input, every node with an edge). It becomes the ONE shared notion: the owner, the executor, and the new review warning all read it. Not renamed (a rename widens the diff for no behavior). The no-Input reading is forced by requirement 3: E17 makes a linked Verifier the executor on a no-Input canvas, so the owner must count that set too.
- Planner: `resolveVerifyOwnerId` filters its topological order by that set; nothing else changes, so the preference order (last connected Verifier, else last connected Tester, else null) holds and the owner equals `evalExecutorId()` whenever a connected Verifier exists, by construction. No memo (the executor's memo stays; owner cost is one extra graph walk per call).
- Planner: the new review entry is a `warn` for an agent that HAS edges but is outside the run; a fully loose node keeps today's "is not connected to anything" warning only (no double entry). Agents only; other node types are out of scope.
- Planner: emitted text does not change (requirement 4). The beat sentence "the Verifier when this workflow has one" stays as is; only Explain reasons, the Verifier config-panel status line, and advisor rule (j) wording change, none of which reach the five generators.
- Planner: a spike of the owner filter, the warning, and two Explain reasons in a scratch copy passed 1977/1977 (all 15 eval tests, E11 byte-identity included), so the shared-set change breaks no existing test.

## Surface area (file -> role)

- index.html `resolveVerifyOwnerId`: filter by `evalReachableIds()`.
- index.html `validateWorkflow`: the new warning after the "not connected to anything" loop.
- index.html `explainAgentNode` rows "Verification-instructions step hint" and "Pre-registered eval step hint": owner, executor, and stray-Verifier reasons.
- index.html `explainWorkflow` rows "Verification instructions" and "Pre-registered eval": name the chosen step and the connected rule.
- index.html `verifyStatusHtml` and advisor rule (j): stray-aware wording.
- index.html comments above `evalReachableIds` and `VERIFY_OWNER_ROLES`: say the set is the shared notion of the run.
- tests.html: one new describe (titles start with "should") for the warning, owner with a stray, owner = executor, preset byte-identity, Explain rows, the status line; the eval describe is frozen.

## Task checklist

- [x] Write the pre-registered eval from the requirements (@eval-author)
- [x] Plan the change: the connected set, the owner choice, the warning, the Explain rows, the tests (@planner)
- [x] Verifier config-panel status line and advisor rule (j) say why a stray Verifier is not the owner (@implementer)
- [x] Workflow Review warns by name for every agent not connected to an Input (@implementer)
- [x] Verification-mandates owner chosen from the connected set, preference order kept (@implementer)
- [x] Eval executor and mandates owner agree whenever a connected Verifier exists (@implementer)
- [x] Explain rows name the owner consistently; a stray Verifier's row says why it is not the owner (@implementer)
- [x] Tests for the warning, the owner choice, the agreement, the preset byte-identity, and the Explain rows (@tester)
- [x] Byte-identity of every preset in all five formats confirmed (@verification-tester)
- [x] Execute the pre-registered eval and report every criterion (@verification-tester)

## Verify

- `./run-tests.sh` (headless Chrome; Python 3 and Chrome present). Result after the Implementer: 1977 of 1977 pass, including all 17 eval criteria; the byte-identity guard E11 passes. After the Tester: 1997 of 1997. After revise cycle 1: 1998 of 1998 (a golden byte-identity test for every plain preset outside the eval block; the notes-only stray Explain row fixed in explainAgentNode via hasVerifyMandates and its test sharpened). Final: `./run-tests.sh --verbose` PASS 1998 of 1998 (Verifier, run 2). Final orchestrator run on the finished tree, machine idle: PASS 1998 of 1998 in about 6 seconds; regression probe against origin/main: 110 preset outputs identical.
- Full-text byte-identity probe (Verifier, run 1, scratch page removed): the HEAD index.html beside the working copy, 23 presets x 9 variants x 5 formats, 1035 comparisons, 0 diffs; the Review entries and the mandates owner identical to HEAD on every preset.
- Environment capability survey: this machine runs the single-file app headless (run-tests.sh, python http.server, Chrome --dump-dom); a real Chrome is available for manual checks; no databases, devices, or external services are involved; git is present but delivery is left uncommitted.

## Pre-registered eval

Frozen: sha256 046bac2989166ededaf53878ecfbdb5e21381c8c1565528f03147af1630f64e0 over the criteria block below, written by the Eval Author from the requirements before any plan existed (transcribed verbatim from its handoff; no later step edits these lines). Executable checks live in tests.html, describe "Eval: one notion of the run (pre-registered eval)"; 7 of its tests fail today by design, every guard passes.

```
Fixtures: Canvas H = In -> Builder(coder) -> Run Verifier -> Done, plus stray chain Side Planner -> Side Coder -> Side Tester -> Stray Verifier (sorts after Run Verifier). "Paths" = verifyPaths ['docs/verify.md']. "One-click eval" = addPreRegisteredEval(Input). Workflow name pinned to 'eval-fixture' (a blank name is random).
Structural assumptions: resolveVerifyOwnerId, verifyInstructionsStepHint, evalExecutorId, validateWorkflow entries {type,msg}, explainNode/explainWorkflow rows {part,status,reason} with today's row names; "warn by name" = a warn or error entry whose msg contains the label (info does not count).
E1 [R1] auto: Canvas H; each of the 4 stray agents is named (label substring) by >=1 validateWorkflow() entry of type warn or error.
E2 [R1 must-not, guard] auto: an agent reaching the run only by an edge INTO a connected node, and an agent connected only to a second Input, are named by no review entry.
E3 [R1, guard] auto: a fully loose agent is still named by a warn or error entry.
E4 [R1/R4, guard] auto: every preset, plain and with one-click eval (all agents connected): per-agent count of review entries naming the quoted label equals today's captured map.
E5 [R2] auto: Canvas H + paths: resolveVerifyOwnerId() = Run Verifier; verifyInstructionsStepHint non-empty for it, empty for Stray Verifier; same with inline notes only; same with Stray Verifier fully loose.
E6 [R2] auto: In -> Builder -> Run Tester -> Done, loose Stray Verifier, stray chain ending in Stray Tester sorting after Run Tester: owner = Run Tester; hint only on Run Tester.
E7 [R2] auto: no connected Verifier or Tester, loose Stray Verifier and Stray Tester: owner null; neither gets the hint.
E8 [R2, guard] auto: connected V1 -> Tester -> V2: owner V2; connected V -> Tester: owner V.
E9 [R3] auto: Canvas H + Eval Author (In -> Eval Author -> Builder) + paths: evalExecutorId() = resolveVerifyOwnerId() = Run Verifier; equal with inline notes only.
E10 [R3] auto: every preset + paths + one-click eval + stray agent chain longer than the preset ending in a Verifier: when evalExecutorId() is non-null, resolveVerifyOwnerId() equals it.
E11 [R4, guard] auto: every preset x {plain, paths, paths+one-click eval, +memory+record} x five generators (genWorkflow, genSubAgents, genAgentTeams, genClaudePrompt, genAgentSDK): cyrb53 hash = today's captured hash.
E12 [R5] auto: Canvas H + Eval Author + paths, explainNode formats prompt/subagent/teams: Run Verifier rows "Verification-instructions step hint" and "Pre-registered eval step hint" emitted; Stray Verifier both skipped; its verification row reason matches /connect|outside the run|not part of the run|not in the run|never runs/i.
E13 [R5, decided: director answered Q1 yes, "both rows" includes the workflow-level rows] rubric + auto guard: explainWorkflow('prompt') rows "Verification instructions" and "Pre-registered eval" on Canvas H + Eval Author + paths, and "Verification instructions" on the E6 canvas + paths. PASS: each reason is true for its canvas and both rows describe the same chosen step (same label, or the same rule including connection to the run). FAIL: either reason states a rule that a stray Verifier satisfies (for example "Verifier if present"). Auto guard: neither reason contains "Stray Verifier". Rubric because the requirement states no wording.
E14 [R6] manual: git diff tests.html outside the eval describe. PASS: new or changed it() blocks (titles start "should") cover (a) the warning, (b) owner with a stray Verifier, (c) owner = executor, (d) preset byte-identity, (e) the Explain rows. FAIL: any topic has no test outside the eval block.
E15 [non-goal, guard] auto: per preset, one-click eval node types/roles/labels/positions and edges hash = today's.
E16 [non-goal, guard] auto: #sidebar input/select/textarea count = 35 and awd_prefs key set = today's 36 keys.
E17 [non-goal, guard] auto: executor unchanged: Canvas H + author -> Run Verifier; no Input, author -> coder -> Linked Verifier + loose Verifier -> Linked Verifier; no Input and no linked Verifier -> null; two Inputs, Verifier connected only via the second Input sorting last -> it (and owner = it).
```

**Eval results, run 1 (2026-11-01, Verification: Tester).** 16 PASS, 1 FAIL, 0 BLOCKED of 17; verdict NOT VERIFIED (E14, plus requirement 5 unmet with inline-notes-only mandates, reported outside the criteria).
- E1 PASS: eval test green; probe: 4 warn entries "is not connected to an Input node, so it never runs" for Side Planner, Side Coder, Side Tester, Stray Verifier
- E2 PASS: eval test green
- E3 PASS: eval test green
- E4 PASS: eval test green; probe: validateWorkflow() JSON identical HEAD vs tree for 23 presets x 9 variants
- E5 PASS: eval test green; probe also checked the hint parts the test omits: Run Verifier hint non-empty, Stray Verifier hint empty, with paths, notes only, loose, loose + notes
- E6 PASS: eval test green
- E7 PASS: eval test green
- E8 PASS: eval test green
- E9 PASS: eval test green
- E10 PASS: eval test green
- E11 PASS: eval test green; probe: 1035 full-text comparisons HEAD vs tree, 0 diffs
- E12 PASS: eval test green; actual stray reason: "not the owning verification step: this step is not connected to an Input, so it never runs and cannot own the mandates" in prompt, subagent, teams
- E13 PASS: rubric: Canvas H rows name "Run Verifier" for both, rule "last Verifier connected to the run"; E6 canvas names "Run Tester"; guard test green
- E14 FAIL: topic (d) preset byte-identity has no test outside the eval block; the tester's preset test checks warnings and owner only. (a)(b)(c)(e) covered
- E15 PASS: eval test green
- E16 PASS: eval test green; gold = 35 controls, 36 keys
- E17 PASS: eval test green

**Eval results, run 2 (2026-11-01, Verification: Tester, delta re-verify after revise cycle 1).** 17 PASS, 0 FAIL, 0 BLOCKED; verdict VERIFIED.
- E1 PASS: Unchanged from run 1. The test passes in run 2.
- E2 PASS: Unchanged from run 1. The test passes in run 2.
- E3 PASS: Unchanged from run 1. The test passes in run 2.
- E4 PASS: Unchanged from run 1. The test passes in run 2.
- E5 PASS: Unchanged from run 1. The test passes in run 2.
- E6 PASS: Unchanged from run 1. The test passes in run 2.
- E7 PASS: Unchanged from run 1. The test passes in run 2.
- E8 PASS: Unchanged from run 1. The test passes in run 2.
- E9 PASS: Unchanged from run 1. The test passes in run 2.
- E10 PASS: Unchanged from run 1. The test passes in run 2.
- E11 PASS: Unchanged from run 1. The test passes in run 2.
- E12 PASS: The test passes. The inline-notes probe shows the not-connected reason on the stray Verifier's row in all three formats.
- E13 PASS: Re-judged on the rubric: both rows name "Run Verifier" with the rule "the last one connected to the run". The guard test passes.
- E14 PASS: (d) is now covered by "should generate the same output in all five formats for every plain preset as before the change". Topics (a), (b), (c) and (e) are unchanged from run 1.
- E15 PASS: Unchanged from run 1. The test passes in run 2.
- E16 PASS: Unchanged from run 1. The test passes in run 2.
- E17 PASS: Unchanged from run 1. The test passes in run 2.

## Risks / trade-offs

- The eval's byte-identity sweep (E11) generates every preset in four configurations across five formats. On an idle machine the whole suite still runs in about 6 seconds; while several headless suites ran concurrently during this workflow it took about 45 seconds against the runner's 60-second budget and one attempt produced no results before the retry passed. If a slow or busy machine trips the budget, trim E11 to fewer configurations or move the full sweep to a verify command (the frozen criterion stays; its test is what would move).
- One extra graph walk per owner call (evalReachableIds is memoized on the graph shape; no measurable slowdown).

## Gotchas / non-obvious

- Eval E11's configurations 2 and 3 generate every preset WITH the one-click eval, so their golden hashes include the eval preamble's text; a later change to the eval's emitted wording requires recapturing those goldens (configurations 0 and 1 are untouched by such a change). First recapture: 2026-11-01, when the preamble gained the brief-toward-the-eval and fold-answers sentences.
- Orchestration lesson from this run: a step brief must never contradict a frozen criterion; the eval is the acceptance spec the orchestrator briefs toward, not around (gate cycle 1).
- Eval criterion E12's regular expression for a stray Verifier's Explain reason also matches the older generic wording ("an expensive check never runs twice"), so E12 passed after the owner change alone; the Tester's own test checks the stray wording directly (Implementer, 2026-11-01).

## Verification ledger

- [x] Independent code review of the index.html diff against the requirements and the matched records' invariants (Reviewer, 2026-11-01): PASS, no critical or high findings; suite re-run 1977 of 1977; headless probe of the new Explain and status strings on a stray sub-chain canvas.
- [x] Tester suite (2026-11-01): 20 tests in one describe before the frozen eval block; suite 1997 of 1997; three mutations (owner filter removed, warning disabled, stray Explain branch removed) each caught by the new tests, the third by the new tests alone (eval E12 cannot see it, see Gotchas). Revise cycle 1: two more mutations caught (the old paths condition restored; one space in an emitted heading).
- [x] Verifier run 1 (2026-11-01): frozen hash recomputed and matched; eval describe byte-identical to the post-freeze copy; suite 1997 of 1997; headless full-text probe 1035 generations, 0 diffs; real-app probes of the stray, no-Input, stray-cycle, Input-with-no-edges, empty-canvas, advisor, and notes-only cases; verdict NOT VERIFIED (E14; requirement 5 with notes-only mandates).
- [x] Verifier run 2 (2026-11-01, delta): hash matched; suite 1998 of 1998 (eval 16 of 16 tests, Tester 21 of 21); golden map equal to the frozen eval's pre-change values for all 23 presets; notes-only probe shows the not-connected reason in the prompt, subagent, and teams formats; content lint clean; verdict VERIFIED.

## Found bugs

- A stray Verifier's Explain verification row says "no verification paths configured" when the mandates are inline notes only, instead of the not-connected reason: the branch checks file paths before notes (`explainAgentNode`, the verification step-hint row; fix is `!hasVerifyMandates()` in that condition, Explain only). Pre-existing ordering quirk, declared out of scope by the approved plan; reported by the Reviewer 2026-11-01. FIXED in revise cycle 1 after the Verifier reported requirement 5 unmet with notes-only mandates (director decision).
- (Raised again by the house review of this diff, 2026-11-01: the UI says a stray step never runs while the prompt lists it; the next change should filter strays out of the generators or soften the wording.) All five generators still emit a stray (unconnected) agent as a numbered step, so "never runs" describes the designer's notion of the run, not the emitted prompt (the generators' step loop); pre-existing, declared out of scope by the plan, reported by the Verifier. Director's call: a later change can skip unreachable agents in the generators or stop the run on the warning.
- With inline notes alone arming the mandates, the owner's own Explain row still says "verification paths configured"; the owner is right, the wording is old (explainAgentNode, the owner branch). Reported by the Verifier; cosmetic.

## Outcome

The designer has one notion of which agents belong to a run. The verification-mandates owner and the pre-registered eval executor are chosen from the same connected set, so they never disagree; the Workflow Review names any agent that has edges but no path to an Input; Explain, the Verifier's status line, and the advisor say why a stray Verifier is not the owner. Surface: index.html (owner resolver, review, step and workflow Explain rows, status line, advisor rule, one comment) and tests.html (21 new tests plus the 16-test frozen eval). Every preset generates byte-identical output in all five formats. Run shape: six steps, one director question, one approval, one revise cycle on the Verifier's gate, verified on the second pass.

## Built with (provenance)

Workflow `one-notion-of-the-run`: Feature (fast) preset with Add eval. Eval Author -> Planner -> Implementer -> Reviewer -> Review Passed? (3 revisions, No -> Implementer) -> Tester -> Verification: Tester (Verifier loop, Objective met?, 3 revisions, No -> Tester) -> Feature Complete. Director approval before the build on; workflow memory, durable record, and ground-in-prior-records on; Atlassian and code-search MCP toggles on (defaults); every step on the default model (Opus). Delivery: leave uncommitted.

## Links

- Work item: none (director direction in session). Branch: main. PR: none.
- Grounds on / touches: grounds on `.workflow/verification-instructions.md`, `.workflow/pre-registered-eval.md`, `.workflow/review-loop-topo-order.md`; amended `.workflow/verification-instructions.md` (Current behavior: owner from the connected set) and `.workflow/pre-registered-eval.md` (the deferred "one notion of the run" item closed).

## History

- 2026-11-01: created (by orchestrator)
- 2026-11-01: E11 goldens for the eval-including configurations recaptured after the eval preamble changed in pre-registered-eval (the criterion and the record's frozen criteria text are untouched) (by direct session)

```awd:run
{"workflow": "one-notion-of-the-run", "repo": "agentic-workflow-designer", "steps": [{"slug": "eval-author", "status": "done", "turns": 2, "cap": 10}, {"slug": "planner", "status": "done", "turns": 1, "cap": 10}, {"slug": "implementer", "status": "done", "turns": 1, "cap": 10}, {"slug": "reviewer", "status": "done", "turns": 1, "cap": 10}, {"slug": "tester", "status": "done", "turns": 2, "cap": 10}, {"slug": "verification-tester", "status": "done", "turns": 2, "cap": 10}], "gates": [{"slug": "review-passed", "cycles": 0, "final": "Pass"}, {"slug": "objective-met", "cycles": 1, "final": "Pass"}], "eval": {"criteria": 17, "passed": 17, "failed": 0, "blocked": 0}, "notes": "director answered one Eval Author question before the freeze; plan approved as is; one revise cycle on the Verifier gate (E14 missing non-eval test, requirement 5 with notes-only mandates), verified on the second pass"}
```
- 2026-11-01: the connected set gained two rules (an edgeless Input does not define the run; a canvas with no edges is wholly the run) and the five generators plus the approval checkpoint now read it through runSortedNodes, so a stray is absent from the prompt as well as inert in the review (by strays-never-run)
