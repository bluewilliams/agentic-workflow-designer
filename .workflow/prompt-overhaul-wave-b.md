# Prompt overhaul wave B: the philosophy sweep (role expertise over tool coaching)

Branch: main. Status: current.

```awd:record
{"slug": "prompt-overhaul-wave-b", "status": "current", "date": "2026-07-03", "files": ["index.html", "tests.html"], "verify": ["./run-tests.sh", "grep -c 'Decompose by risk' index.html"], "superseded_by": null}
```

## Current behavior

The six core reasoning templates teach their roles' craft, not tool mechanics. Planner: decompose-by-risk, resume-unit steps, decisions-vs-assumptions, out-of-scope boundary, test-strategy-with-the-plan, stop condition (handoff adds Sequence/Assumptions/Out of Scope). Researcher: breadth-then-depth, verified-vs-inferred labels, triangulation, negative-findings-are-findings, per-recommendation confidence, stop-when-the-question-belongs-to-the-implementer (handoff adds Negative Findings). Architect: options-considered-and-why-losers-lost, simplest-design guard, boundary contracts for whatever the system has, failure/scale/race design, live-rollout sequencing (handoff adds Options Considered). Investigator: anti-anchoring (two hypotheses, hunt disconfirming evidence, correlation-vs-causation on git suspects) around the kept repro-test step (handoff adds Hypotheses Eliminated). Reviewer: materiality bar (default PASS, only material defects block, evidence rule on Critical/High), risk-based depth, review-the-tests-as-hard-as-the-code. Tester: good-test bar (behavior not implementation, delete-if-nothing-would-fail-it, boundaries first-class) around the kept conventions-by-recency step. The strong templates (implementer, frontend, backend, fixer, writers) kept their structure with tool tutorials compressed into craft-first parentheticals. Tool defaults re-derived: researcher +Bash (its recency-as-convention method reads git history); all other sets verified against the rewritten templates.

## Why and scope

The owner's organizing insight, validated by the three-fork deep review: templates spent their budget teaching tool mechanics ("use Glob... use LSP workspaceSymbol...") that the generators' injected layers already teach (suggestion line + clause + code-search hint), while the actual craft of each role - what a great planner/researcher/architect DOES - was largely absent. House style to converge on: the critic prompts (adversary/verifier, ~95:5 expertise-to-coaching).

## Key decisions

- Six deep rewrites (planner, researcher, architect, investigator, reviewer, tester) following the review's planner example; five invariants protected throughout: handoff field names stable (new fields additive only), the "End your response with:" block kept (OpenSpec parser contract), conditional-availability phrasing for web tools kept and test-pinned (researcher/investigator name WebSearch/WebFetch inside the conditional), PROMPTS.general untouched (fallback composition), no /datadog/i in investigator.
- Compression pass, not restructuring, for the strong set: implementer 4 LSP steps -> 1 craft step; backend 4 -> 1; frontend 3 -> 1; fixer 3 -> 2; writerTechnical 5 -> 2; writerApi 6 -> 2; all renumbered sequentially. Voices and safety rails preserved verbatim (implementer SAFETY block, tester conventions-by-recency, fixer repro-test discipline).
- **Size, honestly**: expertise costs tokens. The six rewrites grew (+4,279 chars total; planner +1,349, reviewer +800, architect +862) while compressions trimmed the rest (-424). Composed 4-agent everything-on workflow: 70,389 -> 72,893 chars (+3.6%); mid-chain implementer block 8,005 -> 7,928 (-1%). The review's "~10% lighter" projection assumed compression-only; the owner's ask was expertise-first. The RATIO target is met: zero pure tool-tutorial steps remain in the core set - every surviving tool reference carries role judgment.
- Tool defaults under suggestion semantics: researcher +Bash (git-recency methodology); planner/architect/reviewer stay lean deliberately (read-and-reason roles; the suggestion clause makes lean costless); builders/tester/debugger/writers verified covering every instructed capability.
- Test pins updated deliberately, never weakened: fallback pin -> 'execute without re-planning'; C6 additive-guard -> pins 'Decompose by risk' + 'findReferences on a shared type' in both toggle states; researcher conditional-web pin satisfied by naming the tools inside the conditional step.

## Changes

- index.html: PROMPTS planner/researcher/architect/investigator/reviewer/tester rewritten; implementer/backend/frontend/fixer/writerTechnical/writerApi compressed + renumbered; AGENT_TYPE_TOOL_DEFAULTS.researcher +Bash.
- tests.html: 3 pins updated (fallback opening, C6 x2 states, none weakened).

## Verification

- 1322/1322 after every template (six template gates + compression gate + defaults gate). Content-lint grep exit 1. Before/after composition measured headlessly (temporary measure.html, deleted).

## Task checklist

- [x] planner rewrite (risk decomposition, resume units, assumptions, scope, stop condition; +3 handoff fields)
- [x] researcher rewrite (methodology; verified-vs-inferred; negative findings; confidence; stop)
- [x] architect rewrite (options-and-losers; simplest guard; boundary contracts; failure/scale; rollout)
- [x] investigator rewrite (anti-anchoring; mechanism-not-vicinity; correlation-vs-causation; repro step kept)
- [x] reviewer rewrite (materiality bar; evidence rule; risk depth; tests-as-hard-as-code; rubric kept)
- [x] tester rewrite (good-test bar; conventions-by-recency kept verbatim)
- [x] Compression pass x6 templates, renumbered
- [x] Tool defaults re-derived (researcher +Bash; rest verified)
- [x] Composition before/after measured; suite green per gate; content-lint

## Update (same day): recency + reuse become builder/reviewer defaults

Owner ruling: agents do not reliably weight conventions by recency on their own (they weight by abundance - backwards in a mid-migration codebase), and reuse-over-reinvention should be a default, not a hope. The tester's conventions-by-recency paragraph was the model. Implementer step 4 upgraded: follow where the codebase is GOING (git-log the files nearest the change, mirror the newest deliberate pattern) + reuse before you invent (search for the concept before building it - duplicating an existing capability is a defect, not a style choice). Frontend/backend gained a compact line of the same discipline. Reviewer's Conventions bullet became Conventions & reuse: judge against the CURRENT direction, never bless the old majority pattern by abundance, and flag reinvention as material when reuse was reasonable. One test pin migrated to the new contract + four new pins.

Also judged on owner ask: scope-creep and comment-discipline coverage CONFIRMED at three independent layers each - scope (implementer simplest-solution opener; Skeptic stay-in-scope + scope over-reach as a MATERIAL defect; reviewer Scope-and-minimality bullet) and comments (always-emitted Conventions block's self-describing-code discipline reaching every agent; reviewer comment-the-why + narrating-comment flags; fixer comment restraint). No change needed.

- [x] Implementer recency+reuse step; frontend/backend lines; reviewer Conventions & reuse bullet
- [x] Pin migration + 4 new pins; suite green; content-lint
