# AI-lane encoding: continuous value to spike train and back

This note answers what sits at the seam between the manas layer (typed prose,
`Str`/`Msg`, coarse steps) and a neuron layer (spike trains, continuous time).
Nothing in the tree names this seam today. Four questions: the three named
encodings, the decode direction, whether float is required, and the shape of
a chirality sum type for it.

## 1. Three encodings

| scheme | mechanism | spike cost | latency cost | good for |
|---|---|---|---|---|
| rate | count spikes in a fixed window; more spikes means a larger value | many spikes for fine resolution (a Poisson-style train needs N spikes for N resolution levels) | full window every time, regardless of the value | robustness to per-spike noise; simple hardware (a counter); no shared clock needed beyond the window boundary |
| latency (time-to-first-spike) | one spike per neuron; a large value fires early, a small value fires late | one spike, minimal energy | average case fast, worst case is the full window when the value is small | energy-constrained links; fast reaction to a large/salient value; measured 4 to 7.5x lower latency and 3.5 to 6.5x fewer spikes than rate coding on the same task |
| population | many neurons, each tuned to a different part of the value's range (a tuning curve); the joint activity across the population is the value | each neuron can fire sparsely; cost scales with population size rather than per-neuron precision | one window, same as rate, but decode needs the whole population's count before it resolves | continuous, multi-dimensional, or circular quantities (an angle, a direction); noise averages out across redundant neurons rather than corrupting a single count |

Rate coding is a single counter and is the cheapest to build; latency coding
trades a shared time reference for the lowest spike count and the lowest
average latency; population coding trades neuron count for noise robustness
and is the only one of the three that generalizes past a single scalar.

## 2. Decoding back

All three reduce to counting, timing, or a weighted sum, over the same
spike train shape (a set of tick offsets per neuron within a window).

| scheme | decode operation |
|---|---|
| rate | `value = count / window`, or a running leaky-integrator filter for a value that updates continuously rather than once per window |
| latency | `value = (window - first_spike_tick) / window`, given a shared reference tick marking window start; no spike observed by the window's end decodes to the value's floor |
| population | `value = sum(tuning[i] * count[i]) / sum(count[i])`, the population-vector decode: a tuning-curve-weighted average across the whole population |

Each of these is division, and each division is over integers already
counted or timed. Nothing here requires calculus or a continuous kernel
integral; all three shapes as run in practice are discrete sums over ticks.

## 3. Fixed point or float

Fixed point suffices. All three decode operations are counting, integer
tick subtraction, and weighted-sum-then-divide, each expressible in a Q-format
fixed-point representation with a chosen fractional-bit width bounding the
rounding error. Loihi 2, the reference neuromorphic chip, commits to this
exactly: 32-bit fixed-point arithmetic throughout, spike payloads as
integers up to 24 bits, no floating-point unit anywhere on the chip. The
domain does not need float; it was never using one.

## 4. A chirality type for an encoding

A closed sum, one constructor per scheme, each carrying only what its decode
needs and nothing a different scheme would need instead:

```
Encoding =
    Rate       { window: Nat, count: Nat, max: Nat }
  | Latency    { window: Nat, ref: Nat, first-spike: Nat option }
  | Population { size: Nat, tuning: Array Nat, count: Array Nat }
```

| constructor | fields | why each field |
|---|---|---|
| `Rate` | `window`, `count`, `max` | `window` and `count` decode the fraction; `max` is the count that maps to the value's ceiling, fixing the Q-format scale without a float |
| `Latency` | `window`, `ref`, `first-spike` | `ref` is the shared clock tick the window opened on, required because a single spike carries no value without it; `first-spike` is `option` because a value below the window's floor never fires |
| `Population` | `size`, `tuning`, `count` | `tuning` is each neuron's preferred value (fixed-point, one per neuron); `count` is each neuron's spike count in the window; `size` bounds both arrays and lets the decode reject a malformed pair |

`Rate` and `Latency` both name a `window`, and it stays a shared field
rather than a shared constructor, because their decode arithmetic differs
(division for `Rate`,
subtraction-then-division against `ref` for `Latency`). `Population` carries
two arrays rather than a scalar because its decode is a weighted sum across
neurons, the one shape here that a single-neuron encoding cannot express.

## Sources

- [Neural Coding in Spiking Neural Networks: A Comparative Study for Robust Neuromorphic Systems](https://pmc.ncbi.nlm.nih.gov/articles/PMC7970006/)
- [T2FSNN: Deep Spiking Neural Networks with Time-to-first-spike Coding](https://arxiv.org/pdf/2003.11741)
- [First-spike coding promotes accurate and efficient spiking neural networks for discrete events with rich temporal structures](https://pmc.ncbi.nlm.nih.gov/articles/PMC10577212/)
- [Supervised Learning With First-to-Spike Decoding in Multilayer Spiking Neural Networks](https://pmc.ncbi.nlm.nih.gov/articles/PMC8072060/)
- [INFORMATION PROCESSING WITH POPULATION CODES](https://www.cs.toronto.edu/~zemel/documents/popCodeReview.pdf)
- [Population Codes: Theoretic Aspects](https://www.cns.nyu.edu/malab/static/files/publications/_old/2009%20Ma%20Pouget.pdf)
- [A Look at Loihi 2 - Intel - Neuromorphic Chip](https://open-neuromorphic.org/neuromorphic-computing/hardware/loihi-2-intel/)
- [Adding numbers with spiking neural circuits on neuromorphic hardware](https://arxiv.org/pdf/2503.10387)
