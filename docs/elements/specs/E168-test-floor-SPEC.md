---
element: E168
slug: test-floor
title: **The native test system the Python corpus migrates INTO — a refinement, not a port**
kind: BUILD-PROPER
example: examples/E168-test-floor.md
status: audited
updated: 2026-08-25
---

# E168 SPEC — **The native test system the Python corpus migrates INTO — a refinement, not a port**

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.
>
> ⛑ **status: audited — the fresh-eyes re-audit ran on 2026-08-25 at `14786fd`
> and PASSED.** The two NEEDS-AUTHOR items were answered before it; the re-audit
> reproduced fifteen of the eighteen ledger rows from scratch (§2), applied five
> citation FIXes, and raised no blocking FLAG. FLAG 3 (decision 4,
> the membrane) is answered by the author: **E168 mints its own `Builder`
> capability** rather than wait on E171, the element the audit's measurement
> minted (`SELF-IMPLEMENT-CATALOG.md:436`, `LEDGER.md:103`, state `design`).
> FLAG 4 (decision 10, the oracle seam) is answered by **measurement** — the
> eighteen-row linearity ledger in §2, run against the promoted `scaffold/build/B1`
> at `2c3ca84`. Neither answer is asserted anywhere in this file without the row
> that measured it. Everything the audit FIXed stands; those repairs are still
> marked ⛑ in place, and the two rows this revision rewrote are marked ⚖.
>
> **Position:** E168 builds the **floor**, and only the floor. The 709-function
> corpus migration that motivates it is downstream work and is minted in this
> change as **E170** (§6) rather than smuggled in here. The reason the split is
> load-bearing and not tidiness: migrating 709 tests into today's shape bakes
> the defect in for another year, and *migrating twice is worse than designing
> first* — which is also why the floor must ship with a **real adopter**, not as
> a library nobody's phase returns a value into.

## 1. Deliverable

- **After this runs:** a new pure module `scaffold/lib/test-floor.chiral` in which
  a test is a **value** — an `Expect` carries the **provenance** of its expected
  result as a closed sum (`ExProv`, four arms matching the four ranks of
  `docs/testing-floors.md:166-177`), a `Gate` cannot be constructed without a
  `MutRun` produced by a mutant that was **built and run**, a differential is an
  **expectation source** rather than a verdict (`diff-expect`), and a gate whose
  only expectations were minted by its own differential is scored
  **`g-inadequate` by rank** before a single check runs. Judgment is a total pure
  fold (`check` / `gate-verdict` / `suite-fold`); the only `=>` surface is
  `observe`, `mut-run`, `oracle-ask` and `differ`.
- ⚖ **The capability, and what it buys that the arrow does not.** Every seam that
  **produces evidence** — `observe`, `mut-run`, `oracle-ask`, and `differ` which
  calls the last of them — takes **`(1 bld Builder)`** and hands a fresh one back
  in its result sum; the judgment seams — `check`, `gate-verdict`, `suite-fold`,
  `report` — take none, and that is the whole membrane. `Builder` is minted and
  owned by this element (decision 4). The plain-words reason, because the SPEC
  previously gave a false one:
  - **The arrow is a declaration, not a refusal.** `observe : (=> … )` is
    checked nowhere at the call site. A `->` def calling an `=>` def compiles and
    performs the crossing — measured, and that measurement is the whole content
    of **E171** (`SELF-IMPLEMENT-CATALOG.md:436`, `design`). So with no cap,
    `(observe s)` sitting inside `check` is silently legal, and *"judgment cannot
    manufacture evidence"* is hand-carried discipline — the exact defect this
    element exists to end.
  - **The capability is refused by something that is built.** `check : (-> Expect
    Obs CheckR)` holds no `Builder` binder, so the same call is a type error:
    row **N**, `load: type mismatch`, exit 1; its twin **N′** — the same `check`
    retyped to `(=> (1 bld Builder) Str I64)` — compiles and runs, so the refusal
    is the missing cap and not a lowering miss.
  - **And the cap is linear, which the arrow has no way to be.** A `(1 bld
    Builder)` binder is held to exactly-once by the live checker (rows **L1/L2/L3**),
    so *how many programs this gate built* is a fact of the type rather than a
    convention.
  - **What it does NOT buy, stated rather than implied: unforgeability.** A `->`
    def can mint a cap from the ambient crossing and call the cap-taking observer
    anyway — row **K**, compiles, runs, exit 7. `Builder` is a *threading
    obligation the checker enforces*, not an unforgeable token; forging it costs
    one visible line inside the judgment body instead of no line at all. This is
    P5's verb honesty (`PRINCIPLES.md:141-144`) — detection, not prevention.
    Prevention arrives with **E171** (a `->` body must not reach a crossing) or
    **E80** (the ambient externs go away); E168 waits on neither and defers
    nothing to either.
- ⚖ **"No new externs, no new sysface holes" is restored — and now measured.**
  Every seam above is a `def` or a `data` over crossings that already exist: the
  selected `Oracle` seam compiles and runs with `prelude` alone (row **S**), and
  the `Builder` shape likewise (row **L3**). The claim was false only against the
  *porttype* spelling of `Oracle`, which decision 10 does not take, because a
  freshly named porttype's freshly named externs do **not** lower — row **X**,
  `extern does not lower: builder-close`.
- `scaffold/lib/test-runner.chiral` is rewritten around `test-main` so its six
  samples become a `Suite`, and `scaffold/tests/run-native.sh` grows a **Phase
  12** carrying the three historically could-not-fail gates as fixtures that now
  go RED.
- **Non-goals** (residue with homes in §6):
  - **The migration.** Re-founding the 335 differentials, porting the 68
    B1-driven and rewriting the 306 python-checker-only assertions is **E170**,
    minted in this change. Nothing in this SPEC transcribes a Python test.
  - **Re-expressing the other ten phases.** Phase 2 and the new Phase 12 are the
    adopters; Phases 1 and 3–11 keep their current shell shape and stay green
    unchanged.
  - **Output into a `Console`** (decision 5). The floor uses today's ambient
    `put`. ⚖ `Builder` is **not** on this list — it is built here (decision 4).
    The asymmetry is deliberate and is not taste: nothing in the floor's design
    turns on *who may print*, whereas the floor's whole claim is that **judgment
    cannot manufacture evidence**, and that claim has no other carrier once the
    arrow is measured not to make it. Printing stays ambient until E80; building
    does not.
  - **Import resolution** and the ~35% of suite wall-clock spent forking
    `bin/chirality-resolve.sh` — a harness cost, not the floor's (decision 2).
  - Test discovery, parallelism, timing, and any report format beyond `report`.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E168 postdates the map snapshot; treat as
  **BUILD** (bundle §3). Ledger row `LEDGER.md:136` = `design`.
- **Live code this composes with — do NOT respec any of it:**
  - **`scaffold/lib/ddc.chiral` (the built precedent the example never cites).**
    It is *already* the shape this element generalizes: verdicts as values
    (`DdcR`, `:37-40`), a pure total compare core with the effectful leg-running
    deliberately outside the file (`:1-5`), a declared-and-checked provenance
    record (`Prov`, `:30-31`), pairwise disjointness on named axes
    (`leg2-disjoint?` `:68`, `prov-disjoint?` `:88`), and — the sentence this
    SPEC's rank floor leans on — **"THE QUORUM GATE FIRES BEFORE ANY BYTE IS
    READ. Agreement is not a quorum"** (`:120-126`), with the refusal string
    `"provenance not pairwise disjoint"` at `:139`. `:110-112` states the
    ownership rule explicitly: *"One owner per rule: there is deliberately no
    second disjointness routine on this path."* **The floor must not build a
    second one.**
  - **`scaffold/lib/test-runner.chiral` (68 L).** `(data Sample () (sample (path
    Str) (want I64)))` `:18`; ambient `(extern openat (=> Bytes I64))` `:14` and
    `(extern run-elf (=> Bytes I64))` `:15`; `run-one` `:25-40` — which is
    *exactly* the body `observe` needs (`openat` → `read-fd-all` → `compile-all`
    → `run-elf` → compare); `run-all` `:43`; `manifest` `:49-55` (**six**
    hardcoded samples); `compile-main` `:63-68`, a `(=> I64 I64)` root that
    prints with ambient `put`. There is **no `test-main`** anywhere in the tree.
  - **`scaffold/lib/backend.chiral`** — `(porttype Backend)` `:31`, the E144
    str-carrier note `:24`, and the E145 laundering peel `BePeekR` / `be-peek`
    `:55-56`. This is the only shape in the tree for reading a linear handle's
    identity without scaling it to ω.
  - **`scaffold/lib/secret.chiral:21`** — `(porttype Secret)`. ⚖ *The claim that
    used to close this bullet — "with `Backend`, these are the only two porttypes
    in the tree" — is FALSE and is corrected here, because two decisions leaned
    on it.* `grep -rn '^(porttype' scaffold/lib/` (2026-08-25, `2c3ca84`) finds
    **ten, in seven files**: `Secret` (`secret.chiral:21`), `Backend`
    (`backend.chiral:31`), `Fd` (`ports/fd.chiral:16`), `Clock`/`Timer`/`Env`
    (`ports/clock.chiral:17-19`), `Pool` (`ports/pool.chiral:13`), `Sock`/`LSock`
    (`ports/sock.chiral:16-17`), `Pty` (`ports/pty.chiral:14`). The old figure is
    what a **non-recursive** `scaffold/lib/*.chiral` returns — the measurement
    trap, not a fact. It matters here because `ports/fd.chiral` is 36 L importing
    only `prelude`, i.e. the *cheap* linear handle a carrier-shaped `Oracle`
    would have reached for; decision 10 declines it on grounds that survive the
    correction.
  - **E159, BUILT `7b2b87e`** (`SELF-IMPLEMENT-CATALOG.md:421`): the checker
    refuses *"function parameter of a linear type at quantity omega — a linear
    parameter must be declared (1 x T)"*. ⚖ Re-measured this run as row **P**,
    exit 1, verbatim. **Scope, corrected:** the rule fires on a **porttype**
    parameter. It does *not* fire on a `data` wrapper, however linear its
    contents — row **W** compiles. So the old sentence *"this is why `(->
    Oracle OracleId)` cannot be written and `oracle-id` must peel"* is only true
    of the porttype spelling, which decision 10 does not take; under the shape
    that is taken, the `(1 o Oracle)` declaration is the author's to write and
    the gate that catches a slip is G8, not the checker.
  - **`docs/testing-floors.md:161-201`** — the contract: four ranks (`:166-177`),
    *"A gate row must be able to name its rank. Rank 4 unlabelled is a finding."*
    (`:179`), the run-the-mutant rule (`:183-187`), and the two near-misses
    (`:189-196` E156 G4, `:197-201` E161 G0).
  - **`scaffold/tests/run-native.sh` (297 L, eleven phases)** and
    **`scaffold/tests/samples/` (25 `.chiral` samples)**.
  - Live baseline, measured 2026-08-25 at `6acbf9a` (`ulimit -s unlimited; bash
    scaffold/tests/run-native.sh`, 5m35.806s): **eleven phases, 163 assertions,
    82 roots, exit 0.** Not re-measured in this run; cited, not claimed fresh.
- ⚖ **The linearity ledger — what the built checker actually enforces.**
  Decisions 4 and 10 both turn on one question the SPEC had been answering from
  memory: *does QTT track linearity through a `data` constructor field, and what
  forces the `(1 x T)` declaration in the first place?* Nineteen programs,
  reported as the eighteen rows below (**Wq1** folds its two), plus a handful of
  bisection steps that located **T✗**. Each was
  written to a temp dir, resolved with `bin/chirality-resolve.sh`
  (`chirality_blob_file scaffold/lib`), compiled `ulimit -s unlimited;
  scaffold/build/B1 < blob > out`, and RUN whenever an ELF came out. B1 is the
  promoted `scaffold/build/B1`, 1,077,624 B, tree at `2c3ca84`. Programs deleted
  after the run; every message below is verbatim B1 stderr.

  | Row | Program shape | B1 |
  |---|---|---|
  | **L1** | `(1 b Builder)` binder of an ordinary single-ctor `data` (**no** linear field), **dropped** | exit 1 — `load: linear binder usage mismatch` |
  | **L2** | the same binder, **used twice** | exit 1 — `load: linear binder usage mismatch` |
  | **L3** | the same binder, **used once** | exit 0 → runs, **exit 42** |
  | **F1** | `(1 o Oracle)` whose ctor carries `(1 b Backend)`; the **carried field used twice** | exit 1 — `load: field binder usage mismatch` |
  | **F2** | the same, the **carried field dropped** | exit 1 — `load: field binder usage mismatch` |
  | **F3** | the same, the **carried field used once** | exit 0 → runs, **exit 42** |
  | **W** | the same wrapper declared at **ω** (`(-> Oracle Str)`) and duplicated, so the carried q1 handle is consumed twice | exit 0 → runs, **exit 42 — NOT refused** |
  | **Wq1** | the same wrapper at `(1 o Oracle)`, **dropped whole** / **used twice** | exit 1 — `load: linear binder usage mismatch` (both) |
  | **P** | a bare `(porttype Oracle)` parameter at ω | exit 1 — `load: function parameter of a linear type at quantity omega -- a linear parameter must be declared (1 x T)` |
  | **X** | a **freshly named** porttype whose mint and discharge are **freshly named externs, actually called** | exit 1 — `no emitted label for entry compile-main \| skip chain for compile-main: compile-main: extern does not lower: extern does not lower: builder-close` |
  | **C1** | the full carrier-shaped oracle seam (`(oracle (id OracleId) (1 b Backend))`, `oracle-id` peeling, `oracle-drop` → `backend-close`) | exit 0 → runs, **exit 41** |
  | **C2** | the same with `oracle-drop` **leaking** the carried handle | exit 1 — `load: field binder usage mismatch` |
  | **S** | the **selected** seam — `(oracle (id OracleId))`, `oracle-id`/`oracle-drop` as `->` defs, `prelude` only, no carried handle | exit 0 → runs, **exit 42** |
  | **K** | a `->` `check` that **mints** a cap from the ambient crossing and calls the cap-taking `observe` | exit 0 → runs, **exit 7 — forgery is open** |
  | **N** | `check : (-> Str I64)` calling `(observe s)` where `observe : (=> (1 bld Builder) Str Obs)` | exit 1 — `load: type mismatch` |
  | **N′** | the twin: the same `check` retyped `(=> (1 bld Builder) Str I64)` | exit 0 → runs, **exit 2** |
  | **T** | the Step-3 shape whole: a **three-arm** `ObsR` carrying a fresh `(1 bld Builder)` in *every* arm, one cap serving two `observe` calls, each binder consumed by a `case` in **tail** position | exit 0 → runs, **exit 8** (4+2+2) |
  | **T✗** | the same program with one q1 binder consumed by a **def call nested in an argument position** — `(+ c (discharge b2))` | exit 1 — `load: field binder usage mismatch` |

  ⛑ **Independently reproduced at the re-audit (2026-08-25, `14786fd`), because a
  central claim of this SPEC was measured false once already and a second set of
  measurements does not get taken on trust.** **Fifteen of the eighteen rows** were
  rewritten from scratch by the auditor — new programs, not the author's files —
  resolved and compiled the same way against the same promoted `scaffold/build/B1`
  (1,077,624 B, verified live). **Every one reproduced**, verbatim, including both
  rows the design's honesty rests on: **W** compiles and runs **exit 42** (a `data`
  wrapper at ω carrying a genuine `(1 b Backend)`, duplicated, its handle consumed
  twice — *not refused*), and **K** compiles and runs **exit 7** with the crossing
  performed (forgery open). Also reproduced: **L1**/**L2** `load: linear binder
  usage mismatch`, **L3** exit 42, **F1**/**F2** `load: field binder usage
  mismatch`, **F3** exit 42, **P** `load: function parameter of a linear type at
  quantity omega -- a linear parameter must be declared (1 x T)`, **X** `no emitted
  label for entry compile-main | skip chain for compile-main: compile-main: extern
  does not lower: extern does not lower: builder-close`, **S** exit 42, **N** `load:
  type mismatch` / **N′** exit 2, **T** compiles and runs the three-arm shape through
  two chained observations, and **T✗** `load: field binder usage mismatch`. G2's
  separate `load: non-exhaustive case` was reproduced too. The three not re-run
  (**Wq1**, **C1**, **C2**) are corollaries of rows that were — Wq1 is L1/L2's two
  mistakes on the wrapper form, C1/C2 are the carrier option decision 10 declines.
  ⚑ **And T✗ was hit by accident before it was aimed at**, which is the strongest
  thing that can be said for it: the auditor's first **F3** wrote the discharge as
  `(str-len (be-base b))` — one `be-base` in an argument position, the binder used
  exactly once — and B1 refused it `load: field binder usage mismatch`. Rewritten
  with the peel in tail position, the identical program compiles and exits 42. The
  SPEC's warning that this row is *"the row most likely to burn an implementation
  run"* is not a prediction; it burned this audit inside one turn.

  **What the ledger settles, in the order it matters.** (i) *Linearity does
  survive a `data` field* — F1 and F2 are refused, with their own distinct
  message, so the wrapper is not fiction and the porttype is not forced. (ii)
  *But the field is not where the discipline lives.* L1/L2 refuse the identical
  mistakes on a wrapper carrying **no** linear field at all, so what enforces
  exactly-once is the **binder's declared quantity**, not the carried handle —
  which is the opposite of the "linearity is inherited from the carried port"
  reading, and is the measurement decision 10 turns on. (iii) *Nothing forces
  that declaration for a `data`* — W compiles; only a porttype gets P. (iv)
  *And a porttype is not free* — X does not lower, so option (a) genuinely buys
  P at the price of new `tal-erase` rows and hand-written `bytes-tal` `TIFn`s.
  (v) **And one implementation constraint the SPEC would otherwise have shipped
  wrong.** A cap that is *consumed* by `observe` serves one observation and a
  gate needs many, so `ObsR` must hand a **fresh** `Builder` back in every arm —
  `backend.chiral:26-28`'s rule (*"every be-\* consumes the handle and RETURNS a
  fresh one in its result sum, so a run is a proven-unbroken linear chain"*)
  applied to a multi-arm sum. Row **T** proves that composes. Row **T✗** is why
  it is written down: an **application scales a q1 binder to ω**, so consuming
  the threaded cap as `(+ c (discharge b2))` is refused even though the binder is
  used exactly once. `e145_be_peek_roundtrip.chiral:10-13` states the rule (*"a
  `case` binds base1 and b2 as two separate binders (a case does NOT scale its
  scrutinee's usage) … using `(be-base b)` in any qw position scales the q1
  handle to qw"*); the corollary for Step 3 is that every threaded binder is
  discharged by a `case` in **tail** position or in a `do` head, never nested
  inside another call's argument. ⚑ This is the row most likely to burn an
  implementation run, which is why it is in the baseline and not left to be
  rediscovered.
- **True delta:** one new pure module (~260 L) + a rewritten 68 L runner + one
  new shell phase + eight new fixture samples. Nothing under `scaffold/lib/`
  other than `test-runner.chiral` changes; `mach-c.chiral`, `ddc.chiral` and the
  ten untouched phases are read, not edited.
  ⚖ **Measured 2026-08-25 (estimate left standing above; the delta is the
  calibration data):** the module is **620 L** (2.4x), the runner **116 L**, the
  new phase is a **155 L** script plus 15 lines of `run-native.sh`, and the eight
  fixtures are **356 L**. ⚖ **Re-measured at `f9441e4`** (`wc -l`): module **854
  L** (3.3x), runner **129 L**, phase script **207 L**, and **11** fixtures
  totalling **573 L**. The first measurement was Step 6's shape; the delta since
  is G9/G10's rows and fixtures plus this session's honest-register comments, not
  a re-estimate. The claim that nothing else under `scaffold/lib/`
  changes HELD. The claim that the ten untouched phases are read and not edited
  did **not**: `scaffold/tests/ddc-c-leg.sh` (Phase 10) is edited, because its F3
  differential sweeps `scaffold/tests/samples/` and treats an untabled file as a
  failure. That is the gate working, and Step 6's note records what it caught.
- **Baseline drift since the cited run:** none. `git log 6acbf9a..2c3ca84 --
  scaffold/` is **empty** (nine commits, all docs), so the 11 / 163 / 82 figure
  below is the current tree's, not a stale one.

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | New `test-floor.chiral` beside `test-runner`, or grown inside it? | **RESOLVED → two files, and the path is `scaffold/lib/`, not `lib/`** | `ddc.chiral:1-5` is the settled precedent and states the reason in its own header: the pure compare core is one file, *"the leg-running orchestration … lives outside this file"*, and that split is what makes *"the verdict … re-derivable on the reference floor because everything here is pure and total."* Identical requirement here (a second chirality build or the Rocq leg must re-judge the same observations). The unadopted-floor risk the example names is answered structurally by Step 5+6, not by collapsing the files. ⚑ The example writes `lib/test-floor.chiral`; the tree's library directory is `scaffold/lib/` (`ls lib/` does not exist) — corrected here, not in the example. |
| 2 | Who owns import resolution / the ~35% `bin/chirality-resolve.sh` fork cost? | **RESOLVED → not E168, and no element is minted for it** | The floor is complete without it: `observe` reuses `run-one`'s body (`test-runner.chiral:25-40`), which calls `compile-all` and never forks a resolver. Owning resolution would make the test library a build system — the example's own corollary. No follow-on is named, because nothing in this SPEC waits on it; per the deferral rule an unowned harness cost is recorded as unowned, not parked on a phantom E#. |
| 3 | Do the 25 `scaffold/tests/samples/` become `pv-fixed` or `pv-meaning`? | **RESOLVED → `pv-meaning` (rank 3)** | `testing-floors.md:172-173` defines rank 3 as *"the expected value written down from what the program is supposed to mean, by hand, before running anything."* That is literally `manifest` (`test-runner.chiral:49-55`): `exit42.chiral → 42`, `enum-tag.chiral → 5` — hand-written beside the sample from what the sample means. Rank 2 (`:169-171`) is *"a fixed committed artifact (a golden blob that predates the change)"* — it needs an artifact with a digest, and a sample's exit code has none; the `.chiral` file is the **input**, not the artifact. So `(pv-meaning "sample's declared exit code")`. |
| 4 | Does `Builder` exist, and should the floor reify build/exec authority into a port? | ⚖ **RESOLVED → yes: E168 MINTS `Builder` and threads `(1 bld Builder)` through every evidence-producing seam — `observe`, `mut-run`, `oracle-ask`, `differ` — while `check` / `gate-verdict` / `suite-fold` / `report` take none. Author's call, 2026-08-25, recorded in E171's catalog row (`SELF-IMPLEMENT-CATALOG.md:436`) and ledger row (`LEDGER.md:103`): E168 does not wait on the membrane.** | The half of the old row that stands, re-verified: there is no `Builder` in the tree under any name, and the build-and-run authority is ambient `openat` / `run-elf` (`test-runner.chiral:14-15`). **Why the cap and not the arrow.** The SPEC's original reason for needing no port — *"a `->` function cannot call an `=>` one"* — was measured FALSE at the SPEC audit and is now an element of its own: **E171** (`SELF-IMPLEMENT-CATALOG.md:436`, `design`), whose row carries the five probes. It is **not** restated here as a live claim and nothing in E168 is deferred to it. What replaces it is narrower and measured: with no cap, `(observe s)` inside `check` is a legal call the compiler performs (E171 probe 3 — compiles, prints, exit 7); **with** `(1 bld Builder)` threaded, the same call is refused, because `check : (-> Expect Obs CheckR)` has no such binder — row **N**, `load: type mismatch`, against its compiling twin **N′**. That is a refusal made by a checker that exists today, not by a declaration nothing reads. **Its shape follows decision 10's measurement, not a second design call:** `(data Builder () (builder (via Str)))` — a single-ctor `data`, `via` naming the compiler the floor builds through, binders declared `(1 bld Builder)`. Rows **L1/L2/L3** measure that this is enforced exactly-once: dropped ⇒ `load: linear binder usage mismatch`, twice ⇒ the same, once ⇒ compiles and runs. It is **not** a fresh porttype, because row **X** shows a fresh porttype's externs do not lower; it carries no borrowed handle, because rows L1/L2 show the discipline does not come from one. **Stated rather than implied — the cap is forgeable.** Row **K**: a `->` def mints a cap from the ambient crossing and calls the cap-taking observer; compiles, runs, exit 7. So `Builder` is a threading obligation, not a token, and §1 says so in those words. Under P5's verb honesty (`PRINCIPLES.md:141-144`) that is **detection**, and naming the downgrade is the requirement. Prevention is E171's (the `->` body may not reach a crossing) or E80's (the ambient externs go away) — both minted, neither waited on, nothing deferred to either. ⚑ Deferral-rule honesty, unchanged: E80's cap set is enumerated *Console/Clock/Timer/Env/NetCap* (`SELF-IMPLEMENT-CATALOG.md:128`, verified live) and build/exec is **not** in it, so **no element owned a `Builder`** — which is exactly why E168 mints it here rather than parking it on E80 or on a phantom. |
| 5 | `test-main` takes `(1 c Console)`? | **RESOLVED → no; `test-main : (=> (List Suite) I64)`** | `Console` does not exist. Reifying it is E80, `design` = unbuilt (`LEDGER.md:233`). Writing `(1 c Console)` would take a live dependency on an unbuilt element for a benefit the floor does not need: `compile-main` (`test-runner.chiral:63-68`) already prints through ambient `put`, and `report` is a pure `(-> (List GateR) Str)` deliberately downstream of the verdict, so the printing site is one line. When E80 lands, retyping is a signature change at one call site. |
| 6 | **FLAG 1 — what does E161 G0 re-express as on this floor?** | **RESOLVED → (a), a rank floor, scoped to differential-minted expectations. Conformance target 2 has THREE members.** | The citation holds and is the doc's own diagnosis. `testing-floors.md:197-202`: *"Making **both** providers emit the same wrong marker left the provider-vs-provider differential reporting **ok**. Only the gate's own expected blob — **a rank-2 source outside both legs** — caught it."* (⚑ *re-quoted 2026-08-25: the sentence read "the fixed committed blob" when this decision was written; `testing-floors.md` §*Rank 2's anchor* (`:216-262`) records what the anchor actually was — the gate's own heredoc pin, not the gitignored compiler blob. The operative phrase this decision rests on is unchanged.*) The operative phrase is **"outside both legs"**: the defect is not that the two legs were the same source (they were not — `df-common-mode` genuinely cannot fire), it is that **every expectation in the gate came from inside the comparison.** Mechanized: `differ` mints its `Expect` with the provenance of the **weaker** leg (`oid-prov`), so a provider-vs-provider differential mints `pv-derived` (rank 4 — implementation-derived, `:174-177`); the gate is `g-inadequate` unless `checks` also carries an expectation at rank ≤ 3, i.e. one **not** derived from the implementation. Rank ≤ 3 rather than the recorded instance's rank 2, because `:163-164` states the requirement as *"the source must be independent of the thing under test"* and ranks 1–3 all satisfy it while `:174-177` marks rank 4 as *"never a correctness claim"*. The historical fix — adding the gate's own fixed expected blob — is exactly a rank-2 `Expect` entering `checks`, which turns the fixture green. ⚑ **Scope, so this does not contradict the example.** The example's §5 knob note says a per-phase floor (*"no gate weaker than rank 2"*) is **policy, keep it out of the library** — and that stays true. This rule is narrower and structural: it fires **only** on a gate that carries a differential-minted expectation, and it is about **externality to the comparison**, not about phase-wide strictness. A hand-written rank-4 regression net with no differential in it is still constructible and still green, which `:174-177` permits when labelled — and `pv-derived (why Str)` is the label. |
| 7 | **FLAG 2 — how does a `DiffR` reach a `GateR`?** | **RESOLVED → a differential is an expectation SOURCE, not a verdict** | Stated, per the audit's instruction, rather than inferred. `diff-expect : (-> Str DiffR ExpectR)` where `ExpectR = (ex-ok (e Expect)) \| (ex-refused (why Str))`. `(df-agree obs)` → `(ex-ok (ex what obs (oid-prov weaker)))` — the agreed observation becomes the `want`, at the provenance of the **weaker of the two legs asked**. `(df-differ a b)` → `(ex-refused "legs disagree")`: two opinions that differ supply **no** expected value, and the disagreement is itself the finding. `(df-common-mode id)` → `(ex-refused "one source is not two opinions")`. `Gate` therefore gains one field — `(diffs (List Expect))` — so that "this expectation was minted by a differential" is a **fact of the type**, not a naming convention, which is what arms decision 6's rank floor. This is also precisely what makes swapping Python→CompCert a *data change*: you construct a different `Oracle` at the call site and the minted `Expect` changes its `ExProv` with it. |
| 8 | Is `mu-survived` ever legitimately green (a semantically-equivalent mutant)? | **RESOLVED → no escape hatch** | `testing-floors.md:183-184` requires a gate to *"name a mutant that **falsifies** it"*. A mutant that is semantically equivalent by construction does not falsify the gate, so it was never a valid mutant for the rule — the rule already excludes it, and no arm is needed to excuse it. `:203-212` is the precedent for the disposal: E166's mutant (c) was *"caught by the shim gate and by G4 conviction, **missed by F3**"* and is **recorded as a measurement, not excused** — *"A mutant a gate misses is as much a measurement as one it catches."* An author who believes a mutant is equivalent picks a different mutant; `g-inadequate` carries the label so the report names which one survived. Adding a labelled escape hatch recreates advice, which is the defect the element exists to end. |
| 9 | Naming: the floor's provenance sum vs `ddc.chiral`'s `Prov` | **RESOLVED → `ExProv` / `CheckR`; `Obs`, `Expect`, `Gate`, `Suite` keep their example names** | `ddc.chiral:30` already owns `(data Prov ())` with entirely different fields `(language toolchain author epoch)`. Duplicate type names *are* tolerated in this tree — `Verdict` is defined three times (`kernel-core.chiral:39`, `tal-spec.chiral:50`, `totality.chiral:50`) — but only because those import closures are disjoint, and that is exactly the condition that fails here: the E166 DDC gate is one of the gates that will eventually return a `Suite`, putting `ddc.chiral` and the floor in one closure. So the floor's sum is `ExProv` (arms unchanged: `pv-external` / `pv-fixed` / `pv-meaning` / `pv-derived`) and `check`'s result is `CheckR` (`ck-pass` / `ck-fail`) rather than a fourth `Verdict`. |
| 10 | Must `Oracle` be a bare porttype or a carried one? | ⚖ **RESOLVED → a single-ctor `data` whose field is its own identity — `(data Oracle () (oracle (id OracleId)))` — with every binder declared `(1 o Oracle)`. No porttype, no borrowed handle, no new extern.** | The author's three-way was to be settled by measurement, and the measurement is §2's ledger. **The condition that would have killed the wrapper is not met:** a q1 handle in a `data` field can be neither consumed twice (**F1**) nor dropped (**F2**) — both `load: field binder usage mismatch` — so the refusal is real and *plain data with no linearity* stays rejected on principle 6 as it was. **But the same ledger relocates where the linearity comes from,** and that is what picks the shape. Rows **L1/L2/L3** run the identical mistakes against a wrapper carrying **no** linear field and get the identical refusals (`load: linear binder usage mismatch`): exactly-once is a property of the **declared binder quantity**, not of the carried port. So the carrier's advertised benefit — *"linearity is inherited rather than re-minted"* — is measured absent. What a carrier would add is one further refusal on the field (F1/F2, and **C2** on a full seam), and it would cost a handle that this floor never crosses: `oracle-ask` reaches its leg through the ambient `openat`/`run-elf`, so a carried `Fd` or `Backend` would be **inert at runtime and minted from nothing**. `http.chiral:454-455` is verified verbatim (*"A bare porttype cannot be bridged from a crossing return, so retype it as a single-ctor data carrying **the live Sock cap** + …"*) and **"live" is the load-bearing word**: there the carried cap is the stream. Here there is no live handle, and minting a fake one to borrow a refusal is a claim of possession the floor does not have — P3 governs ports that are actually crossed, and principle 6 cuts an abstraction that names a port it never opens. **Why not the porttype (option a).** It buys exactly one thing the wrapper does not: it makes the `(1 x T)` declaration compulsory — row **P** refuses a porttype parameter at ω, row **W** shows a `data` wrapper at ω is admitted and its contents duplicated. That is a real gap and it is owned as residue in §6, not glossed. It is declined because the price is measured: row **X** — a freshly named porttype's freshly named externs do **not** lower (`extern does not lower: builder-close`), so option (a) means new `tal-erase.chiral:123-133` rows and hand-written `bytes-tal.chiral` `TIFn`s (`nb-be-peek-t` `:35`, `nb-be-close-t` `:47`, both verified live). That is **new trusted surface grown so a test library can express itself**, which inverts P5's tiering — *"spend the strong rungs where they are load-bearing; floor the rest on purpose"* (`PRINCIPLES.md:178-179`). The W gap is instead floored on purpose, and G8 is the floor: one mechanical row asserting every `Oracle`/`Builder` occurrence in a `test-floor.chiral` signature is at `(1 x T)`. A grep is detection, not proof, and §5 labels it as such. **The seam this yields, measured whole:** row **S** — `oracle-id : (-> (1 o Oracle) OracleIdR)` peeling by `case` and rebuilding, `oracle-drop : (-> (1 o Oracle) Unit)` consuming it, `prelude` the only import — compiles and runs. Consequence for §1's `=>` list: `oracle-id` and `oracle-drop` are **pure**, so the crossing surface is `observe`, `mut-run`, `oracle-ask`, `differ`. ⚑ **Divergence from the brief, declared rather than absorbed:** the author's option 3 said *carrying an existing linear handle*. Rows L1/L2 are why the carrier is dropped while option 3 is otherwise taken; a reviewer who wants the carrier back gets F1/F2/C1/C2 as the cost-free half of the evidence and the inert-handle argument as the objection. |
| 11 | How much adopts in this SPEC? | **RESOLVED → Phase 2 + a new Phase 12; Phases 1, 3–11 untouched** | The measured failure mode in this repo is *"built but unadopted"* (four occurrences, E42 among them), so a floor with no adopter is not shippable. But re-expressing eleven phases is the migration, which is E170. Phase 2 is the right first adopter — it is the only phase whose assertions already live in chirality (`manifest`, six samples), so adopting it is a rewrite of one 68 L file rather than a shell excavation. Phase 12 is where `differ`, the mutant rule and the rank floor get a real adopter, via the three historical could-not-fail gates. |

⚖ **No NEEDS-AUTHOR items remain.** Decision 4 is the author's call (mint `Builder`
here, do not wait on E171); decision 10 is settled by §2's ledger, in the direction the
measurement supports. Decisions 1, 2, 3, 5, 6, 7, 8, 9 and 11 stand as RESOLVED with
every citation re-verified against the live tree at the 2026-08-25 SPEC audit, and the
three this revision touched (`LEDGER.md:136`/`:233` after E171's insertion shifted them,
`SELF-IMPLEMENT-CATALOG.md:128`, `http.chiral:454-455`) re-verified again here.
`status: audited` — the fresh-eyes re-audit ran and passed (§2's reproduction note);
this file is now the implementation contract.

## 4. Change plan (ordered, commit-sized)

### Step 1 — the provenance + observation core
- **Target:** `scaffold/lib/test-floor.chiral` (new) — `ExProv`, `prov-rank`,
  `Obs`, `obs-cmp`, `CheckR`, `Expect`, `check`.
- **Change:** the example §5 blocks 1–3 verbatim except `Prov`→`ExProv`,
  `Verdict`→`CheckR` / `vd-pass`→`ck-pass` / `vd-fail`→`ck-fail` (decision 9).
  `prov-rank` is total with **no default arm** — a fifth source forces every rank
  policy to be revisited. `obs-cmp` is structural with one arm per `Obs`
  constructor; mismatched constructors are `ck-fail`. `Obs` ships with exactly
  `ob-exit` / `ob-bytes` / `ob-int` — **no `ob-text`**, so a rendering cannot be
  the deciding value (the E166 inverted-comparison lesson,
  `testing-floors.md:204-213` context).
- **Size:** ~S (~70 L). ⚖ **Measured: the four steps landed as one 620 L file**
  (`wc -l scaffold/lib/test-floor.chiral`, 2026-08-25 after Step 5's `ObsKey`
  retype; 581 L at Step 4's commit `8a30f89`; **854 L** at `f9441e4`, the growth
  after Step 6 being comment rather than code). Per-step figures are not separable
  after the fact and the estimate is left standing rather than overwritten -- the
  prediction-vs-outcome delta is the calibration data. The whole-module estimate
  is §2's ~260 L, so the module came in at **2.4x** (2.2x at Step 4).

### Step 2 — the oracle seam
- **Target:** `scaffold/lib/test-floor.chiral` — `Oracle`, `OracleId`,
  `OracleIdR`, `oid-prov`, `oracle-id`, `oracle-ask`, `oracle-drop`, `id-eq`,
  `DiffR`, `diff-of`, `differ`, `ExpectR`, `diff-expect`.
- ⚖ **Unblocked; written against decision 10's resolved shape**, whose whole seam
  was compiled and run as ledger row **S** before this step was written.
- **Change:** `(data Oracle () (oracle (id OracleId)))` — a single-ctor `data`
  whose field is its own identity, **not** a porttype and **not** a carrier for a
  borrowed handle (decision 10). Every binder is declared `(1 o Oracle)`; that
  declaration is what makes the port linear (rows **L1/L2/L3**), and G8 is the row
  that catches a slip to ω, which the checker does not (row **W**). `oracle-id :
  (-> (1 o Oracle) OracleIdR)` is a `case` that reads the id and rebuilds a fresh
  wrapper — **pure**, because possession is not exercise, and no `be-peek`-shaped
  extern is involved. `oracle-drop : (-> (1 o Oracle) Unit)` consumes the wrapper
  by `case`; also pure, matching `backend-close`'s own precedent
  (`backend.chiral:42-43`, *"Pure (`->`): no syscall"*). `oracle-ask` is the one `=>`
  def here: it dispatches on the peeled `OracleId` and reaches the
  named opinion through crossings that already exist (`openat` + `read-fd-all`
  for `or-fixed`, `compile-all` + `run-elf` for an in-tree leg) — which is build
  and exec authority, so it takes **`(1 bld Builder)`** and returns a fresh one in
  every arm of its result sum, and `differ` threads the same cap through both
  asks. ⚖ `differ` is otherwise the example's body unchanged: same id ⇒ drop both
  ports and return `(df-common-mode id)` **without asking** — no observation
  manufactured, no port leaked, and the cap handed straight back unspent, which is
  itself observable in the type; otherwise ask each port exactly once and
  `diff-of` the pair. Every threaded binder is discharged by a `case` in tail
  position (ledger rows **T** / **T✗**).
  `oid-prov : (-> OracleId ExProv)` is total: `or-ccomp`/`or-gcc`/`or-rocq` →
  `pv-external`; `or-fixed` → `pv-fixed`; `or-python` and any in-tree provider →
  `pv-derived` (it is a sibling implementation of the thing under test, rank 4 by
  `testing-floors.md:174-177`). `diff-expect` implements decision 7, minting at
  the **weaker** leg's provenance (`max` of the two ranks).
- **Size:** ~M (~90 L). ⚖ *See Step 1's measured note: the module is one file and
  the per-step split is not recoverable from it.*

### Step 3 — the mutant rule, the gate fold, and the rank floor
- **Target:** `scaffold/lib/test-floor.chiral` — `MutRun`, `observe`, `mut-run`,
  `Gate`, `GateR`, `best-rank`, `fold-checks`, `gate-verdict`.
- **Change:** `MutRun` is `mu-killed (label Str) (base Obs) (mutated Obs)` |
  `mu-survived (label Str) (obs Obs)` — constructible only from observations, so
  "I named a mutant" cannot be typed as "I ran one". `observe` is
  `run-one`'s body (`test-runner.chiral:25-40`) with the comparison removed and
  the exit code returned as `(ob-exit code)`.
  ⛑ **Corrected at the SPEC audit: `run-one`'s body has THREE exits, not one.**
  `:31` is `FAIL openat` and `:35` is `FAIL compile`; both return before any exit
  code exists, and neither has an `Obs` to yield. `observe : (=> Str Obs)` is
  therefore not constructible from that body, and the sentinel repair — returning
  `(ob-exit -1)` for "the file was not there" — is a which-of-N encoded as a
  magic number, which `docs/pattern-boundary-sums.md`'s standing directive makes
  a finding. Signature is **`observe : (=> (1 bld Builder) Str ObsR)`** with

  ```
  (data ObsR ()
    (ob-ok      (o Obs)    (1 bld Builder))
    (ob-nofile  (path Str) (1 bld Builder))
    (ob-nobuild (why Str)  (1 bld Builder)))
  ```

  ⚖ **Two things merge in that declaration and both are load-bearing.** The
  *arms* are the audit's repair — a result sum instead of an `(ob-exit -1)`
  sentinel, the same shape decision 7 chose for `ExpectR = ex-ok | ex-refused`.
  The *fresh `(1 bld Builder)` in every arm* is decision 4's restoration, and it
  is not decoration: a cap that `observe` merely consumed would serve exactly one
  observation and a gate needs many, so the cap must come back out.
  `backend.chiral:26-28` is the precedent in its own words — *"every be-\*
  consumes the handle and RETURNS a fresh one in its result sum, so a run is a
  proven-unbroken linear chain — no duplicated handle … and no silent drop"*.
  Ledger row **T** compiles and runs exactly this three-arm shape through two
  chained observations; row **T✗** is the trap beside it — an application scales a
  q1 binder to ω, so `(+ c (discharge b2))` is refused though `b2` is used once.
  Discharge every threaded binder by a `case` in **tail** position or a `do` head.
  `mut-run : (=> (1 bld Builder) Str Bytes MutRunR)` threads the same way, with
  `MutRunR` carrying the fresh cap beside the `MutRun`: build+run the base, apply
  the mutation bytes, build+run the mutant, return `mu-killed` iff the two `Obs`
  differ and `mu-survived` if they do not. Note two observations are performed, so
  the cap is threaded twice inside the body — which is the point of it being
  linear rather than ambient.
  `Gate` is `(gate (name Str) (checks (List Expect)) (diffs (List Expect))
  (adequacy MutRun))` — the fourth field per decision 7. `gate-verdict` is a
  pure `(-> Gate (List Obs) GateR)` with the arms in this order, and the order is
  the contract:
  1. `(mu-survived label o)` ⇒ `(g-inadequate name label)` — **scored RED before
     any check runs**;
  2. `diffs` non-empty **and** `(>i (best-rank checks) 3)` ⇒
     `(g-inadequate name "no expectation outside the compared legs")` — the
     decision-6 rank floor, and the only clause that is new relative to the
     example. ⛑ **`best-rank` is spelled out at the SPEC audit, because the
     obvious fold makes this clause unable to fire.** `best-rank` is the
     **minimum** `prov-rank` over the list (best = strongest = smallest), and its
     empty-list case is **5, not 0** — the weakest possible value. A fold seeded
     at 0 returns 0 for `checks = nil`, `(>i 0 3)` is false, and a gate carrying
     a differential-minted expectation and **no checks at all** scores green:
     the E161 G0 defect, reintroduced by the accumulator. Decision 6's wording is
     the authority — *"`g-inadequate` unless `checks` **also** carries an
     expectation at rank ≤ 3"* — and an empty `checks` carries none;
  3. otherwise `fold-checks` over `checks ++ diffs`: first `ck-fail` ⇒ `g-red`,
     else `(g-green name n worst)` carrying the count and the **weakest** rank.
- **Size:** ~M (~90 L). ⚖ *See Step 1's measured note.*

### Step 4 — the suite fold and the entry
- **Target:** `scaffold/lib/test-floor.chiral` — `Suite`, `suite-fold`, `report`,
  `test-main`.
- **Change:** `Suite = (suite (phase Str) (gates (List Gate)))`; `suite-fold :
  (-> Suite (List (List Obs)) (List GateR))` pure; `report : (-> (List GateR)
  Str)` pure and deliberately downstream of the verdict so it can never decide
  it; `test-main : (=> (List Suite) I64)` (decision 5) printing `report`'s string
  through ambient `put` and returning 0 iff every `GateR` is `g-green`.
- ⚖ **`test-main` is also the floor's one mint site.** It constructs the single
  `(builder "B1")` the run threads and discharges it before returning; nothing
  below it constructs one. That is the property G8 asserts mechanically and the
  one row **K** says the type system will not assert for us — a second
  construction anywhere in `test-floor.chiral` compiles, so *one mint site* is a
  checked fact about this file, not a guarantee about chirality.
- **Size:** ~S (~50 L). ⚖ *See Step 1's measured note.*

### Step 5 — adopt: `test-runner.chiral` is rewritten around the floor
- **Target:** `scaffold/lib/test-runner.chiral` — `Sample`, `manifest`,
  `run-one`, `run-all`, `compile-main`.
- **Change:** `manifest`'s six `Sample`s become a `Suite` whose gates carry
  `(ex path (ob-exit want) (pv-meaning "sample's declared exit code"))` per
  decision 3; `run-one` becomes `observe` (moved to the floor in Step 3) and the
  comparison moves into `check`; `run-all` becomes `suite-fold`; `compile-main`
  keeps its name and `(=> I64 I64)` type — it is the entry symbol the native
  driver compiles (`test-runner.chiral:58-59`) — and becomes the `=>` shell that
  calls `test-main`. ⚖ `test-runner.chiral`'s two ambient externs (`openat` `:14`,
  `run-elf` `:15`) move behind `observe`, so they are named in one file and
  reached only with a cap in hand; they stay ambient *externs* (removing that is
  E80's) and the SPEC claims nothing more. Each gate needs a `MutRun`: the manifest gate's mutant is
  "corrupt the compiled ELF's entry byte", run once, expected `mu-killed`.
  ⛑ **The step must also make Phase 2 REBUILD the runner, or the adoption is
  unobservable — measured at the SPEC audit.** `run-native.sh:94-105` runs the
  prebuilt `scaffold/build/test-runner` and no phase in the suite rebuilds it;
  the file is not even tracked (`git ls-files scaffold/build/test-runner` is
  empty, mtime 2026-08-25 01:05), and `docs/banks/verification.md` already says
  so in the C-leg admission caveat — *"Phase 2 contributes no assertions to that
  count (it executes the prebuilt `scaffold/build/test-runner`, which no compiler
  in the run rebuilds)"*. So this whole step could land, the source could be
  reverted, and Phase 2 would stay green off a stale binary. Phase 2 gains the
  build line the harness already documents at `run-native.sh:104`
  (`chirality_blob … test-runner | B1 > build/test-runner`) **before** it runs, so
  that the floor being adopted is a fact the suite can see. Without this, G1 and
  G7 below cannot fail — this repo's own recorded failure mode, and the fourth
  instance of it.
- **Size:** ~M (rewrite of a 68 L file, plus ~4 lines of Phase 2 harness).
  ⚖ **Measured 2026-08-25:** `test-runner.chiral` **68 -> 116 L** (⚖ *`wc -l` at
  `f9441e4`: **129 L**, Step 6's follow-on fixes;*
  +152/-78 in the diff, so a rewrite and not an edit, as estimated). The Phase 2
  harness came in at **+62/-14 lines of `run-native.sh`**, not ~4 -- the estimate
  counted the build line and not the rebuild's own failure path, its guard for a
  missing resolver, or the ⚑ comment recording why a phase that ran a prebuilt
  binary was the fourth instance of this repo's measured failure mode. A fifth
  file was touched that the estimate did not name at all: `ddc-c-leg.sh`
  (+56/-8), because E166's F3 differential sweeps `scaffold/tests/samples/` and
  Step 6's fixtures had to be tabled there -- see the note on Step 6.

### Step 6 — the three could-not-fail gates, and the cap, as a new Phase 12
- **Target:** `scaffold/tests/samples/e168_*.chiral` (new) +
  `scaffold/tests/run-native.sh` (new Phase 12 block, following the Phase 11
  pattern at `:265`).
- **Change:** four **verdict** fixtures, each a root program returning an exit code that
  fixes its meaning, in the style of `e166_ddc_legc.chiral`:
  `e168_mut_survived.chiral` (E156 G4: a gate whose `MutRun` is `mu-survived` ⇒
  `g-inadequate` before any check), `e168_mut_identical.chiral` (E166 G3: two
  identical `Obs` from `mut-run` ⇒ `mu-survived`), `e168_rank_floor.chiral`
  (E161 G0: a `differ` over two **distinct** in-tree providers, both wrong the
  same way ⇒ `df-agree` ⇒ a rank-4 minted `Expect` ⇒ `g-inadequate`; then the
  same gate **with** a `pv-fixed` check ⇒ `g-green`, reproducing the historical
  fix; ⛑ **and a third case added at the SPEC audit — the same gate with a
  `pv-meaning` (rank 3) check instead ⇒ `g-green` too.** Without it G4's second
  mutant cannot fire: raising the floor from ≤ 3 to ≤ 2 leaves a `pv-fixed`
  (rank 2) anchor green, so the fixture would report exactly the same verdict
  under the mutant as without it, and the row would claim to prove a boundary it
  never touches), and `e168_common_mode.chiral` (two ports carrying the same `OracleId` ⇒
  `df-common-mode`, both ports dropped, nothing asked, and the cap handed back
  unspent).
- ⚖ **Plus a fifth positive fixture and three refusal fixtures, replacing the one
  refusal pair the SPEC used to carry.** The old pair asserted that `(-> Oracle
  OracleId)` is refused by E159 — true of a **porttype** `Oracle`, which decision
  10 does not build. Under the shape that is built, that declaration **compiles**
  (ledger row **W**), so the old row would have asserted a refusal that does not
  happen. What is refused, measured, is the linear discipline itself, and each
  refusal fixture ships beside a compiling twin so no control can pass for the
  wrong reason (the E159 false-control lesson, `SELF-IMPLEMENT-CATALOG.md:421`):
  - `e168_cap_thread.chiral` — the **positive control**: one `Builder` minted, two
    observations threaded through it, an `Oracle` asked once and dropped, exit 0.
    This is the twin for all three refusals below; without it their exit-1 could
    be any compile error at all.
  - `e168_reject_nocap.chiral` — a `check`-shaped `->` def with no `Builder` binder
    calling `observe` ⇒ `load: type mismatch` (row **N**; its twin **N′** is the
    fixture above). *This is the fixture that carries the element's central
    claim*: judgment cannot reach the evidence-producing seam **with no cap in
    hand**. ⛑ *Qualifier added at the re-audit, so this line agrees with §1
    rather than restating the claim §1 spends a bullet downgrading.* Unqualified
    it would assert what row **K** measures FALSE — a `->` def that mints its own
    `Builder` reaches `observe` and runs (re-measured at the re-audit: compiles,
    prints, **exit 7**). What the fixture pins is that reaching the seam costs a
    visible line, which is detection, not prevention.
  - `e168_reject_cap_drop.chiral` — `observe`'s `(1 bld Builder)` dropped instead
    of returned ⇒ `load: linear binder usage mismatch` (row **L1**).
  - `e168_reject_port_twice.chiral` — `differ` asking one `(1 o Oracle)` twice ⇒
    `load: linear binder usage mismatch` (row **L2**).
  All three carry `_reject_` in the name — the tree's existing convention for "must
  not compile" (`e166_mach_c_reject_lda6.chiral`; `run-native.sh:170` skips the
  pattern in the Phase-7 sweep, 6 such files today). ⚑ Here the naming is
  convention only, not protection: the Phase-7 sweep does not reach
  `scaffold/tests/samples/` at all (measured below), so what keeps these three out
  of a "must compile" sweep is that no sweep covers their directory. Phase 12 is
  the only thing that asserts their DIAGNOSTIC, and it must assert **exit 1 AND
  the diagnostic text**, never exit-1 alone. ⛑ *"The only thing that runs them"
  corrected 2026-08-25: Phase 10's F3 differential sweeps all 36 files in that
  directory and carries these under the `refused` marker it grew when it caught
  them untabled — F3 checks THAT both legs refuse, Phase 12 checks WHY.*
- **Size:** ~M. ⚖ **Measured 2026-08-25:** eight fixtures **356 L** total
  (`e168_rank_floor` 85, `e168_cap_thread` 55, `e168_common_mode` 52,
  `e168_mut_identical` 48, `e168_mut_survived` 45, `e168_reject_nocap` 28,
  `e168_reject_port_twice` 23, `e168_reject_cap_drop` 20) plus a **155 L**
  `scaffold/tests/test-e168-floor.sh` and a 15-line Phase 12 block in
  `run-native.sh`. ⚖ **Re-measured at `f9441e4`** (`wc -l
  scaffold/tests/samples/e168_*.chiral`): **11** fixtures, **573 L** — the three
  since are `e168_empty_floor` 107, `e168_reject_diff_swap` 56 and
  `e168_reject_hand_diff` 32, from G9/G10, and two of the original eight grew a
  correction comment this session (`e168_rank_floor` 85 → 101,
  `e168_mut_identical` 48 → 54) — and the script is **207 L**, asserting **12**
  rows. The element's whole diff against `8a30f89` is **+772/-78**
  across 13 files.
  ⚑ **And one thing the step plan did not anticipate, recorded because the
  estimate is only useful beside what it missed.** The SPEC states that
  `_reject_` is "the tree's existing convention for 'must not compile'", citing
  `e166_mach_c_reject_lda6.chiral`. Measured: that sample **compiles** and exits
  1 -- in `scaffold/tests/samples/` the convention has meant "runs and must not
  exit 0". E166's F3 differential sweeps that directory and fails on any untabled
  file, so the first full-suite run after Step 6 came back exit 1 with eight
  such failures. The repair was to teach the F3 table a third marker, `refused`
  (both legs must reject the sample, with the same message) -- which gave that
  differential the negative half its own header asks for and it never had.

- **Golden behavior:** the live suite still passes unchanged, and the three
  recorded shapes in which a gate **could not fail** now go RED on this floor —
  because a green re-expression proves nothing, green being what all three
  already were. ⛑ *"Three gates that historically could not fail" corrected
  2026-08-25: none of the three shipped. `testing-floors.md:183-187` records
  **two near-misses** (E156 G4, E161 G0), each caught in the session that
  produced it; E166 G3's identically-objdumping `m_mul` was measured at design
  time and replaced before the row shipped, which this SPEC's own G3 cell and
  `E166-mach-c-SPEC.md:556` both say.*

| # | Row | Expectation-provenance rank | Mutant that falsifies it |
|---|-----|------------------------------|--------------------------|
| G1 | Phase 2's six samples, re-expressed as a `Suite`, still exit 0 with every `Expect` carrying an `ExProv` and no arm added to `ExProv` | **rank 3** — `pv-meaning`; the wants are hand-derived from each sample's meaning (`testing-floors.md:172-173`, decision 3) | Change the `exit42.chiral` gate's `want` to 41 ⇒ `ck-fail` ⇒ `g-red`. If it stays green, `check` is not reaching `obs-cmp`. ⛑ **Runnable only with Step 5's Phase-2 rebuild**: the mutant edits `test-runner.chiral` source, and `run-native.sh:94-105` executes a prebuilt, untracked `scaffold/build/test-runner` that no phase rebuilds — so without the rebuild this mutant changes nothing the suite can see. |
| G2 | E156 G4 re-expressed: `list-sort` deleted, mutant **survives** ⇒ `g-inadequate` before any check runs | **rank 3** — `pv-meaning`. ⛑ *Was "rank 2 — the historical record is a committed artifact"; corrected at the SPEC audit.* `testing-floors.md:169-171` reserves rank 2 for an independent second computation or **a golden blob that predates the change**; a prose record in a note is neither. The expected value here is `g-inadequate`, hand-derived from what the floor is supposed to mean before anything ran — `:172-173` exactly. `testing-floors.md:189-196` stays cited as the row's **motivation**, not as its expectation's source. | ⛑ *Restated at the SPEC audit — the mutant as written cannot be RUN.* Deleting the `(mu-survived …)` arm makes the `case` non-exhaustive, and B1 refuses it: `load: non-exhaustive case` (measured 2026-08-25 at `b67714b`). A mutant the compiler rejects was never built, so it produces no measurement under `testing-floors.md:183-187`. The runnable form **replaces the arm's body** with `(fold-checks name checks got)`, keeping the case total: the fixture then goes **green**, i.e. the shipped defect returns. |
| G3 | E166 G3 re-expressed: `m_mul` mutant objdumps identically ⇒ `mut-run` yields `mu-survived` ⇒ `g-inadequate` | **rank 3** — `pv-meaning`; the expectation *"two equal observations are not a killed mutant"* is hand-derived from the meaning of `MutRun` (`testing-floors.md:172-173`). ⛑ *Was rank 2; corrected at the SPEC audit for the same reason as G2 — `testing-floors.md:204-213` and `docs/banks/verification.md:236-240` (byte-identity under gcc 12.2.0 and CompCert 3.17, 1,077,624 B, both verified live; ⛑ *was `:223-230`, which is the E171 membrane-mutant paragraph — corrected at the re-audit*) are the row's motivation, not a golden artifact supplying its expected value.* | Make `mut-run` return `mu-killed` when its two `Obs` are **equal** ⇒ G3 goes green, proving the two-observations-must-differ requirement is what carries it. |
| G4 | **FLAG 1's target.** E161 G0 re-expressed: `differ` over two distinct in-tree providers both wrong the same way ⇒ `df-agree` ⇒ a rank-4 minted `Expect` ⇒ **`g-inadequate` by rank**; adding the fixed expected blob as a `pv-fixed` check ⇒ `g-green` | **rank 3** for the ROW's own expectation (`g-inadequate`, then `g-green`, both hand-derived from the floor's rules — `testing-floors.md:172-173`); **rank 2 for the `pv-fixed` blob the fixture carries as data**, which is the historical fix itself. ⛑ *Was "rank 2" for the whole row; split at the SPEC audit.* `testing-floors.md:197-202` — *"Only the gate's own expected blob — a rank-2 source outside both legs — caught it"* — verified verbatim and is what the ≤ 3 floor is built from (⚑ *the page said "the fixed committed blob" when this row was written; corrected 2026-08-25, `:216-262`*). | Delete clause 2 (the rank floor) from `gate-verdict` ⇒ the fixture reports green with **both providers wrong**, which is the 2026 defect verbatim. (Runnable: clause 2 is a guard, not a `case` arm, so deleting it still compiles — unlike G2's.) Second mutant: raise the floor to rank ≤ 2 ⇒ the rank-3 `pv-meaning` anchor added to `e168_rank_floor.chiral` at the SPEC audit is wrongly reddened, showing the ≤ 3 boundary is chosen, not accidental. ⛑ **Without that third fixture case this second mutant could not fire at all** — the fixture's only green anchor was `pv-fixed` (rank 2), which survives the raised floor unchanged. |
| G5 | `df-common-mode`: two ports carrying the same `OracleId` are refused **without either being asked**, both are dropped, and the `Builder` comes back **unspent** | **rank 3** — meaning of the form; the same rule the built `ddc.chiral:120-126` states as *"Agreement is not a quorum"* | Replace `differ`'s `(id-eq ida idb)` guard with `false` ⇒ one source is consulted twice and returns `df-agree`. Second mutant: drop the `oracle-drop` calls ⇒ the linear checker must reject the unconsumed ports. ⚖ **Both mutants re-checked against the shape decision 10 actually builds, and both still fire.** The second one used to lean on `Oracle` being a porttype; it does not need to. Measured this run on a `data`-shaped `Oracle` at `(1 o Oracle)`: dropped ⇒ exit 1, `load: linear binder usage mismatch` (row **L1**); asked twice ⇒ exit 1, same message (row **L2**); asked once ⇒ compiles and runs (row **L3**). ⚑ Third mutant, new with the cap: have `differ` **discard** the `Builder` instead of returning it ⇒ `load: linear binder usage mismatch`, which is what makes "the cap came back unspent" a claim the compiler checks rather than a sentence in this table. |
| G6 | ⚖ **Rewritten — the row it replaces asserted a refusal that does not happen.** The linear discipline of `Builder` and `Oracle` is REFUSED in three named ways, each beside a compiling twin: (i) a cap-less `check` calling `observe` ⇒ `load: type mismatch`; (ii) a dropped `(1 bld Builder)` ⇒ `load: linear binder usage mismatch`; (iii) an `(1 o Oracle)` asked twice ⇒ the same. The twin is `e168_cap_thread.chiral`, which threads both exactly once and runs | **rank 2** — the committed diagnostic text of a compiler that is built; each string measured verbatim this run against `scaffold/build/B1` at `2c3ca84` (rows **N**, **L1**, **L2**) with its compiling control (rows **N′**, **L3**) | Retype `observe` to drop the `(1 bld Builder)` parameter entirely ⇒ (i) compiles, and the fixture that must fail stops failing. That single mutant falsifies the element's central claim, which is why it is the row. ⛑ **RUN 2026-08-25, and this account of it is WRONG — recorded rather than quietly fixed, because a mutant described but not run is the defect this element exists to end.** (a) The one-line form *does not compile*: dropping the parameter from the signature and `bld` from the `lam` leaves the body naming `bld`, so B1 answers `load: unknown name bld` and nothing is built. (b) Carried through properly — mint a `(builder …)` inside both of `observe`'s arms and repair its two call sites (`mut-run`, `observe-exs`), each consuming the incoming cap with `(case bld ((builder via) …))` — the library **does** compile (a trivial root importing `test-floor` builds, exit 0), so the mutant is real. (c) But `e168_reject_nocap` **still does not compile**, and not for this row's reason: **`load: field binder usage mismatch`**, a diagnostic this SPEC never names, because `ObsR`'s three arms each carry a `(1 bld Builder)` FIELD that the fixture's case arms bind and drop. The row still fires — `refuses` demands `load: type mismatch` and gets a different message — and so does G6's twin: `e168_cap_thread` hands `(builder "B1")` to a mutated `observe` that now expects a `Str`, giving `load: builder checked against a non-data type`. So this is a false ACCOUNT of a live gate, not a dead gate, and what the run actually shows is that the cap parameter is not the only thing carrying the discipline: `ObsR`'s q1 field carries it one layer down. Method: `scaffold/lib` copied to a scratch dir, mutated there, fixtures resolved against the copy with `chirality_blob_file` and compiled by `scaffold/build/B1`; the tree was never mutated. ⛑ **The old row is retired, not softened.** It asserted that `(-> Oracle OracleId)` is refused at load with E159's message — true only of a **porttype** `Oracle`. The audit measured that half honestly (exit 1, `load: function parameter of a linear type at quantity omega -- a linear parameter must be declared (1 x T)`, re-measured here as row **P**), but decision 10 does not build a porttype, and on the shape it does build the same declaration **compiles** (row **W**). Shipping the old row would have pinned a refusal the tree does not make — the E161 G0 defect in its purest form, a gate that cannot fail. |
| G7 | **Non-regression:** Phases 1 and 3–11 are untouched and the suite is still **exit 0**, with the assertion count rising, never falling | **rank 4, labelled** — `pv-derived "regression net"`; permitted at `testing-floors.md:174-177` precisely because it is labelled and is not a correctness claim | Revert Step 5's `compile-main` rewrite while keeping Step 4's `test-main`, **and rebuild `scaffold/build/test-runner`** ⇒ Phase 2 must fail on the missing entry symbol, proving Phase 2 really executes the adopted path. ⛑ **Without the rebuild this mutant could not fail** — measured at the SPEC audit: `run-native.sh:94-105` runs a prebuilt, untracked binary (`git ls-files scaffold/build/test-runner` empty) that no phase in the suite rebuilds, so the reverted source is invisible and Phase 2 stays green. The rebuild is added to Phase 2 in Step 5 for exactly this reason; the mutant is the check that it took. |
| G8 | ⚖ **New. Declaration hygiene, mechanically: every occurrence of `Oracle` or `Builder` in a `def`/`data` signature inside `scaffold/lib/test-floor.chiral` is at `(1 x T)`, and `(builder …)` is constructed at exactly one site (`test-main`)** | **rank 4, labelled** — `pv-derived "declaration lint"`. It is a grep over our own source, so it is not a correctness claim, and `testing-floors.md:174-177` permits it precisely because it is labelled | Retype any one `(1 o Oracle)` parameter to `Oracle` ⇒ the row goes RED. **And the row exists because nothing else catches that**: row **W** measured that a `data` wrapper at ω compiles and its contents are duplicated, where a porttype would be refused (row **P**). ⚑ **Named at its honest rung, per P5** (`PRINCIPLES.md:141-144`): this is *detection*, not prevention — a grep, not a type. Decision 10 takes the gap on purpose rather than growing the sysface to close it, and §6 records it as residue with no owner rather than deferring it to a phantom element. |

- **Green line:** **11 phases / 163 assertions / 82 roots / exit 0** (measured
  2026-08-25 at `6acbf9a`, cited not re-measured; ⚖ *and still current — `git log
  6acbf9a..2c3ca84 -- scaffold/` is empty, so nothing since that run touched a
  tested byte*) → **12 phases / 172 assertions / 82 roots / exit 0** (⚖ *the
  derivation below stands as the SPEC's; the LIVE suite is **175** at `f9441e4`,
  the three extra rows being G9's two swap refusals and G10's fail-open row,
  added after this SPEC's table by E168's own follow-on fixes*).
  ⛑ **The right-hand figures were re-derived at the SPEC audit, replacing an
  unsourced "≥ 175 / ≥ 86" — the defect E166's SPEC shipped once already.** ⚖ They
  are re-derived **again** here, from the fixture list Step 6 now carries rather
  than adjusted to fit: restoring `Builder` and retiring the porttype refusal
  changed which fixtures exist, so the number had to move. **The `≥` is gone
  too** — an unsourced `≥` was caught twice in this repo, and it is not a bound
  the SPEC can state without naming the rows behind it.
  - **Roots stay 82.** Phase 7's sweep is `grep -rl '^(def compile-main'` over
    `scaffold/lib TUI agent scaffold/samples` (`run-native.sh:166-167`) — it does
    **not** cover `scaffold/tests/samples/`, where Step 6 puts the fixtures.
    ⚖ Re-measured at `2c3ca84` (`grep -rl … | drop symlinks | sort | wc -l`):
    that sweep yields **94** paths, of which **0** are under
    `scaffold/tests/samples/`, and 94 = 82 compiled + 6 `*_reject_*` + 6
    `KNOWN_FAIL`. **Eight** new fixtures there move the roots count by **zero**,
    including the three `_reject_` ones — a directory the sweep never enters
    cannot contribute skips either. (Step 6 follows `e166_ddc_legc.chiral`, which
    lives in `scaffold/tests/samples/` and is run by its own phase, not by the
    roots sweep.)
  - ⚖ **Assertions 163 → 172, one `ok` per fixture, derived from Step 6's list
    and nothing else.** A phase script emits one `ok` line per assertion
    (`test-e156-dedup.sh` is the pattern, ⛑ **14** of them — *re-measured at the
    re-audit, `bash scaffold/tests/test-e156-dedup.sh` printing `sort adoption
    (E156): 14 passed, 0 failed`; the SPEC said 18*), so the count is the
    fixture count:
    | Fixture | Asserts |
    |---|---|
    | `e168_mut_survived` | exit code ⇒ `g-inadequate` before any check |
    | `e168_mut_identical` | exit code ⇒ `mu-survived` |
    | `e168_rank_floor` | exit code over its three internal cases |
    | `e168_common_mode` | exit code ⇒ refused unasked, both dropped |
    | `e168_cap_thread` | exit code ⇒ the positive control compiles and runs |
    | `e168_reject_nocap` | exit 1 **and** `load: type mismatch` |
    | `e168_reject_cap_drop` | exit 1 **and** `load: linear binder usage mismatch` |
    | `e168_reject_port_twice` | exit 1 **and** `load: linear binder usage mismatch` |
    | G8's declaration lint | every `Oracle`/`Builder` signature at `(1 x T)`, one `(builder …)` site |
    Nine rows: **163 + 9 = 172.** The previous derivation was 6 (four fixtures +
    a two-row refusal pair); the pair is retired with G6 and five rows replace
    it — the positive control, three refusals, and G8. Any figure other than 172
    must change this table first.
  - ⚑ **A fixture with more than one internal case still counts once.**
    `e168_rank_floor` checks three (differential-only ⇒ `g-inadequate`; plus a
    `pv-fixed` check ⇒ `g-green`; plus a `pv-meaning` check ⇒ `g-green`) and
    reports one exit code, exactly as `e166_ddc_legc.chiral` folds 34 cases into
    one. Counting its cases as assertions is how an inflated figure gets built,
    so it is named here and refused.
  - Phase 2 contributes **0** assertions to either total — it reports an exit
    code, not `ok` lines (`run-native.sh:98-101`) — so re-expressing its six
    samples moves no count, as stated, and G1's evidence is Phase 2's exit code
    plus the Step 5 rebuild.
  - `ledger-lint` clean A–R.
- ⚖ **MEASURED 2026-08-25, at commit `4320470`:** `ulimit -s unlimited; time bash
  scaffold/tests/run-native.sh` -> **12 phases, 172 assertions, 82 roots, exit 0,
  zero FAIL lines, 3m44.647s.** ⚖ **RE-MEASURED at `f9441e4`, same command:**
  **12 phases, 175 assertions, 82 roots, exit 0, zero FAIL lines, 4m10.591s**,
  C leg on `/opt/compcert/bin/ccomp`, Phase 12 reporting `12 passed, 0 failed`. The derived right-hand figure was hit exactly,
  which is what deriving it from the fixture table rather than adjusting it to fit
  is for. Phase 7 reports `downstream roots: 82 compiled, 0 failed, 12
  known/negative, 0 newly passing`, so the eight fixtures moved the roots count by
  zero as §5 predicted. `ledger-lint` clean A–R.
- **Done when:** `scaffold/lib/test-floor.chiral` exists, `test-runner.chiral`
  returns a `Suite` through it **and Phase 2 rebuilds it from source**, and
  G2/G3/G4 are RED on the floor while the full native suite is exit 0 — i.e. the
  three recorded could-not-fail shapes now do (⛑ *not "three gates that could
  not fail" — see the Golden-behavior note above; none of them shipped*). ⛑ **Every mutant in the table above
  must be RUN and its measured result recorded before this element is called
  done** (`testing-floors.md:183-187`); the SPEC audit found three that could not
  be run as written (G1, G2, G7) and one that could not fire (G4's second), which
  is exactly the class this element exists to end. ⚖ This revision changed G5,
  retired and replaced G6, and added G8, so those three carry the same
  obligation and their mutants were checked for runnability here rather than
  assumed: G5's three mutants are rows **L1/L2/L3** plus the discarded-cap case;
  G6's single mutant (delete `observe`'s cap parameter) turns row **N** into row
  **K**'s outcome, i.e. it compiles, which is a change the fixture can see (⛑
  *this prediction was checked for runnability, not run, and it is WRONG — see
  the measured account in G6's mutant cell above: the fixture is still refused,
  with `load: field binder usage mismatch`. The row fires; the prediction did
  not hold*); G8's mutant is a one-character retype that its grep reports. **The one that could
  NOT fire is why G6 was retired**: on the built shape the old row's subject
  compiles (row **W**), so its mutant would have reported the same verdict either
  way — the exact defect class, caught before shipping this time.

## 6. Residue & links

- **Deliberately unbuilt:**
  - **The corpus migration** — 335 differentials re-founded, 68 B1-driven ported,
    306 python-checker-only rewritten. Home: **E170**, minted in this change
    (catalog + ledger). This SPEC's size discipline is the whole reason the split
    exists: the floor is ~260 L of library plus one adopter, and speccing the
    migration inside it would bury the design content under 709 transcriptions.
  - **Re-expressing Phases 1 and 3–11**, including E166's C-leg gate. Home:
    **E170**. The example's conformance target 3 — *the C leg still convicts
    byte-identically when its `Oracle` is passed as `(or-gcc …)` / `(or-ccomp …)`
    rather than wired in* — is the first item of E170's differential leg, not a
    row in §5 above; §5's G7 keeps Phase 10 as an untouched non-regression row.
  - **A `Console` cap.** Home: **E80** (`LEDGER.md:233`, `design`). Not deferred
    *to* — the floor is complete without it (decision 5, which stands).
  - ⚖ **A `Builder` cap — no longer residue at all: E168 mints and owns it**
    (decision 4, author's call 2026-08-25). It could not be deferred: E80's cap
    set is enumerated *Console/Clock/Timer/Env/NetCap*
    (`SELF-IMPLEMENT-CATALOG.md:128`, verified live) and build/exec is not in it,
    so **no element owned a `Builder`** and naming one would have been a phantom
    dep. When E80 lands, `Builder` joins the granted set and `test-main`'s mint
    site becomes a parameter — a signature change at one call site, which is why
    minting it here costs E80 nothing.
  - ⚖ **What `Builder` does NOT close, kept as residue rather than implied shut:
    forgery.** Row **K** — a `->` def mints a cap and calls the cap-taking
    observer; compiles, runs, exit 7. Prevention is **E171**'s (a `->` body must
    not transitively reach a crossing — `SELF-IMPLEMENT-CATALOG.md:436`,
    `LEDGER.md:103`, `design`) or **E80**'s (the ambient externs go away).
    ⚑ Both are minted and **nothing in E168 is deferred to either** — E168 ships
    complete with detection, and the honest downgrade is stated in §1 and in
    decision 4 rather than left for a reader to discover.
  - ⚖ **The ω-declaration gap on a `data`-shaped linear wrapper. Home: nobody's,
    and deliberately not minted.** A porttype parameter at ω is refused (row
    **P**); a `data` wrapper carrying a q1 handle at ω is **not** (row **W**), so
    `(1 o Oracle)` / `(1 bld Builder)` is a declaration the author writes and the
    checker does not demand. E168 floors this on purpose (`PRINCIPLES.md:175-177`:
    *"where finite resources force a lower rung, the shortfall is a visible fact
    in the type, not a silent hole"*) with **G8**, a grep, labelled `pv-derived` because a
    grep is detection and not proof. It is **not** minted as an element: nothing
    in E168 waits on it, and per the deferral rule an unowned gap is recorded as
    unowned rather than parked on an E# that does not exist. A future element
    that wants it would be *"a data type with a linear field is classified
    linear"* — E159's own class, one level out — and this paragraph is the note
    it would start from.
  - **Import resolution / the ~35% fork cost.** Home: **nobody's yet**, and
    deliberately not minted — nothing here waits on it (decision 2).
  - **Test discovery (getdents), parallelism, timing, report formats.** Tracked
    in the native-harness work, not here.
- **Follow-on:** **E170** — *the corpus lands on the floor*. Minted with this
  SPEC so the deferrals above name a real home rather than a phantom.
- **Related:** [[E168-test-floor]] · [[testing-floors]] · [[pattern-boundary-sums]]
  · [[E166-mach-c]] · [[verification]] · [[elements/catalog]]
