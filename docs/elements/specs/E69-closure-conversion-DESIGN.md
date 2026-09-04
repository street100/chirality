# E69 — closure conversion, drawn out (worked examples + implementation notes)

> ⚑ **TRIAGE 2026-09-04 — DEAD.** 0 of 5 steps are executable at HEAD. Design
> companion to the DEAD SPEC; keep as rationale, do not queue. Bucket and
> evidence: `records/spec-tier-triage.md`. This file was not rewritten and its
> `status:` was not changed.

> **IMPLEMENTATION STATE (2026-08-02, 401 green).**
> `scaffold/chirality/closconv.py` exists and is **wired live into `lower_all`**
> (idempotent via `sig._closconv_done`; no-op on closure-free code). THREE
> closure-producing site kinds now lower + are tested (`tests/test_closconv.py`),
> all native == reference == expected, D-2 deterministic:
> 1. **Higher-order parameter / Global function-value** —
>    `(apply-it add1 x)`: a `(-> I64 I64)`-typed param applied, and a Global
>    (`add1`) passed as a value (a nullary closure).
> 2. **Partial-application captures (§7b #1)** —
>    `(make-adder 3)` capturing `3`; both **k=1** and **k=2 multi-capture**
>    (`(add3 10 20)`).
> 3. **Escaping lambda literals** — `(the (-> I64 I64) (lam (w) (+ z w)))`
>    (Ann-wrapped, let-bound) and a **bare `(lam (w) (+ z w))` in an argument
>    position** (type from the callee), each capturing `z`.
>
> **Architecture** (all in `closconv.py`): `_collect` walks every def threading a
> **type context** (mirroring `lower.Low`: param types on the def chain, the
> let-value type on `Let`, callee-domain types on `App` args, the lambda's own
> param types when descending). Closure sites are keyed heterogeneously:
> `("g", g, k)` (partial app / nullary value) and `("lam", <body>, <captys>)`
> (lambda literal), each → a synth record. `_synth` mints one `$clo<i>` sum +
> `$apply<i>` per arrow family with one ctor per site (fields = its captures) and
> one `case` arm — `_arm_body` remaps the site's source body so a captured var
> reads the ctor field and a remaining param reads apply's arg (§1.3 de Bruijn,
> verified against the eval convention: first ctor field = highest arm index,
> last = Var 0). `_rewrite` turns `(f x)`→`($apply f x)`, a partial App / lambda
> literal → its `Con`, a Global value → its nullary ctor, an arrow param type →
> `$clo`. **Detection reads the ORIGINAL sig; installation is two post-loop
> passes** (all new types, then re-check every body) so a def calling a converted
> peer sees the peer's new `$clo` type. Only families with a convertible ctor get
> an `$apply` (an empty `case` would crash); out-of-scope sites are left
> unconverted → their def just doesn't lower (SKIPPED, never a crash — tested).
> Bare lambdas require an expected type (`Ann` or arg position) so an escaping
> literal's arrow type is always in reach — no inference. Helpers added this
> slice: `_peel_lams`, `_callee_doms`, `_first_order_body` (the arm-lowerability
> guard), `_arm_body`; `_ty_of` now handles `Ann`.
>
 > **Conformance gate #3 (the chirality twist) is LOCKED** — `test_closconv.py`
> `test_linear_capture_is_rejected`: an ω-closure capturing a linear port
> (`(the (=> I64 Unit) (lam (m) (sock-close s)))`) is rejected by the EXISTING
> linear-kind rule at check time ("binder s declared 1 but used w"), before any
> conversion. The ownership law E69 makes structural is asserted, not just
> claimed; a non-linear capture of the same shape checks fine (the control).
>
> **NEXT SLICE — true nested closures (§6). A FINDING makes this a foundational
> increment, not a small one (surfaced by drawing the two-level term out,
> 2026-08-02):** an arrow type like `(-> A (-> B C))` is **ambiguous** between a
> 2-ary function (curried, lowers today via greedy `_peel_pi_terms`) and a 1-ary
> function returning a **1-ary closure** (`(-> A Clo_BC)`). The distinction is the
> VALUE (a `Global` def vs. an escaping lambda literal), not the type — so
> families keyed by arrow-type *alone* are ambiguous once an intermediate arrow is
> a real runtime closure. The current model assumes fully-saturated (greedy-peel)
> arities everywhere, which is sound only because closures are eliminated; §6
> breaks it because `apply_mid` must **return a `Clo_in`**, i.e. its cod is itself
> a `$clo`. Doing §6 needs: (1) lambda-literal families keyed by **binder-count
> arity** (peel exactly `d` = the literal's `Lam` depth, not greedily), with a
> possibly-arrow cod; (2) that arrow cod converted to `$clo` (the `new_cod`→`$clo`
> machinery already exists for params — extend to lambda cods); (3) arm bodies
> **re-run through the rewrite** so a nested literal in a middle arm becomes a
> `Con` building the inner closure (arms are taken verbatim today — this needs a
> declare-all-`$clo`/`$apply`-then-fill-arms split so `keyed_apply` is complete
> before any arm is built). `reg_lam` currently defers §6 via `_first_order_body`
> (nested `Lam` body) — the guard is correct; lifting it is the above rework.
> Off the self-host critical path (NbE is named-recursion, not multi-level
> escaping closures), so it deserves an explicit go before the arity rework lands.
>
> **Then `q=0` erasure (§7b)** — thinner than it reads: a vestigial *non-dependent*
> erased param is rare (dependent erased params, the usual kind, don't lower
> anyway), and correct multi-param erasure needs de Bruijn binder-strip at the def
> + arg-drop at every saturated call site + skip-if-any-partial-call. Scoped but
> low-yield; `q=1` is port-coupled (rides E70). **Then E70** on the shared
> tal-signature carrier. Deferred within E69: self-referential closure cells
> (§7 shape 3).
>
> Discipline: `closconv.py` is wired into `lower_all`, so a bug breaks ALL
> lowering — probe each slice in isolation, then run the suite, commit only when
> green.



Companion to `E69-closure-conversion-SPEC.md` (the contract) and the example
(the rationale). This doc *works the transformation through on real terms* so
the implementation is a transcription of something already checked on paper,
not a design done live in code. Every term below is in the actual checked-term
representation (verified against the elaborator 2026-08-02).

## 0. The representation (ground truth)

Checked kernel terms, de Bruijn:

| term | shape | note |
|---|---|---|
| variable | `("Var", i)` | `i` = de Bruijn index; 0 = innermost binder |
| lambda | `("Lam", name, body)` | binds ONE var; `name` is cosmetic, the **type is not in the term** (it lives in the `Pi`) |
| application | `("App", f, arg)` | curried; a spine is left-nested `App(App(f,a),b)` |
| global / prim | `("Global", n)` / `("Prim", n)` | a call target / an extern |
| constructor | `("Con", dname, cname, [args])` | a data value |
| case | `("Case", scrut, [(cname, [names], body)], default)` | arm binds `len(names)` vars |
| let | `("Let", q, name, val, body)` | `body` at depth+1 |

`terms.uses_below(t, bound)` and `terms.shift_close(t, delta)` are the de Bruijn
walkers already in the tree — **reuse them, do not re-derive index math.** Free
variables are `uses_below`'s dual (collect the `Var i` with `i >= bound`).

The lowering path (`lower.py`) is strictly first-order; it rejects exactly three
things E69 must eliminate first:
- `expr` `App` with a non-`Global`/`Prim` head → `Ineligible` (`:274`) — a
  higher-order call (applying a closure value).
- `len(spine) != len(doms)` → `Ineligible` (`:276`) — partial application.
- a nested `Lam` term reaching `expr` → `Ineligible("… stays upper")` (`:284`).

## 1. Worked example A — `make-adder` (the capturing closure)

Source: `(def make-adder (-> I64 (-> I64 I64)) (lam (x) (lam (y) (+ x y))))`.

**Checked term (verified):**
```
make-adder : (-> I64 (-> I64 I64))
  Lam("x", Lam("y", App(App(Prim "+", Var 1), Var 0)))
```
Inside the inner lam: `Var 0` = y (its own binder), `Var 1` = x (the outer
binder — the capture).

### Step 1 — find the lam-site and its captures
The inner `Lam("y", …)` is a value of arrow type `(-> I64 I64)`. Its free
variables = the `Var i` in its body with `i ≥ 1` (index 0 is its own `y`),
shifted down by 1 to name the enclosing scope: here `{ Var 1 } → x`. So:
- **captures = [x : I64]** (one capture; type read off the enclosing env / the
  `Pi` telescope, NOT the term).

### Step 2 — synthesize the closure sum (one per arrow-signature family)
The arrow `(-> I64 I64)` gets ONE data type; each lam-site of that arrow is one
constructor carrying that site's captures:
```
(data Clo_I64_I64 ()
  (k0 (cap0 I64)))        ; k0 = make-adder's inner lam; cap0 = the captured x
```

### Step 3 — synthesize the apply for that family
```
apply_I64_I64 : (-> Clo_I64_I64 I64 I64)
```
Its body dispatches on the closure and runs the site's original body, with two
renamings applied to that body's variables:
- the lam's **own parameter** (`y`, `Var 0`) → apply's **argument** parameter;
- each **captured** var (`x`, `Var 1`) → the **arm binder** for its field.

Worked de Bruijn surgery (this is the delicate bit — spelled out):
```
apply_I64_I64 = Lam("clo", Lam("arg",
                  Case(Var 1,                        ; scrutinee = clo
                    [("k0", ["cap0"], BODY)], None)))
```
Inside the `k0` arm the binder stack (innermost first) is `[cap0, arg, clo]`, so
`cap0 = Var 0`, `arg = Var 1`, `clo = Var 2`. The original inner-lam body was
`App(App(Prim"+", Var 1 = x), Var 0 = y)`; remap **x → cap0 (Var 0)** and
**y → arg (Var 1)**:
```
BODY = App(App(Prim "+", Var 0), Var 1)
```
Mechanically: build the arm environment `[captures…, apply-params…]` in a fixed
order, then rewrite the site body by mapping each original variable to its new
index in that environment. `shift_close` + a small index-remap table does it;
do not hand-count in the general case.

### Step 4 — rewrite the defining site
The inner `Lam` becomes a constructor application capturing its free vars (in
make-adder's body, after binding `x`, `x` is `Var 0`):
```
make-adder : (-> I64 Clo_I64_I64)                    ; return type: arrow → the sum
  Lam("x", Con("Clo_I64_I64", "k0", [Var 0]))
```

### Step 5 — rewrite every use site
An application whose head is *not* a first-order `Global`/`Prim` — i.e. applying
a closure value — becomes an `apply_*` call:
```
((make-adder 3) 7)
  = App(App(Global "make-adder", 3), 7)
  → App(App(Global "apply_I64_I64", App(Global "make-adder", 3)), 7)
```
Now every node is first-order: `make-adder` returns a data value, `apply_I64_I64`
is `data`+`case` over words, the call site is an ordinary saturated call — all
three lower through the existing path unchanged.

## 2. Worked example B — the linear capture (the continuation shape)

Source shape (E39's continuation, the reason the chirality twist is not optional):
```
(lam (s2) …)   where s2 : Sock, captured at quantity 1
```
Conversion carries the quantity onto the field:
```
(data KontClo () (clo-kont (1 s2 Sock)))
```
`KontClo` transitively holds a port ⇒ the **existing linear-kind rule**
(`effects.py on_binder`, `K.is_linear`) makes every `KontClo` value quantity-1.
So `apply-kont`'s closure parameter must be bound `1`, and using the closure
twice / dropping it is a **checker rejection** — E39's bind-site law
re-derived structurally, zero new machinery. *The negative test is the point.*

Note (from probing, 2026-08-02): a `1`-quantity binder only typechecks where the
value is genuinely used once; pure `I64` ops use their args at ω, so the linear
case is essentially **always a port** — i.e. it rides E70's effectful fragment.
The pure-lowerable E69 slice is the ω-capturing closures (example A).

## 3. Worked example C — partial application

Two shapes, one move (capture-and-repack):
- **A saturated closure apply that's under-applied downstream** — `add3 = (make-adder 3)`
  is already a `Clo_I64_I64`; `(add3 7)` is example A's use-site rewrite.
- **A top-level function applied to too few args** — `(f a)` where
  `f : (-> I64 I64 I64)`: synthesize a closure ctor for `f` capturing `a`
  (`(data Clo_f () (kf (cap0 I64)))`), and `apply_f(kf(a), b) = (f a b)`. The
  partial app becomes `Con(Clo_f, kf, [a])`; the eventual second arg goes through
  `apply_f`. Same three synthesized pieces (sum + ctor + apply), same rewrite.

## 4. The pass, as an algorithm (sketch — not code)

Whole-program, over the checked sig, before `lower_all`:
1. **Collect** every lam-site (a `Lam` not in the top-level def-lam-chain) and
   every partial-application site, across all `global_defs`. Group by arrow
   signature.
2. **Per family**: mint one `data Clo_<sig>` with one constructor per site
   (fields = that site's captures, with quantities); mint one `apply_<sig>`
   (case over the sum; each arm = the site body remapped per §1.3).
3. **Rewrite** every def body: lam-site → `Con` of its captures; closure-value
   application → `apply_<sig>` call; partial app → `Con` + `apply_<sig>`.
4. **Retype** the rewritten defs (arrow return/param types that became closures
   now read `Clo_<sig>`); register the new data + defs in the sig.
5. **Re-check** everything through the existing checker — the converted program
   is first-order `data`+`case`+`def`, and re-checking is what makes the
   linear-kind rule enforce captures (§2). A conversion bug is a checker/floor
   alarm, never shipped.

`q=0` erasure rides this pass (drop the erased param at the def AND the arg at
every call site — sig-level and consistent; there is no `lower.py`-local slice,
because a dropped fn-sig has lost which spine positions were erased).

## 5. Open implementation questions (surfaced by drawing it out)

1. **Nested closures** (a lam inside a lam inside a lam). The middle lam
   captures from the outer; the inner captures from both. Captures compose: an
   inner site's free vars may include a *middle* binder that is itself becoming
   a capture field. Order the conversion inside-out, and a middle capture of an
   outer var threads through as a field of the middle closure that the inner
   reads. Worth a dedicated worked example before coding (example D, TODO).
2. **`apply_<sig>` identity across families with the same tal shape.** Two
   different source arrow types that erase to the same tal signature (e.g. both
   one-word-in, one-word-out): do they share one `apply`, or stay distinct by
   source type? Distinct-by-source is simpler and safe (more `apply`s, no
   aliasing hazard); sharing is an optimization. Lean distinct.
3. **Recursion through a closure** (deferred per SPEC §3 #4): a site whose body
   references a `Global` that is itself being converted, or a self-referential
   closure. Back-patch or a `rec-` constructor — needs example E before coding.
4. **Where the mint names live** so two runs are byte-identical (D-2): the
   family/ctor/apply names must be a deterministic function of the source
   (arrow signature + site order), never a counter over hash iteration.

## 6. Example D — nested closures (drawn)

`(lam (x) (lam (y) (lam (z) (+ (+ x y) z))))`. Three lam-sites; the middle and
inner ones capture across more than one binder.

- **Innermost** (binds `z`): body `(+ (+ x y) z)` uses `x`, `y` (free), `z`
  (own). Captures `{x, y}`.
- **Middle** (binds `y`): its body *is* the inner lam, which captures `{x, y}` —
  but `x` is free in the middle too (from the outer), while `y` is the middle's
  own binder. So the middle site captures `{x}`, and it must *forward* `x` into
  the inner closure it builds.
- **Outer** (binds `x`): builds the middle closure capturing `{x}` = its param.

The threading is compositional — **each `apply` reconstructs its environment
from its closure's fields + its own params, then builds any nested closure from
that reconstructed environment**:
```
data Clo_mid  () (m0 (x I64))                  ; middle closure carries x
data Clo_in   () (i0 (x I64) (y I64))          ; inner closure carries x AND y

apply_mid : (-> Clo_mid I64 Clo_in)            ; (clo=x, y) -> build inner
  = case clo of (m0 x) -> (i0 x y)             ; x from the field, y from the param
apply_in  : (-> Clo_in I64 I64)                ; (clo={x,y}, z) -> the body
  = case clo of (i0 x y) -> (+ (+ x y) z)

make : (-> I64 Clo_mid)  = (lam (x) (m0 x))
```
**Rule (the general capture law):** a site's capture set = the free vars of its
body that escape its own binder; those vars are read from *the enclosing
closure's fields*, not an ambient scope — so a capture that is itself an
enclosing capture threads through as a field at every level between where it is
bound and where it is used. Convert **inside-out** so each level knows what its
descendants need to be handed. The de Bruijn remap is §1.3's, applied per level.

## 7. Example E — recursion (drawn; why the first cut defers only the hard case)

Three shapes, only one deferred:
1. **Named top-level recursion** (e.g. `fib` calling `fib`, or NbE's `eval`
   calling `eval`): first-order `Global` self-calls — **already lower today**,
   untouched by conversion. *This is the bulk of the self-host customer's
   recursion* (NbE is recursive `def`s, not self-capturing closures).
2. **Recursion through `apply_*`**: a converted higher-order recursive function
   becomes a top-level `apply_*` that calls itself — an ordinary `Global`
   self-call. **Lowers for free**; `apply_*` is just a def.
3. **A self-referential closure CELL** (a closure whose capture field must point
   at the closure value itself — a knot): needs the standard **back-patch**
   (allocate the cell, then write the self-field) or a `rec-` constructor. This
   is the only genuinely new case, and it is **deferred** (SPEC §3 #4) because
   (1)+(2) cover NbE and the emitter, so nothing in the self-host critical path
   needs it in the first cut.

So "recursion" is not a blanket blocker: only shape 3 is deferred, and it is
rare and off the critical path.

## 7b. IMPLEMENTATION FINDING (2026-08-02) — the flagship example was mis-scoped

Building the first slice against real terms surfaced a correction: **`make-adder`
as written is not a closure-conversion case.** Its type `(-> I64 (-> I64 I64))`
is, by currying, identical to `(-> I64 I64 I64)`, and the existing lowering
already peels *both* lams as parameters. Verified: `make-adder` and a
fully-applied caller `((make-adder a) b)` **lower and run native today with the
pass doing nothing.** The doc's §1 example site `((make-adder 3) 7)` is fully
applied → currying, not a closure.

**A closure only exists when a function value ESCAPES un-applied.** The two real
triggers, both verified against `lower.py`:
1. **Partial application that escapes** — `(let ((f (make-adder 3))) (+ (f z) (f 1)))`
   → rejected `partial application` (`lower.py:276`). Here `(make-adder 3)` is a
   real closure capturing `3`; `f` is a closure value applied later.
2. **A function-typed parameter, applied** — `(def apply-it (-> (-> I64 I64) I64 I64)
   (lam (f x) (f x)))` → rejected `type does not lower` (the `(-> I64 I64)` param
   has no word rep). `(f x)` is a higher-order application (`lower.py:274`).

**Consequences for the pass** (it is *use-site* driven, not def-return driven):
- The conversion targets are **partial-application sites** and **function-typed
  positions** (params/args/returns used as values), NOT "defs that return an
  arrow" (those are curried and lower already).
- `make-adder` *can* be a closure source — but only via trigger 1 (partial +
  escape). The apply arm is then make-adder's full body `(+ x y)` with `x` from
  the captured partial arg and `y` from the apply argument.
- A first-order `Global` used as a *value* (e.g. `add1` passed to `apply-it`)
  becomes a **nullary** closure constructor; direct calls of it stay direct.
- The de Bruijn machinery (`_free_indices`, `_remap`) and the synthesis path
  (`check_data`/`check_def`/`_mk_pi`) in `closconv.py` are reusable as-is; only
  the *trigger detection + collection* logic reorients from def-return to
  use-site.

**The example/doc §1 should be re-anchored** on an escaping partial application
(trigger 1) so the flagship actually exercises the pass; the fully-applied
`((make-adder 3) 7)` stays as the contrasting "this is just currying, no
conversion" case. (Recorded here; the example edit is a follow-on.)

## 8. Rounded off — ready to implement

The transformation is fully on paper: the representation (§0), the three worked
cases (§1–§3), the pass algorithm (§4), nested capture (§6), recursion (§7), and
the four implementation decisions (§5: sig-level location, distinct-apply-per-
source-type, deterministic mint names, `q=0` sig-level erasure). `closconv.py`
is now a transcription of §4 with §1.3's remap and §6's inside-out order — no
design left to do live in code. Build order: `closconv.py` (the pass) → the
`lower.py:300` `q=0` relaxation riding it → then E70 on the shared carrier.
