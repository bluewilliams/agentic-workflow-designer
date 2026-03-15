# Agentic Workflow Designer

Turn any Jira ticket, user story, or task description into a production-quality agentic workflow in seconds. Built on context engineering best practices, the generated prompts handle the details you'd forget to include - tool selection (like telling agents to use LSP), upstream dependencies, success criteria, output format - so every agent gets exactly the right instructions without you having to think of everything.

Design multi-agent pipelines visually, configure each agent's role, model, and tools, then export optimized prompts ready to paste into Claude Code, Claude.ai, or the Anthropic Agent SDK.

**[Try it live](https://bluewilliams.github.io/agentic-workflow-designer/)** - No install required, runs entirely in-browser.

## Design Philosophy

Single HTML file. No frameworks, no build step, no server, no dependencies. Open it in a browser and it works. Deploy it to GitHub Pages and it works. Send it to a colleague and it works.

All data stays in your browser (localStorage). Nothing is sent to a server. Export workflows as `.json` files to share with your team, or save them by name and pick up where you left off.

## What It Does

1. **Paste your requirements** - a Jira URL, user story, task description, or any freeform text. Jira links are detected automatically and resolved via the Atlassian MCP server
2. **Build a workflow** - auto-generate from your input, choose from 14 curated presets, or build one manually from the node palette
3. **Configure each agent** - model, tools, prompt, max turns
4. **Export** in 5 formats optimized for different execution environments
5. **Save & load workflows** by name, export/import as `.json` files for sharing
6. **Enable Memory Protocol** (optional) for compaction-resilient workflows with TOON notation

## Export Formats

| Format | Use Case | Output |
|--------|----------|--------|
| **Workflow** | Planning & documentation | Structured markdown overview |
| **Sub-Agents** | Claude Code (Task tool) | Ready-to-paste Task tool calls with comprehensive prompts |
| **Agent Teams** | Claude Code Teams | Team lead brief with TeamCreate/TaskCreate delegation plan |
| **Agent SDK** | Anthropic Agent SDK | Python skeleton with agent configs and async orchestration |
| **Claude.ai** | Claude.ai / API | Step-by-step role-based prompt for single-agent execution |

## Memory Protocol

Toggle **Enable workflow memory** in the sidebar to inject a compaction-resilient memory system into exported prompts. When enabled:

- Each agent reads memory files **before** starting work (step zero)
- Each agent writes progress + breadcrumb **after** completing work (final step)
- Compaction recovery is automatic. Agents detect missing breadcrumbs and re-read state from disk
- Inter-agent communication flows through `shared.md` using TOON notation
- Memory files: `shared.md` (append-only), `@{agent}.md` (per-agent)
- Duplicate agent labels are handled automatically with unique slug suffixes

Memory auto-enables for complex workflows (parallel forks, decision gate loops, or 5+ agents) when loading presets or generating from a story. Workflows created without a name get an auto-generated two-part name (e.g. `swift-falcon`) so every workflow has a unique memory path. You can always overwrite the name or toggle memory off manually.

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
- **Documentation** - Planner > Researcher > Doc Writer (Writer: Technical) > Doc Reviewer
- **DevOps** - Planner > DevOps Engineer > Reviewer > Decision gate > Tester
- **Performance** - Planner > Profiler > Optimizer > Reviewer > Decision gate > Tester
- **Testing** - Planner > Code Analyzer > Test Suite Writer > Reviewer > Decision gate > Tester
- **Data Migration** - Planner > Researcher > Migration Engineer > Reviewer > Decision gate > Tester

## Node Types & Configuration

Click any node on the canvas to open its configuration panel. Each node type has unique settings:

### Agent
The core building block. Every agent can be individually configured:
- **Agent Type** - Planner, Architect, Coder, Frontend, Backend, Reviewer, Tester, Debugger, Researcher, Writer, or General. Each type has a built-in prompt template that activates when you leave the prompt blank. Writer agents have a **Writing Style** selector (Technical, User Guide, Business, API Reference, Runbook) that auto-configures tools and prompt for each discipline
- **Model** - Opus 4.6, Sonnet 4.6, Haiku 4.5, Sonnet 4.5, Opus 4.5 — plus 1M context variants for Opus 4.6 and Sonnet 4.6. Set a default model in the sidebar; override per-node as needed
- **Tools** - Toggle individual tools on/off: Read, Write, Edit, Bash, Grep, Glob, WebSearch, WebFetch, Task, LSP. Presets assign sensible defaults (e.g. Reviewers get read-only tools, Coders get everything)
- **Agent Prompt** - Custom instructions. Leave blank to use the agent type's built-in template, or write your own
- **Custom Notes** - Additional context injected into the generated prompt (constraints, implementation details)
- **Max Turns** - Limits how many agentic turns the agent can take (default: 10)

### Decision
A conditional gate that loops agents back for revisions when criteria aren't met:
- **Condition** - The criteria to evaluate (e.g. "All tests pass and code review has no critical findings")
- **Yes/No Labels** - Customize the branch labels (default: Yes/No, presets use Pass/Revise)
- **Max Revisions** - Caps the revision loop to prevent infinite cycles (default: 3)

Decision criteria are automatically embedded into upstream agent prompts so agents know what they're being evaluated against.

### Parallel Fork
Splits the workflow into concurrent branches:
- **Strategy** - Wait for All (default), First Complete, or Race

### Input
- **Source** - Jira Ticket, User Story, PRD, or Custom
- **Description** - Requirements text. Preset-specific placeholder templates guide you to provide the right information

### Output
- **Format** - Code Changes, Pull Request, Report, or Documentation
- **Deliverable** - Description of what's produced
- **Branch Name / Target Branch** - Appear when format is Pull Request, with git provider auto-detection

### Preset-Specific Settings

Some presets reveal additional sidebar sections:
- **Test Automation** shows an **App Under Test** field - specify the local path to the app being tested so agents can explore its source for DOM selectors, screen structure, and locator patterns (Selenium, Playwright, etc.)
- **UI Design & Development** shows a **UI Context** field for styling preferences and design system notes (e.g. "Use vanilla-extract + clsx, avoid SCSS")

## Key Features

- **SVG canvas** with pan, zoom, and drag-and-drop
- **Smart story detection** - auto-generates appropriate workflow from story keywords
- **Decision gate integration** - downstream decisions are embedded as success criteria in agent prompts, with explicit reasoning requirements and configurable revision limits
- **Format recommendations** - a smart banner above the export tabs suggests the best format based on your workflow shape (agent count, parallel forks)
- **Requirements scaffolding** - preset-specific placeholder templates guide you to provide the right information (steps to reproduce for bugs, acceptance criteria for features, etc.)
- **Acceptance criteria extraction** - when generating from requirements, bullet/numbered acceptance criteria are automatically extracted and used as decision gate conditions
- **Workflow-aware prompts** - agents know their upstream dependencies and downstream consumers
- **Save/Load workflows** - save by name, auto-restore work-in-progress on refresh, export/import `.json` for sharing
- **Persistent preferences** - default model, memory toggle, MCP integrations, export format, app source path, and repositories auto-save across sessions
- **Multi-repository support** - specify multiple repos with branches; agents check out the right branch and pull latest before starting
- **Memory Protocol** - optional compaction-resilient memory with TOON v1 notation, auto-enabled for complex workflows
- **Pull Request creation** - opt-in PR output format with git provider auto-detection (GitHub, Bitbucket, GitLab), configurable feature branch and target branch, and safety-first prompt injection. All presets default to Code Changes; PR creation requires explicit opt-in
- **Custom workflows** - add your own nodes and connections; export generators add smart scaffolding automatically
- **Model selection** - Sonnet 4.5/4.6, Opus 4.5/4.6, Haiku 4.5 per node, plus 1M context variants for Opus 4.6 and Sonnet 4.6. Full model IDs (e.g. `claude-opus-4-6`, `claude-sonnet-4-5-20251001`) or Claude Code aliases (e.g. `opus[1m]`) are passed directly in all exports
- **Implementation Plan** - optional field to paste a Claude Code plan (from `/plan` mode). Provides codebase-specific context — file paths, patterns, architecture — so agents know HOW to implement, not just WHAT to build. Included in all exports and persisted with saved workflows
- **MCP Integrations** - global toggles for Atlassian (on by default) and Sourcebot (on by default, cross-repo code search) MCPs, plus a freeform field for custom MCPs. When enabled, prompt hints are injected into all exports so agents prefer these tools over built-in alternatives
- **Requirements Refinement** - click **Refine** to generate a discovery interview prompt. Run it in Claude Code and it interviews you about edge cases, UX decisions, tradeoffs, and technical constraints using `AskUserQuestion`, then writes a refined spec to `.claude/specs/{workflow-name}.md`. Paste the result back into Requirements for sharper prompts

## Save & Load

Workflows persist automatically. Your canvas is auto-saved on every change and restored on page refresh.

### Named Workflows
Click **Save** in the sidebar to save the current workflow by name. Saved workflows appear in a list. Click to load, click × to delete. Same-name saves overwrite the previous version.

### Export / Import
Click **Export .json** to download the workflow as a portable file. Click **Import** to load a `.json` file from a colleague or another browser. All data stays local (localStorage). Nothing is sent to a server.

### Preferences
Your default model, memory toggle, export format tab, app source path/branch, and repositories are remembered automatically. No explicit save needed. Just change a setting and it persists across sessions.

## Testing

Open `tests.html` in any browser to run the full test suite (190 tests, zero dependencies). Tests load `index.html` in a hidden iframe and exercise utilities, state management, persistence, memory protocol, all 5 export generators, workflow generation, preset loading, format recommendations, workflow auto-naming, and requirements refinement. Green/red results render instantly with expandable failure details.

**CLI runner**: `./run-tests.sh` runs headlessly via Chrome + Python 3 (no npm). Use `--verbose` for failure details. Exit code 0 = all pass.

## Getting Started

Open `index.html` in any modern browser (Chrome, Firefox, Safari, Edge). Or deploy via GitHub Pages - it works automatically.

The CLI test runner (`run-tests.sh`) requires Chrome/Chromium + Python 3.

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
