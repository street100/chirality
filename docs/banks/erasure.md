---
node: banks/erasure
layer: bank
tier: depth
related: [banks/INDEX, banks/capability, banks/effect-and-alarm, banks/memory, banks/port, banks/runtime, banks/verification, decisions/decision-erased-word-level, arcs/enforcement-arc, records/enforcement-arc, status-ledger]
status: current
updated: 2026-09-04
---

# Bank: erasure

> The monolith this refracts: **type erasure, the compiler dropping types before
> codegen**. One phase elsewhere; here, at least three independent mechanisms,
> at three levels, each with its own justification.

**Why this bank exists.** Erasure is load-bearing in five existing banks and the
subject of none. [[banks/capability]] rests its Shard H on it, "reflection
without authority (the erased witness)"; [[banks/effect-and-alarm]] carries
`erased-allow` as the membrane's third rule; [[banks/memory]] carries the erased
capacity bound; [[banks/port]] and [[banks/runtime]] each carry one line of it.
A concept that supports five other concepts and has no home of its own is where
the misfire in §4 comes from.

**The measurement, 2026-09-04.** `eras` appears **262 times across 42 files** in
`lib/` and `prog/` by `grep -roi`. Two modules are named for it,
`lib/typing/erased-nf.chiral` (47 L) and `lib/lowering/tal/erase.chiral`
(284 L), and a third completes the join, `lib/lowering/tal/reify.chiral` (62 L).
⚑ Two of the 42 files carry a **different word**: `lib/protocol/vt-parser.chiral`
declares `erase-display` and `erase-line`, the terminal ED/EL sequences, and
`lib/protocol/grid.chiral` carries both senses in one file: the terminal one at
`:143` and the type-level one at `:26-27`, where `rows`/`cols` are unerased
runtime witnesses and the bound `n` is the erased type-level size. Those two
files hold 21 of the 262.

**Build state.** Grounded in `records/conformance-map.md` and [[status-ledger]].
⚑ The map has a row for **one** of the shards below. It classifies 82 rows over
E-numbers reaching E67 plus E166, against a catalog of 180, so for shards keyed
to E100, E125, E154, E184 and E185 the map **has no row** and the state beside
them is measured against the tree instead. Saying otherwise would be a gate that
cannot fail.

---

## 1. The concept in chirality

**The one-sentence truth.** There is no single erasure here; there are three
independent ones, at three levels, and each one is answerable for a different
property.

**What erasure IS.** Three separate droppings, each with its own justification:

- **Quantity.** A `q=0` binder has no runtime presence, so nothing represents it.
  The justification is the QTT usage audit: a binder used zero times cannot be
  observed.
- **Representation.** Every non-arrow type is one machine word, so two concrete
  types that differ only in name may share one defunctionalization family. The
  justification is that no machine instruction distinguishes them.
- **Annotation.** The typed SSA joins the executable IR by dropping `TalTy`. The
  justification is that the annotations existed for a checker that has already
  run.

**What erasure IS NOT.** A phase. No pass in this tree is named "erase types";
`lib/lowering/tal/erase.chiral` drops one specific IR's annotations and nothing
else. Erasure is also no licence to identify two types:
[[decisions/decision-erased-word-level]] rules that the erased-word type lives
strictly at the lowering type level, that `Core` gains no
word spelling, and that the kernel's `conv` relation is untouched. The reason is
that conversion is an equivalence relation and therefore transitive, so a `Word`
converting with `I64` and with `(List Str)` would make `I64` convert with
`(List Str)` and collapse the source type system.

---

## 2. The refraction: the shards, their homes, their build-state

| | shard | home | state |
|---|---|---|---|
| **A** | **quantity erasure**: a `q=0` binder has no runtime presence | `lib/typing/qtt.chiral`, with `Qty` at `:14`, `qmul` at `:24` whose zero arm annihilates, and `qfits` at `:40`; `lib/typing/kernel.chiral:852-853`, Pi formation binds the domain at `q0` and the comment reads *"Usage is empty at formation (types erase)"* | **built.** The conformance map's two E5 rows are both `CONFORMS`, and the second states the tie directly: *"linear-kind wired at on_binder (q=1), erasure forces q=0 pure"* |
| **B** | **erased-position purity**: a `q=0` position must be pure | `erased-allow`, `lib/typing/effects.chiral:38-39`, the effect membrane's third seam | **written and unreached.** [[status-ledger]]'s Effects row measures it: the three seams *"have no caller anywhere in the tree"*, and the module's two importers take `row-join`/`row-sub`/`mem-str` only. The map classes the membrane `EXTEND` under E12. The caller is **E171**, `design` |
| **C** | **proof irrelevance**: a refinement lowers as its base | the refine arm of the type peel, at `lib/lowering/compile-front.chiral:69`, whose own comment reads *"E125: a refinement is proof-irrelevant / erased at runtime"* | **built.** E125 is `built` in [[status-ledger]]. Map has no row |
| **D** | **type-kinded capture drop**: a captured type variable becomes no closure field | `field-erased?` and `kept-count`, `lib/lowering/upper/closconv.chiral:716-722`; the predicate is `q=0` **or** the field's type is a `c-type` | **built**, E100, 2026-08-16. It exists because the earlier code word-ified type-kinded captures into `$clo` fields, a `t-type` field failed `term->ntalty`, and the whole `$apply` vanished. Map has no row |
| **E** | **representation-shape erasure**: every non-arrow is one word, so a defunctionalization family merges | `shape-eq`, `lib/lowering/upper/closconv.chiral:335-356`; the design note at `:359-363` states the intent, that domains always erase while codomains stay concrete when ground: *"two families that return different ground types … must NOT merge"* | **built.** Map has no row |
| **F** | **the uniform erased word** at the lowering type level | `tt-word`, `lib/lowering/tal/ssa.chiral:17-20`, defined as representation-compatible with any one-word type and checked by `tal-ty=?` (`lib/lowering/tal/check.chiral:68`, whose first arm makes it match everything). Its neutral twin is `nt-word` (`lib/lowering/lowspec.chiral:32`), carried to `tt-word` at `lib/lowering/compile-back.chiral:28` | **built**, and the relation is the one the checker repairs of 2026-09-03 (`ddfbc27`) restored. [[records/enforcement-arc]] EN-14 holds the measurement |
| **G** | **kept-versus-erased domains at the peel** | `ty-kept-doms`, `lib/lowering/compile-front.chiral:159-163`, dropping every domain whose quantity is 0; `term->ntalty` then maps `(t-var i)` to `(nt-word)` at `:70`, commented *"B1: an erased type variable in a KEPT position"* | **built.** This is the tree already reaching the erased word from a type variable, which [[decisions/decision-erased-word-level]] names as an observation about existing machinery that decides nothing |
| **H** | **type-level def removal at the back** | `filter-erasable`, `lib/lowering/compile-back.chiral:183-192` | **built as a dry-run erase, and it keeps no record for this arm.** ⚑ See the note below: the row as usually stated does not survive contact with the code. E184's `erased-by-design` arm is the fix and is `design`, unbuilt |
| **I** | **annotation erasure, the two-IR join** | `lib/lowering/tal/erase.chiral` (284 L) drops the `TalTy` annotations, flattens `Block`/`TalTerm` into seq-structured code, resolves each constructor name to its declaration-order tag and decides immediate-versus-boxed; `lib/lowering/tal/reify.chiral` (62 L) rebuilds the executable IR 1:1; `lib/typing/erased-nf.chiral` (47 L) is the neutral form between them. The whole erasure is `reify-fn . erase-fn` | **built**, pure, total, errors-as-values |

⚑ **Shard H, corrected against the source.** `filter-erasable` is commonly read
as the pass that removes type-level defs. What it actually does is run `erase-fn`
as a dry run and keep the TFns that succeed. A def outside the native subset is
dropped, and it earns a skip record only when `first-nonlowering-op` names an
offending extern; everything else is dropped silently. So a type-level def and a
def that failed to lower leave the tree by the same door and with the same
absence of a record. That is precisely why E184's R1 requires a separate
`erased-by-design` fate arm: *"a type-level def is not a failed lowering, and
without that arm every ratio built on the fates is noise"*
([[arcs/enforcement-arc]], R1).

⚑ **A fourth erasure, one line and no shard.** `lib/typing/kernel.chiral:681`
drops a `t-ann` at evaluation. It falls outside A (the quantity goes unconsulted),
outside E (no representation is involved) and outside I (no IR is crossed), and
no element row names it. It is recorded here and given no shard of its own,
because one arm of an evaluator is too small to refract.

---

## 3. Cross-cuts: where an erasure shard IS another concept's shard

This is the section the bank was built for. Erasure is already load-bearing in
five banks, and the structural finding below is the one that changed how the
tree is laid out.

- **The erased witness ([[banks/capability]] Shard H) is A plus B.** A capability
  present in the type and erased at runtime is structurally unable to be
  exercised, which is what lets scriba render a datum indexed by a cap without
  holding it. Shard H names its own prerequisite: the pattern is sound only if a
  `q=0` position is effect-free. ⚑ **That bank calls the prerequisite enforced,
  and [[status-ledger]] says it is not.** The seam it cites by line number is the
  cut oracle's; the live home is `lib/typing/effects.chiral:38-39`, and the
  Effects row of the ledger measures those three seams as having no caller
  anywhere in the tree. The pattern is sound by construction at the type level
  and unguarded at the seam. E171 is the row that closes the gap.
- **`erased-allow` ([[banks/effect-and-alarm]]) is B, and it is the whole of B.**
  There it is one of three membrane rules beside `on-apply` and `on-binder`;
  here it is the subject, and the reason the other two are its neighbours is
  that all three gate the same annotation.
- **The erased capacity bound ([[banks/memory]]) is A applied to a size index,
  with C on top.** The bound arrives as an erased `(0 n I64)` on both operations
  (`lib/ports/pool.port:27`, `:31`), the `< n` in a refined offset references
  that erased capacity and
  collapses at a concrete pool, and the runtime check runs against the witness
  `cap` rather than against `n`. Space-as-a-port is built on a number that is
  not there.
- **The pure outer arrow over an erased bound ([[banks/port]]) is A plus B.** A
  crossing spelled with a pure `->` wrapping an inner `=>` is only honest
  because the outer binder is erased and an erased position is required pure.
  B is what makes that signature readable rather than a loophole.
- **Dropping `q=0` lets in the evaluator ([[banks/runtime]]) is A at the
  interpreter, and the live kernel does not do it.** That bank's line points at
  the cut oracle. `lib/typing/kernel.chiral:680` evaluates a `t-let` by pushing
  the value into the environment whatever the quantity says, so A stops at the
  type level and the evaluator carries the value anyway. What the live evaluator
  does erase is the annotation, one line below at `:681`, *"annotations erase at
  eval"*, which is the fourth erasure noted under §2.
- **The tal-type equality that erasure needs is a [[banks/verification]]
  instrument.** `tal-ty=?` (`lib/lowering/tal/check.chiral:68`) is what makes
  shard F checkable, and [[decisions/decision-erased-word-level]] reason 5 turns
  on the verification bank's own rule: one instrument may not work at two levels,
  so the kernel does not re-check post-closconv output and `ck-prog` is the right
  instrument for lowered code.

### The structural finding: erasure cannot be one module here

`lib/typing/erased-nf.chiral`'s header records it, and
`lib/lowering/tal/erase.chiral`'s header records it again.
`lib/lowering/tal/ssa.chiral` (the typed SSA lowering produces) and `lib/lowering/tal/ir.chiral` (the executable
IR the emitter consumes) **deliberately reuse constructor names**. `TFn`, `t-ret`
and their neighbours mean the annotated thing in one and the erased thing in the
other, and the ssa header says so: *"Keep the two separate: same names, different
meanings."* chirality has a flat global namespace and whole-file `import` with no
selective or qualified form, so one module importing both is a hard load error
(`t-ret redeclared`).

So the erasure is three files rather than one: `erase.chiral` imports the typed
SSA and produces `NFn`; `reify.chiral` imports the executable IR and rebuilds
from `NFn`; `erased-nf.chiral` is the collision-free wire, using only prelude
types and `n-`-prefixed constructors so it can be imported beside either side.
The module split is a workaround for a namespace defect, and the header names it
as such.

**The tree files that defect under E154**, per-module label mangling at
lowering, `design` and unbuilt. [[records/enforcement-arc]] EN-16 and
[[arcs/enforcement-arc]] both name its most recent instance:
`lib/lowering/tal/check.chiral` declares eleven top-level names that already
exist in the compiler's blob, which is why `lib/lowering/compile-back.chiral`
cannot import it and why `ck-prog` has no call site, the block on requirement 2
of the enforcement arc. EN-16 also finds that five of those eleven are
byte-identical duplicates rather than homonyms, so the prefix that makes the
module loadable leaves two copies of one function. **One unbuilt element is
therefore holding both the shape of this bank's largest shard and the enforcement
arc's live blocker.**

---

## 4. Native → chirality translation (the misfire → the correction)

- **"The compiler erases types before codegen, like Java or GHC."** → There is no
  such phase. There are three erasures at three levels: quantity (shard A, in the
  kernel, justified by the usage audit), representation (shard E, in closure
  conversion, justified by the machine word), and annotation (shard I, at the tal
  join, justified by the checker having already run). They drop different things,
  at different times, and answer to different properties.
- **"Then a `Word` type in the source language would tidy all three up."** →
  Refused, 2026-09-04. Conversion is an equivalence relation and therefore
  transitive, so one `Word` converting with two distinct ground types identifies
  those two ground types. `.planning/RESEARCH-EN15-prior-art.md` §6 surveys seven
  systems and none admits such a type into a source conversion or equality
  relation. [[decisions/decision-erased-word-level]] carries the ruling.
- **"An erased value is untyped, so anything goes there."** → An erased position
  is *more* constrained. Shard B requires it pure, and the binder rule refuses a
  linear type at quantity 0 outright, because a value bound at 0 is erased
  without ever being discharged (`lib/typing/kernel.chiral:344-350`).
- **"Erasure is a back-end concern."** → Shards A, B and C are all in
  `lib/typing/`. Only E, F, H and I are downstream of the typecheck.
- **Conflating the three is what produced the EN-15 confusion.** The question
  *"where does the erased word type live?"* only looks hard while quantity
  erasure, representation erasure and annotation erasure are treated as one
  thing. Separated, the answer falls out: the erasure that produced the problem
  is representation erasure, which happens after the typecheck, so the type it
  needs belongs at the level where that phase is checked.

---

## 5. What is genuinely unbuilt: the honest residue

1. **The spelling of the erased position. E185, `design`, minted 2026-09-04,
   needing the full pipeline.** The level is settled by
   [[decisions/decision-erased-word-level]]; the shape is open. `apply-ty`
   (`lib/lowering/upper/closconv.chiral:1096-1098`) spells the synthesized
   dispatcher's domains with one family member's concrete `Core` types, so four
   `$apply` dispatchers carry a tal type their own arms contradict and `ck-prog`
   is right to refuse them. Two candidates, and
   `.planning/RESEARCH-EN15-prior-art.md` §6 measures the prior art as split: a
   quantified type variable with the concrete types on the constructor, against a
   coarse word type of the lower language related by subtyping. ⚑ Nothing here is
   a miscompile. Every one of these values is one word at runtime and the emitted
   code is correct; the defect is the type the IR carries.
2. **The `$kI_J` capture constructor's field types. EN-17, an open author call,
   opened 2026-09-04.** Research §7 finds both published shapes keeping
   constructor fields concrete, and the structural reason is that a capture
   constructor (`ctor-name`, `lib/lowering/upper/closconv.chiral:1114`) is
   applied at one site, so nothing forces its fields to merge, while the shared
   dispatcher's argument position is constrained by every family member at once.
   That is the opposite arrangement to the measured `$apply7`, so whether the two
   instances are one defect or two is unsettled and E185's ruling may or may not
   reach the fields.
3. **The `erased-by-design` fate arm. E184, `design`, unbuilt.** It exists
   because a type-level def is a deliberate outcome while a failed lowering is a
   defect, and shard H cannot tell the two apart today. Without it every ratio
   built on the fates is noise.
4. **Per-module label mangling. E154, `design`, unbuilt.** The structural fix
   for the defect that forces shard I into three files and that blocks `ck-prog`
   from reaching the shipping path. Hand-patched at every prior instance;
   [[records/enforcement-arc]] EN-16 is the latest.
5. **The caller for `erased-allow`. E171, `design`, unbuilt.** Shard B's rule is
   in the tree and generalized to set-containment. What E171 owes is the reach
   from the kernel's apply and binder judgments, so that a `->` body cannot
   arrive at a crossing transitively. Until it lands, shard B constrains nothing
   that runs, and [[banks/capability]]'s Shard H prerequisite is a type-level
   argument rather than an enforced one.

**Gradient, stated once.** Shards A, C, D, E, F, G and I are built and running on
every compile. Shard B is written and unreached. Shard H runs and records
nothing. The five residue rows above are the whole of what erasure owes.

---

## 6. Relational anchors: thin notes that should link INTO this bank

- [[banks/capability]]: Shard H is A plus B, and its prerequisite is §5 item 5.
- [[banks/effect-and-alarm]]: `erased-allow` is shard B, one of its three seams.
- [[banks/memory]]: the erased capacity bound is A with C on top.
- [[banks/port]]: an erased bound under a pure arrow is A plus B.
- [[banks/runtime]]: dropping `q=0` lets is A at the evaluator.
- [[banks/verification]]: `tal-ty=?` is what makes shard F checkable, and its
  one-instrument-per-level rule carries reason 5 of the erased-word ruling.
- [[decisions/decision-erased-word-level]]: the level, settled 2026-09-04.
- [[arcs/enforcement-arc]]: requirement 2, and E184 and E185 in full.
- [[records/enforcement-arc]]: EN-13 through EN-17 are the measurements under
  §5.
- [[status-ledger]]: build state for E100, E125, E154, E171, E184, E185.
