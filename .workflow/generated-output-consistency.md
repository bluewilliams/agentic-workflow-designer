# Generated-output consistency sweep (labels, gates, dashes, dangling lines)

Branch: main. Status: current.

```awd:record
{"slug": "generated-output-consistency", "status": "current", "date": "2026-07-01", "files": ["index.html", "tests.html"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

genWorkflow's parallel siblings emit Agent Context, Max turns, and Success gate lines at parity with sequential steps. Blank-label decisions fall back to Yes/No everywhere so gate text and routing agree. toolAccessText call sites guard empty tool lists, generated strings carry no em dashes, the empty-General validator warning describes the scaffold accurately, and the Debugger type description matches its investigate-only template.

## Why and scope

A designer-wide audit of generated-prompt quality surfaced a cluster of small consistency defects - none breaking on its own, but each one hands the executing agent slightly wrong or contradictory text. Fixed as one batch: same theme, individually trivial, jointly worth a record.

## Key decisions

- **genWorkflow parallel siblings now emit at parity with sequential steps**: `Agent Context:` (was bare `Context:`, the one spot diverging from the standardized label), `Max turns:`, and per-sibling `Success gate:` lines. Deliberately NOT emitted for siblings: `Depends on:` - a fork child's only dependency is the fork itself, and the group header ("Run the following agents simultaneously") already carries that; emitting it would be noise.
- **Empty-label decision fallbacks aligned to Yes/No** (10 sites were `|| 'Pass'` / `|| 'Fail'`). Decision nodes are CREATED with `yesLabel:'Yes', noLabel:'No'` (node defaults), and the decision-point routing sections already fell back to Yes/No - so the Pass/Fail fallbacks could make one document demand a "Pass/Fail verdict" while its routing keyed on "Yes/No" (reachable via imported JSON with blank labels). One fallback pair everywhere; explicit user labels unaffected.
- **Empty tool list no longer renders a dangling closed enumeration** ("You have access to these tools: "). `toolAccessText`'s own test documents the contract - "bare label, caller guards emission" - but three call sites (genSubAgents step bullets x2, buildTeammateBlock) were unguarded. Guarded them like the sites that already complied.
- **Em dashes removed from all generated/user-facing strings**: the revise-cycle decision lines (x2, `\u2014` escapes), the memory-protocol TOON example, the story-input placeholder, and the agent-palette tooltip separator. Generated artifacts should not carry em dashes.
- **Copy accuracy**: validateWorkflow's empty-General warning said "(no built-in template)" - stale since PROMPTS.general landed; now "(generic scaffold - tailor it to your task)", matching the fix's tailor-me intent. Debugger's AGENT_TYPES desc said "Investigates and fixes bugs" but its template (investigator) investigates to root cause and hands off to a Fixer; desc now says "Investigates bugs to root cause" (honest smallest fix; a combined investigate+fix standalone template was considered and deferred).

## Changes

- index.html: genWorkflow parallel-branch parity block; 10 gate-label fallback sites; 3 toolAccessText guards; 5 em-dash strings; validator warning copy + comment; Debugger desc.
- tests.html: "Generated-output consistency" describe - parallel-sibling parity (context/turns/gate + old label absent), Yes/No fallback agreement on blank-label decisions, no dangling tool line on empty tools, no em dashes across all five formats (revise-loop + memory paths included).

## Verification

- 1199 -> 1203 (+4), full suite green. Content-lint grep clean.

## Task checklist

- [x] Parallel-sibling parity in genWorkflow (Agent Context / Max turns / Success gate; Depends-on deliberately skipped)
- [x] Yes/No fallback alignment (10 sites)
- [x] toolAccessText caller guards (3 sites)
- [x] Em-dash sweep in emitted strings (raw + `\u2014`-escaped)
- [x] Validator General copy + Debugger desc accuracy
- [x] Tests for each; suite green; content-lint
