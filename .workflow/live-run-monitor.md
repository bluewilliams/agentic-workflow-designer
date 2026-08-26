# Live Run Monitor: the canvas watches the run

Context: no work item (director-commissioned flagship; vision approved, built in one delivery). Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

The Monitor toolbar button (Chromium; hidden where the File System Access API is absent) opens a right-side drawer over the canvas that watches up to 4 directory handles (persisted in IndexedDB, key `monitorDirs`, shared `awdIdb` kv). A ~2.5s poll (paused while the tab hides) scans every watched tree bounded by depth/count caps, diffs `lastModified`+size snapshots, and re-reads only changed text files. The panel renders: the task checklist in three tiers (confirmed = `- [x]` in `tasks.md`; provisional = a normalized-substring match against agents' `t: {task} done` lines; open), with `(@slug)` owner tags; per-agent status chips from TOON entries (own file authoritative, a done handoff in `shared.md` wins, orchestrator log lines excluded); a change feed; and a click-to-view file list whose `.md` files render through `renderMarkdown` with an `awd:record` header chip (slug, status, date) - so a `.workflow` watch doubles as a durable-record browser. Canvas agent nodes carry live status dots (blue active, green done, red blocked/failed) through the guarded `monitorNodeStatus` hook, matched by label slug. `monitorRecompute` locates `tasks.md` at any depth and scopes the run surface to its directory: ONE watch covers a multi-repo run's live surface (the memory folder is shared across repos); extra watches add per-repo record browsing. Emissions carry the two-tier convention: every orchestrator memory variant seeds `tasks.md` (copied from the durable record's checklist when a record is kept - conditional at generation - else derived from the plan) and ticks each box individually as step reports confirm; every sub-agent appends `t:` lines to its OWN file at task completion (one writer per file, zero contention); the single-session variant ticks `tasks.md` itself. The record protocol adds owner tags, the kickoff tasks.md mirror, and a concision discipline. All parsing is pure string functions; the scan accepts any handle-iterator-protocol object (fake-handle tested). Everything is read-only and memory-gated with OFF assertions.

## Why and scope

Task lists tick in batches today because only the orchestrator may write the durable record (single-writer rule), and it learns of completed work when a sub-agent returns - often after ALL implementation tasks. The director wants live progress inside the designer. Design: the run's memory directory becomes a complete live telemetry surface the browser can watch (File System Access API, polling - no shipped file-watch events in browsers), and the emitted prompts gain a two-tier progress convention so granularity exists to display. The durable record stays the canonical task list; an ephemeral `tasks.md` in the memory directory is its live projection (hot-cache-over-durable-notes pattern). Scope: one removable monitor block + panel UI + canvas live badges + emission clauses + record-protocol quality pass. Chromium-only, hidden where unsupported, read-only by construction, paused when the tab hides.

## Requirements

1. Watching MUST require one directory pick (the memory dir or its parent), persist across visits via IndexedDB (repoConnect pattern), and re-arm with one click when permission lapses.
2. The panel MUST show: the task list with three visual states (open / provisional / confirmed), per-agent status, a chronological feed from `shared.md`, and a click-to-view file list. Canvas nodes MUST carry live status dots (running / done / blocked) matched by label slug.
3. Two-tier progress MUST be emission-backed: the orchestrator seeds and ticks `tasks.md` (confirmed tier, one writer); each sub-agent appends `t: {task} done` lines to its OWN memory file at the moment a task completes (provisional tier, single-writer per file, zero contention). The single-session variant ticks `tasks.md` directly (the orchestrator IS the executor).
4. Every emission addition MUST be memory-gated with OFF assertions; the record-protocol additions ride the existing durable gate (durable requires memory - the superset invariant holds).
5. Parsers MUST be pure functions over strings (TOON entries, checklists, provisional ticks) - fully unit-testable; the directory scan MUST accept any object speaking the handle async-iterator protocol (fake-handle testable, the scanRunReportsFromHandle precedent).
6. The record protocol quality pass: checklist boxes MAY carry an owner tag `(@{slug})` so tasks map to steps, kickoff mirrors the checklist into `tasks.md`, and the protocol gains an explicit concision discipline (the record competes with OpenSpec-style multi-file specs by being ONE dense navigable file - never padded).
7. The monitor MUST double as a durable-artifact browser: the file viewer renders markdown through the existing renderMarkdown pipeline, and a file carrying an `awd:record` fence shows a header chip (slug, status, date) - so picking `.workflow/` browses past changes as pleasantly as watching a live run.

## Approach and decisions

- Poll, do not push: FileSystemObserver is an origin trial only; snapshot-and-compare on `lastModified` + size every ~2.5s, re-reading only changed files, capped depth and file count. Rejected: watching arbitrary agent-edited repo files (git's job; tells WHAT changed, never WHERE THE RUN IS).
- `tasks.md` in the MEMORY dir rather than monitor-reads-the-record: one picked directory serves the whole monitor, and the record (repo-side) stays canonical. Rejected: dual connections (repo + memory) - friction kills the demo.
- Provisional ticks live in each agent's OWN file: preserves the single-writer-per-file invariant that shaped the memory protocol. Rejected: agents appending to tasks.md (write races) and agents writing the record (violates the one-writer-per-beat rule).
- The parked incremental-checkpoint patch is superseded by intent: these clauses are its purpose-built successor, written fresh against the current protocol. The parked artifact can be retired.

## Surface area (file -> role)

- index.html: LIVE RUN MONITOR removable block (state, idb reuse, scan, parsers, poll loop, panel render), toolbar button + panel markup + CSS, canvas status-dot hook (guarded), emission clauses in genMemoryProtocol / genAgentMemoryPreamble-Postamble / genSingleAgentMemoryProtocol / orchestrator kickoff sites, genDurableRecordProtocol checklist + kickoff lines.
- tests.html: parser units, fake-handle scan, merge logic, emission ON/OFF pins, panel DOM pins, exposure lines for monitor consts.

## Task checklist

- [x] Emission: tasks.md seeding + orchestrator tick discipline in both orchestrator memory variants (@orchestrator)
- [x] Emission: per-agent provisional `t:` clause in the per-agent and workflow-format memory beats (@orchestrator)
- [x] Emission: single-session variant ticks tasks.md directly (@orchestrator)
- [x] Record protocol: owner tags on checklist boxes + kickoff mirror line + concision discipline (@orchestrator)
- [x] Emission ON/OFF test pins across formats (@orchestrator)
- [x] Monitor core: state, supported gate, connect/persist/permission, resolve slug dir, multi-tree watches (@orchestrator)
- [x] Monitor scan: bounded recursive enumerate over the handle protocol + snapshot diff (@orchestrator)
- [x] Parsers: TOON entries, task checklist, provisional ticks, merge, agent statuses (@orchestrator)
- [x] Poll loop with visibility pause + changed-file re-read only (@orchestrator)
- [x] Panel UI: drawer, connect states, tasks three-tier, agents, feed, file viewer + record chip (@orchestrator)
- [x] Canvas live status dots matched by slug, guarded and removable (@orchestrator)
- [x] Parser + merge + fake-handle + DOM + emission tests green (@orchestrator)
- [x] Docs: README, TECHNICAL, help modal (Explain needs nothing: the memory row already unfolds the protocol text that names the monitor) (@orchestrator)
- [x] Review pass, fixes, three-surface record finalize (@orchestrator)

## Verify

- `./run-tests.sh` (1643 -> 1660: 6 emission pins + 11 monitor-core tests incl. fake-handle scan and full-panel render)
- Headless visual: panel rendered from fabricated state over the fullstack preset - three-tier ticks, owner tags, agent chips, feed, and live canvas dots all confirmed on screenshot

## Gotchas / non-obvious

- Browsers ship no file-watch events (FileSystemObserver = Chromium origin trial only); polling is the design, not a shortcut.
- Provisional-to-checklist matching is normalized substring matching - agents restate task names; exact-match would silently drop ticks.

## History

- 2026-08-25: created - design record authored as the spec before implementation (by direct session)
- 2026-08-25: built in one delivery per the director's ask - emissions (tasks.md + provisional t: lines across all four memory variants), record-protocol quality pass (owner tags, kickoff mirror, concision discipline), monitor block (multi-tree watches added mid-build on a director question about multi-repo runs), panel UI, canvas dots, docs. 1643 -> 1660, visual proof captured. Supersedes the parked incremental-checkpoint patch by intent (fresh clauses against the current protocol; the parked artifact can be retired) (by direct session)
- 2026-08-25: high-review fixes (8 finder angles; the parent reviewer stalled after finding, so adjudication ran in-session) - file-row handler injection killed (index-based selection; a filename with quote entities never enters a JS string), re-grant now restarts the poll timer, a lapsed watch no longer wipes the run surface (removals gated on actually-scanned prefixes), duplicate-label nodes get dots through buildAgentSlugMap, revise-dispatched agents show active again (ISO-timestamp ordering beats a stale shared done), short tasks gained a false-half-tick length guard, capitalized Tasks.md reads back, newest tasks.md wins across multiple watched runs, the slug-guess auto-descent dropped (could persist a stale handle forever), watch removal is by name (index race), per-watch scans + text reads parallelized, canvas repaints only when a status changed, panel keeps scroll position, feed capped by one const, help-modal Handoff heading un-orphaned, monitorSupported aliased. Deliberately kept: parseToonEntries body lines and scan-record mtime/size fields (both keep the pure layers testable with plain fabricated objects); emission-prose dedup deferred with a sync-comment instead (the three variants phrase deliberately differently around a shared contract). +6 regression pins, 1661 -> 1667 (by direct session)
