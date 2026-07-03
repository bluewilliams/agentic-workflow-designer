# Prompt overhaul wave C: specialized expertise, Analyst type, two new presets

Branch: main. Status: current.

```awd:record
{"slug": "prompt-overhaul-wave-c", "status": "current", "date": "2026-07-03", "files": ["index.html", "tests.html", "README.md", "TECHNICAL.md"], "verify": ["./run-tests.sh", "grep -c \"analysis_forecast\" index.html"], "superseded_by": null}
```

## Current behavior

The specialized templates are expertise-first: securityAuditor opens with a threat-model preamble (assets, trust boundaries, attacker goals) and reports only reachability-verified findings with exploitability-x-impact severity; perfProfiler names suspects and a representative workload before measuring and only optimizes what profiling indicted; migrationEngineer plans expand-contract with schema/backfill separation, lock awareness, and explicit deploy-order coupling; devopsEngineer carries least-privilege, secrets-never-in-code, idempotent-pipeline, and environment-promotion discipline; codeAnalyzer ranks hotspots by churn x complexity under an actionability bar; archReviewer demands traced evidence for every claim; writerBusiness labels every figure measured or estimated with provenance. The test-automation family discovers its stack from the repo (BDD framework, assertions, DI, locators, logging - recency-weighted) with all former C#/SpecFlow/Appium names demoted to examples. A 14th agent type, Analyst ("Measures, estimates, and forecasts with visible methodology"), is fully wired: analysisSynthesizer template, gatherer tool set, a dedicated analysis Skeptic lens (arithmetic follows from inventory, units carried, measured-vs-estimated separation, assumption sensitivity, sanity-check bite), membership in both step-hint role sets, and a bespoke OpenSpec analysis record-section group; the auto-builder's analysis nodes are analyst-typed. Two new presets ship the new idioms end to end: Analysis & Forecast (Gatherer -> Analyst -> analysis-lens Skeptic gate "Numbers hold up?" -> business-writer report) and Incident RCA (Investigator with write tools for the failing repro -> Verifier loop "Root cause verified?" -> RCA-shaped technical writer), both with story placeholders and calibration-clean. The advisor's rule (g) flags review-role verdicts that route nowhere.

## Why and scope

Wave C of the prompt-overhaul campaign (see prompt-overhaul-wave-a/b): the deep review found the specialized set tutorial-heavy with named expertise gaps, the test-automation family silently stack-locked to one tech stack, analysis work reviewed under the wrong Skeptic lens, and verdict-routing dead ends invisible to the advisor. The owner licensed new agent types and presets where appropriate.

## Key decisions

- **Analyst as a first-class type over template-identity lens keying**: the review suggested keying the analysis lens by effective-prompt identity; a real type is simpler and buys tool defaults, hint membership, OpenSpec grouping, and honest Explain provenance in one stroke. The auto-builder retype means a Skeptic attached to analysis work now scrutinizes arithmetic instead of source citations.
- **Incident RCA pairs the Investigator with the VERIFIER, not the Skeptic**: a root cause is proven by execution (repro, trace), not argued - the preset encodes doubt-by-demonstration. RCA writer = technical writer + RCA-shaped Agent Context (impact, timeline, mechanism, why safeguards missed it, prevention by leverage) rather than a new template - the shelf fit.
- **Advisor rule (g) is type-gated to review roles** (reviewer/adversary/verifier): the first cut fired on every post-gate Tester (their handoffs carry pass/fail language legitimately) - the calibration test caught it, and the gate preserves zero-nag presets. A tester-typed dead-end validator would be missed; accepted, documented.
- **Test-family DRY extraction skipped honestly**: the review's "~70% verbatim" predated wave B (the tester rewrite diverged the family); no verbatim region survives across even four of the five templates, so a helper would manufacture a seam to save under 1KB.
- appExplorer verified already stack-agnostic (its identifier list spans web/Android/iOS/framework-specific); left untouched.
- Preset skeptics predating wave 0 keep maxTurns 5 in their explicit configs; only the two new presets use the raised defaults (8/10). Sweeping old presets to 8 was considered and deferred - their turn budgets were calibrated as a set.

## Changes

- index.html: 7 specialized template rewrites; 5 test-automation templates de-hardcoded (+ testPlanner/screenObjectWriter discovery preambles); Analyst wiring across 8 maps/sets; analysis_forecast + incident_rca presets + palette entries + story placeholders; advisor rule (g).
- tests.html: +7 tests (Analyst wiring x3, preset shapes x2, rule g, smoke) and lockstep updates (AGENT_TYPES length 14, STEP_ROLES 13, calibration 17 presets).
- README (16 presets + 2 entries), TECHNICAL (count fixes).

## Verification

- 1322 -> 1329, suite green after every item; content-lint grep exit 1; smoke test generates + explains both presets through the real rig.

## Task checklist

- [x] 7 specialized templates expertise-first (handoff fields stable)
- [x] test_automation family stack-discovery (+ DRY skip documented)
- [x] Analyst type: template map, tool defaults, analysis lens, step-role sets, OpenSpec group, auto-builder retype
- [x] Analysis & Forecast preset (analysis-lens Skeptic gate, business finisher, placeholder)
- [x] Incident RCA preset (Verifier loop, RCA-shaped writer, placeholder)
- [x] Advisor rule (g) verdict-routing, type-gated, calibration-clean at 17
- [x] Docs: README/TECHNICAL counts + preset entries
- [x] Suite green (1329/1329); content-lint

## Update (same pass): preset Skeptic turns swept

The deferred judgment was overridden by the coordinator: the shallow-PASS risk that justified raising the Skeptic default to 8 applies equally to the older presets' explicit maxTurns:5 skeptics - "left as calibrated" described their age, not a decision. All four preset skeptic nodes swept 5 -> 8.

- [x] 4 preset skeptic maxTurns 5 -> 8

## Update (same day): orchestration craft - the conductor gets the expertise treatment

Owner asked whether the orchestrator itself was in best shape for the three core formats; review verdict: the agents got expertise-first treatment while the conductor kept mechanics ("evaluate the output against the criteria" was the deepest line). New orchestratorCraft(format, hasParallels) content helper (one source, per-format containers) emits five judgment bullets in Workflow/Sub-Agents/Teams: brief down do not dump (generalizes the Atlassian one-coherent-spec rule to all step briefing - pass signal, not transcripts); grade gates on evidence honestly (never soften a failure because the run is long - the gate exists because passing bad work downstream costs more than one more cycle); surgical revise briefs (critic blockers verbatim + what was already acceptable so the step fixes rather than rewrites + cycle count); step-failure handling format-fitted (sub-agents/teams: ONE re-run with a sharpened brief, then record-and-decide, never silently absorb the step's job; workflow single-session: one fresh attempt informed by the failure, then record-and-decide); reconcile fan-in (only emitted when a fork exists - concatenated contradictions are not a synthesis). SDK and Claude.ai deliberately excluded (programmatic / single-conversation - the delegation craft does not apply; Claude.ai keeps its inline gate instructions). Also fixed a real contradiction the review surfaced: genWorkflow's Implementation Notes told the orchestrator to "spawn sub-agents for each step" while its execution model directive says single-session - the bullet now matches the model (run steps yourself; Task only for parallel-marked steps). Explain anatomy gained an "Orchestration craft" row (emitted core formats with live probe, skipped claude with reason).

- [x] orchestratorCraft() helper (one source; failure bullet format-fitted; fan-in gated on forks)
- [x] Injected: genWorkflow Implementation Notes, genSubAgents pre-delivery, genAgentTeams post-protocol
- [x] genWorkflow single-session contradiction fixed
- [x] Explain row with agreement probe
- [x] +5 tests (presence x3 formats, absence x2, fan-in gating, failure variants, contradiction pin, explain row); suite green; content-lint

## Update (final coherence read): the last seam

A fresh-eyes end-to-end read of four complete generated documents (~295k chars: feature preset in all three core formats + Incident RCA) verdicted everything executable and found ONE emission defect + one cosmetic: (1) getDepNodes counted gate failure back-edges as dependencies, so step-1 agents were told to await reviewers that run after them (the RCA Investigator awaited its own Verifier; the Implementer's Input named the Skeptic's verdict but never the Planner's plan). Fixed with the same isReviseBackEdge predicate topologicalSort uses (the two now agree by construction) PLUS review-loop resolution now also surfaces the reviewed work source alongside the critic. (2) genWorkflow emitted step hints after the Instructions line so they rendered as items inside the template's handoff list - hints now emit before Instructions in both sequential and parallel blocks. +2 tests. Everything else across the read came up clean: no contradictions, no stale pre-campaign ghosts, no ordering problems.

- [x] isReviseBackEdge exclusion in getDepNodes + reviewed-source resolution through review-loop gates
- [x] genWorkflow hints before Instructions (both blocks)
- [x] Regression tests (RCA investigator deps, planner deps, implementer sees Planner, hint ordering)

## Update (morning): revise-loop continuity per format

Owner question - "respawning on each verifier finding seems lossy, no?" - surfaced a per-format truth worth encoding. Workflow format: single session, nothing lost. Agent Teams: teammates PERSIST - the revise instruction said "re-assign," ambiguous enough to invite spawning a replacement; now explicit: "send the feedback back to the SAME teammate, who keeps their full working context; do not spawn a replacement." Sub-Agents: Task agents are one-shot by runtime - respawn is the mechanism - but the loss is mitigated by design: the surgical revise brief plus (when memory is on) the agent's own memory file; the revise line now points the re-spawned agent at its prior working state explicitly. One teams pin migrated to the sharper contract.

- [x] Teams: same-teammate continuity explicit
- [x] Sub-Agents: memory-recovery clause (memoryEnabled-gated)
- [x] Pin migration; suite green; content-lint
