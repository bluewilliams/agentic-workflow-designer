# Effort control: a per-step reasoning-depth lever

Workflow: none (director-directed change, built directly). Branch: main. Status: finalized, committable.

```awd:record
{"slug": "effort-control", "status": "current", "date": "2026-07-24", "files": ["index.html", "tests.html", "README.md", "TECHNICAL.md"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

Effort is a **node config field** (`config.effort`, `''` = inherit), set per step in Node Configuration directly under Model, with a sidebar **Default Effort** that an unset step inherits. The sidebar section keeps its "Default Model" heading; Default Effort sits inside it as a second default.

Effort deliberately does **not** bake at creation the way `model` does. Model must always be a concrete value; effort has a real unset state, since the runner has its own default. So `''` means inherit and `nodeEffort()` resolves it at read time. That keeps Default Effort meaningful after a preset loads, which is the common flow, and makes every node behave identically however it was created.

**A workflow where no step carries effort emits nothing at all** and is byte-identical to output from before this feature existed.

When a step carries a level, `effortStepNote(node)` emits a line beside that step's Model line, at the same five sites as its peer `modelContextNote`. `effortHint()` adds one workflow-level beat explaining the mechanism once (that Claude Code applies effort per session via `claude --effort <level>` rather than per Task call, and that the SDK export sets it per step), so the per-step lines stay terse. `genAgentSDK` emits a real per-agent `output_config={"effort": ...}`. Claude.ai emits nothing, matching its model skip.

The node picker offers only the levels that step's model accepts, via `modelEffortLevels`. `resolvedEffortFor` resolves **down only, never up**, and every difference is named: in the step's prose line, in a generated SDK comment, and in the Explain rows.

Persistence comes free from the existing seams: node effort rides `serializeWorkflow`/`deserializeWorkflow` (autosave, saved workflows, export/import), and Default Effort rides `savePrefs`/`restorePrefs`. `deserializeWorkflow` drops an unknown level exactly as it drops an unknown model.

## Why and scope

The designer had no lever for reasoning depth, so every run inherited a default nobody chose. Effort is the more precise cost and quality control than swapping a step to a weaker model, and since `Task()` carries no effort parameter it is the only such lever the emitted prompts can reach for at all.

Verified before building rather than assumed: `claude --effort <level>` exists and takes exactly `low, medium, high, xhigh, max`.

It shipped first as a workflow-level setting, on the reasoning that a session flag cannot be honored per step. The director corrected that, and was right: `modelContextNote` is already a per-node line that says the Task tool cannot carry `[1m]` and ships as honest intent anyway. The objection proved too much, since it would have killed that note too. Effort is the same shape, and the SDK format executes it per agent for real. It moved to node config, which is also where every other per-step knob lives (`model`, `tools`, `maxTurns`, `prompt`, `notes`) - keeping it in `state` alone was the one-off.

Non-goals: no change to any emission when no step carries effort; no hiding of the control on models that do not support the parameter; no effort field on the Agent Library form yet (custom agents normalize to inherit, so they are safe, and the form is a separate surface).

## Requirements

1. Unset MUST emit nothing, in every format. (Tests: effortHint is null and no format mentions effort when unset; plus the byte-identity proof below)
2. Set MUST ride as intent in the three prose formats and stay out of Claude.ai. (Test: rides in the three prose formats and stays out of Claude.ai)
3. The SDK MUST emit a real, model-legal parameter. (Tests: SDK emits a real output_config for a supporting model; SDK skips the parameter for Haiku and says why; SDK lowers xhigh to high for Sonnet 4.6 and names the substitution)
4. Resolution MUST go down only, and every difference MUST be visible. (Tests: resolves an unsupported level DOWN, never up; the prose note calls out steps whose model cannot take the level; says nothing about odd models when every step supports the level)
5. The preference MUST round-trip and reject a bogus stored level. (Tests: round-trips through savePrefs and restorePrefs; a stored blob with no effort key leaves it unset, and a bogus stored level is ignored)
6. Explain MUST name the lever in user language in both states, at BOTH levels. (Tests: names its lever in user language whether set or unset; the sdk single-row summary mentions effort only when set; Explain Step carries an Effort row that reflects THIS step's model; the step Effort row carries no probe; the sdk step summary names what this step will actually emit)

## Approach and decisions

- **One inheritance semantic, not two.** The first cut baked the default in `addNode` behind the `!(config && config.model)` guard. Presets pass `model` explicitly, so they skipped the bake and stayed on inherit, while a blank node pinned - two identical-looking steps that diverged the moment Default Effort changed. Caught by driving preset, duplicate, and blank-node creation side by side. Resolved toward inherit-at-read rather than bake-everywhere: it is the smaller change, it keeps the sidebar control useful for preset-built workflows (most of them), and the panel already reads "Inherit (Max)" so nothing is hidden.
- **Per-node, through the existing seams, not a new mechanism.** The field is `config.effort` beside `config.model`; the control is the shared `configSelect` helper; the emission is `effortStepNote`, a peer of `modelContextNote`, pushed at the same five sites; the default bakes at `addNode` like `model` does. That choice is what makes persistence free rather than something to build: node effort is already inside the serialized workflow, and Default Effort is already inside prefs. Verified by driving a real page reload, not by reading the code.
- **The picker is filtered, not the control hidden.** A step on Haiku still shows an Effort row offering Inherit only, so the user learns the model takes none instead of watching a control vanish (the July discovery ruling).
- **Unset emits nothing** is the regression contract, proven rather than asserted: a full generator snapshot was captured before any edit (17 presets x 5 formats + 3 toggle combinations, 101 blocks, 6,757,893 characters) and re-captured after, normalizing only the randomly generated workflow name. Identical both times, including after a late Explain change.
- **Control always visible**, per the July discovery ruling on App Under Test and UI Context: summon-to-unlock is backwards, and a visible control that reads "Haiku 4.5 does not accept the effort parameter" teaches where a vanished one leaves the user guessing. Haiku is handled at emission, not by hiding the lever.
- **Never silently substitute.** A model that cannot take the configured level gets the difference named, in the prose list and in a generated SDK comment. This is the same principle as the roster change landed the same day, where a superseded model could no longer emit a shorthand that resolved to its successor.
- **Sidebar section keeps its "Default Model" heading** at the director's call: Default Effort is a bonus inside it, not a co-headline. It adds no visual weight at rest since that section ships collapsed.
- **Explain Step gets its own row**, added after the director asked whether the lever surfaces there. Effort is configured once for the run, but whether a given step honors it depends on that step's model, so the node row states what THIS step actually runs at: applies / lowered to the level its model supports / skipped because its model takes none. Its probe is deliberately empty, because the effort text is emitted at the workflow level and a probe would claim the step's own block contains it. The sdk step summary gained the same node-specific clause.
- Explain: the `sdk` format returns a single hand-built row and never reaches the row list, so a `format === 'sdk'` branch drafted into the Effort row's reason string was unreachable. Removed, and the SDK's own summary row gained a conditional effort clause instead. Caught by probing the rendered Explain output for all four formats rather than by reading the code.

## Success criteria

- An unset workflow is byte-identical to pre-feature output.
- A set workflow carries honest, actionable effort intent in the formats that are actually used, and a valid parameter in the one that executes it.

## Spec quality check

- [x] Each requirement testable and unambiguous
- [x] Scope bounded (Non-goals stated)
- [x] No open clarifications remain (the harness affordance was verified, not assumed)
- [x] Every scenario names a verifying test
- [x] Success criteria measurable

## Task checklist

- [x] Verify the Claude Code affordance and level vocabulary before designing
- [x] Capture a pre-change generator baseline for the byte-identity proof
- [x] Core helpers: EFFORT_LEVELS, modelEffortLevels, resolvedEffortFor, effortHint
- [x] Per-step emission at the five modelContextNote sites + one workflow-level beat
- [x] SDK real parameter with model-aware resolution and visible comments
- [x] Node config field + shared configSelect control; sidebar Default Effort; prefs and serialization inherited from the existing seams
- [x] Explain row plus the SDK summary clause, at workflow AND step level
- [x] 27 tests
- [x] Byte-identity re-proved after the final Explain edit
- [x] Screenshots of both the sidebar section and the node config panel
- [x] Persistence verified across a real page reload (default + per-node override + emitted line)
- [x] Dead helper removed (modelSupportsEffort was defined and never called)
- [x] Close pass over preset / duplicate / Agent Library / undo / OpenSpec paths
- [x] Inheritance semantics unified after that pass found two of them
- [x] OpenSpec forwards effort as intent beside Model
- [x] README + TECHNICAL updated
- [x] Finalize: record, index entry, timeline line

## Verify

- `./run-tests.sh` -> PASS 1559/1559 (1532 baseline, +27).
- **Byte-identity proof**: full generator snapshot across 17 presets x 5 formats + 3 toggle combinations, before the feature and after, normalizing only the per-load random workflow name. 101 blocks, 6,757,893 characters, zero differences. Re-proved four times: after the first build, after the Explain change, after the per-node refactor, and after the inheritance fix.
- **Close-pass audit**: preset-built, duplicated, and blank nodes compared side by side under a changing Default Effort; config panel checked against the value each step actually runs at; OpenSpec export inspected.
- **Persistence proof**: a real page reload in a headless session. Default Effort medium and a per-step override of max both survived, an unset step still resolved to the default, the emitted step line came back, and the sidebar trigger read Medium.
- Headless ON-path drive: support matrix per roster entry, `resolvedEffortFor` across supporting/partial/unsupporting models, the rendered prose beat, presence in exactly the three prose formats, the SDK's three emission shapes (real parameter / lowered with comment / skipped with comment), and a return to silence on unset.
- Explain probed for all four row-list formats in both states, workflow-level and per-step, across a supporting / capped / unsupporting model.
- Content lint on changed files -> exit 1; no em dashes in the diff.

## History

- 2026-07-24: created (by effort-control)

## Current state / next action

Finalized and green; uncommitted for the director, alongside the same-day `model-roster` unit.

## Outcome

The designer has a per-step reasoning-depth lever it never had, sitting under Model where the other per-step knobs live, expressed honestly per format and surfaced in both Explain and Explain Step, with zero effect until someone opts in. 27 tests, a byte-identity proof that the default path is untouched, and persistence inherited rather than built.

## Gotchas / non-obvious

- `explainWorkflow('sdk')` returns early with one hand-built row. Any new row added to the main list is invisible to that format, and a `format === 'sdk'` branch inside such a row is dead code.
- Generator snapshots are not directly comparable across loads: an unnamed workflow gets a fresh random name each time, and it appears both hyphenated in prose and underscored in the SDK's Python function name. Normalize both forms or the diff is pure noise.
- `--effort` is a session flag, not a per-spawn parameter. That constrains how the note is worded, but it does not mean per-step effort is wrong to express - `modelContextNote` set that precedent.
- `autoSaveWorkflow` is debounced 1000ms. A persistence probe that reloads sooner than that tests nothing and looks like a data-loss bug.
- The `addNode` default-baking guard is `!(config && config.model)`, which presets do not satisfy because they pass `model` explicitly. Any new "bake a workspace default into the node" idea will silently skip every preset-built node. This is why effort resolves at read instead.
- `deserializeWorkflow` takes `c.nodes` verbatim, so any new config field needs its own validation line there. A test with a deliberately junk value caught this; without it a foreign blob's bogus level would have reached an emitted prompt.

## Built with (provenance)

Built directly by Claude (Opus 5) at the director's request, no generated workflow. Memory and durable records on. Directed by a conversation that started as a model-roster question and arrived here.

## Links

- Grounds on / touches: `.workflow/model-roster.md` (same-day sibling; effort is the lever that change's reasoning pointed at, and both enforce the never-silently-substitute rule), `.workflow/dogfood-run-fixes.md` (A1, which established that `Task()` carries no effort parameter), `.workflow/context-agent-types.md` (the discovery ruling behind keeping the control visible).
- Branch: main (uncommitted for the director).
