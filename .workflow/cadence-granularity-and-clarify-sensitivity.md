# Prompt hardening from a real cold run (cadence granularity + clarify sensitivity)

Work: two safe, additive prompt-text tunings driven by a real cold-run's findings. Branch: main. Status: complete, uncommitted (awaiting director commit).

## Why and scope

A real cold run surfaced two prompt weaknesses (not code bugs): (1) the durable record's Task checklist stayed all-unchecked until finalize because one Implementer finished many items and the orchestrator batched the ticks; (2) the clarify gate, though on, silently resolved a real null/below-threshold fork instead of asking. Both are fixed by sharpening generated-prompt text only - no executable behavior changes, so the regression surface is just "does the generated text still contain what the tests assert."

Non-goals: the heavier structural cadence options (interleaving a record-update beat into the Execution Plan, or per-step sub-agent handoff reporting) - left parked unless this lighter sharpening proves insufficient on the next run; making clarify always-ask (kept a low-stakes escape so it does not get spammy).

## Requirements

- R1: The KEEP CURRENT cadence MUST require ticking EACH checklist item a step completed, including when one step finishes several at once, and not batching ticks to finalize.
  - Given genDurableRecordProtocol output, Then the KEEP CURRENT beat says to tick each completed item from the step's handoff, explicitly covers one step completing several items, says tick them now (not at finalize), and states an interrupted run must show which items are done vs remain. (test: v2.3 ticks EACH checklist item per step)

- R2: The clarify gate MUST lean toward asking on genuine high-value forks (null/empty/missing/below-threshold semantics, conflicting behavior, contract/schema shape) while keeping a low-stakes / convention escape so it does not question everything.
  - Given clarifyFirstHint when on, Then it says to lean toward asking on those high-value forks, names the null/below-threshold (included vs excluded vs error) case, and qualifies that self-resolving is only for low-stakes or convention-clear choices (a sensitivity floor, not a mandate to question everything). (test: leans toward asking on high-value forks but keeps a low-stakes escape)

## Approach and decisions

- Cadence: sharpened the existing enforced KEEP CURRENT bullet rather than restructuring execution - the run showed the orchestrator HAD the handoffs (Files Changed was itemized) but did not transcribe them to the checklist, so the targeted fix is to make per-item ticking from the handoff an explicit, enforced instruction, including the one-step-many-items case. Chose this lighter sharpening over the structural options (execution-plan interleave / sub-agent reporting) to stay additive and low-risk; the structural options remain the next lever if this is not enough.
- Clarify: added a "lean toward asking on high-value forks" bullet biased at the exact category it missed (null/below-threshold), with an explicit low-stakes/convention escape and a "sensitivity floor, not a mandate to question everything" qualifier, so it asks when it matters without becoming noisy. Did not touch the non-interactive fallback or the proceed-if-clear bullet.

## Surface area (file -> role)

- index.html genDurableRecordProtocol: the KEEP CURRENT "Tick the Task checklist items" bullet rewritten to require per-item ticking from the handoff, the one-step-many-items case, tick-now-not-at-finalize, and the interrupted-run requirement.
- index.html clarifyFirstHint: one new bullet biasing toward asking on high-value forks with a low-stakes escape.
- tests.html: +1 cadence test (v2.3) in the Durable Record protocol-content suite; +1 clarify test in the Clarify gate suite.

## Verify

- Command: `./run-tests.sh`. Result: 650/650 passed (baseline 648, +2, no regressions).

## Outcome

The durable-record protocol now enforces per-item checklist ticking after each step (covering one Implementer finishing many items), and the clarify gate leans toward asking on genuine null/empty/contract forks while keeping a low-stakes escape. Both are additive prompt-text changes verified by string-assertion tests; no executable behavior changed. The heavier structural cadence options remain parked.

## Built with (provenance)

Produced directly (no sub-agent fan-out) from a real cold-run's findings: two additive prompt-text sharpenings plus string-assertion tests.
