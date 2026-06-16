# Format-aware orchestrator identity in generated prompts

Work: make the "who the orchestrator is" prose match the chosen export format. Branch: main. Status: complete, uncommitted (awaiting director commit).

## Why and scope

Two generated blocks named the orchestrator with a hardcoded identity list that included "the team lead" and "the SDK harness" regardless of the export format. In a Sub-Agents export (sequential Task sub-agents, no team lead) this read as if the workflow had become an Agent Teams run - a director reported exactly that confusion. The fix makes the orchestrator-identity phrase track the format: "the session you paste this into" for Workflow and Sub-Agents, "the team lead" for Agent Teams, "the SDK harness" for Agent SDK, "the Claude.ai conversation you paste this into" for Claude.ai.

Non-goals: changing the generic orchestrator descriptions in the Atlassian/clarify/Datadog gate hints (they say only "the top-level agent driving this workflow and spawning its steps" - already correct in every format); changing the Agent Teams brief's own legitimate "team lead" role language.

## Requirements

- R1: The orchestrator-identity phrase MUST match the export format wherever the prose enumerates a concrete identity.
  - Given format teams, Then the phrase is "the team lead". (test: orchestratorIdentity returns the right phrase for each of the five formats; Agent Teams export still calls the orchestrator the team lead)
  - Given format subagent or prompt, Then the phrase is "the session you paste this into" and never "team lead". (test: consumeRecordsHint names the format-appropriate orchestrator; Sub-Agents export never calls the orchestrator a team lead)
  - Given format sdk, Then the phrase is "the SDK harness". (test: genDurableRecordProtocol names the format-appropriate orchestrator)
  - Given format claude, Then the phrase is "the Claude.ai conversation you paste this into". (test: Claude.ai export uses the conversation phrasing, not team lead)

- R2: A Sub-Agents export MUST NOT contain the string "team lead" anywhere.
  - Given a bug-fix workflow with consumeRecords + memory + durable record on, When genSubAgents runs, Then the output contains no "team lead". (test: Sub-Agents export never calls the orchestrator a team lead)

- R3: Every generated prompt MUST declare its execution model early, with a format-specific directive that names the run model and forbids the wrong alternatives, so the runtime does not infer a different model from later vocabulary.
  - Given any format, When its generator runs, Then the output contains that format's execution-model label and no other format's. (tests: each generator emits its own execution-model label; a generator never emits another format's execution-model label)
  - Given the sub-agent format, Then the directive says to spawn each step as a sub-agent and to not create a team, and appears before the first agent step. (tests: the Sub-Agents directive forbids the team alternative; the directive appears before the first agent step)

## Approach and decisions

- Added a single helper `orchestratorIdentity(fmt)` returning the format-appropriate noun phrase, defaulting to `state.exportFormat` when no format is passed.
- Threaded an explicit `fmt` argument from each generator into the two functions that name a concrete identity: `consumeRecordsHint(fmt)` and `genDurableRecordProtocol(fmt)`. Chose explicit threading over reading `state.exportFormat` inside the helpers because the generators are also called directly (in tests, and potentially out of band), so an explicit format makes the output deterministic rather than dependent on global state. The default-to-state fallback keeps existing no-arg callers working.
- Left the gate hints (atlassianTicketFetchHint, clarifyFirstHint, datadogGroundingHint) unchanged: they describe the orchestrator generically without asserting a specific identity, so they are already correct in all five formats.
- Anti-priming follow-up: the agent-teams FEATURE vocabulary (team lead, TeamCreate, team_name, "coordinate teammates", "spawn teammates", shutdown_request) is what can nudge an executor into spinning up a team. After the identity fix it is fully confined to the Agent Teams export, except one colloquial "a teammate would actually use" in the durable-record protocol (rendered in non-Teams formats too), softened to "a colleague would actually use" so non-Teams exports carry none of that vocabulary. Kept the word "orchestrator" everywhere: it is the accurate, format-neutral term for the driving agent and does not denote the Agent Teams feature.

## Surface area (file -> role)

- index.html `executionModelDirective(fmt)` (new helper, beside orchestratorIdentity): returns [label, body] declaring the run model per format; injected early (right under the header) in all five generators - genWorkflow, genSubAgents, genAgentTeams (markdown blockquote), genAgentSDK (docstring line), genClaudePrompt (markdown blockquote). Always on (not toggle-gated).
- index.html `orchestratorIdentity(fmt)` (new helper, above consumeRecordsHint): the per-format identity phrase.
- index.html `consumeRecordsHint(fmt)`: identity line now uses the helper; threaded from genWorkflow('prompt'), genSubAgents('subagent'), genAgentTeams('teams'), genClaudePrompt('claude').
- index.html `genDurableRecordProtocol(fmt)`: the ORCHESTRATOR-owns-the-record line now uses the helper; threaded from the same four generators (genAgentSDK does not emit this block). Also softened "a teammate would actually use" -> "a colleague would actually use" (anti-priming).
- tests.html: export parity for `orchestratorIdentity`; new "Orchestrator identity is format-aware" suite (8 tests: per-format identity, Sub-Agents/Teams/Claude checks, a toggle-independence matrix, and an agent-teams-vocabulary anti-leak guard); updated one durable-protocol wording assertion to match the teammate->colleague edit.

## Verify

- Command: `./run-tests.sh` (headless Chrome over tests.html).
- Result: 641/641 passed. Baseline before this change was 628; +13 across two suites (identity per format with toggle-independence matrix and anti-leak guard; execution-model directive present, format-specific, early, and non-cross-contaminating); no regressions.

## Outcome

Generated prompts now name the orchestrator correctly for the chosen format via a small `orchestratorIdentity(fmt)` helper threaded into `consumeRecordsHint` and `genDurableRecordProtocol`. A Sub-Agents export no longer says "team lead"; Agent Teams keeps it; Claude.ai/SDK/Workflow each get their own phrasing. Additionally, every generated prompt now opens with a format-specific `executionModelDirective(fmt)` that names the run model and forbids the wrong alternatives (for example a Sub-Agents prompt states "spawn each step as a sub-agent... do not create a team"), and the one colloquial "teammate" in the durable-record protocol was softened to "colleague" so non-Teams exports carry no agent-team vocabulary. Verified by two suites (format-aware identity + execution-model directive); full run 641/641 green.

## Built with (provenance)

Produced directly (no sub-agent fan-out) during a session auditing the MCP toggles and export formats: trace the offending strings, add the helper, thread the format, add tests.
