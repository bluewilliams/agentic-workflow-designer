# Comment discipline: no ticket IDs, minimal + concise

Work item: Blue flagged generated code carrying verbose JSDoc with Jira keys ( x3 + a TODO()). Status: complete, uncommitted (Blue commits). Tests: 701/701.

## Why and scope

The always-on conventionsHint already preferred self-describing code and gated comments to "non-obvious why", but it said nothing about (a) ticket/issue IDs in comments or (b) brevity - so agents stuffed Jira keys + multi-line narratives + TODO(TICKET) into comments. Blue wants minimal, concise comments, reserved for genuinely non-obvious code or public/exported API surfaces (JSDoc), with NO ticket IDs (git already ties code to its ticket) and no comments-for-the-sake-of-it (reads as AI slop).

Non-goals: not banning comments (JSDoc on API surfaces + non-obvious why still welcome); not touching the legitimate test-selector TODO markers (screenObjectWriter's `// TODO: verify selector` is intentional).

## Requirements

R1. conventionsHint MUST forbid ticket/issue IDs (Jira keys, PR numbers) and changelog notes in code comments, citing version control. (test: conventions ticket-ID ban)
R2. conventionsHint MUST demand brevity / no comments-for-the-sake-of-it, and keep the API-surface (JSDoc) allowance. (test: conventions brevity)
R3. The reviewer template MUST flag ticket-ID/changelog/over-long comments. (test: reviewer ticket-ID)
R4. The fixer's "add a comment" step MUST be gated to genuinely-non-obvious + no ticket IDs. (test: fixer no-ticket)
R5. Preserve the pinned phrases: "self-describing code over comments", "in tests as much as in production code", reviewer "comment the why, not the what". (existing conventions tests)

## Approach and decisions

- Three string edits in index.html: conventionsHint para 1 (the global always-on directive, reaches every agent + custom prompts), the reviewer Comments bullet, and the fixer step 9. The conventionsHint is the high-leverage one (flows down to all roles); the reviewer + fixer reinforce it at the points most likely to emit ticket-ref comments.
- Kept all test-pinned phrases so existing coverage holds.
- Also captured Blue's underlying preference globally in ~/.claude/user/preferences.md (Code Preferences > Comments) so it applies to ALL code written for him, not just designer output.

## Surface area (file -> role)

- index.html: conventionsHint() para 1 (~1079); PROMPTS.reviewer Comments bullet (~1335); PROMPTS.fixer step 9 (~1326). Prose-only, no logic.
- tests.html: +3 tests (conventions ticket-ID ban + brevity; reviewer ticket-ID; fixer no-ticket).
- ~/.claude/user/preferences.md (global user preference, outside the repo).

## Task checklist

- [x] conventionsHint: no ticket IDs + brevity + keep JSDoc allowance
- [x] reviewer: flag ticket-ID/changelog/over-long comments
- [x] fixer: gate the comment step + no ticket IDs
- [x] +3 tests; preserved pinned phrases; ./run-tests.sh 701/701
- [x] Capture the preference globally (preferences.md)

## Verify

Command: ./run-tests.sh -> 701/701 pass. Prose-only change to generated prompts (no logic); no sub-agent review needed.

## Outcome

Generated workflows now tell agents: comment only where it earns its place (non-obvious why, real gotcha, or public/exported API via JSDoc), keep it short, and never put ticket IDs or changelog notes in code comments. Reviewer + fixer reinforce it. Directly addresses the -in-comments slop Blue flagged.

## Built with (provenance)

Workflow: direct implementation by the orchestrator (3 prompt-string edits + 3 tests), prose-only, no sub-agent review. Part of the code-conventions capability; tightens .workflow/orchestrator-directives-for-code-comments-and-project-consistency.md.

## Links

Branch: TBD. PR: TBD.
