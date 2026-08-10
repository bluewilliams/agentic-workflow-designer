# Context agent types: App Explorer and Design Analyzer become first-class

Workflow: context-agent-types. Branch: main. Status: finalized, committable.

```awd:record
{"slug": "context-agent-types", "status": "current", "date": "2026-07-03", "files": ["index.html", "tests.html", "README.md"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

App Explorer (`appExplorer`) and Design Analyzer (`designAnalyzer`) are first-class agent types in every registry: the type dropdown (16 types, read-only-explicit descriptions), `AGENT_TYPE_PROMPT_MAP` (-> `PROMPTS.appExplorer` / `PROMPTS.designSystemAnalyzer`), `AGENT_TYPE_TOOL_DEFAULTS` (Read/Grep/Glob/LSP/Bash - no Write or Edit, matching their read-only contracts), the researcher Skeptic lens, the OpenSpec `research` record group, and `CODE_SEARCH_STEP_ROLES` (they explore codebases; deliberately NOT in `DATADOG_STEP_ROLES` - code and design exploration is not telemetry-relevant). The App Under Test and UI Context sidebar sections are ALWAYS PRESENT (like Repositories) - no reveal machinery exists: each carries a one-line consumer hint naming the steps that use it (App Explorer / Design Analyzer), both join the first-run collapse seed as visible one-line advertisements, and emission still gates purely on content (path set / notes non-empty). The `test_automation` and `ui_component` presets and the Auto Workflow UI shape carry the new types. Advisor rule (h) suggests setting the App Source path when an explorer CONSUMER has none - the consumer set is type OR either explorer template text, so legacy researcher-typed carriers get the same nudge (a fresh Test Automation preset deliberately fires it until the path is set - the calibration pin asserts that one-suggestion lifecycle). Advisor rule (i) covers the inverse mismatch: an App Source path set with NO consuming step (no appExplorer-type node and neither explorer template text on any node) draws a stale-config suggestion - it never gates emission (config binds; the rule only surfaces the mismatch), and (h)/(i) are mutually exclusive by construction. The App Source / UI Context Explain OFF rows give configuration guidance (set the path or notes in the named sidebar section; the consuming step types are named). The TYPE's default template (`PROMPTS.appExplorer`) is now a general application cartographer - structure and entry points, surfaces, navigation and data flow, public contracts, conventions, gaps - with UI selector mining as one explicitly-named branch; the original selector-heavy prompt is frozen byte-identical as `PROMPTS.uiAppExplorer` and carried by the `test_automation` preset (the reveal fallback matches BOTH texts; a node carrying the frozen preset text keeps it on type change, the bugTester precedent). The App Source block's access is EXPLICIT configuration: an Access selector (`appSourceAccess`, read-only default, persisted via prefs with absent-key = readonly, reset by New Workflow) chooses between the byte-identical READ-ONLY contract and an unconditional writable-by-deliberate-configuration contract (modifications declared in the handoff; steps with no cause to modify still treat it as read-only) - no emitted contract consults tool selections; tools are pure suggestions everywhere.

## Why and scope

The appExplorer and designSystemAnalyzer templates were smuggled aboard researcher-typed preset nodes: unreachable outside their presets, invisible in the type dropdown, and their sidebar sections were revealed by exact-template identity - so editing the prompt one character hid the App Under Test section while the node still needed it. Three stacked discoverability defects (unreachable template, fragile reveal, lever-less Explain rows), killed structurally by promotion to first-class types. Non-goals: no changes to the researcher type, no bespoke Skeptic lenses. (The original no-new-templates non-goal was lifted the same day by the director's template-split ruling - see History.)

## Requirements

1. Both types MUST be complete registry citizens (dropdown, prompt map, tool defaults, lens, OpenSpec group, step-hint sets).
   - (Tests: registers both types with read-only-explicit descriptions (length 16); maps both types to their templates and resolves via getEffectivePrompt; tool defaults match the preset grants and exclude Write/Edit; skeptic lens: both types review under the researcher lens; step hints: both types get code search, neither gets Datadog; both types are report-shaped: no found-defect protocol block)
2. The App Under Test and UI Context sections MUST be always-present with consumer hints; a collapsed section stays visible.
   - (Test: App Under Test and UI Context are always-present sections with consumer hints (no summoning node required))
3. Explain OFF rows MUST give configuration guidance naming the section and its consumers.
   - (Test: Explain OFF rows give configuration guidance naming the section and its consumers)
4. A set App Source with no consuming step MUST draw the advisor's stale-config suggestion, mutually exclusive with rule (h), never gating emission.
   - (Test: advisor rule (i): a set App Source with no consuming step draws the stale-config suggestion; rules (h) and (i) are mutually exclusive)
4. Presets and the auto-builder MUST carry the new types; pristine type-swap MUST work.
   - (Tests: the test_automation and ui_component presets carry the new types; pristine type-swap: researcher defaults follow the node to App Explorer)
5. The advisor MUST point a fresh user at the missing App Source, and only then.
   - (Tests: advisor rule (h) ON/clear lifecycle; migrated calibration pin asserting all other presets stay silent and test_automation carries exactly the one setup pointer that clears when the path is set)
6. Explain OFF rows MUST name the summoning type as the lever. (Test: Explain OFF rows name the summoning node type as the lever)

## Success criteria

- A user can summon an App Explorer or Design Analyzer from the type dropdown like any other role, and the section it needs appears open and ready.
- Editing either node's prompt never hides its sidebar section.
- A fresh Test Automation preset tells the user the one thing it needs (the app path) and goes quiet once told.

## Spec quality check

- [x] Each requirement testable and unambiguous
- [x] Scope bounded (Non-goals stated)
- [x] No open clarifications remain (director rulings: names stay short role nouns, read-only lives in descriptions + tools + contracts; auto-expand on reveal transition; advisor rule scoped to appExplorer only)
- [x] Every scenario names a verifying test
- [x] Success criteria measurable

## Approach and decisions

- Mirrored the Analyst-type wiring checklist (wave C) registry by registry rather than inventing a new promotion path - the grounding record enumerated every surface a type touches.
- Researcher Skeptic lens for both (no bespoke lenses): their outputs are findings-with-sources, exactly the failure mode the researcher lens critiques (grounding in real sources). Test-pinned as equality with the researcher critic prompt.
- DATADOG_STEP_ROLES deliberately excludes both: code and design exploration is not telemetry-relevant; over-hinting is noise.
- Reveal keeps the legacy exact-template fallback so pre-promotion saves and imports (researcher-typed nodes carrying the pristine templates) still reveal their sections.
- Transition-only auto-expand (module-level shown-state trackers beside render()): expanding on every render would fight a user who deliberately collapsed the section; expanding only on hidden-to-shown honors the sidebar-collapse programmatic-reveal principle without a persistent nag. (Machinery deleted later the same day - see the always-visible History entry.)
- Always-visible over conditional reveal (director discovery ruling): summon-to-unlock was backwards - a user who would benefit from an App Explorer could never learn the capability exists by scanning the sidebar, and no one creating a workflow intuitively knows a node type unlocks a section. The collapse feature obviated hiding (a collapsed section is a visible one-line advertisement at zero cost), so the entire reveal apparatus (type checks, legacy template fallback's reveal duty, transition trackers, transition auto-expand) was deleted; consumer hints in each section body carry the discovery link in the opposite, findable direction.
- Auto Workflow Shape 8's Design System Analyzer retyped along with the presets (judgment: same capability, same type - the wave-C precedent retyped auto-built analysis nodes too).
- Advisor rule (h) fires for a fresh test_automation preset BY DESIGN: the App Source path is the one input the preset cannot work without, so the calibration pin was migrated to assert the sharper contract (one suggestion, exact message, clears when the path is set) instead of blanket silence.
- Debugger judgment inherited unchanged; the old pre-web-tools debugger tool set is now exactly the App Explorer default, so the matches-ANY-default pristine rule treats it as pristine - the affected test fixture was migrated to a genuinely unowned set (deliberate, commented).

## Surface area (file -> role)

index.html: `AGENT_TYPES` (2 entries, read-only-explicit descs), `AGENT_TYPE_TOOL_DEFAULTS`, `AGENT_TYPE_PROMPT_MAP`, `ADVERSARY_LENS_BY_ROLE`, `OPENSPEC_ROLE_GROUP`, `CODE_SEARCH_STEP_ROLES`; `render()` carries a comment marking App Under Test / UI Context as always-present (all reveal machinery deleted); both sections' markup lost display:none and gained consumer-hint lines; `test_automation` + `ui_component` preset nodes and Auto Workflow Shape 8 retyped; `adviseWorkflow` rules (h) and (i - stale App Source, inverse of h, mutually exclusive); App Source / UI Context Explain rows (lever named); help modal context-types bullet. tests.html: "Context agent types" suite (13 tests) + 4 deliberate migrations (two AGENT_TYPES count pins 14 -> 16, the outdated-pristine fixture, the preset calibration pin's test_automation lifecycle). README.md: agent-type list gains Analyst (pre-existing omission, fixed in passing and declared), App Explorer, Design Analyzer.

## Task checklist

- [x] Ground on the analyst-type wiring (wave C record) and agent-type-tool-defaults record
- [x] Wire both types through every registry
- [x] Reveal by type + legacy fallback
- [x] Transition-only auto-expand past the first-run collapse seed
- [x] Presets + auto-builder retyped
- [x] Advisor rule (h) + calibration migration
- [x] Explain lever rows + help modal + README
- [x] Tests: 13 new + 4 deliberate migrations
- [x] Full suite green via ./run-tests.sh
- [x] Finalize: record, index entries, timeline lines, sidebar-collapse + agent-type-tool-defaults amendments

## Verify

- `./run-tests.sh` -> PASS 1505/1505 (baseline 1492 + 13 new; 4 pins migrated deliberately, none weakened; zero regressions).
- The private hygiene grep (CLAUDE.local.md, not committed) -> exit 1 on all changed files. No em dashes in additions.

## Gotchas / non-obvious

- `initSidebarCollapse` decorates headers ONCE at boot - re-running it in a test double-binds the header click handlers (a click then toggles twice, a net no-op) and corrupts later suites. Simulate collapsed state with `setSectionCollapsed` instead.
- The old pre-web-tools debugger tool set (Read/Bash/Grep/Glob/LSP) is now exactly the App Explorer default: nodes carrying it pristine-swap on type change by the matches-ANY-default rule. Intended (the rule's universe grew), but surprising if you expected "matches nothing".
- The transition trackers are module-level state: a render with zero explorer nodes resets them, so tests (and imports) that clear the canvas re-arm the auto-expand for the next genuine reveal. (Historical: trackers deleted the same day with the reveal machinery.)

## History

- 2026-07-03: created (by context-agent-types)
- 2026-07-03: selection-as-intent for app source writes - the App Source block stays read-only by default; an App Explorer granted Write/Edit becomes a NAMED exception (may modify the app source where the task requires, declared in handoff; every other step still read-only). Asymmetric by design: selection signals intent, absence never forbids (the suggestions ruling holds); memory-file writes untouched (separate protocol guarantee, test-pinned together) (by context-agent-types)
- 2026-07-03: advisor rule (i) - the inverse of (h): a set App Source with no consuming step draws a stale-config suggestion (content-gated emission is untouched; the rule surfaces the mismatch); mutually exclusive with (h) by construction, test-pinned (by context-agent-types)
- 2026-08-07: director-requested machinery audit, five fixes - (1) appSourceBlock's exploration guidance is now addressed to the steps that do exploration/test authoring, with a closing line binding every other step to the access contract only (the block rides every step in every format by design; the prose now says who each part is for); (2) uiContextBlock gained a framing line (user-provided constraints, any platform - web/mobile/desktop, authoritative for UI decisions, validate-then-honor) instead of emitting bare notes; (3) SDK bug fixed: the app_source_path comment hardcoded READ-ONLY and ignored the Access selector - it now reflects writable configuration; the ui_context comment names all UI consumers, not just Design Analyzer; (4) sidebar UI Context copy and placeholder broadened beyond web (Compose Material3 / SwiftUI examples); (5) OpenSpec export now forwards App Source (path/branch/access posture) and UI Context (newline-collapsed) in openSpecContextBlock - a test-automation schema no longer silently loses its app path. Empty-state byte-identity preserved everywhere. +4 tests, 1574 -> 1578 (by direct session)
- 2026-07-03: always-visible sections - the App Under Test / UI Context reveal machinery (type checks, legacy fallback reveal duty, transition trackers + auto-expand) deleted per the director's discovery ruling (summon-to-unlock was backwards; a collapsed section advertises, a hidden one cannot); consumer hints added to both section bodies; Explain OFF rows reworded to configuration guidance; first-run seed counts unchanged (both ids were already among the 15) (by context-agent-types)
- 2026-07-03: template split - the type default becomes a general application-cartographer prompt (expertise-first register); the original selector-mining text is frozen byte-identical as uiAppExplorer and owned by the test_automation preset; reveal fallback matches both texts; type descriptions/help/README generalized with UI mining as the named branch (director ruling: the selector prompt was the preset's specialization, not the role) (by context-agent-types)
- 2026-07-03: selection-as-intent SUPERSEDED same day by the explicit Access selector (director cohesion ruling: zero selection-consulting contracts) - appSourceWriteGranted deleted; the App Source block now keys on the appSourceAccess config (readonly default byte-identical, writable unconditional on tools, declared-in-handoff); tools return to pure suggestions everywhere; memory-write guarantee unchanged (by context-agent-types)
- 2026-07-03: app source auto-sync - pinned branch gets fetch/checkout/pull --ff-only with a no-force degradation clause; unpinned gets a safe current-branch ff-only sync; every exploration records the commit SHA explored (version provenance). Sync framed as maintenance, not modification - the read-only contract governs authoring (by context-agent-types)
- 2026-07-03: the test_automation preset's specialist node relabeled 'UI Explorer' (was 'App Explorer' - the label taught users the type name meant the narrow UI thing; director catch). Type name unchanged (by context-agent-types)
- 2026-07-03: AGENT_TYPES roster alpha-sorted by display name (display-only - everything keys on ids; suite confirmed zero order dependence). Director UX catch: the new types no longer read as bottom-of-list afterthoughts (by context-agent-types)
- 2026-07-04: advisor rule (h) extended to the shared consumer predicate (type OR template text) - the overnight audit confirmed legacy carriers were consumers for (i) but never earned the (h) nudge; the third state is closed (by explain-lever-audit)

## Outcome

App Explorer and Design Analyzer are real agent types: summonable from the dropdown, read-only by description + tool floor + emitted contract, revealing their sidebar sections by type (edit-proof, both template texts) with the section arriving expanded, advised when missing their one required input, and explained with levers named. The type default is a general cartographer template with the selector specialization frozen into the test_automation preset, and App Source access is an explicit read-only/writable selector rather than any tool consultation. 1492 -> 1511 tests across the unit's three rulings.

## Built with (provenance)

Workflow `context-agent-types`: executed directly by Claude (Fable) as a worker fork under the director's ruling (promote the smuggled templates; names stay short role nouns with read-only front-and-center in descriptions; auto-expand on reveal; advisor rule for the missing App Source). Grounded on the wave-C analyst wiring and the agent-type-tool-defaults record; three coordinator refinements folded mid-build (reveal-transition auto-expand, advisor rule, read-only naming ruling).

## Links

- Grounds on / touches: grounds on `.workflow/prompt-overhaul-wave-c.md` (the Analyst-type wiring checklist), `.workflow/agent-type-tool-defaults.md` (registry + pristine-swap rules), `.workflow/sidebar-collapse.md` (programmatic-reveal principle); amended `.workflow/sidebar-collapse.md` (conditional sections join the auto-expand inventory) and `.workflow/agent-type-tool-defaults.md` (registry gains two types; the old debugger set is now owned).
- Branch: main (uncommitted delivery for the director).
