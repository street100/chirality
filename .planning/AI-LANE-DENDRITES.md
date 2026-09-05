# Dendritic computation as a candidate for the unit layer

Where dendritic computation sits, what it changes about the unit, and what
that does to the layer stack `AI-LANE-GAP.md` already drew and the `Advance`
sum `AI-LANE-EXECUTION.md` already proposed.

## 1. Position and what it changes

Dendritic computation sits between the synapse and the soma. It is the only
place inputs get combined before the output decision.

| | perceptron | dendritic unit |
|---|---|---|
| combination | one sum, one threshold | branches sum locally, each nonlinear; branch outputs combine at the soma |
| a single input alone | contributes linearly to the one sum | does nothing |
| two inputs on one branch | linear, same as two inputs anywhere else | inside a coincidence window, an AND: the branch fires |
| two inputs on different branches | linear, same as above | sum linearly, no AND |

A branch is a local AND gate. Input A alone does nothing. Input B alone does
nothing. A and B on the same branch inside a window fires it. `threshold(sum
of w*x)` has no branch boundary, so it has no coincidence test to run, at any
input count.

## 2. The axes and their modulators

Four axes set a branch's behavior.

| axis | what it measures | measured value |
|---|---|---|
| distance from soma | somatic EPSP for a distal synapse | 4.6, 3.6, 2.9 mV at 50, 150, 250 micrometres; half-width and risetime grow with distance |
| which branch | same-branch vs cross-branch summation | same-branch sums superlinearly; cross-branch sums linearly |
| local threshold | coincident synapse count needed to trigger a regenerative event | set per branch, by local channel density |
| timing window | relative arrival of excitation against inhibition | decides whether a coincidence lands inside or outside the branch's AND window |

Dendritic democracy complicates the first axis by design: synaptic scaling
gives distal synapses larger conductances, so somatic amplitude becomes
location-independent. Location dependence turns from a fixed cable property
into a tunable one.

Four modulators act on those axes.

| modulator | mechanism | effect |
|---|---|---|
| branch-specific inhibition | shunting inhibition on a branch | vetoes that branch; inhibition distal to the excitation is more effective than inhibition near the soma |
| off-path inhibition | raises local spike threshold | pathway-specific gating, the branch carrying the excitation stays untouched |
| acetylcholine | blocks potassium channels | raises dendritic excitability; fewer coincident synapses needed to trigger an NMDA spike |
| dopamine | receptor-subtype dependent | raises or lowers excitability, direction set by which receptor is present |
| back-propagating spike | a somatic spike meets a distal plateau | turns one spike into a high-gain burst, a feedback edge from output into input combination |

## 3. Mechanism in order

| step | event | timescale |
|---|---|---|
| 1 | spike arrives at a synapse on a branch | sub-millisecond, local depolarization |
| 2 | passive spread along the branch | same order, attenuating and filtering |
| 3 | coincident same-branch input crosses the local threshold | a regenerative event, all-or-none |
| 4 | the plateau persists | tens to hundreds of milliseconds, a local memory trace |
| 5 | the plateau depolarizes neighbouring segments | lowers their threshold, enables sequence detection across the tree |
| 6 | the summed effect reaches the soma | may cross the somatic threshold and spike |

Two discrete thresholds sit at two spatial scales, step 3's branch threshold
and step 6's somatic threshold, with continuous integration filling the
interval between them.

`AI-LANE-EXECUTION`'s `Advance` sum classifies a member's trigger as tick
against event, chosen once per member, or split per member under
`advance-hybrid`. The mechanism above nests two thresholds inside one
member. Step 3 is event-shaped: a crossing with no fixed schedule. Step 4's
plateau is duration-shaped: a state that persists across a window. What
wakes the soma at step 6 is that persistence, distinct in kind from a single
event's instant crossing. `Advance` carries a slot for tick, a slot for
event, and a slot for a per-member split between the two. It carries no slot
for two thresholds nested inside one member at two spatial scales, one
event-shaped and one duration-shaped. A dendritic unit needs that fourth
shape, or its trigger flattens onto whichever of tick or event the existing
three constructors can approximate.

## 4. What it does to the layer stack

Three findings converge on the branch as the shared locus:

- the unit of nonlinearity is the branch (step 3's local threshold)
- the unit of gating is the branch (branch-specific inhibition, section 2)
- the unit of memory is the branch (step 4's plateau, a local trace)

The branch is the addressable object. A projection that targets a whole unit
can only add another line to a sum arriving at one shared threshold, which
throws away the AND-gate structure section 1 found. A projection that
targets a compartment can express "synapse X projects onto branch 3's
coincidence window," and that address is what carries nonlinearity, gating,
and memory together.

`AI-LANE-GAP` draws L3 as "the unit: stateful, typed ports, one
implementation per backend" and L4 as "topology: populations, projections,
connectors, routing tables," with the boundary set at the unit. Section 2's
modulators and section 3's mechanism both name the branch as the atom that
carries nonlinearity, gating, and memory. The L3/L4 boundary in
`AI-LANE-GAP` is drawn against the wrong atom: a routing table needs an
address one level finer
than which unit, down to which branch of which unit, or every dendritic
effect above collapses back into the single per-unit sum section 1 started
from.

Nothing in the stack today carries the feedback edge section 2's last
modulator named: a somatic spike returning into the same member's dendrite
after that member has already advanced. `Advance`'s `=>` crosses outward from
a member when it fires. No primitive carries a signal back into a member's
own dendrite once it has fired, which is what a back-propagating-spike burst
requires.

## 5. The fork: declarative against emergent ordering

Biology grows branch-level ordering through structural plasticity. Which
synapses land on which branch, at what distance, is the product of a slow
developmental and activity-dependent process. That ordering is unsupervised,
and it is unreadable after the fact: no closed form recovers why a mature
branch's threshold sits where it does from the branch alone.

A freely designed system can skip that history. A branch condition, a
coincidence window, a synapse set, a local threshold, can be given directly
as a value, checkable and composable the way `Advance`'s own constructors
are.

| choice | cost |
|---|---|
| declare the branch condition as a value | forfeits the network's own capacity to discover a partition nobody specified in advance |
| let ordering emerge through plasticity | forfeits the ability to read what a unit computes, since the condition lives in a weight history instead of in a value |

Neither cost is recoverable inside the other choice. A declared condition can
be read, but it cannot discover a partition its designer failed to
anticipate. An emergent one can discover such a partition, but it forfeits
the read-out that made L3's typed ports inspectable in the first place.
