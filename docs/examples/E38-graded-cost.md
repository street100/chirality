---
element: E38
slug: graded-cost
title: Graded cost / coeffect semiring (the load-bearing decision)
kind: BUILD-PROPER
reference_class: PAPER
ours_source: (none)
status: drafted
updated: 2026-07-22
---

# E38 — Graded cost / coeffect semiring (the load-bearing decision)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.
> **Scope bound, on purpose:** this example covers ONLY the carrier-adjacency
> slice — the grade seats beside the row seat, and one composition step. The
> full cost program (grade inference, size-indexed bounds, lowering grades to
> tal) is edges 2/3 build-out, not this pre-run.

## 1. Scope

- **Element:** E38, the grade seats on the Pi carrier — QTT's usage semiring
  generalized to the frozen product `usage × time × space × info-flow`,
  composed in the *same judgment motion* that already accounts usage.
- **Kind:** BUILD-PROPER (settled decision, zero code).
- **Why chirality needs its own:** P2's central claim — "the type is the whole
  cost" — currently has no mechanism; `kernel.py` carries only 0/1/ω. The
  decision is settled (`decision-graded-kernel`: cost lives in the kernel as
  semiring *data* enrichment, not an external module), and the carrier shape
  must be pinned now so E39's row seat, E52's certificate format, and the
  eventual spec all build against the right arity once.

## 2. Research

- **Reference class:** PAPER — coeffect calculi (Petricek/Orchard), graded
  modal types; Granule is the existence proof that usage, cost, and security
  levels cohabit as grades in one product structure.
- **Key findings:**
  1. **Grades are coeffects: they scale under the binder's quantity and add
     under sequencing** — exactly the algebraic signature the kernel's usage
     accounting already implements (`uadd(uf, uscale(q, ua))` at the
     application step, `kernel.py:436`; same shape at let, `:530`). So the
     enrichment grows the *data* the arithmetic ranges over (a scalar → a
     product tuple), not the judgment logic. Same motion, wider domain.
  2. **The factor width is frozen now** (`usage × time × space × info-flow`,
     decision-graded-kernel) so adding a factor later is not a change to the
     trusted structure — the same seat-freezing move the row seat used
     (`decision-effect-facets` carrier:
     `(q, row, grades⟨…⟩, totality-mark, dom, cod)`).
  3. **What is NOT a grade:** termination (a property — the totality mark) and
     binding time (a modality — staging). Forcing either into the semiring is
     the category error the decision exists to prevent; they hold their own
     seats.
  4. **The cost domain starts ℕ∞** — constant over-approximate bounds, no
     solver — with size-indexed grades as the promotion path, *sharing the
     linear-arithmetic entailment the refinement engine (E9) already has*.
     Info-flow is a reserved trivial-lattice seat (enforcement is stage 7–8).

## 3. Conventional (other-language) approach

How cost is carried everywhere else — as prose:

```python
def sum_bytes(bs: bytes) -> int:
    """O(len(bs)). Allocates nothing."""     # a comment. nothing checks it.
    total = 0
    for b in bs:                              # or accidentally O(n^2) later —
        total += b                            # the docstring won't notice
    return total

# and the P3 parable: to every type system in this class, a catastrophic
# regex is "pure" — re.match(evil, s) types identically at 1µs and 1 hour.
```

- **Assumptions it bakes in:** cost is documentation; composition is manual
  arithmetic nobody performs; the interface says *nothing* about time or
  space, so resource exhaustion is a runtime surprise; "pure" certifies only
  the absence of I/O, never the absence of a pinned core (ReDoS) or an
  unbounded allocation. External analyzers exist precisely because the type
  refuses to carry the fact.

## 4. The chirality idea

- **Chirality features in play:** QTT quantities & the usage vector (the existing
  semiring instance), the effect row (exercise facet — the sibling seat),
  refinement entailment (shared arithmetic), totality (the license that makes
  a bound meaningful), the carrier seats of `decision-effect-facets`.
- **The reframing:** the arrow carries a grade vector beside its row, and
  **one judgment motion at application composes every seat at once**:
  usage — `uadd`/`uscale`, unchanged; row — union (E39); grades — scale by
  the binder's quantity, add across sequencing, pointwise per factor. Cost
  stops being a property *about* the program and becomes a component *of* the
  type, over-approximate by design (exact cost is undecidable — P2's stated
  limit; the bound is a ceiling, not a meter).
- **The continuation tie (the E39 law reaching cost):** a captured
  continuation's cost contribution is its **multiplicity × its body grade** —
  the same `qmul` that guards linear ports now doing cost work. A
  1-continuation adds its body once; an ω-continuation (port-free capture)
  absorbs its time factor to ∞ unless the handler's own declared bound proves
  the resume count. Zero new judgment logic; the semiring was already the
  mechanism.
- **What chirality makes impossible here:** a signature that claims cheap while
  calling expensive (grade addition fails the declared ceiling, same
  conservative shape as a refinement rejection); unbounded allocation hiding
  inside an empty-row "pure" helper (the space factor is orthogonal to the
  row); the ReDoS parable — an empty row no longer certifies harmless,
  because time is a seat of its own, which is P3's "time and space are ports"
  made checkable instead of prose.

## 5. Chirality example (fleshed)

```chirality
(import "prelude")

; PROPOSED surface for this pre-run (the annotation form is an open question,
; §6): a grade vector rides the arrow the way quantities ride binders.
; Absent annotation = neutral grades (time 0, space 0), inferred; a declared
; bound is an obligation checked at every application — a ceiling, no meter.
;
; grades⟨usage × time × space × flow⟩ — usage is the existing 0/1/w seat;
; time/space are N∞ constants at this tier; flow is a reserved seat, unused.

; A bounded pure helper: empty row, bounded spend. time 64 = one pass over a
; cell the refinement bounds below 64 bytes; space 0 = allocates nothing.
(declare sum-bytes
  (graded ((time 64) (space 0))
    (-> (refine I64 (>= 0) (< 64)) Bytes I64)))
; (def sum-bytes (lam (n bs) ...structural byte loop, elided ; …))

; Sequencing ADDS grades pointwise; the caller's ceiling must cover the sum.
; 64 + 64 + 2 glue <= 130 — checks, by the same entailment refinement uses.
(declare sum-two
  (graded ((time 130) (space 0))
    (-> Bytes Bytes I64)))
(def sum-two
  (lam (a b) (+ (sum-bytes 63 a) (sum-bytes 63 b))))

; REJECTED (illustration): declaring (time 100) on sum-two. 64+64+2 > 100 —
; conservative failure at the declaration, never a runtime meter. Exactly a
; refinement rejection's shape, on a different seat.

; The one kernel motion this slice pins, at every application (and let):
;   usage:  uadd(uf, uscale(q, ua))     — exists today, kernel.py:436
;   row:    union(row-f, row-a)         — the E39 sibling seat
;   grades: gadd(gf, gscale(q, ga))     — same two ops, product domain
; Three seats, one motion, no new judgment logic — data grew, the step didn't.

; The continuation tie: an w-bound continuation multiplies its body grade by
; w — time absorbs to ∞ unless the handler's declared bound proves the count.
; A 1-continuation (captured ports — E39's law) adds its body grade once.
```

- **Knobs to modify:** the per-factor domain (ℕ∞ now; size-indexed later);
  the ceiling values; where the annotation attaches (whole def vs per-arrow —
  matters for higher-order); which factors a profile demands ceilings on.
- **Deliberately omitted:** grade *inference* (this slice checks declared
  ceilings only); size-indexed grades (E47-adjacent promotion path);
  info-flow semantics (reserved seat); lowering grades to tal; any runtime
  metering (none exists, none is claimed); the full edges-2/3 program.

## 6. Use / modify notes

- **Lands in:** `kernel.py` — `qadd`/`qmul`/`qjoin`/`qfits` and the usage
  vector ops generalized to the product domain (data growth in the trusted
  core, seat count frozen — review as a trusted-core edit per
  `decision-effect-facets`); `terms.py` Pi carrier gains the grade seats; a
  `grades` module behind the existing seams for the entailment (sharing
  E9's interval arithmetic); a surface annotation form.
- **Conformance target:** all existing tests green with neutral grades — the
  0/1/ω kernel embeds as the usage factor with time/space at the neutral
  element, the same bit-compat story as E39's empty/nonempty row projection.
  No behavior change until a ceiling is declared.
- **Open questions:** (1) **the ω-absorption rules per factor** — what
  ω × (time 3) means (∞ on time? bounded when the consumer proves a count?)
  decides whether higher-order code gets useful bounds or collapses to ∞;
  (2) whether grade entailment reuses `refine.py`'s engine or a sibling
  module (they share linear arithmetic — one engine, two seats?); (3) the
  surface form (`graded` wrapper vs inline per-arrow annotation); (4)
  per-def vs per-arrow attachment for higher-order signatures.
- **Related:** [[E39-effect-row]] (the sibling seat; one composition motion),
  E5 (the semiring port this generalizes), [[E09-refinement]] (shared
  entailment), E47 (sized promotion path), `decision-graded-kernel` (the
  settled three-home split), `decision-effect-facets` (the carrier).
