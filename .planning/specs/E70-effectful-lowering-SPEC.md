---
element: E70
slug: effectful-lowering
title: Effectful lowering: the effect row's tal shadow + preserve-check over the effect claim, making `=>` arrows lowerable (the compiler is effectful — self-hosting cannot go native without this)
kind: BUILD-PROPER
example: examples/E70-effectful-lowering.md
status: audited
updated: 2026-08-02
---

# E70 SPEC — Effectful lowering: the effect row's tal shadow + preserve-check

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.
>
> **Staging (author call 2026-08-02): E69 first, then E70 (this).** E69 already
> defunctionalized every higher-order call to first-order `data`+`case`, so by
> the time E70 runs, a lowered body's calls are all to **named functions with
> precise rows** — the footprint re-derivation never meets an indirect call or a
> DYN row. That is what makes the static check below sound and simple.
>
> ---
> **⚑ IMPLEMENTATION-READY (2026-08-02 — READ THIS FIRST, then follow the E70
> DESIGN §7b build order).** E69 is landed (410 green); E70 was scoped against the
> live substrate and three findings supersede parts of §3–§5's original phrasing.
> The DESIGN doc's §7b (Findings + the (a)–(f) build order) is the authoritative
> implementation plan; the corrections:
> 1. **The row check is the EFFECTFUL PROJECTION, not full `def_rows`** — Decision
>    §6#2 / DESIGN §6#2 "keep pure prims" is **unsound now that E69 conversion is
>    real**: a defunctionalized pure `->` fn (e.g. `apply-it`) statically reaches
>    pure prims (`+`) its pre-conversion `def_rows` never named → a full-`def_rows`
>    check false-`row-escape`s it (verified). Check `reachable EFFECTFUL crossings
>    ⊆ declared EFFECTFUL row` (the Pi seat = `def_rows ∩ port-crossings`).
> 2. **The check runs on the lower.py tal IR (UPPER vocab)** — `prim +`,
>    `call <def>`; the `nb-*`/PRIM2LIB floor translation is native-only (§7's
>    many-to-one inversion does NOT arise at `check_fn`). `def_rows` is the
>    transitive LEAF-crossing set: `call <def>` contributes `def_rows[def]`.
> 3. **The emission crux + its DE-RISK.** A crossing is refused today only because
>    ports are excluded from `prim_sigs`. Keep it a `prim <crossing>` in the tal IR
>    (add a `crossing_sigs` table so `check_fn` accepts it — Str==Bytes so no rep
>    cast) and route it in `native.py` (`prim put` → `ti-call wrap-put` + synthesize
>    `Unit` from the byte-count). **RISK POINT RESOLVED: native syscall codegen
>    already exists** (`nb-sys-*` in `sys-tal.chiral` via `ti-sys`, compiled into
>    every emission, tested); step (c) is just **relaxing the `native.py:478`
>    membrane to admit the `wrap-*` wrappers** into the native lib (they compile
>    for free). This makes E70 a moderate wiring effort, not a large integration.
> Green line concretely: current baseline **410 → ≥ 414** (the §5 "+4"). Land
> (a)–(f) as one tested commit per step; the pure baseline stays green (additive,
> gated behind the `=>` gate). Differential-test `put`/`print` stdout vs the interp.
> ---

## 1. Deliverable

- **After this runs:** the `=>` eligibility gate (`lower.py:298`) opens — an
  effectful function lowers exactly like a pure one, its crossings compiling to
  calls into the E51 binding-table wrappers. The typed tal signature gains a
  **row shadow** (the tal image of E39's `Row.names` — a canonical sorted
  crossing-name set, populated from `sig.def_rows`), sitting beside E69's
  quantities field on the same carrier. `preserve-check` (`tal.py` `check_fn`)
  grows a **second obligation**: re-derive, from the compiled body alone, the
  set of crossings transitively reachable (calls into E51 wrappers → upper name
  via the binding table; calls into other tal functions → their shadows;
  outlined helpers → computed bottom-up) and demand **reachable ⊆ declared**
  (`row_subsumes`), rejecting the module at the floor otherwise. Net: the
  compiler's own effectful, (now-defunctionalized) code lowers to native with
  its effect claim carried down **checked**, the same way its type is.
- **Non-goals:** row polymorphism / a live DYN row at the floor (never arises —
  E69 defunctionalized its only source); grade shadows (E38, cost seats lower
  separately); alarm-payload representation at the floor; the `runtime.py`
  dispatch refactor (E51's implementation run); closure conversion itself (E69,
  the prior stage). Optimizer passes need **no change** — their outputs re-enter
  the extended check by construction.

## 2. Baseline (what already exists)

- **Conformance-map verdict:**
  - *"Effect algebra / typed rows" — E39, carrier edit BUILT 2026-07-28:* Pi
    pos-2 is the frozen `Seats(row, …)` (`row.py`); rows are call-graph-inferred
    at elaboration into a deterministic canonical sorted form, and
    **`sig.def_rows` is named "the E51/E70 artifact."** Non-spine `=>` carry the
    DYN row; the rowvar seat is frozen (row polymorphism is not this element).
    So the *upper* row E70 shadows is already built and stored — E70 carries it
    down and re-derives-and-checks at the floor.
  - *"DDC harness" — E53:* explicitly *"true Stage1==Stage2 fixpoint + leg-running
    are E70-gated."* E70 is the gate that unblocks the fixpoint (the compiler
    must lower to run natively).
- **Live code this composes with (do NOT respec):**
  - `row.py` — `Row` (canonical sorted `names` + reserved `rowvar`),
    `row_subsumes` (the `reachable ⊆ declared` test, DYN-aware), `row_union`
    (the merge E69's `apply-*` rows use). E70 re-uses these at the floor; it
    does not re-derive set-containment.
  - `sig.def_rows` — the per-def inferred upper row (the declared shadow source).
  - `lower.py:298` — the `=>` rejection (`Ineligible("effectful …")`). **This
    SPEC opens exactly this line.** The eff seat is already peeled and visible
    (`_peel`, `:73`).
  - `tal.py` `check_fn` — today re-checks the tal image of the declared *type*.
    E70 adds the row re-check beside it. `TalFn.sysface` (the one-bit prototype)
    generalizes into the sys-family projection of the shadow.
  - E51 binding table (`build_sys_linkage`, `native.py:640`) — `sys-bindings` =
    `{extern-name → wrapper-name}`; wrappers hold the `sys` ops, lowered `=>`
    bodies *call* the wrappers. The mapping witness the check spans.
  - E69's quantities field on the typed tal signature — E70 adds the row field
    to the **same** carrier (§6 coordination).
- **True delta:** (a) the row-shadow field on the typed tal signature; (b) the
  `tal_row_check` re-derivation + `row_subsumes` gate inside `check_fn`;
  (c) the one-line gate relaxation at `lower.py:298` (lower `=>` carrying its
  `sig.def_rows`); (d) `sysface` re-derived as the sys-family projection.

## 3. Decisions

Every open question from the example §6, dispositioned. Most were resolved from
the built substrate at the example-audit; carried here with citations.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Which vocabulary the shadow speaks. | **RESOLVED: check across the table.** | Shadow in upper crossing names (`sig.def_rows`, canonical sorted); body in floor symbols (wrapper calls / `nb-sys-*`); the E51 `bind-sys` table is the mapping witness, itself re-checked (not trusted). Confirmed by `row.py` + the E51 binding table. |
| 2 | Transitive shadows for outlined (non-tail) functions. | **RESOLVED: computed bottom-up.** | `lower.py:313` already re-checks the synthesized `low.extra` functions; the row check computes their reachable set (no user declaration exists) and carries it, while verifying user defs against their declared `sig.def_rows`. |
| 3 | `halt`/alarm crossings — implicit in every shadow, or explicit? | **RESOLVED: explicit.** | `halt` is an ordinary extern (`effects.py`: "nothing special-cases them"; E26 alarms-as-crossings), so it enters a shadow only when actually reachable. |
| 4 | DYN row at the floor. | **RESOLVED: never arises.** | The only source of DYN (`"*"`) is a higher-order `=>` in a non-spine position; E69 (staged first) defunctionalizes it to concrete precise-row calls before E70 runs. So the floor shadow is always a precise crossing-name set — E70 need not represent DYN at all. |
| 5 | `sysface` after the row lands. | **RESOLVED: sys-family projection.** | `sysface` is re-derived as `row ∩ sys-family ≠ ∅` — the backend's refusal is unchanged in behavior, now a projection of the richer shadow rather than a separate bit. |
| 6 | E70/E69 co-sequencing (the example's one FLAG). | **RESOLVED by the staging call: E69 first.** | E69 lands the defunctionalization; E70 then lowers the resulting first-order effectful code (incl. E69's `apply-*`, whose rows are `row_union` over their arms). E70 alone additionally covers *first-order* effectful defs. Neither is a blocker to the other's *spec*; the build order is E69 → E70. |

No NEEDS-AUTHOR blockers.

## 4. Change plan (ordered, commit-sized)

### Step 1 — the row-shadow field on the typed tal signature
- **Target:** `tal.py` (the typed signature / `fn_sigs` carrier; the E18 typed
  IR) — add a row field beside E69's quantities field.
- **Change:** carry `sig.def_rows[name]` (a `Row`) onto the tal signature at
  lowering; pure functions get the empty row. No new tal *term* forms (the row
  is signature metadata, not an instruction).
- **Size:** ~M.

### Step 2 — the row obligation in `preserve-check`
- **Target:** `tal.py` `check_fn` (+ a `tal_row_check` helper).
- **Change:** after the existing type re-check, walk the body: for each `call`,
  map a wrapper-callee through the E51 binding table to its upper crossing name,
  or union a tal-function callee's shadow (computed for `low.extra`); union
  direct crossings; then `row_subsumes(reachable, declared)` or raise a
  `row-escape` alarm naming the function and the offending crossing.
- **Size:** ~M.

### Step 3 — open the `=>` gate
- **Target:** `lower.py:298`.
- **Change:** replace the effectful rejection with: if `sig.def_rows[name]` is
  available, lower the `=>` body like a pure one (crossings are ordinary calls
  to E51 wrappers) and attach the row (Step 1). The body is then held to the row
  by Step 2's re-check in `lower_all`'s existing `check_fn` call.
- **Size:** ~S.

### Step 4 — `sysface` as the sys-family projection
- **Target:** `tal.py` (`TalFn.sysface` derivation) + the backend refusal site.
- **Change:** compute `sysface` as `row ∩ sys-family ≠ ∅` instead of the
  standalone bit; assert no behavior change on the existing sys-library refusal.
- **Size:** ~S.

## 5. Conformance gate

- **Golden behavior:** effectful functions lower and run with observables
  identical to the interpreter path; every currently-lowered pure function
  re-checks with row `{}` unchanged; a lowering/optimizer output that reaches a
  crossing its declared row does not name is **rejected** at the floor
  (`row-escape`); `sysface` re-derives exactly as the sys-family projection (no
  backend refusal change).
- **Tests to add (`scaffold/tests/test_effectful_lower.py`, NEW):**
  1. **Positive (first-order):** a first-order effectful def (e.g. `log-line`
     calling `fd-write`) lowers; native observables equal the reference
     interpreter (differential across floors).
  2. **Positive (post-E69):** an effectful `apply-*` from E69's conversion
     lowers, its shadow = `row_union` of the arms (depends on E69 landed).
  3. **Negative (the point):** hand-construct a lowered body that calls a
     wrapper its declared row omits → assert `check_fn` raises `row-escape`
     naming the fn + crossing (a lowering/optimizer bug is a floor alarm).
  4. **Pure unchanged:** every currently-lowered pure function re-checks with
     row `{}`; `sysface` projection matches the old bit on the sys library.
  5. **Determinism (D-2):** the row re-derivation is order-independent (the
     shadow is a canonical sorted set).
- **Green line:** against the **post-E69 baseline** (E69 lands first per the
  staging), E70 adds tests 1, 3, 4, 5 (**+4**); test 2 (E69's `apply-*`
  lowering) rides E69's conversion being in, so it may already be exercised by
  E69's suite. `ledger-lint` clean; the pure suite stays green.
- **Done when:** a first-order effectful function compiles native and matches
  its reference observables, and an undeclared-crossing body is a floor
  rejection. (The closure-heavy effectful fragment rides E69 being landed.)

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - *Row polymorphism / rowvar at the floor* — not needed (Decision #4); stays
    reserved in `row.py` until upper-level row polymorphism (post-cluster).
  - *Grade shadows* — → [[E38]] (cost seats lower separately).
  - *Alarm-payload representation at the floor* — rides E26's alarm machinery.
  - *`runtime.py` dispatch refactor* — E51's implementation run.
- **Coordination note (cluster):** the row field (this SPEC, Step 1) and E69's
  quantities field extend the **same typed tal signature carrier**. Implement
  E70 Step 1 by *extending* the carrier E69 introduced, not a parallel one —
  one extended tal signature holds both quantities (E69) and the row (E70).
- **Follow-on / links:** [[E69-closure-conversion]] (the prior stage — makes
  calls concrete so this footprint applies; its effectful `apply-*` are this
  SPEC's positive test #2), [[E39-effect-row]] (the upper row this shadows —
  `sig.def_rows`, `row_subsumes`, `row_union`), [[E51-sys-linkage]] (the binding
  table the check spans), [[E18-tal-check]] (the checker gaining the obligation),
  [[E72-re-bootstrap]] (the fixpoint this unblocks), [[E16-lowering]] (the
  pipeline extended).
