# OpenSpec artifacts option (faithful change + delta-applied specs)

Context: no work item (direct session, director-requested: OpenSpec teams get committable, archivable artifacts - their repos keep `openspec/`, not `.workflow/`). Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- A **Write OpenSpec artifacts (change + specs)** checkbox (id `openSpecArtifactsToggle`, default OFF, prefs- and workflow-persisted) sits under the durable-record toggle as a STRICT SUBSET of it: hidden and force-cleared whenever durable records turn off, restored consistently, superset-enforced on load (`!!p.openSpecArtifacts && state.durableRecord`).
- When ON, `genDurableRecordProtocol` emits TWO gated companions - a kickoff step beside the record's creation, and finalize step **d2** - so the run leaves FAITHFUL, team-committable OpenSpec artifacts, indistinguishable from OpenSpec-native work, with an honest in-flight change if the run is interrupted. Lifecycle: at kickoff, create `openspec/changes/{change-slug}/` with `proposal.md` (why/what from the record's Why and scope), `tasks.md` (plain checkboxes mirroring the record checklist, ticked as tasks complete), and `design.md` fed from Approach and decisions where the repo's changes carry one, with spec deltas expressed the repo's own way. At finalize, apply the change to `openspec/specs/{capability-slug}/spec.md` as DELTAS - only touched `### Requirement:` sections (with `#### Scenario:` Given/When/Then blocks) change, every other line of an existing spec preserved verbatim - then archive the change exactly the way the repository archives changes (the openspec CLI's archive and validate preferred when available; a validation failure is a completion-gate failure).
- Faithful means UNSTAMPED: the artifacts never point at the record and never claim generation - they are team truth once written, hand-edits included, and every future run (designer grounding or OpenSpec tooling) treats them as normal OpenSpec documents. The repository's existing `openspec/` files ALWAYS outrank the shapes the emission describes.
- The three-surfaces doctrine and the completion gate carry conditional carve-outs naming these artifacts as the one sanctioned exception. Decisions with rejected alternatives, verify evidence, the owner-tagged checklist, and history stay in the record - the run's working spine, committed or not at the team's choice.
- Touch-Up and Record Sync already amend and archive `openspec/` artifacts, so amendments flow without special-casing.

## Why and scope

Teams standardized on OpenSpec do not commit `.workflow/`; a stamped projection pointing at an uncommitted record is misleading, and a rewrite-in-place spec clobbers team edits. OpenSpec's own change/delta/archive model solves both: deltas merge instead of rewrite, and archives make the change lifecycle first-class. The record keeps everything OpenSpec cannot carry and drives the live features; the committed durable layer is genuinely OpenSpec. Scope: one state flag, one nested toggle, handler/persistence wiring, one gated emission step plus two doctrine carve-outs, docs, tests. Non-goals: no stamped projection mode (superseded in design before ever shipping), no read-side changes (grounding already scans both corpora).

## Approach and decisions

- Faithful full-lifecycle artifacts (rejected: the stamped spec-only projection built first) - a projection protected OUR canonical-record model, but the target users do not commit the record; the delta/archive lifecycle IS OpenSpec's own answer to concurrent edits, and unstamped artifacts are the only kind such teams can treat as real.
- Repo-conventions-outrank + CLI-validate-when-available (rejected: encoding one fixed OpenSpec shape) - self-corrects against OpenSpec format evolution instead of chasing it.
- Emission-level instructions (rejected: generating the files from app code) - the agent writes at run time with the record in hand; the designer stays a prompt generator.

## Verify

- `./run-tests.sh`: 1713/1713 (ON emission pins the lifecycle, deltas, no-stamp, archive, validate-gate, and both carve-outs; OFF pins including the inconsistent-state superset guard; toggle-subset UI + serialization round-trip)

## History

- 2026-09-03: created as a stamped spec-only mirror (projection of the record's requirements into openspec/specs/, generated-from stamp, no changes/ proposals). 1710 -> 1713 (by direct session)
- 2026-09-03: redesigned to FAITHFUL artifacts on director direction (target teams commit openspec/, not .workflow/): full change lifecycle (proposal/tasks/design created at work start, archived at finalize), specs updated by delta with existing content preserved verbatim, stamp removed (artifacts are team truth), CLI validate as a completion-gate item, identifiers renamed specMirror -> openSpecArtifacts, record file renamed to match. Suite steady at 1713 (by direct session)
- 2026-09-03: review round (5/5 confirmed) - the lifecycle's kickoff half now EMITS at kickoff: a gated companion beside the record-creation step creates the change dir when work begins (an interrupted run leaves an honest in-flight change; tasks tick during the run), with d2 reworded to the finalize half only (apply deltas, archive). Self-collision guidance added: an existing active change for the same slug is an earlier interrupted attempt - resume it, never duplicate; the coordinate-around-active-changes grounding rule applies to OTHER work's changes, never your own. The completion-gate carve-out gained its missing OFF pin, both early-return guards clear and sync consistently (the memory-off path routes through clearDurableRecord), and the last mirror-era vocabulary left code and test titles. Suite steady at 1713 (by direct session)
