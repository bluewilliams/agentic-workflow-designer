# Durable record index

Scan-then-open: read this index first, match an entry against the files or capability your change touches, then open only the matched record(s). One entry per record, grouped by a stable capability slug.

## code-search-mcp-option

- record: .workflow/make-sourcebot-option-general-and-called-code-search-mcp.md
- intent: generalize the single "Sourcebot" toggle into a tool-agnostic "Code search (MCP)" option (UI label, injected hint, exporters, docs)
- files: index.html (codeSearchHint + mcpCodeSearch toggle wiring + the four exporter injection sites + two inline hint blocks + SDK comment banner), tests.html, README.md, TECHNICAL.md
- status: current | date: 2026-06-13

## durable-record-protocol

- record: .workflow/compress-durable-record-at-finalize.md
- intent: finalize step compresses Verify/Gotchas into a clean spec (no per-agent transcript); surface area marked provisional until grounded
- files: index.html (genDurableRecordProtocol - finalize guidance + surface-area guidance), tests.html (Durable Record protocol-content tests)
- status: current | date: 2026-06-13

## repo-context-paths

- record: .workflow/repo-context-paths.md
- intent: two settings inputs (Rules/constitution paths + Product docs PRD/ADR) that inject repo-scoped binding-rules and product-goals guidance into generated prompts; flat lists, sticky, per-repo anti-contamination in the hint
- files: index.html (rulesPathsHint + productDocsHint + the two chip-list inputs + savePrefs/restorePrefs + sticky clearCanvas + five injection sites), tests.html, README.md, TECHNICAL.md
- status: current | date: 2026-06-13
