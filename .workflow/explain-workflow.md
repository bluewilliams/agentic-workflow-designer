# Explain This Workflow: per-part anatomy of what the generators emit and why

Branch: main. Status: current.

```awd:record
{"slug": "explain-workflow", "status": "current", "date": "2026-07-02", "files": ["index.html", "tests.html", "README.md"], "verify": ["./run-tests.sh", "grep -c 'anatomy vs generated output agreement' tests.html"], "superseded_by": null}
```

## Current behavior

Two Explain surfaces make prompt composition inspectable. The Explain button beside Copy opens the workflow-level anatomy of the currently selected format: every orchestrator block (execution model, requirements, plan, delivery, all MCP/grounding/clarify hints, memory and durable-record protocols, decision section, run-report directive) as an emitted-or-skipped row with the gating reason and a snippet. "Explain step" sits beside it in the prompt actions and shows the per-step anatomy for the node selected on the canvas (agent, decision, parallel, output; a guard toast nudges when nothing explainable is selected): role-template provenance via classifyAgentPrompt, the three tool lines, per-step memory, the Datadog/code-search/record-handoff hints, Agent Context, dependencies, gates, delivery discipline, and closing order. Row statuses are derived by calling the same helpers the generators call; every emitted row carries a probe (a verbatim substring of the generated text) and agreement tests assert probes against real generator output, so the explainer cannot drift from what is actually emitted. The SDK format collapses to a single deliberate-exclusion note (owner does not use it). The whole feature is a removable block, inert until clicked.

## Why and scope

The 2026-07-01 designer-wide audit found a dozen invisible-composition bugs: parts silently missing (fields dropped from parallel branches), silently wrong (a General agent running the researcher template), or silently contradictory (memory writes ordered from Write-less agents). Each was invisible because nobody could see WHICH parts a generated prompt was composed of, or why a part did or did not fire. This panel is the permanent antidote and a teaching surface for the on-ramp audience.

## Key decisions

- **The agreement invariant is the feature's warranty.** A row's status comes from CALLING the real helper (a part is emitted iff datadogStepHint/toolScopeNote/closingOrderNote/... returns text for this node and state) - conditions are never re-implemented. Emitted rows carry a probe: the first meaningful line of the helper's live text, container prefixes stripped (explainProbe), so it stays a verbatim substring at any nesting level. The agreement tests generate real output for a matrix of nodes and toggles across the three core formats and assert every probed row appears; skipped-part absence is asserted with test-owned literals. If a generator changes, the tests fail and the explainer must move in lockstep - by construction it cannot lie.
- **Reasons name the actual gate**: "Datadog toggle off" vs "role 'adversary' not in DATADOG_STEP_ROLES (plan-shaping roles only; implementers inherit telemetry via the orchestrator brief)"; "parallel-fork sibling - the fork header conveys the dependency, the line is deliberately omitted"; template provenance distinguishes auto-applied / unmodified / user-edited / foreign-template (reusing classifyAgentPrompt states).
- **Bread-and-butter depth, SDK note**: full row taxonomies for Workflow, Sub-Agents, and Agent Teams (each format's true emission order and format-specific probes); Claude.ai reuses the agent rows with tool lines marked not-applicable and probe-free rows where its section shapes differ; the SDK returns one static row naming the hard tools param and the deliberate per-step hint exclusion.
- **UI reuses the existing modal language**: a third help-overlay modal (zero new CSS), Esc/backdrop/button close wired into the shared Escape chain ahead of the validation overlay; entry points are two adjacent buttons in the prompt actions - Explain (workflow level) and Explain step (selected node; guard-and-toast rather than disabled-state plumbing). A config-panel button was tried first and moved by owner call: sitting under the tool chips it read as a stray tool. Everything typeof-guarded so removing the block leaves the app intact.
- **Node-level vs workflow-level split**: per-step parts on the node's Explain, orchestrator blocks on the format-tab Explain, each modal footer pointing at the other - one part never appears in both, so the two views compose rather than duplicate.

## Changes

- index.html: EXPLAIN THIS WORKFLOW removable block after closeValidation (explainProbe/exRow/explainIsParallelChild, explainAgentNode/explainDecisionNode/explainParallelNode/explainOutputNode/explainNode/explainWorkflow, showExplain/closeExplain, EXPLAIN_FORMATS); explainOverlay modal HTML; Explain button in the prompt actions; Explain-this-step button + binding in updateConfig; Escape-chain branch; help-modal section.
- README.md: Explain This Workflow section.
- tests.html: "Explain this workflow (anatomy vs generated output agreement)" describe (8 tests) + exposure additions.

## Verification

- 1291 -> 1299 (+8), full suite green. Content-lint grep exit 1. Agreement matrix covers: researcher missing LSP with all toggles off and all on, across the three core formats with absence literals; role-gating (Skeptic vs Datadog set, writer vs code-search set); template provenance states; decision/parallel/gated-agent/fork-sibling rows against generated sections; workflow-level rows flipping with memory/durable/grounding/clarify toggles; SDK single-note collapse; output-node delivery driver; modal DOM render from both entry points in the headless rig.

## Task checklist

- [x] Study true emission order of all three core generators + helper gates
- [x] Pure core: exRow/explainProbe + agent/decision/parallel/output row builders per format
- [x] explainWorkflow orchestrator rows with per-toggle reasons; SDK single note
- [x] Agreement invariant: statuses from real helper calls; probes from live text
- [x] UI: modal (reused classes), adjacent Explain / Explain step buttons in prompt actions (config-panel placement tried, moved by owner call), Escape chain
- [x] Tests: agreement matrix, role gating, provenance, decision/parallel, workflow toggles, modal DOM
- [x] Docs: README section + help modal
- [x] Suite green (1299/1299); content-lint grep clean; no em dashes

## Update (same day): inline full text + input-node anatomy

Two owner-driven refinements after first use. (1) Truncated rows now unfold IN PLACE: exRow carries the full emitted text, and rows whose full text meaningfully exceeds the probe render as a native details/summary - snippet plus a [view full] affordance expanding to a scrollable block inside the modal (owner call: inline, consistent with how everything else in the modal reads; no second surface). The Agent Prompt's full template - the original ask - is one click away without leaving the anatomy. (2) Input nodes are now explainable (the guard previously toasted them away): explainInputNode() rows for Requirements (present/empty, and where they land per format - Sub-Agents injects them into every agent prompt), Source framing (URL-only resolve-once vs story/PRD derive-requirements framing vs plain text), and Atlassian ticket fetch - all statuses from the same helpers the generators call (requirementsBlock / inputSourceHint / atlassianTicketFetchHint), preserving the agreement invariant. Guard toast simplified to "Select a step on the canvas first". +3 tests (input agreement incl. URL-only branch, inline details rendering). 1300 -> 1303.

- [x] exRow full text + details/summary inline expansion (escHtml both layers)
- [x] explainInputNode (requirements / framing / Atlassian) + dispatch + guard relaxed
- [x] Tests: input rows agree with real output; empty-story skip; details unfold; suite green; content-lint

Follow-on within the same update: the unfold check missed single-line rows truncated at the 120-char snippet cap (a long one-line Requirements had an unreachable tail) - expandable now also triggers on a truncated snippet; and the workflow-level Memory/Durable protocol rows carried header-only literals as their text, so they had nothing to unfold - they now pass the real protocol text (genMemoryProtocol / genSingleAgentMemoryProtocol / genDurableRecordProtocol; the sub-agent memory header stays literal, its block is inline in the generator). Probes unchanged, agreement tests green. +1 test (workflow-level unfold: requirements tail + shared.md reachable). 1303 -> 1304.

- [x] Truncated-single-line unfold + full protocol text on workflow-level rows

## Update (same day): The orchestrator capstone row

Owner asked where the orchestrator lives in the anatomy - and the honest answer was "everywhere, unlabeled": the workflow-level Explain IS the orchestrator's brief, but nothing said so. explainWorkflow now leads with a capstone row, "The orchestrator": not a canvas node, it is <orchestratorIdentity(format)> - the top-level agent this entire document programs; every row below is part of its brief, and the canvas nodes are the steps it <spawns as sub-agents / delegates as team lead / plays in turn / executes in sequence>. The reason line summarizes its duties in THIS configuration (gate count, delivery ownership, durable-record maintenance or memory anchoring when toggled, run-report emission) - all derived from the same state the generators read. Empty snippet by design (conceptual row; nothing verbatim to probe, so the agreement matrix is untouched). +1 test pinning the row, its format verbs, and duty toggling.

- [x] Capstone row + per-format execution verb + configuration-derived duties
- [x] Test: leads the rows, duties reflect toggles/gates; suite green; content-lint

## Update (same day): the orchestrator run plan

Owner asked for something dynamic that makes the orchestrator row as browseable as the rest. New pure builder orchestratorRunPlan(format) derives the itinerary the orchestrator will actually follow from the SAME sources the generators read: conditional kickoff items (Atlassian resolve-once when URLs present, the .workflow grounding scan when consumeRecords, the bounded Datadog read when mcpDatadog, record creation + up-front checklist when durable), an execution sequence that mirrors the generators' emitted-set walk exactly (format-appropriate verb per step, parallel groups launched once with their strategyJoinPhrase, gate lines after their feeders with the generators' label fallbacks and revise routing + cycle caps, deduped per gate), and close-out (delivery winner, record finalize when on, the awd:run fence always). The capstone row's snippet is now a summary line (N steps, P parallel groups, G gates with worst-case +K revise spawns, critical path D - D from the revise-edge-excluded DAG via isReviseBackEdge, cycle-guarded; zero clauses omitted, critical path shown only when it differs from N) and [view full] unfolds the numbered plan. Built by hand rather than exRow so probe stays '' - the plan is synthesized prose, and the agreement matrix must never grep generated output for it (all matrix tests guard on probe truthiness, verified). One test-authoring correction: consumeRecords defaults ON, so a fresh workflow legitimately has a kickoff item - the no-kickoff assertion now turns the toggle off first (test fixed, not code). +3 tests. 1311 -> 1314.

- [x] orchestratorRunPlan builder (kickoff / execution walk / close-out / summary numbers)
- [x] Capstone row wiring (snippet=summary, full=plan, probe='' - no agreement leakage)
- [x] Tests: topo+gate order, parallel once + join phrase + critical path, toggle tracking, DOM unfold, format verbs
- [x] Help modal clause; suite green; content-lint
