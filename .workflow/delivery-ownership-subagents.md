# Delivery ownership in the sub-agent format (one PR, not one per agent)

Branch: main. Status: current.

```awd:record
{"slug": "delivery-ownership-subagents", "status": "current", "date": "2026-07-01", "files": ["index.html", "tests.html"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

In the sub-agent format, delivery (branch, push, PR) is orchestrator-owned and emitted once in genSubAgents' tail. Each agent prompt carries deliveryAgentNote() instead: pr/commit outputs get a branch-discipline note (never push or open the PR yourself), report/docs get nothing, and no-output workflows keep the per-agent noCommitBlock. The other four formats emit delivery at the orchestrator level as before.

## Why and scope

In the sub-agent format, `buildAgentPrompt` injected the full imperative delivery block (`deliveryBlock('##')` - branch checkout, `git push`, `gh pr create` / Bitbucket API steps) into EVERY spawned agent's prompt. A literal mid-workflow Planner, Researcher, or Reviewer was licensed - instructed, even - to push the branch and open the PR before downstream steps ran, and several agents could each open one. The other four formats already emit delivery once at the orchestrator level; the sub-agent format was the outlier.

## Key decisions

- **Delivery is orchestrator-owned, emitted once**: genSubAgents now emits `deliveryBlock('##')` in its orchestrator tail (after Decision Routing, before the task section), matching the other formats' architecture.
- **Per-agent prompts get `deliveryAgentNote()` instead**: for `pr`/`commit` outputs, a short Delivery Discipline section - work on the feature branch, do NOT commit/push to the target branch, do NOT push the feature branch or open a PR yourself, delivery runs once at the end. For `report`/`docs` outputs the per-agent note is empty (the final artifact is the orchestrator's synthesis concern, and repeating it per-agent invited every agent to write "the" report). With no output node, agents keep the existing `noCommitBlock` text verbatim (it is already the safe per-agent variant).
- **No change to genWorkflow / Agent Teams / SDK / Claude.ai formats**: their deliveryBlock call sites were verified orchestrator-level already.

## Changes

- index.html: new `deliveryAgentNote(level)` beside `deliveryBlock`; buildAgentPrompt swaps `deliveryBlock('##')` -> `deliveryAgentNote('##')`; genSubAgents orchestrator tail gains the single `deliveryBlock('##')` emission.
- tests.html: PR workflow emits `gh pr create` exactly once with two per-agent Delivery Discipline sections and the no-push sentence; no-output workflow still carries the per-agent no-commit discipline.

## Verification

- 1213 -> 1215 (+2), full suite green (no existing test pinned the per-agent block - confirmed by running the suite after the swap, before adding new tests). Content-lint grep clean.

## Task checklist

- [x] deliveryAgentNote() per-agent variant (pr/commit discipline, report/docs empty, no-output noCommit passthrough)
- [x] buildAgentPrompt swap + orchestrator-tail single deliveryBlock emission
- [x] Verify other four formats already orchestrator-level (no change)
- [x] Tests: single gh pr create, per-agent discipline present, no-output discipline retained; suite green; content-lint
