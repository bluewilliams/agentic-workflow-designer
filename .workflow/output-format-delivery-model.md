# Output-format-driven delivery model

Work item: Blue - make delivery a clean function of the Output node format (no separate toggle). Status: PHASE 1 DONE + PHASE 2 DONE (both uncommitted; Blue commits). Tests: 721/721.

## Why and scope

Delivery (commit / push / PR / report / docs) should be driven purely by the Output node format, not a separate "Delivery" toggle. Code changes are produced by the agents regardless of the output node; the output node only chooses what to DO at the end + describes the deliverable.

## Key facts (verified)

- Code changes happen whether or not there is an output node. No output node -> noCommitBlock ("leave changes uncommitted for review"). The output node does NOT gate whether work happens; it only drives the delivery block.
- "Code Changes" format == no-output-node behavior (both -> noCommitBlock, leave uncommitted). So Code Changes is the explicit form of the safe default. KEEP IT - do NOT remove/rename (Blue reconsidered; his "we don't have code changes" premise was wrong).
- A single Report output handles "code AND report" (e.g. performance): the optimizer makes code changes (left uncommitted) AND a report is produced. No need for two output nodes.
- A workflow can have multiple output nodes (fan-out), but presets use one. deliveryBlock priority handles multi-output: pr > commit > report > docs > code.
- No preset uses format='pr' (verified). Presets must never default to Pull Request.

## PHASE 1 - DONE (uncommitted; Blue commits)

Removed the Delivery section + commitPr toggle; made delivery format-driven (pr vs not):
- Removed the Delivery sidebar `<div class="sidebar-section">` (Commit & open a PR checkbox) + all commitPr state wiring (state field, toggleCommitPr, serialize, restore, clearCanvas x2).
- Added `deliversPr()` (~index.html:5998, before prBlock): true if any output is format='pr'.
- The 5 generators now use `(deliversPr() ? prBlock(...) : noCommitBlock(...))` instead of `state.commitPr ? ...` (genWorkflow ~6107, genSubAgents ~6402, genAgentTeams ~6546, genAgentSDK ~6931 + 6934 heading, genClaudePrompt ~7050).
- Rewrote the Delivery test suite -> "Delivery is driven by the Output node format" (pr->prBlock, code/report/docs->noCommitBlock, toggle-gone assertion, deliversPr() unit). Removed `win.state.commitPr=false` from resetState. 704/704.
- TECHNICAL.md prBlock section updated (format-driven, no toggle, noCommitBlock for non-pr).

## PHASE 2 - DONE (uncommitted; Blue commits)

Built exactly per the plan below, plus the agreed "Code Changes" -> "Leave Uncommitted" rename (Blue's call, since Commit now sits next to it). Internal value stays 'code'. What shipped:
- Format dropdown (index.html ~3594): Leave Uncommitted (code) / Commit (commit) / Pull Request (pr) / Report (report) / Documentation (docs). Branch Name shows for pr AND commit; Target Branch for pr only.
- `deliveryBlock(level)` dispatcher + `deliveryFormats()` + `deliveryTitle()` helpers near prBlock (~index.html:5988). Priority pr > commit > report > docs > code. Replaced the `deliversPr() ? ...` ternary at all 5 generator sites (genWorkflow `deliveryBlock('###')`; genSubAgents/Teams/Claude `deliveryBlock('##')`; SDK uses deliveryBlock('###') + deliveryTitle().toUpperCase() banner).
- New blocks after noCommitBlock: `commitBlock` (feature branch, commit + push, "Do NOT open a pull request"), `reportBlock` (write a Markdown report; leave code uncommitted; never commit - not code, not the report), `docsBlock` (follow project doc conventions; leave code uncommitted; never commit). deliversPr() kept (tests + dispatcher reference).
- Tests: rewrote the delivery suite to a 5 generators x 5 formats matrix (must/mustNot substrings) + dispatch-priority unit + no-output fallback + commitBlock unit + deliversPr unit. 721/721.
- Docs: TECHNICAL.md "Delivery (deliveryBlock())" table + security-table rows + file-tree line; README Output section rewritten (5 formats, no-output behavior, no preset uses PR).
- Verified by a real headless render of commit/report/docs blocks - prose clean, correct, hyphens only.
- POLISH (same turn): enriched reportBlock (lead with bottom-line/BLUF + ground claims in specifics: file:line, commands, numbers + flag open questions + concise) and docsBlock (update the relevant existing doc in place rather than adding a new file + show-don't-tell examples + concise). Behavior unchanged; richer guidance only.
- ADVERSARIAL REVIEW (independent agent): clean on all functional categories (every generator uses deliveryBlock; dispatch priority correct; UI/branch-gating right; commit serializes via type-only validation; no commitPr leftovers; no em dashes; no preset uses pr; performance=report; no prose contradictions). One real catch fixed: the report/docs test assertions used bare substrings ('written report'/'documentation') that could pass for the wrong reason -> tightened to unique markers 'Deliverable: a written report' / 'Deliverable: documentation'. Optional/deferred: deliversPr() now has no production callers (only pinned by a test) - left in as a sensible predicate; Blue can prune later.

### Original PHASE 2 plan (for reference)

Generalize delivery into a format dispatcher + add Commit, and make Report/Docs produce real artifacts.

Output Format options + behavior:
1. **Code Changes** (value 'code', default) -> noCommitBlock: produce code, leave uncommitted for review. Same as no output node. KEEP AS-IS.
2. **Commit** (value 'commit', NEW) -> commitBlock (NEW): feature branch, commit + push, NO PR. Branch Name field.
3. **Pull Request** (value 'pr') -> prBlock: feature branch, commit + push, open PR. Branch Name + Target Branch fields.
4. **Report** (value 'report') -> reportBlock (NEW): produce an actual written report (findings / observations / benchmarks, as a markdown doc or inline); leave ANY code changes uncommitted; NEVER commit/push/PR.
5. **Documentation** (value 'docs') -> docsBlock (NEW): produce actual documentation following the project's doc conventions; leave ANY code changes uncommitted; NEVER commit/push/PR.

Performance preset STAYS format='report' (Blue's call) - now produces a real performance report + leaves the optimized code uncommitted.

Implementation steps:
- Add `deliveryBlock(heading)` dispatcher: scan output formats; pr->prBlock, commit->commitBlock, report->reportBlock, docs->docsBlock, else->noCommitBlock. Replace the `deliversPr() ? prBlock : noCommitBlock` ternary at the 5 generator sites with `deliveryBlock(...)`. (deliversPr can stay or be inlined.)
- Add commitBlock (prBlock minus the PR-creation steps: branch, commit, push, stop). reportBlock + docsBlock (produce-the-artifact + leave-code-uncommitted + never-commit).
- Output config UI (~index.html:3607): add 'commit' to the format configSelect options -> code / commit / pr / report / docs. Branch fields (~3609): show Branch Name for pr AND commit; Target Branch for pr only.
- NODE_DEFAULTS.output.config.format stays 'code'.
- Tests: extend the delivery suite for all 5 formats x 5 generators + commitBlock/reportBlock/docsBlock assertions; output-format dropdown options test (now includes Commit).
- Docs: README Format list (add Commit; note Report/Docs produce artifacts + never commit) + TECHNICAL delivery model.
- Re-audit presets (no pr; report/docs/code correct). Performance stays report.

## Current state / next action

Phase 1 + Phase 2 both DONE + uncommitted + 721 green. The delivery model is complete: format-driven, 5 formats, Commit added, Report/Docs produce real artifacts and never commit, "Leave Uncommitted" rename applied (value still 'code'), no preset uses pr, performance stays report. Next action: Blue commits the working-tree changes (index.html, tests.html, README.md, TECHNICAL.md, this record). No further implementation pending.

## Built with (provenance)

Workflow: direct implementation by the orchestrator across a multi-turn design conversation. Part of the delivery / output-node capability. Triggered by Blue noticing the Output "Pull Request" format overlapped with the (now-removed) Delivery toggle.

## Links

Branch: TBD. PR: TBD.
