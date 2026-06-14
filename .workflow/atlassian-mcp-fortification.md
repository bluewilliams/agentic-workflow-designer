# Make Atlassian guidance toggle-driven via a two-block split (no hardcoding)

Context: bring Atlassian guidance to the same consistency Datadog now has - toggle-driven, no hardcoded template lines - while keeping every workflow functional, especially the Jira-URL-as-input flow. Branch: main. Status: in progress.

## Why and scope
Atlassian guidance comes from two places today: the top-level `atlassianHint(urls)` (already gated on `state.mcpAtlassian` AND a Jira URL present) and ~10 hardcoded "If an Atlassian MCP tool is available, fetch/search..." lines baked into PROMPTS templates. The hardcoded lines are the fallback that makes toggle-off + Jira-URL work, but they also fire with no URL (phantom "fetch the ticket") and when the toggle is off (Atlassian noise). This change removes the hardcoding and splits Atlassian guidance into two clean concerns so all four (toggle x URL) scenarios behave correctly.

Non-goals: NOT touching the standalone Atlassian prompts in the Prompt Library (inherently Atlassian-themed, user-selected); NOT touching any Datadog work (datadogGroundingHint, datadogStepHint, mcpDatadog); NOT rejecting/blocking Jira-URL input (the browser fallback keeps it working); NOT changing the mcpAtlassian toggle's default (stays on).

## Requirements
- R1 Ticket-fetch block MUST be URL-driven and TOGGLE-INDEPENDENT, and ORCHESTRATOR-OWNED to avoid over-fetching. Given the workflow input contains a Jira URL (via getWorkflowAtlassianUrls/extractAtlassianUrls), When any format is generated, Then a block is injected instructing the orchestrator (the top-level agent, even when there is no named Planner step) to resolve the ticket ONCE before the first step and fold its content into the brief it hands the steps - so no step re-fetches the same ticket - via Atlassian MCP if available, otherwise the browser tools; the resolved ticket is the spec. Fires regardless of `state.mcpAtlassian`.
- R2 General Atlassian block MUST be TOGGLE-driven AND relevance-gated/anti-redundant. Given `state.mcpAtlassian` is true, When any format is generated, Then a block is injected saying Atlassian MCP is available for related context (other tickets, Confluence, linked/duplicate issues) but agents MUST prefer what is already in their brief, look something up only when their specific task needs context not already provided, and NOT repeat a lookup another step already did. This is the only Atlassian part gated by the toggle.
- R3 All ~10 hardcoded "If an Atlassian MCP tool is available..." lines MUST be removed from PROMPTS templates; after the change no PROMPTS template matches that hardcoded string (grep-verified). The two blocks cover both intents (ticket-fetch and related-search).
- R4 The two-block model MUST be applied at the four generator sites where atlassianHint is used (genWorkflow, genSubAgents, genAgentTeams, genClaudePrompt), the Refine and Plan inline "## Atlassian Context" blocks, and the Agent SDK exporter's Atlassian block.
- R5 Scenario matrix (all four MUST function; each verified by a test): toggle ON + URL -> ticket-fetch AND general both present; toggle ON + no URL -> general only, NO phantom ticket-fetch; toggle OFF + URL -> ticket-fetch only (MCP-or-browser wording); toggle OFF + no URL -> NO Atlassian guidance anywhere.
- R6 validateStoryInput MUST soften: when a Jira URL/key is input with the toggle off, show an informational nudge ("tip: enable Atlassian MCP for a direct ticket fetch; otherwise agents read the ticket via the browser"), not a blocking-feeling warning; the URL preset-picker MUST appear regardless of the toggle. The input MUST NOT be rejected.
- R7 No-regression: existing tests stay green; the Datadog work and the Prompt Library Atlassian prompts are untouched; the mcpAtlassian toggle/state wiring is unchanged except as required by the two-block refactor.
- R8 Suite green (baseline 539); new tests cover the four scenarios per affected generator + the template-line removal + the softened validateStoryInput. Hyphens not em dashes; no company-specific names.

## Success criteria
- A pasted Jira URL produces a workflow that fetches the ticket in every toggle state (MCP or browser) - the input flow never silently breaks.
- With no Jira URL, no generated workflow tells agents to "fetch the ticket"; with the toggle off and no URL, no Atlassian text appears at all.
- `grep "If an Atlassian MCP tool is available" index.html` returns only non-template (Prompt Library / Help) hits, none in PROMPTS templates.
- `./run-tests.sh` passes at >= 539, all green.

## Spec quality check
- [x] Each requirement is testable and unambiguous
- [x] Scope is bounded (Non-goals stated)
- [x] No open clarifications remain
- [x] Every behavior change names a verifying test
- [x] Success criteria are measurable

## Approach and decisions
- Decision: two-block split - a ticket-fetch block (URL-driven, toggle-independent) and a general-Atlassian block (toggle-driven) - likely two functions (e.g. `atlassianTicketFetchHint(urls)` and `atlassianGeneralHint()`) replacing the single `atlassianHint`. The Planner finalizes the exact shape and whether to keep one function with two parts.
- Decision: browser fallback in the ticket-fetch block. Chosen "option 2" (couple ticket-fetch to URL-presence, with MCP-or-browser) over "option 1" (reject the Jira URL when the toggle is off). Rejected option 1 because it blocks the user; option 2 keeps every workflow functional - the toggle governs GENERAL Atlassian use, while honoring the pasted ticket is driven by the input being there. Caveat: the browser path assumes the user is logged into Jira in their browser.
- Decision: soften validateStoryInput from a warning to a nudge and un-gate the URL preset-picker from the toggle, because the browser fallback makes URL input work in either toggle state - so blocking-feeling UX is no longer warranted.
- Grounding: mirrors the proven Datadog pattern (`.workflow/datadog-mcp-toggle.md` for the toggle-gated top-level block, `.workflow/datadog-step-escalation.md` for removing hardcoded template guidance in favor of generated blocks). Same injection sites and test approach.
- Decision (anti-over-fetch, Blue): make the two blocks a faithful mirror of the Datadog ARCHITECTURE, not just the toggle plumbing. The ticket-fetch block is ORCHESTRATOR-OWNED - resolve the ticket once up front and fold it into the brief (like datadogGroundingHint / consumeRecords) so N steps never re-fetch the same ticket. The general block is relevance-gated and anti-redundant (like datadogStepHint) - prefer the brief, look up only what your task needs, do not repeat another step's lookup. Rejected the naive "every agent fetches the ticket / looks things up" framing because it causes redundant fetches of the same ticket and over-fetching of related context. This is a wording/framing change; the injection structure is unchanged.
- Literal block strings (carry the same framing into the SDK and Refine/Plan blocks, adapted to their format):
  - Ticket-fetch: "**Atlassian ticket (the spec) - fetch once, up front.** The orchestrator (the top-level agent driving this workflow and spawning its steps, even when there is no named Planner step) resolves the ticket(s) below ONCE before the first step and folds the content into the brief it hands the steps - so no step re-fetches the same ticket. If an Atlassian MCP server is connected, fetch full details (description, acceptance criteria, linked issues, comments); otherwise open the URL(s) with the browser tools (assumes you are signed in to Atlassian there). The resolved ticket is the spec - treat its full content as the source of truth, and pass it down so the steps inherit it without re-querying." (then the URL list)
  - General: "**Atlassian (general) - look up only what your task needs.** An Atlassian MCP server is available for related context: other Jira tickets, Confluence docs (architecture, ADRs, runbooks), and linked or duplicate issues. Prefer what is already in your brief - the orchestrator has folded in the input ticket. Look something up yourself only when your specific task needs context not already provided, and do not repeat a lookup another step has already done. Skip this when your task does not need it."
- Post-merge: validate on a REAL Jira issue (paste a live ticket URL, generate a workflow, run it) to confirm the orchestrator-fetch-once and relevance-gating behave in practice, not just in tests.

## Surface area (file -> role) - provisional until the Planner grounds
- `index.html` `atlassianHint` (~1045) - refactor into the two-block model (ticket-fetch + general).
- `index.html` PROMPTS templates (~1203, 1205, 1222, 1227, 1238, 1247, 1272, 1297, 1305, 1452) - remove the hardcoded Atlassian lines.
- `index.html` four generator sites (~5775, 5945, 6210, 6669) + SDK Atlassian block (~6425) + Refine/Plan inline blocks (~4471, 4572) - emit the two blocks.
- `index.html` validateStoryInput (~4388-4513) incl. the toggle-off warnings (~4447, 4548) and the URL preset-picker gating (~4513) - soften + un-gate.
- `tests.html` - scenario tests per generator + template-removal + validateStoryInput.
- Out of scope (do NOT touch): Prompt Library Atlassian prompts (~3926-4130), all Datadog code.

## Task checklist
- [x] Planner: confirmed every Atlassian site + the 10 template lines (caught the array-element special case, the harness-export ReferenceError risk, the sourceLabel contradiction, the already-toggle-independent picker)
- [x] Implementer: built the two blocks, removed the hardcoded lines, wired all generators + SDK + Refine/Plan, softened validateStoryInput, added the scenario suite; suite 539 -> 577 green
- [x] Orchestrator refinement (Blue): rebalanced both block wordings - ticket = source for the plan (no raw-ticket-plus-plan duplication), general = permissive/anti-redundancy-only (not suppressing beneficial use); applied to the two functions + SDK; suite stayed 577
- [x] Reviewer: adversarially verified all four scenarios, no hardcoded line in templates, Datadog/Prompt-Library untouched, the refined wording resolves both over-fetch concerns, minimality - PASS
- [x] Orchestrator: finalized record, updated `.workflow/_index.md`, confirmed 577 green

## Verify
- `./run-tests.sh` -> 539 before, **577 after** (+38 tests), all passing. `grep "If an Atlassian MCP tool is available" index.html` -> 1 (the Prompt Library reviewer prompt only; 0 in PROMPTS templates). No `atlassianHint` reference remains in index.html or tests.html. Datadog hint functions intact (unchanged). `git diff --stat`: index.html +110/-50, tests.html +220/... - index.html and tests.html only.

## Outcome
Replaced the single toggle-AND-URL-gated `atlassianHint` with two functions: `atlassianTicketFetchHint(urls)` (URL-driven, toggle-INDEPENDENT, orchestrator-owned - the orchestrator resolves the ticket once as the SOURCE for the plan/requirements, and does not pass the raw ticket down on top of the plan) and `atlassianGeneralHint()` (toggle-driven, permissive but anti-redundant - use it freely when it helps, just do not re-fetch what you already have or repeat another step's lookup). Removed the hardcoded "If an Atlassian MCP tool is available" line from 10 PROMPTS templates so the toggle/URL drives all Atlassian guidance. Wired both blocks into the four prose generators + the SDK exporter + the Refine/Plan inline blocks. Softened validateStoryInput: the URL-only + toggle-off case no longer aborts generation (it shows a nudge), so a pasted Jira URL works in every toggle state via the MCP-or-browser fallback; the bare-Jira-key guard is kept; the Refine sourceLabel now keys off URL presence. All four (toggle x URL) scenarios behave correctly, including the consistency wins (no phantom ticket-fetch when there is no URL; no Atlassian noise when toggle off + no URL). Surface area: index.html (the two functions + four generators + SDK + Refine/Plan + validateStoryInput + the 10 template removals) and tests.html (harness export + rewritten unit tests + the 4x4 scenario suite).

## Follow-up (post-merge)
Validate on a REAL Jira issue: paste a live ticket URL, generate a workflow (and run it) to confirm in practice that the orchestrator fetches once and the steps work from the distilled plan (no re-fetch, no ticket-plus-plan duplication), and that relevance-gated related lookups happen when beneficial without over-fetching. Tests cover the wiring; only a live ticket confirms the agent behavior.

## Built with (provenance)
Workflow: `Atlassian MCP fortification` (Feature preset, generated by the agentic-workflow-designer; Planner -> Implementer -> Reviewer -> Tester, orchestrated in one session with a human design checkpoint after Planner and orchestrator test confirmation). Grounded by the `.workflow/_index.md` scan-then-open index. Baseline suite 539 green at kickoff.

## Links
- Work item: none (local task). Branch: main. PR: pending. Related: `.workflow/datadog-mcp-toggle.md`, `.workflow/datadog-step-escalation.md` (the Datadog analog this mirrors).
