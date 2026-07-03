# Revise-edge continuity: the loop-back tells you what a revise means

Branch: main. Status: current.

```awd:record
{"slug": "revise-edge-continuity", "status": "current", "date": "2026-07-03", "files": ["index.html", "tests.html"], "verify": ["./run-tests.sh", "grep -c 'reviseContinuity' index.html"], "superseded_by": null}
```

## Current behavior

A revise loop-back edge styles itself to the ACTIVE output format's continuity semantics: solid when the execution context persists across the revise (Workflow and Claude.ai single-session, Agent Teams' persistent teammates), dashed when a fresh agent is spawned (Sub-Agents, SDK). Hovering the edge shows the exact semantics as an SVG title (Sub-Agents' tip mentions the memory file when memory is on); the Explain anatomy's Revise-routing row carries the same phrase from the same helper; one help-modal Canvas Tips line is the reference. Switching output tabs restyles the edge live.

## Why and scope

Owner idea from the "isn't respawning lossy?" conversation: the loop-back edge means something different per format (same teammate continues vs fresh spawn briefed from memory), and the canvas could teach that - the rare case where format-awareness on the canvas carries real semantics rather than decoration. Owner's constraint: no tight coupling between canvas and output tabs. Legibility design: line-style semantics are unreadable unaided, so the feature is layered disclosure - the style CHANGE on tab switch is the hook, the hover tip teaches, the Explain row seals, help documents.

## Key decisions

- **One pure helper is the single source**: `reviseContinuity(format)` -> `{solid, tip}` beside `isReviseBackEdge`. The canvas renderer and `explainDecisionNode` both ask it, so tooltip and anatomy can never disagree. Rule: solid = context persists; dashed = fresh spawn.
- **Loose coupling, zero new seams**: `setExportFormat` already calls `render()`, so tab switches refresh edges with NO new wiring - the renderer simply consults the helper at draw time behind a `typeof` guard. Removing the helper block returns edges to exactly their prior rendering (guard shape test-pinned by undefining the helper and asserting a clean render).
- **CSS does the styling**: two classes (`revise-continues` -> `stroke-dasharray:none`, `revise-respawns` -> `6 3`) override the visual back-edge dash only on semantic revise edges (`isReviseBackEdge`, reused not duplicated); all other edge styling untouched. A forward-pointing revise edge (rerouted upstream) still styles correctly since the semantic predicate, not geometry, drives it.
- **Tip lands as an SVG `<title>`** (native hover, no tooltip machinery, textContent-safe).

## Changes

- index.html: CSS pair; `reviseContinuity()` removable block; guarded renderer consult + title; Revise-routing explain row appends the helper's phrase; Canvas Tips help line.
- tests.html: helper mapping across five formats + memory variant; live DOM dashed-under-subagent / solid-under-teams with title text via real `setExportFormat`; forward edge untouched; explain-row phrase per format; removability (helper undefined -> pristine render).

## Verification

- 1336 -> 1340 (+4), suite green; content-lint. DOM evidence is the test suite itself (headless Chrome, real render).

## Task checklist

- [x] reviseContinuity() single-source helper (5 formats, memory-aware subagent tip)
- [x] Guarded renderer consult + SVG title; CSS pair; forward edges untouched
- [x] Explain Revise-routing row phrase from the same helper
- [x] Canvas Tips help line
- [x] Tests incl. removability; suite green; content-lint
