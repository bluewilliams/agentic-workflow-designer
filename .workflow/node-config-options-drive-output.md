# Make node config options drive the generated prompt

Branch: local working tree. Status: current. The giant copy-to-clipboard prompt is the product, so every node type's config must actually land in it.

## Why and scope

An audit found three node config controls were inert: Parallel `strategy`, Input `source`, and Task `acceptance`. A control that renders a choice but ignores it is misleading. The deeper finding: the **entire Task node** was dropped by all five generators (they iterate `agents = ordered.filter(type==='agent')`), so a Task node's description and acceptance contributed nothing. Made all three functional with a hard rule: each option's default is byte-identical to prior output; new behavior fires only on a non-default value.

Non-goals: emitting Parallel `description` or Input `description` (their content is already carried globally; emitting would duplicate it and break byte-identical). Auto Workflow scoring changes (tracked separately - the read-only-over-inference gap).

## Requirements

- **Parallel Strategy drives join semantics in all 5 generators.** GIVEN a fork, WHEN strategy is `all` THEN output is byte-identical to before (`genWorkflow` prints `(all)`, SDK uses `asyncio.gather`); WHEN `any` THEN proceed-on-first prose + SDK `asyncio.wait(FIRST_COMPLETED)`; WHEN `race` THEN first-useful-result prose + SDK `FIRST_COMPLETED` with `_t.cancel()` on pending. Verified by `Node config: Parallel Strategy join semantics`.
- **Task nodes reach the prompt.** GIVEN a Task node with description (+ optional acceptance), WHEN any generator runs THEN a Tasks section lists the label, description, and `Done when: {acceptance}` (omitted when acceptance empty). GIVEN no Task nodes THEN no Tasks section (baseline byte-identical). Verified by `Node config: Task nodes reach the prompt`.
- **Empty Task nodes contribute nothing.** GIVEN a Task with no description, no acceptance, and the default label, WHEN any generator runs THEN it is omitted from the Tasks section (the node stays on the canvas - connections/topology preserved - it just injects no silent content). A deliberate (non-default) label counts as intent and IS emitted. Verified by the empty-task / renamed-empty-task tests. `taskHasContent(t)` gates both helpers.
- **Input Source frames the input softly.** GIVEN source `story` or `prd`, WHEN generating THEN a one-line framing hint appears; GIVEN `jira` or `custom` THEN no hint (the story box + `requirementsBlock` URL handling already carry requirements, so the default never assumes a wrong fetch). Verified by `Node config: Input Source framing`.
- **Settings round-trip.** GIVEN strategy/source/acceptance set, WHEN serialize -> deserialize THEN all three survive. Verified by `Node config: round-trips through serialize/deserialize`.

## Success criteria

- Picking a non-default value visibly changes the relevant generator output; the default does not.
- Full suite green, 1052 -> 1064 (12 new tests).

## Approach and decisions

- **Helpers** (before `genWorkflow`): `strategyJoinPhrase(strategy)`, `forkStrategyOf(forkId)`, `taskSectionLines(ordered, marker)`, `taskSectionComments(ordered)` (SDK comment form), `inputSourceHint()`.
- **Strategy**: edited the 5 existing parallel-emission sites; `all` (and legacy-undefined) take the unchanged branch. Chose to keep `(all)` literal rather than improve the wording, because changing it would break byte-identical for every existing preset.
- **Task**: chose an additive "Tasks" section over inlining tasks into the agent step-loop. Rejected inlining because the loops index on the `agents` array with parallel-sibling math; mixing tasks in risked the working agent emission. The section is empty when no task nodes exist, so it is byte-identical for all presets/Auto Workflow (none create Task nodes). Task labels already appear in `genWorkflow`'s Execution Flow line; the section adds the missing description+acceptance.
- **Source**: injected `inputSourceHint()` into the shared `requirementsBlock` (covers genWorkflow/genAgentTeams/genClaudePrompt + genSubAgents per-agent) and into the genAgentSDK requirements block. Only `story`/`prd` emit; `jira`/`custom` return `''`. No preset uses `story`/`prd`, so zero regression.

## Surface area (file -> role)

- `index.html`: 5 new helpers; 5 strategy sites (one per generator); 5 task-emission sites; 2 source-hint sites (`requirementsBlock`, genAgentSDK). No serialization change needed (config already deep-cloned by `serializeWorkflow`).
- `tests.html`: 4 new describe blocks, 12 it() tests.
- Out of scope: Auto Workflow scoring; Parallel/Input `description` emission.

## Task checklist

- [x] Strategy join semantics across 5 generators (all = byte-identical)
- [x] Task node emission across 5 generators (Tasks section + Done when)
- [x] Input Source framing for story/prd (jira/custom silent)
- [x] Tests: non-default fires, default byte-identical, round-trip (12 tests)
- [x] README + TECHNICAL updated

## Verify

`./run-tests.sh` -> `PASS: 1075/1075` (post-guard + SDK source-hint consistency + empty-task gating; node-config portion was 1064). Headless probe confirmed all five generators emit the Tasks section, the `Done when:` acceptance, race join semantics, and the PRD hint on a workflow built with a Task node, a `race` fork, and a `prd` input source.

## Gotchas / non-obvious

- An empty Task is omitted from the Tasks SECTION, but `genWorkflow`'s Execution Flow line still lists its label (the flow trace mirrors every canvas node - transparent topology, not injected instructions; intentionally left as-is for canvas/flow consistency).
- - `genWorkflow`'s parallel line prints `(all)` today (not `wait for all`) because `config.strategy` defaults to the truthy `'all'`; byte-identical means keeping `(all)`.
- `win.state` is unreadable from a raw iframe probe (functions close over it internally); pass a literal model string instead of `w.state.defaultModel`.
- The Input source hint must be suppressed for URL-only AND empty stories. The markdown generators get this free (requirementsBlock's URL-only branch returns before the hint, and it returns `[]` for empty story), but genAgentSDK added the hint unconditionally - gated it on `story && !isUrlOnly(story)` so all five generators agree (caught by the pre-commit deep pass).

## Outcome

All three previously-inert node options now drive the generated prompt, with defaults byte-identical and new behavior gated to non-default values. The real fix was the Task node, which had been dropped wholesale, not just its acceptance field.

## Built with (provenance)

Authored directly (not via a generated workflow). Notably, the candidate sub-agent workflow produced by Auto Workflow for this very task was discarded: it had no implementer step (the task's acceptance-criteria-heavy prose misclassified it as a test-authoring task), which surfaced the separate Auto Workflow read-only-over-inference gap.
