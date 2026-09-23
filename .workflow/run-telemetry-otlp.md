# Run telemetry (OTLP logs): the orchestrator posts progress events

Context: no work item (direct session, director-requested: teams want to follow workflow runs in their observability platform; the first design had the designer posting, and the director redirected it to the RUN posting - the generated prompt instructs the orchestrator). Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- A **Run telemetry (OTLP logs)** toggle in the Run Reports section (default OFF, prefs-persisted) reveals four optional fields: endpoint URL, service name, user, tags. All five values live in `awd_prefs`.
- When ON, `runTelemetryHint()` renders ONE shared block that rides `pushSharedHints` into Workflow, Sub-Agents, Agent Teams, and Claude.ai, plus a comment banner in the Agent SDK format (rendered from the same function via `_sdkHintLines`). An Explain row names the endpoint source and service. OFF emits nothing, pinned per format.
- The block asks the orchestrator (in a team, the lead) to be the ONLY writer and to post one standard OTLP/HTTP JSON log record per event: `run.start`, `step.start`, `step.done`, `task.confirmed`, `gate.verdict` (with cycle), `verify.result`, `run.finalize` (with the awd:run summary), `run.failed`. Severity INFO, WARN for revise or blocked, ERROR for run.failed.
- Endpoint: the explicit URL, else the standard `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT` environment variable, else skip telemetry and say so once. `OTEL_EXPORTER_OTLP_HEADERS` is honored so credentials never enter the designer. Service defaults to `agentic-workflow-designer`. Identity (`user.email`): the explicit user, else the signed-in Claude Code account email when a status command or the environment plainly reports it (the facet Claude Code's own telemetry carries, so events join; the prompt forbids opening credential or token files to find it), else `git config user.email`, else `-`. `session.id` carries `CLAUDE_CODE_SESSION_ID`. Tags (`key:value, ...`) become attributes; malformed entries drop; every value is JSON-escaped.
- Discipline in the prompt: curl with `--max-time 5`, at most one retry, a failed post never changes the work, attribute values are short identifiers only (never requirements text, prompt bodies, file contents, or secrets). Platforms named explicitly: curl on macOS, Linux, and Windows 10+ (curl.exe or Invoke-RestMethod), shell-appropriate env syntax, seconds-times-1e9 timestamps where nanoseconds are unavailable.
- The designer itself makes no network call. Help modal and README document the feature.

## Why and scope

Progress visibility for teams, without the browser problems of a designer-side sender (CORS, mixed content, a page that today makes zero requests) and without depending on the tab being open. The run reports on itself, as the awd:run fence does. Vendor-neutral by construction: the payload is the OTel standard and the variables are the OTel standard, so any OTLP-compatible collector works. Scope: state, prefs, markup, one hint function with helpers, three injection sites, help, README, tests. Non-goals: no metrics (logs only), no designer-side sending, no per-step posting.

## Approach and decisions

- Run-side emission (rejected: designer-side POSTs) - no CORS or mixed-content constraints, works with the tab closed, one source of truth.
- Standard env var fallback (rejected: mandatory URL) - machines that already carry `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT` need zero configuration; the name is the OpenTelemetry specification's, not any vendor's.
- Identity chain with Claude account first (rejected: git email only) - joins to Claude Code's own telemetry facet; explicit override kept.
- Bounded event set mapped to memory-protocol moments (rejected: free-form logging) - no new ceremony, cardinality stays sane.

## Verify

- `./run-tests.sh`: 1750/1750 (OFF in all five formats + Explain skipped; ON: endpoint, default service, all events, headers var, platform line in all five; discipline phrases in the four prose formats; env-var fallback; identity chain and explicit user; service/tag parsing with JSON escaping; the record parses as OTLP JSON with the pinned attribute order; prefs round-trip and field panel visibility)

## History

- 2026-09-22: created (toggle + four fields, prefs, shared hint, SDK banner, Explain row, help, README, tests). 1741 -> 1748 (by direct session)
- 2026-09-22: review round (10 findings, all acted on) - the copy-time secret scan now covers the telemetry fields (a key in an endpoint query string trips the warning); severity is a placeholder carrying the OTLP mapping (9 INFO, 13 WARN, 17 ERROR) instead of a hard-coded INFO; field values are cleaned of backticks and asterisks at input, on restore, and in the hint (they broke markdown code spans and were stripped inside the SDK banner's JSON); the identity chain names only a plainly-reported account email and forbids opening credential or token files; tags drop reserved keys (the record's own attribute names) and duplicates so OTLP keys stay unique; OTEL_EXPORTER_OTLP_HEADERS values are percent-decoded per the specification; docs lead with generic OTLP collectors and keep vendors as examples (director asked for OTel-first); one trimmed endpoint accessor serves the hint and the Explain row; the events sentence composes from TELEMETRY_EVENTS; inputs use the house .story-input class. 1748 -> 1750 (by direct session)
