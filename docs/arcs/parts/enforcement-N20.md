---
row: enforcement/N20
arc: enforcement
title: the census: which of the prelude's externs lower to a routine that reads or writes memory at a caller-supplied index, and which of those clamp
kind: tool
origin: new
req: 1
status: draft
updated: 2026-09-10
---

# enforcement/N20: the census of caller-indexed byte access across the prelude's externs

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** the tree holds a committed, re-runnable instrument that names
  every one of `lib/prelude/prelude.chiral`'s externs whose lowering carries a
  caller-supplied value into a byte-cell seat, and states what each one does at
  an out-of-range value. A hand measurement with a date is not the deliverable.
  The instrument is.
- **Serves:** requirement 1 of [[arcs/enforcement-arc]], *"A capability sits at
  ENFORCED, or its ledger row says why it does not"* (`docs/arcs/enforcement-arc.md:42`).
  The open half is the row-says-why half (`:44-48`). A ledger row cannot say why
  a memory-safety capability is not at ENFORCED while the extent of the
  capability is uncounted. `records/bounds-residue.md` BR-05 verified this
  requirement as the one `N20` carries alone beside `N1` and `N4`.
- **Goal:** [[goals/enforcement]], condition 1.

## 2. What the tree holds

Measured 2026-09-10 at HEAD, structurally over the source and behaviourally
against the committed `bin/chirality-bin`.

- **Bank:** [[banks/text]] shard A is the built byte/string floor and its own
  limits line names the unclamped slice. [[banks/memory]] shard 3 is
  `mem-put-checked` (`lib/memory/mem-linear.chiral:26-28`), the refinement
  discipline that already carries a bound for a different carrier.
  [[banks/verification]] is the one that governs this row's deliverable: its
  one-sentence truth (`docs/banks/verification.md:75-78`) is that verification
  here is *"a layered set of independent instruments, each of which can only see
  what is below its branch point, ranked by the provenance of the expectation it
  checks against"*. A census is an instrument and inherits that contract,
  including the mutant rule at `:95-97`.

### The route split: 34 externs, three lowering paths

`lib/prelude/prelude.chiral:59-104` declares **34** externs, re-verified
2026-09-10 by `grep -c '^(extern '`. `erase-prim`
(`lib/lowering/tal/erase.chiral:153-170`) dispatches each name three ways:

| path | count | where | result |
|---|---|---|---|
| `op-parse` | 16 | `lib/lowering/tal/erase.chiral:90-107` | `en-prim`, a register operation. No memory seat |
| inlined by name | 3 | `:160-166`, `bget` / `blen` / `str-len` | `n-bget` / `n-blen`, a machine instruction |
| `prim2lib` | 15 | `:111-139` | `n-call` into a `native-lib` TIFn |

16 + 3 + 15 = 34.

### ⚑ The table and the dispatcher disagree, and the dispatcher wins

`prim2lib-table` carries `(pair "bget" "nb-bget")` at
`lib/lowering/tal/erase.chiral:135` and `(pair "str-len" "nb-blen")` plus
`(pair "blen" "nb-blen")` at `:113`. `erase-prim` tests those three names
**before** it consults the table (`:160-166`), so those three rows never fire on
the lowering path. `grep '"nb-bget"\|"nb-blen"'` over `lib/` and `prog/` returns
their own `ti-fn` headers (`lib/lowering/tal/bytes.chiral:54`, `:57`) and the
two table rows, and no `ti-call`. Both routines are emitted into `native-lib`
(`:636`) as dead entries.

A census keyed on `prim2lib-table` reports `bget → nb-bget`, which is a routine
nothing calls. The real read for `bget` is the inlined `ti-bget` at `:161`. The
row named the two-surface-names-one-routine hazard; this is a second hazard in
the same table, in the other direction.

Four surface pairs share one routine: `str-sub`/`bslice` → `nb-bslice`,
`str-cat`/`bcat` → `nb-bcat`, `str-len`/`blen` → `nb-blen`,
`str->bytes`/`bytes->str` → `nb-id`.

### The population: 7 of 34

A caller-supplied value reaches a byte-cell seat in seven externs, six distinct
routines. Six carry an **index**; `brepeat` carries an **extent** into
`ti-bnew`'s length seat, which is a different seat and a different failure.

| extern | prelude | route | routine | seat | at a small out-of-range value | at a far one |
|---|---|---|---|---|---|---|
| `bget` | `:97` | inline | `ti-bget`, `erase.chiral:161` | idx, arg 1 | returns a value, exit 0 | SIGSEGV, exit 139 |
| `str-sub` | `:83` | `prim2lib` | `nb-bslice`, `bytes.chiral:147` | start arg 1, end arg 2 | `(blen (bslice "abc" 0 99))` is **99**; start `-5` gives length **7** | reached through the same seats |
| `bslice` | `:98` | `prim2lib` | `nb-bslice`, same routine | same | same | same |
| `str-find-from` | `:85` | `prim2lib` | `nb-bfind-from`, `bytes.chiral:355` | start, arg 2 | forward `99`: sentinel `-1`, exit 255. backward `-5`: exit **2**, a plausible answer after reading before the buffer | SIGSEGV, exit 139 |
| `unpack-u32` | `:102` | `prim2lib` | `nb-unpack32`, `bytes.chiral:225` | off, arg 1 | returns a value, exit 0 | SIGSEGV, exit 139 |
| `unpack-u16` | `:104` | `prim2lib` | `nb-unpack16`, `bytes.chiral:246` | off, arg 1 | returns a value, exit 0 | SIGSEGV, exit 139 |
| `brepeat` | `:100` | `prim2lib` | `nb-brepeat`, `bytes.chiral:179` | count, arg 1, an extent | n/a | count `-3`: SIGSEGV, exit 139 |

Every behavioural cell was run this session against the committed
`bin/chirality-bin` under `( ulimit -s unlimited; ./bin/chirality run … )`, with
the probe an `(import "prelude/prelude")` and one
`(def compile-main (-> I64 I64) (lam (n) …))`, which is EN-31's method. Exit
codes are the returned `I64` modulo 256.

Five negative controls, all correct: `str-cat` 4, `bcat` 4, `str-eq` 7,
`pack-u32` 4, `str-find` 255.

### ⚑ Zero of the seven clamps

Two routines carry a guard. Both are partial, and neither clamps the
out-of-range index.

| routine | guard | covers | leaves |
|---|---|---|---|
| `nb-bslice` | `(ti-prim 4 (op-lti) 2 1)`, `lib/lowering/tal/bytes.chiral:150` | an inverted range `j < i` yields the empty slice | `j > len` and `i < 0`. The header at `:130-132` states the first exclusion in its own words |
| `nb-bfind-from` | `(ti-prim 6 (op-lei) 5 3)`, `:360` | `start + needle_len <= haystack_len`, returns `-1` | a negative start passes the test and reaches `nb-match`'s `ti-bget` at `:339-340` |

So the row's question *"which of those clamp"* has the answer **none**, and the
answer is not a two-valued one. Two members guard one case each, one of them to
a sentinel rather than to a clamped value.

### A third outcome is already built, in the same tree

`lib/lowering/tal/sys.chiral:1006-1010` states the doctrine: *"A real bounds
violation is a corpse: on size<=0 or off/len out of range the body takes the
arena-fail shape (exit_group(-EINVAL), never returns)"*. `nb-arena-fail-t`
(`:120-122`) is a live `ti-sys 231`, reached by `nb-pool-read` (`:1104`),
`nb-pool-write` (`:1070`), `nb-pool-create` (`:1014`) and `nb-arena-commit`
(`:133`). The outcome set over the tree is therefore at least four: a clamped
value, a sentinel, a silent unrelated value, and process death.

### The rungs, and what re-derives any of this today

| what exists | where | rung | reached by |
|---|---|---|---|
| the 34 extern declarations | `lib/prelude/prelude.chiral:59-104` | IMPLEMENTED | the compiler, every compile |
| `erase-prim`, the route authority | `lib/lowering/tal/erase.chiral:153-170` | IMPLEMENTED | `erase-instr`, `:181` |
| `native-lib`, 28 TIFns as a readable `(List TIFn)` | `lib/lowering/tal/bytes.chiral:636` | IMPLEMENTED | emission |
| `TIFn` / `TCode` / `TInstr` as ordinary data sums | `lib/lowering/tal/ir.chiral:19-49` | IMPLEMENTED | the whole tal path |
| a native census over the compiler's own output | `prog/optimizer-census.prog` (225 L) | IMPLEMENTED | `tools/test/opt-census.sh`, `8 passed, 0 failed` at `38ecdba` |
| the bug class, as one prose cell | `docs/definitions/bug-classes.md:46` | DESIGNED | nothing re-derives the cell |
| the repair for one routine | `E176`, `docs/elements/catalog.md:490` | design | no SPEC exists |
| the two known members, as a record | `records/enforcement-arc.md` EN-31 | measured 2026-09-10 | a hand probe |
| the call-site count for two of the seven, 242 | `records/bounds-residue.md` BR-06 | measured 2026-09-10 | a hand tokeniser |

**Nothing in `lib/`, `prog/` or `tools/` re-derives any row of the census
table above.** `grep -rn 'str-sub\|bslice' tools/test/` returns nine files, every
hit in range (EN-31), and `tools/test/run-tests.sh` reads `412 passed, 0 failed`
with all seven members as measured.

### Honest limits of this measurement

- **The domain is the prelude's 34.** `grep -rn '^(extern '` over `lib/` and
  `prog/` returns **73** externs across 20 files. The other 39 are ports and
  syscall faces and are outside the row's words.
- **The routine population is larger than the reachable-from-prelude set.**
  `ti-bget` and `ti-bput` occur **51** times in `lib/lowering/tal/bytes.chiral`
  and **24** times in `lib/lowering/tal/sys.chiral`. Most sit in routines
  (`nb-copy`, `nb-get-u64`, `nb-put-u64`, `nb-cell-i64`, the pool and arena set)
  whose offsets come from `lib/` callers rather than from a prelude extern.
- **The guard reading is structural.** "Two routines carry a guard" was read off
  the `ti-tcase` bodies. It is not a dominance analysis and does not prove that
  no other path reaches the read unguarded.

## 3. The delta

§2 answers the census question for 2026-09-10. That is exactly the artifact the
row refuses: *"Committed, re-runnable, not a session probe."*

1. **No committed instrument enumerates the externs or their routes.** The
   34-name list, the 16/3/15 split and the seven-member population were hand-read
   from three files this session.
2. **No committed instrument takes the outcome column.** Twelve probes were
   compiled and run by hand. They are gone when this session ends.
3. **Nothing reddens when the population changes.** A 35th extern, a new
   `prim2lib` row, a guard added to `nb-unpack32` or removed from `nb-bslice`
   all leave `412 passed, 0 failed` untouched. This is requirement 6's own
   blind spot turned on a class with no gate row, which `enforcement/N21`
   states as a separate row and does not fix here.
4. **The outcome vocabulary exists nowhere as a value.** `docs/definitions/bug-classes.md:46`
   holds one prose cell with a blank element column, and it names one member of
   seven.
5. **Two hazards in the structure are live and unrecorded.** The three inlined
   names whose `prim2lib` rows never fire, and `nb-bget` / `nb-blen` emitted
   dead into `native-lib`. Neither is named in any doc or record before this
   file.

**Verdict:** a real delta, and the delta is an instrument rather than a fact.
The fact is taken above and is a by-product.

## 4. The shapes

The tree does not settle this. `prog/optimizer-census.prog` is a precedent for
one half and covers neither the extern enumeration nor the behavioural half.

### Shape A: a native structural census

- **Form:** one `prog/` root. Reads `lib/prelude/prelude.chiral` on stdin,
  runs `lib/surface/sexp.chiral`'s `read-all-go` (`:261`) over the bytes and
  filters `(extern …)` heads, so the extern list is derived rather than
  hardcoded. For each name it **calls `erase-prim`** with a synthetic operand
  list and reads the `XI` arm (`lib/lowering/tal/erase.chiral:26`): `en-prim` is
  a register op, `n-bget` is the inline read, `n-call fname` names the routine.
  Then it folds `native-lib` (`lib/lowering/tal/bytes.chiral:636`, 28 `TIFn`s,
  an ordinary `(List TIFn)`) with a register-taint fixpoint: parameters
  `0..nparams-1` are tainted, `ti-prim` and `ti-const` propagate, `ti-call`
  propagates into the callee's parameter at the same position, and a hit is a
  tainted register in the index seat of `ti-bget` / `ti-bput` or the length seat
  of `ti-bnew`.
- **Costs:** one new `prog/` root, so Phase 7's sweep goes 93 → 94. Estimated
  260-320 lines on `prog/optimizer-census.prog`'s 225-line basis plus the taint
  fixpoint that file has no counterpart for.
- **Forbids:** it says nothing about what happens at runtime. A `ti-tcase` on a
  tainted register is presence of a branch, and §2 measured that a present guard
  covers one case out of three.
- **Reaches:** the whole population, including members nobody has thought of,
  and it reddens when the extern set or a routine body changes.

### Shape B: a native behavioural probe sweep

- **Form:** one `prog/` root reading a case index on stdin and dispatching a
  `case` over one call per arm, plus a bash gate that compiles it once and runs
  it N times, recording exit code and stdout per case. EN-31's method, promoted
  from a session probe to a committed pair. The separate process per case is
  required: a bounds violation is SIGSEGV and takes the process with it.
- **Costs:** one new root, 60-90 lines, plus the gate. Phase 7 goes 94 → 95 if
  taken beside A.
- **Forbids:** it cannot enumerate. Every case is a name somebody already wrote
  down, so the instrument is blind to the member it was not told about, which is
  the precise failure `enforcement/N18`'s *"two measured entries out of an
  unmeasured set"* records.
- **Reaches:** the outcome column exactly, over the four-value set §2 measured.

### Shape C: a Python tool under `tools/`

- **Form:** a text reading of `prelude.chiral`, `erase.chiral` and
  `bytes.chiral`.
- **Costs:** cheapest to write and it adds to a set the tree is deleting.
  Requirement 5 of [[arcs/enforcement-arc]] measures 12,671 lines outside the
  language against 782 native, and [[goals/self-tooling]] is the goal removing
  them.
- **Forbids:** a text reading of `erase-prim` is the naive reading §2 measured
  wrong twice: the table says `bget → nb-bget` and the dispatcher inlines, and
  two surface names share `nb-bslice`. A regex over `prim2lib-table` reproduces
  both errors.

### Shape D: a record row alone

- **Form:** §2's table written into `records/bounds-residue.md` with its date and
  citations, no instrument.
- **Costs:** zero. It is what this file already contains.
- **Forbids:** nothing reddens. The row's own words rule it out.

### Shape E: A and B as one layered element

- **Form:** both roots plus one bash gate. The structural half names the
  population and the routes; the behavioural half measures what each member
  does; the gate asserts that the two halves agree on the membership list and
  pins the outcome per member. A member the structural half finds and the
  behavioural half has no case for is a red row.
- **Costs:** two roots, Phase 7 goes 93 → 95, plus the gate.
- **Forbids:** it still does not prove a guard correct, and it does not repair
  anything. `E176` keeps `nb-bslice`'s repair whole.
- **Reaches:** both halves of the row's sentence. Neither A nor B alone does.

## 5. The call

- **Chosen: Shape E.** The row asks two questions in one sentence and §4
  measures that no single instrument answers both. A enumerates and cannot
  observe; B observes and cannot enumerate.
  [[banks/verification]] `:75-78` is the citation: verification here is a
  layered set of independent instruments each seeing only what is below its
  branch point, and the two halves branch at different stages. A reads the
  lowering; B reads the running ELF. The gate's expected values live in bash
  over both, which is the rank the same bank's `:95-97` requires of a gate row
  that must be able to fail.

### ⚑ How the instrument survives both answers to the clamp-against-trap call

The outcome column is **the observed behaviour at an out-of-range value**, over
a closed four-value set §2 measured in the tree: a clamped value, a sentinel,
a silent unrelated value, and process death. It is not the predicate *"does this
clamp"*.

- If the author rules **clamp**, the target reading for every member is
  `clamped value` and the instrument prints the same column.
- If the author rules **trap**, the target reading for every member is
  `process death`, `nb-arena-fail` is the built shape it names
  (`lib/lowering/tal/sys.chiral:120-122`), and the instrument prints the same
  column.

Under either ruling the gate pins whatever the ruling makes the target and
reddens on every member that has not moved. A census whose column read
*"clamps / does not clamp"* would be asking the wrong question under one of the
two answers. This one is not.

### This row's own questions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Is the domain the prelude's 34 externs or all 73 in the tree | RESOLVED | The row's own words are *"the prelude's externs"*. §2's honest limits record the 39 outside it and the 75 `ti-bget`/`ti-bput` sites the extern reach does not cover |
| 2 | Does `brepeat`'s extent belong in the same census as the six indices | RESOLVED | Yes, in its own column. The row's subject is a caller-supplied value reaching a memory seat, and `ti-bnew`'s length seat is one (`lib/lowering/tal/ir.chiral:26`). §2 measured `(brepeat b -3)` as SIGSEGV, which is the same failure through a different door |
| 3 | A native `prog/` root or a Python tool under `tools/` | RESOLVED | Requirement 5 of [[arcs/enforcement-arc]] and [[goals/self-tooling]]. §4 Shape C also measures the text reading as wrong on this specific structure |
| 4 | Does the instrument hardcode the extern list | RESOLVED | No. `lib/surface/sexp.chiral:261` reads `Bytes` and `prog/prose-lint.prog:42` is the precedent for a root reading source on stdin, so the list is derived and a 35th extern reddens the gate |
| 5 | Does this element repair anything | RESOLVED | No. `E176` owns `nb-bslice`'s repair and `docs/arcs/parts/diagnostics-L5.md` §6 already sizes that phase. This element measures and asserts |
| 6 | Whether requirement 6 should quantify over bug classes rather than gate rows | DEFERRED | `enforcement/N21`, which states it as its own row |
| 7 | Which element owns the four members this census adds | DEFERRED | `enforcement/N19` holds the instruction-level obligation and `enforcement/N18` the carrier. This row buys the number and assigns no repair |

### Author calls carried, and none answered here

Neither blocks this row, because §5's chosen shape is invariant under both
answers. Both stay `unreviewed`.

| call | where | bearing |
|---|---|---|
| **Which arc owns the bounds class** | `records/author-calls.md:363` | If it goes against enforcement this row moves whole with `N18`, `N19` and `N21`, keeping its id. The instrument and its contents do not change |
| **Is a clamp an enforcement outcome, or does it discharge the class by hiding it** | `records/author-calls.md:364`, and `docs/arcs/parts/diagnostics-L5.md:520` question 9 | Decides what `docs/definitions/bug-classes.md:46` may read after `E176` builds. The ⚑ block above states how this instrument prints the same column under either ruling |

`records/author-calls.md` was outside this run's write surface and no row was
added to it. This design opens no new author call.

## 6. The mint packet

- **Elements:** one. The structural half and the behavioural half constrain each
  other: the gate's central assertion is that the two membership lists agree,
  and a list agreeing with itself is the common-mode expectation
  [[banks/verification]] `:592-593` names as no expectation at all. Splitting
  them into two elements puts that assertion in neither.
- **Band:** `UNASSIGNED`. The arc's `E184-E189` band is spent and
  `docs/decisions/decision-lane-split.md:327` bars two focuses minting from one
  band concurrently. Per [[decisions/decision-work-ids]] and the 2026-09-06
  ruling that a band is advisory, the mint step assigns the number.
- **Catalog row:**
  `| E<NN> | **The caller-indexed byte-access census: which of the prelude's 34 externs carry a caller-supplied value into a byte-cell seat, and what each does out of range** | Not built. Two committed roots and one gate. The structural root derives the extern list from `lib/prelude/prelude.chiral` through `lib/surface/sexp.chiral`, calls `erase-prim` (`lib/lowering/tal/erase.chiral:153`) per name to read the route off the `XI` arm rather than off `prim2lib-table`, and folds `native-lib` (`lib/lowering/tal/bytes.chiral:636`) with a register-taint fixpoint. The behavioural root is EN-31's probe method committed: one case per member, one process per case, exit code and stdout recorded. Measured 2026-09-10 and re-derived by neither: **7 of 34** externs carry a caller-supplied value to a byte-cell seat, six an index and `brepeat` an extent, over six routines, and **zero of the seven clamps**. Two carry a partial guard: `nb-bslice` on the inverted range alone (`bytes.chiral:150`), `nb-bfind-from` on the forward direction alone, to a `-1` sentinel (`:360`). `str-find-from`, `unpack-u32`, `unpack-u16` and `brepeat` are four members no lens row, catalog row or ledger row names. The outcome column is the observed behaviour over four values, so the instrument survives both answers to the clamp-against-trap author call. | `OURS`; the census `records/enforcement-arc.md` EN-31 could not size | SH |`
- **Ledger row:**
  `| E<NN> | bounds-census | design | **The caller-indexed byte-access census over the prelude's 34 externs.** Requirement 1 of [[arcs/enforcement-arc]] cannot say why the capability is not at ENFORCED while its extent is uncounted. Two roots plus one gate; measures and asserts, repairs nothing. `E176` keeps `nb-bslice`'s repair. | `enforcement/N20`, EN-31, BR-06 | SH |`
  Category **MEM**, which owns byte cells per the legend at
  `docs/elements/ledger.md:63`. `E176` sits in **VAL** under module `string`
  (`:312`), and a census over the lowering rather than over one surface function
  is MEM's.
- **Size:** 3 new files, 2 edited.
  - `prog/<census>.prog`, 260-320 L. Basis: `prog/optimizer-census.prog` is
    225 L for a fold of comparable shape over the compiler's own output, and
    this adds the sexp filter and the taint fixpoint.
  - `prog/<probe>.prog`, 60-90 L. Basis: a `case` over one call per member,
    twelve arms at §2's case count.
  - `tools/test/<census>.sh`, 260-340 L. Basis: `tools/test/opt-census.sh` is
    306 L for four rows and four mutants.
  - `docs/elements/catalog.md` and `docs/elements/ledger.md`, one row each.
  - **Build cost:** no `lib/` change, so the first agreement is `C1 == C2`.
    Two new roots enter Phase 7's automatic sweep
    (`tools/test/run-tests.sh:175-176`, `grep -rl '^(def compile-main' lib prog`),
    taking it 93 → 95 compile-only roots. The gate carries a `not-a-phase:`
    declaration on the route eight sibling gates take, so `run-tests.sh`'s
    `412 passed, 0 failed` does not move. No build was run by this design.
- **Related:** [[arcs/enforcement-arc]] requirement 1, [[banks/verification]],
  [[banks/text]], [[banks/memory]], [[records/enforcement-arc]] EN-31,
  `records/bounds-residue.md` BR-06, `docs/arcs/parts/diagnostics-L5.md`,
  `docs/arcs/parts/enforcement-N18.md`, `docs/definitions/bug-classes.md`,
  [[goals/self-tooling]], `E176`.

Every `E#` named here is already minted. The follow-on rows are
`enforcement/N18`, `enforcement/N19` and `enforcement/N21`, all of which exist
in the arc's roster.
