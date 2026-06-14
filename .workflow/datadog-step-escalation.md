# Let investigation-shaped worker agents escalate to Datadog when orchestrator grounding is insufficient

Context: complete the step-side of the Datadog grounding feature. The orchestrator already does a bounded plan-shaping read (see `.workflow/datadog-mcp-toggle.md`); this adds a toggle-gated, self-gating per-agent hint so investigation-shaped worker roles can run their own deeper Datadog query ONLY when the orchestrator's grounding was insufficient for their task. Branch: main. Status: in progress.

## Why and scope
The Datadog toggle currently instructs only the orchestrator (a bounded grounding block) plus the Bug Fix investigator (a hardcoded, toggle-independent line). Other investigation-shaped worker agents (researcher, a debugger used outside bug-fix, a tester validating runtime behavior) have no standing instruction to use Datadog - they depend entirely on the orchestrator delegating. This closes that gap: when the toggle is on, the relevant worker roles get a standing, self-gating note that they may escalate to their own Datadog query if the orchestrator's bounded grounding is not enough for their specific task. The note is deliberately "escalate only if unsatisfactory" so workers prefer the orchestrator's read and do not redundantly re-query.

Decision evolved (Blue, this session): the toggle is the SINGLE SOURCE OF TRUTH for Datadog guidance - no Datadog text is hardcoded in any workflow agent template. The Bug Fix investigator's hardcoded Datadog line is REMOVED and replaced by the toggle-gated hint. This is a deliberate behavior change: with the toggle off, Bug Fix no longer mentions Datadog at all; with it on, the investigator gets the new escalation hint. The content-dedup is dropped (nothing hardcoded left to collide with, and skipping the hint when a prompt mentions Datadog was too blunt - it would also block a legitimately different query). Role set expanded to include planner and architect (they reason about the system and can need operational data beyond the orchestrator's bounded read).

Non-goals: NOT changing the orchestrator grounding block (already shipped); NOT touching `getEffectivePrompt` (it also drives the node-config display); NOT adding the hint to pure-production roles (coder, frontend, backend, reviewer, writer, general) or to the SDK exporter; NOT touching the standalone Datadog prompts in the Prompt Library (inherently Datadog-themed, user-selected); NOT making the hint fire when the toggle is off; Atlassian's similar hardcoding in templates is OUT OF SCOPE (a possible follow-up).

## Requirements
- R1 A `datadogStepHint(node)` helper MUST return the escalation hint string when BOTH: (a) `state.mcpDatadog` is true; (b) the node's `agentType` is in the role set {`planner`, `architect`, `researcher`, `debugger`, `tester`} - and MUST return `''` otherwise. No content-dedup (dropped: with nothing hardcoded there is nothing to collide with, and skipping on a Datadog mention would wrongly block a legitimately different query).
- R2 The hint MUST encode: the trigger is production DATA broadly (telemetry, dashboards, SLOs, dependencies, deploy history, or other operational signals), not just live telemetry; prefer what the orchestrator already folded into the brief over re-running the same query for info you already have; you MAY still run your own deeper or differently-angled query when you judge it could surface something the bounded read did not (use your judgment - the guard is against redundant re-queries, not against a different angle); skip if Datadog is unavailable or the task does not need it. Hyphens not em dashes; no company-specific names. Literal string below in Approach.
- R3 The hint MUST be injected at the per-agent generation emission sites in the FOUR prompt formats (genWorkflow x2: the parallel sub-step site ~5811 and the single-node site ~5822; genSubAgents ~6007; genAgentTeams ~6248; genClaudePrompt x2: ~6702 and ~6726), appended after the effective prompt. It MUST NOT be injected in genAgentSDK (consistent with the orchestrator gate-block scoping), and MUST NOT alter `getEffectivePrompt` itself.
- R4 The hint system MUST be a no-op when the toggle is off: `datadogStepHint` returns `''` for every node, so it injects nothing in any format. (Overall toggle-off output differs from the prior build ONLY by R5's removal of the investigator's hardcoded line - the one intended change.) Verifying test: toggle off -> the step-hint marker is absent from all four formats.
- R5 Single source of truth (replaces the old dedup): all hardcoded Datadog text MUST be removed from `PROMPTS.investigator` (the only workflow template that hardcodes Datadog), so Datadog guidance comes ONLY from the toggle-gated hint. Behavior change: toggle OFF -> a Bug Fix workflow has NO Datadog mention; toggle ON -> the investigator (agentType `debugger`, in the role set) gets the new hint instead. The investigator template MUST still read coherently after removal (its Atlassian and other guidance left untouched - Atlassian consolidation is a separate change). Verifying tests: `PROMPTS.investigator` no longer matches /datadog/i; toggle-on bugfix node contains the hint marker; toggle-off bugfix node contains no Datadog text.
- R6 Positive case: a `researcher` (or `tester`) node with a default (non-Datadog) prompt + toggle on MUST receive the step hint in the generated output; with the toggle off it MUST NOT. A non-investigation role (e.g. `coder`) MUST NOT receive it in either state.
- R7 The node-config display / `classifyAgentPrompt` MUST be unaffected (the hint is generation-only). Verifying: the Agent Prompt status line + preview tests stay green; no new "Datadog" text appears in the node-config UI.
- R8 The full suite MUST stay green (baseline 528) with new tests added for R1-R7. No company-specific names; hyphens only; match existing code/style.

## Success criteria
- Toggle off: generated output unchanged from today (byte-identical), across all formats.
- Toggle on: a researcher/tester worker carries the escalation hint; the bugfix investigator carries exactly its original (single) Datadog line; a coder carries none.
- A maintainer reading a generated workflow sees one coherent Datadog story: orchestrator grounds (bounded), the relevant worker may escalate only if that grounding was insufficient, no duplicate or contradictory instructions.
- `./run-tests.sh` passes at >= 528, all green.

## Spec quality check
- [x] Each requirement is testable and unambiguous
- [x] Scope is bounded (Non-goals stated)
- [x] No open clarifications remain
- [x] Every behavior change names a verifying test
- [x] Success criteria are measurable

## Approach and decisions
- Decision: inject at the GENERATION emission sites, never in `getEffectivePrompt`. Rejected modifying getEffectivePrompt because it also feeds the node-config display and classifyAgentPrompt - changing it would leak the hint into the UI and break the status/preview tests.
- Decision: NO content-dedup, and remove all hardcoded Datadog from agent templates (the toggle is the single source of truth). Rejected the earlier content-dedup (skip if the prompt mentions Datadog) on two grounds Blue raised: (1) the dedup was only needed because of the investigator's hardcoded line - remove that line and there is nothing to collide with; (2) skipping the hint whenever Datadog is mentioned is too blunt - it would also block an agent from running a legitimately DIFFERENT query. The guard belongs in the WORDING ("prefer what you were given, do not re-run the same query, but a different/deeper query on your judgment is fine"), not in a skip.
- Decision: role set = {planner, architect, researcher, debugger, tester} - the roles that reason about the system. Added planner/architect (Blue): the orchestrator's grounding is bounded, so a planner/architect designing against a live system can need deeper operational data than the brief carries; the "only if necessary / use your judgment" framing prevents redundant re-grounding. Excluded coder/frontend/backend/reviewer/writer/general (writer is a borderline candidate for runbook/SRE docs - left out for now). debugger (the bugfix investigator) is now in-set and, with its hardcoded line removed, receives the hint cleanly when the toggle is on.
- Decision: the trigger is production DATA broadly, not just live telemetry (Blue) - SLOs, dashboards, dependencies, deploy history all count, which is what makes the hint relevant to planner/architect.
- Literal hint string: "If a Datadog MCP server is connected and your task could be informed by production data (telemetry, dashboards, SLOs, dependencies, deploy history, or other operational signals), prefer what the orchestrator already folded into your brief over re-running the same query for information you already have. You may still run your own deeper or differently-angled Datadog query when you judge it could surface something the orchestrator's bounded read did not. Skip this if Datadog is unavailable or your task does not need it." (single line; unique test marker: "differently-angled Datadog query".)
- Decision: four prompt formats only, not SDK - consistent with the orchestrator gate-block scoping in `.workflow/datadog-mcp-toggle.md`.

## Surface area (file -> role) - provisional until the Planner grounds
- `index.html` `datadogStepHint(node)` - new helper near `datadogGroundingHint` (~1128) / `getEffectivePrompt` (~1150). Gated per R1.
- `index.html` six emission sites - genWorkflow ~5811 + ~5822, genSubAgents ~6007, genAgentTeams ~6248, genClaudePrompt ~6702 + ~6726. Append the hint after each `getEffectivePrompt(...)` (matching each site's push/interpolation shape). Do NOT touch genAgentSDK ~6478.
- `index.html` (do NOT modify): `getEffectivePrompt` ~1150, `classifyAgentPrompt` ~1167, `PROMPTS.investigator` ~1211 (its Datadog line stays).
- `tests.html` - harness export for `datadogStepHint`; a new suite covering R1-R7 (off=absent across formats; researcher/tester on=present; debugger+investigator-template on=absent/dedup; coder on=absent; display unaffected).
- Reference-only: `datadogGroundingHint` (the orchestrator side), `AGENT_TYPE_PROMPT_MAP` (~1141), the bugfix preset (the Investigator node is agentType `debugger`), and prior record `.workflow/datadog-mcp-toggle.md`.

## Task checklist
- [x] Planner: confirmed the six emission sites + shapes (caught the interpolation-vs-push hazard at the two `- Instructions:` sites); confirmed role set; drafted the hint + test list
- [x] Implementer: added `datadogStepHint` (5-role set, no dedup), the six injections, removed Datadog from PROMPTS.investigator, inverted the prior run-#7 guard, added the test suite; suite green
- [x] Reviewer: adversarially verified - toggle-off no-op, single source of truth, investigator template coherent, no double-instruction, display unaffected, only index.html+tests.html touched - PASS
- [x] Orchestrator: finalized record, updated `.workflow/_index.md`, confirmed tests green

## Verify
- `./run-tests.sh` -> 528 before, **539 after** (+11 tests), all passing. The step-hint marker ("differently-angled Datadog query") appears once in index.html (the helper) and is injected at exactly the six per-agent sites; `PROMPTS.investigator` is Datadog-free (0 matches); genAgentSDK/getEffectivePrompt/classifyAgentPrompt untouched. `git diff --stat`: index.html +59/-1, tests.html +182/-2.

## Outcome
Added `datadogStepHint(node)`: a toggle-gated, per-agent escalation hint injected at the six per-agent generation sites for the reason-about-the-system roles {planner, architect, researcher, debugger, tester}. The hint tells those workers to prefer the production context the orchestrator already folded into their brief, but permits a deeper or differently-angled Datadog query on their own judgment when it could reveal something the bounded read did not - the guard is against redundant re-queries, not a different angle. Trigger broadened past live telemetry to production DATA generally (SLOs, dashboards, dependencies, deploy history). Removed all hardcoded Datadog from `PROMPTS.investigator` so the toggle is the single source of truth: toggle off -> no Datadog anywhere (including Bug Fix); toggle on -> the investigator gets the hint like any other in-set role. No dedup (the wording, not a skip, manages redundancy). The prior run-#7 guard was inverted to assert the investigator is now Datadog-free. Generation-only (node-config display unaffected); SDK exporter excluded; toggle-off output is a no-op for the hint system. Surface area: `index.html` (helper + six sites + investigator template) and `tests.html`.

## Built with (provenance)
Workflow: `Datadog step escalation` (Feature-style: Planner -> Implementer -> Reviewer -> Tester, orchestrated in one session, with a human design checkpoint after Planner and orchestrator test confirmation). Grounded by the `.workflow/_index.md` scan-then-open index. Baseline suite 528 green at kickoff.

## Links
- Work item: none (local task). Branch: main. PR: pending. Related: `.workflow/datadog-mcp-toggle.md` (the orchestrator side this completes).
