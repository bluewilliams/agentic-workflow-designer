# OpenSpec export: cross-tool grounding (read side)

Branch: main. Status: current. Implements backlog #9 (lighter option).

## Why and scope

The flywheel has four grounding directions (run type x record format):

| Run type | Reads our `.workflow/` records | Reads OpenSpec docs |
|---|---|---|
| Our prompt-run workflow | yes (consumeRecordsHint) | no (future) |
| OpenSpec run | **this change** | yes (native, via requires) |

Before this, the OpenSpec export wired in none of the memory/record protocols, so an OpenSpec run could not benefit from the `.workflow/` records our prompt-run workflows leave behind - the read-side flywheel stopped at the tool boundary. This makes the bottom-left cell work: when "Ground in prior records" is on, the exported schema tells the OpenSpec run to consult our durable-record index before it works. The records become a shared substrate across both run types, not a per-tool silo.

Non-goals: the *write* side (an OpenSpec run does NOT produce our `.workflow/{slug}.md` flywheel doc - that fights OpenSpec's generate-once-per-doc model; see openspec-export-durable-record-toast.md). The top-right cell (our prompt-run grounding reading OpenSpec docs) is deliberately NOT solved by teaching the read-side a second format - the chosen direction is "converge on one index": have OpenSpec runs append a breadcrumb to `.workflow/_index.md` so our existing grounding picks them up unchanged. That is a separate, bigger follow-on (new backlog item), not this change.

## Requirements

- R1 - When "Ground in prior records" is ON, the exported schema's FIRST artifact instruction tells the run to scan `.workflow/_index.md` (and `.workflow/_timeline.md`) before working, open only matched records, and carry their decisions/gotchas/surface-area in. [test: "grounding rides on the FIRST artifact only when the toggle is on"]
- R2 - Grounding rides on the first artifact only (the entry step); downstream steps inherit through `requires`, not by repeating the block. [test: same - asserts the implementer block does NOT contain it]
- R3 - When the toggle is OFF, no grounding text appears anywhere in the schema. [test: "no grounding text in the schema when the toggle is off"]
- R4 - Self-gating on greenfield: the prose ends with "if no index exists or nothing matches, proceed normally" so it is a no-op when there is nothing to ground in. [test: "openSpecGroundingBlock ... points at the index when on" asserts the proceed-normally clause]
- R5 - Additive + removable; core untouched; round-trip unaffected (re-import reads the awd:meta JSON, not the instruction text). [verified: helper lives in the removable OpenSpec block; existing 26 OpenSpec tests incl. round-trip stayed green]

## Approach and decisions

- New pure helper `openSpecGroundingBlock()` next to `openSpecContextBlock()` (same "ride designer state into instructions" family). Returns a COMPACT distillation of the read-side prose (`consumeRecordsHint`) - not the full six-bullet version, which would bloat the schema - gated on `state.consumeRecords` (returns '' when off).
- Injected at the first artifact only in `buildOpenSpecSchema`: `const grounding = openSpecGroundingBlock();` then for `i === 0`, prepend it to that artifact's instruction. This mirrors our prose model ("the orchestrator grounds once before the work begins") and OpenSpec's reality (the entry artifact runs first; its generated doc, carrying any grounding-informed decisions, flows downstream via requires).
- Why first-artifact-only, not every artifact or the apply block: grounding is a one-time pre-work read; repeating it per step is noise and schema bloat. The apply block is the final implementation, after grounding has already happened.
- Why the LIGHTER option (preamble on an existing artifact) over the heavier one (a dedicated `grounding` artifact + requires edge): faithful, half the surface, and it does not touch the DAG, so OpenSpec's validation surface is unchanged.
- Default-on consequence (accepted): `consumeRecords` defaults to true, so default exports now include the grounding preamble on the first artifact. This is the intended behavior and is runtime-self-gating (harmless on greenfield). It is the one way this is not byte-identical-by-default; all existing tests still passed.

## Surface area (file -> role)

- `index.html` REMOVABLE OpenSpec block: new pure `openSpecGroundingBlock()`; `buildOpenSpecSchema` computes it once and prepends it to the first artifact's instruction (gated, `i === 0`).
- `index.html` help modal "OpenSpec export": reworked the record-toggle note into a two-bullet read-side-flows-in / write-side-does-not split.
- `tests.html`: 3 tests in the "OpenSpec schema export" describe + `openSpecGroundingBlock` bridged to `win`.

## Task checklist

- [x] Pure helper `openSpecGroundingBlock()` (compact, gated on `state.consumeRecords`)
- [x] Prepend to the FIRST artifact's instruction in `buildOpenSpecSchema` (i === 0)
- [x] Help-modal read-side/write-side split bullets
- [x] Bridge `openSpecGroundingBlock` to `win` in tests.html
- [x] Tests (3): helper on/off, first-artifact-only, off-means-absent
- [x] Verify existing 26 OpenSpec tests (incl. round-trip) still pass with default-on grounding
- [x] This record + backlog #9 marked done + `_index` + `_timeline` entries

## Verify

`./run-tests.sh` -> 1139/1139 (was 1134; +5 across this work). The default-on change broke none of the existing OpenSpec assertions (all `toContain`, additive-safe). YAML rendering: `openSpecYamlBlock` emits a literal block scalar (`|`) padding every line to 6 spaces under the 4-space `instruction:` key, so the multi-line grounding (with backticks/colons) is literal text needing no escaping - the new `artBlock(planner)` test confirms the text lands in the entry artifact and not the downstream one.

CLI-VALIDATED (2026-06-28): headlessly generated a real export with grounding ON (planner -> backend -> skeptic, PR output) and ran `openspec schema validate` against it: "✓ Schema 'rate-limit-flow-schema' is valid" (exit 0). Confirmed in the rendered schema.yaml that the grounding bullets sit cleanly under `instruction: |` (correct indentation, prompt + execution params + record line follow), and that the grounding appears on the FIRST artifact only (grep count = 1 across all artifacts). So the free-text grounding does not break `openspec schema validate` 1.4.1.

## Spec quality check (finalize)

- [x] Every requirement is testable and has a verifying test
- [x] Scope bounded; non-goals stated (write side excluded; polyglot reader rejected in favor of converge-on-one-index)
- [x] No open clarifications
- [x] Verify section records real results (1137/1137 + the YAML-rendering reasoning)
- [x] Additive + removable; core untouched; round-trip unaffected
- [x] Finalized for commit

## Outcome

An OpenSpec schema exported with "Ground in prior records" on now instructs the run to read our `.workflow/_index.md`/`_timeline.md` before working, so OpenSpec runs inherit the context our prompt-run workflows captured. Compact gated preamble on the entry artifact, three tests, core untouched. Closes the read-side cross-tool direction (backlog #9). The reverse close - OpenSpec runs writing breadcrumbs back into our index so our workflows benefit from OpenSpec durable docs - is the next, separate follow-on.

## Update (2026-06-28): DRY consolidation of the read-side protocol

Follow-up in the same session: the 3-tier lookup prose existed in two near-duplicate copies (the prompt read-side `consumeRecordsHint` and the OpenSpec `openSpecGroundingBlock`, which started as a hand-written distillation). Consolidated to a single source of truth.

- New `groundingLookupSteps()` returns the canonical three-tier steps (`tiers` / `scanIndex` / `noTransitive` / `supersede` / `greenfield`) as plain, framing-free strings.
- `consumeRecordsHint` now composes from it: orchestrator lead + every step rendered with the `> - ` blockquote. The step strings are VERBATIM copies of the originals in the same order, so the prompt output is byte-identical (hard constraint: no behavior change in the prompt generators). Confirmed - all existing `consumeRecordsHint`/`genWorkflow` tests stayed green.
- `openSpecGroundingBlock` now renders the SAME source as plain instruction bullets, using the read-relevant subset (`tiers`, `scanIndex`, `greenfield`) - skips the write-side `supersede` step and the multi-repo `siblings` step, since an OpenSpec run reads to inform its work, it does not maintain our index. Its text shifted to the fuller canonical wording (allowed: "worded a little differently for the openspec export path is fine"), which also makes the OpenSpec instructions MORE faithful to the full three-tier lookup than the prior distillation.
- THIRD copy folded in too (`genAgentSDK`): the SDK's hand-wrapped `#`-comment grounding banner now renders the shared steps via a new `wrapComment(text, width)` helper (word-wraps to <=79 cols, backticks stripped for plain comments). Rationale (decided with Blue): align the SDK now, before it is exercised, so the upcoming SDK rework has fewer divergent copies to reconcile. Bonus parity: the SDK's old bespoke copy was MISSING the supersede + siblings steps; it now carries the full set like the prompt side. Verified safe by the 4 existing SDK grounding tests (presence, timeline-before-index order, gating, non-markdown) plus a new parity test.
- Net result: ONE source of truth (`groundingLookupSteps`) feeds all three consumers - prompt outputs (`> -` blockquote, full set), SDK (`#` comments via wrapComment, full set), OpenSpec (plain bullets, read subset). `groundingLookupSteps` and `wrapComment` live in core (not the removable OpenSpec block), so removing the OpenSpec block leaves the prompt + SDK paths intact.
- +3 tests total this consolidation: the DRY-linkage test (prompt vs OpenSpec share the steps, framing differs, OpenSpec uses the subset); the SDK parity test (supersede + siblings now present, backticks stripped); plus hardening two existing SDK phrase-assertions to an unwrapped view so word-wrap cannot split a checked phrase. Suite: 1139/1139.

## Spec quality check - DRY consolidation (finalize)

- [x] Prompt outputs byte-identical (verified by source diff: same strings, same `> - ` prefix, same order; existing tests green)
- [x] OpenSpec text reuses the shared source (DRY); framing/subset differences are intentional and tested
- [x] SDK folded onto the shared source via wrapComment; gains supersede+siblings parity; 4 existing + 1 new test green
- [x] groundingLookupSteps + wrapComment in core; removing the OpenSpec block does not break prompt/SDK grounding
- [x] +3 tests pin the reuse, the per-format framing, and the SDK parity; suite 1139/1139
- [x] Finalized for commit

## Built with (provenance)

Authored directly across a design conversation that mapped the four grounding directions and chose "one shared index, no polyglot reader," then consolidated the read-side protocol to a single source feeding all three consumers (prompt, SDK, OpenSpec). Verified via the headless test suite (1139/1139), a source-level diff confirming the prompt output is byte-identical, and a standalone check of the SDK comment wrapping (all lines <=78 cols, no broken tokens).
