# Compress durable record at finalize

Work item: none (dogfood). Branch: main. Status: in progress.

## Why and scope
The durable-record protocol (genDurableRecordProtocol in index.html) tells each agent to amend the record as it works and the orchestrator to finalize it (Outcome, breadcrumb, remove scaffolding), but it never tells finalize to COMPRESS the working sections. So committed records accumulate per-agent transcript commentary - the existing record .workflow/make-sourcebot-option-general-and-called-code-search-mcp.md has Verify and Gotchas full of "REVIEWER VERDICT...", "IMPLEMENTER GOTCHA...", and duplicate scan lines, reading like a chat log instead of a spec. Add a finalize-compression instruction, tighten the kickoff guidance so surface area is marked provisional until grounded, and apply both retroactively to the one existing record as the worked example.

Non-goals: changing any other protocol behavior (consume gate, clarify gate, breadcrumb format, the produce/write rules). Not superseding the code-search record - this only reformats its verbose sections (its decisions are unchanged).

## Requirements
R1 - genDurableRecordProtocol() MUST instruct the finalize step to compress the working sections.
- Given the durable-record option is on, When genDurableRecordProtocol() renders, Then the finalize guidance tells the orchestrator to compress Verify and Gotchas into a tight final statement (collapse per-agent running commentary, remove duplicate scan lines) while keeping the Built-with provenance and the final facts. [test: Durable Record: protocol content > 'v2.7: finalize compresses Verify and Gotchas into a clean spec (no per-agent transcript)' - asserts proto.toContain('compresses Verify and Gotchas') (the recommended unique phrase, grep-confirmed absent from tests.html and index.html)]

R2 - The protocol MUST tell the orchestrator to mark Surface area as provisional until it is grounded.
- Given the protocol renders, When the kickoff/maintenance guidance is read, Then it states surface area is provisional until the grounding or first working step verifies it (the orchestrator should not assert confident surface-area guesses before grounding). [test: same describe block > 'v2.7: Surface area is marked provisional until grounded' - asserts proto.toContain('provisional until the grounding') (unique phrase, grep-confirmed absent from both files)]

R3 - The existing code-search record's Verify and Gotchas MUST be compressed without losing durable facts.
- Given .workflow/make-sourcebot-option-general-and-called-code-search-mcp.md, When compressed under the new rule, Then Verify/Gotchas contain no per-agent transcript lines ("REVIEWER VERDICT", "IMPLEMENTER GOTCHA", duplicate dash/fence scan lines) but still state the final 482/482 result and retain the durable gotchas (the harness resetState() default-ON fix; the false-positive rename sites that must not be touched). [test: grep-based content check, not a harness test]

R4 - Regression safety: the suite MUST stay green with count >= baseline and no forbidden punctuation.
- Given ./run-tests.sh after the change, Then it is 100% green with count >= 483 (baseline), no em/en dashes anywhere touched, and no triple-backtick fences inside any protocol string. [test: the suite + dash/fence scan]

## Success criteria
- A reader of any finalized record sees a clean spec, not a transcript (no per-agent verdict narration left in Verify/Gotchas).
- The protocol's finalize step names compression explicitly, and a protocol-content test asserts that instruction is present.
- The existing record is compressed with zero loss of durable facts (final result + real gotchas retained).
- ./run-tests.sh green with count >= 483.

## Spec quality check
- [x] Each requirement is testable and unambiguous
- [x] Scope is bounded (Non-goals stated)
- [x] No open clarifications remain (clarify gate no-opped: requirements clear)
- [x] Every scenario names a verifying test (or a noted manual check)
- [x] Success criteria are measurable

## Approach and decisions
- Add the finalize-compression instruction to the existing finalize guidance in genDurableRecordProtocol(), and add the provisional-surface-area note to the kickoff guidance. Additive wording only; do not alter consume/clarify/breadcrumb/produce rules.
- Grounding result (consume gate): the code-search record was matched via shared files but is NOT a decision-dependency and NOT superseded by this change. This change reformats its verbose sections only. Do not set supersedes/superseded_by.
- Compression keeps the Built-with provenance line (it already records the agent roles) and the final facts; it strips per-agent attribution narration from Verify/Gotchas.

## Surface area (file -> role) - GROUNDED by the Investigator
- index.html, genDurableRecordProtocol() (function spans 2322-2383):
  - FINALIZE site: line 2366, the "On completion, finalize it for commit:" bullet under `### How to maintain it`. The new compression instruction must be appended here (this is where Outcome/breadcrumb/strip-scaffolding already live). Current text ends: "...The committed artifact is the requirements (with verifying tests), the approach and decisions, the completed checklist, the Verify results, and the outcome." Add the directive to compress Verify and Gotchas into a tight final statement, collapsing per-agent running commentary (e.g. REVIEWER VERDICT / IMPLEMENTER GOTCHA) and removing duplicate scan lines, keeping the Built-with provenance and the final facts.
  - KICKOFF/SURFACE-AREA site: line 2342, the `- **Surface area (file -> role)**:` "What it contains" bullet. Current text: "a compact map of the main files or types the change touches and what each does, including explicit out-of-scope notes, so an agent or person can navigate the change without rediscovering it." Append the provisional note (surface area is provisional until the grounding or first working step verifies it). Reinforce at the kickoff "Create it at kickoff" bullet (line 2363) if a second touch is wanted, but line 2342 is the canonical surface-area description.
- tests.html: describe block `Durable Record: protocol content` (opens line 976, beforeEach resetState at 977, closes line 1219). Each test grabs `const proto = win.genDurableRecordProtocol();`. Add two new `it(...)` blocks before the closing `});` at line 1219 (after the v2.6 orchestrator test at 1191). Recommended unique assertion phrases: `'compresses Verify and Gotchas'` (R1) and `'provisional until the grounding'` (R2) - both grep-confirmed absent from tests.html and index.html, no collision with the toNotContain('Sourcebot') checks (1014/1060) or em/en-dash checks (1018/1019). Existing protocol-content tests are pure additive substring checks; none break.
- .workflow/make-sourcebot-option-general-and-called-code-search-mcp.md: compress Verify (lines 105-123) + Gotchas (lines 129-137). See keep/cut list in the Investigator handoff. Worked example.
- README.md / TECHNICAL.md: item 4 doc update is a NO-OP for the finalize-compression change. Both mention "finalize" only in the context of the breadcrumb _index.md being "written at finalize" (README line 70, TECHNICAL line 288) - they do NOT describe the record's finalize-compression step, so there is nothing to update for this change. Do not edit them.

## Task checklist
- [x] Investigator: ground the surface area (confirmed finalize site = index.html:2366, surface-area/kickoff site = index.html:2342; protocol-content test block = tests.html:976-1219; README/TECHNICAL do NOT describe finalize-compression so item 4 doc update is a no-op), capture baseline count (483/483 green)
- [x] Fixer: add the finalize-compression instruction + provisional-surface-area note; add the protocol-content test; compress the existing record's Verify/Gotchas; update docs if needed (README/TECHNICAL no-op confirmed)
- [x] Tester: assert the new protocol-content test; grep the compressed record for forbidden transcript lines; run the full suite; dash/fence scan
- [x] Orchestrator (finalize): compressed THIS record's Verify (dogfooded the new rule), wrote Outcome, projected the _index.md entry, removed scaffolding

## Verify
- ./run-tests.sh: 485/485 green (483 baseline + 2 new R1/R2 protocol-content tests). Independently re-run by the Tester, same result.
- R1/R2: the protocol contains "compresses Verify and Gotchas" (index.html:2366, finalize bullet) and "provisional until the grounding" (index.html:2342, surface-area bullet); both asserted by the new tests (tests.html ~1219-1226).
- R3: the code-search record's Verify/Gotchas contain zero "REVIEWER VERDICT" / "IMPLEMENTER GOTCHA" / "TESTER (independent" lines; all three durable facts retained (482/482 from 468; the resetState() default-ON harness gotcha; the false-positive rename sites). Reads as a clean spec.
- R4 / scope: no em/en dashes or triple-backtick fences on any changed line; index.html diff is two additive bullet-tail insertions only (consume/clarify/breadcrumb/produce rules unchanged); README.md and TECHNICAL.md not modified.

## Outcome
Added a finalize-compression directive to genDurableRecordProtocol() (index.html:2366): at finalize the orchestrator compresses Verify and Gotchas into a tight final statement, collapsing per-agent running commentary and duplicate scan lines while keeping the Built-with provenance and final facts. Added a provisional-surface-area note to the surface-area guidance (index.html:2342). Two protocol-content tests assert both phrases (tests.html). Applied the new rule retroactively to the code-search record (compressed its Verify/Gotchas, and the one stray Surface-area attribution line, with no durable fact lost) as the worked example. The directive carries a readability guard ("compress the transcript accretion, not the reasoning; the record must still read like an authored OpenSpec/spec-kit-quality spec - keep the Why, the decisions and their rejected alternatives, and the durable gotchas") so an agent cannot over-compress into terseness; a protocol-content test asserts it ("not the reasoning"). Tests 483 -> 485 green. README/TECHNICAL untouched (they do not describe record compression).

## Built with (provenance)
Produced by the workflow "Compress durable record at finalize" (Sub-Agents form, Bug Fix shape), agent roles Investigator -> Fixer -> Tester with no named Planner, driven by an orchestrator that ran an up-front grounding gate (consume - matched the code-search record) and a clarify gate (no-op) before the first step. Grounded by direct grep over index.html and tests.html plus the committed .workflow/_index.md.

## Links
- Work item: none (dogfood)
- Branch: main
- PR: TBD
