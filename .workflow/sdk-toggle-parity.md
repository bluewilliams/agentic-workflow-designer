# SDK exporter: render the Clarify-first and Datadog-grounding toggles

Branch: main. Status: current.

## Why and scope

genAgentSDK silently dropped two workflow toggles: `clarifyFirst` and `mcpDatadog` produced no output at all in the SDK format (every other format renders them; the OpenSpec exporter at least toasts about silent no-ops). A pipeline author reading the generated script had no idea the workflow was configured to clarify requirements first or ground in production telemetry.

## Key decisions

- **Orchestrator-level banners only.** Both hints render as `# ── title ──` comment banners in the script header, through the SAME shared hint sources the prose formats use (`clarifyFirstHint()`, `datadogGroundingHint()`), wrapped via the existing `wrapComment` pattern the records block established (blockquote markers, bold, and backticks stripped - no markdown in Python comments). One new local helper `_sdkHintLines` does the strip+wrap for both.
- **Per-step hints stay OUT of SDK agent instructions - deliberately.** Mid-implementation, tests R3 ("Datadog step escalation") and C5 ("Code search step awareness") failed: they PIN the SDK exporter's exclusion from per-step hints. The rationale holds up: the SDK's `tools=[...]` param is hard enforcement and grants no MCP access, so a per-step "use the Datadog/code-search MCP" would be an un-executable instruction (the same contradiction class the memory-write-authorization fix removed). Reverted the per-step injection, kept the exclusion tests intact, and added a source comment at the injection site so the next person does not repeat the attempt.
- clarifyFirstHint's non-interactive branch already names SDK pipelines ("record the open questions as explicit assumptions... proceed"), so the banner is correct for headless runs without wording changes.

## Changes

- index.html: `_sdkHintLines` + two banner blocks in genAgentSDK (before the code-search block); explanatory comment at the per-agent instructions site.
- tests.html: "SDK toggle parity" describe - Datadog banner on/off, Clarify banner on/off, and per-step hints remain excluded (complementing R3/C5).

## Verification

- 1215 -> 1219 (+4). R3/C5 exclusion tests pass unchanged. Content-lint.

## Task checklist

- [x] Clarify-first + Datadog banners via shared hint sources (wrapComment pattern)
- [x] Per-step SDK injection attempted, caught by R3/C5, reverted with rationale comment
- [x] Tests: banners on/off + exclusion; suite green
