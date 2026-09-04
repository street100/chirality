---
element: E52
slug: certificate-split
title: Kernel-core certificate split: kernel-spec artifact + small trusted core re-checking untrusted producers' certificates + certificate / proof-object format (LCF / de Bruijn)
kind: BUILD-PROPER
example: examples/E52-certificate-split.md
status: audited
updated: 2026-08-31
---

# E52 SPEC — Kernel-core certificate split: kernel-spec + kernel-core + the certificate seam

> ⚑ **TRIAGE 2026-09-04 — NEEDS-REPLAN.** 1 of 5 steps are executable at HEAD.
> Already self-annotated DEAD TARGET on A1-A4; B1 partly landed. Intent
> survives, gate does not. Bucket and evidence: `records/spec-tier-triage.md`.
> This file was not rewritten and its `status:` was not changed.

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.
>
> **Trust-lane element — read this first.** E52's load-bearing deliverable is a
> **Lane-5** program (SELF-HOST-PLAN item 2 of the strong judgment core): the
> small, spec-directed chirality-side `recheck` that replaces trusting the Python
> elaborator+checker monolith, verified by the Stage1==Stage2 fixpoint. ~~It is
> **gated on the checker port** (E3/E4/E13 → `lib/kernel.chiral`, `audited` but
> not built = the build wave). This SPEC scopes that full contract AND a
> buildable-now Python **reference producer/checker pair** (the "transition"
> the example §6 names) as the de-risking first commit. The Python seam is a
> real seam, not the TCB win — that lands with the port.~~ **Every clause struck
> here is stale; see the next block.**

> **⚑ RE-AUDITED 2026-08-31 — BLOCKED. Not implementable as written.** Three
> load-bearing premises of the 2026-08-02 text died afterwards. Each is fixed at
> its own site below; this block is the index.
>
> 1. **The Python leg is gone.** External judgment is CUT — Rocq, CompCert and
>    the Python oracle (`docs/decisions/decision-scope.md` decision 5;
>    `docs/definitions/status-ledger.md:22-24`). `scaffold/` does not exist, and
>    with it `kernel.py`, `surface.py`, `lower.py`, `optimize.py` and
>    `scaffold/tests/test_kernel.py`. §4 had already ruled Phase (A) not a build
>    step; what is new is that its *artifacts* are deleted, so every §5 clause
>    that differentials against them is unrunnable and there is no pytest count
>    to be a green line.
> 2. **The build gate has cleared.** §2's "all `audited`, none built" is false.
>    E3, E4, E5, E6 and E13 are all `built` (`docs/elements/ledger.md:66-72`), and
>    the checker port is the live judgment reached by every compile
>    (`docs/definitions/status-ledger.md:87`). Phase (B) is unblocked — and is
>    in fact partly landed already; see §2.
> 3. **The paths are hoisted.** The 2026-08-31 migration moved the tree to
>    `lib/<role>/`, `prog/`, `tools/test/`. Every `scaffold/…` and flat
>    `lib/*.chiral` path below has been rewritten to its live home. An
>    implementation run following the old text literally would have targeted
>    files that do not exist.
>
> Three FLAGs are open at their sites and are **not** resolved here: the L0
> `kernel-spec` is owned by no element (§1 non-goals, §6), E52's build-state has
> four claimants and four answers (§2), and decision #3's deferral target does
> not exist (§3).

## 1. Deliverable

- **After this runs:** the def-entry judgment flows through an explicit
  **certificate seam** — the elaborator emits a `Cert` (the elaborated core
  term + a per-site conversion tier + carrier version) and holds no trust; a
  single consumer `recheck : Spec → Cert → Verdict` re-derives it and returns a
  **verdict value** (errors-as-values, not a raised `KernelError`); definition
  installation consumes the verdict, never producer output. ~~Delivered in two
  phases: **(A)** a buildable-now Python reference producer/checker pair in
  `kernel.py`/`surface.py`~~ **(A) IS DEAD, 2026-08-31** — `scaffold/` and both
  files are deleted with the Python oracle (`docs/decisions/decision-scope.md` decision 5), and §4 had
  already ruled it not a build step. **The only deliverable is (B):** the
  chirality-side `lib/typing/kernel-core.chiral` `recheck` over the live
  `Term`, joined to the fixpoint. Its differential can no longer be "against
  pair (A)" — see §5 for what replaces it.
- **Non-goals:** `docs/kernel-spec.md` as a *full audited prose artifact*
  (couples E71; §6). ⚑ **FLAG (2026-08-31), do not implement past this line
  without an author call:** that non-goal leaves the L0 base ownerless. E71's
  SPEC delivers `docs/tal-spec.md` + `lib/tal-spec.chiral`
  (`docs/elements/specs/E71-golden-restructure-SPEC.md:27,30,99`) — the *tal* floor,
  not kernel-spec — while E71's catalog row calls the kernel-spec the golden
  object (`docs/elements/catalog.md:212`) and E72 merely *couples* it
  (`:218`). No element builds it. Consequence in code: `Spec` and `SpecRule`
  exist in `lib/typing/kernel-core.chiral:28-29` with **nothing anywhere
  populating them**, so `recheck`'s `Spec` argument is inert and the function is
  spec-*shaped*, not spec-*directed*. The **serialized certificate wire format**
  (#3 → DEFERRED; ⚑ its named target does not exist, see §3). **Spec-size-budget
  enforcement** tooling (#4 → DEFERRED as premature; §3). Producer #2+ (the
  optimizer already carries `preserve-check`; solvers per inspiration Tier O).
  The `conv-cached` signature scheme (tier 3 crypto is its own element).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** `Kernel-core certificate verifier + discipline` —
  **BUILD**, L, E52 (`records/conformance-map.md:181`): *"Settled in
  docs; kernel.py is single trusted checker, no producer/consumer split …
  Decision made; forward build."* ⚑ That row's premise (`kernel.py`) is itself
  deleted; the row has not been re-cut since the hoist. The sibling row `DDC
  differential harness` is **BUILT (E53)** and names `cert-over-Adhikara → E52`
  as its forward hook — E52's certificate is what E53's climb eventually carries.
- **⚑ FLAG (2026-08-31) — E52's build-state has four claimants and four
  answers. Report, never pick:**
  | claimant | says |
  |---|---|
  | this SPEC's frontmatter | `status: audited` |
  | `docs/elements/ledger.md:218` | `design`, with an explicit `⚑ UNRESOLVED 2026-08-22` |
  | `docs/examples/INDEX.md:65` | `implemented` |
  | `records/conformance-map.md:181` | `BUILD` (i.e. not built) |
  `LEDGER.md:20` names CONFORMANCE-MAP the authority on disagreement, and
  `ledger-lint` check N (`tools/ledger-lint/ledger-lint.py:828`) sees the pair
  and **deliberately refuses to pick**, printing
  `[N] E52 KNOWN disagreement (ledger=design, INDEX=implemented)` non-fatally
  (verified by running it 2026-08-31). Two further defects inside the LEDGER row
  itself, for whoever resolves this: it says *"CONFORMANCE-MAP carries no
  verdict for E52"* — false, line 181 carries `BUILD`; and it cites
  `kernel-core.chiral` having *"only 4 defs"* as non-evidence, which is a count,
  not a measurement (see the next bullet for what the file actually does). The
  disagreement is above this doc. **Author call.**
- **⚑ Part of Phase (B) is ALREADY IN THE TREE (measured 2026-08-31), and the
  SPEC below does not know it.** `lib/typing/kernel-core.chiral` is 60 lines
  carrying `JForm`/`SpecRule`/`Spec`/`ConvEv`/`Cert`/`Verdict` and a working
  `recheck` (`:54-60`), and `chirality check lib/typing/kernel-core.chiral`
  passes. What is honestly missing is **reach, not code**:
  - **Zero importers.** Nothing in `lib/` or `prog/` imports
    `typing/kernel-core` (grepped across `.chiral`/`.prog`/`.port`/`.profile`).
    It is SEEDED by `docs/definitions/status-ledger.md` decision 9's rung definition, not IMPLEMENTED.
  - `lib/typing/reflect-floor.chiral:49-53` **re-declares `recheck` forward**
    rather than importing it, and at a *different signature* —
    `(-> Frozen Cert Verdict)` against kernel-core's `(-> Spec Cert Verdict)` —
    so the E45 succession seam and the E52 core do not currently compose.
  - `Spec`/`SpecRule` are declared and **nothing populates them** (§1 FLAG).
  - `recheck` calls `infer` with a literal empty `Sig`
    (`kernel-core.chiral:58`), so it can only re-check a closed core term: no
    definition with a global reference is expressible as a `Cert` today.
- **Live code this composes with (do NOT respec):**
  - ~~`kernel.py:400 infer` / `kernel.py:483 check`~~ → **`lib/typing/kernel.chiral:819 infer` /
    `:937 check`** (declares at `kernel.chiral:434-435`) — the bidirectional judgment
    is **already syntax-directed re-derivation** over the elaborated core `Term`
    (`Var`/`Global`/`Prim`/`Lit`/`Pi`/`App`/`Let`/`Ann`/`Lam`/EXT). Metavariables
    are resolved in the elaborator; the elaborated term already carries `Ann`
    (ascription) nodes at the non-syntax-directed points. **The elaborated term
    IS the derivation** (example finding #1), so `recheck`'s typing half = run
    the *existing* `check`/`infer` on the certificate's term — no new judgment.
  - ~~`kernel.py:567 finish_def`~~ **DELETED.** The def-entry it named is now the
    loader path `lib/module/loader.chiral` → `lib/typing/kernel.chiral`, and it
    returns a `TcR`/`CkR` **verdict value already** (`kernel.chiral:410`
    `(data TcR () (tc-ok …) (tc-err (why Reason)))`), not a raised `KernelError`.
    The errors-as-values half of E52 therefore **landed elsewhere, via E157**,
    and is no longer part of E52's delta.
  - ~~`surface.py:169–186 toplevel`~~ **DELETED.** The producer is now
    `lib/surface/parse.chiral` + `lib/module/loader.chiral`. It still hands the
    elaborated term straight to the judgment with no `Cert` between them, so the
    *gap* E52 names is intact; only the file is different.
  - ~~`kernel.py:277 conv`~~ → **`lib/typing/kernel.chiral:702 conv`** (declared
    `:426`) — the conversion checker (`conv-rerun`, tier 1) already exists and is
    what tier-1 sites re-run. `preserve-check` is the **proven-once** certificate
    re-checker E52 generalizes, now `lib/lowering/tal/check.chiral:290 ck-fn` +
    `lib/lowering/upper/optimize.chiral:250 re-check`. ⚑ It was **demoted from
    ENFORCED to built-but-unadopted on 2026-08-31**
    (`docs/definitions/status-ledger.md:121`): neither runs in the shipping
    compile, and nothing imports `lib/lowering/upper/optimize.chiral` at all. So
    the "proven once in code" premise E52 leans on is now *proven once and
    unadopted*.
  - ~~`lib/ddc.chiral`~~ → **`lib/evidence/ddc.chiral`** (E53, built) — the
    differential-compare core the chirality-side (B) certificate eventually feeds.
    ⚑ `docs/decisions/decision-self-verification.md:264` records E53 as *marked
    built and unable to run*; do not treat it as a live floor.
- ~~**Not yet built (the gate):**~~ **THE GATE HAS CLEARED (2026-08-31).** Every
  port module this SPEC waited on exists and is `built`
  (`docs/elements/ledger.md:66-72`): `lib/typing/kernel.chiral` (E3/E4
  `infer`/`check`/`conv`), `lib/surface/terms.chiral` (E13; note the *live* full
  ADT `Term` the kernel owns is `lib/surface/syntax.chiral` —
  `docs/definitions/status-ledger.md:87`), `lib/typing/qtt.chiral` (E5),
  `lib/surface/data.chiral` (E6/E7/E8). Phase (B) is **not blocked**; its
  "gated on the checker port" framing everywhere below is stale.
- **True delta (restated 2026-08-31):** (A) is void. (B) is *reach*, not new
  code: populate `Spec` from a kernel-spec artifact (⚑ ownerless, §1 FLAG),
  reconcile `recheck`'s signature with `reflect-floor.chiral:53`, give it a real
  `Sig` so non-closed defs are certifiable, route the loader's def-entry through
  it, and add the phase that gates it.

## 3. Decisions

| # | Question (example §6) | Disposition | Rationale / owner |
|---|-----------------------|-------------|-------------------|
| 1 | Conversion-evidence tier mix (`conv-rerun`/`conv-trace`/`conv-cached`) | **RESOLVED → per-instance** | Settled 2026-07-26 (catalog §VII): tier chosen *per certificate site* — `conv-rerun` where the check is decidable & cheap (conversion/NbE), `conv-trace` for undecidable producer outputs (solvers), `conv-cached` only where perf dominates; TCB = union of tier-checkers used. ~~Phase (A) implements~~ **Phase (B) implements `conv-rerun` only** (the sole tier whose checker — ~~`kernel.py:277 conv`~~ **`lib/typing/kernel.chiral:702 conv`** — already exists); trace/cached are constructors reserved in the ADT, unimplemented, each a later per-site pick. ⚑ Verified 2026-08-31: `lib/typing/kernel-core.chiral:32-35` reserves all three exactly as specified, and `recheck` re-runs conversion via `infer`. Citation re-checked against `docs/decisions/decision-self-verification.md:246-252`, which restates the same per-instance call. |
| 2 | Totality of `recheck` itself — spec-level normalization claim, or fuel-bounded verdict? | **RESOLVED-IN-DIRECTION** (carried-measure part); fuel posture **PROVISIONAL** | Split into two parts. **Settled (author-ratified 2026-08-02 + docs):** totality of the *carried input* is not a `recheck` concern — the totality mark is a carrier seat (`decision-effect-facets`, Pi carrier `(q,row,grades,totality-mark,…)`) re-checked as a **declared measure**: "declared, never inferred … the checker only re-checks the measure, and a false one is rejected" (`totality.md`, classify-not-enforce). `recheck` re-accounts it like any seat. **Provisional (recommended, not yet ratified):** the residual — `recheck`'s own termination when it re-runs **conversion** (the one site with no declared measure) — takes the **fuel-bounded verdict** posture (`recheck` structurally total, no SN axiom in trusted *code*; a `v-fuel` verdict names exhaustion; SN lives in kernel-spec as a tiered P5 claim, not a `(total)`-code axiom). This is **coupled to [[E03-nbe-normalize]] dec#1**, itself still provisional (b); **decide the two together at the port**. ~~Non-blocking: Phase (A) reuses Python `conv` as-is (CPython recursion = the interim floor), so the fuel verdict + threading is a Phase-(B) obligation, not owed now.~~ ⚑ **Now blocking, 2026-08-31.** There is no Python floor to defer to: the port has landed and `lib/typing/kernel-core.chiral:18-22` states in its own header that `v-fuel` is **reserved and `conv` is not fuel-threaded**, so the module ships the *un*-decided posture. The E3 tie is still open (`docs/examples/INDEX.md:28`: *"Core NOT asserted `(total)` — SN posture is a spec-level claim (E52 #2 / this dec#1, fuel-verdict), not a code axiom"*). This is a build obligation E52 now owes, not a deferral. |
| 3 | Certificate serialized / canonical wire format (~~E12 bootstrap bridge~~) | ~~**DEFERRED → E12 bridge**~~ ⚑ **FLAG — the deferral target does not exist** | Two independent defects, measured 2026-08-31. **(a) The citation is false.** E12 is the *effect membrane* (`->` vs `=>`) — `docs/elements/catalog.md:54`, `docs/elements/ledger.md:95` — and owns no bootstrap bridge. The phrase "E12 bootstrap bridge" occurs nowhere in the tree except this SPEC and its own example (`docs/examples/E52-certificate-split.md:245,255`). Under CLAUDE.md's deferral rule this is a phantom dep. **(b) The stated occasion is gone.** "the transition where chirality producers emit Certs the **still-Python core** reads" cannot occur: the Python core is CUT (`docs/definitions/status-ledger.md` decision 5). The nearest real homes on the books are **E72** (re-bootstrap artifact, `docs/elements/catalog.md:218`) and **E62** (bootstrap floor), but choosing between them, or minting a new element, is an **author call — not resolved here**. Meanwhile `Cert` stays an in-process chirality value (`lib/typing/kernel-core.chiral:36`), so no format is owed *yet*; the leading candidate on record is still canonical S-expr reusing E1's reader + the fixpoint's canonicalization (D-1/D-2). |
| 4 | Spec-size-budget enforcement (what "readable in a sitting" measures; who signs a spend) | **DEFERRED as premature** (author-ruled 2026-08-02) | Priority is rung 1, and composability lets us add enforcement later without cost (principle 6 — an abstraction that doesn't constrain behavior yet is overhead). The budget stays a **documented design intent** in kernel-spec (prose: "readable in a sitting; every carrier seat spends from it"), **no lint/tooling**. Revisit *only if* kernel-spec actually bloats — a refactor then, not machinery now. |

~~No blocking NEEDS-AUTHOR remains → `status: draft` (not `blocked`). Phase (B)
carries a **build-gate**, not a decision-gate: it waits on the checker port, not
on an unanswered question.~~

⚑ **Reversed 2026-08-31. The build-gate cleared and a decision-gate opened.**
Phase (B) no longer waits on the checker port (§2); it waits on **three author
calls** — who owns the L0 `kernel-spec` (§1), which of four claimants states
E52's build-state (§2), and where the wire-format deferral actually lands (#3
above) — plus one obligation that used to be deferred and now is not (#2, the
fuel posture). This SPEC is **BLOCKED**, not implementable as written.

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
> Phase B ports to chirality). ~~Phase (B) is the deliverable, **gated on the checker
> port** (the build wave).~~ **Phase (B) is the deliverable and is NO LONGER GATED**
> — the port landed (§2).
>
> **⚑ 2026-08-31: steps A1–A4 address deleted files.** `scaffold/` does not
> exist. Every `Target:` line in A1–A4 below is unreachable, and the steps are
> retained *only* as the prose record of the seam's shape. An implementation run
> must start at **B1**. Their content has already been partly superseded by the
> tree: `Verdict`-as-a-value is live at `lib/typing/kernel-core.chiral:39-43`,
> and the raising `KernelError` they wrap does not exist — the judgment returns
> `TcR`/`CkR` (`lib/typing/kernel.chiral:410`).

### Step A1 — the certificate data layer (Python) — **DEAD TARGET**
- **Target:** ~~`scaffold/chirality/kernel.py`~~ (deleted) — new module-level types near the top.
- **Change:** add `Cert` (elaborated `Term` + a `ConvEv` tier tag + `carrier_ver:int`),
  `ConvEv` (`conv-rerun` implemented; `conv-trace`/`conv-cached` reserved,
  raising `NotImplementedError` if constructed — honest un-built), and `Verdict`
  as a tagged value: `v-accepted` / `v-rejected(rule, at)` / `v-wrong-carrier(want, got)`
  / `v-fuel` (reserved for Phase B, unreachable in A). `carrier_ver` = a single
  module constant `CARRIER_VER` bumped only when the Pi seat set changes.
- **Size:** ~S.

### Step A2 — `recheck` as an errors-as-values wrapper — **DEAD TARGET**
- **Target:** ~~`scaffold/chirality/kernel.py`~~ (deleted) — new `def recheck(sig, cert)`.
- **Change:** re-derive the certificate against the current judgment: check
  `cert.carrier_ver == CARRIER_VER` (else `v-wrong-carrier`); run the existing
  `check(sig, Ctx(), cert.tm, sig.global_types[name], EMPTY_ROW)` inside a
  `try/except KernelError` that **converts the raise into `v-rejected(rule, at)`**
  (map the error to the failing judgment form + location); conversion sites hit
  the existing `conv` (tier 1). Return `v-accepted` on success. `recheck` itself
  raises nothing. **No new judgment logic** — it wraps A1's boundary around the
  code that already runs.
- **Size:** ~M.

### Step A3 — route def-entry through the seam — **DEAD TARGET**
- **Target:** ~~`scaffold/chirality/kernel.py:567 finish_def` + `surface.py:169–186 toplevel`~~ (both deleted). The live def-entry is `lib/module/loader.chiral` → `lib/typing/kernel.chiral`.
- **Change:** `surface.toplevel` builds a `Cert` from the elaborated `body`
  (the producer, holding no trust) and calls a verdict-consuming path;
  `finish_def` (or a new `finish_def_checked`) calls `recheck`, and on
  `v-accepted` installs (`sig.global_defs[name] = body`), on `v-rejected` /
  `v-wrong-carrier` reports (preserving today's error text so the suite's
  expected messages still match). Keep the raising `finish_def` available for
  callers that want it, or adapt call sites — implementer's diff decision, shown.
- **Size:** ~M.

### Step A4 — the negative test (the whole point of the split) — **DEAD TARGET; the idea survives, see §5**
- **Target:** ~~`scaffold/tests/test_kernel.py` (or new `test_certificate.py`)~~ (deleted with the Python oracle). The negative test itself is the one half of the gate that can be re-founded — as a phase under `tools/test/mutant.sh`, not as pytest. §5 restates it.
- **Change:** (i) differential — every def the current path accepts, `recheck`
  accepts; every rejection matches, across a corpus (the existing suite exercises
  it). (ii) **injected-bug** — hand a `Cert` whose elaborated term has a
  deliberately wrong ascription (a producer bug) and assert `recheck` returns
  `v-rejected`, not `v-accepted`. This is the seam's reason to exist.
- **Size:** ~S.

### Step B1–B* — chirality-side `recheck` (~~GATED on the checker port~~; **UNGATED, and partly landed**)
- **Target:** ~~NEW `lib/kernel-core.chiral`~~ → **`lib/typing/kernel-core.chiral`,
  which EXISTS (60 L, 4 defs, type-checks OK — measured 2026-08-31)**. It already
  carries `Cert`/`Verdict`/`ConvEv`/`JForm`/`SpecRule`/`Spec` and a `recheck`
  over the live `Term`, importing `typing/kernel` and `typing/diag`. Path fixes
  to the consumed modules: ~~`lib/kernel.chiral`~~ → `lib/typing/kernel.chiral`,
  ~~`lib/terms.chiral`~~ → `lib/surface/terms.chiral` (with `lib/surface/syntax.chiral`
  the live full-ADT `Term`), ~~`lib/qtt.chiral`~~ → `lib/typing/qtt.chiral`,
  ~~`lib/data.chiral`~~ → `lib/surface/data.chiral`.
- **What B still owes** (this is the real change plan; the prose above was
  written against an empty tree):
  1. **A `Spec` with contents.** `Spec`/`SpecRule` are declared and unpopulated
     (`kernel-core.chiral:28-29`). Blocked on the ownerless kernel-spec — §1 FLAG.
  2. **One `recheck`, not two.** `lib/typing/reflect-floor.chiral:53` forward-declares
     `recheck` at `(-> Frozen Cert Verdict)`; kernel-core defines it at
     `(-> Spec Cert Verdict)`. Reconcile, then have reflect-floor **import**
     `typing/kernel-core` instead of re-declaring.
  3. **A real `Sig`.** `kernel-core.chiral:58` passes a literal empty `Sig`, so
     only closed core terms are certifiable; a def with a global reference is not
     expressible as a `Cert` today.
  4. **A caller.** Zero importers. Route the loader's def-entry
     (`lib/module/loader.chiral`) through `recheck` so the module is reached.
  5. **The fuel posture.** `v-fuel` is reserved and `conv` is not fuel-threaded
     (`kernel-core.chiral:18-22`) — decision #2, now owed rather than deferred.
  6. **A phase.** See §5.
- **Size:** ~M for 2–6; 1 is gated on an author call, not on the build wave.

## 5. Conformance gate

> **⚑ REBUILT 2026-08-31. The 2026-08-02 gate below is struck: half of it cited
> an executor that no longer exists, and the SPEC carried no staleness marker
> saying so.** What died, what survives, and what the survivor may claim:

**(i) The differential half is DEAD, and cannot be re-founded.** It compared
`recheck` against "the Python reference producer/checker pair". Rocq, CompCert
and the Python oracle are CUT (`docs/decisions/decision-scope.md` decision 5;
`docs/definitions/status-ledger.md:22-24`); `kernel.py`, `surface.py` and
`scaffold/tests/test_kernel.py` are deleted. There is no second implementation of
the judgment in this tree to differential against — by design: `bin/chirality`
has no `test-python` subcommand, on purpose, and the three semantically distinct
judgment cores that replace external judgment are **still unbuilt**
(`docs/definitions/status-ledger.md` decision 5). E53's DDC compare core is `built` but **cannot run**
(`docs/decisions/decision-self-verification.md:264`), so it is not a substitute
either. Deleting this clause loses no coverage that exists; keeping it was a gate
that could not fail.

**(ii) The negative half SURVIVES and is mechanizable today.** "an injected
wrong-ascription certificate yields `v-rejected`" is a **mutant**: inject a
defect, assert the gate refuses. `tools/test/mutant.sh` (new, 2026-08-31) is
exactly that rule made mechanical, and it closes the four ways such a measurement
fails silently — anchor matched nothing, mutant did not build, mutant is
semantically inert, base was already red (`mutant.sh:17-42`), plus
`mutant_fixpoints` reporting stability so "it self-hosts" is never read as "it is
correct". Its declared mutants today all mutate a **rule** in `lib/` and score a
phase; E52's is the dual (mutate the **certificate**, score `recheck`), and the
library API — `mutant_build` / `mutant_differs` / `mutant_control` /
`mutant_red` — is the machinery for both.

**(iii) The re-founded gate, and PRECISELY what it may claim.** A new phase under
`tools/test/run-tests.sh` (the phase list at `:131-134,203` is the shape; a
number after 13) that:
  1. builds a `Cert` over a well-typed closed core term and asserts
     `recheck` → `v-accepted`;
  2. mutates the term's ascription to a wrong type and asserts
     `recheck` → `v-rejected` — the injected producer bug;
  3. asserts a stale `carrier-ver` → `v-wrong-carrier`;
  4. runs the base compiler as `mutant_control` first, so a phase red for an
     unrelated reason cannot convict the mutant.

  **It may claim:** the certificate seam refuses a *producer* (elaboration) bug
  that today's trusted-de-facto path would have installed.
  **It may NOT claim any of:**
  - **a TCB reduction.** `recheck` calls `infer` from `lib/typing/kernel.chiral`
    — the *same* checker that judged the term in the first place
    (`kernel-core.chiral:58`). Per
    `docs/decisions/decision-self-verification.md:99-110`, L0 is "an L0
    re-checker that consumes a fully explicit derivation and checks each step
    against the table. **No inference**"; a function whose body is `infer` is
    L1, not L0. Re-running the same core on the same term is **re-execution, not
    re-derivation**, so no shared bug in `infer`/`conv` is visible to this gate,
    and the trusted base is unchanged in size.
  - **independence, agreement, or a DDC leg.** Same core, one formulation. The
    note's amendment 3 (`:167-173`) is the general form: where formulations are
    extensionally equivalent by construction, agreement is worth close to
    nothing.
  - **the ascending sequence.** `:241-245`: E52 "is L0/L1/L2 … What §3 adds is
    the *ascending sequence* with per-level faithfulness, **which E52 does not
    have**." Nothing E52 ships closes the Gödel bound; the hierarchy terminates
    downward in a human-read artifact (`:121-122`) — the kernel-spec that §1
    FLAGs as ownerless.
  - **spec-directedness.** With `Spec` unpopulated, the gate exercises a
    `recheck` that ignores its `Spec` argument.

**Green line.** ~~430 → ≥ 433~~ **struck: that is a pytest function count and
there is no pytest.** The Python oracle suite is CUT, so no test-function number
can be quoted; the green line must be **a named phase in
`tools/test/run-tests.sh`** that prints its own pass tally, and the run's unported
phases are printed by name and reason every run (`run-tests.sh:207-212`).
`python3 tools/ledger-lint/ledger-lint.py` is **not clean today** (check I,
FRONTIER staleness, measured 2026-08-31) and two checks report VACUOUS rather
than ok — an E52 gate must not silently inherit that as its bar.

**Done when:** the loader's def-entry runs through `recheck`, the new phase is
green under the promoted binary, the mutant of clause (2) is scored **RED** under
`mutant_control`, and the compiler still reaches a byte-identical fixpoint at
GEN3 (`docs/definitions/status-ledger.md`: check each artifact non-empty before the `cmp`; a fixpoint is
stability, never correctness — `mutant.sh:34-41` measured five semantic mutants
that fixpointed perfectly).

## 6. Residue & links

- **Deliberately unbuilt (with homes):**
  - ~~Chirality-side `recheck` + the real TCB reduction → **Phase B, Lane 5**
    (gated on the checker port; the fixpoint verifies the last Python dies).~~
    **Re-cut 2026-08-31:** the `recheck` *code* exists
    (`lib/typing/kernel-core.chiral`), the *reach* does not (zero importers), and
    the **TCB reduction is not owed by this element at all** — `recheck` calls
    the same `infer` it is meant to be independent of, which is re-execution, not
    re-derivation (`docs/decisions/decision-self-verification.md:99-110`). The
    last Python did die, but the fixpoint did not verify that: it verified
    stability (`docs/decisions/decision-scope.md`; `tools/test/mutant.sh:34-41`).
  - `conv-trace` / `conv-cached` tiers → later per-site picks (decision #1);
    `conv-cached` signature/crypto is its own element.
  - Serialized certificate wire format → ~~**E12 bootstrap bridge**~~
    ⚑ **no such home; author call owed** (decision #3 FLAG).
  - Spec-size-budget enforcement tooling → **deferred**, revisit only on bloat
    (decision #4).
  - `docs/kernel-spec.md` as a full audited artifact → ~~couples
    **[[E71-golden-restructure]]** (one ownership budget governs both)~~
    ⚑ **the L0 base is owned by NO element** — E71's SPEC builds `tal-spec`, not
    `kernel-spec` (§1 FLAG). ~~Phase A writes only the seat/rule intent it
    needs~~ (Phase A is void), so nothing in this SPEC writes any of it.
  - `recheck` fuel + `v-fuel` verdict + SN-as-P5-claim-in-spec → ~~**Phase B** /
    **[[E03-nbe-normalize]] dec#1** (decide the SN posture together at the
    port)~~ — the port has landed and the posture is still undecided, so this is
    now **owed by E52**, not deferred (decision #2).
  - **New residue named here (2026-08-31), so it is not deferred to a phantom:**
    the *ascending sequence with per-level faithfulness* that
    `docs/decisions/decision-self-verification.md:241-245` says E52 does not have
    has **no element**. It is not silently E52's; it needs its own catalog and
    ledger row before anything defers to it.
- **Follow-on this unblocks:** the E53 DDC climb's `cert-over-Adhikara` hook
  (⚑ E53 is `built` and cannot run, `decision-self-verification.md:264`); D3
  succession (a stager's core runs `recheck spec successor-core-cert` before
  staging — the certificate IS the succession payload; the seam is stubbed at
  `lib/typing/reflect-floor.chiral:48-54` and does **not** currently compose with
  kernel-core's `recheck`, §2); producer #2+ certification.
- **Related:** [[E52-certificate-split]] (rationale), `decision-split-checker`
  (the settled split — checked socket, not quorum), `certificate-discipline`
  (re-run not spot-check; tiering), **`docs/decisions/decision-self-verification.md`
  (2026-08-31, POSTDATES this SPEC and bounds what its gate may claim — read it
  before implementing)**, [[E03-nbe-normalize]]/[[E04-bidir-universes]]
  (the judgment being split; dec#1 SN tie), [[E13-debruijn]] (`CoreTerm`),
  [[E39-effect-row]] (elaborated-term-as-certificate existence proof),
  [[E71-golden-restructure]] (sibling spec artifact — ⚑ it builds `tal-spec`, not
  `kernel-spec`), ~~[[E12-effect-membrane]] (bootstrap bridge; format home)~~
  **struck: E12 is the effect membrane and owns no bridge**, E53 (DDC
  independence), E72 (re-bootstrap artifact kernel-spec anchors).
