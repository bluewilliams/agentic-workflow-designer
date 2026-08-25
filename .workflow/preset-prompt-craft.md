# Preset prompt craft: composability audit of the 42 agent templates

Context: no work item (director-requested audit + tuning). Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- All 42 preset prompt templates were audited against four craft criteria: verdict/gate discipline, handoff contract, evidence discipline, and proportionality. Every template ends with a structured Handoff Summary (100 percent compliance, pre-existing). 27 of 42 needed no change.
- Gate-feeding specialized reviewers now carry the materiality bar the base `reviewer` template models: `fullstackReviewer` and `testReviewer` open with "The materiality bar" (default verdict PASS; only Critical or High findings make NEEDS REVISION; depth scales to the diff), and `uiReviewer` states the same gating inline. Without a stated bar, a Medium finding could burn a full three-cycle revise loop.
- Test agents carry the honesty clause: `e2eTester` (never fake, stub, or hardcode a result; failing output is the evidence) and `bugTester` (never fake, stub, or weaken). `tester` already had it.
- Builder specialists carry the minimality sentence `implementer` already had: `backend` and `frontend` say no drive-by refactors, out-of-scope improvements go in the handoff. `devopsEngineer` gains the non-destructive verification rule (dry-runs and plan output only; never apply, deploy, destroy, or mutate shared environments).
- Composability fallbacks: `uiImplementer` works without a Design System Brief (derives conventions from the codebase and declares the inference) because users can delete the analyzer node; `integrator` names the architectural design as the tiebreaker when parallel streams disagree and reports the conflict instead of silently rewriting a stream.
- All four swarm auditors scope to the input (`securityAuditor`, `qualityAnalyst`, `perfProfiler`, `archReviewer`): a PR gets the change and its blast radius; a whole codebase gets hotspots/threat-model/hot-paths/load-bearing-seams first, with an honest covered-and-not-covered disclosure in every handoff. `reportBuilder` preserves upstream severities, evidence, and attribution (aggregate, never soften) and names reviewer disagreements.
- `investigator` proportionality: a shallow cause proven by direct evidence skips the two-hypothesis ceremony, which is for genuinely uncertain causes.
- `uiAppExplorer` branch sync matches the safe App Under Test sidebar form: `pull --ff-only`, and a dirty or non-fast-forward tree means proceed with current state and say so (never force).
- Comment discipline (director default: only a non-obvious why, a real gotcha, or public API docs): builders inherit it from the always-emitted `conventionsHint()`; the base `reviewer` enforces it; `fullstackReviewer`, `uiReviewer`, and `changeScopedReviewer` now carry a matching flag-narrating-comments dimension (in changeScopedReviewer, usually Nit; a misleading comment is Important).
- Lane discipline is preserved by design: every addition keeps reviewers reading and auditing, testers and verifiers executing, and the Skeptic refuting. The materiality bars REDUCE reviewer intensity, so the Reviewer does not drift toward the Skeptic or Verifier lanes.
- Deliberately NOT changed: `stepDefWriter` stack examples (already framed with "e.g." and "such as"), `designSystemAnalyzer` length (no free cuts), and no reviewer invokes any runner-specific review skill (prompts stay provider-neutral; the noisier external materiality bar stays out).

## Why and scope

The director asked whether the preset reviewer looked thin and which agents could use tuning, with a premium on frictionless composable agents that do not eat wall clock without ROI. A subagent audit produced a fact matrix over all 42 templates; the additions are roughly 20 sentences across 17 prompts, each one either saving a revise cycle (materiality bars, fast paths), preventing a fake pass (honesty clauses), removing a composability trap (Brief fallback, stream tiebreaker), or bounding unbounded scope (swarm auditors). Prompts are static templates: presets pick changes up at apply time; saved workflows keep their baked prompt text by design (no silent mutation).

## Verify

- `./run-tests.sh` (1618 -> 1627; new "Preset prompt craft batch" suite pins one discriminating token per added beat plus an em/en-dash sweep of every touched template; the frozen `uiAppExplorer` byte-pin migrated deliberately to the safe branch clause)

## History

- 2026-08-24: created - audit matrix (subagent, 4 criteria x 42 templates), 17 templates tuned per the director-approved ranked list, comment-discipline dimension added on a director follow-up, lane-discipline constraint honored throughout (by direct session)
- 2026-08-24: review fixes - swarm scoping extended to all four auditors (perfProfiler and archReviewer had kept whole-codebase framing beside their scoped siblings) with a uniform covered-and-not-covered disclosure; devopsEngineer step 7 references step 4 instead of restating its tools with drifted examples; dash sweep widened from 15 hardcoded keys to every PROMPTS key; frozen uiAppExplorer pin retitled to match its migrated content; a duplicate base-reviewer assertion dropped; misplaced Suite 13 banner relocated to its suite. Suite steady at 1627 (by direct session)
