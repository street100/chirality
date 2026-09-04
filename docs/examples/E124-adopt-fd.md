---
element: E124
slug: adopt-fd
title: `adopt-fd`: introduce a raw `I64` fd into the linear `Fd` porttype so an already-open fd (e.g. from `openat`/`open-rw`) becomes a move-only cap that must be closed exactly once. Because `Fd` erases to `nt-i64` (E123), adoption is a RUNTIME NO-OP (identity on the word) — the only substance is the surface introduction form + its effect/capability posture (adopting ambient authority into the cap discipline). The cheapest native cap PRODUCER: with E107's `fd-close` row it yields a native cap round-trip (`adopt-fd (openat …) → fd-close → exit 42`), proving carrier+acquire+release below the type layer WITHOUT the ~M socket-acquisition layer. Unblocks verifying E107's held close rows
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: drafted
updated: 2026-08-12
---

# E124 — `adopt-fd`: introduce a raw `I64` fd into the linear `Fd` porttype so an already-open fd (e.g. from `openat`/`open-rw`) becomes a move-only cap that must be closed exactly once. Because `Fd` erases to `nt-i64` (E123), adoption is a RUNTIME NO-OP (identity on the word) — the only substance is the surface introduction form + its effect/capability posture (adopting ambient authority into the cap discipline). The cheapest native cap PRODUCER: with E107's `fd-close` row it yields a native cap round-trip (`adopt-fd (openat …) → fd-close → exit 42`), proving carrier+acquire+release below the type layer WITHOUT the ~M socket-acquisition layer. Unblocks verifying E107's held close rows

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E124, `adopt-fd` — a primitive that introduces an already-open raw
  `I64` file descriptor (from `open-rw`/`openat`) into the linear `Fd` porttype,
  minting a move-only capability that the checker forces to be closed exactly once.
- **Kind:** BUILD-PROPER — no raw→porttype introducer exists today. `ports.chiral`
  has only *acquisition* crossings (`sock-connect`, `pool-create`, `open-rw`); each
  either performs a syscall that hands back a fresh port, or (like `open-rw`) returns
  a bare `I64`. There is no way to take a bare `I64` you already hold and re-type it
  into the cap discipline.
- **Why chirality needs its own:** it is the cheapest native **cap producer**. E123
  (afea68d) made `Fd` erase to `nt-i64` — the underlying fd word — so adoption is a
  pure re-type with an *identity* lowering. Paired with E107's `fd-close` release row
  it gives a full carrier+acquire+release round-trip
  (`adopt-fd (open-rw …) → fd-close → exit 42`) that exercises the whole linear-Fd
  cap machinery below the type layer, WITHOUT the heavy socket-acquisition (`~M`)
  layer. It is also the honest home for "adopt ambient authority into the discipline"
  — the one place raw fd ownership crosses into the cap world.

## 2. Research

- **Reference class:** OURS — `lib/ports/ports.chiral` (the `porttype`/`extern`
  floor: `Fd` at :14, `fd-close` at :80, the `sock-connect`/`open-rw` acquisition
  precedents), `lib/lowering/compile-front.chiral:27-43` (E123: `porttype-word?` →
  `term->ntalty` peels `Fd` to `nt-i64`), `lib/lowering/tal/crossing-wraps.chiral:36-38`
  (the E107 `fd-close`/`sock-close`/`lsock-close → nb-sys-close` release rows). The
  external framing is POSIX/Rust raw-fd ownership.
- **Key findings:**
  1. **`Fd` and `I64` share one carrier.** `porttype-word?` lists `Fd`, so
     `term->ntalty` peels *both* `Fd` and `I64` to `nt-i64`
     (compile-front.chiral:51-54). At the machine layer `adopt-fd` is therefore the
     *identity on a word* — nothing to compute, the raw register already IS the fd.
     **How a pure `->` extern actually lowers (traced against live code):** the
     front peel accepts it (`prim->n`/`prims->n`, compile-front.chiral:242-254 — both
     `I64` and `Fd` peel to `nt-i64`, so `adopt-fd` joins the prim table and the call
     `(adopt-fd raw)` becomes `i-prim dst "adopt-fd" [raw] nt-i64`), but the BACK-half
     erase boundary decides the code. `erase-prim` (tal-erase.chiral:137-153) resolves
     a pure prim's *name* in strict precedence: `op-parse` (the closed `Op` sum,
     prelude.chiral:26-29 — arithmetic/bit ops only) → `bget` → `blen`/`str-len` →
     `prim2lib-table` (a `n-call` into the byte library) → else the hard error
     `xi-err "prim not in native subset: <op>"`. `adopt-fd` is in none of the first
     four, so **as of today it does NOT lower — it falls to that error.** The
     shipping path that DOES lower a pure re-type identity is the fourth rung: a
     `prim2lib-table` row. Directly precedented — `str->bytes` and `bytes->str`
     (also pure re-types on a shared carrier) map to `"nb-id"` (tal-erase.chiral:118),
     and `nb-id` is a real one-in/one-out identity TAL body, `(ti-fn "nb-id" 1 1
     (ti-ret 0))` (bytes-tal.chiral:23), that returns its argument register. So
     `adopt-fd` rides the *existing* mechanism: one `prim2lib-table` row
     `(pair "adopt-fd" "nb-id")` (or a readably-named sibling) — a pure `n-call`,
     **no crossing, no `crossing-wraps` row, no membrane cost.** It pays one call to
     `nb-id`; a literal-zero-cost register-alias would additionally need `erase-prim`
     taught a passthrough case (no register-move `NInstr` exists today), but that is
     an optional optimization, not a prerequisite.
  2. **`Fd` is an opaque linear atom.** `porttype` teaches the kernel only that the
     value exists and is B-typed, so any binder holding it is quantity `1`
     (ports.chiral:3-8). No surface term constructs an `Fd` from an `I64` — the
     re-type MUST be a primitive whose type is owned at the boundary.
  3. **The release row is uncommitted.** `crossing-wraps.chiral:36-38` (`fd-close →
     nb-sys-close`) is in the working tree but NOT in `HEAD` (verified: committed
     `crossing-wraps.chiral` has no `fd-close` row). The E124 conformance round-trip
     depends on that row, so E124's sample lands together with E107 (or uses a
     crossing whose row is already committed).
  4. **No crossing = pure.** By the effect membrane's two facets, `adopt-fd` changes
     *possession* (a fresh linear `Fd` comes into being) but performs no *exercise*
     (no syscall). Its honest effect row is empty → `->`.

## 3. Conventional (other-language) approach

Outside chirality, adopting a raw fd is an ownership convention the compiler cannot check
— canonically Rust's `FromRawFd`:

```rust
// SAFETY: caller asserts `raw` is open and that this File now OWNS it.
let file: File = unsafe { File::from_raw_fd(raw) };
// ...use...
// drop(file) closes it — but nothing forces exactly-one close, and
// double-adopting the same raw fd (aliasing) compiles fine.
```

- **Assumptions it bakes in:** ownership is a *comment* (`// SAFETY:`), enforced only
  by an `unsafe` block and programmer discipline. Nothing at the type level forbids
  (a) forgetting to close (leak), (b) closing twice / double-adopting the same raw fd
  (use-after-free, fd reuse races), or (c) using the fd after it moved. The
  "must close exactly once" invariant lives in prose, not in the signature.

## 4. The chirality idea

- **Chirality features in play:** QTT linearity (`Fd` is quantity-`1`, used exactly
  once); the effect membrane's possession-vs-exercise split (`->` empty row vs `=>`);
  ports & the no-ambient-authority posture; category **C** (a typed cap over a
  B-untrusted referent, governed by a caller vouch); the E123 shared `nt-i64` carrier.
- **The reframing.** `adopt-fd` is a **pure `(-> I64 Fd)` primitive extern** whose
  type is owned at the boundary and whose lowering is the *identity on the carrier
  word*. The `unsafe`/comment obligation is split cleanly:
  - the part chirality CAN'T check — "this raw `I64` really is an open fd you own" — is a
    **caller vouch at a category-C boundary** (the fd came from a syscall the kernel
    owns; it is B-untrusted). `adopt-fd` is the *trusted primitive* that admits it.
  - the part chirality CAN check — "closed exactly once, never used after move" — becomes
    a **type guarantee** the instant the word enters `Fd`: linearity forces exactly
    one `fd-close`, runtime-free.
- **Effect posture.** Adoption performs no crossing, so the row is empty → `->`. It
  mints *possession* without *exercise*. This is the load-bearing membrane call: a
  cap can come into being without a syscall (E123 already justified the value-level
  identity — the word is the fd), so the introducer stays pure.
- **What chirality makes impossible here:** the three Rust failure modes above are all
  *untypeable* once adopted — drop is rejected (linear unused), double-close/reuse is
  rejected (linear used twice), use-after-move is rejected (the binder is spent). The
  only freedom chirality keeps is the irreducible one: vouching that the raw word was a
  real, owned fd — and that is named and localized at exactly one primitive.

## 5. Chirality example (fleshed)

```chirality
(import "prelude")
(import "ports")            ; Fd, fd-close, open-rw

; ── the introducer ──────────────────────────────────────────────────────────
; PURE re-type: I64 (a raw, already-open fd) -> Fd (a move-only cap).
; No crossing (no syscall), so the row is EMPTY (->). E123 makes Fd erase to
; nt-i64, so the lowering is the identity on the carrier word: the raw register
; already IS the fd. TRUSTED: the caller vouches the fd is open and theirs
; (category-C boundary, POSIX/Rust `from_raw_fd`) — chirality cannot check that, but
; it CAN, and does, force "closed exactly once" from here on.
(extern adopt-fd (-> I64 Fd))

; ── the cap round-trip (conformance) ─────────────────────────────────────────
; open-rw : (=> Bytes I64)     — raw fd | -errno   (ambient authority)
; adopt-fd: (-> I64 Fd)        — re-type into the cap discipline  (this element)
; fd-close: (=> (1 f Fd) Unit) — release = close(fd)              (E107)
(declare main (=> I64))
(def main (lam (_)
  (let ((raw (open-rw (str->bytes "/dev/null\0"))))   ; raw : I64
    ; Boundary-sums note: a robust caller parses `raw` into an fd-ok/fd-err sum
    ; (raw >= 0 ?) BEFORE adopting; adopt-fd itself is trusted and does not check.
    (let ((fd (adopt-fd raw)))                          ; fd : Fd, quantity 1
      (case (fd-close fd)                               ; consumes fd exactly once
        (unit (exit 42)))))))                           ; golden exit code

; ── why the alternatives don't typecheck (the guarantee) ─────────────────────
;   (let ((fd (adopt-fd raw))) (exit 42))               ; REJECTED: fd dropped (linear unused)
;   (case (fd-close fd) (unit (case (fd-close fd) ...))) ; REJECTED: fd used twice
;   (let ((a (adopt-fd raw)) (b (adopt-fd raw))) ...)   ; two caps, each must close once —
;                                                        ;   aliasing the raw word is legal at
;                                                        ;   the I64 layer (the trusted seam);
;                                                        ;   the DISCIPLINE only starts at Fd.
```

- **Knobs to modify:** the porttype minted (any word-carried cap in
  `porttype-word?` — `Sock`/`Clock`/`Timer`/… could take a sibling `adopt-*`); the
  raw source (`openat`, an inherited fd, a `dup`'d fd); whether the caller parses the
  raw `I64` into an fd-ok/fd-err sum before adopting.
- **Deliberately omitted:** the errno/validity check on `raw` (adopt-fd is trusted by
  design); any *gated* variant that would require a `RawFdAuthority` cap (deferred —
  see §6); the socket-acquisition layer (the whole point is to skip it).

## 6. Use / modify notes

- **Lands in:** (1) `lib/ports/ports.chiral` — one `extern adopt-fd (-> I64 Fd)`
  line beside `fd-close`; `Fd` is already a member of `porttype-word?`
  (compile-front.chiral:39), so the E123 carrier peel needs no change. (2)
  `lib/lowering/tal/erase.chiral` — one `prim2lib-table` row `(pair "adopt-fd"
  "nb-id")` (beside the `str->bytes`/`bytes->str → nb-id` rows at :118), so the pure
  prim reaches its identity lowering instead of the `"prim not in native subset"`
  fall-through. No new TAL body is required (`nb-id` already ships, bytes-tal.chiral:23).
- **Conformance target:** the native round-trip
  `adopt-fd (open-rw "/dev/null") → fd-close → exit 42` compiled by B1 and run,
  observing exit code 42 — proving carrier (E123) + acquire (open-rw) + adopt (this)
  + release (E107) below the type layer. **Gate coupling:** the `fd-close →
  nb-sys-close` row is uncommitted in `HEAD`, so E124's sample must land *together
  with* E107 (recommended), or the negative-space tests (drop/double-close are
  untypeable) stand alone while the positive round-trip waits on E107's commit.

- **SIZE verdict: XS.** One `extern adopt-fd (-> I64 Fd)` line (`Fd` carrier already
  done by E123) **plus one `prim2lib-table` row** mapping `adopt-fd → nb-id`
  (tal-erase.chiral:118 / bytes-tal.chiral:23). It is NOT a new backend shape: the
  pure-re-type-to-identity path already ships — `str->bytes`/`bytes->str` lower the
  identical way (pure `->` extern → `prim2lib` → the `nb-id` identity body). The whole
  substance is the one-row wiring + the membrane/posture decision, not code volume;
  add the E107 coupling for the positive gate. (An earlier draft sized this at S for a
  "new backend shape"; the traced lowering shows the shape is precedented, so XS.)

- **RESOLVED — introduction form.** A **pure `(-> I64 Fd)` primitive extern** lowered
  via the **existing `prim2lib` identity path** (`adopt-fd → nb-id`). Rationale:
  (a) it fits the membrane honestly — no crossing, so an empty row / `->`, matching
  possession-without-exercise; (b) E123 proves the value-level identity
  (`Fd = nt-i64 = I64`), and the backend *already lowers a pure re-type identity*:
  `str->bytes`/`bytes->str` map through `prim2lib-table` to `nb-id`, a one-in/one-out
  body returning its argument register (`(ti-fn "nb-id" 1 1 (ti-ret 0))`,
  bytes-tal.chiral:23) — `adopt-fd` rides the identical mechanism with a single
  `prim2lib-table` row; (c) it must be a *primitive* (extern), because the opaque
  porttype admits no surface constructor from `I64` — a plain `(lam (x) x)` would not
  typecheck (`x : I64 ≠ Fd`); the checker owns the re-type at the boundary.
  **Rejected candidates:** a **process `(=> I64 Fd)` crossing + a `crossing-wraps`
  row + an `nb-adopt-fd` TAL body** — *wrong on the membrane* (it is not a crossing;
  there is no syscall), and unnecessary now that the pure `prim2lib` path is shown to
  ship; and a **checker-level cast form** — more machinery than a single
  boundary-owned extern type needs. **What the spec still fixes (small):** the erase
  boundary today *rejects* a pure prim it does not recognise (`erase-prim` falls to
  `xi-err "prim not in native subset: adopt-fd"`, tal-erase.chiral:151-153), so the
  spec must add the `prim2lib-table` row (reuse `nb-id`, or introduce a readably-named
  identity sibling). Optionally, a literal-zero-cost register-alias would teach
  `erase-prim` a passthrough case — a pure optimization, out of scope for the cheap
  cap-producer.

- **RESOLVED — capability / no-ambient-authority posture.** `adopt-fd` is a
  **TRUSTED primitive**, the chirality analogue of Rust's `unsafe from_raw_fd`: the caller
  vouches the raw fd is open and theirs, a **category-C** boundary over a B-untrusted
  referent that the kernel cannot check. This is the ONE place raw ambient authority
  is minted into the cap discipline, so it is named and localized on purpose. **Named
  tension:** adopting a bare `I64` introduces authority without a capability gating it
  — a small crack in no-ambient-authority. **Deferred follow-on:** a *gated* variant
  that consumes a `RawFdAuthority` (or `Env`-style) cap so that even adoption must be
  handed its authority — the honest path to closing the crack, but out of scope for
  this cheap cap-producer. Surfaced for the spec as a known residue, not a blocker.

- **Linearity (confirmed).** The §5 round-trip shows adopt→close consuming the `Fd`
  exactly once; dropping it (linear unused), closing it twice / using it after move
  (linear used twice / spent binder) are all **untypeable**. The runtime cost of the
  guarantee is zero — it is discharged entirely at check time.

- **Related:** [[E123]] (the `Fd → nt-i64` carrier this rides), [[E107]] (`fd-close`
  release — the coupled release row and positive-gate dependency), [[E122]] (the
  `Pool n` indexed-carrier sibling deliberately left off `porttype-word?`),
  `docs/pattern-boundary-sums.md` (the raw-`I64` → fd-ok/fd-err parse a robust caller
  applies before adopting).
