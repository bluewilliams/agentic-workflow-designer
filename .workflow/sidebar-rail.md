# Sidebar rail (the whole sidebar folds to a thin rail)

Context: no work item (direct session; the first product ask relayed from the organization that will fork the designer: can the whole sidebar collapse? Only sections folded until now). Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- **One body class, one grid track.** `body.sidebar-rail` swaps the page grid's first track from 320px to 36px; the canvas and the prompt panel take the width because the page grid already pins every panel to its cell. The track animates (`grid-template-columns`, 240ms). The sidebar's children keep their width during the slide (clipped by the sidebar's overflow) and fade; once the track has settled, `body.sidebar-rail-settled` removes them from the layout. Expanding reverses it in one frame: the children re-enter and the track grows.
- **Two toggles, one key.** A chevron beside the title folds the sidebar; the rail (the sidebar's first child, shown only while railed) carries a chevron and a vertical "Designer" label that both expand it. `[` toggles it from the canvas, beside the existing `1`, `2`, and `?` keys, and is ignored while typing. Both toggles carry `aria-expanded`.
- **Persisted** in `awd_sidebar_rail`, restored at boot through `initSidebarRail()` with the transition suppressed for that first paint, like the section fold state.
- **Explicit reveals open the rail**: an Explain deep link (`jumpToSection`), the empty-canvas quick start links, and the save-name nudge. **Selecting a node does not**: the Node Configuration section still re-opens underneath, but dragging on a wide canvas never pops the sidebar back open. Section folding is unchanged underneath the rail.
- Help and README each gain one sentence.

## Why and scope

Once a workflow has twenty nodes, or during a demo, the 320px column is dead weight and the canvas is the point. A thin rail, not a drawer or a hover reveal, because the sidebar is where the work starts and the inputs must stay findable. Non-goals: a mini sidebar with icons on the rail; auto-expanding on node selection; a resizable sidebar width.

## Verify

- `./run-tests.sh`: 1856 -> 1864. Suite `Sidebar rail`: the expanded baseline; fold to 36px with the canvas column at 36, sections hidden, rail bar shown, persisted, and back; restore at boot with the no-animation guard released; explicit reveals open it and node selection does not; the `[` key toggles outside inputs and is ignored inside.
- Real browser: the slide animates both ways; the rail shows the chevron and the vertical label; the toolbar labels return once the canvas column is wide enough.

## History

- 2026-10-25: created - the rail, two toggles, the `[` key, persistence, explicit reveals, help and README. 1856 -> 1861 (by direct session)
- 2026-10-25: review round 1 (8 findings, all acted on) - `[` ignores modifier keys (Cmd+[ stays Back); the pressed toggle hands focus to its counterpart, the rail label is a real control (role, tabindex, Enter and Space), both toggles name the sidebar through aria-controls; `prefers-reduced-motion` drops the slide and settles at once; on expand the contents keep their width while the track grows (`sidebar-rail-opening`), so nothing rewraps; the quick-start links reveal through `jumpToSection`; the `[` key is listed with the other keys in the help and the empty-canvas legend; a dead guard removed; the commit must carry the index and timeline with the record. 1861 -> 1863 (by direct session)
- 2026-10-25: review round 2 (10 findings, all acted on) - the save-name nudge expands Requirements as well as the rail (the field was inside a folded section); the contents keep their measured width (the sidebar's clientWidth beside the scrollbar, written to `--sidebar-content-w` at fold time) during both slides, so nothing rewraps at either end; the scroll position survives a fold; `[` ignores only the Command key, so AltGr layouts that type `[` with Ctrl+Alt reach it; any focused sidebar control hands focus to the visible toggle, not only the two chevrons; the rail is one button (chevron plus the vertical label inside it) carrying the ARIA state; the widths and the duration live in `--sidebar-w`, `--rail-w`, `--rail-ms`, read by both CSS and JS; the quick start makes one scroll through `jumpToSection(id, innerSelector)`; the timer is cleared before the same-state early return, which also drops the opening class on an instant reset; the suite's afterEach follows the collapse-module rule. 1863 -> 1864 (by direct session)
- 2026-10-25: while landing the round-2 scroll fix - the focus hand-off itself scrolled the sidebar back to the top (a focus call scrolls its target into view), which is why the restored position vanished; the hand-off now focuses with preventScroll, and the restore runs after layout has the children back. Suite steady at 1864 (by direct session)
