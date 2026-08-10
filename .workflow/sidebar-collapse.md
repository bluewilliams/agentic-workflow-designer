# Collapsible sidebar sections with persistence

Workflow: sidebar-collapse. Branch: main. Status: finalized, committable.

```awd:record
{"slug": "sidebar-collapse", "status": "current", "date": "2026-07-03", "files": ["index.html", "tests.html"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

Every left-sidebar section header is a click toggle with a chevron (CSS ::before on an empty span, so h3.textContent stays clean); collapsing hides the section body via `.sidebar-section.collapsed > :not(.collapse-header){display:none !important}`. Collapsed state persists in localStorage `awd_sidebarCollapsed` (object of collapsed ids; absent = expanded; try/catch on read and write, bad or non-object JSON degrades to expanded). On FIRST boot (key absent), `initSidebarCollapse` seeds a curated state - every section collapsed except requirements and presets - and persists it, so the all-expanded default now applies only after storage degradation, never on a true first visit; an existing key (including `{}`) is never re-seeded, and `loadCollapsedState` semantics are untouched (the seed lives at init, added by sidebar-first-run). An Expand All / Collapse All control sits above the first section (its wrapper is not a `.sidebar-section`, so it never self-decorates). Programmatic reveals auto-expand first: selectNode expands node-config inside its existing genuine-change guard before the instant scroll (the node-config-ux invariant holds by construction), the empty-canvas preset link expands the presets section before its scroll. The App Under Test and UI Context sections are always present (their conditional reveal and transition auto-expand were deleted by context-agent-types the same day they were added - a collapsed section is a visible advertisement, so hiding earned nothing). All 12 sections carry stable literal `data-collapse-id` keys (15 originally; 2026-08-07 merges folded workflow-name into requirements, repo-context-paths into repositories, and ui-context into app-under-test - see History). Expanded sections render exactly as before; the feature is invisible until used.

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
- The 12 ids (since 2026-08-07): requirements, workflow-context, default-model, repositories, add-nodes, presets, app-under-test, workflow-management, mcp-integrations, memory-durable-record, run-reports, node-config.
- Low, tolerated (reviewer): expandSection persists even when already expanded (redundant write, not a hot path); stale storage keys for removed ids are tolerated and rebuilt by collapse-all.

## History

- 2026-07-03: created - built live by the first dogfood run of the designer's own generated workflow (by sidebar-collapse)
- 2026-07-03: History section and Grounds-on line added as the record-format v2.1 exemplar; no behavior change (by dogfood-run-fixes)
- 2026-07-03: first-boot curated seeding added at initSidebarCollapse (13 collapsed, requirements + presets open, persisted once; storage semantics untouched) - Current behavior updated in place, status stays current (by sidebar-first-run)
- 2026-08-07: two section merges (director-approved for approachability) - Workflow Name folded into Requirements as one "Workflow Name & Requirements" section (name is optional and derived FROM requirements, and both are touched on every new workflow; the New Workflow button moved UP into the Expand/Collapse All controls row, right-aligned - a global clear-everything action belongs with the global controls, and its exit freed the header for the full title; id stays `requirements` so the seed and the empty-canvas quick-start link work unchanged), and Repo Context Paths folded into Repositories as "Repos & Context Paths" (same setup moment: where the code lives and what agents must read there; the paths area keeps its own uppercase sub-label inside). 15 ids -> 13; first-boot seed now 11 collapsed + the same 2 open, one open section = the whole quick start. Stale keys for the removed ids linger harmlessly (absent section = no-op). Headings verified single-line at half sidebar width. Deliberately NOT merged: Memory/Durable Records with Run Reports (would visually recouple deliberately decoupled concerns). Workflow Context's bare "optional" label normalized to the "(optional)" convention of its siblings. Test pins migrated 15/13 -> 13/11; header-button guard test retargeted to the controls row (no section header carries an interactive control anymore) (by direct session)
- 2026-08-07: the floating Better-outcomes tip (MCP/LSP setup advice that sat BETWEEN Workflow Management and MCP Integrations) moved inside the MCP Integrations section directly under its heading - it now collapses with the section it advises instead of permanently occupying sidebar space (by direct session)
- 2026-08-07: third merge + heading cleanup - UI Context folded into App Under Test as "App & UI Context" (both are context for UI-flavored work; each half keeps an uppercase sub-label, `uiContextSection` survives as an inner div so the always-present pins hold), and the MCP Integrations heading dropped its cryptic "prompt hints" suffix for a body line that actually explains it (toggles add prompt hints, they install nothing). 13 ids -> 12, seed 10 collapsed + 2 open. Deliberately kept apart: Presets vs Add Nodes (quick-start focus vs editing tool) and Memory vs Run Reports (decoupled on purpose) - the merge campaign ends here (by direct session)
- 2026-08-07: two heading renames (director-requested) - "Repos & Context Paths" is now "Multi-Repo & Context Paths" with the "(optional)" suffix retired (the name carries the optionality; width bought back against wrap) and a description that tells single-repo in-repo launches to leave it empty (branch pinning named as the other reason to list a repo); "Add Nodes" is now "Node & Agent Palette" (the code called it a palette all along - palette-grid/renderAgentPalette - and the heading now advertises the Quick Patterns and Custom Agents groups it contains). Section ids unchanged (repositories, add-nodes) - renames are display-only (by direct session)
- 2026-07-03: the conditional App Under Test / UI Context sections joined the auto-expand inventory - they expand on their hidden-to-shown reveal transition so a type-revealed section never appears folded behind the first-run seed (by context-agent-types)
- 2026-07-03: that reveal-transition entry is superseded within the day - App Under Test / UI Context became always-present sections and the reveal machinery was deleted; the auto-expand inventory returns to selectNode + the preset link (by context-agent-types)

## Outcome

The sidebar is now collapsible per-section with a chevron, persistent across visits, with expand/collapse-all and guaranteed auto-expand on every programmatic reveal. index.html +95/-16 plus a 10-test suite; 1350/1350 green; uncommitted for the director's review. Both review gates passed on cycle 1.

## Built with (provenance)

Workflow `sidebar-collapse` (Feature Development preset, Sub-Agents format): Planner -> Skeptic review gate ("Plan sound?", max 3 cycles) -> Implementer -> Reviewer gate ("Review Passed?", max 3 cycles) -> Tester -> code output (no-commit delivery). Memory + durable record + ground-in-records ON; grounding matched node-config-ux and fed the planner's brief; models opus[1m] per node (run as `opus` - the [1M] variant is not expressible in the Task tool's model parameter). Run live by Claude (Fable) as orchestrator, dogfooding the designer's own generated prompt; both gates passed cycle 1; the planner's response channel failed twice (harness idle quirk) and the memory files carried the run - the protocol's redundancy was load-bearing, not ceremonial.

## Links

- Grounds on / touches: grounds on `.workflow/node-config-ux.md` (the selectNode change-gated instant-scroll invariant); amended no other records.

```awd:run
{"workflow": "sidebar-collapse", "repo": "agentic-workflow-designer", "steps": [{"slug": "planner", "status": "done"}, {"slug": "skeptic-review-planner", "status": "done"}, {"slug": "implementer", "status": "done"}, {"slug": "reviewer", "status": "done"}, {"slug": "tester", "status": "done"}], "gates": [{"slug": "plan-sound", "cycles": 1, "final": "Passed"}, {"slug": "review-passed", "cycles": 1, "final": "Approved"}], "notes": "Both gates cycle 1. Planner report channel failed twice (harness idle quirk); memory files carried the full plan and the run proceeded per the failure-handling craft. Implementer self-caught a chevron/textContent regression; Tester self-caught a wrapper-aware assertion fix. 1340 -> 1350 tests."}
```
