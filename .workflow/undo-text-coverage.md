# Undo coverage: text edits become undoable; select-clicks stop eating the stack

Branch: main. Status: current.

## Why and scope

Two undo defects from the UX audit. (a) Config text edits never pushed an undo snapshot, so Cmd+Z after writing a prompt jumped to the last STRUCTURAL snapshot - it could silently wipe a hand-written prompt. (b) Every node mousedown pushed a snapshot even for plain select-clicks, so browsing a workflow flooded the 50-entry cap with no-ops and Cmd+Z "did nothing" repeatedly.

## Key decisions

- **Editing-session grain for text**: the FIRST input event on a config field since it was (re)built or last blurred pushes one snapshot of the pre-edit state; further keystrokes in the burst are free; blur ends the session. The listener is registered BEFORE the state-writing handler on the same elements, so the snapshot always sees pre-edit state. The expand modal needs no special handling - it mirrors edits by dispatching the source field's own input event, which is exactly the mechanism the new listener (and its tests) ride.
- **Drag snapshots commit at drag-END, only if the node moved**: mousedown still captures the snapshot (state must be caught before the gesture mutates it) into `state._dragUndoSnap`, but it reaches the stack in the mouseup handler only when position actually changed. `pushUndo(snap)` gained an optional pre-captured-snapshot parameter for this; all other callers unchanged.
- **Tests written first** (verified failing before implementation, each for the right reason): typing burst = one entry + one undo restores pre-edit text; redo round-trips; blur splits sessions; a structural change after a text edit undoes independently (text survives, then reverts on the second undo); a 10-click select storm consumes ZERO slots; a real drag produces exactly one entry and undoes the move. Tests drive the real config-panel textarea and real mouse events on `.node-group`/`#canvasWrap`.
- Test-rig additions: `undoDepth()` + `clearUndo()` exposures (the shared iframe's stack sits at the 50-cap from earlier tests; depth assertions need a clean baseline).

## Changes

- index.html: pushUndo optional snap param; mousedown captures `state._dragUndoSnap` instead of pushing; mouseup commits it when moved; per-field session listener block ahead of the config binding block.
- tests.html: "Undo coverage: text edits and select-clicks" describe (6 tests) + two exposures.

## Verification

- 1251 -> 1257 (+6), full suite green - including all pre-existing undo/redo tests unchanged. Content-lint.

## Task checklist

- [x] Session-grain text undo (pre-registered listener; blur boundary; modal path by construction)
- [x] Drag-end commit, moved-only; select-clicks free
- [x] Behavioral tests first (seen failing), then green; suite green; content-lint
