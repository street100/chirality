---
row: coding-turn/A1
arc: coding-turn
title: a tool as a closed sum: the arm a call decodes to, carrying the tool's name and its declared parameter schema, so the four inline `Json` schemas at `prog/shilpa/turn.chiral:99-147` are derived from the value instead of written beside it
kind: primitive
origin: new
req: 1
status: draft
updated: 2026-09-08
---

# coding-turn/A1: a tool as a closed sum

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** a tool's identity and its declared parameter schema become one
  value of a closed sum in `prog/shilpa/`, so the array of tool schemas the model
  is sent is a total function over that sum's arms, and a tool name arriving
  from the wire is decoded into an arm once at the boundary.
- **Serves:** requirement 1 of [[arcs/coding-turn-arc]], "**A tool is a value the
  type system names.** Observed at `prog/shilpa/turn.chiral:361-374`: the
  `str-eq` chain over four literal names becomes a `case` over a closed sum, and
  a grep for `str-eq` inside the dispatch path returns zero. The count that
  moves is the tool constructor count, zero today."
- **Goal:** [[goals/coding-agent]], condition 1, "A coding turn is decomposed
  across the engine rather than run as one loop, and each step holds only the
  tools it was granted."
- **The standing directive this row cashes:** [[pattern-boundary-sums]], author
  2026-08-09, "apply this as much as physically possible". A boundary that
  classifies an op name, a request kind or a verdict is retyped as a closed sum
  and never left as a `Str` tag; an audit may treat a string where a sum belongs
  as a finding. `dispatch-tool` is that boundary and the tool name is that tag.
  This row does not re-derive the directive.

## 2. What the tree holds

Measured 2026-09-08 against the working tree.

**Bank:** [[banks/unit]], the refraction of "the agent / the model call / the
LLM chain" into nineteen shards. Four shards touch this row and none of them is
a tool.

- **Shard A**, the unit itself, is the `Expert` record at
  `prog/prapanca/core/types.chiral:66-68`, whose `tools` field is the least-privilege
  grant declared at `:64-65`. It is a `(List Str)`, so the grant spells tool
  names in the same untyped currency the dispatch does.
- **Shard B** is the payload type, `Ty` at `prog/prapanca/core/flow.chiral:42`,
  `Shape` at `:46` and `ShField` at `:47`. The bank's own row records that
  `ty-eq` at `:77` compares by name alone, so two `Ty` values with one name and
  different `Shape` are indistinguishable below it.
- **Shard R** is persistence: `purefn->json` at
  `prog/prapanca/core/flow-persist.chiral:110` renders a closed sum totally into
  `Json`, and `json->purefn` at `:167` reads it back. This is the tree's own
  precedent for deriving JSON from a sum's arms.
- **Shard S** is the self-extension wall, `prog/prapanca/core/builder.chiral`.
  `accept-gate` at `:43` decodes a model's emitted text and runs `flow-ty` over
  it before admitting it to the skill library; `tool-builder-flow` at `:77` and
  `tool-builder-author` at `:61` are the pipeline that authors one. It type-checks
  a new `Flow` a model emitted. It builds no tool schema and it executes no tool,
  so this row is elsewhere.

[[banks/capability]] owns the grant half. This row leaves it alone: reading the
grant is `coding-turn/A3` and `A4`.

### The census

| what exists | where | rung | reached by |
|---|---|---|---|
| the four tool schemas, built inline as `Json` through six helpers ending in `tools-json` | `prog/shilpa/turn.chiral:99-147`, defs `:101-147` | IMPLEMENTED | `request-body` at `:195` on every model call |
| `dispatch-tool`, a nested `str-eq` chain over the four literal names `"read"`, `"write"`, `"edit"`, `"bash"`, falling through to `(str-cat "error: unknown tool " name)` | `prog/shilpa/turn.chiral:361-374` | IMPLEMENTED | `loop` at `:409` |
| `tc-line`, a **second** `str-eq` chain over the same four names, for the transcript label | `prog/shilpa/turn.chiral:389-403` | IMPLEMENTED | `loop` at `:409` |
| the parsed call, carrying its arguments as an un-decoded JSON string | `prog/shilpa/turn.chiral:276`, `(data Call () (call (id Str) (name Str) (args Str)))` | IMPLEMENTED | `parse-turn` at `:285` |
| `arg-get`, re-parsing that string once per argument at each use | `prog/shilpa/turn.chiral:306` | IMPLEMENTED | the four `do-*` at `:322`, `:329`, `:339`, `:352`, and `arg-or` at `:383` |
| the four native tools themselves | `prog/shilpa/tools-fs.chiral:50`, `:62`, `:88`; `ag-bash` at `prog/shilpa/turn.chiral:61` over the `raw-proc-spawn`/`wait` crossings at `:46-47` | IMPLEMENTED | `dispatch-tool` |
| `PureFn`, a closed sum of six deterministic string transforms, each arm carrying its own typed arguments | `prog/prapanca/core/flow.chiral:129-137` | SEEDED | `run-pure` at `:456`, cased exhaustively; `flow-pure` and `flow-branch-pure` arms of `Flow` at `:140-153` |
| `Shape`, three arms, and the seam check that decides a payload against one | `Shape` at `prog/prapanca/core/flow.chiral:46`, `shape-ok-json` at `:328`, `shape-ok` at `:349`, `refine-ok` at `:355` | SEEDED | `run-pipeline` through the seam check |
| `Expert.tools`, the grant, a `(List Str)` | `prog/prapanca/core/types.chiral:64-65`, record at `:66-68` | SEEDED | bound at seven destructuring sites, read at zero |
| the grant's own spelling of the vocabulary: **26 occurrences of `(cons "read" nil)`** across `prog/prapanca/profile/` and `prog/prapanca/core/builder.chiral:67`, over 30 declared experts. `"read"` is the only tool name any expert is granted | `prog/prapanca/profile/code-test.chiral:50`, `:65`, `:74`, `:89` and 22 more | SEEDED | nothing reads it |
| the agent's stated import boundary: `prog/shilpa/turn.chiral` imports `prelude/prelude`, `protocol/http`, `protocol/json` and `shilpa/tools-fs`, and its header states the refusal to reach `prog/prapanca/` and why | `prog/shilpa/turn.chiral:11-15`, imports at `:17-20` | IMPLEMENTED | two roots, `prog/samples/shilpa-probe.prog:9` and `prog/samples/self-extend-probe.prog:13` |

### Three measurements that decide §4

1. **No tool sum exists anywhere.** `grep -rn '(data Tool' prog lib` returns
   zero. The constructor count requirement 1 names is zero, confirmed.
2. **`Shape` has no primitive-type arm and its record arm is unread.**
   `sh-prose` at `prog/prapanca/core/flow.chiral:46` is documented at `:43-44` as
   "the genuinely opaque case (any text is a valid value)", which is a statement
   about a payload. The four schemas each declare the JSON type `"string"`
   separately at `prog/shilpa/turn.chiral:103`. And `shape-ok-json`'s record arm at
   `prog/prapanca/core/flow.chiral:339` reads `((sh-rec fs) (case j ((j-obj kvs) true) (_ false)))`:
   it binds the field list and discards it, checking only that the payload is an
   object. `Shape` carries no per-field description and no `required` list, and
   the schemas at `prog/shilpa/turn.chiral:107-124` need both.
3. **Reaching `Shape` from `prog/shilpa/` costs the whole prapanca core.**
   `Shape` lives in `prog/prapanca/core/flow.chiral`, whose imports at `:22-30`
   include `prapanca/core/types`, `prapanca/core/bind`, `prapanca/backend` (the linear
   `Backend` porttype at `prog/prapanca/backend.chiral:32`) and
   `prapanca/pipeline/runner`. `prog/shilpa/turn.chiral:11-15` states the choice not
   to reach `prog/prapanca/` and names the E100 residual as the reason. Importing
   `Shape` imports the whole prapanca core and its linear porttype into the agent
   blob.

## 3. The delta

Real, and it is one vocabulary spelled in five independent places with nothing
tying them.

The four tool names and their parameter names exist today as string literals at:

- the schema array the model is sent, `prog/shilpa/turn.chiral:136-146`, where
  each name and each parameter name is written once;
- the `do-*` bodies, `:322-359`, where each parameter name is written **a second
  time** as an `arg-get` key. `do-write`'s `"path"` and `"content"` at `:331` and
  `:334` are the same two strings as `params2`'s arguments at `:139-140`, and
  nothing relates them;
- `dispatch-tool`'s `str-eq` chain, `:362-374`;
- `tc-line`'s `str-eq` chain, `:389-403`, which additionally re-picks each tool's
  one meaningful parameter name by hand;
- the grant, 26 `(List Str)` sites carrying `"read"`.

Adding a fifth tool means editing four of those five places, and the compiler
refuses none of the omissions. That is exactly the drift
[[pattern-boundary-sums]] describes at its §"The test": a `Str` encoding
which-of-N is a sum wearing a disguise, and information present at point A
re-derived at point B belongs in a constructor field.

`PureFn` at `prog/prapanca/core/flow.chiral:129-137` is the closest existing shape
and it is **not coverage**. Every one of its six arms is a pure string transform
applied by `run-pure` at `:456`; no arm crosses the membrane, none names a file
or a process, and `Expert.tools` goes unread anywhere near it. It is the
tree's answer to "a step as a value" and it is the form a tool sum would rhyme
with, which is a precedent and not a build.

**Verdict:** a real delta. Nothing in the tree types a tool.

**Not in this row.** Dispatching through the value is `coding-turn/A2`. Reading
the grant is `A3` and `A4`. A `Flow` node that fires a tool is `A5`, the `Ty` a
result carries is `A6`. This row defines the value those rows consume.

## 4. The shapes

The tree does not settle this. Four forms were tested and the choice turns on one
structural fact §2 surfaced: **a tool kind and a tool call are different values.**
The schema array at `prog/shilpa/turn.chiral:134` enumerates *kinds*, one entry
per tool, with no arguments in hand. `dispatch-tool` at `:362` decodes a *call*,
which has arguments and no enumeration. A shape that conflates them cannot do
both jobs.

### Shape A: the kind as a nullary closed sum, its declared parameters as data

- **Form:** `(data Tool () (t-read) (t-write) (t-edit) (t-bash))` beside
  `(data ToolParam () (tparam (name Str) (desc Str)))`. Four total functions off
  the sum: `tool-name`, `tool-desc`, `tool-params`. One enumeration,
  `all-tools : (List Tool)`. One boundary decoder,
  `tool-of-name : (-> Str (Maybe Tool))`. `tools-json` becomes a fold of
  `tool->json` over `all-tools`, on the `purefn->json` precedent at
  `prog/prapanca/core/flow-persist.chiral:110`.
- **Costs:** the arguments stay an un-decoded `Str` past the boundary, so
  `arg-get` at `prog/shilpa/turn.chiral:306` survives this row; what changes is
  that its key comes off `tool-params` instead of a literal. The `"type":"string"`
  fact moves into `prop-str`'s single writing rather than into the type.
- **Forbids:** a tool with a non-string parameter, and a tool absent from the
  sum. Both are wanted. All four tools declare every parameter `"string"` today
  (`prog/shilpa/turn.chiral:103`), and a tool the type system does not name is
  precisely what requirement 1 refuses.
- **Buys:** coverage is checked, so `dispatch-tool` and `tc-line` collapse into
  two exhaustive `case`s over one sum and a fifth tool breaks both at check time.
  The schema is a function of the value, so the model's declared vocabulary and
  the dispatch's accepted vocabulary cannot disagree.
- **Consequence beyond this row, one line:** a schema that is a value makes
  emitting a `json_schema` / `response_format` constraint to the backend
  mechanical. That is a backend change, and it stays outside this row.

### Shape B: the call as a closed sum, arms carrying decoded arguments

- **Form:** `(data Tool () (t-read (path Str)) (t-write (path Str) (content Str)) (t-edit (path Str) (needle Str) (repl Str)) (t-bash (command Str)))`,
  the `PureFn` shape at `prog/prapanca/core/flow.chiral:129-137` copied exactly.
- **Costs:** it cannot be enumerated. `all-tools`, which `tools-json` folds over,
  needs one inhabitant per arm, and `(t-write ? ?)` has none without fabricated
  strings. So the schema array needs either a second type that *is* the kind, or
  a value invented to be discarded. Either way the row's own defect returns: two
  vocabularies that can drift. The language has no term-level reflection over
  constructor field names, so the parameter names cannot be recovered from the
  arm.
- **Forbids:** the same set as A, plus a call reaching dispatch with a missing
  argument, which is a genuine gain and belongs to whoever decodes the call.
- **Rejected here, and it survives elsewhere.** It is the right shape for the
  *decoded call*, a different value from the one this row defines. §5 disposes
  it.

### Shape C: a record of name plus a schema expressed as the existing `Shape`

- **Form:** `(data Tool () (tool (name Str) (params Shape)))`, reusing `Shape` at
  `prog/prapanca/core/flow.chiral:46` and its `sh-rec` arm as the record of named
  fields.
- **Costs, measured in §2:** `Shape` carries no per-field description, and all
  eight descriptions at `prog/shilpa/turn.chiral:136-146` are prose the model
  reads; it carries no `required` list, which every one of the four schemas emits
  at `:109`, `:115` and `:123`; and `sh-prose` is an opaque-payload marker
  (`prog/prapanca/core/flow.chiral:43-44`), where each schema declares the JSON
  `"string"` type at `:103`. Its own validator discards the field list
  (`prog/prapanca/core/flow.chiral:339`). The import cost is decisive: `Shape` drags
  `prapanca/core/types`, `prapanca/core/bind`, `prapanca/backend`'s linear porttype and
  `prapanca/pipeline/runner` (`prog/prapanca/core/flow.chiral:22-30`) into a blob whose
  own header refuses `prog/prapanca/` for a stated reason (`prog/shilpa/turn.chiral:11-15`).
- **Forbids:** nothing this row wants forbidden. It is an open record, so the
  name stays a `Str` and `dispatch-tool` keeps its chain.
- **Rejected.** It pays the largest import cost in the set to reach a type that
  expresses less than the four schemas already state.

### Shape D: a dispatch sum only, the four inline `Json` schemas left standing

- **Form:** the sum of Shape A, cased in `dispatch-tool`, with
  `prog/shilpa/turn.chiral:99-147` untouched.
- **Costs:** cheapest by a wide margin, and it leaves the schema and the dispatch
  as two vocabularies that can drift, which is the defect the row's own text
  names. A tool added to the sum and forgotten in `tools-json` compiles clean and
  is never offered to the model.
- **Forbids:** an unnamed tool at dispatch, and nothing else.
- **Rejected.** It fails the row's stated purpose, and [[pattern-boundary-sums]]
  §"Live precedents" names the half-done retype as the thing not to leave
  standing.

## 5. The call

- **Chosen: Shape A.** It is the only form that serves both jobs the vocabulary
  has. The schema array needs an enumeration of kinds and Shape B has none;
  the schema needs descriptions, `required` and a string-type marker, and Shape C
  carries none of the three at an import cost the agent's header already refused;
  Shape D leaves the drift the row exists to close. Shape A makes `tools-json` a
  total function over `all-tools`, on the `purefn->json` precedent at
  `prog/prapanca/core/flow-persist.chiral:110`, and makes the accepted name set and
  the offered name set one value.

| # | Question | Disposition | Rationale / owner |
|---|---|---|---|
| 1 | Does the sum carry the decoded arguments? | RESOLVED, no | The enumeration `all-tools` that `tools-json` folds over needs one inhabitant per arm, and an arm carrying `(path Str)` has none without a fabricated value. §4 Shape B. The decoded-call carrier is a second value; no roster row in [[arcs/coding-turn-arc]] owns it, and a design run does not edit the arc. **A row is owed and this design would open it**: `coding-turn/A10`, "the tool call decoded into an arm carrying its typed arguments, so `arg-get` (`prog/shilpa/turn.chiral:306`) leaves the `do-*` bodies", group G1, serving requirement 1. |
| 2 | Where does the value live? | RESOLVED | A new leaf module `prog/shilpa/tool.chiral` importing `prelude/prelude` and `protocol/json` only. `prog/shilpa/turn.chiral:11-15` refuses `prog/prapanca/` imports, so the value cannot live under `prog/prapanca/core/`; and `prog/prapanca/core/flow.chiral:25` already imports `protocol/json`, so a leaf over prelude and json is importable from either side without a new crossing. `coding-turn/A5` needs `Tool` visible from `prog/prapanca/core/flow.chiral`, and this placement is the one that admits it. |
| 3 | Does `tc-line` collapse in this row or in `coding-turn/A2`? | RESOLVED, this row | `A2`'s text claims `dispatch-tool` at `prog/shilpa/turn.chiral:361-374` and nothing else. `tc-line` at `:389-403` executes no tool: it reads a name and a parameter name, which is exactly what this row's value carries, and it is `->` where `dispatch-tool` is `=>`, so it consumes the sum at no effect cost. Leaving a second `str-eq` chain over the sum's own vocabulary standing is the finding [[pattern-boundary-sums]] describes. A design audit that disagrees moves it to `A2`, and the value is unchanged either way. |
| 4 | Does the `(List Str)` grant at `prog/prapanca/core/types.chiral:64-65` become `(List Tool)`? | DEFERRED to `coding-turn/A3` and `coding-turn/A4` | Both rows exist in [[arcs/coding-turn-arc]]'s roster. Retyping the grant is reading the grant, which is requirement 2. This row leaves all 26 sites alone. |
| 5 | Does a schema-as-value emit `json_schema` / `response_format` to the backend? | DEFERRED, out of arc | A backend change. It is a consequence of Shape A, recorded in §4 as one line, and no row in this arc owns it. |

No NEEDS-AUTHOR. [[arcs/coding-turn-arc]]'s one open author call, `NEEDS-AUTHOR-1`,
is about requirement 5 and `overflow-guard`, and does not touch requirement 1.

## 6. The mint packet

- **Elements: one.** The sum, its accessors, its enumeration, its boundary
  decoder and the `tools-json` derivation constrain each other: splitting the
  schema derivation from the sum recreates the two-vocabulary defect this row
  exists to close, which is §4's Shape D. `coding-turn/A2` is the separate
  element that dispatches through the value.
- **Band:** `UNASSIGNED`. [[arcs/coding-turn-arc]] reserves no block, and per
  author call B, ruled 2026-09-06, a band is advisory: an arc without one mints
  the next number free tree-wide. Measured 2026-09-08, the highest number in
  `docs/elements/catalog.md` is E197. The mint assigns the next free number, and
  this design names none.
- **Catalog row**, on the live five-column header at `docs/elements/catalog.md:90`:

  `| E<NN> | **A tool as a closed sum** — `(data Tool () (t-read) (t-write) (t-edit) (t-bash))` in a new `prog/shilpa/tool.chiral`, with `tool-name` / `tool-desc` / `tool-params` total off the sum, `all-tools` the enumeration, and `tool-of-name : (-> Str (Maybe Tool))` the boundary decode. `tools-json` becomes a fold of `tool->json` over `all-tools`, so the schema array the model is sent is a function of the value. | Not built — the tool constructor count is zero (`grep -rn '(data Tool' prog lib` returns zero, 2026-09-08). The vocabulary is spelled in five unrelated places today: the schema array (`prog/shilpa/turn.chiral:136-146`), the `arg-get` keys in the four `do-*` (`:322-359`), `dispatch-tool`'s `str-eq` chain (`:361-374`), `tc-line`'s second chain (`:389-403`), and 26 `(List Str)` grant sites under `prog/prapanca/profile/`. | `OURS`; [[pattern-boundary-sums]], the standing 2026-08-09 directive; the in-tree precedents are the closed `Op` sum (E70), `PureFn` (`prog/prapanca/core/flow.chiral:129-137`) and its total codec `purefn->json` (`prog/prapanca/core/flow-persist.chiral:110`) (`IMPL`) | SH |`

- **Ledger row**, on the header at `docs/elements/ledger.md:78`:

  `| E<NN> | agent-tool | design | A tool as a closed sum: the arm a call decodes to, carrying name and declared parameter schema | SH |`

- **Size:** two files touched.
  - **New**, `prog/shilpa/tool.chiral`, **90 to 120 lines**. Basis: two data
    declarations, four total functions over a four-arm sum, one enumeration, one
    decoder, and one `Json` renderer. The comparable is `purefn->json` plus
    `json->purefn` at `prog/prapanca/core/flow-persist.chiral:110-190`, roughly 80
    lines for a six-arm sum with richer fields, in a file of 414 lines.
  - **Edited**, `prog/shilpa/turn.chiral`, net **-30 to -40 lines**. `prop-str`,
    `params1`, `params2`, `params3`, `fn-obj`, `tool-obj` and `tools-json` at
    `:101-147` are 47 lines and leave; `tc-line` at `:389-403` is 15 lines and
    becomes about 5; one import is added. `fld1` through `fld4` and `solo` at
    `:80-97` stay: the message builders at `:153-199` use all five.
  - `prog/shilpa/tools-fs.chiral` is untouched. Nothing under `prog/prapanca/` is
    touched: the grant is `coding-turn/A3` and `A4`.
- **Track:** SH.
- **Next step:** `pipeline-audit` at DESIGN level, then the mint. The row takes a
  **SPEC**: §4 weighed four shapes and rejected three with measured reasons, so
  the tree does not settle the form and the row is not `direct`.
- **Related:** [[arcs/coding-turn-arc]], [[goals/coding-agent]],
  [[pattern-boundary-sums]], [[banks/unit]], [[banks/capability]],
  [[decisions/decision-design-before-mint]], [[decisions/decision-work-ids]].
