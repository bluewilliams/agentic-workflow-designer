# Bespoke analysis prompts for the Auto Workflow measure/forecast branch

Branch: main. Status: current.

## Why and scope

The auto-builder's analysis branch (Data Gatherer -> Analyst -> Report Writer, for measure/forecast/cost/quantify stories) ran both agents on the generic codebase-research template, whose output contract ("recommended implementation approach") does not fit a measurement task at all. The Data Gatherer carried an interim Agent Context line licensing its Bash/WebFetch use because the shared template never mentioned them - the tool-selection-consistency record named a bespoke prompt as the proper fix. This is that fix.

## Key decisions

- **Two prompts, not one**: the chain has two genuinely different jobs. `PROMPTS.analysisGatherer` collects the numbers (repo metrics via Bash - wc/du/git-log style; usage surfaces via LSP; external reference data - pricing/benchmarks - via WebFetch under the conditional "available to you" phrasing); `PROMPTS.analysisSynthesizer` computes the answer (visible arithmetic with units, explicit justified assumptions, low/expected/high forecast ranges, an independent sanity anchor, per-number confidence).
- **Measured vs estimated is a first-class distinction** in both prompts - gathered values are tagged at collection and the tag propagates through every calculation into the findings. This is the single most common failure mode of agent-produced estimates.
- **Handoff contracts fit the work**: Gatherer ends with Data Inventory / Measured vs Estimated / Gaps / Collection Notes; Analyst ends with Findings / Methodology / Assumptions / Recommendation.
- **Interim Agent Context license RETIRED**: the Data Gatherer's notes line is empty again - Bash and WebFetch guidance now lives in the prompt proper, per the stated plan. Tools unchanged (Read/Grep/Glob/Bash/LSP/WebFetch; Analyst without WebFetch). Both prompts mention only tools their node carries (toolSubstitutionNote stays silent - test-pinned).
- agentType stays `researcher` for both (keeps the Datadog/code-search step-hint membership, which fits analysis work).

## Changes

- index.html: PROMPTS.analysisGatherer + PROMPTS.analysisSynthesizer (new "Analysis" section beside researcher); auto-builder analysis branch wired to them; Data Gatherer notes cleared.
- tests.html: analysis-intent test rewritten - both agents pinned to their bespoke prompts, tool licensing verified in-prompt, notes empty, substitution note silent for both.

## Verification

- 1246/1246 green (one test rewritten in place). Content-lint.

## Task checklist

- [x] analysisGatherer + analysisSynthesizer templates (measured-vs-estimated first-class; conditional web phrasing)
- [x] Auto-builder wiring + interim license line retired
- [x] Test repoint; suite green; content-lint
