---
element: E32
slug: clock-exit-env
title: `clock_gettime` (`time-mono`), `exit`, `env` access
kind: REPLACE-CRUTCH
example: examples/E32-clock-exit-env.md
status: audited
updated: 2026-07-27
---

# E32 SPEC — `clock_gettime` (`time-mono`), `exit`, `env` access

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** the time and process-exit crossings (`time-mono`,
  `sleep-ms`, `exit`) and the `env-get` view are moved off CPython's
  `time`/`sys`/`os` onto the sys-tal floor — three new hand-tal crossings
  (`nb-sys-clock-gettime` 228, `nb-sys-nanosleep` 35, `nb-sys-exit-group` 231)
  plus reified `Clock`/`Timer`/`Env` capability porttypes and `TimeR`/`SleepR`/`EnvR`
  result sums that replace the ambient `time-mono`/`sleep-ms`/`env-get`
  externs, all differentially agreeing with the crutch across the three floors.
- **Non-goals:** the wall clock (`CLOCK_REALTIME` — B-untrusted time, owned by
  the freshness-verify design, not here); env *iteration* (only keyed lookup is
  faced); env *mutation* (no `env-set` — the view is read-only by type; a
  mutable env would be a newly-decided crossing); the never-return floor
  semantics of `exit` (E26's `Never`); the actual envp-walk body (depends on
  E34's psABI entry protocol — see §3 #6, §4 Step 6). Residue in §6.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** the single row naming E32 is the P3 Category-C
  port-membrane row — **CONFORMS** (`E30,E31,E32,E33`, tier S): "Crossing SHAPE
  conforms to P3. Transport swap is E51 lane, not a reshape." So E32 is **not**
  a reshape of the membrane; it authors three more crossings *inside* the
  already-conformant shape and reifies two ambient externs into capabilities.
  No BUILD/REFACTOR verdict is outstanding against it.
- **Live code this composes with (do NOT respec):**
  - `scaffold/lib/sys-tal.chiral` — the hand-tal crossing floor: 7 crossings
    already built (`nb-sys-write`/`read`/`lseek`/`memfd`/`ftruncate`/`mmap`/
    `munmap`), each `(tfn "name" arity slots (body))` over the `tal-ir` ops
    `ti-sys`/`ti-bptr`/`ti-blen`/`ti-bnew`/`ti-const`/`ti-prim`/`ti-case`/
    `ti-call`; aggregated in `sys-lib`. `ti-sys dst nr (arglist)` **is** the
    membrane primitive (`emit-core.chiral` maps it to `(mach-sys m)`). The
    out-param + write-then-read-one-cell discipline is already live in
    `nb-sys-read` (`ti-bnew`→`ti-bptr`→`ti-sys`→read back) and the E21 arena
    roundtrip.
  - `scaffold/lib/ports.chiral` — the typed face: the ambient externs to be
    replaced sit at lines 73–75 (`env-get`/`time-mono`/`sleep-ms`) and 80–81
    (`exit`/`halt`); the reification pattern (opaque linear `porttype` +
    result-`data` sum) is already exercised by `Sock`/`LSock`/`Fd`/`Pool` and
    `RecvR`/`AccR`/`PoolR`.
  - The I64-only seam, byte cells (`bnew`/`bptr`/`blen`), result sums, Euclidean
    `/`·`%`, and the totality checker are all built (memory index).
- **True delta:** (a) three `nb-sys-*` crossings + their `sys-lib` entry; (b) a
  little-endian `cell-i64` reader and an `ms↔timespec` cell builder (bytes-tal
  idiom — **no `cell-i64`/`bget64` exists today**, confirmed by grep); (c) the
  `Clock`/`Timer`/`Env` porttypes, `TimeR`/`SleepR`/`EnvR` sums, and typed
  `time-mono`/`sleep-ms`/`env-get` declarations replacing the three ambient
  externs; (d) the bridge bodies wiring caps→crossings→result sums; (e) E51
  binding-table rows + `impl_ports` host referents for the differential.
  `exit`/`halt` are **untouched** (E26 territory).

## 3. Decisions

Every open question from example §6, dispositioned. RESOLVED only where a
settled doc/precedent decides it; genuinely novel design is surfaced as
NEEDS-AUTHOR, never answered silently.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Is `env-get` a **row entry** (a crossing) even though no syscall occurs? | **DEFERRED → E39** | The example's working answer — "a crossing is an *observation or mutation of the world*, not a syscall; env-get is in the row" — is carried as the provisional stance, but the *row representation* is E39's design (feeds E39's row-representation work per example §6). This element ships the typed face; E39 ratifies whether the reified `Env` view sits in the effect row. Transparently open in the example. |
| 2 | The never-return floor semantics of `exit` / where `Exit` sits vs `halt` / `Never` | **DEFERRED → E26** | `exit`/`halt` keep their existing polymorphic `(-> (0 A (type 0)) (=> I64 A))` surface (unchanged this run); `nb-sys-exit-group` (231) is authored as a crossing whose tal body has no reachable `t-ret`, but the 0-ctor-data-vs-first-class-bottom decision and `Exit`-granted-to-`main` are E26's (`[[E26-alarm-control-flow]]`). Transparently open in the example. |
| 3 | Does `cell-i64` earn a floor instruction (`bget64`) or stay a library loop? | **RESOLVED — library loop** | Principle "compose, don't reinvent": `nb-sys-read` already calls a hand-tal helper (`nb-copy`) via `ti-call` rather than a bespoke instruction; the 8-byte LE assembly is the same tier. Ship `cell-i64` as a bytes-tal library def; a `bget64` floor instruction is a later *optimization*, not a correctness need (residue §6). Reversible engineering default, no design commitment. |
| 4 | `Clock` covers both read+sleep, or split into `Clock`/`Timer` (one cap per crossing family vs per crossing) | **RESOLVED (author, 2026-07-27) → split `Clock`/`Timer`** | Grounded in `docs/time-and-clocks.md`, which exists to un-blur time into three senses the two crossings straddle: `time-mono` reads the **trusted anchor** (the register-root-derived integrity reference told-time is checked against — evidence infrastructure), while `sleep-ms` is **time-you-must-act-by** territory (deadlines, runtime-scheduled, expected to dissolve into counter-effect machinery). One cap would re-fuse the senses at the capability layer. And a later split would not be free: caps attenuate by subtyping over refinement/value-index (`docs/banks/capability.md`), and an opaque unitary `Clock` atom has no structure to attenuate over. `Clock` gates `time-mono`; `Timer` gates `sleep-ms`. The example's §5 single-cap fleshed form is superseded on this point. |
| 5 | errno-sum granularity (`time-err`/`sleep-err` carrying a raw `errno I64` vs a classified sum) | **DEFERRED → E51** | Shared open question of the sys-linkage lane (`[[E51-sys-linkage]]`); this element carries the raw `errno I64` constructor the example uses, and adopts E51's classification when it lands. |
| 6 | Where does `env-get` read envp from? | **DEFERRED → E34 (dependency)** | The typed face + `EnvR` sum land now, but the body that *walks the exec-time envp block* depends on E34's psABI entry protocol (argc/argv/envp above initial rsp). Until E34 lands, `env-get`'s differential binds to the `impl_ports` host referent (`os.environ`) only; the native envp-walk follows E34. Called out in §4 Step 6 and §5. |

No decision blocks the change plan (#4 resolved by the author 2026-07-27; #6
scopes env-get's native body to a follow-on).

## 4. Change plan (ordered, commit-sized)

### Step 1 — three sys-tal crossings
- **Target:** `scaffold/lib/sys-tal.chiral` — new `nb-sys-clock-gettime`,
  `nb-sys-nanosleep`, `nb-sys-exit-group`; extend `sys-lib`.
- **Change:** author each as `(tfn "name" arity slots (body))` against
  `refs/ref-clock.md`'s register table, mirroring `nb-sys-read`'s
  `ti-bptr`→`ti-sys` shape:
  - `nb-sys-clock-gettime` — arg0 = clockid I64, arg1 = timespec cell.
    `ti-bptr` the cell → rsi; clockid → rdi; `ti-sys dst 228 (rdi,rsi)`;
    `t-ret` the raw kernel return (0 or -errno). Cell is caller-allocated
    (`bnew 16`), kernel is just another writer (len word stays chirality's — memfd
    precedent).
  - `nb-sys-nanosleep` — arg0 = req cell, arg1 = rem cell. `ti-bptr` both →
    rdi/rsi; `ti-sys dst 35 (rdi,rsi)`; `t-ret` raw return (0, or -EINTR with
    rem holding the remainder). **No retry loop** — the ret is returned as-is.
  - `nb-sys-exit-group` — arg0 = status I64 → rdi; `ti-sys dst 231 (rdi)`;
    body has no reachable `t-ret` (never returns; floor treatment is E26's —
    emit the syscall then an unreachable trap/`t-ret` sentinel matching how the
    existing `exit` extern lowers).
  - Add all three to the `sys-lib` `cons` chain.
- **Size:** ~M.

### Step 2 — cell↔i64 marshalling helpers (bytes-tal idiom)
- **Target:** `scaffold/lib/bytes-tal.chiral` — the existing bytes-tal lib where
  `nb-copy` lives (sys-tal imports only `prelude`/`tal-ir`; `ti-call` resolves
  helpers by name at the tal tier, no import needed, exactly as `nb-sys-read`
  reaches `nb-copy` today) —
  new `cell-i64` (read 8 LE bytes at offset → I64) and `cell-put-i64`
  (write an I64 as 8 LE bytes at offset), plus `ms->timespec` /
  `timespec->ms` built on them and the Euclidean math from `ref-clock.md`
  (`tv_sec=ms/1000`, `tv_nsec=(ms%1000)*1000000`; `ms=tv_sec*1000+tv_nsec/1e6`).
- **Change:** hand-tal byte-assembly (8 `bget`+shift per word / 8 `bput`),
  reachable via `ti-call` as `nb-copy` is. Per decision #3 — no new floor
  instruction.
- **Size:** ~M.

### Step 3 — reified caps + result sums
- **Target:** `scaffold/lib/ports.chiral` — add `(porttype Clock)`,
  `(porttype Timer)`, `(porttype Env)`; add `TimeR` (`time-r (ms I64)` / `time-err (errno I64)`),
  `SleepR` (`slept` / `interrupted (remaining-ms I64)` / `sleep-err (errno I64)`),
  `EnvR` (`env-r (v Str)` / `env-none`) — each constructor threading its cap
  linearly (`(1 c Clock)` / `(1 t Timer)` / `(1 e Env)`) per example §5,
  amended by decision #4 (split).
- **Change:** insert alongside the existing `Sock`/`RecvR` block.
- **Size:** ~S.

### Step 4 — typed faces replace ambient externs
- **Target:** `scaffold/lib/ports.chiral` lines 73–75.
- **Change:** replace the three ambient externs with cap-gated declarations:
  `time-mono (=> (1 c Clock) TimeR)`, `sleep-ms (=> (1 t Timer) I64 SleepR)`,
  `env-get (=> (1 e Env) Str EnvR)`. `exit`/`halt` (80–81) untouched (decision
  #2). Split `Clock`/`Timer` caps per decision #4.
- **Size:** ~S.

### Step 5 — bridge bodies
- **Target:** `scaffold/lib/ports.chiral` (or a small sys-face lib it imports) —
  `wrap-time-mono` / `wrap-sleep-ms` binding the typed faces to the Step-1
  crossings via the Step-2 helpers, per example §5: alloc cell → cross → on
  `<i ret 0` return `*-err (- 0 ret)`, else read back and fold to ms /
  case on ret for `slept`/`interrupted`/`sleep-err`.
- **Change:** exact bodies from example §5 `wrap-time-mono` sketch, extended for
  `sleep-ms` (build req cell from ms; read rem only on -EINTR) — caps per
  decision #4: `wrap-sleep-ms` threads `Timer`, not the example's single `Clock`.
- **Size:** ~M.

### Step 6 — env-get body + E51 bindings + host referents
- **Target:** `scaffold/lib/ports.chiral` (env-get bridge), the E51 binding
  table, and `impl_ports.py`.
- **Change:** `env-get` bridge returns `env-r`/`env-none` (absence is a
  constructor, not `""`). **Native body walks the exec-time envp block —
  deferred to E34 (decision #6); until then bind env-get to `os.environ` in
  `impl_ports` for the differential.** Add E51 rows binding
  `time-mono`/`sleep-ms`/`env-get` to their referents (reference floor: real
  `clock_gettime`/`nanosleep`/`os.environ`; native: the `nb-sys-*` crossings).
- **Size:** ~M.

## 5. Conformance gate

- **Golden behavior:** differential vs the crutch across the three floors —
  `time-mono` within jitter of `time.monotonic_ns()//1e6` **and monotone across
  successive calls**; `sleep-ms n` sleeps ≥ n ms (modulo EINTR, now surfaced as
  `interrupted`); `exit n` yields process status n; `env-get k` byte-equal with
  `os.environ[k]` for present keys and `env-none` for absent ones.
- **Tests to add** (in `scaffold/tests/test_process_externs.py`):
  - `test_time_mono_monotone` — reference vs native floor: two reads, second ≥
    first, both within jitter of the host clock.
  - `test_sleep_ms_observable` — `sleep-ms n` elapses ≥ n ms measured on the
    host; EINTR path yields `interrupted` (not a hidden retry).
  - `test_exit_group_status` — spawned `exit n` process exits with status n.
  - `test_env_get_present_absent` — present key byte-equal `os.environ`; absent
    key ⇒ `env-none`.
  - `test_clock_gettime_out_param` — `nb-sys-clock-gettime` fills the 16-byte
    cell; `cell-i64` reads `tv_sec`@0/`tv_nsec`@8 back agreeing across floors.
- **Tests to update in place** (same file — Steps 4/6 invalidate three
  existing tests, which must be updated, not deleted):
  - `test_externs_are_declared_in_ports_chirality` asserts the exact string
    `(extern sleep-ms (=> I64 Unit))`, which Step 4 removes — update the
    assertion to the new cap-gated face.
  - `test_sleep_ms_blocks_at_least_the_interval` and
    `test_sleep_ms_nonpositive_returns_immediately` call
    `IMPL_PORTS["sleep-ms"]` at the shim and assert a `UNIT` return — update
    to the Step-6 binding shape (a `SleepR` value, not `UNIT`).
- **Green line:** 281 → ≥ 286 (5 new; the 3 updates are in place, count
  unchanged); `ledger-lint` clean.
- **Done when:** all five new tests pass and the three updated ones stay
  green, with reference and native floors agreeing
  by construction on the syscall paths, env-get agreeing via the host referent
  (native envp-walk pending E34), and the ambient `time-mono`/`sleep-ms`/
  `env-get` externs no longer present in `ports.chiral`.

## 6. Residue & links

- **Deliberately unbuilt:**
  - `bget64`/`bput64` floor instructions — `cell-i64` ships as a library loop
    (decision #3); the instruction is a later optimization (nobody's yet).
  - Native `env-get` envp-walk — depends on **E34** (psABI entry protocol);
    host-referent-bound until then (decision #6).
  - `exit`'s never-return floor semantics / `Never` / `Exit`-to-`main` — **E26**.
  - `env-get` as a ratified effect-row entry / row representation — **E39**.
  - errno-sum classification — **E51** (raw `errno I64` carried for now).
  - `CLOCK_REALTIME` wall clock (freshness-verify design) and env *iteration* /
    *mutation* — out of scope by §1.
- **Follow-on this unblocks:** E31 (poll — the out-param *array* shape reuses
  clock_gettime's out-param cell), E33 (process-spawn — never-return-in-child
  reuses exit_group).
- **Related:** [[E32-clock-exit-env]] · [[E51-sys-linkage]] · [[E26-alarm-control-flow]]
  · [[E34]] · [[E39]] · [[E31]] · [[E33-process-spawn]] · [[E21-arena]] ·
  [[time-and-clocks]] · [[banks/capability]] (decision #4's grounding) ·
  `examples/refs/ref-clock.md`.
