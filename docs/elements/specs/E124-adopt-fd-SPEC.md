---
element: E124
slug: adopt-fd
title: `adopt-fd`: introduce a raw `I64` fd into the linear `Fd` porttype so an already-open fd (e.g. from `openat`/`open-rw`) becomes a move-only cap that must be closed exactly once. Because `Fd` erases to `nt-i64` (E123), adoption is a RUNTIME NO-OP (identity on the word) — the only substance is the surface introduction form + its effect/capability posture (adopting ambient authority into the cap discipline). The cheapest native cap PRODUCER: with E107's `fd-close` row it yields a native cap round-trip (`adopt-fd (openat …) → fd-close → exit 42`), proving carrier+acquire+release below the type layer WITHOUT the ~M socket-acquisition layer. Unblocks verifying E107's held close rows
kind: BUILD-PROPER
example: examples/E124-adopt-fd.md
status: audited
updated: 2026-08-12
---

# E124 SPEC — `adopt-fd`: introduce a raw `I64` fd into the linear `Fd` porttype so an already-open fd (e.g. from `openat`/`open-rw`) becomes a move-only cap that must be closed exactly once. Because `Fd` erases to `nt-i64` (E123), adoption is a RUNTIME NO-OP (identity on the word) — the only substance is the surface introduction form + its effect/capability posture (adopting ambient authority into the cap discipline). The cheapest native cap PRODUCER: with E107's `fd-close` row it yields a native cap round-trip (`adopt-fd (openat …) → fd-close → exit 42`), proving carrier+acquire+release below the type layer WITHOUT the ~M socket-acquisition layer. Unblocks verifying E107's held close rows

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** a pure `(extern adopt-fd (-> I64 Fd))` primitive exists in
  `lib/ports/ports.chiral` and lowers to the identity on its carrier word, so
  an already-open raw `I64` fd can be re-typed into the linear `Fd` cap — closing
  the loop `open-rw (I64) → adopt-fd (Fd, quantity 1) → fd-close`, where the
  checker now forces the adopted fd to be closed exactly once and rejects
  drop / double-close / use-after-move.
- **Non-goals:** no syscall / no crossing (adoption is pure — no `crossing-wraps`
  row, no new TAL body); no errno/validity check on `raw` (`adopt-fd` is trusted
  by design); no *gated* `RawFdAuthority`-consuming variant (§3.2, §6); no
  register-alias / passthrough `NInstr` optimization (§3.3, §6); no sibling
  `adopt-*` for other porttypes (`Sock`/`Clock`/…).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E124 postdates the CONFORMANCE-MAP snapshot;
  treat as **BUILD** (bundle §3: "E124 postdates the map snapshot; treat as BUILD").
  E123 already lowers the `Fd` carrier (committed afea68d), so the value-level
  identity is settled fact, not respec.
- **Live code this composes with (do NOT respec):**
  - `lib/ports/ports.chiral` — `(porttype Fd)` (:14), `(extern fd-close (=> (1 f Fd) Unit))` (:80),
    `(extern open-rw (=> Bytes I64))` (:154, the raw-fd source). The `adopt-fd`
    line lands beside `fd-close`.
  - `lib/lowering/compile-front.chiral` — `porttype-word?` already lists `Fd` (:35-36),
    so `term->ntalty` peels `Fd → nt-i64` (:46-48, E123); `prim->n`/`prims->n`
    (:242-254) already accept a pure `->` prim whose domains/codomain peel to
    `nt-i64`, so `(adopt-fd raw)` becomes `i-prim dst "adopt-fd" [raw] nt-i64`
    with NO front-half change.
  - `lib/lowering/tal/erase.chiral` — `prim2lib-table` (:110-123) with the pure
    re-type precedent `("str->bytes" "nb-id")` and `("bytes->str" "nb-id")` (:118);
    `prim2lib` lookup (:124); `erase-prim` (:137-153) whose fifth rung is the
    `prim2lib` `n-call` and whose final fall-through is
    `xi-err "prim not in native subset: <op>"` (:153).
  - `lib/lowering/tal/bytes.chiral` — `nb-id` identity body `(ti-fn "nb-id" 1 1 (ti-ret 0))`
    (:23), one-in/one-out, returns its argument register. Already ships; no new body.
- **True delta:** exactly two lines — one `extern` in `ports.chiral`, one
  `prim2lib-table` row `(pair "adopt-fd" "nb-id")` in `tal-erase.chiral`. The
  front-half peel and the `nb-id` body already exist; without the `prim2lib` row
  `erase-prim` would reject `adopt-fd` at :153. No new backend shape.

## 3. Decisions

Every open question from the example §6, dispositioned. RESOLVED only when
derivable from a settled artifact (cited); DEFERRED to a named home; NEEDS-AUTHOR
surfaced, never silently answered. All four here resolve or defer — no blocker.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Introduction form: pure extern vs `=>` crossing vs checker cast? | **RESOLVED** | Pure `(-> I64 Fd)` primitive extern lowered via the existing `prim2lib` identity path (`adopt-fd → nb-id`). Precedent: `str->bytes`/`bytes->str` are pure re-types on a shared carrier mapping to `"nb-id"` (tal-erase.chiral:118), where `nb-id` is the one-in/one-out identity body `(ti-fn "nb-id" 1 1 (ti-ret 0))` (bytes-tal.chiral:23). Membrane: no syscall → empty row → `->` (possession without exercise, example §4). **Rejected** the `=>` crossing + `crossing-wraps` row + `nb-adopt-fd` body — membrane-wrong (there is no syscall to cross); and the checker-level cast form — more machinery than a boundary-owned extern type needs. Must be a *primitive* because the opaque porttype admits no surface constructor from `I64` (`(lam (x) x)` fails: `x : I64 ≠ Fd`). |
| 2 | Capability posture under no-ambient-authority: is trusted adoption acceptable? | **RESOLVED (trusted) + DEFERRED (gated variant)** | `adopt-fd` is a **trusted category-C primitive** — the chirality analogue of Rust `unsafe from_raw_fd`: it mints *possession* without *exercise* (holding a cap ≠ crossing the membrane), so it is membrane-consistent, matching the `env-open` INTERIM ambient-acquisition precedent (`(extern env-open (=> Unit Env))`, ports.chiral:121 — authority admitted at one named seam). Named tension: adopting a bare `I64` introduces authority without a cap gating it. **DEFERRED** — a gated variant consuming a `RawFdAuthority`/`Env`-style cap (so even adoption must be handed its authority) is the honest no-ambient-authority follow-on; surfaced in §6, not dropped, out of scope for the cheap cap-producer. |
| 3 | Identity via an `nb-id` call vs a zero-cost register-alias? | **RESOLVED (`nb-id`) + DEFERRED (passthrough)** | Lower through `prim2lib → nb-id` now: correct, precedented, one `n-call` to a one-instruction body. A literal zero-cost register-alias would need `erase-prim` taught a passthrough case, but **no register-move `NInstr` exists today** (verified against `erase-prim`, tal-erase.chiral:137-153 — the fall-through emits `xi-err`, there is no move op). Adding one is an optional later optimization, not needed for correctness. **DEFERRED** to §6. |
| 4 | E107 coupling: the positive round-trip needs `fd-close`, whose row is uncommitted. | **RESOLVED (couple to E107)** | Verified: `crossing-wraps.chiral:38` (`fd-close → nb-sys-close`) is in the working tree but **absent from HEAD** (`git show HEAD:…/crossing-wraps.chiral` has no `fd-close` row). So E124's **positive** conformance (`adopt-fd → fd-close → exit 42`) lands **together with E107's rows as one native-cap-proof unit**. The **untypeable-negative** checks (drop / double-close / use-after-move) depend only on the checker + the `adopt-fd` extern and **stand alone** without E107. Owner: E107 (`[[E107]]`). |

No NEEDS-AUTHOR items; `status: draft` stands (frontmatter unchanged).

## 4. Change plan (ordered, commit-sized)

Two lines, one logical commit (the extern is inert until the erase row lowers it,
so they ship atomically). Coupled with E107 for the positive gate (§5).

### Step 1 — surface the `adopt-fd` extern
- **Target:** `lib/ports/ports.chiral` — beside `(extern fd-close …)` (:80).
- **Change:** add `(extern adopt-fd (-> I64 Fd))` with a comment: pure re-type of
  an already-open raw fd into the linear `Fd` cap; trusted (caller vouches the fd
  is open and theirs, category-C); no crossing → `->`. `Fd` is already in
  `porttype-word?`, so the E123 carrier peel needs no change.
- **Size:** ~XS (one line).

### Step 2 — wire the identity lowering
- **Target:** `lib/lowering/tal/erase.chiral` — `prim2lib-table` (:111-123).
- **Change:** add the row `(pair "adopt-fd" "nb-id")` alongside the
  `str->bytes`/`bytes->str → nb-id` rows (:118). This routes `erase-prim`'s fifth
  rung to a `n-call adopt-fd → nb-id` instead of falling to
  `xi-err "prim not in native subset: adopt-fd"` (:153). No new TAL body (`nb-id`
  ships at bytes-tal.chiral:23). No `crossing-wraps` row (pure, not a crossing).
- **Size:** ~XS (one row).

### Step 3 — self-hosting reblob gate (compiler sources touched)
- **Target:** none (verification only). `ports.chiral` and `tal-erase.chiral` are
  blob-resident compiler sources, so after promoting the new binary, re-run it
  over the same blob and `cmp` byte-for-byte (B1-compiling-B1 fixpoint) — it must
  reproduce itself.
- **Size:** ~XS (one command, ~1s).

## 5. Conformance gate

- **Golden behavior (positive, coupled to E107):** the native cap round-trip

  ```chirality
  (def main (lam (_)
    (let ((raw (open-rw (str->bytes "/dev/null\0"))))   ; raw : I64  (acquire)
      (let ((fd (adopt-fd raw)))                          ; fd  : Fd, quantity 1 (adopt — this element)
        (case (fd-close fd)                               ; release (E107) — consumes fd once
          (unit (exit 42)))))))
  ```

  B1-compiled and run, observing **exit code 42** — proving carrier (E123) +
  acquire (`open-rw`) + adopt (E124) + release (E107) below the type layer,
  without the `~M` socket-acquisition layer.
- **Golden behavior (negative, stands alone — no E107):** three variants must
  **fail to typecheck** —
  - `(let ((fd (adopt-fd raw))) (exit 42))` — REJECTED: `fd` dropped (linear unused);
  - `(case (fd-close fd) (unit (case (fd-close fd) …)))` — REJECTED: `fd` used twice;
  - use of `fd` after it moved into `fd-close` — REJECTED: spent binder.
  (Aliasing the raw `I64` — `(adopt-fd raw)` twice — is legal at the `I64` layer;
  the discipline only begins at `Fd`, so that is not a negative.)
- **Tests to add:**
  - a positive sample under `scaffold/tests/` (sibling to `test_e106_linear_cap.py`
    / `test_fd_passing.py`) — compile-and-run on the **native floor**, assert exit 42.
    Lands with E107.
  - a negative-space check — the three untypeable variants rejected by the checker
    (chirality floor); stands alone, independent of E107's uncommitted row.
- **Green line:** judge on the **native floor + the round-trip**, not the stale
  704-function python baseline. The gate is (a) the reblob `cmp` self-hosting
  fixpoint passes (Step 3), (b) the positive sample exits 42 once E107's rows are
  present, (c) the three negatives fail to check. ledger-lint clean.
- **Done when:** `adopt-fd (open-rw "/dev/null") → fd-close → exit 42` runs to
  exit 42 under a B1-built binary (with E107), the reblob byte-compares identical,
  and the three linearity negatives are rejected by the checker.

## 6. Residue & links

- **Deliberately unbuilt:**
  - **Gated adoption variant** consuming a `RawFdAuthority`/`Env`-style cap so
    that even adoption is handed its authority — the honest close of the
    no-ambient-authority crack (§3.2). Home: a follow-on element / the cap-model
    docket; not this cheap cap-producer.
  - **Zero-cost register-alias passthrough** — teaching `erase-prim` a move-free
    passthrough case (needs a register-move `NInstr` that does not exist today,
    §3.3). Home: an optional backend optimization, `tal-erase.chiral` / lowspec.
  - **Sibling `adopt-*` introducers** for other word-carried porttypes
    (`Sock`/`Clock`/`Timer`/…) — same mechanism, out of scope here.
- **Follow-on:** unblocks verifying E107's held `fd-close`/`sock-close` rows via a
  cheap native round-trip; a template for adopting any `porttype-word?` cap.
- **Related:** [[E124-adopt-fd]] (the drafted example), [[E123]] (the `Fd → nt-i64`
  carrier this rides), [[E107]] (`fd-close` release — the coupled positive-gate
  dependency), [[E122]] (the `Pool n` indexed-carrier sibling left off
  `porttype-word?`), `docs/pattern-boundary-sums.md` (the raw-`I64` → fd-ok/fd-err
  parse a robust caller applies before adopting).
