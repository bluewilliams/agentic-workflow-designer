# Timeline

Newest first. One line per change: date - capability-slug - one-line intent - record link. A recency lens over the same records the `_index.md` breadcrumb groups by capability; together they form the three-tier lookup (timeline -> index -> record). Never hand-pruned.

2026-06-23 - durable-record-protocol - documentation-only design overview of the durable-record system (four parts + three-tier lookup + six design decisions) added to TECHNICAL.md for a new maintainer - .workflow/write-a-design-overview-of-the-durable-record-system.md
2026-06-23 - consume-prior-records - teach the read-side grounding guidance (consumeRecordsHint + the genAgentSDK inline comment) the full three-tier lookup so it scans _timeline.md (recency) and _index.md (relevance), not index-only - .workflow/make-ground-in-prior-records-use-the-full-three-tier-lookup.md
