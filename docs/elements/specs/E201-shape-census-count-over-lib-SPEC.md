---
element: E201
slug: shape-census-count-over-lib
title: "**The shape census: a count over `lib/` and `prog/` that a document can cite by name**"
design: arcs/parts/errors-as-values-EV12.md
status: audited
updated: 2026-09-28
---

# E201 SPEC: **The shape census: a count over `lib/` and `prog/` that a document can cite by name**

> The build half, produced by the `design-to-spec` run. The design at
> `docs/arcs/parts/errors-as-values-EV12.md` made the design decisions and an audit gated
> them before this element minted. An implementation run follows THIS file.

## 1. Deliverable

- **After this runs:** the tracked source list piped through
  `prog/shape-census.prog` prints one `pred SC-<id> n=<all> closure=<in>` line
  per reading row of the register, and suite phase 34 goes red when the register and the
  instrument disagree, when a pinned reading moves, when a fixture reading
  departs from its hand count, when `SC-err-arm-bare-str` exceeds its named
  allowed value, when a document cites an `SC-` id the register lacks, or when a
  file the reader refuses goes unreported.
- **Chosen shape:** taken at `docs/arcs/parts/errors-as-values-EV12.md` §5:
  Shape **B** for placement (a chirality instrument that asserts nothing, a bash
  verdict at phase 34), **R1** for the reader (`read-all-forms`), **P3 over P1**
  for the citation (a tracked document writes ``30 (`SC-err-arm-bare-str`,
  2026-09-23)`` and the gate pins each reading on its own). One element, three
  new files, one edited line in `tools/test/run-tests.sh`.
- **Names and rules this SPEC fixes**, which the design left to the build:
  - **The input** is the tracked source list,
    `git ls-files lib prog | grep -E '\.(chiral|port|prog)$'`, 311 files on
    2026-09-28. Tracked files only, so an untracked file the author is working
    on (`prog/demo/passman-min` today) cannot move a pinned reading. No gate
    under `tools/` or `bin/` calls `git ls-files` in code today, so this gate is
    the first; `tools/test/map-integrity.sh:11` uses it only in a comment's
    measurement. `.manifest` files are excluded: they are import targets
    (`bin/chirality-resolve.sh:65`) that declare no `data`, `def` or `case`.
  - **The input line form** is `<path>` or `<path><TAB>closure`. The gate marks
    closure membership, because resolution lives in the resolver and the
    instrument cannot enumerate (§2).
  - **The output lines:** `pred SC-<id> n=<all> closure=<in>` per reading row,
    fourteen, the `in-closure` filter row printing no `pred` line of its own;
    `inst SC-<id> <path> <name>` per instance; `skip <path> <reason>` per file
    the reader refused or could not open; one closing
    `census files=<n> read=<n> skipped=<n> forms=<n>`.
  - **The arm-name rule** behind `SC-result-sum` is the wide predicate
    `docs/arcs/parts/errors-as-values-EV1.md:75` states: an ok-side head ends
    `-ok` or is `ok!`, or ends `-r` in a sum that also carries an arm ending
    `-err`; an err-side head ends `-err`, `-bad` or `-fail`, or is `bad!`. The
    ground is `:83-84`, *"Whichever predicate the arc meant, those nine are
    boundary sums"*, over `TimeR` (`lib/ports/clock.port:21-23`) and `ChkR`
    (`lib/module/loader.chiral:61`). The EV1 scan read this rule at 79 sums,
    49 with a `Str` error slot and 33 bare; the implement run reports its own
    readings beside those and pins its own.
  - **`SC-ctor-head-sites` is a register row of its own**, making fifteen rows:
    fourteen readings and the `in-closure` filter. §2 gives the reason.
- **Non-goals.** The threshold `SC-err-arm-bare-str` ratchets down to, which is
  `EV3`'s (§4, §5). Amending the arc's bare figures into dated readings, which
  the design's residue 1 names. Extern names as a counted namespace. Directory
  enumeration inside the instrument, which waits on `E148`. A depth guard in the
  reader. A check that a register row's words match its arm, which the design's
  §4c names as residue.

## 2. What the code forces

Every line below was opened in the working tree at `fa4461a` on 2026-09-28.

| target | the design assumed | the file admits | verdict |
|---|---|---|---|
| `lib/surface/sexp.chiral:286-287`, `:276-284` | `read-all-forms` hands each file's top-level forms as `(List FormPos)` | it does. `FormPos` is `(fp (offset I64) (form Sexp))` at `:35-36`, `Sexp` has four arms, `s-list`, `s-sym`, `s-i64`, `s-str` at `:12-16`, and failure is `af-err (msg Str) (pos I64)` at `:39-41`. **Measured:** a scratch root calling `read-all-forms` over all 311 tracked files returned `af-ok` for every one, 7,784 top-level forms, in 0.23 s, at an 8 MB stack and under `ulimit -s unlimited` alike | agrees |
| `lib/surface/sexp.chiral:44` | a file past `MAX-DEPTH` yields an error the census reports (design §4b, gate row R6) | **`MAX-DEPTH` is defined and read nowhere.** `grep -rn MAX-DEPTH lib prog` returns `:44` alone, and `read-form*` at `:216-234` carries `depth` into its messages without comparing it to anything. A form nested past the stack is a crashed process, with no `af-err` behind it. The `af-err` half of R6 is live: a scratch file holding `(a (b` returned `unclosed ( at 1:5 depth=2`. **Audit re-measure, 2026-09-28:** a file of 5,000 nested `(` read `af-ok` at an 8 MB stack, so a file past `MAX-DEPTH` is read and counted rather than refused; 300,000 nested `(` segfaulted at 8 MB (exit 139) and read `af-ok` under `ulimit -s unlimited`, the stack the gate runs at | **constrains**: R6 grades `af-err` and an unopenable path; a crash is caught by the missing `census` line, which the gate treats as every row failing |
| `prog/paren-audit.prog:34`, `:36`, `:208-232`, `:240-244` | the instrument reads a path list on stdin the way the tree's scanners do | the idiom is there whole: `(import "lowering/compile-all")` for `read-fd-all`, `(extern openat (=> Bytes I64))`, a NUL-terminated open per path with a named row on a negative fd, and `compile-main` splitting stdin on newlines | agrees; `do-file`'s shape is copied, `skip` replacing `UNREADABLE` |
| `bin/chirality-resolve.sh:248-257`, `:299-305` | the `in-closure` filter is a property of the file | the resolver owns it. Each module in a blob is closed by `(end-module "<key>")`, and a root outside every search root gets none. `chirality_blob_file "lib:prog" prog/compiler.prog` closes **61** modules on 2026-09-28, 61 distinct keys, all under `lib/` | **constrains**: the gate derives membership from those markers and tags input lines; the instrument re-implements no resolution |
| `bin/chirality-resolve.sh:293-305` | a mutated copy of the instrument can be built outside `prog/` | it can: *"Not a module of any root (a .prog entry, a fixture in a mktemp dir): resolve what it imports and append it."* | agrees; every instrument mutant builds from `$TMP` |
| `prog/optimizer-census.prog:12-14`, `:18`, `:24-28` | the precedent for a census root outside the closure that asserts nothing | `:12-14` is the leaf clause, `:18` *"IT EXISTS BECAUSE THE FIGURE IT PRINTS WAS NOT REPRODUCIBLE"*, `:24-28` *"IT ASSERTS NOTHING AND ALWAYS EXITS 0. Every comparison lives in bash"* with the reason | agrees |
| `tools/test/opt-census.sh:89-91`, `:92`, `:95-97`, `:166-172`, `:188`, `:191` | the mutant discipline to copy, cited by the design at `:88` and `:94` | the lines moved by one: GA-19 (no mutant removes an arm) at `:89-91`, GA-18 (`cmp -s` before a build) at `:92`, GA-21/GA-22 (pin the whole line) at `:95-97`, `sub` at `:166-172`, both `ulimit -s unlimited` lines at `:188` and `:191` | agrees, cited at the live lines |
| `tools/test/opt-census.sh:5-11` | the new gate must not copy this header (`PRB-93`, `records/lenses/problems.md:1308`) | the header still states the phase-number call as standing | agrees; the new header carries no `not-a-phase:` line |
| `tools/test/run-tests.sh:370-378`, `:347-353` | 33 is the last phase and 34 the first free | `run_phase 33` at `:378` is the last dispatch line; no line dispatches 34. The 2026-09-06 ruling at `:347-353` is the rule a new number follows | agrees |
| `tools/test/run-tests.sh:125-143`, `:134` | a phase reports into the suite's count | `run_phase` counts a phase through the last `[0-9]+ passed, [0-9]+ failed` its log prints, and a script exiting non-zero fails the run | **constrains**: the gate's last line is `shape-census: <p> passed, <f> failed` |
| `tools/test/registration.sh:55`, `:87-89`, `:118-121`, `:129-131`, `:281-291` | phase 34 registers cleanly | G6 flags only 21-23 (`:118-121`), so 34 clears M7 *take-the-reserved-band* (`:281-291`). `dispatched` reads the last field of a dispatch line as the script (`:87-89`). G2 needs every `tools/test/*.sh` dispatched or declared out, and G3 fails one that is both (`:129-131`) | agrees; the dispatch line ends in `shape-census.sh` and the script carries no `not-a-phase:` |
| `tools/test/run-tests.sh:175` | the instrument compiles in Phase 7 with no registration | `grep -rl '^(def compile-main' lib prog` picks it up | agrees; the fixtures live under `tools/test/samples/`, outside that sweep |
| `docs/arcs/parts/errors-as-values-EV12.md` §5 predicate table, and `docs/elements/catalog.md:513` | fourteen register rows, with `SC-ctor-head-sites` reported beside `SC-ctor-head` | `git grep` over `docs/` and `records/` finds `SC-ctor-head-sites` cited once, in the design itself. Gate row R5 fails on a cited id with no register row, so it would be red on its first run. The catalog row also carries the literal `SC-<id>` | **constrains**: `SC-ctor-head-sites` gets its own row and its own `pred` line; R5's id grammar is `SC-[a-z][a-z0-9-]*`, which skips `SC-<id>` |
| `docs/arcs/errors-as-values-arc.md:75`, `records/author-calls.md:52` | `EV3` settles the number `SC-err-arm-bare-str` may read, 29 or 0 | the **29** is 29 of the **47** arms carrying a `Str` anywhere in the error slot, outside the closure. The gate predicate is the **30** bare-`Str` subset of those 47. The call's numbers are stated under a different predicate from the one R4 grades | **constrains**: R4 carries one named allowed value and cites the call; which predicate and which column the ruling binds is carried to the author (§5) |
| `lib/lowering/tal/ir.chiral:9-10` | constructor heads are tags and are never summed with names | *"Constructor names arrive as tag numbers (declaration order); only function names survive as strings"* | agrees |

- **Constraints carried into §3:** R6 is graded on `af-err` and on an
  unopenable path, with no depth arm; closure membership is computed in bash and
  handed in on the input line; `SC-ctor-head-sites` is a fifteenth register row;
  the gate's last line is the suite's tally form; mutants build from `$TMP`.
- **Refusals:** one. The design's gate row R6 (design §6) grades a file that
  *"exceeds `MAX-DEPTH`"* as a named skip, and §4b says such a file *"yields
  `a-err`"*. `lib/surface/sexp.chiral:44` and `:216-234` contradict both, so this
  SPEC grades R6 on `af-err` and an unopenable path only and drops the depth
  half. The R1 call does not rest on it, since every tracked file parses, so the
  reader call stands and the refusal is recorded here and in §5 as a finding
  against the design's text.

## 3. Change plan (ordered, commit-sized)

### Step 1: the register

- **Target:** `docs/definitions/shape-census.md`, new.
- **Change:** frontmatter in the `docs/definitions/` form (`node`, `layer`,
  `related`, `status`, `updated`). One table row per id, fifteen rows, each with
  the id, the rule in words, what it excludes, and the instrument arm that
  implements it:
  - `SC-data-decl`: a top-level form whose head is `data`.
  - `SC-result-sum`: a `data` with exactly one ok-side arm and at least one
    err-side arm under §1's arm-name rule. `-2arm` holds two arms exactly,
    `-nplus` three or more.
  - `SC-err-arm-bare-str`, `SC-err-arm-str-plus`, `SC-err-arm-declared`: over
    `SC-result-sum-2arm`, the err-side arm's fields, a field's type being the
    last element of its field form so `(1 c Clock)` reads as `Clock`. Exactly
    one field typed `Str`; a `Str` field beside at least one other; exactly one
    field typed by a name in the `SC-data-name` set.
  - `SC-rebuild-unchanged`: a `case` arm whose pattern is `(H b1 … bn)`, `H`
    err-side, `n ≥ 1`, every `bi` a symbol, and whose body is exactly
    `(K b1 … bn)` with `K` err-side. `inst` lines carry `same` when `K = H` and
    `cross` otherwise, the split the arc states as 137 / 65.
  - `SC-passthrough-case`: a `case` with at least one err-side pattern arm in
    which every arm with a head outside the ok side is an `SC-rebuild-unchanged` arm.
  - `SC-hand-traverse`: a top-level `(def f …)` whose body holds a `case` arm
    with pattern `(cons h t)` whose body holds a `case` carrying an err-side
    pattern arm that does not call `f` and an arm that does.
  - `SC-def-name`, `SC-data-name`, `SC-ctor-head`: distinct names in each of
    three namespaces. `SC-ctor-head-sites`: data arms counted with multiplicity.
  - `in-closure`: the filter, reported as `closure=`.
  Below the table: the namespace rule, naming all four (extern names are the
  fourth and are uncounted) with `lib/lowering/tal/ir.chiral:9-10` and
  `docs/arcs/parts/lowering-and-emit-LE18.md:127` as its authority; the citation
  form ``<n> (`SC-<id>`, <date>)``; the input scope from §1.
- **Size:** S, 100 to 160 lines. Written first because each row is what an arm
  implements.

### Step 2: the instrument

- **Target:** `prog/shape-census.prog`, new.
- **Change:** a header in `prog/optimizer-census.prog:1-46`'s form stating why
  it exists, that it asserts nothing and always exits 0, the input and output
  forms, and that it is a leaf outside the compiler closure. Imports
  `prelude/prelude`, `prelude/list`, `prelude/string`, `ports/ports`,
  `lowering/compile-all` and `surface/sexp`, all under `lib/`, so a copy in
  `$TMP` resolves. Body:
  - `do-file` in `prog/paren-audit.prog:208-232`'s shape, splitting the input
    line on TAB for the closure tag; `af-err` and a negative fd print `skip`
    and bump `skipped`.
  - one classifier per register row over `Sexp`, each a named top-level `def`
    so a mutant is a one-line substitution: the arm-name tests `ok-side?` and
    `err-side?`; `field-type`; `rebuild-arm?` comparing binder lists in order;
    a namespace collector per name predicate.
  - a textual `(data ` counter over the file's raw bytes, printed as
    `text data n=<n>` and never as a `pred` line. It exists so FD-48 §11's
    comment-and-string gap stays visible beside `SC-data-decl`, and so M1 is a
    substitution of one call.
  - accumulation in one record threaded through the file loop, then the `pred`
    lines in register order and the closing `census` line.
- **Size:** M to L, 400 to 550 lines (design §6).

> A step touching `lib/` or `prog/` is compiler source and owes the build rule in
> [[working-discipline]]. This step adds a `prog/` leaf outside
> `prog/compiler.prog`'s closure, so the compiler's own sources do not change and
> no generation is owed. The run proves that rather than assuming it:
> `chirality_blob_file "lib:prog" prog/compiler.prog` before and after the step,
> each checked non-empty, then `cmp`. The instrument itself is built new by
> `bin/chirality-bin` under `ulimit -s unlimited` and never replaces anything.

### Step 3: the fixtures

- **Target:** `tools/test/samples/shape-census-fixture.chiral` and
  `tools/test/samples/shape-census-unreadable.chiral`, new. Neither defines
  `compile-main`, so neither is a root, and nothing globs `samples/`.
- **Change:** the first holds every declaration classified by hand in a comment
  beside it, with at least one trap per predicate: a `(data ` inside a comment
  and one inside a string literal; a `(def ` inside a string literal; two data
  types sharing a constructor head; a three-arm result sum; an err arm carrying
  `Str` beside `(pos I64)`; a `-r`/`-err` sum and an `ok!`/`bad!` sum; an err arm
  ending `-invalid`, which the live rule declines and M2 admits; a `case` arm
  rebuilding a different err constructor from the same binders (counted,
  `cross`); a `case` arm rebuilding with binders reordered (declined), sitting in
  a `case` that also carries a non-rebuild err arm, so M4 moves
  `SC-rebuild-unchanged` and leaves `SC-passthrough-case`; one passthrough
  `case`; one hand traverse. The second holds `(a (b` and nothing else.
- **Size:** S, 60 to 100 lines.

### Step 4: the gate

- **Target:** `tools/test/shape-census.sh`, new.
- **Change:** the header states what the gate is, which rows and mutants it
  holds, and why the instrument and the verdict are two files, citing
  `prog/optimizer-census.prog:24-28`. No `not-a-phase:` line. The body follows
  `tools/test/opt-census.sh`: `scratch`, `sub` with the `cmp -s` guard, a build
  and run under `ulimit -s unlimited`, one `measure` returning the whole verdict
  line, rows read off that line, mutants run only when the base line is all ok.
  - **Preconditions**, exit 2 and no tally: the register, the instrument and
    both fixtures exist; the compiler blob assembles non-empty; its
    `(end-module` list does not hold `shape-census`.
  - **The input:** the `git ls-files` list of §1, each path tagged `closure`
    when its key is among the compiler blob's `(end-module "<key>")` markers,
    read line-anchored: an unanchored grep also finds `<n>` and `<name>` in the
    blob's comments, 63 distinct against the 61 real keys.
  - **The pins:** `WANT_LIVE`, the fourteen `n=`/`closure=` pairs over the live
    input as one string; `WANT_FIX`, the fourteen hand counts over the fixture.
    Each is set by hand from the implement run's first reading and the hand
    classification, and neither is computed by the gate.
  - **The allowed value**, one named variable with the call beside it:

    ```
    # The ceiling R4 holds SC-err-arm-bare-str to. records/author-calls.md:52
    # (EV3) is `unreviewed`: the narrow reading lets the check read 29 and the
    # wide reading requires 0, both stated over a different predicate. Until it
    # is ruled this is the reading pinned on the implement date and ratchets
    # down only. The ruling replaces this value and nothing else.
    SC_BARE_STR_ALLOWED=<the implement run's reading>
    ```
  - the last line is `shape-census: <p> passed, <f> failed (<s>s)`.
- **Size:** M, 250 to 350 lines.

### Step 5: registration

- **Target:** `tools/test/run-tests.sh`, after `:378`.
- **Change:** a comment block on the pattern of `:370-377`, citing the
  2026-09-06 ruling and 33 as the last registered number, then
  `run_phase 34 "the shape census (E201)"   shape-census.sh`.
- **Size:** S, one dispatch line and a comment block of about six lines.

Steps 1 to 4 land in one commit, since each is inert without the others, and
step 5 in a second, so a bisect can tell a red gate from a red registration.

## 4. Conformance gate

- **Baseline:** 2026-09-28, `fa4461a`. Phase 34 does not exist; nothing counts a
  declaration's shape. The suite reads 441 assertions, 95 compile-only roots,
  `gate PASSED` (fact 4 of the dispatch, re-verified in the run's report).
- **Expected:** phase 34 prints `shape-census: 14 passed, 0 failed`: six rows
  and eight mutants. The suite's assertion count rises by 14; Phase 7 compiles
  96 roots; `registration.sh` stays green with one more dispatch line.
- **Named phase:** `run_phase 34 "the shape census (E201)" shape-census.sh`.
- **Rows**, each read off one verdict line
  `R1 R2 R3 R4 R5 R6 live=<digest> fix=<digest>`:
  1. **R1** the `pred` ids equal the register's ids, as sets, both directions.
  2. **R2** the live readings equal `WANT_LIVE`, whole.
  3. **R3** the fixture readings equal `WANT_FIX`, whole. The row that separates
     a correct predicate from a self-consistent one.
  4. **R4** `SC-err-arm-bare-str n` does not exceed `SC_BARE_STR_ALLOWED`.
  5. **R5** every `SC-[a-z][a-z0-9-]*` token under `docs/` and `records/`
     names a register row.
  6. **R6** a run over the live list plus the unreadable fixture plus one
     nonexistent path prints two `skip` lines naming them, reads
     `skipped=2`, and leaves every live reading as it was.
  - **A run with no `census` line** reads every row `absent`, the shape of
    `tools/test/opt-census.sh:220`. The instrument prints its `pred` lines after
    the last file, so a crash on any file leaves no reading and reddens all six
    rows. That is how a reader crash surfaces: the suite goes red, without the
    path that caused it.
- **Mutants**, each reverted, none removing an arm, each pinning the whole line:
  - **M1 comment-blind**: `SC-data-decl`'s arm calls the textual counter.
    Moves `SC-data-decl` alone, by the comment-and-string occurrences FD-48 §11
    measured at 12. Reddens R2 and R3.
  - **M2 arm-rule-widened**: `err-side?` also admits heads ending `-none` or
    `-invalid` and the bare head `bad`. Moves `SC-result-sum` and the readings
    under it. `SC-rebuild-unchanged`, `SC-passthrough-case` and
    `SC-hand-traverse` also call `err-side?` (§3 step 1), so they can move too;
    the whole-line pin records what the implement run reads. The fixture's
    `-invalid` sum guarantees R3 moves whatever the live tree holds.
  - **M3 namespaces-summed**: the `SC-ctor-head` collector also takes `def`
    names. Moves `SC-ctor-head` and `SC-ctor-head-sites`; caught by R2 and R3,
    with R1 green.
  - **M4 rebuild-loosened**: `rebuild-arm?` compares binders as sets. Moves
    `SC-rebuild-unchanged` and leaves `SC-passthrough-case`, on the fixture's
    reordered arm.
  - **M5 register-row-dropped**: one row cut from a scratch copy of the
    register. Reddens R1 and R5, no other row.
  - **M6 skip-dropped**: the `af-err` arm returns the running total and prints
    nothing. Reddens R6 alone.
  - **M7 bare-str-grown**: the fixture joins the live input list. Its bare-`Str`
    two-arm sum raises `SC-err-arm-bare-str` above the allowed value. Reddens
    R2 and R4.
  - **M8 closure-untagged**: the gate hands the list with no `closure` tags.
    Every `closure=` reads 0. Reddens R2 alone, which is what grades the filter.
- **Done when:** `bash tools/test/run-tests.sh` prints `Phase 34` with
  `shape-census: 14 passed, 0 failed`, the suite ends `gate PASSED`, and the
  compiler blob is byte-identical before and after the change.

## 5. Residue and links

- **Deliberately unbuilt:**
  - **The threshold.** `records/author-calls.md:52`, row `EV3`, `unreviewed`.
    R4's allowed value is the implement-date reading and moves only on that
    ruling. Two things the ruling has to say are carried to the author: which
    predicate it binds, since its 29 and 47 are stated over a `Str` anywhere in
    the error slot and R4 grades the bare subset; and whether it binds the total
    or the outside-closure column.
  - **The arm-name rule** is EV1's wide predicate on the ground §1 cites. If the
    author meant the strict one, the reading moves and so does every number the
    `EV3` ruling states.
  - **A depth guard in the reader.** `MAX-DEPTH` at
    `lib/surface/sexp.chiral:44` is read by nothing. It is `E1`'s, and the
    design's §4b sentence that relies on it is a candidate `revisit` against
    `docs/arcs/parts/errors-as-values-EV12.md`, with this run as the trigger.
    The call stands without it.
  - **The arc's figures as dated readings**, design residue 1: the arc file,
    `records/author-calls.md:52` and `records/findings.md` `FD-48` §11, the
    first and last live under the author today.
  - **`PRB-93`**, the stale header at `tools/test/opt-census.sh:5-11`, owner
    absent. This element does not copy it and does not claim it.
  - **Register words against instrument arms**, design §4c: no row compares
    them. The register names each arm so the drift stays findable by hand.
  - **A bare number citing no id**, design §5 question 4: a `doc-audit`
    obligation.
  - **`GAP-18`**: served in part, and the gap stays open.
- **Follow-on:** `errors-as-values/EV3`, whose ruling sets
  `SC_BARE_STR_ALLOWED`; `errors-as-values/EV5` through `EV11`, whose adoption
  lowers the readings R2 pins.
- **Related:** [[arcs/errors-as-values-arc]] · [[arcs/zero-python-arc]] ·
  [[goals/self-tooling]] · [[goals/readable-surface]] ·
  [[definitions/working-discipline]] · [[banks/verification]] · `E1` · `E173`

## SPEC audit (2026-09-28): the implement-ready gate

**Verdict: PASS.** Charter run on the bundle `pack.py E201 --audit spec` at
`92a51b2`, each citation opened in the working tree. Three author flags stay
open; none blocks the build, because each lands on one named value or one pair
of named `def`s that a ruling replaces, and `records/author-calls.md:52` itself
holds that no number in it binds until this element's check is committed.

### Re-measured

- 311 tracked `.chiral`/`.port`/`.prog` files under `lib/` and `prog/`, plus two
  `.manifest`. A probe root calling `read-all-forms` over the 311 read 7,784
  top-level forms, every file `af-ok`, at 8 MB and unlimited stacks alike.
- `(a (b` reads `unclosed ( at 1:5 depth=2`. Nesting past `MAX-DEPTH` is read,
  and a crash needs a nesting the gate's `ulimit -s unlimited` does not reach
  (§2, the `sexp.chiral:44` row).
- The compiler blob carries 61 line-anchored `(end-module` markers, 61 distinct.
- `run_phase 33` at `tools/test/run-tests.sh:378` is the last dispatch line;
  `tools/test/registration.sh:118-121` flags 21-23 only.
- `grep -rn MAX-DEPTH lib prog` returns `lib/surface/sexp.chiral:44` alone.
- `git grep` finds `SC-` tokens in three files, every one a register id, so R5
  is green on its first run.

### FIXes applied above

1. §1 and §3 step 4 counted fifteen `pred` lines and fifteen pins. The register
   holds fourteen readings and one filter row that prints no `pred` line, so
   `WANT_LIVE` and `WANT_FIX` carry fourteen each.
2. §1 cited `tools/test/map-integrity.sh:11` as a gate precedent for
   `git ls-files`. The line is a comment's measurement, and no shell under
   `tools/` or `bin/` calls it in code. Reworded to say this gate is the first.
3. §2 cited `tools/test/registration.sh:82` for G3. `:82` defines the
   `not-a-phase:` marker; G3 is `:129-131`.
4. §2 cited `sub` at `tools/test/opt-census.sh:166-171`; it closes at `:172`.
5. §2's refusal line read *none* while the SPEC drops the depth half of the
   design's gate row R6. Restated as one refusal, with the design's text named.
6. §2's `sexp.chiral:44` row gains the audit's depth measurements.
7. §3 step 4 now reads the closure markers line-anchored: an unanchored grep
   also finds `<n>` and `<name>` in blob comments.
8. §4 states the absent-census rule the §2 constraint relies on, which the
   plan implied through `opt-census.sh` and never said.
9. §4 M2 claimed to move nothing outside `SC-result-sum`. Three other rows call
   `err-side?` by §3's own definitions, so the claim is withdrawn and the
   whole-line pin decides it.

### On the unenforced `MAX-DEPTH`

The gate is sound and it surfaces a crash: a crashed
instrument prints no `pred` or `census` line, every row reads `absent`, the
script exits non-zero and `run-tests.sh:134` counts the phase failed. The
cost is attribution, since the red run does not name the file. A file nested
past 200 and short of the stack is read and counted, so the design's premise
fails there and no crash occurs; `E1` owns the guard and §5 routes
the design's sentence to `revisit`.

### Observations

- R4 is redundant with R2 while `SC_BARE_STR_ALLOWED` equals the pinned
  reading: growth reddens both, and M7 reddens both. R4 earns its row once a
  ruling sets the value below the reading, or when R2 is re-pinned.
- The design cites `tools/test/opt-census.sh:88` and `:94`; the live lines are
  `:89-91` and `:95-97`. The design is outside this run's write surface.

### Author flags, carried verbatim, none blocking

All three hang off `records/author-calls.md:52`, row `EV3`, `unreviewed`.

1. **Which predicate the `EV3` ruling binds.** Its figures, 47 with 29 outside
   the closure, count a `Str` anywhere in the error slot. R4 grades
   `SC-err-arm-bare-str`, the bare-`Str` subset that reads 30. Does the ruling
   bind the 47-predicate or the bare 30-predicate? Non-blocking: the register
   carries both `SC-err-arm-bare-str` and `SC-err-arm-str-plus`, so either
   answer is a change to which reading R4 compares.
2. **Whether the allowed value applies to the total or to the outside-closure
   count.** Non-blocking: every `pred` line carries `n=` and `closure=`, so the
   outside count is derivable from what the instrument prints.
3. **Whether `EV1`'s wide arm-name rule is the intended one**: `-ok`, `-r` or
   `ok!` against `-err`, `-bad`, `-fail` or `bad!`, grounded at
   `docs/arcs/parts/errors-as-values-EV1.md:83-84`. Non-blocking: the rule lives
   in the two named `def`s `ok-side?` and `err-side?`, M2 grades it, and a
   strict ruling is a change to those two plus a re-pin.

**Next stage:** implement E201 from this SPEC, §3 steps 1 to 4 in one commit and
step 5 in a second.
