# Multi-Repo & Context Paths section declutter

Context: no work item (direct session polish, director-requested; sibling pass to memory-section-declutter). Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- The Multi-Repo & Context Paths section carries tightened copy: the repo-list intro and the Repo Context Paths intro are short, the CLAUDE.md story appears once and stays accurate (auto-loaded in the launch repo; the generated prompt has agents read the other repos' copies) with the survive-New-Workflow guarantee kept, the Rules sub-line reads "(binding constraints on how to build)", the Verification sub-line reads "(what a change must prove; routed to the owning Verifier, else the final Tester)", and the inline-notes label reads "Inline notes (optional): mandates without a file, same MUST/SHOULD language:".
- Suggestion buttons deduplicate against configured paths: `syncPathSuggest(suggestId, paths)` hides a dashed suggestion whose path is already added and shows it again when the chip is removed. The three suggest containers gained ids (`rulesPathSuggest`, `productDocPathSuggest`, `verifyPathSuggest`), and the sync runs at the end of `renderRulesRows` / `renderProductDocRows` / `renderVerifyRows` - the functions every mutation path and the prefs-restore already run through, so load-time state is covered for free.
- The full ownership and CLAUDE.md story still lives on its deep surfaces (Help modal, emitted verification beat); the sidebar carries the short form only.
- Everything else in the section is untouched: ids, inputs, chip rendering, Clear All, the fail-the-run posture checkbox, and all emitted-prompt text.

## Why and scope

The section was the wordiest block in the sidebar and about a third of its text was duplication (CLAUDE.md explained twice, a four-line Verification parenthetical restating the Help modal). Suggestion chips also duplicated configured chips visually (an added VERIFY.md chip sat directly above the identical dashed suggestion). Scope: copy trims plus the one small render-time dedupe; no state shape, persistence, or emission changes.

## Verify

- `./run-tests.sh` (1614/1614; includes the new suggestion-dedupe test cycling add -> hidden -> remove -> shown across two groups)
- Visual: expanded-section screenshot confirms the tightened copy and suggestion dedupe

## History

- 2026-08-22: created - five copy trims (two intros, two sub-lines, inline-notes label; the duplicated CLAUDE.md sentence removed), `syncPathSuggest` dedupe hooked into the three chip renderers, sub-line test pin migrated + dedupe test added. 1613 -> 1614 (by direct session)
- 2026-08-22: review fix - the first trim of the context-paths intro over-compressed into two confirmed defects: "auto-read in every listed repo" misattributed prompt-instructed reads to the harness (and said nothing in the empty-list case), and the survive-New-Workflow guarantee vanished while the New Workflow button claims to clear all inputs. Intro reworded accurate-and-short; both restored (by direct session)
