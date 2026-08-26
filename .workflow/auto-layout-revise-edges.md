# Auto Layout: revise edges seed cycle-breaking

Context: no work item (director-reported rendering defect, any preset or workflow affected). Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- `autoLayout()` seeds its back-edge set with the app's revise semantics BEFORE running the DFS cycle-breaker: every connection `isReviseBackEdge()` classifies as a revision path (a decision's noLabel edge - the same authority `topologicalSort` uses) is marked as a back-edge up front, under two guards. (1) Loop closure: the target reaches the decision again through the remaining edges - only the edge under test is excluded, so chained revise loops whose return path crosses another decision's No branch still seed. (2) The target keeps at least one OTHER forward in-edge - a remediation node whose only inbound edge is the revise edge (Gate -Revise-> Fixer -> Reviewer) keeps that edge forward and the DFS breaks its loop on the return edge, so it never strands at layer 0. Seeded edges never enter the DFS as forward edges.
- The DFS still runs afterward for any remaining cycles (hand-built loops without decisions), unchanged.
- Guard for forward No branches: a decision branch that goes genuinely forward (an escalation path whose target never loops back) is NOT seeded, so its target keeps a normal downstream layer.
- Robustness at the same seams: Step 2 guards both edge endpoints, so an imported dangling connection (ghost target) no longer throws and silently aborts layout; `deserializeWorkflow` backfills missing connection ids uniquely (hand-edited or tuning-round-trip JSON keeps node ids only), so every id-keyed consumer holds.
- Result: fork siblings targeted by the same revise decision share a layer and stack vertically (Backend and Frontend side by side in the Full Stack preset), for every preset and every hand-built workflow - `loadPreset` runs `autoLayout()`, so this IS the default render.

## Why and scope

DFS-only cycle-breaking is visit-order dependent. In the Full Stack preset the DFS reached the decision through Backend, so the decision's `Revise -> Frontend` edge pointed at a still-unvisited node and read as a forward dependency; the DFS instead cut `Frontend -> Reviewer`, and Frontend ranked one layer after the decision - rendered far right beside Tester on every preset apply. The director reported it from the canvas. Scope: `autoLayout()` Step 1 only; ranking, ordering, and positioning are untouched.

## Gotchas / non-obvious

- The "revise-excluded reachability" idiom now exists in FOUR hand-rolled copies with subtly different semantics: `autoLayout`'s `reachesBack` (self-reach true), `validateWorkflow`'s `reaches` (self-reach false), `advisorReachesOutputUnreviewed`, and `advisorReachable` (removable advisor block, so core code cannot call it). A change to revise-edge semantics must visit all four or the canvas silently disagrees with validation and ordering. Extracting one shared helper beside `isReviseBackEdge` was reviewed as the right next step and deliberately deferred - it touches the validator and a removable block, and deserves its own careful unit of work.

## Verify

- `./run-tests.sh` (1628 -> 1634: Suite 17 gains the fullstack-shape regression built with the exact triggering edge order, the forward-No-branch guard, the revise-only-inbound remediation shape, the chained-revise-loop shape, the ghost-edge no-throw case, and the connection-id backfill)
- Visual: headless preset apply confirms Backend/Frontend stacked inside the parallel group by default

## History

- 2026-08-25: created - revise edges seed the back-edge set with a loop-closure guard; DFS retained for non-decision cycles (by direct session)
- 2026-08-25: review fixes (two hand-traced regressions plus hardening) - the seed gained the other-forward-in-edge guard (a revise-only-inbound Fixer was stranded at layer 0; old DFS had kept it right of its gate), reachability excludes only the edge under test (chained revise loops through another decision's No branch previously fell back to the visit-order DFS and re-flung siblings), Step 2 guards dangling edge targets (TypeError silently killed the Auto Layout button on ghost imports), deserializeWorkflow backfills missing connection ids (an id-less revise edge poisoned the seed Set), and the dead fails-open typeof guard on isReviseBackEdge dropped (core predicate, house idiom is a bare call). The shared-reachability extraction was deferred with the Gotcha above. 1630 -> 1634 (by direct session)
