---
element: E04
slug: full-adt-kernel
title: The full-ADT kernel — Sig-parameterized infer/check with the globals/data/case/literals arms (rung-1 keystone)
kind: SELF-HOST
reference_class: PAPER/IMPL
ours_source: scaffold/chirality/kernel.py
status: reviewed
updated: 2026-08-03
---

# E04 (full-ADT kernel) — Sig-parameterized infer/check: the globals/data/case/literals arms

> One worked example, produced by the `worked-example` pre-run.
>
> **This is the rung-1 keystone** (`.planning/RUNG1-CRITICAL-PATH.md` item 2). The
> ported chirality kernel (E3/E4) is the CLOSED CORE only; this extends it with the
> arms it deferred so it can check REAL programs. Co-designed with item 1 (the full
> `Sig`) — the `Sig` holds the bodies this checks, and this resolves globals in the
> `Sig`; neither is buildable without the other.

## 1. Scope

- **Element:** extend the trusted chirality kernel judgment (`lib/kernel.chiral`
  `infer`/`check`, E3/E4) from the closed λ-core to the **full ADT language**: add
  a **`Sig` parameter** (globals + prim/extern types + data decls) and the
  **`t-global` / `t-prim` / `t-lit` / `t-con` / `t-tcon` / `t-case`** infer/check
  arms — the exact arms `lib/kernel.chiral:14` names as deferred ("globals/prims,
  data values, let, literals -> E6/full-ADT assembly").
- **Kind:** SELF-HOST — `kernel.py` `infer`/`check` → chirality. Trusted-core.
- **Why chirality needs it:** the ported kernel `Term` cannot even *represent* a
  global or a `case`, so it cannot check any real def (every def body is
  global-and-data-heavy). No full-ADT kernel ⇒ nothing checks the chirality compiler's
  own source ⇒ no rung-1 self-check. Everything downstream (the loader, req #2's
  install-validation, the fixpoint) is gated on this.

## 2. Research

- **Reference class:** OURS — `kernel.py` `infer` (:400) / `check`, the
  Sig-parameterized bidirectional judgment. PAPER — Dunfield–Krishnaswami
  bidirectional typing; the ADT/`case` rules are standard (ATTAPL).
- **Key findings (load-bearing):**
  1. **The judgment is Sig-parameterized; the ported chirality one is not.**
     `infer(sig, ctx, t, allow_eff)` looks globals up in `sig.global_types` (:411),
     prims in `sig.prim_types` (:417). The chirality `infer : (-> Ctx Term TcR)` must
     become `(-> Sig Ctx Term TcR)` (item 1 supplies the `Sig`).
  2. **The `Term`/`Value` ADT must extend.** `kernel.py` has `Global`/`Prim`/`Lit`/
     `Con`/`TCon`/`Case`; the chirality `Term` (`t-var/t-type/t-pi/t-lam/t-app/t-let/
     t-ann`) has none. Add `t-global`/`t-prim`/`t-lit`/`t-con`/`t-tcon`/`t-case` +
     the matching `Value` forms (`v-con`/`v-tcon`/neutral global/prim heads — the
     `quote` arms at kernel.py:376-387 show the shape).
  3. **Con/TCon/Case REUSE the ported data checks — do not reinvent.** A `t-con`'s
     field types come from the data decl (E6 `_infer_ctor_params`, ported in
     `data.chiral`); a `t-case` demands coverage (E6 `check-coverage`, ported) and
     checks each arm under the ctor's field binders. The full-ADT kernel *calls*
     `data.chiral` (kernel + data co-load clean — verified), it does not duplicate
     positivity/coverage.
  4. **This forces the `Core` unification (the dedup debt's core).** The kernel
     `Term`, surface `Core`, and lower `Core` are three de-Bruijn ADTs; the loader
     must produce ONE the kernel consumes. Settle it here (item 1).

## 3. Conventional (other-language) approach

`kernel.py` — a Sig-parameterized dispatch with mutable-dict global resolution:

```python
def infer(sig, ctx, t, allow_eff):
    k = t[0]
    if k == "Var":    return ctx[t[1]]
    if k == "Global": return sig.global_types[t[1]]          # dict lookup
    if k == "Prim":   return sig.prim_types[t[1]]
    if k == "Lit":    return _lit_type(t)                    # I64 / Str
    if k == "App":    ...                                    # infer f, check arg
    # Con/TCon: field types from the data decl; Case: coverage + per-arm check
```

- **Assumptions it bakes in:** the signature is a mutable ambient dict resolved by
  name; globals are trusted present (a `KeyError` on a missing one, not a typed
  rejection); no proof obligation that the resolution is total.

## 4. The chirality idea

- **Chirality features in play:** the trusted-core judgment (errors-as-values, no
  exceptions); an **immutable `Sig` threaded** (not a mutated dict); composition
  over reinvention (the E6/E7 data checks plug into the `case`/`con` arms); one
  unified `Core` (the loader→kernel representation).
- **The reframing:** the `Sig` is a value passed *down* the judgment. A global
  resolves by **structural lookup** returning a `TcR` (`t-err "unknown global g"`
  on miss — a typed rejection, never a crash). A `case` is checked by handing the
  scrutinee's data decl to the ported `check-coverage` and typing each arm under
  the ctor's field binders (via the ported `_infer_ctor_params`). The judgment
  stays bidirectional; only its alphabet grows.
- **What chirality makes impossible here:** an unresolved global that silently
  type-checks (the lookup is total, its failure a value); a non-exhaustive `case`
  reaching the floor (coverage is a judgment obligation, E6); an unchecked
  constructor application (field arities/types checked against the decl).

## 5. Chirality example (fleshed)

```chirality
; ---- item 1: the full Sig (the loader writes it, every judgment reads it) -----
(data Sig ()
  (sig (globals (List (Pair Str (Pair Term Term))))   ; name -> (type, body)
       (prims   (List (Pair Str Term)))               ; extern name -> type
       (datas   (List DataDecl))))                    ; the data.chiral decl form

; ---- the extended Term (E3/E4's core + the deferred full-ADT arms) -----------
;   t-global / t-prim / t-lit / t-con / t-tcon / t-case  (added to the E3 Term)

; ---- the judgment gains a Sig parameter --------------------------------------
(declare infer (-> Sig Ctx Term TcR))
(declare check (-> Sig Ctx Term Value CkR))

; ---- the new arms (skeleton; the core arms are E3/E4, unchanged but Sig-threaded)
(def infer-arm (lam (sg c t)
  (case t
    ((t-global n)  (case (sig-global-ty sg n)              ; structural lookup
                     (none      (t-err (str-cat "unknown global " n)))
                     ((some ty) (t-ok (eval-ty sg ty)))))   ; its declared type
    ((t-prim n)    (case (sig-prim-ty sg n)
                     (none (t-err (str-cat "unknown prim " n))) ((some ty) (t-ok (eval-ty sg ty)))))
    ((t-lit l)     (t-ok (lit-type l)))                    ; I64 / Str
    ((t-con dn cn args)                                    ; a data constructor
       (case (ctor-field-tys sg dn cn)                     ; REUSE E6 _infer_ctor_params
         (none (t-err "unknown ctor"))
         ((some ftys) (check-args sg c args ftys (v-tcon dn nil)))))
    ((t-case scrut arms dflt)                              ; the case rule
       (case (infer sg c scrut)
         ((t-err e) (t-err e))
         ((t-ok sty) (case (data-of sty)
            (none (t-err "case on non-data"))
            ((some dd) (case (check-coverage dd (arm-ctors arms) dflt)  ; REUSE E6
               ((cov-missing ms) (t-err (str-cat "non-exhaustive: " ms)))
               ((cov-ok) (check-arms sg c dd arms))))))) ; each arm under its binders
    (_ (infer-core sg c t)))))                            ; Var/Type/Pi/Lam/App/Let/Ann = E3/E4
; ... check-args / check-arms / arm-ctors / data-of elided ; …
```

- **Knobs to modify:** the `Sig` shape (item 1 — what the loader carries); which
  `Core`/`Term` becomes the unified one; the literal types.
- **Deliberately omitted:** the loader that BUILDS the `Sig` (item 3 / req #2 —
  install-* over this `Sig`); effect-row checking in the arms (E12/E39, the row
  layer already built, threaded via `allow_eff`→`allow_row`); universe
  cumulativity details (E4 core, unchanged).

## 6. Use / modify notes

- **Lands in:** `lib/kernel.chiral` — extend E3's `Term`/`Value` + E4's
  `infer`/`check` with the arms above and the `Sig` parameter; a new `Sig` (item
  1) co-lands. `data.chiral` is imported (co-loads clean) for the ctor/coverage
  reuse. **Trusted-core diff — show it explicitly (standing discipline).**
- **Conformance target:** differential vs `kernel.py` `infer`/`check` over a
  corpus that exercises every new arm — a global reference, a prim, an I64/Str
  literal, a constructor application (right + wrong arity), a `case` (exhaustive →
  ok, missing-arm → rejected), nested case — accept/reject + inferred type
  matching the oracle, over a REAL loaded `Sig`.
- **Decided (2026-08-03, decide-and-check — overridable):**
  - **The `Core` unification → EXTEND the kernel `Term` in place now; defer the
    full three-way unification.** Add `t-global`/`t-prim`/`t-lit`/`t-con`/
    `t-tcon`/`t-case` to `lib/kernel.chiral`'s `Term`; the loader bridges surface
    `Core` → this extended `Term` at install. Rationale: unblocks the trusted-core
    build without an up-front refactor of surface/lower/closconv (each tested,
    ripples); matches `kernel.py`'s single-Term shape; the unification (the risky
    dedup) is deferrable to when it's forced. NB: adding `Term` ctors ripples to
    `eval`/`quote`/`conv` — each needs its new arm; keep the E3/E4 differentials
    green (trusted-core diff shown explicitly).
- **Open questions (for the spec):**
  - **The E6/E7 bridge** — the ported data checks work over `data.chiral`'s `Ty`/
    `DataDecl`; the kernel works over `Term`/`Value`. How does the `case` arm hand
    a scrutinee's data decl across that representation seam (a `Ty`↔`Term` bridge,
    or unify)?
  - **The `Sig` shape (item 1)** — exactly what fields, and does it subsume/extend
    E69's `SigV` + the sig-driver's `EffSig` (which already carry def_rows/ports)?
- **Related:** [[RUNG1-CRITICAL-PATH]] (item 2, this; item 1 the `Sig`; item 3 the
  loader), [[E3]] (the core `Term`/NbE this extends), [[E6]] (the ctor/coverage
  checks the `con`/`case` arms reuse), [[E2-row-inference]] (a sibling sig-driver
  slice), [[E69-sig-mutation]] (the install that writes this `Sig`).
