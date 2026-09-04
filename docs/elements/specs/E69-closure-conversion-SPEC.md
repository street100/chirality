---
element: E69
slug: closure-conversion
title: Closure conversion + quantities-to-tal: lower closures and partial application, carry 0/1/ω to the floor (today only unrestricted closure-free arrows lower; NbE is made of closures)
kind: BUILD-PROPER
example: examples/E69-closure-conversion.md
status: audited
updated: 2026-08-02
---

# E69 SPEC — Closure conversion + quantities-to-tal

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.
>
> **Staging (author call 2026-08-02): E69 first, then E70.** This SPEC delivers
> closure conversion for the fragment that can lower *today* — the PURE
> higher-order code. Converted `apply-*` dispatchers that are effectful (their
> arms cross) still hit the `=>` eligibility gate and wait for E70. That
> boundary is stated explicitly in §3 and §6; it is not a gap, it is the stage.

## 1. Deliverable

- **After this runs:** a closure-conversion pass (`scaffold/chirality/closconv.py`)
  transforms the checked signature *before* `lower_all` — every capture-bearing
  `lam` and every partial application becomes first-order `data`+`case`
  (defunctionalized: one constructor per capture site, one `apply-*` per
  arrow-signature-family), with captured binders carrying their QTT quantities
  (0 erased at conversion, 1 recorded, ω plain). Quantities-to-tal: the lowering
  gate stops rejecting 0/1 binders (`lower.py:300`) and instead erases 0 and
  records 1. Net: **pure higher-order code (nested `lam`, partial application)
  lowers to native and runs**, differentially equal to its direct-style source;
  a linear-capturing closure is a linear cell that the *existing* checker
  rejects on duplication.
- **Non-goals:** the effect row of effectful `apply-*` (that is E70 — the
  staged next; effectful converted code converts here but does not lower until
  the `=>` gate opens); grade seats (E38); recursive closures via self-reference
  (deferred within E69 — §3 #4); typed-environment/existential conversion (the
  modular alternative — deferred to E57 staging, §3 #2); the conversion as a
  certificate-emitting producer (E52).
- 2026-09-04: the Python oracle was cut, and scaffold/ went with it in the 2026-08-31 migration. The citations it left are kept as a record and have no live successor.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** no E69 row (postdates the snapshot) — treat as
  **BUILD**. The `module` bank is authoritative: *"only pure/ground/non-dependent
  bodies lower today; closures/HO are separate forward work (E69), not a
  defect."* So this is honestly-unbuilt; the delta is net-new, not a refactor.
- **Live code this composes with (do NOT respec):**
  - `lower.py` `Low` class (`:107`) — `expr`/`tail` lower checked `Term`s to
    tal; already emits `data`→boxed-cell (`ti-cona`) and `case`→dispatch
    (`ti-case`/`lsb`). The converted first-order program is exactly what this
    already handles.
  - `lower.py` `_peel` (`:73`) — the eligibility gate. `:298` rejects effectful
    (`=>`) arrows — **left as-is; opening it is E70**. `:300` rejects `q != K.W`
    binders (`Ineligible("quantified binder (0/1 stay upper for now)")`) — **this
    SPEC opens exactly that line** (the quantities-to-tal half).
  - Boxed data (milestone 2): `[tag][fields]` arena cells + `lsb` tag dispatch
    — the flat-closure representation, already built. Closures need **no new
    runtime form** (example §2.2).
  - The linear-kind rule (`effects.py` `on_binder`; E8's `is_linear`) — a `data`
    value transitively holding a port is quantity-1 by construction. This is
    what makes a port-capturing closure-cell linear *for free* after conversion,
    and what rejects its duplication. No new machinery.
  - Elaborate → check → lower pipeline: because conversion emits surface `data`
    +`case`+`def`, the converted program re-elaborates and re-checks through the
    existing checker — the capture discipline is checked, not asserted.
- **True delta:** (a) `closconv.py` — the defunctionalizing transform over the
  sig; (b) the one-line gate relaxation at `lower.py:300` (0 erased, 1 recorded);
  (c) the tal signature carrying recorded 1-quantities (the "quantities-to-tal"
  field, on the *typed* tal signature — coordinates with E70's row field on the
  same signature, §6).

## 3. Decisions

Every open question from the example §6, dispositioned.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Where the conversion pass sits — surface-to-surface before `lower`, or inside `lower.py` before tal emission? | **RESOLVED: sig-level, before `lower_all`.** | `closconv.py` transforms the checked sig (adds the closure `data` decls + `apply-*` `def`s, rewrites bodies: capture-`lam`→constructor, application→`apply-*` call), then the *existing* elaborate/check/lower runs on the result. Chosen because the output is surface `data`+`case`+`def` the pipeline already lowers, and re-checking makes the linear-kind rule enforce captures (example §4: "the converted program is first-order code the current lowering path already handles"). Defunctionalization is whole-batch, and the whole batch is available at the sig level. |
| 2 | Defunctionalization vs typed (existential) environments. | **RESOLVED: defunctionalize now; DEFERRED modular version → E57.** | The tal floor has no existentials (example §2.3); Reynolds defunctionalization needs zero new tal formers (closed-world `case` over one sum per signature family). It is whole-batch/anti-modular, which is honest *now* because the scaffold is batch-compiled; the modular MMH form is revisited when separate compilation / live linking (E57 staging) arrives. Matches the settled "defunctionalization now, revisit at E57" direction. |
| 3 | apply-per-signature explosion management. | **RESOLVED: one `apply-*` per arrow-signature-family.** | Capture sites are grouped by the arrow type they inhabit; each family gets one sum (constructors = its capture sites) and one `apply-*` (arms = the code bodies). Count is bounded by distinct higher-order arrow signatures in the batch, not by capture sites. Mechanical. |
| 4 | Recursive closures (self-reference via the cell). | **DEFERRED within E69** (named follow-on). | First cut converts non-recursive closures + partial application. Self-referential closures need the standard back-patch or a `rec-closure` constructor; scoped as a follow-on step so the first cut ships the common case. NbE's recursion is largely named top-level `def` recursion (already lowers), not closure self-reference, so this does not block the self-host customer's bulk. |
| 5 | Effect row of effectful `apply-*`. | **DEFERRED → E70 (the staged next).** | An `apply-*` whose arms cross is effectful; its row is `row_union` over the arms (E70's floor re-derivation). Such `apply-*` convert here but do not lower until E70 opens the `=>` gate. This SPEC's conformance target is therefore the PURE higher-order fragment; the effectful fragment lands with E70. This is the staging boundary, stated. |
| 6 | Conversion as a certificate-emitting producer under E52. | **DEFERRED → E52.** | The conversion output is preserve-checked like any lowered code (a bad conversion is a floor alarm), which suffices now. Whether it *additionally* emits an E52 certificate rides the E52 spec-size decision. |

No NEEDS-AUTHOR blockers. (The staging call and defunctionalization direction
are settled per the author; both recorded above, both revisitable.)

## 4. Change plan (ordered, commit-sized)

### Step 1 — `closconv.py`: defunctionalize the pure fragment
- **Target:** `scaffold/chirality/closconv.py` (NEW) + a call site before
  `lower_all` in the compile path.
- **Change:** walk the checked sig; for each capture-bearing `lam` collect its
  free variables (with quantities), group capture sites by arrow-signature
  family, synthesize one closure `data` sum + one `apply-*` `def` per family,
  and rewrite: capture-`lam` → constructor application (0-captures dropped),
  saturated application of a converted arrow → `apply-*` call. Emit surface
  forms so elaborate/check/lower run unchanged.
- **Size:** ~L.

### Step 2 — partial application → capture-and-repack
- **Target:** `closconv.py` (same pass).
- **Change:** an under-saturated application becomes a constructor that captures
  the supplied arguments; the dispatch supplies the rest. Same record shape as
  Step 1 (example §5: `(add3 7)` ⇒ `(apply-i64-i64 (clo-adder 3) 7)`).
- **Size:** ~M.

### Step 3 — quantities-to-tal: open the 0/1 gate
- **Target:** `lower.py:300` (`_peel` / `lower_all`) + the tal signature in
  `tal.py`.
- **Change:** replace the `q != K.W` rejection with: 0-quantity params erased
  (not lowered — no runtime presence), 1-quantity params lowered and **recorded
  in the typed tal signature** (the quantities field, alongside where E70 will
  add the row field — §6). ω unchanged. The linear-kind rule already checks the
  cells upstream; this step just stops refusing to lower them. *(Two distinct
  erasure sites, not double-erasure: 0-quantity **captures** never become
  closure fields at conversion — Step 1; 0-quantity **params** are dropped here
  at lowering — the general quantities-to-tal gate.)*
- **Size:** ~M.

### Step 4 — (follow-on, may split to its own commit) recursive closures
- **Target:** `closconv.py`.
- **Change:** back-patch or a `rec-closure` constructor for self-referential
  captures (§3 #4). Ships after the non-recursive cut is green.
- **Size:** ~M.

## 5. Conformance gate

- **Golden behavior:** every converted PURE higher-order program is
  differentially equal to its direct-style source on the reference interpreter
  and the native floor; every converted body preserve-checks; a linear-capturing
  closure (the `KontClo`/`(1 s Sock)` shape) is *rejected* by the checker when
  duplicated or dropped — the negative test is the point.
- **Tests to add (`scaffold/tests/test_closconv.py`, NEW):**
  1. **Round-trip (positive):** `make-adder`/curried and a partial-application
     case — convert, lower, run native; assert results equal the direct-style
     reference interpreter (differential across floors).
  2. **Erasure:** a closure capturing a 0-quantity type param — assert the
     capture becomes no field (the converted cell has only runtime fields).
  3. **Linearity (negative):** a closure capturing `(1 s Sock)` used twice —
     assert the *existing* checker rejects it (no lowering needed; the rejection
     is the ownership claim).
  4. **Determinism (D-2):** two independent conversions of the same batch are
     byte-identical after lowering (the conversion is a pure function of the sig).
- **Green line:** 390 → **≥ 394**; `ledger-lint` clean; the existing pure/
  first-order suite stays green (conversion is a no-op on closure-free code).
- **Done when:** a pure curried/partial-application program compiles native via
  the conversion pass and matches its reference result, and a linear-capture
  duplication is a checker rejection.

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - *Effectful `apply-*` lowering* — the `=>` gate + `row_union` shadow →
    [[E70-effectful-lowering]] (the staged next; the coupling is §3 #5).
  - *Recursive closures* — §3 #4, a follow-on step within E69.
  - *Typed/existential (modular) environments* — → E57 staging (§3 #2).
  - *Grade seats on the capture record* — → [[E38]] (cost seats lower separately).
  - *Conversion certificate* — → [[E52]].
- **Coordination note (cluster):** Steps 3 (E69, quantities) and E70 (the row
  shadow) both extend the **same typed tal signature** (`tal.py` `fn_sigs` /
  the E18 typed IR). The two specs must land compatible signature fields —
  quantities (E69) beside the row (E70). Flagged so the E70 spec reuses, not
  re-invents, the extended-signature carrier.
- **Implementation notes (validated against the code 2026-08-02):**
  - The three rejection sites the pass must eliminate *before* `lower.py` sees
    the term: `expr` `App`-with-non-Global/Prim head (`lower.py:274`, higher-order
    call), `len(spine) != len(doms)` (`:276`, partial application), and a nested
    `Lam` term (`:284`). `fn` (`:125`) peels only the top-level lam chain.
  - **Quantities `q=1` is port-coupled, not a pure slice** (probed): pure ops
    use their args at ω, so a `(1 x I64)` binder fails the checker
    (`binder x declared 1 but used w`). Linear params are really ports (E70).
    So Step 3's *testable* payoff is `q=0` erasure, and that erasure must be
    **sig-level and consistent** (drop the erased param at the def AND the arg at
    every call site) — there is no `lower.py`-local slice, because the dropped
    fn-sig loses which spine positions were erased. Both `q=0` erasure and
    closures therefore land *in* `closconv.py` (the sig-level pass), not as a
    gate tweak. Build order within E69: `closconv.py` first (it is the
    prerequisite for a testable increment), then the `:300` relaxation rides it.
- **Follow-on / links:** [[E70-effectful-lowering]] (mutual dependency — E69
  makes calls concrete, E70 lowers their rows), [[E39-effect-row]] (the law
  this makes structural), [[E16-lowering]] (the pipeline extended),
  [[E3]]/[[E15-reference-interpreter]] (NbE — the closure-heavy customer),
  [[E5]] (the semiring the capture records carry), EDGE-CANDIDATES C3.
