# Review-loop back-edges no longer break step ordering (topologicalSort)

Branch: main. Status: current.

```awd:record
{"slug": "review-loop-topo-order", "status": "current", "date": "2026-07-01", "files": ["index.html", "tests.html"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

topologicalSort excludes revise back-edges from its ordering graph (via the generalized isReviseBackEdge - see revise-loop-topo-generalization), so attached Skeptic/Verifier loops emit in correct dependency order in all four prose generators and the OpenSpec export anchors requires on the true upstream instead of orphaning the gated artifact.

## Why and scope

Attaching a Skeptic or Verifier to a NON-terminal node broke the emitted step order in all four prose generators. `topologicalSort` fed the loop's failure back-edge (decision -> revise target) into Kahn's algorithm as a normal dependency, making the loop cluster cyclic: no node in it ever reached in-degree 0, so the whole cluster fell into the "append unvisited in creation order" fallback. Planner -> Coder(+Skeptic) -> Tester emitted as Planner, Coder, **Tester, Skeptic review: Coder** - the orchestrator ran downstream work on unreviewed output, and the document contradicted itself (Tester's "Depends on" named a step that appeared after it). Verified headlessly before the fix in genWorkflow, genSubAgents, genAgentTeams, and genClaudePrompt.

## Key decisions

- **The back-edge is a runtime revision path, not a dependency** - so it is excluded from the ordering graph, not special-cased downstream. New `isReviewLoopBackEdge(c)` identifies it exactly the way `detachReviewLoop` and `setReviewLoopBackTarget` already do: FROM a decision carrying `reviewLoopDecisionFor`, labelled with that decision's `noLabel`. Identification by label (not by destination) matters because the failure branch can be rerouted to any upstream node.
- **The decision -> downstream forward edges stay in the graph** (they ARE dependencies), which is what pulls the gated downstream step after the loop.
- **Manual revise loops (plain decisions the user wires back by hand) are deliberately NOT excluded** in topologicalSort. They still cycle into the fallback, which today happens to emit creation order - the presets rely on that and stay byte-identical. Generalizing the exclusion to every decision failure branch was DONE as a follow-up the same day: see .workflow/revise-loop-topo-generalization.md (all 15 presets verified byte-identical under the generalization).
- **OpenSpec export healed for free**: the mid-chain-loop export previously gave the gated downstream artifact `requires: []` (an orphan root an OpenSpec run could execute first) and pointed `apply.requires`/`tracks` at the skeptic. With correct topo order the existing `posIdx` upstream filter resolves naturally: planner [] -> coder [planner] -> skeptic-review-coder [coder] -> tester [skeptic-review-coder], apply requires tester and tracks tester.md. No exporter code change needed; a regression test pins the chain.

## Changes

- index.html: `isReviewLoopBackEdge()` helper + one-line exclusion in `topologicalSort`'s edge pass.
- tests.html: "Review-loop topological ordering (mid-chain loops)" describe - topo order assertion, Skeptic-before-Tester heading order in all four prose formats, OpenSpec dependency-chain regression (tester requires the skeptic artifact, apply requires tester, no orphan `requires: []`).

## Verification

- Headless before/after: step order Planner, Coder, Tester, Skeptic -> Planner, Coder, Skeptic, Tester in all four formats; OpenSpec tester stanza `requires: []` -> `requires: - skeptic-review-coder`.
- Full suite green (no existing ordering/preset test changed). Content-lint.

## Task checklist

- [x] isReviewLoopBackEdge helper (same identification as detach/reroute)
- [x] Exclude the back-edge from topologicalSort adjacency
- [x] Verify decision forward edges still order the gated downstream after the loop
- [x] Confirm OpenSpec requires-chain heals with no exporter change; pin with regression test
- [x] Tests: topo order, four prose formats, OpenSpec chain; suite green; content-lint
