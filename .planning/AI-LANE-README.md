# The unit lane

> A design document for a system that does not exist. Present tense throughout
> describes intended behaviour. Nothing here is built, and no claim below has a
> gate behind it.

## What it is

A way to build and run networks of configurable computational units. One typed
protocol spans a spiking neuron population, a transformer instance and a pure
function. A network is a value: populations, the projections between them, and
the discipline that advances them in time.

Everything is integer arithmetic. The type system carries the scale, the bounds
and the effect discipline, so a class of failures that other frameworks find by
testing is refused at compile time here.

## 1. The unit

The core abstraction carries five things.

| | |
|---|---|
| input ports | typed |
| output ports | typed |
| state | declared, bounded, with a decay or eviction rule |
| arrival | request-response, streaming, or continuous |
| update | frozen, offline-trained, or online-local |

The interface and the implementation are separate declarations. One unit
interface admits several implementations, selected per backend and per
precision, so the same network description runs against different substrates.

## 2. Compartments

A unit is a tree of compartments, and the **branch** is the addressable object.
It carries three things at once: the nonlinearity, the gating, and the memory.

Inputs group onto branches. Each branch applies a nonlinearity to its local sum.
Branch outputs combine at the soma, which applies its own threshold. Input A
alone does nothing, input B alone does nothing, A and B on the same branch inside
a window fire the branch. A local AND gate.

The consequence is that a unit is a bank of independently gated detectors sharing
one output line. Several patterns live in one tree without interfering, because
gating keeps them apart.

### The axes

| axis | what varies |
|---|---|
| distance from soma | a distal input contributes less at the soma, and its time course spreads |
| which branch | same-branch inputs sum superlinearly, cross-branch inputs sum linearly |
| local threshold | how many coincident inputs trigger the branch |
| timing window | how far apart two inputs may arrive and still coincide |

Distance dependence is itself tunable. Scaling a distal input's weight upward
makes its somatic contribution location-independent when that is wanted.

### The modulators

| modulator | effect |
|---|---|
| branch-targeted inhibition | vetoes one branch. Pathway-specific gating rather than a blanket. Inhibition placed distal to the excitation is more effective than inhibition near the soma, and it works by raising the local threshold |
| gain signals | raise or lower branch excitability, changing how many coincident inputs a branch needs |
| the inward edge | a somatic firing propagates back into the unit's own tree, and meeting an active branch it produces a burst |

That last row is a feedback edge from a unit's output into its own input
combination. It runs against the direction every other crossing takes.

### Two thresholds

Computation is analog, then discrete, then analog, then discrete: local
integration on a branch, the branch threshold, summation at the soma, the somatic
threshold. Nested thresholds at two spatial scales, each with its own time
constant.

## 3. Networks

| construct | what it is |
|---|---|
| population | a count, a unit model, parameters, and a dedication naming what the group is for |
| projection | a pre-population, a post-population, a connector, and a target compartment |
| connector | a closed sum: all-to-all, one-to-one, fixed-probability, explicit list |
| routing table | a pure function from a source address to a target list |

A projection addresses a compartment inside a unit. Addressing a whole unit
collapses the branch structure back into one shared threshold and discards what
compartments buy.

Inhibition is a second routing target, since a veto names a branch.

## 4. Time

`Advance` is a closed sum.

| arm | meaning |
|---|---|
| `advance-tick` | state advances on a fixed interval |
| `advance-on-event` | state advances when a message arrives |
| `advance-hybrid` | the tick and event members are named as data |

The membrane is built once per member rather than once per network. A
tick-driven member is pure between two fixed-interval crossings. An event-driven
member is pure between two arrival-set crossings. Both satisfy pure inside and
crossing at the boundary, and the boundary is arbitrated per member. No shared
clock, and no global timestamped queue.

## 5. Encoding

The seam between values and spike trains.

| encoding | carries | decode |
|---|---|---|
| `Rate` | a window, a count, a maximum | counting |
| `Latency` | a window, a reference, a first-spike time | integer subtraction of ticks |
| `Population` | a size, tuning per unit, counts per unit | a weighted sum then a divide |

Every decode is integer arithmetic. `Population` carries arrays where the others
carry scalars, since its decode spans the whole group.

## 6. Learning

Traces live where the update happens; signals come from somewhere else.

**Per synapse**, an eligibility trace accumulates local activity. **A modulator**
is a dedicated unit kind with one output, large fan-out, and no per-unit state.
It reaches units through a fixed random projection whose weights are set once and
never trained, which sidesteps the need for feedback connections that mirror the
forward ones.

Four channels leave a modulator, and only one of them carries error.

| channel | role |
|---|---|
| error | the learning signal itself |
| learning rate | how fast a trace moves a weight |
| inverse temperature | how random action selection is |
| discount factor | the timescale over which future value counts |

An update is the trace multiplied by the broadcast signal, summed over time. No
unrolled history is stored, so updates run online.

**Structural plasticity** changes where a synapse sits rather than what it
weighs. Since placement determines which branch an input lands on, it changes
what the unit computes.

**A consolidation mode** is a phase where the network reorganizes instead of
computing. Structural change happens there, separated from the online updates
that run during inference.

## 7. Numerics

| quantity | width |
|---|---|
| weight | 8 bits, 16 where precision demands it |
| unit state | 16 to 24 bits |
| accumulator | up to 32 bits |
| message | up to 32 bits |
| scale | a power of two, so rescaling is a shift |

Fixed point with the scale in the type. Mixed-scale arithmetic is a type error.
Determinism follows, which matters because the surrounding tree gates on a
byte-identical rebuild.

The discretized unit update is multiply-accumulate against constant
coefficients, with no transcendental functions anywhere. The transformer
nonlinearities have integer algorithms: a polynomial for the activation
function, a stabilized polynomial with shifts for the normalizing exponential,
and an iterative integer square root for layer normalization.

## 8. Observation

Two shapes, and each covers what the other cannot.

| | sampled trace | run manifest |
|---|---|---|
| granularity | per timestep | per run |
| carries | spikes, state, weights | a structured digest of a completed run |
| size | grows with population times duration | bounded by construction |
| answers | what happened at time t | what the run decided and whether it conformed |

A recording request names what to capture and at what sampling interval, and the
interval is an integer multiple of the timestep. The bounded manifest keeps a
digest; the trace rides beside it as a separate value.

## 9. What the type system guarantees

Four failures are refused structurally.

| failure | mechanism |
|---|---|
| a loop does not terminate | totality, demanded by the profile |
| a resource leaks or is consumed twice | linear types |
| an unhandled state is reached | closed sums with enforced coverage |
| behaviour changes under timing variation | each unit is a continuous mapping from input streams to output streams, so output histories depend on input histories alone |

Conventional frameworks find all four by testing.

Two more are outside that set.

**Bounded values are reachable.** A state variable with a declared range is a
refinement, and runaway accumulation becomes a type error. This needs saturating
arithmetic, which is a named gap.

**Convergence is not.** Totality proves a loop stops. It says nothing about
whether it stopped somewhere useful. No type system provides this, and a freely
designed unit has no reference implementation to check against, so both
correctness and convergence are measurement questions needing a corpus and a
gate.

That split is the organizing distinction: structural stability is type-level
work, dynamical stability is gate-level work, and they need different evidence.
