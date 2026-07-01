# Aligned tool-availability wording + extracted it into one content helper

Branch: main. Status: current.

## Why and scope

Per-node tool selections surface into every generated format, but the wording had drifted into two variants - a bare `- Tools: X` label (Workflow, Agent Teams, Sub-Agents metadata, OpenSpec intent) and a `You have access to these tools: X.` sentence (the Sub-Agents system prompt). Two goals: (1) align them on one phrasing, and (2) stop the phrasing from living inline in 7 places so a future wording change is one edit, not a 6-spot sweep (which is exactly what the alignment itself cost before the extraction).

Non-goals: touching the Agent SDK's tool rendering - it emits the real `tools=[...]` param, the ONLY true enforcement point, and should stay structural, not prose. NOT building a monolithic multi-format agent renderer (see rejected below). NOT extracting the model line (its per-format rendering genuinely diverges: label+param vs `getModelId` vs raw).

## Key decisions

- **One phrasing: `You have access to these tools: X`** across Workflow, Sub-Agents, Agent Teams, and the OpenSpec export intent. Picked the second-person form (over a bare label or a neutral "Available tools:") because it reads as an actionable grant to the agent that will act, which elicits tool use better, and it fits both an agent-facing prompt line and a spec/metadata bullet.
- **Availability, not restriction; a CLOSED enumeration.** The line means "these are yours to use," not "you may use ONLY these / stop and refuse others." Deliberately NO "minimally" / "at least" - that would make the list a FLOOR and quietly re-authorize a tool the user deselected on purpose (e.g. WebSearch), defeating the point of per-node selection. A plain closed enumeration reads as the provided set, so a deselected tool is not-granted. Honest caveat recorded: in the copy-paste prompt formats this is a strong DIRECTIONAL signal (a model will almost always respect it), not a hard sandbox; only the SDK `tools=[...]` param truly blocks an unlisted tool.
- **DRY the knowledge, not the shape.** Extracted the wording into a pure content helper `toolAccessText(tools)` that returns the WORDS only; each generator keeps its own container (bullet vs bold vs indent vs sentence-with-period vs YAML), because the container legitimately differs per format and forcing uniformity would be a leaky abstraction. Helper returns the bare label for an empty list to match prior inline behavior byte-for-byte; the caller keeps its own emit guard, so guarded spots still omit when there are no tools and unconditional spots still print the label - output is identical for all inputs.
- **Rejected: a `renderAgent(node, {format})` mega-function.** That trades 7 honest one-line duplications for one function sprouting a `format` conditional per divergence, where a Workflow tweak could break OpenSpec. The formats SHOULD be able to drift independently - that is a feature, not debt.

## Changes

- New pure helper `toolAccessText(tools)` (defined just above `genWorkflow`): `'You have access to these tools: ' + (tools?.length ? tools.join(', ') : '')`.
- Routed all 7 call sites through it: `genWorkflow` (serial step + parallel sibling), `buildAgentPrompt` (Sub-Agents system prompt, keeps the trailing period), `genSubAgents` metadata (serial + parallel), `buildTeammateBlock` (Agent Teams), `openSpecStepIntent` (OpenSpec export). Each keeps its own `- ` / `  - ` / bold / `${pre}` / `.` container and its own emit guard.
- Wording alignment folded in: the old bare `- Tools:` / `- **Tools**:` labels are gone from the prose formats; every surface now reads `You have access to these tools: X`.

## Surface area (file -> role)

- index.html: `toolAccessText` helper (1 def) + 7 call sites; removal of the two old label variants.
- tests.html: "Tool availability wording (aligned across formats)" describe - helper-direct test (exact string + empty-list bare label), aligned-phrasing across the 3 prose generators, old `- Tools:` / `**Tools**:` labels asserted gone, OpenSpec export carries the phrasing, plus a golden exact-line pin (`- You have access to these tools: Read, Grep, Glob`) so the helper can't drift the container.

## Verification

- 1177 -> 1181 (+4 net). Byte-identical refactor confirmed structurally: the extraction changed no output, so the pre-existing round-trip `toBe` guard and every substring test stayed green through it; the wording alignment (1177->1180) preceded the extraction (1180->1181).
- Content-lint scan of both touched files: clean.

## Task checklist

- [x] Align all prose formats + OpenSpec intent on `You have access to these tools: X`
- [x] Decide semantics: availability, closed enumeration (no "minimally"), SDK = only hard enforcement
- [x] Extract `toolAccessText(tools)` pure content helper; route 7 call sites; keep containers per-format
- [x] Byte-identical guard (existing suite green through the extraction) + golden exact-line pin + helper-direct test
- [x] Content-lint scan

## Next candidates (parked - and honestly, weaker than tools)

The tool line was the standout because it combined BOTH long, drift-prone wording AND genuine repetition of the same string. The others hit only one, or neither, so the juice is thinner:

- **Max-turns line** - simple but a 2-word stable label (`Max turns: N`) unlikely to ever be reworded, so a helper is low-value indirection. Only worth it if we want mechanical uniformity.
- **Dependency line** - a WEAKER candidate than it first looked: the phrasing genuinely diverges by format (`Depends on:` in Workflow/Sub-Agents-metadata, `Input from: ... - pass their output as context` in Teams, and a full `## Input / Review the output from: X before proceeding...` prose block in the Sub-Agents system prompt). That is semantic divergence, not cosmetic, so a shared helper would paper over real differences - probably leave it alone.
- **Model line** - NOT a candidate (label+param vs getModelId vs raw).

Net: stopping after the tool line is the right call. Forcing helpers onto the marginal ones would itself read as over-abstraction. A higher-value maintainability move for adopters would be a short "how the generators are structured" map in TECHNICAL.md (the shared block/hint/directive/content-helper seams), not more micro-DRY.
