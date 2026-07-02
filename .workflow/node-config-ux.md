# Node-config UX: selection scroll feedback + type-switch bake-trap fix

Branch: main. Status: current.

## Why and scope

Two node-configuration UX defects from the audit. (1) Selecting a node gave NO visible feedback: the config panel sits ~1600px below the sidebar fold (headless-measured panel top 2621px in a 1000px viewport, sidebar scrollTop 0), so every configure step began with manual hunting. (2) The type-switch bake trap: changing agent type bakes the template into `config.prompt` only when the box is empty, so a SECOND type change stranded the previous role's full template under a status line claiming "Edited from the {new role} template" - and generation ran the new type on the old role's text.

## Key decisions

- **Selection scroll**: `selectNode` scrolls the config panel into view (`scrollIntoView({block:'nearest'})`) ONLY on a genuine selection change to a node (never on re-selects or drag-start of the already-selected node - no scroll-jacking). Instant scroll, not smooth: smooth scrolling proved unreliable headless and the reliability matters more than the animation. Headless before/after: panel top 2621px/out of view -> 341px/in view on select.
- **Bake trap - pristine-swap rule**, generalizing the in-repo precedent the Writing Style handler already uses: on type change, an EMPTY box still bakes (unchanged); text that byte-matches (trim) ANY known role template - new `matchesAnyRoleTemplate()` covering all mapped templates, writer style variants, and every adversary-lens variant - is pristine and re-bakes to the new type's template; anything else is user work and is never touched.
- **Truthful status line for legacy saves**: workflows saved before this fix can still hold another role's baked text. `classifyAgentPrompt` gains a `foreign-template` state ("Unmodified template text from a different role (left over from an agent-type change). Reset to apply the {role} template.") and the Reset button now shows for it, giving a one-click recovery.

## Changes

- index.html: selectNode scroll (change-gated); matchesAnyRoleTemplate helper; agentType-change pristine-swap branch; classifyAgentPrompt foreign-template state; agentPromptStatusBlock message + Reset visibility.
- tests.html: bake-trap sequence test (general -> planner -> tester ends on the tester template, classified 'template'); customized text survives type changes; foreign-template classification + status block + Reset rendering.

## Verification

- 1225 -> 1228 (+3). Headless: scroll before/after measured; full app smoke (boot, add, connect, select, all five generators with memory + durable on) passes. Content-lint.

## Task checklist

- [x] Change-gated scrollIntoView with headless before/after evidence
- [x] matchesAnyRoleTemplate + pristine-swap on type change (Writing Style precedent)
- [x] foreign-template classify state + truthful copy + Reset affordance
- [x] Tests: re-bake, custom-survives, foreign-template; suite green
