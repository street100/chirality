---
element: E204
slug: extern-honesty-pure-declared-extern
title: "**Extern honesty: a pure-declared extern reaches no crossing**"
design: arcs/parts/enforcement-N27.md
status: audited
updated: 2026-09-30
---

# E204 SPEC: **Extern honesty: a pure-declared extern reaches no crossing**

> The build half, produced by the `design-to-spec` run. The design at
> `docs/arcs/parts/enforcement-N27.md` made the design decisions and an audit gated
> them before this element minted. An implementation run follows THIS file.

## 1. Deliverable

- **After this runs:** a program declaring `(extern print (-> Str Unit))` is
  refused at load, and every compile refuses its image when a `native-lib`
  routine holds a `ti-sys` or calls a name outside `native-lib`, or when a
  `prim2lib-table` target names a routine outside `native-lib`.
- **Chosen shape:** Shape A, the design's §5 call: refuse at load beside
  `load-extern-linear`, close the pure library at emit beside `ck-tiprog`. A
  crossing is a `ti-sys` reached through `ti-call`; the arena growth that
  `ti-bnew` and `ti-cona` reach is substrate (design §5, question 1).
- **Non-goals:** a `=>` extern over a pure route stays legal (design §5,
  question 2). The five erased-outer externs are out of scope, since
  `ty-crosses` reads their inner `=>` (question 3). No transitive walk over
  `link-lib` or object code; `ck-tiprog` and `xw-fns` keep their scope.
  Emission is untouched: both checks read and refuse, and add no function to
  the image.

Measured 2026-09-30 at `37e99c0`, re-verified by this run:

- the probe below prints `crossed` and exits 7 under `bin/chirality run`;
- `grep -rnE '^\s*\(extern [^ ]+ \(->' lib prog` returns 43 declarations in
  four files. The five that are `crossing-wraps` keys (`pool-write`,
  `pool-read`, `pool-close`, `exit`, `halt`) carry an inner `=>`; the other 38
  name no `crossing-wraps` key;
- `native-lib` holds 30 routines, none with a `ti-sys`, every `ti-call` inside
  it naming a member; `prim2lib-table`'s 17 distinct targets are all members.

## 2. What the code forces

| target | the design assumed | the file admits | verdict |
|---|---|---|---|
| `lib/module/loader.chiral:457-476` | the refusal sits beside `load-extern-linear` | `load-extern` hands a well-typed extern to `load-extern-linear` at one arm, `((v-type l) (load-extern-linear s name tyt))` (`:467`, one occurrence). A new `load-extern-honest` slots between them | agrees |
| `lib/module/loader.chiral:11-14` | the loader can import `lowering/tal/crossing-wraps` | the loader imports `surface`, `kernel`, `list`, `diag`; `crossing-wraps` imports only `prelude/prelude` (`lib/lowering/tal/crossing-wraps.chiral:11`). No module under `lib/module`, `lib/surface` or `lib/typing` defines `crossing-wraps` or `cw-lookup` | agrees |
| `lib/typing/kernel.chiral:315-319` | `ty-crosses` is the predicate | reads only the codomain spine of `t-pi`, which is the design's "Pi spine" | agrees |
| `lib/typing/diag.chiral:99-114`, `:430-470` | one new `Judg` arm and its sentence | `r-judged` renders through `dg-judg-msg` (`:337`, `:677`); no other site matches `Judg` exhaustively | constrains: see below |
| `tools/test/arity.sh:547-549`, `:567-572` | nothing outside `lib/` reads `Judg` | `arity.sh` pins `Judg` at 37 arms and its M7 mutant at 38, and M7's `sed` anchors on the literal line `(jg-not-positive)       (jg-linear-field-decl) (jg-field-nontype))` (`:567`) | constrains: see below |
| `lib/lowering/compile-emit.chiral:292-296` | the closure check sits beside `ck-tiprog` in `emit-elf-m` | `emit-elf-m` binds `image` then cases on `ck-tiprog`; a case inserted between the `let` and `ck-tiprog` fits the chain | agrees |
| `lib/lowering/compile-emit.chiral:14-18` | `prim2lib-table` is in reach | the table lives in `lib/lowering/tal/erase.chiral:111-143`, which `compile-emit` does not import; `erase` imports `prelude`, `ssa`, `erased-nf`, `crossing-wraps` (`:20-23`) and nothing that imports `compile-emit` | constrains: see below |
| `lib/lowering/compile-emit.chiral:238-252` | the walker follows `xw-code`'s pattern | `xw-code` and `xw-branches` walk `t-seq`, `ti-ret`, `ti-tcase` with its default; `TInstr` carries `ti-sys (dst nr args)` and `ti-call (dst fname args)` (`lib/lowering/tal/ir.chiral:24`, `:33`) | agrees |
| `lib/lowering/tal/bytes.chiral:813-825` | `native-lib` is one list of `TIFn` | it is; the members' names come from `tifn-nm` (`compile-emit.chiral:172-173`) | agrees |
| `lib/lowering/tal/sys-check.chiral:71-77` | `ck-tiprog` already refuses a `ti-sys` in `native-lib` | it does, keyed by function name, since no `native-lib` routine has a `sys-row`; and a routine renamed to a registered name collides with its `sys-lib` twin at `first-dup-go` (`compile-emit.chiral:304`). So on today's registry E204's `ti-sys` arm refuses nothing the image did not already refuse. What it adds is independence from the registry, which is swappable data (`sys-check.chiral:11-13`): a `native-lib` routine that a registry row names, with a matching number, passes `ck-tiprog` and `first-dup-go` and is refused by E204 alone. The gate's `ti-sys` row poisons exactly that case | constrains: see below |

- **Constraints carried into §3:**
  1. The new `Judg` arm goes on its own line after `(jg-pure-crossing)`, so
     `arity.sh:567`'s anchor still matches once. `arity.sh:548` moves to 38 and
     its M7 row (`:571-572`) to 39.
  2. `compile-emit` gains `(import "lowering/tal/erase")`. The new names use
     the prefix `plib-`, which is unused under `lib/` and `prog/`.
  3. The emit check runs **before** `ck-tiprog`, so a `native-lib` offender is
     named in E204's sentence. No gate row depends on the order.
  4. Ten `compile-main` roots hold `module/loader` or `compile-emit` in their
     import closure: `prog/compiler.prog`, `e185-apply-word.prog`,
     `e186-capture-fields.prog`, `e188-apply-spine.prog`,
     `optimizer-census.prog`, `paren-audit.prog`, `prose-lint.prog`,
     `shape-census.prog`, `test-runner.prog`, `wield.prog`. Their bytes move
     because their source moves. Every other root's must not.
- **Refusals:** none.

## 3. Change plan (ordered, commit-sized)

### Step 1: the mutant builder takes a source root

- **Target:** `tools/test/mutant.sh`, at `mutant_build` (`:127`).
- **Change:** inside `mutant_build`, `local src="${CHIRALITY_MUTANT_SRC:-$MUT_REPO}"`,
  and copy `lib`, `prog`, `bin` from `$src` at `:131`. Read per call, so a
  row can point one build at a pre-poisoned tree (E3). The
  default keeps every existing caller byte-for-byte on its current tree. The
  E204 gate's poison rows need it: under a mutant leg they must build from the
  mutant's tree, or they grade the shipped sources and convict nothing.
- **Size:** S, three lines. Tooling only, no rebuild.
- **Commit 1:** `mutant.sh: mutant_build reads CHIRALITY_MUTANT_SRC`.

### Step 2: the load refusal

- **Target:** `lib/typing/diag.chiral`, `Judg` (`:99-114`) and `dg-judg-msg`
  (`:430-470`).
- **Change:** a line `(jg-extern-pure-crossing)` after `(jg-pure-crossing)`;
  in `dg-judg-msg` the arm
  `((jg-extern-pure-crossing) (str-cat "extern declared pure routes to a crossing (use => not ->): " n))`.
- **Target:** `lib/module/loader.chiral`, imports and `load-extern`.
- **Change:** `(import "lowering/tal/crossing-wraps")` after `:14`. `:467`
  becomes `((v-type l) (load-extern-honest s name tyt))`, and beside
  `load-extern-linear`:

  ```
  (declare load-extern-honest (-> Sig Str Term LoadR))
  (def load-extern-honest
    (lam (s name tyt)
      (case (ty-crosses tyt)
        (true  (load-extern-linear s name tyt))
        (false
          (case (cw-lookup crossing-wraps name)
            (none     (load-extern-linear s name tyt))
            ((some w) (ld-err (r-judged (subj-extern name) (jg-extern-pure-crossing)))))))))
  ```

  with a comment above it stating the rule and naming E204. The line
  `((some w) (ld-err (r-judged (subj-extern name) (jg-extern-pure-crossing))))`
  occurs once; it is the M1 anchor.
- **Target:** `tools/test/arity.sh:533`, `:548-549`, `:571-572`.
- **Change:** the count reads 38 ("E171 and E204 added one each"), M7's 39.
- **Size:** M, about 25 lines.

### Step 3: the pure library closed at emit

- **Target:** `lib/lowering/compile-emit.chiral`.
- **Change:** `(import "lowering/tal/erase")` after `:18`. Before `emit-elf-m`,
  a block headed by a comment stating the rule, the substrate exclusion
  (`:206-211`) and E204:

  ```
  (declare plib-names (-> (List TIFn) (List Str)))
  (declare plib-instr (-> (List Str) Str TInstr (Maybe Str)))
  (declare plib-code (-> (List Str) Str TCode (Maybe Str)))
  (declare plib-branches (-> (List Str) Str (List (Pair (Pair I64 (List I64)) TCode)) (Maybe Str)))
  (declare plib-fns (-> (List Str) (List TIFn) (Maybe Str)))
  (declare plib-targets (-> (List Str) (List (Pair Str Str)) (Maybe Str)))
  (declare pure-lib-offender (-> (List TIFn) (List (Pair Str Str)) (Maybe Str)))
  ```

  `plib-instr` answers `fn " holds ti-sys"` on `ti-sys`, and
  `fn " calls " f " outside native-lib"` on a `ti-call` whose `f` is no
  member. `plib-code`, `plib-branches` and `plib-fns` walk as `xw-code`,
  `xw-branches` and `xw-fns` do, carrying the routine's name.
  `plib-targets` answers `"prim " k " routes to " v " outside native-lib"` for
  the first pair whose `v` is no member. `pure-lib-offender lib t` binds
  `(plib-names lib)` once, answers `plib-fns`'s offender if any, else
  `plib-targets`'s.
- **Change in `emit-elf-m`:** after the `image` binding,

  ```
  (case (pure-lib-offender native-lib prim2lib-table)
    ((some m) (elf-err (str-cat "E204 pure library REFUSED emit: " m)))
    (none
  ```

  wrapping the `ck-tiprog` case, with one closing paren added at the chain's
  foot. The call `(pure-lib-offender native-lib prim2lib-table)` occurs once;
  it is the M2 anchor.
- **Size:** M, about 45 lines.

### Step 4: rebuild under the build rule

Steps 2 and 3 are compiler source and are built together, per
`docs/definitions/working-discipline.md`: `build-new`, test, promote.

1. `chirality_blob_file "lib:prog" prog/compiler.prog` to a scratch blob. `C1`
   from `bin/chirality-bin`, `C2` from `C1`, a non-empty check before each
   `cmp`. Emission is untouched, so `C1 == C2` is expected. If they differ,
   `C3` from `C2`, then `C4`, and stop at `C4`.
2. **The bytes proof.** `git archive HEAD lib prog bin` into a scratch
   directory, blob HEAD's `prog/compiler.prog` there, compile it with `C2`,
   and `cmp` the result with the prior `bin/chirality-bin`. Identical means
   an unchanged source emits unchanged bytes through the new compiler.
3. **The roots proof.** For every `compile-main` root under `lib/` and `prog/`
   outside §2's ten and outside `*_reject_*`, compile with the prior
   `bin/chirality-bin` and with `C2`, and `cmp` each non-empty pair. Every
   pair identical; the three phase-7 known failures fail under both.
4. The gate below under `CHIRALITY_COMPILE=C2`, all rows green. Then the same
   gate under the prior binary with `CHIRALITY_NO_MUTANTS=1`: rows L1 to L4 red.
5. Promote `C2` to `bin/chirality-bin`, then the suite.

### Step 5: the gate, its samples and its registration

- **Target:** `prog/samples/e204_reject_pure_print.prog`, the probe:

  ```
  (import "prelude/prelude")
  (extern print (-> Str Unit))
  (def f (-> I64 I64) (lam (n) (let (u (print "crossed")) n)))
  (def compile-main (=> Unit I64) (lam (u) (f 7)))
  ```

  and `prog/samples/e204_reject_pure_exit.prog`, a pure erased-outer spine
  `(extern exit (-> (0 A (type 0)) (-> I64 A)))` with a trivial
  `compile-main`. The `_reject_` infix keeps both out of phase 7
  (`tools/test/run-tests.sh:179`).
- **Target:** `tools/test/extern-honesty.sh`, on `tools/test/membrane.sh`'s
  frame: `refuse_file`, `admit_file`, `runs`, a red log, a mutant section that
  pins each mutant's full red set. It sets `CHIRALITY_MUTANT_DIR="$T/mut"` and
  `CHIRALITY_MUTANT_BASE="$CC"` before sourcing `mutant.sh`, so that file's
  own `EXIT` trap is never installed. §4 lists the rows.
- **Target:** `tools/test/run-tests.sh`, after phase 36:
  `run_phase 37 "extern honesty, load and emit (E204)"   extern-honesty.sh`,
  with a comment giving the build cost.
- **Records, same commit:** catalog and ledger rows to `built`,
  `docs/definitions/status-ledger.md`, the `enforcement/N27` roster row.
- **Size:** L, about 200 lines of gate.
- **Commit 2:** `E204 built: extern honesty refused at load and emit
  (enforcement/N27)`, holding steps 2 to 5 and the promoted binary.

## 4. Conformance gate

- **Baseline:** phase 37 does not exist. The probe runs and exits 7; nothing
  reads an extern's name against its route, and nothing walks `native-lib`.
- **Expected:** phase 37 green, every row below `ok`, both mutants reddening
  exactly their pinned sets.
- **Named phase:** `run_phase 37 "extern honesty, load and emit (E204)"
  extern-honesty.sh`. 34 and 35 are claimed by E201 and E202's SPECs and 36 is
  E171's, so 37 is the first free.

**L: the load refusal.** Each wants a refusal whose output carries
`extern declared pure routes to a crossing (use => not ->): <name>`.

| row | fixture |
|---|---|
| L1 the probe: a pure `print` called from a `->` def | `prog/samples/e204_reject_pure_print.prog`, want name `print` |
| L2 a pure `put`, declared and never called | inline root, `(extern put (-> Str Unit))` |
| L3 a pure `read`, another route | inline root, `(extern read (-> I64 I64 Bytes))` |
| L4 an erased outer binder over a pure spine | `prog/samples/e204_reject_pure_exit.prog`, want name `exit` |

**A: the controls.**

| row | wants |
|---|---|
| A1 a `=>` `print` declared in the root and called from a `=>` `compile-main` | runs, program exit 7 |
| A2 each file holding a `->` extern loads | the file list is `grep -rlE '^\s*\(extern [^ ]+ \(->' lib prog`, mapped to import keys. A row fails unless the list holds `lib/prelude/prelude.chiral` and `prog/prapanca/backend.chiral`; then one `admit` per file, a root importing it. Four today, the 43 declarations |
| A3 a `=>` extern over a pure route | `prog/samples/prapanca-code-test-live.prog` compiles; it binds `backend-open`, the E159 mint |

Phase 7 stays the wide control: every `compile-main` root still compiles.

**E: the emit rule, graded on the sources.** Each row builds a compiler from
the tree `CHIRALITY_MUTANT_SRC` names (the repo by default) with one poison
applied, through `mutant_build` under a label unique to the leg, then compiles
a trivial root with it. Each wants a refusal carrying
`E204 pure library REFUSED emit: ` and the offender sentence.

| row | poison | wants |
|---|---|---|
| E1 a `native-lib` routine calls outside it | `lib/lowering/tal/bytes.chiral`, `(ti-fn "nb-id" 1 1 (ti-ret 0))` to `(ti-fn "nb-id" 1 2 (t-seq (ti-call 1 "nb-arena-fail" (cons 0 nil)) (ti-ret 0)))` | `nb-id calls nb-arena-fail outside native-lib` |
| E2 a `prim2lib-table` target outside `native-lib` | `lib/lowering/tal/erase.chiral`, `(cons (pair "brepeat" "nb-brepeat")` to `(cons (pair "brepeat" "nb-sys-write")` | `prim brepeat routes to nb-sys-write outside native-lib` |
| E3 a `native-lib` routine holds a registered `ti-sys` | two files. The row copies `lib`, `prog`, `bin` from its source tree to a scratch tree, replaces `(nil)` in `lib/lowering/tal/target-linux.manifest` (one occurrence) with `(cons (sys-row "nb-id" 60) (nil))`, then calls `mutant_build` with `CHIRALITY_MUTANT_SRC` at that tree and `bytes.chiral`'s E1 anchor to `(ti-fn "nb-id" 1 2 (t-seq (ti-sys 1 60 (cons 0 nil)) (ti-ret 0)))`. `ck-tiprog` admits it (registered, matching number) and `first-dup-go` admits it (`nb-id` is in no other library) | `nb-id holds ti-sys` |

Every anchor occurs once today. A poison build that answers `FAIL:` is `bad`,
never `ok`.

**M: the mutants.** Each is built by `mutant_build`, must differ from the base,
and its leg re-runs this file under the mutant compiler with
`CHIRALITY_MUTANT_SRC` set to that mutant's tree, so the E rows build from it.

| mutant | change | reddens exactly |
|---|---|---|
| M1 load refusal off | `lib/module/loader.chiral`, `((some w) (ld-err (r-judged (subj-extern name) (jg-extern-pure-crossing))))` to `((some w) (load-extern-linear s name tyt))` | L1, L2, L3, L4 |
| M2 emit closure off | `lib/lowering/compile-emit.chiral`, `(pure-lib-offender native-lib prim2lib-table)` to `(pure-lib-offender nil nil)` | E1, E2, E3 |

Under M2 all three poison compilers emit: E1 and E2 hold no `ti-sys`, and
E3's is registered with its number. Each row reddens because the image is
admitted. No row's red rests on which check's sentence answers. A non-empty base red set is `bad`
before any mutant is scored.

⚑ **Cost.** Three poison builds on the base run, two mutant builds, and three
poison builds in each leg: eleven compiler generations, about 40 s each,
so about seven minutes. No tree rule caps a phase's cost; phases 33 and 36
rebuild compilers inside the suite and state the cost in their `run_phase`
comment (`tools/test/run-tests.sh:370-383`), which step 5's comment follows.

- **Mutant:** M1 and M2 above, each run, each pinned to its full red set.
- **Done when:** `bash tools/test/run-tests.sh` prints phase 37 with 0 failed,
  the four L rows are red under the prior binary, step 4's two proofs hold,
  and `C1 == C2` (or the first agreement by `C4`).

## 5. Residue and links

- **Deliberately unbuilt:**
  - [[banks/port]] Shard 3 still grades the derivation sound for an extern
    (`docs/banks/port.md:147-148`). A `doc-audit` of the bank once this builds.
  - The substrate exclusion is stated in the compiler's comments and in E204's
    catalog row, and in no decision. The design's §6 names the catalog row as
    its home.
  - `E198`'s catalog row counts 34 prelude externs; 35 open `->` today. Owned
    by `E198`'s SPEC stage.
  - `link-lib` and object code keep per-function scope under `ck-tiprog` and
    `xw-fns`; E204 closes `native-lib` alone, which is every route a pure
    extern takes (design §2).
- **Follow-on:** `E198` (extern census, designed).
- **Related:** [[arcs/parts/enforcement-N27]], [[arcs/parts/enforcement-N26]],
  [[arcs/parts/enforcement-N20]], [[banks/port]].
