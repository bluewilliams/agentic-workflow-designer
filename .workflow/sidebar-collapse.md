# Collapsible sidebar sections with persistence

Workflow: sidebar-collapse. Branch: main. Status: finalized, committable.

```awd:record
{"slug": "sidebar-collapse", "status": "current", "date": "2026-07-03", "files": ["index.html", "tests.html"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

Every left-sidebar section header is a click toggle with a chevron (CSS ::before on an empty span, so h3.textContent stays clean); collapsing hides the section body via `.sidebar-section.collapsed > :not(.collapse-header){display:none !important}`. Collapsed state persists in localStorage `awd_sidebarCollapsed` (object of collapsed ids; absent = expanded, so default is all-expanded; try/catch on read and write, bad or non-object JSON degrades to expanded). An Expand All / Collapse All control sits above the first section (its wrapper is not a `.sidebar-section`, so it never self-decorates). Programmatic reveals auto-expand first: selectNode expands node-config inside its existing genuine-change guard before the instant scroll (the node-config-ux invariant holds by construction), and the empty-canvas preset link expands the presets section before its scroll. All 15 sections carry stable literal `data-collapse-id` keys. Expanded sections render exactly as before; the feature is invisible until used.

## Why and scope

The sidebar's length was an audited usability defect (Node Configuration measured ~2,600px below a 1,000px viewport fold across ~14 always-expanded sections). Collapsible sections with persistence let users shrink the sidebar to their working set. Non-goals: no section reordering, no responsive redesign, no changes to section content.

## Requirements

1. Every sidebar section header MUST toggle its section body on click, with a chevron indicating state; expanded sections MUST render exactly as today.
   - Given an expanded section, When its header is clicked, Then its body hides and the chevron flips. (Test: header click toggles collapsed and hides/shows the body)
   - Given a collapsed section, When its header is clicked, Then its body shows again. (Same test, second click)
   - Given the Workflow Name header's New Workflow button, When the button is clicked, Then the section does NOT toggle. (Test: interactive-child guard)
2. Collapsed state MUST persist across visits via localStorage; default MUST be all expanded.
   - Given a collapsed section, When the app re-inits, Then it renders collapsed. (Test: initSidebarCollapse re-applies persisted state)
   - Given absent or empty storage, When the app loads, Then all sections render expanded. (Test: default all-expanded)
   - Given bad JSON or non-object values, When loading, Then the app MUST NOT throw and degrades to expanded. (Test: bad-JSON resilience)
   - Given a toggle, When storage is written, Then loadCollapsedState reads it back; re-toggle removes the key. (Test: persistence round-trip)
3. An expand-all / collapse-all control MUST exist at the sidebar top with tooltips.
   - Given collapsed sections, When Expand All is clicked, Then all 15 expand and storage is `{}`. (Test: expand/collapse-all)
   - Given expanded sections, When Collapse All is clicked, Then all 15 collapse and persist. (Same test)
4. Every programmatic sidebar reveal MUST auto-expand its target section first.
   - Given a collapsed node-config, When a node is selected (genuine change), Then the section expands and configFields is visible before the scroll. (Test: selectNode auto-expand)
   - Given a collapsed presets section, When the empty-canvas preset link is clicked, Then the section expands first. (Test: preset-link path, driving the real inline onclick)
5. Section ids MUST be stable literals, not title-derived. (Test: 15 unique literal data-collapse-ids; control not a section)

## Success criteria

- A user can reduce the sidebar to only the sections they use, persisting across visits.
- Selecting a node always makes the config panel visible regardless of collapse state.
- Zero visual difference for users who never touch the feature (the 1340 pre-existing tests unchanged).

## Spec quality check

- [x] Each requirement testable and unambiguous
- [x] Scope bounded (Non-goals stated)
- [x] No open clarifications remain
- [x] Every scenario names a verifying test
- [x] Success criteria measurable

## Approach and decisions

- Boot-time header decoration + CSS child-hiding over DOM restructuring - zero visual change when expanded, no markup rewrite (Skeptic-verified against the real DOM: Workflow Name has a `.section-heading` wrapper, the other 14 a bare h3; the picker handles both).
- Chevron as CSS ::before on an empty prepended span, chosen over a literal glyph after the glyph polluted h3.textContent and broke an exact-match title test - the implementer caught and fixed its own regression mid-step.
- Storage shape: object of collapsed ids (absent = expanded) over an explicit per-section map - default-all-expanded falls out for free and Expand All is just `{}`.
- Auto-expand placed inside selectNode's existing `changed && id !== null` guard, before the visible-gated instant scroll - the node-config-ux invariant (change-gated, instant) holds by construction rather than by convention.
- Reveal inventory verified complete by the Skeptic (3 scrollIntoView sites total: node-config, preset link, helpJump - the last is help-modal-only and correctly excluded). appSource/uiContext conditional rows deliberately not auto-expanded (default-expanded covers first appearance).

## Surface area (file -> role)

- index.html: collapse CSS block (beside the .section-heading rules); `.sidebar-collapse-controls` markup above the first section; 15 `data-collapse-id` attributes; the collapse JS module (loadCollapsedState/saveCollapsedState/setSectionCollapsed/toggleSection/expandSection/expandAllSections/collapseAllSections/initSidebarCollapse, near the `$` helper); the selectNode auto-expand line; the preset-link inline-onclick expand; the initSidebarCollapse boot hook; one help-modal Canvas Tips bullet.
- tests.html: the "Collapsible sidebar sections" describe (10 tests) with mandated afterEach cleanup; exposure-line additions for the module's functions.

## Task checklist

- [x] Orchestrator grounding (node-config-ux matched: selectNode scroll must stay protected)
- [x] Plan the implementation (risk-first, resume-unit steps)
- [x] Skeptic review of the plan passes
- [x] Section headers toggle with chevron (stable literal ids)
- [x] localStorage persistence (awd_ key, try/catch, default expanded)
- [x] Expand all / Collapse all control with tooltips
- [x] Auto-expand reveal-path inventory + guards (node select, preset link, others found)
- [x] Help modal line
- [x] Tests: toggle, persistence round-trip, expand/collapse-all, default-expanded, every auto-expand path
- [x] Code review passes (materiality bar)
- [x] Full suite green via ./run-tests.sh
- [x] Finalize: record, index entry, timeline line, run report

## Verify

- `./run-tests.sh` -> PASS 1350/1350 (baseline 1340 + 10 feature tests; zero regressions). Run independently by the Implementer, the Tester, and the orchestrator.
- Content-lint grep clean; no em dashes; diff scope +95/-16 in index.html plus the test suite.

## Gotchas / non-obvious

- The collapse test suite MUST clean up (afterEach: selectNode(null) + expandAllSections + remove awd_sidebarCollapsed): a left-collapsed node-config puts display:none !important on configPanel children and contaminates visibility assertions in other suites.
- Do not assert the chevron via h3.textContent - it is a CSS pseudo-element by design.
- Textareas are wrapped by enhanceExpandableTextarea, so per-element getComputedStyle display checks hit the wrapper; assert the section's direct-child display contract instead.
- The 15 ids: workflow-name, requirements, workflow-context, default-model, repositories, repo-context-paths, add-nodes, presets, app-under-test, ui-context, workflow-management, mcp-integrations, memory-durable-record, run-reports, node-config.
- Low, tolerated (reviewer): expandSection persists even when already expanded (redundant write, not a hot path); stale storage keys for removed ids are tolerated and rebuilt by collapse-all.

## History

- 2026-07-03: created - built live by the first dogfood run of the designer's own generated workflow (by sidebar-collapse)
- 2026-07-03: History section and Grounds-on line added as the record-format v2.1 exemplar; no behavior change (by dogfood-run-fixes)

## Outcome

The sidebar is now collapsible per-section with a chevron, persistent across visits, with expand/collapse-all and guaranteed auto-expand on every programmatic reveal. index.html +95/-16 plus a 10-test suite; 1350/1350 green; uncommitted for the director's review. Both review gates passed on cycle 1.

## Built with (provenance)

Workflow `sidebar-collapse` (Feature Development preset, Sub-Agents format): Planner -> Skeptic review gate ("Plan sound?", max 3 cycles) -> Implementer -> Reviewer gate ("Review Passed?", max 3 cycles) -> Tester -> code output (no-commit delivery). Memory + durable record + ground-in-records ON; grounding matched node-config-ux and fed the planner's brief; models opus[1m] per node (run as `opus` - the [1M] variant is not expressible in the Task tool's model parameter). Run live by Claude (Fable) as orchestrator, dogfooding the designer's own generated prompt; both gates passed cycle 1; the planner's response channel failed twice (harness idle quirk) and the memory files carried the run - the protocol's redundancy was load-bearing, not ceremonial.

## Links

- Grounds on / touches: grounds on `.workflow/node-config-ux.md` (the selectNode change-gated instant-scroll invariant); amended no other records.

```awd:run
{"workflow": "sidebar-collapse", "repo": "agentic-workflow-designer", "steps": [{"slug": "planner", "status": "done"}, {"slug": "skeptic-review-planner", "status": "done"}, {"slug": "implementer", "status": "done"}, {"slug": "reviewer", "status": "done"}, {"slug": "tester", "status": "done"}], "gates": [{"slug": "plan-sound", "cycles": 1, "final": "Passed"}, {"slug": "review-passed", "cycles": 1, "final": "Approved"}], "notes": "Both gates cycle 1. Planner report channel failed twice (harness idle quirk); memory files carried the full plan and the run proceeded per the failure-handling craft. Implementer self-caught a chevron/textContent regression; Tester self-caught a wrapper-aware assertion fix. 1340 -> 1350 tests."}
```
