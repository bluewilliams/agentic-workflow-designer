# Run telemetry MCP sink (events to the harness that drives the run)

Context: direct session, director-requested the evening the MCP facade went public, for a headless bridge that boots the page, proxies the facade as MCP tools, and wants the run's events in-process. Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- Run Telemetry gains a sink: `telemetrySink` is `otlp` (default: the collector, exactly as before), `mcp` (one tool call per event to a tool the driving harness exposes), or `both`. `telemetryTool` names the tool; blank means "the tool the harness announces for run events". The two values persist in prefs, travel in team settings (adopted only at their defaults), ride the facade (`setOptions`, undo step, `catalog().telemetrySinks` and `catalog().telemetryEvents`), and show in the Explain row.
- `runTelemetryHint()` stays the single source for every format: with `otlp` the text is byte-identical to before; with `mcp` the transport is one tool call per event with the OTLP record as the tool input, no curl, no endpoint, no headers, and the fallback when the tool is absent is the memory log line and the run-report fence; with `both` the collector and the tool each get every event, and an absent tool leaves the collector in place. Telemetry never changes the work in any sink.
- One new event, `director.decision`: emitted only when a director answer changes what the run does or delivers (a waived step, an overridden gate, a failing criterion accepted, scope cut, a plan approved with modifications); a plain approval emits nothing. It is the live twin of the Director decisions record section (next unit of work).

## Why and scope

A harness that drives the designer already holds its MCP tools in the agent's session. Sending run events through one of those tools gives it every event the moment it fires, with no network path, no credentials in the prompt and nothing to poll, while the same events keep reaching a collector for everyone else. Scope: the sink and tool fields, the transport text, the event, the facade keys and catalog entries, docs. Non-goals: no per-keystroke logging (the event set stays bounded), no designer-side network call, no change to the record shape.

## Approach and decisions

- The record shape is unchanged across sinks: the tool input IS the OTLP record, so a harness and a collector see identical events. Rejected: a second, smaller event shape for the tool (two shapes drift).
- The sink is explicit configuration, never a tool-selection contract: it consults no tool chips and forbids nothing.
- Blank tool name delegates to the harness ("the tool it announces") rather than guessing a name, so the designer never bakes a product's tool name into a prompt.
- Three sidebar guards that pinned "no new control" and the persisted preference keys were migrated deliberately (controls 35 to 37, the key list, the control anatomy); they were frozen for runs that are finished.

## Verify

- `./run-tests.sh`: 2168 -> 2174 (OTLP sink unchanged and names no tool; MCP sink transport, fallback, no curl or headers, named and blank tool; both sinks; the select and the tool field, persistence and the unknown-value fallback; facade keys, validation, catalog and undo; team settings and the Explain row).
- Content lint clean; no em or en dashes.

## History

- 2026-11-06: created (by direct session) - sink, tool, transport text, director.decision event, facade keys, docs; three frozen guards migrated.
