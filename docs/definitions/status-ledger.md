---
node: status-ledger
layer: navigation
related: [module-map, open-edges, floor-agreement, index, memory-model, permission-model, totality]
status: draft
updated: 2026-08-24
---

# Status ledger

> **⚑ Milestone — self-hosting fixpoint (2026-08-05).** The native compiler now
> compiles its own source to a **byte-identical** copy of itself (`selfhost.py
> stage2` → `FIXPOINT: B1 == B2`, 1 s, peak 0.1 GB, deterministic). The CPython
> interpreter is **evicted from the compile path** — a chirality program is compiled
> end-to-end by native chirality, no interpreter and no Python logic in the compile.
> The Python scaffold survives only as the test-suite reference oracle (off the
> build/run paths). Its external-verification successors are **two, and one of
> them now runs**: the Rocq port (still toolchain-less here) and, since
> 2026-08-24, E166's `Mach`→C leg, which gives DDC a second toolchain-disjoint
> leg (`ddc-legc`) and gates as Phase 10 of the native suite — see
> [[testing-floors]] and [[banks/verification]]. This
> promotes the whole *compile pipeline* from IMPLEMENTED-on-CPython toward the
> self-hosted floor; the remaining CPython dependence is the test oracle and the
> `check`/kernel path when run interpreted. See [[trust-boundary]] for the TCB
> delta and `.planning/FIXPOINT-CHECKLIST.md` for what remains (Phase B: retire
> the seed as a shipped artifact; the tests' Rocq rewrite).

The design notes are written in the present tense of the finished system. The
scaffold implements a fraction of it. This note is the map between the two, so a
reader never has to carry *is this real?* as load on every claim — the same
regularity the language asks of code, asked of its own documentation. [[module-map]]
places every module on the two axes; this places every module on the axis the
notes leave implicit: **how real it is.** The finer-grained honest status already
lives in `docs/implementation/README.md`, `docs/implementation/AUDIT.md`, and the *Scaffold status*
sections of [[memory-model]]; this consolidates it, and the design notes carry a
status banner pointing here.

## The four rungs

- **DESIGNED** — the note describes it; no code realizes it.
- **SEEDED** — a partial, stub, or single-case realization exists in the scaffold.
- **IMPLEMENTED** — it works in the scaffold, on the Python/host substrate.
- **ENFORCED** — it is structurally guaranteed (kernel- or checker-checked), not
  merely present.

The rungs are orthogonal to correctness. ENFORCED is the strongest claim; an
IMPLEMENTED property runs but rests on trusted host code (the current TCB —
CPython and the Linux syscall surface, see [[trust-boundary]]); a SEEDED one is a
slice; DESIGNED is intent. On the host substrate, even an ENFORCED property is *enforced against a
well-behaved program, not an adversary at the Python level* — enforcement in the
adversarial sense arrives with self-hosting.

## Built — ENFORCED

| Claim | Evidence |
|---|---|
| QTT core: term rep + checker (the trusted judgment) | `chirality/kernel.py`, `chirality/terms.py`; `tests/test_kernel.py` |
| Quantities 0/1/ω resource counting | `kernel.py`; `test_kernel.py` (used-twice / unused rejected) |
| Linear types → **port aliasing control** | `kernel.py` `is_linear` + on_binder at Pi/lam/let/field/apply; `test_kernel.py` |
| Strict positivity of datatypes | `data.py` `_positivity`, per-param variance cache; runs at `check_data` |
| **preserve-check** (lowering *and* optimizer re-check at the floor) | `lower.py`, `optimize.py`; `test_optimize.py` pins an ill-typed pass as a floor alarm |
| Floor agreement of the arithmetic prims (by collapse) | fold imports the reference's arithmetic; `test_optimize.py`, `test_native.py`; see [[floor-agreement]] |

## Built — IMPLEMENTED (works, on the host substrate)

| Claim | Evidence |
|---|---|
| Dependent types (Pi, value-indexed `(Pool n)`) | `kernel.py`; `lib/ports/ports.chiral` |
| Subtyping | `kernel.py` `subtype` (mechanism present; not applied to grant narrowing) |
| tal floor: independent checker + trusted-drop interpreter | `chirality/tal.py`; `tests/test_tal.py` |
| Lowering: pure fragment → tal | `chirality/lower.py`; 48/48 pure functions lower |
| Native backend: chirality emitter → x86-64 | `chirality/native.py`, `lib/lowering/x64/mach.chiral` (no LLVM/Cranelift); `tests/test_native.py`; measured `docs/benchmarks/RESULTS-2026-08-01.md` (7 runs) — bare emitter within 1.0–1.5× gcc -O0; with the first opt pass (inline byte ops, const fold, immediates, pow2 sar/and, TCO) ahead of -O0 outright; with the trait-native tier (guard elision, total-call folding, CSE, lookup tables — `docs/benchmarks/TRAIT-OPTS.md`) 1.4–8.4× behind -O2 (compute-bound 1.37×), whole-series native speedup 2.9–10.2× at equal load (ratios only) |
| W^X loader | `native.py` (map RW → write → `mprotect` R+X; never W+X) — real on the host loader |
| specialize / pregen primitive | `chirality/optimize.py` (meaning-preserving; makes no cost claim) |
| Memory discipline as a profile choice | `lib/memory/mem-linear.chiral`, `lib/memory/mem-region.chiral`; `tests/test_memory.py` |
| Inbound bridge verification | `chirality/bridge.py` (dynamic, depth-bounded ≤4; outbound confinement not built) |
| Frozen-port-set conformance | `chirality verify`; profiles in `prog/demo/` (named crossings only; edge 18 open) |
| Surface syntax | `chirality/sexp.py`, `chirality/surface.py` (scaffold s-expr; real surface is stage 4) |
| Sys-face syscall crossings + self-hosted arena (E21) | `lib/lowering/tal/sys.chiral`: write / read / lseek / memfd_create / ftruncate / mmap / munmap (mprotect, close still missing); chirality sizes+maps its own anonymous file, byte-roundtrips, unmaps; differentially tested |
| Orchestration substrate (json, http+SSE, backend iface, fsm, manas coordinator) | `lib/*.chiral`, `scaffold/tests/test_{http,manas,backend*}.py` — chirality logic over a **CPython transport** (urllib/socket/select); E51 linkage to the self-hosted sys-face is still open |

## Built — SEEDED (a slice exists)

| Claim | What exists / what does not | Evidence |
|---|---|---|
| Refinement types | I64 conjunction of atoms over a **constant or a bare in-scope variable** (`v < n`), with **path-sensitivity** for both (a comparison-guarded branch learns the bound it proves — `_narrow`/`sig.narrow_hooks`); a symbolic bound collapses to a constant on instantiation (Pi re-evaluation), keeping subtyping sound; constant part sound+complete, symbolic part sound (syntactic entailment, no arithmetic between variables); only arithmetic-expression bounds (`v<n+1`) remain out | `chirality/refine.py`; `chirality/terms.py` (Refine shift/uses traverse operands); `tests/test_refine.py` (`TestPathSensitivity`, `TestSymbolicRefinement`) |
| Effects | one coarse pure/process bit at 3 judgment points — ⚑ **and those 3 points are in the Python oracle only (measured 2026-08-25)**: `bin/chirality-bin` compiles and RUNS a `->` def that calls an `=>` one, and the crossing really happens, so the bit is carried natively and refused nowhere ([[banks/effect-and-alarm]] §5d; the gate is E171). The two-facet effect algebra (possession + exercise, edge 16) is settled on paper — [[decision-effect-facets]] — and unbuilt | `chirality/effects.py` (the Evidence column was already the whole story; the Claim column did not say so) |
| Totality | all three pillars built — strict positivity, case coverage, and termination ([[totality]]); the termination check proves **structural** (a case-bound field shrinks) *and* **numeric measure** (a parameter stepped toward a bound a guard proves — a constant with wraparound excluded, or a *variable* `n` with `±1` step and `n` unchanged) recursion — `row-bytes`, every constant-guarded counting loop, and variable-bounded loops prove; it *classifies* (records `sig.totality`), not yet globally *enforced* — unprovable recursion (non-unit-symbolic/lexicographic/mutual) type-checks unless `sig.require_total` or a profile's `(total)` clause | `data.py` (`_positivity`, `_check_case`, `check_termination`/`_totality_reason`); `surface.py` `verify_profiles`; `tests/test_kernel.py` `TestTermination`, `TestTotalityProfile`; `prog/prog/demo/verify-total.chiral` |
| Syscall gating | `sysface` confinement mark + no surface path to `sys`; **not** a numeric allowlist (the number is an arbitrary immediate) | `tal.py`, `native.py` |
| Broker | spawn / teardown / link-at-load only; grant / revoke / audit not built | `impl_ports.py`, `runtime.py` |
| Staging | `spawn` + link-at-load, ad hoc; the binding-time *modality* is designed | `impl_ports.py`, `runtime.py` |
| Secret custody (first slice of [[modules-custody]]) | **type-level** discipline only: opaque linear `Secret`, single greppable guarded exit — runs. Host-copy hygiene partial (`secret-reveal` returns immutable `bytes` it cannot zero); memory custody absent. Redundancy / datum-policy not built | `lib/capability/secret.chiral`, `impl_ports.py`; `tests/test_secret.py`; `prog/prog/demo/passman-min.chiral` |

## DESIGNED — docs only, no code

Region types · capability types · the graded/cost kernel beyond 0/1/ω (decision
settled, unbuilt) · reflect-typed and the reflective floor (edge 5) · **port
revocation** · **permission attenuation / grants / delegate** (only *Move*, i.e.
linearity, is built) · redundancy / datum-policy of [[modules-custody]] (its
type-level custody-split slice is now SEEDED — secret custody, above) ·
information-flow / taint / constant-time (the "blocking
trio" of [[modules-security]]) · adhikara (the capability protocol the broker
chapter rests on) · the bridges evidence-half (attestation, isolation-enforce,
freshness-verify, audit-reconcile, reflect-raw) · cheri-floor · bootstrap-floor ·
`runtime` *as specified* (critical sections, register-root custody, scheduler —
`runtime.py` is an evaluator + linker, a different artifact) · arithmetic-expression
refinement bounds (`v<n+1` — bare-variable bounds are SEEDED above; the pool offset is compile-time checked via `mem-put-checked`).

## Sharpest designed-vs-real gaps

1. **The security surface is nearly vapor in code.** [[modules-security]] reads
   present-tense with no line in the scaffold; [[modules-custody]] now has its
   *first* line — secret custody (SEEDED, type-level only) — but its
   redundancy/datum-policy bulk is still vapor. constant-time is even named "the
   first customer of preserve-check" — yet preserve-check is built and
   constant-time is not wired to it.
2. **[[permission-model]] claims the work is done.** "Everything that does the
   work already exists" is false against the scaffold: of the four grant
   operations only *Move* exists; capability ports, grants, and the sidehand do
   not.
3. **Cost is settled-on-paper, unbuilt.** `kernel.py` still carries only 0/1/ω;
   the typed-cost thesis has no grade structure yet.
4. **Totality classifies but does not yet gate by default** — all three pillars run, yet unprovable recursion type-checks unless `require_total` or a profile `(total)` clause asks.
5. **The `runtime` note describes a different artifact than `runtime.py`.**

## Stale claims fixed / flagged

- [[decision-backend]] "there is no backend yet" — **fixed**: a native x86-64
  emitter now exists, and as of 2026-08-01 is measured across four runs —
  bare, within 1.0–1.5× of gcc -O0; after the first optimization pass
  (inline byte ops, const folding, immediates, Euclidean pow2 sar/and,
  tail-call elimination) ahead of -O0 outright; the trait-native tier
  (guard elision, totality-licensed comptime, CSE, dense-tag tables)
  closed to 1.4–8.4× behind -O2 (compute-bound 1.37× after magic-multiply
  division), whole-series native speedup 2.9–10.2× at equal load
  (cross-side ratios only) — `docs/benchmarks/RESULTS-2026-08-01.md`.
- [[decision-backend]] / [[modules-lowering]] named **LLVM or Cranelift** as the
  codegen library while the scaffold hand-emits x86-64 from chirality with neither —
  **reconciled 2026-07-22** (decision-backend's dated reconciliation; DECISION-DOCKET
  D2): the built Mach path supersedes; no codegen library in the trusted path.

## Maintenance

This ledger is the status source of truth; the design notes carry a one-line
status banner pointing here rather than restating status inline. Update a rung
here when it changes, and keep the sharpest-gaps list honest — a claim that
climbs from DESIGNED to SEEDED is progress worth recording, and a claim that
silently stays DESIGNED while its note reads as shipped is the exact failure this
ledger exists to prevent.
