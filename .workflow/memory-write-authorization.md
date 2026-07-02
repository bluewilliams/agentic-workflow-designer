# Authorize memory-file writes for read-only-task agents

Branch: main. Status: current.

```awd:record
{"slug": "memory-write-authorization", "status": "current", "date": "2026-07-01", "files": ["index.html", "tests.html"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

Memory-file writes are protocol-level, not task-level: every per-agent memory-write emission carries memoryWriteAuthNote(), so an agent whose task tools omit Write is still authorized and expected to append to its memory files. The Agent SDK format unions "Write" into the emitted tools=[...] param when memory is on and the node lacks it, with a generated-code comment. Everything sits behind the existing memoryEnabled gates; memory off emits nothing.

## Why and scope

The memory protocol mandates per-agent file appends ("append a TOON entry to `@{slug}.md`... This is not optional"), but the per-agent tool line is a closed enumeration that scopes task work. An agent whose task tools omit `Write` (Skeptic, Verifier, preset Reviewer/Researcher) received two contradictory instructions: "you have access to these tools: Read, Grep, Glob, LSP" and "you MUST write files". In the prose formats that is a contradiction the agent has to guess its way through; in the Agent SDK format `tools=[...]` is a hard runtime block, so compliance was literally impossible and the agent silently dropped out of the memory protocol. Design ruling: memory writes are PROTOCOL-level, not task-level - every agent writes its own memory; the tool enumeration scopes the task only.

## Key decisions

- **Direct per-agent writes stay (not orchestrator-mediated).** The established pattern in all three multi-agent formats is each agent owns `@{slug}.md` and appends to `shared.md` itself; the protocol's whole point is surviving compaction by writing early/often DURING a turn, which an orchestrator transcribing at handoff boundaries cannot protect. The orchestrator-transcribes pattern belongs to the durable-record layer (curated narrative artifact), not the memory layer (working state). Different artifacts, different owners - kept deliberately.
- **One shared sentence, DRY'd**: new content helper `memoryWriteAuthNote()` ("Memory-file writes are part of the workflow protocol, not the task: every agent appends to its memory files even when `Write` is not in its task tool list...") injected at every per-agent memory-write emission: genMemoryProtocol (covers Workflow prompt + Agent Teams headers), genAgentMemoryPostamble (covers Sub-Agents + SDK per-agent prompts), the Sub-Agents "Memory System" header, and the teammate WRITE LAST block. Words shared, container shapes untouched (per the generator-architecture rule).
- **SDK gets a real tools union, not just prose**: when `state.memoryEnabled` and a node's tools lack `Write`, the emitted `tools=[...]` appends `"Write"` with a trailing `# Write added for the memory protocol` comment in the generated script. Prose can carve out an exemption; a hard param cannot - the capability must actually be granted. Agents already holding Write are untouched (no duplicate, no comment).
- **Everything stays behind the existing `state.memoryEnabled` gates** (verified all emission sites are gated; durable record is already forced off when memory is off). Memory off = zero new text, zero tools change.
- **Claude.ai single-conversation format skipped**: one agent maintaining `progress.md`, no per-agent tool enumeration conflict to resolve.

## Changes

- index.html: `memoryWriteAuthNote()` helper; injections in genMemoryProtocol, genAgentMemoryPostamble, the Sub-Agents memory header, buildTeammateBlock's WRITE LAST block; genAgentSDK tools union (`sdkWriteAdded`).
- tests.html: "Memory write authorization (read-only-task agents)" describe - note present in all three prose formats when memory on; absent everywhere when off; SDK unions Write for a Write-less agent (exact tools line + comment); SDK leaves Write-holding agents untouched.

## Verification

- 1195 -> 1199 (+4), full suite green. Content-lint grep clean.

## Task checklist

- [x] memoryWriteAuthNote() content helper (single source for the words)
- [x] Inject at all four per-agent memory-write emission surfaces
- [x] SDK tools=[...] union with generated-code comment (memory on + Write missing only)
- [x] Confirm memoryEnabled gating covers every new emission (off = unchanged output)
- [x] Tests: prose presence, off absence, SDK union, SDK no-duplicate; suite green; content-lint
