---
element: E28
slug: mmap-crossings
title: `mmap`/`munmap`/`mprotect`/`close` as sys crossings
kind: REPLACE-CRUTCH
example: examples/E28-mmap-crossings.md
status: audited
updated: 2026-07-27
---

# E28 SPEC — `mmap`/`munmap`/`mprotect`/`close` as sys crossings

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** the sys-tal syscall floor (`scaffold/lib/sys-tal.chiral`)
  carries two new raw crossings — `nb-sys-mprotect` (syscall nr 10, 3 args:
  addr/len/prot) and `nb-sys-close` (syscall nr 3, 1 arg: fd) — built on the
  same `tfn`+`ti-sys` pattern as the seven existing crossings, added to
  `sys-lib`, and **differentially green byte-for-byte across the native x86-64
  floor and the TalMachine reference floor**. This completes the four
  memory/fd crossings on the chirality-side floor and satisfies E20's `mprotect`
  dependency.
- **Non-goals (residue in §6):** the full typed Category-C `Map`/`Prot`/`MapR`
  linear-capability face in `lib/mem.chiral` (example §4–5 — its erased-`Prot`
  proof is unsettled, the zeroize obligation homed at E56 — decisions #2/#3);
  page-alignment arithmetic on `base`/`len`; the W^X loader swap of `native.py`
  off ctypes `_mprotect` (that is E20's REFACTOR, now *unblocked* by this run,
  not part of it); `MAP_SHARED`/file-backed refactor; per-errno decoding beyond
  raw `I64`; touching the Python port impls (`_poolclose`/`_fdclose`) — the
  crutch stays until E51/E20 retire it.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** E28 is **EXTEND**, not BUILD. The authoritative
  row: *"Built + membrane-sound for present crossings
  (write/read/lseek/memfd/ftruncate/mmap/munmap); E21 arena done; **missing
  mprotect, close** … Add mprotect/close = same tfn+ti-sys pattern into
  existing slot. mprotect also unblocks E20."* The W^X-loader REFACTOR row is
  explicitly *"unblocked by E28 mprotect"* — downstream, out of scope here. The
  E51 linkage row is a forward BUILD gated on E28 — also downstream.
- **Live code this composes with (do NOT respec):**
  - `scaffold/lib/sys-tal.chiral` — the seven built crossings. Pattern is fixed:
    `nb-sys-munmap` = `(tfn "nb-sys-munmap" 2 3 (t-seq (ti-sys 2 11 (cons 0 (cons 1 nil))) (t-ret 2)))`
    (arity, temp-count = arity+1, `ti-sys <arity> <nr> <arg-regs>`, result temp = arity).
    `nb-sys-mmap` (nr 9, 6 args, regs 0–5) and `nb-sys-ftruncate` (nr 77) are
    the closest analogs. `sys-lib` is the cons-list registry of all crossings.
  - `scaffold/chirality/tal.py` — `_sys(nr, args)` executes the crossing; `check_fn`
    sets `TalFn.sysface = True` on any body reaching the sys face, and the floor
    refuses non-`nb-sys-*` sysface functions (confinement invariant).
  - `scaffold/chirality/native.py` — compiles each `TFn` to x86-64; the syscall
    lowering already emits `nr` as an immediate + the register bank.
  - `scaffold/tests/test_native.py` — the differential harness:
    `self.compiled["nb-sys-*"](...)` (native floor) vs
    `machine.call("nb-sys-*", ...)` (reference floor); the sysface invariant
    test (`test_native.py:383`) asserts `fn.sysface == name.startswith("nb-sys-")`
    for *every* fn — it will cover the two new names automatically.
  - `scaffold/chirality/impl_ports.py` — `_fdclose` (line 224), `_poolclose` (205),
    `_poolcreate`/`_poolwrite` bind the pool/fd at the **Python port membrane**.
    This is the REPLACE-CRUTCH target for later (E51/E20); **untouched here** —
    the raw crossing is a separate, lower layer.
- **True delta:** two new `TFn` defs + two `sys-lib` entries in
  `sys-tal.chiral`, plus two differential test pairs in `test_native.py`. No new
  Python port impl; no `native.py`/`tal.py` mechanism change (the syscall
  lowering and `ti-sys`/`sysface` plumbing already handle any nr/arity).

## 3. Decisions

Every open question from example §6, dispositioned. The scope decision (#0) is
added because the example's §4–5 typed face over-reaches the authoritative
EXTEND verdict, and the note gating this run pins the delta to the two raw
crossings.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 0 | Does E28 build only the raw crossings (mprotect/close), or also the full typed `Map`/`Prot`/`MapR` linear face of example §4–5? | **RESOLVED — raw crossings only** | CONFORMANCE-MAP E28 row is **EXTEND**: *"Add mprotect/close = same tfn+ti-sys pattern into existing slot."* The typed linear face is a larger Category-C bridge whose proof mechanics are unsettled (#2/#3); it is residue (§6), not the committed gate. Keeps the run from respeccing built crossings or overbuilding. |
| 1 | Does `seal-exec` returning a *fresh* `Map` (not mutate-in-place) confuse a later JIT that cached the old base? | **RESOLVED** | Answered in example §6: no — same `base`, so the address is stable; only the type changes. Applies only to the deferred typed face; non-blocking. |
| 2 | How is the zeroize-on-drop obligation expressed — a special `munmap` variant, or a general linear-`drop` hook? | **RESOLVED (author, 2026-07-27) → neither; homed at E56 (custody)** | Resolved by refraction, not by picking a side: "Zeroed-on-drop and secret custody are *not* a memory feature — they are the custody modules" (`docs/banks/memory.md` cross-cut C5). The obligation is a per-datum custody **type obligation** owned by **E56** (memory custody / zeroize-as-type-obligation; `docs/memory-model.md` commitment 5), with zeroize-to-the-floor as E56's named residue (spills/DSE can break the semantics promise — bank Shard 9). The discipline libraries already own zeroize-on-close at the semantics level (`mem-drop`, bank Shard 4). E28's deferred typed face owes only that its drop path routes through the discipline libs — no `munmap` variant, no kernel `drop` hook. |
| 3 | Must the memfd `Fd` outlive the `Map`? Encode the ordering, or leave it to the pool wrapper? | **RESOLVED → DEFERRED to pool wrapper** | Example §6 answers: the `Fd` does not need to outlive the `Map` once mapped. For the raw floor, `nb-sys-close` is an independent crossing that encodes **no** Map/Fd ordering; any ordering is the typed-face/pool-wrapper's job (deferred with #2). |
| 4 | What `prot` bitmask value seals a page executable for the `mprotect` test? | **RESOLVED** | Linux ABI: `PROT_READ 1 \| PROT_EXEC 4 = 5` (RX); `PROT_READ 1 \| PROT_WRITE 2 = 3` (RW), per the `nb-sys-mmap` comment convention already in `sys-tal.chiral`. Mechanical test constant, not a design call. |

No decision blocks §4: #2 is resolved (homed at E56) and the deferred
ordering (#3) lives entirely in the deferred typed face. The EXTEND is
fully specifiable and unblocked.

## 4. Change plan (ordered, commit-sized)

### Step 1 — add the two raw crossings to the sys-tal floor
- **Target:** `scaffold/lib/sys-tal.chiral` — new `nb-sys-mprotect` and
  `nb-sys-close` `TFn` defs (place beside `nb-sys-munmap`), and extend the
  `sys-lib` cons-list to register both.
- **Change (adapting the built pattern verbatim):**
  ```chirality
  ; mprotect(addr, length, prot) -> 0 (or -errno): change page protection.
  ; W^X pattern is map RW -> fill -> mprotect RX. nr 10; args rdi rsi rdx.
  (def nb-sys-mprotect TFn
    (tfn "nb-sys-mprotect" 3 4
      (t-seq (ti-sys 3 10 (cons 0 (cons 1 (cons 2 nil))))
        (t-ret 3))))

  ; close(fd) -> 0 (or -errno): release an fd; the memfd side of the pool.
  ; nr 3; one arg in rdi.
  (def nb-sys-close TFn
    (tfn "nb-sys-close" 1 2
      (t-seq (ti-sys 1 3 (cons 0 nil))
        (t-ret 1))))
  ```
  then `(cons nb-sys-mprotect (cons nb-sys-close … ))` at the head of `sys-lib`.
- **Size:** S. (temp-count = arity+1; result temp = arity; syscall nrs 10/3 —
  all matching the existing `munmap`/`ftruncate` shape; no plumbing change.)

### Step 2 — differential tests across both floors
- **Target:** `scaffold/tests/test_native.py` — two native/reference pairs
  alongside the existing `test_native_mmap_anonymous_page` /
  `test_reference_mmap_agrees`.
- **Change:**
  - `test_native_mprotect_seals_rx` + `test_reference_mprotect_agrees`: anon
    `mmap` RW page (`prot 3`) → `nb-sys-mprotect(ptr, 4096, 5)` returns `0` on
    both floors → `munmap`. Assert byte-identical results
    (`self.compiled[...]` vs `machine.call(...)`).
  - `test_native_close_memfd` + `test_reference_close_agrees`: `memfd` fd →
    `nb-sys-close(fd)` returns `0` on both floors → a follow-up
    `nb-sys-lseek(fd, 0, 0)` returns the same `-EBADF` sentinel on both floors
    (closed-fd observable agrees).
- **Size:** S.

### Step 3 — confirm confinement + registry (no new code)
- **Target:** `scaffold/tests/test_native.py:383` sysface invariant (iterates
  every fn) — verify it now marks `nb-sys-mprotect`/`nb-sys-close` as
  `.sysface` (they reach `ti-sys`) and that no non-`nb-sys-*` fn does.
- **Change:** none if the invariant test already enumerates `sys-lib`; if it
  hard-codes names, add the two. Confirm `sys-lib` length grew by 2.
- **Size:** XS.

## 5. Conformance gate

- **Golden behavior:** `nb-sys-mprotect` and `nb-sys-close` produce
  **byte-identical** syscall results (`0` on success, the same `-errno`
  sentinel on failure) on the native x86-64 floor and the TalMachine reference
  floor. The `mmap` RW → `mprotect` RX (prot 5) → `munmap` sequence agrees
  across floors; the `memfd` → `close` → `lseek`-returns-`-EBADF` sequence
  agrees across floors. Both new names are marked `.sysface` (confinement
  invariant holds); the frozen Python port set in `impl_ports.py` is
  **unchanged** (no new `@impl`).
- **Tests to add:** `test_native_mprotect_seals_rx` /
  `test_reference_mprotect_agrees`; `test_native_close_memfd` /
  `test_reference_close_agrees`. Each pair differentially compares the native
  compiled floor against the TalMachine reference floor.
- **Green line:** 281 → ≥ 285 test functions (2 pairs); the existing sysface
  invariant test (`test_native.py:383`) stays green with two new `nb-sys-*`
  entries; `ledger-lint` clean.
- **Done when:** `sys-lib` carries `nb-sys-mprotect` (nr 10) and `nb-sys-close`
  (nr 3), both floors agree byte-for-byte on all four memory/fd crossings, and
  the E28 CONFORMANCE-MAP row is eligible to flip EXTEND → CONFORMS (E20's
  `mprotect` dependency thereby satisfied).

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - Typed Category-C `Map`/`Prot`/`MapR` linear-capability face in
    `lib/mem.chiral` (example §4–5) — home: an E28 **follow-on** on a new lib
    file; blocked on the erased-`Prot` proof indexing (the zeroize obligation
    is E56's — decision #2, resolved 2026-07-27; the face's drop path routes
    through the discipline libs). Not part of the committed EXTEND.
  - Page-alignment arithmetic on `base`/`len`, and the `len > 0` /
    `off >= 0` refinements — home: refinement-types module (already built for
    I64 bounds; wiring is the typed-face follow-on).
  - W^X loader swap of `native.py` off ctypes `_mprotect` onto
    `nb-sys-mprotect` — home: **E20 REFACTOR**, now *unblocked* by this run.
  - `MAP_SHARED`/file-backed mappings, per-errno decoding — home: E51 sys
    linkage / later.
- **Follow-on (this unblocks):** E20 (W^X loader mprotect swap), E51
  (orchestration self-host sys linkage — transport replacement), E30 (fd-passing
  — reuses `nb-sys-close` + the linear-cap discipline).
- **Related:** [[E28-mmap-crossings]] (example), [[E20]] (W^X loader, unblocked),
  [[E51-sys-linkage]] (forward BUILD gated on E28), [[E30-fd-passing]],
  [[E26-alarms]] (result-sum error model), [[E21]] (self-hosted arena — the
  completed mmap/munmap half this extends).
