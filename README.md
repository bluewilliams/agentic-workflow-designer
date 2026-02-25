# Agentic Workflow Designer

A visual, interactive playground for designing AI agent workflows from Jira tickets and user stories. Design multi-agent pipelines, configure each agent's role, model, and tools, then export optimized prompts ready to paste into Claude Code, Claude.ai, or the Anthropic Agent SDK.

**[Try it live](https://bluewilliams.github.io/agentic-workflow-designer/)** - No install required, runs entirely in-browser.

## What It Does

1. **Paste a Jira ticket or user story** into the story input
2. **Auto-generate a workflow** or build one manually from the node palette
3. **Configure each agent** - model, tools, prompt, max turns
4. **Export** in 6 formats optimized for different execution environments
5. **Save & load workflows** by name, export/import as `.json` files for sharing
6. **Enable Memory Protocol** (optional) for compaction-resilient workflows with TOON notation

## Export Formats

| Format | Use Case | Output |
|--------|----------|--------|
| **Workflow** | Planning & documentation | Structured markdown overview |
| **Sub-Agents** | Claude Code (Task tool) | Ready-to-paste Task tool calls with comprehensive prompts |
| **Agent Teams** | Claude Code Teams | Team lead brief with TeamCreate/TaskCreate delegation plan |
| **Agent SDK** | Anthropic Agent SDK | Python skeleton with agent configs and async orchestration |
| **Claude Prompt** | Claude.ai / API | Step-by-step role-based prompt for single-agent execution |
| **Manifest** | Portability & sharing | TOON v1 workflow definition — git-committable, diff-friendly |

## Memory Protocol

Toggle **Enable workflow memory** in the sidebar to inject a compaction-resilient memory system into exported prompts. When enabled:

- Each agent reads memory files **before** starting work (step zero)
- Each agent writes progress + breadcrumb **after** completing work (final step)
- Compaction recovery is automatic — agents detect missing breadcrumbs and re-read state from disk
- Inter-agent communication flows through `shared.md` using TOON notation
- Memory files: `manifest.md` (read-only), `shared.md` (append-only), `@{agent}.md` (per-agent)

No install required — the memory protocol is embedded directly in the generated prompts.

## Built-in Presets

- **Feature Build** - Planner > Implementer > Reviewer > Tester
- **Bug Fix** - Investigator > Fixer > Tester > Verification gate
- **Full Stack** - Architect > parallel Backend + Frontend > Review > E2E Test
- **Code Review** - Analyzer > Reviewer > Improver > Validator
- **Parallel Research** - Codebase Explorer + Doc Researcher + Pattern Analyzer > Synthesizer
- **Agent Swarm** - Security + Quality + Performance + Architecture audit > Report
- **Test Automation** - [Test Planner | App Explorer] > parallel Feature Writer + Screen Objects + Step Definitions > Test Reviewer (with app source path + branch support)

## Node Types

- **Agent** - Configurable AI agent with role, model, tools, and prompt
- **Decision** - Conditional gate with pass/fail criteria (integrated into agent prompts)
- **Parallel Fork** - Split workflow into concurrent branches
- **Input** - Story/requirements entry point
- **Output** - Deliverable definition

## Key Features

- **SVG canvas** with pan, zoom, and drag-and-drop
- **Smart story detection** - auto-generates appropriate workflow from story keywords
- **Decision gate integration** - downstream decisions are embedded as success criteria in agent prompts
- **Workflow-aware prompts** - agents know their upstream dependencies and downstream consumers
- **Save/Load workflows** - save by name, auto-restore work-in-progress on refresh, export/import `.json` for sharing
- **Persistent preferences** - default model, memory toggle, export format, app source path, and repositories auto-save across sessions
- **Multi-repository support** - specify multiple repos with branches; agents check out the right branch and pull latest before starting
- **Memory Protocol** - optional compaction-resilient memory with TOON v1 notation
- **TOON Manifest** - portable, git-friendly workflow definition format
- **Custom workflows** - add your own nodes and connections; export generators add smart scaffolding automatically
- **Model selection** - Sonnet 4.5/4.6, Opus 4.5/4.6, Haiku 4.5 with correct Task tool keys

## Save & Load

Workflows persist automatically. Your canvas is auto-saved on every change and restored on page refresh.

### Named Workflows
Click **Save** in the sidebar to save the current workflow by name. Saved workflows appear in a list — click to load, click × to delete. Same-name saves overwrite the previous version.

### Export / Import
Click **Export .json** to download the workflow as a portable file. Click **Import** to load a `.json` file from a colleague or another browser. All data stays local (localStorage) — nothing is sent to a server.

### Preferences
Your default model, memory toggle, export format tab, app source path/branch, and repositories are remembered automatically. No explicit save needed — just change a setting and it persists across sessions.

## Usage

Open `index.html` in any modern browser. No dependencies, no build step, no server required.

Or deploy via GitHub Pages - the file is named `index.html` so it works automatically.

## How the Prompts Work

Each export format generates workflow-aware prompts that include:

- **Role context** - what the agent is responsible for
- **Tool awareness** - which tools are available
- **Memory read** (when enabled) - check breadcrumbs, recover from compaction
- **Task methodology** - numbered steps with clear deliverables
- **Input dependencies** - output from upstream agents to review
- **Success gates** - downstream decision criteria baked into the agent prompt
- **Output format** - structured response guidance for the next step
- **Memory write** (when enabled) - persist progress, hand off via shared.md, write breadcrumb
- **Full requirements** - the complete story/ticket, never truncated

This means agents know their place in the pipeline and produce output that the next agent can act on immediately.

## License

MIT
