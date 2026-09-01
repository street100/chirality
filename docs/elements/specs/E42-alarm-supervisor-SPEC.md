---
element: E42
slug: alarm-supervisor
title: Runtime supervisor (critical sections, register-root custody, scheduler)
kind: BUILD-PROPER
example: examples/E42-alarm-supervisor.md
status: audited
updated: 2026-08-12
---

# E42 SPEC — Runtime supervisor (critical sections, register-root custody, scheduler)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** a new `scaffold/lib/supervisor.chiral` exists — the v1
  **supervised event loop + alarm-as-crossing core** on the coarse `=>` effect
  bit: `AlarmSet`/`Alarm`/`DueR` + `KontMsg` types, the pure alarm registry
  (`earliest`, `wait-ms`, `remove-rid`), the `notify`/`fire-earliest` alarm
  crossing (re-arm-forward-from-now on `k-resume`, synthesized cancel on
  `k-cancel`), and the supervised loop (`supervise-step`/`supervise`) that folds
  the nearest alarm deadline into `poll-fds`'s ms timeout and, per tick, EITHER
  fires the earliest alarm (`poll-timeout`) OR dispatches exactly one ready fd
  into `mux-step` (`poll-ready`) — threading the linear `SockVec` and `Clock`
  cap on every arm. First consumer: `TUI/mux` (per `TUI/mux/SCOPE.md`, currently
  `Blocked-on-core`). Ships with a compile+run conformance sample (exit 42).
- **Non-goals (full scope named, deferred — §6):** the **fully-typed alarm**
  (recoverable-vs-fatal as an E39-row TAG, counter-effect set beyond
  `k-resume`/`k-cancel`/`halt`) → **E26** (hard-gated on E39). The **rung-2
  halves** — critical sections (preemption-disabled windows), register-root
  custody (derive-not-store), interrupt→alarm translation, SMP decomposition —
  have **no rung-1 referent** (at rung 1 the supervisor is discipline on a Linux
  we do not control). Named, not built. Timer-precision upgrades (`timerfd`,
  `ppoll`) deferred (decision #1).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** E42 is **BUILD / L** on two rows (`Runtime
  supervisor as specified`, P2,P3 and P1,P3 — `CONFORMANCE-MAP.md:377–378`):
  "Distinct artifact… scheduler (seL4-shaped)… Not built; runtime.py is
  evaluator+linker, no crit-sections/GC-roots/scheduling." Reference class PAPER
  (seL4/microkernel). So this is a **forward BUILD of a new, separate artifact** —
  keep it distinct from E15 (`runtime.py`, the golden evaluator+linker, which the
  same map explicitly marks "NOT the E42 supervisor — keep distinct"). The v1
  slice builds the **scheduler + alarm-crossing shape** only; the map's
  crit-sections/register-root clauses are the rung-2 residue (§6).
- **Live code this composes with (name; do NOT respec):**
  - `scaffold/lib/poll.chiral` (E-poll) — `poll-fds : (=> (List I64) I64 PollR)`,
    a pure pollfd builder + ready-scanner around one `nb-poll` crossing, returning
    the boundary sum `PollR = poll-ready (List ReadyFd) | poll-timeout | poll-err
    errno` (`poll.chiral:11–14,68`). **This already implements the
    compute-deadline-into-poll's-ms-timeout mechanism** decision #1 resolves onto.
  - `scaffold/lib/ports.chiral` (E32) — the split time caps: `Clock` +
    `time-mono : (=> (1 c Clock) TimeR)` (monotonic ms, `ports.chiral:121,136`),
    `Timer` + `sleep-ms` (`:122,137`); `halt : (-> (0 A (type 0)) (=> Str A))`
    (`:150`) — the one realized counter-effect. `Sock`, `sock-recv/-send/-close`,
    `RecvR`.
  - `scaffold/lib/lincoll.chiral` (E106) — `SockVec` (move-only linear cap
    container, `:26`), `sv-detach-at : (-> (1 v SockVec) I64 DetachR)` (`:53`),
    `mux-step : (=> (1 v SockVec) (=> I64 SockVec))` ("concurrent progress,
    serial mutation" — only the serviced cap is mutated, `:80`).
  - The membrane: `->` vs `=>` is `CONFORMS` (E12, `CONFORMANCE-MAP.md:57`) — the
    coarse pure/process bit rides Pi pos-2 and is part of type identity. This is
    the bit the v1 supervisor types against.
  - `TUI/mux/SCOPE.md` — the concrete consumer, explicitly `Blocked-on-core` on
    "the E42 alarm-supervisor substrate (designed, unbuilt)".
- **True delta (deliverable minus baseline):** the **loop / scheduler** itself
  (`supervise`, `supervise-step`) + the **alarm registry & crossing**
  (`AlarmSet`/`Alarm`/`KontMsg`/`DueR`, `earliest`, `wait-ms`, `remove-rid`,
  `notify`, `fire-earliest`) + the fd→dispatch glue (`dispatch-one`). Everything
  the loop *stands on* — `poll-fds`, `time-mono`/`Clock`, `mux-step`/`SockVec`,
  `halt` — exists and is imported, not rebuilt.

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls:
RESOLVED only when derivable from a settled doc (cite it); genuinely novel
design goes to NEEDS-AUTHOR and is surfaced, never answered on the author's behalf.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Concrete timer mechanism: compute-nearest-deadline into `poll`'s ms timeout, vs `timerfd` per alarm, vs `ppoll` (ns + atomic sigmask)? | **RESOLVED → poll-timeout for v1** | `poll-fds` already implements the deadline-into-ms-timeout path (`poll.chiral:68`, `PollR = …poll-timeout…`) — zero new crossing, dependency-free, and `poll(2)` ms/`-1`/`0` semantics are web-verified (example §2, man7). `timerfd` (ns, `POLLIN`-readable, one fd/timer) and `ppoll` (ns + atomic sigmask) are named as **later precision upgrades, DEFERRED** — they buy sub-ms granularity the TUI/mux consumer does not need. v1 accepts ms granularity + a per-tick deadline recompute. |
| 2 | Effect-row dependency: build on the coarse `=>` bit now, or wait for the typed effect row (recoverable-vs-fatal in the type)? | **RESOLVED → coarse `=>` now; typed alarm DEFERRED to E26** | **Corrected build-state:** E39's effect-row CARRIER is already BUILT (steps 1–6, 2026-07-28 — Pi pos-2 `Seats(row,…)`, `subtype` VPi row-subsumption, `effects.py` set-containment, call-graph-inferred rows; `CONFORMANCE-MAP.md:58`). Only E39 Step-7 (Console reification, pending the E51-vs-Console author call) + the handler/subtraction machinery remain, and that machinery **rides E26** (`Alarms as a typed effect`, `BUILD`/unbuilt, **hard-gated on E39**, `CONFORMANCE-MAP.md:59`). So the coarse-`=>` supervised loop is buildable **now**; recoverable-vs-fatal-in-the-type gates on **E26, NOT the E39 row**. Recoverable-vs-fatal is meanwhile carried **structurally** by the constructor offering — `k-resume`+`k-cancel` = recoverable, `k-cancel` alone = fatal (`docs/banks/effect-and-alarm.md` Shard 5) — so v1 loses no expressiveness at the value level. Do NOT implement E26 here. |
| 3 | The rung-2 halves — critical sections, register-root custody, interrupt→alarm translation, SMP — at rung 1? | **DEFERRED — no rung-1 referent** | `RUNG-2-MAP.md` Cluster 1 ("seated, not scheduled"): these are **metal-only**. At rung 1 the supervisor is *discipline on a Linux we do not control* (C8) — there is no preemption to disable, no register root to custody, no interrupt vector to translate. Build the **shape** (the loop, the alarm crossing) now; never fake the metal enforcement. Homes: crit-sections/register-root → E42's own rung-2 mandate + E56 (custody bulk, `CONFORMANCE-MAP.md:375`); interrupt→alarm → no catalog element (consumes E39/E26); SMP → E42 rung-2 ("decomposition unspecified"). |
| 4 | `earliest` cost — O(n) linear-list scan per tick? | **RESOLVED → O(n) list for v1; heap = residue** | The `AlarmSet` linear list gives an O(n) `earliest`/`remove-rid` per tick. Acceptable at the TUI/mux resident count. A deadline-ordered heap (O(log n)) is the obvious upgrade if residents grow — recorded as §6 residue, not built now. |
| A | **Scope call (author-tier):** is the v1 supervisor lib in scope to build **now**, or should `TUI/mux` run on a bare `poll-timeout` loop inline until a real multi-session driver lands? | **RESOLVED → build `supervisor.chiral` now** (author, `TUI-PRIMITIVES.md` §Decisions row 3, 2026-08-12: "Build `supervisor.chiral` now. → Wave 3") | `TUI/mux/SCOPE.md` marks itself `Blocked-on-core` **on exactly this substrate**, and the §5 spine already compiles clean under B1 (29048-byte ELF), so the lib is buildable and unblocks a named consumer today. The extract-vs-inline taste call was the author's; it was made — **build the lib now**: the alarm-crossing shape is the load-bearing, reusable part (the rung-2 emulator is the second consumer already named in the example §1), and inlining it into `mux` would duplicate the membrane-typed crossing that is the whole point. |

Decision **#A** was the one scope/extraction call the author owned; it is now
**resolved (build the lib now)**, so no decision blocks §4. §4–§6 target the
`scaffold/lib/supervisor.chiral` home accordingly. No NEEDS-AUTHOR remains;
`status: draft` reflects only that spec-audit + implement are still ahead.

## 4. Change plan (ordered, commit-sized)

### Step 1 — Alarm registry types + pure spine
- **Target:** `scaffold/lib/supervisor.chiral` (new) — `KontMsg`, `Alarm`,
  `AlarmSet`, `DueR`; `earliest`, `wait-ms`, `remove-rid`.
- **Change:** the example §5 data decls verbatim (`KontMsg () (k-resume (rearm-ms
  I64)) (k-cancel)`; `Alarm`/`AlarmSet`/`DueR`). The three pure functions:
  `earliest : (-> AlarmSet DueR)` (structural min-scan), `wait-ms : (-> AlarmSet
  I64 I64)` (nearest-deadline `-` now, clamp `>=0`, `-1` when empty), `remove-rid
  : (-> AlarmSet I64 AlarmSet)`. All three must typecheck as **pure `->`** (the
  conformance gate checks the negatives). `(import "poll" "ports" "lincoll")`.
- **Size:** ~S

### Step 2 — The alarm crossing (`notify` / `fire-earliest`)
- **Target:** `scaffold/lib/supervisor.chiral` — `notify` extern, `fire-earliest`.
- **Change:** `(extern notify (=> I64 KontMsg))` — the coarse-`=>` handler port
  (decision #2; the E39 row-tag upgrade is E26). `fire-earliest : (=> AlarmSet
  I64 AlarmSet)` cases `notify`'s answer: `k-resume dt` → `as-cons (alarm (+ now
  dt) r) (remove-rid s r)` (re-arm **forward** from now); `k-cancel` → `remove-rid
  s r` (synthesized cancel). `due-none` → `s` unchanged.
- **Size:** ~S

### Step 3 — The supervised loop (thread `SockVec` + `Clock`)
- **Target:** `scaffold/lib/supervisor.chiral` — `Tick`, `supervise-step`,
  `dispatch-one`, `supervise`, + the elided glue `fd->index` / `held-fds`.
- **Change:** `supervise-step : (=> (1 caps SockVec) (List I64) AlarmSet (1 c
  Clock) Tick)` — read `time-mono c` (thread `Clock` back via `TimeR`), then
  `poll-fds fds (wait-ms s now)`: `poll-ready rs` → `dispatch-one` (service ONE),
  `poll-timeout` → `fire-earliest s now`, `poll-err`/`time-err` → tick unchanged
  (each arm its own supervisor alarm at rung 2). `dispatch-one : (=> (1 caps
  SockVec) (List ReadyFd) SockVec)` detaches the ready cap and calls `mux-step`.
  `supervise` recurses on the returned `Tick` (a **productive** process, not a
  terminating fn). **Invariant: the `SockVec` returns on EVERY arm** (lincoll
  linearity — no dropped cap). Implement the elided `fd->index`/`held-fds`
  mechanically (the example marks them skeletal).
- **Size:** ~M

### Step 4 — Conformance sample (compile + run, exit 42)
- **Target:** `TUI/samples/` (or `scaffold/tests/` sample) — a driver that
  registers a near-deadline alarm, runs the loop, and asserts the behavior.
- **Change:** see §5. A `compile-main (=> I64 I64)` entry exercising the loop end
  to end; exit 42 on success. Compiled with B1 and run — no fixpoint.
- **Size:** ~S

**Residue noted in-plan:** the O(n) `earliest`/`remove-rid` scan (→ heap, §6);
`notify` is a stub extern (→ E39 row-tag crossing, E26); `dispatch-one`'s
recv-route body is skeletal.

## 5. Conformance gate

- **Golden behavior (behavioral, compile+run, exit 42):** register an alarm with
  a **near deadline**, run the supervised loop, and confirm:
  1. **the alarm FIRES at/after the deadline** — the loop's `poll-fds fds
     (wait-ms s now)` returns `poll-timeout` when the nearest deadline is reached,
     and `fire-earliest` raises the crossing;
  2. **`k-resume`/`k-cancel` honored** — a `k-resume dt` handler re-arms the alarm
     forward (`now+dt`, still present in the returned `AlarmSet`); a `k-cancel`
     handler drops it (absent from the returned set);
  3. **exactly one `mux-step`** — when `poll-ready` returns a ready fd, exactly one
     cap is serviced (serial mutation), and
  4. **the linear `SockVec` threads once** — it comes back on *every* branch
     (`poll-ready`/`poll-timeout`/`poll-err`/`time-err`); dropping it fails the
     checker.
- **Type-level negatives (must stay checker-REJECTED):** dropping the linear
  `SockVec` cap on any arm; `let`-threading the cap (aliasing a `q=1` value);
  `earliest`/`wait-ms`/`remove-rid` declared/used as `=>` (they are provably `->`).
  Mirror the E106 linear-cap negative-test pattern (`test_e106_linear_cap.py`).
- **Tests to add:** one behavioral sample (`compile-main`, exit 42, run under B1 —
  native floor) + the checker-rejection negatives (type floor). Compare: native
  (compile+run) for behavior, checker for the negatives.
- **Green line:** 704 test functions (76 files) → ≥ 704 + 3 (behavioral sample +
  ≥2 negatives); ledger-lint clean.
- **Fixpoint status:** the supervisor is a **pure library** — it imports
  `poll`/`ports`/`lincoll` and adds no compiler-source change, so the gate is
  **compile-with-B1-and-run, no fixpoint** (the §6 B1 probe already showed the
  spine compiles: exit 0, 29048-byte ELF). It does **not** touch the blob; no
  self-hosting byte-compare is owed.
- **Done when:** the sample compiles under B1, runs to exit 42 demonstrating a
  near-deadline alarm firing (re-arm + cancel both honored) and exactly one
  `mux-step` on a ready fd with the `SockVec` threaded once; the three negatives
  stay checker-rejected; green line holds; ledger-lint clean.

## 6. Residue & links

- **Deliberately unbuilt (full scope named, honest v1):**
  - **Fully-typed alarm** — recoverable-vs-fatal as an E39-row TAG (not just the
    constructor offering), the counter-effect set beyond `k-resume`/`k-cancel`/
    `halt` (re-key / re-derive / relocate / repair-from-survivors / quarantine),
    and the handler/subtraction machinery → **E26** (`BUILD`/unbuilt, hard-gated
    on E39; `CONFORMANCE-MAP.md:59`). E39 carrier is BUILT (`:58`); E26 is the
    gate on the typed alarm — **not** the E39 row.
  - **Rung-2 halves — no rung-1 referent** (decision #3, `RUNG-2-MAP.md` Cluster 1,
    "seated not scheduled"): critical sections (preemption-disabled windows),
    register-root custody (derive-not-store) → E42 rung-2 mandate + E56 custody
    bulk (`CONFORMANCE-MAP.md:375`); interrupt→alarm translation → no catalog
    element (consumes E39/E26); SMP decomposition → E42 rung-2 ("decomposition
    unspecified"). Built as *shape* only at rung 1; metal enforcement never faked.
  - **Timer-precision upgrades** — `timerfd` (ns, one fd/timer, folded in as
    just-another-`POLLIN` fd) and `ppoll` (ns + atomic sigmask), deferred behind
    decision #1's poll-timeout v1.
  - **O(n) `earliest`** → deadline-ordered heap (O(log n)) if resident count grows
    (decision #4).
  - Skeletal glue: `fd->index`, `held-fds`, `dispatch-one`'s recv-route body.
- **Follow-on (what this unblocks):** `TUI/mux` (its `Blocked-on-core` substrate);
  the rung-2 emulator (second named consumer); E26 (the typed-alarm upgrade lands
  on this shape); E43 broker (the grant/revoke arm of this supervisor).
- **Related:** [[E42-alarm-supervisor]], [[E39-effect-row]] (row the alarm becomes
  a tag in — carrier built), [[E26-alarms]] (typed alarm, gated on E39),
  [[E106-lincoll]] (`SockVec` the loop threads), [[E32-clock-timer]] (`Clock` cap
  the wait reads), [[E43-broker]] (grant/revoke arm), `docs/banks/effect-and-alarm.md`
  (Shard 5 / §5a — design authority), `.planning/RUNG-2-MAP.md` (Cluster 1).
