# Make Ground-in-Prior-Records use the full three-tier lookup

Work item: enrich the grounding (read-side) guidance to use timeline + index + record. Branch: three-tier-grounding-read-side. Status: finalized (uncommitted, awaiting director review and commit).

Contents: [Why and scope](#why-and-scope) - [Requirements](#requirements) - [Success criteria](#success-criteria) - [Spec quality check](#spec-quality-check) - [Approach and decisions](#approach-and-decisions) - [Surface area](#surface-area-file---role-verified-by-implementer) - [Task checklist](#task-checklist) - [Gotchas](#gotchas--non-obvious) - [Verify](#verify) - [Outcome](#outcome) - [Built with](#built-with-provenance)

## Why and scope
The generated grounding guidance ("Ground in Prior Records" toggle) tells agents how to consult prior `.workflow/` durable records before planning. Today it only points agents at `_index.md` (the by-capability "what touches X" lens). A sibling `_timeline.md` (chronological, newest-first, written at finalize by the durable-record protocol) now exists on the WRITE side, but nothing on the READ side tells agents to use it. This change teaches the grounding guidance to use the full three-tier lookup: `_timeline.md` (when something changed) leads to `_index.md` (what touches X) leads to the durable record (full detail). It lives in the shared helper `consumeRecordsHint` and in the drifted inline Python-comment variant inside `genAgentSDK`, which must stay in parity.

Non-goals: changing how the timeline is WRITTEN (already exists in `genDurableRecordProtocol`); adding new toggles; touching unrelated grounding/MCP hints; making git mandatory.

## Requirements

- **R1 (MUST) The shared `consumeRecordsHint` names both lenses and the three-tier order.** When Ground in Prior Records is ON, the emitted hint MUST name `_index.md` for relevance ("what touches X") AND `_timeline.md` for recency ("what changed lately"), and MUST state the order timeline (when) -> index (what touches) -> record (detail).
  - Given consumeRecords ON, When `consumeRecordsHint()` is emitted, Then it contains `_index.md`, `_timeline.md`, and the three-tier ordering wording with timeline before index. (test: "hint names both lenses and states the three-tier order")
  - Given consumeRecords ON, When the four prose exporters assemble full output, Then each carries the timeline content and ordering, not just the banner. (test: "the three-tier timeline guidance reaches all four prose exporters full output")
  - Given consumeRecords ON, When the hint is read, Then the timeline read is framed as judgment-based ("when recency matters"), not a forced every-run step. (test: "frames the timeline read as judgment, not a forced every-run step")

- **R2 (MUST) The guidance is general (recency use cases), not bug-specific.** It MUST name several recency situations (regression, orienting/onboarding, resuming work), not only bugs.
  - Given consumeRecords ON, When the hint is emitted, Then it mentions multiple recency use cases beyond bugs. (test: "names several recency use cases (regression, onboarding, resuming)")

- **R3 (MUST) The genAgentSDK inline Python-comment variant has timeline parity.** The SDK comment variant MUST carry the same timeline-aware, three-tier guidance as the shared helper, consistent in meaning.
  - Given consumeRecords ON, When `genAgentSDK()` output is emitted, Then its consume-records comment names `_timeline.md` and `_index.md` and states the three-tier order. (tests: "SDK consume comment reaches three-tier parity" and the SDK banner emits-both-files test)

- **R4 (MUST) OFF means absent.** When Ground in Prior Records is OFF, no grounding guidance (and no new timeline wording) is emitted in any generator.
  - Given consumeRecords OFF (with durableRecord also OFF), When genWorkflow runs, Then the output contains neither the grounding banner nor `_timeline.md`. (test: the genWorkflow OFF-absence test)
  - Given consumeRecords OFF (with durableRecord also OFF), When genAgentSDK runs, Then its consume comment and `_timeline.md` are absent. (test: the SDK OFF-absence test)
  - Given consumeRecords OFF, When `consumeRecordsHint()` is called, Then it returns null. (test: "consumeRecordsHint is null when the toggle is off, present when on")

- **R5 (MUST) Hygiene.** New generated text MUST contain no em or en dashes, no triple-backtick fences in any hint string, stay provider-neutral, and not make git mandatory (mentioning git history is allowed).
  - Given the new hint text, When scanned, Then it has zero em/en dashes and stays provider-neutral with no literal `Durable Record`. (test: the consumeRecordsHint em/en-dash + provider-neutral test; SDK em/en-dash test)
  - Given the new hint text, When scanned, Then it has zero triple-backtick fences. (test: the no-triple-backtick-fence test)

- **R6 (MUST) Docs reflect the three-tier read.** README and TECHNICAL, where they describe Ground-in-Prior-Records / the durable-record index, MUST cover the three-tier lookup and the timeline read.
  - Given the docs, When the grounding/index sections are read, Then they describe the timeline (recency) tier and the three-tier order. (verified by Tester via direct source review; no automated test - docs are prose)

## Success criteria
- Every generator that emits grounding guidance (prompt/subagent/teams/claude + the SDK comment variant) names both `_index.md` and `_timeline.md` and the three-tier order when ON.
- With the toggle OFF, generated output is unchanged from before this change (no timeline wording leaks).
- The timeline read reads as judgment ("when recency matters"), so a reader does not treat it as a mandatory per-run step.
- `./run-tests.sh` is green and the suite grows with tests covering presence at all emitting generators, absence when OFF, SDK parity, the three-tier wording, and the dash/fence hygiene.

## Spec quality check
- [x] Each requirement is testable and unambiguous
- [x] Scope is bounded (Non-goals stated)
- [x] No open clarifications remain
- [x] Every scenario names a verifying test (R6 is doc prose, verified by source review)
- [x] Success criteria are measurable

## Approach and decisions
- Edit the single shared helper `consumeRecordsHint` so all four prose generators inherit the three-tier guidance from one place (mirrors how the helper is already shared). Keep the existing `_index.md` bullet; add the timeline (recency) framing and the explicit order.
- Mirror the same meaning into the genAgentSDK inline `#`-comment variant by hand, since it reimplements the guidance inline and has drifted (it is not wired to the shared helper).
- Keep timeline framed as judgment, not instruction, to honor "reference, not instructions" and avoid forcing a read every run.

## Surface area (file -> role) [verified by Implementer]
- index.html `consumeRecordsHint(fmt)` - shared read-side grounding helper, gated on `state.consumeRecords`. New `>`-prefixed timeline bullet inserted before the existing (unchanged) `_index.md` bullet; names both lenses + the three-tier order, judgment-framed.
- index.html genAgentSDK consume-records `#`-comment block (inside `if (state.consumeRecords)`) - body rewritten to semantic parity with the prose helper.
- tests.html - "Consume prior records (read side)" describe and "Export: genAgentSDK" describe; +6 new tests, 3 existing extended (SDK presence, genWorkflow OFF, SDK OFF).
- README.md - "Reading those records back is automatic" paragraph; +1 sentence on the timeline tier and three-tier order.
- TECHNICAL.md - the `consumeRecordsHint()` description in the durable-record paragraph; +1 clause on the judgment-gated timeline read.
- Out of scope (untouched): `genDurableRecordProtocol` / `genDurableRecordComment` timeline-WRITE prose (already correct); other MCP/grounding hints.

## Task checklist
- [x] Planner: produce implementation plan (exact edits, wording, test list)
- [x] Skeptic: review plan against requirements (gate) - PASS, no blocking defects
- [x] Implementer: enrich `consumeRecordsHint` with the timeline tier + three-tier order
- [x] Implementer: bring the genAgentSDK inline comment variant to parity
- [x] Implementer: update README grounding/index section
- [x] Implementer: update TECHNICAL grounding/index section
- [x] Implementer: add tests (presence all generators, OFF absence, SDK parity, three-tier wording, dash/fence hygiene) - +7 tests
- [x] Reviewer: code review (gate) - PASS, no critical issues, scope confined, independently re-ran suite green
- [x] Tester: ran ./run-tests.sh (1095/1095), mapped every acceptance criterion to a named non-vacuous test, added 1 test closing a prose-generator presence gap

## Gotchas / non-obvious
- `_timeline.md` is emitted by TWO independent code paths gated on DIFFERENT toggles: the read-side `consumeRecordsHint` (gated `state.consumeRecords`, this change) and the write-side `genDurableRecordProtocol` / `genDurableRecordComment` (gated `state.durableRecord`). An OFF-absence test for the new read-side wording must turn off `consumeRecords` AND `durableRecord` to assert `_timeline.md` is absent from full generator output - the genWorkflow OFF-absence test and the SDK OFF-absence test (the latter via `resetState`, which defaults `durableRecord` false) already do both. Add a `_timeline.md` absence assertion only in those fully-OFF halves, never in a half where `durableRecord` is ON (the write side legitimately emits it there).
- `consumeRecordsHint` deliberately uses lowercase "durable record", never the literal `Durable Record`, to avoid colliding with durable-record gating assertions. Keep the new wording lowercase.

## Verify
- Command: `./run-tests.sh`
- Result: PASS 1095/1095 (was 1087 before this change; +8 tests total - 7 from the Implementer, 1 from the Tester closing a prose-generator presence gap). Run independently three times (Implementer, Reviewer, Tester), all green, no regressions. Grep confirmed zero em/en dashes and zero triple-backtick fences in the new hint strings; literal `Durable Record` absent (lowercase only); provider-neutral; git not mandated.
- Independent review: the Skeptic passed the plan (no blocking defects, verified the `_timeline.md` toggle-gating that could have broken the OFF tests) and the Reviewer passed the diff (no critical issues, scope confined to the read side + docs + tests).

## Outcome
The read-side grounding guidance now uses the full three-tier lookup. `consumeRecordsHint` (the shared helper inherited by all four prose exporters: genWorkflow, genSubAgents, genAgentTeams, genClaudePrompt) gained one `>`-prefixed bullet, placed before the existing `_index.md` bullet, that names `.workflow/_timeline.md` (recency, newest-first) and `.workflow/_index.md` (relevance, "what touches X"), states the order timeline (when) -> index (what touches) -> record (detail), keeps `_index.md` as the default entry point, and frames the timeline scan as a judgment call "when recency matters" with three general use cases (regression, orienting/onboarding, resuming) rather than bugs only. The drifted genAgentSDK inline `#`-comment variant was rewritten to semantic parity. README and TECHNICAL gained matching prose. The change is gated entirely on `state.consumeRecords`, so OFF output is unchanged. The write side (`genDurableRecordProtocol` / `genDurableRecordComment`, which already author `_timeline.md`) was deliberately left untouched - this change only taught the reader to use what the writer already produces, closing the read/write asymmetry where `_timeline.md` was written but never consulted. Suite: 1095/1095 green (+8 tests); independently plan-reviewed (Skeptic) and diff-reviewed (Reviewer), no blocking defects.

## Built with (provenance)
Workflow: Make Ground-in-Prior-Records use the full three-tier lookup. Pipeline shape: Planner -> Skeptic (gate, revise->Planner, max 3 cycles) -> Implementer -> Reviewer (gate, revise->Implementer, max 3 cycles) -> Tester. All steps run as sub-agents on Opus 4.8 [1M]. Run context: workflow memory + durable record + ground-in-prior-records all on; grounded in prior `.workflow/` records (consume-prior-records, durable-record-protocol, agent-sdk-ground-in-prior-records-gap, and the timeline three-tier work in genDurableRecordProtocol). Single repo, single-file app (index.html) with a headless test suite (tests.html via run-tests.sh).
