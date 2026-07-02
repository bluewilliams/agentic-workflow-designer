# Interleaved parallel siblings: emit the group once, drop nothing

Branch: main. Status: current.

## Why and scope

All five generators walked the topo-ordered agent list with the same pattern: on hitting a parallel-group member, emit the WHOLE sibling group, then `i += siblings.length`. That assumes siblings are contiguous in topo order. Wire fork -> (A, B) plus A -> C -> B and topo order interleaves (A, C, B): the group emitted at A, the blind `+= 2` advance consumed C's slot, then B (a group member) triggered the group AGAIN - A and B appeared twice and **C was silently dropped**. In the SDK output `gamma_config` was defined but `gamma.run()` never called; `validateWorkflow` said nothing. Silent omission of a step the user drew, in every format. Verified headlessly before the fix.

## Key decisions

- **Emitted-id set per generator, not a refactor.** Each of the five loops gains `const emittedPar = new Set()`, a skip at the top (`if (emittedPar.has(node.id)) { i++; continue; }`), and the parallel branch now marks all siblings emitted and advances by 1. The group still emits once, at its first-encountered member; non-siblings between group members emit normally in their own topo position. Container shapes untouched; for the contiguous (normal) case the emitted text is byte-identical - the whole existing suite passing unchanged is the proof.
- **The skip lives above stepNum++** in the formats that number steps, so skipped slots never consume a step number.
- **Semantics stay honest via a validator warning, not emission surgery**: when two children of one fork have a dependency path between them, `validateWorkflow` now warns they "cannot truly run simultaneously". The reachability walk excludes any decision's failure branch (the `noLabel`-labelled edge) - a revision path is not a dependency - which keeps manual revise loops (e.g. the test-automation preset's Revise edge back to its authoring fork) from producing false positives. Attached review loops are a subset of that rule.
- **SDK note**: with the fix, an interleaved B still receives `context=requirements` at task-creation time even though it depends on C; the warning is what tells the user the drawn structure is unsound. Restructuring emission to stage such groups is out of scope.

## Changes

- index.html: five emission loops (genWorkflow, genSubAgents, genAgentTeams, genAgentSDK, genClaudePrompt) converted to the emitted-set walk; `validateWorkflow` sibling-dependency warning with revise-edge-aware reachability.
- tests.html: "Interleaved parallel sibling emission (no duplicates, no drops)" describe - per-generator exactly-once assertions (group header count, each sibling count, the intermediate agent present, `await gamma.run(` exactly once in SDK), the validator warning fires on the interleaved case, and a clean contiguous fork yields no warning with unchanged emission.

## Verification

- Headless before/after on fork->(A,B) + A->C->B: Alpha/Beta blocks 2 -> 1 each, Gamma steps 0 -> 1, parallel group blocks deduplicated, SDK `gamma.run` 0 -> 1, validator [] -> sibling-dependency warning.
- Full suite green; the one mid-development failure (test-automation preset tripping the new warning through its manual revise loop) drove the revise-edge exclusion rather than a weakened assertion. Content-lint.

## Task checklist

- [x] Emitted-set walk in all five generators (byte-identical contiguous output)
- [x] Skip placed so step numbering is unaffected
- [x] validateWorkflow sibling-dependency warning (warn, not error)
- [x] Revise-edge-aware reachability (manual loops and attached loops excluded)
- [x] Tests: exactly-once per format, warning on/off cases; suite green; content-lint
