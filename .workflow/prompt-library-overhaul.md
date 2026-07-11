# Prompt Library quality campaign (75 entries reviewed)

Workflow: prompt-library-overhaul. Branch: main. Status: finalized, committable.

```awd:record
{"slug": "prompt-library-overhaul", "status": "current", "date": "2026-07-10", "files": ["index.html", "tests.html"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

All 75 PROMPT_LIBRARY entries meet the library quality bar: standalone copy-paste prompts (no workflow scaffolding), expertise-first with availability-safe tool mentions (web-dependent research names its no-web fallback), honest-verdict contracts on review/audit prompts, structured output contracts, and negative-findings coverage on every audit-shaped prompt (what was checked and found clean is reported as signal, never omitted). Live Monitors all carry usage interval, exit condition, first-iteration baseline, and delta-only reporting. Five structural tests guard the bar: library-wide em/en-dash-free across every text surface, non-empty descriptions, the negative-findings contract on the security trio + Bug Hunter, availability-safe pins on the dependency prompts, and fictional PROJ-style example keys.

## Why and scope

The library predates the prompt-overhaul campaign (waves A-C) that raised the agent templates to expertise-first quality; the director asked for the same review so library users get the best possible results. Non-goals: no redesign, no deletions, no title or category changes (favorites are keyed category + title and must not orphan).

## Requirements

1. Every entry MUST be a standalone prompt with no workflow scaffolding. (Verified by review: zero memory-protocol, orchestrator, or handoff leakage found; the one designer-jargon clause in Converge to a Metric generalized to plain work-log phrasing.)
2. Tool mentions MUST be availability-safe and never restrictive. (Tests: capability claims are availability-safe: web-dependent research names its fallback; PR Review Watcher gained the adapt-the-queries clause by review.)
3. Audit-shaped prompts MUST report negative findings. (Test: audit prompts demand negative findings, not just problems (clean coverage is signal).)
4. House rules MUST hold across every text surface. (Tests: every entry is em- and en-dash free...; every entry carries a non-empty description; example project keys in inputs stay fictional (PROJ-style).)
5. Existing pins MUST survive untouched - titles, categories, Loops safeguards, input plumbing. (Verified: zero migrations; 1521 pre-existing tests passed unchanged after every batch.)

## Grade distribution (the review artifact)

- Strong as-is: 62 of 75. Standouts held to as models: the three Loops prompts (anti-reward-hacking safeguards), Release Regression Finder (per-version rate normalization, pre-existing-error discipline), all eight Live Monitors (baseline/delta/exit semantics), the Meeting & Status Prep trio (deep, gated, honest about their vault dependency).
- Targeted fixes: 13 entries, 14 edits. By theme: negative-findings additions (Bug Hunter verdict line, Error Handling Audit, Memory Leak Detective, OWASP coverage summary, Auth Deep Dive, Secrets Scan, API Contract Review, Data Quality Audit); availability-safe capability claims (Dependency Risk maintenance checks, Dependency Update changelog research, OWASP A06 advisory lookup); suggestion-semantics phrasing (PR Review Watcher gh clause); standalone phrasing (Converge to a Metric log clause); content-lint spirit (Sprint Stale Work placeholder example key -> PROJ).
- Rewrites: 0. Honest finding: the library was already written near the wave-B bar; the campaign found polish, not disease.

## Approach and decisions

- Preserved every title and category verbatim: favorites are keyed `category + ':' + title` (renaming orphans user favorites silently).
- Negative-findings lines appended as one or two sentences each, never restructuring - length discipline over bulk.
- The Sprint placeholder's example key was a real-prefix leak in spirit even though the content-lint pattern (which matches key-plus-digit forms) did not literally match it; fixed and pinned positively (PROJ) so the guard never needs to quote any pattern.
- Integration categories (Datadog, Sourcebot, Azure) legitimately name their tools - the category headers declare the requirement; suggestion semantics govern phrasing, not naming.
- Arrows in output-format examples are allowed (not em/en dashes); the new dash guard pins the actual banned characters across all five text surfaces per entry.

## Verify

- `./run-tests.sh` -> PASS 1526/1526 (baseline 1521 verified first; +5 structural tests; zero regressions, zero pin migrations).
- Content-lint grep (CLAUDE.local.md) on index.html + tests.html -> clean.
- Em/en dashes in the library block: 0 before, 0 after (now test-pinned forever).

## Gotchas / non-obvious

- Entries ending a category close with `' }` not `' },` - exact-string edits against the library must match the terminator or silently miss.
- The provider-neutral test at the durable-record suite covers genDurableRecordProtocol, NOT the library; the library names tools by design.

## History

- 2026-07-10: created (by prompt-library-overhaul)
- 2026-07-10: category data model cleaned under the director's no-compat license - requirement badges moved from HTML-in-name-strings to a requires field (names plain, defensive tag-stripping now vestigial), 'memory-mode-portable' jargon replaced with 'a personal memory/notes setup', Sourcebot requirement generalized to code-search MCP wording; titles reviewed and deliberately kept (all 75 earn their names) (by prompt-library-overhaul)

## Outcome

75 entries reviewed against the campaign bar; 13 strengthened (negative-findings contracts, availability-safe capability claims, one content-lint spirit fix), 62 confirmed strong, 0 rewritten; 5 structural guards added so the bar is pinned, not aspirational. 1521 -> 1526.

## Built with (provenance)

Direct campaign by Claude (Fable) as a fork: full read of all 75 entries, per-pillar grading grounded on the wave A-C records, exact-string batch edits with suite runs between, spot-mutation cold re-read of five rewritten entries.

## Links

- Grounds on / touches: grounds on `.workflow/prompt-overhaul-wave-a.md`, `.workflow/prompt-overhaul-wave-b.md`, `.workflow/prompt-overhaul-wave-c.md`, `.workflow/strengthen-agent-prompts.md` (the philosophy and calibration bar); amended no other records.
- Branch: main (uncommitted delivery for the director).
