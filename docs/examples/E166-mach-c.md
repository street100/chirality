---
element: E166
slug: mach-c
title: A conforming `Mach` that emits C, and the external-compiler DDC leg it unlocks
kind: BUILD-PROPER
reference_class: OURS
ours_source: scaffold/tests/ddc.py
status: drafted
updated: 2026-08-25
---

# E166 — A conforming `Mach` that emits C, and the external-compiler DDC leg it unlocks

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E166 — a THIRD conforming `Mach` value, `mach-c`, that renders the
  abstract codegen ops as C-as-portable-assembly, so an external C compiler (gcc
  now, CompCert when the toolchain lands) can build a chirality compiler that becomes
  the second leg of diverse double-compilation.
- **Kind:** BUILD-PROPER. Not built.
- **Why chirality needs its own:** `scaffold/tests/ddc.py` names the quorum as two
  *executors of the one chirality emitter* — `leg 0 self-hosted (chirality/chirality-native)`
  and `leg 1 py-scaffold (python/cpython3) tal.TalMachine`. **Leg 1 dies with the
  Python oracle**, and `ddc.chiral`'s `ddc-compare` returns `ddc-bad-quorum "one
  leg is not a quorum"` below two legs, while `leg2-disjoint?` demands that BOTH
  the `language` and the `toolchain` axes differ. So retiring Python does not
  weaken DDC — it *deletes* it, unless a replacement prior exists. `mach-c` plus
  an external C compiler is that prior.
- **Not a reversal of `docs/decision-backend.md`.** That note carries an author
  scope clarification dated 2026-08-23 (lines 11–17): the fork governs the
  **canonical shred instance**, whose backend stays `mach-x64` — no LLVM, no
  Cranelift, no C. `mach-c` is an *additive verification instance*, and the note
  itself cites `mach.chiral` + `mach-listing.chiral` as the mechanism that makes
  additive instances free.

## 2. Research

- **Reference class:** `OURS` — `scaffold/lib/ddc.chiral` (E53, built) and its
  untrusted mirror `scaffold/tests/ddc.py`; `scaffold/lib/mach.chiral` and
  `scaffold/lib/mach-listing.chiral` as the conforming-second-target precedent;
  `scaffold/lib/sys-tal.chiral` + `scaffold/lib/crossing-wraps.chiral` for the
  crossing path; CompCert as the external prior.

- **Key findings (measured against the live tree, 2026-08-23):**

  1. **The `Mach` record is 37 fields, not ~20.** `scaffold/lib/mach.chiral` is
     137 lines and the `(data Mach () (mach …))` constructor carries 37 function
     fields: `pro stp lda con dcon bin cal ret lsc cjne alo fld lsb fin bnw bgt
     bpt bln lea dat sys bpr bini tca ltb fcp fci fjc jtb clb binr binir fcpr
     fcir ldr galo gbnw` (the last two from E91). The catalog row's "~20" is
     stale — every accessor is spelled out in the file. **Sizing consequence:
     `mach-c` must inhabit 37 arms, not 20.** `mach-listing.chiral` inhabits all
     37 in 136 lines, so the target size is real but small.
     *(Corrected by the example audit, 2026-08-24: the pre-run wrote "38" while
     enumerating 37 names. Measured `grep -cE '^\(def mach-' mach.chiral` = 37,
     and the enumeration above is the accessor list verbatim — the catalog row
     already said 37.)*
     ⚑ **~~Only two of the 37 are effectful.~~ FOUR are.** `stp` and `lda` are
     declared `(=> I64 I64 (List Asm))` — *"may halt past the register args"* —
     and so are `fjc` and `clb`. So `mach-c`'s arms are pure except those four,
     and their `=>` is required, not incidental.
     *(Corrected after the fact, 2026-08-24. The pre-run wrote "only two" and
     the SPEC recorded the error without being able to fix it — a spec run's
     write surface is the SPEC alone. Measured against the live tree:
     `mach.chiral:66` `mach-stp`, `:68` `mach-lda`, `:118` `mach-fjc`, `:122`
     `mach-clb` are the four `(-> Mach (=> …))` accessors, matching the record
     fields at `:29 stp`, `:30 lda`, `:55 fjc`, `:57 clb`; every other field is
     `->`. The implementation and `scaffold/tests/samples/e166_mach_c.chiral:11`
     both carry the corrected four. Left visible rather than silently rewritten,
     because an implementer copying the original claim writes `fjc`/`clb` as
     `->` and hits a type error.)*

  2. **`mach-listing` is the existence proof, and it is the template.** Its
     header: *"It exists to prove emit-core is genuinely target-independent (the
     same codegen drives it with no change)… a conforming Mach value, nothing
     more."* It emits **text into `a-bytes`** and gives every relocation the
     `e-noenc` encoder, *"whose encoder ignores the displacement (this target
     does not run)."* `mach-c` copies that shape exactly — except it must run.

  3. **Every syscall in the whole system funnels through ONE `Mach` field.** The
     path is: a bound crossing → `crossing-wraps.chiral` routes it to an
     `nb-sys-*` wrapper → the wrapper is authored in tal in
     `scaffold/lib/sys-tal.chiral` (1,343 L, 55 `ti-sys` sites over 28 distinct
     syscall numbers) → tal lowering emits `ti-sys` → `emit-core` calls
     `(mach-sys m) dst nr argslots`. `mach-x64`'s answer is `x-sys` (line 783):
     place the args in the SysV syscall registers, `mov rax, nr`, `0f 05`
     (`x-syscall`, :779), store `rax`. **There is exactly one instruction-level
     place a syscall exists.** That single funnel is what makes the C runtime
     shim small (§4, choice 2).
     ⚑ **The audit found the direct evidence the pre-run argued for indirectly,
     and it is stronger: `mach-sys` has exactly ONE call site in the entire
     codegen** — `emit-core.chiral:167`, `((ti-sys dst nr args) (emit-i
     ((mach-sys m) dst nr args) "sys"))`. The funnel is not a count of wrappers
     that happens to converge; it is a single line. The wrapper counts below
     are supporting colour, and two of them were wrong (see choice 2). The
     28-distinct-syscall-numbers figure is confirmed: the second field of
     `ti-sys` over `sys-tal.chiral` yields 0 1 3 7 8 9 10 11 13 16 33 35 41 42
     46 53 57 59 61 72 77 112 228 231 257 293 319 322.

  4. **`emit-fn` emits `(a-label name)` and then `(mach-pro m) nregs`**
     (`emit-core.chiral:532-533`), and intra-function skip labels use the same
     `a-label` constructor (`:222`, `:368`, `:414`), as do literal cells
     (`:551`). So the `Asm` stream is **flat** — it has no function-boundary
     token. A byte target does not care; a C target does, because C needs
     `}\nstatic i64 f(…) {`. This is the one place `mach-c` cannot be a pure
     `Mach` value (§4, choice 1).

  5. **`Op` is a closed 15-constructor sum, and two of its arms do not map to a
     C operator.** `prelude.chiral:36-39`: `op-add op-sub op-mul op-div op-mod
     op-eqi op-lti op-lei op-mulhi op-sar op-shr op-band op-bor op-bxor op-shl`.
     `mach-x64.chiral:158-167` records the constraint: *"idiv alone truncates
     toward zero; chirality division is EUCLIDEAN (0 <= r < |b|), so a branchless
     correction below turns the truncated result into the Euclidean one, matching
     the reference/fold"*, plus a D3 guard for the zero divisor and `INT_MIN/-1`.
     C's `/` and `%` truncate. So `op-div`/`op-mod` are **not** `/` and `%`, and
     `op-mulhi` has no ISO-C spelling at all.

  6. **`ddc.py`'s two comparison notions are the vocabulary the verdict must be
     stated in**, and they are not interchangeable: *"fixpoint = bit-identity of
     emitted artifacts; admission = observable conformance (a leg matches the
     reference on an input vector before it may sit in the quorum). Conformance
     admits the leg; bit-identity convicts the binary."*

  7. **Toolchain reality here:** `gcc (Debian 12.2.0-14+deb12u1) 12.2.0` is
     installed, so the gcc leg is runnable today. **`ccomp` is absent**, so the
     CompCert leg remains a design target. *(Updated by the example audit,
     2026-08-24: `coqc` and `opam` are no longer absent — Coq 8.16.1 was
     installed via apt and a Rocq 9 opam switch was provisioned this session on
     the author's call. That changes E169's toolchain premise, not E166's:
     nothing in this element needs Rocq, and `ccomp` is still not here.)*

## 3. Conventional (other-language) approach

Compiling-through-C is one of the oldest portability moves in the business —
Cfront, early Chicken/Gambit Scheme, Nim, Vala, GHC's `-fvia-C`, Eiffel, Haxe.
Two flavours dominate, and the difference is the whole design question:

**(a) C-as-a-high-level-language** (Nim, Vala): emit structured C that a human
would recognise — real functions, real locals, `if`/`while`/`for`, real structs.
Readable, optimizes well, but requires a *second lowering* from the IR into C
control flow, because the compiler's own IR is already flat.

**(b) C-as-portable-assembly** (Chicken, GHC's old via-C route): emit one
register file as an array, `goto` for control flow, one giant function or many
uniform-arity ones.

```c
/* (b), the shape a flat-IR backend actually produces */
static long f_fib(long a0, long a1, long a2, long a3, long a4, long a5) {
  long r[7];
  r[0] = a0;
  r[1] = 1;
  if (((r[0] < r[1]) ? 1 : 0) != 0) goto L3;
  r[2] = r[0] - 1;  r[3] = f_fib(r[2],0,0,0,0,0);
  r[4] = r[0] - 2;  r[5] = f_fib(r[4],0,0,0,0,0);
  r[6] = r[3] + r[5];
  return r[6];
L3: ;
  return r[0];
}
```

And the runtime that always comes with it:

```c
/* the part nobody counts, and it is where the trust actually goes */
extern void *GC_malloc(size_t);         /* a garbage collector             */
static void *heap; static size_t hp;    /* or a bump arena over malloc     */
long rt_write(long fd, void *p, long n) { return write(fd, p, n); }  /* libc */
```

- **Assumptions it bakes in:**
  - **The C runtime is invisible.** Chicken's `runtime.c` is >5,000 lines; GHC's
    RTS is far larger. Compiling-to-C is sold as "the C compiler is now the
    backend", but the *actual* deliverable is codegen **plus** a runtime, and the
    runtime is unverified C that nobody audits. An element that quietly grows a
    large C runtime has **moved** the trusted drop, not shrunk it.
  - **libc is ambient authority in C's own idiom.** `write`, `malloc`, `open` are
    callable from anywhere in the emitted program. chirality's whole membrane says
    authority is the set of ports you hold; a libc-linked emitted program has
    dissolved that by construction.
  - **Integers and pointers are the same thing.** Bump allocators in C store raw
    addresses in `intptr_t`, cast them back, and dereference. gcc tolerates it.
    CompCert's block-based memory model does not: an integer cast back to a
    pointer has no provenance, and dereferencing it is outside the theorem.
  - **UB is a performance feature.** Signed overflow, strict aliasing, and
    shift-count UB are what let gcc optimize. chirality's I64 *wraps* two's-complement
    and its division is Euclidean — both of which C's own operators get wrong.
  - **Diversity is assumed rather than declared.** Nobody writes down what makes
    two build paths independent; DDC lives or dies on that being a checked value.

## 4. The chirality idea

chirality already did the hard part in 2023-vintage terms: `mach.chiral` froze the
backend as a **record of functions**, so "a new target" is a *value*, not a fork.
`mach-listing` proved a second one drives `emit-core` with no change. E166 is
therefore not "add a C backend to chirality" — it is "inhabit the existing interface
one more time, and pay honestly for the two things a *running* target needs that
a listing target does not: a crossing implementation and a heap."

- **Chirality features in play:** P4 (modularity is conformance, not configuration —
  `Mach` is the conformance contract); the effect membrane (`mach-sys` is the
  single instruction-level crossing, so the shim's surface is the membrane's own
  surface); boundary sums (the `Op` sum, the `EncTag` sum, and a new
  function-vs-local label sum); categories A/B/C (the C shim is category B —
  substrate the language cannot type — and it must be *small* for that to be
  honest); `Prov` as a declared, checked value rather than an assumption.

### Choice 1 — the seam: `Mach`, not `tal`

**Decision: `Mach`.** `mach-c` is a `Mach` value plus a C-mode *assembler* (the
replacement for `assemble`/`materialize`, not for `emit-core`).

- **For `Mach`:** `emit-core.chiral` (573 L) is untouched. `mach-listing` has
  already demonstrated this exact move, so the risk is measured, not estimated.
  Crucially, the point of a DDC leg is to diversify the **executor**, not the
  **program**: `ddc.py` says outright that the legs are *"the two EXECUTORS of the
  one chirality emitter"*. A second lowering would make the C leg compile a
  *different program*, which is precisely what would stop a divergence from
  localizing.
- **Against `tal`:** a structured-C lowering is a **second lowering to audit**.
  The whole thesis of E166 is that the trusted drop SHRINKS; adding a parallel
  lowering grows it. It buys diversity where there is none to buy — the checker
  and the tal floor are shared either way — at the cost of the one thing the
  element exists to avoid.
- **The cost, stated:** the emitted C is register-array-and-`goto` C. A human
  will not read it for pleasure, gcc's register allocator sees an array of
  `i64` (it does SROA it, but the codegen is worse than hand-written C), and
  debugging a divergence means reading generated C. Accepted: this leg exists to
  be *compared*, not to be *fast* or *pretty*.
- **The one honest exception, forced by finding 4:** the `Asm` stream has no
  function-boundary token. `mach-c` therefore ships a `c-assemble` that consumes
  `(List Asm)` alongside the emitted function-name list and classifies each
  `a-label` **once, at that boundary, into a closed sum** —
  `(data CLbl () (c-fn (n Str)) (c-local (n Str)) (c-lit (i I64)))` — instead of
  sniffing the string downstream. That is the `pattern-boundary-sums` move, and it
  keeps the C-specific knowledge in one pass rather than smeared across 38 arms.

### Choice 2 — the crossings: one shim function, because there is one funnel

This is the element's real design content, and finding 3 settles it. chirality's
crossings do not scatter, and the decisive fact is one line rather than a tally:
**`(mach-sys m)` is invoked from exactly one place in the whole codegen**,
`emit-core.chiral:167`. Around it, `crossing-wraps.chiral` maps **44** named
crossings onto **21** distinct `nb-sys-*` wrappers (plus a handful that route
elsewhere — `put`/`print`/`trace`/`halt` to `wrap-*`, `run-elf` to `nb-run-elf`,
`read-key` to `nb-read-key`), and the `nb-sys-*` wrappers are authored in tal in
`sys-tal.chiral`. Every one of them reaches the metal through the single `Mach`
field `sys`. **So the C shim needs exactly one crossing function**, and
`mach-c`'s `sys` arm renders a call to it.
*(Audit correction, 2026-08-24: the draft said "43 named crossings into
`nb-sys-*` wrappers, every wrapper is tal in `sys-tal.chiral`". Measured: 44
`(pair …)` rows, 21 distinct `nb-sys-*` names, and four crossings that are not
`nb-sys-*` at all. The conclusion is unaffected and now rests on the single call
site instead of on the tally — which is the citation that should have carried it
from the start.)*

The whole runtime, freestanding — no libc, no headers, no GC:

```c
/* chirality-rt.c — the ENTIRE C runtime for a mach-c-built chirality program. */
typedef long i64;

/* (1) the one heap object. Every chirality cell pointer is an INDEX into this. */
#define M_WORDS (1L << 27)     /* 1 GiB of ADDRESS SPACE. .bss is demand-paged,
                                   so untouched pages cost nothing resident --
                                   the same deal arena.chiral buys with
                                   MAP_NORESERVE. 64 MiB (arena.chiral's INITIAL
                                   size) is NOT enough: measured below. */
static union { i64 w[M_WORDS]; unsigned char b[8 * M_WORDS]; } m_heap;
static i64 m_hp = 1;                             /* word 0 reserved: index 0 == null */

/* (2) the one crossing. Every syscall in the system arrives here. */
static i64 m_sys(i64 nr, i64 a0, i64 a1, i64 a2, i64 a3, i64 a4, i64 a5) {
  register i64 r10 __asm__("r10") = a3;
  register i64 r8  __asm__("r8")  = a4;
  register i64 r9  __asm__("r9")  = a5;
  i64 ret;
  __asm__ volatile ("syscall" : "=a"(ret)
      : "a"(nr), "D"(a0), "S"(a1), "d"(a2), "r"(r10), "r"(r8), "r"(r9)
      : "rcx", "r11", "memory");
  return ret;
}

/* (3) the ONLY integer->pointer cast in the program. Handed to the kernel,
       never dereferenced by C. Mirrors x-bpr (cell pointer + 8). */
static i64 m_bptr(i64 cell) { return (i64)(void *)&m_heap.b[8 * (cell + 1)]; }

/* (4) the ops C spells differently than chirality does (finding 5), each computed
       in u64 so that WRAPPING is defined rather than UB. chirality I64 wraps
       two's-complement; C signed overflow does not, and gcc optimizes on the
       assumption it cannot occur. */
typedef unsigned long u64;
static i64 m_add(i64 a, i64 b) { return (i64)((u64)a + (u64)b); }
static i64 m_sub(i64 a, i64 b) { return (i64)((u64)a - (u64)b); }
static i64 m_mul(i64 a, i64 b) { return (i64)((u64)a * (u64)b); }

/* shifts: x86 `sar/shr/shl rax, cl` mask the count to 6 bits, so chirality's
   semantics ARE count-mod-64. C is UB at >= width, so mask explicitly. */
static i64 m_shl(i64 a, i64 n) { return (i64)((u64)a << (n & 63)); }
static i64 m_shr(i64 a, i64 n) { return (i64)((u64)a >> (n & 63)); }
static i64 m_sar(i64 a, i64 n) { u64 x = (u64)a; int k = (int)(n & 63);
  return (i64)(a < 0 ? ~(~x >> k) : x >> k); }        /* arithmetic, no impl-def */

/* division: Euclidean (0 <= r < |b|), AND the D3 guard mach-x64 documents at
   :175-185 — divisor 0 TRAPS deliberately, divisor -1 takes a branch that
   computes the answer without idiv (quotient = -dividend, wrapping to INT_MIN
   for INT_MIN; remainder 0). Both are exactly the inputs where C's / and % are
   UB, so reproducing the guard is what keeps the two legs the same language,
   not defensive coding. */
static void m_trap(void) { __asm__ volatile ("ud2"); }
static i64 m_div(i64 a, i64 b) {
  if (b == 0) { m_trap(); return 0; }
  if (b == -1) return (i64)(0u - (u64)a);              /* wraps for INT_MIN */
  i64 q = a / b; if (a % b < 0) q -= (b > 0) - (b < 0); return q; }
static i64 m_mod(i64 a, i64 b) {
  if (b == 0) { m_trap(); return 0; }
  if (b == -1) return 0;
  i64 r = a % b; if (r < 0) r += (b < 0) ? (i64)(0u - (u64)b) : b; return r; }
static i64 m_mulhi(i64 a, i64 b) { /* 32-bit halves; no __int128, CompCert lacks it */ … }

/* (5) entry */
extern i64 m_main(i64, i64, i64, i64, i64, i64);
void _start(void) { m_sys(60, m_main(0, 0, 0, 0, 0, 0), 0, 0, 0, 0, 0); }
```

**The honest size: ~70 lines of C**, of which the only part outside any
theorem is the 7-line `__asm__ volatile ("syscall")` block. That is the *same*
axiom `mach-x64` already embeds as the two bytes `0f 05`
(`(def x-syscall Bytes (bcat (b1 15) (b1 5)))`, `mach-x64.chiral:779`) —
relocated, not added.
*(Estimate annotated 2026-08-25 at `8a066d5`: the shim shipped at **197 raw
lines / 103 code**, not ~70. It is still well under the SPEC's ~150 L threshold
(`E166-mach-c-SPEC.md:287`, *"if it passes ~150 L, stop and say"*), so the
honesty check this estimate exists to serve PASSES — the figure moved, the
verdict did not. §6 carries the full prediction-vs-outcome note and the method.)*

**And the honest ledger, stated as plainly as the win:**

| what | before | after |
|---|---|---|
| trusted chirality codegen | `mach-x64.chiral` 1,737 L | `mach-c.chiral` ≈ 200–300 L + `c-assemble` ≈ 80 L |
| trusted C | none | ≈ 70 L, 8 of them unverifiable asm (`syscall` + `ud2`) |
| trusted external toolchain | none | **gcc 12.2 (enormous, unverified)** → CompCert (verified, INRIA) |

*(The three `≈` figures in that table are design-time estimates and are left
standing as such. Shipped, measured 2026-08-25 at `8a066d5`: `mach-c.chiral`
**403 raw / 190 code**, `c-assemble.chiral` **223 / 113**, `chirality-rt.c`
**197 / 103**. The row's shape survives — the chirality codegen is still an order of
magnitude under `mach-x64`'s 1,737 — and §6 carries the method.)*

With gcc the TCB *grows* by the whole of gcc; the leg is still worth having,
because gcc's provenance is genuinely disjoint from chirality's and that is what
DDC buys. Only with CompCert does the trusted drop actually shrink. Say it that
way or the element is oversold.

**What chirality makes impossible here:** the emitted C cannot acquire ambient
authority, because there is nothing to acquire — no libc is linked, and the only
route to the kernel is `m_sys`, which is only ever generated by the `sys` field,
which `sys-check.chiral`/the tal sys-face already gates. *"Lowered pure code has
no surface path to ti-sys/ti-bptr, so the membrane holds structurally"*
(`sys-tal.chiral` header). The C target inherits that structurally rather than
re-earning it.

### Choice 3 — the memory model: one object, indices not addresses

`arena.chiral` today is `mmap(0, 67108864, PROT_RW, PRIVATE|ANON|NORESERVE)` with
`arena-grow` doubling via `mremap`, and cell pointers are absolute addresses.
Transliterated naively, that C is: store an address in an `i64`, cast it back,
dereference. gcc accepts it. **CompCert's memory model does not** — its pointers
carry a block identity, an integer has none, and `*(i64 *)n` for an arbitrary `n`
is outside the theorem entirely. Aliasing is a second hazard: reading the same
storage as `i64` and as bytes is exactly what `bgt`/`bpt`/`bln` do.

**Decision: a single static heap object, addressed by index, with byte and word
views through a union.**

- Every chirality cell "pointer" becomes a **word index** into `m_heap.w`. All
  arithmetic on it is integer arithmetic inside one object's bounds — no
  provenance question can even be asked.
- `fld` / `alo` / `bln` are `m_heap.w[…]`; `bgt` / `bpt` are `m_heap.b[…]`. The
  union makes the two views one object, so strict aliasing is not violated (the
  `memcpy` spelling is the fallback knob if a target compiler is fussier).
- Index `0` is reserved so the null cell stays index 0, as today.
- **`m_bptr` is the single int→ptr cast**, and its result is handed to the
  kernel, never dereferenced by C. A pointer-to-integer cast is defined; it is
  integer-to-pointer *dereference* that is not, and this shape has none.
- **⚑ Cost, stated — and the first draft's number was REFUTED by measurement
  (example audit, 2026-08-24).** The draft reserved 64 MiB *"matching
  arena.chiral"* and justified it with *"the leg's job is to compile one known
  program once."* That justification is exactly what breaks it: the one known
  program is `B1 < blob.chiral`, and it was measured at **313.1 MiB peak RSS**
  (0.73 s, exit 0, output byte-identical to `B1` — so the fixpoint held on the
  measured run). 64 MiB is `arena.chiral`'s **initial** size, not its working
  size — `arena-grow` doubles, so a real self-compile climbs 64 → 128 → 256 →
  512 MiB of mapping. A 64 MiB static heap would abort on the element's central
  deliverable.
  The fix keeps the simplification and drops the number: reserve **1 GiB of
  address space** in `.bss`. A static array is demand-paged, so untouched pages
  are never resident — the same deal `arena.chiral` already buys with
  `MAP_NORESERVE`, reached by a different mechanism. `arena-grow`/`galo`/`gbnw`
  still lose growth (a static array cannot be `mremap`ed) and still render as
  `alo`/`bnw` plus a bounds check that traps; that capability loss is real and
  is the right trade. **What is no longer claimed is that the reserve is
  free-because-small.** It is cheap because it is virtual, and the spec must
  carry the measured number so the constant is never re-derived from
  `arena.chiral`'s initial size again.
- **The residue that does not go away:** the kernel writes into `m_heap` through
  an address C handed out. That write is invisible to CompCert's theorem. It is
  an axiom — the same one every verified-compiler-plus-syscalls story carries —
  and it must be *named*, not buried in the `volatile` on the asm block.

### Choice 4 — what this leg convicts, in `ddc.py`'s own vocabulary

**The prompt's framing needs one correction, and the code is the authority.**
"Byte-identity across two backends is impossible" is true but not the comparison
DDC runs. `ddc.py`: *"The two near-term legs are the two EXECUTORS of the one
chirality emitter."* Leg 0 is `NativeBackend`, leg 1 is `tal.TalMachine`; **both emit
chirality's own x86-64 bytes**, which is why `bytes=?` over `(artifact Bytes)` is
meaningful at all. `mach-c` continues that construction exactly: it builds a
*different executable of the same compiler*, and that executable still emits
through `mach-x64`. So:

- **`admission` — what the C leg must earn.** `chirality-bin-c` (the compiler built by
  gcc/CompCert from `mach-c`'s output) is **not** bit-comparable to `chirality-bin`: one
  is `mach-c`+gcc output, the other is `mach-x64` output. Its right to sit in the
  quorum comes from *observable conformance on an input vector* — it must produce
  the reference answers. That is precisely `admission`, and it is the only thing
  the C artifact itself can ever be judged by.
- **`fixpoint` / conviction — what the C leg then delivers, and it is not
  nothing.** Once admitted, `chirality-bin-c < blob > out_c` and `chirality-bin < blob > out_0`
  produce two x86-64 artifacts of *the same emitter*, and those **are**
  byte-comparable. `ddc-converged (artifact Bytes)` is reachable; this is the
  Thompson construction, and it convicts a compromised `chirality-bin` exactly as leg 1
  does today. **So the element is stronger than "admission-only": the leg is
  admitted by conformance and then convicts by bit-identity — which is the whole
  sentence, not half of it.**
- **The quorum gate passes.** `leg2-disjoint?` requires both axes to differ:
  `("c", "gcc-12")` vs `("chirality", "chirality-native")` differs on both.
  Post-Python-retirement the quorum is exactly two legs, which `ddc-compare`
  accepts.
- **The residue nobody should launder:** `Prov` has four axes and only two are
  checked. `author` stays `"shred"` for both legs, because *we* write `mach-c`.
  The catalog row's *"the first leg whose Prov is genuinely disjoint from chirality's
  own"* is true on the **checked** axes (language, toolchain) and false on
  `author` — and `ddc.chiral`'s own comment already concedes it: *"author is
  assertable only — recorded, not laundered."* The disjointness this leg buys is
  **toolchain** disjointness (GNU/INRIA vs us), which is the axis a Thompson
  attack lives on. That is enough. It is not "fully independent".
- **And the invariant the spec must carry:** `mach-c` must not accept programs
  `mach-x64` refuses, or the legs are not executing the same language.
  Concretely, `mach-x64`'s `lda` halts with *"call/def with >6 args; SysV passes
  the 7th+ on the stack, unimplemented"* (`mach-x64.chiral:1663`); C has no such
  limit. `mach-c` must reproduce the refusal rather than quietly succeed.

## 5. Chirality example (fleshed)

Copy `mach-listing.chiral`'s shape; render C text into `a-bytes`; give every
relocation `e-noenc`, because in C a reference is a *name*, and displacements are
the C compiler's problem, not ours.

```chirality
; lib/mach-c.chiral — a THIRD conforming Mach: C-as-portable-assembly.
;
; Same move as mach-listing (text into a-bytes, e-noenc relocations), with one
; difference that changes everything: THIS TARGET RUNS. So the ops must be
; semantics-preserving C, not a pretty rendering — Euclidean div, wrapping I64,
; and a heap that is one C object addressed by index (never a reconstituted
; pointer), so the emitted C stays defined under CompCert's memory model and not
; merely tolerated by gcc.
;
; ⚑ NAMING: every helper here is `mc-`-prefixed. `mach-listing.chiral` already
; defines TOP-LEVEL `line`, `lcat` and `r` (measured: its defs are `line r noenc
; slots lbl-list lcat l-args listing`), and emitted labels share ONE FLAT
; NAMESPACE until E154 lands — two co-blobbed modules cannot define the same
; internal name. This is the same workaround E151a took with its `su-` prefix,
; and BUILD-ORDER §1 A2 catalogues it as a codegen defect forcing app-level
; duplication, not as good style. The right home for `mc-line`/`mc-lcat`/`mc-r`
; is a shared text-emit shelf once E154 removes the hazard (§6, open questions).
;
; Registers are `r[i]`, an i64 array local to each function; incoming params are
; a0..a5 (SysV shape, so the resident-argreg ops binr/binir/fcpr/fcir/ldr have a
; direct spelling); the flags register is modelled by two locals _ca/_cb that
; fcp/fci fill and fjc consumes.

(import "prelude")
(import "ports")
(import "asm-reloc")
(import "mach")

; ---------------------------------------------------------------- text helpers
(def mc-line (-> Str (List Asm))
  (lam (s) (one-b (str->bytes (str-cat s "\n")))))

(def mc-r (-> I64 Str) (lam (n) (str-cat "r[" (str-cat (i64->str n) "]"))))
(def mc-a (-> I64 Str) (lam (n) (str-cat "a" (i64->str n))))

(def mc-lcat (-> (List Asm) (List Asm) (List Asm))
  (lam (xs ys) (case xs (nil ys) ((cons h t) (cons h (mc-lcat t ys))))))

; ---------------------------------------------------------------- the Op table
; op-name is the chirality spelling; this is the C one. ⚑ FAR FEWER ops are infix
; than the first draft assumed, and the audit corrected it: chirality I64 is
; two's-complement WRAPPING, and C's signed +, -, *, << are UNDEFINED on
; overflow — gcc is licensed to assume overflow cannot happen and optimize on
; that assumption. A leg whose arithmetic gcc may reinterpret is not executing
; the same language as mach-x64, which is the one invariant this element cannot
; trade away. So every op whose chirality meaning is defined where C's is not goes
; through the shim, computing in u64 and casting back:
;   - add/sub/mul  : wrap (C signed overflow = UB)
;   - shl          : wrap, and mask the count (C shift >= width = UB)
;   - sar/shr      : mask the count; x86 `sar rax, cl` masks to 6 bits, so
;                    chirality's shift semantics ARE count-mod-64 (mach-x64.chiral:
;                    321/323/331) and C must reproduce that mask explicitly
;   - div/mod      : Euclidean, not truncating, PLUS the D3 guard
;                    (mach-x64.chiral:175-185)
;   - mulhi        : no ISO-C spelling at all
; Only the six genuinely-total ops stay infix: band bor bxor eqi lti lei.
(data COp () (c-infix (s Str)) (c-call (fn Str)))

(def c-op (-> Op COp)
  (lam (op)
    (case op
      ((op-band) (c-infix "&"))   ((op-bor) (c-infix "|"))
      ((op-bxor) (c-infix "^"))   ((op-eqi) (c-infix "=="))
      ((op-lti) (c-infix "<"))    ((op-lei) (c-infix "<="))
      ((op-add) (c-call "m_add")) ((op-sub) (c-call "m_sub"))
      ((op-mul) (c-call "m_mul")) ((op-shl) (c-call "m_shl"))
      ((op-sar) (c-call "m_sar")) ((op-shr) (c-call "m_shr"))
      ((op-div) (c-call "m_div")) ((op-mod) (c-call "m_mod"))
      ((op-mulhi) (c-call "m_mulhi")))))

; c-expr renders the BARE EXPRESSION `<x> OP <y>` — no dst, no semicolon —
; because fjc needs it inside an `if (...)`, where an assignment statement is a
; syntax error. c-bin-text is one statement wrapped around it. ⚑ The audit
; caught the first draft calling c-bin-text with an empty dst from fjc, which
; renders `if ((( = _ca < _cb;) ? 1 : 0) != 0)` — not C. Splitting the two is
; the fix, and it is also why binr/binir can share the statement form exactly.
(def c-expr (-> Op Str Str Str)
  (lam (op x y)
    (case (c-op op)
      ((c-infix s) (str-cat x (str-cat " " (str-cat s (str-cat " " y)))))
      ((c-call f)  (str-cat f (str-cat "(" (str-cat x (str-cat ", " (str-cat y ")")))))))))

(def c-bin-text (-> Str Op Str Str Str)
  (lam (dst op x y)
    (str-cat dst (str-cat " = " (str-cat (c-expr op x y) ";")))))

; ---------------------------------------------------------------- args
; C has no 6-register limit, but mach-x64 REFUSES past 6 (mach-x64.chiral:1663).
; mach-c reproduces the refusal: the two legs must accept the same language, or
; a DDC comparison is comparing two different programs.
(def c-lda (=> I64 I64 (List Asm))
  (lam (ap slot)
    (case (<=i ap 5)
      (true (mc-line (str-cat "_a[" (str-cat (i64->str ap)
                    (str-cat "] = " (str-cat (mc-r slot) ";"))))))
      (false (halt (List Asm) "emit(c): call/def with >6 args; mach-x64 refuses these, so mach-c does too")))))

; ---------------------------------------------------------------- the Mach
(def mc Mach
  (mach

    ; pro — the function BODY opener. The signature and the closing brace of the
    ; previous function belong to c-assemble, because emit-fn emits (a-label
    ; name) BEFORE calling pro and the Asm stream carries no boundary token
    ; (emit-core.chiral:532-533).
    (lam (nregs)                                                        ; pro
      (mc-lcat (mc-line "{")
        (mc-lcat (mc-line (str-cat "  i64 r[" (str-cat (i64->str (+ nregs 1)) "];")))
          (mc-lcat (mc-line "  i64 _a[6]; i64 _s[6]; i64 _ca; i64 _cb;")
                (mc-line "  (void)_a; (void)_s; (void)_ca; (void)_cb; i64 _sc;")))))

    (lam (ap slot)                                                      ; stp
      (mc-line (str-cat "  " (str-cat (mc-r slot) (str-cat " = " (str-cat (mc-a ap) ";"))))))

    c-lda                                                               ; lda

    (lam (slot val)                                                     ; con
      (mc-line (str-cat "  " (str-cat (mc-r slot)
              (str-cat " = " (str-cat (i64->str val) ";"))))))

    (lam (slot tag)                                                     ; dcon
      (mc-line (str-cat "  " (str-cat (mc-r slot)
              (str-cat " = " (str-cat (i64->str tag) ";"))))))

    (lam (op dst x y)                                                   ; bin
      (mc-line (str-cat "  " (c-bin-text (mc-r dst) op (mc-r x) (mc-r y)))))

    ; cal — args were placed into _a[] by lda, so the call site is uniform-arity
    ; (SysV shape, six i64 in, one i64 out). The a-rel keeps the callee NAME in
    ; the stream for c-assemble's forward-declaration pass; the displacement is
    ; meaningless in C, hence e-noenc, exactly as mach-listing does.
    (lam (dst fname args)                                               ; cal
      (mc-lcat (c-args args 0)
        (cons (a-rel 0 e-noenc fname)
          (mc-line (str-cat "  " (str-cat (mc-r dst)
                  (str-cat " = " (str-cat fname
                    "(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5]);"))))))))

    (lam (slot) (mc-line (str-cat "  return " (str-cat (mc-r slot) ";"))))    ; ret

    ; lsc / lsb — the compare register is the local _sc. lsb reads the boxed
    ; scrutinee's TAG: word 0 of the cell, which in C is one indexed load out of
    ; the single heap object — no pointer is reconstituted.
    (lam (slot) (mc-line (str-cat "  _sc = " (str-cat (mc-r slot) ";"))))     ; lsc
    (lam (tag skip)                                                     ; cjne
      (mc-lcat (mc-line (str-cat "  if (_sc != " (str-cat (i64->str tag) ")")))
        (cons (a-rel 0 e-noenc skip)
          (mc-line (str-cat " goto " (str-cat skip ";"))))))
    ; …  alo fld  — `r[dst] = m_alloc(tag, n); m_heap.w[r[dst]+1+k] = r[fk];`
    (lam (slot) (mc-line (str-cat "  _sc = m_heap.w[" (str-cat (mc-r slot) "];"))))  ; lsb

    (the (List Asm) nil)                                                ; fin
                                        ; (the heap lives in the shim, not here)

    ; …  bnw bgt bpt bln  — byte face, all through m_heap.b[…]
    ; …  lea dat          — literals: an index into a static initializer table
    ; …  bpr              — the ONE int->ptr cast: `r[dst] = m_bptr(r[src]);`

    ; sys — the single crossing. Every syscall chirality performs (55 ti-sys sites
    ; across 28 numbers in sys-tal.chiral) arrives HERE and nowhere else, which is
    ; why the C runtime shim is ~70 lines rather than a runtime.
    (lam (dst nr args)                                                  ; sys
      (mc-lcat (c-sysargs args 0)
        (mc-line (str-cat "  " (str-cat (mc-r dst)
                (str-cat " = m_sys(" (str-cat (i64->str nr)
                  ", _s[0], _s[1], _s[2], _s[3], _s[4], _s[5]);")))))))

    ; …  bini tca ltb                     — mechanical
    ; fcp/fci/fjc — x86 flags have no C spelling, so the compare is SPLIT
    ; honestly: fcp/fci stash the operands, fjc applies the op and branches.
    (lam (x y) (mc-line (str-cat "  _ca = " (str-cat (mc-r x)                 ; fcp
                      (str-cat "; _cb = " (str-cat (mc-r y) ";"))))))
    (lam (x v) (mc-line (str-cat "  _ca = " (str-cat (mc-r x)                 ; fci
                      (str-cat "; _cb = " (str-cat (i64->str v) ";"))))))
    (lam (op tag skip)                                                  ; fjc
      (mc-lcat
        (mc-line (str-cat "  if (((" (str-cat (c-expr op "_ca" "_cb")
                   (str-cat ") ? 1 : 0) != " (str-cat (i64->str tag) ")")))))
        (cons (a-rel 0 e-noenc skip)
          (mc-line (str-cat " goto " (str-cat skip ";"))))))

    ; jtb — a `switch`, NOT a computed goto: `goto *tbl[i]` is a GNU extension
    ; and CompCert refuses it. Tags are dense by construction, so switch is
    ; exact and the C compiler builds its own jump table.
    ; …  (lam (scrut labels) …)                                          ; jtb

    (lam (k) (the (List I64) nil))                                      ; clb
                          ; C owns register allocation; nothing is clobbered here

    ; binr/binir/fcpr/fcir/ldr — the "operand resident in an argument register"
    ; ops. In C an argreg IS a parameter, so these are one line each and ldr is
    ; genuinely nothing when i == j (the pass-through param).
    (lam (op dst i y) (mc-line (str-cat "  " (c-bin-text (mc-r dst) op (mc-a i) (mc-r y))))) ; binr
    ; …  binir fcpr fcir
    (lam (j i) (case (=i i j)                                           ; ldr
                 (true (the (List Asm) nil))
                 (false (mc-line (str-cat "  _a[" (str-cat (i64->str j)
                          (str-cat "] = " (str-cat (mc-a i) ";"))))))))

    ; galo/gbnw (E91) — growth is impossible on a fixed static heap, so these
    ; render as alo/bnw plus the bounds check that exits. The honest cost of
    ; choosing ONE C object over mmap+mremap.
    ; …  (galo) (gbnw)
    ))
```

And the C-mode assembler, which is where the flat-`Asm`-stream problem is paid
for — once, as a boundary sum:

```chirality
; The label classification, parsed ONCE against the emitted function set, so no
; arm downstream string-sniffs a name (docs/pattern-boundary-sums.md).
(data CLbl () (c-fn (n Str)) (c-local (n Str)) (c-lit (i I64)))

(declare c-classify (-> (List Str) Str CLbl))     ; fn-names -> label -> CLbl

; the two arg-placing folds the Mach arms above call. `c-args` fills _a[] for a
; call; `c-sysargs` fills _s[] for a crossing. Both are `=>` for the same reason
; `lda` is: past six they must reproduce mach-x64's refusal.
(declare c-args    (=> (List I64) I64 (List Asm)))
(declare c-sysargs (=> (List I64) I64 (List Asm)))

; c-assemble replaces assemble/materialize for this target: a-bytes pass
; through, an a-rel contributes only its NAME (to the forward-declaration
; prologue), and an a-label becomes either `}` + a new function signature, a C
; label, or a data symbol.
(declare c-assemble (-> (List Str) (List Asm) Bytes))
```

- **Knobs to modify:**
  - `M_WORDS` — the fixed heap reserve, **1 GiB of address space against a
    measured 313 MiB peak**. The whole growth question is this one constant plus
    the `galo`/`gbnw` arms. Re-measure before shrinking it; do not re-derive it
    from `arena.chiral`'s 64 MiB *initial* mapping, which is the mistake the
    audit caught.
  - The union-vs-`memcpy` spelling of the byte/word views, if a target C compiler
    is stricter about aliasing than gcc and CompCert are.
  - `m_shr`'s and `>>`'s signedness: C's `>>` on a signed value is
    implementation-defined before C23 (gcc and CompCert both define it as
    arithmetic, which is what `op-sar` wants) — swap to an explicit unsigned cast
    if a third compiler ever joins.
  - The uniform 6-argument calling shape; a `c-call` prologue-per-arity variant
    would produce nicer C at the cost of `cal` needing the callee's arity.
  - `Prov ("c" "gcc-12" …)` → `("c" "compcert-3.x" …)` is a one-line leg swap in
    `ddc.chiral`; nothing else in the element changes.

- **Deliberately omitted:**
  - The leg-*running* orchestration. `ddc.chiral`'s own header: *"The leg-running
    orchestration (spawn/exec each leg on one source) is effectful lane-A
    machinery and lives outside this file."* Same here.
  - Optimization. `x64-peep` has no C analogue and needs none — the C compiler is
    the optimizer, and this leg is not judged on speed.
  - ELF emission (`compile-emit.chiral`'s 224-byte entry stub, `heapptr`/
    `heapbase`/`heapend`/`heapreserve` cells). The C compiler and its linker
    produce the executable; `_start` is 1 line in the shim.
  - Anything about the canonical instance. `mach-x64` remains the backend;
    nothing here proposes compiling the shipped chirality through C.

## 6. Use / modify notes

- **Lands in:**
  - `scaffold/lib/mach-c.chiral` — the `Mach` value (all ~~38~~ **37** fields;
    ≈ 200–300 L, against `mach-listing`'s 136 for the same 37 arms).
  - `scaffold/lib/c-assemble.chiral` — the C-mode replacement for
    `assemble`/`materialize` plus the `CLbl` sum (≈ 80 L).
  - `scaffold/rt/chirality-rt.c` — the runtime shim (≈ 70 L; the *entire* C
    deliverable, and its size is the element's honesty check. It was ≈ 45 L
    before the audit added the wrapping-arithmetic and D3-guard helpers — the
    growth is the honest price of the two legs meaning the same thing).
  - `scaffold/lib/ddc.chiral` — one new leg constant beside `ddc-leg0`/`ddc-leg1`:
    `(def ddc-legc Leg (leg "c-external" (prov "c" "gcc-12" "shred" 2026)))`,
    and `ddc-verdict-code`'s pair updated when leg 1 retires.

  ⚑ **Estimates annotated, not overwritten (2026-08-25, at `8a066d5`).** All
  three sizes above are design-time projections and stay as written — the
  prediction-vs-outcome delta is calibration data about our own estimating, and
  an example is the frozen rationale, not a status page. What shipped, measured
  in this run against the live tree:

  | file | projected | raw (`wc -l`) | code |
  |---|---|---|---|
  | `scaffold/lib/mach-c.chiral` | ≈ 200–300 L | **403** | **190** |
  | `scaffold/lib/c-assemble.chiral` | ≈ 80 L | **223** | **113** |
  | `scaffold/rt/chirality-rt.c` | ≈ 70 L | **197** | **103** |

  Method: code lines are `grep -cvE '^[[:space:]]*(;|$)'` for the two `.chiral`
  files and `grep -cvE '^[[:space:]]*(//|/\*|\*|$)'` for the C shim. Every
  estimate overshot in the same direction, and for one shared reason worth
  keeping: the sizing was done against `mach-listing`'s 136 lines, a target that
  never has to *run*, so it budgeted nothing for the post-mortem comments the
  running target earned (over a third of `mach-c.chiral` is the F1 comment). The
  maintained figures live in `docs/banks/verification.md` §2 (`mach-c`, 190 of
  403 — the catalog's 189 is the same file under a slightly different code-line
  convention) and in the E166 rows of `.planning/SELF-IMPLEMENT-CATALOG.md` and
  `.planning/LEDGER.md` (the shim's 103, with its method). The verdict the shim
  estimate existed to gate is unchanged: 103 is under the SPEC's ~150 L
  threshold. **"all 38 fields" was the pre-run's miscount** — 37, as §2 finding
  1 above already records and corrects.

- **Conformance target:**
  1. `emit-core.chiral` is **byte-identical before and after** — the same proof
     `mach-listing` carries. If `emit-core` had to change, choice 1 was wrong.
  2. `chirality-bin-c` (gcc-built, from `mach-c`'s output) reproduces the reference
     answers on the test vector — that is `admission`, and it is what admits the
     leg to the quorum.
  3. `chirality-bin-c < blob > out_c` byte-equals `chirality-bin < blob > out_0` — that is
     `fixpoint`, and it is what the leg then convicts with.
  4. `prov-disjoint?` returns `true` for `(ddc-leg0, ddc-legc)`.

- **Open questions a real implementation must decide:**
  - Does `c-assemble` sit beside `assemble` in `asm-reloc.chiral`, or in its own
    file? (`assemble` is target-independent today; a C mode is the first thing
    that would make it not.)
  - String-building cost. `mach-listing` is exercised on toy programs;
    `mach-c` must render a whole compiler's worth of C through `str-cat`. Whether
    that needs a `Bytes` builder is a measurement, not a guess — take it in the
    spec.
  - Where the fixed-heap bounds check `exit`s from, given `galo`/`gbnw` return
    `(List Asm)` and cannot themselves cross.
  - Whether `chirality-bin-c`'s admission vector is the existing suite or a smaller
    named vector; `ddc.py` says "an input vector" without fixing one.
  - The retirement sequencing against S12/rung-1: this leg must be **admitted**
    before leg 1 is deleted, or there is a window with no quorum at all.
  - ⚑ **Name mangling — raised by the example audit; the pre-run never named
    it.** chirality labels contain characters C identifiers cannot: `compile-main`,
    `str-cat`, and `closconv.chiral:1097`'s generated `$clo0` / `$apply0` are all
    illegal as C identifiers (`-` and `$`; `$` is a common extension but not
    ISO C, and CompCert is the strict reader here). So `c-assemble` needs a
    total, **injective** chirality-name → C-identifier map, and injectivity is the
    load-bearing half: two chirality names colliding into one C identifier is a
    silently miscompiled leg, which is worse than no leg. The shim's
    `extern i64 m_main(...)` already assumes some such convention without
    stating it. This is `CLbl`'s neighbour and probably belongs in the same
    boundary pass.
  - ⚑ **AUTHOR CALL — the divergence runs the other way for memory, and the
    example's own invariant only covers one direction.** §4 choice 4 requires
    that *"`mach-c` must not accept programs `mach-x64` refuses"*, and the
    `>6 args` arm reproduces `mach-x64`'s refusal for exactly that reason. The
    fixed heap is the **inverse** case: `mach-x64` grows the arena without
    bound, `mach-c` traps at `M_WORDS`. So there exist programs `mach-x64`
    accepts and `mach-c` refuses. That is a *coverage* limit, not a soundness
    hole — DDC compares only where both legs run, and a trap is visible rather
    than silent — and 1 GiB against a measured 313 MiB peak leaves 3× headroom
    for the leg's one stated job. But whether a leg that cannot grow is still
    "the same language" for quorum purposes is a scope judgement, not a
    measurement, and the spec should carry an explicit answer rather than
    inherit this note.
  - **Where `mc-line` / `mc-lcat` / `mc-r` should actually live.** They are
    `mc-`-prefixed here only because emitted labels share one flat namespace
    until **E154** lands and `mach-listing.chiral` already owns `line`, `lcat`
    and `r` at top level. That is BUILD-ORDER §1 A1 (a helper below its
    generality) forced by §1 A2 (the emit-tier collision) — the same pair
    E151a's `su-` prefix worked around. Post-E154 the answer is a shared
    text-emit shelf that both conforming targets import; the spec should say so
    rather than let a second private copy calcify.

- **Related:** [[E53]] (`lib/ddc.chiral`, the pure compare core this extends) ·
  [[E70]] (the closed `Op` sum and the erase-boundary parse `c-op` mirrors) ·
  [[E91]] (`galo`/`gbnw`, the two arms this target cannot honour) ·
  `docs/decision-backend.md` (the scope clarification that makes this additive) ·
  `docs/axis-altitude.md:43` ("the single trusted drop to the metal" — the thing
  that moves and shrinks here, and does not vanish).
