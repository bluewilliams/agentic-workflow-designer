# First-run experience: curated sidebar, quick start, derived workflow names

Workflow: sidebar-first-run. Branch: main. Status: finalized, committable.

```awd:record
{"slug": "sidebar-first-run", "status": "current", "date": "2026-07-03", "files": ["index.html", "tests.html"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

On first boot (no `awd_sidebarCollapsed` key), `initSidebarCollapse` seeds the collapsed state - every section collapsed except requirements and presets - and persists it, after which it is ordinary user state; an existing key (including `{}`) is never re-seeded, and `loadCollapsedState`'s absent-key = expanded semantics are untouched. The empty canvas is a two-step quick start (paste requirements or a Jira URL -> pick a preset - then copy your prompt); its requirements link expands and scrolls to the Requirements section exactly like the preset link, and the panel hides once nodes exist. The Workflow Name placeholder reads "optional - auto-named from your requirements", and when the name is empty every slug site (memory path, durable record path, export slug) derives the slug from the requirements text via the shared `deriveSlugFromStory`/`effectiveNameSlug` helpers - first 6 prose words after stripping URLs and Jira keys, `untitled` only when requirements are empty too - with the displayed paths updating live as requirements are typed. An explicit name always wins, byte-identically to the old behavior.

## Why and scope

A fresh visitor gets the full wall of 15 expanded sections and no guidance, which reads as "a lot of work to get a first workflow off the ground" - the quickest real path touches only Requirements and Presets. Derived names fix both the unstated optionality and the untitled.md collision. Non-goals: no section reordering, no changes to collapse storage semantics, no visual redesign, no behavior change when an explicit name is provided.

## Requirements

1. First boot only (`awd_sidebarCollapsed` key absent), the app MUST seed the collapsed state - every section collapsed except requirements and presets - persisted so it becomes normal user state. An existing stored key MUST never be re-seeded; `loadCollapsedState` semantics MUST NOT change (seeding at init only).
   - Given no stored key, When the app inits, Then 13 sections collapse, requirements + presets stay open, and the object persists. (Test: first boot (no saved key) seeds every section collapsed except Requirements and Presets, and persists the seeded object)
   - Given an existing key including `{}`, When the app inits, Then nothing is re-seeded and the stored value is preserved verbatim. (Test: an existing saved key (including empty {}) is never re-seeded on init)
2. Bad-JSON resilience MUST be unchanged: corrupted storage degrades to all-expanded without throwing.
   - Given bad or non-object JSON, When loading, Then no throw and all sections render expanded; the seed is gated on absent-key so it never fires. (Test: pre-existing bad-JSON resilience test, unchanged)
3. All existing auto-expand guarantees MUST stay intact.
   - Given a collapsed node-config, When a node is selected, Then it expands before the scroll; Given a collapsed presets section, When the preset link is clicked, Then it expands. (Tests: pre-existing selectNode auto-expand + preset-link tests, selector tightened to a[onclick*="presets"], assertions unchanged)
4. The empty-canvas state MUST be a two-step quick start whose requirements mention expands and scrolls to Requirements, hidden when nodes exist.
   - Given an empty canvas, Then both anchors render; Given a node, Then the panel hides. (Test: shows both quick-start anchors on an empty canvas and hides the panel once a node exists)
   - Given a collapsed Requirements section, When the requirements link is clicked, Then it expands first. (Test: the empty-canvas requirements link expands a collapsed Requirements section)
5. The Workflow Name placeholder MUST communicate optionality; no permanent label text. (Verified within the derived-slug/live-path suites via the placeholder text "optional - auto-named from your requirements")
6. Empty name -> slug derived from the requirements text; `untitled` only when both empty; all three slug sites share the derivation; displayed paths update live; explicit name always wins.
   - Given empty name + prose, Then all three sites derive the first-words slug. (Test: empty name + prose story derives a first-words slug at getMemoryPath, getDefaultArtifactPath, and serializeWorkflow.slug)
   - Given empty both, Then untitled. (Test: empty name + empty story falls back to untitled at all three sites)
   - Given punctuation-only story, Then untitled. (Test: empty name + punctuation-only story yields untitled (no usable prose to derive from))
   - Given a Jira-URL-only story, Then a non-untitled, non-colliding slug. (Test: empty name + a story that is only a Jira URL still derives a non-untitled, non-colliding slug)
   - Given an explicit name and any story, Then the name wins at all three sites. (Test: an explicit workflow name always wins over a non-empty story at all three sites)
   - Given an empty name, When requirements are typed, Then the displayed memory + artifact paths follow. (Test: validateStoryInput refreshes memoryPathDisplay.textContent and the artifact placeholder from the story)
   - Given an explicit name, When requirements are typed, Then the displayed path does not move. (Test: an explicit name pins the displayed path so typing requirements does not move it)
7. No cross-suite contamination from the collapse discipline or the first-boot seed.
   - (Tests: the collapse-suite afterEach discipline (expandAll + remove key) restores every section and cannot leak collapsed state; the harness boot normalization strips the first-boot seed so a non-collapse suite starts all-expanded)

## Success criteria

- A first-time visitor sees two open sections and a two-step hint instead of fifteen open forms, and can produce a prompt without touching anything else.
- Two unnamed workflows in the same repo can no longer collide on the same record or memory path.
- A returning user's saved collapse state and every existing behavior are untouched.

## Spec quality check

- [x] Each requirement testable and unambiguous
- [x] Scope bounded (Non-goals stated)
- [x] No open clarifications remain (both planner assumptions resolved at the plan gate)
- [x] Every scenario names a verifying test
- [x] Success criteria measurable

## Approach and decisions

- Derived slug: `deriveSlugFromStory(story)` strips URLs and Jira keys, takes the first 6 prose tokens, slugifies; a bare-URL-only story derives a URL slug rather than untitled (non-empty requirements should never collide on untitled); `effectiveNameSlug()` is the single derivation used by all three slug sites. Chose a new shared helper over editing `slugify` itself (slugify has other callers with different fallbacks - the `'workflow'` download names stay out of scope).
- First-boot seed lives at the TOP of `initSidebarCollapse`, gated on `getItem(SIDEBAR_COLLAPSE_KEY) === null`, building the seed from the live `data-collapse-id` DOM query (no hardcoded id list to drift) - `loadCollapsedState` semantics untouched by construction.
- Harness normalization: the test rig boots the iframe (which now seeds collapsed) BEFORE clearStorage/resetState, so the boot handler gains `win.expandAllSections()` - the plan's riskiest unknown (cross-suite visibility contamination), confronted first.
- The existing preset-link test selector tightens from `#emptyState a[onclick]` (first match, ambiguous once a second anchor exists) to `#emptyState a[onclick*="presets"]` - assertion unchanged, guarantee preserved.
- Requirements quick-start anchor mirrors the preset link's inline-onclick pattern: `expandSection('requirements')` then smooth-scroll to `storyInput`.
- Empty-state copy is a numbered two-step CTA; the old "or add nodes manually" clause was dropped to keep it focused (manual add unchanged on the canvas - the empty state is guidance only).
- Skeptic-verified (gate cycle 1): the harness-boot mitigation is sufficient for every suite ordering (the collapse suite manages its own key state, so the seed never fires inside it); the live-update path rides `storyInput`'s existing `oninput` and `updateMemoryPath` already refreshes the artifact-path display; `saveWorkflow` gates on a non-empty name, so the derived slug causes zero storage fragmentation; both planner assumptions accepted (deterministic 6-token derivation; bare-URL story derives a URL slug - more compliant than untitled).

## Surface area (file -> role)

index.html: `initSidebarCollapse` (first-boot seed block), `deriveSlugFromStory`/`effectiveNameSlug` (new helpers beside `slugify`), `getMemoryPath`/`getDefaultArtifactPath`/`serializeWorkflow` (repointed to the shared derivation), `validateStoryInput` (live `updateMemoryPath()` call), `#workflowName` placeholder, `#emptyState` two-step quick start. tests.html: harness boot handler (`expandAllSections()` after reset), preset-link selector tighten, new suites per requirement. Out of scope: the `getName() || 'workflow'` download-name sites.

## Task checklist

- [x] Orchestrator grounding (sidebar-collapse matched - amend planned; node-config-ux invariant inherited; slug sites unowned)
- [x] Plan the implementation (risk-first, resume-unit steps)
- [x] Skeptic review of the plan passes
- [x] First-boot curated seeding (only requirements + presets open; no re-seed on existing key)
- [x] Empty-canvas two-step quick start (requirements link expands + scrolls; hidden when nodes exist)
- [x] Name-input optionality placeholder
- [x] Derived slug from requirements at every slug site, live path updates, explicit name wins
- [x] Tests: seeding, no re-seed, bad-JSON unchanged, auto-expand unchanged, hint visibility, derived-slug matrix, placeholder, cross-suite contamination guard
- [x] Code review passes (materiality bar)
- [x] Full suite green via ./run-tests.sh
- [x] Finalize: record, index entry, timeline line, sidebar-collapse amendment (Current behavior + History), run report

## Verify

- `./run-tests.sh` -> PASS 1398/1398 (baseline 1385 + 3 implementer step-level tests + 10 tester matrix tests; zero regressions). Run independently by the Implementer, the Reviewer, the Tester, and the orchestrator. This run doubles as the sidebar-collapse record's regression confirmation (its verify command, green).
- Content-lint grep on the changed files -> exit 1. No em dashes in the diff. (The orchestrator's finalize check caught a tester fixture named with an lint-pattern key and renamed it PROJ-9 before close-out; suite re-run green.)

## Gotchas / non-obvious

- Reviewer (gate cycle 1, security drill): the story-derived slug always passes `slugify` ([a-z0-9-] only) and is consumed via textContent/placeholder, so there is no injection surface; explicit-name behavior is byte-identical to the old expression at all three sites, and slug-keyed storage cannot fragment because `saveWorkflow` gates on a non-empty name.
- A lowercase Jira key (proj-123) is not stripped by `deriveSlugFromStory` - harmless (still a non-untitled, non-colliding slug), accepted as-is.
- The seed-count test asserts 13 via the suite's ALL_IDS list while the runtime seed builds from the live DOM - if sections are ever added or removed, only the test list needs updating.

## History

- 2026-07-03: created (by sidebar-first-run)

## Outcome

A first-time visitor now sees two open sections plus a two-step quick start instead of fifteen open forms, and unnamed workflows derive their slug from the requirements text (untitled collisions eliminated). index.html +47 lines, tests.html +13 tests (3 implementer + 10 tester); 1385 -> 1398 green; uncommitted for the director's review. Both gates passed on cycle 1.

## Built with (provenance)

Workflow `sidebar-first-run` (Feature Development preset, Sub-Agents format): Planner -> Skeptic review gate ("Plan sound?", max 3 cycles) -> Implementer -> Reviewer gate ("Review Passed?", max 3 cycles) -> Tester -> code output (no-commit delivery). Memory + durable record + ground-in-records ON (the new defaults); models opus per node; run live by Claude (Fable) as orchestrator - second dogfood run, first under the v2.1 record protocol and the dogfood-run-fixes prompt improvements.

## Links

- Grounds on / touches: grounds on `.workflow/sidebar-collapse.md` (collapse module contract + gotchas) and `.workflow/node-config-ux.md` (scroll invariant, inherited); amended `.workflow/sidebar-collapse.md` (Current behavior now includes first-boot seeding; History line added).
- Branch: main (uncommitted delivery for the director).
```awd:run
{"workflow": "sidebar-first-run", "repo": "agentic-workflow-designer", "steps": [{"slug": "planner", "status": "done"}, {"slug": "skeptic-review-planner", "status": "done"}, {"slug": "implementer", "status": "done"}, {"slug": "reviewer", "status": "done"}, {"slug": "tester", "status": "done"}], "gates": [{"slug": "plan-sound", "cycles": 1, "final": "Passed"}, {"slug": "review-passed", "cycles": 1, "final": "Approved"}], "notes": "Both gates cycle 1. All five one-shot sub-agents returned complete reports (zero channel failures - the A6 one-shot fix validated). Planner found the test-harness boot contamination risk; orchestrator finalize caught an lint-pattern test fixture and renamed it. 1385 -> 1398 tests."}
```
