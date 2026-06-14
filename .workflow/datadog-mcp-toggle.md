# Add a first-class Datadog MCP toggle to the MCP Integrations panel

Context: promote Datadog from an "other MCP" you describe in free text to a first-class toggle, matching how it is already framed in the app copy. Branch: main. Status: in progress.

## Why and scope
The app frames Datadog MCP as a first-class, recommended integration (the "Better outcomes" sidebar tip and the Help "Recommended Integrations" section name it alongside Atlassian and a language LSP). But the MCP Integrations panel only has toggles for Atlassian and Code search; Datadog has no control - users would have to describe it in the free-text "other MCPs" box. This change closes that inconsistency by adding a Datadog toggle that injects a general observability hint into exported prompts, mirroring the existing `atlassianHint` / `codeSearchHint` pattern. It also generalizes Datadog guidance beyond the one place it is currently hardcoded (the Bug Fix investigation step).

Non-goals: not changing the Bug Fix workflow's existing inline Datadog guidance (kept, to avoid a behavior regression); not adding Datadog to the prompt-library prompts (they already reference it); not building install/auth UI (the Help already documents setup).

## Requirements
- R1 The MCP Integrations panel MUST show a "Datadog" toggle. Given the sidebar renders, When the panel is shown, Then a checkbox labeled "Datadog (metrics, logs, traces)" (or similar) appears after the "Code search (MCP)" toggle, with id `mcpDatadogToggle`. Verifying test: a DOM-presence test in tests.html.
- R2 The toggle MUST default to UNCHECKED (opt-in), unlike Atlassian/Code search which default checked - Datadog is less commonly configured. Given a fresh state, When the app loads, Then `state.mcpDatadog === false` and the box is unchecked.
- R3 When `state.mcpDatadog` is true, a `datadogGroundingHint()` function MUST emit an ORCHESTRATOR up-front grounding block (shaped like `consumeRecordsHint` / `clarifyFirstHint`, NOT the per-step `codeSearchHint` tool hint), and return `null` when false. The block instructs the orchestrator (the top-level agent that drives the workflow, even when there is no named Planner or Investigator step) to, before the first step: judge whether the work would be materially informed by production telemetry (a bug, regression, incident, performance, reliability, capacity, OR documenting/validating a service's real runtime behavior) AND whether Datadog MCP is available; if so, pull a BOUNDED, point-in-time, plan-shaping read (current error rate, regression window, affected-service health, recent anomalies relevant to scope) and fold it into the brief; explicitly NOT a full investigation, and hand the deep query to the relevant step. Self-gating: a no-op when the work is not telemetry-relevant or Datadog is unavailable.
- R4 The grounding block MUST be injected at the same orchestrator-block sites that inject `consumeRecordsHint` and `clarifyFirstHint` (the four format generators: Workflow ~5742/5744, Sub-Agents ~5908/5910, Agent Teams ~6170/6172, Claude prompt ~6626/6628), so enabling the toggle adds the block to every export format. Verifying test: per-format injection tests (block present when on, absent when off).
- R4b Orchestrator-owned, not step-dependent: because the block is emitted at the orchestrator level, it MUST fire for canned workflows that include no Planner or Investigator agent (the orchestrator always exists). The bounded plan-shaping read is the orchestrator's job; the deep, fresh Datadog query stays with whatever step owns the investigation (and the existing Bug Fix inline mention, kept per R6).
- R5 State MUST round-trip: the toggle wires through `toggleMcpDatadog()`, the default state object, `savePrefs`, and `restorePrefs`, exactly like `mcpCodeSearch`. Given the toggle is set and prefs are saved/restored, When the app reloads, Then the toggle state persists.
- R6 The Bug Fix workflow's existing inline Datadog mention MUST remain (no regression); the new hint is additive. Given the Datadog toggle is off, When a Bug Fix workflow is exported, Then it still contains its current "if Datadog MCP tools are available" guidance.
- R7 The full suite MUST stay green (baseline 518). New tests are added for R1-R5. No company-specific names; hyphens not em dashes; match existing UI/code style.
- R8 (minor) The Help MCP/Integrations wording SHOULD note Datadog is now a toggle (not just a recommended install), keeping Help consistent with the new control.

## Success criteria
- Enabling the Datadog toggle adds an observability hint to all four export formats; disabling it removes the hint entirely.
- A fresh install shows Datadog unchecked; an existing Bug Fix export is byte-unchanged when the toggle is off (no regression).
- Toggle state persists across reload via prefs.
- `./run-tests.sh` passes at >= 518, all green.

## Spec quality check
- [x] Each requirement is testable and unambiguous
- [x] Scope is bounded (Non-goals stated)
- [x] No open clarifications remain
- [x] Every behavior change names a verifying test
- [x] Success criteria are measurable

## Approach and decisions
- Decision (architecture): the toggle emits an ORCHESTRATOR up-front grounding block, mirroring the `consumeRecordsHint` / `clarifyFirstHint` gate blocks - NOT the per-step `codeSearchHint` tool hint. Rationale: Datadog grounding is plan-shaping context that belongs to whoever owns the plan, and the orchestrator is the one agent guaranteed to exist in every workflow (the existing gate blocks already rely on this, firing "even when there is no named Planner step"). Putting it at the orchestrator level is what guarantees the grounding happens in canned workflows that have no planner/investigator.
- Decision (separation of concerns): "Bounded Orchestrator + Step use." The orchestrator does a BOUNDED, point-in-time, plan-shaping read; the deep investigation stays with the step that owns it. Rejected two alternatives: (a) "Full orchestrator grounding" - doing the complete Datadog investigation up front and baking it into the plan - rejected because it over-fixes the plan to a stale snapshot and steps on the investigating agent's job; (b) "Step-level only" - rejected because canned workflows without a planner/investigator would then get no grounding at all. The bound is enforced by the prompt contract the same way record-grounding is bounded ("read the matched decisions, do not re-derive the codebase").
- Decision (relevance gating): the block self-gates on relevance ("would production telemetry materially inform this work?") rather than an enumerated bug/perf list, so it also covers documentation or validation tasks that describe a service's real runtime behavior. No-op when not relevant or Datadog unavailable.
- Decision: default UNCHECKED. Chose opt-in over the Atlassian/Code-search default-on because the block drives an active consultation of a production telemetry system, which a user should knowingly enable. The double self-gating (relevance AND availability) keeps it harmless when on, so the cost of opt-in is low.
- Decision: do NOT trim the Bug Fix inline Datadog mention. Rejected trimming it because, combined with default-off, it would REMOVE the always-on Datadog nudge from the workflow where it matters most - a behavior regression. The orchestrator block is additive; the deep step-level query is where the bug-fix mention lives.
- Decision: clearCanvas resets `mcpDatadog` to false (its default), NOT forced true the way `mcpCodeSearch` is - consistent with default-off.

## Surface area (file -> role) - provisional until the implementer grounds
- `index.html` MCP Integrations panel (~line 643-649, after the Code search toggle) - add the `mcpDatadogToggle` checkbox. PRIMARY UI.
- `index.html` `datadogGroundingHint()` - new function next to `consumeRecordsHint` (~1097) / `clarifyFirstHint` (~1112), gated on `state.mcpDatadog`, returning the orchestrator grounding block (or null).
- `index.html` injection sites - mirror `consumeRecordsHint` / `clarifyFirstHint` usages (the orchestrator gate blocks): genWorkflow ~5742/5744, genSubAgents ~5908/5910, genAgentTeams ~6170/6172, genClaudePrompt ~6626/6628. Place the Datadog block alongside those gate blocks in each generator. (Note: this is a DIFFERENT injection family than `codeSearchHint`, which is a per-step tool hint - do not conflate.)
- `index.html` state wiring - default state (~1304 `mcpCodeSearch: true` -> add `mcpDatadog: false`), `toggleMcpDatadog()` (~1778), savePrefs (~1844), restorePrefs (~1886), clearCanvas (~5365/5370 - reset to false, do not force true).
- `tests.html` - new tests paralleling the codeSearch/atlassian hint + prefs tests.
- `index.html` Help (~line 882 Recommended Integrations / the MCP Integrations note) - minor wording so Help reflects the toggle (R8).
- Reference-only (the pattern to copy, do not change): `codeSearchHint` (1046), the `mcpCodeSearch` wiring, and prior records `make-sourcebot-option-general-and-called-code-search-mcp.md` and `repo-context-paths.md`.

## Task checklist
- [x] Planner: confirmed the injection sites + state-wiring; decided the four orchestrator-block generators only (NOT genAgentSDK); finalized the test list
- [x] Implementer: added the toggle, `datadogGroundingHint()`, the four injection sites, full state wiring (default-off + clearCanvas reset to false), the Help note; added 10 tests; suite green
- [x] Reviewer: verified pattern parity with consumeRecords/clarifyFirst, no Bug Fix regression (R6), default-off (R2), orchestrator-owned (R4b), minimality - PASS
- [x] Orchestrator: finalized record, updated `.workflow/_index.md`, confirmed tests green

## Verify
- `./run-tests.sh` -> 518 before, **528 after** (10 new tests), all passing. The Datadog grounding block appears at exactly four call sites (genWorkflow, genSubAgents, genAgentTeams, genClaudePrompt) and is absent from genAgentSDK; the Bug Fix `PROMPTS.investigator` inline mention is intact (1 occurrence, unchanged). `git diff --stat`: index.html +40/-1, tests.html +76/-1 - no unrelated edits.

## Outcome
Added a first-class "Datadog (metrics, logs, traces)" toggle to the MCP Integrations panel (default unchecked). When on, it emits an ORCHESTRATOR up-front grounding block (`datadogGroundingHint()`), shaped like the `consumeRecords` / `clarifyFirst` gate blocks and injected alongside them in the four format generators - so it fires for any workflow shape, including canned ones with no Planner or Investigator. The block self-gates on relevance ("would production telemetry materially inform this work?", which also covers documentation/validation of runtime behavior) AND Datadog availability, and is bounded to a point-in-time, plan-shaping read - the deep query stays with the step that owns the investigation. The Bug Fix inline Datadog mention is kept (no regression); full state round-trip (toggle / savePrefs / restorePrefs / clearCanvas-resets-to-false) mirrors `mcpCodeSearch` but default-off. Surface area: `index.html` (UI toggle + state wiring + the new function + four injection sites + a Help note) and `tests.html` (harness export, resetState hardening, a 10-test "Datadog grounding gate" suite).

## Built with (provenance)
Workflow: `Add Datadog MCP toggle` (Feature-style: Planner -> Implementer -> Reviewer, orchestrated in one session, with orchestrator test confirmation). Grounded by the `.workflow/_index.md` scan-then-open index. Baseline suite 518 green at kickoff.

## Links
- Work item: none (local task). Branch: main. PR: pending.
