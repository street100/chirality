---
element: E197
slug: record-request
title: "**`RecordRequest`: what a run is asked to record, as a value**"
kind: BUILD-PROPER
reference_class: PAPER/IMPL
ours_source: (none)
status: drafted
updated: 2026-09-05
---

# E197 — **`RecordRequest`: what a run is asked to record, as a value**

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E197, the closed sum naming what a run is asked to write down,
  one constructor per class of recordable signal, together with the total
  function that prices a request against the run it is aimed at. It covers
  `unit-lane/N10` from [[arcs/unit-lane-arc]].
- **Kind:** BUILD-PROPER.
- **Why chirality needs its own:** nothing in this tree names the seam.
  Measured 2026-09-05 at `68673a1` over `lib/` and `prog/`: `RecordRequest`,
  `record-spikes`, `sample-every` and `sampling` return **zero files** each;
  `spike` returns **two**, both E196's own (`prog/unit/encoding.chiral`,
  `prog/e196-encoding-sweep.prog`); `neuron` returns **one**, a comment at
  `prog/unit/encoding.chiral:28` naming what E196 excludes. `.planning/AI-LANE-GAP.md`
  section 1's L2 line states the same absence and names `RunManifest`/`RawCall`
  as the nearest existing pattern.
- **Out of scope:** the trace itself. `unit-lane/N11` is the unbounded result
  type paired against `RunManifest`, and it is unminted. E197 stops at the
  request. Also out: any population, any producer of a spike, any storage
  backend.

⚑ **`membrane` is the tree's sharpest homonym and this element walks into it.**
The word appears in **37 files** under `lib/` and `prog/`, and every one of them
is the *effect* membrane (`lib/typing/effects.chiral:1`, "E12: the effect
membrane"). Not one occurrence means a neuron's membrane potential. The arc's
census warns that a hit is usually a homonym; this is the largest instance of
it in the lane, and `record-membrane` is a constructor whose name collides with
the tree's most load-bearing term.

## 2. Research

- **Reference class:** `PAPER`/`IMPL`, and EXTERNAL. There is no in-tree
  baseline. The research is `.planning/AI-LANE-RECORDING.md` and this run does
  not redo it.
- **Three signal classes, three cost profiles.** Spikes are discrete events
  carrying a neuron id and a timestamp with no magnitude. Membrane potential is
  a continuous value existing at every step whether or not a spike fires.
  Synaptic weights are one value per synapse, moving on a learning timescale
  and so sampled sparsely in time.
- **The sampling interval is a count of steps, and the substrate is what makes
  it one.** A simulator advances state in fixed steps of `dt`, nothing new
  exists between steps, and PyNN's `record()` therefore requires
  `sampling_interval` to be an integer multiple of the timestep.
- **The field answers volume by an asymmetry between the classes.** NEST's
  `spike_recorder` collects every spike from connected neurons with no
  configuration. Its `multimeter` records nothing until told which variables to
  pull. Cheap discrete events default to on; expensive continuous state is
  asked for by name; anything dense is aggregated into rate bins at 25 ms or
  50 ms before it is written down.
- **This tree already carries the digest/unbounded split the case needs.**
  `ExpertCall` (`prog/manas/core/types.chiral:131`) is described in its own
  comment as "the DIGEST-ONLY conformance record kept bounded for the
  manifest". `RawCall` (`:152`) is the unbounded sibling threaded out beside
  it, and the comment states the reason: "so the manifest's round-trip schema
  stays unchanged". `RunManifest` (`:166`) holds fifteen fields shaped to a
  golden. A dense per-timestep trace is exactly what "kept bounded" excludes.

### The measurements this pre-run owes

Every figure below is an execution result. One chirality module and one root
were written for this run, compiled and executed with today's
`bin/chirality-bin` (1,188,216 B, 2026-09-05 10:13). The module declares
`RecordRequest`, a `RunShape` to price it against, one total `rr-samples` over
all three arms with no `_`, a total `rr-interval` returning `(Maybe I64)`, and
`rr-fields`. The root prints one line per configuration carrying `ivl=`,
`samples=`, `fields=` and `xspk=`, the last being the request's sample count as
a multiple of the same shape's spike count. Twenty-one lines. Section 5 carries
the module verbatim. Nothing under `lib/`, `prog/` or `tools/` was touched.

Columns: `n` neurons, `f` synapses per neuron, `t` ticks, `r` spikes per neuron
per 1,000 ticks, `ivl` the request's own `sample-every`.

**M1 · The volume asymmetry is real, and it is the sampling interval that
closes it.**

| line | req | `n` | `f` | `t` | `r` | `ivl` | `samples` | `xspk` |
|---|---|---|---|---|---|---|---|---|
| 1 | spikes | 1,000 | 100 | 1,000 | 10 | none | **10,000** | 1 |
| 2 | membrane | 1,000 | 100 | 1,000 | 10 | 1 | **1,000,000** | **100** |
| 3 | membrane | 1,000 | 100 | 1,000 | 10 | 25 | 40,000 | 4 |
| 4 | membrane | 1,000 | 100 | 1,000 | 10 | 50 | 20,000 | 2 |
| 5 | weights | 1,000 | 100 | 1,000 | 10 | 1 | **100,000,000** | **10,000** |
| 6 | weights | 1,000 | 100 | 1,000 | 10 | 1,000 | 100,000 | 10 |
| 7 | spikes | 1,000 | 100 | 1,000 | 100 | none | 100,000 | 1 |
| 8 | membrane | 1,000 | 100 | 1,000 | 100 | 1 | 1,000,000 | **10** |
| 9 | spikes | 1,000 | 100 | 60,000 | 10 | none | 600,000 | 1 |
| 10 | membrane | 1,000 | 100 | 60,000 | 10 | 1 | 60,000,000 | 100 |
| 11 | weights | 1,000 | 100 | 60,000 | 10 | 1,000 | 6,000,000 | 10 |
| 12 | spikes | 100,000 | 1,000 | 1,000 | 10 | none | 1,000,000 | 1 |
| 13 | membrane | 100,000 | 1,000 | 1,000 | 10 | 1 | 100,000,000 | 100 |
| 14 | weights | 100,000 | 1,000 | 1,000 | 10 | 1 | **100,000,000,000** | **100,000** |

At one sample per tick a membrane request costs **100 times** the spike request
over the same population and duration, and a weights request costs **10,000
times** it. That ratio is the measured content of the field's default
asymmetry, and it is the whole reason the type exists as a sum. Line 6 is the
repair: sampling weights once per 1,000 ticks, the learning timescale the
research names, takes the ratio from 10,000 to 10 and makes the request
affordable at the same population.

⚑ **The ratio is set by the firing rate, and the class of signal only decides
which side of it a request sits on.** Line 8 is line 2's population firing at
100 Hz instead of 10 Hz. The membrane cost is identical (1,000,000 both times,
because the membrane exists at every step whatever the neuron does), while the
spike cost rises tenfold and the ratio falls from 100 to 10. So "spikes are
cheap" is a claim about a firing rate, and a request cannot be priced from its
constructor alone. `rr-samples` takes a `RunShape` for that reason.

**M2 · The sampling interval is a divisor, and three of its values are
defects.**

| line | `ivl` | `t` | `samples` | what happened |
|---|---|---|---|---|
| 15 | 1,001 | 1,000 | **0** | the interval exceeds the run. The request records nothing and says nothing |
| 16 | 999 | 1,000 | 1,000 | one sample per neuron, the run's last tick dropped |
| 17 | 3 | 1,000 | 333,000 | `1000/3` floors to 333. One tick of the run is unsampled |
| 18 | 7 | 1,000 | 142,000 | `1000/7` floors to 142. Six ticks unsampled |
| 19 | -3 | 1,000 | **-333,000** | a negative volume, and nothing refuses it |

And the value the sweep cannot carry:

⚑ **`sample-every = 0` kills the process.** Measured directly on today's
binary: a root printing `before`, then `(/ 1000 0)`, then `after` prints
`before` and dies with **`Illegal instruction`, exit 132**. `after` is never
reached. There is no chirality-level error, no returned sum, and no diagnostic.
The divide is a hardware instruction and the language does not guard it, so a
`sample-every` of zero produces no wrong answer; it produces a dead run. This is the
strongest single argument in this element for a refinement on the field, and it
is measured rather than assumed.

**M3 · `/` uses two rounding rules, and both appear on one output line.**

| expression | result | floor would be | trunc-to-zero would be |
|---|---|---|---|
| `(/ 1000 3)` | **333** | 333 | 333 |
| `(/ -1000 3)` | **-334** | -334 | -333 |
| `(/ 1000 -3)` | **-333** | -334 | -333 |
| `(/ -1000 -3)` | **334** | 333 | 333 |
| `(/ 7 2)` | 3 | 3 | 3 |
| `(/ -7 2)` | **-4** | -4 | -3 |
| `(/ 7 -2)` | **-3** | -4 | -3 |
| `(/ -7 -2)` | **4** | 3 | 3 |

With a positive divisor `/` floors, which is the rule E196's audit recorded.
With a negative divisor it ceils. Neither pure flooring nor pure truncation
describes both halves. Line 19 above carries both rules at once: `samples` is
`1000 * (/ 1000 -3)` = -333,000 under the ceiling rule, and `xspk` is
`(/ -333000 10000)` = **-34** under the flooring rule, so a single output line
rounds one way and then the other. A reader deriving either figure by reasoning
would get one of them wrong.

**M4 · The `I64` wall is past anything writable, so this element needs no
compiler change.**

| line | `n` | `f` | `t` | `ivl` | `samples` |
|---|---|---|---|---|---|
| 20 | 1,000,000 | 1,000,000 | 1,000,000 | 1 | **1,000,000,000,000,000,000** |
| 21 | 1,000,000 | 10,000,000 | 1,000,000 | 1 | **-8,446,744,073,709,551,616** |

Line 20 is 10^18, inside `I64`'s 9,223,372,036,854,775,807 with a factor of
nine to spare, and it describes a million neurons at a million synapses each
sampled every tick for a million ticks: 10^15 synapses, an order of magnitude
past a human brain's, sampled 10^6 times. Line 21 raises fan-out tenfold and
the product wraps to a negative. So the wall exists and sits at a
**sample count no storage tier could hold**: at one byte per sample line 20 is
already an exabyte. `op-mulhi` and E189 are therefore off this element's path
for the same reason E196 measured, and **no compiler change is required**:
every figure in this section was produced on today's binary with nothing under
`lib/` altered.

**M5 · The digest is constant and the trace is not, which is why they are two
types.** Lines 1, 2 and 5 against lines 9, 10 and 11 hold the same requests
against a run sixty times longer. `fields=` reads 1, 2 and 2 in both, and
`samples=` multiplies by sixty. The request is a bounded value whose size is
fixed by its constructor; what it commissions grows with the run. That is
`ExpertCall` against `RawCall`, one layer down.

⚑ **`RunManifest` cannot absorb the digest, and this is a finding rather than a
question.** Its fifteen fields are the golden manifest's fifteen top-level keys
(`prog/manas/core/types.chiral:166`), and `RawCall`'s own comment says the
split exists so "the manifest's round-trip schema stays unchanged". Adding a
recording field to `RunManifest` breaks the conformance surface that comment
protects. E197 touches neither type.

## 3. Conventional (other-language) approach

Every simulator in the reference class writes the request as a call, with the
variables as strings in a list and one interval applied to all of them.

```python
# PyNN and NEST shape it roughly this way: variables are strings, the interval
# is a float in milliseconds, and the request is an action rather than a value.
pop.record(["spikes", "v", "gsyn_exc"], sampling_interval=1.0)
pop.record("spikes", sampling_interval=5.0)   # accepted, and it means nothing

mm = nest.Create("multimeter", params={"record_from": ["V_m"], "interval": 1.0})
nest.Connect(mm, pop)                          # nothing records until this runs
```

- **Assumptions it bakes in:**
  - **One interval for a list of variables.** `sampling_interval` is a keyword
    on the call, so it attaches to spikes and to voltage alike. The second line
    above is well-formed and inert: an event stream has no interval to obey.
  - **The variables are strings.** A typo is a runtime lookup failure at best,
    and at worst a silently unrecorded variable discovered when the analysis
    finds an empty array.
  - **The interval is a float in milliseconds**, over a substrate that advances
    in integer steps. The integer-multiple rule is then a runtime check on a
    float, and the two representations must be reconciled by validation.
  - **The volume is nowhere in the signature.** Nothing in `record()` says what
    the call commits the run to writing. A membrane request over a large
    population is the same call shape as a spike request and costs a hundred
    times more.
  - **The request is an action.** `record()` mutates the population and
    `Connect` wires the recorder. There is no value to pass around, inspect,
    price, log, or compare against a later run's.

## 4. The chirality idea

- **Chirality features in play:** the closed sum with a coverage-checked `case`
  (boundary sums, the standing directive); the request as an inert value rather
  than a call, so pricing it is `->` with an empty effect row; refinement types
  on the constructor's fields; totality; the float wall, which makes the
  interval a tick count in `I64`.
- **The reframing.** The thing being recorded stops being a string in a list
  and becomes a constructor. Each constructor carries exactly the fields its
  own class needs: `record-spikes` carries a scope and nothing else, because an
  event stream is addressed by occurrence; `record-membrane` and
  `record-weights` each carry a `sample-every`, because both are addressed by
  time. The asymmetry the conventional API expresses as a keyword that is
  sometimes meaningless is here the shape of the sum, so `rr-interval` returns
  `(Maybe I64)` and the `none` arm is the typed statement that an event stream
  has no interval. And because the request is a value, `rr-samples` can price
  it before the run starts. That function is what turns M1's ratio from a
  property of the literature into a number the type computes.
- **What chirality makes impossible here:**
  - **An interval attached to spikes.** `record-spikes` has no such field, and
    it cannot be given one at the call site.
  - **An unknown signal class.** The sum is closed at three and `case` is
    coverage-checked, so a fourth class is a compile error at every consumer
    instead of a runtime lookup failure at one.
  - **A float interval.** The tree has no float type, so the interval is a tick
    count and PyNN's integer-multiple rule holds by construction instead of by
    validation.
  - **A request whose cost is unknowable.** `rr-samples` is total over the sum,
    so every constructor prices.
- ⚑ **What it does not make impossible, measured.** A `sample-every` of `0`
  still kills the process (M2), a negative one still yields a negative volume,
  and an interval larger than the run still yields a silent zero. The sum
  closes the *classification*; it does nothing about the *field's domain*. Only
  a refinement on `sample-every` closes the first two, and the third is
  run-relative and outside anything the constructor can see. Stating the sum as
  though it closed all three would be the phantom-feature error.

## 5. Chirality example (fleshed)

Real surface syntax. Every form below compiled and ran under today's
`bin/chirality-bin` while producing section 2's figures, apart from the
`VolumeR` variant at the end, which is the recommendation M4 argues for.

```chirality
(import "prelude/prelude")

; ── the request. One closed sum, one constructor per class of recordable
; signal, each carrying its OWN scope. `record-spikes` carries no interval
; because an event stream is addressed by occurrence and not by time.
(data RecordRequest ()
  (record-spikes   (population Str))
  (record-membrane (population Str) (sample-every I64))
  (record-weights  (population Str) (sample-every I64)))

; ── the run a request is priced against. `rate-milli` is spikes per neuron per
; 1,000 ticks, so it is a Hz reading when a tick is a millisecond, held as an
; integer because the float wall leaves no other option.
(data RunShape ()
  (run-shape (neurons I64) (fanout I64) (ticks I64) (rate-milli I64)))

; ── ONE total pricing function over the sum. Three arms, no `_`, integer only,
; and `->` because a request is inert data and pricing it crosses nothing.
(declare rr-samples (-> RunShape RecordRequest I64))
(def rr-samples (lam (s q)
  (case s
    ((run-shape n f t r)
      (case q
        ((record-spikes p)     (/ (* (* n t) r) 1000))
        ((record-membrane p e) (* n (/ t e)))
        ((record-weights p e)  (* (* n f) (/ t e))))))))

; ── the interval, typed. The `none` arm IS the asymmetry: it is what the
; conventional `sampling_interval=` keyword cannot say.
(declare rr-interval (-> RecordRequest (Maybe I64)))
(def rr-interval (lam (q)
  (case q
    ((record-spikes p)     none)
    ((record-membrane p e) (some e))
    ((record-weights p e)  (some e)))))

; ── the digest a manifest would keep: bounded, and constant in the run's
; length. M5 measures the contrast against `rr-samples`.
(declare rr-fields (-> RecordRequest I64))
(def rr-fields (lam (q)
  (case q
    ((record-spikes p)     1)
    ((record-membrane p e) 2)
    ((record-weights p e)  2))))
```

**The recommended pricing signature, which M2 and M4 measure the need for.**
The `I64` version above returns 0 for a request that records nothing, a
negative for a negative interval, and a wrapped negative past the wall, and it
dies outright on a zero interval:

```chirality
; the reason exists at the pricing and must not be re-derived downstream.
(data VolumeR ()
  (v-ok      (samples I64))
  (v-empty)                      ; the interval exceeds the run: nothing sampled
  (v-unbounded))                 ; the product leaves I64

; the field's domain, closed at the constructor. `>` and `<` are two of the five
; legal refinement operators (`SymOp`, lib/typing/refine.chiral:11); `!=` and
; `/=` are neither legal nor refused, so `<>` is the only honest spelling of
; "nonzero" and `(> 0)` is the one wanted here.
(data RecordRequest ()
  (record-spikes   (population Str))
  (record-membrane (population Str) (sample-every (refine I64 (> 0))))
  (record-weights  (population Str) (sample-every (refine I64 (> 0)))))
```

- **Knobs to modify:** the constructor set, which is where a fourth signal
  class would land; the `RunShape` field list, which is what `rr-samples` may
  read; the refinement bound on `sample-every`; whether `rr-samples` returns
  `I64` or `VolumeR`; whether `population` stays a `Str`.
- **Deliberately omitted:** the trace type itself, which is `unit-lane/N11`;
  any aggregation of a trace into rate bins, which the research names as the
  field's third volume move and which needs a trace to aggregate; any storage
  tier; any producer of a spike.

## 6. Use / modify notes

- **Lands in:** `prog/unit/recording.chiral`, beside `prog/unit/encoding.chiral`.
  E196 opened `prog/unit/` and settled the `lib/` against `prog/` question for
  this lane, so E197 inherits the answer instead of re-asking it. The module is
  category A with an empty port set, pure `->` throughout, which files it under
  **VAL** the way E196 is filed.
- **Owes no fixpoint, on the same measurement E196 made.** `prog/compiler.prog`'s
  blob is **820,959 B** at `68673a1` with **zero** hits on `unit/recording`,
  measured 2026-09-05. A module under `prog/unit/` that no `lib/` file imports
  is outside the compiler the tree compiles itself with. The implementing run
  owes the second half of E196's check: copy a `lib/` file that imports the
  module and confirm the same scan sees it arrive, so the scan is proved
  sensitive rather than merely silent.
- **Conformance target, and it is something that runs.** A root that constructs
  each of the three constructors against a set of `RunShape` values, prices
  each, and prints one line per configuration carrying `ivl=`, `samples=`,
  `fields=` and `xspk=`, with a shell driver in `tools/test/` comparing those
  lines against pins. The pins are section 2's tables, twenty-one lines. What
  each row asserts:

| claim | the assertion | why it is that shape |
|---|---|---|
| the volume law | **exact equality**, `samples == n * (t / e)` for membrane, `n * f * (t / e)` for weights, `n * t * r / 1000` for spikes, recomputed in the driver from the row's own columns | it is an arithmetic identity. Nothing is approximated and no bound is involved |
| the interval's home | **a positive presence check**: `ivl=none` on every spikes row and on no other | the `(Maybe I64)` return is the element's central structural claim and no numeric column carries it |
| the interval's rounding | **exact equality** on the five rows where `e` does not divide `t` | measured: 0, 1,000, 333,000, 142,000 and -333,000 |
| the wall | **exact equality** on lines 20 and 21, one inside `I64` and one wrapped | measured: 10^18 and -8,446,744,073,709,551,616 |

⚑ **A pinned line and a recomputed law are both needed here, and for a
different reason than E196 gave.** E196's population arm asserts a bound, so
pinning an integer was strictly stronger than the law and silent about it. Here
the law is an exact identity, so a pin and a recomputation agree on every row
by construction. They still both belong: a golden line is cut by running the
code, so a wrong `rr-samples` is pinned as correct and blessed for good, while
a driver that recomputes `n * (t / e)` in awk from the row's own `n`, `t` and
`ivl` never reads the golden and convicts what the pin blessed. The SPEC should
say this explicitly, because the E196 precedent reads as though the two checks
were alternatives.

- **The gate can fail, demonstrated.** Four mutants were built and run on
  today's binary. Each row below names what reddens **and what cannot**:

| mutant | change | reddens | cannot move |
|---|---|---|---|
| **M1** | `record-membrane`'s pricing drops the neuron factor | the **ten** membrane rows (2, 3, 4, 8, 10, 13, 16, 17, 18, 19): 1,000,000 → **1,000**, 40,000 → **40**, 60,000,000 → **60,000**, -333,000 → **-333** | every spikes row and every weights row. The arms are priced independently |
| **M2** | `record-weights`'s pricing drops the fan-out | the **six** weights rows (5, 6, 11, 14, 20, 21): 100,000,000 → **1,000,000**, 100,000,000,000 → **100,000,000** | every spikes and membrane row. It also **collapses lines 20 and 21 onto the same figure** (1,000,000,000,000 both), so the wall stops being observable |
| **M3** | `rr-interval` answers `(some 1)` for spikes | the **four** spikes rows (1, 7, 9, 12), in the `ivl=` column only: `none` → **1** | **every `samples=` figure in the file**. Not one number moves |
| **M4** | the interval divide ceils instead of flooring | the **five** rows where `e` does not divide `t` (15, 16, 17, 18, 19): 0 → **1,000**, 1,000 → **2,000**, 333,000 → **334,000**, 142,000 → **143,000**, -333,000 → **-332,000** | the **nine** rows whose interval divides the run exactly (`ivl` = 1, 25, 50 or 1,000). Those rows are blind to the rounding rule |

⚑ **M3 is the mutant this element exists to catch, and no volume column sees
it.** The interval on `record-spikes` is the whole structural content of the
sum: it is the difference between three constructors and one record with an
optional field. A gate pinning only `samples=` passes M3 completely, because
`rr-interval` feeds no arithmetic. The `ivl=` column and the positive-presence
row in the table above exist for that single reason, and dropping either one
leaves the element's central claim ungated while the gate still reads green.

⚑ **M4 names which rows carry the rounding claim, and they are the ones a
shorter sweep would drop.** Nine of the fourteen rows in M1's table use an interval that divides
the run exactly, so the ceiling mutant leaves every one of them untouched. The
claim is carried entirely by lines 15 to 19. Dropping the `ivl=3` or `ivl=7`
configuration to shorten the sweep would cost the whole rounding claim while
the row count barely moves, which is the trap E196's audit found on its own
`h=20` row.

- **The driver needs a phase or a declaration, and it takes the second.**
  `tools/test/registration.sh` G2 holds that every `tools/test/*.sh` on disk is
  dispatched by a `run_phase` line in `run-tests.sh` or declares itself out in
  its own header as `# not-a-phase:` with a reason. Phases 1-7, 13-20 and 24 are
  taken, 8-12 are held for unported old-tree phases,
  [[decisions/decision-lane-split]] reserves 21-23 for Lane B, and no band is
  reserved for this lane. E196 resolved this by declaring itself out under the
  standing suite-phase-number call in [[records/author-calls]], and E197 follows
  it. This element does not pick the number.
- **No compiler change is required, and it was checked.** The module, the root
  and all four mutants compiled and ran on today's `bin/chirality-bin` with
  nothing under `lib/` altered. The one place a compiler change could have been
  argued for is M4's wall, and M4 measures that the wall sits past any sample
  count a storage tier could hold.
- **Open questions the SPEC owes:**
  1. **`population` is a `Str`, and the boundary-sums directive says a `Str`
     encoding which-of-N is a sum in disguise.** No `Population` type exists:
     that is `unit-lane/N17`, unminted. The precedent inside this tree cuts
     both ways. `Expert` carries `sees` and `returns` as `Str` by explicit
     deferral (`prog/manas/core/types.chiral:63`, "prose descriptors here
     (typed I/O is target work)"), and `unit-lane/N13` is the row that closes
     that same deferral. So shipping `Str` here mints a second instance of a
     debt the lane already has a row for. Blocking on N17 instead costs E197 its
     independence. Neither is free and the SPEC must pick.
  2. **The refinement on `sample-every`.** M2 measures three distinct failures
     and one refinement closes two of them. `(refine I64 (> 0))` removes the
     zero divide and the negative volume. The interval-exceeds-the-run case is
     run-relative and no constructor-level predicate can see it, so it needs
     either a smart constructor taking the `RunShape`, a `VolumeR` result, or a
     stated precondition. Which of the three, and whether the refinement engine
     decides `(> 0)` on this field today, are both open.
  3. **`I64` or `VolumeR`.** M2's silent zero and M4's wrap are the same defect
     class E196 closed with `DecodeR`, and the boundary-sums directive answers
     it the same way. The cost is a second data type plus a `case` at every call
     site, on a function whose callers do not exist yet.
  4. **Whether `rr-samples` belongs to this element at all.** The row is a
     primitive at L2 and names the sum only. The pricing function is what makes
     the sum gateable, and without it E197 ships a data declaration no test can
     convict. Adding it means E197 covers a law the roster did not put in this
     row, which is the choice E196 made deliberately for N8 and N9 and which
     should be made deliberately again rather than by drift.
  5. **What the digest becomes.** M5 measures that the request is bounded and
     the trace is not, and the finding above rules that `RunManifest` cannot
     absorb it. Whether the digest is a field on `unit-lane/N11`'s trace type, a
     separate small record, or `rr-fields` and nothing more is a question E197
     can state and N11 must answer.
- **Related:** [[arcs/unit-lane-arc]] row `unit-lane/N10`; [[banks/unit]];
  [[decisions/decision-display-numerics]]; [[decisions/decision-lane-split]];
  [[records/author-calls]] for the suite-phase-number call. `unit-lane/N11` is
  the unbounded trace this request commissions and it stays unminted.
