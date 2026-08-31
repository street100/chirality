---
element: E12
slug: effect-membrane
title: Effect membrane rules (pure -> vs process =>)
kind: SELF-HOST
reference_class: PAPER
ours_source: scaffold/chirality/effects.py
status: drafted
updated: 2026-07-22
---

# E12 — Effect membrane rules (pure `->` vs process `=>`)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.
> **Reworked 2026-07-22** to the settled two-facet model
> (`decision-effect-facets`): the one-bit membrane is the *projection* of the
> effect row, and the three judgments become set-containment over rows.

## 1. Scope

- **Element:** E12, the membrane rules — the three judgment points that decide
  whether a computation may cross (`=>`) or is inert pure compute (`->`),
  whether a value may be bound at a given QTT quantity, and what may run in an
  erased (quantity-0) position.
- **Kind:** SELF-HOST. This is one of the trusted-core modules (`terms.py` +
  `kernel.py` + `data.py` + `effects.py` + `refine.py`); reimplementing it in
  chirality shrinks the TCB from host Python to chirality itself.
- **Why chirality needs its own:** the membrane is where P3 ("govern the ports")
  is *mechanically enforced*, and it is the **exercise facet** of the settled
  two-facet model: the row records the crossings a term performs; the ports it
  holds (possession) are the other facet, joined to it by construction. As
  long as the membrane lives in CPython, the language's central safety claim
  is only as trustworthy as an untyped Python method. Self-hosting it puts the
  rule under chirality's own discipline — the checker that enforces the membrane
  is itself membrane-checked.

## 2. Research

- **Reference class:** PAPER — effect systems and graded monads. Reviewed the
  *shape* of the idea, not a specific implementation: type-and-effect systems
  (Gifford–Lucassen), effect rows (Koka / Leijen), algebraic effects & handlers
  (Frank, Eff), and graded/parameterised monads (Katsumata). Grounded against
  the chirality baseline in `scaffold/chirality/effects.py`, the surface grammar in
  `scaffold/lib/ports.chiral`, and the settled shape in
  `decision-effect-facets` (2026-07-21).
- **Key findings:**
  - **The bit is the seed of the row, not the destination.** Today's `eff`
    bool on the Pi is the empty/nonempty **projection** of the effect row —
    the record of which crossings a term performs, *inferred from the call
    graph* (`->` = empty row). Unlike Koka's declared rows, the chirality row is
    the **exercise** facet beside a **possession** facet (linear ports held),
    joined by construction once every crossing takes its capability as a
    parameter. Declared rows appear only at module/profile boundaries.
  - **Holding is not crossing.** A pure function may transport and repack
    ports without crossing them — the `RecvR` result-shape pattern is
    load-bearing pure plumbing. The row records *performance*, a call-graph
    fact; possession is a data-flow fact. Deriving one from the other was
    considered and reversed (`decision-effect-facets`, first recorded
    reversal).
  - **The core move is a wall on composition, not a monad transformer.** The
    callee's row must be contained in what the context permits, decided at
    the application site. This is `effects.py:on_apply` generalized from
    boolean implication to **set-containment**.
  - **Linearity and erasure interlock with the row.** An erased (0) position
    demands the **empty row and totality** — the bit never covered divergence
    and neither does the row; that residue is the totality gate (edge 9). A
    linear (port-holding) value must be bound at quantity 1 (`on_binder`) —
    that judgment is the possession facet's seam, unchanged by the rework.
  - **Handlers add no kernel forms.** The handler machinery rides E39's
    verified CPS elaboration (ordinary linear closures, resumption
    multiplicity = the continuation's QTT quantity); the membrane only
    *gates*. Nothing here interprets effects.

## 3. Conventional (other-language) approach

How this is done outside chirality — the existing Python membrane, plus the
mainstream effect-system framing.

```python
# scaffold/chirality/effects.py — the coarse membrane, in host Python
class Rules:
    def on_apply(self, sig, ctx, fty, allow_eff):
        q, eff = fty[1], fty[2]              # the callee's Pi: quantity, effect bit
        if eff and not allow_eff:
            raise KernelError("effectful application inside a pure function "
                              "(use => not ->)")
        self.on_binder(sig, ctx, fty[4], q, "function parameter")
        return self.erased_allow(q, allow_eff)

    def erased_allow(self, q, allow_eff):
        return allow_eff if q != 0 else False   # a 0-position is pure
```

A Koka-style system generalises the bit to a declared effect row
(`<console,exn>`) discharged by handlers; a graded monad generalises it to any
ordered monoid.

- **Assumptions it bakes in:** the Python version is **untyped and unproven** —
  `fty` is a raw tuple indexed by integer position, the effect "type" is a
  Python bool, and nothing stops a caller from constructing a `Rules` that
  lies. It trusts CPython for memory safety and totality, and it co-mingles
  the effect check and the linearity check by ambient method calls with no
  type saying they are the two facets of one membrane.

## 4. The chirality idea

- **Chirality features in play:** the effect row (exercise) and linear ports
  (possession), joined by construction; QTT quantities `0/1/w` and usage
  accounting; categories A/B/C (the membrane is the category-C crossing made
  mechanical); totality (erased positions; the rule functions themselves).
- **The reframing:** model the row as a typed value with an ordered-set
  algebra (empty / containment / union) and write the three rules as **pure,
  total chirality functions** over the row plus the QTT quantity. The membrane's
  questions become: containment at application (may these crossings happen
  here), emptiness-plus-totality at erasure, and the possession-facet
  linearity rule at binding. Because the rule functions are `->` (empty row),
  the self-hosted membrane provably performs no crossing while deciding who
  may perform crossings — the adjudicator sits on the pure side of its own
  membrane.
- **What chirality makes impossible here:** smuggling a crossing past the wall (a
  `->` context admits only empty-row callees — rejected at elaboration, not
  runtime); an effect riding in on a runtime-absent argument (erased position
  ⇒ empty row); duplicating or dropping effect authority (a port at quantity
  ≠ 1 is rejected — possession's seam); and taxing pure plumbing (threading a
  port through a result shape performs no crossing, so it stays `->`-callable
  — holding is not crossing).

## 5. Chirality example (fleshed)

The clear-cut example — the three judgments over an *abstract* row algebra.
The concrete row representation (set-of-crossing-names vs porttype-keyed) is
E39's owned decision; this example deliberately programs against the algebra
only, so it survives that choice.

```chirality
; The effect membrane as self-hosted chirality: the three judgments of effects.py,
; generalized from the one-bit lattice to set-containment over the effect row.
; The old bit survives as a projection: pure = (row-empty? r).

(import "prelude")   ; Bool, true/false, Unit

; ---- the row, abstractly ---------------------------------------------------
; Row is the exercise record: the crossings a term performs. Its representation
; is E39's call; the membrane needs only this algebra.
(declare Row (type 0))
(declare row-empty Row)                    ; the -> arrow's row
(declare row-sub (-> Row Row Bool))        ; containment: sub within super
(declare row-join (-> Row Row Row))        ; union: sequencing accumulates

; the projection that today's eff bit becomes
(def row-pure? (-> Row Bool)
  (lam (r) (row-sub r row-empty)))

; ---- rule 1: on-apply ------------------------------------------------------
; May a callee performing `callee` crossings run in a context permitting
; `here`? effects.py's boolean implication, as containment. An effectful
; application inside a pure context fails because nothing is contained in
; the empty row except the empty row.
(def on-apply-ok (-> Row Row Bool)
  (lam (here callee) (row-sub callee here)))

; ---- rule 2: erased-allow --------------------------------------------------
; A quantity-0 position is absent at runtime: whatever sits there must
; perform nothing — its permitted row collapses to empty. (The other half of
; erasure safety is totality — divergence is not in any row; that residue is
; the totality gate, edge 9. Named, not modeled here.)
(data Qtt () (q0) (q1) (qw))   ; erased / linear / unrestricted

(def erased-allow (-> Qtt Row Row)
  (lam (q here)
    (case q
      (q0 row-empty)   ; erased -> the permission collapses to no crossings
      (q1 here)
      (qw here))))

; ---- rule 3: on-binder (the possession facet's seam) -----------------------
; A linear (port-holding) type may only be bound at quantity 1. Untouched by
; the row rework: this is the OTHER facet — possession — meeting the membrane
; at one seam. `is-linear` is the kernel's structural walk (E8).
(declare Ty (type 0))               ; the term type, opaque here (E13/E3's)
(declare is-linear (-> Ty Bool))    ; supplied by the data/kind layer (E8)

(def on-binder-ok (-> Qtt Ty Bool)
  (lam (q ty)
    (case (is-linear ty)
      (false true)                  ; non-linear: any quantity is fine
      (true (case q (q1 true) (q0 false) (qw false))))))  ; linear: exactly 1

; ---- holding is not crossing, demonstrated ---------------------------------
; A function that transports a port without crossing it has row-empty: it is
; -> and callable from pure code, even though it touches a Sock value.
; (Compare RecvR unpacking in lib/ports.chiral — load-bearing pure plumbing.)
;   (def repack (-> RecvR MyShape) ...)     ; row: empty. Pure. Fine.
```

- **Knobs to modify:** instantiate `Row` per E39's representation decision;
  swap `Qtt` for the actual QTT semiring value once E5 lands; bind `is-linear`
  to the concrete E8 linear-kind decision; add the row-variable seat for
  higher-order signatures (E39's carrier reservation) when declared rows land
  at module/profile boundaries.
- **Deliberately omitted:** the row representation (E39-owned); handlers and
  effect discharge (E39's verified CPS elaboration — the membrane only gates);
  the wiring into `infer`/`check` (the kernel's E3/E4 call sites — note the
  reshape list in `banks/effect-and-alarm` §5a: conv equality → row
  subsumption is *conv's* change, not the membrane's); the actual `Ty`
  representation.

## 6. Use / modify notes

- **Lands in:** `scaffold/chirality/effects.py` replaced by a chirality module —
  provisionally `scaffold/lib/effects.chiral` (or folded into the trusted-core
  chirality kernel module once E3/E4 self-host). The `*-ok` / `erased-allow`
  functions become the chirality analogues of `Rules.on_apply`, `Rules.on_binder`,
  `Rules.erased_allow`, generalized to rows.
- **Conformance target:** every existing membrane test stays green with the
  bit read as the empty/nonempty projection of the row — (a) a nonempty-row
  call inside an empty-row (`->`) function is rejected; (b) a quantity-0
  position collapses to the empty row; (c) a linear/port type at quantity ≠ 1
  is rejected. Cross-check against `lib/ports.chiral`: accept the file as-is,
  reject a mutant binding a `Sock` at `w` or calling `sock-recv`
  (row `{sock-recv}`) from a `->` context — and *accept* a pure function that
  merely repacks a `RecvR` (row empty; holding ≠ crossing).
- **Open questions:** the row representation and row-variable surface, and
  declared-row syntax at module/profile boundaries (all E39-owned — the
  one-bit-or-row question this example used to carry is **resolved**,
  `decision-effect-facets` 2026-07-21). How the rule functions get *called*
  by a kernel that is still partly Python during bootstrap — a category-C
  bridge across the seam, or does E12 wait until E3/E4 are chirality? Where does
  `is-linear` live so the membrane and the data layer agree without a cycle?
- **Related:** [[E39-effect-row]] (the row, the reshape, the verified handler
  elaboration), [[E26-alarm-control-flow]] (alarms as crossings in this row),
  [[E13-debruijn]] (the term machinery the Pi annotations ride on), E5 (the
  quantities `erased-allow`/`on-binder` read), E8 (`is-linear`), E70 (the
  row's tal shadow — lowering this membrane to the floor).
