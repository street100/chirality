---
node: banks/verification
layer: bank
tier: depth
related: [testing-floors, floor-agreement, certificate-discipline, split-role, decision-split-checker, axis-altitude, modules-lowering, trust-boundary, status-ledger, banks/evidence-and-split, open-edges]
status: draft
updated: 2026-09-04
---

# Bank: verification

> **⚑ THE C LEGS ARE DROPPED, 2026-09-01** (`d8bcec5`, `d0c5dd5`).
> `lib/lowering/c/{mach,assemble,emit}.chiral`, `prog/compiler-c.prog` and the
> four `e166_*` fixtures are deleted. Shard 8 below, §5 item 8, and every gate
> count, ratio and mutant result attached to `mach-c` are the **record of a leg
> that ran**, kept because a bank's job is the refraction and its history, and
> dated in place. They are not claims about today's tree.
>
> The reason is the criterion. The leg shared `compile-front` and `compile-back`
> whole with the canonical instance and differed only at emit, which makes it a
> second **target** under one formulation. Verification
> here goes through N semantically distinct judgment cores that must agree; three
> encodings of one rule set would be worth nothing, and one encoding emitted
> twice is less than that. See [[decision-self-verification]].
>
> **Three consequences this bank has to carry.** (1) `ddc-leg0` has **no**
> disjoint partner in the tree now, so Shard 4's *"DISCHARGED 2026-08-24"* is
> re-opened by the drop and the DDC quorum floor is unmet again. (2) `ddc.chiral`
> keeps `ddc-legc`, `ddc-legcc`, `ddc-fold`, `ddc-legs`, `ddc-compare`,
> `ddc-verdict-code` and `DdcR`, and **nothing calls or asserts any of them**;
> the file stays reachable only because `test-floor.chiral:31` imports it for
> `bytes=?`. (3) `lib/memory/alloc-fixed.chiral` lost its only importer with the
> C-leg blob. See [[open-edges]] for both.
>
> **What the drop does NOT retract.** Rules 1, 2 and 3, the adequacy limits in
> §5, and the mutants that were actually run. Those are findings about
> differentials in general and survive the leg that produced them.
>
> ⚑ **This banner shifted every line below it by +30.** A `verification.md:NNN`
> citation written before 2026-09-01 lands 30 lines early.

> **What a bank is.** The depth tier under the thin relational notes in
> `docs/`. A bank holds the full *refraction* of ONE concept: what it is, the
> shards it decomposes into with their principled homes and honest build-state,
> the cross-cuts where one shard *is* a shard of another concept, and the
> native monoliths it gets mistaken for.
>
> **Why this bank exists.** Two reasons, and the second is the embarrassing one.
> (1) The monolith is **"tests"** — a single undifferentiated suite you run, with
> a percentage attached, that either is or is not green. chirality does not have that
> and cannot have it: what it has is a *layered set of independent instruments*,
> each blind above its own branch point, ranked by where its expected values came
> from. (2) Almost all of the design reasoning behind that architecture — the
> branch-point rule, the ratio rule, the bisection argument for a second C seam,
> *"`preserve-check` is already a translation validator"* — was written into
> **commit messages** during one session (2026-08-23) and nowhere else. Commit
> messages are provenance, not the note base. This bank is where that reasoning
> comes home.
>
> **Relationship to [[testing-floors]].** That note is the *contract*: which
> floors gate, which advise, the coverage map, the provenance ranks, the mutant
> rule, and the discipline that retires Python. This bank is the depth tier under
> it and does not restate it — it **refracts** it: which shard of verification
> lives where, what is actually built, and where a shard of verification turns out
> to be a shard of [[certificate-discipline]], [[split-role]], or
> [[axis-altitude]] wearing a different name. Build-state is AUTHORITATIVE from
> `records/conformance-map.md` and [[status-ledger]]; where a facet is
> genuinely unbuilt it is named as such, never rounded to done — and where it is
> built-but-not-green, that is said too.

---

## 1. The concept in chirality

**The one-sentence truth.** Verification in chirality is **a layered set of
independent instruments, each of which can only see what is below its branch
point, ranked by the provenance of the expectation it checks against** — not a
suite, not a number, and not the fixpoint.

**What verification IS.**

- **Instruments, plural and independent.** The native behavioural suite, the
  self-host fixpoint, `preserve-check`, the DDC differential, the Python oracle,
  the Rocq external spec. Each answers a *different* question. `chirality test`
  running them all is a convenience, not a unification.
- **Structural, not statistical.** The question is never "what fraction of lines
  ran" but "which stage of the pipeline does this instrument's branch point sit
  below, and how big is the new code relative to what it tests" — the two rules
  in [[testing-floors]]'s coverage map.
- **Provenance-ranked.** An assertion is only as strong as the independence of
  the thing that supplied its expected value. An expectation derived from the
  implementation under test is a regression net; an expectation from Rocq or
  CompCert is a correctness claim. The ranks are the contract's, §*Expectation
  provenance*.
- **Falsifiable by construction.** A gate row must name a mutant that breaks it
  **and the mutant must be run.** Both of this session's near-misses were gates
  that named a correct mutant and would have shipped green without running it.

**What it IS NOT.**

- **NOT the fixpoint.** `B1 == B2` byte-identical proves **stability, not
  correctness** (`rocq/README.md`; [[testing-floors]] §*Why Python is advisory*).
  A compiler that miscompiles *consistently* fixpoints perfectly. That gap is the
  entire reason the rest of this bank exists.
- **NOT coverage percentage.** See §4.
- **NOT "the test suite."** There is no single suite. There is a *quorum* with a
  refusal condition (`ddc-bad-quorum`), a gating set, and an advisory set.
- **NOT self-certifying.** The checker cannot prove itself — [[decision-split-checker]].
  It can be proved *against an external spec*, which is why `rocq/` exists at all.

---

## 2. The refraction — the shards, their homes, their build-state

### Shard 1 — the self-host fixpoint · **BUILT (rung-1, 2026-08-05)**
- **What.** Compile the blob with B1, run the result over the same blob, byte-compare.
- **Home.** The build ceremony — `.planning/BUILD-ORDER.md`, `CLAUDE.md`'s build rule.
- **Build-state.** BUILT and routinely run (~1s). **What it proves is stability,
  not correctness.** `BUILD-ORDER.md` records the sharpest available proof of the
  limit: a *reversed-but-total* comparator passed the fixpoint at identical byte
  size. A fixpoint check is not a correctness check.

### Shard 2 — `preserve-check` (types held to the floor) · **CONFORMS (E16)**
- **What.** Every compiled body is re-checked against its declared type at the tal
  floor; every optimizer pass is a tal→tal transform re-run through it.
- **Home.** [[modules-lowering]] — `lower_all` / `tal.check_fn`.
- **Build-state.** BUILT and ENFORCED (`CONFORMANCE-MAP.md:65`, "Fully built";
  optimizer row :66). **And it is already a translation validator** — it re-checks
  each compilation's output against a specification of that output, per
  compilation, which is structurally CompCert's own technique for its hard passes.
  Two caveats, both load-bearing: it checks **types, not behaviour**, and **the
  checker itself is unverified**.

### Shard 3 — the native behavioural suite · **BUILT**
- **What.** `.chiral` programs whose *meaning* fixes an exit code, run natively.
- **Home.** `tools/test/run-tests.sh` (Phase 1 inline) + `tools/test/samples/`
  (55 `.prog` roots as of 2026-09-04, walked by the native test-runner
  `prog/test-runner.prog`). ⚑ Every figure in this shard's build-state below was
  measured against the pre-migration paths and has not been retaken.
- **Build-state.** BUILT and GATING: **twelve phases, 175 ok assertions / 0 FAIL /
  82 roots, exit 0 in 4m10.591s** (measured 2026-08-25 at `f9441e4`, `ulimit -s
  unlimited; time bash scaffold/tests/run-native.sh`, C leg on
  `/opt/compcert/bin/ccomp`; the *"172 ok / 3m44.647s"* this shard carried was
  the `4320470` figure, and the three rows since are E168's own follow-on fixes,
  G9's two swap refusals and G10's fail-open row; *"eleven phases, 163 ok"*
  before that was pre-E168). Zero Python in the
  path. **Phase 2** is E168's adopter — the six samples are a `Suite` of
  provenance-carrying `Expect`s, and the phase REBUILDS
  `scaffold/build/test-runner` from source before running it. **Phase 12** is
  E168's conviction: the three recorded could-not-fail SHAPES -- two near-misses
  and one mutant retired at design time, none of them shipped -- as fixtures the
  floor scores RED, **12 asserted rows** over 11 fixtures (the phase's own `12
  passed, 0 failed` line at `f9441e4`; it was nine at `4320470`). This is the primary correctness gate. **Phase
  10** runs E166's external-compiler leg in its `--no-admission` form, so the C
  leg gates through the primary suite rather than beside it; `CHIRALITY_C_LEG_SKIP`
  stops the recursion when the leg script is itself re-running this suite for
  admission. **Phase 11** (E155/E161 resolver + build-state, **19 assertions**)
  was wired in at `70ee90f` after sitting orphaned since E155.
- **The whole suite is overridable by ONE variable, and until 2026-08-25 it was
  not.** `CHIRALITY_BIN` selects the compiler for every phase — that is the
  mechanism E166's admission gate runs on. It was honoured by `run-native.sh`'s
  own inline phases only; five sub-scripts re-derived the compiler and two more
  went through `bin/chirality`, so seven phases silently ran under `B1` during an
  admission run. Fixed at `ce593c4` and mechanized as `ledger-lint` **check P**
  (a suite script naming `scaffold/build/B1` must consult `CHIRALITY_BIN`).

### Shard 4 — DDC / diverse double-compilation · **BUILT-compare-core (E53); a second disjoint leg standing (E166)**
- **What.** Wheeler's construction: two provenance-disjoint legs compile the same
  source; agreement admits, divergence is named and localized.
- **Home.** `lib/evidence/ddc.chiral` (**213 L** at `wc -l` on 2026-09-04, pure
  compare core: `Prov`/`Leg`/`DdcR`/`LegOut` + first-divergence fold, every fn
  proven total). ⚑ Both drivers are gone: the untrusted Python one went with the
  oracle, and the C-leg script went with the leg on 2026-09-01. The file says so
  itself at `:21-22`, "Its teeth are GONE as of 2026-09-01 … nothing asserts any
  of this now." The compare core stands with no caller.
- **Build-state.** Compare core BUILT (`CONFORMANCE-MAP.md:45`, CONFORMS, E53).
  **One honest narrowing survives, one is discharged.** (a) SURVIVES — `Prov` has
  four axes `(language toolchain author epoch)` but `leg2-disjoint?` checks
  **two** of them — `author` stays `"shred"` for every leg, and `ddc.chiral:14`
  already concedes that *"author is assertable only — recorded, not laundered."*
  The axis actually bought is **toolchain**, which is the one a Thompson attack
  lives on. (b) **DISCHARGED 2026-08-24.** Leg 1 is still
  `py-scaffold (python / cpython3) tal.TalMachine` and still dies with the Python
  oracle — but it is no longer the only leg disjoint from `ddc-leg0`.
  `ddc.chiral:162` now carries
  `(def ddc-legc Leg (leg "c-external" (prov "c" "gcc-12" "shred" 2026)))`, and
  gate G5 of the leg script checks `prov-disjoint?` over `(ddc-leg0, ddc-legc)`
  plus 36 quorum cases (13 as first built; ten added 2026-08-25 for the CompCert leg, four of them asserting that the two C legs are **not** disjoint from each other; thirteen more when `ddc-compare` was fixed at `f713ec8`). ⚑ **Until that fix the floor was declared and not enforced:** `ddc-compare` folded bytes and never called `prov-disjoint?`, so two legs with identical provenance — a compiler agreeing with itself — returned `ddc-converged`, and case 21 asserted exactly that for the two C legs. It now refuses before reading a byte, with `"provenance not pairwise disjoint"` kept distinct from the two arity reasons. So `ddc-bad-quorum`'s floor of two disjoint legs is met
  **without Python**, and S12's ordering constraint — *admit the replacement
  before deleting the incumbent* — is satisfied for the DDC half of the
  retirement. It is not satisfied for the rest of Shard 5's dependents (§3 C6).
  ⚑ **RE-OPENED 2026-09-01.** The C leg is dropped, so `ddc-leg0`'s only disjoint
  partner in the tree is gone again and the floor of two disjoint legs is unmet.
  Nothing asserts the 36 quorum cases either: `e166_ddc_legc` was deleted with
  the leg.
  ⚑ **What is registered is the leg, not yet the pairing.** `ddc-verdict-code`
  (`ddc.chiral:185`; the `:129` this note carried was stale before the fix too)
  still composes `ddc-leg0` with `ddc-leg1` — disjoint on both axes, so it
  converges unchanged through the new gate —; the C leg is a
  standing constant that the script gates, not the default second opinion inside
  that one function. Swapping it is a one-constant change and is not done.

### Shard 5 — the Python oracle (the external-verification leg) · **CUT**
- **What.** A differential second opinion via the reference interpreter/checker.
- **Home.** ⚑ **none.** `scaffold/chirality/` is gone, and
  `docs/decisions/decision-scope.md` consequence 1 records the cut. The 14 `.py`
  files left in the tree on 2026-09-04 are the authoring harness under `tools/`
  plus four example generators, and none of them judges chirality.
- **Build-state.** ⚑ **CUT, recorded 2026-09-04. There is no running external
  leg at all.** The paragraph below is the record of the last repair while it
  ran, dated 2026-08-23:
  **348 → 638 tests running**, errors **318 → 88**, failures 23 unchanged.
  290 tests were not *executing* at all (`setUpClass` died before discovery), so
  the suite reported a small green-ish number while most of it never ran. Four
  independent causes, none of them "it is stale": no libdir fallback in the
  loader, no knowledge of E160's `kind` / E161's `module`, data groups installed
  in file order rather than as a planned group, and two tests carrying their own
  rotted private resolver. **It is not green.** 88 errors / 23 failures remain and
  need per-case adjudication — some are real differentials doing their job.
  Standing correction from that repair: *a failing external check is a failing
  check, not an advisory note* — filing it as "NEEDS-AUTHOR, non-blocking" for
  three elements was the error.

- **Scope, enumerated.** What "retire the oracle" actually covers is not this
  bank's to hold and not [[testing-floors]]'s either: it is
  [`.planning/RUNG1-CHECKLIST.md`](../../.planning/RUNG1-CHECKLIST.md) Phase C
  **§C-inventory** (measured 2026-08-24: **133 `.py` / 29,243 LOC** in tree —
  102 files owned by C3/C5/C6a/C6b, **988 LOC** that no row owned until C7, two
  named judgment calls, and ~4,400 LOC of authoring harness explicitly out of
  scope because it is not chirality). `ledger-lint` **check O** reads that table and
  fails on any unclassified `.py`. Two claims that measured *false* are recorded
  there so they are not re-raised as blockers: `refine.py`'s `_OPS` is not a
  stranded semantics fact (`refine.chiral:11` owns the op set as a closed sum;
  the Python is merely *cited* as authority in five docs — A5 rot, a
  `doc-audit` item), and `interp.chiral` does not run on Python (it imports
  `prelude` only; it is differentially *checked against* `runtime.py`, which is
  Shard 9's dependency, not a build one).

### Shard 6 — the Rocq external-spec leg · **SEEDED ONLY**
- **What.** An independent formalization of chirality semantics, proved under `coqc`;
  the only instrument that survives a *consistent* miscompile in our own tree.
- **Home.** ⚑ **none in this tree, measured 2026-09-04.** `rocq/` does not exist
  and `docs/decisions/decision-scope.md` consequence 1 cuts Rocq with the rest of
  external judgment. What it held is recorded here as history: `Chirality/I64.v`
  (64 L) + `Chirality/I64Spec.v` (183 L), `HAMMER-MANIFEST.md`, the hammer loop.
- **Build-state.** SEEDED. ⚑ *Corrected 2026-08-25 — the blanket "no toolchain in
  this environment" was already stale and is now measurably false.* `coqc 8.16.1`
  is installed (it cannot read `rocq/Chirality/*.v`, which use Rocq-9's
  `From Stdlib Require Import` — a source question, not an absence) and
  **`ccomp 3.17` is built and working**, from the INRIA tarball on Debian `main`'s
  coq/ocaml/menhir, with **no `opam` involved**. `opam` remains absent and
  unwanted. `gcc 12.2.0` is present. Two facets of one integer type is still the
  whole of the formalization. `rocq/README.md:81` names
  *"checker soundness is the next slice"* — i.e. the shard that would close
  [[decision-split-checker]]'s gap is not started.

### Shard 7 — expectation provenance + the run-the-mutant rule · **DOCS ONLY**
- **What.** Every assertion names the rank of its expected value's source
  (external > independent in-house reference > meaning-of-the-form hand-derived >
  implementation-derived golden, admissible only when labelled a regression net);
  every gate row names a mutant *and runs it*.
- **Home.** [[testing-floors]].
- **Build-state.** **BUILT for gates written on the floor, DOCS-ONLY elsewhere —
  E168, 2026-08-25.** `lib/evidence/test-floor.chiral` makes both mechanical: an
  `Expect` has no arity that omits its `ExProv`, so an unlabelled expectation is
  not constructible, and a `Gate` cannot be built without a `MutRun` that only
  `mut-run` produces — from two programs that were built and run. The residue is
  honest and large: the eleven phases E168 did not re-express still carry the
  discipline by hand, and that migration is **E170**. The reason
  this cannot wait for the migration: expectation source is a **parameter** of the
  test, so declared, swapping Python→CompCert is a data change — implicit, as it
  is across the differential corpus today, it is **335 rewrites**.
- **⚑ A live instance, measured 2026-08-25 — the mutant was never run, and the
  gate is the README's.** `README.md`'s *"effect membrane — pure code
  structurally can't do I/O"* line is demonstrated by `chirality check
  demo/_eff.chiral` → `load: type mismatch`, exit 1. It does fail. It fails for
  the **wrong reason**: `prog/demo/_eff.chiral:3` is `(def f (-> I64 Unit)
  (lam (n) (put 42)))`, and `put` is `(=> Str Unit)`
  (`lib/ports/stdio.port:11`), so the refusal is the **argument**
  mismatch `I64`-where-`Str`-is-wanted. Mutate it the one way the claim requires
  — `(put "x")`, same `(-> I64 Unit)` signature — and it compiles under
  `scaffold/build/B1` and prints. Running the mutant is the whole difference
  between a demo and a gate, and nothing was checking that it had been run. The
  membrane hole this exposed is [[banks/effect-and-alarm]] §5d, minted as
  **E171**.

### Shard 8 — the C legs · **`mach-c` BUILT 2026-08-24, DROPPED 2026-09-01 (E166) · `tal-c` DESIGN (E167)**

> ⚑ **The whole of this shard below is historical as of 2026-09-01.** `mach-c`
> was built, gated and registered, and is now deleted; `tal-c` is a catalog row
> and nothing else, and was never built. Nothing in this shard describes a file
> that is on disk today except `ddc-legc` and `ddc-legcc`, which survive in
> `lib/evidence/ddc.chiral` with no caller.

- **What.** Additional conforming backend instances that emit C-as-portable-
  assembly, compiled by an *external* compiler — **both gcc 12.2.0 and CompCert
  3.17, in the committed tree, with `ccomp` the default** since 2026-08-25 —
  giving DDC its first genuinely non-in-house leg. `ddc-c-leg.sh` runs 9/9 green
  under either (`CHIRALITY_C_LEG_CC` selects; the version banner prints on every
  run), G4 convicting byte-identical at **1,077,624 B under both**. ⚑ The two C
  compilers are **not two legs**: `leg2-disjoint?` needs both language and
  toolchain to differ and they share `"c"`, so `ddc-legc` (gcc) and `ddc-legcc`
  (CompCert) are alternatives, and a quorum is leg 0 plus *exactly one* of them.
- **Home.** `lib/lowering/mach/mach.chiral`'s backend seam (**37** accessor
  fields), used beside `lib/lowering/x64/mach.chiral` and
  `lib/lowering/listing/mach.chiral`. ⚑ The third instance this shard is about,
  `mach-c.chiral`, went with the C target on 2026-09-01 and is not in the tree;
  everything below is dated evidence of what the leg bought while it ran. Not a reversal of [[decision-backend]] — that fork scopes
  the *canonical shred instance*, and an additive verification instance is what
  [[banks/profile]]'s decision-profiles is for.
- **Build-state.** **E166 COMPLETE 2026-08-24 (Steps 0–6 + two fixes); E167 still
  a catalog row.** `mach-c.chiral` inhabits all 37 `Mach` fields in **190 code
  lines of 403** (`grep -cvE '^[[:space:]]*(;|$)'` and `wc -l`, measured
  2026-08-24 — over a third of the file is the F1 post-mortem comment, which is
  why the two counts diverge so far; the catalog row's 189 is the same file under
  a slightly different code-line convention, not a disagreement about the code),
  `c-assemble.chiral` is the C-mode assembler,
  `scaffold/rt/chirality-rt.c` is the freestanding shim, and `emit-c.chiral` +
  `compile-driver-c.chiral` wire the second blob. **Both halves of the
  construction are measured, and both now hold at `-O2`** (they did not before
  F2 — any *"-O1 only"* qualifier is stale): **admission** — the native suite run
  under `chirality-bin-c`, **154 ok / 0 FAIL / 82 roots compiled, exit 0**
  (re-measured 2026-08-25); **conviction** —
  `chirality-bin-c < blob` and `B1 < blob` both 1,077,624 B, **byte-identical**. So
  `ddc-converged` is not merely reachable in principle; it has been reached.
- **⚑ The admission figure this bank used to carry — *"135 ok … with `chirality-bin-c`
  as the compiler"* — was a false attribution, not a stale count.** The override
  reached only `run-native.sh`'s inline phases, so of those 135 rows **6**
  (Phase 1) ran under `chirality-bin-c` and **129** (Phases 3/4/5/6/8/9) ran under `B1`
  while being counted as C-leg coverage; Phase 7's 82 root compiles were genuine,
  that phase being inline. With the override made total (`ce593c4`), admission
  re-run at `e579106` covers **154 assertions — 148 of them never previously run
  under the C-built compiler — 0 FAIL, nothing diverged**. **One limit stays
  named rather than absorbed:** Phase 10 is skipped by construction during
  admission (`CHIRALITY_C_LEG_SKIP`) — the leg does not re-enter itself. So **11 of
  the 12 phases are genuine `chirality-bin-c` coverage**, and the 12th is the leg being
  gated. ⚑ *The OTHER limit this paragraph carried — "Phase 2 contributes no
  assertions to that count (it executes the prebuilt
  `scaffold/build/test-runner`, which no compiler in the run rebuilds)" — was
  retired by **E168** on 2026-08-25: Phase 2 rebuilds that binary from source
  under `$CHIRALITY_BIN`, so under admission it is built by `chirality-bin-c` and its rows are
  evidence for that leg. It still emits no `ok` lines (it reports an exit code),
  so it moves no count either way; what changed is that the code it runs is the
  code the run compiled.* Admission re-measured at `4320470`: **163 assertions,
  0 failed, under `chirality-bin-c`**.
- **The leg runs as one command, and it is gated.** `bash
  scaffold/tests/ddc-c-leg.sh` = **10 gates green** (2m21s in the
  `--no-admission` form Phase 10 runs; **≈3m45s** for the full form, which
  re-runs the whole suite under `chirality-bin-c`): G0b (blob A =
  674,612 B, **51** modules, `mach-c` + `alloc-fixed` present and `mach-x64` +
  `alloc-growing` absent) · G1 (`B1 < blobA` → `chirality-bin-emit-c`, 1,007,992 B) ·
  the shim's own 51 hand-derived checks · G2 (an exit-42 program through
  mach-c → C → gcc) · F3 (**36** samples — the phase's own `36 samples: both legs agree AND
  match the documented exit code` line at `f9441e4`, `ls
  scaffold/tests/samples/*.chiral | wc -l` = 36; ⚑ *was "33 samples … three of
  them carrying the `refused` marker" — the fixture count moved with G9/G10 and
  **five** rows carry `refused` today*. On those five rows both legs must reject
  the sample with the same diagnostic — ⚑ *which, as `ddc-c-leg.sh` now states
  where the marker is defined, cannot currently fail: both legs are handed the
  same blob and refuse at LOAD, and the row never reaches $CC*) · `chirality-bin-c` built (2,171,314 B of C →
  983,024 B binary; ⚑ *was 813,656 B — re-measured 2026-08-25 at `4320470`*) · G4 conviction · the emitted artifact then RUNS · G5
  (quorum disjointness) · G3 admission. Step 6 registered `ddc-legc`; Step 5
  wired Phase 10 of the native suite (Shard 3).
- **⚑ Two build facts that are load-bearing and were each got wrong once.** The
  shim's heap reserve is **1 GiB**, not 4: a 4 GiB-`.bss` static binary SIGSEGVs
  at load in this environment (`MemTotal` 3.9 GiB, `vm.overcommit_memory=0`), and
  past ~2 GiB the shim will not *link* without `-mcmodel=medium`. `e0fbd82`'s
  commit message claimed the 4→1 GiB cut while the constant it shipped still read
  4 GiB; `50b18d0` is the change that actually made the message true. Headroom is
  ample: self-compile high-water is **36,547,557 words = 292 MiB** inside the
  1 GiB reserve. And `-Wl,--defsym,m_entry=m_<mangled root>` is **required** to
  link the leg, not an optimization.
- **⚑ The two defects, because both are the kind that recur.** (1) The three
  comparison ops were **polarity-inverted**: `true` is tag 0, so a comparison
  materialized as a *value* must yield the tag, and `mach-x64:367/369/371` emit
  `setne`/`setge`/`setg` for exactly that reason. Spelling them `==`/`<`/`<=`
  negated every materialized Bool — `is-trivia` returned true for every byte,
  `skip-trivia` ate the source, `read-all-str` returned zero forms **as
  success**, and the compiler reported `no such def: compile-main`. Worse, `fjc`
  was *compensating* with a `? 0 : 1`, so the fused compare-and-branch path
  worked perfectly while every materialized Bool was wrong — which is why seven
  subsystems tested clean during diagnosis. (2) **`_start` never realigned the
  stack**: the kernel enters 16-aligned with no return address, gcc compiles a C
  `_start` assuming a return address was pushed, so every frame was skewed by 8
  and any 16-byte SIMD spill faulted. Presented as an `-O2`-only SIGSEGV and was
  not an optimizer bug at all.
- **⚑ What let both through, and it is this bank's own subject.** `mach-c`'s
  68-assertion gate checks each arm's **emitted text**. `op-eqi` rendering `==`
  *looks* right and is semantically inverted; three of those assertions were
  **pinning the bug**. Text cannot see polarity, and nothing checked the runtime
  behaviour of the *composition* until the whole compiler was run. That is §5
  item 7's adequacy limit — not a gap to close but a permanent one to design
  around, and the design answer is the behavioural differential (F3), **which is
  now built** and is stated as a rule in [[testing-floors]] (*a conforming-target
  gate must be BEHAVIOURAL, not textual*).
- **⚑ Three mutants run and reverted, and the third one is the point.** (a)
  Re-inverting `mach-c.chiral:138` back to `==` — the original F1 defect — makes
  F3 diverge on nearly every sample while G2's exit-42 program still passes,
  which is precisely how that defect hid for two sessions. (b) `(import
  "mach-x64")` in blob A fails G0b **and** G1 with *"mc: extern does not lower:
  lambda stays upper"* — Shard 8b's structural invariant, observed rather than
  asserted. (c) Dropping `m_div`'s Euclidean correction is caught by the shim
  gate and by G4 conviction and is **MISSED by F3**, because no sample in the
  corpus divides negatively. **F3 does not subsume the shim gate.** A behavioural
  differential covers the behaviour its corpus exercises; a corpus is not a
  specification, and the arm-level and shim gates stay standing beside it.
- **⚑ A counting trap this element hit twice, recorded so a third doc does not.**
  `grep -c 'end-module'` over a blob **over-counts**, because the form is
  *mentioned* inside source comments that the blob carries verbatim. The anchored
  form `grep -c '^(end-module '` is the real count, and G0b uses exactly it:
  blob A = **51** modules (G0b prints it), `scaffold/build/blob.chiral` = **52**
  (measured here, 2026-08-24). Any figure of 68/69 for these blobs came from the
  unanchored grep and is wrong.
- E166 went through the full pipeline — example (`examples/E166-mach-c.md`),
  SPEC, implementation; E167 is a catalog row. Both have catalog + ledger rows
  (no phantom deps).
- **The correction the pre-run forced, because the catalog row had it wrong.**
  I wrote that byte-identity across two backends is impossible, so the leg could
  only ever *admit*. That misreads the construction: `mach-c` does not emit the
  final artifact — it builds a **different executable of the same compiler**, and
  that executable still carries `mach-x64` as its codegen. So `chirality-bin-c < blob`
  and `chirality-bin < blob` are two x86-64 artifacts of the *same* emitter and are
  byte-comparable; `ddc-converged` is reachable. **Admission applies to `chirality-bin-c`
  itself; conviction applies to what it then emits.** That is Wheeler's DDC — the
  Thompson construction — which is the whole reason `ddc.chiral` exists.

### Shard 8b — the C leg's category boundary, and why it needs no machinery · **STRUCTURAL**
- **What.** The C leg can only compile programs in the **provable** fragment: its
  heap is one static object addressed by index, so `mach-x64` grows where
  `mach-c` traps. That asymmetry is not a defect to engineer away — it is
  [[axis-typeability]]'s axis surfacing where it should. `arena.chiral:1` already
  self-describes as *"category-C bridge: typed arena over mmap/mremap"*: growth
  takes its memory from a syscall, so the cell pointer is an integer no theorem
  can follow, and correctness rests on **evidence over an admitted hole (C)**.
  A static object indexed in bounds rests on **proof, one copy correct (A)**.
  The axis's own test — *"what does its correctness rest on"* — decides it.
- **So Rule 1 has a second axis.** A differential covers what is below its branch
  point in the *pipeline*, and what is **inside its branch point in the
  category**. The C leg covers the A fragment; growing programs sit outside it
  and are governed by [[split-role]]'s P5 — agreement between independent
  representations — which is what DDC already is. Scope, stated; not a gap.
- **Build-state: STRUCTURAL, and this is the point.** Nothing enforces it and
  nothing needs to. Two `Alloc` instances cannot coexist in one blob
  (`specialize-singleton.chiral:78-84`; **measured 2026-08-24** — a blob carrying
  both `alloc-growing` and `alloc-fixed` dies with `alloc-growing: extern does
  not lower: lambda stays upper`). The C-leg blob imports `alloc-fixed` and not
  `alloc-growing`, so there is **no growing allocator present to wire by
  mistake**. The invariant is the module graph, not a check over it.
  ⚑ **2026-09-01: that blob is gone, and it was `alloc-fixed`'s only importer.**
  The module stays on purpose, as the choice a future program makes against
  `alloc-growing`, and no gate compiles it any more. [[open-edges]] records it so
  a cleanup pass does not read zero importers as dead code.
- **⚑ The mistake worth keeping.** E166's SPEC first proposed indexing `Alloc` by
  a `MemCat` tag so `emit-c` could *demand* a provable allocator — a type error
  instead of a paragraph. Two things killed it, in order: the language cannot
  lower an indexed fn-bearing record at all (`.planning/LANGUAGE-INVENTORY.md`
  §4), and, more importantly, **it was restating in the type a fact the blob
  structure already makes unrepresentable.** That is global principle 6's
  overhead (an abstraction that constrains nothing) reached by global principle
  5's anti-pattern (a bolted-on seam check over a structural invariant). The
  generalisable lesson: *before encoding an invariant, check whether the
  substrate already forbids the violation* — the same error, three times in one
  session, as capping `arena-grow` to hide a boundary that belonged visible.

### Shard 9 — upper→tal behavioural coverage · **DESIGN (E169)**
- **What.** The first *behavioural* instrument over `lower.chiral` (407 L), whose
  only current instrument is `preserve-check`'s **type** argument.
- **Home.** In-house half: `lib/evidence/interp.chiral` (E15, "the golden reference
  interpreter") evaluating upper terms vs `lib/lowering/tal/eval.chiral` running the
  lowered tal. External half: `preserve-check` verified in Rocq.
- **Build-state.** DESIGN, and both halves have lost a leg. ⚑ The in-house half
  still declares its dependency in its own header,
  `lib/evidence/interp.chiral:6`, on an oracle that is cut, so the golden
  reference interpreter is golden against nothing. The external half's
  formalization is `rocq/`, which is not in the tree (Shard 6).

### The coverage map, and the two rules that generate it

| stage | lines | in-house instrument | external instrument |
|---|---|---|---|
| upper → tal | `lower.chiral` **407** | `interp` vs `tal-eval` (not built — E169) | Rocq-verified `preserve-check` (E169) |
| tal → `Mach` ops | `emit-core.chiral` **573** | `tal-eval` vs a native run | tal→C leg (E167) |
| `Mach` ops → machine | `mach-x64.chiral` **1,737** | — | `Mach`→C leg (E166) — **BUILT + GATED**, `ddc.chiral:162` |
| the checker | — | — | Rocq spec (`rocq/`) |

**RULE 1 — a differential only covers what is BELOW its branch point.** Everything
above the branch is common-mode: both legs run the same code, so both are wrong
the same way and the comparison reports `ok`. This is why E166 covers `mach-x64`'s
**1,737 lines and not `emit-core`** — both legs drive the same `emit-core`,
unchanged, which is exactly what makes E166 cheap and exactly why it cannot see
one line of the 573 above it.

**RULE 2 — a differential is worth building only when the new translator is much
smaller than what it tests.** `mach-c` **1:3.3 measured built** (the estimate was
~1:5–1:12; the flattering figure came from comparing `mach-c`'s *code* lines
against `mach-x64`'s *raw* ones — see [[testing-floors]]) ✓ · `tal-c` ~1:6–1:11,
estimate ✓ · upper→C ~1:1.3 ✗ — a **rewrite wearing a differential's clothes**: a second
compiler of comparable size with its own bug population, teaching you nothing
about which of the two is right. That ratio is why upper→tal gets Rocq instead of
a third C seam.

**Why two C legs and not one.** Bisection is the entire argument for E167:
`tal→C` disagrees while `Mach→C` agrees ⇒ `emit-core` (573) is the culprit; both
disagree ⇒ `mach-x64` (1,737). **Neither leg alone localizes.** The cost is
recorded honestly: a tal seam compiles a *different program*, forfeiting E166's
shared-`emit-core` localization.

---

## 3. Cross-cuts — where a shard of "verification" IS a shard of another concept

**C1 · The whole ladder is certificate-discipline (Shards 2, 6, 9 ↔ [[certificate-discipline]]).**
The house pattern is *untrusted producer + small trusted checker*.
**`preserve-check` IS that pattern** — the 407-line lowering is the untrusted
producer, the tal type-checker is the small trusted checker. So is the Rocq hammer
loop: the model proposes, `coqc` is the trusted checker. And so is the *third rung*
of E169's ladder — verifying `preserve-check` in Rocq means proving a **small
checker**, not a 407-line compiler pass. That is why the ladder reads (1) types
checked today, (2) verify the checker, (3) extend the certificate from types to
behavioural refinement: it is certificate-discipline applied one level out, to the
checker itself.

**C2 · DDC's quorum IS split-role's quorum (Shard 4 ↔ [[split-role]], [[banks/evidence-and-split]]).**
P5 is "several independent representations, require agreement." DDC is that
principle instantiated on compilation, and `ddc-bad-quorum` is its **refusal**:
when provenance is not disjoint, the quorum is not a quorum and the harness says
so rather than reporting agreement. Verification does not have its own theory of
cross-checked truth — it borrows evidence-and-split's, and inherits its limit
(agreement between correlated authors is weak evidence, which is why the `author`
axis stays *recorded, not laundered*).

**C3 · The verification architecture mirrors the altitude architecture, because it is the same seam (Shards 6+8 ↔ [[axis-altitude]]).**
`docs/axis-altitude.md:43` — *"tal is the floor and it is typed. Below tal is the
single trusted drop to the metal."* That drop is exactly what the C legs shorten:
E166 takes the trusted chirality codegen from 1,737 L down to a ~1:1 op translation
plus the freestanding C shim (Shard 8) — and, built, that drop *moves* rather
than shrinking, because gcc replaces `mach-x64` in the trusted base and gcc is
larger than what it replaced. What the leg buys is disjoint provenance. And the reason the two instruments split where they do is
that tal is where *"types preserved and checked down to"* already ends. So:
**the C trick covers the machine-ward half, Rocq covers the proof-ward half, and
they meet at tal.** The verification architecture mirrors the altitude
architecture because it *is* the altitude architecture, read from the other side.
This is the bank's best insight and the reason it is worth having.

**C4 · The checker's self-reference problem (Shard 6 ↔ [[decision-split-checker]]).**
The split-checker decision says the checker is a small trusted core with untrusted
certificate producers around it — which settles *who* is trusted but not *why the
core deserves it*. A checker cannot prove itself; it can be proved **against an
external spec**. That is the whole justification for the Rocq leg's existence, and
it is why `rocq/README.md`'s "checker soundness is the next slice" is a
verification item and a split-checker item at the same time.

**C5 · Which floors gate is a floor-agreement question, not a verification one (Shards 3, 5, 6 ↔ [[floor-agreement]]).**
[[testing-floors]] sets the current answer — native GATING, rocq GATING on
well-formedness, Python ADVISORY. What *makes* multiple floors coherent, and what
it means for them to disagree, is floor-agreement's shard. The 2026-08-23 repair
is the cross-cut biting: an advisory floor going red for months is a
floor-agreement failure that presented as a testing problem.

**C6 · Retiring the oracle is a memory/ownership migration, not a deletion (Shard 5 ↔ [[status-ledger]], [[trust-boundary]]).**
Every instrument the oracle currently underwrites — DDC leg 1, `interp.chiral`'s
own oracle line, 335 differential tests — is a *dependency* that must land
somewhere before the deletion, which is why the retirement is a background
migration with named replacements (E166 for leg 1, E168 for the corpus, E169 for
`interp`) rather than a stop-the-world rewrite.

---

## 4. Native → chirality translation (the misfire → the correction)

- **"You need CI and a coverage percentage."** → Coverage-% measures *lines
  executed*, not whether any assertion could have failed. Both of this session's
  near-misses had **100% of their lines executed** and asserted nothing about the
  thing under test. The chirality replacement is the branch-point rule (what an
  instrument can *see*) plus the mutant rule (whether it can *fail*).
- **"Golden tests will catch regressions."** → They encode the implementation's
  current answer. That is **rank 4** provenance: admissible **only** when labelled
  a regression net, never as a correctness claim. A golden capture of a wrong
  answer is a wrong answer with a test defending it.
- **"The self-host fixpoint proves the compiler works."** → It proves the compiler
  is **stable**. `BUILD-ORDER.md` records a *reversed-but-total* comparator that
  passed the fixpoint at identical byte size. Consistent miscompilation is exactly
  the class a fixpoint cannot see, and the reason an external floor is not
  optional.
- **"A differential between two implementations is strong evidence."** → Only
  **below the branch point**, and only if the provenance is genuinely disjoint.
  **E161 G0**: making *both* providers emit the same wrong marker left the
  provider-vs-provider differential reporting `ok`. Only the gate's own expected
  blob — a rank-2 source outside both legs — caught it. **A common-mode expectation
  is not an expectation.**
- **"Just point CompCert at it and the compiler is verified."** → CompCert proves
  **C → asm**. It does **not** prove **chirality → C**. The trusted drop *moves and
  shrinks*; it does not vanish. And with gcc rather than CompCert the TCB grows by
  the whole of gcc — the leg is still worth having, because what DDC buys is
  *disjoint provenance*, not a smaller TCB.
- **"The oracle is failing because it is stale; retire it."** → Of the 318 errors,
  the large majority were four mechanical loader defects, and 290 tests were not
  running at all. "It is stale" was a story that let a red external check be filed
  as advisory for three elements running.

### The two near-misses, with their mechanisms

These are this bank's evidence. Both are gates that named the *right* mutant and
would have shipped green had it not been run.

- **E156 G4 — a golden fixture blind to its own mutant.** The gate passed
  **14/14 with `list-sort` deleted** from `row-of`. Two independent causes, both
  measured: `irow` conses each newly reached port onto the front, so the
  accumulator arrives in reverse first-encounter order — the fixture's
  `write, read, open` reversed into `open, read, write`, *already ascending*, so a
  sort mutant is invisible through an accidentally-sorted input; and `row-join`
  de-duplicates its first argument only *against its second*, never within itself,
  so the duplicate was eaten before it ever reached the function under test and the
  golden could not observe `list-dedup-adj` at all. Lesson, stated so it cannot be
  softened: ***"byte-identical to the old implementation" is also what a fixture
  that exercises nothing achieves.***
- **E161 G0 — a common-mode differential.** Mutant M3 made **both** providers emit
  the same wrong marker. The two fixed-blob rows failed; *"the two providers agree
  with each other"* still said `ok`. Rule 1, met in the wild, one stage away from
  where the map predicts it. The pin — a reference outside both legs, which is
  rank 2's second clause — is what caught it. ⚑ *Corrected 2026-08-25: both
  accounts above said "the fixed committed blob", which reads as
  `scaffold/build/blob.chiral` — a file that is gitignored (`.gitignore:8`) and
  re-derived by the resolver, so neither committed nor fixed. The pin is the gate's
  own `want-lib.chiral`/`want-root.chiral`, hand-written heredocs inside the tracked
  `scaffold/tests/test-module-kind.sh` and byte-compared there. The history and the
  rank are unchanged; `docs/testing-floors.md` §*Rank 2's anchor* carries the full
  correction and the five-part admission test a NEW anchor must pass.*

---

## 5. What's genuinely new / unbuilt — the honest residue

1. **`lower.chiral` (407 L) has only a *type* argument — BUILD, E169.** No
   behavioural instrument exists over the upper→tal stage at all. Both halves are
   design: the in-house `interp` vs `tal-eval` differential, and the Rocq-verified
   `preserve-check`. Neither subsumes the other — types are not behaviour, and an
   unverified checker checking types is not a proof.
2. **`emit-core.chiral` (573 L) has in-house coverage only — BUILD, E167.**
   `tal-eval` vs a native run is a genuine second computation but a rank-2 one,
   same author, correlated blind spots. The external instrument (the `tal-c` leg)
   is not built, and by Rule 1 **E166 cannot substitute for it** — E166's branch is
   below `emit-core`.
3. **The Rocq leg's blocker is the SOURCES, not the toolchain — BUILD.** ⚑
   *Rewritten 2026-08-25; the old text said `coqc`/`rocq`/`opam`/`ccomp` are all
   absent, and two of those four are no longer true.* `coqc 8.16.1` is installed
   and **`ccomp 3.17` is built** (see item 6); `gcc 12.2.0` is present; only
   `opam`/`rocq` are absent, and the CompCert route proved opam unnecessary. What
   actually blocks this shard is that `rocq/Chirality/*.v` are written against
   Rocq 9's `From Stdlib Require Import` root rename, which 8.16 rejects — a
   one-line-per-file source question, not a missing tool. E166's *gcc first,
   CompCert later* sequencing was still the right call for a different reason
   than the one recorded: not that `ccomp` was unobtainable, but that the shim
   does not compile under it (item 6). The formalization itself is still two
   files about one integer type.
4. **The oracle is not green — LEGACY, retiring, NEEDS-AUTHOR.** 88 errors and 23
   failures survive the repair. They are **not one systemic cause** and need
   per-case adjudication. Two already triaged: `lib/reflect-floor.chiral` fails on
   **both** floors (`unknown name Former`) — the oracle and the native compiler
   *agree*, so it is a source defect, unnoticed because nothing compiles
   `reflect-floor` natively (it defines no `compile-main`, so Phase 7 never sweeps
   it); and `test_kernel_fulladt_chirality`'s `Con`/`Tcon` cases are a genuine
   chirality-vs-Python disagreement (chirality `err`, oracle `ok`) — a real differential
   needing a verdict on which side is right, not a patch to make it quiet.
5. **Provenance ranks and the mutant rule — ENFORCED where a gate is written on
   the floor (E168, BUILT 2026-08-25); still prose everywhere else, and that is
   E170.** [[testing-floors]] remains the contract, `test-floor.chiral` is that
   contract as types, and Phases 2 and 12 are the only two adopters so far. The corpus that must migrate onto the enforced
   version is measured: **335 differential** (unportable — they re-found on a
   different second opinion or lose their meaning) / **68 B1-driven** / **306
   python-checker-only**. Designing the floor *before* migrating is the sequencing
   reason: migrating twice is worse.
6. **CompCert licensing — RESOLVED by the author, 2026-08-24; the gcc TCB point
   stands.** The INRIA non-commercial licence restricts **use of CompCert**, not
   the output of a program CompCert compiled, and carries no output restriction.
   A one-off `ccomp` comparison against `gcc` is *evaluation*, which the licence
   permits; chirality's own AGPL-3.0-or-later is untouched by it. The one standing rule is
   distribution: **never ship a CompCert-built artifact.** So the CompCert half of
   the C-leg argument is no longer contingent on a licence question.

   ⚑ **Nor is it contingent on `ccomp` existing — MEASURED 2026-08-25, and the
   blocker that remained was OURS. It is now closed; this item is history plus a
   recipe, not a gap.** CompCert 3.17 builds in this environment from the
   INRIA tarball on Debian `main`'s `coq 8.16.1` / `ocaml 4.13.1` /
   `menhir 20220210` (it bundles Flocq and MenhirLib), with **no opam** — the
   route that took this box down twice was never required. `make -j2 all` returned
   RC=0 at a floor of 1.37 GB free. ⚑ **Read that before installing anything:**
   `apt-get install -y --no-install-recommends coq menhir ocaml-findlib
   libmenhir-ocaml-dev`, then the v3.17 tarball, `./configure x86_64-linux
   -prefix /opt/compcert && make -j2 all && make install`. Debian ships no
   `compcert` package in any suite, and opam is neither present nor needed.

   **`mach-c`'s 2.1 MB of generated C was CompCert-clean as written.** What was
   *not* clean was the hand-written shim: GNU local register variables, a
   file-scope `__asm__`, and `m_sys`'s `"a"`/`"D"`/`"S"`/`"d"` register
   constraints — three hard refusals no CompCert flag reaches, in a file whose
   header showed it was written *with CompCert in mind* and never tested against
   it. **Resolved 2026-08-25 (`aa055ec`)**: the three moved into
   `scaffold/rt/chirality-rt.s` (`m_sys`, `m_trap`, `_start`), the shim gate is
   51/51 under both compilers, and the leg is 9/9 under both. ⚑ The trap is
   carried in that file above the crossing, because it is the line someone will
   "fix": relaxing the constraints to generic `"r"` **compiles clean and emits a
   bare `syscall` with no operand reaching any register**. "It built" is not
   evidence for a crossing.

   ⚑ **The accounting, decided rather than assumed.** A `.s` beside the shim is a
   second trusted artifact, and E166's honesty check is the shim's size — so the
   trusted drop is counted as **C code lines + asm code lines, SUMMED**: 89 + 27
   = **116** against the SPEC's ~150. Moving code across a file boundary must not
   be able to shrink the number that measures how much we are trusting, or the
   check becomes a filing trick. Recorded in both file headers.

   What does *not* change: **gcc carries the whole of gcc in the TCB**, so the
   gcc leg buys disjoint provenance and not a smaller trusted base. The CompCert
   leg is the one that shrinks it, which is why it is the default. And the
   distribution rule is unchanged and now live rather than prospective: **never
   ship a CompCert-built artifact** — `ddc-c-leg.sh` builds every one of them in
   a work dir its EXIT trap removes.
7. **Test-adequacy is not mechanizable — a permanent limit, not a gap to close.**
   An external reference supplies the expected **behaviour**; it cannot tell you
   the test asked the right **question**. Expectation-correctness is mechanizable;
   adequacy is not. Both E156 G4 and E161 G0 were adequacy failures with perfectly
   sound expectations — which is exactly why the mutant rule is *separate* from the
   provenance rank and why neither replaces the other. **E166 supplied the
   sharpest instance yet, and it is a limit rather than a near-miss:** F3, the
   behavioural differential built precisely because the 68 text assertions could
   not see polarity, **misses** the `m_div` Euclidean mutant — no sample in its
   corpus divides negatively. A corpus is not a specification. The instrument
   built to close one adequacy hole has an adequacy hole of its own, and that is
   the general shape, not this element's accident.
8. **The C leg is registered but not yet the default second opinion — BUILD,
   small.** `ddc-legc` stands at `ddc.chiral:162` and G5 gates its disjointness
   from `ddc-leg0`, but `ddc-verdict-code` (`ddc.chiral:185`) still composes
   `ddc-leg0` with `ddc-leg1`, the Python one. The quorum *can* be met without
   Python; the one function that hardcodes a pairing does not yet do so. Naming it
   here so the discharge in Shard 4 is not read as more than it is.

   ⚑ **SUPERSEDED 2026-09-01.** The leg is dropped, so this item is no longer a
   small BUILD. `ddc-verdict-code` still composes leg 0 with the Python leg 1,
   and now **neither leg it names exists as a running thing** and no caller
   consults it. The successor item is in [[open-edges]]: `ddc.chiral` is the
   referee for a quorum of judgment cores, and its `Prov` has no formulation
   axis to referee on.

---

## 6. Relational anchors — thin notes that should link INTO this bank

- [[testing-floors]] — the contract this bank is the depth tier under: which
  floors gate, the coverage map, the provenance ranks, the mutant rule.
- [[floor-agreement]] — what it means for several floors to agree or disagree, and
  which get to fail the build (C5).
- [[certificate-discipline]] — untrusted producer + small trusted checker;
  `preserve-check` and the Rocq ladder are both instances (C1).
- [[split-role]] — P5, several independent representations requiring agreement;
  DDC's quorum and its refusal (C2).
- [[decision-split-checker]] — why the checker needs an *external* spec rather
  than self-certification (C4).
- [[axis-altitude]] — "the single trusted drop to the metal" is what the C legs
  shorten; the two instruments meet at tal (C3).
- [[modules-lowering]] — `preserve-check`'s home; the stage the coverage map's top
  two rows describe.
- [[trust-boundary]] — what the built claims *rest on*, beside what it is
  *checked by*; the TCB ledger the C legs move.
- [[status-ledger]] — build-state authority for every claim in §2.
- [[banks/evidence-and-split]] — category C, cross-checked truth where proof runs
  out; DDC's quorum shard lives there too.
