---
element: E53
slug: ddc-bootstrap
title: Diverse double-compilation / trusting-trust bootstrap (the independence residue under E52)
kind: BUILD-PROPER
example: examples/E53-ddc-bootstrap.md
status: audited
updated: 2026-07-27
---

# E53 SPEC — Diverse double-compilation / trusting-trust bootstrap (the independence residue under E52)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** a **differential compare / divergence-localizer harness**
  — a thin, untrusted Python driver (`scaffold/tests/ddc.py`) plus the pure chirality
  compare core (`scaffold/lib/ddc.chiral`) — that runs two provenance-declared
  executors on one input, and returns a named verdict: `ddc-converged` (all legs
  emitted the same bytes) or `ddc-diverged` naming *which leg* diverged *and
  localizing the first divergence* to `function@byte_offset` (the emitter carries
  no source spans — `file:line` is future emitter metadata, §6). The harness
  builds the CHECK machinery the Stage1==Stage2 fixpoint runs through (the true
  cross-stage fixpoint itself stays out of near-term scope — §5 scope honesty). The near-term legs are **leg 0** = the
  self-hosted native artifact (`NativeBackend.compile` — the suspect and the
  fixpoint's subject) and **leg 1** = the Python scaffold (`tal.TalMachine` — the
  prior, a different language/toolchain). This is the existing `test_native.py`
  differential pattern generalized from `assertEqual`-on-a-scalar to
  first-divergence-wins-over-an-artifact-with-a-name.
- **Non-goals:** the full chirality-native ceremony (leg-*running* via spawn/exec is
  lane-A / E70 effectful lowering — elided here); leg 2 (the E72 weekend
  interpreter) and the full multi-axis provenance quorum; `ddc-converged` becoming
  a certificate consumable over Adhikara; hashing/digests (the floor compares
  whole bytes, no prim yet); the spec-conformance admission gate (E71's
  `conform`). All in §6.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E53 postdates the map snapshot; treat as
  **BUILD**. Nothing for the DDC ceremony exists today.
- **Live code this composes with (the refraction — do NOT respec these):**
  - `chirality/tal.py` — `tal.TalMachine(lowered)`: the reference executor. This
    **is leg 1** (Python scaffold, cpython toolchain). Already the differential
    reference floor throughout `test_native.py`.
  - `chirality/native.py` — `NativeBackend().compile(sig, fns)`: the self-hosted
    x86-64 emitter and its emitted artifact. This **is leg 0** (the suspect).
    Also provides `decode(sig, ty, ptr)` for observable-output comparison.
  - `scaffold/tests/test_native.py` — the **seed pattern**: `agree(name, args)`
    runs `self.compiled[name](*args)` (native) against `self.machine.call(name,
    args)` (reference) and asserts equality. The harness reuses this exact
    two-floors-one-input mechanism; DDC only changes the *comparison* (fold to
    first divergence, name the leg) and the *subject* (the emitted artifact bytes,
    not just a scalar return).
  - `docs/split-role.md` (exists) — provenance vectors, agreement-as-verdict, and
    the honest-limits framing the Prov/quorum shape derives from.
- **True delta:** a new `scaffold/lib/ddc.chiral` (pure compare core: `Prov`/`Leg`/
  `DdcR`/`LegOut` + `ddc-compare`/`ddc-fold`, runnable on the reference floor
  because it is pure), a new `scaffold/tests/ddc.py` (untrusted driver that runs
  the two floors, collects emitted artifacts, and localizes first divergence), and
  a new `scaffold/tests/test_ddc.py`. No change to `native.py`/`tal.py` beyond
  reading their public entry points. Two comparison notions kept distinct in the
  code: **fixpoint = bit-identity of emitted artifacts** (cross-stage; near-term
  proxied only by leg-0-twice reproducibility — §5 scope honesty); **executor
  admission = observable conformance** (a leg matches spec vectors before it may
  sit in the quorum). "Conformance admits the leg; bit-identity convicts the
  binary."

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Does a `ddc-converged` verdict become a **certificate** other nodes consume over Adhikara, or stay a local build-time fact? | **DEFERRED → E52 (certificate evidence elements) / D4's cross-node route** | Needs the cert-evidence element and the Adhikara transport. The near-term harness delivers a *local* verdict; that is sufficient for the port-verification use. Promoting it to a consumable certificate is additive and lives where E52 builds the evidence class; D4 (RESOLVED 2026-07-27 → `docs/decision-profiles.md` "The conformance mechanism") routes cross-node claims over Adhikara as certificate evidence elements per its direction record. |
| 2 | How does the **epoch axis** interact with re-runs (a re-run IS the point — verdicts should date, not accumulate)? | **DEFERRED → post-E70 full ceremony** (principle recorded) | The principle is settled by the example's own reasoning (dated, non-accumulating verdicts). *Implementing* dated verdicts belongs to the effectful re-runnable ceremony, which needs E70 lowering to actually re-spawn legs. Near-term driver runs once per invocation and records the epoch in the Prov vector without accumulation. |
| 3 | When is the ceremony **demanded** — every release? every kernel-spec change? | **NEEDS-AUTHOR (non-blocking)** | A release-cadence / policy call the author owns (values + scope, not derivable from code). Does NOT block building the harness — the mechanism exists regardless of the trigger policy. Surfaced, not answered. |
| 4 | Must leg 2 eventually be written by a **genuinely different author** for the provenance vector to mean what it says (the author common-mode)? | **DEFERRED → E72 (leg 2's authorship) + `docs/split-role.md` honest-limits** | split-role already names the author axis as assertable-not-attestable and accepts it as an honest rung. The near-term 2-leg harness (leg 0 native vs leg 1 scaffold) does not include leg 2, so the author common-mode is not yet exercised; it lands with E72. Recorded in the Prov vector, not laundered. |

Decision #3 is NEEDS-AUTHOR but **non-blocking** — it does not block the audit
gate; the SPEC's status is pipeline-managed (`specced` → `audited` on audit
pass, via `chirality-pack.py --mark`). §4–§6 are fully specified.

## 4. Change plan (ordered, commit-sized)

### Step 1 — Pure compare core in chirality
- **Target:** `scaffold/lib/ddc.chiral` (new) — `Prov`, `Leg`, `DdcR`, `LegOut` data;
  `bytes=?` / `fixpoint=?` (the same byte-equality, named for its two roles);
  `prov-disjoint?` (pairwise, on named axes); `ddc-compare` / `ddc-fold`
  (first-divergence-wins, naming the two disagreeing legs).
- **Change:** transcribe the example §5 skeleton verbatim into checked chirality
  surface syntax. It is **pure**, so it type-checks now AND runs on
  `tal.TalMachine` over `LegOut` values — no E70 needed for the core (only the
  leg-*running* needs effects). `prov-disjoint?` checks language + toolchain axes
  (leg 0 = chirality/chirality-native vs leg 1 = python/cpython3); it records but does not
  attest the author axis.
- **Size:** ~M

### Step 2 — Thin untrusted Python driver
- **Target:** `scaffold/tests/ddc.py` (new) — `run_leg(...)`, `ddc_fold(...)`,
  `ddc_compare(...)`, `Prov`/`Leg`/`LegOut` mirrors, a `main()`.
- **Change:** mirror `ddc-fold` in Python (untrusted — the verdict is
  re-derivable from the pure core). For a given chirality source: build leg 0 via
  `NativeBackend().compile(sig, fns)` and capture its **emitted artifact bytes**
  (the machine-code buffer); build leg 1 via `tal.TalMachine(lowered)`. Compare
  (a) the emitted artifact bytes across legs for bit-identity, and (b) observable
  outputs over an input vector (reusing the `agree()` marshalling from
  `test_native.py`) for executor admission. Assert `prov-disjoint?` (language +
  toolchain) BEFORE comparing; on <2 legs or non-disjoint provenance return
  `ddc-bad-quorum`.
- **Size:** ~M

### Step 3 — First-divergence localizer
- **Target:** `scaffold/tests/ddc.py` — `localize(offset, fn_spans)`.
- **Change:** on artifact-byte divergence, find the first differing byte offset
  and map it to `(function, offset-within-function)` via the emitter's
  name→offset map (`native.py:397-401`). **Localization granularity is
  `function@byte_offset` only** — no source-span metadata exists anywhere in
  the emitter (`native.py`/`emit-core.chiral`/`emit-x64.chiral` carry no
  span/lineno; verified 2026-07-22, 2nd-order audit); `file:line` resolution
  is a future emitter-metadata dependency, moved to §6 residue. The
  `ddc-diverged` value carries both leg names; the driver attaches the
  localization.
- **Size:** ~S–M

### Step 4 — Tests
- **Target:** `scaffold/tests/test_ddc.py` (new).
- **Change:** the converged run, the injected-one-byte negative test, the
  provenance-quorum checks, and a chirality-core-vs-driver agreement check (below).
- **Size:** ~M

## 5. Conformance gate

- **Golden behavior (the negative test IS the point):**
  1. **Diverged (headline):** inject a one-byte mutation into one leg's emitted
     artifact → the harness returns `ddc-diverged` naming **that leg** and a
     `function@byte_offset` localization.
  2. **Converged:** the true two-leg run on a demo function returns
     `ddc-converged`, and **native emission is reproducible** leg-0-twice (two
     independent `NativeBackend` compiles of the same source emit bit-identical
     artifacts). **Scope honesty (2nd-order audit 2026-07-22): leg-0-twice is
     single-compiler REPRODUCIBILITY, not the Stage1==Stage2 fixpoint** — the
     authoritative fixpoint (DETERMINISM-DEBTS header; SELF-HOST-PLAN) compares
     two *different* compilers of the same source, and both leg-0 runs share
     one Python driver and one insertion order, so the D-2 order debt CANNOT
     surface here. The true cross-stage fixpoint is out of E53's near-term
     scope (blocked on E70 leg-running + the chirality-driven compile) and this
     harness must never be cited as it holding.
  3. **Bad quorum:** a single-leg or duplicate-provenance quorum returns
     `ddc-bad-quorum` (the disjointness gate fires before comparison).
- **Tests to add (`test_ddc.py`), naming which floors each compares:**
  - `test_true_run_converges` — leg 0 (`NativeBackend`) vs leg 1 (`TalMachine`),
    observable outputs agree ⇒ `ddc-converged`.
  - `test_native_emission_reproducible` (renamed from `test_fixpoint_leg0_twice`
    — it is NOT the Stage1==Stage2 fixpoint, see §5.2) — bit-identity of two
    `NativeBackend` emissions.
    **Honest hedge:** if emission bakes absolute heap/code addresses in, this
    surfaces the exact determinism debt the example flags (E8 `repr`
    canonicalization; trust-boundary ordering/encoding pins) — record it as
    `xfail(reason=...)` naming the pre-port gate rather than a false green.
  - `test_injected_byte_diverges` — mutate one byte of leg 0's artifact ⇒
    `ddc-diverged` naming leg 0 + localized offset (native vs reference).
  - `test_bad_quorum_rejected` — <2 legs and duplicate Prov ⇒ `ddc-bad-quorum`.
  - `test_chirality_core_matches_driver` — the **pure `ddc-fold` run on
    `tal.TalMachine`** returns the same verdict as the Python driver over the
    same `LegOut` vectors (the untrusted driver is checked against the
    re-derivable chirality core).
- **Green line:** 281 → ≥ 286; ledger-lint clean.
- **Done when:** `python -m pytest scaffold/tests/test_ddc.py` is green, the
  injected-byte test returns `ddc-diverged` with the correct leg named and a
  `function@byte_offset` localization, and the true run returns `ddc-converged`
  with native-emission reproducibility holding (or an `xfail` naming the
  determinism debt).

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - Leg-*running* orchestration (spawn/exec each leg on the same source) →
    **E70** effectful lowering + **E33/E51** (lane-A process machinery). Until it
    lands, the driver runs the two in-process floors, which is enough for the
    port check.
  - Leg 2 (E72 weekend interpreter) + full multi-axis provenance quorum +
    hardware axis → **E72**.
  - `ddc-converged` → consumable certificate over Adhikara → **E52** (+ D4's
    cross-node certificate-evidence route; D4 RESOLVED 2026-07-27 →
    `docs/decision-profiles.md`).
  - `file:line` divergence localization → **emitter span metadata** (no
    span/lineno exists in `native.py`/`emit-core.chiral`/`emit-x64.chiral` today;
    a future emitter-metadata element, nobody's yet).
  - Determinism pins (E8's `repr`-keyed linear-kind seen-set; trust-boundary
    ordering/encoding) → **the port** (pre-port gate; the fixpoint test above
    surfaces the debt if unpaid).
  - Digest/hashing optimization of the compare → **nobody's yet** (floor uses
    whole-bytes equality; no prim need).
  - The spec-conformance admission gate (`conform`) that *entitles* a leg to the
    quorum → **E71** (`golden-restructure`).
  - Author common-mode attestation → **E72** + `docs/split-role.md` honest-limits
    (accepted rung: assertable, not attestable).
- **Follow-on:** completes the executor half of the checker's trust story that
  **E52** (certificates — the judgment half) begins; makes **E72**'s
  re-bootstrap machinery load-bearing as a DDC leg (one build, two guarantees).
- **Related:** [[E53-ddc-bootstrap]], E52 (certificates), E72 (re-bootstrap),
  [[E71-golden-restructure]] (spec conformance admits a leg),
  [[E15-reference-interpreter]] (leg 1's core), E8 (`repr` canonicalization
  debt), D7 / edge 11 (RESOLVED-IN-DIRECTION 2026-07-26: bootstrap independence
  = re-derivability + DDC, toolchain-diverse, authorship honestly named — this
  element is level 1's mechanism; the level-2 fork was a phantom, operational
  agreement lives in `docs/floor-agreement.md`),
  `docs/split-role.md` (provenance vectors).

> **Verification note (facts checked against the repo; corrected in orchestrator
> audit 2026-07-22):** `docs/split-role.md` exists. The chirality-source emitter
> named in the example's §2 finding 2 **does exist** — `scaffold/lib/emit-x64.chiral`
> (10-line wiring) over `scaffold/lib/emit-core.chiral` (5.4 KB, target-independent
> codegen) + `scaffold/lib/mach-x64.chiral` (18.6 KB, the x86-64 machine). The
> earlier draft's claim that it was absent was a path error (searched `lib/` from
> repo root, not `scaffold/lib/`). This does **not** change the change plan: the
> two legs are the two **executors** of that one chirality emitter — leg 0 =
> `chirality/native.py`'s `NativeBackend` (compiles the emitter to x86-64), leg 1 =
> `chirality/tal.py`'s `TalMachine` (interprets it) — which is exactly the example's
> "diverse *executors*, not diverse *codegens*" finding 2. Repo-root `tools/` and
> `lib/` do not exist — Python tooling lives in `scaffold/tools/` (`balance.py`)
> and chirality libraries in `scaffold/lib/`; the driver and compare core are new
> files there (paths corrected in the 2026-07-27 spec audit — the change plan's
> earlier repo-root targets repeated the path-class error this note records).
