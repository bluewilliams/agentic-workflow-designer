# Native control chrome renders dark (color-scheme)

Workflow: native-dark-scheme. Branch: main. Status: finalized, committable.

```awd:record
{"slug": "native-dark-scheme", "status": "current", "date": "2026-07-10", "files": ["index.html"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

`:root` declares `color-scheme: dark`, so OS widget chrome (scrollbars, form-control furniture) renders in the platform's dark variants. The interim `select option` theme styling this record originally added is gone: unified-dropdowns wraps every native select in the custom-select skin (natives visually hidden, never opening an OS popup), which superseded option styling entirely. color-scheme stays for the chrome the skin does not cover.

## Why and scope

Open dropdown menus rendered as light macOS popups against the dark app (director screenshot: the App Under Test Access selector). The popup's layout and overlay behavior are OS chrome and not stylable; the color mismatch is fixed by declaring the document's scheme. Non-goals: no custom dropdown component (heavy, accessibility-fraught, against single-file simplicity - the native popup's macOS overlay anatomy is accepted as platform behavior).

## Verify

- `./run-tests.sh` -> PASS 1513/1513 (one-line CSS addition; zero behavioral surface).
- Visual: open any select (Access, Agent Type, Model, Default model, posture, writing style) - popup renders dark on Chromium/Safari/Firefox per platform support.

## History

- 2026-07-10: created (by native-dark-scheme)
- 2026-07-10: select option theme styling added - flips Chromium to its author-styled popup renderer, matching native dropdowns to the custom-select aesthetic (director caught the two-species inconsistency: Default Model is a bespoke .custom-select, everything else native) (by native-dark-scheme)
- 2026-07-10: the option-styling line removed, superseded by the unified custom-select skin (natives now visually hidden and never open an OS popup); color-scheme dark retained for scrollbars and remaining chrome (by unified-dropdowns)

## Outcome

One declaration; every dropdown popup and scrollbar in the app now matches the dark aesthetic to the extent the platform allows.

## Built with (provenance)

Direct fix by Claude (Fable) from the director's screenshot report; too small for a workflow run.
