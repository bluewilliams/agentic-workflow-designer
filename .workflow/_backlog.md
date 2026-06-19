# Backlog (future work, not yet built)

Parked items with the real-run evidence behind them, so the dedicated passes start from data, not guesses. Newest context first. Each item: what, why, the evidence, and the design options.

## 1. Spec-kit-style discrete-task granularity (the big one)

**What**: a dynamic-granularity tier for the durable record's Task checklist - flat checklist for small work, but for large work make the granular tasks the EXECUTION units (spec-kit tasks.md model: per-task IDs, ordering/dependencies, parallel markers, phases), so progress is trackable and resumable mid-implementation.

**Why / evidence (a real cold run)**: the durable record's Task checklist is granular (DTO, handler, factory, validation, predicate, tests - 8 items), but the workflow executes coarse: ONE Implementer sub-agent does all 8 internally and reports back ONCE. So there is no execution boundary that maps to a single checklist item - the orchestrator can only tick them as a batch after the Implementer returns (and in the run, not until finalize). If the Implementer dies after item 4 of 8, the record has no idea which 4 were done. This is the concrete validation we said we needed before building this tier: it is no longer speculative.

**Design options**:
- Lighter: the Implementer emits per-task progress as it finishes each item (update the checklist or its handoff). Caveat: sub-agents currently write only the ephemeral memory, not the durable record (write-race avoidance) - needs a defined channel.
- Heavier (spec-kit model): explode implementation into per-task steps that each report, giving real per-task checkpoints and mid-implementation resumability. This IS the dynamic-granularity tier.

**Caution**: the hard part is the dynamic scaling - small tasks must stay a flat checklist or every small record bloats. Drive this off a real large task so the scaling is tuned against reality.

## 2. Durable-record per-step cadence: structural fix

**Status update (2026-06-16)**: partially addressed. The KEEP CURRENT bullet now explicitly requires ticking EACH checklist item per step (covering one Implementer finishing many items, tick-now-not-at-finalize) - see .workflow/cadence-granularity-and-clarify-sensitivity.md. The STRUCTURAL options below remain open if that prose sharpening still proves insufficient on the next cold run.

**What**: make the per-step record update STRUCTURAL, not just prose. The enforced "KEEP CURRENT (after EVERY step)" section now in genDurableRecordProtocol is necessary but NOT sufficient.

**Why / evidence (a real cold run)**: the run's prompt DID contain the KEEP CURRENT text, and the cold executor still skipped it - it created the record at kickoff, updated it once after the Planner (substantive fold-in), then lapsed: Status stuck at "(planning)", checklist all unticked, Current state frozen at post-Planner, even at the Reviewer. A cold orchestrator does the substantive fold-ins but skips the mechanical bookkeeping (status bump, checklist ticks) between spawns.

**Design options**:
- Interleave an explicit "### Update the record" beat into the generated Execution Plan after each `### Step N`, so the orchestrator steps through it rather than relying on discipline.
- And/or have each sub-agent's handoff emit "checklist items I completed + new status" so the orchestrator just transcribes it instead of deciding to.

## 3. Clarify gate sensitivity (optional prompt-tuning)

**What**: bias the clarify gate toward ASKING on the high-value ambiguity categories (null/empty/error cases, conflicting behavior) rather than resolving them silently.

**Why / evidence (a real cold run)**: clarify was ON, but the gate under-triggered - the Planner resolved a real null/below-threshold fork itself ("below-threshold/null absent from dict") and documented it as a decision instead of asking. Not a regression (gate wiring/text unchanged); a judgment call that leans toward "proceed and document the assumption." Whether that is acceptable depends on whether the director wanted to weigh in on null handling.

**Tradeoff**: more asking = more interruptions. Make it a sensitivity knob, not always-ask.

## 4. Remaining Agent SDK toggle gaps

**What**: genAgentSDK still does not inject clarifyFirst, Datadog (grounding + step), or the per-step code-search hint (only consumeRecords was closed - see consume-prior-records record). Also: genAgentSDK reimplements mcpAtlassian and mcpCodeSearch as inline Python-comment banners that duplicate the shared hint helpers (drift risk).

**Why / evidence**: surfaced by the toggle-wiring audit (read-only run). Datadog is simply newer than the SDK exporter; clarify has a non-interactive branch that is relevant to SDK; the duplication is a maintenance smell.

## 5. batchUndo dead code

**What**: `batchUndo(fn)` at index.html:3103 is defined but never called. Trivial removal whenever convenient. Surfaced by the toggle-wiring audit.

## 6. Worktree support for large / parallel workflows

**What**: optional git-worktree isolation for parallel or epic-level workflows - each parallel slice works in its own worktree + branch, integrated at the join, with a PR per slice.

**Why**: isolation (parallel writers do not stomp each other's working tree) and smaller, independent PRs.

**Key framing**: worktrees are the ISOLATION half. The SMALLER-PR half comes from decomposing the epic into independent vertical slices (= backlog #1). Worktrees alone = conflict-avoidance for parallel fan-outs; worktrees + slicing = the full "epic -> small PRs" story. Build with #1 or right after.

**Two build options**:
- Standalone subset (smaller win now): "isolation for parallel fan-out steps" - a gated toggle that fires ONLY when the workflow has a parallel group; give each parallel writer a worktree, integrate at the join. ~half the size, clearly useful.
- Full feature (with #1): epic -> vertical slices -> worktree + branch per slice -> PR per slice.

**Size**: medium prompt-injection feature (toggle + a `worktreeHint()` lifecycle block + relevance-gated injection at the generator sites + a per-worktree Delivery/PR variant + tests) - same additive pattern as the MCP/Delivery toggles, low-risk. The code is small; the prompt DESIGN (lifecycle, integration-merge, cleanup) is the real work.

**Agent-prompt impact**: minimal. The role templates (planner/implementer/etc.) stay unchanged. It is a new orchestrator-level lifecycle block + a small gated per-agent line ("operate in your assigned worktree at {path}, do not touch others") + a per-worktree Delivery variant. Additive injection, not a rewrite.

**Caveats**: prompt-instructed worktrees are more fragile than programmatic ones (orphaned worktrees, integration-merge conflicts at the seam); opt-in by nature (overhead for ordinary sequential tickets); the durable-record protocol already anticipates multi-branch epics via the `epic` facet + `siblings` cross-links in `_index.md`.

## 7. Generic adversarial-critic agent + attach-anywhere review loop

**Status (2026-06-18): DONE.** Shipped the generic `adversary` role (one template + role-aware lens + materiality bar) and the one-click context-menu attach/detach review loop. See .workflow/generic-adversarial-critic-agent-with-one-click-attach.md. 671/671 tests, independent review PASS. The debate PANEL (below) remains deferred.

**What**: a reusable adversarial "Critic" agent type (refute-first posture) attachable to ANY step, looped back through the existing decision routing (review -> if issues, re-spawn the source agent with the feedback, max N cycles) - generalizing code review to any work product (plan, research, design, docs).

**Why**: the adversarial second look is a proven quality lever and is underused beyond code review. Adversarially reviewing the PLAN before implementation catches the most expensive errors earliest.

**What we already have**: Reviewer / Validator / Tester roles + the Decision node's "if NEEDS REVISION re-spawn X (max 3 cycles)" loop-back (Feature Dev / Bug Fix presets). So the loop already EXISTS for code.

**The gaps**: (a) a generic critic role with an explicit refute/skeptical posture (today's Reviewer is balanced, not adversarial); (b) easy one-action attach of "adversarial review + loop-back" to any node; (c) optional multi-critic panel (N lenses that can challenge each other) for high-stakes steps.

**Recommendation / increments**:
- First: a generic `adversary`/`critic` agent type (refute-first prompt) + reuse the existing decision loop-back. Small-medium.
- Second: a UI affordance to attach a critic + back-edge to any node in one click. Medium.
- Defer: the debate PANEL (N critics, majority or synthesis) - high cost, sharp diminishing returns; opt-in, high-stakes only, never default.

**Key design note**: adversarial value depends on INDEPENDENCE + posture - the critic must default to skeptical, treat the burden as on the work to prove itself, and not rubber-stamp. Cost scales with cycles and critic count, so cap cycles and gate panels.

**Size**: generic critic + reuse loop = medium; the attach-anywhere UI = medium; the full panel = medium-large.
