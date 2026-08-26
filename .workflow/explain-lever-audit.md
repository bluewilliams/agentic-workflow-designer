# Explain lever audit: every OFF row names its lever, docs match the code

Workflow: explain-lever-audit. Branch: main. Status: finalized, committable.

```awd:record
{"slug": "explain-lever-audit", "status": "current", "date": "2026-07-04", "files": ["index.html", "tests.html", "TECHNICAL.md", "README.md"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

The OFF-row principle is uniformly enforced across Explain: every row showing a feature as off or absent names its lever - the exact user action that would turn it on - in plain language, with no internal constant names, no raw agentType ids, and no implementation jargon; config-dependent rows name the sidebar section that holds the config (Repo Context Paths groups, Repositories, MCP Integrations notes, Node Configuration), and by-design states read as design, not errors. ON reasons use the plain UI toggle names their OFF siblings use. The Claude.ai format's Model row is a by-design skip ("carries no model parameter") mirroring its tools rows. Advisor rule (h) fires for the SAME consumer set rule (i) counts (appExplorer type OR either explorer template text), so a legacy researcher-typed explorer without an App Source path gets the setup nudge - (h) and (i) are mutually exclusive over one shared predicate with no third state. TECHNICAL.md, README.md, and the help modal describe the always-present sections, the 16-type alpha-sorted roster, the uiAppExplorer template split, the UI Explorer preset label, the appSourceAccess pref, and all four prompt-status states.

ON rows show the CONFIGURED VALUES and REAL EVIDENCE, never heading placeholders: Repositories names each path @ branch in its reason and unfolds the real repoBlock; App Under Test names path @ branch + access and unfolds appSourceBlock; UI Context and Workflow Context unfold the user's own text (the Requirements-row precedent); both Delivery rows unfold the actual deliveryBlock; the three context-path rows name their configured paths (verification also names inline-notes presence beside its posture); the Memory and Durable-record rows name the live memory path and artifact path; the step Model row names the model in its reason. Evidence previews render light inline markdown via exInlineMd (escape FIRST, then bold + single-backtick code spans only - no block-level pass that could reflow verbatim emitted lines).

## Why and scope

The overnight read-only audit (run after the context-agent-types unit landed) found the OFF-row principle well internalized in the newest rows but violated in older ones: the Datadog and code-search step hints leaked `DATADOG_STEP_ROLES`/`CODE_SEARCH_STEP_ROLES` plus raw agentType ids (the exact defect class the principle was coined from), three rows carried implementation jargon ("caller guards emission", "no maxTurns set", "superset invariant"), six config rows never named their sidebar home, the Claude.ai Model row claimed "always emitted" against a generator that emits no model line, and TECHNICAL.md still described the pre-split world in seven places. Rule (h)'s predicate gap (confirmed by the audit) silently skipped legacy template carriers. Non-goals: advisor letter file-order (cosmetic, (f) deliberately sits below (i) to keep (h)/(i) adjacent to their shared predicate); the audit's "mild" suggestions judged as padding.

## Requirements

1. OFF rows MUST name their lever without internal identifiers.
   - Given a Skeptic node with Datadog on, Then its step-hint OFF reason names plan-shaping roles and the Agent Type lever, never the internal set name. (Test: role gating: a Skeptic skips the Datadog hint by ROLE; a writer skips code-search by ROLE - migrated to pin the new contract including toNotContain on the constant names)
   - Given empty config, Then the six config rows name their sidebar home. (Covered by the agreement suite remaining green over the reworded reasons)
2. ON reasons MUST match the plain UI names. (Covered by the agreement suite; internal state keys removed at all five toggle rows plus the ordering row)
3. The Claude.ai Model row MUST be a by-design skip. (Test: Claude.ai format: the Model row is a by-design skip (that generator emits no model parameter))
4. Rule (h) MUST cover the shared consumer set. (Test: advisor rule (h) covers legacy template carriers: a researcher-typed explorer without a path gets the nudge; with a path, both rules stay silent)
5. Docs MUST match the shipped code. (TECHNICAL.md eight spots, README preset label, help modal pronoun + fourth prompt-status state - verified by reread; doc files are not test-covered)

## Spec quality check

- [x] Each requirement testable and unambiguous
- [x] Scope bounded (Non-goals stated)
- [x] No open clarifications remain
- [x] Every scenario names a verifying test (doc spots verified by reread, noted)
- [x] Success criteria measurable

## Success criteria

- A user reading any Explain OFF row knows the exact next action without asking.
- No Explain text names an internal constant, state key, or config field id.
- TECHNICAL.md contains no claim contradicted by the current code.

## Approach and decisions

- Applied the audit's suggested rewrites nearly verbatim (they were authored against the live text); judgment exercised only on the "mild" tier - Atlassian, suggestion-clause, success-gate, and decision-section rows got their obvious lever mentions; toggle-named OFF rows left as-is (audit judged them acceptable).
- The audit's help-modal suggestion to document the foreign-template status was applied with CORRECTED semantics: the state means unmodified template text from a different role left by a type change (per the code at promptTemplateInfo), not a preset-curated specialist - the audit's framing was checked against the source before writing.
- Rule (h) reuses `_appExplorerConsumers` verbatim rather than duplicating the predicate - (h) and (i) cannot drift apart again.
- The role-gating test pin was migrated to the sharper contract (asserts the new plain-language reasons AND the absence of the old constant names), never weakened.

## Surface area (file -> role)

- index.html: explainAgentNode (Datadog/code-search step-hint rows, tools/Max Turns rows, Model row, verify-hint OFF branch), explainWorkflow (six config rows, five toggle ON reasons, durable-requires-memory row, Atlassian rows, decision-section row), explainDecisionNode (ordering row, success-gate row), adviseWorkflow rule (h) + the (i) mutual-exclusivity comment, help modal (pronoun + fourth status state).
- tests.html: role-gating pin migrated; two new pins (Model-row by-design skip; legacy-carrier rule (h)).
- TECHNICAL.md: eight staleness fixes. README.md: preset label.

## Task checklist

- [x] Batch 1: Explain wording (High + jargon + medium table + obvious milds + ON-text)
- [x] Batch 2: doc staleness (TECHNICAL.md x8, README x1, help x2)
- [x] Batch 3: rule (h) shared predicate + comment + test
- [x] Test migrations deliberate; agreement matrix green
- [x] Full suite green via ./run-tests.sh

## History

- 2026-07-04: created - the overnight read-only audit's findings applied in three batches (by explain-lever-audit)
- 2026-08-07: Explain OFF-guidance became actionable - rows whose lever lives in a sidebar section now carry a deep link ("configure ->" when skipped, "open section ->" when emitted) that closes the modal, expands the target section, and scrolls to it (jumpToSection; smooth for humans, instant under __instantScroll / reduced motion - the selectNode precedent). One central EXPLAIN_SECTION_LINKS map (row part -> section id); step-only levers (Model/Effort/turns) deliberately unmapped - their lever is the selected node's config panel, not a section. +2 tests, 1578 -> 1580 (by direct session)
- 2026-08-07: the links reach Explain Step through the shared renderer - memory rows (preamble/postamble/read/write), the durable-handoff row, and the three step hints (Datadog / code-search -> MCP Integrations; verification-instructions -> Multi-Repo & Context Paths) now jump to their levers from the step view too. The director's question caught a mismap while extending: "Branches" is the parallel/output fork-paths row, NOT repo branches - it was pointing at the repositories section; removed from the map and pinned link-free. +1 test, 1580 -> 1581 (by direct session)
- 2026-08-25: ON-row richness pass (director noticed Repositories showed only its heading) - six rows had heading-placeholder evidence, replaced with the real emitted blocks (repoBlock, appSourceBlock, deliveryBlock at both workflow and output-node level) or the user's own text (UI Context, Workflow Context); reasons now name configured values (repo paths @ branches, App Under Test path, rules/docs/verify path lists + inline-notes presence, memory path, artifact path, step model name - the Model row also explains the base-alias emission the director asked about: "this step runs Opus 5 - emitted as the base alias opus, which the runner resolves to its newest build"). Evidence previews gained exInlineMd (escape-first bold + code spans; deliberately NOT a full markdown pass, and reasons stay plain text). Deliberately left alone: rows whose evidence already IS the full hint text, and reason strings that would only duplicate what their evidence shows. +4 tests, 1634 -> 1637 (by direct session)
- 2026-08-25: review fixes on the richness pass - evidence blocks now match the emitting format's heading level (subagent/teams/claude emit these blocks at ##, prompt/SDK at the ### defaults; _exH threads it into repoBlock/appSourceBlock/deliveryBlock at both workflow and output-node level), the dead winnerHeading const dropped (its only consumer became deliveryBlock), the three path-list reasons filter blank entries (hand-edited prefs blobs), and exInlineMd unified onto the shared inlineFmt with code-spans-first ordering so backticked glob literals never bold. 1637 -> 1640 (by direct session). Second review pass: the heading-level ternary extracted into one shared explainHeadingLevel(format) (was encoded twice), and the Model row's redundant probe ternary dropped (exRow blanks probe/full itself when not emitted). Director polish: the reason renderer honors newlines (escape-then-br), and the Repositories reason lists one repo per line under the count.

## Outcome

Every Explain OFF row now names its lever in user language; ON reasons use UI names; the one ON-state inaccuracy (Claude.ai Model row) is a by-design skip; rule (h) and (i) share one consumer predicate; TECHNICAL.md/README/help match the shipped code. index.html + tests.html + two docs; 1511 -> 1513 (two new pins, one migrated); zero regressions.

## Built with (provenance)

Workflow `explain-lever-audit`: read-only audit agent (overnight, no writes) produced the findings report; a single implementing fork applied the three batches under the director's morning approval. Grounded on the audit report as specification.

## Links

- Grounds on / touches: grounds on `.workflow/context-agent-types.md` (the OFF-row principle's origin + rule h/i), `.workflow/defect-posture.md` (the FOUND_DEFECT_ROLES defect class the principle was coined from), and the overnight audit report (method); amended `.workflow/context-agent-types.md` (rule h predicate claim + History line).
- Branch: main (uncommitted delivery for the director).
