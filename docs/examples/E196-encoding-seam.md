---
element: E196
slug: encoding-seam
title: "**`Encoding`: the seam between a continuous value and a spike train**"
kind: BUILD-PROPER
reference_class: PAPER/IMPL
ours_source: (none)
status: drafted
updated: 2026-09-05
---

# E196 — **`Encoding`: the seam between a continuous value and a spike train**

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E196, the closed sum that names how a value is carried as spikes,
  together with the encode and decode arithmetic over it. It covers
  `unit-lane/N8` and `unit-lane/N9` from [[arcs/unit-lane-arc]] as one decision,
  because a constructor's fields and its decode arithmetic constrain each other:
  a field the decode never reads is dead, and a decode that reaches for a field
  the constructor lacks is a type error found at the SPEC stage instead of here.
- **Kind:** BUILD-PROPER.
- **Why chirality needs its own:** the seam has no shard in this tree. A grep of
  `lib/` and `prog/` for `spike`, `neuron`, `tuning`, `population vector` and
  `first-spike` returns **zero files** (measured 2026-09-05 at `fc53378`), and
  [[banks/unit]]'s nineteen-shard refraction names no encoding shard: its shard B
  is the `Ty`/`Shape` payload type and its shard G is the `Backend` model
  crossing, both above this layer. The census at `471f688` reached the same
  answer for the whole `origin: new` roster.
- **Out of scope:** any neuron model, any network construct, any execution
  discipline. Those are `unit-lane/N15` through `N23` and none is minted.

⚑ **The element defines a seam and encodes nothing real.** No population exists
to consume a spike train, so the deliverable is the sum, the decode, and a gate
over the round trip. §6 says what that gate ends in, what it cannot end in
yet, and shows three mutants reddening it.

## 2. Research

- **Reference class:** `PAPER`/`IMPL`, and EXTERNAL. No in-tree baseline exists.
  The research is `.planning/AI-LANE-ENCODING.md`, drawn from the SNN neural
  coding literature (rate, time-to-first-spike, population-vector decoding) and
  from Loihi 2's committed arithmetic. This run does not redo it.
- **The three schemes, and what each decode reads.** Rate counts spikes in a
  window. Latency carries one spike whose offset from a shared reference is the
  value. Population spreads the value across a group of units, each with its own
  preferred value, and decodes the group's joint activity as a weighted average.
- **Fixed point suffices, and the domain never used a float.** Loihi 2 is 32-bit
  fixed point throughout, with spike payloads as integers up to 24 bits and no
  floating-point unit on the chip. [[decisions/decision-display-numerics]] rules
  the same way for this tree's own reasons, one of which applies with full force
  here: float rounding varies across emit paths, and the build rule gates on a
  byte-identical fixpoint.

### The measurements this pre-run owes

All figures below come from one chirality program written for this run, compiled
and executed with today's `bin/chirality-bin`. It declares the `Encoding` sum,
implements one total `enc-decode` over all three arms, sweeps each encoding's
whole domain, and prints `domain=` `exact=` `maxerr=` per configuration.
Section 5 carries the program's spine verbatim. It touches no file under `lib/`,
`prog/` or `tools/`.

**M1 · Rate. The round trip is exact iff `max <= window`, and lossy above it.**

| `window` | `max` | domain | exact | max error | `ceil(max/window)` |
|---|---|---|---|---|---|
| 100 | 100 | 101 | **101** | 0 | 1 |
| 100 | 50 | 51 | **51** | 0 | 1 |
| 255 | 255 | 256 | **256** | 0 | 1 |
| 100 | 400 | 401 | 101 | 3 | 4 |
| 32 | 1000 | 1001 | 9 | 31 | 32 |
| 16 | 255 | 256 | 2 | **16** | 16 |
| 7 | 255 | 256 | 2 | **37** | 37 |
| 3 | 100 | 101 | 2 | 33 | 34 |
| 1 | 100 | 101 | 2 | 99 | 100 |

The first three rows close exactly over the whole domain. Above `max = window`
the window holds `window + 1` codes for `max + 1` values, so most values cannot
survive; the exact count collapses to single digits rather than settling at the
code count, because encode truncates down and decode truncates down again.
`maxerr <= ceil(max/window)` holds in all nine configurations and is reached in
two of them. That is a measured bound over this sweep and not a proof.

The research's phrase "loses resolution below one spike per window" is the
`window=16 max=255` row read at the bottom of the domain: every value under 16
encodes to a count of 0 and decodes to 0.

**M2 · Latency. The round trip is exact over the whole domain, and the domain is
the window.**

| `window` | `ref` | domain | exact | max error |
|---|---|---|---|---|
| 100 | 1000 | 101 | **101** | 0 |
| 16 | 0 | 17 | **17** | 0 |
| 1024 | 1000000 | 1025 | **1025** | 0 |

Encode is `ref + (window - v)` and decode is `window - (first-spike - ref)`.
Both are integer addition and subtraction with no division anywhere, so nothing
truncates and every value in `[0, window]` comes back. The loss is entirely at
the boundary: the constructor's fields carry `window`, `ref` and `first-spike`
and no scale, so the representable set is exactly the `window + 1` tick offsets
and a value outside it has no code at all.

⚑ **This is a finding about the field list, and it is the SPEC stage's fork.**
`Rate` carries `max` and lands its decode on `[0, max]`. `Latency` as the
research states it carries no `max` and lands its decode on `[0, window]`. Two
constructors of one sum therefore decode onto two different domains, and a
caller reconciling them divides outside the type, which is the mixed-scale
arithmetic [[decisions/decision-display-numerics]] calls a type error. Either
`Latency` gains `max` and becomes symmetric with `Rate`, or the sum declares
that ticks are the scale and `Rate`'s `max` goes. Both close it; picking is SPEC
work.

**M3 · Population. The round trip closes at the tuning values and nowhere
reliably, and overlap decides the rest.** Tuning is `size` preferred values
evenly spread over `[0, max]`; each unit fires a triangular count of peak `k`
inside a half-width `h` and nothing outside it.

| `size` | `max` | `h` | `k` | domain | exact | max error | max numerator |
|---|---|---|---|---|---|---|---|
| 8 | 1000 | 20 | 100 | 1001 | 8 | **980** | 100,000 |
| 8 | 1000 | 200 | 100 | 1001 | 247 | 33 | 135,406 |
| 8 | 1000 | 400 | 100 | 1001 | 38 | 91 | 213,669 |
| 32 | 1000 | 100 | 100 | 1001 | 430 | 24 | 288,624 |
| 64 | 65536 | 4096 | 1024 | 65537 | 2014 | 1028 | 252,848,138 |

The `h = 20` row is the sharpest one. Spacing is `1000/7 = 142` and the
half-width is 20, so exactly the 8 tuning values come back exactly, and a value
more than 20 from every tuning value fires **no unit at all**: the denominator is
zero, the decode returns 0, and the error is the whole value. The 980 is
`v = 980` decoding to 0 with the nearest tuning value at 1000 and `|980-1000|`
not under 20.

⚑ **A zero denominator is reachable, and the total decode hides it.** Returning
0 makes a silent window indistinguishable from a genuine floor value, which is
the `Str`-tag defect the boundary-sums directive names one type up: the
information exists at the decode and is absent at the caller. The repair is a
result sum rather than an `I64`, and §5 writes it.

Comparing the `h = 200` and `h = 400` rows: more overlap is worse here (247
exact against 38), because a wider curve pulls distant tuning values into the
average. More units is better (`size = 32` at 430 exact against `size = 8` at
247). Neither reaches exactness, so Population's assertion is a bounded error
against a stated configuration and never an equality.

**M4 · The products fit `I64`, so `op-mulhi` stays out and E189 stays off this element's path.**
The numerator is `sum(tuning[i] * count[i])`, bounded by
`size * max-tuning * max-count`. Four probes, each computing the real dot product
on today's binary with every unit at its peak count:

| `size` | max tuning | `k` | numerator | denominator | decode |
|---|---|---|---|---|---|
| 64 | 65,536 | 1,024 | 2,147,451,904 | 65,536 | 32,767 |
| 64 | 2,147,483,647 | 65,536 | 4,503,599,623,241,728 | 4,194,304 | 1,073,741,823 |
| 64 | 1,099,511,627,776 | 16,777,216 | **-520,093,696** | 1,073,741,824 | **-1** |
| 1024 | 1,099,511,627,776 | 16,777,216 | **-8,573,157,376** | 17,179,869,184 | **-1** |

Row 2 is the realistic ceiling: a `size` of 64, tuning at the top of a signed
32-bit Q-format, and a count of 2^16 per unit produce 4.50e15, which is 0.05% of
`I64`'s 9,223,372,036,854,775,807. Every product and every partial sum fits with
three orders of magnitude of headroom, so **the element needs no high half and no
new numeric primitive, and the zero-compiler-changes constraint holds.**

Rows 3 and 4 are past the wall and are printed to show the failure mode: the
accumulator wraps, the decode returns -1, and nothing traps. ⚑ **E189 would not
repair those rows.** At a tuning ceiling of 2^40 and a count of 2^24 a *single*
product is already 2^64, so `op-mulhi` would be needed, and the *accumulator*
overflows as well, which `op-mulhi` does not address. The guard that belongs here
is a bound on the constructor's fields, which is a refinement type and costs
nothing outside this element. E189 stays what it is: unowned, a `lib/` edit
owing a fixpoint, and unrelated to this element's pricing.

## 3. Conventional (other-language) approach

Every spiking framework in the reference class writes this as a family of
functions over float arrays, with the scheme chosen by a string or an enum
outside the data.

```python
# snnTorch / Nengo / BindsNET all shape it roughly this way.
def encode(x, scheme="rate", T=100, num=64):
    if scheme == "rate":
        return (torch.rand(T, *x.shape) < x).float()      # x in [0.0, 1.0]
    if scheme == "latency":
        return spikegen.latency(x, num_steps=T, tau=5.0, threshold=0.01)
    if scheme == "population":
        centers = np.linspace(0.0, 1.0, num)
        return np.exp(-((x[:, None] - centers) ** 2) / (2 * sigma ** 2))
    raise ValueError(scheme)                               # reachable at runtime

def decode(spikes, scheme="rate"):
    if scheme == "rate":
        return spikes.mean(0)                              # loses T
    ...
```

- **Assumptions it bakes in:**
  - **Floats everywhere**, including the tuning curve's exponential, so the
    round trip's error depends on the accumulation order and cannot be pinned.
  - **The scheme is a string.** `raise ValueError(scheme)` is reachable, the
    encoder and the decoder agree by convention, and a run that encodes as rate
    and decodes as latency is a silent wrong answer.
  - **The parameters escape the value.** `T`, `tau`, `threshold` and `sigma` are
    call arguments the spike tensor does not carry, so the decoder must be
    handed the same numbers again or it silently rescales.
  - **Silence is a zero.** An empty window and a genuine zero are the same
    tensor, at every layer, forever.
  - **Partiality is the error channel.** The failure is an exception raised from
    inside the arithmetic rather than a value in the signature.

## 4. The chirality idea

- **Chirality features in play:** the closed sum with an exhaustive `case`
  (boundary sums, the standing directive); errors as values; the `I64` floor and
  the float wall; totality; refinement types on the constructor's fields; the
  `->` membrane, since every decode here is pure.
- **The reframing.** The scheme stops being a string beside the data and becomes
  the data. `Encoding` is one closed sum with one constructor per scheme, each
  carrying exactly the fields its own decode reads, so the parameters travel with
  the spikes and an encoder and a decoder cannot disagree about `window` or
  `max`. `enc-decode` is one function with three arms and no `_`, which makes the
  coverage checker the thing that proves a new scheme was decoded rather than a
  code review. Because the whole decode is counting, integer subtraction and a
  weighted sum over `I64`, its signature is `->`: an empty effect row, a typed
  fact that decoding crosses nothing.
- **What chirality makes impossible here:**
  - **An unknown scheme.** There is no `raise ValueError` arm to reach, because
    the sum is closed at three and `case` is coverage-checked.
  - **A decode reading a field its constructor lacks.** `Latency` has no `max`
    and cannot be given one at the call site.
  - **A float sneaking into the tuning curve.** The tree has no float type, so
    the triangular curve above is the arithmetic that survives; §2 M3 measures
    what it costs, and the cost is stated rather than assumed away.
  - **A silent window pretending to be a zero**, once the decode returns
    `DecodeR` rather than `I64`. The measured 980 error in §2 M3 is exactly this
    case, and the type is what removes it.

## 5. Chirality example (fleshed)

Real surface syntax. Every form below compiled and ran under today's
`bin/chirality-bin` while producing §2's figures, apart from the `DecodeR`
variant at the end, which is the recommendation §2 M3 argues for.

```chirality
(import "prelude/prelude")
(import "prelude/list")

; ── the seam. One closed sum, one constructor per scheme, each carrying what
; its OWN decode reads and nothing another scheme would want instead.
(data Encoding ()
  (enc-rate       (window I64) (count I64) (max I64))
  (enc-latency    (window I64) (ref I64) (first-spike (Maybe I64)))
  (enc-population (size I64) (tuning (List I64)) (count (List I64))))

; `Population` is the one arm carrying arrays, because its decode spans the
; whole group. `Rate` and `Latency` decode one unit and carry scalars.

(declare enc-dot (-> (List I64) (List I64) I64))
(def enc-dot (lam (a b)
  (case a
    (nil 0)
    ((cons x xs) (case b
       (nil 0)
       ((cons y ys) (+ (* x y) (enc-dot xs ys))))))))

(declare enc-sum (-> (List I64) I64))
(def enc-sum (lam (a)
  (case a (nil 0) ((cons x xs) (+ x (enc-sum xs))))))

; ── ONE total decode over the sum. Three arms, no `_`, integer only, and `->`
; because nothing here crosses. Counting, tick subtraction, weighted sum.
(declare enc-decode (-> Encoding I64))
(def enc-decode (lam (e)
  (case e
    ((enc-rate w c m) (/ (* c m) w))
    ((enc-latency w r f)
      (case f
        (none 0)
        ((some t) (- w (- t r)))))
    ((enc-population n ts cs)
      (let (den (enc-sum cs))
        (case (=i den 0)
          (true 0)
          (false (/ (enc-dot ts cs) den))))))))

; ── the encoders, one per arm, each the inverse of its own decode arm.
(def enc-rate-of (-> I64 I64 I64 Encoding)
  (lam (w m v) (enc-rate w (/ (* v w) m) m)))

; a large value fires EARLY, so the offset is the window's complement; a value
; at the floor never fires and the field is `none`.
(def enc-latency-of (-> I64 I64 I64 Encoding)
  (lam (w r v)
    (case (=i v 0)
      (true  (enc-latency w r none))
      (false (enc-latency w r (some (+ r (- w v))))))))

; triangular tuning of half-width h and peak k. The exponential of the
; conventional version is what the float wall removes; §2 M3 prices the swap.
(declare enc-counts (-> (List I64) I64 I64 I64 (List I64)))
(def enc-counts (lam (ts v h k)
  (case ts
    (nil nil)
    ((cons t r)
      (let (d (enc-abs (- v t)))
        (case (<i d h)
          (true  (cons (- k (/ (* k d) h)) (enc-counts r v h k)))
          (false (cons 0 (enc-counts r v h k)))))))))
; … enc-abs, enc-tuning (size preferred values evenly over [0,max]) elided.
```

**The recommended decode signature, which §2 M3 measures the need for.** The
`I64` version above returns 0 for a silent population and 0 for a floor value,
and the measurement reached that arm with an error of 980:

```chirality
; the reason exists at the decode and must not be re-derived downstream.
(data DecodeR ()
  (d-val    (v I64))
  (d-silent))                    ; no unit fired inside the window

(declare enc-decode-r (-> Encoding DecodeR))
(def enc-decode-r (lam (e)
  (case e
    ((enc-rate w c m) (d-val (/ (* c m) w)))
    ((enc-latency w r f)
      (case f
        (none (d-silent))
        ((some t) (d-val (- w (- t r))))))
    ((enc-population n ts cs)
      (let (den (enc-sum cs))
        (case (=i den 0)
          (true  (d-silent))
          (false (d-val (/ (enc-dot ts cs) den)))))))))
```

- **Knobs to modify:** the field lists, which is where §2 M2's fork lands
  (`Latency` gains `max`, or `Rate` loses it and ticks become the scale); the
  tuning curve's shape, `h` and `k`, which §2 M3 shows moving the error by an
  order of magnitude; the refinement bounds on `Population`'s fields, which are
  what keep §2 M4's numerator inside `I64`; whether `enc-decode` returns `I64` or
  `DecodeR`.
- **Deliberately omitted:** the leaky-integrator running decode the research
  names as `Rate`'s alternative, which needs the time parameter of
  `unit-lane/N7`; any spike train representation richer than a count and an
  offset; anything that produces or consumes these values, since no population
  exists.

## 6. Use / modify notes

- **Lands in:** a new module. `lib/` has thirteen subdirectories today
  (`capability`, `crypto`, `evidence`, `lowering`, `memory`, `module`, `ports`,
  `prelude`, `protocol`, `runtime`, `surface`, `text`, `typing`) and none is this
  lane's, so `lib/unit/encoding.chiral` is the proposal and naming the directory
  is part of it. The module is category A with an empty port set, pure `->`
  throughout, which is why the ledger files E196 under **VAL**.
- **Conformance target, and it is something that runs.** A root that constructs
  each of the three constructors, sweeps its domain, and prints one line per
  configuration carrying `domain=`, `exact=` and `maxerr=`, with a shell driver
  in `tools/test/` comparing those lines against pins. The pins are §2's tables.
  What each row asserts differs by arm, and that is the answer to what the gate
  can assert:

| arm | the assertion | why it is that shape |
|---|---|---|
| `Rate` | **exact equality**, on the restricted domain `max <= window` | measured: 101 of 101, 51 of 51, 256 of 256 |
| `Rate` | **a bounded error**, `maxerr <= ceil(max/window)`, above that domain | measured over six configurations, reached in two |
| `Latency` | **exact equality**, unrestricted over `[0, window]` | measured: 101 of 101, 17 of 17, 1025 of 1025. No division occurs |
| `Population` | **a bounded error** against a stated `size`, `h` and `k`, plus a positive assertion that a silent window decodes to `d-silent` | measured: exactness only at the `size` tuning values, and a reachable zero denominator |

⚑ **A pinned line asserts an equality, and the bound is a second check.**
Comparing `exact=9 maxerr=31` against a golden line asserts `maxerr == 31`. It is
stronger than `maxerr <= ceil(max/window)` on that one row and says nothing about
the law, which §2 M1 already calls a measured bound over this sweep. The driver
gets one or the other by construction: pin the observed integers, or compute
`ceil(max/window)` in the root and pin the verdict it prints. A table promising a
bound over a driver that pins an integer is a gate aimed past its own claim, so
the SPEC picks and says which. The `d-silent` half of `Population`'s row is
likewise unmeasured here: §5's `DecodeR` variant is written and no sweep runs it,
so that assertion has no figure and no mutant yet.

⚑ **The driver needs a phase or a declaration, and it has neither.**
`tools/test/registration.sh` G2 holds that every `tools/test/*.sh` on disk is
dispatched by a `run_phase` line in `run-tests.sh` or declares itself out in its
own header as `# not-a-phase:` with a reason, and a script that lands as neither
reddens G2 on the next suite pass. Phase 7 sweeps
`grep -rl '^(def compile-main' lib prog`, so it compiles the root and executes
nothing, and `tools/` sits outside that census entirely. Phases 1-7 and 13-20 and
24 are taken, 8-12 are held for unported old-tree phases,
[[decisions/decision-lane-split]] reserves 21-23 for Lane B, and no band is
reserved for this lane, so the number is an author call. `crypto.sh` and
`tal-check.sh` are the standing precedent and both sit undispatched: a gate
declared out is a gate that does not run.

- **The gate can fail, demonstrated.** Three mutants were built and run on
  today's binary:

| mutant | change | effect |
|---|---|---|
| **M1** | `Rate`'s decode divides by `window + 1` | all nine rate rows redden on the exact count, every one of them falling to **1**: 101 → **1**, 51 → **1**, 256 → **1**, 9 → **1**, 2 → **1**. `max error` rises on eight and holds at 99 on `window=1, max=100`, where the exact count is the whole conviction |
| **M2** | `Latency`'s decode drops the window complement, returning `first-spike - ref` | every latency row reddens: exact 101 → **2**, 17 → **2**, 1025 → **2**, `max error` 0 → `window` |
| **M3** | `Population`'s tuning curve goes rectangular, firing a flat `k` inside `h` | three of the four rows redden: exact 247 → **13**, 38 → **7**, 430 → **53**. The `h = 20` row does not move, at 8 exact and 980 max error either way |

  Each mutant reddens its own arm and leaves the other two rows untouched, so a
  reddened row names the arm that broke it.

⚑ **The `h = 20` row cannot see the curve's shape.** Spacing is 142 and the
half-width is 20, so at most one unit ever fires, and one unit's weighted average
is its own tuning value whatever count that unit carries. The row carrying the
load-bearing 980 is blind to the whole tuning-curve defect class, and the three
overlapping rows are what convict it. A fourth mutant dropping the zero
denominator guard does reach it, reddening all four rows and taking `h = 20`
from 8 exact to **6**.

  The exact counts are the load-bearing pins. A row asserting only "the two
  agree" would pass under a decode that always returns its input, which is the
  positive-presence rule `prog/e188-apply-spine.prog` states for its own R4.
- **Open questions the SPEC owes:**
  1. **`Latency`'s scale.** §2 M2's fork. Two constructors decoding onto two
     domains is settled by adding `max` to `Latency` or by removing it from
     `Rate`, and the sum cannot ship with both.
  2. **`I64` or `DecodeR`.** §2 M3 measured a reachable silent arm. The boundary
     sums directive answers it one way and the cost is a second data type plus a
     `case` at every call site.
  3. **The refinement on `Population`'s fields.** §2 M4 gives the bound
     (`size * max-tuning * max-count < 2^63`) and the failure past it (a wrapped
     accumulator decoding to -1). Whether that becomes a `refine` on the
     constructor, a checked smart constructor returning a result sum, or a
     documented precondition is undecided.
  4. **The array type.** `Population` is written here with `(List I64)`, which
     makes the decode a fold and pairs two lists whose lengths only `size`
     relates. A length-indexed pair would make the mismatch untypeable and costs
     dependent machinery this element has not priced.
  5. **The directory.** `lib/unit/` is a new subdirectory of `lib/` and the
     module key is the root-relative path, so naming it is a `MAP.md`-visible
     choice rather than a free one. Two measurements bear on it. `MAP.md`'s own
     `lib/` tree lists twelve directories and the filesystem holds thirteen, so
     that listing is already one behind and gains a second gap here. And every
     shard [[banks/unit]] refracts sits under `prog/manas/`, including the closed
     sums `Expert`, `Flow` and `StopPolicy` and the `Backend` porttype the bank
     records as an anomaly for living outside `lib/ports/`. `prog/` is what
     chirality ships and `lib/` is what it is, so an application-domain sum for a
     neuron lane has a claim on `prog/` that this element has not weighed.
     `lib/manifest/` is the counter-precedent: [[decisions/decision-lane-split]]
     lands Lane B in a new `lib/` subdirectory by author call.
  6. **The gate's phase number.** No band is reserved for this lane and 8-12,
     21-23 are held. The driver is dispatched at a number the author assigns or
     it declares itself `# not-a-phase:` and does not run.
- **Related:** [[arcs/unit-lane-arc]] rows `unit-lane/N8` and `unit-lane/N9`;
  [[banks/unit]]; [[decisions/decision-display-numerics]];
  [[decisions/decision-lane-split]]. E189 stays a separate, unowned element, per §2 M4.
