# Custom prompts in the Prompt Library

Branch: main (pushed). Status: current.

## Why and scope

The Prompt Library shipped as a curated, read-only set. This makes it user-extensible: add/edit/delete your own prompts (stored in localStorage), shown under a "My Prompts" category, plus export/import as JSON for backup and sharing. Local-first (no backend), consistent with the app's single-file philosophy. It turns the library from something you read into something you invest in.

Non-goals: server sync or hosted prompt packs (local + file export only); custom input-popup templating (the `input` find/replace) for user prompts - v1 custom prompts are plain text, though the popup still works for built-ins; per-category placement for custom prompts (all land in one "My Prompts" group).

## Requirements

- R1 - Add / edit / delete, persisted to localStorage. GIVEN the library, WHEN a user saves via the form (title + optional desc + prompt body) THEN it is stored under `awd_custom_prompts` and rendered under a "My Prompts" category with Edit/Delete + a CUSTOM badge; edit prefills the form; delete confirms. [tests: "effectivePromptLib appends a My Prompts category...", "a custom card gets Edit/Delete + a CUSTOM badge..."]
- R2 - Inert until used (zero behavior change when unused). `effectivePromptLib()` returns the EXACT `PROMPT_LIBRARY` reference when there are no custom prompts, and always APPENDS custom last so built-in indices never shift (the render/copy/favorite plumbing is index-based). [tests: "effectivePromptLib returns the exact PROMPT_LIBRARY...", "built-in indices are unchanged..."]
- R3 - Export / import as JSON for backup + sharing. Export writes `{ format:'awd-custom-prompts', version:1, prompts:[...] }`; import accepts that envelope OR a bare array, validates each entry, and dedupes by title (same title updates in place, so re-importing an updated pack is idempotent). [tests: "mergeImportedPrompts adds new and dedupes by title", "mergeImportedPrompts accepts an { prompts: [...] } envelope and rejects bad data..."]
- R4 - Safe rendering. User-authored title/desc are HTML-escaped so a stray `<` or `"` cannot break the card; built-in cards are unchanged. [tests: "...escapes user title (no raw HTML)", "a built-in card is unchanged..."]
- R5 - Works with search + favorites for free. Custom cards use the same `.plib-card` classes, so the DOM-based filter and the category:title favorites scheme apply unchanged; the "My Prompts" category hides when nothing matches and the clear-search re-render preserves custom prompts. [verified headless: search "refactor"/"description writer"/a built-in term + clear-search all behaved correctly with custom prompts present]
- R6 - Additive + removable; core untouched apart from one seam. The only core change is `PROMPT_LIBRARY` -> `effectivePromptLib()` in the render/copy/favorite functions, plus a custom branch in `buildPromptCard` and a guarded toolbar; everything else is a marked removable block. [verified: the prior 1124 tests stayed green; `effectivePromptLib()` degrades to `PROMPT_LIBRARY` if the block is removed]

## Approach and decisions

- Single seam: `effectivePromptLib()` = the built-in `PROMPT_LIBRARY` plus a "My Prompts" category appended when custom prompts exist. It returns the exact `PROMPT_LIBRARY` reference when empty, so the library is byte-identical until used; append-only keeps built-in indices stable. *Rejected:* prepending custom (shifts every built-in index, breaks the index-based copy/favorite handlers); a parallel custom-only render path (duplicates card/copy/favorite/search logic).
- Storage: localStorage `awd_custom_prompts` (mirrors `awd_prefs` / `awd_workflows`). No network of any kind. *Rejected:* hosted sync (breaks local-first and adds a backend).
- Graceful removability: `effectivePromptLib()` guards with `typeof getCustomPrompts === 'function'`, the toolbar renders only when the block is present, and the `buildPromptCard` custom branch only fires for the custom category - so deleting the block degrades cleanly to the curated, read-only library.
- Import dedupes by title (update-in-place) so re-importing an updated pack is idempotent and sharing is painless; it accepts both the export envelope and a bare array for forgiving imports, and returns -1 on unrecognized data.
- Escape user-authored title/desc at render only (store raw, escape on display); built-ins stay raw to preserve their trusted formatting.
- v1 prompts are plain text (no input-popup templating) to keep the add form simple; the `input` mechanism still works for built-ins.

## Surface area (file -> role)

- `index.html` core seam: `effectivePromptLib()` - the only new core function; returns `PROMPT_LIBRARY` when empty. The render/copy/favorite functions (`copyLibPrompt`, `confirmPlibInput`, `toggleFavorite`, `buildPromptCard`, `renderPromptLib`) reference it instead of `PROMPT_LIBRARY` (9 swaps). `buildPromptCard` gains a custom branch (escaped title/desc + CUSTOM badge + Edit/Delete); `renderPromptLib` gains a guarded toolbar (+ Add your own / Export mine / Import).
- `index.html` REMOVABLE block (`// === Custom prompts (user-authored library entries) - REMOVABLE ===`): `getCustomPrompts` / `saveCustomPrompts` / `newCustomPromptId`, `rerenderPromptLib`, `openCustomPromptForm` / `closeCustomPromptForm` / `saveCustomPromptForm`, `deleteCustomPrompt`, `exportCustomPrompts`, `mergeImportedPrompts` / `importCustomPromptsFile`. Plus the `#customPromptOverlay` add/edit form markup.
- `tests.html`: `describe('Custom Prompts (Prompt Library)')` (7 tests) + the win-bridge of `effectivePromptLib` / `getCustomPrompts` / `saveCustomPrompts` / `mergeImportedPrompts`.
- Docs: README "Prompt Library" (custom-prompts paragraph + the JSON format), help modal "Prompt Library" (toolbar + sharing note).

## Task checklist

- [x] Core seam `effectivePromptLib()` (returns PROMPT_LIBRARY when empty; appends "My Prompts" last)
- [x] Route render/copy/favorite (`copyLibPrompt`, `confirmPlibInput`, `toggleFavorite`, `buildPromptCard`, `renderPromptLib`) through the seam (9 swaps)
- [x] `buildPromptCard` custom branch: escaped title/desc + CUSTOM badge + Edit/Delete
- [x] Guarded toolbar (+ Add your own / Export mine / Import) in `renderPromptLib`
- [x] localStorage CRUD (`getCustomPrompts`/`saveCustomPrompts`/`newCustomPromptId`, add/edit/delete via the form, `rerenderPromptLib`)
- [x] Add/edit form overlay (`#customPromptOverlay`)
- [x] Export (`exportCustomPrompts`) + import (`mergeImportedPrompts`/`importCustomPromptsFile`; dedupe-by-title; accepts envelope or bare array)
- [x] Tests (7): inert-until-used identity, append/index-stability, merge+dedupe, envelope/bad-data, escaping, built-in-card-unchanged
- [x] Verified search + favorites with custom prompts present (headless)
- [x] Docs (README + help modal) and this record + `_index` + `_timeline`

## Verify

`./run-tests.sh` -> 1131/1131 (was 1124; +7). Headless end-to-end: added two prompts through the real form flow (stored + rendered), edit-form prefilled, copy did not throw; two screenshots confirmed the toolbar and the My Prompts cards (badge + Copy/Edit/Delete). Search verified with custom prompts present: a term filters to the right card, a built-in-only term hides "My Prompts", and clear-search re-render preserves custom prompts. Storage is localStorage only (grep confirmed no fetch/XHR/WebSocket in the block).

## Gotchas

- The library render/copy/favorite plumbing is INDEX-based; custom must be APPENDED last (never prepended/inserted) so built-in indices stay valid. `effectivePromptLib()` guarantees this.
- The CUSTOM badge text lives inside `.plib-card-title`, so searching "custom" surfaces all custom prompts (benign, arguably useful). Move the badge outside the title text if that should not be searchable.
- localStorage is per-browser; clearing it wipes custom prompts - Export is the backup path (flagged in the README).
- Favorites of a deleted custom prompt dangle harmlessly: the favorites lookup skips any category:title it cannot resolve.

## Spec quality check (finalize)

- [x] Every requirement is testable and has a verifying test (or a stated headless verification)
- [x] Scope bounded; non-goals stated
- [x] No open clarifications
- [x] Verify section records real results (1131/1131 + headless add/edit/search flows + screenshots)
- [x] Additive + removable; library byte-identical until used (identity test)
- [x] Finalized for commit

## Outcome

The Prompt Library is now user-extensible: add/edit/delete your own prompts (localStorage), shown under "My Prompts" with a CUSTOM badge, fully integrated with search + favorites + the input popup, and shareable via JSON export/import (dedupe-by-title). Additive and removable; with no custom prompts the library is byte-identical to before.

## Built with (provenance)

Authored directly, pairing across a multi-turn design conversation; verified via the headless test suite plus driven add/edit/search flows and screenshots. Integrates through the single `effectivePromptLib()` seam so the curated library and core stay intact.
