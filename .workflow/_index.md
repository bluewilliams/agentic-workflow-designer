# Durable record index

Scan-then-open: read this index first, match an entry against the files or capability your change touches, then open only the matched record(s). One entry per record, grouped by a stable capability slug.

## code-search-mcp-option

- record: .workflow/make-sourcebot-option-general-and-called-code-search-mcp.md
- intent: generalize the single "Sourcebot" toggle into a tool-agnostic "Code search (MCP)" option (UI label, injected hint, exporters, docs)
- files: index.html (codeSearchHint + mcpCodeSearch toggle wiring + the four exporter injection sites + two inline hint blocks + SDK comment banner), tests.html, README.md, TECHNICAL.md
- status: current | date: 2026-06-13
