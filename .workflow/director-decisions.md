# Director decisions (the record's trail of answers that changed the run)

Context: direct session, director-requested after a run did something its plan did not say and nothing in the record explained why. Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- With **Record director decisions** on (a switch directly under Keep a durable record in Memory & Durable Record; on by default whenever the record is on; stored with the other preferences and kept through a record-off period, so it shows on again when the record returns; a team setting an org pack can set; a facade `setOptions` boolean), the record protocol carries a **Director decisions** section, included only when any exist: one line per director answer that changed what the run did or delivered (`- YYYY-MM-DD HH:MM: {what was asked} -> {what the director decided} -> {the consequence}`): a step waived, a gate overridden, a failing criterion accepted, scope cut, a plan approved with modifications. A plain approval, an answer that confirmed the proposed default, or a preference with no effect on the outcome is never written. The orchestrator writes the line at the KEEP CURRENT beat right after the answer arrives; steps never write it. The plan-approval clause routes an approval with modifications, a rejection and a waiver there; the eval open-questions clause records each answer there.
- Switch or no switch: a task the director waived is ticked as `(waived by director: reason)` instead of left open or ticked silently, the completion gate accepts that form, and a skipped or failed step in the run-report fence carries a `reason` that names the director when the director decided it.
- Off: no Director decisions text is emitted anywhere; the record reads as before.
- Record off: nothing instructs a write to a record that will not exist. The record protocol is absent, the approval clause does not route to the section, and the eval open-questions clause tells the orchestrator to record each director answer in the frozen eval itself (the criterion it shaped carries the answer); with the record on and the switch off, that clause records the answer in the record as a decision.

## Why and scope

The record captured the plan's decisions and the eval's answers but had no home for a mid-run director choice, so a reader a month later could not tell that a person decided a step would not run. Scope: the switch, the section and its gate, the beat bullet, the approval and eval clauses, the waiver tick, the fence reason, docs. Non-goals: no change to the record's single-file shape; the section is concise by rule (one line per decision, nothing routine).

## Approach and decisions

- Default on with the record (director: "I'll just turn it off if I don't want it"); New Workflow resets it with the other switches of its section unless the section is pinned. Rejected: a spot in Defaults (that section seeds nodes). Reconsidered 2026-11-06 evening (a pinned section could hold it off forever): kept on, because the pin IS the off-for-good path and an unpinned section resets to the defaults like every other switch.
- The preference is independent of the record: the prefs restore no longer zeroes it when the record is off (the first cut did, so a saved profile with the record off came back with the switch off after the record was turned on again, and the golden maps had been captured in that state); emission gates on the record at every site instead.
- The filter is "changed what the run did or delivered", stated in the protocol and repeated at the beat, so the section cannot become a transcript.
- The waiver tick and the fence reason are not behind the switch: they are honesty about what ran.
- Three frozen sidebar guards migrated deliberately (controls 37 to 38, the preference keys, the control anatomy) and the five golden maps recaptured: the fence reason sentence changes every format for every preset, the rest only record-bearing variants.

## Verify

- `./run-tests.sh`: 2174 -> 2178, then 2181 with the fixes below (New Workflow reset unless pinned; record off emits no record instruction) (switch on: section, beat, approval routing, waiver wording; switch off: nothing, waiver and fence reason stay; the switch's placement, default, follow-the-record, persistence, legacy prefs, team settings key, New Workflow default; facade option, undo, catalog).
- Content lint clean; no em or en dashes; the full-output diff against the previous commit shows only the intended sentences.

## History

- 2026-11-06: created (by direct session).
- 2026-11-06 (later): amended in place. New Workflow now resets the switch unless its section is pinned (the reset block had skipped it); the prefs restore keeps the preference through a record-off period; the checkbox moved directly under Keep a durable record; with the record off the eval open-questions clause no longer names the record; unchecking Keep a durable record (or memory) by click now hides the switch with the other record fields (the click handlers mirrored the fields by hand and skipped it; only the sync path hid it), the saved preference comes back when the record returns. Golden maps recaptured for the record-bearing and eval variants; the suite pins the switch's baseline so no test can leak a value into the guards.
