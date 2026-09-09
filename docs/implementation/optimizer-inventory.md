---
node: implementation-optimizer-inventory
layer: implementation
related: [implementation/README, implementation/reg-disciplines, implementation/rd-packed-cert, benchmarks/README, benchmarks/OPT-LEDGER, benchmarks/OPTIMIZATIONS-TODO, benchmarks/OPT-CHECKLIST, arcs/enforcement-arc, index]
status: measured
updated: 2026-09-08
---

# The optimization surface of the self-hosted compiler

An inventory taken at `ea31370` on 2026-09-07 and re-measured against
`8c72746` on 2026-09-08. It answers what is here. It ranks nothing, proposes
nothing, and names no gap. Where something is absent the absence is recorded
with the command that establishes it.

The subject is the compiler that `prog/compiler.prog` lowers to: the binary at
`bin/chirality-bin`, 1,220,984 bytes, sha256 prefix `3b0f809a96fe84cde7289d40`,
over a blob of 841,089 bytes as assembled by `bin/chirality-resolve.sh` from
`lib:prog`. Both figures were taken on 2026-09-08. The survey read 1,241,464
bytes at `7d971a30c0bfda52fc2d952b` over a blob of 855,545 bytes on 2026-09-07,
before `lowering/tal/check` left the compiler closure at `b613a8f` and before
E189 landed at `c86b007`.

## 1. Every pass that exists

`prog/compiler.prog:16-20` reads source from fd 0, calls `compile-all`, and
writes the ELF to fd 1. `compile-all` (`lib/lowering/compile-all.chiral:18`)
is three calls in sequence: `compile-front` at `:20`, `back-program` at `:23`,
`emit-elf-m` at `:34`.

Seventeen transformations run on the way from text to bytes, and four gates sit
between them. A gate rewrites nothing and answers a verdict. A fifth stood
between passes 8 and 9 until 2026-09-08, and the row for pass 8 records where it
went.

### The front half, `compile-front` (`lib/lowering/compile-front.chiral:366-373`)

| # | Pass | Seat | Consumes | Produces | What it does |
|---|---|---|---|---|---|
| 1 | `read-all-str` | `lib/surface/parse.chiral:1431` (inside `load-source`) | source `Str` | s-expression forms | reader |
| 2 | `load-source-batched` | `lib/module/load-batch.chiral:97` over `load-source` at `lib/surface/parse.chiral:1431` | forms | `Sig` | porttype install, data group elaboration, then every form in source order, elaborated and typechecked into the signature |
| G1 | `tot-gate` | `lib/typing/totality-check.chiral:153` | `Sig` | `TotalR` | the `(total)` profile gate. A source declaring no `(total)` profile classifies no def |
| 3 | `specialize-singletons` | `lib/lowering/upper/specialize-singleton.chiral:229` | `Sig` | `Sig` | monomorphizes a function-bearing record built exactly once. Fields lift to globals, projector applications rewrite to the lifted target (`sp-rw`, `:124-132`), the dictionary parameter is retyped `q=0` (`q0-dom`, `:155`), and dead globals are pruned (`drop-pruned`, `:228`) |
| 4 | `closconv-sig` | `lib/lowering/upper/closconv-driver.chiral:280` | `Sig` | `CCOut` | defunctionalization. `collect` (`lib/lowering/upper/closconv.chiral:979`) finds the families, `synth-fams` (`lib/lowering/upper/closconv-driver.chiral:223`) mints one `$clo<i>` data type and one `$apply<i>` dispatcher per family, and `rw` (`lib/lowering/upper/closconv.chiral:1325`) rewrites every body. A refused family rides out as an `SkRec` list |
| 5 | `peel-globals` | `lib/lowering/compile-front.chiral:227` | `Sig` globals | `(List NDef)` | Pi-chain peel to ground `NTalTy` (`term->ntalty`, `:60`) and body peel to neutral `NCore` (`term->ncore`, `:107`). Arguments at a callee's `q=0` positions are dropped at every call site (`tnc-keep`, `:136`). A def whose type or body does not peel is dropped |

`datas->n` (`:255`) and `prims->n` (`:335`) peel the data declarations and the
pure externs alongside. `ports-manifest` (`:296`) intersects the declared
profiles into one permitted port set.

### The back half, `back-program` (`lib/lowering/compile-back.chiral:332-336`)

| # | Pass | Seat | Consumes | Produces | What it does |
|---|---|---|---|---|---|
| 6 | `program-lits` | `lib/lowering/compile-back.chiral:124` | `(List NDef)` | `(List Str)` | interns every string literal, first-occurrence order, deduped through an ordered `Map` (`dedup-str`, `:118`) |
| 7 | `compile-fn` | `lib/lowering/upper/lower.chiral:412` | `LCore` | `TFn` plus outlined extras | typed SSA emission. A monotonic `ssa-fresh` counter (`:161`) gives single assignment. A non-tail `case` is outlined into a synthesized `<name>$<n>` function whose parameters are the enclosing binder env plus the scrutinee (`outline`, `:311`). An erased `q=0` binder gets a defined placeholder (`build-binders`, `:398`) |
| 8 | `fold`, adopted unjudged | `lib/lowering/compile-back.chiral:247` (`opt-tfns`), transform at `lib/lowering/upper/optimize.chiral:140` | `TFn` | `TFn` | constant folding and propagation over a per-block register environment, comparison folding to a nullary `Bool` constructor, and static case dispatch on a known constructor (`dispatch`, `lib/lowering/upper/optimize.chiral:130`). `opt-tfns` applies `(fold t)` and adopts the residual with no verdict to consult. The `chk-ok` guard that stood here until 2026-09-08 is gone by the author's ruling in `records/lenses/problems.md` PRB-70, which keeps `lowering/tal/check` outside the compiler closure; the header at `lib/lowering/compile-back.chiral:235-245` records that forcing that guard to answer `chk-ok` emitted a byte-identical blob, and routes the census to `prog/optimizer-census.prog` |
| 9 | `filter-erasable` | `lib/lowering/compile-back.chiral:185` | `(List TFn)` | kept `TFn`s plus `SkRec`s | dry-run erase; a function carrying a prim outside the native subset is dropped with the offending op named |
| 10 | `prune-fix` | `lib/lowering/compile-back.chiral:214` | `(List TFn)` | kept `TFn`s plus `SkRec`s | fixpoint cascade: a function calling a label no longer present is dropped, and its callers with it |
| 11 | `erase-fn` | `lib/lowering/tal/erase.chiral:272` | `TFn` | `NFn` | drops the `TalTy` annotations, flattens `Block`/`TalTerm` into seq-structured code, resolves a constructor name to its declaration-order tag (`ctor-tag`, `:59`), decides immediate against boxed (`is-enum`, `:75`), parses a prim op name once into the closed `Op` sum (`op-parse`, `:91`), routes every other lowerable prim to a `nb-*` library call (`prim2lib`, `:140`), and rewrites a bound crossing into a call of its E51 wrapper (`erase-instr-onto`, `:213`) |

### The emit half, `emit-elf-m` (`lib/lowering/compile-emit.chiral:292-323`)

| # | Pass | Seat | Consumes | Produces | What it does |
|---|---|---|---|---|---|
| 12 | `reify-fn` | `lib/lowering/tal/reify.chiral:55` | `NFn` | `TIFn` | a total 1:1 rebuild across the two colliding namespaces |
| 13 | link | `lib/lowering/compile-emit.chiral:295` | object `TIFn`s | one image | prepends `native-lib` (`lib/lowering/tal/bytes.chiral:636`) and `link-lib` (`lib/lowering/tal/sys-linkage.chiral:98`) |
| G2 | `ck-tiprog` | `lib/lowering/tal/sys-check.chiral:72` | the whole image | `SysR` | H7, the syscall chokepoint. Every `ti-sys` must name a registered function with a matching number |
| G3 | `manifest-offender` | `lib/lowering/compile-emit.chiral:260` | object fns plus the port manifest | `Maybe Str` | H8, the declared profile's frozen port set |
| G4 | `first-dup-go` | `lib/lowering/compile-emit.chiral:177` | the image | `Maybe Str` | refuses a label collision between object code and the linked runtime |
| 14 | `emit-program` | `lib/lowering/mach/emit-core.chiral:537` | `(List TIFn)` | `(List Asm)` | target-independent codegen against the `Mach` record. Five selection rewrites live inside it and are tabled below |
| 15 | `x64-peep` | `lib/lowering/x64/mach.chiral:1321` | `(List Asm)` | `(List Asm)` | byte-level peephole. Pattern A (`peep-hit`, `:1245`) drops a `mov rax,[slot]` that follows a `mov [slot],rax` on the same displacement. Pattern B (`peep-hit-rcx`, `:1285`) turns the rcx reload into a three-byte `mov rcx,rax` |
| 16 | `assemble` | `lib/lowering/mach/asm-reloc.chiral:161` | `(List Asm)` | `(Pair Bytes offsets)` | label placement then relocation resolution against an ordered `Map` |
| 17 | `assemble-elf` | `lib/lowering/compile-emit.chiral:142` | code bytes | ELF bytes | prepends the 224-byte entry stub (`entry-stub-v2`, `:59`), which reserves 64 GiB `PROT_NONE`, commits a 256 KiB prefix, stores the four arena cells, and calls the entry |

### The transformations inside `emit-program`

These five run during instruction selection. Each is a pattern match on the
erased IR, and each has a `Mach` face op behind it.

| Rewrite | Recognizer | Machine op | What it replaces |
|---|---|---|---|
| immediate operand folding | `cenv-get` in `emit-instr`, `lib/lowering/mach/emit-core.chiral:146-161`; fact update at `cenv-step`, `:46` | `bini` / `binir` | a slot load of a second operand that a preceding `ti-const` defined. `bini-body` (`lib/lowering/x64/mach.chiral:967`) picks the imm32 encodings, and falls back to materializing the constant in rcx |
| lookup table | `table-of`, `lib/lowering/mach/emit-core.chiral:288` | `ltb` (`lib/lowering/x64/mach.chiral:1101`) | a compare chain over an unboxed enum whose arms all bind nothing and return a constant. No bounds check, because tags are dense by declaration order |
| jump table | `jtb-codes`, `lib/lowering/mach/emit-core.chiral:337` | `jtb` (`lib/lowering/x64/mach.chiral:1165`) | the compare chain for four or more non-constant arms over a dense unboxed scrutinee |
| fused compare and branch | `fused-of`, `lib/lowering/mach/emit-core.chiral:379` | `fcp` / `fci` / `fjc` (`lib/lowering/x64/mach.chiral:1185`, `:1189`, `:1221`) | setcc, the bool slot write, and the reload. One cmp feeds both `Bool` arms |
| tail call | `tail-call-of`, `lib/lowering/mach/emit-core.chiral:428` | `tca` (`lib/lowering/x64/mach.chiral:1055`) | call plus epilogue, for the shape `(t-seq (ti-call dst f args) (ti-ret dst))`. Demoted to call plus ret past six arguments |

### Transformations that live inside the x64 target

`lib/lowering/x64/mach.chiral` carries instruction selection that no
target-independent pass sees.

| Transformation | Seat | Condition |
|---|---|---|
| power-of-two strength reduction | `pow2-k` at `lib/lowering/x64/mach.chiral:891`, used by `x-div-imm` (`:911`) and `x-mod-imm` (`:931`) | a constant divisor that is a power of two. Euclidean division makes `sar` and `and` exact with no correction |
| constant-divisor guard elision | `x-div-imm` (`:911`) and `x-mod-imm` (`:931`) | a constant divisor outside `{0, -1}` drops the test/ud2 and the cmp/-1 branch. `d = 1` and `d = -1` collapse with no idiv. `d = 0` keeps the deliberate trap |
| byte-op inlining | `erase-prim` at `lib/lowering/tal/erase.chiral:152-168` | `bget`, `blen` and `str-len` become the machine ops `n-bget` and `n-blen` instead of calls into the one-instruction `nb-*` wrappers |

### What is compiled in and never called

| Symbol and seat | What it is | Evidence |
|---|---|---|
| `dead` (`lib/lowering/upper/optimize.chiral:192`) | the DCE pass | `opt-tfns` ships `(fold t)`. The header at `lib/lowering/compile-back.chiral:225-233` records the measurement: wired whole, the compiler miscompiles itself at `293 passed, 98 failed`, `fold` alone grades `42 passed, 0 failed` and `dead` alone `33 passed, 9 failed` |
| `optimize` (`lib/lowering/upper/optimize.chiral:263`) | the whole pipeline, `dead (fold fn)` | grep for `(optimize ` across `lib` and `prog` returns nothing |
| `specialize` (`lib/lowering/upper/optimize.chiral:265`), `specialize-raw` (`:249`), the `rmap-*` renaming family (`:195-223`) | partial evaluation and its SSA renamer | grep for `(specialize ` across `lib` and `prog` returns only comment lines. `(def rmap-block` is present in the compiler blob exactly once and reachable from `specialize-raw` alone |
| `emit-truthful` (`lib/lowering/x64/emit.chiral:8`) and `emit-param` (`:14`) | the two unreachable emit entries | `emit-elf-m` calls `emit` (`:11`). grep for `emit-param` and `emit-truthful` across `lib`, `prog`, `tools` and `bin` returns their definitions and documentation references, no call site |
| `row-check` (`lib/lowering/upper/eff-lower.chiral:144`), `eff-gate` (`:175`), `sysface` (`:155`) | the effect-row half | the only importer is `lib/module/sig-driver.chiral:24`, which nothing on the compile path imports. `grep -c "(def row-check"` over the compiler blob returns 0 |
| `conform-vecs` (`lib/lowering/tal/spec.chiral:71`) and `tal-spec` (`:125`) | the spec-as-golden half | no module under `lib` or `prog` imports `lowering/tal/spec`. `grep -c "(def conform-vecs"` over the compiler blob returns 0 |
| `lib/lowering/tal/eval.chiral` and `lib/lowering/listing/mach.chiral` | the tal interpreter and the listing target | `grep -rn 'import "lowering/tal/eval"'` and the same for `lowering/listing/mach` over `lib` and `prog` return nothing |

## 2. What the IR affords

An absence recorded in this section is a fact about what this substrate reaches
today, and `docs/definitions/working-discipline.md` rules on how such a record
is read. Nothing here is a shortfall against another compiler, and no reference
implementation stands behind these lines.

### The two TAL instruction sets

There are two, joined by erasure. `lib/lowering/tal/ssa.chiral` is the typed
SSA form that lowering produces and that `ck-fn`
(`lib/lowering/tal/check.chiral:290`) is written against; since 2026-09-08 that
checker runs from `prog/optimizer-census.prog` alone, outside the compiler
closure. `lib/lowering/tal/ir.chiral` is the type-erased form the emitter
consumes.
`lib/typing/erased-nf.chiral` is the neutral transport between them.

| IR | Types | Instructions | Terminators |
|---|---|---|---|
| typed SSA, `lib/lowering/tal/ssa.chiral:21-50` | `TalTy` at `:21-22`: `tt-i64`, `tt-str`, `tt-bytes`, `tt-word`, `tt-data`. Five | `Instr` at `:26-34`: `i-const`, `i-prim`, `i-call`, `i-con`, `i-bnew`, `i-bget`, `i-bput`, `i-blen`. Eight | `TalTerm` at `:38`: `t-ret`, `tt-case`. `Block` at `:37` pairs an instruction run with one terminator |
| erased, `lib/lowering/tal/ir.chiral:19-49` | none. The annotations are gone | `TInstr` at `:19-34`: `ti-const`, `ti-prim`, `ti-con`, `ti-cona`, `ti-call`, `ti-lit`, `ti-bnew`, `ti-bget`, `ti-bput`, `ti-blen`, `ti-sys`, `ti-bptr`. Twelve | `TCode` at `:41-46`: `t-seq`, `ti-ret`, `ti-tcase` |
| neutral, `lib/typing/erased-nf.chiral:26-47` | none | `NInstr` at `:26-36`. Ten, the subset a lowered pure function can reach. No `ti-sys`, no `ti-bptr` | `NCode` at `:40-45` |

`tt-word` is representation-compatible with every one-word type, checked by
`tal-ty=?` (`lib/lowering/tal/check.chiral:68-70`).

Both instruction sets have no move or copy form, no phi, no explicit label or
jump form, no loop form, and no float or sub-word integer type. A `Bytes`
payload is reached only through `ti-bget`, `ti-bput`, `ti-blen` and `ti-bptr`.
There is no field-update instruction: `ti-cona` is the only way to write a
cell's fields, and it always allocates a fresh one.

### The closed `Op` sum

`lib/prelude/prelude.chiral:36-39` declares sixteen constructors. A
`ti-prim` carries an `Op`, so every consumer matches it exhaustively.

| Constructor | Surface binding | Where |
|---|---|---|
| `op-add`, `op-sub`, `op-mul`, `op-div`, `op-mod` | `+`, `-`, `*`, `/`, `%` | `lib/prelude/prelude.chiral:59-63` |
| `op-eqi`, `op-lti`, `op-lei` | `=i`, `<i`, `<=i` | `lib/prelude/prelude.chiral:64-66` |
| `op-band`, `op-bor`, `op-bxor` | `band`, `bor`, `bxor` | `lib/prelude/prelude.chiral:67-69` |
| `op-shl`, `op-shr`, `op-sar` | `shl`, `shr`, `sar` | `lib/prelude/prelude.chiral:70-72` |
| `op-mulhi`, `op-mulhu` | `mulhi`, `mulhu` | `lib/prelude/prelude.chiral:73-74` |

So all sixteen have a surface binding, and they have had one since E189 landed
at `c86b007` on 2026-09-08. `op-mulhi` encodes the one-operand signed `imul` at
`lib/lowering/x64/mach.chiral:321`, reached at `:377`; `op-mulhu` encodes the
one-operand unsigned `mul` at `:323`, reached at `:379`; both take the clobber
entry at `:1455-1456`, documented at `:1395-1397`; and `op-parse`
(`lib/lowering/tal/erase.chiral:91`) accepts both strings at `:100-101`.
`grep -rniI "mulhi" lib prog` now finds it in `lib/prelude/prelude.chiral`,
`lib/lowering/x64/mach.chiral`, `lib/lowering/tal/erase.chiral`, the header of
`lib/crypto/poly1305.chiral` and `prog/e189-widening-multiply.prog`, so a source
program produces one.

⚑ `docs/definitions/working-discipline.md:144-145` still reads that `op-mulhi`
is "present in the sum, emitted by the backend, and reachable from no surface
binding". The externs at `lib/prelude/prelude.chiral:73-74` are what that
sentence says does not exist. The source is the authority above this document
and this row follows it; the sentence in the definitions tier is left for its
own audit.

### How a call is represented

| Stage | Form | Seat |
|---|---|---|
| surface / `LCore` | `lc-app` spine, flattened by `spine` | `lib/lowering/upper/lower.chiral:213` |
| typed SSA | `i-call dst f srcs ty` for a global, `i-prim dst op srcs ty` for an extern | the choice is made by `mk-call` (`lib/lowering/upper/lower.chiral:220`) inside `emit-call` (`:285`) |
| neutral | `n-call dst fname args` | `lib/typing/erased-nf.chiral:31` |
| erased | `ti-call dst fname args` | `lib/lowering/tal/ir.chiral:24` |
| bytes | `mach-cal`, which owns register args and the SysV stack zone past six | `lib/lowering/x64/mach.chiral:1648` |

A higher-order application does not lower. `expr-app`'s default arm answers
`er-skip "higher-order application"` (`lib/lowering/upper/lower.chiral:283`),
which is why `closconv-sig` runs first.

No pass inlines a function body into a caller. Three rewrites replace a call
with something else, and none of them copies a body:

- `erase-prim` (`lib/lowering/tal/erase.chiral:152-168`) turns `bget`, `blen`
  and `str-len` into single machine ops instead of calls into the `nb-*`
  wrappers whose whole body is that one op.
- `sp-rw` (`lib/lowering/upper/specialize-singleton.chiral:124-132`) collapses
  a projector application on the singleton dictionary into a direct reference
  to the lifted global. This is devirtualization at the `Term` level.
- `tail-call-of` (`lib/lowering/mach/emit-core.chiral:428`) turns a call in
  tail position into a frame teardown and a jump.

### How a closed product is represented, and where the allocation is introduced

`(data Q4 () (q4 (qa I64) (qb I64) (qc I64) (qd I64)))` at
`lib/crypto/chacha.chiral:48` is the worked case, with `St` at `:42-45`.

| Stage | Representation | Seat |
|---|---|---|
| `Sig` | `DataDecl` with one `Ctor` and its `Field` list | `lib/module/loader.chiral`, built by `load-source` |
| neutral `NData` | `datas->n` peels each field type through `term->ntalty`. A data type with one field that does not peel is dropped whole | `lib/lowering/compile-front.chiral:239-261` |
| lowering `DData` | `ndatas->ddatas` rebuilds `DCtor`/`DData` | `lib/lowering/compile-back.chiral:71-74` |
| typed SSA | `i-con dst dn cn srcs (tt-data dn nil)`, one instruction, arguments evaluated left to right by `expr-args` | `lib/lowering/upper/lower.chiral:291-299` (`expr-con`) |
| erased | `is-enum` decides. Every constructor nullary gives `n-con dst tag`, an immediate word. Any fielded constructor boxes the whole type and gives `n-cona dst tag srcs` | `lib/lowering/tal/erase.chiral:69-83`, `:193-197` |
| tal-ir | `ti-cona dst tag fields` | `lib/lowering/tal/ir.chiral:23` |
| bytes | `emit-instr`'s `ti-cona` arm calls `alo-cell` on the `Alloc` record | `lib/lowering/mach/emit-core.chiral:151` |

The allocation is introduced at `i-con` and becomes machine code at
`alo-cell`. The live `Alloc` instance is `alloc-growing`
(`lib/memory/alloc-growing.chiral:18`), bound in `lib/lowering/x64/emit.chiral:11`,
so `alo-cell` is `x-galo` (`lib/lowering/x64/mach.chiral:515`). The size is
decided by one expression, `(let (sz (* 8 (+ 1 (length I64 fs))))` at
`lib/lowering/x64/mach.chiral:517`: one word for the tag plus one word per
field. Four fields give 40 bytes, sixteen fields give 136.

Reproduced 2026-09-07 by `tools/bench/crypto-kernel.sh sites`, which counts the
`lea rcx,[rax+sz]` bytes in the emitted ELF for the block subject:

```
   lea rcx,[rax+ 40]  x2  = 1 allocation site(s)   Q4  4 fields
   lea rcx,[rax+136]  x6  = 3 allocation site(s)   St 16 fields
```

The static-arena instance `alloc-fixed` (`lib/memory/alloc-fixed.chiral`) has
zero importers, recorded at `lib/memory/alloc.chiral:5-7`. Its `x-alo`
counterpart computes the same size at `lib/lowering/x64/mach.chiral:489`. The
arena reclaims nothing: `heapptr` only advances.

### Loops, and back-edges

There is no loop form. `TCode` (`lib/lowering/tal/ir.chiral:41-46`) has three
constructors and none of them is a loop, a branch target, or a fallthrough.
`Block`/`TalTerm` (`lib/lowering/tal/ssa.chiral:37-39`) is a tree: every arm
ends the block and branches never rejoin. Iteration is tail recursion.

One place identifies a back-edge. `tail-call-of`
(`lib/lowering/mach/emit-core.chiral:428`) matches
`(t-seq (ti-call dst f args) (ti-ret dst))` and emits argument placement plus
`tca`, a frame teardown and a `jmp` (`x-tca`, `lib/lowering/x64/mach.chiral:1055`).
It does not distinguish a self-call from a mutual one, and it records nothing:
its result is a `(Maybe (Pair Str (List I64)))` consumed inside `emit-code`.
No pass above the emitter carries a loop-header fact.

### Compile-time constant round counts

`rounds` (`lib/crypto/chacha.chiral:76-80`) recurses on a runtime `I64`. Its
one caller inside the module passes a literal: `(rounds s0 10)` at
`lib/crypto/chacha.chiral:128`.

No pass sees that 10 as a fact about `rounds`. Two constant environments exist
and both stop at a call:

- `fold`'s `cenv` (`lib/lowering/upper/optimize.chiral:47-55`) is per-`TFn` and
  is threaded down a block. Its `i-call` arm pops the destination's fact and
  learns nothing about the callee (`fold-instr` at `:96`, the arm at `:101`).
- `emit-instr`'s `cenv` (`lib/lowering/mach/emit-core.chiral:18-61`) is
  per-function and per-block; `cenv-step` (`:46`) kills the destination of
  every defining instruction, and a `ti-call` defines its destination.

`specialize-raw` (`lib/lowering/upper/optimize.chiral:249`) is the machinery
that would bind a static argument to a residual function. It has no call site.

### Register allocation

None. The x64 target's own header states the design at
`lib/lowering/x64/mach.chiral:7-9`: "Memory-machine codegen: every virtual
register in a stack slot, rax/rcx scratch, so no register allocator is needed
for the first target."

The mapping is arithmetic. `slotd` (`:45`) puts virtual register `r` at
`[rbp - 8*(r+1)]` and `frame` (`:53`) rounds `8 * nregs` up to a multiple of
16. `nregs` comes from the SSA counter that `compile-fn` returns
(`lib/lowering/upper/lower.chiral:420`), so the frame is as large as the
function's virtual register count.

Three pieces of the register-discipline design are built:

| Piece | Seat | State |
|---|---|---|
| the clobber table | `x64-clobbers`, `lib/lowering/x64/mach.chiral:1443`, behind the `clb` face at `lib/lowering/mach/mach.chiral:57` | built. Maps an op key to the argument-register indices it may write |
| accumulator residency at the byte level | `x64-peep`, `lib/lowering/x64/mach.chiral:1321` | built and live. `emit` passes it at `lib/lowering/x64/emit.chiral:11` |
| parameter residency | `res-find`/`res-kill-args`/`res-init` at `lib/lowering/mach/emit-core.chiral:75-137`, `binr`/`binir`/`fcpr`/`fcir`/`ldr` at `lib/lowering/x64/mach.chiral:1532`, `:1542`, `:1550`, `:1556`, `:1564` | built and unreachable. `res-init` (`lib/lowering/mach/emit-core.chiral:133`) returns an empty map unless its `on` flag is true; `emit-program` receives `false` from `emit-with-peep` (`:564-567`) and `true` only from `emit-with-param` (`:570-573`), whose only caller is `emit-param` (`lib/lowering/x64/emit.chiral:14`), which nothing calls |

## 3. What the Python eviction removed

`find . -name "optimize.py" -not -path "./.git/*"` returns nothing.
`ls scaffold` answers `No such file or directory`. Fifteen `.py` files remain
in the tree and every one is a tool under `tools/`, `.planning/` or
`docs/examples/refs/`; none is a compiler backend.

The campaign's own record is `docs/benchmarks/OPT-LEDGER.md`, closed
2026-08-02. Its List 1 is the item-by-item ledger. Each row below is that list,
checked against the self-hosted tree.

| # | Campaign item | In the self-hosted compiler | Evidence |
|---|---|---|---|
| 1 | intrinsic inlining of `bget`/`blen` | yes | `erase-prim`, `lib/lowering/tal/erase.chiral:152-168` |
| 2 | constant folding and propagation | yes | `fold`, `lib/lowering/upper/optimize.chiral:140`, wired at `lib/lowering/compile-back.chiral:247` |
| 3 | branch folding on a known constructor | yes | `dispatch`, `lib/lowering/upper/optimize.chiral:130`, reached from `fold-block` at `:119` |
| 4 | CSE / value numbering | no | `grep -rniI "cse" lib prog --include=*.chiral --include=*.prog` returns the type names `RdcSeg` and `DecSet`, the `tcsets` termios family (`TCSETS`, `tcsetattr`, `nb-sys-tcsets`, `nb-tcsets`) and `act-decsets`, none of them a pass. There is no common-subexpression pass in the tree |
| 5 | dead code elimination | present, excluded | `dead` exists at `lib/lowering/upper/optimize.chiral:192` and is in the compiler blob. `opt-tfns` (`lib/lowering/compile-back.chiral:247`) applies `fold` alone. The exclusion is by measurement, recorded at `lib/lowering/compile-back.chiral:225-233` |
| 6 | operand folding to immediate forms | yes | `emit-instr` plus `cenv-step`, `lib/lowering/mach/emit-core.chiral:146-161` and `:46`; `bini-body`, `lib/lowering/x64/mach.chiral:967` |
| 7 | power-of-two strength reduction | yes | `pow2-k`, `lib/lowering/x64/mach.chiral:891` |
| 8 | constant-divisor guard elision | yes | `x-div-imm` (`lib/lowering/x64/mach.chiral:911`) and `x-mod-imm` (`:931`) |
| 9 | tail-call optimization | yes | `tail-call-of`, `lib/lowering/mach/emit-core.chiral:428`; `x-tca`, `lib/lowering/x64/mach.chiral:1055` |
| 10 | switch lowering to a lookup table | yes | `table-of`, `lib/lowering/mach/emit-core.chiral:288`; `x-ltb`, `lib/lowering/x64/mach.chiral:1101` |
| 11 | compare and branch fusion | yes | `fused-of`, `lib/lowering/mach/emit-core.chiral:379`; `x-fcp` (`lib/lowering/x64/mach.chiral:1185`), `x-fci` (`:1189`), `x-fjc` (`:1221`) |
| 12 | byte-level peephole | yes | `x64-peep`, `lib/lowering/x64/mach.chiral:1321`, live through `emit` at `lib/lowering/x64/emit.chiral:11` |
| 13 | totality-licensed compile-time evaluation (`_total_const_call`) | no | `grep -rniI "comptime" lib prog` and `grep -rniI "total-const" lib prog` both return nothing. `tot-gate` (`lib/typing/totality-check.chiral:153`) is imported once, by `lib/lowering/compile-front.chiral:24`, and its result is a `TotalR` verdict consumed at `lib/lowering/compile-front.chiral:371`. No optimizer reads a totality proof |
| 14 | magic-multiply constant division | encodings yes, pass no | `x-imul-rcx-1op` at `lib/lowering/x64/mach.chiral:321`, `x-sar-cl` at `:325`, `x-shr-cl` at `:327`, and the `op-mulhi` arm inside `op-bytes` (`:355-393`) at `:377`. `grep -rniI "divmagic" lib prog` returns nothing. E189 bound `mulhi` and `mulhu` as externs on 2026-09-08, so the name is now reachable from source, but no pass builds a reciprocal and no divisor is rewritten into a multiply |
| 15 | real register allocation | no | section 2 above. The header claim at `lib/lowering/x64/mach.chiral:7-9` still describes the shipping emitter |
| 16 | control-flow jump tables | yes | `jtb-codes`, `lib/lowering/mach/emit-core.chiral:337`; `x-jtb`, `lib/lowering/x64/mach.chiral:1165` |
| 19 | autospec, the bounded auto-pregen policy | no | `grep -rniI "autospec" lib prog` returns nothing. `specialize-raw` (`lib/lowering/upper/optimize.chiral:249`) is the pregen primitive and has no call site |

### The campaign's named apparatus

| Campaign artifact | State here | Evidence |
|---|---|---|
| `optimize.py` | gone | `find . -name "optimize.py"` returns nothing |
| `test_regdisc.py`, the conformance gate | gone, with no replacement | `grep -rn "regdisc" tools bin prog` returns nothing. `ls tools/test/*.sh` lists 27 scripts and none of them is a register-discipline gate |
| `NativeBackend(discipline=…)`, the discipline selector | replaced by three named entry points, one of them reachable | `emit-truthful` (`lib/lowering/x64/emit.chiral:8`), `emit` (`:11`), `emit-param` (`:14`). The call at `lib/lowering/compile-emit.chiral:307`, inside `emit-elf-m`, is to `emit`. There is no name-keyed selector and no `(regs …)` profile clause |
| rd-truthful | built, uncalled | `emit-truthful`, `lib/lowering/x64/emit.chiral:8`. Its peephole argument `rd-truthful` (`:6`) is the identity |
| rd-cache | built and live | `emit`, `lib/lowering/x64/emit.chiral:11`, passing `x64-peep` |
| rd-param | built, uncalled | the residency map at `lib/lowering/mach/emit-core.chiral:68-137`, its five machine ops, and `emit-param` at `lib/lowering/x64/emit.chiral:14`. `res-init` returns the empty map on the shipping path |
| rd-packed | not built | `docs/implementation/rd-packed-cert.md:3` reads "Status: RATIFIED 2026-08-02". `docs/benchmarks/OPTIMIZATIONS-TODO.md:8-10` reads "design done, zero code written". `grep -rn "rd-packed" lib prog tools bin` returns nothing outside `docs/` |
| SSA renaming machinery (`_remap_block`) | ported, uncalled | `rmap-block` and its family at `lib/lowering/upper/optimize.chiral:195-223`. Present in the compiler blob once, reachable only from `specialize-raw` |
| `_check_single_assignment` at every pass entry | not ported as a check | `grep -rniI "single-assignment\|single assignment" lib prog` returns the design note at `lib/lowering/upper/lower.chiral:110-111` and nothing executable. SSA is produced by the monotonic counter at `lib/lowering/upper/lower.chiral:161`. `cenv-step` (`lib/lowering/mach/emit-core.chiral:22-23`) states that its soundness does not assume SSA |
| preserve-check as the transform license | ported, and OUT of the compiler since 2026-09-08 | `Checked` and `re-check` were at `lib/lowering/upper/optimize.chiral:22` and `:250`, adopted at `lib/lowering/compile-back.chiral:244`, from `5b7478f` to `b613a8f`. The author ruled (`records/lenses/problems.md` PRB-70) that `lowering/tal/check` stays outside the compiler closure, so both moved to `prog/optimizer-census.prog` and `opt-tfns` adopts `(fold t)` unjudged. The census over the emitted TFns is still gated by `tools/test/opt-census.sh` |
| the differential floor (`TalMachine`) | present, unwired | `lib/lowering/tal/eval.chiral` is 187 lines and no module under `lib` or `prog` imports it |
| the tal spec as golden data | present, unwired | `lib/lowering/tal/spec.chiral:125` defines `tal-spec` with two entries. No importer |

### The two design documents that survived

| Document | What it describes | Built? |
|---|---|---|
| `docs/implementation/reg-disciplines.md` | four register disciplines and one conformance gate. It reports rd-truthful, rd-cache and rd-param as BUILT at `:21-33`, and its build order marks steps 1 to 3 DONE at `:70-85` | partly. The clobber table (step 2) and the residency machinery (step 3) are in the self-hosted tree at `lib/lowering/x64/mach.chiral:1443` and `lib/lowering/mach/emit-core.chiral:68-137`. rd-cache is the shipping path. rd-truthful and rd-param are built and have no caller. The gate the document calls "the enforcement" (`tests/test_regdisc.py`, `:6`) does not exist in this tree, so the conformance claim at `:60-66` is unwitnessed here |
| `docs/implementation/rd-packed-cert.md` | the move-script placement certificate and its forward-symbolic-walk checker | no. `:3` reads RATIFIED and `docs/benchmarks/OPTIMIZATIONS-TODO.md:10` reads "zero code written". The three structural facts it leans on are all present: terminator-only code (`lib/lowering/tal/ir.chiral:41-46`), the SSA counter (`lib/lowering/upper/lower.chiral:161`), and the clobber table as data (`lib/lowering/x64/mach.chiral:1443`). Its citations point at the old tree's paths (`lib/tal-ir.chiral`, `optimize.py`, `mach-x64.chiral`) |

## 4. What measurement exists

### Gates that run

| Instrument | What it measures | Last run |
|---|---|---|
| `tools/test/run-tests.sh` | the behavioural floor: 21 dispatched phases plus inline behavioural cases and a compile-only root sweep | re-run 2026-09-08 at `8c72746`: `assertions: 422 passed, 0 failed`, `compile-only: 94 roots built, 0 failed`, `chirality test: gate PASSED`. The survey read 412 and 93 over 20 phases on 2026-09-07, before E189 added phase 32 |
| `tools/test/opt-census.sh` | four rows over the typed-assembly checker's census of what the compiler emits, plus four mutants. Pins `defs=1518 skipped=10`, `tfns=1548 ok=1517 err=31`, and one error class whose every callee is the refused TFn's own `$0` block | re-pinned 2026-09-08 at `38ecdba`, where it read `8 passed, 0 failed`. Re-run 2026-09-08 at `8c72746` it reads `2 passed, 2 failed, 4 mutants unmeasured`: the census is now `defs=1519 skipped=10 tfns=1549 ok=1518 err=31`, which E189 moved at `c86b007` without the pins moving with it, so R1 and R2 are red, and the four mutants stay unmeasured because the gate holds a mutant graded against a red base to measure nothing. R3 and R4 hold. It read six rows, six mutants and 1582/1550/32 until PRB-70's ruling took `check.chiral` out of the compiler blob; the two rows and two mutants that asserted the wiring retired with it. Unregistered: it takes no phase number and is run by hand, stated in its header |
| `prog/optimizer-census.prog` | the census the gate reads. Imports `lowering/tal/check` in its own right since 2026-09-08 and carries `re-check` and the `Checked` sum, runs `ck-fn` per TFn over a compiler blob, and prints `tfns/ok/err/defs/skipped/unfolded-ok` plus an error class list. Asserts nothing and always exits 0 | built as a Phase 7 root by the suite run above |
| `tools/test/tal-check.sh` | the tal checker's own rows | green as of 2026-09-08 at `21 ok, 0 FAIL`. It read `20 ok, 1 FAIL` on G18 from `5b7478f` to `b613a8f`; `records/enforcement-arc.md` EN-25 and EN-26 record both readings |

### Benchmarks

| Document | What it measures | Backend behind the figures | Last run |
|---|---|---|---|
| `docs/benchmarks/RESULTS-2026-08-01.md` | ten runs of three micro-kernels against `gcc -O0` and `-O2` | Python-hosted. `:281-289` names `scaffold/chirality/native.py` (`NativeBackend.compile`) running the chirality emitter on the scaffold interpreter, with Python as loader and trampoline. The driver is `cd scaffold/bench && sh run.sh` (`:9`), and `scaffold/` does not exist in this tree | 2026-08-02 |
| `docs/benchmarks/language-performance.md` | the campaign headline: arith 1.38x, bytesum 5.2x, states 6.7x of `gcc -O2` | Python-hosted. It sources every figure to `scaffold/bench/RESULTS-2026-08-01.md` at `:23-24` and `:75`, and states the Python loader-and-trampoline arrangement at `:63` | 2026-08-02, restated 2026-08-10 |
| `docs/benchmarks/OPT-CHECKLIST.md`, `OPT-LEDGER.md`, `OPTIMIZATIONS-TODO.md`, `TRAIT-OPTS.md` | the campaign's worklist, ledger, continuation contract and trait survey | Python-hosted throughout. `OPT-CHECKLIST.md:17` speaks of "ports of `optimize.py`"; `OPT-LEDGER.md`'s enforcement table cites `optimize.py:218`, `native.py:521` and `test_backend.py` | closed 2026-08-02 |
| `docs/benchmarks/growing-allocator-scale.md` | the reserve-commit arena from 16 MiB to 32 GiB, checksum-as-exit-code per rung | self-hosted. Its run header names "Compiler: B1, 790904 bytes (md5 `2e2da0bedff04f17492138c9ba56d581`)" | 2026-08-10 |
| `docs/benchmarks/test-suite-wall-clock.md` | the native suite's own cost | self-hosted, and superseded. `docs/benchmarks/README.md:18-19` records that every figure in it predates the 2026-08-31 migration and stops short of being a baseline for the current tree | before 2026-08-31 |
| `docs/benchmarks/text-matcher-prose-lint.md` | `prog/prose-lint.prog` against mawk over 81 files and 609,872 B: 15.1x slower, 1.11 GB allocated, OOM-killed at the default scope | self-hosted. `:89` names `bin/chirality-bin`, sha256 `ac8de63e5687fad4…` | 2026-09-02 |
| `docs/benchmarks/text-matcher-allocation.md` | where that 1.11 GB goes, one subject per pipeline stage under a 2 GB cgroup. Matcher 86.8%, `blank-spans` 6.8%, `str-split` 6.3% | self-hosted. `:36` names `bin/chirality-bin`, sha256 `ac8de63e5687fad4…` | 2026-09-02 |
| `docs/benchmarks/crypto-kernel-allocation.md` | what `lib/crypto/chacha.chiral` costs per byte and whether `Q4` and `St` survive as arena cells | self-hosted. `:42` names `bin/chirality-bin`, sha256 `7d971a30c0bfda52fc2d952b…` | 2026-09-07 |

The line between the two backends is otherwise unmarked in `docs/benchmarks/`.
`README.md` there describes five docs and the directory holds thirteen.

### The instruments themselves

| Instrument | What it reads |
|---|---|
| `tools/bench/crypto-kernel.sh` | four modes. `alloc` builds six subjects and prints bytes per iteration; `sites` counts `lea rcx,[rax+sz]` byte patterns in the emitted ELF to find inline bump-allocation sites; `time` runs a min/median/max band over ten runs after two warmups; `xor` measures the stream path at four message sizes. Every subject is generated in `$TMPDIR` and compiled with `bin/chirality` |
| `heap-allocated` | `lib/ports/process.port:36`, an `(=> Unit I64)` crossing returning `heapptr - heapbase`. The bump pointer only advances and nothing reclaims, so the difference is the allocator's own state. It is the instrument behind the crypto and text-matcher allocation docs |
| `tools/test/run-tests.sh` | the gating floor. Zero Python; `bin/chirality-bin` is the only thing that compiles anything |

There is no wall-clock or instruction-count instrument that runs inside
`tools/test/run-tests.sh`. Its wall clock is printed and sets no bar, per the
2026-09-01 ruling cited at `docs/benchmarks/README.md:29`. There are no
hardware performance counters: `docs/benchmarks/OPTIMIZATIONS-TODO.md:55-56`
records them as blocked in the sandbox and owed on bare metal.
