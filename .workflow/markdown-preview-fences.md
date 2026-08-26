# Prompt preview: inline marks render inside fenced blocks

Context: no work item (director-reported readability defect in the prompt panel). Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- `renderMarkdown` (the zero-dependency prompt-panel renderer) renders INLINE marks - bold and single-backtick code spans via `inlineFmt` - inside fenced code blocks. Heading lines inside a fence render as bold monospace lines with their hash marks preserved (structure without pretending the payload is not a payload); lists and tables inside a fence stay plain, and HTML inside fenced payloads stays escaped.
- `inlineFmt` uses placeholder protection: code spans are lifted out first (printable \u0000 escape sequences in source, no raw control bytes in source), bold runs on what remains, then the spans restore. That gets both hard cases right at once: backticked glob literals (`**/theme/**`) never bold, and a bold that CONTAINS a code span (the shared-log intro line) still renders. Plain numbers in text are untouched by the sentinel round trip.
- This matters because the Sub-Agents format embeds each agent's whole prompt inside a fence: raw `**` and backticks across every agent block read as broken formatting rather than intentional payload.
- Display-only by construction: Copy and export always ship `_rawPrompt`; the rendered HTML never leaves the panel. The SDK format keeps its plain `textContent` branch untouched.
- The Explain modal's evidence previews solve the same problem with their own escape-first `exInlineMd` (recorded under explain-lever-audit); both surfaces now read consistently.

## Why and scope

The director flagged raw `**Before doing ANYTHING else**` and backticked paths across the prompt panel's fenced agent blocks. One-line change in `renderMarkdown`'s in-fence branch (`escHtml` -> `inlineFmt`, which itself escapes first); nothing else in the renderer moved.

## Verify

- `./run-tests.sh` (1637 -> 1638: fence-inline test asserts bold + code render, headings stay literal, HTML stays escaped)

## History

- 2026-08-25: created - in-fence lines render through inlineFmt instead of bare escHtml (by direct session)
- 2026-08-25: review fix - both micro-renderers ran bold BEFORE code spans, so backticked glob literals (`**/theme/**` in the Design Analyzer template) got their asterisks eaten and bolded: inlineFmt now splits out code spans first and bolds only outside them, and exInlineMd collapsed into a one-line wrapper over it (one pipeline, the panel and the modal can never diverge). Same length (by direct session)
- 2026-08-25: director follow-up - the split approach broke bold SPANNING a code span (the shared-log intro kept raw asterisks), so the split became placeholder protection (lift spans, bold across, restore; printable escape sentinels after a first pass accidentally wrote raw NUL bytes into source); fence heading lines now render bold with hash marks preserved. Visual proof against the reported sample. 1640 -> 1641 (by direct session)
- 2026-08-25: review hardening - inlineFmt strips literal NULs from input (imported JSON can smuggle them into prompt strings; a smuggled NUL-digit-NUL sequence could swap in the wrong code chip), and the accidental raw NUL byte this record itself picked up while DOCUMENTING the incident was scrubbed (git had started treating the record as binary). Fence-heading visibility ruled deliberate: hash marks inside fences are payload, not formatting - hiding them would misrepresent what agents write to disk. 1641 steady +1 pin (by direct session)
- 2026-08-25: director caught #### falling through - renderMarkdown had rules for # / ## / ### only, so the per-agent "#### Frontend" section heads rendered as plain paragraphs; four-plus-hash lines now render as h4 (own style row, text2 tone) while fences keep them literal as ever. 1642 -> 1643 (by direct session)
