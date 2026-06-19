# Verifier role + generalized review-loop family

Work item: follow-on to backlog #7 (the adversarial critic). Status: complete, uncommitted (Blue commits). Tests: 689/689. Review: PASS (no Critical/High).

## Why and scope

Add a second one-click review kind - a Verifier whose job is to PROVE the outcome meets the objective with evidence (run it, call the API, drive the browser, follow the doc steps), distinct from the Skeptic which critiques by inspection. Generalize the Skeptic's hardcoded one-click attach into a small kind-parameterized "review-loop family" so a third kind is trivial later. Also rename the Skeptic's user-facing display from "Adversary" to "Skeptic" (the user picked Skeptic + Verifier).

Non-goals: no change to the Skeptic's behavior or graph shape; no new palette node type; no multi-critic panel; internal agentType id for the Skeptic stays `adversary` (only the display name changed).

## Requirements

R1. A new `verifier` role MUST resolve like any role (AGENT_TYPES + AGENT_TYPE_PROMPT_MAP + PROMPTS.verifier), with NO role-lens (one strong default prompt). (tests: `verifier role`)

R2. PROMPTS.verifier MUST be a strong default with no custom notes: anchor on a definition of done; honor custom acceptance notes when present; cover running code/tests, calling an API, driving a browser UI, following documentation steps, data/migration, infra, research, and design; an evidence ladder that never fakes a pass; try-to-break; non-destructive/local safety; and a routable VERIFIED / NOT VERIFIED verdict + convergence. (tests: `verifier prompt content`)

R3. The one-click attach MUST be generalized to a kind-parameterized family (REVIEW_LOOP_KINDS + attachReviewLoop/detachReviewLoop/toggleReviewLoop/getReviewLoop/hasReviewLoop/canAttachReviewLoop) with generic markers reviewLoopFor/reviewLoopKind + reviewLoopDecisionFor. The Skeptic ('adversary') and Verifier are the two kinds. (tests: `review-loop family`)

R4. Verifier attach MUST build target -> verifier -> Decision("Objective met?") with Verified forward and Not verified back-edge, in one undoable action; verifier gets execution tools (Bash + WebFetch). (tests: `review-loop family` attach/undo)

R5. One review loop per node: attaching a second loop of EITHER kind MUST be a no-op. (test: `allows only one loop per node`)

R6. A review node (Skeptic OR Verifier) MUST NOT be attachable as a review target. (test: `cannot attach a review loop to a Skeptic or Verifier node`)

R7. The context menu MUST show both "Add skeptic review" + "Add verification" on a bare Agent/Task; when a loop is attached show that kind's "Remove ..." and hide the other; hide both on a review node. (verified in-browser)

R8. The Skeptic MUST be unchanged in behavior: same graph shape, same role lens via config.adversaryRole, backward-compat aliases (attachAdversary etc.) still work; display name now "Skeptic". (tests: existing Skeptic suites via aliases + `keeps the Skeptic working`)

R9. New markers MUST survive serialize/deserialize (deep-cloned config) so detach + no-double-attach work after reload. (covered by existing serialization deep-clone)

R10. No regressions. (full suite 689/689)

## Approach and decisions

- REVIEW_LOOP_KINDS map holds per-kind config (labelPrefix, decisionLabel, condition, yesLabel/noLabel, tools, maxTurns, useRoleLens, menu strings). attachReviewLoop/detachReviewLoop read from it. Adding a third kind = one more entry + one menu item.
- Verifier has NO lens (one strong default prompt) - chose this over a role-keyed lens because verification METHOD is driven by the artifact under test (which the prompt's method-menu self-selects), not by the producing node's role. Simpler and more accurate than the Skeptic's lens.
- Verifier tools include Bash + WebFetch (it must execute to gather evidence); the Skeptic stays read-only. Browser automation is mentioned in the prompt as "if available" (MCP, not a togglable tool).
- Display rename only: AGENT_TYPES name 'Adversary' -> 'Skeptic'; internal id stays 'adversary'. Precedent: AGENT_TYPE_PROMPT_MAP already decouples id from prompt key (coder->implementer, debugger->investigator). Avoids churning the working feature's id/markers/tests.
- Generic markers reviewLoopFor/reviewLoopKind/reviewLoopDecisionFor replace adversaryFor/adversaryDecisionFor everywhere (attach code + 2 preset demos + tests). adversaryRole kept (Skeptic-only lens key). Rejected keeping adversaryFor for a verifier node (semantically wrong for maintainers).
- Backward-compat aliases (attachAdversary/detachAdversary/hasAdversaryAttached/canAttachAdversary/toggleAdversarialReview) delegate to the generic functions - keeps existing test call sites and any muscle memory working with no churn.
- One review loop per node (kind-agnostic hasReviewLoop), enforced in attach + surfaced in the menu. Rejected allowing skeptic+verifier on the same node (graph clutter, confusing semantics).

## Surface area (file -> role)

index.html:
- AGENT_TYPES: 'adversary' name -> 'Skeptic'; +verifier entry (now 13).
- AGENT_TYPE_PROMPT_MAP: +verifier:'verifier'.
- PROMPTS.verifier: the default verifier prompt (the centerpiece).
- REVIEW_LOOP_KINDS + getReviewLoop/hasReviewLoop/canAttachReviewLoop/attachReviewLoop/detachReviewLoop/toggleReviewLoop + the 5 backward-compat aliases (replaced the old attachAdversary block).
- Context menu: ctxAdversary -> ctxSkeptic + new ctxVerifier; showContextMenu setReviewItem two-item logic.
- Presets: feature + documentation demos use the generic markers + 'Skeptic review:' labels.

tests.html: AGENT_TYPES length 12->13; 'Adversary'->'Skeptic' display + role; marker renames; +`verifier role`, `verifier prompt content`, `review-loop family` suites (16 new). 689 total.

## Task checklist

- [x] Rename Skeptic display name (AGENT_TYPES) - id stays 'adversary'
- [x] Add verifier role (AGENT_TYPES + map + PROMPTS.verifier)
- [x] Author the default verifier prompt (method menu + evidence ladder + safety + verdict + convergence)
- [x] Generalize attach into REVIEW_LOOP_KINDS + generic functions + aliases
- [x] Generic markers reviewLoopFor/reviewLoopKind/reviewLoopDecisionFor (attach + presets + tests)
- [x] Two context-menu items + setReviewItem one-loop-per-node logic
- [x] Tests: verifier role/prompt/family + updated Skeptic tests; 689/689 green
- [x] Browser-verify menu states + verifier render (Objective met? / Verified / Not verified; "Verifier" subtitle)
- [x] Independent adversarial review - PASS, no Critical/High (traced refactor blast radius, undo, serialization, exclusions, prompt)

## Verify

Command: ./run-tests.sh -> 689/689 pass. Browser: context-menu states correct (both add / remove+hide / both-hidden-on-review-node); verifier renders as Builder -> Verification -> Objective met? -> [Verified] forward / [Not verified] back-edge. Independent adversarial review verdict: PASS (no Critical/High) - confirmed the generic attachReviewLoop('adversary') builds the identical graph the old code did, the back-edge label equals the decision noLabel for both kinds (generators match unchanged), the Skeptic lens fires only via useRoleLens, verifier resolves with no lens, markers survive deep-clone serialization, and the new tests assert real behavior.

## Gotchas / non-obvious

- Internal id 'adversary' displays as 'Skeptic' (intentional, mirrors coder->implementer). buildAdversaryPrompt/ADVERSARY_LENSES/adversaryRole keep the 'adversary' naming internally.
- Verifier has no lens; getEffectivePrompt resolves it via the normal map (no special branch, unlike the Skeptic).
- Same visual-read gotcha as the Skeptic: on attach the edge into the original downstream now originates from the Decision diamond, not the review node.

## Outcome

Shipped the Verifier and generalized the one-click into a review-loop family, additive and uncommitted (Blue commits). What changed:
- New `verifier` role: PROMPTS.verifier, a strong no-notes default that anchors on a definition of done, self-selects a verification method per artifact (run code/tests, call an API, drive a browser UI, follow documentation steps, reconcile data, dry-run infra, re-derive research, trace a design), climbs an evidence ladder that never fakes a pass, tries to break the work, stays non-destructive/local, and ends on a routable VERIFIED / NOT VERIFIED verdict with convergence. Execution tools (Bash, WebFetch). No role lens (resolves via the map).
- Generalized review-loop family: REVIEW_LOOP_KINDS config + attachReviewLoop/detachReviewLoop/toggleReviewLoop/getReviewLoop/hasReviewLoop/canAttachReviewLoop, generic markers reviewLoopFor/reviewLoopKind/reviewLoopDecisionFor, two context-menu items (ctxSkeptic, ctxVerifier), one-loop-per-node, review nodes excluded as targets. Backward-compat aliases keep the Skeptic's old function names working.
- Skeptic display rename (Adversary -> Skeptic), internal id unchanged. Preset demos relabeled "Skeptic review:" and switched to the generic markers.
- Verification: 689/689 tests (16 new). Browser-verified menu states + render. Independent adversarial review: PASS, no Critical/High.

Follow-on (preset demo + docs): added a Verifier demo to the ui_component preset - attached (one-click shape) to the UI Implementer so it proves the built component works (browser-driven) before the UI Reviewer; "Not verified" loops back to the implementer. ui_component goes 3->4 agents and is now memory-enabled (gained a loop). This is the "prove late" half that complements the Skeptic-on-the-plan demos. Tests 689->690. README updated: a Quick Start (paste requirements -> pick preset -> copy Sub-Agents prompt -> send to Claude), a "Review Loops: Skeptic & Verifier (one-click)" section, the two new agent types, the context-menu mention, and the 3 demoed preset descriptions.

## Built with (provenance)

Workflow: direct implementation by the orchestrator (mostly assembly onto the existing review-loop machinery + one authored prompt) with a PLANNER CHECKPOINT (Blue signed off Skeptic+Verifier naming + the verifier prompt) and an independent adversarial code-review pass. Related to .workflow/generic-adversarial-critic-agent-with-one-click-attach.md (same `adversarial-review` capability).

## Links

Work item: .workflow/_backlog.md item 7 (follow-on). Branch: TBD. PR: TBD.
