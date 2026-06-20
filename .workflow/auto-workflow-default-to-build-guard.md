# Auto Workflow: default-to-build guard

Branch: local working tree. Status: current. Stops `generateFromStory` from inferring a read-only / non-coding shape (and producing no implementer) when the user's intent is tangible build work.

## Why and scope

Dogfooding surfaced the bug: a build task ("make three node options functional") whose acceptance criteria were thick with test vocabulary scored `test` dominant and produced **Shape 11 (Code Analyzer -> Test Suite Writer) with no implementer**. Root cause: there is no "build/feature" category - build is only the `generic` fallback, so incidental read-only vocabulary (test/doc/review words in acceptance criteria) wins uncontested. Most designer use is tangible build work, so inferring read-only when the user wants real work is the costly error. Blue's principle: slant to code under ambiguity; generalize past `test` to all read-only intents (research/review/analysis/documentation).

Non-goals: adding a build CATEGORY (generic build verbs would hijack other categories - the reason it never existed); re-tuning the CATEGORIES weights (kept stable so the 289-case fuzz behavior does not move).

## Requirements

- **A non-coding intent stands only if the task asks to PRODUCE a read-only deliverable.** GIVEN dominant in {research, review, analysis, test, documentation}, WHEN no read-only deliverable marker is present OR build signal weighs >= read-only signal, THEN reclassify to a build shape (`generic`), which routes through the hasUI/hasAPI/simple/generic chain and always lands an implementer + testing/review tail. Verified by `default-to-build guard` suite.
- **Position-independent.** Requirements rarely declare intent up front, so deliverable markers match ANYWHERE; markers in the first ~240 chars weigh 2 vs 1 (a soft boost, not a gate). Verified by the multi-paragraph build fixtures (intent buried after a Background/Acceptance block).
- **Demote-only.** The guard can only turn read-only -> build, never build -> read-only, so it cannot newly hijack anything into a read-only shape. The only possible regression is over-demoting a genuine read-only task - which the 289 fuzz cases guard against.
- **Genuine read-only is preserved.** "Write tests for X" -> test; "Evaluate options... recommendation... research only" -> research; "Audit X for... findings... read-only" -> review; "Document the API... OpenAPI" -> documentation. Verified by the guard suite + unchanged fuzz labeled cases.
- **Structural invariant.** Every non-read-only, non-authoring fuzz shape MUST contain >=1 implementer (`IMPLEMENTERS` = code-writers minus Test Suite/Test Writer). Turns "no implementor" into a test failure.

## Approach and decisions

- Guard inserted in `generateFromStory` right after `dominant` is computed (changed `const`->`let`) and BEFORE `isReadOnlyIntent`, so the planner/architect layer also sees the corrected intent.
- `READONLY_MARKERS` per intent = what the work PRODUCES (recommendation/comparison matrix/findings/cost forecast/write-tests/write-docs), not domain mentions. Key fix found empirically: test markers must be authoring-only (`write/add/improve tests|coverage`), NOT acceptance-style mentions (`unit tests cover`, `test suite passes`) - the latter is what a build task's AC contains.
- `BUILD_MARKERS` = implement/wire-up/make-it-functional/fix/refactor/migrate, plus concrete UI/API artifacts (endpoint/component/middleware/migration/handler). Deliberately OMITS generic nouns (job/service/feature) that are usually the SUBJECT of a read-only task ("add docs for the export **job**") - that false positive was caught by the fuzz suite and removed. Build verbs framed by read-only context ("whether to implement", "no implementation") are discounted.
- Demote target is `generic` (a value matched by no `dominant ===` branch), so it falls through to the hasUI/hasAPI/simple/generic build chain.
- Chose markers + margin over a build CATEGORY (no weight-table changes, no cross-category hijack) and over positional "leads with" (real tickets bury intent).

## Surface area (file -> role)

- `index.html`: `generateFromStory` - the default-to-build guard block (~45 lines: NON_CODING set, READONLY_MARKERS, BUILD_MARKERS, position-weighted strength, demote). No CATEGORIES/PRIORITY/shape changes.
- `tests.html`: `IMPLEMENTERS` const; build-shape structural invariant in the labeled-intent fuzz loop; new `default-to-build guard` suite (7 tests: 4 build-with-read-only-vocab keep an implementer; genuine write-tests/research/audit stay read-only).
- README + TECHNICAL: Workflow Generation section (replaced the stale "leads with the imperative verb" claim with the guard).

## Verify

`./run-tests.sh` -> `PASS: 1071/1071` (was 1064; +7 guard tests; the structural invariant also runs across every labeled build fuzz case). Headless probes: dogfood + "add retry mechanism (test-heavy AC)" + "rate limiter (test AC)" + "implement endpoint, document it" all gain an implementer; genuine write-tests/research/audit/document all stay read-only. Guard converged in 2 empirical iterations (fix 1: dropped the "job" build-noun false positive; fix 2: test markers authoring-only).

## Gotchas / non-obvious

- The guard runs ONLY on an already-winning read-only `dominant`; it cannot promote. So loose read-only markers are safe (worst case = keep read-only = current behavior).
- Test acceptance vocabulary ("the test suite passes", "unit tests cover X") is NOT a read-only signal - only authoring phrasing ("write/add tests") is. This distinction is the crux of the test case.
- `win.state` is unreadable from a raw iframe probe; `generateFromStory` clears nodes itself when confirm() returns true.

## Outcome

`generateFromStory` now defaults to building under ambiguity: a read-only/non-coding shape is chosen only when the task asks to produce a read-only deliverable, so build tasks with test/doc-heavy acceptance criteria keep their implementer. Demote-only + the 289-case fuzz oracle + a new build-has-implementer invariant make it safe and regression-proof.

## Built with (provenance)

Authored directly (the empirical loop: implement guard -> run 289-case fuzz -> fix the failures it surfaced -> headless-probe real-format tickets -> lock with fixtures). Follows the discarded dogfood workflow that first exposed the gap (`.workflow/node-config-options-drive-output.md`).
