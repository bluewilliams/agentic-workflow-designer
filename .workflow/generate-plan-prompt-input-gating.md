# Gate Generate Plan Prompt on the requirements input (like Refine)

Branch: main. Status: current.

## Why and scope

Generate Plan Prompt had no disabled affordance - it only self-checked at click time (a toast if the box was empty), inconsistent with Auto Workflow and Generate Refine Prompt, which grey out when they cannot run. Gate Plan too, so an empty box gives a clear visual "not yet" instead of a click that just toasts.

## Key decision (which gating rule)

Plan gates like **Refine (disable when empty)**, NOT like **Auto Workflow (>=6 words of prose)**. The three are not the same:
- Auto Workflow keyword-picks a workflow, so it needs prose and disables on empty / URL-only / key-only / too-short.
- Refine and Plan just need SOME requirements. Crucially they **work with a bare Jira URL** (they fetch the ticket and treat it as the spec) and with a short spec - confirmed: `generatePlanPrompt` and `generateRefinePrompt` have identical preconditions (`if (!story) return`, key-only handled at click time).

So gating Plan with Auto Workflow's prose rule would WRONGLY disable it for a valid ticket URL or a short-but-real requirement. Refine's "disable when empty" is the correct match.

## Changes

- Gave the Plan button `id="planBtn"`.
- `validateStoryInput` now sets `planBtn.disabled = empty` (and a why-disabled tooltip), alongside the existing `refineBtn` gating - and adds the same tooltip to Refine (it had none). Auto Workflow keeps its stricter prose gate + contextual disabled tooltip.
- The click-time self-check in `generatePlanPrompt` stays as a safety net.
- Help modal updated (it previously said Plan "isn't gated by the input validator").
- Tooltips: added the disabled-state "Paste requirements or a Jira URL first" to Refine + Plan. Did NOT add enabled-state descriptions - the buttons have inline "Quick start" / "Optional" help right below them, so a descriptive tooltip would be redundant (same principle as the toolbar tooltip pass).

## Surface area (file -> role)

- index.html: `planBtn` id on the Generate Plan Prompt button; `validateStoryInput` gates planBtn + adds Refine/Plan disabled tooltips; one help-modal sentence updated.
- tests.html: `describe('Input gating (Auto Workflow / Refine / Plan)')` - 4 tests.

## Task checklist

- [x] planBtn id
- [x] Gate planBtn (disable when empty) + why-tooltip; add tooltip to Refine
- [x] Update help modal wording
- [x] Tests (empty disables all; Jira URL enables Refine+Plan not Auto Workflow; sentence enables all; Plan gates like Refine not Auto Workflow on a short spec)
- [x] This record + `_index` + `_timeline`

## Verify

`./run-tests.sh` -> 1176/1176 (was 1172; +4). The tests pin the key decision: a bare Jira URL and a short (<6-word) spec both keep Plan and Refine enabled while Auto Workflow stays disabled; an empty box disables all three; a full sentence enables all three.

## Spec quality check (finalize)

- [x] Every change has a verifying test or a stated verification
- [x] Scope bounded; the gating-rule decision is explicit (Plan == Refine, not Auto Workflow)
- [x] No open clarifications
- [x] Verify records real results (1176/1176)
- [x] Click-time self-check retained (no loss of the safety net)
- [x] Finalized for commit

## Outcome

Generate Plan Prompt now greys out alongside Generate Refine Prompt when the requirements box is empty (consistent affordance), but stays enabled for a Jira URL or short spec where it is genuinely useful - unlike Auto Workflow, whose stricter prose gate is specific to keyword-picking. Disabled-state tooltips explain the "not yet" on all three; enabled-state descriptions were left to the existing inline help.

## Built with (provenance)

Authored directly after a UI-consistency question. Verified by reading both generators' preconditions (identical) and the headless suite (1176/1176).
