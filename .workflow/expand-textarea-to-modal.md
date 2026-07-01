# Expand any text box into a large modal editor

Branch: main. Status: current.

## Why and scope

Several fields hold substantial text - Requirements, Workflow Context, Agent Prompt, Agent Context, and the prompt/agent editor bodies - but the inline boxes are small, so users end up drafting long specs/prompts in an external editor and pasting back. Add a discreet, intuitive way to pop any of these open in a big modal editor, WITHOUT losing the streamlined inline editing.

Requested fields (Blue): Requirements, Agent Prompt, Agent Context, the Agent editor (customAgentPrompt/customAgentNotes), and the Prompt Library "add a custom prompt" body. Plus Workflow Context, and - free via the keyboard path - any other textarea.

## Key decisions

- **The modal is a REMOTE CONTROL of the real field, not a copy.** Opening mirrors the source textarea's value into a big modal textarea; typing there writes back to the source AND dispatches the source's own `input` event, so every existing handler (validateStoryInput / updatePrompt / autosave / the config-panel data-key binding) fires exactly as if typed inline. No save/cancel, no reconcile, no divergence - closing just closes. This is why it is regression-proof: the app never sees anything different from normal typing.
- **Two affordances, one engine.** (1) A discreet corner button (a small expand glyph, ~40% opacity, brightens on hover) in each wired textarea's top-right; (2) `Cmd/Ctrl+E` while ANY textarea is focused. The button is discoverability; the shortcut is the universal path (covers fields without a button, incl. dynamically-rendered ones). The main keydown handler early-returns when a field is focused, so the shortcut lives in its own listener.
- **DRY wiring, two placement paths.** Node-config textareas (Agent Prompt, Agent Context) get the button automatically because they all render through the shared `configTextarea()` - added the `.ta-wrap` + `taExpandButton()` there once. Static fields (storyInput, planInput, customPromptBody, customAgentPrompt, customAgentNotes, uiContextNotes, mcpCustomNotes) are wrapped at init by an idempotent `enhanceExpandableTextarea()` pass, so no button HTML is duplicated across the markup.
- **Layering.** The expander overlay is z-index 500, above the prompt/agent form modals (z-400), so "expand" works from inside the Agent editor and Prompt editor (modal-over-modal); Esc closes only the expander and returns focus to the source.
- **Live word/char count + "Changes save automatically"** microcopy so users trust closing without a save button. Caret/selection from the source is preserved into the modal.
- **Additive + removable.** All CSS is in `.text-expand-*` / `.ta-*` rules, JS in a marked REMOVABLE block, markup in `#textExpandOverlay`. Remove those three regions (and the `taExpandButton()` call in configTextarea) to fully excise it; the inline boxes revert untouched. No existing behavior changed - the inline fields render and behave exactly as before, just inside a positioned wrapper.

## Changes

- CSS: `.text-expand-overlay/.text-expand-modal` (the big editor) + `.ta-wrap/.ta-expand` (the corner button).
- Markup: `#textExpandOverlay` modal (title, big textarea, footer with count + Done).
- JS (REMOVABLE block): `openTextExpand/syncTextExpand/closeTextExpand/updateTextExpandCount`, `textExpandIsOpen`, `textExpandTitleFor` (friendly titles: config `<label>` > id map > dataset override > "Edit text"), `expandFromButton`, `taExpandButton`, `enhanceExpandableTextarea` + init pass, and a `Cmd/Ctrl+E` / `Esc` keydown listener.
- `configTextarea()`: wraps its textarea in `.ta-wrap` + the button (Agent Prompt/Context get it for free).
- Help modal: one paragraph under "Editing Agent Prompts" documenting the expand button + Cmd/Ctrl+E.

## Surface area (file -> role)

- index.html: CSS block; `#textExpandOverlay` markup; the REMOVABLE JS block; the one-line `configTextarea` wrap; a help-modal paragraph.
- tests.html: "Expand-to-modal text editing" describe (7 tests) + 8 bridge exports.

## Verification

- 1181 -> 1188 (+7): taExpandButton markup; configTextarea wraps with button; static fields wrapped at init; enhance idempotent (no double-wrap); textExpandTitleFor resolution; open-mirror + live-sync-back round-trip; and a behavioral test that a modal edit fires storyInput's oninput so the Refine gate flips disabled->enabled (proves the remote-control design end to end).
- Headless screenshots (viewed): the discreet corner button renders on Requirements + Workflow Context at the intended low opacity without overlapping text; the expanded modal shows the title, big editor with preserved caret, live "N words / N chars" count, "Changes save automatically", and Done. Temp files removed.
- Content-lint.

## Task checklist

- [x] Big modal editor that mirrors a textarea and live-syncs back via the source's own input event
- [x] Discreet corner button on the wired fields + Cmd/Ctrl+E on any focused textarea + Esc/Done/backdrop close
- [x] Wire Requirements, Workflow Context, Agent Prompt, Agent Context, Agent editor, Prompt editor (config via configTextarea; statics via an idempotent init wrap)
- [x] Modal-over-modal layering (z-index above the form modals)
- [x] Tests (7) + headless screenshot verification; full suite green; content-lint; additive/removable
