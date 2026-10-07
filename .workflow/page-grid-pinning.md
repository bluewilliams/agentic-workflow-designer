# Page grid pinning (the four panels own their cells; a foreign body child never steals one)

Context: no work item (direct session, director-reported: a colleague opened the published designer and could not see the Copy button; the screenshot showed the canvas dropped to the middle of its column with an empty region above it and the prompt panel sitting under the sidebar in the 320px column, its format tabs cut off after Agent Teams). Branch: main. Status: current. Repo: agentic-workflow-designer.

## Current behavior

- `<body>` is the page grid (320px sidebar column, canvas column; rows 1fr / auto / auto). Its four in-flow children are now pinned to their cells: `.sidebar` column 1 rows 1-3, `.main-area` column 2 row 1, `.prompt-resize` column 2 row 2, `.prompt-area` column 2 row 3. Before, only the sidebar's row span was explicit and the other three relied on auto-placement.
- `grid-auto-rows:0` on the body: an element that still lands in an implicit row (anything in-flow that is not one of the four) takes no height, so the canvas keeps its full height whatever is injected.
- Every other direct body child (context menu, toast, overlays, tip) is positioned out of flow and was never a grid item; nothing about them changes.

## Why and scope

A browser extension that injects an in-flow element into `<body>` (a bare custom element or a div, typically prepended) used to take the first free cell. With the sidebar locked to its rows first, auto-placement then put the foreign element in column 2 row 1 (the 1fr row, so an empty element drew the whole canvas height as blank space), the canvas in column 2 row 2 at its intrinsic height, the resize handle in row 3, and the prompt panel in an implicit row 4 under the sidebar: 320px wide, with `overflow:hidden` clipping the tabs past Agent Teams and the whole actions group (Explain, Explain Step, Copy). Reproduced in headless Chrome with one prepended element: prompt at x=0, 320 wide, Copy clipped; identical for an element inserted before the canvas. After the fix every probe (prepend, before-canvas, a visible 40px banner, removal) measures byte-identical to the baseline. Scope: five CSS declarations and one suite. Non-goals: no wrapper element around the panels (same robustness, more markup churn), no hiding of foreign elements (not ours to touch), no change to the resize logic.

## Approach and decisions

- Explicit placement on the four panels (rejected: wrapping them in an `#app` grid container) - pinning is five declarations with no markup change, and it closes the hole fully: a foreign element can only ever land in an implicit row.
- `grid-auto-rows:0` (rejected: leaving implicit rows auto-sized) - an injected element with visible height would otherwise shrink the canvas by that height from the bottom-left; with zero-height implicit rows the layout is invariant and the stray content falls past the viewport, which the body already clips.
- Geometry test with the test iframe shown (rejected: computed-style assertions on `gridColumnStart`) - the suite's iframe is `display:none`, so the suite shows it for this one describe and measures real rectangles: the contract is where the panels and the Copy button land, not which declaration produced it. The frame is hidden again in afterEach and the foreign element removed.

## Verify

- `./run-tests.sh`: 1806/1806 (baseline geometry: canvas beside the sidebar at the top, prompt panel spanning the canvas column, Copy inside it; a prepended in-flow element changes nothing; a visible 40px element before the canvas changes nothing; removal leaves the baseline). The two injection tests fail against the previous CSS (prompt panel at x=0, 320 wide), proven by running the suite on a copy with the pins removed.
- Content lint clean on all touched files
- NOT verified: which extension injected the element on the colleague's browser; the reproduction uses a bare custom element and a div, the two shapes an in-flow injection takes.

## History

- 2026-10-07: created (five CSS declarations on the body grid and its four panels; one geometry suite) after a colleague's screenshot showed the prompt panel under the sidebar with the Copy button clipped. 1802 -> 1806 (by direct session)
