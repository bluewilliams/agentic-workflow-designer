# Multi-input handoff reliability: typed dependency refs + reviewer-count-agnostic Report Builder

Branch: local working tree. Status: current. Two small, low-risk reliability fixes surfaced by the read-only audit execution-dogfood (`.workflow/audit-of-generated-prompt-machinery.md`, gap #1 + a follow-on idea).

## Why and scope

Two ways a multi-input step (synthesis, aggregation, review, an implementer fed by planner+architect) could be handed ambiguous context:
1. The Report Builder role prompt hardcoded the four Review-Swarm dimensions ("security, quality, performance, architecture" / "health scores per dimension"), so on any review shape with different/fewer reviewers it referenced dimensions nobody audited.
2. Dependency-reference lines passed only the upstream agent LABEL, not its TYPE - a downstream step got the name of each source but not the role behind it.

Non-goals: passing the upstream agent's prompt/goal (label+type is enough; the full prompt would bloat and risk a downstream agent re-doing upstream work). Dynamic per-instance prompt generation (a static conditional clause covers both the swarm and single-reviewer cases).

## Requirements

- **Report Builder is reviewer-count agnostic.** GIVEN a review shape with any number/kind of reviewers, WHEN `PROMPTS.reportBuilder` renders THEN it aggregates "every upstream reviewer - whatever areas they covered" and gives a per-area breakdown ONLY "where multiple reviewers covered distinct areas" - no hardcoded dimension names. Verified by `Report Builder prompt is reviewer-count agnostic`.
- **Dependency refs carry the upstream type.** GIVEN a downstream agent with upstream agent deps, WHEN any of the four prose generators renders its dependency line THEN each ref is "Label (Type)" (e.g. "Codebase Mapper (Researcher)"). Applies to ALL steps, not just reviewers. Verified by `Dependency references carry upstream agent type`.
- **getDeps contract unchanged.** GIVEN the same graph, `getDeps(id)` still returns plain labels (the validation/dangling-ref check and any plain-ref consumer are unaffected). Verified indirectly by the full suite staying green (preset byte-identical tests).

## Approach and decisions

- Refactored `getDeps` into a shared walk `getDepNodes(id)` (returns agent nodes, deduped by label) + `getDeps` (maps to labels - unchanged output) + new `getDepsWithType` (maps to "Label (Type)"). One walk, two formatters; `getDeps`'s contract is preserved so the validation site at index.html:~6248 is untouched.
- Swapped `getDeps` -> `getDepsWithType` at the 7 display sites (`const deps = ...` feeding the "Depends on / Review the output from / Input from / Use the output from" lines) across genWorkflow/genSubAgents/genAgentTeams/genClaudePrompt. All 7 verified display-only (.length/.join); one (genAgentTeams ~7225) was already dead code.
- Report Builder: 5 targeted substring edits in `PROMPTS.reportBuilder` - genericized the aggregate line + output + handoff, added the conditional "where multiple reviewers covered distinct areas" clause. Static prompt with conditional phrasing chosen over dynamic generation (no machinery, can't degrade the swarm: its inputs ARE the dimensions, so it still breaks out per-area).
- genAgentSDK does not emit the markdown dependency lines, so it is unaffected (and is a removal candidate anyway).

## Surface area (file -> role)

- `index.html`: `getDepNodes`/`getDeps`/`getDepsWithType` (~6534); 7 display-site swaps; `PROMPTS.reportBuilder` (~1470).
- `tests.html`: `Dependency references carry upstream agent type` (2 tests, incl. a non-reviewer Implementer<-Planner case) + `Report Builder prompt is reviewer-count agnostic` (1 test).
- README.md + TECHNICAL.md: topology/dependency-ref note (type-tag on upstream dependencies).

## Verify

`./run-tests.sh` -> `PASS: 1080/1080` (was 1077; +3). Probe: type-tag "Codebase Mapper (Researcher)" appears in genWorkflow/genSubAgents/genAgentTeams/genClaudePrompt; reportBuilder source has the conditional clause and no hardcoded dimensions.

## Outcome

Multi-input handoffs are more reliable: aggregators no longer invent dimensions, and every downstream step now sees the role behind each input it receives. Both are additive, low-risk, and apply to all four prose generators uniformly.

## Built with (provenance)

Authored directly, from gap #1 + the dependency-context idea surfaced by the audit execution-dogfood.
