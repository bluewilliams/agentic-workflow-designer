# Surface critical assumptions (shown once, the run does not stop)

Context: direct session, director-requested as the next change that improves every run. Branch: main. Status: current. Repo: agentic-workflow-designer.

```awd:record
{"slug": "surface-critical-assumptions", "status": "current", "date": "2026-11-11", "files": ["index.html", "tests.html", "README.md"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

When neither gate is on (Clarify requirements first, Approve plan before build), every prose format (prompt, Sub-Agents, Agent Teams, Claude) tells the orchestrator to surface critical assumptions once, just before the first step that changes files or produces the deliverable. An assumption is critical only when a wrong guess would change what the result observably does or the shape of the solution (its architecture, a contract, a data schema) AND would be costly to undo. At most three are shown, numbered, most consequential first, each as the option taken, the option passed over, and what the choice decides, so the director can redirect one with a reply as short as "2: the other option". If more pass, one line says how many more are in the step handoffs (and the durable record, when one is kept). If none pass, the orchestrator says nothing. It never waits, applies a redirect if one arrives, and never raises assumptions again mid-run.

## How it works

`criticalAssumptionsHint()` returns the one instruction, or nothing when `clarifyFirst` or `approvePlan` is on, because each of those gates already puts the questions or the plan in front of the director. `pushSharedHints` emits it right after the Clarify gate's slot, so the four prose formats carry it in the orchestrator header. The surprise: it is the only orchestrator instruction whose normal outcome is silence.

## Why and scope

Every run's outcome is capped by requirement clarity. With Clarify off (the default), ambiguity was resolved silently and labeled only in step handoffs the director may never read; a wrong guess surfaced at review, after the build. Scope: the hint, its emission, its Explain row, tests, docs. Non-goals: no new switch; no stop; no change to the Clarify or Approve plan gates; the SDK format is unchanged (minimal by owner priority).

## Approach and decisions

- Non-blocking by design: the tool's strength is that a run is hands-off once it starts (director).
- Limited on purpose so large work cannot flood the director: two tests, a cap of three, silence when nothing passes, one moment only (director: "an epic with many stories could include many assumptions which could overwhelm").
- "Critical" covers architecture as well as visible behavior (director asked whether critical meant a significant change to the architecture): the first test reads "what the result observably does or the shape of the solution".
- Each line carries the option taken and the option passed over, so weighing in is a short reply (director: "I'm going with this option, but could have done this one").
- Off under either gate, so the three mechanisms never stack.

## Verify

- `./run-tests.sh`: 2191 -> 2194 (emitted once per prose format with every clause; replaced by either gate; absent from the SDK; names the durable record only when one is kept).
- Full-output diff against the previous commit (23 presets, 8 variants, 5 formats, 920 outputs): zero removed lines, one added line in 552 outputs; SDK outputs and every Clarify or Approve plan output byte-identical. Content lint clean; no em or en dashes.

## History

- 2026-11-11: created (by direct session).
