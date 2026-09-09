---
row: emitted-speed/X8
arc: emitted-speed
title: the rotate's name and its width: `C1` and `C2` name a left and a right rotate and the sum names neither, `C35` recognizes the idiom in the emitter and names no operation, and `rotl32` (`lib/crypto/chacha.chiral:24-25`) rotates at 32 bits inside a 64-bit lane, so what width a named rotate carries is open against `C32` and `B8`
kind: primitive
origin: new
req: 6
status: draft
updated: 2026-09-08
---

# emitted-speed/X8: the rotate's name and its width

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** the machine's rotate reaches surface source under a name that
  says which direction it turns, at a stated width, with the out-of-range
  amount disposed rather than inherited in silence.
- **Serves:** requirement 6 of [[arcs/emitted-speed-arc]] `:252-265`, first
  half, "a rotate and a widening multiply reachable from surface source", and
  its second half, "every one of the 38 bucket C rows reading as a named
  operation, as a row scheduled by name under another condition, or as a refusal
  citing the baseline", of which `C1`, `C2` and `C35` are three.
- **Goal:** [[goals/emitted-speed]] `:115`, condition 6, "Every operation the
  machine offers is named or refused, and every name the `Op` sum carries reaches
  the surface."
- **Kind:** `primitive`. The deliverable is a constructor and the surface name
  that reaches it. The roster's kind cell carries `primitive` and this run
  changes it to nothing else.

## 2. What the tree holds

Measured 2026-09-08 against the live tree. Every line number below was opened on
that date. A concurrent session commits frequently and the numbers moved twice
today.

- **Bank:** none. [[banks/INDEX]] lists thirteen banks and a grep of all of them
  for the rotate, for `rotl` and for the `Op` sum returns nothing. The absence is
  already recorded: [[arcs/emitted-speed-arc]] §3 states that "the machine's
  operation set holds no shard either", so condition 6 opens on a concept with no
  refraction. This run does not build the bank. `emitted-speed/X7` §6 carries the
  same residue and no roster row in this arc holds it.

### The operation as it exists

| what exists | where | rung | reached by |
|---|---|---|---|
| the closed `Op` sum, **sixteen** constructors, every one a scalar 64-bit binary operation, and none of them a rotate | `lib/prelude/prelude.chiral:36-39` | IMPLEMENTED | `ti-prim`, `op-bytes`, `bini-body` |
| the extern block, **sixteen** bindings. `E189` closed the last gap on 2026-09-08 by adding `mulhi` and `mulhu` | `lib/prelude/prelude.chiral:59-74` | IMPLEMENTED | surface source |
| `ti-prim` is binary and single-destination, and `erase-prim` takes exactly two operands and refuses every other arity | `lib/lowering/tal/ir.chiral:21`, `lib/lowering/tal/erase.chiral:153-157` | IMPLEMENTED | every lowered prim |
| the rotate is binary, so it needs nothing from `B6`. That separates it from `C3`, `C4`, `C5`, `C6`, `C20`, `C21` and `C22`, whose own rows each name `B6` | `docs/benchmarks/OPT-CANDIDATES-2026-09.md:319-322,336-338`, against `lib/lowering/tal/ir.chiral:21` | measured | |
| `TalTy` carries one integer, `tt-i64`. An operation's width has no type to travel in, so a width rides the operation's name or goes unspelled | `lib/lowering/tal/ssa.chiral:21-22` | IMPLEMENTED | `ttype`, `ck-instrs` |

### The six sites a new constructor edits, and the four it does not

`op-mulhu` landed on 2026-09-08 and its edit set is on disk, so the cost of one
constructor is measured rather than estimated. Six edited points across three
`lib/` files, and one that needs none.

| site | where | what a rotate needs |
|---|---|---|
| the sum | `lib/prelude/prelude.chiral:38` | one constructor per name |
| `op-name`, exhaustive | `lib/prelude/prelude.chiral:44-51`, the `mulhu` arm at `:49` | one arm per name |
| the extern block | `lib/prelude/prelude.chiral:74` | one line per name |
| `op-parse`, the erase boundary | `lib/lowering/tal/erase.chiral:90-107`, the `mulhu` arm at `:101` | one arm per name, plus the nesting tail |
| `op-bytes`, exhaustive | `lib/lowering/x64/mach.chiral:355-391`, the `mulhu` arm at `:379` | one arm and one byte constant per name |
| `bini-body`, exhaustive | `lib/lowering/x64/mach.chiral:967-1033`, the `mulhu` arm at `:1031` | one arm and one imm8 encoder per name |
| `x64-clobbers` | `lib/lowering/x64/mach.chiral:1443-1465`, the `mulhu` keys at `:1456` | **nothing.** `bin:` and `bini:` keys outside `clb-clean?` (`:1427-1441`) fall to `clb-rcx`, which is what the three shifts take. `mulhu` needed a key because one-operand `mul` writes `rdx` |

Two further matches over `Op` carry a wildcard and are provably unreached by a
rotate. `op-cmp?` (`lib/prelude/prelude.chiral:54-55`) answers `false` by
default, and `fjc-cc` (`lib/lowering/x64/mach.chiral:1201-1211`) is reached only
through `fused-of`, which guards on `op-cmp?` (`lib/lowering/mach/emit-core.chiral:379-393`).

The constant folder is a third site the bucket C preamble's edit list omits, and
the omission is correct. `fold-prim` dispatches on a `Str` over `+ - * / %` and
`fold-cmp` over `=i <i <=i` (`lib/lowering/upper/optimize.chiral:60-73`); every
bitwise operation in the sum already falls through to `none`. A rotate joins them
and folds nothing, which is a missed fold rather than a wrong answer.

### The encoding, and what of it the tree already carries

The three shifts are the same x86 opcode group under three ModRM digits, and all
six encoders are on disk.

| encoder | bytes, decimal as written | form |
|---|---|---|
| `x-sar-cl` | `72 211 248` | `sar rax, cl` |
| `x-shr-cl` | `72 211 232` | `shr rax, cl` |
| `x-shl-cl` | `72 211 224` | `shl rax, cl` |
| `x-shr-imm` | `72 193 232` then the count byte | `shr rax, imm8` |
| `x-shl-imm` | `72 193 224` then the count byte | `shl rax, imm8` |
| `x-sar-imm` | `72 193 248` then the count byte | `sar rax, imm8` |

`lib/lowering/x64/mach.chiral:325,327,335,337-338,341-342,857-858`. The ModRM
byte is `192 + 8 x digit`: `224` is digit 4, `232` is digit 5, `248` is digit 7.
A rotate reuses opcode `211` for the count-in-`cl` form and `193` for the imm8
form, and differs only in the digit. ⚑ **Which digit selects `rol` and which
selects `ror` is an external ISA fact and this tree pins no x86 source.**
`.planning/sources/` holds no Intel or AMD manual, and `records/findings.md`
carries no row about the instruction set. The SPEC owes that pin or the gate owes
the confirmation.

### The immediate form is the one the workload uses

Every rotate amount in the one built consumer is a literal.

| what | where |
|---|---|
| `rotl32` at four operations: `(band (bor (shl x n) (shr x (- 32 n))) M32)`, with `M32` at `:18` | `lib/crypto/chacha.chiral:24-25` |
| `qround` calling it four times, at 16, 12, 8 and 7 | `lib/crypto/chacha.chiral:52-55` |
| `dround` calling `qround` eight times, so a double round runs 32 of them and a block at ten double rounds runs 320 | `lib/crypto/chacha.chiral:59-72,76-81` |
| the pinned count: `qround` is `4 x (add32=2, bxor=1, rotl32=4)` = 28 ops, 80 quarter rounds per block, 35 ops per byte | `docs/benchmarks/crypto-kernel-allocation.md:221-225`, measured 2026-09-07 |
| the shifts' immediate arms, each guarded `(and (<=i 0 imm) (<=i imm 63))` and falling back to `mov rcx, imm` plus the `cl` form outside it | `lib/lowering/x64/mach.chiral:977-982,983-986,1025-1029` |

⚑ **The pinned count of 4 counts the four bit operations.** `rotl32`'s body is
five prim applications as written, because `(- 32 n)` is a `ti-prim` too. It
folds only if `rotl32` inlines, and `opt-tfns` adopts `fold` alone
(`lib/lowering/compile-back.chiral:247-250`), which is a constant folder over
`Instr` and not an inliner. So `rotl32` is a real call and the subtraction is a
real instruction inside it.

### What `C35` would cost here

The tree's peephole is byte-level and holds two patterns of one residency rule.
`peep-hit` (`lib/lowering/x64/mach.chiral:1245`) matches a `mov [slot], rax`
ending one emitted chunk against a `mov rax, [slot]` beginning the next, over raw
bytes, with the same displacement; `peep-hit-rcx` at `:1285` is the same shape
on the `rcx` operand path, and `x64-peep` at `:1321` drives both.

The rotate idiom spans four `ti-prim` instructions whose intermediate values each
take a stack slot, because the memory machine puts every virtual register in one
and there is no register allocator (`lib/lowering/x64/mach.chiral:7-9,45,53`).
Recognizing it at that level means matching across four chunks and the loads and
stores between them. Nothing in the tree does that, and both existing patterns
are two-chunk pairs.

### The two consumers, one built and one scheduled

| consumer | what it asks the rotate for | state |
|---|---|---|
| ChaCha20, `lib/crypto/chacha.chiral` | a **32-bit** rotate inside a signed `I64` lane, 320 per block | built, gated |
| `crypto-primitives/K2`, the permutation module | a **64-bit** rotate per lane. `.planning/CRYPTO-MODEL.md:137-138` counts a Keccak-f round at 25 rotations in ρ and 5 in θ, sourced to `FIPS202`, which `.planning/sources/` pins. `.planning/CRYPTO-MODEL.md:225` measures the ρ rotation at three operations here "because the closed `Op` sum has no rotate and the backend emits shift, shift, or", and `.planning/CRYPTO-MODEL.md:237` records the amounts as literals | `open`, `unminted` |

`.planning/CRYPTO-MODEL.md:512` carries `C6`, whether the word layer lands before
the kernels, "since scoping it after means writing every kernel twice". `K2` is
the row that would be written twice.

### The amount at the width and above

| fact | where |
|---|---|
| `C34` records that no document in this tree states what a shift by 64 or more means, and that `x-shl-cl` inherits x86's masking of the count to six bits | `docs/benchmarks/OPT-CANDIDATES-2026-09.md:350` |
| `bini-body`'s `0..63` guard is an encoding-legality test and states no semantics. Outside the range it emits `mov rcx, imm` and the `cl` form, which masks | `lib/lowering/x64/mach.chiral:977-982`, against `:325,327,335` |
| `F34` names the family, "choosing semantics so the cheap encoding is correct", and records it as "present for division, open for shifts and string indexing" | `docs/benchmarks/OPT-CANDIDATES-2026-09.md:515` |
| the crypto end reaches the same question: a rotation needs `(bor (shl x n) (shr x (- w n)))` and the `n = 0` case shifts by the full width, which ChaCha20 never exercises | `.planning/CRYPTO-MODEL.md:522-525` |
| the rotation amount wanted at `(refine I64 (>= 0) (< w))`, so the refinement fragment is a third answer and it belongs to the crypto arc | `.planning/CRYPTO-MODEL.md:314` |
| [[arcs/emitted-speed-arc]] `:261-265` records the baseline a refusal would cite as OWED, since no document under `docs/decisions/` names the instruction set the emitted code may assume | |

## 3. The delta

The machine turns a word by a count in one instruction and nothing in this tree
names that operation. [[working-discipline]] `:126-132` already records the
absence as a finding, with crypto as "the first workload to ask this substrate
for a rotate". Subtracting §2 leaves four separable pieces.

- **Two constructors' worth of machine capability with no name.** The sum's
  sixteen members are the four arithmetic, the modulus, three signed
  comparisons, two widening multiplies, three shifts and three bitwise
  operations. Rotation is absent from all sixteen and is expressible only as the
  three-operation idiom `C35` describes.
- **A width the operation set cannot spell.** `TalTy` has one integer
  (`lib/lowering/tal/ssa.chiral:21-22`) and every `Op` constructor is 64-bit. The
  one built consumer wants 32. So the width question is live inside this row.
  `C32` and `B8` own the type-system answer and this arc leaves them
  unscheduled.
- **An out-of-range amount with no stated meaning.** The shifts inherit x86's
  masking with no document saying so, and a rotate arrives at the same seam.
- **`C1`, `C2` and `C35` undisposed** against requirement 6's second half, which
  wants every bucket C row reading as named, scheduled elsewhere, or refused.

**Verdict: a real delta.** One machine capability, an open width, and an
undisposed semantic seam.

## 4. The shapes

Four candidates. Three of them are takeable in this run and the fourth is ruled
out by a standing rule rather than by cost, so the tree settles nothing here and
the row runs the full pipeline.

### Shape A: one 64-bit rotate, left only

- **Form:** add `op-rotl` with the extern `rotl`, opcode `211` and `193` under
  the `rol` digit. A right rotate is written `(rotl x (- 64 n))`.
- **Costs:** one constructor, three exhaustive arms, one `op-parse` arm, two byte
  encoders, one extern. Three `lib/` files inside the compiler's blob, so one
  full BUILD RULE cycle with a fixpoint.
- **Forbids:** it forbids nothing at the machine layer and leaves `ror` emitting
  from no name, which is the hole [[working-discipline]] `:134-142` rules on and
  the state `E189` was minted to end for the multiply. It also makes the
  out-of-range amount **load-bearing**: `(rotl x (- 64 0))` is a rotate by 64, so
  the identity every right rotate is written through lands on exactly the case
  `C34` records as unstated. Shape B never reaches it.

### Shape B: `rotl` and `rotr`, two 64-bit constructors

- **Form:** the machine holds two instructions and the sum names two.
  `op-rotl` and `op-rotr`, both `(-> I64 I64 I64)` externs, the direction riding
  the operation's name. That is the `shr` and `sar` shape verbatim
  (`lib/prelude/prelude.chiral:71-72`) and the shape `E189` took for the two
  widening multiplies on 2026-09-08 (`docs/elements/catalog.md:505`).
- **Costs:** Shape A's cost doubled at every arm, and still one edit to one closed
  sum in the same three files, so one BUILD RULE cycle and one fixpoint.
- **Forbids:** it forbids reading the direction off anything but the call site,
  which is what E108 already settled for the two shifts
  (`docs/examples/E108-shift-ops.md:74-79`). It forbids nothing `C32`, `B8` or
  `C38` want.
- **What it buys the measured workload:** nothing. Held against `rotl32`, a
  64-bit rotate leaves the count at four. For `x` in `0..2^32-1` and `n` in
  `1..31`, `(band (rotl x n) M32)` drops the wrapped bits instead of returning
  them to the low end, because they sit at bit positions 32 and above. The
  correct 32-bit rotate over a 64-bit one is
  `(bor (band (shl x n) M32) (shr x (- 32 n)))`, four operations again. What
  changes is the name and the 64-bit consumer.

### Shape C: a 32-bit rotate

- **Form:** `op-rotl32` and `op-rotr32`, emitting the 32-bit-operand form with no
  REX.W prefix. A write to a 32-bit register zero-extends into the 64-bit one on
  this machine, which delivers `M32` at no instruction, so `rotl32` drops from
  four operations to one.
- **Costs:** it puts the first operation narrower than a word into a sum whose
  every member is 64-bit today, and `TalTy` has no width for it to declare
  (`lib/lowering/tal/ssa.chiral:21-22`), so the width rides the name and nothing
  checks it. `ck-instrs` types the result `tt-i64` like every other prim
  (`lib/lowering/tal/check.chiral:225`), and a value that is 32 bits by
  convention and 64 by type is the state `add32` and `rotl32` already live in at
  the source level, moved down into the machine layer where the checker sees it.
- **Forbids:** it answers `C32` and `B8` from the operation end while
  [[arcs/emitted-speed-arc]] `:252-260` leaves the 32-bit lane unscheduled, and
  the zero-extension it relies on is a second unpinned ISA fact beside the ModRM
  digits.
- **Buys:** the 320 rotations per ChaCha20 block drop from four operations to
  one, which is three quarters of the residue requirement 6 attributes to `C32`.

### Shape D: the emitter idiom alone, which is `C35`

- **Form:** recognize `(bor (shl x n) (shr x (- w n)))` in the backend and emit
  one rotate. It costs no change to the closed sum, which its own row states
  (`docs/benchmarks/OPT-CANDIDATES-2026-09.md:351`).
- **Ruled out as a disposal, by a rule rather than by cost.**
  [[working-discipline]] `:134-142` states that an operation the backend emits
  and the language does not name is P1's forgotten-syscall hole one level down,
  so recognizing an idiom in the emitter "is an implementation detail underneath
  a named primitive and never a substitute for one". The same passage names
  `op-rot` as the worked example of what a constant-time judgment can reason
  about and a fused shift-shift-or cannot. `C35` therefore cannot close `C1`.
- **Costs, measured, if it is ever built underneath a name:** the tree's
  peephole is a byte matcher over adjacent chunk pairs
  (`lib/lowering/x64/mach.chiral:1245,1285,1321`), and the idiom spans four
  `ti-prim` instructions with a stack slot between each pair. That is a
  different mechanism from the one on disk.

**The tree settles none of A, B and C.** They differ in what the language ends
up naming and at what width, and the codebase carries no rule that picks between
them. So the row is a pipeline row and a SPEC stands between the shape and the
build.

## 5. The call

- **Chosen: Shape B**, `rotl` and `rotr` as two 64-bit constructors and two
  externs.

Three reasons, in order of weight. The goal's test is taken per operation and the
machine offers two instructions, so Shape A leaves one of them emitting behind a
name no program can write and reproduces on `ror` the state `E189` just ended for
`mulhi`. Shape A's negated amount routes every right rotate through a rotate by
64, which is the one case `C34` records as unstated, so the cheaper-looking shape
is the one that makes the open question load-bearing. Shape C answers `C32` and
`B8` from the operation end, on a row whose arc does not schedule the 32-bit lane
and whose type layer has nowhere to put the width.

**What the call costs, stated rather than absorbed:**

1. **It buys the measured workload nothing.** `rotl32` stays at four operations,
   for the reason §4 works out. The 12-operation `qround` [[goals/emitted-speed]]
   `:115` computes needs `C32` as well, and requirement 6 already attributes that
   residue to a row this arc does not schedule. The element's own text has to
   carry that sentence.
2. **Two names land ahead of a built consumer**, which is the same price `E189`
   paid and priced. What earns them is the machine capability plus condition 6,
   and the one scheduled consumer, `crypto-primitives/K2`, is `open` and
   `unminted`.
3. **`C35` stays open** and this row closes none of it. Under decision 5 it is
   available later underneath the name, at the cost §4 measures.
4. **One unpinned ISA fact rides into the SPEC**, the ModRM digit assignment.
   The chosen shape is the same under either assignment, and decision 6 routes
   the byte.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Two constructors, or one with a negated amount | **RESOLVED → two.** | The machine has two instructions and [[goals/emitted-speed]] `:115` tests every one it offers. `E189` settled the parallel question for the widening multiply on the `shr`/`sar` precedent, where the reading rides the operation's name (`docs/examples/E108-shift-ops.md:74-79`, the externs at `lib/prelude/prelude.chiral:71-72`, the element at `docs/elements/catalog.md:505`). That precedent is available and does not bind, and the deciding evidence here is local: one name forces every right rotate through `(rotl x (- 64 n))`, whose `n = 0` case is a rotate by 64. Two names never reach it |
| 2 | The width | **RESOLVED → 64.** | `TalTy` carries one integer, `tt-i64` (`lib/lowering/tal/ssa.chiral:21-22`), and every one of the sum's sixteen constructors is a 64-bit operation (`lib/prelude/prelude.chiral:36-39`). A narrower operation has no type to declare its width in, so under Shape C the width rides the name and nothing checks it. The width belongs to `C32` and `B8` (`docs/benchmarks/OPT-CANDIDATES-2026-09.md:348,277`), which [[arcs/emitted-speed-arc]] does not schedule |
| 3 | What a rotate by the width or more means | **RESOLVED → `rot x n` equals `rot x (n mod 64)`, and the machine implements it with no fixup.** | This is settleable here where `C34` is not, and the asymmetry is the reason. Rotation by `n` and by `n mod w` are the same permutation of the word, so masking the count is an identity rather than a convention; for a shift, masking gives `shl x 64` the value `x` where the arithmetic reading gives 0, which is why `C34` records the shift case as open and `F34` files it under choosing semantics to fit the encoding (`docs/benchmarks/OPT-CANDIDATES-2026-09.md:350,515`). Two's-complement low-six-bits equals the least non-negative residue mod 64 for every `I64`, negative amounts included, so the rule is total. The immediate arm copies the shifts' `0..63` guard verbatim (`lib/lowering/x64/mach.chiral:977-982`) and its out-of-range fallback masks correctly |
| 4 | Whether this row settles `C34` | **RESOLVED → no, and it inherits nothing either.** | Decision 3 states the rotate's own answer from an identity, so the row neither settles the shift question nor leaves its own unanswered. `C34` stays open on `shl`, `shr` and `sar`, where the arc records a refusal as having no baseline to cite ([[arcs/emitted-speed-arc]] `:261-265`) and `F34` records the family as open. A refusal is unavailable here for the same reason `emitted-speed/X7` §6 recorded: `docs/decisions/` names no instruction set. `rol` and `ror` are in the 64-bit base, so this element needs no answer from that baseline |
| 5 | Whether the emitter idiom is part of the answer | **RESOLVED → no, and it may still be built later underneath the name.** | [[working-discipline]] `:134-142` rules that recognizing an idiom in the emitter sits beneath a named primitive and substitutes for none, and names `op-rot` as its worked example. `C35` therefore cannot dispose `C1`. Requirement 6's second half is satisfied for `C35` by that rule, which reads it as an implementation detail under a named operation rather than as a candidate owing a disposal |
| 6 | Which ModRM digit is `rol` and which is `ror` | **RESOLVED → the shape does not turn on it, and the element owes the byte a pin or an observing gate.** | The three shift encoders on disk give the opcode bytes and the `192 + 8 x digit` ModRM shape (`lib/lowering/x64/mach.chiral:325,327,335,337-338,341-342`), and the digit assignment is the one fact they do not give. Shapes A, B and C are the same under either assignment, so the decision above stands whatever the byte is. What the byte needs is either a `research` run putting an x86 source in `.planning/sources/` and a row in `records/findings.md`, which is the form `ledger-lint` check AM enforces for a quoted standard (`tools/ledger-lint/ledger-lint.py:2355-2372`), or a gate row convicting the swapped digit by observation, since `rotl x 1` and `rotr x 1` disagree on every word with exactly one bit set. The SPEC picks, and §6 sizes both |
| 7 | Whether the machine's operation set gets a bank | **RESOLVED for this run, and the bank stays owed.** | The absence is measured in §2 and already recorded by [[arcs/emitted-speed-arc]] §3. `emitted-speed/X7` §6 carries the same residue. A bank is one concept's whole refraction and no roster row in this arc holds it, so building it inside an operations row would put a doc-tier artifact in the wrong place |
| 8 | Whether this row claims the reserved `E115` slot or mints fresh | **RESOLVED → mint fresh, and the `E115` slot narrows to `bnot`.** | `E115` is a slot with no catalog row, and `docs/elements/catalog.md:590-593` records its `?` track as an author call the six CRY slots carry for a reason of their own. Claiming it would put the rotate on an unsorted track and pull an author call into a row that owes none. Its subject is also wider: it bundles `bnot`, which is `C21`, whose row wants `B6` because a complement is unary (`docs/benchmarks/OPT-CANDIDATES-2026-09.md:337`), and this row is binary. The rotate's home is CG beside `E96` and `E108` on track `SH` (`docs/elements/ledger.md:139,142`), which are the two elements the slot text itself names as what it extends |
| 9 | Whether the width decision blocks `crypto-primitives/K2` | **DEFERRED → `crypto-primitives/K2`.** | `K2` wants a 64-bit rotate per lane and this row delivers exactly that, so ordering `X8` first is what `.planning/CRYPTO-MODEL.md:512`'s `C6` asks for on the word layer. `K2` is `open` and `unminted` ([[arcs/crypto-primitives-arc]] `:125`) and it owns the refinement-typed amount `.planning/CRYPTO-MODEL.md:314` wants |

No question here is NEEDS-AUTHOR. Decision 3 was the candidate, and the identity
disposes it without an author call. Decision 8 was the second, and it is settled
by staying off the `?` track rather than by ruling on it.

## 6. The mint packet

- **Elements: one.** Both names are one edit to one closed sum across three
  `lib/` files inside the compiler's blob, each of which owes a fixpoint rebuild,
  so splitting the left rotate from the right buys two BUILD RULE cycles for one
  decision. Where two parts constrain each other, one element covers both, and
  these two are the same sum widened once. `E189` is the precedent on the same
  sum, built 2026-09-08 (`docs/elements/catalog.md:505`).
- **A register row already covers this row's subject, and it is a slot rather
  than an element.** `docs/elements/ledger.md:355` reads

  ```
  | E115 | crypto-bit-floor | rotations (`rotl`/`rotr`) + `bnot` — extends E96/E108 (CG) | ? |
  ```

  inside the CRY reserved-slot table at `:345-364`, whose header columns are
  `Slot | Module | Depends | Track`. `docs/elements/catalog.md`
  has no `E115` row, and `:590-593` states the position: the six reserved CRY
  slots E114 to E119 "are slots rather than elements, they have no catalog row",
  and their `?` track is an author call. Three consequences.
  1. `E115` is **not minted**, so the deferral rule permits naming it only as
     what it is, a reservation.
  2. Its subject is wider than this row. It bundles `bnot`, which is `C21`, and
     `C21`'s own row wants `B6` because a complement is unary
     (`docs/benchmarks/OPT-CANDIDATES-2026-09.md:337`). This row is binary and
     wants nothing from `B6`.
  3. It sits under CRY, whose track is `?`. The rotate's home is CG beside `E96`
     and `E108`, module `bit-prims`, which are the two elements the slot text
     itself names as what it extends.
  **Decision 8 mints fresh** and narrows the `E115` slot text to `bnot`. The
  highest number either register carries today is `E197`
  (`docs/elements/catalog.md`, `docs/elements/ledger.md`), so the mint takes the
  next one free above it.
- **Band:** `UNASSIGNED`. [[arcs/emitted-speed-arc]] holds no reserved block, and
  under the 2026-09-06 overlap ruling a band says where to look first and stops
  nothing ([[decisions/decision-lane-split]] `:38-62`).
- **Catalog row:**

  ```
  | E<NN> | **The rotate's two names, at 64 bits: `rotl` and `rotr`** | Not built. The closed `Op` sum carries sixteen constructors and none of them turns a word (`lib/prelude/prelude.chiral:36-39`); the extern block binds all sixteen (`:59-74`). `rotl32` spends four operations on what the machine does in one (`lib/crypto/chacha.chiral:24-25`), and `qround` calls it four times at literal amounts 16, 12, 8 and 7 (`:52-55`), which `docs/benchmarks/crypto-kernel-allocation.md:221-225` counts into 28 ops per quarter round and 35 ops per byte. The element adds `op-rotl` and `op-rotr` and binds both as `(-> I64 I64 I64)` externs, the direction riding the operation's name on the `shr`/`sar` precedent (E108, `docs/examples/E108-shift-ops.md:74-79`) and on E189's reading of it for the widening multiply. The encoders reuse the shifts' opcode group, `211` for the count-in-`cl` form and `193` for the imm8 form, differing only in the ModRM digit (`lib/lowering/x64/mach.chiral:325,327,335,337-338,341-342`); the immediate arm copies the shifts' `0..63` guard and its masking fallback (`:977-982`). **The semantics of an out-of-range amount is stated and needs no baseline:** `rot x n` equals `rot x (n mod 64)`, which is an identity of the permutation rather than a convention, so the machine's six-bit masking is correct for every `I64` amount including negatives. That is why this element settles its own case where `C34` leaves the shifts open. **What it does not buy:** nothing for ChaCha20. A 64-bit rotate leaves `rotl32` at four operations, because the wrapped bits of a 32-bit value land at bit 32 and above and a mask drops them; the 32-bit lane is `C32` and `B8` and `docs/arcs/emitted-speed-arc.md` does not schedule it. The one scheduled consumer is `crypto-primitives/K2`, `open` and `unminted`, whose Keccak-f round runs 25 rotations in ρ and 5 in θ at 64-bit lanes where the idiom costs three operations (`.planning/CRYPTO-MODEL.md:137-138,225`). `C35`, the emitter idiom, stays open and closes none of this: `docs/definitions/working-discipline.md` rules that a recognized idiom sits beneath a named primitive and names `op-rot` as the example. Residue the element carries in its own text: the ModRM digit assignment is an external ISA fact this tree pins nowhere. Three `lib/` files inside the compiler's blob, so the full BUILD RULE applies: build-new, test, promote, fixpoint verified. Designed by `emitted-speed/X8`. | `OURS`; ~E96, ~E108, ~E189 |
  ```

- **Ledger row**, into `## CG · Codegen pipeline` beside `E96` and `E108`:

  ```
  | E<NN> | bit-prims | design | **The rotate's two names, at 64 bits: `rotl` and `rotr`.** The closed `Op` sum names no rotate (`lib/prelude/prelude.chiral:36-39`) and `rotl32` spends four operations on one instruction (`lib/crypto/chacha.chiral:24-25`). The element adds `op-rotl` and `op-rotr` with the shifts' opcode group under two further ModRM digits (`lib/lowering/x64/mach.chiral:325,327,335`), binds both as `(-> I64 I64 I64)` externs with the direction riding the name on the `shr`/`sar` precedent, and states that `rot x n` equals `rot x (n mod 64)`, an identity that needs no baseline and leaves `C34`'s shift question untouched. It buys ChaCha20 nothing, because a 32-bit rotate over a 64-bit one still costs four operations; the scheduled consumer is `crypto-primitives/K2`. Three `lib/` files inside the compiler's blob, full BUILD RULE with a fixpoint. | ~E96, ~E108, ~E189 |
  ```

- **Size.** Three `lib/` files and roughly twenty-two edited lines, plus a probe
  and a gate. `lib/prelude/prelude.chiral` takes about six: two constructors into
  the sum at `:38-39`, two arms inside `op-name` (`:44-51`), and two extern lines
  after `:74`. `lib/lowering/tal/erase.chiral` takes about four: two arms in the
  `op-parse` chain (`:90-107`) with the nesting tail.
  `lib/lowering/x64/mach.chiral` takes about twelve: four byte-encoder
  definitions beside `:325-342`, two arms inside `op-bytes` (`:355-391`), two
  guarded arms inside `bini-body` (`:967-1033`) on the pattern at `:1025-1029`,
  and the comment block at `:317-318` extended. `x64-clobbers` takes nothing, per
  §2. The basis is the arm count measured in §2 against `E189`'s edit set on
  disk, doubled for the second name and reduced by the clobber key, with no
  second backend since `lib/lowering/c/` does not exist.
  The line count understates the cost. Three files inside the compiler's blob
  mean build-new, test, promote and a verified fixpoint, which is the cost
  [[arcs/native-protocol-arc]] `:111-115` named when it refused a binding on a
  zero-compiler-changes constraint.
  A probe under `prog/` and a gate under `tools/test/` are new files.
  `tools/test/mul-widen.sh` is the nearest sizing precedent at six rows and four
  mutants, and it is `E189`'s, on the same sum, landed 2026-09-08. The observable
  that distinguishes a rotate from the idiom it replaces is that the rotated-out
  bits come back: `rotl x 1` for `x` with its top bit set differs from `shl x 1`
  in bit 0. The observable that convicts a swapped ModRM digit is that
  `rotl x 1` and `rotr x 1` disagree, and the observable for decision 3 is that
  `rotl x 64` equals `x` and `rotl x 65` equals `rotl x 1`.
- **Residue this packet does not close.**
  - The machine's operation set has no bank, measured in §2. No roster row in
    this arc holds one, and `emitted-speed/X7` §6 carries the same line.
  - `C32` and `B8`, the 32-bit lane, stay open, and the ChaCha20 residue
    requirement 6 attributes to them stays.
  - `C34` stays open on the three shifts. Decision 3 settles the rotate by an
    identity and takes nothing from the shift question.
  - `C35` stays open. Decision 5 keeps it available underneath the name at the
    cost §4 measures.
  - The x86 baseline stays owed. `rol` and `ror` are in the 64-bit base so this
    element needs no answer from it, and the ModRM digit assignment is a
    separate unpinned fact routed by decision 6.
  - `E115`'s slot covers `bnot` as well as the rotations. Whichever disposition
    the mint takes, `C21` stays unscheduled and unnamed by this row.
- **Related:** [[arcs/emitted-speed-arc]], [[goals/emitted-speed]],
  [[benchmarks/OPT-CANDIDATES-2026-09]], [[benchmarks/crypto-kernel-allocation]],
  [[working-discipline]], [[elements/catalog]], [[elements/ledger]],
  [[decisions/decision-lane-split]], [[arcs/crypto-primitives-arc]],
  [[arcs/native-protocol-arc]], [[banks/INDEX]].
