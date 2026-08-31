---
element: E12
slug: effect-membrane
title: Effect membrane rules (pure `->` vs process `=>`)
kind: SELF-HOST
example: examples/E12-effect-membrane.md
status: audited
updated: 2026-08-01
---

# E12 SPEC — Effect membrane rules (pure `->` vs process `=>`)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** a new `scaffold/lib/effects.chiral` carrying the **three
  membrane rules** in chirality source — `on-apply-ok`, `on-binder-ok`,
  `erased-allow` — written as pure, total functions over the effect-row algebra
  (`row-empty`/`row-sub`/`row-join`) plus the QTT quantity, that, run on the RT
  interpreter, reproduce the verdicts of `scaffold/chirality/effects.py`'s `Rules`
  (`on_apply:23`/`on_binder:38`/`erased_allow:46`): reject a callee whose row is
  not contained in the context's permitted row, force an erased (q0) position to
  the empty row, and reject a linear-kind type bound at quantity ≠ 1.
- **Non-goals (residue → §6):**
  - **The row carrier itself** — `Row`/`Seats`/`row_subsumes`/`row_union` are
    **E39**'s built artifact (`scaffold/chirality/row.py`); its chirality self-host is
    E39's. E12 ports the *rules that consult* the algebra, over a minimal
    concrete `Row` stand-in for the differential (decision #1); E39 swaps the
    full carrier (rowvar / `ROW_DYN` / `Seats`) under the same rules.
  - **Handlers / effect discharge** — E39's verified CPS elaboration; the
    membrane only *gates*, it interprets nothing.
  - **`is-linear`** — the linear-kind decision is **E8** (`kernel.py:is_linear`
    `:208` + `data.py:_linear_data` `:77`); the membrane *consumes* it.
  - Does **not** delete or wire-in `effects.py`; it stays the bootstrap rules
    **and** the differential oracle. Does **not** touch the kernel (the rules
    live in the `effects` module the kernel consults at its 3 seams, not in it).

## 2. Baseline (what already exists)

- **Conformance-map verdict — and a snapshot-staleness to name:** the E12 row is
  `Effect membrane | CONFORMS · S · E12 | "One coarse pure/process bit at 3 seams
  … No work owed within E12's coarse-bit scope; upgrade tracked as E39."` That
  row is a **classification-time (2026-07-21) snapshot**: the *live* `effects.py`
  is **already row-based** — the E39 steps-1–6 build (2026-07-28) reshaped it, so
  `on_apply` now gates by `row_subsumes(seat.row, as_row(allow_row))`, not a
  boolean. The two are reconciled exactly as the map's own E39 row records
  ("effects.py gates by set-containment"). So E12's *placement* CONFORMS and its
  live *mechanism* is the E39 row — this SPEC ports the **rules** (E12) over the
  **carrier** (E39, built). The example's §3 boolean Python snippet is
  pre-E39 and superseded by the live code below.
- **Live code this composes with (do NOT respec):**
  - `scaffold/chirality/effects.py` — the golden oracle (row-based). `on_apply`
    (`:23`): `row_subsumes(seat.row, as_row(allow_row))` then `on_binder` on the
    param then `erased_allow`; `on_binder` (`:38`): `q != 1 and K.is_linear(...)`
    → reject; `erased_allow` (`:46`): `as_row(allow_row) if q != 0 else
    EMPTY_ROW`. `fty[2]` is a `Seats`, `seat.row` the `Row`.
  - `scaffold/chirality/row.py` — **E39's** built row algebra the rules call:
    `Row(names, rowvar)` (`:28`), `EMPTY_ROW` (`:42`), `row_union` (`:52`),
    `row_subsumes` (`:77`), `as_row` (`:68`), `ROW_DYN`, `Seats` (`:35`). The
    example's abstract `row-empty`/`row-sub`/`row-join` map onto
    `EMPTY_ROW`/`row_subsumes`/`row_union`.
  - `scaffold/chirality/kernel.py` — `is_linear` (`:208`, the E8 linear-kind walk the
    possession seam calls); the kernel consults `sig.rules` at its 3 seams
    (`on_apply`/`on_binder`/`erased_allow`).
  - `scaffold/lib/ports.chiral` — the frozen typed face for the cross-check:
    effectful externs are `=>` with per-family result sums (`sock-recv (=> (1 s
    Sock) (refine I64 (> 0)) RecvR)` `:62`), pure plumbing over ports is `->`
    (`RecvR` unpacking) — the "holding ≠ crossing" fixtures.
  - `scaffold/lib/prelude.chiral` — `Bool`/`Unit`/`List`/`Str`; comparisons
    `=i <i <=i` only.
- **True delta = one new library file's three rules.** effects.py is 52 lines;
  E12's *new* content is the three rule functions in chirality over the row algebra +
  a `Qtt` (`q0`/`q1`/`qw`), plus a minimal concrete `Row` stand-in
  (decision #1) so they run against the oracle. The rules are
  **representation-agnostic** — this is why the port is not work E39 redoes: E39
  supplies the concrete `Row`, not the rule bodies.

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls:
RESOLVED only when derivable from a settled source (cited); DEFERRED to a named
home; genuinely novel design → NEEDS-AUTHOR, surfaced never answered.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | **Row representation** for the runnable port — abstract algebra survives E39's choice, but what does the differential run on? | **RESOLVED — minimal names-list stand-in; E39 swaps the full carrier** | Engineering scoping call (as E10 #4 / E11 #3): model `Row` = `(List Str)` (crossing names), `row-empty` = `nil`, `row-sub` = subset, `row-join` = dedup-union — mirroring `row.py`'s names-based `row_subsumes`/`row_union` for the empty/nonempty/containment verdicts the membrane decides. The full carrier (`rowvar`/`ROW_DYN` row-polymorphism, `Seats`) is **E39**'s (`row.py`); the rule bodies are unchanged when it swaps in. Not author-tier — a representation choice the example explicitly designs to survive. |
| 2 | **Row representation & row-variable surface, declared-row syntax** at module/profile boundaries. | **DEFERRED → E39** | `decision-effect-facets` (2026-07-21, settled) resolves the *mechanism*; the concrete row shape + rowvar seat is E39's built carrier (`row.py`, the `sig.def_rows` artifact). The one-bit-or-row question the example used to carry is closed; representation is E39's. Nothing E12 binds depends on E39's unbuilt residue (row polymorphism). |
| 3 | **How are the rules *called*** by a kernel still partly Python during bootstrap — a category-C bridge, or wait for E3/E4? | **DEFERRED → checker self-host (E3/E4)** | The rules' call sites are `infer`/`check` (`kernel.py`, E3/E4). Same pattern as E10/E11: the chirality rules + their differential are deliverable now; **wiring them onto the live `sig.rules` seam rides the whole checker self-host** (the Python `Rules` stays the bootstrap gate meanwhile). No bridge is built by E12; the port is validated against the oracle, not swapped into the live checker. |
| 4 | **Where does `is-linear` live** so membrane and data layer agree without a cycle? | **RESOLVED — E8's, consumed one-way** | `is-linear` is the linear-kind decision (`kernel.py:is_linear:208` + `data.py:_linear_data:77`, **E8**). `on-binder-ok` *consumes* it (takes it as a supplied function / imports the E8 layer); the dependency is one-way (membrane → kind layer), so no cycle. Derivable from the outlines (the membrane calls `K.is_linear`; the kind layer never calls the membrane). |

All dispositioned; none blocking. `status: draft` (not blocked).

## 4. Change plan (ordered, commit-sized)

### Step 1 — the row-algebra stand-in + `Qtt`
- **Target:** `scaffold/lib/effects.chiral` (new) — `(import "prelude")`; `Row`
  = `(List Str)` alias, `row-empty`/`row-sub`/`row-join` (subset / dedup-union),
  `row-pure?`; `data Qtt` (`q0`/`q1`/`qw`).
- **Change:** the example §5 algebra, instantiated at the names-list rep
  (decision #1); `row-sub`/`row-join` structural-recursive on the list (total).
- **Size:** ~S

### Step 2 — the three rules
- **Target:** `effects.chiral` — `on-apply-ok (-> Row Row Bool)` (= `row-sub
  callee here`), `erased-allow (-> Qtt Row Row)` (`q0` → `row-empty`, else the
  permitted row), `on-binder-ok (-> Qtt Ty Bool)` over an `is-linear` the file
  imports/takes (decision #4).
- **Change:** verbatim from the audited example §5, over the Step-1 rep. Already
  syntax-legal (`case`, no value-`if`).
- **Size:** ~S

### Step 3 — differential test file
- **Target:** `scaffold/tests/test_effects_chirality.py` (new; leave the Python
  membrane tests untouched).
- **Change:** load `lib/effects.chiral`, drive the three rules with the `apply1`
  RT harness. Assert against `effects.py` verdicts: (a) a nonempty-row callee vs
  an empty (`->`) context → reject (matches `row_subsumes(nonempty, EMPTY)` =
  False); (b) `erased-allow q0 r` = `row-empty` (matches `erased_allow` returning
  `EMPTY_ROW`); (c) a linear `Ty` at `qw`/`q0` → reject, at `q1` → accept
  (matches `on_binder` `q != 1 and is_linear`). Drive `effects.py` live (build a
  `Seats`/`Row`, call `Rules().on_apply`/`erased_allow`) as the oracle.
- **Size:** ~M

## 5. Conformance gate

- **Golden behavior:** the three chirality rules return the same verdict the live
  `effects.py` `Rules` do, read through the empty/nonempty/containment projection
  the built `row.py` already uses: (a) `on-apply-ok here callee` ⇔ `row_subsumes`
  (a nonempty callee in an empty context is rejected — "effectful application
  inside a pure function"); (b) `erased-allow q0 _` = `row-empty` ⇔
  `erased_allow` → `EMPTY_ROW`; (c) `on-binder-ok q ty` rejects a linear `ty` at
  q ≠ 1 ⇔ `on_binder`. Cross-check the *intent* against `lib/ports.chiral`:
  `sock-recv` (row `{sock-recv}`) is not `->`-callable, while a pure `RecvR`
  repack (row empty — holding ≠ crossing) is.
- **Floors compared:** the **chirality RT interpreter** running `effects.chiral` vs
  the **Python `effects.py`/`row.py` oracle** driven live — lib-level
  chirality-vs-golden (`test_json.py` shape), not native/tal. Row-polymorphism
  (`ROW_DYN`/rowvar) subtleties are **E39**'s gate, not exercised here.
- **Green line:** 355 → ≥ 355 + k (the new `test_effects_chirality.py` functions);
  full suite stays green, `effects.py`/`row.py` unchanged, ledger-lint clean.
- **Done when:** `test_effects_chirality.py` passes — the three chirality rules match the
  live `effects.py` verdicts on the containment / erasure / linear-binder cases,
  over the names-list `Row` stand-in.

## 6. Residue & links

- **Deliberately unbuilt:**
  - **The row carrier's self-host** (`row.py` → chirality: `Row`/`Seats`/`row_subsumes`
    /`row_union`, rowvar, `ROW_DYN`) — **[[E39-effect-row]]**. E12's names-list
    stand-in (decision #1) is swapped for it; the rules are unchanged.
  - **Handlers / effect discharge** (verified CPS elaboration) — **[[E39-effect-row]]**;
    alarms-as-crossings — **[[E26-alarm-control-flow]]**.
  - **Wiring the rules onto the live `sig.rules` seam** and retiring the Python
    `Rules` — rides the checker self-host (**E3/E4**); decision #3.
  - **The row's tal shadow** (lowering this membrane to the floor) — **[[E70]]**.
  - Totality of divergence in an erased position — the totality gate
    (**[[E11-totality-checker]]** / edge 9), named by the example, not modeled here.
- **Follow-on:** contributes the membrane rules to the self-hosted checker stack;
  pairs with [[E39-effect-row]] (carrier), [[E08]] (`is-linear`), [[E05]] (the
  QTT quantities `erased-allow`/`on-binder` read).
- **Related:** [[E12-effect-membrane]] (rationale) · [[E39-effect-row]] (the row,
  the reshape, handlers) · [[E26-alarm-control-flow]] (alarms as crossings) ·
  [[E03-nbe-normalize]]/[[E04-bidir-universes]] (the `infer`/`check` call sites) ·
  [[E70]] (the row's tal shadow) · `docs/decision-effect-facets.md` (the settled
  two-facet mechanism).
