---
element: E17
slug: optimizer
title: Optimizer: const-fold, DCE, specialize/partial-eval/pregen
kind: SELF-HOST
reference_class: PAPER
ours_source: scaffold/chirality/optimize.py
status: drafted
updated: 2026-07-12
---

# E17 — Optimizer: const-fold, DCE, specialize/partial-eval/pregen

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E17, a `tal -> tal` optimizer — constant folding, dead-code
  elimination, and `specialize` (partial evaluation binding static arguments to
  produce a residual, which *is* the pregen artifact).
- **Kind:** SELF-HOST — port `scaffold/chirality/optimize.py` (343 lines) to chirality
  source so the optimizer lives inside the language, not the host.
- **Why chirality needs its own:** shrink the TCB. The organizing discipline is that
  every pass is a `tal -> tal` transform whose output is re-run through
  `check-fn`; correctness is discharged by the *same* preserve-check that
  discharges lowering (the floor checks the invariant, the pass is never
  trusted). An optimizer bug produces ill-typed tal and is caught, never shipped.

## 2. Research

- **Reference class:** PAPER — partial evaluation, Jones–Gomard–Sestoft
  (*Partial Evaluation and Automatic Program Generation*, 1993), grounded in the
  OURS docstring's framing of `specialize` as the pregen primitive.
- **Key findings:**
  - **The mix equation.** A specializer takes a program `p` and its *static*
    inputs `s` and emits a residual `p_s` with `[[p_s]](d) = [[p]](s, d)`. In
    E17 `specialize(env, fn, bindings)` binds the statically-known arguments and
    returns a residual `fn` — a pregenerated artifact. Const-fold is the
    "reduce the static sub-computations" half of the same move.
  - **Binding-time separation.** Split each instruction into static (fully
    determined now → fold it, `_fold_prim`) vs dynamic (must remain in the
    residual). DCE then drops dynamic instructions whose results are unused
    (`_uses_in_block` / `dead`). The three passes are one binding-time story.
  - **Correctness = semantic equivalence, discharged externally.** PE is only
    valid if the residual is meaning-preserving. The paper argues this at the
    metalevel; E17 makes it *checkable*: `tal.check_fn(env, residual)` re-runs
    the floor's judgment on every pass output — the invariant is verified, not
    asserted.
  - **Futamura framing.** Specializing an interpreter wrt a program yields a
    compiled program; this is why "a residual is a pregenerated artifact" and
    why `specialize` sits next to `stage`/`pregen`/`link-and-load` in the
    staging module. **Honest boundary (from the OURS docstring):** these are
    *meaning-preserving only* — no graded-cost claim; a cost-typed account
    waits on the cost-gradient decision.

## 3. Conventional (other-language) approach

How this is done outside chirality — the existing Python (`optimize.py`).

```python
# optimize.py — passes are dict-munging transforms; the checker is a call you
# must remember to make, not a fact the type of `fold` guarantees.

def fold(fn):                       # const-fold: rewrite blocks in place
    cenv = {}                       # ambient mutable env of known constants
    for block in fn["blocks"]:
        _fold_block(block, cenv)    # mutates block["instrs"]
    return fn

def dead(fn):                       # DCE
    live = set()
    _uses_in_block(..., live)       # walk to find used defs
    for block in fn["blocks"]:
        _dead_block(block, live)    # deletes instrs whose def is unused
    return fn

def specialize(env_tal, fn, bindings, name=None):
    residual = _remap_block(...)    # partial-eval: bind static args
    tal.check_fn(env_tal, residual) # the preserve-check — but nothing forces
    return residual                 # this line to exist; forgetting it type-checks
```

- **Assumptions it bakes in:**
  - **Untyped, forgettable proof obligation.** `fold`/`dead`/`specialize` have
    type `fn -> fn`; the preserve-check is a *convention* — a call you can drop,
    reorder, or comment out and Python is just as happy. The invariant lives in
    the programmer's discipline, not the substrate.
  - **Ambient mutation.** `cenv`, `live`, and the in-place block rewrites are
    hidden state; the signature says nothing about what a pass touches, so a
    "pure" fold could silently read a file and no type would object.
  - **Partiality.** Dict/`set` walks can `KeyError`, and the recursion over
    blocks has no termination witness — a malformed tal can loop or throw
    instead of returning an explicit error.

## 4. The chirality idea

How chirality's model reframes it.

- **Chirality features in play:** the effect membrane (`->` vs `=>`), errors-as-values
  result sums, totality, and QTT-erased type params. Category **A** (typed) — a
  pass is correctness-by-proof, its output re-judged by the kernel.
- **The reframing:**
  - **A pass is a pure arrow.** `(-> TFn TFn)` is inert: it provably touches no
    ports, so an "optimization" that reads a file or reorders I/O is *untypeable*.
    The conventional freedom for a fold to peek at ambient state is gone at the
    type level.
  - **The preserve-check moves into the signature.** A pass does not return a bare
    `TFn`; it returns a `Checked` result sum — `(c-ok (v TFn))` only exists once
    `check-fn` has re-run the floor's judgment, `(c-err (msg Str))` otherwise. The
    caller must `case` on it, so the proof obligation is no longer forgettable: an
    ill-typed residual is a *value you must handle*, not a skipped call.
  - **Totality.** Block traversal is structural recursion on the block list with a
    reversed accumulator flipped once; the fold worklist decreases on a numeric
    measure. "Ran out of / malformed tal" is a returned `c-err`, never a throw or
    a hang.
  - **Erased evidence.** Type params ride as `(0 A (type 0))` — present for the
    judgment, gone at runtime, so the checking apparatus costs nothing residual.
- **What chirality makes impossible here:** shipping a mis-typed residual (the
  `c-ok` constructor cannot be formed without the passing check), and a pass that
  secretly crosses the membrane (a `->` fold cannot hold a port). The honest
  boundary stands: chirality enforces *meaning-preservation*, not a cost claim.

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
(import "prelude")
(import "tal-ir")         ; TFn, TCode, TInstr — the tal DATA (lib/tal-ir.chiral)

; check-fn (the preserve-check) and its PR result sum are the tal CHECKER — today
; Python `tal.py`, i.e. E18, NOT yet self-hosted. E17's optimizer CONSUMES them,
; so until E18 self-hosts they are forward-declared here as the coupled surface
; (Env is the tal checker's environment). Elided pass helpers declared too.
(declare Env  (type 0))              ; the tal checker's env (E18)
(data PR () (p-ok (v TFn) (extra I64)) (p-err (msg Str) (pos I64)))
(declare Cenv     (type 0))          ; constant-env for folding (elided)
(declare LiveSet  (type 0))          ; live def-set for DCE (elided)
(declare Bindings (type 0))          ; static args for specialize (elided)
(declare check-fn (-> (0 e Env) TFn PR))

; --- the check result is a value, not a convention ---------------------------
; A pass hands back a TFn only wrapped in evidence that the floor re-judged it.
(data Checked ()
  (c-ok  (v TFn))         ; residual that PASSED check-fn
  (c-err (msg Str)))      ; a pass produced ill-typed tal — caught, never shipped

; check-fn is the SAME preserve-check that discharges lowering. It is pure:
; judging tal touches no ports, so the whole optimizer is a `->` computation.
(declare re-check (-> (0 e Env) TFn Checked))
(def re-check
  (lam (e t)
    (case (check-fn e t)              ; PR from the tal checker (E18): p-ok / p-err
      ((p-ok  _   _) (c-ok  t))
      ((p-err m   _) (c-err m)))))

; --- pass 1: constant folding ------------------------------------------------
; Pure fold of instructions already determined. Structural recursion over the
; block list with a reversed accumulator flipped once; cenv is threaded, not
; ambient. `; …` elides the per-instr prim table (_fold_prim in OURS).
(declare fold-block (-> (List TInstr) Cenv (List TInstr) (List TInstr)))
(declare fold (-> TFn TFn))
(def fold
  (lam (fn)
    (the TFn
      ; walk fn's blocks, fold each with an empty constant env, reassemble
      ; …
      fn)))

; --- pass 2: dead-code elimination -------------------------------------------
; Two structural walks: collect the live def-set, then drop unused defs.
(declare uses-in (-> (List TInstr) LiveSet LiveSet))
(declare dead (-> TFn TFn))
(def dead
  (lam (fn)
    (the TFn
      ; live = fixpoint of uses-in over blocks; delete instrs whose def ∉ live
      ; …
      fn)))

; --- pass 3: specialize (partial evaluation = the pregen primitive) ----------
; Bind statically-known arguments -> residual. This is the mix equation:
;   [[residual]](d) = [[fn]](bindings, d).  Then re-check at the floor.
(declare specialize (-> (0 e Env) TFn Bindings Checked))
(def specialize
  (lam (e fn bindings)
    (let ((residual (the TFn
                      ; remap fn's params against bindings, propagate constants
                      ; …
                      fn)))
      (re-check e residual))))        ; residual is a pregenerated artifact

; --- the pipeline: fold ; dead, each output re-judged ------------------------
(declare optimize (-> (0 e Env) TFn Checked))
(def optimize
  (lam (e fn)
    (case (re-check e (dead (fold fn)))
      ((c-ok  t) (c-ok t))            ; caller MUST handle both arms
      ((c-err m) (c-err m)))))
```

- **Knobs to modify:** the prim table inside `fold-block` (which ops fold); the
  `Bindings` shape and how aggressively `specialize` propagates; swap the `List`
  block spine for a refined `(refine I64 (>= 0))` index vector if you want proven
  in-bounds block access; add a pass by composing another `(-> TFn TFn)` before the
  final `re-check`.
- **Deliberately omitted:** the `_fold_prim` opcode table, the `Cenv`/`LiveSet`
  representations, the block-remap fixpoint, and any cost/graded-usage accounting
  (the honest boundary — these transforms make no cost claim).

## 6. Use / modify notes

- **Lands in:** `scaffold/chirality/optimize.py` becomes `lib/optimize.chiral` (the
  chirality port); it links against the ported `tal` module for `check-fn`/`Env`.
- **Conformance target:** reproduce the OURS golden behavior — `fold` collapses
  determined prims, `dead` drops unused defs, `specialize(env, fn, bindings)`
  returns a residual with `[[residual]](d) = [[fn]](bindings, d)` — and, on every
  pass output, `check-fn` re-passes (the preserve-check that OURS calls at
  `optimize.py:312`/`:329`). An optimizer bug must surface as `c-err`, never as a
  shipped ill-typed tal.
- **Open questions:** does `re-check` after *each* pass or only at the pipeline
  end suffice for the floor's guarantee? What is the totality measure for the DCE
  liveness fixpoint (block count vs instr count)? The cost-gradient decision
  (edges 2/3) is still unresolved — until then `optimize` carries no graded-cost
  type, only meaning-preservation.
- **Related:** [[E17-optimizer]] · tal / `check-fn` (the floor) · the staging
  module (`stage` / `pregen` / `link-and-load`) that `specialize` sits beside ·
  E26 alarms (errors-as-values result sums) · E9 refinement engine (for the
  optional refined block-index knob).
