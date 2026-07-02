# Standardize the notes field's user-facing label on "Agent Context"

Branch: main. Status: current.

## Why and scope

The per-agent `config.notes` field was named inconsistently: the UI called it **"Agent Context"** everywhere (config panel, agent-editor form, help, the expand modal), but every generated prompt labeled it **"Additional context"**. So a user set "Agent Context" and then saw "Additional context" in the output - a real terminology mismatch. Standardized the output on "Agent Context" so the whole app uses one term.

## Key decisions

- **Standardize on "Agent Context" (title case), not "Additional context".** Rationale: it matches the UI field the user actually interacts with, and it pairs systematically with **"Workflow Context"** (the sidebar `planInput` field) - giving a clean two-tier mental model (Workflow Context = the whole run; Agent Context = this one agent). "Additional context" paired with nothing.
- **Do NOT rename the internal `config.notes` key.** It is invisible plumbing; renaming would ripple through serialize/deserialize, the `awd:meta` round-trip, the config data-key binding, every generator, and would break backward-compat with already-saved workflows that store `notes`. High churn, zero user value. Key stays `notes`; only the labels changed.
- **Presets correctly fill Agent Prompt, not Agent Context - left as-is.** Confirmed this is the right design: Agent Prompt = the role (preset-fillable with a curated template); Agent Context = the user's task-specific extras (rightly empty by default - a generic preset has nothing meaningful to put there, and dumping the role into Context would leave the prompt empty and duplicate via getEffectivePrompt's fallback). Only imported schemas fill Context, because a foreign artifact has BOTH an instruction and a description and we park the description there to avoid losing it.

## Changes

- index.html: all 7 generated-output labels swapped "Additional context"/"## Additional Context" -> "Agent Context" across Workflow, Sub-Agents (`## Agent Context`), Agent Teams, Agent SDK, Claude.ai (2 spots), and the OpenSpec export body. (Two `replace_all` passes.)
- README.md + TECHNICAL.md: reworded the descriptive "additional context" prose to "extra context"; fixed a now-stale TECHNICAL.md mapping line that documented `config.notes -> "Additional context"` (now -> the "Agent Context" section).
- Left untouched: one unrelated index.html line ("re-spawn ... with the reviewer's feedback as additional context") - that is correct English about decision-gate re-spawns, not the field.

## Verification

- 1189 -> 1190 (+1): a test asserting all 5 generators AND the OpenSpec export contain "Agent Context" and NOT "additional context".
- Full suite green through the change; NO test pinned the old "Additional context" string (grep-confirmed before editing), so nothing broke. Content-lint.

## Follow-on (same session): fixed the import<->export asymmetry for Agent Context

The rename surfaced a pre-existing asymmetry: EXPORT embeds `config.notes` into the artifact `instruction` as an "Agent Context:" block, but foreign IMPORT was pulling notes from the artifact's `description` (a semantic conflation - an OpenSpec `description` is artifact metadata, not agent context) AND leaving our own "Agent Context:" text buried in the prompt on a round-trip. Fixed the IMPORT side (`openSpecSchemaToWorkflow`):
- New `openSpecExtractAgentContext(instruction)`: pulls our "Agent Context:" block back into notes and strips it from the prompt (so a re-export does not duplicate it). Mirrors the export order (prompt -> Agent Context -> repo-context -> intent); notes end where the first trailing block begins. A genuinely foreign schema has no such block -> notes ''.
- STOPPED mapping a foreign `description` -> notes. `description` now only backfills the prompt when there is no instruction; it is never treated as Agent Context.
- Export is unchanged and provenance-independent: any node with notes gets the "Agent Context:" block in its instruction, so import -> add/edit Agent Context in the designer -> re-export bundles it with the instructions exactly like native (Blue's question). Our own normal round-trip stays lossless via `awd:meta`; this fixes the `awd:meta`-stripped case (e.g. `openspec schema fork`).
- +3 tests incl. a full export -> foreign-import -> re-export round-trip asserting Agent Context is extracted (not buried), not sourced from a foreign description, and bundled exactly once on re-export (no dup). 1190 -> 1193.

## Task checklist

- [x] Swap all 7 generated-output labels to "Agent Context" (comprehensive grep, both case variants)
- [x] Keep the internal `config.notes` key (no rename - compat + churn)
- [x] Fix stale docs (TECHNICAL mapping line) + reword descriptive prose
- [x] Lock it with a test across all 5 formats + OpenSpec; full suite green; content-lint
- [x] Confirmed presets-fill-Prompt-not-Context is correct and left unchanged
