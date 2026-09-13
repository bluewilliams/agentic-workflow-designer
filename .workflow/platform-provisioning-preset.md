# Platform Provisioning preset (greenfield delivery plumbing, estate-first)

Context: no work item (direct session, director-requested after a roster coverage audit found one gap: greenfield platform provisioning - new repos, IaC, pipelines, registries, access wiring - with deploy-proof verification). Design validated against two real-world foundation-scaffolding epics (a frontend one and a backend one) reviewed via MCP for shape only; nothing from them appears in this repo, and the crafts are host-generic by contract. Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- A **Platform Provisioning** tile (preset key `platform_provisioning`) sits in the More presets fold beside DevOps / Infrastructure. Shape: Provisioning Brief -> Estate Surveyor -> Provisioning Planner -> Skeptic gate ("Plan sound?") -> Provisioner -> Convention Reviewer gate ("Conventions hold?") -> Deploy Verifier -> "Provision proven?" gate -> Platform Ready. Six agents; the verifier is a MAINLINE step with a bespoke prompt and a plain revision loop back to the Provisioner (not review-loop machinery), because its evidence-table contract is the preset's core value.
- Five bespoke crafts in `PROMPTS`:
  - `estateSurveyor` (researcher): precedent mining before creation - newest shipped sibling per deliverable kind, templates and generators with exact invocations and parameters, pinned pipeline/provider versions, the naming grammar derived from real examples (with length/character limits), access-registration pattern, observability baseline. Gaps are open questions, never guesses.
  - `provisioningPlanner` (planner): every expensive decision BEFORE creation - deliverables inventory, the name cascade (names traced to everything derived from them), template parameters with wrong-value consequences, cross-repo contract literals written ONCE with every consumer listed (mismatches fail silently), the environment matrix (parity default), the lead-time register ordered FIRST (external reviews, slow release trains), the automated-vs-manual split with copy-ready instruction blocks for human-permission items, and a provable Done Means per deliverable per environment.
  - `provisioner` (coder): generate over clone over invent; remote creation via connected MCPs; permission-blocked steps become verbatim manual handoffs and never block local scaffolding; name cascade applied exactly (conflicts surfaced, never improvised); literals copied character for character; whole environment-matrix rows; never commit a credential (secrets check on generated/copied files - templates are where tokens travel); planned skeletons only.
  - `provisioningReviewer` (reviewer): fidelity check against the Convention Ledger and the plan - sibling shape, pinned-version drift (always gates), full matrix (never a sample), cascade and literal greps at every consumer, secrets (always Critical), manual-handoff precision.
  - `deployVerifier` (verifier, mainline): per-deliverable per-environment evidence table - build green, deploy healthy, gate denies without the grant (test the negative), package installs, IaC applies clean. Cells are VERIFIED (with evidence) / MANUAL (with the exact human check - never silently passed) / FAILED (loops back).
- `STORY_PLACEHOLDERS.platform_provisioning` asks for deliverables, target platforms + connected MCPs, the environment list, precedents to mirror, naming decisions, access requirements, and out-of-scope.
- Both preset-audit sweeps (advisor calibration, test_automation excepted by design; validation warnings) are DERIVED from the sidebar tiles, so every preset - present and future - is audited automatically, with a tile-without-builder guard.

## Why and scope

The preset roster covered frontend, backend, quality, research, and amendment work, but greenfield provisioning was stretched over the DevOps preset, whose prompts assume an existing codebase to read conventions from. Real scaffolding epics show a different risk profile: the expensive mistakes are pre-creation decisions (names cascade into packages/images/namespaces, generator parameters gate regeneration, shared literals fail silently, external items burn calendar), and "done" is proven by deployment evidence, not by a Tester. Hence the two structural upgrades over a naive shape: an Estate Surveyor BEFORE the planner, and a Skeptic ON the plan. MCP posture is the house one: hints and capability, never restriction; graceful absence via manual handoffs. Scope: five prompts, one builder, tile, placeholder, structure + craft pins, calibration-sweep membership, README bullet. Non-goals: no vendor-specific variants (Custom MCP notes and the MCP toggles carry specifics), no fast variant.

## Approach and decisions

- Mainline Deploy Verifier with bespoke prompt (rejected: verifier review-loop machinery) - loop-machinery verifiers are auto-prompted, and the per-environment evidence-table contract must be explicit.
- Skeptic via the existing adversary machinery with `adversaryRole:'planner'` (rejected: a bespoke plan-critic prompt) - the canonical skeptic already scrutinizes contracts, coupling, and boundary conditions, and reuse keeps one skeptic voice app-wide.
- Convention review BEFORE deploy verification (rejected: verify-then-review) - reading is cheap, deploy cycles are expensive, and a full-matrix config check catches deploy-time failures at review time.
- Host-generic crafts pinned by test ("version-control host" phrasing asserted) - the generalization is a contract, not a habit.

## Verify

- `./run-tests.sh`: 1731/1731 (structure pin: 6 agents, skeptic wired to the planner, both gates' back-edges, verifier prompt identity, placeholder; craft pins in their own suite: precedent-first, name cascade, literals-once, lead-time register, credential hygiene, whole-matrix review, evidence table, MANUAL-never-silent, negative-gate test, host-generic phrasing; both audit sweeps pass, derived from the sidebar tiles so counts cannot rot)
- Content lint clean on all touched files (the design-source epics' identifiers appear nowhere in the repo)

## History

- 2026-09-13: created (five crafts, builder, tile, placeholder, pins, README) after design validation against two real foundation-scaffolding epics; feature_fast added to the calibration sweep in the same change. 1743 -> 1745 (by direct session)
- 2026-09-13: review round 2 (9 findings adjudicated, 8 acted on, 1 label alignment) - both audit sweeps derived from the sidebar tiles (the hand lists rotted twice), the advisor emitsVerdict heuristic widened to verifier vocabulary (VERIFIED/FAILED tables and NOT VERIFIED were invisible, so a rewired Provision proven? gate drew no nag), the feature_fast drift test made two-directional (fast-only nodes are drift, drifted nodes named), craft pins rehomed from the Amend-presets suite to their own describe, the skeptic label aligned to what a detach/re-attach regenerates, the record count de-numbered, and the untracked record file staged. 1751 -> 1731 (validation sweep consolidated, assertions preserved) (by direct session)
