# Multi-repo: read each repo's CLAUDE.md (it does not auto-load outside the launch dir)

Work item: Blue - does Claude honor CLAUDE.md/rules when an agent works outside the workspace dir (a second repo)? Status: complete, uncommitted (Blue commits). Tests: 704/704.

## Why and scope

Verified against Claude Code docs (via the claude-code-guide agent): CLAUDE.md and `.claude/rules/` auto-load ONLY for the tree rooted at the directory the session launched in. A second repo cloned elsewhere is outside that tree, so its CLAUDE.md is NOT auto-loaded; non-fork subagents inherit the LAUNCH repo's rules, not a re-scan of new directories. `--add-dir` grants file access but by default does NOT load those dirs' CLAUDE.md unless `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` is set. Only CLAUDE.md + `.claude/rules/` auto-load anywhere (CONVENTIONS.md/CONTRIBUTING.md never do).

Our generated prompts ASSUMED CLAUDE.md is universally auto-loaded ("already auto-loaded, do not re-read") - true for the launch repo, false (and actively misleading) for secondary repos in a multi-repo run. Fix: make the prompts repo-aware, and surface the env-var setup as the clean alternative.

Non-goals: the designer cannot set env vars or launch flags (it emits text to paste); the env-var path is a documented user setup, the per-repo read is the portable in-prompt fallback.

## Requirements

R1. The multi-repo block (repoBlock) MUST instruct agents to read each repo's own CLAUDE.md / CLAUDE.local.md / .claude/rules/ before changing it, explaining auto-load covers only the launch dir. (test: multi-repo block)
R2. The multi-repo block MUST name the cleaner setup: `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir <path>`, with the per-repo read as the fallback. (test: multi-repo block)
R3. rulesPathsHint + productDocsHint MUST stop claiming CLAUDE.md is universally auto-loaded; instead say it auto-loads for the launch repo and tell agents to read each OTHER repo's CLAUDE.md/.claude/rules in a multi-repo run. (test: rules hint multi-repo)
R4. The sidebar helper text MUST match (CLAUDE.md auto-read in the launch repo). (test: existing sidebar text test, updated)
R5. Preserve the pinned hint-semantics phrases (BINDING, auto-loaded, CLAUDE.md, directory/single file, Read only what is listed, within each in-scope repository, no Sourcebot/em-dash/fence). (existing tests)

## Approach and decisions

- Two-layer fix: (1) in-prompt per-repo read (portable, works regardless of launch) + (2) document the env-var/--add-dir setup (cleaner, automatic, but user-controlled and only for --add-dir repos). Belt-and-suspenders.
- Kept the launch repo efficient: do NOT re-read its CLAUDE.md; only the OTHER repos need an explicit read. Accepts that auto-load already covers the launch repo.
- Listed Rule Paths already resolve per-repo - that path was already correct and also covers the never-auto-loaded files (CONVENTIONS.md etc.); only the CLAUDE.md assumption was wrong.

## Surface area (file -> role)

- index.html: repoBlock (per-repo rules read step + env-var setup tip ~2103); rulesPathsHint (~1096) + productDocsHint (~1116) repo-aware CLAUDE.md; sidebar helper text (~467, ~471). Prose/UI-text only.
- tests.html: +2 (multi-repo block has per-repo read + env var; rules hint multi-repo CLAUDE.md); updated the sidebar-text assertion.
- README.md: new "Multi-repo gotcha: CLAUDE.md only auto-loads for the launch repo" subsection.

## Task checklist

- [x] repoBlock: per-repo CLAUDE.md/.claude/rules read step + env-var setup tip
- [x] rulesPathsHint + productDocsHint: repo-aware CLAUDE.md wording
- [x] sidebar helper text + its test
- [x] README multi-repo gotcha subsection
- [x] +2 tests; preserved pinned phrases; ./run-tests.sh 704/704

## Verify

Command: ./run-tests.sh -> 704/704 pass. Prose/UI-text change (no logic); behavior confirmed against Claude Code docs by the claude-code-guide agent (memory.md + sub-agents.md).

## Outcome

Multi-repo generated workflows now tell agents to explicitly read each working repo's CLAUDE.md / CLAUDE.local.md / .claude/rules/ before changing it (auto-load only covers the launch repo), and surface the `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir` setup as the clean automatic alternative. Closes the gap where a secondary repo's rules were silently ignored - and removes the old "CLAUDE.md is already auto-loaded, do not re-read" wording that was steering agents wrong.

## Follow-on: per-repo rule scoping (incl. the launch repo)

Blue asked to also scope the LAUNCH repo's auto-loaded CLAUDE.md to only the launch repo (no cross-contamination into other repos' work). Added a step 4 to repoBlock: each repository's CLAUDE.md/.claude/rules govern ONLY that repo's work; the CLAUDE.md auto-loaded at session start belongs to the launch repo (treat as that repo's rules, not a global default), do not apply it to changes in another repo even though it stays loaded in context; when changing a repo, follow that repo's rules, and on conflict the repo being changed wins. Mirrors the anti-contamination wording the listed Rule/Product paths already had. +1 test; 704->705.

HONEST FRAMING (in the wording + for Blue): this is a BEHAVIORAL scoping discipline, not hard isolation. The launch repo's CLAUDE.md is physically loaded in the model's context for the whole session and cannot be unloaded by a prompt; we can only instruct the agent to apply rules per-repo. True hard isolation would require separate sessions per repo (breaks the single cross-repo workflow). For the common case, behavioral scoping is the practical answer and matches what we already trust for the listed paths.

## Built with (provenance)

Workflow: direct implementation by the orchestrator. Claude Code behavior verified by a claude-code-guide subagent against official docs (memory.md, sub-agents.md). 5 prose/UI edits + 2 tests + README. Part of the repo-context-paths capability.

## Links

Branch: TBD. PR: TBD.
