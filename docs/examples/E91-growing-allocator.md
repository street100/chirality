---
element: E91
slug: growing-allocator
title: Growing allocator — a single `Alloc` discipline whose bump path is an inline rel8 check-first grow-retry loop over a reserve-commit arena
kind: BUILD-PROPER
reference_class: OURS/IMPL
ours_source: (none)
status: reviewed
updated: 2026-08-10-post-implementation
---

# E91 — Growing allocator: a single `Alloc` discipline, an inline rel8 grow-retry loop, and a reserve-commit arena

> One worked example, produced by the `worked-example` pre-run and **re-worked
> 2026-08-10 after E91 was actually implemented and independently verified** (the
> growing allocator now genuinely grows: value + byte cells past 256 KiB grow
> across ~9 doublings, the self-compile grows its own arena, fixpoint = 790904B,
> suite 703). This is the rationale doc; every claim below is checked against the
> shipped code (`mach-x64.chiral` `x-galo`/`x-gbnw`/`x-fin`, `sys-tal.chiral`
> `nb-arena-grow`/`nb-arena-commit`, `alloc.chiral` `alloc-growing`,
> `compile-emit.chiral` `entry-stub-v2`). Two earlier drafts were materially
> wrong — the corrections are called out inline so the mistakes stay legible.

## 1. Scope

- **Element:** E91, the growing allocator — **one** change with three
  interdependent parts (growth needs all three), all landed:
  - **The bump path grows in place.** `x-galo` (value cells) and `x-gbnw` (byte
    cells) in `mach-x64.chiral` emit an **inline rel8 check-first grow-retry
    loop**: bound-check the candidate bump against `heapend`; on fit, store +
    advance `heapptr`; on miss, `call` the one shared `"arena-grow"` stub and
    `jmp` back to the top to re-read `heapend` and re-check. No `ud2` on the
    growing path.
  - **One shared `"arena-grow"` stub** (in `x-fin`, once per image) marshals the
    real callee contract and calls `nb-arena-grow`, which `mprotect`-doubles the
    committed prefix of a `PROT_NONE` reservation and publishes the new
    `heapend`.
  - **A reserve-commit entry stub** (`entry-stub-v2` in `compile-emit.chiral`,
    byte-identical to `native.py._entry_stub`): `mmap PROT_NONE` a 64 GiB
    reservation → `mprotect` a committed `INIT_COMMIT` (256 KiB) prefix →
    initialize four cells `heapptr`/`heapbase`/`heapend`/`heapreserve`.
  - The trap-vs-grow choice is an **`Alloc` discipline** (`alloc.chiral`, E81) —
    but there is exactly **one** live instance: `alloc-growing`. See §2.
- **Kind:** BUILD-PROPER.
- **Why chirality needs its own:** The bump allocator in `mach-x64.chiral` was hard-
  capped at the initial committed heap and merely `ud2`-trapped on exhaustion —
  the whole compiler only self-hosted because the arena was a 16 GiB
  demand-paged `NORESERVE` placeholder that never actually filled. Under the
  reserve-commit arena (a `PROT_NONE` reservation ~64 GiB + an `mprotect`'d RW
  prefix of `INIT_COMMIT` 256 KiB), an allocation past the committed prefix must
  transparently `mprotect` the next span RW (`nb-arena-grow`) instead of
  trapping. This is the last link in the dynamic-arena chain: E89 startup → E90
  growth primitive → **E91 wires growth into the allocator's hot path.**

> **Correction over the first two drafts.** Earlier drafts framed E91 as **two
> steps** with "check-first reordering" as a *prerequisite* to do first. That was
> wrong: the allocators were **already** check-first (`x-alo`/`x-bnw` bound-check
> before any store). No reorder work existed. The real work was wiring the grow
> path, the stub, and the reserve-commit stub — which is what shipped.

## 2. Research

- **Reference class:** OURS (`mach-x64.chiral` allocation helpers + the
  `asm-reloc.chiral` `Asm`/`EncTag` vocabulary + `alloc.chiral` E81 seam) / IMPL
  (V8/Go-style reserve-then-commit arenas).
- **Key findings (as implemented):**
  - **Exactly ONE fn-bearing `Alloc` instance may live in the compiler blob.**
    `specialize-singletons` monomorphizes the fn-bearing `Alloc` dict to a
    *single* instance and rewrites projectors straight to it. Two distinct
    fn-bearing instances hard-error at the loud `count==1` gate. So the shipped
    `alloc.chiral` defines **only** `alloc-growing` (bare global refs
    `mach-galo`/`mach-gbnw`) — there is no second `fixed-trap` instance sitting
    beside it. This "one instance, not two" fact is the load-bearing constraint
    of the whole element.
  - **The bump grows via an inline rel8 loop, not a per-site labelled branch.**
    `x-galo`/`x-gbnw` emit raw rel8 displacements inline: `jbe +7` (byte `76 07`)
    skips the 5-byte `call "arena-grow"` + 2-byte back-`jmp` when the bump fits;
    on a miss the `call` runs, then `jmp -30` (`x-galo`) / `jmp -41` (`x-gbnw`)
    (`EB E2` / `EB D7`) returns to the loop top to re-load `heapptr`/`heapend`
    and re-check. The ONLY relocation is the single global `e-call "arena-grow"` —
    there are no per-site `retry`/`commit` labels, so the label-gensym worry the
    first draft raised never materialized.
  - **`nb-arena-grow` NEVER returns a negative value.** It reads the current
    committed end, computes `target = committed_end + max(committed_size, need)`,
    and calls `nb-arena-commit`, which `mprotect`s the new span and publishes
    the end. On the reservation ceiling being exceeded, or on `mprotect`
    refusal, it calls `nb-arena-fail` → `exit_group(code)` — it does not return
    an errno. So the caller's grow path does **not** branch on a sign; it just
    `call`s and retries. Every failure is a clean process exit, never a returned
    error value and never a `ud2` on the growing path.
  - **The real root cause that made growth finally work: the `-8` offset.**
    `nb-get-u64`/`nb-put-u64` lower to `ti-bget`/`ti-bput`, which read/write at
    `ptr + off + 8` — the payload offset that skips a *boxed value's* 8-byte
    length header. But the arena cells (`heapptr`/`heapend`/…) are **raw 8-byte
    slots** with no header. So the stub and `nb-arena-grow`/`nb-arena-commit`
    pass `off = -8`, landing the read/write on the raw cell's byte 0. Without
    that compensation the grow logic silently read/wrote the wrong 8 bytes — the
    single correction that turned the "built but never grew" false summit into a
    working allocator.
  - **The call/jump mechanism already existed.** `apply-enc`
    (`asm-reloc.chiral`) encodes `e-call` → `E8 dddd` (5-byte rel32 call) and the
    RIP-relative load/lea encoders `e-ldrdi`/`e-ldrsi`/`e-learcx` (used by the
    stub to marshal `base`/`reserve_end`/`&heapend`). The `x-fin` stub reuses
    exactly these — no new encoders.
  - **The arena cells are plain mutable globals.** `heapptr`/`heapbase`/
    `heapend`/`heapreserve` are `a-label` + 8-byte slots in `x-fin`, loaded/
    stored via the 7-byte rip-relative `e-ldheap`/`e-stheap`/`e-cmpheap` forms.
  - **`mremap` is REJECTED, and appears nowhere as a mechanism** (still true).
    `MREMAP_MAYMOVE` may relocate the whole mapping, dangling every absolute
    heap pointer already handed out; `mremap` without `MAYMOVE` fails whenever
    the following VA is occupied. Reserve-commit sidesteps both: the mapping
    never moves — growth only flips reserved pages RW via `mprotect`, so all
    existing pointers stay valid.

## 3. Conventional (other-language) approach

How a reserve-commit bump allocator grows in a language where the heap is
ambient (the V8/Go arena shape — a large `PROT_NONE` reservation, an `mprotect`'d
committed prefix, growth by doubling the committed span):

```c
// Conventional: the arena is a global; growth is a direct syscall in the
// allocation path. No typed effect, no proof obligation, no retry invariant.
static uintptr_t arena_base;    // start of the PROT_NONE reservation
static uintptr_t heapptr;       // bump pointer
static uintptr_t heapend;       // end of the *committed* (RW) prefix
static uintptr_t reserve_end;   // end of the reservation

void* bump_alloc(size_t size) {
    uintptr_t bump = heapptr;
    uintptr_t next = bump + size;
    while (next > heapend) {                       // exhausted the committed prefix
        size_t committed = heapend - arena_base;
        size_t grow = committed;                   // double
        if (heapend + grow > reserve_end) grow = reserve_end - heapend;
        if (grow == 0) abort();                    // reservation exhausted -> fatal
        // commit the next span RW; the mapping never moves, so pointers hold
        if (mprotect((void*)heapend, grow, PROT_READ|PROT_WRITE) != 0) abort();
        heapend += grow;
        // re-check: heapptr/heapend re-read at the top of the loop
    }
    // NB: the object is written only AFTER we know it fits
    *(uintptr_t*)bump = /* tag */ 0;
    heapptr = next;
    return (void*)bump;
}
```

- **Rejected reflex — `mremap`.** The naive C move is
  `mremap(base, old, old*2, MREMAP_MAYMOVE)`. Chirality rejects it: `MAYMOVE`
  relocates the region and dangles every pointer already handed out;
  no-`MAYMOVE` growth is unreliable when the next VA is taken. Reserve-commit
  (`mprotect` on a fixed reservation) is the mechanism chirality carries instead.
- **Assumptions it bakes in:**
  - **Ambient mutation.** `heapptr`, `heapend`, `arena_base`, `reserve_end` are
    naked globals — no capability, no ownership, no linear discipline.
  - **Partiality via `abort()`.** OOM is a raw process kill with no typed exit.
  - **Untyped syscall.** `mprotect` is a raw libc call with no effect tracking —
    any function in the program can call it.
  - **Growth policy hard-wired into the allocator.** "double, else fail" is
    inlined; there is no seam to swap the discipline.

## 4. The chirality idea

How chirality's model reframes a reserve-commit bump-allocator growth path.

- **Chirality features in play:**
  - **Category B (untyped) code emitted, Category C bridge for the crossing.**
    The `Asm` list `x-galo`/`x-gbnw` emit is category B — raw x86-64 the language
    cannot type. The `"arena-grow"` stub's call to `nb-arena-grow` is a Category
    C bridge: a typed TAL wrapper over the `mprotect` syscall, E76-registered at
    the syscall chokepoint (`mprotect` is row 10) and preserve-checked like every
    sys-lib crossing.
  - **Sub-semantic memory, not an effect.** Growth is *substrate*: it does NOT
    ride the effect membrane (same tier as the entry stub). `x-galo`/`x-gbnw`
    stay pure `->` code generators. The `mprotect` syscall inside
    `nb-arena-grow` is still E76-registered and preserve-checked — sub-semantic
    is not unaudited.
  - **One shared stub, not inline growth glue (code-size discipline).** The heavy
    sequence (push the caller-saves, marshal SysV args, call, pop, `ret`) lives
    **once per image** in the `"arena-grow"` stub. Each allocation site emits
    only the inline rel8 check + a 5-byte `call` to it — keeping the compiler
    small (790904B image, 256 KiB initial committed heap), the same ethos as the
    reservation footprint.
  - **Failure is a clean exit, not a returned error and not a `ud2`.**
    `nb-arena-grow` never returns a negative value — when the reservation ceiling
    is exceeded or `mprotect` refuses, it takes `nb-arena-fail`'s
    `exit_group(code)` path. So the growing bump path can never `ud2` (that was
    the old fixed-trap fate) and the stub never has to inspect a sign. Every
    grow either commits more memory and the retry's re-check passes, or the
    process exits cleanly on genuine OOM.
  - **Totality.** The retry loop is bounded: each pass either fits (falls
    through to the commit) or grows-and-retries; a grow that cannot satisfy the
    request exits the process inside `nb-arena-grow`. The loop re-loads
    `heapptr`/`heapend` fresh at the top and recomputes the bump from the
    immediate size, so re-entry is deterministic — no unbounded spin, no
    partial-function escape.
- **The reframing:**
  Conventional C inlines the growth syscall and its policy into every
  allocation. Chirality keeps the growth primitive as a separately-auditable TAL
  wrapper (`nb-arena-grow`), the growth *glue* as one shared per-image stub, and
  the allocator as a pure codegen function that emits an inline check plus a
  named `call` to the stub. The relocation system resolves the address — the
  allocator names the stub, it does not know where the stub lands.
- **What chirality makes impossible here:**
  - You cannot store past `heapend` before checking — the allocators are
    check-first, so exhaustion is caught on the `cmp`/branch, never on a write.
  - You cannot accidentally call `mprotect` from arbitrary code — only
    `nb-arena-grow` has the crossing registered at E76.
  - You cannot forget to recheck after growth — the retry `jmp` is structural.
  - You cannot silently return NULL — a still-exhausted grow does not return:
    `nb-arena-grow` takes its `exit_group` exit, never a null bump.
  - You cannot ship two conflicting allocation policies by accident —
    `specialize-singletons`' loud `count==1` gate permits exactly one fn-bearing
    `Alloc` instance in the blob.
  - `mremap`/`MAYMOVE` never appears — the mapping is fixed, pointers never dangle.

## 5. Chirality example (fleshed — the shipped shape)

### The growing value-cell allocator: inline rel8 check-first grow-retry

The loop top re-loads `heapptr`; the candidate bump goes in `rcx`; `jbe +7`
skips the grow call + back-jmp on a fit; a miss `call`s the one shared
`"arena-grow"` stub and `jmp`s back to the top. The displacements are raw
`a-bytes` (no per-site labels); only `e-call "arena-grow"` is relocated.

```chirality
; x86: 76 07 = jbe +7 (skip the 5-byte call + 2-byte back-jmp when the bump fits)
;      EB E2 = jmp -30 (back to the loop top: re-load heapptr, re-check heapend)
(def x-galo (-> I64 I64 (List I64) (List Asm))
  (lam (dst tag fs)
    (let (sz (* 8 (+ 1 (length I64 fs))))
      (cons (a-rel 7 e-ldheap "heapptr")               ; retry: rax = *heapptr
        (cons (a-bytes (x-lea-bump sz))                ; rcx = rax + sz  (candidate end)
          (cons (a-rel 7 e-cmpheap "heapend")          ; cmp rcx, *heapend
            (cons (a-bytes (bcat (b1 118) (b1 7)))     ; jbe +7  (fits -> commit)
              (cons (a-rel 5 e-call "arena-grow")      ; miss -> grow (NEVER returns <0)
                (cons (a-bytes (bcat (b1 235) (b1 226))) ; jmp -30 -> retry
                  ; --- fits: write the cell and commit the bump ---
                  (cons (a-bytes (bc3 (x-store-tag tag) (x-alo-fields fs 0) (x-store-rax dst)))
                    (cons (a-bytes (x-lea-bump sz))    ; recompute bump
                      (cons (a-rel 7 e-stheap "heapptr")
                        (the (List Asm) nil)))))))))))))
```

`x-gbnw` is the same loop with the byte-cell size sequence
(`(len + 15) & ~7`) instead of `x-lea-bump`; its back-`jmp` is `EB D7`
(`jmp -41`) because the size sequence is longer.

### The one shared `"arena-grow"` stub (in `x-fin`, once per image)

The stub marshals the REAL callee contract and calls `nb-arena-grow`. There is
no sign test and no `stheap heapend` — `nb-arena-commit` publishes the new end
itself (through `nb-put-u64` at the `-8` raw-cell offset).

```chirality
; nb-arena-grow(base=rdi, reserve_end=rsi, need=rdx, heapend_cell=rcx) -> new_end(rax)
;   need = (candidate bump in rcx) - *heapend
(a-label "arena-grow")
  <push caller-saves: rcx rsi rdi rdx r8 r9 r10 r11>
  (a-rel 7 e-ldrsi "heapend")            ; rsi = *heapend
  <48 89 CA  mov rdx, rcx>               ; rdx = candidate bump
  <48 29 F2  sub rdx, rsi>               ; rdx = need = bump - *heapend
  (a-rel 7 e-ldrdi "heapbase")           ; rdi = heapbase (doubling measure)
  (a-rel 7 e-ldrsi "heapreserve")        ; rsi = reserve ceiling
  (a-rel 7 e-learcx "heapend")           ; rcx = &heapend (the tracking cell)
  (a-rel 5 e-call "nb-arena-grow")       ; grow; publishes heapend, or exit_group on OOM
  <pop caller-saves>
  <C3  ret>                              ; back to the caller's jmp -> retry
```

### The reserve-commit entry stub (`entry-stub-v2`, byte-identical to native.py)

```chirality
; mmap(0, reserve-bytes, PROT_NONE, PRIVATE|ANON, -1, 0)   ; 64 GiB reservation
; mprotect(base, init-commit, PROT_RW)                     ; commit a 256 KiB prefix
; heapptr=base ; heapbase=base ; heapend=base+init-commit ; heapreserve=base+reserve-bytes
(def reserve-bytes I64 68719476736)   ; == native.py RESERVE_BYTES (guarded by test_arena_constants)
(def init-commit   I64 262144)        ; 256 KiB == native.py INIT_COMMIT
```

### The single `Alloc` discipline (E81)

There is ONE fn-bearing instance — `alloc-growing`, bare global refs so
`specialize-singletons` rewrites projectors straight to `mach-galo`/`mach-gbnw`.
No `fixed-trap` instance sits beside it (two would trip the loud `count==1`
gate).

```chirality
; alloc.chiral — the sole live Alloc instance.
(def alloc-growing Alloc
  (alloc
    mach-galo                                  ; growing value-cell allocator (x-galo)
    mach-gbnw                                  ; growing byte-cell allocator (x-gbnw)
    (lam (m slot) (the (List Asm) nil))        ; region/drop are no-ops (bump never reclaims)
    (lam (m slot) (the (List Asm) nil))
    (lam (m src)  (the (List Asm) nil))))
```

- **Deliberately omitted / off this path:**
  - The `nb-arena-grow`/`nb-arena-commit` bodies + the `mprotect` crossing —
    E90-REV owns the assembly glue and the syscall; E91 wires them.
  - Thread-safety — single-threaded per process; no `lock cmpxchg`.
  - Multiple growth policies / a second `Alloc` instance — one policy, one
    instance (the singleton gate).

## 6. Use / modify notes

- **Landed in:** `scaffold/lib/mach-x64.chiral` — `x-galo` (:509) / `x-gbnw`
  (:667) hold the inline grow-retry loop; `x-fin` (:537) holds the `"arena-grow"`
  stub + the `heapptr`/`heapbase`/`heapend`/`heapreserve` cells.
  `scaffold/lib/compile-emit.chiral` — `entry-stub-v2` (reserve-commit) +
  `reserve-bytes`/`init-commit` defs. `scaffold/lib/sys-tal.chiral` —
  `nb-arena-grow`/`nb-arena-commit`/`nb-arena-fail` (the `-8` raw-cell offset
  lives here). `scaffold/lib/alloc.chiral` — the sole `alloc-growing` instance.
- **Conformance target (all met, independently verified):**
  - The self-compile grows its own arena: value + byte cells allocated past the
    256 KiB committed prefix grow across ~9 doublings and complete with the
    correct result — never `ud2`/SIGILL on the growing path.
  - Allocating past the reservation ceiling exits via `nb-arena-fail`
    (`exit_group`), never SIGSEGV.
  - Fixpoint reconverges byte-identical (790904B) after each compiler-source
    change; full py suite green (703; `test_arena_constants` parity now
    unskipped and passing); `bin/make-public.sh` sync clean.
- **The `-8` offset is the thing to remember.** Any future code that reads/writes
  a raw arena cell through `nb-get-u64`/`nb-put-u64` must pass `off = -8` to skip
  the boxed-payload `+8` that `ti-bget`/`ti-bput` add — this was the actual bug
  behind three "built but never grew" false summits.
- **Related:** [[E89-arena-init]] (reserve-commit startup: `PROT_NONE` reserve +
  `mprotect` `INIT_COMMIT`), [[E90-arena-grow-crossing]] (`nb-arena-grow`
  `mprotect`-doubling crossing + the shared grow stub),
  [[E76-syscall-chokepoint]] (registers `nb-arena-grow`'s `mprotect` crossing),
  [[E81-alloc-seam]] (the `Alloc` discipline — single-instance home).
</content>
</invoke>
