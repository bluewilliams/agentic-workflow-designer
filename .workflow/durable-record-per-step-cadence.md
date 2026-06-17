# Durable record per-step cadence (enforced KEEP CURRENT)

Work: make the generated durable-record protocol force a per-step update cadence, not just a finalize. Branch: main. Status: complete, uncommitted (awaiting director commit).

## Why and scope

A real run (the SDK consume-records workflow) exposed that the orchestrator deferred all durable-record writing to finalize, so the record did not exist mid-run. The protocol did say "keep it current" and "fold each step's findings in as they report back", but only as passive prose buried in a maintenance list - there was no discrete, enforced per-step beat, while FINALIZE was explicit and enforced. The result: the resume-from-interruption property the record exists for was not actually delivered, which matters most on large multi-step workflows.

This change adds an enforced per-step cadence and sharpens the kickoff timing, so the protocol communicates create -> update-every-step -> finalize as one enforced spine.

Non-goals: spec-kit-style granular task IDs / parallel markers / dependency phases (deferred to a dedicated pass, to be tuned against a real large task so the dynamic scaling does not bloat small records); changing the SDK durable-record handling.

## Requirements

- R1: The protocol MUST state an enforced per-step update beat, symmetric with FINALIZE.
  - Given genDurableRecordProtocol output, Then it contains a "KEEP CURRENT (the orchestrator runs this after EVERY step, before spawning the next - enforced)" section that says to overwrite Current state / next action, tick the checklist, and fold the step's output by action, and to not batch all writing to the end. (test: v2.2 has an enforced per-step KEEP CURRENT cadence and a before-Step-1 kickoff)
  - Given the toggle on, When the four prose generators run, Then each contains the KEEP CURRENT cadence. (test: v2.2 the per-step cadence reaches the four prose generators when durableRecord is on)

- R2: The kickoff timing MUST be explicit (before the first step).
  - Given the protocol, Then it says "Create it at kickoff, before you spawn Step 1". (test: v2.2 ... before-Step-1 kickoff)

## Success criteria

- An orchestrator following the generated prompt updates the record after each step, so an interrupted large run can be resumed from the Current state / next action line alone.
- The change is text-only inside the existing protocol block: no new injection sites, no behavior change when durableRecord is off.

## Spec quality check

- [x] Each requirement is testable and unambiguous.
- [x] Scope bounded (Non-goals stated: spec-kit granularity deferred, SDK unchanged).
- [x] No open clarifications.
- [x] Every scenario names a verifying test.
- [x] Success criteria measurable.

## Approach and decisions

- Added the cadence as a discrete, enforced "### KEEP CURRENT" section right before "### FINALIZE", mirroring FINALIZE's enforced framing - chosen over merely re-wording the existing "keep it current" bullet because the real failure was the lack of a discrete, enforced per-step trigger (a passive property is easy to defer; an enforced beat is not).
- Kept it inside genDurableRecordProtocol (emitted at the existing four prose-generator call sites) rather than adding a new early directive helper with its own injection sites - lowest-risk additive shape, no new surface, and the director explicitly wanted to avoid breakage. Surfacing a short early pointer remains an optional future add.
- Included a parallel-fan-out rule (fold once at the join, not from each concurrent agent) to keep the cadence consistent with the existing write-race guidance.

## Surface area (file -> role)

- index.html genDurableRecordProtocol: new "### KEEP CURRENT ... - enforced" section (5 lines) before FINALIZE; sharpened the kickoff bullet to "Create it at kickoff, before you spawn Step 1". Nothing else changed; emitted only when durableRecord is on, at the four prose generators.
- tests.html "Durable Record: protocol content" describe: +2 tests (the enforced cadence + before-Step-1 kickoff is present; the cadence reaches the four prose generators).

## Task checklist

- [x] Sharpen kickoff timing to before-Step-1.
- [x] Add the enforced KEEP CURRENT per-step section before FINALIZE.
- [x] Add the 2 protocol-content tests.
- [x] Run ./run-tests.sh, all green.

## Verify

- Command: `./run-tests.sh`.
- Result: 647/647 passed. Baseline before this change was 645; +2; no regressions.

## Outcome

The generated durable-record protocol now forces an enforced per-step KEEP CURRENT beat (overwrite Current state / next action, tick checklist, fold the step's output by action, do not batch to the end) and an explicit before-Step-1 kickoff, giving a create -> update-every-step -> finalize spine. Text-only, additive, gated on durableRecord. Closes the resume-from-interruption gap a real run exposed. Spec-kit-style granular task breakdown was deliberately deferred to a dedicated pass.

## Built with (provenance)

Produced directly (no sub-agent fan-out) right after a workflow run surfaced the gap: diagnose the missing per-step trigger, add the enforced section + kickoff sharpening, add tests.
