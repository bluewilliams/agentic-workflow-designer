# OpenSpec foreign-schema import (view a schema NOT created here)

Branch: main. Status: current. Closes the deferred FOREIGN-schema import noted in openspec-schema-export-and-roundtrip.md.

## Why and scope

Until now, import only round-tripped OUR own exports: the schema.yaml carries the full workflow as a `# awd:meta` JSON comment, and `openSpecExtractMeta` rehydrates it losslessly. A schema authored anywhere else (by hand, by the openspec CLI, by a teammate) has no awd:meta, so import showed "foreign schemas not supported yet." This adds best-effort import of foreign OpenSpec schemas so they can be viewed and edited in the visual designer - turning the tool from a round-tripper for its own output into a general OpenSpec viewer/editor.

It is intentionally LOSSY: a plain schema carries no designer-only fields (node positions, agent type, model/tools/turns), so those default and are editable after import. The structure (steps + dependencies + apply) is preserved faithfully.

Non-goals: a full general-purpose YAML parser (scoped to the OpenSpec schema.yaml shape OpenSpec and our exporter emit); preserving artifact ids on a later re-export (re-export regenerates ids from labels via openSpecSlug - best-effort, accepted); importing the per-step template bodies as anything other than defaults.

## Requirements

- R1 - A dependency-free YAML-subset parser handles the OpenSpec schema shape: top-level scalars, the `artifacts` list of maps, the `apply` map, `requires` (inline `[]` or block list), block scalars (`|`/`>`) for `instruction`, and `#` comments; quoted (double/single) and plain scalars. [test: "parses the OpenSpec schema shape ..."]
- R2 - Map artifacts -> agent nodes (instruction, else description, becomes the prompt; agentType defaults to `general`), `requires` -> connections, `apply` -> an output node fed by its required artifacts (or the leaves if apply lists none). [test: "maps artifacts -> agent nodes, requires -> edges, apply -> output node"]
- R3 - Layered left-to-right layout by longest-path depth so the imported graph is immediately readable. [test: asserts a root is left of its dependent]
- R4 - Defensive on real-world/foreign input: a `requires` pointing at a missing artifact is dropped (no crash, no dangling edge); a cycle does not infinite-loop (depth has a cycle guard); non-schema YAML (no artifacts) returns null. [tests: "skips a requires reference to a missing artifact"; "returns null for YAML that is not an OpenSpec schema"]
- R5 - The produced object loads via the existing `deserializeWorkflow` (valid node types, correct shape). [test: "the parsed workflow loads cleanly via deserializeWorkflow"]
- R6 - Additive + removable; the only core touch is one guarded branch in `importWorkflowFile`. [verified: feature lives in a REMOVABLE block; importWorkflowFile calls it behind `typeof openSpecImportForeign === 'function'` and degrades to a clear message if removed]

## Approach and decisions

- Purpose-built parser, not general YAML: the schema shape is shallow and regular, so a scoped indentation parser (parseMap / parseList / readValue / readBlock / parseScalar) is more robust and far smaller than a general YAML lib, and keeps the single-file, dependency-free constraint. Documented as a subset.
- Inverse of `buildOpenSpecSchema`: artifacts -> agents, requires -> edges, apply -> output. Mapping apply to an output node (rather than another agent) mirrors how the exporter treats output nodes as the apply/deliverable phase, so a round-trip reads naturally.
- Lossy by design: defaults for the fields a plain schema cannot carry (agentType `general`, default model/tools/turns, computed positions). The import toast says so ("best-effort view; agent roles, models, and positions are defaults you can adjust") to set expectations.
- Pure core (`openSpecImportForeign` returns a deserializeWorkflow-shaped object, no DOM), so it is unit-testable; `importWorkflowFile` does the DOM load via the existing `deserializeWorkflow`.
- description preserved when distinct: if an artifact has both `instruction` and `description`, the instruction becomes the prompt and the description is kept in the node's Agent Context (notes) so nothing is lost.

## Surface area (file -> role)

- `index.html` REMOVABLE block `// === OpenSpec foreign-schema import ... REMOVABLE ===`: `openSpecParseYaml` (the subset parser), `openSpecSchemaToWorkflow` (schema -> canvas, layered layout, depth with cycle guard), `openSpecImportForeign` (pure orchestrator).
- `index.html` core touch: in `importWorkflowFile`, the `.ya?ml|md` branch now calls `openSpecImportForeign` behind a typeof guard, loads via `deserializeWorkflow`, and toasts node count + the lossy caveat (or a clear failure message).
- `tests.html`: `describe('OpenSpec foreign-schema import')` (6 tests) + `openSpecParseYaml` / `openSpecSchemaToWorkflow` / `openSpecImportForeign` bridged to win.

## Task checklist

- [x] YAML-subset parser (scalars, lists, maps, block scalars, comments, quoted/plain)
- [x] Schema -> workflow mapper (artifacts->agents, requires->edges, apply->output)
- [x] Layered layout by longest-path depth (with cycle guard)
- [x] Defensive: missing-requires dropped, non-schema -> null, no crash
- [x] Wire into importWorkflowFile behind a typeof guard (+ informative toasts)
- [x] Bridge + tests (6) incl. our-exporter-minus-awd:meta round-trip via the foreign path
- [x] CLI cross-check: ran openspec-CLI-generated schema.yaml through the importer headlessly
- [x] This record + backlog update + `_index` + `_timeline`

## Verify

`./run-tests.sh` -> 1149/1149 (was 1143; +6). CLI cross-check (the real proof it handles OpenSpec's OWN style, not just our hand-written sample): generated `openspec schema init my-foreign --artifacts proposal,specs,tasks`, then ran that exact schema.yaml through `openSpecImportForeign` headlessly -> name `my-foreign`, agents [Proposal, Specs, Tasks], one Apply output, 3 edges (proposal->specs->tasks->apply), `deserializeWorkflow` true, 4 live nodes, and the description-as-prompt fallback fired (these CLI artifacts have no `instruction`). Confirms plain unquoted scalars with commas, omitted instruction, block lists, and inline `[]` all parse. Tree clean, content-lint grep empty.

## Spec quality check (finalize)

- [x] Every requirement has a verifying test (or the stated headless CLI cross-check)
- [x] Scope bounded; non-goals stated (no general YAML, lossy, no id preservation on re-export)
- [x] No open clarifications
- [x] Verify section records real results (1149/1149 + CLI cross-check)
- [x] Additive + removable; one guarded core branch; degrades cleanly if the block is removed
- [x] Finalized for commit

## Gotchas

- Lossy on the way in: re-exporting an imported foreign schema will NOT reproduce its original artifact ids (ids regenerate from labels) or its templates - it round-trips structure, not byte-for-byte. Our own exports still round-trip losslessly via awd:meta (that path is unchanged and takes precedence).
- The parser is a SUBSET: exotic YAML (flow maps `{a: 1}`, anchors/aliases, multi-doc `---`) is not supported. OpenSpec's own output and our exporter do not use those. If a foreign schema fails to parse, the importer returns null and the toast says so rather than importing garbage.
- Block scalar folding (`>`) is treated like literal (`|`) - good enough for using instruction text as a prompt.

## Outcome

The designer can now import and visually edit OpenSpec schemas it did not create. Foreign schema.yaml -> a best-effort workflow (artifacts as agents, requires as edges, apply as output), with defaults for the designer-only fields a plain schema lacks. Dependency-free subset parser, pure mapper, one guarded core branch, 6 tests, validated against an openspec-CLI-generated schema. Our own lossless awd:meta round-trip is unchanged and still takes precedence.

## Built with (provenance)

Authored directly as the inverse of buildOpenSpecSchema. Verified via the headless suite (1149/1149) and a cross-check against a schema generated by the real openspec CLI (1.4.1).
