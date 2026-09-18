---
node: arc-lowering-and-emit
layer: navigation
related: [arcs/README, goals/self-hosting, arcs/enforcement-arc, arcs/emitted-speed-arc, arcs/checker-core-arc, arcs/sys-face-arc, arcs/independent-judgment-arc, arcs/ownership-and-trust-arc, arcs/runtime-loading-arc, banks/verification, banks/erasure, banks/module, status-ledger, bug-classes, working-discipline, decisions/decision-scope, decisions/decision-work-ids, decisions/decision-backend, elements/catalog, records/homing-triage, records/findings, records/lenses/problems, records/author-calls, index]
status: current
updated: 2026-09-18
---

# Arc: lowering-and-emit

- goals: [[goals/self-hosting]], condition 5: "Every built element of the
  compiler holds a roster row in an arc." The same goal's condition 4 is served
  by requirements 1, 2 and 3 below, which state over this arc's own code the
  reach and assertion that condition names. `docs/goals/self-hosting.md:102-107`
  is the table that names this arc as one of four subject arcs, opened
  2026-09-18, and `:92-100` gives it both conditions in one sentence: each
  "rosters the elements of that subject that no other arc rosters, and states
  over the same code the reach and assertion requirements condition 4 names". No
  second goal is served. [[goals/enforcement]], [[goals/emitted-speed]] and
  [[goals/independent-judgment]] were each tested against this roster and each
  is refused under *What this arc does not take*. **Conditions 1 to 3 are not
  claimed**, and `LE24` states why while taking the phase that would gate them.
- reserved element block: **none**. Twenty-three of the twenty-four rows carry an
  element minted long before this file, and the arc-local ids per
  [[decisions/decision-work-ids]] spell the letters `LE`, for lowering and emit:
  `lowering-and-emit/LE1` upward. A grep for `LE` followed by a digit over
  `docs/`, `records/` and `.planning/` returns nothing, verified 2026-09-18. The
  subject's category code in `docs/elements/ledger.md:128` is `CG`, which
  [[arcs/checker-core-arc]]'s `CK` follows; `CG` is declined here because a grep
  for `CG` followed by a digit hits `.planning/sources/PDFSPEC.txt:48609`, where
  it is a PDF content-stream operator, so the id would not be greppable. The
  two-letter form follows `sys-face`'s `SF`, `checker-core`'s `CK` and
  `tool-authority`'s `TA`.
- build-state authority: [[status-ledger]]
- checklist: none. No `records/lowering-and-emit.md` exists.
- neighbour: [[arcs/emitted-speed-arc]], stated in full under *What this arc does
  not take*. That arc owns what emitted code costs. This arc owns whether the
  emitter's own parts are reached and gated at all.

## Why this arc exists

Condition 5 is the homing invariant [[goals/README]] states at `:27`. Measured
2026-09-18 against the working tree: `docs/elements/ledger.md` §CG holds 25 rows,
five of them already rostered (`E16`, `E17` and `E18` by
[[arcs/enforcement-arc]], `E71` by [[arcs/ownership-and-trust-arc]], `E146` by
[[arcs/file-types-arc]]), and **twenty hold no roster row anywhere**. The goal's
own cell for this arc names thirteen elements and three of them sit outside §CG:
`E34` in §FMT, `E69` and `E95` in §EF. None of the three holds a roster row
either, and each is named in the cell's subject sentence, so this arc takes
twenty-three rows and the seam is that sentence rather than the category alone.

Condition 4 reads the same claim over the compiler's parts. Its failure shape is
`docs/definitions/bug-classes.md:171-173`: a rule can be written, compile
cleanly, pass the suite, get marked built in the catalog, then run on no path.
This subject is where that shape is cheapest to observe, because the emit path
ends in an artifact a person can run. **Nine roots exist that were written to
verify elements of this roster, six of them pass when run by hand, and no phase
script names one of the nine.**

## What the tree already holds

Measured 2026-09-18 against the working tree. [[banks/INDEX]] holds thirteen and
three own pieces of this territory. [[banks/erasure]] refracts the three
independent droppings and places representation erasure at
`lib/lowering/tal/erase.chiral`, which is where the porttype carriers of `G2`
land. [[banks/verification]]'s backend shard is the 37-field `Mach` seam at
`lib/lowering/mach/mach.chiral`, used beside `lib/lowering/x64/mach.chiral` and
`lib/lowering/listing/mach.chiral`, and its own ⚑ at
`docs/banks/verification.md:309` records that the third instance went with the C
target on 2026-09-01. [[banks/module]] §4 refracts the namespace question and
places the label collision of `G4` at the codegen tier rather than the design
tier. None is re-derived below.

| group | what exists today | where | rung |
|---|---|---|---|
| G1 the upper pipeline | lowering, pure terms to tal with slot allocation, 420 lines inside the closure and reached by every compile. `docs/elements/catalog.md` and `enforcement/N6` both cite it at 407 lines | `lib/lowering/upper/lower.chiral`, driver `lib/lowering/compile-back.chiral:252` | IMPLEMENTED |
| G1 | closure conversion and quantities-to-tal, 1,434 lines plus a 295-line stateful driver that `lib/lowering/compile-front.chiral` imports, so both are inside the closure. Quantities reach the floor through `dqty->i` | `lib/lowering/upper/closconv.chiral`, `lib/lowering/upper/closconv-driver.chiral:30` | IMPLEMENTED |
| G1 | ⚑ **`E69`'s catalog cell reads "not built" over a driver the compiler imports.** `docs/elements/catalog.md:263` says *"not built; 'later milestone' prose only until now"*; the ledger row was corrected to `built` on 2026-09-04 and `closconv.chiral:1` names the element in its own first line | `docs/elements/catalog.md:263` against `lib/lowering/upper/closconv.chiral:1` | a false claim |
| G1 | the signature pre-scan, built: `def-sigs` is declared at `lib/lowering/compile-back.chiral:77`, defined at `:78`, and called at `:336` before the per-function loop, so a mutually recursive effectful call resolves at lowering with no forward-reference failure | `lib/lowering/compile-back.chiral:77-80`, `:336` | IMPLEMENTED |
| G1 | ⚑ **effectful mutual recursion works and its catalog cell says it does not.** Measured 2026-09-18 by a four-line probe: two `=>` functions calling each other through one `(declare ...)` compile and the program exits 42. `docs/elements/catalog.md:419` reads *"Not built; scriba blob loads clean (E94 provides capacity) but `compile-main` label dropped during effectful mutual recursion"* | probe recorded on `LE5`; `docs/elements/catalog.md:419` | a false claim |
| G1 | ⚑ **the loader still requires the `(declare ...)`.** The same probe with the forward declaration removed fails at `load: unknown name is-odd`, so the pre-scan `E93` delivers sits at the lowering stage and surface name resolution is unchanged | probe recorded on `LE4` | IMPLEMENTED as scoped |
| G1 | the skip chain as typed values, built: `SkReason`, `SkRec` and the blame formatter in one 122-line decl home named for the element on its first line, imported by `lib/lowering/compile-back.chiral:20` and joined into `r-skipped` by `lib/typing/diag.chiral` rather than copied | `lib/lowering/skip-diag.chiral:1`, `lib/typing/diag.chiral:57` | IMPLEMENTED |
| G1 | ⚑ **the per-expression skip reason is still a bare string.** `ExprR`'s `er-skip` carries `(reason Str)` and three of its construction sites `str-cat` a message, so the typed sum landed at the `lower-defs` level and `lower.chiral`'s own arm did not move. `docs/elements/catalog.md:424` puts the file at 79 lines against 122, and the `native-prim?` resolution it demands is discharged by deletion: a grep over `lib/` and `prog/` returns nothing | `lib/lowering/upper/lower.chiral:125`, `:239-246` | IMPLEMENTED in part |
| G1 | ⚑ **`E94`'s capacity limit has no measurement in the tree and its two authorities disagree about what it is.** The ledger reads `flight` and the catalog reads *"Not built; scriba compiles without linkage, fails with all 5 linkage files"*. No count of forms or data types appears in either, and `records/lenses/unspoken.md` UNS-34 admits the element as unhomed | `docs/elements/ledger.md:135`, `docs/elements/catalog.md:399` | unmeasured |
| G2 the floor and its carriers | the erase peel and its prim-to-library table, 285 lines inside the closure, which is where a handle porttype becomes a machine word | `lib/lowering/tal/erase.chiral` | IMPLEMENTED |
| G2 | the three porttype carriers, all three built and each with a landed root. `e123_porttype_carrier.prog` and `e145_be_peek_roundtrip.prog` both exit 42, run 2026-09-18 | `prog/samples/`, `tools/test/samples/` | IMPLEMENTED |
| G2 | the primitive families, built at the surface with the encoder arms behind them: `band`, `bor`, `bxor` and `shl` as externs at `lib/prelude/prelude.chiral:67-70` with their `Op` constructors at `:38-39`, `shr` and `sar` beside them, and `bput-u16-le` at `lib/lowering/tal/bytes.chiral:628` | `lib/prelude/prelude.chiral`, `lib/lowering/tal/bytes.chiral:628` | IMPLEMENTED |
| G2 | ⚑ **the roots that verify them pass and nothing dispatches them.** `e108_shift.prog` and `e109_bput_u16_le.prog` both exit 42, run 2026-09-18, and neither basename appears in any `tools/test/*.sh` | `prog/samples/e108_shift.prog`, `prog/samples/e109_bput_u16_le.prog` | absent |
| G3 the machine and the file | the x86-64 encoder, 1,766 lines inside the closure, driving a target-independent 573-line `emit-core` through the 37-field `Mach` seam with a 170-line relocation pass | `lib/lowering/x64/mach.chiral`, `lib/lowering/mach/emit-core.chiral`, `lib/lowering/mach/asm-reloc.chiral` | IMPLEMENTED |
| G3 | ⚑ **`E19`'s catalog cell names four modules and one of them exists nowhere.** `docs/elements/catalog.md:119` reads *"**Already chirality** `lib/emit-core/mach/mach-x64/asm-reloc`"*; `find lib -name 'mach-x64*'` returns nothing and the other three moved under `lib/lowering/mach/` and `lib/lowering/x64/` | `docs/elements/catalog.md:119` | a stale citation |
| G3 | ⚑ **exactly one gate script names any file of the code generator, and it belongs to another element.** `tools/test/mul-widen.sh` is Phase 32 under `E189`'s name. A grep for `op-bytes`, `x64/mach`, `mach.chiral`, `elf.chiral` and `emit-core` over `tools/test/*.sh` returns that one file | census over `tools/test/*.sh`, 2026-09-18 | absent |
| G3 | the executable format, built and on every path: `elf-file` wraps an emitted code batch in a 64-byte Ehdr plus one 56-byte PT_LOAD, `lib/lowering/compile-emit.chiral:18` imports it and `:144` calls it, so every ELF this tree emits is that function's output | `lib/lowering/x64/elf.chiral:79` | IMPLEMENTED |
| G3 | ⚑ **the element's own header contradicts its own code, and the code is the reasoned half.** `:6` says *"one 56-byte RX PT_LOAD"*; `:60` says *"RWX (PF_R|PF_W|PF_X = 7), not RX"* and gives the reason, the bump-pointer cells living in the same segment; `:70` writes `7`. `readelf -l bin/chirality-bin` reports one `RWE` LOAD, which agrees with the code | `lib/lowering/x64/elf.chiral:6` against `:60`, `:70` | a stale comment |
| G4 the blob and the path | import resolution, two providers pinned against each other and both live: the 434-line native resolver keyed on the root-relative path, and the shell provider the BUILD RULE uses. Extension order and the `(end-module "<key>")` marker are stated in both | `lib/module/resolve.chiral:13-20`, `bin/chirality-resolve.sh:248-257` | IMPLEMENTED |
| G4 | the multi-root search path, built: the resolver takes a list of roots spelled `-L <dir>` on `prog/resolve.prog`'s stdin (`:26`, parsed at `:53`), with no importer-directory leg at all, and a module's key is its root-relative path, which makes the basename-collision class unreachable rather than merely named | `lib/module/resolve.chiral:6-11`, `:30-38`, `prog/resolve.prog:53` | IMPLEMENTED |
| G4 | ⚑ **`E155`'s ledger row cites a line that says something else.** It quotes `tools/test/run-tests.sh:210` for the NOT PORTED notice; `:210` is a comment about `E157` and the Phase 11 line is at `:412` | `docs/elements/ledger.md:152` against `tools/test/run-tests.sh:412` | a stale citation |
| G4 | ⚑ **the flat label space still refuses two private names, reproduced 2026-09-18.** Two co-blobbed modules each defining one `helper` refuse at `duplicate label (an object def collides with the linked runtime): helper` with no ELF written. The refusal is `first-dup-go` and the message names a cause this probe does not have: the collision is object against object | `lib/lowering/compile-emit.chiral:304-305` | ENFORCED, with the wrong reason printed |
| G4 | the prefixed clones the defect forces, still in the tree: `lib/lowering/tal/check.chiral:52` defines `tck-ce-fns` against `lib/lowering/upper/lower.chiral:193`'s `ce-fns`, one of the eleven names prefixed `tck-` at `5b4fb71` | `lib/lowering/tal/check.chiral:22`, `:52` | a live workaround |
| G5 the instruments | the reference interpreter over the pure fragment, 109 lines, **zero importers**, outside the closure. ⚑ Its header at `:6` still reads *"runtime.py stays the oracle"* about a file that is gone | `lib/evidence/interp.chiral:6` | SEEDED |
| G5 | the target-side evaluator, 187 lines, zero importers, outside the closure. `enforcement/N13` places it with the interpreter above as the preserve-check's T1 pair | `lib/lowering/tal/eval.chiral` | SEEDED |
| G5 | ⚑ **the second conforming `Mach` has zero importers.** `lib/lowering/listing/mach.chiral` is 136 lines, emits a human-readable listing instead of bytes, and says in its own header that it *"exists to prove emit-core is genuinely target-independent"*. It is outside the closure and no file in `lib/`, `prog/` or `tools/` imports it, so the target-independence claim rests on an instance nothing runs | `lib/lowering/listing/mach.chiral:1-8` | SEEDED |
| G5 | the test floor, adopted: 1,023 lines, imported by `prog/test-runner.prog:28`, which Phase 2 rebuilds from source every run and gates by exit code. `docs/elements/ledger.md:154` records 854 lines at `f9441e4` | `lib/evidence/test-floor.chiral`, `tools/test/run-tests.sh:95-107` | IMPLEMENTED |
| G5 | ⚑ **eighteen fixtures sit on that floor and zero are dispatched.** Every file under `tools/test/samples/` importing `evidence/test-floor` counts eighteen, and no basename among them appears in any `tools/test/*.sh`. Phase 12 is the phase they were written for and `tools/test/run-tests.sh:413` prints it NOT PORTED over *"the phase SCRIPT and its mutant machinery"*, with the fixtures landed | census 2026-09-18; `tools/test/run-tests.sh:22`, `:413` | absent |
| G5 | Phase 2's manifest is six files: `exit42`, `exit7`, `multi-def`, `boxed-a`, `boxed-b` and `enum-tag`, against `prog/samples`' 69 files. `prog/test-runner.prog:23` records directory auto-discovery as `E170` W0.2 | `prog/test-runner.prog:40-45` | IMPLEMENTED as scoped |
| G6 the gate | the closure: 62 import targets resolve from `prog/compiler.prog` over `lib:prog` across the three extensions `MAP.md:20` names, carrying 17,674 lines against `lib/`'s 105 modules and 26,598. **27 of the 32 `lib/lowering/` targets are inside it** | measured 2026-09-18 | ENFORCED |
| G6 | the five outside, 944 lines: `tal/check` 312, `tal/eval` 187, `upper/eff-lower` 183, `listing/mach` 136, `tal/spec` 126. Three belong to elements this arc refuses and two are `G5`'s instruments | measured 2026-09-18 | SEEDED |
| G6 | ⚑ **the fixpoint compare runs, holds, and no phase performs it.** Run 2026-09-18: the blob regenerates in 1.193 s at 17,797 lines, generation one builds in 0.765 s at 1,220,984 B and is byte-identical to the committed `bin/chirality-bin`, generation two builds from generation one in 0.766 s, and `cmp` reports `C1 == C2`. **Under three seconds of wall clock, end to end.** `tools/test/run-tests.sh:412` gives Phase 11's blocker as *"no committed blob artifact to cmp against"* | `docs/definitions/working-discipline.md:26-33`, run here | absent |
| G6 | the root census, for the boundary rather than for a row: 103 roots carry `^(def compile-main` under `lib prog`, Phase 7's own selector, and **84 are named by no `tools/test/*.sh` at all**. Of the 84 the largest family is `prog/samples` at 50 | measured 2026-09-18 | absent |

Four facts from that table govern the roster. **The emit path is built and inside
the closure**, so no row here writes a pass from nothing. **The verification of
it is landed and undispatched**: nine roots, six of them passing by hand, zero
named by a phase, plus eighteen fixtures on a floor whose phase is unported.
**The state claims have drifted**, six of them measurably and two into plain
falsehood. **The one instrument that would give the emitter a second reading has
zero importers**, and the C leg that was its third is parked with its code
deleted.

## What is missing, and its structure

| group | owns |
|---|---|
| G1 the upper pipeline | pure terms to tal: closure conversion, defunctionalization at both levels, quantities to the floor, the signature pre-scan, mutual recursion, capacity, and the blame chain when a def is dropped. Every part is built and inside the closure. What is absent is a phase over any of it, and two of its state cells are false |
| G2 the floor and its carriers | the erase peel, the three porttype carriers, and the primitive families the surface declares. All built, each with a landed root that passes. What is absent is the dispatch |
| G3 the machine and the file | instruction encoding, relocation, the target-independent core, and the ELF wrapper. All on the path of every compile. What is absent is any assertion that discriminates one encoder arm from another, and the one gate script that touches the encoder belongs to `E189` |
| G4 the blob and the path | the two resolvers, the multi-root search path, and the flat label space beneath them. The resolvers are built and pinned by prose. The label space refuses a legal program and prints the wrong reason for it |
| G5 the instruments | a second reading of what the emitter decided: the source-side interpreter, the target-side evaluator, the listing target, the second C seam, and the floor the corpus lands on. The floor is adopted. Every other instrument has zero importers |
| G6 the gate | a phase that runs one of this arc's roots and judges what comes back, and a phase that rebuilds the artifact and compares it with itself. Neither exists. The second is measured above at under three seconds |

### The edges that run against the order

| edge | direction | what crosses |
|---|---|---|
| G6 to everything | against, and the loudest | G6 reads as last and is first. Nine roots already exist, six of them pass, and dispatching one is a `run_phase` line. Building further down the order adds parts to a pipeline whose existing verification is disconnected. `docs/definitions/bug-classes.md:171-173` names the class and this arc's own premise is that two state cells read the opposite of what a four-line probe returns |
| G4 to G1 | against | `E154`'s flat label space is why `lib/lowering/tal/check.chiral` carries eleven `tck-`-prefixed clones, and the module that needs them is `enforcement/N8`'s. So the cheapest-looking row in `G4` is the one that unblocks another arc, and reading `G1` before `G4` as a schedule leaves that arc's blocker standing |
| G5 to G3 | against | the listing target exists to hold `emit-core` to target independence and has zero importers, so the claim that `G3`'s core is target-independent has no instrument behind it. Reading `G3` as settled because it is built and reached inverts what reached means here: reached by the compiler, judged by nothing |
| G5 to G5 | out of this arc's reach | `LE23` is blocked on `LE22`'s Phase 12 and `LE21` is blocked on an author call. So the two instruments that would give the emit path a second independent reading cannot both be scheduled from here, and `LE20` half (a) is the one that can |
| G1 to G3 | out of this arc's reach | the preserve-check over what lowering produces is `enforcement/N6`, `N13` and `N14`, and `lib/lowering/tal/check.chiral` stays outside the closure by PRB-70's ruling. A session giving `ck-prog` a call site from here is building another arc's row |

## REQUIREMENTS

Six, each with the observation beside it, measured 2026-09-18.

1. **Every root that verifies an element of this arc is dispatched by a phase.**
   Observed as the root's basename appearing in a `tools/test/*.sh` script some
   `run_phase` line names, which is goal condition 4(b)'s own observation. Today
   zero of nine: `e100_poly_ho`, `e145_be_peek_roundtrip`, `e147_nested_ho`,
   `e108_shift`, `e109_bput_u16_le` and `e123_porttype_carrier` were run by hand
   here and pass; `e170_conv_eta`, `e170_infer_arms` and `e170_qtt_semiring`
   re-found another arc's rules on this arc's floor. Eighteen fixtures importing
   `evidence/test-floor` are dispatched by none.

2. **Every module an element of this arc names sits inside the compiler's import
   closure, or the row says why not.** Observed by resolving `(import "...")`
   transitively from `prog/compiler.prog` over `lib:prog` across the three
   extensions `MAP.md:20` names, which is goal condition 4(a)'s own observation.
   Today 62 targets and 17,674 lines, with 27 of the 32 `lib/lowering/` targets
   inside and five outside at 944 lines, plus `lib/evidence/interp.chiral` at 109
   lines and zero importers.

3. **The emitted artifact's identity is re-derived by a phase.** Observed as a
   phase building two generations from one regenerated blob and comparing them,
   each artifact checked non-empty first. Today no phase does it and
   `tools/test/run-tests.sh:412` gives a blocker the compare does not have. Run
   by hand here: 1.193 s to regenerate the blob, 0.765 s and 0.766 s for the two
   generations, `C1 == C2` byte-identical at 1,220,984 B, and `C1` equal to the
   committed binary.

4. **Every state claim over one of this arc's elements names code that says what
   the claim says.** Observed by opening each cited span and reading it. Today six
   fail: `E69`'s catalog cell reads "not built" over a driver inside the closure,
   `E95`'s reads "Not built" against a probe that exits 42, `E19`'s names a module
   path that exists nowhere, `E155`'s ledger row cites a line about `E157`,
   `E34`'s own header says `RX` against the `RWX` its code writes, and `E97`'s
   cell puts its file at 79 lines against 122 and demands a resolution already
   discharged by deletion. This is the class [[records/findings]] FD-27 states and
   `E76` worked.

5. **A name a module defines for itself cannot be broken by another module
   defining the same name.** Observed by co-blobbing two modules that each define
   one private helper and compiling. Today the compile refuses at
   `lib/lowering/compile-emit.chiral:304-305` with `duplicate label (an object def
   collides with the linked runtime): helper`, fails closed with no ELF written,
   and names a cause the case does not have.

6. **What the emitter decided is read by a second instrument that a phase
   reaches.** Observed as an instrument outside `lib/lowering/x64/` consuming the
   same program and being imported from something a phase runs. Today the three
   candidates have zero importers: `lib/lowering/listing/mach.chiral` 136 lines,
   `lib/lowering/tal/eval.chiral` 187 lines, `lib/evidence/interp.chiral` 109
   lines. The fourth was the C leg, parked 2026-09-01 with its code deleted.

## Roster

Twenty-four rows. Twenty-three carry an element minted long before this file and
homed by no roster until now, and one is unminted. Ids spell `LE`. **This arc
mints nothing and allocates no number.**

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `lowering-and-emit/LE1` | closure conversion and quantities-to-tal, built on the shipping path and stated unbuilt by its own catalog cell. `lib/lowering/upper/closconv.chiral` is 1,434 lines naming the element at `:1`, `closconv-driver.chiral:2` calls itself the stateful driver, and `lib/lowering/compile-front.chiral` imports it, so both are inside the closure; `dqty->i` at `closconv-driver.chiral:30` carries `q0`, `q1` and `qw` to the floor. `docs/elements/catalog.md:263` reads *"not built; 'later milestone' prose only until now"* while `docs/elements/ledger.md` was corrected to `built` on 2026-09-04. **Wanted**: the cell re-derived, and a phase that asserts a quantity reaching the floor. **Blocking condition**: none measured | G1 | law | bind | 1, 4 | built | `E69` |
| `lowering-and-emit/LE2` | poly-higher-order defunctionalization, whose erased type-kinded captures were the 2026-08-16 fix and whose root is dispatched by nothing. `field-erased?` drops a `q0` or `Type`-shaped capture at every materialization point in `closconv.chiral` and `closconv-driver.chiral`. `tools/test/samples/e100_poly_ho.prog` carries five cases and exits 0, run 2026-09-18; no `tools/test/*.sh` names it, and the file sits outside the `lib prog` tree Phase 7 selects over, so the suite does not even compile it. **Wanted**: that root under a phase. **Blocking condition**: none measured | G1 | law | bind | 1 | built | `E100` |
| `lowering-and-emit/LE3` | nested and higher-order defunctionalization, the second level, same shape and same silence. `arm-body` passes `(arm-rw-ctx fields)` so `rw` has the capture arrow types to dispatch on. `tools/test/samples/e147_nested_ho.prog` carries three cases and exits 0, run 2026-09-18, named by no script. `lower.chiral:280`'s `er-skip "higher-order application"` is the refusal this element retired and nothing asserts the retirement. **Wanted**: that root under a phase, with the pre-fix refusal as its control. **Blocking condition**: none measured | G1 | law | bind | 1 | built | `E147` |
| `lowering-and-emit/LE4` | the signature pre-scan, built and scoped narrower than its own title. `def-sigs` is declared at `lib/lowering/compile-back.chiral:77`, defined at `:78` and called at `:336` before the per-function loop; `ce-fns` is the `CEnv` accessor at `lib/lowering/upper/lower.chiral:193`. The catalog cell at `:387` cites *"line 74"* and *"`compile-back.chiral:211-226`"*, and `:211-226` is the prune pass. Measured 2026-09-18: a mutual `=>` pair with its `(declare ...)` removed fails at `load: unknown name is-odd`, so the pre-scan resolves the lowering forward reference and surface name resolution is untouched. **Wanted**: the two citations re-derived and the scope stated in the cell. **Blocking condition**: none measured | G1 | primitive | bind | 1, 4 | built | `E93` |
| `lowering-and-emit/LE5` | effectful mutual recursion, and its catalog cell is the plainest false claim on this roster. Measured 2026-09-18: `(def is-even (=> I64 I64) …)` and `(def is-odd (=> I64 I64) …)` calling each other, with one `(declare is-odd (=> I64 I64))`, compile and run to exit 42 through `bin/chirality-bin`. `docs/elements/catalog.md:419` reads *"Not built; scriba blob loads clean (E94 provides capacity) but `compile-main` label dropped during effectful mutual recursion"*. The ledger reads `built`. **Wanted**: the cell re-derived against the probe, and the probe committed as a root under a phase. **Blocking condition**: none measured | G1 | law | bind | 1, 4 | built | `E95` |
| `lowering-and-emit/LE6` | the form and type capacity limit, the one element of this roster with no measurement anywhere. The ledger reads `flight`, which the roster's closed vocabulary has no word for and which is written `building` here; `docs/elements/catalog.md:399` reads *"Not built; scriba compiles without linkage, fails with all 5 linkage files"*. Neither authority carries a count of forms or data types, nor names the constant that bounds them, so the element states a limit nobody has read off the code. `records/lenses/unspoken.md` UNS-34 admits it as unhomed and stands at `unreviewed`. **Wanted**: the limit located in `lib/surface/parse.chiral` or `lib/module/loader.chiral` and given a number, before anything is raised. **Blocking condition**: none measured. The five linkage files the cell blames are a scriba-tier claim this arc does not re-derive | G1 | primitive | bind | 4 | building | `E94` |
| `lowering-and-emit/LE7` | the skip chain, typed one level up and still a string where it starts. `lib/lowering/skip-diag.chiral` is 122 lines, names the element at `:1`, holds `SkReason`, `SkRec` and the blame formatter, and is imported by `lib/lowering/compile-back.chiral:20` and `lib/typing/diag.chiral:57`, which joins the chain into `r-skipped` rather than copying it. `ExprR`'s `er-skip` still carries `(reason Str)` at `lib/lowering/upper/lower.chiral:125` with three `str-cat` sites at `:239-246`. The `native-prim?` resolution the cell demands is discharged by deletion: a grep over `lib/` and `prog/` returns nothing. `docs/elements/catalog.md:424` puts the file at 79 lines. **Wanted**: the expression-level reason typed, the cell re-measured, and one blame chain asserted. **Blocking condition**: none measured | G1 | primitive | bind | 1, 4 | built | `E97` |
| `lowering-and-emit/LE8` | the word carrier for handle porttypes, built, with the `t-primty` mapping that stopped cap-crossings dropping to `(none)` at the peel. Its root passes and nothing runs it: `prog/samples/e123_porttype_carrier.prog` exits 42, run 2026-09-18, named by no script. `sys-face/SF14` cites this carrier in prose as the identity peel `E124` lowers through and rosters `E124` rather than this element. **Wanted**: that root under a phase. **Blocking condition**: none measured | G2 | primitive | bind | 1 | built | `E123` |
| `lowering-and-emit/LE9` | the non-word carrier, `Str` through the peel as `nt-str` with the tal-erase identity peel beside it, the `E123` residue taken separately. It is necessary and insufficient for `E137` by its own row, which names `E145` as the rest. No root exists for this half alone; the `E145` root exercises the pair. **Wanted**: a root that separates the `Str` carrier from the laundering peel, so a regression in one is distinguishable from the other. **Blocking condition**: none measured | G2 | primitive | bind | 1 | built | `E144` |
| `lowering-and-emit/LE10` | the `be-peek` laundering peel, a `ti-cona` duplicating a handle pointer into a `qw` base and a `q1` handle so a linear str-porttype threads without QTT scaling. `tools/test/samples/e145_be_peek_roundtrip.prog` exits 42, run 2026-09-18, named by no script. Its negative control is recorded in the ledger row and exists nowhere as a fixture: the plain `E144` form still failing `linear binder usage mismatch`. **Wanted**: the root under a phase with its negative control beside it. **Blocking condition**: none measured | G2 | primitive | bind | 1 | built | `E145` |
| `lowering-and-emit/LE11` | the bitwise family, four surface externs with encoder arms behind them and no assertion over either. `band`, `bor`, `bxor` and `shl` are externs at `lib/prelude/prelude.chiral:67-70` with `op-band`, `op-bor`, `op-bxor` and `op-shl` at `:38-39` and printer arms at `:50-51`. `records/homing-triage.md:163` proposes [[arcs/emitted-speed-arc]] and reads `clear`; **verified 2026-09-18 that that arc rosters no element at all** and names `E108` once, in its resume state at `:339`. **Wanted**: one assertion per operation against a known answer. **Blocking condition**: none measured | G2 | primitive | bind | 1 | built | `E96` |
| `lowering-and-emit/LE12` | the right shifts, `shr` logical and `sar` arithmetic, whose distinction is the whole content of the element and whose root states it: `prog/samples/e108_shift.prog:3` reads *"(shr -1 63) = 1 logical: the top bit shifts to the LSB, zero-filled"*. The root exits 42, run 2026-09-18, and no script names it. `records/homing-triage.md:174` proposes [[arcs/emitted-speed-arc]] on the same footing as `E96` and that arc rosters neither. **Wanted**: that root under a phase, which is the one assertion in the tree that would catch `sar` emitted where `shr` was written. **Blocking condition**: none measured | G2 | primitive | bind | 1 | built | `E108` |
| `lowering-and-emit/LE13` | the little-endian u16 writer, built at `lib/lowering/tal/bytes.chiral:628` under its own comment at `:621`, with the sharpest undispatched root on this roster: `prog/samples/e109_bput_u16_le.prog` asserts seven properties including byte order at a nonzero offset, length preservation and both untouched neighbours, and exits 42, run 2026-09-18. No script names it. `lib/protocol/inet.chiral:30` cites this writer as the precedent it deliberately declines, the `sockaddr_in` port being big-endian. **Wanted**: that root under a phase. **Blocking condition**: none measured | G2 | primitive | bind | 1 | built | `E109` |
| `lowering-and-emit/LE14` | the x86-64 code generator, 1,766 lines inside the closure, reached by every assertion in the suite and discriminated by one gate script that belongs to another element. `lib/lowering/x64/mach.chiral` inhabits the 37-field `Mach` seam at `lib/lowering/mach/mach.chiral` and drives the 573-line `emit-core` with `asm-reloc` behind it. A grep for `op-bytes`, `x64/mach`, `mach.chiral`, `elf.chiral` and `emit-core` over `tools/test/*.sh` returns `tools/test/mul-widen.sh` alone, Phase 32 under `E189`. `docs/elements/catalog.md:119` names `lib/emit-core/mach/mach-x64/asm-reloc` and `find lib -name 'mach-x64*'` returns nothing. **Wanted**: the cell re-derived, and one assertion per encoding family that fails when an arm is wrong rather than when the program stops running. **Blocking condition**: none measured. **The widening multiply and the rotate are `emitted-speed/X7` and `X8`** and this row takes neither | G3 | primitive | bind | 1, 4 | built | `E19` |
| `lowering-and-emit/LE15` | the executable format, built and universal: `elf-file` at `lib/lowering/x64/elf.chiral:79` wraps a code batch in a 64-byte Ehdr plus one 56-byte PT_LOAD, imported at `lib/lowering/compile-emit.chiral:18` and called at `:144`, so every ELF this tree emits including `bin/chirality-bin` is its output. Its header at `:6` says *"one 56-byte RX PT_LOAD"* and `:60` says *"RWX (PF_R|PF_W|PF_X = 7), not RX"* with the reason, the heap cells sharing the segment; `:70` writes `7` and `readelf -l bin/chirality-bin` reports one `RWE` LOAD. The code and the binary agree and the header line is stale prose. **Wanted**: `:6` corrected, and one assertion that the emitted header is the header the layout constants describe. **Blocking condition**: none measured. **The W^X question is `E132`'s**, rostered by [[arcs/runtime-loading-arc]], and this row states the segment flags without asking them to change | G3 | primitive | bind | 1, 4 | built | `E34` |
| `lowering-and-emit/LE16` | import resolution and the bundler, two providers pinned against each other by prose and by nothing mechanical. `lib/module/resolve.chiral` is 434 lines keyed on the root-relative path, imported by `prog/resolve.prog` and `lib/evidence/test-floor.chiral`; `bin/chirality-resolve.sh` is the one the BUILD RULE runs. Both state the extension order and the `(end-module "<key>")` marker, and `resolve.chiral:19-20` asks for them to be kept *"byte-for-byte in step"*. No check compares them, and the phase that would is Phase 11, unported. **Wanted**: the two providers made to agree by an instrument rather than by a comment, over one blob. **Blocking condition**: none measured. `records/homing-triage.md:154` proposes [[arcs/enforcement-arc]] and reads `clear`; **verified 2026-09-18 that that arc's element cells are `E16`, `E17`, `E18`, `E70`, `E184` through `E188` and `E198`, and hold no `E87`** | G4 | tool | bind | 1, 3 | built | `E87` |
| `lowering-and-emit/LE17` | the multi-root search path and the collision diagnosis, both built, and the phase that gated them is unported. The resolver takes a list of roots spelled `-L <dir>` on `prog/resolve.prog`'s stdin (`:26`, parsed at `:53`), an earlier root shadowing a later one, with no importer-directory leg; a module's key is its root-relative path (`resolve.chiral:30-38`), which makes the old basename-collision class unreachable rather than merely named, and two importable extensions under one path is a named error at `:40`. The deletion half landed with the 2026-08-31 migration. `docs/elements/ledger.md:152` cites `tools/test/run-tests.sh:210` for the NOT PORTED notice and `:210` is a comment about `E157`; the notice is at `:412`. **Wanted**: the resolver half of Phase 11 ported, and the citation repointed. **Blocking condition**: none measured. Phase 11's other half is `LE24`'s and the two share one phase slot | G4 | tool | bind | 1, 3, 4 | built | `E155` |
| `lowering-and-emit/LE18` | the per-module label namespace, `design`, and the defect is live at HEAD. Reproduced 2026-09-18: two co-blobbed modules each defining one private `helper` refuse at `duplicate label (an object def collides with the linked runtime): helper` from `first-dup-go` (`lib/lowering/compile-emit.chiral:304-305`), fail closed with no ELF written, and the message names a collision with the runtime that this case does not have. The workarounds are in the tree: `lib/lowering/tal/check.chiral:52` defines `tck-ce-fns` against `lower.chiral:193`'s `ce-fns`, one of eleven names prefixed `tck-` at `5b4fb71`. **`enforcement` collects instances of this problem and does not own the element**: verified 2026-09-18, `E154` appears in `docs/arcs/enforcement-arc.md` at lines 51, 262, 593 and 645 and in no element cell of it, and line 645 calls the eleven collisions *"E154's fifth instance"*. **Wanted**: labels mangled by owning module at emit with the surface name unchanged, and the refusal's message naming the case it fired on. **Blocking condition**: none measured. `docs/banks/module.md` §4 already refracts the namespace question and this row is the codegen-tier collision under it | G4 | primitive | new | 4, 5 | open | `E154` |
| `lowering-and-emit/LE19` | the reference interpreter over the pure fragment, 109 lines, zero importers, outside the closure, with a false premise in its own header: `lib/evidence/interp.chiral:6` reads *"runtime.py stays the oracle"* about a file that is gone. It is half (a) of `LE20`'s instrument and the only source-side evaluator in the tree. `records/homing-triage.md:97` proposes [[arcs/enforcement-arc]] and reads `clear`, citing `docs/arcs/enforcement-arc.md:49`; **this run disagrees**: `:49` is inside that arc's requirement 2 about the typed-assembly floor, the element appears in no element cell there, and `enforcement/N13` names this file as one half of a pair it says in its own words it does not hold. **Wanted**: the header corrected, and the interpreter reached from something a phase runs. **Blocking condition**: none measured | G5 | tool | bind | 2, 4, 6 | built | `E15` |
| `lowering-and-emit/LE20` | behavioural coverage of lowering, the first instrument that would judge what `lower.chiral` produces by running it. Half (a) is buildable today: `lib/evidence/interp.chiral` (109 L) evaluates the upper term, `lib/lowering/tal/eval.chiral` (187 L) runs the lowered tal, same program, compare the results; both sit at zero importers. Half (b) is the certificate ladder over `preserve-check` and blocks on an absent toolchain. **`enforcement` does not roster it**, verified 2026-09-18: `docs/arcs/enforcement-arc.md:504-505` carries `E169` only inside `N13`'s cell, whose words are *"`docs/elements/catalog.md:484` E169 half (a) already describes this instrument … and no arc names it (UNS-45), so whether this row adopts E169 or mints is the design stage's"*. Under [[goals/README]] at `:27` and `:32` an element sits in every arc that claims it, so this row claims it here and `N13` adopting it too is no competition: that row's obligation is the preserve-check's T1 rung and this row's is the emitter's behaviour. **Wanted**: half (a), the two evaluators required to agree over one program. **Blocking condition**: half (b) needs `coqc` or `rocq`, absent; half (a) needs nothing | G5 | tool | connect | 1, 2, 6 | open | `E169` |
| `lowering-and-emit/LE21` | the second C seam, `tal-c`, emitting C one stage above the `Mach` branch so `emit-core` gets external provenance, which the parked `E166` leg could not give it. The bisection argument is the element's whole content: `tal→C` disagreeing while `Mach→C` agrees localizes `emit-core`; both disagreeing localizes `mach-x64`; neither leg alone localizes. Sized at roughly 200 to 400 lines covering 2,310, from `lib/lowering/tal/eval.chiral`'s 187 lines being enough to interpret tal. Its track reads `?` in both authorities and the 2026-09-10 parking does not settle it. **Wanted when the call lands**: the `tal` seam, sequenced after the cheaper leg's shared questions settle. **Blocking condition**: **the `?` track call**, carried verbatim under FLAGs. `records/lenses/unspoken.md` UNS-44 admits the element as unhomed | G5 | tool | new | 6 | open | `E167` |
| `lowering-and-emit/LE22` | the test floor, adopted and without its own phase. `lib/evidence/test-floor.chiral` is 1,023 lines (`docs/elements/ledger.md:154` records 854 at `f9441e4`), imported by `prog/test-runner.prog:28`, which Phase 2 rebuilds from source every run and gates by exit code, so the adoption is real. **Phase 12 is the element's own phase and it does not run**: `tools/test/run-tests.sh:22` and `:413` print it NOT PORTED over *"the phase SCRIPT and its mutant machinery"*, while eighteen fixtures importing the floor sit under `tools/test/samples/` and no script names one. So the element reads `built` with its gate absent, and the floor's central claim, that a `Gate` cannot be constructed without a `MutRun`, is exercised by nothing the suite runs. **Wanted**: the Phase 12 script and the mutant machinery, dispatching the eighteen. **Blocking condition**: none measured | G5 | tool | bind | 1 | built | `E168` |
| `lowering-and-emit/LE23` | the corpus landing on the floor, blocked on the phase above. Lanes C, D and E are done and their artifacts are in the tree: `e170_conv_eta`, `e170_infer_arms`, `e170_qtt_semiring` and `e170_refine_top` re-found four checker rules, `e170_port_twin` and six `e170_reject_*` roots carry the per-port map, and every one of them is a Phase 12 row. Lane B, re-expressing Phases 1 and 3 to 11 as `Suite` values, is untouched. **Every artifact of the three finished lanes is undispatched for the same reason `LE22` is**, and `checker-core/CK7` through `CK10` name four of them as the roots their rules already have and cannot get run. **Wanted**: Lane B, after Phase 12 exists. **Blocking condition**: `LE22`. `records/lenses/unspoken.md` UNS-46 admits the element as unhomed | G5 | tool | connect | 1 | open | `E170` |
| `lowering-and-emit/LE24` | the fixpoint compare as a phase: build two generations from one regenerated blob, check each artifact non-empty, `cmp` them, and iterate when the first pair differs, because `docs/definitions/working-discipline.md:35-41` puts the first agreement at `C2 == C3` for a change that touched emission. **Measured 2026-09-18 and the cost objection does not survive it**: blob 1.193 s at 17,797 lines, generation one 0.765 s at 1,220,984 B and byte-identical to the committed binary, generation two 0.766 s, `C1 == C2`. Under three seconds against a suite that runs minutes. `tools/test/run-tests.sh:412` gives the blocker as *"no committed blob artifact to cmp against"* and the compare takes no committed blob: both its inputs are tracked, `bin/chirality-bin` and `bin/chirality-resolve.sh`'s `chirality_blob_file` at `:269`. **Wanted**: the phase, in Phase 11's slot beside `LE17`'s resolver half. **Blocking condition**: none measured. **The placement is an author call**, carried verbatim under FLAGs | G6 | tool | new | 1, 3 | open | `unminted` |

### Coverage

Run 2026-09-18 against the table above.

- **Every requirement is served.** 1 by `LE1` through `LE5`, `LE7` through
  `LE17`, `LE20`, `LE22`, `LE23` and `LE24`; 2 by `LE19` and `LE20`; 3 by `LE16`,
  `LE17` and `LE24`; 4 by `LE1`, `LE4`, `LE5`, `LE6`, `LE7`, `LE14`, `LE15`,
  `LE17`, `LE18` and `LE19`; 5 by `LE18`; 6 by `LE19`, `LE20` and `LE21`. No
  requirement is unscheduled.
- **Every row serves a requirement.** All twenty-four name at least one. No row
  is out of scope.
- **Eighteen rows are `built`, one is `building`, four are `open` with an element
  and one is `open` and unminted, and the requirements they serve are unmet,
  which is this arc's premise.** The state column is the pipeline's authority for
  a row; the elements are built and what the rows carry is the residue. Goal
  condition 4 is exactly the requirement that a built part run on a path
  something asserts.
- **Every `origin` is defensible from the measurement.**
  - `LE18` and `LE21` are `new` because the deliverable exists nowhere: no label
    mangling at emit, and no `tal` to C seam in a tree whose C backend was
    deleted on 2026-09-01. `LE24` is `new` because no phase in
    `tools/test/run-tests.sh` performs the compare and the procedure it wraps
    lives only in a command block a person runs.
  - `LE20` and `LE23` are `connect` because both halves exist and the join does
    not: two evaluators at zero importers that would have to be required to
    agree, and three finished corpus lanes whose artifacts wait on a phase
    script.
  - The other eighteen are `bind` because the code is built and what is absent is
    a surface onto it: a dispatch line for a root that already passes, or a state
    cell that matches the code. Each names the span measured.

## What this arc does not take

- **The typed-assembly floor and the preserve-check.** [[arcs/enforcement-arc]]
  owns `E16`, `E17`, `E18` and `E70` through `N6`, `N7`, `N8`, `N9`, `N13` and
  `N14`, and `lib/lowering/tal/check.chiral` stays outside the compiler's closure
  by `records/lenses/problems.md` PRB-70's ruling of 2026-09-08.
  `tools/test/tal-check.sh` is 493 lines, is dispatched by no `run_phase` line by
  its own decision, and belongs to that arc. **The boundary is the direction the
  two arcs read the emit path.** That arc asks whether what the emitter produced
  is well-typed and whether the compiler states its own work. This arc asks
  whether the emitter's parts are reached and judged at all. No row of that arc is
  edited by this run.
- **What emitted code costs.** [[arcs/emitted-speed-arc]] owns `X1` through `X9`:
  the transparent single-constructor product, multi-value return, the per-pass
  switch, the outside control, the residual instrument, the widening multiply,
  the rotate and the three-set agreement gate. `records/homing-triage.md:163` and
  `:174` propose that arc for `E96` and `E108` and both read `clear`. **This run
  disagrees, for a measured reason.** That arc rosters no element at all: its nine
  element cells are `unminted`, and `E108` appears once in the file, at `:339`, in
  its resume state as the precedent a future row would follow. Its requirement 6
  quantifies over operations the measured workload asks for and a bucket C
  disposition, and its requirement 5 is the agreement gate over the `Op` sum, the
  extern block and `op-bytes`. Neither counts a shipped bitwise operation's
  behaviour. `LE11` and `LE12` take the two elements where their roots already
  sit, and if the author prefers the speed seat both rows retire and the elements
  move with their ids intact.
- **The crossing surface.** [[arcs/sys-face-arc]] rosters nineteen crossing
  elements through `SF1` to `SF20` and owns the `.port` sheets, the linkage
  table, the carrier lifecycles and the module coordinate. `E123` is named in
  that arc's prose at `:191`, inside `SF14`'s cell, as the carrier the `adopt-fd`
  identity peel was predicted by; that row's element cell is `E124`. `LE8` takes
  the carrier and takes no crossing.
- **The reader and the type theory.** [[arcs/checker-core-arc]] rosters eighteen
  elements through `CK1` to `CK19` and owns the register of judgments the checker
  can reach. Four of the `e170_*` roots this arc's `LE23` counts are that arc's
  `CK7` through `CK10`, which name them and state that they cannot get them
  dispatched. This arc owns the phase they wait on and takes none of the four
  rules.
- **The W^X floor and the resident loader.** [[arcs/runtime-loading-arc]] rosters
  `E132` and owns a resident binary mapping a freshly compiled artifact with a
  load-time port fence. `LE15` states the `RWE` segment as the emitter writes it
  and asks for no change to the flags.
- **The second opinion as a goal.** [[goals/independent-judgment]] holds
  `docs/decisions/decision-scope.md`'s consequence 1, three semantically distinct
  judgment cores that must agree, and [[arcs/independent-judgment-arc]] rosters
  `J1` to `J5`. `records/homing-triage.md:221` routes `E167` to that arc or to
  [[arcs/ownership-and-trust-arc]] as an open call, and
  `docs/arcs/independent-judgment-arc.md:147-149` records the trap a leg has to
  clear: a leg sharing a front end and differing at emit is one formulation
  emitting twice, which is the reading `E166` was dropped on. **`LE21` homes the
  element in the subject it emits from and claims no verdict on the judgment
  architecture**; if the author seats it under that goal, the row retires and the
  element moves with its id.
- **The golden-semantics restructure.** `E71` is `OT` by the 2026-09-15 ruling
  and rostered as `ownership/O2`. It shares `lib/lowering/tal/spec.chiral` and
  `lib/evidence/interp.chiral` with `LE19`, and
  `docs/arcs/ownership-and-trust-arc.md:71-74` records that arc's requirement 3
  as served by no row, enumerated as `GAP-08`, over the reference semantics in
  `spec.chiral`. This arc takes `E15` and takes neither `E71` nor that gap.
- **The wider root census.** 84 of the 103 roots Phase 7's own selector returns
  are named by no gate script, the largest family being `prog/samples` at 50.
  [[arcs/checker-core-arc]] measured the same census at 81 unnamed and routed the
  residue here and to the unopened `substrate-floor`. **Of the 84, nine belong to
  elements of this roster** and requirement 1 schedules exactly those nine. The
  `prapanca` families are [[arcs/orchestration-engine-arc]]'s and the `scriba`
  families are [[arcs/scriba-arc]]'s. The difference between 81 and 84 is the
  matching rule: this run counted a root as named only when its full basename
  appears in a `tools/test/*.sh` file, and Phase 2's manifest of six lives in
  `prog/test-runner.prog` rather than in a script.
- **Repairing the catalog and the ledger.** Requirement 4 is what `LE1`, `LE4`,
  `LE5`, `LE6`, `LE7`, `LE14`, `LE15`, `LE17`, `LE18` and `LE19` buy, and this
  run edits neither file.

## FLAGs

⚑ **The compare's phase is argued here and its placement is the author's.**
`docs/goals/self-hosting.md:216-225` carries the call, and its words are:
*"**The compare's phase has no owner, and `enforcement` does not hold it.** Read
2026-09-17. [[goals/enforcement]]'s five conditions and [[arcs/enforcement-arc]]'s
six requirements reach ENFORCED ledger rows, the typed-assembly floor on the
shipping path, the check agreeing with the compiler it checks, the optimizer's
re-check, the tooling ratio, and a named mutant per gate row. None of the eleven
names the fixpoint, the blob, or the BUILD RULE. The nearest candidate in §Arcs is
the unopened `lowering-and-emit`, whose subject is whether the emitter's own parts
are reached and gated at all. ⚑ **FLAG, author tier: naming that arc the owner is
a placement call, and this goal does not take it.** The phase is owed and
unplaced."*

**The argument for this arc, from the subject.** The compare's two inputs are the
emitter's output and the blob the resolver builds, and both are this arc's:
`bin/chirality-bin` is `LE15`'s `elf-file` output and the blob is `LE16`'s and
`LE17`'s providers. The phase slot it would occupy is Phase 11, whose title is
*"resolver + build state"* and whose resolver half is `E155`, rostered here as
`LE17`, so the compare's phase and this arc's own element are one unported phase.
The observation it satisfies is goal condition 4(b)'s, a phase asserting a value
over a root rather than only compiling it, and the root is the compiler. No other
standing arc's requirements reach it: `enforcement`'s eleven do not, measured at
`7fc6eb0` and re-read here; `emitted-speed`'s six reach cost and the target ratio;
`checker-core`'s six reach the judgment register; `sys-face`'s six reach the
crossings. `LE24` is drawn while the call is out, following
[[arcs/sys-face-arc]]'s precedent for `SF20` and [[arcs/checker-core-arc]]'s for
`CK17`.

**What the row does not claim.** Conditions 1 to 3 of [[goals/self-hosting]] are
held by the BUILD RULE as a standing discipline and carry no arc by that goal's
own §Arcs, and `docs/goals/README.md:48` keeps `none open` until the phase exists.
`LE24` serves conditions 4 and 5 over this arc's subject. That the same phase
would move conditions 1 to 3 from IMPLEMENTED to ENFORCED is a consequence stated
here and not a claim on those conditions: claiming them would contradict the
standing-gate shape and raise three fresh check AF violations, which `26bf3be`
measured.

⚑ **`E167`'s track reads `?` and the author's call is open.**
`records/author-calls.md` carries it, and its words are: *"⚑ **The row stays
`unreviewed`, and E166 and E167 are what holds it open.** Their parking ruling of
2026-09-01 is recorded in `docs/elements/catalog.md` §UNSORTED and in
`docs/decisions/decision-scope.md:103-112` consequence 1. It settles whether the
work happens and names neither track token, and the cut it records was of external
judgment, a different axis from the SH and OT split. Both cells still read `?` in
`docs/elements/catalog.md` and `docs/elements/ledger.md`."* The same row states
the consequence for homing: *"Three of them, E77, E78 and E167, are unhomed
`design` orphans, so the track answer gates their homing: an `OT` element is
deferred and an `SH` one is queued"*, amended to *"E167 is the one named orphan
the call still gates."* `LE21` carries the `?` verbatim, homes the element, and
sorts nothing. Homing is planning under `docs/decisions/decision-scope.md` §What
"deferred" means here, exactly, and as of `7fc6eb0` a design and a SPEC for an
`OT` element are planning too, so the row stands whichever way the track lands.

⚑ **Two state cells read the opposite of what a four-line probe returns.**
`E95`: `docs/elements/catalog.md:419` reads *"Not built"* and two mutually
recursive `=>` functions compile and exit 42, run 2026-09-18. `E69`:
`docs/elements/catalog.md:263` reads *"not built"* and `closconv-driver.chiral` is
imported by `lib/lowering/compile-front.chiral`, inside the compiler's own
closure. `ledger-lint` check AB pairs the catalog's build column against the
ledger's state column and reports zero issues, so both drifted in the direction AB
cannot see. Four further citations are stale, listed under requirement 4. Neither
file is in this run's write scope. [[arcs/sys-face-arc]] found four of this class
on 2026-09-17, [[arcs/checker-core-arc]] four and [[arcs/substrate-floor-arc]] two
on 2026-09-18, which makes twelve in four arcs.

⚑ **`E94`'s two authorities disagree and neither carries a measurement.** The
ledger reads `flight` and the catalog reads *"Not built"*. No count of forms or
data types and no bounding constant appears in either, so the element asserts a
capacity limit nobody has read off `lib/surface/parse.chiral` or
`lib/module/loader.chiral`. `LE6` is drawn as `building`, the roster word for a
state the closed vocabulary has no name for, following
[[arcs/checker-core-arc]]'s handling of `part` and `flight`, and its first
deliverable is the number.

⚑ **This arc is unanchored on `arc -> goal done-condition`.**
`docs/goals/self-hosting.md` conditions 4 and 5 each name `[[arcs/sys-face-arc]]`
and nothing else, and `tools/lens/lens.py:255` reads a condition's arc from the
`[[arcs/...]]` links in its body. So `lens.py chain` reports this file in that
rung's uncovered set beside [[arcs/checker-core-arc]], which `e50157f` already
broke to 34 of 35. The goal file is outside this run's write scope and the edit is
owed: conditions 4 and 5 each name this arc, the table at `:91-96` moves its row
from unopened to opened with its element count corrected from 13 to 23, the
sentences reading "The other three subject arcs" become one, the honest limit's
"39 of the compiler's own built elements" falls by this roster's nineteen
non-exempt rows, and the list of arcs opened in this shape at `:104-108` gains a
seventh. The `⚑` at `docs/goals/self-hosting.md:124` already records that
`docs/goals/README.md:48` is owed the matching change.

⚑ **`ledger-lint` check AH raises eight violations against this roster and every
one of them is real.** AH globs `f"{elem}-*-SPEC.md"` with the element cell's
literal text (`tools/ledger-lint/ledger-lint.py:2187-2189`), and its known
zero-padding misreport is that a single-digit element's SPEC is zero-padded on
disk while the cell is written bare. **This roster has no exposure to it**: its
lowest element is `E15`, every cell here carries two or three digits, and each is
spelled the same way in both places, which is why nine of the thirteen AH
violations [[arcs/checker-core-arc]] drew are padding artifacts and these eight
are none. Measured 2026-09-18: `LE3`, `LE10`, `LE14` and `LE17` each raise both
limbs, no SPEC existing for `E147`, `E145`, `E19` or `E155` and no
`docs/arcs/parts/lowering-and-emit-LE*.md` existing for any row, which is the
correct reading for an arc opened in one run. Sixteen of the twenty-three elements
hold a SPEC under `docs/elements/specs/`; `E154`, `E167` and `E169` hold none and
read `open`, a state AH does not read. The tool is outside this run's write
scope.

⚑ **`records/lenses/unspoken.md` UNS-34, UNS-44, UNS-45 and UNS-46 admit `E94`,
`E167`, `E169` and `E170` as unhomed, and all four stand at `unreviewed`.**
`LE6`, `LE21`, `LE20` and `LE23` give each a home, so all four rows are owed a
state change and a `checked:` date. That file is outside this run's write scope.
The four are also why the element homes owed count falls by nineteen and not by
twenty-three: check AE exempts an element an unspoken row admits, so those four
were never inside the owed 51.

## Resume state

Opened 2026-09-18 against [[goals/self-hosting]] condition 5, on the author's
approval of the four subject arcs when that goal was amended at `2d8dbac` and the
direction of 2026-09-17 to finish them. Twenty-four rows, six requirements,
nothing designed. Rows spell `LE`. Twenty-three of the twenty-four carry an
element minted before this file and this run mints nothing.

**The census.** `docs/elements/ledger.md` §CG holds 25 element rows. Five hold a
roster row already: `E16`, `E17` and `E18` in [[arcs/enforcement-arc]], `E71` in
[[arcs/ownership-and-trust-arc]], `E146` in [[arcs/file-types-arc]]. Twenty hold
none: `E15`, `E19`, `E87`, `E93`, `E94`, `E96`, `E97`, `E100`, `E108`, `E109`,
`E123`, `E144`, `E145`, `E147`, `E154`, `E155`, `E167`, `E168`, `E169` and `E170`.
Three more the goal's own cell names for this arc hold none either, and they sit
outside §CG: `E34` in §FMT, `E69` and `E95` in §EF. All twenty-three are rostered
above. Seventeen read `built`, `E168` reads `**built**` and is written `built`,
`E94` reads `flight` and is written `building`, and `E154`, `E167`, `E169` and
`E170` read `design`, which the roster's closed vocabulary has no word for and
which is written `open`. No element of §CG is `superseded`.

**The row to take up first is `LE24`.** Its whole procedure ran here in under
three seconds, both inputs are tracked, and it is the only row on this roster
that turns a goal condition from a discipline into a gate. `LE13` is the second:
its root asserts seven properties of a byte writer, exits 42 today, and needs one
`run_phase` line. `LE12` is the third for the same reason and catches the one
substitution a shift encoder can make. `LE18` is the fourth: its probe runs in
four lines and the refusal it produces names the wrong cause, which is a
diagnostic defect sitting on top of a design one.

**What was measured before any row's state was written.** The fixpoint compare is
re-runnable and is `docs/definitions/working-discipline.md:26-33` verbatim:
regenerate the blob with `chirality_blob_file "lib:prog" prog/compiler.prog`,
build `C1` with `bin/chirality-bin`, build `C2` with `C1`, `cmp` them. It returned
17,797 blob lines, 1.193 s, two generations at 0.765 s and 0.766 s, 1,220,984 B
each, `C1 == C2`, and `C1` equal to the committed binary. The closure census
resolves `(import "...")` transitively from `prog/compiler.prog` over `lib:prog`
across the three extensions `MAP.md:20` names and returns 62 targets and 17,674
lines against `lib/`'s 105 modules and 26,598, with 27 of the 32 `lib/lowering/`
targets inside. The root census greps `^(def compile-main` over `lib prog`, which
is Phase 7's own selector, and returns 103 roots of which 19 are named by some
gate script. The fixture census counts nine roots written for elements of this
roster and eighteen importing `evidence/test-floor`, and finds zero of either
named by a script. Six fixtures were run by hand and their exit codes are on
`LE2`, `LE3`, `LE8`, `LE10`, `LE12` and `LE13`. The two probes are four lines each
and are recorded in full on `LE5` and `LE18`.
