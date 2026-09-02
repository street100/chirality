---
node: status-ledger
layer: navigation
related: [module-map, open-edges, floor-agreement, index, memory-model, permission-model, totality]
status: draft
updated: 2026-09-01
---

# Status ledger

> **⚑ Milestone — self-hosting fixpoint (2026-08-05).** The native compiler
> compiles its own source to a **byte-identical** copy of itself. The CPython
> interpreter is **evicted from the compile path** — a chirality program is compiled
> end-to-end by native chirality, no interpreter and no Python logic in the compile.
> Re-verified after the migration: `C1 == C2`, byte-identical, `bin/chirality-bin`
> at 1,098,104 bytes and committed; and the old tree's compiler and this one emit
> byte-identical code for the same source across 147 moved files (`docs/definitions/status-ledger.md`,
> *Verified, not asserted*). The selfhost.py harness that produced the original
> `FIXPOINT: B1 == B2` line is gone with the rest of the Python; the recompile
> recipe now lives in `bin/chirality`'s own missing-compiler message.
>
> ⚑ **External judgment is CUT** — author decision, `docs/decisions/decision-scope.md` decision 5: the
> Rocq port, CompCert, and the Python oracle are all gone. `bin/chirality` has no
> `test-rocq` and no `test-python`, and `tools/test/run-tests.sh` lists Phase 10,
> the external-compiler C leg, as **DROPPED**. E166's `Mach`→C leg is **dropped
> too, 2026-09-01** (`d8bcec5`, `d0c5dd5`), with its four fixtures. It shared
> `compile-front` and `compile-back` whole and differed only at emit, so it was a
> second **target** under one formulation. The criterion below is *different
> formulations*, and a second target satisfies none of it. What replaces external
> judgment is **three semantically distinct judgment
> cores that must agree** — different formulations, not three encodings of one
> rule set — and that is unbuilt. The gating floor is `tools/test/run-tests.sh`:
> 7 of the old tree's 12 phases ported, plus Phase 13, with the 5 unported phases
> printed by name and reason on every run. `chirality check` is the native
> compiler, not Python (`tools/test/check-cli.sh`), so CPython is off the check
> path too. See [[trust-boundary]] for the TCB delta and
> `.planning/FIXPOINT-CHECKLIST.md` for what remains.

> **⚑ Diagnostics & formatting arc — BUILT 2026-09-01.** Six elements landed on
> `master`, each through the full example → audit → SPEC → audit → implement
> pipeline. **Suite: 303 assertions, 0 failed, 11 phases, 88 roots, `gate PASSED`.**
> **`bin/chirality-bin` is 1,147,256 bytes** (was 1,098,104 at migration, then
> 1,130,872) and reproduces itself byte-identically — `N1 == N2`, fixpoint at
> generation one, verified after every promotion.
>
> | element | what it is | gate |
> |---|---|---|
> | **E157** | diagnostics as typed values — `ld-err`/`ck-err` carry a closed `Reason` with evidence, not a `str-cat`'d sentence | Phase 13, 30 |
> | **E158** | `Doc` — printf's template split from its flatten; `doc->str`, `doc->rendering` | Phases 14 + 17, 45 |
> | **E174** | `Rendering` gains `r-row` + a per-node width function; also repaired `apc.chiral`'s codec, which was **already red** | Phase 15, 41 |
> | **E175** | the ANSI close restores the **ambient face** instead of resetting to default | Phase 16, 38 |
> | **E181** | `surface/pretty` — the term printer repointed at the real 16-constructor `Term`, returning `Doc`; **moved from `typing/`** | Phase 18, 61 |
>
> **Two facts other work depends on.** (1) `typing/pretty` **no longer exists** —
> the key is **`surface/pretty`** (`MAP.md`: a printer checks nothing, so it is
> `surface/parse`'s inverse). (2) The compiler changed size twice in this arc; any
> measurement taken against an earlier binary was taken against a different one.
>
> **Unbuilt residue, all with rows** (in the untracked `.planning/` catalog —
> see *Where element detail lives*, below): E176 `str-sub` is unclamped and
> **segfaults** · E177 display-width table · E178 `r-table` per-column widths ·
> E179 the face registry becomes authoritative · E180 face-aware incremental
> redraw · E182 the arity judgments carry their arity · E183 `.protocol`.
> Lane B holds E146 · E163 · E183. Division and enforcement: **`docs/decisions/decision-lane-split.md`**.
>
> **⚑ Where element detail lives, and why this section exists.** `.planning/` is
> **untracked** (`.gitignore:12`, master's decision — the planning tier is private
> working material). So the element catalog, the ledger rows and every SPEC in this
> arc are **on disk and invisible to git**. Anyone reading the repo sees only
> `docs/examples/INDEX.md` and *this* file. That is the whole reason a build-state
> summary belongs here: an arc recorded only in `.planning/` did not happen, as far
> as a second reader is concerned. **It also cost a real collision** — two sessions
> independently minted `E173`, and nothing detected it until a merge put both INDEX
> rows side by side.


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

**Redefined 2026-08-31.** They used to measure which *substrate* ran a thing:
IMPLEMENTED meant "works on the Python/host substrate", and the TCB was named as
CPython plus the Linux syscall surface. That question is settled — CPython is off
the compile path and off the check path, and the self-hosting fixpoint holds — so
a rung defined by it measures nothing.

What the rungs measure now is **reach**: whether the built thing is actually
arrived at by a shipping path, and whether anything fails when you break it.
That is the distinction preserve-check and W^X were both filed on the wrong side
of.

- **DESIGNED** — the note describes it; no code realizes it.
- **SEEDED** — code exists and **nothing reaches it**. A partial, a stub, or a
  complete implementation that no shipping path calls. Built is not adopted.
- **IMPLEMENTED** — reached by a shipping path and it works, but **no gate fails
  if you break it**. It is load-bearing and unprotected.
- **ENFORCED** — structurally guaranteed and **gated**: a check in the kernel,
  the loader or the suite fails when the property stops holding. Breaking it
  turns something red.

The rungs are orthogonal to correctness, and the ladder is about exposure rather
than quality. A SEEDED thing may be perfect and simply uncalled; an ENFORCED one
may be crude and merely defended.

**The TCB is `bin/chirality-bin` and the Linux syscall surface** ([[trust-boundary]]).
The compiler is the maximal-authority process and it compiles itself, which is
the trusting-trust circularity `.planning/projects/02-language-design.md` and
[[certificate-discipline]] own. CPython is no longer in it.

⚑ **What ENFORCED still does not mean.** A gate defends against a mistake, not
against an adversary who controls the source. The three semantically distinct
judgment cores that would make agreement adversarial are **unbuilt** (HANDOFF
decision 5), so every rung on this page is enforcement against error.

## Built — ENFORCED

| Claim | Evidence |
|---|---|
| QTT core: term rep + checker (the trusted judgment) | `lib/surface/syntax.chiral` is the live full-ADT `Term` the kernel owns (`lib/surface/terms.chiral` is E13's closed-core differential artifact, not the one in the path); `lib/typing/kernel.chiral` is the judgment — `infer` / `check` / `conv` / `quote` / `subtype`. Reached by every compile: `lib/lowering/compile-front.chiral` → `lib/surface/parse.chiral` → `lib/module/loader.chiral` → the kernel. Gated by `tools/test/check-cli.sh` (Phase 3), which pins that it accepts well-typed source and refuses ill-typed source by name. ⚑ tests/test_kernel.py is CUT (Python oracle) |
| Quantities 0/1/ω resource counting | `lib/typing/qtt.chiral` — `Qty` as `q0`/`q1`/`qw`, the semiring `qadd`/`qmul`/`qjoin`, the audit `qfits`, and the usage vectors `uzero`/`uadd`/`uscale`/`ujoin`; consumed by `lib/typing/kernel.chiral`. `tools/test/check-cli.sh` rejects used-twice and dropped linear binders, both with `linear binder usage mismatch` |
| Linear types → **port aliasing control** | `lib/typing/kernel.chiral` `is-linear` (a property of the type, read off the `latoms`/`ldatas` registries the loader populates) + the binder rule at Pi/lam/let/field/apply; the loader-side twin is in `lib/module/loader.chiral`. Gated by `tools/test/check-cli.sh` and `tools/test/linear-mint.sh` (Phase 6: the let binder, the Pi binder, the extern arrow) |
| Strict positivity of datatypes | `lib/surface/data.chiral` — the E7 walk (`walk`/`walk-args`/`ctors-ok?`) with the per-param strict-positivity cache `compute-sp`, called live from `lib/module/loader.chiral` at data install. Verified 2026-08-31: a datatype with a negative recursive occurrence is refused, `not strictly positive` |
| Floor agreement of the arithmetic prims (by collapse) | `lib/lowering/upper/optimize.chiral` `fold-prim`/`fold-cmp` and `lib/lowering/tal/eval.chiral` `eval-prim` both compute on chirality's own I64 `+ - * / %`, so the constant folder and the reference machine cannot disagree by construction; see [[floor-agreement]]. ⚑ The collapse is now at the *primitive*, not at an import — the two are separate dispatch chains over one set of prims, and test_optimize.py / test_native.py, which pinned the agreement, are CUT (Python oracle) |
| A total matcher over `Str`, returning spans (E173 slice 1) | `lib/text/matcher.chiral`, 533 lines: Antimirov partial derivatives, with `pd` the residual, `norm` the line the live-set bound lives in, and `find-all` one pass whose threads carry their own start offset. Reached by `prog/prose-lint.prog`, its first consumer. Gated by Phase 19, `tools/test/matcher.sh`: 18 assertions and 12 mutants, none inert, each mutant pinning the full verdict line. G9 runs the eight native checks against the awk tool over 80 files through `prose-lint --summary`, where the totals agree exactly (em-dash 906, antithesis 392, copula-negation 159, parallel-no 8). Suite measured 2026-09-01: 321 assertions, 0 failed, `gate PASSED`. ⚑ **Slice 1 only.** Captures are slice 2 of E173 and unbuilt. ⚑ **Eight checks against awk's ten.** `self-reference` and `first-person` have no implementation here and the native tool prints them as NOT-CHECKED rows. ⚑ **G10 observes termination and does not prove it.** A `pd` whose `p-star` arm recurses into `(p-star q)` compiles OK, because the Totality row below records that `lib/typing/totality.chiral` is imported by nothing, so G10 runs the mutant under an 8 MB stack and a 20 s ceiling and observes the divergence, with the base tree reaching its sentinel under the same limits as the control. BA-39 in [[records/baseline-alignment]] carries the history. ⚑ The wall clock is unmeasured in this tree and `docs/benchmarks/` has no file for it. |

## Built — IMPLEMENTED (reached by a shipping path, no gate defends it)

| Claim | Evidence |
|---|---|
| Dependent types (Pi, value-indexed `(Pool n)`) | `lib/typing/kernel.chiral` (`v-pi` + the `t-pi` former from `lib/surface/syntax.chiral`); `lib/ports/pool.port` declares the indexed `porttype Pool` and the size-indexed `PoolR`/`PoolReadR`, imported through `lib/ports/ports.chiral` |
| Subtyping | `lib/typing/kernel.chiral` `subtype` — conversion + universe cumulativity + the `v-refine` rules, with `subtype-into` for the refine-into-refine case (mechanism present; not applied to grant narrowing) |
| tal floor: independent checker + trusted-drop interpreter | `lib/lowering/tal/check.chiral` (the checker, a threaded register-file Gamma, verdict as a value) + `lib/lowering/tal/eval.chiral` (the fuel-bounded reference interpreter), over the one shared IR `lib/lowering/tal/ssa.chiral`. ⚑ Neither is on the compile path: nothing imports `lib/lowering/tal/eval.chiral`, and `lib/lowering/tal/check.chiral` is reached only from `lib/lowering/upper/optimize.chiral` (unimported) and `lib/lowering/upper/eff-lower.chiral` (reached only from `lib/module/sig-driver.chiral`, whose Phase 8 is not ported). tests/test_tal.py is CUT (Python oracle) |
| Lowering: pure fragment → tal | `lib/lowering/upper/lower.chiral` — the E16 eligibility partition (`ttype`, `eligible?`/`skip-reason`, the lowered/skipped split) plus `compile-fn`, imported by `lib/lowering/compile-back.chiral` and so live in every compile. ⚑ The 48/48 figure was a Python-era count: UNVERIFIED here, nothing in the tree measures it |
| Native backend: chirality emitter → x86-64 | `lib/lowering/x64/emit.chiral` + `lib/lowering/x64/mach.chiral` (the one conforming `Mach`; all opcode and register knowledge lives there) over the ISA-agnostic `lib/lowering/mach/emit-core.chiral`, with `lib/lowering/x64/elf.chiral` writing the static ELF — no LLVM/Cranelift, and live in every compile via `lib/lowering/compile-emit.chiral`. ⚑ tests/test_native.py is CUT (Python oracle), and the benchmark run below predates the migration and has not been re-run. Measured `docs/benchmarks/RESULTS-2026-08-01.md` (7 runs) — bare emitter within 1.0–1.5× gcc -O0; with the first opt pass (inline byte ops, const fold, immediates, pow2 sar/and, TCO) ahead of -O0 outright; with the trait-native tier (guard elision, total-call folding, CSE, lookup tables — `docs/benchmarks/TRAIT-OPTS.md`) 1.4–8.4× behind -O2 (compute-bound 1.37×), whole-series native speedup 2.9–10.2× at equal load (ratios only) |
| specialize / pregen primitive | `lib/lowering/upper/optimize.chiral` `specialize`/`specialize-raw` (partial evaluation over the typed tal IR; meaning-preserving, makes no cost claim, returns a `Checked` so the residual is re-judged). ⚑ Nothing imports `lib/lowering/upper/optimize.chiral` — built, unadopted |
| Memory discipline as a profile choice | `lib/memory/mem-linear.chiral`, `lib/memory/mem-region.chiral`; the `(memory linear)` / `(memory region)` profile clause is parsed and judged in `lib/surface/parse.chiral` and gated by `tools/test/profile-target.sh` (Phase 4), which pins both the accepts and the refusal of an unknown discipline. ⚑ tests/test_memory.py is CUT (Python oracle) |
| Inbound bridge verification | **CUT (Python oracle).** bridge.py had no chirality successor and there is no bridge module under `lib/`. `lib/lowering/tal/sys-linkage.chiral` still describes re-seating `bridge.verify` on each wrapper's return, so the inbound membrane it names has no implementation in this tree |
| Frozen-port-set conformance | `lib/surface/parse.chiral` parses, judges and stores the `(profile ...)` manifest over its frozen port set; the refusal point is `emit-elf-m` in `lib/lowering/compile-emit.chiral` (H8, per-program). Gated by `tools/test/syscall-manifest.sh` (Phase 5) and `tools/test/profile-target.sh` (Phase 4); profiles in `prog/demo/` (named crossings only; edge 18 open). ⚑ There is no `chirality verify` subcommand — `bin/chirality` is compile / run / check / test |
| Surface syntax | `lib/surface/sexp.chiral` (the reader), `lib/surface/surface.chiral` (the elaborator, `Surf` → `Core`) and `lib/surface/parse.chiral` (the top-level form dispatch and the composition manifest) — all three in the compile path via `lib/lowering/compile-front.chiral` (s-expr surface; the real surface is stage 4) |
| Sys-face syscall crossings + self-hosted arena (E21) | `lib/lowering/tal/sys.chiral`: write / read / lseek / memfd_create / ftruncate / mmap / munmap, and — since E28, contrary to this row's old parenthetical — `nb-sys-mprotect-t` and `nb-sys-close-t` too, alongside the socket, pty, poll, fork/exec and clock crossings; routed by `lib/lowering/tal/crossing-wraps.chiral` and `lib/lowering/tal/sys-linkage.chiral`. chirality sizes+maps its own anonymous file, byte-roundtrips, unmaps. ⚑ "differentially tested" meant the CPython differential, which is CUT |
| Orchestration substrate (json, http+SSE, backend iface, fsm, manas coordinator) | `lib/protocol/json.chiral`, `lib/protocol/http.chiral`, `prog/manas/backend.chiral`, `prog/manas/fsm.chiral`, `prog/manas/coordinator.chiral`; the roots under `prog/manas/` are swept compile-only by `tools/test/run-tests.sh` Phase 7. E51 linkage to the self-hosted sys-face is still open. ⚑ The `test_http` / `test_manas` / `test_backend*` suites are CUT (Python oracle), and so is the CPython transport they ran over: `http-request` and `backend-open` have no entry in `lib/lowering/tal/crossing-wraps.chiral`, so this substrate type-checks and lowers but has no referent to run against |

## Built — SEEDED (code exists, nothing reaches it)

| Claim | What exists / what does not | Evidence |
|---|---|---|
| Refinement types | I64 conjunction of atoms over a **constant or a bare in-scope variable** (`v < n`), with **path-sensitivity** for both (a comparison-guarded branch learns the bound it proves — `_narrow`/`sig.narrow_hooks`); a symbolic bound collapses to a constant on instantiation (Pi re-evaluation), keeping subtyping sound; constant part sound+complete, symbolic part sound (syntactic entailment, no arithmetic between variables); only arithmetic-expression bounds (`v<n+1`) remain out | `lib/typing/refine.chiral` — `Constraint`, `entails`, `is-empty`, and the `narrow` atom-selection hook; `lib/surface/syntax.chiral` carries the `t-refine` former and `RfAtom`, whose operand is a `Term`, so shift/uses traverse it; `lib/typing/kernel.chiral` holds the `v-refine` value, `subtype`/`subtype-into`, and the case-guard path-sensitivity hook (`narrow-branch`/`narrow-side`/`ctx-narrow`). ⚑ test_refine.py, with TestPathSensitivity and TestSymbolicRefinement, is CUT (Python oracle) and no phase exercises the refinement fragment. Note also that kernel.chiral's own narrow-seam comment still says the chirality kernel `Value` has no `v-refine` form; it has one |
| Effects | one coarse pure/process bit at 3 judgment points, and **nothing calls those 3 points (re-measured 2026-08-31)**. They are native now, in `lib/typing/effects.chiral`, so the older reading *"in the Python oracle only"* is retired: they are in this tree and unreached. `bin/chirality-bin` compiles and RUNS a `->` def that calls an `=>` one, the crossing really happens, so the bit is carried natively and refused nowhere ([[banks/effect-and-alarm]] §5d; the gate is E171). The two-facet effect algebra (possession + exercise, edge 16) is settled on paper — [[decision-effect-facets]] — and unbuilt | `lib/typing/effects.chiral` — the E12 membrane, generalized to set-containment: `on-apply-ok`, `erased-allow`, `on-binder-ok`, plus `row-sub`/`row-join`. ⚑ Those three refusing rules have **no caller anywhere in the tree**: the module's only importers, `lib/typing/row-infer.chiral` and `lib/lowering/upper/eff-lower.chiral`, take `row-join`/`row-sub`/`mem-str` and nothing else. effects.py, the row's old answer to *where the seams live*, is CUT, so the bit is now carried and refused nowhere at all. ⚑ **E171, re-scoped 2026-08-31 against the oracle's deletion.** Its catalog row (E171 in `docs/elements/catalog.md`) was minted to port the oracle's three seams into the compiler that compiles everything. Those seams are already here and already generalized to set-containment, so what E171 owes is not the rules but the **caller**: reach `on-apply-ok`/`erased-allow`/`on-binder-ok` from `lib/typing/kernel.chiral`'s apply and binder judgments, so a `->` body cannot reach a crossing transitively. The direction is unchanged by the deletion, being fixed by P2 (no category opts out of the type) and P3 (the port-check is the type-check); blast radius, granularity against E160/E161's module-level port-set claim, and infer-vs-annotate stay open to E171's own pre-run, exactly as its row already says. ⚑ That row and the matching E171 row in `docs/elements/ledger.md` still cite scaffold/chirality/effects.py:23,38,46 and scaffold/lib/effects.chiral, deliberately un-backticked here because the hoist deleted both. The live homes are `lib/typing/effects.chiral` and `lib/typing/kernel.chiral`, whose own comments at lines 14-15, 898 and 1001 still say the seams are owed.|
| Totality | two of the three pillars built and refusing: strict positivity and case coverage ([[totality]]). The third, termination, is **SEEDED**: `lib/typing/totality.chiral` is the built E11 classifier and no module imports it, so it is unreached rather than absent (measured 2026-08-31). What it holds, for when something reaches it: it proves **structural** (a case-bound field shrinks) *and* **numeric measure** (a parameter stepped toward a bound a guard proves — a constant with wraparound excluded, or a *variable* `n` with `±1` step and `n` unchanged) recursion — `row-bytes`, every constant-guarded counting loop, and variable-bounded loops prove; it *classifies* (records `sig.totality`), not yet globally *enforced* — unprovable recursion (non-unit-symbolic/lexicographic/mutual) type-checks unless `sig.require_total` or a profile's `(total)` clause. Wiring it is E11's remaining work; no new element is owed. | Two pillars are live and refuse: positivity via `lib/surface/data.chiral` + `lib/module/loader.chiral` (`not strictly positive`) and case coverage via `lib/typing/kernel.chiral` + `lib/typing/diag.chiral` (`non-exhaustive case`). **Termination is neither enforced nor classified in the built compiler**: `lib/typing/totality.chiral`, the E11 structural + numeric-measure classifier, is imported by nothing, and `lib/surface/parse.chiral` says in its own header that the `(total)` profile clause is parsed, judged and stored with enforcement elsewhere — measured 2026-08-31, a profile carrying `(total)` over an unguarded self-call checks OK. `prog/demo/verify-total.chiral` is the demo (its own header still invokes the retired `python3 -m chirality verify`); `tools/test/profile-target.sh` gates the clause's *parse*, not its proof. test_kernel.py's TestTermination and TestTotalityProfile are CUT (Python oracle)|
| Syscall gating | `sysface` confinement mark + no surface path to `sys`; **not** a numeric allowlist (the number is an arbitrary immediate) | `lib/lowering/tal/sys-check.chiral` — the E76 default-deny chokepoint — over the swappable permitted set in `lib/lowering/tal/target-linux.manifest`; the refusal itself is in `emit-elf-m`, `lib/lowering/compile-emit.chiral`. Gated by `tools/test/syscall-manifest.sh` (Phase 5), which poisons the registry inside the compiler's own blob and shows the compiler built from it refuses to emit |
| Broker | spawn / teardown / link-at-load only; grant / revoke / audit not built | Spawn and teardown: `lib/runtime/proc.chiral` (E33 `proc-spawn`, one return with a linear `Reap` obligation) and `lib/runtime/supervisor.chiral` (E42 supervised loop). Link-at-load: `load-extern`/`load-extern-linear` in `lib/module/loader.chiral`, with the crossing→wrapper table in `lib/lowering/tal/crossing-wraps.chiral`. grant / revoke / audit: no code |
| Staging | `spawn` + link-at-load, ad hoc; the binding-time *modality* is designed | The same two sites as Broker: `lib/runtime/proc.chiral` and `load-extern` in `lib/module/loader.chiral`. Nothing represents binding time in a type |
| Secret custody (first slice of [[modules-custody]]) | **type-level** discipline only: opaque linear `Secret`, single greppable guarded exit. It **type-checks and lowers, and has no referent to run against**: `secret-seal`/`secret-reveal`/`secret-wipe` have no entry in `lib/lowering/tal/crossing-wraps.chiral` (verified 2026-08-31), the same shape as `http-request` and `backend-open` in the row above. Host-copy hygiene partial (`secret-reveal` returns immutable `bytes` it cannot zero); memory custody absent. Redundancy / datum-policy not built | `lib/capability/secret.chiral` — `porttype Secret` with `secret-seal` / `secret-reveal` / `secret-wipe` and the `send-revealed` legal path; `prog/demo/passman-min.chiral` type-checks under `chirality check` (verified 2026-08-31). ⚑ The impl_ports.py referent is CUT and none of the three externs appears in `lib/lowering/tal/crossing-wraps.chiral`, so the discipline is checkable but nothing executes it. test_secret.py is CUT; `tools/test/samples/e170_reject_secret_leak.prog` is a fixture with no runner — Phase 12 is not ported|
| **preserve-check** *(demoted from ENFORCED 2026-08-31: built, unadopted)* (lowering *and* optimizer re-check at the floor) | `lib/lowering/tal/check.chiral` is the independent floor judgment (`ck-fn`/`ck-prog`) and `lib/lowering/upper/optimize.chiral` `re-check` is the one caller — its `chk-ok` cannot be formed without it. ⚑ **Neither runs in the shipping compile.** `lib/lowering/upper/lower.chiral` does not import `lib/lowering/tal/check.chiral` and calls no `ck-fn`; nothing in `lib/` or `prog/` imports `lib/lowering/upper/optimize.chiral` at all. test_optimize.py is CUT (Python oracle) and no phase replaces it |

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
what `lib/runtime/` actually holds is `poll.chiral`, `proc.chiral` and
`supervisor.chiral`: a coarse-`=>` supervised loop, a process face, a poll face.
The rung-2 halves have no rung-1 referent and `supervisor.chiral` says so) ·
arithmetic-expression
refinement bounds (`v<n+1` — bare-variable bounds are SEEDED above; the pool offset is compile-time checked via `mem-put-checked`).
| W^X loader *(demoted from IMPLEMENTED 2026-08-31: the built path emits RWX)* | ⚑ **NOT HELD in the built path.** `lib/lowering/x64/elf.chiral` emits **one RWX** `PT_LOAD` — its own comment says "RWX (PF_R + PF_W + PF_X = 7), not RX" because the bump-pointer cells live in the image, and names the split as "the named W^X follow-on"; `readelf -l` on the committed `bin/chirality-bin` reports a single RWE segment (verified 2026-08-31). The map-RW → write → `mprotect` R+X host JIT loader this row described was native.py, CUT (Python oracle). `lib/lowering/tal/sys.chiral` `nb-sys-mprotect-t` exists but the arena uses it for PROT_NONE → RW commit, not for W→X separation |

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
3. **Cost is settled-on-paper, unbuilt.** `lib/typing/qtt.chiral` still carries
   only 0/1/ω; the typed-cost thesis has no grade structure yet.
4. **Totality does not gate, and no longer classifies either.** Positivity and
   coverage refuse live, but the termination classifier
   (`lib/typing/totality.chiral`) is imported by nothing, and a profile's
   `(total)` clause is stored without being checked — an unguarded self-call
   under `(total)` checks OK (measured 2026-08-31). This is weaker than the
   "classifies but does not gate" this list claimed.
5. **The `runtime` note describes a different artifact than the built
   `lib/runtime/`.**

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
