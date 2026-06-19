# Generic adversarial-critic agent with one-click attach

Work item: backlog #7 (.workflow/_backlog.md). Status: complete, uncommitted (Blue commits). Tests: 671/671. Review: PASS.

## Why and scope

Add a generic adversarial-critic capability to the agentic-workflow-designer (single index.html, tests in tests.html). A refute-first reviewer attachable to any work-producing node in one click, which auto-assembles the critic plus a Decision node plus a back-edge revise loop, reusing the existing Decision/maxRevisions machinery. The bar: a smooth design-time UX and a critic whose feedback is genuinely meaningful - it sends work back only when a revise cycle is worth more than it costs, never for nitpicks.

Non-goals: no multi-critic debate panel (deferred); no new palette node type; no change to other role templates; no programmatic execution of the critic (this app only GENERATES prompts).

## Requirements

R1. The app MUST expose a new `adversary` agent role resolvable like any other role.
- Given an Agent node with agentType `adversary`, When getEffectivePrompt resolves it, Then it returns the adversary template. (test: TBD)
- Given an `adversary` prompt, When classifyAgentPrompt runs, Then it classifies it like any role (no crash, recognized). (test: TBD)

R2. The adversary template MUST encode a refute-first posture and a strict materiality bar.
- Then it states the burden is on the work to prove itself and the critic actively hunts for what is wrong but stays scoped. (test: TBD)
- Then the default verdict is PASS; NEEDS REVISION only for material defects (correctness, requirement-not-met, missing edge/null/error, security/data-handling, scope over-reach, false-passing tests). (test: TBD)
- Then it explicitly excludes style/naming/taste/formatting/speculative "could be better", and says when in doubt PASS. (test: TBD)

R3. The adversary template MUST encode a single routable verdict contract.
- Then it ends with exactly "VERDICT: PASS" or "VERDICT: NEEDS REVISION", followed by Critical/High blocking issues (each with the concrete change required), then Medium/Low non-blocking notes. (test: TBD)

R4. Severity gating MUST be encoded: only Critical/High findings make the verdict NEEDS REVISION; Medium/Low are recorded but still PASS. (test: TBD)

R5. Convergence MUST be encoded: respect the revise-loop max cycles; on the final cycle focus only on remaining blockers; if blockers remain after the cap, PASS with the issues documented rather than blocking forever. (test: TBD)

R6. The template MUST be ONE template with a role-aware lens selected from the reviewed node's role.
- Given the reviewed role is planner, Then the lens scrutinizes plan completeness, edge/null/error cases, wrong/missing files, unjustified decisions, requirement satisfaction. (test: TBD)
- Given the reviewed role is coder/implementer, Then the lens scrutinizes correctness, scope creep, missing error handling, convention fit. (test: TBD)
- Given an unknown/Task role, Then a generic fallback lens applies. (test: TBD)
- Lenses for architect, researcher, tester, writer also provided. (test: TBD)

R7. One-click attach MUST be offered only on Agent and Task nodes (never input/output/decision/parallel). (test: TBD)

R8. One-click attach MUST, in a single undoable action, create a critic Agent (agentType adversary, tagged with the reviewed role), rewire the target's outgoing connection(s) to flow target -> critic, create a Decision node ("Review passed?", default maxRevisions) whose PASS branch goes to the target's original downstream and whose NEEDS-REVISION branch loops back to the target.
- Then the critic label is "Adversarial review: {target}". (test: TBD)
- Then a single pushUndo snapshot restores the entire prior state. (test: TBD)

R9. One-click detach MUST remove the critic + Decision + back-edge and restore the target's original downstream, also undoable. (test: TBD)

R10. No double-attach: attaching to a target that already has an attached critic loop MUST NOT create a second loop (control disabled or offers detach). (test: TBD)

R11. All prose generators MUST render the adversary role and the Decision revise-loop routing correctly, reusing the existing Reviewer/Decision rendering; the adversary prompt and its verdict contract flow through unchanged. (test: TBD)

R12. All previously passing tests MUST still pass. (test: full suite)

## Success criteria

- A designer can turn any plan/research/design/doc/code step into a reviewed-and-revised step in one click, and undo it in one click.
- The generated prompt for a critic-attached workflow tells the critic to send work back ONLY for material defects, and routes NEEDS REVISION back to the source agent with a cycle cap.
- Test baseline rises from ~650; no regressions.

## Spec quality check

- [x] Each requirement is testable and unambiguous
- [x] Scope is bounded (Non-goals stated)
- [x] No open clarifications remain (planner checkpoint signed off)
- [x] Every requirement names a verifying test (see Verifying tests below)
- [x] Success criteria are measurable

## Verifying tests (tests.html suites)

- R1 (role resolves) -> `adversary role` > resolves via getEffectivePrompt; classifies bare like any role; maps to PROMPTS key.
- R2 (refute-first + materiality bar) -> `adversary template content` > refute-first posture; default PASS and exclude nitpicks.
- R3 (verdict contract) -> `adversary template content` > PASS / NEEDS REVISION verdict contract.
- R4 (severity gating) -> `adversary template content` > gate on Critical/High only.
- R5 (convergence) -> `adversary template content` > proceed after the cap.
- R6 (role-aware lens) -> `adversary role-aware lens` > planner lens; code lens (coder/frontend/backend); generic fallback.
- R7 (offered on Agent/Task only) -> `adversary attach / detach` > offered only on Agent/Task; not on a critic node.
- R8 (attach builds loop, undoable) -> `adversary attach / detach` > creates critic+decision+revise loop; undoable in a single step.
- R9 (detach restores downstream) -> `adversary attach / detach` > restores the original downstream on detach.
- R10 (no double-attach) -> `adversary attach / detach` > does not double-attach.
- R11 (generators render) -> `adversary in generated output` > renders the critic prompt and revise loop in genWorkflow.
- R12 (no regressions) -> full suite, 671/671 pass.

## Approach and decisions

Locked design (from prior session, recorded in .claude-state/ai-tools/recent.md):
- ONE critic template + role-aware LENS keyed off the reviewed node's role (not N prompts, not one flat prompt).
- MATERIALITY BAR: default PASS; NEEDS REVISION only for Critical/High material defects; never style/taste/nitpicks; when in doubt PASS.
- SEVERITY-GATED routing: Medium/Low non-blocking, still PASS.
- CONVERGENCE: respect max cycles; proceed with documented issues after cap.
- ONE-CLICK attach on Agent/Task only; auto-creates critic (new `adversary` agentType) + Decision + back-edge; atomic + undoable via pushUndo.
- SYMMETRIC one-click DETACH; NO double-attach.
- REUSE existing Decision/maxRevisions loop; SINGLE-critic only (panel deferred).
- `adversary` wired into AGENT_TYPE_PROMPT_MAP.

Rejected alternatives: N separate critic prompts (rejected - maintenance + drift); a brand-new palette node type for the loop (rejected - the Decision node + maxRevisions loop already exists, reuse it); a debate panel of N critics (deferred - high cost, sharp diminishing returns).

Implementation decisions:
- Lens delivery: getEffectivePrompt special-cases agentType 'adversary' to return buildAdversaryPrompt(config.adversaryRole), exactly paralleling the existing writer/writingStyle case. Chose this over baking the full prompt into config.prompt so the critic node stays a clean editable "template" and edits do not fight a stored string.
- Verdict labels Passed / Needs revision (over the preset's Approved / Revise) so the generated routing echoes the critic's verdict words; the generators match the revise branch by label, so any labels work.
- Atomicity via the existing batchUndo(fn) helper (single pushUndo + try/finally) rather than a hand-rolled pushUndo/_undoBatch flag. Chose batchUndo over the manual flag (as in addParallelGroup) because try/finally guarantees _undoBatch cannot stick true if an inner call throws, which would otherwise silently suppress all future undo. Adopted after the adversarial review flagged the missing try/finally.
- Control surface: a single context-menu item (ctxAdversary) that toggles Add/Remove, gated to Agent/Task nodes, mirroring the existing ctxAddBranch precedent. A second future one-click action is now just another ctx* item + toggle fn.

## Surface area (file -> role) - VERIFIED by grounding

index.html:
- 1215-1220 AGENT_TYPE_PROMPT_MAP: add `adversary: 'adversary'`.
- 984-996 AGENT_TYPES (11 entries): add `adversary` -> becomes 12 (tests.html:455 asserts 11, must bump to 12).
- 1264-1290 PROMPTS: add `PROMPTS.adversary` (string) = generic-lens build; add `buildAdversaryPrompt(reviewedRole)` + `ADVERSARY_LENSES` map.
- 1224-1235 getEffectivePrompt: add an `agentType==='adversary'` branch returning buildAdversaryPrompt(node.config.adversaryRole) - parallels the existing writer/writingStyle special-case.
- 1241-1259 classifyAgentPrompt: same adversary branch so an attached critic reads as 'template', not 'custom'.
- 3149-3187 addNode/addConnection (string ids "n7"/"c9"; addConnection already rejects self-loop + duplicate from/to). 3110-3120 pushUndo/_undoBatch (whole-state deep-clone snapshot). 3189 deleteNode strips a node + its edges. New `attachAdversary(id)` / `detachAdversary(id)` / `toggleAdversarialReview()` mirror addParallelGroup's batched pattern (one pushUndo, _undoBatch=true, mutate, false, render+updateConfig).
- 807-811 context menu + 3795-3802 showContextMenu: add a `ctxAdversary` item shown only when sel.type is agent/task, label toggles Add/Remove by attached state.
- 5854/6019/6273/6499/6783 generators: NO change needed - they match the revise branch by `c.label === d.config.noLabel`, role-agnostic, so the adversary loop renders unchanged (verified).

tests.html: new suite (role resolution, template asserts, lens-by-role, attach+undo, detach, no-double-attach, offered-only-on-agent/task, generator output) + bump the length-11 assertion at line 455 to 12.

Reuse anchor: Feature Dev preset index.html:5206-5217 is the exact Reviewer->Decision->back-edge recipe to mirror (back-edge = addConnection(d.id, target.id, noLabel); forward = addConnection(d.id, downstream, yesLabel)).

## Task checklist

- [x] Ground the design against the real code (functions, node/connection model, preset loop, undo, UI surface, test conventions)
- [x] Planner checkpoint: presented role-lens mechanism, attach/detach graph ops, final wording, verdict-to-Decision wiring; director signed off (go with recommendations: Passed/Needs revision labels, context-menu control, AGENT_TYPES bump)
- [x] Add adversary role template (one template + role-aware lens via ADVERSARY_LENSES + buildAdversaryPrompt) and wire into AGENT_TYPES + AGENT_TYPE_PROMPT_MAP
- [x] Recognize adversary in getEffectivePrompt + classifyAgentPrompt (branch mirrors the writer/writingStyle special-case)
- [x] Implement one-click attach (atomic, undoable) on Agent/Task nodes (attachAdversary)
- [x] Implement symmetric detach + no-double-attach guard (detachAdversary, hasAdversaryAttached, canAttachAdversary, toggleAdversarialReview) + context-menu item ctxAdversary
- [x] Verify generators render adversary + revise loop (no generator change needed - they match the revise branch by c.label === noLabel; confirmed by genWorkflow test)
- [x] Write tests (role resolution, template asserts, lens-by-role, attach/undo, detach, no-double-attach, offered-only-on-agent/task, generator output) - 21 new tests
- [x] Run ./run-tests.sh; confirm baseline rises and no regressions - 671/671 pass (was ~650)
- [x] Independent adversarial review pass - VERDICT PASS, no Critical/High. Acted on its one actionable note: hardened attach/detach to use batchUndo (try/finally) so _undoBatch cannot stick true. Re-ran tests: 671/671.

## Verify

Command: ./run-tests.sh (headless Chrome over tests.html). Result: 671/671 pass (baseline was ~650; 21 new adversary tests, no regressions).

## Gotchas / non-obvious

- The role-aware lens travels via node.config.adversaryRole, NOT a baked config.prompt - getEffectivePrompt special-cases agentType 'adversary' (parallel to the existing writer/writingStyle case). So an attached critic stays a "template" node (editable, classifies cleanly), and the lens is selected at render time.
- Attach re-routes the target's ORIGINAL outgoing edge labels to plain 'Passed' on the decision branch; detach restores them as plain (unlabeled) edges. Forward edges out of an agent/task are effectively never labeled, so this is lossless in practice, but a target whose forward edge carried a custom label would lose it on attach+detach. Acceptable.
- Deleting a target node (or Disconnect All) does NOT auto-remove its attached critic+decision - same as deleting any node leaves its neighbors. The orphaned critic keeps adversaryFor pointing at the gone target; harmless (no-double-attach checks by id, which no longer exists).
- Test bridge: top-level `const`s are not auto-exposed to the iframe window; only function declarations are. AGENT_TYPE_PROMPT_MAP (a const) had to be added to the tests.html win.* bridge (line ~5564). buildAdversaryPrompt/attachAdversary/etc. are function declarations, so auto-exposed.
- Visual-read gotcha (not a bug): on attach, the target's original outgoing edge is rerouted to become the new Decision's "Passed" branch. So after attaching a critic to a node whose downstream was, say, a Reviewer, the edge INTO that downstream now originates from the critic's Decision diamond, not from the target or the critic node. At a glance the critic can look like a dead-end and the downstream like it is orphaned, when the path is really target -> critic -> Decision --Passed--> downstream. The path is intact; only the edge's visible origin moved. (Also: attaching a critic to a node whose downstream is already a reviewer produces a back-to-back double review - working as designed, the user's choice.) Verified via edge trace on the feature preset 2026-06-18.

## Outcome

Shipped a generic adversarial-critic capability, additive and uncommitted (Blue commits). What changed:
- New `adversary` agent role: one refute-first template (buildAdversaryPrompt) with a role-aware lens (ADVERSARY_LENSES + ADVERSARY_LENS_BY_ROLE), a strict materiality bar (default PASS, NEEDS REVISION only for Critical/High material defects, never nitpicks), severity gating, and a PASS / NEEDS REVISION verdict contract. Wired into AGENT_TYPES (now 12) and AGENT_TYPE_PROMPT_MAP; resolved by getEffectivePrompt/classifyAgentPrompt via an adversary branch that parallels the writer/writingStyle case.
- One-click attach/detach: a context-menu item (ctxAdversary) on Agent/Task nodes that, in a single undoable action (batchUndo), builds target -> critic -> Decision with a Needs revision back-edge to the target and a Passed forward branch to the original downstream. Symmetric detach restores the original downstream; a no-double-attach guard and a toggle label complete it. Reuses the existing Decision/maxRevisions loop, so all five generators render the revise loop unchanged.
- Surface: index.html (role map + templates + buildAdversaryPrompt, getEffectivePrompt/classifyAgentPrompt branches, attachAdversary/detachAdversary/toggleAdversarialReview/hasAdversaryAttached/canAttachAdversary, ctxAdversary markup + showContextMenu). tests.html (21 new tests across 5 suites; AGENT_TYPES length 11->12; AGENT_TYPE_PROMPT_MAP added to the win.* bridge).
- Verification: ./run-tests.sh -> 671/671 pass. Independent adversarial review verdict: PASS, no Critical/High; its one actionable note (try/finally around the undo batch) was addressed by adopting batchUndo.

Follow-on (preset demos): wired the critic into two presets as teaching demos, deliberately sparse to model the materiality ethos. Feature Development gets a critic on the Planner (review the plan before implementation - a non-code artifact, highest-leverage spot; shown alongside the existing balanced code-review loop for contrast). Documentation swaps its balanced Doc Reviewer for an adversary critic on the Doc Writer (writer lens; accuracy vs the code) and gains the revise loop it lacked - a different scenario (writing vs planning). Wired inline in the preset builders with the adversaryFor/adversaryDecisionFor markers (NOT via attachAdversary, whose batchUndo would reset the preset's own _undoBatch); loadPreset's autoLayout positions everything, verified clean in the browser (single horizontal flow, both loops curve below, no tangle). Test updates: feature 4->5 agents; documentation now memory-enabled (gained a decision); +2 preset-demo tests. Suite now 673/673.

## Built with (provenance)

Workflow: Generic adversarial-critic agent with one-click attach. Roles: Planner -> Implementer -> Reviewer (-> revise loop, max 3) -> Tester. Grounded by direct code reading of index.html/tests.html (no external code-search index for this personal repo). Orchestrator enforces a PLANNER CHECKPOINT for director sign-off before edits.

## Links

Work item: .workflow/_backlog.md item 7. Branch: TBD. PR: TBD.
