# Agentic Workflow Designer

Turn any Jira ticket, user story, or task description into a production-quality agentic workflow in seconds. The generated prompts handle the details you'd forget to include: tool selection, upstream dependencies, success criteria, output format, decision gates with revision loops. Every agent gets exactly the right instructions without you having to think of everything.

Design multi-agent pipelines visually, configure each agent's role, model, and tools, then export optimized prompts ready to paste into Claude Code, Claude.ai, or the Anthropic Agent SDK.

**[Try it live](https://bluewilliams.github.io/agentic-workflow-designer/)** - zero install, runs entirely in-browser.

## Design Philosophy

Single HTML file. No frameworks, no build step, no server, no dependencies, no drama. Open it in a browser and it works. Deploy it to GitHub Pages and it works. Send it to a colleague and it works.

All data stays in your browser (localStorage). Nothing is sent anywhere. Your requirements, prompts, and workflows never leave your machine unless you copy them yourself.

## What It Does

1. **Paste your requirements** - a Jira URL, user story, task description, or any freeform text. Jira links are detected automatically and resolved via the Atlassian MCP server. Input validation catches bare ticket keys and guides you to paste the full URL
2. **Refine & plan** (optional) - click **Refine Prompt** to have Claude interview you and sharpen vague requirements, then **Plan Prompt** to generate a codebase-aware implementation blueprint
3. **Build a workflow** - auto-generate from your input, choose from 14 curated presets, or build one manually from the node palette
4. **Configure each agent** - model, tools, custom prompts (or use built-in templates), max turns
5. **Copy the prompt** from 5 output formats optimized for different execution environments
6. **Save & load workflows** by name, export/import as `.json` files for sharing
7. **Enable Memory Protocol** (optional) for compaction-resilient workflows with TOON notation
8. **Browse the Prompt Library** - high-impact prompts for code review, security audits, debugging, planning, and more. Copy and paste into Claude Code

## Prompt Output

The bottom panel generates a ready-to-copy prompt tailored to your execution environment. Pick the tab that matches where you'll run the workflow:

| Format | Best For | What You Get |
|--------|----------|--------------|
| **Workflow** | Planning, documentation, sharing | Structured markdown overview of the full pipeline |
| **Sub-Agents** | Claude Code (most common) | Ready-to-paste Task tool calls with self-contained agent prompts |
| **Agent Teams** | Claude Code Teams (experimental) | Team lead brief with TeamCreate/TaskCreate delegation |
| **Agent SDK** | Anthropic Agent SDK | Python skeleton with agent configs and async orchestration |
| **Claude.ai** | Claude.ai / API (no CLI tools) | Step-by-step role-based prompt for single-agent execution |

Not sure which to pick? The app tells you. A recommendation banner above the tabs analyzes your workflow shape and suggests the best fit. Simple 1-2 agent workflows get pointed to Claude.ai, parallel pipelines to Sub-Agents, and larger teams to Agent Teams. Click the suggestion to switch.

## Memory Protocol

Toggle **Enable workflow memory** in the sidebar to inject a compaction-resilient memory system into exported prompts. When enabled:

- Each agent reads memory files **before** starting work (step zero)
- Each agent writes progress + breadcrumb **after** completing work (final step)
- Compaction recovery is automatic. Agents detect missing breadcrumbs and re-read state from disk
- Inter-agent communication flows through `shared.md` using TOON notation
- Memory files: `shared.md` (append-only), `@{agent}.md` (per-agent)
- Duplicate agent labels are handled automatically with unique slug suffixes

Memory auto-enables for complex workflows (parallel forks, decision gate loops, or 5+ agents) when loading presets or generating from a story. You can always toggle it on or off manually.

No infra required. The memory protocol is embedded directly in the generated prompts. It just works.

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
- **Model** - Opus 4.6, Sonnet 4.6, Haiku 4.5, Sonnet 4.5, Opus 4.5, plus 1M context variants for Opus 4.6 and Sonnet 4.6. Set a default model in the sidebar; override per-node as needed
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

## Refine & Plan

Two optional steps that dramatically improve output quality for complex tasks:

**Refine Prompt** generates a discovery interview. Paste it into Claude Code and it asks you about edge cases, UX decisions, tradeoffs, and constraints using `AskUserQuestion`, then writes a refined spec to `.claude/specs/{workflow-name}.md`. Paste the result back into Requirements.

**Plan Prompt** generates a codebase analysis prompt. Claude explores your code (via Sourcebot if available), identifies relevant files and patterns, and produces an implementation blueprint in `.claude/plans/{workflow-name}.md`. Paste the result into the Implementation Plan field so agents know HOW to build, not just WHAT to build.

Both prompts tell Claude exactly what to do next, closing the loop back to the Workflow Designer.

## Prompt Library

Click the **Prompts** button in the toolbar for a curated collection of high-impact prompts across code review, security, architecture, debugging, testing, documentation, planning, DevOps, data migrations, and more. These aren't one-liners. Each prompt encodes expert methodology: structured review checklists, multi-phase audit frameworks, systematic debugging approaches. They produce better results than asking from scratch.

Prompts that need context (like "what file to analyze") show an input popup before copying so the prompt is ready to paste with no editing. Star your favorites and they float to the top.

## MCP Integrations

Global toggles for **Atlassian** (Jira/Confluence) and **Sourcebot** (cross-repo code search), plus a freeform field for custom MCP tools. When enabled, prompt hints are injected into all exports so agents use these tools instead of slower alternatives. The Prompt Library also includes tool guidance for prompts that benefit from cross-repo search or Jira context.

## More Under the Hood

- **Smart story detection** auto-generates an appropriate workflow shape from your requirements keywords
- **Acceptance criteria extraction** parses bullet/numbered criteria from requirements and uses them as decision gate conditions
- **Decision gates** are embedded as success criteria in upstream agent prompts, with explicit reasoning requirements and configurable revision limits
- **Multi-repository support** lets you specify multiple repos with branches; agents check out the right branch before starting
- **Pull Request creation** is an opt-in output format with git provider auto-detection (GitHub, Bitbucket, GitLab) and safety-first defaults
- **Secret scanner** checks all user inputs for API keys, credentials, and connection strings before copying to clipboard
- **Input validation** catches bare Jira ticket keys, URL-only input without Atlassian MCP, and insufficient keywords for generation
- **Workflow-aware prompts** include upstream dependencies, downstream consumers, and the full requirements in every agent's instructions
- **Persistent preferences** for default model, memory toggle, MCP settings, output format, repositories, and prompt library favorites carry across sessions automatically

## Things You Might Not Notice

- **New Workflow**: The small "New Workflow" link next to the Workflow Name heading clears everything and starts fresh. Save or export your current workflow first if you want to keep it.
- **Auto-naming**: Leave the workflow name blank and it generates a memorable two-part name (e.g. `swift-falcon`). Every workflow gets a unique identity for memory paths and file exports.
- **Generate feedback**: After auto-generating a workflow, a toast tells you how many agents were created so you know it worked.
- **Right-click context menu**: Right-click any node for quick access to Duplicate, Disconnect All, and Delete.
- **Empty prompt detection**: When you copy a prompt, the app warns if any agents have empty prompts (they won't know what to do).
- **Keyboard shortcuts**: `1` `2` `3` for Select/Connect/Delete modes, `?` for help, `Delete` to remove selected, `Alt+Drag` to pan.
- **Zoom to fit**: Click **Fit** in the toolbar to auto-zoom so all nodes are visible.
- **Preset-specific placeholders**: When you pick a preset, the Requirements textarea updates with a template tailored to that workflow type (steps to reproduce for bugs, acceptance criteria for features, etc.).
- **Jira URL detection**: Paste a Jira URL instead of requirements and the app detects it, then asks you to pick a workflow type (Feature, Bug Fix, UI Design, Full Stack, Test Automation) since there aren't enough keywords to auto-generate.
- **Quick patterns**: The palette includes Fork (2/3/4) and Fan-Out shortcuts that scaffold parallel agent groups in one click.
- **Custom workflows**: Not limited to presets. Add any combination of nodes from the palette and wire them up however you want. The prompt generators handle the scaffolding.

## Save & Load

Workflows persist automatically. Your canvas is auto-saved on every change and restored on page refresh.

### Named Workflows
Click **Save** in the sidebar to save the current workflow by name. Saved workflows appear in a list. Click to load, click × to delete. Same-name saves overwrite the previous version.

### Export / Import
Click **Export .json** to download the workflow as a portable file. Click **Import** to load a `.json` file from a colleague or another browser. All data stays local (localStorage). Nothing is sent to a server.

### Preferences
Your default model, memory toggle, output format tab, app source path/branch, and repositories are remembered automatically. No explicit save needed. Just change a setting and it persists across sessions.

## Testing

Open `tests.html` in any browser. That's it. Zero dependencies, zero build step. Tests load `index.html` in a hidden iframe and exercise everything: utilities, state management, persistence, memory protocol, all 5 prompt output generators, workflow generation, preset loading, format recommendations, input validation, the prompt library, and more. Green/red results render instantly.

**CLI runner**: `./run-tests.sh` runs headlessly via Chrome + Python 3. No npm, no Jest, no Webpack. Use `--verbose` for failure details. Exit code 0 = all pass.

## Getting Started

Open `index.html` in any modern browser. Or deploy to GitHub Pages. There is no step three.

CLI test runner (`run-tests.sh`) needs Chrome/Chromium + Python 3. That's the entire dependency list.

## How the Prompts Work

Each output format generates workflow-aware prompts that include:

- **Role context** - what the agent is responsible for
- **Tool awareness** - which tools are available
- **Memory read** (when enabled) - check breadcrumbs, recover from compaction
- **Task methodology** - numbered steps with clear deliverables
- **Input dependencies** - output from upstream agents to review
- **Success gates** - downstream decision criteria baked into the agent prompt
- **Output format** - structured response guidance for the next step
- **Memory write** (when enabled) - persist progress, hand off via shared.md, write breadcrumb
- **Full requirements** - the complete story/ticket, never truncated

Agents know their place in the pipeline and produce output the next agent can act on immediately. No manual glue code, no copy-pasting between steps.

## License

MIT
