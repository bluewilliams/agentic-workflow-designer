# Button labels: Auto Workflow + Generate Refine/Plan Prompt

Work item: Blue - the "Plan Prompt" button under the "Implementation Plan" box read like it acted on the box, not like it generates a separate prompt. Status: complete, uncommitted (Blue commits). Tests: 705/705.

## Why and scope

Three "generate" actions existed but only one said so: primary `Generate` (builds the workflow in-app), `Refine Prompt` and `Plan Prompt` (each generates a prompt you copy out and run in Claude Code). The two small ones read as nouns/labels, so `Plan Prompt` next to the `Implementation Plan` input looked like it operated on that input. Relabel for a clear two-tier read.

Non-goals: no behavior change (same handlers); kept the Help-modal flow-section h3 titles ("Refine Prompt Flow", "Plan Prompt Flow") since a test pins them and they name the flow, not the button.

## Approach and decisions

- `Generate` -> **Auto Workflow** (primary): builds the workflow in-app NOW. Chose "Auto Workflow" over "Generate Workflow" because (a) the main button's behavior differs from the two prompt-generators (in-app build vs copy-out prompt), so differentiating is clearer than three identical "Generate"; (b) it parallels the existing "Auto Layout" toolbar button, fitting the app's vocabulary. Blue floated it and it proved the better call.
- `Refine Prompt` -> **Generate Refine Prompt**, `Plan Prompt` -> **Generate Plan Prompt**: the two helpers now share a "Generate ___ Prompt" shape that reads as an action producing a prompt, distinct from "Auto Workflow".
- Two-tier story: Auto Workflow (build now) vs Generate ___ Prompt (make a prompt to run elsewhere).

## Surface area (file -> role)

- index.html: 3 button labels (generateBtn, refineBtn, plan button); the two on-screen helper texts; the Requirements textarea PLACEHOLDER (default attr + the clearCanvas/New-Workflow reset - user-facing, easy to miss); Help-modal "click X" references AND the two flow-section h3 titles ("Generate Refine/Plan Prompt Flow"); two generated-output lines (genClaudePrompt help + the story-prompt build line). UI text only, no logic.
- README.md: 4 button-name references (Quick Start + Refine & Plan section).
- TECHNICAL.md: user-journey steps, input-validation notes, file-structure sidebar map, help-flow description (all referenced the old labels).
- tests.html: updated the 2 help-flow-title assertions (Refine/Plan Prompt Flow -> Generate Refine/Plan Prompt Flow). 705/705.

Lesson (caught by Blue): a button relabel has MANY scattered references - not just the button + adjacent helper text, but the textarea placeholder (x2: default + reset), generated-output strings, help-modal headings + bodies, and the technical docs. Sweep ALL files with grep for the old label (in a "click X" / button context) before calling a relabel done.

## Verify

Command: ./run-tests.sh -> 705/705 pass. Browser-verified: "Auto Workflow" + "Generate Refine Prompt" fit on one line under Requirements, "Generate Plan Prompt" under Implementation Plan, no overflow/wrap; helper text matches.

## Outcome

The Requirements/Implementation-Plan area now reads clearly: a primary "Auto Workflow" build button, and two "Generate Refine Prompt" / "Generate Plan Prompt" helpers that visibly produce a prompt to run in Claude Code - removing the "does this button act on the Implementation Plan box?" confusion.

## Built with (provenance)

Workflow: direct implementation by the orchestrator (UI text relabel + help/README references), prose-only, no sub-agent review. Browser-verified label fit.

## Links

Branch: TBD. PR: TBD.
