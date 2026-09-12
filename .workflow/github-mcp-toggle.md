# GitHub MCP toggle (and the Atlassian label gains Bitbucket)

Context: no work item (direct session, director-requested). Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- A **GitHub (repos, PRs, issues, Actions)** checkbox sits above the Atlassian toggle in the MCP hints group, default OFF (unlike Atlassian, a GitHub MCP is not assumed present), persisted in prefs, mirroring the mcpAtlassian wiring exactly: state flag, toggle handler, prefs save/restore, one gated hint.
- `githubGeneralHint()` (gated on `mcpGithub`) rides `pushSharedHints` - the ONE injection site covering all four prompt formats - plus the SDK's comment block and an Explain lever row. The craft mirrors the house MCP posture: use it freely for context that genuinely helps (PR review threads, issues, org repos, Actions failure logs), WRITE operations only where the workflow's delivery instructions call for them (never on the agent's own initiative), no redundancy, and graceful absence (note the gap, never block).
- The Atlassian label reads **(Jira, Confluence, Bitbucket)** and its general hint names Bitbucket repos, pull requests, and pipelines - the Atlassian MCP has carried Bitbucket tools all along; the label and hint now say so.

## Why and scope

GitHub-hosted teams had no first-class hint while Atlassian teams did; and the Atlassian label undersold what its MCP already covers. Scope: markup, state/prefs wiring, one hint at the shared injection site + SDK block + Explain row, four pins. Non-goals: no delivery-format changes (PR delivery stays the Output node's explicit choice), no default-ON (evidence-based defaults only).

## Verify

- `./run-tests.sh`: 1725 -> 1728 (hint craft incl. write-restraint and graceful absence; cross-format gated injection; label + hint Bitbucket pins)

## History

- 2026-09-12: created - toggle, hint, shared injection, SDK block, Explain row, Bitbucket label + hint update, pins. 1725 -> 1728 (by direct session)
