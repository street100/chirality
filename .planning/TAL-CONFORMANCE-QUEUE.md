# The TAL conformance queue

The property, stated by the author 2026-09-08: **if you type the upper language
you can lower to the lower language fully and properly typed.** That is
type-preserving compilation, and the typed-assembly floor is the witness for it.
This file is the live queue that gets the tree there.

`docs/arcs/enforcement-arc.md` requirement 2 carries the arc-side statement.
`records/lenses/problems.md` PRB-15, PRB-38, PRB-41, PRB-42, PRB-45, PRB-46,
PRB-49, PRB-53, PRB-67 and PRB-73 are measurements against the property rather
than independent defects, which is the reading this queue replaces. Ruling them
one at a time as separate repairs produces locally cheap answers that do not
compose into a floor.

## What the tree measured before opening this

Taken 2026-09-08 at `e82e50e`, so the queue starts from facts rather than
from the rows' own summaries.

| fact | where |
|---|---|
| `LCore` is type-erased | `lib/lowering/upper/lower.chiral:116-123` |
| `TalTy` is five constructors, one of them `tt-word` | `lib/lowering/tal/ssa.chiral:21-22` |
| `tal-ty=?` is word-compatibility rather than nominal equality, and `tt-word` matches every type on either side | `lib/lowering/tal/check.chiral:66-77` |
| an empty type-argument list is a wildcard at the argument-list level | `lib/lowering/tal/check.chiral:78-95`, `targs=?` |
| `ck-prog` and `ck-block` have zero call sites outside their own module | measured, `grep` over `lib/` and `prog/` |
| the only caller of `ck-fn` in the tree is a gate probe | `prog/optimizer-census.prog:78` |
| the erased-word type lives strictly at the lowering type level, and `Core` gains no word spelling | `docs/decisions/decision-erased-word-level.md`, ruled 2026-09-04 |

The consequence those seven lines carry together: **the tree does not preserve
types down to the target, it preserves representation compatibility.** A checker
whose equality relation answers `true` for `tt-word` against anything is
checking that a value fits in a word. That is a real property and it is not the
property the author stated. Whether the gap is a defect or a costed choice is
what the queue's first three slices decide, and no row in the tree settles it
today.

## The vehicle

TAL is a published external object, so the synthesis is a `translate` run
writing `docs/translations/tal.md`, and the slices below are its gather. The
translate skill states the relation: research is the gather step of a translate
run, and the gather is pinned before anything is written.

`.planning/sources/TAL.gather` is the manifest and the translate run creates it.
`TALTOPLAS` is already pinned, by FD-14.

## The slices

One question each, one `research` run each, one `FD` row each in
`records/findings.md`, sources pinned. Serial, one agent at a time, per
`docs/decisions/decision-dispatch-cadence.md`.

| # | question | serves |
|---|---|---|
| R1 | What does the type-preservation theorem state, phase by phase, in the F-to-TAL translation, and what obligation does each phase carry? | the property itself. Everything below depends on it |
| R2 | Where do production compilers lose source types on the way down, and what do they give up by doing it? | whether `LCore`'s erasure is a defect or a costed choice |
| R3 | When a target type system is coarser than the source, what published mechanisms discharge the resulting soundness obligation, and what does each cost the producer, the checker and the runtime? | `tt-word`, `tal-ty=?`'s wildcard, E185, `decision-erased-word-level` |
| R4 | How is closure conversion typed, and what must the target type system express to state its result? | `closconv`, the `$apply` dispatchers, the `$k` capture constructors, PRB-45/46/49 |
| R5 | What must a block boundary carry for a target-level checker to be complete, and what obligation does that put on the producer? | PRB-73, and the producer half FD-14 did not reach |
| R6 | What does accepting a target program witness, and how do certifying compilers relate the source and the target? | what `preserve-check` means in E16's and E70's titles |
| R7 | How does an effect claim survive lowering, and what carries it at the target level? | E70, PRB-53 |

### What is already answered, so no slice re-asks it

**FD-14** settled the reporting half of R5: a checker collects several refusals
when the state at every block boundary is written in the artifact under check,
and one that derives its own environment stops at the first refusal, is made
total, or poisons and suppresses. R5 takes the producer half only: what has to
be declared, how it is verified, and what it costs the pass that emits it.

**`decision-erased-word-level`** settles the LEVEL: the erased word lives at the
lowering type level and `Core` gains no word spelling. R3 does not reopen the
level.

**FD-16** settled what R3 originally asked. Collapsing to a uniform word is
ordinary production practice and every surveyed compiler does it, so the
alternatives question is closed. What FD-16 left open is the discharge: the two
surveyed systems keeping a checked target over a coarser type language charge
the producer a runtime cast at every use site, and the tree charges nothing. R3
was rewritten to that question on 2026-09-08 and FD-17 answers it.

## Order, and why

R1 first: it defines the property, and a slice run before it would be measuring
against a target nobody has stated. R3 second: it is the sharpest live question
in the tree and the one the most rows touch. R2 third: it prices R3's answer
against what production compilers actually accept. R4, R6, R5, R7 follow, and
R7 is last because E70 is unbuilt and gated on `decision-effect-facets`.

## State

| slice | state |
|---|---|
| R1 | FD-15 |
| R2 | FD-16 |
| R3 | FD-17 |
| R4 | UNRUN |
| R5 | UNRUN |
| R6 | UNRUN |
| R7 | UNRUN |
| translate | blocked on the gather |
