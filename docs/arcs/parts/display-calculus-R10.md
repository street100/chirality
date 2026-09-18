---
row: display-calculus/R10
arc: display-calculus
title: the fixed-point coordinate type, denominator a type parameter. The tree already carries the mechanism, measured here on this compiler: a value-indexed `data` whose index occurs in no field compiles, lowers and runs, two instantiations at 1/64 and 1/256 are refused as a type mismatch, and a consumer that writes the index as a literal in its signature fails to lower
kind: primitive
origin: pair
req: 1, 6
status: draft
updated: 2026-09-18
---

# display-calculus/R10: the fixed-point coordinate type

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** a coordinate must be a value whose denominator is part of its
  type, so a coordinate at 1/64 and a coordinate at 1/256 have no sum and the
  checker refuses the program that adds them. The denominator is a parameter of
  the type and not a number this row picks, which is `FD-39` build-list item (1)
  verbatim: *"a fixed-point coordinate type, 24.8 following cairo or 26.6
  following FreeType's input, with the subpixel denominator a type parameter per
  `FD-34`"* (`records/findings.md:625`).
- **Serves:** requirement 1 of [[arcs/display-calculus-arc]]
  (`docs/arcs/display-calculus-arc.md:131-138`), whose widening on 2026-09-18
  put this row inside it: *"A coordinate carries the denominator it is measured
  in, so two instantiations at 1/64 and 1/256 have no sum."* Also requirement 6
  (`:173`), both halves: the piece compiles alone, and a grep for a float type
  over it returns zero.
- **Goal:** [[goals/display]], condition 1 (`docs/goals/display.md:52`), which
  is the condition this arc holds. Condition 3, Geometry (`:61-64`), is
  unopened and names [[decisions/decision-display-numerics]] as what it sits
  behind; this row is the first object that ruling implies.

## 2. What the tree holds

Measured 2026-09-18 against the working tree, with `bin/chirality-bin`
(1,257,848 bytes) for the six numbered probes: 1 through 5 below, and 6 in §3.
⚑ **All six were re-run from source by the DESIGN audit 2026-09-18 against the
same binary and each reproduced**, with the one correction carried into probe 3's
program cell.

- **Bank:** [[banks/render]], which refracts the renderer, the style engine, the
  display list and the terminal emulator into twenty-four shards across thirteen
  homes. **The bank carries no coordinate shard.** Its translation table answers
  *"a float for layout"* with the refusal and names no fixed-point carrier
  (`docs/banks/render.md:291`). Its residue section lists seven items
  (`:299-324`) and none of them is a coordinate, and `:329` states that those
  seven *"are the whole of what the display tier owes"*. The bank reads
  `updated: 2026-09-04` (`:7`), which predates `E200`, `FD-39` and the six
  raster rows this roster opened on 2026-09-18, so that sentence is stale rather
  than wrong about a coordinate. Nothing in the bank covers this row.

### The ruling this row sits under

| what it rules | where | what it leaves |
|---|---|---|
| fixed point, with the scale in the type; a mixed-scale arithmetic is a type error | `docs/decisions/decision-display-numerics.md:9`, `:47-49` | settled 2026-09-04 by author directive (`:11`) |
| the float alternative, refused on the record, with the seven places `F64` would touch | `:17-23`, `:38-43` | closed |
| the scale itself | `:70-76`: *"The scale is a per-lane choice and this ruling does not fix one number."* | **open, and this row does not close it either**: a type parameter defers the number to the instantiation site |

⚑ **One count defect in that document, re-measured here.** `:27-28` says *"The
`Op` sum is closed at fifteen integer ops"* and lists fifteen, omitting
`op-mulhu`. `lib/prelude/prelude.chiral:36-39` carries **sixteen**: add, sub,
mul, div, mod, eqi, lti, lei, mulhi, mulhu, sar, shr, band, bor, bxor, shl.
`FD-34` item 10 (`records/findings.md:527`) already recorded the same defect
against `.planning/DISPLAY-LAYER-GAP.md:86-87`. The pricing argument is
unaffected and the number is wrong in both places.

### The arithmetic

| what exists | where | rung | reached by |
|---|---|---|---|
| the sixteen integer ops, closed | `lib/prelude/prelude.chiral:36-39` | ENFORCED | every emitted binary op; the sum's header states why it is closed (`:31-35`) |
| the surface names of the arithmetic externs | `lib/prelude/prelude.chiral:59-74` | ENFORCED | `+ - * / % =i <i <=i band bor bxor shl shr sar mulhi mulhu` |
| division is Euclidean, so it floors for a positive divisor | `lib/lowering/x64/mach.chiral:161-163`: *"idiv alone truncates toward zero; chirality division is EUCLIDEAN (0 <= r < \|b\|)"*, with the branchless correction at `:301` | ENFORCED | **Probe 1**, this compiler: `(/ -32 64)` exits 99 against a `+ 100` base, so the quotient is `-1`; `(sar -32 6)` exits 99 too. `(/ -96 64)` exits 98, so the quotient is `-2`. Division and arithmetic shift agree on negatives at a positive power-of-two divisor, which C's `/` does not do |
| the widening multiply, both names | externs at `lib/prelude/prelude.chiral:73-74`, parsed at `lib/lowering/tal/erase.chiral:100-101`, emitted at `lib/lowering/x64/mach.chiral:377` and `:379` | built, E189 (`docs/elements/ledger.md:331`) | `prog/e189-widening-multiply.prog`, twelve call sites, gated by Phase 32 (`tools/test/run-tests.sh:368`) |
| a float type | nowhere | absent | a grep over `lib/` and `prog/` for `subpixel`, `denominator` and `fractional` returns one hit, `lib/protocol/json.chiral:358`, which records that numbers with a fractional part have no `I64` form |

### The type-level integer index, which is the mechanism this row needs

| what exists | where | rung | reached by |
|---|---|---|---|
| a `data` parameterised by a value of type `I64` | eight declarations: `lib/protocol/grid.chiral:28`, `lib/memory/mem-region.chiral:23`, `:31`, `:54`, `:65`, `lib/ports/pool.port:15`, `:19`, `lib/protocol/vt-parser.chiral:47` | built | E111 (`docs/elements/ledger.md:179`), E120, E122 |
| the same as a `porttype` | `lib/ports/pool.port:13`, with `:4` stating the property: *"(Pool 16384) and (Pool 4096) are different types"* | built | four demo roots, `prog/demo/tomodachi.chiral:19` and three others |
| the erased binder that carries the index into a signature | `(0 n I64)`, 47 occurrences over ten files; `lib/memory/mem-region.chiral:27`, `lib/protocol/grid.chiral:130-139` | built | every consumer of a value-indexed type in the tree |
| the same binder at quantity `w` where the producer needs the value at runtime | `lib/protocol/grid.chiral:131`, `(w n I64)`; `w` parses to quantity 2 at `lib/surface/parse.chiral:55` | built | `grid-new`, which passes `n` to `pool-create` (`:157`) |
| what makes two instantiations different types | `lib/typing/kernel.chiral:729-730`: `conv` on `v-tcon` requires the same data name **and** `conv-spine` over the type arguments | built | every conversion check |
| where the index comes from at a construction | `lib/typing/kernel.chiral:1072-1090`. With an expected type, `con-check` takes the arguments off it. With none, `solve-con-params` (`:1114-1118`) solves each parameter only from a field that is a bare occurrence, and returns `jg-ctor-infer-params` when one is unsolved | built | every constructor application |
| whether a parameter must occur in a field | `lib/module/loader.chiral:502-512`. `check-dparams` requires each parameter to be a type and checks nothing else; `check-dfields` (`:513-529`) checks positivity and linearity and no occurrence | built | the data driver, `load-data` at `:547` |
| the fixture that gates the size index | `tools/test/samples/e170_reject_pool_size.prog`, a minimal pair against `pe-pool-16` in `e170_port_twin.prog:70` | **SEEDED** | nothing. `tools/test/run-tests.sh:179` skips every `*_reject_*` root, and `:423` lists Phase 12's script and its mutant machinery among what was never ported from the old suite. The file exists and no phase runs it |

### Four probes, run here, because the mechanism had never been asked this question

Each is a whole program compiled from the resolved blob with `bin/chirality-bin`
and run, exit code reported.

| probe | program | result |
|---|---|---|
| **2. a phantom index compiles, lowers and runs** | `(data Fix ((d I64)) (fix (v I64)))` with `mk : (-> (0 d I64) I64 (Fix d))` and `unfix : (-> (0 d I64) (Fix d) I64)`, `compile-main` returning `(unfix 64 (mk 64 42))` | compile exit 0, **run exit 42** |
| **3. two instantiations are refused, and the twin is accepted** | the same declarations with `use : (-> (0 d I64) (Fix d) I64)`, the consumer's index arriving through the erased binder. The accepting form is `(use 256 (mk 256 42))`; the mismatched one changes the single literal `256` to `64` at the construction | the accepting form runs, **exit 42**. The mismatched form fails at load with **`load: type mismatch`**. One integer inside a type is the whole difference. ⚑ Spelling the consumer `(-> (Fix 256) I64)` instead type-checks and then fails to lower, which is probe 5, so the consumer writes the binder here too |
| **4. a construction with no expected type is refused** | `(case (fix 42) ((fix v) v))` with no annotation and no declared return type | **`load: cannot infer type parameters of fix`**, which is `jg-ctor-infer-params` reaching the surface |
| **5. a value-indexed type at a concrete literal index does not lower** | `(def useV (-> (Vec 16) I64) …)` over `(data Vec ((n I64)) (vec (len I64) (bs Bytes)))`, against the identical body declared `(-> (0 n I64) (Vec n) I64)` | the literal form fails with **`extern does not lower: call target not lowered: useV`**; the erased-binder form exits 42. The same pair over a `(type 0)` parameter, `(-> (Box I64) I64)`, lowers and runs, so the defect is specific to a **value** index written as a literal in a `->` signature |

Probe 5 is a general property of the tree that no record names. It is consistent
with every existing consumer: `lib/protocol/grid.chiral:130-139` and
`lib/memory/mem-region.chiral:27-75` write `(0 n I64)` at every seat and never a
literal, so the shape the tree already uses is the shape that lowers.

### The refinement route, and what it cannot carry

| what exists | where | what it gives |
|---|---|---|
| the refinement vocabulary | `lib/typing/refine.chiral:11`, five `SymOp`s, `>= > <= < <>`, over a constant or an operand level (`:13-18`) | a bound on a value's magnitude |
| a refinement naming a data's own index | `lib/memory/mem-linear.chiral:27`, `(refine I64 (>= 0) (< n))` | an inter-variable bound does compose with `((n I64))` |
| the only refinement-typed extern argument | `lib/ports/sock.port:69`, `(refine I64 (> 0))` | one seat, tree-wide |
| a refinement's runtime fate | `lib/lowering/compile-front.chiral:69`: *"a refinement is proof-irrelevant / erased at runtime"*, lowered as its base | nothing survives to a consumer |
| what the vocabulary already failed to spell | `lib/prelude/prelude.chiral:122-127`, `E200`'s own comment: `blen dst == 4 * blen cover` has no spelling in the five `SymOp`s, so the extent lives in the routine and gate row G4 asserts it | the adjacent wall, measured |

None of the five operators expresses a unit. A refinement says how large an
integer is and says nothing about what it counts.

### What is already built beside this row

| what exists | where | rung | reached by |
|---|---|---|---|
| the coverage composite and its two one-field wrappers | `lib/prelude/prelude.chiral:128-130`, `Cover` and `Pix` over `Bytes`, with `bover` | built, E200 (`docs/elements/ledger.md:184`) | Phase 33 (`tools/test/run-tests.sh:378`), `prog/samples/e200-coverage-composite.prog`, 137 lines |
| the typed cell vocabulary | `lib/protocol/grid.chiral:6`, `:12`, `:18`, `Color`, `Attrs`, `Cell` carrying `(width I64)` | built, E111 | `lib/protocol/vt-parser.chiral` and four fixture roots |
| the only coordinate arithmetic in the tree | `prog/demo/sprites.chiral:66-71`, `(* y 1024)` as a whole-pixel row stride into a `(Pool n)` | runs | three demo roots |
| a fixed-point coordinate | nowhere | **absent** | a grep over `lib/` and `prog/` for `fixed point`, `26.6`, `24.8` and `frac-bits` returns one hit, `prog/unit/encoding.chiral:15`, a comment about Loihi 2 |

## 3. The delta

Subtract §2. The ruling exists and is settled. The sixteen ops exist and cover
every operation the reference class uses. The type-level integer index exists,
is declared eight times, distinguishes instantiations at `lib/typing/kernel.chiral:729-730`,
and is proved on this compiler by probes 2 and 3. The erased binder exists and
is the tree's own convention at 47 seats.

What is missing is four things and all four are small.

1. **No type in this tree carries a denominator.** Every coordinate is a bare
   `I64` and its scale lives in a reader's head. The grep returns one hit and it
   is about a neuromorphic chip.
2. **No rounding rule is written anywhere.** `FD-34` measured that the naive
   power-of-two form `(x + 32) & -64` is asymmetric at ties and that FreeType
   ships a corrected macro adding `- (x < 0)` (`records/findings.md:527`,
   `FTCALC:468`), and that Pango publishes the defect the naive form leaves,
   *"PANGO_PIXELS also behaves differently for +512 and -512"*. **Probe 6**,
   this compiler: at `d = 64` the naive form sends `-32`, which is one half of a
   pixel below zero, to `0`, while it sends `+32` to `+1`; the corrected form
   sends them to `-1` and `+1`. A rule chosen by accident inherits the published
   defect.
3. **A parameter occurring in no field has no precedent here.** All eight
   value-indexed declarations use their index in a field. Probe 2 shows the
   kernel and the lowering accept one anyway, and probe 4 shows what it costs:
   the construction must sit where an expected type reaches it.
4. **No consumer exercises any of it**, which
   [[decisions/decision-primitive-with-consumer]] `:100` names as the thing that
   makes a minted primitive a phantom in the other direction.

**Verdict: a real delta.** One data declaration, one arithmetic module over
externs that already ship, a stated rounding rule, and one consumer root. The
element adds no extern, no `TIFn` and no compiler source.

## 4. The shapes

The fork is where the denominator lives. Five forms were put to the tree and two
of them are refused by measurement rather than by argument.

### Shape A: a phantom type-level index carrying the denominator

- **Form:** `(data Fix ((d I64)) (fix (v I64)))`. `d` occurs in no field. Every
  operation takes it as an erased binder: `(-> (0 d I64) (Fix d) (Fix d) (Fix d))`.
  `v` is the numerator, counting units of `1/d`.
- **Costs:** a construction must sit in checking position, because probe 4 shows
  inference refusing it with `load: cannot infer type parameters of fix`. Every
  consumer must take `(0 d I64)` rather than writing the literal, because probe
  5 shows the literal form failing to lower. Both costs are already the tree's
  convention at 47 seats.
- **Forbids:** adding a 1/64 coordinate to a 1/256 one, which is requirement 1.
  Probe 3 measured the refusal as `load: type mismatch` on a one-literal
  difference.
- **Buys:** one arithmetic for every scale. `FD-34` records this as the shape
  three independent projects converged on, `FT_PAD_FLOOR( x, n )`,
  `CAIRO_FIXED_FRAC_BITS` and `FixedPoint<fractional_bits, Storage>`
  (`records/findings.md:527`), and names it *"a defensible shape the pins do
  support"*.

### Shape B: one nullary type per denominator

- **Form:** `(data Fix64 () (fix64 (v I64)))` beside `(data Fix256 () (fix256 (v I64)))`.
  This is `E200`'s precedent exactly: `Cover` and `Pix` are one-field wrappers
  over `Bytes` whose whole content is nominal identity
  (`lib/prelude/prelude.chiral:128-129`).
- **Costs:** the arithmetic is written once per denominator, and a conversion is
  written once per ordered pair. Two scales is twenty functions where Shape A
  has ten. The tree has no way to abstract over the set, so the cost grows with
  every scale a lane adds, and `FD-34` measured Blink shipping three units in
  one engine (`records/findings.md:527`, `BLINKLU:473-475`).
- **Forbids:** the mix, by nominal identity, with no phantom parameter and no
  new mechanism.
- **Buys:** nothing unmeasured. Every part of it is a shape the tree ships.

### Shape C: the denominator as a runtime field

- **Form:** `(data Fix () (fix (den I64) (v I64)))`.
- **Costs:** the checker sees one type. Two coordinates at different scales add
  with no complaint and the routine branches on `den` at runtime.
- **Refused.** It fails requirement 1 at
  `docs/arcs/display-calculus-arc.md:131-132` outright: the invalid state is
  representable, and the invariant moves from the type into a runtime check the
  requirement exists to remove.

### Shape D: the denominator as a refinement on the value seat

- **Form:** `(refine I64 …)` on the numerator.
- **Refused by measurement.** `lib/typing/refine.chiral:11` admits five
  operators, `>= > <= < <>`, and every one of them bounds a magnitude. No atom
  says an integer counts units of `1/d`. `lib/lowering/compile-front.chiral:69`
  erases a refinement to its base, so nothing would reach a consumer even if the
  vocabulary could spell it. `E200` hit the neighbouring wall with
  `blen dst == 4 * blen cover` and recorded it in place
  (`lib/prelude/prelude.chiral:122-127`).

### Shape E: the exponent as the index, so `d = 2^k`

- **Form:** `(data Fix ((k I64)) (fix (v I64)))`, the index being the shift
  count.
- **Costs:** it forbids every non-power-of-two denominator. `FD-34` measured
  Gecko's 1/60 as the one denominator in the survey with a published reason, and
  that reason argues **against** a power of two: an author-specified decimal
  length is exactly representable, and so is a device-pixel ratio of 3, 5 or 6,
  neither of which 64 gives (`records/findings.md:527`, `MOZUNITS:102-106`).
  Gecko still ships 60 (`GECKOAPPU:13`). A type that cannot spell 60 forecloses
  a lane the record defends.
- **Buys:** every conversion between scales is a shift by a difference of
  indices, and the full-range multiply of §5 question 6 is reachable with
  `mulhi` and two shifts.

## 5. The call

- **Chosen: Shape A**, a phantom type-level index carrying the denominator
  itself. Three reasons, in order of weight. The mechanism is measured working
  on this compiler at probes 2, 3 and 4 rather than argued. It is the shape
  `FD-34` says the pins support and that three projects reached independently.
  It keeps the number out of the type constructor, which is what
  `decision-display-numerics:70-76` leaves open and what this row is therefore
  not entitled to close.

  Shape B stays as the fallback and it is a real one: if the SPEC finds a
  phantom parameter failing somewhere probe 2 did not reach, Shape B needs no
  mechanism the tree lacks and costs a function per scale. Shape E is declined
  because it forbids the one denominator the record defends, and powers of two
  remain expressible under Shape A as `d = 64`.

- **The operations the element ships.** Ten, all pure `->`, all over
  `lib/prelude/prelude.chiral:59-74`:
  `fix-of-int`, `fix-floor`, `fix-round`, `fix-add`, `fix-sub`, `fix-neg`,
  `fix-lt`, `fix-eq`, `fix-scale` (a `Fix d` times a plain `I64`) and
  `fix-rescale` (`d1` to `d2`, taking both indices at `w` because it needs their
  values). Nothing here is the accumulator and nothing here is the subdivision.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Does [[decisions/decision-display-numerics]] already settle this row | **RESOLVED**, and it narrows it | The ruling settles the kind, fixed point with the scale in the type (`:9`, `:47-49`), and refuses the float alternative on the record (`:17-23`). It explicitly leaves the number open: *"The scale is a per-lane choice and this ruling does not fix one number"* (`:72-73`). So this row designs a type constructor and picks no denominator, which is exactly what the ruling leaves. The row is narrower than the roster's `what` cell reads and it does not close |
| 2 | Can the type carry the denominator at all | **RESOLVED by measurement** | Yes, as an erased type-level `I64` index occurring in no field. Probe 2 compiled, lowered and ran it (exit 42). Probe 3 measured the refusal of a mixed pair as `load: type mismatch` on a one-literal difference. `lib/typing/kernel.chiral:729-730` is the rule that makes the two instantiations different, and `lib/module/loader.chiral:502-529` is the driver that never asks a parameter to occur in a field |
| 3 | Which denominator | **RESOLVED**: none, by the shape | The parameter defers it to each instantiation site, which is what the roster row asks for and what `FD-34` calls the shape the pins support (`records/findings.md:527`). `FD-34` also measures that no surveyed source gives a reason for 64 over 256 or 16, so a number picked here would rest on nothing |
| 4 | The denominator or the exponent as the index | **RESOLVED**: the denominator, Shape A over Shape E | Gecko's 1/60 is the one denominator with a published reason and the reason argues against a power of two; it still ships (`records/findings.md:527`). A power-of-two index is expressible under Shape A and the reverse does not hold |
| 5 | What the rounding rule is at ties and at negatives | **RESOLVED**: `fix-round` rounds ties away from zero, `fix-floor` floors toward minus infinity | `fix-floor v = (/ v d)`, which is one op, because `lib/lowering/x64/mach.chiral:163` makes division Euclidean, so it floors for a positive divisor. Probe 1 measured `(/ -96 64)` as `-2` and `(/ -32 64)` as `-1`, agreeing with `(sar -32 6)`. `fix-round v = (/ (+ v (- (/ d 2) (b2i (<i v 0)))) d)`, which is FreeType's corrected macro `((x) + 32 - (x < 0)) & -64` (`FTCALC:468`, `records/findings.md:527`) written for a general `d`. Probe 6 measured the naive form sending `-32` to `0` and `+32` to `+1` at `d = 64`, and the corrected form sending them to `-1` and `+1`. Pango publishes the naive form's asymmetry as a defect, so adopting it knowingly is the failure this question exists to prevent |
| 6 | What a multiply of two `Fix d` compiles to, and where it stops | **RESOLVED for the shipped form, with a discovered requirement recorded beside it** | The exact answer is `a*b/d`. At `d = 2^k` it is `(bor (shl (mulhi a b) (- 64 k)) (shr (* a b) k))`, five of the sixteen ops, `mulhi` `*` `shl` `shr` `bor`, six counting the `-` on the shift amount, with `mulhi` built and gated at Phase 32. At a general `d` the 128-bit product needs a 128-by-64 divide and `lib/prelude/prelude.chiral:36-39` contains none, so the element ships the single-word form `(/ (* a b) d)`, exact whenever `\|a\|·\|b\| < 2^63` and stated as such. **Discovered requirement, per `docs/definitions/working-discipline.md:112-124`**: a full-range fixed-point multiply at a non-power-of-two denominator is the first workload to ask this substrate for a 128-by-64 divide, and the citation proving the absence is the sixteen-constructor sum. The element is buildable without it, and `docs/definitions/working-discipline.md:120-124` rules the word `blocked` wrong for a requirement of this kind |
| 7 | Does a value-indexed type at a concrete literal index lower | **RESOLVED**: no, measured, and the shape routes around it | Probe 5: `(-> (Vec 16) I64)` fails with `extern does not lower: call target not lowered`, while the identical body at `(-> (0 n I64) (Vec n) I64)` runs. The same pair over a `(type 0)` parameter lowers, so the defect is specific to a value index written as a literal in a `->` signature. Every existing consumer in the tree already writes the erased binder (`lib/protocol/grid.chiral:130-139`, `lib/memory/mem-region.chiral:27-75`), which is why this has never been hit. **A second discovered requirement**, recorded with its minimal pair and routed to residue in §6 |
| 8 | The word size, and where the scale runs out | **RESOLVED** | The integer is `I64`, so at denominator `d` the range is ±(2^63−1)/d whole units: ±1.44e17 at 1/64, ±3.60e16 at 1/256, ±1.41e14 at 1/65536. `FD-34`'s four measured run-out cases are all 32-bit: Blink's 1/65536 at ±32,767 px forced a widening to `int64_t`, cairo is ±8,388,607 px and says its 32 cannot move, Skia drops antialiasing above 8,191 device pixels (`records/findings.md:527`). None reproduces at `I64`. The element states the formula in the module header rather than a number, because `decision-numeric-width-pluggable` makes the width a moduleset axis (`docs/decisions/decision-display-numerics.md:74-76`) |
| 9 | Who is the consumer | **RESOLVED** | [[decisions/decision-primitive-with-consumer]] `:100` rejects a primitive minted alone and `:84` gives `origin` the value `pair`. The consumer is a root under `prog/samples/` that places a sprite row at a fractional y, rounds it to a device row through `fix-round`, and draws through `brepeat` (`lib/prelude/prelude.chiral:100`) and `bover` (`lib/prelude/prelude.chiral:130`), both built. It needs no accumulator and no subdivision, so `docs/goals/display.md:43-45` consequence 3 holds: the primitive is reachable without the rest of its lane. The precedent for the root is `prog/samples/e200-coverage-composite.prog`, 137 lines |
| 10 | Does the change owe a byte-identical fixpoint | **RESOLVED**: no | The element adds one new module under `lib/prelude/` and one root under `prog/samples/`, and no compiler module imports either. `docs/definitions/working-discipline.md:23` scopes the generation loop to *"When the compiler's own sources changed"*. The element declares no extern, writes no `prim2lib-table` row and adds no `TIFn`, which is what distinguishes it from `E200`. The check is a grep for importers of the new module, and the SPEC's gate carries it |
| 11 | Does this row absorb `R11` or `R13` | **RESOLVED**: no | The ten functions are the coordinate's own arithmetic. `R11` is the per-pixel signed-area accumulator and `R13` is midpoint subdivision; both consume this type and neither is here. A design that built either would fail the same clause `E200`'s design used to refuse Shape D (`docs/arcs/parts/display-calculus-R3.md:296-322`) |

⚑ **One NEEDS-AUTHOR, raised by the DESIGN audit 2026-09-18 and unanswered.**
Question 6 says *"the element ships the single-word form `(/ (* a b) d)`"*, and
the ten operations listed above carry no `Fix d` times `Fix d`: `fix-scale` is a
`Fix d` times a plain `I64` and reaches for no divide at all. **Does the element
ship an eleventh operation, a `Fix d` times `Fix d` at `(/ (* a b) d)` with its
`|a|·|b| < 2^63` exactness bound stated in the header, or does it ship no such
multiply, question 6 recording the form it would take when one is wanted?** §6's
size basis moves by a few lines either way, so this is a scope call. The audit
does not take it.

**Otherwise no NEEDS-AUTHOR is surfaced.** Questions 1 through 11 are each
closed by a settled document, a pinned finding, or a probe run here and reported
with its exit code. The two discovered requirements in questions 6 and 7 are recorded
with the citations proving the absence and neither is called a blocker, per
`docs/definitions/working-discipline.md:120-124`. `status` stays `draft`.

## 6. The mint packet

- **Elements: one.** The type and its ten operations constrain each other: the
  operations are what make the erased binder load-bearing, and the type with no
  operation is a wrapper nobody can add. The consumer root is the other half of
  a `pair` and cannot compile without the module, which is
  [[decisions/decision-primitive-with-consumer]] `:89-90`, *"a `pair` row mints
  as one element where the halves are unbuildable apart"*. The roster's `what`
  cell names no consumer, so the mint owes it the consumer half along with the
  `origin` flip from `new` to `pair`.
- **Band:** `UNASSIGNED`. `docs/arcs/display-calculus-arc.md:12` states the arc's
  reserved element block as **none**, and
  `docs/decisions/decision-lane-split.md:60-62` rules that such an arc *"takes
  the next free number and records the range it landed in"*. The next free
  number is **one past E200**, which is the highest in both registries
  (`docs/elements/catalog.md:336`, `docs/elements/ledger.md:184`). The mint
  allocates it; this packet does not spell it, because naming a number no row
  carries is the deferral rule's own defect (`docs/definitions/working-discipline.md:78`).
- **Catalog row**, for a new section **XX** appended at the file tail after the
  `## OWED` block (`docs/elements/catalog.md:600`, file ends at 649). E200
  landed inside section XIII, the value-heap discipline seam (`:303`), and a
  pure numeric type does not belong under that heading. The file's five-column
  form (`:329-330`):

```
| E<NN> | **The fixed-point coordinate: the denominator rides the type.** `(data Fix ((d I64)) (fix (v I64)))` with the denominator an erased type-level index, so a coordinate at 1/64 and one at 1/256 have no sum and the checker refuses the program that adds them. Ten pure operations over the existing sixteen-op floor: `fix-of-int`, `fix-floor`, `fix-round`, `fix-add`, `fix-sub`, `fix-neg`, `fix-lt`, `fix-eq`, `fix-scale`, `fix-rescale`. `fix-floor` is one `/` because chirality division is Euclidean (`lib/lowering/x64/mach.chiral:163`); `fix-round` rounds ties away from zero, following FreeType's corrected `ROUND_F26DOT6` rather than the naive form whose asymmetry Pango publishes. `FD-34` measured three independent projects making the denominator a parameter and none arguing for 64 specifically; `FD-39` names this build-list item (1). No extern, no `TIFn`, no compiler source, so no fixpoint | Not built. One new module `lib/prelude/fixed.chiral`, one consumer root under `prog/samples/`, one suite phase | FreeType `FT_PAD_FLOOR( x, n )`, cairo `CAIRO_FIXED_FRAC_BITS`, Blink `FixedPoint<fractional_bits, Storage>` (`records/findings.md:527`) (`OURS`/`IMPL`) | SH |
```

- **Ledger row**, into the `MEM · Memory & substrate floor` section
  (`docs/elements/ledger.md:158-161`), beside E24 `arith` and E200, whose form
  there is six columns:

```
| E<NN> | fixed-point | design | The fixed-point coordinate: the denominator rides the type | ←E24, ←E189, →E200 | SH |
```

- **Size:** three files, ~215 lines added, none changed.

  | file | change | lines | basis |
  |---|---|---|---|
  | `lib/prelude/fixed.chiral` | the `data` declaration and ten `->` definitions, with the range formula and the tie rule in the header | ~90 | `lib/prelude/set.chiral` is 46 lines for six functions and `lib/prelude/map.chiral` is 173 for a richer surface; ten small bodies plus a header sit between them |
  | `prog/samples/` | one new root, the consumer: a sprite row placed at a fractional y, rounded, drawn through `brepeat` and `bover` | ~95 | `prog/samples/e200-coverage-composite.prog` is 137 lines for one extern with four gate cases; this root has no extern to exercise |
  | `tools/test/` | one phase asserting the rounding table at ties and negatives, the floor at negatives, and the mixed-scale refusal as a `*_reject_*` fixture | ~30 | the phase-script floor. The suite-number call is ruled at `records/author-calls.md:64`, a gate takes the first number colliding with nothing, and Phase 33 is the highest (`tools/test/run-tests.sh:378`), so this takes **34** |

  No fixpoint, per §5 question 10. The gate is `build-new → test` with the new
  phase green and Phase 7 compiling the new root.

  ⚑ **The mixed-scale refusal belongs in the phase script.** Measured: `tools/test/run-tests.sh:179` skips every `*_reject_*` root and
  `:423` records the Phase 12 script as not ported, so a refusal dropped into
  `tools/test/samples/` is gated by nothing. `e170_reject_pool_size.prog` sits
  in exactly that state today. The new phase script runs, so the refusal is
  asserted there.

- **Residue, named and not absorbed.**

  | residue | owner | state |
  |---|---|---|
  | a value-indexed data at a concrete literal index in a `->` signature does not lower, minimal pair in §2 probe 5 | a new row in [[arcs/lowering-and-emit-arc]] or an `FD` row. ⚑ **Owed and not opened here**, because this run may not edit an arc file or `records/` | unrostered |
  | the 128-by-64 divide a full-range fixed-point multiply needs at a non-power-of-two denominator | the same. `docs/definitions/working-discipline.md:134-140` rules that an operation the backend can express and the language does not name is a hole one level down | unrostered |
  | `docs/decisions/decision-display-numerics.md:27-28` writes the `Op` sum as fifteen and omits `op-mulhu` | a `doc-audit` run on that decision. `E200`'s design named the same defect and it is still there | unscheduled |
  | `docs/banks/render.md:329` states seven residue rows as *"the whole of what the display tier owes"*, against `FD-39`'s six-item build list and the six raster rows opened 2026-09-18 | a `doc-audit` run on [[banks/render]], whose `updated` is 2026-09-04 | unscheduled |
  | `tools/test/samples/e170_reject_pool_size.prog` and the ten other `*_reject_*` fixtures under `tools/test/samples/`, eleven in all, are gated by nothing | the Phase 12 port, named at `tools/test/run-tests.sh:423` | unscheduled |
  | the accumulator, the prefix sum, the subdivision and the emitter | `R11`, `R12`, `R13`, `R14`, rostered on this arc | rostered, `unminted` |
  | what a pixel is | `R2`, rostered on this arc | rostered, `unminted` |

- **Related:** [[arcs/display-calculus-arc]], [[goals/display]],
  [[decisions/decision-display-numerics]],
  [[decisions/decision-primitive-with-consumer]],
  [[decisions/decision-lane-split]], [[banks/render]],
  [[definitions/working-discipline]], `records/findings.md` FD-34 and FD-39.
