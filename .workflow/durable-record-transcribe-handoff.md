# Durable record: transcribe-ready per-step handoff

Branch: local working tree. Status: current. The lighter half of backlog #2 (per-step cadence reliability) - moves the per-step record update from "the orchestrator re-derives what changed" to "each step reports transcribe-ready lines and the orchestrator copies them."

## Why and scope

Cold runs reliably do the substantive work (resolve ticket / plan / pass the plan downstream) but skip the mechanical between-step record bookkeeping (checklist ticks, status bump) - re-confirmed by the read-only audit dogfood. Put the transcribe-ready data production on the RELIABLE actor: the sub-agent (which dependably honors its explicit end-of-response handoff), not the orchestrator (the flaky between-step actor). Non-goal: the heavier interleaved per-step "### Update the record" beats (backlog #2 option A) - still queued as the fallback if this proves insufficient on a build-task cold run.

## Requirements

- **Each agent emits a transcribe-ready handoff (gated, reused).** GIVEN the durable-record toggle is on, WHEN any of the four prose generators emits an agent step THEN the step is told to end its report with two lines - `DONE:` the work items it completed, `STATUS:` a one-line current-state. One shared helper `recordHandoffHint()` returns this verbatim for every agent; it returns '' when the toggle is off. Verified by `v2.5` (helper on/off + present in all four generators when on, absent when off).
- **The orchestrator transcribes, not re-derives.** The KEEP CURRENT bullet says: each step is instructed to emit DONE/STATUS; transcribe those (tick the matching checklist items, overwrite Current state) rather than reconstruct; fall back to Files Changed / verification only if a step omits them. Verified by `v2.4`.
- **Gating.** Durable-record only (no record = no checklist to feed); Ground-in-Prior-Records (read side) unaffected; non-record handoffs unchanged. Verified by `v2.5` off-case.

## Approach and decisions

- One shared helper `recordHandoffHint()` (gated on `state.durableRecord`), injected at the six per-agent sites that already carry `datadogStepHint`/`codeSearchStepHint` - the established universal per-agent injection pattern.
- Chose the step-hint injection pattern over folding into `genAgentMemoryPostamble`, because the postamble is used by only two generators (genSubAgents + SDK) - it would miss genWorkflow and genAgentTeams. The step-hint sites cover all four prose generators.
- Agent-side over orchestrator-only (the earlier shipped half): agents reliably honor end-of-response handoff instructions; the orchestrator is the actor that skips bookkeeping. So producing the data agent-side makes the DONE/STATUS reliably EXIST; the orchestrator then only copies. Reconciled the orchestrator KEEP CURRENT bullet from "ask each step" to "each step is instructed to emit; transcribe" so the two halves complement without a redundant double-ask.
- genAgentSDK not wired (it lacks the per-agent step-hint pattern and is a removal candidate); consistent with the audit.

## Surface area

- `index.html`: `recordHandoffHint()` helper; 6 per-agent injections (genWorkflow x2, genSubAgents, genAgentTeams, genClaudePrompt x2); reconciled KEEP CURRENT bullet in `genDurableRecordProtocol`.
- `tests.html`: `recordHandoffHint` bridged to win; `v2.4` (orchestrator transcribe wording) + `v2.5` (agent-side reuse + gating, +1).

## Verify

`./run-tests.sh` -> 1083/1083. v2.5 confirms the fragment is present per-agent in all four prose generators when durableRecord is on and absent when off; helper returns '' when off.

## Gotchas

- Durable record is a strict superset of memory (`toggleDurableRecord` forces it off when memory is off), so a test exercising the on-case sets `memoryEnabled = true` too.
- The fragment is a handoff instruction injected at the (mid-block) step-hint sites; phrased as "end your report with..." so it reads as a handoff addendum, not a competing task.

## Outcome

Per-step record updates are now transcriptions of each step's own DONE/STATUS report, produced by the reliable actor (the agent) via one reused gated fragment, with the orchestrator copying. The lighter half of backlog #2 is done in its fuller form; the heavier interleaved-beats remains queued, to be validated/decided by a build-task dogfood.

## Built with (provenance)

Authored directly, from backlog #2 (re-confirmed by the read-only audit dogfood); upgraded from the orchestrator-only half to the agent-side fuller version on the director's request.
