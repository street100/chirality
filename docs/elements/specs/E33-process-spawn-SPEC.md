---
element: E33
slug: process-spawn
title: Process model: `spawn` (socketpair + `fork`/`execve`/`clone`)
kind: REPLACE-CRUTCH
example: examples/E33-process-spawn.md
status: audited
updated: 2026-07-27
---

# E33 SPEC — Process model: `spawn` (socketpair + `fork`/`execve`/`clone`)

> ⚑ **TRIAGE 2026-09-04 — DONE-ALREADY.** 0 of 6 steps are executable at HEAD.
> `lib/runtime/proc.chiral:51-103` carries `argv->pkt` and `raw-proc-spawn`.
> Bucket and evidence: `records/spec-tier-triage.md`. This file was not
> rewritten and its `status:` was not changed.

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** a new `lib/runtime/proc.chiral` gives chirality a typed,
  single-return `proc-spawn`: from a validated `(List Str)` argv it launches an
  **arbitrary external program** over a `SOCK_CLOEXEC` socketpair plus a
  CLOEXEC errno-pipe (`fork` → child `dup2`+`execve`, errno written to the
  pipe + `_exit(127)` on exec failure → parent single return with a
  synchronous `se-noexec`), handing back a
  linear `Child` = a `Reap` obligation + our end `Sock`, with `wait` decoding
  the status word to `ExitStatus` and interior-NUL argv rejected as
  `se-badargv` before any syscall. `run-filter cap ["cat"] b"x"` returns
  `(some b"x")` with the child reaped.
- **Non-goals:** no first-class `(cap ProcPort)` capability *value* (gating
  stays the profile frozen-port-set, §3 dec 4); no `clone`/vfork flags (§3
  dec 2); no stderr
  (fd 2) wiring, envp parameter, timeout, or kill/signal — all §6 residue. Does
  not touch the existing staging `spawn` (see Baseline).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** the two rows naming E33 both read **CONFORMS /
  SEEDED** — the *Category C port membrane* row ("spawn/staging SEEDED") and
  the *CLI/staging connector* row ("Self-hosted spawn is E33"). So the crossing
  SHAPE is settled; E33 adds a new named crossing to the existing frozen port
  set, it does not reshape one.
- **Live code this composes with (do NOT respec):**
  - `scaffold/lib/ports.chiral` — `(porttype Sock)`, `LSock`, `Fd`; the `=>`
    process-arrow socket externs `sock-send`/`sock-recv`/`sock-close`/`poll2`
    over linear `Sock` (E29/E30). `Sock` is reused verbatim as `Child`'s
    io field; the socketpair pattern is already proven in `impl_ports._spawn`.
  - `scaffold/chirality/impl_ports.py` — `_spawn` (line 90) already does
    `socket.socketpair(AF_UNIX, SOCK_STREAM)` + `Popen(pass_fds=…)`. It stages
    a **chirality profile** into a child chirality runtime (`python -m chirality
    spawn-run`) and returns one `Sock`. This is a *different* primitive from
    E33 (no argv, no execve of an arbitrary binary, no reap, no status decode);
    E33 is a **sibling**, not a reshape of it. Port-set gating precedent lives
    here (ports.chiral line 65: "spawn sits in a profile's frozen port set or
    that profile cannot use it").
  - The refinement module (`refine`) supplies `(refine I64 (> 0))` etc.
    for `pid`/`code`/`sig`; QTT quantity annotations (`(1 r Reap)`) supply the
    linear-consume discipline.
- **Not present (part of the delta):** no `(cap …)` capability *parameter*
  former exists — the `(cap I64)` in `mem-region.chiral` is a struct field
  (capacity), not a capability. No `raw-spawn`/`execve`/`wait4` host binding.
  `proc.chiral` does not exist.
- **True delta:** `SOCK_CLOEXEC` socketpair + CLOEXEC errno-pipe +
  `fork`/child-`dup2`/`execve` + `wait4`/reap, wrapped as one Category-B extern (`raw-proc-spawn`) + a
  Category-C `proc-spawn` bridge + the pure `argv->pkt` validator + the
  `Child`/`Reap`/`ExitStatus`/`SpawnErr` types — a new file, none of it a
  rewrite of the staging spawn.

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls:
RESOLVED only when derivable from a settled doc (cite it); genuinely novel
design goes to NEEDS-AUTHOR and is surfaced, never answered on the author's behalf.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Child-side `execve` failure: exit-code-127 convention vs errno-over-CLOEXEC-pipe (the latter distinguishes `se-noexec` from a program that itself exits 127, costs one more fd pair in the B primitive) | **RESOLVED (author, 2026-07-27) → errno-over-CLOEXEC-pipe in v1** | Doctrine fixes the end state: an alarm/divergence is "diagnostic *by construction*, not by convention" (`docs/banks/effect-and-alarm.md` X2) and "an unnamed failure path would be the gap" (`docs/error-and-alarm.md`) — exit-127-only conflates exec-failure with a program that ran and chose 127, and leaves `se-noexec` declared-but-unproduced (a phantom constructor). The author took the pipe in v1: the primitive is being written fresh, the cost is one CLOEXEC fd pair + a child-side write/parent-side read inside it, and `se-noexec` is producible and *synchronous* from the first landing. Pre-exec failures (socketpair/pipe/fork) stay `se-nomem`; `exited(127)` at `wait` now unambiguously means the program ran and exited 127. |
| 2 | `clone` flags vs plain `fork` (vfork-style `CLONE_VM\|CLONE_VFORK` is faster but constrains child-side code harder) | **RESOLVED → plain `fork`** | Decidable, no values conflict. The child-side code is already async-signal-safe-shaped — `dup2`/`close`/`execve`/`_exit(127)` only (ex. §2 finding 2) — so it is `fork`-safe as-is; vfork's shared-VM constraint buys speed no requirement asks for and adds a footgun. Momentum: take the obvious minimal option. The `clone`-flags optimization → §6 residue. |
| 3 | Should `Reap` carry a phantom brand tying it to the `ProcPort` that minted it? | **DEFERRED → capability model (rides with dec 4)** | The plain linear `Reap` already delivers v1's core guarantee (reap exactly once: dropping the `1`-bound field is a type error, reusing the consumed token is a type error). A brand tying `Reap` to its minting port is an orthogonal *cross-child provenance* guarantee that presupposes the `ProcPort` capability value exists (dec 4, deferred). Fabrication-resistance of `Reap` (opaque porttype vs open `data` constructor) rides the same home. Non-blocking. Owner: `docs/permission-model.md` / a capability-model element. |
| 4 | (surfaced by baseline) The example gates on `(cap ProcPort)`, but no capability *value* former exists in the language | **DEFERRED → capability/permission model** | v1 gates `raw-proc-spawn` exactly as the staging spawn is gated today: membership in a profile's **frozen port set** (`ports.chiral` line 65; `impl_ports._spawn` precedent). The `=>` process arrow already marks the crossing as effectful (a `->` function provably cannot spawn). The first-class `(cap ProcPort)` value parameter is the deferred enhancement; surface signatures in §4 omit it. Non-blocking. Owner: `docs/permission-model.md`. |
| 5 | (surfaced by baseline) Name collision: E33's bridge is called `spawn`, but `(extern spawn …)` already exists as the staging spawn | **RESOLVED → name E33's primitives `proc-spawn` / `raw-proc-spawn`** | Decide-and-check: the staging `spawn` is a live, differently-typed primitive (`=> Str Sock`); reusing the name clobbers it. E33's external-program bridge is `proc-spawn` and its Category-B substrate is `raw-proc-spawn`, both in `proc.chiral`. |

No open decisions: dec 1 resolved by the author (2026-07-27, errno-pipe in
v1). §4–§6 are specified against decs 1/2/3/4/5.

## 4. Change plan (ordered, commit-sized)

### Step 1 — types: `SpawnErr` / `Reap` / `Child` / `SpawnRes` / `ExitStatus`
- **Target:** NEW `lib/runtime/proc.chiral` — the five `data` decls from ex. §5.
- **Change:** `(import "prelude")` + `(import "ports")` (to reuse `Sock`).
  Declare `SpawnErr` (`se-nomem`/`se-noexec` carrying `(errno I64)`,
  `se-badargv`); `Reap` = `(reap (pid (refine I64 (> 0))))`; `Child` =
  `(child (1 r Reap) (1 io Sock))` (both fields linear — reuses the existing
  `Sock` porttype, does NOT redeclare it); `SpawnRes` = `sp-ok (1 c Child)` /
  `sp-err (e SpawnErr)`; `ExitStatus` = `exited (code (refine I64 (>= 0) (< 256)))`
  / `signaled (sig (refine I64 (> 0) (< 64)))`. No `(cap ProcPort)` param (dec 4).
- **Size:** ~S

### Step 2 — pure edge: `argv->pkt` validator + marshaller
- **Target:** `lib/runtime/proc.chiral` — `(declare argv->pkt (-> (List Str) (Option Bytes)))` + `def`.
- **Change:** build the byte-framing loop the example omitted as mechanical:
  fold `argv`, `str->bytes` each element, scan for interior `0x00` (→ `none`,
  i.e. `se-badargv`), else frame NUL-terminated into one `Bytes` block. A `->`
  pure arrow: runs *before* the membrane, so a bad argv issues **zero**
  syscalls. Reuses `Str`/`Bytes` prelude primitives.
- **Size:** ~M

### Step 3 — Category B substrate: `raw-proc-spawn` (the only fork site)
- **Target:** `scaffold/lib/proc.chiral` decl `(extern raw-proc-spawn (=> Bytes SpawnRes))`
  + host binding `_raw_proc_spawn` in `scaffold/chirality/impl_ports.py` (next to `_spawn`).
- **Change:** host: `socket.socketpair(AF_UNIX, SOCK_STREAM | SOCK_CLOEXEC)`
  (CLOEXEC at creation — ex. §2 finding 1; note the staging `_spawn` omits it)
  + `os.pipe2(os.O_CLOEXEC)` (the errno-pipe, dec 1); `os.fork()` (dec 2,
  plain fork); **child** — close the pipe read end, `dup2(child_fd,0)`,
  `dup2(child_fd,1)`, decode `pkt`→argv, `os.execve(argv[0], argv, {})`; on
  exec failure write `errno` (8-byte LE) to the pipe write end, then
  `os._exit(127)` (belt-and-braces, no longer the signal); **parent** —
  `close(child_fd)` + close the pipe write end, then `read()` the pipe:
  **EOF (0 bytes — CLOEXEC fired on the successful exec)** → single return
  `sp-ok (child (reap pid) ("sock", parent))`; **errno bytes** → `waitpid` the
  child (no zombie on the error path), `sp-err (se-noexec errno)` —
  synchronous from spawn itself (dec 1). socketpair/pipe/fork `OSError` →
  `sp-err (se-nomem errno)`. Register `raw-proc-spawn` in the profile
  frozen-port-set gate (dec 4).
- **Size:** ~L

### Step 4 — reap: `wait` extern + status decode
- **Target:** `lib/runtime/proc.chiral` decl `(declare wait (=> (1 r Reap) ExitStatus))`
  (host extern `raw-wait`) + `_raw_wait` in `impl_ports.py`.
- **Change:** consumes the linear `Reap`, reads its `pid`, `os.waitpid(pid, 0)`,
  decode: `os.WIFEXITED` → `exited(WEXITSTATUS)`, `os.WIFSIGNALED` →
  `signaled(WTERMSIG)`. Consuming `r` is what makes forgetting/double-reaping a
  type error. (No raw int escapes — status word decoded at the seam.)
- **Size:** ~S/M

### Step 5 — Category C bridge: `proc-spawn` + `run-filter` demo
- **Target:** `lib/runtime/proc.chiral` — `proc-spawn`, `run-filter`.
- **Change:** `(declare proc-spawn (=> (List Str) SpawnRes))`,
  `def = (lam (argv) (case (argv->pkt argv) (none (sp-err se-badargv)) ((some pkt) (raw-proc-spawn pkt))))`.
  Then `run-filter` verbatim from ex. §5 (send-close-write → drain → wait →
  match `exited 0`). Both are ordinary process functions above the bridge.
- **Size:** ~S

### Step 6 — differential conformance test
- **Target:** `scaffold/tests/test_process_externs.py` (extend) or NEW `test_proc.py`.
- **Change:** the four §5 gate tests (below). Assert the interior-NUL case
  issues **zero** syscalls (spy/patch `os.fork`/`socket.socketpair`).
- **Size:** ~M
- 2026-09-04: the Python oracle was cut, and scaffold/ went with it in the 2026-08-31 migration. The citations it left are kept as a record and have no live successor.

## 5. Conformance gate

- **Golden behavior:** parity with the CPython `socketpair`+`Popen`+`wait`
  triple —
  1. **round-trip + reap:** `run-filter cap ["cat"] b"x"` → `(some b"x")`, and
     the child is reaped exactly once (no zombie: a second `waitpid` on that pid
     → `ECHILD`).
  2. **exec failure, synchronous + unambiguous:** `proc-spawn cap ["/nonexistent"]`
     returns `sp-err (se-noexec ENOENT)` from the spawn call itself (dec 1:
     errno-pipe) — never blocks, and the child is reaped on the error path
     (no zombie).
  3. **pre-syscall reject:** an argv element containing `0x00` → `se-badargv`
     with **zero** syscalls issued.
- **Tests to add:** `test_proc_spawn_cat_roundtrip`,
  `test_proc_spawn_nonexistent_synchronous_noexec`,
  `test_proc_exit127_distinct_from_noexec` (a program that *runs* and exits
  127 → `sp-ok` + `wait` → `exited(127)`, disjoint from `se-noexec` — the
  ambiguity the pipe exists to kill),
  `test_proc_spawn_interior_nul_no_syscall` — each drives the `proc.chiral`
  surface through the interpreter against its `impl_ports` host referent (the
  single host floor; `fork`/`execve` have no native/tal floor — that is E34+
  AOT territory, so this is a host-referent differential, not cross-floor).
- **Green line:** 281 → ≥ 285; `python3 tools/ledger-lint/ledger-lint.py` clean.
- **Done when:** the `cat` filter round-trips its payload and the child is
  reaped (second wait → ECHILD), the `/nonexistent` path returns a synchronous
  `sp-err (se-noexec …)` without hanging, exit-127 programs are disjoint from
  `se-noexec`, and interior-NUL argv is rejected before any syscall runs.

## 6. Residue & links

- **Deliberately unbuilt (with home):**
  - `clone`/vfork flags optimization (dec 2) → perf pass, nobody's yet.
  - `(cap ProcPort)` capability *value*, `Reap`→port brand, `Reap`
    fabrication-resistance (opaque porttype) (decs 3, 4) →
    `docs/permission-model.md` / a capability-model element.
  - stderr (fd 2) → a second linear `Sock` field on `Child`; validated `envp`
    parameter; spawn timeout (pair `wait` with poll) → [[E31-poll-select]];
    kill/signal forwarding → a separate signal capability.
- **Follow-on this unblocks:** [[E34]] (an AOT-emitted ELF is exactly what
  `execve` here launches); [[E31-poll-select]] (non-blocking wait on the child
  `Sock`, spawn timeouts); agentic worker/filter drivers (manas-in-chirality).
- **Related:** [[E33-process-spawn]] (rationale), [[E29]] wire/socket
  primitives `Sock` reuses, [[E30]] port membrane, [[E31-poll-select]],
  [[E32-clock-exit-env]] (`_exit`/envp at the seam), [[E34]];
  `docs/process-and-runtime.md`, `docs/permission-model.md`.
