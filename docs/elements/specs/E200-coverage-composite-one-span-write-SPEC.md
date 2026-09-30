---
element: E200
slug: coverage-composite-one-span-write
title: "**The coverage composite: one span write, one allocation**"
design: arcs/parts/display-calculus-R3.md
status: audited
updated: 2026-09-18
---

# E200 SPEC: **The coverage composite: one span write, one allocation**

> The build half, produced by the `design-to-spec` run. The design at
> `docs/arcs/parts/display-calculus-R3.md` made the design decisions and an audit gated
> them before this element minted. An implementation run follows THIS file.

## 1. Deliverable

- **After this runs:** a program composites a rectangle of coverage against one
  colour over a destination span in **one `ti-bnew` and one pass**, through a
  new pure `->` prelude extern `bover`, whose mask operand and colour operand
  are two distinct one-constructor types that no call site can swap.
- **Chosen shape:** Shape A, taken at `docs/arcs/parts/display-calculus-R3.md`
  §5 on four cited grounds. One extern, one `prim2lib-table` row, one hand-written
  TAL routine, no change to `lib/lowering/tal/check.chiral`. The fill half is
  `brepeat` (`lib/prelude/prelude.chiral:100`) and this element adds nothing to it.
- **Names this SPEC fixes**, which the design left unstated: the extern is
  `bover`, after `PIXMAN_OP_OVER` (`FOOTRENDER:1080`, quoted at
  `records/findings.md:518`); the wrappers are `Cover` and `Pix`; the routines
  are `nb-bover` and its loop `nb-bover-go`. All four names are free tree-wide,
  measured 2026-09-18 by `grep -rlw` over `lib/` and `prog/`. `Color` is **not**
  free and §2 records why.
- **Non-goals.** A varying-span write of arbitrary content, which `FD-33`
  measures that no surveyed renderer performs (`records/findings.md:518`). The
  zero-allocation pool path, which is the design's Shape D. Any transfer
  function or unpremultiply, which `FD-37` measures nobody evaluates in integers
  (`records/findings.md:561`) and which the arc's `R2` owns. The fixed-point
  coordinate type, the accumulator, the prefix sum, the subdivision and the span
  emitter, which are `display-calculus/R10` through `R15`. Residue is §5.

## 2. What the code forces

The design chose a shape against structural outlines. This is where the live
files push back. Every line below was opened in the working tree at `207f68a`
on 2026-09-18.

| target | the design assumed | the file admits | verdict |
|---|---|---|---|
| `lib/prelude/prelude.chiral:96-104`, plus `:91-92` | one extern beside `brepeat`, and a pure `Bytes` surface of eleven | eleven exactly: `str->bytes` and `bytes->str` at `:91-92`, nine at `:96-104`. `grep -c '^(extern'` returns **34** for the file | agrees |
| `lib/protocol/grid.chiral:6` | the colour wrapper is a new one-constructor type | **`Color` is taken.** `(data Color ()` sits there with `color-default` and `color-rgb` at `:9`. A second `Color` in `prelude/prelude` collides in the flat blob, which is the E154 shape the E189 probe steers around (`prog/e189-widening-multiply.prog:32-35`) | **constrains** |
| `lib/lowering/tal/erase.chiral:112-139` | one `prim2lib-table` row | twenty-three rows, one `cons` pair per surface name, terminated at `:139`. `erase-prim` reaches it last, at `:167-169`, and an absent row is the error `prim not in native subset:` at `:169` | agrees |
| `lib/lowering/compile-back.chiral:62-64`, `:330` | nothing stated | **no further table is owed.** `prim-table` holds five rows and they are the i64 arithmetic ops. Every other extern's `TalSig` is derived from the program's own declarations by `nprims->table` (`:147-148`) and appended at `:330`, so the `(extern bover …)` line is the single source of the signature | agrees |
| `lib/lowering/tal/ir.chiral:19-34` | `ti-bnew` plus `ti-bput` carry the routine | twelve `TInstr` constructors and **no field-load instruction**. A boxed cell is read only by binding its fields through `ti-tcase src true`, whose branch form is `((tag, binds), code)` at `:44-46` | **constrains** |
| `lib/lowering/tal/bytes.chiral`, `lib/lowering/tal/sys.chiral`, `lib/lowering/tal/sys-linkage.chiral` | the shape is settled by what `native-lib` already holds | **58 of 58 `ti-tcase` forms in hand-written TAL carry `boxed = false`**, 14 in `bytes.chiral`, 44 in `sys.chiral`, none in `sys-linkage.chiral`. Not one hand-written routine destructures a boxed cell today. `nb-be-peek-t` (`bytes.chiral:35-38`) *builds* one with `ti-cona` and reads none | **constrains** |
| `lib/lowering/tal/bytes.chiral:636-645` | one `TIFn` appended LAST, twenty-eight members today | twenty-eight exactly, and the E145 note is at `:643-644` verbatim: "appended LAST so it does not shift the addresses of the other runtime routines" | agrees, with the ordering carried to §3 |
| `lib/lowering/tal/bytes.chiral:60-76`, `:163-186` | `nb-copy-t` is 17 lines, `nb-rep-go-t` is 15 | both hold. `nb-brepeat-t` at `:179-186` is the entry that allocates once with `ti-bnew` at `:183` and hands a recursive loop the extent, which is the two-routine shape this element copies | agrees |
| `lib/lowering/tal/bytes.chiral:610-619` | `bput-u8` costs six allocations per byte | six, read off the body: `bslice` prefix, `pack-u32`, `bslice` of that, the suffix `bslice` or `cell-new 0`, the inner `bcat`, the outer `bcat`. The comment at `:603-609` states the fresh-cell discipline that forces them | agrees |
| `lib/typing/refine.chiral:11`, `:13-18` | the length seat carries a refinement on its own signature | the atom language is five `SymOp`s over **a constant or an operand level**, held in `sym` as `(List (Pair SymOp I64))`. A bound relating two arguments through `blen` and a multiply has no spelling in it | **constrains** |
| `lib/ports/sock.port:69` | a refinement-typed extern argument is ordinary | **it is the tree's only one**, and it is `=>`. Zero pure `->` externs carry a refinement. They do lower: `lib/lowering/compile-front.chiral:69` erases a refinement to its base and names `sock-recv`'s `n` as the case | **constrains** |
| `lib/memory/arena.chiral:29`, `lib/memory/alloc-growing.chiral:22-24`, `lib/memory/alloc.chiral:18-24` | a 64 MB arena that reclaims nothing | `67108864` at `arena.chiral:29`, doubling by `mremap` at `:40-41`. `alloc-growing`'s `renter`, `rexit` and `adrop` are three `(the (List Asm) nil)` lists, reaching the fields declared at `alloc.chiral:22-24` | agrees, and §1's operating condition rests on it |
| `prog/compiler.prog`'s closure | nothing stated; the tree records sixty (`records/baseline-alignment.md:199`) | **sixty-one**, measured today by `chirality_blob_file "lib:prog" prog/compiler.prog` and counting `^(end-module` lines: 61 lines, 61 distinct names. `prelude/prelude`, `lowering/tal/bytes` and `lowering/tal/erase` are all three inside it | agrees; the fixpoint is owed |
| `tools/test/run-tests.sh:345-368` | seven gates registered at 25 through 31, so the next free number follows them | **eight**, through 32: `mul-widen.sh` took 32 at `:368`. `records/author-calls.md:64` still says seven and is one gate behind the file it points at. The ruling at `:348-354` makes this file the only authority, so **33 is the first free number** | **constrains** |
| `tools/test/run-tests.sh:171-197` | Phase 7 sweeps every root and the element owes a phase of its own | Phase 7 compiles and does not run: `:150-151` says "Compile only (no run)". `:199-207` removes its rows from the assertion count because "A compile carries NO expected value". A sample root's exit code is asserted by nothing | agrees, and sharpens §4 |
| `prog/samples/e109_bput_u16_le.prog:21-45`, against `tools/test/mul-widen.sh:9-12` | the consumer follows the `e109` precedent | the two precedents disagree and the newer one rules. `e109`'s `compile-main` returns its own verdict as an exit code. `mul-widen.sh:9-12` states the rule that supersedes it: "a probe that derives its own verdict is green under any mutant that changes what the verdict says" | **constrains** |
| `tools/test/mul-widen.sh:76-81` | a mutant is a `sed` over a scratch `lib/` | a mutated `lib/` alone proves nothing, because the probe is compiled by a binary embedding the old backend. Each such mutant assembles `prog/compiler.prog` from the scratch `lib/`, builds **one generation**, and compiles the probe with that generation, at about 2 s per generation | **constrains** |
| `tools/test/mul-widen.sh` and every registered gate beside it | the phase costs about 25 lines | **fifteen registered gates carry a scratch-`lib/` mutant runner and the smallest is 259 lines**, the largest 781: `capture-fields` 259, `apply-word` 281, `encoding` 306, `apply-spine` 378, `defunc-blame` 397, `crypto` 403, `recording` 414, `mul-widen` 435, `render-doc` 582, `matcher` 593, `arity` 598, `doc` 629, `face` 706, `pretty` 715, `row` 781. A gate with four run mutants, three of which rebuild a generation, runs to hundreds of lines | **constrains** |

### Constraints carried into §3

1. **`Color` is taken, so the wrappers are `Cover` and `Pix`.** Both names, and
   `Mask` and `bover`, return nothing from `grep -rlw` over `lib/` and `prog/`.
   `Span` is taken by `lib/text/matcher.chiral`, so this element leaves it alone.
2. **The `TIFn` is the first hand-written TAL to destructure a boxed cell.** The
   extern's signature mentions `Cover` and `Pix`, both one-constructor data with
   a field, so both are boxed by `ir.chiral:5-7` and `erase.chiral:75`, and the
   only way into the field is `ti-tcase src true` with one branch at tag 0. The
   mechanism is live along its whole length, and hand-written TAL enters it by
   the same door compiled code does: `boxed-of` (`erase.chiral:79-83`) computes
   the flag for compiled code, `emit-core.chiral:514` reads the flag and loads
   the tag through `mach-lsb` rather than `mach-lsc`, `emit-core.chiral:204`
   emits the branches, and `emit-binds` (`:193-196`) issues the field loads
   through `mach-fld`. Both `lsb` and `fld` are declared at
   `lib/lowering/mach/mach.chiral:39-40` and both are implemented on x64,
   `fld` at `lib/lowering/x64/mach.chiral:1716` and `lsb` at `:1718`.
   Zero precedents in hand-written TAL is a sequencing risk and
   not a refusal: nothing on the path refuses `boxed = true`, it is only that
   no hand-authored routine has taken it, so the tag and bind indices are
   checked by the gate rather than by a precedent. §3 step 1 puts the unwrap
   first with its own evidence line.
3. **The length guarantee moves from the type to the routine.** The relation the
   seat needs is `blen dst == 4 * blen cover`, and the refinement fragment holds
   constants and operand levels only. The extent is therefore derived inside
   `nb-bover` as `n = min(blen cover, blen dst / 4)` with `op-lti` and `op-div`,
   both members of the sixteen-op sum (`lib/prelude/prelude.chiral:36-39`), and
   the gate asserts the refusal behaviourally. The signature still carries
   `(refine I64 (>= 0))` nowhere, because Shape A has no explicit length
   argument to hang it on: the extents are the two cells' own lengths.
4. **The consumer prints and the gate compares.** The probe emits tagged rows on
   `put` and computes no verdict, on `mul-widen.sh:9-12`.
5. **Three of the four mutants rebuild one compiler generation.**
6. **The phase number is 33.**

### Refusals

**None.** No target refuses Shape A. `status` stays `draft`.

## 3. Change plan (ordered, commit-sized)

### Step 1: the primitive, in three compiler files, as one commit

- **Target:** `lib/prelude/prelude.chiral` at `:94-104`;
  `lib/lowering/tal/erase.chiral` at `prim2lib-table`, `:112-139`;
  `lib/lowering/tal/bytes.chiral` at the tail and at `native-lib`, `:636-645`.
- **Change, in the order the file tree forces:**
  1. `prelude.chiral`, after `brepeat` at `:100`: two one-constructor data
     declarations and one extern.
     `(data Cover () (cover (bs Bytes)))`, one byte of coverage per pixel.
     `(data Pix () (pix (bs Bytes)))`, one premultiplied ARGB8888 quad.
     `(extern bover (-> Bytes Cover Pix Bytes))`, destination span, mask,
     colour, returning a fresh span of the destination's length. The comment
     states the encoding the wrapper names, 8-bit premultiplied and encoded,
     which `FD-37` records as Wayland's own floor (`records/findings.md:563`).
  2. `bytes.chiral`, at the file tail after `bput-u16-le` (`:628-633`):
     `nb-bover-go-t`, the loop, and `nb-bover-t`, the entry. The entry unwraps
     both boxed operands with two `ti-tcase src true` forms at tag 0, takes
     `ti-blen` of each cell, computes `n = min(blen cover, blen dst / 4)`, does
     **one** `ti-bnew` of `blen dst`, and calls the loop. The loop does four
     `ti-bget` from the destination, one `ti-bget` from the mask, four `ti-bget`
     from the colour, the source-over arithmetic, and four `ti-bput` into the
     fresh cell, then recurses on `n - 1`. `nb-copy-t` (`:60-76`) is the recursion
     shape and `nb-brepeat-t` (`:179-186`) is the allocate-then-loop shape.
     Bytes at and beyond `4n` are copied through unchanged, so the result is
     length-preserving on the destination.
  3. `bytes.chiral`, `native-lib` at `:636-645`: both new routines appended
     **after `nb-be-close-t`**, at the very end of the `cons` chain. ⚑ The
     reason is stated at `:643-644` and it is the E145 address note: the list
     position is the runtime routine's address, so an insertion anywhere else
     shifts the address of every routine after it and changes the emitted bytes
     of every root that reaches one. The note's scope is layout, and it
     makes no correctness claim, because a full rebuild regenerates every call site from
     the same list, and §4 prints it as a measured note and leaves it ungraded.
  4. `erase.chiral`, inside `prim2lib-table` before the `nil` at `:139`:
     `(cons (pair "bover" "nb-bover")`. No `crossing-wraps` row is owed, on the
     grounds the table's own `be-peek` and `backend-close` comments state at
     `:125-133`: a pure `->` extern crosses no membrane and issues no syscall.
- **Size:** ~62 lines added, 1 changed. `prelude.chiral` ~12, `erase.chiral` ~4,
  `bytes.chiral` ~46 added and the `native-lib` tail line rewritten.
- **The arithmetic the routine implements**, so the gate can recompute it: for
  each channel, with `a` the coverage byte, `s` the colour channel and `d` the
  destination channel, `out = div255(s * a) + div255(d * (255 - div255(s_a * a)))`
  where `s_a` is the colour's alpha channel and `div255(x)` is
  `((x + 128) + ((x + 128) >> 8)) >> 8`. Every operation is a member of the
  sixteen-op sum at `lib/prelude/prelude.chiral:36-39`: `op-add`, `op-sub`,
  `op-mul`, `op-shr`. `FD-37` prices this family at ±1 LSB
  (`records/findings.md:561`) and no new op is owed.

> This step is compiler source and owes the build rule in [[working-discipline]]:
> `build-new → test → promote`, generations from the same blob until two
> consecutive agree, a non-empty check before every `cmp`, a stop at `C4`.

- **Fixpoint, and where the first agreement is expected.** All three files sit
  inside `prog/compiler.prog`'s 61-module closure, measured in §2. The change
  reaches emission, because `native-lib` is appended to every image at
  `lib/lowering/compile-emit.chiral:295`, so `docs/definitions/working-discipline.md:35-41`
  puts the first agreement at **`C2 == C3`** and `C1 != C2` on its own reports a
  correct build. `E188` at `032681f` is the worked three-generation case
  (`working-discipline.md:52-60`). Stop at `C4`.

### Step 2: the consumer, one root

- **Target:** `prog/samples/e200-coverage-composite.prog`, new file.
- **Change:** a root with `(def compile-main (=> I64 I64))` importing
  `prelude/prelude` and `ports/stdio`, printing tagged rows on `put` and
  computing no verdict. Its literal fixture is what makes the element checkable
  alone: it constructs the mask in source, so nothing upstream of `bover` has to
  exist. Rows:
  - `R1` a four-pixel span, destination `str->bytes` of sixteen known bytes,
    mask `(cover (str->bytes "\x00\x55\xaa\xff"))`, colour `(pix …)` one
    premultiplied quad. Prints the sixteen output bytes as hex.
  - `R2` the same span with the coverage-0 pixel first, printed on its own, so
    the identity case has its own row.
  - `R3` the coverage-255 pixel on its own, so the replacement case has its own
    row.
  - `R4` an over-long mask: 8 coverage bytes against a 16-byte destination that
    admits 4 pixels. Prints the output length and the trailing bytes.
  - `R5` a 1920-pixel span, 7,680 destination bytes and 1,920 mask bytes.
    Prints the output length and a checksum fold.
  Hex printing follows `prog/e189-widening-multiply.prog:45-57`, whose comment
  at `:14-19` records that `i64->str` segfaults on a wide operand.
- **Size:** ~70 lines.
- Not compiler source. No fixpoint. Phase 7 (`run-tests.sh:171-197`) sweeps it
  and compiles it, and asserts nothing about what it prints.

### Step 3: the gate and its registration

- **Target:** `tools/test/span-over.sh`, new file; `tools/test/run-tests.sh` at
  `:368`, one `run_phase` line appended after phase 32.
- **Change:** the six rows and four mutants of §4, on `mul-widen.sh`'s driver
  shape: its `mutlib` (`:141-155`), `gen` (`:158-166`) and `build` (`:169-177`)
  helpers, including both `mutlib` guards, the symlink check and the
  did-not-mutate check.
- **Size:** ~260 lines for the script, 1 line in `run-tests.sh` plus ~4 of
  comment.
- Not compiler source. No fixpoint.

**Total projection: ~400 lines added across six files, 1 changed.** The design
sized this at "~120 lines added and ~2 changed" over five files
(`docs/arcs/parts/display-calculus-R3.md` §6). The gap is the gate, and **the
design's estimate is the wrong one.** It allowed 25 lines on the basis "the
phase-script floor", and no such floor exists: the fifteen registered gates
carrying a scratch-`lib/` mutant runner are 259 to 781 lines. The primitive
itself lands inside the design's estimate. The sixth file is `run-tests.sh`, one
line.

## 4. Conformance gate

- **Baseline.** Nothing composites anything anywhere in the tree today.
  `tools/test/run-tests.sh` registers no phase over a byte composite, `bover`
  appears in no file, and the only path to a varying span is `bput-u8`
  (`lib/lowering/tal/bytes.chiral:610`) at six allocations per byte.
- **Expected.** `tools/test/span-over.sh` green at six rows, four mutants each
  reddening exactly the rows named for it and no others.
- **Named phase: 33.** `tools/test/run-tests.sh:348-354` carries the author's
  2026-09-06 ruling that this file is the only authority for a phase number and
  that a gate takes the first number colliding with nothing. Eight are
  registered, 25 through 32, the eighth being `mul-widen.sh` at `:368`, so 33 is
  the first free. ⚑ Two documents disagree with the file and both are already
  recorded. `records/author-calls.md:64` says seven at 25 through 31 and is one
  gate behind. `docs/definitions/testing-floors.md:69` still calls the number a
  standing author call, which is `PRB-93` at `records/lenses/problems.md:1308`.
  Neither is repaired here and neither reopens the call.

### The six rows

| row | asserts | why it cannot be satisfied by looking at nothing |
|---|---|---|
| G1 | the probe resolves, compiles to a non-empty ELF, exits 0 and prints five tagged rows | it is the precondition every row below reads, and `mul-widen.sh:212-217` aborts the whole gate when it fails |
| G2 | every output byte of `R1` equals the source-over value **recomputed in bash** from the row's destination, mask and colour bytes, which the gate script carries as its own literals beside the probe's, by §3 step 1's formula | no golden is pinned. A golden cut by running the code pins a wrong answer as correct for good, which is `mul-widen.sh:45-51`'s G4 shape. The gate holding the operands rather than reading them back out of the probe is also what lets M4 convict |
| G3 | the two extremes are exact: `R2`'s coverage-0 pixel leaves all four destination bytes byte-identical, and `R3`'s coverage-255 pixel leaves all four equal to the colour | these are the two points where a rounding error cannot hide, and they are the rows a dropped mask term moves in opposite directions |
| G4 | `R4`'s output length equals the destination length, its first sixteen bytes are the composite of the four pixels the destination admits, and the run does not fault | the extent bound lives in the routine and not in the type (§2 constraint 3), so this is the only place the length discipline is checked at all |
| G5 | `R5`'s 1920-pixel span completes, and the probe's max RSS is at most one eighth of a control root doing the same sixteen spans through `bcat` per pixel | the arithmetic sets the threshold and no observation pins it: sixteen spans cost 122,880 B here and 118,026,240 B through `bcat`, against a 67,108,864 B arena (`lib/memory/arena.chiral:29`). The control must grow the arena and this must stay inside it |
| G6 | both halves of the pair are reachable alone: a root calling only `brepeat` compiles with no reference to `bover`, and the probe calling `bover` compiles with no reference to `brepeat` | `docs/goals/display.md:43-45` consequence 3 is a property of the vocabulary, and a gate over one primitive never sees it |

### The four mutants, each actually run

| mutant | what it breaks | rebuilds | pins red |
|---|---|---|---|
| **M1 `coverage-dropped`** | in a scratch `lib/`, `nb-bover-go-t`'s multiply by the mask byte becomes a multiply by 255 | one generation | **G2 and G3's coverage-0 row.** G3's coverage-255 row stays green by construction, and that asymmetry is what makes the mutant informative rather than a blanket failure |
| **M2 `extent-off-by-one`** | the loop bound becomes `n + 1`, so the routine reads one pixel past the shorter cell | one generation | **G4, and G1 where it faults.** G2, G3 and G6 stay green, so a red outside that set says the blast radius was wrong |
| **M3 `prim2lib-row-dropped`** | the `(pair "bover" "nb-bover")` row is deleted from `prim2lib-table` | one generation | **G1, with the exact refusal `prim not in native subset: bover` off stderr**, which `erase.chiral:169` constructs. It proves the rewrite table is load-bearing and that the extern does not lower by some other path |
| **M4 `fixture-mask-collapsed`** | the probe's `R1` mask becomes four 255 bytes | nothing | **G2 alone.** `R2` and `R3` carry their own mask literals and this mutation does not reach them, so G3 stays green and a red there says the blast radius was wrong. It convicts the fixture rather than the backend, on `mul-widen.sh:104-106`'s M4 shape, and proves `R1`'s four coverage bytes are load-bearing rather than echoed from the destination |

⚑ **Each mutant pins the whole set of rows it moves**, and a row moving outside
its set fails the mutant. `records/gate-audit.md` GA-21 and GA-22 both convict a
gate naming one row per mutant, as `mul-widen.sh:83-86` records.

⚑ **The E145 placement is printed as a measured note and left ungraded.** The gate builds
one generation from a scratch `lib/` with `nb-bover-t` spliced before
`nb-bfind-from-t` instead of appended, compiles the probe with it, and prints
whether the ELF differs from the append-last build and whether the probe's five
rows are unchanged. The expected reading is that the bytes differ and the
behaviour does not, because a full rebuild regenerates every call site from the
same list. Grading it would assert a correctness property the note does not
claim, which is the failure `BA-39` records in `E173`'s own gate
(`records/baseline-alignment.md:426-433`): a gate row asserting a refusal that
nothing enforces passes by looking at nothing.

- **Done when:** `tools/test/run-tests.sh` runs phase 33 at six rows green and
  zero failed, each of M1 through M4 reddens exactly the rows its table entry
  names, and the promoted compiler reaches a byte-identical fixpoint at
  `C2 == C3` with the non-empty check before every `cmp`.

## 5. Residue and links

### The operating condition, and what blocks the element's scale

**One allocation per span is the shape chosen precisely so this element's own
cost is linear**, and it is. A 1920-pixel scanline is one 7,680-byte cell and
one pass, against 7,376,640 bytes for the `bcat` route
(`prog/demo/sprites.chiral:58-63`, right-recursive over k pieces of s bytes, so
`s * k * (k+1) / 2`) and 147,490,560 bytes for `bput-u8` per byte
(`lib/lowering/tal/bytes.chiral:610-619` at `3n - off + 4` each). Against the
67,108,864-byte arena (`lib/memory/arena.chiral:29`), whose `renter`, `rexit`
and `adrop` are three empty instruction lists
(`lib/memory/alloc-growing.chiral:22-24`) reaching the `renter`, `rexit` and
`adrop` fields declared at `lib/memory/alloc.chiral:22-24` and bound as `re`,
`rx` and `dr` by the accessors at `:27-35`, the three routes read:

| route | one 1920-pixel scanline | one 1080-row frame | arena reach |
|---|---|---|---|
| `bput-u8` per byte | 147,490,560 B | | exhausts at roughly byte 3,100 of the first scanline |
| `bcat` per pixel | 7,376,640 B | 7,966,771,200 B | 9 of 1080 rows |
| **`bover`, this element** | **7,680 B** | **8,294,400 B** | **8 frames** |

**What `E200` can do before `E84` lands.** One span, at linear cost, at any
width the two cells admit. A glyph, a sprite row, a scanline, an offscreen
layer: each is one `bover` call, one allocation, one pass, and the element's own
arithmetic never touches `bcat`.

**What it cannot do.** Assemble many spans into one surface. Every caller that
joins spans with `bcat` re-enters the quadratic that belongs to `bcat` and not
to this element, and at 1,920 pieces the 8.5x it costs at 16 pieces is 960x:
right-recursive `bcat` over k pieces costs `(k + 1) / 2` times the linear route.
`docs/elements/catalog.md:308-312` records the same site trapping mid-emit at
compiler scale. **`memory-discipline/M4` owns the fix and it is minted:**
`docs/arcs/memory-discipline-arc.md:81` reads "`alloc-dps`: a destination-passing
emit buffer, and `nb-bcat`'s quadratic goes", state `open`, element **`E84`**,
whose catalog row at `docs/elements/catalog.md:334` calls itself "The direct
`nb-bcat`-quadratic kill" and whose ledger state is `design`
(`docs/elements/ledger.md:173`). This is a named blocking condition on the
element's **scale** and not a deferral to a phantom, which is what
`docs/definitions/working-discipline.md:74-85` forbids. `E63`'s catalog row
(`docs/elements/catalog.md:205`) is the author's worked example of the form: the
element stands, its blocker is named, and what it reaches and does not reach is
stated rather than implied.

**A second condition sits beside it and is a different element.** One allocation
per span times 1080 spans is 8,294,400 bytes per frame with nothing reclaiming
any of it, so a frame loop grows the arena without bound. That is the discipline
and not this primitive: `memory-discipline/M2`, element **`E82`**, minted, state
`design` (`docs/arcs/memory-discipline-arc.md:79`,
`docs/elements/ledger.md:171`).

### Deliberately unbuilt

- **The zero-allocation pool composite**, the design's Shape D. Kept as the path
  a frame loop will want. `display-calculus/R15` holds it
  (`docs/arcs/display-calculus-arc.md:220`), added at `2f3d691`, and records the
  design's refusal with it.
- **The encoding as a type**, `display-calculus/R2`. `bover`'s signature does not
  move when `R2` widens the colour wrapper, which is the design's §5 question 1.
- **The fixed-point coordinate type**, `display-calculus/R10`.
- **The accumulator, the prefix sum, the subdivision, the span emitter and Shape
  D**, `display-calculus/R11` through `R15`, added at `2f3d691`. This SPEC
  reaches into none of them. The coverage bytes `bover` consumes are `R12`'s
  output, the row prefix sum with its truncating clamp to the coverage byte
  (`docs/arcs/display-calculus-arc.md:217`), handed over by `R14`'s span emitter
  (`:219`), and this element constructs them in its own fixture instead.
- **The eighth unclamped byte-cell seat.** `E198`
  (`docs/elements/catalog.md:649`) is the census over the prelude's 34 externs
  and it is minted. `bover` takes no explicit length argument, so it adds no
  seat of the `str-sub` kind (`docs/elements/ledger.md:316`), and the extent
  discipline it does carry is asserted by G4 rather than by a type.
- **A screen.** The output has no path to one until `E199` lands:
  `docs/arcs/canvas-arc.md:114` measures `sock-send-fd` absent from the lowered
  crossings, so `prog/demo/wl-client.chiral:201` does not lower.

### Corrections this run measured and did not take

- `records/author-calls.md:64` reads "Seven registered at 25 through 31" and the
  file it cites as the only authority registers eight, through 32. A `doc-audit`
  or `revisit` on that row owns it.
- `docs/definitions/testing-floors.md:69` calls the phase number a standing
  author call after it was ruled. Already `PRB-93`
  (`records/lenses/problems.md:1308`).
- `records/baseline-alignment.md:199`, `BA-16`'s 2026-09-04 re-measure, says the
  compiler's closure is sixty modules. Measured today it is sixty-one.
- `records/author-calls.md:72` says the pure `Bytes` surface is twelve externs.
  §2 counts eleven at `lib/prelude/prelude.chiral:91-92` and `:96-104`.
- `docs/decisions/decision-display-numerics.md:26-28` lists the `Op` sum as
  fifteen and omits `op-mulhu`. The sum at `lib/prelude/prelude.chiral:36-39` is
  sixteen. Named by the design and left to a `doc-audit` run.
- `lib/prelude/prelude.chiral:10` says the file declares 38 externs and
  `grep -c '^(extern'` returns 34. `E198`'s own title already says 34.

### NEEDS-AUTHOR

**None.** Every question this run met is closed by a settled document, a pinned
measurement, or a live file. The seat call at `records/author-calls.md:72`,
which arc owns `display-calculus/R3`, stays `unreviewed` on its own terms and
nothing in this SPEC forecloses it.

### Related

[[arcs/display-calculus-arc]], [[goals/display]], [[arcs/canvas-arc]],
[[arcs/memory-discipline-arc]], [[arcs/enforcement-arc]], [[banks/memory]],
[[banks/render]], [[decisions/decision-display-numerics]],
[[decisions/decision-primitive-with-consumer]], [[decisions/decision-lane-split]],
[[decisions/decision-scope]], [[working-discipline]],
`records/findings.md` `FD-33`, `FD-37`, `FD-39`.
