---
element: E189
slug: widening-multiply-two-names
title: "The widening multiply's two names: `mulhi` signed, `mulhu` unsigned"
design: arcs/parts/emitted-speed-X7.md
status: audited
updated: 2026-09-08
---

# E189 SPEC: The widening multiply's two names: `mulhi` signed, `mulhu` unsigned

> The build half, produced by the `design-to-spec` run. The design at
> `docs/arcs/parts/emitted-speed-X7.md` made the design decisions and an audit
> gated them at `857f99d` before this element minted. An implementation run
> follows THIS file.
>
> ⚑ **SPEC-level audit 2026-09-08 at `c1829f3`: PASS.** Every `file:line` below
> was reopened, `G4`'s identity was rederived and its six goldens recomputed in
> both Python and bash, `48 F7 E1` was disassembled a fourth time, and the build
> baseline was rerun end to end. Four FIXes landed: the retired `pack.py`
> citations, the test-baseline date, a deterministic observable for `G5`, and a
> third rung for `M3`. The status flip is owed separately, for the reason §5
> gives.

**Every `file:line` below was opened on 2026-09-08 at `35c844c`**, on a clean
worktree. A concurrent session has been committing to this tree all day and the
design's own §2 says its numbers were measured the same way. Where a number
here differs from the design's, §2 says so in its own row. HEAD moved to
`8f64ae9` while this file was being written; that commit touches
`.planning/TAL-CONFORMANCE-QUEUE.md` and `docs/decisions/decision-preserve-check.md`
and no target below, and every line was re-checked against it.

`python3 tools/pack/pack.py E189 --spec` **did not run.** At the time of writing
it died with `no drafted example examples/E189-*.md`, because `spec_mode` still
read the retired `docs/examples/` pipeline and E189 is the first element minted
under `docs/decisions/decision-design-before-mint.md` to reach this stage. The
bundle below was assembled by hand from the same sources that mode would have
printed, and this file was written from the template at
`docs/elements/specs/_TEMPLATE.md` instead of being scaffolded.

⚑ **That half of the tool gap closed one commit later, and the SPEC audit
measured it.** `c1829f3` repointed `spec_mode`, now at
`tools/pack/pack.py:684-693`, at `pipeline_artifact`, which answers
`('design', 'docs/arcs/parts/emitted-speed-X7.md')` for E189. The line citations
this paragraph carried retire with the gap. What survives is the roster row at
`docs/arcs/emitted-speed-arc.md:277`, which still reads `designed` where the pack
would have flipped it to `specced`, and the post-audit flip, which §5 carries.

## 1. Deliverable

- **After this runs:** a surface program can write `(mulhi a b)` for the signed
  high 64 bits of a 64-by-64 product and `(mulhu a b)` for the unsigned high 64
  bits, the two answer differently whenever either operand's top bit is set, and
  the `Op` sum's every constructor is reachable from surface source.
- **Chosen shape: Shape B**, signed and unsigned as two constructors and two
  externs, taken at `docs/arcs/parts/emitted-speed-X7.md` §5. `op-mulhi` keeps
  its constructor, its bytes `48 F7 E9` and its emission and gains the extern
  `mulhi`; `op-mulhu` is added beside it with the bytes `48 F7 E1`. Both externs
  are `(-> I64 I64 I64)` on the E108 precedent, where signedness rides the
  operation's name. The shape is settled and this file does not reopen it.
- **`48 F7 E1` is `mul rcx`**, third independent verification 2026-09-08:
  `objdump -D -b binary -m i386:x86-64` over the six bytes `48 F7 E1 48 F7 E9`
  prints `mul %rcx` then `imul %rcx`. ModRM `E1` is mod 11, reg 100 (`/4`), rm
  001 (`rcx`). `MUL r/m64` writes `RDX:RAX`, so `x-mov-rax-rdx`
  (`lib/lowering/x64/mach.chiral:197`) and the `clb-rdx-rcx` clobber set carry
  over from `op-mulhi` unchanged.
- **Non-goals.** No two-slot form and no second return value: `C38` stays open
  and belongs to `emitted-speed/X2`. No unsigned comparison: `C13` closes the
  ordering residue and this run leaves the arc's disposal of it standing. No
  unsigned low half: the low 64 bits are the same integer under either reading.
  No arm in `fold-prim` or `eval-prim`, for the reason §2 measures. No consumer:
  neither extern has a built caller on the day it lands, and
  `lib/crypto/poly1305.chiral:11-14` stays on its five 26-bit limbs.

## 2. What the code forces

The design chose a shape against structural outlines. This is where the live
files push back.

**The design's file-and-arm census holds exactly.** `grep -rn "op-mulhi" lib/
prog/ tools/` returns five lines and `grep -rn "op-shl"` returns five, in the
same five places: the sum, `op-name`, the `op-parse` chain, `op-bytes` and the
immediate dispatch. Three `lib/` files, as the design says. `lib/lowering/c/`
does not exist. No sixth site carries the whole sum.

| target | the design assumed | the file admits | verdict |
|---|---|---|---|
| `lib/prelude/prelude.chiral:36-39` | the closed `Op` sum, 15 constructors, `op-mulhi` at `:38` | exactly that | agrees |
| `lib/prelude/prelude.chiral:44-51` | `op-name`, the `op-mulhi` arm at `:49` | exactly that | agrees |
| `lib/prelude/prelude.chiral:59-72` | the extern block, 14 `I64` entries, no `mulhi` | exactly that. The 14 are `+ - * / % =i <i <=i band bor bxor shl shr sar`, so 14 of the sum's 15 names bind and `mulhi` is the one that does not | agrees |
| `lib/prelude/prelude.chiral:54-55` | not named by the design | `op-cmp?` is a **sixth** `case op`, and it ends in a wildcard `_`. `op-mulhu` falls into it and answers `false` | constrains |
| `lib/lowering/tal/erase.chiral:91-107` | `op-parse`, the `"mulhi"` arm at `:100` | exactly that. The chain is 15 nested `(false (case …` arms closed by one tail at `:107` | constrains |
| `lib/lowering/tal/erase.chiral:152-157` | `erase-prim` enforcing arity 2, cited as `:153-157` | the `declare` is at `:152` and the `def` at `:153`. `mulhu` is binary, so the arity gate admits it with no edit | agrees |
| `lib/lowering/x64/mach.chiral:313`, `:321` | the comment already reading `signed`, and `x-imul-rcx-1op` as `(bc3 (b1 72) (b1 247) (b1 233))` | exactly that. 233 is `0xE9` | agrees |
| `lib/lowering/x64/mach.chiral:359-391` | `op-bytes`, the `op-mulhi` arm at `:377`, mid-list | exactly that. `op-shl` at `:391` is the terminal arm and carries the closing parens | agrees |
| `lib/lowering/x64/mach.chiral:971-1033` | one immediate arm at `:1033` | `op-mulhi` at `:1033` is the **terminal** arm of `bini-body` and carries the four closing parens that end the `case`, the `lam` and the `def` | constrains |
| `lib/lowering/x64/mach.chiral:1201-1211` | not named by the design | `fjc-cc` is a **seventh** `case op`, wildcard-terminated at `:1211`. Its only caller is `x-fjc` at `:1221`, dispatched from the fused compare-branch path that `fused-of` gates on `op-cmp?` (`lib/lowering/mach/emit-core.chiral:379-392`, the guard at `:383`) | constrains |
| `lib/lowering/x64/mach.chiral:1443-1464` | one clobber key at `:1455`, the set `clb-rdx-rcx` at `:1415`, priced by the comment at `:1395` | all three exactly. The key test at `:1455` is a nested `or` over `bin:mulhi`, `bini:mulhi` and `bpt`. The **fall-through at `:1464` is `clb-rcx`**, which is `{3}` and omits `rdx` | constrains |
| `lib/lowering/mach/emit-core.chiral:156-161` | not named by the design | the clobber key is built as `(str-cat "bin:" (op-name op))` and `(str-cat "bini:" (op-name op))`. `op-name`'s new arm is what makes the new clobber key exist | agrees |
| `lib/lowering/compile-back.chiral:280-289` | `lowerable-prim?` admitting everything `op-parse` accepts | exactly that: `:282` calls `op-parse` first. No edit is owed here | agrees |
| `lib/lowering/upper/optimize.chiral:60-67` | `fold-prim` models neither `mulhi` nor the six bitwise ops | exactly that. It dispatches on `Str`, matches five names and answers `(none)` for every other | agrees |
| `lib/lowering/tal/eval.chiral:85-95` | `eval-prim` models the same five and answers `v-i64 0` otherwise | exactly that, and it dispatches on `Str` | agrees |
| `tools/test/run-tests.sh:173-178` | not named by the design | Phase 7 sweeps **every** root in the tree by `grep -rl '^(def compile-main' lib prog`. A new probe under `prog/` joins the sweep with no list edit | constrains |
| `tools/test/run-tests.sh:365-367` | the gate is a new phase | 29, 30 and 31 are taken by `encoding.sh`, `recording.sh` and `crypto.sh`. **32 is the first free number** | constrains |

**Refusals: none.** Every target admits Shape B. No `revisit` on the design is
owed by this run.

### Constraints carried into §3

1. **The closed sum forbids splitting steps 1 through 3.** Three exhaustive
   `case op` matches cover every constructor with no wildcard: `op-name`
   (`prelude.chiral:46-51`), `op-bytes` (`mach.chiral:355-385`) and `bini-body`
   (`mach.chiral:965-1025`). Adding the constructor without all three arms leaves
   a match non-exhaustive and the tree does not compile. The three files land in
   **one commit** and pay **one** build-rule cycle between them.
2. **The `op-parse` tail gains exactly two closing parens.** Each arm is
   `(false (case (str-eq op "X") (true (some (op-x)))`, which leaves one `(false`
   and one `(case` open, and every arm's closer sits on the single tail line at
   `erase.chiral:107`. Getting the count wrong is a parse failure and not a
   silent defect, so it costs a compile and not a wrong answer.
3. **The immediate arm goes above `mach.chiral:1025`.** `op-mulhi` is the
   terminal arm and holds the `))))` that closes `bini-body`. Inserting
   `op-mulhu` above it leaves that tail where it is; inserting below it moves
   four parens onto a new line for no gain.
4. **Two wildcard `case op` sites absorb the new constructor silently, and both
   are safe.** `op-cmp?` (`prelude.chiral:54-55`, the wildcard on `:55`) answers `false` for `op-mulhu`,
   which is correct: `mulhu` is no comparison. `fjc-cc`
   (`mach.chiral:1193-1203`) is reached only through the fused compare-branch
   path, which `fused-of` gates on `op-cmp?` at `emit-core.chiral:383`, so the
   wildcard is unreachable for `op-mulhu`. Neither wants an arm. They are named
   here so an implementation run does not have to find them and a later reader
   knows they were opened.
5. **The clobber key is load-bearing and its omission is a silent miscompile.**
   Leaving `bin:mulhu` and `bini:mulhu` out of the test at `mach.chiral:1445` does not fail
   a build. It falls through to `clb-rcx` at `mach.chiral:1453`, which is `{3}`, so the
   allocator believes `rdx` survives a `mul` that writes `RDX:RAX`. This is why
   §4 carries a mutant for it separately from the byte mutant.
6. **`mach.chiral` is blank-line separated and the design's line count reads it
   as though it were not.** 940 of its 1755 lines are blank. `prelude.chiral` (22
   blank of 154) and `erase.chiral` (25 of 284) are ordinary. So the design's
   "roughly fourteen edited lines" understates the file delta: the six
   `mach.chiral` edits cost about twelve lines in the file if the surrounding
   style is kept, and the whole change is **about nineteen file lines** over the
   design's fourteen logical ones. The design's arm count is right; only the
   line arithmetic moves.
7. **`fold-prim` and `eval-prim` get no arms, and the second one shapes the
   gate.** Both dispatch on `Str` and neither is an exhaustive match over `Op`,
   so a sixteenth constructor breaks neither and owes neither anything the
   fifteenth already owes and has not paid. Extending them would be new work on
   `mulhi` and on the six bitwise ops at the same time, which is a different
   element. The consequence for §4 is sharp: `eval-prim` answers `v-i64 0` for
   any name outside its five, so the TAL reference interpreter returns `0` for
   both `mulhi` and `mulhu` and **cannot be the gate's oracle**. The gate runs
   emitted native code.

### The build baseline, measured

`bin/chirality-bin` is **1,220,984 bytes** and the tree is at a fixpoint right
now: `chirality_blob_file "lib:prog" prog/compiler.prog` assembles 840,440 bytes
in 1.2 s, and `bin/chirality-bin` compiling that blob produces a binary
**byte-identical to itself**. One generation costs about **0.9 s** of compile
plus about 1.2 s of blob assembly. Measured 2026-09-08 at `35c844c`. This is what
makes §4's three compiler rebuilds affordable inside a registered phase.

## 3. Change plan (ordered, commit-sized)

> Steps 1 through 3 touch `lib/`, which is compiler source, and they land as one
> commit. That commit owes the build rule in
> [[definitions/working-discipline]] `:16-50`: build-new, test, promote, nothing
> replacing itself in place, generations from the same blob until two
> consecutive ones are byte-identical, a non-empty check before every `cmp`, and
> a stop at `C4`. The recipe there is the only copy. A comment-only edit counts,
> and step 3 carries two.

### Step 1: the surface names and the sum
- **Target:** `lib/prelude/prelude.chiral`, at `Op` (`:36-39`), `op-name`
  (`:44-51`), the extern block (`:59-72`).
- **Change:** `(op-mulhu)` into the sum immediately after `(op-mulhi)` on `:38`.
  `((op-mulhu) "mulhu")` into `op-name` immediately after the `op-mulhi` arm on
  `:49`. Two extern lines after `:72`, both `(-> I64 I64 I64)`, commented the way
  `shr` and `sar` are: `mulhi` as the signed high 64 of the product and `mulhu`
  as the unsigned high 64.
- **Insertion position, and why it is stated rather than assumed:** `op-mulhu`
  goes **beside** `op-mulhi` at every site, so the pair reads together in all
  five. Nothing in the tree reads a constructor's ordinal: `op-bytes`, `op-name`
  and `bini-body` all match by constructor, and the clobber table keys off
  `op-name`'s string (`emit-core.chiral:156-161`). The renumbering of `op-sar`
  through `op-shl` is therefore internal to a self-hosted compile, and the
  fixpoint below is what proves it rather than the sentence.
- **Size:** ~4 lines. S.

### Step 2: the erase boundary
- **Target:** `lib/lowering/tal/erase.chiral`, at `op-parse` (`:91-107`).
- **Change:** one arm after `:100`, `(false (case (str-eq op "mulhu") (true (some (op-mulhu)))`,
  and exactly two more `)` on the tail at `:107`. `lowerable-prim?` and
  `erase-prim` need no edit: the first routes through `op-parse`
  (`compile-back.chiral:282`) and the second gates on arity, which `mulhu`
  satisfies.
- **Size:** ~2 lines. S.

### Step 3: the machine layer
- **Target:** `lib/lowering/x64/mach.chiral`, at the synthetic-prim block
  (`:311-321`), `op-bytes` (`:359-391`), `bini-body` (`:971-1033`), the clobber
  comment (`:1395`) and `x64-clobbers` (`:1443-1464`).
- **Change:**
  1. `(def x-mul-rcx-1op Bytes (bc3 (b1 72) (b1 247) (b1 225)))   ; mul rcx`
     after `:321`. 225 is `0xE1`.
  2. The comment at `:313` gains the second name: `mulhi` is the signed high 64
     and `mulhu` the unsigned high 64, both leaving it in `rdx`.
  3. `((op-mulhu) (bcat x-mul-rcx-1op x-mov-rax-rdx))` after `:377`. The
     `x-mov-rax-rdx` tail at `:197` is shared with `op-mulhi` and is correct for
     both: `MUL r/m64` and `IMUL r/m64` both write `RDX:RAX`.
  4. `((op-mulhu) (bcat (x-mov-rcx-imm imm) (op-bytes op)))` immediately
     **before** `:1033`, so the terminal arm keeps its closing parens.
  5. The `or` chain at `:1455` gains `bin:mulhu` and `bini:mulhu`, with the two
     extra closing parens the nesting needs.
  6. The comment at `:1395` gains the `mulhu` row beside the `mulhi` one, same
     `{2,3}`.
- **Size:** ~6 logical edits, about 12 lines in a blank-line-separated file. M.

**Commit 1 is steps 1 through 3 together**, for the reason in §2 constraint 1.
Then the build rule, once, from the same blob each generation.

**Where the first agreement is expected: `C1 == C2`.** The discipline puts the
first agreement at `C2 == C3` when a change touches emission **and** the
compiler's own blob holds a site that change reaches
([[definitions/working-discipline]] `:34-42`, E188 at `032681f` being the
measured case). Both halves are required and only the first holds here. The
change adds an emission arm, and that arm is keyed on `op-mulhu`, which nothing
under `lib/` or `prog/` calls: `grep -rln mulhu` over the tree returns nothing
today and returns only this element's own files afterward. Every byte the new
generator emits for the compiler's own sources is a byte the old generator emits
the same way, which is the declaration-only case the discipline puts at
`C1 == C2`.

**If the prediction misses, do not stop at `C1 != C2`.** The rule caps the first
agreement at `C2 == C3` and stops at `C4`, so build `C3` from `C2` and `cmp C2
C3`. A `C1 != C2` here says one of two things and the first differing char says
which: a `mulhu` call site has arrived inside the compiler's own blob closure, or
the constructor's insertion position moved a tag ordering that the old generator
and `C1` resolve differently. The second would falsify step 1's stated reason for
placing `op-mulhu` beside `op-mulhi`, and it is recorded in the implementation
run either way. A `C2 == C3` that follows is still a correct build.

### Step 4: the probe
- **Target:** `prog/e189-widening-multiply.prog`, new file.
- **Change:** a root on the `prog/e188-apply-spine.prog` shape: it imports
  `prelude/prelude` and `ports/stdio`, **asserts nothing**, always exits 0, and
  prints one line per row. Every comparison lives in bash in step 5, because a
  probe that derives its own verdict is green under any mutant that changes what
  the verdict says. Each line carries the two operands and both answers, so the
  driver can re-derive the law without reading a golden. Six rows, and both call
  forms: at least one row takes an operand from `compile-main`'s own argument so
  the **register** path (`bin:mulhu`) is emitted, and at least one takes a
  literal so the **immediate** path (`bini:mulhu`, `mach.chiral:1025`) is
  emitted. Operands with the top bit set are built with `(shl 1 63)` and
  `(- 0 1)` so no literal-parsing question enters the gate. `i64->str`
  (`prelude.chiral:87`) prints them.
- **It needs the promoted compiler**, because `mulhu` does not parse until step 3
  lands. So it cannot be committed before commit 1 is promoted.
- **Does it owe a second fixpoint?** It touches `prog/`, and the tree already
  reasons about this: `tools/test/render-doc.sh:558-570` measures whether the
  changed module is inside `prog/compiler.prog`'s blob closure and says "no
  fixpoint obligation" when it is not. A root nothing imports is outside. The
  implementation run **measures** this with the same blob scan instead of
  asserting it, and records the number.
- **Phase 7 picks it up with no list edit** (`run-tests.sh:177`), so the probe
  must compile cleanly under the promoted compiler or Phase 7 goes red.
- **Size:** ~60 lines, new file. M.

### Step 5: the gate
- **Target:** `tools/test/mul-widen.sh`, new file; one `run_phase 32` line in
  `tools/test/run-tests.sh` after `:367`; the registration witness at
  `tools/test/registration.sh` grades the new dispatch line automatically.
- **Change:** §4. Neither file is `lib/` or `prog/`, so no build obligation.
- **Size:** ~200 lines, new file, plus 1 line. M.

## 4. Conformance gate

- **Named phase:** 32, `tools/test/mul-widen.sh`, dispatched from
  `tools/test/run-tests.sh`. 29, 30 and 31 are taken and 32 is the first free.
  `run-tests.sh` is the only authority for a phase number, which is the rule
  phase 24 already states there.
- **Baseline:** `bash tools/test/run-tests.sh` exits 0 at `assertions: 412
  passed, 0 failed` with `93 roots built, 0 failed` and gate PASSED, last
  recorded 2026-09-08 at `records/enforcement-arc.md:310`, after `b613a8f` and
  `38ecdba`. `records/lenses/problems.md:419` carries the same figure from
  2026-09-06 and `docs/implementation/optimizer-inventory.md:335` from
  2026-09-07. `mulhu` does not parse, so a probe calling it does not compile.
- **Expected:** the same run green with the probe compiling as a Phase 7 root
  and phase 32 reporting its own tally, `mul-widen: N passed, 0 failed`.

### What the gate observes

**The observable is disagreement, and each answer is checked on its own.** A row
asserting that `mulhi` returns something passes against the wrong primitive. The
six rows below are chosen so that three properties are separable.

| row | a | b | `mulhi` | `mulhu` |
|---|---|---|---|---|
| R1 | `2^32` | `2^32` | 1 | 1 |
| R2 | `2^40` | `2^40` | 65536 | 65536 |
| R3 | -1 | 3 | -1 | 2 |
| R4 | 3 | -1 | -1 | 2 |
| R5 | -1 | -1 | 0 | -2 |
| R6 | `(shl 1 63)` | 2 | -1 | 1 |

- **G1** the probe compiles to a non-empty ELF, runs and exits 0.
- **G2** R1 and R2 **agree**. Both operands are non-negative, so the two readings
  coincide, and a row where they differ convicts one of the two arms.
- **G3** R3 through R6 **disagree**. Each has one operand with its top bit set,
  and each disagreement is a different pair of values, so a swap that fixes one
  cannot fix all four.
- **G4** every row satisfies the wrapping identity, computed in bash from the
  row's own operands with the golden unread:

  ```
  mulhi == mulhu - (a < 0 ? b : 0) - (b < 0 ? a : 0)     (mod 2^64)
  ```

  This holds because `a = A - 2^64·[a<0]` over the unsigned word `A`, so
  `a·b = A·B - 2^64(s_a·B + s_b·A) + 2^128·s_a·s_b`, and dividing by `2^64`
  leaves `mulhu - s_a·B - s_b·A` in the low 64 bits. Bash `$(( ))` is 64-bit
  two's complement and wraps, so the driver checks the law without computing
  either 128-bit product. **G4 convicts a row the pinned table cannot**: a golden
  cut by running the code pins a wrong answer as correct for good, and G4 never
  reads the golden. This is `encoding.sh`'s G2-beside-G3 shape
  (`tools/test/encoding.sh:24-32`).
- **G5** both call forms are emitted. The register form and the immediate form
  are two arms (`mach.chiral:373` and `:1025`) and two clobber keys, so at least
  one row of each is required. **The probe's own output cannot settle this.** It
  reports each row's source shape, and which arm the compiler took is
  `emit-core.chiral:154-161`'s decision, made on whether the operand resolves to
  a tracked value. So G5 reads the emitted bytes. `bini-body`'s `op-mulhu` arm
  materializes through `x-mov-rcx-imm` (`mach.chiral:855`), which is `48 B9`
  followed by an 8-byte immediate, so the immediate form in the probe's ELF is
  `48 B9`, eight bytes, `48 F7 E1`, and the register form is a `48 F7 E1` with no
  such prefix. G5 counts both and fails on a zero in either column.

### Mutants, each actually run

A compiler generation costs about 2 s here (§2), so a mutant that rebuilds the
compiler from a mutated `lib/` is affordable. The driver copies `lib/` on
`tools/test/render-doc.sh:131-145`'s `mutlib` shape, including its guard that the
scratch `lib/` is a real directory and never a symlink, and its refusal of a
`sed` pattern that changed nothing. A mutated `lib/` alone proves nothing here,
because the probe is compiled by a binary that embeds the **old** backend, so
each mutant builds one generation from the mutated blob and compiles the probe
with **that** binary.

- **M1 `mulhu-emits-imul`**, the mutant the whole gate exists for. In the
  scratch `lib/lowering/x64/mach.chiral`, `(b1 225)` in `x-mul-rcx-1op` becomes
  `(b1 233)`, which is `E1` becoming `E9`. R3 through R6 collapse to agreement,
  G3 goes red on all four and G4 goes red on all four. **The gate dies on it.**
  Green when the mutant's output differs from the golden on exactly R3 to R6 and
  on nothing else, so a green row says the blast radius was the arm.
- **M2 `mulhi-emits-mul`**, the reverse: `(b1 233)` in `x-imul-rcx-1op` becomes
  `(b1 225)`. The same four rows move and they move the other way. M1 and M2
  together are what a single swapped ModRM byte can be, in both directions.
- **M3 `clobber-key-dropped`**. The `bin:mulhu`/`bini:mulhu` test is removed
  from `mach.chiral:1445`, so `x64-clobbers` falls through to `clb-rcx` at
  `:1453` and the allocator believes `rdx` survives a `mul`. This is a silent
  miscompile and not a build failure, which is why it is a row of its own.
  **Its observable rides on register pressure**, because whether the
  allocator actually places a live value in `rdx` depends on register pressure at
  the site. The implementation run **measures** whether M3 moves the probe. If it
  does not, the probe is enlarged with a value held live across the multiply and
  added to the result, and it is re-measured.
  ⚑ **A deterministic observable exists, and it is the third rung.**
  `x64-clobbers` (`mach.chiral:1433-1453`) is a pure function of the key string
  that `emit-core.chiral:156-161` builds from `op-name`, so M3 changes its answer
  for `bin:mulhu` and `bini:mulhu` by construction: `{2,3}` becomes `{3}`. A row
  reading that answer under both trees convicts M3 whatever the allocator does
  with `rdx`. The ladder is three rungs: the probe as written, the probe enlarged
  with values held live across the multiply, then `x64-clobbers`'s own answer.
  UNCONVICTED is reachable only after all three, and it still carries the
  measurement beside it and a row in `records/`, because a mutant claimed and not
  convicted is worse than one named honestly.
  ⚑ **The third rung's mechanism is the implementation run's to choose.** A
  `prog/` probe importing `lowering/x64/mach` is one shape and
  `lib/lowering/x64/emit.chiral:2` is the precedent, but E154's colliding
  top-level names are a live hazard that `prog/e188-apply-spine.prog:17-19` names
  from experience, and this file did not measure whether `mach` collides.
- **M4 `probe-calls-mulhi-twice`**, in a scratch `prog/`, the probe's `mulhu`
  calls become `mulhi`. No compiler rebuild. Every disagreement row collapses.
  This convicts the **golden** instead of the backend: it proves G3's four rows
  are load-bearing and that the probe's two columns come from two different
  primitives.

### The negative half

`prog/compiler.prog`'s blob holds no `mulhu` call site, which is what §3's
`C1 == C2` prediction rests on. A scan for a needle that matches nothing
anywhere passes by looking at nothing, so the scan is run beside its positive:
the base blob holds zero call sites and a scratch `lib/` with one `mulhu` call
spliced into a module the compiler imports makes the same scan see it arrive.
This is `render-doc.sh`'s G9-plus-M11 pair (`:558-580`).

- **Done when:** `bash tools/test/run-tests.sh` exits 0 with phase 32 green and
  its own tally, `bash tools/test/mul-widen.sh` exits 0 standalone, and M1, M2
  and M4 each redden exactly the rows they own with M3 either convicted or
  reported UNCONVICTED with its measurement.

## 5. Residue and links

### Deliberately unbuilt

- **The two-slot widening multiply.** `C38`, owned by `emitted-speed/X2`. Shape B
  pays two multiplies where the machine could pay one, and `C38` is what recovers
  it. Shape A paid the same price.
- **The unsigned less-than.** `C13`. An unsigned high word can return with its
  top bit set and every comparison in the `Op` sum is signed, so `(mulhu a b)`
  can produce a value that `<i` orders wrongly. `shr`, `band`, `bor`, `bxor` and
  `shl` already produce that residue, so this element adds a producer and no new
  kind of it. `docs/arcs/emitted-speed-arc.md:180-186` disposes `C13` as a
  finishing job and this run leaves that standing.
- **A consumer for either name.** Neither extern has a built caller on the day it
  lands. `.planning/AI-LANE-NUMERICS.md:66` wants the signed half and sits in the
  agent tier; `C17` wants the unsigned one and lands in `crypto-primitives/K25`,
  which is open and unminted. What earns the pair is the machine capability plus
  `docs/goals/emitted-speed.md:115` condition 6, and the element's own text says
  so instead of implying a workload is waiting.
- **A bank for the machine's operation set.** Measured absent in the design's §2
  and recorded by `docs/arcs/emitted-speed-arc.md` §3. No roster row holds one.
- **Arms in `fold-prim` and `eval-prim`.** Neither models `mulhi` today and
  neither models the six bitwise operations, so the sixteenth constructor owes
  them nothing the fifteenth already owes and has not paid. Extending them is
  work on seven operations at once and belongs to a row of its own.
- **The instruction-set baseline.** `C10`, `C11` and `C34` record that no
  document names what the emitted code may assume. `F7 /4` is in the 64-bit base,
  so this element needs no answer from that baseline and the baseline stays owed.

### Owed by this run's own findings

- **`tools/pack/pack.py --mark audited` cannot serve a design-minted element.**
  ⚑ The `--spec` half of this gap is CLOSED. `c1829f3` repointed `spec_mode`
  (`tools/pack/pack.py:684-693`) at `pipeline_artifact`, which resolves E189 to
  `docs/arcs/parts/emitted-speed-X7.md`. The post-audit flip did not move with
  it. `mark_mode` (`tools/pack/pack.py:651-681`) is still example-tier: it looks
  the element up in `docs/examples/INDEX.md`, wants a row whose status cell reads
  `specced`, and dies at `:681` with `INDEX row for E189 not found`. E189 has no
  such row, because a design-minted element registers in its arc roster. Every
  element minted from `docs/arcs/parts/` hits this, so E189 is the first of a
  class. The fix is a tool change and this run's write surface is the SPEC.
  **No roster row holds it.**
- **The roster row still reads `designed`.** `docs/arcs/emitted-speed-arc.md:277`
  would read `specced` had the pack run. With `spec_mode` repaired a `--spec` run
  now flips it and leaves this file alone (`pack.py:722-723`), so the flip is
  owed to that run or to a hand edit of the arc. Neither this run nor its audit
  touched the arc.

### Follow-on

- `emitted-speed/X2`, which owns `C38` and what a function may return.
- `crypto-primitives/K25`, open and unminted, which is where `C17`'s consumer
  lands.
- `emitted-speed/X8` and `emitted-speed/X9`, the arc's other requirement-6 rows.

### Related

[[arcs/emitted-speed-arc]], [[goals/emitted-speed]],
[[arcs/parts/emitted-speed-X7]], [[definitions/working-discipline]],
[[definitions/status-ledger]], [[elements/catalog]], [[elements/ledger]],
[[benchmarks/OPT-CANDIDATES-2026-09]], [[arcs/native-protocol-arc]],
[[arcs/crypto-primitives-arc]], [[decisions/decision-design-before-mint]],
[[decisions/decision-lane-split]].
