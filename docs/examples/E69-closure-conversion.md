---
element: E69
slug: closure-conversion
title: Closure conversion + quantities-to-tal: lower closures and partial application, carry 0/1/ω to the floor (today only unrestricted closure-free arrows lower; NbE is made of closures)
kind: BUILD-PROPER
reference_class: PAPER
ours_source: (none)
status: drafted
updated: 2026-07-22
---

# E69 — Closure conversion + quantities-to-tal: lower closures and partial application, carry 0/1/ω to the floor (today only unrestricted closure-free arrows lower; NbE is made of closures)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E69, lowering higher-order code: turn every `lam` that captures
  variables (and every partial application) into first-order data + dispatch the
  existing floor already knows how to run, carrying the 0/1/ω quantities of the
  captured variables down with it.
- **Kind:** BUILD-PROPER — the lowering path today rejects closures, partial
  application, and non-unrestricted arrows outright; "closures are a later
  milestone" was prose until this element.
- **Why chirality needs its own:** the compiler's own kind of code is higher-order —
  NbE is semantically *made of* closures, the emitter and collections are
  higher-order — so self-hosting cannot go native without this. And the chirality
  twist is not optional: a closure that captures a linear port must *itself* be
  linear at the floor, or lowering erases exactly the discipline E39 enforces
  above (EDGE-CANDIDATES C3: capture visibility is a no-untyped-bottom
  question).

## 2. Research

- **Reference class:** PAPER — typed closure conversion (Minamide–Morrisett–
  Harper), flat closures (Appel), defunctionalization (Reynolds). Tier P:
  papers only, no canonical kernel read.
- **Key findings:**
  1. **Conversion is type-preserving** (MMH's whole point): the converted
     program typechecks in the target, so `preserve-check` extends across the
     pass — a broken conversion is a floor alarm, never shipped. This is the
     opposite of the conventional erase-at-lambda-lifting.
  2. **A flat closure is one record**: code pointer + the captured variables
     inline (Appel). That is exactly the scaffold's boxed-cell discipline —
     `[tag][field0]…` arena cells from milestone 2 — so closures need **no new
     runtime representation**.
  3. **The caller must not know the environment's layout.** MMH hides it behind
     an existential type — which the tal floor does not have. Reynolds'
     defunctionalization is the closed-world alternative: one constructor per
     capture site, apply = exhaustive `case` dispatch — expressible entirely in
     `data` + `case`, which already lower.
  4. **Quantities ride the capture record.** The environment is an ordinary
     record whose fields carry 0/1/ω; a record transitively holding a port is
     linear by the *existing* linear-kind rule. So the floor re-derives E39's
     continuation-quantity law structurally, with zero new machinery.

## 3. Conventional (other-language) approach

How this is done outside chirality — the exact point where types conventionally die:

```c
/* C-style closure: code pointer + void* environment. The env's layout,
   ownership, and lifetime are invisible to the type system. */
struct clo { int (*code)(void *env, int arg); void *env; };
int adder_code(void *env, int y) { return *(int *)env + y; }
/* call site: c->code(c->env, 5);  — env is untyped, capture is erased */
```

```python
# Python: capture is free, unrestricted, GC'd; a closure over a socket can be
# called twice, stored forever, or dropped — nothing tracks the capture.
send = lambda bs: sock.send(bs)
```

- **Assumptions it bakes in:** the environment is untyped (`void*` — assembly
  is where types die, the thesis's gap at the worst altitude); capture is
  unrestricted (a closure over a resource can be duplicated or leaked); no
  proof obligation on the transform (lambda lifting is trusted, not checked);
  allocation and lifetime are ambient (GC or hope).

## 4. The chirality idea

- **Chirality features in play:** QTT quantities on every binder, the linear-kind
  rule (data transitively holding a port ⇒ quantity 1), boxed `[tag][fields]`
  cells, `data`+`case` lowering (already built, including `lsb` tag dispatch),
  `preserve-check`, erasure (0-quantity).
- **The reframing:** conversion makes the invisible **structural**. Above, a
  closure's capture set is invisible in its type — soundness lives in bind-site
  usage accounting (E39's sharpening). Converting a capture site into a
  constructor whose fields *are* the capture set makes capture an ordinary
  typed record: the 1-captures make the closure value linear by the existing
  rule, the 0-captures are erased at conversion (never fields at all), and the
  converted program is first-order `data`+`case` code the current lowering
  path already handles. Partial application is the same move: capture-and-
  repack the supplied arguments into the record, dispatch supplies the rest.
- **What chirality makes impossible here:** calling a port-capturing closure twice
  (its cell is linear — the floor now *sees* why); leaking a captured resource
  (dropping the cell is dropping a linear); an untyped environment (`void*`
  cannot be written — the cell's tal type records fields and quantities); a
  conversion bug shipping (the converted body must preserve-check like any
  lowered code).

## 5. Chirality example (fleshed)

```chirality
(import "prelude")

; ---- direct style (what the programmer writes) --------------------------
(def make-adder (-> I64 (-> I64 I64))
  (lam (x) (lam (y) (+ x y))))          ; inner lam captures unrestricted x

; the E39 continuation is the linear case: a lam capturing (1 s2 Sock).
; Both lower through the SAME transform below.

; ---- what conversion emits (defunctionalized; every form already lowers) --
; One constructor PER capture site; fields ARE the capture set, with its
; quantities. 0-quantity captures are erased here — they never become fields.
(data CloI64I64 ()
  (clo-adder (x I64)))                  ; make-adder's inner lam: captures x at w

(def apply-i64-i64 (-> CloI64I64 I64 I64)
  (lam (c y)
    (case c
      ((clo-adder x) (+ x y)))))        ; dispatch = the one code body

(def make-adder-cc (-> I64 CloI64I64)   ; the converted maker: builds the record
  (lam (x) (clo-adder x)))

; partial application = capture-and-repack into the same shape:
;   (add3 7)  ==>  (apply-i64-i64 (clo-adder 3) 7)

; ---- the linear case: capture record carries the quantity ---------------
(data KontClo ()
  (clo-kont (1 s2 Sock)))               ; E39's continuation, converted
; KontClo transitively holds a port => the EXISTING linear-kind rule makes
; every KontClo value quantity-1: one call or one cancel, enforced by the
; floor's own data discipline. E39's bind-site law, re-derived structurally.
(declare apply-kont (=> (1 c KontClo) (KontMsg Bytes) Res))  ; linear binder explicit — on_binder rejects a bare (ω) binding of a linear type
; body: case on clo-kont, then the k-resume/k-cancel dispatch from E39. ; …

; At the floor: a CloI64I64 value is an ordinary [tag][fields] arena cell,
; dispatch is the existing lsb instruction, apply-* preserve-checks like any
; lowered function. NOTHING new enters tal for the defunctionalized form.
```

- **Knobs to modify:** the capture-record fields per site; per-arrow-type
  apply functions (`apply-i64-i64`, `apply-kont`, …) vs one per signature
  family; where the conversion pass sits (surface-to-surface before `lower`,
  or inside `lower.py` before tal emission).
- **Deliberately omitted:** the effect row of `apply-*` under E70 (dispatch
  merges branch rows — computed as the `row_union` of the dispatched arms'
  rows, which is BUILT and concrete; NOT the row-variable seat, which stays
  reserved for row polymorphism — a defunctionalized apply over a *closed* sum
  has a concrete union row, no polymorphism, so `row.py`'s rowvar is not its
  customer); grade seats (E38); recursion through closures (self-reference via
  the cell — needs the standard back-patch or a rec-closure ctor, decided at
  implementation).

## 6. Use / modify notes

- **Lands in:** a conversion pass in `scaffold/chirality/lower.py` (or a
  standalone `closconv.py` feeding it) — emitting the `data`/`case` forms
  above so the *existing* lowering, `emit-core`, and both machines run
  unchanged. Quantities-to-tal rides the same pass: 0-params dropped at
  conversion, 1-params recorded in the tal signature.
- **Conformance target:** every converted program is differentially equal to
  its direct-style source on the reference interpreter; every converted body
  preserve-checks; the linear cases (KontClo) are *rejected* by the checker
  when duplicated — the negative tests are the point.
- **Open questions:** **defunctionalization vs typed environments** — the
  closed-world `case` dispatch needs zero new tal formers but is whole-batch
  (anti-modular: a new capture site extends the sum), while MMH existential
  environments are modular but teach the floor a new type former; the scaffold
  is batch-compiled today, so defunctionalization is honest *now* — the call
  must be revisited when separate compilation / live linking (E57 staging)
  arrives. Also: apply-per-signature explosion management; rec-closures;
  whether the conversion is its own certificate-emitting producer under E52.
- **Open (author-tier, scope — shared with E70):** E69 and E70 are mutually
  dependent — E69 makes higher-order calls concrete so E70's footprint applies,
  and E69's `apply-*` functions are themselves effectful (they dispatch to
  crossing bodies) so their rows are E70's to lower (`row_union` over the arms).
  Neither alone takes the closure-heavy compiler native. Whether they ship as
  one deliverable or staged is the cluster co-sequencing call — the mirror of
  E70's boundary FLAG.
- **Related:** E39 (the law this makes structural), E70 (effectful lowering —
  apply's rows), E16 (the lowering path this extends), E3/E15 (NbE — the
  customer), E5 (the semiring the capture records carry), EDGE-CANDIDATES C3.
