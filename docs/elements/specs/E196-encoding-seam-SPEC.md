---
element: E196
slug: encoding-seam
title: "**`Encoding`: the seam between a continuous value and a spike train**"
kind: BUILD-PROPER
example: examples/E196-encoding-seam.md
status: audited
updated: 2026-09-05
---

# E196 SPEC · **`Encoding`: the seam between a continuous value and a spike train**

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

Every figure below was measured in this run, off-tree, against a copy of `lib/`
and `prog/` and the tracked `bin/chirality-bin`, 1,188,216 bytes. A concurrent
session promoted a binary at `8d4009d` while this run was open; the promoted
binary is byte-identical to `af08fed`'s (`cmp` clean), and the whole sweep and
both probes were re-run on it with output identical to the first pass.

## 1. Deliverable

- **After this runs:** `prog/unit/encoding.chiral` declares the closed `Encoding`
  sum, the `DecodeR` result sum, one total `enc-decode` over all three arms and
  one encoder per arm; `prog/e196-encoding-sweep.prog` sweeps twenty
  configurations and prints twenty pinned lines; `tools/test/encoding.sh` judges
  those lines and four mutants by hand.
- **Non-goals:** any neuron model, any population, any projection, any execution
  discipline, any consumer of a spike train. Those are `unit-lane/N15` through
  `N23` and none is minted. No file under `lib/` moves, so the element owes no
  fixpoint. §5 measures that claim rather than asserting it.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none. `records/conformance-map.md` carries zero
  rows naming E196; the element postdates the map snapshot. The ledger row reads
  `design` and the catalog opens `Not built`, which agree.
- **Live code:** nothing to compose with, and that was measured twice. The
  example's grep of `lib/` and `prog/` for `spike`, `neuron`, `tuning`,
  `population vector` and `first-spike` returned zero files, and the arc's census
  at `471f688` moved none of the roster's 37 `origin: new` rows.
  [[banks/unit]] §2 refracts the concept into nineteen shards, A through S, and
  no shard is an encoding: shard B is the `Ty`/`Shape` payload type and shard G
  is the `Backend` model crossing, both above this layer.
- **What the change composes with:** `prelude/prelude` for the fourteen integer
  ops at `lib/prelude/prelude.chiral:58-71` and `i64->str`, `prelude/list` for `List`, `ports/stdio` for `put`. The
  module binds no extern of its own and every function in it is `->`.
- **True delta:** one new module, one new root, one new gate script. Three files,
  all new, none under `lib/`.

## 3. Decisions

Every open question from the example §6, dispositioned.

| # | Question | Disposition | Rationale / owner |
|---|---|---|---|
| 1 | `Latency`'s scale | **RESOLVED: `Latency` gains `max`** | [[decisions/decision-display-numerics]] rules that the scale rides the type and that a mixed-scale arithmetic is a type error. Measured below: with `max` on the arm, `Latency` and `Rate` obey one law over one domain |
| 2 | `I64` or `DecodeR` | **RESOLVED: `DecodeR`, and `enc-decode` returns it** | The boundary-sums directive, applied by [[banks/unit]] shard F's `bind-miss` and shard S's `accept-gate`: a reason that exists at the decode is a value. Measured below: the repair moves 727 of 1,001 population readings and one of every 101 latency readings out of the numeric channel |
| 3 | The refinement on `Population`'s fields | **DEFERRED to the implementation run's documented precondition, and priced here** | The bound is `size * max-tuning * max-count < 2^63` and the failure past it is measured below. `refine` on a constructor is machinery this element has not priced and the arc has no row for it, so the deferral rule forbids minting one to hold it |
| 4 | The array type | **DEFERRED, and it stays `(List I64)`** | A length-indexed pair makes the `tuning`/`count` mismatch untypeable and costs dependent machinery. `unit-lane/N14` (`ty-eq` shape-equality) is the arc row that layer sits behind and it is `unminted`, so nothing is deferred to a name that does not exist: the residue is recorded in §6 with no element attached |
| 5 | The directory | **RESOLVED: `prog/unit/encoding.chiral`** | `MAP.md`'s tiers table names `prog` in the universal tier beside seven `lib/` directories and the base shelf, and leaves `typing`, `surface` and `module` in the language-implementation tier. `MAP.md:122` reads `prog/` as what chirality ships, as distinct from what it is. An `Encoding` sum for a neuron lane is application-domain data and belongs to neither `lib/` tier. Every shard [[banks/unit]] refracts already sits under `prog/`. Two mechanical facts follow: `MAP.md` lists twelve `lib/` directories against thirteen on disk, so a `lib/unit/` would widen a gap this element does not own, and `MAP.md` carries no `prog/` subdirectory listing, so `prog/unit/` is invisible to it. `lib/manifest/` is the counter-precedent and it does not reach: a manifest is module-system machinery, which is the universal tier |
| 6 | The gate's phase number | **DEFERRED to the standing author call, *Which suite phase number a new gate takes*, in `records/author-calls.md`** | `tools/test/encoding.sh` declares itself out with `# not-a-phase:` and a reason, the route `crypto.sh`, `tal-check.sh`, `apply-word.sh`, `capture-fields.sh`, `defunc-blame.sh` and `apply-spine.sh` already take. Measured below: the declaration keeps `registration.sh` G2 and G4 green and the gate runs by hand |

**Decision 1, and what adding the field costs.** `Latency` as the research states
it decodes onto `[0, window]` while `Rate` decodes onto `[0, max]`, so a caller
holding an `Encoding` cannot know the range without matching on the arm, and a
value whose range differs from the window has no code at all. With `max` on the
arm, encode is `ref + (window - v*window/max)` and decode is
`(window - (first-spike - ref)) * max / window`. Where `max = window` the two
divisions cancel and the arithmetic is the example's, so the exactness result
survives. Where `max > window` the arm becomes lossy exactly as `Rate` is. The `maxerr`
figures below are `Rate`'s at the same `window` and `max`, 3 at `w=100 m=400` and
16 at `w=16 m=255`. The exact counts sit one below `Rate`'s, 100 against 101 and
1 against 2, because `v = 0` decodes to `d-silent` under decision 2.
The alternative, removing `max` from `Rate`, was refused: it deletes the whole
M1 sweep and it does not make the three arms symmetric, because `Population`'s
scale lives in `tuning` under either reading.

**Decision 2, and where the example's 980 went.** Under `DecodeR` a silent window
leaves the numeric channel, so `maxerr` on the sharp population row falls from
980 to 19 and 727 readings are counted as `silent`. The example's figure is
recoverable: mutant M4 below restores `(d-val 0)` in the silent arm and the row
prints `silent=0 maxerr=980`. The same holds on `Latency`, where `v = 0` never
fires: with `(d-val 0)` in the `none` arm the three latency rows print
`exact=101`, `17` and `1025`, which are the example's three figures, and with
`d-silent` they print `100`, `16` and `1024` with `silent=1`. Both reconciliations
were run, and the outputs are in §5.

**Decision 3, the bound and the failure past it.** Four probes, each computing
the real dot product with every unit at its peak count, re-derived on the tracked
binary:

| `size` | max tuning | `k` | numerator | denominator | decode |
|---|---|---|---|---|---|
| 64 | 65,536 | 1,024 | 2,147,451,904 | 65,536 | 32,767 |
| 64 | 2,147,483,647 | 65,536 | 4,503,599,623,241,728 | 4,194,304 | 1,073,741,823 |
| 64 | 1,099,511,627,776 | 16,777,216 | **-520,093,696** | 1,073,741,824 | **-1** |
| 1024 | 1,099,511,627,776 | 16,777,216 | **-8,573,157,376** | 17,179,869,184 | **-1** |

All four reproduce the example's M4 exactly. Row 2 is the realistic ceiling at
0.048828% of `I64`'s 9,223,372,036,854,775,807, so the element needs no high half
and no new numeric primitive. **E189 stays off this element's path and would not repair rows
3 and 4.** At a tuning ceiling of 2^40 and a count of 2^24 a single product is
already past 2^63, and the accumulator overflows as well, which `op-mulhi` does
not address. The guard that belongs here is a bound on the constructor's fields,
which is a refinement on the constructor. `64 * 2,147,483,647 * 65,536` is
9,007,199,250,546,688 and fits; `64 * 1,099,511,627,776 * 16,777,216` is
1,180,591,620,717,411,303,424 and does not.

## 4. Change plan (ordered, commit-sized)

Every step was executed off-tree in this run against a copy of `lib/` and
`prog/`, compiled with the tracked binary, and run. Nothing under the real
`lib/`, `prog/` or `tools/` was touched.

### Step 1: the module
- **Target:** `prog/unit/encoding.chiral`, NEW FILE, ~100 lines
- **Change:** the closed `Encoding` sum with `enc-rate (window count max)`,
  `enc-latency (window ref max first-spike)` and
  `enc-population (size tuning count)`; the `DecodeR` sum with `d-val` and
  `d-silent`; `enc-abs`, `enc-dot`, `enc-sum`, `enc-fired`; one total
  `enc-decode : (-> Encoding DecodeR)` with three arms and no `_`; the four
  encoders `enc-rate-of`, `enc-latency-of`, `enc-tuning`, `enc-counts` and the
  constructor `enc-population-of`. Adapts the example §5 snippet with decision 1's
  extra field and decision 2's result sum. No `(module …)` form, matching the
  `prog/prapanca/` precedent, which carries none.
- **Two syntax facts the example's snippet does not carry**, both measured here:
  `let` binds in the double-paren form `(let ((x e)) …)` that `lib/prelude/list.chiral`
  uses, and `enc-fired` is new, because the `maxfire` column §5 needs did not
  exist in the example.
- ⚑ **A `def`'s type must carry one argument per `lam` binder.**
  `(def enc-latency-of (-> I64 I64 I64 Encoding) (lam (w r m v) …))` fails with
  `load: lambda checked against a non-function type`, because decision 1's fourth
  field gives the encoder a fourth argument.
- **Verified by:** the module resolves under `lib:prog` and compiles inside a
  probe root that decodes one `enc-rate-of`.
- **Size:** M

### Step 2: the sweep root
- **Target:** `prog/e196-encoding-sweep.prog`, NEW FILE, ~95 lines
- **Change:** an `Acc` record carrying `exact`, `silent`, `maxerr` and `maxfire`;
  `acc-step` folding one `DecodeR` into it; `sw-rate`, `sw-lat` and `sw-pop`
  sweeping a whole domain; `row-rate`, `row-lat` and `row-pop` printing one line
  each; `compile-main` running twenty configurations. **It asserts nothing and
  always exits 0**, because a gate that re-derives its own verdict is green under
  any mutant that changes what the verdict says. `prog/e188-apply-spine.prog`
  states that rule for its own R4 and this root follows it.
- ⚑ **The effectful row functions return `Unit`.** `put` is `(=> Str Unit)`, so
  `(def row-rate (=> I64 I64 I64) …)` fails with `load: type mismatch` and
  nothing further. That was the one compile failure in this run and it is
  recorded because the diagnostic names no site.
- **The root lands in Phase 7's census for free.** Phase 7 sweeps
  `grep -rl '^(def compile-main' lib prog`, so the suite compiles this root every
  pass and executes none of it. That is the `compiled` state [[banks/unit]] §2
  defines, one step short of reached, and it is the whole suite claim this
  element may make.
- **Verified by:** G1, then G2 against the golden.
- **Size:** M

### Step 3: the gate
- **Target:** `tools/test/encoding.sh`, NEW FILE
- **Change:** the five rows and four mutants of §5, with the declaration
  `# not-a-phase: E196's number waits on the standing suite-phase-number call in
  records/author-calls.md` at the head. Mutants run over a copied tree, the
  mechanism Phase 17 and Phase 19 use for a module outside the compiler's blob.
- ⚑ **`mutlib` copies `lib/` alone.** `tools/test/render-doc.sh:133` is
  `cp -a "$REPO/lib" "$MUTLIB"` and every mutant target is `lib/`-relative. This
  module sits under `prog/`, so the driver copies `prog/` beside it and points
  the resolver at the copy.
- **Verified by:** `tools/test/encoding.sh` printing `9 passed, 0 failed` over
  G1 to G5 and M1 to M4.
- **Size:** M

### Step 4: the registries
- **Target:** `docs/elements/catalog.md`, `docs/elements/ledger.md`
- **Change:** the catalog and ledger rows both spell
  `Latency { window, ref, first-spike }`, which decision 1 supersedes, and
  neither names `DecodeR`. Repoint both at implementation time, in the commit
  that lands the module, so this step rides in step 1's and opens no fourth
  commit.
- **What holds the rows today:** no `ledger-lint` check reads a catalog row's
  constructor prose. J, K, N and AB pass with both rows unedited and must still
  pass after the repoint, which is what makes the deferral safe and the repair
  owed.
- **Size:** S

**No step touches `lib/` or `prog/compiler.prog`**, so the build rule's
`build-new → test → promote` and its byte-compare do not apply. §5 G5 measures
that rather than reasoning about imports.

## 5. Conformance gate

`tools/test/encoding.sh`, declared out of the dispatch table, run by hand.
**No suite conformance is claimed anywhere**: the sweep root is compiled by
Phase 7 and executed by nothing in `tools/test/run-tests.sh`.

### The golden

Twenty lines, measured on the tracked binary:

```
rate w=100 m=100 domain=101 exact=101 silent=0 maxerr=0 maxfire=1
rate w=100 m=50 domain=51 exact=51 silent=0 maxerr=0 maxfire=1
rate w=255 m=255 domain=256 exact=256 silent=0 maxerr=0 maxfire=1
rate w=100 m=400 domain=401 exact=101 silent=0 maxerr=3 maxfire=1
rate w=32 m=1000 domain=1001 exact=9 silent=0 maxerr=31 maxfire=1
rate w=16 m=255 domain=256 exact=2 silent=0 maxerr=16 maxfire=1
rate w=7 m=255 domain=256 exact=2 silent=0 maxerr=37 maxfire=1
rate w=3 m=100 domain=101 exact=2 silent=0 maxerr=33 maxfire=1
rate w=1 m=100 domain=101 exact=2 silent=0 maxerr=99 maxfire=1
lat w=100 r=1000 m=100 domain=101 exact=100 silent=1 maxerr=0 maxfire=1
lat w=16 r=0 m=16 domain=17 exact=16 silent=1 maxerr=0 maxfire=1
lat w=1024 r=1000000 m=1024 domain=1025 exact=1024 silent=1 maxerr=0 maxfire=1
lat w=100 r=1000 m=400 domain=401 exact=100 silent=1 maxerr=3 maxfire=1
lat w=16 r=0 m=255 domain=256 exact=1 silent=1 maxerr=16 maxfire=1
pop n=8 m=1000 h=20 k=100 domain=1001 exact=8 silent=727 maxerr=19 maxfire=1
pop n=8 m=1000 h=80 k=100 domain=1001 exact=9 silent=0 maxerr=63 maxfire=2
pop n=8 m=1000 h=200 k=100 domain=1001 exact=247 silent=0 maxerr=33 maxfire=3
pop n=8 m=1000 h=400 k=100 domain=1001 exact=38 silent=0 maxerr=91 maxfire=6
pop n=32 m=1000 h=100 k=100 domain=1001 exact=430 silent=0 maxerr=24 maxfire=7
pop n=64 m=65536 h=4096 k=1024 domain=65537 exact=2014 silent=0 maxerr=1028 maxfire=8
```

**Against the example, re-derived rather than copied.** All nine rate rows
reproduce the example's M1 exactly on both columns. Four of five population rows
reproduce M3 exactly. All four M4 probes reproduce. The two divergences are
decision 2's and both are demonstrated to be decision 2's, above: `Latency`'s
three exact counts drop by one apiece into `silent`, and the sharp population
row's 980 becomes `silent=727 maxerr=19`. The `h=80` row and the `maxfire`
column are new here and the example has no figure for either.

**`maxerr <= ceil(max/window)` holds on all fourteen scalar rows**, including the
five latency rows, which is decision 1's evidence: the two arms obey one law once
`Latency` carries `max`. Reached in two rate rows (`w=16 m=255` at 16 of 16,
`w=7 m=255` at 37 of 37) and in one latency row (`w=16 m=255` at 16 of 16). This
bound is measured over this sweep. Proving it is outside the element.

### The rows

| row | the assertion | how it is judged |
|---|---|---|
| **G1** | the sweep root resolves, compiles to a non-empty ELF and exits 0 | the resolver plus `bin/chirality-bin`, then the ELF |
| **G2** | the twenty lines are byte-identical to the golden | `diff` against the checked-in golden |
| **G3** | every scalar row satisfies `maxerr <= ceil(max/window)` | computed in bash from the row's own `w` and `m`, with the golden unread |
| **G4** | at least one population row carries `maxfire >= 2` | read off the golden |
| **G5** | `prog/compiler.prog`'s blob contains no `unit/encoding` | resolve the blob, grep it |

⚑ **G2 and G3 are two claims and the driver runs both.** Pinning
`maxerr=31` asserts equality with 31, which is stronger than
`maxerr <= ceil(1000/32)` on that row and silent about the law. Computing the
bound in the root and pinning the verdict it prints is the shape
`prog/e188-apply-spine.prog` refuses, so both live in bash: G2 is the conviction
and G3 is the law, checked against a formula the driver evaluates from the
configuration. This answers the example's fork by taking neither horn.

⚑ **G4 exists because one row is blind and the golden says which.** With `size`
tuning values evenly spread over `[0, max]`, spacing is `max/(size-1)` and a unit
fires inside a half-width `h`. Silence needs `h` below half the spacing and
overlap needs `h` above it, so **no evenly spaced configuration carries both**.
Measured exhaustively over `max` in 100, 255 and 1000, `size` 3 through 16 and
every `h` up to `max`: zero configurations carry both, and the flip is one step
wide. At `size=8 max=1000`, `h=71` gives 13 silent at `maxfire=1` and `h=72`
gives 0 silent at `maxfire=2`. The limit belongs to `enc-tuning`'s even spacing.
Uneven tuning carries both: `[0, 10, 500, 1000]` at `h=20` measures 912 silent
and `maxfire=2`, so the blind row is a consequence of the tuning constructor this
element ships.
The sweep measures it: the one row with `silent > 0` carries `maxfire=1`, and all
five rows with `maxfire >= 2` carry `silent=0`. A row where one unit fires
decodes to that unit's own tuning value whatever count it carries, so the
`h = 20` row cannot see the tuning curve's shape at all, which M3 below measures.
G4 is what stops the sweep from being reduced to blind rows.

### The mutants

| mutant | change | measured effect |
|---|---|---|
| **M1** rate-window-off-by-one | `Rate` decode divides by `window + 1` | G2 red on all nine rate rows, exact falling to 1 on every one; `maxerr` rises on eight and holds at 99 on `w=1 m=100`. G3 red on five rows: `maxerr` 7 against `ceil` 4, 60 against 32, 29 against 16, 63 against 37, 49 against 34 |
| **M2** latency-drops-complement | `Latency` decode returns `(first-spike - ref) * max / window` | G2 red on all five latency rows, exact 100 → 1, 16 → 1, 1024 → 1, 100 → 1, 1 → 0. G3 red on all five, `maxerr` reaching `max` on each |
| **M3** rectangular-curve | the tuning curve fires a flat `k` inside `h` | G2 red on the five rows with `maxfire >= 2`: exact 9 → 15, 247 → 13, 38 → 7, 430 → 53, 2014 → 115. **The `h = 20` row does not move**, at 8 exact, 727 silent and 19 maxerr either way, which is the blindness G4 guards |
| **M4** silence-is-zero | `d-silent` → `(d-val 0)` in the `Population` arm | G2 red on the `h = 20` row alone: `silent` 727 → 0 and `maxerr` 19 → **980**. This is decision 2's positive assertion, and the figure it restores is the example's |

Each mutant reddens its own arm and leaves the other two arms' rows untouched, so
a reddened row names the arm that broke it.

⚑ **G3 is subsumed on this sweep and is kept anyway.** No mutant reddens G3
without also reddening G2; a fifth mutant doubling `Rate`'s decode was built and
run and it reddens G3 on eight of nine rate rows and G2 on all nine. G3 earns
its keep when a configuration is added to the root later. That row's golden line
is cut by running the code, so a wrong decode is pinned as correct and G2 blesses
it for good. G3 evaluates the law from the row's own `w` and `m` and never reads
the golden, so it convicts a row the pin cannot.

⚑ **G5 sees the needle arrive, measured.** `prog/compiler.prog`'s blob resolves to
820,959 bytes and holds zero occurrences of `enc-decode`, `enc-rate`,
`enc-population`, `DecodeR`, `d-silent`, `Encoding` and `unit/encoding`. Adding
`(import "unit/encoding")` to `lib/typing/diag.chiral` over a copied tree takes
the blob to 824,763 bytes with `enc-decode` at 2 and `unit/encoding` at 3, so the
scan sees the needle arrive. The byte count rides the module's own size and the
needle counts are what the row asserts. This is `tools/test/render-doc.sh`'s G9 plus M11,
applied to a second element. **The element therefore ships under a plain
`chirality run` with no fixpoint obligation.**

### The green line

`tools/test/run-tests.sh` gains no phase and its thirteen dispatch lines are
unchanged. `tools/test/registration.sh` was run against a copied `tools/test/`
carrying the new script: **9 passed, 0 failed**, base verdict
`G1:ok G2:ok G3:ok G4:ok G5:ok G6:ok`, with the PEND list going from 10 of 23 to
**11 of 24**. Baseline `9 passed, 0 failed` at 10 of 23, measured on the live
tree in this run.

`ledger-lint` baseline at the start of this run: checks I and R fail, at 1 and 41
findings, both predating it; H and M vacuous; everything else clean. At the close
R stands at 1, because the concurrent session repointed forty citations at
`0d7ebb5`. This SPEC adds no finding to either check, and J, K, N, V and AB stay
green. Re-measured at `98a9450`: `ledger-lint: clean`, every check at zero, H and
M still vacuous, and N carrying its one KNOWN non-failing E52 note.

**Done when:** `tools/test/encoding.sh` prints `encoding: 9 passed, 0 failed`
over G1 to G5 and M1 to M4, `tools/test/registration.sh` still prints
`9 passed, 0 failed`, and `ledger-lint` reports no check newly failing.

## 6. Residue & links

- **Deliberately unbuilt, and each with its home:**
  - **The refinement on `Population`'s fields** (decision 3). The bound and the
    failure past it are measured in §3 and the constructor carries a documented
    precondition. `refine` on a constructor field has no arc row and no element,
    so nothing is deferred to a name that does not exist.
  - **The length-indexed `tuning`/`count` pair** (decision 4). `(List I64)` pairs
    two lists whose lengths only `size` relates. `unit-lane/N14` is the arc row
    the shape-equality half sits behind and it reads `unminted`.
  - **`enc-scale : (-> Encoding I64)`**, a total reader for the arm's own
    ceiling. Decision 1 makes it derivable on every arm. No consumer exists, so
    it is written when one does.
  - **The leaky-integrator running decode**, `Rate`'s alternative in the research,
    which needs the time parameter of `unit-lane/N7`. `unminted`.
  - **The suite phase number** (decision 6). The standing call in
    `records/author-calls.md` covers it and the row is already stale against the
    live count, so this run adds no paragraph to it and states the measurement
    here: 11 of 24 scripts outside the dispatch table once this gate lands, of
    which seven wait on that one number and four declare out for structural
    reasons.
- **Follow-on:** none minted by this run. `unit-lane/N10` through `N42` are the
  arc's remaining rows and every one reads `unminted`.
- **Related:** [[E196-encoding-seam]], [[arcs/unit-lane-arc]] rows `unit-lane/N8`
  and `unit-lane/N9`, [[banks/unit]], [[decisions/decision-display-numerics]],
  [[decisions/decision-lane-split]], [[working-discipline]]. E189 stays a
  separate, unowned element, measured off this element's path in §3.
