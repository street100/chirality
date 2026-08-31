---
element: E16
slug: lowering
title: Lowering: pure→tal, register/slot alloc, non-tail case outlining, preserve-check
kind: SELF-HOST
example: examples/E16-lowering.md
status: audited
updated: 2026-08-01
---

# E16 SPEC — Lowering: pure→tal, register/slot alloc, non-tail case outlining, preserve-check

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** a new `scaffold/lib/lower.chiral` carrying the **lowering
  connector** in chirality source — the eligibility gate (`eligible?`), the type
  lowerer (`ttype`), the body compiler (`compile-fn`: SSA emit + non-tail-`case`
  outlining), and `lower-all` — as pure, total `->` functions that **return a
  result sum** (`low-ok` / `low-skip reason`) instead of raising `Ineligible`,
  and whose every emitted `TalFn` is run back through `check-fn` (the tal
  preserve-check). Run on the RT interpreter it reproduces
  `scaffold/chirality/lower.py`'s `lower_all` (`:287`) **partition** — the identical
  `lowered` set and identical `skipped` reasons — for the same `Sig`.
- **Non-goals (residue → §6):**
  - **The tal data + checker it consumes** — `TalTy`/`Instr`/`TalFn` and
    `check-fn` are **E18**'s (`tal.py`); their chirality self-host is E18's, so the
    *full runnable* emission+preserve-check differential rides E18 (§2 coupling).
  - **The register/slot packing pass** — E16 emits SSA (fresh reg per bind); the
    packing/allocation pass is a separate downstream tal→tal transform (E17's
    optimizer family or its own element), decision #1.
  - **Widening eligibility** — closures / higher-order / partial application and
    `0`/`1`-quantified binders stay **upper** (map row: "widening is separate
    forward work"), decision #3.
  - Does **not** delete or wire-in `lower.py`; it stays the golden oracle for the
    partition differential.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** `Lowering connector + preserve-check | CONFORMS ·
  S · E16 | "pure→tal, reg/slot alloc, non-tail case outlining, re-check at floor;
  Fully built; monotonic single-assignment slots, lower_all holds body to declared
  type via tal.check_fn. Narrow eligibility (pure, non-dependent, ground) is the
  honest scaffold slice; widening (closures/HO) is separate forward work."`
  CONFORMS ⇒ faithful transcription of a complete artifact.
- **Live code this composes with (do NOT respec):**
  - `scaffold/chirality/lower.py` — the golden oracle. `lower_all` (`:287`) is the
    partition driver (install sig → `Low.fn` → `tal.check_fn` → collect
    lowered/skipped); `ttype` (`:29`) is the type lowerer; `Low` (`:107`) is the
    body compiler — `fresh` (`:116`, fresh reg per bind = SSA), `fn` (`:125`),
    `tail` (`:138`), `expr` (`:172`, non-tail-`case` outlining); `Ineligible`
    (`:23`) is the raise this port turns into a `low-skip` value; `prim_sigs`
    (`:87`).
  - **E18's tal (the connector's counterpart, consumed not respec'd):** `tal.py`
    `check_fn` (the preserve-check), `TalFn`/tal types. E18 is `drafted` (not yet
    self-hosted), so `lib/lower.chiral`'s `compile-fn` output + `check-fn` call
    ride E18's tal-in-chirality — **the coupling this SPEC scopes around** (the
    partition logic is testable now; the emission+preserve-check differential
    lands when E18 self-hosts). Keep `check-fn`/`TalFn` as E18's; do not respec.
  - `scaffold/lib/prelude.chiral` / `collections.chiral` — `List`/`Pair`/`Maybe`,
    `and`/`or`/`not`, `=i`, structural folds; comparisons `=i <i <=i` only.
  - Mutual/forward `data` (**E79**, built) — for any `TalTy`↔`Instr`↔`TalFn`
    forward references in the shared tal ADT.
- **True delta = one new library file's connector.** The wins over `lower.py`:
  the connector is a pure `->` transform (it *cannot* do I/O — "the compiler
  quietly reached out" is untypeable), eligibility failure is a `low-skip` value
  in the return type (not a raised `Ineligible`), and it is Category-C — its
  output is re-validated by the independent `check-fn`, so a connector bug
  degrades to a caught `low-skip`, never to unsound tal.

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls:
RESOLVED only when derivable from a settled source (cited); DEFERRED to a named
home; genuinely novel design → NEEDS-AUTHOR, surfaced never answered.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Where does the **register/slot packing** pass live (E16 emits pure SSA; packing deferred)? | **RESOLVED — not E16; a downstream tal→tal pass → E17/optimizer family** | The example §2 + map both fix E16's contract as *SSA emit* (`Low.fresh` = fresh reg per bind), with packing "deferred to a later tal optimizer pass." A tal→tal packing/allocation transform is the optimizer family's shape ([[E17-optimizer]]); whether it rides E17 or spins its own element is a minor downstream call, but it is **not E16's** — E16's output being SSA + preserve-checked is the settled slice. DEFERRED → [[E17-optimizer]] (or a dedicated alloc element). |
| 2 | The exact chirality surface for **outlined-function synthesis** (naming, threading live registers). | **RESOLVED — mirror `lower.py`** | OURS `Low.expr` (`:172`) already fixes it: a non-tail `case` becomes a synthesized `TalFn` named `name$k`, whose params are the enclosing live registers plus the scrutinee, emitted and preserve-checked **alongside** the parent. The port reproduces that scheme (the `name$k` convention + live-regs-as-params); a mechanical transcription of a built behavior, not a new design. Owner: this element, per `lower.py:expr`. |
| 3 | Do **`0`/`1`-quantified binders** ever lower, or stay permanently upper? | **RESOLVED — stay upper (matches OURS); widening is separate work** | The map row is explicit: "Narrow eligibility (pure, non-dependent, ground) is the honest scaffold slice; **widening (closures/HO) is separate forward work**." OURS `lower_all` rejects `q != W` and effectful arrows. The port mirrors that gate; lowering selected linear binders is a future eligibility widening (its own element), not E16. Derivable from the map + `lower.py`. |
| 4 | *(coupling, surfaced by the bundle)* E18's tal (`TalFn`/`check-fn`) is **not yet self-hosted** — what is runnably testable now? | **RESOLVED — partition now; emission+preserve-check ride E18** | Like E10/E12's stand-in coupling: the **partition logic** (`eligible?` + `skip-reason` + `lower-all`'s lowered/skipped split) is self-contained and differentiable against `lower.py`'s partition today. The **tal emission** (`compile-fn`) + the `check-fn` call consume E18's tal-in-chirality, so their full differential lands when E18 self-hosts. Engineering scoping call; the E18 hand-off is named. |

All dispositioned; none blocking. `status: draft`.

## 4. Change plan (ordered, commit-sized)

### Step 1 — data shapes + eligibility gate
- **Target:** `scaffold/lib/lower.chiral` (new) — `(import "prelude")`; `TalTy`/
  `Instr`/`TalFn` (or import E18's when it lands), `LowRes` (`low-ok`/`low-skip`),
  `Binder`, and `eligible?` + `ground?`/`skip-reason` helpers.
- **Change:** the example §5 decls + the fixed `eligible?` (`case`-on-Bool, not
  value-`if`); the gate rejects effectful and `q != W` (decision #3). All
  declares before defs (mutual group).
- **Size:** ~M

### Step 2 — `ttype` (type lowerer)
- **Target:** `lower.chiral` — `ttype (-> Sig UType (Opt TalTy))` + `ground?`.
- **Change:** port `lower.py:ttype` (`:29`) — upper ground type → `TalTy`, else
  `opt-none`. Structural over the type. Total.
- **Size:** ~S

### Step 3 — `compile-fn` (SSA emit + non-tail-case outlining)
- **Target:** `lower.chiral` — `compile-fn` + the fresh-register bookkeeping and
  the outlining synthesis (`name$k`, live-regs-as-params, decision #2).
- **Change:** port `Low.fn`/`tail`/`expr` (`:125`/`:138`/`:172`); fresh reg per
  bind (SSA); non-tail `case` → synthesized `TalFn` preserve-checked with the
  parent. Consumes E18's `TalFn` (coupling, decision #4). The largest piece.
- **Size:** ~L

### Step 4 — `lower-def` / `lower-all` (partition + preserve-check)
- **Target:** `lower.chiral` — `lower-def` (fixed: `case`-on-`pair` destructure,
  `case`-on-Bool gate, result sum) + `lower-all` (structural fold → lowered/
  skipped).
- **Change:** the example §5 `lower-def`/`lower-all`; each emitted `TalFn` runs
  through `check-fn` (E18), ok → `low-ok`, err → `low-skip` (a lowering bug lands
  as a caught skip). Total fold.
- **Size:** ~M

### Step 5 — differential test file
- **Target:** `scaffold/tests/test_lower_chirality.py` (new; leave `test_optimize.py`
  et al. untouched).
- **Change:** load `lib/lower.chiral`, drive `lower-all`/`eligible?` with the
  `apply1` RT harness over a fixture `Sig`. Assert the **partition** matches
  `lower.py.lower_all`: identical lowered-name set and identical skip reasons for
  a corpus (an eligible pure ground def; an effectful def → skip "effectful"; a
  `0`/`1`-quantified def → skip "quantified binder"; a non-ground def → skip).
  The full emission+`check-fn` differential is gated on E18 (decision #4) — until
  then assert `eligible?`/`skip-reason` parity, the self-contained half.
- **Size:** ~M

## 5. Conformance gate

- **Golden behavior:** for the same `Sig`, `lower.chiral::lower-all` reproduces
  `lower.py.lower_all`'s partition — identical `lowered` set, identical `skipped`
  reasons; `eligible?` accepts exactly the pure/unrestricted/non-dependent/ground
  arrows OURS accepts; no eligible def dropped, no ineligible def lowered. When
  E18's tal-in-chirality lands, **every** emitted `TalFn` (parents + outlined
  `name$k` extras) additionally passes `check-fn` (the preserve-check) — a
  connector bug surfaces as a `low-skip`, never as unsound tal.
- **Floors compared:** the **chirality RT interpreter** running `lower.chiral` vs the
  **Python `lower.py` oracle** (partition differential; the emission+preserve-check
  differential is E18-gated). Lib-level chirality-vs-golden, not native/tal.
- **Green line:** 355 → ≥ 355 + k (the new `test_lower_chirality.py` functions);
  full suite stays green, `lower.py`/`tal.py` unchanged, ledger-lint clean.
- **Done when:** `test_lower_chirality.py` passes — the chirality connector's partition
  matches `lower_all` on the corpus (eligible-lowered, and each skip reason), with
  the emission+preserve-check differential recorded as E18-gated.

## 6. Residue & links

- **Deliberately unbuilt:**
  - **Tal data + `check-fn` self-host** (`TalTy`/`Instr`/`TalFn`, the preserve-check)
    — **[[E18-tal-check]]**; the emission+preserve-check differential rides it
    (decision #4).
  - **Register/slot packing** pass — decision #1 → [[E17-optimizer]] / a dedicated
    alloc element; E16 emits SSA only.
  - **Eligibility widening** (closures / HO / partial application / lowering
    selected linear binders) — decision #3, separate forward work.
  - **`compile-fn`'s full body walker** — the mechanical SSA/outlining loop; the
    example elides it, this SPEC scopes it (Step 3) but flags it the largest piece.
  - Retiring `lower.py` and wiring `lower.chiral` into the toolchain — rides the
    checker self-host.
- **Follow-on:** the lowering half of the self-hosted compiler; pairs with
  [[E18-tal-check]] (its preserve-check judgment) and [[E17-optimizer]] (the
  tal→tal passes over its SSA output).
- **Related:** [[E16-lowering]] (rationale) · [[E18-tal-check]] (the tal checker /
  `check-fn` this calls — `tal.py`, NOT E15) · [[E17-optimizer]] (packing +
  tal→tal opts, decision #1) · [[E15-reference-interpreter]] (the golden semantics
  the preserve-check preserves) · [[E09-refinement]] (bounds on lowered I64) ·
  [[E24-i64-arith]] (the ground I64 floor).
