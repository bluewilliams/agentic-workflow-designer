# Conventions directive (comment discipline + test-convention nudge) + reviewer enforcement line

Context: no work item (plain-text spec). Branch: main. Status: DONE (grading run - uncommitted). Repo: agentic-workflow-designer.

## Why and scope
Agents tend to over-comment. Bake a soft, orchestrator-level "Conventions" directive into every generated workflow so coding/testing steps prefer self-describing code over comments and match the project's existing test conventions, plus one reviewer line that enforces it. This is a Constitution/Directives default; a repo's own rules/CLAUDE.md override it. Surfaced from the design discussion after the  + Delivery/finalize runs.

Non-goals: do NOT touch the Datadog, Atlassian, code-search, memory, repo-context, Delivery, or finalize work; index.html + tests.html only; no toggle (always-on, self-scoping); do NOT add a reviewer convention-deviation line (the reviewer already evaluates "Conventions: Follows project patterns and style").

## Requirements
- R1 A new `conventionsHint()` (next to `codeSearchHint`) MUST return the Conventions block, emitted at the SAME top-level standing-guidance sites where `codeSearchHint()` is injected: the four prose generators (genWorkflow, genSubAgents, genAgentTeams, genClaudePrompt) as a `> **...**` block, and the Agent SDK exporter as a `#`-comment block. ALWAYS emitted (no toggle/gating); self-scopes by wording (harmless no-op on a no-code workflow).
- R2 The block text MUST be: prefer self-describing code over comments in tests as much as production; comment only for genuinely complex logic / a non-obvious why / where the project's conventions call for it, never to restate what well-named code says; public/exported APIs may carry JSDoc/docstrings; when writing tests, first read the project's existing/recent tests and follow their conventions (framework, unit/integration split, naming, fixtures, comment style); the repo's rules/CLAUDE.md define these and take precedence. Hyphens not em dashes; no company-specific names.
- R3 `PROMPTS.reviewer` MUST gain ONE concise evaluation line: "Flag narrating or redundant comments - comment the why, not the what." No convention-deviation line (already covered).
- R4 Tests: the Conventions block (unique marker, e.g. "in tests as much as in production code") appears in each of the four prose generators' output AND the SDK output; present regardless of toggle state (always-on); the reviewer template contains the comment-flag line; a non-code/research workflow still generates fine.
- R5 No-regression: index.html + tests.html only; the full suite stays green (baseline ~592); Datadog/Atlassian/code-search/memory/repo-context/Delivery/finalize untouched.

## Success criteria
- Every generated workflow (all five export formats) carries the Conventions directive, so coding/testing agents get the comment discipline + test-convention nudge by default.
- The reviewer enforces it (flags narrating/redundant comments).
- `./run-tests.sh` passes at >= 592, all green.

## Spec quality check
- [x] Each requirement is testable and unambiguous
- [x] Scope is bounded (Non-goals stated)
- [x] No open clarifications remain
- [x] Every scenario names a verifying test (block-in-5-generators + always-on-both-toggle-states + reviewer-line + no-regression-on-existing-Conventions-line)
- [x] Success criteria are measurable

## Approach and decisions
- Mirror the `codeSearchHint` standing-block pattern: a new `conventionsHint()` emitted at the same five sites. Chosen over per-role-template lines because one source of truth flows to every agent (incl. custom prompts) and the soft framing reads naturally once; it matches the orchestrator-flows-down architecture.
- Always-on, no toggle: it is a baseline good-practice default that self-scopes by wording, and the repo's Rules/CLAUDE.md (rulesPathsHint feature) is the real override - a toggle would be redundant.
- Reviewer gets the comment-flag line only (genuinely new); NOT a convention-deviation line (the reviewer already checks "Conventions: Follows project patterns and style").
- New `code-conventions` capability; additive, no supersession.

## Surface area (file -> role) - PROVISIONAL until the Planner grounds
- index.html `conventionsHint()` - new, next to `codeSearchHint`.
- index.html - the five `codeSearchHint` emission sites (4 prose generators + SDK) get a parallel `conventionsHint` emission.
- index.html `PROMPTS.reviewer` (~1246) - one new evaluation line.
- tests.html - block-in-5-generators + reviewer-line + harmless-on-no-code tests.
- Out of scope: all other subsystems.

## Task checklist
- [x] Planner: confirmed the 5 codeSearchHint emission sites; caught two subtleties (the SDK block must be UNCONDITIONAL not inside the mcpCodeSearch guard; the marker "in tests as much as in production code" wraps across SDK comment lines, so use "self-describing code over comments" as the cross-format marker); verified no exact-output test would shift (always-on safe).
- [x] Implementer: added conventionsHint + 4 prose emissions + the unconditional SDK block + the reviewer line; added 9 tests; 592 -> 601 green. Self-corrected the apostrophe escaping (`\'` not `\\'`) to match the codebase.
- [x] Reviewer: PASS - folded in by the orchestrator (read-only step). Verified all 5 sites, the SDK block is unconditional, always-on independence (both toggle states), the single reviewer line + the untouched existing Conventions line, minimality.
- [x] Tester: closed as orchestrator verification (Implementer authored the tests, Reviewer ran them; my final ./run-tests.sh confirmed 601 + the markers).
- [x] Orchestrator: FINALIZED via the explicit FINALIZE step - folded the Reviewer's verdict in, ticked spec-quality, wrote the Outcome, updated `.workflow/_index.md`, stripped the scaffolding.

## Verify
- `./run-tests.sh` -> 592 before, **601 after** (+9 tests), all passing. `conventionsHint` defined once; emitted at the 4 prose generators (`_..Co = conventionsHint()`) + the SDK as an unconditional `#`-comment block; cross-format marker `self-describing code over comments` present; the reviewer line `comment the why, not the what` present. `git diff --stat`: index.html +23/-1, tests.html +50 - the two files only.

## Outcome
Added a soft, always-on `conventionsHint()` standing block emitted at all five generator sites (the four prose generators next to `codeSearchHint`, plus an unconditional `#`-comment block in the SDK exporter). The directive tells coding and testing steps to prefer self-describing code over comments (in tests as much as production), to comment only for genuinely complex logic / a non-obvious why / where the project's conventions call for it, to use JSDoc/docstrings for public APIs, and - when writing tests - to first read the project's existing tests and match their conventions; the repo's own rules/CLAUDE.md take precedence. It is a Constitution/Directives default with no toggle (self-scoping by wording, overridable by the repo). Plus one `PROMPTS.reviewer` line ("Flag narrating or redundant comments - comment the why, not the what") to enforce it, sitting next to the existing "Conventions: Follows project patterns and style" criterion (no convention-deviation line, which would have been redundant). Surface area: index.html (`conventionsHint` + four prose emissions + the SDK block + the reviewer line) and tests.html (+9 tests). New `code-conventions` capability; additive, no supersession. GRADING RUN: not committed.

## Built with (provenance)
Workflow: `Orchestrator directives for code comments and project consistency` (Feature preset, generated by the agentic-workflow-designer; Planner -> Implementer -> Reviewer -> Tester, orchestrated as a GRADING run). Grounded by `.workflow/_index.md`.

## Links
- Work item: none. Branch: main. PR: none (grading run, not committed).
