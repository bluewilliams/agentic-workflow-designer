# Dogfood-run fixes: valid model params, honest hints, memory kickoff/recovery, durable record v2.1

Workflow: dogfood-run-fixes. Branch: main. Status: finalized, committable.

```awd:record
{"slug": "dogfood-run-fixes", "status": "current", "date": "2026-07-03", "files": ["index.html", "tests.html", ".workflow/sidebar-collapse.md"], "verify": ["./run-tests.sh", "the private hygiene grep (CLAUDE.local.md, not committed)"], "superseded_by": null}
```

## Current behavior

Generated prompts now emit only VALID Task-tool model parameters: `taskModelMap` maps every `[1M]` variant to its base alias (`opus`, `sonnet`, `fable`) and a `modelContextNote()` prose line rides next to each affected model line (workflow, sub-agents, teams) carrying the 1M intent (`/model opus[1m]` where the harness supports it); the SDK keeps full API ids, which were already valid. The Atlassian hints are honest about availability (general hint: "if one is connected... do not block"; ticket hint: a neither-tool fallback). All four memory-protocol variants tell agents a missing breadcrumb on the FIRST turn of a fresh run is expected, not compaction; the orchestrator (or the single claude.ai agent) seeds the memory directory and a kickoff entry BEFORE step 1; sub-agent postamble, teams WRITE LAST, and the shared protocol's final turn all mirror the COMPLETE handoff summary (not just the TOON digest) into `@{slug}.md` as the recovery copy. The sub-agents execution model states one-shot semantics (steps return their final report as the Task result and cannot be messaged again); the workflow format states it for its parallel Task launches; teams (persistent teammates) deliberately does not. Memory, durable record, and ground-in-prior-records now default ON (state seed, HTML checked attributes, and the New Workflow reset all agree; explicit-false imports stay false). The durable record protocol v2.1 adds: a mandatory append-only `## History` ledger (one dated line per amendment, born with a created line); right-sized lineage (amend in place + History line for altered behavior, `partial` status for a replaced slice, `superseded` + Archive only for whole-capability replacement) on both the read (grounding) and write (finalize) sides; a `Grounds on / touches:` line in Links written from the run; section mutability rules (Current behavior + in-progress scaffolding are the only rewrite-in-place prose; History/decisions/gotchas/risks append-only; checklist items never erased; post-finalize changes are dated addenda); and grounding hardening (the orchestrator routes record excerpts by role - gotchas to implementers, requirements + verifying tests to reviewers/testers as review criteria, invariants to skeptics; testers re-run overlapping records' verify commands; steps note which record informed a decision). All memory-gated text is absent when the memory toggle is off, all durable-record text absent when that toggle is off, all grounding text absent when ground-in-prior-records is off.

## Why and scope

The first live dogfood run (sidebar-collapse) surfaced six real defects in the generated prompts - an invalid model param the orchestrator had to silently work around, an availability claim stated as fact, a first-turn breadcrumb check that reads as a false compaction signal, unseeded memory files, digest-only memory entries that could not have recovered the run had the full plan not been mirrored by judgment, and an unstated one-shot spawn contract that let a named agent idle. Blue additionally ruled the record system should carry the WHY of changes for future readers and reconstructible provenance (History, right-sized supersession, mutability rules), that grounding should feed every role rather than only the planner, and that memory + durable record should be on by default (the flywheel should not be opt-in). Non-goals: the A8 first-impression sidebar defaults (dropped mid-wave; deferred to its own dogfood run), retrofitting hand-authored records older than sidebar-collapse, and any SDK model-string change (its full API ids were already valid).

## Requirements

1. Task-tool model parameters MUST be valid base aliases; the 1M intent MUST survive as prose.
   - Given a node on an [1M] model, When sub-agents export runs, Then the Task call carries the base alias and the note appears. (Tests: "should emit a base model param plus the 1M prose note for Opus 4.8 [1M] (Task tool rejects [1m] values)" + sonnet/fable variants; cross-feature "valid base model alias plus the 1M note")
   - Given the workflow and teams formats, Then the model line shows the [1M] label, base param, and note. (Tests: "should show the [1M] label with a base param and the 1M prose note"; "A1: teams format emits the base param plus the 1M note")
   - Given a non-1M model, Then no note is emitted anywhere; Given the SDK, Then full API ids are kept with no note. (Tests: "A1: non-1M models emit no context note in any prose format"; "A1: SDK keeps full API model ids")
2. Availability hints MUST be conditional, never assertions. (Tests: "A2: general Atlassian hint is conditional, not an availability assertion"; "A2: ticket hint handles neither-tool-available honestly")
3. All four memory variants MUST carry the first-turn breadcrumb clause, kickoff seeding, and complete-handoff mirroring, and MUST emit none of it when memory is off. (Tests: the A3/A4/A5 trios, each with a memory-OFF assertion across genWorkflow/genSubAgents/genAgentTeams/genClaudePrompt)
4. One-shot spawn semantics MUST be stated for sub-agents and workflow-format parallel launches, and MUST NOT appear for teams. (Tests: the three A6 tests)
5. Memory, durable record, and grounding MUST default ON across seed, HTML, and reset; explicit-false imports MUST stay false. (Tests: the four A7 tests)
6. The durable record protocol MUST define History, right-sized lineage, Grounds-on, and mutability rules, gated on the durable-record toggle; grounding MUST route by role, gated on its toggle. (Tests: the B1-B5 tests, each with an OFF assertion)

## Success criteria

- A workflow generated with all defaults produces a run that needs zero orchestrator workarounds for model params, memory seeding, or first-turn checks.
- A future reader of any v2.1 record can reconstruct when and why each part changed without opening git history.
- A user who never touches a toggle gets the full flywheel (memory + record + grounding) by default.

## Spec quality check

- [x] Each requirement testable and unambiguous
- [x] Scope bounded (Non-goals stated)
- [x] No open clarifications remain
- [x] Every scenario names a verifying test
- [x] Success criteria measurable

## Approach and decisions

- Model params: map 1M variants to base aliases in `taskModelMap` + a single `modelContextNote()` helper emitted beside every model line, over per-format ad hoc notes - one source, five emission sites. SDK deliberately untouched (`getModelId` already returns valid API ids; a note there would be noise in generated code).
- Kickoff seeding lives in `genMemoryProtocol` (covers workflow + teams in one place) plus the sub-agents orchestrator memory block and the claude.ai single-agent variant - by emission site, not by copy-pasting into each generator.
- Complete-handoff mirroring extends the existing postamble step 1 and teams WRITE LAST step 1 rather than adding new numbered steps, so agent prompts keep their shape; `shared.md` stays TOON-compact by design (the @slug file is the recovery copy - proven load-bearing in the dogfood run when the planner's response channel failed twice).
- Defaults flip: `state` seed + `checked` HTML attributes + `clearCanvas` reset all changed together so first paint, first boot, and New Workflow agree. Import semantics kept as-is and stated: guarded flags (memoryEnabled, consumeRecords) leave current state when the key is absent; durableRecord absent stays off (faithful to old payloads and conservative about writing files into repos); explicit false always stays false. Grounding (consumeRecords) was ALREADY default-on; the "flip" was confirming it, not changing it.
- Right-sized lineage: three tiers (amend-in-place / partial / superseded) over the old binary, giving the index's dormant `partial` facet real semantics instead of inventing a conflicting one.
- History is a section INSIDE the record (the three-surfaces rule is untouched); one line per change with the deep why living in the amending record - provenance without verbosity.
- Grounding routing added to `consumeRecordsHint` (single emission point used by all four prose formats) rather than per-role template edits - the orchestrator distributes excerpts, so token discipline is preserved.
- Test baseline stays memory-OFF in `resetState` (deliberate: gating tests stay explicit) while dedicated A7 tests pin the app-level ON defaults via HTML attributes, `clearCanvas`, and `deserializeWorkflow`.
- Old test pins on `model="opus[1m]"` and "will modify or replace" migrated to the sharper contracts, never weakened.
- A8 (curated first-run collapse + empty-canvas quick start) was implemented then cleanly reverted mid-wave on Blue's scope change - deferred to its own dogfood run; no trace remains in code, tests, or records.

## Surface area (file -> role)

- index.html: `taskModelMap`/`getTaskModelParam`/`isLongContextModel`/`modelContextNote` (model-param block); `atlassianTicketFetchHint` + `atlassianGeneralHint` (honesty); `genMemoryProtocol`, `genAgentMemoryPreamble`, `genAgentMemoryPostamble`, `genSingleAgentMemoryProtocol`, the sub-agents Memory System block, and the teams READ FIRST / WRITE LAST lines (A3/A4/A5); `executionModelDirective.subagent` + the workflow parallel-launch line (A6); the state seed, `memoryToggle`/`durableRecordToggle` checked attributes, `memoryPathField`/`artifactPathField` default display, and `clearCanvas` defaults (A7); `genDurableRecordProtocol` (History anatomy, mutability rules, kickoff/maintain/finalize/gate wiring, Links Grounds-on, index evolution lineage) + `genDurableRecordComment` (compact mirror); `groundingLookupSteps.supersede` + `consumeRecordsHint` routing bullets (B2/B5); help modal (record anatomy + supersession paragraphs).
- tests.html: 6 migrated pins; the "Dogfood-run fixes" suite (35 tests: A1-A7 + B1-B5 with per-format ON and OFF assertions); resetState baseline comments.
- .workflow/sidebar-collapse.md: retrofit exemplar - History section + Links Grounds-on line (partial-amendment rule in action: stays current, gains a History line naming this record).

## Task checklist

- [x] A1 model param: base aliases + modelContextNote at all five prose emission sites; SDK judgment call
- [x] A2 Atlassian hints conditional-honest (general + ticket)
- [x] A3 first-turn breadcrumb clause in all four memory variants
- [x] A4 kickoff seeding (orchestrator shared.md; claude.ai progress.md), memory-gated
- [x] A5 complete-handoff mirroring (postamble, teams WRITE LAST, shared protocol final turn), memory-gated
- [x] A6 one-shot spawn line (sub-agents + workflow parallel; teams untouched)
- [x] A7 defaults ON (seed + HTML + reset), import explicit-false preserved
- [x] A8 implemented then reverted cleanly on Blue's scope change (deferred)
- [x] B1 History section wired through anatomy, kickoff, maintain, finalize, gate
- [x] B2 right-sized lineage on read (grounding) and write (index evolution, finalize) sides; `partial` given semantics
- [x] B3 Grounds on / touches line in Links, written from the run
- [x] B4 section mutability rules + gate enforcement
- [x] B5 grounding routes excerpts by role; reviewers/testers treat records as criteria; verify re-runs
- [x] C sidebar-collapse.md retrofit (History + Grounds-on; nothing else touched)
- [x] Tests: 6 migrations + 35 new, every memory/durable/grounding addition with an OFF assertion
- [x] Full suite green via ./run-tests.sh; content-lint grep clean; no em dashes

## Verify

- `./run-tests.sh` -> PASS 1385/1385 (baseline 1350 + 35 new; 6 old pins migrated to sharper contracts, none weakened; zero regressions).
- `the private hygiene grep (CLAUDE.local.md, not committed)` -> exit 1 (clean).
- Em-dash grep over index.html, tests.html, .workflow/*.md -> no matches.

## Gotchas / non-obvious

- The 1M prose note itself contains the literal `opus[1m]` (the `/model` example), so a test must never assert the ABSENCE of that bare string in an [1M] export - assert `model="opus[1m]"` absence (the Task param form) instead.
- `resetState` in tests.html keeps memory/durable OFF as the test baseline even though the app now defaults ON - deliberate, so every gating test toggles explicitly; the A7 tests pin the app defaults through the HTML `checked` attributes (which survive runtime `.checked` mutation) and `clearCanvas`.
- `buildTestWorkflow` calls `resetState` internally - a test proving post-reset defaults must add nodes via `addNode` directly, not via `buildTestWorkflow` (which would wipe the flags again).
- The B3/B5 OFF assertions must disable BOTH durableRecord and consumeRecords: `Grounds on / touches` is emitted by both the record protocol and the grounding hint.
- Import absent-key semantics (stated, deliberate): memoryEnabled/consumeRecords guarded (absent = keep current state, typically the new default); durableRecord unguarded (absent = off - faithful to old payloads, conservative about writing files); explicit false always stays false.

## History

- 2026-07-03: created - the fix batch from the first live dogfood run, plus Blue's durable-record v2.1 rulings (History/provenance, right-sized supersession, mutability, grounding routing, defaults ON); A8 added then dropped mid-wave by Blue (deferred to its own run) (by dogfood-run-fixes)

## Outcome

Six live-run defects fixed across all four prompt formats with memory-gating proven by OFF assertions; the durable record protocol gained provenance (History), right-sized lineage with real `partial` semantics, mutability rules, and Grounds-on traversal; grounding now feeds every role, not just the planner; and the full flywheel (memory + durable record + grounding) is the default. index.html + tests.html + the sidebar-collapse exemplar retrofit; 1350 -> 1385 tests, all green; uncommitted for the director's review.

## Built with (provenance)

Workflow `dogfood-run-fixes`: executed directly by Claude (Fable) as a single implementing agent under Blue's live direction (spec assembled from the dogfood-run audit in the session vault; scope amended live four times: +B4 mutability, +B5 grounding hardening, +A7 defaults flip, +A8 then -A8). Memory + durable record conventions honored by hand; grounded on `.workflow/sidebar-collapse.md` (the run that surfaced the defects), `node-config-ux` untouched.

## Links

- Grounds on / touches: grounds on `.workflow/sidebar-collapse.md` (defect source + retrofit target) and the record protocol text in index.html; amended `.workflow/sidebar-collapse.md` (History + Grounds-on retrofit, no behavior change).
- Branch: main (uncommitted working tree for review).
