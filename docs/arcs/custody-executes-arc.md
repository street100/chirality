---
node: arc-custody-executes
layer: navigation
related: [arcs/README, goals/password-manager, arcs/sys-face-arc, arcs/lowering-and-emit-arc, arcs/bridge-arc, arcs/ownership-and-trust-arc, arcs/crypto-primitives-arc, banks/capability, banks/port, banks/memory, status-ledger, modules-custody, working-discipline, decisions/decision-scope, decisions/decision-work-ids, decisions/decision-design-before-mint, records/author-calls, records/conformance-map, records/lenses/problems, index]
status: current
updated: 2026-09-23
---

# Arc: custody-executes

- goals: [[goals/password-manager]], condition 5: "**The custody type executes
  rather than only type-checking.**"
- reserved element block: **none**. Rows carry arc-local ids `CU1` and up per
  [[decisions/decision-work-ids]]. The letter is `CU` for custody: `C` is
  [[arcs/bridge-arc]]'s and `CK` is [[arcs/checker-core-arc]]'s, and a grep for
  `CU` followed by a digit over `docs/`, `records/` and `.planning/` returns no
  row id, verified 2026-09-23. Three rows carry `E40`, minted long before this
  file; the other four read `unminted`.
- build-state authority: [[status-ledger]]
- checklist: none today. A `records/custody-executes.md` opens when the first
  row is worked, on the pattern `records/sys-face.md` follows.
- track: `E40` is filed `OT` at `docs/elements/ledger.md:234` and
  [[decisions/decision-scope]] build-defers that track. Every row below states
  whether the scope call reaches it, under *Which rows the scope call governs*.

## Why this arc exists

`docs/goals/password-manager.md` states condition 5 and its observation in one
sentence: `secret-seal`, `secret-reveal` and `secret-wipe`, declared at
`lib/capability/secret.chiral:36`, `:41` and `:45`, each holding an entry in
`lib/lowering/tal/crossing-wraps.chiral`. Conditions 1 and 4 of that goal count
and gate what the custody path does at runtime, so until the three externs reach
a body there is no runtime for either to read. This arc is the floor under them.

What it takes to hold is wider than the one table the condition names, and the
compiler says so when asked. Measured 2026-09-23, a root whose `compile-main`
seals bytes and wipes the result refuses at `bin/chirality compile` with
`no emitted label for entry compile-main | skip chain for compile-main:
compile-main: extern does not lower: secret-seal`. Two separate gates produce
that refusal and only one of them is the crossing table. §3 measures both.

## What the tree already holds

Measured 2026-09-23 against the working tree. [[banks/INDEX]] holds thirteen and
three own this territory. [[banks/capability]] Shard G puts lifecycle custody in
the component broker (`docs/banks/capability.md:263-267`). [[banks/port]] records
`Secret`'s nominal identity as one of only three facets any porttype carries
beyond custody, and names `secret-seal` among the ambient mints that make
non-forgeability zero for every port (`docs/banks/port.md:426-441`).
[[banks/memory]] Shard 9 is the closest home: it holds zeroize and register-root
custody, calls the secret seed built and the bulk `E56`, and states the ceiling
this arc inherits (`docs/banks/memory.md:211-229`).

| group | what exists today | where | rung |
|---|---|---|---|
| G1 the carrier | `porttype-word?` classifies six porttypes to a machine word and `porttype-str?` one to a string. `Secret` is in neither list, so `term->ntalty` answers `(none)` for it and `prim->n` drops every extern mentioning it | `lib/lowering/compile-front.chiral:37-45`, `:52-55`, `:60-72`, `:326-333` | ENFORCED, and it runs on every compile |
| G1 the carrier | the general carrier registry, a per-porttype declared carrier consulted like `latoms`, is named in the tree as `E123` §6's deferred refinement. The two name lists are the stopgap the comment says they are | `lib/lowering/compile-front.chiral:50-52` | DESIGNED |
| G2 the routing | the crossing table: **44 rows**, extern name to wrapper name. [[arcs/sys-face-arc]] `SF1` counts the same 44 at `docs/arcs/sys-face-arc.md:178`. None of the three custody names is among them | `lib/lowering/tal/crossing-wraps.chiral:14-57` | ENFORCED |
| G2 the routing | the table's three consumers, so a row added there is read by all of them: erase rewrites `i-prim` to a wrapper call, the profile gate reads the codomain as the vocabulary of crossing, and `sys-bindings` is derived from it | `lib/lowering/tal/erase.chiral:220`, `lib/lowering/compile-emit.chiral:226`, `lib/lowering/tal/sys-linkage.chiral:93` | ENFORCED |
| G2 the routing | the second route, and the precedent that an effectful extern need not take the first: `prim2lib-table` holds **24 rows** and `adopt-fd`, declared `(=> I64 Fd)` at `lib/ports/fd.port:32`, lowers through it to the identity peel `nb-id` with no crossing row anywhere | `lib/lowering/tal/erase.chiral:112-143`, `:120` | ENFORCED |
| G3 the floor | zeroize, built and reached: `nb-pool-zero` recursively zero-fills `[base, base+size)`, is folded into `sys-lib`, and `nb-pool-close` calls it before `munmap` | `lib/lowering/tal/sys.chiral:1109-1118`, `:1321`, `:1138` | ENFORCED, through `pool-close` |
| G3 the floor | a wrapper that returns a data wrapper rather than a word, which is the shape `secret-reveal`'s declared `RevealR` needs: `be-peek` builds a two-field sum inside the peel | `lib/lowering/tal/erase.chiral:125-126` | ENFORCED |
| G3 the floor | what a new wrapper must join to reach the image: `link-lib` is four `wrap-*` functions plus `sys-lib`, and `emit-elf-m` runs the E76 chokepoint over the whole image before it will emit bytes | `lib/lowering/tal/sys-linkage.chiral:98-99`, `lib/lowering/compile-emit.chiral:296` | ENFORCED |
| G4 the type | the custody slice itself, 56 lines: `porttype Secret` at `:21`, the `RevealR` wrapper at `:31`, the three externs at `:36`, `:41` and `:45`, and `send-revealed` as the sole legal path at `:53`. Declared outside `lib/ports/`, so it is none of the 51 externs on the nine `.port` sheets | `lib/capability/secret.chiral` | SEEDED |
| G4 the type | the demonstration, 32 lines. `bin/chirality check` answers OK, verified 2026-09-23. `bin/chirality compile` refuses it with `no such def: compile-main`: the file is library-shaped and declares no entry | `prog/demo/passman-min.chiral` | SEEDED |
| G5 the gate | the leak fixture, 30 lines, named by no line of `tools/test/*.sh`, verified 2026-09-23 by grep. It is a Phase 12 row and [[arcs/lowering-and-emit-arc]] `LE23` already counts it among the six `e170_reject_*` roots | `tools/test/samples/e170_reject_secret_leak.prog` | absent |
| G5 the gate | the phase register. 33 is the highest dispatched, and the author's 2026-09-06 ruling makes this file the only authority for a number and gives a gate the first one colliding with nothing | `tools/test/run-tests.sh:378`, `:346-350` | ENFORCED |

Three measurements govern the roster, each re-runnable.

**The refusal has two causes and the condition names one of them.** A probe
declaring `(porttype Fd)` with two externs named `secret-seal` and `secret-wipe`
refuses at `compile-main: extern does not lower: secret-seal`. The identical
file with those two names changed to `open-rw` and `close`, which hold crossing
rows at `lib/lowering/tal/crossing-wraps.chiral:34` and `:21`, emits a
37,240-byte ELF. The identical file keeping `open-rw` and `close` and changing
the porttype to `Secret` refuses again, with the message doubled:
`extern does not lower: extern does not lower: open-rw`. The doubling separates
the two skip records, `lib/lowering/compile-back.chiral:271` for a def the
lowerer refused and `:191` for a def erase refused, so the carrier gate at
`lib/lowering/compile-front.chiral:37-45` and the routing gate at
`lib/lowering/tal/crossing-wraps.chiral` are independent and both stand between
this type and a running program.

**The count in condition 5's observation is 44 and not 45.** Measured by
`grep -c '(cons (pair' lib/lowering/tal/crossing-wraps.chiral`, which answers 44
over `:14-57`. `docs/arcs/sys-face-arc.md:178` reads the same 44. The 45 in
`docs/goals/password-manager.md` and in `records/author-calls.md:52` is the
count of closing parentheses on `:58`, one of which closes the `def`.

**The one authority for this slice's state says it lowers.**
`docs/definitions/status-ledger.md:195` reads *"It **type-checks and lowers**,
and has no referent to run against"*. The first probe above is the
counterexample: nothing that mentions `Secret` peels, so the slice does not
lower and never reaches the stage where a referent would be missing.
`records/lenses/problems.md` PRB-30 already reported that row as carrying a
stale trace and could not edit it. `lib/capability/secret.chiral:40` carries the
second stale claim, *"The host binding zeroes its own copy on the way out"*,
against a host binding `docs/definitions/status-ledger.md:195` records as CUT.

## What is missing, and its structure

| group | owns |
|---|---|
| G1 the carrier | a classification for `Secret` at the front peel, so a type mentioning it maps to a machine representation instead of to `(none)`. The mechanism is built and closed over seven names |
| G2 the routing | a body named for each of the three externs, by a crossing row or by an identity peel, and the ruling that says which of the two routes custody takes |
| G3 the floor | the bodies themselves: what seal mints, what reveal returns inside `RevealR`, and what wipe zeroes |
| G4 the program | one root that reaches all three from an entry the emitter can find |
| G5 the gate | a phase that runs that root and reddens when the custody path breaks |

### The edges that run against the order

| edge | direction | what crosses |
|---|---|---|
| G2 to G1 | against, and it is the one that decides the arc | the carrier and the route are one question asked twice. An identity peel makes `Secret` its own payload cell, which is what `backend-open` does for `Backend` at `lib/lowering/tal/erase.chiral:124`; a crossing row makes it a handle a wrapper mints, which is what `open-rw` does for `Fd`. Choosing the carrier first commits the route, and the numbering reads the other way |
| G3 to G2 | against | erase splits a crossing by its declared result at `lib/lowering/tal/erase.chiral:220-225`: a `Unit` crossing has its destination overwritten with the Unit tag and a value crossing keeps the wrapper's cell. `secret-wipe` returns `Unit` and `secret-seal` and `secret-reveal` do not, so what each body returns decides the shape of its routing row and the row cannot be written first |
| G5 to everything | against, and the loudest | `docs/definitions/bug-classes.md:171-173` names the class: a rule that compiles, passes the suite and is marked built while running on no path. This slice is already in it twice over, once for `E40` reading `built` at `docs/elements/ledger.md:234` and once for the state authority at `docs/definitions/status-ledger.md:195` claiming a lowering that does not happen. Building G1 through G4 without G5 adds to the unasserted set before it subtracts from it |
| G4 to G3 | against, partly | `prog/demo/passman-min.chiral` needs an entry before it can be compiled at all, and that edit is independent of every body below it. The root can be made compilable, and refused for a stated reason, before any wrapper exists |
| G5 to the leak fixture | out of this arc's reach | `tools/test/samples/e170_reject_secret_leak.prog` is a Phase 12 row and [[arcs/lowering-and-emit-arc]] `LE22` and `LE23` own Phase 12's port. This arc's gate runs a positive execution root and takes neither the fixture nor the phase |

## REQUIREMENTS

Five, each with the observation beside it, measured 2026-09-23.

1. **A type mentioning `Secret` survives the front peel.** Observed by
   `bin/chirality compile` on a root whose entry reaches a `Secret`-typed extern
   no longer answering `extern does not lower: extern does not lower: <name>`.
   Today `term->ntalty` at `lib/lowering/compile-front.chiral:60-72` answers
   `(none)` for `Secret`, because `porttype-word?` at `:37-45` names six types
   and `porttype-str?` at `:52-55` names one and `Secret` is in neither.

2. **Each of the three externs names a body.** Observed by `secret-seal`,
   `secret-reveal` and `secret-wipe` each appearing either in
   `lib/lowering/tal/crossing-wraps.chiral` or in `prim2lib-table` at
   `lib/lowering/tal/erase.chiral:112-143`, and by the choice between those two
   routes standing in the tree as a written ruling. Today the crossing table
   holds 44 rows and the peel table 24, and none of the three is in either.

3. **`secret-wipe` zeroes the span it consumes.** Observed by the wipe body
   calling a zero-fill over the carrier's own bytes, `nb-pool-zero` at
   `lib/lowering/tal/sys.chiral:1109-1118` being the one this tree already ships
   and already reaches through `nb-pool-close`. The ceiling is stated with it:
   [[banks/memory]] Shard 9 records zeroed-on-drop as a semantics promise the
   machine can break through spills and dead-store elimination
   (`docs/banks/memory.md:219-223`), so this observes the instruction and not
   the absence of a copy.

4. **One root runs the custody chain and exits on a judged value.** Observed by
   a source file whose `compile-main` seals bytes, reveals them through
   `send-revealed` at `lib/capability/secret.chiral:53`, and exits on a value a
   runner compares. `prog/demo/passman-min.chiral` is 32 lines and
   `bin/chirality compile` refuses it with `no such def: compile-main`.

5. **A named suite phase runs that root and reddens when the custody path
   breaks.** Observed by a `run_phase` line in `tools/test/run-tests.sh`. The
   highest dispatched today is 33 at `:378`, and the author's 2026-09-06 ruling
   recorded at `:346-350` gives a gate the first number colliding with nothing.

## Roster

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `custody-executes/CU1` | the carrier-and-route ruling for `Secret`, taken once and written down before either half is built. The fork: an identity peel, which makes `Secret` its payload cell on the `backend-open` precedent at `lib/lowering/tal/erase.chiral:124` and owes no crossing row, against a crossing row over a wrapper-minted handle on the `open-rw` precedent at `lib/lowering/tal/crossing-wraps.chiral:34`. The second fork inside it: whether `Secret` joins the two closed name lists at `lib/lowering/compile-front.chiral:37-45` and `:52-55`, or the general carrier registry those lines call `E123` §6's deferred refinement gets built. **Wanted**: one design artifact under `docs/arcs/parts/` carrying the call and its reason. **Blocking condition**: none measured. This row is planning and `docs/decisions/decision-scope.md:75-83` puts a design inside planning | G1 | decision | new | 1, 2 | open | `unminted` |
| `custody-executes/CU2` | `Secret` gets whatever carrier `CU1` rules, so `term->ntalty` stops answering `(none)` for it and `prim->n` at `lib/lowering/compile-front.chiral:326-333` stops dropping all three externs. The mechanism is built and its membership is closed over seven names. **Wanted**: the classification, and the probe in §3 compiling instead of refusing with the doubled message. **Blocking condition**: `CU1`, whose second fork decides whether this is one name or a registry | G1 | primitive | bind | 1 | open | `unminted` |
| `custody-executes/CU3` | the three externs reach a named body through whichever table `CU1` rules, and all three consumers of that table see it: erase at `lib/lowering/tal/erase.chiral:220`, the profile gate at `lib/lowering/compile-emit.chiral:226`, and `sys-bindings` at `lib/lowering/tal/sys-linkage.chiral:93`. `E40`'s own residue is this join and nothing else at this layer. **Wanted**: three rows, or three peels, with the arrow each one's declared result forces. **Blocking condition**: `CU1` | G2 | port | connect | 2 | open | `E40` |
| `custody-executes/CU4` | the wipe body, zeroing the carrier's own span over `nb-pool-zero` at `lib/lowering/tal/sys.chiral:1109-1118`, and joined to the image the way `link-lib` at `lib/lowering/tal/sys-linkage.chiral:98-99` requires. `secret-wipe` returns `Unit`, so it takes erase's Unit arm at `lib/lowering/tal/erase.chiral:222`. The zero-fill issues no syscall, so the E76 chokepoint at `lib/lowering/compile-emit.chiral:296` costs it no row in `lib/lowering/tal/target-linux.manifest`. **Wanted**: the body and the zero-fill call, with the spill ceiling stated beside it. **Blocking condition**: `CU3` | G3 | primitive | bind | 3 | open | `E40` |
| `custody-executes/CU5` | the seal and reveal bodies. Seal mints the carrier from plaintext `Bytes` and does no encryption, which `lib/capability/secret.chiral:12-13` already rules. Reveal consumes the carrier and returns the two-field `RevealR` declared at `:31`, which is the shape `be-peek` already builds inside a peel at `lib/lowering/tal/erase.chiral:125-126`. **Wanted**: both bodies, and the honest limit re-stated where the code is: `secret-reveal` hands back immutable bytes it cannot zero, and the claim at `lib/capability/secret.chiral:40` that a host binding zeroes its own copy names a binding this tree no longer has. **Blocking condition**: `CU3` | G3 | primitive | bind | 2, 3 | open | `E40` |
| `custody-executes/CU6` | the runnable root: a `compile-main` that seals bytes, reveals them through `send-revealed` at `lib/capability/secret.chiral:53`, and exits on a value. `prog/demo/passman-min.chiral` is the 32-line fragment it grows from and today has no entry at all. Whether the root is that file with an entry added or a second file beside it is part of the row. **Wanted**: one root that `bin/chirality compile` accepts and that runs. **Blocking condition**: `CU4` and `CU5` for the run. The entry alone is addable today and makes the refusal a stated one | G4 | tool | bind | 4 | open | `unminted` |
| `custody-executes/CU7` | the phase: a `run_phase` line that compiles and runs `CU6`'s root and judges its exit, taking the first number colliding with nothing under the author's 2026-09-06 ruling at `tools/test/run-tests.sh:346-350`. It is not Phase 12: the leak fixture and Phase 12's port are [[arcs/lowering-and-emit-arc]] `LE22` and `LE23`, and this gate runs the positive path. **Wanted**: the phase, and the mutant that reddens it. **Blocking condition**: `CU6`, which supplies the root it would run | G5 | tool | new | 5 | open | `unminted` |

### Coverage

Run 2026-09-23 over the seven rows and the five requirements.

- **Every requirement is named by at least one row.** 1 by `CU1` and `CU2`; 2 by
  `CU1`, `CU3` and `CU5`; 3 by `CU4` and `CU5`; 4 by `CU6`; 5 by `CU7`.
- **Every row names at least one requirement.** All seven do.
- **Every `origin` is defensible from §3.** `CU1` is `new` because the fork it
  settles is stated nowhere: the two routes are both built and the tree has
  never ruled which one custody takes. `CU2`, `CU4` and `CU5` are `bind` because
  the carrier lists, the zero-fill and the data-returning peel all exist and the
  custody type has no surface in any of them. `CU3` is `connect` because the
  type and the routing tables are each built and nothing joins them, which is
  the same reading `bridge/C4` gives `E40` on a different axis. `CU6` is `bind`
  because the demonstration exists and lacks an entry. `CU7` is `new` because no
  phase over this slice exists in any form.
- **No row claims an unminted element number.** `CU3`, `CU4` and `CU5` carry
  `E40`, which `docs/elements/ledger.md:234` mints. The other four read
  `unminted`.

### Which rows the scope call governs

`records/author-calls.md:52` holds the open call, *whether `E40`'s remaining
custody build comes forward with [[goals/password-manager]] or stays on the `OT`
track*. This arc does not settle it, and
`docs/decisions/decision-scope.md:67-68` splits what it can reach: the track is
build-deferred. Plan deferral is the sense it does not carry, and `:75-83`
puts a design and a SPEC inside planning. So the rows sort three ways.

| rows | the call reaches | why |
|---|---|---|
| `CU1` | its build, which is a document | The row's whole deliverable is a design artifact under `docs/arcs/parts/`, which `docs/decisions/decision-scope.md:75-83` names as planning. It is schedulable today whichever way the call goes, and it is the row that makes every other one decidable |
| `CU2`, `CU3` | contested, and the call decides | Neither row writes to a file an `OT` element owns. `lib/lowering/compile-front.chiral` is `E123`'s and `lowering-and-emit/LE8` rosters it `built`; `lib/lowering/tal/crossing-wraps.chiral` is `E51`'s and `sys-face/SF1` rosters it `built`. Both changes exist only so an `OT` element runs, which is the distinction the call has to draw |
| `CU4`, `CU5`, `CU6`, `CU7` | yes, park until it rules | These are `E40`'s own implementation: two wrapper bodies, a root that exercises them, and the gate that judges the root. `CU7` also carries `CU6` as a blocking condition, so it parks twice |

Under [[decisions/decision-scope]]'s second pair, `CU1` carries no track
deferral and no blocking condition. `CU2` through `CU7` each carry a blocking
condition of their own, named in the roster, and those outlive the call the way
`E63`'s hardware dependence outlives it.

## What this arc does not take

- **The leak fixture and Phase 12.** `tools/test/samples/e170_reject_secret_leak.prog`
  is one of the six `e170_reject_*` roots [[arcs/lowering-and-emit-arc]] `LE23`
  counts, and `LE22` owns Phase 12's absent port. That fixture is
  `docs/goals/password-manager.md` condition 1's observation and condition 1 is
  separately queued. `CU7` adds a phase for the positive path and edits neither
  row.
- **The carrier mechanism and its gate.** `lowering-and-emit/LE8` rosters `E123`
  `built` and its stated want is that element's root under a phase
  (`docs/arcs/lowering-and-emit-arc.md:208`). `CU2` adds `Secret` to the set that
  mechanism classifies and takes neither the mechanism nor its gate. ⚑ If `CU1`
  rules for the general carrier registry instead of a name, the work lands in
  `E123`'s own residue and its owner is `LE8`. That ownership is an author call
  and `CU1` carries it.
- **The linkage table as a surface.** [[arcs/sys-face-arc]] `SF1` owns the
  twelve `.port` declarations that reach no routing row
  (`docs/arcs/sys-face-arc.md:178`). The twelve exclude the three custody
  externs, which are declared in `lib/capability/secret.chiral`, outside
  `lib/ports/`, and the nine sheets carry 51 externs of which none mentions
  `Secret`, verified 2026-09-23. `CU3` adds three names and edits no row of that
  arc.
- **Memory custody, redundancy and datum policy.** `E56` is minted at
  `docs/elements/ledger.md:243` and [[banks/memory]] Shard 9 assigns it the
  register root, per-datum flow policy and zeroize as a type obligation
  (`docs/banks/memory.md:223-226`). `CU4` zeroes one span at one crossing and
  claims none of that.
- **Custody as evidence.** `bridge/C4` holds `E40` and `E56` as the first
  evidence element for the supervisory bridge
  (`docs/arcs/bridge-arc.md:70`). That row reads the same element under
  [[goals/bridge]] requirement 2 and takes no lowering.
- **The crypto under the vault.** [[arcs/crypto-primitives-arc]] holds the
  seven rows conditions 2 and 3 of the goal name, serving [[goals/own-web]]
  condition 4. Sealing here is custody and not encryption, which
  `lib/capability/secret.chiral:12-13` already rules, so no row of that arc is
  touched.
- **Information-flow labelling.** `E44` is minted at `docs/elements/ledger.md:236`
  and owns the property that revealed bytes never reach a socket.
  `lib/capability/secret.chiral:9-13` states the limit this arc inherits: once
  revealed, the bytes are ordinary and untracked.

## Resume state

Opened 2026-09-23 on `docs/goals/password-manager.md` condition 5, the first of
that goal's five conditions to take an arc. Seven rows, all `open`, none
designed. `CU1` is where a session picks up, and it is the only row whose build
is a document.

**What blocks the arc.** The author call at `records/author-calls.md:52` governs
`CU2` through `CU7` as the table above sorts them. No reserved element block, so
the five unminted rows carry arc-local ids meanwhile.

⚑ **The call's own sentence reads wider than the build.**
`records/author-calls.md:52` ends *"Condition 5 of the goal cannot be scheduled
until it is settled"*, and `docs/decisions/decision-scope.md:67-68` and `:75-83`
put a goal, a roster row, a design and a SPEC outside what the track defers.
This file is written on the second reading. Whether the two sentences say one
thing is itself unsettled, and this run reports it and settles nothing.

⚑ **Condition 5's observation may name the wrong table, and the tree holds the
counterexample.** `adopt-fd` is declared `(=> I64 Fd)` at `lib/ports/fd.port:32`,
executes, and appears in no row of `lib/lowering/tal/crossing-wraps.chiral`,
because it lowers through the identity peel at `lib/lowering/tal/erase.chiral:120`.
If `CU1` rules for the peel route, condition 5 holds with the crossing table
unchanged and its stated observation goes red on a passing build. That is a
`revisit` run against the goal, triggered by `CU1`'s ruling. This arc edits no
goal file.

⚑ **Three drifted claims measured here, each in a document this run does not
edit.** `docs/goals/password-manager.md` and `records/author-calls.md:52` both
give the crossing table 45 rows and it holds 44.
`docs/definitions/status-ledger.md:195` says the slice *"type-checks and
lowers"* and the probe in §3 shows nothing mentioning `Secret` peels.
`lib/capability/secret.chiral:40` says the host binding zeroes its own copy on
the way out, against a host binding the same ledger row records as CUT. The
first is arithmetic, the second is the state authority contradicting the
compiler, and the third is a comment describing evicted code. `records/lenses/problems.md`
PRB-30 already reported the second and could not edit it.

⚑ **Condition 5 of the goal still reads *Unopened, and it holds no arc file*,
and `docs/goals/README.md` still reads `none open` for this goal.** This run
writes one arc file and its `docs/arcs/README.md` row, which is what `arc-open`
carries. The goal-side amendment is owed to a `goal-open` or `revisit` run.
`ledger-lint` check AF skips a goal whose README cell opens `none open`, so the
inconsistency costs no finding and is recorded here instead of being inferred.
