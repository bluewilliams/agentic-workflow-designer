# Rendered markdown over idle text fields (click-to-edit)

Context: no work item (direct session, director request from the Agent Prompt expand editor: show the markdown rendered, edit the raw text on click, "the normal convention, do not invent one"). Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- Every textarea inside a `.ta-wrap` (the thirteen config-panel and sidebar fields plus the expand modal) shows its markdown rendered while idle and the raw markdown while it has focus. Focus leaving renders it again from the current value. Click, Tab, or a programmatic focus all count the same (the `focusin` and `focusout` delegates). This is the click-to-edit convention of Jira, Trello, and Confluence inline fields.
- The textarea is the only source of truth and is never replaced: same id, value, events, resize, autosave, undo, and the corner expand button. The view is a sibling `div.md-view.md-rendered` painted over the textarea's box, built by `renderMarkdown` (the prompt area's renderer, which escapes HTML first). An empty field shows no view, so its placeholder stays visible. A view is redrawn only when the text changed since it was last drawn.
- Clicking the view focuses the field with the caret at the top and the field scrolled to the top, where the reader was looking. The mousedown is prevented so the click never first blurs whatever was focused.
- A press elsewhere leaves the field even when its default is prevented (the canvas does that for a pan, a right click, and connect mode), so the field never stays raw after the user has visibly moved on; a press inside the field's own wrap (the expand button prevents default to carry the caret) is left alone.
- Views refresh on focus changes, after the config panel is rebuilt, at boot, and on the universal re-render seam (`updatePrompt`), so a load, an import, or a template reset shows up without the writer knowing about the view.
- The expand modal opens rendered when the field was not being edited (click to edit, same as any idle field), and straight into the editor when opened mid-edit (Cmd/Ctrl+E or the corner button from a focused field, caret carried) or when the field is empty. Opened rendered, keyboard focus sits on the dialog container, so Tab reaches its controls and the canvas shortcuts (Backspace deletes the selected node) stay out; the canvas keydown handler also bails while the dialog is open. Closing returns focus to the field only when the user was editing in the dialog; a reader who closed a rendered view gets the field back rendered.
- The Agent Prompt's **Preview full prompt** block renders through the same renderer instead of a raw `pre`.
- The view copies the textarea's own box at refresh time (padding, background, border, radius, from computed style), so fields with inline styling swap without a shift, and its clip-path leaves the resize grip corner uncovered (not in the modal, whose textarea has no grip). The custom prompt form and the agent preset form paint their views from the value they just wrote, so no stale view survives from an earlier prompt. While the dialog is open the sweep refreshes only the dialog's own field.
- `renderMarkdown` renders a numbered list as an ordered list (it was a bullet list), so step order survives in the prompt area, the views, and the preview.
- One stylesheet serves every rendered surface: all of the prompt area's descendant rules (`h1` through the table cells) now hang off `.md-rendered` with sizes in em so each surface's base size scales them, which the prompt output, the idle views, and the preview body all carry. The wrapped textarea is `display:block`, so the wrapper is exactly the textarea box and the view matches it; the Agent Prompt status block lost the negative margin that depended on the old inline-block gap.

## Why

A prompt full of `**bold**` and numbered steps is hard to read raw, and the raw markdown must stay editable because it is what the agent reads. A rich-text editor would round-trip the markdown lossily; a transparent overlay would depend on pixel alignment that a proportional font and bold weights break. The focus swap keeps the textarea untouched and reuses the renderer the app already trusts.

## Verify

- `./run-tests.sh`: 1879 -> 1893 (a rendered view over an idle field built by `renderMarkdown`; raw on focus and rendered again on blur with the edited text; click gives focus with the caret at the top; no view for an empty field; HTML escaped; sidebar views refresh on `updatePrompt` after a programmatic value change; a view is rebuilt only when the text changed; a default-prevented canvas press leaves the field while the expand button does not; the modal opens rendered, raw mid-edit, raw when empty, and its sync path is untouched; the prompt area carries the shared class and the old descendant selectors are gone and the dead preview rule with them; a dialog opened rendered keeps focus inside and Backspace deletes nothing; the custom prompt form paints a fresh view per prompt; numbered steps render as an ordered list; the view copies the textarea's box and leaves the grip corner uncovered). One pre-existing preview test migrated from "a `pre` with the raw text" to "a rendered body equal to `renderMarkdown` of the effective prompt".
- Real browser (Chrome): the Requirements field, the Agent Prompt field (idle, click to edit with the focus grow, blur back), the Preview full prompt block, the expand modal (opens rendered, click to edit, Escape closes and focus returns to the field).

## Known limits

- The caret lands at the top on click, not under the clicked word (mapping a click in rendered HTML to a source offset is not reliable).
- The renderer's own conventions apply: a single `#` heading renders as an h2 and a blank line renders as a line break, the same as the prompt area.

## History

- 2026-10-30: created - view helper and delegates, hooks, modal wrap, preview block, shared `.md-rendered` stylesheet, README; then the default-prevented press rule after the director saw a field stay raw. 1879 -> 1889 (by direct session)
- 2026-10-30: house review (high, all findings): twelve findings, all acted on - canvas shortcuts fired into a dialog opened rendered (focus now on the dialog, handler bails while open); stale views in the custom prompt and agent preset forms (openers refresh); five rules left on the old stylesheet scope (migrated, sizes in em); the preview lost step numbering (numbered lists are ordered lists now, renderer-wide); the view covered the resize grip (clip-path notch); per-field inline box styles mismatched (the view copies the textarea's computed box); a dead preview rule and a never-matching selector removed; a tautological assertion and an empty destructuring in tests fixed; the sweep skips the thirteen hidden fields while the dialog is open. 1889 -> 1893 (by direct session)
