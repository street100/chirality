---
element: E123
slug: native-porttype-carrier
title: "Native word-carrier for handle porttypes — give the fd/handle porttypes a runtime carrier so a porttype-carrying crossing lowers to native"
kind: BUILD-PROPER
example: examples/E123-native-porttype-carrier.md
status: audited
updated: 2026-08-12
---

# E123 SPEC — Native word-carrier for handle porttypes

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `term->ntalty` (`compile-front.chiral:30`) assigns the
  six single-word handle porttypes — `Sock`, `LSock`, `Fd`, `Clock`, `Timer`,
  `Env` — a runtime carrier (`nt-i64`) at the front peel, so a def whose
  argument, return, or data-field is one of them PEELS and emits an entry label
  instead of being silently dropped. A crossing on a porttype value (e.g.
  `close`/`sock-close`/`fd-close`, already routed in `crossing-wraps.chiral`)
  now lowers to native machine code on the erased fd, with the checker's
  linearity intact (it was discharged before erasure).
- **Non-goals:** no new crossing wrappers (E51/E107 own those); no `Pool n`
  carrier (indexed, cell-shaped — E120/E122); no real fd wired end-to-end
  beyond the isolation sample; no change to `tal-ssa`/reg-alloc/preserve-check/
  `tal-erase`/`compile-back`/emit (a word-carried porttype is an ordinary
  register — verified below).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E123 postdates the CONFORMANCE-MAP
  snapshot (bundle §3: "treat as BUILD"). This is a BUILD-PROPER element with
  no prior map row to extend.
- **Live code this composes with (do NOT respec):**
  - `compile-front.chiral:30-39` `term->ntalty` — the front peel. Its
    `t-primty` case maps only `I64`/`Str`/`Bytes`; every other primty (i.e.
    every nullary porttype) falls to `(none)` = "stays upper" → `peel-def`
    (161) drops the def → no entry label. **This is the single gate.**
  - `compile-back.chiral:24-28` `ntalty->talty` — already maps `nt-i64 → tt-i64`
    totally (verified in the example-audit), so NO downstream ripple once a
    porttype is `nt-i64`.
  - `ports.chiral` — the six porttypes are declared: `Sock`/`LSock`/`Fd` (12-14),
    `Clock`/`Timer`/`Env` (99-101), each a nullary `(porttype X)` = opaque
    linear atom = `t-primty "X"` at load. Result sums with porttype fields:
    `RecvR`/`AccR`/`ConnR`/`SendR`/`SendFdR` (Sock/LSock/Fd), `TimeR`/`SleepR`/
    `EnvR` (Clock/Timer/Env). Their fields erase through the SAME
    `term->ntalty`, so this one change fixes them too.
  - `crossing-wraps.chiral` — already routes `sock-close`/`lsock-close`/
    `fd-close` → `nb-sys-close` and `close` → `nb-sys-close`. The wrapper table
    is NOT the blocker; the dropped carrier is.
  - `lower.chiral:26,37-50` `UT`/`ttype` — the legacy E16 differential twin of the
    same `t-primty→carrier` map (`u-prim` → I64/Str/Bytes-else-none). Dead in
    the live `compile-all` path (see decision #4).
- **True delta:** one mapping (six atom names → `nt-i64`) added to one pure
  function in one file. Everything else already exists.

## 3. Decisions

Every open question from example §6, dispositioned. No silent design calls.

| # | Question | Disposition | Rationale / citation |
|---|----------|-------------|----------------------|
| 1 | Carrier declaration site: inline name-list in `term->ntalty`, or a per-porttype registry in `ports.chiral` consulted like `latoms`? | **RESOLVED → INLINE** for E123; registry **DEFERRED** (residue §6) | All six in-scope porttypes map to the SAME carrier (`nt-i64`), so an inline membership list is NOT a which-of-N sentinel — it is one predicate "these atoms are word-carried," which is boundary-sums-clean (`docs/pattern-boundary-sums.md`: parse the classification once as a value; a single closed set is not a scattered string chain). A declared `(porttype-carrier Sock word)` registry built like `latoms` (`kernel.chiral`) is the extensible refinement for the day a non-word carrier lands, but it adds a loader field — same deferral posture as `Pool`. |
| 2 | `Clock`/`Timer`/`Env` carriers: genuinely one word, or need a cell? | **RESOLVED → all three IN scope as `nt-i64`** (single word) | Each is a nullary `(porttype X)` (`ports.chiral:99-101`) whose threaded value is a single-word handle: `Clock` = a monotonic clockid/anchor token (`time-mono` reads it, `ports.chiral:114`); `Timer` = a deadline/timer token (`sleep-ms`, 115); `Env` = a pointer/slot handle into the environ view (`env-view` keys into it, `env-open : Unit→Env`, 116-121). None carries multi-word payload in the *cap value* — the data they view lives behind the handle. NB (not over-claiming): none of `time-mono`/`sleep-ms`/`env-view`/`env-open`/`env-close` has a `crossing-wraps` row yet, so mapping them yields NO lowering payoff today — it keeps the carrier map complete/boundary-clean for when their E51 wrappers land. The load-bearing unblock is `Sock`/`LSock`/`Fd`. |
| 3 | `Pool n` in scope, or deferred? | **DEFERRED → E120/E122** | `Pool` is an *indexed* porttype (`ports.chiral:19` `(porttype Pool (n I64))`); its surface indexed form is DEFERRED in the parser (`parse.chiral:39`), it hits the `t-tcon` branch (→ `nt-data "Pool"`, wrong carrier), and E122's carrier is the `[base|size]` cell (`nt-bytes`-like), NOT a word. Out of scope confirmed; kept in the `car-cell` residue note only. |
| 4 | `lower.chiral` `ttype`/`u-prim` twin: dead, or mirror the map? | **RESOLVED → dead in the live `compile-all` path** (example-audit); confirm-or-XS-mirror step in §4 | `lower.chiral`'s `UT`/`ttype` (26,37-50) is the legacy E16 differential slice, not on the live `compile-front → compile-back` peel path that E123 changes. The change is load-bearing ONLY in `term->ntalty`. §4 Step 2 grep-confirms no live porttype flows through `UT`; if (unexpectedly) one does, mirror the same six-name→`tt-i64` map there — XS, non-load-bearing. |
| 5 | Preserve-check: does `tal-check` see a consistent `tt-i64` end-to-end? | **RESOLVED → no change; named in the gate** | The carrier is assigned at the front peel, BEFORE `compile-fn`/SSA/`tal-erase`, so `tal-check` only ever sees `tt-i64` for a porttype register — the same word type an `I64` fd already uses. No preserve-check change anticipated; §5 asserts the isolation sample type-checks clean as the observable proof. |

No NEEDS-AUTHOR items; `status: draft` (unblocked).

## 4. Change plan (ordered, commit-sized)

### Step 1 — word-carrier map in the front peel  *(the whole functional change)*
- **Target:** `scaffold/lib/compile-front.chiral` — `term->ntalty` (30-39),
  `t-primty` case.
- **Change:** after the `I64`/`Str`/`Bytes` ladder, add a porttype-carrier
  fallthrough. Add a leaf helper `porttype-word? : Str → Bool` (or a `Carrier`
  sum + membership per boundary-sums) holding the closed set
  `{"Sock","LSock","Fd","Clock","Timer","Env"}`; on a hit, yield
  `(some (nt-i64))` (erase to the one-word carrier); on a miss keep `(none)`.
  Adapts the example §5 snippet — but ship the S form (single membership
  predicate → `nt-i64`), not the full `Carrier` sum, since every in-scope atom
  shares one carrier (decision #1). `Pool` stays on the `t-tcon` path,
  untouched.
- **Size:** ~S (~8-12 lines, one pure function, one file).

### Step 2 — confirm the `lower.chiral` twin is dead  *(safety, likely no-op)*
- **Target:** `scaffold/lib/lower.chiral` — `ttype`/`UT` (26,37-50).
- **Change:** grep-confirm the live `compile-all` path does not route a
  porttype through `UT` (decision #4). If confirmed dead → NO code change (a
  comment-only or zero commit). Only if a live porttype flow is found: mirror
  the same six-name → `tt-i64` map in `u-prim`. Non-load-bearing.
- **Size:** ~XS (confirm; mirror only-if).

### Step 3 — isolation conformance sample + reblob self-host check
- **Target:** `scaffold/tests/` (new sample, per §5) + the reblob/`cmp` gate.
- **Change:** add the porttype-crossing isolation sample (below) and wire its
  native run; run the self-hosting reblob-`cmp` since `compile-front.chiral` is
  blob-resident.
- **Size:** ~S.

**Commit count: 2** (Step 1 carrier map; Step 3 sample+gate), **+1 conditional**
(Step 2 mirror only if a live `UT` porttype flow surfaces — not expected).

## 5. Conformance gate

- **Golden behavior:** a def taking/returning a value typed as a handle
  porttype emits an entry label and lowers to a native ELF whose crossing runs
  on the erased fd — the same exit behavior the raw-`I64` control (E106 exit-42)
  produces, now with linearity intact.
- **Isolation (must NOT depend on E107's held-uncommitted rows):** reuse the
  isolation the E107 implement agent used — a live fd (from `open-rw`) threaded
  as a porttype-typed linear value and handed to an ALREADY-LOWERING crossing,
  `close` (present in `crossing-wraps.chiral`), with `main` returning **exit 42**.
  This exercises E123's carrier peel WITHOUT touching E107's uncommitted
  `sock-close`/`fd-close`/`lsock-close` wrapper rows.
  - **Before E123:** the porttype-typed def drops → no entry label → build
    fails (`compile-emit.chiral:192` `no emitted label for entry`).
  - **After E123:** the def peels, the crossing lowers, the ELF runs → exit 42.
- **Tests to add:** one native-floor sample under `scaffold/tests/` (shape of
  `test_e106_linear_cap.py` / `test_compile_run_chirality.py`): compile the
  isolation program with B1, run the ELF, assert exit 42. Differential leg:
  the compiled crossing image is `nb-sys-close` on the erased word (same as the
  raw-fd control).
- **Self-hosting gate:** `compile-front.chiral` is blob-resident → after the
  change, reblob and run the promoted binary over the blob once more, `cmp`
  byte-identical (B1-compiling-B1 fixpoint), per the BUILD RULE.
- **Green line:** 704 test functions → ≥ 705 (the isolation sample); the native
  floor + the isolation sample are the judges, NOT the stale green count.
  ledger-lint clean.
- **Downstream note (NOT this gate):** the **E106 native `sv-drain` milestone**
  is the real payoff once E107's fd-close rows are committed ON TOP of E123 —
  but that is E107's conformance gate. E123 stands alone on the isolation
  sample + the native floor.
- **Done when:** the isolation program compiles under B1, its ELF exits 42
  (was: no-emitted-label build failure), and the reblob `cmp` is byte-identical.

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - **Per-porttype carrier registry in `ports.chiral`** (`(porttype-carrier X
    word)` consulted like `latoms`, extensible to non-word carriers) — DEFERRED
    (decision #1); revisit when the first non-word carrier (Pool) needs a
    declared home. Inline predicate suffices for the six same-carrier atoms.
  - **`Pool n` cell carrier** (`car-cell` / `[base|size]`, the `t-tcon` path) —
    E120/E122 (decision #3); the parser's deferred indexed-porttype surface
    form (`parse.chiral:39`) rides with it.
  - **Crossing wrappers for `time-mono`/`sleep-ms`/`env-view`/`env-open`/
    `env-close`** — absent from `crossing-wraps.chiral`; E51/E32 own them. Until
    they land, `Clock`/`Timer`/`Env` carry a word but no crossing lowers
    (decision #2, not over-claimed).
- **Follow-on this unblocks:** E107 (native fd-close crossings, committed on top
  of E123), E106 (native `sv-drain` milestone).
- **Related:** [[E123-native-porttype-carrier]] · [[E107-cap-close]] ·
  [[E106-linear-caps-utf8]] · [[E120-pool]] · [[E122-pool-native]] ·
  [[E70-crossing-wraps]] · [[E51-syscall-wrappers]] · [[E32-time-caps]] ·
  `docs/pattern-boundary-sums.md`
