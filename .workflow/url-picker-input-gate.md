# URL preset picker: react to the paste, not the text state

Context: no work item (direct session fix). Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- `validateStoryInput(fromUser)`: the `urlPresetPicker` ("Your input looks like a ticket URL. What type of work is it?") SHOWS only when the input is URL-only AND the call came from a real input event (the Requirements textarea's `oninput` passes `true`). It HIDES on any call path the moment the input stops being URL-only, so a stale picker never lingers.
- The startup revalidate (the bare `validateStoryInput()` after `restoreAutoSave()`) never reopens the picker: a restored session whose requirements are a bare ticket URL loads quiet, workflow intact.
- Pasting a URL mid-session still surfaces the picker (that is the act it exists for), including through the expand modal (`syncTextExpand` dispatches a real input event on the source).
- The bare-Jira-key hint (`storyHint`) is deliberately NOT gated the same way: a bare key is an input that genuinely needs fixing, so the state warning may show on load.
- Tests (Softened guards describe): user-input path shows; startup revalidate does not reopen; any revalidate clears the picker once prose exists.

## Why and scope

The picker fired purely on "text is URL-only", so every page load of a session saved with a ticket URL in Requirements re-popped the first-run helper over a fully built workflow. The picker's purpose is to help choose a preset at the moment a URL is pasted - an act, not a state. Scope: the show gate only; the picker markup, its preset buttons, dismiss, and the bare-key hint are untouched.

## History

- 2026-08-06: created - `fromUser` gate on the show path, hide stays universal on every path; existing show test migrated to the sharper contract + 2 regression tests. 1563 -> 1565 (by direct session)
