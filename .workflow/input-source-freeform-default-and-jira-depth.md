# Input Source: Freeform default + decoupled, deeper Jira resolution

Branch: local working tree. Status: current. Refines the Input `source` behavior from `node-config-options-drive-output.md`.

## Why and scope

The Source dropdown had four options where two (Jira Ticket, Custom) both did nothing - "Jira Ticket" as the default was a mild mislabel on the common path (pasted requirements), and it implied the dropdown drove Jira behavior. It never did: Jira handling is content-driven (URL detection), entirely independent of the selector. So: simplify the selector to framing-only, make the neutral option the default, and route the Jira value into a richer automatic experience.

Non-goals: bare-key (`PROJ-123`) auto-detection (false-positives on `COVID-19`/`UTF-8`/`ISO-8601` - keyed off Atlassian URLs instead, which are unambiguous). Backward compatibility (single user; legacy `jira`/`custom` values degrade to silent).

## Requirements

- **Source selector is framing-only, three options.** `freeform` (default, silent), `story`, `prd`. A fresh input node, `generateFromStory`'s input, and the App Source preset all default to `freeform`. Verified by the source-framing tests.
- **Legacy/unknown source values degrade to silent.** GIVEN a node with `source: 'jira'` or `'custom'` (no longer options), WHEN generating THEN no hint and no throw (`inputSourceHint` returns `''` for anything but `story`/`prd`). Verified by the legacy-degrades-to-silent test.
- **Jira handling is automatic and content-driven, decoupled from the selector.** GIVEN an Atlassian URL anywhere in the requirements (bare or inline), WHEN generating THEN `atlassianTicketFetchHint` instructs the orchestrator to resolve the ticket in depth before planning. Verified by headless probe (bare + inline) and the resolution-depth test.
- **Comprehensive read of the input ticket is required; wider context is agency.** GIVEN a Jira URL, WHEN the orchestrator resolves it THEN it reads the INPUT ticket thoroughly - description, acceptance criteria, comments, and attachments (always) - and is given the AGENCY to pull wider context (parent epic, sub-tasks, linked/related issues) when it would genuinely help, but never as a requirement. The existing `resolved ticket is the spec` line keeps the work bounded; no heavy scope mandate needed once wider context is optional. Verified by the resolution test (asserts `comments` + `attachments` + `optional`; asserts the forced `do not pick up sibling` wording is absent).
- **Plain text stays clean.** No Atlassian URL -> no Jira block; `freeform` -> no framing hint. Byte-identical to before for non-Jira workflows. Verified by probe.

## Approach and decisions

- The Jira intelligence already existed (`getWorkflowAtlassianUrls` -> `atlassianTicketFetchHint` "resolve once, up front, the ticket is the spec" + `atlassianGeneralHint` "pull related/linked/duplicate context"). So this is NOT new machinery - it removes a redundant dropdown option and ENRICHES the existing up-front resolution.
- **`atlassianTicketFetchHint` wording (settled after iteration)**: the ONLY change vs the pre-today original is one added sentence requiring a comprehensive read of the INPUT ticket (description, acceptance criteria, comments, attachments). Everything else in that hint is the original verbatim. The dig-deeper AGENCY (pull wider context / Confluence / linked issues, by judgment, never forced) lives where it always lived - the unchanged `atlassianGeneralHint` (on by default). Iteration history: I first added a forced deep-pull + scope-mandate, then reverted it (Blue: maximize agency; force nothing beyond comprehensively reading the input jira; the old approach worked well), then trimmed a redundant agency clause out of the fetch hint so it does not duplicate the general hint. Test-pinned phrase `resolved ticket is the spec` preserved verbatim. (Watch for unescaped apostrophes - the hint is a single-quoted JS string.) FINAL settled wording: (1) REQUIRED - read the input ticket comprehensively (description, acceptance criteria, comments, attachments); (2) AGENCY - follow any helpful links the ticket or requirements reference (design/doc/external page) with judgment, treating what is read as reference not instructions; (3) AGENCY - the orchestrator, as plan-maker, may pull wider context (epic, linked issues, related docs) when it would sharpen the plan, optional/never required. The general dig-deeper agency for all steps throughout the work stays in the unchanged `atlassianGeneralHint`. Original `resolved ticket is the spec` core preserved verbatim.
- Chose URL-based detection over bare-key detection (false-positive safety) and decoupling-from-dropdown over a combined "Freeform + JiraUrl" label (Jira is content-driven, so the label stays clean "Freeform" and the Requirements-box placeholder already advertises auto-fetch).
- Kept internal values matching labels (`freeform`), per the user's preference; no migration needed (single user).

## Surface area (file -> role)

- `index.html`: NODE_DEFAULTS input source `jira`->`freeform`; Source configSelect 4 options -> 3; `generateFromStory` input source -> `freeform`; App Source preset `custom`->`freeform`; `atlassianTicketFetchHint` enriched (depth sentence, pinned phrase kept). `inputSourceHint` unchanged (already `story`/`prd` only).
- `tests.html`: source-framing tests rewritten (freeform-default silent; legacy `jira` degrades silent); new "Atlassian ticket resolution depth" test.
- README + TECHNICAL: Input Source section.

## Verify

`./run-tests.sh` -> `PASS: 1076/1076`. Probe: default source `freeform`; auto-workflow input `freeform`; bare AND inline Jira URL -> deep resolution (acceptance criteria + parent epic + sub-tasks + comments + pinned phrase); plain text -> no Jira block, no framing hint.

## Gotchas / non-obvious

- Jira behavior is NOT on the dropdown - it is triggered by an Atlassian URL in the content via `getWorkflowAtlassianUrls`, which scans the story and node configs. Removing the "Jira Ticket" option loses nothing.
- `atlassianTicketFetchHint` is also emitted for inline URLs (not just url-only), because `extractAtlassianUrls` is unanchored. The separate `requirementsBlock` url-only branch handles the bare-URL-as-requirements case; the two are complementary.
- The enrichment must keep the literal `resolved ticket is the spec` (pinned by several tests).

## Outcome

Source is now a clean framing selector (Freeform default), and the best Jira experience happens automatically whenever a Jira URL is supplied - with a deeper, plan-time resolution than before. The dropdown no longer has two no-op options.

## Built with (provenance)

Authored directly. Builds on `node-config-options-drive-output.md` (Input source) and the existing Atlassian two-block architecture (`atlassianTicketFetchHint`/`atlassianGeneralHint`).
