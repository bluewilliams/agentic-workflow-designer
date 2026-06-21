# Audit of generated-prompt machinery

Work item: read-only audit (no ticket). Branch: local working tree. Status: in progress (orchestrating).

## Why and scope

The designer wires features/toggles (memory, durable record, ground-in-prior-records, clarify-first, Atlassian/Datadog/code-search MCP, repo context, delivery formats) into five generators (genWorkflow, genSubAgents, genAgentTeams, genAgentSDK, genClaudePrompt) - added over time, not always uniformly. Produce a prioritized findings report of gaps and inconsistencies. **Non-goals:** any code change (read-only audit); the report is the deliverable.

## Audit scope (what the audit must cover)

- Toggle/feature wiring parity across all five generators.
- Durable-record protocol: does it drive per-step cadence or rely on discipline a cold run skips?
- Cross-generator consistency: requirements framing, delivery, orchestrator identity, Jira handling.
- Anything else that would degrade a generated prompt or a cold run.

## Grounding (from existing .workflow records, folded into the reviewer brief)

- `agent-sdk-ground-in-prior-records-gap` + `consume-prior-records`: genAgentSDK historically lagged on toggle injections and reimplements some MCP hints inline (drift risk). Backlog #4 documents clarify/Datadog/code-search SDK gaps still open.
- `cadence-granularity-and-clarify-sensitivity` + backlog #2/#3: cold runs skip the per-step record cadence; clarify under-triggers.
- `orchestrator-identity-format-aware`, `delivery-commit-pr`, `datadog-mcp-toggle`, `code-search-mcp-option`, `atlassian-mcp-fortification`, `durable-record-protocol`: the per-feature wiring history.

## Surface area (provisional - reviewer to verify)

- `index.html`: the 5 generator functions + the shared hint helpers (atlassianTicketFetchHint/atlassianGeneralHint, codeSearchHint/codeSearchStepHint, datadogGroundingHint/datadogStepHint, clarifyFirstHint, consumeRecordsHint, genDurableRecordProtocol, executionModelDirective, orchestratorIdentity, requirementsBlock, deliveryBlock).
- `tests.html`: parity assertions (export suites, MCP toggle leak guard).

## Task checklist

- [x] Step 1 (Quality Reviewer): DONE - audited parity/cadence/consistency; findings folded in below.
- [x] Step 2 (Report Builder): agent died mid-response (API error) before writing; orchestrator recovered and wrote the report (findings already captured) -> `.workflow/audit-of-generated-prompt-machinery-report.md`.
- [x] Orchestrator: workflow gaps captured (see below).

## Findings (Step 1, read-only)

- **Parity matrix**: the four prose generators (genWorkflow/genSubAgents/genAgentTeams/genClaudePrompt) call every shared hint helper consistently. **genAgentSDK is the sole divergence on every row**: it reimplements 10 helpers inline as Python `#` comments (drift risk) and OMITS four entirely - `clarifyFirstHint`, `datadogGroundingHint`, `datadogStepHint`, `codeSearchStepHint` (grep of the SDK range for these returns zero).
- **HIGH - live drift (new)**: the SDK's inline `consumeRecords` comment (~7365-7377) has already drifted below the shared `consumeRecordsHint` (1254-1267) - it omits the "Grep the index, do not read it whole" scaling guidance and the supersede-on-modify bullet. Not hypothetical; already weaker.
- **HIGH - missing clarify-first in SDK**: ironic, since `clarifyFirstHint` itself names "an SDK pipeline" as the non-interactive case it handles, yet the SDK never receives it.
- **HIGH - missing Datadog grounding + step in SDK**: an SDK pipeline for a bug/regression with Datadog on silently loses all telemetry grounding.
- **HIGH - SDK durable-record cadence degraded**: SDK uses `genDurableRecordComment` (2926-2950), which collapses the enforced per-step KEEP-CURRENT beat (present and structural in `genDurableRecordProtocol` 2893-2898) to one prose clause - exactly the cold-run-skips-cadence gap backlog #2 fixed for the prose generators, never carried into the SDK.
- **MEDIUM - test blind spots**: the consume/clarify/datadog parity suites assert "all FOUR exporters" (SDK intentionally excluded), the MCP leak-guard's ON positive controls assert only `genWorkflow`, and the rules/product-docs "all five" tests check only the section-title substring, not body equivalence - so SDK drift is silent to the suite.
- **Confirms** backlog #2 (cadence) and #4 (SDK toggle gaps) still open; NEW = the consume-records drift is already real and untested.

## Outcome

Audit complete (read-only, no code changed). Deliverable: `.workflow/audit-of-generated-prompt-machinery-report.md`. The four prose generators are in lockstep; genAgentSDK is the sole divergence (10 helpers reimplemented inline + 4 missing toggle injections + degraded durable-record cadence); NEW = the SDK consume-records comment has already drifted below the shared helper, untested. Backlog #2 and #4 confirmed still open. All fixes land on the SDK (which the director does not use), so SDK priority is the director's call; the test blind spots (parity suites exclude the SDK) are worth closing regardless.

## Workflow gaps observed (the execution-dogfood output)

Running this generated workflow end-to-end surfaced gaps in the DESIGNER's own generated prompts:
1. **Role-task vs requirements mismatch (High)**: the Quality Reviewer's canned "Your Task" is generic code-quality (complexity/DRY/SOLID, LSP-heavy); the actual audit ask lived only in the Requirements block. A paste-and-run user gets a generic review unless the orchestrator re-focuses the brief.
2. **LSP instructions on a single-file app (Medium)**: the reviewer prompt leans on LSP documentSymbol/incomingCalls/outgoingCalls, useless on one inline `<script>`. The generator hands out LSP steps regardless of language-server availability.
3. **Report Builder is a Review-Swarm template on a single-reviewer workflow (High)**: it instructs "aggregate across security/quality/performance/architecture" and "health scores per dimension" when only one Quality reviewer ran - it would reference dimensions never audited.
4. **Irrelevant hints injected (Low)**: the Report Builder (Read/Write only) received the Datadog + code-search MCP hint blocks - noise for a compile-the-report role.
5. **Durable-record protocol does not fit a read-only audit (Medium)**: built for code changes (Requirements as MUST/SHALL + Given/When/Then + verifying tests); for an audit there is nothing to test, and it overlaps the audit report (two artifacts). No read-only/report variant.
6. **No resilience guidance for a dead step (Medium, surfaced live)**: the Report Builder agent died mid-response (API error) before writing. Recovery worked only because the orchestrator held the findings + this record - but the generated prompt gives no explicit "a step died: recover from the record/handoff" instruction. Strong argument for the durable record; also a gap in the prompt's failure handling.

## Built with (provenance)

Workflow `Audit of generated prompt machinery` (Auto Workflow, read-only review shape): Quality Reviewer (read-only; Read/Grep/Glob/LSP) -> Report Builder (Read/Write) -> Audit Report. Toggles on: durable record + ground-in-prior-records. No decision gates, forks, or review loops. Orchestrated manually for an execution-dogfood; Step 2 agent died on an API error and the orchestrator recovered from this record.
