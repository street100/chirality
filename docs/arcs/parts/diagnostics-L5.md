---
row: diagnostics/L5
arc: diagnostics
title: `str-sub` does not clamp: an out-of-range end index segfaults while a prelude comment claims otherwise
kind: law
origin: pair
req: 5
status: blocked
updated: 2026-09-19
---

# diagnostics/L5: `str-sub` does not clamp: an out-of-range end index segfaults while a prelude comment claims otherwise

> One roster row worked up, produced by the `element-design` run. This row is
> the unusual case: its element is already minted. `E176` was minted 2026-08-31
> by the E158 implement run, under the worked-example flow that
> [[decisions/decision-design-before-mint]] retired on 2026-09-05, and it never
> got an example. §6 is therefore a no-op packet: it records the design the old
> flow never produced so the row can reach a SPEC. The precedent is `85b76af`
> and `39be4bb`, which measured the same shape on `E163` / `file-types/K1`.

## 1. The obligation

- **The row:** the range discipline of the tree's substring primitive stops
  being a sentence in a comment and becomes a property of the code, and the
  consumer written against the false sentence is repointed at whatever
  replaces it. One primitive, one consumer, scheduled together per
  [[decisions/decision-primitive-with-consumer]].
- **Serves:** requirement 5 of [[arcs/diagnostics-arc]], *"The error-quality
  rows are closed. E182 arity evidence (closed 2026-09-02), E176 `str-sub`,
  E179 face registry. Two of the three are open, so this requirement stands
  unmet."*
- **Goal:** the tie is by the arc's requirement 5 and by
  `docs/decisions/decision-lane-split.md:255`, which puts *"the error-quality
  rows (E182, E176, E179) are closed"* in Lane A's definition of done. **The
  honest limit:** no done-condition of [[goals/readable-surface]] names memory
  safety. Condition 4, *"Regularity holds at the surface. One shape, one
  meaning"*, is the nearest fit and it fits by analogy rather than by its own
  terms: `str-sub` has one spelling and two meanings, the clamping one its
  callers were told about and the unclamped one it has. This row is scheduled
  by the arc's requirement, not by a goal condition, and that is a gap in the
  goal rather than in the row.

### Both halves, named

Per [[decisions/decision-primitive-with-consumer]], a row naming one half is
half a row.

| half | what | where |
|---|---|---|
| **primitive** | `str-sub`, and its alias `bslice`, gain a range discipline that the code enforces | `lib/prelude/prelude.chiral:83`, `:98`; `lib/lowering/tal/bytes.chiral:147` |
| **consumer** | `str-starts-with`, and the open-coded duplicate of it in scriba, stop resting on a false comment | `lib/prelude/string.chiral:14-17`; `prog/scriba/completion.chiral:5-10` |

Neither discharges the other. Repairing the primitive alone leaves two comments
in the tree asserting a property for a reason that is no longer the reason.
Repairing the consumers alone leaves 133 other call sites over an unguarded
primitive.

## 2. What the tree holds

Measured 2026-09-10 against the working tree at `1de4040`, unless a date says
otherwise. Every runtime measurement below was taken with the committed
`bin/chirality-bin` (1,220,984 B, dated 2026-09-08) under
`(ulimit -s unlimited; …)`.

- **Bank:** [[banks/text]]. The refraction is the point: what another language
  calls "safe substring" is here shard **A**, *"the byte/string floor: `str-len`,
  `str-sub`, `str-find`, `str-find-from`, `str-cat`; `blen`, `bget`, `bslice`,
  `bcat`"*, `docs/banks/text.md:47`, marked **built** with the defect named in
  the same cell: *"`str-sub` is unclamped, E176 / BA-35"*. Shard **B**,
  `:48`, *"derived string ops: starts-with, strip-prefix, contains, split, …"*,
  is also **built**, chirality over A. The bank's own limits list repeats it at
  `docs/banks/text.md:138-139`. **There is no phantom feature here.** The
  primitive exists, is built, is reached by the whole tree, and what is missing
  is a property of it. The bank is the authority that this row is a `law` over
  an existing shard and not a `primitive` that needs writing.

### The primitive, as it stands

| what exists | where | rung | reached by |
|---|---|---|---|
| `(extern str-sub (-> Str I64 I64 Str))`, a raw extern, no bounds behaviour in the type | `lib/prelude/prelude.chiral:83` | built (bank shard A) | 135 call sites, below |
| `(extern bslice (-> Bytes I64 I64 Bytes))`, the same primitive under a second name | `lib/prelude/prelude.chiral:98` | built (bank shard A) | 115 call sites, below |
| `prim2lib-table` maps **both** names to the single routine `nb-bslice` | `lib/lowering/tal/erase.chiral:115`, `(cons (pair "str-sub" "nb-bslice") (cons (pair "bslice" "nb-bslice")` | built | the lowering shuttle |
| `nb-bslice-t`, the one TAL implementation both names lower to | `lib/lowering/tal/bytes.chiral:147` | built | `lib/lowering/compile-emit.chiral:16` imports `lowering/tal/bytes`; `lib/lowering/compile-all.chiral:15` imports `compile-emit`; `prog/compiler.prog:13` imports `compile-all`. **Inside the closure, and it is emission** |
| the inverted-range clamp, and its own statement of what it does *not* cover | `lib/lowering/tal/bytes.chiral:128-132`: *"slice [i, j): an INVERTED range (j < i) yields the EMPTY slice instead of handing a negative length to the allocator … **j > len still faults: that is the other half of the range finding, and `str-starts-with` currently depends on it.**"* | built | — |
| the arm-tag trap recorded at the site: a swap of the two `ti-tcase` arms type-checks and is invisible until **gen3** | `lib/lowering/tal/bytes.chiral:134-144` | built | binds any future edit here |

### The three range cases, measured today

`str-sub` is `(s start end)`, half-open. Three ways out of range, and they are
in three different states.

| case | probe | result today | state |
|---|---|---|---|
| `end < start` | `(str-len (str-sub "abcdef" 5 2))` | **0**, the empty slice, exit 0 | **FIXED 2026-08-31.** `nb-bslice-t` clamps it, `lib/lowering/tal/bytes.chiral:150-155`. The SIGSEGV `PRB-47` records for `(str-sub "abc" 2 1)` does not reproduce. **Not re-designed here.** |
| `end > len`, small overrun | `(str-len (str-sub "abc" 0 99))` | **99**, exit 0. A `Str` of length 99 over a 3-byte buffer: 96 bytes of adjacent memory returned as string content, no error and no truncation | **UNTOUCHED. This is the live defect.** |
| `end > len`, large overrun | `(str-len (str-sub "abc" 0 999995))` | **SIGSEGV, exit 139** | **UNTOUCHED.** Same defect. Whether it reads garbage or dies is a question about page mapping, not about the code |
| `start < 0` | `(str-len (str-sub "abcdef" (- 0 2) 3))` | **5**, exit 0. It reads from two bytes **before** the buffer | **UNTOUCHED, and not previously recorded.** No lens row, catalog row or ledger row names this case. It is reachable from live code: `str-find` returns `-1` when the needle is absent (`lib/prelude/string.chiral:27`), and a start computed from an unchecked `str-find` is negative |

The catalog row's headline claim, *"an out-of-range end index SEGFAULTS"*
(`docs/elements/catalog.md:490`), is **true and incomplete**: it segfaults at a
large overrun and silently over-reads at a small one, and the silent case is
the worse of the two because nothing goes red.

### The consumer half, measured

| what exists | where | state |
|---|---|---|
| the false comment, and the function written on it | `lib/prelude/string.chiral:14`, *"; does s begin with prefix? (str-sub clamps, so a too-long prefix is just false)"*, and `str-starts-with` at `:15-17` calling `(str-sub s 0 (str-len prefix))` | **load-bearing and false.** With `prefix` longer than `s` this reads `(str-len prefix)` bytes out of an `s`-sized buffer |
| **a second, independent copy of the same false belief** | `prog/scriba/completion.chiral:5-7`, *"; str-sub clamps out-of-bounds indices, so a longer prefix automatically yields false — the clamped candidate is shorter and won't match"*, and `complete-prefix` at `:8-10` calling `(str-sub candidate 0 (str-len prefix))` | **not previously recorded anywhere.** It is not an importer of `str-starts-with`; it is an open-coded duplicate that re-derived the same wrong reason |
| `str-strip-prefix`, which calls `str-starts-with` as its guard | `lib/prelude/string.chiral:20-24` | inherits the over-read from its guard, then does a safe slice |
| `(str-eq (str-sub "ab" 0 25) "a-very-long-prefix-indeed")` via `str-starts-with` | probe today | returns **false**, exit 0. The *answer* is right; it was obtained by reading 23 bytes past a 2-byte buffer and finding they differed. Nothing makes them differ |

### The call-site census, measured, and the two claims kept apart

The arc, the catalog row (`docs/elements/catalog.md:490`) and the ledger row
(`docs/elements/ledger.md:312`) all say **131 call sites**. Measured today by
paren-balanced extraction over every `.chiral`, `.prog` and `.manifest` under
`lib/` and `prog/`:

| measurement | count |
|---|---|
| three-argument `str-sub` calls | **135** |
| `bslice` calls, the same primitive under its other name | **115** |
| **total calls through `nb-bslice`** | **250** |

The 131 is stale and low, and it counts only one of the two surface names.

**"135 sites" and "135 sites at risk" are different claims.** Classified by the
shape of the `end` argument:

| class | shape | count | reachability of `end > len` |
|---|---|---|---|
| **C1** | `end` is `(str-len <the same subject>)`, e.g. `(str-sub cmd 5 (str-len cmd))` | **46** | **unreachable by construction.** `end` is exactly the subject's length |
| **C3** | `end` is `(str-len <a different string>)` | **2** | **reachable, and it is the defect's own shape.** Both sites: `lib/prelude/string.chiral:17` and `prog/scriba/completion.chiral:10` |
| **C2** | everything else: literals, `(+ i 1)`, `str-find` results, arithmetic | **87** | **guard-dependent, and unmeasured here.** Each is in range iff a local guard holds. Auditing 87 guards is not this run's work and is not this element's work either |

So the honest statement is: **2 sites are structurally out of range and are the
consumer half of this row; 46 are provably safe; 87 rest on local guards that
nobody has checked.** The claim "131 sites at risk" is not supported by any
measurement in the tree, and this design does not make it.

### What the records say, and which rows are live

| row | where | state |
|---|---|---|
| `PRB-24` *"`str-sub` reads past the end of its string and reports the read length"* | `records/lenses/problems.md:328` | **OPEN**, owner `E176`, checked 2026-09-01, from `BA-35` |
| `PRB-47` *"`str-sub` clamps, says a load-bearing comment"* | `records/lenses/problems.md:655` | **OPEN**, owner `none`, checked 2026-09-01, from `FD-01` |
| `BA-35` | `records/baseline-alignment.md:388` | the origin of `PRB-24` |
| `FD-01` | `records/findings.md:28` | **RETIRED 2026-09-05**, content moved to `PRB-47`. Cited by `docs/decisions/decision-lane-split.md:341` as though live, which is a stale citation |
| catalog `E176` | `docs/elements/catalog.md:490` | Not built |
| ledger `E176` | `docs/elements/ledger.md:312` | `design`, category `string`, `←E158` |

### The type-level route, measured rather than assumed

The catalog row proposes *"give it a refined signature … so an unclamped call
does not typecheck"* and calls it *"the one the language exists to make
available"* (`docs/elements/catalog.md:490`). Four probes today, against the
committed binary:

| probe | result |
|---|---|
| `(=> (s Str) I64 (refine I64 (<= (str-len s))) Str)` | **`load: unknown name s`, exit 1.** A refinement atom cannot see a value binder introduced by an `=>` seat, so `end ≤ (str-len s)` is **not expressible** |
| `(-> (0 n I64) (=> Str I64 (refine I64 (<= n)) Str))` | **OK, exit 0.** A refinement *can* bound a seat by an erased index parameter |
| the same, applied as `(sub-safe 3 "abc" 0 99)` | **`load: cannot prove refinement`, exit 1.** The gate is real and refuses |
| the same, applied as `(sub-safe 3 "abc" 0 2)` | **OK, exit 0.** A good call passes |

The working pattern already exists in the tree: `lib/memory/mem-linear.chiral:27`,
`(-> (0 n I64) (=> (1 p (Pool n)) (refine I64 (>= 0) (< n)) Bytes (Pool n)))`.

**What that leaves.** The gate works when the bound is an erased index. `Str`
has no index to bind it to: it is `t-primty`, a bare primitive type,
`lib/surface/syntax.chiral:29`. So the index must be threaded by hand at every
call site and nothing ties it to the actual string. [[status-ledger]]'s
refinement row states the fragment's edge independently: atoms are *"over a
constant or a bare in-scope variable (`v < n`)"* with *"no arithmetic between
variables"*, and `(str-len s)` is neither.

### The ownership line the lane-split left open

`docs/decisions/decision-lane-split.md:336-341`: *"**E176's repair site.**
`str-sub` is an extern at `lib/prelude/prelude.chiral:83`, mapped to `nb-bslice`
at `lib/lowering/tal/erase.chiral:114`. Whether the fix is a guard in
`lib/prelude/string.chiral` or a change under `lib/lowering/` decides whether
diagnostics reaches enforcement's tree. The element has no SPEC and nothing
settles it."* §4 and §5 below are where that gets settled, and §5 records that
it is settled by a measurement rather than by preference.

## 3. The delta

§2 subtracted, what is missing:

1. **A range discipline for `end > len` and for `start < 0`.** The `end < start`
   case has one and the other two do not. The primitive has a clamp for exactly
   one of its three out-of-range cases, and the two without one are the two that
   read memory the string does not own.
2. **`start < 0` is not scheduled anywhere.** No lens row, catalog row or ledger
   row names it. It was measured for the first time in §2 above. It is the same
   defect in the same routine and it must not be repaired half-way again.
3. **Coverage of the second surface name.** Every artifact on this defect says
   `str-sub`. `bslice` is the same routine, `lib/lowering/tal/erase.chiral:115`,
   with 115 further call sites, and no artifact in the tree says so. A repair
   scoped to `str-sub` by name would either miss `bslice` or fix it silently.
4. **The two false comments.** `lib/prelude/string.chiral:14` and
   `prog/scriba/completion.chiral:5-7` each assert clamping as the reason their
   function is correct. Repairing the primitive would make both sentences
   accidentally true while leaving two functions whose stated reason for
   working is a property nobody chose to give them.
5. **A gate.** No phase of `tools/test/run-tests.sh` exercises an out-of-range
   `str-sub` or `bslice`. The defect is nine days old in the record and nothing
   would go red if it were reintroduced.
6. **Three stale numbers.** `131` in the arc, the catalog row and the ledger
   row, against a measured 135 + 115.

**Verdict: a real delta.** Two of three range cases unguarded, a second surface
name nothing names, two false comments, no gate.

## 4. The shapes

The tree does **not** settle this. `docs/decisions/decision-lane-split.md:339`
says so in as many words: *"nothing settles it."* Six forms, and the primitive
half and the consumer half are listed separately because they compose freely.

⚑ **Shape E was added 2026-09-10, and the four that preceded it were an
incomplete set.** `.planning/BOUNDS-AUTHOR-CALLS.md` §3.4 item 1 (`d9902a2`)
measured that this section offered four shapes and omitted a fifth the
principles do not distinguish from the chosen one: *"Clamp-and-return absorbs
the caller's error; clamp-and-trap (a checked abort that names the bad call)
closes the same crossing and keeps the signal. P1's 'gated shut', P3's membrane
and P4's physics are each satisfied by both."* Shape E is that shape, given the
same treatment as A, B, C and D, and §5 is re-tested against it below.

⚑ **Shape F was added 2026-09-19, and the five that preceded it were an
incomplete set on a second axis.** `records/findings.md` `FD-40` (`9a8c3bc`)
surveyed twenty-five pinned sources and measured that the field does not split
clamp against halt, it splits reporting against silent, and that a clamp with no
signal is the one shape nothing in the survey defends. A, B, C, D and E held no
arm for what the clamp camp actually ships. Shape F is that arm, given the same
treatment, and §5 is re-tested against it below. **It is written and refused, on
this tree's own terms, and the reason is in the arm.**

### The primitive half

#### Shape A: clamp in `nb-bslice-t`, at the one lowering site

- **Form:** extend the guard already at `lib/lowering/tal/bytes.chiral:147-160`.
  It presently branches on `j < i` and returns the empty slice. Add the two
  missing clamps: `j` to `len`, `i` to `0` (and then `i` to `j`). The result is
  a total function: every `(s, i, j)` yields a slice of `s`.
- **Costs:** the change is emission and inside `prog/compiler.prog`'s closure
  (§2), so it pays the generation sequence in full, first agreement at
  `C2 == C3`. It is the file whose own comment (`:134-144`) records that an
  arm-tag inversion here is invisible until gen3. Three or four extra
  `ti-tcase` branches in TAL, hand-written, in the routine with the tree's
  sharpest recorded trap.
- **Forbids:** an out-of-range call can no longer be *detected*. Silent
  truncation replaces silent over-read: `(str-sub "abc" 0 99)` returns `"abc"`
  and the caller's arithmetic error is absorbed. It makes the two false
  comments true by fiat, which is the outcome
  [[decisions/decision-primitive-with-consumer]] calls half a row unless the
  consumer half lands with it.
- **Reaches:** both surface names at once, all 250 call sites, because there is
  one routine.

#### Shape B: a refined signature on the extern

- **Form:** replace `(-> Str I64 I64 Str)` with a signature whose seats carry
  refinements, so an out-of-range call fails `chirality check`.
- **Costs:** **unconstructible in the form the catalog row proposes.** Measured
  in §2: a refinement atom cannot name an `=>` value binder, so
  `(refine I64 (<= (str-len s)))` is a load error. The constructible form is
  `(-> (0 n I64) (=> Str I64 (refine I64 (<= n)) Str))`, which type-checks and
  genuinely refuses bad calls, but requires a length index that `Str` does not
  have (`lib/surface/syntax.chiral:29`) and that nothing ties to the string. So
  the real cost of B is a length-indexed `Str`, which is a language element and
  not this row.
- **Forbids:** it forbids exactly the bad call, at check time, which is what
  this language is for. It also forbids every dynamic caller: any site whose
  `end` comes from `str-find` or from parsed input cannot discharge the
  obligation statically and needs a runtime narrowing.
- **Note:** [[status-ledger]]'s refinement row records that path-sensitive
  narrowing exists (`_narrow` / `narrow-branch`), so a guarded caller *can* in
  principle discharge a bound. Against a bare `n` it works; against `(str-len s)`
  it has nothing to work on.

#### Shape C: a total signature — `str-sub` returns an option

- **Form:** `(-> Str I64 I64 (Option Str))`, `none` out of range.
- **Costs:** 250 call sites, every one rewritten. `nb-bslice` would have to
  build a sum at the TAL floor, which is a much larger change to the same
  trapped routine than A.
- **Forbids:** it forbids ignoring the error, which is right, and it forbids
  `str-sub` in a value position, which is how nearly all 250 sites use it.

#### Shape D: a checked wrapper in `lib/prelude/string.chiral`

- **Form:** leave the extern alone; add `str-sub-safe` in chirality over
  `str-len` and the raw extern; repoint the consumers.
- **Costs:** the smallest change and it stays out of `lib/lowering/`, so it does
  not pay the generation sequence and does not cross into enforcement's tree
  (`docs/decisions/decision-lane-split.md:336-341`).
- **Forbids:** nothing. The raw extern stays reachable and unguarded, `bslice`
  is untouched, and the tree gains a second spelling that callers may or may
  not use. It converts a memory-safety hole into a convention, which is the
  form [[design-principles]] and this row's own premise reject: the defect
  *is* that a safety property was asserted in prose rather than enforced.

#### Shape E: a checked trap in `nb-bslice-t`, at the same lowering site

- **Form:** Shape A's branch structure with the opposite arm bodies. Where A
  returns a clamped slice, E calls a routine that never returns: `nb-arena-fail`
  (`lib/lowering/tal/sys.chiral:118-122`, one `ti-sys 231` and a sentinel
  `ti-ret`) under its own status, or `wrap-halt`
  (`lib/lowering/tal/sys-linkage.chiral:71-79`) with a message. `nb-bslice`
  becomes total on its in-range domain and ends the process outside it. The
  surface extern is untouched: `(extern str-sub (-> Str I64 I64 Str))` stays a
  pure arrow, and so does `bslice`.
- **Constructible today.** Measured, because two things could have forbidden it
  and neither does.
  - **The routine can reach a fail.** `lib/lowering/compile-emit.chiral:295`
    builds one image, `native-lib ++ link-lib ++ obj`, and `:168-170` records
    that the three share **one flat label namespace**. `nb-arena-fail-t` is in
    `sys-lib` (`lib/lowering/tal/sys.chiral:1308`, `:1340`) and `wrap-halt-t` in
    `link-lib` (`lib/lowering/tal/sys-linkage.chiral:98`), so a `ti-call` by name
    out of `native-lib` resolves.
  - **The precedent is in this tree and it is this defect.** `nb-arena-commit-t`
    calls `nb-arena-fail` on a ceiling overrun (`lib/lowering/tal/sys.chiral:139-141`)
    and `nb-pool-create-t` on `size <= 0` (`:1020-1021`). The file states the
    doctrine at `:1006-1009`: *"A real bounds violation is a corpse: on size<=0
    or off/len out of range the body takes the arena-fail shape
    (exit_group(-EINVAL), never returns) — the externs' return types carry no
    error arm …, so a fatal exit is control flow, not a value sentinel."* An
    out-of-range index already aborts here.
  - **It costs the surface types nothing.** The E76 chokepoint has two bindings.
    H7 requires every `ti-sys` in the whole image to name a registered function
    with a matching number, and `nb-arena-fail → 231` is already registered
    (`lib/lowering/tal/target-linux.manifest:57`). H8, the profile port set, is
    scanned over the object program's own reified fns and **explicitly not the
    byte runtime**: *"A crossing the substrate itself reaches (nb-arena-grow ->
    nb-sys-mprotect) is not charged to the composition, because it is not a port
    the composition chose"* (`lib/lowering/compile-emit.chiral:283-287`, and the
    call is `(manifest-offender ports obj)` at `:298`). So E needs no
    `crossing-wraps` row, no profile edit, no `=>`, and no change at any of the
    250 call sites.
- **Costs:** the same TAL edit in the same trapped routine as A, so the same
  build price: emission inside `prog/compiler.prog`'s closure, first agreement
  `C2 == C3`, gen3 mandatory (`lib/lowering/tal/bytes.chiral:134-144`). On top
  of that, four that are E's alone.
  - **It cannot name the bad call.** `nb-bslice-t` has three parameters and no
    source location, no caller identity, and no literal it can index: `ti-lit`
    addresses the *object program's* literal cell (`lib/lowering/tal/ir.chiral:25`)
    and the byte runtime is linked into every program, so a message is built one
    `ti-bput` per character, the pattern `wrap-halt-t` uses for its single
    newline (`lib/lowering/tal/sys-linkage.chiral:74-79`). E can say which
    primitive and which bound. Which of 250 sites called it, it cannot say.
  - **The trap fires inside the compiler.** `prog/compiler.prog` is a program
    that slices strings, so a stale guard anywhere becomes a compiler that exits
    on a floor status. `lib/typing/diag.chiral`'s ten-arm `Reason`
    (`.planning/LANGUAGE-INVENTORY.md:125`) has no arm for it and the message is
    not a diagnostic.
  - **The status is ad hoc.** The tree's fail codes are `1` and `2`
    (`lib/lowering/tal/sys.chiral:127-128`) and `-22` (`:1020`). No document
    lists them and nothing registers a new one.
  - **It buys nothing the type records**, exactly as A does not: three
    comparisons at 250 sites, and no seat carries the cost.
- **Forbids:** the silent over-read **and** the silent truncation. Shape A's own
  Forbids reads *"an out-of-range call can no longer be detected"*; E is the
  shape that keeps the detection. What it forbids in exchange is every use of
  `str-sub` that today survives on a wrong answer: the 87 C2 sites resting on
  unaudited local guards (§2) stop being guard-dependent and become
  abort-dependent, so a guard that is wrong today returns garbage and tomorrow
  kills the process. It forbids `str-find`'s `-1` reaching a `start` unchecked
  (`lib/prelude/string.chiral:27`), which is live. And it forbids the two
  consumers outright under Shape α: `str-starts-with` with a too-long prefix
  traps instead of returning `false`, so the consumer half **must** be β.
- **Reaches:** both surface names, all 250 call sites, one routine. Identical
  to A.
- **⚑ The type stays silent about the abort, and the mark that would carry it is
  the wrong mark.** The live Pi is
  `(t-pi (q Qty) (s Seat) (dom Term) (cod Term))` (`lib/surface/syntax.chiral:21`):
  no row seat, no totality-mark seat. The carrier that has them,
  `(q, row, grades⟨…⟩, totality-mark, dom, cod)`, is the target and not the
  present (`docs/decisions/decision-effect-facets.md:78-80`), and the same
  decision homes partiality there: *"`totality` keeps the partiality mark"*
  (`:107`). **`nb-bslice` could not carry that mark.** The mark is
  `docs/decisions/decision-graded-kernel.md:51-58`'s: *"Total by default,
  partiality is the marked climb"*, discharged by *"structural recursion plus
  strict positivity plus case coverage"*. It is a **termination** property and
  `nb-bslice` terminates. `docs/definitions/status-ledger.md:190` puts that
  pillar at IMPLEMENTED, classifying and refusing only under a `(total)`
  profile. So the mark neither describes the trap nor would catch it.

  The honest surface form is a different shape and it was measured too.
  Declaring `(extern str-sub (=> Str I64 I64 Str))` with a `crossing-wraps` row
  makes `str-sub` a port every profile must list. Four probes today against the
  committed `bin/chirality-bin`: `halt` is `(extern halt (-> (0 A (type 0)) (=> Str A)))`
  (`lib/ports/process.port:14`); a `(-> I64 I64)` def whose body calls it checks
  **OK**, so the crossing does **not** propagate to callers through the type; the
  same source under `(profile p (ports print) (target t))` fails with
  `E76 profile REFUSED emit: crossing halt (wrap-halt) is outside the declared profile port set`;
  and adding `halt` to the port list makes it pass. So the surface route's price
  is every profile in the tree, charged at emit rather than at check. The
  substrate route pays none of that price, and buys none of that containment.


#### Shape F: clamp in `nb-bslice-t` and return the clamped extent with it

⚑ **Added 2026-09-19 by a revisit against `records/findings.md` `FD-40`. The
five that preceded it were an incomplete set on a second axis.** `FD-40`
surveyed twenty-five pinned sources and reports that the field does not divide
clamp from halt: *"The axis the sources actually divide on is whether the
out-of-range condition survives the call in a form the caller can test."* Six
clamps and six traps both ship. Every clamp the survey finds endorsed in print
hands the truncation back: Go's `copy` *"returns the number of elements copied"*
and that number *"is the minimum of `len(src)` and `len(dst)`"* (`GOSPEC:7478-7484`),
`strlcpy` states the contract outright, `STRLCPY:229` *"the caller's
responsibility to handle this."*, and GCC's default diagnostic fires on exactly
the discard: it *"warns only about calls to bounded functions whose return value
is unused"* (`GCCWARN:7483-7484`), while the silent-clamp case next to it,
`strncpy` truncating without the terminator, is *"a common mistake, and so the
call"* is diagnosed (`GCCWARN:8983`). The survey's
two silent clamps, Python's slice and Lua's `string.sub`, are also its two for
which no source states any reason. Shape A is the silent clamp. This is the arm
the field's clamp camp actually occupies, and until now it was not on the ballot.

- **Form:** Shape A's branch structure and arm bodies, with a widened return.
  `(extern str-sub (-> Str I64 I64 SubR))` where `SubR` carries the clamped
  slice and the extent actually delivered, so a caller can compare it against
  the `(- j i)` it asked for. `bslice` likewise. Two constructible spellings,
  and they are different shapes rather than two styles of one.
  - **F1, a plain report.** `(data SubR () (sub-r (s Str) (got I64)))`.
  - **F2, a report the caller cannot drop.** The same sum with the witness
    linear, `(sub-r (s Str) (1 c Clamped))`, so the checker refuses a caller
    that ignores it. This is GCC's default diagnostic made a refusal rather
    than a warning, which is the substrate form of the same rule.
- **Both are constructible today, and the difference between them is the whole
  arm.** Four probes 2026-09-19 against the committed `bin/chirality-bin`
  (1,257,848 B, `30b288b`; §2's measurements were taken against the 1,220,984 B
  binary of 2026-09-08 and are not re-run here).
  - `(extern str-sub2 (-> Str I64 I64 SubR))` over `(sub-r (s Str) (got I64))`,
    with a caller that `case`s it and uses the count: **OK, exit 0.** A pure
    arrow may return a reporting sum.
  - The same, with a caller that `case`s it and **discards** the count: **OK,
    exit 0.** Nothing in the tree objects. `lib/typing/diag.chiral:121-141`'s
    ten-arm `Reason` has no unused-result arm, so F1's signal is advisory and
    the tree cannot tell a caller that tested it from one that did not.
  - The same sum with the witness linear, caller discards: **exit 1,
    `load: field binder usage mismatch`.**
  - The same, caller consumes the witness: **OK, exit 0.** So F2's report is
    enforced, by the quantity discipline the ledger already carries at
    **ENFORCED** rather than IMPLEMENTED: *"Quantities 0/1/ω resource
    counting"* and *"Linear types → port aliasing control"* are rows 161 and 162
    under `docs/definitions/status-ledger.md:156`'s **Built — ENFORCED**
    heading, each naming the gate that defends it
    (`tools/test/check-cli.sh`, `tools/test/linear-mint.sh`). So F2's refusal is
    not a property this row would have to build.
- **⚑ F2 is refused, and it is refused by a ruling this tree already took on
  this exact question at this exact floor.** `docs/elements/specs/E113-pool-read-SPEC.md:29-35`
  retired a two-arm out-of-range-as-value `pool-read` for three reasons, and two
  of them bite here. *"(3) the boundary-sums directive governs which-of-N
  classification, and errors-as-values (E29) governs genuinely-fallible ops — a
  bounds violation is neither"*: F2's linear witness is a per-call classification
  of the bounds condition, which is the shape that clause excludes, and the
  `ConnR` idiom it points away from (`docs/elements/specs/E29-sockets-SPEC.md:104`,
  `(conn-r (1 s Sock))` / `(conn-err (msg Str))`) is for an operation that can
  fail on the world's terms rather than on the caller's. *"(1) `pool-write`
  already halts on OOB, so a value-returning read would be an inconsistent
  pair"*: the same inconsistency is sharper here, because the sibling is in the
  same file. `nb-pool-read-t` (`lib/lowering/tal/sys.chiral:1104`) traps through
  `nb-arena-fail` on `off < 0` and again on `size < off + len` — **this row's own
  two live cases** — while returning a single-arm sum, and the file states the
  doctrine at `:1006-1009`: *"the externs' return types carry no error arm …, so
  a fatal exit is control flow, not a value sentinel."* A reporting `nb-bslice`
  puts a value sentinel for a bounds condition into the one runtime whose
  written rule is that it has none. That ruling is a spec-audit's and not the
  author's, so it is reported as binding until the author says otherwise rather
  than treated as settled doctrine. **Its third reason is not used here.** Clause
  (2), *"an OOB pool read is a caller logic bug … not a recoverable boundary —
  halt-as-assertion is correct"*, is an argument for Shape E, and adopting it
  would be ruling the fork this design holds for the author. It is recorded and
  left.
- **F1 survives that ruling and is dominated on cost.** F1 classifies nothing,
  so clause (3) does not reach it. What reaches it is the second probe: the
  report is droppable and nothing counts the drops, so at the 87 class-C2 sites
  resting on unchecked local guards (§2) F1 behaves exactly as A does unless
  each of those 87 is edited by hand — which is the audit §2 says is not this
  element's work. Meanwhile the return type moved, so every one of the 250 call
  sites is rewritten, and `nb-bslice-t` must build a sum at the TAL floor. Those
  are Shape C's two costs verbatim, and C buys the stronger property: C's `none`
  cannot be used as a `Str` by a caller who ignored it, and F1's clamped slice
  can. **F1 pays C's price for A's property.**
- **Costs:** the TAL edit of A or E in the same trapped routine, plus a sum
  built at that floor, plus 250 call-site rewrites, plus — under F2 — the
  87-guard audit that §5 names as Shape E's true scope. F2 moves that audit
  from runtime to `chirality check`: a guard that is wrong is a refusal the
  author sees before shipping rather than a process exit in a shipped program.
  That is the one thing F holds that neither A nor E does, and it is priced
  above both.
- **Forbids:** F1 forbids the silent over-read and forbids nothing else: the
  truncation is reported and the report may be ignored, so an out-of-range call
  is detectable and undetected, which is the state `GCCWARN:7483-7484` names.
  F2 forbids the silent over-read, the silent truncation and the discarded
  report: no caller of `str-sub` or `bslice` anywhere in the tree
  may leave the clamp untested, so all 87 C2 sites and both C3 sites must state
  what they do about it. What F2 forbids in exchange is `str-sub` in a value
  position at all 250 sites, which is Shape C's own Forbids, and it forbids the
  byte runtime's stated rule that a bounds condition is control flow and not a
  value.
- **Reaches:** both surface names, all 250 call sites, one routine, identical to
  A and E — and unlike them it does not reach them silently, because the return
  type change makes every site fail to check until it is edited.
- **⚑ What F measures about Shape A, and it cuts both ways.** Under A the
  clamped extent is already recoverable without any type change:
  `(str-len (str-sub s i j))` is strictly less than `(- j i)` exactly when a
  clamp fired, and `str-len` lowers to a single `ti-blen` instruction rather
  than a call (`lib/lowering/tal/erase.chiral:170`), so the test costs one
  instruction at the sites that choose to write it. So A's Forbids, *"an
  out-of-range call can no longer be detected"*, is right about the substrate
  and too strong about the caller: what A removes is detection by default, not
  detection. The other half of the same measurement is that this is precisely
  Python's shape — the extent is a projection of the returned value, obtainable
  and not presented — and `FD-40` files Python's slice among its two clamps that
  report nothing and state no reason. Neither half of that is a ruling. The
`(- j i)` comparison holds for `j > i`; the inverted range is already the
defined empty slice (§2) and reports nothing, which is correct because nothing
was clamped away.

### The consumer half

#### Shape α: delete the reason, keep the function

Repoint `str-starts-with` (`lib/prelude/string.chiral:15-17`) and
`complete-prefix` (`prog/scriba/completion.chiral:8-10`) onto whichever
primitive shape lands, and replace both comments with the property that is
actually true afterward.

- **Costs:** two functions, two comments.
- **Forbids:** nothing, and that is the objection: under Shape A both functions
  keep working for a new reason, so nothing in the tree would notice if the
  clamp were reverted.

#### Shape β: make the consumer independent of the range discipline

Write `str-starts-with` so it does not depend on out-of-range behaviour at all:
guard on `(<=i (str-len prefix) (str-len s))` first, then compare an in-range
slice. Same for `complete-prefix`, or make it call `str-starts-with` instead of
re-deriving it.

- **Costs:** one comparison per call in the tree's hottest string predicate.
- **Forbids:** it forbids the class of bug this row exists to close, at the two
  sites where it is structurally reachable, **independently of** whether the
  primitive is ever repaired — and it removes the duplicate derivation that
  produced the second false comment.

## 5. The call

- **Primitive half: the site is settled and the shape is not.** ⚑ **Re-tested
  2026-09-10 against Shape E and the choice did not survive as written.** The
  four reasons below are what this design offered for Shape A. Each of them is
  a reason against B, C or D, and **not one of them separates A from E**: E
  repairs the same routine, reaches the same 250 sites under both surface
  names, is constructible today (§4, measured), rewrites no call site, and is
  no convention. The site under `lib/lowering/` stands. Which of the two total
  repairs lands there is **NEEDS-AUTHOR**, carried below.

- **Was chosen, primitive half: Shape A**, clamp in `nb-bslice-t`.

  The reason is a measurement rather than a preference, and it is the one
  `docs/decisions/decision-lane-split.md:339` said nothing settled. **There is
  one routine and two surface names.** `lib/lowering/tal/erase.chiral:115` maps
  both `str-sub` and `bslice` to `nb-bslice`, so a repair anywhere else in the
  tree covers one name and leaves 115 or 135 calls on the other. Shape D is
  refused on the same ground and on `design-principles`: it answers a
  memory-safety hole with a convention, which is the defect restated. Shape C
  costs 250 rewrites for a property Shape A gives for three branches. Shape B
  is the form the catalog row asked for and §2 measured it unconstructible over
  a `Str` with no index; it is not rejected on merit, it is **not yet
  buildable**, and the thing it needs is named as a roster row below rather
  than deferred to a number that does not exist.

  **The repair is all three cases, not one.** `j` to `len`, `i` to `0`, then
  `i` to `j`. The `start < 0` case is measured in §2 and is unscheduled
  anywhere else; repairing two of three would repeat exactly the half-repair
  this row was opened to finish. This holds under A and under E alike: the
  branch set is the same and only the arm bodies differ.

- **⚑ A versus E, re-tested, and the one measurement that separates them.**
  The four reasons above discriminate B, C and D and are silent on E, so the
  paragraph they support was an argument for a set of one drawn from a set of
  four. Against the widened set exactly one asymmetry is measured rather than
  preferred, and it is in this design's own §2: **87 call sites (class C2) rest
  on local guards nobody has checked**, and §2 states that auditing them *"is
  not this run's work and is not this element's work either"*. That statement
  survives Shape A, which turns a bad guard into a truncated value. It does not
  survive Shape E, which turns a bad guard into a process exit, so E's true
  scope is `E176` **plus** an 87-site guard audit that no roster row holds. The
  other direction is equally measured and equally real: Shape A's own Forbids
  reads *"an out-of-range call can no longer be detected"*, and those same 87
  guards are what a trap would find. The same measurement reads as a cost from
  one side and as the point from the other, which is what makes it the author's
  and not this design's.

  **⚑ Re-tested again 2026-09-19 against Shape F, and the A-versus-E paragraph
  above did not survive as the whole of it either.** The paragraph is kept
  because its measurement stands: the 87 guards are still the one asymmetry that
  separates A from E, and it still reads as a cost from one side and as the
  point from the other. What `records/findings.md` `FD-40` (`9a8c3bc`) adds is
  that A and E are not the two ends of the field's axis. Twenty-five pinned
  sources divide on reporting against silent rather than on clamp against halt;
  six languages clamp and six trap, both ship widely, and **the shape nothing in
  the survey defends is a clamp that returns no signal** — which is Shape A as
  written, and specifically Python's spelling of it, one of the survey's two
  clamps that report nothing and state no reason. So the paragraph above was an
  argument between two arms drawn from a set of five that omitted the thing the
  clamp camp actually ships.

  **Three things the widened set adds, and none of them rules.** First, the
  survey does not hand the trap camp the argument either: no surveyed system
  reaches totality by clamping, and SPARK, which is Ada, proves the trap
  unreachable while Ada's dynamic semantics still raise `Constraint_Error`, so
  the static route (§4 Shape B) is measured as a discharge of E rather than a
  replacement for it. Second, the field's one recorded change of mind in the
  last two years ran toward termination: C++26 hardening moved out-of-bounds
  library access from undefined to *"evaluated with a terminating semantic"*
  (`CPPLIBINTRO:395`), and `FD-40` reports no proposal moving anything toward a
  clamp. Third, and the only one that touches Shape A's own text: the 87 guards
  are also what a *report* would find, and §4 Shape F measures that A leaves the
  clamp recoverable by a one-instruction length comparison but requires nothing
  of any caller and counts no caller that skips it. **Shape A's Forbids is
  therefore right about the substrate and too strong about the caller**, and
  that correction is recorded in Shape F rather than by editing the sentence §5
  quotes.

  **And the third arm is written and refused, so the ballot did not become a
  three-way choice.** Shape F's enforcing form is excluded by
  `docs/elements/specs/E113-pool-read-SPEC.md:29-35`, a ruling this tree already
  took on this question at this floor: a bounds violation is neither a which-of-N
  classification nor a genuinely-fallible op, and the sibling routine in the same
  file, `nb-pool-read-t` (`lib/lowering/tal/sys.chiral:1104`), already traps on
  this row's own two cases while returning a sum with no error arm. Shape F's
  advisory form survives that ruling and pays Shape C's full price for Shape A's
  property. **The author's fork stays A against E.** What changed is that it is
  now a fork whose third possibility was measured and closed rather than never
  raised.

  **Not ruled here.** Whether a clamp discharges the bug class or hides it is
  `records/author-calls.md:86`, `unreviewed`, and the clamp-versus-trap fork is
  `.planning/BOUNDS-AUTHOR-CALLS.md` §3.4 item 1. This design answers neither,
  and the 2026-09-19 revisit answered neither. It closes the gap that item
  named: the fork now has both of its arms written in the same form, so the
  question the author is asked is a real two-way choice. `status: blocked`
  already, and this widens what is blocked from a sequencing question to the
  primitive half itself.

- **Chosen, consumer half: Shape β**, and it is not optional. **This survives
  the widened set and it survives it harder.**

  Under Shape A alone, `str-starts-with` and `complete-prefix` keep returning
  the right answer for a reason they did not choose, and no test in the tree
  distinguishes the clamped primitive from the unclamped one at those sites. β
  makes each consumer correct on its own terms, which is what makes the pair
  one unit rather than a primitive with a comment edit attached. `α` is
  subsumed: both comments are rewritten either way. Under Shape E the argument
  stops being about witnessing and becomes about correctness: `str-starts-with`
  passes `(str-len prefix)` against `s`, so under a trap a too-long prefix is a
  process exit where the tree expects `false`, and `complete-prefix` is the same
  call at `prog/scriba/completion.chiral:10`. β is required by A and **forced**
  by E, so the consumer half is settled either way and the primitive half is
  what the author holds.

- **`origin` is `pair`**, per [[decisions/decision-primitive-with-consumer]]:
  *"A `pair` row names both halves in its `what` cell: the primitive, and the
  consumer that exercises it."* ⚑ **`docs/arcs/README.md:74` still lists only
  `new` · `bind` · `connect`.** The decision added the fourth value on
  2026-09-10 and the roster's own contract document was not updated. This
  design does not touch that file; it is reported.

- **What the build rule costs this element.** `nb-bslice-t` sits in
  `lib/lowering/tal/bytes.chiral`, reached from `prog/compiler.prog:13` →
  `lib/lowering/compile-all.chiral:15` → `lib/lowering/compile-emit.chiral:16`.
  It is inside the closure **and it is emission**, so per
  [[working-discipline]] the first agreement is **`C2 == C3`, not `C1 == C2`**,
  and a run stopping at `cmp C1 C2` would report failure on a correct build.
  Every generation carries `(ulimit -s unlimited; …)`; every artifact is checked
  non-empty before every `cmp`, because two empty files compare equal; the run
  stops after `C4` and reports sizes and the first differing char. On top of
  that, `lib/lowering/tal/bytes.chiral:134-144` binds this specific routine: an
  arm-tag inversion here type-checks and is invisible for two generations, so
  **gen3 is mandatory evidence and "the new compiler builds" is not evidence.**
  No build is run by this design stage.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Which of the five shapes repairs the primitive | **PARTLY RESOLVED, and ⚑ re-opened between two of them 2026-09-10** | **The site is settled.** One routine, two surface names: `lib/lowering/tal/erase.chiral:115`. Only a repair at `nb-bslice` reaches both, which refuses B, C and D and settles the ownership line left open at `docs/decisions/decision-lane-split.md:336-341`: the repair site is under `lib/lowering/`, so diagnostics does reach enforcement's tree for this element. **The shape at that site is not settled.** Shape A and Shape E occupy the same site with the same reach and the same build price, and no reason in this design separates them. See row 9 |
| 9 | **Clamp (A) or trap (E) at `nb-bslice`** | **NEEDS-AUTHOR** | Opened by `.planning/BOUNDS-AUTHOR-CALLS.md` §3.4 item 1 (`d9902a2`), which measured that this design's §4 held four shapes and omitted the fifth. Both are total repairs at one site; the principles satisfy both (P1, P3, P4, per that section); the one measured asymmetry is §2's 87 unaudited C2 guards, which A absorbs and E converts into process exits. The class question behind it is `records/author-calls.md:86` and stays `unreviewed`. **This design rules neither.** ⚑ **Re-tested 2026-09-19 against `records/findings.md` `FD-40` and the fork stays two-armed.** The finding measures the field as splitting on reporting against silent rather than clamp against halt, so §4 gained Shape F, the reporting clamp. F is written and refused on this tree's terms: `docs/elements/specs/E113-pool-read-SPEC.md:29-35` excludes a bounds violation from the boundary-sums and errors-as-values idioms, and `nb-pool-read-t` already traps on this row's two cases in the same file. The citation on this line read `:364` until 2026-09-19; `:364` is the blank line under a heading at `:363` that closed on 2026-09-02, and the clamp row is at `:86` |
| 2 | Does the clamp cover `start < 0` as well as `end > len` | **RESOLVED** | Measured in §2: `(str-sub "abcdef" (- 0 2) 3)` returns 5 and reads before the buffer. Same routine, same defect, and [[working-discipline]]'s build rule makes a second pass over this file expensive enough that splitting it is the wrong economy |
| 3 | Does the repair cover `bslice` | **RESOLVED** | It cannot avoid it. `lib/lowering/tal/erase.chiral:115` maps both names to `nb-bslice`. The catalog and ledger rows must stop saying `str-sub` alone |
| 4 | Is the refined signature the right end state | **DEFERRED** to roster row `text-tools/L6`, **which does not yet exist and is not opened by this run** | §2 measured the refined form constructible only over an erased index, and `Str` is `t-primty` with no index (`lib/surface/syntax.chiral:29`). A length-indexed `Str` is a language element belonging to [[arcs/text-tools-arc]] and its bank shard A, not to this arc. Per [[working-discipline]]'s deferral rule this names a row and no `E#`. **The row is owed and this design does not open it**, because a design run may write only its own artifact; opening it is reported as work owed |
| 5 | What gate proves the repair | **RESOLVED** | A new phase of `tools/test/run-tests.sh` over the three range cases in both surface names, plus a mutant that reverts each clamp arm. `lib/lowering/tal/bytes.chiral:134-144` forces the mutant set to be **run at gen3**, not at gen1 |
| 6 | Are the two false comments deleted or corrected | **RESOLVED** | Corrected to state the property the code then has, at both `lib/prelude/string.chiral:14` and `prog/scriba/completion.chiral:5-7`. Under Shape β each function no longer depends on the clamp, so each comment states its own guard rather than a property of a callee |
| 7 | **Sequencing: does `E176` go before the other Lane A candidate** | **NEEDS-AUTHOR** | Carried verbatim in the box below. This design answers it nowhere |
| 8 | Do the three stale `131` counts get corrected, and by whom | **DEFERRED** to the mint/SPEC stage for `E176` | The arc file, `docs/elements/catalog.md:490` and `docs/elements/ledger.md:312` all read `131`; measured 135 `str-sub` + 115 `bslice`. A design run may not write those files |

### NEEDS-AUTHOR, carried verbatim

From `docs/arcs/diagnostics-arc.md:88-96`:

> ⚑ **Sequencing, raised by the author and undecided.** `E176` is sharper than
> E182 on consequence: `str-sub` is unclamped, segfaults, has 131 call sites, and
> its safety was asserted in a comment that `str-starts-with` was built on. Both
> are in Lane A's definition of done. On sharpness alone E176 goes first. The
> row is in `records/author-calls.md`. `lib/typing/kernel.chiral` and
> `lib/typing/diag.chiral` are both inside `prog/compiler.prog`'s closure, so
> E182 promotes. Its blob and binary deltas will carry 13 commits of other arcs'
> work unless a re-promotion lands first, so the SPEC states which of the two it
> reports.

And from `records/author-calls.md:397-403`:

> ⚑ **A sequencing note the flag did not ask and the author raised.** `E176` is on
> this arc, unbuilt, and is sharper than E182 on consequence: `str-sub` is
> unclamped, segfaults, has 131 call sites, and its safety was asserted in a
> comment that `str-starts-with` was then built on. E182 buys two error messages
> that gain their numbers. Both are in Lane A's definition of done. On sharpness
> alone E176 goes first, and that is a sequencing question rather than a scope
> one, so it decides nothing here.

**One fact bears on it and is recorded without answering it:** the arc records
E182 as **BUILT 2026-09-02**, five commits `65bec90` to `bd042ae`
(`docs/arcs/diagnostics-arc.md:101`, and roster row `diagnostics/V2` state `built` at `:250`).
Whether that disposes of the question, or whether the question was always about
a policy that outlives this pair, is the author's to say. `status: blocked`
until it is said.

## 6. The mint packet

**⚑ This packet is a NO-OP. Do not mint. Do not write a catalog row or a ledger
row.**

The element is **`E176`, already minted** 2026-08-31 by the E158 implement run.
`diagnostics/L5` carries `E176` in its roster `element:` cell today. This packet
exists to record the design the retired worked-example flow never produced, so
that `pack.py --spec` has a rationale artifact to read and the row can reach a
SPEC at all. The precedent is `85b76af` and `39be4bb`: 186 catalog elements,
122 with an example, 73 without, and 47 of those 73 in ledger state `design` —
minted, unbuilt and unspeccable, because
[[decisions/decision-design-before-mint]] retired the example stage on
2026-09-05 and `docs/examples/` is closed to new writes. The escape measured
there is an `element-design` run on the roster row whose element cell already
names the orphan, with the mint declared a no-op. This is that run.

- **Elements:** **one, and it already exists.** The primitive half and the
  consumer half are one element because they are unbuildable apart: Shape β's
  guard is only correct once the primitive is total, and a total primitive is
  unwitnessed without a consumer that stops depending on the old behaviour
  (under Shape A) or unshippable without one (under Shape E, which would trap
  at both consumer sites).
  The precedent for one element over a pair is
  `docs/arcs/parts/part-split-PS1.md` §6, cited by
  [[decisions/decision-primitive-with-consumer]].
- **Band:** **not drawn.** `E176` predates the band. For the record, this arc's
  reserved block is `E184-E189`, shared with [[arcs/enforcement-arc]]
  (`docs/decisions/decision-lane-split.md:31`, `:280`), and `docs/decisions/decision-lane-split.md:327`
  records that two focuses cannot mint from it concurrently. **No number is
  drawn by this run.**
- **Catalog row:** **none written.** `docs/elements/catalog.md:490` already
  holds `E176`. Three of its statements are measurably stale and the SPEC stage
  owns the correction, not this run: the count `131` (measured 135 `str-sub` +
  115 `bslice`); the scope `str-sub` alone (the routine is `nb-bslice`, reached
  by both names, `lib/lowering/tal/erase.chiral:115`); and the proposal
  *"give it a refined signature … The refined route is the one the language
  exists to make available"*, which §2 measured unconstructible over a `Str`
  with no index.
- **Ledger row:** **none written.** `docs/elements/ledger.md:312` already holds
  `E176`, category `string`, state `design`, `←E158`. The state stays `design`;
  this run produces a design, and the audit gates it. The category `string` is
  arguably wrong now that the repair site is `lib/lowering/tal/bytes.chiral`,
  and that is the SPEC stage's call.
- **Roster:** `diagnostics/L5` moves `open` → `designed`, which
  `tools/pack/pack.py` wrote into `docs/arcs/diagnostics-arc.md:257` as a side
  effect of the bundle command. **That edit is the tool's, not this run's.**
- **Size:** four files, and the estimate's basis is given per file. ⚑ **The
  table below is Shape A's.** Shape E touches the same four files at the same
  scale: its `nb-bslice-t` arms call a fail routine instead of allocating an
  empty slice, which is fewer TAL instructions per arm, and it adds one
  registry consideration (`nb-arena-fail` reused under a distinct status, or a
  new `ti-sys 231` row beside `lib/lowering/tal/target-linux.manifest:57`). The
  gate row changes shape: assertions over returned lengths become assertions
  over exit statuses. Nothing in the size estimate turns on the fork, so the
  packet is not re-derived for E.

  | file | change | lines | basis |
  |---|---|---|---|
  | `lib/lowering/tal/bytes.chiral` | two further clamps in `nb-bslice-t`, `:147-160` | **+25 to +40** | the existing single clamp is 4 lines of `ti-tcase` plus its arms at `:150-155`; two more comparisons with the same shape, plus register renumbering, plus the comment at `:128-132` rewritten to state what is now covered |
  | `lib/prelude/string.chiral` | `str-starts-with` (`:15`) gains its own guard, and the false comment above it is rewritten | **+4 to +6** | one `cond` over `(<=i (str-len prefix) (str-len s))` around a 3-line body |
  | `prog/scriba/completion.chiral` | `complete-prefix` calls `str-starts-with`, or gains the same guard; `:5-7` rewritten | **+3 to +6** | a 3-line body and a 3-line comment |
  | `tools/test/<new>.sh` + a `.prog` fixture | the gate: three range cases × two surface names, plus a mutant per clamp arm | **+120 to +200** | `tools/test/doc.sh` is 26 assertions; `tools/test/render-doc.sh` is 19 assertions with 11 mutants. This gate is nearer the smaller of those in assertion count and carries 3 mutants |

  **The cost is not in the lines.** It is in the generation sequence: the change
  is emission inside the closure, so `C1`…`C3` minimum with a non-empty check
  before every `cmp`, and `lib/lowering/tal/bytes.chiral:134-144` requires the
  mutant set to be exercised at **gen3**, because an arm-tag inversion here is
  invisible at gen1 and gen2.

- **Related:** [[banks/text]] shard A · [[arcs/diagnostics-arc]] req 5 ·
  [[decisions/decision-primitive-with-consumer]] ·
  [[decisions/decision-design-before-mint]] · [[decisions/decision-lane-split]]
  `:255`, `:336-341` · [[working-discipline]] the build rule and the deferral
  rule · `records/lenses/problems.md` `PRB-24`, `PRB-47` ·
  `records/baseline-alignment.md` `BA-35` · [[status-ledger]] the refinement row.

Every `E#` named here is already minted. The one deferral, question 4, names a
roster row that is **owed and not opened**, per the deferral rule.
