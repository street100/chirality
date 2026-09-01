> **ARCHIVED 2026-09-01. Superseded by `docs/decisions/decision-graded-kernel.md`, tracked, by this file own statement.** The settled record is the decision note.

# Foundation forks: the graded-kernel design pass

> **SETTLED 2026-07-05.** All three forks decided per the recommended defaults
> (A: parametric semiring, ℕ∪{∞} now, full factor width; B1 checker + ratified
> total-by-default; C1 modal staging, two-level first). The settled record is
> `docs/decision-graded-kernel.md`. First increment built: strict-positivity
> checking (Fork B), 5 tests, `scaffold/chirality/data.py`. This file is retained
> as the working rationale behind that note.


Context: Decision 1 (from `SCAFFOLD-NEXT.md`/`DESIGN-SESSION-PREP.md`) is
settled — **A: enrich the kernel's grade structure** rather than keep cost in
an external module. That turns "one letter" into a real foundational design
pass, because enriching the kernel means fixing the shape of the graded
structure *once* (changing it later is the trusted-kernel churn A was chosen
to avoid). This note lays out the three sub-forks that shape follows.

Framing that resolves the "carve all the stones" question: the things we want
are not all the same kind of rock.
- **Coeffect grades** (compose in one product semiring): usage, time, space,
  information-flow. Granule is the existence proof they cohabit.
- **A property, not a grade**: termination — totality checking, separate
  machinery. It is the *license to evaluate early* (pregen safety).
- **A modality, not a grade**: binding-time / staging. It is the *engine* of
  pregen (what is known-now vs known-later).

So: one semiring (Fork A), one totality mechanism (Fork B), one staging
modality (Fork C). Each below is a decision with a recommended default.

Once decided, these graduate to `docs/decision-*.md` in the note base;
this file is the working layout, not the settled record.

---

## Fork A — the cost semiring's structure  (blocks the stage-3 kernel)

**Question.** What algebraic domain do the cost grades (time, space) take,
and how do they compose with usage in the product coeffect semiring?

The composition itself is determined once domains are chosen: a product
coeffect semiring, componentwise, where substituting a term used `q` times
multiplies its cost by `q` ("the spend is part of the type's weight", P2).
That is the standard graded comonad; no fork there. The fork is the **grade
domain** for a cost dimension:

- **Option A1 — constant grades: ℕ ∪ {∞}** with (+, ·). Simple, decidable,
  total. `∞` = unbounded. But it cannot say "cost is linear in the input
  size": any data-dependent function collapses to `∞`, so most real code is
  untyped-for-cost. Good enough to *state* a constant bound (the idle bound is
  structurally 0; a fixed buffer is a constant).
- **Option A2 — size-indexed / symbolic grades**: a grade is an expression
  over in-scope size variables (`3·n + 5`). Expressive enough for real bounds
  (RAML / sized-cost territory). Cost composition and entailment then need a
  decision procedure over those expressions — linear arithmetic, the *same*
  engine refinement's entailment wants. More upfront design.

**Recommendation.** Make the kernel semiring **parametric over the coeffect
semiring**, instantiate it with **A1 (ℕ∪{∞}) now**, and keep **A2 as the
promotion path sharing refinement's linear-arithmetic entailment**. This
mirrors how refinement shipped (generic arithmetic, chosen fragment): the
*shape* is fixed and foundational, the *domain* is swappable without
re-carving the trusted structure. Carve the full width of factors now —
**usage × time × space × info-flow** — even though info-flow starts as a
trivial two-point lattice ("not tracked"), because adding a factor later is
exactly the churn A was chosen to avoid.

**Commits to.** The kernel's quantity becomes a tuple over a fixed set of
coeffect factors; `qadd/qmul/qfits/uscale` generalize to the product (the
judgment logic is unchanged — only the data the arithmetic ranges over gets
richer). **Unlocks.** Stage-3 kernel term representation; the optimizer's
profitability policy (it can finally read a cost off the type); the tomodachi
idle bound as a graded type (the docs' named settling test for edge 3).

---

## Fork B — the totality mechanism  (the pregen safety license)

**Question.** Two parts, one settled and one open.
- *Policy* (settled by the docs): total by default; partiality is the marked
  climb, tracked as a modality/effect (this is also where the effect algebra
  of edge 16 lives — the partiality mark is one effect among the alarm/counter
  effects). Ratify, don't re-litigate.
- *Checker* (the fork): what algorithm establishes that a term is total
  (terminating + covering + productive), so the compiler may evaluate it at
  generation time without hanging?

- **Option B1 — structural recursion + positivity + coverage.** The standard
  minimal totality kit (Coq/Agda's core): recursion descends on a structurally
  smaller argument, datatypes are strictly positive, `case` is exhaustive.
  Conservative (rejects some total functions), no annotations for the common
  case, well-trodden.
- **Option B2 — sized types.** Types carry a size index; recursion must
  decrease it. Handles more total functions (esp. higher-order), but it is a
  type-system feature that threads through everything — a much larger
  commitment, and it interacts with the cost grades (a size index is close to
  a cost grade — they may want to share).

**Recommendation.** Ratify the policy. For the checker, **B1 now**
(positivity is already flagged missing in the scaffold; coverage exists for
`case`; structural-descent is the addition), with **B2 flagged as the
promotion path** — and note the size-index/cost-grade overlap so if B2 lands
it reuses Fork A's machinery rather than duplicating it.

**Commits to.** A totality pass beside the checker; the partiality modality in
the effects layer. **Unlocks.** Safe stage-time evaluation — the compiler can
run a static subterm iff it is total — which is the precondition for pregen
and for the design's totality-facing claims. Feeds Fork C.

---

## Fork C — the staging / binding-time modality  (the pregen engine)

**Question.** How is "known now (static) vs known later (dynamic)"
represented, and how do spawn / specialize / pregen read it? And: two-level
(compile/run) only, or multi-stage (a runtime that stages a runtime…)?

- **Option C1 — Davies–Pfenning modal staging** (`□A` = closed code of `A`,
  next-stage operators; quote/splice move between levels). The principled
  multi-level staging calculus. Composes with dependent types (modal dependent
  staging exists in the literature). Keeps binding-time OUT of the coeffect
  semiring, where it does not belong (it is a modality — *when* available — not
  a resource).
- **Option C2 — binding-time as a coeffect grade** (static/dynamic as a
  two-point lattice factor in the Fork A semiring). Lighter, unifies with cost
  machinery, but blurs the modality/coeffect distinction; less principled and
  awkward for multi-stage.
- **Sub-fork: levels.** Two-level (which `lower.py` + the native backend
  already are, implicitly: an upper level and a run level) vs multi-stage. The
  chirality process model — "run a configuration and it is itself a runtime,
  cascading" — *wants* multi-stage; `spawn` stages the next level.

**Recommendation.** **C1, multi-stage**, because it is the principled match
for process = runtime = compiler, self-similar and cascading: `spawn` stages
the next level, `specialize` (built) is cross-stage partial evaluation, pregen
is running the static level ahead of time. Scaffold path: start **two-level
with the modal operators explicit** (formalize what `lower`/native already do)
and generalize to multi-stage. Biggest of the three design-wise; do it last.

**Commits to.** A staging modality in the process/staging layer (not the
kernel semiring); explicit stage annotations. **Unlocks.** The pregen story
end to end — typed binding-time, so the compiler knows what it may precompute;
and the "one compiler, multi-staged" identity becomes literal, not aspirational.

---

## Dependency & ordering

    Fork A (semiring shape)  ──unblocks──▶  stage-3 kernel, optimizer policy
         │
         ├── info-flow factor (seat now, enforcement later → stages 7–8)
         │
    Fork B (totality)  ──feeds──▶  Fork C (only evaluate total code early)
         │
    Fork C (staging modality)  ──unblocks──▶  pregen / specialize / spawn typed

- **Blocking now:** only Fork A's *shape*. Decide it and the kernel can be
  finalized; B and C need only their *seats* reserved (a modality slot in the
  effects/staging layer, a totality-pass hook).
- **Direction now, build later:** B and C. Deciding their *direction* now
  prevents rework; their machinery lands as their stage arrives.
- **This is the payoff triangle for the stated goal** (type + precompute +
  pregen + generate on the fly): Fork A says *what you can know statically*,
  Fork B says *it is safe to run early*, Fork C is *the mechanism that runs it
  early*. All three, and only these three, are load-bearing for it.

## What I need from you

- Fork A: confirm **parametric semiring, ℕ∪{∞} now, full factor width
  (usage × time × space × info-flow) with info-flow trivial**. (Or pick A2 to
  go size-indexed from the start.)
- Fork B: confirm **B1 checker + ratify total-by-default policy**. (Or commit
  to sized types up front.)
- Fork C: confirm **C1 modal staging, two-level first → multi-stage**. (Or C2
  if you want binding-time folded into the semiring.)

Answering A unblocks building; B and C can be one-word confirmations of the
defaults or their own conversations.
