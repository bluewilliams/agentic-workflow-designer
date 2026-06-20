# Help modal: cover the features that had shipped without docs

Work item: Blue - the top-right Help (?) modal had drifted behind the product. Several marquee features were undocumented, and he wanted clearer guidance on the export-format types plus a Claude in Chrome recommendation. Status: DONE (uncommitted; Blue commits). Tests: 724/724.

## What was missing -> what was added

Added 3 new sections + enriched 3 existing ones in the help-body (index.html, the `<div class="help-body">` block):

1. **Review Loops (Skeptic & Verifier)** (NEW, after Editing Agent Prompts) - the one-click context-menu feature was entirely undocumented. Covers: what each does (Skeptic refutes by inspection, only Critical/High; Verifier proves by executing - runs/calls/drives a browser); **when to use which** (Skeptic on high-stakes/expensive-to-undo steps like the plan or security code; Verifier on any runnable outcome, placed late); **why powerful** (complementary - reasoning vs execution = defense in depth, doubt early/prove late; one click = reviewer + Decision + bounded back-edge; renders in every export format; Remove + send-back-target reroute). Points at the Delivery Swarm preset.

2. **Delivery (Output node format)** (NEW, after Export Formats) - documents the format-driven delivery model: Leave Uncommitted (default) / Commit / Pull Request / Report / Documentation, and that code changes happen regardless of an output node; no preset defaults to PR.

3. **Handoff** (NEW, before Export Formats) - documents the Handoff button under Saved Workflows (downloads a .md resume package: how to resume, durable-record path, ready-to-run prompt, workflow definition; live state travels with the git branch + durable record).

4. **Export Formats** (ENRICHED) - per Blue's ask, a real blurb on Workflow vs Sub-Agents vs Agent Teams: Workflow = one orchestration prompt run in a single session (adopt each role in turn); Sub-Agents = each step delegated to its own fresh-context sub-agent via the Task tool; Agent Teams = agents run concurrently as a team via a shared handoff file (Preview). Agent SDK + Claude.ai kept brief (Blue said they likely don't need more). Added a rule-of-thumb (start Workflow; Sub-Agents when context/isolation matters; Agent Teams when steps are truly independent) and noted the hint bar.

5. **Recommended Integrations** (ENRICHED) - added **Claude in Chrome** (Blue's suggestion): drives a real Chrome tab to read PR diffs, navigate the running app, and confirm a UI renders/behaves; powers the Verifier's browser checks and the PR-review/UI library prompts.

6. **Canvas Tips + Power User Tips** (ENRICHED) - right-click line now mentions the Skeptic/Verification loop actions; 3 new power tips (right-click to add a review loop; Output Format = the single delivery control; Delivery Swarm is the showcase to adapt); + Quick Patterns and not-limited-to-presets tips.

7. **How the Prompts Work** (NEW, before Export Formats) + **Under the Hood** (NEW, before Power User Tips) - Blue noticed the README has nice sections (How the Prompts Work, More Under the Hood, Things You Might Not Notice) and asked whether to mirror them. Verdict applied: "How the Prompts Work" was a clear add (conceptual, not in Help) - what every agent's prompt carries (role/methodology, tools, dependencies, success gates, full requirements, memory read/write). "Under the Hood" = a compact version covering only the AUTOMATIC behaviors not already in Help (smart detection, acceptance-criteria extraction, secret scanner, input validation, auto-naming, preset placeholders). Did NOT mirror "Things You Might Not Notice" wholesale - most (undo/validation/token/clone/shortcuts/fit/right-click) was already in Canvas Tips/Toolbar Features; added only the missing Quick Patterns + custom-workflows bits to Canvas Tips. Final help-body = 20 h3 sections.

8. **README footer link** (NEW) - a tasteful footer at the very bottom of the help-body (hairline separator, muted text, accent link) pointing to `https://github.com/bluewilliams/agentic-workflow-designer#readme` (the `#readme` anchor is branch-agnostic). The "go deeper" affordance since Help mirrors concepts but is not the full README. Test pins the URL substring.

9. **Prep-step disambiguation + repos/rules + flywheel** (Blue asked about all four). Assessment: the README already covered the flywheel (Memory Protocol L82-88) and multi-repo/rules thoroughly (Repo Context Paths + CLAUDE.md gotcha + env var L101-126); the real gap in BOTH was that Generate Refine Prompt vs Generate Plan Prompt vs Clarify-requirements-first were never disambiguated side-by-side, and Help had almost nothing on repos/rules. Added: (a) Help "Which prep step should I use?" section after Clarify - Refine sharpens the WHAT (rough->spec, interviews you), Plan sharpens the HOW (codebase-aware plan), Clarify = the in-flow lighter version of Refine; they stack. (b) Help "Multiple Repos & Rules Files" section after Jira - Repositories + Repo Context Paths (binding rules vs product docs) + the multi-repo CLAUDE.md gotcha + the CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD env-var launch command. (c) Made the flywheel explicit in Help's Ground in Prior Records ("write + read = flywheel; the more you run, the better-grounded each new workflow starts"). (d) README Refine & Plan section: added a Clarify cross-reference + Refine/Plan/Clarify rule-of-thumb. Final help-body = 22 h3 sections. Test pins 'Which prep step should I use?' + 'Multiple Repos'.

10. **Multi-repo rules wording fix** (Blue's catch). He worried the "Multi-repo gotcha" paragraph (Help + README) read as if the env var were REQUIRED or the rules might not work. VERIFIED by rendering: 3 repos selected + `.claude/rules` listed once -> the generated prompt (repoBlock steps 3-4 + rulesPathsHint) explicitly tells agents to read each in-scope repo's own CLAUDE.md/.claude/rules before changing it and scope them per-repo; the prompt itself calls the explicit per-repo read "the fallback that works no matter how the session was launched" and the env var "the most reliable way" (convenience, NOT required). Reworded both: lead with "handled for you" - listing the path once honors each repo's rules per-repo, no per-repo entry and no env var needed; the env var is explicitly an OPTIONAL reliability boost. 724/724.

11. **Clarify section cross-reference fix** (Blue thought the Generate Refine/Plan Prompt Flow sections were "absent"). VERIFIED via headless innerText + offsetParent: both DO render visibly as sections 2-3 (right after Quick Start, ~700px from top); they were just far above where Blue had scrolled (Ground/Clarify in the middle). The real issue: the Clarify section pointed to "the Generate Refine Prompt flow above" - ~12 sections up, so the reference felt broken. Fix: redirected it to the ADJACENT "Which prep step should I use?" comparison just below Clarify ("see Which prep step should I use? just below for how they differ"). Nothing was actually missing. 12. **Full reorg into grouped sections + jump-to ToC** (Blue: "the ToC sounds good, make it the best it can be"). Reorganized the 22 flat sections into **7 labeled groups** with `<h2>` group headers + a `.help-toc` "Jump to" box at the top whose 7 links call `helpJump(id)` (smooth scrollIntoView to each group header id). Groups: Getting Started | Sharpen the Task (Which prep step -> Refine Flow -> Plan Flow -> Full Flow -> Clarify - prep CONSOLIDATED) | Build the Workflow (Editing Prompts, Review Loops, Canvas Tips, Toolbar) | Give Agents Context (Jira, Multiple Repos) | Export & Delivery (How the Prompts Work, Export Formats, Delivery) | Memory, Records & Handoff (Durable Record, Ground, Handoff) | More (Prompt Library, Recommended Integrations, Under the Hood, Power User Tips). Cross-refs auto-fixed for the new order (Clarify now says "...Which prep step should I use? **above**"; Which-prep says "flow diagrams **below**"). Implemented via a deterministic Python reorder script (parse by h3, regroup, assert all 22 placed exactly once) - NOT hand-moved - then verified by headless render (7 groups, 22 h3s, all 7 ToC ids resolve, helpJump is a function). CSS added: `.help-body h2` (accent uppercase group label), `.help-toc` box. Test: new "groups sections with a jump-to table of contents" (7 ids resolve + helpJump is function). 725/725. This SUPERSEDES the "big reorg deferred" note in #11.

## Files

- index.html: help-body sections above (18 h3 sections total, verified in order via headless render).
- tests.html: Usability & Help > "should contain key help sections" - added asserts for 'Review Loops', 'Delivery (Output node format)', 'Handoff', 'Claude in Chrome'.

## Verification

- 724/724. Headless render confirms 18 sections in the intended order and well-formed HTML.

## Built with (provenance)

Direct implementation by the orchestrator across an interactive review of the Help modal; Blue drove the scope (review loops when/why, export-format-type blurb, Handoff, Claude in Chrome) message by message.

## Links

Branch: TBD. PR: TBD.
