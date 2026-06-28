# Durable record index

Scan-then-open: read this index first, match an entry against the files or capability your change touches, then open only the matched record(s). One entry per record, grouped by a stable capability slug.

## openspec-schema-export

- record: .workflow/openspec-schema-export-and-roundtrip.md
- intent: export a designer workflow as a valid OpenSpec (@fission-ai/openspec) custom schema (one artifact per WORK node - agent or task: id<-label, instruction<-prompt/spec+forwarded config/gate-loop/join intent, requires<-upstream-work edges, template per artifact, apply block) AND a lossless round-trip import - a `# awd:meta` comment carries the full serializeWorkflow() JSON so re-import reuses the existing deserializeWorkflow (no YAML parser). Additive 6th export ("OpenSpec" button in the Export area, NOT a tab, NOT a fork); review-loop back-edges dropped so requires stays a DAG. WYSIWYG-completeness: every node type reflects into the schema body - tasks become artifacts (description+acceptance), output nodes become apply deliverables (PR/commit/report/docs+branch/target), input source+detail go into the description, parallel any/race join is described in branch prose; agent model/tools/maxTurns ride as instruction intent (no native slot). Export is a real `.zip` of the `openspec/schemas/<name>/` tree (dependency-free store-only writer) so it drops into a repo and validates (templates are required on disk).
- files: index.html (REMOVABLE block: openSpecSlug/openSpecYamlBlock/openSpecParallelJoinNote/openSpecStepIntent/openSpecInstruction/openSpecContextBlock/openSpecOutputLine/openSpecUpstreamWork/openSpecExtractMeta/OPENSPEC_ROLE_GROUP+OPENSPEC_RECORD_SECTIONS/openSpecRecordSections/openSpecTemplate/buildOpenSpecSchema/openSpecCrc32/openSpecZip/exportOpenSpecSchema + the openspecExportBtn button + importWorkflowFile awd:meta+zip branches + Import accept widened), tests.html ("OpenSpec schema export" describe, 24 tests, + win-bridge)
- status: current | date: 2026-06-28 | note: 1120/1120; validated vs real `openspec schema validate` 1.4.1 (linear/parallel/decision/task + role-mix export PASS; round-trip body-lossless + re-export PASS; templates are required on disk -> hence the .zip, stamped with real local time). Templates are role-aware AND node-specific record skeletons (handoff structure; skeptic mirrors the VERDICT contract; tasks get a prefilled acceptance checklist; each encodes graph position + multi-repo checklist + gate readiness) - not empty stubs. Core untouched (5 generators, getDepNodes); reuses core inputSourceHint/strategyJoinPhrase for WYSIWYG parity. Deferred: FOREIGN-schema import (needs a YAML-subset parser, own ticket). Repo Context Paths (rules+product-docs) forwarded into every artifact instruction + apply.

## durable-record-cadence

- record: .workflow/durable-record-transcribe-handoff.md
- intent: lighter half of backlog #2 - make the orchestrator's per-step durable-record update a TRANSCRIPTION (each step asked to end its report with DONE: items + STATUS: one-line; orchestrator transcribes) rather than a re-derivation. Single additive bullet in genDurableRecordProtocol KEEP CURRENT; gated on Keep Durable Record (off = absent); Ground-in-Prior-Records unaffected
- files: index.html (recordHandoffHint() helper + 6 per-agent injections [genWorkflow x2, genSubAgents, genAgentTeams, genClaudePrompt x2] + reconciled KEEP CURRENT bullet in genDurableRecordProtocol), tests.html (recordHandoffHint bridged; v2.4 + v2.5)
- status: current | date: 2026-06-21 | builds-on: .workflow/durable-record-per-step-cadence.md | note: 1083/1083; FULLER agent-side version - the reliable actor (each agent) emits DONE/STATUS via one reused gated fragment, orchestrator transcribes (reconciled from the orchestrator-only half). Injected via the step-hint pattern (not the postamble, which is only 2 generators). Gated on durableRecord (off=absent, tested); SDK not wired (no step-hint pattern + removal candidate). Heavier interleaved per-step beats (backlog #2 option A) still queued as fallback, to be validated by a build-task dogfood

## handoff-context-reliability

- record: .workflow/handoff-context-reliability.md
- intent: two multi-input-handoff reliability fixes from the audit dogfood - (1) genericize PROMPTS.reportBuilder so it is reviewer-count agnostic (drop hardcoded security/quality/performance/architecture dimensions; conditional per-area breakdown only "where multiple reviewers covered distinct areas"); (2) tag dependency-reference lines with the upstream agent TYPE via new getDepsWithType ("Label (Type)") so a downstream step knows the ROLE behind each output, not just the name - applies to ALL steps, not just reviewers
- files: index.html (getDeps refactor -> getDepNodes + getDeps[unchanged] + getDepsWithType; 7 display-site swaps; PROMPTS.reportBuilder), tests.html (+3 tests), README.md/TECHNICAL.md
- status: current | date: 2026-06-21 | builds-on: .workflow/audit-of-generated-prompt-machinery.md | note: 1080/1080; getDeps contract unchanged (validation untouched); static conditional clause chosen over dynamic generation (cannot degrade the swarm - its inputs ARE the dimensions); genAgentSDK unaffected (no markdown dep lines; removal candidate)

## generated-prompt-audit

- record: .workflow/audit-of-generated-prompt-machinery.md
- intent: read-only audit of the five generators' toggle/feature wiring parity, durable-record cadence, and cross-generator consistency - run as an EXECUTION-dogfood (an Auto Workflow generated workflow, orchestrated end-to-end to surface gaps in the designer's own generated prompts). Deliverable: .workflow/audit-of-generated-prompt-machinery-report.md
- files: index.html (5 generators + shared hint helpers), tests.html (parity suites); NO code changed (read-only)
- status: current | date: 2026-06-21 | note: audit result = 4 prose generators in lockstep, genAgentSDK the sole divergence (10 helpers inline + 4 missing toggle injections + degraded durable-record cadence; NEW: consume-records SDK comment already drifted, untested). Confirms backlog #2 (cadence) + #4 (SDK gaps). Workflow-gaps found by running it: generic role-task vs the actual ask, LSP steps on a single-file app, Report-Builder swarm-template on a 1-reviewer workflow, durable-record protocol does not fit a read-only audit, no dead-step recovery guidance (Step 2 agent died on an API error; orchestrator recovered from this record)

## input-source

- record: .workflow/input-source-freeform-default-and-jira-depth.md
- intent: simplify the Input Source selector to framing-only (Freeform default / User Story / PRD - dropped the two no-op options Jira Ticket + Custom) and route Jira into a richer AUTOMATIC, content-driven experience. Jira handling was never on the dropdown - an Atlassian URL (bare or inline) triggers atlassianTicketFetchHint; enriched that up-front resolution to pull description+acceptance criteria, parent epic, sub-tasks, blocking/linked issues, and recent comments so the orchestrator's ORIGINAL PLAN reflects the full picture
- files: index.html (NODE_DEFAULTS input source jira->freeform; configSelect 4 opts->3; generateFromStory input->freeform; App Source preset custom->freeform; atlassianTicketFetchHint depth enrichment - pinned phrase `resolved ticket is the spec` preserved), tests.html (source-framing tests rewritten: freeform-default silent + legacy jira degrades silent; + Atlassian resolution-depth test), README.md + TECHNICAL.md (Input Source)
- work-item: follow-on from node-config + input-source UX discussion | status: current | date: 2026-06-20 | builds-on: .workflow/node-config-options-drive-output.md | note: 1076/1076; bare-key auto-detection deliberately avoided (false-positives COVID-19/UTF-8 - keyed off Atlassian URLs); legacy jira/custom values degrade to silent (single user, no migration); probe-verified bare+inline URL deep resolution + clean plain text

## node-config-output

- record: .workflow/node-config-options-drive-output.md
- intent: make three inert node config controls drive the generated prompt - Parallel `strategy` (join semantics in all 5 generators; SDK maps any/race to asyncio.wait FIRST_COMPLETED, race cancels pending), Task nodes (were dropped wholesale; now a Tasks section with description + `Done when:` acceptance), Input `source` (story/prd add a one-line framing hint; jira/custom stay silent). Each option's default is byte-identical; new behavior fires only on a non-default value
- files: index.html (helpers strategyJoinPhrase/forkStrategyOf/taskSectionLines/taskSectionComments/inputSourceHint; 5 strategy sites + 5 task-emission sites + 2 source-hint sites in requirementsBlock & genAgentSDK), tests.html (4 describe blocks / 12 tests), README.md + TECHNICAL.md (Task/Parallel/Input node config + "Node config that drives output")
- status: current | date: 2026-06-20 | note: 1064/1064 (was 1052); no preset/Auto Workflow creates Task nodes or uses story/prd source, so all existing output is byte-identical (existing suite + new baseline tests confirm); Parallel/Input `description` deliberately NOT emitted (content already carried globally - would duplicate + regress); surfaced the separate Auto Workflow no-implementer gap (this task's own auto-generated workflow was discarded for having no builder)

## adversarial-review

- record: .workflow/generic-adversarial-critic-agent-with-one-click-attach.md
- intent: a generic refute-first `adversary` agent role (one template + role-aware lens + strict materiality bar: default PASS, NEEDS REVISION only for Critical/High material defects, never nitpicks) plus a one-click context-menu action that attaches/detaches a critic + Decision + back-edge revise loop on any Agent/Task node in a single undoable step, reusing the existing Decision/maxRevisions loop so all five generators render it unchanged
- files: index.html (AGENT_TYPES +adversary, AGENT_TYPE_PROMPT_MAP, ADVERSARY_LENSES + ADVERSARY_LENS_BY_ROLE + buildAdversaryPrompt, getEffectivePrompt/classifyAgentPrompt adversary branch, attachAdversary/detachAdversary/toggleAdversarialReview/hasAdversaryAttached/canAttachAdversary via batchUndo, ctxAdversary markup + showContextMenu, feature + documentation preset demos), tests.html (5 new suites / 23 tests; AGENT_TYPES length 11->12; feature 4->5 agents; documentation memory-enabled; AGENT_TYPE_PROMPT_MAP added to win.* bridge)
- status: current | date: 2026-06-18 | note: independent review PASS; lens travels via config.adversaryRole (parallels writer/writingStyle); demoed sparsely in 2 presets (Feature->Planner = plan, Documentation->Doc Writer = docs); deleting a target leaves its critic+decision orphaned; debate panel deferred. SUPERSEDED-IN-PART by verifier-and-review-loop-family.md (2026-06-19): the display name became "Skeptic", markers became reviewLoopFor/reviewLoopKind/reviewLoopDecisionFor, and the attach was generalized into a kind-parameterized family - the behavior here is unchanged, see that record for current code.

- record: .workflow/verifier-and-review-loop-family.md
- intent: a second one-click review kind, a Verifier that PROVES the outcome meets the objective with evidence (run it, call the API, drive a browser, follow doc steps) - distinct from the Skeptic which critiques by inspection; plus generalizing the one-click attach into a kind-parameterized review-loop family (REVIEW_LOOP_KINDS + generic functions/markers) so a third kind is trivial; plus renaming the Skeptic's display (id stays 'adversary')
- files: index.html (AGENT_TYPES Skeptic rename +verifier=13, AGENT_TYPE_PROMPT_MAP +verifier, PROMPTS.verifier, REVIEW_LOOP_KINDS + attachReviewLoop/detachReviewLoop/toggleReviewLoop/getReviewLoop/hasReviewLoop/canAttachReviewLoop + 5 back-compat aliases, ctxSkeptic+ctxVerifier + showContextMenu setReviewItem, feature+documentation preset markers/labels), tests.html (+16 tests: verifier role/prompt/family; length 12->13; Adversary->Skeptic; marker renames)
- work-item: backlog #7 follow-on | status: current | date: 2026-06-19 | builds-on: .workflow/generic-adversarial-critic-agent-with-one-click-attach.md | note: 697/697 tests; independent reviews PASS (x2); verifier has NO lens (one strong default prompt, method self-selected per artifact); verifier gets Bash+WebFetch; one review loop per node; review nodes (Skeptic/Verifier) cannot be review targets; demoed in ui_component preset; ALSO includes the reroute feature (setReviewLoopBackTarget + a dropdown on the review-loop decision to re-point the failure back-edge to any work node, edge-only/no new state, canvas redraws live)

## auto-workflow-detection

- record: .workflow/auto-workflow-default-to-build-guard.md
- intent: a demote-only "default-to-build" guard in generateFromStory so a read-only/non-coding shape (research/review/analysis/test/documentation -> no implementer) is chosen ONLY when the task asks to PRODUCE a read-only deliverable; build tasks whose acceptance criteria are thick with test/doc vocabulary keep their implementer. Surfaced by dogfooding (the auto-generated workflow for the node-config task had no builder). Position-independent (deliverable markers match anywhere; first ~240 chars weigh more), slants to code on ties, can never promote build->read-only
- files: index.html (generateFromStory: NON_CODING guard block w/ READONLY_MARKERS + BUILD_MARKERS + position-weighted strength + demote-to-generic; no CATEGORIES/PRIORITY/shape changes), tests.html (IMPLEMENTERS const; build-shape structural invariant in the fuzz labeled-intent loop; "default-to-build guard" suite +7), README.md + TECHNICAL.md (Workflow Generation guard, replaced stale "leads with the imperative verb")
- work-item: follow-on from node-config dogfood | status: current | date: 2026-06-20 | builds-on: .workflow/auto-workflow-scoring-and-fuzz.md | note: 1071/1071 (was 1064); converged in 2 empirical iterations (dropped "job" build-noun false positive caught by fuzz; test markers tightened to authoring-only so "test suite passes" AC != test intent); demote-only => 289 fuzz read-only cases unchanged; key crux = test acceptance vocabulary is NOT a read-only signal, only "write/add tests" authoring is

- record: .workflow/auto-workflow-scoring-and-fuzz.md
- intent: ultrathink improvement of Auto Workflow (`generateFromStory`) intent detection + Skeptic/Verifier integration + a property-based fuzz harness. Keeps generating BESPOKE workflows (not preset-picking). Fixed verified mis-detections (plurals missed `\bword\b`; no research/review intents; review requests built code). Added: inflection-tolerant keywords; 2 new READ-ONLY intents research (spike->report) + review (audit->report) with leading-verb detection so an imperative wins but mid-sentence "audit logging"/"evaluates X" stays weak; PRIORITY tie-break; Skeptic-on-Planner (standard/complex) + Verifier-on-builder (complex, single builder) via inline wrapReview (no batchUndo); detection toast with near-tie warning; denoiseForScoring strips real-Jira boilerplate (Logistics/CI/Release-pipeline sections, "Database Changes: None") before scoring so a real ticket is not hijacked to DevOps/data
- files: index.html (generateFromStory: CATEGORIES 10->13 (+analysis intent: measure/forecast/cost->read-only report; weakened bare "X vs Y" so a list separator no longer hijacks to research) + inflection + research/review + leading verbs, PRIORITY tie-break, isReadOnlyIntent planner-skip, research/review shapes + selfContained tail guard, primaryBuilder, wrapReview Skeptic/Verifier, toast; Help "Under the Hood" line), tests.html (Auto Workflow fuzz: ~242 labeled + 7 traps + 40 gibberish = ~289 cases; structural invariants; toast assertion), README.md + TECHNICAL.md (Workflow Generation)
- status: current | date: 2026-06-19 | note: 1049/1049 (was 725); read-only intents emit report + zero code-writers (asserted); api still has no dedicated shape (backend Implementer, Tier 3 deferred); verified by headless probes + fuzz

## presets

- record: .workflow/swarm-presets-review-and-delivery.md
- intent: renamed the read-only "Agent Swarm" audit preset -> "Review Swarm" (key stays `swarm`), and added a new showcase preset "Delivery Swarm" (key `delivery_swarm`) - an intricate end-to-end build (20 nodes / 11 agents) that demonstrates the full toolkit in one flow: two parallel fan-outs (Discovery 3-way, Build backend+frontend), the Skeptic doubting the Lead Planner early, the Verifier proving the Integrator late, a final review gate, and tests. Output format `code` (Leave Uncommitted); no preset uses pr.
- files: index.html (4 new house-style PROMPTS codebaseCartographer/requirementsAnalyst/priorArtResearcher/integrator; sidebar items rename+add; delivery_swarm builder; presetPlaceholders.delivery_swarm), tests.html (delivery_swarm count=11 + review-loop suite: Skeptic on planner, Verifier on integrator, 0 dangling, 4 parallel nodes), README.md + TECHNICAL.md preset rows
- status: current | date: 2026-06-19 | note: 724/724; headless smoke clean (0 dangling, no blank prompts, all 5 generators render); reused the Skeptic/Verifier construction pattern from the feature + ui_component presets; naming open to Blue (he floated "Agent Swarm Review"); display labels are independent of the internal keys

## autosave-persistence

- record: .workflow/autosave-toggle-sync.md
- intent: a toggle change now refreshes the awd_autosave workflow snapshot (savePrefs -> autoSaveWorkflow), so a stale snapshot can no longer override a just-saved toggle on reload; fixes the Durable Record checkbox unchecking itself on refresh
- files: index.html (savePrefs +autoSaveWorkflow call), tests.html ("Autosave stays in sync with toggle changes" suite + export parity)
- status: current | date: 2026-06-16 | note: bug only manifests when an autosave snapshot exists (a workflow with nodes); reproduced on the deployed build

## consume-prior-records

- record: .workflow/make-ground-in-prior-records-use-the-full-three-tier-lookup.md
- intent: teach the READ-side grounding guidance the full three-tier lookup - consumeRecordsHint (shared, inherited by all four prose exporters) gains one bullet naming `_timeline.md` (recency, newest-first) + `_index.md` (relevance) and stating the order timeline -> index -> record, judgment-framed ("when recency matters": regression, onboarding, resuming), with `_index.md` still the default entry; the drifted genAgentSDK inline `#`-comment variant brought to parity. Closes the read/write asymmetry where `_timeline.md` was written but never consulted. Write side (genDurableRecordProtocol) untouched.
- files: index.html (consumeRecordsHint timeline bullet + genAgentSDK consume comment), README.md, TECHNICAL.md, tests.html (+8 tests: three-tier order/wording, judgment framing, recency use-cases, all-four-prose-exporter presence, SDK parity, OFF absence, no-fence hygiene)
- status: current | date: 2026-06-23 | builds-on: .workflow/agent-sdk-ground-in-prior-records-gap.md | note: 1095/1095 green; gated on consumeRecords (OFF unchanged); OFF-absence tests also disable durableRecord since the write side emits `_timeline.md` independently. First record to also seed `.workflow/_timeline.md`.

- record: .workflow/agent-sdk-ground-in-prior-records-gap.md
- intent: give genAgentSDK the consume-records (ground-in-prior-records) guidance it lacked - a gated inline Python-comment banner mirroring the SDK's existing mcpAtlassian/mcpCodeSearch blocks; closes the read/write asymmetry the toggle-wiring audit surfaced (SDK wrote records but never grounded in them)
- files: index.html (genAgentSDK consumeRecords banner ~6557-6568), tests.html ("Export: genAgentSDK" suite +4)
- status: current | date: 2026-06-16 | note: surfaced by the toggle-wiring audit; other SDK gaps (clarifyFirst, Datadog, per-step code-search) remain

## orchestrator-identity

- record: .workflow/orchestrator-identity-format-aware.md
- intent: make a generated prompt unambiguous about its format so it is not mis-run (e.g. Sub-Agents as Agent Teams) - orchestratorIdentity(fmt) tracks the format in the identity prose (threaded into consumeRecordsHint + genDurableRecordProtocol), plus an always-on executionModelDirective(fmt) injected early in all five generators that names the run model and forbids the wrong alternatives; also softened a colloquial "teammate" to "colleague" in the durable-record protocol
- files: index.html (orchestratorIdentity + executionModelDirective + consumeRecordsHint(fmt) + genDurableRecordProtocol(fmt) + 8 threaded call sites + 5 directive injection sites), tests.html (export parity + "Orchestrator identity is format-aware" + "Execution-model directive" suites)
- status: current | date: 2026-06-16

## code-search-mcp-option

- record: .workflow/code-search-mcp-awareness-in-agent-role-prompts.md
- intent: per-agent code-search-MCP awareness (gated codeSearchStepHint mirroring datadogStepHint) injected into 8 planning/implementing/navigating roles at the six datadog sites; plus a complementary-not-fallback reframe of the four code-search blocks (standing/Refine/Plan/SDK banner)
- files: index.html (CODE_SEARCH_STEP_ROLES + codeSearchStepHint + six injection sites + codeSearchHint clause + Refine/Plan/SDK-banner reframe), tests.html (export parity + "Code search step awareness" suite + tightened codeSearchHint test)
- status: current | builds-on: .workflow/make-sourcebot-option-general-and-called-code-search-mcp.md | date: 2026-06-15

- record: .workflow/make-sourcebot-option-general-and-called-code-search-mcp.md
- intent: generalize the single "Sourcebot" toggle into a tool-agnostic "Code search (MCP)" option (UI label, injected hint, exporters, docs)
- files: index.html (codeSearchHint + mcpCodeSearch toggle wiring + the four exporter injection sites + two inline hint blocks + SDK comment banner), tests.html, README.md, TECHNICAL.md
- status: current | date: 2026-06-13

## durable-record-protocol

- record: .workflow/write-a-design-overview-of-the-durable-record-system.md
- intent: documentation-only design overview of the durable-record system for a new maintainer - a new TECHNICAL.md subsection covering the four parts (the per-record durable record, `_index.md` relevance lens, `_timeline.md` recency lens, the generated `genDurableRecordProtocol` write-side + `consumeRecordsHint` read-side), the three-tier lookup (timeline -> index -> record), and the six design decisions with their recorded rationale + rejected alternatives (separate timeline file, finalize completion gate, three-tier grounding, transcribe-vs-re-derive, finalize compression, write-index-at-finalize-as-projection). No code change
- files: TECHNICAL.md ("### Durable Record System: Design Overview" under "## Memory Protocol", after the existing "### Durable Record (committable artifact)" reference)
- status: current | date: 2026-06-23 | note: grounded in the durable-record-protocol + consume-prior-records + durable-record-cadence records; Planner -> Researcher (all claims source-verified, zero corrections) -> Doc Writer -> Skeptic (PASS); complements the existing terse wiring reference rather than duplicating it; describes the timeline MECHANISM (the live `_timeline.md` has one dated entry, introduced 2026-06-23)

- record: .workflow/provenance-captures-workflow-shape.md
- intent: enrich the durable record's "Built with (provenance)" line to capture the workflow SHAPE (ordered roles + topology: decision gates/revision caps, parallel forks, Skeptic/Verifier review loops incl. attach points + reroute targets), the notable non-default config (models, significant tool grants, turn limits), and the run context (toggles/MCPs/repo-context) - capped to shape-and-knobs, NOT a full dump (the exported .json/Handoff carry the verbatim pipeline). Answers "should the durable doc include the workflow spec" = yes, as compact provenance
- files: index.html (genDurableRecordProtocol Built-with bullet ~2771; prose-only, protected phrases preserved), tests.html (+1 provenance-shape test)
- status: current | date: 2026-06-19

- record: .workflow/cadence-granularity-and-clarify-sensitivity.md
- intent: two cold-run tunings - KEEP CURRENT now requires ticking EACH checklist item per step (covers one Implementer finishing many items, tick-now-not-at-finalize); and the clarify gate leans toward asking on high-value forks (null/empty/below-threshold, conflicting behavior, contract shape) with a low-stakes escape
- files: index.html (genDurableRecordProtocol KEEP CURRENT bullet + clarifyFirstHint bullet), tests.html (+2)
- status: current | date: 2026-06-16 | builds-on: .workflow/durable-record-per-step-cadence.md

- record: .workflow/durable-record-per-step-cadence.md
- intent: force an enforced per-step KEEP CURRENT cadence (overwrite Current state/next action, tick checklist, fold step output by action - do not batch to finalize) plus an explicit before-Step-1 kickoff, so an interrupted large run is resumable; surfaced by a real run that deferred all record-writing to the end
- files: index.html (genDurableRecordProtocol - new KEEP CURRENT section + kickoff sharpening), tests.html (Durable Record protocol-content +2)
- status: current | date: 2026-06-16 | related: .workflow/compress-durable-record-at-finalize.md (sibling refinement of the same protocol)

- record: .workflow/compress-durable-record-at-finalize.md
- intent: finalize step compresses Verify/Gotchas into a clean spec (no per-agent transcript); surface area marked provisional until grounded
- files: index.html (genDurableRecordProtocol - finalize guidance + surface-area guidance), tests.html (Durable Record protocol-content tests)
- status: current | date: 2026-06-13

## repo-context-paths

- record: .workflow/multi-repo-claudemd-loading.md
- intent: fix the multi-repo CLAUDE.md gap - CLAUDE.md/.claude/rules auto-load ONLY for the launch dir (verified vs Claude Code docs), so secondary repos' rules were silently ignored and our prompts wrongly said "CLAUDE.md already auto-loaded, do not re-read". Now the multi-repo block has agents read each repo's CLAUDE.md/CLAUDE.local.md/.claude/rules before changing it + names the `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir` setup; rulesPathsHint/productDocsHint + sidebar text made repo-aware
- files: index.html (repoBlock ~2103, rulesPathsHint ~1096, productDocsHint ~1116, sidebar text ~467/471), tests.html (+2, updated sidebar assertion), README.md (multi-repo gotcha subsection)
- status: current | date: 2026-06-19 | note: listed Rule/Product paths were already resolved per-repo (correct); only the CLAUDE.md auto-load assumption was wrong. Verified via claude-code-guide vs memory.md + sub-agents.md. ALSO added per-repo rule SCOPING (repoBlock step 4): each repo's CLAUDE.md/.claude/rules govern only that repo's work, the auto-loaded launch-repo CLAUDE.md is scoped to the launch repo (not a global default), conflict -> repo-being-changed wins. Behavioral scoping, NOT hard isolation (launch CLAUDE.md stays in session context; a prompt cannot unload it)

- record: .workflow/repo-context-paths.md
- intent: two settings inputs (Rules/constitution paths + Product docs PRD/ADR) that inject repo-scoped binding-rules and product-goals guidance into generated prompts; flat lists, sticky, per-repo anti-contamination in the hint
- files: index.html (rulesPathsHint + productDocsHint + the two chip-list inputs + savePrefs/restorePrefs + sticky clearCanvas + five injection sites), tests.html, README.md, TECHNICAL.md
- status: current | date: 2026-06-13

## agent-prompt-config

- record: .workflow/agent-prompt-edit-ux.md
- intent: refine the Agent Prompt edit UX - compact textarea that expands on focus, "Edited from the {Role} template" wording + a two-box (Agent Prompt vs Custom Notes) hint, and an undoable Reset-to-template control
- files: index.html (agentPromptStatusBlock + the agent-branch focus/blur and reset binders + the Agent Prompt/Custom Notes configTextarea calls + CSS), tests.html
- status: current | supersedes: .workflow/strengthen-agent-prompts.md | date: 2026-06-13

- record: .workflow/strengthen-agent-prompts.md
- intent: node-config UI shows the attached role template (status line + inline read-only preview + ~6-row textarea) so agents stop looking thin; plus two additive lines (minimality + record-assumptions) to the coder/implementer template
- files: index.html (classifyAgentPrompt + agentPromptStatusBlock + updateConfig agent branch + configTextarea attrs param + PROMPTS.implementer), tests.html
- status: superseded | superseded_by: .workflow/agent-prompt-edit-ux.md | date: 2026-06-13

## delivery-commit-pr

- record: .workflow/output-format-delivery-model.md
- intent: make delivery (commit/push/PR/report/docs) a clean function of the Output node format, removing the separate Delivery toggle. PHASE 1 + PHASE 2 DONE (uncommitted), 723 tests. Delivery is fully format-driven via deliveryBlock(level) dispatch (priority pr>commit>report>docs>code). 5 formats: Leave Uncommitted (code, default, renamed from "Code Changes", value unchanged) | Commit (commit+push, no PR) | Pull Request | Report (writes a real report, never commits) | Documentation (writes real docs per project conventions, never commits). Branch Name shows for pr+commit, Target Branch for pr only. No preset uses pr; performance stays report.
- files: index.html (deliveryBlock/deliveryFormats/deliveryTitle/commitBlock/reportBlock/docsBlock + format dropdown w/ commit + branch-field gating + 5 generator sites use deliveryBlock), tests.html (delivery suite = 5 generators x 5 formats matrix + dispatch/fallback/commit/deliversPr units), TECHNICAL.md (Delivery section + security table + file tree), README.md (Output section)
- status: current | date: 2026-06-19 | note: code changes happen regardless of output node (no output -> leave uncommitted); a single Report output handles code+report (e.g. performance); KEY: keep Code Changes (== no-output default)

## ui-labels

- record: .workflow/workflow-context-agent-context-rename.md
- intent: rename the two free-form context fields as a scoped pair - "Implementation Plan" -> **Workflow Context** (injected into every agent) + a scope sub-label and a hairline separator before the Generate Plan Prompt button; "Custom Notes" -> **Agent Context** (this node only). Generated output section "## Implementation Plan (starting guidance)" -> "## Workflow Context (...)" in all 5 generators. Dissolves the box-vs-button "Plan" overlap + reflects that the field is general context (Blue pasted a Datadog-MCP hint, not a plan). Internal ids/keys (planInput, getPlan, plan, config.notes) UNCHANGED for serialization compat
- files: index.html (Workflow Context sidebar block + Agent Context node field + 5 generator headers + Help-modal refs), tests.html (output-section + helper assertions), README.md (2 refs), TECHNICAL.md (3 refs)
- status: current | date: 2026-06-19 | builds-on: .workflow/button-label-clarity.md | note: kept "Generate Plan Prompt" button + "Implementation Planning" plan-prompt title + the tech-spec template's "## Implementation Plan" section; 705/705; browser-verified

- record: .workflow/button-label-clarity.md
- intent: relabel the three "generate" buttons for clarity - `Generate` -> **Auto Workflow** (in-app build, parallels Auto Layout), `Refine Prompt` -> **Generate Refine Prompt**, `Plan Prompt` -> **Generate Plan Prompt**. Two-tier read: Auto Workflow builds now vs the two Generate-___-Prompt helpers make a prompt to run elsewhere. Fixes "Plan Prompt looks like it acts on the Implementation Plan box"
- files: index.html (3 button labels + helper texts + Help-modal "click X" refs, kept the flow-title h3s; one genClaudePrompt help line), README.md (4 refs); tests.html none (705/705)
- status: current | date: 2026-06-19 | note: UI text only, no logic; browser-verified label fit

## in-app-help

- record: .workflow/help-modal-feature-coverage.md
- intent: cover features that had shipped without Help docs + Blue-requested additions. 3 NEW sections (Review Loops [Skeptic & Verifier - what/when/why], Delivery [output-node format model], Handoff [resume-package export]) + enriched Export Formats (real Workflow vs Sub-Agents vs Agent Teams blurb + rule-of-thumb), Recommended Integrations (+Claude in Chrome), and Canvas/Power-User tips
- files: index.html (help-body: 22 h3 sections total - also added How the Prompts Work, Under the Hood, "Which prep step should I use?" [Refine vs Plan vs Clarify], "Multiple Repos & Rules Files" [+CLAUDE.md gotcha/env-var], flywheel framing in Ground), README.md (Refine & Plan: +Clarify cross-ref + rule-of-thumb), tests.html (help-sections assertion +Review Loops/Delivery/Handoff/Claude in Chrome/How the Prompts Work/Under the Hood/Which prep step/Multiple Repos + README footer URL)
- status: current | date: 2026-06-19 | builds-on: .workflow/documentation-updates.md | note: 724/724; headless render confirms 20 sections in order; review-loops section answers Blue's "when/why they're powerful" (Skeptic=reason/inspect on high-stakes steps, Verifier=execute/prove on runnable outcomes, doubt-early-prove-late = defense in depth); "Under the Hood" mirrors only the AUTOMATIC behaviors (Things-You-Might-Not-Notice was already covered by Canvas Tips/Toolbar Features - not duplicated)

- record: .workflow/documentation-updates.md
- intent: refresh the in-app Help modal (the `?` button) to match the current feature set - four new h3 sections (Editing Agent Prompts, Durable Record, Ground in Prior Records, Clarify Requirements First), an input-aware Generate note, and fixing the stale "Shared Memory" wording to the real toggle names
- files: index.html (.help-body div only - four new h3 sections + Quick Start and Power User Tips edits), tests.html (help-sections assertion extended for the four new headings)
- status: current | date: 2026-06-14

## datadog-mcp-toggle

- record: .workflow/datadog-mcp-toggle.md
- intent: add a first-class "Datadog" toggle to the MCP Integrations panel (default off) that, when on, emits an ORCHESTRATOR up-front production-telemetry grounding block - self-gating on relevance + Datadog availability, bounded plan-shaping read, deep query left to the step; mirrors the consumeRecords/clarifyFirst gate blocks (not the per-step codeSearch hint)
- files: index.html (mcpDatadogToggle UI + state wiring like mcpCodeSearch but default-off/clearCanvas-resets-false + datadogGroundingHint() + four generator injection sites + Help note), tests.html (harness export + resetState + 10-test "Datadog grounding gate" suite)
- status: current | date: 2026-06-14

- record: .workflow/datadog-step-escalation.md
- intent: complete the step-side of Datadog grounding - a toggle-gated per-agent hint (datadogStepHint) injected at the six per-agent generation sites for the reason-about-the-system roles {planner, architect, researcher, debugger, tester}, letting them run their own deeper/differently-angled query only when the orchestrator's bounded read is insufficient; removed the hardcoded Datadog line from PROMPTS.investigator so the toggle is the single source of truth (toggle off = no Datadog anywhere)
- files: index.html (datadogStepHint + DATADOG_STEP_ROLES + six per-agent injection sites + PROMPTS.investigator Datadog removal), tests.html (harness export + inverted run-#7 guard + 11-test "Datadog step escalation" suite)
- status: current | builds-on: .workflow/datadog-mcp-toggle.md | date: 2026-06-14

## atlassian-mcp-fortification

- record: .workflow/atlassian-mcp-fortification.md
- intent: make Atlassian guidance toggle-driven without breaking the Jira-URL-as-input flow - split atlassianHint into a URL-driven toggle-INDEPENDENT ticket-fetch block (orchestrator resolves the ticket once as the SOURCE for the plan, MCP-or-browser fallback, no raw-ticket-plus-plan duplication) and a toggle-driven permissive-but-anti-redundant general block; removed the hardcoded "If an Atlassian MCP tool is available" line from 10 PROMPTS templates; softened validateStoryInput so a Jira URL works in every toggle state
- files: index.html (atlassianTicketFetchHint + atlassianGeneralHint replacing atlassianHint + four generators + SDK + Refine/Plan blocks + validateStoryInput softening + 10 template removals), tests.html (harness export + rewritten unit tests + 4x4 scenario suite)
- status: current | date: 2026-06-14 | follow-up: validate on a real Jira issue post-merge

## delivery-commit-pr

- record: .workflow/delivery-section-enhancement.md
- intent: make committing/pushing/opening-a-PR an explicit opt-in (default OFF) via a new "Delivery" sidebar section + commitPr toggle that gates the five prBlock() call sites (noCommitBlock emitted when off); resolves the prBlock-vs-safety-list contradiction. ALSO (Part B, durable-record-protocol capability) restructured genDurableRecordProtocol's finalize prose into an explicit "### FINALIZE" step + a read-only-steps fold-in point.
- files: index.html (Delivery section + commitPr state wiring like mcpDatadog + noCommitBlock + 5 gated prBlock sites + genDurableRecordProtocol FINALIZE restructure), tests.html (+15 tests)
- status: current | date: 2026-06-14 | related: .workflow/compress-durable-record-at-finalize.md (Part B coexists with it - sibling refinements of the durable-record-protocol finalize guidance, no supersession)

## code-conventions

- record: .workflow/test-convention-discovery-by-recency.md
- intent: make test-writing roles match the project's CURRENT test conventions by discovering them from the most recently modified/added test files (git history or newest-by-mtime), borrowing the designSystemAnalyzer's recency pattern. Strengthened conventionsHint para 2 + added the concrete step to tester/testWriter/testSuiteWriter/bugTester/e2eTester. Language-agnostic per Blue (generic "structure and phrasing of test cases", no JS describe/it idiom). Triggered by a generated tester ignoring the project's naming convention
- files: index.html (conventionsHint para 2 ~1081 + 5 test-role templates), tests.html (+1)
- status: current | date: 2026-06-19 | related: .workflow/comment-discipline-no-ticket-ids.md

- record: .workflow/comment-discipline-no-ticket-ids.md
- intent: tighten the always-on comment directive - forbid ticket/issue IDs (Jira keys, PR numbers) + changelog notes in code comments (git already ties code to its ticket), demand brevity / no comments-for-the-sake-of-it (AI slop), keep the JSDoc-on-API-surfaces allowance; reviewer + fixer reinforce it. Triggered by generated code carrying  x3 + TODO() in a JSDoc block
- files: index.html (conventionsHint para 1 ~1079, PROMPTS.reviewer Comments bullet ~1335, PROMPTS.fixer step 9 ~1326; prose-only), tests.html (+3); also ~/.claude/user/preferences.md (global pref)
- status: current | date: 2026-06-19 | builds-on: .workflow/orchestrator-directives-for-code-comments-and-project-consistency.md

- record: .workflow/orchestrator-directives-for-code-comments-and-project-consistency.md
- intent: bake a soft, always-on orchestrator-level "Conventions" directive into generated workflows (prefer self-describing code over comments incl. tests; comment only for complex/why/project-convention; JSDoc for public APIs; when writing tests, match the project's existing test conventions; repo rules/CLAUDE.md override) + a reviewer line flagging narrating/redundant comments
- files: index.html (new conventionsHint() emitted at the 4 prose generators + an unconditional SDK #-comment block, next to codeSearchHint; one PROMPTS.reviewer "comment the why, not the what" line), tests.html (+9 tests)
- status: current | date: 2026-06-14

## atlassian-mcp-fortification

- record: .workflow/requirements-should-not-be-a-bare-uri.md
- intent: per-step "## Requirements" no longer emits a bare ticket URL (which invited every step to re-fetch); a new requirementsBlock(story, heading) helper points steps at the orchestrator-resolved spec + keeps the URL as a labeled reference when isUrlOnly(story), and emits plain-text input unchanged. Reinforces the resolve-once ticket-fetch protocol at the per-step level.
- files: index.html (requirementsBlock helper + the 4 multi-step generator Requirements sites routed through it; Refine/Plan single-agent prompts left as-is), tests.html (+12 tests)
- status: current | date: 2026-06-14 | related: .workflow/atlassian-mcp-fortification.md (complements the orchestrator-side ticket-fetch; no supersession)
