---
row: memory-discipline/M8
arc: memory-discipline
title: the linear indexed buffer
kind: primitive
origin: new
req: 5, 1
status: blocked
updated: 2026-09-30
---

# memory-discipline/M8: the linear indexed buffer

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** one linear buffer mechanism in which an indexed write mutates in
  place, an indexed read lowers to one load, the index is proven in `[0, n)` the
  way `mem-put-checked` proves an offset, and the element is a byte, an `I64`
  word or a boxed value, each serving its named consumer with no second
  mechanism beside it.
- **Serves:** requirement 5 of [[arcs/memory-discipline-arc]], *"A buffer is
  written in place ... Observed as a write whose cost does not grow with the
  buffer's length."* It bears on requirement 1 through `M4`: the emit buffer's
  quadratic copy is allocation the live set never needed.
- **Goal:** [[goals/local-ai]], condition 1.
- **Consumers, each served by this one mechanism:** `memory-discipline/M4`
  (`E84`), the emit byte builder; [[arcs/text-tools-arc]] P2 and P3, `I64` DP
  rows and Myers's V vectors (`docs/arcs/text-tools-arc.md:142-176`, FD-56 item
  (k)); P5, a transition table read in one load (FD-56 item (i)); and
  `lowering-and-emit/LE25`'s id-keyed dense tables of boxed `TalSig`s
  (`docs/arcs/parts/lowering-and-emit-LE25.md:198-205`).

## 2. What the tree holds

Measured 2026-09-30 at HEAD `990923d` plus the working tree.

- **Bank:** [[banks/memory]]. Its shard for this row is the linear
  `(Pool n)` with its capacity in the type and `mem-put-checked` as the checked
  write. [[banks/erasure]] shard F supplies the fact that settles element width
  below: every non-arrow value is one word at the lowering type level.

| what exists | where | rung | reached by |
|---|---|---|---|
| a type-indexed linear porttype | `(porttype Pool (n I64))`, `lib/ports/pool.port:13`; the indexed form loads as an empty data with the index params, marked linear, `lib/surface/parse.chiral:697-705` | ENFORCED (linearity) | `lib/protocol/grid.chiral:22-27`, E111's cell store |
| an in-place linear write, bytes only | `pool-write`, `lib/ports/pool.port:27`, crossing to `nb-pool-write` (`lib/lowering/tal/crossing-wraps.chiral:51`), a runtime bounds check then `nb-copy` into `base+off` (`lib/lowering/tal/sys.chiral:1067-1070`). Each write takes a `Bytes` cell as its source | IMPLEMENTED | `lib/protocol/grid.chiral:176` |
| a linear read that allocates | `pool-read`, `lib/ports/pool.port:30`, returns `PoolReadR` (`:19`); `nb-pool-read` builds a fresh byte cell and a two-field result cell per read, `ti-bnew` and `ti-cona` at `lib/lowering/tal/sys.chiral:1104` | IMPLEMENTED | `lib/protocol/grid.chiral:194` |
| the pool's allocation | memfd, ftruncate, mmap per `pool-create`, `lib/lowering/tal/sys.chiral:1011-1013`. A syscall triple and page granularity per buffer | IMPLEMENTED | E111 |
| the checked write | `mem-put-checked`, `lib/memory/mem-linear.chiral:26-28`, index `(refine I64 (>= 0) (< n))` against the erased capacity; the raw `mem-put` beside it (`:15-16`) keeps the runtime check for offsets the fragment cannot prove (`:24-25`) | SEEDED, zero importers | nothing |
| the refinement procedure | `lib/typing/refine.chiral`, conjunction of atoms over a constant or a bare in-scope variable, path-sensitive through `narrow-branch` (`lib/typing/kernel.chiral:483`, `:1279`) and `ctx-narrow` (`:1455`); `docs/definitions/status-ledger.md:189` places it SEEDED, no phase exercising it | SEEDED | the kernel |
| linearity by type | `is-linear`, `lib/typing/kernel.chiral:325-330`, reads the `latoms`/`ldatas` registries; `docs/definitions/status-ledger.md:162` | ENFORCED | every binder rule |
| the linear-result rule | E159, `lib/module/loader.chiral:445-476`: an extern whose result is a linear porttype must carry a `=>` arrow on its spine (`docs/elements/ledger.md:306`) | ENFORCED | every extern load |
| a byte write into a value cell | `bput-u8`, `lib/lowering/tal/bytes.chiral:603-619`, rebuilds prefix, byte and suffix through two `bcat`s (`:619`) | IMPLEMENTED | every caller of `bput-u8` |
| word access over bytes | `nb-get-u64` (`lib/lowering/tal/bytes.chiral:484`) and `nb-put-u64` (`:558`) compose a word from single-byte `ti-bget`/`ti-bput`; a word read is several loads | IMPLEMENTED | `lib/lowering/tal/sys.chiral` |
| the TAL byte face | `i-bnew`/`i-bget`/`i-bput`, `lib/lowering/tal/ssa.chiral:31-33`; `ti-bnew`/`ti-bget`/`ti-bput`, `lib/lowering/tal/ir.chiral:26-28`; surface `bget` erases inline to one `n-bget`, `lib/lowering/tal/erase.chiral:163-166` | ENFORCED | every compiled program |
| the Mach byte face | `bnw`, `bgt`, `bpt` fields, `lib/lowering/mach/mach.chiral:42-44`; x64 `x-bgt` is one `movzx`, `lib/lowering/x64/mach.chiral:703-707`; `lib/lowering/listing/mach.chiral` is the second instance. **No field loads or stores a word at a dynamic index**: `fld` (`mach.chiral:39`) takes a static field index | ENFORCED | `lib/lowering/mach/emit-core.chiral:164-165` |
| the uniform erased word | `tt-word`, `lib/lowering/tal/ssa.chiral:17-21`, one word for an `I64`, a `Str`, a `Bytes` or a boxed pointer; [[decisions/decision-erased-word-level]] | built | the lowering |
| the allocation seam | `Alloc` with `bytes` and `adrop`, `lib/memory/alloc.chiral:18-24` | built (`E81`) | the emitter |
| `Str` carries no index | `(t-primty (n Str))`, `lib/surface/syntax.chiral:29`; `enforcement/N18` (`docs/arcs/enforcement-arc.md:549`) is the row that gives the byte floor a bound | open | |

**Probes, 2026-09-30, `bin/chirality check` over scratch sources.**

1. `(porttype Buf (A (type 0)) (n I64))` loads: an indexed porttype takes a
   type parameter beside a value index. So does `(data Got ((A (type 0)) (n
   I64)) (got (x A) (1 b (Buf A n))))`.
2. `buf-put I64 4 b 3 7` against `(refine I64 (>= 0) (< n))` checks OK; index
   `4` is refused, `cannot prove refinement`.
3. A loop guarded by `(<i i 0)` then `(<i i n)` with `n` bound at `w` checks OK;
   the same loop with the lower guard dropped is refused, `cannot prove
   refinement`. The fragment proves a guarded computed index today.
4. Using the buffer twice is refused, `linear binder usage mismatch`.
5. An extern `buf-new` returning `(Buf A n)` through `->` alone is refused by
   E159: *"a minted capability must cross (`=>`), else it is never tracked at
   q1"*.
6. An extern returning `Got` through `->` loads, and the kernel still tracks its
   result at q1: `let`-binding and dropping it is refused `linear binder usage
   mismatch`, dropping its buffer field is refused `field binder usage
   mismatch`. So a linear result of a `->` application **is** tracked, and
   E159's stated premise holds only as a rule about capability mints.
7. A `->` def taking and returning `(1 b (Buf I64 4))` that calls a `=>`
   `buf-put` checks OK today, because the membrane is carried and refused
   nowhere (`docs/elements/ledger.md:121`, E171 at `design`).

**What this settles about the questions put to this row.** The linear binder is
checked by type and already reaches a runtime buffer, the `Pool`. That buffer
fails the row three ways: its write consumes a `Bytes` cell, its read allocates
two cells, and it holds bytes only. The TAL and Mach floors hold a byte face and
no word face.

## 3. The delta

1. **A carrier allocated from the value heap.** The `Pool` allocates by syscall
   and holds bytes. A buffer of words or boxed values, allocated through
   `Alloc`'s `bytes` and released through `adrop`, does not exist.
2. **A word face at a dynamic index.** Two TAL instructions and two `Mach`
   fields, a word load and a word store at `8 + 8i` past the cell header, with
   their checker, interpreter, erase and emit arms. A word read is several loads
   today.
3. **A write that takes the element.** `pool-write` copies a `Bytes` source per
   write. The buffer's write takes the element value and stores it.
4. **A read that allocates nothing.** Every linear read in the tree returns its
   handle inside a fresh cell. Requirement 5 asks for one load. §5 question 2.
5. **Frozen reads.** LE25's tables and P5's table are written once and then read
   many times across passes. Threading a linear handle through every reader is
   the wrong shape for a read-only phase; an O(1) freeze into an unrestricted
   array with a one-load read serves them, and for bytes the frozen form is the
   existing `Bytes` with `bget`.
6. **Growth.** `M4`'s builder does not know its final length. A grow that copies
   into a larger buffer and consumes the old one gives amortized O(1) appends.
7. **The arrow the primitives carry.** E159 forces `=>` on every primitive that
   returns the buffer (probe 5). P2 and P3 are stated pure (`->`,
   `docs/arcs/text-tools-arc.md:144`); once E171 lands, a `->` body cannot call
   them. §5 question 1.

**Verdict:** a real delta.

## 4. The shapes

### Shape A: extend the `Pool`
- **Form:** add `pool-put-u8`, `pool-put-word` and `pool-get-word` crossings over
  the existing `(Pool n)`.
- **Costs:** a memfd, ftruncate and mmap per buffer (`sys.chiral:1011-1013`),
  page granularity for a 64-entry V vector, and every operation `=>`.
- **Forbids:** typed elements. The pool is an untyped byte mapping, so a boxed
  `TalSig` read back is an `I64` that a cast would have to re-type, which the
  tree has no sound form for. It fails LE25.

### Shape B: three carriers, one per element
- **Form:** `ByteBuf`, `WordBuf`, `BoxBuf A`, each with its own primitives.
- **Costs:** three sets of primitives, and a word buffer and a boxed buffer
  that lower identically, since both elements are one `tt-word`.
- **Forbids:** code generic over the element. P3's `diff` is generic in `A`
  (`docs/arcs/text-tools-arc.md:160`). It is two mechanisms where the lowering
  has one.

### Shape C: one carrier `(Buf A n)` of word slots for every `A`, bytes included
- **Form:** one element per word; a byte buffer is `(Buf I64 n)` holding values
  below 256.
- **Costs:** eight bytes per byte. `M4`'s emit buffer for a 1,188,216-byte
  `bin/chirality-bin` becomes about 9.5 MB, and freezing it to `Bytes` costs a
  packing copy.
- **Forbids:** nothing wanted, and it works against requirement 1, whose subject
  is peak memory.

### Shape D: element width as a type index read at lowering
- **Form:** `(Buf A n)` with the slot width chosen from `A` when the call lowers.
- **Costs:** the lowering sees `A` erased. A generic body lowers once, with `A`
  at `tt-word` ([[decisions/decision-erased-word-level]]), so the width would
  have to come from a runtime header tag, a branch per access.
- **Forbids:** one load per read. It fails requirement 5.

### Shape E: one linear discipline, two slot widths, one word carrier for every `A`
- **Form:** `(Buf A n)`, `n` one-word slots, for every `A`: `I64` and boxed
  values share it because both are one word. `(Bbuf n)`, `n` byte slots, whose
  cell is an ordinary `[len][payload]` byte cell. Both are indexed porttypes
  from one module, share the index type `(refine I64 (>= 0) (< n))`, allocate
  through `Alloc`'s `bytes`, release through `adrop`, and freeze in O(1):
  `Bbuf` to `Bytes`, `Buf` to an unrestricted `(Arr A n)` read by `arr-get`.
  Width is fixed by the carrier's name, which the lowering reads, so every
  access is one load or one store.
- **Costs:** two carrier names. A new word face on the TAL and `Mach` floors.
- **Forbids:** a byte buffer of boxed values, which no consumer names, and a
  width chosen by a generic body, which the erased lowering cannot honour.

## 5. The call

- **Chosen:** Shape E. A fell on typed elements and the syscall allocation, B on
  genericity over `A`, C on requirement 1, D on requirement 5. E is the only
  shape in which the byte and word cases differ exactly where the machine
  differs, and `I64` and boxed values share a carrier because the tree already
  lowers both as one `tt-word`. It serves every consumer: `M4` writes a `Bbuf`,
  grows it and freezes it to the `Bytes` the emitter already writes out; P2 and
  P3 write and read `(Buf I64 n)`; P5 builds a `(Buf I64 n)` table and reads it
  frozen through `arr-get`; LE25 builds a `(Buf TalSig n)` and reads it frozen.

**The operation set**, the same on both carriers, with `Bbuf` taking and
yielding an `I64` element masked to its low byte:

| operation | type sketch, `Buf` side | lowers to |
|---|---|---|
| `buf-new` | `(w n I64) A` to `(Buf A n)` | `Alloc` `bytes` of `8n`, then a fill loop |
| `buf-put` | `(1 b (Buf A n)) (refine I64 (>= 0) (< n)) A` to `(Buf A n)` | one word store; the result is `b` |
| `buf-get` | `(1 b (Buf A n)) (refine I64 (>= 0) (< n))` to `A` and `b` | one word load, §5 question 2 |
| `buf-grow` | `(w m I64) (1 b (Buf A n)) A` to `(Buf A m)`, `m` at least `n` | allocate, copy `n` slots, fill the rest |
| `buf-freeze` | `(1 b (Buf A n))` to `(Arr A n)`; `Bbuf` to `Bytes` with a used length `(refine I64 (>= 0) (<= n))` | the same pointer; `Bbuf` rewrites its length word |
| `arr-get` | `(Arr A n) (refine I64 (>= 0) (< n))` to `A` | one word load, unrestricted |
| `buf-drop` | `(1 b (Buf A n))` to `Unit` | `Alloc` `adrop` |

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Do the primitives carry `->` or `=>`? E159 forces `=>` on every one that returns the buffer (probe 5), and E171 would then refuse them inside P2's and P3's pure bodies | **NEEDS-AUTHOR** | measurement and options below |
| 2 | How does a linear read return the buffer without allocating a result cell? | **NEEDS-AUTHOR** | measurement and options below |
| 3 | How does the linear binder reach the buffer? | RESOLVED: as an indexed porttype | probes 1 and 4; `is-linear` at `lib/typing/kernel.chiral:325-330`; the `Pool` precedent at `lib/ports/pool.port:13` |
| 4 | Width as a type index, or separate element types over one carrier? | RESOLVED: width by carrier name, element type by index | Shape D's failure; [[decisions/decision-erased-word-level]] makes every `A` one word, so one word carrier covers `I64` and boxed |
| 5 | Where does the bound check live? | RESOLVED: refinement at compile time, the only form | the row names `mem-put-checked`'s bound; probe 3 shows a guarded computed index proving today, so no runtime-checked twin is needed and none is built. No decision under `docs/decisions/` settles bounds otherwise. Index arithmetic the fragment cannot prove (P3's `k + d`) takes a caller guard; widening the fragment to a linear sum is `E41`'s (`docs/elements/ledger.md:170`) |
| 6 | Freeing and reuse | RESOLVED: `buf-drop` through `Alloc`'s `adrop`; `buf-freeze` hands the cell on | `lib/memory/alloc.chiral:24`; what `adrop` reclaims is the policy's, `memory-discipline/M2` and `M3` |
| 7 | Do existing programs' emitted bytes change? | RESOLVED: no | no existing source names a new primitive; the new `erase-prim` arms and `Mach` fields fire only on them. The compiler's own source grows, so `bin/chirality-bin` changes and the build rule's fixpoint (`C1 == C2`, `C2` reproducing the blob) is the check. Enforcement requirement 7 (`docs/arcs/enforcement-arc.md:471-480`) covers optimizer rewrites and this row adds none, unless question 2 takes option (a) |
| 8 | A boxed value stored in a buffer that outlives its region | DEFERRED: `memory-discipline/M2` (`E82`) and `E41` | a region reset under a live `Buf` of pointers is a region-typing question; under `alloc-bump` nothing is reclaimed, so nothing dangles |

### NEEDS-AUTHOR 1: the buffer's arrow

**Plainly:** an in-place write to a buffer only one binder can see is
unobservable, so P2 and P3 can stay pure. The rule that forbids a pure arrow
here was written for capabilities, and probe 6 shows its stated reason does not
hold for linear results in general. Changing it touches the loader's rule, which
the author reviews.

- **Measured:** E159 refuses `(extern buf-new (-> (0 A (type 0)) (w n I64) A
  (Buf A n)))`. Its premise, *"a pure `->` spine hands the capability back
  unrestricted"* (`lib/module/loader.chiral:446-449`), does not reproduce for a
  linear data result: probe 6's `->` extern result is tracked at q1 and its drop
  refused. [[decisions/decision-effect-facets]] states *"holding is not
  crossing"* (`docs/decisions/decision-effect-facets.md:91-94`).
- **(a)** Keep E159 as built. Every primitive is `=>`; P2 and P3 are declared
  `=>` and lose the purity `docs/arcs/text-tools-arc.md:144` states.
- **(b)** E159 distinguishes an authority porttype, whose mint crosses, from a
  memory porttype, whose operations are `->`. The loader gains the distinction
  and the buffer module declares its two carriers as memory porttypes. P2 and P3
  stay pure under E171.
- **Recommendation:** (b). It is the proper answer: the effect membrane then
  says what crosses, and a local buffer crosses nothing.

### NEEDS-AUTHOR 2: the linear read

**Plainly:** a read has to hand the buffer back, and the tree's only way to hand
two things back is a fresh cell, which is an allocation per read. Requirement 5
asks for one load, so either the language gets a read form that never builds the
pair, or the lowering learns to skip it.

- **Measured:** `nb-pool-read` allocates a byte cell and a two-field result cell
  per read (`lib/lowering/tal/sys.chiral:1104`). P2's table costs `m` by `L`
  reads per candidate; at a 24-byte result cell that is 24 bytes of heap per DP
  cell read, which is the churn `memory-discipline/M3` exists to remove.
- **(a)** `buf-get` returns `(Got A n)`, and the lowering fuses a `case` that
  destructures it at once into one load with the handle register passed
  through. A result used any other way keeps its cell. One load holds where the
  pattern matches, and the fusion is a rewrite that brings enforcement
  requirement 7 in.
- **(b)** A surface binding form, `(buf-read (x b2) (buf-get b i) body)`, typed
  as `case` on `Got` and lowered with no pair ever built. One load holds by
  construction.
- **(c)** A borrow quantity in the kernel, so a read takes the buffer without
  consuming it. A trusted-core edit to QTT that no consumer needs beyond this
  read.
- **Recommendation:** (b). The one-load property lives in the form, which the
  build rule favours over a pattern the lowering could miss.

## 6. The mint packet

Blocked on §5 questions 1 and 2. The packet below holds under the
recommendations; either ruling the other way changes the arrows in the catalog
row and nothing else in it.

- **Elements:** one. The two carriers share the index type, the allocation, the
  release, the read form and the gate, and the word face exists only to serve
  them. Split into a byte element and a word element, each would still carry the
  read form and the arrow rule, and neither alone discharges requirement 5,
  which names all three element types.
- **Band:** `UNASSIGNED`. `E81-E85` is minted whole
  (`docs/arcs/memory-discipline-arc.md:14`).
- **Catalog row:**
  `| E<NN> | **The linear indexed buffer**: `(Buf A n)` of one-word slots for every `A` and `(Bbuf n)` of byte slots, indexed porttypes allocated through `Alloc`, written in place and read in one load under a linear binder, the index a `(refine I64 (>= 0) (< n))` proven at compile time, frozen in O(1) to `(Arr A n)` or `Bytes`; a word load and word store join the TAL and `Mach` floors | primitive | Wadler 1990, *Linear types can change the world!*; Clean uniqueness-typed arrays; Linear Haskell's mutable arrays | shape | requirement 5 of the memory-discipline arc; one mechanism for `M4`'s byte builder, text-tools P2, P3, P5 and LE25's tables | SH |`
- **Ledger row:**
  `| E<NN> | linear-buffer | design | The linear indexed buffer: `Buf`/`Bbuf`/`Arr`, the word face on TAL and `Mach`, the read form. Check: a gate phase over bound refusal, linear-reuse refusal, a write whose cost is flat in the length, a read that is one load in the listing, freeze round-trips; BUILD RULE `C1 == C2` | `memory-discipline/M8` | SH |`
- **Size:** about 13 files and 450 lines. A new `lib/memory/buf.chiral` with the
  porttypes and operations, about 90; the word face in
  `lib/lowering/tal/{ir,ssa,check,eval,erase,reify}.chiral` and
  `lib/typing/erased-nf.chiral`, about 70, sized on the byte face's arms beside
  it; `lib/lowering/mach/{mach,emit-core}.chiral` and the two instances, about
  50, sized on `x-bgt`; `buf-grow` and the fill loop as hand TAL beside
  `nb-copy`, about 40; the arrow and read-form rulings in the loader and parser,
  about 60; a gate script and probe roots, about 140.
- **Related:** [[banks/memory]], [[arcs/memory-discipline-arc]],
  [[arcs/text-tools-arc]], `docs/arcs/parts/lowering-and-emit-LE25.md`,
  [[decisions/decision-erased-word-level]],
  [[decisions/decision-effect-facets]].

### Needed and unrostered

| what | why this row needs it | where it would go |
|---|---|---|
| E159's check misses a linear result carried inside a data | probe 6: an extern returning `Got` through `->` loads, while the same buffer returned bare is refused. The rule judges the result's head only | a `revisit` of `E159`, or an enforcement row |
| `mem-put-checked` and `lib/memory/mem-linear.chiral` stay at zero importers | this row copies its bound and does not import it; whether the `Pool`'s raw `mem-put` keeps its runtime-checked path once a checked buffer exists is the memory bank's question | `memory-discipline/M6`'s neighbour, or [[banks/memory]] residue |
| `M4`, P2, P3, P5 and LE25 rewritten onto the buffer | each consumer's adoption is its own row's work; LE25 §5 reason 2 names the swap to a dense table and schedules nothing | the consumer rows themselves; LE25 needs a `revisit` once this is built |
