---
element: E173
slug: total-matcher
title: **A total matcher over `Str`**
kind: BUILD-PROPER
example: docs/examples/E173-total-matcher.md
status: draft
updated: 2026-09-01
---

# E173 SPEC — **A total matcher over `Str`**

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

This SPEC covers **slice 1 only**: the matcher with no captures. Slice 2
(captures, 77 sites) is E173's own second slice and is scoped in §4 and §6. Per
the deferral rule in [[working-discipline]], neither slice mints an element, and
this run minted none.

## 1. Deliverable

- **After this runs:** a new module `lib/text/matcher.chiral`, module key
  `text/matcher`, holds a **total, pure, span-returning matcher over `Bytes`**.
  It is shard **D** of [[banks/text]] and P1 of [[arcs/text-tools-arc]]. The
  exported surface, all `->`:

  | binding | type | what it answers |
  |---|---|---|
  | `Cls` / `cls-has` | `(-> Cls I64 Bool)` | is this byte in this class |
  | `Assert` / `Ctx` / `holds` | `(-> Ctx Assert Bool)` | the zero-width tests |
  | `Pat` / `nullable` | `(-> Ctx Pat Bool)` | can the pattern accept here |
  | `pd` | `(-> Ctx I64 Pat (List Pat))` | the Antimirov partial derivative |
  | `norm` | `(-> (List Thread) (List Thread))` | the line that holds the bound |
  | `find-at` | `(-> Pat Bytes I64 (Maybe Span))` | anchored: match at one offset |
  | `find-all` | `(-> Pat Bytes (List Span))` | **one pass**, leftmost-longest, non-overlapping |
  | `count-matches` | `(-> Pat Bytes I64)` | the `grep -c` row of the coverage table |
  | `LState` / `line-step` / `blank-spans` | see §4 step 4 | the line-state pass |

- **`prog/prose-lint.prog` retires its three NOT-CHECKED rows.** The three
  strings it prints today at `:186-188` (`not-but`, `parallel-no`,
  code-skipping) become counted rows, and the 31 literal needles spelled as
  `cons` chains at `:105-121` become patterns scanned in one pass instead of 31.

- **Non-goals**, each with a home in §6: captures and tagged derivatives (slice
  2); a regex-syntax parser (there is no pattern syntax, on purpose); codepoint
  classes (`lib/protocol/utf8.chiral` owns those); leftmost-first / lazy
  semantics (slice 2); the score, the edit script and the stable address (shards
  E, F and G of [[banks/text]], all unnumbered); opening `PureFn`
  (`prog/manas/core/flow.chiral:103`), which the bank calls D's second job.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** no rows. E173 postdates the map snapshot, which
  carries 73 elements against a catalog of 178, so the map is silent here and
  the element is **BUILD**. The build-state authority used instead is
  [[banks/text]] §2, measured against the tree on 2026-09-01.

- **Live code this composes with. Named here; do not respec them:**

  | shard | what is built | where |
  |---|---|---|
  | A | `str-len` `str-sub` `str-find` `str-find-from` `str-cat` `str->bytes` `blen` `bget` `bslice` `bcat` | `lib/prelude/prelude.chiral:75-101`, extern |
  | B | eleven derived string ops, `str-cmp` over `su-cmp-bytes` | `lib/prelude/string.chiral:91-92` |
  | C | `length` `append` `filter` `foldl` `any-list`, `list-sort` (`lib/prelude/list.chiral:143`), `list-dedup-adj` (`:184-186`) | `lib/prelude/list.chiral` |
  | | `Ord` as `(lt) (eq) (gt)` | `lib/prelude/ord.chiral:14` |
  | | the `data`+`case` state-machine idiom this copies | `lib/protocol/vt-parser.chiral:11-20` |

  Two contract facts from C are load-bearing in §4 and are quoted rather than
  re-derived. `list-sort` is **stable** (`lib/prelude/list.chiral:120-145`:
  `ms-merge` takes the left element on `eq`, and `ms-sort-n` splits left-first).
  `list-dedup-adj` keeps the **first** element of each run
  (`lib/prelude/list.chiral:148-190`, which writes the survivor rule down
  because a key projection makes it observable).

- **What does not exist.** There is no `lib/text/` directory. The tree has
  eleven under `lib/` and `text` is absent from them. `MAP.md:104-120` lists the `lib/`
  directories and has no row for it. Nothing in the tree names a `Span`, a
  `Pat`, or a matcher. The whole floor today is `str-find` / `str-find-from`
  (`lib/prelude/prelude.chiral:81-82`), which lower to the naive scan
  `nb-bfind-from` (`lib/lowering/tal/bytes.chiral:355-380`).

- **True delta:** one directory, one module of ≈ 220 lines, one `MAP.md` row,
  one consumer edit in `prog/prose-lint.prog`, one new suite phase. Nothing the
  compiler imports changes, which §5 makes a checked row rather than a claim.

## 3. Decisions

Every open question from the example §6, plus the fork
[[arcs/text-tools-arc]] defers to this stage, dispositioned. No silent design
calls.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | **The arc's fork.** Patterns fixed at pack time and checkable at compile time, or accepted at run time and bounded per pattern with a dynamic set? | **RESOLVED. Run time.** | Three facts, below. |
| 2 | `run-from` returns `-1` for no match, a sentinel where a sum belongs | **RESOLVED. A sum.** | [[pattern-boundary-sums]] is a standing author directive: *"If a `Str` or `I64` in a signature encodes which-of-N-things, it is a sum wearing a disguise."* Its own live precedent is the errno-or-value crossing sums. There is exactly one failure mode here and it carries no field, so the sum is `(Maybe Span)` and a bespoke `MatchR` would add a name over nothing. The internal accumulator becomes `(Maybe I64)` by the same rule. |
| 3 | **Captures:** tagged derivatives, or a narrower primitive (split + span scan + integer scan)? | **DEFERRED to slice 2 of E173.** | The example names the measurement that settles it: classify all 77 sites into served-by-split-scan versus needs-a-submatch, from the same census script, before a line of tagging. That classification is slice 2's step 1. No element is minted; a slice of E173 is E173. |
| 4 | **Match semantics:** longest, shortest, or leftmost-first? | **RESOLVED for slice 1: leftmost-longest.** Leftmost-first **DEFERRED to slice 2** | `norm` is the one function the arrow's honesty lives in, and it is sort-then-dedup over the tree's existing `list-sort` / `list-dedup-adj` idiom. Leftmost-first needs a priority-ordered residual list and a dedup that keeps first-by-priority, which replaces that idiom with a new one. Slice 1's only consumer counts hits and is indifferent. All 10 lazy-quantifier sites in the census are capture-bearing and therefore slice 2's, so the decision is taken where its evidence is. This is scoped to E173. It rules on nothing outside it. |
| 5 | Does `pat-cmp` passed to `list-sort` trip the value-poison rule? | **RESOLVED. No.** | `docs/definitions/totality.md:105-107` poisons a *recursive* definition used as a value. The tree's dodge is a non-recursive wrapper over the recursive worker, `str-cmp` over `su-cmp-bytes` at `lib/prelude/string.chiral:91-92`, and `lib/typing/row-infer.chiral:103-104` is a live caller passing exactly that pair into `list-dedup-adj` and `list-sort`. `pat-cmp` copies the shape. |
| 6 | A text bank is owed | **RESOLVED. Discharged.** | `docs/banks/text.md` exists and homes this element as shard D. What it owes on the way out is a state flip on that one row (§4 step 7). |
| 7 | *(new here)* `find-all` over n start offsets is n anchored passes, which is the defect the element exists to remove | **RESOLVED. One pass; a thread carries its start.** | Forced by [[arcs/text-tools-arc]] REQUIREMENT 1 and by the measured motivation the arc quotes: *"31 passes over 7 MB where one pass would do… the algorithm is the cost, not the compiled code."* Restarting an anchored `run-from` at every offset is n passes and is worse than the 31 it replaces. §4 step 3 carries the shape. |
| 8 | *(new here)* `lib/text/` has no row in `MAP.md`'s tree | **RESOLVED. The change plan adds it.** | `MAP.md` is the tree contract, so a directory absent from it is absent from the tree. §4 step 1. |

### Why decision 1 is settled and not an author call

The fork asks whether `Pat` is a compile-time artifact or a runtime value. Three
facts close it, and each is independently sufficient.

1. **A pattern in the corpus is built from `argv`.** `tools/pack/pack.py:130-133`
   builds its element-id probe as `rf"\b{p}0*{n}{sfx}\b"` from an id that
   arrives on the command line (`pos = [a for a in sys.argv[1:] …]`,
   `tools/pack/pack.py:692`, reaching the builder at `:419`). `pack.py` is
   inside E173's scope: `docs/arcs/zero-python-arc.md` puts it behind this
   element, and the census counts 36 `re.` sites in it. A pattern set fixed
   before the program runs cannot express that site, so REQUIREMENT 3 (the
   coverage table holds) fails on the pack-time arm.

2. **A `data` sum is a runtime value in this language, and there is no staging
   construct that would make one otherwise.** The example's move 1, which
   passed its audit, makes `Pat` a closed `data` sum so that a malformed
   pattern has no representation. `reflect-typed`, the staged-metaprogramming
   module, is design-tier in `docs/modules/module-map.md` and has no home under
   `lib/`. The pack-time arm therefore needs machinery the tree does not have,
   which is a different question from choosing between two shapes it does.

3. **Staticness buys no totality.** `pd` recurses only on strict subterms of
   `Pat` and proves under the structural rule with no measure
   (`docs/definitions/totality.md:46-58`). The driver steps `i` by exactly `+1`
   under the strict guard `(<i i n)` with `n` passed unchanged, measure `n - i`
   (`docs/definitions/totality.md:80-89`). Both proofs hold for an arbitrary
   runtime `Pat`. What the pack-time arm would buy is a **compile-time constant**
   in the cost rather than a bound in terms of an input, and `PRINCIPLES.md` §2
   asks for the second: *"exact cost is undecidable, so the type carries an
   over-approximate bound, not an exact predictor."* REQUIREMENT 1 says
   *bounded in its input*, and `pat` is an input.

Pointing the same way, without being needed: [[banks/text]] `:121-123` records
that `PureFn` is closed at six constructors, that a new text step means editing
`prog/manas/core/flow.chiral` (the sum is declared at `:103`) and recompiling,
and that **opening that wall is D's second job**. A compile-time-fixed pattern
set does not open it.

**What would have made this author-tier.** If the corpus had no runtime-built
pattern, and the language had a staging construct, then "specialize each pattern
at pack time" and "carry a `Pat` value" would be two coherent shapes with a taste
question between them. Neither antecedent holds.

**The cost the run-time arm owes, and where it is paid.** The bound
`|PD(r)| <= ‖r‖ + 1` is enforced by a call to `norm`, in code. The type does not carry it.
Carrying it in the type wants a refinement over the live set's length, which
[[pattern-boundary-sums]] names as the right instrument for a bound. Nothing in
the tree carries a refinement of that shape today. Recorded as residue in §6
with the home **nobody's yet**, and made checkable in §5 as G4 with mutant M2
rather than left as a comment.

## 4. Change plan (ordered, commit-sized)

**Build-rule status, stated once.** Every step below touches `lib/` or `prog/`,
so [[working-discipline]]'s rule applies: build-new, test, promote, nothing
replaces itself in place. **No step adds a module to the compiler's closure.**
`prog/compiler.prog` does not import `text/matcher` and will not, so the blob
built from `lib:prog` is unchanged and no promotion and no byte-compare is owed.
That is the E158 commit-4 disposition for `protocol/render-doc`, and §5 G8 makes
it a checked row instead of an assumption.

### Step 1 — the directory, the module, the tree contract
- **Target:** `lib/text/matcher.chiral` (new), `MAP.md`
- **Change:** create the file with the module header the shelf uses,
  `(module text/matcher (cat A) (alt upper))`, matching
  `lib/prelude/list.chiral:12`. Imports: `prelude/prelude`, `prelude/list`,
  `prelude/ord`. Add one row to `MAP.md`'s `lib/` tree block:
  `text/        matching and spans over Bytes`.
- **Size:** S

### Step 2 — the classes, the assertions, the pattern algebra
- **Target:** `lib/text/matcher.chiral`: `Cls`, `cls-has`, the class constants,
  `Assert`, `Ctx`, `holds`, `Pat`, `nullable`
- **Change:** the example §5 blocks 1 through 4, adopted as written. Bytes, not
  codepoints: a UTF-8 lead byte is `>= 194` and fails every ASCII range, which
  `prog/prose-lint.prog:43-45` already records as the wanted answer.

```chirality
(data Cls () (c-byte (b I64)) (c-range (lo I64) (hi I64))
             (c-any) (c-not (inner Cls)) (c-or (l Cls) (r Cls)))
(data Assert () (a-bol) (a-eol) (a-wordb)
                (a-not-before (c Cls)) (a-not-after (c Cls)))
(data Ctx () (ctx (prev I64) (here I64)))          ; -1 means off the end
(data Pat () (p-nil) (p-lit (s Str)) (p-cls (c Cls)) (p-ast (a Assert))
             (p-cat (l Pat) (r Pat)) (p-alt (l Pat) (r Pat))
             (p-star (inner Pat)))
(declare cls-has (-> Cls I64 Bool))
(declare holds   (-> Ctx Assert Bool))
(declare nullable (-> Ctx Pat Bool))
```

  `Assert` is closed at five because the census found the whole zero-width
  budget the corpus needs: 21 `\b` sites and three one-byte-class lookaround
  sites, zero backreferences. A general lookaround engine is never built.
- **Size:** M (≈ 90 L)

### Step 3 — the derivative, the bound, and the one-pass driver
- **Target:** `lib/text/matcher.chiral`: `pd`, `pd-cat`, `Thread`, `pat-cmp-go`,
  `pat-cmp`, `thread-cmp`, `norm`, `step-set`, `Span`, `at-byte`, `accepts`,
  `find-at`, `find-all`, `count-matches`
- **Change:** `pd` is the example §5 block 5 unchanged; it is the whole
  algorithm and every arm recurses on a strict subterm. The driver is **not**
  the example's: decision 7 replaces the anchored restart with one pass whose
  live set carries each thread's start offset.

```chirality
(data Span   () (span (from I64) (to I64)))
(data Thread () (th (from I64) (pat Pat)))         ; a named nullary type: see below
(declare pd        (-> Ctx I64 Pat (List Pat)))
(declare pat-cmp-go (-> Pat Pat Ord))
(declare pat-cmp    (-> Pat Pat Ord))              ; non-recursive wrapper, decision 5
(declare thread-cmp (-> Thread Thread Ord))        ; compares the pat field ONLY
(declare norm      (-> (List Thread) (List Thread)))
(def norm (lam (ts) (list-dedup-adj Thread thread-cmp
                      (list-sort Thread thread-cmp ts))))
(declare find-all  (-> Pat Bytes (List Span)))
```

  **`Thread` is a `data` and not `(Pair I64 Pat)`.** `list-sort` takes its
  erased type argument explicitly at the call site
  (`lib/typing/row-infer.chiral:103-104` passes `Str`), and E100 exists because
  multi-parameter type application at a call site is its own element. A named
  nullary type sidesteps that and carries the field names besides.

  **Why the pass stays bounded.** New threads are appended, so starts run
  non-decreasing along the live list; `list-sort` is stable and
  `list-dedup-adj` keeps the first of each run, so deduping on the `pat` field
  alone keeps the **least start** per distinct residual. The set is therefore
  held at `‖pat‖ + 1` and the earliest start wins, which is leftmost-longest
  (decision 4) falling out of the bound rather than being bolted beside it.

  **The arrow, stated honestly.** States visited is `O(n × ‖pat‖)`. Work per
  state adds `pd` over each live thread and one sort, so bytes-to-work is
  `O(n × ‖pat‖² log ‖pat‖)`. Linear in the input and independent of how many
  needles a caller folds into one `p-alt`, which is the property REQUIREMENT 1
  and the 2.4x motivation both ask for.

  `find-at` keeps the example's anchored entry, returning `(Maybe Span)` per
  decision 2. The `-1` sentinel survives in exactly one place, `at-byte`, where
  it means *off the end of the buffer* and is a byte-valued reading rather than
  a which-of-N classification.
- **Size:** L (≈ 80 L)

### Step 4 — the line-state pass
- **Target:** `lib/text/matcher.chiral`: `LState`, `line-step`, `blank-spans`
- **Change:** `vt-parser`'s `PState` idiom (`lib/protocol/vt-parser.chiral:11-20`)
  with two states. A line whose first non-blank content is a run of three backticks toggles `ls-prose` / `ls-fence` and the
  toggling line is itself never scanned, which is what the awk baseline does at
  `tools/prose-lint/prose-lint.sh:76-79`. `blank-spans` replaces an inline span
  with **spaces of the same length**, so an offset found on the blanked copy is
  still valid on the original. That is the length-preserving rule
  `lib/prelude/string.chiral:96-99` already states for the ASCII case fold.

```chirality
(data LState () (ls-prose) (ls-fence))
(declare line-step   (-> LState Str (Pair LState Bool)))   ; snd: scan this line?
(declare blank-spans (-> Str Str))
```
- **Size:** M (≈ 35 L)

### Step 5 — the consumer: `prog/prose-lint.prog`
- **Target:** `prog/prose-lint.prog`: `n-antithesis`, `n-copula`, `n-slop`,
  `n-throat`, `n-connective` (`:105-121`), `scan-doc` (`:143`),
  `compile-main` (`:181`)
- **Change:** each check becomes one `Pat` built by constructor application, so
  the five `cons` chains collapse into five `p-alt` trees; `scan-doc` runs
  `line-step` over the lines and `count-matches` once per check per line instead
  of `str-find-from` once per needle over the whole buffer. The three
  `NOT-CHECKED` rows at `:186-188` become counted rows. Import `text/matcher`.
- **Size:** M

### Step 6 — the gate
- **Target:** `tools/test/matcher.sh` (new), `tools/test/samples/e173_matcher.prog`
  (new), `tools/test/run-tests.sh`
- **Change:** §5's rows and mutants. Register as
  `run_phase 19 "the total matcher (E173 pd + norm)" matcher.sh`, following the
  `run_phase 18` line; the runner's guard already fails a phase whose script is
  missing, so a vanished gate cannot report ok.
- **Size:** L

### Step 7 — the state, on the way out
- **Target:** `docs/banks/text.md` shard D row, `docs/definitions/status-ledger.md`,
  `docs/examples/INDEX.md`, `docs/arcs/text-tools-arc.md`
- **Change:** flip shard D from `design` to built-for-slice-1 with the measured
  line count; add the rung E173 reached to the status ledger; flip the INDEX row
  to `implemented` with the date and what was measured; repoint the arc's P1
  sketch signature, which reads `find-all : Ctx -> Pat -> Bytes -> (List Span)`
  and carries a `Ctx` argument that step 3 derives from `(bs, i)` instead.
- **Size:** S

### Slice 2, scoped and not planned here
Slice 2 is tagged derivatives for the 77 capture sites, inside E173. Its step 1
is the classification decision 3 names, and its shape stays open until that
measurement exists. It mints no element and this SPEC does not plan it.

## 5. Conformance gate

- **Golden behavior.** `prog/prose-lint.prog` and the awk implementation at
  `tools/prose-lint/prose-lint.sh:75-98` produce the **same per-check totals**
  over the same file list, for all eight checks, including the three the native
  tool prints as NOT-CHECKED today. That is
  [[arcs/zero-python-arc]] REQUIREMENT 3 (each replacement verified against the
  tool it replaces, on the same inputs) applied to this element.

  The comparison is **differential and run in the same invocation**, against the
  awk tool live. `.planning/PROSE-BASELINE.tsv` is frozen at 21,456 hits across
  475 files on 2026-08-31 and `.planning/protocol/tone.md` records it as
  predating the consolidation and naming three paths that moved, so a gate
  against those numbers would be measuring a corpus that no longer exists.

- **Tests to add.** `tools/test/matcher.sh` + `tools/test/samples/e173_matcher.prog`,
  run as **Phase 19**. Rows, each read off emitted output:

  | row | asserts |
  |---|---|
  | G1 | `cls-has` at both edges of every class constant: 47/48/57/58, 64/65/90/91, 96/97/122/123, and byte 194 outside every ASCII class |
  | G2 | `nullable` on all seven `Pat` arms, both `Ctx` windows |
  | G3 | the bound holds: `(p-star (p-cls cls-lower))` over 100 lower bytes keeps the live set at 2 at every step |
  | G4 | the bound is `norm`'s: with `norm` neutered the same input drives the live set past `‖pat‖ + 1` |
  | G5 | `find-all` over the five prose-lint patterns on a fixed fixture equals the awk counts for the same fixture |
  | G6 | leftmost-longest: overlapping candidates return the earliest start and the longest end |
  | G7 | the line pass: fenced and inline-span lines match the awk `fence` toggle's skipped set, and `blank-spans` is length-preserving |
  | G8 | the blob from `chirality_blob_file "lib:prog" prog/compiler.prog` is **byte-identical** before and after, so `text/matcher` is outside the compiler's closure and no promotion is owed |
  | G9 | wall clock: the chirality tool and the awk tool timed back to back on the same file list in the same run, ratio `<= 1.0`. The native tool is 2.4x slower today, and removing the 31 passes is the stated reason for the element |

  Mutants. The harness is **not** `tools/test/mutant.sh`. That one mutates a
  file, rebuilds `prog/compiler.prog`'s blob and asserts the mutant compiler
  differs from the base (`mutant_differs`, `tools/test/mutant.sh:125`, checked
  at `:208`). G8 says `text/matcher` is outside that closure, so a mutation of
  it builds a byte-identical compiler and the harness scores it INERT instead of
  convicting a row. The mechanism for a module outside the closure is Phase 17's,
  on the same E158 commit 4 precedent G8 already cites: a scratch `lib/` copied
  with `cp -a`, mutated in place with `sed -i`, refused if the mutation changed
  nothing, and the fixture compiled against that tree
  (`tools/test/render-doc.sh:131-142`, driven at `:315-318`). `matcher.sh`
  carries its own copy of that helper.

  | mutant | mutation | convicted by |
  |---|---|---|
  | M1 | `a-bol` loses its offset-0 case | G7 |
  | M2 | `norm` becomes the identity | G4, G3 |
  | M3 | the `p-star` arm of `pd` recurses into `(p-star q)` instead of rebuilding it | `chirality check` refuses the module |
  | M4 | `find-at` keeps the first accept instead of the longest | G6 |
  | M5 | `thread-cmp` compares the `from` field as well as `pat` | G6 |
  | M6 | `c-range` uses `<i` at the high edge | G1 |
  | M7 | `blank-spans` deletes a span instead of blanking it | G7 |
  | M8 | `nullable` returns false on the `p-star` arm | G2 |
  | M9 | `find-all` reports overlapping matches instead of resuming at a match's end | G5 |
  | M10 | a compiler-closure module gains `(import "text/matcher")` | G8 |
  | M11 | the driver restarts the anchored `find-at` at every offset instead of carrying threads | G9 |

  M8 through M11 exist because `docs/definitions/testing-floors.md:261` requires
  every row to name a mutant that is run, and G2, G5, G8 and G9 named none. M11
  is the one that matters most: it is the n-pass shape decision 7 rejects, it is
  correct on every other row, and G9 is the only row that can see it.

- **Green line:** suite **303 passed, 0 failed** (last measured, recorded at
  `records/baseline-alignment.md:147`) → ≥ 303 plus Phase 19's assertions, with
  Phases 1 through 18 unchanged at their recorded counts. `ledger-lint` no worse
  than its measured baseline: A(6) B(5) C(1) F(27) G(77) I(1) R(130) T(1), with
  H and M vacuous.

- **Done when:** Phase 19 is green with all seven mutants convicted, the awk and
  chirality per-check totals agree on all eight checks in one differential run,
  and the blob is byte-identical across the change.

## 6. Residue & links

- **Deliberately unbuilt:**
  - **Captures / tagged derivatives, and leftmost-first semantics.** Slice 2 of
    E173, gated on decision 3's classification of the 77 sites.
  - **The state-set bound carried in a type** rather than by a call to `norm`.
    Home: **nobody's yet**. It wants a refinement over the live set's length and
    the tree carries no refinement of that shape.
  - **Counted repetition `{n,m}`.** Expanded to `p-cat` chains at construction.
    19 sites, all with small literal bounds. No constructor is owed.
  - **A byte-set `Cls` constructor over a 256-bit bitmap.** A pure speedup
    that changes no arm of `pd`. Home: this module, when a measurement asks.
  - **Opening `PureFn`** (`prog/manas/core/flow.chiral:103`), which
    [[banks/text]] calls D's second job. Outside slice 1 and unscheduled.
  - **Shards E (score), F (edit script) and G (stable address)** of
    [[banks/text]], all unnumbered. [[arcs/text-tools-arc]] has no reserved element
    block, `docs/decisions/decision-lane-split.md` reserves E184-E189 and
    E190-E195 for other lanes, and the block is already an open row in
    `records/author-calls.md`. Nothing here is deferred to an unminted element.
  - **The entry shape** (one `.prog` per tool, or one multi-call entry). The arc
    states it does not settle this and does not need to; the library is the
    artifact.

- **Follow-on:** slice 2 of this element. Downstream, [[arcs/zero-python-arc]]
  unblocks the 3,560 LOC it puts behind E173, and E148 and E150 remain the other
  two gates.

- **Related:** [[E173-total-matcher]] · [[banks/text]] (shard D) ·
  [[arcs/text-tools-arc]] (P1) · [[arcs/zero-python-arc]] (REQUIREMENT 3) ·
  [[pattern-boundary-sums]] (decision 2) · [[totality]] (the measure that picks
  the algorithm) · [[working-discipline]] (the build and deferral rules) ·
  [[E148]] · [[E150]] · [[banks/verification]] (a check is a matcher plus an
  authority) · [[status-ledger]]
