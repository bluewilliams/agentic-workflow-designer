# Defect posture: a per-node intensity selector for the found-defect protocol

Workflow: defect-posture. Branch: main. Status: finalized, committable.

```awd:record
{"slug": "defect-posture", "status": "current", "date": "2026-07-03", "files": ["index.html", "tests.html"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

The **Defect Posture** select has two homes with two meanings. On the CODER FAMILY (coder, backend, frontend, general - the only roles with the knob; debugger nodes are investigator-shaped in this app's presets, and testers/verifiers carry the balanced protocol with their `config.defectPosture` ignored) it tunes fix-vs-record: **Balanced** (default, byte-identical to the protocol as shipped), **Record-only** (surgical diffs, fix only true blockers), **Aggressive** (opportunistically heal the working area, tested and declared, balloon signal intact). On REVIEWER nodes it tunes flag-back intensity for pre-existing defects the review SPOTS - never fixing, never gate-failing: **Balanced** (default, emits nothing - byte-identical to the pre-knob reviewer; pre-existing defects become non-blocking notes), **Surgical** (judge only the change, "the diff is your entire jurisdiction"), **Aggressive** (sweep the diff's neighborhood and report a dedicated "Flagged pre-existing defects (for the orchestrator)" section; flags can never make the verdict NEEDS REVISION). When any reviewer runs aggressive, every prose format's orchestrator guidance gains a topology-grounded handling line: flags dispatch to the fixer step ONLY along the review gate's DRAWN revise edge, as a follow-up brief AFTER the gate passes - outside the revise loop, never consuming gate cycles - with format-aware continuity (Teams re-messages the same teammate, Sub-Agents respawns onto the memory file, Workflow/Claude continue in-session); when the canvas draws no revise edge the line is RECORD-ONLY and forbids inventing a route; every path records to Found bugs. A non-balanced posture renders on the node subtitle ("aggressive defects") so a configured deviation is visible on the graph. `nodeDefectPosture(node)` resolves absent = `balanced`; `foundDefectNote(node)` is the single emission surface for both knobs at all per-step sites in the four prose formats; the reviewer template additionally judges declared fixes against the producing step's declared posture. Explain rows are posture-aware on both homes and name the selector as the lever; posture rides the canvas serialization (absent keys stay absent, explicit values round-trip).

## Why and scope

The found-defect protocol shipped with one intensity. Different workflows legitimately want different lines between fix and record: a hotfix wants a surgical diff, a cleanup sprint wants opportunistic healing - and the Explain row on carrying roles deserved a real lever (director design conversation, born from the reviewer Explain-row confusion). Blue's ruling: the default MUST be byte-identical to the shipped protocol, so the selector changes nothing for anyone who never touches it. Non-goals: no posture for non-carrying roles (a reviewer that fixes stops being a reviewer - the type change or a Fixer step is the honest path); no workspace-level default (posture is per-node, workflow shape decides).

## Requirements

1. Balanced MUST be byte-identical to the pre-feature protocol, with absent and explicit keys equivalent. (Test: balanced is byte-identical: absent key and explicit balanced emit the same text)
2. The three postures MUST emit distinct contracts while all preserving never-work-around and declared-diff honesty. (Test: the three postures emit distinct contracts, all keeping the honesty rules)
3. Posture MUST be per-node in generated output. (Test: posture is per-node in generated output: each sub-agent carries its own)
4. The select MUST render only for carrying roles. (Test: Defect Posture select renders only for carrying roles)
5. Explicit postures MUST round-trip serialization; absent keys MUST stay absent and resolve balanced. (Test: explicit posture round-trips through serialize/deserialize; absent stays balanced)
6. The reviewer MUST judge declared fixes against the producing step's declared posture. (Test: reviewer clause judges declared fixes against the producing step posture)
7. Explain MUST show the active posture, name the lever, and agree with the live helper. (Test: Explain row reflects the active posture, names the selector, and its probe equals the live helper)

## Success criteria

- A user who never opens the selector sees zero change in any generated prompt.
- A hotfix workflow can demand a surgical diff and a cleanup workflow can license healing, per node, and the reviewer's scope judgment follows the declared posture instead of fighting it.

## Spec quality check

- [x] Each requirement testable and unambiguous
- [x] Scope bounded (Non-goals stated)
- [x] No open clarifications remain
- [x] Every scenario names a verifying test
- [x] Success criteria measurable

## Approach and decisions

- Variants live inside `foundDefectNote` itself (three return branches), not as separate helpers - one emission surface, the six per-step call sites untouched, so posture can never diverge across formats.
- `nodeDefectPosture(node)` accessor with `|| 'balanced'` over seeding the key into NODE_DEFAULTS - absent-key-means-default keeps older saves and presets untouched and the serialization story free (nothing new to serialize when unset).
- The select reuses `configSelect` and the generic `node.config[key] = val` delegated handler - zero new plumbing; visibility rides the same conditional-render pattern as the writer's Writing Style select.
- Reviewer clause folded into the existing declared-fix sentence (one sentence, as ruled) rather than a new criterion bullet.

## Surface area (file -> role)

index.html: `nodeDefectPosture` + the three-branch `foundDefectNote` (beside FOUND_DEFECT_ROLES); the Defect Posture `configSelect` block in the node-config panel (after Model, gated on FOUND_DEFECT_ROLES); the reviewer template's posture sentence; the Found-defect Explain row's ON status; the help-modal Defect Posture sentence. tests.html: the "defect posture (per-node selector)" suite (7 tests).

## Task checklist

- [x] nodeDefectPosture accessor + three emitted variants (balanced byte-identical)
- [x] Node-config Defect Posture select, carrying roles only
- [x] Reviewer declared-posture clause
- [x] Explain row posture status + lever
- [x] Help modal sentence
- [x] Tests: byte-identical pin, distinct contracts, per-node emission, UI visibility, round-trip, reviewer pin, Explain agreement
- [x] Full suite green via ./run-tests.sh

## Verify

- `./run-tests.sh` -> PASS 1481/1481 (baseline 1474 + 7; zero regressions - the byte-identical default meant no existing pin moved).
- Content-lint grep on changed files -> exit 1; no em dashes in additions.

## Gotchas / non-obvious

- A node whose type changes away from a carrying role keeps a stale `defectPosture` key - harmless (emission gates on role, same tolerated-stale-key precedent as the collapse module), and the key re-applies if the type changes back.
- The balanced test pins absent-vs-explicit equality rather than a frozen text copy, so future deliberate wording changes to the protocol update ONE string without a twin to keep in sync.

## History

- 2026-07-03: created (by defect-posture)
- 2026-07-03: reshaped per two director rulings - DECLUTTERED (knob narrowed to the coder family; debugger/tester/verifier keep balanced emission without UI) and the REVIEWER gained its own flag-back posture (spot-and-report to the orchestrator, never fix, never gate-failing) with a topology-grounded dispatch line (drawn revise edge only, outside gate cycles, format-aware continuity; record-only when no edge is drawn) and posture-on-subtitle canvas visibility (by defect-posture)
- 2026-07-03: dispatch handling gains the reconcile clause - flagged defects an earlier step recorded with a considered deferral reason keep their disposition; a louder flag never overrides a recorded judgment (director scenario: balanced implementer defers, aggressive reviewer re-flags) (by defect-posture)

## Outcome

The found-defect protocol's fix/record line is now a per-node dial with an honest default: Balanced is character-for-character the shipped protocol, Record-only delivers surgical diffs, Aggressive licenses declared-and-tested healing - and the reviewer's scope judgment reads the dial instead of fighting it. index.html + 7 tests; 1474 -> 1481.

## Built with (provenance)

Workflow `defect-posture`: executed directly by Claude (Fable) as a single implementing agent under Blue's live direction (design settled in conversation: three high-level options, balanced-as-default ruling, reviewer-never-carries decision). Durable record + grounding conventions honored by hand.

## Links

- Grounds on / touches: grounds on `.workflow/agent-craft-batch.md` (the found-defect protocol + reviewer clause this feature parameterizes); amended `.workflow/agent-craft-batch.md` (Current behavior gains the posture knob; History line added).
- Branch: main (uncommitted delivery for the director).
