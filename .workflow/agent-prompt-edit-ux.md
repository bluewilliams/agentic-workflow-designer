# Agent prompt edit UX

Work item: none (dogfood). Branch: main. Status: in progress. Supersedes: .workflow/strengthen-agent-prompts.md (same capability: agent-prompt-config).

## Why and scope
The Strengthen-agent-prompts change made the role template visible but left three rough edges that confused even the author: the textarea sits at 6 rows always (a wall of text alongside two other text areas), the edited-state status reads "Custom prompt - overrides..." (sounds like a separate feature and implies the template is discarded when it is not), and there is no one-click way back to the pristine template after editing. Refine the node-config edit UX: compact textarea that expands on focus, clearer "Edited from..." wording plus a two-box hint, and a Reset-to-template affordance. This evolves the agent-prompt-config capability and supersedes the prior record (the inline preview and the Part B template lines it introduced are unchanged and stay documented there).

Non-goals: changing getEffectivePrompt or any exporter/generation logic; touching the inline read-only preview or the Part B implementer-template lines; any change to generated output (the reset just sets config.prompt to the role template, a normal config value).

## Requirements
R1 - The Agent Prompt textarea MUST be compact at rest and expand on focus, never losing the editable value.
- Given an agent node is selected, When the panel renders, Then the Agent Prompt textarea is compact (about 3 rows / the original min-height), showing the opening sentence or two. [test: "Agent Prompt textarea is compact at rest with the expand class and no rows attr" - assert [data-key="prompt"] classList contains 'agent-prompt-textarea', has NO 'rows' attribute, not readOnly/disabled]
- Given the textarea is focused, Then it expands smoothly (about 6-8 rows) via a min-height transition; Given it loses focus, Then it returns to compact. [test: "focusing the Agent Prompt textarea adds the focused class and blur removes it" - dispatch focus event -> classList contains 'focused'; dispatch blur -> classList toNotContain 'focused']
- Given the user has typed in it, When it expands and collapses, Then the value is unchanged. [test: "expand-on-focus preserves the textarea value across focus and blur" - set value, dispatch focus then blur, assert value unchanged and config.prompt unchanged (no updateConfig called)]

R2 - The status wording and a two-box hint MUST make the replace-vs-add model clear.
- Given the prompt has been edited (differs from the template), Then the status reads "Edited from the {Role} template ({N} lines)." (not "Custom prompt - overrides"). [test: "edited prompt shows the Edited-from-template status wording with line count" - status text toContain 'Edited from the Coder template', toMatch /\(\d+ lines\)/, toNotContain 'overrides' and toNotContain 'Custom prompt (']
- Given the empty and unmodified-template states, Then they keep their current meanings ("Using the {Role} role template (auto-applied...)" / "Full {Role} role template attached (~{N} lines)..."). [test: existing "empty prompt shows the auto-applied role-template status line" (tests.html L2277) + "unmodified template prompt shows the attached-template status line with line count" (L2286), both UNCHANGED and must still pass]
- Given the panel renders, Then a concise hint explains the two boxes (edit the Agent Prompt directly, or leave it and add extra context in Custom Notes); the Custom Notes helper names its appended-for-this-agent job. [test: "the two-box hint is present and the Custom Notes helper names its appended job" - assert .agent-prompt-hint exists and toContain 'Custom Notes'; assert [data-key="notes"] placeholder toContain 'appended to this agent']

R3 - A Reset-to-template affordance MUST appear only when edited and restore the pristine template, instantly and undoably.
- Given the prompt is edited, Then a "Reset to {Role} template" control is shown; Given it is empty or the unmodified template, Then the control is absent. [test: "Reset control appears only when the prompt is edited" - custom-prompt node: .agent-prompt-reset exists; empty-prompt node: querySelector('.agent-prompt-reset') toBeNull; unmodified-template node: toBeNull]
- Given the user clicks Reset, Then config.prompt is set to the current role template for that agent type, the status refreshes to the unmodified-template state, and NO confirmation dialog is shown. [test: "clicking Reset restores the role template and refreshes status with no dialog" - click .agent-prompt-reset; assert node.config.prompt === getEffectivePrompt(template-resolved) i.e. equals PROMPTS.implementer; status now toContain 'Full Coder role template attached'; .agent-prompt-reset now toBeNull; no window.confirm/modal invoked]
- Given the user clicks Reset then undo (the existing undo/redo), Then the prior edited text is restored. [test: "Reset is undoable via the existing undo - undo restores the edited text" - edit prompt to X, click Reset, call win.undo(), assert the selected node's config.prompt === X again"]

R4 - Generation MUST be untouched: getEffectivePrompt and the exporters are unchanged; generated output is unchanged by this feature itself.
- Given a workflow, When a prompt is generated, Then output is identical before/after this change (aside from the user's own edits/reset, which are normal config). [test: "reset and focus/blur do not leak into generated output and generation is unchanged" - snapshot genWorkflow()+genSubAgents() on a built workflow, run selectNode+updateConfig+focus/blur+ (on an edited node) reset, assert genWorkflow/genSubAgents toNotContain 'Edited from' and 'Reset to'; PLUS the existing Part-A display-only snapshot test (L2362) UNCHANGED and still passing]

R5 - Regression: the suite MUST stay green with no net decrease from 509; prior tests that asserted rows===6 and the old status wording are UPDATED (not deleted); new tests cover reset + expand-on-focus.
- Given ./run-tests.sh after the change, Then green with count >= 509. [test: the full suite via ./run-tests.sh (>= 509) + an em/en-dash scan (0) and a triple-backtick-fence scan (0) over the new UI strings. The two UPDATED tests (rows===6 -> compact/expand at tests.html L2350; overrides-wording -> Edited-from at L2294) keep their it() slots, so net count rises by the 5 new tests, landing >= 514.]

## Success criteria
- The config panel is compact at rest (the Agent Prompt no longer dominates), and editing is comfortable (focus expands it).
- A user can tell, from the wording, that editing the Agent Prompt changes the template in place and Custom Notes adds to it - without asking.
- A user who edits the prompt can get the pristine template back in one click, and recover their edit via undo.
- Generated output is unchanged by the feature.
- ./run-tests.sh green with count >= 509.

## Spec quality check
- [x] Each requirement is testable and unambiguous
- [x] Scope is bounded (Non-goals stated; preview + Part B untouched)
- [x] No open clarifications remain (reset=instant+undoable, on-blur=always-collapse both resolved)
- [x] Every scenario names a verifying test
- [x] Success criteria are measurable

## Approach and decisions
- Build on the prior strengthen-agent-prompts surface (the updateConfig agent branch, classifyAgentPrompt, agentPromptStatusBlock, the configTextarea attrs param). This change supersedes that record for the agent-prompt-config capability.
- D1 (reset behavior, director-resolved): instant, NO confirmation dialog, but UNDOABLE via the existing undo/redo system. Chose over a modal confirm (friction, fights the lightweight feel) and over instant-with-no-recovery (a misclick would lose edits) - the labeled action plus undo is low-friction and safe. If wiring reset into the undo stack is not clean, fall back to a lightweight INLINE two-step confirm (never a modal).
- D2 (on-blur, director-resolved): always collapse back to compact. Chose over stay-expanded-if-edited because the latter reintroduces the clutter this change removes and makes node panels inconsistent; the status line + preview + re-focus-expands preserve awareness and access.
- D3 (wording): "Edited from the {Role} template" not "Replaced/overrides" - a small edit is an in-place edit, not a replacement, so "Edited from" is accurate and non-alarming.
- Constraints: no em/en dashes (UI text included), no fences, reuse existing styling/vars, provider-neutral.

## Surface area (file -> role) - GROUNDED by the Planner (2026-06-13)
index.html (single file; fns/consts global, reachable as win.X):
- L3216-3217 `configTextarea('Agent Prompt','prompt',...,'rows="6"')`: DROP the `'rows="6"'` arg (5th param) and ADD a class so the textarea is compact at rest and expands on focus via CSS, not rows. Pass `'class="agent-prompt-textarea"'` as the 5th `attrs` arg instead. The `attrs` param already appends raw into the `<textarea ...>` tag (L3403-3405), so `class="..."` lands correctly. Value never touched.
- L3403-3405 `configTextarea(label,key,value,placeholder,attrs)`: UNCHANGED (the generic 5th `attrs` hook already exists from the prior change). Other 8 callers unaffected.
- L3409-3426 `agentPromptStatusBlock(node)`: (a) change the `info.state==='custom'` string at L3417 from `Custom prompt (${info.lines} lines) - overrides the ${info.role} template.` to `Edited from the ${info.role} template (${info.lines} lines).`; keep the 'empty' (L3413) and 'template' (L3415) strings as-is; (b) add a two-box hint <div class="agent-prompt-hint"> (always shown) after the status line; (c) when `info.state==='custom'`, also emit a Reset control `<button type="button" class="agent-prompt-reset" data-role="${escHtml(info.role)}">Reset to ${escHtml(info.role)} template</button>` (native button, keyboard-operable). classifyAgentPrompt (L1115) decides edited vs template and thus when Reset/the edited string show.
- L1115-1133 `classifyAgentPrompt(node)`: UNCHANGED. 'custom' === edited; drives Reset visibility + edited wording.
- L3350-3385 `if (node.type==='agent')` binder block (runs after the generic input/textarea binder at L3260 and the select binder at L3276): add (a) a focus/blur listener pair on `.agent-prompt-textarea` that toggles a `.focused` class (NOT updateConfig - value preserved); (b) a click+keydown(Enter/Space) binder on `.agent-prompt-reset` whose handler calls `pushUndo()`, then sets `node.config.prompt = getEffectivePrompt({...node, config:{...node.config, prompt:''}})` (the role template - same value a fresh preset node resolves to), then `updateConfig()` (re-render refreshes status to 'template' + hides Reset) and `render()`. Place next to the existing preview-toggle binder (L3354-3368).
- L2951-2956 `pushUndo()` + L2943-2949 `_snapshotState()` (snapshots state.nodes deep-cloned) + L2962-2988 `undo()/redo()`: the EXISTING undo system. Reset hooks in by calling `pushUndo()` BEFORE mutating `node.config.prompt`, exactly as addNode (L2991) and every structural mutator do. No debounce; pushUndo is synchronous and clears the redo stack. `undo()` restores `state.nodes` from the snapshot and re-renders, so the prior edited text returns. window.undo/redo/pushUndo are global.
- L3219-3220 Custom Notes `configTextarea('Custom Notes','notes',...,placeholder)`: update the placeholder (helper text) to name its appended-for-this-agent job. New string in WORDING below.
- L146-177 CSS `.config-field` / `.agent-prompt-*` block: add `.agent-prompt-textarea` (compact min-height at rest, e.g. min-height ~64px / ~3 rows; `min-height` transition) and `.agent-prompt-textarea.focused` (taller, e.g. ~150px / ~7 rows) so expansion is pure CSS, value untouched. Add `.agent-prompt-hint` (muted helper-text style like `.agent-prompt-status`) and `.agent-prompt-reset` (small text-button, keyboard-focusable, reuse the preview-toggle button styling pattern at L165-169). Note: base `.config-field textarea` already has `min-height:60px` (L153) - the `.agent-prompt-textarea` rule overrides it.
- getEffectivePrompt (L1098), exporters genWorkflow (L5540-area)/genSubAgents/emitAgentBlock/buildAgentPrompt UNTOUCHED. Reset only sets a normal config value, so generated output is identical aside from the user's own reset.

### Undo integration for Reset (confirmed clean - no fallback needed)
The director's fallback (inline two-step confirm) is NOT needed. `pushUndo()` is the exact, clean hook: it deep-snapshots state.nodes before the mutation and clears redo, identical to how addNode/deleteSelected/etc. already make actions undoable. Reset handler = `pushUndo(); node.config.prompt = <role template>; updateConfig(); render();`. A subsequent `undo()` (button, Ctrl/Cmd+Z, or `win.undo()` in tests) pops the snapshot and restores the edited text. Reachable in tests as `win.undo()`.

tests.html (iframe src=index.html; win on load; harness describe/it/expect toContain/toNotContain/toBe/toMatch/toBeNull; DOM-render pattern addNode+selectNode+updateConfig+win.document.querySelector at L2277+):
- UPDATE L2350-2361 'Agent Prompt textarea renders with rows=6...': replace the `prompt.rows).toBe(6)` assertion with compact-at-rest + expand-on-focus (assert `.agent-prompt-textarea` class present, NOT readOnly/disabled; dispatch focus -> `.focused` added; dispatch blur -> `.focused` removed; value unchanged). Keep the Custom Notes `hasAttribute('rows')` false check (still true since rows attr is gone everywhere).
- UPDATE L2294-2301 'custom prompt shows the overrides-template status line' -> assert `toContain('Edited from the Coder template')` and `toMatch(/\(\d+ lines\)/)`; drop the 'overrides the Coder template' / 'Custom prompt (' assertions.
- ADD (R2/R3) tests: two-box-hint-present; reset-appears-only-when-edited; reset-restores-template-no-dialog; reset-is-undoable; expand-on-focus-preserves-value. Names + phrases in the plan's TEST section.
- UNCHANGED (must still pass): the 'empty'/'template' status tests (L2277-2293), classifyAgentPrompt unit (L2302-2320), preview toggle (L2325-2345), Part-A-display-only (L2362-2381), the whole Implementer Template suite (L2386+).

## Task checklist
- [x] Baseline 509 (orchestrator captured; Planner re-confirmed surface sites against current line numbers; run-tests.sh present)
- [x] Compact default + expand-on-focus: dropped rows="6", added class="agent-prompt-textarea"; CSS min-height transition (64px rest, 150px .focused) + .focused state; focus/blur listeners in the agent binder toggle ONLY the class (never updateConfig; value preserved)
- [x] Status edited-state -> "Edited from the {Role} template ({N} lines)." (agentPromptStatusBlock)
- [x] Two-box hint (.agent-prompt-hint, always shown) + Custom Notes helper placeholder names appended-for-this-agent job
- [x] Reset-to-template control (.agent-prompt-reset, shown only when state==='custom'; handler = pushUndo() -> set config.prompt to role template (getEffectivePrompt of node with prompt blanked) -> updateConfig()+render(); instant, no dialog; undoable; click + keydown Enter/Space)
- [x] Updated prior tests (rows===6 -> compact/expand+focus/blur; overrides-wording -> Edited-from); added 6 new tests (expand-preserves-value, two-box-hint+notes-helper, reset-appears-only-when-edited, reset-restores-no-dialog, reset-undoable-via-win.undo, generation-unchanged-no-leak)
- [x] run-tests 515/515 (>= 509, exceeds 514 target); em/en-dash scan (0); fence scan (0)
- [ ] (finalize) supersede strengthen-agent-prompts in _index.md (orchestrator at finalize)

## Verify
- Baseline (before): ./run-tests.sh -> PASS 509/509.
- After: ./run-tests.sh -> PASS 515/515 (green). Net +6 = the 6 added tests; the 2 updated tests kept their it() slots. Exceeds the >= 514 target.
- em/en-dash scan over new UI strings (index.html + tests.html): 0. Whole-file index.html em/en-dash count: 0.
- Triple-backtick-fence scan over new UI strings: 0.
- git diff (index.html) is confined to: CSS (.agent-prompt-textarea/.focused, .agent-prompt-hint, .agent-prompt-reset), the two configTextarea calls (Agent Prompt class swap, Custom Notes placeholder), the agent binder block (focus/blur + reset listeners), and agentPromptStatusBlock (edited wording + hint + conditional reset button). getEffectivePrompt, genWorkflow/genSubAgents/emitAgentBlock/buildAgentPrompt, classifyAgentPrompt, the preview-toggle logic, and the Part B implementer template are UNTOUCHED.
- Behavior confirmed by tests: focus/blur toggle only the .focused class and do not call updateConfig (value + config.prompt preserved); reset calls pushUndo() before mutating, so win.undo() restores the edited text; reset/focus/blur do not leak 'Edited from'/'Reset to' into genWorkflow/genSubAgents output.

- Independently re-verified by the Reviewer and Tester (every R1-R5 assertion read against the source, not trusted by name). The Tester closed a real gap: all reset tests used a coder node, so it added a writer-style test ensuring Reset resolves the agent-type template (PROMPTS.writerTechnical), not a hardcoded implementer path. Final: 516/516 green.

## Wording strings (exact - hyphens only, no fences; all grep-confirmed absent today)
- Edited-state status (agentPromptStatusBlock L3417): `Edited from the ${info.role} template (${info.lines} lines).`
- Two-box hint (.agent-prompt-hint, always shown): `Two ways to steer this agent: edit the Agent Prompt above to change the template in place, or leave it as the role template and add extra context in Custom Notes below.`
- Custom Notes helper (placeholder at L3220): `Extra context, constraints, or details for this step - appended to this agent's prompt (it does not replace the Agent Prompt above).`

## Gotchas (Implementer, 2026-06-13)
- Reset role-template value: used `getEffectivePrompt({ ...node, config: { ...node.config, prompt: '' } })` (shallow clone with prompt blanked) so the resolved template exactly matches what classifyAgentPrompt compares against, which flips state to 'template' and removes the Reset control on re-render. For a coder node this equals PROMPTS.implementer (asserted in tests).
- Reset button placed BEFORE the .agent-prompt-hint inside agentPromptStatusBlock; the hint is always shown, the button only when state==='custom'.
- CSS: `.agent-prompt-textarea` rule is scoped under `.config-field textarea.agent-prompt-textarea` so specificity beats the base `.config-field textarea{min-height:60px}` without !important.
- Line numbers shifted after edits (CSS additions pushed later sites down ~30-35 lines); the Surface area line refs are pre-edit. Anchor by symbol name, not line number, going forward.

## Outcome
Refined the node-config edit UX for the Agent Prompt field, superseding the strengthen-agent-prompts change for the agent-prompt-config capability (that record's inline preview and Part B implementer-template lines are unchanged and stay documented there). Three parts: (1) the Agent Prompt textarea is compact at rest and expands smoothly on focus, collapsing on blur, via a CSS class toggle that never touches the value; (2) clearer wording - the edited-state status now reads "Edited from the {Role} template ({N} lines)" instead of "Custom prompt - overrides," plus an always-shown two-box hint and a Custom Notes helper that names its appended-for-this-agent job; (3) a "Reset to {Role} template" control that appears only when edited and restores the role template instantly with no dialog, made undoable through the existing pushUndo() so a misclick is recoverable. getEffectivePrompt and the exporters are untouched; generated output is unchanged by the feature. Surface area: index.html (the Agent Prompt + Custom Notes configTextarea calls, agentPromptStatusBlock, the agent-branch focus/blur + reset binders, CSS) and tests.html. Tests 509 -> 516 green.

## Built with (provenance)
Produced by the workflow "Agent prompt edit UX" (Sub-Agents form, Feature shape), agent roles Planner -> Implementer -> Reviewer -> Tester, driven by an orchestrator that ran an up-front grounding gate (consume - a genuine capability match that supersedes the strengthen-agent-prompts record) and a clarify gate (no-op; both open questions pre-resolved by the director). Grounded by the committed .workflow/_index.md, the superseded record, and grep over index.html and tests.html.

## Links
- Work item: none (dogfood)
- Branch: main
- PR: TBD
