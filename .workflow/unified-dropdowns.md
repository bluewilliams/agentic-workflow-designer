# Unified dropdowns: every native select wears the custom-select skin

Workflow: unified-dropdowns. Branch: main. Status: finalized, committable.

```awd:record
{"slug": "unified-dropdowns", "status": "current", "date": "2026-07-10", "files": ["index.html", "tests.html"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

Every dropdown in the app presents the same `.custom-select` aesthetic (the Default Model look, per the director's ruling). The app's three native selects (`appSourceAccess`, `customAgentType`, `customAgentModel`) are wrapped at boot by `enhanceSelect()`: the native stays in the DOM as the single source of truth (visually hidden, `aria-hidden`), and the skin renders a keyboard-operable trigger (`role="combobox"`, Enter/Space opens, arrows move with `aria-activedescendant`, Enter selects, Escape closes, Tab closes-and-moves-on) plus a below-anchored `role="listbox"` option list. A skin pick sets the native `.value` and dispatches a bubbling `change`, so every inline handler fires untouched; programmatic `.value` writes follow through `refreshEnhancedSelect()` at the three assignment sites (restorePrefs, clearCanvas, openAgentForm - which also rebuilds the option roster). `closeAllCustomSelects()` enforces one-popup-open across all species (skin, config-selects, the bespoke Default Model select), and the canvas shortcut handler exempts anything inside `.custom-select`, so dropdown keystrokes (Escape, Delete) never leak into canvas actions. Node-config dropdowns (`configSelect()`) and `#defaultModelSelect` were already custom-selects and are unchanged.

## Why and scope

The director preferred the Default Model dropdown's look over native selects (macOS renders native popups as OS chrome that fights the dark app). Unify on one visual species. Non-goals: rebuilding the two existing custom-select species onto the enhancer (config-selects are div-only with no native underneath, so a single code path is unreachable in this unit; visuals were already identical); a from-scratch dropdown component.

## Requirements

1. Every native select MUST wear the skin with the native authoritative underneath.
   - Given boot, Then all three natives are wrapped, hidden, aria-hidden, with combobox trigger + listbox. (Test: wraps every native select at boot: the hidden native stays authoritative inside a custom-select wrapper)
   - Given a repeat enhance call, Then no double-wrap. (Test: re-running enhanceSelect never double-wraps)
2. Skin picks MUST be indistinguishable from native changes to the rest of the app.
   - Given a click on a skin option, Then native value + change handlers + trigger text all update. (Tests: clicking a skin option sets the native value, fires change handlers, and updates the trigger; a skin pick on the Agent Library type select fires the inline onchange (template pristine-swap))
3. Programmatic writes MUST stay supported via the refresh hook. (Test: programmatic native sets follow through the refresh hook (restorePrefs / clearCanvas path))
4. Keyboard operation MUST work and MUST NOT leak into canvas shortcuts. (Test: keyboard: Enter opens, arrows move, Enter selects, Escape closes - and never leaks to canvas shortcuts)
5. One popup open at a time, across every dropdown species. (Test: only one popup open at a time, across the skin and the bespoke Default Model select)
6. Dynamic option rebuilds (openAgentForm) MUST refresh the skin in place. (Test: openAgentForm rebuilds the native options and the skin refreshes in place (no double-wrap, full roster))

## Success criteria

- A user sees one dropdown aesthetic everywhere; no light OS popup ever appears.
- Every existing test that drives selects programmatically passes untouched (the native remained authoritative: 1513/1513 pre-suite).
- Dropdowns are keyboard-accessible for the first time (natives were, the div species were not; the skin restores parity for the wrapped three).

## Approach and decisions

- Progressive enhancer over rebuild (the enhanceExpandableTextarea remote-control precedent, grounded on expand-textarea-modal): the skin is a remote control for the real field, never a copy to reconcile. Chose this over migrating everything to one component because config-selects have no native element - a full merge rewrites working code for zero visual gain.
- #defaultModelSelect left bespoke: migrating it to native+enhancer would only swap which second species survives (config-selects remain div-based regardless) while forcing test-pin migrations - poor trade; visuals already identical. Noted as a candidate only if the div species ever earns a native rebuild for a11y.
- Canvas-shortcut safety via the exemption list (adding `.custom-select` to the existing tagName guard) rather than a capture-phase trap: the trap (validation-modal precedent) intercepts global keys for a modal; here the fix is that focusable dropdown parts should never have been shortcut surfaces at all. This also protects the two pre-existing custom-select species the moment they ever become focusable.
- The one-open invariant is enforced by the OPENER (closeAllCustomSelects before opening), shared across all three species by patching the two existing click handlers to the same helper.

## Surface area (file -> role)

- index.html: enhancer CSS (.native-select-hidden, .kb-active) replacing the superseded `select option` styling; the Unified dropdowns removable block (closeAllCustomSelects / refreshEnhancedSelect / refreshEnhancedSelects / enhanceSelect + boot IIFE) after the expand-to-modal block; canvas keydown exemption; closeAllCustomSelects calls in initDefaultModelSelect and the config-select trigger handler; refresh calls at restorePrefs / clearCanvas / openAgentForm.
- tests.html: the "Unified dropdowns" suite (8 tests) with afterEach restoring access value, closing the agent form, and resetState.

## Verify

- `./run-tests.sh` -> PASS 1521/1521 (baseline 1513 verified before starting; +8 suite tests; every pre-existing select-driving test passed untouched, zero migrations needed - the native-authoritative design's proof).
- Content-lint grep (CLAUDE.local.md) on changed files -> exit 1. No em/en dashes added.

## Gotchas / non-obvious

- The skin dispatches `change` (bubbling) - inline `onchange` attributes fire, but anything listening for `input` on a select would not; no such listener exists today.
- openAgentForm rebuilds native options via innerHTML (wiping `selected` state into attributes); refreshEnhancedSelect must be called AFTER both innerHTML writes - it reads sel.value, which the selected attribute establishes.
- The Escape guard works by exemption, not capture: keydown on anything inside `.custom-select` returns early from the canvas handler. Tests assert mode survives Escape both open and closed.

## History

- 2026-07-10: created (by unified-dropdowns)

## Outcome

One dropdown aesthetic app-wide: the three native selects wear the custom-select skin with full keyboard support and the native authoritative underneath; cross-species single-popup discipline; zero existing-test churn. index.html + an 8-test suite; 1513 -> 1521.

## Built with (provenance)

Direct fork execution by Claude (Fable) from the director's ruling ("I like the one we have for model selection better"); grounded on .workflow/expand-textarea-to-modal.md (remote-control enhancer pattern), .workflow/native-dark-scheme.md (the superseded interim fix), .workflow/validation-modal.md (key-containment precedent, deliberately not reused - exemption chosen over trap).

## Links

- Grounds on / touches: grounds on `.workflow/expand-textarea-to-modal.md`, `.workflow/native-dark-scheme.md`, `.workflow/validation-modal.md`; amended `.workflow/native-dark-scheme.md` (its option-styling line superseded by this unit).
- Branch: main (uncommitted delivery for the director).
