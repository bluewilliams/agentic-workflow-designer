# Memory & Durable Record section declutter

Context: no work item (direct session polish, director-requested). Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- The sidebar's Memory & Durable Record section shows the derived memory path as one subtle inline line: a `memory-help` paragraph reading `Memory path:` followed by the path in a small code chip. The chip carries the `memoryPathDisplay` id, so `updateMemoryPath()` and `validateStoryInput()` keep writing `textContent` into the same element. The old uppercase label + boxed display pair is gone.
- The editable Artifact Path keeps its uppercase label and input: editable fields keep labels, derived displays do not. That contrast is the visual cue for "you can change this one".
- The Export -> Handoff package tip paragraph is removed from the section (with its two `memory-hint` CSS rules). The Help modal still documents the Handoff package, and the handoff export toast still points users at Keep a durable record.
- Two help texts are one line shorter: Ground in prior records drops "surface area" and the parenthetical phrasing; Keep a durable record drops the trailing "Versioned with your code." sentence ("committable" already says it, and the Help modal keeps the full story).
- `.memory-section .memory-help code` gains `overflow-wrap:anywhere` so long derived paths wrap cleanly inside the chip.
- All behavior contracts are untouched: every show/hide seam targets `memoryPathField`, `durableRecordField`, and `artifactPathField` by id, and every id and container nesting is unchanged, so toggle, restore-from-localStorage, preset-apply, and import paths behave exactly as before.

## Why and scope

The section was the busiest block in the sidebar: three default-on toggles each carrying multi-line help, two label + box path displays of equal visual weight (one derived, one editable), and a three-line accent-colored tip. The director asked for a calmer presentation with zero behavior change. Scope: presentation only - markup and CSS inside the section, no JS, no emitted-prompt text.

## Verify

- `./run-tests.sh` (1613/1613; toggle-reveal, path-derivation, and afterEach-reset tests cover the touched seams)
- Visual: headless screenshot of the expanded section confirms the inline path line, the durable-block guide, and the removed tip

## History

- 2026-08-22: created - memory path demoted to an inline chip line, Handoff tip removed, two help texts trimmed, dead `memory-hint` CSS dropped; ids and containers pinned unchanged (by direct session)
