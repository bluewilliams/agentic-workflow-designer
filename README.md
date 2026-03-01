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
| **Manifest** | Portability & sharing | TOON v1 workflow definition. Git-committable, diff-friendly |

## Memory Protocol

Toggle **Enable workflow memory** in the sidebar to inject a compaction-resilient memory system into exported prompts. When enabled:

- Each agent reads memory files **before** starting work (step zero)
- Each agent writes progress + breadcrumb **after** completing work (final step)
- Compaction recovery is automatic. Agents detect missing breadcrumbs and re-read state from disk
- Inter-agent communication flows through `shared.md` using TOON notation
- Memory files: `manifest.md` (read-only), `shared.md` (append-only), `@{agent}.md` (per-agent)
- Duplicate agent labels are handled automatically with unique slug suffixes

Memory auto-enables for complex workflows (parallel forks, decision gate loops, or 5+ agents) when loading presets or generating from a story. You can always toggle it off manually.

No install required. The memory protocol is embedded directly in the generated prompts.

## Built-in Presets

- **Feature Build** - Planner > Implementer > Reviewer > Tester
- **Bug Fix** - Investigator > Fixer > Tester > Verification gate
- **Full Stack** - Architect > parallel Backend + Frontend > Review > E2E Test
- **Code Review** - Analyzer > Reviewer > Improver > Validator
- **Parallel Research** - Codebase Explorer + Doc Researcher + Pattern Analyzer > Synthesizer
- **Agent Swarm** - Security + Quality + Performance + Architecture audit > Report
- **Test Automation** - [Test Planner | App Explorer] > parallel Feature Writer + Screen Objects + Step Definitions > Test Reviewer (with app source path + branch support)
- **UI Design & Development** - Design System Analyzer > UI Implementer > UI Reviewer
- **Refactoring** - Planner > Code Analyzer > Refactorer > Reviewer > Decision gate > Tester
- **Documentation** - Planner > Researcher > Doc Writer > Doc Reviewer
- **DevOps** - Planner > DevOps Engineer > Reviewer > Decision gate > Tester
- **Performance** - Planner > Profiler > Optimizer > Reviewer > Decision gate > Tester
- **Testing** - Planner > Code Analyzer > Test Suite Writer > Reviewer > Decision gate > Tester
- **Data Migration** - Planner > Researcher > Migration Engineer > Reviewer > Decision gate > Tester

## Node Types

- **Agent** - Configurable AI agent with role, model, tools, and prompt
- **Decision** - Conditional gate with pass/fail criteria, configurable max revision cycles (integrated into agent prompts with reasoning requirements)
- **Parallel Fork** - Split workflow into concurrent branches
- **Input** - Story/requirements entry point
- **Output** - Deliverable definition (format: Code Changes, Pull Request, Report, or Documentation). When format is Pull Request, additional fields appear for Branch Name and Target Branch

## Key Features

- **SVG canvas** with pan, zoom, and drag-and-drop
- **Smart story detection** - auto-generates appropriate workflow from story keywords
- **Decision gate integration** - downstream decisions are embedded as success criteria in agent prompts, with explicit reasoning requirements and configurable revision limits
- **Format recommendations** - a smart banner above the export tabs suggests the best format based on your workflow shape (agent count, parallel forks)
- **Requirements scaffolding** - preset-specific placeholder templates guide you to provide the right information (steps to reproduce for bugs, acceptance criteria for features, etc.)
- **Acceptance criteria extraction** - when generating from requirements, bullet/numbered acceptance criteria are automatically extracted and used as decision gate conditions
- **Workflow-aware prompts** - agents know their upstream dependencies and downstream consumers
- **Save/Load workflows** - save by name, auto-restore work-in-progress on refresh, export/import `.json` for sharing
- **Persistent preferences** - default model, memory toggle, export format, app source path, and repositories auto-save across sessions
- **Multi-repository support** - specify multiple repos with branches; agents check out the right branch and pull latest before starting
- **Memory Protocol** - optional compaction-resilient memory with TOON v1 notation, auto-enabled for complex workflows
- **TOON Manifest** - portable, git-friendly workflow definition format
- **Pull Request creation** - opt-in PR output format with git provider auto-detection (GitHub, Bitbucket, GitLab), configurable feature branch and target branch, and safety-first prompt injection. All presets default to Code Changes; PR creation requires explicit opt-in
- **Custom workflows** - add your own nodes and connections; export generators add smart scaffolding automatically
- **Model selection** - Sonnet 4.5/4.6, Opus 4.5/4.6, Haiku 4.5 with correct Task tool keys

## Save & Load

Workflows persist automatically. Your canvas is auto-saved on every change and restored on page refresh.

### Named Workflows
Click **Save** in the sidebar to save the current workflow by name. Saved workflows appear in a list. Click to load, click × to delete. Same-name saves overwrite the previous version.

### Export / Import
Click **Export .json** to download the workflow as a portable file. Click **Import** to load a `.json` file from a colleague or another browser. All data stays local (localStorage). Nothing is sent to a server.

### Preferences
Your default model, memory toggle, export format tab, app source path/branch, and repositories are remembered automatically. No explicit save needed. Just change a setting and it persists across sessions.

## Testing

Open `tests.html` in any browser to run the full test suite (129 tests, zero dependencies). Tests load `index.html` in a hidden iframe and exercise utilities, state management, persistence, memory protocol, all 6 export generators, workflow generation, preset loading, and format recommendations. Green/red results render instantly with expandable failure details.

**CLI runner**: `./run-tests.sh` runs headlessly via Chrome + Python 3 (no npm). Use `--verbose` for failure details. Exit code 0 = all pass.

## Requirements

- Any modern browser (Chrome, Firefox, Safari, Edge)
- No server, no build step, no dependencies

For the CLI test runner (`run-tests.sh`): Chrome/Chromium + Python 3.

## Usage

Open `index.html` in any modern browser. That's it.

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
