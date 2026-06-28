# Auto Workflow: smarter intent detection + Skeptic/Verifier + fuzz harness

Work item: Blue asked for an ultrathink review of Auto Workflow (`generateFromStory`) to make it pick the best workflow shape for the input, keep it generating UNIQUE workflows (not preset-picking), leverage the Skeptic/Verifier where appropriate, and validate with "a few hundred tests with random fake requirements." Status: DONE (uncommitted; Blue commits). Tests: 1014/1014 (was 725).

## Reframe

Auto Workflow is a weighted-keyword SCORING ENGINE that builds a bespoke shape - it does not pick from presets. Blue confirmed he wants it to stay that way.

## Verified mis-detections (probe before changes)

- "Write tests for the checkout flow" -> generic impl (plural "tests" missed `\btest\b`)
- "Document the public API endpoints" -> code-writing impl (verb "document" not a keyword; "API endpoints" out-scored it)
- "Research Postgres vs DynamoDB" -> code-writing impl (no research intent existed)
- "Review the payment service for security vulnerabilities" -> code-WRITING workflow (no review intent; it would modify code when asked to review)

## Changes (index.html `generateFromStory`)

1. **Inflection-tolerant keywords** - every category regex now tolerates plurals/verb forms (`tests`, `endpoints`, `deploying`, `migrations`, `document`, `optimizing`). This was the single biggest accuracy win (most real inputs are pluralized).
2. **Two new read-only intents**: `research` (research/evaluate/compare/"X vs Y"/"whether to use"/spike/feasibility) -> Parallel(Codebase/Options/Tradeoff researchers) -> Synthesizer -> Research Report (report); `review` (review/audit/assess/"code review"/"review of") -> read-only auditors (+Security/Performance when signalled) -> Report Builder -> Audit Report (report). Both are READ-ONLY (no code-writing agent, format report). Planner/architect layer skipped for read-only intents (`isReadOnlyIntent`). Tail gated with `selfContained`.
3. **Leading-verb intent detection** - research/review (and documentation/refactoring/performance/test verb-phrases) lead with a high-weight `^verb` rule (weight 5 for research/review) so an imperative ("Review the service", "Document the API") wins, while a bare mid-sentence word ("audit logging", "a service that evaluates X") stays weak (1.5) and does NOT hijack a build. Added "X vs Y" and "whether to use" frames.
4. **Principled tie-break** - `PRIORITY` map (security>research>review>data>performance>...>ui>api) breaks score ties instead of object insertion order.
5. **Skeptic / Verifier when appropriate** (Blue's ask) - inline `wrapReview(target, kind)` replicates `attachReviewLoop`'s core re-point WITHOUT batchUndo (batchUndo's finally would break the generate undo batch). Skeptic on the Planner whenever one exists (standard/complex builds); Verifier on the single primary builder for `complex` workflows. Read-only/doc shapes get neither.
6. **Detection toast** - "Auto-detected: <intent> workflow (N agents)" + a near-tie warning ("close call vs X; rephrase or pick a preset").

## Fuzz harness (tests.html, `Auto Workflow fuzz (property-based)`)

- Seeded RNG (mulberry32) for reproducibility. 11 labeled intents x 22 = 242 cases from templates with random fill-ins (neutral subjects, tech names) -> assert the detected `shapeOf` matches the known intent + structural invariants. Read-only intents additionally assert format=report and zero code-writing agents.
- 7 hand-picked TRAP cases that previously mis-fired (implement+"audit logging" -> generic; "service that evaluates X" -> generic; "Build a page to compare plans" -> ui; "Research whether to use GraphQL API" -> research; "Audit X for security vulnerabilities" -> review).
- 40 gibberish inputs -> structural invariants only (graceful fallback, never throws).
- **Structural invariants asserted for every generated workflow**: exactly one input + one output, >=1 agent, no dangling edges, input feeds something, output is reached, no orphan agents, no blank effective prompts, valid output format.
- Total ~289 generated cases. Runtime 2.3s -> 4.9s (acceptable).

## Files

- index.html: CATEGORIES rewrite (12 cats, inflection, research, review, leading verbs), PRIORITY tie-break + isReadOnlyIntent + runnerUp, planner/arch read-only skip + plannerNode, research/review domain branches + selfContained, primaryBuilder capture, tail guard, wrapReview + Skeptic/Verifier calls, detection toast; Help "Under the Hood" line.
- tests.html: fuzz suite + traps + gibberish (~289 cases); updated the generate-feedback toast assertion ("Generated workflow with" -> "Auto-detected").
- README.md (Smart story detection bullet), TECHNICAL.md (Workflow Generation section rewrite).

## Verification

- 1022/1022. Probes confirmed: research->report read-only, review->report read-only (+Security Auditor when signalled), "Document the API"->docs, "Compare X vs Y"->research, billing-implement-with-audit-logging->code build (+Skeptic), complex multi-signal build->Skeptic on Planner + Verifier on builder.

## Realistic Jira-sized ticket validation (Blue's follow-up ask)

Ran 8 fleshed-out multi-paragraph tickets (description + acceptance criteria + technical notes) through the generator and inspected each. 7/8 were clearly reasonable on the first pass: full-stack feature -> parallel Backend+Frontend + Security Review + Skeptic + AC gate; production bug -> Investigator/Fixer + Skeptic + Verifier + regression Tester; performance -> Profiler/Optimizer + report + Skeptic/Verifier; security -> build + Security Review + Skeptic/Verifier; research spike -> read-only research report; audit -> read-only review report WITH Security Auditor + Performance Reviewer (both signalled in the ticket); data migration -> Migration Engineer + Verifier; documentation -> docs output, no code gate. Acceptance-criteria bullets correctly fed the decision-gate condition in every code workflow.

One real issue found + fixed: the TOAST reported the raw `dominant` category, so a ui+api ticket said "UI workflow - close call vs API" even though it correctly built a full-stack shape. Fixed: the toast now reports the ACTUAL shape (DOMINANT_SHAPES gate; ui+api -> "full-stack feature", security -> "security", api -> "API / backend"), and the false near-tie warning is suppressed when ui+api resolves to full-stack by design.

### Real-ticket denoise (follow-up - Blue sent a real fleshed-out Jira ticket)

Ran a real Jira ticket (a mobile background-sync feature, ~350 words with Background/Logistics/Promises/AC/Scenarios/Risks/Open-Questions sections). Findings: (1) GOOD - NO spaghetti; bounded at ~13 nodes / 8 agents regardless of ticket size (the generator caps at the complexity tiers). (2) BAD - the **Logistics boilerplate** ("Build Pipeline: ... CI Build", "Release Pipelines: Android/iOS/Desktop Release Pipeline") hijacked the intent to **DevOps**, and "Database Changes: None (no schema change; no migration)" would falsely signal data - naive bag-of-words counts keywords in pure-metadata/negated sections. The actual work vocabulary (sync/suspend/background/iOS) is not in the keyword set, so the loudest incidental boilerplate word won.

FIX: `denoiseForScoring(text)` strips boilerplate/metadata sections (Logistics, Build/Release Pipelines, Repo, Database/Config Changes, Out of Scope, Risks, Open Questions, Observability, Impacted Areas, etc.) before scoring, keeping the work-statement sections (Background/Objective/Narrative/Promises Made/Acceptance Criteria/Scenarios); safety-net falls back to full text if >70% stripped. Scoring uses denoised text; complexity still uses full text. ALSO removed the noisy weight-1 research rule `(compare|versus|vs|options|alternatives)` -> just `alternatives` (the word "option" as in "the preventSuspend option" was scoring research; compare/vs are already covered by leading-verb + the X-vs-Y pattern). Result: the real ticket now correctly detects a **feature build** (Planner->Architect->Researcher->Implementer->Code Review->decision->Tester + Skeptic on plan + Verifier on implementation), 13 nodes, clean. Privacy: real ticket used for LOCAL testing only - not committed, not in vault; the permanent test is genericized.

### Analysis intent + vs-list fix (2nd real ticket - a Datadog cost-measurement ticket)

Blue sent a 2nd real ticket: pull Datadog log/metric volume, forecast monthly cost per service, document methodology, share with stakeholders. It's a measure-and-report task (no code). Probe: it landed on RESEARCH->report - right OUTPUT type (read-only report) but by ACCIDENT: the billable-category list "log bytes vs indexed events vs custom metrics vs APM vs RUM" tripped the "X vs Y" pattern 4x (+12 research). Also the research AGENTS (Options Researcher, Tradeoff Analyzer) fit loosely - there are no options/tradeoffs, it's measurement.

Fixes: (1) NEW **analysis** intent (13th category) - leading measure/quantify/forecast/estimate + cost/usage phrases (cost analysis|estimate|impact|forecast, capacity planning, "forecast the cost/spend", "estimate the cost/usage/volume", rough estimate) + domain terms (billable, cardinality, throughput, baseline). Shape: Data Gatherer -> Analyst -> Report Writer -> Analysis Report (read-only, format report, never code). PRIORITY 8, isReadOnlyIntent, DOMINANT_SHAPES, SHAPE_NAME 'cost / usage analysis'. (2) **Weakened the bare "X vs Y" pattern** 3 -> 1.5 so a list separator no longer hijacks; a real comparison still wins via the leading compare/evaluate verb (weight 5). Result: the Datadog ticket -> analysis report (proper fit); "Build a settings page with a light vs dark mode toggle" -> UI (not research); "Evaluate Kafka versus RabbitMQ" -> still research. Tests: +analysis fuzz (22) + 2 traps (vs-list-in-UI -> ui, measure-cost -> analysis) + read-only assertion extended. 1022 -> 1046. Privacy: real ticket local-only; tests genericized (no real names/projects).

### Bug-report structure signal (3rd real ticket - a feature-gate-bypass bug fix)

Blue sent a 3rd real ticket: a bug where a feature-gate selector (mirroring a prior fix) was not wired into two completed-tickets consumers, so an "Attachments" entry point still showed. It's a BUG FIX (recreation steps, expected/actual, regression test, "add unit tests"). Probe: it landed on **UI** (Design System Analyzer -> UI Implementer) - wrong. Root cause: "render"/"renders" used in bug-report PROSE ("the component renders the action unconditionally", "renders as before") is a UI keyword (weight 2) and appeared ~3x, inflating UI past bugfix - same class as audit-logging / vs-list (a domain word used descriptively).

FIX (general): added a **bug-report structure** signal to the bugfix category - `steps to reproduce|recreation steps|reproduction steps|repro steps` (3) and `expected results|behaviour / actual results|behaviour` (2). Real bug tickets have this structure and no feature ticket does, so it reliably outweighs incidental domain words. Result: the ticket -> **bugfix** (Investigator->Fixer->Tester + Skeptic on plan + Verifier on Fixer), fmt code, 13 nodes, clean. Hardens detection for every future bug ticket, like denoise did for boilerplate. Test: a genericized bug-report-structured ticket WITH UI noise (toolbar/header/renders) -> asserts bugfix (not UI). Privacy: real ticket local-only; test genericized (no ticket IDs/product/filenames).

### Repetition cap + infra-provisioning vocab (4th real ticket - provision a standalone DB instance)

Blue sent a 4th real ticket: provision a net-new standalone Cosmos DB instance + storage account + env config for a service (an infra/DevOps task). Probe: landed on **API/backend** - wrong. Two causes: (1) repetition inflation - "database" (~6x) and "service" (~8x, from "User Location Service") pumped api up; (2) the infra-action vocabulary ("provision", "storage account", "standalone instance") was not in the devops category at all. (Denoise correctly stripped the Logistics/Release-pipeline section, so devops couldn't lean on those.)

Fixes (both general): (1) **per-rule match cap** - `score += weight * Math.min(matches.length, 3)` so a single rule cannot dominate by repetition (helps "service"/"database"/"render"/"vs" runaway everywhere); (2) **infra/provisioning vocabulary added to devops** - leading provision/deploy/set-up/stand-up/spin-up (4); body provision/standalone instance/storage account/managed instance/access policy (2); connection string/environment config/stage-and-prod (1.5). Result: the ticket -> **devops** (DevOps Engineer + Skeptic on plan + Verifier on DevOps Engineer - the Verifier maps exactly to the ticket's "connectivity validated / smoke testing confirms"). Test: a genericized infra ticket (with stripped pipelines + repeated database/service) -> asserts devops. Privacy: real ticket local-only; test genericized.

### Consolidation/dedup refactor vocab (5th real ticket - a Terraform consolidation refactor)

Blue sent a 5th real ticket (huge, ~1800 words, live Azure subscription GUIDs / DevOps URLs - heavily genericized + local-only): consolidate ~60 duplicated Terraform files across 5 environments to a single root set, "behavioral equivalence" via zero-change plans. It SELF-IDENTIFIES as "This refactoring" with verb "Consolidate". Probe: landed on **DevOps** (the infra/terraform domain vocabulary - "terraform"(3) + "infrastructure" - outscored refactoring). The denoise correctly stripped the giant boilerplate (Impacted Areas, Risks table, Open Questions, Config Changes, Delivery pipelines) and it stayed bounded at 12 nodes (no spaghetti).

This is the FIRST real ticket that was genuinely AMBIGUOUS (an infra refactor - DevOps and Refactor are both defensible), not a clear mis-fire. Fix: added consolidation/dedup vocabulary to the refactoring category (consolidat-inflections + leading verb, deduplicate, single source of truth, behavioural equivalence, duplicate/duplication) - intent-over-domain, and a genuinely useful gap (the category had no DRY/consolidation language). Result: refactoring rose into contention; the ticket now detects **DevOps - close call vs refactor** (the near-tie warning fires), which is the correct behavior for a genuinely ambiguous ticket: pick one, flag the close alternative, let the user switch. Did NOT force refactoring to win (would over-fit + "duplicate charges" in the bug ticket shows bare "duplicate" is ambiguous). Test: a clean consolidation refactor with NO infra noise -> asserts refactoring (locks the vocab without asserting the ambiguous tie). Privacy: real ticket local-only; test genericized (no GUIDs/URLs/repo/team names).

Locked in: a genericized boilerplate-heavy ticket test (denoiseForScoring strips metadata + keeps work statement; the ticket is NOT mis-detected as DevOps/data/review and builds code) + 6 of the realistic tickets as permanent tests (`realistic Jira-sized tickets`): assert shape + Skeptic/Verifier presence on the complex ones + acceptance-criteria text in the gate + read-only intents emit report with zero code-writers. (Note: the Verifier is gated to `complex` complexity, so a moderate-length bug ticket gets a Skeptic only - the test bug ticket was written long enough to be complex and exercise the Verifier path.)

## Notes / future

- `api` still has no dedicated dominant shape (falls to a backend Implementer) - functionally fine, deprioritized (Tier 3).
- Bag-of-words has inherent ambiguity ("write tests for the dashboard component"); handled via leading-verb weight + tie-break + the detection toast as the user's safety net.

## Built with (provenance)

Direct implementation by the orchestrator; verified empirically with headless probes (verify-before-reasoning) and the new fuzz suite.

## Links

Branch: TBD. PR: TBD.
