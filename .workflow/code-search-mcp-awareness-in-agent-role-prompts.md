# Code search (MCP) awareness in agent role prompts

Work: make generated agent prompts aware a code-search MCP is available. Branch: main. Status: complete, uncommitted (awaiting director commit).

## Why and scope

The "Code search (MCP)" toggle already injected a standing `codeSearchHint()` block once per generated workflow (orchestrator-level), but each role's prompt body hardcodes a numbered exploration list (Glob, then Grep, then LSP) and never mentions the MCP, so a literal-minded agent following its role steps never reaches for it. This change surfaces, at the per-agent level, that a code-search MCP is available and what it uniquely offers: searching ACROSS repositories at once, which is how an agent reads the seams between systems (API contracts, shared schemas, producer/consumer pairs) that single-repo Grep and LSP cannot easily see.

This is an AWARENESS change, not a preference change: agents are told the tool exists and where it shines, never that it takes precedence over Glob/Grep/LSP. A follow-on tweak (director request) also reframed the existing code-search blocks so Glob/Grep/LSP read as COMPLEMENTARY to code search (used in addition, when appropriate), not as a second-string "fallback for when no MCP is connected."

Non-goals: removing any Glob/Grep/LSP guidance or capability; consolidating the role templates; touching genAgentSDK's per-agent injection; making prompts lighter. A bigger (riskier) refactor was explicitly deferred. (Note: the change is additive at the per-agent layer; it also reworded three existing standing/inline code-search blocks to the complementary framing - guidance preserved, relationship reframed, nothing removed.)

## Requirements

- R1: The system MUST surface code-search-MCP awareness per-agent only when the user's Code search (MCP) toggle is on.
  - Given the toggle is on and an in-scope agent, When a workflow is generated, Then the agent's section contains the awareness string. (test: "Code search step awareness" C1)
  - Given the toggle is off, When a workflow is generated, Then the awareness string is absent everywhere and the helper returns an empty string. (test: C3)

- R2: The awareness hint MUST be limited to the planning, implementing, and navigating roles, keyed on agentType.
  - Given an in-scope agentType (planner, architect, researcher, debugger, coder, backend, frontend, general), When the helper runs with the toggle on, Then it returns the awareness string. (test: C2)
  - Given an out-of-scope agentType (e.g. reviewer, tester, writer), When the helper runs with the toggle on, Then it returns an empty string. (test: C4)

- R3: The hint MUST be injected only at the six per-agent sites that already carry datadogStepHint; genAgentSDK MUST NOT receive it.
  - Given the toggle on, When each of genWorkflow, genSubAgents, genAgentTeams, genClaudePrompt is generated, Then the awareness string appears. (test: C1)
  - Given the toggle on, When genAgentSDK is generated, Then the awareness string is absent. (test: C5)

- R4: Every existing role-template Glob/Grep/LSP step MUST remain intact; the per-agent hint adds to, never replaces, the template's own steps.
  - Given a planner agent, When a workflow is generated with the toggle on OR off, Then the template's own `Use \`Grep\`` and `LSP workspaceSymbol` steps are still present. (test: C6)

- R7: The code-search blocks MUST frame Glob/Grep/LSP as complementary to code search, not as a fallback for when no MCP is connected.
  - Given the toggle on, When codeSearchHint() is generated, Then it frames Glob/Grep/LSP as usable alongside / in addition to code search and does not label them "Fallback when no" MCP. (test: "discover/browse/search/read flow and frame Glob/Grep/LSP as complementary")

- R5: The hint wording MUST be awareness-not-preference and MUST contain no em or en dashes.
  - Given the returned string, Then it contains no em dash, no en dash, and none of the words precedence/prefer/preferred. (test: C7)

- R6: The hint MUST be generation-only and never appear in the node-config display.
  - Given an in-scope agent and the toggle on, When classifyAgentPrompt runs, Then its display text omits the awareness string. (test: C8)

## Success criteria

- With the toggle on, an agent in any of the 8 in-scope roles sees, in its own section, that a code-search MCP is available and why it helps at cross-repo seams.
- With the toggle off, generated output is byte-identical to before this change.
- A maintainer can delete the per-agent hint by removing the helper and its six call sites with zero effect on the role templates themselves.

## Spec quality check

- [x] Each requirement is testable and unambiguous.
- [x] Scope is bounded (Non-goals stated).
- [x] No open clarifications remain (role set width and echo length signed off by director).
- [x] Every scenario names a verifying test.
- [x] Success criteria are measurable.

## Approach and decisions

- Mirrored the existing `datadogStepHint(node)` pattern exactly rather than inventing a new mechanism: a toggle-gated, agentType-gated helper returning a plain string, injected beside each existing datadogStepHint call. Chose this over editing the static PROMPTS templates because the templates cannot be conditionally gated on the toggle, and over strengthening only the standing codeSearchHint() block because that does not reach the per-agent step lists where a literal agent decides how to explore.
- Role set: all 8 candidate agentTypes (planner, architect, researcher, debugger, coder, backend, frontend, general), chosen over the Planner's conservative 5. The frontend<->backend boundary is the canonical API-contract seam, so dropping backend and frontend would remove the hint from exactly the roles on either side of a cross-repo contract. The hint is gated and cheap, and the director preferred coverage over leanness; redundancy with the standing block is acceptable and intended.
- Standing-block touch kept the fuller echo (director's call): both `codeSearchHint()` and `codeSearchStepHint()` name the seams/contracts benefit. Accepted minor duplication in service of emphasis.
- Awareness-not-preference framing throughout: no "use it first" or "takes precedence" language anywhere.
- Complementary-not-fallback reframe (director request): reworded four existing code-search blocks (codeSearchHint standing block, the Refine interview block, the Plan block, and the genAgentSDK comment banner) so Glob/Grep/LSP read as usable alongside code search and combinable with it, rather than only as a fallback for when no MCP is connected. The no-MCP case is preserved as a trailing clause; no capability or tool guidance was removed.

## Surface area (file -> role)

- index.html `CODE_SEARCH_STEP_ROLES` + `codeSearchStepHint(node)` (after datadogStepHint, before AGENT_TYPE_PROMPT_MAP): the new gated per-agent helper.
- index.html `codeSearchHint()` (the standing block): one added clause naming the cross-repo seams benefit; the former "Fallback when no MCP" sub-section reworded to the complementary "use alongside Glob/Grep/LSP" framing (recommended flow untouched).
- index.html Refine interview block (~4534), Plan block (~4641), and the genAgentSDK comment banner (~6521): the "fall back to Glob/Grep/LSP" lines reworded to the same complementary framing.
- index.html six injection sites: genWorkflow (sub-step + node), genSubAgents, genAgentTeams, genClaudePrompt (sub-step + node) - each a sibling line beside the existing datadogStepHint injection.
- index.html genAgentSDK: out of scope, intentionally no hint (matches datadogStepHint and codeSearchHint).
- tests.html export block: `window.codeSearchStepHint = codeSearchStepHint;` for harness reach; new `describe('Code search step awareness', ...)` suite (11 tests) after the Datadog step escalation suite.

## Task checklist

- [x] Add CODE_SEARCH_STEP_ROLES + codeSearchStepHint helper mirroring datadogStepHint.
- [x] Touch codeSearchHint() with the additive seams clause.
- [x] Inject at the six per-agent sites; skip genAgentSDK.
- [x] Export parity in tests.html.
- [x] Write the 11-test awareness suite.
- [x] Reframe the three "fallback" code-search blocks to complementary; tighten the codeSearchHint test to lock it.
- [x] Run ./run-tests.sh, all green.

## Verify

- Command: `./run-tests.sh` (headless Chrome over tests.html).
- Result: 624/624 passed. Baseline before this change was 613; +11 from the new suite; no regressions.

## Gotchas / non-obvious

- The phrase "Code search (MCP)" appears in BOTH `codeSearchHint()` (standing block, lead-in `> **Code search (MCP)** (cross-repo code search)`) and `codeSearchStepHint()` (per-agent, lead-in `Code search (MCP) is available. A code-search MCP (for example Sourcebot)`). Any test or future edit must assert on the function-specific lead-in, never bare "Code search (MCP)", to avoid cross-matching.
- The helper returns `''` (empty string), matching datadogStepHint, NOT `null` like the standing codeSearchHint(). Call sites test truthiness, so both work, but follow the datadogStepHint convention here.

## Outcome

Added a toggle-gated, agentType-gated per-agent helper (`codeSearchStepHint`) that injects code-search-MCP awareness into the 8 planning/implementing/navigating roles at the same six emission sites as datadogStepHint, plus a one-clause touch to the standing codeSearchHint() block naming the cross-repo seams benefit. Every existing role-template Glob/Grep/LSP step is intact, and per-agent output is unchanged when the toggle is off. A follow-on reframe reworded three existing code-search blocks (standing, Refine, Plan) so Glob/Grep/LSP read as complementary to code search rather than a no-MCP fallback - guidance preserved, relationship reframed. Verified by an 11-test awareness suite plus a tightened codeSearchHint test; full run 624/624 green.

## Built with (provenance)

Produced by the "Code search (MCP) awareness in agent role prompts" workflow (Feature Development preset): Planner -> Implementer -> Reviewer -> Tester, with a director sign-off checkpoint after planning. Grounded by reading the existing datadogStepHint pattern and the Datadog step escalation test suite in-repo.
