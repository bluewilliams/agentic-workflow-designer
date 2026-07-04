# Per-agent-type default tool sets (role implies a tool floor)

Branch: main. Status: current.

```awd:record
{"slug": "agent-type-tool-defaults", "status": "current", "date": "2026-07-01", "files": ["index.html", "tests.html"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

Every agent type resolves a default tool set through agentTypeToolDefaults() (AGENT_TYPE_TOOL_DEFAULTS; writer per style via WRITER_TOOL_DEFAULTS; general derived from NODE_DEFAULTS; adversary/verifier mirroring REVIEW_LOOP_KINDS; appExplorer/designAnalyzer read-only floors of Read/Grep/Glob/LSP/Bash - no Write or Edit). Type changes pristine-swap tools by the matches-any-default rule in both the node panel and the Agent Library form (applyAgentTypeChange), and never touch customized sets - note the old pre-web-tools debugger set is now exactly the appExplorer default, so it counts as pristine under matches-ANY-default. Coder/frontend/backend/debugger/researcher defaults include WebSearch/WebFetch, licensed by conditional web steps in their templates.

## Why and scope

Owner ruling: an agent's role class implies a default tool floor - a Researcher generally SHOULD have the web tools (WebSearch/WebFetch), a Coder needs write access, a Planner is read-only. Before this, only Writer had per-style tool defaults (WRITER_TOOL_DEFAULTS); every other type change left the node holding whatever tools it was created with (usually the generic Add-Agent set), so switching a fresh node to Researcher never granted the web tools its role implies. The user's selection always wins: deselecting a tool is respected everywhere, and the per-step availability line ("You have access to these tools: ...") remains the dynamic truth of what is actually selected.

## Key decisions

- **AGENT_TYPE_TOOL_DEFAULTS** map beside the other type-level tables: planner/architect/reviewer Read/Grep/Glob/LSP; coder/frontend/backend Read/Write/Edit/Bash/Grep/Glob/LSP; tester same-as-coder (deliberately includes Edit - the tester template instructs modifying tests; audit had flagged preset testers lacking it; preset nodes themselves left untouched); debugger Read/Bash/Grep/Glob/LSP; researcher Read/Grep/Glob/WebSearch/WebFetch/LSP; general REFERENCES NODE_DEFAULTS.agent.config.tools (derived, cannot drift from the Add-Agent default); adversary/verifier mirror REVIEW_LOOP_KINDS[kind].tools (declaration order prevents referencing directly; equality is test-pinned so drift breaks the suite); writer resolves per style via the existing WRITER_TOOL_DEFAULTS through the new agentTypeToolDefaults(type, style) resolver.
- **Pristine-swap on type change, mirroring the prompt rule**: the agentType handler now swaps tools only when the current set set-equals ANY known default (any type's defaults or any writer style's) - the same "matches any template" decision matchesAnyRoleTemplate made for prompts, so tools and prompt follow the node to its new type together. A user-customized set never swaps. This REPLACED the old unconditional writer-branch tool overwrite: switching a customized node to Writer now preserves its tools (previously clobbered); no test pinned the old clobber, and fresh nodes behave identically.
- **Researcher template gains one conditional web step** (step 10 of 13): "Where external references would help and web tools are available to you, use WebSearch... and WebFetch..." - selection-safe phrasing that never lies when the web tools are deselected, closing the loop with the role's new default floor.
- **Presets and auto-built nodes unaffected**: they set explicit curated tool arrays at creation (no type-change event), and their curated sets (e.g. planner + WebSearch) intentionally do not set-equal any default, so even a later type change preserves them.
- The Data Gatherer's Agent Context license line (prior unit) remains - that is task-specific guidance, a different layer from the role floor.
- Out of scope, noted: the Agent Library editor's applyAgentTypeChange keeps its own existing behavior; the writingStyle-change handler already had its own pristine mechanism and is untouched.

## Changes

- index.html: AGENT_TYPE_TOOL_DEFAULTS + agentTypeToolDefaults() + toolSetsEqual() + toolsMatchAnyDefault() after WRITER_TOOL_DEFAULTS; agentType-change handler pristine-swap (replacing the unconditional writer tools overwrite); PROMPTS.researcher conditional web step (renumbered 10-12 to 11-13).
- tests.html: "Agent-type default tool sets" describe (8 tests): map completeness over AGENT_TYPES against ALL_TOOLS; researcher includes web tools / planner+reviewer read-only; adversary+verifier set-equal REVIEW_LOOP_KINDS (anti-drift pin); general identity with NODE_DEFAULTS; UI-driven general->researcher swap (real dropdown click) gains WebFetch and sheds Write; customized (preset-style) tools survive a type change; switch-to-writer applies style defaults through the same rule; researcher template conditional phrasing. Test-iframe exposure line extended (AGENT_TYPE_TOOL_DEFAULTS, REVIEW_LOOP_KINDS, NODE_DEFAULTS, ALL_TOOLS).

## Verification

- 1229 -> 1237 (+8), full suite green; the UI-swap tests drive the real config-panel dropdown in the headless app (same rig as a standalone smoke). Content-lint grep exit 1. No em dashes added.

## Task checklist

- [x] AGENT_TYPE_TOOL_DEFAULTS + resolver + set-equality helpers (general derived, adversary/verifier mirror pinned by test)
- [x] Pristine-swap on type change (matches-ANY-default rule, consistent with the prompt fix); customized sets never touched
- [x] Writer path unified under the same rule (no double-apply, no unconditional clobber)
- [x] Researcher template conditional web step, selection-safe phrasing
- [x] 8 tests incl. real-UI dropdown drive; suite green; content-lint

## Update (same day): defaults refinement + Agent Library form parity

Owner license: "if our defaults are limiting for any agent type... make things the best they can be" (goal: every generated workflow as successful as possible), plus an explicit ruling that the project carries NO backward-compatibility obligations yet.

**Defaults refinement.** coder/frontend/backend/debugger gain WebSearch + WebFetch (ALL_TOOLS order). Rationale: implementers routinely build against external libraries/frameworks/APIs where consulting the official docs beats guessing an API surface from memory; a debugger searching the exact error message or stack signature is one of the highest-value moves in real bug work. Each of the four templates (implementer, frontend, backend, investigator) gains ONE conditionally-phrased web step ("...and web tools are available to you...") modeled on the researcher's, renumbering the later steps - implementer after the conventions step, backend/frontend before their create/modify steps, investigator after the git-log step (search the exact error message / stack signature for known issues). Templates stay truthful under any selection.

**Reviewer verdict: unchanged.** PROMPTS.reviewer is purely read-and-analyze (four LSP verification steps + an evaluation rubric; it runs nothing - no linter/test/build execution instructed), so Bash stays out of reviewer defaults.

**Deliberate keeps (questioned, kept):** planner/architect stay lean and repo-grounded (breadth-first web research is the Researcher's job; a plan grounded in the actual codebase beats one grounded in blog posts); adversary stays read-only vs verifier's Bash+WebFetch (the Skeptic reasons about the work, the Verifier executes and proves - the asymmetry is the design); tester keeps the write set without web tools (its job is exercising THIS repo's behavior).

**Outdated-pristine-set consequence (pinned by test, per the no-compat ruling - documentation, not a promise):** a node holding the OLD coder seven-tool set still set-equals the tester default, so it remains "pristine" and swaps on type change; a node holding the OLD debugger set matches no current default and is treated as customized (kept). Acceptable: matching is against CURRENT defaults by design, and stale sets degrade to the safe behavior (keep).

**Agent Library form parity.** applyAgentTypeChange (shared by the library agent form) previously had TWO divergences from the node panel: non-writer type changes never swapped tools, and switch-to-writer unconditionally clobbered even customized tool sets. It now applies the identical pristine rules: toolsMatchAnyDefault -> swap to agentTypeToolDefaults(newType, style); blank prompt fills; matchesAnyRoleTemplate(current) -> re-bakes for the new type; customized tools/prompts never touched. Two tests that pinned the old clobber were REWRITTEN to pin the new contract (clean-behavior choice per the no-compat ruling, not a weakening); +2 new form tests (pristine chain general->planner->writer in the real form DOM; customized selection + typed prompt survive).

- [x] coder/frontend/backend/debugger +WebSearch/WebFetch; four templates gain a conditional web step (renumbered, no pins broken)
- [x] Reviewer verdict recorded (read-only, no Bash)
- [x] Deliberate keeps recorded (planner/architect, adversary/verifier asymmetry, tester)
- [x] Outdated-set consequence pinned (old-coder swaps via tester match; old-debugger kept as customized)
- [x] applyAgentTypeChange full parity (tools pristine-swap + template re-bake); 2 old-clobber tests rewritten, 2 added
- [x] Suite 1241 -> 1246, content-lint

## History

- 2026-07-01: created (by agent-type-tool-defaults)
- 2026-07-03: registry gains appExplorer/designAnalyzer read-only defaults; the old debugger set became an owned default under matches-ANY-default (by context-agent-types)
