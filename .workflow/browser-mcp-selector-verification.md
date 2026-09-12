# Browser automation MCP + runtime selector verification

Context: no work item (direct session, director-approved from the MCP roster review; closes the parked runtime-selector-verification item from the UI-automation assessment noted in preset-prompt-craft.md). Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- A **Browser automation (Playwright MCP, Chrome DevTools, etc.)** checkbox sits above the GitHub toggle, default OFF, mirroring the mcpGithub wiring (state, toggle, prefs, workflow-level hint via pushSharedHints across all four formats + the SDK comment block + an Explain workflow row).
- `browserGeneralHint()` carries the house MCP posture tuned to browsers: use it where LIVE evidence beats static reading (UI behavior, rendered states, reproducing issues, confirming selectors, screenshots as evidence), read-mostly (state-changing app actions only where a step's task calls for them), graceful absence.
- **The un-parked centerpiece**: `browserStepHint(node)`, role-gated by `BROWSER_STEP_ROLES` (appExplorer, frontend, tester, verifier - reviewers stay in the reading lane by lane discipline), injected at all SIX per-step emission sites beside datadogStepHint (the sequential AND parallel branches of the Workflow and Claude formats, the Sub-Agents prompts, the Teams teammate blocks) plus a per-node Explain row. The appExplorer variant closes the selector loop the templates have carried all along: navigate to each mapped screen, confirm every mined selector resolves uniquely to the intended visible element, and FLIP runtime-unconfirmed marks to runtime-confirmed on evidence - turning the map's TODO column and the downstream "Selectors to Verify" handoff columns into in-run verification instead of a manual inspector pass. Executing UI roles get the general live-evidence-over-assumption variant with the same read-mostly and graceful-absence rules.

## Why and scope

Every UI-automation template already marked statically-derived selectors runtime-unconfirmed and pointed at manual verification (Appium Inspector, devtools) - the uncertainty flowed Explorer to writers to reviewer but never resolved in-run. A connected browser MCP resolves it at the source. Scope: one toggle, two hint functions, five injection sites, Explain rows, pins. Non-goals: no per-preset changes (the hints are role-gated and self-gating), no write-action license (read-mostly is the posture), no reviewer-lane injection.

## Verify

- `./run-tests.sh`: 1728 -> 1731 (workflow-hint craft; step-hint role gating incl. the reading-lane exclusion and OFF gates; cross-format injection incl. the explorer's VERIFY clause reaching all four formats)

## History

- 2026-09-12: created - toggle + browserGeneralHint + browserStepHint with BROWSER_STEP_ROLES, five injection sites, Explain rows, pins. Closes the parked runtime-selector-verification design. 1728 -> 1731 (by direct session)
- 2026-09-12: review round (6/6 confirmed, all fixed) - the step hint had missed BOTH parallel-siblings loops (a fork's explorer got Datadog and code-search hints but no selector verification - exactly the gap the record claimed closed; now at all six sites with a parallel-fork pin); the SDK's hand-inlined Atlassian comment had silently missed the Bitbucket expansion AND had long ago dropped the graceful-absence tail (all three SDK MCP blocks now render from their hint functions via the hoisted _sdkHintLines helper with closing rules - drift is structurally impossible); the three new Explain rows gained their mcp-integrations deep-links; and resetState covers mcpGithub/mcpBrowser so an assertion failure can never leak a toggle into later tests. 1731 -> 1733 (by direct session)
- 2026-09-12: label wrap fix (director screenshot: the long vendor parentheticals wrapped under the checkboxes and broke the row alignment) - the Browser automation and Code search labels shortened to one-liners ((Playwright, etc.) / (Sourcebot, etc.)) with the full vendor roll call moved to title tooltips, and the toggle CSS gained a hanging indent (flex-start + flexed text span) so ANY future wrap indents under the text, never under the checkbox. Suite steady at 1733 (by direct session)
