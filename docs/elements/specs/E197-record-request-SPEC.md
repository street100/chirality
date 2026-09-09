---
element: E197
slug: record-request
title: "**`RecordRequest`: what a run is asked to record, as a value**"
kind: BUILD-PROPER
example: examples/E197-record-request.md
status: audited
updated: 2026-09-05
---

# E197 SPEC · **`RecordRequest`: what a run is asked to record, as a value**

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

Every figure below was measured in this run, off-tree, against a copy of `lib/`
and `prog/` and the tracked `bin/chirality-bin`, 1,188,216 bytes, 2026-09-05
10:13. The module, the sweep root, six mutants, four refinement probes and both
halves of the fixpoint scan were compiled and executed. Nothing under the live
`lib/`, `prog/` or `tools/` was touched.

⚑ **A concurrent session left a newer, uncommitted binary in the tree while this
run was open**, 1,237,368 bytes against HEAD's 1,188,216, and the two are not
byte-identical. Every claim here was re-run on both. The twenty golden lines
reproduce byte-identically under each, and the four refinement probes give the
same four verdicts under each. The figures below are stated against the tracked
binary, which is HEAD's.

## 1. Deliverable

- **After this runs:** `prog/unit/recording.chiral` declares the closed
  `RecordRequest` sum with a `(refine I64 (> 0))` on `sample-every`, the
  `RunShape` a request is priced against, the `VolumeR` result sum, one total
  `rr-samples` over all three arms, `rr-interval : (-> RecordRequest (Maybe I64))`
  and `rr-fields`; `prog/e197-recording-sweep.prog` sweeps twenty configurations
  and prints twenty pinned lines; `tools/test/recording.sh` judges those lines,
  three compile probes and six mutants by hand.
- **Non-goals:** the trace itself, which is `unit-lane/N11` and unminted; any
  population, any projection, any producer of a spike, any storage backend; the
  aggregation of a trace into rate bins, which needs a trace to aggregate. No
  file under `lib/` moves, so the element owes no fixpoint. §5 measures that
  claim on both halves instead of asserting it.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none. `records/conformance-map.md` carries zero
  rows naming E197; the element postdates the map snapshot. The ledger row reads
  `design` and the catalog opens `Not built`, which agree.
- **Live code:** nothing to compose with. The example's grep of `lib/` and
  `prog/` returned zero files for `RecordRequest`, `record-spikes`,
  `sample-every` and `sampling`, and the 37 files carrying `membrane` are all
  E12's effect membrane (`lib/typing/effects.chiral:1`), which this element does
  not touch.
- **The pattern this mirrors, and does not modify.** [[banks/unit]] shard K is
  `RunManifest`, `ExpertCall` and `RawCall`, the bounded record beside its
  unbounded sibling (`prog/prapanca/core/types.chiral:131`, `:152`, `:166`).
  E197 is that same split one layer down and it writes into neither type:
  `RunManifest`'s fifteen fields are the golden manifest's fifteen top-level
  keys, and `RawCall`'s own comment says the split exists so the manifest's
  round-trip schema stays unchanged. No shard among A through S is a recording
  request, so nothing here is a respec.
- **What the change composes with:** `prelude/prelude` for `*`, `/`, `=i` and
  `i64->str`, and `ports/stdio` for `put`. The module binds no extern of its own
  and every function in it is `->`, which files it under VAL the way E196 is
  filed. The sweep root needs no `prelude/list`.
- **True delta:** one new module, one new root, one new gate script. Three
  files, all new, none under `lib/`.

## 3. Decisions

Every open question from the example §6, dispositioned. Two carried evidence
from the EXAMPLE audit; both were re-measured here and one of the two came back
narrower than the audit left it, which decision 2 records.

| # | Question | Disposition | Rationale / owner |
|---|---|---|---|
| 1 | `population` as `Str` against a `Population` type | **DEFERRED, and it stays `Str`** | `unit-lane/N17` is the `Population` construct and it reads `unminted` at L4. E197 is an L2 row, so waiting on N17 makes a lower layer block on a higher one. The in-tree precedent is `Expert`'s `sees`/`returns` (`prog/prapanca/core/types.chiral:63`, "prose descriptors here (typed I/O is target work)"), whose closing row `unit-lane/N13` is also unminted. Nothing is deferred to a name that does not exist: N17 is a roster row with no element, so the residue is recorded in §6 with no element attached, on E196 decision 4's precedent |
| 2 | The refinement on `sample-every` | **RESOLVED: `(refine I64 (> 0))` ships, and the engine's reach is measured here rather than assumed** | Measured below: the predicate is decided for a literal and for a value already at the refined type, and refused for every computed argument including `(+ 20 5)`. That is decidable enough to ship and it costs the sweep one configuration, which §5 converts into a stronger gate row. The example's three-way choice for the interval-exceeds-the-run case is closed by decision 3's `v-empty`, so no smart constructor and no stated precondition is owed |
| 3 | `I64` or `VolumeR` | **RESOLVED: `VolumeR`, with `v-ok` and `v-empty` and no third arm** | `docs/definitions/pattern-boundary-sums.md` is the directive and E196 applied it to `DecodeR` (`prog/unit/encoding.chiral:63`). A request that commissions nothing is a reason that exists at the pricing. `v-unbounded` is dropped with its cost measured below: detecting the wrap needs an overflow primitive this tree has no binding for, and the wall sits past any writable sample count |
| 4 | Whether `rr-samples` belongs to E197 | **RESOLVED: it ships, and the element covers `unit-lane/N10` plus one law the roster has no row for** | The arc's own reason for pairing N8 and N9 applies here verbatim: a constructor's fields and its arithmetic constrain each other, and splitting them settles one against a guess at the other. Measured below, both of this element's remaining decisions are consequences of the pricing arithmetic and neither survives without it. The cost is stated and not hidden: the roster carries no volume-law row, the mint is the arc session's event, and this run does not open one. §6 carries it |
| 5 | What the digest becomes | **DEFERRED to `unit-lane/N11`, which is unminted, so §6 holds it with no element attached** | E197 ships `rr-fields` and states the finding it rests on. `RunManifest` cannot absorb the digest: its fifteen fields are the golden's fifteen keys and `RawCall`'s comment names the schema that protects. Whether the digest becomes a field on N11's trace type, a separate small record, or `rr-fields` and nothing more is N11's answer to give |
| 6 | The gate's phase number | **DEFERRED to the standing author call, *Which suite phase number a new gate takes*, `records/author-calls.md:30`** | `tools/test/recording.sh` declares itself out with `# not-a-phase:` and a reason, the route `crypto.sh`, `tal-check.sh`, `apply-word.sh`, `capture-fields.sh`, `defunc-blame.sh`, `apply-spine.sh` and E196's `encoding.sh` already take. Phases 1-7, 13-20 and 24 are taken, 8-12 stay owed to unported old-tree phases, [[decisions/decision-lane-split]] reserves 21-23 for Lane B, and this lane holds no band. Measured below: the declaration keeps `registration.sh` G1 through G6 green. This element does not pick a number, and it adds no paragraph to a row whose own count is already stale |

**Decision 2, and the reach the engine actually has.** The EXAMPLE audit measured
that `(record-membrane "p" 25)` compiles while `0` and `-1` are refused with
`load: cannot prove refinement`. That reproduces here, and it is only half the
answer, because the sweep root does not construct requests from literals at the
constructor. It passes an interval down through a row function. Four probes on
the tracked binary, each a whole root compiled from the module above:

| the argument reaching `sample-every` | verdict |
|---|---|
| literal `25`, through a parameter typed `I64` | **`load: cannot prove refinement`** |
| literal `25`, through a parameter typed `(refine I64 (> 0))` | compiles, prints 40000 |
| literal `0` and literal `-3`, refined parameter | **`load: cannot prove refinement`** |
| `(+ 20 5)`, refined parameter | **`load: cannot prove refinement`** |

Two facts follow and both shape §4. The refinement does not survive an ordinary
`I64` seat, so every caller between the literal and the constructor carries the
refined type in its own signature; `row-mem` and `row-wgt` are declared
`(=> I64 I64 I64 I64 (refine I64 (> 0)) Unit)` for that reason. And the engine
decides literals only, so `(+ 20 5)`, whose value is 25, is refused alongside
`0`. The predicate closes the constructor against a written interval and says
nothing about one computed at run time, which is the same wall
`C1C2-style-round-trip-SPEC.md` measured on `face-join`.

⚑ **The refinement costs the sweep the negative-interval row, and buys a better
one.** The example's golden line 19 is `sample-every = -3` at `samples=-333000`,
the row that carried M2's negative volume and both of the `/` rounding rules on
one line. It cannot be constructed against this declaration, so the golden is
twenty lines and not twenty-one. What replaces it is stronger than a pin: gate
row R2 in §5 compiles three probe roots and asserts that `0` and `-3` are
refused while `25` is accepted. A pinned negative volume records a defect the
type now makes unwritable; R2 records the refusal itself.

**Decision 3, and what the second arm buys, measured.** With the refinement in
place, a zero divide and a negative volume are gone at compile time, so
`VolumeR` is left holding one case: a request that commissions nothing. On an
`I64` return that case prints `samples=0`, and `0` is a legitimate volume
elsewhere in the type: a spikes request over a population at `rate-milli = 0`
prices honestly at zero, so one integer carries two unrelated facts. Mutant M6
in §5 measures the collision on the live sweep. It restores `(v-ok v)` in place
of the `v-empty` test and line 15 moves from `samples=empty xspk=empty` to
`samples=0 xspk=0`, at which point line 15's `xspk` reads identically to line
16's, whose `xspk=0` is a true quotient. That is `DecodeR`'s `d-silent` one
layer down and it is E196 decision 2's shape.

**Decision 3's third arm, and the reason it stays unbuilt.** `v-unbounded` would report
the `I64` wrap that golden line 20 carries. Detecting it before the multiply
needs either a high-half product, which is `unit-lane/N1` (`op-mulhi` bound to a
surface extern, `unminted`) and which E196 measured off its own path for the
same reason, or a division pre-check on every factor, which `RunShape`'s
unrefined fields do not support. The wall was measured in the example at
1,000,000,000,000,000,000 samples for a million neurons at a million synapses
each sampled every tick for a million ticks, which is an exabyte at one byte per
sample. The element pins the wrap as observed behaviour on golden lines 19 and
20 and guards nothing, and §6 records that with its home.

**Decision 4, and the two measurements the call rests on.** The EXAMPLE audit
refuted the pre-run's argument for including `rr-samples`, which was that the
sum is unconvictable without it. That refutation reproduces here exactly: mutant
M3 touches `rr-interval` alone, moves not one `samples=` figure in the file, and
still reddens four rows. So the sum's structural claim is gateable with
`rr-interval` and `rr-fields` and no pricing. The call is therefore made on the
other side of the ledger, and on evidence this run took:

- **Without a divide, the refinement guards a field nothing computes with.**
  `sample-every` is still *read* without the pricing: `rr-interval` returns it
  and the sweep prints it in the `ivl=` column, which is what M3 convicts
  through. What goes is the arithmetic. `(> 0)` was bought to close M2's zero
  divide and M2's negative volume, and both are the divide's; against a value
  that is only carried and printed, an interval of `0` or `-3` costs the element
  nothing. Measured: dropping the refinement from the constructor and from
  `row-mem` and `row-wgt` leaves all twenty golden lines byte-identical. So
  decision 2's whole apparatus, a refined constructor field threaded through
  every caller's signature, constrains no behaviour a pricing-free E197 would
  ship, which is what the sixth operating principle cuts.
- **Without a pricing result, `VolumeR` has no reason to exist at all.** Decision
  3 is a decision about `rr-samples`'s return type. Deleting the function
  deletes the question, and it takes `rr-wrap` and `RunShape` with it: measured,
  `rr-samples` is the only consumer of all three.
- **So the field would be settled against a guess at the law.** That is the arc's
  own stated reason for minting N8 and N9 as one element, applied to the same
  shape one row later.

The honest cost, stated rather than absorbed: the roster's L2 band carries
`N10` (this sum), `N11` (the trace) and `N12` (the message-width contract), and
none of the three is a recording volume law. E197 therefore covers its row plus
one claim the roster does not carry. Minting is the arc session's event and
comes first, on this arc's own resume note, so this run opens no row and §6
names the gap as owed.

## 4. Change plan (ordered, commit-sized)

Every step below was executed off-tree in this run against a copy of `lib/` and
`prog/`, compiled with the tracked binary, and run. Nothing under the live
`lib/`, `prog/` or `tools/` was touched.

### Step 1: the module
- **Target:** `prog/unit/recording.chiral`, NEW FILE, 39 lines
- **Change:** the closed `RecordRequest` sum with `record-spikes (population Str)`,
  `record-membrane (population Str) (sample-every (refine I64 (> 0)))` and
  `record-weights` at the same shape; `RunShape` carrying `neurons`, `fanout`,
  `ticks` and `rate-milli`; the `VolumeR` sum with `v-ok` and `v-empty`;
  `rr-wrap : (-> I64 VolumeR)` folding a zero product to `v-empty`; one total
  `rr-samples : (-> RunShape RecordRequest VolumeR)` with three arms and no `_`;
  `rr-interval : (-> RecordRequest (Maybe I64))` whose `record-spikes` arm is
  `none`; and `rr-fields : (-> RecordRequest I64)`. Adapts the example §5
  snippet with decision 2's refinement and decision 3's result sum. No
  `(module …)` form, matching the `prog/prapanca/` and `prog/unit/encoding.chiral`
  precedent.
- ⚑ **`rr-wrap` must be defined above `rr-samples`.** It is a plain `def` with
  no `declare`, and the `case` on a `Bool` takes E196's spelling,
  `(case (=i v 0) (true (v-empty)) (false (v-ok v)))`. A nullary constructor is
  applied as `(v-empty)` and matched as the bare word `v-empty`, which is
  `enc-decode`'s idiom at `prog/unit/encoding.chiral:106`.
- **Verified by:** the module resolves under `lib:prog` and compiles inside a
  probe root that reads `rr-fields` off a `record-spikes`.
- **Size:** M

### Step 2: the sweep root
- **Target:** `prog/e197-recording-sweep.prog`, NEW FILE, 63 lines
- **Change:** `kv` and `kvs` line builders, `vol-str : (-> VolumeR Str)` printing
  `empty` on the second arm, `ivl-str : (-> RecordRequest Str)` printing `none`
  on the spikes arm, `xspk-str : (-> VolumeR VolumeR Str)` dividing a request's
  volume by the same shape's spike volume, one shared `row-line`, and `row-spk`,
  `row-mem`, `row-wgt`. `compile-main` runs twenty configurations through a `do`
  chain. **It asserts nothing and always exits 0**, on
  `prog/e188-apply-spine.prog`'s rule that a gate re-deriving its own verdict is
  green under any mutant that changes what the verdict says.
- ⚑ **The interval parameters carry the refinement.** `row-mem` and `row-wgt`
  are `(=> I64 I64 I64 I64 (refine I64 (> 0)) Unit)`. Declaring them
  `(=> I64 I64 I64 I64 I64 Unit)` fails the whole root with
  `load: cannot prove refinement` and no site named, which decision 2 measured.
- **The root lands in Phase 7's census for free.** Phase 7 sweeps
  `grep -rl '^(def compile-main' lib prog`, so the suite compiles this root every
  pass and executes none of it. That is the `compiled` state [[banks/unit]] §2
  defines, and it is the whole suite claim this element may make.
- **Verified by:** R1, then R3 against the golden.
- **Size:** M

### Step 3: the gate
- **Target:** `tools/test/recording.sh`, NEW FILE
- **Change:** the six rows and six mutants of §5, with the declaration
  `# not-a-phase: E197's number waits on the standing suite-phase-number call in
  records/author-calls.md` at the head. Mutants run over a copied `prog/`, the
  mechanism `tools/test/encoding.sh` uses for a module outside the compiler's
  blob, with the same symlink guard: `cp -a` copies a symlink as a symlink and
  every later `sed -i` then writes through it into the tree under test.
- ⚑ **What loses a wide value in this tree's awk is the RENDERING, not `int()`**,
  measured on `mawk`: `int(100000000000)` compares equal to `100000000000` and
  `printf "%.0f"` prints it back exactly, so `int()` is lossless. What loses it
  is `printf "%d"`, which clamps to 2147483647, and string coercion under
  `CONVFMT`/`OFMT` at `%.6g`, where the same value renders as `1e+11`. That
  second one is what made a first draft of R4 report a false finding on golden
  line 14: the recomputed 100,000,000,000 was compared as the string `1e+11`
  against the row's own `100000000000`. R4 therefore renders every recomputed
  volume with `%.0f` and never with `%d` or a bare `print`, applies `int()` to
  the small quotient `t/ivl` for the floor division it is there to do, keeps the
  wide multiply in floating point, which is exact below 2^53, and declares the
  two rows at or past that bound skipped rather than checking them wrong. The
  repair is why the row prints its own skipped count.
- **Verified by:** the six rows and six mutants, run end to end in this run.
- **Size:** M

### Step 4: the registries
- **Target:** `docs/elements/catalog.md`, `docs/elements/ledger.md`
- **Change:** neither row names `VolumeR`, the refinement, or `rr-samples`'s
  return type. Repoint both at implementation time, in the commit that lands the
  module, so this step rides in step 1's and opens no fourth commit.
- **What holds the rows today:** no `ledger-lint` check reads a catalog row's
  constructor prose. J, K, N, V and AB pass with both rows unedited and must
  still pass after the repoint, which is what makes the deferral safe and the
  repair owed.
- **Size:** S

**No step touches `lib/` or `prog/compiler.prog`**, so the build rule's
`build-new → test → promote` and its byte-compare do not apply. §5 R6 measures
that on both halves.

## 5. Conformance gate

`tools/test/recording.sh`, declared out of the dispatch table, run by hand.
**No suite conformance is claimed anywhere**: the sweep root is compiled by
Phase 7 and executed by nothing in `tools/test/run-tests.sh`.

### The golden

Twenty lines, measured on the tracked binary. Columns are `n` neurons, `f`
synapses per neuron, `t` ticks, `r` spikes per neuron per 1,000 ticks, `ivl` the
request's own `sample-every`, `samples` the priced volume, `fields` the bounded
digest, `xspk` the volume as a multiple of the same shape's spike volume:

```
spikes n=1000 f=100 t=1000 r=10 ivl=none samples=10000 fields=1 xspk=1
membrane n=1000 f=100 t=1000 r=10 ivl=1 samples=1000000 fields=2 xspk=100
membrane n=1000 f=100 t=1000 r=10 ivl=25 samples=40000 fields=2 xspk=4
membrane n=1000 f=100 t=1000 r=10 ivl=50 samples=20000 fields=2 xspk=2
weights n=1000 f=100 t=1000 r=10 ivl=1 samples=100000000 fields=2 xspk=10000
weights n=1000 f=100 t=1000 r=10 ivl=1000 samples=100000 fields=2 xspk=10
spikes n=1000 f=100 t=1000 r=100 ivl=none samples=100000 fields=1 xspk=1
membrane n=1000 f=100 t=1000 r=100 ivl=1 samples=1000000 fields=2 xspk=10
spikes n=1000 f=100 t=60000 r=10 ivl=none samples=600000 fields=1 xspk=1
membrane n=1000 f=100 t=60000 r=10 ivl=1 samples=60000000 fields=2 xspk=100
weights n=1000 f=100 t=60000 r=10 ivl=1000 samples=6000000 fields=2 xspk=10
spikes n=100000 f=1000 t=1000 r=10 ivl=none samples=1000000 fields=1 xspk=1
membrane n=100000 f=1000 t=1000 r=10 ivl=1 samples=100000000 fields=2 xspk=100
weights n=100000 f=1000 t=1000 r=10 ivl=1 samples=100000000000 fields=2 xspk=100000
membrane n=1000 f=100 t=1000 r=10 ivl=1001 samples=empty fields=2 xspk=empty
membrane n=1000 f=100 t=1000 r=10 ivl=999 samples=1000 fields=2 xspk=0
membrane n=1000 f=100 t=1000 r=10 ivl=3 samples=333000 fields=2 xspk=33
membrane n=1000 f=100 t=1000 r=10 ivl=7 samples=142000 fields=2 xspk=14
weights n=1000000 f=1000000 t=1000000 r=10 ivl=1 samples=1000000000000000000 fields=2 xspk=100000000
weights n=1000000 f=10000000 t=1000000 r=10 ivl=1 samples=-8446744073709551616 fields=2 xspk=-844674408
```

**Against the example, re-derived and not copied.** All fourteen rows of the
example's M1 table reproduce exactly on `samples` and `xspk`, including the
100x and 10,000x ratios the element exists to express and line 8's fall from
100 to 10 that shows the ratio is set by the firing rate. Lines 16 through 18
reproduce M2's `999`, `3` and `7` rows exactly at 1,000, 333,000 and 142,000.
Lines 19 and 20 reproduce M4's wall exactly at 10^18 and the wrap. Two
divergences, both a decision's and both demonstrated above: line 15 prints
`samples=empty` where the example printed `0`, which is decision 3, and the
example's line 19 at `sample-every = -3` is absent, which is decision 2 and is
carried instead by gate row R2.

### The rows

| row | the assertion | how it is judged |
|---|---|---|
| **R1** | the sweep root resolves, compiles to a non-empty ELF and exits 0 | the resolver plus `bin/chirality-bin`, then the ELF |
| **R2** | the refinement refuses: a `sample-every` of `0` and of `-3` each fail to build with `load: cannot prove refinement`, and `25` builds | three probe roots compiled in the driver, judged on the compiler's own exit and message |
| **R3** | the twenty lines are byte-identical to the golden | `diff` against the checked-in golden |
| **R4** | the volume law holds on every row: `n*(t/e)` for membrane, `n*f*(t/e)` for weights, `n*t*r/1000` for spikes, floor division, `empty` where the quotient is zero | recomputed in awk from the row's OWN columns, with the golden unread and the two rows past 2^53 declared skipped |
| **R5** | `ivl=none` on every spikes row and on no other | read off the row's own tag and `ivl` column, golden unread |
| **R6** | `prog/compiler.prog`'s blob holds no `unit/recording`, AND a copied `lib/` that imports it makes the same scan see it arrive | resolve the blob, grep it, twice |

⚑ **R3 and R4 are two claims and the driver runs both, and here each convicts
rows the other cannot.** The example argued the pin and the law belong together
because a golden line is cut by running the code, so a wrong `rr-samples` is
pinned as correct and blessed for good, while a driver recomputing the law from
the row's own columns never reads the golden. That argument holds and this run
measured a second, sharper one on top of it. Mutant M2 moves six golden lines
and R4 catches four of them, because lines 19 and 20 sit past awk's exact range
and R4 declares them skipped. Mutant M5 moves nineteen golden lines and R4
catches four, because `xspk` couples every row to the spikes price while the law
is checked per arm. So R3 convicts on rows R4 abstains from, R4 convicts against
a formula R3 cannot hold an opinion about, and neither is a weaker copy of the
other. E196's precedent reads as though the two were alternatives; on this
element they are not.

⚑ **R5 exists because the element's central claim moves no number.** The
interval on `record-spikes` is the whole structural content of the sum: it is
the difference between three constructors and one record with an optional field.
Measured on M3 below: `rr-interval` answering `(some 1)` for spikes leaves every
`samples=` figure in the file untouched, so R4 reports nothing and only the
`ivl=` column moves. A gate pinning volumes alone passes M3 completely. R5
evaluates the presence claim from each row's own tag and never reads the golden,
so it convicts what neither the pin nor the law reaches.

⚑ **R2 is what decision 2 buys, and it is a gate row no sweep line could be.**
The example's twenty-first configuration priced a negative interval at
`-333,000`. Against this declaration that configuration does not compile, so the
defect leaves the golden and becomes a compile refusal. R2 asserts the refusal
in both directions, which is what stops a later run from quietly dropping the
refinement: removing it turns R2's two refused probes green and R2 red, while
every one of the twenty golden lines stays byte-identical.

### The mutants

Each pins the WHOLE SET of golden lines it moves, by line number, on
`tools/test/encoding.sh`'s rule that a gate naming one row per mutant cannot see
a mutant reddening a row outside its own pin. All six were built and run in this
run; the moved-line sets below are measured, and the R4 columns are the same
mutants judged by the recomputed law alone.

| mutant | change | R3 moves | R4 catches |
|---|---|---|---|
| **M1** membrane-drops-neurons | `(* n (/ t e))` → `(/ t e)` | the **nine** membrane rows 2, 3, 4, 8, 10, 13, 16, 17, 18: 1,000,000 → 1,000, 40,000 → 40, 60,000,000 → 60,000, 333,000 → 333. Line 15 does not move, because a zero quotient is `v-empty` under either arithmetic | the same nine |
| **M2** weights-drops-fanout | `(* (* n f) (/ t e))` → `(* n (/ t e))` | the **six** weights rows 5, 6, 11, 14, 19, 20. It **collapses lines 19 and 20 onto 1,000,000,000,000 both**, so the wall stops being observable | four of the six; 19 and 20 are past awk's exact range and R4 skips them, which is what keeps R3 load-bearing |
| **M3** spikes-gains-an-interval | `rr-interval`'s spikes arm → `(some 1)` | the **four** spikes rows 1, 7, 9, 12, in the `ivl=` column only. **Not one `samples=` figure in the file moves** | **none.** R5 catches all four |
| **M4** ceiling-idiom | `(/ t e)` → `(/ (+ t (- e 1)) e)` in both arms | the **four** rows where `e` does not divide `t`: 15 (`empty` → 1,000), 16 (1,000 → 2,000), 17 (333,000 → 334,000), 18 (142,000 → 143,000). The **sixteen** rows whose interval divides the run exactly or which carry no interval are blind to the rounding rule | the same four |
| **M5** spikes-drops-the-rate | `(/ (* (* n t) r) 1000)` → `(/ (* n t) 1000)` | **nineteen** of twenty rows. On `samples=` it moves the four spikes rows 1, 7, 9, 12 and **collapses lines 1 and 7 onto 1,000 both**; the other fifteen move on `xspk` alone, whose denominator is the spikes price | four: the spikes rows on `samples=`. R4 is checked per arm, so the `xspk` knock-on is invisible to it |
| **M6** empty-is-zero | `rr-wrap`'s body → `(v-ok v)` | **line 15 alone**: `samples=empty xspk=empty` → `samples=0 xspk=0` | line 15 |

⚑ **M5's blast radius is nineteen rows and that is the `xspk` column's doing,
not an arm leak.** M1, M2, M3 and M6 each stay inside their own arm, so a
reddened row names the arm that broke it, which is E196's property. M4 has no
single arm, because the ceiling idiom goes into the membrane and weights arms
together, but it stays inside its own arithmetic all the same: every weights row
in the golden carries an interval that divides its run exactly, so the four rows
it reddens are the four the rounding rule can reach. M5 breaks it by
construction: `xspk` divides every row's volume by the same shape's spikes
volume, so changing the spikes arm moves the denominator under all three. The
column is kept for that reason and not in spite of it. It is what carries the
element's headline ratio directly, the 100x and 10,000x of the example's M1, and
it makes the spikes arm the one arm every row depends on. What localizes M5 is
R4, which is checked per arm and names the four `samples=` rows exactly.

⚑ **M6 is decision 3's positive assertion.** With `v-empty` restored to
`(v-ok 0)`, line 15 reads `xspk=0`, which is byte-identical in that column to
line 16's honest quotient of zero. One integer then carries "the interval
outran the run" and "the volume rounds below one" with nothing to separate them,
which is the collision `docs/definitions/pattern-boundary-sums.md` names. This
is E196's M4 one element later.

### The green line

`tools/test/run-tests.sh` gains no phase and its thirteen dispatch lines are
unchanged. `tools/test/registration.sh` was run against a copied `tools/test/`
carrying the new script: **9 passed, 0 failed**, base verdict
`G1:ok G2:ok G3:ok G4:ok G5:ok G6:ok`, with the PEND list going from 11 of 24 to
**12 of 25**. Baseline `9 passed, 0 failed` at 11 of 24, measured on the live
tree in this run.

⚑ **R6 sees the needle arrive, measured on both halves.** `prog/compiler.prog`'s
blob resolves to **820,959 bytes**, unmoved from E196's figure, and holds zero
occurrences of `unit/recording`, `RecordRequest`, `record-spikes`,
`record-membrane`, `record-weights`, `rr-samples`, `VolumeR` and `sample-every`.
Adding `(import "unit/recording")` to a copied `lib/typing/diag.chiral` takes the
blob to **822,178 bytes** with `unit/recording` at 2, `RecordRequest` at 4,
`record-membrane` at 4, `rr-samples` at 2 and `VolumeR` at 3, so the scan is
proved sensitive and not merely silent. This is `tools/test/render-doc.sh`'s G9
plus M11 applied to a third element. **E197 therefore ships under a plain
`chirality run` with no fixpoint obligation.**

`ledger-lint` at the start of this run: check AC fails with 3 findings (`E20`,
`E26`, `E101`), check I fails with 1, and the `[N] E52` note is flagged rather
than failing. H and M stay vacuous. Check I was already red when this run
opened: `pack.py --spec` flips the element's `docs/examples/INDEX.md` row to
`specced`, and that file is one of the frontier's condense sources
(`tools/frontier/frontier.py:53`), so the scaffold moved a source without a
re-condense. The re-condense belongs to the arc session. This SPEC adds no
finding to any check, and J, K, N, V and AB stay green.

**Done when:** `tools/test/recording.sh` prints `recording: 12 passed, 0 failed`
over R1 to R6 and M1 to M6, `tools/test/registration.sh` still prints
`9 passed, 0 failed`, and `ledger-lint` reports no check newly failing.

## 6. Residue & links

- **Deliberately unbuilt, and each with its home:**
  - **`population` as a typed value** (decision 1). `unit-lane/N17` is the
    `Population` construct at L4 and it reads `unminted`, so nothing is deferred
    to a name that does not exist and no element is attached. Shipping `Str`
    mints a second instance of the debt `Expert` already carries at
    `prog/prapanca/core/types.chiral:63`, whose closing row `unit-lane/N13` is also
    unminted. Both are recorded here so the second instance is visible when N13
    or N17 is minted.
  - **A `sample-every` computed at run time** (decision 2). The engine decides
    the predicate for a literal and for a value already at the refined type, and
    refuses `(+ 20 5)`. Every interval this element writes is a literal, so the
    constructor is closed in practice and open in principle. The general
    question is the same one `C1C2-style-round-trip-SPEC.md` measured on
    `face-join`, and it has no arc row and no element.
  - **`v-unbounded`, and the `I64` wrap it would report** (decision 3). Golden
    line 20 pins the wrap as observed behaviour and nothing guards it. Detecting
    it needs `unit-lane/N1`'s high-half product, which reads `unminted`, or a
    division pre-check `RunShape`'s unrefined fields do not support. The wall
    sits at an exabyte of samples, which is why the pin is enough for now.
  - **The volume law's roster row** (decision 4). E197 covers `unit-lane/N10`
    plus one L2 law the roster has no row for; `N11` is the trace and `N12` is
    the message-width contract, and neither is it. Minting is the arc session's
    event and comes first, so this run opens nothing. ⚑ **The arc owes a row, or
    owes an explicit note that N10 absorbs the law**, and until one of the two
    lands the roster under-reports what E197 built.
  - **What the digest becomes** (decision 5). `rr-fields` ships and answers
    nothing beyond itself. `unit-lane/N11` is the unbounded trace paired against
    `RunManifest` and it reads `unminted`, so no element is attached.
  - **The suite phase number** (decision 6). The standing call in
    `records/author-calls.md:30` covers it. The row's own count is stale, at
    8 of 21 against a live 11 of 24, so this run adds no paragraph to it and
    states the measurement here instead: 12 of 25 scripts outside the dispatch
    table once this gate lands.
  - **Rate-bin aggregation**, the research's third volume move. It needs a trace
    to aggregate, so it sits behind `unit-lane/N11`. `unminted`.
- **Follow-on:** none minted by this run. `unit-lane/N11` through `N42` are the
  arc's remaining rows and every one reads `unminted`.
- **Related:** [[E197-record-request]], [[arcs/unit-lane-arc]] row
  `unit-lane/N10`, [[banks/unit]] shard K, [[decisions/decision-display-numerics]],
  [[decisions/decision-lane-split]], [[working-discipline]],
  `docs/definitions/pattern-boundary-sums.md`, `records/author-calls.md`. E196's
  SPEC is the shape precedent for §5 and its `DecodeR` is decision 3's.
