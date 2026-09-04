---
node: decision-erased-word-level
layer: decision
related: [records/enforcement-arc, records/author-calls, banks/verification, decision-scope, decision-split-checker, modules-lowering, status-ledger, arcs/enforcement-arc]
status: settled
updated: 2026-09-04
---

# Decision: the erased-word type lives at the lowering type level

## The fork as it stood

`closconv-sig` groups higher-order call sites into defunctionalization families
keyed by a shape that erases every non-arrow type to one word
(`lib/lowering/upper/closconv.chiral:335-356`). The design note beside it states
the erasure as intent: domains always erase, because a polymorphic `(-> K K ..)`
parameter has to share a family with the concrete closures passed to it
(`lib/lowering/upper/closconv.chiral:359-363`). `apply-ty` then spells the
synthesized `$apply` dispatcher's domains with one family member's concrete
`Core` types (`lib/lowering/upper/closconv.chiral:1096-1098`), reached from
`lib/lowering/upper/closconv-driver.chiral:206`. Those concrete types survive the
peel, because `term->ntalty` carries a primitive type through as `nt-i64` or
`nt-str` and a data type as `nt-data` (`lib/lowering/compile-front.chiral:60-72`).

Four dispatchers therefore carry a tal type their own arms contradict, and
`ck-prog` is right to refuse them. [[records/enforcement-arc]] EN-15 holds the
measurement.

An erased domain's honest tal type is `tt-word`, which
`lib/lowering/tal/ssa.chiral:17-20` already defines as the uniform erased
one-word type, representation-compatible with any one-word type and checked by
`tal-ty=?`. The fork was where that word type lives. One side puts it in the
surface and core type language, where a nominal `Word` enters the kernel's `conv`
relation. The other side keeps it strictly at the lowering type level, where
`tal-ty=?` already carries representation compatibility.

## The decision, 2026-09-04

**The erased-word type lives strictly at the lowering type level. `Core` gains no
word spelling and the kernel's `conv` relation is not widened.**

## The reasons, in order of force

1. **Conversion is an equivalence relation, so it is transitive.** A `Word` that
   converts with `I64` and with `(List Str)` makes `I64` convert with
   `(List Str)`. That is a collapse of the source type system. GHC avoids exactly
   this by making `Any` a closed type family with no equations; Java avoids it by
   making `Object` a supertype in a directional relation. This reason alone
   settles the fork.

2. **The prior art is one-sided.** `.planning/RESEARCH-EN15-prior-art.md` §6
   surveys seven systems: the JVM verifier, MLton RSSA, TALx86, GHC, Pottier and
   Gauthier, Huang and Yallop, and OCaml with CakeML. Not one admits a type into
   the source conversion or equality relation that identifies two distinct ground
   types. Every one uses something else: a directional relation, a kind
   constraint plus a quantified variable, an explicit term-level cast, or no
   static relation at all.

3. **The kernel would gain a conversion it never uses.** `closconv-sig` runs
   after the typecheck (`lib/lowering/compile-front.chiral:342`), so its output is
   never re-checked by the kernel. Widening `conv` for a phase that relation never
   sees costs soundness and buys nothing.

4. **The relation already exists at exactly one level.**
   `lib/lowering/tal/ssa.chiral:17-20` defines `tt-word` as
   representation-compatible with any one-word type, checked by `tal-ty=?`. A
   second compatibility relation in the kernel is two statements of one rule, and
   the second drifts from the first.

5. **The one argument for the kernel refutes itself.** The reason to want `Word`
   in `Core` is to let the kernel re-check post-closconv output. That is one
   instrument asked to work at two levels, and [[banks/verification]] holds the
   opposite: layered independent instruments, each blind above its own branch
   point. The right instrument for lowered code is `ck-prog`, and wiring
   `ck-prog` onto the shipping path is precisely what EN-15 blocks. So the case
   for widening the kernel is a case for unblocking `ck-prog`, which is the
   ruling.

## What this does not settle

### The spelling, which is E185

The ruling fixes the level and leaves the shape of the erased position open. The
prior art splits, and `.planning/RESEARCH-EN15-prior-art.md` §6 names the split
under "Where the prior art is genuinely mixed":

| candidate | who does it |
|---|---|
| a quantified type variable, with the concrete types on the constructor | Pottier and Gauthier's specialized `apply`, TAL's abstract `α` in a register-file type, TALx86's `∀α:T4` |
| a coarse top or word type of the lower language, related by subtyping | Java's `Object`, the JVM verifier's `oneWord`, MLton's `RepType` with `isSubtype` |

The tree already reaches `tt-word` from a type variable: `term->ntalty` maps
`(t-var i)` to `(nt-word)` at `lib/lowering/compile-front.chiral:70`, under the
comment "B1: an erased type variable in a KEPT position". That is an observation
about what machinery exists and decides nothing. E185 carries the choice.

### The `$kI_J` capture constructor's field types

**A separate open call, and this is a correction.** An earlier reading in session
took the two instances to have one answer. `.planning/RESEARCH-EN15-prior-art.md`
§7 shows the prior art keeps constructor fields concrete. Pottier's
`succ : Arrow int int` carries concrete field types beside concrete arrow indices,
and Minamide, Morrisett and Harper's typed closure conversion hides a
heterogeneous environment behind `∃` with the fields concrete inside the pack.

A capture constructor is applied at one site, so nothing forces its fields to
merge. Only the shared dispatcher's argument position is constrained by the whole
family. Under that shape the constructor is the concrete side and the dispatcher
the varying side, which is the opposite arrangement to the measured `$apply7`,
which reddens through `ck-con`'s field check. Whether the two instances are one
defect or two stays unsettled, and a row in [[records/author-calls]] holds it.

## The survey

`.planning/RESEARCH-EN15-prior-art.md`, committed at `224f215`. Web research
only, seven systems read, every claim labelled **Read** or **Inferred**. §6 is the
convergent-practice table and the fork's weight; §7 is the capture-constructor
instance; §8 is what could not be found, including the absence of any published
statement of the thread-5 principle as a principle. The table stays there.
