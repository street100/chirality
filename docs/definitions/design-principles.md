---
node: design-principles
layer: foundation
related: [thesis, joining-law, floor-agreement, status-ledger, open-edges, syntax-evolution]
status: draft
updated: 2026-07-06
---

# Design principles (the reader's side)

There are two kinds of principle in this project. `PRINCIPLES.md` at the root
states the seven the *architecture* commits to — what the language governs
(express everything, everything is a process, govern the ports, compute is inert
until it touches a port, the safe path is the cheap path...). This note states
the ones the *surface* commits to — how the language and its documentation
present to a person. The architecture principles decide what is *true*; these
decide whether a human can *see* that it is true. They answer to one test.

## The test: regularity

A language exists to manage human fallibility — to make a program fit in a head.
The load-bearing criterion for that is **regularity**: things that look the same
behave the same, and things that behave differently look different. Its violation
is the worst class of defect, because it defeats recognition: a reader can no
longer trust that a familiar shape means what it meant last time, so every
instance must be re-reasoned from scratch (the `==` disease — a comparison whose
meaning depends on the operands' types).

Regularity is the presentation-layer cousin of P5, *the safe path is the cheap
path*. P5 makes the safe shape the default to **write**; regularity makes the
true shape the default to **read**. It is tested on three surfaces, and this
cycle chirality failed it on all three:

- **Syntax** — a form means one thing everywhere. Today the multiplicity marker
  is an int literal (`0`, `1`) in one place and a symbol (`w`) in another, and
  `the` puts the type first against the ecosystem's learned expr-first order.
- **Semantics** — a program computes one value on every executor. `-7/2` computed
  three different values across the reference interpreter, the constant-folder,
  and native code — regularity broken at the semantic level, which
  [[floor-agreement]] now forbids.
- **Documentation** — a note's tense matches its status. Present-tense prose reads
  as shipped whether or not it is; [[status-ledger]] restores the match by
  tagging design prose, so present tense stops implying built.

That one criterion, across syntax, semantics, and docs, is the spine. The rest of
the criteria are how you reach it.

## The criteria, and where chirality sits

Seven, foundation-first (after Feinman):

1. **Readability** — read it, know what it does. chirality pays for this by putting
   every effect and cost in the type (P2); it currently *loses* it to an
   annotation tax that buys nothing (see the trades below).
2. **Expressability** — know what to write. s-expressions are weak here (no shape
   to guide toward); the real surface (stage 4) owes this.
3. **Predictability** — generalize new code from one example. Regularity's
   precondition. Flat-only patterns and case pyramids erode it.
4. **Regularity** — the keystone, above.
5. **Concision** — short. Deliberately *demoted* (below).
6. **Summarizability** — think at the level you care about. The two axes and
   profiles give this at module scale.
7. **Separability** — edit and test in parts. The splitting and [[joining-law]]
   discipline is exactly this.

## The deliberate trades

chirality ranks **regularity and safety over concision.** When they conflict, the
verbose-but-regular, verbose-but-safe form wins — this is why every effect and
every unit of cost sits in the type (P2), making signatures heavier on purpose.

But demoting concision is not a licence for noise. Regularity's verbosity is
tolerable only because *the ordinary fades*: you spend words on the unusual and
let defaults and inference absorb the routine. So the rule that follows is one
line — **spend verbosity only where it carries meaning; reclaim it everywhere it
is noise.**

- **Signal — spend here.** The grade a value carries, the effects it has, the
  resources it spends, the refinement it satisfies. These are the unusual the
  reader must see. Under-specifying them (one effect bit, one scalar grade) is
  the real regression, not the verbosity.
- **Noise — reclaim here.** A type the checker could infer, an erased parameter
  written longhand, a constructor annotation forced by weak inference. These are
  the ordinary; making the reader write them is pure extraneous load with no
  safety bought.

The scaffold currently has this backwards: verbose where it is noise (the
`(the (List A) ...)` tax, the `(0 A (type 0))` boilerplate) and terse where it is
signal (effects are one bit, grades one scalar). The correction is a
*reallocation*, not a net change in verbosity — richer explicit grades and
effects, inferred and implicit ordinary. [[syntax-evolution]] applies this.

## Why this is a theory, not taste

The criteria are not aesthetics. Cognitive-load theory splits the load a task
imposes into *intrinsic* (the problem's real difficulty), *extraneous* (imposed
by presentation), and *germane* (building the right mental model). The language's
whole job on the human side is to cut extraneous load so germane load is free for
the problem. Every item above is an extraneous-load lever: the annotation tax is
extraneous load outright; a regularity break converts recognition (free) into
recall (costly); a mis-tensed note adds an "is this real?" check to every claim.

And concision for its own sake is a trap: a length or complexity metric does not
track what a human actually perceives as legible, so *short is not the same as
clear*. The small kernel is small because it borrows the host substrate, not
because it is simple ([[status-ledger]] draws that line, [[floor-agreement]] and
[[trust-boundary]] keep it honest). Optimize the reader's model, not the metric.

## Using the charter

- A choice that trades regularity or safety against concision resolves the same
  way every time: regularity and safety win.
- Adding verbosity, ask: is this the *unusual* (spend) or the *ordinary*
  (reclaim)?
- Adding a surface form, apply the regularity test: does it look different only
  where it behaves different, and can a reader generalize it from one example?
  ([[syntax-evolution]].)
- Writing a design note, apply the doc-regularity test: does the tense match the
  build status? ([[status-ledger]].)

The spine, one line: **make chirality behave as it looks — across syntax, semantics,
and docs — and spend verbosity only where it carries meaning.**
