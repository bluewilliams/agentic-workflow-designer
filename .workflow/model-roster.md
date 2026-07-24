# Model roster: Opus 5 added, superseded families retired, shorthand rule made safe

Workflow: none (director-directed change, built directly). Branch: main. Status: finalized, committable.

```awd:record
{"slug": "model-roster", "status": "current", "date": "2026-07-24", "files": ["index.html", "tests.html", "README.md", "TECHNICAL.md"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

The MODELS array offers eleven entries: Fable 5, Opus 5, Opus 4.8, Sonnet 5, Sonnet 4.6 (each with a `[1M]` variant) and Haiku 4.5. Opus 5 (`claude-opus-5`, family `opus-5`) is the default at every default site: the shipped `defaultModelTrigger` label, `NODE_DEFAULTS`, `state.defaultModel`, and both `state.defaultModel || ...` fallbacks.

`taskModelMap` holds only the newest model in each family, so Fable 5, Opus 5, Sonnet 5, and Haiku 4.5 emit the short aliases `fable` / `opus` / `sonnet` / `haiku`, and every superseded model falls through `getTaskModelParam` to its full API id (`claude-opus-4-8`, `claude-sonnet-4-6`). The SDK format is unaffected: it reads `getModelId` and has always emitted the full id.

`modelContextNote` derives its base from the same `getTaskModelParam`, so a `[1M]` variant on a superseded model reads `/model claude-opus-4-8[1m]` while a current one reads `/model opus[1m]`. Its middle clause now says the Task parameter "does not accept the `[1m]` suffix" rather than "accepts only base model names", which was only true while every mapped value was a short alias.

Retired from the roster: Opus 4.7 and Opus 4.6 (with their `[1M]` variants), and the dated 4.5 pair that occupied the bare `opus` / `sonnet` values.

Loading a workflow whose agent node names a model no longer in MODELS snaps that node to `state.defaultModel`, alongside the existing output-node migration in `deserializeWorkflow`. `configSelect` renders an unrecognized value as itself rather than borrowing the first option's label.

## Why and scope

Opus 5 shipped and should be selectable and default. The four older families were carrying no weight.

The load-bearing part is not the roster edit, it is `taskModelMap`. It maps a selector value to the Task tool's `model` parameter, and a short alias resolves to whatever is newest in that family. Leaving Opus 4.8 mapped to `opus` after Opus 5 arrived would mean a step deliberately pinned to 4.8 silently runs on 5, with nothing in the emitted prompt showing the substitution. The same defect already existed unshipped for Sonnet 4.6, which had kept `sonnet` after Sonnet 5 took it, so it is fixed here rather than left as a known-wrong second instance.

Non-goals: no attempt to keep the retired models selectable or to preserve a stored preference naming one (director ruling, this change and standing). Making a *loaded node* land on a valid model is in scope and not that waiver - see the Approach note; the distinction is between carrying retired models forward and emitting an invalid parameter. Also out of scope: any change to the `-1m` suffix machinery, the SDK id path, or Haiku 4.5.

## Requirements

1. Opus 5 and Opus 5 [1M] MUST appear in every picker and be the shipped default. (Tests: offers Opus 5 and Opus 5 [1M] in the default-model dropdown; ships defaulted to Opus 5)
2. The retired families MUST be gone from the roster and every picker. (Test: retires the superseded model families from every picker)
3. Only the newest model in a family MUST hold the shorthand; superseded models MUST emit their full id. (Tests: only the newest model in each family holds the shorthand alias; should use full ID for Opus 4.8 / for Sonnet 4.6, each asserting the shorthand is absent from a document where every step is on the superseded model)
4. The 1M note MUST agree with the emitted param for both shorthand and pinned bases. (Test: A1: modelContextNote and getTaskModelParam agree on the base alias, extended with the pinned cases)
5. A stored default naming a retired model MUST be ignored rather than applied. (Test: a stored default naming a retired model is ignored, not applied)
6. A workflow saved on a retired model MUST NOT emit its stored value as the Task param, and the config panel MUST NOT show a model the node is not holding. (Tests: a workflow saved on a retired model loads onto the default instead of emitting an invalid param; the config panel never shows a model the node is not holding)
7. Pin migrations: eight existing assertions carried the old shorthand contract and were migrated to the sharper one, never weakened.

## Approach and decisions

- Three data edits (MODELS rows, `taskModelMap` keys, four default sites) plus one prose fix in `modelContextNote`. Every emitter, picker, and Explain row reads the shared helpers and needed no touch, confirmed by driving the built app headlessly and reading the real emissions from all five generators.
- The `opus` and `sonnet` MODELS values were the dated 4.5 entries, not shorthand entries, so retiring them frees nothing and collides with nothing. Opus 5 uses the versioned `opus-5` value like every other current family.
- The absence assertions in requirement 3 set **every** node to the superseded model. Scoping them to one node in a workflow whose other steps sit on the default would have made the check vacuous, since the default legitimately emits `model="opus"`. The first draft did exactly that and failed, which is the assertion doing its job.
- No compat shim for the *default-model preference*, per the director. The existing `MODELS.find(...)` guard in `restorePrefs` already prevents the visible failure (a stored `opus-4.6` is dropped rather than becoming a phantom selection); requirement 5 pins that guard so the no-shim decision rests on tested behavior rather than assumption.
- The node-level guard is a different question and was added deliberately after a headless probe. A node holding a retired value emitted `model="opus-4.6"` verbatim, because `getModelId` also falls through to the raw value - not a stale-but-valid id, but a string no harness resolves - while `configSelect` showed `MODELS[0]` ("Fable 5") for that same node. That is an invalid emission plus a UI that contradicts it, which is a correctness defect rather than the compat the director waived (carrying retired models forward). Fixed at the two seams: a migration in `deserializeWorkflow` next to the existing output-node one, and `configSelect` no longer borrowing a label it does not hold. The configSelect half is general - it protects every config dropdown from the same class of drift, not just Model.
- Deliberately left alone: the two "tolerates an older awd_prefs blob" tests still seed `defaultModel: 'opus-4.6'`. That value is now genuinely retired, which makes those tests strictly better at what they already claimed to test.

## Success criteria

- Opus 5 is selectable and default; all five formats emit a valid, correct model reference for every roster entry.
- No superseded model emits a family shorthand in any format.

## Spec quality check

- [x] Each requirement testable and unambiguous
- [x] Scope bounded (Non-goals stated)
- [x] No open clarifications remain
- [x] Every scenario names a verifying test
- [x] Success criteria measurable

## Task checklist

- [x] Ground in the existing roster machinery (sonnet-5-models, dogfood-run-fixes)
- [x] MODELS rows: add Opus 5 pair, retire the four superseded families
- [x] taskModelMap: Opus 5 takes the shorthand, Opus 4.8 and Sonnet 4.6 fall through to full ids
- [x] Four default sites plus the shipped trigger label
- [x] modelContextNote clause corrected for pinned bases
- [x] Test migrations (8 assertions) plus new roster, retirement, and stored-default guards
- [x] Fixture sweep: 110 retired-model fixtures moved to the current default
- [x] README + TECHNICAL updated, including a stale SDK example naming a retired id
- [x] Full suite green via ./run-tests.sh
- [x] Real emissions verified by execution across all five generators
- [x] Retired-value load path probed headlessly before and after the guard
- [x] Finalize: record, index entry, timeline line

## Verify

- `./run-tests.sh` -> PASS 1532/1532 (1528 baseline; +7 new guards, -3 tests covering retired models).
- Headless drive of the built app: roster table (value / label / Task param / SDK id) plus the model lines from genSubAgents, genWorkflow, genAgentTeams, and genAgentSDK on a four-step workflow spanning Opus 5, Opus 4.8, Opus 5 [1M], and Sonnet 4.6 [1M]. Confirmed the shorthand appears only for current models, the full id for superseded ones, the SDK full id throughout, and the 1M note base matching the emitted param in both cases. Second probe on the retired-value path: a two-node workflow imported with `opus-4.6` and `sonnet-4.6` loads with the retired node on the default and the supported one untouched, the panel agrees with the node, all five formats emit valid references, and the raw retired string appears nowhere in any output. Third check: an arbitrary unknown value renders as itself in the panel.
- Content lint on the changed files -> exit 1; no em dashes in the diff.

## History

- 2026-07-24: created (by model-roster)

## Current state / next action

Finalized and green; uncommitted for the director.

## Outcome

Opus 5 is the default and selectable everywhere; four superseded families are gone; a superseded model can no longer emit a shorthand that resolves to its successor; and a workflow saved on a retired model can no longer emit an invalid param behind a config panel showing something else. Three data edits, one prose fix, two guards, one exposure line, 7 net new tests.

## Gotchas / non-obvious

- `MODELS` is a `const`, so the roster-level test needed a line in the tests.html exposure block. Function declarations reach the iframe on their own; const bindings do not.
- The bespoke harness has no `toNotBe` matcher. Compare and assert on the boolean instead.
- `getModelId` and `getModelLabel` both fall through to the raw value for an unknown model, so retiring a model turns every stored reference to it into an invalid emission rather than a visibly broken one. Removing a model from MODELS is never only a data edit; check the load path.
- The 1M note legitimately contains a literal `/model <base>[1m]`, so absence assertions must use the param form `model="<base>[1m]"`, never the bare string. Same lesson as sonnet-5-models and dogfood-run-fixes; it now applies to full-id bases too.

## Built with (provenance)

Built directly by Claude (Opus 5) at the director's request, no generated workflow. Memory and durable records on.

## Links

- Grounds on / touches: `.workflow/sonnet-5-models.md` (the roster and 1M machinery this extends; its stated behavior is unchanged, so it was not amended) and `.workflow/dogfood-run-fixes.md` (A1, which established valid Task model params and `modelContextNote`). This record now owns the roster and the newest-holds-the-shorthand rule for future model changes.
- Branch: main (uncommitted for the director).
