---
node: decision-preserve-check
layer: decision
related: [decision-self-verification-hierarchy, decision-erased-word-level, arc-enforcement, records-findings, certificate-discipline, index]
status: settled
updated: 2026-09-09
---

# Decision: a preserve-check is two rungs, and the line between them is what a type claim carries

`docs/elements/catalog.md` E16 and E70 both name a **preserve-check** in their
titles and nothing in this tree defined the phrase. This settles it.

## The decision, 2026-09-08

**A preserve-check is both routes, and `PRINCIPLES.md` §5 seats each one on its
own rung.**

| rung | route | covers | verb |
|---|---|---|---|
| T0 | the typed route: preservation stated as [[records/findings]] FD-15's five lemmas, `⊢ e : τ` implies `⊢ [[e]] : [[τ]]` | type preservation, over every definition that lowers | prevention |
| T1 | the semantic route: a source semantics and a target semantics required to agree | value agreement, over the same definitions | detection |

The two rungs stack over one program. T0's claim is target well-typedness, and it
says nothing about which value a well-typed body returns; T1 is what carries the
value. §5 states the rule the boundary follows: *a single source of truth is right
when the thing is provable and wrong when it is not, because in the unprovable
region one copy means you can never tell it changed.* Its own rung table stacks
the same way, seating the reconciler as "a T0 singleton guarding T1 material".

⚑ **Corrected 2026-09-09. This decision placed the line at `ttype`'s `Maybe`, and
that function has no caller.** The text read "`ttype`
(`lib/lowering/upper/lower.chiral:35`) is `(-> UT (Maybe TalTy))`, and that
`Maybe` is P5's tier boundary written into the code without being named as one",
with T0 covering "the region where `ttype` answers `some`" and T1 "the region
where `ttype` answers `none`". `docs/arcs/parts/enforcement-N14.md` measured
`ttype` at **zero call sites** anywhere under `lib/`, `prog/` or `tools/`, so
neither region is a region of anything that runs. The live type translation is
`term->ntalty` (`lib/lowering/compile-front.chiral:58-79`), which answered
`(none)` on **zero of 22,742 globals** across 63 roots, and its image passes
through `ntalty->talty` (`lib/lowering/compile-back.chiral:24`), declared
`(-> NTalTy TalTy)` with no `Maybe` to answer with. **No type translation on the
shipping path has a refusal region for a tier line to run through.** What the
typed route leaves uncarried is the value, and the tree has measured two ways
past it. `tal-ty=?`'s first arm makes `tt-word` match every one-word type
(`lib/lowering/tal/check.chiral:68-70`), and `term->ntalty` hands `t-var` and
`t-pi` exactly that carrier (`:70-71`), so a coarse target type accepts a value
the source type refuses. An exact ground target type still pins no value, which
is EN-20's own fixture: the codomain is `I64`, `const 0` matches the declared
return, and nothing reddens. Coarseness covers the first escape and misses the
second, so coarseness does not draw the line either.

## Why both, rather than one

**They are different verbs.** §5's own verb-honesty paragraph says this principle
is detection where P1 through P4 are prevention, and requires the downgrade be
named rather than left to imply. A typed claim prevents. An agreement between two
evaluators notices. Neither substitutes for the other and the tree has measured
what happens when only one is present.

**The tree already holds the counterexample.** [[records/enforcement-arc]] EN-20:
`arm-body`'s `(none)` arm emits `const 0`, the literal matched the declared
return where the codomain was ground, `ck-prog` accepted, and the target returned
`0` where the source returned `30`. Target well-typedness accepted a program that
did not preserve meaning. T0 alone does not catch it and T1 convicts it.

**The published position is both.** FD-20 measured CompCert proving
`transf_c_program_correct` once over all programs and additionally running
per-pass validators of the form `check_function (rtl) (ltl) (env)` for the passes
it does not prove outright.

**The writers are independent, which is T1's stated catch.** §5's rung table
warns that N copies buy integrity only if the writers are independent rather than
the copies. `lib/evidence/interp.chiral` evaluates `Core`; `lib/lowering/tal/eval.chiral`
evaluates the tal IR. Two languages, two implementations. That is the criterion
[[decision-self-verification-hierarchy]] §0 sets when it rules out a second
emitter over one rule set as a second formulation.

## What this settles, and what it does not

**Settled: `ck-prog` is not a preserve-check and never was.** FD-20 measured every
published construction reaching preservation as a function of two programs,
`Validate(S, C)`, `check_function (rtl) (ltl) (env)`, `V : Source x Target -> boolean`.
`ck-prog` is `(-> CEnv Prog TckR)` and both arguments are target-level, so
accepting witnesses target well-typedness alone. `docs/elements/catalog.md:484`
calls it a translation validator already, and that sentence is refuted by arity
in `records/lenses/problems.md` PRB-77.

**Settled: dropping a definition is the defect, and it is a routing defect.**
FD-16 measured no production compiler occupying the tree's position. Everyone
types the definition or aborts wholesale, and the one production partiality, a
HotSpot C2 bailout, keeps the refused method running from an already-verified
class file. This tree drops the definition from the artifact `ck-prog` reads,
measured 2026-09-09 at **347 skip records over 22,742 definitions, 1.53%**, in
three channels. Under this decision a refusal routes to T1, and dropping does
neither job.

⚑ **Corrected 2026-09-09. The door is term-level, and this paragraph attributed
it to a type translation.** The text read "This tree drops the definition from
the artifact `ck-prog` reads. Under this decision a `none` is not a failure, it
is a routing decision to T1, and dropping is neither", with the `none` meant as
`ttype`'s. `docs/arcs/parts/enforcement-N14.md` classified all 347 records
through `skwhy-tag`. Every one of the **182** records from the arm this decision
names, `le-skip` at `lib/lowering/compile-back.chiral:270-271`, comes from
`lib/lowering/upper/lower.chiral:283`, `expr-app`'s catch-all on a spine head
that is neither `lc-prim` nor `lc-global`, 162 records; `:251`, `expr`'s `lc-lam`
arm, 10; and `:417`, `compile-fn` failing `strip-lams`, 10. None of the three
consults a type translation. The comment at
`lib/lowering/compile-back.chiral:265-269` states it from the other side: the
front's peel gate is coarser than the back's body compile, so a def passes peel
and fails here. The other 165 are `filter-erasable` (5) and the callee cascade
(160). **A definition leaves the artifact because its body does not lower.**

**Settled: T1's population is the definitions that lower.** The peel accepted all
22,742 globals and the back dropped 347 before emission. A dropped definition has
no tal image, so `lib/lowering/tal/eval.chiral` has nothing to run and the
agreement T1 requires cannot be formed over it. T1 covers what reaches the
artifact, and measuring what does not is a separate instrument.

**Not settled here: which discharge T0 takes.** FD-17 measured five and none is
free. That is a separate call and this decision does not make it.

**Not settled here: the sequencing.** T1's two halves exist unimported at 187 and
109 lines; T0's work is the whole remaining conformance queue. Which runs first is
scheduling and `.planning/TAL-CONFORMANCE-QUEUE.md` carries it.
