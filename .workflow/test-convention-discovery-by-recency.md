# Test roles discover conventions from recently modified tests

Work item: Blue - a generated tester ignored the project's test naming convention (JS "it should") that recent tests use. Status: complete, uncommitted (Blue commits). Tests: 702/702.

## Why and scope

The shared conventionsHint already said "read the project's existing and recent tests and follow their conventions", but (a) it never said HOW to find the current convention, and (b) the per-role test templates only softly referenced "existing test patterns" via LSP references to the changed code - which finds nothing for a brand-new function/file, so the tester wrote from its defaults and missed the project's naming/structure. Borrow the proven recency pattern the designSystemAnalyzer already uses (git log --diff-filter=AM to find the most recently modified files = the team's CURRENT approach, ls -lt fallback) and apply it to test authoring, in every test-writing role for reliability.

Constraint (Blue): keep it LANGUAGE/TASK-AGNOSTIC - describe "the structure and phrasing of test cases and groupings" generically; do NOT hardcode the JS/TS describe/it or it('should') idiom.

Non-goals: not touching the mobile test-automation roles (testPlanner/screenObjectWriter/stepDefWriter/featureWriter already read existing feature files / screen classes heavily); no logic change (prose only).

## Requirements

R1. The shared conventionsHint test guidance MUST tell agents to discover the CURRENT convention by finding the most recently modified/added test files (git history, or newest by mtime) and reading a few, preferring recent examples over defaults. (test: recency phrase in genWorkflow)
R2. Each general test-writing role (tester, testWriter, testSuiteWriter, bugTester, e2eTester) MUST carry the same concrete recency-discovery + match step in its own prompt (reliability - the shared block alone got skipped). (test: each role contains "most recently modified")
R3. The guidance MUST be language-agnostic: "structure and phrasing of test cases and groupings", framework, file location/naming, assertions, fixtures, mocking - NO JS-specific idiom. (test: generic phrase present; tester does not contain "it('should")
R4. Preserve the conventionsHint para-1 pinned phrases. (existing conventions tests)

## Approach and decisions

- Strengthened conventionsHint para 2 (shared, reaches all roles + custom prompts) AND added the concrete recency step to each of the 5 general test roles (per-role reliability). Two-pronged because Blue's evidence is that the shared block alone gets skipped by the sub-agent.
- Recency is the key: conventions drift, so the NEWEST tests are the source of truth (mirrors designSystemAnalyzer's git-log approach). git history primary, newest-by-mtime fallback.
- Language-agnostic wording per Blue: generic "structure and phrasing of test cases and groupings" instead of describe/it.

## Surface area (file -> role)

- index.html: conventionsHint() para 2 (~1081); PROMPTS.tester step 3, PROMPTS.testWriter step 2, PROMPTS.testSuiteWriter step 2, PROMPTS.bugTester step 6, PROMPTS.e2eTester step 2. Prose-only.
- tests.html: +1 test (all 5 roles + the shared block carry "most recently modified"; tester has the generic phrase and not the JS idiom).

## Task checklist

- [x] conventionsHint para 2: recency-based discovery + generic phrasing
- [x] tester / testWriter / testSuiteWriter / bugTester / e2eTester: concrete recency step, language-agnostic
- [x] +1 test; preserved pinned phrases; ./run-tests.sh 702/702

## Verify

Command: ./run-tests.sh -> 702/702 pass. Prose-only change to generated prompts (no logic); no sub-agent review.

## Outcome

Every general test-writing role now starts by finding the most recently modified test files and matching their framework, location, test-case structure and phrasing, assertions, fixtures, and mocking - preferring recent examples over defaults - so generated tests fit the project's current convention the first time, in any language. The shared conventionsHint carries the same guidance for custom prompts.

## Built with (provenance)

Workflow: direct implementation by the orchestrator (6 prompt-string edits + 1 test), prose-only, no sub-agent review. Part of the code-conventions capability; complements the comment-discipline change.

## Links

Branch: TBD. PR: TBD.
