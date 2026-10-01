---
node: arc-errors-as-values
layer: navigation
related: [arcs/README, goals/readable-surface, arcs/diagnostics-arc, pattern-boundary-sums, banks/effect-and-alarm, status-ledger, index]
status: current
updated: 2026-10-01
---

# Arc: errors-as-values

- goals: [[goals/readable-surface]], condition 2: "**The convenient way is the
  safe way.** Where a check is conservative and taxes safe code, that is
  recorded as a debt against this goal rather than absorbed silently by the
  person writing the code." Second: condition 1, "**A diagnostic tells the
  reader what to do**, beyond that something failed and where." Third, from
  2026-10-01: [[goals/enforcement]] conditions 1 and 2, through the
  [[bug-classes]] rows whose `owner` cell names this arc.
- reserved element block: `none`. `E184-E189` is spent (`E189` was the last free
  number and landed 2026-09-08, [[working-discipline]] §A capability the
  substrate lacks is a finding), `E190-E195` is [[arcs/file-types-arc]]'s,
  `E196-E239` the unit lane's, `E240-E259` is shared by three arcs and
  `E260-E263` is [[arcs/text-tools-arc]]'s. Rows here carry arc-local ids
  `EV1`-`EV12` per [[decisions/decision-work-ids]]. `EV` is free tree-wide.
- build-state authority: [[status-ledger]]
- checklist: [[records/errors-as-values]], opened 2026-10-01 by the revisit
  that set the three principles below. It read *"none yet"* until then.

## Why this arc exists

Condition 2 says the convenient way is the safe way. This tree's safe shape for
failure is already settled and already written down: `pattern-boundary-sums` is
a **standing author directive from 2026-08-09**, *"apply this as much as
physically possible"*, and it says a boundary parses its classification into a
closed sum and passes the value downstream. Measured over `lib/` and `prog/`,
the tree obeys the first half of that directive and pays for it twice. **76
two-arm ok/err boundary sums exist and no combinator exists over any of them**,
so propagation is hand-written at **202 sites** where an error is destructured
and reconstructed with its payload untouched. And **47 of the 76 carry a `Str`
in the error slot**, which is the second half of the directive unobeyed: a `Str`
is a classification wearing a disguise, and a caller cannot `case` on it. Safe
is the expensive way here, and the expense is the arc.

Condition 1 is the second goal, and it is what the payload half buys. A `Str`
tells a reader what happened and cannot tell them what to do, because nothing
downstream can branch on it. `E157` removed exactly this defect for `ld-err` and
`ck-err`, mints `Reason` as a ten-arm evidence-bearing sum, and is gated at
Phase 13. It was applied to two constructors and to no others. **The two halves
of this arc must be scheduled together**, and §4's first back-edge says why: a
shared carrier laid over a `Str` payload turns `(p-err (msg Str))` into
`(Result Core Str)`, which preserves the defect exactly and makes it read as
finished.

## The three principles

Stated by the author on 2026-10-01 in session, and every row serves at least
one. The author's words, verbatim: *"doesnt compile until the errors we can
detect are handled"*; *"feedback is great even if tests arent thorough (because
tests should be for logic bugs anyway"*; *"error handling is made more
convenient/straightforward for all cases we can detect"*. And on their standing:
*"these three need to be principle goals of error handling arc"*.

1. **A program doesn't compile until the errors we can detect are handled.**
2. **The refusal is the feedback.** It names what is unhandled and where, with
   evidence the writer can act on. Tests are for logic bugs, and this arc leans
   on none of them; how a program's logic tests are required is
   `records/lenses/unspoken.md` UNS-52.
3. **Handling is convenient and straightforward for every case we can detect.**

**The errors we can detect** are the failures whose possibility shows in a type:
a crossing, a partial primitive, a refinement, a declared error sum. A wrong
specification sits outside, and so does a channel with no port
(`PRINCIPLES.md:108-111`).

### What handled covers

Principle 1 has four sides, and a missing side lets an error through unhandled
with the program still compiling.

| side | what it asks | where it is served |
|---|---|---|
| produced | every detectable failure arrives as a declared error. Text, a value of the success type standing for failure, and a silent default each fail this side | requirements 2, 3 and 5; rows `EV14` and the adoption rows |
| ruled out | a failure a refinement rules out needs no handler, and a partial primitive offers a proven precondition or a checked form that returns a result | [[arcs/enforcement-arc]] rows `N18` to `N22` and `N31`; termination under [[arcs/checker-core-arc]] row `CK12` |
| consumed | a result cannot be dropped, cannot skip an arm, and cannot escape a boundary | requirement 6; `jg-nonexhaustive`, ENFORCED; rows `EV13` and `EV16` |
| fed back | the refusal names the unhandled arms or rights with evidence | requirement 3's evidence-bearing payloads; row `EV15` |

Principle 3 rides on all four: requirement 1's combinators, handlers that keep
the plumbing out of a body, and an explicit discard that is written out where a
result is meant to be dropped, so dropping is the loud opt-in P4 asks for.

## What the tree already holds

Measured 2026-09-23 over `lib/` and `prog/`, and the bank comes first.
[[banks/INDEX]] holds twelve.

**The bank's correction is a constraint on this arc, not an input to it.**
[[banks/effect-and-alarm]] §4 already refracts this concept and answers the
misfire *"chirality needs `Result`/`Either` for error handling"*: `Result` is a
**shadow** of the row mechanism, carrying no recoverable-vs-fatal distinction,
no counter-effect set, and none of the split-fed payload the alarm carries. That
correction is about **the alarm**, the effect-row layer whose keystone is `E39`,
specced and unbuilt. This arc is below it: the 76 sums are ordinary
alternate-return values in already-written compiler and protocol code, and
nothing here is the alarm. A row that starts claiming to build the alarm has
left this arc.

| group | what exists today | where | rung |
|---|---|---|---|
| carrier | the polymorphic carrier, three instances, each polymorphic in the **payload** and monomorphic in the error | `lib/surface/surface.chiral:23` `PR` (its own comment: *"result sum: POLYMORPHIC so one type carries Core / I64 / a pair / a list"*), `lib/surface/parse.chiral:750` `MfR`, `prog/scriba/puffer.chiral:41` `NewPufR` | IMPLEMENTED |
| carrier | 76 two-arm ok/err boundary sums, minted fresh per boundary. Six in one file at `apc.chiral:19-24` differ only in the ok arm's payload type; six more at `erase.chiral:26-31` differ only in the ok arm and all carry `(reason Str)` | tree-wide census over `lib/` and `prog/` | IMPLEMENTED |
| carrier | **zero combinators.** No `bind`, no `map-err`, no `and-then`, no `then` over a result. Every `bind-*` name in the tree is variable binding | `lib/typing/kernel.chiral:498` `bind-fields`, `lib/lowering/tal/eval.chiral:104` `bind-vals`, `lib/lowering/tal/check.chiral:237` `bind-dsts` | absent |
| carrier | 202 rebuild-unchanged sites: a `case` arm destructures an error and reconstructs one with the same binder. 137 same-carrier, 65 cross-carrier. Worst files: `parse.chiral` 69, `kernel.chiral` 32, `surface.chiral` 32, `loader.chiral` 16, `erase.chiral` 12, `apc.chiral` 23 | same census | IMPLEMENTED |
| carrier | `do` exists and carries **no** propagation. `elab-do` desugars `(<- x e)` to a linear `c-let`, and its own comment says so: *"do: linear (q=1) let-sequencing"* | `DoStmt` at `lib/surface/surface.chiral:45`; `elab-do` at `lib/surface/surface.chiral:266`, under its own comment at `lib/surface/surface.chiral:265` | IMPLEMENTED |
| payload | the target shape, a declared error sum in the error slot, **15 instances**: `Reason` ×8, `ResErr` ×3, `SpawnErr` ×2, `MfErr` ×1, `Obs Obs` ×1 | `lib/typing/kernel.chiral` (6), `lib/module/loader.chiral` (2), `lib/module/resolve.chiral` (3), `lib/surface/parse.chiral:750` `MfR` over `MfErr` at `:730`, `lib/runtime/proc.chiral`, `prog/shilpa/turn.chiral`, `lib/evidence/test-floor.chiral` | ENFORCED for `Reason` (E157, Phase 13, `tools/test/diag.sh`) |
| payload | 47 error arms carrying a `Str`: **30 a bare `Str` alone**, 17 a `Str` beside something else (usually `(pos I64)`). **18 inside `prog/compiler.prog`'s import closure, 29 outside** | census; the closure is the 61 modules `chirality_blob_file "lib:prog" prog/compiler.prog` resolves | IMPLEMENTED |
| payload | 13 more error arms carry a raw `I64` errno, which is the third shape and out of this arc's scope | `lib/protocol/term.chiral` ×11, `lib/memory/arena.chiral`, `lib/protocol/http.chiral` | IMPLEMENTED |
| payload | **the arms are already recoverable from the source.** Over 763 construction sites of the 44 censused error constructors: 354 (46%) pass a bare variable (propagation, which a combinator deletes), 177 a literal, 21 a `str-cat` with a literal prefix, 211 (27%) genuinely computed. 28 of the 44 yield a distinct arm set from their own literals: `p-err` 38 arms / 279 sites, `step-err` 15/79, `e-err` 14/19, `tck-err` 14/27, `pos-bad` 8/13, `elf-err` 8/10, `xi-err` 7/10, `quad-err` 6/12, `r-err` 6/18 | same census | IMPLEMENTED |
| doctrine | the standing directive, with its own audit test: *"if a `Str` or `I64` in a signature encodes which-of-N-things, it is a sum wearing a disguise"* | `docs/definitions/pattern-boundary-sums.md` | — |
| doctrine | `E157` is the worked precedent for the payload half, on two constructors. `Reason` is ten evidence-bearing arms, rendered by `dg-msg` and `dg-doc`, each exhaustive with no `_` arm | `lib/typing/diag.chiral:121`, `docs/elements/catalog.md:474` | ENFORCED (Phase 13) |
| doctrine | `MfErr`/`MfR` is the second worked instance and the only one that is **already the full target shape**, a shared payload-polymorphic carrier over a declared 18-arm sum, with its own comment naming the pattern | `lib/surface/parse.chiral:730` and `:750` | IMPLEMENTED |
| survey | seven languages surveyed. Roc and OCaml polymorphic variants keep per-boundary specificity in one carrier with widening inferred, and **both pay by dropping the declared-constructor check this tree rests on** (`OCAMLPOLYV:336`). Zig pays with a payload-free error and forbidden recursion. The other five widen per boundary and write the injection by hand | [[records/findings]] FD-48 | — |
| feasibility | a generic `(Result A E)` with a higher-order `bind` **type-checks, compiles and runs**, so the carrier half asks the substrate for nothing it lacks. The lowering blocker, `E100`'s fn-param application residual, closed via `E100`/`E147` on 2026-08-16 and `E185`-`E188` on 2026-09-04 | **re-verified 2026-09-23 by probe**, not by a tracked artifact: `(data Result ((A (type 0)) (E (type 0))) (ok (v A)) (bad (e E)))` with `rbind` taking `(-> A (Result B E))` as a value parameter, two chained binds over a three-arm `MyErr`. `chirality run` prints 43 and exits 0; `chirality compile` emits **37,240 bytes** which runs and exits 0. ⚑ the byte figure is **not distinctive**: `docs/arcs/custody-executes-arc.md:76` records the same 37,240 for an unrelated minimal probe, so it identifies the floor of a program with one port import rather than this experiment | IMPLEMENTED |

**What no arc holds.** [[arcs/diagnostics-arc]]'s `values` group is the
compiler's `Reason` sum and its `Judg` arms: `V1` and `V2` are built, `V3`
disposes of two unreachable arms and `V4` makes `Reason`'s exhaustiveness
checkable. All four are about `Reason`. None of them reaches the 76 carriers or
the 47 `Str` payloads outside it. [[goals/readable-surface]] condition 4 assigns
"the error vocabulary" to that arc and means the reader-facing message;
condition 2 is unopened and holds no arc file, which is what this one takes.

## What is missing, and its structure

| group | owns |
|---|---|
| `carrier` | one result type declared once, polymorphic in **both** slots, and the combinator that deletes the hand-written rebuild |
| `classification` | turning a `Str` error slot into a declared sum: the recipe, its completeness test, and the scope call over how far it reaches |
| `adoption` | the per-boundary migration, sequenced so the shape is proven outside the compiler's import closure before it enters one |
| `gate` | the check that stops a new bare-`Str` boundary sum landing after the work is done |

### The edges that run against the order

| edge | direction | what crosses |
|---|---|---|
| `classification` -> `carrier` | against the numbering | ⚑ **the trap this arc exists to avoid.** A shared carrier is usable the moment it is declared, and using it over a `Str` payload produces `(Result Core Str)`: the 202 rebuild sites vanish, the arc reads as half finished, and the payload defect is preserved and now harder to see because the site count that made it visible is gone. So the classification's recipe (`EV4`) and its scope call (`EV3`) are owed **before** any adoption row over a `Str`-carrying boundary, and requirement 2 is the check |
| `adoption` -> `carrier` | against the numbering | the carrier's final shape is settled by the **last** adoption row, not the first. Whether the error slot is one type variable or a constrained one is answered by what the 47 boundaries turn out to need, and `apc.chiral` (3 origination sites, 2 classes) cannot answer it. `EV11` is the row that forces the answer and it is scheduled last |
| `adoption` -> `adoption` | against the numbering | ordering inside the group runs by **closure membership, not by size**. 18 of the 47 sit inside `prog/compiler.prog`'s 61-module closure and owe the three-generation fixpoint build of [[working-discipline]]; 29 sit outside and owe `chirality run FILE`. The cheapest-looking row, `MfR`'s pure-win adoption with zero classification work, is **inside** and therefore not first |
| `gate` -> `classification` | against the numbering | the gate's predicate is the classification's own definition of a declared error sum. Writing the gate before one boundary has landed aims it at a guess, which [[decisions/decision-scope]] names as a gate that cannot fail |

## REQUIREMENTS

1. **One carrier, declared once, with a combinator that deletes the rebuild.**
   Observed by two things: `bind` and `map-err` exist as declared defs over the
   result type rather than as variable-binding names, and the rebuild-unchanged
   count falls from its 2026-09-23 baseline of **202** by the number of sites in
   each adopted boundary. The census predicate is a `case` arm destructuring an
   error and reconstructing one with the same binder, re-runnable over `lib/`
   and `prog/`.
2. **A carrier shared over a `Str` payload is refused.** ⚑ **Widened
   2026-10-01 under principle 1**: an error encoded as a value of the success
   type is the same defect one step earlier, since nothing can `case` on it
   either. `open-rw` answers `fd | -errno` in one `I64`
   (`lib/ports/file.port:14`), and `str->i64` maps junk to 0 with no failure arm
   (`lib/prelude/prelude.chiral:150`). Row `EV14` carries the census. Observed by no adopted
   boundary's error slot resolving to `Str`: every one names a declared sum. A
   row that lands the carrier and leaves the payload is this requirement
   failing, and it is the one the first back-edge exists for.
3. **The classification is complete per boundary, and checkable.** Observed by
   each converted constructor's arm count matching the distinct classes the
   census recovers from its own construction sites (`quad-err` 6, `tck-err` 14,
   `e-err` 14, `step-err` 15, `p-err` 38), and by every renderer over the new
   sum being exhaustive with no `_` arm, which is `E157`'s own shape at
   `lib/typing/diag.chiral:311` and `:556`.
4. **The shape is proven outside the compiler's import closure before it enters
   it.** Observed against the 61-module closure: the first adopted boundary is
   one of the 29 outside it and is gated by a suite phase, and no row inside the
   closure is adopted until that has landed. A row inside owes the
   three-generation fixpoint build with the non-empty guard before every `cmp`.
5. **A new boundary sum cannot land with a bare `Str` error arm.** Observed by a
   check that fails on the census predicate: a two-arm ok/err sum whose error
   arm carries exactly one `Str` field. It reads 30 today, and the number it is
   allowed to read is settled by `EV3`'s ruling.

6. **A detectable error cannot be dropped and cannot escape.** Opened
   2026-10-01 under principle 1. Observed by two probes refused at check: a
   result bound and never consumed, refused by `r-usage` through a linear error
   arm on `EV1`'s carrier, and an alarm reaching a profile's `main` with no
   handler, refused through [[arcs/enforcement-arc]] row `N25`'s effect row.

## Roster

Ids are arc-local per [[decisions/decision-work-ids]] and **do not change when a
row mints**, so a citation made now survives the number arriving. Every row maps
to `unminted`: this arc holds no band.

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `errors-as-values/EV1` | one result type declared once, polymorphic in the payload **and** the error, generalising the three in-tree carriers that are polymorphic in the payload alone (`PR`, `MfR`, `NewPufR`) | carrier | primitive | bind | 1, 2 | specced | `E202` |
| `errors-as-values/EV2` | `bind` and `map-err` as ordinary declared defs over `EV1`'s type. A plain `bind` is a call and never early-returns, so it cannot strand a linear binder; short-circuit sugar over `do` is **deferred and not rostered**, and §Resume state says why | carrier | primitive | new | 1 | open | `unminted` |
| `errors-as-values/EV3` | the scope call: whether condition 1 reaches the whole tree or only the compiler's `Reason` arms. 29 of the 47 `Str`-carrying error arms are outside the compiler's closure entirely. Carried as a row in [[records/author-calls]], `unreviewed` | classification | decision | new | 3, 5 | open | `unminted` |
| `errors-as-values/EV4` | the classification recipe and its completeness test: how a boundary's arm set is recovered from its own construction sites, and what makes the recovered set complete. Generalises `E157`'s `Reason` and `parse.chiral:730`'s `MfErr`, the two instances that already did it by hand | classification | law | new | 3 | open | `unminted` |
| `errors-as-values/EV5` | `lib/protocol/apc.chiral:19-24`: six carriers differing only in the ok arm collapse onto `EV1` over a declared `ApcErr`. The purest carrier case in the tree, 23 rebuild sites of which 17 cross-carrier, and only 3 origination sites in 2 classes, so the classification is nearly free. **Outside** the closure | adoption | primitive | connect | 1, 2, 4 | open | `unminted` |
| `errors-as-values/EV6` | `lib/protocol/inet.chiral:20` `QuadR`: `quad-err` 6 arms over 12 sites, the smallest boundary whose arm set is complete in its own literals. The first row where classification carries real content. **Outside** the closure | adoption | primitive | bind | 2, 3, 4 | open | `unminted` |
| `errors-as-values/EV7` | `lib/lowering/tal/check.chiral:47,49` `TckR`/`TckCovR`: `tck-err` 14 arms / 27 sites, `cov-err` 2 / 7. A type checker's refusals, which is the case condition 1 is strongest about. **Outside** the closure | adoption | primitive | bind | 1, 2, 3, 4 | open | `unminted` |
| `errors-as-values/EV8` | `lib/lowering/tal/eval.chiral:30-31` `ER`/`RunR`: `e-err` 14 arms / 19 sites, `r-err` 6 / 18, both three-arm sums whose third arm `-oot` is already a declared class beside the `Str`. **Outside** the closure | adoption | primitive | bind | 1, 2, 3, 4 | open | `unminted` |
| `errors-as-values/EV9` | `lib/lowering/tal/erase.chiral:26-31`: six carriers all carrying `(reason Str)`, 38 construction sites, 12 rebuild sites. The **first row inside** the closure, so it is the first to owe the three-generation fixpoint build | adoption | primitive | connect | 1, 2, 4 | open | `unminted` |
| `errors-as-values/EV10` | `lib/surface/parse.chiral`: `MfR` at `:750` adopts `EV1` with **zero** classification work, being already the target shape, and `StepR`'s `step-err` (15 arms / 79 sites) classifies beside it. 69 rebuild sites, the highest count in the tree. Inside the closure | adoption | primitive | bind | 1, 2, 3 | open | `unminted` |
| `errors-as-values/EV11` | `lib/surface/surface.chiral:23-25` `PR`/`p-err`: 38 arms over 279 sites, 32 rebuild sites. The largest boundary in the tree and the row that settles whether `EV1`'s error slot needs a constraint. Inside the closure, and **last** | adoption | primitive | bind | 1, 2, 3 | open | `unminted` |
| `errors-as-values/EV12` | the census becomes a check: a two-arm ok/err sum whose error arm is exactly one `Str` field fails it. Reads 30 today. Registers as a suite phase or as a `ledger-lint` check, and that placement is part of the row | gate | tool | new | 5 | specced | `E201` |
| `errors-as-values/EV13` | a result cannot be dropped: `EV1`'s error arm carries quantity 1, so a result bound and never consumed is refused by `r-usage`; `bind` threads it, and a written discard is the one way to drop an error on purpose | carrier | law | new | 6 | open | `unminted` |
| `errors-as-values/EV14` | no failure in band: a census of every crossing and primitive whose failure is a value of its success type (`-errno` in an `I64` at `lib/ports/file.port:14`, junk parsed to 0 at `lib/prelude/prelude.chiral:150`), each converted to a declared sum. The census's first reading is owed by this row's design | classification | law | new | 2 | open | `unminted` |
| `errors-as-values/EV15` | typed refusals reach the writer: def, declare and extern refusals keep their `Reason` past `lib/surface/parse.chiral:580` and `:673` instead of becoming text there and coming back as `r-relayed` at `lib/module/load-batch.chiral:81` ([[bug-classes]], *A typed refusal is flattened on the shipping path*) | classification | law | connect | 3 | open | `unminted` |
| `errors-as-values/EV16` | an alarm cannot escape a boundary: the effect row at a profile's `main` is discharged by handlers, and an undischarged row is refused. The consumer of [[arcs/enforcement-arc]] row `N25`'s row, with E26's handlers | adoption | law | pair | 6 | open | `unminted` |

### Coverage

Run 2026-09-23, and it passes on all three limbs.

**Every requirement is named by at least one row.** 1 by `EV1`, `EV2`, `EV5`,
`EV7`, `EV8`, `EV9`, `EV10`, `EV11`. 2 by `EV1`, `EV5`, `EV6`, `EV7`, `EV8`,
`EV9`, `EV10`, `EV11`, `EV14`. 3 by `EV3`, `EV4`, `EV6`, `EV7`, `EV8`, `EV10`,
`EV11`, `EV15`. 4 by `EV5`, `EV6`, `EV7`, `EV8`, `EV9`. 5 by `EV3` and `EV12`.
6 by `EV13` and `EV16`, added 2026-10-01 with the requirement.

**Every row names at least one requirement.** All twelve do.

**Every `origin` is defensible from §3.** `EV1` is `bind` because §3 measures the
polymorphic carrier existing three times already, at `surface.chiral:23`,
`parse.chiral:750` and `puffer.chiral:41`, each polymorphic in the payload and
needing one home and a second type variable. `EV2`, `EV3`, `EV4` and `EV12` are
`new` because §3 measures zero combinators, no stated scope, no stated recipe
and no check. `EV5` and `EV9` are `connect` because both files already hold six
carriers that differ only in the ok arm, so the work joins two built things. The
five remaining adoption rows are `bind` because §3 measures the arm set as
**already present in the source** at each of them, as the literal and
`str-cat`-prefix construction sites the census recovers, needing a declared
surface rather than invention. No row is marked `new` over work §3 shows built.

## Resume state

⚑ **2026-10-01: RESCOPE. The arc takes three principles and a sixth
requirement.** Trigger: the author's direction in session the same day, recorded
under `## The three principles`, that a program does not compile until the
errors we can detect are handled, that the refusal is the feedback, and that
handling is convenient for every case we can detect. Requirement 2 widens to
errors held in band; requirement 6 opens for an error that is dropped or
escapes; rows `EV13` to `EV16` open. [[records/errors-as-values]] ER-01 carries
the run. **Next is unchanged**: `EV3`, then `EV1`, `EV4`, `EV5`. `EV13` designs
beside `EV1`, since both settle the carrier.

**Opened 2026-09-23.** Nothing designed, nothing minted, no element number
available. The next stage is `element-design` on one roster row.

**Start at `EV3`, and it is not a design run.** The scope call is an author call
and a pass must stop on it: [[goals/readable-surface]] condition 1's stated
observable is scoped to *"every `Reason` arm"*, and 29 of the 47 `Str`-carrying
error arms are outside the compiler entirely, in `lib/protocol/{apc,http,json}`,
`prog/prapanca`, `prog/scriba` and `prog/shilpa`. Whether condition 1 reaches
them decides how many rows this arc owes and what number `EV12`'s check is
allowed to read. The row is in [[records/author-calls]] at `unreviewed`, and
[[dispatch]] §What the orchestrator does itself is why no agent answers it.

**Then `EV1`, `EV4`, `EV5`, in that order.** `EV5` is the first adoption row on
purpose: `apc.chiral` is outside the closure, its six carriers differ only in
the ok arm, and it originates 3 errors in 2 classes, so it proves the carrier
and the combinator at nearly zero classification cost. `EV11` is last on
purpose: 279 sites inside the closure is where a wrong carrier shape is most
expensive to undo.

**Deferred, named, and deliberately not rostered.** Short-circuit sugar over
`do`. A plain `bind` is an ordinary call and never early-returns, so it cannot
strand a linear binder; sugar that early-returns can, and that is a real QTT
question no source in [[records/findings]] FD-48 addressed. Naming it as a row
would schedule work whose shape nothing in the tree settles, which is the
deferral rule's own case. It becomes a row when `EV2` has landed and a consumer
asks for it.

**Ruled out before this arc opened, so a revisit does not re-take them.**
Feasibility of a generic `(Result A E)` with a higher-order `bind`: proven, and
re-verified 2026-09-23 by a probe that compiles, runs, exits 0 and prints the
right answer through two chained binds.
Retiring the per-boundary error sums: refused, because
`pattern-boundary-sums` says the specific error is the point and the shape is a
shared carrier over a **specific** declared `E`. Compiler diagnostic rendering
(`Reason`, `Doc`, `pretty`): built, and it is [[arcs/diagnostics-arc]]'s.
Runtime alarm semantics: a different layer, keystone `E39`, no arc, and
[[banks/effect-and-alarm]] §4 is the reason a row here must not drift into it.

**The measurements above are re-runnable and were taken 2026-09-23** over every
`.chiral` file under `lib/` and `prog/`, by s-expression parse rather than by
grep. The four numbers a later run should compare against: **76** two-arm ok/err
boundary sums, **47** of them with a `Str` in the error slot (30 bare), **202**
rebuild-unchanged sites, and **61** modules in `prog/compiler.prog`'s import
closure.
