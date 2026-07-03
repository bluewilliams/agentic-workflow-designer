# Tool selections are suggestions, never restrictions

Branch: main. Status: current.

```awd:record
{"slug": "tool-suggestion-semantics", "status": "current", "date": "2026-07-03", "files": ["index.html", "tests.html", "TECHNICAL.md"], "verify": ["./run-tests.sh", "grep -c 'Suggested tools for this step' index.html"], "supersedes": ".workflow/tool-access-wording-and-dry.md", "superseded_by": null}
```

## Current behavior

A node's selected tools are STRONG SUGGESTIONS - the step's primary toolkit - never a restriction. Every prose format emits `Suggested tools for this step: X` (single source: `toolAccessText`) followed by one suggestion clause (`toolScopeNote`): suggestions, not limits - the agent may use any other tool its runtime provides (other core tools, MCP servers, task tracking) when the task calls for it. Full and partial selections read identically; there is no withheld-list variant and no substitution note. The Agent SDK emits NO hard `tools=[...]` param - the suggestion rides as a `# Suggested tools:` comment plus the same instruction lines. The memory protocol's write authorization is phrased against the suggested set ("whether or not `Write` is among its suggested tools"), with no SDK Write-union machinery. Ride-alongs: the Verifier holds Write in both pinned tool sets (its prompt writes a throwaway harness), the Skeptic runs 8 turns (was 5), and the debugger defaults include Write/Edit (its template writes a failing repro test).

## Why and scope

Owner ruling, superseding the 2026-06-30 closed-enumeration decision (`tool-access-wording-and-dry.md`): honor the user's tool selections as strong suggestions while never limiting or blocking an agent from any tool available to it. The closed enumeration had already been softened twice (the scope note un-forbidding unmodeled tools; the substitution note reconciling template mentions) - both were patches on semantics that fought the goal. Suggestion semantics dissolve the whole conflict class: a template mentioning an unselected tool is no longer a contradiction, a deselected tool is no longer withheld, and the SDK's hard param - the one true enforcement point - was the ruling's direct casualty.

## Key decisions

- **One wording, one clause, uniform**: `Suggested tools for this step: X` + a single suggestions-not-limits sentence, emitted together wherever tools are selected. Deselection now means "not recommended for this step", not "forbidden" - the designer expresses intent, the agent keeps judgment.
- **`toolSubstitutionNote` REMOVED** (helper, five emission sites, tests, Explain row): under suggestion semantics there is no gap to reconcile - the clause already licenses any tool the template mentions.
- **SDK: no `tools=[...]` param.** A hard block is incompatible with the ruling. The suggestion survives as a comment on the AgentConfig plus the same suggestion line/clause inside the instructions. Consequence: the memory-protocol Write-union machinery (`sdkWriteAdded`) is deleted - nothing needs un-blocking when nothing blocks. The R3/C5 per-step-hint exclusion is KEPT but re-rationalized: the format stays minimal by owner priority (the old rationale - "the hard param grants no MCP access" - died with the param).
- **Explain rows renamed** to "Suggested tools" / "Suggestion clause" (substitution row gone); SDK note rows recast; agreement matrix updated against real output.
- **Ride-alongs from the deep prompt review**, coherent with the new semantics: Verifier +Write (both pinned sets - its prompt instructs writing a throwaway harness), Skeptic maxTurns 5 -> 8 (a critic that runs out of turns mid-hunt returns a shallow PASS), debugger defaults +Write/Edit (its template writes a failing repro test).

## Changes

- index.html: toolAccessText/toolScopeNote rewritten, toolSubstitutionNote removed (helper + 5 sites), genAgentSDK tools param -> comment + instruction lines, memoryWriteAuthNote recast, sdkWriteAdded machinery removed, R3/C5 rationale comment rewritten, REVIEW_LOOP_KINDS (skeptic turns, verifier Write) + AGENT_TYPE_TOOL_DEFAULTS (debugger, verifier), Explain rows renamed/removed, SDK explain notes recast.
- tests.html: identity + phrasing pins to the new wording; substitution tests removed; suggestion-clause uniformity + SDK-no-param tests added; memory-auth describe rewritten (no union); agreement-matrix row names; exposure line.
- TECHNICAL.md: content-helper example updated.

## Verification

- 1319 -> 1316 (net: -substitution/-union tests, +suggestion-uniformity, +SDK-no-param), full suite green. Content-lint. Headless spot-check: generated sub-agent prompt carries the suggestion line + clause; SDK carries the comment and no `tools=[`.

## Task checklist

- [x] toolAccessText -> suggestion wording (single source, identity test updated)
- [x] toolScopeNote -> uniform suggestions-not-limits clause (no withheld variant)
- [x] toolSubstitutionNote removed (helper, 5 sites, tests, Explain row)
- [x] SDK: tools param removed; comment + instruction-line suggestion; Write-union machinery deleted
- [x] memoryWriteAuthNote recast for suggestion semantics
- [x] R3/C5 exclusion kept, rationale rewritten (owner-priority minimalism)
- [x] Ride-alongs: verifier +Write (both sets), skeptic turns 8, debugger +Write/Edit
- [x] Explain rows + agreement matrix updated
- [x] Docs (TECHNICAL.md); records superseded/rewritten; suite green; content-lint

## Update (same day): owner refinements after review

Three refinements from the owner's read of the finished campaign. (1) Planner and architect regain WebSearch/WebFetch in their defaults, with conditional craft lines in both templates (planner: prior-art check - "a plan that reinvents a solved problem wastes its implementer"; architect: verify framework capabilities against current docs, not memory). The wave-A lean removal honored the June ruling, but suggestion semantics changed the economics: a generous suggestion costs nothing, and the owner sees web as core to these roles. (2) The suggestion clause gains a role-intent guard: "Let your role guide you: an investigative or review step should prefer reporting findings over changing things, unless its instructions say otherwise" - cheap insurance for the write-without-Write concern; the role prompt remains the real steering. (3) Confirmed for the record: memory and durable-record protocols were untouched by the semantics change beyond the write-authorization rewording; all gates and contracts intact.

- [x] planner/architect +WebSearch/WebFetch defaults + conditional template lines
- [x] Role-intent sentence in toolScopeNote
- [x] Test pins (defaults + clause sentence)
