# Explain report export (committable audit document)

Context: no work item (direct session, director-requested: a future colleague diagnosing why a run failed or succeeded needs Explain-level configuration detail without the app). Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- An **Explain Report** item in the Export menu (beside Handoff Package) downloads `{slug}-explain.md`: the Explain modal's full content as a committable markdown document. Structure: header (date, format, node/connection counts, prompt token estimate), the Requirements verbatim in a fence, the Workflow anatomy rows, then one section per node in topological order - every lever row as `**{part}** - EMITTED|SKIPPED - {reason}` with the emitted evidence beneath in a TILDE fence (evidence can itself contain backtick fences), truncated past 1200 chars with an honest count (the generated prompt carries the full text; the reasons are the audit payload).
- The document ends with the full `serializeWorkflow()` JSON in a fence plus the re-import instruction (Import > From clipboard), so the report is LOSSLESS: a colleague reopens the exact workflow with interactive Explain from the committed file alone.
- Built entirely on the pure `explainWorkflow`/`explainNode` rows the modal renders - one analysis path, no drift surface. Empty canvas guards with a toast; the success toast suggests committing beside the durable record. Help modal and README carry the story.

## Why and scope

The awd blocks serve machines and the generated prompt shows WHAT was instructed, but the WHY (lever states, reasons, evidence) lived only in the in-app modal and died with the tab. For postmortems the diagnosis kit is now complete in the repo: the WHY (this report), the WHAT HAPPENED (durable record + awd:run fence), and reproducibility (the embedded JSON). Scope: one generator + one export function + a menu item + docs + tests. Non-goals: no second analysis path, no auto-attach to runs (committing is the director's deliberate act).

## Verify

- `./run-tests.sh`: 1723 -> 1725 (report structure incl. EMITTED/SKIPPED and tilde fences and embedded JSON; truncation honesty, fenced story, empty-evidence contract)

## History

- 2026-09-12: created - generator, export, menu item, help + README notes, Suite 12k. UX pass on director direction: an Export report button rides the Explain modal header itself (the discovery point where users experience the content), and the README gained a proper Explain report sibling section beside the Handoff bundle. 1723 -> 1725 (by direct session)
- 2026-09-12: review round (7 findings: 6 confirmed + 1 drift-cost cleanup, all fixed) - the Lossless claim was FALSE (bare serializeWorkflow lacks the importer's format envelope - now embedded exactly as exportWorkflowFile builds it, so a whole-report paste round-trips); a whole-report paste would have ingested the run-report directive's EXAMPLE fence as fake telemetry (evidence now defangs ```awd:run with one space - the importer's raw-text scan misses it, markdown still renders the fence); fixed tilde fences were breakable by user-authored tilde runs and by truncation landing mid-run (fences now size themselves past the longest inner run, story fence included - the fenceFor discipline, tilde edition); the header token count regenerated state.exportFormat's prompt regardless of the report's format parameter (now dispatches per format; the dead typeof guard removed); the truncation notice pointed at a source that cannot contain synthesized rows (now points at the designer, true for every row); the modal Export report button rendered dead-center in the space-between header (now grouped with the close X); and the copy-pasted row template collapsed into one pushRow. Refuted by the review with evidence: JSON-fence breakage (stringify keeps fences mid-line), row-shape drift across node types, the storyInput test leak. Suite steady at 1725 (by direct session)
- 2026-09-12: the modal button reads Export FULL report (director asked whether steps export individually - the ambiguity was real: the button sits inside what may be a single-step view, while every export has always been the complete workflow document). One word; the tooltip already said it (by direct session)
