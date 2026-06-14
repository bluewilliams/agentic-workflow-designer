# Durable record index

Scan-then-open: read this index first, match an entry against the files or capability your change touches, then open only the matched record(s). One entry per record, grouped by a stable capability slug.

## code-search-mcp-option

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
