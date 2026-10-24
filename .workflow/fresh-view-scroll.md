# Fresh views open at the top (expand modal, Explain and validation lists, format tabs)

Context: no work item (direct session, director-observed: some scroll positions survive between views, so a newly opened expand window or Explain step window starts scrolled to the bottom; "is this ideal or how it should be?"). Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- **Expand modal** (`openTextExpand`): the caret is carried from the source field only when that field is the active element, decided before the modal textarea takes focus. An untouched textarea reports its selection at the END of its value, which is what opened the expanded view scrolled to the bottom; a field not being edited now opens at the top with the selection collapsed at 0.
- **Explain and validation lists** (`showExplain`, `showValidation`): the scrolling list (`#explainList`, `#validationList`, the `.help-body`) is reset to the top after the overlay is shown; a hidden element ignores a scroll assignment, so the reset runs after `.show`, and a new anatomy never opens where the last one was left.
- **Format tabs** (`setExportFormat`): the prompt output scrolls to the top only when the format actually changed; the in-place regeneration every edit triggers keeps the reader's scroll.
- Unchanged by design: the prompt output keeps its scroll across edits; the help modal keeps its place (its jump links and long read benefit from it); the sidebar keeps its own scroll.

## Why and scope

A scroll position is state of a view. The Explain, validation, and expand surfaces reuse one DOM element for every view they show, so the position of the previous view leaked into the next one and read as "opened at the bottom". A fresh view starts at the top; a view the user is working in keeps its place. Scope: four small changes, one suite. Non-goal: no change to in-place regeneration or to the help modal.

## Verify

- `./run-tests.sh`: 1821/1821 (expand from a field not being edited: selection 0,0 and scrollTop 0; from a field being edited near the end: the caret carries; Explain reopened after a scrolled anatomy: top; a changed format tab: top; an in-place regeneration: scroll kept). Frame shown for real geometry.
- Content lint clean on all touched files

## History

- 2026-10-23: created (openTextExpand caret rule, showExplain and showValidation resets after show, setExportFormat reset on change; one suite) on a director question during the saved-workflow context work. 1818 -> 1821 together with that unit's round 3 (by direct session)
- 2026-10-23: review round (1 finding on this unit, acted on) - the corner expand button took focus on mousedown, so the click path never counted as editing and always opened at the top; now the button prevents its mousedown focus, pinned with a dispatched mousedown. Suite steady at 1821 (by direct session)
