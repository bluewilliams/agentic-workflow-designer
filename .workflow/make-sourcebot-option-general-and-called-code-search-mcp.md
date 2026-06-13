# Code search (MCP): generalize the Sourcebot option to be tool-agnostic

Work item: none (dogfood of the durable-record system). Branch: main. Status: complete, pending commit by the owner.

## Why and scope
The settings panel has a single "Sourcebot" toggle that injects cross-repo code-search guidance into every generated prompt. It hardcodes one vendor (Sourcebot) in both the UI and the injected text, even though the same guidance applies to any code-search MCP (Sourcebot, Sourcegraph, Kilo Code, and others). Generalize the one option into a tool-agnostic "Code search (MCP)" option so the generated prompts work with whatever code-search MCP a user has, and update user-facing docs to match.

Non-goals:
- Changing what the option does (it still injects code-search guidance at the same sites with the same gating). This is a naming and wording generalization, not a behavior change.
- The "Cross-Repo (requires Sourcebot)" workflow template category (index.html ~3782-3797) is a distinct feature (cross-repo templates), not the code-search option. Grounding correction (Planner): it has NO `state.mcpSourcebot` gating - it renders unconditionally from PROMPT_LIBRARY, so nothing breaks if left alone. Leave it and the "e.g. Sourcebot" PROMPT_LIBRARY/PROMPTS bodies UNCHANGED (out of scope; test 3081 depends on one of them keeping the word "Sourcebot").

## Requirements
R1 - The injected code-search guidance MUST be tool-agnostic: it names multiple example tools as illustrative and mandates none.
- Given the option is enabled, When any exporter renders, Then the guidance names at least two example code-search tools (for example Sourcebot, Sourcegraph, Kilo Code) and presents none as required. [test: hint functions > should name multiple example code-search tools and mandate none (codeSearchHint, MCP Integrations suite)]
- Given the option is enabled, When the guidance renders, Then it contains no claim that a specific named server "is available". [test: hint functions > should not claim a specific named server is available (codeSearchHint asserts toNotContain 'Sourcebot server is available' / 'A Sourcebot MCP server is available')]

R2 - The option MUST inject its guidance at all four exporters and the comment variant when enabled, and omit it everywhere when disabled.
- Given enabled, When genWorkflow / genSubAgents / genAgentTeams / genClaudePrompt render, Then the code-search guidance is present in each. [test: export integration > should include code-search hint in {workflow,sub-agents,agent-teams,claude-prompt} export when enabled - extend existing 'should include Sourcebot hint in sub-agents export when enabled' (2410) and ADD genWorkflow + genAgentTeams + genClaudePrompt cases]
- Given enabled, When the comment (SDK) variant renders, Then the code-search header/guidance is present. [test: export integration > should include code-search header in agent-SDK (comment) export when enabled - NEW, asserts genAgentSDK() contains the generalized header]
- Given disabled, When any of the five render, Then no code-search guidance appears. [test: export integration > should NOT include code-search hint in sub-agents export when disabled (rename of 2748) + NEW disabled cases for genWorkflow / genAgentTeams / genClaudePrompt / genAgentSDK]

R3 - The option MUST default to ON.
- Given fresh state with no saved prefs, When the app initializes, Then state.mcpCodeSearch is true and the checkbox is checked. [test: hint functions > should default mcpCodeSearch to ON - NEW, asserts resetState() leaves win.state.mcpCodeSearch === true (default-state assertion)]
- Given New Workflow is clicked, When state resets, Then the option returns to ON. [test: should reset MCP state on New Workflow (Atlassian on, code-search on) - rename of 2426, asserts win.state.mcpCodeSearch === true after clearCanvas()]

R4 - The option is treated as brand-new: nothing reads, writes, or depends on the old mcpSourcebot localStorage key. A stale old key has no effect.
- Given localStorage holds only the old mcpSourcebot key (no mcpCodeSearch), When restorePrefs runs, Then state.mcpCodeSearch takes its default (ON) and the old key is not read. [test: prefs persistence > stale old mcpSourcebot localStorage key has no effect (no migration) - NEW: write awd_prefs JSON containing only mcpSourcebot:false, call restorePrefs(), assert win.state.mcpCodeSearch === true]
- Given localStorage holds a mcpCodeSearch value, When restorePrefs runs, Then that value is applied. [test: prefs persistence > restorePrefs applies a saved mcpCodeSearch value - NEW: write awd_prefs JSON with mcpCodeSearch:false, call restorePrefs(), assert win.state.mcpCodeSearch === false]
- Decision: no migration and no fallback. The old key is ignored entirely (not read, not written, not deleted). This supersedes the seed's backward-compat requirement #4.

R5 - The guidance MUST describe a discover -> browse -> search -> read flow with a Glob/Grep/LSP fallback when no code-search MCP is available.
- Given enabled, When the guidance renders, Then it includes the discovery flow and an explicit fallback for when no code-search MCP is present. [test: hint functions > should describe a discover/browse/search/read flow with a Glob/Grep/LSP fallback - NEW, asserts codeSearchHint() contains 'discover'/'browse'/'search'/'read' flow markers and 'Glob', 'Grep', 'LSP' fallback terms; also asserts toNotContain em dash and en dash]

R6 - No user-facing string MUST present the code-search OPTION as Sourcebot-only; the UI label and README reflect the tool-agnostic framing (Sourcebot may appear only as one example).
- Given the UI label, When inspected, Then the primary text is "Code search (MCP)" with example tools as secondary helper text. [test: UI label > code-search toggle shows tool-agnostic label - NEW: assert the #mcpCodeSearchToggle label span textContent contains 'Code search (MCP)' and the helper span contains 'Sourcebot, Sourcegraph, Kilo Code']
- Given README, When inspected, Then it describes the option tool-agnostically and names Sourcebot only as an example. [test: manual/doc - README.md line 187/190 + TECHNICAL.md 61/73 reviewed by hand]

R7 - Regression safety: every previously-passing test MUST still pass and the total test count MUST NOT decrease.
- Given ./run-tests.sh, When run after the change, Then it is 100% green with count >= baseline. [test: the suite itself]

## Success criteria
- The injected guidance names two or more example code-search tools and mandates none.
- Generated output is byte-for-byte unchanged when the option is OFF (no guidance leaks).
- No reference to the old mcpSourcebot localStorage key remains anywhere in the code (treated as if it never existed).
- ./run-tests.sh is green with a test count equal to or greater than the pre-change baseline.
- No user-facing string presents the code-search option as Sourcebot-only.

## Spec quality check
- [x] Each requirement is testable and unambiguous
- [x] Scope is bounded (Non-goals stated, including the cross-repo template category)
- [x] No open clarifications remain (label, pref migration, branch all resolved)
- [x] Every scenario names a verifying test (filled once tests are written)
- [x] Success criteria are measurable

## Approach and decisions
- Follow the existing toggle-wiring pattern exactly (mirror consumeRecords / mcpAtlassian): rename the state field mcpSourcebot -> mcpCodeSearch and the hint function sourcebotHint -> codeSearchHint, and rename the DOM id mcpSourcebotToggle -> mcpCodeSearchToggle. Keep default ON.
- D1 (label framing): primary label "Code search (MCP)" with example tools as secondary helper text ("Sourcebot, Sourcegraph, Kilo Code, etc."). Chose over generic-only (less discoverable) and Sourcebot-named (not vendor-neutral, fails R6).
- D2 (pref handling): clean rename with NO migration and NO fallback. restorePrefs references only the new mcpCodeSearch key; the old mcpSourcebot key is never read, written, or deleted. Rationale (director): single user today, no value in carrying legacy storage cruft - treat the option as if the old key never existed. This supersedes the seed's backward-compat requirement #4 and its migration acceptance criterion.
- D3 (branch): work in the working tree on main; the repo owner commits.
- The new hint text uses hyphens (no em or en dashes), uses no triple-backtick fences (would break the exporter fencing - use inline examples), and avoids introducing any literal string that collides with another feature's gating tests.

## Surface area (file -> role)
index.html (all in scope unless noted):
- 561-562 checkbox input + label (id and visible text rename, add helper text)
- 803 help/docs `<li>` describing the option (generalize)
- 940-942 sourcebotHint() -> codeSearchHint() (rename + rewrite body tool-agnostic)
- 1137 state default mcpSourcebot: true -> mcpCodeSearch: true
- 1235 researchExplorerPrompt('landscape-advisory') string literal naming Sourcebot. CORRECTION (Planner verified): this is an UNCONDITIONAL string, NOT gated by state.mcpSourcebot. It is a wording-generalization site only (no state field here). Generalize "(Sourcebot)" -> a tool-agnostic phrasing (e.g. "a code-search MCP").
- 1609-1610 toggleMcpSourcebot() -> toggleMcpCodeSearch()
- 1673 savePrefs entry
- 1712-1715 restorePrefs entry (rename only; no reference to the old key)
- 4078-4082 generateRefinePrompt inline `if (state.mcpSourcebot)` block (gating field rename + generalize the pushed line; fix the em dash in the `// Sourcebot hint —` comment at 4078)
- 4176-4189 generatePlanPrompt inline `if (state.mcpSourcebot)` block: "## Codebase Exploration" + per-tool bullet list (gating field rename + generalize body; fix the em dash in the `// Sourcebot hint —` comment at 4176 and the em dashes in the bullet lines 4181-4185). NOTE the tool bullets here use ` — ` (em dash) separators that must become ` - `.
- 4991, 4996 New Workflow reset (state + checkbox)
- 5359 / 5521 / 5779 / 6207 the four codeSearchHint() injection sites (_wfSb/_saSb/_atSb/_cpSb vars)
- 5993-5994 comment (SDK) variant gating + header (generalize)
- 3782-3797 "Cross-Repo (requires Sourcebot)" PROMPT_LIBRARY category. CORRECTION (Planner verified): this category contains NO state.mcpSourcebot reference. renderPromptLib()/filterPromptLib() iterate PROMPT_LIBRARY unconditionally; the category is always rendered. "(requires Sourcebot)" in the category label and "Requires Sourcebot."/"Sourcebot MCP" in the four prompt bodies/descs are pure display text. There is NO gating field to rename here, so nothing breaks if left alone. Per Non-goal, rewording these descriptions is OUT of scope. LEAVE THIS BLOCK UNCHANGED. (Note: test 3081 asserts a PROMPT_LIBRARY 'Bug Hunter Review' prompt contains 'Sourcebot' - prompt-library bodies must keep the word, do not strip it.)
tests.html (Planner-verified site map):
- 3833 window-exposure line: `window.sourcebotHint = sourcebotHint;` -> `window.codeSearchHint = codeSearchHint;` (REQUIRED or the renamed fn is undefined in tests)
- Hint tests 2369-2381: rename `win.state.mcpSourcebot` -> `win.state.mcpCodeSearch`, `win.sourcebotHint()` -> `win.codeSearchHint()`; replace the `toContain('Sourcebot MCP')` / specific-tool-name assertions with the R1/R5 assertions (multiple example tools, no "is available" claim, discover/browse/search/read + Glob/Grep/LSP fallback, no em/en dash)
- Export-integration tests 2410-2415, 2740-2746, 2748-2752: rename state field + `toContain('Sourcebot MCP')` -> the new header substring; ADD genWorkflow + genAgentTeams + genClaudePrompt + genAgentSDK enabled/disabled cases (R2 currently only covers genSubAgents + the two prompt generators)
- New Workflow reset 2426-2434: rename `win.state.mcpSourcebot` -> `win.state.mcpCodeSearch` (title too)
- Refine integration 2581-2600 + edge case 2729-2738: rename state field + header substring; the 2729 `toNotContain('find_class')` / `toContain('ask_codebase')` assertions depend on the hint body wording, so re-target them to the NEW hint vocabulary (drop 'ask_codebase' if the rewrite no longer uses it)
- Plan integration 2643-2662: rename state field + header substring + the `toContain('search_code')` / 'Explore the codebase thoroughly' assertions to the generalized wording
- ADD: stale-old-key test (mcpSourcebot in localStorage has no effect), default-ON test, restorePrefs-applies-mcpCodeSearch test, UI-label test (see Requirements)
- tests.html harness: `resetState()` now sets `win.state.mcpCodeSearch = true` (it did not manage the MCP toggles before); needed so the default-ON and stale-old-key tests hold. See Gotchas.
- UI-label test uses `win.document.getElementById('mcpCodeSearchToggle').parentElement.querySelector('span')` and asserts the span textContent contains both 'Code search (MCP)' and 'Sourcebot, Sourcegraph, Kilo Code'.
- DO NOT TOUCH (must keep passing, unrelated): 1003/1049/1199 (durable-record provider-neutral `toNotContain('Sourcebot')`), 1298/1372 (consume/clarify hints `toNotContain('Sourcebot')`), 3081 (`toContain('Sourcebot')` on a PROMPT_LIBRARY body). The new option hint MUST NOT inject the literal `Durable Record` and the durable-record/consume/clarify hints MUST NOT gain a 'Sourcebot' substring.
README.md / TECHNICAL.md:
- generalize the option's description; Sourcebot may remain as one named example

## Task checklist
- [x] Capture baseline: run ./run-tests.sh, record pass count (468/468 green)
- [x] Rename state field, hint fn, DOM id across every site above (no gating site missed)
- [x] Rewrite the hint body tool-agnostic (examples + discover/browse/search/read + Glob/Grep/LSP fallback, hyphens, no fences)
- [x] Update checkbox label + helper text
- [x] restorePrefs references only the new key (no old-key read, fallback, or migration)
- [x] Generalize inline exporter mentions (1235 unconditional literal, 4078, 4176, 5994) and help text (803)
- [x] DO NOT touch the Cross-Repo PROMPT_LIBRARY category (3782-3797): Planner confirmed it has no state.mcpSourcebot gating; leave display text as-is (Non-goal) - left unchanged
- [x] Rewrite Sourcebot tests + fix window-exposure line (3833) + ADD: stale-old-key no-effect test, default-ON test, restorePrefs-applies test, UI-label test, and genWorkflow/genAgentTeams/genClaudePrompt/genAgentSDK enabled+disabled cases (R2 gap)
- [x] Update README.md / TECHNICAL.md
- [x] Run ./run-tests.sh, confirm green and count >= baseline (482/482 green, +14)
- [x] em/en-dash scan across changed files; fence scan in hint text

## Verify
- `./run-tests.sh` -> PASS 482/482 (green), up +14 from the 468/468 baseline. The +14 cover R2 exporter cases, R3 default-ON, R4 stale-old-key + restorePrefs-applies, R5 flow/fallback, and R6 UI label. 100% green, count >= baseline.
- OFF-state is byte-for-byte unchanged: every code-search injection is gated (the four canonical sites push only when codeSearchHint() is truthy, and it returns null when !state.mcpCodeSearch; the two inline blocks and the SDK comment guard on if (state.mcpCodeSearch)). No ungated push of code-search text exists.
- Dash, fence, and reference scans passed: no em/en dashes on any changed line (index.html, tests.html, README.md, TECHNICAL.md); zero triple-backtick fences in any code-search hint string; zero live state.mcpSourcebot / sourcebotHint / mcpSourcebotToggle / toggleMcpSourcebot references remain (the only mcpSourcebot literals left in tests.html are inside the R4 stale-old-key test, which writes the OLD key to prove it has no effect). DO-NOT-TOUCH tests (toNotContain('Sourcebot') gating checks and the Bug Hunter Review toContain('Sourcebot')) untouched and passing.

## Risks / trade-offs
- The rename touches more `state.mcpSourcebot` gating sites than a textbook single-toggle (inline hints at 4078/4176/1235, comment variant, cross-repo templates). Missing any one leaves a dead reference and breaks generation. Mitigation: grep for every `mcpSourcebot` / `Sourcebot` occurrence and reconcile against this surface map before finishing.
- Existing em dashes live in the current Sourcebot hint and nearby comments. They must become hyphens wherever touched, or they ship. Mitigation: dedicated dash scan on changed lines.

## Gotchas / non-obvious
- The four canonical injection sites use codeSearchHint(); but 4078 and 4176 are SEPARATE inline blocks that build their own text and gate on the same field. They are easy to miss and are not covered by renaming the hint function alone.
- run-tests.sh runs headless Chrome and exercises functions exposed on window in tests.html; the exposure line (tests.html 3833) must be updated or the renamed function is undefined in tests.
- Harness resetState() default-ON fix: resetState() did not reset the MCP toggle fields, so `win.state.mcpCodeSearch = true` was added to the harness resetState() (tests.html ~240) to make the R3 default-ON and R4 stale-old-key tests hold (without it, a prior test that set it false carries over). This is a harness-default fix mirroring the app default at index.html:1137, NOT an app behavior change.
- FALSE-POSITIVE sites that must NOT be touched (do NOT rename state on these): line 1235 (researchExplorerPrompt literal, unconditional), the Cross-Repo PROMPT_LIBRARY category 3782-3797, and the many PROMPT_LIBRARY/PROMPTS bodies that say "e.g. Sourcebot". These are display/prompt text, not `state.mcpSourcebot` reads. Tests 3081 and 3181 assert a PROMPT_LIBRARY body still contains 'Sourcebot' - keep prompt-library bodies as-is. The ONLY state-gating reads of mcpSourcebot are: 941, 1137(default), the toggle ~1610, 1673(savePrefs), 1712-1715(restorePrefs), 4079, 4177, 4991/4996(reset), 5993, and the four `sourcebotHint()` call sites 5359/5521/5779/6207.

## Outcome
The single Sourcebot toggle is now a tool-agnostic "Code search (MCP)" option. Surface area touched: index.html (state field, hint function, toggle, DOM id, default, savePrefs/restorePrefs, New-Workflow reset, the four exporter injection sites, the two inline hint blocks, the SDK comment banner, the checkbox label + helper text, the help li, and the unconditional literal at 1235), tests.html (exposure line, renamed/retargeted Sourcebot tests, and new R2-R6 coverage), README.md, and TECHNICAL.md. The injected guidance now names Sourcebot, Sourcegraph, and Kilo Code as examples with none mandated, makes no "X is available" claim, and adds a discover -> browse -> search -> read flow with a Glob/Grep/LSP fallback. Clean rename with no localStorage migration (the old mcpSourcebot key is never read, per director decision). The Cross-Repo PROMPT_LIBRARY category was deliberately left unchanged (Non-goal; it has no state gating). Tests: 468/468 baseline -> 482/482 green (+14). All five Spec quality check items pass. No commits (owner commits). Produced and verified by Planner -> Implementer -> Reviewer -> Tester under an orchestrator that ran grounding + clarify gates up front; grounding corrected two wrong assumptions in the kickoff surface map before any code was written.

## Built with (provenance)
Produced by the workflow "Make Sourcebot option general and called Code Search MCP" (Sub-Agents form), agent roles Planner -> Implementer -> Reviewer -> Tester, driven by an orchestrator that ran an up-front grounding gate (durable-record index, greenfield) and a clarify gate before the first step. Grounded by direct grep/LSP over index.html and tests.html.

## Links
- Work item: none (dogfood)
- Branch: main
- PR: TBD
