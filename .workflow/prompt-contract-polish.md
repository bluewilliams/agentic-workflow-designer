# Prompt-contract polish: closing order, fallback dedup, code-search role widening

Branch: main. Status: current.

```awd:record
{"slug": "prompt-contract-polish", "status": "current", "date": "2026-07-01", "files": ["index.html", "tests.html"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

closingOrderNote() emits one ordering sentence when two or more end-of-response contracts stack (Handoff Summary, then DONE:/STATUS record lines, then the memory breadcrumb last). The unknown-agent-type fallback composes from PROMPTS.general's body with a label-seeded first line. CODE_SEARCH_STEP_ROLES spans 12 roles including reviewer/tester/adversary/verifier; DATADOG_STEP_ROLES stays deliberately narrow.

## Why and scope

Three small generated-prompt quality items from the designer audit, batched: (1) an agent with memory + durable record on receives up to four stacked "end your response with" contracts (role Handoff Summary / Output Format, DONE:/STATUS: record lines, memory breadcrumb) with no ordering guidance; (2) the unknown-agent-type smart fallback in getEffectivePrompt was a near-duplicate of `PROMPTS.general` (drift risk - one gets improved, the other silently does not); (3) `CODE_SEARCH_STEP_ROLES` excluded the review/critic roles even though the hint's own rationale (cross-repo seams, producer/consumer pairs, auditing claims) squarely fits them.

## Key decisions

- **`closingOrderNote()`** - one pure helper, emitted only when a second closing contract is active (durable record's DONE:/STATUS or the memory breadcrumb; a single contract stays unqualified). Order: Handoff Summary first, DONE:/STATUS next, breadcrumb as the very last line - consistent with the memory postamble's existing "end your response with the breadcrumb" (never contradicted). Injected in the sub-agent prompt, the teammate block, and the SDK instructions.
- **Fallback composed from the template**: the unknown-type fallback now returns `'Complete the task: {label[: notes]}.'` + `PROMPTS.general`'s body after its first line - single source, zero drift. Display-only for unknown types (classifyAgentPrompt template-compares mapped types only), so the dynamic first line cannot break pristine detection. Side effect: the fallback body gains the general template's slightly better step 1 wording.
- **CODE_SEARCH_STEP_ROLES += reviewer, tester, adversary, verifier** (8 -> 12). Writer stays out (docs work rarely spans repo seams). **DATADOG_STEP_ROLES deliberately unchanged**: plan-shaping telemetry belongs to the reasoning roles; implementers inherit it via the orchestrator's brief - reasoning recorded as a source comment. The C-series tests duplicating the role list as a literal were updated in lockstep; C4's out-of-scope probe moved from reviewer/tester (now in scope by design) to writer/unknown.

## Changes

- index.html: closingOrderNote + 3 injections; getEffectivePrompt fallback body from PROMPTS.general; CODE_SEARCH_STEP_ROLES widened with rationale comment.
- tests.html: "Closing-order note" describe (full stack, memory-only, none); fallback seed + body-sync test; C-series role list 8 -> 12 with C4 rewritten.

## Verification

- 1221 -> 1225 (+3 closing order, +1 fallback; C-series count unchanged). Content-lint.

## Task checklist

- [x] closingOrderNote helper + sub-agent/teammate/SDK injections, gated on 2+ contracts
- [x] Fallback derives from PROMPTS.general (label/notes seed kept)
- [x] Role-set widening + test-literal lockstep + DATADOG stays narrow (documented)
- [x] Tests for each; suite green
