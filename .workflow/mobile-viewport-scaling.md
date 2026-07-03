# Mobile viewport: scale to fit instead of clipping

Branch: main. Status: current.

```awd:record
{"slug": "mobile-viewport-scaling", "status": "current", "date": "2026-07-03", "files": ["index.html"], "verify": ["./run-tests.sh", "grep -c 'width=1280' index.html"], "superseded_by": null}
```

## Current behavior

The viewport meta declares a fixed width of 1280, so mobile browsers scale the whole desktop layout to fit the screen - tiny but complete and pinch-zoomable. Desktop browsers ignore the viewport tag entirely.

## Why and scope

The page declared `width=device-width, initial-scale=1.0` - the responsive-layout promise - while the layout is a fixed desktop grid (320px sidebar + canvas, height:100vh). Phones took the promise literally, rendered at device width, and clipped the app (owner's phone screenshot). Owner asked for basic scaling: not cut off, tiny is fine. One-line fix, deliberately NOT a responsive redesign.

## Key decisions

- Fixed 1280 viewport over a responsive rework: the app is a desktop tool; scale-to-fit gives mobile users a complete, zoomable view at one line of risk-free change. A real mobile layout is a separate product decision if ever wanted.

## Verification

- 1319/1319 unchanged (no test surface); content-lint. Real-device check = owner's phone after next deploy.

## Task checklist

- [x] Viewport meta swapped with explanatory comment
- [x] Suite green; content-lint

## Update (same day): dvh for the iOS bottom-bar strip

Owner's phone still clipped the bottom: 100vh on mobile Safari includes the strip behind the browser's bottom bar, and the app suppresses page scroll, so the output panel hid underneath with no way to reach it. The app grid now uses height:100dvh (dynamic viewport height, tracks the visible area as browser bars show/hide) with 100vh kept as the fallback line for older engines. Desktop treats dvh as vh; zero impact.

- [x] height:100vh;height:100dvh on the body grid
