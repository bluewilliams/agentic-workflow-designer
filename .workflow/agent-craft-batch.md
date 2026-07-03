# Agent craft batch: found-defect protocol, verifier strengthening, verification ledger, owner-only mandates

Workflow: agent-craft-batch. Branch: main. Status: finalized, committable.

```awd:record
{"slug": "agent-craft-batch", "status": "current", "date": "2026-07-03", "files": ["index.html", "tests.html", "CLAUDE.md", ".workflow/verification-instructions.md"], "verify": ["./run-tests.sh", "git grep -niE 'XX-[0-9]|REDACTED|REDACTED|REDACTED|REDACTED|ai\\.tools|XX-[0-9]|XX-[0-9]' -- index.html tests.html CLAUDE.md"], "superseded_by": null}
```

## Current behavior

Building and testing roles (coder, backend, frontend, general, debugger, tester, verifier) receive a found-defect protocol in every generated step prompt (`foundDefectNote`, per-step beside the other role-gated hints): a blocking pre-existing defect is fixed with the coverage correctness demands; low-hanging fruit inside the code already being changed is fixed in passing and tested like the agent's own work (with test-plan ballooning as the not-actually-trivial tell); everything else is reported for the record's Found bugs section - working around a defect and undeclared drive-by fixes are named anti-patterns, and the reviewer template treats a DECLARED defect fix as in scope while undeclared ones stay findings. The tester template closes by proving its tests can fail (spot mutation: break the two or three most load-bearing behaviors, watch the suite go red, revert, report; skips must be stated). The verifier template opens as the escalation tier (summoned to actually RUN the work), enumerates the definition of done as a checklist before exercising, treats provided verification steps as additive to its own judgment (never a substitute), reuses the repo's own test rig or builds a throwaway harness (always removing scratch artifacts), asserts precise contract forms over loose substrings, and degrades honestly under budget pressure (highest-risk first, remainder reported not-verified). The durable-record protocol gains two sections: **Found bugs** (always in the anatomy; append-only; deferred defects stay discoverable by future grounding scans) and the **Verification ledger** (emitted when the workflow runs a verifier or repo mandates are configured; one checkbox per verification act, append-and-tick, re-runs annotate rather than duplicate, blocked required checks stay visibly unticked; the verifier's handoff asks for ledger lines and the spec quality check gains an independent-verification box when a verifier exists). Repo-mandated verification files route owner-only (see the amended verification-instructions record). The import toast names the missing `format` field; the awd:run example fence carries the first connected repo's name (my-app as fallback); `CLAUDE.md` at the repo root now carries the binding agent rules (content-lint grep, no em dashes, fixture-key style, single-file conventions, gating discipline).

## Why and scope

Three dogfood runs produced evidence-based craft gaps: agents had no channel for pre-existing defects they trip over (fix-vs-record ambiguity, workaround risk), vacuous tests had no forcing function, the verifier template relied on orchestrator briefs for harness/checklist/budget discipline it should own, verification acts left no durable ledger, and the repo-mandate contract went to three roles when one owner prevents duplicate execution of expensive checks. Non-goals: no full mutation-testing tooling default (that is a repo mandate for VERIFY.md - the help text now says so); no per-node verification config; no new durable surfaces (both new sections live inside the record).

## Requirements

1. Building/testing roles MUST carry the three-tier found-defect protocol; plan/review/critique roles MUST NOT. (Tests: building and testing roles carry the protocol; plan/review/critique roles do not; carries the three tiers: blocking fix, in-passing fix with real coverage, record-and-defer; a coder step carries the protocol end-to-end in generated prompts; a planner step does not)
2. The reviewer MUST treat declared defect fixes as in-scope. (Test: the reviewer template treats a DECLARED pre-existing-defect fix as in scope)
3. The tester MUST close by proving its tests can fail, with an honest skip path. (Test: the tester template closes by proving its tests can fail)
4. The verifier template MUST carry: escalation-tier intent, checklist-first, additive-mandates, harness bootstrapping with scratch cleanup, precise-contract-form assertion, budget honesty. (Tests: the six verifier strengthening tests)
5. The record protocol MUST define Found bugs (always) and the Verification ledger (verifier or mandates present), wired through mutability, KEEP CURRENT, and the finalize gate; the verifier's handoff MUST request ledger lines; everything durable-gated. (Tests: the seven ledger/Found-bugs tests including the durable-OFF silence assertion)
6. Repo-mandated verification files MUST route to exactly one owning step (last verifier, else last tester; reviewers never), stated as additive to the owner's own method. (Tests: the owner-resolution suite - verifier owns over upstream tester; last tester wins; reviewers never; non-verification roles never; no-owner workflows emit nothing; additive sentence pinned)
7. Polish: import toast names the missing format field (manual check - the toast string is inline in importWorkflowFile); the awd:run example uses the connected repo name. (Test: the awd:run example fence names the connected repo, falling back to my-app)
8. Help text MUST name full mutation testing as the archetypal repo-mandated check. (Test: the help modal names full mutation testing as a repo-mandated verification check)

## Success criteria

- An agent that finds a bug now has exactly three sanctioned moves, all visible in review or the record - silent workarounds and silent fixes are both named violations.
- A future reader can see every verification act a run performed (and every check it could not perform, with reasons) in one ledger.
- An expensive repo-mandated check (cloud grid, load test) can never execute twice in one run.

## Spec quality check

- [x] Each requirement testable and unambiguous
- [x] Scope bounded (Non-goals stated)
- [x] No open clarifications remain (owner-only ruling and the additive clarification arrived mid-wave and are folded in)
- [x] Every scenario names a verifying test (req 7's toast is a stated manual check)
- [x] Success criteria measurable

## Approach and decisions

- The found-defect protocol is ONE shared helper (`foundDefectNote` + `FOUND_DEFECT_ROLES`) emitted at the six existing per-step hint sites, not per-template copy-paste - same architecture as datadogStepHint. It is always-on for its roles (craft judgment, not a toggleable integration). general/backend/frontend included: they hold write tools and implement.
- Owner resolution reuses `topologicalSort()` (execution order, revise back-edges excluded) rather than canvas order - "last" means last to run, which is what ownership requires.
- The step hint keys on node identity (`node.id === resolveVerifyOwnerId()`), so bare config objects can never accidentally receive the contract - owner-only is structural.
- The Verification ledger emits on `hasVerifier || verifyPaths configured` (mandates need a ledger home even in tester-owned workflows); the spec-quality independent-verification box emits on hasVerifier only.
- Found bugs is unconditional in the anatomy (any run can find bugs); both new sections are inside the record - the three-surfaces rule is untouched.
- Requirements-truncation investigation (run-2 report: "text" -> "tex" clipped identically across all step prompts): NOT REPRODUCIBLE in-app. Evidence: no maxlength anywhere in index.html; the story emission path is `getStory()` reading the live textarea value directly with no slice/substring (the only story slice is a display-only 200-char auto-workflow description preview). The loss was upstream of the app - most consistent with a terminal line-wrap copy artifact when the requirements were copied from chat. Documented here rather than in Found bugs since it is not an app defect.
- Director clarifications honored: repo-mandated checks are ADDITIVE everywhere they are described (owner step hint, orchestrator beat, verifier template, help) - nothing reads as "do only the mandates."

## Surface area (file -> role)

- index.html: `foundDefectNote`/`FOUND_DEFECT_ROLES` (new, beside datadogStepHint) + emission at the six per-step sites + Explain row; PROMPTS.reviewer declared-fix clause; PROMPTS.tester spot-mutation step 7; PROMPTS.verifier five strengthenings; `resolveVerifyOwnerId`/`VERIFY_OWNER_ROLES` replacing VERIFY_STEP_ROLES + retargeted `verifyInstructionsStepHint` + beat/sidebar/SDK-header/openSpec/help/Explain wording; genDurableRecordProtocol (Found bugs + Verification ledger + spec-quality box + mutability + KEEP CURRENT + finalize-gate wiring, hasVerifier/hasLedger conditionals); `recordHandoffHint(node)` verifier ledger-lines variant (all six call sites now pass their node); genDurableRecordComment mirror; importWorkflowFile toast reason; runReportDirective repo name.
- tests.html: exposure-block migration (VERIFY_OWNER_ROLES/resolveVerifyOwnerId/FOUND_DEFECT_ROLES/foundDefectNote); suites 12c/12d migrated to owner resolution (BEAT_MARK, routing pins, the owner-resolution describe); new suite 12e "Agent craft batch" (20 tests).
- CLAUDE.md: new repo-root agent rules (binding).
- .workflow/verification-instructions.md: amended in place (Current behavior + History line; index intent line rewritten).
- README.md: Sonnet 5 in the model list; auto-naming bullet rewritten (derived slugs, stale two-part-name claim removed); collapsible-sidebar/first-boot + empty-canvas quick-start bullets; Repo Context Paths grown to three lists with the verification-instructions description (owner-targeting, posture, contract); durable record section gains Verification ledger + Found bugs; More Under the Hood gains found-defect protocol + spot-mutation bullets.
- TECHNICAL.md: Sonnet 5 + taskModelMap note in the model line; awd_prefs persistence shape updated (repo-context lists + verify posture); Repo Context Paths section covers the third list, owner resolution, and foundDefectNote; durable-record anatomy sentence gains the two conditional sections. Two pre-existing en dashes in zoom ranges fixed in passing (trivially in-path under the new CLAUDE.md rule).
- Help modal: collapsible-sidebar line gains the curated first boot + quick start; new derived-names tip; record-anatomy paragraph gains Verification ledger + Found bugs.

## Task checklist

- [x] Found-defect protocol helper + six emission sites + Explain row + reviewer clause
- [x] Found bugs record section wired through anatomy/mutability/KEEP CURRENT/finalize
- [x] Spot-mutation tester step + help mutation example
- [x] Verifier template: escalation intent, checklist-first, additive mandates, harness bootstrap, contract-form, budget honesty
- [x] Verification ledger: anatomy, spec-quality box, KEEP CURRENT, finalize gate, verifier handoff ledger lines
- [x] Polish: import toast reason, awd:run repo name, truncation investigation (not reproducible in-app, evidence recorded)
- [x] Owner-only retargeting: resolver, step hint, beat, sidebar/help/SDK/openSpec/Explain wording, additive sentence
- [x] Repo CLAUDE.md
- [x] Tests: 20 new + deliberate migrations; full suite green
- [x] verification-instructions.md amendment (Current behavior + History + index intent)
- [x] Finalize: record, index entry, timeline lines
- [x] Docs sweep (item 9, post-finalize addendum): README, TECHNICAL, help modal cover runs 2-3 + this wave

## Verify

- `./run-tests.sh` -> PASS 1471/1471 (re-run green after the docs sweep; the help modal is test-covered and no pins needed migration)
- Original wave verification: `./run-tests.sh` -> PASS 1471/1471 (baseline 1447 + 20 new in suite 12e + net 4 from the owner-resolution migration; zero regressions).
- `git grep -niE 'XX-[0-9]|REDACTED|REDACTED|REDACTED|REDACTED|REDACTED|XX-[0-9]|XX-[0-9]' -- index.html tests.html CLAUDE.md` -> exit 1 (CLAUDE.md documents the command itself via the pattern in a code span; scoped check on content matches confirms only the rule text). No em dashes in any addition.

## Gotchas / non-obvious

- Removing a const from index.html breaks the tests.html exposure block mid-chain, which makes UNRELATED suites fail with "X is not a function" - the failure signature looks like a load error but node --check passes. Migrate the exposure line in the same edit as the const.
- The 12e chain() helper calls resetState() internally - set durable/memory toggles AFTER building the workflow, not before.
- genDurableRecordProtocol does not itself check state.durableRecord (gating lives at the generator call sites) - protocol-content tests can call it directly regardless of toggles; emission-silence tests must go through the generators.
- The additive-mandates sentence appears in FOUR places by design (owner step hint, orchestrator beat, verifier template, help) - tests pin the step hint and template forms.

## History

- 2026-07-03: created (by agent-craft-batch)
- 2026-07-03: largest-executable-slice rule added to the verifier evidence ladder + test pin (director refinement, post-finalize dated addendum) (by agent-craft-batch)
- 2026-07-03: loadSavedWorkflow gains the Replace confirm + undo point (parity with preset load; source invariant migrated 6 -> 7 sites) (by agent-craft-batch)
- 2026-07-03: addendum - item 9 docs sweep landed post-finalize (README/TECHNICAL/help coverage for runs 2-3 and this wave, in the repo voice); two pre-existing TECHNICAL en dashes fixed in passing (by agent-craft-batch)

## Update 2026-07-03: largest-executable-slice rule (director refinement)

The verifier's evidence ladder gains a middle rung between execute-everything and trace-only: when the whole system cannot run, exercise the largest slice that CAN (call the changed function directly, throwaway harness, the one locally-runnable endpoint, component in isolation), expanding minimally beyond the changed surface when blast radius warrants - judgment stated in the report; trace-only is taken one criterion at a time, never wholesale. Test-pinned in the verifier template suite. Suite 1471 -> 1472.

## Update 2026-07-03: saved-workflow load parity (director catch)

`loadSavedWorkflow` replaced a non-empty canvas with no confirm and no undo point while every sibling destructive-replace (preset, Auto Workflow, New Workflow) had both. Now: the same `withConfirm` Replace guard (blue primary per the color-semantics ruling - undoable replace, modal is the caution signal) gated on `nodes.length > 0`, plus a `pushUndo()` before deserialize. Empty canvas asks nothing. Tests: vetoable + undo-point + empty-canvas-silent; the six-site `withConfirm` source invariant deliberately migrated to seven with the new site named. 1472 -> 1474.

## Outcome

Agents now have a pragmatic three-tier channel for pre-existing defects (fix blocking, fix trivially-in-path with real coverage, record the rest - never work around); testers prove their tests can fail; the verifier is an explicitly stronger escalation tier with checklist-first auditable evidence; every verification act lands in a durable append-and-tick ledger where blocked required checks stay visible forever; repo-mandated checks route to exactly one owning step and always add to (never replace) that step's own method; and the repo carries binding agent rules in CLAUDE.md. index.html + tests.html + CLAUDE.md + one record amendment; 1447 -> 1471 green.

## Built with (provenance)

Wave `agent-craft-batch`: executed directly by Claude (Fable) as a single implementing fork under the director's live direction, with three mid-wave director refinements relayed by the orchestrator (owner-only routing; mandates-are-additive; repo-mandated terminology). Spec assembled from the three dogfood runs' audit evidence. Grounded on the verification-instructions, dogfood-run-fixes, and tool-suggestion-semantics records.

## Links

- Grounds on / touches: grounds on `.workflow/verification-instructions.md` (retargeted), `.workflow/dogfood-run-fixes.md` (protocol wiring patterns), `.workflow/tool-suggestion-semantics.md` (suggestions-never-limits); amended `.workflow/verification-instructions.md` (owner-only routing - Current behavior updated in place, History line appended, index intent line rewritten, status stays current).
- Branch: main (uncommitted working tree for the director's review).
