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
