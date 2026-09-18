---
row: display-calculus/R3
arc: display-calculus
title: the span primitive is one primitive wide, the coverage composite. The fill half already ships as `brepeat`, the pure `Bytes` surface is eleven externs and not twelve, `bput-u8` is a builder at six allocations per byte, and no surface extern reaches the `ti-bnew`/`ti-bput` pair the IR already carries
kind: primitive
origin: pair
req: 1
status: draft
updated: 2026-09-18
---

# display-calculus/R3: the span primitive

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** a program must be able to write one rectangle of pixels in time
  and allocation linear in the rectangle, for the two writes every surveyed
  renderer performs and for no third write. Those two are *fill a rectangle with
  one colour* and *composite a rectangle of coverage against one colour*, per
  `records/findings.md:518` (`FD-33`, part 5).
- **Serves:** requirement 1 of [[arcs/display-calculus-arc]], "A property value
  carries its invariant. Every property is a sum whose invalid states have no
  representation, so a construction the vocabulary forbids fails the checker."
  A coverage mask and a colour are two `Bytes` today and nothing distinguishes
  them at a call site.
- **Goal:** [[goals/display]], condition 4, "The pixel. A pixel has a correct
  value by type." ⚑ That condition holds no arc file and is named in
  `docs/goals/display.md:65-67` as standing *behind the span-primitive question*,
  so this row is the one rostered row reaching into it. Condition 4's own
  numeric question is settled by [[decisions/decision-display-numerics]].
- **Also cited by:** `docs/arcs/canvas-arc.md:115` and
  `docs/goals/own-web.md:77`, both as the second of two blockers between a
  canvas and a screen.

## 2. What the tree holds

Measured 2026-09-18 in the working tree at `fd973da`.

- **Bank:** [[banks/memory]] owns this row, Shard 6, byte cells `[len][payload]`,
  `docs/banks/memory.md:173-182`, whose home is `lib/lowering/tal/bytes.chiral`
  and the arena. **The bank names the cell and names no write surface**, so the
  refraction this row extends is Shard 6 and the shard has no span facet.
  [[banks/render]] is the sibling and it holds the cell-grid and style side, 24
  shards across 13 homes, none of them a byte write. The `docs/banks/render.md`
  measurement table counts `r-face`, `d-tag` and importers and counts nothing
  under `lib/lowering/`.

### The row's own four counts, each re-measured

| the row says | measured | where |
|---|---|---|
| the pure `Bytes` surface is **twelve** externs | **eleven** | `lib/prelude/prelude.chiral:91-104`. `grep -c '(extern' lib/prelude/prelude.chiral` returns **34** for the whole file, and the file's own header at `:10` says 38 |
| no `pack-u8` | **holds.** No extern of that name exists tree-wide | the eleven above are `str->bytes`, `bytes->str`, `blen`, `bget`, `bslice`, `bcat`, `brepeat`, `pack-u32`, `unpack-u32`, `pack-u16`, `unpack-u16` |
| no builder | **refuted.** `bput-u8` is a surface def and it is live | `lib/lowering/tal/bytes.chiral:610`, called at `lib/protocol/grid.chiral:76-78` and `:105`, `:108`, and at `lib/runtime/poll.chiral:53` |
| no fill-with-function | **holds**, and the name in the tree is a trap. `nb-fill` writes decimal digits backwards for `nb-i64s` and fills nothing | `lib/lowering/tal/bytes.chiral:274-292`, reached from `:316` and `:323` |
| `brepeat` makes a solid span and nothing else | **holds, and it is already the fill half.** One `ti-bnew` of `len * n`, then one copy loop | `nb-brepeat-t` at `lib/lowering/tal/bytes.chiral:179-187` over `nb-rep-go-t` at `:163` |

Every other `Bytes`-typed extern in the tree is a `=>` crossing: `pool-write`
(`lib/ports/pool.port:27`), `sock-send` (`lib/ports/sock.port:67`), `read`
(`lib/ports/fd.port:34`) and eighteen more. **So `kind: port` in
`.planning/DISPLAY-LAYER-GAP.md:196` is wrong and `primitive` in the arc roster
is right:** both target primitives are pure `->` over `Bytes` and cross no
membrane.

### What exists, by rung

| what exists | where | rung | reached by |
|---|---|---|---|
| a solid span in one allocation, linear in output | `brepeat`, `lib/prelude/prelude.chiral:100` | IMPLEMENTED | ten live call sites, six of them in the compiler itself: `lib/lowering/x64/mach.chiral:751`, `lib/lowering/mach/asm-reloc.chiral:47`, `lib/lowering/tal/eval.chiral:65`, `lib/protocol/wire.chiral:26`, `lib/protocol/inet.chiral:46`, `lib/text/matcher.chiral:573`. A break reddens the fixpoint. No phase asserts its semantics; `tools/test/samples/e173_matcher.prog` is the only file under `tools/test/` naming it |
| allocate n bytes, then write byte i | `ti-bnew` and `ti-bput`, `lib/lowering/tal/ir.chiral:26` and `:28` | IMPLEMENTED | hand-written TAL only: `lib/lowering/tal/bytes.chiral`, `lib/lowering/tal/sys.chiral:41`, `lib/lowering/tal/sys-linkage.chiral:44-47`. **No surface extern reaches either.** `ti-bput` is commented "initialization write into a fresh cell" |
| the freshness rule that makes `ti-bput` sound | nothing | DESIGNED | `lib/lowering/tal/check.chiral:13` names byte typed-init, the linear bput-before-read discipline, and `:14` says of it "is scaffold-honest residue (decision #a)". The checker's rule at `:217` types the three operands and asserts nothing about the cell |
| a byte builder | `bput-u8`, `lib/lowering/tal/bytes.chiral:610-626` | IMPLEMENTED | `lib/protocol/grid.chiral`, `lib/runtime/poll.chiral`. **Six allocations per byte written**, priced below |
| the destination surface | `pool-write`, `lib/ports/pool.port:27`, and `pool-read` at `:30` | IMPLEMENTED | both carry a `crossing-wraps` row, `lib/lowering/tal/crossing-wraps.chiral:51-52`, so a read-modify-write of a pool is expressible today |
| the integer arithmetic a composite needs | the `Op` sum, `lib/prelude/prelude.chiral:36-39` | ENFORCED | every compile. ⚑ **The sum is sixteen**, and `docs/decisions/decision-display-numerics.md:24-27` says fifteen and lists fifteen, omitting `op-mulhu`. That doc defect is named here and left to a `doc-audit` run |
| the existing consumer | `prog/demo/sprites.chiral`, 76 lines | SEEDED | **nothing.** 103 roots in the tree carry `(def compile-main` and none reaches anything under `demo/`, transitively closed over `(import "...")`, so Phase 7's sweep at `tools/test/run-tests.sh:176-177` never reaches it |

### The allocation floor, which is arithmetic and not an estimate

The canonical discipline is `alloc-growing` (`lib/memory/alloc-growing.chiral:18`)
and **its reclamation is three empty instruction lists**: its `renter`, `rexit`
and `adrop` fields are each `(the (List Asm) nil)` at `:22-24`. The arena starts at 64 MB and doubles
by `mremap` (`lib/memory/arena.chiral:29` and `:40`). `docs/elements/catalog.md:308-311`
records the consequence at compiler scale: 12 GB churned in one self-compile, with
the arena-exhaustion `ud2` trapping in `nb-bcat` mid-emit, core-verified 2026-08-05.
`docs/benchmarks/text-matcher-prose-lint.md:176` fits `prog/prose-lint.prog` at
1,747 B of arena per input byte over a 46 MB floor. ⚑ That absolute is a lower
bound on a compiler that no longer exists: `docs/benchmarks/text-matcher-allocation.md:12-14`
records that `9f46c6c` cut the matcher's allocation 58% per input byte, and that
the attributions hold where the absolutes do not.

**One `bput-u8` call costs six allocations.** Reading `lib/lowering/tal/bytes.chiral:610-626`:
`bslice cell 0 off` is `off` bytes, `pack-u32 val` is 4, `bslice` of that is 1,
the suffix is `n - off - 1`, the inner `bcat` is `n - off`, the outer `bcat` is
`n`. Total `3n - off + 4`.

| destination span | bytes written | arena consumed, `bput-u8` per byte | cells |
|---|---|---|---|
| a 16-byte `Cell` (`lib/protocol/grid.chiral:43-44`) | 8 | ~356 B plus 48 headers, ~46x the record | 48 |
| a 1920-pixel ARGB8888 scanline | 7,680 | **147,490,560 B** | 46,080 |

`grid.chiral:44` calls its codec "allocation-bounded (one `cell-new 16` + fixed
`bput-*`/`bget-*`)" and that claim is true: the bound is a constant. The constant
is 46x the output, which is invisible at 16 bytes and exhausts the 64 MB arena
partway through the first scanline at 7,680.

**The `bcat`-accumulate route is 20x better and dies at the same place.**
`prog/demo/sprites.chiral:58-63` is right-recursive `bcat` over k pieces of s
bytes, so it costs `s * k * (k+1) / 2`.

| span | k, s | arena consumed |
|---|---|---|
| one 256-byte sprite row | 16, 16 | 2,176 B, 8.5x |
| one 1920-pixel scanline, per pixel | 1920, 4 | 7,376,640 B |
| one 1080-row frame of the same | | 7.97 GB |

**That is the arithmetic behind `docs/arcs/canvas-arc.md:117`'s "Sprites work and
real drawing does not."** The pattern is 8.5x at 16 pieces and 1,920 pieces is
where 8.5x becomes 1,920x.

### The marked inference in `FD-33`, tested against the source

`records/findings.md:518` marks as inference that "with a 1-bit bitmap font the
pattern already in `prog/demo/sprites.chiral:58-63` expresses the second
primitive, since `bcat` of `brepeat` costs one concatenation per RUN per
scanline". **The inference fails twice against the file.**

1. `row-bytes` (`prog/demo/sprites.chiral:58`) does one `bcat` per source
   **character**, at `:62`. Run coalescing appears nowhere in the file, so a 16-character
   row costs 16 concatenations whether it holds one run or sixteen.
2. **The pattern expresses no composite at all.** `draw-rows`
   (`prog/demo/sprites.chiral:66`) calls `pool-write` at `:71` and calls
   `pool-read` nowhere, so nothing in the file reads the destination. `cpx`
   (`:15`) returns `pack-u32 0` from its transparent arm at `:22`, which
   writes fully transparent black over whatever the destination held. The file
   expresses a fill and an opaque rectangular copy.

So the existing precedent covers primitive one and covers none of primitive two.

### The seat hazard the composite inherits

`docs/elements/catalog.md:648` (`E198`, unbuilt) measured **7 of 34** prelude
externs carrying a caller-supplied value into a byte-cell seat, six an index and
`brepeat` an extent, over six routines, and **zero of the seven clamps**. The
shipped instance is `E176` (`docs/elements/ledger.md:315`): `str-sub` is
unclamped, `(str-sub "abc" 0 999995)` exits 139, and `string.chiral:14` claims a
clamp it does not perform. A new extern taking a span length is an eighth seat of
the same kind.

## 3. The delta

**The row's framing is half built and its stated requirement does not exist.**

Subtract §2 from §1:

- *twelve externs* is **eleven**. The count carries no weight either way.
- *no builder* is refuted: `bput-u8` is a builder, it ships, and it is quadratic.
  What is absent is a **linear-allocation** builder.
- *varying content has no linear-time path* names a requirement the reference
  class does not have. `FD-33` read eleven systems at their own sources and found
  no general varying-span write in any of them (`records/findings.md:518`).
  `FD-39` §8 (`records/findings.md:615`) adds that analytic area coverage, the
  one family that is CPU-viable with no GPU, fits the two rectangle primitives
  and needs no third.
- *`brepeat` makes a solid span and nothing else* holds, and **the solid span is
  primitive one.** Fill a rectangle with one colour is `brepeat` of a pixel: one
  allocation, linear in output, shipping, and reached from ten call sites. Half
  the row is built.

**The real delta is one primitive.** Composite a rectangle of coverage against
one colour, over a destination span, in one allocation and one pass. Three parts
are missing and all three are small:

1. **A surface that reaches `ti-bnew` plus `ti-bput`.** The IR pair exists
   (`lib/lowering/tal/ir.chiral:26`, `:28`) and no extern reaches it. This is why
   the row's `origin` of `new` is wrong: the primitive exists one altitude down
   and needs a surface, which `docs/arcs/README.md:74` spells `bind`.
2. **The composite itself**, as one `TIFn` in the byte library. `FD-37`
   (`records/findings.md:561`) priced the arithmetic: source-over with a
   coverage mask ships in 16-bit integers at ±1 LSB, with `premul` and `lerp`
   both integer, using only members of the sixteen-op sum. No new op is owed.
3. **Two operand types**, so a call site distinguishes a mask from a colour
   where today both are a bare `Bytes`. This is what requirement 1 asks of this row.

**Verdict:** a real delta, one primitive wide. The fill half is CLOSED by
`brepeat` and its ten call sites.

### The scope line, stated

`FD-39`'s build list (`records/findings.md:625`) has six items. **This row is the
surface primitive: what writes bytes.** It delivers item **(5)**, the two
rectangle primitives, of which one already ships, and item **(6)**, the
coverage-span emitter, which that finding already says "is a loop over (3) and
not a new primitive" and which therefore needs no element of its own. Items (1)
through (4) never write a pixel and are named as residue in §6:

| `FD-39` item | this row | why |
|---|---|---|
| (1) a fixed-point coordinate type | **residue** | it holds no bytes. [[decisions/decision-display-numerics]] settles fixed point and leaves the denominator open, and `FD-34` (`records/findings.md:527`) measures that three of three rasterizer-internal denominators are 1/256, that FreeType, cairo and Blink each made it a type parameter, and that nothing in the record argues for 1/64 |
| (2) a signed-area cell accumulator | **residue** | one integer per pixel of the active band, read and summed and never written to the surface |
| (3) a row prefix sum | **residue** | produces the coverage bytes this primitive consumes |
| (4) integer curve subdivision | **residue** | `FTGRAYS:1073-1074` midpoint splitting with a shift-derived count, pure arithmetic |
| (5) the two rectangle primitives | **this row.** One ships, one mints | |
| (6) a coverage-span emitter | **this row**, and no element | a loop over (3) by that finding's own words |

A design that absorbed (1) through (4) would take four rows' work. This one does
not.

## 4. The shapes

### Shape A: one extern per primitive, at the span

- **Form:** one new surface extern in `lib/prelude/prelude.chiral` beside
  `brepeat`, taking the destination span, the coverage mask, and the colour, and
  returning a fresh span of the destination's length. One `prim2lib-table` row in
  `lib/lowering/tal/erase.chiral:111-138`. One `TIFn` in
  `lib/lowering/tal/bytes.chiral` of the shape `nb-copy-t` (`:60-76`, 19 lines)
  and `nb-rep-go-t` (`:163-177`, 16 lines) already have: one `ti-bnew` of the
  length, then a recursive body doing four `ti-bget`, the source-over arithmetic
  in `Op` members, and four `ti-bput`. Two one-constructor wrappers so the mask
  and the colour are distinct types. The signature matches the reference class's
  own: `KITTYFONTSH:73` is `alpha_mask, dest, src_rect, dest_rect, src_stride,
  dest_stride, color_rgb` and `FOOTRENDER:1080` is `PIXMAN_OP_OVER, clr_pix,
  glyph->pix, pix`, both quoted in `records/findings.md:518`.
- **Costs:** one allocation of the span length per span, one pass. A 1920-pixel
  scanline is 7,680 bytes and one cell, 19,200x less than `bput-u8` per byte and
  960x less than `bcat` per pixel. A 1080-row frame is 8.3 MB, so the 64 MB arena
  holds 7.7 frames before it grows. Compiler source changes, so the build rule
  applies and a byte-identical fixpoint is owed
  (`docs/definitions/working-discipline.md:15-45`). Appending to `native-lib`
  must go LAST, per the note at `lib/lowering/tal/bytes.chiral:643-644`, because
  the list position is the runtime routine's address.
- **Forbids:** a varying-span write of arbitrary content, which `FD-33` measures
  that no surveyed renderer performs. It forbids compositing in any encoding
  other than the one the wrapper names. It forbids in-place mutation, so a
  caller cannot accumulate into one buffer across spans without one allocation
  per span.
- **Allocation behaviour:** one cell per span, reclaimed by nothing. Bounded per
  call and unbounded across a frame loop, which is `memory-discipline/M2` and
  `E82`.

### Shape B: expose the IR pair, and write both primitives above it

- **Form:** two externs, `bnew : (-> I64 Bytes)` and `bput : (-> Bytes I64 I64
  Bytes)`, straight onto `ti-bnew` and `ti-bput`. Both primitives are then
  ordinary chirality defs in a new `lib/protocol/span.chiral`, and so is anything
  else anyone wants.
- **Costs:** `bput` returning a fresh `Bytes` is `bput-u8` again, six allocations
  per byte and 147 MB per scanline, so the shape only pays if `bput` returns the
  same cell mutated. That is sound only under the freshness rule
  `lib/lowering/tal/check.chiral:13-14` names as omitted residue, so this shape
  owes the checker rule as well as the externs. The rule is the linear
  bput-before-read discipline, which is destination passing, which is `E84`.
- **Forbids:** nothing, and that is the objection. A general mutable byte surface
  is the largest possible surface for the smallest measured requirement, and
  `goals/display.md:43-46` asks for primitives reachable alone. One mechanism
  that reaches everything is the opposite request.
- **Allocation behaviour:** unbounded per span without the checker rule; one cell
  per span with it, matching Shape A at the cost of a checker change.

### Shape C: one fill-with-function

- **Form:** one extern of the shape `(-> I64 (-> I64 I64) Bytes)`: allocate n,
  write `f i` at byte i. Both primitives become partial applications, and item
  (6) of `FD-39`'s list is the same loop.
- **Costs:** one allocation, linear, and one call through the defunctionalized
  dispatcher per byte. The prelude already carries the pattern that makes a
  first-class function value survive `closconv`: `str-eqf` at
  `lib/prelude/prelude.chiral:82`, whose comment at `:80` calls it "a GLOBAL
  wrapper of the str-eq prim, so it can be passed as a first-class" function
  value, and `:81` closes the sentence with "that closconv defunctionalizes". The shape cannot be a `prim2lib` rewrite, because the
  argument is a closure and the rewrite table maps a name to a routine.
- **Forbids:** nothing, again. A fill-with-function *is* the general varying-span
  write the row asked for and `FD-33` measured that nobody needs.
- **Allocation behaviour:** one cell per span, and one dispatcher frame per byte.

### Shape D: the pool as the destination, and no `Bytes` at all

- **Form:** a port extern of the shape `(-> (0 n I64) (=> (1 p (Pool n)) I64
  Bytes I64 (Pool n)))`, compositing a coverage mask against a colour directly
  into the pool at an offset. It allocates nothing whatsoever. It joins the 44
  lowered crossings at `lib/lowering/tal/crossing-wraps.chiral` beside the four
  pool rows at `:50-53`.
- **Costs:** a `crossing-wraps` row, a TAL body under `lib/lowering/tal/sys.chiral`,
  and a place in the frozen port set of every profile that draws. It makes
  `kind: port` correct, which is what `.planning/DISPLAY-LAYER-GAP.md:196` said.
- **Forbids:** compositing into a plain `Bytes`, so a glyph atlas, an offscreen
  layer and a unit test all become unreachable without a live `(Pool n)`. That is
  `goals/display.md:43-46` consequence 3 violated from the other side: the
  primitive would not be reachable without the port lane.
- **Allocation behaviour:** zero, which is the one thing it has over Shape A and
  it is a real advantage.

## 5. The call

- **Chosen:** **Shape A**, one extern for the composite, with `brepeat` standing
  as the fill. Four reasons, in order of weight.
  1. It is the only shape that allocates exactly once per span **and** needs no
     change to `lib/lowering/tal/check.chiral`. Shape B owes the omitted
     freshness rule, which is `E84`'s work.
  2. Both primitives stay pure `->`, so each is reachable from a program with
     neither the other nor the port lane, which is `goals/display.md:43-46`
     consequence 3. Shape D fails that clause.
  3. `FD-33` measured the requirement as exactly two rectangle writes and no
     third. Shapes B and C both deliver a general mechanism for a closed
     requirement, which is the case `design-principles` calls overhead.
  4. The signature is the reference class's own, twice over, at
     `FOOTRENDER:1080` and `KITTYFONTSH:73`.

  Shape D is kept, as the zero-allocation path a frame loop will want, and it is
  named as residue in §6 rather than folded in here.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | What encoding do the composite's operands carry, given that `FD-37` measures premultiply and linearise failing to commute (`records/findings.md:559`) | **RESOLVED** | The element mints two one-constructor wrappers, so a mask cannot be passed where a colour goes and neither can be a bare `Bytes`. That is requirement 1 of [[arcs/display-calculus-arc]] applied to this row's own operands, and it settles nothing about what `R2` (`.planning/DISPLAY-LAYER-GAP.md:195`) decides a colour is: `R2` widens the colour wrapper later without touching this signature. The arithmetic is defined for one encoding state, 8-bit premultiplied and encoded, which `FD-37` records as Wayland's own floor (`records/findings.md:563`, restated at `:572`), and the wrapper is where that state is named |
| 2 | Does the composite evaluate a transfer function or an unpremultiply | **RESOLVED** | No. `FD-37` measured that no surveyed implementation evaluates either in integers at any width (`records/findings.md:561`), and this element does neither. `R2` owns both |
| 3 | The span length is an eighth unclamped byte-cell seat | **DEFERRED** to `enforcement/N20` (`docs/arcs/enforcement-arc.md:512`), the census row, for the general question. **RESOLVED** for this element: the length seat carries a refinement on its own signature, which is the instrument `docs/elements/ledger.md:315` names for exactly this defect, calling `str-sub`'s prose clamp "A safety property asserted in PROSE rather than in a TYPE", and the element's gate asserts the refusal |
| 4 | Does this element need `E84` destination passing | **RESOLVED** | No. Shape A allocates once per span with no `bcat` anywhere, and `E84` is the `nb-bcat`-quadratic kill (`docs/elements/catalog.md:334`). Shapes B and C would need it, and §5 declines both |
| 5 | Does a frame loop need reclamation | **DEFERRED** to `E82` / `memory-discipline/M2` (`docs/arcs/memory-discipline-arc.md:79`) | One allocation per span times 1080 spans is 8.3 MB per frame and the arena reclaims nothing (`lib/memory/alloc-growing.chiral:22-24`), so the arena grows without bound across frames. That is a property of the discipline and not of this primitive, and `M2` is the phase-scoped reset that fixes it |
| 6 | Is a float type needed anywhere in this row | **RESOLVED** | No, and positively. `FD-39` verified analytic coverage shipping in fixed point twice, FreeType `grays` at 1/256 and Skia in `SkFixed` 16.16 across 137 occurrences, and states that every operation in items (1) to (6) is a member of the sixteen-op sum (`records/findings.md:625`). [[decisions/decision-display-numerics]] settles fixed point by author directive |
| 7 | Does the change owe a byte-identical fixpoint | **RESOLVED** | Yes. The extern is in `lib/prelude/prelude.chiral` and the `TIFn` is in `native-lib`, both compiler source, so `docs/definitions/working-discipline.md:15-45` applies. The change touches emission, so the first agreement is expected at `C2 == C3` and not at `C1 == C2` |
| 8 | Who is the consumer, given that a primitive may not mint alone | **RESOLVED** | [[decisions/decision-primitive-with-consumer]] rejects "a primitive minted alone, with no named consumer". The consumer is a root under `prog/samples/` on the `e109_bput_u16_le.prog` precedent (45 lines, carries `compile-main`, swept by Phase 7), compositing a coverage mask against a colour into a `(Pool n)` and asserting the resulting bytes. ⚑ Its honest limit is the precedent's: Phase 7 compiles that file and no phase runs it, so the element owes a phase of its own |

**No NEEDS-AUTHOR is surfaced.** Every fork above is closed by a settled document
or a pinned finding, and `status` stays `draft`.

## 6. The mint packet

- **Elements:** **one.** The fill half needs none, because `brepeat` ships and is
  reached from ten call sites, which is also the answer to the split question:
  a fill is usable with no composite today. The composite's four parts constrain
  each other and cannot be committed apart. The extern's declaration is what
  `erase-prim` dispatches on (`lib/lowering/tal/erase.chiral:153-154`), the
  `prim2lib-table` row is what names the routine, the `TIFn` is the routine, and
  the two wrappers are the operand types the extern's signature mentions. Four
  files, one commit, one fixpoint. The `origin` is `pair`, per
  [[decisions/decision-primitive-with-consumer]], with the primitive half a
  `bind` of `ti-bnew` plus `ti-bput`.
- **Band:** `UNASSIGNED`. `docs/arcs/display-calculus-arc.md` states its reserved
  element block as **none**, and `docs/decisions/decision-lane-split.md:60-62`
  rules that an arc with no band mints the next free number tree-wide and records
  the range it landed in.
- **Catalog row**, for a new section following XIX, in the file's own five-column
  form:

```
| E<NN> | **The coverage composite: one span write, one allocation.** Composite a rectangle of coverage against one colour over a destination span, in one `ti-bnew` and one pass, with the mask and the colour as distinct one-constructor types. The fill half is `brepeat` and needs nothing. `FD-33` measured eleven systems and found these two writes and no third; `FD-37` priced the arithmetic at ±1 LSB inside the sixteen-op sum. Today the only builder is `bput-u8` (`lib/lowering/tal/bytes.chiral:610`) at six allocations per byte, which is 147 MB for one 1920-pixel scanline against a 64 MB arena that reclaims nothing | Not built. New extern in `lib/prelude/prelude.chiral`, one `prim2lib-table` row, one `TIFn` appended LAST to `native-lib`, one sample root, one phase | `pixman` `PIXMAN_OP_OVER` with a mask (`FOOTRENDER:1080`), kitty's CPU `alpha_mask`/`color_rgb` signature (`KITTYFONTSH:73`) (`OURS`/`IMPL`) | SH |
```

- **Ledger row**, into the `MEM · Memory & substrate floor` section
  (`docs/elements/ledger.md:158`), whose form there is six columns:

```
| E<NN> | bytes | design | The coverage composite: one span write, one allocation | ←E25, →E82 | SH |
```

- **Size:** five files, ~120 lines added and ~2 changed.

  | file | change | lines | basis |
  |---|---|---|---|
  | `lib/prelude/prelude.chiral` | one extern beside `brepeat` at `:100`, two one-constructor data decls | ~8 | the decls follow `PoolReadR` (`lib/ports/pool.port:19`), one line each |
  | `lib/lowering/tal/erase.chiral` | one `prim2lib-table` row | 1 | the table at `:111-138` is one `cons` pair per name |
  | `lib/lowering/tal/bytes.chiral` | one `TIFn`, plus one `native-lib` entry appended LAST | ~40 | `nb-copy-t` is 19 lines (`:60-76`) and `nb-rep-go-t` is 16 (`:163-177`); this body adds four `ti-bget`, the source-over arithmetic and four `ti-bput` |
  | `prog/samples/` | one new root, the consumer | ~50 | `prog/samples/e109_bput_u16_le.prog` is 45 lines for one byte primitive |
  | `tools/test/` | one phase asserting the composited bytes and the length refusal | ~25 | the phase-script floor, and ⚑ its number is behind the standing suite-number call in `records/author-calls.md` |

  Plus the build rule: `build-new → test → promote` with generations until two
  agree, expected at `C2 == C3` because the change reaches emission
  (`docs/definitions/working-discipline.md:36-40`).

- **Residue, named and not absorbed.** Twelve items, of which six are rows this
  run owes and could not open:

  | residue | owner | state |
  |---|---|---|
  | the fixed-point coordinate type, `FD-39` item (1) | a new row in [[arcs/display-calculus-arc]]'s R lane. ⚑ **Owed and not opened here**, because this run may not edit the arc file. [[decisions/decision-display-numerics]] settles the kind and `FD-34` (`records/findings.md:527`) supplies the denominator evidence | unrostered |
  | the signed-area cell accumulator, item (2) | the same lane, the same row or its sibling | unrostered |
  | the row prefix sum, item (3) | the same | unrostered |
  | integer curve subdivision, item (4) | the same | unrostered |
  | the zero-allocation pool composite, Shape D | a port-lane row against [[arcs/native-window-arc]] | unrostered |
  | `R2`, the encoding as a type | `.planning/DISPLAY-LAYER-GAP.md:195`, rostered by **no** arc. `FD-37` already hands it four corrections | unrostered |
  | reclamation across a frame loop | `E82`, `memory-discipline/M2`, minted, `design` | scheduled |
  | the `nb-bcat` quadratic, for any caller that keeps using `bcat` | `E84`, `memory-discipline/M4`, minted, `design` | scheduled |
  | the unclamped byte-cell seats, 7 of 34 with zero clamping | `E198` and `enforcement/N20` | one minted, one rostered |
  | the `Op` sum written as fifteen at `docs/decisions/decision-display-numerics.md:24-27` | a `doc-audit` run on that decision | unscheduled |
  | `.planning/DISPLAY-LAYER-GAP.md:196` giving `R3` `kind: port` against the roster's `primitive` | the same gap file, on its next pass | unscheduled |
  | the prelude header at `lib/prelude/prelude.chiral:10` saying 38 externs against 34 | `E198`, whose own title already says 34 | minted |

  ⚑ **Six rows are owed and this run opened none of them**, because the stage may
  not edit `docs/arcs/display-calculus-arc.md` beyond the roster flip. The mint
  step or an `arc-open` amendment owes those six rows before any of them is cited
  by a SPEC.

- **What this element does not reach.** Its output has no path to a screen until
  `E199` lands: `docs/arcs/canvas-arc.md:114` measures `sock-send-fd` absent from
  the 44 lowered crossings, so `prog/demo/wl-client.chiral:201` does not lower.
  That is the arc's first blocker and this row is the second.
- **Related:** [[arcs/display-calculus-arc]], [[goals/display]],
  [[arcs/canvas-arc]], [[goals/own-web]], [[banks/memory]], [[banks/render]],
  [[decisions/decision-display-numerics]],
  [[decisions/decision-primitive-with-consumer]], [[decisions/decision-lane-split]],
  [[arcs/memory-discipline-arc]], [[arcs/enforcement-arc]],
  [[working-discipline]], `records/findings.md` `FD-33`, `FD-34`, `FD-37`,
  `FD-39`.
