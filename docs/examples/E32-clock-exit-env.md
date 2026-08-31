---
element: E32
slug: clock-exit-env
title: `clock_gettime` (`time-mono`), `exit`, `env` access
kind: REPLACE-CRUTCH
reference_class: SPEC
ours_source: (none)
status: drafted
updated: 2026-07-22
---

# E32 — `clock_gettime` (`time-mono`), `exit`, `env` access

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.
> ABI facts (syscall numbers, timespec layout, register convention, ms math):
> **`refs/ref-clock.md`**, regenerable via `refs/gen-clock.py` — cited, not
> restated.

## 1. Scope

- **Element:** E32 — the time and process-exit crossings (`time-mono`,
  `sleep-ms`, `exit`) plus `env-get`, moved off CPython's `time`/`sys`/`os`
  onto the sys-tal floor (E51 binds them; lane A authors them).
- **Kind:** REPLACE-CRUTCH.
- **Why chirality needs its own:** beyond shedding the crutch, this element is a
  **survey of crossing shapes** the sys face has not met yet. Every crossing
  built so far is all-integer in, integer out (or byte-cell *in*, for memfd's
  name). E32 adds: an **out-param struct** (clock_gettime writes a timespec
  the caller reads back), an **in-param struct with a partial-completion
  result** (nanosleep and EINTR), a crossing that **never returns**
  (exit_group), and one "crossing" that is **not a syscall at all** (env).
  Each shape is a template the rest of the bank reuses (poll's pollfd array
  is the out-param shape again; spawn's never-return-in-child is exit's).

## 2. Research

- **Reference class:** SPEC — the Linux x86-64 ABI, derived locally into
  `refs/ref-clock.md`: clock_gettime=228 / nanosleep=35 / exit_group=231
  (231, not thread-exit 60), CLOCK_MONOTONIC=1, EINTR=4, timespec = two i64s
  (tv_sec @0, tv_nsec @8, 16 bytes), register convention per crossing, and
  the ms↔timespec math.
- **Key findings:**
  1. **The out-param discipline needs no new floor instructions.** A timespec
     is a 16-byte cell: `bnew 16` → pass `bptr` in rsi → kernel writes it →
     read the two i64s back from the payload. Write-then-read on one cell is
     already the arena-roundtrip pattern (E21); the kernel is just another
     writer. (The cell's len word stays chirality's, not the kernel's — the memfd
     precedent.)
  2. **EINTR is a result, not a hidden loop.** nanosleep returning -EINTR
     leaves the *remainder* in the rem timespec. The honest bridge returns
     `interrupted remaining-ms` as data; whether to re-sleep is the caller's
     policy. A retry loop inside the bridge would be an unbounded loop hidden
     below the totality checker's sight — exactly the shape the membrane
     exists to surface.
  3. **exit_group never returns.** The extern's polymorphic return
     (`(-> (0 A (type 0)) (=> I64 A))`, the existing `exit`/`halt` shape) is
     the surface form; what the *floor* does with a call that cannot return
     ties directly to E26's open `Never` question (0-ctor data vs first-class
     bottom). Cited, not resolved here.
  4. **`env-get` performs no syscall.** envp is stack data the kernel hands
     the process at exec, per the psABI entry protocol (E34's territory:
     argc/argv/envp above the initial rsp). Reading it is reading B memory
     the process already owns — the reified `Env` capability
     (decision-effect-facets ambient-reification worklist) gates a *memory
     view*, not a kernel entry.

## 3. Conventional (other-language) approach

```python
# impl_ports.py — the crutch: CPython stdlib over libc, ambient everywhere.
def _time_mono(u):
    return time.monotonic_ns() // 1_000_000   # anyone may ask the clock
def _sleep_ms(ms):
    time.sleep(ms / 1000.0)                   # EINTR retried invisibly,
                                              # a FLOAT crosses the seam
def _exit(code):
    raise MetisExit(code)                     # exit as an exception, caught
                                              # at the top — unwind theater
def _env_get(name):
    return os.environ.get(name, "")           # process-global mutable dict
```

- **Assumptions it bakes in:** ambient authority (any code can read the
  clock, sleep, exit, read env — no capability anywhere); a float on the
  sleep path (the seam chirality forbids); EINTR silently retried (libc/CPython
  decide the policy, invisibly); exit-as-exception (a `finally:` can
  *intercept process death*); env as a mutable global snapshot whose
  mutation (`os.environ[...]=`) silently diverges from the real envp.

## 4. The chirality idea

- **Chirality features in play:** reified capabilities (Clock, Env — possession),
  the effect row (exercise), byte cells for struct marshalling, result sums
  for errno, the I64-only seam (ms, never float seconds), totality (no
  hidden retry loops).
- **The reframing:** four shapes, one discipline —
  - `time-mono`: hold `Clock`, cross; the bridge allocates the timespec
    cell, makes the syscall, folds `tv_sec*1000 + tv_nsec/1000000` to ms
    (Euclidean, per the settled division law), returns I64.
  - `sleep-ms`: hold `Clock`, cross with an I64 ms bound; interruption comes
    back as `interrupted remaining-ms` — caller policy, visible in the type.
  - `exit`: hold `Exit` (granted to `main` per the E26 design), cross, never
    return.
  - `env-get`: hold `Env`, *view* — no syscall; the bridge reads the envp
    block handed at exec.
- **What chirality makes impossible here:** an un-held clock read or exit (a
  `->` function, or a `=>` one without the cap, cannot express either); a
  float crossing the seam; an invisible retry policy; an intercepted exit
  (no unwind exists to catch it); and env mutation drifting from reality —
  there is no env-set, the view is read-only by type, and a mutable env
  would be a new decided crossing, not a dict write.

## 5. Chirality example (fleshed)

```chirality
(import "prelude")
(import "sys-tal")     ; nb-sys-clock-gettime / nb-sys-nanosleep /
                       ; nb-sys-exit-group — lane-A hand-tal, ref-clock.md

; ---- reified capabilities (the ambient-extern reification, made real) ----
(porttype Clock)       ; time-mono + sleep-ms gate on this
(porttype Env)         ; env-get gates on this
; Exit is E26's design (granted to main); not redeclared here.

; ---- result shapes: errno is a constructor, ports thread back ------------
(data TimeR ()
  (time-r   (ms I64) (1 c Clock))
  (time-err (errno I64) (1 c Clock)))

(data SleepR ()
  (slept    (1 c Clock))
  (interrupted (remaining-ms I64) (1 c Clock))   ; EINTR: caller's policy
  (sleep-err (errno I64) (1 c Clock)))

(data EnvR ()
  (env-r    (v Str) (1 e Env))
  (env-none (1 e Env)))                          ; absent ≠ empty string

; ---- the typed faces (what lib/ports.chiral's ambient externs become) -----
(declare time-mono (=> (1 c Clock) TimeR))
(declare sleep-ms  (=> (1 c Clock) I64 SleepR))
(declare env-get   (=> (1 e Env) Str EnvR))

; ---- bridge sketch: the out-param shape (clock_gettime) ------------------
; refs/ref-clock.md: nr=228, rdi=CLOCK_MONOTONIC(1), rsi=bptr(cell), 16-byte
; cell, tv_sec @0, tv_nsec @8; ret 0 or -errno.
(def wrap-time-mono (=> (1 c Clock) TimeR)
  (lam (c)
    (let ((cell (bnew 16)))                    ; fresh zeroed cell (arena law)
      (let ((ret (nb-sys-clock-gettime 1 cell)))
        (if (<i ret 0)
            (time-err (- 0 ret) c)
            ; read back the two i64s the kernel wrote; byte-wise assembly
            ; per the bytes-tal idiom (8 bgets + shifts per word) ; …
            (let ((sec (cell-i64 cell 0)))
              (let ((nsec (cell-i64 cell 8)))
                (time-r (+ (* sec 1000) (/ nsec 1000000)) c))))))))

; ---- the in-param + partial-completion shape (nanosleep) -----------------
; req cell built from ms (sec = ms/1000, nsec = (ms%1000)*1000000 — Euclidean);
; rem cell read back ONLY on -EINTR. Retry is the CALLER's loop, bounded by
; the measure the caller can prove — never hidden in the bridge.
(declare wrap-sleep-ms (=> (1 c Clock) I64 SleepR))
; … build req cell; (nb-sys-nanosleep req rem); case on ret:
;   0 => (slept c) ; -EINTR => (interrupted (cell->ms rem) c)
;   other => (sleep-err (- 0 ret) c) ; …

; env-get: NO syscall — the bridge walks the exec-time envp block (E34's
; psABI entry protocol owns where that block lives). Read-only by type.
```

- **Knobs to modify:** whether Clock covers both read and sleep or splits
  (`Clock` / `Timer`) — one cap per crossing family vs per crossing; the
  errno sum granularity (E51's open question, shared); `env-none` vs
  defaulting — kept as a constructor so absence is a fact, not `""`.
- **Deliberately omitted:** the hand-tal bodies (lane A authors them against
  `refs/ref-clock.md`'s register table); `cell-i64`'s byte-assembly loop
  (bytes-tal idiom, `; …`); the wall-clock (`CLOCK_REALTIME` is B-untrusted
  time — the freshness-verify design owns it, not this element); env
  *iteration* (only keyed lookup is faced).

## 6. Use / modify notes

- **Lands in:** `lib/sys-tal.chiral` (three `nb-sys-*` crossings, lane A) +
  `lib/ports.chiral` (the reified Clock/Env porttypes and result shapes,
  replacing the ambient `time-mono`/`sleep-ms`/`env-get` externs) + the E51
  binding table rows.
- **Conformance target:** differential vs the crutch — `time-mono` within
  jitter of `time.monotonic_ns()//1e6` and *monotone across calls*;
  `sleep-ms n` sleeps ≥ n ms (modulo EINTR, now visible); `exit n` produces
  process status n; `env-get` byte-equal with `os.environ` for present keys
  and `env-none` for absent ones.
- **Open questions:** **is `env-get` a row entry?** No kernel entry occurs,
  but the read observes world-state (exec-time input) — if it is *not* a
  crossing, a `->` function holding Env could read env and purity stops
  meaning referentially transparent. The honest answer seems to be: a
  crossing is an *observation or mutation of the world*, not a syscall —
  env-get is in the row, and E32 is the existence proof that the row is not
  a syscall list. (Feeds E39's row-representation design.) Also: Clock
  granularity (one cap or two); where `Exit` sits vs `halt` (E26); whether
  `cell-i64` earns a floor instruction (`bget64`) or stays a library loop.
- **Related:** [[E51-sys-linkage]] (the binding table + errno pattern),
  [[E31]] (poll — the out-param array shape next), [[E33-process-spawn]]
  (never-return in the child), [[E26-alarm-control-flow]] (`Never`, `Exit`),
  [[E34]] (psABI entry — where envp lives), [[E21-arena]] (the cell
  roundtrip discipline), `refs/ref-clock.md` (the ABI facts).
