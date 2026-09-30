---
row: enforcement/N25
arc: enforcement
title: the effect row on the Pi, its row variables, and the algebra over them
kind: primitive
origin: new
req: 1
status: blocked
updated: 2026-09-30
---

# enforcement/N25: the effect row on the Pi

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.
>
> ⚑ **This row is pre-minted.** It carries `E39`, at ledger state `design`
> (`docs/elements/ledger.md:116`). `tools/pack/pack.py enforcement/N25 --start`
> printed `enforcement/N25 already carries E39. The design stage is behind it;
> use --spec`, then scaffolded this file and moved the roster row from `open`
> to `designed` anyway. So §6 writes no mint. It states the amended catalog and
> ledger rows for `E39` and the SPEC the next stage replaces.

## 1. The obligation

- **The row:** the Pi's effect seat holds a row: a finite set of entries, each a
  label with zero or more type-level arguments, plus a finite set of row
  variables, or the top row. The kernel compares rows by set equality in `conv`,
  by subsumption in `subtype` with contravariant domains, joins them, removes
  named entries from them, and projects them onto today's bit. Rows erase: no
  emitted byte changes.
- **Serves:** requirement 1 of [[arcs/enforcement-arc]], "A capability sits at
  ENFORCED, or its ledger row says why it does not." `E39` is at `design`.
- **Goal:** [[goals/enforcement]], condition 1.

## 2. What the tree holds

Measured 2026-09-30 at `12e2fba` plus the working tree.

- **Bank:** [[banks/effect-and-alarm]]. Shard 1 is the bit, carried and refused
  nowhere (`docs/banks/effect-and-alarm.md:105-121`). Shard 2 is the three
  membrane rules, reached by nothing (`:123`), which are `E171`'s. Shard 5,
  recoverable against fatal, rides this row (`:195`). §5a is the resolved
  mechanism this row carries out (`:375`). [[banks/memory]] names the region
  consumer through `memory-discipline/M9`.

| what exists | where | rung | reached by |
|---|---|---|---|
| the carrier: `(q, row, grades, totality-mark, dom, cod)` with the seat count frozen and a row-variable seat reserved, a trusted-core edit | `docs/decisions/decision-effect-facets.md:77-86` | DESIGNED | nothing |
| rows inferred by elaboration from transitive crossings; declared bounds at module and profile boundaries; `->` is the empty row | `docs/decisions/decision-effect-facets.md:34-38` | DESIGNED | nothing |
| row variables for higher-order code, the ceremony on boundary signatures | `docs/decisions/decision-effect-facets.md:115-119` | DESIGNED | nothing |
| the seat: one bit | `(data Seat () (s-pure) (s-proc))`, `lib/surface/syntax.chiral:12` | IMPLEMENTED | every arrow |
| the Pi carrying it | `(t-pi (q Qty) (s Seat) (dom Term) (cod Term))`, `lib/surface/syntax.chiral:21`; `v-pi`, `lib/typing/kernel.chiral:26` | IMPLEMENTED | every arrow |
| the seat compared by equality | `seat=`, `lib/typing/kernel.chiral:559-563`, read by `conv-struct` at `:712-716` | IMPLEMENTED | `conv` |
| `subtype` has no `v-pi` arm; an arrow falls through to `conv` | `lib/typing/kernel.chiral:799-811` | IMPLEMENTED | `subsume` |
| the bit read as "does this type cross" | `seat-crosses`, `ty-crosses`, `lib/typing/kernel.chiral:313-319` | IMPLEMENTED | the fn/proc export split, `lib/module/loader.chiral:474`, `lib/surface/parse.chiral:917`, `lib/typing/kernel.chiral:389`, `:397` |
| the elaborator's Pi: `eff` an `I64`, set on the innermost binder only | `lib/surface/surface.chiral:55`, `build-pis` at `:101-106` | IMPLEMENTED | the loader |
| Core to Term and back | `eff->seat`, `lib/module/loader.chiral:20`, `:38`; `dseat->i`, `lib/lowering/upper/closconv-driver.chiral:31`, `:48` | IMPLEMENTED | the compiler |
| lowering reads the bit: defunctionalization families key on the per-arrow `eff` vector | `pi-effs`, `lib/lowering/upper/closconv.chiral:324-329`; `shape-eq` `:343-351`; `arrow-key-eq` `:381-386`; `mk-pi` `:1157-1164` | IMPLEMENTED | every `$apply` family |
| the printer | `lib/surface/pretty.chiral:228` | IMPLEMENTED | diagnostics |
| a row model over closed names: `row-empty`, `row-sub`, `row-join`, `row-pure?`; entries without arguments, and neither variables nor removal | `lib/typing/effects.chiral:10-30` | SEEDED | `lib/typing/row-infer.chiral` and `lib/lowering/upper/eff-lower.chiral`, neither in the blob (`docs/elements/ledger.md:113`) |
| the lowered shadow: crossing names as `(List Str)`, a def's row given as input | `lib/lowering/upper/eff-lower.chiral:9-17`, `keep-in` at `:35-38` | SEEDED | `lib/module/sig-driver.chiral` only, zero importers (`docs/elements/ledger.md:119`) |
| row inference over the call graph | `lib/typing/row-infer.chiral:1-13` | SEEDED | the same chain |
| a negative sample fixing `=>` against `->` | `prog/samples/e42_reject_pure_as_process.prog:11-21` | IMPLEMENTED | the suite |
| profile requirements judged by subtyping | `prog/demo/profile-tomodachi.chiral:4-7` | IMPLEMENTED | `verify` |
| the prior plan: set-of-names rows, subsumption in `subtype`, `conv` kept at equality | `docs/elements/specs/E39-effect-row-SPEC.md:105`, `:154-170` | DEAD, `:13-17` | nothing |
| the worked example: alarms as crossings, handlers as ordinary linear closures | `docs/examples/E39-effect-row.md:86-104`, `:157-199` | DESIGNED | `E26` |

**Consumers read today.**

- `memory-discipline/M9` needs a region entry naming a binder `s`, a row
  variable so the seal keeps the block's other effects, and removal of the `s`
  entries only (`docs/arcs/memory-discipline-arc.md:102`). [[records/findings]]
  FD-62 gives the side condition, `s` free in neither the context, the result
  nor the remaining row, and reads Koka's `run` as transferring whole once the
  seat holds region entries and a row variable.
- `enforcement/N26` (`E171`) needs the empty-or-nonempty projection and
  subsumption against the empty row (`docs/arcs/enforcement-arc.md`, the `N26`
  row).
- `E26`'s handler discharges crossing entries under its own rule
  (`docs/elements/ledger.md:114`, gated on `E39`).
- `enforcement/N9` (`E70`) lowers the row to the tal shadow of crossing names
  (`docs/arcs/enforcement-arc.md:547`).
- `checker-core/CK20` puts a multiplicity `m` on the same Pi, compared by
  equality (`docs/arcs/parts/checker-core-CK20.md:110-126`, `:174-183`).

**Measured over `lib/` and `prog/`** (an s-expression walk over every
`.chiral`, `.prog` and `.port`, comments and strings stripped): 755 `(=> `
forms and 3,526 `(-> `. A `=>` with no body to infer a row from sits at 17
sites in 10 files: 4 parameter domains (`prog/prapanca/backend.chiral:145`,
`:155`; `prog/prapanca/pipeline/runner.chiral:115`, `:147`), 5 data fields
(`lib/lowering/mach/mach.chiral:29-30`, `:55`, `:57`;
`prog/scriba/cmd-types.chiral:11`), and 8 profile requirement arrows over six
files under `prog/demo/`. Pattern sites over the live Pi: 40 `(t-pi ` and
`(v-pi ` in 10 files, and 19 `(c-pi ` in 5.

## 3. The delta

1. **A row value.** Nothing in the kernel holds more than one bit. The model at
   `lib/typing/effects.chiral:10-30` has closed names, no argument on an entry
   and no variable, so it cannot say `s`.
2. **Row variables.** Reserved at `decision-effect-facets.md:82` and absent.
   The kernel has no unifier, so a variable must be a thing the checker can
   compare and substitute without solving.
3. **Scope.** An entry naming `s` must be walked by eval, quote, shift and the
   free-variable check. Today the seat is opaque to all of them
   (`lib/typing/kernel.chiral:677`, `:766`, `:1193`, `:1219`).
4. **Subsumption.** `subtype` has no Pi arm, so a pure arrow is refused where an
   effectful one is wanted.
5. **Removal.** No operation removes an entry from anything.
6. **The projection for lowering.** Families key on the bit
   (`closconv.chiral:381-386`). Unless every lowering reader goes through one
   projection, a row changes family keys and so changes emitted bytes.
7. **A spelling.** The surface arrow reads a leading item as a binder
   (`lib/surface/parse.chiral:436-441`). No form writes a row.

**Verdict:** a real delta.

## 4. The shapes

### Shape A: a row record beside Term, with its own row binder
- **Form:** `Seat` becomes a record holding entries and one tail variable,
  living outside `Term`; a row variable is bound by a new row quantifier on the
  Pi, instantiated by its own rule.
- **Costs:** a second binder sort in a de Bruijn kernel: a second index space
  or a shared one with a sort check, and an instantiation rule the kernel does
  not have. A single tail makes join partial: `⟨|μ⟩ ∪ ⟨|ν⟩` has no single-tail
  form without unification.
- **Forbids:** passing a row as an ordinary erased argument. Unwanted, since
  `M9`'s block already binds `s` as `(0 s (type 0))`.

### Shape B: rows as kernel terms of kind `Row`, variables as erased binders
- **Form:** `Term` gains `(t-row (ents (List REnt)) (vars (List Term)))` and
  `(t-row-top)`, with `(data REnt () (rent (label Str) (args (List Term))))`.
  The kind is `(t-primty "Row")`. A row variable is an ordinary binder
  `(0 e Row)`. `Value` gains the normal form `v-row`, whose `vars` hold only
  neutrals: eval merges a variable bound to a row into the entries.
  `Seat` becomes `(seat (row Term))`, scoped like the codomain so a row can
  name the Pi's own binder, as `M9`'s block `(=> (0 s (type 0)) … A)` needs.
- **Costs:** two `Term` constructors and one `Value` constructor; every walker
  that must see a binder's scope learns the row. `conv` and `subtype` call a set
  algebra over values in the kernel.
- **Forbids:** a row outside `Term`. Wanted: substitution, scoping and the
  free-variable check come from the walkers the kernel already has.
- **Precedent:** Tofte and Talpin's effects are sets whose atoms include
  effect variables, `TOFTETALPIN97:703-705 "An atomic effect is a term of the
  form"` … `"An effect is a finite set of atomic effects."`, the atoms being
  `put(ρ)`, `get(ρ)` and effect variables. A set of variables is what makes join
  total without a unifier.

### Shape C: `Row` as a library `data`
- **Form:** `(data Row () (row-nil) (row-ext …))` in `lib/`, no kernel form.
- **Costs:** `conv` on data values is structural (`lib/typing/kernel.chiral`,
  the `v-con` arm of `conv-struct`), so `{a b}` and `{b a}` differ, and a
  canonical order over entries naming variables breaks under substitution. A
  field of type `(type 0)` puts `Row` a universe up.
- **Forbids:** set equality. Unwanted.

### Shape D: keep the closed name model
- **Form:** swap the bit for `effects.chiral`'s `(List Str)`.
- **Forbids:** region entries and row variables, which FD-62 names as what
  `M9` needs. Unwanted.

## 5. The call

- **Chosen:** Shape B. It is the only shape where a row variable is an
  ordinary erased binder, which is how `M9` already binds `s`, and where join,
  subsumption and removal are total without a unifier.

**The algebra, over `v-row` and `v-row-top`, in the kernel.**

1. **Join:** union of entries and of variables, deduplicated by `conv`; top
   absorbs.
2. **Subsumption** `r1 ⊆ r2`: true if `r2` is top; false if `r1` is top and
   `r2` is not; else every entry of `r1` is `conv`-equal to an entry of `r2`
   and every variable of `r1` is `conv`-equal to a variable of `r2`. Each
   variable may be instantiated empty, so this is complete for all
   instantiations.
3. **Equality:** mutual subsumption. `conv-struct`'s `v-pi` arm uses it at a
   fresh variable, where `seat=` stands today.
4. **Removal** `row-remove r l args`: drop every entry with label `l` whose
   arguments are `conv`-equal; variables stay; top stays top. The result bounds
   the effect from above whatever a variable holds. When a removal is sound is
   the consumer's rule: `M9`'s seal, `E26`'s handler.
5. **Projection** `row-crosses`: false only on a row with no entry and no
   variable. `seat-crosses` and every lowering reader go through it.

**The kernel rules.**

1. `subtype` gains a `v-pi` arm: quantities equal, `m` equal once `CK20`
   lands, rows by subsumption, domains contravariant, codomains covariant at a
   fresh variable. `conv` keeps equality, because it compares domains and
   arguments where a direction is wrong (`E39-effect-row-SPEC.md:154-170`
   measured that trap).
2. `infer-pi` checks the row against `Row` in the binder's scope; `t-row`
   infers each entry argument and checks each variable against `Row`.
3. A binder of type `Row` is admitted only at quantity 0. A row has no runtime
   form.
4. Eval, quote, `ub-at` and `sc-at` walk the row at the codomain's depth.

**What changes on the far side.**

- **Emitted bytes: none.** Core's `c-pi` carries the row and `pi-effs` answers
  `row-crosses`, so `shape-eq` and `arrow-key-eq` key every existing family as
  today. Row binders are quantity 0 and `ty-kept-doms` drops them
  (`lib/lowering/compile-front.chiral:162`). The gate is `C1 == C2` and a
  byte-identical blob against the pre-change compiler.
- **What stops checking.** Under the recommendation of NEEDS-AUTHOR 1, none:
  `->` maps to the empty row and a bare `=>` to top, so `conv` answers as
  `seat=` does on all 4,281 arrows. What newly checks: a `->` value where a `=>`
  is wanted, profile requirements met by a purer provider, and refinement
  subtyping under an arrow, which falls to `conv` today
  (`lib/typing/kernel.chiral:809-811`). The E42 sample stays refused.
- **Duplicate labels: none.** Rows are sets. Koka's duplicates buy principal
  unification and precise types for elimination forms
  (`KOKAROWS14:169-171`). This kernel has no unifier, and a set gives a handler
  a sound upper bound: handling `exn` in `⟨exn | μ⟩` leaves `μ`, which may still
  hold `exn`.
- **The lowered shadow.** An entry with no argument is a crossing name, which
  is what `eff-lower.chiral`'s `(List Str)` holds. Entries with arguments and
  variables erase at lowering. `N9` owns the shadow.
- **CK20.** The two share the Pi and do not interact. The `v-pi` arm above is
  written once for both: `m` by equality, the row by subsumption. Whichever
  builds second adds its field to the other's arm. `Seat` is a record so the
  frozen seat count (`decision-effect-facets.md:79-81`) lands on its fields
  and `t-pi` keeps four fields. Whether `m` lands as a `Seat` field, which
  spares `CK20` its 40 pattern sites, or on `t-pi` as `CK20` designed, is
  `CK20`'s SPEC's call.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | What a bare `=>` means | **NEEDS-AUTHOR** | below |
| 2 | How a row and a row binder are written | **NEEDS-AUTHOR** | below |
| 3 | Entries: names only, or labels with arguments | RESOLVED: labels with arguments | `M9` names `s` (`docs/arcs/memory-discipline-arc.md:102`); FD-62 item 5(a) |
| 4 | One tail variable or a set | RESOLVED: a set | no unifier in the kernel; `TOFTETALPIN97:703-705` |
| 5 | Duplicate labels | RESOLVED: none, rows are sets | FD-62 item 2; `KOKAROWS14:169-171` |
| 6 | Subsumption in `conv` or `subtype` | RESOLVED: `subtype`, `conv` keeps equality | `docs/banks/effect-and-alarm.md` §5a; `E39-effect-row-SPEC.md:154-170` |
| 7 | Where removal's soundness lives | RESOLVED: in each consumer | the roster row, "each consumer keeps the rule saying when a removal is sound" |
| 8 | The membrane rules over the row | DEFERRED(`enforcement/N26`) | `E171` |
| 9 | Row inference, a producer | DEFERRED(`enforcement/N26`) | `N26`'s row names inferring against annotating as its design stage's |
| 10 | Declared bounds at module and profile boundaries | DEFERRED(`E51`) | `E39-effect-row-SPEC.md:107`; a profile requirement is a type, and a written row is legal in it from this row |
| 11 | The tal shadow of the row | DEFERRED(`enforcement/N9`) | `E70` |

### NEEDS-AUTHOR 1: what a bare `=>` means

**In plain words.** Today `=>` says "may cross" and nothing more. Once rows
exist, a `=>` with no row written must mean something. Either it means "any
effect", the top row, and precision comes only where someone writes a row; or
the elaborator stamps each def's inferred row into its type, as
`decision-effect-facets.md:34-38` reads, and every place with no body to infer
from needs a written row or a row variable.

**Measurement.** 755 `=>` forms. 17 of them have no body: 4 parameter domains
in 2 files, 5 data fields in 2 files, 8 profile requirements in 6 files (§2).
Under stamping, those 17 need rows, `Mach` gains a row parameter and every use
of `Mach` with it, and two closures with different inferred rows stop sharing a
type inside a `List` or a field; that count needs the inference producer, which
is SEEDED (`lib/typing/row-infer.chiral:1-13`) and unmeasured. Under top, 0
sites change, and a seal or handler can remove nothing from code declared with a
bare `=>`, so `M9`'s block and `E26`'s handled body must write their rows.

**Options.** (a) top: the Pi carries the declared bound, a bare `=>` is top,
inferred rows are a per-def fact that `N26` and `N9` check against the bound.
(b) stamping: the Pi carries the inferred row; the 17 sites take written rows
or variables.

**Recommendation:** (a). It is complete on its own: the kernel checks what is
written, and inference stays an untrusted producer checked against it, which is
`decision-effect-facets.md`'s P5 reading (`:152-154`). Nothing in it is replaced
later.

### NEEDS-AUTHOR 2: how a row and a row binder are written

**In plain words.** An effectful arrow needs a place to write "this crosses
`put`, touches region `s`, and whatever `e` stands for". A row variable needs a
kind to be bound at.

**Measurement.** Every item of an arrow but the last parses as a binder
(`lib/surface/parse.chiral:436-441`), and a list item without a leading numeral
parses as an anonymous binder's type, so a leading row item collides with a type
constructor of the same head. No `data` named `Row` exists under `lib/` or
`prog/`; `row` is a def at `prog/prose-lint.prog:164`. `CK20`'s NEEDS-AUTHOR 4
is open on the same arrow head (`docs/arcs/parts/checker-core-CK20.md:213-233`).

**Options.** (a) a leading row item under a reserved head, `(=> (row put (st s)
e) (1 h (Buf s)) I64)`, reserved only in that position; (b) a wrapper around the
arrow, `(with-row (put (st s) e) (=> …))`; (c) a new arrow head carrying the
row. The kind is written `Row` under all three.

**Recommendation:** (a). The row sits where the bit sits today, on the arrow
it types, and the reservation is positional, so `prose-lint`'s `row` is
untouched. Settle it with `CK20`'s spelling, since both write on the same head.

## 6. The mint packet

- **Elements:** one, `E39`, already minted. The carrier, the algebra, the
  kernel rules and the spelling constrain each other: without the spelling no
  row can be written, and without the scoping rule an entry naming `s` is
  unsound under substitution. Nothing is minted.
- **Band:** none drawn. `E39` predates the arc's block `E184-E189`.
- **Catalog row, amended:**
  `| E39 | **The effect row on the Pi**: a set of labelled entries with type-level arguments, a set of erased row variables of kind `Row`, and the top row; set equality in `conv`, subsumption in `subtype` with contravariant domains, join, removal, and the empty-or-nonempty projection the bit becomes. Alarms type as crossing entries; their handler is E26's. Erases: no emitted byte changes | one coarse bit; edge 16 | effect rows and effect sets, Leijen MSFP 2014, Tofte and Talpin 1997 (`PAPER`) | SH |`
- **Ledger row, amended:**
  `| E39 | effect-row | design | The effect row on the Pi: carrier, row variables, algebra, projection. Check: a gate phase over row equality, subsumption and removal with mutants, a region entry refused out of scope, a `->` accepted where `=>` is wanted, the E42 sample still refused; BUILD RULE `C1 == C2` with a byte-identical blob | SH |`
- **SPEC:** `docs/elements/specs/E39-effect-row-SPEC.md` is DEAD
  (`:13-17`) and targets the evicted Python oracle. `design-to-spec` writes its
  replacement from this file.
- **Size:** about 14 files and 420 lines. Kernel: two `Term` arms and one
  `Value` arm in `lib/surface/syntax.chiral` and `lib/typing/kernel.chiral`,
  the algebra at about 90 lines, the `subtype` arm and `infer-pi` and `t-row`
  rules at about 50, and nine walker sites (`lib/typing/kernel.chiral:677`,
  `:712`, `:766`, `:1193`, `:1219`; `lib/surface/data.chiral:208`, `:267`;
  `lib/lowering/upper/specialize-singleton.chiral:138`;
  `lib/surface/pretty.chiral:121`). `t-pi` keeps its arity, so the other 31
  Pi pattern sites are untouched. Core: `c-pi`'s `eff` becomes a row term over
  19 sites in 5 files, one line each, plus `row-crosses` at `pi-effs`. A
  `Reason` arm for the quantity-0 rule at about 8 lines over the tables in
  `lib/typing/diag.chiral`; the spelling at about 30 lines in `parse-arrow` and
  `build-pis`; the printer at about 15; a gate script at about 90. Basis: the
  counts in §2 and `CK20`'s per-site figures for the same files.
- **Related:** [[arcs/enforcement-arc]] `N26`, `N9`;
  [[arcs/memory-discipline-arc]] `M9`; `checker-core/CK20`; `E26`;
  [[records/findings]] FD-62; [[decisions/decision-effect-facets]].

### Needed and unrostered

| what | why this row needs it | where it would go |
|---|---|---|
| two [[records/author-calls]] rows, NEEDS-AUTHOR 1 and 2 | the run was barred from writing that file | a clerical write by the dispatching session |
| a pinned source for Pi subtyping with effect subsumption under QTT grades | the `subtype` arm is a trusted-core edit; FD-62 item 5(e) finds no pin covering a graded kernel | a `research` run, an `FD` row |
| `memory-discipline/M9`'s row still reads `E39` as "homed by nobody" | `docs/arcs/memory-discipline-arc.md:102` predates `1b9961e` | a `revisit` of that row |
| `CK20`'s question 3 rests on the seat's equality | `docs/arcs/parts/checker-core-CK20.md:209` cites `conv-struct`'s seat check, which this row moves to subsumption in `subtype` | a `revisit` of `checker-core/CK20` |
| FD-62 reads Koka's duplicates as serving inference alone | `KOKAROWS14:170-171` names precise types for elimination forms as the second use, which bears on `E26` | a `revisit` of FD-62 |
