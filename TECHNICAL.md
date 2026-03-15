# Agentic Workflow Designer: Technical & Product Reference

> A living document. Update this whenever architecture, features, or product goals evolve.

---

## High-Level Objectives

### Problem
Engineers working with AI-powered development (Claude Code, Anthropic Agent SDK, Agent Teams) face a consistent challenge: translating a Jira ticket or user story into a well-structured multi-agent prompt is complex and time-consuming. The mental model of "which agents do what, in what order, with what instructions" is hard to hold in your head and even harder to communicate to a team.

### Solution
The Agentic Workflow Designer is a **visual, browser-based playground** that bridges the gap between a requirements document and a production-ready agentic workflow prompt. Users drag, drop, and connect nodes on a canvas to design their multi-agent pipeline, then copy a fully-formed prompt into Claude Code, Claude.ai, or the Anthropic Agent SDK.

### Core User Journey
1. Paste a Jira ticket or user story into the sidebar
2. Click **Generate Workflow** (or pick a preset, or build manually)
3. The canvas populates with agent nodes connected in the right order
4. Optionally reconfigure each node (agent type, model, tools, custom prompt)
5. Toggle **Memory Protocol** on/off as needed
6. Select an export format tab and click **Copy**
7. Paste the output into Claude Code or the Agent SDK and run it
8. Optionally **Save** the workflow by name, or **Export .json** to share with colleagues

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
│              │   (5 export format tabs)         │
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
  defaultModel: 'opus-4.6', // Global default for new nodes
  repositories: [] // Array of { path, branch } for multi-repo workflows
}
```
No frameworks, no reactive libraries. Each user action calls `render()` which does a full DOM diff-free re-render of the SVG canvas and triggers `updatePrompt()`.

### Persistence (localStorage)
All persistence uses `localStorage` so the app remains a single portable HTML file with no server dependencies.

| Key | Shape | Purpose |
|-----|-------|---------|
| `awd_prefs` | `{ defaultModel, memoryEnabled, appSourcePath, appSourceBranch, exportFormat, repositories }` | User preferences, auto-saved on change and auto-restored on load |
| `awd_workflows` | `[ { slug, name, savedAt, nodeCount, agentCount }, ... ]` | Index of saved workflows (metadata only) |
| `awd_wf_{slug}` | `{ version, slug, name, story, savedAt, repositories, canvas: { nodes, connections, nextId, pan, zoom } }` | Full saved workflow data |
| `awd_autosave` | Same shape as `awd_wf_{slug}` | Single-slot auto-save, debounced 1s on `render()` |

**Serialization boundary**: Nodes (full config), connections, nextId, pan, zoom, workflowName, storyInput, repositories, and memoryEnabled are persisted. Transient UI state (selectedId, mode, connectFrom, dragging, isPanning, mousePos) is excluded.

**Error handling**: All localStorage operations are wrapped in try/catch. Auto-save fails silently; explicit save/export shows a toast on failure.

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
- **Agent Type**: Planner, Architect, Coder, Frontend, Backend, Reviewer, Tester, Debugger, Researcher, Writer, General
- **Writing Style** (Writer only): Technical, User Guide, Business, API Reference, Runbook. Auto-configures tools and prompt template per style
- **Model**: Opus 4.6 (default), Sonnet 4.6, Sonnet 4.5, Opus 4.5, Haiku 4.5
- **Tools**: Checkboxes for Read, Write, Edit, Bash, Grep, Glob, WebSearch, WebFetch, Task, LSP
- **Agent Prompt**: Freeform textarea. If left blank, falls back to `getEffectivePrompt()`
- **Custom Notes**: Additional context injected into all export formats
- **Max Turns**: Integer cap on the agent's execution turns

---

## Prompt Generation System

### `getEffectivePrompt(node)`: 3-Tier Fallback (with Writer style resolution)
```
User-entered prompt
  → Writer style template (writer + capitalize(writingStyle) → PROMPTS[writerTechnical|writerBusiness|...])
    → Agent type template (AGENT_TYPE_PROMPT_MAP → PROMPTS[key])
      → Smart generic fallback using node label
```
For Writer agents, the writing style (stored in `node.config.writingStyle`) is resolved to a style-specific prompt key before falling back to the generic agent type map. This ensures exported prompts always contain real instructions, even if the user never touches the prompt field.

### `PROMPTS` Library
30+ pre-written agent prompt templates covering:
- **Planning/Architecture**: `planner`, `architect`
- **Implementation**: `implementer`, `backend`, `frontend`
- **Investigation/Fix**: `investigator`, `fixer`
- **Review**: `reviewer`, `fullstackReviewer`, `codeAnalyzer`, `codeReviewer`, `improver`
- **Testing/Validation**: `tester`, `bugTester`, `e2eTester`, `validator`
- **Research**: `codebaseExplorer`, `docResearcher`, `patternAnalyzer`, `synthesizer`
- **Audit**: `securityAuditor`, `qualityAnalyst`, `perfProfiler`, `archReviewer`, `reportBuilder`
- **Test Automation (SET)**: `appExplorer`, `testPlanner`, `featureWriter`, `screenObjectWriter`, `stepDefWriter`, `testReviewer`
- **Writer**: `writerTechnical`, `writerUserguide`, `writerBusiness`, `writerApi`, `writerRunbook`
- **Cross-cutting**: `securityReview`, `testWriter`, `researcher`

Each template is structured with numbered steps, expected outputs, handoff summaries, and output format guidance.

---

## Export Formats

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

### Pull Request Creation (`prBlock()`)
When any output node has `format: pr`, the `prBlock()` helper injects PR creation instructions into all 5 export formats. The block includes:
- **Hard safety rule**: never commit or push directly to the target branch
- **Branch name**: uses the user-provided name, or derives from ticket ID in requirements, or generates a descriptive name
- **Target branch**: uses the user-provided value, or defaults to `main`
- **Git provider detection**: parses `git remote -v` to determine GitHub/Bitbucket/GitLab and uses the appropriate CLI tool (`gh`, Atlassian MCP, `glab`)
- **Graceful fallback**: if PR creation fails (auth, missing tool), pushes the branch and provides the user a URL to create the PR manually

All presets default to `format: 'code'`. PR creation is strictly opt-in: users must select "Pull Request" from the Format dropdown and configure the branch fields.

### Decision Gate Quality
All export formats enforce structured decision evaluation:
- **Reasoning requirement**: Agents must evaluate each criterion systematically and show reasoning before stating a verdict
- **Revision limits**: Decision gates include a configurable max revision count (default 3) to prevent infinite loops. After the limit, agents proceed with the best version and document remaining concerns
- **Decision Routing (Sub-Agents)**: The Sub-Agents format includes a dedicated "Decision Routing" section that tells the orchestrator exactly how to handle pass/fail results, including which agents to re-spawn on failure

### Format Recommendations
A smart banner above the export tabs analyzes the current workflow shape and suggests the best export format:
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

---

## Canvas Interaction

### Modes
- **Select** (default, `1`): Click to select, drag to move nodes
- **Connect** (`2`): Click source → click target to draw an edge
- **Delete** (`3`): Click a node or edge to remove it

### Navigation
- **Pan**: Alt+drag or middle-mouse drag
- **Zoom**: Scroll wheel (0.2×–3×)
- **Auto Layout**: BFS-based topological layout, left-to-right, vertical centering per layer
- **Zoom Fit**: Scales viewport to show all nodes with 80px padding

### Context Menu
Right-click a node to access: Duplicate, Add Branch (Parallel only), Disconnect All, Delete.

---

## Workflow Generation (`generateFromStory`)

Parses the user story with keyword detection to build an appropriate workflow automatically:

| Keywords Detected | Workflow Shape |
|---|---|
| Bug/fix/crash/error | Input → Investigator → Fixer → Tester → Decision → Output |
| UI + API keywords | Input → Planner → Parallel(Backend, Frontend) → Reviewer → Decision → Tester → Output |
| UI only or API only | Input → Planner → Parallel(Researcher, Implementer) → Reviewer → Decision → Tester → Output |
| Security keywords | Adds a Security Review agent before the main reviewer |

After generation, memory is auto-enabled if the workflow has parallel forks or 5+ agents. If the workflow name field is empty, `ensureWorkflowName()` auto-generates a memorable two-part name (e.g. `swift-falcon`) from built-in adjective/noun word lists so every workflow gets a unique memory path. Then `autoLayout()` arranges nodes cleanly.

---

## Presets

| Preset | Pattern |
|--------|---------|
| **Feature Development** | Input → Planner → Implementer → Reviewer → Tester → Feature Complete (code) |
| **Bug Fix** | Input → Investigator → Fixer → Tester → Decision → Fix Complete (code) |
| **Full Stack Feature** | Input → Architect → Parallel(Backend, Frontend) → Reviewer → Tester → Feature Ready (code) |
| **Code Review** | Input → Analyzer → Reviewer → Improver → Validator → Improved Code (code) |
| **Parallel Research** | Input → Fork → (Codebase Explorer ‖ Doc Researcher ‖ Pattern Analyzer) → Join → Synthesizer → Research Report (report) |
| **Agent Swarm** | Input → Fork → (Security Auditor ‖ Quality Analyst ‖ Perf Profiler ‖ Arch Reviewer) → Join → Report Builder → Audit Report (report) |
| **Test Automation** | (Jira Ticket + App Source) → Fork → (Test Planner ‖ App Explorer) → Join → Fork → (Feature Writer ‖ Screen Objects ‖ Step Definitions) → Join → Test Reviewer → Decision → Test Suite (code) |
| **UI Design & Development** | Input → Design System Analyzer → UI Implementer → UI Reviewer → Component Ready (code) |
| **Refactoring** | Input → Planner → Code Analyzer → Refactorer → Reviewer → Decision → Tester → Refactored Code (code) |
| **Documentation** | Input → Planner → Researcher → Doc Writer (Writer: Technical) → Doc Reviewer → Documentation (docs) |
| **DevOps** | Input → Planner → DevOps Engineer → Reviewer → Decision → Tester → Infrastructure Ready (code) |
| **Performance** | Input → Planner → Profiler → Optimizer → Reviewer → Decision → Tester → Optimized (report) |
| **Testing** | Input → Planner → Code Analyzer → Test Suite Writer → Reviewer → Decision → Tester → Test Suite (code) |
| **Data Migration** | Input → Planner → Researcher → Migration Engineer → Reviewer → Decision → Tester → Migration Complete (code) |

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
| Safe-by-default output format | All presets use `format: 'code'` (local changes only). PR creation requires explicit opt-in to prevent agents from pushing code or creating branches without user intent |
| `prBlock()` prompt injection | PR instructions are only injected when at least one output node has `format: pr`. Provider detection via `git remote -v` works for GitHub, Bitbucket, and GitLab with graceful fallback |
| TOON v1 for memory files | Compact notation reduces token usage in agent context while preserving structured state |
| Memory auto-enable criteria | Parallel forks, decision loops, or 5+ agents. Simple linear chains stay off to avoid unnecessary overhead. `generateFromStory` excludes decision gates from criteria since it adds one to every code workflow by default |
| localStorage for persistence | No server needed; keeps single-file portability; auto-save + named save + JSON export covers all sharing needs |
| Debounced auto-save (1s) | Saves on every render without impacting interaction performance |
| Separate prefs vs. workflow storage | Preferences (model, memory, format) persist globally; workflows persist individually by slug |
| App Under Test after Presets | Contextual placement. Appears directly below the preset that triggers it (Test Automation) |
| Repositories between Default Model and Add Nodes | Always visible. Persists across sessions (prefs) and saved workflows. Injected into all 5 export formats |

---

## Known Limitations & Future Opportunities

### Current Limitations
- **No undo/redo**: Changes are irreversible without clearing the canvas
- **No multi-select**: Can only select one node or edge at a time
- **Agent SDK export is pseudocode**: The Python output requires manual adaptation to real SDK patterns
- **Decision routing in exports is informational**: Most exports describe decision gates as prompt instructions. The Sub-Agents format includes explicit routing, but the Agent SDK still requires manual conditional logic
- **Memory is prompt-only**: No deterministic pre-compaction hook exists; agents rely on frequent writes and breadcrumb detection
- **localStorage only**: Persistence is browser-local; clearing browser data deletes saved workflows

### High-Value Future Features
1. **Undo/Redo**: Command pattern or immutable state snapshots
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
├── index.html       # The entire application (~4,300 lines)
├── tests.html       # iframe-based test suite (~1,210 lines, 206 tests)
├── run-tests.sh     # Headless CLI test runner (Chrome + Python 3, zero npm deps)
├── TECHNICAL.md     # This document
├── README.md        # User-facing overview
├── LICENSE          # MIT
└── .gitignore
```

The `index.html` is internally organized into clearly delimited sections:
```
CSS styles (lines 7–258)
HTML structure (lines 259–559)
  ├── Sidebar: Workflow Name, Story Input (+ Refine), Implementation Plan, Default Model, Repositories,
  │            Add Nodes, Presets, App Under Test (conditional), Saved Workflows, Tip, MCP Integrations, Memory, Node Config
  ├── Canvas: Toolbar, SVG canvas, Empty state
  └── Prompt Output: 5 format tabs, Copy button
JavaScript:
  ├── STATE & CONSTANTS
  │     ├── NODE_DEFAULTS, AGENT_TYPES (11 types), ALL_TOOLS, MODELS
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
  ├── EXPORT FORMAT SYSTEM
  │     ├── getFormatRecommendation()    # workflow shape analysis
  │     ├── updateFormatRec()            # recommendation banner rendering
  │     ├── prBlock()          # PR creation prompt injection (when format=pr)
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

`tests.html` is a zero-dependency, iframe-based test harness. Open it in any browser to run all tests — no build step, no server required.

**How it works**: Loads `index.html` in a hidden `<iframe>`, accesses its `contentWindow` for all functions, state, and DOM. Tests run against the real app with real localStorage and real initialization.

**Coverage** (206 tests across 16 suites):
- **Pure utilities**: `slugify`, `extractAcceptanceCriteria`, `isUrlOnly`, `getEffectivePrompt`, `getModelLabel`
- **State management**: `addNode`, `addConnection`, `deleteNode`, `buildAgentSlugMap`, `topologicalSort`
- **Persistence**: serialize/deserialize roundtrips, prefs save/restore, workflow save/load
- **Memory protocol**: path generation, TOON notation, slug collisions, auto-enable logic
- **Export generators**: all 5 formats (Workflow, Sub-Agents, Agent Teams, Agent SDK, Claude.ai) with memory on/off
- **Workflow generation**: keyword scoring, structural properties, AC extraction
- **Preset loading**: agent count verification for all 14 presets, memory auto-enable behavior
- **Format recommendations**: agent count and parallel fork heuristics
- **Workflow auto-naming**: name generation format, variety, empty-field population, user name preservation
- **Writer Agent Type**: config panel interactions, writing style switching, prompt/tool updates, export output
- **Model Version Handling**: Full model IDs (e.g. `claude-opus-4-6`, `claude-sonnet-4-5-20251001`) and Claude Code aliases (e.g. `opus[1m]`) passed directly in Task tool `model` parameter and all export formats, including 1M context window variants
- **MCP Integrations**: Atlassian/Sourcebot/custom MCP hint generation, toggle gating, export injection, persistence, clear-all reset
- **Implementation Plan**: Plan field persistence, serialization, export injection across formats, clear-all reset
- **Requirements Refinement**: Refine prompt generation with requirements inclusion, Atlassian/Sourcebot MCP awareness, workflow name slugification, spec file path generation, user redirect instructions
- **Plan Prompt Generation**: Plan prompt generation with requirements context, Sourcebot codebase exploration guidance, Atlassian hints, Jira URL-only handling, plan file path generation, user redirect instructions
- **Cross-Feature Edge Cases**: Sourcebot tool name accuracy, plan injection across all export formats, self-validation in exports, 1M model aliases, whitespace-only plan handling, MCP hint toggle behavior

**Running tests in a browser**: Open `tests.html` in a browser. Results render immediately — green/red badges per suite, expandable failure details with expected vs actual values.

**Running tests from CLI**: `./run-tests.sh` runs the full suite headlessly via Chrome and Python 3 (no npm). Use `--verbose` to print individual failure details. Exit code 0 = all pass, 1 = failures.

---

## Development Guidelines

- **Keep it single-file**: Resist the urge to add a build step unless complexity demands it
- **Run tests after changes**: Run `./run-tests.sh` from CLI or open `tests.html` in a browser. All 206 tests should pass
- **Render on demand**: Call `render()` and `updatePrompt()` after any state mutation (`render()` triggers auto-save automatically)
- **Export completeness**: Every export format must include the full user story as context. Never assume the recipient has seen it
- **Prompt quality first**: The quality of exported prompts is the product's core value proposition. `getEffectivePrompt()` and the `PROMPTS` library are the most important code in the file
- **Memory injection order**: Preamble (read) before task, postamble (write) after output format. Never append memory as an afterthought at the end
- **Test with real Jira tickets**: The keyword detection in `generateFromStory()` was tuned for real-world ticket language. Validate changes against diverse examples
- **Model IDs**: Keep `MODELS` array in sync with current Anthropic model availability; the `family` field is used for SDK code generation

---

*Last updated: 2026-03-01*
