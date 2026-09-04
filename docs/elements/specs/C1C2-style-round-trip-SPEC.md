---
element: C1C2
slug: style-round-trip
title: "Relate the two style representations, and make the round trip close"
kind: law
example: examples/C1C2-style-round-trip.md
status: draft
updated: 2026-09-04
---

# C1C2 SPEC. Relate the two style representations, and make the round trip close

> Implementation contract produced by the `example-to-spec` run. Bridges the
> reviewed worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

Covers arc rows `display-calculus/C1` and `display-calculus/C2` together, both
`unminted`, arc-local ids per [[decisions/decision-work-ids]]. `tools/pack/pack.py`
scaffolds none of this: its id regex accepts `E`, `U`, `S` and `N` only and refused
`C1C2` again in this run with *"element id must look like E13 / U13 / S19 / N1"*.
The bundle was assembled by hand, as the example's was.

**Every figure below was measured in this run**, at `970ca2a`, on an unmodified
working tree. Where a figure differs from the example's, the difference is called
out and the measurement here governs.

## 1. Deliverable

- **After this runs:** `face-sgr`'s SGR codes exist as a value (`face-params`),
  `parse-sgr` reaches the `sgr-italic` arm `apply-one` has carried since E111, a
  new `lib/protocol/style.chiral` states the projection from `Face` to `Attrs`
  and the equation `fold-sgr (face->attrs outer) (face-params inner) ==
  face->attrs (face-join outer inner)`, and a compiled root sweeps 63,536 probes
  and exits 42.
- **Non-goals.** Retyping `Face`'s three `I64` fields (decision 1). Retiring
  `Face` (decision 2). A byte-level leg through `vt-parser` (decision 3).
  Retiring `SGR_AWK` (decision 4). Moving `bool-eq` to the prelude (decision 6).
  `display-calculus/C4` and `C5`, which lost their pre-run when C01 went
  `superseded` and stay `not started`.
- **This element ships a hand-run gate**, outside the suite total, and §5 prices
  it. Any claim that C1 and C2 are covered by `bin/chirality test` is false until
  a phase number lands.

## 2. Baseline

`records/conformance-map.md` carries no row for this tier, so the build-state
authority here is [[banks/render]], which now lists twenty-four shards across
thirteen homes. Nothing below is respecced.

### What is already built

| shard | symbol | measured this run |
|---|---|---|
| C, H | `Attrs` at `lib/protocol/grid.chiral:12`, over `Color` at `:6` | six named `Bool`s over a closed three-arm sum. E111, `built` (`docs/elements/ledger.md:177`) |
| H | `parse-sgr` at `lib/protocol/grid.chiral:201` | names **23** of 51 codes: `0 1 4 7 22 24 27`, `30` through `37`, `40` through `47`. Every other code returns `sgr-other` (`grid.chiral:35`) |
| H | `apply-one` at `lib/protocol/grid.chiral:215` | an arm per `Sgr` constructor, no `_`. `fold-sgr` at `:232` folds in order |
| E | `default-faces` at `lib/protocol/render.chiral:148` | eleven entries. `fg` in `{-1,1,2,3,4,7}`, every `bg` is `-1`, attribute masks `{0,1,2,8}` with exactly one entry at `8` |
| L | `face-sgr` at `lib/protocol/render.chiral:188` | emits bold `1`, underline `4`, italic `3`, reverse `7`, then `30+fg`, then `40+bg`. `sgr-code` at `:180` is one `str-cat` chain with no branch on its argument |
| G | `face-join` at `lib/protocol/render.chiral:366` | `bor` on attributes, a non-negative inner colour wins, a negative inherits. Its own comment calls itself a description of what the emitter already does. Sole caller `render.chiral:773` |
| X | `SGR_AWK` at `tools/test/face.sh:176` | a third SGR model, in awk, running as Phase 16 |

### The delta, measured

- **The round trip does not close.** Bit `4` of `attrs` emits `ESC[3m` and code
  `3` returns `sgr-other`, so 8 of the 16 attribute masks lose italic. `fg` 10
  through 17 emit `ESC[40m` through `ESC[47m` and decode as a background change.
  `fg` and `bg` of 8 or 9 emit `38 39 48 49` and all four vanish.
- **`Face` is the projection and `Attrs` survives.** `Attrs` carries `blink` and
  `strike` for which `Face` has no bit, and `Color` carries `color-rgb` and
  `color-indexed` past 7 for which `face-sgr` has no spelling. The projection is
  faithful on a sub-domain `Face`'s type states nowhere: `fg` and `bg` in
  `{-1} ∪ 0..7`, attribute mask in `0..15`.
- **Blast radius, re-measured.** 2 `face-sgr` call sites, both in
  `render.chiral` (`:396`, `:772`); one application of `face-join`, at the
  recursion on `render.chiral:772-773`; 8
  `lookup-face` call sites; 14 `Face` constructions, every one in
  `render.chiral`. The 26 `(r-face` applications tree-wide, 18 of them under
  `prog/scriba/`, move on none of this: `r-face` holds a `Str` face name
  (`render.chiral:15`) and never a `Face` value.
- **Reach.** `protocol/grid` has five importers, `vt-parser.chiral` and four
  roots under `prog/scriba/samples/`. All of them bottom out in Phase 7, which
  compiles and runs nothing (`tools/test/run-tests.sh:150`, loop at `:175-190`).
  Zero roots under `tools/test/samples/` import `protocol/grid` today, so this
  element's gate creates its own reach.

### The build rule does not fire

The blob built in this run from `prog/compiler.prog` over `lib:prog` is
**812,351 bytes over 17,335 lines**, and it spells `protocol/grid` **0** times,
`data Face` **0**, `data Attrs` **0**, `parse-sgr` **0**, `face-sgr` **0**,
`face-join` **0**, `bool-eq` **0** and `protocol/style` **0**. `protocol/render`
occurs 4 times, every one a comment carried in from `lib/prelude/doc.chiral`
(`:48`, `:85`, `:181`, `:182`).

**So every step of §4 ships under a plain `chirality run FILE`.** No
`build-new → test → promote`, no byte-compare, no fixpoint. Step 6 lands that
claim as a gate row on the `tools/test/render-doc.sh:555-566` precedent, so the
licence is checked rather than asserted. Decision 6 names the one change that
would flip this on.

### Two claims corrected before this SPEC cites them

Both were scope errors about `lib/protocol/render-doc.chiral`, and both are fixed
in this run.

| where | said | measured |
|---|---|---|
| `docs/banks/render.md` shard K | "written and unreached. Zero importers, measured" | zero importers under `lib/` and `prog/`; **two** under `tools/`, at `tools/test/samples/e158_render.prog:58` and a heredoc probe at `tools/test/render-doc.sh:423`. Phase 17 (`tools/test/run-tests.sh:268`) builds the first and **executes** it (`tools/test/render-doc.sh:110`) |
| [[arcs/display-calculus-arc]] row `A1` and its resume state | "`protocol/render-doc` has zero importers" | the same. The row's own grep was scoped to `lib/ prog/` and true; the resume state repeated it unscoped |

`render-doc.chiral:19-24` is where both inherited it. That file is under `lib/`
and was left alone. The bank's header tally moved with shard K, from twenty
running and two written-and-unreached to twenty-one and one.

What `A1` asks for survives the correction: a **shipping** producer for the `Doc`
to `Rendering` path, and there is none. That is why this element's gate ends in
an exit code from `face-params` and `fold-sgr` and never in screen bytes.

## 3. Decisions

The example's §6 carries seven. Each is dispositioned here. Two are the author's
to overrule and say so.

| # | question | disposition | rationale |
|---|---|---|---|
| 1 | a refinement on `Face`'s fields | **RESOLVED: no.** The domain ships as `in-sgr-domain`, a checked predicate | measured below. The refinement engine proves a bound for a literal or for a value already at the refined type, and for nothing else |
| 2 | which representation retires | **RESOLVED for the direction, RESIDUE for the work.** `Attrs` survives, `Face` is the projection | §2 measures both losses. Retiring `Face` is a separate change and this arc has no reserved element band, so it is filed `UNASSIGNED` under [[working-discipline]]'s deferral rule |
| 3 | a byte-level leg through `vt-parser` | **RESOLVED: no** | it drags a `Pool` crossing into a gate whose every function is `->`, and it closes less than it appears to. See below |
| 4 | whether `SGR_AWK` retires | **RESOLVED: not here.** It stays | it is E175's grader, and it disagrees with `apply-one` in three classes, so swapping it changes what Phase 16 asserts. Home: [[arcs/enforcement-arc]]'s tooling-surface requirement, and [[banks/render]] shard X |
| 5 | whether E111's ledger row reopens | **RESOLVED: no**, and the author may overrule | the blame chain is settled below. What is left is a false conformance claim on a `built` row, and this tree's settled route for that is a `records/gate-audit.md` row |
| 6 | whether `bool-eq` moves to the prelude | **RESOLVED: no** | `lib/prelude/prelude.chiral` is inside the blob. Moving it is the one change that would put the build rule on this element |
| 7 | whether `style.chiral` carries a `(module …)` coordinate | **RESOLVED: no** | settled twice already, on this same file's neighbour |
| S1 | the suite phase number | **NEEDS-AUTHOR, non-blocking.** Already recorded | [[records/author-calls]] carries the standing row and the display tier's instance on it. The script ships declared out |
| S2 | `sgr-code` on codes `3` and `40` through `47` | **RESOLVED: accepted as stated residue** | bounded by a measurement. See §5 |

### 1. The refinement, settled by measurement

The example logs this as the follow-on's first decision and flags the two
computed constructions as the risk. Four probes were compiled in this run against
`lib/`, and they settle it outright:

| probe | verdict |
|---|---|
| `(f 8)` into a field typed `(refine I64 (>= 0) (<= 15))` | **OK** |
| `(f 99)` into the same field | refused, `load: cannot prove refinement`. The check has teeth |
| `(f (+ 1 2))` | **refused**, `load: cannot prove refinement` |
| `(f (bor 8 4))` | **refused** |
| the `face-join` shape, `(f (case (<i -1 0) (true 3) (false -1)))` | **refused** |
| a function whose parameter is declared at the refined type, applied to a literal | **OK** |

A constant-foldable `+` does not survive, so `bor` and occurrence typing on a
`case` were never the boundary. `face-join` builds `fg` through a `case` and
`attrs` through `(bor oat iat)` at `render.chiral:372`, and `lookup-face`'s miss
arm builds a third at `:167`. Refining `Face`'s fields today makes `face-join`
fail to compile.

⚑ **The precedent is thinner than it reads.** `lib/runtime/proc.chiral:42-43`
declares two constructors with refined fields and `:28` declares a third. Every
occurrence of `exited`, `signaled` and `reap` in `lib/` and `prog/` is a `case`
pattern (`proc.chiral:144`, `:148`; `lib/evidence/harness.chiral:18`, `:19`;
`prog/samples/a5_proc_spawn.prog:16`, `:20`), and `prog/agent/agent.chiral:43-44`
redeclares the same sum with plain `I64` fields. **Nothing in the tree constructs
a refined constructor field.** The pattern ships as a declaration and a
destructuring.

So the predicate is the answer available today, and the follow-on that would
change it is a refinement-engine element rather than a display one.

### 3. The byte leg, and what it would actually buy

`lib/protocol/vt-parser.chiral` turns bytes into `act-sgr` parameter lists
(`:35`, `:224`) and applies them (`:253`), so the leg is writable. Three
measurements price it against nothing:

1. `sgr-code` (`render.chiral:180`) is `(str-cat (str-cat (str-cat ansi-esc "[") (i64->str n)) "m")`, one expression with **no branch on `n`**. Exercising it on one code exercises it on every code.
2. Phase 16 already drives it in a real byte stream. The E175 fixture's output was built and run in this audit: **841 bytes, 129 SGR sequences**, carrying codes `0 1 4 7 31 32 37` and no others. The `0` is `ansi-reset` (`render.chiral:329`), so `sgr-code` itself is exercised on six.
3. `vt-parser` produces a parameter list and hands it to `fold-sgr`, which is the same fold this element's gate already runs. The leg adds bytes in front of a comparison that is already made.

Against that it imports `protocol/grid`, which imports `ports/ports`, so it puts
a `Pool` crossing inside a pure gate. The one property the leg would buy is
ordering, and §5 measures that neither tier catches it either way.

### 5. The blame chain, and who owns a `parse-sgr` regression

`parse-sgr` and `fold-sgr` are reached by `prog/scriba/samples/t4_grid.prog` and
by `lib/protocol/vt-parser.chiral:253`, whose own two importers are sample roots.
All of them stop at Phase 7, which compiles. E111's stated conformance is
*"t4_codec/t4_grid native exit 42"* (`docs/elements/ledger.md:177`) and no phase
executes either root, so **E111 has no running gate to re-run.**

| if the round trip breaks after this edit | |
|---|---|
| which element owns it | **this one.** The two `cond` rows exist to satisfy this element's law and this element's gate is the only thing that reads them |
| what catches it | this element's own root, through `joins-agree`. Deleting the code-3 row is mutant 1 and it disagrees on **7,128** of 14,256 asserted probes, measured natively in this run |
| what does not | E111's row, because nothing runs it. Phase 7, because it compiles. Phase 16, because `parse-sgr` is on the decode side and Phase 16 grades emitted bytes |
| the cost | the catcher is hand-run. Until a `run_phase` line exists, a `parse-sgr` regression is caught by a person typing the script's name |

The bookkeeping residue is E111's conformance line asserting a run that does not
happen. Reopening a `built` row to carry an arm it already declares would trade
one false statement for another. The route this tree has already taken for a
false gate claim is a `records/gate-audit.md` row: GA-25 was opened four days
ago by this element's own pre-run for exactly that class. §6 files it there.
**The author may overrule and reopen E111 instead.**

### 6. `bool-eq`, and the one thing that would change the build rule

Three spellings exist: `bool-eq` (`render.chiral:202`), `booleq`
(`prog/scriba/samples/t4_codec.prog:15`) and `not` over a `case`. This element
retires the second and leaves the first where it is.

`lib/prelude/prelude.chiral` is inside the compiler's blob, verified twice in
this run: `not` is defined at `prelude.chiral:137`, and the blob built from
`prog/compiler.prog` carries `(def not (-> Bool Bool)` at its own line 137. A def
added there owes `build-new → test → promote` and the byte-compare with a
non-empty check. **That is the single change in reach of this element that would
put the build rule on it**, and it buys `grid.chiral` the ability to hold
equality beside `Attrs`, which is where it belongs. Real price, real payoff,
different element.

`tools/test/row.sh:729` censuses `render.chiral`'s names for the
duplicate-definition class and would catch a second `bool-eq`. It censuses no
name in `grid.chiral` and would census none in `style.chiral`.

### 7. The module coordinate

Measured this run: **0 of 11** files under `lib/protocol/` carry a `(module …)`
line, against **9 of 9** under `lib/prelude/` and 15 files tree-wide. The
question was settled twice already on `render.chiral` itself: E174's example and
E175's example each name adding one as *E161 adoption* and out of scope. E161 is
`built` (`docs/elements/ledger.md:303`), so adoption is a directory-wide change
against a mechanism that exists. A new file carrying the only coordinate in its
directory is the irregularity `docs/definitions/design-principles.md` names as
the worst class of defect, and it is why this decision needs no new element to
hold it.

### S1. The phase number

[[records/author-calls]] records four documents disagreeing about which suite
number a new gate takes, with 8 through 12 owed to unported old-tree phases and
21 through 23 contested. That row already carries the display tier's instance and
already names this element. No new row is opened.

The script ships with a `# not-a-phase: <reason>` header line and no number, on
the standing precedent. Verified on disk in this run: seven such declarations
exist, five on gate scripts (`crypto.sh:6`, `tal-check.sh:11`, `apply-word.sh:5`,
`mutant.sh:11`, `map-integrity.sh:7`) and two on the dispatch table and its
witness (`run-tests.sh:348`, `registration.sh:4`). `tools/test/registration.sh`
run in this audit reports **13 dispatch lines against 20 scripts, 7 of them
PEND**, and **9 passed, 0 failed** with G1 through G6 all `ok`. Adding an eighth
declared-out script keeps G2 green and moves no suite number.

## 4. Change plan

Seven steps. **Steps 1 through 5 were executed off-tree in this run** against a
copy of `lib/` and a copy of `prog/`, compiled with `bin/chirality-bin`, and run.
`git status --porcelain lib/ prog/` was empty afterward. The measured outcome of
each is recorded with it, so an implementation run has an expected value rather
than a prediction.

### Step 1. `parse-sgr` reaches the arm `apply-one` already has
- **Target:** `lib/protocol/grid.chiral`, `parse-sgr` at `:201`
- **Change:** two `cond` rows beside the bold and underline pairs.
  ```chirality
  ((=i code 3)  (sgr-italic true))
  ((=i code 23) (sgr-italic false))
  ```
  `sgr-italic` is declared at `grid.chiral:37` and folded at `:223`; nothing in
  the tree constructs one today, so this reaches a dead arm rather than adding a
  capability. `23` is ECMA-48's italic-off and is added for symmetry with the
  `22`/`24`/`27` rows already present.
- **Measured:** with these two rows the gate root exits **42**; without them it
  exits **1**. `t4_grid.prog` folds codes `1` and `31` only, so no existing
  fixture's result moves.
- **Size:** S

### Step 2. One definition of the byte rule, read twice
- **Target:** `lib/protocol/render.chiral`, `face-sgr` at `:188`
- **Change:** hoist the code list out. `face-sgr` becomes
  `(lam (f) (sgr-str (face-params f)))`; `face-params` returns `(List I64)`;
  `sgr-str` maps `sgr-code` over it. Signature unchanged, so the two call sites
  (`:396`, `:772`) do not move. Built back to front with `cons`, because the
  prelude has no `append`.
- ⚑ **Two corrections to the example's §5 snippet, both found by compiling it.**
  The snippet does not type-check as written.
  1. `(let ((l0 nil))` fails with `load: cannot infer type parameters of nil`. It must be `(let ((l0 (the (List I64) nil)))`, the idiom `lib/evidence/test-floor.chiral:779` already uses.
  2. The `case` pattern `((face name fg bg attrs))` binds `attrs` to the `I64` field and shadows the `Attrs` constructor of the same name. In `face->attrs` (step 3) that fails with `load: cannot apply a non-function`. **Every pattern over `Face` in the new code binds the field as `at`.** In `face-params` the rename is optional and is taken anyway, so one spelling covers both files.
- **Measured:** the E175 fixture's output is **byte-identical** across the split,
  841 bytes before and after, `cmp` clean.
- **Size:** M

### Step 3. `lib/protocol/style.chiral`, new
- **Target:** a new file, 54 lines as written in this run
- **Change:** `idx->color`, `face->attrs`, `color-eq`, `attrs-eq`,
  `in-sgr-domain`, `joins-agree`. Imports `prelude/prelude`, `protocol/render`
  and `protocol/grid`. Every def is `->`.
- **Why its own file, measured.** A probe root importing `protocol/render` alone
  blobs to 64,499 bytes; adding `protocol/grid` takes it to 103,915, a delta of
  **39,416**. Putting the `grid` import into `render.chiral` would charge all 18
  of its importers that delta for a type they do not use.
  `lib/protocol/render-doc.chiral` is the precedent for a bridge module joining
  two tiers and changing no blob.
- **Why not `grid.chiral`, which is where `Attrs` lives.** `attrs-eq` needs a
  `Bool` equality. `grid.chiral` imports `prelude/prelude`, `lowering/tal/bytes`
  and `ports/ports` (`:1-3`) and none of the three spells one. `bool-eq` is
  `render.chiral:202`, and `grid.chiral` importing `protocol/render` inverts the
  tier and charges `vt-parser.chiral` for it. Decision 6 is the clean version and
  its price.
- **`color-eq` and `attrs-eq` are hoisted from a fixture.**
  `prog/scriba/samples/t4_codec.prog:17-32` already defines both over these two
  types with its own `booleq` at `:15`. Writing a second copy while retiring a
  duplicate representation is incoherent, so the pair moves out of the fixture
  and into `lib/`. The hoisted `color-eq` takes `style.chiral`'s association of
  the three-way `and`; the fixture's grouping differs and the meaning does not.
- **Measured:** a root importing both `protocol/render` and `protocol/grid`
  compiles clean, and the two files have **zero** top-level name collisions (67
  names against 27). The module and the gate root below type-check `OK` together.
- **Size:** M

### Step 4. `t4_codec.prog` becomes a caller
- **Target:** `prog/scriba/samples/t4_codec.prog`
- **Change:** delete its `booleq` (`:15`), `color-eq` and `attrs-eq` (`:17-32`);
  add `(import "protocol/style")`. `cell-eq`, `rt` and `compile-main` remain.
- **Measured:** compiles clean and still exits **42**. Its blob grows from
  **67,441** to **107,562 bytes**, +40,121. The example predicted about 38,807
  from a probe-root delta; the measurement on the real edit is the larger figure
  and includes `style.chiral` itself. `t4_codec` is a Phase 7 compile-only root,
  so that charge is compile time on one fixture and reaches no shipping program.
- **Size:** S

### Step 5. `tools/test/samples/c1c2_round_trip.prog`, new
- **Target:** a new fixture root
- **Change:** `walk-bg` / `walk-fg` / `walk-attrs` / `walk-amb`, structural
  recursion on a decreasing counter so each is total. The colour axes run from
  17 down to -1 and the attribute axis from 15 down to 0; `in-sgr-domain` decides
  which visited probe is asserted. `walk-amb` asserts `in-sgr-domain` on every
  registry face before walking it. `compile-main` returns 42 on the whole product
  holding and 1 otherwise, the convention `t4_codec` and `t4_grid` already use.
- **Measured:** 63,536 visited, 14,256 asserted, exit 42 against a patched tree
  and exit 1 against today's. Blob 107,395 bytes.
- **Size:** M

### Step 6. `tools/test/style.sh`, new, and it declares itself out
- **Target:** a new gate script
- **Change:** a `# not-a-phase: <reason>` header line naming the standing
  author call, then the rows in §5. No `run_phase` line anywhere.
- **Also:** the build-rule row. On the
  `tools/test/render-doc.sh:555-566` precedent, assert that
  `prog/compiler.prog`'s blob does not contain `protocol/style`, so the "no
  fixpoint obligation" claim in §2 is checked on every run rather than believed.
  That precedent pairs the assertion with a mutant that puts the import in and
  requires the scan to see it; carry both halves or the row grades a needle that
  matches nothing.
- **Size:** M

### Step 7. The doc tier
- **Target:** `docs/elements/ledger.md`, `docs/examples/INDEX.md`,
  [[arcs/display-calculus-arc]] rows `C1` and `C2`, [[banks/render]] shards G, H
  and L, `records/gate-audit.md`
- **Change:** the arc rows move off `unminted` with the gate named and its
  hand-run status stated. Shard G stops saying the cascade has no stated law.
  `records/gate-audit.md` gains the row decision 5 files. **No row anywhere may
  say this element's conformance is in the suite total.**
- **Size:** S

## 5. Conformance gate

**Golden behavior.** `walk-amb` returns true over the whole product, so the root
exits 42. Every figure below was re-derived twice in this run, once as an
independent model and once **natively**, by compiling the root with
`bin/chirality-bin` and reading the count it prints. The two agree exactly.

| | measured |
|---|---|
| probes **visited** | **63,536** = 11 ambients × 16 masks × 19 `fg` × 19 `bg` |
| probes **asserted** | **14,256** = 11 × 16 × 9 × 9, the ones `in-sgr-domain` admits |
| **disagreeing on the shipping definitions** | **0** |

Every arithmetic factor is read off the tree: `default-faces`
(`render.chiral:148`) has eleven entries, the colour axes are swept `-1..17` and
the domain admits `-1..7`, the attribute axis is swept at its domain width.

### Mutants

| mutant | what it moves | disagreeing |
|---|---|---|
| 1. delete `((=i code 3) (sgr-italic true))` from `parse-sgr` | the italic loss returns. No registry ambient carries bit 4, so nothing masks it | **7,128** of 14,256, the half of the masks carrying bit 4 |
| 2. widen `in-sgr-domain`'s `fg` bound to `(<=i fg 17)` | the asserted set grows to 11 × 16 × 19 × 9 = 30,096. `fg` 8 emits `38` and `fg` 9 emits `39`, both `sgr-other`; `fg` 10 through 17 emit `40` through `47`, which `parse-sgr` reads as a **background** | **15,840** newly asserted, every one of them |
| 3. delete `(cons 7 l2)` from `face-params` | the reverse bit stops being emitted while `face-join`'s `bor` still sets it | **6,480**. The shortfall from 7,128 is the point: `manas-cursor` is the one ambient whose own `attrs` is `8`, so on its slice the pen already carries reverse and the mutant is masked. The other ten convict it |

Mutant 1 needs no harness on day one: **the root exits 1 against today's
unmodified `lib/`**, because today's `lib/` is mutant 1. Step 1 is what turns it
green, verified in this run.

### The mutant hole, stated

**Widening `attrs` past 15, or either colour bound below -1, disagrees on
nothing.** Measured, with the sweep widened to match each bound so the probes
actually exist:

| bound widened | newly asserted | disagreeing |
|---|---|---|
| `attrs` upper, 15 → 31 | 14,256 | **0** |
| `attrs` lower, 0 → -16 | 14,256 | **0** |
| `fg` lower, -1 → -9 | 12,672 | **0** |
| `bg` lower, -1 → -9 | 12,672 | **0** |

`face-params` and `face-join` read bits `1`, `2`, `4` and `8` and nothing else,
so an `attrs` of 16 to 31 behaves as `attrs - 16`. Any negative index emits
nothing, inherits the outer in `face-join`, and maps to `color-default` in
`idx->color`, so every negative agrees with every other. The counts scale with
how far the bound is moved; the zero does not.

**Narrowing is the other direction, and it is guarded by `walk-amb` asserting
`in-sgr-domain` on every registry face.** Measured, the first narrowed value each
bound is refused at:

| bound | caught first at | which face refuses it |
|---|---|---|
| `attrs` upper | 7 | `manas-cursor`, `attrs` 8 |
| `fg` upper | 6 | `manas-header`, `fg` 7 |
| `attrs` lower | 1 | `default`, `comment`, `string`, all `attrs` 0 |
| `fg` lower | 0 | `default` and `manas-cursor`, both `fg` -1 |
| `bg` lower | 0 | every entry, every `bg` is -1 |
| **`bg` upper** | **never** | **none** |

⚑ **The `bg` upper bound is unguarded in the narrowing direction.** Every entry
in `default-faces` has `bg` of `-1`, so narrowing that bound all the way to `-1`
refuses no registry face. Measured: the asserted set falls from 14,256 to
**1,584** with **0** disagreements and the root still exits 42. The example's
residue paragraph claims narrowing is guarded and names one face where two
qualify; this is the case where it is guarded by nothing. Closing it needs a
registry entry with a non-negative `bg`, which is `display-calculus/C5`'s
root-supplied theme. Until then it is residue with a number against it.

### The fourth row this gate does not carry, and why the reason has changed

A row asserting `face-sgr f == sgr-str (face-params f)` is a tautology after
step 2, since that equation becomes the definition of `face-sgr`. The example
drops it on that ground and the ground holds.

⚑ **What replaces it is weaker than the example implies, and this run measured
the gap.** A fourth mutant was built and run: emit the same six codes in the
**reverse order**. It disagrees on **0** of 14,256 probes. Within the domain every
code `face-params` emits writes a distinct `Attrs` slot, so `fold-sgr` is
order-independent and `joins-agree` cannot see a reordering. Phase 16 cannot
either: its cell map is an unordered set and its G5 pins only the stream's final
four bytes.

**So the emitted order of SGR parameters is guarded by nothing in either tier**,
and decision 3's byte leg would not close it, because `vt-parser` hands
`fold-sgr` a parameter list and the same order-independence applies. Only a
byte-level golden pin catches a reorder. That is stated residue rather than a
row this element can write.

### `sgr-code` on codes 3 and 40 through 47, accepted

No tier guards these bytes, and the exposure is bounded by two measurements.
`sgr-code` (`render.chiral:180`) has no branch on its argument, so the six codes
Phase 16 drives through it in a live byte stream exercise the same single
expression that `3` and `40` through `47` would. What is genuinely unexercised is
the `i64->str` of those particular integers. **Accepted as residue**, recorded
here. Decision 3 does not close it.

### Baseline → expected

| | baseline, measured this run | expected |
|---|---|---|
| `bin/chirality test` | **373 passed, 0 failed**; compile-only 88 roots built, 0 failed; `gate PASSED` | **unchanged at 373**, and 89 compile-only roots after step 5. This element adds no assertion to the suite total, because its script carries no `run_phase` line |
| Phase 16, `tools/test/face.sh` | **38 passed, 0 failed** | unchanged. Step 2 is byte-identical on its fixture, verified |
| Phase 17, `tools/test/render-doc.sh` | dispatched and green in the suite run above | unchanged |
| `tools/test/registration.sh` | 9 passed, 0 failed; 13 dispatch lines, 20 scripts, 7 PEND | **9 passed, 0 failed; 13 dispatch lines, 21 scripts, 8 PEND** |
| `tools/test/style.sh`, hand-run | does not exist | exit 0, the root exits 42, three mutants each reddening with the count above |
| `ledger-lint` | **clean**, checks A to AB, with H and M vacuous and named | clean |
| `prose-lint` | clean on every file this element touches | clean |

**Done when** `bash tools/test/style.sh` reports 0 failed with the root at exit
42 and each of the three mutants reddening at 7,128, 15,840 and 6,480, `bin/chirality test`
still reports 373 passed and 0 failed, and `tools/test/registration.sh` reports
21 scripts with 8 PEND and G1 through G6 `ok`.

## 6. Residue and links

**Deliberately unbuilt**, each with its home.

| residue | home |
|---|---|
| `Face`'s three `I64` fields stay bare. Decision 1 measures why the refinement engine cannot carry the domain today | a refinement-engine element. This arc has no reserved band, so the row is `UNASSIGNED` per [[working-discipline]] |
| retiring `Face`. Direction settled, work not taken | the same, and [[arcs/display-calculus-arc]]'s `C1` row |
| the byte-level leg through `vt-parser` | [[banks/render]] shard Q, and decision 3's measurement |
| the emitted **order** of SGR parameters, guarded by nothing in either tier | stated in §5. Needs a byte-level golden pin |
| the `bg` upper bound, unguarded in the narrowing direction | `display-calculus/C5`, a root-supplied theme with a non-negative `bg` |
| `sgr-code` on `3` and `40` through `47` | §5, accepted with its bound |
| `sgr-blink` and `sgr-strike`, arms no `Face` can reach | [[banks/render]] shard H. They stay dead after this element |
| `SGR_AWK` as a third SGR model | [[arcs/enforcement-arc]]'s tooling-surface requirement; [[banks/render]] shard X |
| `bool-eq` in `render.chiral` rather than the prelude | decision 6, priced. The one change that would put the build rule on this tier |
| E111's conformance line asserting a run no phase performs | `records/gate-audit.md`, beside GA-25, filed by step 7 |
| the suite phase number | [[records/author-calls]], the standing row. Already carries this element |
| `display-calculus/C4` and `C5` | `not started`, returned there when C01 went `superseded` |

**Mints nothing.** [[decisions/decision-lane-split]] reserves `E184-E189` and
`E190-E195`, and neither band is this arc's. Under [[working-discipline]]'s
deferral rule an arc with no reserved block writes `UNASSIGNED` and stops, so
every follow-on above is residue with a named home instead of a phantom `E#`.

**Related:** [[C1C2-style-round-trip]] (the example this implements) ·
[[C01-typed-style-value]] (superseded by it) · [[banks/render]] (shards C, D, E,
G, H, K, L, Q, X) · [[arcs/display-calculus-arc]] (rows C1, C2, and the A1
correction in §2) · [[goals/display]] · [[decisions/decision-work-ids]] ·
[[decisions/decision-lane-split]] · [[working-discipline]] (the build rule, the
deferral rule, the reporting rule) · [[status-ledger]] (E111, E175, and the
unregistered-script precedent) · [[records/gate-audit]] (GA-25) ·
[[records/author-calls]] (the phase-number fork) · [[arcs/enforcement-arc]]
(decision 4's home)
