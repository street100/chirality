# NATIVE-CAP-LIFECYCLE-MAP — what "native caps" actually requires

**Written 2026-08-12, grounded in live code.** Produced after the E107 native
re-run surfaced that the E106 `sv-drain` milestone was gated three layers deep
(close → carrier → acquisition). This maps the *whole* arc at once so we sequence
it deliberately instead of discovering the next gap at each build.

## The model

A chirality cap is a **porttype** — an opaque linear atom (`Sock`/`LSock`/`Fd`/`Pool n`/
`Clock`/`Timer`/`Env`, `ports.chiral:12-101`). To run a cap program **natively**,
four stages must all lower:

**carrier → acquire → use → release**

- **carrier** — the backend runtime representation of the porttype value.
- **acquire** — the crossing that *produces* a cap (returns a porttype).
- **use** — crossings that read/write through the held cap.
- **release** — the crossing that *consumes* the cap exactly once (close).

The type-level discipline (move-only, exactly-once, opacity) is **fully built and
sound** in the checker — that is real and is the crown jewel. What was mostly
unbuilt is the **native emission** of the lifecycle below the type layer.

## State matrix (grounded, cited)

| Cap | carrier | acquire | use | release |
|-----|---------|---------|-----|---------|
| **Sock / LSock** | ✅ E123 `→ nt-i64` (`compile-front.chiral`, committed afea68d) | ❌ `sock-connect`/`listen`/`accept` **oracle-only** (`impl_ports.py:142+`); **no** `nb-sys-socket`/`connect`/`bind`/`listen`/`accept` TAL (grep-clean) | 🟡 `sock-send`/`recv` oracle-only, but `nb-sys-write`/`read`/`send-fd` TAL **exist** (`sys-tal.chiral:18,39,366`) → rows only | 🟡 E107 rows **ready** (held), lower via E123 — but unverifiable until a producer exists |
| **Fd** | ✅ E123 `→ nt-i64` | ❌ no `adopt-fd` (raw `I64→Fd`); `open-rw` returns raw `I64`, not `Fd` | 🟡 `nb-sys-read`/`write` exist → rows | 🟡 E107 `fd-close` row ready (held) |
| **Pool n** | 🟡 routes `t-tcon → nt-data` cell path (`compile-front.chiral:34,55`); needs E122's `[base\|size]` cell impl | 🟡 `pool-create` — **E122 audited** (memfd→ftruncate→mmap, native) | 🟡 `pool-write`/`read` — E120/E113 | 🟡 `pool-close` — E120 body + E107 pool-close row (W2) |
| **Clock/Timer/Env** | ✅ E123 `→ nt-i64` | — (no crossing-wraps rows; carrier-completeness only) | — | — |

Legend: ✅ built · 🟡 partial / ready-but-gated · ❌ unbuilt.

## The elements (sized, dependency-ordered)

| # | Element | Stage | Size | State | Note |
|---|---------|-------|------|-------|------|
| **E123** | porttype word-carrier | carrier | S | ✅ **DONE** (afea68d) | `Sock/LSock/Fd/Clock/Timer/Env → nt-i64` |
| **E124** *(propose)* | `adopt-fd` (raw `I64 → Fd`) | acquire | **XS-S** | unbuilt | runtime no-op (`Fd=I64`); the **cheapest native cap producer** |
| **E107** | sock/lsock/fd-close rows | release | S | ready (held) | verifiable the moment *any* producer lands |
| **E125** *(propose)* | `sock-send`/`recv` rows | use | S | unbuilt | rows over existing `nb-sys-write`/`read`/`send-fd` |
| **E126 / E29-native** *(propose)* | socket acquire | acquire | **M** | unbuilt | `socket`/`connect`/`bind`/`listen`/`accept` TAL + `sockaddr_un` packing + `ConnR`/`LisR`/`AccR` assembly. **The E106 `sv-drain` milestone's true gate.** |
| **E122** | native `pool-create` | acquire (pool) | M | audited | + Pool cell-carrier |
| **E120** | pool write/read/close | use+release (pool) | M | specced | W2 |
| **T7 / T8** | pty adopt / I/O | full (pty) | M/L | type-level | later |

## Two milestone paths — the key strategic fork

The E106 milestone was framed as one small step. In reality:

- **Cheap native-cap-lifecycle PROOF (Fd path): E124 + E107 ≈ S total.**
  `adopt-fd` an `openat`'d fd → `fd-close` it → **native exit 42**. This proves
  carrier + acquire + release end-to-end *without* the socket layer, using the
  no-op Fd carrier. It's the honest minimal "native caps work" demonstration.
- **Full E106 `sv-drain` (Sock path): needs E126/E29-native ≈ M.**
  `sv-drain`'s sample acquires via `sock-connect`, so it specifically needs the
  socket acquisition layer (syscalls + `sockaddr_un`). Not reachable until E126.

**Recommended spine:** E123 ✅ → **E124 (adopt-fd, S)** → **E107 (close, ready)** →
*minimal native cap round-trip lands (exit 42)* → E125 (sock use, S) → **E126
(socket acquire, M)** → *E106 `sv-drain` milestone lands*. Pool rides its own
E122 → E120 track in parallel.

## Roadmap corrections this forces

1. **The Wave-1 milestone was mis-stated.** "E106 `sv-drain` runs native (exit 42)"
   is an M-element-away Sock-path milestone, not a 3-crossing-row finish. Retarget
   Wave-1's *native-cap proof* to the **Fd adopt→close** path (E124+E107); keep the
   `sv-drain` milestone tied to E126.
2. **E107's SPEC §5 contradicts its own §6** (§5 milestone needs acquisition; §6
   scopes acquisition out). Fix §5 to the Fd-path proof.
3. **E29 (sockets) is oracle-only** — its native leg (E126) is a real unbuilt M
   element, not implied-done. The `numeric-width` / LEDGER should reflect this.
4. E107's rows stay **held** until E124 gives them a verifiable producer.

## What is genuinely solid (credit)

The whole **type-level** cap discipline (linear move-only, exactly-once-close,
opacity, the checker negatives) is built and enforced — verified this session
(the E107 re-run confirmed double-close / drop-without-close stay checker-rejected).
E123 (carrier) is done and proven discriminating. The gap is purely the native
emission of acquire/use for the fd-backed caps — bounded, sized above, no longer
a mystery.
