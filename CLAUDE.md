# Agent rules for agentic-workflow-designer

These rules are binding for every agent working in this repository.

## Hygiene (checked before every commit)

- Content-lint: run the private hygiene grep documented in CLAUDE.local.md (gitignored, never committed) - it must exit 1 on the files you touched. Never quote its pattern in any tracked file: the pattern itself is the secret.
- Test fixtures use `PROJ-` style fictional ticket keys (e.g. `PROJ-123`) only.
- NO em dashes or en dashes anywhere - prose, code, comments, records. Use a hyphen, a colon, parentheses, or two sentences. (Negative test assertions that check for their absence are the one legitimate place the characters appear.)

## App conventions

- Single-file app: `index.html` is the entire application; `tests.html` is the entire suite (bespoke describe/it harness). Run tests with `./run-tests.sh` (headless Chrome; zero dependencies beyond Python 3 + Chrome). The suite must be green before and after your change.
- Do not create new files without explicit direction - the app stays single-file, and the only sanctioned artifacts are the durable records below.
- Plain-script JS: function declarations auto-expose to the test iframe; `const`/`let` bindings need a line in the tests.html exposure block. Escape apostrophes inside single-quoted JS strings.
- localStorage keys use the `awd_` prefix with try/catch on read and write.
- Prompt-emission changes respect the toggles: memory-gated text only when `memoryEnabled`, durable-record text only when `durableRecord`, grounding only when `consumeRecords`, verification-instructions only when `verifyPaths` is non-empty. Every gated emission gets an OFF/empty test assertion.
- Tool selections are suggestions, never restrictions - emitted prompts must not forbid tools.

## Durable records

- Records live in `.workflow/` per the v2.1 protocol: one record per unit of work + `_index.md` + `_timeline.md` are the ONLY durable surfaces. Ground new work by scanning `_index.md` first (scan-then-open).
- Records are finalized per the completion gate (the record protocol emitted in generated prompts is the authoritative spec); amendments to other records follow the right-sized lineage rules (amend in place + History line; supersede only for whole-capability replacement).

## Tests

- Match the newest suites' conventions (they drift deliberately; recent beats abundant).
- Tests touching the sidebar collapse module or `awd_` storage must clean up in afterEach (expandAllSections + key removal). Assert section direct-child display contracts, not per-element computed styles (textareas are wrapped).
- Never weaken an assertion to make a change pass - migrate deliberately to the sharper contract.
