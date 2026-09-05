# What advances a neuron network in time

One question: is the advance a single discipline, or two glued at a boundary.
The catalog needs an answer before the execution-protocol layer gets a shape.

## 1. The two disciplines

| | time-driven | event-driven |
|---|---|---|
| trigger | fixed tick, e.g. 1ms | a spike arrival |
| cost driver | dt. Halving dt roughly doubles work | firing rate. Cost scales with spike count |
| cost when activity is sparse | wasted work. Every idle neuron is touched every tick | cheap. An idle neuron costs nothing |
| cost when activity is dense | flat and predictable | a root-solve per threshold crossing, plus queue pressure that grows with spike volume |
| ordering | free. Tick order is total order | earned. A global timestamped priority queue, or an equivalent |

Measured comparisons convert to cost per synaptic event: elapsed time per
simulated second, divided by synapse count and mean firing rate. Reported
rates run 7.5 Hz for short-range connectivity up to 32-38 Hz for long-range.
The crossover sits where per-tick sweep cost (population size, tick rate)
equals per-event cost (spike count, queue and root-solve overhead). A sparse,
low-rate network favors event-driven. A dense or high-rate network favors
time-driven. Neither term is fixed at design time.

## 2. Why SpiNNaker's split works

Compute is time-driven: a timer tick interrupt fires every core in a
synchronous island, state advances, no core waits on another mid-tick.
Communication is event-driven: only at the tick boundary do spikes leave, as
a 40- or 72-bit packet carrying a source address, fanned out by a
router-side table.

The split works because it never asks the two disciplines to share a queue.
A global timestamped event queue would need every spike, from every core,
ordered against every other spike, at real-machine scale. SpiNNaker's own
finding is that global clock synchronization is a virtual impossibility at
that size. GALS sidesteps it: synchronous islands internally, an
asynchronous packet-switched fabric between them. The tick is the only
ordering primitive compute needs. The router is the only ordering primitive
communication needs. Neither discipline borrows the other's.

## 3. The hybrid case

A hybrid simulator buys accuracy per unit cost: run the active or
structurally complex neurons time-driven, since their state changes every
tick regardless, and run the sparse or simple ones event-driven, since their
state changes only on a spike. The split falls wherever the workload draws
the line.

The cost is a second control path. The system now carries three added parts:
a rule that decides which neuron takes which discipline, population-level or
per-neuron; a mechanism that moves a spike from the event side onto the tick
boundary the time-driven side expects; and a lookup-table or bi-fixed-step
mechanism so the event side's variable-length steps still land somewhere the
time-driven side can consume. This is where a hybrid simulator's actual
complexity lives: population and pre-filtering in event-driven engines,
bi-fixed-step integration on the time-driven side, a CPU/GPU split along the
same seam.

Starting with one discipline and adding the other later costs a redesign of
the boundary. The tick boundary has to become a place where an out-of-band
event queue can drain, a capability the pure time-driven design never
needed and the pure event-driven design already carried. Adding event-driven
to a time-driven-only system means building that drain point. Adding
time-driven to an event-driven-only system means building the tick itself.
The SpiNNaker shape, compute time-driven and exchange event-driven meeting
only at the boundary, is already the shape a hybrid needs. A system built on
that split holds the seam the hybrid case asks for before the hybrid case
ever arrives.

## 4. The chirality shape

A closed sum, `Advance`, alongside `Order` and `StopPolicy`:

```
(data Advance ()
  (advance-tick)                  ; every member advances on a fixed schedule
  (advance-on-event)               ; a member advances only when a message arrives
  (advance-hybrid (tick-members (List Str))))  ; named members are tick; the rest are on-event
```

This is a which-of-N, the same shape as `Order` and `StopPolicy`: it
classifies how a Pipeline's members are driven, apart from what they
compute. `advance-hybrid` carries the split as data, which members are on
the tick, so the choice is inspectable at the type instead of buried inside
a scheduler.

**The membrane.** `->` is the pure step: a tick's, or an event's, local
computation, no I/O, total within the tick. `=>` is the boundary exchange:
spikes leaving at the tick's end, or a message arriving to wake an on-event
member. The claim under test, that within a tick everything is pure and only
the boundary exchange crosses, restates SpiNNaker's split in chirality's
terms. Compute is the `->` island. The router is the `=>` crossing. Nothing
forces a shared queue between them, since the `=>` carries only addressed
packets and carries no ordering obligation.

**Whether it survives the hybrid case.** In part, and the part that fails is
the finding worth keeping. `advance-tick` fits the membrane exactly: the
tick's `->` body is pure, the end-of-tick `=>` is the only crossing.
`advance-on-event` fits a looser version of the same shape: an event-driven
neuron's `->` step runs when a message arrives, so the schedule the
membrane assumed for a "tick" is absent for that member, yet the step
itself is still pure and still bounded by two `=>` crossings, only at
irregular intervals set by arrival instead of by a clock. The honest
statement scopes the membrane per member rather than per Pipeline: a
tick-driven member is pure between two fixed-interval crossings, an
event-driven member is pure between two arrival-set crossings, and both
satisfy pure inside, cross only at the boundary. `advance-hybrid` is the sum
variant that names this directly: the boundary is arbitrated per member by
whichever `=>` crossing that member is waiting on. That is the router-table
shape, distinct from a global event queue.

The consequence for the execution-protocol layer: build the membrane once,
per member, and let `Advance` decide per member which trigger fires it.
Building a single global scheduler serving both disciplines from one queue
would reproduce the shared-queue design SpiNNaker measured as impractical at
scale, and would model this choice as a loose tag where the boundary-sums
directive already requires a closed sum.
