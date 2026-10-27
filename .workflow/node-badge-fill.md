# Node badges: no badge on decision nodes, visible fill on the rest

Context: no work item (direct session, director screenshot on the light theme: a black question mark sat against the label on a decision diamond; invisible on the dark theme). Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- Decision nodes draw no icon badge. The diamond is the icon, and condition labels usually end in a question mark already.
- The other node types keep their badge at x=16. The `.node-badge` rule carries an explicit `fill:var(--text2)`, so the plain-glyph badges (Task check, Parallel bars) read on both themes. The emoji badges (Agent, Input, Output) are color glyphs and ignore fill, as before.

## Why

SVG text defaults to black when no fill is set, which is why the badge only showed on the light theme. On the diamond the badge sat at `w / 2 - 40` while the label is centered at `w / 2`, so any label longer than about eight characters ran into it. Dropping the badge removes the collision outright. Moving it to the top vertex was the alternative, rejected as redundant with the shape.

## Verify

- `./run-tests.sh`: 1864 -> 1866 (a decision node has no badge and keeps its label; a task badge carries a non-black computed fill)

## History

- 2026-10-25: created - decision badge removed, badge fill set. 1864 -> 1866 (by direct session)
