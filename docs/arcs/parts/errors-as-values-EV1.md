---
row: errors-as-values/EV1
arc: errors-as-values
title: one result type declared once, polymorphic in the payload **and** the error, generalising the three in-tree carriers that are polymorphic in the payload alone (`PR`, `MfR`, `NewPufR`)
kind: primitive
origin: bind
req: 1, 2
status: audited
updated: 2026-09-29
---

# errors-as-values/EV1: one result type declared once, polymorphic in the payload **and** the error, generalising the three in-tree carriers that are polymorphic in the payload alone (`PR`, `MfR`, `NewPufR`)

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** one `data` declaration exists whose payload slot and whose error
  slot are both type parameters, so a boundary can share it while keeping its
  own declared error sum. Nothing adopts it in this row.
- **Serves:** requirement 1 of [[arcs/errors-as-values-arc]], *"One carrier,
  declared once, with a combinator that deletes the rebuild"*, whose first
  observable is that `bind` and `map-err` exist as declared defs **over the
  result type**. This row is the type half of that observable and `EV2` is the
  combinator half.
- **Also serves:** requirement 2, *"A carrier shared over a `Str` payload is
  refused"*. The type is where the refusal becomes expressible: an error slot
  that is a parameter can be instantiated at a declared sum, and the arc's own
  flagged trap is instantiating it at `Str`.
- **Goal:** [[goals/readable-surface]], condition 2, *"The convenient way is the
  safe way."*

## 2. What the tree holds

Measured 2026-09-23 over `lib/` and `prog/` by a paren-balanced scan that strips
comments and string literals before counting, and by four probes run against
`bin/chirality-bin`. The scan read 511 `data` declarations; `SC-data-decl`,
2026-09-29, reads 516 over the 312 tracked files of `E201`'s census.

**Bank:** [[banks/effect-and-alarm]]. Its §4 refraction answers the misfire
*"chirality needs `Result`/`Either` for error handling"* at
`docs/banks/effect-and-alarm.md:354-362`: a bare `Result` conflates ordinary
alternate return with divergence, carries no recoverable-vs-fatal fact (Shard 5,
`:195-210`, DESIGN and unbuilt, riding `E39`) and no counter-effect set
(Shard 4), so `Result` is a shadow of the row mechanism. **That correction is a
boundary on this row rather than an objection to it.** The 79 carriers this row
generalises are alternate return values in already-written code, and none of
them is an alarm. The bank's constraint on `EV1` is that the type may not be
presented as the effect algebra and may not grow a recoverability field, because
`docs/banks/effect-and-alarm.md:201-206` already homes that fact on the
crossing's handler signature as a `KontMsg` constructor offering.

| what exists | where | rung | reached by |
|---|---|---|---|
| the payload-polymorphic, error-monomorphic carrier, three instances and no fourth | `lib/surface/surface.chiral:23` `PR` over `(p-err (msg Str))`; `lib/surface/parse.chiral:750` `MfR` over the 18-arm `MfErr` at `:730`; `prog/scriba/puffer.chiral:41` `NewPufR` over `(puf-err (msg Str))` | IMPLEMENTED | `PR` and `MfR` by the compiler's own front end, `NewPufR` by scriba |
| two type parameters, four precedents | `Pair` `lib/prelude/prelude.chiral:20`, `Map` `lib/prelude/map.chiral:19`, `MinR` `lib/prelude/map.chiral:131`, `Step` `prog/prapanca/fsm.chiral:15` | IMPLEMENTED | `Pair` tree-wide, `Map` by the compiler closure |
| bind, three lines, over the type carrying least of the load | `lib/prelude/maybe.chiral:15-17` `maybe-then : (-> (0 A (type 0)) (0 B (type 0)) (-> A (Maybe B)) (Maybe A) (Maybe B))` | IMPLEMENTED | `lib/prelude/map.chiral`, `prog/prapanca/backend.chiral` |
| zero combinators over any result carrier | no `def` or `declare` named `bind`, `map-err` or `and-then` anywhere under `lib/` or `prog/`; all 60-odd `bind`-containing names are variable binding, `bind-fields` `lib/typing/kernel.chiral:498`, `bind-vals` `lib/lowering/tal/eval.chiral:104`, `bind-dsts` `lib/lowering/tal/check.chiral:237` | absent | nothing |
| one `then` in the tree, and it chains an `Ord` | `lib/typing/ty-cmp.chiral:20` `(def then (-> Ord Ord Ord) ...)` | IMPLEMENTED | `ty-cmp` |
| the doctrine, with its own audit test | `docs/definitions/pattern-boundary-sums.md`, standing author directive of 2026-08-09 and the test *"If a `Str` or `I64` in a signature encodes which-of-N-things, it is a sum wearing a disguise"* | doctrine | the audit charters |
| the survey | [[records/findings]] `FD-48`: Roc and OCaml polymorphic variants keep per-boundary specificity in one shared carrier with the widening inferred, and both pay by dropping the declared-constructor check (`OCAMLPOLYV:336`, with a mistyped tag type-checking at `:342`). Zig pays with a payload-free interned error name (`ZIGLANGREF:6945`) and a compiler that forbids recursion under an inferred set (`:7416`). The other five widen per boundary and write the injection by hand | external | this design |

### 2a. The census, re-derived, and it drifts

The arc's roster and the standing author-call row at `records/author-calls.md:52`
both rest on 76 two-arm ok/err sums, 47 carrying a `Str` error slot (30 bare,
17 beside something else), 18 inside `prog/compiler.prog`'s closure and 29
outside. **No predicate this run tried reproduces that set**, which is the same
outcome `FD-48` §11 recorded when it re-derived the figures it was handed.

| predicate | sums | `Str` error slot | bare `Str` alone | inside closure | outside |
|---|---|---|---|---|---|
| strict: one arm ends `-ok`, the other `-err`, `-bad` or `-fail` | 70 | 45 | 29 | 18 | 27 |
| wide: the strict set plus the `-r`/`-err` spelling and `ok!`/`bad!` | 79 | 49 | 33 | 22 | 27 |
| the arc's figure | 76 | 47 | 30 | 18 | 29 |

The `-r`/`-err` spelling is eight declarations and is the errno-or-value shape
`docs/definitions/pattern-boundary-sums.md` names as a live precedent:
`TimeR` `lib/ports/clock.port:21`, `AccR` `lib/ports/sock.port:28`, `ConnR`
`:31`, `LisR` `:41`, `SendR` `:44`, `WinsizeR` `lib/protocol/term.chiral:19`,
`RawR` `:112`, `SpawnR` `:283`. `ChkR` at `lib/module/loader.chiral:61` spells
its arms `ok!` and `bad!`. Whichever predicate the arc meant, those nine are
boundary sums.

The rebuild-unchanged census reproduces **231** case arms that destructure an
error and reconstruct one from the same binder, 142 same-carrier and 89
cross-carrier, against the arc's 202 / 137 / 65. **The six worst files reproduce
exactly**: `lib/surface/parse.chiral` 69, `lib/typing/kernel.chiral` 32,
`lib/surface/surface.chiral` 32, `lib/protocol/apc.chiral` 23,
`lib/module/loader.chiral` 16, `lib/lowering/tal/erase.chiral` 12. Twelve
sampled matches are all genuine, including the cross-carrier
`lib/typing/kernel.chiral:1099` `((u-err m) (tc-err m))` and
`lib/lowering/tal/erase.chiral:247` `((xd-err r) (xc-err r))`.

**The wide predicate is now a committed instrument.** `EV12` minted as `E201`
and landed at `4e9649f`: `prog/shape-census.prog`, the register
`docs/definitions/shape-census.md`, and the gate `tools/test/shape-census.sh`,
which still waits to be registered as a suite phase. Its arm-name rule is this section's wide row.
Its readings on 2026-09-29, over 312 tracked files, reproduce every wide figure
above:

| reading | n | inside closure | this design's figure |
|---|---|---|---|
| `SC-result-sum-2arm` | 79 | 34 | 79 |
| `SC-err-arm-bare-str` | 33 | 19 | 33 |
| `SC-err-arm-str-plus` | 16 | 3 | 16, so 49 `Str` error slots, 22 inside and 27 outside |
| `SC-err-arm-declared` | 15 | 10 | not measured |
| `SC-rebuild-unchanged` | 231, of which 142 `same` and 89 `cross` | 174 | 231 / 142 / 89, and the six files above at the same counts |

The arc still carries the hand counts 76 / 47 / 30 / 202, and requirement 5
still says the check reads 30 today. Under the committed predicate it reads 33.
No conclusion of this design moves: the numbers it rests on were the wide row
and the wide row is what the instrument implements. Whether the wide rule is the
one the author meant is open under `records/author-calls.md:52`.

### 2b. The compiler closure holds 61 modules and `prelude/maybe` is one

`chirality_blob_file "lib:prog" prog/compiler.prog` emits 63 distinct
`end-module` names, two of which (`<n>`, `<name>`) are text inside string
literals, so the closure is **61 modules** and the arc's figure holds. The
members that matter to this row are `prelude/prelude`, `prelude/maybe`,
`prelude/map`, `surface/sexp`, `surface/surface` and `surface/parse`.
`prelude/maybe` enters through `lib/prelude/map.chiral:12`, and only two files
in the tree import it. `lib/lowering/tal/eval.chiral` and
`lib/lowering/tal/check.chiral` are outside it.

### 2c. The constructor namespace is flat, and a collision is silent at declaration

`senv-add-ctor` at `lib/surface/parse.chiral:458-459` conses `(pair ctor home)`
onto the head of one list per blob, and `assoc` at
`lib/surface/surface.chiral:91-93` returns the first match. So the last
declaration in blob order owns the name, and the earlier owner's constructor is
unreachable. Nothing refuses the duplicate: `load-data` at
`lib/module/loader.chiral:549-551` raises `r-redeclared` on the **data type
name** alone.

Two probes, run this session against `bin/chirality-bin`:

- **Probe B.** Two two-arm types in one file, both declaring `r-ok` and `r-err`,
  with the **first** type's constructor applied. `chirality run` refuses with
  `load: r-ok checked against a different data type`, the `jg-ctor-other-data`
  judgment rendered at `lib/typing/diag.chiral:458`.
- **Probe C.** The same file with only the **second** type's constructor
  applied. Exits 0. The collision is invisible until the shadowed owner is used.

The census finds this live and latent at scale: **22 data type names were
declared more than once** on 2026-09-23 and **24** on 2026-09-29, read off
`SC-data-decl`'s instance lines, the two new ones being `Acc` and `Hit` in
`prog/shape-census.prog`. The scan found **29 constructor names declared by
more than one data type**. `E201` counts no such row: `SC-ctor-head-sites`
reads 1,251 against `SC-ctor-head`'s 1,214 distinct, 2026-09-29, so 37 arms
carry a head another arm already carries. `r-ok` and `r-err` are among them, owned by `RR` at
`lib/surface/sexp.chiral:19-21` and by `RunR` at
`lib/lowering/tal/eval.chiral:30`. `res-ok`/`res-err` are owned by `ResR` at
`lib/module/resolve.chiral:134-136`. `PR`, `p-ok` and `p-err` are declared three
times, at `lib/protocol/apc.chiral:19`, `lib/protocol/json.chiral:106` and
`lib/surface/surface.chiral:23`. None of these collides today, because no root
blobs two owners: `surface/sexp` appears in 11 of the 14 `prog/*.prog` roots on
2026-09-29 (10 of 13 before `prog/shape-census.prog` landed) and
`lowering/tal/eval` in none of them. **`Result` is free as a type name**, with
five textual occurrences under `lib/` and `prog/` and all five inside comments.

This is `E154`'s defect class inside the constructor namespace.
`docs/elements/ledger.md:151` records `E154` as `design` and unbuilt. It names
three hand-renames and carries its own correction of 2026-09-24: thirteen
instances over sixteen files.
`docs/examples/E181-pretty-term-doc.md:236` makes a tree-wide census of every
name an element introduces a gate step, which is the precedent this row inherits.

### 2d. Feasibility, re-verified

**Probe A**, written and run this session. `lib/prelude/prelude.chiral` imported;
`(data Result ((A (type 0)) (E (type 0))) (r-ok (val A)) (r-err (why E)))`; a
three-arm `MyErr`; `r-then` typed
`(-> (0 A (type 0)) (0 B (type 0)) (0 E (type 0)) (-> A (Result B E)) (Result A E) (Result B E))`
taking the continuation as a value parameter; two chained calls over both the ok
and the err path. `chirality run` exits 0, which asserts 42 on the ok path and
the `me-empty` arm on the err path. The err arm of `r-then` is written
`((r-err e) (r-err e))` with no annotation, so the payload parameter `B` is
inferred at an error reconstruction. The lowering blocker was `E100`'s fn-param
application residual, closed by `E100` and `E147` on 2026-08-16 and hardened by
`E185` through `E188` on 2026-09-04. The emitted byte count is deliberately not
recorded here: `docs/arcs/custody-executes-arc.md:76` carries the same figure for
an unrelated minimal probe, so it measures the floor of a program with one port
import.

**Re-run 2026-09-29 by the DESIGN audit, from the scratchpad and not left in the
tree.** The §5 declaration verbatim, `(res-val (v A)) (res-why (e E))`, two
unrelated error sums (`MyErr` of three arms, `IoErr` of two) used in one program,
each cased exhaustively with no `_` arm, and the same higher-order `r-then`
chained at both. `chirality run` exits 0 with all four checks holding. Two
variants, both through `chirality check`: an `IoErr`-typed `Result` given
`me-big` fails with `load: me-big checked against a different data type`, and
the error slot fixed at `Str` fails with `load: me-empty checked against a
non-data type`.

### 2e. `Maybe` is used everywhere

576 `(Maybe ...)` type occurrences, 2,500 applications of `some` or `none`, in
130 files under `lib/` and `prog/`. `Maybe` is declared at
`lib/prelude/prelude.chiral:23`, in the module every other module imports.

## 3. The delta

Subtracting §2 leaves four things, and the first is the row.

1. **No declaration in the tree has a type parameter in the error slot.** All
   three carriers are monomorphic there: `PR` at `Str`, `NewPufR` at `Str`,
   `MfR` at `MfErr`. The four two-parameter precedents are a product (`Pair`),
   a container (`Map`, `MinR`) and a state step (`Step`), and none is a result.
   The gap is exactly one `data` form.
2. **No home exists that is outside the compiler closure.** Requirement 4 wants
   the shape proven outside `prog/compiler.prog`'s 61 modules before it enters
   them, and both obvious homes are already inside: `prelude/prelude` by
   necessity and `prelude/maybe` through `lib/prelude/map.chiral:12`. Declaring
   the type in either puts it in the compiler's blob on the day it lands, before
   any adoption row has run.
3. **No spelling is safe by default.** §2c measures a namespace where the two
   natural spellings are taken, a duplicate is accepted at declaration, and the
   failure surfaces at the shadowed owner's first use. A type meant to be
   imported by many boundaries converts every latent duplicate it collides with
   into a live refusal.
4. **The baseline the requirements are checked against was prose.** §2a gets
   three different answers from three predicates and reproduces none of the
   arc's. `E201` has since committed the wide one, so requirement 1's
   baseline reads 231 as `SC-rebuild-unchanged` and requirement 5's reads 33
   as `SC-err-arm-bare-str`, both 2026-09-29. The arc's own figures still
   await restatement against them.

Items 2 and 3 are the design content. Item 1 is mechanical once they are
settled, and item 4 belonged to `EV12`, which is `E201`.

**Verdict:** a real delta. Small in lines and load-bearing in placement.

## 4. The shapes

Two independent choices. §4a is the home, §4b is the error slot's degree of
freedom. The constructor spelling follows from §4a and is settled in §5.

### 4a. Where the type lives

#### Shape A: a new module `lib/prelude/result.chiral`

- **Form:** `(module prelude/result (cat A) (alt upper))`, importing
  `prelude/prelude` alone, holding the `data` form and nothing else. `EV2` adds
  the combinators to the same file.
- **Costs:** one more file in `lib/prelude/`, which holds nine today. Every
  adopting boundary writes one `import` line.
- **Forbids:** nothing structural. It keeps the type **outside every existing
  blob** until a boundary imports it, which is what requirement 4 asks for and
  what neither other shape can offer. A new module that nothing imports appears
  in no root's resolution, so this row owes no fixpoint build.

#### Shape B: inside `lib/prelude/maybe.chiral`, beside `maybe-then`

- **Form:** the `data` form appended to the file that already holds the only
  bind in the tree, `lib/prelude/maybe.chiral:15`.
- **Costs:** `prelude/maybe` is in the compiler closure through
  `lib/prelude/map.chiral:12`, so the type enters `prog/compiler.prog`'s blob at
  the moment it is declared. The row then owes the three-generation fixpoint
  build of [[working-discipline]] for a declaration nothing calls, and
  requirement 4's ordering is broken by the carrier row itself before any
  adoption row runs.
- **Forbids:** it forecloses proving the shape outside the closure. It also
  widens `prelude/maybe`'s remit from one type to two, and the file's own header
  describes it as `Maybe` combinators for optional lookups.

#### Shape C: inside `lib/prelude/prelude.chiral`, beside `Maybe` and `Pair`

- **Form:** a sixth `data` form in the extern floor, at
  `lib/prelude/prelude.chiral:17-29`.
- **Costs:** the same closure entry as Shape B, and harder. `prelude/prelude` is
  the module every other module imports, so the type and its constructor names
  become visible in every blob in the tree at once, and §2c's 29 latent
  constructor duplicates all become reachable from the same namespace.
- **Forbids:** it makes the constructor spelling a tree-wide reservation that
  cannot be revised without touching every root. The file's own header at
  `:1-5` scopes it to the data types and pure primitives the host implements at
  link time, and `Result` has no host implementation.

#### Shape D: generalise `PR` in place

- **Form:** widen `lib/surface/surface.chiral:23` from `((X (type 0)))` to two
  parameters and let the other boundaries import `surface/surface`.
- **Costs:** `PR` carries 38 arms over 279 construction sites by the arc's own
  measurement and is the largest boundary in the tree. Every one of them moves
  in the same change. `surface/surface` is inside the closure, so the fixpoint
  build is owed immediately. `PR` is also one of three declarations of that type
  name (§2c), so importing `surface/surface` into `lib/protocol/apc.chiral` or
  `lib/protocol/json.chiral` is a hard `r-redeclared` refusal.
- **Forbids:** it collapses `EV1` and `EV11` into one change, which is the
  ordering the arc's own edge table calls the trap.

### 4b. The error slot

#### Shape E: a free type parameter

- **Form:** `(E (type 0))`, exactly as `Pair`'s second parameter at
  `lib/prelude/prelude.chiral:20`.
- **Costs:** nothing at the declaration. A consumer that needs to render an
  error takes the renderer as a value parameter, which is the tree's existing
  idiom for a constrained parameter: `list-sort` and `m-lookup` take the
  comparator as an argument rather than as a constraint on `A`
  (`docs/elements/ledger.md:301`).
- **Forbids:** it forbids nothing and it decides nothing. Whether the slot needs
  a companion witness is answered by what the 47 boundaries turn out to need,
  and `EV11` is the row the arc schedules last for exactly that reason.

#### Shape F: a slot carrying a declared field

- **Form:** the error arm carries a second field beside the parameter, such as a
  renderer or a position, so every boundary gets one for free.
- **Costs:** it fixes at the declaration a thing 47 boundaries have not yet been
  read. 16 of the `Str`-carrying error arms already carry a second field and 33
  do not (§2a), so any single choice is wrong for one of the two groups.
- **Forbids:** adding or removing a field later rewrites every construction site
  of every adopter, which is the cost this arc exists to stop paying.

**The tree does not settle §4a.** Three homes are available and the closure
measurement in §2b is what distinguishes them, which is a measurement this run
took rather than a rule the tree already carries. §4b is closer to settled:
there is no constraint mechanism on a type parameter anywhere in the tree, and
the comparator-passing idiom is the answer to the same question one level down.

## 5. The call

- **Chosen: Shape A and Shape E.** A new `lib/prelude/result.chiral` holding
  `(data Result ((A (type 0)) (E (type 0))) (res-val (v A)) (res-why (e E)))`,
  with the error slot a free parameter and no second field on either arm.
- **Why Shape A.** It is the only home that satisfies requirement 4 for the
  carrier row itself. §2b measures both alternatives inside the 61-module
  closure, and Shape B's cost is that a declaration nothing calls would owe the
  three-generation fixpoint build before a single boundary has proven the shape.
  Shape A also keeps the mint's blast radius at one new file.
- **Why `res-val` and `res-why`.** §2c measures `r-ok`/`r-err` owned twice and
  `res-ok`/`res-err` owned once, with the collision invisible at declaration and
  fatal at the shadowed owner's first use. `res-val` and `res-why` have zero
  declarations tree-wide under the 511-declaration census. The names also read
  as what they carry, which is the discourse rule the naming half of this work
  is measured against. **The mint owes a re-run of the census at the moment it
  lands**, because another session may declare either name first.
- **Why Shape E.** The tree holds no way to constrain a type parameter, and its
  answer to the same question for `Map` and `List` is a function passed by
  value. Fixing a field now would be a decision taken on three boundaries out of
  47.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Where the type lives, and what its constructors are called | RESOLVED | A new `lib/prelude/result.chiral`, constructors `res-val` and `res-why`. Forced by [[arcs/errors-as-values-arc]] requirement 4, which orders proof outside the closure before entry, read against the closure measurement in §2b, and by the namespace measurement in §2c. The mint re-runs the name census |
| 2 | Whether the error slot carries a constraint or is free | DEFERRED to `errors-as-values/EV11` | Free here. `EV11` is the row the arc schedules last because `PR`'s 38 arms are what force the answer. **What this row must leave open**: no field on either arm beyond the two parameters, no companion type in the declaration, and no renderer named in the module. Any of the three would have to be unwound across every adopter |
| 3 | What happens to `PR`, `MfR` and `NewPufR` | DEFERRED for two, residue for the third | `MfR` is `errors-as-values/EV10`, `PR` is `errors-as-values/EV11`. Both are left alone by this row. **`NewPufR` at `prog/scriba/puffer.chiral:41` is covered by no roster row on this arc**, and the deferral rule forbids inventing one here. It is named as owed, for the arc amendment the queue already schedules |
| 4 | Whether `Maybe` is `(Result A Unit)`, and whether that is wanted | RESOLVED | Structurally yes, and the answer is no. Three reasons, each measured. `Maybe` has 576 type occurrences and 2,500 constructor applications across 130 files (§2e), so the rewrite is tree-wide and buys nothing. `none` carries no field and `(res-why unit)` carries a cell. **The third reason is the arc's own requirement 2**: a carrier whose error slot holds no classification is the `Str` defect with the string removed, and `docs/banks/effect-and-alarm.md:354-362` says the same thing one layer up when it calls `Result` a shadow of the row mechanism. `Maybe` means absence and `Result` means a refusal that carries its reason. `maybe-then` stays where it is |
| 5 | What the gate is | RESOLVED | §6 carries it. A runtime sample at two distinct `E` instantiations in one program, a refusal fixture, a name census, and named mutants |

**No NEEDS-AUTHOR.** The band is already settled: `records/author-calls.md:69`
carries the 2026-09-06 ruling *"let overlap exist"*, under which an arc with no
reserved block mints the next number free tree-wide. The standing `unreviewed`
row on whether condition 1 reaches the whole tree
(`records/author-calls.md:52`) sizes `EV3` and the adoption rows and does not
reach this one: the type is declared once whichever way that call goes.

## 6. The mint packet

- **Elements:** one. The declaration and its home are one decision, and §4a
  shows the home is the decision. The combinators are `EV2` and stay separate
  because `EV2`'s own obligation is the linear-binder question, which a `data`
  form does not raise.
- **Band:** `UNASSIGNED`. [[arcs/errors-as-values-arc]] reserves no block.
  `docs/decisions/decision-lane-split.md` reserves `E184-E189` and `E190-E195`
  at `:31`, `E196-E239` at `:64`, `E240-E259` at `:72` and `E260-E263` at `:82`,
  none of them this arc's, and holds bands advisory at `:38`. The mint takes the
  next number free tree-wide.
- **Catalog row**, in the live five-column form at `docs/elements/catalog.md:93`:

  ```
  | E<NN> | **`Result`: one carrier polymorphic in the payload and in the error** | Not built. New module `lib/prelude/result.chiral`, importing `prelude/prelude` alone and outside `prog/compiler.prog`'s 61-module closure until a boundary imports it. `(data Result ((A (type 0)) (E (type 0))) (res-val (v A)) (res-why (e E)))`. Generalises the three payload-polymorphic, error-monomorphic carriers the tree already ships: `PR` `lib/surface/surface.chiral:23`, `MfR` `lib/surface/parse.chiral:750` over the 18-arm `MfErr` at `:730`, `NewPufR` `prog/scriba/puffer.chiral:41`. Two type parameters have four precedents, `Pair`, `Map`, `MinR`, `Step`. Feasibility re-verified 2026-09-23 by probe, and again 2026-09-29 at two distinct error instantiations in one program: the declaration plus a higher-order `r-then` type-checks, compiles and runs, exit 0. The constructor spelling is forced by a namespace measurement, `r-ok`/`r-err` being owned by `RR` `lib/surface/sexp.chiral:19` and `RunR` `lib/lowering/tal/eval.chiral:30`, and `res-ok`/`res-err` by `ResR` `lib/module/resolve.chiral:134` | `OURS`; `FD-48` surveys seven published mechanisms (`IMPL`) | SH |
  ```

- **Ledger row**, in the live five-column form at `docs/elements/ledger.md:80`:

  ```
  | E<NN> | result | design | **`Result`: one carrier polymorphic in the payload and in the error.** The carrier half of [[arcs/errors-as-values-arc]] requirements 1 and 2, covering `errors-as-values/EV1`. A new `lib/prelude/result.chiral` so the type sits outside the compiler's import closure until an adoption row pulls it in, which requirement 4 requires and which neither `prelude/prelude` nor `prelude/maybe` can offer, both being inside it. The error slot stays a free type parameter and `errors-as-values/EV11` settles whether it needs a witness. Constructors `res-val`/`res-why` and type name `Result`, absent from `SC-ctor-head` and `SC-data-name`, 2026-09-29 | →`EV2`, →`EV10`, →`EV11`, ←E100, ←E147, ←E185-E188 | SH |
  ```

- **Size:** one new file, 12 to 18 lines, plus one sample under
  `tools/test/samples/` at roughly 60 to 90 lines and one refusal fixture.
  Basis: `lib/prelude/maybe.chiral` is 23 lines for three combinators and one
  module header, and the `data` form here is five lines. No existing file is
  edited, so the diff is additive. **No fixpoint obligation**, because the new
  module is imported by nothing and therefore appears in no root's resolution;
  `chirality_blob_file "lib:prog" prog/compiler.prog` is unchanged by this
  element and that is itself a gate assertion. `bin/chirality-bin` does not move.
- **Gate**, answering §5 question 5. Four parts, and the first is the one that
  separates correct from compiling:
  1. **Two distinct `E` instantiations in one program.** The sample declares two
     unrelated error sums and uses `Result` at both, then cases each
     exhaustively with no `_` arm. A carrier that was accidentally monomorphic
     fails here and passes a single-instantiation test.
  2. **A refusal fixture.** A program that puts an error of one sum into a
     `Result` declared at the other must fail `chirality check`, with the
     expected refusal text recorded. Measured 2026-09-29 by probe:
     `load: <ctor> checked against a different data type`, the
     `jg-ctor-other-data` judgment at `lib/typing/diag.chiral:458`. That is the
     same judgment §2c's Probe B raises for a constructor collision, so the pin
     names the offending constructor as well as the text, and the fixture's two
     error sums share no constructor name. This is what distinguishes Shape E from the
     structural-row designs `FD-48` priced: `OCAMLPOLYV:336` says OCaml's
     polymorphic variants drop exactly this check, and the route this tree took
     is a shared carrier with a specific declared `E`.
  3. **The name census**, `docs/examples/E181-pretty-term-doc.md:236`'s Phase-17
     shape: `res-val`, `res-why` and `Result` have zero other declarations under
     `lib/`, `prog/` and `tools/`. §2c is why this is a gate rather than a
     courtesy.
  4. **Mutants, each reverted.** A `res-why` arm that drops the payload; a
     declaration with the error slot fixed at `Str`, which is the requirement-2
     trap in executable form. Measured 2026-09-29: under it the refusal fixture
     still fails `chirality check`, with `checked against a non-data type` in
     place of the pinned text, so part 2 catches it through the text pin alone
     and an exit-code-only fixture would pass it; and the second
     instantiation deleted from the sample, which must make part 1 vacuous and
     be caught by the assertion count.
- **Related:** [[arcs/errors-as-values-arc]] · [[goals/readable-surface]] ·
  [[banks/effect-and-alarm]] · [[records/findings]] `FD-48` ·
  `docs/definitions/pattern-boundary-sums.md` · `E154` · `E157` · `E181`

**Residue carried out of this run, for the arc amendment.** `NewPufR`
(`prog/scriba/puffer.chiral:41`) is one of the three carriers this row's title
names and no roster row on the arc reaches it. The census predicates behind
requirement 1's 202 and requirement 5's 30 got three different answers (§2a).
`EV12` has since committed the wide one as `E201` (`4e9649f`), which reads 231
and 33 on 2026-09-29, and the arc's figures are owed a restatement against it.
Neither is deferred to anything unminted.
