---
node: arc-coding-turn
layer: navigation
related: [arcs/README, goals/coding-agent, banks/unit, banks/capability, permission-model, status-ledger, decisions/decision-work-ids, decisions/decision-design-before-mint, arcs/transport-arc, arcs/unit-lane-arc, index]
status: current
updated: 2026-09-08
---

# Arc: coding-turn

- goals: [[goals/coding-agent]], condition 1: "A coding turn is decomposed
  across the engine rather than run as one loop, and each step holds only the
  tools it was granted."
- reserved element block: `none`, so rows carry arc-local ids per
  [[decisions/decision-work-ids]]. This arc spells the letter `A`, for agent:
  `coding-turn/A1` upward. Author call B was ruled 2026-09-06, "let overlap
  exist", so a band is advisory and an arc without one mints the next number
  free tree-wide. `display-calculus/A1` and `A2` spell the same letter. The
  citable name carries the arc prefix, so the two do not collide.
- build-state authority: [[status-ledger]]
- checklist: none. No `records/coding-turn.md` exists.

## Why this arc exists

The engine and the coding agent are two working halves in one tree and neither
reaches the other. `prog/prapanca/` is 9,990 lines, 7,741 of them `.chiral`, and
no file in it executes a tool. `prog/agent/agent.chiral` is 452 lines that run
a whole tool-call turn against a live endpoint and import nothing from the
engine, a choice its own header states at `:12-16`. The condition asks for one
turn crossing that cut: the turn decomposed into engine nodes, and each node
bounded by the tool grant its `Expert` already declares.

Both halves of the condition are already named in the tree and neither is
wired. `Expert.tools` is declared least-privilege at
`prog/prapanca/core/types.chiral:64-65`, bound at seven destructuring sites and
read at none of them, so a grant nothing reads permits everything. `Flow` has
seven constructors and not one of them fires a tool, so there is no engine node
for a granted step to be. What this arc schedules is the joining, plus the two
genuinely absent pieces the joining needs: a tool that is a value, and a node
that carries one.

## What the tree already holds

Measured 2026-09-08. [[banks/INDEX]] holds twelve banks and two of them own
this territory.

- [[banks/unit]] refracts the agent, the model call and the LLM chain. Its
  shard A is the `Expert` record; its cross-cut C1 already reads a `Config` as a
  grant table, "authority is the ports you hold" at the orchestration layer.
  Its shard S is `prog/prapanca/core/builder.chiral`, and that file's
  `accept-gate`, `tool-builder-flow` and `tool-builder-author` decode and
  type-check **new `Flow` values a model emitted** (`builder.chiral:43-51`,
  `:77-78`). It is the self-extension wall. It builds no tool schema and
  executes no tool.
- [[banks/capability]] owns "each step holds only the tools it was granted",
  because least privilege here is capability and nothing else. Of the four
  grant operations only Move is enforced by linearity; Attenuate is
  present-but-unapplied (`subtype` at `lib/typing/kernel.chiral:799`, unwired to
  grant narrowing); Delegate, Revoke and the broker's grant/revoke/audit (E43)
  are design with no code. [[permission-model]] is its thin note. Neither bank
  is re-derived below.

⚑ **`prog/agent/` carries no row in [[status-ledger]], `records/conformance-map.md`
or `docs/elements/catalog.md`.** A grep for `prog/agent` across all three
returns zero. The rungs below are this arc's reading against the ledger's own
four definitions, and for that subtree they rest on no prior row.

| group | what exists today | where | rung |
|---|---|---|---|
| G1 tool-as-value | four tool schemas built inline as `Json`, and a dispatch that is a `str-eq` chain over four literal names | `prog/agent/agent.chiral:99-147`, `:361-374` | IMPLEMENTED |
| G1 | the four native tools themselves, 96 lines plus one crossing | `prog/agent/tools-fs.chiral:50`, `:62`, `:88`; `ag-bash` at `prog/agent/agent.chiral:60` over `raw-proc-spawn`/`wait` | IMPLEMENTED |
| G1 | `PureFn`, a closed sum of six deterministic string transforms, which is the engine's only non-model step and crosses nothing | `prog/prapanca/core/flow.chiral:119-138` | SEEDED |
| G2 the grant | `Expert.tools`, declared least-privilege, default read-only nil | `prog/prapanca/core/types.chiral:64-65`, record at `:66-68` | SEEDED |
| G2 | the field bound at seven destructuring sites across four files and read at zero | `assemble.chiral:51`, `flow.chiral:1336`, `:1338`, `plan.chiral:46`, `:47`, `doc-refine.chiral:17`, `:19` | SEEDED |
| G2 | one profile granting it in earnest, with prose stating the reason | `prog/prapanca/profile/code-test.chiral:39-40`, grant at `:50` | SEEDED |
| G2 | `assemble-prompt` binds `tools` and emits six sections, none of them the grant, so a model is never told what it may use | `prog/prapanca/core/assemble.chiral:48-57` | IMPLEMENTED |
| G3 the engine | `Flow`, seven constructors. `flow-step` makes one model call, `flow-pure` applies a `PureFn`. None executes a tool | `prog/prapanca/core/flow.chiral:140-153` | SEEDED |
| G3 | `flow-ty : Flow -> (Maybe Arrow)`, total over all seven, the pure compositional checker | `prog/prapanca/core/flow.chiral:212` | SEEDED |
| G3 | `ty-eq` compares the name alone by `str-eq`, so a chain seam agrees on names and stays silent on the shape those names carry | `prog/prapanca/core/flow.chiral:77` | SEEDED |
| G3 | `Ty`, `Shape` with three arms (`sh-prose`, `sh-list`, `sh-rec`), `Arrow`, and `refine-ok` validating a step's output against the declared shape by decode success | `prog/prapanca/core/flow.chiral:42`, `:46`, `:71`, `:355` | SEEDED |
| G3 | the membrane holds around the engine: `run-gate` is `->`, `Backend` is a linear porttype threaded through every result carrier, `run-pipeline`'s effect row is exactly `(be-chat)` | `gate.chiral:114`, `prog/prapanca/backend.chiral:32`, `pipeline/runner.chiral:187-188` | IMPLEMENTED |
| G3 | the coding turn as it runs today: one recursion on a step budget, importing prelude, http, json and tools-fs and nothing under `prog/prapanca/` | `prog/agent/agent.chiral:17-20`, `:410-438`, choice stated at `:12-16` | IMPLEMENTED |
| G4 the record | `ExpertCall`, `RawCall`, `RunManifest`, and `manifest-all-green?` reading a run's health off values | `types.chiral:131`, `:152`, `:166`; `flow.chiral:1422` | SEEDED |
| G4 | what the coding turn returns instead: `(Pair Str Str)`, answer and transcript, with no manifest, no gate and no linear `Backend` | `prog/agent/agent.chiral:410`, `:440-452` | IMPLEMENTED |
| G5 the guard | `stop.chiral` is 30 lines and both its defs are `->`: `overflow-guard`, an integer chars/4 estimate against `num_ctx`, and `stop-policy`, a `"sharpen"`/`"example"` substring match. Neither has a caller outside the file | `prog/prapanca/core/stop.chiral:20`, `:25` | SEEDED |
| G5 | the only bound on a coding turn today: an integer step budget decremented once per turn | `prog/agent/agent.chiral:411`, `:428`, `:434` | IMPLEMENTED |
| G6 the gate | Phase 20 compiles five roots under `prog/samples/`, runs each and judges it against the exit code its own header states, deferring the two that need the endpoint under a recorded ruling | `tools/test/transport.sh:165-194`, `tools/test/run-tests.sh:305-326` | ENFORCED |
| G6 | no `prog/agent/` or `prog/prapanca/` path appears in any `tools/test/*.sh`. Phase 7 sweeps every root carrying `compile-main`, compiles it and runs none | `tools/test/run-tests.sh:172-180` | SEEDED |
| G6 | `agent-probe.prog` drives a full `agent-run` tool-call turn and its `compile-main` returns `0` whatever came back | `prog/samples/agent-probe.prog:11-17` | SEEDED |
| G6 | no `*.golden.json` exists in the tree, and two conform roots name an absent path under a directory the 2026-08-31 migration removed | `prog/samples/prapanca-run-conform.prog:66`, `prog/samples/prapanca-flow-conform.prog:71` | SEEDED |

Two facts from that table govern the roster. `stop-policy` decides a retry by
matching `"sharpen"` and `"example"` in an expert id, which answers a
doc-refine question and no coding-turn question, so this arc takes
`overflow-guard` and leaves `stop-policy` where it is. And `prog/agent/agent.chiral`
is imported by exactly two roots, `prog/samples/agent-probe.prog:9` and
`prog/samples/self-extend-probe.prog:13`. `prog/scriba/chat.chiral:3` names
`agent/agent.chiral` in a comment and its import list at `:21-24` reaches
`prapanca/chatter/turn` instead, so no shipping program holds the coding turn.

## What is missing, and its structure

| group | owns |
|---|---|
| G1 tool-as-value | a tool's identity and its declared parameter schema as one value, so a call decodes to an arm of a closed sum. `docs/definitions/pattern-boundary-sums.md` carries the standing directive this group cashes: retype a which-of-N classification as a closed sum at the boundary, and `dispatch-tool`'s four-way `str-eq` chain is the `Str` tag that directive names |
| G2 the grant read | the declared `Expert.tools` list read at both altitudes: rendered into the assembled prompt so the model knows its set, and checked at dispatch so an ungranted call yields a refusal value. [[permission-model]] states why one alone is theater: a guard on the command must lower into constraints on the access it entails |
| G3 the tool step | a `Flow` node that fires a tool, and the `Ty` its result carries, so a coding turn is a tree the engine walks |
| G4 the record | the tool call recorded, so a coding turn emits a `RunManifest` and `manifest-all-green?` can read that turn's health |
| G5 the guard | `overflow-guard` reached on the path a tool result grows, so a turn that outgrows `num_ctx` is bounded by something other than a step count |
| G6 the gate | a phase that fails when a coding turn breaks |

### The edges that run against the order

| edge | direction | what crosses |
|---|---|---|
| G3 to G5 | against | `stop.chiral` is the most primitive module in this arc: 30 lines, importing only `prelude/prelude`, both defs `->`. The ordering puts it last and its input is the largest and latest thing the run produces, the size of a tool result. Built bottom-up, the guard lands with nothing to measure |
| G3 to G1 and G2 | against | the seam types the tool result, and what a tool may return depends on which tool ran, which is the grant's business. `Ty` at `prog/prapanca/core/flow.chiral:42`, `Shape` at `prog/prapanca/core/flow.chiral:46` and `Arrow` at `prog/prapanca/core/flow.chiral:71` sit below both, the three arms of the shape sum name no bytes, and `ty-eq` at `prog/prapanca/core/flow.chiral:77` compares names only. So `read` returning file contents and `bash` returning stdout can share a `Ty` name today and disagree in shape with nothing to say so |
| G6 to G1 | against | the gate is last in the order and is the precondition for observing any group before it. `prog/samples/agent-probe.prog:11-17` runs a full tool-call turn now and returns `0` unconditionally, and no `prog/agent/` or `prog/prapanca/` path is named by any `tools/test/*.sh`. Until G6 lands, every requirement below is checked by reading source instead of by running anything |

## REQUIREMENTS

1. **A tool is a value the type system names.** Observed at
   `prog/agent/agent.chiral:361-374`: the `str-eq` chain over four literal names
   becomes a `case` over a closed sum, and a grep for `str-eq` inside the
   dispatch path returns zero. The count that moves is the tool constructor
   count, zero today.
2. **The `Expert.tools` grant is read, at both altitudes.** Observed as a read
   count moving from zero across the seven bind sites listed above. The
   assembled prompt (`prog/prapanca/core/assemble.chiral:48-57`) names the granted
   tools, and a call to a tool outside the grant yields a value the caller cases
   instead of executing.
3. **A coding turn is more than one node in the engine.** Observed twice:
   `prog/agent/agent.chiral`'s import list at `:17-20` names a path under
   `prog/prapanca/`, and `flow-ty` (`prog/prapanca/core/flow.chiral:212`) returns
   `some` over the turn's `Flow`, whose node count is greater than one. Today
   the turn is the single recursion at `:410-438`.
4. **A coding turn emits a `RunManifest`.** Observed as a root that prints or
   writes a manifest whose `ExpertCall` list (`prog/prapanca/core/types.chiral:131`)
   is non-empty and names the tools fired. Today the turn returns `(Pair Str Str)`
   at `prog/agent/agent.chiral:410`.
5. **`overflow-guard` has a caller on the path a tool result grows.** Observed
   as `grep -rn 'overflow-guard' lib prog` returning a hit outside
   `prog/prapanca/core/stop.chiral`. It returns zero such hits today.
6. **A gate fails when a coding turn breaks.** Observed as a phase in
   `tools/test/run-tests.sh` naming a root that drives a coding turn and
   comparing its exit code against a stated contract. Today
   `grep -rn 'prog/agent\|prog/prapanca' tools/test/` returns zero, and
   `prog/samples/agent-probe.prog:17` returns `0` unconditionally.

The shape condition in [[goals/coding-agent]] governs every row below: no
route, rank or selection may assume a float. No row here introduces a score.
The one arithmetic this arc reaches is `overflow-guard`'s chars/4 estimate,
which is integer already and says so in its own header at
`prog/prapanca/core/stop.chiral:2-7`.

## Roster

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `coding-turn/A1` | a tool as a closed sum: the arm a call decodes to, carrying the tool's name and its declared parameter schema, so the four inline `Json` schemas at `prog/agent/agent.chiral:99-147` are derived from the value instead of written beside it | G1 | primitive | new | 1 | designed | `unminted` |
| `coding-turn/A2` | the four built tools reached through the `A1` value: `fs-read` (`tools-fs.chiral:50`), `fs-write` (`:62`), `fs-edit` (`:88`) and `ag-bash` (`agent.chiral:60`) dispatched by `case` over the sum, replacing the `str-eq` chain at `agent.chiral:361-374` | G1 | primitive | bind | 1 | open | `unminted` |
| `coding-turn/A3` | `assemble-prompt` (`assemble.chiral:48-57`) renders the granted tool names into the prompt it already binds `tools` to build, so the section count moves from six to seven | G2 | primitive | bind | 2 | open | `unminted` |
| `coding-turn/A4` | the grant checked at the one dispatch point, an ungranted call yielding a typed refusal the caller cases, the shape `bind-config` already takes with `bind-miss` at `bind.chiral:52-69` | G2 | law | connect | 1, 2 | open | `unminted` |
| `coding-turn/A5` | a `Flow` node that fires a tool, so a step of a coding turn is a node in the engine's tree, with `flow-ty` (`flow.chiral:212`) staying total over the widened sum | G3 | primitive | new | 3 | open | `unminted` |
| `coding-turn/A6` | the `Ty` a tool result carries and what `refine-ok` (`flow.chiral:355`) accepts for it, settled against `Shape`'s three arms (`flow.chiral:46`) and `ty-eq`'s name-only equality (`:77`) | G3 | decision | new | 3 | open | `unminted` |
| `coding-turn/A7` | the tool call recorded in `RunManifest` (`types.chiral:166`), carrying which tool fired and whether the grant admitted it, so `manifest-all-green?` (`flow.chiral:1422`) reads a coding turn | G4 | primitive | connect | 4 | open | `unminted` |
| `coding-turn/A8` | `overflow-guard` (`stop.chiral:20`) called where a tool result enters the next prompt, so a turn is bounded by the window and not only by the step budget at `agent.chiral:411` | G5 | law | connect | 5 | open | `unminted` |
| `coding-turn/A9` | a phase running a coding-turn root against a stated exit contract, the treatment `transport/T2` to `T4` gave the five transport roots, reusing `transport.sh`'s DEFER ruling for the endpoint it needs | G6 | tool | connect | 6 | open | `unminted` |
| `coding-turn/A10` | the tool call decoded into an arm carrying its typed arguments, so `arg-get` (`prog/agent/agent.chiral:306`) leaves the four `do-*` bodies. Opened 2026-09-08 by `coding-turn/A1`'s design, §5 decision 1: the enumeration `tools-json` folds over needs a nullary kind, so the decoded call is a second value | G1 | primitive | new | 1 | open | `unminted` |

### Coverage

Run 2026-09-08 against the table above.

- **Every requirement is served.** 1 by `A1`, `A2`, `A4` and `A10`; 2 by `A3`
  and `A4`; 3 by `A5` and `A6`; 4 by `A7`; 5 by `A8`; 6 by `A9`. No requirement
  is unscheduled.
- **Every row serves a requirement.** All ten name at least one. No row is out
  of scope.
- **Every `origin` is defensible.** Six rows are `bind` or `connect`, which is
  what a tree this built should produce. The three `new` rows carry the burden:
  - `A1` is `new` because nothing in this tree types a tool. `PureFn`
    (`flow.chiral:119-138`) is a closed sum of six pure string transforms that
    cross nothing, and `builder.chiral`'s `tool-builder-flow` (`:77-78`) builds
    a `Flow` value a model emitted. Neither names a tool.
  - `A5` is `new` because none of `Flow`'s seven constructors
    (`flow.chiral:140-153`) executes a tool: `flow-step` makes one model call
    and `flow-pure` applies a `PureFn`.
  - `A6` is `new` as a decision. `Ty` and `Shape` exist and `refine-ok` runs,
    and no arm of `Shape` covers what a tool returns, so the row settles a shape
    instead of binding a built one.

### What this arc does not take

- **Condition 2, Routes.** The `Pipeline` record's `stop` field is discarded at
  `prog/prapanca/pipeline/plan.chiral:49-50`, and reading it is named in
  [[goals/coding-agent]] condition 2's own done clause. No pipeline in
  `prog/prapanca/profile/` names a file operation, so routing a coding request has
  nothing to route to; that is condition 2 as well. Selecting a tool set by
  model size is a selection under the shape condition and belongs there.
- **Condition 3, Features.** E148 and the directory enumeration under it, and
  `lib/text/matcher.chiral`'s 602 unconsumed lines.
- **Condition 4, Keybinds.** `agent-run` reachable from a binding. This arc
  leaves the coding turn reachable from a `.prog` root, which is where
  `prog/samples/agent-probe.prog:9` already has it.
- **[[arcs/unit-lane-arc]]'s claim on the same types.** `unit-lane/N27`, `N28`
  and `N29` reuse `Expert`/`Flow`/`Skill`, `RunManifest` and `SkillEntry` for
  the neuron lane, under that arc's requirement 5 and its `E196-E239` band. The
  rows here touch the same three types for the deliberative layer: `A5` widens
  `Flow`'s constructor sum, `A7` extends what a `RunManifest` records, and no
  row here touches `Skill` or `SkillEntry`. The overlap is `Flow` and
  `RunManifest`, and the split is the lane.
- **[[arcs/transport-arc]]'s gate.** `A9` reuses Phase 20's shape and takes a
  root transport left out: `prog/samples/agent-probe.prog` is listed in that
  arc's own root table as "beyond the four below", so no transport requirement
  covers it.

## Resume state

Opened 2026-09-08 against `docs/goals/coding-agent.md`, committed the same day.
Ten rows. `A1` is **designed** (`docs/arcs/parts/coding-turn-A1.md`, 2026-09-08),
and the next stage on it is `pipeline-audit` at DESIGN level, then the mint. Its
design takes a SPEC rather than `direct`: four shapes were weighed and three
rejected with measured reasons.

`A10` was opened by that design, §5 decision 1, and is the only row this arc
gained after opening. The nine others are untouched.

`A1` was the row to design first because `A2`, `A4` and `A5` each carry the value
it defines, and the two back-edges that inform `A6` and `A8` both run into it.

Every measurement above was taken against the working tree on 2026-09-08 and
each cites its own `file:line`. Three counts hold this arc's premise and every
one is zero: reads of `Expert.tools`, `Flow` constructors that execute a tool,
and `tools/test/*.sh` references to `prog/agent/` or `prog/prapanca/`.

**NEEDS-AUTHOR-1.** Verbatim: "Condition 1 names three counts and its done
clause takes two. Does requirement 5, `overflow-guard` reached, gate this arc's
completion, or is it carried here and left ungated?" The row is not written to
`records/author-calls.md`, because this run writes the arc file and the
`docs/arcs/README.md` row and nothing else.

⚑ **`docs/goals/coding-agent.md`'s Arcs section reads `none open`, and
`docs/goals/README.md` records the same.** Both are stale as of this file.
Neither is in this run's write scope.
