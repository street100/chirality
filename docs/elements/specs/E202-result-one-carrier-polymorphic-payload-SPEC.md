---
element: E202
slug: result-one-carrier-polymorphic-payload
title: "**`Result`: one carrier polymorphic in the payload and in the error**"
design: arcs/parts/errors-as-values-EV1.md
status: draft
updated: 2026-09-29
---

# E202 SPEC: **`Result`: one carrier polymorphic in the payload and in the error**

> The build half, produced by the `design-to-spec` run. The design at
> `docs/arcs/parts/errors-as-values-EV1.md` made the design decisions and an audit gated
> them before this element minted. An implementation run follows THIS file.

## 1. Deliverable

- **After this runs:** one new module `lib/prelude/result.chiral` declares
  `(data Result ((A (type 0)) (E (type 0))) (res-val (v A)) (res-why (e E)))`,
  a program instantiates it at two unrelated error sums and runs, a program that
  puts one sum's constructor into the other's `Result` is refused with a pinned
  line, and `prog/compiler.prog`'s blob is byte-identical before and after.
- **Chosen shape:** Shape A and Shape E, taken at
  `docs/arcs/parts/errors-as-values-EV1.md` §5. A new home outside the compiler
  closure, the error slot a free parameter, no second field on either arm, and
  the constructors `res-val` and `res-why` forced by the namespace measurement in
  the design's §2c.
- **Names this SPEC fixes**, which the design left unstated: the gate script
  `tools/test/result.sh`, the sample `tools/test/samples/e202_result.prog`, the
  refusal fixture `tools/test/samples/e202_result_reject_cross.prog`, and the
  sample's local chaining helper `e202-then`. All four are free tree-wide,
  measured 2026-09-29 by `ls` and `grep -rn` over `lib/`, `prog/` and `tools/`.
  The helper takes a name no combinator row will want, so `EV2` keeps its
  choice of `bind`, `map-err` and anything spelled `res-…`.
- **Non-goals.** The combinators, which are `errors-as-values/EV2`. Any adoption
  of the type by a boundary: `MfR` is `errors-as-values/EV10`, `PR` is
  `errors-as-values/EV11`, and `NewPufR` is residue with no row (§5). A witness
  or renderer for the error slot, which the design's §5 question 2 defers to
  `errors-as-values/EV11` and which this element must leave room for. Any
  recoverability field, which `docs/banks/effect-and-alarm.md:201-206` homes on
  the crossing's handler signature. Any compiler generation: nothing in the
  closure changes (§2, last row).

## 2. What the code forces

Every line below was opened in the working tree at `70c0191` on 2026-09-29, and
the probes were run from the scratchpad against `bin/chirality-bin` and left
nothing in the tree.

| target | the design assumed | the file admits | verdict |
|---|---|---|---|
| `lib/prelude/` | a new file beside nine | nine files: `alist`, `doc`, `list`, `map`, `maybe`, `ord`, `prelude`, `set`, `string`. No `result.chiral` under `lib/` or `prog/`, so the key `prelude/result` resolves to nothing today | agrees |
| `lib/prelude/maybe.chiral:4`, `:9` | the header form `(module prelude/result (cat A) (alt upper))` after one `import` | `(import "prelude/prelude")` at `:4` and `(module prelude/maybe (cat A) (alt upper))` at `:9`, with the E161 comment at `:6-8` stating that a module binding no extern has an empty `crossings` by derivation. The new file copies the form | agrees |
| `lib/prelude/prelude.chiral:20-21` | two type parameters have a precedent | `(data Pair ((A (type 0)) (B (type 0)))` with `(pair (fst A) (snd B))`, the exact parameter spelling the new declaration uses | agrees |
| `lib/prelude/map.chiral:12` | `prelude/maybe` enters the closure here, so Shape B would put the type inside it | `(import "prelude/maybe")` at `:12` | agrees |
| names `Result`, `res-val`, `res-why` | zero declarations tree-wide | `grep -rnE '\((res-val\|res-why)\b\|data Result\b'` over `lib/`, `prog/` and `tools/` returns nothing. The three `…Result` types in the tree are `BindResult` (`prog/prapanca/core/types.chiral:42`) and `PreflightResult` (`prog/prapanca/core/types.chiral:106`) and `RenderResult` (`prog/scriba/cmd-types.chiral:13`), none of which is the name | agrees; the gate re-runs it (G5) |
| `lib/surface/parse.chiral:458-459`, `lib/surface/surface.chiral:91-93` | the constructor namespace is one list per blob and the first match wins | `senv-add-ctor` conses `(pair cn home)` onto the list, and `assoc` returns the first `str-eq` match | agrees; a collision is silent at declaration, which is why G5 is a gate row |
| `lib/module/loader.chiral:547-551` | a duplicate is refused on the data type name alone | `load-data` raises `r-redeclared` when `sig-data s dn` already holds `dn`, and nothing compares constructor names | agrees |
| `lib/typing/diag.chiral:458-459` | the refusal text is the `jg-ctor-other-data` judgment | `(str-cat n " checked against a different data type")` at `:458`. The Str mutant's text is its neighbour `jg-ctor-nondata` at `:459`, `(str-cat n " checked against a non-data type")` | agrees, and the two sit one line apart, which is why the pin is the whole line |
| the sample, probed 2026-09-29 | two unrelated sums, both cased with no `_` arm, one higher-order chain, exit 0 | the probe below compiled and ran, exit 0, four checks holding: `MyErr` of three arms and `IoErr` of two, `e202-then` typed `(-> (0 A (type 0)) (0 B (type 0)) (0 E (type 0)) (-> A (Result B E)) (Result A E) (Result B E))`, its err arm `((res-why e) (res-why e))` unannotated | agrees |
| `compile-main`'s type | nothing stated | `(-> I64 I64)`, as at `tools/test/samples/e100_poly_ho.prog:50`. The probe's first draft wrote `(-> I64)` and was refused with `load: arrow needs at least a domain and codomain` | **constrains** |
| the refusal, probed 2026-09-29 | the pinned line is `load: me-big checked against a different data type` | the compiler's stderr reads that line exactly when an `IoErr`-typed `Result` is handed `(res-why (me-big 7))` | agrees |
| the Str mutant, probed 2026-09-29 | the fixture still fails `check` under it, with different text | it does. With `(res-why (e E))` replaced by `(res-why (e Str))` in a scratch copy of the module, **both** the sample and the fixture fail with `load: me-big checked against a non-data type`. The constructor in the line is the same, so the constructor half of the pin does not separate this mutant and the phrase half does | **constrains**: the pin compares the whole line |
| `bin/chirality check` before the module exists | nothing stated | `chirality-resolve: no module 'prelude/result'`, exit 1. An exit-code pin on the fixture is green today, before anything is built | **constrains**: G3 compares text, and the gate refuses to run while the module is absent (§3 step 1) |
| `prog/shape-census.prog:114-115`, `:119-120` | adding the module moves `SC-data-decl`, `SC-data-name` and `SC-ctor-head` | measured by running `E201`'s instrument over the 312 tracked sources with a scratch copy of the module added: **four readings move, one more than the design names.** `SC-data-decl` 516 to 517, `SC-data-name` 487 to 488, `SC-ctor-head` 1214 to 1216, `SC-ctor-head-sites` 1251 to 1253. Every closure column holds, and `census files` reads 313. The other ten readings hold, because `err-side?` admits `-err`, `-bad`, `-fail` and `bad!` and `ok-side?` admits `-ok`, `ok!` and a contextual `-r`, and neither admits `res-val` or `res-why` | **constrains**: step 1 re-pins four lines of `WANT_LIVE`, and §5 carries the consequence for the adoption rows |
| `tools/test/shape-census.sh:2`, `:93-106` | `E201`'s gate is unregistered | its header already reads `suite phase 34`, and its `WANT_LIVE` pins the four readings above at their 312-file values. Adding the module reddens its R2 | **constrains**: the re-pin rides in the same commit |
| `tools/test/run-tests.sh:378` | the next free phase number | `run_phase 33` is the last dispatch line. 34 is free in the table and **claimed** by `shape-census.sh:2`, so this gate takes **35**. `tools/test/registration.sh` admits 35: its G5 refuses a duplicate number and its G6 refuses only 21 to 23 | **constrains** |
| `tools/test/registration.sh`, run 2026-09-29 | the suite is green | **it is red today, before this element**: `G1:ok G2:bad G3:ok G4:ok G5:ok G6:ok`, the finding `UNWITNESSED shape-census.sh is on disk, is dispatched by no run_phase line, and declares no reason to be out`, and the five mutant rows that pin the full base line go red with it, `2 passed, 7 failed`. `E201` landed at `4e9649f` after the 2026-09-28 green run | **constrains**: §4's done-when names this red line as pre-existing |
| `tools/test/encoding.sh:219-243` | a leaf module's closure row has a precedent | G5 there asserts `prog/compiler.prog`'s blob holds zero `unit/encoding` and that a scratch `lib/` importing the module makes the same scan see it arrive, so the negative half cannot pass by looking at nothing | agrees; G4 below copies it |
| `prog/compiler.prog`'s closure | the new module is outside it | 61 distinct line-anchored `(end-module "…")` keys in `chirality_blob_file "lib:prog" prog/compiler.prog`, and `prelude/result` is absent from them. Nothing in the plan edits a file whose key is in that list | agrees; **no fixpoint is owed** |

- **Constraints carried into §3:** `compile-main` is `(-> I64 I64)`. The gate
  takes phase 35. The fixture pin compares the whole stderr line. The census
  re-pin covers four readings. The gate asserts the module exists before any
  row, so an absent module cannot pass G3.
- **Refusals:** none. Every target admits Shape A and Shape E.

## 3. Change plan (ordered, commit-sized)

One commit. The module, its gate and the census re-pin land together, because
the module alone reddens `E201`'s R2 and the gate alone has nothing to grade.

**The build rule does not apply to any step, and step 0 proves it.** The only
`lib/` file the plan touches is new and its key is outside the closure, so the
compiler's blob holds still and `bin/chirality-bin` stays as shipped. If any
step comes to touch a file whose key is in the 61, the rule in
[[working-discipline]] applies in full and this paragraph is wrong.

### Step 0: the blob before
- **Target:** none written.
- **Change:** `. bin/chirality-resolve.sh; chirality_blob_file "lib:prog" prog/compiler.prog > $S/blob.before`,
  then `[ -s $S/blob.before ]`. `$S` is the run's scratchpad.
- **Size:** S.

### Step 1: the module
- **Target:** `lib/prelude/result.chiral`, new.
- **Change:** a header comment of a few lines, then `(import "prelude/prelude")`,
  then `(module prelude/result (cat A) (alt upper))`, then the declaration
  verbatim from the catalog row. The comment says four things and nothing else:
  the type generalises `PR`, `MfR` and `NewPufR` in the error slot; it sits
  outside `prog/compiler.prog`'s closure until a boundary imports it; the error
  slot is a free parameter and `errors-as-values/EV11` decides whether it needs a
  witness; it carries no recoverability fact, which
  `docs/banks/effect-and-alarm.md:201-206` homes on the handler signature. No
  `def`, no second field, no companion type, no renderer: the design's §5
  question 2 lists all three as things this row must leave open.
- **Size:** S, 12 to 18 lines.

### Step 2: the sample
- **Target:** `tools/test/samples/e202_result.prog`, new.
- **Change:** imports `prelude/prelude` and `prelude/result`. Declares `MyErr`
  (`me-empty`, `(me-big (n I64))`, `me-neg`) and `IoErr` (`io-eof`,
  `(io-denied (path Str))`), which share no constructor name. One renderer per
  sum to `I64`, each an exhaustive `case` with no `_` arm. `e202-then` with the
  signature in §2. Two producers, `(-> I64 (Result I64 MyErr))` and
  `(-> Str (Result I64 IoErr))`, and one consumer per instantiation. A
  `compile-main (-> I64 I64)` whose exit code is `0` when every check holds and
  the failing check's number otherwise, with at least one ok-path and one
  err-path check at **each** instantiation, and one err-path check routed
  through `e202-then`. The `IoErr` declarations and checks sit between two
  marker comments, `; ---- io: begin` and `; ---- io: end`, so M3 can cut them
  from a copy. The header states that it is resolver-compiled, what each exit
  code means, and that it holds no `_` arm on purpose.
- **Size:** M, 60 to 90 lines. The probe that passed was 48.

### Step 3: the refusal fixture
- **Target:** `tools/test/samples/e202_result_reject_cross.prog`, new.
- **Change:** the same two sums and imports, one def typed
  `(-> Str (Result I64 IoErr))` whose err branch is `(res-why (me-big 7))`, and
  a `compile-main` that calls it. It holds **exactly one** ill-typed site, so
  under the base module the first refused line is that site's. The header
  records the expected line, `load: me-big checked against a different data type`,
  and names `lib/typing/diag.chiral:458`.
- **Size:** S, 20 to 30 lines.

### Step 4: the gate
- **Target:** `tools/test/result.sh`, new.
- **Change:** the five rows and five mutants of §4, on `encoding.sh`'s layout:
  a header naming each row and mutant, a `bad`/`ok` tally, a final
  `result: N passed, M failed` line that `run_phase` sums. It compiles with
  `chirality_blob_file "$REPO/lib:$REPO/prog"` and `$CC`, reads the compiler's
  stderr directly, and keeps `ulimit -s unlimited` on every build. It exits 2
  before any row if `lib/prelude/result.chiral`, the sample or the fixture is
  missing. Every mutant runs against a scratch copy, is `cmp -s`'d against its
  base so a stale pattern reports as a failure, and pins the whole verdict line.
  A mutant's scratch `lib/` is refused if it is a symlink, as `encoding.sh:230`
  does.
- **Size:** M, 200 to 300 lines. `encoding.sh` is 306.

### Step 5: register the phase
- **Target:** `tools/test/run-tests.sh`, after `:378`.
- **Change:** a comment block stating that 35 is taken because 34 is claimed by
  `tools/test/shape-census.sh:2`, under the 2026-09-06 ruling the block at
  `:347-350` states, then `run_phase 35 "one carrier, two error slots (E202 Result)" result.sh`.
- **Size:** S.

### Step 6: the census re-pin
- **Target:** `tools/test/shape-census.sh:86-106`.
- **Change:** re-run the gate and read its live readings. Replace four lines of
  `WANT_LIVE` with the new values and date the comment: `SC-data-decl 517 206`,
  `SC-data-name 488 206`, `SC-ctor-head 1216 592`, `SC-ctor-head-sites 1253 592`
  as measured 2026-09-29, and change `312 files` at `:88` to the count the run
  reads. **Re-read all fourteen**, since another session's edit to `lib/` or
  `prog/` between this SPEC and the implement run moves others, and the pin is
  whatever the tree reads that day. The ten readings this element does not move
  must not move between the two runs of step 7, which is how a foreign drift is
  told apart from this element's. Whether R2 keeps pinning all fourteen whole
  is an open call on `E201`'s registration. If it is ruled to pin only the
  readings a requirement gates, none of the four this element moves is among
  them and this step reduces to the date and the file count.
- **Size:** S.

### Step 7: prove the closure and run the gates
- **Change:** `chirality_blob_file "lib:prog" prog/compiler.prog > $S/blob.after`,
  `[ -s $S/blob.before ] && [ -s $S/blob.after ] && cmp $S/blob.before $S/blob.after`.
  Then `bash tools/test/result.sh`, `bash tools/test/shape-census.sh`, and
  `tools/test/run-tests.sh` in full.
- **Size:** S to run. The suite takes minutes.

## 4. Conformance gate

- **Baseline:** no `Result`, and `tools/test/result.sh` does not exist.
  `tools/test/registration.sh` reads `G1:ok G2:bad G3:ok G4:ok G5:ok G6:ok`,
  `2 passed, 7 failed`, on `shape-census.sh` alone (§2). The full suite, run
  2026-09-29 at `70c0191` with the author's uncommitted edits in the tree,
  reads `assertions: 434 passed, 7 failed` and `96 roots built, 0 failed`,
  and exits `gate FAILED (1 failing check(s)/phase(s))`. All seven failures are
  `registration.sh`'s. The 2026-09-28 green run read 441 and 95; the one new
  root is `prog/shape-census.prog`.
- **Named phase:** 35, `tools/test/result.sh`.
- **The five rows.** Each is one token of the verdict line
  `G1 G2 G3 G4 G5`.
  - **G1, the sample runs.** `e202_result.prog` resolves, compiles to a non-empty
    ELF, and exits 0.
  - **G2, two error slots, both exhaustive.** Read off the sample's text with
    comments stripped: the second arguments of its `(Result … …)` type forms
    number at least two distinct names, and the sample holds no `(_ ` arm. A
    carrier that was accidentally monomorphic passes a one-instantiation sample,
    and G2 is the row that says the sample held two.
  - **G3, the refusal line.** Compiling `e202_result_reject_cross.prog` exits
    non-zero **and** the first line of the compiler's stderr equals
    `load: me-big checked against a different data type`, compared whole.
  - **G4, outside the closure, two halves.** `prog/compiler.prog`'s blob holds
    zero line-anchored `(end-module "prelude/result")` markers, and a scratch
    `lib/` whose `prelude/map.chiral` gains `(import "prelude/result")` makes the
    same scan find one. The negative half alone would pass on a misspelt needle.
  - **G5, the names collide with nothing.** `E201`'s instrument, built from
    `prog/shape-census.prog`, run twice over the tracked `lib/` and `prog/`
    sources: once as listed and once with `lib/prelude/result.chiral` left out.
    The difference is `SC-data-decl` +1, `SC-data-name` +1, `SC-ctor-head` +2,
    `SC-ctor-head-sites` +2, and nothing else moves. A `Result` that collided
    with an existing data name would read `SC-data-name` +0, and a constructor
    that collided would read `SC-ctor-head` +1 against `SC-ctor-head-sites` +2.
    Beside it, `git grep -n '(data Result'` over the whole tree returns exactly
    one line, the module's, so `tools/` is covered too. This is
    `docs/examples/E181-pretty-term-doc.md:236`'s tree-wide name census, run
    through the committed instrument instead of a second scanner.
- **The five mutants, each run.** The line each must produce is pinned whole by
  the implement run from what it measures; the rows named below are the ones
  it must redden.
  - **M1 str-slot.** `(res-why (e E))` becomes `(res-why (e Str))` in a scratch
    module. Measured 2026-09-29: the sample fails with
    `load: me-big checked against a non-data type` and so does the fixture.
    G1 and G3 redden. G3 reddens through the phrase alone, since the
    constructor is the same `me-big`; an exit-code pin would stay green.
  - **M2 drop-payload.** `(res-why (e E))` becomes `(res-why)`. Measured
    2026-09-29: both files fail with the same `non-data type` line. G1 and G3
    redden.
  - **M3 one-instantiation.** The `; ---- io:` block is cut from a scratch copy
    of the sample. The copy still compiles and exits 0, so G1 stays green and
    **G2 alone** reddens. This is the mutant that proves G2 reads something, and
    the gate asserts the copy's exit code so a copy that failed to compile does
    not count as a pass.
  - **M4 name-collision.** `res-why` becomes `r-err` in a scratch module, the
    name `RR` (`lib/surface/sexp.chiral:19-21`) and `RunR`
    (`lib/lowering/tal/eval.chiral:30`) already own. G5 reddens.
  - **M5 closure-entry.** G4's positive half, reported as its own line so a
    reader sees the scan find the module when it is imported.
- **Expected:** `result: 10 passed, 0 failed` or the count the implement run
  pins, verdict `G1:ok G2:ok G3:ok G4:ok G5:ok`, every mutant on its pinned
  line. `shape-census.sh` reads 14 passed with its re-pinned `WANT_LIVE`.
  The compiler blob `cmp`s equal before and after.
- **Done when:** `tools/test/run-tests.sh` shows Phase 35 green with every
  mutant on its pinned line, the blob before and after compare equal under the
  non-empty guard, and the suite's only red line is `registration.sh`'s
  pre-existing `UNWITNESSED shape-census.sh`, or none if `E201` has been
  registered at 34 first.

## 5. Residue and links

- **Deliberately unbuilt:** the combinators, `errors-as-values/EV2`. The error
  slot's witness question, `errors-as-values/EV11`. `MfR`'s adoption,
  `errors-as-values/EV10`, and `PR`'s, `errors-as-values/EV11`. `NewPufR` at
  `prog/scriba/puffer.chiral:41`, which no roster row reaches: owed to the arc
  amendment the design's residue names, and the deferral rule forbids a row
  here.
- **Carried for the arc amendment, found by this run.** `E201`'s arm-name rule
  does not see this type. `err-side?` and `ok-side?`
  (`prog/shape-census.prog:114-120`) admit neither `res-val` nor `res-why`, so
  the census reads `Result` as an ordinary data type. When `EV10` or `EV11`
  moves a boundary onto `Result`, its `-err` arm leaves `SC-result-sum`,
  `SC-err-arm-bare-str` and `SC-rebuild-unchanged`, and requirement 5's count
  falls by the rename whether or not the boundary's error stopped being a
  `Str`. That is a trigger for `revisit` on `E201`'s register
  (`docs/definitions/shape-census.md`) before the first adoption row, and it
  bears on the open `EV3` row at `records/author-calls.md:52`. It does not
  reach this element's shape.
- **Carried, unchanged:** `EV3` (`records/author-calls.md:52`, `unreviewed`)
  sizes the adoption rows and does not reach this one. The design carries no
  `NEEDS-AUTHOR`.
- **Follow-on:** `errors-as-values/EV2` designs next on the same file.
  `E201`'s registration at 34 is independent of this element and either order
  works; §4's done-when states both.
- **Related:** [[arcs/errors-as-values-arc]] · [[arcs/parts/errors-as-values-EV1]] ·
  [[goals/readable-surface]] · [[banks/effect-and-alarm]] ·
  [[records/findings]] `FD-48` · [[working-discipline]] · `E201` · `E181` ·
  `E154` · `E157` · `E196`
