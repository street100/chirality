---
node: arc-coding-turn
layer: navigation
related: [arcs/README, goals/coding-agent, banks/unit, banks/capability, permission-model, status-ledger, decisions/decision-work-ids, decisions/decision-design-before-mint, decisions/decision-part-layout, decisions/decision-orchestration-boundary, decisions/decision-tool-capability, arcs/transport-arc, arcs/tool-authority-arc, arcs/unit-lane-arc, records/coding-turn, index]
status: current
updated: 2026-09-09
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
- checklist: [[records/coding-turn]], prefix `CT`.

## Why this arc exists

The engine and the coding agent are two working halves in one tree and neither
reaches the other. `prog/prapanca/` is 9,990 lines, 7,741 of them `.chiral`, and
no file in it executes a tool. `prog/shilpa/turn.chiral` is 452 lines that run
a whole tool-call turn against a live endpoint and import nothing from the
engine, a choice its own header states at `:11-15`. The condition asks for one
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

⚑ **`prog/shilpa/` carries no row in [[status-ledger]], `records/conformance-map.md`
or `docs/elements/catalog.md`.** A grep for `prog/shilpa` across all three
returns zero. The rungs below are this arc's reading against the ledger's own
four definitions, and for that subtree they rest on no prior row.

| group | what exists today | where | rung |
|---|---|---|---|
| G1 tool-as-value | four tool schemas built inline as `Json`, and a dispatch that is a `str-eq` chain over four literal names | `prog/shilpa/turn.chiral:99-147`, `:361-374` | IMPLEMENTED |
| G1 | the four native tools themselves, 96 lines plus one crossing | `prog/shilpa/tools-fs.chiral:50`, `:62`, `:88`; `ag-bash` at `prog/shilpa/turn.chiral:60` over `raw-proc-spawn`/`wait` | IMPLEMENTED |
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
| G3 | the coding turn as it runs today: one recursion on a step budget, importing prelude, http, json and tools-fs and nothing under `prog/prapanca/` | `prog/shilpa/turn.chiral:17-20`, `:410-438`, choice stated at `:11-15` | IMPLEMENTED |
| G4 the record | `ExpertCall`, `RawCall`, `RunManifest`, and `manifest-all-green?` reading a run's health off values | `types.chiral:131`, `:152`, `:166`; `flow.chiral:1422` | SEEDED |
| G4 | what the coding turn returns instead: `(Pair Str Str)`, answer and transcript, with no manifest, no gate and no linear `Backend` | `prog/shilpa/turn.chiral:410`, `:440-452` | IMPLEMENTED |
| G5 the guard | `stop.chiral` is 30 lines and both its defs are `->`: `overflow-guard`, an integer chars/4 estimate against `num_ctx`, and `stop-policy`, a `"sharpen"`/`"example"` substring match. Neither has a caller outside the file | `prog/prapanca/core/stop.chiral:20`, `:25` | SEEDED |
| G5 | the only bound on a coding turn today: an integer step budget decremented once per turn | `prog/shilpa/turn.chiral:411`, `:428`, `:434` | IMPLEMENTED |
| G6 the gate | Phase 20 compiles five roots under `prog/samples/`, runs each and judges it against the exit code its own header states, deferring the two that need the endpoint under a recorded ruling | `tools/test/transport.sh:165-194`, `tools/test/run-tests.sh:305-326` | ENFORCED |
| G6 | no `prog/shilpa/` or `prog/prapanca/` path appears in any `tools/test/*.sh`. Phase 7 sweeps every root carrying `compile-main`, compiles it and runs none | `tools/test/run-tests.sh:172-180` | SEEDED |
| G6 | `shilpa-probe.prog` drives a full `agent-run` tool-call turn and its `compile-main` returns `0` whatever came back | `prog/samples/shilpa-probe.prog:11-17` | SEEDED |
| G6 | no `*.golden.json` exists in the tree, and two conform roots name an absent path under a directory the 2026-08-31 migration removed | `prog/samples/prapanca-run-conform.prog:66`, `prog/samples/prapanca-flow-conform.prog:71` | SEEDED |

Two facts from that table govern the roster. `stop-policy` decides a retry by
matching `"sharpen"` and `"example"` in an expert id, which answers a
doc-refine question and no coding-turn question, so this arc takes
`overflow-guard` and leaves `stop-policy` where it is. And `prog/shilpa/turn.chiral`
is imported by exactly two roots, `prog/samples/shilpa-probe.prog:9` and
`prog/samples/self-extend-probe.prog:13`. `prog/scriba/chat.chiral:3` names
`shilpa/turn.chiral` in a comment and its import list at `:21-24` reaches
`prapanca/chatter/turn` instead, so no shipping program holds the coding turn.

## What is missing, and its structure

| group | owns |
|---|---|
| G1 tool-as-value | a tool's identity and its declared parameter schema as one value, so a call decodes to an arm of a closed sum. `docs/definitions/pattern-boundary-sums.md` carries the standing directive this group cashes: retype a which-of-N classification as a closed sum at the boundary, and `dispatch-tool`'s four-way `str-eq` chain is the `Str` tag that directive names |
| G2 the grant read | the declared `Expert.tools` list read at both altitudes: rendered into the assembled prompt so the model knows its set, and checked at dispatch so an ungranted call yields a refusal value. [[permission-model]] states why one alone is theater: a guard on the command must lower into constraints on the access it entails |
| G3 the tool step | a `Flow` leaf that fires a crossing, and the `Ty` its result carries, so a coding turn is a tree the engine walks. The crossing is a parameter of the node: [[decisions/decision-orchestration-boundary]] §4 forbids `prog/prapanca/` naming the tool vocabulary that resolves it |
| G4 the record | the crossing recorded, so a coding turn emits a `RunManifest` and `manifest-all-green?` can read that turn's health. `RunManifest` is pinned to the golden's 15 keys, so the record is threaded beside it on the `RawCall` precedent |
| G5 the guard | `overflow-guard` reached on the path a tool result grows, so a turn that outgrows `num_ctx` is bounded by something other than a step count |
| G6 the gate | a phase that fails when a coding turn breaks |

### The edges that run against the order

| edge | direction | what crosses |
|---|---|---|
| G3 to G5 | against | `stop.chiral` is the most primitive module in this arc: 30 lines, importing only `prelude/prelude`, both defs `->`. The ordering puts it last and its input is the largest and latest thing the run produces, the size of a tool result. Built bottom-up, the guard lands with nothing to measure |
| G3 to G1 and G2 | against | the seam types the tool result, and what a tool may return depends on which tool ran, which is the grant's business. `Ty` at `prog/prapanca/core/flow.chiral:42`, `Shape` at `prog/prapanca/core/flow.chiral:46` and `Arrow` at `prog/prapanca/core/flow.chiral:71` sit below both, the three arms of the shape sum name no bytes, and `ty-eq` at `prog/prapanca/core/flow.chiral:77` compares names only. So `fs-read` returning file contents and `fs-write` returning a status can share a `Ty` name today and disagree in shape with nothing to say so |
| G6 to G1 | against | the gate is last in the order and is the precondition for observing any group before it. `prog/samples/shilpa-probe.prog:11-17` runs a full tool-call turn now and returns `0` unconditionally, and no `prog/shilpa/` or `prog/prapanca/` path is named by any `tools/test/*.sh`. Until G6 lands, every requirement below is checked by reading source instead of by running anything |

## Where these rows land

[[decisions/decision-part-layout]], decided 2026-09-09, names five parts under
`prog/` and places the tool layer. Three of its facts govern every row below,
each re-measured 2026-09-09.

- **`prog/indriya/` is the tool layer and it is absent.** `ls prog/` returns no
  such directory. That decision's §3 table names `coding-turn/A1` as the row the
  tool vocabulary comes from, so the G1 rows land in a directory nothing
  occupies and their first commit creates it.
- **Prapañca must not name a consumer.**
  [[decisions/decision-orchestration-boundary]] §4 states the direction and
  measures the one live violation, `prog/prapanca/pipeline/compose.chiral:18-19`.
  A `Flow` node carrying indriya's tool vocabulary would be a second one, so the
  G3 and G4 rows carry the crossing abstractly and resolve it outside.
- **`bash` is out of the goal toolset**, ruled by the author 2026-09-09
  ([[decisions/decision-part-layout]] §5 statement 3). `ag-bash`
  (`prog/shilpa/turn.chiral:60`), its `raw-proc-spawn`/`wait` re-declaration and
  the `SpawnErr`/`Reap`/`Child`/`SpawnRes`/`ExitStatus` scaffolding (`:23-47`),
  `do-bash` (`:351-359`), `dispatch-tool`'s fourth `str-eq` (`:371-374`) and the
  schema entry (`:145-146`) all go, and `prog/samples/shilpa-probe.prog` is a
  root whose whole prompt forces a bash tool_call (`:3-6`, `:15`).

⚑ **The E100 seam reason has lapsed.** `prog/shilpa/turn.chiral:11-15` states
that `be-chat` is not used, so no `map-list` crosses the seam. `map-list` is
live at `prog/prapanca/backend.chiral:85`, inside `chat-body` (`:79-86`), which
`be-chat` (`:116`) calls in its body. The seam the header declines to cross is
crossed by the function it points at. Measured 2026-09-09, and `A12` carries the
consequence.

⚑ **This file cited that header passage as `:12-16` at two sites and the lines
are `:11-15`.** [[decisions/decision-part-layout]] §5 assigns the repoint here.
Corrected 2026-09-09.

## REQUIREMENTS

1. **A tool is a value the type system names.** Observed at
   `prog/shilpa/turn.chiral:361-374`: the `str-eq` chain over four literal names
   becomes a `case` over a closed sum, and a grep for `str-eq` inside the
   dispatch path returns zero. The count that moves is the tool constructor
   count, zero today.
2. **The `Expert.tools` grant is read, at both altitudes.** Observed as a read
   count moving from zero across the seven bind sites listed above. The
   assembled prompt (`prog/prapanca/core/assemble.chiral:48-57`) names the granted
   tools, and a call to a tool outside the grant yields a value the caller cases
   instead of executing.
3. **A coding turn is more than one node in the engine.** Observed twice:
   `prog/shilpa/turn.chiral`'s import list at `:17-20` names a path under
   `prog/prapanca/`, and `flow-ty` (`prog/prapanca/core/flow.chiral:212`) returns
   `some` over the turn's `Flow`, whose node count is greater than one. Today
   the turn is the single recursion at `:410-438`.
4. **A coding turn emits a `RunManifest`.** Observed as a root that prints or
   writes a manifest whose `ExpertCall` list (`prog/prapanca/core/types.chiral:131`)
   is non-empty and names the tools fired. Today the turn returns `(Pair Str Str)`
   at `prog/shilpa/turn.chiral:410`.
5. **`overflow-guard` has a caller on the path a tool result grows.** Observed
   as `grep -rn 'overflow-guard' lib prog` returning a hit outside
   `prog/prapanca/core/stop.chiral`. It returns zero such hits today.
6. **A gate fails when a coding turn breaks.** Observed as a phase in
   `tools/test/run-tests.sh` naming a root that drives a coding turn and
   comparing its exit code against a stated contract. Today
   `grep -rn 'prog/shilpa\|prog/prapanca' tools/test/` returns zero, and
   `prog/samples/shilpa-probe.prog:17` returns `0` unconditionally.

The shape condition in [[goals/coding-agent]] governs every row below: no
route, rank or selection may assume a float. No row here introduces a score.
The one arithmetic this arc reaches is `overflow-guard`'s chars/4 estimate,
which is integer already and says so in its own header at
`prog/prapanca/core/stop.chiral:2-7`.

## Roster

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `coding-turn/A1` | a tool as a closed sum: the arm a call decodes to, carrying the tool's name and its declared parameter schema, so the four inline `Json` schemas at `prog/shilpa/turn.chiral:99-147` are derived from the value instead of written beside it. Lands in `prog/indriya/`, the home [[decisions/decision-part-layout]] §3 gives the tool vocabulary, and enumerates the three tools the `bash` ruling leaves. **Its design is owed a revisit against the same trigger.** `docs/arcs/parts/coding-turn-A1.md:241` puts the value in `prog/shilpa/tool.chiral` so that `coding-turn/A5` can see `Tool` from `prog/prapanca/core/flow.chiral`, which is the import direction [[decisions/decision-orchestration-boundary]] §4 forbids, and its §6 catalog row spells a `t-bash` arm | G1 | primitive | new | 1 | designed | `unminted` |
| `coding-turn/A2` | the built tools reached through the `A1` value: `fs-read` (`tools-fs.chiral:50`), `fs-write` (`:62`) and `fs-edit` (`:88`) dispatched by `case` over the sum, replacing the `str-eq` chain at `turn.chiral:361-374`. `ag-bash` is absent from the list because `A13` deletes it. This dispatch is also what resolves `A5`'s leaf id, so the resolver needs no row of its own | G1 | primitive | bind | 1 | open | `unminted` |
| `coding-turn/A3` | `assemble-prompt` (`assemble.chiral:48-57`) renders the granted set into the prompt it already binds `tools` to build, so the section count moves from six to seven. The obligation survives `tool-authority/TA10`: a model reads a set and cannot case a capability, so whatever carrier the grant takes has to reach the prompt as text. `TA10` picks the carrier and this row renders it. `Expert` stays a `prog/prapanca/` shape ([[decisions/decision-orchestration-boundary]] §1), so rendering its own field names no consumer | G2 | primitive | bind | 2 | open | `unminted` |
| `coding-turn/A4` | the grant checked at the one dispatch point, an ungranted call yielding a typed refusal the caller cases, the shape `bind-config` already takes with `bind-miss` at `bind.chiral:52-69`. **The row is in-process accounting and says so.** [[decisions/decision-tool-capability]] §5 measures that a module reaches naming authority by writing one `extern` line, so a check inside a dispatcher records a refusal where a process boundary would enforce one. `tool-authority/TA10` owns the grant once enforcement is that boundary, and the two stand together. The dispatch point is `prog/indriya/`'s after `A2` | G2 | law | connect | 1, 2 | open | `unminted` |
| `coding-turn/A5` | a `Flow` leaf that fires an effectful crossing, named by an id and carrying its arrow, on the `flow-step` precedent at `flow.chiral:141`, which names an expert by `(expert-id Str)` and holds no `Expert`. What the id resolves to stays outside `prog/prapanca/`, so the engine gains a node a granted step can be and names no consumer. `flow-ty` (`flow.chiral:212`) stays total over the widened sum | G3 | primitive | new | 3 | open | `unminted` |
| `coding-turn/A6` | the `Ty` a crossing's result carries and what `refine-ok` (`flow.chiral:355`) accepts for it, settled against `Shape`'s three arms (`flow.chiral:46`) and `ty-eq`'s name-only equality (`:77`). One port-result type declared in `prog/prapanca/`, with which crossing carries which assigned outside it. The row opened on `read` and `bash` sharing a `Ty` name and disagreeing in shape; `bash` is out, and the live pair is `fs-read` returning file contents (`tools-fs.chiral:50`) against `fs-write` returning a status (`:62`) | G3 | decision | new | 3 | open | `unminted` |
| `coding-turn/A7` | the crossing recorded, so `manifest-all-green?` (`flow.chiral:1422`) reads a coding turn's health off values. Two constraints the row did not carry. `RunManifest` (`types.chiral:166`) is pinned field-for-field to the golden's 15 top-level keys (`types.chiral:154-160`) and `E141` (`docs/elements/catalog.md:247`) is the conformance that reads it back, so a new field is a golden change. And the record must name no consumer. `RawCall` (`types.chiral:152`) is the in-tree answer to both: a second carrier threaded beside the manifest, leaving the round-trip schema untouched | G4 | primitive | connect | 4 | open | `unminted` |
| `coding-turn/A8` | `overflow-guard` (`stop.chiral:20`) called where a tool result enters the next prompt, so a turn is bounded by the window and not only by the step budget at `turn.chiral:411`. The caller sits in the consumer prog and `overflow-guard` stays in `prog/prapanca/`, which is the direction [[decisions/decision-orchestration-boundary]] §4 allows | G5 | law | connect | 5 | open | `unminted` |
| `coding-turn/A9` | a phase running a coding-turn root against a stated exit contract, the treatment `transport/T2` to `T4` gave the five transport roots, reusing `transport.sh`'s DEFER ruling for the endpoint it needs. The root it would have used does not survive `A13`: `prog/samples/shilpa-probe.prog:3-6` states a prompt whose whole job is to force a bash tool_call, and `:15` is that prompt. The row carries a replacement root driving a surviving tool | G6 | tool | connect | 6 | open | `unminted` |
| `coding-turn/A10` | the tool call decoded into an arm carrying its typed arguments, so `arg-get` (`prog/shilpa/turn.chiral:306`) leaves the four `do-*` bodies. Opened 2026-09-08 by `coding-turn/A1`'s design, §5 decision 1: the enumeration `tools-json` folds over needs a nullary kind, so the decoded call is a second value. Lands in `prog/indriya/` beside `A1` and drops the `bash` arm with it | G1 | primitive | new | 1 | open | `unminted` |
| `coding-turn/A11` | the tool-call wire protocol as `prog/indriya/`'s: the `tools` array on a request (`prog/shilpa/turn.chiral:201`) and `tool_calls` read back (`:167`, `:241`). Those three code sites are the only ones in the tree, verified 2026-09-09 by a grep over `.chiral` and `.prog` returning them and five comments. `chat-body` (`prog/prapanca/backend.chiral:79-86`) builds a body with no `tools` key, so `A12` has no way to send a tool call until this lands. Opened 2026-09-09 by [[decisions/decision-part-layout]] §5 statement 1 | G1 | primitive | new | 1, 3 | open | `unminted` |
| `coding-turn/A12` | the duplicated transport deleted. `prog/shilpa/turn.chiral` builds its own request body over `http-request` and `json.chiral`, and the reason its header gives at `:11-15` has lapsed, measured above. The turn reaches the endpoint through `be-chat` (`prog/prapanca/backend.chiral:116`), which is requirement 3's first observable: an import list naming a path under `prog/prapanca/`. Opened 2026-09-09 by [[decisions/decision-part-layout]] §5 statement 2 | G3 | primitive | connect | 3 | open | `unminted` |
| `coding-turn/A13` | `ag-bash` deleted with everything holding it up, enumerated under `Where these rows land`. No design replaces it: the author ruled 2026-09-09 that the goal toolset excludes `bash`. Closing this row makes `tool-authority/TA8`'s condition false, since that row reads the supplied descriptor set as decorative while the child holds a shell (`docs/arcs/tool-authority-arc.md:200`). Opened 2026-09-09 by [[decisions/decision-part-layout]] §5 statement 3 | G1 | primitive | new | 1, 6 | open | `unminted` |

### Coverage

Re-run 2026-09-09 against the table above, thirteen rows.

- **Every requirement is served.** 1 by `A1`, `A2`, `A4`, `A10`, `A11` and
  `A13`; 2 by `A3` and `A4`; 3 by `A5`, `A6`, `A11` and `A12`; 4 by `A7`; 5 by
  `A8`; 6 by `A9` and `A13`. No requirement is unscheduled.
- **Every row serves a requirement.** All thirteen name at least one.
- **Every `origin` is defensible.** Seven rows are `bind` or `connect`. Six are
  `new`, and three of the six are the rows opened 2026-09-09:
  - `A1` is `new` because nothing in this tree types a tool. `PureFn`
    (`flow.chiral:129-138`) is a closed sum of six pure string transforms that
    cross nothing, and `builder.chiral`'s `tool-builder-flow` (`:77-78`) builds
    a `Flow` value a model emitted. Neither names a tool.
  - `A5` is `new` because none of `Flow`'s seven constructors
    (`flow.chiral:140-153`) fires a crossing: `flow-step` makes one model call
    and `flow-pure` applies a `PureFn`. Its shape is `flow-step`'s, and what is
    absent is the constructor.
  - `A6` is `new` as a decision. `Ty` and `Shape` exist and `refine-ok` runs,
    and no arm of `Shape` covers what a crossing returns, so the row settles a
    shape instead of binding a built one.
  - `A11` is `new` because the three wire sites are written inline in a consumer
    and no module holds them as a piece another consumer could take.
  - `A13` is `new` as a deletion. It removes rather than builds, which no other
    row here does.
- **Three overlaps with [[arcs/tool-authority-arc]] are resolved**, the
  resolution that arc left to this one at `docs/arcs/tool-authority-arc.md:247-262`.
  `A4` survives beside `TA10` as accounting where `TA10` is enforcement. `A3`
  survives beside `TA10` as the render, because a model reads a set and cannot
  case a capability. `A2` and `TA8` stop overlapping outright: author call 1 was
  ruled, `A2` loses its fourth arm to `A13`, and `TA8`'s child gets a descriptor
  set worth stating.

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
  leaves the coding turn reachable from a `.prog` root. That root is
  `prog/samples/shilpa-probe.prog:9` today and `A13` deletes it, so `A9` carries
  the replacement.
- **[[arcs/unit-lane-arc]]'s claim on the same types.** `unit-lane/N27`, `N28`
  and `N29` reuse `Expert`/`Flow`/`Skill`, `RunManifest` and `SkillEntry` for
  the neuron lane, under that arc's requirement 5 and its `E196-E239` band. The
  rows here touch the same three types for the deliberative layer: `A5` widens
  `Flow`'s constructor sum, `A7` records a crossing beside a `RunManifest`
  without changing its 15 keys, and no row here touches `Skill` or
  `SkillEntry`. The overlap is `Flow` and `RunManifest`, and the split is the
  lane.
- **[[arcs/transport-arc]]'s gate.** `A9` reuses Phase 20's shape and takes a
  root transport left out: `prog/samples/shilpa-probe.prog` is listed in that
  arc's own root table as "beyond the four below", so no transport requirement
  covers it. `A13` deletes that root and `A9` states its replacement, which
  changes no transport requirement either.

## Resume state

Opened 2026-09-08 against `docs/goals/coding-agent.md`, committed the same day.
Thirteen rows. `A1` is **designed** (`docs/arcs/parts/coding-turn-A1.md`,
2026-09-08). Its design takes a SPEC rather than `direct`: four shapes were
weighed and three rejected with measured reasons.

**The next stage on `A1` is a revisit of its design, before `pipeline-audit`.**
Two of that design's settled decisions were taken against ground that moved on
2026-09-09. §5 decision 2 places the value in `prog/shilpa/tool.chiral` and
argues the placement by `coding-turn/A5` needing `Tool` visible from
`prog/prapanca/core/flow.chiral`, which is the import
[[decisions/decision-orchestration-boundary]] §4 forbids and which `A5`'s
rescoped shape no longer asks for. §6's catalog row spells the sum as
`(t-read) (t-write) (t-edit) (t-bash)`, and `bash` is out. Auditing that design
as it stands would mint a value into the wrong prog with an arm the author
ruled away.

`A10` was opened 2026-09-08 by that design, §5 decision 1. `A11`, `A12` and
`A13` were opened 2026-09-09 by [[decisions/decision-part-layout]] §5, one per
statement.

`A1` was the row to design first because `A2`, `A4` and `A5` each carry the
value it defines, and the two back-edges that inform `A6` and `A8` both run into
it.

Every measurement in this file was taken against the working tree on 2026-09-08
or, where a row cites 2026-09-09, on that day. Three counts hold this arc's
premise and every one was still zero on 2026-09-09: reads of `Expert.tools`,
`Flow` constructors that fire a crossing, and `tools/test/*.sh` references to
`prog/shilpa/` or `prog/prapanca/`.

**NEEDS-AUTHOR-1.** Verbatim: "Condition 1 names three counts and its done
clause takes two. Does requirement 5, `overflow-guard` reached, gate this arc's
completion, or is it carried here and left ungated?" The row is not written to
`records/author-calls.md`, because this run writes the arc file and the
`docs/arcs/README.md` row and nothing else.

⚑ **`docs/goals/coding-agent.md`'s Arcs section reads `none open`, and
`docs/goals/README.md` records the same.** Both are stale as of this file.
Neither is in this run's write scope.
