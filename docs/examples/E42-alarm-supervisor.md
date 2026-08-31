---
element: E42
slug: alarm-supervisor
title: Runtime supervisor (critical sections, register-root custody, scheduler)
kind: BUILD-PROPER
reference_class: OURS/PAPER
ours_source: scaffold/chirality/runtime.py
status: drafted
updated: 2026-08-11
---

# E42 — Runtime supervisor (critical sections, register-root custody, scheduler)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E42 — the runtime **supervisor / scheduler**: the top-level
  process that multiplexes {fd-readiness, fired alarms, the resident work-list},
  dispatches one unit of work at a time (serial mutation), threads the linear
  session capabilities, bounds **critical sections** (preemption-disabled
  windows), and holds **register-root custody** (the derive-not-store master
  secret). It is the substrate the TUI `mux` and the rung-2 emulator run on.
- **Kind:** BUILD-PROPER. Reference class OURS/PAPER — `scaffold/chirality/runtime.py`
  (a *different* artifact: the scaffold's tree-walking evaluator+linker, not this
  supervisor) plus seL4/microkernel design notes.
- **Why chirality needs its own:** the supervisor is where the whole effect/alarm
  algebra is *performed* at system scale. It is the **counter-effect dispatcher**
  (effect-and-alarm bank X5: "the supervisor's revoke is a customer of the
  effect/alarm system") and the home of the two rung-2 secret-root obligations
  (critical sections, register root). None of it exists as code — the catalog
  carries it as `PAPER; design notes only` (`.planning/RUNG-2-MAP.md` Cluster 1).
  The full scope is deliberately named here even though §5 fleshes only the
  alarm-register/fire + supervised-loop core.

  **Full scope, per `RUNG-2-MAP.md`:** (a) the supervised event loop / scheduler
  itself; (b) **alarms as crossings** on the effect membrane (not ambient
  timers/signals) with graded continuations + synthesized cancel; (c) **critical
  sections** — "atomic, preemption-disabled or the root leaks" (SECURE-DATUM);
  (d) **register-root custody** — keys derived, never stored in RAM; (e) the
  **interrupt → alarm translation** (a hardware event enters the effect row as an
  alarm crossing — no catalog element, consumes E39/E26); (f) **SMP / multi-core**
  decomposition (inside E42's mandate, "decomposition unspecified"). (c)–(f) have
  no rung-1 referent — at rung 1 the supervisor is *discipline on a Linux we do
  not control*; only metal converts them (rung 2). §5 fleshes (a)+(b).

## 2. Research

- **Reference class:** OURS/PAPER.
  - `docs/banks/effect-and-alarm.md` — the design authority. An **alarm** is "a
    detected divergence, raised as a typed effect, carrying what diverged from
    what" (§1). The **counter-effect** is the response drawn from a *named finite
    set* (re-key / re-derive / relocate / repair-from-survivors / quarantine /
    halt). Cross-cut **X5**: the supervisor (E42) IS the counter-effect
    dispatcher; the E43 broker is its grant/revoke arm. **X1**: a revoked linear
    port becomes a dead port, the *next crossing raises an alarm* — the runtime
    "arranges that the type of the next crossing carries the failure", it does not
    poll at runtime.
  - `.planning/RUNG-2-MAP.md` — the supervisor's place in the rung-2 machine: the
    classical kernel is *dissolved* (no interrupt-handler table — a hardware event
    is an alarm crossing; no scheduler-as-separate-thing — it is this process).
    Critical sections / register root / SMP all live under E42's mandate.
  - `scaffold/lib/poll.chiral` (E-poll) — the concrete scheduling **mechanism that
    exists today**: `poll-fds : (=> (List I64) I64 PollR)`, a pure pollfd builder
    + pure ready-scanner around one `nb-poll` crossing, returning the boundary sum
    `PollR = poll-ready (List ReadyFd) | poll-timeout | poll-err errno`.
  - `scaffold/lib/ports.chiral` (E32) — time reified as **split** capabilities:
    `Clock` (`time-mono : (=> (1 c Clock) TimeR)`, the monotonic anchor) vs
    `Timer` (`sleep-ms`, a deadline-wait). Both thread the cap back linearly via a
    result sum (the `RecvR` pattern). No wall clock.
  - `scaffold/lib/lincoll.chiral` (E106) — `SockVec`, the move-only linear cap
    container the loop iterates, with `mux-step` ("concurrent progress, serial
    mutation": only the serviced cap is ever mutated).
  - `TUI/mux/SCOPE.md` — the concrete consumer: hold N `Session` caps, one loop
    drains all ptys; explicitly `Blocked-on-core` on "the E42 alarm-supervisor
    substrate (designed, unbuilt)".

- **Key findings (load-bearing):**
  1. **The membrane floor is BUILT; the alarm's handler machinery is the build.**
     The `->` vs `=>` effect bit is `CONFORMS` (E12): it rides Pi position 2 and
     is part of type identity. The *effect-row carrier* is further along than the
     coarse bit: **E39 steps 1–6 landed BUILT 2026-07-28** (CONFORMANCE-MAP) — a
     row in Pi pos-2, `subtype`'s VPi row-subsumption case, set-containment gating,
     call-graph-inferred rows — with only Step 7 (Console reification) pending and
     the handler/subtraction machinery riding E26. What is genuinely unbuilt is the
     *alarm as a tag on that row* plus its counter-effect handler machinery
     (recoverable-vs-fatal in the type): that is **E26, hard-gated on E39** (BUILD,
     unbuilt). So today an alarm is a thesis with a Python crutch (`MetisExit` /
     `PortError`, `alarms.py`), and only `halt` is realized (a bare extern,
     `ports.chiral:127`). §5 fleshes with the coarse `=>` bit and **names** the E26
     alarm-tag upgrade — it does not pretend the typed alarm is here.
  2. **Alarms are crossings, and control is graded by capture** (settled 2026-07-21,
     `decision-effect-facets`, amended into `decision-graded-kernel`). A handler is
     the process at the other end of a port; resumption multiplicity is **graded by
     what the continuation captures** (a continuation holding a linear cap is
     one-shot at `q=1`); abort is a **synthesized cancel** closing the captured
     inventory. Recoverable-vs-fatal is encoded structurally: offering **both**
     `k-resume` and `k-cancel` = recoverable, `k-cancel` **alone** = fatal
     (effect-and-alarm Shard 5) — no new carrier field.
  3. **Timer/`poll` timeout semantics (web-verified, man7).** `poll(2)`: timeout in
     **milliseconds**; `-1` = block forever; `0` = return immediately; return value
     `0` = timed out with no fd ready. `ppoll(2)`: `timespec` (ns) + atomic signal
     mask; a negative timeout is an error, not "infinite". `timerfd_create(2)`: the
     timer notifies via a **file descriptor** that becomes `POLLIN`-readable on
     expiry and can be watched by `poll`/`epoll` alongside other fds; `read()`
     returns a `uint64` expiration count. → three candidate mechanisms for the
     loop's wait (a genuine spec-stage decision — see §6): compute-nearest-deadline
     into `poll`'s ms timeout (what `poll-fds` does *today*), a `timerfd` folded in
     as just-another-pollable-fd, or `ppoll` for ns precision + signal safety.

## 3. Conventional (other-language) approach

An event loop / supervisor in C or Python: a run-loop that registers timer
callbacks in a heap, installs signal handlers, and blocks in `poll`/`epoll` on
a timeout computed from the nearest timer. A libuv-style skeleton:

```c
for (;;) {
    int timeout = timers_empty() ? -1 : (nearest_deadline() - now_ms());
    int n = poll(fds, nfds, timeout);           /* block on fds OR timeout   */
    if (n == 0) run_due_timers();               /* a timer "fired"           */
    else for (i=0;i<nfds;i++) if (fds[i].revents) dispatch(fds[i].fd);
}
/* alarms arrive out-of-band: */
void on_sigalrm(int s) { g_flag = 1; }          /* signal handler, ambient   */
```

- **Assumptions it bakes in:**
  - **Ambient timers / signals.** `SIGALRM` fires into a handler with no
    capability in scope; the timer heap is process-global state.
  - **Untyped effects.** `dispatch(fd)` may do anything; nothing in a callback's
    type says it crosses, and nothing distinguishes a *divergence* (an alarm) from
    an ordinary event or from a hung callback (non-termination — a fourth,
    silently-fused axis).
  - **Aliasable resources.** the fd set and the timer callbacks are shared,
    mutable, re-entrant; a callback can close an fd another still references
    (use-after-free), and re-entrancy is uncontrolled — there is no notion of a
    *critical section the scheduler owns*.
  - **`try/catch` fuses four things** chirality un-fuses (effect-and-alarm §4): the
    signal, the control-flow unwind, the recovery, and the "hung" case.

## 4. The chirality idea

- **Chirality features in play:** the effect membrane (`->` pure vs `=>` process,
  E12 built; the effect-**row** carrier E39 built steps 1–6, the alarm-**tag** on
  it E26 to build); QTT linearity (the `Sock`/`Clock`
  caps threaded `q=1`, `SockVec` move-only); ports & capabilities (no ambient
  authority — the `Clock` is *passed*, not read from thin air); boundary sums
  (`PollR`, `KontMsg`, `TimeR` — parse once, no sentinels); totality (the pure
  spine is total; the loop is a *productive* process, not a terminating function).

- **The reframing:**
  - **An alarm is a crossing, not a signal.** Firing an alarm is a `=>` crossing
    that notifies the resident at the other end of its port and reads back a
    `KontMsg` (`k-resume rearm-ms | k-cancel`). `k-resume` re-arms **forward** from
    now (the only sound resumption after a committed crossing — effect-and-alarm
    §5a); `k-cancel` is the **synthesized cancel** that drops the alarm and closes
    what the continuation captured. There is no ambient timer heap: the pending set
    is a value the supervisor threads.
  - **The scheduler IS the loop, and the wait is `poll`'s timeout.** The nearest
    alarm deadline is *multiplexed into* `poll`'s timeout argument: `wait-ms`
    computes `deadline - now` (via the `Clock` cap) clamped to `>= 0`, or `-1`
    (block forever) when no alarm pends. One blocking primitive then resolves
    **both** axes: `poll-timeout` ⇒ the nearest alarm fired; `poll-ready` ⇒ an fd
    is ready → dispatch **exactly one** index into `mux-step` (serial mutation).
  - **Critical sections + register-root are the scheduler's, by construction.**
    Because there is no ambient authority and mutation is serial-by-linearity, a
    critical section is a *preemption-disabled window the supervisor owns* around
    the alarm crossing (rung-2: "atomic, preemption-disabled or the root leaks");
    register-root custody (derive-not-store) lives in the same trusted process.
    Neither has a rung-1 referent — at rung 1 they are discipline on Linux (§6).

- **What chirality makes impossible here:** an alarm that is *dropped* (dropping it
  shows in the type — effect-and-alarm §1); a callback that closes a cap another
  holds (linearity rejects it); ambient timer/authority (no cap in scope, no
  crossing); and — the load-bearing one — silently treating a **hung** resident as
  a catchable alarm: non-termination is the *totality modality*, a separate axis
  the supervisor does not conflate with divergence.

## 5. Chirality example (fleshed)

The alarm-register/fire core + the supervised wait. Real surface syntax. The
whole spine below **compiles clean under B1** (`compile-main` entry, exit 0 →
29 KB ELF; see §6 ground-truth): the alarm crossing typechecks on the membrane
and `poll-fds` composes as the wait primitive. Consumed interfaces (`poll-fds`,
`PollR`, `Clock`, `time-mono`, `TimeR`) are shown by their **real** signatures
from `poll.chiral` / `ports.chiral`; in the tree these come by `(import …)`.

```chirality
(import "poll")        ; poll-fds, PollR, ReadyFd, Cond
(import "ports")       ; Clock, time-mono, TimeR   (E32 split)
(import "lincoll")     ; SockVec, sv-detach-at, mux-step   (E106)

; ── alarms as data on the membrane ────────────────────────────────────────────
; recoverable-vs-fatal is the CONSTRUCTOR OFFERING (effect-and-alarm Shard 5):
; a handler returning k-resume|k-cancel is recoverable; k-cancel-only is fatal.
; NOTE: today the row is the coarse `eff` bit; the alarm-as-a-typed-row-TAG is
; E26, hard-gated on the E39 effect row. This is the shape that row will carry.
(data KontMsg () (k-resume (rearm-ms I64)) (k-cancel))

; an alarm registered ahead of time: a monotonic-ms deadline + the resident to
; notify. It holds NO linear cap (custody of caps stays in the SockVec), so the
; pending set is an ordinary unrestricted value the supervisor threads.
(data Alarm   () (alarm (deadline I64) (rid I64)))
(data AlarmSet () (as-nil) (as-cons (hd Alarm) (tl AlarmSet)))
(data DueR    () (due-none) (due (ms I64) (rid I64)))

; earliest pending deadline (pure min-scan, structural recursion = total).
(def earliest (-> AlarmSet DueR)
  (lam (s)
    (case s
      (as-nil (due-none))
      ((as-cons a rest)
        (case a
          ((alarm d r)
            (case (earliest rest)
              (due-none      (due d r))
              ((due md mr)   (case (<i d md) (true (due d r))
                                             (false (due md mr)))))))))))

; THE MULTIPLEX: fold the nearest alarm deadline INTO poll's timeout.
;   poll(2): timeout in ms; -1 = block forever; 0 = return immediately.
; So fd-readiness and alarm-firing share ONE blocking primitive.
(def wait-ms (-> AlarmSet I64 I64)
  (lam (s now)
    (case (earliest s)
      (due-none    (- 0 1))                       ; no alarm: -1 = infinite
      ((due ms r)  (case (<i ms now) (true 0)     ; already due: don't block
                                     (false (- ms now)))))))

(def remove-rid (-> AlarmSet I64 AlarmSet)
  (lam (s r)
    (case s
      (as-nil (as-nil))
      ((as-cons a rest)
        (case a
          ((alarm d ar) (case (=i ar r) (true  (remove-rid rest r))
                                        (false (as-cons a (remove-rid rest r))))))))))

; ── firing an alarm IS the crossing ───────────────────────────────────────────
; notify the resident at the other end of its port; read its KontMsg answer.
; k-resume dt => re-arm FORWARD at now+dt (the only sound post-crossing resume);
; k-cancel    => synthesized cancel: drop the alarm (closing captured inventory).
; (`notify` stands for the handler port; the E39 row makes it a row-tag crossing.)
(extern notify (=> I64 KontMsg))

(declare fire-earliest (=> AlarmSet I64 AlarmSet))
(def fire-earliest
  (lam (s now)
    (case (earliest s)
      (due-none s)
      ((due ms r)
        (case (notify r)                                        ; <- the crossing
          ((k-resume dt) (as-cons (alarm (+ now dt) r) (remove-rid s r)))
          ((k-cancel)    (remove-rid s r)))))))

; ── one supervised tick: the scheduler's body ─────────────────────────────────
; multiplex {fd-readiness, fired alarm}; dispatch exactly ONE unit; thread the
; caps + clock back linearly. `=>` process: it crosses (time, poll, service).
(data Tick () (tick (1 caps SockVec) (rest AlarmSet) (1 c Clock)))

(declare supervise-step (=> (1 caps SockVec) (List I64) AlarmSet (1 c Clock) Tick))
(def supervise-step
  (lam (caps fds s c)
    (case (time-mono c)                              ; read the monotonic anchor
      ((time-err e c2) (tick caps s c2))             ; clock diverged: its own alarm
      ((time-r now c2)
        (case (poll-fds fds (wait-ms s now))         ; block on fds OR alarm deadline
          ((poll-ready rs)                           ; an fd is ready …
            (tick (dispatch-one caps rs) s c2))      ;   … service ONE (serial mutation)
          ((poll-timeout)                            ; the nearest alarm fired …
            (tick caps (fire-earliest s now) c2))    ;   … raise it as a crossing
          ((poll-err e) (tick caps s c2)))))))       ; poll diverged: supervisor alarm

; dispatch the first ready fd into the mux servicing step: detach that cap,
; recv/send threads the SAME cap back (RecvR), push it back. Only the serviced
; cap is ever mutated -> "concurrent progress, serial mutation" (lincoll/E106).
(declare dispatch-one (=> (1 caps SockVec) (List ReadyFd) SockVec))
(def dispatch-one
  (lam (caps rs)
    (case rs
      (nil caps)                                     ; nothing ready: pool unchanged
      ((cons r more)
        (case r ((ready fd cnd) (mux-step caps (fd->index caps fd))))))))

; the outer loop is the SCHEDULER: recurse on the returned Tick forever. It is a
; PRODUCTIVE process (an event loop), not a terminating function — it lives
; outside the (total) demand: partiality is one effect in the totality modality.
(declare supervise (=> (1 caps SockVec) (List I64) AlarmSet (1 c Clock) Unit))
(def supervise
  (lam (caps fds s c)
    (case (supervise-step caps fds s c)
      ((tick caps2 s2 c2) (supervise caps2 (held-fds caps2) s2 c2)))))
```

- **Knobs to modify:** the resident id type (`rid I64` → a linear resident cap
  once residents are caps); the `notify` port (a stub extern here → an E39
  row-tag crossing to a real handler process); the wait mechanism inside
  `wait-ms`/`poll-fds` (poll-ms deadline vs `timerfd` vs `ppoll` — §6); the
  work-list shape (`AlarmSet` linear list → a deadline-ordered heap for O(log n)
  `earliest`).
- **Deliberately omitted (skeletal or named-only):** `fd->index` / `held-fds` /
  `dispatch-one`'s recv-route body (mechanical, elided); the **critical-section
  wrapper** around the alarm crossing (rung-2 preemption control — no rung-1
  referent); **register-root custody** and **SMP** (named in §1, no code); the
  interrupt→alarm translation (no catalog element). The counter-effect *set*
  beyond `k-resume`/`k-cancel`/`halt` (re-key / re-derive / relocate / repair /
  quarantine) — those land with E26 on the E39 row.

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/supervisor.chiral` (new) — the scheduler + alarm
  registry — consuming `poll.chiral`, `ports.chiral` (E32 `Clock`), and
  `lincoll.chiral` (E106 `SockVec`); its first consumer is `TUI/mux` (per
  `TUI/mux/SCOPE.md`). The rung-2 halves (critical sections, register root,
  interrupt→alarm, SMP) attach here as they are cataloged.
- **Conformance target:** the loop must (1) service **exactly one** ready cap per
  tick (serial mutation — no second writer), (2) fire the earliest-deadline alarm
  when `poll-timeout` returns, threading the pending set as a value, (3) re-arm on
  `k-resume` / drop on `k-cancel`, and (4) never drop a linear cap on any arm
  (the `SockVec` comes back on every branch, `lincoll` invariant). The pure spine
  (`earliest`/`wait-ms`/`remove-rid`) must be provably `->`.
- **Ground-truth (B1 probe, verbatim).** The §5 spine (with the consumed
  interfaces re-declared by their real signatures, over `collections`, plus a
  `compile-main (=> I64 I64)` entry exercising `wait-ms`) compiled under B1:
  `B1 exit=0`, `29048`-byte ELF. This confirms the two real questions: **(a)** the
  alarm-crossing shape typechecks on the membrane — `notify (=> I64 KontMsg)`
  cased with a `k-cancel` arm inside `fire-earliest`; **(b)** the poll-timeout
  driver composes as the loop's wait primitive — `poll-fds fds (wait-ms s now)`
  with `poll-timeout → fire-earliest`, and `time-mono` threads the `Clock` cap
  linearly through `TimeR`. (The minimal blob does not carry `poll.chiral`'s own
  `div`/`mod` prims — those resolve only in the full tree — so the interfaces
  were re-declared, not imported, for the isolated probe; signatures are verbatim.)
- **Open questions (genuine spec-stage decisions, left for the SPEC):**
  1. **The concrete timer mechanism** — *unsettled*. `poll-fds` already implements
     the compute-nearest-deadline-into-poll's-ms-timeout path (this example uses
     it), simplest and dependency-free but ms-granular and re-computes the deadline
     each tick. Alternatives: a **`timerfd`** per alarm (or one re-armed) folded in
     as just-another-`POLLIN` fd — uniform "everything is an fd", ns-granular, at
     the cost of a fd per timer and a new crossing; or **`ppoll`** for ns precision
     + atomic signal masking. Web-verified semantics in §2; pick in the SPEC.
  2. **The effect-row dependency (E39/E26).** §5 fleshes with the coarse `=>` bit;
     the alarm-as-a-typed-row-**tag** (and recoverable-vs-fatal as the E39-carried
     `KontMsg` offering) is **E26, hard-gated on E39** (specced, unbuilt). The E39
     row *carrier* is already built (steps 1–6, 2026-07-28); what remains is E26's
     alarm-tag + handler machinery. The supervisor is buildable on the coarse bit
     now; the *typed* alarm waits on E26. Do not implement E26 here.
  3. **Rung-2 halves have no rung-1 referent.** Critical sections
     (preemption-disabled windows), register-root custody (derive-not-store), the
     interrupt→alarm translation, and SMP decomposition are **metal-only**
     (`RUNG-2-MAP.md` Cluster 1; "seated, not scheduled"). At rung 1 the supervisor
     is discipline on a Linux we do not control (C8) — build the *shape* (the loop,
     the alarm crossing) now, never fake the metal enforcement.
  4. **`earliest` cost.** the linear-list `AlarmSet` is O(n) per tick; a
     deadline-ordered heap is the obvious upgrade if the resident count grows.
- **Related:** [[E39-effect-row]] (the row this alarm becomes a tag in),
  [[E26-alarms]] (alarm-as-typed-effect, gated on E39), [[E106-lincoll]] (the
  `SockVec` the loop threads), [[E32-clock-timer]] (the `Clock` cap the wait
  reads), [[E43-broker]] (the grant/revoke arm of this supervisor).
