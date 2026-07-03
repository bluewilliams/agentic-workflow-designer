# Prompt overhaul wave A: mechanical bugs from the deep review

Branch: main. Status: current.

```awd:record
{"slug": "prompt-overhaul-wave-a", "status": "current", "date": "2026-07-03", "files": ["index.html", "tests.html"], "verify": ["./run-tests.sh", "git grep -c 'builderNodes' index.html"], "superseded_by": null}
```

## Current behavior

The auto-builder's review gate always re-runs the BUILDERS on Revise (captured before the security step consumes lastNodes). All code-shipping presets gate their reviewer verdicts: review (Validation passed? -> Improver), fullstack (Review passed? -> Backend+Frontend), ui_component (UI review passed? -> UI Implementer). Both critics carry honest-verdict convergence: never PASS/VERIFIED with material findings regardless of cycle, delta-scoped re-review, and every generator's revise instruction tells the orchestrator to pass the cycle index to the reviewer. Investigator/fixer handoffs address "whoever implements the fix" and "the workflow's testing step" instead of phantom teammates. The analysis chain finishes with the business writer. Auto research r1 is mode-aware at preset parity. Preset planners/architects are web-lean per the defaults ruling (testPlanner keeps WebSearch deliberately - device/platform coverage genuinely benefits). PROMPTS.general's codebase steps are conditional ("where the task touches a codebase"). writerUserguide can read what it finds (WebFetch + conditional web step). Formatting nodes (Synthesizer/Advisor/Report Builder x4 sites) are writer-typed, not planner-typed.

## Why and scope

The three-fork deep prompt review found mechanical defects beneath the prompt-philosophy findings: a miswired revise loop (reviews-without-fixes), three dead-end verdicts, a Skeptic convergence paragraph that corrupted its own verdict (PASS-despite-blockers, keyed to a cycle index nothing communicated), phantom-role handoffs, and a cluster of pairing/copy drift. Wave A fixes the mechanics; waves B/C carry the philosophy sweep.

## Key decisions

- Convergence honesty: the critic's verdict NEVER lies - the orchestrator owns proceed-after-cap (it already says so at every gate site); documented blockers become the record of what was accepted. Delta-scoped re-review ("judge only whether previously raised blockers are fixed... do not re-litigate") is what makes loops converge. Generators now instruct passing "cycle X of the max" to reviewers; Claude.ai single-conversation format self-notes the cycle. Verifier aligned (never VERIFIED while unmet; re-verify checks failed criteria + what fixes could have disturbed). Old pins asserting PASS-after-cap wording were rewritten to pin the new contract.
- fullstack's Revise re-runs BOTH fork siblings (Backend + Frontend) - multi-target revise edges are the auto-builder's established pattern; the reviewer's feedback tells each what applies.
- testPlanner keeps WebSearch: planning device/platform coverage is a genuinely web-informed task (judged per template; the other 10 planner/architect grants removed, including the auto-builder's).
- Formatting nodes retyped writer/technical: only agentType-driven behavior changes (hints, Skeptic lens, OpenSpec role group -> docs); their explicit prompts are untouched.

## Changes

- index.html: builderNodes capture + revise retarget; 3 preset gates (+positions); both Convergence paragraphs; 8 cycle-clause emission sites (4 prose formats + claude + OpenSpec gate note); investigator/fixer handoff phrasing; analysis finisher; r1 parity; 11 WebSearch removals; PROMPTS.general conditional; WRITER_TOOL_DEFAULTS.userguide + template step; 4 formatter retypes.
- tests.html: security-revise targeting (2), preset gates (3), cycle-index emission (1), convergence pins rewritten to the new contract (3 assertions), stale test title renamed.

## Verification

- 1316 -> 1322 (+6), full suite green after every item. Content-lint grep clean.

## Task checklist

- [x] Security revise miswire (builderNodes captured pre-reassignment; both paths tested)
- [x] Dead-end gates: review / fullstack / ui_component (idiom-consistent labels, maxRevisions 3, calibration + zero-warnings tests still green)
- [x] Skeptic + Verifier convergence rewrite (honest verdicts, delta scope) + cycle-index clause at all revise emission sites
- [x] Phantom-role handoff phrasing (field names stable)
- [x] Analysis finisher writerBusiness; auto r1 parity (+ record overclaim corrected)
- [x] WebSearch contradiction resolved (11 removed; testPlanner kept, reasoned)
- [x] PROMPTS.general codebase-conditional (fallback-composition invariant intact)
- [x] writerUserguide WebFetch (defaults + conditional template step)
- [x] Formatter nodes writer-typed (4 sites)
