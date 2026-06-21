# Audit: Generated-Prompt Machinery (Agentic Workflow Designer)

Read-only audit. Evidence from grep/Read of `index.html` and `tests.html` at the current working-tree state. Generator ranges: `genWorkflow` ~6637-6805, `genSubAgents` ~6806-7063, `genAgentTeams` ~7064-7293, `genAgentSDK` ~7294-7585, `genClaudePrompt` ~7590-end.

## Bottom line

The four **prose** generators (Workflow, Sub-Agents, Agent Teams, Claude Prompt) are in lockstep - every shared hint helper is called consistently across all four, including the now-structural per-step durable-record cadence. **`genAgentSDK` is the sole divergence on every axis**: it hand-reimplements 10 helpers as inline Python comments and omits four toggle injections entirely. Backlog #2 (durable-record cadence) and #4 (SDK toggle gaps) are **confirmed still open**; one **new** finding - the SDK's inline consume-records text has already drifted below the shared helper, and no test catches it.

## Parity matrix

WF/SA/AT/CP all call the shared helpers. `genAgentSDK`: **inline** = reimplemented as `#` comments (drift risk); **MISSING** = absent.

| Feature / helper | WF | SA | AT | SDK | CP |
|---|---|---|---|---|---|
| executionModelDirective / orchestratorIdentity | ✓ | ✓ | ✓ | ✓ (sdk key) | ✓ |
| requirementsBlock / appSourceBlock / uiContextBlock / repoBlock | ✓ | ✓ | ✓ | **inline** (~7470-7512) | ✓ |
| deliveryBlock | ✓ | ✓ | ✓ | ✓ | ✓ |
| atlassianTicketFetchHint / atlassianGeneralHint | ✓ | ✓ | ✓ | **inline** (~7330-7353) | ✓ |
| codeSearchHint / consumeRecordsHint / rulesPathsHint / productDocsHint | ✓ | ✓ | ✓ | **inline** (~7354-7411) | ✓ |
| clarifyFirstHint | ✓ | ✓ | ✓ | **MISSING** | ✓ |
| datadogGroundingHint | ✓ | ✓ | ✓ | **MISSING** | ✓ |
| datadogStepHint (per-agent) | ✓ | ✓ | ✓ | **MISSING** | ✓ |
| codeSearchStepHint (per-agent) | ✓ | ✓ | ✓ | **MISSING** | ✓ |
| durable-record protocol | ✓ protocol | ✓ | ✓ | **degraded** (genDurableRecordComment) | ✓ |

## Findings by severity

### HIGH
1. **Live drift (new).** The SDK inline `consumeRecords` comment (~7365-7377) has already drifted below the shared `consumeRecordsHint` (1254-1267): it omits the "Grep the index, do not read it whole" scaling guidance and the supersede-on-modify bullet. Already a weaker subset - not hypothetical. *Fix:* generate the SDK comment by wrapping the shared helper text, or pin body-equivalence with a test.
2. **Missing clarify-first in SDK.** `clarifyFirstHint` (1276) explicitly names "an SDK pipeline" as the non-interactive case it handles, yet the SDK never receives it. *Fix:* inject a gated `# ──` clarify banner.
3. **Missing Datadog grounding + step in SDK.** `datadogGroundingHint` / `datadogStepHint` never fire; an SDK pipeline for a bug/regression with Datadog on silently loses telemetry grounding. *Fix:* inject gated Datadog banners (grounding + per-agent step).
4. **SDK durable-record cadence degraded.** `genAgentSDK` uses `genDurableRecordComment` (2926-2950), which collapses the enforced per-step KEEP-CURRENT beat (structural in `genDurableRecordProtocol` 2893-2898) to one prose clause (2943) - the cold-run-skips-cadence gap (backlog #2) never carried into the SDK. *Fix:* add the enforced "after each step, before the next: overwrite current-state, tick each completed item, do not batch to finalize" beat to the comment variant.

### MEDIUM
5. **Missing per-step code-search awareness in SDK.** `codeSearchStepHint` absent from the SDK agent loop (7421-7462). *Fix:* inject per-agent in the loop.
6. **SDK requirements/app-source/ui/repo hand-rolled** (7470-7512) with a "matching requirementsBlock's behavior" hand-assertion (7478) that will desync if those shared blocks change. *Fix:* call the shared block builders, or test equivalence.
7. **Test blind spots.** The consume/clarify/datadog parity suites assert "all FOUR exporters" (tests.html 1421, 1504, 1551, 1728, 1737, 1798, 1822) - SDK intentionally excluded, so its gaps produce no failure. The MCP leak-guard (1890-1941) ON positive controls assert only `win.genWorkflow` (1920-1925, 1935-1940). The rules/product-docs "all five" tests (4323-4343) assert only the section-title substring, not body equivalence - so SDK inline-body drift is silent. *Fix:* add SDK rows asserting intended behavior; make positive controls span all five; pin SDK-body parity.

## Top fixes (priority order)
1. Carry the enforced per-step cadence into `genDurableRecordComment` (HIGH, backlog #2).
2. Inject clarify-first + Datadog grounding/step + code-search-step into `genAgentSDK` (HIGH, backlog #4).
3. Kill the inline drift - route SDK banners through the shared helpers, or pin them with body-equivalence tests (HIGH).
4. Add SDK rows to the parity/leak test suites (MEDIUM) - so the matrix is pinned by tests, not reviewer memory.
5. Replace hand-rolled SDK requirements/app-source/ui/repo with the shared block builders, or test equivalence (MEDIUM).

**Every actionable fix concentrates on `genAgentSDK`** - the prose machinery (the four formats most users run) is healthy and consistent.
