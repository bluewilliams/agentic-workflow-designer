# Director decisions (the record's trail of answers that changed the run)

Context: direct session, director-requested after a run did something its plan did not say and nothing in the record explained why. Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- With **Record director decisions** on (a switch under Keep a durable record in Memory & Durable Record; on by default whenever the record is on; stored with the other preferences; a team setting an org pack can set; a facade `setOptions` boolean), the record protocol carries a **Director decisions** section, included only when any exist: one line per director answer that changed what the run did or delivered (`- YYYY-MM-DD HH:MM: {what was asked} -> {what the director decided} -> {the consequence}`): a step waived, a gate overridden, a failing criterion accepted, scope cut, a plan approved with modifications. A plain approval, an answer that confirmed the proposed default, or a preference with no effect on the outcome is never written. The orchestrator writes the line at the KEEP CURRENT beat right after the answer arrives; steps never write it. The plan-approval clause routes an approval with modifications, a rejection and a waiver there; the eval open-questions clause records each answer there.
- Switch or no switch: a task the director waived is ticked as `(waived by director: reason)` instead of left open or ticked silently, the completion gate accepts that form, and a skipped or failed step in the run-report fence carries a `reason` that names the director when the director decided it.
- Off: no Director decisions text is emitted anywhere; the record reads as before.

## Why and scope

The record captured the plan's decisions and the eval's answers but had no home for a mid-run director choice, so a reader a month later could not tell that a person decided a step would not run. Scope: the switch, the section and its gate, the beat bullet, the approval and eval clauses, the waiver tick, the fence reason, docs. Non-goals: no change to the record's single-file shape; the section is concise by rule (one line per decision, nothing routine).

## Approach and decisions

- Default on with the record (director: "I'll just turn it off if I don't want it"); New Workflow resets it with the other switches of its section unless the section is pinned. Rejected: a spot in Defaults (that section seeds nodes).
- The filter is "changed what the run did or delivered", stated in the protocol and repeated at the beat, so the section cannot become a transcript.
- The waiver tick and the fence reason are not behind the switch: they are honesty about what ran.
- Three frozen sidebar guards migrated deliberately (controls 37 to 38, the preference keys, the control anatomy) and the five golden maps recaptured: the fence reason sentence changes every format for every preset, the rest only record-bearing variants.

## Verify

- `./run-tests.sh`: 2174 -> 2178 (switch on: section, beat, approval routing, waiver wording; switch off: nothing, waiver and fence reason stay; the switch's placement, default, follow-the-record, persistence, legacy prefs, team settings key, New Workflow default; facade option, undo, catalog).
- Content lint clean; no em or en dashes; the full-output diff against the previous commit shows only the intended sentences.

## History

- 2026-11-06: created (by direct session).
