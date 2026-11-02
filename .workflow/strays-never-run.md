# Strays never run: an agent with no connection to the run is never emitted as a step

Context: no work item (director direction, 2026-11-01). Branch: main (uncommitted delivery for the director). Status: finalized, committable (left uncommitted for the director). Workflow: strays-never-run.

```awd:record
{"slug": "strays-never-run", "status": "current", "date": "2026-11-01", "files": ["index.html (evalReachableIds, runSortedNodes, genWorkflow, genSubAgents, genAgentTeams, genAgentSDK, genClaudePrompt, approvalCheckpoint)", "tests.html (describe: Strays never run; the frozen eval describe; one migrated Plan approval gate assertion)"], "verify": ["./run-tests.sh", "./run-tests.sh --verbose"], "superseded_by": null}
```

[Current behavior](#current-behavior) · [Why and scope](#why-and-scope) · [Requirements](#requirements) · [Approach and decisions](#approach-and-decisions) · [Surface area](#surface-area-file---role) · [Task checklist](#task-checklist) · [Verify](#verify) · [Pre-registered eval](#pre-registered-eval) · [Verification ledger](#verification-ledger) · [Gotchas](#gotchas--non-obvious) · [Found bugs](#found-bugs) · [Outcome](#outcome) · [History](#history)

## Current behavior

An agent with no connection to the run is never emitted as a step. `runSortedNodes()` returns the topological order restricted to the connected set (`evalReachableIds`), and the five generators and the approval checkpoint build their step and agent lists from it, so a stray chain or a loose agent is absent from every format and the remaining steps are numbered without a gap. The connected set has three rules: with an Input that has at least one edge, every node reachable from such an Input in either direction; with no Input that has an edge (an edgeless Input is not wired yet and does not define the run), every node that has an edge; with no edges at all, every node, so a single agent on an empty canvas still generates its one step and a lone Verifier there owns the mandates and executes the eval. The Workflow Review, the mandates owner, the eval executor, and Explain read the same set, so the prompt and the review agree. Every connected workflow generates byte-identical output in all five formats.

## Why and scope

The designer now has one notion of which agents belong to a run, but the generated prompt still lists agents that notion calls inert, so a director sees "never runs" in the review and a numbered step in the prompt for the same node. Filtering the five generators and the approval checkpoint by the same connected set makes the prompt agree with the review. A canvas with no Input and no edges must keep every node as the run so a single agent on an empty canvas still generates its one step. Non-goals: no change to the connected-set rule for canvases with an Input; no change to the validator text, the owner choice, the executor choice, or Explain wording; no new sidebar setting; no change to the eval machinery.

## Requirements

1. Every generated format (Workflow, Sub-Agents, Agent Teams, Claude.ai, Agent SDK) MUST build its step list from the agents in the connected set, so an agent with no connection to the run is never emitted as a step and the remaining steps are numbered without a gap. Given a stray chain beside a connected workflow, When any format is generated, Then no stray appears and the numbering is contiguous. (Tests: should omit a stray chain from each of the five formats and number the remaining steps without a gap; eval E1, E2, E12, E13)
2. The approval checkpoint MUST choose its pause step and its prior steps from the same connected set. Given a stray build step sorting first, Then the pause lands on the first connected build step and the stray is not a prior step. (Tests: should never choose a stray as the approval pause or count it as a prior step; the migrated Plan approval gate assertion; eval E10, E11)
3. On a canvas with no Input: Given no edges at all, Then every node is the run (a single agent still generates its one step; several loose agents still generate); Given edges, Then the nodes with edges are the run, as today. Given an Input with no edges beside a wired chain, Then the chain is the run (director's rule). (Tests: should keep the one step of a single agent on a canvas with no Input and no edges; should keep every loose agent when the canvas has no Input and no edges; should omit a loose agent beside a chain on a canvas with no Input; should let a wired chain beside an edgeless Input define the run, so its steps and its approval gate stand; eval E6 to E9, E19)
4. For a workflow in which every agent is connected to an Input, the generated output in all five formats MUST be byte-identical to today's. (Tests: eval E3, E4, E15; the Verifier's full-text comparison of 690 preset outputs against HEAD)
5. The Workflow Review warning, the mandates owner, the eval executor, and Explain wording MUST be unchanged; the only observable change is the stray's absence from the prompt, except on the two canvases where the connected set itself changes by the director's decisions (an edgeless Input beside a wired chain; a canvas with no edges). (Tests: should give validateWorkflow, the mandates owner, the eval executor, and Explain the same set the generators emit; eval E16 to E19)
6. Parallel groups and per-repository lanes MUST emit exactly as today when connected; a fork or join with no path to an Input is omitted with its branches. (Tests: should omit a stray fork and join with its branches and keep a connected parallel group as it was; eval E5)
7. Tests MUST cover: a stray chain omitted in each format with contiguous numbering; the single-agent no-Input no-edge canvas; several loose agents; a stray beside a chain on a no-Input canvas; the approval checkpoint ignoring a stray; preset byte-identity.

## Success criteria

- A director who leaves an agent unwired sees it named in the review and absent from the prompt, with no gap in the step numbers.
- A single agent dropped on an empty canvas generates exactly as before.
- Every existing preset generates the same text as before in all five formats.

## Spec quality check

- [x] Each requirement is testable and unambiguous (all seven map to the 20 frozen criteria)
- [x] Scope is bounded (Non-goals stated)
- [x] No open clarifications remain (open: whether the workflow-level attribute leaks listed under Approach are in scope; the plan defaults to out of scope, recorded as a follow-up)
- [x] Every scenario names a verifying test (or a noted follow-up)
- [x] Success criteria are measurable
- [x] Independent verification ran (see Verification ledger)

## Approach and decisions

- Director approval of the plan (2026-11-01): approved with one modification, the edgeless-Input rule below.
- Correction to the plan line above (2026-11-01, at finalize): under the edgeless-Input rule only ONE pinned assertion migrated (the Orphan Coder pause); an Input with no edges beside a wired chain still gives its checkpoint and its steps, so the second assertion stands unchanged.
- Director decision on the Reviewer's finding (2026-11-01): a loose non-agent node beside a connected chain (an Output, a gate, an empty fork) is not part of the run and drops from the output; requirement 4's byte-identity promise is about connected workflows, and every preset is identical. Rejected: keeping loose non-agent nodes in the output, which would reintroduce a second notion of the run for non-agent nodes.
- Director decision on the analyzer's question (2026-11-01): an Input node with no edges does not define the run; it is not wired yet, so the run falls back to the no-Input rule (nodes with edges, or every node when the canvas has none). A wired chain beside an edgeless Input still generates and its approval gate does not vanish, which keeps the plan-approval-gate record's pinned contract; the Review still names the edgeless Input as not connected to anything. Rejected: letting an edgeless Input zero the run, which would blank a director's prompt mid-construction.
- Director decision on the Eval Author's open question Q1 (2026-11-01): the no-Input no-edges clause lives in the shared connected set (`evalReachableIds`), so a lone Verifier on an empty canvas owns the mandates and executes the eval and its Review and Explain rows follow; requirement 5's "unchanged" applies wherever the connected set is unchanged. Rejected: applying the clause to the step list only, which would recreate two notions of the run (question -> the one-notion reading -> E19).
- Plan (Design Analyzer, 2026-11-01): one shared filtering point. A new `runSortedNodes()` returns `topologicalSort()` restricted to `evalReachableIds()`; the five generators replace their one `const ordered = topologicalSort();` line with it, and `approvalCheckpoint` builds its agent list from it. Every later list in a generator (agents, parallels, decisions, outputs, task sections, the parallel-group sibling walk, per-repo lanes) derives from `ordered`, and step numbers come from a counter over the emitted loop, so numbering is contiguous with no further edit. The edge-local reads inside the generators (fork children, decision feeders and revise targets) start from emitted nodes, and the connected set is closed under adjacency, so they never reach a stray. Rejected: five per-generator filters (five chances to drift) and a temporary state swap around generation (catches every global scan, but a global mutation with memo thrash and re-entrancy risk). Prototyped on a scratch copy: all 20 criteria pass and the suite is 2023/2023 green once two pinned plan-approval-gate assertions migrate.
- Reversed invariant, on purpose: the plan-approval-gate record says the checkpoint uses "the SAME agent list every generator emits (unreachable palette nodes included - the generators run them, first in fact)". It still uses the generators' list, and that list now excludes strays, so the round-11 hazard (a stray builder running before the gate) cannot return. Amend that record's Current behavior at finalize. Two pinned assertions in the "Plan approval gate" suite migrate deliberately to the sharper contract: a palette Orphan Coder is no longer the pause (the Reviewer is), and an Input with no edges beside a wired chain now gives no checkpoint and no steps, because that chain is not connected to the Input (Review already says it never runs).
- Known attribute leaks, out of scope by default (no criterion covers them; fixing them touches selectors shared with the Review, Explain, or the run monitor, which requirement 5 freezes): workflow-level helpers scan `state.nodes` directly, so a stray still changes the prompt text without being a step. Probed on the scratch copy (stray beside a connected chain): a stray with effort (`effortHint`), an exhaustive stray (`depthNodes`, prints its label), an aggressive stray reviewer (`reviewerFlagHandlingNote`), a stray Verifier (`genDurableRecordProtocol` ledger), a stray Eval Author (eval sections, prints its label), a stray Atlassian URL (`getWorkflowAtlassianUrls`), a stray with a duplicate label (`buildAgentSlugMap` renames the connected step's slug), and a stray Output (`deliveryFormats` and the delivery blocks). A stray task node does not leak. The Explain run plan (`orchestratorRunPlan`) and the OpenSpec export (`buildOpenSpecSchema`) still list strays; both sit outside the five formats.

## Surface area (file -> role)

Verified by the Design Analyzer (2026-11-01): index.html (`evalReachableIds`: the no-Input no-edges clause and its comment; new `runSortedNodes()` beside `topologicalSort`; the `ordered` line of `genWorkflow`, `genSubAgents`, `genAgentTeams`, `genAgentSDK`, `genClaudePrompt`; the agent list and its comment in `approvalCheckpoint`; no change to `perRepoLaneMap`, `perRepoLaneWalk`, `approvalForkOf`, `isReviseBackEdge`, the parallel-group walks, or any Review or Explain code), tests.html (one migrated assertion in the "Plan approval gate" suite, the Orphan Coder pause; the edgeless-Input assertion stays by the director's rule; eight new tests in the newest suites' conventions).

## Task checklist

- [x] Write the pre-registered eval from the requirements (@eval-author)
- [x] Analyze the generators' step-list construction and the approval checkpoint against the connected set (@design-system-analyzer)
- [x] The connected set keeps every node when the canvas has no Input and no edges (@ui-implementer)
- [x] Each of the five generators builds its step list from the connected set with contiguous numbering (@ui-implementer)
- [x] The approval checkpoint chooses its pause and prior steps from the connected set (@ui-implementer)
- [x] Parallel groups and per-repository lanes unchanged when connected; a stray fork or join omitted with its branches (@ui-implementer)
- [x] Tests for each format, the single-agent canvas, loose agents, a stray beside a chain, the approval checkpoint, and preset byte-identity (@ui-implementer)
- [x] Migrate the two pinned plan-approval-gate assertions that encode the reversed invariant (@ui-implementer) (one migrated: the Orphan Coder pause; the second, the edgeless-Input gate, stays by the director's rule and keeps passing)
- [x] Execute the pre-registered eval and report every criterion (@verification-ui-implementer)
- [x] Review the change against the requirements and the matched records' invariants (@ui-reviewer)

## Verify

- `./run-tests.sh` (headless Chrome; Python 3 and Chrome present). Result after the UI Implementer: 2031 of 2031, the 20 eval criteria included; a mutation that returned the plain sort failed 17 tests. Verifier: 2031 of 2031; 690 of 690 full-text preset comparisons identical to HEAD.
- Environment capability survey: this machine runs the single-file app headless (run-tests.sh, python http.server, Chrome --dump-dom); a real Chrome is available for manual checks; no databases, devices, or external services are involved; git is present but delivery is left uncommitted.

## Pre-registered eval

Frozen: sha256 c8f79ba3bcadf0723526cc509f2b5946457a2bd2cf81eccf2d1df62f062fbb64 over the criteria block below, written by the Eval Author from the requirements before any plan existed (transcribed verbatim from its handoff; no later step edits these lines). Executable checks live in tests.html, describe "Eval: strays never run (pre-registered eval)"; 11 of its tests fail today by design, every guard passes.

```
- E1 [R1,R7] automated: In->Alpha Planner->Beta Coder->Done plus a stray chain (planner->coder) and a loose coder; no "strayling" match (case-insensitive) in any of the five generator outputs.
- E2 [R1,R7] automated: same canvas; in Workflow, Sub-Agents, Agent Teams, Claude.ai the step headings read 1,2 in order, titled Alpha Planner then Beta Coder (assumption: headings match /^(?:\*\*|### )Step (\d+):/m; the SDK has no step numbers).
- E3 [R1,R5] automated: plain and approvePlan+memory+record, all five outputs after adding the strays equal the base canvas outputs byte for byte.
- E4 [R1,R4,R6] automated: every preset, plain, one-click eval, approvePlan+memory+record, plus the stray chain and loose agent; all five outputs equal those without them and hold no match.
- E5 [R6] automated: a stray fork(all)->2 branches->join->agent and a stray per-repo fork->coder->tester->collect, beside the base chain, parallel_research, and cross_repo, plain and approval; outputs equal those without them, no match.
- E6 [R3] guard: one agent, no Input, no edges, plain and approval; five output hashes and the approvalCheckpoint projection equal today's.
- E7 [R3] guard: three loose agents, no Input, no edges; hashes and checkpoint equal today's.
- E8 [R3] guard: no-Input chain with edges; hashes and checkpoint equal today's.
- E9 [R3,R7] automated: no-Input chain plus a loose coder; output equals the chain-only output, no match.
- E10 [R2,R7] automated: approval on, base plus strays; checkpoint node Beta Coder, prior [Alpha Planner], no stray in any field, whole projection equals the base-only checkpoint.
- E11 [R2,R3] automated: approval on, no-Input chain plus a loose coder; checkpoint projection equals the chain-only one, no stray.
- E12 [R1] automated: base plus strays; for each exportFormat after updatePrompt(), no match in getActivePromptText() or #promptOutput text.
- E13 [R1] automated: In->Done plus two loose agents, plain and approval; output equals the In->Done output, no match.
- E14 [non-goal] guard: an agent connected only by an incoming edge and one under a second Input appear in all five outputs; hashes equal today's.
- E15 [R4,R7] guard: every preset in five variants (plain, mandates, one-click eval, memory+record, approval+memory+record); five output hashes equal today's.
- E16 [R5] guard: validateWorkflow [type,msg] hashes on five stray canvases equal today's.
- E17 [R5] guard: connected Run Verifier with a later stray Verifier chain and a loose Verifier: owner and executor are Run Verifier; no-Input chain plus loose Verifier: both are the chain's Linked Verifier.
- E18 [R5] guard: Explain mandates and eval hint rows (prompt, subagent, teams) for three Verifiers and the workflow rows hash equal today's.
- E19 [R3,R5; decided by the director: the no-edge clause lives in the shared connected set] automated: no Input and no edges with mandates on (a lone Verifier; a loose Coder plus a loose Verifier; a loose Eval Author plus a loose Verifier): the Verifier is the mandates owner and the eval executor; no Review entry naming a node there says it never runs or is not connected to an Input, none says no step owns the mandates; its Explain mandates hint is emitted with no never-runs reason, its eval hint has no never-runs reason (emitted when an Eval Author is present), and the workflow Verification instructions row names it.
- E20 [non-goals] guard: 35 sidebar controls, the same awd_prefs keys, one-click eval placement per preset equal today's.
```

**Eval results, run 1 (2026-11-01, Verification: UI Implementer).** 20 PASS, 0 FAIL, 0 BLOCKED; verdict VERIFIED. Control: the same eval against the committed HEAD app fails the 11 behavior criteria and passes the 9 guards.
- E1 PASS: No "strayling" text in any of the five formats. At HEAD it fails: the stray appears in the Workflow output.
- E2 PASS: Steps are numbered 1,2 (Alpha Planner, then Beta Coder) in the four numbered formats. At HEAD they are numbered 1 to 5.
- E3 PASS: Output with strays equals output without them, in plain and in approval+memory+record.
- E4 PASS: Every preset in three variants gives the same output with strays and contains no stray.
- E5 PASS: A stray fork/join and a stray per-repo lane are omitted beside the base chain, parallel_research, and cross_repo.
- E6 PASS: Guard: a single agent with no Input and no edges hashes the same as the golden value, and so does its checkpoint.
- E7 PASS: Guard: three loose agents give the golden output and checkpoint.
- E8 PASS: Guard: a no-Input chain gives the golden output and checkpoint.
- E9 PASS: A no-Input chain plus a loose coder gives the chain-only output.
- E10 PASS: The checkpoint is Beta Coder with prior [Alpha Planner], and no stray appears in any field.
- E11 PASS: On a no-Input canvas, the checkpoint equals the chain-only checkpoint.
- E12 PASS: updatePrompt and #promptOutput contain no stray in any export format.
- E13 PASS: An Input to Done canvas plus two loose agents gives the Input to Done output.
- E14 PASS: Guard: an agent connected only by an incoming edge, or only through a second Input, is still emitted.
- E15 PASS: Guard: every preset in five variants gives the golden hashes.
- E16 PASS: Guard: the Workflow Review hashes on five stray canvases are unchanged.
- E17 PASS: Guard: the mandates owner and the eval executor are Run Verifier, or the chain's Linked Verifier on the no-Input canvas.
- E18 PASS: Guard: the Explain hint rows hash the same as the golden value.
- E19 PASS: A lone Verifier on a canvas with no Input and no edges owns the mandates and executes the eval. At HEAD it fails: the owner is null.
- E20 PASS: Guard: 35 sidebar controls, the same awd_prefs keys, and the same one-click eval placement.

## Verification ledger

- [x] Verifier run 1 (2026-11-01): frozen hash reproduced over the record's criteria; suite 2031 of 2031 from the headless page dump; the same suite against the committed HEAD index.html as a control (2011 pass, 20 fail: the 11 behavior criteria, the 8 new tests, the migrated approval-gate test); side-by-side probe of HEAD and the working tree on 23 presets x 6 variants x 5 formats, 690 of 690 identical, checkpoint projections identical; stray canvases absent from all five formats with contiguous numbering; content lint clean, no dashes; probe files removed. Verdict VERIFIED.
- [x] UI Reviewer (2026-11-01): full diff of index.html and tests.html against the requirements, the two director decisions, and the routed invariants (emitted-id walk unchanged, lane walk unchanged, the connected set still single and memoized); suite 2031 of 2031; content lint clean, no dashes. Verdict PASS, no critical or high findings.

## Gotchas / non-obvious

- The one canvas shape whose Review, owner, executor, and Explain output changes is an edgeless Input beside a wired chain: the chain is the run under the director's rule, so the review no longer says its agents never run, and the edgeless Input is the stray. Requirement 5's "unchanged" holds everywhere else (UI Implementer, 2026-11-01).
- One new test indexes the five-format results by the numbered-format list, which holds because the four numbered formats come first in the same order (Reviewer, 2026-11-01).
- The comment above `evalReachableIds` saying a loose Verifier "never" counts is true only while other edges exist; the next clause qualifies it (Reviewer, 2026-11-01).

## Found bugs

- FIXED after the run (house review, 2026-11-01): Explain's run plan and the OpenSpec export now read `runSortedNodes()`; a stray Eval Author no longer emits the eval contract (`evalAuthorNodes` is the authors in the run, `evalAuthorsOnCanvas` drives the one-click and its menu); a loose Output no longer drives delivery or branching (`runOutputs`); a stray Verifier no longer switches the record into ledger mode.
- validateWorkflow and adviseWorkflow still enumerate every Output on the canvas for their format and branching checks (house review, 2026-11-01); left as is for now because their warnings describe the canvas, loose nodes included, and the loose-node warning already fires beside them.
- Remaining attribute leaks: a stray's effort, a duplicate label (which changes the connected step's slug), an aggressive stray reviewer, or a stray Atlassian URL can still change workflow-level prompt text without the stray being a step (Design Analyzer, 2026-11-01; the selectors are shared with the Review, Explain, and the run monitor).

## Outcome

The generated prompt agrees with the Workflow Review: an agent the review calls never-running is absent from every format, the steps renumber without a gap, and the approval pause can no longer land on a stray. The connected set gained two rules decided by the director (an edgeless Input does not define the run; a canvas with no edges is wholly the run), so a single agent on an empty canvas and a wired chain beside an unwired Input behave as before. Surface: index.html (one new helper, the five generators' input list, the checkpoint's agent list, the connected set) and tests.html (eight new tests, one migrated assertion, the 20-test frozen eval). Every preset generates byte-identical output in all five formats. Run shape: five steps, one director question, one approval with one modification, verified and reviewed on the first pass.

## Built with (provenance)

Workflow `strays-never-run`: UI Component preset with Add eval (the preset's own Verifier became the executor; no loop was added). Eval Author -> Design System Analyzer -> UI Implementer -> Verification: UI Implementer (Verifier loop, Objective met?, 3 revisions, No -> UI Implementer) -> UI Reviewer -> UI review passed? (3 revisions, No -> UI Implementer) -> Component Ready. Director approval before the build on; workflow memory, durable record, and ground-in-prior-records on; every step on the default model (Opus). Delivery: leave uncommitted.

## Links

- Work item: none (director direction in session). Branch: main. PR: none.
- Grounds on / touches: grounds on `.workflow/one-notion-of-the-run.md`, `.workflow/parallel-sibling-emission.md`, `.workflow/plan-approval-gate.md`, `.workflow/cross-repo-change.md`, `.workflow/review-loop-topo-order.md`; amended `.workflow/one-notion-of-the-run.md` (Current behavior: the connected set's two new rules), `.workflow/plan-approval-gate.md` (Current behavior: the reversed invariant), `.workflow/parallel-sibling-emission.md` (History: the walk's input list).

## History

- 2026-11-01: created (by orchestrator)
- 2026-11-01: house review round after finalize, nine findings, all acted on: the eval contract, delivery and branching, the Verification ledger, Explain's run plan, and the OpenSpec export now follow the run rather than the canvas (a stray Eval Author, Output, or Verifier no longer drives workflow-level text); Remove eval is one undo step; the run's execution order has one helper (resolveVerifyOwnerId, evalExecutorId, lastBuildStepId reuse runSortedNodes); a stale undo comment; New Workflow renders the Eval default once. Two older tests that built unconnected Output nodes migrated to connected ones (a loose Output is not a delivery). 2031 -> 2034 (by direct session)

```awd:run
{"workflow": "strays-never-run", "repo": "agentic-workflow-designer", "steps": [{"slug": "eval-author", "status": "done", "turns": 2, "cap": 10}, {"slug": "design-system-analyzer", "status": "done", "turns": 1, "cap": 10}, {"slug": "ui-implementer", "status": "done", "turns": 1, "cap": 10}, {"slug": "verification-ui-implementer", "status": "done", "turns": 1, "cap": 10}, {"slug": "ui-reviewer", "status": "done", "turns": 1, "cap": 10}], "gates": [{"slug": "objective-met", "cycles": 0, "final": "Pass"}, {"slug": "ui-review-passed", "cycles": 0, "final": "Pass"}], "eval": {"criteria": 20, "passed": 20, "failed": 0, "blocked": 0}, "notes": "one Eval Author question answered before the freeze; plan approved with one modification (an edgeless Input does not define the run); verified and reviewed on the first pass"}
```
