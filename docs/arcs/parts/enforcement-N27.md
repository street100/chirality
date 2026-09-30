---
row: enforcement/N27
arc: enforcement
title: extern honesty, an extern whose declared type holds no `=>` seat lowers to code that reaches no crossing, refused where the arrow is read
kind: law
origin: new
req: 1
status: draft
updated: 2026-09-30
---

# enforcement/N27: extern honesty, a pure-declared extern reaches no crossing

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** an extern whose declared type carries no `=>` seat anywhere in its
  Pi spine lowers to code that reaches no crossing, and a program that declares
  one whose lowering does reach a crossing is refused by the compiler. `E171`
  reads the declared arrow as the trust root
  (`docs/arcs/parts/enforcement-N26.md:231`), so the membrane is sound only
  where this holds.
- **Serves:** requirement 1 of [[arcs/enforcement-arc]], "A capability sits at
  ENFORCED, or its ledger row says why it does not." `E171`'s capability cannot
  sit at ENFORCED while its trust root is unchecked.
- **Goal:** [[goals/enforcement]], condition 1.

## 2. What the tree holds

Measured 2026-09-30 at `d47f5ce`.

- **Bank:** [[banks/port]], Shard 3 (`docs/banks/port.md:136-145`) reads the crossing bit
  off the extern's type, derived by `ty-crosses`
  (`lib/typing/kernel.chiral:315-319`), and the bank grades the derivation
  *"sound for an `extern`"* (`docs/banks/port.md:147-148`). The probe below
  measures that grade false: the derivation reads the declared type, and the
  lowering routes by name.

### The predicate and the population

The predicate is `ty-crosses` false: no `=>` seat on the Pi spine
(`lib/typing/kernel.chiral:318`). `grep -rnE '\(extern [^ ]+ \(->' lib prog`
returns 44 lines. One is a comment (`lib/lowering/tal/bytes.chiral:638`), so 43
declarations open with `->`, matching the `N26` design's 43
(`docs/arcs/parts/enforcement-N26.md:264`). Five of the 43 carry an erased outer
binder and a `=>` inside: `pool-write`, `pool-read`, `pool-close`
(`lib/ports/pool.port:27-31`), `exit` and `halt`
(`lib/ports/process.port:13-14`). `ty-crosses` reads them as crossings, so they
are honest by declaration. **The population is 38**: 35 in
`lib/prelude/prelude.chiral` (`:59-104`, `:130`) and three in
`prog/prapanca/backend.chiral` (`:38`, `:44`, `:57`).

### Where an extern's implementation lives

The route is chosen by **name**, in one order, at `erase-instr-onto`
(`lib/lowering/tal/erase.chiral:218-228`) and `erase-prim` (`:158-173`):

| step | table | where | lands on |
|---|---|---|---|
| 1 | `crossing-wraps`, 44 rows | `lib/lowering/tal/crossing-wraps.chiral:13` | a wrapper or `nb-sys-*` `TIFn` in `link-lib` |
| 2 | `op-parse`, 16 ops | `lib/lowering/tal/erase.chiral:91-107` | one `en-prim` register op |
| 3 | `bget`, `blen`, `str-len` inline | `:160-166` | one `n-bget` or `n-blen` |
| 4 | `prim2lib-table` | `:112-143` | a `ti-call` into a named routine |
| 5 | none | `:173` | `prim not in native subset`, compile fails |

The routines are hand-written `TIFn`s: `native-lib`, 30 of them
(`lib/lowering/tal/bytes.chiral:813-826`), and `link-lib`, the four `wrap-*`
plus `sys-lib` (`lib/lowering/tal/sys-linkage.chiral:98-99`,
`lib/lowering/tal/sys.chiral:1308`). A syscall is the one instruction `ti-sys`
(`lib/lowering/tal/ir.chiral:33`). `emit-elf-m` builds the image as
`native-lib ++ link-lib ++ obj` and runs `ck-tiprog` over it
(`lib/lowering/compile-emit.chiral:295-296`), which checks every `ti-sys` against
the `sys-row` manifest (`lib/lowering/tal/target-linux.manifest:20`), keyed by
the function's own name (`lib/lowering/tal/sys-check.chiral:31-45`). It walks one
function at a time and follows no `ti-call`.

### No pure-declared extern crosses today

A scratchpad probe parsed every `TIFn` in `bytes.chiral`, `sys.chiral` and
`sys-linkage.chiral` (97 functions, 40 holding a `ti-sys`), routed each of the 38
by the order above, and walked `ti-call` edges transitively. Results:

- none of the 38 names is a `crossing-wraps` key, and the two tables share no key;
- 16 route to `op-parse` and 3 inline, one instruction each;
- 19 route through `prim2lib-table` to 13 distinct routines, every one in
  `native-lib`, with a transitive reach of one to three functions and **zero
  `ti-sys`**;
- the walk is live: from `nb-pool-read` it reaches `nb-arena-fail`, whose
  `ti-sys 231` it reports (`lib/lowering/tal/sys.chiral:120-122`).

`prog/prapanca/backend.chiral:40-44`'s comment claim holds: `backend-close`
routes to `nb-be-close` (`lib/lowering/tal/erase.chiral:133`), which reaches
nothing.

### The tree admits a lie, measured

The route reads the name and never the declared type. A program that does not
import `lib/ports/stdio.port` declares `(extern print (-> Str Unit))`, where the
port's own declaration is `(=> Str Unit)` (`lib/ports/stdio.port:10`), and calls
it from a def typed `(-> I64 I64)`. `bin/chirality run` on it prints `crossed`
and exits 7. `E171` accepts the def, `crossing-wraps` routes `print` to
`wrap-print` (`lib/lowering/tal/crossing-wraps.chiral:15`), and the write
syscall runs inside a pure def. `load-extern`
(`lib/module/loader.chiral:457-468`) refuses a redeclaration and a non-type and
nothing else. The same lie reaches the datasheet: `crossings-of`
(`lib/module/loader.chiral:218-228`) reads `sig-prim-crosses`, so the module
reports no crossing bound.

### What "crossing" excludes

`TCode` never reaches the allocator. `ti-bnew` and `ti-cona` lower to
machine code that calls `arena-grow`, which calls `nb-arena-grow`
(`lib/lowering/x64/mach.chiral:522`, `:559`), and that reaches `mprotect` and
`exit_group` through `sys-lib`. The compiler already states this substrate is
not a crossing a composition chose (`lib/lowering/compile-emit.chiral:206-211`,
`:282-288`), and `E171` accepts every allocating `->` def. So "reaches a
crossing" is a `ti-call` walk over `TCode` to a `ti-sys`, and the row's literal
"issues no syscall" fails for every allocating routine and names a different
property.

### The neighbour, and the reach

| what exists | where | rung | reached by |
|---|---|---|---|
| declared-arrow bit | `ty-crosses`, `lib/typing/kernel.chiral:315` | ENFORCED | `E171`'s refusal, `crossings-of` |
| route by name | `erase-instr-onto`, `lib/lowering/tal/erase.chiral:218` | IMPLEMENTED | every compile |
| per-function `ti-sys` chokepoint | `ck-tiprog`, `lib/lowering/tal/sys-check.chiral:71` | ENFORCED | `emit-elf-m`, `compile-emit.chiral:296` |
| object-code wrapper scan | `xw-fns`, `lib/lowering/compile-emit.chiral:253` | ENFORCED | profiled programs only, object functions only, no transitivity |
| extern census over `prelude.chiral` | `E198`, `docs/elements/catalog.md:650` | DESIGNED | nothing, unbuilt |

**No transitive reach exists.** `ck-tiprog` and `xw-fns` each stop at one
function. `E198` (the `N20` row) is at `design`
(`docs/elements/ledger.md:473`), and its designed root folds `native-lib` alone
with a taint fixpoint (`docs/arcs/parts/enforcement-N20.md:210-220`), so it would
miss `link-lib`, and it keys on index seats rather than arrows.

## 3. The delta

Two halves, each unsound without the other:

1. **The name half.** Nothing joins a declaration's `ty-crosses` to the route its
   name takes. The probe crosses from a pure def through a `->` extern named
   `print`.
2. **The routine half.** Nothing states, and nothing checks, that the routines
   steps 2 to 4 land on reach no `ti-sys`. It holds today by the probe, and
   `prim2lib-table` pointing one name at a `sys-lib` routine would link: the
   image carries `link-lib` (`compile-emit.chiral:295`).

**Verdict:** a real delta. The tree's 38 declarations are honest; the compiler
admits a dishonest one from any program.

## 4. The shapes

### Shape A: refuse at load, close the pure library at emit
- **Form:** `load-extern` refuses an extern with `ty-crosses` false whose name is
  a `crossing-wraps` key, with a new `Judg` arm. Beside `ck-tiprog` in
  `emit-elf-m`, a closure check: every `native-lib` function holds no `ti-sys`
  and calls only `native-lib` names, and every `prim2lib-table` value names a
  `native-lib` function.
- **Costs:** the loader imports `lowering/tal/crossing-wraps`, a leaf over
  `prelude` alone (`crossing-wraps.chiral:11`) already inside the compiler blob
  through `sys-linkage`. One walk of 30 functions per compile.
- **Forbids:** a pure declaration of a crossing name, in any program. A `=>`
  declaration over a pure route stays legal, which `E159` needs
  (`prog/prapanca/backend.chiral:33-37`).

### Shape B: carry the bit to the route, refuse at erase
- **Form:** the lowering's prim record carries `ty-crosses`, and
  `erase-instr-onto` refuses a crossing route for a non-crossing prim. Same
  closure check at emit.
- **Costs:** the bit threads through `lowering/lowspec` and `compile-back`'s prim
  tables (`lib/lowering/compile-back.chiral:137-142`), a carrier change on the
  shipping path for one boolean the loader already holds.
- **Forbids:** the same programs, reported at compile rather than load, after
  the kernel has accepted the lie.

### Shape C: an out-of-closure census and gate
- **Form:** one `prog/` root on `E198`'s Shape A pattern, deriving the extern
  list from the tree's sources, routing, and walking the image.
- **Costs:** one root, one gate, nothing on the shipping path.
- **Forbids:** nothing a program does. It measures the tree's 38 and is blind to
  the probe above, which declares its extern outside every file the census
  reads.

## 5. The call

- **Chosen:** Shape A. `E171` refuses at the kernel from the declared bit, so
  the declaration is checked where the bit is first stored. The loader already
  reads the same bit at `crossings-of`. The routine half is a fact about the
  image `emit-elf-m` assembles, so it runs where `ck-tiprog` runs, on the E76
  precedent (`lib/lowering/tal/sys-linkage.chiral:103-111`). B checks the same
  thing later and spends a carrier. C is rejected under
  `.planning/protocol/reconcile.md` §"Proper or not at all": it closes the
  tree's population and leaves the hole the probe measured.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Is "crossing" `ti-sys` reached through `TCode`, or any syscall including the allocator's | RESOLVED | `lib/lowering/compile-emit.chiral:206-211` and `:282-288` exclude the substrate, and `E171` accepts allocating `->` defs; charging it would make every allocating def dishonest |
| 2 | Is a `=>` declaration over a pure route refused | RESOLVED | no. `E159` makes a linear mint cross with no syscall (`prog/prapanca/backend.chiral:33-37`) |
| 3 | Are the five erased-outer externs in scope | RESOLVED | no. `ty-crosses` reads the whole spine (`lib/typing/kernel.chiral:318`), so they declare a crossing |
| 4 | Does the front end importing a lowering table breach layering | RESOLVED | the leaf is prelude-only data (`lib/lowering/tal/crossing-wraps.chiral:1-11`) and already in the blob; no module enters the closure |
| 5 | Does `E198` own the routine half | RESOLVED | no. It measures index seats over `native-lib` and refuses nothing (`docs/elements/catalog.md:650`) |

No NEEDS-AUTHOR.

## 6. The mint packet

- **Elements:** one. The name half is sound only when the pure routes are pure,
  and the closure check buys nothing while a name can reach a wrapper, so the two
  constrain each other.
- **Band:** none. `E184-E189` is spent and bands are advisory
  (`docs/decisions/decision-lane-split.md:39-49`); `--mint` takes the next free.
- **Catalog row:**
  `| E<NN> | **Extern honesty: a pure-declared extern reaches no crossing.** \`load-extern\` refuses an extern whose type carries no \`=>\` seat and whose name is a \`crossing-wraps\` key; \`emit-elf-m\` refuses an image whose \`native-lib\` holds a \`ti-sys\` or calls outside itself, or whose \`prim2lib-table\` names a routine outside it | law | none | internal | \`E171\` reads the declared arrow as its trust root, and the route reads the name; a \`(-> Str Unit)\` \`print\` crosses from a pure def today (\`enforcement/N27\` §2) | SH |`
- **Ledger row:**
  `| E<NN> | extern-honesty | module/loader, lowering/compile-emit | design | **A pure-declared extern reaches no crossing.** \`E171\`'s trust root. The tree's 38 are honest, measured 2026-09-30; a program's own declaration is unchecked. | \`enforcement/N27\`, EN-38 | SH |`
- **Size:** about six files and 120 to 160 lines. `lib/module/loader.chiral`
  about 15 lines on `load-extern`'s 12 (`:457-468`); `lib/typing/diag.chiral` one
  `Judg` arm and its rendering; `lib/lowering/compile-emit.chiral` about 40 lines
  on `xw-fns`' 26-line walker (`:231-263`); two refusal samples under
  `prog/samples/` at about 8 lines each, the probe above being one; gate rows
  with three mutants (drop the load refusal, point one `prim2lib-table` value at
  `nb-sys-write`, add a `ti-call` to `nb-arena-fail` in one `native-lib`
  routine). Rebuild to `C1 == C2`.
- **Related:** [[arcs/parts/enforcement-N26]], [[arcs/parts/enforcement-N20]],
  [[banks/port]].

### Needed and unrostered

| need | measured | owner |
|---|---|---|
| [[banks/port]] Shard 3 grades the derivation sound for an extern | false by §2's probe (`docs/banks/port.md:147-148`) | a `doc-audit` of the bank once this element builds |
| the substrate exclusion lives only in compiler comments | `lib/lowering/compile-emit.chiral:206-211`, `:282-288`; no decision names it | none; a line in `docs/decisions/decision-effect-facets.md` |
| `E198`'s catalog row counts 34 prelude externs | 35 open `->` today, `bover` at `lib/prelude/prelude.chiral:130` added by `E200` | `E198`'s SPEC stage |
