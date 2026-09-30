---
element: E184
slug: def-fate-sum
title: "**Attribution: every def's fate is stated by the compiler, with evidence, and checked**"
design: examples/E184-def-fate-sum.md
status: draft
updated: 2026-09-11
---

# E184 SPEC: **Attribution: every def's fate is stated by the compiler, with evidence, and checked**

> The build half, produced by the `design-to-spec` run. An implementation run
> follows THIS file.

**The design-tier artifact is `docs/examples/E184-def-fate-sum.md`, and there is
no `docs/arcs/parts/` file.** E184 minted 2026-09-01, before
[[decisions/decision-design-before-mint]], so the worked example written
2026-09-09 is the artifact that made the design decisions and §5 of it is the
literal spelling this file plans against. `python3 tools/pack/pack.py E184 --spec`
resolved it and scaffolded this file.

**Every `file:line` below was opened on 2026-09-11 at `95e52e3`.** Where a number
differs from the design's, §2 says so in its own row. Another session commits to
this tree concurrently.

## 1. Deliverable

- **After this runs:** the compiler states one fate for every definition in a
  two-stage domain, every fate carries typed evidence, the fates reach
  `compile-all`'s success arm, and a fold inside the compile refuses a definition
  with no fate, a definition with two, and an emitted label no fate claims.

- **Chosen shape:** the six sums, the two-level reason and the fate record of
  `docs/examples/E184-def-fate-sum.md` §5, with the domain ruled 2026-09-10 by
  the author as **the pre-pass def set plus what the pass created**, a fifth arm
  `ft-created (by Str)`, and **deletion never a fate**: a definition that leaves
  the globals list leaves through `ft-specialized` naming its successors.
  [[records/author-calls]] carries that row at `ruled` and
  `docs/arcs/enforcement-arc.md` `#### The seven requirements` R1 carries the
  amendment. This file does not reopen it.

- **The six spelling decisions are settled and this file applies them.**
  Decision 3 is **retype the producer**: `term->ntalty`, `term->ntalty-list` and
  `term->ncore` become result sums and the `(_ (none))` arms go. Decision 2
  follows from 3 with no separate ruling, so `SkHead`'s width is settled by
  `lib/typing/kernel.chiral:1319` and not by a count. Decision 5 is **`skr-erase`
  carries evidence**. Decision 7 is settled by R1's own text: `ft-erased` keeps
  its arm. Decision 4 loses the `$` convention to R2. Decision 6's premise is
  measured: only `ntalty->talty` exists, so carrying the refused type means
  building a function that is absent tree-wide. All six are in
  [[records/author-calls]]'s E184 rows.

- **Non-goals.**
  - **The 63-root census.** The `extern` tag falling from 187 to 5 is the
    element's conformance target and no committed instrument produces 187 today.
    §4's rows re-derive the split on `prog/compiler.prog` alone. **Home:
    `enforcement/N14`.**
  - **Any change to the emitted bytes.** Nothing here reaches `erase-fn`, so
    every root compiles to the bytes it compiles to today. §4 makes that a
    checked row.
  - **Any change to `format-blame`'s output bytes.** E187's R5 gates it and the
    gate stands. The renderers move onto the new accessors and reproduce their
    strings.
  - **The extern region.** `prim->n` (`lib/lowering/compile-front.chiral:326-333`)
    keeps its `Maybe`. `PeelR` covers definitions and
    [[decisions/decision-def-partition]] §3 keeps the extern region E107's.
  - **The two arm-count sub-questions.** They are the author's, they are open,
    and §3 Step 9 is gated on them. Decision A and decision B in §3.
  - **Linearity as the conservation mechanism.** Decision C in §3 carries it
    unruled, and §2 prices it.

## 2. What the code forces

The design chose a shape against structural outlines. This is where the live
files push back.

### The design's census holds, and the three citations it corrected are right

| target | the design assumed | the file admits | verdict |
|---|---|---|---|
| `lib/lowering/skip-diag.chiral:8` | imports `prelude/prelude` and nothing else | exactly that. One import line | agrees |
| `lib/lowering/skip-diag.chiral:15-16` | `SkReason` three arms, `sk-defunc`'s `why` a `Str`; `SkRec` two fields | exactly that | agrees |
| `lib/lowering/skip-diag.chiral:92-106`, `:121` | `blame-chain` takes fuel, `format-blame` passes 100 | exactly that. `:120` holds the `100` | agrees |
| `lib/lowering/compile-front.chiral:211-223` | `peel-def`, four `(none)` arms at `:214`, `:217`, `:220`, `:222` | exactly that. `:214` is the codomain, `:217` the body on the stated branch, `:220` the kept domains, `:222` the body on the peeled branch | agrees |
| `lib/lowering/compile-front.chiral:72`, `:134` | the two `(_ (none))` arms decision 3 removes | exactly those two lines | agrees |
| `lib/lowering/upper/lower.chiral` | 19 originating skip sites, 15 literal and 4 `str-cat` | `grep -c -- '-skip "'` reads 15 and `grep -c -- '-skip (str-cat'` reads 4, at the 19 lines the design names | agrees |
| `lib/lowering/upper/lower.chiral:125-131` | seven result sums, six carrying `(reason Str)` | seven sums at those lines and **all seven** carry `(reason Str)` | agrees |
| `lib/lowering/compile-back.chiral:271` | every term-level `le-skip` wrapped as `(sk-extern er)` | exactly that, keyed on the `NDef`'s `name` | agrees |
| `lib/lowering/compile-back.chiral:272` | `lower-defs` adopts `(cons main extra)` whole | exactly that, through `lapp-tfn` and `opt-tfns` | agrees |
| `lib/lowering/compile-back.chiral:189`, `:191`, `:211` | `filter-erasable`'s silent arm, its named arm, `prune-pass`'s cascade record | exactly those three | agrees |
| `lib/lowering/compile-back.chiral:255-256` | the two channels run over a flat accumulator | `filter-erasable` at `:255` and `prune-fix` at `:256`, both over `acc` | agrees |
| `lib/lowering/upper/closconv.chiral:698`, `:723`, `:726` | `sk-defunc` built once, two `why` literals | exactly that. `st-pois-defunc` is `:692-698` | agrees |
| `lib/lowering/upper/specialize-singleton.chiral:194`, `:195`, `:202` | `lift-add`, `lift-lifted`, `process-mk` | exactly those three lines | agrees |
| `lib/lowering/upper/specialize-singleton.chiral:227-228` | `prune-live` and `drop-pruned` | exactly those two lines | agrees |
| `lib/lowering/tal/erase.chiral:26-31` | six sums, every one carrying `(reason Str)` | exactly that. `XF` is `:30` | agrees |
| `lib/typing/kernel.chiral:1319` | the exhaustiveness refusal decision 3 uses as its instrument | `(false (tc-err (r-judged (subj-none) (jg-nonexhaustive))))`, inside `finish-case` | agrees |
| `lib/typing/diag.chiral:135`, `:749-751` | `r-skipped`'s payload, `dg-chain-doc` reading `skwhy-tag` and `skwhy-name` | exactly those. `dg-chain-doc` is `:741-754` | agrees |
| `lib/lowering/compile-all.chiral:17`, `:36` | `CAllR` two arms, the `elf-ok` arm discarding `skips` | `CAllR` at `:17`; the `elf-ok` arm is **`:36`** and the `elf-err` arm `:42-44`. The design's §6 correction table already repointed the minted row's `:34-38` and it is right | agrees |
| `lib/lowering/compile-front.chiral:373` | `(bridge-sig (closconv-sig (specialize-singletons sig)) name)` | exactly that. `bridge-sig` is `:344-354` and its `let` at `:349` is where the peel runs | agrees |
| FD-25's blast radius: 27 call sites, all inside `compile-front.chiral` | nothing outside that file calls the six functions | 45 occurrences in `compile-front.chiral`; every occurrence elsewhere is a comment (`closconv.chiral:1004`, `:1030`, `:1101`, four `prog/` and `tools/test/samples/` headers) | agrees |
| `tools/test/opt-census.sh` | `defs=1519 skipped=10 tfns=1549` | re-run 2026-09-11: `census tfns=1549 ok=1518 err=31 defs=1519 skipped=10 unfolded-ok=1518`, `8 passed, 0 failed`, 7 s. The pins the design derived M-A from hold at HEAD | agrees |
| `lib/lowering/upper/specialize-singleton.chiral:229` | `specialize-singletons` returns a bare `Sig` | exactly that. The design cites `:229-232`, which spans `specialize-singletons` at `:229` and `sp-finish` at `:230-232` | agrees |

**Refusals: none.** Every target admits the design's §5 shape. No `revisit` on the
worked example is owed by this run.

### Seven constraints carried into §3, each measured here

**C1. `XF`'s reason is never constructed at `XF`, so decision 5 cannot retype
`XF` alone.** The six sums carry 34 construction sites in
`lib/lowering/tal/erase.chiral`, and they split two ways. **Eight ORIGINATE** a
reason, all of them `xi-err` or `xbr-err`: `:158`, `:162`, `:164`, `:166`, `:169`,
`:190`, `:195`, `:251`. **Twelve PROPAGATE** an existing `r` unchanged: `:223`,
`:226`, `:234`, `:241`, `:243`, `:253`, `:255`, `:262`, `:268`, `:275`, `:282`,
`:284`. `XF` originates nothing: every `xf-err` arrives from `XC` at `:275`, `XC`
from `XI` and `XBR`, `XFS` from `XF` at `:282`. Changing what `XF` carries
therefore changes what `:275` hands it, which is `XC`'s payload, which is `XI`'s
and `XBR`'s. **The sizing question answers itself: all six move together, and
the cost is eight new arms and two readers.** The twelve propagation sites are
textually unchanged.

**C2. The evidence sum cannot live in `erase.chiral`, and `skip-diag.chiral` will
take it.** `skr-erase` carries the evidence and `SkRoot` is declared in
`skip-diag.chiral`, which is in both compiler images (`lib/typing/diag.chiral:57`,
`lib/lowering/compile-back.chiral:21`) and imports `prelude/prelude` alone. A
`skip-diag` sum cannot name an `erase.chiral` type. The eight originating sites
carry only `Str`, so the sum is declarable from `prelude` and lands in
`skip-diag.chiral` beside `SkRoot`. `erase.chiral` then imports `skip-diag`, and
**that import collides on nothing**: the two files' top-level name sets are 32 and
16 and their intersection is empty, measured 2026-09-11, and the live lower image
already loads both into one flat namespace through `compile-back.chiral:17` and
`:21`.

**C3. A sixth `TFn` field costs eight files and reaches two that hold live gate
rows.** `(tfn name params ret body nregs)` is `lib/lowering/tal/ssa.chiral:40` and
the pattern occurs **18 times across 8 files**: `upper/optimize.chiral` 4,
`compile-back.chiral` 4, `prog/optimizer-census.prog` 2, `upper/lower.chiral` 2,
`tal/eval.chiral` 2, `tal/check.chiral` 2, `tal/ssa.chiral` 1,
`tal/erase.chiral` 1. Two of those eight are outside the compiler blob and carry
gates: `tal/check.chiral` is the subject of `tools/test/tal-check.sh` G18, which
PRB-70's ruling put outside the blob on 2026-09-08, and
`prog/optimizer-census.prog` is `tools/test/opt-census.sh`'s whole subject. The
threaded `(List (Pair Str Str))` costs **four signatures in one file**,
`filter-erasable`, `prune-pass`, `prune-fix` and `lower-defs`, all in
`compile-back.chiral`, with the producer already holding the relation at `:272`.
**Decision 4's remaining fork is decided by that ratio.**

**C4. `conserve` needs a domain the fates did not produce, and no seat sees both
halves today.** Stage one of the domain is `(sig-globals sig)` as
`specialize-singletons` receives it, which exists only inside `compile-front`
(`:373`). Stage two closes after `outline` has run, inside `lower-defs` in the
back. `compile-all` sees `FR` and `BR` and never sees a `Sig`. A fold that
recovers the domain from the fates compares the fates against themselves and is
the gate that cannot fail [[decisions/decision-scope]] names. **So `fr-ok` gains a
`domain (List Str)` field carrying stage one**, and `conserve` is seated in
`compile-all` where both halves are in hand. The design's §5 widened `FR` with
`fates` and did not name this field.

**C5. The fold is affordable, and the machinery is already imported.**
`lib/lowering/compile-back.chiral:19` imports `prelude/map`, an AVL with
`m-lookup`, `m-insert` and `m-fold` over a comparator, and `dedup-str`
(`:117-124`) already runs `str-cmp` through it. On `prog/compiler.prog` the domain
is 1,519 definitions plus the 13 created names and the emitted label set is 1,549,
so a list-against-list fold is about 2.3 M string comparisons and a `Map Str I64`
fold is about 17 K. **`conserve` runs on every compile**, which is R7's own
sentence, and the map is why that costs a fraction of a second instead of a
rebuild.

**C6. `tools/test/samples/e158_doc.prog` is sha256-pinned by three gates, and
moving it runs a four-file cascade.** The fixture constructs
`(mk-skrec "lowerme" (sk-callee "callee"))` at `:154` and moves with the
spelling. Its digest `2a319302…` is pinned at `tools/test/row.sh:674`,
`tools/test/face.sh:556` and `tools/test/pretty.sh:481`, and those scripts are
themselves pinned: `render-doc.sh:492-495` pins `face.sh` and `row.sh`, and
`pretty.sh:475-482` pins all five. `records/gate-audit.md` GA-23 measured the same
cascade and `records/enforcement-arc.md` EN-26 ran it on 2026-09-08. **Three pins
and their two carriers are re-taken in the commit that moves the fixture**, which
is `render-doc.sh:489-500`'s stated rule.

**C7. `tools/test/defunc-blame.sh` mutates the exact text this element rewrites.**
M3 at `:349` substitutes `(mk-skrec g (sk-defunc g why))` for
`(mk-skrec g (sk-defunc why why))` in `closconv.chiral`, M2 at `:340-341`
substitutes the two `why` string literals, and M4 at `:358` substitutes
`(str-eq (skwhy-tag w) "defunc")` in `skip-diag.chiral`. All three anchors die
with the spelling. The failure is loud rather than silent, because `mutate`
refuses a pattern that changed nothing, so this is a constraint on the commit
that moves each anchor and not a hazard left for later.

### What the linear-obligation option costs, measured

Decision C below is carried unruled, and this is its price rather than its
answer. `Reap`'s shape is `lib/runtime/proc.chiral:27-33`, and linearity is real:
`is-linear` (`lib/typing/kernel.chiral:325-330`) answers on the type,
`linear-bad?` (`lib/module/loader.chiral:495-496`) refuses a linear field declared
at a quantity other than 1, and `check-dfields` (`:526`) applies it. **The
carrier is where it stops.** `List` is `lib/prelude/prelude.chiral:27-29` and its
`cons` declares `(hd A)` with no quantity token, which
`lib/surface/parse.chiral:496` defaults to `w=2`. `is-linear` reaches its `_`
arm on a type variable, so `(List <linear>)` is accepted at `List`'s declaration
and charges nothing. **A linear `ft-specialized` therefore cannot ride a
`(List FateRec)`**, and every signature in the design's §5 uses that carrier
through nine modules. The linear answer is a different transport rather than a
different spelling, and that is what the author's row is being asked about.

### The build baseline, measured 2026-09-11 at `95e52e3`

`chirality_blob_file "lib:prog" prog/compiler.prog` assembles **841,089 bytes** in
1.3 s. `bin/chirality-bin` is **1,220,984 bytes** and compiling that blob produces
`P1` at 1,220,984 bytes; `P1` compiling the same blob produces `P2`; `cmp P1 P2`
is identical and `cmp P1 bin/chirality-bin` is identical. **The Step-0
precondition passes on an unmodified tree**, so a mismatch after any step below is
attributable to that step. One generation costs about 1 s of compile beside 1.3 s
of blob assembly.

## 3. Change plan (ordered, commit-sized)

> Every step below touches `lib/`, which is compiler source, so the whole of §3
> owes the build rule in [[definitions/working-discipline]]: build-new, test,
> promote, nothing replacing itself in place, generations from the same blob until
> two consecutive ones are byte-identical, a non-empty check before every `cmp`,
> `(ulimit -s unlimited; …)` on every invocation, and a stop at `C4`. **The rule
> is paid once, at Step 11**, which is E187's eight-step shape (`8f688be` through
> `8d4009d`, promotion at the last). Each step before it is verified to compile
> under the tracked binary where it lands, and `bin/chirality-bin` is stale until
> Step 11 promotes. **Nothing in emission moves**, so the first agreement is
> expected at `C1 == C2` and `C2 == C3` is the cap.

**The sizing call behind eleven steps.** The sums come first and the producers
follow, because a producer cannot construct a sum that does not exist yet, and
that is the design's own open question 3. Within that ordering the boundaries are
forced by what compiles: a closed sum and every `case` over it must land together
or the tree is non-exhaustive, which is `lib/typing/kernel.chiral:1319`. Eleven
steps put each sum with its own producers and keeps every step under about
seventy lines against the design's measured 380 to 520. **A single commit was
refused** because it lands nine blob modules, three gate scripts, a fixture, a
probe and a driver at once with one build cycle to attribute a failure to.
**Three or four commits were refused** for the same reason one step down: they
merge `skip-diag.chiral`'s six sums with the nine files that construct them, so a
non-exhaustive `case` and a wrong evidence arm arrive in one diff.

### Step 0: the Step-0 precondition (verification only, no commit)

Re-run §2's baseline. Record the blob and binary byte figures. Two empty files
compare equal, so the non-empty guard runs before every `cmp`.

### Step 1: `skip-diag.chiral` gains the five evidence codes, and constructs none of them

- **Target:** `lib/lowering/skip-diag.chiral`, after `SkRec` at `:16`.
- **Change:** declare `SkHead` (16 arms), `SkPos` (3 arms), `DefWhy` (2 arms),
  `SkLow` (18 arms) and `XErr` (8 arms), each with the accessor block
  `skip-diag.chiral:3-6` and `lib/typing/diag.chiral:20-25` make mandatory: every
  `case` on these sums lives inside a small accessor def as the direct body of a
  `lam`. `sklow-text` reproduces the 19 live strings of
  `lib/lowering/upper/lower.chiral` and `xerr-text` reproduces the eight of
  `lib/lowering/tal/erase.chiral`, so the two renderers are checkable against the
  literals they replace before any producer moves. **`XErr`'s eight arms are C1's
  eight originating sites**: `xe-prim-arity2 (op Str)` for `:158`, `xe-bget-arity`
  for `:162`, `xe-blen-arity` for `:164`, `xe-strlen-arity` for `:166`,
  `xe-prim-nonnative (op Str)` for `:169`, `xe-const-data` for `:190`,
  `xe-con-unknown (cn Str)` for `:195`, `xe-branch-unknown (cn Str)` for `:251`.
  **`SkHead`'s width is 16 because the instrument makes it 16**: decision 3
  removes the `(_ (none))` arms at `compile-front.chiral:72` and `:134`, and
  `kernel.chiral:1319` then forces one arm per unnamed `Term` head.
- **Size:** L for the file, purely additive, nothing else compiles differently.

### Step 2: `erase.chiral`'s six sums carry `XErr`

- **Target:** `lib/lowering/tal/erase.chiral` at `:20-31` and the eight originating
  sites; `lib/lowering/compile-back.chiral:132` and `:188`.
- **Change:** a new `(import "lowering/skip-diag")`, the six `(reason Str)` fields
  become `(reason XErr)`, the eight originating sites construct arms, the twelve
  propagation sites are untouched, and the two readers in `compile-back.chiral`
  call `xerr-text`. `:132`'s `(str-cat "erase: " m)` keeps its bytes.
- **The sizing call, with C1 as its reason:** all six sums move in one change,
  because `XF` originates no reason and every `xf-err` payload arrives from `XC`,
  `XI` and `XBR`. Retyping `XF` alone changes nothing, because its payload is
  `XC`'s.
- **Size:** M.

### Step 3: `lower.chiral`'s seven sums carry `SkLow`, and the 84 dead lines go

- **Target:** `lib/lowering/upper/lower.chiral` at `:125-131`, the 19 sites, and
  `:22-105`; `lib/lowering/compile-back.chiral:271`.
- **Change:** the seven `(reason Str)` fields become `(site SkLow)` and the 19
  sites construct arms. One `sl-case-nondata` arm covers both
  `lib/lowering/upper/lower.chiral:309` and
  `lib/lowering/upper/lower.chiral:358`, which are one refusal reached down two
  paths. Two arms cover `lib/lowering/upper/lower.chiral:246` and
  `lib/lowering/upper/lower.chiral:249`, which carry one message between them.
  That is E157's Judg shape (`lib/typing/diag.chiral:12-18`) and not a
  duplicate: `SkLow` is a site code, and two sites carrying one field are two
  sites. The 84 unreached lines at `:22-105`
  are deleted, which is [[decisions/decision-def-partition]] §5 and the author's
  2026-09-09 ruling in [[records/author-calls]]. `compile-back.chiral:271` wraps
  `(sk-extern (sklow-text er))`, so the message stays byte-identical and
  `SkReason` is untouched for one commit.
- **The shim is named and its retirement is scheduled.** `sklow-text` at `:271`
  exists so Step 3 compiles without Step 5's `SkReason`. Step 5 replaces it with
  `(sk-root (skr-body er))`. Merging the two steps was refused: together they are
  `lower.chiral`'s 19 sites plus `skip-diag.chiral`'s two-level rewrite plus four
  construction sites plus `diag.chiral` plus a fixture plus three sha256 pins.
- **Size:** L.

### Step 4: `closconv.chiral` builds `DefWhy`

- **Target:** `lib/lowering/upper/closconv.chiral:692-698`, `:723`, `:726`;
  `tools/test/defunc-blame.sh:340-341` and `:349`.
- **Change:** `st-pois-defunc` takes a `DefWhy`, the two literals become
  `(dw-no-declared-type)` and `(dw-family-arity)`, and `skwhy-detail`
  (`skip-diag.chiral:37-38`) renders through `defwhy-text` so `defunc-lines` keeps
  its bytes. `defunc-blame.sh`'s M2 and M3 anchors are repointed at the new text
  in the same commit, which is C7.
- **Size:** S.

### Step 5: `SkReason` becomes two-level over `SkRoot`, and PRB-81's observable lands

- **Target:** `lib/lowering/skip-diag.chiral:15`, `:25-38`, `:92-106`, `:119-121`;
  `lib/lowering/compile-back.chiral:191`, `:211`, `:271`;
  `lib/typing/diag.chiral:749-751`; `tools/test/samples/e158_doc.prog:154`;
  `tools/test/defunc-blame.sh:358`; `tools/test/row.sh:674`,
  `tools/test/face.sh:545`, `tools/test/pretty.sh:481`, and the two carriers
  `render-doc.sh:492-495` and `pretty.sh:475-482`.
- **Change:** `SkRoot` gets five arms (`skr-body (site SkLow)`,
  `skr-extern (op Str)`, `skr-erase (why XErr)`, `skr-defunc (name Str) (why
  DefWhy)`, `skr-peel (pos SkPos) (head SkHead)`) and **no cascade arm**.
  `SkReason` keeps its name and gets two arms, `sk-root (why SkRoot)` and
  `sk-cascade (callee Str) (root Str) (why SkRoot)`. An unrooted chain is then
  unrepresentable. `blame-chain`'s `fuel` parameter and `format-blame`'s `100`
  retire, because the root is a field. `filter-erasable`'s silent arm at
  `compile-back.chiral:189` stops dropping and files `(skr-erase m)`, which is
  decision 5 and M-C's repair. The three sha256 pins and their two carriers are
  re-taken here, which is C6.
- **The observable:** `skwhy-tag` answers `"extern"` for every record today.
  After this step `skroot-tag` answers `"body"` for the `lower-defs` channel and
  `"extern"` only for `filter-erasable`'s named arm.
- **Size:** L.

### Step 6: `compile-front.chiral` retypes the producer

- **Target:** `lib/lowering/compile-front.chiral`, at `term->ntalty` (`:58-72`),
  `term->ntalty-list` (`:73-78`), `term->ncore` and its four helpers
  (`:102-158`), `peel-def` (`:211-223`), `peel-globals` (`:226-233`),
  `field-tys->n` (`:238-245`), `prim->n` (`:326-333`), `bridge-sig` (`:344-354`).
- **Change:** `NtR`, `NtLR`, `NcR` and `PeelR` as the design's §5 declares them.
  The `(_ (none))` arms at `:72` and `:134` go and every remaining `Term`
  constructor takes a named arm, which `kernel.chiral:1319` enforces.
  `peel-def` returns `PeelR`, whose `pk-erased` arm is the codomain refused at
  `(t-type n)` and whose `pk-skip` arm carries a `SkRoot`. `peel-globals` returns
  `(Pair (List NDef) (List FateRec))`. **FD-25's measured radius is the size of
  this step**: 27 call sites, 11 self-recursive, 12 distinct enclosing functions,
  refusal originating at 3 sites, propagating at 19, absorbed at 3 sinks that
  today drop a whole entity and continue. `prim->n` keeps its `Maybe` by §1's
  non-goal, so its two `term->ntalty` calls read the new sum and re-wrap.
- **Size:** L. This is the largest single-file step in the plan.

### Step 7: `specialize-singletons` states what it created

- **Target:** `lib/lowering/upper/specialize-singleton.chiral:195`, `:202`,
  `:227-232`; `lib/lowering/compile-front.chiral:373`;
  `prog/e186-capture-fields.prog:286`.
- **Change:** `SpRel` and `SpOut` as the design's §5 declares them.
  `specialize-singletons` returns `(sp-out sig rel)`, with `sp-lifted` naming what
  `lift-lifted` created and `sp-dropped` naming what `drop-pruned` deleted beside
  the targets `sp-rw` redirected its callers to. `compile-front.chiral:373`
  destructures it. **`prog/e186-capture-fields.prog:286` is the one call site
  outside `lib/`**, measured tree-wide 2026-09-11, and it moves in this commit.
- **Size:** M.

### Step 8: the owner relation reaches `filter-erasable` and `prune-pass`

- **Target:** `lib/lowering/compile-back.chiral:184`, `:204`, `:213`, `:252-275`.
- **Change:** `lower-defs` accumulates `(pair label def-name)` beside `acc` from
  the `(cons main extra)` it already holds at `:272`, and threads it into
  the two calls at `:255` and `:256` of the same file, which reach
  `filter-erasable` and `prune-fix`; `prune-fix` hands it to `prune-pass`. The
  two channels then key their records by definition where they key them by
  emitted label today.
- **The sizing call, with C3 as its reason:** the threaded
  `(List (Pair Str Str))` over a sixth `TFn` field. Four signatures in one file
  against 18 sites in eight files, two of which sit outside the compiler blob and
  carry live gate rows (`tools/test/tal-check.sh` G18 over
  `lib/lowering/tal/check.chiral`, `tools/test/opt-census.sh` over
  `prog/optimizer-census.prog`). The `<def>$<ncase>` convention was eliminated by
  R2 and E157 before this run.
- **Size:** M.

### Step 9: `Fate`, `FateRec`, and the record reaching the success arm

- **⚑ GATED. This step cannot land until decision A and decision B below are
  ruled.** They fix the arm list. Steps 1 through 8 and Step 11 are independent of
  them.
- **Target:** `lib/lowering/skip-diag.chiral` (the `Fate` and `FateRec`
  declarations, `FateRec` retiring `SkRec`), `lib/lowering/compile-back.chiral:126`
  (`BR`), `:327` (`back-program`), `lib/lowering/compile-front.chiral:319-321`
  (`FR`), `lib/lowering/compile-all.chiral:17` where `CAllR` is declared and
  `:36` where the `elf-ok` arm is, `lib/typing/diag.chiral:135` (`r-skipped`),
  `lib/lowering/upper/closconv-driver.chiral:145` (`CCOut`'s `dsk`).
- **Change:** `Fate` takes five arms, `ft-emitted (labels (List Str))`,
  `ft-specialized (into (List Str))`, `ft-created (by Str)`, `ft-erased` and
  `ft-skipped (why SkReason)`, with the fifth carried by the 2026-09-10 ruling.
  `FateRec` widens `SkRec`'s two fields so a record exists for a definition that
  succeeded, and its four readers move with it. **`fr-ok` gains `domain (List
  Str)`** carrying stage one, which is C4 and which the design's §5 did not name.
  `ca-ok` carries `(fates (List FateRec))` and `ca-err` carries them too.
- **Size:** L.

### Step 10: `conserve`, the exit, and the gate

- **⚑ GATED on Step 9.**
- **Target:** `lib/lowering/compile-back.chiral` (`ConsR`, `conserve`,
  `fold-labels`), `lib/lowering/compile-all.chiral:18-45` (the seat),
  `bin/chirality:8-13` (the exit), `prog/e184-fates.prog`,
  `tools/test/samples/e184_fates.prog`, `tools/test/def-fates.sh`,
  `tools/test/run-tests.sh`.
- **Change:** `ConsR` takes four arms, `cs-ok`, `cs-unfated (def-name Str)`,
  `cs-twice (def-name Str)` and `cs-unclaimed (label Str)`. `conserve` folds
  through `prelude/map` (C5) and only `cs-ok` reaches `ca-ok`. `bin/chirality`
  gains a `fates FILE` subcommand beside compile / run / check / test, and its
  help text gains the line. The gate is §4.
- **`conserve` runs on every compile**, which is this run's answer to the design's
  open question 2 and is R7's own sentence. C5 is the measurement that makes it
  affordable.
- **Size:** L.

### Step 11: build-new, test, promote, record

Run the build rule end to end over the changed blob, verify `C1 == C2` at
non-empty, promote, and run `tools/test/run-tests.sh`. Record the blob and binary
byte figures beside Step 0's, a new `EN` row in `records/enforcement-arc.md`, and
the E184 flips in `docs/elements/ledger.md`, `docs/elements/catalog.md`,
`docs/examples/INDEX.md` and `docs/arcs/enforcement-arc.md`.

### Numbered decisions this run carries and does not rule

| # | question | disposition | owner |
|---|---|---|---|
| A | Whether `specialize-singletons`' creations and `outline`'s creations take one arm or two | **NEEDS-AUTHOR, and it gates Step 9.** [[records/author-calls]] carries the row at `unreviewed` and `docs/arcs/enforcement-arc.md` R1's second ⚑ states it. [[records/findings]] FD-22 item 10 measures the published split as two for one arm with a mechanism tag (GCC, MLIR), one for two constructs (DWARF), one abstaining (LLVM's machine outliner), and records the caveat that R2 forbids the `Str` both majority shapes use for the tag. Concretely: either the 40 outlined extras stay labels inside `ft-emitted`'s list, which is M-A's argument and the design's §5 spelling, or they enter the domain under `ft-created` beside the 13 lifted globals, which is R7's own re-test sentence. **The two readings disagree and both are in the tree's live text** | author |
| B | Whether a definition that survives the pass and is also the origin of a created one takes one arm or two | **NEEDS-AUTHOR, and it gates Step 9.** The same `unreviewed` row. `alloc-growing` (`lib/memory/alloc-growing.chiral:18-24`) is the measured instance: it is the origin of three created names and E188's example measures it reaching `compile-fn` and being skipped there. The ruling states `ft-specialized` as the exit of a **departure** and `alloc-growing` does not depart, which narrows the question without closing it | author |
| C | Whether R7's conservation is a checked fold or a linear obligation on the `Reap` model | **CARRIED, unruled by this run.** `docs/arcs/enforcement-arc.md` R7's second ⚑ leaves the choice open and names two things it costs: `Reap` is consumed by one waiter while `ft-specialized` names N successors, so it is a fan-out, and linearity inside the compiler's own source is a commitment about how those passes are written. §2 adds the third and it is a measurement: `(List <linear>)` is accepted at `List`'s declaration and charges nothing, so a linear `ft-specialized` cannot ride the carrier every signature in the design's §5 uses. **§3 builds the checked fold**, which is R7's own sentence *a def with no fate, or with two, fails the compile*, and the linear answer stays a different element rather than a repair to this plan | open |
| D | Which strings `skroot-tag`, `sklow-tag` and `skhead-tag` return, and which of them `format-blame` renders | **RESOLVED by this run.** `format-blame`'s output is byte-identical, which E187's R5 gates, so `leaf-label` (`skip-diag.chiral:86-88`) keeps its exact sentence and reads `skr-extern`'s `op` through the new accessors. The new tags are read by the report exit and by §4's rows and by nothing E187 pins. `sklow-text` and `xerr-text` reproduce the 19 and 8 live strings verbatim | this run |
| E | Whether `conserve` runs on every compile or behind the report exit | **RESOLVED: every compile.** R7 says *checked inside the compile* and C5 prices it: `prelude/map` is already imported at `compile-back.chiral:19` and turns a 2.3 M-comparison list fold into a 17 K-comparison map fold on `prog/compiler.prog` | this run |
| F | The order the nine blob modules land in | **RESOLVED: §3's eleven steps.** Sums first, producers after, each closed sum landing with every `case` over it | this run |

## 4. Conformance gate

- **Named phase:** **33**, `tools/test/def-fates.sh`, dispatched from
  `tools/test/run-tests.sh`. 32 is the last taken (`mul-widen.sh`, E189) and 21
  through 23 are Lane B's reserved band. `run-tests.sh` is the only authority for
  a phase number. `tools/test/registration.sh` requires a new script to be
  dispatched or to declare itself out with a reason, so a registered phase is one
  edit.

- **Baseline.** `bash tools/test/run-tests.sh` reads **422 passed, 0 failed**
  across 21 phases with **94 roots built, 0 failed** and gate PASSED, recorded
  2026-09-09 at `docs/arcs/emitted-speed-arc.md:342` after E189.
  `bash tools/test/opt-census.sh` reads `8 passed, 0 failed` over
  `census tfns=1549 ok=1518 err=31 defs=1519 skipped=10 unfolded-ok=1518`, re-run
  2026-09-11. `skwhy-tag` answers `"extern"` for every skip record the tree
  produces. `compile-all`'s `elf-ok` arm carries no record. Nothing computes a
  partition and compares it to the artifact.

- **Expected.** The same run green with `prog/e184-fates.prog` compiling as a
  Phase 7 root, which takes the root count to **95**, and phase 33 reporting its
  own tally. `opt-census.sh` unchanged, because nothing in emission moves.

### What the gate observes

The probe reads a blob on stdin, runs the front and the back, and reports one
verdict line. **`tools/test/samples/e184_fates.prog` is the fixture** and it lives
under `samples/` so Phase 7's `grep -rl '^(def compile-main' lib prog`
(`run-tests.sh:173-178`) does not sweep it. The fixture is hand-built to put one
definition on each arm: one that emits, one that emits with an outlined extra, one
whose body does not lower, one refused at the peel, one lifted by
`specialize-singletons`, and one dropped by the cascade. The driver also runs the
probe over `prog/compiler.prog`'s own blob, which is where the census rows live.

**Every mutant pins the WHOLE verdict line.** `records/gate-audit.md` GA-21 and
GA-22 both convict a gate that names one row per mutant, because a mutant
reddening a row outside its own pin is then invisible. **Every mutant is a
SUBSTITUTION and never an arm deletion**, which is GA-19: deleting an arm makes
the module non-exhaustive, the compiler refuses the tree, and the row is graded on
a compile refusal instead of on the property it names.

| row | what it asserts | falsifier | why it can convict |
|---|---|---|---|
| **G1** | `conserve` answers `cs-ok` on the fixture and on `prog/compiler.prog`'s blob, and `compile-all` reaches `ca-ok` | M1, M2, M3 | **A row asserting only `cs-ok` on a correct tree is reddened by nothing**, which is [[decisions/decision-scope]]'s gate that cannot fail. G1 is therefore three-sided: the base tree answers `cs-ok`, and three planted trees each answer a different arm. Without those three this row would pass against a `conserve` whose body is `(cs-ok)` |
| **G2** | on M1's tree `conserve` answers `cs-unfated` naming the dropped definition, **and the compile refuses** | M1 | R7's line between attribution and logging. FD-22 item 7 measured GCC's nearest equivalent as a log that neither folds to the emitted set nor fails the build, so a green G2 is the clause no surveyed system occupies. A tree where the fold detects and the compile succeeds is the failure this row exists to catch |
| **G3** | on M2's tree `conserve` answers `cs-twice`, and on M3's tree `cs-unclaimed`, each naming its subject | M2, M3 | the other two arms of the partition. `cs-twice` is *a definition with two fates*, `cs-unclaimed` is *an emitted label no fate names*, and neither is reachable from the other |
| **G4** | the fixture's fate report names exactly one fate per domain member, and the domain size equals stage one plus stage two | M1, M2 | C4's independence: the domain comes from `(sig-globals sig)` through `fr-ok`'s new field and the fates come from the passes, so the two sides are computed by different code. A mutant that drops a fate moves one side and not the other |
| **G5** | on `prog/compiler.prog`, `skroot-tag` answers `"body"` for exactly the records `lower-defs` produced, and that count equals `tools/test/opt-census.sh`'s `skipped`, which reads **10** | M1, M4 | **a cross-instrument agreement.** `prog/optimizer-census.prog:161` counts `le-skip` in a program that shares no code with the probe, and two independent programs agreeing on 10 is evidence the classification is the live one. Today `skwhy-tag` answers `"extern"` for all 10 |
| **G6** | `sklow-tag` splits the `"body"` records across its 18 arms, and the split is pinned at what the implementation run measures | M4 | PRB-81's repair at this root's granularity. The 162 / 10 / 10 split the design cites is over 63 roots and no committed instrument produces it, so this row pins `prog/compiler.prog` and the 63-root figure stays `enforcement/N14`'s |
| **G7** | every `sk-cascade`'s `root` names a record whose `skroot-tag` is one of the five non-cascade tags | M7 | *resolves to a non-cascade root* holding by construction. The positive half runs on the base tree; **the negative half is M7**, a scratch tree where `SkRoot` gains a cascade arm, which the compiler refuses at `skroot-tag`. The property IS the refusal, so grading it on a refusal is the row and not GA-19's trap. The refusal is checked non-empty beside a base tree that builds |
| **G8** | `format-blame`'s output over `tools/test/samples/e188_slot_break.prog` is byte-identical under the pre-change binary and the promoted one | M5 | E187's R5, unchanged. `records/enforcement-arc.md` EN-23 recorded the exact refusal line, so the comparison has a pinned subject |
| **G9** | every root under `lib/` and `prog/` emits a byte-identical ELF under the pre-change binary and the promoted one | M6 | E187's own measurement shape, 90 roots compared one blob each. **It carries a falsifier rather than standing as a control**: M6 drops one definition from `peel-globals`' output, which moves bytes for every root reaching it and reddens G1 and G4 beside G9. GA-22 indicts a row no mutant reaches, and this row is reached |

### Mutants, every one a substitution, every one RUN

The driver copies `lib/` on `tools/test/render-doc.sh:131-145`'s `mutlib` shape,
including its guard that the scratch `lib/` is a real directory and never a
symlink, and its refusal of a `sed` pattern that changed nothing. A mutated `lib/`
alone proves nothing, because the probe is compiled by a binary embedding the old
back end, so each mutant builds one generation from the mutated blob and runs the
probe under that binary. §2 measures one generation at about 2.3 s, so seven
mutants cost about 16 s of compile.

| mutant | the substitution | what it reddens |
|---|---|---|
| **M1 `fate-dropped`** | `peel-globals`' `pk-skip` arm returns the recursive tail without consing its `FateRec`. The arm stays and the module builds | **G1 bad, G2 bad if `conserve` does not refuse, G4 bad, G5 bad, G9 bad.** The definition is still dropped from the `NDef` list, so the emitted program moves |
| **M2 `fate-duplicated`** | `lower-defs`' `le-ok` arm conses a second `FateRec` for the same name beside the emitted one | **G1 bad, G3 bad (`cs-twice`), G4 bad.** Nothing else moves, so a green G5 here says the duplicate is a record and not a second compile |
| **M3 `label-unclaimed`** | `lower-defs`' `le-ok` arm builds `ft-emitted` from `main` alone and drops `extra` from the label list | **G1 bad, G3 bad (`cs-unclaimed`).** This is M-A's whole argument made falsifiable: the 40 outlined extras are why `labels` is a list |
| **M4 `sklow-collapsed`** | `lower.chiral:283`'s `(sl-ho-app)` becomes `(sl-lam-value)` | **G6 bad**, and G5 green, because the count is unchanged and the classification moved. The pair separates *how many* from *which* |
| **M5 `blame-renderer-moved`** | `leaf-label` (`skip-diag.chiral:86-88`) loses the trailing space from `": extern does not lower: "` | **G8 bad** and nothing else. E187's R5 gate is a byte comparison and this is the smallest thing that moves a byte |
| **M6 `peel-drops-one`** | `peel-globals` skips the first definition whose name is longer than a threshold, a substitution that builds and drops one `NDef` | **G9 bad, G1 bad, G4 bad.** It is G9's falsifier and it reddens two rows beside it, which is why the pin is the whole line |
| **M7 `root-carries-cascade`** | `SkRoot` gains `(skr-cascade (callee Str))` in a scratch `lib/`, making `skroot-tag` non-exhaustive | **the tree refuses to compile, and G7's negative half requires that refusal.** The base tree building is the positive control beside it. This is the one mutant graded on a refusal, and the property it grades is unrepresentability |

**The four silent failures of `tools/test/mutant.sh:19-40`, each closed.**
*The mutation matched nothing*: every substitution declares its occurrence count,
the driver refuses any other count, and the mutated tree is `cmp -s`'d against the
base before it is built, which is GA-18's accepted idiom. *The mutant did not
build*: M1 through M6 remove no arm and change no arity, and a failed build
collapses the line to a token no pin holds; M7 is the exception and its expected
value IS the refusal. *Semantically inert*: each substitution moves a value a row
reads directly, and the pinned line is the evidence it moved. *The base was
already red*: the driver asserts the base verdict line before it mutates anything,
which is why the mutants run after Step 11.

### The negative half

Two rows here can pass by looking at nothing and each gets its positive beside it.
G5's `skipped=10` scan is run against a scratch tree with one extra refusing
definition spliced into a module the compiler imports, and the count must move to
11; a scan for a needle that matches nothing anywhere passes by looking at
nothing, which is `render-doc.sh:558-580`'s G9-plus-M11 pair. G7's refusal is run
beside the base tree's successful build, so *the compiler refuses this* is
distinguished from *the compiler refuses everything today*.

- **Done when:** `bash tools/test/run-tests.sh` exits 0 with phase 33 green and
  its own tally at 95 roots, `bash tools/test/def-fates.sh` exits 0 standalone,
  M1 through M7 have each been built and run and reverted with their pinned lines
  recorded, `bash tools/test/opt-census.sh` still reads
  `defs=1519 skipped=10 tfns=1549`, the build rule reaches `C1 == C2` at
  non-empty, and E187's `tools/test/defunc-blame.sh` still reads `11 ok, 0 FAIL`
  with its three repointed anchors.

## 5. Residue and links

### Cost, re-measured, with both earlier figures left standing

`docs/elements/catalog.md` prices E184 at *roughly 150 to 250 LOC across five
modules, three signature changes*. `docs/examples/E184-def-fate-sum.md` §6
re-measured it on 2026-09-09 at **nine blob modules, eleven signature or data
changes, 380 to 520 LOC**. Both stay as written, which is the frozen-estimate rule
in `docs/arcs/enforcement-arc.md` `#### Cost`.

**What this run adds, measured 2026-09-11.** The nine blob modules hold. The
signature count rises by two the design did not list: `fr-ok` gains a `domain`
field (C4) and the six `erase.chiral` sums move together rather than `XF` alone
(C1), which is one data change covering six declarations. **The 380 to 520 figure
is the blob side and this run does not move it**, and the 84 lines deleted at
`lower.chiral:22-105` are inside it.

**The gate is the cost the design left out.** The four most recent comparable
gates measure at 259 to 435 lines of driver (`capture-fields.sh` 259,
`apply-word.sh` 281, `defunc-blame.sh` 397, `mul-widen.sh` 435) beside 124 to 293
lines of probe (`e185-apply-word.prog` 124, `e186-capture-fields.prog` 293). Seven
mutants and nine rows put this one at the top of that range, so **the gate is
roughly 400 to 750 lines outside the blob**, plus the fixture. Beside it sit three
sha256 re-takes and their two carriers (C6), three mutant anchors in
`defunc-blame.sh` (C7), one call site in `prog/e186-capture-fields.prog`, and
`bin/chirality`'s exit.

### Deliberately unbuilt

- **The 63-root census that produces 187.** No committed instrument re-derives a
  def-level count across roots, and §4's rows re-derive the split on
  `prog/compiler.prog` alone. **Home: `enforcement/N14`**, which
  `docs/arcs/enforcement-arc.md` scopes to fix it first. ⚑ One half of the
  design's F3 is stale: `prog/optimizer-census.prog` does re-derive `defs=1519`
  and `skipped=10` on one root, and G5 leans on exactly that.
- **The arm list's final width.** Decisions A and B are the author's and Step 9
  is gated on them. **Home: [[records/author-calls]]**, the row *Whether a created
  definition and its origin take one arm or two*, at `unreviewed`.
- **Conservation as a linear obligation.** Decision C, carried unruled. §2
  measures the carrier that blocks it: `(List <linear>)` is accepted at `List`'s
  declaration (`lib/prelude/prelude.chiral:27-29`,
  `lib/surface/parse.chiral:496`, `lib/typing/kernel.chiral:325-330`) and charges
  nothing, so the answer costs a transport through nine modules. **Home: a roster
  row in [[arcs/enforcement-arc]], and no element is minted for it here.**
- **`sl-short-chain`'s `have` field.** `compile-fn` knows `want` as `total`
  (`lower.chiral:414`) and does not know `have`, because `strip-lams` answers
  `(none)` without reporting the depth it reached. The design prices it at two
  lines in the same file. This plan takes the field and Step 3 carries the two
  lines; a plan that drops the field loses nothing structural.
- **`sl-case-nondata`'s refused type.** Decision 6's premise is measured: only
  `ntalty->talty` exists (`lib/lowering/compile-back.chiral:24`) and the reverse
  direction is absent tree-wide, so this plan leaves the field out. **Home: the same
  roster row that would build the direction.**
- **Any `Term` or `TalTy` in the sums.** `skip-diag` is in both compiler images
  and imports `prelude` alone, which is `lib/lowering/lowspec.chiral:5-12`'s
  verified finding. `SkHead` exists for that reason.

### Follow-on

- `enforcement/N14`, which owns the def-level census the conformance target needs.
- [[arcs/enforcement-arc]] requirement 2, still blocked on its own subject and
  untouched here.
- The author's two arm-count rulings, which unblock Step 9.

### Related

[[E184-def-fate-sum]] · [[decisions/decision-def-partition]] ·
[[arcs/enforcement-arc]] · [[records/enforcement-arc]] · [[records/author-calls]] ·
[[records/findings]] · [[records/gate-audit]] · [[records/lenses/problems]] ·
[[definitions/working-discipline]] · [[definitions/testing-floors]] ·
[[definitions/pattern-boundary-sums]] · [[decisions/decision-scope]] ·
[[decisions/decision-design-before-mint]] · [[banks/erasure]] ·
[[banks/verification]] · [[status-ledger]] · [[E33]] · [[E97]] · [[E107]] ·
[[E157]] · [[E168]] · [[E185]] · [[E187]] · [[E188]] · [[E189]]
