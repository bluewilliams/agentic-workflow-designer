# URL preset picker: react to the paste, not the text state

Context: no work item (direct session fix). Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- Live prompt (since 2026-11-05): typing in Requirements, Workflow Context, or the custom MCP notes regenerates the prompt after a 250ms typing pause (`schedulePromptUpdate`; `updatePrompt` cancels a pending one; `flushPromptUpdate` runs it now). Copy flushes before it reads the text, so it never ships text older than the sidebar. Every other sidebar control regenerates at once through its own handler (a 42-control audit found no other stale case).

- `validateStoryInput(fromUser)`: the `urlPresetPicker` ("Your input looks like a ticket URL. What type of work is it?") SHOWS only when the input is URL-only AND the call came from a real input event (the Requirements textarea's `oninput` passes `true`). It HIDES on any call path the moment the input stops being URL-only, so a stale picker never lingers.
- The startup revalidate (the bare `validateStoryInput()` after `restoreAutoSave()`) never reopens the picker: a restored session whose requirements are a bare ticket URL loads quiet, workflow intact.
- Pasting a URL mid-session still surfaces the picker (that is the act it exists for), including through the expand modal (`syncTextExpand` dispatches a real input event on the source).
- The bare-Jira-key hint (`storyHint`) is deliberately NOT gated the same way: a bare key is an input that genuinely needs fixing, so the state warning may show on load.
- Tests (Softened guards describe): user-input path shows; startup revalidate does not reopen; any revalidate clears the picker once prose exists.

## Why and scope

The picker fired purely on "text is URL-only", so every page load of a session saved with a ticket URL in Requirements re-popped the first-run helper over a fully built workflow. The picker's purpose is to help choose a preset at the moment a URL is pasted - an act, not a state. Scope: the show gate only; the picker markup, its preset buttons, dismiss, and the bare-key hint are untouched.

## History

- 2026-08-06: created - `fromUser` gate on the show path, hide stays universal on every path; existing show test migrated to the sharper contract + 2 regression tests. 1563 -> 1565 (by direct session)
- 2026-11-05: the generated prompt was stale after typing (director: the designer did not update when requirements changed until a preset was selected): the Requirements, Workflow Context and custom MCP notes handlers validated and autosaved but never regenerated, so the panel, the token count and the Copy text lagged until a preset load, a format switch or a canvas change. Proven headless (typed text absent from the panel and the Copy text, present in a fresh generation). Fix: a 250ms debounced regeneration on those three fields, cancelled by any immediate regeneration, and a flush in Copy. A headless audit of every visible sidebar control (42) now finds zero stale. 2043 -> 2046 (by direct session)
