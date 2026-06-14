# Per-step Requirements: resolved-spec pointer for URL input (not a bare URL)

Context: no work item (plain-text spec). Branch: main. Status: DONE (grading run - uncommitted). Repo: agentic-workflow-designer.

## Why and scope
When the requirements input is a ticket URL, the generated per-step "## Requirements" section emits the raw `getStory()` - a bare URL - which invites every step to re-fetch the ticket, contradicting the ticket-fetch protocol (orchestrator resolves once; steps work from the distilled spec). Surfaced as finding #1 from the  grading run. Fix: for URL-only input, the per-step Requirements POINTS each step at the orchestrator-resolved spec (their brief / the durable record) and keeps the source URL only as a labeled reference; for plain-text input, emit the text unchanged.

Non-goals: do NOT remove the URL from the input node or the ticket-fetch block (the orchestrator still needs it to resolve once); do NOT touch Datadog/Atlassian-ticket-fetch/code-search/memory/repo-context/Delivery/finalize/conventions work; index.html + tests.html only; no commit.

## Requirements
- R1 When the story input is URL-only (a ticket URL with no real prose), each generator's per-step "## Requirements" MUST emit a resolved-spec pointer (work from the orchestrator's resolved spec / brief / durable record; do not re-fetch) plus the source URL as a labeled reference - NOT a bare URL.
- R2 When the story input is plain text (the spec itself, with or without an embedded URL), the per-step "## Requirements" MUST emit the text unchanged (today's behavior) - regression guard.
- R3 The URL MUST still reach the orchestrator (the input node + atlassianTicketFetchHint are untouched), so the resolve-once flow is preserved.
- R4 The per-step pointer MUST be consistent with atlassianTicketFetchHint (reinforce, not contradict).
- R5 Tests: per affected generator, URL-only story -> pointer + URL-reference present, bare-URL absent; text story -> text present unchanged.
- R6 No-regression: index.html + tests.html only; suite green (baseline ~601); hyphens not em dashes; no company-specific names.

## Success criteria
- A URL-only workflow's per-step Requirements reads "work from the resolved spec, here is the URL for reference" - no step is handed a bare URL to re-fetch.
- A text workflow is byte-unchanged in its per-step Requirements.
- `./run-tests.sh` passes at >= 601, all green.

## Spec quality check
- [x] Each requirement is testable and unambiguous
- [x] Scope is bounded (Non-goals stated)
- [x] No open clarifications remain (both decisions resolved + approved at the human checkpoint)
- [x] Every scenario names a verifying test (URL-only -> pointer; text -> unchanged; prose+URL -> unchanged; per generator)
- [x] Success criteria are measurable

## Approach and decisions (RESOLVED + approved at the human checkpoint)
- DECISION 1 (when the pointer fires): `isUrlOnly(story)`. Bare ticket URL -> pointer; prose (even with an embedded URL) -> text unchanged (the prose is the spec); bare Jira key (no URL) -> text unchanged (nothing to re-fetch, blocked upstream anyway). Rejected firing on any-URL-present, which would wrongly rewrite prose-with-URL specs.
- DECISION 2 (wording): the pointer mirrors `atlassianTicketFetchHint` (resolve-once / do-not-re-fetch / reference-only) so they reinforce. Source URL rendered as a labeled reference; falls back to `story` when `extractAtlassianUrls` finds no Atlassian URL (non-Atlassian URL-only input).
- DECISION 3 (scope): applied to the four MULTI-STEP generators (genWorkflow, genSubAgents, genAgentTeams, genClaudePrompt); Refine/Plan single-agent prompts LEFT AS-IS (no spawned steps to protect; they already carry tested URL-only handling). The pointer's purpose (stop N steps re-fetching) does not apply when N=1.
- DECISION 4 (shape): extracted a DRY `requirementsBlock(story, heading)` helper (one place, four one-line call sites) rather than inline the branch - the Planner explicitly cited the new Conventions directive. Net `index.html` change was a REDUCTION in duplication.
- Grounding: reinforces `.workflow/atlassian-mcp-fortification.md` (the orchestrator-side ticket-fetch); related, NOT a supersession (that record owns the resolve-once block; this adds the complementary per-step rendering).

## Surface area (file -> role) - PROVISIONAL until the Planner grounds
- index.html - the per-step "## Requirements" emission sites in the agent generators (the bare `if (story){ push('## Requirements'); push(story); }` pattern; ~4-5 sites). Check the Refine/Plan single-agent prompts separately (no "steps" - may stay as-is or use the same pointer).
- index.html - reuse `isUrlOnly` / `extractAtlassianUrls` / `getWorkflowAtlassianUrls` for detection; do NOT reinvent.
- tests.html - URL-only vs text per-generator tests.
- Out of scope: the input node, atlassianTicketFetchHint, all other subsystems.

## Task checklist
- [x] Planner: pinned the 4 multi-step sites (genWorkflow `###`, the other three `##`) + correctly scoped OUT Refine/Plan; resolved DECISION 1 (isUrlOnly) + DECISION 2 (wording) + recommended the DRY helper; PAUSED for the human checkpoint (approved).
- [x] Implementer: added `requirementsBlock(story, heading)` + routed all 4 sites through it; added 12 tests; 601 -> 613 green. Refine/Plan untouched.
- [x] Reviewer: PASS - folded in by the orchestrator (read-only step). Verified URL-only -> pointer, prose+URL -> text (isUrlOnly false), the non-Atlassian-URL fallback, consistency with atlassianTicketFetchHint, Refine/Plan untouched, the helper is comment-free/self-describing, minimality.
- [x] Tester: closed as orchestrator verification (Implementer authored the 12 tests, Reviewer ran them; final ./run-tests.sh confirmed 613 + the marker/sites/Refine-Plan-intact).
- [x] Orchestrator: FINALIZED via the explicit FINALIZE step - folded the Reviewer in, ticked spec-quality, wrote the Outcome, updated `.workflow/_index.md`, stripped the scaffolding.

## Verify
- `./run-tests.sh` -> 601 before, **613 after** (+12 tests), all passing. `requirementsBlock` defined once + routed at all 4 multi-step generators; marker `Work from the resolved spec in your brief` present (helper only); the two Refine/Plan `## Atlassian Context` blocks untouched. `git diff --stat`: index.html +14/-18 (a net reduction - the helper removed duplication), tests.html +37 - the two files only.

## Outcome
Replaced the bare-`push(story)` per-step "## Requirements" emission with a `requirementsBlock(story, heading)` helper at the four multi-step generators (genWorkflow `###`, genSubAgents/genAgentTeams/genClaudePrompt `##`). For URL-only input (`isUrlOnly`), the per-step Requirements now points each step at the orchestrator-resolved spec ("Work from the resolved spec in your brief... do not re-fetch the ticket. Source ticket (reference only...): {url}"), with the URL kept as a labeled reference (falling back to the raw story for a non-Atlassian URL). For plain text (incl. prose that embeds a URL), the text is emitted unchanged. This closes finding #1 from the  grading run - steps are no longer handed a bare URL that invites re-fetching, reinforcing the resolve-once ticket-fetch protocol. The input node + atlassianTicketFetchHint are untouched, so the URL still reaches the orchestrator. Refine/Plan single-agent prompts left as-is (no spawned steps). Surface area: index.html (the helper + four routed sites) and tests.html (+12 tests). Reinforces `atlassian-mcp-fortification` (no supersession). GRADING RUN: not committed.

## Built with (provenance)
Workflow: `Requirements should not be a bare uri` (Feature preset, generated by the agentic-workflow-designer; Planner -> Implementer -> Reviewer -> Tester, orchestrated as a GRADING run with a Planner checkpoint). Grounded by `.workflow/_index.md` (matched atlassian-mcp-fortification).

## Links
- Work item: none. Branch: main. PR: none (grading run, not committed). Related: `.workflow/atlassian-mcp-fortification.md` (the ticket-fetch capability this reinforces).
