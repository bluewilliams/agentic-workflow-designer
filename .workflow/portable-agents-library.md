# Purpose-built portable agents (Agent Library)

Branch: main. Status: current (built via the dogfood workflow "Agent Library (portable agents)": Planner -> Implementer -> Tester -> Skeptic, memory + durable record + grounding on). Implements backlog #11.

## Why and scope

Let users save a configured agent node as a named, reusable, shareable agent and drop it into any workflow pre-wired (e.g. a "WebAPI-endpoints agent" that knows the org's conventions). The agent-node analog of the custom-prompts library. Orthogonal to OpenSpec - a portable agent just yields a richer artifact instruction on export.

Non-goals: a new node type (a preset instantiates a normal agent node); server sync; per-source UI beyond grouping; capturing rules/product-doc paths in v1 (config only - can extend later); semver ranges / changelogs / update notifications.

## Requirements

- R1 - A portable agent is a saved snapshot of an agent node's config (agentType, model, tools, prompt, notes, maxTurns). Instantiating one adds a normal agent node with that config. MUST NOT add a new node type. [scenario: instantiate -> a node of type 'agent' with the saved config appears]
- R2 - CRUD in localStorage (`awd_custom_agents`): save the selected agent node as a preset, edit, delete. [scenarios: save-from-selected; edit updates in place; delete removes]
- R3 - Source partitioning: each agent carries `source` (user|org|builtin) + optional `pack`; the id is NAMESPACED by source (`user:<slug>`, `org:<pack>/<slug>`). Display grouped by source.
- R4 - Non-clobbering, version-aware merge: importing a pack only affects its declared source; a namespaced id makes cross-source collision impossible (a user agent can NEVER be overwritten by an org import). Within a source + id: incoming version > local updates; equal or lower is skipped (no-op). [scenarios: import org pack leaves user agents untouched; re-import same version = no change; higher version updates; an org pack declaring a `user:` id is re-namespaced to org]
- R5 - Optional author-controlled `version` (string) + auto `updated` ISO timestamp. [scenario: saving stamps updated; version is whatever the author set]
- R6 - Export/import JSON packs (`{format:'awd-agent-pack', version:1, source, agents:[...]}`); "Export mine" exports the user source. [scenario: export then import round-trips]
- R7 - Additive + removable; inert until used (no saved agents -> only a toolbar + hint, zero behavior change elsewhere). The only core seam is one guarded call in renderPromptLib. [scenario: with no agents, prompt library renders identically apart from the Agents section]

## Approach and decisions

- Mirror the custom-prompts feature exactly (localStorage + CRUD + export/import + a REMOVABLE block + a form overlay), so the code is familiar and low-risk.
- **Namespaced ids give non-clobber for free**: `source:slug` (org adds `pack/`). Cross-source ids can never collide, so a user agent is structurally safe from an org import. On import, the id's source prefix is FORCED to match the resolved source (an incoming `user:`-prefixed id in an org pack is re-derived), closing the one spoofing hole.
- **Version-aware merge**: `compareAgentVersions` (dotted-number compare); incoming > existing updates, else skip. Equal = idempotent re-import.
- UI (revised 2026-06-30): the Agent Library is its OWN toolbar button + modal (`#agentLibOverlay`, `toggleAgentLib`/`renderAgentLib`), NOT nested in the Prompt Library. Rationale: nesting produced two near-identical toolbars stacked (two "Export mine" buttons adjacent) and conflated copy-paste prompts with instantiable node configs. Considered a single "Library" button with Prompts|Agents tabs; chose a separate button for the cleanest separation at the cost of one small toolbar button. The modal has the toolbar (Save selected agent / Export mine / Import pack) + cards grouped by source (Add to canvas / Edit / Delete; edit+delete only for user source).
- Save-from-node: snapshot the selected agent node's config; the form sets name + version (+ editable prompt/notes); instantiate uses `addNode('agent', ...config)`.

## Surface area (file -> role)

- index.html REMOVABLE block `// === Custom agents (portable agent presets / Agent Library) - REMOVABLE ===`: getCustomAgents/saveCustomAgents, newAgentId, compareAgentVersions, normalizeAgentConfig, saveSelectedAgentPreset, openAgentForm/closeAgentForm/saveAgentForm, deleteCustomAgent, instantiateAgent, exportAgentPack, mergeImportedAgents, importAgentPackFile, toggleAgentLib/renderAgentLib/rerenderAgentLib/renderAgentLibrary/agentCardHtml. Plus the toolbar "Agents" button, the `#agentLibOverlay` modal, and the `#customAgentOverlay` form markup. NO hook in renderPromptLib (own modal). Help modal + README each have an "Agent Library" section.
- tests.html: "Custom Agents (Agent Library)" describe (10 tests, incl. own-modal render + not-in-prompt-lib) + bridge.

## Task checklist

- [x] Data layer: getCustomAgents/saveCustomAgents/newAgentId (namespaced)/compareAgentVersions/normalizeAgentConfig
- [x] saveSelectedAgentPreset + form (open/close/save) + deleteCustomAgent
- [x] instantiateAgent (adds an agent node)
- [x] exportAgentPack + mergeImportedAgents (source-partitioned, version-aware, non-clobber, id re-namespacing) + importAgentPackFile
- [x] renderAgentLibrary/agentCardHtml + guarded hook in renderPromptLib + #customAgentOverlay markup
- [x] Tests (CRUD, non-clobber merge, version-aware update, namespaced dedup + re-namespacing, instantiate, inert-until-used, render-hook) + bridge
- [x] Verify (run suite) + headless smoke
- [x] Finalize record + index/timeline

## Spec quality check (finalize)

- [x] Every requirement is testable and has a verifying test
- [x] Scope bounded; non-goals stated
- [x] No open clarifications (defaults locked: per-source packs; extend Prompt Library UI; config-only v1)
- [x] Verify section records real results (1163/1163 + headless screenshot)
- [x] Additive + removable; inert until used; the only core seam is one guarded renderPromptLib call
- [x] Finalized for commit

## Follow-ups (post-build, 2026-06-30)

- Moved the Agent Library to its OWN toolbar button + modal (see Approach UI note) - was nested in the Prompt Library.
- Added a **search box** (mirrors the Prompt Library): `filterAgentLib` hides non-matching cards and any source group with no match; `rerenderAgentLib` preserves the query; groups wrapped in `.agent-group`. Search renders only when agents exist. +1 test. (Custom user-defined groupings were considered and DECLINED as premature - source grouping suffices at expected sizes; a lightweight optional "group" field is the parked middle-path if libraries grow.)
- Help modal + README each gained an "Agent Library" section.
- **Full-config form (2026-06-30):** the save/edit form now exposes the COMPLETE agent config - Agent Type (select), Model (select), Max Turns (number), Tools (toggle chips), in addition to Name/Version/Prompt/Context - mirroring the node config panel. Previously type/model/tools/maxTurns were snapshotted-from-node but not editable, so a preset's model/tools were locked after creation and you could not author one from scratch. openAgentForm populates the controls from the config; saveAgentForm reads them all (Object.assign over baseConfig so unknown fields like writingStyle survive). +1 test (form round-trip of the full config). New `.ca-label`/`.ca-input` CSS; the form modal scrolls (max-height 86vh).

- **Agent Type now functions in the form (2026-06-30):** added `applyAgentTypeChange(config, newType, currentPromptText, label)` - a NODE-INDEPENDENT helper that mirrors the node panel's behavior: for 'writer' set a default writingStyle + swap tools to that style's defaults; if the prompt is blank, fill it from the role template (`getEffectivePrompt`, which reads only config+label, so a synthetic `{config,label}` is safe). The form's Agent Type `<select>` calls `onAgentFormTypeChange()` on change (operates on live form state; never overwrites a typed prompt). Shared form helper `renderAgentFormTools`. **Deliberately did NOT refactor the node panel onto the helper** - it is committed working core used on every config edit, and the equivalence has one non-occurring edge (promptEl null), so per "no regressions" I left the node panel's inline logic untouched. The genuinely-shared logic (WRITER_TOOL_DEFAULTS, getEffectivePrompt) was already centralized; the helper centralizes the glue for the form and is node-panel-compatible for a future safe refactor. +3 tests. Honest residual: the form uses native `<select>`s while the node panel uses a styled custom-dropdown widget (visual diff), and the form has no Writing Style field (writingStyle is preserved via baseConfig + set on writer-type change, but not directly editable in the form) - both deferred.

- **Favorite -> Add Nodes palette (2026-06-30):** a star/pin on each agent card adds it to a "Custom Agents" group in the Add Nodes palette as a one-click add button (-> `instantiateAgent`). Favorites are a SEPARATE user-owned id list (`awd_agent_favs`), NOT a flag on the agent - so favoriting an ORG agent survives a pack re-import (tested). The palette section hides entirely when nothing is favorited; it resolves favorites against the current library (a deleted agent drops out, and `deleteCustomAgent` prunes the fav). `renderAgentPalette` is a guarded hook called at init + after fav toggle / save / import / delete; the existing node-type buttons + Quick Patterns + Presets are untouched. Mirrors the Prompt Library's favorites pattern (separate list). +4 tests. Bounded on purpose: pin/unpin only - no drag-reorder, folders, or recently-used. Palette items truncate long agent names with an ellipsis (`.agent-name` overflow + `min-width:0` on `.palette-item` so the grid track stays 1fr) to keep the 2-up grid aligned like the node buttons; full name on hover via title.

## Verify

`./run-tests.sh` -> 1172/1172 (was 1153; +19: own-modal render, agent search, full-config form round-trip, applyAgentTypeChange blank-fill/preserve + writer tools, form type-change parity, favorites-as-separate-list, palette renders-favorites-only/hidden-when-empty, delete-prunes-fav, card pin toggle, + the original logic suite). Tests cover: namespaced ids (cross-source collision impossible), version compare, inert-until-used (no agents -> toolbar + hint, no cards), org import never clobbers user agents, a spoofed `user:` id in an org pack is re-namespaced to org (user agent untouched), version-aware merge (higher updates / equal-or-lower no-op), instantiate adds a normal 'agent' node with the saved config, export/import round-trip, non-pack data -> null, and the renderPromptLib hook injects the section. Headless screenshot confirmed the UI: an "Agent Library" section in the Prompt Library with My Agents (version badges + Add/Edit/Delete) and Org: <pack> (Add only - no Edit/Delete), prompt categories below unchanged.

## Outcome

The Prompt Library now has an Agent Library: save a configured agent node as a named, versioned, shareable preset and drop it into any workflow pre-wired. Source-partitioned (user/org/builtin) with namespaced ids so an org import can never overwrite the user's own agents; merge is version-aware (higher updates, equal/lower no-op). Mirrors the custom-prompts feature; one guarded seam in renderPromptLib; inert until used. Built end-to-end via the dogfood workflow (Planner -> Implementer -> Tester -> Skeptic) - see the dogfood findings appended below.

## Dogfood findings (Planner -> Implementer -> Tester -> Skeptic, run warm by the author)

What the workflow STRUCTURE added (it did help):
- The mandated **kickoff durable record** forced the requirements + non-goals + the namespaced-id / version-aware-merge decisions to be written BEFORE coding - which made the build a transcription of a plan rather than discovery mid-edit.
- The **Skeptic step** earned its keep: it surfaced that the unit tests did not exercise the renderPromptLib injection hook (only the logic), which added the render-integration test (+1) and the headless screenshot. A freeball build would likely have shipped without that UI-integration coverage.
- **Ground-in-prior-records** mattered: reading backlog #11 + the custom-prompts record up front meant the design decisions (source partitioning, version) were already settled, so no re-litigation.

Where it added ceremony (honest):
- The **live record-maintenance beat** (create-at-kickoff, KEEP-CURRENT-after-every-step) is awkward when ONE agent plays all roles in sequence - I batched the Verify/Outcome at finalize rather than ticking after each role, because the steps were not real handoffs. The structure assumes multi-agent handoffs; single-session collapses that. The record is accurate, just not maintained tick-by-tick.
- For a feature the author already understood deeply, the Planner/Tester role separation was lighter-weight value than the Skeptic - the real signal is that the **review loop** (Skeptic) is the highest-value beat, more than the role sequence itself.

Net: the structure produced a more complete, better-documented, better-tested result than a freeball build would have - chiefly via the kickoff spec and the adversarial review. The per-step record cadence is the part that fits multi-agent runs better than a single warm session.

## Built with (provenance)

Workflow: "Agent Library (portable agents)" - Planner -> Implementer -> Tester -> Skeptic (linear, no decision/loop node; Skeptic verdict honored in-session). Toggles: memory + durable record + ground-in-prior-records ON. Run warm by the author (the workflow's exported single-session prompt was followed as the build plan). Verified via the headless suite (1163/1163) + a UI screenshot.
