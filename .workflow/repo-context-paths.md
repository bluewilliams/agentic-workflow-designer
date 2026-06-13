# Repo context paths

Work item: none (dogfood). Branch: main. Status: in progress.

## Why and scope
Generated workflows should read and honor a repo's own rules/conventions and its product/architecture docs, not just the per-task spec. Add two optional path inputs to the designer so a user can list repo-level rules/constitution files and PRD/ADR docs; the generated prompt then tells the agents to read and honor them with the right semantics. Three-tier model: (1) constitution/rules = how to build (binding; CLAUDE.md is auto-loaded for free, this captures extra rules paths); (2) product/architecture docs (PRD/ADR) = goals and direction the work must serve and not contradict; (3) spec = this task's contract, already the existing seed input.

Non-goals: a field for the per-task spec (tier 3 is already the seed). Any filesystem access in the designer (it captures path strings; the agents do the reading). Changing unrelated features. Per-repo-specific path selection (genuinely different path sets for different repos in a multi-repo unit of work) is a deliberate future extension, NOT built now: the flat lists apply to all in-scope repos and the hint scopes them per-repo. If repos ever need different path sets, that is a recorded follow-up, and we will pick the right shape then (a per-entry repo tag vs context attached to the repositories list) with real requirements rather than guessing now.

## Requirements
R1 - Two optional path-list inputs (Rules/constitution, Product docs PRD/ADR) MUST exist, each supporting add, remove-one, clear-all, and one-click quick-add suggestions.
- Given the settings panel, When rendered, Then both inputs appear as chip lists with a text input + Add, a per-chip remove, and a Clear-all. [test: Repo context paths > UI > both rules and product-doc chip lists render with input, Add, and Clear-all controls]
- Given a path typed and Added, Then it becomes a chip in that list; Given remove on a chip, Then it is gone; Given Clear-all, Then the list empties. [test: Repo context paths > state > addRulesPath / removeRulesPath / clearRulesPaths mutate state.rulesPaths; product-doc twin]
- Given the quick-add chips, When clicked, Then they add their path in one click (Rules: .claude/rules, CONVENTIONS.md, CONTRIBUTING.md; Docs: docs/, ARCHITECTURE.md, docs/adr/). [test: Repo context paths > quick-add > clicking a rules quick-add chip adds its path; clicking a product-doc quick-add chip adds its path]

R2 - Both lists MUST persist to localStorage and survive a New Workflow reset; only Clear-all empties them.
- Given paths added then savePrefs+restorePrefs, Then both lists are restored intact. [test: Repo context paths > persistence > savePrefs then restorePrefs round-trips rulesPaths and productDocPaths intact]
- Given New Workflow reset, Then the two lists are unchanged (NOT cleared). [test: Repo context paths > persistence > clearCanvas keeps rulesPaths and productDocPaths (sticky, not reset)]
- Given an older awd_prefs blob lacking these keys, When restorePrefs runs, Then it tolerates the absence (lists stay empty, no error). [test: Repo context paths > persistence > restorePrefs tolerates an older awd_prefs blob lacking rulesPaths/productDocPaths (stay empty, no throw)]

R3 - When a list is non-empty its hint MUST be injected at all four exporters AND the comment variant; when empty, nothing is injected.
- Given rulesPaths non-empty, When genWorkflow/genSubAgents/genAgentTeams/genClaudePrompt/comment render, Then the rules hint appears naming the listed paths. [test: Repo context paths > injection > rules hint appears at all five exporters when rulesPaths non-empty (genWorkflow, genSubAgents, genAgentTeams, genClaudePrompt, genAgentSDK)]
- Given productDocPaths non-empty, When the same render, Then the product-docs hint appears. [test: Repo context paths > injection > product-docs hint appears at all five exporters when productDocPaths non-empty]
- Given both empty, When any render, Then neither hint appears (output unchanged). [test: Repo context paths > injection > neither hint appears at any of the five exporters when both lists empty]

R4 - The hints MUST convey the correct semantics.
- Given the rules hint, Then it states the paths are BINDING constraints in addition to the auto-loaded CLAUDE.md, and gives directory-vs-file discovery (a directory: discover relevant rule/convention files by common name; a file: read directly). [test: Repo context paths > hint semantics > rules hint says binding, names CLAUDE.md auto-read, has directory-vs-file discovery and read-only-what-is-listed, no Sourcebot/em-dash/en-dash]
- Given the product-docs hint, Then it states the docs define goals/direction the work must SERVE and not contradict, instructs snapshotting the relevant intent into the durable record's Why/scope, and gives the same directory-vs-file discovery; both hints say read only what is listed (no blind-hunt) and that CLAUDE.md is already auto-read. [test: Repo context paths > hint semantics > product-docs hint says serve/not-contradict, snapshot into durable record Why and scope (lowercase), directory-vs-file discovery, read-only-what-is-listed, no Sourcebot/em-dash/en-dash/literal 'Durable Record']
- Given a multi-repo unit of work, Then BOTH hints instruct the agent to resolve each listed path within each in-scope repository, to let each repository's own rules/docs govern only that repository's work, to NEVER carry one repository's rules or product context into another repository's work (honor each repo's own when they differ), and to treat a path absent in a given repository as simply no-extra-context there, not an error. [test: Repo context paths > hint semantics > both hints carry the per-repo scoping / no-cross-apply language (pick a unique phrase, grep tests.html first)]

R5 - Regression/constraints: the suite MUST stay green with count >= 485, no em/en dashes anywhere (including generated hint text), no triple-backtick fences in any hint string, all generated content provider-neutral.
- Given ./run-tests.sh after the change, Then green with count >= 485. [test: the suite + dash/fence scan]

## Success criteria
- A user can list rules + product-doc paths; they persist across workflows in the same repo, survive New Workflow, and only Clear-all empties them.
- Generated prompts include the correctly-worded rules / product-docs guidance only when paths are listed; output is unchanged when both lists are empty.
- README/TECHNICAL describe the two inputs and the three-tier model.
- ./run-tests.sh green with count >= 485.

## Spec quality check
- [x] Each requirement is testable and unambiguous
- [x] Scope is bounded (Non-goals stated)
- [x] No open clarifications remain (quick-add set and labels resolved)
- [x] Every scenario names a verifying test
- [x] Success criteria are measurable

## Approach and decisions
- Mirror the existing field/list patterns: the `repositories` add/remove list (for the chip UI + render) and the `mcpCustom` persisted field (for the prefs wiring). Two state arrays: rulesPaths, productDocPaths (default empty).
- D1 (quick-add, clarify-resolved): include one-click suggestion chips - Rules: .claude/rules, CONVENTIONS.md, CONTRIBUTING.md; Docs: docs/, ARCHITECTURE.md, docs/adr/. Chose over no-quick-add (less seamless) and minimal (less useful). All generic/provider-neutral; user can still type any path.
- D2 (labels, clarify-resolved): "Rules / constitution paths" with helper "(binding; CLAUDE.md already read)" and "Product docs (PRD / ADR)" with helper "(goals/direction to honor)". Chose over short labels because the helper teaches the constraint-vs-goal distinction inline.
- D3 (sticky, director decision): the New Workflow reset does NOT clear these lists; only Clear-all does; both persist to localStorage. Rationale: they are repo-level context that carries across workflows in the same repo. This differs deliberately from the toggles, which reset.
- D4 (no FS access): inputs capture path strings only; the generated hint is where directory-vs-file discovery is instructed (guidance/examples, not a rigid filename list, so the agent uses judgment per repo).
- Hints are gated on a non-empty array (no separate toggle), injected in the grounding phase near consumeRecordsHint.
- The existing `_restoring` guard in savePrefs/restorePrefs already covers the new arrays (saves during restore are suppressed), so the new prefs cannot self-clobber.
- D5 (multi-repo stance, director decision): keep FLAT lists now; make the hints repo-aware AND repo-scoped - each path is resolved within each in-scope repo, a repo's own context governs only that repo's work, one repo's context is never applied to another's, and a path missing in a repo is fine (empty, not an error). Different-paths-per-repo selection is deferred (see Non-goals). Chose this over building per-repo UI now (scope growth for the less-common case) and over pre-structuring entries as objects (would guess the eventual shape, which is genuinely unknown - per-entry repo tag vs context attached to the repositories list); the real corner to avoid was a silent single-repo assumption, which the repo-scoped hint wording removes.

## Surface area (file -> role) - GROUNDED by Planner 2026-06-13 (baseline re-confirmed 485/485)
Inherited template (consume gate): the `code-search-mcp-option` record maps the toggle/field wiring to replicate. Its line numbers predated the compression change; re-grounded below against the current index.html (6470 lines) and tests.html (3965 lines).

### index.html (grounded line numbers)
- 412-417: Repositories sidebar-section (the chip-list UI precedent: h3 + helper div + `<div id="repoList">` + `addRepoRow()` button). The two new controls go in a NEW sidebar-section placed immediately AFTER this block (after line 417), before the MCP Integrations section at 554.
- 555-575: MCP Integrations sidebar-section (mcpCustomNotes textarea at 573 = the persisted-input precedent; oninput="savePrefsDebounced()").
- 1741-1750: `addRepoRow(path, branch)` - mirror for quick-add-by-value.
- 1751-1754: `removeRepoRow(btn)` - mirror for per-chip remove.
- 1755-1765: `onRepoChange()` - rebuilds state.repositories from DOM, calls savePrefsDebounced + updatePrompt + autoSaveWorkflow. Mirror this sync pattern.
- 1786-1799: `renderRepoRows()` - re-renders rows from state. Mirror for renderRulesRows/renderProductDocRows.
- 1134-1140: state defaults block (repositories: [] at 1134; mcpCodeSearch: true at 1137; mcpCustom: '' at 1140). ADD `rulesPaths: []` and `productDocPaths: []` here.
- 1660-1683: savePrefs (repositories at 1673; mcpCodeSearch at 1675; mcpCustom at 1678). ADD `rulesPaths: state.rulesPaths` and `productDocPaths: state.productDocPaths`.
- 1660: `let _restoring = false;` 1689-1738: restorePrefs (guarded by `_restoring`; repositories restore at 1709; mcpCodeSearch 1715-1719). ADD `if (Array.isArray(p.rulesPaths)) { state.rulesPaths = p.rulesPaths; renderRulesRows(); }` and the productDocPaths twin, tolerating absence. `_restoring` guard confirmed present (covers the new arrays - no self-clobber).
- 4974-5012: `clearCanvas(skipConfirm)` = New-Workflow reset. Resets repositories at 4984, mcpCodeSearch at 4998. The two new arrays MUST NOT be reset here (sticky); add an explicit comment noting they are intentionally NOT cleared.
- 940-943: `codeSearchHint()` (gated `if (!state.mcpCodeSearch) return null;`) - structural precedent for the two new hint functions. 954-963 `consumeRecordsHint()`, 969-979 `clarifyFirstHint()`, 944-948 `customMcpHint()` - the two new hints go adjacent to these (near 948, before consumeRecordsHint).
- Five injection sites (mirror the `const _wfSb = codeSearchHint(); if (_wfSb) { p.push(_wfSb); p.push(''); }` pattern):
  - genWorkflow (5346): after the _wfSb block ends at 5367 (insert _wfRu/_wfPd pushes).
  - genSubAgents (5496): after _saSb block at 5528-5529.
  - genAgentTeams (5741): after _atSb block at 5786-5787.
  - genAgentSDK (5959): comment variant - after the `if (state.mcpCodeSearch) { ... }` block at 6000-6008, add two `if (state.rulesPaths.length)` / `if (state.productDocPaths.length)` comment blocks (mirror the `# -- ... --` banner style; HYPHENS only, no fences).
  - genClaudePrompt (6175): after _cpSb block at 6214-6215.
- NOTE: generateRefinePrompt (inline block at 4083) and generatePlanPrompt (4181) are the refine/plan prompt generators, NOT the four exporters + SDK comment. They are OUT of scope (the spec injects at the four exporters + comment variant only). Do not touch.

### tests.html (grounded line numbers)
- 221-256: `resetState()` harness. Sets repositories: [] (238) and mcpCodeSearch: true (240). RISK: must ADD `win.state.rulesPaths = []; win.state.productDocPaths = [];` here, or arrays are undefined in tests (the exact gotcha the code-search record hit with mcpCodeSearch). Defaults-empty tests and gating tests depend on this.
- 3953: window-exposure line. Exposes codeSearchHint/consumeRecordsHint/etc. ADD `window.rulesPathsHint = rulesPathsHint; window.productDocsHint = productDocsHint;` (and any tested add/remove helpers if asserted by function rather than via state).
- 705-863: `describe('savePrefs / restorePrefs')` - persistence round-trip tests live here (clearStorage+resetState beforeEach at 650). Add the persistence + tolerate-older-blob tests here or in a new sibling describe.
- 2386-2557: `describe('MCP Integrations')` with sub-describes hint functions (2389), export integration (2455), prefs persistence (2530). The new hint-content + gating + default tests mirror this structure.
- 2530-2543: prefs-persistence + New-Workflow-reset-keeps-ON precedent (resetState -> expect mcpCodeSearch true). Mirror for the survive-New-Workflow (sticky) test, asserting the arrays SURVIVE clearCanvas rather than reset.
- COLLISION MAP (verified by grep, case-sensitive .includes()): `toNotContain('Sourcebot')` at 1014/1060/1210/1319/1393; `toNotContain('Durable Record')` at 1248/1271/1272/1273/1321/1394; `toNotContain('Durable Record Index')` at 1280; em-dash `toNotContain('—')` at 1018/1316; en-dash at 1019/1317. The product-docs hint references the durable record in LOWERCASE ("the durable record's Why and scope") so it does NOT match `toNotContain('Durable Record')`. Neither hint may contain 'Sourcebot', em dash, or en dash. 'binding', 'constitution', 'rulesPaths', 'productDocPaths', 'PRD', 'ADR' are ABSENT from tests.html (no collision - safe unique assertion phrases).

### README.md / TECHNICAL.md
- Document the two inputs and the three-tier model (constitution/rules = binding; product docs = goals to serve; spec = the task contract). DONE: README has a new "## Repo Context Paths" section; TECHNICAL has "### Repo Context Paths (three-tier context model)".

### Implementer notes / Gotchas (real, post-build)
- Unique multi-repo scoping assertion phrase chosen: `within each in-scope repository` (grepped absent from tests.html before use). Both hints contain it exactly once. Anti-contamination assertion uses `Never carry one repository` (capital N - matches the hint wording; a lowercase assertion FAILED first run and was corrected).
- The capital literal "Durable Record" survives only in two CODE COMMENTS adjacent to the hints (one pre-existing on consumeRecordsHint, one meta-note rephrased to avoid the literal). It is NOT in any injected hint string. The hint-body grep (comments stripped) shows zero. Reviewer: do not flag the comment occurrences as a gating risk - the tests assert on hint OUTPUT.
- The genAgentSDK comment variant uses box-drawing `─` (the existing banner style) for its `# -- ... --` rules; these are NOT em/en dashes and the dash scan confirms zero true em/en dashes in the new comment text.
- New CSS classes added next to .repo-row: .path-input-row, .path-chips, .path-chip(.path-chip-remove), .path-suggest, .path-clear (no existing chip class existed to reuse).
- Chip text rendered via textContent (not innerHTML interpolation) to avoid markup injection from arbitrary path strings; matches the safety posture of escaping done in the repo-row markup.
- REVIEWER VERDICT (2026-06-13): PASS. Re-ran ./run-tests.sh -> 499/499 green (798ms, >= 485). Verified independently: clearCanvas has ZERO assignments to either array (sticky confirmed); savePrefs persists both, restorePrefs guards with Array.isArray (older-blob tolerant). Both hints carry binding/CLAUDE.md-auto-read/dir-vs-file/read-only + the multi-repo "within each in-scope repository" + "Never carry one repository" + "no-extra-context" scoping; a test asserts the scoping phrase in BOTH hints. Product-docs uses lowercase "durable record's Why and scope"; zero capital "Durable Record", zero "Sourcebot", zero em/en dash, zero triple-backtick fences in any hint STRING (the only capital "Durable Record" literals are pre-existing comments and the unrelated Memory UI h3; the SDK banner uses U+2500 box-drawing, not dashes). Gating: 4 function-call exporters (genWorkflow/genSubAgents/genAgentTeams/genClaudePrompt) each guarded by `if (_xxRu/_xxPd)`, plus 2 genAgentSDK comment-variant gates = all five sites, absent when empty (test confirms). generateRefinePrompt/generatePlanPrompt untouched. Chip text via textContent (no XSS). resetState() initializes both arrays. README + TECHNICAL document the two inputs + three-tier model. Scope minimal: mirrors repositories/mcpCustom; nothing unrelated refactored.

## Task checklist
- [x] Capture baseline (485) - Planner re-confirmed: ./run-tests.sh -> 485/485 green (811ms); Implementer re-confirmed 485/485 (822ms)
- [x] State arrays + defaults (empty) at index.html state block (added rulesPaths: [], productDocPaths: [] after mcpCustom)
- [x] Two chip-list controls in a NEW sidebar-section after the Repositories block, mirroring repoList markup (input + Add + chips + per-chip remove + Clear-all + quick-add suggestion chips); added .path-chip/.path-suggest/.path-clear CSS next to .repo-row
- [x] add/remove/clear-all/quick-add(+FromInput) + render functions (mirror addRepoRow/removeRepoRow/onRepoChange/renderRepoRows), each calling savePrefsDebounced + updatePrompt; dedupe on add
- [x] savePrefs + restorePrefs entries; restorePrefs tolerates older blobs (Array.isArray guard) and re-renders chips
- [x] New-Workflow reset (clearCanvas) skips these two lists (sticky) - added explicit "intentionally NOT reset" comment; zero array assignments confirmed by grep
- [x] Two hint functions (rulesPathsHint, productDocsHint) adjacent to customMcpHint; injected at 5 sites: genWorkflow, genSubAgents, genAgentTeams, genClaudePrompt, genAgentSDK comment variant (HYPHENS-only banner)
- [x] tests.html: ADDED window-exposure for both hint fns + the add/remove/clear helpers; ADDED rulesPaths/productDocPaths init to resetState()
- [x] Tests (14 new): UI render, defaults-empty, add/remove/clear-all (rules + product-doc twin), quick-add, persistence round-trip, survive-New-Workflow (sticky), older-blob tolerance, gating non-empty/empty at all five sites (both hints), rules-hint semantics, product-docs-hint semantics, multi-repo per-repo-scoping (both hints contain "within each in-scope repository")
- [x] README + TECHNICAL (two inputs + three-tier model + sticky/multi-repo semantics)
- [x] run-tests 499/499 (>= 485); em/en-dash scan clean; fence scan clean; grep-before-literal honored (collision map in Surface area)
- [x] Tester independent verification (2026-06-13): re-ran suite 499/499; read all 14 assertion bodies vs implementation; independent hint-body grep (zero Sourcebot/capital Durable Record/em-en-dash/triple-fence; scoping phrase x2); R1-R5 all confirmed; no gap found, no test added. Verdict PASS.

## Verify
- ./run-tests.sh: 485 -> 499 green (+14 tests for this change). Independently re-run by the Reviewer and Tester, same result.
- Hint-body grep proofs (rulesPathsHint + productDocsHint executable bodies, comments stripped): Sourcebot = 0; capital "Durable Record" = 0; em dash = 0; en dash = 0; triple-backtick fence = 0; lowercase "durable record" = 2 (productDocsHint only); scoping phrase "within each in-scope repository" = 2 (one per hint). NOTE: the literal "Durable Record" does appear in two CODE COMMENTS near the hints (consumeRecordsHint's pre-existing comment + a meta-note), never in injected hint strings; tests assert the hint OUTPUT is clean.
- clearCanvas: zero assignments to state.rulesPaths / state.productDocPaths (grep-confirmed); only the explanatory "intentionally NOT reset" comment is present. Sticky behavior covered by the clearCanvas-keeps test.
- All R1-R5 confirmed against the live hint bodies (including the multi-repo per-repo-scoping scenario): both hints inject at all five exporters when their list is non-empty and are absent when empty; the rules/product-docs semantics and the per-repo anti-contamination clause are present; output is unchanged when both lists are empty. No gaps found.

## Outcome
Added two optional repo-context path inputs to the designer: "Rules / constitution paths" and "Product docs (PRD / ADR)", each a chip list with add, per-chip remove, clear-all, and quick-add suggestion chips. Both lists persist to localStorage and are STICKY: a New Workflow reset does not clear them (only Clear-all does), since they are repo-level context. Two gated hint functions (rulesPathsHint, productDocsHint) inject at all four exporters plus the SDK comment variant when their list is non-empty: the rules hint frames the paths as binding constraints in addition to the auto-loaded CLAUDE.md; the product-docs hint frames them as goals/direction the work must serve and not contradict, and instructs snapshotting the intent into the durable record's Why/scope. Both hints carry per-repo scoping so one repository's context is never applied to another's work in a multi-repo run, and treat a path missing in a repo as no-extra-context rather than an error. Different-paths-per-repo selection is a recorded future extension (Non-goals). Surface area touched: index.html (state arrays, the new sidebar-section + CSS, the list functions, savePrefs/restorePrefs, the sticky clearCanvas, the two hints, five injection sites), tests.html (resetState init, window-exposure, 14 tests), README.md, TECHNICAL.md. Tests 485 -> 499 green.

## Built with (provenance)
Produced by the workflow "Repo context paths" (Sub-Agents form, Feature shape), agent roles Planner -> Implementer -> Reviewer -> Tester, driven by an orchestrator that ran an up-front grounding gate (consume - a genuine capability match inheriting the code-search record's surface-area map) and a clarify gate (resolved quick-add and labels) before the first step. Grounded by the committed .workflow/_index.md, the code-search record, and grep over index.html and tests.html.

## Links
- Work item: none (dogfood)
- Branch: main
- PR: TBD
