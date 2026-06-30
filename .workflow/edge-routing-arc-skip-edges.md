# Edge routing: arc forward skip edges around intervening nodes

Branch: main. Status: current.

## Why and scope

A forward edge that skips over node(s) on the same row (a bypass edge, e.g. an imported schema whose `apply.requires` points at a mid-chain artifact, so review->Apply jumps past resurrect/validate) was drawn as a flat bezier and visually cut straight through the boxes between its endpoints. Back-edges already arced (below) to avoid exactly this; forward edges did not. This gives obstructed forward edges the same treatment - they arc ABOVE the row so they stay readable. General renderer fix (benefits any workflow with a bypass edge), surfaced by the foreign-schema import.

Non-goals: full obstacle-avoiding orthogonal routing (a bezier arc clears the common single-row case without that complexity); changing node layout; changing the data (the edge is correct - only its path geometry changes).

## Requirements

- R1 - A forward edge whose straight path would cross another node's box is detected and arced above instead of cutting through. [tests: "a forward skip edge over an intervening node is detected and arced clear"; "bezierPath arcs an obstructed forward edge above the row"]
- R2 - Adjacent forward edges (nothing in between) and back-edges are unchanged. [test: adjacent returns not-obstructed; back/right-to-left returns false]
- R3 - Detection ignores the edge's own endpoints as obstacles. [test: from/to never count]
- R4 - Geometry only: endpoints, data, and node positions are unchanged. [verified: only the bezier control points move]

## Approach and decisions

- New `connectionObstructed(x1,y1,x2,y2,fromId,toId)`: true when a node (not from/to) sits horizontally between the endpoints with vertical overlap of the near-horizontal edge band. Forward-only (returns false when x2 <= x1, so back-edges keep their own arc-below path).
- `bezierPath` / `bezierMidpoint` gain an `arc` param: when set, control points lift to `min(y1,y2) - max(80, dx*0.12)` so the curve bows above the row - the forward mirror of the existing back-edge arc-below.
- The render loop computes `arc = !isBack && connectionObstructed(...)` and passes it through. Only edges that would actually cross a node change; everything else renders identically.
- Arc ABOVE (back-edges arc below) so a forward skip and a back-edge stay visually distinct.
- Heuristic, not full routing: a long arc could still pass near nodes in a dense multi-row graph. Accepted - it fixes the common single-row bypass cleanly and is a strict improvement over cutting straight through; true orthogonal routing is a separate, larger feature if ever needed.

## Surface area (file -> role)

- `index.html`: new `connectionObstructed`; `bezierPath` + `bezierMidpoint` gain an `arc` param + branch; the connection render loop computes and passes `arc`. (Core renderer - this is a general fix, not a removable feature block.)
- `tests.html`: 2 tests (obstruction detection incl. forward-only + endpoint-exclusion; bezierPath arc geometry) + `bezierPath`/`connectionObstructed` bridged.

## Task checklist

- [x] `connectionObstructed` (forward-only, excludes endpoints, vertical-band overlap)
- [x] `bezierPath`/`bezierMidpoint` arc branch (lift above the row)
- [x] Render loop computes/passes `arc`
- [x] Tests (2) + bridge
- [x] Visual confirmation (headless screenshot of a synthetic bypass schema)
- [x] This record + `_index` + `_timeline`

## Verify

`./run-tests.sh` -> 1151/1151 (was 1149; +2). Visual: rendered a synthetic schema (alpha->bravo->charlie->delta->echo, apply.requires:[charlie]) headlessly and screenshotted - the charlie->Apply skip edge arcs cleanly above delta and echo; adjacent chain edges stay flat. Geometry-only change; adjacent and back edges unchanged.

## Spec quality check (finalize)

- [x] Every requirement has a verifying test (plus a visual screenshot check)
- [x] Scope bounded; non-goals stated (no full orthogonal routing)
- [x] No open clarifications
- [x] Verify section records real results (1151/1151 + screenshot)
- [x] Geometry only; adjacent/back edges unchanged
- [x] Finalized for commit

## Outcome

Forward skip/bypass edges now arc above intervening nodes instead of cutting through them, mirroring the existing back-edge arc-below. A general readability fix (helps any workflow with a bypass edge), surfaced while importing a real third-party schema whose apply depended on a mid-chain artifact.

## Built with (provenance)

Authored directly after a foreign-schema import made the flat skip-edge cut-through visible. Verified via the headless suite (1151/1151) and a screenshot of a synthetic bypass graph.
