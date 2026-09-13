# Feature (fast) preset (the speed variant without the plan-skeptic loop)

Context: no work item (direct session, director-requested: a one-click fast variant of Feature Development for small, low-risk features). Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- A **Feature (fast)** tile (preset key `feature_fast`) sits FIRST inside the More presets fold. Its tooltip names the trade: Feature Development minus the plan-skeptic loop, for small, low-risk features where a flawed plan is cheap to correct; the reviewer gate and tester keep the quality floor.
- Shape: Requirements -> Planner -> Implementer -> Reviewer -> "Review Passed?" decision (Revise loops back to the Implementer) -> Tester -> Feature Complete. Every node config (agent types, tools, prompts, maxTurns, decision condition and labels) is IDENTICAL to the corresponding Feature Development nodes - the delta is exactly the removed skeptic pair (Skeptic review + "Plan sound?" gate).
- The parent tile's desc now reads "Plan (Skeptic) -> Implement -> Review -> Test" (matching the Delivery Swarm desc convention), so the two shapes read differently at a glance.
- `STORY_PLACEHOLDERS.feature_fast` aliases the feature template (single-sourced by assignment, no copy).
- Memory auto-enables on load (the review decision loop qualifies), pinned by test.

## Why and scope

The plan-skeptic loop is Feature Development's expensive half (up to 3 plan revisions before any code exists) - overhead for small, well-understood features. Bug Fix needed no variant: it has no skeptic or verifier, and its only loop is the tester gate, whose removal would ship unverified fixes. One tile, placed inside the fold, keeps the roster from sprawling. Scope: markup tile + parent desc, one builder, one placeholder alias, one structure test, README bullet (intro de-numbered). Non-goals: no fast Bug Fix, no verifier added to Feature Development (the right-click verification loop is the sanctioned one-click way to add one - user's choice, per the presets-are-opinions-you-override doctrine).

## Approach and decisions

- Clone-minus-skeptic (rejected: a distinct lighter shape) - keeping every remaining node byte-identical to the parent makes the tooltip's claim literally true and the maintenance surface zero.
- Name "Feature (fast)" (rejected: "Quick Feature") - Feature-first groups it with its parent when scanning and the parenthetical matches the roster's label style; director concurred.
- README intro de-numbered ("Nineteen" -> none) - counts rot on every addition; the de-numbering doctrine already applied elsewhere.

## Verify

- `./run-tests.sh`: 1743/1743 (structure pin: 4 agents, no adversary, no reviewLoopFor, Revise back-edge to the Implementer, memory auto-enable)

## History

- 2026-09-12: created (tile, builder, placeholder alias, parent desc, README). 1742 -> 1743 (by direct session)
- 2026-09-13: review round - the byte-identical claim is now ENFORCED (a drift-immunity test snapshots the feature preset's seven shared node configs by label and deep-compares them on feature_fast), and the preset joined BOTH hardcoded audit sweeps: the advisor calibration list and the validation-warnings list (which also gained delivery_swarm, analysis_forecast, and incident_rca - pre-existing omissions proven clean when added). 1745 -> 1751 across the round (by direct session)
