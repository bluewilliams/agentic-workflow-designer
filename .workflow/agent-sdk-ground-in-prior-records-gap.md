# Agent SDK ground-in-prior-records gap

Work: give the Agent SDK exporter the consume-records (ground-in-prior-records) guidance it was missing. Branch: main. Status: complete, uncommitted (awaiting director commit).

## Why and scope

The toggle-wiring audit found that genAgentSDK emitted the durable-record WRITE side (it carries the durable-record protocol) but never the READ/ground side: when the "Ground in prior records" (consumeRecords) toggle is on, the four prose generators inject consumeRecordsHint, while genAgentSDK injected nothing. So an SDK export with the toggle on silently lost record grounding. This closes that asymmetry, additively.

Non-goals: changing the other four generators, refactoring genAgentSDK to call the shared consumeRecordsHint (the SDK deliberately hand-builds its own Python-comment banners), or touching consumeRecordsHint itself.

## Requirements

- R1: When consumeRecords is on, genAgentSDK MUST emit a ground-in-prior-records guidance banner; when off, it MUST NOT.
  - Given consumeRecords on, When genAgentSDK runs, Then the output contains the banner titled "Ground in prior committed records (if any)" plus the actionable specifics (.workflow/_index.md, prefer status: current, open only matched records, no-op on greenfield). (test: should include the consume-records grounding comment when consumeRecords is on)
  - Given consumeRecords off, When genAgentSDK runs, Then the banner is absent. (test: should omit the consume-records grounding comment when consumeRecords is off)

- R2: The change MUST NOT alter the other four generators or leak the SDK comment banner into them.
  - Given consumeRecords on, When each prose generator runs, Then it still contains the prose hint "Ground in prior committed records" and none contains the SDK `#`-banner form. (test: other generators unchanged)
  - Given consumeRecords on and the sdk format, Then the SDK output contains no prose blockquote marker "> **Ground in prior committed records (if any).**" (the SDK uses `#` comments). (test: no prose-hint leak)

- R3: The added block MUST follow the SDK's existing inline-banner convention and the repo's text discipline.
  - Given the added lines, Then they use the `# ── Title ──` banner style of the neighboring mcpAtlassian/mcpCodeSearch blocks, contain no em or en dash, use ASCII apostrophes, and name no provider/company. (test: the consumeRecords ON test also asserts no em/en dash; reviewer confirmed style + provider-neutrality)

## Success criteria

- An Agent SDK export generated with "Ground in prior records" on now tells its orchestrator to ground in prior committed records before the first step; with the toggle off the export is byte-identical to before.
- The SDK now covers consumeRecords the same way it already covers mcpAtlassian and mcpCodeSearch (inline Python-comment banner), removing the read/write asymmetry of the durable-record feature in the SDK.

## Spec quality check

- [x] Each requirement is testable and unambiguous.
- [x] Scope is bounded (Non-goals stated).
- [x] No open clarifications remain.
- [x] Every scenario names a verifying test.
- [x] Success criteria are measurable.

## Approach and decisions

- Hand-built an `if (state.consumeRecords) { ... }` Python-comment banner inside genAgentSDK, mirroring the existing inline mcpAtlassian and mcpCodeSearch SDK blocks, placed right after the mcpCodeSearch block and before the Conventions banner. Chose the hand-built banner over adding a `consumeRecordsHint('sdk')` call because the SDK exporter does not convert the markdown hints to comments - it builds its own `#`-comment banners - and routing the markdown helper through it would have been a larger, out-of-scope change. The duplication is consistent with how the SDK already handles the other two MCP toggles (a known, accepted SDK pattern; reducing that duplication is a separate future refactor).
- Distinguished the SDK output by its comment-banner FORM (`# ── Ground in prior committed records (if any)`), not by the title text: the prose hint also contains "Ground in prior committed records (if any)", so the `#`-banner vs `> **` blockquote prefix is what separates SDK from prose. (This corrected a wrong planning assumption that the prose omitted "(if any)".)

## Surface area (file -> role)

- index.html, genAgentSDK (~6557-6568): new gated `if (state.consumeRecords)` Python-comment banner block, between the mcpCodeSearch block and the Conventions banner. Nothing else in genAgentSDK or any other generator changed; consumeRecordsHint untouched.
- tests.html, existing "Export: genAgentSDK" describe: +4 tests (consumeRecords on contains the banner + specifics + no em/en dash; off omits it; no prose-blockquote leak in SDK; the four prose generators unchanged and free of the SDK banner).

## Task checklist

- [x] Ground in prior .workflow records; locate the SDK inline-banner convention and exact insertion point.
- [x] Insert the gated consumeRecords banner in genAgentSDK, matching neighbor style/width.
- [x] Add the 4 SDK tests in the existing genAgentSDK suite.
- [x] Run ./run-tests.sh, all green.

## Verify

- Command: `./run-tests.sh` (headless Chrome over tests.html).
- Result: 645/645 passed. Baseline before this change was 641; +4 from the new SDK tests; no regressions.

## Gotchas / non-obvious

- The prose consumeRecordsHint and the SDK banner share the title text "Ground in prior committed records (if any)". Tests that need to tell SDK from prose must key on the FORM - the SDK `# ──` comment banner vs the prose `> **...**` blockquote - not on the title substring.
- genAgentSDK reaches mcpAtlassian/mcpCodeSearch/consumeRecords by inline reimplementation, not by calling the shared hint helpers; the four prose generators do call the helpers. Keep that split in mind when changing any of these toggles.

## Outcome

Added a gated consume-records guidance banner to genAgentSDK so an Agent SDK export grounds in prior committed records when the toggle is on, matching how the SDK already handles the other MCP toggles. Purely additive (12 lines), gated, provider-neutral. Closes the read/write asymmetry the toggle-wiring audit surfaced. Verified by 4 new tests; full run 645/645 green. Remaining SDK gaps from the same audit (clarifyFirst, Datadog grounding/step, per-step code-search) are not addressed here.

## Built with (provenance)

Produced by the "Agent SDK ground-in-prior-records gap" workflow (Feature Development preset): Planner -> Implementer -> Reviewer -> Tester, run as sub-agents. Grounded in the repo's .workflow records (the gap was surfaced by the prior toggle-wiring audit). Note: the orchestrator created this record at finalize rather than at kickoff - a protocol-adherence gap noted during the run.
