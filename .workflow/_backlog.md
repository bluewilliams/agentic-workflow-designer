# Backlog (future work, not yet built)

Parked items with the real-run evidence behind them, so the dedicated passes start from data, not guesses. Newest context first. Each item: what, why, the evidence, and the design options.

## 1. Spec-kit-style discrete-task granularity (the big one)

**What**: a dynamic-granularity tier for the durable record's Task checklist - flat checklist for small work, but for large work make the granular tasks the EXECUTION units (spec-kit tasks.md model: per-task IDs, ordering/dependencies, parallel markers, phases), so progress is trackable and resumable mid-implementation.

**Why / evidence (a real cold run)**: the durable record's Task checklist is granular (DTO, handler, factory, validation, predicate, tests - 8 items), but the workflow executes coarse: ONE Implementer sub-agent does all 8 internally and reports back ONCE. So there is no execution boundary that maps to a single checklist item - the orchestrator can only tick them as a batch after the Implementer returns (and in the run, not until finalize). If the Implementer dies after item 4 of 8, the record has no idea which 4 were done. This is the concrete validation we said we needed before building this tier: it is no longer speculative.

**Design options**:
- Lighter: the Implementer emits per-task progress as it finishes each item (update the checklist or its handoff). Caveat: sub-agents currently write only the ephemeral memory, not the durable record (write-race avoidance) - needs a defined channel.
- Heavier (spec-kit model): explode implementation into per-task steps that each report, giving real per-task checkpoints and mid-implementation resumability. This IS the dynamic-granularity tier.

**Caution**: the hard part is the dynamic scaling - small tasks must stay a flat checklist or every small record bloats. Drive this off a real large task so the scaling is tuned against reality.

**Unified design (2026-06-21)**: #1 and #2 are the same problem from two ends. Full cross-type model (the return-once constraint, per-type cadence table, Levels 0-3, item-granularity principle) is in `.workflow/granular-checkpointing-design.md`. Deferred pending a build-task dogfood that validates Level 0 and gives real data to tune Level 2.

## 2. Durable-record per-step cadence: structural fix

**Status update (2026-06-16)**: partially addressed. The KEEP CURRENT bullet now explicitly requires ticking EACH checklist item per step (covering one Implementer finishing many items, tick-now-not-at-finalize) - see .workflow/cadence-granularity-and-clarify-sensitivity.md. The STRUCTURAL options below remain open if that prose sharpening still proves insufficient on the next cold run.

**Status update (2026-06-21)**: RE-CONFIRMED still open by the read-only audit dogfood. New evidence: genAgentSDK's durable record uses `genDurableRecordComment`, which dropped the per-step cadence beat ENTIRELY (one prose clause). DECISION: start with the transcribe-ready-handoff option below (lighter, best reliability-per-word); only reach for the interleaved "### Update the record" beats if a cold run still slips. GATING: the transcribe-handoff lives inside `genDurableRecordProtocol`, so it fires only when Keep Durable Record is on (no record = no checklist to transcribe); Ground-in-Prior-Records (read side) is unaffected. VALIDATE with a build-task dogfood - the read-only audit cannot exercise the implement -> record-tick cadence.

**What**: make the per-step record update STRUCTURAL, not just prose. The enforced "KEEP CURRENT (after EVERY step)" section now in genDurableRecordProtocol is necessary but NOT sufficient.

**Why / evidence (a real cold run)**: the run's prompt DID contain the KEEP CURRENT text, and the cold executor still skipped it - it created the record at kickoff, updated it once after the Planner (substantive fold-in), then lapsed: Status stuck at "(planning)", checklist all unticked, Current state frozen at post-Planner, even at the Reviewer. A cold orchestrator does the substantive fold-ins but skips the mechanical bookkeeping (status bump, checklist ticks) between spawns.

**Design options**:
- Interleave an explicit "### Update the record" beat into the generated Execution Plan after each `### Step N`, so the orchestrator steps through it rather than relying on discipline.
- ~~And/or have each sub-agent's handoff emit "checklist items I completed + new status" so the orchestrator just transcribes it~~ DONE 2026-06-21 (.workflow/durable-record-transcribe-handoff.md), fuller agent-side version: each agent emits DONE/STATUS via a reused gated `recordHandoffHint()` (injected per-agent across the 4 prose generators), and the orchestrator transcribes - the reliable actor produces the data. REMAINING: the heavier interleaved-beats option above, only if a build-task cold run still shows the cadence slipping. See the unified cross-type design in `.workflow/granular-checkpointing-design.md` - the interleave is only the orchestrator/Claude.ai half; the SDK needs a STRUCTURAL in-code write, and true sub-task survival needs decomposition (Level 2) since sub-agents return only once.

## 3. Clarify gate sensitivity (optional prompt-tuning)

**What**: bias the clarify gate toward ASKING on the high-value ambiguity categories (null/empty/error cases, conflicting behavior) rather than resolving them silently.

**Why / evidence (a real cold run)**: clarify was ON, but the gate under-triggered - the Planner resolved a real null/below-threshold fork itself ("below-threshold/null absent from dict") and documented it as a decision instead of asking. Not a regression (gate wiring/text unchanged); a judgment call that leans toward "proceed and document the assumption." Whether that is acceptable depends on whether the director wanted to weigh in on null handling.

**Tradeoff**: more asking = more interruptions. Make it a sensitivity knob, not always-ask.

## 4. Remaining Agent SDK toggle gaps

**What**: genAgentSDK still does not inject clarifyFirst, Datadog (grounding + step), or the per-step code-search hint (only consumeRecords was closed - see consume-prior-records record). Also: genAgentSDK reimplements mcpAtlassian and mcpCodeSearch as inline Python-comment banners that duplicate the shared hint helpers (drift risk).

**Why / evidence**: surfaced by the toggle-wiring audit (read-only run). Datadog is simply newer than the SDK exporter; clarify has a non-interactive branch that is relevant to SDK; the duplication is a maintenance smell.

## 5. batchUndo dead code - RESOLVED (now in use)

**Status (2026-06-19): no longer dead.** `batchUndo(fn)` is now called by the review-loop attach/detach (attachReviewLoop/detachReviewLoop) - it was adopted as the atomic+undoable wrapper (single pushUndo + try/finally) after the adversarial review flagged the missing try/finally. This item is closed; do not remove batchUndo.

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

## 8. Review-loop decision: No Label rename desyncs the back-edge (minor, pre-existing)

**What**: a review loop's back-edge is located by matching the connection's `label` against the decision's `config.noLabel` (in the generators, the reroute dropdown, and setReviewLoopBackTarget). If a user hand-edits the decision's **No Label** input after attaching, `config.noLabel` updates but the existing back-edge connection's `label` does not - they desync, and the back-edge can no longer be found (silent no-op for reroute; generators fall back).

**Why / evidence**: surfaced by the independent review of the reroute feature (2026-06-19). Pre-existing assumption shared by the generators (the revise-branch match); the reroute code is consistent with it and does not worsen it.

**Fix options**: when the No Label input changes on a review-loop decision, rewrite the matching back-edge connection's `label` to the new value (keep them in sync). Small, in the configInput change handler. Low priority - editing a managed review-loop decision's labels by hand is uncommon.

## 9. Cross-tool grounding: let OpenSpec exports read prior `.workflow/` records - DONE (2026-06-28)

**Status (2026-06-28): DONE (lighter option).** Shipped `openSpecGroundingBlock()` (compact, gated on `state.consumeRecords`) prepended to the FIRST artifact's instruction in `buildOpenSpecSchema`; downstream steps inherit via requires. Self-gating on greenfield; help-modal read-side/write-side split added; 3 tests; 1137/1137. Record: `.workflow/openspec-export-cross-tool-grounding.md`. The reverse direction (OpenSpec writing breadcrumbs back into our index) is now backlog #10.

**What**: teach the OpenSpec schema export to emit a grounding instruction (gated on the "Ground in prior records" toggle) so an OpenSpec run benefits from the `.workflow/_index.md` records our prompt-run workflows leave behind. Today the export wires in NONE of the three memory/record protocols - confirmed: `buildOpenSpecSchema`/`openSpecInstruction` call no `gen*` protocol; all three toggles are silent no-ops on the export (`exportOpenSpecSchema` now toasts this for the durable record only). This item closes the gap for the READ side specifically.

**The four grounding directions (the full picture)**: run-type x record-format. (a) our prompt-run reads our `.workflow/` records - works (consumeRecordsHint). (b) OpenSpec run reads OpenSpec docs - works natively via requires. (c) OpenSpec run reads our `.workflow/` records - THIS item (#9, now done). (d) our prompt-run reads OpenSpec docs - NOT done; do NOT solve by teaching the read-side a second format (polyglot reader = drift + OpenSpec has no `_index` to cheaply scan). Solve (d) instead by converging on ONE index: have OpenSpec runs append a breadcrumb to `.workflow/_index.md` (= backlog #10), so our existing grounding picks them up unchanged.

**Why this one and not the write side**: grounding is read-only, so it fits OpenSpec's generate-once-per-doc model cleanly - "read prior context before producing the first doc" is just a preamble on the first artifact's instruction. The durable WRITE side (`.workflow/{slug}.md` flywheel) fights that model (it is a single mutable read/update doc, OpenSpec has no native running-state slot) and is deliberately left out (see the durable-only export toast + help note, 2026-06-28). So the read side is the natural cross-tool bridge; the write side is not. Payoff: the flywheel goes cross-tool - records authored by our prompt runs feed OpenSpec runs and vice versa, making `.workflow/` a shared substrate rather than a per-output silo. This is Blue's framing: "allow opensepc workflows to benefit from workflow generator workflows."

**Design options**:
- Lighter: prepend a grounding preamble to the FIRST artifact's `instruction` (the plan/first step) - "if `.workflow/_index.md` exists, scan it for the files/capability this change touches and fold the relevant decisions/gotchas in before planning." Self-gating (no-op on greenfield, already a grounding property). No new artifact, no DAG change. Smallest faithful version.
- Heavier (more OpenSpec-idiomatic): a dedicated `grounding` artifact that generates a short grounding-notes doc which downstream artifacts `require`. Everything-is-an-artifact fits OpenSpec's grain and leaves a visible grounding record, at the cost of one extra doc + a DAG edge.

**Key design notes**: reuse the existing read-side prose (the inline "Ground in prior committed records" text ~line 1291) rather than authoring a second copy - drift risk otherwise. Gate strictly on the "Ground in prior records" toggle (on by default) so an unchecked export is byte-identical. Keep it inside the removable OpenSpec block. Relates to the broader grounding-coverage theme: `.workflow/agent-sdk-ground-in-prior-records-gap.md` (the SDK had the same read-side gap) and `.workflow/make-ground-in-prior-records-use-the-full-three-tier-lookup.md` (the three-tier `_timeline`/`_index`/record lookup the preamble should mirror).

**Size**: small-medium. Lighter option is a gated string prepend at the export's first-artifact site + a test asserting the preamble appears when the toggle is on and is absent when off; heavier option adds an artifact + `requires` edge + round-trip handling. Additive, removable, low-risk - same pattern as the existing gated injections.

## 10. Reverse cross-tool: OpenSpec runs drop a breadcrumb (+timeline) into our index

**What**: have an OpenSpec run authored by our exporter append a one-line entry to `.workflow/_index.md` and `.workflow/_timeline.md` pointing at its generated step docs, so a LATER prompt-run workflow's "Ground in prior records" picks up OpenSpec-authored work for free. This is the reverse of #9 and the clean way to solve grounding-direction (d) - our prompt runs benefiting from OpenSpec durable docs - WITHOUT a polyglot reader.

**Why / framing**: the key design call (from the 2026-06-28 conversation) is converge on ONE grounding substrate (`.workflow/_index.md`, our format) rather than teach our read-side to parse OpenSpec's layout. OpenSpec's generated docs are flat per-step `<id>.md` files with no index, no capability slug, no status/supersession facets - grounding-hostile. So instead of reading them natively, we have the OpenSpec run EMIT the breadcrumb in our format. Then nothing in the read-side changes; the flywheel closes both ways.

**Reconciliation with the "write side fights OpenSpec" rule**: carrying the full MUTABLE `.workflow/{slug}.md` flywheel doc into OpenSpec fights its generate-once model (no native running-state slot) - that stays excluded (see openspec-export-durable-record-toast.md). But a SINGLE STATIC breadcrumb line, appended once at end-of-run, is compatible with OpenSpec's grain: it is just one more generated artifact. So #10 = "emit a breadcrumb," NOT "maintain a living record." That distinction is the whole reason #10 is feasible where the full write side is not.

**How (design sketch)**:
- Add a final artifact to the exported schema (after `apply`, or as the last `requires`-leaf) whose instruction is: "append/update ONE entry in `.workflow/_index.md` (create the file if absent) summarizing this change in the index's one-line-per-record format - capability slug, intent, the generated step docs as the record link(s), `status: current`, date - and prepend a matching line to `.workflow/_timeline.md`." Reuse the EXACT index/timeline format prose our durable-record protocol already defines (single source of truth; do not fork the format).
- Gate it on "Keep a durable record" (the write-side toggle) so the breadcrumb-drop is opt-in and symmetric with how the prompt outputs gate their write side. (Open question: or gate on a new "leave a breadcrumb for OpenSpec runs" sub-toggle? Probably reuse Keep-a-durable-record to avoid config bloat.)
- The record link points at the OpenSpec step docs (e.g. `openspec/changes/<id>/...`), since there is no single `.workflow/{slug}.md` - the breadcrumb is the bridge, the OpenSpec docs are the detail. Grounding opens the matched breadcrumb and follows the link to the OpenSpec docs.

**Caveats / open questions**:
- OpenSpec step docs live where the schema's `generates`/change layout puts them, not in `.workflow/` - so the breadcrumb's "record link" crosses into `openspec/`. Grounding must tolerate a record link that is not a `.workflow/{slug}.md`. Minor, but the read-side prose currently assumes the link is a durable record; may need a one-line "the link may point at OpenSpec step docs" allowance.
- Format drift risk: the OpenSpec run is an LLM following an instruction, so the emitted breadcrumb must match our index format closely enough to grep. Mitigate by giving it the format verbatim + a concrete example line in the instruction.
- Supersession: a breadcrumb-only entry has no full record to diff against, so the supersede/siblings machinery is weaker for OpenSpec-authored entries. Acceptable - they are still discoverable and current-flagged.

**Size**: medium. It is one more gated artifact in the schema + reusing the existing index/timeline format text + a test that the breadcrumb artifact appears (gated) and carries the format. The real work is prose precision (so the emitted line is grep-compatible) and a small read-side allowance for non-`.workflow/` record links. Build AFTER #9 (done) since the read-side must exist to consume what #10 writes.

## 11. Purpose-built portable agents (an Agent Library) - DONE (2026-06-30)

**Status (2026-06-30): DONE.** Shipped via the dogfood workflow (Planner->Implementer->Tester->Skeptic). Save an agent node as a named/versioned/shareable preset (localStorage `awd_custom_agents`), source-partitioned (user/org/builtin) with namespaced ids (org import can never clobber user agents), version-aware merge, export/import packs, instantiate onto canvas. Its OWN toolbar "Agents" button + modal (NOT nested in the Prompt Library - decided 2026-06-30 after the nested layout stacked two near-identical toolbars; a "Library"+tabs option was considered, separate button chosen). 10 tests, 1163/1163. Record: `.workflow/portable-agents-library.md`. Open scope questions resolved: per-source packs; OWN button+modal; config-only v1 (no rules/product-doc paths yet).

**What**: let users save a configured agent node as a named, reusable, shareable "agent" and drop it into any workflow pre-wired - e.g. a "WebAPI-endpoints agent" that already knows the org's conventions/standards. The agent-node analog of the custom-prompts library we shipped.

**Why / framing (Blue, 2026-06-30)**: encode org conventions once, reuse everywhere. Highest-leverage building block for composing workflows. Orthogonal to OpenSpec - a portable agent just produces a richer artifact `instruction` on export, so no format work needed.

**Converged design decisions (from the conversation):**
- **Extend the core agent node, do NOT add a new node type.** A portable agent = a saved snapshot of the agent node's config (agentType, model, tools, prompt, notes, maxTurns, ideally Repo Context Paths). Instantiating one creates a normal agent node, pre-filled. Future-proof: new agent config fields are captured automatically via the same serialization.
- **Reuse the custom-prompts infrastructure**: localStorage + export/import JSON + add/edit/delete + the inert-until-used seam + a REMOVABLE block. Same proven pattern.
- **Source partitioning (bake into v1, painful to retrofit):** each saved agent carries a `source` = `user` | `org` | `builtin` (+ a pack name). Display grouped by source ("My Agents" / "Org: <pack>" / built-in).
- **Non-clobbering, partitioned merge:** importing an org pack only touches the `org` group - it can NEVER overwrite the user's personal agents. Dedup happens WITHIN a source by a NAMESPACED id (e.g. `org:platform/webapi-agent` vs `user:my-thing`), so cross-source name collisions coexist. Re-importing an updated org pack updates-in-place within the org group (idempotent), like `mergeImportedPrompts` but partitioned.

**Open scope questions (resolve before building):**
- Export: bundle user+org together, or always per-source packs (an "agent pack" with a declared source)?
- UI: a dedicated "Agents" tab/panel, or extend the Prompt Library UI with an Agents section?
- Does saving capture Repo Context Paths too, or just node config?
- Later harmonization: custom PROMPTS could adopt the same source-partitioning (currently one "My Prompts" group, dedup-by-title globally) - defer, design agents right first.

**Decided NOT to do (related, 2026-06-30):** ditch OpenSpec `scripts/` folder support - it is a convention (helper `.mjs` referenced from instructions), NOT part of the OpenSpec format; import already preserves the references via instruction text; managing the files does not fit a single-file browser app. Also decided NOT to infer input nodes (or synthesize decision/parallel/task) on foreign import - unlike `apply` (a real named block -> output node), input has no OpenSpec counterpart, so inferring one fabricates a node from the top-level `description` and risks round-trip drift; the `requires` DAG already shows fan-out/fan-in faithfully as edges.

**Size**: medium. Mirrors the custom-prompts feature (CRUD + localStorage + export/import + removable block + tests) plus the source-partitioning logic (namespaced ids, per-source merge, grouped display) and an "instantiate onto canvas" action. Additive, removable, low-risk - same family as custom prompts.
