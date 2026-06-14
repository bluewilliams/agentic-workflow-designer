# Refresh the in-app Help modal to match the current feature set

Context: bring the in-app Help (the `?` button) up to date with features shipped since it was last written. Branch: main. Status: in progress.

## Why and scope
The in-app Help modal in `index.html` (the `.help-body` div) has drifted: it documents an older feature surface and still uses retired terminology ("Shared Memory"), while the flagship additions (Durable Record, the orchestrator, grounding, the clarify gate, Agent Prompt editing, input-aware Generate) are absent or wrong. README.md and TECHNICAL.md are current and are the source of truth for wording. This is a documentation-accuracy task only.

Non-goals: no change to application behavior, generated-prompt logic, or any feature. Help content only, plus test assertions if a heading changes. Not expanding to document every setting (e.g. Rules/Product-docs paths) - only the six topics below.

## Requirements
- R1 The Help MUST document the Durable Record and the orchestrator. Given a user opens Help, When they read it, Then it explains the committable `.workflow/{slug}.md` record + `.workflow/_index.md` breadcrumb index, that the orchestrator owns the record (creates at kickoff, folds in step findings, finalizes/compresses for commit), and the supersession lineage. Mirror README.md. Verifying test: tests.html help-sections assertion (extended).
- R2 The Help MUST document "Ground in prior records" as the read side (scan committed `.workflow` records, inherit decisions/gotchas/surface area; no-op on greenfield). Mirror README.md + `consumeRecordsHint`.
- R3 The Help MUST document "Clarify requirements first" as an in-flow clarification gate distinct from the Refine Prompt flow; graceful in non-interactive runs. Mirror README.md + `clarifyFirstHint`.
- R4 The Help MUST NOT reference "Shared Memory"; it MUST describe the real toggles "Enable workflow memory" (ephemeral, `~/.claude`, uncommitted) and "Keep a durable record" (committable). Fix the Power User Tips bullet and any other occurrence.
- R5 The Help MUST document Agent Prompt editing: clicking a node exposes an editable agent-prompt template with a Default / Edited-from / Custom status, and Custom Notes are appended (not a replacement). Mirror `agent-prompt-edit-ux.md` + `agentPromptStatusBlock`.
- R6 The Help MUST document input-aware Generate: disabled until enough prose to pick a workflow; bare Jira key / URL-only prompts a preset pick; Refine and Plan available once requirements are entered. Mirror `validateStoryInput`.
- R7 The five test-asserted headings MUST remain present (Quick Start, Refine Prompt Flow, Plan Prompt Flow, Power User Tips, Export Formats). Given the suite runs, When the help-sections test executes, Then it passes. If headings are added/renamed, the test MUST be updated to assert the new sections too.
- R8 The full suite MUST stay green (baseline 518/518). No company-specific names; hyphens not em dashes; match existing Help HTML style.

## Success criteria
- Every one of the six topics is described in the Help and is accurate against the actual code in index.html (not invented).
- `./run-tests.sh` passes at >= 518 tests; the help-sections test covers the new sections.
- A reader who only opens Help understands the Durable Record, grounding, the clarify gate, the two memory toggles, Agent Prompt editing, and Generate's input rules.
- README and Help are consistent on the six topics.

## Spec quality check
- [x] Each requirement is testable and unambiguous
- [x] Scope is bounded (Non-goals stated)
- [x] No open clarifications remain (requirements authored and clear)
- [x] Every behavior change names a verifying test (help-sections test)
- [x] Success criteria are measurable

## Approach and decisions
- Source of truth is README.md/TECHNICAL.md and the live code (the named hint functions), NOT assumption. Chose mirror-the-README over write-fresh because the README descriptions are already vetted and consistent, which minimizes drift.
- Documentation-only; no behavior touched, so blast radius is the help-body HTML plus the one help-sections test assertion.

## Surface area (file -> role) - provisional until the Writer grounds
- `index.html` (`.help-body` div, ~lines 811-899) - the Help content to update; PRIMARY.
- `tests.html` (Usability & Help -> "should contain key help sections", ~line 3531) - extend assertions if headings change.
- `README.md` - source of truth + consistency cross-check (prefer its wording; edit only to align).
- Reference-only (accurate-wording sources, do not modify): `consumeRecordsHint`, `clarifyFirstHint`, `genDurableRecordProtocol`, `agentPromptStatusBlock`/`validateStoryInput` in index.html, and prior records `agent-prompt-edit-ux.md`, `compress-durable-record-at-finalize.md`.

## Task checklist
- [x] Planner: confirm the exact help-body region, the stale spots, and the test assertion to extend
- [x] Researcher: pull accurate wording from README + the named hint functions + matched prior records
- [x] Doc Writer: update the Help sections (R1-R6), fix terminology (R4), keep the five headings (R7), extend the test, run the suite
- [x] Doc Reviewer: verify each claim against the code; confirm minimality and no behavior change
- [x] Orchestrator: finalize record, update `.workflow/_index.md`, confirm tests green

## Verify
- `./run-tests.sh` -> 518/518 pass, before and after the change (the four new heading checks are `toContain` assertions inside the existing "should contain key help sections" case, so the case count holds at 518 while coverage expands). Grep confirms zero remaining "Shared Memory" references. `git diff --stat`: index.html +27/-1 (all inside `.help-body`), tests.html +4 (inside the one help-sections test) - no JS, CSS, or generated-prompt logic touched.

## Outcome
Refreshed the in-app Help modal to match the current feature set. Added four `<h3>` sections - Editing Agent Prompts, Durable Record, Ground in Prior Records, Clarify Requirements First - and folded an accurate input-aware-Generate note into Quick Start. Fixed the stale "Shared Memory" bullet in Power User Tips to name the real toggles ("Enable workflow memory" / "Keep a durable record"). Extended the tests.html help-sections assertion to guard the four new headings by exact string. The five originally-asserted headings remain. Accuracy guard held on the Generate section (Refine gates only on empty; Plan self-guards via toasts, not the validator's 6-word threshold). Surface area: `index.html` (`.help-body` only) and `tests.html` (one test). README/TECHNICAL were already current and were the wording source; no README change needed.

## Built with (provenance)
Workflow: `Documentation updates` (Documentation preset). Agent roles: Planner -> Researcher -> Doc Writer -> Doc Reviewer, orchestrated in one session. Grounded by the `.workflow/_index.md` scan-then-open index over this repo. Baseline suite 518/518 green at kickoff.

## Links
- Work item: none (local task). Branch: main. PR: pending.
