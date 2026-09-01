> **ARCHIVED 2026-09-01. Superseded. The port these seven dossiers de-risked has LANDED: the checker, the analyses, the pipeline, the substrate and the sys/format layers are chirality in `lib/` and `prog/`. Successors are `docs/examples/` (the worked examples) and `docs/elements/specs/`, both TRACKED.** ⚑ Every source line cited below is an evicted `scaffold/chirality/*.py` path. Nothing here can be re-run. Its cross-family "candidate element" flags were checked 2026-09-01 before archiving and **every one resolved to a minted element** (E51 built, E42 built, E52 design-unresolved, E20/E21/E23/E26/E32 all minted), so no unminted phantom is lost with the file.

# Family 4 — The substrate floor (E20–E27)

**Elements:** E20 loader (W^X mmap→mprotect), E21 mmap-as-arena / pointer rep /
bump wiring, E22 allocator / region types / GC, E23 FFI trampoline (CFUNCTYPE),
E24 I64 two's-complement arithmetic, E25 byte cells `[len][payload]`, E26
alarms / control flow, E27 data-structure registries (dict/set → maps).

**State of the family.** This is the seam between "chirality as a program on CPython"
and "chirality as a program on the metal." The good news the audit found: the *hard
half is already chirality.* The x86-64 backend (`mach-x64.chiral`) emits the whole
bump-allocator inline — RIP-relative `heapptr`/`heapend` cells, bound check, `ud2`
trap, `[len][payload]` byte-cell allocation with 8-byte rounding — and the sys
face (`sys-tal.chiral`) already crosses to the kernel through hand-authored tal.
What remains in Python at this floor is thin and mechanical: a ~40-line ctypes
loader (E20/E23), the arena `mmap` + pointer poke (E21), the reference-drop I64
arithmetic (E24, already value-agreed with native by construction), the reference
`bytearray` cells (E25, likewise), and two genuinely-Python-shaped things — the
alarm exceptions (E26) and the CPython dict/set registries the checker/runtime are
built on (E27). E22 (allocator beyond bump + region *types*) is the one genuinely
UNBUILT item, and it splits cleanly by tier.

The recurring pattern here: **most of these crutches vanish the moment there is an
ELF entry point (E34, family 5) instead of a JIT-into-mmap loader.** E20, E21, E23
are all "the loader does X for the JIT case"; a real executable does X via the ELF
loader + a `_start` that syscalls `mmap` itself. So the family's ordering is
dominated by one external dependency (ELF/E34) and one not-yet-built sys slice
(the `mmap`/`mprotect`/`close` crossings, E28 — the recipe for which is proven by
the existing `lseek`/`memfd`/`ftruncate` slices) that this family should *demand
land first*.

---

## E20 — Loader: RW mmap → W^X mprotect → executable   [REPLACE-CRUTCH · Tier R]

**Lives now:**
- `scaffold/chirality/native.py:104-116` — `_PROT_*` constants, `_libc = ctypes.CDLL(None)`, `_mprotect` wrapper.
- `scaffold/chirality/native.py:404-421` — the load sequence: `mmap.mmap(-1, …, PROT_READ|PROT_WRITE)`, `buf.write(code)`, `addressof`, arena poke, `_mprotect(base, code_end, PROT_READ|PROT_EXEC)`.
- `scaffold/chirality/native.py:419-420` — page rounding: `_PAGE = 4096`, `code_end = offsets.get("heapptr", (len(code)+_PAGE-1) & ~(_PAGE-1))`.
- The emitted side that makes W^X possible: `scaffold/lib/mach-x64.chiral:184-193` (`x-fin`: `(a-align 4096)` then the `heapptr`/`heapend` cells).

**Verdict:** REDO — a scaffold shortcut. It is a JIT-in-mmap loader written in
Python/ctypes. The proper form is not "port these 15 lines to chirality"; it is "emit
an ELF (E34) and let the kernel's loader + a chirality `_start` do it." As long as the
target is JIT, the loader can shrink to the `mmap`/`mprotect`/`close` sys crossings
(E28) called from chirality; as the AOT target (E34) lands, it disappears entirely.

**Explainer.** The W^X invariant is the whole point and it is subtle: the code
region must be *never simultaneously writable and executable*. The current code
maps RW, writes bytes + pokes the arena base into the emitted `heapptr`/`heapend`
cells, *then* flips `[base, code_end)` to R+X. The split point `code_end` is
exactly the `heapptr` offset, because `x-fin` (`mach-x64.chiral:187`) page-aligns
(`a-align 4096`) before laying the two 8-byte heap cells — so everything below the
alignment boundary is code + read-only literals and becomes R+X, while the two
mutable heap-pointer cells stay R+W (the running code bumps `heapptr`). The trap
that isn't obvious: **`heapptr`/`heapend` are data the code mutates, so they must
NOT be in the executable page**; the emitter's page-align in `x-fin` is what makes
the loader's single `mprotect` boundary correct. A self-hosted loader must
reproduce that exact contract or it will either fault (writing R+X memory) or leave
code writable (W^X violation). Also note the code-only fallback at line 420: with
no heap, `code_end` rounds the code length up to a page.

**Translation dossier.**

*Source exemplar* (`native.py:404-421`):
```python
buf = mmap.mmap(-1, max(len(code), 1), prot=mmap.PROT_READ | mmap.PROT_WRITE)
buf.write(code)
base = ctypes.addressof(ctypes.c_char.from_buffer(buf))
...
_PAGE = 4096
code_end = offsets.get("heapptr", (len(code) + _PAGE - 1) & ~(_PAGE - 1))
_mprotect(base, code_end, _PROT_READ | _PROT_EXEC)
```

*Target sketch* — a chirality `nb-sys-mmap` / `nb-sys-mprotect` at the tal floor,
modeled exactly on `nb-sys-lseek` (`sys-tal.chiral:52-55`, an all-integer crossing)
and `nb-sys-write` (`sys-tal.chiral:18-23`, which uses `ti-bptr`+`ti-sys`). `mmap`
takes 6 integer args (addr=0, len, prot, flags, fd=-1, off=0); `mprotect` takes 3.
Both are pure `ti-sys` crossings returning the mapping address / status in a
register:
```
; mmap(0, len, prot, flags, -1, 0) -> address (nr 9)   [modeled on nb-sys-lseek]
(def nb-sys-mmap TFn
  (tfn "nb-sys-mmap" 4 8            ; params: len, prot, flags, fd-or-neg1
    (t-seq (ti-const 4 0)           ; addr = 0 (kernel chooses)
    (t-seq (ti-const 5 0)           ; offset = 0
    (t-seq (ti-sys 6 9 (cons 4 (cons 0 (cons 1 (cons 2 (cons 3 (cons 5 nil)))))))
      (t-ret 6))))))
; mprotect(addr, len, prot) -> 0 (nr 10)                [modeled on nb-sys-ftruncate]
(def nb-sys-mprotect TFn
  (tfn "nb-sys-mprotect" 3 4
    (t-seq (ti-sys 3 10 (cons 0 (cons 1 (cons 2 nil))))
      (t-ret 3))))
```
Both constructs (`ti-sys` with a 6-elt / 3-elt `cons`-list, `ti-const`) appear
verbatim in `sys-tal.chiral`; the sys ABI already loads args in `rdi rsi rdx r10 r8
r9` (`mach-x64.chiral:254-266`), which is exactly the 6-arg `mmap` shape.

*Mechanical recipe.*
1. **NEW (small):** add `nb-sys-mmap`/`nb-sys-mprotect`/`nb-sys-close` sig rows to
   `native.py:90-96` `LIB_SIGS` and the tal defs to `sys-tal.chiral`'s `sys-lib`
   list — this is the standard sys-slice recipe (DOSSIER-SPEC pattern 2). This is
   E28's work; E20 *consumes* it.
2. **TRANSLATE:** the loader's "map RW, write code, flip to R+X" sequence becomes a
   chirality orchestrator that calls `nb-sys-mmap`(RW) → writes bytes (the write is the
   deep part: needs the emitted code *as a byte cell* and a copy into the mapping —
   see E21) → `nb-sys-mprotect`(R+X on `[base, heapptr)`).
3. **NEW (the real work):** who runs this orchestrator? In JIT mode it is still
   driven from Python's `compile()`. **The honest end state is ELF (E34):** no
   loader at all, the kernel maps R-X text and R-W data per the program headers.
   *Finding:* chirality has no construct today for "get the address of a freshly-mapped
   region as a value you can write into and then call" — that is E21+E23's gap, not
   a syntax chirality already has. Say so; do not sketch a fake `call-address` op.

**Dependencies:** needs E28 (`mmap`/`mprotect`/`close` sys crossings) first;
ultimately subsumed by E34 (ELF). Unblocks nothing else directly — it is a
consumer.

**Est. pass size:** M as a JIT-loader port (mostly E28 + the E21 write path); the
proper AOT version is gated on E34 and is really E34's pass.

---

## E21 — mmap as the arena; pointer representation; bump base/end wiring   [REPLACE-CRUTCH · Tier R]

**Lives now:**
- `scaffold/chirality/native.py:47` — `ARENA_BYTES = 1 << 20`.
- `scaffold/chirality/native.py:410-418` — the arena `mmap`, `abase = addressof(...)`, and the two `struct.pack("<q", abase)` / `abase+ARENA_BYTES` pokes into the emitted `heapptr`/`heapend` cells; `self._heap = (buf, offsets["heapptr"], abase, abase+ARENA_BYTES)`.
- `scaffold/chirality/native.py:433-448` — `alloc_bytes`: the Python-side test path that materializes a `[len][payload]` cell in the live arena (bump `heapptr`, `memmove`, 8-round `size = 8 + ((len+7) & ~7)`).
- **The chirality side that already bumps:** `scaffold/lib/mach-x64.chiral:159-193` (`x-alo`, `x-fin`) and `:216-225` (`x-bnw`): RIP-relative `enc-ldheap`/`enc-cmpheap`/`enc-stheap` on `"heapptr"`/`"heapend"`, `ud2` trap past `heapend`.

**Verdict:** EXTEND — the *bump allocator itself is already chirality* (`mach-x64.chiral`,
inline in every allocation site). What is a crutch is only (a) *where the arena
memory comes from* (Python `mmap.mmap`) and (b) *how the base/end pointers get into
the emitted cells* (Python `struct.pack` poke). Both are one `mmap` sys crossing +
one store away from being chirality-native. The pointer representation is already
correct and load-bearing: a heap value is one machine word (a raw address into the
arena); `_word_rep` (`native.py:208-228`) documents the four word-shapes (I64, enum
tag, byte-cell ptr, boxed-cell ptr).

**Explainer.** The arena contract is: a single contiguous RW region; `heapptr`
starts at `base`, `heapend = base + size`; every allocation bumps `heapptr` after a
`cmp rcx, heapend` bound check (`x-alo`, `mach-x64.chiral:166-178`); past-end faults
via `ud2` (`x-trap`, line 157). The region "frees as a unit" when the batch drops
(this is the linear/region discipline of `memory-model.md` at the metal — no GC,
no per-object free). The subtlety a self-hosted version must preserve: **the emitted
code references `heapptr`/`heapend` RIP-relative** (`enc-ldheap` = `mov rax,
[rip+d]`), so the cells must be laid out at a known offset *inside the same mapped
image as the code* and the loader only has to write the two initial values. The
current split — code in one `mmap`, arena in a *second* `mmap`, base poked in — is a
scaffold convenience; note the arena is a *separate* region from the code, but the
`heapptr`/`heapend` cells live with the code (page-aligned tail via `x-fin`). A
self-hosted loader keeps that: map code image, map arena, store `arena_base` /
`arena_base+size` into the two cells, then W^X the code.

**Translation dossier.**

*Source exemplar* (`native.py:410-416`):
```python
arena = mmap.mmap(-1, ARENA_BYTES, prot=mmap.PROT_READ | mmap.PROT_WRITE)
abase = ctypes.addressof(ctypes.c_char.from_buffer(arena))
buf[offsets["heapptr"]:offsets["heapptr"]+8] = struct.pack("<q", abase)
buf[offsets["heapend"]:offsets["heapend"]+8] = struct.pack("<q", abase+ARENA_BYTES)
```

*Target sketch.* The `mmap` half is a chirality `nb-sys-mmap` call (see E20 sketch).
The pointer *representation* is already what the emitter assumes (a raw word). What
chirality lacks: **a store of a computed address into a specific code-image offset from
chirality.** Today that store is Python `buf[off:off+8] = struct.pack(...)`. There is no
chirality construct for "write 8 bytes at absolute address A" at the tal floor — `ti-bput`
writes *one byte into a byte cell* (`tal.py:138-140`), not an arbitrary word into an
arbitrary address. *Finding (NEW construct needed):* a word-store-to-address primitive
(or: emit the arena `mmap` from a chirality `_start` that then stores base into the cells
before jumping to `main`). This is the same missing piece as E20 step 3. Do not
sketch it against existing syntax — it is genuinely new floor vocabulary.

Note the existing `memfd_create`+`ftruncate` slices (`sys-tal.chiral:63-79`) are
explicitly described as "the first half of a chirality-side arena" — the plan is memfd →
ftruncate → **mmap** the memfd. E21's proper pass finishes that chain.

*Mechanical recipe.*
1. **COPY:** `ARENA_BYTES` and the size/round math are already mirrored in chirality
   (`x-bnw` rounds `(len+15)&~7`, `mach-x64.chiral:203-205`). Nothing to port.
2. **TRANSLATE:** `mmap.mmap(-1, ARENA_BYTES, RW)` → `nb-sys-mmap` call (E28 dep).
   Chain it after the existing `memfd_create`+`ftruncate` slices if a file-backed
   arena is wanted, or anonymous `MAP_ANONYMOUS` for the simple case.
3. **NEW:** the base/end store into the emitted cells (word-store-to-address, above)
   — small but genuinely new. This is the element's real pass content.

**Dependencies:** E28 (`mmap`). Shares the word-store gap with E20/E23. Unblocks a
fully self-hosted JIT loader.

**Est. pass size:** S once E28 lands and the word-store construct is decided.

---

## E22 — Allocator / region types / GC-outside-TCB (beyond bump)   [BUILD-PROPER · Tier P (region types) + Tier F (allocator)]

**Lives now:**
- Bump arena only: `scaffold/lib/mach-x64.chiral:159-193` (native), `native.py:410-418` (loader wiring).
- Discipline libraries (NOT the type feature): `scaffold/lib/mem-linear.chiral` (linear `(Pool n)`, `mem-put`/`mem-put-checked`/`mem-drop`), `scaffold/lib/mem-region.chiral` (a `Region` = linear pool + runtime `cap` + `used`, `mem-alloc`/`mem-write`/`mem-stow`/`region-avail`/`region-close`).
- Reference pool impl (the crutch under the discipline libs): `scaffold/chirality/impl_ports.py:174-207` (`pool-create` via `os.memfd_create`+`ftruncate`+`mmap`; `pool-close` zeroizes then `close`; `pool-write` bounds-checks).
- Design: `docs/open-edges.md` edge 3 (cost/region gradient), `docs/memory-model.md:99-146` ("region" does two jobs; region *types* deferred).

**Verdict:** UNBUILT (region *types*) + PROPER-in-miniature (the bump/region
*discipline*). Two distinct things wear the word "region" (`memory-model.md:132-146`
warns of exactly this trap): (1) the **region library** — a linear pool + cursor,
built and working (`mem-region.chiral`), with a *runtime* capacity witness `cap` it
branches on; (2) **region types** — the deferred type-system feature that would make
the offset itself typed and *retire* that runtime bound check. (1) is done; (2) is
edge 3, unbuilt.

**Explainer.** The current discipline is: linearity gives conservation (a `Region`
is a linear resource, threaded, dropped once, frees as a unit — `mem-region.chiral:15-17`),
and the *static size lives in the type* as an erased index `n` (quantity 0), so
nothing branches on `n` at runtime; instead a runtime witness `cap` (agreeing with
`n` by construction) is what `mem-alloc` checks (`mem-region.chiral:8-13`, `:37-44`).
The trap the doc names explicitly: `mem-region.chiral:11-13` — "Refinement types
would make the offset itself typed and retire the runtime check; that is deferred,
edge 3." So **E22's proper pass is exactly the refinement/region-types integration
that `mem-put-checked` (`mem-linear.chiral:26-28`) already anticipates**: it takes a
`(refine I64 (>= 0) (< n))` offset and forgets it to base I64. The refinement
module (family 1, E9/E41) is the enabling work; E22 is the *consumer* that turns
"discipline library with runtime checks" into "type-discharged offsets." GC-outside-
TCB is a further, separate design item (edge 3) with no scaffold at all.

**Translation dossier.**

*Source exemplar* — the anticipation is already written (`mem-linear.chiral:26-28`):
```
(def mem-put-checked
  (-> (0 n I64) (=> (1 p (Pool n)) (refine I64 (>= 0) (< n)) Bytes (Pool n)))
  (lam (n p off bs) (pool-write n p off bs)))   ; forget the refinement to the base I64
```
and the runtime-witness check it aims to retire (`mem-region.chiral:41`):
```
(case (<=i (+ used len) cap) (true ...) (false (halt ...)))
```

*Target sketch.* The Tier-F half (a real allocator with free-lists beyond bump) is
a new chirality library modeled on `mem-region.chiral`'s constructor+linear-threading
style — a `data Region`/`data AllocR` plus recursive functions, all constructs that
already appear there. The Tier-P half (region *types*) is **not sketchable in
today's syntax**: it needs the type system to carry the offset bound and discharge
the `<=i … cap` check statically. *Finding:* the `(refine I64 (>= 0) (< n))`
surface already parses (it's in `mem-linear.chiral`), so the *type* is expressible;
what's missing is the checker actually using it to eliminate the runtime witness at
a concrete pool. That is E9/E41 checker work, flagged to family 1.

*Mechanical recipe.*
1. **Tier F allocator (NEW, self-contained):** new lib modeled on `mem-region.chiral`;
   read dlmalloc/arena literature (policy allows source). Bounded, no identity stake.
2. **Tier P region types (NEW, gated):** land refinement-typed offsets in the checker
   (family 1), then *delete* the `cap`/`used` runtime witness from `mem-region.chiral`,
   replacing the `<=i` guard with a type obligation. This is the payoff of edge 3.
3. **GC:** design-only; leave UNBUILT, cite edge 3.

**Dependencies:** E9 (refinement decision proc) + E41 (region types) — both family 1.
Unblocks retiring runtime bounds checks across `mem-*` and the native `x-trap`.

**Est. pass size:** L — slice into (a) Tier-F allocator library [S], (b) region-type
integration once E9/E41 land [M], (c) GC design [separate, out of family].

---

## E23 — FFI trampoline (CFUNCTYPE native entry)   [REPLACE-CRUTCH · Tier R (`OURS`)]

**Lives now:**
- `scaffold/chirality/native.py:422-431` — `ctypes.CFUNCTYPE(c_int64, *argtypes)(addr)`; `cfn._chirality_buf = buf` (pins the buffer so it can't be unmapped under the callable).
- `scaffold/chirality/native.py:328-341` — `decode`: reads native words back into runtime values via `ctypes.cast`/`string_at` (the return-value half of the shuttle).
- Reference side's analogous crutch: `scaffold/chirality/tal.py:263-279` (`TalMachine._sys` via `ctypes.CDLL(None).syscall`; `_bptr` via `from_buffer`).

**Verdict:** REDO — but the honest note from the catalog (E23 row: "disappears with
a real entry point / ELF") is correct: this crutch **has almost no independent
replacement work; it evaporates when there is an ELF entry point (E34).** The
CFUNCTYPE call is "how CPython calls into a JIT'd buffer." A chirality executable has a
`_start`; there is no host language on the other side of the FFI boundary to
trampoline from.

**Explainer.** CFUNCTYPE does exactly two things: (1) reinterpret an integer address
as a callable with a C ABI signature (all args `c_int64`, return `c_int64` — which
matches the SysV convention the emitter targets, `mach-x64.chiral:3`), and (2) keep
the executable buffer alive (`_chirality_buf`). The subtlety worth recording: **every
chirality native function is `(int64, …) -> int64` at the ABI** — boxed values are
passed/returned as raw pointer words, and `decode` (`native.py:321-341`) is what
re-inflates a returned word into a runtime value by walking heap cells. That decode
step is *not* a crutch that disappears — it is the "read a native result back" logic
that any embedding (test harness, REPL) needs; but in a pure-chirality program the
result never crosses back into a host, so decode is test-only. The trampoline proper
(the CFUNCTYPE) is pure JIT-glue.

**Translation dossier.**

*Source exemplar* (`native.py:424-429`):
```python
argtypes = [ctypes.c_int64] * len(f.params)
cfn = ctypes.CFUNCTYPE(ctypes.c_int64, *argtypes)(addr)
cfn._chirality_buf = buf
```

*Target sketch.* There is no chirality-syntax sketch, because the proper form is the
*absence* of a trampoline: an ELF `_start` (E34) that calls `main` directly. *Finding:*
the only construct that would let chirality "call an address computed at runtime" is the
same word-store/indirect-call floor vocabulary E20/E21 flagged as missing — an
indirect `call rax`. The emitter today only emits *direct* rel32 calls (`enc-call`,
`mach-x64.chiral:126`; `a-rel 5 enc-call fname`, `:304`). So a self-hosted JIT that
called its own output would need an indirect-call op the backend doesn't have.
That's a real new finding, not a port.

*Mechanical recipe.*
1. **DELETE on E34:** once ELF lands, the trampoline is gone — the kernel enters
   `_start`. No port.
2. **If a JIT REPL is still wanted (NEW):** add an indirect-call floor op (`call
   rax`) to `mach-x64.chiral` and a chirality loader that jumps to the mapped base.
   Small, but genuinely new backend vocabulary.
3. **KEEP (test-only):** `decode` stays as embedding glue; it is not on the program's
   own critical path.

**Dependencies:** E34 (ELF) makes it disappear; otherwise needs the indirect-call op.
Unblocks: nothing — pure consumer.

**Est. pass size:** S (delete-on-ELF) or S+ (indirect-call op for a JIT REPL).

---

## E24 — I64 two's-complement arithmetic (bignum reference is a crutch)   [REPLACE-CRUTCH · Tier R (`SPEC`)]

**Lives now:**
- `scaffold/chirality/impl_pure.py:19-45` — `_I64_MIN`, `_I64_MOD`, `wrap64`, `i64_div`, `i64_mod` (the single source of truth).
- `scaffold/chirality/impl_pure.py:57-80` — the extern bindings `+ - * / % =i <i <=i`.
- `scaffold/chirality/optimize.py:28,42-50` — the const-folder imports `wrap64/i64_div/i64_mod` so a fold cannot diverge from the runtime.
- **Native side (already agrees, natively):** `scaffold/lib/mach-x64.chiral:66-109` (`x-add/x-sub/x-imul`; `x-cqo`+`x-idiv-rcx`+`x-div-fix`/`x-mod-fix` — the branchless truncated→Euclidean correction via `cmovs`).
- TAL range check: `scaffold/chirality/tal.py:102-103` (const must be in `[-2^63, 2^63)`).

**Verdict:** PROPER, in the sense that matters — this is a *settled floor-agreement
decision*, not a shortcut to redo. The catalog calls the bignum reference "a crutch"
but the audit's honest read: CPython's arbitrary-precision int is the *reference
oracle*, and `wrap64`/`i64_div`/`i64_mod` reduce it into the exact two's-complement /
Euclidean semantics the native code implements. Reference and native **agree on
values by construction** (DOSSIER-SPEC pattern 4; `chirality-division-euclidean` memory).
The only "crutch" is that the reference *computes* in bignum then wraps, rather than
in a real 64-bit register — but that is the correct shape for a *reference*
interpreter (E15) and does not need replacing; the native drop already does the
register arithmetic.

**Explainer.** The load-bearing invariant: I64 is two's-complement 64-bit (`+ - *`
wrap, `impl_pure.py:23-25`), and `/`/`%` are **Euclidean** (`0 <= r < |b|`), matching
SMT-LIB div/mod so a solver-discharged refinement means at runtime what it proved
(`impl_pure.py:14-17`). Do NOT re-argue floor-vs-truncate (settled 2026-07-06,
`docs/decision-inspiration-policy.md`, `chirality-division-euclidean` memory). The
non-obvious trap: the native side gets Euclidean from x86 `idiv` (which *truncates*)
via a branchless correction (`x-div-fix`/`x-mod-fix`, `mach-x64.chiral:99-109`) that
fires exactly when the truncated remainder is negative — a self-hosted reference must
match that, and it does because both go through the same `i64_div`/`i64_mod` law and
`emit-x64` was written to that law. When the *reference interpreter* self-hosts (E15,
family 2), these three functions are the arithmetic it needs — they port to chirality I64
ops trivially since chirality I64 *is* the two's-complement type.

**Translation dossier.**

*Source exemplar* (`impl_pure.py:28-35`):
```python
def i64_div(a, b):
    if b == 0: return None
    r = a % b
    if r < 0: r += abs(b)
    return wrap64((a - r) // b)   # (a-r) is an exact multiple of b
```

*Target sketch.* When the reference interpreter self-hosts, `i64_div` in chirality is a
direct transcription — every op it needs (`%`, `<i`, `+`, `-`, `/`) is a native
prim, and division-by-zero becomes a `halt` alarm (see E26). Modeled on the recursive
arithmetic already in `bytes-tal.chiral` (e.g. `nb-digits`, `:205-219`, which uses
`/` and `<i`):
```
(def i64-div (-> I64 I64 I64)          ; assumes b /= 0 (caller guards, halts)
  (lam (a b)
    (let (r (% a b))                    ; % already Euclidean-native
      (/ (- a r) b))))                  ; native / on an exact multiple
```
*Note:* chirality's native `%` is **already Euclidean** (`impl_pure.py:38-45` and the
native `x-mod-fix`), so the Python `if r<0: r+=abs(b)` correction is *unnecessary in
chirality* — the reduction is baked into the prim. That is a simplification the port
gets for free. Constructs used (`let`, `%`, `-`, `/`) all appear in
`bytes-tal.chiral`/`emit-x64.chiral`.

*Mechanical recipe.*
1. **COPY (semantics):** the two's-complement + Euclidean law is fixed; no decision.
2. **TRANSLATE:** `i64_div`/`i64_mod`/`wrap64` → chirality using native prims; drop the
   sign-correction (native `%` already does it). Rule: Python-bignum-then-wrap
   collapses to a single native op because chirality I64 *is* the wrapped type.
3. **NEW:** none. This is the cleanest element in the family.

**Dependencies:** none for the semantics; the *port* rides on E15 (reference
interpreter self-hosts, family 2). Unblocks the arithmetic floor of a self-hosted
reference + optimizer.

**Est. pass size:** S — trivial once the reference interpreter is chirality.

---

## E25 — Byte cells `[len][payload]` (bytearray reference is a crutch)   [REPLACE-CRUTCH · Tier R (`OURS`)]

**Lives now:**
- **Reference (crutch):** `scaffold/chirality/tal.py:237-243` (`bnew` → `bytearray`, `bget`/`bput`/`blen` over it) and `:273-279` (`_bptr` via `from_buffer`).
- **Native cells (proper):** `scaffold/lib/mach-x64.chiral:195-238` (`x-bnw`/`x-bgt`/`x-bpt`/`x-bln`, and `x-dat` literal cells `:245-251`) — the real `[len][payload]`, 8-rounded.
- **The library over cells (proper, chirality):** `scaffold/lib/bytes-tal.chiral` (the whole `nb-*` family: `nb-blen`, `nb-bget`, `nb-copy`, `nb-bcat`, `nb-bslice`, packing, `nb-i64s`, search).
- Decode side: `scaffold/chirality/native.py:326-330` (`string_at(val+8, n)` reads a native cell back).

**Verdict:** REDO (the reference cell), but the target already exists — this is the
most-completed element in the family after E24. The `bytearray` in `TalMachine` is a
Python stand-in for the native `[len][payload]` cell; the *native* representation and
the *entire byte-manipulation library* are already chirality (`bytes-tal.chiral`,
preserve-checked). The redo is narrow: make the reference machine agree with the
native layout, or (better) note that once the reference interpreter itself self-hosts
(E15) it will allocate real cells from the same arena and the `bytearray` vanishes.

**Explainer.** The cell layout contract, documented precisely so the pass is
mechanical (this is the "write it down" ask): **a Bytes/Str value is one machine word
= a pointer to a cell laid out as `[len: 8 bytes little-endian][payload: len bytes][pad
to 8]`.** Size of a cell = `8 + ((len + 7) & ~7)` (`native.py:442`; native `x-bnw`
computes `(len+15)&~7` = the len word + rounded payload, `mach-x64.chiral:203-205,219-221`).
The payload address (what a syscall wants) is `cellptr + 8` (`x-bpr`, `mach-x64.chiral:285-290`;
`ti-bptr`). Str and Bytes share one layout, so one library serves both — the shuttle
maps `str-cat`→`nb-bcat`, `str->bytes`/`bytes->str`→`nb-id` (`native.py:53-65`,
`bytes-tal.chiral:1-13`). Honest scaffold limits already documented: strings are
byte-indexed UTF-8 (coincides with host on ASCII); `bput` is an init-write not
forbidden after escape (`tal.py:26-33`); the library uses recursion not loops so very
large buffers can exhaust the stack (`bytes-tal.chiral:10-13`).

**Translation dossier.**

*Source exemplar* — the crutch (`tal.py:237-243`):
```python
elif op == "bnew":  regs[ins[1]] = bytearray(regs[ins[2]])
elif op == "bget":  regs[ins[1]] = regs[ins[2]][regs[ins[3]]]
elif op == "bput":  regs[ins[1]][regs[ins[2]]] = regs[ins[3]] & 255
elif op == "blen":  regs[ins[1]] = len(regs[ins[2]])
```
— vs the proper native form (`mach-x64.chiral:216-225`, `x-bnw`), which allocates a
real `[len][payload]` cell from the bump arena with the bound check.

*Target sketch.* No new chirality is needed — the target is `bytes-tal.chiral`, which
*already exists and is checked*. The only work is deleting the `bytearray` path when
the reference interpreter self-hosts. If a chirality reference interpreter needs its own
cell ops, they are exactly `ti-bnew`/`ti-bget`/`ti-bput`/`ti-blen` (`tal-ir.chiral`,
used throughout `bytes-tal.chiral`).

*Mechanical recipe.*
1. **COPY:** the layout contract above is fixed and already implemented natively.
2. **TRANSLATE:** the reference `bytearray` ops map 1:1 to the arena cell ops; when
   the reference interpreter (E15) allocates from the arena, the map is exact.
3. **NEW:** none — the library is already chirality.

**Dependencies:** rides on E15 (reference self-hosts) + E21 (arena). Unblocks nothing
new; it is the data model everything above already assumes.

**Est. pass size:** S — mostly deletion, once E15/E21 land.

---

## E26 — Alarms / control flow (exceptions-as-control-flow is a crutch)   [REPLACE-CRUTCH · Tier P → ties E39/edge 16]

**Lives now:**
- `scaffold/chirality/alarms.py` — `MetisExit(code)`, `MetisHalt`, `PortError` (Python exceptions).
- **Raised at:** `impl_ports.py:59` (`exit`→`MetisExit`), `:64` (`halt`→`MetisHalt`), `:82/96/107/116/131/140/149/177/198` (port ops → `PortError`); `impl_pure.py:66/74/112/123/134/141` (div/mod-by-zero, bget/brepeat/unpack range → `PortError`); `bridge.py:85` (type-mismatch at a crossing → `PortError`).
- **Caught at:** `cli.py:91-97` and `:137-143` (the two run loops turn `MetisExit`→exit code, `MetisHalt`/`PortError`/`RuntimeErrorChirality`→stderr + code 1); `runtime.py` imports them (`:25`).
- **Native analogue:** `mach-x64.chiral:155-157` (`x-trap` = `ud2` on arena overflow — a hardware fault, the metal's "halt").
- Design: `docs/error-and-alarm.md` (alarm = typed effect, response = counter-effect), `docs/open-edges.md` edge 16 (the effect mechanism).

**Verdict:** REDO — and specifically, **it should become the effect-algebra story
(E39 / edge 16), not be ported as-is.** This is the most important judgment in the
family. The catalog row for E26 says as much ("ties E12/edge 16"), and `error-and-alarm.md`
is unambiguous: "An alarm is not an out-of-band exception… it is raised as a typed
effect, in the same port and effect algebra as everything else… total: code cannot
drop an alarm without the drop showing in its type." Python exceptions are the
*exact anti-pattern* the design rejects (out-of-band, invisible in the type). So the
proper form is not "reimplement `MetisHalt` in chirality"; it is "alarms are typed
effects with counter-effect handlers," which is an unbuilt type-system feature (E39,
edge 16).

**Explainer.** There are really three different things bundled in `alarms.py`, and
they don't all resolve the same way:
1. **`MetisExit`** — normal program termination with a code. This is the `exit`
   effect; it maps to the `exit(2)` syscall (family 4/E32) and needs no exception
   machinery — a self-hosted `main` returns/ syscalls directly.
2. **`MetisHalt`** — the deliberate fatal alarm ("what diverged"). At the metal this
   is already `ud2` (`x-trap`). At the language level it is the `halt` counter-effect
   from the named set (`error-and-alarm.md:36-41`: re-key/re-derive/relocate/repair/
   quarantine/**halt**). This is the one that must become a typed effect.
3. **`PortError`** — a protocol/range divergence at a crossing (bridge type mismatch,
   div-by-zero, out-of-range `bget`). These are *the alarms* `error-and-alarm.md`
   describes — "this does not agree with the rest" — and each should be a *named,
   typed, recoverable-or-fatal* effect, not a catch-all Python exception.

The trap that isn't obvious from the code: **the scaffold flattens all three into
`try/except` at the CLI boundary** (`cli.py:91-97`), which is precisely the
"unnamed failure path is the gap" the thesis warns against (`error-and-alarm.md:20`).
Porting that structure to chirality would import the anti-pattern. The honest end state:
totality (already built) proves a process *ends*; the effect algebra (E39) makes
*whether it diverged and how it's answered* visible in the type. Div-by-zero
(`impl_pure.py:66`) is the sharp test case — the refinement/effect system should
either prove the divisor non-zero or make the alarm typed.

**Translation dossier.**

*Source exemplar* (`impl_ports.py:57-64`, `cli.py:91-93`):
```python
@impl("exit")
def _exit(_A, code): raise MetisExit(code)
@impl("halt")
def _halt(_A, msg): raise MetisHalt(msg)
...
except MetisExit as e:  return e.code
except MetisHalt as e:  print(f"chirality: alarm (halt): {e}", ...); return 1
```
The chirality surface *already has `halt`* as a typed operation returning any type —
`mem-region.chiral:43-44`: `(halt (AllocR n) "region: allocation past capacity")`,
and `mach-x64.chiral:122`: `(halt Bytes "emit: unknown prim …")`. So `halt` is a
first-class chirality term today (it inhabits any type, like `absurd`); the *exception*
is only its scaffold *implementation*.

*Target sketch.* This is a **finding, not a sketch**: the proper mechanism is edge 16,
undecided between "algebraic effects with resumable handlers," "typed result rows," or
another shape (`error-and-alarm.md:52-58`, `open-edges.md:166`). chirality has no
effect-handler / typed-alarm-row syntax today. What *does* exist to build on:
- `halt` as a total term inhabiting any type (above) — the fatal branch is expressible.
- the coarse effect bit (`->` pure vs `=>` process, `effects.py`, E12) — the one bit
  that must grow into the algebra.
Do NOT invent handler syntax. The pass-ready artifact this element needs is the edge-16
decision (an ADR picking the effect mechanism), which is family-6 / E39 work.

*Mechanical recipe.*
1. **NEW (design, gated):** resolve edge 16 (E39) — pick the effect mechanism. Until
   then E26 cannot be "ported," only stubbed.
2. **TRANSLATE (the easy third):** `MetisExit` → an `exit(2)` sys crossing (E32); no
   effect machinery needed. This slice is independent and can land early.
3. **REDO (the hard two):** `MetisHalt`/`PortError` become typed effects once E39
   lands; `halt` the term already exists, so it is the *handler/typing* that is new.

**Dependencies:** E39 / edge 16 (the effect mechanism) — family 6. E12 (effect
membrane) is the seed. The `exit` slice depends only on E32.
**Cross-family flag:** E26 is really the substrate-visible face of E39; recommend the
two be planned together.

**Est. pass size:** M — but blocked on an edge-16 decision; unblocked slice (`exit`
via syscall) is S.

---

## E27 — Data-structure registries (dict/set → chirality maps)   [REPLACE-CRUTCH · Tier P]

**Lives now (the CPython dict/set inventory a self-hosted checker must replace):**

*The kernel `Sig` — the load-bearing registries* (`scaffold/chirality/kernel.py:115-150`):
- `:115` `global_types = {}`  `:116` `global_defs = {}`  `:117` `global_values = {}`
- `:118` `_evaluating = set()`  `:119` `prim_types = {}`  `:120` `prim_arity = {}`
- `:121` `atom_types = {}`  `:122` `linear_data = set()`
- `:124` `ext_check = {}`  `:125` `ext_eval = {}` (+ the other hook dicts nearby)
- `:129` `totality = {}`  `:146` `data = {}`  `:147` `ctor_home = {}`
- `:148` `targets = {}`  `:149` `profiles = {}`  `:150` `prim_is_port = {}`
- `:214` `_seen = set()`

*The tal checker* (`scaffold/chirality/tal.py`):
- `:79` `fn_sigs = {}`  `:85` `regty = {}`  `:170` `covered = set()`  `:178` `dict(regty)`  `:184` `set(order)`

*Data checker* (`scaffold/chirality/data.py`): `:202` `covered = set()`, `:242` `set(decl.order)`, `:626` `dec = set()`, `:676/701` `dict(size)`, `:683` `dict(bounds)`.

*Runtime* (`scaffold/chirality/runtime.py`): `:43` `globals = {}`, `:49` `_result_ty = {}`, `:29` `IMPLS = {**IMPL_PURE, **IMPL_PORTS}`.

*Lowering* (`scaffold/chirality/lower.py`): `:60` `ctors = {}`, `:89` `out = {}`, `:289` `lowered = {}`, `:290` `skipped = {}`.

*Optimizer* (`scaffold/chirality/optimize.py`): `:33` `_PURE_NOALLOC` set, `:34` `_FOLDABLE` set, `:94` `dict(cenv)`, `:158` `used = set()`, `:243` `remap = {}`.

*Surface/other:* `surface.py:47` `loaded = set()`, `:180/199` profile port sets, `:456` `out = {}`; `refine.py:67` `set(ex)`; `bridge.py:19` `_ATOM_TAG` dict; `terms.py:14` `LIT_TYPE` dict; `native.py:241` `ctor_tag = {}`, `:395` `offsets = {}`, `:365-368` `lib_tal`/`fn_sigs`.

**Verdict:** EXTEND — the replacement target *exists in miniature* but is nowhere
near ready. `scaffold/lib/collections.chiral` already provides the association-list
"map until there is a better map": `alist-get`/`alist-put`/`alist-has` keyed by a
caller-supplied equality (so one alist serves Str and I64 keys), plus `length`/`append`/
`map-list`/`filter`/`foldl`/`any-list`. Its own header states the intent: "This is the
library floor the self-hosted checker will stand on (the Sig registries become
association lists before they become anything faster)" (`collections.chiral:1-6`). So
E27 is: (1) as the checker self-hosts (family 1), every `Sig` dict becomes an
`(List (Pair K V))` via `alist-*`; (2) *later*, alists become real hash maps or
balanced trees (Tier P) for performance.

**Explainer.** The subtlety: **not every Python dict/set is a "registry" — most are
transient local scratch** (`regty` in the tal checker, `covered` sets for coverage,
`dict(size)`/`dict(bounds)` in the refinement walk, `remap` in the optimizer). Those
port to whatever the self-hosted algorithm uses locally (often an alist or a fold-
accumulated `List`). The *true registries* — the ones that are the checker's state —
are the `Sig` fields (`kernel.py:115-150`): `global_types`, `global_defs`, `data`,
`ctor_home`, `totality`, `profiles`, the hook tables. Those are what `collections.chiral`
targets. The honest performance note: alists are O(n) lookup; a self-hosted checker on
alists will be *correct but slow*, which is fine for bootstrap (`collections.chiral:5-6`:
"the checker runs upper during bootstrap") and is the explicit staging plan. The Tier-P
upgrade to hash maps / balanced trees is deferred and identity-bearing (build clean from
papers, don't lift an impl).

**Translation dossier.**

*Source exemplar* — a representative registry (`kernel.py:115-117,146-147`):
```python
self.global_types = {}   # name -> type_value
self.global_defs = {}    # name -> term (closed)
...
self.data = {}           # dname -> DataDecl
self.ctor_home = {}      # cname -> dname
```
*and the target it maps to* (`collections.chiral:61-84`):
```
(def alist-get (-> (0 K (type 0)) (0 V (type 0))
                   (-> K K Bool) (List (Pair K V)) K (Maybe V)) ...)
(def alist-put (-> ... (List (Pair K V)) K V (List (Pair K V))) ...)
```

*Target sketch.* A `Sig` becomes a record of alists; `global_types` is
`(List (Pair Str TypeValue))`, looked up with `(alist-get Str TypeValue str-eq env
name)`. `str-eq` is the native prim (`impl_pure.py:85`); every construct here
(`alist-get`, `Pair`, `str-eq`, `Maybe`) already exists in `collections.chiral`/
`prelude.chiral`. A set (e.g. `_evaluating`, `loaded`) becomes an `(List Str)` with a
membership `any-list`/`alist-has`. *Finding:* there is no record/telescope for a
heterogeneous `Sig` struct yet (that is E48, dependent records, `data.py:134` limit) —
so the self-hosted `Sig` is either many separate alist parameters threaded together, or
waits on E48. Flag: the *shape* of the self-hosted `Sig` gates on E48.

*Mechanical recipe.*
1. **TRANSLATE (registries):** each `Sig.<field> = {}` → an `(List (Pair K V))` field;
   `d[k]` → `alist-get`, `d[k]=v` → `alist-put`, `k in s` → `alist-has`/`any-list`.
   Rule: key type picks the equality (`str-eq` for name keys). Rides on family-1 self-host.
2. **TRANSLATE (local scratch):** `covered`/`regty`/`remap` etc. become fold-threaded
   `List`s in the self-hosted algorithm — local, not registry.
3. **NEW (Tier P, deferred):** alists → hash maps / balanced trees for speed. Clean-room
   from papers.
4. **Finding:** heterogeneous `Sig` needs E48 (dependent records) or a
   many-threaded-parameter workaround.

**Dependencies:** family-1 self-hosting (the checker) drives it; the `Sig` struct shape
gates on E48 (family 6). Unblocks a self-hosted checker's state model.
**Cross-family flag:** E48 (dependent records) blocks a clean self-hosted `Sig`.

**Est. pass size:** L — sliced by consumer: (a) the `Sig` registries [M, with family 1],
(b) transient scratch [folds into each algorithm's self-host], (c) the hash-map upgrade
[S–M, deferred].

---

# Family footer

## Redo list (ranked by how much it poisons downstream work)

1. **E26 alarms (REDO → E39).** The worst poison: `try/except` at the CLI is the
   exact anti-pattern the design rejects (unnamed failure path). Porting it would
   import the anti-pattern into chirality. It is blocked on an edge-16 / E39 decision, so
   it also *delays* anything that wants typed error handling. Highest priority to get
   a decision on, even though the code is small.
2. **E20 loader (REDO).** JIT-in-mmap ctypes loader. Poisons the "chirality on the metal"
   story until ELF (E34) lands; every "self-hosted" claim has an asterisk while the
   loader is Python. Gated on E28 (mmap sys crossing) for the interim chirality-JIT loader.
3. **E27 registries (EXTEND, but broad).** Not poisonous (alists exist, bootstrap is
   fine slow) but *touches every checker module*, so it is the largest surface. Its
   `Sig`-shape gate on E48 could stall a clean self-host.
4. **E23 trampoline / E25 reference cells / E21 arena poke** — all REDO/EXTEND but
   *shallow*: they evaporate on ELF (E23) or on the reference-interpreter self-host
   (E25) or on one mmap crossing (E21). Low poison.
5. **E24** — not a redo at all; a settled floor-agreement. Listed only to say: leave it.

## Ordering (dependency-respecting sequence)

1. **E28 first (family 4/syscall):** `mmap`/`mprotect`/`close` sys crossings. Every
   other substrate item that isn't pure-chirality-already needs these. (Flag to family-4
   syscall auditor: this family *demands* E28.)
2. **E21** (arena via `nb-sys-mmap` + the base/end store) — needs E28 + the word-store
   decision.
3. **E20** (chirality JIT loader) — needs E28 + E21; produces the interim self-hosted loader.
4. **E24** (arithmetic port) — independent; land with E15 (reference self-host).
5. **E25** (drop `bytearray`) — with E15 + E21.
6. **E27** (registries → alists) — with family-1 checker self-host; watch the E48 gate.
7. **E22** (region types) — needs E9/E41 (family-1 refinement). Tier-F allocator can
   land independently earlier.
8. **E26** (typed alarms) — needs the edge-16/E39 decision; the `exit`-via-syscall
   slice can land early (needs only E32).
9. **E23** / the whole family's *proper* form — subsumed by **E34 (ELF, family 5)**;
   until then everything is "self-hosted JIT."

## Cross-family flags

- **→ Family 4 (syscall, E28/E32):** this family cannot self-host its loader/arena
  without E28 (`mmap`/`mprotect`/`close`) and cannot retire `MetisExit` without E32
  (`exit(2)`). E28 should be sequenced *before* E20/E21.
- **→ Family 5 (E34 ELF):** E20, E21, E23 all collapse into "emit ELF + `_start`" once
  E34 exists. The proper end-state of the substrate floor *is* E34; recommend E34 be
  treated as the parent pass for E20/E23.
- **→ Family 1 (E9/E41 refinement + region types):** E22's payoff (retiring the
  `<=i … cap` runtime witness) and E20/E21's `mem-put-checked` discharge both depend on
  refinement-typed offsets. `mem-linear.chiral:26-28` already anticipates the interface.
- **→ Family 6 (E39 effect algebra / edge 16; E48 dependent records):** E26 *is* the
  substrate face of E39 — plan them together. E27's clean self-hosted `Sig` gates on
  E48 (heterogeneous record; `data.py:134` limit).

## New findings (candidate floor vocabulary the backend lacks)

- **Word-store-to-absolute-address** (E20/E21): the loader's `struct.pack` poke into
  the emitted `heapptr`/`heapend` cells has no chirality/tal equivalent — `ti-bput` writes
  one byte into a *byte cell*, not a word to an arbitrary address. Either add a floor op
  or move the store into a chirality `_start`. Not sketchable in current syntax.
- **Indirect call `call rax`** (E23): the emitter only emits direct rel32 calls
  (`enc-call`). A self-hosted JIT that jumps to its own freshly-mapped output needs an
  indirect call op the backend does not have. (Moot under ELF.)
- **`exit(2)` sys crossing** (E26/E32): the clean replacement for `MetisExit` — an
  all-integer `ti-sys` slice modeled on `nb-sys-lseek`. Small, independent, land early.
