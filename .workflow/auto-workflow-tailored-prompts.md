# Auto Workflow: tailored research prompts + writer-lens doc review

Branch: main. Status: current.

```awd:record
{"slug": "auto-workflow-tailored-prompts", "status": "current", "date": "2026-07-01", "files": ["index.html", "tests.html"], "verify": ["./run-tests.sh"], "superseded_by": null}
```

## Current behavior

The Auto Workflow research branch mirrors the Parallel Research preset: mode inference from the story, researchDocPrompt/researchPatternPrompt/researchSynthesizerPrompt with the preset's tool sets, and the fork carries researchMode so the mode editor works on auto-built workflows. The documentation tail attaches the writer-lens Skeptic loop. The analysis branch runs the bespoke analysisGatherer/analysisSynthesizer prompts (see analysis-branch-prompts). The four dead PROMPTS keys are deleted.

## Why and scope

The Auto Workflow builder's research and documentation paths produced measurably weaker prompts than the presets for the same intent. Research branch: 'Options Researcher' carried tools `Read/Grep/Glob/WebSearch` but the generic `PROMPTS.researcher` prompt, whose steps mandate seven LSP operations it did not have and never mention WebSearch; 'Tradeoff Analyzer' said nothing about tradeoffs; 'Synthesizer' got the technical-writer documentation template. Documentation path: 'Doc Reviewer' reviewed prose with the code-review checklist (`PROMPTS.reviewer`, "LSP findReferences on modified functions"). Meanwhile the tailored, mode-aware `research*Prompt` builders the Parallel Research preset uses sat unused, and four dead PROMPTS keys (`synthesizer`, `docResearcher`, `patternAnalyzer`, `codebaseExplorer`) lingered unreferenced.

## Key decisions

- **Research branch now truly mirrors the Parallel Research preset** (its comment already claimed to): same `inferResearchMode(story)` + `detectNamedOptions(story)` inference, `researchDocPrompt` for Options Researcher (tools Read/WebSearch/WebFetch), `researchPatternPrompt` for Tradeoff Analyzer (Read/Grep/Glob/LSP), `researchSynthesizerPrompt` for the Synthesizer (agentType planner, Read/Write, maxTurns 5 - all per the preset). The fork carries `researchMode`/`options`/`evaluationBias` so `applyResearchMode` (the mode editor) now works on auto-built research workflows too. 'Codebase Researcher' keeps `PROMPTS.researcher` with LSP tools (coherent as-is; verified).
- **Documentation tail mirrors the documentation preset**: single-writer case gets the full writer-lens Skeptic review loop (adversary node with `adversaryRole:'writer'` + `reviewLoopFor`/`reviewLoopKind`, "Docs accurate?" decision with `reviewLoopDecisionFor`, Passed/Needs revision edges). Multi-branch tails (a loop needs ONE reviewed node) fall back to the linear reviewer, now with `buildAdversaryPrompt('writer')` instead of the code-review checklist.
- **Behavior-pin test updated, not weakened**: "should omit decision gate for documentation workflows" pinned the old linear shape; replaced with a sharper assertion (exactly one decision, it is a review-loop gate labeled "Docs accurate?", the skeptic carries the writer lens) matching the preset's contract.
- **Analysis branch: minimal touch only.** Dropped the unmentioned `WebFetch` from Data Gatherer. Data Gatherer/Analyst keep `PROMPTS.researcher`: none of the tailored research prompts fits a measure/forecast task (they evaluate options), and inventing a bespoke analyst template was out of scope. Named follow-up: a dedicated analysis prompt pair.
- **Dead keys deleted** after confirming zero references in index.html and tests.html (one test iterated `codebaseExplorer` in a hardcoded-Atlassian regression list; removed from the list since the assertion is vacuous for a deleted template).

## Changes

- index.html: research branch (mode inference + three prompt/tool swaps + fork config), documentation tail (skeptic loop + fallback), Data Gatherer tools, four PROMPTS keys removed.
- tests.html: "Auto Workflow tailored research prompts" describe (prompt/tool coherence, fork researchMode, dead keys gone); doc-gate structural test rewritten; Atlassian-regression list updated.

## Verification

- 1219 -> 1221 (+3 new, -1 parametrized). Content-lint.

## Task checklist

- [x] Research branch mirrors preset (inference, builders, tools, fork mode config)
- [x] Documentation tail: writer-lens skeptic loop + fallback
- [x] Data Gatherer tool coherence (WebFetch dropped); analysis-prompt follow-up named
- [x] Dead PROMPTS keys deleted with reference check
- [x] Tests updated/added; suite green

## Update (same day): Data Gatherer WebFetch restored

Owner ruling reversed the drop: do not shrink a node's prior capability to satisfy prompt coherence - availability is a floor, and a granted-but-unmentioned tool is a milder flaw than a wrongly limited agent (also squares with Bash having been kept, which the researcher prompt equally never mentions). WebFetch is back in the Data Gatherer's default tools, and coherence is solved from the other side: a new Agent Context line licenses BOTH out-of-template tools ("use Bash for repo metrics... WebFetch for external reference data... when the analysis calls for them") without touching the shared PROMPTS.researcher template. The bespoke analysis-branch prompt remains the named follow-up; when it lands, the license moves into the prompt proper. +1 test (tools include WebFetch+Bash, notes license both). 1228 -> 1229.

- [x] WebFetch restored + Agent Context license line (no shared-template edit)
- [x] Test pinning tools + license; suite green; content-lint
