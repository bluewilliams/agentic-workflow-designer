# Validation details: native alert() replaced with an in-app modal

Branch: main. Status: current.

```awd:record
{"slug": "validation-modal", "status": "current", "date": "2026-07-01", "files": ["index.html", "tests.html"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

Workflow validation details render in the #validationOverlay modal (help-modal classes, per-warning severity icon rows, Esc/backdrop/button close); zero-issue runs show a toast instead. The app contains no native alert() calls.

## Why and scope

Clicking the toolbar warning badge called native `alert('Workflow Issues:\n\n' + ...)` - jarring against the app's modal/toast language and unreadable for many warnings (one unstyled block, no scrolling affordance). This was the app's ONLY `alert()` call site (verified by grep), so the native-dialog surface is now gone entirely.

## Key decisions

- **Reused the help-modal pattern wholesale**: `#validationOverlay` uses the existing `help-overlay`/`help-modal`/`help-header`/`help-body` classes - zero new CSS, automatic visual consistency, backdrop-click close via the same inline pattern, and the shared Esc handler gained a validationOverlay check ahead of helpOverlay.
- **Presentation swap only**: `validateWorkflow()` and its warning data are untouched; `showValidation()` renders each warning as an icon + escaped message row (⚠ amber for `warn`, ✖ red for `error` - only `warn` exists today but the type field is honored), and the zero-issues path keeps its existing toast.
- Modal capped at 560px wide (narrower than help) - it is a list, not a document.

## Changes

- index.html: `#validationOverlay` markup beside `#helpOverlay`; `showValidation()` renders rows + shows overlay; new `closeValidation()`; Esc handler entry.
- tests.html: modal opens listing every warning verbatim (textContent probe), closes via closeValidation; zero-issues path never opens the modal (toast route); functions added to the test exposure line.

## Verification

- 1248/1248 green (+2). Headless-verified through the tests themselves (same iframe rig): open, per-warning content, close, and the toast-only path. Content-lint.

## Task checklist

- [x] Overlay markup on help-modal classes (no new CSS)
- [x] showValidation renders rows + severity icons; closeValidation; Esc + backdrop close
- [x] Only alert() site in the app converted (grep-verified)
- [x] Tests: content + open/close + zero-issue path; suite green

## Update (same day): themed confirm modal - the native confirm() dialogs join

Owner flagged the white browser confirm() dialogs (New workflow, preset replace) as the last stock-browser UI. New appConfirm(message, {confirmLabel, danger}) -> Promise<boolean>: #confirmOverlay on the help-modal classes (zero new CSS, z-index 600 - above every other overlay since confirms can fire from inside modals like the Agent Library), escHtml'd message with line-break support, Cancel + a labeled confirm button (danger = red), Enter confirms unless Cancel is focused, Escape cancels, backdrop cancels; a capture-phase key listener traps all other keys so canvas shortcuts cannot fire under an open confirm; danger confirms focus Cancel (safe default). withConfirm(message, opts, proceed) is the call-site helper: under the test hook (window.__autoConfirm, set true by the rig beside the old win.confirm stub) it short-circuits SYNCHRONOUSLY - which is what kept all 1314 pre-existing sync tests valid without a single await added; without the hook it runs the modal round-trip then proceed(). Six sites converted via a _confirmed reentry param (deleteSavedWorkflow, deleteCustomPrompt, deleteCustomAgent, generateFromStory, loadPreset, clearCanvas), each with danger + an action-verb label (Delete/Replace/Clear); their bodies stay synchronous so programmatic callers (pickUrlPreset, tests) are unaffected.

DELIBERATE KEEP (owner-granted skip license, applied): the two secrets-copy confirms (copyPrompt, copyTuningPrompt) STAY native. Reasoning: the modal round-trip moves navigator.clipboard.writeText out of the original gesture's synchronous task; Chromium tolerates promise-chain writes but the headless rig STUBS the clipboard (tests.html seeds writeText), so the change is not provable in CI - and breaking copy is worse than a white dialog. One-line comments at both sites; revisit with real-browser verification if the dialogs grate.

- [x] appConfirm + withConfirm + #confirmOverlay (z-index 600, keyboard trap, danger focus-Cancel)
- [x] Six sites converted with _confirmed reentry; sync bodies preserved
- [x] Two secrets-copy sites kept native with source comments (clipboard-gesture, rig-unprovable)
- [x] Test hook __autoConfirm (sync short-circuit); 5 new tests incl. hookless veto/proceed and the 2-native/6-converted invariant; 1314 -> 1319

## Update (same day): danger red reserved for the irreversible

Owner call, validated by the code: preset load and canvas clear push an undo point first (single undo restores the whole canvas), so their confirm buttons were overclaiming with danger red. Replace (preset + Auto Workflow) and Clear (new workflow) confirms now use the standard blue primary button - the modal itself is the caution signal; color is reserved for consequence. The three deletes ("cannot be undone") keep danger red and the focus-Cancel safe default.

- [x] danger:false on the three undoable confirms; deletes unchanged
