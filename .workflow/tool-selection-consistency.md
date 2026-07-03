# Tool-selection consistency: preset tester Edit + substitution note

Branch: main. Status: current.

```awd:record
{"slug": "tool-selection-consistency", "status": "current", "date": "2026-07-01", "files": ["index.html", "tests.html"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

Preset testers carry Edit. Under the tool-suggestion semantics (see tool-suggestion-semantics.md): toolScopeNote() emits one uniform suggestions-not-limits clause after the suggested-tools line; toolSubstitutionNote no longer exists (a template mentioning an unselected tool is not a contradiction when the selection is a suggestion). The scope/substitution behaviors this record originally built are historical below.

## Why and scope

Two follow-ups closing the loop on the owner's tool model ("tool selected, the agent has it; tool deselected, it is not part of the agent's prompt"):

1. **Preset testers lacked Edit** while their templates (tester/bugTester/e2eTester) instruct modifying existing test files - an audit minor now inconsistent with AGENT_TYPE_TOOL_DEFAULTS giving new Tester nodes Edit.
2. **Static role templates can teach a deselected tool** (deselect LSP on a researcher and the template still mandates seven LSP steps). The availability line is authoritative by ruling, but the prompt momentarily contradicted the selection - the one residual gap in the owner's model.

## Key decisions

- **Preset testers gain Edit** (9 tool arrays: every `tools:[...six-tool set...], prompt:PROMPTS.tester|bugTester|e2eTester` site, including the auto-builder's ternary). Curated exceptions left alone deliberately: `Validator` (runs and reports, does not write) and `Feature Writer` (authors new .feature files; Write suffices).
- **`toolSubstitutionNote(node)`**: emitted beside the agent's instructions ONLY when the effective prompt backtick-mentions a tool outside the node's selection - "Note: your instructions mention X - not in your tool list. Skip those steps or achieve the same goal with the tools you do have." Names the exact missing tools. Returns '' when the selection covers every mention, and on empty tool lists (no enumeration emitted = no contradiction to reconcile). Injected in the five agent-facing surfaces: genWorkflow sequential + parallel-sibling blocks, buildAgentPrompt (sub-agents), buildTeammateBlock (teams), and the SDK instructions array. Plan-level step summaries in genSubAgents deliberately skipped (table-of-contents, not agent-facing).
- **Why a note, not template rewriting**: templates stay static and shared (the byte-identical/one-source architecture); selection-aware template surgery would be a much larger, riskier change. The note reconciles the two layers in one sentence, only when they actually disagree.
- Known thin edge, accepted: the SDK note tests the node's SELECTED tools, while the emitted tools param may additionally carry the memory-protocol Write union - a template mentioning `Write` on a Write-less memory-on node would be flagged despite the union granting it. Templates reference Write in prose, not backticks, so this is theoretical today.

## Changes

- index.html: 9 preset/auto-builder tester tool arrays +Edit; `toolSubstitutionNote()` beside `toolAccessText()`; 5 emission sites.
- tests.html: substitution note flags missing LSP in all four generated formats; silent when covered and on empty tools; preset tester carries Edit; helper added to the test-iframe exposure line.

## Verification

- 1237 -> 1240 (+3), full suite green. Content-lint grep clean.

## Task checklist

- [x] Preset tester Edit (9 arrays; Validator/Feature Writer left curated)
- [x] toolSubstitutionNote helper + 5 agent-facing injections (plan summaries skipped)
- [x] Tests: flag + silence + preset Edit; suite green; content-lint

## Update (same day): toolScopeNote - the enumeration is closed over the MODELED set only

Owner raised the sharp edge of the closed enumeration: the real runtime has many tools the designer does not model (MCP servers the workflow's own hints ENCOURAGE - code search, Datadog, Atlassian - plus task tracking, notebooks, and whatever else the session carries). A strictly-read "You have access to these tools: Read, Grep, Glob" could talk an agent out of using them, hurting workflow success. New `toolScopeNote(tools)` emitted right after the availability line at the same five agent-facing surfaces: names the withheld CORE tools explicitly ("Core tools not listed above (Write, Edit, ...) are deliberately withheld for this step" - deselection semantics get STRONGER, not weaker) and declares everything outside the modeled set unrestricted ("MCP tools connected to your session, task tracking, and other runtime utilities... remain available as normal"). Full-selection nodes get only the outside-clause; empty tool lists get nothing (no enumeration = nothing to scope). SDK variant carries only the outside-clause (the hard tools=[...] param already enforces the core set; MCP servers configured on the runtime remain reachable). Withheld list derives from ALL_TOOLS so it cannot drift. Chip growth (TodoWrite etc.) considered and deferred: the scope note handles the long tail by category without adding config noise; add chips only if a tool needs per-node selectability. +1 test. 1240 -> 1241.

- [x] toolScopeNote helper (withheld-naming + outside-clause; ALL_TOOLS-derived)
- [x] 5 surface injections incl. SDK outside-clause variant
- [x] Test: withheld naming, full-set variant, empty silence, all-format presence; suite green; content-lint

## Update (2026-07-03): suggestion semantics land

The owner ruled tool selections are strong suggestions, never restrictions (tool-suggestion-semantics.md). This record's two reconciliation devices resolved accordingly: toolSubstitutionNote REMOVED (nothing to reconcile when nothing is forbidden); toolScopeNote reduced to the uniform suggestions-not-limits clause (no withheld-list naming). The preset-tester Edit work stands unchanged.

- [x] Current behavior rewritten; devices resolved per the new semantics
