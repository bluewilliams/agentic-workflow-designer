# Give the General agent its own template (stop it impersonating Researcher)

Branch: main. Status: current.

```awd:record
{"slug": "general-agent-template", "status": "current", "date": "2026-07-01", "files": ["index.html", "tests.html"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

The General agent type resolves to its own neutral scaffold template (PROMPTS.general: complete the task, orient, plan, execute, verify, Handoff Summary) via AGENT_TYPE_PROMPT_MAP.general = 'general', distinct from the Researcher template. validateWorkflow still nudges empty-prompt General agents to tailor the scaffold. The dynamic label-seeded fallback in getEffectivePrompt serves only genuinely unknown agent types and composes its body from PROMPTS.general so the two cannot drift.

## Why and scope

Resetting a "General" agent filled its Agent Prompt with the **codebase-research** template - because `AGENT_TYPE_PROMPT_MAP.general` pointed at `'researcher'` (the same prompt the dedicated Researcher type uses). So "General-purpose agent" silently handed you a research-specific checklist, and `classifyAgentPrompt` (which resolves templates through the same map) treated that researcher text AS the General template. Surfaced by Blue after a Reset.

## Key decisions

- **General now has its own neutral, general-purpose template** (`PROMPTS.general`): a static "Complete the assigned task -> orient with Glob/Grep/LSP -> plan -> execute -> verify -> Handoff Summary" scaffold (the static form of the existing smart fallback). Map changed `general: 'researcher'` -> `general: 'general'`. General is now distinct from Researcher; Researcher is unchanged.
- **Kept the "empty General prompt" validation warning.** `validateWorkflow()` warns about General agents with an empty `config.prompt` but NOT about typed agents (coder/planner/etc.) - revealing the design intent: typed agents have complete role templates; a General agent is a scaffold you are expected to tailor. The warning checks the STORED prompt (not the template), so it is unaffected and still nudges the user. So General's template is an honest starting scaffold, and the warning says "tailor me" - coherent, vs the old state where it silently ran as a researcher.
- **Static, not the dynamic fallback.** The smart fallback interpolates the node label; a mapped type must resolve to a static PROMPTS entry so `classifyAgentPrompt` (template comparison) and Reset behave correctly. So PROMPTS.general is the static form. The dynamic fallback remains as the last resort for genuinely unknown/unmapped agent types.
- **No impact on imported/foreign agents:** foreign import creates `agentType:'general'` nodes but with a prompt (from the instruction), so getEffectivePrompt returns the stored prompt, not the template. The map only matters for empty-prompt General agents (new palette node / Reset) - exactly the case being fixed.

## Changes

- index.html: added `PROMPTS.general` (general-purpose scaffold); `AGENT_TYPE_PROMPT_MAP.general` 'researcher' -> 'general'; updated the smart-fallback comment (now for unknown/unmapped types only).
- tests.html: "General agent template (distinct from Researcher)" describe - General maps to `general` and a general-purpose template (not the researcher prompt), end-to-end genWorkflow emits it, and Researcher still uses the researcher prompt.

## Verification

- 1193 -> 1195 (+2). The existing "warn about empty General prompts" test and "presets zero warnings" tests still pass (warning logic untouched; named presets use typed agents, not General). Content-lint.

## Task checklist

- [x] Add PROMPTS.general (static general-purpose scaffold)
- [x] Point AGENT_TYPE_PROMPT_MAP.general at it (was 'researcher')
- [x] Keep the empty-General validation warning (intent: General is a tailor-me scaffold)
- [x] Test: General != Researcher, end-to-end output uses the general template; full suite green; content-lint
