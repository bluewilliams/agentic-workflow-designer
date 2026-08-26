# Durable record index

Scan-then-open: read this index first, match an entry against the files or capability your change touches, then open only the matched record(s). One entry per record, grouped by a stable capability slug.

## live-run-monitor

- record: .workflow/live-run-monitor.md
- intent: the canvas watches the run - a Chromium Monitor drawer polls up to 4 watched directories (File System Access, IndexedDB-persisted handles) and renders live telemetry: the tasks.md checklist in three tiers (confirmed orchestrator ticks / provisional per-agent `t: {task} done` lines / open), agent status chips + live canvas dots from TOON entries, a change feed, and a markdown file viewer with awd:record header chips (a .workflow watch doubles as a durable-record browser). One watch covers a multi-repo run's live surface (shared memory folder); emissions gained the two-tier progress convention across all four memory variants (orchestrator seeds/ticks tasks.md individually; sub-agents append provisional ticks to their OWN files - one writer per file) and the record protocol gained owner tags, the kickoff tasks.md mirror, and a concision discipline. Read-only, poll-based (no browser file-watch events), memory-gated with OFF pins. Supersedes the parked incremental-checkpoint patch by intent.
- files: index.html (LIVE RUN MONITOR removable block, panel + button + CSS, canvas dot hook, memory-variant + record-protocol emission clauses), tests.html (Suites 12g emissions + 12h core), README.md, TECHNICAL.md, help modal
- status: current | date: 2026-08-25 | note: 1643 -> 1667 (incl. 6 regression pins from the high-review fix cycle: handler injection, re-grant timer, lapsed-watch wipe guard, duplicate-label slug map, revise-status ordering, false-half-tick length guard). Visual proof over the fullstack preset.

## markdown-preview-fences

- record: .workflow/markdown-preview-fences.md
- intent: the prompt panel renders inline marks (bold + code spans, escape-first inlineFmt) INSIDE fenced code blocks while block structure stays literal there - the Sub-Agents format embeds whole agent prompts in fences, where raw markers read as broken formatting. Display-only: Copy ships _rawPrompt; SDK textContent branch untouched.
- files: index.html (renderMarkdown in-fence branch, one line), tests.html (fence-inline pin)
- status: current | date: 2026-08-25 | note: 1637 -> 1638.

## auto-layout-revise-edges

- record: .workflow/auto-layout-revise-edges.md
- intent: autoLayout's cycle-breaking now seeds revise edges (isReviseBackEdge, the topologicalSort authority) as back-edges before the DFS, guarded on true loop closure so forward No branches (escalation paths) keep downstream layers. Fixes the visit-order defect that flung a fork sibling to the decision's next rank (Frontend beside Tester on every Full Stack preset apply); generic for all presets and hand-built workflows since loadPreset runs autoLayout.
- files: index.html (autoLayout Step 1 seeding + two-guard reachesBack, Step 2 endpoint guard, deserializeWorkflow connection-id backfill), tests.html (Suite 17: six layout-shape regressions incl. remediation, chained-revise, ghost-edge, id backfill)
- status: current | date: 2026-08-25 | note: 1628 -> 1634. Layout + import hardening; ranking, ordering, positioning untouched. Gotcha: four divergent revise-reachability copies documented in the record, shared-helper extraction deferred.

## preset-prompt-craft

- record: .workflow/preset-prompt-craft.md
- intent: composability audit of all 42 preset prompt templates (4 criteria: verdict discipline, handoff, evidence, proportionality) - 17 tuned with ~20 sentences: materiality bars on the specialized gate-feeding reviewers (fullstackReviewer/testReviewer/uiReviewer; default PASS, only Critical/High gate), honesty clauses on e2eTester/bugTester (blocked is never a pass), minimality on backend/frontend + non-destructive verification on devopsEngineer, Brief-absent fallback on uiImplementer, stream-conflict tiebreaker on integrator, input-scoping on securityAuditor/qualityAnalyst, severity preservation on reportBuilder, investigator proportionality, uiAppExplorer ff-only branch sync, and a flag-narrating-comments dimension on the three production-code reviewers. Lane discipline preserved (reviewers read, testers/verifiers execute, Skeptic refutes); no runner-specific review skill wired in (provider-neutral). 2026-08-24: selector craft de-Appiumed - framework-neutral locator order (role/label, test id, stable CSS; never hashed classes or indices) across both explorer templates + writer + reviewer, runtime-unconfirmed marks flowing Explorer -> writer -> reviewer with a handoff confirmation column, vendor-neutral inspector and platform language.
- files: index.html (PROMPTS templates only; no machinery), tests.html (Preset prompt craft batch suite + deliberate freeze-pin migrations)
- status: current | date: 2026-08-24 | note: 1618 -> 1628. Presets adopt at apply time; saved workflows keep baked prompts by design.

## repo-section-declutter

- record: .workflow/repo-section-declutter.md
- intent: calmer Multi-Repo & Context Paths sidebar section, sibling pass to memory-section-declutter - five copy trims (both intros, the Rules and Verification sub-lines, the inline-notes label; CLAUDE.md auto-reading stated once instead of twice), plus suggestion-chip dedupe: `syncPathSuggest` hides a dashed suggestion while its path is configured and restores it on removal, hooked into the three chip renderers so every mutation path and prefs-restore stays covered.
- files: index.html (section copy, three suggest-container ids, syncPathSuggest + three render hooks), tests.html (sub-line pin migrated, dedupe test added)
- status: current | date: 2026-08-22 | note: 1613 -> 1614. Copy + render-time visibility only; state shape, persistence, and emitted prompts untouched.

## memory-section-declutter

- record: .workflow/memory-section-declutter.md
- intent: calmer Memory & Durable Record sidebar section with zero behavior change - the derived memory path demoted from label + boxed display to one inline code-chip line (same `memoryPathDisplay` id, textContent contract intact), the Export -> Handoff tip removed (Help modal + export toast still cover it), two help texts trimmed one line each, dead `memory-hint` CSS dropped. Editable Artifact Path keeps its label; derived displays do not - that contrast marks what the user can change.
- files: index.html (sidebar memory section markup + memory-section CSS only; no JS, no emitted prompts)
- status: current | date: 2026-08-22 | note: 1613 tests unchanged; presentation only, all show/hide ids and nesting pinned.

## epic-run-feedback

- record: .workflow/epic-run-feedback.md
- intent: nine run-evidenced improvements from a real two-repo epic run - capability-conditional execution model (continue-don't-respawn where the harness allows; one-shot stays baseline), memory file promoted to the authoritative report channel, revise routing scoped to the faulted targets with approved-branch fencing, orchestrator decisions logged to shared.md, tester discrimination proof + reviewer corroboration, do-not-fake and machine-contention beats, durable-content sweep before finalize strips scaffolding, and a once-per-run environment capability survey inherited by downstream steps. 2026-08-22: grounding also scans openspec/ docs, bounded like the index scan (auto with the toggle).
- files: index.html (execution-model fragments, revise emission, memory protocol x2, tester/validator/changeScopedReviewer/planner/architect templates, durable-record spec, groundingLookupSteps + consumeRecordsHint + openSpecGroundingBlock + genAgentSDK grounding, sidebar toggle text, help modal, Explain reasons, kickoff narration), tests.html, README.md, TECHNICAL.md
- status: current | date: 2026-08-22 | note: 1605 -> 1613. Integration gate honored: every change carries run evidence.

## review-preset-efficiency

- record: .workflow/review-preset-efficiency.md
- intent: the Review preset made change-proportional AND structurally differentiated (4 agents: findings adversarially audited via the new review lens before fixes are spent, requirements-coverage review, per-finding evidence, fast paths; the 10-turn whole-codebase Analyzer folded into the Reviewer's diff-sized step 0; Improver/Validator aligned to the Blocking/Important/Nit vocabulary with no-drive-by + proportional-diff discipline) and a Branch Diff Review library prompt (no-checkout git-plumbing review of any branch vs any merge target, three-dot merge-base diff, optional inputs with honest fallbacks).
- files: index.html (changeScopedReviewer + improver/validator/requirementsAnalyst prompts, ADVERSARY_LENSES.review, review + delivery_swarm presets, Branch Diff Review entry), tests.html
- status: current | date: 2026-08-11 | note: 1602 -> 1605.

## external-review-hardening

- record: .workflow/external-review-hardening.md
- intent: an outside agent's ranked review applied where risk stays near zero - CI now gates Pages deploys on the suite (test job + needs, self-heal guarded to deploy failures, per-ref concurrency); updateConfig builds via array + single innerHTML assignment (was O(n^2) appends); configSelect escapes its unknown-value fallback (imported JSON is user data); the four generators' hint preambles consolidated into pushSharedHints (proven byte-identical across 17 presets x 5 formats x 3 toggle combos via a stash-diff snapshot harness; net -49 lines). Function-size decomposition deliberately declined in favor of on-touch.
- files: .github/workflows/pages.yml, index.html (updateConfig, configSelect, pushSharedHints + 4 call sites), tests.html (+3)
- status: current | date: 2026-08-07 | note: 1585 -> 1588.

## url-picker-input-gate

- record: .workflow/url-picker-input-gate.md
- intent: the urlPresetPicker ("Your input looks like a ticket URL...") shows only on a real input event - `validateStoryInput(fromUser)`, textarea oninput passes true - so pasting a URL still surfaces the preset helper but the startup revalidate of a restored URL-only session never reopens it over a built workflow; hide stays universal on every path; the bare-key hint deliberately keeps its state-based behavior (an input that genuinely needs fixing).
- files: index.html (validateStoryInput signature + picker show gate, textarea oninput), tests.html (show test migrated to fromUser + 2 regression tests)
- status: current | date: 2026-08-06 | note: 1563 -> 1565. Direct session fix - surfaced by the director hitting the picker on every open.

## effort-control

- record: .workflow/effort-control.md
- intent: a PER-STEP Effort lever in Node Configuration under Model (`config.effort`, '' = inherit), with a sidebar Default Effort that unset steps inherit at READ time (deliberately not baked like model: effort has a real unset state, and baking silently skipped every preset-built node because presets pass model explicitly). No step carrying effort emits NOTHING - proven byte-identical three times against a pre-feature snapshot of 17 presets x 5 formats + 3 toggle combos. Per-step prose line via effortStepNote (peer of modelContextNote, same 5 sites) + one workflow-level beat explaining that Claude Code applies effort per SESSION (claude --effort <level>), not per Task call; real per-agent output_config in the SDK; nothing in Claude.ai. Model-aware: the picker offers only what a step's model accepts, resolution goes DOWN only, every difference named in prose, an SDK comment, and Explain. Persistence inherited free from serializeWorkflow + savePrefs; deserializeWorkflow drops an unknown level like it drops an unknown model; OpenSpec forwards effort as intent beside Model.
- files: index.html (+181/-3: EFFORT_LEVELS/modelEffortLevels/resolvedEffortFor/nodeEffort/effortStepNote/effortHint, node config field + shared configSelect control, 5 per-step emission sites, SDK output_config, sidebar Default Effort, deserialize validation, Explain rows at workflow AND step level), tests.html (+27), README.md, TECHNICAL.md
- status: current | date: 2026-07-24

## model-roster

- record: .workflow/model-roster.md
- intent: Opus 5 added and made the default; Opus 4.7, Opus 4.6 and the dated 4.5 pair retired. The load-bearing half is taskModelMap: only the NEWEST model in a family holds the short alias, so Opus 4.8 and Sonnet 4.6 now fall through to their full API ids - leaving a superseded model mapped to a shorthand would silently run the step on its successor (the Sonnet 4.6 instance of that defect existed already and is fixed here). modelContextNote follows the same base, so a pinned [1M] note reads /model claude-opus-4-8[1m]. No compat shim for the default-model pref by ruling (the existing restorePrefs guard is now pinned). Separately fixed a real defect the retirement exposed: a node holding a retired model emitted that raw value as the Task param (getModelId falls through) while configSelect showed MODELS[0] - now migrated to the default on load, and configSelect renders an unknown value as itself.
- files: index.html (MODELS, taskModelMap, modelContextNote clause, 4 default sites + trigger label, deserializeWorkflow migration, configSelect), tests.html (8 migrations, 7 new guards, MODELS exposure, 110 fixture sweep), README.md, TECHNICAL.md
- status: current | date: 2026-07-24

## agent-library-button

- record: .workflow/agent-library-button.md
- intent: Add to Canvas reclassed from the borrowed .plib-copy chip to btn sm - matches Edit/Delete height and brightness; Prompt Library chips keep their class (count-pinned, chip fits there).
- files: index.html (renderAgentLib row markup)
- status: current | date: 2026-07-10

## prompt-library-overhaul

- record: .workflow/prompt-library-overhaul.md
- intent: the PROMPT_LIBRARY (now 76 entries) brought to the campaign quality bar - 62 strong as-is, 13 targeted fixes (negative-findings contracts on every audit-shaped prompt, availability-safe web-research claims, suggestion-safe gh phrasing, standalone log clause, PROJ-style example keys), 0 rewrites; 5 structural tests pin the bar (dash-free surfaces, non-empty descs, negative-findings, availability-safe, fictional keys). Category model cleaned same-day: requirement badges from a `requires` field (names plain, pinned), public-readable requirement labels, Sourcegraph as the library-wide code-search example. 2026-08-06: flagship "Software & Framework Upgrade" prompt (4-phase gated contract: baseline-first honesty anchor, research-before-code across every crossed major boundary, staged execution with revert-to-last-green, verification matrix + runtime proof + supported verdict; in-prompt dials DEPENDENCY SCOPE / API ADAPTATION defaulted conservative) added first in "Data & Migrations", renamed "Migrations & Upgrades" (no-compat license; old-category favorites silently unstar). 2026-08-07: input popup generalized to multi-field forms - `inputs` array of text + real dropdown fields (enhanceSelect skin, defaults preselected, find tokens replaced at every occurrence; legacy single `input` renders byte-identical, first textarea keeps the plibInputText id for Cmd+E) - and the upgrade prompt became the first consumer (target + 4 dropdowns: scope, API adaptation, REPORT DETAIL incl. a none opt-out, and a REPORT DESTINATION save-as-markdown-file checkbox (the shared pattern all 6 Documentation prompts also carry via [output destination] tokens) + optional constraints that outrank every dial) with breadth hardening (target-existence sanity check, cross-ecosystem version detection incl. C++ build files, rendering signal for UI-library upgrades, legacy safety-net-first, published-library leak check)
- files: index.html (PROMPT_LIBRARY, plibInputList/renderPlibInputFields/copyLibPrompt/confirmPlibInput, popup markup + label CSS), tests.html (+5 guards, upgrade contract + multi-input popup suites), TECHNICAL.md (category list, input model), README.md
- status: current | date: 2026-08-07

## unified-dropdowns

- record: .workflow/unified-dropdowns.md
- intent: one dropdown aesthetic app-wide - enhanceSelect() wraps the three native selects (appSourceAccess, customAgentType, customAgentModel) in the custom-select skin with the native authoritative underneath (skin picks dispatch real change events; programmatic writes follow via refreshEnhancedSelect at restorePrefs/clearCanvas/openAgentForm); full keyboard support (combobox/listbox, arrows, Escape) with canvas-shortcut exemption; one-popup-open enforced across all species; config-selects and #defaultModelSelect already custom, unchanged.
- files: index.html (enhancer block + CSS + exemption + refresh call sites), tests.html (8-test suite)
- status: current | date: 2026-07-10

## native-dark-scheme

- record: .workflow/native-dark-scheme.md
- intent: color-scheme dark at :root - OS widget chrome (scrollbars, control furniture) renders dark. Its interim select-option styling was superseded same-day by unified-dropdowns (natives now skinned and never open OS popups).
- files: index.html (:root CSS)
- status: current | date: 2026-07-10

## dogfood-run-fixes

- record: .workflow/dogfood-run-fixes.md
- intent: the first dogfood run's fix batch + durable record protocol v2.1. Task model params are valid base aliases with a 1M prose note (modelContextNote at all five prose emission sites; SDK ids already valid); Atlassian hints conditional-honest; all four memory variants gain the first-turn breadcrumb clause, orchestrator kickoff seeding (shared.md / progress.md), and COMPLETE-handoff mirroring into @slug.md (the proven recovery copy) - every addition memory-gated with OFF assertions; sub-agents + workflow-parallel state one-shot spawn semantics (teams untouched); memory + durable record + grounding default ON (seed + HTML checked + clearCanvas; explicit-false imports stay false). Record protocol v2.1: append-only History ledger (one dated line per amendment, born with a created line), right-sized lineage (amend-in-place / partial slice / full supersede - `partial` finally has semantics), Grounds on / touches line in Links, section mutability rules (only Current behavior + scaffolding rewrite in place), and grounding hardening (orchestrator routes record excerpts by role; reviewers/testers treat record requirements + gotchas as criteria; testers re-run overlapping verify commands).
- files: index.html (model-param block, hint honesty, four memory variants, execution directives, defaults, genDurableRecordProtocol + genDurableRecordComment, groundingLookupSteps + consumeRecordsHint, help modal), tests.html (6 migrations + 35 new), .workflow/sidebar-collapse.md (exemplar retrofit)
- status: current | date: 2026-07-03 | note: 1350 -> 1385. A8 (first-run collapse curation) implemented then dropped by scope change - deferred to its own dogfood run.

## defect-posture

- record: .workflow/defect-posture.md
- intent: two per-node Defect Posture knobs sharing one select and one emission surface (foundDefectNote): coder-family nodes tune fix-vs-record (balanced byte-identical default / record-only surgical / aggressive healing, all declared + tested); reviewer nodes tune flag-back intensity for pre-existing defects they spot (balanced notes / surgical ignores / aggressive sweeps + flags to the orchestrator - never fixing, never gate-failing), with an orchestrator handling line that dispatches flags ONLY along the review gate's drawn revise edge as a post-pass follow-up (outside gate cycles; record-only when no edge drawn) in all four prose formats. Non-balanced postures render on the node subtitle. Testers/verifiers carry the balanced protocol without a knob.
- files: index.html (nodeDefectPosture, foundDefectNote variants, node-config select, reviewer clause, Explain row, help), tests.html (7 tests)
- status: current | date: 2026-07-03 | note: 1474 -> 1481; balanced default means zero delta for untouched workflows.

## agent-craft-batch

- record: .workflow/agent-craft-batch.md
- intent: evidence-based agent-craft wave from the three dogfood runs. Found-defect protocol for building/testing roles (foundDefectNote at the six per-step sites: fix blocking defects with the coverage correctness demands; fix trivially-in-path fruit tested like your own work; record everything else for the Found bugs section - workarounds and undeclared drive-bys are named anti-patterns; reviewer treats DECLARED fixes as in scope; intensity now a per-node Defect Posture selector - see defect-posture). Tester closes by proving its tests can fail (spot mutation, honest skips). Verifier strengthened: escalation-tier intent, checklist-first evidence trail, additive-mandates, repo-rig harness bootstrapping with scratch cleanup, precise-contract-form assertions, budget honesty. Record protocol gains Found bugs (always) + Verification ledger (verifier or mandates present; append-and-tick; blocked required checks stay visibly unticked; verifier handoff reports ledger lines). Repo-mandated verification files retargeted owner-only (amends verification-instructions). Polish: import toast names the missing format field, awd:run example carries the real repo name, requirements-truncation report investigated (not reproducible in-app). Repo CLAUDE.md born (binding agent rules).
- files: index.html (foundDefectNote/FOUND_DEFECT_ROLES, PROMPTS.reviewer/tester/verifier, resolveVerifyOwnerId/VERIFY_OWNER_ROLES, genDurableRecordProtocol, recordHandoffHint(node), genDurableRecordComment, importWorkflowFile, runReportDirective), tests.html (suite 12e + owner-resolution migration), CLAUDE.md (new)
- status: current | date: 2026-07-03 | note: 1447 -> 1471. Three mid-wave director refinements folded in (owner-only routing; mandates additive; repo-mandated terminology).

## context-agent-types

- record: .workflow/context-agent-types.md
- intent: App Explorer and Design Analyzer are first-class agent types (16 total) - full registry wiring (prompt map, read-only tool floors without Write/Edit, researcher skeptic lens, OpenSpec research group, code-search step hint); the TYPE default template is a general application cartographer (structure/surfaces/contracts/flows, UI selector mining as a named branch) with the original selector prompt frozen byte-identical as uiAppExplorer and owned by the test_automation preset; the App Under Test / UI Context sections are ALWAYS PRESENT with consumer hints (no reveal machinery - a collapsed section advertises, a hidden one cannot; emission still content-gated); App Source access is an explicit Access selector (readonly default byte-identical / writable unconditional, declared-in-handoff) - zero contracts consult tool selections; advisor rules (h) explorer-without-path and (i) path-without-consumer are mutually exclusive nudges; Explain OFF rows give configuration guidance naming sections and consumers. 2026-08-07 audit: "App Source" renamed "App Under Test" everywhere user-facing (headings, Explain, advisor); emission prose role-addressed (exploration steps get the selector protocol, everyone else the access contract), UI Context framed authoritative any-platform, SDK access-selector bug fixed, OpenSpec forwards both blocks.
- files: index.html (AGENT_TYPES/AGENT_TYPE_TOOL_DEFAULTS/AGENT_TYPE_PROMPT_MAP/ADVERSARY_LENS_BY_ROLE/OPENSPEC_ROLE_GROUP/CODE_SEARCH_STEP_ROLES, always-present section markup + consumer hints, presets, adviseWorkflow rules h + i, explain rows, help), tests.html, README.md
- status: current | date: 2026-08-07 | note: 1492 -> 1510 across the unit's rulings; audit fixes to 1578. Kills the smuggled-template discoverability defects structurally.

## explain-lever-audit

- record: .workflow/explain-lever-audit.md
- intent: the OFF-row principle enforced uniformly across Explain - every off/absent row names its lever in user language (no internal constants, no raw agentType ids, no jargon; config rows name their sidebar home); ON reasons use plain UI toggle names; Claude.ai Model row is a by-design skip; advisor rules (h)/(i) share one consumer predicate (legacy template carriers get the setup nudge); TECHNICAL/README/help staleness swept (16-type roster, uiAppExplorer split, UI Explorer label, appSourceAccess, always-present sections). 2026-08-07: OFF-guidance made actionable - rows deep-link their sidebar-section levers via a central EXPLAIN_SECTION_LINKS map (jumpToSection: close modal, expand, scroll). 2026-08-25: ON-row richness - heading-placeholder evidence replaced with real emitted blocks and user text, reasons name configured values (repos @ branches, context paths, memory/artifact paths, step model), previews render escape-first inline bold/code (exInlineMd).
- files: index.html (explainAgentNode/explainWorkflow/explainDecisionNode rows, adviseWorkflow rule h, help modal), tests.html (1 migration + 2 pins), TECHNICAL.md, README.md
- status: current | date: 2026-07-04 | note: 1511 -> 1513. Findings from the overnight read-only audit, applied in three approved batches.

## verification-instructions

- record: .workflow/verification-instructions.md
- intent: repo-mandated verification files, OWNER-ONLY routed - third sticky Repo Context Paths group (verifyPaths add-chips + verifyFailRun checkbox, default ON) emitting an orchestrator discovery/scoping beat at all FIVE formats (verifyInstructionsHint) and a per-step execute-and-report contract (verifyInstructionsStepHint) to exactly ONE step: the workflow's owning verification step via resolveVerifyOwnerId (last verifier-type node, else last tester; reviewers audit, never execute; upstream testers receive nothing so expensive mandates never run twice). Contract: executed/na/blocked with reasons; blocked-required surfaces in verdict + record Verify/Verification ledger + awd:run and fails the run when posture ON; the repo's mandates are ADDITIVE to the owner's own verification method, never a substitute; openSpecContextBlock forwards; silence-when-empty structural; suggestion semantics preserved. 2026-08-07: ownerless fallback (orchestrator executes at close-out), advisor rule (j), SDK routing drift fixed; inline verification notes (fileless mandates through the same machinery) + Verifier config-panel mandate status. 2026-08-22: run-evidenced arming - the checkbox disables with a hint while no mandates exist (inert posture made visibly inert, state sticky), and blocked required checks report through a structured awd:run blockedVerifications array instead of free-text notes.
- files: index.html (verifyInstructionsHint/verifyInstructionsStepHint/resolveVerifyOwnerId/VERIFY_OWNER_ROLES, state+prefs+clearCanvas, sidebar third block + chip twins, 5 workflow-level + 4 per-step emit sites, openSpecContextBlock, explain rows, help, awd:meta+adoptMeta), tests.html (23 + run-level matrix + owner-resolution migration)
- status: current | date: 2026-07-03 | note: third dogfood run (fork + verifier), plan gate passed cycle 2 after a real parity-gap block.

## sonnet-5-models

- record: .workflow/sonnet-5-models.md
- intent: Sonnet 5 + Sonnet 5 [1M] model support - MODELS rows (family sonnet-5, id claude-sonnet-5) + taskModelMap base alias sonnet for both variants; every picker generic from MODELS; 1M machinery generalizes by the -1m suffix with zero special-casing; SDK full id, prose base alias + 1M note.
- files: index.html (MODELS array, taskModelMap, latest-models comment), tests.html (8 pins)
- status: current | date: 2026-07-03 | note: sibling of verification-instructions (same run); both plan-gate claims verified, zero logic changes.

## sidebar-first-run

- record: .workflow/sidebar-first-run.md
- intent: first-run experience - on first boot (absent awd_sidebarCollapsed) initSidebarCollapse seeds a curated collapse state (11 collapsed since the 2026-08-07 section merges, requirements + presets open, persisted once; existing keys never re-seeded); the empty canvas is a two-step quick start (requirements link expands + scrolls like the preset link, panel hides with nodes); Workflow Name placeholder says optional; empty name derives the slug from the requirements text via deriveSlugFromStory/effectiveNameSlug at all three slug sites (memory path, record path, export slug; untitled only when both empty; explicit name wins byte-identically; live path updates while typing).
- files: index.html (initSidebarCollapse seed, deriveSlugFromStory/effectiveNameSlug, getMemoryPath/getDefaultArtifactPath/serializeWorkflow, validateStoryInput, #emptyState, #workflowName), tests.html (harness boot normalization + 13 tests)
- status: current | date: 2026-07-03 | note: 1385 -> 1398. Second dogfood run - built by the designer's own generated workflow, both gates cycle 1.

## sidebar-collapse

- record: .workflow/sidebar-collapse.md
- intent: collapsible left-sidebar sections with persistence - every section header is a chevron click-toggle (CSS child-hiding, zero visual change expanded), state persists in awd_sidebarCollapsed (absent = expanded; try/catch, bad-JSON degrades to expanded; on a true FIRST boot the key is seeded curated by sidebar-first-run - 13 collapsed, requirements + presets open), Expand All / Collapse All control above the first section, and every programmatic reveal auto-expands first (selectNode -> node-config inside its genuine-change guard BEFORE the instant scroll - the node-config-ux invariant holds by construction; empty-canvas preset link likewise). App Under Test / UI Context are always-present sections (their brief conditional-reveal era ended same-day, by context-agent-types). 12 stable literal data-collapse-ids (was 15; 2026-08-07 merges: workflow-name into requirements as "Workflow Name & Requirements" (New Workflow button relocated to the controls row), repo-context-paths into repositories as "Repos & Context Paths", ui-context into app-under-test as "App & UI Context"; MCP heading suffix moved to a body line; display renames "Multi-Repo & Context Paths" + "Node & Agent Palette" (ids unchanged) - seed now 10 collapsed + requirements/presets open).
- files: index.html (collapse CSS + module + 15 ids + selectNode/preset-link guards + boot hook + help line), tests.html (10-test suite, mandated afterEach cleanup)
- work-item: designer-generated workflow run (first live dogfood) | status: current | date: 2026-07-03 | note: 1340 -> 1350; both gates cycle 1; run report embedded in the record.

## revise-edge-continuity

- record: .workflow/revise-edge-continuity.md
- intent: the revise loop-back edge styles itself to the active format's continuity semantics (solid = context persists: Workflow/Claude single-session, Teams persistent teammates; dashed = fresh spawn: Sub-Agents/SDK) with the exact meaning on hover (SVG title; memory-aware) and the same phrase in the Explain revise-routing row - one pure helper reviseContinuity() is the single source both surfaces ask, renderer consults behind a typeof guard, setExportFormat's existing render() is the whole tab coupling. Layered disclosure: the style change is the hook, the hover teaches, Explain seals.
- files: index.html (helper block, renderer consult, CSS pair, explain row, help line), tests.html (+4)
- status: current | date: 2026-07-03 | note: 1336 -> 1340. Owner idea from the respawn-lossiness conversation.

## prompt-overhaul-wave-c

- record: .workflow/prompt-overhaul-wave-c.md
- intent: (UPDATED: + orchestratorCraft() - the conductor's judgment block in the three core formats: brief-down-not-dump, evidence-honest gates, surgical revise briefs, format-fitted failure handling, fork-gated fan-in reconciliation; genWorkflow spawn-vs-single-session contradiction fixed; Explain row added.) wave C of the prompt overhaul. Specialized templates expertise-first (securityAuditor threat-model + reachability bar, perfProfiler hypothesis-first, migrationEngineer expand-contract, devopsEngineer least-privilege/idempotence, codeAnalyzer churn-x-complexity + actionability bar, archReviewer traced-evidence, writerBusiness figure provenance); test-automation family discovers its stack from the repo (C#/SpecFlow/Appium demoted to examples); NEW Analyst agent type fully wired (analysisSynthesizer template, gatherer tools, dedicated analysis Skeptic lens, both hint sets, bespoke OpenSpec analysis sections, auto-builder retyped); NEW presets Analysis & Forecast (analysis-lens Skeptic gate -> business writer) and Incident RCA (Verifier proves the root cause by execution); advisor rule (g) flags review-role verdicts routing nowhere (type-gated; calibration-clean at 17 presets).
- files: index.html, tests.html, README.md, TECHNICAL.md
- status: current | date: 2026-07-03 | note: 1322 -> 1329. Content-lint.

## prompt-overhaul-wave-b

- record: .workflow/prompt-overhaul-wave-b.md
- intent: the philosophy sweep - core templates teach role craft, not tool mechanics (owner's organizing insight; critic prompts = house style). Six deep rewrites: planner (decompose-by-risk, resume units, decisions-vs-assumptions, out-of-scope, stop condition), researcher (verified-vs-inferred, triangulation, negative findings, confidence, stop), architect (options-and-why-losers-lost, simplest guard, failure/scale, rollout), investigator (anti-anchoring: two hypotheses + disconfirming evidence + correlation-vs-causation), reviewer (materiality bar + evidence rule + risk-based depth + tests-as-hard-as-code), tester (good-test bar: behavior-not-implementation, delete-if-nothing-would-fail-it). Strong set compressed to craft-first parentheticals (implementer/backend/frontend/fixer/writerTechnical/writerApi). Researcher defaults +Bash. Zero pure tool-tutorial steps remain in the core set; composed size +3.6% (expertise costs tokens; ratio target met).
- files: index.html (12 templates + researcher defaults), tests.html (3 pins)
- status: current | date: 2026-07-03 | note: 1322/1322 throughout; handoff names stable, new fields additive.

## prompt-overhaul-wave-a

- record: .workflow/prompt-overhaul-wave-a.md
- intent: mechanical bugs from the three-fork deep prompt review. Auto-builder security path re-ran the REVIEWER on Revise (builders now captured pre-reassignment); review/fullstack/ui_component presets had dead-end reviewer verdicts (now gated with revise edges); Skeptic/Verifier Convergence corrupted verdicts (PASS-despite-blockers keyed to an unknowable cycle index) - now honest-verdict + delta-scoped re-review, with every generator's revise instruction passing "cycle X of the max" to the reviewer; phantom-role handoffs ("for the Fixer") rephrased; analysis chain finishes with writerBusiness; auto r1 research parity closed; 11 unjustified planner/architect WebSearch grants removed (testPlanner kept, reasoned); PROMPTS.general codebase-conditional; writerUserguide +WebFetch; 4 formatter nodes writer-typed.
- files: index.html, tests.html
- status: current | date: 2026-07-03 | note: 1316 -> 1322 (+6). Content-lint. Waves B/C (philosophy sweep, specialized infusion) follow.

## tool-suggestion-semantics

- record: .workflow/tool-suggestion-semantics.md
- intent: (UPDATED: planner/architect regained web-tool suggestions + conditional craft lines; clause gained a role-intent guard - investigative/review steps prefer reporting over changing.) OWNER RULING (supersedes tool-access-wording): tool selections are STRONG SUGGESTIONS, never restrictions - agents are never limited or blocked from any tool available to them. `Suggested tools for this step: X` + one suggestions-not-limits clause, uniform across full/partial selections; toolSubstitutionNote removed; the Agent SDK emits NO hard tools=[...] param (suggestion rides as comment + instruction lines; Write-union machinery deleted; R3/C5 exclusion kept, re-rationalized as owner-priority minimalism). Ride-alongs from the deep prompt review: verifier +Write in both pinned sets, skeptic maxTurns 8, debugger defaults +Write/Edit. Explain rows renamed (Suggested tools / Suggestion clause).
- files: index.html, tests.html, TECHNICAL.md
- status: current | date: 2026-07-03 | note: 1319 -> 1316 (substitution/union tests removed, uniformity + SDK-no-param added). Content-lint. First real supersession in the archive.

## mobile-viewport-scaling

- record: .workflow/mobile-viewport-scaling.md
- intent: phones clipped the app because the viewport meta promised a responsive layout (width=device-width) the fixed desktop grid never delivers. Now `width=1280`: mobile scales the whole page to fit (tiny but complete, pinch-zoomable), desktop ignores the tag. Deliberately a one-line scale-to-fit, not a responsive redesign. UPDATE: app grid height is 100dvh (visible-viewport tracking; 100vh fallback) so the output panel no longer hides behind mobile Safari's bottom bar.
- files: index.html (viewport meta)
- status: current | date: 2026-07-03 | note: no test surface; real-device check after deploy.

Record anatomy v2: each record opens with an `awd:record` JSON fence (slug, status current|superseded, date, files, exact verify commands, superseded_by) and a present-tense "Current behavior" section - read that first for the living truth, and the history below it only for the why. Records dated before 2026-07-01 migrate to v2 on touch. Superseded entries move to the Archive section at the bottom of this file; the durable system is exactly three surfaces (record + this index + _timeline.md), never any companion documents.

## explain-workflow

- record: .workflow/explain-workflow.md
- intent: make prompt composition permanently inspectable (the 2026-07-01 audit's dozen invisible-composition bugs are this feature's reason to exist). Two adjacent buttons in the prompt actions: Explain = workflow-level anatomy of the selected format, LED by "The orchestrator" capstone row (not a canvas node - the agent this document programs; configuration-derived duties; [view full] unfolds orchestratorRunPlan(): kickoff/execution/close-out itinerary mirroring the generators' emission order, snippet = steps/groups/gates/worst-case-revise/critical-path); Explain Step = per-step anatomy for the node selected on the canvas, ALL node types incl. input (requirements/framing/Atlassian rows). Long rows unfold inline via details/summary ([view full]); Memory/Durable protocol rows carry their real protocol text. THE INVARIANT: statuses come from calling the same helpers the generators call, emitted rows carry verbatim probes, agreement tests pin the explainer to real generated output across a node/toggle matrix in the three core formats - and the synthesized run plan keeps probe EMPTY so it can never leak into that matrix. SDK collapses to one deliberate-exclusion note. Removable block, reused modal classes, inert until clicked.
- files: index.html (explain block + modal + two entry buttons + Escape branch + help section), README.md, tests.html (agreement describe + exposures)
- status: current | date: 2026-07-02 | note: 1291 -> 1299 (+8). Content-lint.

## self-improvement-loop

- record: .workflow/self-improvement-loop.md
- intent: one unit of work closing the design -> run -> re-design loop. (1) Record anatomy v2 in the generated durable-record protocol: awd:record JSON fence (born-current statuses) + present-tense "Current behavior" first section (spec-vs-delta in one file), granular live-ticked checklists with resume semantics (DONE: names exact boxes), finalize self-lint (the agent is the linter), Archive as a SECTION of _index (index stays one file, always), grounding reads Current behavior first / skips Archive / follows superseded_by in all consumers; 16 exemplar records retrofitted. (2) Run-report contract: every run ends with ONE awd:run fence (steps status/turns/cap, gates cycles/verdict, used-only `grounded` slugs when the grounding toggle is on, omit-never-invent; the orchestrator also narrates grounding outcomes to the user at kickoff + final report, 2026-07-11) via runReportDirective() in workflow/subagents/teams/claude (SDK = comment line); finalize copies it into the record; the OpenSpec apply step emits the fence + a one-line reverse-grounding breadcrumb (closes backlog #10). (3) Designer read side (removable blocks): Import ingests fence-bearing text (after awd:meta so handoffs round-trip) OR a one-time "Connect repo" folder grant auto-rescans .workflow/ (FS Access API, IndexedDB handle, djb2 content-hash dedupe shared by both feeds - never double-counts); aggregates in localStorage awd_run_reports drive amber telemetry badges + a config Run history line + the data-gated Tuning prompt (stats + retained run NOTES and grounded counts + awd JSON + the full designer toolbox incl. models/toggles/topology -> Claude returns an improved workflow with per-change predicted effects; pastes straight back via Import > From clipboard; advisor nudges at 3 runs). (4) adviseWorkflow(): six non-blocking rules incl. telemetry rules, lightbulb Suggestions group in the Workflow Review modal, one-click Attach Skeptic; badge stays issues-only; all 15 presets advise clean (calibration-pinned). Also: test harness now awaits async tests (was passing them vacuously; canary-proven). CONNECT GUIDANCE: Chrome's FS Access blocklist refuses the home directory root - tooltip/help teach mkdir -p ~/.awd first, then pick the folder ITSELF via Cmd+Shift+G; telemetry home is workflow-level (~/.awd/run-reports.md, one connect covers every repo).
- files: index.html, tests.html (+33 across four describes), README.md, TECHNICAL.md, .workflow/ (16 retrofits + _index preamble/Archive)
- status: current | date: 2026-07-02 | note: 1257 -> 1290 (+33). Every wave parent-verified. Content-lint.

## undo-text-coverage

- record: .workflow/undo-text-coverage.md
- intent: config text edits never pushed undo (Cmd+Z could wipe a hand-written prompt by jumping to the last structural snapshot) and every node mousedown pushed a snapshot even for bare select-clicks (50-cap flooded with no-ops). Now: editing-session grain for text (first input since (re)build/blur snapshots pre-edit state, listener registered ahead of the state-writing handler; expand modal covered by construction - it dispatches the source's input event) and drag snapshots commit at drag-END only when the node moved (pushUndo gained an optional pre-captured-snap param). Behavioral tests written first and seen failing.
- files: index.html (pushUndo param, mousedown/mouseup, session listener), tests.html (6 tests + undoDepth/clearUndo exposures)
- status: current | date: 2026-07-01 | note: 1251 -> 1257 (+6). Content-lint.

## revise-loop-topo-generalization

- record: .workflow/revise-loop-topo-generalization.md
- intent: generalizes the topo exclusion from attached review-loop back-edges to ANY decision's noLabel failure branch (the app's decision semantics are pass/revise; a revision path is never a dependency). One shared isReviseBackEdge() replaces isReviewLoopBackEdge (strict superset) AND validateWorkflow's inline copy - ordering and sibling-reachability can no longer disagree. All 15 presets verified BYTE-IDENTICAL before/after (headless snapshot diff of topo order + genWorkflow + genSubAgents); the fix exclusively repairs hand-built loops whose creation order differs from flow order (pinned: Tester-created-first now orders Planner -> Coder -> gate -> Tester). OpenSpec manual-loop export anchors requires to the real upstream (test-pinned).
- files: index.html (isReviseBackEdge, topologicalSort, validateWorkflow alias), tests.html (new describe, predicate exposure), .workflow/review-loop-topo-order.md (follow-up flipped)
- status: current | date: 2026-07-01 | note: 1248 -> 1251 (+3), zero existing-test changes. Content-lint.

## validation-modal

- record: .workflow/validation-modal.md
- intent: themed in-app surfaces replace native browser chrome. #validationOverlay (help-modal classes, zero new CSS) carries the warning badge's details (icon + message rows) AND the advisor's Suggestions group; appConfirm/withConfirm + #confirmOverlay (z-index 600, danger button, Enter/Escape/backdrop, capture-phase key trap, sync test hook __autoConfirm) replace six of the eight native confirm() sites (deletes, preset/auto-workflow replace, New workflow). DELIBERATE KEEP: the two secrets-copy confirms stay native - the modal round-trip moves the clipboard write out of the gesture task and the rig stubs the clipboard, so unprovable in CI; comments at both sites. COLOR SEMANTICS: danger red is reserved for the irreversible - the three cannot-be-undone deletes are red with focus-Cancel; the undoable Replace/Clear confirms use the standard blue primary (preset load pushes a single undo point; the modal is the caution signal, color marks consequence).
- files: index.html (both overlays, showValidation/closeValidation, appConfirm/withConfirm, six converted call sites), tests.html (7 tests + hook + exposures)
- status: current | date: 2026-07-01 | note: 1246 -> 1248 (+2). Content-lint.

## analysis-branch-prompts

- record: .workflow/analysis-branch-prompts.md
- intent: the Auto Workflow analysis branch and the Analysis & Forecast preset run bespoke analysisGatherer (numbers with sources, Bash repo metrics, conditional WebFetch, measured-vs-estimated tagged at collection) and analysisSynthesizer (visible arithmetic with units, justified assumptions, low/expected/high ranges, sanity anchor, per-number confidence). Both nodes are ANALYST-typed (wave C): the analysisSynthesizer is the analyst type's template, the Skeptic reviews analysis work under the dedicated analysis lens, and OpenSpec exports use the analysis record sections.
- files: index.html (two PROMPTS entries + analysis-branch wiring), tests.html (analysis-intent test rewritten)
- status: current | date: 2026-07-01 | note: 1246/1246 (rewrite in place). Content-lint.

## tool-selection-consistency

- record: .workflow/tool-selection-consistency.md
- intent: preset testers carry Edit (9 arrays; Validator/Feature Writer curated exceptions). Its two reconciliation devices resolved under suggestion semantics (tool-suggestion-semantics.md): toolSubstitutionNote REMOVED; toolScopeNote is now the uniform suggestions-not-limits clause. Record retains the closed-enumeration history.
- files: index.html (tester arrays, toolSubstitutionNote + 5 injections), tests.html (3 tests + exposure)
- status: current | date: 2026-07-01 | note: 1237 -> 1240 (+3). Content-lint.

## agent-type-tool-defaults

- record: .workflow/agent-type-tool-defaults.md
- intent: owner ruling - a role class implies a default tool floor (Researcher gets WebSearch/WebFetch, Coder gets write access, Planner is read-only), while a user deselect always wins. New AGENT_TYPE_TOOL_DEFAULTS map + agentTypeToolDefaults() resolver (general derives from NODE_DEFAULTS; adversary/verifier mirror REVIEW_LOOP_KINDS, equality test-pinned; writer defers to WRITER_TOOL_DEFAULTS per style). Type change now pristine-swaps tools by the same matches-ANY-default rule the prompt bake fix uses, so tools and prompt follow the node together; customized sets never swap (this also removed the old unconditional writer-branch tool clobber). PROMPTS.researcher gains one selection-safe conditional web step ("where... web tools are available to you") so the template never lies under any selection. Presets/auto-built nodes unaffected (explicit curated arrays, no type-change event).
- files: index.html (map + helpers after WRITER_TOOL_DEFAULTS; agentType handler; researcher template step 10), tests.html ("Agent-type default tool sets" describe, 8 tests; iframe exposure line extended)
- status: current | date: 2026-07-01 | note: 1229 -> 1237 (+8), then same-day UPDATE (see record): coder/frontend/backend/debugger +web tools with conditional template steps, reviewer deliberately unchanged (read-only), Agent Library form gains full pristine-swap parity via applyAgentTypeChange (old writer-only clobber removed). 1241 -> 1246. Content-lint. UI-swap tests drive the real dropdown headlessly.

## node-config-ux

- record: .workflow/node-config-ux.md
- intent: two node-config UX defects. Selecting a node gave no visible feedback (config panel ~2621px below a 1000px viewport fold) - selectNode now scrolls the panel into view, gated on genuine selection CHANGE (no scroll-jacking; smooth for humans, instant under the test rig via __instantScroll and for reduced-motion users; before/after 2621px -> 341px). Type-switch bake trap: a second type change stranded the previous role's baked template under a lying status line - new matchesAnyRoleTemplate() (all mapped templates + writer variants + adversary lenses) generalizes the Writing Style handler's pristine-swap rule: pristine template text re-bakes for the new type, user text never touched. classifyAgentPrompt gains a 'foreign-template' state with truthful copy + Reset button for legacy saves.
- files: index.html (selectNode, matchesAnyRoleTemplate, agentType handler, classifyAgentPrompt, agentPromptStatusBlock), tests.html (bake-trap sequence, custom-survives, foreign-template)
- status: current | date: 2026-07-01 | note: 1225 -> 1228 (+3). Headless smoke of the full app passes. Content-lint.

## prompt-contract-polish

- record: .workflow/prompt-contract-polish.md
- intent: three prompt-quality items batched. closingOrderNote(): one sentence ordering the up-to-four stacked end-of-response contracts (Handoff Summary -> DONE:/STATUS -> memory breadcrumb last), emitted only when a second contract is active; injected in sub-agent/teammate/SDK emissions. Unknown-type fallback in getEffectivePrompt now composes from PROMPTS.general's body (label/notes-seeded first line kept) - near-duplicate literal deleted, drift risk gone. CODE_SEARCH_STEP_ROLES widened 8 -> 12 (reviewer/tester/adversary/verifier - the hint's cross-repo-seams rationale fits auditing; writer stays out; DATADOG_STEP_ROLES deliberately unchanged, implementers inherit telemetry via the orchestrator's brief); C-series test literals updated in lockstep, C4 probe moved to writer/unknown.
- files: index.html (closingOrderNote + 3 injections, fallback, role set), tests.html (closing-order describe, fallback-sync test, C-series)
- status: current | date: 2026-07-01 | note: 1221 -> 1225 (+4). Content-lint.

## auto-workflow-tailored-prompts

- record: .workflow/auto-workflow-tailored-prompts.md
- intent: Auto Workflow's research branch now actually mirrors the Parallel Research preset (its comment claimed it already did): inferResearchMode/detectNamedOptions from the story, researchDocPrompt for Options Researcher (Read/WebSearch/WebFetch - no more 7 LSP steps without LSP), researchPatternPrompt for Tradeoff Analyzer, researchSynthesizerPrompt for the Synthesizer (planner type, Read/Write, like the preset); fork carries researchMode so the mode editor works on auto-built workflows. Documentation tail gets the preset's writer-lens Skeptic review loop ("Docs accurate?" gate) with a linear writer-lens fallback for multi-branch tails; the omit-decision-gate structural test rewritten to pin the new sharper contract. Data Gatherer WebFetch: dropped, then RESTORED same day by owner ruling (availability is a floor; never shrink prior capability for prompt coherence) with an Agent Context line licensing Bash+WebFetch instead of a shared-template edit (bespoke analysis prompts landed 2026-07-01; wave A 2026-07-03 closed r1 explorer parity and swapped the analysis finisher to writerBusiness - see record Updates). Four dead PROMPTS keys deleted (synthesizer, docResearcher, patternAnalyzer, codebaseExplorer).
- files: index.html (research branch, documentation tail, analysis tools, PROMPTS), tests.html (tailored-prompts describe, doc-gate test, Atlassian-regression list)
- status: current | date: 2026-07-01 | note: 1219 -> 1221. Content-lint.

## sdk-toggle-parity

- record: .workflow/sdk-toggle-parity.md
- intent: genAgentSDK renders clarifyFirst + mcpDatadog as orchestrator-level # banners from the shared hint sources. Per-step Datadog/code-search hints stay OUT of SDK instructions - kept minimal by owner priority (tests R3/C5; the original hard-tools-param rationale died with the param, see tool-suggestion-semantics.md).
- files: index.html (genAgentSDK banners + rationale comment), tests.html (SDK toggle parity describe)
- status: current | date: 2026-07-01 | note: 1215 -> 1219 (+4). Content-lint.

## delivery-ownership-subagents

- record: .workflow/delivery-ownership-subagents.md
- intent: buildAgentPrompt injected the full imperative delivery block (branch/push/`gh pr create`) into EVERY sub-agent's prompt, licensing a mid-workflow Planner or Reviewer to open the PR (or several agents to each open one). Delivery is now orchestrator-owned in the sub-agent format too: genSubAgents emits `deliveryBlock('##')` once in its orchestrator tail (matching the other four formats, which were verified already orchestrator-level), and each agent gets `deliveryAgentNote()` instead - pr/commit = branch-discipline note (work on the feature branch, never push or open the PR yourself), report/docs = empty, no output node = the existing noCommitBlock verbatim.
- files: index.html (deliveryAgentNote beside deliveryBlock; buildAgentPrompt swap; genSubAgents tail emission), tests.html (single gh-pr-create + per-agent discipline + no-output discipline tests)
- status: current | date: 2026-07-01 | note: 1213 -> 1215 (+2). Content-lint.

## review-loop-topo-order

- record: .workflow/review-loop-topo-order.md
- intent: attaching a Skeptic/Verifier to a non-terminal node emitted steps OUT OF ORDER in all four prose generators - topologicalSort fed the loop's failure back-edge to Kahn's as a dependency, the cluster went cyclic, and everything fell into the creation-order fallback (downstream Tester emitted before the Skeptic gate). New `isReviewLoopBackEdge()` (same identification as detach/reroute: decision with reviewLoopDecisionFor + noLabel-labelled edge) excluded from the adjacency; forward edges stay. OpenSpec mid-chain-loop export healed for free (gated artifact was `requires: []` orphan root, apply tracked the skeptic; now the chain is planner -> coder -> skeptic -> tester, apply requires tester). Manual revise loops deliberately untouched.
- files: index.html (isReviewLoopBackEdge + topologicalSort exclusion), tests.html ("Review-loop topological ordering" describe)
- status: current | date: 2026-07-01 | note: part of 1203 -> 1213 (+10 with parallel-sibling-emission). Content-lint.

## parallel-sibling-emission

- record: .workflow/parallel-sibling-emission.md
- intent: all five generators emitted a parallel group with `i += siblings.length`, assuming siblings are contiguous in topo order; fork->(A,B) + A->C->B duplicated the A/B group and SILENTLY DROPPED C (SDK defined gamma_config but never called run()). Converted every loop to an emitted-id set walk (group emits once at first member, skips advance by 1, non-siblings emit in their own topo slot) - byte-identical for the contiguous case. Plus a validateWorkflow warning when fork siblings have a dependency path between them ("cannot truly run simultaneously"), with revise-edge-aware reachability (any decision's noLabel branch excluded) so manual revise loops like the test-automation preset don't false-positive.
- files: index.html (5 emission loops + validator warning), tests.html ("Interleaved parallel sibling emission" describe)
- status: current | date: 2026-07-01 | note: part of 1203 -> 1213. Content-lint.

## generated-output-consistency

- record: .workflow/generated-output-consistency.md
- intent: batch of generated-output consistency fixes from the designer-wide audit: genWorkflow parallel siblings get Agent Context/Max turns/Success gate parity with sequential steps (was bare `Context:` + missing fields); empty-label decision fallbacks aligned to Yes/No at 10 sites (was Pass/Fail, contradicting routing text); 3 unguarded toolAccessText call sites now skip empty tool lists (per the helper's own documented contract); em dashes removed from all emitted strings (revise-cycle lines, TOON example, placeholder, palette tooltip); validator empty-General warning copy updated for PROMPTS.general ("generic scaffold - tailor it"); Debugger desc now honest ("Investigates bugs to root cause" - its template does not fix).
- files: index.html (genWorkflow parallel branch, fallback sites, guards, strings, AGENT_TYPES desc), tests.html ("Generated-output consistency" describe)
- status: current | date: 2026-07-01 | note: 1199 -> 1203 (+4). Content-lint.

## memory-write-authorization

- record: .workflow/memory-write-authorization.md
- intent: memory writes are PROTOCOL-level, not task-level: memoryWriteAuthNote() at every per-agent memory-write emission - every agent appends to its memory files whether or not Write is among its SUGGESTED tools. The former SDK Write-union machinery is gone with the hard tools param (tool-suggestion-semantics.md); all behind memoryEnabled gates.
- files: index.html (memoryWriteAuthNote + 4 injections + genAgentSDK tools union), tests.html ("Memory write authorization" describe)
- status: current | date: 2026-07-01 | note: 1195 -> 1199 (+4). Content-lint.

## general-agent-template

- record: .workflow/general-agent-template.md
- intent: the "General" agent type was mapped to the `researcher` prompt (`AGENT_TYPE_PROMPT_MAP.general = 'researcher'`), so a Reset showed the codebase-research checklist and it silently ran as a researcher. Gave General its own neutral general-purpose template (`PROMPTS.general`, static: complete-the-task -> orient/plan/execute/verify/Handoff) and repointed the map (general -> 'general'). KEY: kept the "empty General prompt" validation warning - validateWorkflow warns on empty General prompts but NOT typed agents, revealing the intent (typed agents have full role templates; General is a scaffold you tailor). The warning checks the stored prompt so it's unaffected; now coherent (scaffold + "tailor me" nudge) vs the old silent-researcher behavior. Static (not the dynamic label fallback) so classifyAgentPrompt/Reset compare correctly; the dynamic fallback remains for genuinely unknown types. No impact on imported foreign agents (they carry a prompt from the instruction, so the template is not used).
- files: index.html (PROMPTS.general; AGENT_TYPE_PROMPT_MAP.general researcher->general; fallback comment), tests.html ("General agent template" describe: General maps to general + a general template not researcher, end-to-end genWorkflow emits it, Researcher unchanged)
- status: current | date: 2026-07-01 | note: 1193 -> 1195 (+2). Existing empty-General warning test + preset-zero-warnings tests still pass (warning logic untouched; named presets use typed agents). Content-lint.

## agent-context-label

- record: .workflow/agent-context-label-standardization.md
- intent: standardize the per-agent `config.notes` field's user-facing label on "Agent Context". The UI already said "Agent Context" everywhere (config panel / agent form / help / expand modal) but every generated prompt said "Additional context" - a real mismatch (the user sets one term, sees another). Chose "Agent Context" (matches the UI + pairs with "Workflow Context" = planInput, a clean two-tier model). Swapped all 7 output spots (Workflow / Sub-Agents `## Agent Context` / Agent Teams / SDK / Claude.ai x2 / OpenSpec export body). Deliberately did NOT rename the internal `notes` key (invisible plumbing; renaming ripples through serialize/deserialize/awd:meta/data-key/all generators + breaks saved-workflow compat). Also DECIDED (and left unchanged): presets correctly fill Agent Prompt (the role template) not Agent Context (user's task-specific extras, rightly empty; only foreign imports fill Context, from an artifact's description).
- files: index.html (7 output labels via 2 replace_all), README.md + TECHNICAL.md (reworded prose + fixed a stale mapping line), tests.html ("Agent Context label" describe, 1 test across 5 formats + OpenSpec)
- status: current | date: 2026-07-01 | note: 1189 -> 1190, then -> 1193 with the import<->export asymmetry fix. No test pinned the old "Additional context" string (grep-confirmed pre-edit) so nothing broke. FOLLOW-ON: export embeds notes into the artifact instruction as an "Agent Context:" block (provenance-independent - import+edit+re-export bundles it like native); foreign import now `openSpecExtractAgentContext()` pulls that block back into notes + strips it from the prompt (no re-export dup) and NO LONGER maps a foreign `description` into Agent Context (description is metadata; only backfills prompt when no instruction). awd:meta stays lossless for normal round-trips; this fixes the awd:meta-stripped (openspec schema fork) case. +3 round-trip tests. Content-lint. One unrelated "additional context" line (decision re-spawn feedback) correctly left alone.

## expand-textarea-modal

- record: .workflow/expand-textarea-to-modal.md
- intent: summon a large modal editor for any text box (Requirements, Workflow Context, Agent Prompt, Agent Context, the Agent-editor customAgentPrompt/customAgentNotes, and the Prompt Library add-prompt customPromptBody) so users can draft/review long specs+prompts in-app instead of an external editor - without losing the streamlined inline boxes. Affordance: a discreet top-right corner button (`taExpandButton`, ~40% opacity) on each wired field, PLUS `Cmd/Ctrl+E` while ANY textarea is focused (own keydown listener, since the main handler early-returns on field focus). KEY DESIGN: the modal is a REMOTE CONTROL, not a copy - `syncTextExpand` writes the modal value back to the source AND dispatches the source's own `input` event, so validateStoryInput/updatePrompt/autosave/the config data-key binding all fire exactly as inline typing (no save/cancel/reconcile -> regression-proof; closing just closes). DRY wiring: config fields get the button via the shared `configTextarea()`; static fields wrapped at init by an idempotent `enhanceExpandableTextarea()` (no duplicated button markup). Overlay z-index 500 -> works modal-over-modal (from inside the Agent/Prompt form modals). Live word/char count + "changes save automatically" + caret preserved; Esc/Done/backdrop close + focus returns to source. `textExpandTitleFor` picks a friendly title (config <label> > id map > dataset override > "Edit text").
- files: index.html (`.text-expand-*`/`.ta-*` CSS; `#textExpandOverlay` markup; REMOVABLE JS block openTextExpand/syncTextExpand/closeTextExpand/textExpandTitleFor/taExpandButton/enhanceExpandableTextarea + Cmd/Ctrl+E & Esc listener; one-line configTextarea wrap; a help-modal paragraph), tests.html ("Expand-to-modal text editing" describe, 7 tests + 8 bridge exports)
- status: current | date: 2026-07-01 | note: 1181 -> 1189 (+8). Additive/removable; no existing behavior changed (inline fields render inside a positioned .ta-wrap, otherwise identical). FOLLOW-ON: the agent-node context badge (top-right pencil) now opens that agent's Agent Context in the modal (editAgentContext = selectNode + openTextExpand on [data-key=notes]); guarded/removable, mousedown-stopPropagation so it doesn't drag. Found via the pencil showing on imported schemas (foreign import puts an artifact's description into Agent Context) but not presets. Headless screenshots viewed: discreet corner button on Requirements+Workflow Context (no text overlap); expanded modal shows title, big editor w/ preserved caret, live count, "changes save automatically", Done. A test proves a modal edit fires storyInput.oninput -> Refine gate flips disabled->enabled (remote-control design proven). Content-lint; temp files removed. UNCOMMITTED (Blue commits).

## import-autofit

- record: .workflow/import-autofit-and-zoomfit-defer.md
- intent: importing a workflow now FITS the view (was overflowing until a manual Fit click; presets already fit via loadPreset->autoLayout). Fit added to `importWorkflowFile`'s 3 success branches ONLY - deliberately NOT in the shared `deserializeWorkflow` (undo/redo + autosave-restore also use it, where an auto re-fit would fight the user's view). Decision: `zoomFit` now SELF-DEFERS via setTimeout(0), so every caller just calls `zoomFit()` - no wrapper, no raw-setTimeout sprinkle. Safe because the fit MATH is sync-correct (node w/h are static NODE_DEFAULTS, getBoundingClientRect forces layout - proven headlessly a sync fit took a 2140px/8-node import 1 -> 0.392), so a one-macrotask defer is strictly safe; confirmed no caller needs a synchronous fit (only the Fit button + the mutation sites call it; no test references it). A named `fitViewSoon()` wrapper (pure zoomFit + explicit defer at call sites) was considered then dropped for the simpler single-function surface. Tradeoff accepted: zoomFit is now fire-and-forget async (no instant sync fit; nothing needs one today).
- files: index.html (`zoomFit` self-defer via setTimeout(0); 3 fit calls in importWorkflowFile; autoLayout/addFanIn/addFanOut simplified from raw setTimeout(zoomFit) to zoomFit()). No test change - the import path is async FileReader; verified via headless harness (7-artifact foreign schema -> 8 nodes, 2140px vs 1280px viewport, auto-fits zoom 1 -> 0.392, re-confirmed after baking in the defer).
- status: current | date: 2026-06-30 | note: 1181/1181 (call-site simplifications behavior-preserving - zoomFit was already effectively deferred at every mutation site - plus the new import fit). Content-lint. Temp harness files removed.

## refine-plan-clipboard

- record: .workflow/refine-plan-clipboard-roundtrip.md
- intent: QoL for the copy-heavy Refine/Plan round-trip. The generated Refine and Plan prompts now instruct Claude Code to put the result on the SYSTEM CLIPBOARD (in addition to writing `.claude/specs/{slug}.md` / `.claude/plans/{slug}.md`), so paste-back into the Workflow Designer (Refine -> Requirements box, Plan -> Workflow Context box) is one paste instead of open-file-copy-paste. New pure helper `clipboardCopyInstruction(filePath)` - cross-platform PIPE form (`cat FILE | pbcopy` macOS / `... | xclip -selection clipboard` or `... | xsel -b` Linux / `... | clip.exe` Windows), with `clip.exe` covering PowerShell/cmd/Git Bash/WSL, and a graceful manual-copy fallback when no clipboard tool exists. KEEPS the file (persistence + fallback). Best-effort, non-destructive; Claude Code only (Claude.ai web falls back to the file).
- files: index.html (clipboardCopyInstruction helper; the "Finally" blocks in generateRefinePrompt + generatePlanPrompt; two inline help notes), tests.html (helper cross-platform test + 2 existing refine/plan tests updated to new wording + clipboard assertions)
- status: current | date: 2026-06-30 | note: 1177/1177 (+1 helper test; reworded "paste them into" -> "Paste it into" broke 2 pinned assertions -> updated to the new wording + pbcopy checks). Windows question resolved: clip.exe is a native Windows binary reachable from every shell (PowerShell/cmd/Git Bash/WSL); switched to the pipe form for shell robustness.

## input-gating

- record: .workflow/generate-plan-prompt-input-gating.md
- intent: gate Generate Plan Prompt on the requirements input (disable when empty, with a why-tooltip) for a consistent affordance with Auto Workflow + Refine. KEY DECISION: Plan gates like REFINE (non-empty), NOT like Auto Workflow (>=6 words prose) - Plan/Refine work with a bare Jira URL and short specs (they fetch the ticket and plan against it), whereas Auto Workflow's prose gate is specific to its keyword-picking; gating Plan the strict way would wrongly disable it for a valid ticket URL. Added `planBtn` id + `validateStoryInput` gating + disabled-state tooltips on Refine/Plan (enabled-state descriptions skipped - inline Quick start/Optional help already covers them); click-time self-check retained as a safety net.
- files: index.html (planBtn id; validateStoryInput gates planBtn + Refine/Plan tooltips; 1 help-modal sentence), tests.html ("Input gating" describe, 4 tests)
- status: current | date: 2026-06-30 | note: 1176/1176 (+4). Tests pin the decision: bare Jira URL + short (<6-word) spec keep Plan/Refine enabled while Auto Workflow stays disabled; empty disables all; a sentence enables all. Confirmed generatePlanPrompt and generateRefinePrompt have identical preconditions.

## workflow-management-ui

- record: .workflow/workflow-management-ui-and-tooltips.md
- intent: UI polish (markup only, behavior-inert). (1) Folded the Handoff button into the Export dropdown (Export -> Workflow JSON / OpenSpec schema / Handoff package) - Handoff IS an export (a resume `.md` package) - so Workflow Management fits one row (Save . Clone . Export . Import); standalone Handoff button removed. (2) Added a tooltip to the previously-untitled Clone button (Clone = save-a-copy: renames to "(copy)" so the next Save creates a new workflow); kept the SHORT label so the row stays one line (a longer "Save Copy" would re-break it). (3) Focused tooltip-consistency pass: toolbar mode buttons (Select/Connect/Delete with their VERIFIED 1/2/3 shortcuts), view buttons (Auto Layout/Fit/zoom), and the five output tabs (condensed from the help modal); deliberately skipped self-evident (Save/Import) and inline-documented controls (toggles, generate buttons).
- files: index.html (Export menu markup + Handoff menuitem, removed standalone Handoff button, Clone/toolbar/tab titles, 2 help-modal refs), README.md (Handoff bundle -> "Export -> Handoff package"). No JS logic, no tests (title/markup only).
- status: current | date: 2026-06-30 | note: 1172/1172 (unchanged - behavior-inert). Screenshots confirmed one-row + the Export menu (Workflow JSON / OpenSpec schema / Handoff package); the 1/2/3 mode shortcuts were confirmed against the keydown handler before being claimed in tooltips. Decisions: Handoff-in-Export over a Save split-button; tooltip over relabel for Clone; scoped (not blanket) tooltips.

## portable-agents-library

- record: .workflow/portable-agents-library.md
- intent: Agent Library (backlog #11 DONE) - save a configured agent node as a named, versioned, SHAREABLE preset (localStorage `awd_custom_agents`) and instantiate it onto the canvas as a normal 'agent' node (NO new node type). Source-partitioned (user|org|builtin) with NAMESPACED ids (`user:<slug>` / `org:<pack>/<slug>`) so an org import can NEVER clobber the user's own agents; version-aware merge via `compareAgentVersions` (incoming > local updates, equal/lower no-op); an org pack spoofing a `user:` id is re-namespaced to org. Optional author-controlled `version` + auto `updated`. Mirrors the custom-prompts feature (CRUD + export/import JSON packs + a form overlay + a REMOVABLE block). UI: its OWN toolbar "Agents" button + `#agentLibOverlay` modal (NOT nested in the Prompt Library - decided 2026-06-30 because nesting stacked two near-identical toolbars and conflated copy-paste prompts with instantiable node configs; a "Library"+tabs option was considered, separate button chosen). Inert until used (no agents -> toolbar + hint only).
- files: index.html (REMOVABLE block `// === Custom agents (portable agent presets / Agent Library) - REMOVABLE ===`: data/CRUD/merge + toggleAgentLib/renderAgentLib/rerenderAgentLib/renderAgentLibrary/agentCardHtml; toolbar "Agents" button; `#agentLibOverlay` modal; `#customAgentOverlay` form; NO renderPromptLib hook; help modal + README "Agent Library" sections), tests.html ("Custom Agents (Agent Library)" describe, 10 tests incl. own-modal render + not-in-prompt-lib, + bridge)
- status: current | date: 2026-06-30 | note: 1172/1172 (+19; FAVORITE-TO-PALETTE: a star/pin on agent cards adds an agent to a "Custom Agents" group in the Add Nodes palette as a one-click add (instantiateAgent). Favorites are a SEPARATE user-owned id list `awd_agent_favs` (not a flag on the agent) so favoriting an ORG agent survives pack re-import; palette hidden when empty; renderAgentPalette guarded hook at init + on fav/save/import/delete; node-type buttons untouched. Also: the save/edit FORM exposes the full agent config - Agent Type/Model/Max Turns/Tools chips + Name/Version/Prompt/Context, mirroring the node config panel. The Agent Type select now FUNCTIONS via a node-independent `applyAgentTypeChange(config,newType,currentPromptText,label)` helper (writer tool-defaults + fill-blank-prompt-from-role-template via getEffectivePrompt which reads only config+label); the node panel was deliberately NOT refactored onto it (committed core, no-regression priority) - helper is node-panel-compatible for a future safe DRY. Plus a search box mirroring the Prompt Library - filterAgentLib hides non-matching cards + empty source groups, query preserved across re-render). Custom user-defined groupings DECLINED as premature (source grouping suffices; lightweight optional group-field parked). Built end-to-end via the DOGFOOD workflow (Planner->Implementer->Tester->Skeptic, memory+durable+grounding on, run warm) - dogfood findings in the record (kickoff spec + Skeptic review = highest-value beats; live per-step record cadence fits multi-agent runs better than a single warm session). UI screenshot confirmed source-grouped cards (My Agents = Add/Edit/Delete; Org = Add only). Non-clobber is structural (namespaced ids), proven by the spoof test.

## loop-prompt-library

- record: .workflow/loop-prompt-library-variants.md
- intent: add a "Loops" category to the Prompt Library with three fill-the-blanks loop builders - Converge to a Metric (measurable target, hill-climb), Best-of-N (explore diverse candidates, score, keep best), Critique and Refine (judgment-gated by an adversarial critic, no metric). Chosen on the measurable-vs-judgment x refine-vs-explore axes so they are genuinely distinct, not copy-paste. Each seeds its objective via the input popup (`input.find` = `[your objective]`, token in the body not the stripped preamble) and enforces the remaining fields with a hard Step 0 "validate before looping, else STOP and ask" gate - the forcing function the single-field input UI cannot provide (the agent judges quality, e.g. is the criterion measurable, not mere presence). Variant anti-failure rules: Converge = sacred measurement + cap + stall + honest MET/NOT MET exit; Best-of-N = real diversity + honest identical scoring + disqualify-on-invariant + auditable scoreboard; Critique = concrete quality bar + adversarial/independent critic + "no blocking issues" stop (not perfection).
- files: index.html (new `{ category: 'Loops', prompts: [3] }` in PROMPT_LIBRARY between Code Quality and Code Generation; pure curated content, no code change), tests.html ("new prompt categories" describe +4 tests incl. end-to-end replace/strip mirroring confirmPlibInput)
- status: current | date: 2026-06-28 | note: 1143/1143 (+4). Additive only - count tests are `>=`, copy-button-per-card auto-scales. Single-field input limitation handled by seeding the objective via the popup + Step 0 agent-enforced completeness for the rest. Deferred: a visual "Goal Loop" preset (MAX_ITERATIONS -> maxRevisions, measurement -> gate condition) and multi-field input UI. Critique-Refine is the single-prompt form of the shipped generic adversary/critic + review-loop.

## custom-prompts-library

- record: .workflow/custom-prompts-library.md
- intent: make the Prompt Library user-extensible - add/edit/delete your own prompts (localStorage `awd_custom_prompts`), shown under a "My Prompts" category with a CUSTOM badge + Edit/Delete, plus JSON export/import for backup and sharing (dedupe-by-title). Integrates through ONE seam, effectivePromptLib(), which returns the exact PROMPT_LIBRARY reference when there are no custom prompts (inert until used) and appends custom LAST so the index-based render/copy/favorite plumbing keeps stable built-in indices; user title/desc escaped; works with search + favorites + the input popup for free; local-first (no network).
- files: index.html (core seam effectivePromptLib() + 9 PROMPT_LIBRARY->effectivePromptLib() swaps in render/copy/favorite + buildPromptCard custom branch + guarded toolbar; REMOVABLE block: getCustomPrompts/saveCustomPrompts/newCustomPromptId/rerenderPromptLib/open|close|saveCustomPromptForm/deleteCustomPrompt/exportCustomPrompts/mergeImportedPrompts/importCustomPromptsFile + #customPromptOverlay form), tests.html ("Custom Prompts (Prompt Library)" describe, 7 tests, + win-bridge), README + help modal (Prompt Library section)
- status: current | date: 2026-06-28 | note: 1131/1131; localStorage only (no fetch/XHR). Export format {format:'awd-custom-prompts',version:1,prompts:[{id,title,desc,prompt}]}; import also accepts a bare array and dedupes by title (update-in-place). effectivePromptLib() === PROMPT_LIBRARY when empty (tested identity) so behavior is byte-identical until used; degrades to PROMPT_LIBRARY if the block is removed. Search + favorites verified with custom prompts present.

## openspec-schema-export

- record: .workflow/openspec-schema-export-and-roundtrip.md
- intent: export a designer workflow as a valid OpenSpec (@fission-ai/openspec) custom schema (one artifact per WORK node - agent or task: id<-label, instruction<-prompt/spec+forwarded config/gate-loop/join intent, requires<-upstream-work edges, template per artifact, apply block) AND a lossless round-trip import - a `# awd:meta` comment carries the full serializeWorkflow() JSON so re-import reuses the existing deserializeWorkflow (no YAML parser). Additive 6th export ("OpenSpec" button in the Export area, NOT a tab, NOT a fork); review-loop back-edges dropped so requires stays a DAG. WYSIWYG-completeness: every node type reflects into the schema body - tasks become artifacts (description+acceptance), output nodes become apply deliverables (PR/commit/report/docs+branch/target), input source+detail go into the description, parallel any/race join is described in branch prose; agent model/tools/maxTurns ride as instruction intent (no native slot). Export is a real `.zip` of the `openspec/schemas/<name>/` tree (dependency-free store-only writer) so it drops into a repo and validates (templates are required on disk).
- files: index.html (REMOVABLE block: openSpecSlug/openSpecYamlBlock/openSpecParallelJoinNote/openSpecStepIntent/openSpecInstruction/openSpecContextBlock/openSpecOutputLine/openSpecUpstreamWork/openSpecExtractMeta/OPENSPEC_ROLE_GROUP+OPENSPEC_RECORD_SECTIONS/openSpecRecordSections/openSpecTemplate/buildOpenSpecSchema/openSpecCrc32/openSpecZip/exportOpenSpecSchema + the openspecExportBtn button + importWorkflowFile awd:meta+zip branches + Import accept widened), tests.html ("OpenSpec schema export" describe, 26 tests, + win-bridge)
- status: current | date: 2026-06-28 | note: 1124/1124; validated vs real `openspec schema validate` 1.4.1 (linear/parallel/decision/task + role-mix export PASS; round-trip body-lossless + re-export PASS; templates are required on disk -> hence the .zip, stamped with real local time). Templates are role-aware AND node-specific record skeletons (handoff structure; skeptic mirrors the VERDICT contract; tasks get a prefilled acceptance checklist; each encodes graph position + multi-repo checklist + gate readiness) - not empty stubs. Core untouched (5 generators, getDepNodes); reuses core inputSourceHint/strategyJoinPhrase for WYSIWYG parity. FOREIGN-schema import: DONE 2026-06-29 (see openspec-foreign-schema-import.md). Repo Context Paths (rules+product-docs) forwarded into every artifact instruction + apply.

## edge-routing

- record: .workflow/edge-routing-arc-skip-edges.md
- intent: forward skip/bypass edges now arc ABOVE intervening nodes instead of cutting straight through (the forward mirror of the existing back-edge arc-below). New `connectionObstructed(x1,y1,x2,y2,fromId,toId)` (forward-only; a node sits horizontally between endpoints with vertical-band overlap; excludes the edge's own endpoints); `bezierPath`/`bezierMidpoint` gain an `arc` param (lift to min(y1,y2) - max(80, dx*0.12)); render loop computes `arc = !isBack && connectionObstructed(...)`. Geometry-only - data, node positions, adjacent edges, and back-edges unchanged. Heuristic (not full orthogonal routing) but a strict improvement for the common single-row bypass; surfaced by importing a real schema whose apply.requires pointed at a mid-chain artifact.
- files: index.html (core renderer: connectionObstructed + bezierPath/bezierMidpoint arc branch + render-loop wiring), tests.html (+2 tests; bezierPath/connectionObstructed bridged)
- status: current | date: 2026-06-29 | note: 1151/1151 (+2). Visual-confirmed via headless screenshot of a synthetic bypass graph (charlie->Apply arcs over delta/echo). Core renderer change (general fix, not a removable block). Future: true obstacle-avoiding orthogonal routing if dense multi-row graphs ever need it.

- record: .workflow/openspec-export-apply-requires-from-output.md
- intent: `buildOpenSpecSchema` now derives `apply.requires` from the work artifacts that actually feed the OUTPUT node(s) (via `openSpecUpstreamWork`, router-resolved + deduped), falling back to the last artifact when no output is wired - instead of hardcoding the last topo artifact. Makes the OpenSpec terminal gate faithful: a designer output feeding a mid-chain step, or a foreign schema whose apply gates on a non-last step (e.g. apply requires a mid-chain `review` while the chain continues to a later step), is preserved and round-trips instead of being rewritten to "the last step." Output node CONFIG still drives apply.instruction (format->deliverable); this fixes only apply.requires. `tracks` unchanged (separate concern). awd:meta round-trip already lossless; this is about the human/CLI schema + foreign re-export.
- files: index.html (buildOpenSpecSchema apply block: apply.requires from openSpecUpstreamWork over outputs, fallback lastId), tests.html ("OpenSpec schema export" describe +2 tests: divergent designer workflow; divergent foreign round-trip)
- status: current | date: 2026-06-30 | note: 1153/1153 (+2). Common/linear case byte-identical (output feeds last step -> openSpecUpstreamWork = [last] = old lastId), so no existing apply test changed. Verified divergent designer (output->implementer, not last validate) and divergent foreign round-trip (apply<-build preserved, not rewritten to verify).

- record: .workflow/openspec-foreign-schema-import.md
- intent: import an OpenSpec schema.yaml NOT created here (hand-written, openspec-CLI, a teammate's) into the visual designer for viewing/editing - closes the deferred FOREIGN-schema import. Dependency-free YAML-SUBSET parser (`openSpecParseYaml`: top-level scalars, artifacts list-of-maps, apply map, requires inline `[]`/block list, `|`/`>` block scalars, `#` comments, quoted+plain scalars) + inverse-of-buildOpenSpecSchema mapper (`openSpecSchemaToWorkflow`: artifacts->agent nodes with instruction|description as prompt + agentType `general`, requires->edges, apply->output node, layered layout by longest-path depth, cycle-guarded) + pure orchestrator (`openSpecImportForeign` -> deserializeWorkflow-shaped object or null). LOSSY by design (a plain schema has no designer fields, so positions/agentType/model/tools default and are editable). Our own awd:meta round-trip is unchanged and takes precedence.
- files: index.html (REMOVABLE block `// === OpenSpec foreign-schema import ... REMOVABLE ===`; core touch: one guarded branch in `importWorkflowFile` calling it behind `typeof openSpecImportForeign === 'function'`), tests.html ("OpenSpec foreign-schema import" describe, 6 tests; parser/mapper/orchestrator bridged)
- status: current | date: 2026-06-29 | note: 1149/1149 (+6). CLI cross-checked: ran an `openspec schema init`-generated schema.yaml through the importer headlessly (3 agents Proposal/Specs/Tasks + Apply output, 3 edges, deserialized) - confirms OpenSpec's own style (plain unquoted scalars w/ commas, omitted instruction, block lists, inline `[]`). Defensive: missing-requires dropped, non-schema -> null, cycle-guarded, no crash. Subset only (no flow maps / anchors / multi-doc). Re-export of an imported foreign schema is structure-faithful but not byte-identical (ids regenerate from labels).

- record: .workflow/openspec-export-cross-tool-grounding.md
- intent: cross-tool grounding (read side, backlog #9 DONE) - an OpenSpec run authored by our exporter now reads our `.workflow/` records. Gated pure helper `openSpecGroundingBlock()` (compact distill of `consumeRecordsHint`, gated on `state.consumeRecords`) prepended to the FIRST artifact's instruction in `buildOpenSpecSchema`; downstream steps inherit via `requires`; self-gating on greenfield. Closes grounding direction (c) of four (run-type x format). Direction (d), our prompt runs reading OpenSpec docs, deliberately NOT solved by a polyglot reader - the chosen path is converge-on-one-index (OpenSpec writes a breadcrumb back), = backlog #10 - CLOSED 2026-07-02 by self-improvement-loop (the exported apply step now writes the one-line _timeline.md/_index.md breadcrumb back, self-gated on the target repo keeping a .workflow/ system).
- files: index.html (core: shared `groundingLookupSteps()` + `wrapComment()`; `consumeRecordsHint` composes from the shared source byte-identically; `genAgentSDK` grounding renders it via wrapComment. REMOVABLE OpenSpec block: `openSpecGroundingBlock()` + first-artifact injection in `buildOpenSpecSchema`. Help modal "OpenSpec export" read-side/write-side split), tests.html ("OpenSpec schema export" + "Export: genAgentSDK" describes, +7 tests net; `openSpecGroundingBlock`/`groundingLookupSteps` bridged)
- status: current | date: 2026-06-28 | note: 1139/1139. Default-on (`consumeRecords` defaults true) so default exports now carry the grounding preamble on the entry artifact - intended + runtime-self-gating; broke no existing OpenSpec test. Round-trip unaffected (re-import reads awd:meta, not instructions). Lighter option (preamble on existing artifact, no DAG change). Write side still excluded (fights OpenSpec generate-once model). DRY: the 3-tier lookup prose is now ONE source (`groundingLookupSteps()`) feeding ALL THREE consumers - prompt outputs (`> -` blockquote, full set, BYTE-IDENTICAL verified by source diff), SDK (`#` comments via wrapComment, full set, gained supersede+siblings parity), OpenSpec (plain bullets, read subset). Shared helpers in core, so removing the OpenSpec block leaves prompt+SDK grounding intact.

- record: .workflow/openspec-export-durable-record-toast.md
- intent: durable-record expectation toast. The three memory/record toggles drive only the prompt generators; the OpenSpec export calls no `gen*` protocol, so all three are silent no-ops on it. When Keep-a-durable-record is ON at export, the success toast (and a help-modal paragraph) now note the run leaves OpenSpec's per-step records, not the single `.workflow` flywheel doc - closing the expectation gap for the one surprising toggle (the "write side"). Messaging-only; export behavior unchanged. Durable-OFF stays the plain success line (no nag). Memory/grounding deliberately not messaged (memory is ephemeral scratch; grounding read-side is backlog #9, a real feature not a note).
- files: index.html (REMOVABLE OpenSpec block: pure helper `openSpecExportToast(name,durable)` + `exportOpenSpecSchema` uses it, 7s dwell when durable; help modal "OpenSpec export" paragraph), tests.html ("OpenSpec schema export" describe +2 tests; `openSpecExportToast` bridged)
- status: current | date: 2026-06-28 | note: 1134/1134 (+2). Pure string-in/string-out helper so the wording is pinned for both toggle states without a brittle DOM-toast assertion. Rejected carrying the durable record into OpenSpec (fights its generate-once-per-doc/DAG model; no native running-state slot) - the per-step record templates are the OpenSpec-native handoff. Read-side cross-tool grounding parked as backlog #9.

## durable-record-cadence

- record: .workflow/durable-record-transcribe-handoff.md
- intent: lighter half of backlog #2 - make the orchestrator's per-step durable-record update a TRANSCRIPTION (each step asked to end its report with DONE: items + STATUS: one-line; orchestrator transcribes) rather than a re-derivation. Single additive bullet in genDurableRecordProtocol KEEP CURRENT; gated on Keep Durable Record (off = absent); Ground-in-Prior-Records unaffected
- files: index.html (recordHandoffHint() helper + 6 per-agent injections [genWorkflow x2, genSubAgents, genAgentTeams, genClaudePrompt x2] + reconciled KEEP CURRENT bullet in genDurableRecordProtocol), tests.html (recordHandoffHint bridged; v2.4 + v2.5)
- status: current | date: 2026-06-21 | builds-on: .workflow/durable-record-per-step-cadence.md | note: 1083/1083; FULLER agent-side version - the reliable actor (each agent) emits DONE/STATUS via one reused gated fragment, orchestrator transcribes (reconciled from the orchestrator-only half). Injected via the step-hint pattern (not the postamble, which is only 2 generators). Gated on durableRecord (off=absent, tested); SDK not wired (no step-hint pattern + removal candidate). Heavier interleaved per-step beats (backlog #2 option A) still queued as fallback, to be validated by a build-task dogfood

## handoff-context-reliability

- record: .workflow/handoff-context-reliability.md
- intent: two multi-input-handoff reliability fixes from the audit dogfood - (1) genericize PROMPTS.reportBuilder so it is reviewer-count agnostic (drop hardcoded security/quality/performance/architecture dimensions; conditional per-area breakdown only "where multiple reviewers covered distinct areas"); (2) tag dependency-reference lines with the upstream agent TYPE via new getDepsWithType ("Label (Type)") so a downstream step knows the ROLE behind each output, not just the name - applies to ALL steps, not just reviewers
- files: index.html (getDeps refactor -> getDepNodes + getDeps[unchanged] + getDepsWithType; 7 display-site swaps; PROMPTS.reportBuilder), tests.html (+3 tests), README.md/TECHNICAL.md
- status: current | date: 2026-06-21 | builds-on: .workflow/audit-of-generated-prompt-machinery.md | note: 1080/1080; getDeps contract unchanged (validation untouched); static conditional clause chosen over dynamic generation (cannot degrade the swarm - its inputs ARE the dimensions); genAgentSDK unaffected (no markdown dep lines; removal candidate)

## generated-prompt-audit

- record: .workflow/audit-of-generated-prompt-machinery.md
- intent: read-only audit of the five generators' toggle/feature wiring parity, durable-record cadence, and cross-generator consistency - run as an EXECUTION-dogfood (an Auto Workflow generated workflow, orchestrated end-to-end to surface gaps in the designer's own generated prompts). Deliverable: .workflow/audit-of-generated-prompt-machinery-report.md
- files: index.html (5 generators + shared hint helpers), tests.html (parity suites); NO code changed (read-only)
- status: current | date: 2026-06-21 | note: audit result = 4 prose generators in lockstep, genAgentSDK the sole divergence (10 helpers inline + 4 missing toggle injections + degraded durable-record cadence; NEW: consume-records SDK comment already drifted, untested). Confirms backlog #2 (cadence) + #4 (SDK gaps). Workflow-gaps found by running it: generic role-task vs the actual ask, LSP steps on a single-file app, Report-Builder swarm-template on a 1-reviewer workflow, durable-record protocol does not fit a read-only audit, no dead-step recovery guidance (Step 2 agent died on an API error; orchestrator recovered from this record)

## input-source

- record: .workflow/input-source-freeform-default-and-jira-depth.md
- intent: simplify the Input Source selector to framing-only (Freeform default / User Story / PRD - dropped the two no-op options Jira Ticket + Custom) and route Jira into a richer AUTOMATIC, content-driven experience. Jira handling was never on the dropdown - an Atlassian URL (bare or inline) triggers atlassianTicketFetchHint; enriched that up-front resolution to pull description+acceptance criteria, parent epic, sub-tasks, blocking/linked issues, and recent comments so the orchestrator's ORIGINAL PLAN reflects the full picture
- files: index.html (NODE_DEFAULTS input source jira->freeform; configSelect 4 opts->3; generateFromStory input->freeform; App Source preset custom->freeform; atlassianTicketFetchHint depth enrichment - pinned phrase `resolved ticket is the spec` preserved), tests.html (source-framing tests rewritten: freeform-default silent + legacy jira degrades silent; + Atlassian resolution-depth test), README.md + TECHNICAL.md (Input Source)
- work-item: follow-on from node-config + input-source UX discussion | status: current | date: 2026-06-20 | builds-on: .workflow/node-config-options-drive-output.md | note: 1076/1076; bare-key auto-detection deliberately avoided (false-positives COVID-19/UTF-8 - keyed off Atlassian URLs); legacy jira/custom values degrade to silent (single user, no migration); probe-verified bare+inline URL deep resolution + clean plain text

## node-config-output

- record: .workflow/node-config-options-drive-output.md
- intent: make three inert node config controls drive the generated prompt - Parallel `strategy` (join semantics in all 5 generators; SDK maps any/race to asyncio.wait FIRST_COMPLETED, race cancels pending), Task nodes (were dropped wholesale; now a Tasks section with description + `Done when:` acceptance), Input `source` (story/prd add a one-line framing hint; jira/custom stay silent). Each option's default is byte-identical; new behavior fires only on a non-default value
- files: index.html (helpers strategyJoinPhrase/forkStrategyOf/taskSectionLines/taskSectionComments/inputSourceHint; 5 strategy sites + 5 task-emission sites + 2 source-hint sites in requirementsBlock & genAgentSDK), tests.html (4 describe blocks / 12 tests), README.md + TECHNICAL.md (Task/Parallel/Input node config + "Node config that drives output")
- status: current | date: 2026-06-20 | note: 1064/1064 (was 1052); no preset/Auto Workflow creates Task nodes or uses story/prd source, so all existing output is byte-identical (existing suite + new baseline tests confirm); Parallel/Input `description` deliberately NOT emitted (content already carried globally - would duplicate + regress); surfaced the separate Auto Workflow no-implementer gap (this task's own auto-generated workflow was discarded for having no builder)

## adversarial-review

- record: .workflow/generic-adversarial-critic-agent-with-one-click-attach.md
- intent: a generic refute-first `adversary` agent role (one template + role-aware lens + strict materiality bar: default PASS, NEEDS REVISION only for Critical/High material defects, never nitpicks) plus a one-click context-menu action that attaches/detaches a critic + Decision + back-edge revise loop on any Agent/Task node in a single undoable step, reusing the existing Decision/maxRevisions loop so all five generators render it unchanged CONVERGENCE REWRITTEN 2026-07-03: honest verdicts always (never PASS with Critical/High findings; orchestrator owns proceed-after-cap), delta-scoped re-reviews, cycle index passed by generators - see prompt-overhaul-wave-a.
- files: index.html (AGENT_TYPES +adversary, AGENT_TYPE_PROMPT_MAP, ADVERSARY_LENSES + ADVERSARY_LENS_BY_ROLE + buildAdversaryPrompt, getEffectivePrompt/classifyAgentPrompt adversary branch, attachAdversary/detachAdversary/toggleAdversarialReview/hasAdversaryAttached/canAttachAdversary via batchUndo, ctxAdversary markup + showContextMenu, feature + documentation preset demos), tests.html (5 new suites / 23 tests; AGENT_TYPES length 11->12; feature 4->5 agents; documentation memory-enabled; AGENT_TYPE_PROMPT_MAP added to win.* bridge)
- status: current | date: 2026-06-18 | note: independent review PASS; lens travels via config.adversaryRole (parallels writer/writingStyle); demoed sparsely in 2 presets (Feature->Planner = plan, Documentation->Doc Writer = docs); deleting a target leaves its critic+decision orphaned; debate panel deferred. SUPERSEDED-IN-PART by verifier-and-review-loop-family.md (2026-06-19): the display name became "Skeptic", markers became reviewLoopFor/reviewLoopKind/reviewLoopDecisionFor, and the attach was generalized into a kind-parameterized family - the behavior here is unchanged, see that record for current code.

- record: .workflow/verifier-and-review-loop-family.md
- intent: a second one-click review kind, a Verifier that PROVES the outcome meets the objective with evidence (run it, call the API, drive a browser, follow doc steps) - distinct from the Skeptic which critiques by inspection; plus generalizing the one-click attach into a kind-parameterized review-loop family (REVIEW_LOOP_KINDS + generic functions/markers) so a third kind is trivial; plus renaming the Skeptic's display (id stays 'adversary')
- files: index.html (AGENT_TYPES Skeptic rename +verifier=13, AGENT_TYPE_PROMPT_MAP +verifier, PROMPTS.verifier, REVIEW_LOOP_KINDS + attachReviewLoop/detachReviewLoop/toggleReviewLoop/getReviewLoop/hasReviewLoop/canAttachReviewLoop + 5 back-compat aliases, ctxSkeptic+ctxVerifier + showContextMenu setReviewItem, feature+documentation preset markers/labels), tests.html (+16 tests: verifier role/prompt/family; length 12->13; Adversary->Skeptic; marker renames)
- work-item: backlog #7 follow-on | status: current | date: 2026-06-19 | builds-on: .workflow/generic-adversarial-critic-agent-with-one-click-attach.md | note: 697/697 tests; independent reviews PASS (x2); verifier has NO lens (one strong default prompt, method self-selected per artifact); verifier gets Bash+WebFetch; one review loop per node; review nodes (Skeptic/Verifier) cannot be review targets; demoed in ui_component preset; ALSO includes the reroute feature (setReviewLoopBackTarget + a dropdown on the review-loop decision to re-point the failure back-edge to any work node, edge-only/no new state, canvas redraws live). CONVERGENCE REWRITTEN 2026-07-03 (verifier: never VERIFIED while unmet; delta-scoped re-verify) + verifier gained Write (suggestion-semantics ride-along) - see prompt-overhaul-wave-a / tool-suggestion-semantics

## auto-workflow-detection

- record: .workflow/auto-workflow-default-to-build-guard.md
- intent: a demote-only "default-to-build" guard in generateFromStory so a read-only/non-coding shape (research/review/analysis/test/documentation -> no implementer) is chosen ONLY when the task asks to PRODUCE a read-only deliverable; build tasks whose acceptance criteria are thick with test/doc vocabulary keep their implementer. Surfaced by dogfooding (the auto-generated workflow for the node-config task had no builder). Position-independent (deliverable markers match anywhere; first ~240 chars weigh more), slants to code on ties, can never promote build->read-only
- files: index.html (generateFromStory: NON_CODING guard block w/ READONLY_MARKERS + BUILD_MARKERS + position-weighted strength + demote-to-generic; no CATEGORIES/PRIORITY/shape changes), tests.html (IMPLEMENTERS const; build-shape structural invariant in the fuzz labeled-intent loop; "default-to-build guard" suite +7), README.md + TECHNICAL.md (Workflow Generation guard, replaced stale "leads with the imperative verb")
- work-item: follow-on from node-config dogfood | status: current | date: 2026-06-20 | builds-on: .workflow/auto-workflow-scoring-and-fuzz.md | note: 1071/1071 (was 1064); converged in 2 empirical iterations (dropped "job" build-noun false positive caught by fuzz; test markers tightened to authoring-only so "test suite passes" AC != test intent); demote-only => 289 fuzz read-only cases unchanged; key crux = test acceptance vocabulary is NOT a read-only signal, only "write/add tests" authoring is

- record: .workflow/auto-workflow-scoring-and-fuzz.md
- intent: ultrathink improvement of Auto Workflow (`generateFromStory`) intent detection + Skeptic/Verifier integration + a property-based fuzz harness. Keeps generating BESPOKE workflows (not preset-picking). Fixed verified mis-detections (plurals missed `\bword\b`; no research/review intents; review requests built code). Added: inflection-tolerant keywords; 2 new READ-ONLY intents research (spike->report) + review (audit->report) with leading-verb detection so an imperative wins but mid-sentence "audit logging"/"evaluates X" stays weak; PRIORITY tie-break; Skeptic-on-Planner (standard/complex) + Verifier-on-builder (complex, single builder) via inline wrapReview (no batchUndo); detection toast with near-tie warning; denoiseForScoring strips real-Jira boilerplate (Logistics/CI/Release-pipeline sections, "Database Changes: None") before scoring so a real ticket is not hijacked to DevOps/data
- files: index.html (generateFromStory: CATEGORIES 10->13 (+analysis intent: measure/forecast/cost->read-only report; weakened bare "X vs Y" so a list separator no longer hijacks to research) + inflection + research/review + leading verbs, PRIORITY tie-break, isReadOnlyIntent planner-skip, research/review shapes + selfContained tail guard, primaryBuilder, wrapReview Skeptic/Verifier, toast; Help "Under the Hood" line), tests.html (Auto Workflow fuzz: ~242 labeled + 7 traps + 40 gibberish = ~289 cases; structural invariants; toast assertion), README.md + TECHNICAL.md (Workflow Generation)
- status: current | date: 2026-06-19 | note: 1049/1049 (was 725); read-only intents emit report + zero code-writers (asserted); api still has no dedicated shape (backend Implementer, Tier 3 deferred); verified by headless probes + fuzz

## presets

- record: .workflow/swarm-presets-review-and-delivery.md
- intent: renamed the read-only "Agent Swarm" audit preset -> "Review Swarm" (key stays `swarm`), and added a new showcase preset "Delivery Swarm" (key `delivery_swarm`) - an intricate end-to-end build (20 nodes / 11 agents) that demonstrates the full toolkit in one flow: two parallel fan-outs (Discovery 3-way, Build backend+frontend), the Skeptic doubting the Lead Planner early, the Verifier proving the Integrator late, a final review gate, and tests. Output format `code` (Leave Uncommitted); no preset uses pr.
- files: index.html (4 new house-style PROMPTS codebaseCartographer/requirementsAnalyst/priorArtResearcher/integrator; sidebar items rename+add; delivery_swarm builder; presetPlaceholders.delivery_swarm), tests.html (delivery_swarm count=11 + review-loop suite: Skeptic on planner, Verifier on integrator, 0 dangling, 4 parallel nodes), README.md + TECHNICAL.md preset rows
- status: current | date: 2026-06-19 | note: 724/724; headless smoke clean (0 dangling, no blank prompts, all 5 generators render); reused the Skeptic/Verifier construction pattern from the feature + ui_component presets; naming open to Blue (he floated "Agent Swarm Review"); display labels are independent of the internal keys

## autosave-persistence

- record: .workflow/autosave-toggle-sync.md
- intent: a toggle change now refreshes the awd_autosave workflow snapshot (savePrefs -> autoSaveWorkflow), so a stale snapshot can no longer override a just-saved toggle on reload; fixes the Durable Record checkbox unchecking itself on refresh
- files: index.html (savePrefs +autoSaveWorkflow call), tests.html ("Autosave stays in sync with toggle changes" suite + export parity)
- status: current | date: 2026-06-16 | note: bug only manifests when an autosave snapshot exists (a workflow with nodes); reproduced on the deployed build

## consume-prior-records

- record: .workflow/make-ground-in-prior-records-use-the-full-three-tier-lookup.md
- intent: teach the READ-side grounding guidance the full three-tier lookup - consumeRecordsHint (shared, inherited by all four prose exporters) gains one bullet naming `_timeline.md` (recency, newest-first) + `_index.md` (relevance) and stating the order timeline -> index -> record, judgment-framed ("when recency matters": regression, onboarding, resuming), with `_index.md` still the default entry; the drifted genAgentSDK inline `#`-comment variant brought to parity. Closes the read/write asymmetry where `_timeline.md` was written but never consulted. Write side (genDurableRecordProtocol) untouched.
- files: index.html (consumeRecordsHint timeline bullet + genAgentSDK consume comment), README.md, TECHNICAL.md, tests.html (+8 tests: three-tier order/wording, judgment framing, recency use-cases, all-four-prose-exporter presence, SDK parity, OFF absence, no-fence hygiene)
- status: current | date: 2026-06-23 | builds-on: .workflow/agent-sdk-ground-in-prior-records-gap.md | note: 1095/1095 green; gated on consumeRecords (OFF unchanged); OFF-absence tests also disable durableRecord since the write side emits `_timeline.md` independently. First record to also seed `.workflow/_timeline.md`.

- record: .workflow/agent-sdk-ground-in-prior-records-gap.md
- intent: give genAgentSDK the consume-records (ground-in-prior-records) guidance it lacked - a gated inline Python-comment banner mirroring the SDK's existing mcpAtlassian/mcpCodeSearch blocks; closes the read/write asymmetry the toggle-wiring audit surfaced (SDK wrote records but never grounded in them)
- files: index.html (genAgentSDK consumeRecords banner ~6557-6568), tests.html ("Export: genAgentSDK" suite +4)
- status: current | date: 2026-06-16 | note: surfaced by the toggle-wiring audit; other SDK gaps (clarifyFirst, Datadog, per-step code-search) remain

## orchestrator-identity

- record: .workflow/orchestrator-identity-format-aware.md
- intent: make a generated prompt unambiguous about its format so it is not mis-run (e.g. Sub-Agents as Agent Teams) - orchestratorIdentity(fmt) tracks the format in the identity prose (threaded into consumeRecordsHint + genDurableRecordProtocol), plus an always-on executionModelDirective(fmt) injected early in all five generators that names the run model and forbids the wrong alternatives; also softened a colloquial "teammate" to "colleague" in the durable-record protocol
- files: index.html (orchestratorIdentity + executionModelDirective + consumeRecordsHint(fmt) + genDurableRecordProtocol(fmt) + 8 threaded call sites + 5 directive injection sites), tests.html (export parity + "Orchestrator identity is format-aware" + "Execution-model directive" suites)
- status: current | date: 2026-06-16

## code-search-mcp-option

- record: .workflow/code-search-mcp-awareness-in-agent-role-prompts.md
- intent: per-agent code-search-MCP awareness (gated codeSearchStepHint mirroring datadogStepHint) injected into 8 planning/implementing/navigating roles at the six datadog sites; plus a complementary-not-fallback reframe of the four code-search blocks (standing/Refine/Plan/SDK banner)
- files: index.html (CODE_SEARCH_STEP_ROLES + codeSearchStepHint + six injection sites + codeSearchHint clause + Refine/Plan/SDK-banner reframe), tests.html (export parity + "Code search step awareness" suite + tightened codeSearchHint test)
- status: current | builds-on: .workflow/make-sourcebot-option-general-and-called-code-search-mcp.md | date: 2026-06-15

- record: .workflow/make-sourcebot-option-general-and-called-code-search-mcp.md
- intent: generalize the single "Sourcebot" toggle into a tool-agnostic "Code search (MCP)" option (UI label, injected hint, exporters, docs)
- files: index.html (codeSearchHint + mcpCodeSearch toggle wiring + the four exporter injection sites + two inline hint blocks + SDK comment banner), tests.html, README.md, TECHNICAL.md
- status: current | date: 2026-06-13

## durable-record-protocol

- record: .workflow/write-a-design-overview-of-the-durable-record-system.md
- intent: documentation-only design overview of the durable-record system for a new maintainer - a new TECHNICAL.md subsection covering the four parts (the per-record durable record, `_index.md` relevance lens, `_timeline.md` recency lens, the generated `genDurableRecordProtocol` write-side + `consumeRecordsHint` read-side), the three-tier lookup (timeline -> index -> record), and the six design decisions with their recorded rationale + rejected alternatives (separate timeline file, finalize completion gate, three-tier grounding, transcribe-vs-re-derive, finalize compression, write-index-at-finalize-as-projection). No code change
- files: TECHNICAL.md ("### Durable Record System: Design Overview" under "## Memory Protocol", after the existing "### Durable Record (committable artifact)" reference)
- status: current | date: 2026-06-23 | note: grounded in the durable-record-protocol + consume-prior-records + durable-record-cadence records; Planner -> Researcher (all claims source-verified, zero corrections) -> Doc Writer -> Skeptic (PASS); complements the existing terse wiring reference rather than duplicating it; describes the timeline MECHANISM (the live `_timeline.md` has one dated entry, introduced 2026-06-23)

- record: .workflow/provenance-captures-workflow-shape.md
- intent: enrich the durable record's "Built with (provenance)" line to capture the workflow SHAPE (ordered roles + topology: decision gates/revision caps, parallel forks, Skeptic/Verifier review loops incl. attach points + reroute targets), the notable non-default config (models, significant tool grants, turn limits), and the run context (toggles/MCPs/repo-context) - capped to shape-and-knobs, NOT a full dump (the exported .json/Handoff carry the verbatim pipeline). Answers "should the durable doc include the workflow spec" = yes, as compact provenance
- files: index.html (genDurableRecordProtocol Built-with bullet ~2771; prose-only, protected phrases preserved), tests.html (+1 provenance-shape test)
- status: current | date: 2026-06-19

- record: .workflow/cadence-granularity-and-clarify-sensitivity.md
- intent: two cold-run tunings - KEEP CURRENT now requires ticking EACH checklist item per step (covers one Implementer finishing many items, tick-now-not-at-finalize); and the clarify gate leans toward asking on high-value forks (null/empty/below-threshold, conflicting behavior, contract shape) with a low-stakes escape
- files: index.html (genDurableRecordProtocol KEEP CURRENT bullet + clarifyFirstHint bullet), tests.html (+2)
- status: current | date: 2026-06-16 | builds-on: .workflow/durable-record-per-step-cadence.md

- record: .workflow/durable-record-per-step-cadence.md
- intent: force an enforced per-step KEEP CURRENT cadence (overwrite Current state/next action, tick checklist, fold step output by action - do not batch to finalize) plus an explicit before-Step-1 kickoff, so an interrupted large run is resumable; surfaced by a real run that deferred all record-writing to the end
- files: index.html (genDurableRecordProtocol - new KEEP CURRENT section + kickoff sharpening), tests.html (Durable Record protocol-content +2)
- status: current | date: 2026-06-16 | related: .workflow/compress-durable-record-at-finalize.md (sibling refinement of the same protocol)

- record: .workflow/compress-durable-record-at-finalize.md
- intent: finalize step compresses Verify/Gotchas into a clean spec (no per-agent transcript); surface area marked provisional until grounded
- files: index.html (genDurableRecordProtocol - finalize guidance + surface-area guidance), tests.html (Durable Record protocol-content tests)
- status: current | date: 2026-06-13

## repo-context-paths

- record: .workflow/multi-repo-claudemd-loading.md
- intent: fix the multi-repo CLAUDE.md gap - CLAUDE.md/.claude/rules auto-load ONLY for the launch dir (verified vs Claude Code docs), so secondary repos' rules were silently ignored and our prompts wrongly said "CLAUDE.md already auto-loaded, do not re-read". Now the multi-repo block has agents read each repo's CLAUDE.md/CLAUDE.local.md/.claude/rules before changing it + names the `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir` setup; rulesPathsHint/productDocsHint + sidebar text made repo-aware
- files: index.html (repoBlock ~2103, rulesPathsHint ~1096, productDocsHint ~1116, sidebar text ~467/471), tests.html (+2, updated sidebar assertion), README.md (multi-repo gotcha subsection)
- status: current | date: 2026-06-19 | note: listed Rule/Product paths were already resolved per-repo (correct); only the CLAUDE.md auto-load assumption was wrong. Verified via claude-code-guide vs memory.md + sub-agents.md. ALSO added per-repo rule SCOPING (repoBlock step 4): each repo's CLAUDE.md/.claude/rules govern only that repo's work, the auto-loaded launch-repo CLAUDE.md is scoped to the launch repo (not a global default), conflict -> repo-being-changed wins. Behavioral scoping, NOT hard isolation (launch CLAUDE.md stays in session context; a prompt cannot unload it)

- record: .workflow/repo-context-paths.md
- intent: two settings inputs (Rules/constitution paths + Product docs PRD/ADR) that inject repo-scoped binding-rules and product-goals guidance into generated prompts; flat lists, sticky, per-repo anti-contamination in the hint
- files: index.html (rulesPathsHint + productDocsHint + the two chip-list inputs + savePrefs/restorePrefs + sticky clearCanvas + five injection sites), tests.html, README.md, TECHNICAL.md
- status: current | date: 2026-06-13

## agent-prompt-config

- record: .workflow/agent-prompt-edit-ux.md
- intent: refine the Agent Prompt edit UX - compact textarea that expands on focus, "Edited from the {Role} template" wording + a two-box (Agent Prompt vs Custom Notes) hint, and an undoable Reset-to-template control
- files: index.html (agentPromptStatusBlock + the agent-branch focus/blur and reset binders + the Agent Prompt/Custom Notes configTextarea calls + CSS), tests.html
- status: current | supersedes: .workflow/strengthen-agent-prompts.md | date: 2026-06-13

- record: .workflow/strengthen-agent-prompts.md
- intent: node-config UI shows the attached role template (status line + inline read-only preview + ~6-row textarea) so agents stop looking thin; plus two additive lines (minimality + record-assumptions) to the coder/implementer template
- files: index.html (classifyAgentPrompt + agentPromptStatusBlock + updateConfig agent branch + configTextarea attrs param + PROMPTS.implementer), tests.html
- status: superseded | superseded_by: .workflow/agent-prompt-edit-ux.md | date: 2026-06-13

## delivery-commit-pr

- record: .workflow/output-format-delivery-model.md
- intent: make delivery (commit/push/PR/report/docs) a clean function of the Output node format, removing the separate Delivery toggle. PHASE 1 + PHASE 2 DONE (uncommitted), 723 tests. Delivery is fully format-driven via deliveryBlock(level) dispatch (priority pr>commit>report>docs>code). 5 formats: Leave Uncommitted (code, default, renamed from "Code Changes", value unchanged) | Commit (commit+push, no PR) | Pull Request | Report (writes a real report, never commits) | Documentation (writes real docs per project conventions, never commits). Branch Name shows for pr+commit, Target Branch for pr only. No preset uses pr; performance stays report.
- files: index.html (deliveryBlock/deliveryFormats/deliveryTitle/commitBlock/reportBlock/docsBlock + format dropdown w/ commit + branch-field gating + 5 generator sites use deliveryBlock), tests.html (delivery suite = 5 generators x 5 formats matrix + dispatch/fallback/commit/deliversPr units), TECHNICAL.md (Delivery section + security table + file tree), README.md (Output section)
- status: current | date: 2026-06-19 | note: code changes happen regardless of output node (no output -> leave uncommitted); a single Report output handles code+report (e.g. performance); KEY: keep Code Changes (== no-output default)

## ui-labels

- record: .workflow/workflow-context-agent-context-rename.md
- intent: rename the two free-form context fields as a scoped pair - "Implementation Plan" -> **Workflow Context** (injected into every agent) + a scope sub-label and a hairline separator before the Generate Plan Prompt button; "Custom Notes" -> **Agent Context** (this node only). Generated output section "## Implementation Plan (starting guidance)" -> "## Workflow Context (...)" in all 5 generators. Dissolves the box-vs-button "Plan" overlap + reflects that the field is general context (Blue pasted a Datadog-MCP hint, not a plan). Internal ids/keys (planInput, getPlan, plan, config.notes) UNCHANGED for serialization compat
- files: index.html (Workflow Context sidebar block + Agent Context node field + 5 generator headers + Help-modal refs), tests.html (output-section + helper assertions), README.md (2 refs), TECHNICAL.md (3 refs)
- status: current | date: 2026-06-19 | builds-on: .workflow/button-label-clarity.md | note: kept "Generate Plan Prompt" button + "Implementation Planning" plan-prompt title + the tech-spec template's "## Implementation Plan" section; 705/705; browser-verified

- record: .workflow/button-label-clarity.md
- intent: relabel the three "generate" buttons for clarity - `Generate` -> **Auto Workflow** (in-app build, parallels Auto Layout), `Refine Prompt` -> **Generate Refine Prompt**, `Plan Prompt` -> **Generate Plan Prompt**. Two-tier read: Auto Workflow builds now vs the two Generate-___-Prompt helpers make a prompt to run elsewhere. Fixes "Plan Prompt looks like it acts on the Implementation Plan box"
- files: index.html (3 button labels + helper texts + Help-modal "click X" refs, kept the flow-title h3s; one genClaudePrompt help line), README.md (4 refs); tests.html none (705/705)
- status: current | date: 2026-06-19 | note: UI text only, no logic; browser-verified label fit

## in-app-help

- record: .workflow/help-modal-feature-coverage.md
- intent: cover features that had shipped without Help docs + Blue-requested additions. 3 NEW sections (Review Loops [Skeptic & Verifier - what/when/why], Delivery [output-node format model], Handoff [resume-package export]) + enriched Export Formats (real Workflow vs Sub-Agents vs Agent Teams blurb + rule-of-thumb), Recommended Integrations (+Claude in Chrome), and Canvas/Power-User tips
- files: index.html (help-body: 22 h3 sections total - also added How the Prompts Work, Under the Hood, "Which prep step should I use?" [Refine vs Plan vs Clarify], "Multiple Repos & Rules Files" [+CLAUDE.md gotcha/env-var], flywheel framing in Ground), README.md (Refine & Plan: +Clarify cross-ref + rule-of-thumb), tests.html (help-sections assertion +Review Loops/Delivery/Handoff/Claude in Chrome/How the Prompts Work/Under the Hood/Which prep step/Multiple Repos + README footer URL)
- status: current | date: 2026-06-19 | builds-on: .workflow/documentation-updates.md | note: 724/724; headless render confirms 20 sections in order; review-loops section answers Blue's "when/why they're powerful" (Skeptic=reason/inspect on high-stakes steps, Verifier=execute/prove on runnable outcomes, doubt-early-prove-late = defense in depth); "Under the Hood" mirrors only the AUTOMATIC behaviors (Things-You-Might-Not-Notice was already covered by Canvas Tips/Toolbar Features - not duplicated)

- record: .workflow/documentation-updates.md
- intent: refresh the in-app Help modal (the `?` button) to match the current feature set - four new h3 sections (Editing Agent Prompts, Durable Record, Ground in Prior Records, Clarify Requirements First), an input-aware Generate note, and fixing the stale "Shared Memory" wording to the real toggle names
- files: index.html (.help-body div only - four new h3 sections + Quick Start and Power User Tips edits), tests.html (help-sections assertion extended for the four new headings)
- status: current | date: 2026-06-14

## datadog-mcp-toggle

- record: .workflow/datadog-mcp-toggle.md
- intent: add a first-class "Datadog" toggle to the MCP Integrations panel (default off) that, when on, emits an ORCHESTRATOR up-front production-telemetry grounding block - self-gating on relevance + Datadog availability, bounded plan-shaping read, deep query left to the step; mirrors the consumeRecords/clarifyFirst gate blocks (not the per-step codeSearch hint)
- files: index.html (mcpDatadogToggle UI + state wiring like mcpCodeSearch but default-off/clearCanvas-resets-false + datadogGroundingHint() + four generator injection sites + Help note), tests.html (harness export + resetState + 10-test "Datadog grounding gate" suite)
- status: current | date: 2026-06-14

- record: .workflow/datadog-step-escalation.md
- intent: complete the step-side of Datadog grounding - a toggle-gated per-agent hint (datadogStepHint) injected at the six per-agent generation sites for the reason-about-the-system roles {planner, architect, researcher, debugger, tester}, letting them run their own deeper/differently-angled query only when the orchestrator's bounded read is insufficient; removed the hardcoded Datadog line from PROMPTS.investigator so the toggle is the single source of truth (toggle off = no Datadog anywhere)
- files: index.html (datadogStepHint + DATADOG_STEP_ROLES + six per-agent injection sites + PROMPTS.investigator Datadog removal), tests.html (harness export + inverted run-#7 guard + 11-test "Datadog step escalation" suite)
- status: current | builds-on: .workflow/datadog-mcp-toggle.md | date: 2026-06-14

## atlassian-mcp-fortification

- record: .workflow/atlassian-mcp-fortification.md
- intent: make Atlassian guidance toggle-driven without breaking the Jira-URL-as-input flow - split atlassianHint into a URL-driven toggle-INDEPENDENT ticket-fetch block (orchestrator resolves the ticket once as the SOURCE for the plan, MCP-or-browser fallback, no raw-ticket-plus-plan duplication) and a toggle-driven permissive-but-anti-redundant general block; removed the hardcoded "If an Atlassian MCP tool is available" line from 10 PROMPTS templates; softened validateStoryInput so a Jira URL works in every toggle state
- files: index.html (atlassianTicketFetchHint + atlassianGeneralHint replacing atlassianHint + four generators + SDK + Refine/Plan blocks + validateStoryInput softening + 10 template removals), tests.html (harness export + rewritten unit tests + 4x4 scenario suite)
- status: current | date: 2026-06-14 | follow-up: validate on a real Jira issue post-merge

## delivery-commit-pr

- record: .workflow/delivery-section-enhancement.md
- intent: make committing/pushing/opening-a-PR an explicit opt-in (default OFF) via a new "Delivery" sidebar section + commitPr toggle that gates the five prBlock() call sites (noCommitBlock emitted when off); resolves the prBlock-vs-safety-list contradiction. ALSO (Part B, durable-record-protocol capability) restructured genDurableRecordProtocol's finalize prose into an explicit "### FINALIZE" step + a read-only-steps fold-in point.
- files: index.html (Delivery section + commitPr state wiring like mcpDatadog + noCommitBlock + 5 gated prBlock sites + genDurableRecordProtocol FINALIZE restructure), tests.html (+15 tests)
- status: current | date: 2026-06-14 | related: .workflow/compress-durable-record-at-finalize.md (Part B coexists with it - sibling refinements of the durable-record-protocol finalize guidance, no supersession)

## code-conventions

- record: .workflow/test-convention-discovery-by-recency.md
- intent: make test-writing roles match the project's CURRENT test conventions by discovering them from the most recently modified/added test files (git history or newest-by-mtime), borrowing the designSystemAnalyzer's recency pattern. Strengthened conventionsHint para 2 + added the concrete step to tester/testWriter/testSuiteWriter/bugTester/e2eTester. Language-agnostic per Blue (generic "structure and phrasing of test cases", no JS describe/it idiom). Triggered by a generated tester ignoring the project's naming convention
- files: index.html (conventionsHint para 2 ~1081 + 5 test-role templates), tests.html (+1)
- status: current | date: 2026-06-19 | related: .workflow/comment-discipline-no-ticket-ids.md

- record: .workflow/comment-discipline-no-ticket-ids.md
- intent: tighten the always-on comment directive - forbid ticket/issue IDs (Jira keys, PR numbers) + changelog notes in code comments (git already ties code to its ticket), demand brevity / no comments-for-the-sake-of-it (AI slop), keep the JSDoc-on-API-surfaces allowance; reviewer + fixer reinforce it. Triggered by generated code carrying a Jira key (x3) + a TODO() in a JSDoc block
- files: index.html (conventionsHint para 1 ~1079, PROMPTS.reviewer Comments bullet ~1335, PROMPTS.fixer step 9 ~1326; prose-only), tests.html (+3); also ~/.claude/user/preferences.md (global pref)
- status: current | date: 2026-06-19 | builds-on: .workflow/orchestrator-directives-for-code-comments-and-project-consistency.md

- record: .workflow/orchestrator-directives-for-code-comments-and-project-consistency.md
- intent: bake a soft, always-on orchestrator-level "Conventions" directive into generated workflows (prefer self-describing code over comments incl. tests; comment only for complex/why/project-convention; JSDoc for public APIs; when writing tests, match the project's existing test conventions; repo rules/CLAUDE.md override) + a reviewer line flagging narrating/redundant comments
- files: index.html (new conventionsHint() emitted at the 4 prose generators + an unconditional SDK #-comment block, next to codeSearchHint; one PROMPTS.reviewer "comment the why, not the what" line), tests.html (+9 tests)
- status: current | date: 2026-06-14

## atlassian-mcp-fortification

- record: .workflow/requirements-should-not-be-a-bare-uri.md
- intent: per-step "## Requirements" no longer emits a bare ticket URL (which invited every step to re-fetch); a new requirementsBlock(story, heading) helper points steps at the orchestrator-resolved spec + keeps the URL as a labeled reference when isUrlOnly(story), and emits plain-text input unchanged. Reinforces the resolve-once ticket-fetch protocol at the per-step level.
- files: index.html (requirementsBlock helper + the 4 multi-step generator Requirements sites routed through it; Refine/Plan single-agent prompts left as-is), tests.html (+12 tests)
- status: current | date: 2026-06-14 | related: .workflow/atlassian-mcp-fortification.md (complements the orchestrator-side ticket-fetch; no supersession)

## Archive (superseded)

Superseded entries move here as one-line pointers (record path + superseded_by) so the active sections above track only the current capability surface.

- tool-access-wording -> .workflow/tool-access-wording-and-dry.md - closed-enumeration tool semantics + the toolAccessText DRY extraction (2026-06-30); superseded_by .workflow/tool-suggestion-semantics.md (owner ruling: selections are suggestions, never restrictions - the DRY helper survives and carried the new wording).
