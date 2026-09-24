---
row: crypto-primitives/K2
arc: crypto-primitives
title: the permutation module: named lanes, no array, the width as an erased index, the round count as a type index
kind: primitive
origin: new
req: 2
status: draft
updated: 2026-09-23
---

# crypto-primitives/K2: the permutation module: named lanes, no array, the width as an erased index, the round count as a type index

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** one module under `lib/crypto/` realizes Keccak-p as chirality
  code, with its five step mappings each carrying its own signature, its state a
  record of named lanes holding no array, its lane width an erased index, and its
  round count a type index, so that a target below the family's floor fails to
  construct rather than producing a weakened permutation.
- **Serves:** requirement 2 of [[arcs/crypto-primitives-arc]], "**The permutation
  is a family parameterized only where the mathematics is, and a target below its
  floor fails to construct.** Observable: the module carries the lane width as an
  erased index, carries no parameter the published family lacks, and a gate row
  shows the refusal for a state that cannot hold its capacity."
- **Goal:** [[goals/own-web]], condition 4.

The row is `kind: primitive` and `origin: new`, and its `req` cell reads 2 alone.
All three come from the roster cell at `docs/arcs/crypto-primitives-arc.md:163`.

**Two rulings are the input to this design and neither is re-opened here.** `T1`
at `.planning/CRYPTO-TRANSLATION.md:582` reads "**RULED 2026-09-07: the
mathematics, realized as separated primitives.** The five step mappings are each
their own primitive with its own signature. The family is the layer above them,
and any fusion is a composition there that owes a proof of equality", which fixes
the factoring. `docs/arcs/parts/crypto-primitives-K1.md` §5 chose Shape B, the
object is KECCAK-p[b, nr] with KECCAK-f[b] as its instantiation, and
`.planning/CRYPTO-MODEL.md:120-127` reaches the same level independently and
cites `K1` for it. So this row inherits the level and the factoring, and what it
owes is the carriage.

## 2. What the tree holds

Measured 2026-09-23 against the working tree at `c71ca2d`.

**Bank: none names a permutation, and none is owed for one.**
`docs/banks/INDEX.md` carries thirteen banks and no crypto entry. A bank refracts
one chirality concept across the homes it is split into, and a permutation is an
external object with no shard in this tree. The bank obligation lands on the
carriers instead, and four banks own them: [[banks/erasure]] for the erased
index, [[banks/memory]] for allocation and the `budget` dial,
[[banks/verification]] for the instrument tiering requirement 3 asks of the
result, and [[banks/module]] for the module key. `K1` §2 reached the same verdict
on 2026-09-07 and this run re-tested it rather than inheriting it.

### The translation this design builds against does not exist

`docs/translations/` holds two files, `README.md` and
`aead-chacha20-poly1305.md`. `docs/translations/keccak-p.md` is `K1`'s product
and `K1` is `status: draft`, so **this design is written before the object has
been rendered into this tree's forms**, which inverts requirement 1's order.

What that costs is exact and it is stated so §6 can be re-tested when the
translation lands. Every claim below about **the object** rests on
`.planning/CRYPTO-MODEL.md` §4 at `:107-215` rather than on a pinned source:
the five step mappings and their order, ρ's per-position offsets taken mod `w`,
π carrying no plane-count term, the boundary `R = 12 + 2l` between the `p` and
`f` levels, and Keccak-f[800] at 22 rounds. That section carries its own quotes
into `FIPS202` and `KECCAKSUM` and this design did not re-resolve them; `K1` §2
did, against [[records/findings]] FD-13. Every claim below about **this tree** is
first-hand and carries its own `file:line` or its own command.

### The word layer the permutation sits on

| what exists | where | rung | reached by |
|---|---|---|---|
| the 32-bit lane idiom, `M32`, `add32` and `rotl32` inside signed `I64` | `lib/crypto/chacha.chiral:18-25` | ENFORCED | every quarter round |
| a named-lane state record holding no array, sixteen lanes | `lib/crypto/chacha.chiral:42-46` | ENFORCED | `qround`, `dround`, `st-add` |
| the round count as a runtime `I64` argument on a decreasing counter | `lib/crypto/chacha.chiral:76-80` | ENFORCED | `chacha-block` |
| the closed `Op` sum, sixteen constructors and no rotate | `lib/prelude/prelude.chiral:35-39` | ENFORCED | the tal emitter, exhaustively |
| the erased index: an erased `(0 n I64)` binder beside a value-indexed datum | `lib/memory/mem-region.chiral:23-27` | ENFORCED | `region-open`, `mem-alloc` |
| the refinement carrier, `(refine I64 (>= 0) (< n))` against an erased capacity | `lib/memory/mem-linear.chiral:26-28` | ENFORCED | `mem-put-checked` |
| what a refinement predicate may say: five `SymOp`s over a constant or an operand level | `lib/typing/refine.chiral:11-18` | ENFORCED | the entailment decision |
| the crypto gate, 403 lines of shell at suite phase 31 | `tools/test/crypto.sh`, dispatched at `tools/test/run-tests.sh:367` | ENFORCED | phase 31 |

`lib/crypto/` holds two files, `chacha.chiral` at 163 lines and
`poly1305.chiral` at 245, **and no permutation**. Nothing under
`prog/compiler.prog` imports `crypto/`, so an element landing here owes no
compiler rebuild.

### What the erased-binder idiom actually reaches

[[records/crypto-primitives]] `CP-04` measured it on 2026-09-22 and this design
rests on that count: every erased binder in `lib/` is one of two shapes, **77**
are `(0 _ (type 0))` and **31** are `(0 _ I64)`, the `(Pool n)` / `(Region n)` /
`(Grid n)` capacity index, and **nothing anywhere in `lib/` is indexed by a data
term**. So an erased lane width is the second shape and is a built idiom, while
anything indexed by a key, a domain or a step is new carrier work, which is what
`crypto-primitives/K36` says of requirement 8's key-and-context index.

**A `(Region n)` has the same three fields at every `n`**, which is the property
that decides §4. The index changes how a field is read and never how many fields
there are. `(Grid n)` is the case that shows the alternative: it holds a
`(Pool n)` byte pool at `lib/protocol/grid.chiral:131`, so a collection whose
size varies is carried as bytes behind an index rather than as fields.

### Four measurements this run took of the lowering, because FD-49's conclusion is conditional on them

[[records/findings]] FD-49 priced `T1`'s separated factoring in C at 1.14x
against hand-fused `opt64` when `gcc -O3` inlines and at 5.43x when the step
boundary survives to runtime, and its `element:` field states the condition:
"the tree has no measured answer for whether its compiler inlines a five-call
chain over a 25-field record, and that is the question a `K2` design owes". Four
probes, each reproducible from the command beside it.

**1. `bin/chirality` erases no call.** A five-lane state record, five step
mappings as five top-level defs, and a round applying them in sequence compiles
to five call sites, one per step. The probe source is a five-field `I64` record,
five defs at `(-> L L)`, a `s-round` composing them, a tail-recursive loop, and
an entry def named `compile-main` at `(=> I64 I64)`, which is the name
`bin/chirality:88-90` fixes. The emitted ELF carries no sections and no symbols,
so it is disassembled flat:

```
bin/chirality compile /abs/path/sep.chiral -o /abs/path/sep.elf
objdump -D -b binary -m i386:x86-64 -M intel --adjust-vma=0x400000 sep.elf
```

The round body at `0x407ef6` reads `call 0x408726`, `call 0x408485`,
`call 0x40835c`, `call 0x4080b2` and a tail `jmp 0x407f64`: the four calls and
the tail jump are the five step mappings, standing in the machine code exactly as
they stand in the source. **There is no inlining pass in the lowering.**
`lib/lowering/upper/optimize.chiral` holds `specialize` and `fold`, and
`docs/definitions/status-ledger.md:177` records that
`lib/lowering/compile-back.chiral` "calls `fold` alone, so `specialize` is built
and unadopted"; neither is an inliner. A grep for the word over `lib/` and
`prog/` returns comments about hand-inlined helpers and no pass.

**2. The call itself is cheap, and the separation's cost sits elsewhere.**
Five step mappings over a bare `I64`, so that the boundary is a call and nothing
else, against the same five bodies `let`-bound inside one def, 40,000,000
iterations, minimum of seven runs on this host:

| form | wall clock | per iteration |
|---|---|---|
| five top-level defs, five calls | 377 ms | 9.4 ns |
| one def, the five bodies `let`-bound | 195 ms | 4.9 ns |

Four extra calls cost 4.5 ns, so **a call in this tree is about 1.1 ns**. Both
forms print `1152921496016945024`.

**3. What the separation costs is the intermediate state, because every
constructor heap-allocates.** The same comparison over the five-lane record, five
steps against one fused body, 4,000,000 rounds:

| form | wall clock | per round | user | sys |
|---|---|---|---|---|
| five step defs over the record | 571 ms | 143 ns | 0.228 s | 0.240 s |
| one fused round body | 195 ms | 49 ns | 0.111 s | 0.055 s |

Both print `-4989674163969107408`, which is this design's own differential in
miniature. The gap is 2.93x and it decomposes: four of those extra calls are
4.5 ns by probe 2, and the remaining **89 ns is four heap records**. The
disassembly shows why. Each step's constructor emits the bump-allocator sequence
at `0x40801a`, `lea rcx,[rax+0x30]` against the arena limit with a grow call
beside it, so **a five-lane state costs 0x30 bytes and a 25-lane state costs
0xD0, 208 bytes, allocated once per step**. At Keccak-f[1600] that is five
allocations per round over 24 rounds, **120 allocations and 24,960 bytes per
permutation**, against the 5,776 bytes per 64-byte ChaCha block that
[[benchmarks/crypto-kernel-allocation]] measured. The `sys` column is the arena
growing: it reclaims nothing, which is the same property `docs/elements/catalog.md:336`
records for `E200` as "a 64 MB arena that reclaims nothing".

**4. A shift by the full width is the identity, so ρ's zero offset is correct at
`w = 64` by an accident of the hardware.** `.planning/CRYPTO-MODEL.md:522-525`
carries the question as owed and `K1` §5 question 8 deferred it here. Measured
with a runtime count, so no constant fold can be responsible:

```
(def w (-> I64 I64) (lam (k) (+ 60 k)))
(shl 1 (w 4))                        => 1
(shr 1024 (w 4))                     => 1024
(bor (shl 12345 0) (shr 12345 (w 4))) => 12345
```

The count is masked to six bits before the shift, which is x86-64's `shl`/`shr`
behaviour surfaced unchanged through `op-shl` and `op-shr`. **What the emitted
code does is now measured and what it ought to mean is still open**, and the two
are different questions. The second is `C34` at
`docs/benchmarks/OPT-CANDIDATES-2026-09.md:350`, "shift semantics for an
out-of-range count", state `open`, and `docs/arcs/parts/emitted-speed-X8.md:307`
states the asymmetry that keeps it open: "for a shift, masking gives `shl x 64`
the value `x` where the arithmetic reading gives 0".

**ρ's zero offset is correct under both readings, so `C34` does not gate this
row.** Under masking `(bor (shl x 0) (shr x 64))` is `(bor x x)`, which is `x`.
Under the arithmetic reading the same expression is `(bor x 0)`, which is `x`.
That is the whole of what `K1` §5 question 8 asked and the answer does not wait
on `C34`. At `w = 32` the idiom is correct for a third reason,
`(shr 3735928559 32)` is `0` because a 32-bit lane zero-extended in `I64` has
nothing above bit 31.

**What the language still does not name is the rotate itself.**
`lib/prelude/prelude.chiral:35-39` has `op-shl`, `op-shr` and `op-sar` and no
constructor that turns a word, which is the shape
`docs/definitions/working-discipline.md:134-142` names for `op-mulhi`: an
operation the backend emits that the language does not name is a hole one level
down, and a constant-time judgment can reason about a rotate and cannot reason
about a shift and a shift and an or that an emitter happens to fuse. That is
owned, by `emitted-speed/X8` at `docs/arcs/emitted-speed-arc.md:278`, `designed`
and `unminted`, whose own §6 at `docs/arcs/parts/emitted-speed-X8.md:358` names
"the one scheduled consumer is `crypto-primitives/K2`".

**A fifth measurement, found while taking the fourth, and it belongs to no row in
this arc.** `i64->str` faults on the minimum `I64`: `(i64->str (- (- 0
9223372036854775807) 1))` segfaults at exit 139 while
`(i64->str (- 0 9223372036854775807))` prints. A 64-bit permutation produces that
lane value, and requirement 3's vector gate prints lanes, so the defect is on the
path this arc walks. It is reported and not repaired here.

## 3. The delta

Nothing in this tree is a permutation, so the delta is the whole module. Four
things are missing and the fourth is the one this run discovered.

**1. The state type.** `lib/crypto/chacha.chiral:42-46` is the only named-lane
record in the tree and it is sixteen `I64` fields at one fixed width. A Keccak
state is 25 lanes at a width the target supplies, so the record is new and the
index it carries is new beside it.

**2. The five step mappings and the family over them.** `T1` fixes that these are
five signatures, and `.planning/CRYPTO-MODEL.md:135-141` fixes what each one
computes. The family layer owes the derivation `R = 12 + 2l` and the refusal for
a target below the floor, which is requirement 2's third observable and which
nothing in this tree has ever written: there is no gate anywhere showing a crypto
configuration failing to construct.

**3. A width-generic rotate.** `rotl32` at `lib/crypto/chacha.chiral:24-25` is
fixed at 32 and masks with `M32`. A family over the seven widths needs the
rotation to move with `w`, and §2's probe 4 shows the two-shift idiom is correct
at both 64 and 32 for two unrelated reasons.

**4. ⚑ The lowering erases no call, which was assumed by nothing in this arc and
is now measured.** FD-49's price for `T1` was 1.14x under the condition that the
step boundary is a source-level fact the compiler may erase. **In this tree it is
not.** The five calls stand in the emitted code and each step's return value is a
208-byte heap record at Keccak's width. `docs/definitions/working-discipline.md:112-124`
gives the form this takes: a capability the substrate lacks is a finding rather
than a blocker, and the honest reading is that crypto is the first workload to
ask this substrate to erase a call boundary. The number the asking costs is §2's
2.93x, and **§2's probes 2 and 3 locate 95% of it in allocation rather than in
the call**, which is `crypto-primitives/K20`'s subject and not this row's.

**Verdict:** a real delta, and the largest in the arc. Nothing here is built.

## 4. The shapes

The axis is what carries the state between two step mappings, because `T1` has
already fixed that there are five of them and `K1` has already fixed the level.
Three forms answer it and the tree settles none of them.

### Shape A: one named-lane record per family member, five top-level step defs

- **Form:** `(data St ((w I64)) (st (a00 I64) … (a44 I64)))`, 25 named fields,
  with `w` an erased index carried as `(0 w I64)` on every signature, on the
  `(Region n)` idiom at `lib/memory/mem-region.chiral:23-27`. Five defs
  `(-> (0 w I64) (-> (St w) (St w)))`, one per step mapping, and a round that
  composes them. The round count rides as a second index with a runtime witness
  beside it, the same two-part shape `region-open` uses for its capacity.
- **Costs:** §2's 2.93x, and the five calls and five 208-byte records per round it
  decomposes into. A 25-lane record is destructured and rebuilt five times per
  round, which is the shape `lib/crypto/chacha.chiral:59-72` already writes for
  sixteen lanes in 14 lines, five times over and against a wider record.
- **Forbids:** `planes` as a derived dial. A record's field count is fixed at its
  declaration, so a one-plane state and a five-plane state are two types, and
  `.planning/CRYPTO-MODEL.md:320-325`'s promise that the target's `budget`
  fixes `planes` has no carrier over one type. It also forbids the in-place round
  structure that FD-49's fourth technique names, because every step materialises
  a whole state.

### Shape B: Shape A's five defs kept as the specification, with a fused round beside them

- **Form:** the five mappings exactly as Shape A writes them, plus one
  `f-round` whose body is the five bodies `let`-bound in sequence with no
  intermediate `St` constructed. The fused one ships and the five are what
  `crypto-primitives/K15`'s differential gate compares it against. `T1` licenses
  this in its own words: "any fusion is a composition there that owes a proof of
  equality".
- **Costs:** the proof. FD-49 §6 surveyed five families and found four of them
  verify a hand-written fast form against a specification rather than deriving
  it, so what this tree can actually supply is a differential over test vectors
  and not an equality. It also doubles the source for every family member, and
  `.planning/CRYPTO-MODEL.md` `C6` already prices writing every kernel twice as a
  cost worth avoiding.
- **Forbids:** nothing structurally. It converts `T1`'s free property, that
  separated steps reproduce the published order, into a property one artifact has
  and the shipping one owes.

### Shape C: the state as bytes behind a `(Pool n)`

- **Form:** `(data St ((n I64)) (st (1 pool (Pool n)) (w I64) (planes I64)))` on
  the `(Grid n)` precedent at `lib/protocol/grid.chiral:131`. One type reaches
  every member of the family, the lane count and the width are both real indices,
  and `planes` becomes the derived dial requirement 2 and
  `.planning/CRYPTO-MODEL.md` §8 both want.
- **Costs:** every lane access becomes an offset computation and a bounds
  obligation. `lib/typing/refine.chiral:11-18` admits five `SymOp`s over a
  constant or an operand level, so `(refine I64 (>= 0) (< n))` proves an offset in
  range and an offset derived from a lane coordinate and a width is arithmetic
  that fragment cannot decide, which is the same wall `docs/elements/catalog.md:336`
  records for `E200` where "`blen dst == 4 * blen cover` has no spelling there".
  A `Pool` is a linear atom, so the state becomes linear and every step mapping
  threads it, which settles `C12` at `.planning/CRYPTO-MODEL.md:518` by side
  effect rather than by decision.
- **Forbids:** `.planning/CRYPTO-MODEL.md:230-243`'s whole argument. That section
  derives constant time from the state being a record of named lanes with no
  array: π costs nothing because it is which field is read next, ρ needs no table,
  no bounds check appears because there is no index, and **a secret-dependent
  index has no spelling because there is no index at all**. Shape C gives the
  index a spelling and hands `native-protocol/N5` back the work that section says
  it has nothing left to do.

## 5. The call

- **Chosen:** **Shape A**, one named-lane record per family member with five
  top-level step defs, the width erased, and the round count indexed.

Three reasons, in order of weight.

**The measured cost does not sit where fusing would spend the proof.** §2's
probes 2 and 3 put 4.5 ns of the 94 ns per-round gap at the call boundary and
89 ns at four heap records. Shape B buys the whole 2.93x by taking on `T1`'s
equality obligation, and FD-49 §6 measured that no surveyed mechanism lets an
author write the clean form and get the fast one: four of five families verify a
hand-written fast form and the fifth withdraws its own ideal. Paying that for a
term that is 5% of the gap is the wrong trade, and the other 95% has a roster row
already, `crypto-primitives/K20`, whose cell reads "zero allocation in the inner
loop".

**Shape A is what makes the instruments possible.** `crypto-primitives/K15`'s
differential gate needs two representations of one object and
`crypto-primitives/K16`'s law gate runs at the smallest member. Shape A written
first gives `K15` its first representation and Shape B's fusion is then the
second, which is the ordering the arc's own edge note at
`docs/arcs/crypto-primitives-arc.md:85-87` demands when it says `assurance` runs
backward into `permutation` and constrains how the first representation is
written.

**Shape C forfeits the property the arc was opened to get.**
`.planning/CRYPTO-MODEL.md:230-243` derives constant time from the absence of an
index, and the row's own cell says "named lanes, no array" for that reason. A
form that reintroduces the index to gain a `planes` dial trades a structural
guarantee for a configuration knob, and §6 records the dial as the cost Shape A
pays instead.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | What carries the state between two step mappings | RESOLVED | Shape A, on the three reasons above and on §2's probes 2 and 3 |
| 2 | Whether the factoring itself is re-opened by §2's 2.93x | RESOLVED | No. `T1` at `.planning/CRYPTO-TRANSLATION.md:582` is ruled and this design takes it as input. FD-49's `element:` field states the same, "it does not reopen `T1`" |
| 3 | Whether a shift by the full width is defined, which ρ's zero offset reaches at `w = 64` | ⚑ **RESOLVED**, having been DEFERRED to this row by `docs/arcs/parts/crypto-primitives-K1.md` §5 question 8 | §2's probe 4 measured it in the emitted code: the count is masked to six bits, so a shift by 64 is the identity. **The narrower question ρ raises is answered under either semantics**, because `(bor (shl x 0) (shr x 64))` is `x` whether the second term is `x` or `0`, so this row is unblocked. `.planning/CRYPTO-MODEL.md:522-525` carries it as owed and this measurement discharges the half that belongs to this arc. What the shift **ought** to mean stays open as `C34` at `docs/benchmarks/OPT-CANDIDATES-2026-09.md:350`, and this row neither settles it nor needs it |
| 4 | Whether the rotate is named in the language or left to the shift-shift-or idiom | DEFERRED | `emitted-speed/X8` at `docs/arcs/emitted-speed-arc.md:278`, `designed` and `unminted`, which owns "the rotate's name and its width" and whose §6 already names this row as its one scheduled consumer. Its §5 question 3 resolves the out-of-range amount at `docs/arcs/parts/emitted-speed-X8.md:307`, "`rot x n` equals `rot x (n mod 64)`, and the machine implements it with no fixup". This element ships on the shift-shift-or idiom and adopts `rotl` when `X8` lands. The cost in the meantime is stated at `.planning/CRYPTO-MODEL.md:225`, where ρ's "rotation itself stays three ops, because the closed `Op` sum has no rotate and the backend emits shift, shift, or", once per lane at `:138`'s "one rotation per lane, offsets taken mod `w`" |
| 5 | Whether Ascon-p is a second instance of this family or a second design | DEFERRED, and it does not block | `C2` at `.planning/CRYPTO-MODEL.md:508`, open. `K1` §5 question 4 deferred it here and it is carried rather than answered. **It does not gate Shape A**, because `.planning/CRYPTO-MODEL.md:181-190` already measured that Ascon's round drops θ and π and so is a composition at the family layer owing an equality proof. Shape A's five step defs are what such a composition would be written from, so the module's form is the same under either answer and only the instance table moves |
| 6 | What carries `planes`, given that a record's field count is fixed at its declaration | DEFERRED | `crypto-primitives/K13`, the target declaration row, whose cell reads "what a target states beyond width, and the cost model that gives `best` a meaning". §4 Shape A forbids a derived `planes` and `.planning/CRYPTO-MODEL.md:320-325` promises one, and which side moves is a statement about what a target declares |
| 7 | Whether Keccak-f[25] is a real module or a test-only instance, which decides what the smallest member is | DEFERRED | `crypto-primitives/K16`, the law gate row, which owns "run exhaustively at the smallest member of each family". `T7` at `.planning/CRYPTO-TRANSLATION.md:588` is the open decision and `K1` §5 question 7 already routed it there |
| 8 | Whether the arc's requirement 8 index reaches this module | RESOLVED | No. `docs/arcs/crypto-primitives-arc.md:138-156` scopes requirement 8 to a keyed module's output, and this row is unkeyed: the permutation takes a state and returns a state with no key anywhere in either. `crypto-primitives/K19` and `crypto-primitives/K4` are the keyed rows over this one and they carry the `8` cell, which this row does not |
| 9 | ⚑ Whether `i64->str` faulting on the minimum `I64` is this row's | RESOLVED, with residue | No. It is a defect in `lib/prelude/prelude.chiral`'s `i64->str`, measured by §2 and reachable from every program in the tree, and this element neither causes it nor repairs it. **It belongs to no roster row anywhere**, and `docs/definitions/working-discipline.md:76-86` forbids opening a follow-on `E#` for it, so it is reported here and left for the arc to route. Requirement 3's vector gate is what meets it first, because a 64-bit lane takes that value |

No question here is NEEDS-AUTHOR, the frontmatter reads `draft`, and no row is
owed in [[records/author-calls]]. Question 5 is an author call that stands open
in `.planning/CRYPTO-MODEL.md` §13 and this design carries it rather than
settling it.

## 6. The mint packet

- **Elements: one.** The five step mappings, the state type and the family over
  them are one element because they constrain each other: every step's signature
  is `(-> (St w) (St w))`, so the state type's index set is the family's dial set
  and neither can be settled without the other. The three parts of requirement
  2's observable land inside it, the erased width on the state type, the absent
  extra parameter on the family layer, and the refusal on the construction of a
  configuration below its floor. `crypto-primitives/K15` and
  `crypto-primitives/K16` carry the instruments and are separate rows already.
- **Band:** `UNASSIGNED`. The arc reserves none, per
  `docs/arcs/crypto-primitives-arc.md:14-16` and
  [[decisions/decision-lane-split]], which rules at `:48` that an arc without a
  band "mints the next number free **tree-wide**". Stated as a fact and not as a
  reservation, measured 2026-09-23 by `tools/pack/pack.py`'s own allocator: the
  highest taken number is `E200`, the first free numbers tree-wide are 191
  through 195 inside Lane B's `E190-E195`, and the first free number outside
  every reserved band is 264. **Those numbers are written without an `E` prefix
  on purpose.** `ledger-lint` check AJ enforces the deferral rule on the
  spelling, so writing them as element ids in this artifact would name two
  elements that do not exist, which is the defect the rule is for. The mint takes
  what the allocator gives.
- **Catalog row**, five columns on the header at `docs/elements/catalog.md:93`,
  `| E# | Element | State / location | Reference (class) | Track |`:

  `| E<NN> | **Keccak-p as five step primitives and the family over them.** The state is a record of 25 named lanes holding no array, so π is which field is read next and a secret-dependent index has no spelling (`.planning/CRYPTO-MODEL.md:230-243`). The lane width rides as an erased `(0 w I64)` index on the `(Region n)` shape at `lib/memory/mem-region.chiral:23-27`, the round count as a second index with a runtime witness beside it, and `R = 12 + 2l` is the derivation an instance calling itself Keccak-f[b] owes. A configuration whose state cannot hold its capacity fails to construct, which is requirement 2's third observable and the first refusal of its kind in this tree. `T1` fixes the five signatures and `docs/arcs/parts/crypto-primitives-K1.md` fixes the level at Keccak-p[b, nr]. **Measured before it was designed**: the lowering erases no call, so the five step boundaries stand in the emitted code and each step's state is a 208-byte heap record, 2.93x against a fused round on a five-lane probe, of which 95% is allocation and belongs to `crypto-primitives/K20` | Not built | FIPS 202 Keccak-p[b, nr] (`SPEC`) | SH |`

- **Ledger row**, six columns under `## CRY · Cryptography` at
  `docs/elements/ledger.md:349`, on the shape `docs/elements/ledger.md:184` uses:

  `| E<NN> | keccak-p | design | Keccak-p as five step primitives and the family over them: 25 named lanes, no array, the width erased, the round count indexed, and the refusal for a target below the floor | — | SH |`

  The deps cell is empty on purpose. Every consumer of this element is an
  unminted roster row, `crypto-primitives/K3`, `K4`, `K16` and `K19`, and
  `docs/definitions/working-discipline.md:76-86` forbids writing an `E#` that
  does not exist into a tracked cell.

- **Size:** one new file `lib/crypto/keccak-p.chiral` at an estimated 300 lines,
  and one new gate under `tools/test/` at an estimated 150. The basis for the
  first is `lib/crypto/chacha.chiral`, 163 lines for a sixteen-lane state whose
  `dround` at `:59-72` spends 14 lines destructuring and rebuilding: five step
  bodies over 25 lanes is that shape five times with a wider record, against
  chacha's one. The basis for the second is `tools/test/crypto.sh` at 403 lines
  covering two modules. **Nothing under `lib/` or `prog/` that the compiler
  imports is touched**, measured 2026-09-23: no file in `prog/compiler.prog`'s
  closure imports `crypto/`, and `lib/crypto/poly1305.chiral:17` is the only
  in-tree importer of `crypto/chacha`. So the element owes no rebuild-and-promote
  under `docs/definitions/working-discipline.md:17-50`.
- **Related:** [[arcs/crypto-primitives-arc]], [[arcs/emitted-speed-arc]],
  [[goals/own-web]],
  [[records/findings]], [[records/crypto-primitives]],
  [[benchmarks/crypto-kernel-allocation]], [[banks/erasure]], [[banks/memory]],
  [[banks/verification]], [[banks/module]],
  [[decisions/decision-design-before-mint]], [[decisions/decision-lane-split]],
  [[definitions/working-discipline]].

Every `E#` named here is already minted. Where one is owed, this names a roster
row instead. Five rows carry this design's deferrals and every one of them exists
today: `crypto-primitives/K13`, `K15`, `K16` and `K20` in
`docs/arcs/crypto-primitives-arc.md`'s roster, and `emitted-speed/X8` at
`docs/arcs/emitted-speed-arc.md:278`, which names this row as its own scheduled
consumer.
