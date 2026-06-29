# Loops category in the Prompt Library (three loop-builder prompts)

Branch: main. Status: current.

## Why and scope

Loops are powerful but fail in predictable ways: an unmeasurable goal (no stop condition), reward hacking (gaming the metric), runaway iteration (no cap), regressions while chasing the target, and false-success/thrashing. A canned prompt that FORCES the user to supply what makes a loop converge - and bakes in the anti-failure rules - turns "write a loop prompt" from an expert skill into fill-the-blanks. Ships as a new curated "Loops" category in the Prompt Library (three variants so it is not a category of one).

The three are distinguished on the two axes that actually differ between loops - is success machine-measurable or judgment-based, and do you refine one solution or explore alternatives:

- **Converge to a Metric** - measurable + refine one (hill-climb to a target; the staple).
- **Best-of-N (explore, keep the best)** - measurable + explore many (when greedy refinement gets stuck).
- **Critique and Refine (no metric)** - judgment + refine one (adversarial critic gates completion; writing/design/plans).

Non-goals: a visual "Goal Loop" preset/node (heavier follow-on - maps MAX_ITERATIONS to a decision's maxRevisions and the measurement to the gate condition); multi-field input UI (the popup is single-field, so the objective is seeded via the popup and the rest are enforced by the prompt itself - see below); checklist-completion and fixpoint/until-stable archetypes (folded in as stop-condition notes inside Converge rather than separate entries, to keep the set crisp).

## Requirements

- R1 - A "Loops" category with exactly the three variants above. [test: "should have a Loops category with three distinct loop variants"]
- R2 - Each variant seeds its objective through the input popup (`input.find` = `[your objective]`), with the find token in the BODY (`Objective: [your objective]`) not the stripped preamble, so replacement targets it. [tests: "each Loops prompt seeds the objective..."; "Loops input replacement targets the body objective and strips the preamble (end-to-end)"]
- R3 - Each variant has a hard Step 0 completeness/quality gate ("Validate before looping ... STOP and ask") so the agent refuses to loop on a missing or unmeasurable goal - the forcing function the single-field UI cannot provide. [test: "each Loops prompt ... gates before looping"]
- R4 - Converge carries the metric-loop safeguards: a measurement command, the measurement/criterion is sacred (anti reward-hacking), a hard cap, a stall rule, and an honest MET/NOT MET exit. [test: "Converge loop carries the metric-loop safeguards..."]
- R5 - Additive only; no existing prompt or count test breaks (count assertions are `>=`; the copy-button-per-card test auto-scales). [verified: suite 1139 -> 1143]

## Approach and decisions

- Single-field input limitation: the Prompt Library input popup collects ONE value and does ONE find/replace (`confirmPlibInput`). So the objective is seeded via the popup, and the remaining fields live in a "REQUIRED - fill these in before running" block in the prompt body, enforced by Step 0. This is intentionally MORE robust than multi-field UI validation: the agent judges QUALITY (is the criterion actually measurable? is the quality bar concrete?), not mere presence, and refuses to loop otherwise. Multi-field input UI is a possible future enhancement, not needed here.
- Preamble token placement: the `> **Your input** ... > Example:` preamble must NOT contain the find token (`confirmPlibInput` replaces the FIRST occurrence, then strips the preamble). The token sits only in `Objective: [your objective]` in the body. An end-to-end test mirrors the replace-then-strip to lock this.
- Each variant has a genuinely different skeleton, fill-ins, and anti-failure rule (not copy-paste): Converge = baseline/hill-climb/metric-gate, sacred measurement; Best-of-N = generate-diverse/score/keep-best, candidates must be real alternatives + honest identical scoring; Critique-Refine = draft/adversarial-critique/revise, critic stays adversarial + bar is "no blocking issues" (not perfection, to avoid infinite nitpicking).
- Selection guidance lives in each `desc` ("Use when ...") so picking the right loop is instant - the variants are only valuable if the choice is obvious.
- Consistency with existing machinery: Critique-Refine is the single-prompt form of the shipped generic adversary/critic + review-loop; Best-of-N echoes the parallel + scoring patterns. All three reference the per-iteration log + durable record so re-runs do not repeat failed approaches.

## Surface area (file -> role)

- `index.html`: new `{ category: 'Loops', prompts: [...] }` in `PROMPT_LIBRARY` (3 entries, each with `input`/`desc`/`prompt`), inserted between Code Quality and Code Generation. No code changes - pure curated content consumed by the existing render/copy/input machinery (and `effectivePromptLib`).
- `tests.html`: 4 tests in the "new prompt categories" describe (category + variants, objective-seeding + Step 0 gate, Converge safeguards, end-to-end replace/strip).

## Task checklist

- [x] "Loops" category with Converge / Best-of-N / Critique-Refine
- [x] Each seeds objective via input popup; find token in body, not preamble
- [x] Step 0 completeness/quality gate in all three (STOP and ask)
- [x] Converge safeguards: measurement command, sacred metric, cap, stall, honest exit
- [x] Best-of-N: diversity axis + honest identical scoring + disqualify-on-invariant + auditable scoreboard
- [x] Critique-Refine: concrete quality bar + adversarial/independent critic + "no blocking issues" stop
- [x] Tests (4) incl. end-to-end replace/strip mirroring confirmPlibInput
- [x] This record + `_index` + `_timeline`

## Verify

`./run-tests.sh` -> 1143/1143 (was 1139; +4). The end-to-end test runs `confirmPlibInput`'s exact replace + preamble-strip regex against the real shipped prompt string and confirms the user's objective lands in the body and no `[your objective]` placeholder leaks. Count tests unaffected (all `>=`; copy-button-per-card auto-scales). Additive curated content only - no generator or core code touched.

## Spec quality check (finalize)

- [x] Every requirement is testable and has a verifying test
- [x] Scope bounded; non-goals stated (preset, multi-field UI, checklist/fixpoint folded in)
- [x] No open clarifications
- [x] Verify section records real results (1143/1143 + end-to-end replace/strip)
- [x] Additive only; no existing prompt or count test affected
- [x] Finalized for commit

## Outcome

The Prompt Library now has a "Loops" category with three fill-the-blanks loop builders that force a well-formed, safe loop: Converge to a Metric (measurable target), Best-of-N (explore and keep the best), and Critique and Refine (judgment-gated). Each seeds its objective through the input popup and enforces the rest via a hard Step 0 gate, with variant-specific anti-failure rules (sacred measurement / real-diversity + honest scoring / adversarial critic). Additive curated content; core untouched.

## Built with (provenance)

Authored directly from a late-night design conversation that mapped loop failure modes and the measurable-vs-judgment / refine-vs-explore taxonomy. Verified via the headless suite (1143/1143) including an end-to-end mirror of the input-popup replace/strip.
