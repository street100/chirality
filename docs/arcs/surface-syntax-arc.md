---
node: arc-surface-syntax
layer: navigation
related: [arcs/README, goals/readable-surface, arcs/file-types-arc, arcs/diagnostics-arc, syntax-evolution, design-principles, modules-core, status-ledger, decisions/decision-lane-split, decisions/decision-work-ids, decisions/decision-scope, elements/catalog, records/homing-triage, records/lenses/unspoken, index]
status: current
updated: 2026-09-14
---

# Arc: surface-syntax

- goals: [[goals/readable-surface]], condition 4: "**Regularity holds at the
  surface.** One shape, one meaning. Observed on the three current instances:
  file kinds, syntax and the error vocabulary."
- reserved element block: **none**. One row carries `E49`, minted long before
  this file, and the other three carry arc-local ids per
  [[decisions/decision-work-ids]] spelling the letters `SY`, for surface syntax:
  `surface-syntax/SY1` upward. A grep for `SY` followed by a digit over `docs/`
  and `records/` returns nothing, verified 2026-09-14; the five hits under
  `.planning/` are `[SY16]`, a bibliography key inside the pinned
  `.planning/sources/RFC9771.txt`. The
  two-letter form follows `terminal`'s `TM` and `syscall-custody`'s `SC`, and
  `S` was already spelled by [[arcs/scriba-arc]] and [[arcs/module-split-arc]].
- build-state authority: [[status-ledger]]
- checklist: none. No `records/surface-syntax.md` exists.
- siblings: [[arcs/file-types-arc]] holds the file-kinds instance of the same
  condition and [[arcs/diagnostics-arc]] holds the error-vocabulary instance.
  This arc holds the third, syntax, which the condition names and neither
  sibling states.

## Why this arc exists

Condition 4 names three instances and schedules two. The goal file gives
`[[arcs/file-types-arc]]` for the kinds and `[[arcs/diagnostics-arc]]` for the
vocabulary, and it gives the middle word, syntax, to nobody.
[[records/homing-triage]] measured `E49` as held by no roster and proposed this
arc; the author approved opening it 2026-09-14.

The condition's test is one shape, one meaning. Over time that reads as
[[syntax-evolution]] already states it: *"the same syntax must keep the same
meaning across versions, or a reader's recognition is worth less each release."*
That note reserves two occupied slots against a future break and nothing in
`lib/`, `prog/` or `tools/` checks either reservation. Beside it the tree calls
its own surface a scaffold while 198 files are written in it, and no tracked
document says what the surface it is a scaffold for would be.

**The ownership check was run before this arc claimed anything.** No file in
`docs/arcs/` names `E49`, verified 2026-09-14 by grep over the whole directory.
[[records/lenses/unspoken]] `UNS-14` records the same measurement on 2026-09-05
under the title *"E49 is unbuilt and no arc names it"*. The nearest claim is
`file-types/K3`, which holds `E190`, and §What this arc does not take draws that
boundary.

## What the tree already holds

Measured 2026-09-14 against the working tree. [[banks/INDEX]] holds thirteen and
[[banks/text]] owns the payload side of this territory, a payload plus a way to
name a part of it plus total functions between those. None of it is re-derived
below.

| group | what exists today | where | rung |
|---|---|---|---|
| G1 the fork | the evolution rule for the surface the tree has: additive forms are safe, an occupied slot must have its final shape reserved while it holds one inhabitant | `docs/definitions/syntax-evolution.md:20-29` | DESIGNED |
| G1 | reservation one, the quantity slot. `0/1/w` is declared the usage projection of a grade whose other factors default, and `(q x Ty)` the one-factor special case | `docs/definitions/syntax-evolution.md:40-51` | DESIGNED |
| G1 | reservation two, the arrow. `=>` is declared the default widest effect label and a labeled form a refinement of it | `docs/definitions/syntax-evolution.md:60-66` | DESIGNED |
| G1 | the losslessness law the two reservations serve: a surface rendering *"may not drop linearity, capabilities, or effects, or it becomes an ungoverned path"* | `docs/modules/modules-core.md:77-79` | DESIGNED |
| G1 | the co-gate, stated in the note's own words: implicit arguments land in the same reserved binder slot, so the shape is designed *"together with the grade-vector binder (Fork A) and the checker's inference story (stage 4)"* | `docs/definitions/syntax-evolution.md:86-88` | DESIGNED |
| G1 | ⚑ **no tracked file states that stage 4 is a different notation at all.** `docs/elements/catalog.md:179` records the live state as *"scaffold s-expr surface only"* and `docs/definitions/syntax-evolution.md` governs the evolution of that same s-expr surface. Graduated against replaced is unstated | measured 2026-09-14 | absent |
| G2 the inventory | the reader: a byte-directed S-expression reader over four `Sexp` formers, with line, column, depth and last-opened-form on a failure | `lib/surface/sexp.chiral`, 315 lines, 47 defs, positions at `:137`, `:151`, `:164` | IMPLEMENTED |
| G2 | the recognizer: `Sexp` to `Surf`, ten expression heads under one `cond`, plus the do-bind | `lib/surface/parse.chiral:181-190`, `:108`, 1,466 lines, 81 defs | IMPLEMENTED |
| G2 | the toplevel vocabulary: ten heads plus a named refusal for an eleventh | `lib/surface/parse.chiral:1276-1303` | IMPLEMENTED |
| G2 | ⚑ **that vocabulary grew by two and the archived scope note still reads eight.** `module` and `end-module` landed with E161 and are dispatched at `:1292` and `:1294`. `.planning/archive/audit/family-7-design-edges-b.md:564` lists the invariant toplevel set as `import/data/declare/def/porttype/extern/target/profile` | `lib/surface/parse.chiral:1292`, `:1294` | IMPLEMENTED |
| G2 | ⚑ **no form inventory exists.** The archived design named it the buildable-now artifact, *"every construct ... × every corpus exemplar file:line × its kernel elaboration"*, and a `find` over `docs/` and `.planning/` returns no such table | `.planning/archive/audit/family-7-design-edges-b.md:598-600` | absent |
| G3 the second surface | the elaborator the new surface must feed unchanged: name to de Bruijn, arrow, lam, let, case, do, cond, the, refine, and the profile and target verify | `lib/surface/surface.chiral`, 321 lines, 30 defs | IMPLEMENTED |
| G3 | the core the two surfaces would share: sixteen `Term` formers over de Bruijn indices, with `Qty` on the binder and `Seat` on the arrow | `lib/surface/syntax.chiral:12`, `:18-34` | ENFORCED |
| G3 | the written direction, and its output is chirality source: 30 `pp-` bindings, all sixteen `Term` arms, no `_` arm | `lib/surface/pretty.chiral`, 399 lines, gate phase 18 | ENFORCED |
| G3 | ⚑ **the quantity is one scalar and the effect is one bit, which is what the two reservations are about.** `is-quant` admits `0`, `1` and `w` and yields an `I64`; the arrow is parsed at two heads and carries `s-pure` or `s-proc` | `lib/surface/parse.chiral:55`, `:182-183`, `lib/surface/syntax.chiral:12` | IMPLEMENTED |
| G3 | ⚑ **nothing checks either reservation.** A grep for `grade-vector`, `grade vector`, `usage projection` and `widest effect` over `lib/`, `prog/` and `tools/` returns nothing. Every hit is prose under `docs/` | measured 2026-09-14 | absent |
| G3 | the two elements the fork is co-gated with, both minted, both `design`, both held by no roster: `E38` the cost grading and `E39` the surface effect algebra | `docs/elements/ledger.md`, `records/homing-triage.md:263`, `:268` | DESIGNED |
| G4 the judge | the corpus the judge would run over: 198 `.chiral` files under `lib/` and `prog/`, plus 9 `.port` files | measured 2026-09-14 | n/a |
| G4 | the composite verdict a diff would read: the loader threads a kernel `Sig` and an `SEnv` through the toplevel loop, and each installed item grows both | `lib/surface/parse.chiral:1276-1310` | IMPLEMENTED |
| G4 | the four verbs the CLI has | `bin/chirality:211-214`, `compile`, `run`, `check`, `test` | ENFORCED |
| G4 | ⚑ **no verb loads one file through two front-ends**, and `tools/test/run-tests.sh` registers no phase that compares two surfaces | measured 2026-09-14 | absent |
| G5 the record | ⚑ **three tracked claims describe the live surface as provisional and one names a file that is gone.** `lib/surface/sexp.chiral:4-5` reads *"sexp.py stays the bootstrap reader AND the differential oracle until the front end (E2/E49) switches"*, and `find . -name 'sexp.py'` returns nothing | `docs/elements/catalog.md:179`, `records/conformance-map.md:178`, `lib/surface/sexp.chiral:4` | SEEDED |

Three facts from that table govern the roster. **The surface stack is built and
self-hosted**, so no row here writes a reader, a recognizer or an elaborator.
**The reservations are prose with no instrument**, which is the gap the condition
reaches. **The fork sits above everything else**: `E49`'s own archived design
refuses to sketch a grammar on the ground that inventing surface syntax is the
one thing the design stage may not do, so the ruling comes before the parser.

## What is missing, and its structure

| group | owns |
|---|---|
| G1 the fork | what stage 4 is. The s-expr surface graduated with its reservations honored, or a second notation over the same core. The ruling restates the two reservations and the losslessness law as constraints on whatever it picks |
| G2 the inventory | every form the surface expresses today, its corpus exemplar and its kernel elaboration, in one table tied to the recognizer so a new head without a row fails |
| G3 the second surface | the grammar and the front-end that reads it, feeding `elab` unchanged. `E49` |
| G4 the judge | two front-ends, one `Sig`, diffed over the corpus as a named phase, with the s-expr side golden until the author retires it |
| G5 the record | the tree stops describing its only surface as a scaffold for something unnamed, or names it |

### The edges that run against the order

| edge | direction | what crosses |
|---|---|---|
| G4 to G3 | against, and the loudest | the judge is buildable with one front-end. Its golden side is the surface every file is already written in, and its diff is a `Sig` comparison over names. Ordering it after G3 reads as build the grammar and then check it, which is the order that ships an unjudged grammar. The archived design calls the harness G3's acceptance test, so the acceptance test can exist first |
| G2 to G1 | against | the fork is answerable only against what the surface expresses, and the inventory is that. G1 gates G3 and G2 feeds G1, so the inventory sits below a decision it supplies |
| G1 to outside the arc | out | the binder slot is co-gated with `E38` and the arrow with `E39`. `docs/definitions/syntax-evolution.md:86-88` states it: deciding stage-4 syntax before Fork A's binder shape re-occupies the reserved slot. Both elements are `design` and both are held by no roster, so the gate on this arc's first row sits on work nothing schedules |
| G5 to G1 | against | the stale claims are wrong under one arm of the fork and true-until-retired under the other, so the record cannot be repaired before the ruling. It is listed last and depends on the first |

## REQUIREMENTS

Five, each with the observation beside it, measured 2026-09-14.

1. **Stage 4 is ruled before a grammar is written.** Observed as a file under
   `docs/decisions/` naming the choice, the s-expr surface graduated or a second
   notation, and restating the two reservations
   (`docs/definitions/syntax-evolution.md:40`, `:60`) and the losslessness law
   (`docs/modules/modules-core.md:77`) as constraints on it. Today no such file
   exists and `docs/elements/catalog.md:179` states the live position as
   *"scaffold s-expr surface only"*.

2. **Every form the recognizer admits has one tracked row, and a form added
   without one fails.** Observed as a table whose row count equals the head
   count in `lib/surface/parse.chiral`, checked by an instrument. Measured
   today: ten expression heads at `:181-190`, the do-bind at `:108`, and ten
   toplevel heads at `:1276-1303`. No table exists.

3. **Two surfaces agree on one core over the whole corpus.** Observed as a named
   phase in `tools/test/run-tests.sh` that loads each of the 198 `.chiral` files
   under `lib/` and `prog/` through both front-ends and fails on any difference
   in the resulting `Sig`. Today `bin/chirality` has four verbs
   (`bin/chirality:211-214`) and none of them loads a file twice.

4. **The two reserved slots survive whatever the grammar becomes.** Observed as
   fixtures: a `(0 A (type 0))`, a `(1 x Ty)`, a `(w p Ty)` and a `=>` arrow
   yielding the same `Qty` and the same `Seat` under both front-ends. Today the
   reservation is prose and the grep for its four phrases over `lib/`, `prog/`
   and `tools/` returns nothing.

5. **No tracked file calls the live surface a scaffold while it is the only
   surface.** Observed by grep. Today three do, `docs/elements/catalog.md:179`,
   `records/conformance-map.md:178` and `lib/surface/sexp.chiral:4`, and the
   last names `sexp.py`, which `find` no longer returns.

## Roster

Four rows. One carries `E49`, minted long before this file and homed by no
roster until now; three are connective and carry arc-local ids. Ids spell `SY`.
**This arc mints nothing and allocates no number.**

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `surface-syntax/SY1` | the stage-4 fork ruled and written down: the s-expr surface graduated with its two reservations honored, or a second notation over the same core, with the reservations and the losslessness law restated as constraints on whichever arm wins. The ruling also settles the three stale claims of G5, which are wrong under one arm and true-until-retired under the other. **Blocking condition**: `E38`'s binder shape and `E39`'s effect row. `docs/definitions/syntax-evolution.md:86-88` states that deciding stage-4 syntax first re-occupies the reserved slot, and both elements are `design` and held by no roster | G1, G5 | decision | new | 1, 5 | open | `unminted` |
| `surface-syntax/SY2` | the form inventory: every head `lib/surface/parse.chiral` admits, its corpus exemplar at `file:line`, and its kernel elaboration, in one table an instrument checks against the recognizer. The forms exist and the table does not, and the archived design names this the buildable-now artifact. **Blocking condition**: none measured. Nothing external gates this row | G2 | tool | bind | 2 | open | `unminted` |
| `surface-syntax/SY3` | real surface syntax, stage 4: the concrete syntax and the front-end that reads it, producing the same `Surf` that `lib/surface/surface.chiral` already elaborates, so nothing below `elab`'s outputs moves. The kernel term language, the toplevel vocabulary, the binder quantities and the effect bit are the invariant set it may not shrink. **Blocking condition**: `SY1`, because the grammar is the thing that ruling picks | G3 | primitive | new | 3, 4 | open | `E49` |
| `surface-syntax/SY4` | the judge: one file loaded through both front-ends, the two `Sig`s diffed over globals, types and profiles, run over the 198 `.chiral` files as a registered phase, with the s-expr side golden until the author retires it. Both halves it joins are built, the loader's `Sig` threading at `lib/surface/parse.chiral:1276-1310` and the corpus itself. **Blocking condition**: none for the harness. Its second front-end is `SY3`, and until that lands the harness runs one surface against itself, which is what makes it the acceptance test | G4 | law | connect | 3, 4 | open | `unminted` |

### Coverage

Run 2026-09-14 against the table above.

- **Every requirement is served.** 1 and 5 by `SY1`, 2 by `SY2`, 3 and 4 by
  `SY3` and `SY4`. No requirement is unscheduled.
- **Every row serves a requirement.** All four name at least one. No row is out
  of scope.
- **Every `origin` is defensible from the measurement.**
  - `SY1` is `new` because no tracked file states the fork. The note that
    governs the surface governs the evolution of the one the tree has, and the
    graduated-against-replaced question appears in no `docs/decisions/` file.
  - `SY2` is `bind` because the forms exist and the inventory does not. Twenty
    one heads are dispatched across `lib/surface/parse.chiral:108`, `:181-190`
    and `:1276-1303`, and nothing surfaces them as data.
  - `SY3` is `new` because the surface it names has no line in the tree. The
    existing front-end is the thing it stands beside.
  - `SY4` is `connect` because both halves are built: the `Sig` the loop threads
    is live at `lib/surface/parse.chiral:1276-1310`, and the corpus the diff
    runs over is 198 files that compile today. The join is the missing step.
- **Three rows read `unminted` and one reads `E49`.** `E49` carries ledger state
  `design` (`docs/elements/ledger.md:93`) with no design artifact at
  `docs/arcs/parts/surface-syntax-SY3.md`, no SPEC under
  `docs/elements/specs/` and no worked example, so the roster state is `open`:
  the number is held and the pipeline is owed.

## What this arc does not take

- **`<name>.m.gram`, the surface syntax as a declared signature.**
  [[arcs/file-types-arc]] rosters `E190` as `file-types/K3` and its requirement
  6 owns it. The boundary is which question each answers: `E190` asks whether a
  grammar can be a declared kind the reader is derived from, and its own catalog
  cell records that it is a new registry adding a judgment in all but name.
  `E49` asks what the grammar says. A ruling on `SY1` is an input to `E190` and
  neither row is the other. **No row of that arc is edited by this run.**
- **The error vocabulary.** [[arcs/diagnostics-arc]] holds the third instance of
  condition 4 and rosters `E157`, `E158`, `E174`, `E175`, `E181` and `E182`. The
  two arcs meet at `lib/surface/pretty.chiral`, which that arc built as
  `diagnostics/T1` and this one reads as the written direction of the surface.
  This arc writes no printer.
- **Position-bearing parse refusals.** `docs/elements/catalog.md:433` measures
  `E101`'s residue: the reader half is built and `parse.chiral`'s `p-err` still
  carries a bare string with no position at `:244-247`, `:261-270`, `:294` and
  `:331-333`. That is condition 1 of the same goal, a diagnostic telling the
  reader what to do, and `E101` is `built` with the residue recorded on its own
  cell. This arc adds no row for it.
- **The round-trip law `parse(source(t)) == t`.** [[arcs/file-types-arc]] states
  in its own words that the law is `E146`'s row and cannot be `E181`'s, because
  a `surface/pretty` to `module/loader` edge closes a cycle. This arc's judge
  compares two front-ends over source and asserts nothing about the printer.
- **The grade vector and the effect row themselves.** `E38` and `E39` are the
  co-gate on `SY1` and neither is this arc's work.
  [[records/homing-triage]] questions E and F put both to the author and both
  stand unanswered. This arc cites the gate and rosters neither element.
- **Repairing the catalog, the ledger and the conformance map.**
  Requirement 5 is what `SY1` buys and this run edits none of the three files.

## Resume state

Opened 2026-09-14 against [[goals/readable-surface]] condition 4, on the
author's approval of the `surface-syntax` proposal in
[[records/homing-triage]]. Four rows, five requirements, nothing designed. Rows
spell `SY`. The one element on the roster was minted long before this file and
this run mints nothing.

**The row to take up first is `SY2`.** It turns on no open call, its artifact is
an extraction from files already enumerated here, and it is the input `SY1`
needs to be answerable. `SY4` is the second for the same reason: its harness
half is buildable against one front-end and it becomes `SY3`'s acceptance test
the moment a second surface exists.

⚑ **The stage-4 fork is an author call and this run does not take it.** No row
in [[records/author-calls]] carries it, so there is nothing to quote. The
question, in the archived design's own words
(`.planning/archive/audit/family-7-design-edges-b.md:551-558`): *"What does NOT
exist: any decision that stage 4 is a different notation at all, vs the s-expr
surface graduated (reservations honored, additive forms landed, elaborator
self-hosted per E2). The tension is real and unowned ... That is an author
decision; name it, don't decide it."* `SY1` is the row that carries it and the
arc names it here rather than answering it.

⚑ **This arc is unanchored on `arc -> goal done-condition`.**
`docs/goals/readable-surface.md` condition 4 names `[[arcs/file-types-arc]]` and
`[[arcs/diagnostics-arc]]` and no third arc, so `tools/lens/lens.py chain`
reports this file in that rung's uncovered set. Three arcs on one condition
follows the condition's own three instances. The goal file is outside this run's
write scope and the edit is owed.

⚑ **`E49` carries a `records/lenses/unspoken.md` row and homing it moves no
count.** `UNS-14` admits the element under `docs/goals/README.md:27`, and
`ledger-lint` check AE excludes an element an unspoken row admits. The owed
count moves for elements with no such row, so this arc's roster row changes the
`catalog element -> arc roster row` rung and leaves `element homes owed` where
it was. `UNS-14` is now false as written, *"no file in docs/arcs/ names E49"*,
and `records/` is outside this run's write scope.

**What was measured before any row's state was written.** `E49` has no SPEC
under `docs/elements/specs/`, no file under `docs/examples/`, and no design
artifact under `docs/arcs/parts/`, checked 2026-09-14. Its catalog cell
(`docs/elements/catalog.md:179`) and its ledger row
(`docs/elements/ledger.md:93`) agree on `design`, and the tree agrees with both:
the surface is s-expressions everywhere and no second front-end exists. The
citation `supersedes sexp.py` that both the catalog's inspiration row and
`records/conformance-map.md:146` carry is stale in a direction that shrinks
nothing: `sexp.py` is gone, the self-hosted reader took its place at
`lib/surface/sexp.chiral`, and what `E49` supersedes is now a chirality file
inside the compiler blob.
