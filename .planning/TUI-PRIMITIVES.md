# TUI-PRIMITIVES — the primitives chirality owes the TUI stack

The canonical checklist of language/substrate primitives the terminal ecosystem
needs, derived from `TUI/PRIMITIVE-AUDIT.md`. **These land BEFORE the TUI stack
(T6–T19) proper.** Each runs the pipeline (worked-example → audit → spec → audit →
implement), dispatched one at a time (SERIAL — never a parallel batch).

Authority for the gap analysis is `TUI/PRIMITIVE-AUDIT.md`; this file is the
worklist + status + the dependency map the examples uncovered.

## ✅ DONE (the two structural NEEDs, cleared this session)

- [x] **UTF-8 decoder** — `TUI/vt-core/utf8.chiral` (RFC 3629), exit 42; T5 deduped onto it.
- [x] **Linear cap collection** — **E106** `scaffold/lib/lincoll.chiral` (`SockVec`),
  full pipeline + implemented + verified.

## ✅ LAYER-1 IMPLEMENTS LANDED — frontier is now Layer 2 (2026-08-12)

The Layer-1 primitives are **built this session** (all compiled by B1, self-host
fixpoint re-confirmed byte-identical after T7 touched `ports.chiral`):

- **`FMT·E112` APC side-channel** — IMPLEMENTED (63db11f): structured netstring-over-APC
  codec + content-hash block-id + decode wiring.
- **`EF·E42` supervisor v1** — IMPLEMENTED (784639a): supervised `poll` loop +
  alarm-as-crossing (coarse-`=>` form; typed form still gated on `EF·E26`).
- **`T7` Pty porttype** — IMPLEMENTED (81ec7c6): raw-I64 pty master → linear `Pty`
  cap at the type level; touched `ports.chiral` (fixpoint re-verified).
- **`MEM·E111` cell-store** — IMPLEMENTED (af0a7c8): `Pool`-backed linear `(Grid n)`
  + 16B Cell codec across vt-core.

Residue carried forward (named, not dropped):
- **`FMT·E128` apc-handshake** — spec-audited, implement-**gated on the `Terminal`
  port (T13)** landing (it negotiates the structured bit E112 consumes).
- **`EF·E39` Step-7** (Console effect-row reification) — the only E39 residue; the
  effect-row carrier (steps 1–6) is built. Gates `EF·E26` → `EF·E42`-typed.

**The frontier is now Layer 2 — the T# TUI stack**, which starts from this green,
fully-committed baseline: **T1–T3** core terminal crossings · **T8** session ·
**T9** mux · **T10–T12** surface/backend · **T6** images.

### ⚑ FLAG (Layer-2 to settle) — cross-directory import via `scaffold/lib` symlinks

This session added three symlinks so `TUI/` modules resolve as bare imports from
the `scaffold/lib` libdir the resolver (`bin/chirality-resolve.sh`) walks:

- `scaffold/lib/apc.chiral`     → `../../TUI/apc.chiral`
- `scaffold/lib/render.chiral`  → `../../TUI/scriba/render.chiral`
- `scaffold/lib/session.chiral` → `../../TUI/session/session.chiral`

They exist because the resolver has a single flat libdir plus a parent-relative
lookup, and `(import "apc"/"render"/"session")` from a `scaffold/lib` module (or
a cross-tree sample) otherwise finds nothing under `TUI/`. **This is a
resolver-design decision Layer 2 should settle** — the import resolver arguably
should resolve `TUI/` sub-tree paths (namespaced imports / a search-path list)
directly, rather than papering the gap with symlinks that duplicate the module's
apparent home. Not fixed here (no resolver rewrite in a closeout); flagged so it
isn't lost.

## ✅ WAVE-1 COMPLETE + NATIVE-CAP ARC (2026-08-12 session)

**All Wave-1 elements committed + self-hosted:** `CG·E108` shr/sar (85b59af) ·
`CG·E109` bput-u16-le (1b13fe1) · `SYS·E121` fcntl (6bc75ba) · `SYS·E110` O_CLOEXEC
(26202c2) · `SYS·E107` sock/lsock/fd-close (82092f5). E121 was pulled into W1 so
E110's cloexec flip landed *verified*.

**The E106 `sv-drain` native milestone was underscoped — found + cleared.** It was
gated three layers deep, not a 3-row finish (see `NATIVE-CAP-LIFECYCLE-MAP.md`). The
native cap lifecycle (**carrier → acquire → use → release**) was mostly unbuilt below
the type layer. Built this session:
- **`CG·E123`** porttype word-carrier (`Sock/Fd/… → nt-i64` in `term->ntalty`, afea68d).
- **`SYS·E124`** `adopt-fd` (raw `I64→Fd`, identity via `prim2lib→nb-id`) + **`SYS·E107`**
  close rows → **native cap lifecycle PROVEN** (adopt→close→exit 42, 82092f5).
- **`SYS·E126`** native `socketpair` (nr 53, `SockPairR`, first hand-authored `ti-cona`
  / native boxed-sum-returning crossing) → **E106 `sv-drain` MILESTONE LANDED**:
  `socketpair → sv-push×2 → sv-drain → native exit 42`, two real connected caps, no
  peer (9d17b3b). Self-host fixpoint 840056 B.

**Deferred follow-ons (named, not dropped):** `SYS·E127` sock-connect (real client
networking, non-hermetic; design+ABI complete, `examples/E127`) · `E125` sock-send/recv
(rows over `nb-sys-write`/`read`) · `MEM·E120`/`E122` pool-native track (Pool cell-carrier)
· recoverable-result-sum `pool-create` + `MemCap` gating (boundary-sums / no-ambient-authority).

## ⬜ TODO — the primitives (full scope). All 8 examples DRAFTED + committed (64fcc6f)

The B1-grounded examples corrected several sizes (three are near-trivial; two are
bigger than the catalog implied) and surfaced the deps in the next section. Next per
element: audit → spec → audit → implement (serial).

| # | Element | Real change (from the B1-grounded example) | Home | Reblob-gate | Size | Ex | Open spec decision |
|---|---------|--------------------------------------------|------|-------------|------|----|--------------------|
| 1 | **E108 · shr/sar** | just **2 surface extern lines** — Op/emit/shuttle/fold/erase already wired (Euclidean lowering emits them) | `prelude` | yes | XS | ✓ | none |
| 2 | **E109 · bput-u16-le** | **1 `def`** mirroring `bput-u32-le` (respect `bslice` `[i,j)` end) | `bytes-tal` | yes | XS | ✓ | none |
| 3 | **E110 · O_CLOEXEC** | **1 const flip** `258→0x80102` at `sys-tal:630`; `dup2` clears cloexec so slave survives | `sys-tal` | yes | XS | ✓ | (a1) settled in example |
| 4 | **T7 · Pty/Fd cap** | `(porttype Pty)` + `PtyAcqR`/`PtyReadR`, rework `open-pty` hand-back; typechecks clean (20KB ELF) | `ports` + `TUI/session` | yes | M | ✓ | mint granularity: `adopt-pty` vs `pty-acquire` |
| 5 | **E111 · cell store** | `Bytes` writes **allocate** — real fix is a **`Pool`-backed linear `(Grid n)`** + 16B Cell codec; turns `Grid` a **linear resource** across vt-core | `TUI/vt-core` + `Pool` | no | **L** | ✓ | Grid→linear blast radius; **needs E113 pool-read** |
| 6 | **E107 · cap-close family** | just **`crossing-wraps` lowering pairs** — all 5 externs + `close`/`munmap` TAL already exist | `crossing-wraps` + `sys-linkage` | yes | S | ✓ | `pool-close`→`munmap` needs runtime length, `Pool n` is **erased** |
| 7 | **E42 · alarm-supervisor** | alarms-as-crossings + supervised `poll` loop → `mux-step`; coarse-`=>` form typechecks (29KB ELF) | supervisor lib + `TUI/mux` | some | L | ✓ | **typed form gated on E39→E26** (deps); timer mech (poll/`timerfd`/`ppoll`) |
| 8 | **E112 · APC side-channel** | netstring-over-APC encode/decode + `term-structured?` handshake; round-trips (exit 42) | `TUI/apc` + `render` | no | M | ✓ | block-id scheme; APC-vs-DCS handshake byte |

## Dependencies surfaced by the examples (the map, finished)

Implement-ordering the findings force — this is the part the examples added:

- **E42 (typed form) ⟵ E26 (alarm effect tags) ⟵ E39 (effect row).** E39 and E26 are
  both `audited`. **CORRECTION (E42 audit): E39's effect-row carrier is already BUILT**
  (steps 1–6, per `CONFORMANCE-MAP.md:58` — row in Pi pos-2, `subtype` VPi row-subsumption,
  set-containment gating, call-graph-inferred rows); only Step 7 (Console reification) +
  the handler/subtraction machinery (which rides **E26**) remain. So the typed alarm gates
  on **E26** (audited-unbuilt), not the E39 row. E42's coarse-`=>` form ships now. →
  **implement chain: E26 → E42 (typed); E39 Step-7 reification is the only E39 residue.**
- **E111 ⟵ E113 · pool-read** (NEW — needs an example). The region libs only ever
  write (`pool-write`); there is no read/peek crossing, and the `Pool`-backed Grid
  needs O(1) indexed reads. → **to example (added below).**
- **Pool runtime length (E107 `munmap` + E113 bounds) — RESOLVED (E113 example).** The
  length is NOT lost: a `Pool`'s runtime value is the host tuple `("pool", mm, size)`
  (`impl_ports.py:273`); `pool-write` already bounds-checks against `size` and `pool-close`
  already reads it to `munmap`. Each crossing enforces/consumes the bound host-side; where
  surface code needs the length as a value, reuse the existing `Region.cap` witness
  (`mem-region.chiral:23`). **No new `pool-len` crossing, no length-carrying `Pool`.**
- **Native `pool-*` bindings missing — shared IMPLEMENT dep.** The `Pool` crossings
  (`pool-write`/`pool-read`/`pool-close`) are **Python-oracle-only** (no `crossing-wraps`/
  `sys-linkage` entry), so none lower to native yet. E107, E111, and E113 all need the
  native `pool-*` bindings added at implement — NOT a new example; shared implement work.
- **E106 `sv-drain` ⟵ E107.** `sv-drain` only reaches a native run once `sock-close`
  lowers (E107). E107 is the unblock for E106's runtime leg.
- Minor (non-blocking, worked around in-example): `str->i64` doesn't lower in B1 (E112)
  · `Bytes` ops are functional/allocating, mutation only via `Pool` (E111) · linear
  values thread via `case` not `let`, checker-enforced (T7/E106).

## Things we need to example (updated)

- [x] E108, E109, E110, T7, E111, E107, E42, E112 — drafted (64fcc6f).
- [x] **E113 · pool-read** — drafted; resolved the shared Pool-length question with no
  new primitive (reuse host `size` + `Region.cap`).
- **Prereqs already examized (need IMPLEMENT, not example):** **E39** (effect row —
  carrier BUILT steps 1–6, only Step-7 reification left) · **E26** (alarm tags,
  audited-unbuilt) — E26 gates E42's typed form.

**✅ ALL 9 EXAMPLES AUDITED (reviewed) → ALL 9 SPECCED** (E108/E109/E110/T7/E111/
E107/E42/E112/E113). Example-audit caught a real QTT-legality bug in E111 + a
Pool-length overstatement in E107 + the E39-carrier-built correction in E42. Next
stage: spec-audit → implement (serial).

### Decisions — RESOLVED (2026-08-12)

| # | Element | Resolution |
|---|---------|-----------|
| 1 | E110 | **E121 pulled into W1 beside E110** (both one-liner crossings) so the cloexec flip lands VERIFIED — `fcntl(master, F_GETFD) & FD_CLOEXEC` readback proves the flag took, not just the static flag-word + regression gate. (Was: defer E121 to W4, ship E110 asserted.) |
| 2 | E111 | **Sequence after E113, not defer.** The only gate is the structural dep (`pool-read`=E113, in flight); no "if perf bites" trigger. Committed part of vt-core for the emulator (T17); design turnkey. Lands with the emulator wave right after E113. → Wave 4 (ordering by dep+priority, not a punt). |
| 3 | E42 | **Build `supervisor.chiral` now.** → Wave 3. |
| 4 | E112 | Block-id = **content-hash**; handshake query byte = non-blocking follow-on. |
| 5 | E113 native | Shared native-Pool substrate minted as new element **E120** (E114 was taken by crypto). → Wave 2. |
| 6 | MEM·E120 | Native `pool-create` **SPLIT OUT → new element `MEM·E122`** (author override exercised 2026-08-12). E120 = `pool-write`/`pool-read`/`pool-close` bodies + the `[base\|size]` cell witness; E122 = the mint (memfd→ftruncate→mmap→box). E122 sequences first in W2; E120's round-trip gate conclusively exercises both. **DONE 2026-08-12 (604ce36): both E122 and E120 implemented — native Pool create/write/read/close round-trip; the owed E122 spec-extract is discharged.** |

New elements minted (catalog + LEDGER): **E120** native-Pool write/read/close (MEM/pool),
**E122** native `pool-create` mint (MEM/pool — split from E120, 2026-08-12), **E121**
`fcntl`/`F_GETFD` crossing (SYS/pty — now sequenced in **W1** beside E110). Existing dep:
**E26** typed-alarm (EF — gates E42's *typed* form; unbuilt per CONFORMANCE-MAP, though the
LEDGER coarse-state lags to `built`).

> **Element refs use `CAT·E#`** for core elements (category prefix + stable number,
> per `LEDGER.md`). Side-projects keep their own native prefix (`T#`, `S#`) — already
> namespaced, no `CAT·`. Files/tooling keep the bare number.

## WAVES — build order (each wave's deps satisfied within it or earlier)

- **Wave 1 — trivial completions + fd-close family** · core-blob, one reblob-`cmp`
  `CG·E108` shr/sar · `CG·E109` bput-u16-le · `SYS·E110` O_CLOEXEC **+ `SYS·E121` `fcntl(F_GETFD)`
  readback (pulled into W1 so the E110 flip lands VERIFIED, not asserted)** · `SYS·E107`
  sock/lsock/fd-close. Deps: none. **Milestone: `MEM·E106` `sv-drain` runs native (exit 42).**
- **Wave 2 — the two linear-cap substrates** · core-blob, one reblob-`cmp`
  `T7` Pty porttype + `adopt-pty` + `pty-close` · **`MEM·E122` native `pool-create` (the mint) →
  `MEM·E120` `pool-write`/`pool-read`/`pool-close` bodies** → then `MEM·E113`-native +
  `SYS·E107` `pool-close`-native. Deps: Wave 1. Intra-wave order: **E122 → E120** (E120's
  round-trip gate conclusively exercises both); Pty-def before pty-close. (T7 full pty I/O
  stays type-level; native I/O is T8.)
- **Wave 3 — program libs** · no fixpoint
  `EF·E42` supervisor v1 · `FMT·E112` apc + vt-parser decode. Deps: `MEM·E106`/poll/render/
  vt-parser (all built) — independent of Waves 1–2.
- **Wave 4 — emulator-lane, dep-sequenced (NOT deferred)**
  `MEM·E111` cell-store (gated only on `MEM·E113`; builds when E113 lands) ·
  `EF·E26` typed-alarm (upgrades `EF·E42`). Deps: Waves 1–3.

## SCOPE TRACKER — every block, its pipeline stage + wave

Stages: ex → rev(iewed) → spec → s-audit → impl. Update this table as work lands.

| Element | Wave | Stage | Deps (gating) | Note |
|---------|------|-------|---------------|------|
| CG·E108 shr/sar | 1 | **impl** ✓ | — | 85b59af; self-hosted |
| CG·E109 bput-u16-le | 1 | **impl** ✓ | — | 1b13fe1 |
| SYS·E110 O_CLOEXEC | 1 | **impl** ✓ | — | 26202c2; verified via SYS·E121 |
| SYS·E107 fd-closes | 1 | **impl** ✓ | — | 82092f5; unblocked MEM·E106 native drain |
| SYS·E121 fcntl | 1 | **impl** ✓ | — | 6bc75ba; verified E110's flip in-wave |
| T7 Pty cap | 2 | **impl** ✓ | SYS·E107 pty-close; T8 (full I/O) | additive to `ports.chiral` (`porttype Pty`+`PtyAcqR`/`PtyReadR`+adopt-pty/pty-read/pty-close) + `TUI/session/session.chiral` (`open-pty-cap` mint / `read-once` / `PtyVec`); type-level typechecks via B1, t7_pty_cap exit 42, 4 negatives rejected; `B1<blob` byte-identical (no reblob); native run gated E107/T8; session acquirer named `open-pty-cap` (flat-namespace vs D2-retained term.open-pty) |
| MEM·E122 pool-create | 2 | **impl** ✓ | SYS·E28 | 604ce36; the native mint |
| MEM·E120 pool w/r/c | 2 | **impl** ✓ | MEM·E122, SYS·E28 | 604ce36; native Pool round-trip |
| MEM·E113 pool-read | 2 | **audited** ✓ | — | spec-audit found native pool-read ALREADY SHIPPED by E120 (single-arm `pr-r`, halt-on-OOB); spec conformed. Only residue = optional advisory oracle binding |
| SYS·E107 pool-close | 2 | **impl** ✓ | MEM·E120 ✓ | native leg landed with E120 round-trip |
| EF·E42 supervisor | 3 | **audited** ✓ | MEM·E106 ✓, poll ✓ | v1 coarse; #A resolved "build now"; typed→EF·E26 |
| FMT·E112 APC | 3 | **audited** ✓ | render ✓, vt-parser ✓ | content-hash block-id fully specced; implement-ready |
| FMT·E128 apc-handshake | 3 | **audited** ✓ | FMT·E112 + Terminal port (T13); E31 poll ✓, E32 Clock ✓ | spec-audited; implement-gated on E112 + Terminal port landing; negotiates the bit E112 consumes |
| MEM·E111 cell-store | 4 | **audited** ✓ | MEM·E113 ✓ (audited), MEM·E120 ✓ | both deps met; spec-audit reconciled #5/#6 to shipped (E120/E122/E113); ready to implement when emulator lane picked up; no perf-trigger |
| EF·E26 typed-alarm | 4 | audited | EF·E39 (carrier built) | upgrades EF·E42 → typed |
| MEM·E106 lincoll | ✓ | **impl** ✓ | SYS·E107 ✓ | native `sv-drain`→exit 42 milestone LANDED (9d17b3b via E126) |
| UTF-8 decoder | ✓ | implemented | — | vt-parser consumes it |

**✅ COVERAGE (updated 2026-08-12, post-Wave-1/2-land + E112-audit pass)** — Wave 1
is **fully implemented + self-hosted** (E108/E109/E110/E121/E107, E106 `sv-drain`
milestone proven). Wave 2's Pool substrate is **built** (E122+E120 native round-trip,
604ce36; E107 pool-close rode it); its spec-stage remainder — **T7** and **E113** —
are both **audited** (E113's spec-audit found native pool-read already shipped by E120;
T7 audited with citations refreshed). Wave 3: **E112**, **E128**, **E42** all
**audited** (implement-ready). Wave 4: **E111 audited** (deps E113/E120 met — spec
reconciled #5/#6 to shipped, no perf-trigger), **E26 audited**. **The E122 spec-extract
that used to be owed is discharged** — E120/E122 are implemented. **Every wave element
is now implemented or audited; the next stage across the board is implement.** T7's
native-run follow-ons are filed into E107 (pty-close) + T8 (read/adopt/write/migration);
E128's into T15 (APC responder + feature-bitset).

## Deferred (last two of PRIMITIVE-AUDIT's LONG ROAD — NOT in this worklist)

- Pixel/software-framebuffer + GPU backend (image blit, scene layer).
- Trusted-path indicator + secure-attention gesture + per-layer `LayerCap` split.

## Dispatch discipline

- One element at a time, serial. Example → `--audit example` → `--mark reviewed`
  → `--spec` → `--audit spec` → `--mark audited` → STOP (implement is a separate go).
- Core-blob elements (E108/E109/E110/T7/E107/E113): gate on `B1 < blob | cmp - B1`
  before commit; reblob + promote only if it differs (per `BUGS-AND-GAPS.md`).
- Non-compiler programs (E111/E112/E42-lib): compile-with-B1-and-run, no fixpoint.
- **Implement chains (findings-forced):** E39 → E26 → E42 (typed) · E113 → E111 ·
  E107 → E106 native drain.
