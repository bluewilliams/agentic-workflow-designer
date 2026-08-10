# Self-improvement loop: durable artifacts v2, run reports, folder connect, advisor

Branch: main. Status: current.

```awd:record
{"slug": "self-improvement-loop", "status": "current", "date": "2026-07-02", "files": ["index.html", "tests.html", "README.md", "TECHNICAL.md", ".workflow/_index.md"], "verify": ["./run-tests.sh", "grep -c 'awd:record' index.html", "git grep -c 'awd:run' index.html", "grep -c 'function adviseWorkflow' index.html"], "superseded_by": null}
```

## Current behavior

The designer now closes the design -> run -> re-design loop end to end. The generated durable-record protocol (Workflow / Sub-Agents / Agent Teams / Claude formats) ships record anatomy v2: an `awd:record` JSON fence under the H1 (slug, status current|superseded born-current, date, files, exact verify commands, superseded_by), a present-tense "Current behavior" first section (living spec; history below for the why), an OpenSpec-grade granular live-ticked Task checklist with explicit resume semantics, and a finalize gate that self-lints the whole system - all capped at exactly three durable surfaces (record + `_index.md` with its in-file Archive section + `_timeline.md`, one record per unit of work, never companion documents). Every generated run ends with one machine-readable `awd:run` fence (steps status/turns/cap, gates cycles/verdict, omit-never-invent); finalize copies it into the record, and the OpenSpec export's apply step emits the same fence plus a one-line reverse-grounding breadcrumb into the target repo's index/timeline. The designer ingests reports two ways - paste/drop through Import, or a one-time "Connect repo" folder grant (File System Access API, IndexedDB handle, auto-rescan) - with content-hash dedupe shared by both feeds so nothing double-counts; aggregates live in localStorage `awd_run_reports`, telemetry nodes get amber badges plus a config-panel Run history line, and the data-gated Export > Tuning prompt bundles stats + the workflow's awd JSON for Claude to return an improved workflow to re-import. `adviseWorkflow()` renders non-blocking lightbulb suggestions (six rules, including telemetry rules over the same aggregates) in the Workflow Review modal with a one-click Attach Skeptic; suggestions never touch the validation badge, and all 15 presets advise clean. Grounding reads a record's Current behavior first, skips Archive entries, and follows superseded_by forward, in all three consumers.

## Why and scope

Two strategic gaps, one unit of work. First, the durable records captured deltas only - reconstructing a capability's present truth meant replaying N records in order - and were prose-only, unvalidated, and monotonically growing: the structural virtues OpenSpec-class tools do have (current truth vs delta, tool-readability, archive economics, validation) were missing, while their scaffolding weight, CLI dependency, and generate-once rigidity remain deliberately unwanted. Second, the designer shipped workflows and never learned how they went: nothing captured which gates loop, which agents hit turn caps, what fails - so the tool could not get better with use. Owner constraints held throughout: the durable system is exactly three surfaces with one record per unit of work and no new document types ever; Workflow/Sub-Agents/Agent Teams are the bread-and-butter formats (the SDK is currently unused - minimal investment); OpenSpec export included but not central; friction minimized (the folder grant exists because even paste-back was one gesture too many); single-file, zero dependencies, removable blocks, localStorage/IndexedDB only.

## Key decisions

### Durable artifacts v2 (the record anatomy)

- **Spec-vs-delta separation via a section, not a new document**: "Current behavior" lives INSIDE the record as its first prose section, updated on every change; grounding gets current truth in one read. Rejected: an OpenSpec-style specs/ directory (violates the three-surfaces rule).
- **Statuses are current|superseded only** - a record is born when work happens; no planned state, no pre-created records (owner steer).
- **Archive is a SECTION of `_index.md`, not a file**: superseded entries move to `## Archive (superseded)` at the bottom; the prior `_index_archive.md` and shard-file escalations were REMOVED from the protocol - the index stays one file at any scale, grep locality carries cost.
- **Checklists are granular + live** (owner steer): authored up front from the plan, one checkbox per discrete verifiable resume-unit ("could a fresh agent resume from this box?"), ticked as each task completes; `recordHandoffHint`'s `DONE:` names exact checklist items; resume = read Current behavior, then the first unchecked box.
- **The agent is the linter**: the finalize gate checks fence consistency, Current-behavior truth, verify commands actually run, index/timeline written, no companion documents. No CLI validator exists or is wanted.
- **Grounding updated at the single source** (`groundingLookupSteps`): Current-behavior-first, Archive-skipping, superseded_by-forwarding - inherited together by the prompt hint, OpenSpec grounding block, and SDK comment.
- The 16 records dated 2026-07-01 were retrofitted as v2 exemplars; older records migrate on touch.

### Run-report contract (the telemetry write side)

- **Always on, no toggle**: one `awd:run` fence at the end of a run is cheap; a report nobody asked for is harmless text, while a forgotten toggle means the run that mattered left no report. Fields the orchestrator did not track are omitted, never invented. The memory breadcrumb keeps its very-last-line contract; the fence sits immediately before it.
- **Slug join key** (`slugify(label)`, same as the memory files): renaming a node orphans its history - accepted, advisory data.
- **OpenSpec reverse grounding (closes backlog #10)**: the apply step writes ONE static breadcrumb line into the target repo's `.workflow/_timeline.md` (and `_index.md` for a new capability) in our format, self-gated on the system existing, explicitly forbidden from creating files. A static line fits OpenSpec's generate-once grain where the mutable flywheel doc did not.
- **Import seam order**: `awd:meta` is checked FIRST so handoff bundles (which embed the example fence) still round-trip as workflows.
- **Aggregates, not run hoarding**: localStorage keeps per-slug aggregates (runs, capHits, failures, cycleSum/cycleRuns) plus the last report only.
- SDK: one comment line (owner steer - format unused).

### Folder connect (the zero-friction feed)

- **Feed-level dedupe shared by paste AND scan**: `ingestRunFences` hashes each fence's exact inner JSON (djb2) against a persisted seen-set (`awd_run_reports._hashes`, capped 500) - rescans and repeat imports never double-count.
- **Multi-fence extraction is the primitive** (`extractRunFences`; records accumulate one fence per run); `parseRunReport` reimplemented over it, first-fence contract preserved.
- **Injectable scan core**: `scanRunReportsFromHandle` accepts any object speaking the directory-handle async-iterator protocol, so tests drive it with fakes; the picker/permission plumbing above it is thin and untestable by design.
- **IndexedDB for the handle only** (handles cannot live in localStorage; ~40-line promise kv, no deps); permission is queried on load but only ever REQUESTED inside a user gesture (Reconnect button); hidden entirely where the API is unsupported - paste stays the universal fallback.
- **Test harness upgraded to await thenables** (`runGroup` awaits `test.fn()`): the old synchronous runner passed async tests vacuously; all pre-existing sync tests unaffected; a deliberate-break canary proved async assertions really fail.

### Workflow advisor (the advice surface)

- **Six rules, never blocking, never in the badge**: unreviewed build path to output (reviewer-blocked BFS + one-click Attach Skeptic via the existing attachReviewLoop), fan-out converging only at the output, solo agent shipping pr/commit, read-and-analyze role holding Write/Edit, starved builder (maxTurns <= 3), telemetry rules over `awd_run_reports` (gate avg >= 2.5 cycles, cap-outs >= half the runs, failures) gated on data existing. `updateValidation` (the badge) still calls only `validateWorkflow` - pinned by test.
- **Tester is a reviewer role, not a flaggable builder** (a role cannot be both hazard and remedy); builders = coder/frontend/backend, or general holding Write/Edit.
- **BFS sanitizing semantics**: attaching a Skeptic at the terminal builder sanitizes every upstream builder (their only path to the output now crosses the review) - a test initially expected otherwise and was corrected to pin this.
- **Custom-prompt exemption**: a read-only role holding write tools is flagged only on its DEFAULT template (`classifyAgentPrompt().state !== 'custom'`) - a tailored prompt signals deliberate configuration, which is exactly what preset synthesizers are. This single exemption made **all 15 presets advise clean with zero threshold tuning**, pinned by a permanent calibration test.

## Changes

- index.html: genDurableRecordProtocol (anatomy v2 + no-new-documents + one-record-per-unit grain + checklist spec + finalize self-lint + Evolution/Scaling rewrite), recordHandoffHint, groundingLookupSteps, genDurableRecordComment; runReportDirective() + orchestrator-tail injections (workflow/subagents/teams/claude, SDK comment) + OpenSpec applyInstr fence/breadcrumb; RUN REPORT LOOP removable block (parse/ingest/aggregates/badges/Run history/tuning prompt) + guarded call sites; REPO FOLDER CONNECT removable block (idb kv, injectable scan, connect/rescan/reconnect/disconnect UI) + `#repoConnectWrap`; WORKFLOW ADVISOR removable block + showValidation two-group render + modal retitle; help-modal sections.
- tests.html: async-aware runner; +33 tests across four describes; deliberate rewrites of pins contradicting the new contracts (v2.4, v2.8, checklist-grain).
- README.md ("Run Reports" section, advisor bullet), TECHNICAL.md (anatomy v2), .workflow/ (16 exemplar retrofits, _index preamble + Archive section).

## Verification

- `./run-tests.sh` - 1257 -> 1290 (+33), full suite green; every wave independently re-verified by the coordinating session (suite re-runs, content-lint grep, diff reads, preset-snapshot equality re-checked from raw JSON where applicable).
- Content-lint grep exit 1 throughout.

## Task checklist

- [x] Durable artifacts v2
  - [x] awd:record fence spec (born-current statuses, required keys)
  - [x] Current behavior first section + update-on-change
  - [x] Three-surfaces / no-companion-documents rule explicit; Archive as _index section; shard escalations removed
  - [x] Granular live checklist + exact-box DONE: naming + resume semantics
  - [x] Finalize self-lint gate; grounding Current-behavior-first across all consumers
  - [x] 16 exemplar retrofits; README/TECHNICAL/help synced
- [x] Run-report contract
  - [x] runReportDirective() in workflow/subagents/teams/claude; SDK comment line
  - [x] Finalize copies the fence into the record
  - [x] OpenSpec apply fence + reverse breadcrumb (backlog #10 closed)
- [x] Designer ingestion
  - [x] parseRunReport/ingest aggregates + import seam after awd:meta
  - [x] Telemetry badges + config Run history line + data-gated Tuning prompt
- [x] Folder connect
  - [x] Connect/rescan/reconnect/disconnect UI (hidden when unsupported); IndexedDB handle
  - [x] extractRunFences + shared content-hash dedupe across feeds
  - [x] Async-aware test harness (canary-proven)
- [x] Advisor
  - [x] Six rules + one-click Attach Skeptic; badge stays issues-only
  - [x] 15/15 presets advise clean, calibration-pinned
- [x] Suite green (1290/1290); content-lint; all waves parent-verified

## Update (same day): help-modal gap closed

A post-ship documentation audit found the help modal's Durable Record section predated the v2 anatomy: it described the record and index but not the two changes users feel - the resume story (checklist authored up front, ticked live, resume = first unchecked box) and the awd:record fence Connect Repo reads. One paragraph added between the orchestrator and breadcrumb-index paragraphs, closing with the record-grain rule. Docs only; no behavior change.

- [x] Help modal Durable Record paragraph (fence + live checklist resume + grain rule)

## Update (same day): one home for the read side - the Run Reports section

Owner UX ruling: the loop's read-side controls were scattered and overlookable - the Connect-repo pill sat in the Workflow Management button row (wrapping it to two lines) while the Tuning prompt hid inside the Export dropdown. Both now live in a dedicated "Run Reports" sidebar section directly below the Memory & Durable Record toggles, which is the semantically right neighborhood: the record a run keeps is where its report comes back from. Contents: the connect/reconnect/rescan/disconnect state (section renders on unsupported browsers too - the paste path works everywhere, only the connect affordance hides), a live status line ("N run reports ingested for <workflow> - last <date>" vs a no-reports-yet nudge naming both feeds), and the Tuning prompt button with its data-gating (removed from the Export menu; the gate moved out of toggleExportMenu into updateRunReportSection(), which rides updatePrompt - the universal re-render seam - plus every ingestion including quiet folder rescans). ingestRunReport now counts wf.reports for the status line. Workflow Management is back to one line: Save / Clone / Export / Import, pinned by test. Help modal + README location wording updated.

- [x] Run Reports section below the toggles (connect state + status line + tuning button)
- [x] Workflow Management row back to exactly four controls (wrap fix, test-pinned)
- [x] Tuning prompt out of Export; gating via updateRunReportSection on the updatePrompt seam + ingestion
- [x] Help/README wording; +2 tests (section order/home, status + gate tracking); suite green; content-lint

## Update (same day): telemetry is workflow-level - the ~/.awd common home

Owner ruling: run telemetry is a WORKFLOW-level concern, not a repo-level one - the repo scoping was an accident of transport (the fence rode the durable record because it already existed). The directive now also instructs every run to APPEND the same fence to `~/.awd/run-reports.md` (creating it if missing), named as the designer's canonical telemetry feed; the copy inside a durable record is archival context and stays. Self-gating: if writing outside the working directory is not permitted (Claude Code prompts for out-of-tree writes; one always-allow settles it per machine), the run skips silently and the final-response fence still stands as the paste fallback. The OpenSpec apply instruction carries the same addition. The fence schema gains an optional `repo` field (the repository the run executed against, omit-never-invent) as future-proofing for per-repo segmentation - no UI built for it. Designer side needed almost nothing: resolveRecordsDir already falls back to a flat picked folder, extractRunFences already reads every fence in a file, and the content-hash dedupe already makes overlapping feeds safe - so connecting `~/.awd` once covers every workflow against every repo, always on, which is the owner's "relates to the workflows alone so it's on or off" model. Connect UI, help modal, and README now lead with the ~/.awd recommendation and demote per-repo connect to the alternative. The workflow-level explain row now carries the full directive text (same header-literal gap class fixed for the memory rows earlier). +4 tests (directive in all prose formats + OpenSpec, flat-folder scan with repo field, repo-field ingestion). 1306 -> 1310.

- [x] Directive: ~/.awd append + canonical wording + self-gating skip + repo field (prose formats + OpenSpec apply)
- [x] Connect UI / help / README lead with ~/.awd; per-repo demoted to alternative
- [x] Flat-folder resolveRecordsDir + multi-fence run-reports.md scan test; repo-field ingestion test
- [x] Suite green; content-lint

## Update (same day): picker memory, naming, casing

Follow-ons from first hosted use. The folder picker now passes id 'awd-run-reports' so Chrome remembers the last-picked directory across sessions (a page cannot start a picker at an arbitrary path like ~/.awd - browser security; the id-memory gets 90 percent of the way after the first pick). Hidden-folder hint added to the Connect tooltip and help (Cmd+Shift+. on macOS reveals dot-folders in the dialog). Button renamed Connect folder -> "Connect Reports Folder" (owner floated Connect Optimize Folder; Reports names what the folder IS, and the section already carries the self-improvement purpose). Button-casing sweep to the app's Title Case convention: Tuning Prompt, Explain Step, Connect Reports Folder, Add to Canvas, Clear All, Export Mine, Handoff Package (owner caught the first two; the sweep found the rest).

- [x] Picker id memory + hidden-folder hints (tooltip + help)
- [x] Connect Reports Folder rename (+ README/help/strong refs + test pin)
- [x] Title Case sweep across 7 buttons
- [x] Settled on "Connect Folder" after seeing it in situ (owner + me converged: the section header already says RUN REPORTS, so the button restating Reports only cost width); 6px breathing room between the status line and the buttons

## Update (same day): connect guidance for Chrome's home-directory refusal

First real connect attempt hit Chrome's File System Access blocklist: picking the home directory root is refused outright ("contains system files") - only subfolders can be granted. And ~/.awd does not exist before the first run writes there (runs create it; a pre-first-run connect finds nothing to pick). Tooltip + help now teach the working path: create ~/.awd first (mkdir -p), pick the folder ITSELF via Cmd+Shift+G, never the home root. Copy-only change.

- [x] Tooltip + help modal guidance (home-root refusal, mkdir-first, Cmd+Shift+G path)

## History

- 2026-07-11: grounding made visible to the user - orchestrator narrates scan outcomes (kickoff + final report); awd:run fence gains an honest `grounded` slug array (used-only, omitted when none, toggle-gated). The flywheel now shows its owner it is turning (by self-improvement-loop)
- 2026-07-13: the Run report Explain row now states WHY it is always on (independent of the memory/durable/grounding toggles - telemetry about the run, not work-state; local-only, skips silently) - a director with toggles off met the directive as a possible misconfiguration (by self-improvement-loop)
- 2026-07-15: the tuning loop's last leg closed - Import is now a two-item menu (From file / From clipboard) with fenced-payload extraction, so Claude's returned JSON pastes straight back (the save-to-file detour was the undocumented step that stranded the director after his first tuning run); shared importWorkflowText ingestion behind both paths; the copy toast names the return path; advisor rule f0 nudges the Tuning Prompt at three runs of telemetry; the tuning prompt teaches Claude the designer's full toolbox (review loops, defect posture, verification ownership) and requires a predicted next-run effect per change so tuning is falsifiable (by self-improvement-loop)
- 2026-07-15: help modal now walks the tuning loop as five numbered steps (run x3 -> Tuning Prompt -> Claude returns predictions -> Import From clipboard -> next runs grade the predictions) - the director's question proved the old paragraph never said what to do with Claude's reply (by self-improvement-loop)
- 2026-07-15: the tuning prompt now sees the evidence that matters most - ingestion keeps fence notes (newest 5) and grounded-slug counts instead of dropping them; both feed the prompt with a trust-the-note-over-the-counter rule; the taught toolbox grew to the full designer vocabulary (per-node model changes, memory/durable toggles on context-loss signals, sparing topology moves incl. fork/serialize/remove-always-skipped, productive-vs-thrashing maxRevisions, clarify-first on requirements churn) (by self-improvement-loop)
- 2026-08-06: the help walk got readable - the five tuning-loop steps are a real ordered list (each opening with the bolded action) instead of an inline run-on, under the renamed heading "Run Reports: Self-Improvement & Connect Repo" (hyphenated to match the sidebar's self-improvement suffix); heading pinned in the key-sections test (by direct session)
- 2026-08-07: clipboard import hardened after the pre-commit review fleet confirmed four defects - the fence regex now matches ANY info string (awd:run fences were unmatchable: colon failed [a-zA-Z]*) and CRLF endings; pasteImportWorkflow hands importWorkflowText the RAW text with no fake filename, so the awd:meta and run-fence stages see everything (the JSON stage does its own largest-fence extraction, a no-op for plain files) and a filename-less artifacts: content sniff routes pasted foreign OpenSpec YAML to the best-effort importer; the Import dropdown gained outside-click + Escape dismissal and one-open-at-a-time parity with Export; genTuningPrompt stopped re-parsing run reports already in scope. +4 regression tests, 1581 -> 1585 (by direct session)
