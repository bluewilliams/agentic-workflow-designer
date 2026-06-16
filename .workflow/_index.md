# Durable record index

Scan-then-open: read this index first, match an entry against the files or capability your change touches, then open only the matched record(s). One entry per record, grouped by a stable capability slug.

## orchestrator-identity

- record: .workflow/orchestrator-identity-format-aware.md
- intent: make a generated prompt unambiguous about its format so it is not mis-run (e.g. Sub-Agents as Agent Teams) - orchestratorIdentity(fmt) tracks the format in the identity prose (threaded into consumeRecordsHint + genDurableRecordProtocol), plus an always-on executionModelDirective(fmt) injected early in all five generators that names the run model and forbids the wrong alternatives; also softened a colloquial "teammate" to "colleague" in the durable-record protocol
- files: index.html (orchestratorIdentity + executionModelDirective + consumeRecordsHint(fmt) + genDurableRecordProtocol(fmt) + 8 threaded call sites + 5 directive injection sites), tests.html (export parity + "Orchestrator identity is format-aware" + "Execution-model directive" suites)
- status: current | date: 2026-06-16

## code-search-mcp-option

- record: .workflow/code-search-mcp-awareness-in-agent-role-prompts.md
- intent: per-agent code-search-MCP awareness (gated codeSearchStepHint mirroring datadogStepHint) injected into 8 planning/implementing/navigating roles at the six datadog sites; plus a complementary-not-fallback reframe of the four code-search blocks (standing/Refine/Plan/SDK banner)
- files: index.html (CODE_SEARCH_STEP_ROLES + codeSearchStepHint + six injection sites + codeSearchHint clause + Refine/Plan/SDK-banner reframe), tests.html (export parity + "Code search step awareness" suite + tightened codeSearchHint test)
- status: current | builds-on: .workflow/make-sourcebot-option-general-and-called-code-search-mcp.md | date: 2026-06-15

- record: .workflow/make-sourcebot-option-general-and-called-code-search-mcp.md
- intent: generalize the single "Sourcebot" toggle into a tool-agnostic "Code search (MCP)" option (UI label, injected hint, exporters, docs)
- files: index.html (codeSearchHint + mcpCodeSearch toggle wiring + the four exporter injection sites + two inline hint blocks + SDK comment banner), tests.html, README.md, TECHNICAL.md
- status: current | date: 2026-06-13

## durable-record-protocol

- record: .workflow/compress-durable-record-at-finalize.md
- intent: finalize step compresses Verify/Gotchas into a clean spec (no per-agent transcript); surface area marked provisional until grounded
- files: index.html (genDurableRecordProtocol - finalize guidance + surface-area guidance), tests.html (Durable Record protocol-content tests)
- status: current | date: 2026-06-13

## repo-context-paths

- record: .workflow/repo-context-paths.md
- intent: two settings inputs (Rules/constitution paths + Product docs PRD/ADR) that inject repo-scoped binding-rules and product-goals guidance into generated prompts; flat lists, sticky, per-repo anti-contamination in the hint
- files: index.html (rulesPathsHint + productDocsHint + the two chip-list inputs + savePrefs/restorePrefs + sticky clearCanvas + five injection sites), tests.html, README.md, TECHNICAL.md
- status: current | date: 2026-06-13

## agent-prompt-config

- record: .workflow/agent-prompt-edit-ux.md
- intent: refine the Agent Prompt edit UX - compact textarea that expands on focus, "Edited from the {Role} template" wording + a two-box (Agent Prompt vs Custom Notes) hint, and an undoable Reset-to-template control
- files: index.html (agentPromptStatusBlock + the agent-branch focus/blur and reset binders + the Agent Prompt/Custom Notes configTextarea calls + CSS), tests.html
- status: current | supersedes: .workflow/strengthen-agent-prompts.md | date: 2026-06-13

- record: .workflow/strengthen-agent-prompts.md
- intent: node-config UI shows the attached role template (status line + inline read-only preview + ~6-row textarea) so agents stop looking thin; plus two additive lines (minimality + record-assumptions) to the coder/implementer template
- files: index.html (classifyAgentPrompt + agentPromptStatusBlock + updateConfig agent branch + configTextarea attrs param + PROMPTS.implementer), tests.html
- status: superseded | superseded_by: .workflow/agent-prompt-edit-ux.md | date: 2026-06-13

## in-app-help

- record: .workflow/documentation-updates.md
- intent: refresh the in-app Help modal (the `?` button) to match the current feature set - four new h3 sections (Editing Agent Prompts, Durable Record, Ground in Prior Records, Clarify Requirements First), an input-aware Generate note, and fixing the stale "Shared Memory" wording to the real toggle names
- files: index.html (.help-body div only - four new h3 sections + Quick Start and Power User Tips edits), tests.html (help-sections assertion extended for the four new headings)
- status: current | date: 2026-06-14

## datadog-mcp-toggle

- record: .workflow/datadog-mcp-toggle.md
- intent: add a first-class "Datadog" toggle to the MCP Integrations panel (default off) that, when on, emits an ORCHESTRATOR up-front production-telemetry grounding block - self-gating on relevance + Datadog availability, bounded plan-shaping read, deep query left to the step; mirrors the consumeRecords/clarifyFirst gate blocks (not the per-step codeSearch hint)
- files: index.html (mcpDatadogToggle UI + state wiring like mcpCodeSearch but default-off/clearCanvas-resets-false + datadogGroundingHint() + four generator injection sites + Help note), tests.html (harness export + resetState + 10-test "Datadog grounding gate" suite)
- status: current | date: 2026-06-14

- record: .workflow/datadog-step-escalation.md
- intent: complete the step-side of Datadog grounding - a toggle-gated per-agent hint (datadogStepHint) injected at the six per-agent generation sites for the reason-about-the-system roles {planner, architect, researcher, debugger, tester}, letting them run their own deeper/differently-angled query only when the orchestrator's bounded read is insufficient; removed the hardcoded Datadog line from PROMPTS.investigator so the toggle is the single source of truth (toggle off = no Datadog anywhere)
- files: index.html (datadogStepHint + DATADOG_STEP_ROLES + six per-agent injection sites + PROMPTS.investigator Datadog removal), tests.html (harness export + inverted run-#7 guard + 11-test "Datadog step escalation" suite)
- status: current | builds-on: .workflow/datadog-mcp-toggle.md | date: 2026-06-14

## atlassian-mcp-fortification

- record: .workflow/atlassian-mcp-fortification.md
- intent: make Atlassian guidance toggle-driven without breaking the Jira-URL-as-input flow - split atlassianHint into a URL-driven toggle-INDEPENDENT ticket-fetch block (orchestrator resolves the ticket once as the SOURCE for the plan, MCP-or-browser fallback, no raw-ticket-plus-plan duplication) and a toggle-driven permissive-but-anti-redundant general block; removed the hardcoded "If an Atlassian MCP tool is available" line from 10 PROMPTS templates; softened validateStoryInput so a Jira URL works in every toggle state
- files: index.html (atlassianTicketFetchHint + atlassianGeneralHint replacing atlassianHint + four generators + SDK + Refine/Plan blocks + validateStoryInput softening + 10 template removals), tests.html (harness export + rewritten unit tests + 4x4 scenario suite)
- status: current | date: 2026-06-14 | follow-up: validate on a real Jira issue post-merge

## delivery-commit-pr

- record: .workflow/delivery-section-enhancement.md
- intent: make committing/pushing/opening-a-PR an explicit opt-in (default OFF) via a new "Delivery" sidebar section + commitPr toggle that gates the five prBlock() call sites (noCommitBlock emitted when off); resolves the prBlock-vs-safety-list contradiction. ALSO (Part B, durable-record-protocol capability) restructured genDurableRecordProtocol's finalize prose into an explicit "### FINALIZE" step + a read-only-steps fold-in point.
- files: index.html (Delivery section + commitPr state wiring like mcpDatadog + noCommitBlock + 5 gated prBlock sites + genDurableRecordProtocol FINALIZE restructure), tests.html (+15 tests)
- status: current | date: 2026-06-14 | related: .workflow/compress-durable-record-at-finalize.md (Part B coexists with it - sibling refinements of the durable-record-protocol finalize guidance, no supersession)

## code-conventions

- record: .workflow/orchestrator-directives-for-code-comments-and-project-consistency.md
- intent: bake a soft, always-on orchestrator-level "Conventions" directive into generated workflows (prefer self-describing code over comments incl. tests; comment only for complex/why/project-convention; JSDoc for public APIs; when writing tests, match the project's existing test conventions; repo rules/CLAUDE.md override) + a reviewer line flagging narrating/redundant comments
- files: index.html (new conventionsHint() emitted at the 4 prose generators + an unconditional SDK #-comment block, next to codeSearchHint; one PROMPTS.reviewer "comment the why, not the what" line), tests.html (+9 tests)
- status: current | date: 2026-06-14

## atlassian-mcp-fortification

- record: .workflow/requirements-should-not-be-a-bare-uri.md
- intent: per-step "## Requirements" no longer emits a bare ticket URL (which invited every step to re-fetch); a new requirementsBlock(story, heading) helper points steps at the orchestrator-resolved spec + keeps the URL as a labeled reference when isUrlOnly(story), and emits plain-text input unchanged. Reinforces the resolve-once ticket-fetch protocol at the per-step level.
- files: index.html (requirementsBlock helper + the 4 multi-step generator Requirements sites routed through it; Refine/Plan single-agent prompts left as-is), tests.html (+12 tests)
- status: current | date: 2026-06-14 | related: .workflow/atlassian-mcp-fortification.md (complements the orchestrator-side ticket-fetch; no supersession)
