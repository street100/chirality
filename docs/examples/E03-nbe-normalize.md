---
element: E03
slug: nbe-normalize
title: NbE: eval / quote / conv (+ eta)
kind: SELF-HOST
reference_class: PAPER/IMPL
ours_source: scaffold/chirality/kernel.py
status: drafted
updated: 2026-07-13
---

# E03 — NbE: eval / quote / conv (+ eta)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E03, the normalization-by-evaluation engine — `eval_term` (syntax →
  semantic values with closures), `vapp` (semantic application), `quote` (reify a
  value back to a term), and `conv` (decide definitional equality up to eta).
- **Kind:** SELF-HOST — this is `kernel.py`'s `eval_term`/`vapp`/`quote`/`conv`
  ported to chirality-in-chirality.
- **Why chirality needs its own:** NbE is the beating heart of the trusted core —
  conversion checking is what every typing rule calls, so it is the single
  highest-leverage self-host target. Both E4 (bidirectional infer/check) and E5
  (QTT usage) sit on top of `conv`; shrinking the TCB starts here.

## 2. Research

- **Reference class:** PAPER — Abel & Coquand, *Checking Dependent Types with
  Normalization by Evaluation*; IMPL — Agda's `TypeChecking.Conversion` and
  pi-forall's `Equal.hs`. Grounded in the OURS `kernel.py` docstring ("QTT only:
  dependent Pi with quantities 0/1/w, universe levels with cumulativity, NbE
  conversion").
- **Key findings:**
  1. **Closures defer substitution.** `eval` never substitutes into a term; a
     `Lam`/`Pi` body becomes a *closure* `(env, body)`, and application resumes
     `eval` under `env + [arg]`. This is what makes NbE cheap and capture-free.
  2. **Levels vs indices, readback move.** Bodies are stored with de-Bruijn
     *indices* but `quote` walks a fresh *level* `lvl` down each binder and, at a
     neutral variable head `NVar k`, emits index `lvl - 1 - k`. That single
     arithmetic converts level→index with no renaming (OURS `quote`).
  3. **Neutrals keep eval total on open terms.** A stuck variable becomes
     `VNe(head, spine)`; `vapp` on a neutral just extends the spine. So `eval`
     terminates on open terms and `conv` can compare spines structurally.
  4. **Eta is checked before head comparison.** If *either* side is a `VLam`,
     apply both to one fresh neutral and recurse (OURS `conv` first branch) — no
     need to fully normalize both sides first. chirality additionally compares the
     **quantity and the effect arrow** stored on `VPi` (OURS: `a[1]!=b[1] or
     a[2]!=b[2]` ⇒ "quantity and effect are part of the type"), so definitional
     equality is strictly finer than in Agda/pi-forall.

## 3. Conventional (other-language) approach

The OURS `kernel.py`: tuple-tagged values, dispatched on `v[0]`, faults raised
mid-evaluation.

```python
def eval_term(sig, env, t):
    k = t[0]
    if k == "Var":
        i = t[1]
        if not 0 <= i < len(env):            # manual guard against index wrap
            raise KernelError(f"Var index {i} out of range ...")
        return env[len(env) - 1 - i]
    if k == "Lam":
        return ("VLam", t[1], (env, t[2]))   # closure = (env, body); no subst
    if k == "App":
        return vapp(sig, eval_term(sig, env, t[1]), eval_term(sig, env, t[2]))
    # … Type / PrimTy / Lit / Pi / Let

def vapp(sig, f, a):
    if f[0] == "VLam":
        env, body = f[2]
        return eval_term(sig, env + [a], body)
    if f[0] == "VNe":
        return ("VNe", f[1], f[2] + [a])     # extend the spine
    raise KernelError(f"cannot apply {f[0]}")
```

- **Assumptions it bakes in:** partiality via exceptions (a bad index or a
  non-function `App` raises `KernelError` from deep inside eval); untyped
  positional tuples (`v[0]` string tags, `t[4]`/`t[5]` field access — no
  exhaustiveness, a missing tag just falls through to `None`); the negative-index
  wrap footgun that the `0 <= i < len(env)` guard exists only to paper over; and
  no totality guarantee — nothing stops eval from diverging.

## 4. The chirality idea

- **Chirality features in play:** closed `data` sums + coverage-checked `case`
  (categories: A, typed); QTT quantities on the `Pi` binder; the `->` vs `=>`
  effect membrane as part of a type's identity; totality; the I64 floor.
- **The reframing:** `Term` and `Value` become closed sums, so tag dispatch is a
  coverage-checked `case` — the "missing tag falls through to `None`" class of
  bug is structurally gone. The out-of-range `Var` guard stops being a runtime
  `raise`: well-scopedness (`0 <= i < depth`) is a **precondition discharged by
  the checker (E4)** before `eval` ever runs, so `lookup` is total over its
  checked domain. Every arrow is `->` **pure**: NbE provably touches no port, so
  the trusted core cannot smuggle I/O into a "just normalizing" pass. Levels,
  indices, and quantities are all `I64` — no floats anywhere near the kernel.
  Crucially, `conv` compares the `VPi` **quantity `q` and arrow `eff`**, so two
  function types that differ only in `->` vs `=>` (or in `0` vs `1` usage) are
  *not* convertible — the membrane is baked into definitional equality.
- **What chirality makes impossible here:** an `eval` that silently returns the wrong
  binding via negative-index wrap; a non-exhaustive value dispatch; and an NbE
  pass that performs a side effect — all three are ruled out by the substrate,
  not by reviewer vigilance.

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
(import "prelude")

; ---- syntax: de-Bruijn terms (indices count outward from the use site) ----
(data Arr () (pure) (proc))              ; the membrane: -> vs =>
(data Term ()
  (t-var  (i I64))                       ; de-Bruijn index
  (t-type (n I64))                       ; universe level
  (t-pi   (q I64) (eff Arr) (dom Term) (cod Term))   ; QTT + effect on the binder
  (t-lam  (body Term))
  (t-app  (f Term) (a Term))
  (t-let  (v Term) (body Term)))

; ---- semantics: values, closures, neutrals (Value/Clos/Neut are mutual) ----
(data Value ()
  (v-type (n I64))
  (v-pi   (q I64) (eff Arr) (dom Value) (cod Clos))
  (v-lam  (body Clos))
  (v-ne   (head Neut) (spine (List Value))))     ; stuck head + arg spine
(data Clos () (clos (env (List Value)) (body Term)))   ; deferred substitution
(data Neut () (n-var (lvl I64)))

; a fresh neutral variable at binding depth `lvl`
(declare fresh (-> I64 Value))
(def fresh (lam (lvl) (v-ne (n-var lvl) nil)))

; The eval/quote/conv functions are one mutual-recursion group (eval-term<->vapp
; <->clos-apply; quote-val<->quote-neut; conv<->conv-struct), so ALL are
; forward-declared here before any def. Elided helpers (mechanical spines) too.
(declare eval-term   (-> (List Value) Term Value))
(declare vapp        (-> Value Value Value))
(declare clos-apply  (-> Clos Value Value))
(declare conv        (-> I64 Value Value Bool))
(declare conv-struct (-> I64 Value Value Bool))
(declare quote-val   (-> I64 Value Term))
(declare quote-neut  (-> I64 Neut (List Value) Term))
(declare normalize   (-> Term Term))
(declare nth         (-> (List Value) I64 Value))   ; precondition-total lookup (see below)
(declare snoc        (-> (List Value) Value (List Value)))
(declare stuck       Value)                          ; the unreachable placeholder value
(declare is-lam      (-> Value Bool))
(declare app-either  (-> Value Value Value))
(declare arr=        (-> Arr Arr Bool))
(declare conv-neut   (-> I64 Neut (List Value) Value Bool))
(declare spine->apps (-> Term I64 (List Value) Term))

; ---- eval: syntax -> value; NEVER substitutes, builds closures instead ----
; PRECONDITION (discharged by E4): every t-var i satisfies 0 <= i < (len env),
; so `nth` is total here — no runtime range guard, unlike the OURS `raise`.
(def eval-term
  (lam (env t)
    (case t
      ((t-var i)       (nth env i))
      ((t-type n)      (v-type n))
      ((t-pi q e d c)  (v-pi q e (eval-term env d) (clos env c)))
      ((t-lam b)       (v-lam (clos env b)))
      ((t-app f a)     (vapp (eval-term env f) (eval-term env a)))
      ((t-let v b)     (eval-term (cons (eval-term env v) env) b)))))

; ---- vapp: semantic application. exhaustive by coverage; the non-function
;      heads are unreachable on checked terms but must still be written. ----
(def vapp
  (lam (f a)
    (case f
      ((v-lam c)      (clos-apply c a))
      ((v-ne h sp)    (v-ne h (snoc sp a)))        ; extend the spine
      ((v-type _)     stuck)                        ; unreachable: checker proved
      ((v-pi _ _ _ _) stuck))))                     ;   f : Pi before we get here

(def clos-apply
  (lam (c v) (case c ((clos env body) (eval-term (cons v env) body)))))

; ---- conv: decide definitional equality, eta FIRST, then head compare ----
(def conv
  (lam (lvl a b)
    (case (or (is-lam a) (is-lam b))
      ; eta: apply both to one fresh var, recurse one level deeper
      (true
        (let ((x (fresh lvl)))
          (conv (+ lvl 1) (app-either a x) (app-either b x))))
      (false (conv-struct lvl a b)))))

(def conv-struct
  (lam (lvl a b)
    (case a
      ((v-type n)     (case b ((v-type m) (=i n m)) (_ false)))
      ((v-pi q e d c) (case b
                        ((v-pi q2 e2 d2 c2)
                          (and (=i q q2)                 ; quantity is part of =
                            (and (arr= e e2)             ; arrow is part of =
                              (and (conv lvl d d2)
                                (conv (+ lvl 1)
                                      (clos-apply c  (fresh lvl))
                                      (clos-apply c2 (fresh lvl)))))))
                        (_ false)))
      ((v-ne h sp)    (conv-neut lvl h sp b))            ; compare stuck spines
      ((v-lam c)      false))))                          ; unreachable (eta branch handles lams) but must be written for coverage

; ---- quote: reify a value back to a term (level -> index via lvl-1-k) ----
(def quote-val
  (lam (lvl v)
    (case v
      ((v-type n)     (t-type n))
      ((v-pi q e d c) (t-pi q e (quote-val lvl d)
                            (quote-val (+ lvl 1) (clos-apply c (fresh lvl)))))
      ((v-lam c)      (t-lam (quote-val (+ lvl 1) (clos-apply c (fresh lvl)))))
      ((v-ne h sp)    (quote-neut lvl h sp)))))

(def quote-neut
  (lam (lvl h sp)
    (case h
      ((n-var k) (spine->apps (t-var (- (- lvl 1) k)) lvl sp)))))   ; lvl-1-k
      ; spine->apps folds t-app over (map (quote-val lvl) sp) ; …

; normalize = read back the value of a term at depth 0
(def normalize (lam (t) (quote-val 0 (eval-term nil t))))
```

- **Knobs to modify:** the `Arr`/quantity fields on `t-pi`/`v-pi` (drop them for a
  plain-STLC NbE, or extend `Arr` with a concrete effect row for E4); whether
  `conv` is up-to-eta only or also up-to universe cumulativity (add a `<=` on the
  `v-type` levels); the neutral head set (`n-var` only here — add `n-global` for
  top-level defs and `n-const` for data eliminators).
- **Deliberately omitted:** `v-tcon`/`v-con` (data-value quoting — the `data.py`
  seam, its own element), literal/`PrimTy` cases, cumulative subtyping in
  `conv-struct`, and the mechanical `spine->apps` fold (elided with `; …`).

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/kernel.chiral` — the `eval-term` / `vapp` /
  `quote-val` / `conv` block, replacing the corresponding `kernel.py` functions
  (`lib/` is where RT-run chirality source lives; `chirality/` is Python only).
- **Conformance target:** for every well-typed closed term, `normalize` must
  produce the same term the OURS `quote(sig, 0, eval_term(sig, [], t))` produces
  (alpha-eta-equal), and `conv lvl a b` must agree with OURS `conv` on all pairs —
  including rejecting two `Pi`s that differ only in quantity or `->`/`=>` arrow.
- **Open questions:** **totality.** `eval-term` (beta on `t-app`) and `conv`
  (eta grows `lvl`) are *not* structurally decreasing, so chirality's default
  structural-recursion totality checker cannot pass them — NbE termination rests
  on the semantic strong-normalization argument over *well-typed* terms. This
  needs a totality seam (a measure/assumption tied to the well-typedness
  precondition), not a naive structural measure. Also: whether `nth` stays a
  precondition-guarded total helper or returns a result sum (the "errors are
  values" default) — settle once E4 fixes what "well-scoped" guarantees.
- **Related:** [[E04-bidirectional]] (its checker calls `conv`), [[E05-qtt-usage]]
  (usage checking runs alongside the same `Pi` binders), [[E03-nbe-normalize]].
