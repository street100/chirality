---
element: E02
slug: surface-elaborator
title: Surface elaborator (name→deBruijn, arrow/lam/case/do desugar, profile/target verify)
kind: SELF-HOST
reference_class: OURS/PAPER
ours_source: scaffold/chirality/surface.py
status: drafted
updated: 2026-07-13
---

# E02 — Surface elaborator (name→deBruijn, arrow/lam/case/do desugar, profile/target verify)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E02, the surface elaborator — lowers parsed s-expression surface
  syntax to core kernel terms: resolves names to de Bruijn indices, desugars
  `lam`/`case`/`do`/arrow forms, and verifies `(target …)` requirements.
- **Kind:** SELF-HOST.
- **Why chirality needs its own:** it is the frontend that feeds the trusted kernel,
  currently host Python (`scaffold/chirality/surface.py`). Self-hosting it shrinks the
  TCB and makes elaboration itself a *total, errors-as-values* chirality program —
  the compiler frontend is judged by the same rules as the code it lowers.

## 2. Research

- **Reference class:** OURS — `scaffold/chirality/surface.py` (583 lines; the port
  source, whose grammar docstring is the golden form list). PAPER —
  elaboration-to-core / bidirectional elaboration with de Bruijn cores
  (McBride-style locally-nameless, the "elaboration zoo" split of a named surface
  from a nameless kernel).
- **Key findings:**
  1. **Elaboration is name-erasing.** Surface carries names; core carries de
     Bruijn *indices*. The context is a stack and a variable's index is its
     depth-from-top. This keeps core alpha-canonical, so the kernel never
     compares names — it only counts binders.
  2. **Desugaring is a fold that pushes binders.** Each `lam` param, `case`
     pattern var, and `do` statement extends the context by one *before*
     recursing, so index arithmetic is purely positional and never needs
     renaming.
  3. **Both arrows survive to core.** `->` (pure) and `=>` (process) elaborate to
     the same Pi shape but carry an effect/membrane bit; purity is a typed fact
     *preserved* into the kernel term, not sugar discarded at lowering.
  4. **`(target …)` verify is a separate G9 pass.** Each `(require dname ty)` is
     elaborated and checked against the environment; the first unmet requirement
     is returned as a `p-err` value — `chirality verify` reports, never throws.

## 3. Conventional (other-language) approach

How this is done outside chirality — the existing Python (`surface.py` shape).

```python
def elab(term, ctx):                 # ctx: mutable list of names
    tag = term[0]
    if tag == 'var':
        return CVar(ctx.index(term[1]))       # ValueError if unbound
    if tag == 'lam':
        for p in term[1]:
            ctx.append(p)                      # mutate scope in place …
        body = elab(term[2], ctx)
        for _ in term[1]:
            ctx.pop()                          # … and remember to unwind it
        return CLam(body)
    if tag == 'arr':
        return CPi(elab(term[1], ctx), elab(term[2], ctx))   # arrow kind dropped
    # case / do / the …
    raise SyntaxError(f"bad form {tag}")       # partial: any miss throws
```

- **Assumptions it bakes in:** *partiality* — unbound names (`ValueError`) and
  unknown forms (`SyntaxError`) escape as exceptions, so failure lives in control
  flow, not the type. *Hidden mutation* — the scope is an in-place list you must
  remember to `pop`; a missed unwind silently corrupts every later index.
  *Untyped effects* — `->` and `=>` collapse to one `CPi`; the pure/process
  membrane is thrown away at lowering. *Stringly-typed dispatch* — no totality or
  coverage guarantee that every surface form is handled.

## 4. The chirality idea

How chirality's model reframes it.

- **Chirality features in play:** errors-as-values (the `PR` result sum instead of
  exceptions); totality (structural recursion on the closed `Surf` sum, coverage-
  checked `case`); the effect membrane (`->` vs `=>` preserved as an `eff` bit on
  the core Pi); QTT quantity carried onto each Pi binder; an *immutable* context
  (a `(List Str)` extended by `cons`, never mutated); profiles/targets (the G9
  `verify` pass).
- **The reframing:** elaboration becomes a **total, pure `->` function**
  `(List Str) -> Surf -> (PR Core)`. The naming context is an immutable stack; a
  name resolves by structural search to `p-ok ix` or `p-err`. Pushing a binder is
  `(cons nm ctx)` on the recursive call — there is nothing to unwind, because the
  outer frame still holds the un-pushed context. The two arrows are *not*
  collapsed: the process bit is data on `c-pi`.
- **What chirality makes impossible here:** an unbound name cannot silently throw or
  crash the compiler — it is a `p-err` value the caller must `case` on. You
  cannot forget to pop scope, because there is no mutation to unwind. You cannot
  lose the pure/process distinction during desugaring — it is typed data on the
  core term, not a convention. And a non-exhaustive elaborator is a coverage
  error at *its own* compile time, not a `SyntaxError` at runtime.

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
(import "prelude")            ; List, Pair, Str, Bool, Unit, I64/Str ops

; Result sum. prelude has NO PR (json.chiral's is local + monomorphic), so the
; elaborator declares its own, POLYMORPHIC so one type carries Core or an index.
(data PR ((X (type 0)))
  (p-ok  (v X)     (pos I64))
  (p-err (msg Str) (pos I64)))

; --- surface AST (parser output; E1 owns the reader, names still present) ---
(data Surf ()
  (s-var  (name Str))
  (s-app  (fn Surf) (arg Surf))
  (s-lam  (params (List Str)) (body Surf))          ; (lam (x y) body) sugar
  (s-arr  (q I64) (dom Surf) (cod Surf) (proc I64)) ; -> vs => ; proc=1 process
  (s-case (scrut Surf) (arms (List Arm)))
  (s-do   (stmts (List Surf)))                      ; Unit-effect sequencing sugar
  (s-the  (ty Surf) (e Surf)))

; --- core / kernel term (E-checker input; NAMES ARE GONE) ---
(data Core ()
  (c-bvar (ix I64))                                 ; de Bruijn INDEX, no name
  (c-app  (fn Core) (arg Core))
  (c-lam  (body Core))
  (c-pi   (q I64) (dom Core) (cod Core) (eff I64))  ; eff carries the membrane bit
  (c-case (scrut Core) (arms (List CArm))))

; case arms (PROVISIONAL shape — pinned at impl against surface.py's arm form):
; the constructor matched, how many pattern vars it binds (pushed like lam
; params before elaborating the body), and the body. Surface bodies are Surf,
; core bodies are Core. Referenced by s-case/c-case above.
(data Arm  () (arm  (ctor Str) (nvars I64) (body Surf)))
(data CArm () (carm (ctor Str) (nvars I64) (body Core)))

; name -> index: search the stack, index = depth-from-top (structural, total)
(declare ctx-find (-> (List Str) Str I64 (PR I64)))
(def ctx-find
  (lam (ctx nm d)
    (case ctx
      (nil            (p-err "unbound name" 0))
      ((cons h rest)  (case (str-eq h nm)
                        (true  (p-ok d 0))
                        (false (ctx-find rest nm (+ d 1))))))))

; the spine: elaborate one surface node under an IMMUTABLE naming context
(declare elab (-> (List Str) Surf (PR Core)))
(def elab
  (lam (ctx s)
    (case s
      ; a name resolves to its de Bruijn index, or a p-err value
      ((s-var nm)      (case (ctx-find ctx nm 0)
                         ((p-ok ix _)  (p-ok (c-bvar ix) 0))
                         ((p-err m p)  (p-err m p))))
      ; (lam (x y) b) desugars to nested c-lam; each param PUSHES a name
      ((s-lam ps b)    (elab-lam ctx ps b))
      ; -> vs => : the membrane rides on the Pi as `proc`; q is the QTT quantity
      ((s-arr q d c pr) (elab-arr ctx q d c pr))
      ; application, case, do, the — each structural, errors thread through
      ((s-app f a)     (elab-app  ctx f a))
      ((s-case sc ar)  (elab-case ctx sc ar))   ; coverage checked by the kernel
      ((s-do stmts)    (elab-do   ctx stmts))   ; desugars to linear let-seq
      ((s-the t e)     (elab-the  ctx t e)))))  ; ascription survives to core

; the per-form helpers elab dispatches to (declared here; each body is the same
; structural push-binder-then-recurse shape as elab-lam, elided for brevity):
(declare elab-app  (-> (List Str) Surf Surf (PR Core)))
(declare elab-arr  (-> (List Str) I64 Surf Surf I64 (PR Core)))
(declare elab-case (-> (List Str) Surf (List Arm) (PR Core)))
(declare elab-do   (-> (List Str) (List Surf) (PR Core)))
(declare elab-the  (-> (List Str) Surf Surf (PR Core)))

; a lambda pushes each param name, then elaborates the body one binder deeper
(declare elab-lam (-> (List Str) (List Str) Surf (PR Core)))
(def elab-lam
  (lam (ctx ps b)
    (case ps
      (nil            (elab ctx b))                   ; 0 params: just the body
      ((cons p rest)  (case (elab-lam (cons p ctx) rest b) ; push, recurse deeper
                        ((p-ok body _)  (p-ok (c-lam body) 0))
                        ((p-err m q)    (p-err m q)))))))

; profile/target verify (G9): fold the requirements, short-circuit on first fail.
; A requirement row (require dname ty) and the elaboration environment (modeled
; minimally as the elaborated globals — the real Env is the kernel signature):
(data Req () (require (dname Str) (ty Surf)))
(data Env () (env (globals (List (Pair Str Core)))))
(declare verify-target (-> Env (List Req) (PR Unit)))
; … for each (require dname ty): elab ty, check dname inhabits it in Env;
;   first miss -> p-err, all satisfied -> (p-ok unit 0)
```

- **Knobs to modify:** the `Surf`/`Core` constructor set (add `s-let`, `s-cond`,
  literals, `porttype` — the map's full `surface.py` form list is
  `arrow/lam/let/case/do/cond/the/refine`); the `eff`/`proc` encoding (a richer
  effect row instead of a bit — the coarse bit is the current pre-E39 shape);
  whether `ctx` also carries the binder *quantity* so QTT usage is checked during
  elaboration rather than deferred to the kernel; the target-requirement
  predicate in `verify-target`.
- **Deliberately omitted:** the reader/parser (E1 — `Surf` is assumed built);
  the kernel's actual type/coverage *judgment* (elab only produces the term the
  kernel checks); `import` file loading (a side-effecting `=>` pass, separate
  from this pure `elab`); refinement-predicate elaboration inside `(the …)`
  (handed to E9).

## 6. Use / modify notes

- **Lands in:** `scaffold/chirality/surface.chiral` — the self-hosted replacement for
  `scaffold/chirality/surface.py`, feeding the kernel (E-checker), which owns the
  type and coverage judgment.
- **Conformance target:** for every form in the `surface.py` grammar docstring,
  `elab` must produce the *same* core term the Python emits — identical de Bruijn
  indices, the same desugaring of `lam`/`case`/`do`, and the arrow's `eff` bit
  set iff the source used `=>`. `verify-target` must accept/reject the same
  `(target …)` declarations as `chirality verify` does today.
- **Open questions:** does desugaring (`do` → linear-let, multi-param `lam` →
  nested) stay inside `elab` or move to a pre-pass over `Surf`? How is the QTT
  quantity threaded — carried in `ctx` for usage-checking here, or fully deferred
  to the kernel? Is `import` really a separate `=>` phase, and where does its
  once-only load memoization live?
- **Related:** [[E01-reader-parser]] (produces `Surf`), the kernel/E-checker
  (consumes `Core`), [[E09-refinement-engine]] (decides `(the …)` predicates),
  [[E26-alarms]] (the `p-err` position surfaces as a source alarm).
