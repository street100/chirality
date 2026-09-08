---
row: emitted-speed/X7
arc: emitted-speed
title: the widening multiply's shape, which is `C33`, `C17` and `C38` as one decision because they cannot be settled apart: the tree's high word is signed (`lib/lowering/x64/mach.chiral:321`) where the workload wants unsigned, and `C38`'s two-slot form is what `B15`'s single-slot return stands against. Unsigned alone, signed and unsigned as two constructors, and one operation defining two slots are the live shapes, and this row names the decision without taking it
kind: decision
origin: new
req: 5, 6
status: audited
updated: 2026-09-08
---

# emitted-speed/X7: the widening multiply's shape

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** the machine's widening multiply reaches surface source under a
  name that says which of its two products it computes, and the three in-tree
  operation sets agree on that name afterward.
- **Serves:** requirement 6 of [[arcs/emitted-speed-arc]], first half, "a rotate
  and a widening multiply reachable from surface source", and its second half,
  "every one of the 38 bucket C rows reading as a named operation, as a row
  scheduled by name under another condition, or as a refusal citing the
  baseline", which `C17`, `C33` and `C38` are three of. It also moves what
  requirement 5's gate reads: that gate "fails today on `op-mulhi`, which is the
  one difference the three sets hold", and this row decides what the difference
  becomes.
- **Goal:** [[goals/emitted-speed]] `:115`, condition 6, "Every operation the
  machine offers is named or refused, and every name the `Op` sum carries reaches
  the surface."
- **Kind:** `decision`. The deliverable is a settled shape and the operation that
  shape names. The roster's kind cell carries `decision` because what the row
  settles is which primitives exist.

## 2. What the tree holds

Measured 2026-09-08 against the live tree. Every line number below was opened on
that date, because a concurrent session has been committing and line numbers have
moved.

**Bank: none, and the absence is itself measured.** [[banks/INDEX]] `:25-37`
lists thirteen banks and none of them is the machine's operation set. `grep -rn
mulhi docs/banks/` returns nothing, and so does a grep of the same directory for
the `Op` sum and for the primitive set. [[arcs/emitted-speed-arc]] §3 records the
same absence in its own words, "the machine's operation set holds no shard
either", so the bank rule is discharged by a measurement here and the bank stays
owed. §6 carries it as residue.

### What is built

| what exists | where | rung | reached by |
|---|---|---|---|
| the `Op` sum, fifteen constructors, closed, declared by a comment as matched exhaustively by every consumer | `lib/prelude/prelude.chiral:36-39`, `op-mulhi` at `:38` | IMPLEMENTED | every stage below the erase boundary |
| `op-name`, giving `op-mulhi` the string `"mulhi"` | `lib/prelude/prelude.chiral:47-51`, the arm at `:49` | IMPLEMENTED | the clobber-key rebuild at the emit site |
| the extern block, **fourteen** lines over `I64`, holding no `mulhi` | `lib/prelude/prelude.chiral:59-72` | IMPLEMENTED | every program |
| `op-parse`, taking `"mulhi"` back into the sum at the erase boundary | `lib/lowering/tal/erase.chiral:91-107`, the arm at `:100` | IMPLEMENTED | `erase-prim` at `:153-157` |
| `op-bytes`, encoding all fifteen | `lib/lowering/x64/mach.chiral:355-391`, `op-mulhi` at `:377` | IMPLEMENTED | the tal emitter |
| **what `op-mulhi` emits**: `x-imul-rcx-1op`, the bytes `48 F7 E9`, which is `F7 /5`, the one-operand **signed** `imul`. The arm then keeps `rdx` and drops `rax` | `lib/lowering/x64/mach.chiral:321`, grouped at `:311` under the optimizer's synthetic prims, the arm at `:377`. The comment at `:313` already reads `mulhi = signed high 64 of rax*rcx`, so the sign was recorded in the backend and read by nobody upstream | IMPLEMENTED, and its sign is the finding | `op-bytes` |
| the immediate form, dispatching `op-mulhi` through the register form | `lib/lowering/x64/mach.chiral:1033` | IMPLEMENTED | `x-bini` at `:1037` |
| the clobber entry: the keys `bin:mulhi` and `bini:mulhi` mapped to the `rdx`/`rcx` set | the key dispatch at `lib/lowering/x64/mach.chiral:1455`, the set `clb-rdx-rcx` defined at `:1415`, priced by the comment at `:1395` | IMPLEMENTED | the allocator-free slot machine |
| `op-mul`, the low half: `x-imul` is `48 0F AF C1`, the two-operand `imul rax, rcx` | `lib/lowering/x64/mach.chiral:147`, the arm at `:361` | IMPLEMENTED | `op-bytes` |
| the surface path any extern takes: `expr-app` turns an `lc-prim` into an `i-prim` carrying the extern's own name as a `Str`, and `lowerable-prim?` admits everything `op-parse` accepts, ahead of the byte-library, `bget`, `blen` and `str-len` fallbacks it also admits | `lib/lowering/upper/lower.chiral:275-289`, `mk-call` at `:220`, `lib/lowering/compile-back.chiral:280-289` | IMPLEMENTED | every compile |
| the signedness precedent: `shr` and `sar` are two names over one type, both `(-> I64 I64 I64)`, and the doc states the rule as the shift kind being a **name**, where "the choice between zero-fill and sign-fill is spelled at the call site" | `lib/prelude/prelude.chiral:71-72`, `docs/examples/E108-shift-ops.md:74-79` | IMPLEMENTED, E108 | every program |

### What is absent, each proved by a grep run on 2026-09-08

| what is absent | how the absence was measured |
|---|---|
| **any unsigned `F7 /4` path in the backend.** `F7 /4` is `mul`, whose ModRM byte over `rcx` is `E1`, decimal 225 | `grep -n "b1 225" lib/lowering/x64/*.chiral` returns one line, `lib/lowering/x64/mach.chiral:627`, which is `48 83 E1 F8`, `and rcx, -8`. No other file under `lib/lowering/x64/` carries the byte |
| a second backend that would also need the arm | `lib/lowering/c/` does not exist |
| a fold law or a reference-machine arm for `mulhi` | `fold-prim` computes `+ - * / %` and answers `none` for every other name (`lib/lowering/upper/optimize.chiral:60-67`); `fold-cmp` the three comparisons (`:68-73`); `eval-prim` computes the same five and answers `v-i64 0` for everything else (`lib/lowering/tal/eval.chiral:85-95`). `mulhi` and the six bitwise operations are alike unmodelled there |
| a two-result instruction form | `ti-prim` is `(dst I64) (op Op) (a I64) (b I64)`, one destination and exactly two operands (`lib/lowering/tal/ir.chiral:21`); `erase-prim` refuses any `Op` without exactly two operands with `native prim needs 2 operands` (`lib/lowering/tal/erase.chiral:153-157`); `ti-ret` carries one `src` (`lib/lowering/tal/ir.chiral:43`); `TalSig` carries one `ret` (`lib/lowering/tal/ssa.chiral:44`) |

### What already claims this subject

**`E189` is minted, and it is `C33`.** [[elements/catalog]] `:505` and
[[elements/ledger]] `:327` carry it as **`op-mulhi` gets a surface extern: the
high half of a 64-by-64 product**, module `mul-prims`, state `design`, track
`OURS`, `~E96`, `~E108`. [[decisions/decision-lane-split]] `:33-35` records the
mint date, 2026-09-05, and that neither arc owns it. Its minted prose reads the
subject as "the one member of the sum E96/E108 left unbound" and says nothing
about what the constructor emits. `E196`'s catalog row cites it as `~E189`.

So the reading this row was opened to correct already sits in the catalog and the
ledger as an executable instruction. An implement run against `E189` as written
ships a primitive whose answer differs from the unsigned high word whenever
either operand's top bit is set.

### The recorded consumers, and their opposite signs

| consumer | which product it wants | where | state |
|---|---|---|---|
| the AI lane's fixed-point multiply-accumulate: a product between two already-scaled fixed-point values, `L_j * e_ij` in e-prop. Scaled fixed-point values carry a sign, so this consumer computes the **signed** high half | `.planning/AI-LANE-NUMERICS.md:66`, named at `:72` as one of two real arithmetic gaps and at `:96` as the follow-on the lane owes | unbuilt, and it is the agent tier |
| `C17`, "the high word of an **unsigned** product", filed against "x86 `mul` against `imul`" | [[benchmarks/OPT-CANDIDATES-2026-09]] `:333` | absent |
| the lattice arithmetic that would ask for it: `Z_q` at its moduli, modular reduction, the NTT | `crypto-primitives/K25`, [[arcs/crypto-primitives-arc]] `:148` | `open`, `unminted` |

**The one built consumer routed around the gap and stays routed around it.**
`lib/crypto/poly1305.chiral:11-14` sizes five 26-bit limbs so that "each product
in f-mul stays under 2^53" and records the consequence in its own header,
"Signed I64 holds every intermediate; no mulhi". The limbs are at `:46`. The arc
that owns that pipeline refuses the binding by name under a stated
zero-compiler-changes constraint, and says an audit finding the small-limb route
unsound "flags it instead of reaching for the binding, because the binding is a
`lib/` edit and owes a fixpoint rebuild" ([[arcs/native-protocol-arc]]
`:111-115`, with the same absence tabled at `:32`).

### The rung

[[status-ledger]] carries the native backend as `lib/lowering/x64/emit.chiral`
plus `lib/lowering/x64/mach.chiral`, "the one conforming `Mach`; all opcode and
register knowledge lives there", live in every compile. The three files a new
operation touches are inside the compiler's own blob, so the full BUILD RULE
applies to any change here: build-new, test, promote, fixpoint verified.

## 3. The delta

Subtract §2 and four things are left, of which only the first is a capability.

1. **The unsigned high word is absent from the machine layer.** One ModRM byte
   separates it from what is built (`E9` becomes `E1`), and no byte in the tree
   carries it. This is the capability half, and [[working-discipline]] `:112-124`
   is the rule that makes it a finding rather than a blocker: the workload that
   discovered it is the crypto path, and the citation that proves the absence is
   the grep in §2.
2. **Both products are absent from the surface.** The extern block binds
   fourteen of fifteen. The signed high half has a name below the surface and no
   `extern`; the unsigned one has neither.
3. **`E189` carries a false premise.** Its subject is real and its scope is
   short by exactly the finding above. Correcting it is part of this delta,
   because leaving it minted as written leaves the tree holding an executable
   instruction to build the wrong thing.
4. **The two-slot form is undecided and unowned here.** `C38` is a genuine gap
   in the IR, and `emitted-speed/X2` is the row that decides what a function may
   return. The arc records the edge at `docs/arcs/emitted-speed-arc.md:165-169`:
   "`X7` cannot settle before `X2` has answered, and the two rows are settling
   one thing from opposite ends."

Four things are **not** in the delta, and each was measured rather than assumed.

- **The IR, the erase boundary, the clobber table and the immediate form.** Each
  already carries whatever a binary `Op` constructor needs, and a new one adds an
  arm to each of the three exhaustive matches over the sum (`op-name`, `op-bytes`
  and the immediate dispatch) and one line to the `op-parse` chain.
- **The folder and the reference machine.** Neither models `mulhi` today, and
  neither models the six bitwise operations either, so a sixteenth constructor
  owes them nothing that the fifteenth already owes and has not paid.
- **A new type.** §5 decision 2 disposes this.
- **An unsigned low half.** The low 64 bits of a two's-complement product are the
  same integer under either reading of the operands, `x-imul` at
  `lib/lowering/x64/mach.chiral:147` computes them, and `C17` and `C33` ask only
  for the high word.

**Verdict: a real delta.** One machine capability, two surface names, and one
minted element to amend. The arc has already retracted the reading under which
this looked like a finishing job (`docs/arcs/emitted-speed-arc.md:188-199`).

## 4. The shapes

Three candidates. Two of them are takeable in this run and the third is owned by
another row, so the tree settles nothing and this row runs the full pipeline.

### Shape A: unsigned only

- **Form:** add `op-mulhu` to the sum with the extern `mulhu` and the bytes
  `48 F7 E1`. Leave `op-mulhi` as it is, emitting signed and reachable from no
  program.
- **Costs:** one constructor, three exhaustive arms, one `op-parse` arm, one byte
  constant, one clobber key, one extern. Three `lib/` files inside the blob, so
  one full BUILD RULE cycle with a fixpoint.
- **Forbids:** it forbids nothing at the machine layer, and it leaves the sum's
  fifteenth name unreachable. That is the exact condition goal `:115` is written
  against, and [[working-discipline]] `:144-145` names `op-mulhi` as the
  miniature case of it. Requirement 5's gate would still fail on `op-mulhi`, on
  the same constructor, for the same reason. It also strands the one recorded
  demand for the signed product and leaves `E189` with no subject.

### Shape B: signed and unsigned as two constructors

- **Form:** the machine holds two instructions, `F7 /5` and `F7 /4`, and the sum
  names two. `op-mulhi` keeps its constructor, its bytes and its emission, and
  gains the extern `mulhi`. `op-mulhu` is added beside it with the extern
  `mulhu`. Both externs are `(-> I64 I64 I64)`, which is the `sar` and `shr`
  shape verbatim (`lib/prelude/prelude.chiral:71-72`).
- **Costs:** Shape A's cost plus one extern line. Same three files, same single
  fixpoint, because the two names land in one edit to one closed sum.
- **Forbids:** it forbids reading the sign off an operand's declared type, which
  is what the tree already forbids for the two shifts. It forbids nothing the
  two-slot form wants. `C38`'s own row names four beneficiaries, `C8`, `C9`,
  `C17` and `C26` (`docs/benchmarks/OPT-CANDIDATES-2026-09.md:354`). Shape B
  closes `C17` by a separate constructor instead, so `C38`'s demand set drops to
  three and each of those three wants the second slot for something a widening
  multiply does not produce: a carry out for `C8` and `C9` (`:324-325`), and a
  128-bit pair for `C26`, the double-precision shift (`:342`).
- **What it spends against the overhead rule.** The rule is that an abstraction
  must constrain behavior or it is overhead, which this tree states at
  `docs/examples/E156-sort-adopt.md:113` and applies at
  `docs/banks/verification.md:461`. Neither extern has a built consumer on the day
  it lands. Poly1305's 26-bit limbs are the correct shape for Poly1305 and this
  row leaves them alone; the AI lane's demand is unbuilt and sits in the agent
  tier; `crypto-primitives/K25` is `open` and `unminted`. So the honest ground
  for both names is a machine capability plus two recorded demands, which is
  weaker than a workload in hand, and the element's own text has to say so.

### Shape C: one operation defining two slots

- **Form:** `C38`'s two-result prim, a widening multiply yielding the low and
  high halves together.
- **Costs:** a new IR form. `ti-prim` is single-destination and exactly binary
  (`lib/lowering/tal/ir.chiral:21`), `erase-prim` enforces the arity
  (`lib/lowering/tal/erase.chiral:153-157`), `ti-ret` carries one `src` (`:43`)
  and `TalSig` one `ret` (`lib/lowering/tal/ssa.chiral:44`). Every consumer of
  `TInstr` and `TCode` moves with it, and `C38`'s own row names `B15` as what it
  depends on (`docs/benchmarks/OPT-CANDIDATES-2026-09.md:354`, and `B15` itself
  at `docs/benchmarks/OPT-CANDIDATES-2026-09.md:284`).
- **Buys:** one multiply where Shape B costs two. The one-operand form already
  computes both halves into `rdx:rax` and the current arm discards `rax`
  (`lib/lowering/x64/mach.chiral:377`), so the saving is real and it is one
  instruction. Both halves are reachable under Shape B as `(mul a b)` and
  `(mulhu a b)`, at the price of computing the product twice.
- **Forbids:** taking it here would settle what `emitted-speed/X2` owns, on a
  row that reaches the question from the operation end. The arc records that edge
  as the reason condition 6 sits in this arc at all
  (`docs/arcs/emitted-speed-arc.md:165-169`).

**The tree settles none of the three.** Two live shapes remain after Shape C is
deferred, they differ in what the language ends up naming, and the codebase
carries no rule that picks between them. So the row is a pipeline row, and a
SPEC stands between the shape and the build. §6 names the route it takes, which
is shorter than the default one because the element it needs is already minted.

## 5. The call

- **Chosen: Shape B**, signed and unsigned as two constructors and two externs.

The reason is the goal's own test, which is taken per operation. The machine
offers `mul` and `imul` and the sum names one of them. Shape A closes half of
that and leaves the other half emitting behind a name no program can write, which
reproduces the hole [[working-discipline]] `:134-146` describes and keeps
requirement 5's gate red on the same constructor it is red on today. Shape C
buys one instruction and answers a question `emitted-speed/X2` owns.

**What the call costs, stated rather than absorbed:**

1. Two names land ahead of any built consumer, and §4 prices that against the
   overhead rule. What earns them is a machine capability and a goal condition,
   and the element text has to carry that sentence instead of implying a
   workload is waiting.
2. The unsigned high word can come back with its top bit set, and every
   comparison and division in the sum is signed. So `(mulhu a b)` can produce a
   value that `<i` orders wrongly. Decision 3 below disposes it.
3. `E189` is spent as minted and has to be amended before anything is built
   against it. Decision 5 routes that.
4. Shape B pays two multiplies where the machine could pay one. That price is
   recoverable later by `C38`, and Shape A pays the same price meanwhile.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Signed, unsigned, or both | **RESOLVED → both.** | [[goals/emitted-speed]] `:115` tests every operation the machine offers, and [[working-discipline]] `:134-146` fixes the form of the answer: an operation the backend emits that the language cannot write is P1's hole one level down. The machine offers two. Shape A leaves one of them in that state |
| 2 | What type does an unsigned high word return into, when `I64` is signed and every extern in the block is typed over it | **RESOLVED → `(-> I64 I64 I64)`, the same type the signed one takes.** | E108 settled the general rule for exactly this collision and the tree has run on it since: `shr` and `sar` are two total `(-> I64 I64 I64)` externs, the shift kind is a **name**, and "the choice between zero-fill and sign-fill is spelled at the call site" (`docs/examples/E108-shift-ops.md:74-79`, the externs at `lib/prelude/prelude.chiral:71-72`). The reading of the operands belongs to the operation's name and the word is a bit pattern under both. A signedness-carrying type would put the choice back into a declaration the reader may not be looking at, which is the C shape E108 records and refuses (`docs/examples/E108-shift-ops.md:59-72`) |
| 3 | Whether the unsigned result is usable without an unsigned comparison | **RESOLVED → yes, at a residue the tree already carries.** | `shr`, `band`, `bor`, `bxor` and `shl` can each set the top bit today, so a word whose unsigned meaning exceeds the signed range is already producible and already orders wrongly under `<i`. `mulhu` adds a producer of that residue and no new kind of it. `C13`, the unsigned less-than, is what closes it, and [[arcs/emitted-speed-arc]] `:180-186` already disposes `C13` as a finishing job consumed as ordinary work, because `op-lti` gives it a shape to copy. The element text owes the residue in its own words |
| 4 | Whether the widening multiply defines two slots | **DEFERRED → `emitted-speed/X2`.** | `C38` names `B15` as its dependency ([[benchmarks/OPT-CANDIDATES-2026-09]] `:354`, `:284`) and `X2` is the row that decides what a function may return. Shape B leaves `C38` open and takes nothing from it. `C38`'s row names `C8`, `C9`, `C17` and `C26` as what the two-slot form would let exist (`:354`); Shape B closes `C17` by a separate constructor, and the other three still want the second slot for something a widening multiply does not produce, a carry out for `C8` and `C9` (`:324-325`) and a 128-bit pair for `C26` (`:342`) |
| 5 | Whether this row mints a fresh number or amends `E189` | **DEFERRED → `E189`, through a `revisit` run.** | `E189` is minted, its state is `design` and nothing is built against it ([[elements/catalog]] `:505`, [[elements/ledger]] `:327`). Its subject is this subject, measured short. `revisit` is the run this tree built for a settled artifact against a named trigger and its verdict set already holds `AMEND` and `RESCOPE`, so no author call is owed. The trigger is the 2026-09-08 measurement in §2. `E187` is the in-tree precedent for re-scoping an unbuilt element in place ([[elements/catalog]] `:503`) |
| 6 | Whether the machine's operation set gets a bank | **RESOLVED for this run, and the bank stays owed.** | The absence is measured in §2 and already recorded by [[arcs/emitted-speed-arc]] §3. A bank is one concept's whole refraction and no roster row in this arc holds it; `X7` is one operation and building the bank inside it would put a doc-tier artifact inside an operations row. Carried as residue in §6 |
| 7 | Whether the low half needs an unsigned twin | **RESOLVED → no.** | The low 64 bits of a two's-complement product are the same integer under either reading, `x-imul` at `lib/lowering/x64/mach.chiral:147` computes them, and `C17` and `C33` ask only for the high word |

No question here is NEEDS-AUTHOR. Decision 5 was the candidate, and `revisit`
disposes it inside the pipeline.

## 6. The mint packet

- **Elements: one, and it is already minted.** `E189`, amended. The two externs
  and the new constructor are one edit to one closed sum in three files inside
  the compiler's blob, and each of those files owes a fixpoint rebuild, so
  splitting the signed name from the unsigned one buys two BUILD RULE cycles for
  one decision. Where two parts constrain each other, one element covers both,
  and these two parts are the same `Op` sum widened once.
- **The route, and what it means for the mint step.** This row does not allocate
  a number. It goes design, audit, then a `revisit` run on `E189` against the
  trigger in §2, then spec, audit, implement. If that revisit lands `RESCOPE` or
  `AMEND`, the rows below replace `E189`'s and the roster's element cell for
  `emitted-speed/X7` reads `E189`. If it lands `SUPERSEDE`, the same two rows
  mint under the next number free tree-wide and `E189` is retired against them.
- **Band:** `UNASSIGNED`. [[arcs/emitted-speed-arc]] holds no reserved block, and
  under the 2026-09-06 overlap ruling a band says where to look first and stops
  nothing ([[decisions/decision-lane-split]] `:38-62`). `E189` sits in Lane A's
  spent `E184-E189` range and keeping it there costs nothing.
- **Catalog row**, replacing `docs/elements/catalog.md:505`:

  ```
  | E189 | **The widening multiply's two names: `mulhi` signed, `mulhu` unsigned** | Not built. The `Op` sum carries `op-mulhi` (`lib/prelude/prelude.chiral:36-39`, the constructor at `:38`) and the extern block binds fourteen of the fifteen (`:59-72`). Measured 2026-09-08: `op-mulhi` emits `x-imul-rcx-1op`, the bytes `48 F7 E9` (`lib/lowering/x64/mach.chiral:321`, reached at `:377`), which is `F7 /5`, the one-operand SIGNED `imul`, and a grep for the unsigned `F7 /4` form over `lib/lowering/x64/` returns nothing. So binding the constructor that exists names the signed high half and leaves the unsigned one absent from the machine layer, one ModRM byte away. The element adds `op-mulhu` with the bytes `48 F7 E1`, and binds both names as `(-> I64 I64 I64)` externs on the `shr`/`sar` precedent, where the reading of the operands rides the operation's name (E108, `docs/examples/E108-shift-ops.md:74-79`). Two recorded demands, one per sign: `.planning/AI-LANE-NUMERICS.md:66` wants the signed half for fixed-point multiply-accumulate, and `C17` wants the unsigned one, landing in `crypto-primitives/K25`, which is open. Neither is built on the day this lands, and what earns the pair is the machine capability plus `docs/goals/emitted-speed.md:115`. Residue carried in the element's own text: an unsigned high word can return with its top bit set and every comparison in the sum is signed, which `C13` closes and which `shr`, `band`, `bor`, `bxor` and `shl` already produce. Two slots stay out of scope and belong to `C38` through `emitted-speed/X2`. Three `lib/` files inside the compiler's blob, so the full BUILD RULE applies: build-new, test, promote, fixpoint verified. Designed by `emitted-speed/X7`. | `OURS`; ~E96, ~E108 |
  ```

- **Ledger row**, replacing `docs/elements/ledger.md:327`:

  ```
  | E189 | mul-prims | design | **The widening multiply's two names: `mulhi` signed, `mulhu` unsigned.** `op-mulhi` sits in the closed `Op` sum (`lib/prelude/prelude.chiral:36-39`) and emits the one-operand signed `imul`, `48 F7 E9` (`lib/lowering/x64/mach.chiral:321`, reached at `:377`); no unsigned `F7 /4` path exists anywhere under `lib/lowering/x64/`, measured 2026-09-08. The element adds `op-mulhu` with `48 F7 E1` and binds both as `(-> I64 I64 I64)` externs, signedness riding the name on the `shr`/`sar` precedent. Re-scoped from "`op-mulhi`'s surface extern" by `emitted-speed/X7`, whose §2 measured the original subject short: binding what exists ships the signed product where `C17` asks for the unsigned one. Three `lib/` files, full BUILD RULE with a fixpoint. | ~E96, ~E108 |
  ```

- **Size.** Three `lib/` files and roughly fourteen edited lines, plus a probe
  and a gate. `lib/prelude/prelude.chiral` takes about four: one constructor into
  the sum at `:38-39`, one arm at `:49` inside `op-name` (`:44-51`), and two
  extern lines after `:72`. `lib/lowering/tal/erase.chiral` takes about two: one
  arm in the `op-parse` chain at `:91-107`, with the nesting tail.
  `lib/lowering/x64/mach.chiral` takes about eight: one byte constant beside
  `:321`, one arm at `:377` inside `op-bytes` (`:355-391`), one immediate arm at
  `:1033`, one clobber key at `:1455`, and the two comment blocks at `:311-313`
  and `:1395` extended to name the second operation. The basis is the arm count
  measured in §2: three exhaustive matches over the sum, one `op-parse` chain,
  one clobber key, and no second backend, since `lib/lowering/c/` does not exist.
  A probe under `prog/` and a gate under `tools/test/` are new files whose
  observable is that `mulhi` and `mulhu` disagree on an operand with its top bit
  set; `tools/test/encoding.sh` is the nearest sizing precedent at five rows
  and four mutants.
  The line count understates the cost. Three files inside the compiler's blob
  mean build-new, test, promote and a verified fixpoint, which is the cost
  [[arcs/native-protocol-arc]] `:111-115` named when it refused the binding.
- **Residue this packet does not close.**
  - The machine's operation set has no bank, measured in §2. No roster row holds
    one.
  - `C13`, the unsigned less-than, is what makes an unsigned high word orderable.
    [[arcs/emitted-speed-arc]] `:180-186` disposes it as a finishing job and this
    row leaves that disposal standing.
  - `C38` and the two-slot form stay open, owned by `emitted-speed/X2`.
  - `C10`, `C11` and `C34` record that no document names the instruction set the
    emitted code may assume. `F7 /4` is in the 64-bit base, so this element needs
    no answer from that baseline, and the baseline stays owed.
- **Related:** [[arcs/emitted-speed-arc]], [[goals/emitted-speed]],
  [[benchmarks/OPT-CANDIDATES-2026-09]], [[working-discipline]],
  [[elements/catalog]], [[elements/ledger]], [[decisions/decision-lane-split]],
  [[arcs/native-protocol-arc]], [[arcs/crypto-primitives-arc]].
