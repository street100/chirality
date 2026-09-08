---
node: benchmarks-opt-candidates-2026-09
layer: benchmark
status: drafted
related: [implementation/optimizer-inventory, benchmarks/crypto-kernel-allocation, benchmarks/OPT-LEDGER, benchmarks/OPTIMIZATIONS-TODO, benchmarks/TRAIT-OPTS, benchmarks/README, index]
updated: 2026-09-07
---

# The candidate list: every optimization available to this compiler

A discovery list taken 2026-09-07 against `docs/implementation/optimizer-inventory.md`
(the survey at `ea31370`, committed at `43c7fab`), which establishes what the
compiler already does. This file establishes what it could do.

**This file ranks nothing, estimates nothing and recommends no order.** A later
stage triages and a stage after that evaluates. Over-generation is the point: a
candidate a later stage rejects costs one row, and a candidate never listed
costs the whole opportunity in silence. Rows marked doubtful are kept on
purpose.

## How to read a row

| field | content |
|---|---|
| # | a handle for a later stage. The letter is the bucket |
| candidate | what the literature calls it |
| what it does | one or two sentences |
| source | the bucket, and the catalogue or file the row came from |
| status here | `absent`, `present`, `partial`, `blocked` with the blocker named, or `moot` |
| touches | surface, IR, optimizer, backend, type system. Two rows outside the compiler take `tooling` and `runtime` |
| doubtful | a mark and one clause where the row may not apply |

`moot` is the fifth value the field list did not name. It marks a pass that
answers a question this tree does not pose: float canonicalization on a target
with no float type, write barriers on an arena that reclaims nothing. A moot row
stays on the list because the question can come back.

Every `present` and `partial` verdict cites the inventory or the code the
inventory cites. Nothing here re-measures.

## The catalogues walked

Each was fetched and read in this run. All seven are pinned under
`.planning/sources/`, so a citation of the form `ID:LINE` resolves to bytes.

| pin | what it is | lines |
|---|---|---|
| `LLVMPASSES` | LLVM's textual pass registry, `llvm/lib/Passes/PassRegistry.def` | 863 |
| `GCCPASSES` | GCC's pass pipeline, `gcc/passes.def` | 576 |
| `GHCPIPELINE` | GHC's Core-to-Core pipeline, `GHC/Core/Opt/Pipeline.hs` | 589 |
| `MLTONSSA` | MLton's SSA simplification schedule, `mlton/ssa/simplify.fun` | 306 |
| `GOSSA` | Go's SSA pass table, `cmd/compile/internal/ssa/compile.go` at `go1.23.0` | 610 |
| `FLAMBDA` | the OCaml manual's flambda chapter, `manual/src/cmds/flambda.etex` | 1344 |
| `CRANELIFT` | Cranelift's compilation context, `cranelift/codegen/src/context.rs` | 398 |

The textbook axis is covered by these seven together: LLVM and GCC carry the
scalar, loop, interprocedural and machine chapters; GHC and flambda carry the
functional-language chapters that a C-shaped catalogue omits; MLton carries the
whole-program SSA chapter; Go and Cranelift carry the compact backend.

The four IR limitations the inventory records are the spine of bucket B, and
each is quoted back in the `blocked` verdicts of buckets A and F:

1. no interprocedural constant fact. A call kills the constant environment, so
   the literal `10` at `lib/crypto/chacha.chiral:128` never reaches `rounds`.
2. no loop form and no back-edge above the byte emitter.
3. no location vocabulary. `Instr` at `lib/lowering/tal/ssa.chiral:26-34` has a
   `dst` slot index per constructor and offers no move, spill or phi.
4. `ti-cona` always allocates. There is no field-update or reuse form, and
   `x-galo` at `lib/lowering/x64/mach.chiral:509-511` sizes a cell as
   `8 * (1 + fields)`.

## Bucket A. The classical pass catalogue

Seven pass lists, walked row by row. A pass that this IR could carry today is
listed with its seat. A pass that this IR cannot carry is listed anyway, with
the blocker named, because a blocked pass is the argument for the IR change
that unblocks it.

### A-i. Scalar and local

| # | candidate | what it does | source | status here | touches | doubtful |
|---|---|---|---|---|---|---|
| A1 | common subexpression elimination | replaces a repeated pure computation with the first result | `GOSSA:467` generic cse, `MLTONSSA` commonSubexp | absent. Inventory §3 row 4: no CSE pass in the tree | optimizer | |
| A2 | global value numbering | numbers values so equal computations across a whole function share one number | `LLVMPASSES:497` newgvn, `:609` gvn | absent | optimizer | |
| A3 | partial redundancy elimination | inserts a computation on the paths that lack it so the merge sees one value | `GCCPASSES` pass_pre, pass_rtl_pre | absent | optimizer, IR | ? partial redundancy needs a merge point and both IRs are trees |
| A4 | sparse conditional constant propagation | a lattice over constants that also kills unreachable edges | `GOSSA:478` sccp, `GCCPASSES` pass_ccp | partial. `fold` propagates constants per block with no lattice | optimizer | |
| A5 | constant folding | evaluates an operation on known operands at compile time | `GCCPASSES` pass_ccp, `CRANELIFT` cprop rules | present. `fold`, `lib/lowering/upper/optimize.chiral:129` | optimizer | |
| A6 | reassociation | reorders associative chains so constants meet and subexpressions repeat | `LLVMPASSES:537` reassociate, `GCCPASSES` pass_reassoc | absent | optimizer | |
| A7 | instruction combining | local algebraic rewrites over an IR window | `LLVMPASSES:621` instcombine, `CRANELIFT:361` egraph_pass | absent above the byte level. `x64-peep` works on emitted bytes | optimizer | |
| A8 | dead code elimination | removes an instruction whose result nothing reads | `GOSSA:460` deadcode, `LLVMPASSES` dce | present, excluded. `dead` exists at `lib/lowering/upper/optimize.chiral:181` and `opt-tfns` ships `fold` alone, by the measurement at `lib/lowering/compile-back.chiral:228-238` | optimizer | |
| A9 | aggressive and bit-tracking DCE | removes computations whose bits nothing observes | `LLVMPASSES` adce, bdce | absent | optimizer | |
| A10 | dead store elimination | removes a store that a later store overwrites with nothing between | `GOSSA:483` dse | absent | optimizer | ? every `ti-bput` writes a freshly allocated cell |
| A11 | store merging | fuses adjacent narrow stores into one wide store | `GCCPASSES:374` pass_store_merging, `GOSSA:484` memcombine | absent. The `pack-u32` write runs are the shape | optimizer, backend | |
| A12 | copy propagation and copy elimination | forwards a copy's source to its uses and drops the copy | `GOSSA:459` copyelim, `GCCPASSES` pass_copy_prop | blocked by limitation 3. Neither instruction set has a move form, so a copy has no representation to eliminate | IR | |
| A13 | value range propagation | derives an interval per value and discharges tests against it | `GCCPASSES:237` pass_vrp, `GOSSA:471` prove | absent, and blocked for source-derived facts by the refinement drop at `lib/lowering/compile-front.chiral:69` | optimizer, type system | |
| A14 | bounds-check elimination | removes an index guard a range fact discharges | `GOSSA:480` check bce | partial. Constant-divisor guard elision only, `x-div-imm` at `lib/lowering/x64/mach.chiral:905` | optimizer, backend | |
| A15 | redundant test elimination | drops a comparison an earlier comparison already settled | `MLTONSSA` redundantTests | absent | optimizer | |
| A16 | useless-value elimination | drops a value and the tuple slot holding it when no consumer inspects either | `MLTONSSA:63` useless | absent | optimizer | |
| A17 | sinking to uses | moves a computation down to the block that consumes it | `LLVMPASSES:548` sink, `GOSSA:498` tighten | absent | optimizer | |
| A18 | hoisting of common code | lifts a computation both arms perform to the block above them | `LLVMPASSES` gvn-hoist, `GCCPASSES` pass_rtl_hoist | absent | optimizer | |
| A19 | constant hoisting | materializes an expensive constant once and shares the register | `LLVMPASSES:425` consthoist | absent | optimizer, backend | ? `x-mov-rax-imm` is already one instruction |
| A20 | redundant load elimination | drops a load whose value a live slot already holds | `CRANELIFT:344` replace_redundant_loads | partial. Pattern A of `x64-peep`, the recognizer `peep-hit` at `lib/lowering/x64/mach.chiral:1237` | backend | |
| A21 | strength reduction | replaces an expensive operator with a cheaper one on the same value | `LLVMPASSES` slsr, `GCCPASSES` pass_strength_reduction | partial. Power-of-two division and modulo only, `pow2-k` at `lib/lowering/x64/mach.chiral:885` | backend | |
| A22 | magic-number constant division | turns division by a constant into a multiply-high and a shift | `GCCPASSES:373` pass_optimize_widening_mul, Cranelift `opts/div_const.rs` | encodings present, pass absent. Inventory §3 row 14 | optimizer, backend | |
| A23 | byte-swap idiom recognition | recognizes a shift-and-or chain as a byte reversal | `GCCPASSES:275` pass_optimize_bswap | absent, and blocked by the binary-only `ti-prim` form | optimizer, backend | |
| A24 | widening multiply recognition | recognizes a full-width product and emits the two-register form | `GCCPASSES:373` | absent. `op-mulhi` is the unused half of the shape | optimizer, backend | |
| A25 | zero-argument CSE | shares the nullary values a backend keeps re-materializing | `GOSSA:465` zero arg cse | absent | optimizer | ? this target has no global base pointer to share |
| A26 | freeze and undef canonicalization | gives an undefined value one canonical form | `LLVMPASSES` canon-freeze | moot. The floor has no undefined value; a trap is chosen instead | | |

Count: 26.

### A-ii. Control flow

| # | candidate | what it does | source | status here | touches | doubtful |
|---|---|---|---|---|---|---|
| A27 | jump threading | redirects a branch whose outcome an earlier branch already determined | `LLVMPASSES` jump-threading, dfa-jump-threading; `GCCPASSES` pass_thread_jumps | blocked by limitation 2 and by the missing CFG. `TCode` at `lib/lowering/tal/ir.chiral:41-46` has no label or jump form | IR, optimizer | |
| A28 | tail duplication and trace formation | copies a joined tail into each predecessor to expose straight-line work | `GCCPASSES` pass_tracer, pass_duplicate_computed_gotos | blocked, same | IR, optimizer | |
| A29 | basic block layout | orders blocks so the hot edge falls through | `GOSSA:503` layout, `GCCPASSES` pass_reorder_blocks | blocked, same. Emission walks the `TCode` tree in source order | IR, backend | |
| A30 | empty block trimming and block merging | deletes a block that only jumps onward | `GOSSA:509` trim, `GCCPASSES` pass_cleanup_cfg | moot under the tree shape | | |
| A31 | critical edge splitting | breaks an edge from a multi-successor block into a multi-predecessor block | `GOSSA:500` critical | moot. Branches never rejoin, per the inventory's loops section | | |
| A32 | if-conversion and conditional-move selection | turns a short branch into a predicated computation | `GOSSA:481` branchelim, `GCCPASSES` pass_if_conversion, `LLVMPASSES` select-optimize | blocked. There is no select form in either IR and no conditional-move op in the `Op` sum | IR, backend | |
| A33 | branch folding on a known scrutinee | selects the arm a known constructor picks | `MLTONSSA:118` knownCase2 | present. `dispatch`, `lib/lowering/upper/optimize.chiral:119` | optimizer | |
| A34 | switch lowering to a lookup table | replaces a compare chain over an enum with an indexed load | `GCCPASSES` pass_convert_switch | present. `table-of`, `lib/lowering/mach/emit-core.chiral:288` | backend | |
| A35 | switch lowering to a jump table | replaces a compare chain with an indexed jump | `GCCPASSES` pass_lower_switch | present. `jtb-codes`, `lib/lowering/mach/emit-core.chiral:337` | backend | |
| A36 | compare and branch fusion | lets one compare feed the branch with no materialized bool | `GOSSA:506` flagalloc neighbourhood | present. `fused-of`, `lib/lowering/mach/emit-core.chiral:379` | backend | |
| A37 | short circuit | shortens a boolean chain that a phi immediately consumes | `GOSSA:461` short circuit | absent | optimizer | ? the surface `cond` already lowers to nested `case` |
| A38 | unreachable code elimination | deletes code no entry reaches | `CRANELIFT` unreachable_code, `LLVMPASSES` unreachableblockelim | partial. `prune-fix` at `lib/lowering/compile-back.chiral:214` works at function granularity | optimizer | |
| A39 | branch probability annotation | marks the likely edge so layout and scheduling can use it | `GOSSA:502` likelyadjust | absent, and there is no profile to read | optimizer | |
| A40 | profile-guided optimization | feeds measured counts back into inlining, layout and unrolling | `LLVMPASSES` pgo-instr-gen, pgo-instr-use; `GCCPASSES:172` neighbourhood pass_ipa_profile | blocked. No counter instrument exists in the tree, and `perf` is blocked in this sandbox per `docs/benchmarks/OPTIMIZATIONS-TODO.md:57-58` | optimizer, backend | |

Count: 14.

### A-iii. Loops

Every row here carries the same primary blocker. Iteration is tail recursion,
`tail-call-of` at `lib/lowering/mach/emit-core.chiral:428` is the one place a
back-edge is identified, and it records nothing.

| # | candidate | what it does | source | status here | touches | doubtful |
|---|---|---|---|---|---|---|
| A41 | loop-invariant code motion | hoists a computation whose operands do not change across iterations | `GCCPASSES:137` pass_lim, `MLTONSSA:49` loopInvariant1 | blocked by limitation 2. Named on the parked menu at `docs/benchmarks/OPTIMIZATIONS-TODO.md:44-46` | IR, optimizer | |
| A42 | loop unrolling | replicates the body so per-iteration overhead is paid less often | `LLVMPASSES:634` loop-unroll, `MLTONSSA:67` loopUnroll1 | blocked by limitation 2. The ten-iteration `rounds` recursion at `lib/crypto/chacha.chiral:76-80` is the case | IR, optimizer | |
| A43 | loop unswitching | lifts a loop-invariant test out and duplicates the loop per outcome | `MLTONSSA` loopUnswitch, `GCCPASSES` pass_tree_unswitch | blocked by limitation 2 | IR, optimizer | |
| A44 | loop rotation and header copying | turns a top-tested loop into a bottom-tested one | `GOSSA:508` loop rotate, `GCCPASSES` pass_ch | blocked by limitation 2 | IR, optimizer | |
| A45 | induction variable canonicalization and elimination | rewrites derived counters in terms of one canonical variable | `LLVMPASSES` indvars, `GCCPASSES` pass_iv_canon, pass_iv_optimize | blocked by limitation 2 | IR, optimizer | |
| A46 | loop deletion, peeling and bound splitting | removes or reshapes a loop whose trip count is known or whose body is dead | `LLVMPASSES` loop-deletion, loop-bound-split | blocked by limitation 2 | IR, optimizer | |
| A47 | loop fusion, distribution, interchange and jam | reorders whole loop nests for locality | `LLVMPASSES` loop-fusion, loop-distribute, loop-interchange, loop-unroll-and-jam; `GCCPASSES` pass_graphite | blocked twice: limitation 2, and no array subscript vocabulary | IR, optimizer | ? this tree has no affine array indexing to reorder |
| A48 | loop idiom recognition | recognizes a copy or fill loop and emits one block operation | `LLVMPASSES` loop-idiom | blocked by limitation 2 and by the missing block-copy op. The byte-library copy recursions are the shape | IR, backend | |
| A49 | software pipelining | overlaps iterations to hide latency | `GCCPASSES` pass_sms | blocked by limitation 2 and by the absent scheduler | IR, backend | |
| A50 | loop introduction from self tail recursion | recognizes a self tail call as a local loop and gives it a header | `MLTONSSA` introduceLoops | absent. This is limitation 2's enabler wearing a pass name | IR, optimizer | |
| A51 | exitification | floats a loop's exit path into a join so the loop body stays small | `GHCPIPELINE:263` CoreDoExitify | absent | optimizer | |
| A52 | liberate case | unrolls one iteration so a scrutinee that is constant per call becomes known | `GHCPIPELINE:478` liberateCase | absent | optimizer | |
| A53 | loop and SLP vectorization | packs independent scalar work into vector operations | `LLVMPASSES:550` slp-vectorizer, `GCCPASSES` pass_vectorize | blocked three ways: limitation 2, no vector type in `TalTy`, no vector op in the `Op` sum | IR, backend, type system | |
| A54 | loop-carried check hoisting | proves an index guard once for a whole traversal | `GOSSA:480` check bce | blocked by limitation 2 and by the refinement drop | IR, type system | |

Count: 14.

### A-iv. Interprocedural

| # | candidate | what it does | source | status here | touches | doubtful |
|---|---|---|---|---|---|---|
| A55 | inlining | copies a callee body into its caller | `GCCPASSES:175` pass_ipa_inline, `CRANELIFT:204` inline, `FLAMBDA:188` the inlining chapter | absent. Inventory §2: no pass inlines a function body. Named on the parked menu at `docs/benchmarks/OPTIMIZATIONS-TODO.md:42-43` | optimizer | |
| A56 | partial inlining and hot-cold splitting | inlines the hot prefix and leaves the cold remainder outlined | `LLVMPASSES` partial-inliner, hotcoldsplit | absent, and it wants the profile A40 lacks | optimizer | |
| A57 | interprocedural constant propagation | propagates a constant argument into the callee body | `GCCPASSES:172` pass_ipa_cp | blocked by limitation 1 | optimizer | |
| A58 | specialization on a constant argument | clones a callee against known arguments and rewrites the site | `GHCPIPELINE:304` CoreDoSpecConstr, `FLAMBDA:939` | machinery present, uncalled. `specialize-raw` at `lib/lowering/upper/optimize.chiral:238` has no call site. Named as autospec on the parked menu | optimizer | |
| A59 | static argument transformation | drops a recursive parameter that every call passes unchanged | `GHCPIPELINE:199` CoreDoStaticArgs | absent. `rounds`'s state-independent arguments are the case | optimizer | |
| A60 | call arity analysis | eta-expands a function to the arity its call sites actually use | `GHCPIPELINE:256` CoreDoCallArity | absent | optimizer | ? closure conversion has already flattened application |
| A61 | contification | turns a function called from one return context into a continuation in its caller | `MLTONSSA:54` contify1 | absent. The outlined `<name>$<n>` functions from `outline` at `lib/lowering/upper/lower.chiral:311` are exactly this shape | optimizer | |
| A62 | dead argument elimination | removes a parameter no callee body reads | `LLVMPASSES` deadargelim, `FLAMBDA:1120` | partial. Arguments at a callee's `q=0` positions are dropped by `tnc-keep` at `lib/lowering/compile-front.chiral:136`; a live-typed unused parameter survives | optimizer | |
| A63 | named return value and return slot optimization | writes a result into the caller's storage with no intermediate | `GCCPASSES` pass_nrv, pass_return_slot | absent, and blocked by the single-slot return | IR, optimizer | |
| A64 | function merging and identical code folding | collapses two functions with the same body into one symbol | `LLVMPASSES:124` mergefunc, `GCCPASSES` pass_ipa_icf | absent. The synthesized `$apply<i>` dispatchers and the `<name>$<n>` outlines are the corpus to test it on | optimizer | |
| A65 | devirtualization | replaces an indirect call whose target is known with a direct one | `GCCPASSES` pass_ipa_devirt, `LLVMPASSES` wholeprogramdevirt | partial. `sp-rw` at `lib/lowering/upper/specialize-singleton.chiral:124-132` devirtualizes a singleton dictionary at the `Term` level | optimizer | |
| A66 | interprocedural pure and const discovery | proves a callee has no side effect so its call can move or vanish | `GCCPASSES` pass_ipa_pure_const, pass_local_pure_const | present in the type. The module category and the arrow carry it, so no analysis runs | type system | |
| A67 | interprocedural alias and points-to analysis | bounds what a call can read and write | `GCCPASSES` pass_ipa_modref, pass_ipa_pta | absent | optimizer | ? the lowered fragment is pure and every cell is freshly constructed, so the question may not arise |
| A68 | dead global and unreachable symbol pruning | drops a definition nothing reaches | `MLTONSSA` removeUnused | present. `prune-fix` at `lib/lowering/compile-back.chiral:214`, `filter-erasable` at `:185`, `drop-pruned` at `lib/lowering/upper/specialize-singleton.chiral:228` | optimizer | |
| A69 | global constant merging | shares one copy of a repeated constant | `LLVMPASSES` constmerge, `MLTONSSA` duplicateGlobals | partial. `program-lits` at `lib/lowering/compile-back.chiral:124` dedupes string literals and nothing else | optimizer, backend | |
| A70 | dispatcher collapse for defunctionalized families | turns an `$apply<i>` dispatch on a known closure tag into a direct call | bucket 1 applied to `closconv-sig` | absent. `dispatch` folds a known constructor inside a `TFn`, and the closure tag reaching the dispatcher is an interprocedural fact | optimizer | |
| A71 | tail call elimination | replaces a tail call with argument placement and a jump | `LLVMPASSES:555` tailcallelim, `GCCPASSES:381` pass_tail_calls | present. `tail-call-of` plus `x-tca` at `lib/lowering/x64/mach.chiral:1047`. Demoted past six arguments | backend | |
| A72 | whole-program visibility as a starting point | every interprocedural pass sees the entire program with no link-time machinery | `LLVMPASSES` function-import, the LTO family | present by construction. `load-source-batched` builds one `Sig` for the whole batch | optimizer | |

Count: 18.

### A-v. Data representation and memory

| # | candidate | what it does | source | status here | touches | doubtful |
|---|---|---|---|---|---|---|
| A73 | scalar replacement of aggregates | splits a record into its fields and keeps them in registers or slots | `LLVMPASSES:724` sroa, `GCCPASSES:252` pass_sra | absent. The measured `Q4` and `St` cells are the case | optimizer, IR | |
| A74 | unboxing of arguments and returns | passes a product's fields instead of a pointer to it | `FLAMBDA:939` unboxing of specialised arguments, `:1016` unboxing of closures | absent, and blocked by limitation 4 and the single-slot return | IR, optimizer | |
| A75 | constructed product result with worker-wrapper | splits a function that returns a box into a worker returning the fields and a wrapper that boxes | `GHCPIPELINE:174` CoreDoCpr with CoreDoWorkerWrapper | absent. `qround` returning a `Q4` is exactly the shape the transform targets | IR, optimizer | |
| A76 | demand and strictness analysis | discovers which arguments a function forces | `GHCPIPELINE:495` CoreDoDemand | moot for the strictness half; the language is strict. The boxity half that CPR consumes is the live part | optimizer | |
| A77 | argument flattening | passes each field of a tuple argument as its own parameter | `MLTONSSA` flatten, localFlatten, deepFlatten | absent. `sB` in the crypto benchmark is this transform applied by hand, and it allocated zero bytes | IR, optimizer | |
| A78 | reference and cell flattening | turns a heap cell used in one scope into locals | `MLTONSSA` localRef, `FLAMBDA:1147` non-escaping references | absent | optimizer | |
| A79 | escape analysis | proves a cell does not outlive its frame and allocates it cheaply | LLVM and GCC both, as an enabling analysis | absent. It is the analysis A73 and A78 would otherwise need | optimizer | |
| A80 | type simplification and splitting | narrows a data type to the shape its uses require | `MLTONSSA` simplifyTypes, splitTypes | absent | optimizer, type system | |
| A81 | known-case optimization across a construction | forwards a constructor into the `case` that scrutinizes it, deleting the cell | `MLTONSSA:118` knownCase2 | partial. `dispatch` selects the arm; the cell is still built | optimizer | |
| A82 | common argument elimination | shares an argument every call site passes identically | `MLTONSSA` commonArg | absent | optimizer | |
| A83 | common block sharing | merges two blocks with identical bodies | `MLTONSSA` commonBlock | absent | optimizer | |
| A84 | constant lifting and top-level let lifting | evaluates a top-level constant once and emits it as static data | `FLAMBDA:815` lifting of constants, `:857` lifting of toplevel let bindings | absent. `docs/benchmarks/crypto-kernel-allocation.md` measures a top-level `(def name Bytes ...)` re-evaluated at every reference, 336 B per reference for a 32-byte key | optimizer, backend | |
| A85 | float-out and float-in | moves a binding to the outermost or innermost point that keeps its work shared | `GHCPIPELINE:209` CoreDoFloatOutwards, CoreDoFloatInwards | absent | optimizer | |
| A86 | combine conversions | fuses a widening and a narrowing that cancel | `MLTONSSA` combineConversions | moot today. There is one integer width, so no conversion pair exists to fuse | IR, type system | |
| A87 | allocation sinking | moves a construction into the arm that consumes it | GHC and flambda both, as part of the simplifier | absent | optimizer | |

Count: 15.

### A-vi. Machine level

| # | candidate | what it does | source | status here | touches | doubtful |
|---|---|---|---|---|---|---|
| A88 | register allocation | assigns values to physical registers with spills where they do not fit | `GOSSA:507` regalloc, `GCCPASSES:518` pass_ira | blocked by limitation 3. The header at `lib/lowering/x64/mach.chiral:7-9` still describes the shipping emitter | IR, backend | |
| A89 | register coalescing | removes a move by giving both ends the same register | `GOSSA:459` copyelim | blocked by limitation 3 | IR, backend | |
| A90 | rematerialization | recomputes a cheap value instead of spilling it | `GOSSA:501` phi tighten | blocked by limitation 3 | IR, backend | |
| A91 | live-range splitting and spill placement | breaks a long range so the pressure peak is local | LLVM and GCC allocators both | blocked by limitation 3 | IR, backend | |
| A92 | stack slot coloring and frame compaction | reuses one stack slot for values whose ranges do not overlap | `GOSSA` stackalloc.go, `GCCPASSES` pass_live_range_shrinkage | absent. `frame` at `lib/lowering/x64/mach.chiral:53` rounds `8 * nregs` and reuses nothing. This is the slot-retiring allocator ratified in `docs/implementation/rd-packed-cert.md` with zero code written | backend | |
| A93 | flag allocation | schedules the condition-code register as a resource | `GOSSA:506` flagalloc | partial. The fused compare-branch owns the flags across a taken jump, locally | backend | |
| A94 | instruction scheduling | reorders independent instructions to hide latency | `GOSSA:504` schedule, `GCCPASSES:514` pass_sched | absent. The parked menu at `docs/benchmarks/OPTIMIZATIONS-TODO.md:53-54` makes it wait on counters | backend | |
| A95 | machine peephole | rewrites a short emitted instruction window | `GCCPASSES` pass_peephole2 | present. `x64-peep`, `lib/lowering/x64/mach.chiral:1313` | backend | |
| A96 | addressing-mode folding | folds an offset or an index into the memory operand | `GOSSA:489` addressing modes, `GCCPASSES` pass_fold_mem_offsets | partial. `x-load-field` at `lib/lowering/x64/mach.chiral:439` folds the field displacement and nothing wider | backend | |
| A97 | immediate operand folding | folds a known constant into the instruction encoding | `GCCPASSES` pass_combine | present. `bini-body`, `lib/lowering/x64/mach.chiral:961` | backend | |
| A98 | shrink wrapping | builds the frame only on the paths that need it | `GCCPASSES` pass_thread_prologue_and_epilogue | absent. `x-prologue` at `lib/lowering/x64/mach.chiral:65` always builds a frame | backend | |
| A99 | leaf-frame omission | skips the frame for a function that calls nothing | `GCCPASSES` pass_leaf_regs | absent | backend | |
| A100 | branch shortening and relaxation | picks the smallest encoding that reaches the target | `GCCPASSES` pass_shorten_branches | partial. `x-jne8` and `x-jmp8` at `lib/lowering/x64/mach.chiral:271-273` are rel8 with distances computed at emit time | backend | |
| A101 | machine outlining for size | factors a repeated instruction sequence into a called stub | LLVM's machine-outliner, in the codegen registry outside this pin | absent. `outline` at `lib/lowering/upper/lower.chiral:311` outlines for lowering reasons and not for size | backend | |
| A102 | post-reload CSE and register renaming | cleans up after allocation | `GCCPASSES` pass_postreload_cse, pass_regrename | moot until A88 exists | backend | |
| A103 | delay slot filling, mode switching, subreg lowering | target-shaped chores | `GCCPASSES` pass_delay_slots, pass_mode_switching, pass_lower_subreg | moot on this target | backend | |

Count: 16.

### A-vii. Whole program and search

| # | candidate | what it does | source | status here | touches | doubtful |
|---|---|---|---|---|---|---|
| A104 | equality saturation | grows an e-graph of equivalent forms and extracts the cheapest | `CRANELIFT:361` egraph_pass, and its rule discipline in `cranelift/codegen/src/opts/README.md` | absent | optimizer | |
| A105 | superoptimizer harvesting | mines real code for windows a search can improve | `CRANELIFT:352` souper_harvest | absent. Named on the parked menu at `docs/benchmarks/OPTIMIZATIONS-TODO.md:65-84` | optimizer | |
| A106 | alias analysis as an enabling pass | bounds what two memory references can share | `CRANELIFT` alias_analysis.rs, `LLVMPASSES` tbaa, scoped-noalias-aa | absent | optimizer | ? purity plus fresh construction may make it unnecessary here |
| A107 | constant phi removal | deletes a phi whose inputs agree | `CRANELIFT:282` remove_constant_phis | moot. There is no phi | | |
| A108 | float canonicalization and soft float | normalizes NaN and lowers float on targets without it | `CRANELIFT:292` canonicalize_nans, `GOSSA:475` softfloat | moot. There is no float type | | |
| A109 | write barriers, safepoints and GC lowering | inserts the collector's contract | `GOSSA:485` writebarrier, `LLVMPASSES` place-safepoints | moot. The arena only advances and reclaims nothing | | |
| A110 | atomic expansion, sanitizer and coroutine lowering | expands language features this floor does not have | `LLVMPASSES` atomic-expand, tsan, coro-early | moot | | |

Count: 7.

**Bucket A total: 110.**

## Bucket B. The IR limitations, as candidates in themselves

Each row here is an enabler. It buys nothing on its own and it unblocks a
family that bucket A lists separately. The first four are the limitations the
inventory recorded; the rest surfaced while walking the catalogues against this
IR.

| # | candidate | what it does | source | status here | touches | doubtful |
|---|---|---|---|---|---|---|
| B1 | an interprocedural fact environment | gives each function a summary a caller's constant environment can survive into | inventory limitation 1 | absent. `fold`'s `cenv` pops the destination at `i-call` (`lib/lowering/upper/optimize.chiral:90`) and `cenv-step` kills it at `lib/lowering/mach/emit-core.chiral:46`. Unblocks A57, A58, A59, A70, and the totality rows F1 to F4 | IR, optimizer | |
| B2 | a loop form with a recorded back-edge | names a self or mutual tail call as a loop header above the byte emitter | inventory limitation 2 | absent. `tail-call-of` identifies the shape and returns a `Maybe` consumed inside `emit-code`. Unblocks A41 to A54 | IR, optimizer | |
| B3 | a location vocabulary | adds move, spill, reload and phi to the instruction set so a value can live somewhere other than its slot | inventory limitation 3 | absent. `Instr` at `lib/lowering/tal/ssa.chiral:26-34` gives every constructor a `dst` slot index. Unblocks A12, A88 to A92, and B19 | IR, backend | |
| B4 | a non-allocating product form | adds field update, cell reuse, or an unboxed multi-field value | inventory limitation 4 | absent. `ti-cona` is the only way to write a cell's fields. Unblocks A73 to A79, D1 to D5, F7 to F10, F24 | IR, backend | |
| B5 | a control-flow graph with labels and joins | lets a branch rejoin, which the tree-shaped `Block` and `TCode` forbid | bucket 1, from `GOSSA` and `GCCPASSES` needing a CFG for most of their pipeline | absent. Unblocks A3, A27, A28, A29, A32 | IR | ? terminator-only blocks are a named structural asset, so this row trades one invariant for a family |
| B6 | a unary prim form | lets an instruction carry one operand | bucket 3, from the ISA gaps | blocked today by shape. `erase-prim` at `lib/lowering/tal/erase.chiral:153-157` refuses any `Op` without exactly two operands, and `ti-prim` at `lib/lowering/tal/ir.chiral:21` has fields `a` and `b`. Typed SSA already allows it: `i-prim` carries a `(List I64)`. Unblocks C3 to C6, C20 to C23 | IR, backend | |
| B7 | a select form | a three-operand choose, from which a conditional move falls out | bucket 1, `GOSSA:481` branchelim | absent. Unblocks A32 and C7 | IR, backend | |
| B8 | a sub-word integer type | adds a 32-bit or narrower type to `TalTy` | bucket 3, and the measured `band M32` masking | absent. `TalTy` at `lib/lowering/tal/ssa.chiral:21-22` has five members and every integer is `tt-i64`. Unblocks C33, and removes two of `add32`'s three operations at `lib/crypto/chacha.chiral:20` | IR, type system, backend | |
| B9 | fact-carrying lowering | carries refinement and quantity facts through the peel into tal | bucket 5, and `docs/benchmarks/TRAIT-OPTS.md`'s open half | absent, with two exact seats. The type peel lowers a refinement to its base at `lib/lowering/compile-front.chiral:69`, and the Pi-chain peel keeps `dom` and drops the quantity `q` at `:85`. Unblocks A13, A14, F7 to F10, F15 to F21 | type system, IR | |
| B10 | per-definition totality classification | records which definitions are proven total instead of one verdict for the signature | bucket 5 | absent. `TotalR` at `lib/typing/totality-check.chiral:131` is `tot-proven` or one `tot-holdout`, so there is no per-function fact to key a fold on. Unblocks F1 to F5 | type system, optimizer | |
| B11 | a cost model | orders two verified candidates | `docs/benchmarks/OPTIMIZATIONS-TODO.md:73-76` | absent | optimizer | |
| B12 | a semantic equivalence oracle | decides whether a rewritten straight-line window computes the same function | `docs/benchmarks/OPTIMIZATIONS-TODO.md:67-72` | absent. `re-check` proves types and says nothing about meaning. Unblocks A104, A105, F28 | optimizer | |
| B13 | a counter or profile instrument | measures where the time actually goes | inventory §4, and `docs/benchmarks/OPTIMIZATIONS-TODO.md:57-58` | blocked in this sandbox. `perf_event_open` is unavailable in the microVM. Unblocks A39, A40, A56, A94 | tooling | |
| B14 | a timing gate inside the test suite | makes a regression fail rather than print | inventory §4: no wall-clock or instruction-count instrument runs inside `tools/test/run-tests.sh` | absent | tooling | |
| B15 | a multi-value return form | lets a function return more than one slot | bucket 1, from A63 and A75 | absent. `ti-ret` at `lib/lowering/tal/ir.chiral:43` carries one `src` and `TalSig` at `lib/lowering/tal/ssa.chiral:44` carries one `ret`. Unblocks A63, A74, A75, C38 | IR | |
| B16 | an allocation group form | lets several constructions in one straight-line run share one bump check | bucket 4, from the sixteen-instruction `Q4` site | absent. Each `ti-cona` emits its own compare against `heapend` | IR, backend | |
| B17 | a vector type and vector operations | adds a wide register class and its ops | bucket 1, A53 | absent | IR, type system, backend | ? a permutation-shaped workload may reach further with narrower changes |
| B18 | a flat indexed array form | adds a value that holds n words with an index operation | bucket 5, and the erased-index rows | absent. A `Bytes` payload is the only indexable storage, reached one byte at a time | IR, surface, type system | |
| B19 | a placement certificate format | lets an untrusted allocator propose and a small checker verify | `docs/implementation/rd-packed-cert.md`, ratified 2026-08-02 | designed, zero code. `docs/benchmarks/OPTIMIZATIONS-TODO.md:8-10` states it. Depends on B3 | optimizer, backend | |
| B20 | a pass driver with an ordering and a fixpoint | runs passes to convergence instead of once | every catalogue: `GCCPASSES` and `GOSSA` both schedule repeats | absent. `opt-tfns` at `lib/lowering/compile-back.chiral:240` applies `fold` once per `TFn` | optimizer | |
| B21 | a pass-level enable switch | lets a pass be measured alone against the self-hosting fixpoint | inventory §1: `dead` alone grades `33 passed, 9 failed` and `fold` alone `42 passed, 0 failed`, recorded at `lib/lowering/compile-back.chiral:228-238` | absent as a mechanism. The measurement was taken by editing the pipeline | optimizer, tooling | |

**Bucket B total: 21.**

## Bucket C. The `Op` sum and the surface bindings

`lib/prelude/prelude.chiral:36-39` declares fifteen constructors and `:58-71`
binds fourteen of them at the surface. Every operation a current ISA offers and
this set lacks is a row here. Two structural facts shape the whole bucket.

The sum is closed and every consumer matches it exhaustively, so one new
constructor edits `op-name` (`lib/prelude/prelude.chiral:44`), `op-parse`
(`lib/lowering/tal/erase.chiral:91`), `op-bytes`
(`lib/lowering/x64/mach.chiral:351-387`) and the clobber table (`:1433`). That
is the cost of every C row that adds a constructor. The alternative is C35 to
C37: recognize the idiom in the backend and add no constructor at all.

`ti-prim` is binary. A unary operation has no representation in the erased IR
regardless of whether the sum names it, which is why B6 sits under so many rows
here.

| # | candidate | what it does | source | status here | touches | doubtful |
|---|---|---|---|---|---|---|
| C1 | rotate left | rotates a word left by a count | bucket 3, x86 `rol` | absent. `rotl32` at `lib/crypto/chacha.chiral:24` spends four operations on what one instruction does | surface, IR, backend | |
| C2 | rotate right | the same, rightward | bucket 3, x86 `ror` | absent | surface, IR, backend | |
| C3 | byte swap | reverses byte order in a word | bucket 3, x86 `bswap` | absent, and blocked by B6. Every little-endian pack and unpack in the byte library is the consumer | surface, IR, backend | |
| C4 | count leading zeros | counts high zero bits | bucket 3, x86 `lzcnt` and `bsr` | absent, blocked by B6 | surface, IR, backend | |
| C5 | count trailing zeros | counts low zero bits | bucket 3, x86 `tzcnt` and `bsf` | absent, blocked by B6 | surface, IR, backend | |
| C6 | population count | counts set bits | bucket 3, x86 `popcnt` | absent, blocked by B6 | surface, IR, backend | |
| C7 | conditional move | selects one of two words on a condition with no branch | bucket 3, x86 `cmov` | absent, and blocked by B7. Also the constant-time primitive a cipher wants | surface, IR, backend | |
| C8 | add with carry | adds two words plus a carry bit | bucket 3, x86 `adc` | absent, and blocked by the single-slot result: the carry out has nowhere to go | surface, IR, backend | |
| C9 | subtract with borrow | the same, subtracting | bucket 3, x86 `sbb` | absent, blocked the same way | surface, IR, backend | |
| C10 | bit deposit | scatters low bits of a source into a mask's set positions | bucket 3, x86 `pdep` | absent | surface, IR, backend | ? BMI2 availability is a target question this tree has not asked |
| C11 | bit extract | gathers a mask's selected bits into the low end | bucket 3, x86 `pext` | absent | surface, IR, backend | ? same |
| C12 | bit field extract | extracts a run of bits given a start and a length | bucket 3, x86 `bextr` | absent | surface, IR, backend | ? expressible as a shift and a mask, so this is a code-size row |
| C13 | unsigned less-than | compares two words as unsigned | bucket 3. `op-lti` is signed | absent. Every comparison in the sum is signed, so an unsigned length or index comparison is open-coded | surface, IR, backend | |
| C14 | unsigned less-or-equal | the same | bucket 3 | absent | surface, IR, backend | |
| C15 | unsigned division | divides two words as unsigned | bucket 3, x86 `div` against `idiv` | absent. `x-idiv-rcx` at `lib/lowering/x64/mach.chiral:195` is the signed form, and the Euclidean correction at `x-div-fix` exists to fix its sign | surface, IR, backend | |
| C16 | unsigned modulo | the same | bucket 3 | absent | surface, IR, backend | |
| C17 | unsigned multiply-high | the high word of an unsigned product | bucket 3, x86 `mul` against `imul` | absent. `op-mulhi` encodes the signed one-operand `imul` at `lib/lowering/x64/mach.chiral:319` | surface, IR, backend | |
| C18 | signed minimum and maximum | picks the smaller or larger of two words | bucket 3 | absent, and it wants C7 to avoid a branch | surface, IR, backend | |
| C19 | unsigned minimum and maximum | the same, unsigned | bucket 3 | absent | surface, IR, backend | |
| C20 | absolute value | the magnitude of a word | bucket 3 | absent, blocked by B6 | surface, IR, backend | |
| C21 | bitwise complement | inverts every bit | bucket 3, x86 `not` | absent, blocked by B6. Expressible as `bxor` against negative one, which is C37's case | surface, IR, backend | |
| C22 | negation | the additive inverse | bucket 3, x86 `neg` | absent as an op, blocked by B6. `x-neg-rax` at `lib/lowering/x64/mach.chiral:267` exists for the division correction | surface, IR, backend | |
| C23 | sign extension from a narrower width | widens with the sign bit | bucket 3, x86 `movsx` | absent, and it wants B8 to have a narrower width to widen from | surface, IR, type system | |
| C24 | zero extension from a narrower width | widens with zeros | bucket 3, x86 `movzx` | partial. `x-movzx-byte` at `lib/lowering/x64/mach.chiral:625` does it for one byte inside `ti-bget` and nothing exposes it as an operation | IR, backend | |
| C25 | bit test | reads one bit into the flags | bucket 3, x86 `bt` | absent | surface, IR, backend | ? a shift and a mask already fuse to two instructions |
| C26 | double-precision shift | shifts a 128-bit pair by a count | bucket 3, x86 `shld` and `shrd` | absent, blocked by the single-slot result | surface, IR, backend | |
| C27 | word-width load from a byte cell | reads eight bytes of a `Bytes` payload as one word | bucket 3 and bucket 4 | absent. `ti-bget` reads one byte, and `unpack-u32` is a library call through `prim2lib` | IR, backend | |
| C28 | word-width store into a byte cell | writes eight bytes in one store | bucket 3 and bucket 4 | absent. `ti-bput` writes one byte. The measured 944 B tail of `chacha-block` is sixteen `pack-u32` results and fifteen `bcat` results | IR, backend | |
| C29 | block copy | copies a run of bytes with one operation | bucket 3, x86 `rep movsb` | absent. `bcat` is a library call into `nb-bcat` | IR, backend | |
| C30 | block compare | compares two runs of bytes | bucket 3, x86 `rep cmpsb` | absent. `str-eq` routes to `nb-beq` | IR, backend | |
| C31 | block fill | writes one byte value across a run | bucket 3, x86 `rep stosb` | absent. `brepeat` routes to `nb-brepeat` | IR, backend | |
| C32 | a native 32-bit integer type | gives the surface and the IR a width that matches the algorithms | bucket 3, and the measured ChaCha lanes | absent. `add32` and `rotl32` at `lib/crypto/chacha.chiral:20-25` exist only to emulate it, at three and four operations each | surface, IR, type system, backend | |
| C33 | a surface binding for `mulhi` | gives the fifteenth constructor a name a program can write | bucket 3. The inventory records `op-mulhi` with no `(extern mulhi ...)` anywhere | absent. Everything below the surface already accepts it: `op-parse` takes the string, `op-bytes` encodes it, the clobber table has its entry | surface | |
| C34 | shift semantics for an out-of-range count | states what `shl` by 64 or more means, so the cheap encoding stays correct | bucket 5's semantics-first rule applied to bucket 3 | open. x86 masks the count to six bits and `x-shl-cl` at `lib/lowering/x64/mach.chiral:331` inherits that. No document in `docs/` states the language's answer | surface, type system | |
| C35 | backend recognition of the rotate idiom | matches `(bor (shl x n) (shr x (- w n)))` and emits one rotate | bucket 3's alternative to a constructor | absent. Costs no change to the closed sum | backend | |
| C36 | backend recognition of the narrow-width idiom | matches a mask against a width constant and emits the narrow-register form | bucket 3's alternative to C32 | absent. `band` against 4294967295 is one x86 `mov` between 32-bit registers | backend | |
| C37 | backend recognition of the complement idiom | matches `bxor` against negative one and emits `not` | bucket 3's alternative to C21 | absent | backend | |
| C38 | a two-result prim form | lets one operation define two slots, which the full product, the carry chain and the divide-modulo pair all want | bucket 3, aggregated | absent. Depends on B15. It is what would let C8, C9, C17 and C26 exist at all | IR | |

**Bucket C total: 38.**

## Bucket D. The measured profile

Every figure below is quoted from `docs/benchmarks/crypto-kernel-allocation.md`
at `ea31370` unless another file is named. That document is **self-hosted**: its
subject is `bin/chirality-bin`, sha256 prefix `7d971a30c0bfda52fc2d952b`. The
older cross-language figures in `docs/benchmarks/language-performance.md` and
`RESULTS-2026-08-01.md` are **Python-hosted**, and no row here leans on them.

The measured shape: 12.9 to 14.0 MB/s at quiet load, 178 to 194 cycles per byte
by conversion from wall clock and no cycle counter read, 5,776 B allocated per 64-byte block, a static
count of 35 operations per byte, and an in-tree non-allocating control running
3.1 to 3.4x faster at quiet load.

| # | candidate | what it does | source | status here | touches | doubtful |
|---|---|---|---|---|---|---|
| D1 | unbox a product returned from a function | returns `Q4`'s four lanes in slots so the cell is never built | bucket 4, §1a: eighty `Q4` at 40 B and ten `St` at 136 B per block, 4,560 B in `rounds` alone | absent, blocked by limitation 4 and B15. `sB` is the hand-written proof that the same arithmetic allocates zero | IR, optimizer | |
| D2 | sink an allocation into the arm that consumes it | builds a cell only on the path that keeps it | bucket 4, §1c: the `Q4` site is 16 instructions on the taken path | absent | optimizer | |
| D3 | reuse the bump-top cell when the producer is the only consumer | writes the new value over the cell just allocated | bucket 4, and the arena's own shape | absent, blocked by limitation 4 | IR, backend | |
| D4 | hoist the bump check across an allocation group | pays one compare against `heapend` for a run of constructions with a known total size | bucket 4, §1c: `x-galo` emits its own compare and `lea` per site | absent, wants B16 | backend | |
| D5 | construct a cell from live values without the slot round trip | writes fields from where the values already are | bucket 4, §1c: the lanes arrive from `[rbp-…]` slots and the cell is a second copy | absent, wants B3 | backend | |
| D6 | give the arena a reclaim or rewind point | returns bytes the program can prove are dead | bucket 4: `heapptr` only advances, and 0.120 to 0.135 s of a 0.484 s median is kernel time faulting 578 MB of fresh arena | absent | runtime, backend | |
| D7 | replace the quadratic accumulator with a sized output buffer | writes each block into one preallocated buffer | bucket 4, the stream section: `chacha-xor` allocates 295 to 1,191 B per message byte across four sizes, and both allocation and time climb toward 4x per doubling | absent | surface, optimizer | |
| D8 | extend a byte cell in place when it is the bump top | appends with no copy and no new cell | bucket 4, and the linearity row F7 | absent, blocked by limitation 4 | IR, backend | |
| D9 | lift a top-level constant definition into static data | emits the bytes once at a fixed address | bucket 4: a top-level `(def name Bytes ...)` is re-evaluated at every reference, 336 B per reference for a 32-byte key and 88 B for a 12-byte nonce | absent. This is A84 with a measurement attached | optimizer, backend | |
| D10 | memoize a top-level definition at first reference | evaluates once at run time and caches | bucket 4, the same measurement | absent | runtime | ? D9 subsumes it wherever the definition is total and closed |
| D11 | build a serialized block with word stores | replaces sixteen `pack-u32` and fifteen `bcat` with wide writes into one cell | bucket 4, §1a: the 944 B tail of `chacha-block` | absent, wants C27 and C28 | optimizer, backend | |
| D12 | an instruction-count instrument | gives the 35-against-110 gap a mechanical reading instead of a conversion | bucket 4, §3, and the inventory's §4 note that no such instrument runs in the suite | absent. Same need as B13 and B14 | tooling | |
| D13 | separate the two allocators in the counter | tells `x-alo` traffic from `x-galo` traffic | bucket 4, "What this does not establish" | absent | tooling | |
| D14 | measure spills and register pressure | counts what the memory-machine design costs across a kernel | bucket 4, the same section: counting spills was never attempted, and sixteen lanes plus four working values already reach the stack | absent | tooling | |
| D15 | a `gcc -O2` comparison for a real cipher | places the self-hosted compiler against a mature one on the same kernel | bucket 4: the comparison never ran, and every cross-language band in the tree is Python-hosted | absent | tooling | |
| D16 | attack the text matcher's allocation | the same cell-per-step shape at a different scale | `docs/benchmarks/text-matcher-allocation.md`, self-hosted: 1.11 GB total, matcher 86.8%, OOM-killed at the default scope | absent | optimizer | |
| D17 | attack `str-split` and `blank-spans` | two named per-stage shares of that gigabyte | the same file: 6.3% and 6.8% | absent | surface, optimizer | |
| D18 | hardware performance counters on bare metal | replaces the cycles-per-byte conversion with a reading | `docs/benchmarks/OPTIMIZATIONS-TODO.md:57-58` | blocked in this sandbox | tooling | |

**Bucket D total: 18.**

## Bucket F. What this language's own structure licenses

These rows come from totality, linearity, erased indices, refinement types, the
closed `Op` sum, module categories and the certificate discipline. A generic
pass catalogue carries none of them, because each rests on a fact the type
system has already proven and a C compiler would have to recover by analysis.
Two of the seven pinned catalogues reach part of this territory: GHC and flambda
both exploit purity, and neither has a totality proof, a quantity or a
refinement to work with.

`docs/benchmarks/TRAIT-OPTS.md` is the previous survey of this axis and its
rows are marked as already-named.

### F-i. Totality

`tot-gate` at `lib/typing/totality-check.chiral:153` runs on the compile path
and its verdict is consumed at `lib/lowering/compile-front.chiral:371`. No
optimizer reads it. `TotalR` is one verdict for the signature, which is B10.

| # | candidate | what it does | source | status here | touches | doubtful |
|---|---|---|---|---|---|---|
| F1 | compile-time evaluation licensed by a termination proof | runs a proven-total function on constant arguments at compile time with no fuel and no step limit | bucket 5. Already named in `docs/benchmarks/TRAIT-OPTS.md`'s totality row and as ledger item 13 | absent, blocked by B10 and B1. Zig's comptime and C++ `constexpr` both bound the same risk with fiat or fuel, and a total language reaches it by forbidding partiality. This tree can have it in a partial language | optimizer, type system | |
| F2 | full unrolling licensed by the termination proof | unrolls a recursion on a constant argument to completion, with the proof standing in for a trip-count analysis | bucket 5, applied to A42 | absent, blocked by B10 and B1. `(rounds s0 10)` at `lib/crypto/chacha.chiral:128` is the case, and A42's usual blocker (limitation 2) does not apply, because unrolling a proven-total recursion needs no loop form | optimizer | |
| F3 | hoisting a call out of an arm, licensed by totality | moves a total pure call above a branch with no divergence risk | bucket 5, applied to A18 and A41 | absent, blocked by B10. In C the same move needs a proof the call terminates and has no effect, which is why LICM is conservative about calls | optimizer | |
| F4 | memoizing a pure call across the build | caches one evaluation of a total call and reuses it for every identical site | bucket 5. Named in the parked menu as the memoized comptime evaluator | absent, blocked by B10 | optimizer | |
| F5 | speculating both arms of a branch | evaluates both sides when both are total and cheap, then selects | bucket 5, and C7 | absent | optimizer, backend | ? it wants a select form and a cost model before it is worth anything |
| F6 | partial evaluation of an interpreter against a program | the first Futamura projection, with the totality proof replacing the fuel limit | bucket 5. Named in `docs/benchmarks/TRAIT-OPTS.md`'s specialization row | absent. `specialize-raw` is the mechanism and the policy is the open half | optimizer | |

Count: 6.

### F-ii. Linearity

A `1`-quantity binder is a static single-owner proof. Perceus and Lean both
reach the same reuse through a runtime refcount test; here the fact is in the
kernel judgment. Every row is blocked twice: quantities are dropped by `peel-pi`
at `lib/lowering/compile-front.chiral:85`, which keeps `dom` and discards `q`,
and there is no field-update form.

| # | candidate | what it does | source | status here | touches | doubtful |
|---|---|---|---|---|---|---|
| F7 | in-place field update with no alias analysis | writes through a linear binder's cell instead of allocating a new one | bucket 5. Named in `docs/benchmarks/TRAIT-OPTS.md`'s linearity row | absent, blocked by B9 and limitation 4 | IR, type system, backend | |
| F8 | in-place byte-cell extension at the bump top | appends to a linear `Bytes` value that is the last cell allocated | bucket 5, and the measured quadratic in D7 | absent, blocked the same way. The bump-top test is a pointer comparison, which the arena makes trivially decidable | IR, backend | |
| F9 | arena rewind at a linear value's last use | pops the bump pointer back when a linear cell is consumed and nothing can alias it | bucket 5, and D6 | absent, blocked by B9. Neither a collector nor a refcount is needed for it, which is the part no catalogue carries | IR, runtime | ? it needs the last use to be the bump top, so it applies to a stack-shaped subset |
| F10 | destination-passing for a linear result | lets a caller supply the cell the callee writes into | bucket 5, and D5 | absent, blocked by B9 and limitation 4 | IR, surface | |
| F11 | eliding a defensive copy at a crossing | skips a copy that only exists because ownership was unclear | bucket 5 | absent | IR, backend | ? no measurement here shows such a copy today |

Count: 5.

### F-iii. Erased indices and quantities

| # | candidate | what it does | source | status here | touches | doubtful |
|---|---|---|---|---|---|---|
| F12 | monomorphization with no code-size heuristic | specializes on an index that is already gone at run time, so the specialized copy costs nothing extra to run | bucket 5 | partial. `specialize-singletons` at `lib/lowering/upper/specialize-singleton.chiral:229` monomorphizes a function-bearing record built exactly once, and nothing generalizes it | optimizer | |
| F13 | flat layout for a size-indexed type | lays out `n` fields contiguously when `n` is an erased index the checker knows | bucket 5, and B18 | absent | IR, type system | |
| F14 | dropping the work that produces an erased value | never computes what a `0`-quantity binder receives | bucket 5 | partial. `tnc-keep` at `lib/lowering/compile-front.chiral:136` drops the argument at every call site. Nothing walks back to delete the computation that would have produced it, because the argument is a type `Term` that never became code | optimizer | ? in the present peel the producer may not exist at all |

Count: 3.

### F-iv. Refinements

A refinement lowers to its base at `lib/lowering/compile-front.chiral:69`,
inside the type peel `term->ntalty`. That single arm is the blocker under every
row here, and it is B9's first seat.

| # | candidate | what it does | source | status here | touches | doubtful |
|---|---|---|---|---|---|---|
| F15 | bounds-check elision from a refinement | drops an index guard the type already discharged | bucket 5. Named in `docs/benchmarks/TRAIT-OPTS.md`'s refinement row | partial above lowering, absent below it. `mem-put-checked` at `lib/memory/mem-linear.chiral:26` carries the bound in the type, and the fact stops at the peel | type system, optimizer | |
| F16 | Euclidean correction elision | drops the sign-fix sequence when the dividend is proven non-negative | bucket 5, the same row | absent, blocked by B9. `x-mod-fix` at `lib/lowering/x64/mach.chiral:241` is the seven-instruction sequence in question | backend, type system | |
| F17 | guarded-read elision | drops a three-way range guard on a byte read the type already bounds | bucket 5, applied to `cc-at` at `lib/crypto/chacha.chiral:30-35`, which runs on every byte of key, nonce and message | absent, blocked by B9 | type system, backend | |
| F18 | unsigned reasoning from a non-negativity proof | uses the unsigned compare and the logical shift where the type proves the value non-negative | bucket 5, and C13 | absent, blocked by B9 | type system, backend | |
| F19 | width narrowing from a range proof | drops the mask when a value is proven to fit a narrower width | bucket 5, and the measured `band M32` in `add32` and `rotl32` | absent, blocked by B9 and B8 | type system, IR, backend | |
| F20 | shift-count elision | drops a count mask when the type proves the count is in range | bucket 5, and C34 | absent, blocked by B9 | type system, backend | |
| F21 | a proof-carrying `Op` | attaches to each operation the refinement its cheap encoding requires, so the encoding choice is a type check | bucket 5, generalizing F16 to F20 | absent | type system, IR | ? it changes the closed sum's shape, which every consumer matches |

Count: 7.

### F-v. Closed sums, categories and the module system

| # | candidate | what it does | source | status here | touches | doubtful |
|---|---|---|---|---|---|---|
| F22 | dense tags with no density analysis | indexes a table by a tag that declaration order already made dense | bucket 5. Named in `docs/benchmarks/TRAIT-OPTS.md`'s tables row | present. `table-of` and `jtb-codes`, and the inventory records that neither emits a bounds check | backend | |
| F23 | total coverage with no default arm | omits the unreachable fallback because the checker proved the arms exhaust the sum | bucket 5 | partial. `tt-case` at `lib/lowering/tal/ssa.chiral:38` still carries a `(Maybe Block)` default | IR, backend | |
| F24 | transparent single-constructor products | represents a one-constructor type as its fields with no tag and no cell | bucket 5, and D1 | absent. `is-enum` at `lib/lowering/tal/erase.chiral:75` boxes any fielded constructor. `Q4` and `St` are both single-constructor | IR, backend | |
| F25 | reordering licensed by the module category | moves or deletes a call because the module declares category A, with no effect analysis | bucket 5 | absent as a pass. The fact is present and unread: the effect-row half (`row-check`, `eff-gate`) is compiled out of the compile path per the inventory | optimizer, type system | |
| F26 | dead-call elimination from the frozen port set | treats a call into a port the manifest forbids as unreachable | bucket 5. `ports-manifest` at `lib/lowering/compile-front.chiral:296` intersects the declared profiles into one permitted set | absent as a pass; the manifest is a gate that answers a verdict | optimizer | |
| F27 | whole-signature interprocedural passes with no link step | uses the single `Sig` the batch loader builds | bucket 5, and A72 | present as a precondition, unused by any interprocedural pass | optimizer | |

Count: 6.

### F-vi. The certificate discipline

`re-check` at `lib/lowering/upper/optimize.chiral:250` adopts a residual only
through `chk-ok`, which `ck-fn` must form. This is the structural fact that
separates this tree from CompCert's position: a verified transformer must be
conservative once, and a checked artifact lets the producer be reckless every
time.

| # | candidate | what it does | source | status here | touches | doubtful |
|---|---|---|---|---|---|---|
| F28 | an untrusted search-based optimizer | lets an enumerative, stochastic or model-proposed rewriter run outside the trusted base | bucket 5. Named in `docs/benchmarks/OPTIMIZATIONS-TODO.md:61-84` | absent, blocked by B12. `re-check` proves types and says nothing about meaning | optimizer | |
| F29 | a checked register allocator | lets an untrusted allocator propose placements and a small checker verify them | bucket 5, and B19. Ratified at `docs/implementation/rd-packed-cert.md` | designed, zero code, blocked by B3 | optimizer, backend | |
| F30 | translation validation for the byte emitter | checks each emitted artifact against its tal source, closing the last trusted gap | bucket 5. Named in `docs/benchmarks/OPTIMIZATIONS-TODO.md:81-84` | absent. `lib/lowering/tal/eval.chiral` is the differential oracle and no module imports it | optimizer, backend | |
| F31 | the self-hosting fixpoint as a pass acceptance gate | grades a pass by whether the compiler still compiles itself correctly | bucket 5 | present as a practice, absent as a mechanism. It is how `dead` was excluded, and B21 is the switch that would make it repeatable | tooling | |
| F32 | determinism as an admission criterion for a new pass | refuses a pass whose iteration order is unstable, because byte-identity is the self-host's own gate | bucket 5, and ledger element 11 | present as a convention. No check rejects a nondeterministic pass at admission | tooling, optimizer | |
| F33 | placing fact-consuming passes above the erasure seam | runs the passes that need types before `erase-fn` discards them | bucket 5 | absent as a policy. `fold` runs on `TFn` above erasure and reads no type fact; every other transformation runs below it | optimizer | |
| F34 | choosing semantics so the cheap encoding is correct | settles an open semantic question in favour of the encoding that needs no fixup | bucket 5, and ledger element 6, which records Euclidean division as the case already settled | present for division, open for shifts and string indexing. C34 is the live instance | surface, type system | |

Count: 7.

**Bucket F total: 34.**

## Totals

| bucket | what it drew from | count |
|---|---|---|
| A | the classical pass catalogue, seven pinned pass lists | 110 |
| B | the four IR limitations and the enablers found beside them | 21 |
| C | the `Op` sum and the surface bindings | 38 |
| D | the measured profile | 18 |
| F | this language's own structure | 34 |
| | **total** | **221** |

Blocked rows, by the limitation that blocks them:

| blocker | rows |
|---|---|
| limitation 1, no interprocedural fact | A57, and F1 to F4 in part |
| limitation 2, no loop form | A41 to A49, A53, A54 |
| limitation 3, no location vocabulary | A12, A88 to A91, and F29 |
| limitation 4, no non-allocating product | A74, D1, D3, D8, F7, F8, F10 |
| the missing CFG, beyond the four | A27, A28, A29, A32 |
| the binary-only prim form | A23, C3 to C6, C20 to C23 |
| the single-slot return | A63, C8, C9, C26, C38 |
| the refinement drop at the peel | A13, A54, F15 to F21 |
| the collapsed totality verdict | F1 to F4 |
| no counter instrument in this sandbox | A39, A40, A56, A94, D18 |

Rows carrying a doubtful mark: 21.

## What this list does not do

It does not rank, score, or order. It does not estimate what any row is worth.
It does not claim that a `blocked` row is worth unblocking, only that the
blocker is the reason it cannot be tried today. Several rows overlap on purpose:
A73, A75, D1 and F24 all attack the same measured cells from four different
catalogue traditions, and the next stage decides whether that is one candidate
or four.
