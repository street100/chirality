---
node: decision-preserve-check
layer: decision
related: [decision-self-verification-hierarchy, decision-erased-word-level, arc-enforcement, records-findings, certificate-discipline, index]
status: settled
updated: 2026-09-08
---

# Decision: a preserve-check is two rungs, and `ttype`'s `Maybe` is the line between them

`docs/elements/catalog.md` E16 and E70 both name a **preserve-check** in their
titles and nothing in this tree defined the phrase. This settles it.

## The decision, 2026-09-08

**A preserve-check is both routes, and `PRINCIPLES.md` §5 assigns each one its
region.**

| rung | route | covers | verb |
|---|---|---|---|
| T0 | the typed route: preservation stated as [[records/findings]] FD-15's five lemmas, `⊢ e : τ` implies `⊢ [[e]] : [[τ]]` | the region where `ttype` answers `some` | prevention |
| T1 | the semantic route: a source semantics and a target semantics required to agree | the region where `ttype` answers `none` | detection |

`ttype` (`lib/lowering/upper/lower.chiral:35`) is `(-> UT (Maybe TalTy))`, and
that `Maybe` is P5's tier boundary written into the code without being named as
one. §5 states the rule the boundary follows: *a single source of truth is right
when the thing is provable and wrong when it is not, because in the unprovable
region one copy means you can never tell it changed.*

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

**Settled: the `none` arm is the defect, and it is a routing defect.** FD-16
measured no production compiler occupying the tree's position. Everyone types the
definition or aborts wholesale, and the one production partiality, a HotSpot C2
bailout, keeps the refused method running from an already-verified class file.
This tree drops the definition from the artifact `ck-prog` reads. Under this
decision a `none` is not a failure, it is a routing decision to T1, and dropping
is neither.

**Not settled here: which discharge T0 takes.** FD-17 measured five and none is
free. That is a separate call and this decision does not make it.

**Not settled here: the sequencing.** T1's two halves exist unimported at 187 and
109 lines; T0's work is the whole remaining conformance queue. Which runs first is
scheduling and `.planning/TAL-CONFORMANCE-QUEUE.md` carries it.
