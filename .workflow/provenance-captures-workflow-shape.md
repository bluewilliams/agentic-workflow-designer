# Built-with provenance captures the workflow shape + notable config

Work item: Blue's question - should the durable record include the workflow spec (agents + important config)? Status: complete, uncommitted (Blue commits). Tests: 698/698.

## Why and scope

The durable record's "Built with (provenance)" line already captured the workflow name, the agent roles as an ordered roster, and what grounded them - but not the agents' config or the workflow's topology. Enrich it so the provenance answers "what agents and anything important about their config" for an auditor or a future agent re-driving the work, while staying compact (the verbatim pipeline already lives in the exported workflow JSON / Handoff bundle).

Non-goals: NOT a full config or prompt dump in the committed record (that is what the exported `.json` is for); no new record section (enriched the existing Built-with item, not a separate "Pipeline" section); no change to what the Handoff bundle carries.

## Requirements

R1. genDurableRecordProtocol's Built-with item MUST instruct capturing the pipeline SHAPE (ordered roles + topology: decision gates and revision caps, parallel forks, review loops [Skeptic/Verifier] incl. attach points and where failures route). (test: provenance shape)

R2. It MUST instruct capturing notable NON-DEFAULT config (models differing from default / extended context, significant tool grants e.g. a Verifier's Bash+browser, unusual turn limits) and the RUN CONTEXT (toggles/integrations: memory, durable record, ground-in-records, clarify, MCPs, repo context paths). (test: provenance shape)

R3. It MUST cap the note to "the shape and the knobs that matter, not a full config or prompt dump", pointing to the exported workflow definition for the verbatim pipeline. (test: provenance shape)

R4. It MUST preserve the existing protected phrases (workflow name, "the agent roles it ran", "what grounded them", "how this was built", "NOT the minute-to-minute step progress", "removed on commit", the provider-neutral "a code-search index over the repo" example). (tests: existing v2.1 provenance + provider-neutral)

## Approach and decisions

- Enriched the single Built-with `p.push(...)` string in genDurableRecordProtocol (index.html ~2771). Kept every test-pinned phrase; wove in the shape/config/context guidance + the not-a-dump cap. Chose to enrich Built-with over adding a "Pipeline" section (Blue's preference + avoids a new section bloating small records).
- Rationale for capping it: the full verbatim definition is already captured by the Handoff bundle's serialized workflow (re-importable). The record is about the WORK; provenance is the compact "how it was built" pointer, now informative enough for audit/re-drive/eval without duplicating the .json.

## Surface area (file -> role)

- index.html ~2771: the Built-with provenance bullet in genDurableRecordProtocol (enriched prose; no logic change).
- tests.html: +1 test "provenance captures the workflow shape + notable config, not a full dump"; existing v2.1 provenance + provider-neutral tests still pass (protected phrases preserved).

## Task checklist

- [x] Enrich the Built-with provenance guidance (shape + topology + non-default config + run context + not-a-dump cap)
- [x] Preserve protected phrases (existing tests green)
- [x] Add a test for the new content
- [x] Run ./run-tests.sh - 698/698

## Verify

Command: ./run-tests.sh -> 698/698 pass. Prose-only change to a generated prompt (no logic); skipped the sub-agent review (test coverage + preserved-phrase guards are the right bar here).

## Outcome

The generated durable-record protocol now tells agents to record the workflow SHAPE (roles + decision gates/caps + parallel forks + Skeptic/Verifier review loops incl. reroute targets), the notable non-default config (models, key tool grants, turn limits), and the run context (toggles/MCPs/repo-context), capped to shape-and-knobs (the exported `.json`/Handoff carry the verbatim pipeline). Answers "include the workflow spec in the durable doc" - yes, as compact informative provenance, not a dump.

## Built with (provenance)

Workflow: direct implementation by the orchestrator (a focused prompt-content enrichment to genDurableRecordProtocol + one test), no sub-agent review (prose-only, no logic). Part of the durable-record-protocol capability.

## Links

Branch: TBD. PR: TBD.
