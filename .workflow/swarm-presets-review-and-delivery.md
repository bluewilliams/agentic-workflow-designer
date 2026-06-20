# Swarm presets: Review Swarm (rename) + Delivery Swarm (new showcase)

Work item: Blue - the "Agent Swarm" preset name did not signal its read-only code-review focus, and there was no preset showing off the full toolkit. Status: DONE (uncommitted; Blue commits). Tests: 724/724.

## What changed

1. **Renamed** the existing `swarm` preset display name "Agent Swarm" -> **"Review Swarm"** (desc now "[Security | Quality | Performance | Architecture] -> Audit Report"). Internal preset key stays `swarm` (saved workflows, placeholder map, and the agent-count test are unaffected). It is a read-only parallel audit that never touches code.

2. **Added a new showcase preset** `delivery_swarm` -> **"Delivery Swarm"**: an intricate end-to-end build that demonstrates the marquee features in one flow - two parallel fan-outs, the Skeptic (doubt early) AND the Verifier (prove late), plus a review gate and tests.

   Topology (20 nodes, 11 agents, 25 connections, 0 dangling):
   `Feature/Ticket -> Discovery Swarm (fork) -> {Codebase Cartographer, Requirements Analyst, Prior-Art Researcher} -> Synthesize (join) -> Lead Planner [Skeptic loop: Plan sound?] -> Build Swarm (fork) -> {Backend Engineer, Frontend Engineer} -> Merge (join) -> Integrator [Verifier loop: Objective met?] -> Code Reviewer -> Review passed? -> Test Engineer -> Feature Delivered (format code / Leave Uncommitted)`

   - Skeptic attached to Lead Planner via the standard markers (agentType 'adversary', adversaryRole 'planner', reviewLoopFor/reviewLoopKind on the reviewer + reviewLoopDecisionFor on the decision). Decision back-edge "Needs revision" -> Lead Planner.
   - Verifier attached to Integrator (agentType 'verifier', reviewLoopKind 'verifier'). Decision back-edge "Not verified" -> Integrator. Final review gate "Revise" also loops back to Integrator.
   - Output format `code` (Leave Uncommitted) - the safe preset default; no preset uses pr.

3. **4 new house-style PROMPTS** (after reportBuilder): `codebaseCartographer` (map touch points, never design), `requirementsAnalyst` (testable acceptance criteria + open questions + out-of-scope), `priorArtResearcher` (reuse before reinvent, in-repo precedent first), `integrator` (reconcile the parallel streams into a working whole, do not commit). Reused existing prompts for planner/backend/frontend/reviewer/tester. Discovery agents use agentType researcher/planner (valid types).

## Files

- index.html: 4 new PROMPTS; sidebar preset items (rename swarm display, add delivery_swarm); `delivery_swarm` builder in the presets map (after `swarm`); `presetPlaceholders.delivery_swarm`.
- tests.html: delivery_swarm agent-count (11) test; "delivery_swarm review loops" suite (Skeptic on planner = adversary, Verifier on integrator = verifier; 0 dangling; 4 parallel nodes).
- README.md: Review Swarm + Delivery Swarm preset descriptions.
- TECHNICAL.md: preset table rows for Review Swarm + Delivery Swarm.

## Verification

- Headless smoke: loadPreset('delivery_swarm') -> 20 nodes / 11 agents / 25 conns / 0 dangling; planLoop=adversary, integLoop=verifier; no blank effective prompts; all 5 generators render without throwing (37-62K chars).
- Full suite 724/724.

## Naming note

CONFIRMED by Blue (2026-06-19): "Review Swarm" (audit) + "Delivery Swarm" (build). He had floated "Agent Swarm Review" but chose the cleaner purpose-first pair. Internal keys `swarm` / `delivery_swarm` are independent of the labels.

## Built with (provenance)

Direct implementation by the orchestrator. Reused the review-loop construction pattern from the `feature` (Skeptic) and `ui_component` (Verifier) presets.

## Links

Branch: TBD. PR: TBD.
