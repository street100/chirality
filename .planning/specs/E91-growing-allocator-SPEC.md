---
element: E91
slug: growing-allocator
title: Growing allocator — check-first grow-retry loop over a reserve-commit arena, single Alloc discipline
kind: BUILD-PROPER
example: examples/E91-growing-allocator.md
status: implemented
updated: 2026-08-10-implemented
---

# E91 SPEC — Growing allocator (CORRECTED)

> **This SPEC was rewritten 2026-08-10 after a six-theory validation pipeline
> (research → repro → adversarial audit → mechanical-fit) established that E91
> was a FALSE SUMMIT across all prior attempts: the growing allocator has never
> grown. The prior SPEC's Decisions #2/#6/#7 and its "E89/E90 already built"
> baseline were materially wrong. This version is the corrected, mechanically-
> certified contract. Implementation follows THIS file.**

## 0. What the validation established (do not re-litigate)

- **E91 growing is UNIMPLEMENTED.** `x-galo`/`x-gbnw` emit `x-trap` (`76 02 0f 0b`,
  `jbe +2; ud2`) — byte-identical to the fixed allocator. The `"arena-grow"`
  label in `x-fin` is DEAD (no `e-call` reaches it) and mis-marshalled. The
  self-host fixpoint (762106B) survives only on a 16 GiB `PRIVATE|ANON|NORESERVE`
  demand-paged arena, not on any grow capability. (Theory E repro + audit.)
- **`nb-arena-grow`/`nb-arena-commit` (sys-tal.chiral) ARE built** (real mprotect
  doubling) but unreachable — nothing emits the call that would invoke the stub.
- **Check-first is already done.** `x-alo`/`x-bnw`/`x-galo`/`x-gbnw` all bound-
  check before any store. No reorder work remains (prior SPEC Step 1/2 = done).
- **Exactly ONE `Alloc` instance may live in the compiler blob.**
  `specialize-singletons` monomorphizes the fn-bearing `Alloc` dict to a single
  instance; two DISTINCT instances hard-error (old gate) or SILENTLY MISCOMPILE
  (current gate `16d6d1a`, `count>=1`). The prior SPEC's "two disciplines side
  by side" is the root error that produced the whole saga. (Theory A + E.)
- **The lowering route is free:** both a bare-ref Mach-field `alloc-growing` AND
  a lambda-wrap `alloc-growing` lower and self-host — `specialize-singletons`
  hoists lambda fields to named globals (`lift-lifted`). **Mach-editing is NOT
  required.** (Theory B2, empirically built.) A working grow path is
  MECHANICALLY POSSIBLE with existing primitives — no missing encoder, no
  register/ABI/W^X/termination obstruction (Theory E mechanical-fit).

## 1. Deliverable

After this runs, the ELF floor's allocator **actually grows**:
- `x-galo`/`x-gbnw` emit a **check-first inline grow-retry loop**: bound-check
  the desired bump against the `heapend` cell; on fit, store + advance `heapptr`;
  on miss, `call` the shared `"arena-grow"` stub, then **re-read `heapend` and
  retry the check** — never `ud2` on the growing path.
- The `"arena-grow"` stub in `x-fin` marshals the REAL callee contract and calls
  `nb-arena-grow`, which `mprotect`-doubles the committed prefix of a `PROT_NONE`
  reservation and publishes the new `heapend`.
- The chirality-side entry stub sets up a **reserve-commit arena**: `mmap PROT_NONE`
  reservation → `mprotect` a committed `INIT_COMMIT` prefix → initialize four
  cells `heapptr`/`heapbase`/`heapend`/`heapreserve`.
- **Gate:** a program allocating past `INIT_COMMIT` grows and completes with the
  correct result; exhaustion past the reservation ceiling is `nb-arena-fail`'s
  clean `exit_group` (fd-2 diagnostic), never `SIGSEGV`/`ud2` on the growing path.

**Non-goals:** in-process JIT / population-editing eval (Theory F — separate
live-environment arc); runtime moduleset dispatch (profiles/staging — separate
arc); thread-safety; multiple growth policies.

## 2. Baseline (honest, verified)

- `scaffold/lib/mach-x64.chiral`: `x-galo` (:509) / `x-gbnw` (:659) exist but end
  in `(a-bytes x-trap)`. `x-fin` (:535) defines an `"arena-grow"` label whose
  body is dead and mis-marshalled (built for an imagined `(heapptr,heapend,
  heapreserve)` signature that never existed).
- `scaffold/lib/sys-tal.chiral`: `nb-arena-grow-t` (:171) `(base, reserve_end,
  need, heapend_cell) -> new_committed_end`; `nb-arena-commit-t` (:133)
  mprotects `[from,to]` PROT_NONE→RW, ceiling-checks `reserve_end < to`
  (fail code 1 → `nb-arena-fail` → `exit_group`), publishes `to` into the cell
  via `nb-put-u64`. **Never returns a negative errno** — every failure exits.
- `scaffold/lib/asm-reloc.chiral`: encoders `e-ldrdi`/`e-ldrsi`/`e-ldrdx`/
  `e-learcx` (RIP-relative loads + lea) are present (added for the stub).
- `scaffold/lib/compile-emit.chiral`: `entry-stub-v2` is the pre-E89 flat map —
  `mmap(PROT_RW, 16 GiB, NORESERVE)`, inits `heapptr`/`heapend` only, **no
  `heapreserve`, no reservation**. `x-fin` emits `heapptr`/`heapend`/
  `heapreserve` labels but **no `heapbase`**.
- `scaffold/chirality/native.py`: `_entry_stub` (:760) is the reserve-commit v3
  reference (mmap PROT_NONE 64 GiB → mprotect 256 MiB → heapptr/heapend/
  heapreserve). `test_entry_stub_matches_native_byte_for_byte` is `@skip` (E89).
- Gate `16d6d1a` relaxed `find-singleton` to `count>=1`. For the single-instance
  design this is unneeded AND dangerous (silent miscompile of any future 2nd
  instance). Revert to a LOUD gate.

## 3. Decisions (corrected against the prior SPEC)

| # | Decision | Corrected resolution |
|---|---|---|
| 2 | grow-stub ↔ `nb-arena-grow` linkage & signature | **CORRECTED.** Real callee is `nb-arena-grow(base=rdi, reserve_end=rsi, need=rdx, heapend_cell=rcx) -> new_end (rax)`, and it **NEVER returns <0** (fails via `exit_group`). The prior SPEC's `(heapptr,heapend,heapreserve)` args and `js fail` branch are WRONG and dead. Stub computes `need = desired_bump − *heapend`, loads `base←heapbase`, `reserve_end←heapreserve`, `heapend_cell←&heapend` (`e-learcx`), calls, `ret`s; `nb-arena-commit` publishes `heapend`. Caller re-reads + retries. |
| 6 | retry mechanism | **Inline rel8 loop (Shape B).** All intra-allocation jumps are short and fixed-size, so displacements are raw `a-bytes`; the ONLY relocation is the single global `e-call "arena-grow"`. No per-site labels → no Decision #1/#7 tension. (`jbe +7` skips the 5-byte call + 2-byte back-`jmp`; `jmp -30` returns to loop top.) |
| 7 | discipline shape | **SINGLE `Alloc` instance** (two-side-by-side is the root error). Wiring route is free — **lambda-wrap (zero Mach) recommended** (revert the unnecessary `mach.chiral` `galo`/`gbnw` fields + `mach-x64` table rows; `alloc-growing` references `x-galo`/`x-gbnw` directly via `(lam (m dst tag fs) (x-galo dst tag fs))`). Register liveness: the retry recomputes `rax`/`rcx`, so the stub may clobber them — **no save/restore needed** (corrects #2's "preserve rcx"). |
| gate | `16d6d1a` | **REVERT to a loud gate** — error when >1 fn-bearing instance reaches the threading path. Single instance specializes under the original `count==1`. |

## 4. Change plan (ordered; A+B+C are interdependent — growth needs all three)

> BUILD RULE: B1 compiles everything; re-fixpoint after every compiler-source
> change; commit per verified unit. Keep `INIT_COMMIT` LARGE during A so it is
> not a regression; verify growth by TEMPORARILY shrinking it; set the target
> last.

### Step A — reserve-commit entry stub (chirality side ⇄ native.py byte-identical)
- `compile-emit.chiral`: rewrite `entry-stub-v2` to mirror `native.py._entry_stub`
  — `mmap(0, RESERVE_BYTES, PROT_NONE, PRIVATE|ANON, -1, 0)` → `mprotect(base,
  INIT_COMMIT, PROT_RW)` → init `heapptr=base`, `heapbase=base`,
  `heapend=base+INIT_COMMIT`, `heapreserve=base+RESERVE_BYTES`. **Honor the
  `48 a3` moffs64/rax hazard** (build each sum in `rax` before the store). Add
  `reserve-bytes`/`init-commit` defs = native.py's `RESERVE_BYTES`/`INIT_COMMIT`.
- `mach-x64.chiral` `x-fin`: add `a-label "heapbase"` + 8-byte zero slot.
- `compile-emit.chiral` `assemble-elf`/`emit-elf`: thread `heapbase`+`heapreserve`
  offsets (today `emit-elf` passes 4 args to a 5-arg `assemble-elf` and looks up
  only heapptr/heapend). Also add `heapbase` init to `native.py._entry_stub`.
- Unskip `test_entry_stub_matches_native_byte_for_byte`. Fixpoint.

### Step B — grow-retry loop in `x-galo`/`x-gbnw`
- Replace `(a-bytes x-trap)` with the inline rel8 loop (Decision #6): `ldheap
  heapptr → lea/size bump → cmpheap heapend → jbe +7 → e-call "arena-grow" →
  jmp retry → (commit) stores → recompute bump → stheap heapptr`. `x-gbnw` uses
  the byte-cell size sequence. Displacements generated/verified programmatically.
  Fixpoint.

### Step C — correct the `"arena-grow"` stub in `x-fin`
- Rewrite the stub body to the corrected marshalling (Decision #2): save regs it
  must, `need = rcx − *heapend`, `base←heapbase`, `reserve_end←heapreserve`,
  `heapend_cell←&heapend` (`e-learcx`), `e-call "nb-arena-grow"`, restore, `ret`.
  Delete the bogus `stheap heapend`. Confirm the caller (`e-call "arena-grow"`)
  and this label are consistent in ONE tree. Fixpoint. **Growth now works.**

### Step D — (recommended) switch to lambda-wrap, revert Mach fields
- `alloc.chiral`: `alloc-growing` fields = `(lam (m dst tag fs) (x-galo dst tag
  fs))` / `(lam (m dst len) (x-gbnw dst len))`. Revert `mach.chiral` `galo`/`gbnw`
  fields + the `mach-x64` Mach-table rows. Fixpoint (byte-identity vs Step C
  expected — same emitted allocator). If churn is judged not worth it, KEEP the
  Mach-field route and skip D (both are valid; D is a simplification).

### Step E — revert the `16d6d1a` gate to loud
- `specialize-singleton.chiral`: restore `(=i (count-inline …) 1)`; better, make
  `>1` a loud error at the threading point. Fixpoint (byte-identical expected —
  single instance is count==1).

### Step F — cleanup + docs
- Delete dead `scaffold/lib/alloc-growing.chiral` (unimported; wrong signature).
- Correct `examples/INDEX.md` E91 row (was a false summit) and this SPEC status.

## 5. Conformance gate

1. Fixpoint reconverges (`gen==gen`) after each compiler-source change.
2. **Growth:** with `INIT_COMMIT` temporarily shrunk (e.g. 256 KiB), a program
   bump-allocating past it GROWS and completes with the correct result — NOT
   `ud2`/SIGILL. (Prior repro: today it SIGILLs at every shrunk size.)
3. **Clean exhaustion:** allocating past `RESERVE_BYTES` exits via
   `nb-arena-fail` (fd-2 message + `exit_group`), never SIGSEGV/`ud2`.
4. Full py suite green (or residuals named); `test_entry_stub_matches_native_
   byte_for_byte` unskipped and passing.
5. `bin/make-public.sh` sync clean (public fixpoint holds).

## 6. Residue & links

- Scoped in-process eval for population-editing (Theory F, `decision-reflective-
  floor.md:46-48`) — unspecified, likely-required, OFF E91's path. Record.
- Runtime modularity via profiles × staging × mesh (built-but-embryonic) — OFF
  E91's path. Record.
- E90-REV `nb-arena-grow`/`nb-arena-commit` already built (sys-tal.chiral) — this
  SPEC only WIRES them.

## 7. Implementation record (2026-08-10 — DONE, independently verified)

E91 is implemented and the growing allocator genuinely grows.

**Commits (on main):**
- `237c1e5` — Step A: reserve-commit entry stub (`entry-stub-v2` chirality ⇄
  `native.py._entry_stub` byte-identical; `heapbase` cell added; `reserve-bytes`/
  `init-commit` defs).
- `1a6be67` — Step E: reverted the `16d6d1a` gate to the loud `count==1`
  singleton check.
- `70cca90` — Steps B+C: the inline rel8 grow-retry loop in `x-galo`/`x-gbnw`
  and the corrected `"arena-grow"` stub marshalling in `x-fin` — growth works.
- `7650cf7` — Step F: suite-to-green cleanup (deleted dead
  `alloc-growing.chiral` debris, refreshed stale tests).

**The root cause (the thing that made it finally grow):** `nb-get-u64`/
`nb-put-u64` lower to `ti-bget`/`ti-bput`, which access at `ptr + off + 8` (the
boxed-value payload offset that skips an 8-byte length header). The arena cells
are **raw 8-byte slots** with no header, so `nb-arena-grow`/`nb-arena-commit`
must pass `off = -8` to land on the raw cell's byte 0. Without it the grow logic
read/wrote the wrong 8 bytes — the true bug behind the "built but never grew"
false summits. (Corrects the handoff's earlier "nb-arena-grow is built and
correct" summit line: it was built but the marshalling/offset were wrong.)

**Design that shipped:**
- Step D (lambda-wrap) was **NOT** taken — the Mach-field route (`mach-galo`/
  `mach-gbnw` bare global refs in `alloc-growing`) was kept, since it self-hosts
  identically and the churn was not worth it. `alloc.chiral` holds exactly ONE
  fn-bearing instance (`alloc-growing`); no `fixed-trap` instance beside it.
- `x-galo`/`x-gbnw` emit raw rel8 displacements inline (`jbe +7`, `jmp -30`/
  `jmp -41`); the only relocation is the single global `e-call "arena-grow"`.
- `nb-arena-grow` NEVER returns <0 — failure is `nb-arena-fail` → `exit_group`.
- Final `INIT_COMMIT = 262144` (256 KiB); `RESERVE_BYTES = 68719476736`
  (64 GiB). `test_arena_constants` parity is unskipped and passing.

**Gate (SPEC §5) — all met, independently verified:**
1. Fixpoint reconverges byte-identical at **790904B** after each compiler-source
   change.
2. Growth: value + byte cells allocated past the 256 KiB committed prefix GROW
   across ~9 doublings and complete correctly; the self-compile grows its own
   arena — no `ud2`/SIGILL on the growing path.
3. Clean exhaustion: allocating past `RESERVE_BYTES` exits via `nb-arena-fail`
   (`exit_group`), never SIGSEGV/`ud2`.
4. Full py suite green (703; `test_arena_constants` unskipped + passing).
5. `bin/make-public.sh` sync clean (public fixpoint holds).
