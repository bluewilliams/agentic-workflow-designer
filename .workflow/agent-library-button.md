# Agent Library: Add to Canvas dressed as a primary row action

Workflow: agent-library-button. Branch: main. Status: finalized, committable.

```awd:record
{"slug": "agent-library-button", "status": "current", "date": "2026-07-10", "files": ["index.html"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

The Agent Library row's "Add to Canvas" button uses the standard `.btn.sm` class like its Edit/Delete siblings (same height, normal text brightness) plus a tooltip. The Prompt Library's Copy chips keep `.plib-copy` deliberately - a quiet chip fits solo among prompt cards, and a test pins their count.

## Why and scope

The button had borrowed `.plib-copy` (the Prompt Library copy-chip style) when the Agent Library was built from that code - smaller and muted, reading as disabled until hover (director screenshot). Non-goals: no accent/primary coloring (uniform neutral row actions; blue stays reserved for the modal's one primary action).

## Verify

- `./run-tests.sh` -> PASS 1526/1526 (the `.plib-copy` count pin unaffected - agent rows no longer share the class).

## History

- 2026-07-10: created (by agent-library-button)

## Built with (provenance)

Direct fix by Claude (Fable) from the director's screenshot; too small for a workflow run.
