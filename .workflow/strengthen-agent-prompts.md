# Strengthen agent prompts

Work item: none (dogfood). Branch: main. Status: in progress.

## Why and scope
Each agent node already carries a full role-template prompt (~15-25 lines from the PROMPTS map), but the node-config Agent Prompt textarea is ~3 rows tall and shows only the first line, so rich prompts LOOK thin and invite distrust/pushback. Part A makes the attached template visible in the UI (status line + inline preview + a modest textarea bump) without changing any control or any generated output. Part B adds two small high-value lines to the coder/implementer role template (minimality + record-assumptions) - the only intentional generated-output change.

Non-goals: changing how prompts are stored or generated (beyond Part B's two lines); altering any existing control (tools, model, turns, notes, agent type, the editable prompt); a per-task spec field. Part B is scoped to the coder/implementer template only (backend/frontend deferred).

## Requirements
R1 - The node-config panel MUST show a status line under the Agent Prompt textarea reflecting the effective prompt, with the correct role name and a line count.
- Given node.config.prompt is empty, When the panel renders, Then the line reads "Using the {Role} role template (auto-applied when the workflow is generated). Type here to override with your own." [test: "empty prompt shows the auto-applied role-template status line" - assert status el text contains 'Using the Coder role template' and 'auto-applied when the workflow is generated']
- Given node.config.prompt equals the role template for this agent type (unmodified), Then the line reads "Full {Role} role template attached (~{N} lines)..." with N from the effective prompt. [test: "unmodified template prompt shows the attached-template status line with line count" - assert contains 'Full Coder role template attached' and matches /~\d+ lines/]
- Given node.config.prompt is a custom/edited value, Then the line reads "Custom prompt ({N} lines) - overrides the {Role} template." [test: "custom prompt shows the overrides-template status line" - assert contains 'Custom prompt (' and 'overrides the Coder template']
- Template-vs-custom is determined by computing the would-be template the same way getEffectivePrompt does (AGENT_TYPE_PROMPT_MAP -> PROMPTS, plus the writer-style variant) and comparing. [test: "classifyAgentPrompt matches getEffectivePrompt resolution incl writer-style variant" - unit test on window.classifyAgentPrompt across empty/template(coder)/template(writer business)/custom -> 'empty'|'template'|'custom']

R2 - A "Preview full prompt" inline expand MUST show the effective prompt read-only.
- Given the preview is toggled open, When rendered, Then it shows the full effective prompt (getEffectivePrompt) in a read-only block inline (not a modal), and does not alter the editable textarea. [test: "preview toggle expands an inline read-only block showing the effective prompt and leaves the textarea untouched" - click .agent-prompt-preview-toggle, assert .agent-prompt-preview is visible, its text === getEffectivePrompt(node), it is not a textarea/has readonly affordance, and the [data-key="prompt"] textarea value is unchanged]

R3 - The Agent Prompt textarea MUST grow to ~6 rows and stay fully editable; all other controls unchanged; Part A changes no generated output.
- Given the panel renders, Then the Agent Prompt textarea is ~6 rows and editable; AGENT TYPE, MODEL, MAX TURNS, CUSTOM NOTES, and TOOLS chips behave exactly as before. [test: "Agent Prompt textarea renders with rows=6 and stays editable while other fields are unchanged" - assert [data-key="prompt"] rows===6 and not readOnly/disabled; Custom Notes textarea has NO rows attr (shared helper not globally bumped)]
- Given any workflow, When a prompt is generated, Then Part A changes nothing in the output (byte-for-byte identical aside from Part B). [test: "rendering the config panel does not change generated output (Part A is display-only)" - snapshot genWorkflow()+genSubAgents() before, run selectNode+updateConfig+toggle preview, snapshot after, assert equal; AND assert genWorkflow()/genSubAgents() toNotContain 'role template attached' and 'Preview full prompt']

R4 - The coder/implementer template MUST gain a minimality line and a record-assumptions line, additively.
- Given PROMPTS.implementer, Then it contains a minimality line near the top ("Make the minimal change that satisfies the plan - implement what is asked and do not refactor or restructure unrelated code along the way.") and a record-assumptions line before the Handoff Summary ("If something is ambiguous or you are blocked, do not silently guess: proceed with the most reasonable interpretation and state the assumption explicitly in your Handoff Summary..."), with ALL prior template text preserved verbatim. [test: "implementer template gains the minimality and record-assumptions lines additively, preserving prior text" - assert PROMPTS.implementer contains 'Make the minimal change that satisfies the plan', contains 'do not silently guess', still contains the original opener 'Implement the feature following the plan.' and the tail '**Unresolved**: Anything that needs reviewer attention or was deferred'; assert minimality index < '## Handoff Summary' index and assumptions index < '## Handoff Summary' index]
- Given any other role template, Then it is unchanged. [test: "other role templates are unchanged by the implementer edit" - assert PROMPTS.backend / PROMPTS.frontend / PROMPTS.planner / PROMPTS.reviewer toNotContain 'Make the minimal change that satisfies the plan' and toNotContain 'do not silently guess']

R5 - Regression/constraints: suite green >= 499; no em/en dashes anywhere (UI text + template lines); no triple-backtick fences; provider-neutral; the only generated-output change is R4's two lines.
- Given ./run-tests.sh after the change, Then green with count >= 499. [test: the suite + "implementer template additions are em/en-dash free and fence-free" - assert the two new substrings each toNotContain '—', '–', and '```'; plus existing suite green]

## Success criteria
- A user opening any agent node immediately sees that a full role template is attached (or that they have a custom prompt), with a line count, and can preview the full text inline - so the agents no longer look thinly configured.
- Every existing control still works; the prompt is still fully editable for tailoring.
- The only change to generated output is the two additive lines in the coder/implementer template.
- ./run-tests.sh green with count >= 499.

## Spec quality check
- [x] Each requirement is testable and unambiguous
- [x] Scope is bounded (Non-goals stated; Part B = coder/implementer only)
- [x] No open clarifications remain (preview=inline, textarea=~6 rows, Part B scope all resolved)
- [x] Every scenario names a verifying test
- [x] Success criteria are measurable

## Approach and decisions
- Part A lives in the node-config panel rendering (the configTextarea('Agent Prompt'...) area). Add a status helper that classifies effective-prompt as empty/template/custom by reusing the getEffectivePrompt resolution, plus an inline preview toggle, plus the row bump.
- D1 (preview, clarify-resolved): inline expand, not a modal. Chose over modal to keep the user in the config panel and avoid an overlay.
- D2 (textarea height, clarify-resolved): modest bump ~3 -> ~6 rows. Chose over keeping 3 rows because it is a cheap readability win that also directly reduces the looks-thin feeling; the status line + preview still carry the full picture.
- D3 (Part B scope, clarify-resolved): coder/implementer template ONLY. Chose over also-backend/frontend to keep the change surgical and the intentional output-change surface to one template; can extend later.
- Constraints: no em/en dashes (UI + lines), no fences, provider-neutral; grep tests.html before adding a literal.

## Surface area (file -> site) - GROUNDED by the Planner (2026-06-13)
index.html (single file; functions/consts are global so reachable as win.X in tests):
- L1106 `PROMPTS.implementer` (one single-quoted string literal): insert the two additive lines (minimality after the opening `Implement the feature following the plan.\n\n`; assumptions immediately before `\n\n## Handoff Summary`). See R4 lines below for exact text. ONLY this literal changes.
- L3146-3233 `updateConfig()`: the agent branch emits the Agent Prompt field at L3177 (`configTextarea('Agent Prompt','prompt',...)`). Insert, right after that line, (a) the status line and (b) the preview toggle + collapsed preview block, scoped to `node.type==='agent'`. The generic `fields.querySelectorAll('input,textarea')` (L3220) and `.config-select` (L3236) binders already run after; add a dedicated click binder for the preview toggle near the tools-grid binder (L3310-3328, inside `if (node.type==='agent')`).
- L3346-3349 `configTextarea(label,key,value,placeholder)`: SHARED by Custom Notes, Description, Acceptance, Condition, options, evaluationBias, etc. Do NOT globally add rows. Add an OPTIONAL 5th param `attrs` (appended to the `<textarea ...>` tag) and pass `'rows="6"'` ONLY from the Agent Prompt call at L3177. All other callers unaffected (default no attr).
- New helper `classifyAgentPrompt(node)` (placed next to getEffectivePrompt, now ~L1096 after the +0 helper was inserted immediately after getEffectivePrompt's closing brace): returns `{ state:'empty'|'template'|'custom', role, lines, text }` by recomputing the would-be template exactly as getEffectivePrompt (writer-style variant via 'writer'+capitalize(writingStyle), else AGENT_TYPE_PROMPT_MAP->PROMPTS) and comparing trim() to node.config.prompt. role = getAgentTypeName(node.config.agentType); lines = text.split('\n').length on the effective prompt. Reachable as win.classifyAgentPrompt. IMPLEMENTED.
- New helper `agentPromptStatusBlock(node)` (placed next to configTextarea, ~L3406): calls classifyAgentPrompt and returns the status-line markup + the read-only preview-toggle button (.agent-prompt-preview-toggle, native <button>, aria-expanded, caret) + the collapsed .agent-prompt-preview block (a <pre> showing info.text). Emitted right after the Agent Prompt configTextarea (~L3216). The toggle's click+keydown(Enter/Space) binder lives inside the `if (node.type==='agent')` block (~L3300, just before the tools-grid loop); it ONLY toggles .open + flips aria-expanded, never calls updateConfig, so the editable textarea value is preserved. IMPLEMENTED.
- New CSS (in the .config-field block ~L146-157): `.agent-prompt-status` (font-size:11px;color:var(--text3);line-height:1.45;margin-top:-4px) matching helper-text convention; `.agent-prompt-preview-toggle` (clickable, var(--text3), small, keyboard-focusable - use a <button> or tabindex) with an expand caret that rotates on open; `.agent-prompt-preview` collapsed by default (max-height:0;overflow:hidden;transition) and `.open` state; preview block styled distinct from the textarea (muted background var(--surface)/var(--bg), no border-focus, font:var(--mono), readonly look, no edit caret). Keep panel gap consistent (`.config-panel{gap:10px}`) so no layout jank.
- getEffectivePrompt (L1083), AGENT_TYPE_PROMPT_MAP (L1074), getAgentTypeName (L5491), AGENT_TYPES (L923, coder->name 'Coder'), capitalize (L1082) are reused unchanged.
- genWorkflow (L5540) / genSubAgents / emitAgentBlock (L5772) / buildAgentPrompt (L5781) are NOT touched (Part A is display-only). Confirmed they read node.config.prompt + getEffectivePrompt only.
tests.html (iframe at L43 src=index.html; win set on load; harness describe/it/expect with toContain/toNotContain/toBe/toMatch at L88-143; resetState L221; selectCustomOption L339; DOM-render pattern selectNode+updateConfig+win.document.querySelector already used at L2180-2244):
- Add a new describe suite for the status line / preview / row bump (R1-R3), an implementer-template suite (R4), and the Part-A-unchanged + dash/fence suite (R5). No new window export plumbing needed (top-level fns are global); classifyAgentPrompt is reachable as win.classifyAgentPrompt automatically.
- README.md / TECHNICAL.md: NOT required (no public API/protocol surface changes; status line + preview are internal UI). Skip unless the Reviewer wants a one-line UI note.

## Task checklist
- [x] Baseline 499 (orchestrator captured; Planner re-confirm; Implementer re-ran: 499/499)
- [x] Status-line helper (empty/template/custom classification + line count + role name) - classifyAgentPrompt + agentPromptStatusBlock
- [x] Inline preview toggle (read-only effective prompt) - <pre> in .agent-prompt-preview, smooth max-height transition
- [x] Textarea ~3 -> ~6 rows (still editable) - via optional 5th attrs param on configTextarea, passed only by Agent Prompt call
- [x] PROMPTS.implementer: minimality line (top) + assumptions line (before Handoff Summary), additive
- [x] Tests for R1-R5 (incl. generated-output-unchanged-by-Part-A and other-templates-unchanged) - +10 tests
- [x] Docs note if warranted - none needed (internal UI only, no public surface)
- [x] run-tests >= 499; em/en-dash scan (0); fence scan (0)

## Verify
- ./run-tests.sh: 499 -> 509 green (+10 R1-R5 tests). Independently re-run by the Reviewer and Tester (the Tester also flipped an assertion to confirm the harness fails loudly, so green is real).
- Display-only confirmed: genWorkflow/genSubAgents/emitAgentBlock/buildAgentPrompt/getEffectivePrompt are unmodified and contain zero references to the new UI symbols; the R3 snapshot test pins genWorkflow()+genSubAgents() byte-equal before/after a render+toggle. The only generated-output change anywhere is Part B's two lines in PROMPTS.implementer.
- New template lines + UI strings: 0 em/en dashes, 0 triple-backtick fences. configTextarea shared body unchanged; only the Agent Prompt call passes rows="6".
- All R1-R5 verified against the live code: the three status strings + classifyAgentPrompt (reusing the exact getEffectivePrompt resolution incl the writer-style variant); the inline read-only preview shows getEffectivePrompt and leaves the editable textarea value intact; the Agent Prompt textarea is rows=6 and editable while other fields are untouched; both implementer lines are additive with all prior text preserved and other templates unchanged. No gaps.

## Gotchas
- Extensibility (director-flagged, independently reviewed): the 5th `attrs` param on configTextarea is a clean generic hook, not a one-off. The body appends `${attrs ? ' ' + attrs : ''}` with zero key/field inspection; only the Agent Prompt call passes `rows="6"`, the other 8 callers render identically. The status-line/preview is intentionally scoped to the Agent Prompt because only that field has a role-template fallback (getEffectivePrompt) - a deliberate semantic boundary, not accidental coupling.
- Minor (non-blocking): the inline preview block has its own max-height + overflow:auto, so very long prompts scroll and stay fully reachable; no jank.

## Outcome
Part A (node-config UI, no generated-output change): the Agent Prompt field now shows a status line that classifies the effective prompt as auto-applied template / unmodified template (with a ~line count) / custom-override, with the correct role name; an inline read-only "Preview full prompt" expand shows the full effective prompt (getEffectivePrompt) without disturbing the editable textarea; and the textarea grew to ~6 rows. The classification reuses the exact getEffectivePrompt resolution (incl the writer-style variant). The row bump was added as a generic optional `attrs` param on the shared configTextarea (used only by the Agent Prompt call), so it stays extensible without special-casing. Part B (the only generated-output change): the coder/implementer template gained a minimality line and a record-assumptions line, additively. Surface area: index.html (new classifyAgentPrompt + agentPromptStatusBlock helpers, the status/preview markup + binder in updateConfig's agent branch, the configTextarea attrs param, CSS in the .config-field block, and the two PROMPTS.implementer lines), tests.html (10 new tests). Tests 499 -> 509 green.

## Built with (provenance)
Produced by the workflow "Strengthen agent prompts" (Sub-Agents form, Feature shape), agent roles Planner -> Implementer -> Reviewer -> Tester, driven by an orchestrator that ran an up-front grounding gate (consume - scanned the index, no capability match) and a clarify gate (resolved preview/textarea/scope) before the first step. Grounded by the committed .workflow/_index.md and grep over index.html and tests.html.

## Links
- Work item: none (dogfood)
- Branch: main
- PR: TBD
