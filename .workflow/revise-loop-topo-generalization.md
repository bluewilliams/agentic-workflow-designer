# Manual revise loops: topological ordering generalized to all decision failure branches

Branch: main. Status: current.

```awd:record
{"slug": "revise-loop-topo-generalization", "status": "current", "date": "2026-07-01", "files": ["index.html", "tests.html"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

isReviseBackEdge() (any decision's noLabel failure branch) is the shared predicate excluded from topologicalSort's ordering graph and from validateWorkflow's sibling-dependency reachability. Hand-built manual revise loops order correctly under Kahn's algorithm instead of falling back to creation order; all 15 preset outputs are unchanged (verified byte-identical), and the OpenSpec export anchors requires correctly for manual-loop schemas.

## Why and scope

The review-loop-topo-order fix excluded only ATTACHED Skeptic/Verifier back-edges (reviewLoopDecisionFor) from topologicalSort, deliberately leaving hand-built revise loops on the creation-order fallback and naming the generalization as a follow-up. This is that follow-up: any decision's noLabel failure branch is a REVISION path, not a dependency - the app's decision semantics are pass/revise (every generator describes the No branch as "re-run with feedback"), so the ordering graph now excludes them all.

## Key decisions

- **One shared predicate**: new top-level `isReviseBackEdge(c)` (decision node + edge labelled with its noLabel, 'No' fallback) replaces both `isReviewLoopBackEdge` (its strict superset - attached-loop decisions are decisions with noLabel back-edges) and validateWorkflow's inline `isReviseEdge` copy (now an alias). topologicalSort and the sibling-dependency reachability can no longer disagree about what counts as a dependency.
- **All 15 presets verified byte-identical** before/after (full genWorkflow + genSubAgents + raw topo order snapshots, headless, diffed): preset creation order already matched dependency order, so the old fallback never misordered THEM - the generalization exclusively fixes hand-built workflows whose creation order differs from flow order (pinned by a new test that creates the Tester first: old fallback would emit it first; Kahn now orders Planner -> Coder -> gate -> Tester).
- **OpenSpec side verified**: a manual-loop schema's gated downstream artifact anchors to the real upstream (requires contains coder, not an orphan root) - same posIdx family as the healed attached-loop case, confirmed by test.
- Semantic note, accepted: a noLabel edge routed FORWARD to an alternative path (if/else-style routing) would also be excluded from ordering; the app's decision model has no if/else semantics (No always means revise), and the validator already treats such edges as revision paths, so consistency wins.

## Changes

- index.html: `isReviseBackEdge()` (replaces isReviewLoopBackEdge; comment carries the semantics); topologicalSort exclusion generalized; validateWorkflow aliases the shared predicate.
- tests.html: new describe - out-of-creation-order manual loop orders by dependencies (topo + genWorkflow), predicate covers manual + attached loops while Yes edges stay dependencies, OpenSpec manual-loop export anchors requires; predicate exposed to the rig.
- .workflow/review-loop-topo-order.md: follow-up line flipped to point here.

## Verification

- 1248 -> 1251 (+3), full suite green with ZERO existing-test changes (the exclusion is a pure superset and presets were already in flow order). Preset before/after snapshots in the session scratchpad (presets-before/after.json). Content-lint.

## Task checklist

- [x] Shared isReviseBackEdge predicate (topo + validator, one source)
- [x] All-preset before/after snapshot diff: byte-identical
- [x] Out-of-order manual-loop fix pinned; OpenSpec requires anchored; Yes-edge stays a dependency
- [x] Follow-up pointer flipped in review-loop-topo-order.md
