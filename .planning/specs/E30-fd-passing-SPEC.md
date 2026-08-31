---
element: E30
slug: fd-passing
title: fd passing: `sendmsg`+`SCM_RIGHTS` (`sock-send-fd`) — the hard one
kind: REPLACE-CRUTCH
example: examples/E30-fd-passing.md
status: audited
updated: 2026-07-25
---

# E30 SPEC — fd passing: `sendmsg`+`SCM_RIGHTS` (`sock-send-fd`) — the hard one

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.
>
> **Unblocked 2026-07-25.** Decision #1 (the shared "structs at the floor"
> tal-store vocabulary) is **RESOLVED — library composition** by the edge-6
> finding (`docs/open-edges.md`, shaped 2026-07-24: the floor is *thin*;
> "structs at the floor" is composition over `ti-bput`, not new `ti-put-*`
> primitives) **verified against code** (`nb-pack32` already byte-decomposes a
> *runtime* value and stores it via `ti-bput` — see §3 decision #1). Step 1 is
> now a `bytes-tal.chiral` helper family touching no floor and no checker; the
> TCB-expansion that was the genuinely author-tier part of the old NEEDS-AUTHOR
> is moot. All six sections are contract-complete.

## 1. Deliverable

- **After this runs:** an open file descriptor moves to a peer process across a
  connected `AF_UNIX` socket through a native `sendmsg(2)` + `SCM_RIGHTS`
  crossing built entirely at the sys floor — `lib/sys-tal.chiral` gains
  `nb-sys-send-fd`, which packs a `msghdr`/`cmsghdr` in byte cells at the ref's
  exact offsets and issues syscall 46 — so `sock-send-fd` no longer routes
  through CPython `socket.send_fds`. The `Fd` is linearly consumed on success
  (the kernel truly moved it) and returned to the sender only on error.
- **Non-goals:** the receive side (`recvmsg` 47 + `CMSG_FIRSTHDR`/`CMSG_DATA`
  extraction — the dual); multi-fd control messages (`n*4` payload); the
  `runtime.py`/binding-table dispatch that swaps the live referent from Python
  to the tal (that is the E51 transport lane); `MSG_CMSG_CLOEXEC` recv-side
  policy. All residue in §6.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** the sole E30 row is under **Category C port
  membrane** (P3), **CONFORMS / S**: `ports.chiral` already declares the linear
  porttypes `Sock`/`LSock`/`Fd`, `impl_ports.py` binds host referents, and
  linearity + the frozen porttype set are checker-enforced. The map's clause
  "CPython transport→sys-face **without touching decls**" scopes the **E51**
  transport swap; it is not a claim that this element's error-shape correction
  (decision #4) leaves the `sock-send-fd` return type fixed.
- **Live code this composes with (do NOT respec):**
  - `scaffold/lib/ports.chiral:39` — `(extern sock-send-fd (=> (1 s Sock) Bytes (1 f Fd) Sock))` already declared (today returns bare `Sock`, consumes `Fd` unconditionally); linear `Fd` porttype at line 14.
  - `scaffold/lib/sys-tal.chiral` — the sys-floor pattern is built and proven: `nb-sys-write`/`read`/`lseek`/`memfd`/`ftruncate`/`mmap`/`munmap`, all via `ti-sys`, collected in `sys-lib`. `nb-sys-mmap` already uses all 6 arg registers; `nb-sys-write` already does `ti-bptr` address discipline.
  - `scaffold/lib/tal-ir.chiral` — the tal vocabulary in use: `ti-bnew`, `ti-bput` (**single-byte** store), `ti-bget`, `ti-blen`, `ti-bptr`, `ti-const`, `ti-sys`, `ti-call`, `ti-prim`, `ti-con`/`ti-cona`, `ti-lit`.
  - `scaffold/lib/bytes-tal.chiral:136` — `nb-pack32`/`nb-pack16`: the existing little-endian pack idiom. Note it allocates a **fresh** cell and writes bytes `[0..k)` via `%`/`/` + single `ti-bput`; it does **not** store a word at a computed offset into a pre-existing cell, and it cannot store a runtime pointer.
  - `scaffold/chirality/impl_ports.py:156` — `_socksendfd` (the `socket.send_fds` crutch being retired as transport, by E51 not here).
- **True delta:** (a) a **multi-byte store-at-offset** library helper family (`u32`/`u64`/`ptr` into an existing fresh cell) — a generalization of the `nb-pack32` idiom, **not** a floor addition (decision #1, library route); (b) the `msghdr`(56B)+`cmsghdr`(24B control buffer)+`iovec`(16B) byte-layout builder at the ref's offsets; (c) the `nb-sys-send-fd` crossing issuing `sys 46`; (d) the `SendFdR` result sum + the `sock-send-fd` decl reshaped to return it (decision #4).

## 3. Decisions

Every open question from the example §6, dispositioned. RESOLVED only when
derivable from a settled doc/principle (cited); genuine substrate/scope
commitments go to NEEDS-AUTHOR and are surfaced, never silently answered.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | **"structs at the floor" tal-store vocabulary** (edge 6): how does the floor store `u32`/`u64`/`ptr` at a computed offset into an existing cell? New first-class `ti-put-*` store-word opcodes across all 3 floors + the typed-assembly checker, OR library composition over `ti-bput`? And does it land inside E30 or as a prerequisite foundational element? | **RESOLVED — library composition** | **Edge 6** (`docs/open-edges.md`, shaped 2026-07-24): the floor is *thin*; "structs at the floor" is library composition over `ti-bput`, **not** new `ti-put-*` primitives — the "irreducible floor" framing was named an altitude error. **Verified against code:** `nb-pack32` (`scaffold/lib/bytes-tal.chiral:136`) already decomposes a **runtime** value — `slot0 % 256`, where `slot0` is the fn argument — into bytes via runtime `ti-prim "%"/"/"` and stores each with `ti-bput`; the store index is an ordinary I64 slot, so computed offsets and full 8-byte words compose identically. The old fact-(a) claim that `ti-put-ptr` "cannot be `%`/`/`-decomposed at compile time" **conflated compile-time with runtime** — a runtime arena address from `ti-bptr` decomposes at runtime exactly as `nb-pack32`'s runtime input does. So **no new primitive and no TCB expansion** — the trusted-`tal-ir`-core commitment that was the genuinely author-tier part of the old NEEDS-AUTHOR is **moot**. Principle 6 seals it: a store-word helper carries no invariant `ti-bput` lacks, so a new trusted opcode would be pure overhead. Step 1 is a `bytes-tal.chiral` helper family (`nb-put-u32`/`nb-put-u64`/`nb-put-ptr`), touching no floor and no checker; it lands inside E30 (no foundational-element split needed). |
| 2 | **fd consumption matches kernel truth exactly** — success moves the fd (gone), a failed send did NOT move it (still the sender's). | **RESOLVED** | The possession facet — edge 16, settled 2026-07-21 (`chirality-effect-decision`; the two-facet membrane where "move" is a literal kernel operation) — plus QTT linearity (`Fd` is quantity-1). Realized by the `SendFdR` sum: the `sfd-err` arm returns `(1 f Fd)`, the `sfd-ok` arm does not. Linear discipline and kernel behavior then agree by construction; the negative test (recover + reuse the fd after `EMFILE`/`EPIPE`) is the conformance point (§5). |
| 3 | **pointer store / arena address materialized as i64 in a cell** — `ti-bptr` yields the address; storing it into `msg_iov`/`msg_control` needs a word store. | **RESOLVED** (via decision #1) | The ptr store is a runtime decomposition — `ti-bptr` → runtime `ti-prim "%"/"/"` → 8× `ti-bput` at `off+k` — packaged as `nb-put-ptr`, **not** a primitive. No compile-time obstruction: the address is a runtime register value decomposed at runtime, exactly like `nb-pack32`'s runtime input. (User-space `mmap` addresses are non-negative i64, so Euclidean `%`/`/` reconstructs the little-endian bytes correctly — the same assumption `nb-pack32` already relies on.) |
| 4 | **decl reshape** — the example returns `SendFdR` (fd recoverable on error); `ports.chiral:39` currently returns bare `Sock` (fd dropped unconditionally). | **RESOLVED** (deliberate EXTEND) | The bare-`Sock` decl is a linearity lie on the error path: a failed `sendmsg` does not move the fd, yet the current signature consumes it with no return — an unrecoverable leak of a linear resource. `SendFdR` is required for decision #2's soundness. This is an EXTEND of the crossing's error shape, **not** the E51 transport swap the map's "without touching decls" clause governs; the frozen set is the *porttypes* (`Sock`/`Fd`), which are untouched. New `data SendFdR` added; `Fd` porttype unchanged. |
| 5 | **binding-table / `runtime.py` dispatch** wiring `sock-send-fd` → `nb-sys-send-fd`, retiring `_socksendfd`'s `socket.send_fds`. | **DEFERRED → E51** | The map files transport swap explicitly in the E51 sys-linkage lane ("Transport swap is E51 lane, not a reshape"). E30 builds and tests `nb-sys-send-fd` against the reference machine; E51 flips the live referent. |
| 6 | **recvmsg dual** (47 + `CMSG_FIRSTHDR`/`CMSG_DATA` extraction) and **multi-fd** control (`n*4`, `CMSG_LEN(4n)`/`CMSG_SPACE(4n)`). | **DEFERRED** (residue, §6) | Same ref, mirror offsets; the recv side is its own crossing. Out of this run's one-crossing scope. |

## 4. Change plan (ordered, commit-sized)

All five steps are contract-complete against `refs/ref-fdpass.md`. Step 1 is a
`bytes-tal.chiral` helper family (decision #1 RESOLVED — library composition); the
interface Steps 2+ consume — `nb-put-u32 cell off val`, `nb-put-u64 cell off val`,
`nb-put-ptr cell off addr` — is a `bytes-tal.chiral` addition, no floor or checker
touched.

### Step 1 — "structs at the floor": multi-byte store-at-offset  *(library, per decision #1)*
- **Target:** `scaffold/lib/bytes-tal.chiral` — new store-at-offset helpers generalizing the `nb-pack32` idiom to write into an already-allocated cell at a computed offset. **No floor, no typed-assembly checker change.**
- **Change:** little-endian store-at-computed-offset for `u32`, `u64`, and a raw pointer word into an existing fresh byte cell — `nb-put-u32`, `nb-put-u64`, `nb-put-ptr` — each a runtime `%`/`/` byte-decomposition + `ti-bput` at `off+k`. `nb-put-ptr` decomposes the i64 arena address a register holds (from `ti-bptr`) the same way. Writes into a fresh, not-yet-frozen cell, mirroring `ti-bput`'s existing discipline.
- **Size:** ~S–M (library only — the `nb-pack32` idiom generalized; no cross-floor payload).

### Step 2 — `SendFdR` result sum + decl reshape
- **Target:** `scaffold/lib/ports.chiral` — new `data SendFdR`; edit the `sock-send-fd` extern at line 39.
- **Change:** add `(data SendFdR () (sfd-ok (1 s Sock)) (sfd-err (errno I64) (1 s Sock) (1 f Fd)))`; change line 39 to `(extern sock-send-fd (=> (1 s Sock) Bytes (1 f Fd) SendFdR))`. Per decision #4.
- **Size:** ~S

### Step 3 — the control cell (`cmsghdr`, `CMSG_SPACE(4)` = 24 bytes)
- **Target:** `scaffold/lib/sys-tal.chiral` — new `nb-sys-send-fd` (body, part 1).
- **Change:** `ti-bnew` a 24-byte cell; store, at the ref's offsets — `cmsg_len` `u64@0 = 20` (`CMSG_LEN(4)`), `cmsg_level` `u32@8 = 1` (`SOL_SOCKET`), `cmsg_type` `u32@12 = 1` (`SCM_RIGHTS`), fd `u32@16` (the arg-register fd int).
- **Size:** ~S

### Step 4 — the iovec (16B) + the `msghdr` (56B)
- **Target:** `scaffold/lib/sys-tal.chiral` — `nb-sys-send-fd` (body, part 2).
- **Change:** iovec cell (16B): `nb-put-ptr @0` = `ti-bptr` of the payload cell, `u64@8` = its `ti-blen`. msghdr cell (56B), connected socket (name null): `u64@0 = 0` (msg_name), `u32@8 = 0` (msg_namelen), `nb-put-ptr @16` = `&iovec` (msg_iov), `u64@24 = 1` (msg_iovlen), `nb-put-ptr @32` = `&control-cell` (msg_control), `u64@40 = 24` (msg_controllen = `CMSG_SPACE(4)`), `u32@48 = 0` (msg_flags).
- **Size:** ~M

### Step 5 — the crossing + collection
- **Target:** `scaffold/lib/sys-tal.chiral` — `nb-sys-send-fd` (tail) and `sys-lib`.
- **Change:** `ti-sys 46` with args `(sockfd, ti-bptr &msghdr, 0)` (flags 0); return the syscall result register (bytes sent, or `-errno` for the upper `SendFdR` mapping). Sysface-mark the def. Append `nb-sys-send-fd` to `sys-lib`.
- **Size:** ~S

## 5. Conformance gate

- **Golden behavior:** an fd sent from `nb-sys-send-fd` over a real `socketpair`, received on the peer, names the **same open file** as the sender's original — `fstat` `st_ino`/`st_dev` match — and the ordinary iovec payload arrives byte-identical. The reference machine performs the *same* real `sendmsg`, so native and reference are checked against one kernel (the discipline the existing `write`/`mmap` sys slices already use).
- **Tests to add** (`scaffold/tests/test_tal.py` and/or `test_process_externs.py`):
  1. **send-fd roundtrip, differential** — `nb-sys-send-fd` over a `socketpair`; recv the fd on the peer (test-side `recvmsg`); assert `st_ino` match + payload byte-identical; assert byte-for-byte agreement of the built control+msghdr cells vs a reference `sendmsg` construction. Compares reference-machine floor vs the kernel.
  2. **error-path fd recovery (the point of decision #2)** — provoke a failing send (e.g. `EPIPE` after peer close, or `EMFILE`); assert the crossing yields `sfd-err` **and** the linear `Fd` is returned and reusable (a subsequent op on it succeeds). A leak or double-consume here fails the linear check.
  3. **store-word unit** — `nb-put-u32`/`nb-put-u64`/`nb-put-ptr` at offsets into a cell produce the exact little-endian bytes / address the ref specifies (guards the Step 1 library helpers independently of the syscall).
- **Green line:** 281 test functions (22 files) → **≥ 284**; `ledger-lint` clean.
- **Done when:** a fd passed by `nb-sys-send-fd` across a `socketpair` names the same open file on the peer (st_ino match, payload identical), a failed send returns the fd recoverable via `sfd-err`, and the store-word bytes match the ref — all green against the reference machine.

## 6. Residue & links

- **Deliberately unbuilt:**
  - **recv side** — `recvmsg` (47) + `CMSG_FIRSTHDR`/`CMSG_DATA` extraction; its own crossing, mirror offsets from the same ref. Home: a recv-dual element (nobody's yet; sibling of E30).
  - **multi-fd control** — `n*4` payload, `CMSG_LEN(4n)`/`CMSG_SPACE(4n)`; the ref's macros already parameterize on `n`. Home: extension of `nb-sys-send-fd`.
  - **live transport swap** — `runtime.py`/binding-table `sock-send-fd` → `nb-sys-send-fd`, retiring `_socksendfd`. Home: **E51** (decision #5).
  - **`MSG_CMSG_CLOEXEC`** recv-side policy. Home: the recv-dual element.
  - **general struct-builder ergonomics** — a typed ABI-layout abstraction over the `nb-put-*` helpers (offsets/field types named once instead of hand-placed) is the natural follow-on. Edge 6's open call on this was **RESOLVED 2026-07-26 (Batch A): mint it — now element E75** (catalog §XI; a typed layout-descriptor + refinement bounds, re-seated by the bridge, giving E70's preserve-check a layout spec to check against); E30 uses the raw `nb-put-*` helpers directly and does not need it. Home: **E75**.
- **Follow-on unblocked:** the tomodachi/compositor path (E21 Pool memfd reaches the compositor *only* through `sock-send-fd`); every future struct crossing (decision #1's vocabulary is the shared substrate).
- **Related:** [[E30-fd-passing]] · [[E51-sys-linkage]] (binding table + `fd-view` this rides; decision #5) · [[E29-sockets]] (the socket the fd crosses) · [[E21-arena]] (the memfd/Pool whose fd this shares) · [[E70-effectful-lowering]] (the row shadow naming this crossing) · [[E28-mmap-crossings]] (sibling struct-free sys slices) · `refs/ref-fdpass.md` (the ABI) · edge 6 "structs at the floor" (decision #1) · edge 16 possession facet (`chirality-effect-decision`, decision #2).
