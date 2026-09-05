# Loop stability in a neuromorphic system

A neuromorphic system is loops: recurrent connections between units, the
soma-to-dendrite feedback edge, the plasticity loop where activity changes
weights changes activity, and a consolidation loop. Six failure modes attach
to those loops. Four are covered structurally. Two are not.

## 1. The four structural guarantees

| failure | mechanism | conventional SNN framework instead |
|---|---|---|
| the loop does not terminate | totality checking; a profile can demand `(total)`, gated at `lib/typing/totality-check.chiral:130` | runs the loop and times out, or watches a process for a hang |
| a resource leaks or is consumed twice | linear types | a leak detector, or a test run long enough to notice growth |
| an unhandled state is reached | closed sums with enforced coverage | a runtime branch that falls to a default, or a crash in production |
| behaviour changes under timing variation | the Kahn discipline | a scheduler fixed at build time, and a hand-run comparison if it changes |

Each left-column check runs before the loop executes once. Each right-column
item is a test: a conventional framework runs the system and watches, after
the fact, for the inputs someone thought to try.

The Kahn row earns its own paragraph. It is unenforced today. A
process is a continuous mapping from input streams to output streams: output
histories depend only on input histories, independent of the timing or
interleaving of delivery. A neuromorphic system built to this discipline
produces the same spike trains whether it runs on a fixed tick, an event
queue, or a hybrid of the two, because the discipline forbids a process from
observing anything about delivery order beyond what the streams carry. A
conventional SNN framework instead picks a scheduler at build time and treats
the choice as fixed; switching disciplines is a rewrite, and checking that
behavior matches across the two is a comparison run by hand. `Advance` names
the tick/event/hybrid choice as data, per member, but naming the choice is
not proving determinism under it. The row is marked "a design choice"
because nothing in the type checker today rejects a process that peeks at
arrival timing. The discipline has to be adopted by whoever writes the
process.

## 2. The bounded-value case, which is reachable

A membrane potential with a declared range is a refinement on the value.
Chirality ships a refined constructor field today, at
`lib/runtime/proc.chiral:42-43`. Applied to a state variable, a declared
bound turns bounded accumulation into a type error at the write site instead
of a debugging session found after a value has already run away.

Two pieces have to land together to cover this case:

| piece | state |
|---|---|
| refinements on constructor fields | ships today, `lib/runtime/proc.chiral:42-43` |
| saturating arithmetic | a named gap in `AI-LANE-NUMERICS.md`; composes from existing ops (`+ - *` plus `lti/lei` and a select), no new op needed |

`AI-LANE-NUMERICS.md` also measures the width this bears on: state (`u`,
`v`) needs 16 to 24-bit width, and the accumulator that sums weighted spikes
before decay needs 24 to 32-bit width, the widest intermediate in the
pipeline. A refinement that bounds a membrane's range without also fixing
the width it is stored at only moves the runaway one step down the
pipeline, into the accumulator. The bound holds only when the refined range
and the saturating clamp at the width transition are both in place.

## 3. Convergence, and be honest

Totality answers one question: does the loop stop. It answers nothing about
a second question: did the loop stop somewhere useful. A network that
settles to a fixed point of all zeros, or oscillates between two useless
states, passes a totality check exactly as well as a network that learned
the task.

Coverage checking, linear types, and totality each decide a property from
the program text and the type signature alone. Whether a spike train
encodes a good answer depends on the input, the training run, and the task,
none of which a type checker can see. This is measurement territory. It
needs a corpus and a gate: a benchmark suite the network runs against and a
threshold the run must clear. No type system supplies that gate for free.

The wider problem behind this is an oracle problem. A freely designed
neuron model has no reference implementation to check against. Conventional
deep learning has a recourse a freely designed SNN lacks: a well-studied
optimization surface and a large body of prior runs establishing what
"trained" looks like for a given architecture. A new neuron model starts
without either. Correctness of the dynamics has no oracle. Convergence to
something useful has no oracle either. A gate built on a corpus can raise
confidence. It cannot manufacture the oracle that does not exist.

## 4. The split, which is the deliverable

Structural stability is a type-level row set. Dynamical stability is a
gate-level row set. They check different things, need different evidence,
and fail at different times: a structural row fails at compile time, before
the network runs once. A dynamical row fails after a run, against a corpus,
and only ever as a probabilistic finding. Scheduling both under one heading
hides that difference and invites reading a gate result as though it carried
a proof's certainty.

| type-level, owed now | gate-level, owed as a gate design |
|---|---|
| totality on every loop declared `(total)` | a convergence corpus and a pass threshold |
| linear types on every consumed resource | a benchmark of trained-network quality, task by task |
| closed sums with enforced coverage on every state machine | a numeric-stability sweep once saturating arithmetic lands |
| a refinement on every bounded state, once saturating arithmetic closes the gap | a scheduler-equivalence run, time-driven against event-driven, until Kahn moves from adopted to enforced |

The AI lane owes the left column now: the refinement row waits on saturating
arithmetic, the one open item from section 2. It owes the right column as a
gate design. A gate cannot substitute for a proof. The design still needs a corpus, a
threshold, and a report naming which networks cleared it and which did not.
