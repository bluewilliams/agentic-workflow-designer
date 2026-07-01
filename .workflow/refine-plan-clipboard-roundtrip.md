# Clipboard-assisted paste-back for the Refine / Plan round-trip

Branch: main. Status: current.

## Why and scope

The Refine and Plan flows involve sending a prompt to Claude Code and pasting its result back into the Workflow Designer (Refine -> Requirements box; Plan -> Workflow Context box). Today each prompt writes its output to a file (`.claude/specs/{slug}.md`, `.claude/plans/{slug}.md`) and tells the user to OPEN the file, copy it, and paste. This is a quality-of-life improvement: have Claude also put the file's contents on the system clipboard so paste-back is a single step.

Non-goals: replacing the file write (the file persists the spec/plan, is re-openable, and is the fallback if no clipboard tool exists - so keep BOTH); a toggle (this is squarely the purpose of these round-trip prompts, and it degrades gracefully, so it is always on); anything for Claude.ai web (no shell/clipboard - these prompts target Claude Code).

## Key decision

Keep the file AND add a clipboard copy. In Claude Code, Claude has Bash, so it can pipe the file to the clipboard. Cross-platform + best-effort with a graceful fallback, using the PIPE form (`cat FILE | tool`, more robust across shells than `<` redirection): `cat FILE | pbcopy` (macOS), `cat FILE | xclip -selection clipboard` / `cat FILE | xsel -b` (Linux), `cat FILE | clip.exe` (Windows - and `clip.exe` is a native Windows binary reachable from PowerShell, cmd, Git Bash, AND WSL, so every Windows shell context is covered); if none is available, tell the user to open the file and copy manually. Non-destructive (piping to the clipboard is safe).

## Changes

- New pure helper `clipboardCopyInstruction(filePath)` - returns the cross-platform copy command + the manual-copy fallback. Single source for both generators.
- `generateRefinePrompt`: the "Finally" block now (1) copies `.claude/specs/{slug}.md` to the clipboard via the helper, then (2) tells the user it is on the clipboard (and saved), to paste into **Requirements** replacing the original, and to click Generate Plan Prompt next.
- `generatePlanPrompt`: same shape - copies `.claude/plans/{slug}.md`, tells the user it is on the clipboard, paste into **Workflow Context**, then build the workflow.
- Inline help notes (Refine "Quick start", Plan "Optional") mention "Claude copies it to your clipboard".

## Surface area (file -> role)

- index.html: `clipboardCopyInstruction` helper; the "Finally" instruction blocks in `generateRefinePrompt` + `generatePlanPrompt`; two inline help notes.
- tests.html: a pure test for `clipboardCopyInstruction` (cross-platform commands + fallback); the two existing refine/plan output tests updated to the new wording and asserting the clipboard step (`pbcopy`, the file path).

## Task checklist

- [x] `clipboardCopyInstruction` helper (cross-platform + fallback)
- [x] Wire into generateRefinePrompt (spec -> Requirements) and generatePlanPrompt (plan -> Workflow Context)
- [x] Reword the "Finally" instructions to "it is on your clipboard"; inline help notes mention it
- [x] Helper test + update the two existing generator tests (reworded assertions + clipboard checks)
- [x] This record + `_index` + `_timeline`

## Verify

`./run-tests.sh` -> 1177/1177 (was 1176; +1 helper test; the two existing refine/plan tests updated to the new wording and now also assert the clipboard step). The helper test pins all four OS commands + the manual fallback; the generator tests confirm each prompt copies its saved file to the clipboard and names the correct paste-back box.

## Spec quality check (finalize)

- [x] Every change has a verifying test
- [x] Scope bounded; non-goals stated (keep the file, no toggle, Claude Code only)
- [x] No open clarifications
- [x] Verify records real results (1177/1177)
- [x] Best-effort + graceful fallback (no hard dependency on a clipboard tool); non-destructive
- [x] Finalized for commit

## Gotchas

- Best-effort by nature: a clipboard tool may not be installed (xclip often is not on a bare Linux box) - the prompt instructs a manual-copy fallback, and the file is always written regardless.
- Only Claude Code (Bash) can do this; Claude.ai web will just skip the clipboard step and fall back to the file (these prompts are for Claude Code anyway).

## Outcome

Running Generate Refine Prompt or Generate Plan Prompt in Claude Code now leaves the result on your clipboard (and in the file), so paste-back into the Workflow Designer is a single paste instead of open-file-copy-paste - a real friction cut in the tool's copy-heavy round-trip, with a graceful fallback when no clipboard tool exists.

## Built with (provenance)

Authored directly from a QoL request. Verified via the headless suite (1177/1177) - a pure helper test for the cross-platform commands plus the updated refine/plan generator tests.
