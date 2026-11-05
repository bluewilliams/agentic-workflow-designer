# Agent API facade (`window.awd`) and WebMCP registration

Context: no work item (director direction, 2026-11-04). Branch: main (uncommitted delivery for the director). Status: finalized, committable (left uncommitted for the director). Workflow: webmcp-and-mcp-facade.

```awd:record
{"slug": "webmcp-and-mcp-facade", "status": "current", "date": "2026-11-04", "files": ["index.html (facade block: window.awd, _awdStep, _awdRollback, _awdMove with the reassigned global undo and redo, _awdMethod, _awdInvoke, _awdConfig, _awdCaptureSidebar, _awdApplySidebar, _awdSummary, the catalog, awdRegisterWebMCP, _awdModelContext; one boot call at the end of INIT; one help modal paragraph)", "tests.html (describe: Agent API facade (window.awd); describe: Eval: agent API facade and WebMCP registration (pre-registered eval))", "README.md (section: Agent API facade (window.awd))"], "verify": ["./run-tests.sh", "./run-tests.sh --verbose"], "superseded_by": null}
```

[Current behavior](#current-behavior) · [Why and scope](#why-and-scope) · [Requirements](#requirements) · [Success criteria](#success-criteria) · [Approach and decisions](#approach-and-decisions) · [Surface area](#surface-area-file---role) · [Task checklist](#task-checklist) · [Verify](#verify) · [Risks](#risks--trade-offs) · [Gotchas](#gotchas--non-obvious) · [Found bugs](#found-bugs) · [Pre-registered eval](#pre-registered-eval) · [Verification ledger](#verification-ledger) · [History](#history) · [Outcome](#outcome) · [Built with](#built-with-provenance) · [Links](#links)

## Current behavior

The page exposes one documented, versioned agent surface, `window.awd` (`version` "1"), with 28 methods: 8 reads that return plain JSON copies (`listPresets`, `getWorkflow`, `listNodes`, `listConnections`, `generate`, `explain`, `validate`, `describe`) and 20 calls that change the canvas or the sidebar through the app's own entry points (`newWorkflow`, `loadPreset`, `setWorkflow`, `addNode`, `updateNode`, `deleteNode`, `connect`, `disconnect`, `addEval`, `removeEval`, `attachVerifier`, `attachSkeptic`, `detachLoop`, `setRequirements`, `setContext`, `setName`, `setOptions`, `undo`, `redo`, `batch`). Every mutating call is exactly one undo step that also carries the sidebar values it changed, and the app's own undo and redo (toolbar buttons, keyboard shortcuts, `awd.undo()`, `awd.redo()`) restore that step in full; a step the UI pushed moves the canvas only, as before. A call that changes nothing takes no step, a call that throws leaves nothing applied, and `batch(ops)` is one step that rolls back whole when an entry fails. Errors are `Error` instances whose message is `awd: <method>: <text that names the bad value>`. At boot, `awdRegisterWebMCP(context)` registers every catalog entry as a WebMCP tool on `document.modelContext` (else `navigator.modelContext`) through `registerTool`, or through `provideContext` when that is all the context offers, and does nothing when no context exists. `generate(format)` returns the Copy text of any of the five formats without a change to the shown format or to any state. With no facade call made, every preset generates the same text as before in all five formats.

## Why and scope

Agents that drive the designer need one documented, versioned surface to build and read workflows. Internal function names drift and nothing pins their behavior. The facade `window.awd` (version "1") wraps the app's own entry points and registers the same catalog as WebMCP tools when the browser offers WebMCP.

Non-goals: no MCP server process; no change to how prompts are generated; no change to the one-click placement rules; no new node types; no persistence of facade calls beyond what the app already autosaves; no new sidebar control or menu item.

## Requirements

The director's text, verbatim (supplied in full 2026-11-04 after a clipped paste). The tests that verify each requirement are listed under Verifying tests below.

1. A global object `window.awd` exists after boot with a string `version` equal to "1". Its shape is a contract: any later change that removes or renames a method, or changes a return shape, moves the version.

2. Read methods return plain JSON (no DOM nodes, no functions, no live state references; mutating a returned object never changes the canvas):
   - `listPresets()` returns the presets the sidebar offers, each `{ id, name, description }`, in sidebar order.
   - `getWorkflow()` returns the same object `serializeWorkflow()` returns.
   - `listNodes()` returns `[{ id, type, label, x, y, config }]` for every node; `listConnections()` returns `[{ id, from, to, label, fromPort }]`.
   - `generate(format)` returns the generated text for that format exactly as the Copy button would ship it for that format (byte-identical to `_rawPrompt` after selecting that format), for any of the five format ids: prompt, subagent, teams, sdk, claude. It MUST NOT change which format the UI shows, and it MUST NOT change any state. With no nodes it returns an empty string.
   - `explain(format)` returns the Explain rows for that format as `[{ part, status, reason, snippet }]`.
   - `validate()` returns the Review warnings as `[{ type, msg }]` (an empty array when the Review is clean).
   - `describe()` returns the tool catalog: one entry per method with `name`, `description`, and a JSON Schema `inputSchema` (the same catalog WebMCP registration uses).

3. Mutating methods change the canvas or the sidebar through the app's own entry points, re-render, and return the resulting state (a node summary, a connection summary, or the workflow summary `{ name, slug, preset, nodes, connections, warnings }`):
   - `newWorkflow()` clears the canvas without a confirm dialog.
   - `loadPreset(id)` loads a preset by id without a confirm dialog; an unknown id throws.
   - `setWorkflow(json)` restores a workflow object of the shape `getWorkflow()` returns; an object that `deserializeWorkflow` rejects throws, and the canvas is unchanged.
   - `addNode({ type, label, x, y, config })` adds a node. `type` must be a key of NODE_DEFAULTS; for an agent, `config.agentType` must be an id in AGENT_TYPES and `config.model` (when given) a value in MODELS; unknown values throw. Omitted config keys take the node type's defaults. Omitted x and y place the node to the right of the rightmost node on the canvas. Returns the node summary with its new id.
   - `updateNode(id, { label, config })` merges the patch into the node with the same validation as addNode; unknown id throws.
   - `deleteNode(id)` removes the node and its edges; unknown id throws.
   - `connect(from, to, label)` adds an edge (returns the existing edge when one already exists from `from` to `to`); unknown ids or from equal to to throw.
   - `disconnect(from, to)` removes that edge; no such edge throws.
   - `addEval()` adds the pre-registered eval on the Input that anchors the run (an Input with edges, else the only Input); it throws when there is no Input or an Eval Author already exists. `removeEval()` removes it.
   - `attachVerifier(nodeId)` attaches a Verifier loop with the app's route-back rule and returns `{ verifier, gate, routeBack }` as node summaries; `attachSkeptic(nodeId)` attaches a Skeptic loop; `detachLoop(nodeId)` removes the loop on that step. A node that cannot take a loop, or already has one, throws.
   - `setRequirements(text)`, `setContext(text)`, `setName(text)` set the Requirements box, the Workflow Context box, and the workflow name through the same path typing would take (the field's input handlers run, so validation, the prompt, and autosave update).
   - `setOptions({ ... })` sets any of: exportFormat, memoryEnabled, durableRecord, consumeRecords, approvePlan, clarifyFirst, defaultModel, effort, verifyPaths, verifyNotes. Each goes through the sidebar's own handler so the control and the state agree. Unknown keys and invalid values throw, and no key is applied when any key is invalid.
   - `undo()` and `redo()` call the app's undo and redo.

4. Every mutating facade call is exactly one undo step: after any single call, one `undo()` restores the nodes, connections, and generated prompt to what they were before the call, and `redo()` restores the result. A call that changes nothing (connect on an existing edge) consumes no undo step.

5. `batch(ops)` runs an array of `{ tool, input }` entries in order as ONE undo step and returns an array of results. When an entry throws, the batch stops, nothing from the batch remains applied (one undo restores the pre-batch state), and the error names the failing index and tool.

6. Errors from the facade are `Error` instances whose message starts with "awd:" and names the method and the bad value, so an agent can repair its call.

7. WebMCP registration: at boot, when `document.modelContext` (or, as a fallback, `navigator.modelContext`) exists and offers `registerTool`, every entry of `describe()` is registered as a tool whose `execute(input)` calls the facade method and returns `{ content: [{ type: "text", text }] }` with the JSON result as text (an error returns the same shape with `isError: true` and the message). When the context offers only `provideContext`, the same tools are provided through it. When neither exists, nothing is registered and nothing is logged as an error. The registration function takes the context object as a parameter so a test can pass a fake.

8. Existing behavior is untouched: for every preset, with no facade call made, all five generated formats are byte-identical to today's output, and the Review, Explain, undo, and autosave behave as before. No new sidebar control, no new menu item, no change to any generated prompt text.

9. Tests cover: the version and the catalog, every read method's shape, generate() equality with the Copy path for all five formats without changing the UI's format, every mutating method's result and its one-undo-step property, the no-op-consumes-no-step rule, batch atomicity on failure, error messages, WebMCP registration through a fake context for registerTool and for provideContext, the no-context case, and the byte-identity of the five formats for every preset.

10. Documentation: README gains a section that names the facade, its version, the method list in one table, the one-undo-step rule, the error convention, and what WebMCP registration does and does not reach (an agent inside a browser that offers WebMCP; an agent outside the browser reaches the facade through browser automation or through the workflow JSON that Import accepts). The help modal gains one short paragraph pointing at it.

Constraints: single-file app, no new files; follow CLAUDE.md (content lint, no em or en dashes, new test titles start with "should", const or let bindings used by tests need a line in the tests.html exposure block, apostrophes escaped inside single-quoted strings). The facade block is self-contained and removable: one block of code plus one boot call. Tool selections remain suggestions; the facade never forbids a tool.

### Clarifications

- C1 (2026-11-04): the first paste lost text in the middle of some lines. Resolved: the director supplied the full text above.
- C2 (2026-11-04): reach of requirement 4. Resolved: an undo step from a facade call also restores the sidebar fields the prompt depends on (name, requirements, context, options); undo steps from the UI are unchanged. See Approach and decisions.

### Verifying tests

Eval ids are tests of the describe "Eval: agent API facade and WebMCP registration (pre-registered eval)"; quoted titles are tests of the describe "Agent API facade (window.awd)". Both are in `tests.html`.

- Requirement 1: E1; "should expose the facade version "1" as a string".
- Requirement 2: E2 to E10; "should return plain JSON copies from each read method, empty on an empty canvas"; "should generate each format equal to the Copy text without moving the format tab, and throw on an unknown format"; "should list 28 unique catalog entries whose names are the facade methods and whose input schemas are objects"; "should return getWorkflow equal to serializeWorkflow and validate rows equal to the Review warnings as { type, msg }".
- Requirement 3: E11 to E38, E65; "should return a node summary, a connection summary, a loop result, or the workflow summary from each mutator and an array from batch"; "should keep no reference to the caller objects passed to updateNode and addNode"; "should merge an agentType change into the config and keep the prompt, the tools, and the model of the node"; "should place a node with only x given level with the rightmost node, with only y given right of it, and keep a zero coordinate"; "should throw and change nothing when disconnect names an existing edge in the reverse direction".
- Requirement 4 and clarification C2: E39 to E45, E60; "should restore the canvas and the sidebar with one undo after each mutator and the result with one redo"; "should restore a facade step through the toolbar buttons and the keyboard, and leave the sidebar alone on a step the UI pushed"; "should restore the memory and record switches of a facade step through the toolbar and the keyboard"; "should match every state on the way when three undos and three redos cross facade and UI steps"; "should take no undo step for a call that changes nothing, and keep the redo stack"; "should take no undo step and keep the redo stack when setOptions sets every option to its current value"; "should roll back a single call that throws after it changed state and leave both undo stacks as they were".
- Requirement 5: E46 to E48; "should leave nothing applied and no undo step when a batch entry throws first, in the middle, or last"; "should restore the pre-batch state and both stacks when a batch entry is a setWorkflow that throws after it changed state"; "should reject a batch entry that names batch, undo, or redo before any entry applies, naming the index and the tool".
- Requirement 6: E49; "should throw awd: errors that name the method and the bad value, and change nothing".
- Requirement 7: E50 to E57; "should register every entry through a fake registerTool and run a tool, with isError on a failure"; "should provide every entry through a fake provideContext in one call"; "should register nothing and log no error without a model context, and warn when a context fails"; "should warn and leave no unhandled rejection or console error when registerTool or provideContext returns a rejected promise"; "should hand every other catalog entry to registerTool when it throws for one tool, and report it through console.warn only".
- Requirement 8: guards E58 to E63, E64, E66; "should leave the five formats of every preset byte-identical after every read method runs"; the strays-never-run eval test for byte-identical output of every preset (unchanged).
- Requirement 9: E69 (manual read, 13 topics each with a named passing test), E70.
- Requirement 10: E67, E68.
- Constraints: E70 to E74. Tool selections stay suggestions: E65; "should keep the config prototype and the validated agentType when an updateNode patch carries an own __proto__ key".


## Success criteria

- An agent builds a complete workflow and reads the generated prompt with documented `window.awd` calls only.
- One undo after any facade call restores the state before the call.
- A failed batch leaves no trace.
- Every preset generates the same text as before in all five formats when no facade call is made.
- A browser that offers WebMCP lists one tool per facade method; a browser that does not shows no error.

## Spec quality check

- [x] Each requirement is testable and unambiguous (all ten map to the 74 frozen criteria)
- [x] Scope is bounded (Non-goals stated)
- [x] No open clarifications remain (C1 and C2 resolved; the Eval Author raised no question)
- [x] Every scenario names a verifying test (see Verifying tests)
- [x] The success criteria are measurable
- [x] Independent verification ran (see Verification ledger)

## Approach and decisions

- Shape: one contiguous removable block in `index.html` directly before the INIT section, plus one boot call, `awdRegisterWebMCP(_awdModelContext());`, as the last INIT statement. Helpers are `_awd`-prefixed function declarations, so the tests need no exposure line. The registration function is a global, not a method of `window.awd`, because `describe()` lists one entry per method (chose a global over `awd.registerWebMCP`). No app function outside the block is edited; the diff to `index.html` is three hunks, additions only.
- Clarify C2 (director, before the eval was frozen): how far does undo reach for `setRequirements`, `setContext`, `setName`, `setOptions`, `newWorkflow`, and `setWorkflow`? Answer: facade steps restore the sidebar, and the facade hooks the app's undo and redo. Rejected: canvas-only undo (requirement 4 would be false for six methods), and a sidebar-carrying snapshot for every user (changes Cmd+Z in the UI, which conflicts with requirement 8).
- One step per call: `_awdStep(fn)` sets `_undoBatch` so the app's own `pushUndo` calls inside the call do nothing, compares a canvas plus sidebar signature before and after, and pushes ONE canvas snapshot through `pushUndo(snap)` that carries `awdSide`, the before-values of only the sidebar keys the call changed. No change pushes nothing. A nested step (a batch entry) pushes nothing; the outermost step pushes. The wrapper restores `_undoBatch` in finally, which also repairs the app's `loadPreset`, which sets it to false unconditionally.
- Undo hook: the block keeps the originals as `_awdAppUndo` and `_awdAppRedo` and points the global `undo` and `redo` at one hook, `_awdMove`. A stack-top entry without `awdSide` calls the original only (every UI step, so UI behavior is unchanged). An entry with `awdSide` captures the current values of those keys, calls the original, tags the new top of the opposite stack, and applies the sidebar. `awd.undo()` and `awd.redo()` call the global names. The toolbar buttons and the key handler resolve the names at call time, so deleting the block restores the originals with no third edit site. Rejected: restore only inside `awd.undo()` and `awd.redo()` (the first plan; the Skeptic blocked it: the toolbar and Ctrl+Z dropped the carried values, so a sidebar-only step became a dead keystroke and a facade `loadPreset`, `newWorkflow`, or `setWorkflow` step left the old canvas with the new sidebar).
- Carried sidebar keys: wider than name, requirements, context, and the ten options, because `newWorkflow` and `setWorkflow` reset more values the prompt reads (repositories, app source fields, MCP switches, rules and product doc paths, default delivery, eval home, active preset, the OpenSpec switch and artifact path, the verify posture). The restore goes through the same appliers `setOptions` uses, so control and state agree. Rejected: restore through `deserializeWorkflow` or `applyWorkflowContext` (their never-wipe rule skips empty values, so a restore to an empty list fails; from saved-workflow-context).
- Rollback: a throw that left a change pushes the before snapshot straight onto `_undoStack` (not through `pushUndo`, which clears redo), calls the original undo, and pops the redo entry, so both stacks end as they were. A failed batch leaves no undo step.
- Methods: validate everything before the first mutation. `generate` swaps `state.exportFormat` around `getActivePromptText()` and restores it in finally (not `setExportFormat`, which renders and saves prefs). `explain` projects `explainWorkflow` (from explain-workflow). `loadPreset` validates the id first, because the app clears the canvas before it looks the id up. `setWorkflow` runs `deserializeWorkflow` in own-file mode on a clone. `updateNode` merges with object spread like the app's `addNode` (a `__proto__` key in a patch stays an ordinary key) and does not swap templates on an agentType change. `addEval` treats "an Input with edges" as incoming or outgoing edges. `attachSkeptic` returns `{ skeptic, gate }`. `generate` and `explain` throw on an unknown format; `removeEval` with no Eval Author and `detachLoop` with no loop throw. The setters dispatch the field's input event and then refresh the prompt, because typing in the Requirements and Workflow Context boxes does not refresh `_rawPrompt`. `setOptions` rejects a `verifyPaths` entry that is not a string, is empty after a trim, or repeats an earlier entry, and stores entries trimmed. The summary carries counts for nodes and connections and the `{ type, msg }` list for warnings; a missing field becomes `null` so every key is present.
- Errors: every method is built through `_awdMethod(name, fn)`, which rewraps an error that does not start with "awd:" as `awd: <method>: <message>` and keeps the original as `cause` (chose a rewrap over a shape pre-check, because one rewrap covers every input the app does not check). Batch errors read `awd: batch: entry <i> (<tool>) failed: <inner message>` with a zero-based index, for the pre-check and the run. `batch` rejects batch, undo, and redo as entries; reads are allowed.
- WebMCP: `registerTool` first, `provideContext` (one call with `{ tools }`) as the fallback. Each `registerTool` call has its own try, so one refused tool reports through `console.warn` and the others still register; a rejected promise from either call also goes to `console.warn`, never `console.error`. The tool text is always `JSON.stringify` of the result; a tool input of `null` is treated as `{}`.
- Eval Author decisions (no question raised; each sits in one criterion line): the Copy text must be fresh after the three setters (E35); a failed batch leaves the state equal to the state before the batch right after the throw (E47); the summary `preset` is the preset id (E12); read shapes are exact key sets; a throw carries the "awd:" prefix and leaves the state unchanged; facade `loadPreset` undo restores the memory option the app's `loadPreset` switches on (E40); a tool name outside `ALL_TOOLS` is accepted (E65); `verifyPaths` is replaced, not appended, and a boolean option takes a boolean only (E36, E37).
- Design fact, by the requirement: `setWorkflow` restores in own-file mode, so an agent's JSON can change the App Source Access grant and the run switches, which File Import of a foreign file refuses.
- Independent checks: a Skeptic reviewed the plan (one High finding, the undo hook above, fixed in one revise cycle; every other load-bearing claim verified against the code). A Reviewer approved the code at the first cycle with no Critical or High finding and confirmed that no app function outside the block changed; four of its Low notes were applied in a declared polish pass (the spread merge, the per-tool try, a removed unreachable branch, one sharper assertion). A Tester added 15 edge tests and proved 9 load-bearing contracts by mutation. A Verifier executed all 74 frozen criteria and drove the real app in a browser (see Verification ledger).

## Surface area (file -> role)

Verified against the code by the Planner and confirmed from the diff by the Reviewer and the Verifier (three hunks in `index.html`, additions only).

- `index.html`: the facade block (`window.awd`, `_awdStep`, `_awdRollback`, `_awdMove` with the reassigned global `undo` and `redo`, `_awdMethod`, `_awdConfig`, `_awdCaptureSidebar`, `_awdApplySidebar`, `_awdSummary`, `_awdFail`, `_awdInvoke`, the catalog, `awdRegisterWebMCP`, `_awdModelContext`) directly before the INIT section; one boot call after `validateStoryInput();` at the end of INIT; one help paragraph under the `hg-more` heading of the help modal. Wrapped and unchanged: `loadPreset`, `clearCanvas`, `serializeWorkflow`, `deserializeWorkflow`, `addNode`, `addConnection`, `deleteNode`, `deleteConnection`, `attachVerifierLoop`, `attachReviewLoop`, `detachReviewLoop`, `addPreRegisteredEval`, `removePreRegisteredEval`, `getActivePromptText`, `explainWorkflow`, `validateWorkflow`, `undo`, `redo`, `pushUndo`, and the sidebar handlers (`setDefaultModel`, `setEffort`, `toggleMemory`, `toggleDurableRecord`, `toggleConsumeRecords`, `toggleClarifyFirst`, `toggleApprovePlan`, `addVerifyPath`, `clearVerifyPaths`, `setVerifyNotes`, `setExportFormat`).
- `tests.html`: the frozen eval describe "Eval: agent API facade and WebMCP registration (pre-registered eval)" (68 tests, written by the Eval Author before the plan; never edited); the describe `Agent API facade (window.awd)` after it (29 tests).
- `README.md`: one `##` section with no sub-headings between "Save & Load" and "Testing".
- Out of scope: edits to the bodies of the app's `undo`, `redo`, `pushUndo`, `batchUndo`; the generators' text; the one-click placement rules; the frozen eval describes of earlier records; an agentType template swap in `updateNode`; WebMCP tool annotations; an unregister path.

## Task checklist

- [x] Write and freeze the pre-registered eval from the requirements (@eval-author)
- [x] Plan the facade: method map to app entry points, undo strategy, catalog shape, test strategy (@planner)
- [x] Review the plan against the requirements and the matched records (@skeptic-review-planner)
- [x] Prove the facade undo carry end to end: step wrapper, summary, setName, addNode, undo, redo (@implementer)
- [x] Add the facade block with `version` and the read methods (@implementer)
- [x] Add `generate(format)` with no UI change and no state change (@implementer)
- [x] Add the `describe()` catalog with a JSON Schema per method (@implementer)
- [x] Add the canvas mutators with validation and `awd:` errors (@implementer)
- [x] Add the eval and loop mutators (@implementer)
- [x] Add the sidebar setters and `setOptions` (@implementer)
- [x] Add `undo`, `redo`, the one-undo-step rule, and the no-op rule (@implementer)
- [x] Add `batch(ops)` with rollback on failure (@implementer)
- [x] Add WebMCP registration and the one boot call (@implementer)
- [x] Write the facade test suite in tests.html (@implementer)
- [x] Add the README section and the help modal paragraph (@implementer)
- [x] Self-check the shell criteria E70 to E73 and the removal check E74 on the final tree (@implementer)
- [x] Review the code change (@reviewer)
- [x] Add edge tests and prove the load-bearing tests discriminate (@tester)
- [x] Execute every eval criterion and verify the outcome in a real browser (@verification-tester)
- [x] Run the content lint and the full suite on the final tree (@orchestrator)
- [x] Finalize the record, the index entry, and the timeline line (@orchestrator)

## Verify

Environment capability survey (2026-11-04): macOS, Python 3 and Google Chrome present, so `./run-tests.sh` (headless Chrome) runs here, and a real Chrome can be driven over the remote debugging protocol on localhost. Chrome 156 offers a native `document.modelContext` when started with `--enable-features=WebMCP` (found by the Verifier; the first survey said no browser here offered WebMCP). No WebMCP client agent is available here. No database, server, credential, or network dependency applies.

- `./run-tests.sh`: PASS 2138/2138 on the final tree (2026-11-04, run by the orchestrator at finalize; also twice by the Verifier). 2041 earlier tests, 68 eval tests, 29 facade tests. Baseline before the run: PASS 2041/2041 at 44edca2.
- `./run-tests.sh --verbose`: PASS 2138/2138, no FAIL line (2026-11-04, at finalize).
- Freeze check at finalize: the criteria block hash and the eval describe hash both equal the frozen values.
- Shell criteria at finalize: E70 prints 0, E71 prints 0, E72 prints 0; the content lint (the private hygiene check in CLAUDE.local.md) on index.html, tests.html, README.md, and this record gives no output and exit code 1.
- Discrimination (Tester, scratch copy): 9 mutations each turned the right test red (the single push, the single-call rollback, the redo pop in the rollback, the undo and redo hook, the generate format restore, the spread merge, the per-tool try, the rejection catch, the batch outer step). 8 of the 15 edge tests are not proven by a mutation.
- The Verifier's real-browser checks ran from throwaway driver scripts in a scratch folder (headless Chrome over the remote debugging protocol, trusted input events). The scripts and screenshots were scratch and were not kept; the evidence is the recorded results in the Verification ledger. A repeat needs a new driver.
- Not verified here: a WebMCP client agent that lists and calls the tools (none available; the native `executeTool` path it would use was exercised); a native `provideContext` (absent in this Chrome; covered by a stub only); browsers other than Chrome 156 on macOS.

## Risks / trade-offs

- Review follow-up note (2026-11-04): the facade rebinds the global undo and redo to carry sidebar values on a step. A later refactor could move that into the app's own snapshot (one applySnapshot used by undo, redo and rollback); until then any code that captures undo or redo by reference before the facade block binds the app's bare function.

- Known limit in the new code (Low, found by the Verifier, not fixed in this run, the director's call): `_awdConfig` does not type-check `config.tools`. `addNode` or `updateNode` with a `tools` value that is not an array of strings is accepted on a node no generator reads; a later connect to that node then fails with an internal message (`awd: connect: tools.join is not a function`, rolled back), and a UI drag to it throws until one Undo. Tool NAMES must stay unchecked. Suggested fix: reject a non-array or non-string `tools` value in `_awdConfig`, say so in the catalog text, add one test. The same class, lower value: a non-string `prompt` or `notes`.
- Documentation gap (Low): the README says a batch `tool` is a method name; `batch` rejects batch, undo, and redo. The catalog says so; the README does not.
- Code added later that stores a reference to the original `undo` or `redo` would skip the hook. Mitigation: no such reference exists today, and facade suite tests drive the real toolbar buttons and the keyboard on a facade step.
- The app's `loadPreset`, `addParallelGroup`, and `addFanOut` set `_undoBatch = false` unconditionally. Mitigation: every `_awdStep` restores the prior value in finally, and every batch entry runs through the wrapper.
- A facade setter that leaks sidebar state can break later suites. Mitigation: the facade suite resets in afterEach and in a finally per test.
- The README facade section and the help paragraph are pinned by eval tests E67 and E68, so a later edit that removes the method table or the named items fails the suite.

## Gotchas / non-obvious

- Typing in the Requirements and Workflow Context boxes does not refresh `_rawPrompt` today; only a later render does.
- The app's `loadPreset` switches memory on for the larger presets, and the app's undo does not switch it back.
- `serializeWorkflow()` returns live arrays (repositories, rulesPaths, productDocPaths, verifyPaths).
- The test harness skips afterEach when a test throws; the eval tests tidy in a finally block.
- Eval tests E55 to E57 boot a second copy of the app inside the suite (shared localStorage), so the boot code must tolerate a second boot in one browser session.
- Guard E62 counts tags in the served `index.html`: a new button, input, select, or textarea in the sidebar markup, or a new `role="menuitem"` anywhere in the file (script text included), fails it.
- Undo of a facade step that carried options runs the sidebar handlers, so preferences are saved, as a click on the control saves them. `setOptions` with the current values runs the handlers and takes no undo step.
- Pan and zoom are in no undo step (app scope): `setWorkflow` moves them and undo does not restore them.
- E67 makes the README facade section a standing contract: the suite fails if a later edit removes the method table or the other named items.
- A malformed `setWorkflow` shape that makes the app's deserializer throw gives a rewrapped internal message (for example `awd: setWorkflow: c.nodes.every is not a function`): the prefix and the method are right and the state is rolled back, but the bad value is not named.
- The app's deserializer accepts `{ canvas: {} }` (it clears the canvas) and a future version number; `window.awd` is not frozen.
- `awd.loadPreset` on a blank name fills the name box with a generated name, and Undo clears it again.

## Found bugs

- The app's `loadPreset(preset, _confirmed)` with an id that has no builder pushes an undo step, sets `_undoBatch = true`, clears the canvas, and never resets `_undoBatch` (the reset sits inside the `if (presets[preset])` branch), so every later undo push is suppressed. Evidence: read by the Implementer and the Skeptic. Fixed 2026-11-04 in the review follow-up: the reset moved outside the builder branch; one test pins it: not reachable from the UI (only the preset tiles call it) and not through the facade (the id is validated first); outside this change.
- A keydown with key "Z" (upper case, the value the UI Events specification gives for Ctrl+Shift+Z on Windows and Linux) does not redo: the keydown listener tests `e.key === 'z'` in its redo branch. Ctrl+Y and the macOS form work. Evidence: the Verifier's UI-only session left the stacks unchanged for that key on HEAD and on the working tree. Not confirmed on a physical Windows or Linux keyboard. Fixed 2026-11-04 in the review follow-up: the undo and redo branches accept z or Z; one test pins it: pre-existing, outside this change.

## Pre-registered eval

Frozen: sha256 807ee51e8f81d3fc9906fcd29a5a4c2bfba0a2c32270aac0820052a0107505bb over the criteria block (78 lines: 4 header lines and 74 criterion lines). Written by the Eval Author from the requirements alone, before any plan existed, 2026-11-04. Verify the block: `awk '/^Run: \.\/run-tests\.sh --verbose from the repository root/,/^- E74 /' .workflow/webmcp-and-mcp-facade.md | shasum -a 256`. Executable checks: `tests.html`, describe "Eval: agent API facade and WebMCP registration (pre-registered eval)", sha256 7b98be2bbefa7baf5cbf455491632595371a38c66a25b9e8d67e07ce3a8aac69 (`awk "/^describe\('Eval: agent API facade and WebMCP registration/,/^}\);\$/" tests.html | shasum -a 256`).

```
Run: ./run-tests.sh --verbose from the repository root. E1 to E68 are the tests of describe "Eval: agent API facade and WebMCP registration (pre-registered eval)" in tests.html; each test title ends with its id, for example (E6). Pass: no FAIL line of the run carries the id. Fail: a FAIL line carries the id. E69 to E74 name their own command or procedure.
Baseline (HEAD 44edca2 plus the describe, before the work): FAIL 62/2109. E1 to E57 and E64 to E68 fail, the six guards E58 to E63 pass, all 2041 earlier tests pass.
Assumptions the checks rest on, each named again in the test: (a) facade methods are synchronous; (b) a catalog entry's name is the method name and batch takes it as tool; (c) a tool input is one object: the method's own object argument (addNode, setOptions), its named parameters (connect: from, to, label), or one property for a one-parameter method, its name read from the inputSchema; (d) the registration function is a function property of window.awd outside the catalog, or a global function, whose name holds "webmcp", or "modelcontext" with "regist" or "provide"; (e) the confirm dialog is #confirmOverlay with class "show", or the native confirm; (f) run-tests.sh serves index.html and README.md over http; (g) nodes and edges render as [data-id] inside #canvas, a help paragraph is a <p> inside #helpOverlay, the sidebar markup runs from <div class="sidebar" id="sidebar"> to <div class="toolbar">.
Terms: "state unchanged" = JSON.stringify(state) plus the name, Requirements, and Workflow Context values are equal before and after. "summary" = an object with exactly the keys name, slug, preset, nodes, connections, warnings, where name and slug match the name box and serializeWorkflow().slug when a name is set, and nodes, connections, warnings match the state as counts or as lists. "node summary" = exactly id, type, label, x, y, config. "connection summary" = exactly id, from, to, label, fromPort. "chain" = In, Alpha Planner, Beta Coder, Gamma Tester, Done, built with the app's own functions. "throws" = throws an Error whose message starts with "awd:". "snapshot" = nodes, connections, hashes of the five generator outputs, hash of the Copy text (_rawPrompt), name, Requirements, Workflow Context, and the ten options. "probe" = snapshot s0; the app adds a marker node (a UI undo step), s1; the facade call, s2 differs from s1; undo() gives s1; redo() gives s2; undo() twice gives s0.
- E1 [R1] automated: window.awd is an object after boot and window.awd.version is the string "1".
- E2 [R2] automated: feature preset with Requirements, a verify path, and a rules path: each of the 8 read methods returns plain JSON (no function, no undefined, no DOM node, no class instance); the test then mutates the returned nodes, connections, workflow (canvas, verifyPaths, rulesPaths, name), warnings, Explain rows, presets, and catalog; state unchanged and a second read returns the first values.
- E3 [R2] automated: listPresets() ids and names equal the sidebar's .preset-item[data-preset] elements in document order (id = data-preset, name = .preset-name text); each entry has exactly the keys id, name, description; description is a non-empty string (its source is not pinned).
- E4 [R2] automated: getWorkflow() equals serializeWorkflow() key for key on an empty canvas and on bugfix with Requirements, Workflow Context, and a verify path; savedAt is a clock reading and is compared by type only.
- E5 [R2] automated: listNodes() and listConnections() return [] on an empty canvas; on feature every node is a node summary and every connection a connection summary with the values of state (compared sorted by id).
- E6 [R2] automated: feature with Requirements and Workflow Context, then also with memory, record, approval, and a verify path: for each of prompt, subagent, teams, sdk, claude, generate(format) === _rawPrompt read after setExportFormat(format) (five distinct texts); with the UI on teams, every call leaves unchanged: state, the active .format-tab, _rawPrompt, the #promptOutput HTML, the undo depth, and every localStorage pair.
- E7 [R2] automated: empty canvas: generate(format) === "" for all five formats, with the same nothing-changed observation as E6.
- E8 [R2] automated: explain(format) equals explainWorkflow(format) projected to exactly part, status, reason, snippet (same rows, same order) for all five formats on feature with the UI on teams; nothing changed as in E6. Reading: the Explain rows are the workflow-level rows the Explain button shows.
- E9 [R2] automated: validate() is [] on an empty canvas and on the chain (its Review is clean); with a loose coder added it equals validateWorkflow() projected to exactly type, msg, and is not empty.
- E10 [R2] automated: describe() is an array with exactly one entry, unique by name, for each of the 28 methods (listPresets, getWorkflow, listNodes, listConnections, generate, explain, validate, describe, newWorkflow, loadPreset, setWorkflow, addNode, updateNode, deleteNode, connect, disconnect, addEval, removeEval, attachVerifier, attachSkeptic, detachLoop, setRequirements, setContext, setName, setOptions, undo, redo, batch), each a function of window.awd; every entry names a function of window.awd and has a non-empty string description and a plain JSON inputSchema with type "object"; the addNode schema declares type, label, x, y, config; the setOptions schema the ten option keys; the connect schema from, to, label. Assumptions (b), (c).
- E11 [R3] automated: newWorkflow() on the chain with the rig's auto-confirm removed: nodes and connections are empty, the native confirm is not called, #confirmOverlay is not shown, the return is the summary, the node is off the canvas, _rawPrompt is "". Assumption (e).
- E12 [R3] automated: for every preset id, loadPreset(id) from the reset state gives the same nodes and connections (JSON) as the app's loadPreset(id); the return is the summary with preset === id; a node is drawn.
- E13 [R3] automated: loadPreset("bugfix") on the chain with auto-confirm removed: no confirm call, no dialog, the chain is gone, state.activePreset is "bugfix", and the node labels equal the app's bugfix labels. Assumption (e).
- E14 [R3] automated: loadPreset("no_such_preset") throws; state unchanged.
- E15 [R3] automated: w = getWorkflow() on bugfix named saved-flow with Requirements; after documentation is loaded under another name, setWorkflow(w) restores the nodes and connections (JSON), the name, the Requirements, and all five generator outputs; the return is the summary; _rawPrompt === getActivePromptText(); a node is drawn.
- E16 [R3] automated: setWorkflow({}), setWorkflow({ name }) and setWorkflow of a canvas with a node of an unknown type each throw; state unchanged.
- E17 [R3] automated: addNode({ type: "agent", label, x: 640, y: 420, config: { agentType: "reviewer", model: "sonnet-5", maxTurns: 7 } }) returns a node summary with those values and a new id; the node is in state (6 nodes) and drawn; mutating the returned object does not change the node.
- E18 [R3] automated: addNode without config gives task, decision, parallel, input, and output the NODE_DEFAULTS config of the type, and an agent every NODE_DEFAULTS.agent.config value; a partial agent config keeps its keys and takes the defaults for tools and notes.
- E19 [R3] automated: addNode throws on type "no_such_type", agentType "no_such_role", and model "no-such-model" (state unchanged), and accepts every AGENT_TYPES id and every MODELS value.
- E20 [R3] automated: addNode without x and y on the chain returns finite x and y with x greater than the x of every node already there, twice in a row; on an empty canvas x and y are finite (the position is not pinned).
- E21 [R3] automated: updateNode(Beta Coder, { label, config: { maxTurns, model } }) changes those and keeps agentType and prompt; the return is the node summary of that id; the Copy text names the new label; a config-only patch keeps the label and a label-only patch keeps the config; 5 nodes and 4 edges remain.
- E22 [R3] automated: updateNode throws on an unknown id, on agentType "no_such_role", and on model "no-such-model" sent with a label; state unchanged.
- E23 [R3] automated: deleteNode(Beta Coder) removes the node and both its edges (4 nodes, 2 edges), returns a plain JSON object, and the node is off the canvas; deleteNode("n404") throws, state unchanged.
- E24 [R3] automated: connect(In, Done, "direct") adds one edge, returns the connection summary of that edge, and the edge is drawn; the same call again returns the same id and adds nothing; connect(Alpha Planner, Gamma Tester) without a label adds an edge.
- E25 [R3] automated: connect throws on an unknown from, on an unknown to, and when from equals to; state unchanged.
- E26 [R3] automated: disconnect(Alpha Planner, Beta Coder) removes that edge only (5 nodes, 3 edges) and returns a plain JSON object; disconnect throws for the removed edge, for a reverse direction that has no edge, and for an unknown id; state unchanged.
- E27 [R3; non-goal: placement rules] automated: addEval() gives the same nodes and connections (JSON) as the app's addPreRegisteredEval(input) on the chain and on feature, bugfix, parallel_research, documentation; one Eval Author exists and is drawn; the return is a plain JSON object.
- E28 [R3] automated: with a spare Input without edges first in node order plus the chain, addEval() puts the Eval Author after the chain's Input and the spare Input gets no edge; with one Input without edges and a loose coder the result equals the app's one-click on that Input.
- E29 [R3] automated: addEval() throws when the canvas has no Input and when an Eval Author exists; state unchanged.
- E30 [R3] automated: removeEval() after the app's one-click gives the same canvas as the app's removePreRegisteredEval(); no Eval Author remains; the return is a plain JSON object.
- E31 [R3; non-goal: placement rules] automated: attachVerifier(Gamma Tester) gives the same canvas as the app's attachVerifierLoop; the return has exactly verifier, gate, routeBack, each the node summary of a node in state; verifier.config.reviewLoopFor is the tester, the gate is its decision, routeBack is Beta Coder and the gate has an edge to it; attachVerifier(Beta Coder) returns routeBack Beta Coder.
- E32 [R3] automated: attachSkeptic(Alpha Planner) gives the same canvas as the app's attachReviewLoop(id, "adversary"), the loop node is drawn, the return is a plain JSON object; detachLoop on a Skeptic loop and on a Verifier loop gives the same canvas as the app's detachReviewLoop, and hasReviewLoop is false.
- E33 [R3] automated: attachVerifier and attachSkeptic throw on an Input or an Output, on a Skeptic node, on an unknown id, and on a step that has a loop; state unchanged.
- E34 [R3] automated: for setRequirements, setContext, setName: the field holds the text, and after flushPendingSaves() the observation { field value, awd_autosave without savedAt, disabled state of #generateBtn, #refineBtn, #planBtn, #memoryPathDisplay text } equals the observation after typing the same text (value set, input event dispatched) from the same start; the autosave exists; the return is the summary.
- E35 [R3; decided by the Eval Author] automated: after each of setRequirements, setContext, setName on the chain: all five generator outputs hold the new text, _rawPrompt === getActivePromptText() and holds it, #promptOutput shows it, generate("prompt") === _rawPrompt; getWorkflow() carries the name, story, and plan. Decision: the requirement names the prompt as updating; typing in the Requirements and Workflow Context boxes does not refresh _rawPrompt today, so the facade refreshes it.
- E36 [R3] automated: setOptions with all ten keys: state holds each value; the controls agree (active tab, the five toggles, the selected model and effort option, the verify path chips, the notes box); the return is the summary; _rawPrompt === genAgentTeams(); after flushPendingSaves() awd_prefs holds each value; a second call { verifyPaths: ["only.md"], durableRecord: false } replaces the list, clears the toggle, and keeps the other keys.
- E37 [R3] automated: setOptions throws on { approvePlan: true, noSuchOption: 1 } and on approvePlan: true sent with exportFormat "pdf", defaultModel "no-such-model", effort "turbo", clarifyFirst "yes", or verifyPaths 42; after each throw state and the controls are unchanged, so approvePlan stays false.
- E38 [R3] automated: after an app addNode (a UI step) undo() restores the snapshot before it and redo() the snapshot after it; both return the summary; with empty stacks both change nothing and do not throw.
- E39 [R4] automated: the probe holds for addNode (with and without x and y), updateNode, deleteNode, connect, disconnect.
- E40 [R4; director's answer on undo reach] automated: the probe holds for newWorkflow, loadPreset("bugfix"), and setWorkflow(a saved documentation workflow with another name, Requirements, Workflow Context, approvePlan, and a verify path), each from the chain with Requirements and Workflow Context: the name, Requirements, Workflow Context, and options come back with the canvas.
- E41 [R4] automated: the probe holds for addEval, removeEval, attachVerifier, attachSkeptic, detachLoop.
- E42 [R4; director's answer on undo reach] automated: the probe holds for setRequirements, setContext, setName, and setOptions(all ten keys); after setOptions, undo() and redo() also restore the controls of E36.
- E43 [R4, R8; director's answer on undo reach] automated: name and Requirements typed, approval switched on, an app addNode, then the name typed again: undo() removes the node and redo() restores it, and both leave the name, the Requirements, state.approvePlan, and its toggle as they are.
- E44 [R4] automated: marker, then connect on an existing edge: the return carries that edge's id, the snapshot is unchanged, and one undo() gives s0 (the marker went, so the call took no step).
- E45 [R4; derived: a call that throws changes nothing] automated: marker, then addNode of an unknown type, deleteNode("n404"), connect with from equal to to, loadPreset("no_such_preset"), setWorkflow({}), setOptions({ approvePlan: true, effort: "turbo" }): each throws and leaves the snapshot unchanged, and one undo() then gives s0.
- E46 [R5] automated: batch([setName, addNode, connect, setOptions({ approvePlan: true })]) returns a plain JSON array of 4 results in order (the summary with the new name, the node summary of a node in state, the connection summary); the state shows all four changes; the probe, with the controls of E36 added to the snapshot, holds for the batch as one call. Assumptions (b), (c).
- E47 [R5] automated: batch([setName, addNode, connect to "n404", setOptions]) throws an Error whose message starts with "awd:" and holds the standalone number 2 (/\b2\b/) and "connect"; right after the throw the snapshot with the controls equals the one before the batch (the name is back, the node is gone) and approvePlan is false. Assumption: the index is the zero-based array position. Not pinned: whether a failed batch leaves an undo step.
- E48 [R5; boundaries] automated: a batch whose entry 1 names the tool "noSuchTool" throws with "awd:", /\b1\b/, and the tool name, and applies nothing; batch([]) returns [], changes nothing, and one undo() then gives s0.
- E49 [R6] automated: 16 calls (loadPreset unknown id; setWorkflow({}); addNode unknown type, agentType, model; updateNode unknown id, unknown agentType; deleteNode unknown id; connect unknown id, from equal to to; disconnect with no such edge; addEval with an Eval Author present; attachVerifier on an Input; attachSkeptic on a step that has a loop; setOptions unknown key, effort "turbo") each throw an Error instance whose message starts with "awd:" and holds the method name and each bad value (the id, the type, the key, the value; both ids for disconnect).
- E50 [R7] automated: the registration function called with a fake { registerTool }: one call per catalog entry, with the same name, description, and inputSchema, and execute is a function; a fake that offers registerTool and provideContext gets every tool through registerTool. Assumption (d).
- E51 [R7] automated: execute({}) of listNodes and of validate returns exactly { content: [{ type: "text", text }] } with one item, isError is not true, and JSON.parse(text) equals the facade result; execute of addNode, connect, and setName changes the canvas and the name. String results are not read back (the requirement does not say how a string is written as text). Assumptions (c), (d).
- E52 [R7] automated: execute of loadPreset with "no_such_preset" and of connect with from equal to to resolves without a throw or a rejection to the same shape with isError === true and a text that holds the facade error message (it starts with "awd:"); state unchanged.
- E53 [R7] automated: a fake with only provideContext is called at least once; the tools arrays of its arguments together hold every catalog entry with its description, inputSchema, and execute; the listNodes tool executes. Assumption: provideContext receives { tools: [...] } as the WebMCP API defines it.
- E54 [R7] automated: the registration function called with undefined, null, {}, and { registerTool: null, provideContext: undefined }: no throw, console.error is not called, state unchanged.
- E55 [R7] automated: a second copy of the app booted in a frame where document.modelContext and navigator.modelContext are fakes with registerTool: the document fake holds every catalog entry, the navigator fake holds none, and a registered tool executes. Assumption (f).
- E56 [R7] automated: the same boot with only navigator.modelContext: that fake holds every catalog entry.
- E57 [R7] automated: the same boot with neither: the app boots, window.awd.version is "1", console.error is not called, and no uncaught error occurs.
- E58 [R8] guard: every preset in five variants (plain, mandates, one-click eval, memory and record, approval with memory and record), no facade call made: the five generator output hashes equal today's (the same values as the strays-never-run eval).
- E59 [R8] guard: every preset, plain and approval with memory and record: the hash of validateWorkflow [type, msg], of the explainWorkflow rows in five formats, and of the explainNode rows of every agent in prompt, subagent, teams equals today's.
- E60 [R8; director's answer on undo reach] guard: an app addNode pushes one undo step, typing in the sidebar none, an app loadPreset one; the app's undo twice and redo once move the canvas only; the typed name, the Requirements, state.approvePlan, and its toggle stay; the Copy text is fresh.
- E61 [R8; non-goal: persistence] guard: a canvas edit writes nothing before the debounce; flushPendingSaves() writes awd_autosave with today's keys, 6 nodes, and the name; clearCanvas(true) removes it; savePrefs() writes today's keys.
- E62 [R8] guard: the served index.html has in its sidebar markup sections:12, input:25, select:1, textarea:5, button:53, and in the whole file 7 role="menuitem" and 7 class="context-menu-item. Assumptions (f), (g).
- E63 [non-goal: node types] guard: Object.keys(NODE_DEFAULTS) is agent, task, decision, parallel, input, output.
- E64 [R8; non-goal: prompt generation] automated: the chain built through addNode and connect gives the same five generator outputs as the chain built by the app, and generate(format) equals them.
- E65 [constraint: tools are suggestions] automated: addNode with config.tools that holds names outside ALL_TOOLS keeps the list; updateNode then sets another unknown name, then [].
- E66 [non-goal: persistence] automated: from an empty localStorage, a facade session (loadPreset, addNode, updateNode, the three setters, setOptions, batch, addEval, undo, redo, generate, describe, newWorkflow, undo) plus flushPendingSaves() leaves no key that the same session through the app's own functions does not leave, other than awd_autosave and awd_prefs; the sessionStorage size is unchanged.
- E67 [R10] automated: README.md: the smallest section (a heading down to the next heading of the same or a higher level) that holds "window.awd" and one table (consecutive lines that start with |) naming all 28 methods also holds: "version" within 80 characters of a standalone 1; "one" or "single" within 60 characters of "undo"; "awd:" and the word error; "WebMCP"; "automat"; "import" and "JSON". Assumption (f).
- E68 [R10] automated: exactly one <p> inside #helpOverlay holds "window.awd", and it holds "README". Assumption (g).
- E69 [R9] manual: read tests.html outside this describe and name one test for each topic: (1) the version; (2) the catalog; (3) the shape of each of the 8 read methods; (4) generate() equal to the Copy path in five formats with the UI format unchanged; (5) the result of each of the 17 mutating methods and of batch; (6) the one-undo-step property of each; (7) the no-op rule; (8) batch atomicity on failure; (9) error messages; (10) registration through a fake registerTool; (11) through a fake provideContext; (12) the no-context case; (13) byte identity of the five formats for every preset. Pass: every topic has a named test and each passes in the run. Fail: a topic has no test, or its test fails.
- E70 [R9; constraint: titles] automated: `git diff -U0 HEAD -- tests.html | grep -E "^\+.*\bit\('" | grep -vcE "\bit\('should "` prints 0.
- E71 [constraint: no new files; non-goal: no server process] automated: `git status --porcelain --untracked-files=all | grep -v '^?? \.workflow/' | grep -c '^??'` prints 0.
- E72 [constraint: no em or en dashes] automated: `git diff -U0 HEAD -- index.html README.md tests.html | grep '^+' | grep -v '^+++' | grep -v 'toNot' | python3 -c "import sys; t=sys.stdin.buffer.read().decode('utf-8','replace'); sys.exit(1 if (chr(0x2014) in t or chr(0x2013) in t) else 0)"; echo $?` prints 0 (lines of a negative assertion, which carry toNot, are left out).
- E73 [constraint: content lint] automated: run the content lint command documented in CLAUDE.local.md with `--untracked` added and ` -- index.html tests.html README.md .workflow/webmcp-and-mcp-facade.md` appended. Pass: no output and exit code 1.
- E74 [constraint: removable block] manual: copy the repository to a scratch folder; in the copy's index.html delete the facade block and the one boot call; run ./run-tests.sh --verbose in the copy. Pass: two deletions were enough (one contiguous block, one call); the runner prints a PASS or FAIL line (no load error); window.awd is undefined; guards E58 to E63 pass; every failing test is in a facade suite or is a non-guard test of this describe. Fail: a load error, a third place to delete, or any other failing test.
```

### Eval results, 2026-11-04 (Verifier, cycle 1 of 3): 74 PASS, 0 FAIL, 0 BLOCKED

- E1 PASS: suite run: no FAIL line; test read: checks typeof awd, not null, version string "1"
- E2 PASS: no FAIL line; test read: 8 reads plain JSON, mutates every returned object, state and second read equal
- E3 PASS: no FAIL line; test read: ids and names equal .preset-item order, exact keys, non-empty description
- E4 PASS: no FAIL line; test read: canon(getWorkflow) equals canon(serializeWorkflow) without savedAt, two canvases
- E5 PASS: no FAIL line; test read: [] on empty, exact keys, values equal state sorted by id
- E6 PASS: no FAIL line; test read: generate(f) === _rawPrompt after setExportFormat(f), 5 distinct, watch() (state, tab, raw, panel, undo depth, storage) equal after each call, two variants
- E7 PASS: no FAIL line; test read: "" for five formats, watch() equal
- E8 PASS: no FAIL line; test read: rows equal explainWorkflow projection, exact keys, watch() equal
- E9 PASS: no FAIL line; test read: [] on empty and on the chain, equals validateWorkflow projection with a loose coder
- E10 PASS: no FAIL line; test read: 28 methods each one entry, unique, description, object schema, addNode/setOptions/connect properties
- E11 PASS: no FAIL line; test read: auto-confirm removed, confirm counter 0, dialog not shown, summary, node off canvas, raw ""
- E12 PASS: no FAIL line; test read: every preset id, canvas JSON equal to the app's, summary, preset id, node drawn
- E13 PASS: no FAIL line; test read: no confirm, no dialog, chain gone, activePreset bugfix, labels equal
- E14 PASS: no FAIL line; test read: awd: throw, stateSig equal
- E15 PASS: no FAIL line; test read: canvas, name, Requirements, five generator outputs restored, summary, raw fresh, node drawn
- E16 PASS: no FAIL line; test read: {}, { name }, unknown node type each throw awd:, stateSig equal
- E17 PASS: no FAIL line; test read: values, new id, 6 nodes, drawn, returned object detached
- E18 PASS: no FAIL line; test read: NODE_DEFAULTS config per type, agent defaults, partial config
- E19 PASS: no FAIL line; test read: three throws with state equal, every AGENT_TYPES id and MODELS value accepted
- E20 PASS: no FAIL line; test read: x greater than every node twice in a row, finite on empty canvas
- E21 PASS: no FAIL line; test read: merge keeps agentType and prompt, summary, Copy text names the label, config-only and label-only patches
- E22 PASS: no FAIL line; test read: three throws, stateSig equal
- E23 PASS: no FAIL line; test read: 4 nodes 2 edges, plain object, off canvas, n404 throws
- E24 PASS: no FAIL line; test read: edge added and drawn, same id on repeat, no-label connect
- E25 PASS: no FAIL line; test read: unknown from, unknown to, from equals to throw, state equal
- E26 PASS: no FAIL line; test read: one edge removed, three throws, state equal
- E27 PASS: no FAIL line; test read: canvas JSON equal to the app's one-click on the chain and 4 presets
- E28 PASS: no FAIL line; test read: spare Input gets no edge; lone Input equals the app's one-click
- E29 PASS: no FAIL line; test read: no Input and existing Eval Author throw, state equal
- E30 PASS: no FAIL line; test read: canvas equal to removePreRegisteredEval
- E31 PASS: no FAIL line; test read: canvas equal to attachVerifierLoop, exact keys, routeBack Beta Coder, gate edge
- E32 PASS: no FAIL line; test read: canvas equal to attachReviewLoop and detachReviewLoop for both loop kinds
- E33 PASS: no FAIL line; test read: 8 cases throw, state equal
- E34 PASS: no FAIL line; test read: observation after the facade call equals the observation after typing, autosave exists, summary
- E35 PASS: no FAIL line; test read: five outputs, raw, panel, generate hold the new text; getWorkflow carries name, story, plan
- E36 PASS: no FAIL line; test read: ten keys in state, controls, awd_prefs; second call replaces the list
- E37 PASS: no FAIL line; test read: 6 bad calls throw, state and controls equal, approvePlan false
- E38 PASS: no FAIL line; test read: UI step undone and redone through awd, summary, empty stacks no throw
- E39 PASS: no FAIL line; probe read (oneStep: marker, call, undo gives s1, redo gives s2, two undos give s0) for 6 calls
- E40 PASS: no FAIL line; probe read for newWorkflow, loadPreset, setWorkflow with name, Requirements, Context, approvePlan, verify path
- E41 PASS: no FAIL line; probe read for addEval, removeEval, attachVerifier, attachSkeptic, detachLoop
- E42 PASS: no FAIL line; probe read for the 3 setters and setOptions(ten keys); controls equal after undo and redo
- E43 PASS: no FAIL line; test read: UI step undone and redone, name, Requirements, approvePlan, toggle unchanged
- E44 PASS: no FAIL line; test read: same edge id, snapshot equal, one undo gives s0
- E45 PASS: no FAIL line; test read: 6 throwing calls, snapshot equal, one undo gives s0
- E46 PASS: no FAIL line; test read: 4 results in order, state shows all four, probe with controls
- E47 PASS: no FAIL line; test read: awd:, /\b2\b/, "connect", snapshot with controls equal, approvePlan false
- E48 PASS: no FAIL line; test read: awd:, /\b1\b/, tool name, nothing applied; batch([]) is [] and takes no step
- E49 PASS: no FAIL line; test read: 16 cases, Error instance, awd: prefix, method name, each bad value
- E50 PASS: no FAIL line; test read: one registerTool call per entry, same name, description, schema, execute; registerTool wins over provideContext
- E51 PASS: no FAIL line; test read: exact shape, JSON.parse(text) equals the facade result, addNode/connect/setName change the page
- E52 PASS: no FAIL line; test read: no throw, isError true, text holds the awd: message, state equal
- E53 PASS: no FAIL line; test read: provideContext called, tools arrays hold every entry, listNodes executes
- E54 PASS: no FAIL line; test read: undefined, null, {}, null members: no throw, console.error count 0, state equal
- E55 PASS: no FAIL line; test read: second app copy booted in a frame, document fake holds every entry, navigator fake none, tool executes
- E56 PASS: no FAIL line; test read: navigator fake holds every entry
- E57 PASS: no FAIL line; test read: boots, version "1", console.error 0, no uncaught error
- E58 PASS: no FAIL line; guard read: 23 presets x 5 variants, hashes equal GOLD (115 values, equal to the strays-never-run GOLD)
- E59 PASS: no FAIL line; guard read: Review and Explain hashes equal GOLD
- E60 PASS: no FAIL line; guard read: step counts, canvas-only undo, sidebar stays, Copy text fresh
- E61 PASS: no FAIL line; guard read: debounce, autosave keys, clearCanvas removes it, prefs keys
- E62 PASS: no FAIL line; guard read: served index.html counts equal GOLD.ui
- E63 PASS: no FAIL line; guard read: NODE_DEFAULTS keys
- E64 PASS: no FAIL line; test read: chain built through the facade gives the same five outputs; generate equals them
- E65 PASS: no FAIL line; test read: tool names outside ALL_TOOLS kept, replaced, emptied
- E66 PASS: no FAIL line; test read: facade session leaves no extra key against the app session; sessionStorage size equal
- E67 PASS: no FAIL line; test read: smallest README section with window.awd and a 28-method table holds every required phrase
- E68 PASS: no FAIL line; test read: exactly one help paragraph with window.awd, holds README
- E69 PASS: manual: one passing test named per topic outside the eval describe (list in section 3)
- E70 PASS: exact command printed 0 (97 added it( lines, all start with should)
- E71 PASS: exact command printed 0
- E72 PASS: exact command printed 0 (my wider check: 0 of 2158 added lines hold an em or en dash, toNot lines included)
- E73 PASS: content lint from CLAUDE.local.md with --untracked on the four files: no output, exit code 1
- E74 PASS: manual: scratch copy, 2 deletions (the facade block plus its blank line; the boot call); copy differs from HEAD by 1 line (the help paragraph); runner printed FAIL: 89/2138 (no load error); error text "window.awd is not defined"; guards E58 to E63 pass; the 89 failing tests are 60 non-guard tests of the eval describe plus the 29 facade suite tests; 0 other; copy deleted

## Verification ledger

- [x] Freeze check: shasum of the criteria block and of the eval describe, at start and end. Result: both equal the frozen values. (Verifier)
- [x] `./run-tests.sh --verbose` on the working tree, twice. Result: PASS 2138/2138 both times, first attempt. (Verifier)
- [x] Read of the eval describe (68 tests), the facade block, and the facade suite tests for 13 topics. Result: each test exercises its criterion; E69 topics named. (Verifier)
- [x] E70, E71, E72, E73 exact commands. Result: 0, 0, 0, no output with exit 1. (Verifier)
- [x] E74 scratch copy with the block and the boot call deleted, `./run-tests.sh --verbose`. Result: FAIL 89/2138, all 89 in the two facade suites, guards pass, window.awd undefined; copy deleted. (Verifier)
- [x] Real browser (headless Chrome 156, CDP, trusted input) on 127.0.0.1:63279: README-only agent session. Result: 36 of 36 checks pass; real Copy button equals generate() in five formats. (Verifier)
- [x] Real browser: undo and redo through the toolbar, Ctrl+Z, Meta+Z, Ctrl+Shift+Z, Ctrl+Y, awd.undo, awd.redo over 9 facade steps, and mixed UI and facade steps. Result: every snapshot restored; all checks pass. (Verifier)
- [x] Real browser, HEAD export on 127.0.0.1:63280 against the working tree: the same UI-only session. Result: 21 of 21 snapshots and stack depths identical. (Verifier)
- [x] Real browser: make-it-fail session (late-failing batch, 16 malformed setWorkflow inputs, 1088-call bad-argument matrix, 33 named bad calls, 9 no-op calls, generate under another tab, 3 000 000 character text, 241 calls in one tick, markup injection). Result: all pass; finding F1 and note N1 recorded. (Verifier)
- [x] Real browser: facade session and real reload on the working tree against the app-function session on HEAD. Result: equal localStorage values, empty sessionStorage, equal restore. (Verifier)
- [x] Native WebMCP: Chrome 156 with `--enable-features=WebMCP` on port 63282: boot registration, getTools, executeTool. Result: 28 tools registered natively, 15 of 15 checks pass. (Verifier)
- [x] WebMCP stubs installed at document start (8 context shapes). Result: 29 of 29 checks pass. (Verifier)
- [x] Full-text comparison of 23 presets x 2 variants x 5 formats (generator and Copy text), Review, Explain, canvases between HEAD and the working tree. Result: 460 texts, 35 866 962 characters, all equal. (Verifier)
- [x] Static comparison of the HEAD file and the working tree file (sidebar controls, menu items, buttons, inputs, onclick attributes) and of the diff hunks. Result: counts equal; 3 hunks, additions only. (Verifier)
- Blocked: none. Not verified (no required check; see Verify): a WebMCP client agent, a native provideContext, key "Z" on a physical Windows or Linux keyboard.
- [x] Plan review against the requirements, the frozen eval, the code, and the matched records. Result: one High finding, fixed in one revise cycle; delta re-review passed. (Skeptic)
- [x] Code review of the diff plus 8 probe tests in a scratch copy. Result: approved, no Critical or High finding. (Reviewer)
- [x] 15 edge tests and 9 mutations in a scratch copy. Result: PASS 2138/2138; each mutation turned the right test red. (Tester)
- [x] `./run-tests.sh` and `./run-tests.sh --verbose`, both freeze hashes, E70 to E72, and the content lint on the final tree. Result: PASS 2138/2138; hashes equal; 0, 0, 0; lint exit 1. (orchestrator, re-confirms the Verifier runs)

## History

- 2026-11-04: created (by webmcp-and-mcp-facade)
- 2026-11-04: Requirements replaced with the director's full text after a clipped paste (by webmcp-and-mcp-facade)
- 2026-11-04: requirement 4 gained its reach note from clarify C2: facade undo steps restore the sidebar (by webmcp-and-mcp-facade)
- 2026-11-04: finalized after a verified run: eval 74 of 74 passed, suite 2041 to 2138 (by webmcp-and-mcp-facade)

- 2026-11-04: review follow-up (direct session) - the two Found bugs fixed in place (loadPreset undo flag; upper-case Z redo) with one test each, 2138 -> 2140; the CLAUDE.md test-title rule rewritten (one sentence of behavior, should optional)
- 2026-11-04: house review round (code-review high, all findings; direct session) - 13 findings, 10 acted on: tools validated as an array of names on addNode and updateNode; _awdNextSpot guards x, y and w from hand-written setWorkflow nodes; addEval takes an optional inputId and names the ambiguity when more than one Input has edges (the one-click path uses the selected Input for the same reason); getWorkflow described as serializeWorkflow's object (the frozen eval pins it; Export wraps it in an envelope); README batch row names the three excluded tools; one capture after a step instead of three; the catalog built once; verifyPaths applied as one assignment and one render; setText regenerates once; the catch-side undo-flag reset explained. Declined: pan and zoom in the undo payload (the app's own undo never restores the viewport); replacing the undo and redo rebinding with a shared applySnapshot (a redesign the Skeptic already weighed as H1; noted under Risks); two titles without 'should' (the title rule changed the same evening). 2140 -> 2143

## Outcome

The designer's page now has one documented, versioned agent surface, `window.awd` version "1" (28 methods), and registers the same catalog as WebMCP tools when the browser offers a model context. The change is additive: one removable block and one boot call in `index.html` (plus one help paragraph), one facade describe and the frozen eval describe in `tests.html`, and one README section. No app function was edited, and every preset generates the same text as before in all five formats. The suite went from 2041 to 2138 tests. All 74 pre-registered criteria passed, and the Verifier registered and executed the 28 tools on a native `document.modelContext` in Chrome 156 with the WebMCP feature flag. Follow-ups for the director: the `config.tools` type check and the README batch sentence (Risks), and two pre-existing defects (Found bugs). Run shape: one director clarify round (two answers), no Eval Author question, one plan revise cycle, no code revise cycle, verified at the first cycle.

## Built with (provenance)

Workflow `webmcp-and-mcp-facade` (sub-agent format): Eval Author (Fable) -> Planner (Opus) -> Skeptic review of the plan (Opus, gate "Plan sound?", max 3 cycles, revise to Planner; one revise cycle used) -> Implementer (Opus) -> Reviewer (Opus, read-only, gate "Review Passed?", max 3 cycles, revise to Implementer; none used) -> Tester (Opus) -> Verifier (Fable, gate "Objective met?", max 3 cycles, revise to Implementer; none used; executes the pre-registered eval, and a BLOCKED criterion fails the gate). Revise cycles and the delta re-review continued the existing agents with surgical briefs. One declared polish pass by the Implementer after the approved review (four Low notes), outside the gates. Toggles on: workflow memory, durable record, ground in prior records, clarify first, code-search MCP, Atlassian MCP (general; not used, no work item). Grounding: the `.workflow/_index.md` scan (eleven records matched); no `openspec/` directory. Delivery: leave uncommitted.

## Links

- Work item: none. Branch: main. PR: none.
- Grounds on / touches: undo-text-coverage, validation-modal, saved-workflow-context, explain-workflow, strays-never-run, one-notion-of-the-run, pre-registered-eval, verifier-and-review-loop-family, tool-suggestion-semantics, autosave-persistence, in-app-help (read for grounding; none amended).

```awd:run
{"workflow": "webmcp-and-mcp-facade", "repo": "agentic-workflow-designer", "steps": [{"slug": "eval-author", "status": "done"}, {"slug": "planner", "status": "done"}, {"slug": "skeptic-review-planner", "status": "done"}, {"slug": "implementer", "status": "done"}, {"slug": "reviewer", "status": "done"}, {"slug": "tester", "status": "done"}, {"slug": "verification-tester", "status": "done"}], "gates": [{"slug": "plan-sound", "cycles": 1, "final": "Passed"}, {"slug": "review-passed", "cycles": 0, "final": "Approved"}, {"slug": "objective-met", "cycles": 0, "final": "Verified"}], "grounded": ["undo-text-coverage", "validation-modal", "saved-workflow-context", "explain-workflow", "strays-never-run", "one-notion-of-the-run", "pre-registered-eval", "verifier-and-review-loop-family", "tool-suggestion-semantics", "autosave-persistence", "in-app-help"], "eval": {"criteria": 74, "passed": 74, "failed": 0, "blocked": 0}, "notes": "One director clarify round (clipped requirements text resupplied; undo reach decided). Eval Author raised no question. Plan revise cycle 1: the Skeptic blocked a plan that narrowed the director's undo answer. One declared Implementer polish pass after the approved review (four Low notes), outside the gates. Verifier found native WebMCP in Chrome 156 behind a feature flag. Agents' scratch cleanup with rm -rf hit the director's confirm rule and stalled the run until answered. Turns were not tracked."}
```

