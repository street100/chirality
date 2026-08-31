---
element: E52
slug: certificate-split
title: Kernel-core certificate split: kernel-spec artifact + small trusted core re-checking untrusted producers' certificates + certificate / proof-object format (LCF / de Bruijn)
kind: BUILD-PROPER
example: examples/E52-certificate-split.md
status: audited
updated: 2026-08-02
---

# E52 SPEC — Kernel-core certificate split: kernel-spec + kernel-core + the certificate seam

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.
>
> **Trust-lane element — read this first.** E52's load-bearing deliverable is a
> **Lane-5** program (SELF-HOST-PLAN item 2 of the strong judgment core): the
> small, spec-directed chirality-side `recheck` that replaces trusting the Python
> elaborator+checker monolith, verified by the Stage1==Stage2 fixpoint. It is
> **gated on the checker port** (E3/E4/E13 → `lib/kernel.chiral`, `audited` but
> not built = the build wave). This SPEC scopes that full contract AND a
> buildable-now Python **reference producer/checker pair** (the "transition"
> the example §6 names) as the de-risking first commit. The Python seam is a
> real seam, not the TCB win — that lands with the port.

## 1. Deliverable

- **After this runs:** the def-entry judgment flows through an explicit
  **certificate seam** — the elaborator emits a `Cert` (the elaborated core
  term + a per-site conversion tier + carrier version) and holds no trust; a
  single consumer `recheck : Spec → Cert → Verdict` re-derives it and returns a
  **verdict value** (errors-as-values, not a raised `KernelError`); definition
  installation consumes the verdict, never producer output. Delivered in two
  phases: **(A)** a buildable-now Python reference producer/checker pair in
  `kernel.py`/`surface.py` (shrinks nothing in the TCB yet — it reifies the
  boundary and proves it catches an injected elaborator bug); **(B, Lane-5,
  gated on the checker port)** the chirality-side `lib/kernel-core.chiral` `recheck`
  over the ported `CoreTerm` ADT, differential against pair (A), joined to the
  fixpoint.
- **Non-goals:** `docs/kernel-spec.md` as a *full audited prose artifact*
  (couples E71; §6). The **serialized certificate wire format** (#3 → DEFERRED
  to the E12 bootstrap bridge). **Spec-size-budget enforcement** tooling (#4 →
  DEFERRED as premature; §3). Producer #2+ (the optimizer already carries
  `preserve-check`; solvers per inspiration Tier O). The `conv-cached` signature
  scheme (tier 3 crypto is its own element).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** `Kernel-core certificate verifier + discipline` —
  **BUILD**, L, E52: *"Settled in docs; kernel.py is single trusted checker, no
  producer/consumer split … Decision made; forward build."* So the shape is a
  new seam over an existing monolith, not a redesign. The sibling row `DDC
  differential harness` is **BUILT (E53)** and names `cert-over-Adhikara → E52`
  as its forward hook — E52's certificate is what E53's climb eventually carries.
- **Live code this composes with (do NOT respec):**
  - `kernel.py:400 infer` / `kernel.py:483 check` — the bidirectional judgment
    is **already syntax-directed re-derivation** over the elaborated core `Term`
    (`Var`/`Global`/`Prim`/`Lit`/`Pi`/`App`/`Let`/`Ann`/`Lam`/EXT). Metavariables
    are resolved in the elaborator; the elaborated term already carries `Ann`
    (ascription) nodes at the non-syntax-directed points. **The elaborated term
    IS the derivation** (example finding #1), so `recheck`'s typing half = run
    the *existing* `check`/`infer` on the certificate's term — no new judgment.
  - `kernel.py:567 finish_def` — today's def-entry: `check(sig, Ctx(), body,
    tyv, EMPTY_ROW)` then `sig.global_defs[name] = body`. Raises `KernelError`
    on failure. This is morally the recheck already; E52 reifies its boundary.
  - `surface.py:169–186 toplevel` — the producer: `body = self.elab(form[3],
    [])` then `K.finish_def(sig, name, body)`. The elaborated `body` is the
    typing certificate's payload.
  - `kernel.py:277 conv` — the conversion checker (`conv-rerun`, tier 1) already
    exists and is what tier-1 sites re-run. `preserve-check` (`lower.py:432`,
    `optimize.py`) is the **proven-once** certificate re-checker E52 generalizes.
  - `lib/ddc.chiral` (E53, built) — the differential-compare core the chirality-side
    (B) certificate eventually feeds.
- **Not yet built (the gate):** the chirality checker port — `lib/kernel.chiral`
  (E3/E4 `infer`/`check`/`conv`), `lib/terms.chiral` (E13 `CoreTerm`),
  `lib/qtt.chiral` (E5), `lib/data.chiral` (E6/E7/E8) — all `audited`, none built.
  Phase (B) cannot start until they exist (the build wave, rung 1 / Lane 5).
- **True delta:** (A) a `Cert`/`Verdict`/`ConvEv` data layer + an errors-as-values
  `recheck` wrapper + routing `finish_def` through it + the negative test; (B)
  the chirality re-implementation of that same seam over the ported ADT.

## 3. Decisions

| # | Question (example §6) | Disposition | Rationale / owner |
|---|-----------------------|-------------|-------------------|
| 1 | Conversion-evidence tier mix (`conv-rerun`/`conv-trace`/`conv-cached`) | **RESOLVED → per-instance** | Settled 2026-07-26 (catalog §VII): tier chosen *per certificate site* — `conv-rerun` where the check is decidable & cheap (conversion/NbE), `conv-trace` for undecidable producer outputs (solvers), `conv-cached` only where perf dominates; TCB = union of tier-checkers used. Phase (A) implements **`conv-rerun` only** (the sole tier whose checker — `kernel.py:277 conv` — already exists); trace/cached are constructors reserved in the ADT, unimplemented, each a later per-site pick. |
| 2 | Totality of `recheck` itself — spec-level normalization claim, or fuel-bounded verdict? | **RESOLVED-IN-DIRECTION** (carried-measure part); fuel posture **PROVISIONAL** | Split into two parts. **Settled (author-ratified 2026-08-02 + docs):** totality of the *carried input* is not a `recheck` concern — the totality mark is a carrier seat (`decision-effect-facets`, Pi carrier `(q,row,grades,totality-mark,…)`) re-checked as a **declared measure**: "declared, never inferred … the checker only re-checks the measure, and a false one is rejected" (`totality.md`, classify-not-enforce). `recheck` re-accounts it like any seat. **Provisional (recommended, not yet ratified):** the residual — `recheck`'s own termination when it re-runs **conversion** (the one site with no declared measure) — takes the **fuel-bounded verdict** posture (`recheck` structurally total, no SN axiom in trusted *code*; a `v-fuel` verdict names exhaustion; SN lives in kernel-spec as a tiered P5 claim, not a `(total)`-code axiom). This is **coupled to [[E03-nbe-normalize]] dec#1**, itself still provisional (b); **decide the two together at the port**. Non-blocking: Phase (A) reuses Python `conv` as-is (CPython recursion = the interim floor), so the fuel verdict + threading is a Phase-(B) obligation, not owed now. |
| 3 | Certificate serialized / canonical wire format (E12 bootstrap bridge) | **DEFERRED → E12 bridge** (author-ruled 2026-08-02) | Decide the wire format *with the real serialization need in front of us* (the transition where chirality producers emit Certs the still-Python core reads). Phase (A) `Cert` is an **in-process value** (Python object / chirality data), never serialized — no format owed yet. When the bridge lands, revisit; the leading candidate on record is canonical S-expr reusing E1's reader + the fixpoint's canonicalization (D-1/D-2), but it is **not decided here**. |
| 4 | Spec-size-budget enforcement (what "readable in a sitting" measures; who signs a spend) | **DEFERRED as premature** (author-ruled 2026-08-02) | Priority is rung 1, and composability lets us add enforcement later without cost (principle 6 — an abstraction that doesn't constrain behavior yet is overhead). The budget stays a **documented design intent** in kernel-spec (prose: "readable in a sitting; every carrier seat spends from it"), **no lint/tooling**. Revisit *only if* kernel-spec actually bloats — a refactor then, not machinery now. |

No blocking NEEDS-AUTHOR remains → `status: draft` (not `blocked`). Phase (B)
carries a **build-gate**, not a decision-gate: it waits on the checker port, not
on an unanswered question.

## 4. Change plan (ordered, commit-sized)

> **Author priority call — RESOLVED 2026-08-02: DO NOT build Phase (A).**
> Phase (A) adds Python to the check path that the fixpoint would only delete
> later — the opposite of the rung-1 goal (zero CPython). It shrinks no TCB, so
> "de-risking" does not justify writing throwaway trusted-core Python. **Defer
> all of E52 to Lane 5** and build the seam **once, in chirality**, after the checker
> port lands. Phase (A) below is retained as *design reference only* (it
> documents the seam that Phase B implements natively); it is **not a build
> step**. The real, only deliverable is Phase (B).
>
> **Phase (A) — DESIGN REFERENCE ONLY, not to be built** (documents the seam
> Phase B ports to chirality). Phase (B) is the deliverable, **gated on the checker
> port** (the build wave).

### Step A1 — the certificate data layer (Python)
- **Target:** `scaffold/chirality/kernel.py` — new module-level types near the top.
- **Change:** add `Cert` (elaborated `Term` + a `ConvEv` tier tag + `carrier_ver:int`),
  `ConvEv` (`conv-rerun` implemented; `conv-trace`/`conv-cached` reserved,
  raising `NotImplementedError` if constructed — honest un-built), and `Verdict`
  as a tagged value: `v-accepted` / `v-rejected(rule, at)` / `v-wrong-carrier(want, got)`
  / `v-fuel` (reserved for Phase B, unreachable in A). `carrier_ver` = a single
  module constant `CARRIER_VER` bumped only when the Pi seat set changes.
- **Size:** ~S.

### Step A2 — `recheck` as an errors-as-values wrapper
- **Target:** `scaffold/chirality/kernel.py` — new `def recheck(sig, cert)`.
- **Change:** re-derive the certificate against the current judgment: check
  `cert.carrier_ver == CARRIER_VER` (else `v-wrong-carrier`); run the existing
  `check(sig, Ctx(), cert.tm, sig.global_types[name], EMPTY_ROW)` inside a
  `try/except KernelError` that **converts the raise into `v-rejected(rule, at)`**
  (map the error to the failing judgment form + location); conversion sites hit
  the existing `conv` (tier 1). Return `v-accepted` on success. `recheck` itself
  raises nothing. **No new judgment logic** — it wraps A1's boundary around the
  code that already runs.
- **Size:** ~M.

### Step A3 — route def-entry through the seam
- **Target:** `scaffold/chirality/kernel.py:567 finish_def` + `surface.py:169–186 toplevel`.
- **Change:** `surface.toplevel` builds a `Cert` from the elaborated `body`
  (the producer, holding no trust) and calls a verdict-consuming path;
  `finish_def` (or a new `finish_def_checked`) calls `recheck`, and on
  `v-accepted` installs (`sig.global_defs[name] = body`), on `v-rejected` /
  `v-wrong-carrier` reports (preserving today's error text so the suite's
  expected messages still match). Keep the raising `finish_def` available for
  callers that want it, or adapt call sites — implementer's diff decision, shown.
- **Size:** ~M.

### Step A4 — the negative test (the whole point of the split)
- **Target:** `scaffold/tests/test_kernel.py` (or new `test_certificate.py`).
- **Change:** (i) differential — every def the current path accepts, `recheck`
  accepts; every rejection matches, across a corpus (the existing suite exercises
  it). (ii) **injected-bug** — hand a `Cert` whose elaborated term has a
  deliberately wrong ascription (a producer bug) and assert `recheck` returns
  `v-rejected`, not `v-accepted`. This is the seam's reason to exist.
- **Size:** ~S.

### Step B1–B* — chirality-side `recheck` (GATED on the checker port; forward contract)
- **Target:** NEW `lib/kernel-core.chiral` (+ `Cert`/`Verdict`/`ConvEv`/`JForm`/
  `SpecRule` data; `recheck` over the ported `CoreTerm`), consuming
  `lib/kernel.chiral`/`lib/terms.chiral`/`lib/qtt.chiral`/`lib/data.chiral` (E3–E13
  port). `recheck` is pure + structurally total via **fuel** (decision #2); a
  `v-fuel` verdict names conversion exhaustion. Differential vs the Phase-(A)
  Python pair over the same corpus; then joined to the E53 DDC harness / fixpoint.
- **Size:** ~L. **Do not start until the checker port lands (build wave).**

## 5. Conformance gate

- **Golden behavior (Phase A):** for every definition in the existing suite,
  `recheck(sig, cert)` returns `v-accepted` **iff** today's `finish_def` accepts
  it, and its `v-rejected` rule/location corresponds to today's `KernelError` —
  i.e. reifying the boundary changes *no* accept/reject outcome. Plus the
  negative test: an injected wrong-ascription certificate yields `v-rejected`.
- **Tests to add:** `test_certificate.py` — (1) a differential/parametrized pass
  that installs a fixture corpus both ways and asserts verdict-agreement
  (compares the Python reference producer/checker pair against the raising path);
  (2) `test_recheck_catches_injected_elaborator_bug`; (3) `test_wrong_carrier_ver`
  (a `Cert` with a stale `carrier_ver` → `v-wrong-carrier`). All at the Python
  floor (Phase A has no native/chirality floor — that is Phase B's differential).
- **Green line:** 430 → ≥ 433; `python3 tools/ledger-lint/ledger-lint.py` clean.
- **Done when:** def-entry runs through `recheck`, the full suite is green with
  outcomes unchanged, and the injected-bug test proves the seam rejects a
  producer bug that the trusted-de-facto path would have installed.

## 6. Residue & links

- **Deliberately unbuilt (with homes):**
  - Chirality-side `recheck` + the real TCB reduction → **Phase B, Lane 5** (gated on
    the checker port; the fixpoint verifies the last Python dies).
  - `conv-trace` / `conv-cached` tiers → later per-site picks (decision #1);
    `conv-cached` signature/crypto is its own element.
  - Serialized certificate wire format → **E12 bootstrap bridge** (decision #3).
  - Spec-size-budget enforcement tooling → **deferred**, revisit only on bloat
    (decision #4).
  - `docs/kernel-spec.md` as a full audited artifact → couples **[[E71-golden-restructure]]**
    (one ownership budget governs both); Phase A writes only the seat/rule intent
    it needs, not the enumerated spec.
  - `recheck` fuel + `v-fuel` verdict + SN-as-P5-claim-in-spec → **Phase B** /
    **[[E03-nbe-normalize]] dec#1** (decide the SN posture together at the port).
- **Follow-on this unblocks:** the E53 DDC climb's `cert-over-Adhikara` hook; D3
  succession (a stager's core runs `recheck spec successor-core-cert` before
  staging — the certificate IS the succession payload); producer #2+ certification.
- **Related:** [[E52-certificate-split]] (rationale), `decision-split-checker`
  (the settled split — checked socket, not quorum), `certificate-discipline`
  (re-run not spot-check; tiering), [[E03-nbe-normalize]]/[[E04-bidir-universes]]
  (the judgment being split; dec#1 SN tie), [[E13-debruijn]] (`CoreTerm`),
  [[E39-effect-row]] (elaborated-term-as-certificate existence proof),
  [[E71-golden-restructure]] (sibling spec artifact), [[E12-effect-membrane]]
  (bootstrap bridge; format home), E53 (DDC independence), E72 (re-bootstrap
  artifact kernel-spec anchors).
