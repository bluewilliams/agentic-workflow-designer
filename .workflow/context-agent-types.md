# Context agent types: App Explorer and Design Analyzer become first-class

Workflow: context-agent-types. Branch: main. Status: finalized, committable.

```awd:record
{"slug": "context-agent-types", "status": "current", "date": "2026-07-03", "files": ["index.html", "tests.html", "README.md"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

App Explorer (`appExplorer`) and Design Analyzer (`designAnalyzer`) are first-class agent types in every registry: the type dropdown (16 types, read-only-explicit descriptions), `AGENT_TYPE_PROMPT_MAP` (-> `PROMPTS.appExplorer` / `PROMPTS.designSystemAnalyzer`), `AGENT_TYPE_TOOL_DEFAULTS` (Read/Grep/Glob/LSP/Bash - no Write or Edit, matching their read-only contracts), the researcher Skeptic lens, the OpenSpec `research` record group, and `CODE_SEARCH_STEP_ROLES` (they explore codebases; deliberately NOT in `DATADOG_STEP_ROLES` - code and design exploration is not telemetry-relevant). The App Under Test and UI Context sidebar sections reveal by TYPE (`agentType === 'appExplorer'` / `'designAnalyzer'`), with the legacy exact-template match kept as a fallback for older saves - an edited prompt no longer hides a section the node still needs. On the hidden-to-shown transition (only the transition, never every render), the revealed section auto-expands past the first-run collapse seed via `expandSection`; a user who later collapses it is never fought. The `test_automation` and `ui_component` presets and the Auto Workflow UI shape carry the new types. Advisor rule (h) suggests setting the App Source path when an App Explorer has none (a fresh Test Automation preset deliberately fires it until the path is set - the calibration pin asserts that one-suggestion lifecycle). The App Source / UI Context Explain rows name their summoning node type as the lever.

## Why and scope

The appExplorer and designSystemAnalyzer templates were smuggled aboard researcher-typed preset nodes: unreachable outside their presets, invisible in the type dropdown, and their sidebar sections were revealed by exact-template identity - so editing the prompt one character hid the App Under Test section while the node still needed it. Three stacked discoverability defects (unreachable template, fragile reveal, lever-less Explain rows), killed structurally by promotion to first-class types. Non-goals: no new templates (the two existing prompts are unchanged), no changes to the researcher type, no bespoke Skeptic lenses.

## Requirements

1. Both types MUST be complete registry citizens (dropdown, prompt map, tool defaults, lens, OpenSpec group, step-hint sets).
   - (Tests: registers both types with read-only-explicit descriptions (length 16); maps both types to their templates and resolves via getEffectivePrompt; tool defaults match the preset grants and exclude Write/Edit; skeptic lens: both types review under the researcher lens; step hints: both types get code search, neither gets Datadog; both types are report-shaped: no found-defect protocol block)
2. Sections MUST reveal by type, with the legacy template match as fallback.
   - (Tests: reveals the App Under Test section by TYPE even with an edited prompt (the old fragility); legacy fallback: a researcher-typed node carrying the pristine template still reveals (older saves))
3. A section the app reveals MUST NOT appear folded behind a first-run-collapsed chevron; the expand fires only on the hidden-to-shown transition.
   - (Test: a section revealed by the run auto-expands past the first-run collapse seed, once, never fighting the user)
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
- Transition-only auto-expand (module-level shown-state trackers beside render()): expanding on every render would fight a user who deliberately collapsed the section; expanding only on hidden-to-shown honors the sidebar-collapse programmatic-reveal principle without a persistent nag.
- Auto Workflow Shape 8's Design System Analyzer retyped along with the presets (judgment: same capability, same type - the wave-C precedent retyped auto-built analysis nodes too).
- Advisor rule (h) fires for a fresh test_automation preset BY DESIGN: the App Source path is the one input the preset cannot work without, so the calibration pin was migrated to assert the sharper contract (one suggestion, exact message, clears when the path is set) instead of blanket silence.
- Debugger judgment inherited unchanged; the old pre-web-tools debugger tool set is now exactly the App Explorer default, so the matches-ANY-default pristine rule treats it as pristine - the affected test fixture was migrated to a genuinely unowned set (deliberate, commented).

## Surface area (file -> role)

index.html: `AGENT_TYPES` (2 entries, read-only-explicit descs), `AGENT_TYPE_TOOL_DEFAULTS`, `AGENT_TYPE_PROMPT_MAP`, `ADVERSARY_LENS_BY_ROLE`, `OPENSPEC_ROLE_GROUP`, `CODE_SEARCH_STEP_ROLES`; `render()` reveal checks (type-first + legacy fallback) plus `_appSourceWasShown`/`_uiContextWasShown` transition trackers and the transition `expandSection` calls; `test_automation` + `ui_component` preset nodes and Auto Workflow Shape 8 retyped; `adviseWorkflow` rule (h); App Source / UI Context Explain rows (lever named); help modal context-types bullet. tests.html: "Context agent types" suite (13 tests) + 4 deliberate migrations (two AGENT_TYPES count pins 14 -> 16, the outdated-pristine fixture, the preset calibration pin's test_automation lifecycle). README.md: agent-type list gains Analyst (pre-existing omission, fixed in passing and declared), App Explorer, Design Analyzer.

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
- The transition trackers are module-level state: a render with zero explorer nodes resets them, so tests (and imports) that clear the canvas re-arm the auto-expand for the next genuine reveal.

## History

- 2026-07-03: created (by context-agent-types)
- 2026-07-03: selection-as-intent for app source writes - the App Source block stays read-only by default; an App Explorer granted Write/Edit becomes a NAMED exception (may modify the app source where the task requires, declared in handoff; every other step still read-only). Asymmetric by design: selection signals intent, absence never forbids (the suggestions ruling holds); memory-file writes untouched (separate protocol guarantee, test-pinned together) (by context-agent-types)

## Outcome

App Explorer and Design Analyzer are real agent types: summonable from the dropdown, read-only by name-adjacent description + tool floor + emitted contract, revealing their sidebar sections by type (edit-proof) with the section arriving expanded, advised when missing their one required input, and explained with levers named. 1492 -> 1505 tests.

## Built with (provenance)

Workflow `context-agent-types`: executed directly by Claude (Fable) as a worker fork under the director's ruling (promote the smuggled templates; names stay short role nouns with read-only front-and-center in descriptions; auto-expand on reveal; advisor rule for the missing App Source). Grounded on the wave-C analyst wiring and the agent-type-tool-defaults record; three coordinator refinements folded mid-build (reveal-transition auto-expand, advisor rule, read-only naming ruling).

## Links

- Grounds on / touches: grounds on `.workflow/prompt-overhaul-wave-c.md` (the Analyst-type wiring checklist), `.workflow/agent-type-tool-defaults.md` (registry + pristine-swap rules), `.workflow/sidebar-collapse.md` (programmatic-reveal principle); amended `.workflow/sidebar-collapse.md` (conditional sections join the auto-expand inventory) and `.workflow/agent-type-tool-defaults.md` (registry gains two types; the old debugger set is now owned).
- Branch: main (uncommitted delivery for the director).
