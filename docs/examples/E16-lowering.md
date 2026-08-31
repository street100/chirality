---
element: E16
slug: lowering
title: Lowering: pure→tal, register/slot alloc, non-tail case outlining, preserve-check
kind: SELF-HOST
reference_class: OURS/PAPER
ours_source: scaffold/chirality/lower.py
status: drafted
updated: 2026-07-12
---

# E16 — Lowering: pure→tal, register/slot alloc, non-tail case outlining, preserve-check

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E16, the lowering connector — compile an eligible upper-level
  definition down an altitude into typed assembly (`tal`): declared type → tal
  signature (`ttype`), body → tal instruction block (with register/slot alloc
  and non-tail `case` outlined into synthesized functions), then re-check.
- **Kind:** SELF-HOST — port `scaffold/chirality/lower.py` to chirality source.
- **Why chirality needs its own:** shrink the TCB. Lowering is the seam where the
  trusted upper judgment hands work to the floor; if the connector is itself
  chirality (a total `->` function whose output is *re-checked*, not trusted), the
  compiler stops being a thing you have to believe.

## 2. Research

- **Reference class:** OURS (`scaffold/chirality/lower.py`, 325 lines) + PAPER
  (SSA / register allocation, Cooper–Torczon *Engineering a Compiler*).
- **Key findings:**
  1. **Preservation is discharged at the floor, not trusted** (docstring,
     `docs/joining-law.md`). `lower_all` installs the declared type as the tal
     signature, compiles the body, then runs `tal.check_fn(env_tal, fn)` — the
     *tal checker* re-checks the compiled block against that signature. A
     lowering bug is a caught `TalError`, never shipped code.
  2. **Eligibility is a narrow, honest gate.** Only pure (`->`), non-dependent,
     unrestricted arrows over ground types (I64/Str/Bytes and data thereof)
     lower. `lower_all` rejects `effectful (crossings stay upper)` and any
     `q != W` (`quantified binder (0/1 stay upper)`). Closures, partial/higher-
     order application, and refs-to-upper each raise `Ineligible` with a reason;
     `chirality lower` reports which defs lowered and why the rest did not.
  3. **Fresh register per bind ⇒ single-assignment tal** (`Low.fresh`). The
     lowerer emits SSA-shaped tal directly (each `bind` gets a distinct
     register); real register/slot packing is deferred to a later tal optimizer
     pass, not done here.
  4. **Non-tail `case` is outlined** (`Low.expr`). A `case` in expression
     position becomes its own synthesized `TalFn` — params = the enclosing live
     registers plus the scrutinee — and the preserve-check covers each outlined
     function too (`for xfn in low.extra: tal.check_fn(...)`). Tail `case`
     branches inline (`Low.tail`).

## 3. Conventional (other-language) approach

How this is done outside chirality — the existing Python in `lower.py`.

```python
def lower_all(sig):
    env_tal = tal.TalEnv(prim_sigs(sig), data_fields(sig))
    lowered, skipped = {}, {}
    for name in sig.global_defs:
        try:
            parts, cod = _peel(sig, sig.global_types[name])
            if any(e for (q, e, d) in parts):
                raise Ineligible("effectful (crossings stay upper)")
            ptys = [ttype(sig, d) for (q, e, d) in parts]
            rty  = ttype(sig, cod)
            env_tal.fn_sigs[name] = (tuple(ptys), rty)   # install for recursion
            low = Low(sig, env_tal, name)
            fn  = low.fn(sig.global_defs[name], ptys, rty)
            tal.check_fn(env_tal, fn)                     # the preserve-check
        except (Ineligible, TalError) as e:
            skipped[name] = str(e)
    return lowered, skipped
```

- **Assumptions it bakes in:** eligibility failure is an **exception**
  (`Ineligible`) unwinding control flow, not a value in the result; the
  connector's own purity/totality is unstated (a Python function is free to do
  I/O, loop forever, or mutate `env_tal` on a failure path); the `skipped`
  reasons are plain strings, unconnected to the type that ruled the def out.

## 4. The chirality idea

How chirality's model reframes it.

- **Chirality features in play:** the effect membrane (`->` vs `=>`), QTT quantities
  (the eligibility gate *is* the QTT/effect predicate), errors-as-values result
  sums, totality, and categories A/B/C.
- **The reframing:** the lowering connector is itself a **pure, total `->`
  function** — it reads a signature and a body and returns a `TalFn` *or* a
  typed skip reason; it holds no port and cannot do I/O, so "the compiler
  quietly reached out and did something" is untypeable. Eligibility stops being
  a raised exception and becomes a `case` over an explicit result sum: the two
  outcomes (`lowered` / `skipped-with-reason`) are both in the return type.
  Crucially the connector is **Category C** — a typed transform whose *output*
  is re-validated by an independent judgment (`check-fn` at the floor), so a bug
  in the connector degrades to a caught error, never to unsound tal.
- **What chirality makes impossible here:** an effectful or linear/erased binder
  slipping into lowered code (the `->`/QTT gate rejects it *by type*); a lowering
  that "succeeds" without being re-checked (the skeleton wires `lower-def`'s ok
  branch straight through `check-fn`); and a silent non-total pass (structural
  recursion on the term, no `while`).

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
(import "prelude")   ; List, Str, I64, result-sum helpers

; --- the floor's vocabulary (tal), as ground data ---------------------------
(data TalTy ()                       ; the ground tal types a def may lower to
  (tt-i64) (tt-str) (tt-bytes)
  (tt-data (tag I64)))               ; data-of-ground, by type tag

(data Instr ()                       ; a single tal instruction (skeleton)
  (i-const (dst I64) (lit I64))
  (i-prim  (dst I64) (op Str) (args (List I64)))
  (i-call  (dst I64) (fn Str) (args (List I64)))
  (i-ret   (src I64)))

(data TalFn ()                       ; name, param tys, ret ty, block, #regs
  (talfn (name Str) (ptys (List TalTy)) (rty TalTy)
         (block (List Instr)) (nregs I64)))

; --- results are values, never thrown ---------------------------------------
(data LowRes ()                      ; lower one def: a fn, or a typed skip
  (low-ok   (fn TalFn))
  (low-skip (reason Str)))           ; "effectful" / "quantified binder" / …

; type carried down an altitude: upper type -> tal type, if it lowers at all
(declare ttype (-> (0 A (type 0)) UType (Opt TalTy)))

; eligibility gate: pure, unrestricted, non-dependent, ground.
; each (q e d) binder must have e = pure and q = W (unrestricted).
(declare eligible? (-> (List Binder) UType Bool))
(def eligible?                               ; type from the declare above
  (lam (parts cod)
    (case parts
      (nil        (ground? cod))                 ; codomain must be ground
      ((cons b r) (case b
                    ((binder q e d)
                     (case (or e (not (=i q W)))  ; effectful OR 0/1-quantified
                       (true  false)              ;   -> stays upper
                       (false (and (ground? d) (eligible? r cod))))))))))

; lower ONE def: gate, map the signature, compile the body, then PRESERVE-CHECK
(declare lower-def (-> Sig Str LowRes))
(def lower-def                               ; type from the declare above
  (lam (sig name)
    (case (peel-arrow (global-type sig name))  ; destructure the Pair via case
      ((pair parts cod)
        (case (eligible? parts cod)            ; result sum, not a raised Ineligible
          (false (low-skip (skip-reason parts cod)))  ; typed reason, not an exception
          (true
            (let ((ptys (map-tys sig parts))   ; ttype over each domain
                  (rty  (the-ty (ttype sig cod))))
              ; install sig first so recursion sees it, then hold body to it
              (let ((fn (compile-fn sig name ptys rty (global-def sig name))))
                (case (check-fn sig fn)         ; <- the preserve-check
                  ((ok _)     (low-ok fn))
                  ((err msg)  (low-skip msg))))))))))) ; a lowering bug lands HERE

; compile-fn: fresh register per bind (=> single-assignment tal); non-tail
; `case` is outlined into its own TalFn whose params are the live regs plus the
; scrutinee, appended to `extra` and preserve-checked alongside the parent.
(declare compile-fn (-> Sig Str (List TalTy) TalTy Term TalFn))
; … register alloc, tail vs expr emit, non-tail-case outlining elided (skeleton)

; lower EVERY global def; keep the fn on ok, the reason on skip
(declare lower-all (-> Sig (Pair (List TalFn) (List (Pair Str Str)))))
(def lower-all                               ; type from the declare above
  (lam (sig)
    (fold (lam (name acc)
            (case (lower-def sig name)
              ((low-ok fn)       (push-lowered acc fn))
              ((low-skip reason) (push-skipped acc name reason))))
          (empty-acc)
          (global-names sig))))   ; total: structural fold over a finite list
```

- **Knobs to modify:** the ground-type set in `TalTy` / `ground?` (add tal
  types as the floor grows); the eligibility predicate in `eligible?` (today:
  reject `e` and `q /= W`; a later phase may lower selected linear binders);
  the `Instr` set and the register-alloc strategy in `compile-fn`.
- **Deliberately omitted:** the real body walker (`compile-fn`'s tail/expr
  emit, register bookkeeping, the non-tail-`case` outlining loop) — elided with
  `; …`; `ttype`'s data-field recursion; and the `tal` checker itself (E18's
  territory — `tal.py`), consumed here only as `check-fn`.

## 6. Use / modify notes

- **Lands in:** `scaffold/chirality/lower.py` → `lib/lower.chiral` (the SELF-HOST
  port), consuming the tal checker (`check-fn`) and kernel term accessors.
- **Conformance target:** for the same `Sig`, `lower-all` reproduces the Python
  `lower_all`'s partition — identical `lowered` set and identical `skipped`
  reasons — and **every** returned `TalFn` (parents and outlined extras) passes
  `check-fn`. No eligible def is dropped; no ineligible def is lowered.
- **Open questions:** the register/slot allocation contract (pure SSA emit here,
  packing deferred — where does the packing pass live, E17 (the tal optimizer) or a new element?);
  the exact chirality surface for the outlined-function synthesis (naming `name$k`,
  threading enclosing live registers as params); whether `0`/`1`-quantified
  binders ever lower or stay permanently upper.
- **Related:** [[E18-tal-check]] (the tal checker / preserve-check judgment this
  calls — `tal.py`, NOT E15 the interpreter), [[E09-refinement]] (bounds on
  lowered I64), [[E26-alarms]] (errors-as-values).
