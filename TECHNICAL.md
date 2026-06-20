# Agentic Workflow Designer: Technical & Product Reference

> A living document. Update this whenever architecture, features, or product goals evolve.

---

## High-Level Objectives

### Problem
Engineers working with AI-powered development (Claude Code, Anthropic Agent SDK, Agent Teams) face a consistent challenge: translating a Jira ticket or user story into a well-structured multi-agent prompt is complex and time-consuming. The mental model of "which agents do what, in what order, with what instructions" is hard to hold in your head and even harder to communicate to a team.

### Solution
The Agentic Workflow Designer is a **visual, browser-based playground** that bridges the gap between a requirements document and a production-ready agentic workflow prompt. Users drag, drop, and connect nodes on a canvas to design their multi-agent pipeline, then copy a fully-formed prompt into Claude Code, Claude.ai, or the Anthropic Agent SDK.

### Core User Journey
1. Paste a Jira ticket URL, user story, or requirements into the sidebar
2. (Optional) Click **Generate Refine Prompt** to interview with Claude and sharpen requirements
3. Click **Auto Workflow** (or pick a preset, or build manually)
4. The canvas populates with agent nodes connected in the right order
5. (Optional) Click **Generate Plan Prompt** to generate a codebase-aware implementation blueprint
6. Optionally reconfigure each node (agent type, model, tools, custom prompt)
7. Toggle **Memory Protocol** on/off as needed
8. Select an output format tab and click **Copy**
9. Paste the output into Claude Code or the Agent SDK and run it
10. Optionally **Save** the workflow by name, or **Export .json** to share with colleagues

---

## Architecture

### Single-File Design
The entire application is a **single `index.html` file** (~4,200 lines). There is no build step, no server, no dependencies. Open the file in a browser and it works. This is intentional: it keeps the tool portable, shareable as a GitHub link, and trivially deployable as a static page.

### Layout Grid
```
┌──────────────┬──────────────────────────────────┐
│              │         Canvas Area              │
│   Sidebar    │   (SVG, pan/zoom/drag nodes)     │
│   (320px)    │                                  │
│              ├──────────────────────────────────┤
│              │      Prompt Output Panel         │
│              │   (5 output format tabs)          │
└──────────────┴──────────────────────────────────┘
```

### State Model
All application state lives in a single plain JS object:
```js
state = {
  nodes: [],          // All canvas nodes
  connections: [],    // Directed edges between nodes
  selectedId: null,   // Currently selected node or connection ID
  mode: 'select',     // 'select' | 'connect' | 'delete'
  pan: { x, y },      // Canvas viewport offset
  zoom: 1,            // Canvas zoom level (0.2–3)
  exportFormat: 'prompt',
  memoryEnabled: false, // Memory Protocol toggle
  defaultModel: 'opus-4.8', // Global default for new nodes
  repositories: [], // Array of { path, branch } for multi-repo workflows
  mcpAtlassian: true,  // Atlassian MCP toggle
  mcpCodeSearch: true,  // Code search (MCP) toggle (Sourcebot, Sourcegraph, Kilo Code, etc.)
  plibOpen: [],        // Expanded prompt library categories
  plibFavs: []         // Favorited prompt library entries
}
```
No frameworks, no reactive libraries. Each user action calls `render()` which does a full DOM diff-free re-render of the SVG canvas and triggers `updatePrompt()`.

### Persistence (localStorage)
All persistence uses `localStorage` so the app remains a single portable HTML file with no server dependencies.

| Key | Shape | Purpose |
|-----|-------|---------|
| `awd_prefs` | `{ defaultModel, memoryEnabled, appSourcePath, appSourceBranch, exportFormat, repositories, mcpAtlassian, mcpCodeSearch, mcpCustom, plibOpen, plibFavs }` | User preferences, auto-saved on change and auto-restored on load |
| `awd_workflows` | `[ { slug, name, savedAt, nodeCount, agentCount }, ... ]` | Index of saved workflows (metadata only) |
| `awd_wf_{slug}` | `{ version, slug, name, story, savedAt, repositories, canvas: { nodes, connections, nextId, pan, zoom } }` | Full saved workflow data |
| `awd_autosave` | Same shape as `awd_wf_{slug}` | Single-slot auto-save, debounced 1s on `render()` |

**Serialization boundary**: Nodes (full config), connections, nextId, pan, zoom, workflowName, storyInput, repositories, and memoryEnabled are persisted. Transient UI state (selectedId, mode, connectFrom, dragging, isPanning, mousePos) is excluded.

**Error handling**: All localStorage operations are wrapped in try/catch with toast notifications on failure. A secret scanner checks for API keys, credentials, and connection strings before copying prompts to clipboard.

---

## Node Types

| Type | Shape | Color | Purpose |
|------|-------|-------|---------|
| **Agent** | Rounded rect | Blue | A Claude agent with configurable type, model, tools, prompt, notes, and max turns |
| **Task** | Rounded rect | Green | A discrete unit of work with description + acceptance criteria (non-agent) |
| **Decision** | Diamond | Amber | A conditional branch with yes/no routing, configurable max revision cycles, and explicit reasoning requirements |
| **Parallel** | Flat rect | Purple | Fork/Join control flow. Splits into concurrent branches or collects results |
| **Input** | Pill | Cyan | Entry point: Jira ticket, user story, PRD, or custom input. Optional App Source Path and App Branch fields for test automation workflows |
| **Output** | Pill | Rose | Deliverable: code changes, PR, report, or documentation. When format is PR, shows Branch Name and Target Branch fields |

### Agent Node Config
Each Agent node has:
- **Agent Type**: Planner, Architect, Coder, Frontend, Backend, Reviewer, Tester, Debugger, Researcher, Writer, General, plus **Skeptic** and **Verifier** (the review-loop roles - see [Review Loops](#review-loops-skeptic--verifier)). 13 types total (`AGENT_TYPES`)
- **Writing Style** (Writer only): Technical, User Guide, Business, API Reference, Runbook. Auto-configures tools and prompt template per style
- **Model**: Fable 5, Opus 4.8 (default), Opus 4.7, Opus 4.6, Sonnet 4.6, Sonnet 4.5, Opus 4.5, Haiku 4.5 (Fable 5 and the latest Opus/Sonnet also have [1M] variants)
- **Tools**: Checkboxes for Read, Write, Edit, Bash, Grep, Glob, WebSearch, WebFetch, Task, LSP
- **Agent Prompt**: Freeform textarea. If left blank, falls back to `getEffectivePrompt()`
- **Agent Context** (per-node, was "Custom Notes"): additional context injected into this agent's prompt section across all export formats. The workflow-wide counterpart is the **Workflow Context** sidebar field (`getPlan()`, `id="planInput"`)
- **Max Turns**: Integer cap on the agent's execution turns

### Review Loops (Skeptic + Verifier)
Two one-click context-menu actions attach a review-and-revise loop to any Agent or Task node, reusing the existing Decision/maxRevisions machinery (no new node type):

- **Skeptic** (`agentType: 'adversary'`) - a refute-first critic with a role-aware lens (`ADVERSARY_LENSES`, keyed off the reviewed node's role) and a strict materiality bar: default PASS, NEEDS REVISION only for Critical/High material defects, never nitpicks. Resolved via `buildAdversaryPrompt(reviewedRole)`; `getEffectivePrompt`/`classifyAgentPrompt` special-case `adversary` (parallels the Writer/writingStyle case), with the lens carried in `config.adversaryRole`.
- **Verifier** (`agentType: 'verifier'`) - proves the outcome meets the objective with evidence (run it, call the API, drive a browser, follow doc steps). One strong default prompt (`PROMPTS.verifier`, no lens); execution tools (Bash, WebFetch).

Both share a kind-parameterized family (`REVIEW_LOOP_KINDS`): `attachReviewLoop(targetId, kind)` builds `target -> reviewer -> Decision`, with the Decision's no-branch (the back-edge) looping to the target and the yes-branch carrying the target's original downstream; `detachReviewLoop` reverses it; both are single-undo via `batchUndo`. Markers live on the nodes (`reviewLoopFor` + `reviewLoopKind` on the reviewer, `reviewLoopDecisionFor` on the Decision) and survive serialization, so detach + no-double-attach work after reload. Constraints: one loop per node; review nodes can't themselves host a loop (`canAttachReviewLoop` excludes `adversary`/`verifier`). The Decision's failure back-edge can be re-pointed to any work node via `setReviewLoopBackTarget` (a dropdown on the Decision config) - the edge is the single source of truth, so the generators, detach, and serialization all read it (no extra state). Demoed in the Feature Build (Skeptic on Planner), Documentation (Skeptic on Doc Writer), and UI Design (Verifier on UI Implementer) presets. Backward-compatible aliases (`attachAdversary`, etc.) delegate to the generic functions.

---

## Prompt Generation System

### `getEffectivePrompt(node)`: 3-Tier Fallback (with Writer style resolution)
```
User-entered prompt
  → Writer style template (writer + capitalize(writingStyle) → PROMPTS[writerTechnical|writerBusiness|...])
    → Agent type template (AGENT_TYPE_PROMPT_MAP → PROMPTS[key])
      → Smart generic fallback using node label
```
For Writer agents, the writing style (stored in `node.config.writingStyle`) is resolved to a style-specific prompt key before falling back to the generic agent type map. This ensures exported prompts always contain real instructions, even if the user never touches the prompt field. A **Skeptic** (`adversary`) node resolves the same way via `buildAdversaryPrompt(node.config.adversaryRole)` (a parallel special-case); a **Verifier** (`verifier`) node resolves through the normal agent-type map to `PROMPTS.verifier` (no lens).

### `PROMPTS` Library
30+ pre-written agent prompt templates covering:
- **Planning/Architecture**: `planner`, `architect`
- **Implementation**: `implementer`, `backend`, `frontend`
- **Investigation/Fix**: `investigator` (Datadog-aware: checks production logs/errors when MCP available), `fixer`
- **Review**: `reviewer`, `fullstackReviewer`, `codeAnalyzer`, `codeReviewer`, `improver`, `adversary` (Skeptic: refute-first critic, role-aware lens, materiality bar)
- **Testing/Validation**: `tester`, `bugTester`, `e2eTester`, `validator`, `verifier` (evidence-based outcome verification; one default prompt, no lens)
- **Research**: `codebaseExplorer`, `docResearcher`, `patternAnalyzer`, `synthesizer`
- **Audit**: `securityAuditor`, `qualityAnalyst`, `perfProfiler`, `archReviewer`, `reportBuilder`
- **Test Automation (SET)**: `appExplorer`, `testPlanner`, `featureWriter`, `screenObjectWriter`, `stepDefWriter`, `testReviewer`
- **Writer**: `writerTechnical`, `writerUserguide`, `writerBusiness`, `writerApi`, `writerRunbook`
- **Cross-cutting**: `securityReview`, `testWriter`, `researcher`

Each template is structured with numbered steps, expected outputs, handoff summaries, and output format guidance.

---

## Prompt Output Formats

The bottom panel generates prompts in 5 formats. Internally these are called "export formats" in the code (`state.exportFormat`, `setExportFormat()`, etc.).

### 1. Workflow (Structured Markdown)
A `##` header-structured document with numbered steps, agent roles, parallel execution notes, decision points, and expected deliverables. Best for pasting into a Claude.ai conversation as a planning prompt.

### 2. Sub-Agents (Claude Code Task Tool)
Generates markdown with embedded `Task(subagent_type=..., model=..., prompt=...)` pseudocode blocks. Each agent block includes a self-contained prompt with role, tools, task instructions, dependency context, success gates, downstream awareness, and requirements. When memory is enabled, each prompt includes a **Step 0: Read Memory** preamble and a **Final Steps** postamble. Best for use in Claude Code.

### 3. Agent Teams (Preview)
Generates a "team lead brief" for use with the experimental Claude Code Agent Teams feature (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`). Includes TeamCreate setup, parallel spawn instructions, and explicit dependency handoff guidance. When memory is enabled, each teammate block includes **READ FIRST** instructions before the task and **WRITE LAST** instructions after.

### 4. Agent SDK (Python)
Generates Python code using the Anthropic Agent SDK patterns. Includes model family mapping (e.g., `claude-sonnet-4-5-20251001`), tool lists, and agent prompt construction. Useful for programmatic workflow execution.

### 5. Claude.ai
A conversational prompt suitable for Claude.ai, structured as a role-assignment prompt with the full workflow described in natural language.

### Delivery (`deliveryBlock()`)
Delivery is driven **purely by the Output node format** - there is no separate toggle. Code changes are produced by the agents regardless of the output node; the format only decides what happens to the work at the end. `deliveryBlock(level)` dispatches to one of five blocks, injected into all 5 export formats (the SDK renders it as `#` comments). On a multi-output workflow it picks by priority: `pr > commit > report > docs > code`.

| Format | Label | Block | Behavior |
|--------|-------|-------|----------|
| `code` (default) | Leave Uncommitted | `noCommitBlock()` | Make code changes, commit nothing. Same as no output node. |
| `commit` | Commit | `commitBlock()` | Feature branch, commit + push, **no PR**. Branch Name field. |
| `pr` | Pull Request | `prBlock()` | Feature branch, commit + push, open PR. Branch Name + Target Branch fields. |
| `report` | Report | `reportBlock()` | Produce a written report; leave any code uncommitted; never commit/push/PR. |
| `docs` | Documentation | `docsBlock()` | Produce docs per project conventions; leave any code uncommitted; never commit/push/PR. |

`prBlock()` (and `commitBlock()`) include a hard safety rule (never commit/push directly to the target branch), branch-name derivation (user value, else ticket ID, else descriptive), and - for PR only - target-branch defaulting to `main`, git provider detection via `git remote -v` (GitHub/Bitbucket/GitLab → `gh` / Atlassian MCP / `glab`), and a graceful fallback that pushes the branch and hands back a manual-PR URL if creation fails. `reportBlock()`/`docsBlock()` produce the artifact and explicitly leave both the code and the document uncommitted. All presets default to `format: 'code'` (or `report`/`docs` where a document is the deliverable); **no preset uses `pr`**, so commit/push/PR is strictly opt-in via the Format dropdown.

### Research / Advisory Mode (Parallel Research)
The Parallel Research preset is mode-aware so research and advisory spikes do not inherit implementation framing. A spike produces a recommendation, not a build plan.

- **Modes**: `codebase-internal` (our own code), `landscape-advisory` (external options), `hybrid`. Stored on the fork node as `config.researchMode`. Inferred from the requirements text via `inferResearchMode(text)`; overridable from the fork node's inspector (re-bakes the agents in place via `applyResearchMode`).
- **LSP gating**: the codebase/explorer agent keeps `LSP` in its tool list in ALL modes (read-only, cheap). The LSP-heavy instructions (call hierarchy, incoming/outgoing calls, goToImplementation, extension points, "where new code should integrate") are gated to `codebase-internal` and `hybrid`. In `landscape-advisory` the same agent does a current-state INVENTORY (Glob/Grep/Sourcebot/Bash; LSP optional) framed as "map what exists / where artifacts land."
- **Option space + anti-anchoring**: when the title names two options ("X vs Y"), `detectNamedOptions(text)` pre-fills `config.options` and `buildOptionSpaceGuard` injects an instruction to enumerate the FULL option space (status-quo / do-nothing and lighter-weight alternatives included), scored on a shared rubric: effort-to-adopt, maintenance burden, complexity-added, value-delivered, reversibility/lock-in, adoption-friction. The options slot is editable on the fork node.
- **Evaluation bias**: `config.evaluationBias` (defaults to a less-is-more principle) is applied explicitly by the Advisor, which must name the complexity cutoff. Recommending the minimal or do-nothing option is a valid conclusion.
- **Advisory output**: advisory + hybrid end with a single Advisor that writes `ADVISORY.md` (principle-level, scored options matrix, CTO-ready 3-sentence summary, follow-up tickets, open questions). No em dashes in generated artifacts.
- **Additive**: implementation/feature presets are unchanged; all of the above is mode-gated and lives in `researchExplorerPrompt` / `researchDocPrompt` / `researchPatternPrompt` / `researchSynthesizerPrompt`.

### Dependency Wiring
`getDeps(nodeId)` and `getDownstream(nodeId)` resolve through `parallel` (fork/join) and `decision` nodes to the real upstream/downstream agent (or output) labels. Input nodes are the ticket, not a dependency, so the first agents in a parallel fan-out report no upstream instead of a bogus `Depends on: <fork>`. This removes dangling references like `Depends on: Collect` (a join node that is never emitted as a step). `validateWorkflow()` includes a pass that flags any agent referencing a label that is not a defined step or deliverable.

The save-file schema stays `version: 1`: the new fork-node config fields (`researchMode`, `options`, `evaluationBias`) are optional and absent fields render as a plain parallel node, so old saved workflows load unchanged.

### Decision Gate Quality
All export formats enforce structured decision evaluation:
- **Reasoning requirement**: Agents must evaluate each criterion systematically and show reasoning before stating a verdict
- **Revision limits**: Decision gates include a configurable max revision count (default 3) to prevent infinite loops. After the limit, agents proceed with the best version and document remaining concerns
- **Decision Routing (Sub-Agents)**: The Sub-Agents format includes a dedicated "Decision Routing" section that tells the orchestrator exactly how to handle pass/fail results, including which agents to re-spawn on failure

### Format Recommendations
A smart banner above the output tabs analyzes the current workflow shape and suggests the best format:
- 1-2 agents, no parallel fork: Claude.ai
- 3+ agents or parallel fork: Sub-Agents
- 4+ agents with parallel fork: Agent Teams

The banner updates live as nodes are added or removed. Clicking the recommended format name switches tabs.

### Requirements Scaffolding
When a preset is loaded and the requirements field is empty, the textarea placeholder changes to a preset-specific template. All 14 presets have tailored templates (e.g. Bug Fix shows "Steps to reproduce / Expected behavior / Actual behavior", Feature shows "User story / Acceptance criteria / Relevant files"). Templates are placeholders only and never overwrite user content.

### Acceptance Criteria Extraction
`extractAcceptanceCriteria(text)` parses the story text for structured criteria:
- Detects "Acceptance criteria:", "Definition of done:", "Done when:", etc. as section headers
- Within an AC section, all bullet/numbered/checkbox items are captured
- Outside an AC section, items containing requirement language (should, must, verify, ensure, etc.) are captured
- Extracted criteria populate the decision gate `condition` field as a numbered list
- Falls back to `'All review checks pass'` when no criteria are detected

### Topology Awareness in Exports
All generators use `topologicalSort()` to process nodes in dependency order. Each agent's export block includes:
- Input from upstream nodes (dependency context)
- Success gate info if a Decision node follows it
- Downstream awareness so the agent knows who reads its output
- The full Jira/user story as a `## Requirements` section

### Node config that drives output
Every node type's config reaches the generated prompt, and each option's default is byte-identical to prior output (new behavior fires only on a non-default value):
- **Agent / Decision / Output** - fully emitted (roles+prompts, routing+revision caps, delivery via `deliveryBlock`)
- **Parallel `strategy`** - `forkStrategyOf()` + `strategyJoinPhrase()` express join semantics in all five generators; `all` keeps today's wording, the SDK maps `any`/`race` to `asyncio.wait(FIRST_COMPLETED)` (race cancels pending)
- **Task nodes** - `taskSectionLines()` / `taskSectionComments()` emit a Tasks section (label + description + `Done when:` from `acceptance`). Previously dropped entirely; no preset or Auto Workflow creates Task nodes, so existing output is unchanged
- **Input `source`** - a framing selector with three options: `freeform` (default, silent), `story`, `prd`. `inputSourceHint()` adds a one-line framing for `story`/`prd` only; `freeform` (and any legacy/unknown value) is silent. Jira handling is **decoupled** from this selector and content-driven: `getWorkflowAtlassianUrls()` detects any Atlassian URL (bare or inline) and `atlassianTicketFetchHint()` instructs the orchestrator to resolve the ticket in depth before planning (description + acceptance criteria, parent epic, sub-tasks, blocking/linked issues, recent comments). So a pasted Jira URL gets the full treatment under any framing selection; there is no "Jira" dropdown option because it would be redundant
- Deliberately not emitted: Parallel `description`, Input `description` - their content is already carried globally, so emitting would duplicate it and break byte-identical output

### Repo Context Paths (three-tier context model)
Two optional path lists let the user point agents at a repo's own rules and product docs. State: `state.rulesPaths` and `state.productDocPaths` (both `[]` by default). The sidebar UI mirrors the repository chip-list pattern: a text input + Add, per-chip remove, Clear-all, and one-click quick-add suggestion chips. The designer never reads the filesystem; it captures path strings and the agents do the reading.

These inputs realize a **three-tier context model** the prompts make explicit:
1. **Constitution / rules** (`rulesPaths`) = how to build, binding. The launch repo's CLAUDE.md auto-loads for free; these capture extra rule paths on top of it. (Multi-repo caveat below: CLAUDE.md / `.claude/rules` auto-load ONLY for the launch directory.)
2. **Product / architecture docs** (`productDocPaths`, PRD / ADR) = goals and direction the work must serve and not contradict; when a durable record is kept, snapshot the intent into its Why and scope.
3. **Spec** = the task contract, already the existing requirements/seed input (no separate field).

Two hint functions, `rulesPathsHint()` and `productDocsHint()`, sit next to `codeSearchHint()` / `consumeRecordsHint()` and are gated on a non-empty array (no separate toggle). They are injected at all five exporters mirroring the `_wfSb` pattern (`genWorkflow`, `genSubAgents`, `genAgentTeams`, `genClaudePrompt`, and the `genAgentSDK` comment variant). Each hint instructs: read only what is listed (no blind-hunt), directory-vs-file discovery (a directory: discover relevant files by common name; a file: read it directly), and multi-repo scoping (resolve each path within each in-scope repository; a repo's own context governs only that repo's work; never carry one repo's context into another's; a path absent in a repo is no-extra-context, not an error). Hint text is provider-neutral, hyphens only, no triple-backtick fences; the product-docs hint uses the lowercase phrase "durable record" to avoid colliding with durable-record gating.

**Multi-repo CLAUDE.md (`repoBlock`)**: Claude Code auto-loads CLAUDE.md / `.claude/rules` only for the tree rooted at the launch directory (verified against the Claude Code docs); a second repo's rules are not loaded automatically, and non-fork subagents inherit the launch repo's loaded rules without re-scanning new directories. So the generated multi-repo block instructs each agent to read every working repo's `CLAUDE.md` / `CLAUDE.local.md` / `.claude/rules` before changing it, and to **scope rules per repo** - each repo's rules (including the launch repo's auto-loaded CLAUDE.md) govern only that repo's work, with conflicts resolved in favor of the repo being changed. It also surfaces the cleaner setup, `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir <path>`, which auto-loads each added repo's CLAUDE.md. Note this is a behavioral scoping discipline, not hard isolation: the launch repo's CLAUDE.md stays in session context and a prompt cannot unload it.

**Persistence and stickiness**: both lists persist to localStorage via `savePrefs` / `restorePrefs` (the `_restoring` guard already covers them; `restorePrefs` uses an `Array.isArray` guard so older blobs lacking these keys are tolerated). Unlike the MCP toggles, `clearCanvas` (New Workflow) deliberately does NOT reset these arrays - they are repo-level context that carries across workflows in the same repo, so only the Clear-all controls empty them. Different-paths-per-repo selection is a deliberate future extension; the flat lists apply to all in-scope repos and the hint scopes them per-repo.

---

## Memory Protocol

### Overview
The Memory Protocol is an optional system that makes agent workflows resilient to context compaction. When enabled via the sidebar toggle, all export formats inject structured memory instructions that tell agents how to persist their work to disk and recover from context loss.

### Auto-Enable Logic
Memory auto-enables when loading a preset or generating from a story if the workflow meets any of these criteria:
- **Parallel forks** - concurrent agents need shared state coordination via `shared.md`
- **Decision gates** (presets only) - revision loops may re-spawn agents that need to recover context
- **5+ agents** - long-running workflows are more likely to hit compaction

For `generateFromStory()`, decision gates are excluded from the criteria because every generated code workflow gets one by default (it's not a complexity signal in that context). Simple linear chains (e.g. Feature Build, Code Review) stay memory-off. Users can always toggle memory on or off manually.

### Duplicate Label Handling
`buildAgentSlugMap()` generates unique slugs for all agents. When multiple agents share a label (e.g. two "Reviewer" nodes), numeric suffixes are appended (`reviewer-1`, `reviewer-2`). Agents are sorted by node ID before suffix assignment for deterministic output across renders.

### Format-Specific Variants
- **Multi-agent formats** (Sub-Agents, Agent Teams, Agent SDK): Each agent gets its own `@{slug}.md` file, inter-agent handoffs flow through `shared.md`, and breadcrumbs include the agent identifier
- **Single-agent format** (Claude.ai): Uses `genSingleAgentMemoryProtocol()` with a single `progress.md` file instead of per-agent files, since the entire workflow runs in one conversation

### Design Principle: Structural Injection Order
Memory instructions are **structurally embedded** in each agent's prompt flow, not appended as an afterthought:

1. **Read-first (Step 0)**: Memory read instructions appear **before** the task, ensuring agents check for compaction recovery before doing any work
2. **Write-last (Final Steps)**: Memory write instructions appear **after** the output format, ensuring agents persist progress and breadcrumbs as their final mandatory action

This ordering maximizes the probability that agents follow memory instructions even under heavy task load.

### TOON v1 (Token-Optimized Orchestration Notation)
A compact structured notation for agent memory and inter-agent communication:

| Category | Symbols |
|----------|---------|
| **Status** | ✅done 🔄active 🚧blocked ❌failed ⚠️warning 💡insight |
| **Sigils** | @agent #ticket !critical f:file s:symbol fn:function t:type d:decision |
| **Flow** | →next ←depends ↑escalate ↓delegate ∥parallel |
| **References** | [@agent:step] for cross-agent citations |
| **Entry format** | `## @name \| ISO-ts \| status-emoji` then `d:` `f:` `→` `←` `!:` `💡:` lines |

### Memory Files
Two file types stored at `~/.claude/workflow-memory/{workflow-slug}/`:

| File | Access | Purpose |
|------|--------|---------|
| `shared.md` | Append-only | Inter-agent communication channel |
| `@{agent}.md` | Read/write (owning agent) | Per-agent progress and state |

### Compaction Recovery
Each agent ends every response with a breadcrumb comment:
```
<!-- WF_BC: {workflow} @{agent} {ISO-timestamp} -->
```
If an agent's previous breadcrumb is missing from context, compaction has occurred. The agent reads `shared.md` + `@{agent}.md` to recover full context before resuming work.

### Inter-Agent Communication
Downstream agents read `shared.md` to get upstream handoffs. Agents address each other with:
```
→ @{next-agent}: {what they need to know}
```

### Durable Record (committable artifact)

The Memory Protocol has two levels, modeled as a strict superset ladder rather than two independent toggles:

| Level | State | Output | Audience | Lifespan | Home |
|-------|-------|--------|----------|----------|------|
| Workflow Memory | `memoryEnabled` | TOON `shared.md` + `@{slug}.md` | Agents | Ephemeral, one run | `~/.claude/workflow-memory/` |
| Durable Record | `memoryEnabled` + `durableRecord` | One human-readable doc | Humans + audit + future agents | Durable, versioned | In-repo (or work-item) |

`durableRecord` is a superset of `memoryEnabled`: it cannot be on without memory (a committable record of a run requires the run to have survived). The UI enforces this - the **Keep a durable record** checkbox is nested under the memory toggle, and turning memory off via `toggleMemory()` / `setMemoryEnabled(false)` calls `clearDurableRecord()`. Deserialization and prefs restore both coerce `durableRecord` to false when `memoryEnabled` is false.

**State fields:** `state.durableRecord` (bool, default false), `state.artifactPath` (string override, default `''`). Both are persisted in `savePrefs`/`restorePrefs` and `serializeWorkflow`/`deserializeWorkflow`. Save schema stays `version: 1` - the new fields are optional, so older workflows load unchanged.

**Path resolution:** `getDefaultArtifactPath()` returns `.workflow/{slug}.md` (a conventional in-repo location, matching how spec-driven tools commit specs at a fixed repo path). `getArtifactPath()` returns the user override if set, else the default.

**Generation:** `genDurableRecordProtocol()` emits the markdown protocol. The document leads with a **Structure and navigation** block (H1 title + one-line context, omit-when-empty discipline, a conditional Contents index with anchor links once the record grows large, and a fixed section order) so a single doc stays navigable as it scales. The centerpiece is the **Requirements** section: each requirement is a normative MUST/SHALL statement followed by complete Given/When/Then scenarios (happy + boundary + null + negative + error - the 2-to-3 cap was removed) with the verifying test named per scenario, so it is both the spec and the acceptance criteria with per-scenario test traceability (the edge over spec-driven tools' spec files, which carry no test linkage). It is flanked by a **Success criteria** block (measurable, technology-agnostic outcomes, borrowed from spec-kit) and a **Spec quality check** (a self-validation gate run at kickoff and re-confirmed at completion: requirements testable/unambiguous, scope bounded, no open clarifications, every scenario named-test-traced, success criteria measurable). The remaining sections - **Why and scope** (with non-goals), **Approach and decisions** (each with the rejected alternative and why), a surface-area file-to-role map, a **work-breakdown task checklist** (concrete coding/research/test units, not agent/step names), a **Verify** section with real build/test results (an eval substrate), omit-when-empty **Risks** and **Migration/rollout**, **Gotchas**, an **Outcome**, and a **Built-with provenance** line (workflow name + agent roles + grounding, durable in the commit) - are at least on par with what spec-driven tools commit, in one document. An action-trigger ownership model assigns edits by action not role (behavior defined -> Requirements with verifying test; decision made -> approach with alternative; files changed -> surface area; build/tests run -> Verify; risk found -> Risks; new work -> checklist; synthesizer -> outcome + scaffolding strip). Provenance is durable; transient step progress lives only in the current-state scaffolding and is stripped on commit. The protocol also defines a **Durable Record Index** (`.workflow/_index.md`): a per-repo breadcrumb, one structured entry per record grouped by a stable capability slug (facets: files / work-item / epic / status / supersedes / superseded_by / date, omit-when-empty), written through at finalize as a projection of the record - so future workflows scan it (tier 0) and open only the relevant records (tier 2) instead of reading them all. Multi-repo writes a record + index entry in each touched repo, cross-linked via `siblings` + the shared work item/epic, keeping every repo self-describing; on a capability re-work the old record is kept and its entry flipped to `superseded` (with `superseded_by`), so the index points at current behavior with the history one hop away. The **read side** is `consumeRecordsHint()` (gated by the `consumeRecords` toggle, default ON, prefs-persisted, mirroring the `mcpCodeSearch` wiring): a runtime-conditional instruction injected at the workflow level of all four exporters telling the planning/orchestrating step to scan `.workflow/_index.md` if present, open only the records matching the files/capability in scope (preferring `status: current`), fold them into the plan, and supersede a current record the change replaces (the consistency steal from spec-kit's analyze). It is self-gating (a no-op when no index exists), independent of memory/durable (grounding does not require producing), and deliberately avoids the literal string `Durable Record` so it never collides with the durable-record gating. A sibling `clarifyFirstHint()` (gated by the `clarifyFirst` toggle, default **OFF** since it blocks for input, prefs-persisted, injected at the same four exporter sites) is the in-flow equivalent of spec-kit's clarify skill: it has the planning step probe a structured ambiguity taxonomy (under-specified behavior, edge/null/error cases, data shapes, scope, non-functional constraints), ask the director a focused one-round set of questions, then fold the resolutions into the plan and the durable record as resolved decisions; it degrades gracefully when non-interactive (records assumptions/risks and proceeds rather than blocking) and likewise avoids the literal `Durable Record` string. `genDurableRecordComment(prefix)` emits a comment-prefixed pointer for the Python SDK exporter. Both are injected at the workflow-level memory site of all five exporters, nested inside the `memoryEnabled` block (so the superset holds even if state is inconsistent). It is a workflow-level artifact, not per-agent, so it is not injected into per-agent preambles/postambles.

**Provider-neutral:** the protocol references a generic "work-item URL" and "issue tracker", never a specific vendor, keeping the public tool generic. If a work-item URL is supplied with the workflow, agents snapshot its spec into the record; the tool itself never fetches anything.

### Handoff bundle

`exportHandoffFile()` downloads a single Markdown package (`{slug}-handoff.md`) for passing a larger task between engineers. `genHandoffBundle()` assembles it from existing pieces, so it adds no new serialization path:

- `getActivePromptText()` returns the current exporter's output (reusing the same `{prompt, subagent, teams, sdk, claude}` dispatch as `updatePrompt()`, without touching the DOM preview).
- `serializeWorkflow()` provides the importable workflow definition, embedded in a fenced `json` block. It round-trips through the normal `deserializeWorkflow()` loader, so a receiver imports it with the existing **Import** control.
- The prompt is embedded in a fenced block whose fence length is computed by `fenceFor()` to be one backtick longer than the longest backtick run inside the prompt. A prompt that itself contains code fences (e.g. the memory protocol's TOON examples) therefore cannot break the wrapper. The workflow JSON uses a plain ` ```json ` block, since JSON contains no backticks.

Content adapts to `state.durableRecord`: when on, the resume steps lead with the durable record path and warn that a URL-seeded workflow's prompt is thin (resolved context lives in the record, not the prompt); when off, it states there is no captured state to resume from and suggests enabling the durable record. The bundle is intentionally a sender-to-receiver kit: the live state itself travels with the durable record (committed in git or attached to the work item), not inside the bundle, because the generator does not hold runtime artifacts.

---

## Canvas Interaction

### Modes
- **Select** (default, `1`): Click to select, drag to move nodes
- **Connect** (`2`): Click source → click target to draw an edge
- **Delete** (`3`): Click a node or edge to remove it

### Navigation
- **Pan**: Alt+drag or middle-mouse drag
- **Zoom**: Scroll wheel (0.2×–3×)
- **Auto Layout**: Sugiyama longest-path layering algorithm, left-to-right, vertical centering per layer
- **Zoom Fit**: Scales viewport to show all nodes with 80px padding

### Context Menu
Right-click a node to access: Duplicate, Add Branch (Parallel only), **Add skeptic review** / **Add verification** (Agent and Task nodes only; toggle to Remove when a loop is attached - see [Review Loops](#review-loops-skeptic--verifier)), Disconnect All, Delete.

---

## Workflow Generation (`generateFromStory`)

A weighted-keyword scoring engine over **13 categories** builds a bespoke workflow shape (it does not pick a preset). Key properties:

- **Inflection-tolerant matching** - keywords match common plurals and verb forms (`tests`, `endpoints`, `deploying`, `migrations`, `document`), so phrasing variants score the same as the base word.
- **Intent vs domain** - read-only intents (**research**, **review**, **analysis**) score on strong leading-verb rules so an imperative like "Review the service" wins, while an incidental mid-sentence word ("audit logging", "a service that evaluates X") stays weak and does not hijack a build request. The default-to-build guard (below) is the backstop when scoring is ambiguous.
- **Principled tie-breaking** - on equal scores a specificity `PRIORITY` map wins (security/research/review/data/performance over generic build domains) instead of object insertion order.
- **Per-rule repetition cap** - each keyword rule contributes at most `weight x 3`, so a word repeated many times in a long ticket ("service"/"database" x8, a list of "X vs Y") cannot dominate purely by frequency. Distinct keywords (different rules) are unaffected.
- **Boilerplate denoising** (`denoiseForScoring`) - real Jira tickets carry metadata sections (Logistics, Build/Release Pipelines, Repo, "Database Changes: None", Out of Scope, Risks, Open Questions) whose stray keywords otherwise hijack intent (a Release Pipeline line reading as DevOps; "no schema change" reading as a data migration). These sections are stripped before scoring so the engine reads the work statement; a safety net falls back to the full text if denoising removed too much. Complexity still uses the full text (a big ticket is still big work).
- **Default-to-build guard** - the five non-coding shapes (research/review/analysis/test/documentation) produce no implementer, and most designer use is tangible build work, so a non-coding intent is kept ONLY when the task asks to *produce* a read-only deliverable (write tests/docs, a recommendation/comparison matrix, prioritized findings, a cost forecast). Requirements arrive in many formats and rarely declare intent up front, so this does **not** depend on position: deliverable markers are matched anywhere (ones in the first ~2-3 sentences weigh a little more), and weighed against build markers (implement/wire up/make-it-functional/fix/migrate). Because the costly error is a build task with no implementer, ties go to code. The guard is **demote-only** (`research`->build), so it can never push a build into a read-only shape. This is what stops a build task with test-heavy acceptance criteria ("the full test suite passes") from being mistaken for a test-authoring task. A fuzz invariant enforces it: every non-read-only, non-authoring shape must contain >=1 implementer.

| Detected dominant | Workflow shape |
|---|---|
| bugfix | Investigator → Fixer → (code tail) |
| refactoring / data / devops / performance | analyzer/researcher → builder → (code tail) |
| documentation | Researcher → Doc Writer → Doc Reviewer → Output (docs) |
| test | Code Analyzer → Test Suite Writer → (code tail) |
| **research** | Parallel(Codebase / Options / Tradeoff researchers) → Synthesizer → **Report** (read-only, never writes code) |
| **review** | one or more read-only auditors (+ Security/Performance when signalled) → Report Builder → **Audit Report** (read-only) |
| **analysis** | measure/forecast/estimate/cost work → Data Gatherer → Analyst → Report Writer → **Analysis Report** (read-only; never writes code). A bare "X vs Y" is a weak signal so a list of billable categories does not hijack to research |
| UI only / UI + API | Design System Analyzer → UI Implementer, or Parallel(Backend, Frontend) |
| security (additive) | adds a Security Review agent before the main reviewer |

**Review loops where they earn their keep**: a **Skeptic** is wrapped on the Planner whenever one exists (standard/complex builds - doubt the plan early), and a **Verifier** is wrapped on the single primary builder for `complex` workflows (prove it late). Both are inlined re-points of `attachReviewLoop`'s core (no `batchUndo`, so they stay inside the single generate undo batch). Read-only research/review and documentation never get them.

The code tail (review → decision → tester → output) is skipped for read-only (`selfContained`) and documentation shapes. After generation a toast reports the **detected intent** and flags a near-tie so the user can rephrase or pick a preset. Memory auto-enables for parallel forks or 5+ agents; `ensureWorkflowName()` assigns a two-part name (e.g. `swift-falcon`); `autoLayout()` arranges nodes.

**Validation**: a property-based fuzz suite (`Auto Workflow fuzz`, ~290 cases) generates labeled synthetic requirements (random fill-ins, known intent) and asserts the detected shape, plus structural invariants that must hold for any input (one input/output, no orphan agents, no dangling edges, no blank prompts, read-only intents emit a report and contain no code-writing agent) and gibberish inputs for graceful fallback.

---

## Presets

| Preset | Pattern |
|--------|---------|
| **Feature Development** | Input → Planner → Implementer → Reviewer → Tester → Feature Complete (code) |
| **Bug Fix** | Input → Investigator → Fixer → Tester → Decision → Fix Complete (code) |
| **Full Stack Feature** | Input → Architect → Parallel(Backend, Frontend) → Reviewer → Tester → Feature Ready (code) |
| **Code Review** | Input → Analyzer → Reviewer → Improver → Validator → Improved Code (code) |
| **Parallel Research** | Input → Fork → (Codebase Explorer ‖ Doc Researcher ‖ Pattern Analyzer) → Join → Synthesizer → Research Report (report) |
| **Review Swarm** | Input → Fork → (Security Auditor ‖ Quality Analyst ‖ Perf Profiler ‖ Arch Reviewer) → Join → Report Builder → Audit Report (report) |
| **Delivery Swarm** | Input → Fork → (Codebase Cartographer ‖ Requirements Analyst ‖ Prior-Art Researcher) → Join → Lead Planner [Skeptic loop] → Fork → (Backend ‖ Frontend) → Join → Integrator [Verifier loop] → Code Reviewer → Decision → Test Engineer → Feature Delivered (code) |
| **Test Automation** | (Requirements + App Source) → Fork → (Test Planner ‖ App Explorer) → Join → Fork → (Feature Writer ‖ Screen Objects ‖ Step Definitions) → Join → Test Reviewer → Decision → Test Suite (code) |
| **UI Design & Development** | Input → Design System Analyzer → UI Implementer → UI Reviewer → Component Ready (code) |
| **Refactoring** | Input → Planner → Code Analyzer → Refactorer → Reviewer → Decision → Tester → Refactored Code (code) |
| **Documentation** | Input → Planner → Researcher → Doc Writer (Writer: Technical) → Doc Reviewer → Documentation (docs) |
| **DevOps** | Input → Planner → DevOps Engineer → Reviewer → Decision → Tester → Infrastructure Ready (code) |
| **Performance** | Input → Planner → Profiler → Optimizer → Reviewer → Decision → Tester → Optimized (report) |
| **Testing** | Input → Planner → Code Analyzer → Test Suite Writer → Reviewer → Decision → Tester → Test Suite (code) |
| **Data Migration** | Input → Planner → Researcher → Migration Engineer → Reviewer → Decision → Tester → Migration Complete (code) |

---

## Input Validation

The app validates user input at multiple points:
- **Bare Jira keys** (e.g. `PROJ-123`): detected by `isJiraKeyOnly()` and shown an inline hint guiding users to paste the full URL. All three action buttons (Auto Workflow, Generate Refine Prompt, Generate Plan Prompt) block with a toast.
- **URL-only input without Atlassian MCP**: Generate Refine Prompt and Generate Plan Prompt block with a toast since the prompt would contain a URL that agents cannot fetch.
- **URL-only input for Generate**: redirects to the preset picker since there are not enough keywords to auto-generate a workflow.
- **Secret scanning**: `scanForSecrets()` checks all user inputs (requirements, plan, node prompts, notes) for API keys, AWS keys, GitHub/GitLab/Slack tokens, private keys, connection strings, and credential patterns before copying to clipboard. Shows a confirm dialog listing detected secret types.

---

## Prompt Library

A curated collection of high-impact prompts accessible via the **Prompts** toolbar button. Each prompt encodes expert methodology that produces better results than asking from scratch.

### Architecture
- **Data**: `PROMPT_LIBRARY` is a JS array of category objects, each containing an array of prompt entries with `title`, `desc`, `prompt`, and optional `input` config
- **Input popup**: Prompts with an `input` field show a modal collecting user context before copying. Supports `optional: true` with `fallback` text for prompts that work with or without a target
- **Favorites**: Stored as `plibFavs` array in state/prefs (format: `"catIdx:promptIdx"`). Favorited prompts render in a persistent "Favorites" section at the top
- **Category expansion**: Open/closed state persists via `plibOpen` in prefs
- **Tool guidance**: Several prompts include context-aware hints for Sourcebot, LSP, and Atlassian MCP tools (embedded in prompt text, not tied to app toggles)

### Categories
Code Quality, Code Generation, Architecture & Design, Debugging & Performance, Testing, Security, Documentation, Planning & Estimation, Git & Code Review, DevOps & Infrastructure, Data & Migrations, Strategy & Analysis, Release & Operations, Post-Work, Live Monitors, Observability (requires Datadog), Cross-Repo (requires Sourcebot)

### Live Monitors Category
Prompts that watch things for you over time. They run on a recurring interval, compare state across iterations, and self-terminate when their exit condition is met. Each prompt includes a `> **Exit**:` line documenting when the loop should stop. Prompts: PR Build Babysitter, PR Review Watcher, Post-Deploy Canary Monitor, Test Flake Detector, Sprint Stale Work Alert, Long-Running Task Companion, Code Review Soak Test, Service Recovery Watcher.

---

## Help System

The **?** toolbar button opens a help modal covering:
- Quick Start guide
- Generate Refine Prompt and Generate Plan Prompt flows with visual diagrams
- Full flow for power users (refine, plan, build, export)
- Jira integration guidance
- Export format descriptions
- Canvas keyboard shortcuts
- Prompt Library overview
- Power user tips

The help modal also opens via the `?` keyboard shortcut and closes with `Escape`.

---

## Quick Patterns (Palette)

- **Fork (2/3/4)**: Creates a Parallel Fork → N Agent branches → Parallel Join
- **Fan-Out**: Creates an Input → N Agent branches each with their own Output (no join)

---

## Technical Decisions & Rationale

| Decision | Rationale |
|----------|-----------|
| Single HTML file | Zero setup, shareable as a file or GitHub raw link, trivially hostable |
| SVG canvas (not DOM/Canvas API) | Easy to add CSS classes, events, and transforms; scales cleanly |
| No framework | Avoids build complexity; the DOM re-render surface is small enough to manage manually |
| Flat state object + full re-render | Simple to reason about; performance is adequate for the node counts we expect (<50 nodes) |
| Drag uses delta-based screen coordinates | Prevents coordinate transform bugs when canvas is panned/zoomed |
| Topological sort for export ordering | Ensures agents are always exported in dependency order regardless of canvas position |
| getEffectivePrompt 3-tier fallback | Ensures every export always contains real instructions even for blank-prompt nodes |
| Memory preamble/postamble split | Read-before-task + write-after-task ordering maximizes compliance vs. a single appended block |
| Safe-by-default output format | No preset uses `format: 'pr'` (or `commit`); presets deliver `code`/`report`/`docs` (local changes only). Commit/push/PR requires explicit opt-in to prevent agents from pushing code or creating branches without user intent |
| `deliveryBlock()` dispatch | Commit/push instructions are only injected when an output node selects `commit` or `pr`; `report`/`docs`/`code` never commit. Provider detection via `git remote -v` works for GitHub, Bitbucket, and GitLab with graceful fallback |
| TOON v1 for memory files | Compact notation reduces token usage in agent context while preserving structured state |
| Memory auto-enable criteria | Parallel forks, decision loops, or 5+ agents. Simple linear chains stay off to avoid unnecessary overhead. `generateFromStory` excludes decision gates from criteria since it adds one to every code workflow by default |
| localStorage for persistence | No server needed; keeps single-file portability; auto-save + named save + JSON export covers all sharing needs |
| Debounced auto-save (1s) | Saves on every render without impacting interaction performance |
| Separate prefs vs. workflow storage | Preferences (model, memory, format) persist globally; workflows persist individually by slug |
| App Under Test after Presets | Contextual placement. Appears directly below the preset that triggers it (Test Automation) |
| Repositories between Default Model and Add Nodes | Always visible. Persists across sessions (prefs) and saved workflows. Injected into all 5 export formats |
| Undo via state snapshots (not command pattern) | Simpler implementation, easier to reason about. Each pushUndo stores a JSON deep copy of nodes + connections. 50-step limit keeps memory bounded (~250KB worst case) |
| Undo is structural only | Text field edits use the browser's native Ctrl+Z. Canvas undo covers add/delete/connect/disconnect/drag. Separating these avoids interfering with normal text editing |
| Token estimate uses 4 chars/token | Industry-standard approximation for English text and code. Good enough for cost awareness without needing a real tokenizer |
| Validation runs on every render | Cheap operation (iterates nodes/connections arrays). Catches issues in real time rather than only at copy time |

---

## Known Limitations & Future Opportunities

### Current Limitations
- **Undo/redo is structural only**: Covers add/delete/connect/disconnect/drag. Does not capture text field edits (agent prompts, notes, config fields). Use Ctrl+Z in the text field itself for those
- **No multi-select**: Can only select one node or edge at a time
- **Agent SDK export is pseudocode**: The Python output requires manual adaptation to real SDK patterns
- **Decision routing in exports is informational**: Most exports describe decision gates as prompt instructions. The Sub-Agents format includes explicit routing, but the Agent SDK still requires manual conditional logic
- **Memory is prompt-only**: No deterministic pre-compaction hook exists; agents rely on frequent writes and breadcrumb detection
- **localStorage only**: Persistence is browser-local; clearing browser data deletes saved workflows

### High-Value Future Features
1. **Undo/Redo for config fields**: Extend undo to cover text edits in agent prompts and config fields (currently structural only)
2. **Multi-select + bulk operations**: Drag-select multiple nodes, bulk delete, bulk move
3. **Real Agent SDK code generation**: Generate working Python that actually runs the workflow via the Anthropic SDK
4. **Workflow validation**: Warn on disconnected nodes, cycles, missing agent prompts, etc.
5. **Shareable URLs**: Encode workflow state in the URL hash for easy sharing
6. **Node notes preview**: Show truncated notes on the canvas node itself
7. **Connection labels**: Click a connection to add a label (currently only auto-set on Decision pass/fail)
8. **Import from Jira API**: Fetch ticket content directly via Jira REST API
9. **Claude Code hooks integration**: Use hooks for deterministic pre-compaction memory writes (v2 memory)

---

## File Structure

```
agentic-workflow-designer/
├── index.html       # The entire application (single file, ~5,200 lines)
├── tests.html       # iframe-based test suite (zero dependencies)
├── run-tests.sh     # Headless CLI test runner (Chrome + Python 3, zero npm deps)
├── TECHNICAL.md     # This document
├── README.md        # User-facing overview
├── LICENSE          # MIT
└── .gitignore
```

The `index.html` is internally organized into clearly delimited sections:
```
CSS styles
HTML structure
  ├── Sidebar: Workflow Name (+ New Workflow), Story Input (+ Generate Refine Prompt, validation hint),
  │            Workflow Context (+ Generate Plan Prompt), Default Model, Repositories,
  │            Add Nodes, Presets, App Under Test (conditional), Saved Workflows, Tip, MCP Integrations, Memory, Node Config
  ├── Canvas: Toolbar (Select, Connect, Delete, Auto Layout, Fit, Zoom, Prompts, Help), SVG canvas, Empty state
  ├── Prompt Output: 5 format tabs, Copy button
  ├── Help Modal: Quick start, flows, output formats, shortcuts, power user tips
  ├── Prompt Library Modal: Categorized prompts with favorites, input popup, copy
  └── Prompt Input Popup: Collects user context before copying prompts that need it
JavaScript:
  ├── STATE & CONSTANTS
  │     ├── NODE_DEFAULTS, AGENT_TYPES (13 types), ALL_TOOLS, MODELS
  │     ├── WRITING_STYLES (5 styles), WRITER_TOOL_DEFAULTS (per-style tool sets)
  │     ├── Atlassian URL detection
  │     ├── AGENT_TYPE_PROMPT_MAP, capitalize(), getEffectivePrompt()
  │     └── PROMPTS library (30+ templates incl. 5 writer style-specific)
  ├── TOON v1 + MEMORY HELPERS
  │     ├── TOON_KEY constant
  │     ├── slugify(), generateWorkflowName(), ensureWorkflowName()
  │     ├── getMemoryPath(), buildAgentSlugMap()
  │     ├── setDefaultModel(), initDefaultModelSelect()
  │     ├── toggleMemory(), setMemoryEnabled(), updateMemoryPath()
  │     ├── genMemoryProtocol()            # orchestrator-level memory block
  │     ├── genAgentMemoryPreamble()       # per-agent read-first (step 0)
  │     ├── genAgentMemoryPostamble()      # per-agent write-last (final steps)
  │     └── genSingleAgentMemoryProtocol() # simplified memory for Claude.ai format
  ├── PERSISTENCE (localStorage)
  │     ├── showToast()                # reusable toast notification
  │     ├── savePrefs(), restorePrefs() # preference auto-save/restore
  │     ├── serializeWorkflow(), deserializeWorkflow() # state to/from JSON
  │     ├── autoSaveWorkflow(), restoreAutoSave() # debounced WIP persistence
  │     ├── getWorkflowIndex(), setWorkflowIndex() # saved workflow index
  │     ├── saveWorkflow(), loadSavedWorkflow(), deleteSavedWorkflow()
  │     ├── renderSavedWorkflowList()  # sidebar list rendering
  │     └── exportWorkflowFile(), importWorkflowFile() # .json file I/O
  ├── SVG HELPERS
  ├── RENDERING (render → renderNodes, renderConnections, autoSaveWorkflow)
  ├── NODE OPERATIONS
  ├── CONFIGURATION PANEL
  ├── INTERACTION HANDLERS
  ├── MODE & ZOOM
  ├── AUTO LAYOUT
  ├── STORY PARSING & WORKFLOW GENERATION
  │     ├── extractAcceptanceCriteria()  # AC extraction from story text
  │     └── generateFromStory()          # keyword scoring + workflow shape selection
  ├── PRESETS
  │     ├── loadPreset()                 # loads preset + updates story placeholder
  │     ├── STORY_PLACEHOLDERS           # per-preset requirements templates
  │     └── updateStoryPlaceholder()     # dynamic placeholder on story textarea
  ├── UNDO/REDO
  │     ├── pushUndo()                   # snapshot state before mutations
  │     ├── undo(), redo()               # restore from history stacks
  │     └── 50-step limit, Ctrl+Z / Ctrl+Shift+Z / Ctrl+Y keybindings
  ├── WORKFLOW VALIDATION
  │     ├── validateWorkflow()           # checks for disconnected nodes, empty prompts, incomplete decisions
  │     ├── updateValidation()           # toolbar indicator (green check / amber warning count)
  │     └── showValidation()             # alert with issue details
  ├── INPUT VALIDATION
  │     ├── isJiraKeyOnly()              # detect bare Jira ticket keys
  │     ├── validateStoryInput()         # inline hint for story textarea
  │     └── scanForSecrets()             # secret pattern detection before copy
  ├── PROMPT LIBRARY
  │     ├── PROMPT_LIBRARY               # categorized prompt data
  │     ├── togglePromptLib()            # modal toggle
  │     ├── renderPromptLib()            # dynamic rendering with favorites
  │     ├── buildPromptCard()            # card component with star + copy
  │     ├── toggleFavorite()             # add/remove favorites
  │     ├── copyLibPrompt()             # copy with optional input popup
  │     ├── confirmPlibInput()           # substitute user input into prompt
  │     └── filterPromptLib()            # search/filter by title and description
  ├── HELP SYSTEM
  │     └── toggleHelp()                 # help modal toggle
  ├── TOKEN ESTIMATION
  │     ├── estimateTokens()             # ~4 chars per token approximation
  │     └── updateTokenEstimate()        # displays next to Copy button
  ├── EXPORT FORMAT SYSTEM
  │     ├── getFormatRecommendation()    # workflow shape analysis
  │     ├── updateFormatRec()            # recommendation banner rendering
  │     ├── deliveryBlock()    # dispatch by output format: code/commit/pr/report/docs
  │     ├── genWorkflow()      # Format 1: Workflow Markdown
  │     ├── genSubAgents()     # Format 2: Sub-Agent Task calls
  │     ├── genAgentTeams()    # Format 3: Agent Teams brief
  │     ├── genAgentSDK()      # Format 4: Python SDK code
  │     └── genClaudePrompt()  # Format 5: Claude.ai single-conversation prompt
  └── INIT
        ├── initDefaultModelSelect()
        ├── restorePrefs()
        ├── restoreAutoSave() || (updateTransform + render)
        └── renderSavedWorkflowList()
```

---

## Test Suite

`tests.html` is a zero-dependency, iframe-based test harness. Open it in any browser to run all tests. No build step, no server required.

**How it works**: Loads `index.html` in a hidden `<iframe>`, accesses its `contentWindow` for all functions, state, and DOM. Tests run against the real app with real localStorage and real initialization.

**Coverage** (270+ tests across 18 suites):
- **Pure utilities**: `slugify`, `extractAcceptanceCriteria`, `isUrlOnly`, `isJiraKeyOnly`, `getEffectivePrompt`, `getModelLabel`
- **State management**: `addNode`, `addConnection`, `deleteNode`, `buildAgentSlugMap`, `topologicalSort`
- **Persistence**: serialize/deserialize roundtrips, prefs save/restore, workflow save/load
- **Memory protocol**: path generation, TOON notation, slug collisions, auto-enable logic
- **Export generators**: all 5 formats (Workflow, Sub-Agents, Agent Teams, Agent SDK, Claude.ai) with memory on/off
- **Workflow generation**: keyword scoring, structural properties, AC extraction, agent count feedback
- **Preset loading**: agent count verification for all 14 presets, memory auto-enable behavior
- **Format recommendations**: agent count and parallel fork heuristics
- **Workflow auto-naming**: name generation format, variety, empty-field population, user name preservation
- **Writer Agent Type**: config panel interactions, writing style switching, prompt/tool updates, export output
- **Model Version Handling**: full model IDs and Claude Code aliases in all export formats
- **MCP Integrations**: Atlassian/Sourcebot/custom MCP hint generation, toggle gating, export injection, persistence, New Workflow reset
- **Workflow Context**: Plan field (`planInput`) persistence, serialization, export injection across formats
- **Requirements Refinement**: Refine prompt generation, Atlassian/Sourcebot MCP awareness, URL-only and Jira key blocking
- **Plan Prompt Generation**: Plan prompt generation, Sourcebot guidance, Atlassian hints, URL-only blocking
- **Cross-Feature Edge Cases**: Sourcebot tool name accuracy, plan injection, self-validation, 1M model aliases
- **Input Validation**: Jira key detection, inline hint show/hide, URL-only blocking across all action buttons
- **Usability & Help**: help modal content, prompt library (toggle, categories, favorites, input popup, copy, optional inputs, secret scanner), generate feedback toast, copy prompt validation, configInput attrs

**Running tests in a browser**: Open `tests.html` in a browser. Results render immediately with green/red badges per suite, expandable failure details with expected vs actual values.

**Running tests from CLI**: `./run-tests.sh` runs the full suite headlessly via Chrome and Python 3 (no npm). Use `--verbose` to print individual failure details. Exit code 0 = all pass, 1 = failures.

---

## Development Guidelines

- **Keep it single-file**: Resist the urge to add a build step unless complexity demands it
- **Run tests after changes**: Run `./run-tests.sh` from CLI or open `tests.html` in a browser. All tests should pass
- **Render on demand**: Call `render()` and `updatePrompt()` after any state mutation (`render()` triggers auto-save automatically)
- **Export completeness**: Every export format must include the full user story as context. Never assume the recipient has seen it
- **Prompt quality first**: The quality of exported prompts is the product's core value proposition. `getEffectivePrompt()` and the `PROMPTS` library are the most important code in the file
- **Memory injection order**: Preamble (read) before task, postamble (write) after output format. Never append memory as an afterthought at the end
- **Test with real Jira tickets**: The keyword detection in `generateFromStory()` was tuned for real-world ticket language. Validate changes against diverse examples
- **Model IDs**: Keep `MODELS` array in sync with current Anthropic model availability; the `family` field is used for SDK code generation

---

*Last updated: 2026-03-21*
