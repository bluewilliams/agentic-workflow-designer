# Auto-fit the view after importing a workflow + make zoomFit self-deferring

Branch: main. Status: current.

## Why and scope

Two things, one coherent change:

1. **Bug**: importing a workflow (our `awd:meta` round-trip, a foreign OpenSpec schema, or a plain designer JSON) did NOT fit the view - a wide imported workflow overflowed the canvas until the user manually clicked Fit. Presets did not have this problem because `loadPreset` runs `autoLayout()`, which already fits. Reported after picking a preset then importing a foreign OpenSpec schema.
2. **Tidy**: the fit-after-a-mutation defer was sprinkled as raw `setTimeout(zoomFit, 50|80)` across several call sites, which reads as noise (adoption-readiness concern for the single-file tool).

Non-goals: auto-fitting on undo / autosave-restore (those also flow through `deserializeWorkflow`, but a view jump there would fight the user, so the fit is scoped to the import ENTRY point).

## Key decisions

- **Fit on import, at `importWorkflowFile` only.** Added the fit to the three success branches of `importWorkflowFile`, NOT inside `deserializeWorkflow` (shared by undo/redo and autosave-restore, where an automatic re-fit would be jarring).
- **`zoomFit` now self-defers via `setTimeout(0)`; no wrapper.** The fit MATH is synchronous and correct immediately - verified headlessly: node sizes are static (`NODE_DEFAULTS` w/h; the foreign importer hardcodes w:200,h:64), so `getNodesBounds()` reads real numbers straight from `state` with no DOM measurement, and `getBoundingClientRect()` forces sync layout. A sync `deserializeWorkflow()` + fit took a 2140px-wide, 8-node import from zoom 1 -> 0.392. Because the math is sync-correct, a one-macrotask defer (`setTimeout(0)`) is strictly safe, and it lets EVERY caller just call `zoomFit()` without remembering to wrap it - the simplest surface for a colleague reading a single-file app.
- **Considered a named `fitViewSoon()` wrapper first, then dropped it.** A wrapper (pure sync `zoomFit` + `fitViewSoon = setTimeout(zoomFit,50)` at mutation sites) is the more textbook separation, but it makes callers choose between two functions and is a footgun if they pick wrong. For this codebase's goal (approachable single file) the self-deferring `zoomFit` won: one function, impossible to misuse. Verified no caller depends on a synchronous fit (only the Fit button + the mutation sites call it; no test references it), so making it fire-and-forget is safe.
- **Tradeoff accepted**: `zoomFit` is now fire-and-forget async - you cannot get an instant synchronous fit. Nothing needs that today (the Fit button's one-tick delay is imperceptible). If a future caller ever needs a synchronous fit-then-read-transform, factor the body into a pure `computeFit()` then.

## Changes

- `importWorkflowFile`: each of the three success branches now calls `zoomFit()` after the success toast.
- `zoomFit`: body wrapped in `setTimeout(function(){ ... }, 0)` (self-deferring). Fit math unchanged.
- Removed the six raw `setTimeout(zoomFit, 50|80)` sites (autoLayout, addFanIn, addFanOut, import x3) - they now call `zoomFit()` directly. The Fit button already did.

## Surface area (file -> role)

- index.html: `zoomFit` self-defer; 3 fit calls in `importWorkflowFile`; 3 call sites in autoLayout/addFanIn/addFanOut simplified to `zoomFit()`.
- No test file change: the import path is async (FileReader + the self-defer), awkward to unit-test; verified by headless harness instead.

## Verification

- Headless harness (Chrome --headless, real File through `importWorkflowFile`): a 7-artifact foreign schema imports to 8 nodes and the view auto-fits to zoom 0.392 (`autoFitted: true`) - re-confirmed AFTER baking the defer into zoomFit. A second harness confirmed the fit math is correct synchronously (the finding that makes `setTimeout(0)` safe). Temp harness files removed.
- Full suite 1181/1181 (call-site simplifications are behavior-preserving; zoomFit was already effectively deferred at every mutation site).
- Content-lint.

## Task checklist

- [x] Fit the view after a successful import (all three `importWorkflowFile` branches)
- [x] Verify the fit math is synchronous (so setTimeout(0) is safe) + no caller needs a sync fit
- [x] Make `zoomFit` self-defer via setTimeout(0); remove the six raw setTimeout(zoomFit) sites; drop the wrapper
- [x] Headless proof of auto-fit on a wide import (post-change); full suite green; content-lint
