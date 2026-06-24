# Write a design overview of the durable-record system

Work item: none (documentation task). Branch: main. Status: finalized (uncommitted, awaiting director review and commit).

## Why and scope
Document the EXISTING durable-record system in this repo for a new maintainer, as a design overview. The system has several recently-added parts that no single doc explains end to end: a per-record durable record under `.workflow/`, a capability-grouped `_index.md` breadcrumb, a chronological `_timeline.md`, the three-tier lookup that ties them together, and the generated write-side protocol (`genDurableRecordProtocol`) that tells an orchestrator how to author and maintain them, including a finalize completion gate. A new maintainer currently has to reverse-engineer the "why" from prior committed records and the code in `index.html`. Produce a clear design overview as a new section in TECHNICAL.md (or a short `docs/` file if cleaner).

Non-goals: changing any code or behavior of the durable-record system; inventing rationale not recorded in the prior records; duplicating the existing terse reference subsection (TECHNICAL.md "Durable Record (committable artifact)") verbatim - the overview complements it. No commit/push/PR.

## Requirements
- **R1 (MUST) Explain the parts and how they relate.** The overview MUST describe the durable record, `_index.md` (relevance/capability lens), `_timeline.md` (recency/chronological lens), the three-tier lookup (timeline -> index -> record), and the write-side protocol including the finalize completion gate, and how each relates to the others.
  - Given a new maintainer reads the section, When they finish, Then they can name all four parts and state the three-tier order and what each tier answers. (verified by Skeptic review against the code + records)
- **R2 (MUST) Capture key decisions and rationale, including rejected alternatives.** The overview MUST record the "why" for the recent changes (why a separate `_timeline.md`, why the finalize completion gate, why three-tier grounding, and the transcribe-vs-re-derive and finalize-compression decisions), grounded in the prior committed records, with the rejected alternative where a real fork existed.
  - Given a decision in the overview, When checked against the source record, Then its rationale matches a recorded rationale (not invented). (verified by Skeptic)
- **R3 (MUST) Accuracy against current behavior.** Every claim MUST match the actual current behavior - the code in `index.html` (`genDurableRecordProtocol`, `consumeRecordsHint`, the completion gate) and the committed records. Where a decision's reasoning is not recorded, describe current behavior rather than guessing why.
  - Given any factual claim, When traced to `index.html` or a record, Then it is true of the current code/records. (verified by Skeptic line-by-line)
- **R4 (MUST) Follow existing doc conventions.** The section MUST match TECHNICAL.md format/structure, use hyphens not em/en dashes, and update in place (new section) rather than fragmenting across files.
  - Given the rendered doc, When scanned, Then it matches surrounding heading style and has no em/en dashes. (verified by Skeptic)

## Success criteria
- A new maintainer can read the overview alone and understand the four parts, the three-tier lookup, and the write/finalize protocol without reading the source first.
- Every decision stated has a rationale traceable to a committed record; no invented "why".
- The doc lands in TECHNICAL.md (or a short docs/ file) following existing conventions, uncommitted for director review.

## Spec quality check
- [x] Each requirement is testable (by review against source) and unambiguous
- [x] Scope is bounded (Non-goals stated)
- [x] No open clarifications remain
- [x] Every scenario names a verifying check (the Step 4 Skeptic accuracy review against index.html + records is the verifier for R1-R4; it returned PASS)
- [x] Success criteria are measurable

## Approach and decisions
- Pipeline: Planner -> Researcher -> Doc Writer -> Skeptic (gate, revise -> Doc Writer, max 3 cycles), each as a sub-agent on Opus 4.8 [1M]. Documentation deliverable, left uncommitted.
- Orchestrator grounded up front in the prior records (consume-prior-records, durable-record-protocol, durable-record-cadence capabilities) and the live code, and folds that into each step's brief so steps inherit it.
- Placement (Planner, verified): a new subsection in TECHNICAL.md under "## Memory Protocol", placed immediately after the existing "Durable Record (committable artifact)" reference subsection. Chosen over a sibling under "## Technical Decisions & Rationale" (that section is a one-line-per-row table, wrong shape for narrative) and over a separate docs/ file (R4 keeps it in TECHNICAL.md). The new overview complements the existing terse wiring reference (parts + relationships + why), not duplicates it.
- Note: `.workflow/_timeline.md` currently holds only one dated entry (the timeline was introduced 2026-06-23); the overview describes the mechanism, not a long history.

## Surface area (file -> role) [verified by Doc Writer]
- TECHNICAL.md - new subsection "### Durable Record System: Design Overview" under "## Memory Protocol", placed immediately after the existing "### Durable Record (committable artifact)" reference subsection. Four `####` parts (the record, `_index.md`, `_timeline.md`, the protocol), a "How the parts relate" three-tier-lookup part, and a "Design decisions and rationale" part (6 decisions). +27 lines; only TECHNICAL.md changed.
- index.html `genDurableRecordProtocol(fmt)` - the write-side protocol, including the finalize "Completion gate - finalize is not done until ALL of these are true" item; `consumeRecordsHint(fmt)` - the read-side three-tier grounding; the Durable Record Index prose (`_index.md` + `_timeline.md` definitions). Reference only (no code change).
- `.workflow/_index.md`, `.workflow/_timeline.md` - the live breadcrumbs the overview describes (reference only).
- Source records grounding the rationale: `make-ground-in-prior-records-use-the-full-three-tier-lookup.md` (three-tier read), `compress-durable-record-at-finalize.md` (finalize compression), `durable-record-per-step-cadence.md` (enforced cadence/finalize), `durable-record-transcribe-handoff.md` (transcribe vs re-derive), `delivery-section-enhancement.md` Part B (FINALIZE restructure).

## Task checklist
- [x] Planner: produced the doc outline (4-part structure + how-they-relate + 6-decision rationale list), placement recommendation, and the C1-C10 source-verify list
- [x] Researcher: source-verified claims C1-C10 against index.html + live breadcrumbs (all confirmed, zero corrections); confirmed all 6 decision rationales are recorded in their cited records (incl. code-verifying D4's two-generator claim)
- [x] Doc Writer: wrote the "### Durable Record System: Design Overview" subsection in TECHNICAL.md (4 parts + how-they-relate three-tier + 6 decisions with rejected alternatives), uncommitted; +27 lines, only TECHNICAL.md changed, no em/en dashes added
- [x] Skeptic: reviewed for accuracy, completeness, clarity (read-only gate) - VERDICT PASS, no blocking issues; one Medium wording note (item-(f) attribution) applied by the orchestrator
- [x] Orchestrator: applied the Skeptic's wording fix, finalized the record (index + timeline entries), stripped scaffolding

## Verify
- No automated test (documentation). Verification was the Step 4 Skeptic's adversarial accuracy review against index.html (`genDurableRecordProtocol`, `consumeRecordsHint`, completion gate item (g), call sites, toggle defaults) and the cited records, plus a convention/dash scan. Result: VERDICT PASS, no blocking issues; all 14 accuracy claims and all 6 decision rationales traced to source, all four parts + the three-tier relation + the 6 decisions present, no em/en dashes added, `git diff --stat` = TECHNICAL.md only. One Medium non-blocking note (the protocol paragraph attributed strip/compress to FINALIZE items (a)-(f) when only item (f) does it) was applied by the orchestrator at finalize.
- `git diff --stat` confirms only TECHNICAL.md changed.

## Outcome
Added a new subsection "### Durable Record System: Design Overview" to TECHNICAL.md under "## Memory Protocol", immediately after the existing terse "### Durable Record (committable artifact)" wiring reference, which it complements (parts + relationships + why, not a restatement of the wiring). The subsection has four `####` parts - the durable record (`.workflow/{slug}.md`: orchestrator-owns, amend-by-action, fan-out writes to ephemeral memory to avoid races), `_index.md` (the relevance lens, kebab-case capability slugs, grep-by-relevance scan-then-open, written at finalize as a projection), `_timeline.md` (the recency lens, `# Timeline` newest-first, kept out of the index on purpose, mechanism-not-history), and the protocol (`genDurableRecordProtocol` write-side gated on `durableRecord` default OFF across the four prose exporters + the SDK `genDurableRecordComment`; the enforced `### KEEP CURRENT` per-step transcribe beat and `### FINALIZE`; read-side `consumeRecordsHint` gated on `consumeRecords` default ON) - then a "How the parts relate" part covering the three-tier lookup (timeline when -> index what-touches -> record detail; index is the default entry, timeline read judgment-gated on recency; both breadcrumbs are projections, record is the single source of truth), and a "Design decisions and rationale" part with all six decisions as decision -> rationale -> rejected alternative, using only recorded rationale. Pipeline: Planner (outline + placement) -> Researcher (source-verified all claims, zero corrections) -> Doc Writer (wrote the section) -> Skeptic (PASS). Documentation only; +27 lines in TECHNICAL.md, no code touched, left uncommitted for director review.

## Built with (provenance)
Workflow: "Write a design overview of the durable-record system". Pipeline shape: Planner -> Researcher -> Doc Writer -> Skeptic (gate, revise -> Doc Writer, max 3 cycles). All steps run as sub-agents on Opus 4.8 [1M]. Run context: workflow memory + durable record + ground-in-prior-records on; grounded in prior `.workflow/` records. Single repo, single-file app (`index.html`) with docs in TECHNICAL.md / README.md.

## Links
- Work item: none
- Branch: main
- PR: TBD
