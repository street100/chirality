---
element: E15
slug: reference-interpreter
title: Reference interpreter (golden semantics, tree-walk + TCO)
kind: SELF-HOST
reference_class: OURS
ours_source: scaffold/chirality/runtime.py
status: drafted
updated: 2026-07-12
---

# E15 — Reference interpreter (golden semantics, tree-walk + TCO)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E15, the strict tree-walking evaluator over checked kernel terms
  (`runtime.py`'s `RT.run` / `RT.apply1`) — the *golden semantics*: the
  definitional interpreter that says what a chirality program means, with tail-call
  iteration so long-running event loops do not grow the host stack.
- **Kind:** SELF-HOST — it is host Python (`runtime.py`, 181 lines) that defines
  the runtime meaning of every program; it must become chirality source so the
  reference for "what a program does" is itself written in the checked language.
- **Why chirality needs its own:** this evaluator *is* the operational spec every
  lowering (E16) and the tal interpreter (E18) must preserve. While it lives in
  host Python it is an unchecked authority — a `t[0]` string-tag dispatch with
  raise-on-fallthrough and hand-rolled stack management sitting at the semantic
  root of the whole compiler. Self-hosting it makes the golden semantics a
  coverage-checked, membrane-typed chirality process, so "the meaning of a program"
  stops being asserted by convention in Python.

## 2. Research

- **Reference class:** `OURS` — `scaffold/chirality/runtime.py` (whole file; 181 lines,
  the baseline). The `PAPER` side is the standard **definitional interpreter**
  (Reynolds): meaning given by a structural evaluator over the AST, with an
  environment for variables and closures for functions — plus the well-known
  **trampoline / tail-call-iteration** move to keep it constant-stack. The file
  already implements exactly this, so no external transcription is needed.
- **Key findings:**
  1. `RT.run(t, env)` is a **hand-written trampoline**: a `while True` loop that
     *returns* for leaf/value nodes (`Var`, `Lit`, `Lam`, `Con`) but **reassigns
     `(env, t)` and `continue`s** for `Let`, `Case`, `Ann`, and the last call of
     an `App` spine — so tail position iterates instead of recursing.
  2. `apply1(f, a)` encodes the tail-call handshake as a **two-shape return**:
     `(value, None)` for a finished application (extern/`talf`/`pap`), or
     `(None, (env, body))` for a closure call the caller runs *in tail position*.
     The `App` case unwinds the spine so only the final call becomes a `tail_jump`.
  3. **QTT erasure is represented by a sentinel:** a `Let` with quantity `0`
     binds `("erased",)` into the env (`if t[1] == 0:`), and the evaluator must
     remember never to force it. Erasure is a runtime convention here, not a
     structural absence.
  4. The extern/port face is a **category-C bridge crossing done by hand**: `pap`
     application calls `IMPLS[name](*args)` then `bridge.verify(sig, name, v, rty)`
     — the untyped host referent's return is re-checked against its declared type
     inline, in the middle of the eval loop.

## 3. Conventional (other-language) approach

The host evaluator (`runtime.py`) — one `RT.run` method, a `while True` loop
dispatching on a string tag pulled out of a positional tuple, with a companion
`apply1` whose return *shape* signals whether the caller may tail-iterate.

```python
def run(self, t, env):
    while True:
        k = t[0]                                   # (a) tag = tuple[0], untyped union
        if k == "Var":   return env[len(env) - 1 - t[1]]
        if k == "Lam":   return ("clo", env, t[1], t[2])
        if k == "Let":
            if t[1] == 0:  env = env + [("erased",)]        # (b) erasure as a sentinel value
            else:          env = env + [self.run(t[3], env)]
            t = t[4]; continue                              # (c) tail into body, no recursion
        if k == "App":
            spine = []; f = t
            while f[0] == "App": spine.append(f[2]); f = f[1]
            spine.reverse()
            fv = self.run(f, env); tail_jump = None
            for i, arg_t in enumerate(spine):
                av = self.run(arg_t, env)
                result, tail = self.apply1(fv, av)          # (d) (value,None) | (None,(env,body))
                if tail is None:                 fv = result
                elif i == len(spine) - 1:        tail_jump = tail   # last call: iterate
                else:                            fv = self.run(tail[1], tail[0])
            if tail_jump is None: return fv
            env, t = tail_jump; continue                    # (e) the trampoline hop
        # ... Con, Case, Global, Prim, Ann, Type/Pi/... ...
        raise RuntimeErrorChirality(f"run: bad term {k}")       # (f) raise-on-fallthrough
```

- **Assumptions it bakes in:**
  - **Untyped tuple union + raise fallthrough.** `t` is `("Var", i) | ("Lam", …)
    | …` and runtime values are `("clo", …) | ("con", …) | ("pap", …) | ("erased",)`;
    an unhandled tag `raise`s at runtime instead of being ruled out. Coverage over
    both the term sum and the value sum is a convention, not a checked property.
  - **TCO is a manual stack-management trick.** Proper tail calls exist only
    because the author threaded `(env, t)` back into the loop and split `apply1`'s
    return into two shapes. Get the spine unwind or the `i == len-1` guard wrong
    and you silently reintroduce host-stack growth.
  - **Erasure is a value you must not touch.** `("erased",)` is a live env entry;
    nothing structurally prevents forcing it — the checker "holds them pure" out
    of band.
  - **The pure/effectful split is smeared.** One method both pattern-matches inert
    nodes *and* crosses ports (`IMPLS[name](*args)`, `bridge.verify`, tal calls).
    Nothing in the type says which term shapes can touch the world.
  - **Partiality is ambient.** The loop may never terminate (it is *meant* to run
    event loops), but that is nowhere in a type — it is just what a `while True`
    does.

## 4. The chirality idea

chirality makes the golden semantics a **membrane-split** pair — a pure, total,
coverage-checked step function `->` and a `=>` driver that owns exactly the two
things that touch the membrane (divergence and, in the full version, ports) — and
turns the hand-rolled trampoline into an ordinary tail-recursive function plus a
closed `data Step` the `case` must cover.

- **Chirality features in play:**
  - **Effect membrane `->` vs `=>` (E12, P4).** The pure *fragment* is the **term
    language** the evaluator walks (`Var`/`Lit`/`Lam`/`App`-of-closure/`Case`/`Let`
    cross no I/O port). The **evaluator over it is `=>`**, though: `eval-step`,
    `eval`, and `run` are one mutual-recursion group (the big-step evaluator forces
    subterms), they may not terminate — and P4 says non-termination *is* a port
    ("non-termination and unbounded allocation are ports") — and `run` exits the
    `step-stuck` case through the `rt-alarm` crossing. So the honest arrow on all
    three is `=>`. A genuinely-pure `->` **single-step** — one that returns a
    continuation for *every* subterm instead of forcing it, leaving divergence to
    the driver alone — is the sharper membrane split, recorded as a Knob; the
    big-step form here trades that for directness. Either way chirality stops
    runtime.py from *smearing* the membrane: the crossings (`rt-alarm`, the
    deferred extern face) are named `=>`, never hidden inside a "pure" method.
  - **Closed sums + exhaustive `case` (E6 coverage).** The `t[0]` tag union
    becomes `data Term`; the `("clo",…)|("con",…)|…` value union becomes
    `data Value`; the `(value,None)|(None,(env,body))` return becomes `data Step`.
    Forgetting a term shape, a value shape, or the tail case is a compile error,
    not a `raise`.
  - **TCO as guaranteed tail calls, not a trick.** The Python `while True` +
    `env, t = tail_jump` becomes `run` *tail-calling itself* on the next `Step`.
    Because the recursive call is in tail position, chirality's proper-tail-call
    guarantee makes it a constant-stack loop by construction — the spine-unwind,
    the `tail_jump` variable, and the `i == len-1` guard all evaporate. This is
    exactly `fsm.chiral`'s `Step`/`drive` shape (`step-go` vs `step-halt`), reused
    as an evaluator trampoline.
  - **QTT erasure is structural (E5), not a sentinel.** A 0-quantity `Let` does
    not exist at runtime; there is no `("erased",)` in `Value`, so there is
    nothing to force by mistake. Erasure is enforced by the quantity, upstream.
  - **Totality-by-default, partiality as the marked case (E11, P5).** Each *body*
    recurses structurally on `Term`, but `eval-step`/`eval`/`run` form a mutual
    group whose loop (`run` → `eval-step` → `eval` → `run`) is **not** structurally
    decreasing — so the group is the *deliberately* partial one, the honest type of
    an interpreter that runs arbitrary programs. That partiality is opt-in and loud
    (it type-checks only because totality is classified, not enforced by default —
    E11), the marked case per P5.
  - **I64 floor (E24).** de-Bruijn indices, literals, and case tags are `I64`.
- **The reframing:** meaning is given by a step relation `Term => Step` whose
  `step-tail` says "continue at `(env, next)`"; the driver iterates that relation
  to a `Value`. (In the pure-single-step Knob the stepper is `->` and *only* the
  driver is `=>` — the sharper split.) The category-C extern/port crossing
  (runtime.py's `IMPLS`/`bridge.verify`) becomes a *typed bridge connector* at the
  one place the evaluator leaves the pure fragment — not an inline call in the hot
  loop.
- **What chirality makes impossible here:** dispatching on a term or value shape the
  evaluator forgot to handle and `raise`ing (coverage closes it); silently
  reintroducing host-stack growth by mishandling the tail position (the tail call
  is structural, not manual); forcing an erased binding (it is not in `Value`); a
  "pure" evaluation step secretly crossing a port (the `->`/`=>` skin forbids it).

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, in the `fsm.chiral` idiom
(closed `data`, structural `case`, a two-constructor `Step` as the trampoline).
The pure step function is `->`; the divergence-carrying driver is `=>`.

```chirality
; E15 skeleton: the golden tree-walk evaluator as an explicit, coverage-checked
; trampoline. Mirrors scaffold/chirality/runtime.py's RT.run / RT.apply1 -- the manual
; `while True` + (value | (env,body)) return becomes a `data Step` the `case` must
; cover, and the trampoline hop becomes an ordinary tail call. Pure step (->) over
; a closed Term/Value; the port-crossing extern face (category C bridge) is split
; off into the driver's membrane (see Deliberately omitted).
(import "prelude")       ; List, Pair, cons/nil/pair, I64 ops
(import "collections")   ; append (list concat); list-nth is a forward-declared helper below

; Runtime values. Closed sum, so the evaluator cannot fall through the way
; runtime.py's ("clo",..)/("con",..)/("pap",..) tuples can. There is NO ("erased",)
; here: a 0-quantity binding is erased by QTT before runtime, so it cannot be
; represented, let alone forced.
(data Value ()
  (v-lit (n I64))
  (v-clo (env (List Value)) (body Term))     ; body sees 1 new binder
  (v-con (tag I64) (args (List Value))))

; The nameless core term (subset of runtime.py's tag-tuple language: the pure
; fragment -- Global/Prim/Con-of-extern are the omitted bridge face).
(data Term ()
  (e-var  (idx I64))
  (e-lit  (n I64))
  (e-lam  (body Term))                        ; body sees 1 new binder
  (e-app  (fn Term) (arg Term))
  (e-let  (rhs Term) (body Term))             ; body sees 1 new binder
  (e-case (scrut Term) (arms (List (Pair I64 Term)))))

; One trampoline result. This IS runtime.py's apply1 return, made a closed sum:
; a finished value, a tail hop the driver must iterate on, or a stuck term. Three
; constructors, so eval-step can neither drop the tail case nor `raise` on stuck.
(data Step ()
  (step-done  (val Value))
  (step-tail  (env (List Value)) (next Term))
  (step-stuck (why I64)))                     ; unreachable on checked terms

; eval-step env t : evaluate ONE node, in tail position. It is `=>` (process),
; not `->`: this is a BIG-STEP evaluator -- it forces non-tail subterms (function,
; argument, scrutinee) by calling `eval`, and it is one mutual-recursion group with
; `eval`/`run`, so it shares their effect status (they may diverge -- P3 counts
; non-termination as a port -- and `run` exits `step-stuck` via the `rt-alarm`
; crossing). The genuinely-pure step -- a small-step machine that returns a
; continuation for EVERY subterm instead of forcing it, keeping a `->` stepper --
; is the Knob below. The single tail position yields step-tail so `run` iterates
; instead of growing a stack -- runtime.py's `env, t = tail_jump`.
; elided helpers, forward-declared (bodies mechanical): list-nth = env lookup by
; de-Bruijn index; arm-body = select a case arm's body by tag; rt-alarm = the
; typed alarm crossing (the => membrane exit, shape mirrors `halt`; see
; Deliberately omitted). `append` (list concat) comes from collections.
(declare list-nth (-> (0 A (type 0)) (List A) I64 A))
(declare arm-body (-> (List (Pair I64 Term)) I64 Term))
(declare rt-alarm (-> (0 A (type 0)) (=> I64 A)))

; eval-step <-> eval <-> run are one mutual-recursion group, so ALL declares
; come before ANY def (the json.chiral forward-decl idiom).
(declare eval-step (=> (List Value) Term Step))
(declare eval      (=> (List Value) Term Value))
(declare run       (=> Step Value))

(def eval-step                              ; type from the declare above
  (lam (env t)
    (case t
      ((e-var i)    (step-done (list-nth Value env i)))   ; env lookup by de-Bruijn
      ((e-lit n)    (step-done (v-lit n)))
      ((e-lam body) (step-done (v-clo env body)))         ; capture env as a closure
      ((e-let rhs body)
        (step-tail (cons (eval env rhs) env) body)) ; bind, then TAIL into body
      ((e-app f a)
        (case (eval env f)
          ((v-clo cenv cbody)                             ; the one tail CALL: hop, don't recurse
            (step-tail (cons (eval env a) cenv) cbody))
          ((v-lit n)      (step-stuck 1))                 ; applied a non-function
          ((v-con tg ar)  (step-stuck 1))))
      ((e-case scrut arms)
        (case (eval env scrut)
          ((v-con tg ar)                                  ; select arm by tag, bind ctor args
            (step-tail (append Value ar env) (arm-body arms tg)))
          ((v-lit n)   (step-stuck 2))                    ; case on non-data
          ((v-clo e b) (step-stuck 2)))))))

; eval env t : force a subterm to a Value. The non-tail helper eval-step calls
; for scrutinees / arguments / let-rhs; just runs the trampoline from one node.
(def eval                                   ; declared above (mutual group)
  (lam (env t) (run (eval-step env t))))

; run s : drive the trampoline to a Value. Loops on step-tail exactly where
; runtime.py loops with `while True` -- but it is an ordinary TAIL call, so chirality's
; proper-tail-call guarantee makes it constant-stack; no hand-managed stack. `run`
; is `=>` (process), not `->`: an evaluated program may diverge, and P4 counts
; non-termination as a port. step-stuck raises a typed alarm at the membrane
; (never reached on well-checked terms).
(def run                                    ; declared above (mutual group)
  (lam (s)
    (case s
      ((step-done  v)      v)
      ((step-tail  env nx) (run (eval-step env nx)))      ; TCO: tail self-call = the loop
      ((step-stuck why)    (rt-alarm Value why)))))       ; typed alarm, not a host raise
```

- **Knobs to modify:** the `Term` constructor set — add `e-global` / `e-prim`
  (the extern/bridge face) and `e-ann` (transparent, `t = t[1]; continue`) to
  reach runtime.py parity, adding the matching arm to `eval-step` (coverage forces
  it); the `Value` set (add `v-pap`/`v-talf` for partially-applied externs and tal
  functions); the arm-selection helper `arm-body` (default arm vs `case fell
  through`); whether `step-stuck` stays as data or the whole evaluator is proven
  total on *checked* terms (then `step-stuck` is dead and can be dropped).
  **The membrane Knob (the sharper split):** make this a genuine *small-step*
  machine — `eval-step` returns a `step-tail` continuation for *every* non-tail
  subterm (function, argument, scrutinee, let-rhs) instead of forcing it with
  `eval`, so the stepper is `->` (pure) and only the driver `run` is `=>`. That
  isolates every crossing (divergence, `rt-alarm`, the extern face) in the driver.
  The big-step form shown here forces subterms directly for readability, which is
  why `eval-step`/`eval`/`run` are one `=>` mutual group; the small-step form is
  the same idea with the membrane drawn tighter.
- **Deliberately omitted:** the **category-C bridge / port face** — `Global`,
  `Prim`, `pap`/`talf` application, `IMPLS[name](*args)` + `bridge.verify`, and the
  tal-floor handoff. That is a *different* connector (a typed bridge crossing, its
  own element) and is exactly where the second source of `=>` enters; folding it in
  here would blur the pure-core / effect-driver split the example exists to show.
  Also omitted: multi-binder `e-case` arity counting beyond the simple bind, and
  the `sys.setrecursionlimit` host-stack hack (moot once TCO is structural).

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/interp.chiral` (new), the golden reference evaluator;
  imported by the conformance harness and reused as the oracle E16/E18 check
  against; eventually retires `scaffold/chirality/runtime.py`.
- **Conformance target:** reproduce `runtime.py` exactly on golden program
  fixtures — for every checked term `t`, `run (eval-step nil t)` yields a `Value`
  that decodes to the same result `RT.run(t, [])` produces, including closure
  capture, `Case` arm selection, and constant-stack behavior on a deliberately
  deep tail-recursive fixture (an event loop that would blow a non-TCO stack). The
  omitted extern/port arms, once added, must match `apply1`'s `pap`/`talf`
  handshake and `bridge.verify` semantics call-for-call.
- **Open questions:** is `step-stuck` kept as an honest data case, or is the
  evaluator proven total on *well-typed* terms so stuckness is statically dead?;
  does the extern/port face come in as new `Term`/`Value` constructors (one
  evaluator) or as a separate `=>` bridge module the pure core calls out to
  (cleaner membrane, an extra connector)?; how are 0-quantity arguments (still
  evaluated, but the checker holds them pure) represented once erasure is
  structural — evaluated-and-discarded, or elaborated away?
- **Related:** [[E13-debruijn]] (the nameless `Term` and index machinery this
  evaluator walks), [[E16-lowering]] (pure→tal lowering whose *preserve-check*
  must reproduce this golden semantics), [[E18-tal-interp]] (the lower-altitude
  reference interpreter this one is the upper twin of), [[E12-effect-membrane]]
  (the `->` core vs `=>` driver split), [[E05-qtt-semiring]] (the erasure that
  removes 0-lets structurally), [[E24-i64-arith]] (the `I64` index/literal floor).
```