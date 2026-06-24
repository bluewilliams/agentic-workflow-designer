# Agentic Workflow Designer

Turn any Jira ticket, user story, or task description into a production-quality agentic workflow in seconds. The generated prompts handle the details you'd forget to include: tool selection, upstream dependencies, success criteria, output format, decision gates with revision loops. Every agent gets exactly the right instructions without you having to think of everything.

Design multi-agent pipelines visually, configure each agent's role, model, and tools, then export optimized prompts ready to paste into Claude Code, Claude.ai, or the Anthropic Agent SDK.

**[Try it live](https://bluewilliams.github.io/agentic-workflow-designer/)** - zero install, runs entirely in-browser.

## Quick Start

If you just want to get work done, this is the whole path:

1. **Open it** - the [live link](https://bluewilliams.github.io/agentic-workflow-designer/), or `index.html` in any browser.
2. **Paste your requirements** - a Jira URL, a user story, or a plain sentence describing the task, into the Requirements box.
3. **Pick a preset** - click one that matches the work (Feature Build, Bug Fix, Documentation, ...). It drops a ready-made pipeline on the canvas. (Or click **Auto Workflow** to auto-build one from your text.)
4. **Copy the prompt** - hit **Copy** on the **Sub-Agents** tab (the default for Claude Code). The banner above the tabs will point you to a different tab if your workflow fits one better.
5. **Send it to Claude** - paste into Claude Code and let the agents run.

That is the core loop. Everything below is optional polish - tweaking agents, adding review loops, turning on memory, and so on.

## Design Philosophy

Single HTML file. No frameworks, no build step, no server, no dependencies, no drama. Open it in a browser and it works. Deploy it to GitHub Pages and it works. Send it to a colleague and it works.

All data stays in your browser (localStorage). Nothing is sent anywhere. Your requirements, prompts, and workflows never leave your machine unless you copy them yourself.

## What It Does

1. **Paste your requirements** - a Jira URL, user story, task description, or any freeform text. Jira links are detected automatically and resolved via the Atlassian MCP server. Input validation catches bare ticket keys and guides you to paste the full URL
2. **Refine & plan** (optional) - click **Generate Refine Prompt** to have Claude interview you and sharpen vague requirements, then **Generate Plan Prompt** to generate a codebase-aware implementation blueprint
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

### Durable Record (committable artifact)

Workflow memory is ephemeral agent scratch state under `~/.claude/` that keeps a run alive across compaction. When you also want a record the work can be **handed off and committed**, check **Keep a durable record** (it appears under the memory toggle, since a durable record builds on memory - it is a strict superset).

When enabled, the generated prompts instruct agents to maintain one persistent, human-readable document that is:

- the **resumable handoff doc** while work is in progress (an H1 title and one-line context, a Why-and-scope, a **Requirements** contract, the approach and decisions, a surface-area map of the files touched, a **work-breakdown task checklist** - the concrete coding/research/test tasks a developer tracks, not the workflow's agent steps - a Verify section with the real build/test commands and results, any risks/gotchas, plus a current-state/next-action note and a resume note), and
- the **committable artifact** when the work is done (the Requirements with their verifying tests, an outcome summary, the decisions, the completed work-breakdown checklist, a **Built-with provenance** line recording the workflow and the agent roles that produced the change, and branch/PR links).

The centerpiece is the **Requirements** section: each requirement is a normative MUST/SHALL statement of one behavior, followed by the Given/When/Then scenarios that define it - the happy path *and* the boundary, null, negative, and error cases - and the name of the test that verifies each scenario. That makes it both the spec and the acceptance criteria, and it is what a future agent or maintainer leans on to validate the system as they work. Alongside it sit a **Success criteria** block (measurable, technology-agnostic outcomes a non-technical stakeholder can read) and a **Spec quality check** (a short self-validation gate: requirements testable, scope bounded, no open clarifications, every scenario has a verifying test). The contents are deliberately at least on par with what spec-driven tools commit (requirements, approach, tasks, decisions, risks, migration), with things those tools tend to lack: per-scenario test traceability, a Verify section recording the real build/test results (so the artifact doubles as an eval substrate), a current-state/next-action handoff, and a Built-with provenance line. It stays one navigable document - a conditional Contents index links the sections once the record grows large, and small changes stay small (most sections are omit-when-empty). A future maintainer (human or agent) gets the what, the why, the contract, the how, the surface area, and how it was built in one place.

Any agent in the workflow keeps the record current by action, not by role: whoever makes a decision updates the decisions, whoever changes files updates the surface area, whoever runs the build or tests updates Verify, and the last (synthesizing) agent writes the outcome and strips the in-progress scaffolding for commit. The minute-to-minute step progress (which agent is running now) lives only in that scaffolding and is removed on commit, so the committed artifact stays clean while the durable provenance stays.

Set the **Artifact Path** to control where it lands. It defaults to a conventional in-repo path (`.workflow/{slug}.md`) so it versions with the code in the same PR. For work that spans multiple repositories, a record is written in **each** touched repo (describing that repo's slice) and the records cross-link through their shared work item plus sibling links, so every repo stays self-describing.

As records accumulate, the generated prompts also maintain a lightweight **breadcrumb index** at `.workflow/_index.md` - one structured entry per record (grouped by a stable capability slug, with facets for the files touched, work item, epic, status, and supersession lineage), written at finalize. Future workflows and people scan the index first to decide which records are worth opening, instead of reading them all; when a later change re-works a capability the old record is kept and marked superseded, so the index always points at current behavior with the history one hop away.

**Reading those records back is automatic.** A **Ground in prior records** toggle (on by default) injects a runtime-conditional instruction telling the planning step to scan `.workflow/_index.md` if it exists, open only the records relevant to the files and capability the change touches (preferring current ones), and fold their decisions and gotchas into the plan - so accumulated records ground future work without anyone remembering to turn it on. The index (what touches X) is the default entry point; when recency matters (chasing a recent regression, onboarding onto an unfamiliar area, or resuming paused work) it also scans the chronological `.workflow/_timeline.md` (newest first) and opens what it points at, forming a three-tier lookup: timeline (when) leads to index (what) leads to the record (detail). It is self-gating (a no-op on greenfield repos), and if a planned change replaces a behavior a current record defines, the instruction has the planner reconcile against it and supersede it at finalize. Switch it off for clean-slate tasks. Producing a record is opt-in; benefiting from existing ones is automatic.

An optional **Clarify requirements first** toggle (off by default) adds a clarification gate. When checked, the planning step probes the requirements for material ambiguity across a structured taxonomy (under-specified or conflicting behavior, edge/null/error cases, data shapes and contracts, scope boundaries, and non-functional constraints), asks the director a focused set of questions in one round, waits for the answers, then folds each resolution into the plan and into the durable record as a resolved decision (so the spec quality check can confirm no open clarifications remain). It degrades gracefully when run non-interactively - in CI or an SDK pipeline it records the open questions as assumptions and risks and proceeds rather than blocking. It is the in-flow equivalent of a spec-driven tool's clarify step, and it raises the floor for less-experienced directors without taxing anyone who leaves it off.

The durable record holds the spec-and-state of the work in one place. The ephemeral memory keeps the run alive; the durable record makes it resumable by another engineer and auditable after the fact. Both are off by default and add nothing to a simple workflow.

### Handoff bundle

When a larger task needs to pass between engineers, click **Handoff** (next to Export .json) to download a single self-contained Markdown package, `{slug}-handoff.md`. It contains:

- **How to resume** - numbered steps starting from the durable record (the live state), then how to re-run.
- **The durable record path** - where the spec-and-state lives (committed in the repo, or attached to the work item for cross-repo work).
- **The ready-to-run prompt** - the current generated prompt, so the receiving engineer can run immediately.
- **The workflow definition** - the serialized workflow, so they can import it back into the designer to edit the pipeline.

If a workflow was seeded only with a work-item URL, the prompt and definition are intentionally thin - the agent fetches the ticket at runtime, and the resolved context the previous engineer worked from lives in the durable record. The bundle says so, so the receiver trusts the durable record for the current spec and state. The handoff bundle pairs naturally with Durable Record; without a durable record there is no captured state to resume from, and the bundle says that too.

## Repo Context Paths

The **Repo Context Paths** sidebar section lets you point agents at a repo's own rules and product docs, so generated workflows read and honor more than just the per-task spec. It captures path strings only (the designer never touches your filesystem); the agents do the reading. Two optional chip lists, each with a text input, an Add button, per-chip remove, Clear-all, and one-click quick-add suggestions:

- **Rules / constitution paths** (binding; CLAUDE.md already read) - paths whose rules and conventions are binding constraints on HOW you build. Quick-add: `.claude/rules`, `CONVENTIONS.md`, `CONTRIBUTING.md`.
- **Product docs (PRD / ADR)** (goals/direction to honor) - paths describing the goals and direction the work must serve and not contradict. Quick-add: `docs/`, `ARCHITECTURE.md`, `docs/adr/`.

This is the **three-tier context model** the generated prompts make explicit:

1. **Constitution / rules** = how to build (binding). The repo CLAUDE.md is auto-loaded for free; these inputs capture extra rule paths on top of it.
2. **Product / architecture docs (PRD / ADR)** = goals and direction the work must serve and not contradict, and (when a durable record is kept) intent to snapshot into its Why and scope.
3. **Spec** = this task's contract - already the existing requirements/seed input, so it is not a separate field here.

When a list is non-empty, its hint is injected into all five export formats, instructing agents to read only what is listed (no blind-hunt), to use directory-vs-file discovery (a directory: discover relevant files by common name; a file: read it directly), and - in a multi-repo run - to resolve each path within each in-scope repository and never carry one repo's context into another's. The lists are **sticky**: they persist to localStorage and survive a New Workflow reset (only Clear-all empties them), because they are repo-level context that carries across workflows in the same repo. When both lists are empty, nothing is injected and output is unchanged.

### Multi-repo gotcha: CLAUDE.md only auto-loads for the launch repo

Worth knowing for multi-repo workflows: Claude Code auto-loads `CLAUDE.md` and `.claude/rules/` only for the **directory the session launched in** (its tree). A second repository cloned elsewhere is outside that tree, so **its `CLAUDE.md` is not loaded automatically** - and subagents inherit the launch repo's rules rather than re-scanning new directories. So an agent working in repo B can silently miss repo B's rules.

The generated multi-repo prompt handles this for you: it instructs each agent to **read every working repo's own `CLAUDE.md` / `CLAUDE.local.md` / `.claude/rules/` before changing it**, and your listed Rule Paths are resolved per-repo (which also covers files that never auto-load anywhere, like `CONVENTIONS.md` / `CONTRIBUTING.md`). So if you select three repos and list `.claude/rules` once, each repo's own rules are honored for changes made in that repo - you do not need a per-repo entry, and you do not need the environment variable below. It is an **optional** reliability boost that *also* makes Claude Code auto-load each added repo's `CLAUDE.md` at startup:

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../repo-b ../repo-c
```

`--add-dir` grants file access to the extra repos; the env var makes their `CLAUDE.md` load at startup (and thus propagate to subagents). The explicit per-repo read in the prompt is the fallback that works no matter how the session was launched.

## Built-in Presets

- **Feature Build** - Planner > (Skeptic reviews the plan) > Implementer > Reviewer > Decision gate > Tester
- **Bug Fix** - Investigator > Fixer > Tester > Verification gate
- **Full Stack** - Architect > parallel Backend + Frontend > Review > E2E Test
- **Code Review** - Analyzer > Reviewer > Improver > Validator
- **Parallel Research** - mode-aware. Codebase-internal: Codebase Explorer + Doc Researcher + Pattern Analyzer > Synthesizer. Landscape/advisory: Current-State Inventory + Options Researcher + Fit & Tradeoff Analyzer > Advisor (writes ADVISORY.md)
- **Review Swarm** - parallel Security + Quality + Performance + Architecture audit > Aggregate > Report Builder > Audit Report (read-only, never touches code)
- **Delivery Swarm** - the showcase. Discovery fan-out (Codebase Cartographer + Requirements Analyst + Prior-Art Researcher) > Synthesize > Lead Planner (Skeptic doubts the plan) > parallel Backend + Frontend > Integrator (Verifier proves it runs) > Code Review gate > Test > Feature Delivered
- **Test Automation** - [Test Planner | App Explorer] > parallel Feature Writer + Screen Objects + Step Definitions > Test Reviewer (with app source path + branch support)
- **UI Design & Development** - Design System Analyzer > UI Implementer > (Verifier proves it works in a browser) > UI Reviewer
- **Refactoring** - Planner > Code Analyzer > Refactorer > Reviewer > Decision gate > Tester
- **Documentation** - Planner > Researcher > Doc Writer (Writer: Technical) > (Skeptic reviews the docs)
- **DevOps** - Planner > DevOps Engineer > Reviewer > Decision gate > Tester
- **Performance** - Planner > Profiler > Optimizer > Reviewer > Decision gate > Tester
- **Testing** - Planner > Code Analyzer > Test Suite Writer > Reviewer > Decision gate > Tester
- **Data Migration** - Planner > Researcher > Migration Engineer > Reviewer > Decision gate > Tester

## Node Types & Configuration

Click any node on the canvas to open its configuration panel. Each node type has unique settings:

### Agent
The core building block. Every agent can be individually configured:
- **Agent Type** - Planner, Architect, Coder, Frontend, Backend, Reviewer, Tester, Debugger, Researcher, Writer, General, plus **Skeptic** and **Verifier** (the review-loop roles - see [Review Loops](#review-loops-skeptic--verifier-one-click)). Each type has a built-in prompt template that activates when you leave the prompt blank. Writer agents have a **Writing Style** selector (Technical, User Guide, Business, API Reference, Runbook) that auto-configures tools and prompt for each discipline
- **Model** - Fable 5, Opus 4.8, Opus 4.7, Opus 4.6, Sonnet 4.6, Haiku 4.5, Sonnet 4.5, Opus 4.5, plus 1M context variants for Fable 5, Opus 4.8, Opus 4.7, Opus 4.6, and Sonnet 4.6. The default stays Opus 4.8; set a different default in the sidebar or override per-node as needed. Max plan users get 1M context by default. API and Pro users can select 1M variants for research-heavy or long-running agents where the extra context window makes a difference
- **Tools** - Toggle individual tools on/off: Read, Write, Edit, Bash, Grep, Glob, WebSearch, WebFetch, Task, LSP. Presets assign sensible defaults (e.g. Reviewers get read-only tools, Coders get everything)
- **Agent Prompt** - Custom instructions. Leave blank to use the agent type's built-in template, or write your own
- **Agent Context** - Additional context injected into this agent's prompt section (constraints, implementation details). The workflow-wide counterpart is the **Workflow Context** field in the sidebar
- **Max Turns** - Limits how many agentic turns the agent can take (default: 10)

### Decision
A conditional gate that loops agents back for revisions when criteria aren't met:
- **Condition** - The criteria to evaluate (e.g. "All tests pass and code review has no critical findings")
- **Yes/No Labels** - Customize the branch labels (default: Yes/No, presets use Pass/Revise)
- **Max Revisions** - Caps the revision loop to prevent infinite cycles (default: 3)

Decision criteria are automatically embedded into upstream agent prompts so agents know what they're being evaluated against.

### Task
A unit of work (not an agent step). Both fields flow into the generated prompt:
- **Description** - what the task does
- **Acceptance Criteria** - when present, emitted as the task's explicit "Done when:" criteria

Task nodes render as a **Tasks** section in every generator. Adding them changes nothing for workflows that have none (no preset uses Task nodes).

### Parallel Fork
Splits the workflow into concurrent branches. **Strategy** shapes the join semantics in every generator (the default reproduces today's output exactly; the other two only change output when chosen):
- **Wait for All** (default) - collect every branch before continuing
- **First Complete** - proceed with the first branch to finish (Agent SDK maps this to `asyncio.wait(..., FIRST_COMPLETED)`)
- **Race** - take the first useful result and stop waiting on the rest

### Input
- **Source** - how to frame the pasted input: **Freeform** (default, neutral), or **User Story** / **PRD**, which add a one-line framing hint telling agents how to read it. Jira handling is automatic and *content-driven* (independent of this selector): paste a Jira URL - bare or inline - and the orchestrator is instructed to read the ticket thoroughly (description, acceptance criteria, comments, attachments) and is given the agency to pull wider context (parent epic, sub-tasks, linked/related issues) when it would genuinely help - encouraged, never required. Plain text without a Jira URL is treated as the requirements as-is
- **Description** - Requirements text. Preset-specific placeholder templates guide you to provide the right information

### Output
The Output node's **Format** is the single delivery control - it decides what happens to the work at the end. Code changes are produced either way (even with no output node, changes are left uncommitted for review); the format only chooses the finish:
- **Leave Uncommitted** (default) - make the changes, commit nothing
- **Commit** - feature branch, commit + push, no PR
- **Pull Request** - feature branch, commit + push, open a PR (git provider auto-detected: GitHub, Bitbucket, GitLab)
- **Report** - produce a written report; leave any code uncommitted
- **Documentation** - produce docs following the project's conventions; leave any code uncommitted

Other fields: **Deliverable** (what's produced), **Branch Name** (Commit and Pull Request), and **Target Branch** (Pull Request only). No preset defaults to Pull Request - commit/push/PR is always an explicit choice.

### Preset-Specific Settings

Some presets reveal additional sidebar sections:
- **Test Automation** shows an **App Under Test** field - specify the local path to the app being tested so agents can explore its source for DOM selectors, screen structure, and locator patterns (Selenium, Playwright, etc.)
- **UI Design & Development** shows a **UI Context** field for styling preferences and design system notes (e.g. "Use vanilla-extract + clsx, avoid SCSS")
- **Parallel Research** shows a **Research Mode** selector on the fork node (codebase-internal / landscape-advisory / hybrid), plus an **Options to Evaluate** slot and an **Evaluation Bias / Principle** field. Mode is inferred from your requirements (our own code vs external options) and can be changed at any time; the agents re-bake to match. Advisory mode does a current-state inventory (LSP stays available but the heavy call-hierarchy tracing is gated off), enumerates the full option space including status-quo and lighter-weight alternatives, scores every option on a shared rubric, and ends with an Advisor that writes ADVISORY.md (CTO-ready summary, scored matrix, follow-up tickets, open questions). Recommending the minimal or do-nothing option is a valid conclusion.

## Review Loops: Skeptic & Verifier (one-click)

The strongest workflows don't just produce work - they check it. Right-click any **Agent or Task** node and you get two one-click options that build a review-and-revise loop around that step in a single action (and remove it just as easily). Each one drops in a reviewer, a decision gate, and a back-edge that routes problems back to the step to fix, reusing the same revision-loop machinery the presets use - so it renders correctly in every output format. Both are undoable in one step.

- **Add skeptic review** - attaches a **Skeptic**: a refute-first critic that hunts for what is *wrong* by inspection. It runs a strict materiality bar - its default verdict is PASS, and it only loops work back for genuinely material defects (a correctness bug, a missing edge/null/error case, a requirement not met, a security issue, scope over-reach, a test that doesn't actually verify the behavior). It never sends work back for style or nitpicks, and it tailors what it scrutinizes to the kind of work under review (a plan, code, research, tests, docs, ...). Verdict: `PASS` / `NEEDS REVISION`.
- **Add verification** - attaches a **Verifier**: it proves the outcome actually *meets the objective*, with evidence, by exercising the work - running the tests, calling the API, driving the app in a browser, following the documentation steps to confirm they produce the stated outcome, reconciling the data, and so on. It climbs an evidence ladder and never fakes a pass: if something genuinely can't be verified, it says so rather than rubber-stamping. Verdict: `VERIFIED` / `NOT VERIFIED`, with failures looped back to fix.

The pattern they're built for is **doubt early, prove late**: put a Skeptic on the plan to catch the expensive errors before you build, and a Verifier on the final step to prove the outcome before you ship. You'll see this in the presets - Feature Build reviews the Planner with a Skeptic, Documentation reviews the Doc Writer with one, and UI Design verifies the built component with a Verifier.

**Route failures where they belong.** By default a loop sends problems back to the step it's attached to. But sometimes the real fix is upstream - if a Verifier near the end can't verify the outcome because the *plan* was incomplete, re-running the implementer won't help. Select the loop's decision gate and use **"On {failure}, route back to"** to send the failure branch to any earlier step (the Planner, say) instead. The back-edge redraws on the canvas to wherever you point it, so the routing is always visible. It defaults to the reviewed node, so you only touch it when you want to.

A few guardrails keep the graph sane: one review loop per node, and review nodes (Skeptics and Verifiers) can't themselves be reviewed - the one-click only offers what makes sense. (You can always wire an exotic graph by hand.) Both are also available as regular agent types in the node dropdown if you'd rather place them manually. Add a **Custom Note** to either one to give it task-specific acceptance criteria - they're strong out of the box without it.

## Refine & Plan

Two optional steps that dramatically improve output quality for complex tasks:

**Generate Refine Prompt** generates a discovery interview. Paste it into Claude Code and it asks you about edge cases, UX decisions, tradeoffs, and constraints using the `AskUserQuestion` tool, then writes a refined spec to `.claude/specs/{workflow-name}.md`. Paste the result back into Requirements.

**Generate Plan Prompt** generates a codebase analysis prompt. Claude explores your code (via a code-search MCP if available, for example Sourcebot, Sourcegraph, or Kilo Code, with a Glob/Grep/LSP fallback otherwise), identifies relevant files and patterns, and produces an implementation blueprint in `.claude/plans/{workflow-name}.md`. Paste the result into the Workflow Context field so agents know HOW to build, not just WHAT to build.

Both prompts tell Claude exactly what to do next, closing the loop back to the Workflow Designer.

A third option, the **Clarify requirements first** toggle (see [Memory Protocol](#memory-protocol)), does the same kind of clarification as Generate Refine Prompt but *inside* the workflow's planning step rather than as a separate up-front prompt. Rule of thumb: **Refine** sharpens the *what* (rough requirements to a spec), **Plan** sharpens the *how* (codebase-aware approach), and **Clarify** is the lighter in-flow version of Refine when you want a single self-contained prompt. They stack for a big task; flip on Clarify alone for a lighter touch.

## Prompt Library

Click the **Prompts** button in the toolbar for a curated collection of high-impact prompts across code review, security, architecture, debugging, testing, documentation, planning, DevOps, data migrations, and more. These aren't one-liners. Each prompt encodes expert methodology: structured review checklists, multi-phase audit frameworks, systematic debugging approaches. They produce better results than asking from scratch.

Prompts that need context (like "what file to analyze") show an input popup before copying so the prompt is ready to paste with no editing. Star your favorites and they float to the top.

### Live Monitors

The Prompt Library includes a dedicated **Live Monitors** category with prompts that watch things for you over time, leveraging state across iterations to do things a single run can't:

- **PR Build Babysitter** - watch CI checks, summarize failures, stop when green
- **PR Review Watcher** - get notified of new comments, approvals, or merge without context-switching
- **Post-Deploy Canary Monitor** - continuously compare error rates and latency against pre-deploy baseline, escalate on regression
- **Test Flake Detector** - run your test suite repeatedly and statistically identify flaky tests by tracking pass/fail oscillation
- **Sprint Stale Work Alert** - monitor Jira for stories stuck in progress, unassigned blockers, and scope creep
- **Long-Running Task Companion** - start a migration, build, or data import and walk away; get alerted on errors, progress milestones, or completion
- **Code Review Soak Test** - continuously review your git diff as you code, flagging bugs and security issues in real-time while filtering out noise
- **Service Recovery Watcher** - during an incident, track recovery trend and confirm when the service is stable

Each prompt includes an **Exit** condition so the loop self-terminates when its job is done (build goes green, PR merges, service recovers, etc.) rather than running indefinitely.

## Recommended Setup

The Workflow Designer works standalone out of the box, but these optional integrations unlock significantly better results:

### MCP Servers

| MCP Server | What it enables | Install |
|------------|----------------|---------|
| **Atlassian** | Agents fetch Jira ticket and Confluence page details at runtime instead of needing content pasted in | Built into Claude Code. Enable in Settings or via `claude mcp add` |
| **Code search (MCP)** | Cross-repo code search with any compatible MCP server (for example Sourcebot, Sourcegraph, or Kilo Code; none required). Agents discover repos, browse trees, search code, and read files to explore your codebase, falling back to Glob/Grep/LSP when no such MCP is connected | Any code-search MCP works. Sourcebot ([sourcebot.dev](https://sourcebot.dev)) is self-hosted with a free tier; add via `claude mcp add -s user --transport http sourcebot http://localhost:4242/api/mcp` |
| **Datadog** | Observability prompts query logs, metrics, traces, and monitors directly. Bug Fix workflows automatically check production error context during investigation when available | Install CLI: `curl -sSL https://coterm.datadoghq.com/mcp-cli/install.sh \| bash` then `datadog_mcp_cli login` then `claude mcp add -s user datadog -- ~/.local/bin/datadog_mcp_cli --endpoint-path "/api/unstable/mcp-server/mcp?toolsets=core,alerting,apm"` |

Toggle Atlassian and Code search (MCP) on/off in the sidebar. When enabled, prompt hints are injected into all exports so agents prefer these tools. The Prompt Library includes dedicated categories for cross-repo analysis (which works with any code-search MCP such as Sourcebot) and Datadog (observability) prompts, with Chrome browser fallback when MCPs aren't installed.

### LSP (Language Server Protocol)

The **LSP** tool toggle on agent nodes gives agents access to go-to-definition, find-references, and type information. This produces significantly better results for code analysis, refactoring, and debugging prompts. LSP works automatically in Claude Code when your project has the appropriate language server installed:

| Language | LSP Server | Install |
|----------|-----------|---------|
| TypeScript/JavaScript | `typescript-language-server` | `npm i -g typescript-language-server typescript` |
| Python | `pylsp` or `pyright` | `pip install python-lsp-server` or `npm i -g pyright` |
| Go | `gopls` | `go install golang.org/x/tools/gopls@latest` |
| Rust | `rust-analyzer` | Install via rustup or your IDE |
| Java | `jdtls` | Typically bundled with IDE extensions |

LSP is enabled by default on most agent presets. Code-analysis prompts in the Prompt Library include guidance to use LSP tools when available.

## More Under the Hood

- **Smart story detection** auto-generates a bespoke workflow shape from your requirements: a 13-category keyword engine (inflection-tolerant, so "tests"/"endpoints"/"migrations" all count) routes build, research (read-only spike → report), review (read-only audit → report), and analysis (measure/forecast cost → report) intents, defaults to building under ambiguity (a read-only research/review/test/docs shape is only chosen when the task asks to *produce* a read-only deliverable, so a build task with test-heavy acceptance criteria still gets an implementer), wraps a Skeptic on the plan and a Verifier on complex builds, and tells you what it detected so you can rephrase or pick a preset
- **Acceptance criteria extraction** parses bullet/numbered criteria from requirements and uses them as decision gate conditions
- **Decision gates** are embedded as success criteria in upstream agent prompts, with explicit reasoning requirements and configurable revision limits
- **Multi-repository support** lets you specify multiple repos with branches; agents check out the right branch before starting
- **Pull Request creation** is an opt-in output format with git provider auto-detection (GitHub, Bitbucket, GitLab) and safety-first defaults
- **Secret scanner** checks all user inputs for API keys, credentials, and connection strings before copying to clipboard
- **Input validation** catches bare Jira ticket keys, URL-only input without Atlassian MCP, and insufficient keywords for generation
- **Workflow-aware prompts** include upstream dependencies (each tagged with the producing agent's type, e.g. "Mapper (Researcher)", so a step knows the role behind each input), downstream consumers, and the full requirements in every agent's instructions
- **Persistent preferences** for default model, memory toggle, MCP settings, output format, repositories, and prompt library favorites carry across sessions automatically

## Things You Might Not Notice

- **New Workflow**: The small "New Workflow" link next to the Workflow Name heading clears everything and starts fresh. Save or export your current workflow first if you want to keep it.
- **Auto-naming**: Leave the workflow name blank and it generates a memorable two-part name (e.g. `swift-falcon`). Every workflow gets a unique identity for memory paths and file exports.
- **Generate feedback**: After auto-generating a workflow, a toast tells you how many agents were created so you know it worked.
- **Right-click context menu**: Right-click any node for quick access to Duplicate, Disconnect All, and Delete. On agent and task nodes it also offers **Add skeptic review** and **Add verification** (the one-click [review loops](#review-loops-skeptic--verifier-one-click)); on a parallel fork it offers Add Branch.
- **Empty prompt detection**: When you copy a prompt, the app warns if any agents have empty prompts (they won't know what to do).
- **Undo/Redo**: Toolbar buttons or `Ctrl+Z` / `Cmd+Z` to undo, `Ctrl+Shift+Z` / `Cmd+Shift+Z` to redo. Covers adding, deleting, connecting, disconnecting, and dragging nodes. 50-step history.
- **Workflow validation**: A health indicator in the toolbar shows a green check or amber warning count. Click it to see issues like disconnected nodes, empty prompts, or incomplete decision gates. Catches problems before you copy the prompt.
- **Token estimate**: The approximate token count of the generated prompt appears next to the Copy button so you can gauge cost and context usage.
- **Clone workflow**: Click **Clone** in the Saved Workflows section to duplicate the current workflow under a new name. Useful for creating variants without losing the original.
- **Prompt Library search**: Type in the search box to filter prompts by title or description across all categories.
- **Keyboard shortcuts**: `1` `2` `3` for Select/Connect/Delete modes, `?` for help, `Delete` to remove selected, `Alt+Drag` to pan, `Ctrl+Z` to undo.
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
