# Rename: Implementation Plan -> Workflow Context, Custom Notes -> Agent Context

Work item: Blue - the "Implementation Plan" input + "Generate Plan Prompt" button still felt undistinguished, and the field is really general workflow-wide context (he pasted a Datadog-MCP hint, not a plan). Status: complete, uncommitted (Blue commits). Tests: 705/705.

## Why and scope

The "Implementation Plan" sidebar field is free-form context injected into EVERY agent's prompt (getPlan() -> "## ... (starting guidance - adapt based on findings)" in all 5 generators) - a plan is just the canonical content, but any context works. The per-node "Custom Notes" field is the same kind of thing at AGENT scope (appended to one agent's prompt). Renaming them as a matched pair (a) describes them honestly, (b) makes the workflow-vs-agent scope obvious, and (c) dissolves the box-vs-button confusion (the box and "Generate Plan Prompt" stop sharing the word "Plan").

Constraint: internal ids/keys unchanged (`planInput`, `getPlan()`, the `plan` serialization key, `config.notes`) so saved workflows stay compatible - UI/generated-text only.

## Approach and decisions

- Implementation Plan -> **Workflow Context** (matched noun "Context", scope = whole workflow). Added a scope sub-label ("Added to every agent's prompt - ...") and a light hairline separator between the box and the Generate Plan Prompt button (Blue's ask), so the button reads as the optional helper that fills the box, not an action on it.
- Custom Notes -> **Agent Context** (same noun, scope = this node). Placeholder reworded "Added to THIS agent only ...".
- Generated output section renamed to match: "## Implementation Plan (starting guidance - adapt based on findings)" -> "## Workflow Context (...)" in all 5 generators (so a non-plan note like a Datadog hint is no longer mislabeled a "plan").
- KEPT: "Generate Plan Prompt" button (it produces one KIND of workflow context - a plan); "Implementation Planning" (the plan-prompt's title - the activity, not the field); the "## Implementation Plan" section inside the tech-spec prompt-library template (a real doc section); the internal test-suite name.

## Surface area (file -> role)

- index.html: Workflow Context sidebar block (h3 + scope sub-label + placeholder + hairline separator + button row + helper); Agent Context node-config field (configTextarea label + placeholder); agentPromptStatusBlock hint + 2 Help-modal refs (Custom Notes); Help-modal "paste plan into ... field" ref; the "## Workflow Context (starting guidance)" header in all 5 generators (genWorkflow ### + sentence, genSubAgents/genAgentTeams/genClaudePrompt ##, genAgentSDK # ──); the genPlanPrompt "paste into ... field" instruction. UI/text only - no id/key/function renames.
- tests.html: updated output-section assertions (Implementation Plan -> Workflow Context) in the export-integration + plan suites; the plan-prompt "paste into field" assertion; the two-box-hint/Agent-Context helper test (Custom Notes -> Agent Context, placeholder phrase). 705/705.
- README.md: node-config Agent Context (+ Workflow Context counterpart note); Refine & Plan "Workflow Context field".
- TECHNICAL.md: Agent Context (was Custom Notes) note; file-structure sidebar map; test-coverage description.

## Verify

Command: ./run-tests.sh -> 705/705. Browser-verified: Workflow Context header + scope sub-label + new placeholder + the hairline separator above Generate Plan Prompt + helper pointing to "the Workflow Context box above"; Agent Context label confirmed via test.

## Outcome

The two free-form context fields now read as a scoped pair - **Workflow Context** (every agent) and **Agent Context** (this node) - the box-vs-button confusion is gone, and the generated prompts label the injected context consistently. Internal ids/serialization unchanged, so existing saved workflows load fine.

## Built with (provenance)

Workflow: direct implementation by the orchestrator. UI/text + generated-header rename across index.html (incl. all 5 generators) + tests + README + TECHNICAL; internal ids preserved for serialization compat. Browser-verified. Part of the ui-labels capability (follows the Auto Workflow button relabel).

## Links

Branch: TBD. PR: TBD.
