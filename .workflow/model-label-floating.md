# Floating model labels (unnumbered = newest of family)

Context: no work item (direct session, director-requested after Fable 5.1 shipped and made the "Fable 5" label stale). Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- Model labels follow one rule: an UNNUMBERED label (Fable, Opus, Sonnet, Haiku, plus their [1M] variants) marks the newest model of its family - exactly the entries that emit the floating base alias via `taskModelMap` - so the label stays true when a successor ships. A NUMBERED label (Opus 4.8, Sonnet 4.6) marks a deliberately pinned legacy model that emits its full API id.
- `value` keys and `id` strings are untouched (they live in saved workflows, localStorage, and run reports); only display labels changed. The shipped default trigger reads "Opus".
- A naming-rule test enforces the invariant mechanically: for every MODELS entry, floating (getTaskModelParam differs from getModelId) exactly when the label carries no version digit (the [1M] context tag is not a version number).
- README and TECHNICAL state the convention beside the model lists.

## Why and scope

Fable 5.1 released; the "Fable 5" label lied while the emitted `fable` alias correctly floated to 5.1. The display layer now matches the emission semantics the base-alias design already had, ending the rename-on-every-release treadmill. Scope: MODELS labels, the trigger div, label assertions across the suite, one invariant test, README/TECHNICAL copy. Non-goals: no value/id renames, no new model entries (floating means 5.1 needs none).

## Verify

- `./run-tests.sh`: 1707 -> 1708, all passing (label assertions migrated; the naming-rule invariant added)

## History

- 2026-08-26: created - six labels unnumbered, trigger updated, assertions migrated (incl. the Explain resolved-model line and the effort-unsupported prose), naming-rule invariant test, docs convention notes. 1707 -> 1708 (by direct session)
