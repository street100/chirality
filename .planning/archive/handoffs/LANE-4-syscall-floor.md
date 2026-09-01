> **ARCHIVED 2026-09-01. Superseded by `docs/examples/E51-sys-linkage.md` and `lib/lowering/tal/`, plus the E28-E33 ledger rows, all tracked.** The crossings landed and E51 v1 seam is built; the outstanding half is carried in the catalog E51 row.

# LANE 4 — syscall bank real + E51 linkage (→ runtime-floor self-host)

Read `../HANDOFF.md` first. Largely parallel (the crossings are independent hand-
tal); the E51 *wiring* couples to Lane 1's row for the effect claim, but the
crossings themselves can be built now.

## Goal
Take the orchestrator's I/O **off CPython**: author each syscall as hand-tal in
`lib/sys-tal.chiral`, then E51-link so upper-effectful chirality reaches them THROUGH
the sys-face instead of `impl_ports.py`. This is the milestone that makes the
containment claim **enforcement, not discipline** — and gets to the
**runtime-floor self-host** (authority path fully chirality-typed, red-team-able),
the nearer of the two demonstrable milestones.

## Rests on (read these)
- `examples/E28-mmap-crossings.md`, `E29-sockets.md`, `E30-fd-passing.md`,
  `E31-poll.md`, `E32-clock-exit-env.md`, `E33-process-spawn.md` — one per
  syscall family.
- **The ref banks** `examples/refs/ref-*.md` (+ their `gen-*.py`) — exact syscall
  numbers, struct offsets, register conventions, **regen to verify** (they're
  self-checking; fdpass asserts against `socket.CMSG_LEN`).
- `examples/E51-sys-linkage.md` — the binding table + the **fd-view privilege**
  (who may open an opaque port atom to its raw int — must be sysface-only, and
  it must THREAD the port back, not consume it: the audited `FdView` result-shape).
- `lib/sys-tal.chiral` — the existing pattern (write/read/lseek/memfd/ftruncate/
  mmap/munmap already authored).

## The work (spec each first: `--spec`, then implement)
- Author each crossing as hand-tal using the ref bank for exact numbers/layouts.
  **E30 (fd-passing) is the hard one** — "structs at the floor": build msghdr +
  cmsghdr in a byte cell (multi-byte little-endian stores — a shared tal
  vocabulary addition every future struct crossing needs, edge 6).
- E51: an extern→sys-tal binding table (chirality data); link-at-load walks it;
  dispatch executes the tal function; `bridge.verify` re-seats on the sys-tal
  return; `impl_ports.py` demoted to migration fallback, then deleted.
- Wire the existing manas orchestrator onto the self-hosted transport.

## Conformance gate
- Each linked crossing produces byte-identical observables to the `impl_ports`
  path across the existing suite (differential; the reference machine performs
  the real syscall).
- `chirality verify`'s frozen-port-set sees the same crossing names before/after.
- The manas orchestrator runs over ollama/llama.cpp (OpenAI-compatible HTTP) on
  the self-hosted transport — the runtime-floor demo.

## Audit obligation
Regen every ref bank (`python3 examples/refs/gen-*.py`) and confirm deterministic
output. Verify the `fd-view` privilege is expressible ONLY inside the
sysface-marked bridge. Verify the linear Fd threads back on every result arm
(the E51 double-use audit).

## Feeds
The runtime-floor self-host demo (the product wedge). Lane 5 folds this into the
full self-host.
