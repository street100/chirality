---
element: E89
slug: arena-init
title: Arena startup — entry-stub v3 reserve/commit split (PROT_NONE reservation + mprotect'd INIT_COMMIT prefix), single-sourced constants
kind: REPLACE-CRUTCH
reference_class: SPEC/IMPL
ours_source: (none)
status: drafted
updated: 2026-08-09
---

# E89 — Arena startup: entry-stub v3 reserve/commit split, single-sourced constants

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.
>
> **EXTENDED 2026-08-09 (Step 3, S17-D)** to the resolved reserve-commit design
> (`.planning/SCRIBA-UNBLOCK-MAP.md` §"S17 makeup"). Stub v2 (a checked but
> **eager** RW `mmap`) becomes stub v3: a large
> `PROT_NONE` **reservation** plus an `mprotect`'d RW **prefix** of `INIT_COMMIT`.
> Two further corrections land here: (1) the runtime **grow** path (`mremap`
> doubling) is REMOVED from this element — it was always E90/E91's, and `mremap`
> itself is now REJECTED (relocation dangles absolute heap pointers; the
> `nb-sys-mremap` stub was retired in be3df92); E89 owns
> only startup. (2) the arena constants are **single-sourced** (chirality authority,
> py mirror, cross-check test), killing the 16 GiB-vs-64 MB
> drift `b7b4d5e` introduced between `compile-emit.chiral` and `native.py`.
>
> **AUDIT REFRESH 2026-08-09 (post-f2632c1 / 686d51a):** the **py floor is
> already v3** — f2632c1 landed `RESERVE_BYTES` (64 GiB) / `INIT_COMMIT` (8 GiB
> transitional) at `native.py:57-58`, the v3 `_entry_stub` (214 B, `:746`,
> reserve + commit + THREE cells incl. `heapreserve`), the `heapreserve` third
> cell in `mach-x64.chiral` x-fin (`:258-266`), and the cross-check test
> (`scaffold/tests/test_arena_constants.py`); 686d51a implemented E90's
> `nb-arena-fail`/`nb-arena-commit`/`nb-arena-grow` crossings (`sys-tal.chiral`).
> `STUB_ARENA_BYTES` no longer exists. What remains for E89 Step 3 is the
> **chirality floor**: `compile-emit.chiral` still emits v2 (`arena-bytes` 16 GiB,
> eager RW), so the cross-check test is RED (no `reserve-bytes`/`init-commit`
> defs to read) until `entry-stub-v3` lands there.

## 1. Scope

- **Element:** E89 step 3 — the standalone-ELF entry stub, reworked from an eager
  fully-committed arena to a **reserve/commit split**: reserve a large
  `PROT_NONE` virtual region, commit a small RW prefix, and single-source both
  sizes across the chirality authority and its py mirror.
- **Kind:** REPLACE-CRUTCH — replaces the entry stub's eager `mmap(…, PROT_RW,
  …, 16GiB)` (which maps the whole placeholder RW up front, losing the
  sub-megabyte-footprint story) with a reserve-then-commit prologue whose
  resident footprint at startup is `INIT_COMMIT`, not the reservation size.
- **Why chirality needs its own:** two problems with stub v2.
  1. **Eager commit / accounting fragility.** v2 maps 16 GiB `PROT_READ|
     PROT_WRITE` with `MAP_NORESERVE`. It works today only because `NORESERVE`
     tells the kernel not to charge the reservation — but under strict
     overcommit (`vm.overcommit_memory=2`) the RW mapping is still *accountable*
     and can be refused, and even where it maps, the sub-MB footprint ethos
     (684 KB compiler image) is contradicted by a 16 GiB RW arena hanging off it.
     A `PROT_NONE` reservation is VA-only — unaccounted under **every**
     overcommit mode — and only the `mprotect`'d prefix ever costs anything.
  2. **The two-source drift was a live bug — and is now a red test.** From
     `b7b4d5e` the arena size lived in TWO places carrying "must match" comments
     that did NOT match: `compile-emit.chiral` `arena-bytes` said `16 << 30`
     (16 GiB), `native.py` `STUB_ARENA_BYTES` said `64 << 20` (64 MB). The
     byte-identity tests never caught it because the ELF stub and the JIT arena
     are different code paths. f2632c1 landed the enforcement half: py now
     carries `RESERVE_BYTES`/`INIT_COMMIT` (`native.py:57-58`) and
     `scaffold/tests/test_arena_constants.py` reads the chirality source and asserts
     equality — the test FAILS today because `compile-emit.chiral` has no
     `reserve-bytes`/`init-commit` defs yet. Step 3 lands the chirality authority,
     turning the test green and making this class of drift unrepresentable.
- **This element does NOT own growth.** Committing the next chunk when the bump
  cursor passes the prefix is E90 (`nb-arena-grow`, an `mprotect` crossing —
  IMPLEMENTED in 686d51a: `nb-arena-fail`/`nb-arena-commit`/`nb-arena-grow` in
  `sys-tal.chiral:118-190`) wired in by E91 (check-first allocators + the shared
  grow stub, still pending). E89 establishes the reservation, the initial
  commit, and the metadata those siblings consume.

## 2. Research

- **Reference class:** SPEC (Linux `mmap`/`mprotect` ABI, overcommit accounting)
  + IMPL (V8/Go reserve-then-commit arena shape).
- **`PROT_NONE` reservation vs `MAP_NORESERVE` RW.** `mmap(NULL, len, PROT_NONE,
  MAP_PRIVATE|MAP_ANONYMOUS, -1, 0)` reserves virtual address space with no
  access rights and, crucially, **no commit charge under any overcommit policy**
  — including strict `vm.overcommit_memory=2`, where an equivalent `PROT_READ|
  PROT_WRITE` mapping (even with `MAP_NORESERVE`) can still be counted and
  refused. `MAP_NORESERVE` is advisory and mode-dependent; `PROT_NONE` is
  structural. The reservation is a promise of address space, not memory.
- **`mprotect(2)` to commit.** `mprotect(base, INIT_COMMIT, PROT_READ|
  PROT_WRITE)` flips the prefix of the reservation to RW. First touch of each
  page faults in a zero page (like `MAP_ANONYMOUS`), so resident memory tracks
  the touched set, and the arena reads as zeroed. `mprotect` requires a
  page-aligned address (the `mmap` base always is) and rounds the length up to a
  page multiple. Returns 0 or `-errno`.
- **The `-errno` ceiling check is unchanged from v2.** Linux guarantees syscall
  error returns are in `[-4095, -1]`; both the reservation `mmap` and the commit
  `mprotect` are checked `rax < 0 ⇒ fail` (a `test rax, rax; js fail`), NOT a
  `< -4096` form (which would let `-1`/`-12` slip through as success).
- **Sub-megabyte footprint numbers.** The compiler image is ~684 KB;
  `INIT_COMMIT`'s design endstate is **256 KiB** (S17 resolved design) — a
  sub-MB initial heap that keeps the whole process (code + initial heap) under
  a megabyte until real allocation demand grows it. Until E91 wires growth, the
  IMPLEMENTED transitional value is **8 GiB** (`native.py:58` — big enough to
  complete a self-compile with no grow path; drops to 256 KiB with S17-C/E).
  `RESERVE_BYTES` is **64 GiB** (`64 << 30`, implemented `native.py:57`) of
  pure VA — larger than the old 16 GiB placeholder because it costs nothing
  (`PROT_NONE`), giving grow headroom well past the self-compile's ~128 MB peak.
- **Single-sourcing pattern (OURS).** `native.py` already mirrors chirality constants
  elsewhere and asserts equality in tests (the D-2 byte-identity discipline).
  Step 3 applies the same: the chirality `def` is authority, the py name reads
  "must equal the chirality value", and one cross-check test loads the chirality source
  and asserts the py constants match — the mechanical guard the "must match"
  comment only *claimed*. The test half already exists
  (`scaffold/tests/test_arena_constants.py`, f2632c1) and is red until the
  chirality defs land.

## 3. Conventional (other-language) approach

Stub v2 — checked, but **eager** (full RW commit) and **drifted** (two
unsynchronized sources). This is still the LIVE state of the chirality floor
(`compile-emit.chiral:49-91`); the py mirror shown second is HISTORICAL — f2632c1
replaced it with the v3 `_entry_stub`:

```asm
; compile-emit.chiral entry-stub-v2 (abridged): CHECKED but eager 16 GiB RW
mov eax, 9                 ; SYS_mmap
xor edi, edi               ; addr = 0
movabs rsi, 17179869184    ; 16 << 30  -- arena-bytes (chirality authority)
mov edx, 3                 ; PROT_READ | PROT_WRITE   <-- eager: whole 16 GiB is RW
mov r10d, 0x4022           ; MAP_PRIVATE | MAP_ANONYMOUS | MAP_NORESERVE
mov r8, -1                 ; fd = -1
xor r9d, r9d               ; offset = 0
syscall
test rax, rax
jns arena_ok               ; checked -- the v2 win over the blind 48 GiB stub
  ; chirality v2 fail path: exit_group(1) BARE -- no message (the
  ; "can't allocate arena\n" write existed only on the py floor's stub)
arena_ok:
mov [&heapptr], rax        ; heapptr := base
movabs rcx, 17179869184    ; 16 << 30
add rax, rcx
mov [&heapend], rax        ; heapend := base + 16 GiB  (fully-committed end)
xor edi, edi
call <entry>
```

```python
# native.py, HISTORICAL (b7b4d5e..f2632c1): the py mirror -- SAME constant,
# DIFFERENT value (the live drift Step 3's cross-check test now pins)
STUB_ARENA_BYTES = 64 << 20   # 64 MB  <-- comment said "must match ...arena-bytes";
                              #             chirality said 16 << 30. They did NOT match.
def _entry_stub(entry_off, heapptr_abs=0, heapend_abs=0):
    return (b"\xb8\x09\x00\x00\x00"                          # mov eax, 9 (mmap)
            + b"\x48\xbe" + struct.pack("<Q", STUB_ARENA_BYTES)  # movabs rsi, 64 MB
            + b"\xba\x03\x00\x00\x00"                        # mov edx, 3 (PROT_RW, eager)
            + ...)                                          # checked, but 64 MB != 16 GiB
```

- **What it bakes in:**
  - **Eager commit.** The entire arena is `PROT_READ|PROT_WRITE` from
    instruction one. `MAP_NORESERVE` keeps it *usually* free, but it is not
    unaccounted under strict overcommit, and the sub-MB footprint promise is
    broken by a multi-GB RW region.
  - **Two sources of truth.** The size is duplicated in `compile-emit.chiral` and
    `native.py`, each asserting via comment that it matches the other — and they
    silently diverged (16 GiB vs 64 MB). Nothing mechanical enforced the
    equality the comments promised (the cross-check test that now does landed
    with f2632c1).
  - **No headroom discipline.** The fixed 16 GiB was picked to be "big enough";
    there is no cheap way to give more headroom because more headroom means more
    eagerly-committed RW.

## 4. The chirality idea

Stub v3 keeps v2's honest checking and adds the reserve/commit split — memory is
**substrate**, established once at process entry, below the effect membrane.

- **Reserve, then commit — the footprint is the prefix, not the reservation.**
  The stub `mmap`s `RESERVE_BYTES` as `PROT_NONE` (VA only, unaccounted under
  every overcommit mode), then `mprotect`s the first `INIT_COMMIT` bytes to
  `PROT_READ|PROT_WRITE`. `heapptr := base`, `heapend := base + INIT_COMMIT`,
  `heapreserve := base + RESERVE_BYTES`.
  Resident memory at startup is bounded by the touched prefix, so at the
  256 KiB `INIT_COMMIT` endstate the whole running process — 684 KB code +
  sub-MB initial heap — stays under a megabyte until real demand grows it. The
  sub-megabyte ethos then extends to the runtime footprint, not just the image.
- **`heapend` doubles as the committed end; `heapreserve` is the ceiling.** The
  arena cells keep their identity (`mach-x64.chiral` x-fin `:258-266` — now THREE:
  `heapptr`, `heapend`, `heapreserve`, the third landed in f2632c1), but their
  *meaning* sharpens: `heapend` is now the end of the **committed** (RW) prefix,
  not the end of a fully-mapped region, and `heapreserve` holds
  `base + RESERVE_BYTES`, the hard ceiling E90's `nb-arena-commit` refuses to
  grow past. When the bump cursor reaches `heapend`, E90/E91 commit the next
  chunk and advance it (`nb-arena-commit` publishes via `nb-put-u64`,
  implemented 686d51a). Nothing past `heapend` is writable — a store there
  faults (which is exactly why E91's check-first reorder is a prerequisite).
- **Errors as an honest halt — reused, now on two syscalls.** Both the
  reservation `mmap` and the initial `mprotect` are checked `rax < 0 ⇒ fail`;
  either failure takes the honest-fail path (write `"can't allocate arena\n"`
  to fd 2, `exit_group(1)`) — v2's pattern of checking + exit, with a
  diagnostic write added (v2 exited silently, no message). No silent heap
  corruption, no SIGSEGV — a failed reservation or a refused initial commit is a
  clean exit-1 with a message.
- **Sub-semantic, but the syscalls are still E76-registered.** The stub is below
  the language's `->`/`=>` effect semantics (the program building the ground it
  runs on), the same tier v2 already occupied. It is not unaudited: `mmap` (nr 9)
  and `mprotect` (nr 10) are both E76-registered syscall rows, preserve-checked
  like every sys-lib crossing.
- **One authority for the constants.** `reserve-bytes` and `init-commit` become
  chirality `def`s in `compile-emit.chiral` — the single source. `native.py` already
  mirrors them with an explicit "must equal" note (`RESERVE_BYTES`/`INIT_COMMIT`,
  `:57-58`), and the cross-check test (`scaffold/tests/test_arena_constants.py`)
  reads the chirality source and asserts equality. The drift the "must match"
  comment merely *asserted* is mechanically enforced the moment the chirality defs
  exist (today the test is red — the tracked form of the remaining gap).
- **What chirality makes impossible here:** an eager multi-GB RW arena that
  contradicts the footprint story (the reservation is `PROT_NONE`); a silent
  size drift between the two floors (the cross-check test fails the build); a
  reservation or initial-commit failure that corrupts or SIGSEGVs (both are the
  honest exit-1 path). Growth-by-relocation never appears — E89 hands off a
  fixed-address reservation; the mapping never moves.

## 5. Chirality example (fleshed)

The `compile-emit.chiral` entry-stub emitter, v3. Same byte-emitting idiom as v2
(`byte1`/`pack-u32`/`pack-u64`/`bcat`); the shape changes from one eager RW
`mmap` to a `PROT_NONE` `mmap` + an `mprotect` commit, both checked, sharing the
one honest-fail tail. Exact `rel32`/branch displacements are finalized against
the sexp reader at implementation time (as v2's were); the annotations below give
the instruction sequence, not the final byte offsets.

```chirality
; ── arena constants: SINGLE SOURCE OF TRUTH (compile-emit.chiral) ──
; native.py mirrors these; test_arena_constants.py pins the py values equal.
(def reserve-bytes I64 68719476736)   ; 64 << 30 = 64 GiB -- PROT_NONE VA reservation
                                      ;   (unaccounted under ALL overcommit modes,
                                      ;    incl. strict vm.overcommit_memory=2)
(def init-commit   I64 8589934592)    ; 8 GiB TRANSITIONAL (must equal native.py:58
                                      ;   or the cross-check test stays red) --
                                      ;   drops to the 256 KiB endstate once E91
                                      ;   wires growth (S17-C/E); the sub-megabyte
                                      ;   footprint then extends to the runtime heap

; PROT_NONE = 0 ; PROT_READ|PROT_WRITE = 3 ; MAP_PRIVATE|ANON = 0x22
;   (NORESERVE dropped from v2's 0x4022: redundant under PROT_NONE, and the
;    implemented py v3 stub uses 0x22 -- native.py:746)
; mmap = 9 ; mprotect = 10 ; exit_group = 231.  Both syscalls E76-registered.

(def entry-stub-v3 (-> I64 I64 I64 I64 Bytes)
  (lam (entry-off heapptr-abs heapend-abs heapreserve-abs)
    ; ── 1. RESERVE: mmap(NULL, reserve-bytes, PROT_NONE, PRIVATE|ANON, -1, 0) ──
    (bcat (byte1 184)                      ; b8       mov eax, imm32
    (bcat (pack-u32 9)                     ;          9 = mmap
    (bcat (pack-u16 65329)                 ; 31 ff    xor edi, edi   (addr = 0)
    (bcat (pack-u16 48712)                 ; 48 be    movabs rsi, imm64
    (bcat (pack-u64 reserve-bytes)         ;          RESERVE_BYTES (len)
    (bcat (byte1 186)                      ; ba       mov edx, imm32
    (bcat (pack-u32 0)                     ;          0 = PROT_NONE   <-- reserve only
    (bcat (pack-u16 47681)                 ; 41 ba    mov r10d, imm32
    (bcat (pack-u32 34)                    ;          0x22 = PRIVATE|ANON
    (bcat (pack-u16 51017)                 ; 49 c7    mov r8, imm32 (sign-extended)
    (bcat (byte1 192)                      ; c0       /0, rm = r8
    (bcat (pack-u32 4294967295)            ;          0xffffffff -> -1 (fd)
    (bcat (pack-u16 12613)                 ; 45 31    xor r9d, r9d ...
    (bcat (byte1 201)                      ; c9       (offset = 0)
    (bcat (pack-u16 1295)                  ; 0f 05    mmap syscall
    (bcat (bc3 (b1 72) (b1 133) (b1 192))  ; 48 85 c0 test rax, rax  (rax = base OR -errno)
    (bcat x-js-fail                        ; 0f 88 .. js fail   (rax < 0 -> honest-fail tail)
    ; save base before mprotect clobbers rax: heapptr := base now
    (bcat (pack-u16 41800)                 ; 48 a3    mov [moffs64], rax
    (bcat (pack-u64 heapptr-abs)           ;          &heapptr <- base
    ; ── 2. COMMIT: mprotect(base, init-commit, PROT_READ|PROT_WRITE) ──
    (bcat (bc3 (b1 72) (b1 137) (b1 199))  ; 48 89 c7 mov rdi, rax   (addr = base)
    (bcat (byte1 190)                      ; be       mov esi, imm32
    (bcat (pack-u32 init-commit)           ;          INIT_COMMIT (len)
    (bcat (byte1 186)                      ; ba       mov edx, imm32
    (bcat (pack-u32 3)                     ;          3 = PROT_READ|PROT_WRITE
    (bcat (byte1 184)                      ; b8       mov eax, imm32
    (bcat (pack-u32 10)                    ;          10 = mprotect
    (bcat (pack-u16 1295)                  ; 0f 05    mprotect syscall
    (bcat (bc3 (b1 72) (b1 133) (b1 192))  ; 48 85 c0 test rax, rax  (0 OR -errno)
    (bcat x-js-fail                        ; 0f 88 .. js fail   (mprotect refused -> honest-fail)
    ; ── 3. heapend := base + init-commit  (the COMMITTED end) ──
    ; CAUTION: the moffs64 forms are RAX-ONLY -- 48 a1 loads rax, 48 a3 stores
    ; rax; there is NO moffs encoding for rcx. Reload base into rax (a1), add,
    ; store (a3). (The implemented py v3 stub trips exactly here: its [105]/[131]
    ; "48 a3" stores are annotated "mov [..], rcx" but store RAX -- see FLAGs.)
    (bcat (pack-u16 41288)                 ; 48 a1    mov rax, [moffs64]
    (bcat (pack-u64 heapptr-abs)           ;          base back in rax
    (bcat (pack-u16 47432)                 ; 48 b9    movabs rcx, imm64
    (bcat (pack-u64 init-commit)           ;          INIT_COMMIT
    (bcat (bc3 (b1 72) (b1 1) (b1 200))    ; 48 01 c8 add rax, rcx    (base + INIT_COMMIT)
    (bcat (pack-u16 41800)                 ; 48 a3    mov [moffs64], rax
    (bcat (pack-u64 heapend-abs)           ;          &heapend <- committed end
    ; ── 4. heapreserve := base + reserve-bytes  (the RESOLVED third cell) ──
    (bcat (pack-u16 41288)                 ; 48 a1    mov rax, [moffs64]
    (bcat (pack-u64 heapptr-abs)           ;          base back in rax
    (bcat (pack-u16 47432)                 ; 48 b9    movabs rcx, imm64
    (bcat (pack-u64 reserve-bytes)         ;          RESERVE_BYTES
    (bcat (bc3 (b1 72) (b1 1) (b1 200))    ; 48 01 c8 add rax, rcx    (the ceiling)
    (bcat (pack-u16 41800)                 ; 48 a3    mov [moffs64], rax
    (bcat (pack-u64 heapreserve-abs)       ;          &heapreserve <- reservation end
    ; ── 5. call main, propagate result to exit status ──
    (bcat (pack-u16 65329)                 ; 31 ff    xor edi, edi   (dummy arg0 = 0)
    (bcat (byte1 232)                      ; e8       call <entry>
    (bcat (pack-u32 (entry-rel entry-off)) ;          rel32 (LE) -- entry-off - (next-instr off)
    (bcat (pack-u16 51081)                 ; 89 c7    mov edi, eax   (result -> status)
    (bcat (byte1 184)                      ; b8       mov eax, imm32
    (bcat (pack-u32 231)                   ;          231 (exit_group), LE
    (bcat (pack-u16 1295)                  ; 0f 05    syscall
    ; ── honest-fail tail (shared by both js fail branches, extended from v2) ──
    ;   chirality v2: exit_group(1) silently. v3 adds the message tail (mirroring the
    ;   py stub): write(2, "can't allocate arena\n", 21); exit_group(1)
          x-arena-fail-tail))))))))))))))))))))))))))))))))))))))))))))))))))))))))
; NOTE -- the two js displacements (x-js-fail) both target the fail tail; the
; call rel32 and the js rel32s are finalized with the sexp reader at implement
; time, exactly as entry-stub-v2's rel32 = entry-off - 97 was. `x-js-fail` and
; `x-arena-fail-tail` name the fail-branch bytes (the message + the
; write/exit_group sequence -- NEW on the chirality floor; chirality v2's fail path was
; a bare exit_group(1)), factored so both checks share one tail. The implemented
; py v3 (native.py:746, 214 B, call at 143 / rel = entry-off - 148) uses
; jns+2/jmp-rel8 instead of js-rel32 and places the tail at [157] -- the chirality
; emitter may mirror that layout or keep this one; the SPEC pins the bytes.
; assemble-elf must also pass the THIRD cell offset (heapreserve-off) and
; entry-stub-len must be recomputed from v2's 106.
```

- **Knobs to modify:**
  - `reserve-bytes` (`64 << 30`) — pure VA headroom; costs nothing until
    committed. Raise it freely; the only ceiling is the reservation-exhausted
    check in `nb-arena-commit` (E90, implemented — fail code 1 past
    `reserve_end`).
  - `init-commit` — the resident startup heap. Transitional 8 GiB today (must
    equal `native.py:58`); 256 KiB endstate once E91 wires growth. Smaller =
    tighter footprint, more early grow events; must be page-aligned (both
    values are).
  - The commit `prot` (`3` = RW) — never add `PROT_EXEC` to the data arena
    (W^X); the code region is a separate `mprotect` (E20 loader).
- **Deliberately omitted:**
  - **Runtime growth** — committing the *next* chunk when the cursor passes
    `heapend` is E90 (`nb-arena-grow`, `mprotect`-doubling — implemented,
    686d51a) + E91 (check-first allocators + the shared grow stub — pending).
    E89 establishes only the reservation, the initial commit, and the metadata
    they consume. `mremap` appears nowhere (it was in the pre-revision E89
    draft and is now REJECTED — relocation dangles absolute heap pointers; the
    `nb-sys-mremap` stub was retired in be3df92).
  - **Page-rounding of `init-commit`** — chosen already page-aligned; a general
    `INIT_COMMIT` would round up to a page multiple (`mprotect` does this).
- **Resolved since the draft (was "deliberately omitted / open"):**
  - **Reserve-end = a third cell.** `base + reserve-bytes` IS stored, in the
    `heapreserve` cell beside `heapptr`/`heapend` (`mach-x64.chiral` x-fin
    `:258-266`, py stub stores it at `native.py:746` [131]; landed f2632c1).
    The E90 crossings take `reserve_end` as a register argument the caller
    reads from that cell.

## 6. Use / modify notes

- **Lands in (both floors, single-sourced) — py floor DONE, chirality floor is the
  remaining work:**
  - `scaffold/lib/compile-emit.chiral` (REMAINING) — `arena-bytes` (16 GiB,
    eager) is replaced by `reserve-bytes` + `init-commit`; `entry-stub-v2`
    becomes `entry-stub-v3` (the reserve/commit prologue above);
    `entry-stub-len` (106) is recomputed; `assemble-elf` passes the third cell
    offset (`heapreserve-off`) alongside `heapptr-off`/`heapend-off`. This file
    becomes the **authority** for both constants.
  - `scaffold/chirality/native.py` (DONE, f2632c1) — `_entry_stub` is the v3 byte
    sequence (214 B, `:746`); `STUB_ARENA_BYTES` (the drifted `64 << 20`) is
    replaced by `RESERVE_BYTES`/`INIT_COMMIT` (`:57-58`) with explicit "must
    equal compile-emit.chiral" notes; `_ENTRY_STUB_LEN` recomputed; the
    `heapreserve` cell vaddr is wired through the stub call. (But see FLAGs:
    the implemented stub's `48 a3` heapend/heapreserve stores are rax-only and
    store the wrong register's value.)
  - **Cross-check test** (DONE, f2632c1) — `scaffold/tests/test_arena_constants.py`
    reads the chirality source and asserts `native.py`'s `RESERVE_BYTES`/`INIT_COMMIT`
    equal the chirality `def`s. It is RED until the chirality defs land — the drift
    `b7b4d5e` introduced is now a failing test instead of a hopeful comment.
- **Conformance target:**
  - The compiler self-compiles at fixpoint with the reserve-commit stub; the
    resulting ELF's startup resident footprint tracks touched pages of the
    committed prefix, not the reservation size — at the 256 KiB endstate the
    whole process stays sub-MB; verify with `/proc/self/status` `VmRSS` right
    after entry.
  - A reservation failure (e.g. `RLIMIT_AS` below `RESERVE_BYTES`) exits 1 with
    `"can't allocate arena\n"`, NOT a SIGSEGV or OOM-kill. An initial-commit
    `mprotect` failure (e.g. `vm.max_map_count` exhausted) takes the same path.
  - The cross-check test fails the build if the two floors' constants diverge
    (today it fails because the chirality defs don't exist yet — landing them green
    is part of this element's gate).
  - Because the endstate `INIT_COMMIT` (256 KiB) is far below the self-compile's
    ~128 MB peak, the stub v3 arena on its own is NOT enough to self-compile —
    that is the point: the self-compile becomes the real soak for E90/E91
    growth. Until E91 wires the grow path, the transitional `INIT_COMMIT`
    (8 GiB, the value py already carries at `native.py:58`) keeps the build
    green under the `fixed-trap` discipline; the SPEC sequences this with
    S17-A/B/C so no intermediate commit is broken.
- **Open questions — one RESOLVED by implementation, one still carried:**
  - **RESOLVED — reserve-end is a third cell.** The stub stores
    `base + reserve-bytes` in the `heapreserve` cell beside `heapptr`/`heapend`
    (option (a); `mach-x64.chiral` x-fin `:258-266` + `native.py:746`, landed
    f2632c1 — cited, not decided here). E90's twin question ("where do
    `base`/`reserve_end` come from") resolved with it: the implemented crossings
    take them as register arguments (`nb-arena-commit(from, to, reserve_end,
    heapend_cell)`, `nb-arena-grow(base, reserve_end, need, heapend_cell)` —
    `sys-tal.chiral:125-190`, 686d51a). The cell-format half is also settled by
    E90's implementation: the grow/commit path reads and writes the tracking
    cell through `nb-get-u64`/`nb-put-u64` (`sys-tal.chiral:156/175`), not a raw
    `mov [moffs64]` store.
  - **Py JIT `_map_rw` disposition (native.py:559) — STILL OPEN.** The
    in-process JIT arena (`_map_rw` → `nb-sys-mmap`, `native.py:559/637`)
    still maps a fixed fully-committed RW region (`ARENA_BYTES` = 1 MB, `:50`).
    Does it **adopt** reserve-commit (a `PROT_NONE` reservation + `mprotect`
    prefix + the E90 grow path, matching the ELF floor), or **pin the
    fixed-trap discipline** (stay a fixed RW arena, never grow)? This is gated
    by E81's `Alloc` discipline semantics (S17-E: `growing` vs `fixed-trap`):
    the ELF default flips to `growing`, the JIT/tests pin `fixed`. f2632c1
    resolved the S12 docket around it (py oracle retired, E81 seam staged) but
    did NOT decide this: `_map_rw` is unchanged and the `growing` discipline is
    not yet wired (emit-x64 supplies the trap discipline everywhere). The SPEC
    picks the JIT's disposition once S17-E fixes what each discipline means.
    Note the JIT arena has the same write-before-check SIGSEGV hazard shape
    (overflow faults on unmapped VA), so "adopt reserve-commit" also inherits
    E91's check-first prerequisite on the JIT path.
- **Related:** [[E89-arena-init]] · [[E90-arena-grow-crossing]] (the
  `nb-arena-grow` `mprotect`-doubling crossing that commits the NEXT chunk of
  this reservation — IMPLEMENTED 686d51a; consumes E89's
  `base`/`reserve_end`/`heapend` + the honest-fail helper) ·
  [[E91-growing-allocator]] (check-first `x-alo`/`x-bnw` +
  the shared out-of-line grow stub that CALLS `nb-arena-grow`) ·
  [[E81-alloc-discipline]] (`growing` vs `fixed-trap` — decides the JIT `_map_rw`
  disposition) · [[E76-syscall-chokepoint]] (registers the `mmap`/`mprotect`
  crossings this stub issues) · [[E21-arena]] · [[E20-loader]] (also `mprotect`s,
  but for W^X code, not the heap) · `scaffold/lib/compile-emit.chiral`
  (`arena-bytes` → `reserve-bytes`/`init-commit`, `entry-stub-v2` → `v3`;
  becomes the constant authority) · `scaffold/chirality/native.py:57-58`
  (`RESERVE_BYTES`/`INIT_COMMIT`, the mirror) + `:746` (`_entry_stub` v3) +
  `:559` (`_map_rw`, the JIT arena) · `scaffold/tests/test_arena_constants.py`
  (the cross-check) · `scaffold/lib/sys-tal.chiral:118-190` (the E90 crossings)
  · `scaffold/lib/mach-x64.chiral` x-fin `:258-266` (the
  `heapptr`/`heapend`/`heapreserve` cells).

<!-- AUDIT FLAGS (2026-08-09, second pass, post-f2632c1/686d51a/ab43431):
  FIXED from the first pass: FLAG-1 (GB/GiB — now GiB consistently) and
  FLAG-2 (NORESERVE with PROT_NONE — dropped to 0x22, matching the implemented
  py v3 stub at native.py:746).
  FLAG-3 (carried): §5 snippet closing-paren count — deep bcat nesting
    (now 56 closing parens after x-arena-fail-tail, +7 for the heapreserve
    block). Sketch status makes this low-priority but the impl run must count
    exactly (as v2's compilable 106-byte stub did).
  FLAG-4 (author-tier, OUT OF THIS ARTIFACT — scaffold/): the implemented py v3
    _entry_stub (native.py:746) stores the WRONG VALUE into heapend and
    heapreserve. The `48 a3` moffs64 store is rax-only, but at [105]/[131] the
    computed ends live in rcx (rax holds mprotect's 0) — so both cells get 0,
    not base+INIT_COMMIT / base+RESERVE_BYTES. Any ELF emitted through the py
    floor's stub would trap/fault on first allocation. Surfaced in the audit
    report; not fixable from an example audit.
  FLAG-5 (author-tier, OUT OF THIS ARTIFACT): emit-x64.chiral :24/:27/:33
    references `alloc-fixed-trap` (renamed from `alloc-bump` in be3df92) but
    alloc.chiral still defines only `alloc-bump` — a dangling global unless the
    rename lands in alloc.chiral too. Affects the E81/E91 composition this
    example cites.
-->
