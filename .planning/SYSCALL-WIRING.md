# SYSCALL WIRING MAP — face ↔ referent ↔ crossing (2026-07-28)

The 1:1 ledger for the E51 final pass. Three layers: the **typed face**
(effectful externs, contract owned in chirality source), the **host referent**
(`impl_ports.py`, the CPython transport being retired), and the **tal
crossing** (`sys-tal.chiral`, the self-hosted floor). E51's job is the wire
between face and crossing per row; this file is so that pass is *connecting,
not designing*. Status per row = what the wire needs.

**Floor inventory (12 crossings built, all differentially tested incl. the
errno observable):** write(1) read(0) lseek(8) memfd(319) ftruncate(77)
mmap(9) munmap(11) mprotect(10) close(3) clock_gettime(228) nanosleep(35)
exit_group(231).

**Scope caveat (do not misread this file as a closed surface).** These 23
face externs are what chirality *performs*; they are NOT the whole syscall
surface (362 calls — see `docs/syscall-map.md`). The floor is currently
OPEN: `ti-sys` emits any number, gated only by the `nb-sys-*` naming
discipline (RUNG-2-MAP WATCH-4). This file is the wiring ledger for the
performed set; closing the surface (default-deny gate keyed to the typed
crossings, per P1) is separate, unbuilt, author-scoped work.

## Group A — bindable at E51 v1 (full path exists today)

| Face extern | Referent | Tal path | Binds |
|---|---|---|---|
| `put` | `_put` | `nb-sys-write(1, bytes)` | **E51 v1** (decision 5) |
| `print` | `_print` | `nb-sys-write(1, bytes+NL)` — referent appends NL (audit catch) | **E51 v1** |
| `trace` | `_trace` | `nb-sys-write(2, bytes+NL)` — also appends NL | **E51 v1** |

## Group B — crossings built; the wire needs a named seam

| Face extern | Referent | Tal path | Missing seam |
|---|---|---|---|
| `fd-close` | `_fdclose` | `nb-sys-close` ✓ (E28) | fd-view (raw-int view of the linear atom — E51 step 1) |
| `pool-create n` | `_poolcreate` | `memfd → ftruncate → mmap(MAP_SHARED)` ✓ (E21 chain) | the **port-mint seam** (wrapper must MINT `(Pool n)`/`Fd` atoms — fd-view's dual) |
| `pool-close` | `_poolclose` | `munmap + close` ✓ | port-mint seam (consume side) |
| `pool-write` | `_poolwrite` | **not a syscall** — a store into the mapped region; needs a raw-pointer store helper (bytes-tal has cell ops only) | raw-store helper + fd-view |
| `time-mono` | `_timemono` | `nb-sys-clock-gettime` ✓ (E32) | cap-atom view + `nb-cell-i64` fold (helpers ✓) |
| `sleep-ms` | `_sleepms` | `nb-sys-nanosleep` ✓ (E32) | ms→timespec cell build (arith over `nb-cell-put-i64` ✓) |
| `exit` | `_exit` | `nb-sys-exit-group` ✓ (E32) | trivial; `Never` semantics stay E26 |

## Group C — crossings designed (audited SPECs), hand-tal NOT built

| Face extern | Referent | Element | State |
|---|---|---|---|
| `sock-send-fd` | `_socksendfd` | **E30** (sendmsg 46 + SCM_RIGHTS cmsg assembly over `nb-put-*`) | SPEC audited, implement-ready |
| `poll2` | `_poll2` | **E31** (poll 7; pollfd fill reuses E32's cell helpers; face rides the general `nb-sys-poll`) | SPEC audited, implement-ready |

## Group D — THE HOLE: crossings neither built nor specced

| Face externs | Referent | Element | State |
|---|---|---|---|
| `sock-connect` `sock-listen` `sock-accept` `lsock-close` `sock-send` `sock-recv` `sock-close` | `_sock*` (Python `socket`) | **E29** — socket(41) connect(42) bind(49) listen(50) accept(43) send/recv or write/read, plus the AF_UNIX `sockaddr_un` cell assembly | example **reviewed only — never specced**. The largest unbuilt slab on the E51 path; 7 of the face's externs dead-end here |

E29 needs its `example-to-spec` run + audit before its hand-tal can land.
Until then, "retire impl_ports" is structurally impossible for the socket
family — E51's migration-window fallback exists precisely for this.

## Group E — host-B by design (no tal crossing owed on this rung)

| Face extern | Referent | Why not tal | Home |
|---|---|---|---|
| `spawn` (staging) | `_spawn` | stages a chirality child via the host; self-hosted spawn is **E33**'s sibling `raw-proc-spawn` (host-B until E34 AOT — fork/execve of *ourselves* needs an ELF to exec) | E33 → E34 |
| `env-get` / `env-view` | `_envget`/`_envview` | **no syscall exists** — env is exec-time stack data; the native envp walk is gated on **E34**'s psABI entry stub | E34 |
| `halt` | `_halt` | the fatal alarm counter-effect; its machinery is **E26** (rides the E39 row) | E26 |
| `secret-seal/reveal/wipe` | `_secret*` | custody substrate (E40 seed); zeroize-to-floor is **E56** | E40/E56 |
| `http-request`, `chat-*` | urllib shim | composes over sockets — the transport swap is "E51 lane" via **E65**, AFTER E29 lands | E65 |

## The runtime wires (E51's own steps, element-independent)

1. `fd-view` bridge-internal primitive (never a surface extern; sysface-only).
2. `lib/sys-linkage.chiral` binding table (`sys-bindings`) + v1 wrappers.
3. Link-at-load: `runtime.py:133` pap-mint consults the table (**per-runtime
   instance, not module-global** — RUNG-2-MAP WATCH-1).
4. `bridge.verify` re-seated on wrapper returns; `missing` check relaxed to
   bound-or-IMPLS.
5. Demotion comments on bound referents.

## Verdict

Two separate claims, kept separate:

**(1) The performed set is nearly wired.** Face ↔ referent is 1:1 complete
(30/30 effectful externs have referents). Referent ↔ crossing is 1:1
designed or built for everything except the socket family: 12 crossings
built, 2 audited-ready (E30/E31), 7 externs blocked on E29's missing spec,
9 host-B by design with named homes. For groups A/B the final pass is "just
connecting wires" once E51's five runtime wires exist; for sockets it is not
yet — E29 needs its spec first. Sequence: **E31 → E30 → E29 (spec, audit,
implement) → E33 → E51 → E39-step-7 re-thread.**

**(2) The surface is now governed at the type-level chokepoint (E76,
2026-07-28), OS-level still owed.** The closing model is ratified
(`docs/decision-syscall-governance.md`): default-deny at a chokepoint, not
enumeration. First slice built — `tal.py SYSCALL_TABLE` refuses an
unregistered `ti-sys` and binds name↔number, so the 339 unmodeled calls are
denied-by-absence at tal-check, not merely unwritten. Still owed: the
profile-permitted-**subset** gate (E76 remainder), the rung-1 **seccomp**
default-deny that makes the *kernel* refuse them (E77), and number-in-type
attenuation (E78). Do not let "the wires are connected" read as "the floor is
fully closed" — the OS-level half is unbuilt. See `docs/syscall-map.md`.
