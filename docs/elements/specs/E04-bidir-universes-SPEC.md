---
element: E04
slug: bidir-universes
title: Bidirectional infer/check + universes/cumulativity
kind: SELF-HOST
example: examples/E04-bidir-universes.md
status: audited
updated: 2026-08-01
---

# E04 SPEC — Bidirectional infer/check + universes/cumulativity

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `scaffold/lib/kernel.chiral` (the file E3 creates) gains
  the chirality-source bidirectional judgment — `infer` / `check` / `subsume` /
  `subtype` over the shared `Term`/`Val` sums, returning **errors-as-values**
  (`TcR`/`CkR` result sums) and **QTT usage vectors** — differentially equal to
  `kernel.py`'s `infer`/`check`/`subtype` on accept/reject **and** usage-vector
  output for the closed-core fragment (var/type/pi/lam/app/ann).
- **Non-goals:** the effect-row `allow_eff` threading + the three membrane seams
  (`on_apply`/`on_binder`/`erased_allow`) → **E12**; `subtype`'s Pi
  row-subsumption case → **E39**; globals/prims/literals/`let`/`PrimTy` and the
  `ext_check` data hooks → **E6** / full-ADT assembly; refinement subtype hooks →
  **E9**; the `Qty` semiring ops (`u-add`/`u-scale`/`qfits`/`strip-binder`) →
  **E5** (consumed here by signature). This ports the **pure bidirectional +
  cumulativity skeleton**, not the membrane-wired full checker.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** the sole E4 row is **CONFORMS, size S** — "Built;
  `Type l:Type l+1`, cumulativity via subtype, rules via sig.rules … No universe
  polymorphism (not a scaffold goal); frame holds." A self-host transcription of
  a correct reference, not a behavior change.
- **Live code (the reference being ported, do NOT respec):**
  - `kernel.py:400 infer`, `:483 check`, `:321 subtype`, `:531 expect_universe`,
    `:538 strip_binder`, `:545 close_binder` — the functions this transcribes.
  - **The QTT app rule** `uadd(uf, uscale(q, ua))` (`kernel.py:455`) and the
    binder-exit audit `qfits(used, q)` (`:540`) — usage-vector semantics whose
    ops are **E5**'s, consumed by signature.
  - **The type-level-Pi-smuggle re-enforcement** — `check` on `Lam` re-runs
    `on_binder` (`kernel.py:491–496`) because a `VPi` from type-level computation
    bypasses formation. A named golden case (§5).
  - **The dependent-codomain eval guard** — `App` evaluates the argument only if
    `uses_below(fty[5][1], 1)` (`kernel.py:451`), else uses a fresh neutral;
    avoids getting stuck on runtime recursion. `uses-below` is **E13** (audited),
    consumed here.
  - **E3** (audited this pass) provides `eval`/`capply`/`conv` and the base
    `Term`/`Value`/`Clos`/`Neut` sums in the same `lib/kernel.chiral`.
- **True delta:** E4 **extends** E3's `lib/kernel.chiral` data block (adds `t-ann`,
  quantities on binders, `Ctx`, and the `TcR`/`CkR` result sums) and adds the
  three judgment functions + `subtype`. As with E3, the example's `(eff Bool)` on
  `t-pi`/`v-pi` is a **pre-E39 snapshot** — replaced by the opaque `Seat`+`seat=`
  E3 already established (decision #2).

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | **Totality of `conv`** — conversion under evaluation is not structurally decreasing; fuel measure vs trusted-total (Category C)? | **DEFERRED → E3 (decision #1).** | E4's own `infer`/`check`/`subsume` **are** structurally recursive on `Term` (E11 structural-total); the sole non-structural part is the `conv`/`eval` seam, which is **E3's** code. E3's audited SPEC already carries this exact question as its NEEDS-AUTHOR TCB-totality-posture call (mark the NbE core `partial` vs trusted-total by an SN axiom). E4 consumes `conv` by signature and inherits E3's resolution — no separate call owed. |
| 2 | **Effect seat + `allow_eff` threading** — example's `(eff Bool)` and dropped effect param vs the live `Seats` record + row-threaded `allow_eff`. | **RESOLVED (seat) → opaque `Seat`+`seat=` (E3 pattern); DEFERRED (threading + membrane) → E12.** | Same E39 baseline correction E3 applied (`kernel.py:298`, `row.py:35`). The `allow_eff`→Row threading and the three membrane seams (`on_apply`/`on_binder`/`erased_allow`, `kernel.py:437/447/459`) are **E12's** — the example itself omits them ("the effect-allowance parameter threading" is deliberately omitted). E4 ports the effect-agnostic skeleton with the membrane calls as **declared seams** whose bodies live in E12's `lib/effects.chiral`. |
| 3 | **`sig` seam table representation** (ext-check hooks, subtype hooks, membrane rules) — record of function values vs compile-time module wiring? | **DEFERRED, decomposed by home.** | Not one call: membrane rules → **E12**; refinement subtype hooks → **E9**; `ext_check`/data-former hooks → **E6**; the effect-row threading → **E39**. Same "hook mechanism deferred to its home / full-ADT assembly" disposition as E3 decision #4. The *representation* choice (function-value record vs module wiring) lands with whichever home first needs a live hook, not here. |
| 4 | **`TcR`/`CkR` twins vs one shared polymorphic `Result`.** | **RESOLVED → keep the twins for the port.** | `infer` returns `(ty, use)`, `check` returns `use` — genuinely different success payloads, so the twins are not the same type instantiated twice; they make the errors-as-values coverage story explicit and match the example. A shared `(Result E A)` **is** expressible (chirality has polymorphic data — `List T`, `reverse T`), recorded as a non-blocking ergonomics refactor (§6), not a blocker. Decidable → decided. |
| 5 | **`Qty` field type** — E3's `lib/kernel.chiral` binders carry an `I64` quantity placeholder; E4's example carries a `Qty` sum (`q-zero`/`q-one`/`q-many`). | **DEFERRED → E5 (owns the semiring type); E4 declares `Qty` + ops as E5 seams.** | The quantity type + its semiring ops (`qadd`/`qmul`/`qjoin`/`qfits`, `kernel.py:65–91`) are **E5**'s element. E4 writes `infer`/`check` against a declared `Qty` sum and E5-owned `u-add`/`u-scale`/`qfits`/`strip-binder`, consumed by signature. **Integration note:** E3's I64 placeholder and E4's `Qty` sum converge to E5's canonical `Qty` when the shared ADT assembles; recorded so `lib/kernel.chiral` stays coherent across E3→E4→E5. |

No NEEDS-AUTHOR of E4's own (decision #1 is inherited from E3, already surfaced).
Frontmatter `status: draft`; the change plan is fully unblocked.

## 4. Change plan (ordered, commit-sized)

### Step 1 — extend the shared data layer
- **Target:** `lib/kernel.chiral` — the `data` block E3 created.
- **Change:** add `t-ann` to `Term`; carry a `Qty` (E5 seam, decision #5) on
  `t-pi`/`t-lam` binders and `v-pi`/`v-lam`; add `Ctx` (`ctx-nil`/`ctx-bind`),
  and the result sums `TcR` (`tc-ok (ty Val) (use (List Qty))` / `tc-err (msg
  Str)`) and `CkR` (`ck-ok (use (List Qty))` / `ck-err (msg Str)`). Forward-
  `declare` `infer`/`check`/`subsume`/`subtype` + the E5/E13 seams before any
  `def`.
- **Size:** ~S.

### Step 2 — `subtype` (cumulativity + conv fallthrough)
- **Target:** `lib/kernel.chiral` — `subtype`.
- **Change:** transcribe `kernel.py:321` per example §5: `v-type la` vs `v-type
  lb` → `(<=i la lb)`; all other formers fall through to `conv` (E3). The **Pi
  row-subsumption** case (`kernel.py:327–338`, contravariant domain + row
  containment) is a **declared E39 seam** — a commented case above the `conv`
  fallthrough, filled when E39 lands.
- **Size:** ~S.

### Step 3 — `infer` (synthesis, structural on `Term`)
- **Target:** `lib/kernel.chiral` — `infer`.
- **Change:** transcribe `kernel.py:400` per example §5 — `t-var`→`ctx-lookup`
  (one-hot usage), `t-type l`→`(v-type (+ l 1))`, `t-pi`→formation with
  `max-lvl l1 l2` (membrane `on-binder` as a declared E12 seam), `t-ann`→the mode
  switch (infer ty, require `v-type`, `eval`, flip to `check`), `t-app`→the QTT
  app rule `(u-add fu (u-scale q au))` with the **dependent-codomain eval guard**
  via E13's `uses-below` (decision baseline), `t-lam`→`tc-err` (cannot
  synthesize). Result is a `TcR`; every recursive call `case`-dispatches its
  `tc-err`/`tc-ok` (coverage-forced error propagation).
- **Size:** ~M.

### Step 4 — `check` + `subsume` (the one subsumption boundary)
- **Target:** `lib/kernel.chiral` — `check`, `subsume`.
- **Change:** transcribe `kernel.py:483`. `check` on `t-lam` against a `v-pi`
  re-runs `on-binder` (**type-level-Pi-smuggle**, the named golden case), binds a
  fresh neutral at `(ctx-len c)`, checks the body against `(capply cod fresh)`,
  and `strip-binder`s its own usage entry (E5 seam). Every non-intro former
  routes to `subsume` = infer-then-`subtype`, the single infer→check boundary;
  mismatch → `ck-err`.
- **Size:** ~M.

## 5. Conformance gate

- **Golden behavior:** for the closed-core fragment, the chirality `infer`/`check`/
  `subtype` agree with `kernel.py`'s on **both** the accept/reject decision
  (`tc-ok`/`tc-err`, `ck-ok`/`ck-err` vs Python accept/`KernelError`) **and** the
  **usage vector** returned.
- **Dependency of the differential (honest gate):** the chirality floor is runnable
  only once its seams are built — **E3** (`eval`/`capply`/`conv`) and **E5**
  (`u-add`/`u-scale`/`qfits`/`strip-binder`) are hard prerequisites; the
  membrane-dependent case additionally needs **E12** (`on-binder`). So the gate
  splits:
  - **E4-standalone (needs only E3+E5 built):** `Type l : Type (l+1)`; cumulative
    acceptance `Type 0 <= Type 1` **and** its directionality (`Type 1 </= Type
    0`); rejection of an un-annotated lambda in infer mode; the QTT application
    usage `u_f + q·u_a`; Pi-formation level `max l1 l2`. These are the verdict +
    usage-vector differential E4 owns.
  - **Call-site placement (E4-structural):** `check` on `t-lam` **invokes**
    `on-binder` at the binding site (matching `kernel.py:496`) — E4 owns that the
    call is *placed*; the **type-level-Pi-smuggle rejection differential** (a
    linear domain bound at an unrestricted quantity) is produced by E12's
    `on-binder` body, so that accept/reject case is **E12-gated**, not E4's.
- **Tests to add:** differential cases in `tests/test_kernel.py` (or the
  `test_nbe_selfhost.py` harness E3 introduces) running the **chirality floor**
  (`lib/kernel.chiral` under the RT interpreter) against the **Python reference**
  (`kernel.py` infer/check/subtype), asserting equal verdicts and equal usage
  vectors over the E4-standalone corpus above.
- **Green line:** 355 → ≥ 355 + (case count, ≥ 5 E4-standalone); ledger-lint
  clean. (The smuggle-rejection case lands on E12's green line.)
- **Done when:** chirality and Python judgments agree on verdict *and* usage vector
  across the E4-standalone corpus (E3+E5 built), with cumulativity directionality
  passing and the `on-binder` call placed at the check-Lam binding site.

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - **Effect-row `allow_eff` threading + the three membrane seams** → **E12**
    (`lib/effects.chiral`); E4 leaves them as declared call sites.
  - **`subtype` Pi row-subsumption** (contravariant domain, row containment) →
    **E39**.
  - **Globals/prims/literals/`let`/`PrimTy`** + `ext_check` data-former hooks →
    **E6** / full-ADT assembly.
  - **Refinement subtype hooks** (universe-level `>= 0` refinement; forgetting/
    entailment) → **E9**.
  - **`Qty` semiring type + ops** (`u-add`/`u-scale`/`qfits`/`strip-binder`,
    `max-lvl`) → **E5**; the E3-I64 / E4-`Qty` placeholder converges there.
  - **`conv`/`eval` totality** (the non-structural seam) → **E3 decision #1**.
  - **Shared polymorphic `Result`** replacing `TcR`/`CkR` twins → available
    non-blocking ergonomics refactor (decision #4), nobody's yet.
- **Follow-on:** unblocks **E5** (QTT semiring — the ops E4 consumes),
  **E6** (data-former handlers plug into `infer`/`check`), **E12** (wires the
  membrane through these functions). E4 is the center of the TCB — every L1
  element is a seam into these three functions.
- **Related:** [[E04-bidir-universes]], [[E03-nbe-normalize]] (provides
  `eval`/`conv` + the base ADT and the seat/totality patterns),
  [[E05-qtt-semiring]] (the `Qty` type + usage ops), [[E06-data-ctors-coverage]]
  (former hooks), [[E12-effect-membrane]] (the membrane seams + row),
  [[E09-refinement]] (subtype hooks), [[E13-debruijn]] (`uses-below`).
