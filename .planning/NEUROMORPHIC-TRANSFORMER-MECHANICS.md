# Neuromorphic and transformer mechanics, for the local-AI goal

Research capture. Nothing here is built and no element number is minted. Every
row that owes work writes `UNASSIGNED`.

Serves [[goals/local-ai]]. Placement per `.planning/protocol/placement.md`: a
capture lives at `.planning/` top level.

## The framing

The author's words, verbatim:

> "The goal is a blend between neuromorphic and transformers as a concept.
> Basically, look at transformer for the baseline on von neumann, and then look
> at neurmorphic for the proper mechanical structure of it, to come up with the
> 'thing'."

> "transformer is a arithmetic reference to help translate what neuromorphic
> arithmetic does. Which changes a lot. We can implement a lot more of what
> neuromorphic like spinnaker is supposed to be than we think."

Direction of the mapping: neuromorphic supplies the arithmetic and the
mechanical structure. Transformer states what that arithmetic has to compute.
An earlier pass stated this inverted and was corrected. Every mechanic below is
recorded in that direction.

Scope stance from [[goals/local-ai]]: CPU is the target, tiny models, GPU
assumed absent, fine tuning before from-scratch training.

## Section 1: the two floors, measured

### SpiNNaker1

| fact | value | source |
|---|---|---|
| cores per chip | 18 ARM968, integer only, no FPU | sPyNNaker paper |
| arithmetic | ISO/IEC TR 18037:2008 fixed point, 32-bit, used throughout | sPyNNaker paper, quoted below |
| spike transport | Address Event Representation. The packet key carries the source neuron id and nothing else | sPyNNaker paper |
| packet width | 40 or 72 bits | sPyNNaker paper |
| synapse fetch | on spike arrival, the pre-synaptic row is DMA'd from off-chip SDRAM, row-major so the row is contiguous | sPyNNaker paper |
| update model | time-driven neuron state update, event-driven spike processing, pipelined | sPyNNaker paper |

Quoted: "The SpiNNaker ARM968 has no hardware floating-point support, and
software-implemented floating-point operations are costly in terms of both ITCM
and execution time. Fixed point arithmetic is therefore the preferred data
representation."

The `accum` s16.15 and `long fract` s0.31 formats named in the dispatch prompt
are the TR 18037 types. The standard is the citation; the sPyNNaker paper
confirms the standard is what SpiNNaker1 uses.

### SpiNNaker2

Figures from the chip paper, arXiv 2607.24396. These are the designers' own
report and are marked as such.

| unit | figure |
|---|---|
| PEs per chip | 152, each an Arm Cortex-M4F with 128 kB SRAM |
| MAC array per PE | 16x4 output-stationary, int8 cells, two neighbouring cells fuse for int16, 24-bit accumulators |
| chip MAC peak | 5.837 TOPS theoretical, 4.563 TOPS measured at 300 MHz, 78% utilisation (self-report) |
| numerical accelerator | iterative exp and natural log, s16.15 and s0.31 fixed point plus single-precision float, 1 to 16 iterations, 7 to 22 clock cycles, 1 to 2 ulp, monotonic |
| rounding accelerator | round-to-nearest-up-on-tie and stochastic rounding, four threads, 3 to 4 cycles each, bfloat16 output |
| RNG | PRNG is MARS KISS64 at 32 bits per clock. TRNG from ADPLL phase-frequency detection |
| multicast packet | 40 bits plus up to 128 bits of payload, 16K routing entries, 32-bit source filter |
| data NoC | 192-bit flit at 300 MHz |
| power domains | per PE, 0.8 V at 300 MHz or 0.5 V at 150 MHz |
| SNN capacity | >150,000 neurons per chip, >1.8 billion synaptic events/s at a 1 ms tick (self-report) |
| learning | EventProp and e-prop on chip |

The chip paper's own positioning sentence is the licence for building past it:
it "emphasizes flexibility by implementation of algorithms predominantly in
software on microcontrollers, distinguishing it from dedicated neuromorphic
systems with fixed datapaths". SpiNNaker2 is a software machine with integer
accelerators bolted on. That is the same shape as this tree.

### The SpiNNaker2 language-model run, and its limits

arXiv 2312.09084 ran a 3-layer EGRU, 95% weight sparse, embedding 750,
intermediate 1350, on 150 PEs, WikiText-2. Reported: 170.25 ms latency, 0.39 W,
0.0653 J at batch 1, against an A100 at 19.9 ms, 60 W, 1.1935 J.

Three facts from that paper matter more than the energy number.

1. It used **32-bit floating point**, on the M4F, and the paper says so to claim
   numerical equivalence with the GPU baseline. The neuromorphic chip ran the
   language model in float.
2. Weights were stored in **sparse CSR in PE SRAM**, 88.3 kB against 96 kB of
   available data memory per PE.
3. The stated bottleneck was **memory reading and writing rather than
   communication**, and the memory bound allowed only batch size 1 on one chip.

Point 3 is the same wall CPU transformer decode hits. That is the strongest
single argument that the neuromorphic mechanics and the CPU-transformer
mechanics are the same problem seen twice.

### Loihi 2, for contrast

Loihi 2 emits **graded spikes**: an integer payload up to 32 bits riding the
event, so a message carries a magnitude instead of a bit. Neuron models are
programmable fixed-point microcode, which admits resonate-and-fire, sigma-delta,
and custom state machines. The mesh routes 32-bit events.

The graded spike collapses the rate-coding problem: one event carries what a
rate code would spend many ticks transmitting.

## Section 2: the arithmetic sphere

The neuromorphic answer to "no FPU" is a full integer tower. The transformer
literature independently built the same tower for edge inference. They agree
mechanic for mechanic, which is the central finding of this pass.

### M1. Q-format fixed point

A value is an integer with an implied binary point. `accum` is s16.15,
`long fract` is s0.31. Add and subtract are integer add and subtract. Multiply
of two Qn values produces Q2n, so the product needs the high half and a shift.

Cost: add is one instruction. Multiply is one multiply plus one arithmetic
shift, or a widening multiply reading the high word.

Chirality: `op-mul`, `op-mulhi`, `op-sar` at `lib/prelude/prelude.chiral:37-70`
are exactly the three needed. `op-mulhi` is the widening-multiply high word,
which is what a Q31 multiply reads. The tree already owns Q-format multiply and
has never named it.

### M2. Dyadic rescale

Requantisation after an integer matmul multiplies by a real scale
`S_w * S_h / S_a`. HAWQ-V3 forces that scale to a dyadic rational `b / 2^c`, so
rescale is one INT32 multiply and one right shift. No division anywhere,
integer division included.

Cost: 1 multiply + 1 shift per output element.

Chirality: `op-mul` plus `op-sar`. Open: where the dyadic pair `(b, c)` is
computed. Choosing it needs one division. That division happens at build time
inside a tool, and inference sees only the pair.

### M3. Integer exponential

I-BERT's i-exp. Decompose a non-positive `x` as `x = (-ln2) * z + p` with `z` a
non-negative integer and `p` in `(-ln2, 0]`. Approximate `exp(p)` with the
second-order polynomial `L(p) = 0.3585 (p + 1.353)^2 + 0.344`. Then `exp(x)` is
`L(p) >> z`.

Reported max error 1.9e-3.

Cost: one integer division-free decomposition (a multiply by a reciprocal of
ln2 and a shift), one square, two multiplies, one add, one variable right shift.

Alternative: I-ViT's Shiftmax moves the base to 2, so the decomposition is exact
shifts. IntAttention's IndexSoftmax replaces the exponential with a 32-entry
lookup table plus fixed-point rescale, reporting >99.9% cosine similarity to
FP16 softmax.

Chirality: the polynomial needs `op-mul`, `op-add`, `op-sar`. The variable
right shift is `shr`/`sar` with a computed amount; whether the emitter supports
a register shift amount is UNVERIFIED here.

### M4. Integer softmax

Max-subtract for stability, i-exp per element, then divide by the sum. I-BERT
keeps the non-linear stage at INT32 and requantises to INT8 after.

Cost: one pass for the max, one pass of M3, one pass to sum, one reciprocal.
The reciprocal is the only division; it is done once per row and can be a
Newton reciprocal or a dyadic pair.

### M5. Integer GELU and integer LayerNorm

i-GELU approximates `erf` with `L(x) = sgn(x)[a (clip(|x|, max=-b) + b)^2 + 1]`,
`a = -0.2888`, `b = -1.769`, then `i-GELU(x) = x * 0.5 * (1 + L(x/sqrt2))`.
Reported max error 1.8e-2.

i-LayerNorm computes the integer square root by Newton's method, converging
"within at most four iterations for any INT32 inputs", using integer division,
addition and shifting per iteration.

Cost of the sqrt: 4 iterations, each one division plus one add plus one shift.

Chirality: `op-div` exists. A four-iteration bounded loop is a `Nat`-indexed
fold, which the tree writes routinely.

### M6. Stochastic rounding

Round up with probability proportional to the distance to the upper value.
Gupta 2015 measured that round-to-nearest below 14 fractional bits stalls
training because most updates round to zero, and that stochastic rounding trains
at 16-bit fixed point with little degradation, down to 8 bits in some settings.

Cost: one RNG draw plus a compare and add per rounded value. SpiNNaker2 spends
3 to 4 cycles per value with a dedicated unit and four PRNG channels.

Chirality: **no RNG exists anywhere under `lib/`**. Verified 2026-09-02 by grep
for `rng|rand|random|xorshift|kiss64|lcg` across `lib/` and `prog/`; the one hit
is the word "random-access" in a comment at `lib/lowering/tal/sys.chiral:59`.
This blocks stochastic rounding, reservoir initialisation, dropout, and token
sampling. UNASSIGNED.

### M7. The RNG itself

SpiNNaker2 uses MARS KISS64. KISS64 is four integer state words updated with
multiply, xor, and shift per draw. Chirality has `op-mul`, `op-bxor`, `op-shl`,
`op-shr`, `op-band`, which is the whole instruction set KISS64 needs.

Cost: about 10 integer ops per 32-bit draw, no memory traffic beyond the state.

This is the cheapest owed row found in this pass. UNASSIGNED.

### M8. Ternary weights: multiply becomes add, subtract, or skip

BitNet b1.58 quantises weights to `{-1, 0, +1}` by absmean and activations to
int8 by per-token absmax. A ternary weight turns a multiply into an add, a
subtract, or nothing. Four ternary values pack into one int8. The 2B model was
trained on 4T tokens and is claimed comparable to full-precision peers of the
same size (vendor self-report).

Scalable MatMul-free Language Modeling (arXiv 2406.02528) removes matmul
entirely: BitLinear with ternary weights for the dense layers plus an MLGRU for
token mixing. Reported on-par with transformers to 2.7B, >10x inference memory
reduction, and on a multi-chip neuromorphic system 4x throughput at 10x less
energy than edge GPUs (self-report).

Cost per output element for a ternary dot product of length K: K sign-tests and
at most K adds. Zero multiplies.

Chirality: an add-only inner loop over packed 2-bit codes needs `op-band`,
`op-shr` to unpack and `op-add`/`op-sub` to accumulate. No new primitive.

### M9. Binary spikes: matmul becomes masked accumulate

Spike-driven Transformer's SDSA replaces the Q-K dot product and the softmax
with a spike-level mask plus column-wise additions, so the attention path uses
"only mask and addition operations without any multiplication". The paper
reports up to 87.2x lower computation energy than vanilla self-attention and
77.1% top-1 on ImageNet-1K (self-report).

Cost: one AND per element plus one add per surviving element.

Chirality: `op-band` and `op-add`. A spike vector is a bitset over `Bytes`.

### M10. Log-domain arithmetic

Represent a value by its log, so multiply becomes add and the cost moves to the
add-in-log-domain step. Hardware softmax work replaces vector-wide float
multiply and divide with add and subtract in the log domain, using Schraudolph's
exponential trick. Relevant here because the tree's cheapest op is add.

Open: whether a log-domain representation buys anything over M1 given that
`op-mulhi` already makes Q-format multiply cheap.

## Section 3: communication and structure

### M11. Address Event Representation

The event carries the source identity. The receiver holds the weights and does
the lookup. A spike is therefore a few bytes on the wire.

Cost: a 40-bit packet on SpiNNaker, a 32-bit event on Loihi 2. The sender pays
for one packet and the router pays for the fan-out.

Chirality: the shape of a typed message across a port. `lib/ports/sock.port`
and the `Pool` registry are the existing crossings. Open: whether AER is a port
mechanic here at all, or a data layout inside one process.

### M12. Source-based multicast routing

SpiNNaker2 carries 16K routing entries with a 32-bit source filter. One packet
in, many out, decided by a table keyed on source.

Chirality: the `Flow` algebra's `flow-fan` at `prog/manas/core/flow.chiral` is a
fan-out over a decided set. Whether that is the same mechanic at a different
scale is open.

### M13. Core-local memory and message passing only

Every SpiNNaker PE holds 128 kB of SRAM and there is no shared memory between
PEs. A model is partitioned so that each core's weights fit its SRAM. The
language-model run stored 88.3 kB of CSR weights against 96 kB of data memory.

This is a hard sizing constraint that produces the decomposition discipline
`.planning/MANAS-SKILL-GROWER.md` already states in a different vocabulary: a
step that does not fit is under-decomposed.

Chirality: `lib/ports/pool.port` puts the buffer size **in the type**, so
`(Pool 16384)` and `(Pool 4096)` are different types and the crossing verifies
the claim. That is the SRAM-per-core constraint expressed as a type. The tree
built this for the TUI and it is the closest structural analogue found.

### M14. DMA of a synaptic row on event arrival

Weights are fetched only when a spike arrives, row-major so the row is
contiguous, and a completion callback walks the row and applies each synapse.
Nothing is read for a neuron that did not fire.

Cost: one DMA of `fan_out * bytes_per_synapse` per spike, plus one pass over the
row.

Chirality: `pool-read (off, len)` returns `Bytes` beside the threaded linear
`Pool`. The read shape exists. Open: whether the row walk can avoid rebuilding
`Bytes` per synapse.

### M15. Hybrid update: time-driven neurons, event-driven synapses

The neuron state advances on a fixed tick. The synapse only does work when a
packet arrives. Davidson and Furber note that the tick-driven half is the cost
that hardware-agnostic analyses forget: membrane potential is read and written
every timestep for every neuron, and that scales linearly with tick count.

This is the split that decides whether an event-driven design wins. Section 6
carries the number.

## Section 4: coding, the part that decides everything

| code | what one event carries | cost shape |
|---|---|---|
| rate | a count over T ticks | T ticks of state update per neuron, many events |
| time-to-first-spike | a value in the timing of a single spike, at most one per neuron | one event per neuron, ordering must be preserved |
| rank order | a value in the ordering of firsts, timing discarded | one event per neuron, needs a global sort or a decaying sensitivity |
| burst | a value in an inter-spike interval | few events, receiver holds interval state |
| graded / sigma-delta | an integer magnitude in the payload | one event, payload width |
| delta | the change since last transmission, sent only when it exceeds a threshold | one event per changed unit |

### M16. Delta and sigma-delta coding

Delta Networks (Neil et al. 2017) transmit a unit's value only when the change
since last transmission exceeds a threshold, and skip the corresponding MACs and
memory reads. Reported 5-10x energy efficiency on custom accelerators that
zero-skip on the delta vector.

This is the mechanic that turns a dense recurrent layer into an event-driven
one without any spiking model at all. It is the cheapest neuromorphic idea to
apply to a conventional transformer.

Cost: per unit per step, one subtract, one absolute compare, one branch. On the
skip, zero further work.

Chirality: `op-sub`, `op-lti`, `case`. Nothing new.

### M17. Time-to-first-spike and linearity

TTFS restricts each neuron to spike at most once, with the time inversely
proportional to the value. Extreme sparsity: one event per neuron per inference.

**The mapping nobody here has named.** A resource that may be used exactly once
is what this tree's linear types enforce. A TTFS neuron is a linear spike
obligation: it fires once and is consumed. The checker that already rejects a
dropped `Sock` is the same checker that would reject a neuron firing twice. This
is an unusually tight fit between a neuromorphic coding scheme and a language
feature that is already built and enforced.

Open: whether the tick loop can be typed so that "at most one spike per neuron
per inference" is a linearity obligation rather than a runtime counter.

### M18. Graded spikes as the escape from rate coding

If the event can carry an integer payload, the rate code is unnecessary. Loihi 2
does this and calls it sigma-delta. Section 6's break-even number is what forces
it.

## Section 5: dynamics and learning

### M19. LIF in fixed point

Membrane potential `V`, decay per tick, integrate weighted input, compare to
threshold, emit, reset. In fixed point the decay is a multiply by a Q31 constant
and a shift, or a plain right shift when the decay is a power of two.

Cost per neuron per tick: 1 multiply, 1 shift, 1 add, 1 compare, 1 conditional
store. Five integer ops and one state read-modify-write.

### M20. Refractory counter, adaptive threshold, homeostasis

Refractory: an integer countdown per neuron, decremented per tick, gating the
emit. Adaptive LIF: the threshold itself is a second state variable, raised on a
spike and decaying, producing spike-frequency adaptation. Homeostatic rules
raise the winner's threshold and lower the inhibited neurons'.

Cost: one extra state word and one extra decay per neuron.

### M21. Winner-take-all, lateral inhibition, k-WTA

A spike from one unit suppresses its neighbours, forcing sparse codes and
specialisation. k-WTA keeps the top k and zeroes the rest.

This is structurally the same operation as MoE top-k gating and as the top-k in
contextual-sparsity prediction. Three literatures, one mechanic.

Cost: a partial selection over n, O(n) with a threshold sweep or O(n log k) with
a heap.

### M22. STDP and eligibility traces

STDP: each synapse holds a pre-trace and a post-trace, both exponentially
decaying, and the weight changes on a spike as a function of the other trace.

Three-factor rules and e-prop extend this: the eligibility trace accumulates
locally at the synapse and a separate top-down learning signal modulates it.
e-prop factors the BPTT gradient into a forward-accumulated per-synapse
eligibility trace and a per-neuron learning signal.

Cost: **one or two extra words per synapse**, decayed per tick or per event.
That is the dominant memory cost of on-chip learning, and it scales with
synapses rather than neurons.

### M23. EventProp

Applies the adjoint method to the continuous-time spiking system, computing
exact gradients. The backward pass is itself a hybrid system: per-neuron ODEs
plus event-based backward transmission at spike times. It stores state **only at
spike times**, so its memory scales with spike count instead of with
timestep count.

This is the most interesting training mechanic found for a memory-poor host. The
sandbox this tree develops in is 3.85 GB with no swap, and EventProp's memory
profile is the one that fits.

### M24. Surrogate gradients

Forward pass uses the Heaviside step. Backward pass substitutes a smooth
derivative: fast sigmoid, arctan derivative, boxcar, Gaussian. Any function that
peaks at zero and falls monotonically works about equally well.

Cost: no forward cost. Backward cost is one extra elementwise evaluation, and
memory for the full forward trajectory at every timestep, which is what
EventProp avoids.

### M25. Backprop-free local learning

| rule | mechanic | memory |
|---|---|---|
| Forward-Forward | two forward passes, positive and negative data, a per-layer goodness objective, no global backward pass | one layer's activations |
| Direct feedback alignment | error projected to each layer through a fixed random matrix | one random matrix per layer |
| Predictive coding | local prediction errors settle iteratively | per-unit error state |
| Readout-only | freeze everything, train one linear layer | the readout matrix |

Forward-Forward needs no backward graph at all, which means no autodiff. The
tree has no autodiff and this is the family that does not require one.

### M26. Reservoir computing

Fix a random recurrent core, train only the linear readout, usually by ridge
regression. LSM is the spiking version, ESN the rate version.

Cost: inference is the recurrent core plus a matrix-vector product. Training is
one least-squares solve over collected states, which is a fixed cost with no
gradient loop.

Needs an RNG for the reservoir (M6, M7) and a linear solve. Both are absent
here.

### M27. ANN-to-SNN conversion

The bridge from the transformer sphere to the neuromorphic one. The firing rate
of an IF neuron maps to the ReLU output of an artificial neuron. Conversion is
weight normalisation or threshold balancing, which are equivalent in effect.

The cost is latency: the SNN needs enough timesteps to represent the rate, and
short windows produce conversion error. This is the mechanic that makes rate
coding expensive, and Section 6 is why.

## Section 6: what the transformer sphere says the arithmetic must compute

### M28. Attention as content-addressed routing

Query against keys, softmax, weighted sum of values. Read mechanically: a
content-addressed fan-out where the routing weights are computed rather than
stored. M12's routing table stores its weights; attention computes them.

### M29. Linear attention is a recurrent state update

RWKV, RetNet, gated linear attention and Mamba-2 all replace the quadratic
attention with a fixed-size state updated per token, usually a matrix, with a
data-dependent decay that removes some of the old state each step. RWKV-7 uses a
generalised delta rule with an in-context learning rate vector.

Two consequences for this tree.

1. Inference cost per token is constant in sequence length. Memory is one state,
   not a growing KV cache.
2. The state update is `state = decay * state + outer(k, v)`, which is a decay
   and an accumulate. **That is the LIF membrane update at matrix scale.** The
   linear-attention state and the neuromorphic membrane potential are the same
   object: a leaky accumulator that is read, decayed, and added to.

SpikeGPT is built on exactly this observation: it takes RWKV's linear attention
and makes the activations binary and event-driven, reporting 32.2x fewer
operations on neuromorphic hardware (self-report).

### M30. Sparsity in dense transformers

| finding | number | source |
|---|---|---|
| contextual sparsity in an LLM for a given input | up to 85%, 2-6x speedup with an asynchronous predictor | Deja Vu (self-report) |
| ReLUfication induces activation sparsity with negligible loss after fine-tuning | qualitative | Turbo Sparse and related |
| Turbo Sparse Mistral-7B | 2.5B of 7B parameters active per iteration, 8.71 tok/s on an i9-14900HX | self-report |

Contextual sparsity is a learned predictor deciding which units will be zero.
That is a gate. This tree has a gate.

### M31. Mixture of experts as conditional compute

Top-k routing over experts. The measured caution: on CPU, sparse MoE can be
*slower* than dense because routing overhead, irregular control flow and poor
cache locality outweigh the skipped work. Expert selection varies per token,
which destroys cache hit rates.

The lesson transfers directly. Event-driven dispatch buys nothing unless the
skipped work dominates the dispatch cost.

## Section 7: the symbolic bridge

### M32. Hyperdimensional computing and vector-symbolic architectures

Three operations over high-dimensional vectors:

| op | what it does | binary implementation |
|---|---|---|
| bind | associate a role with a filler, output dissimilar to both inputs | elementwise XOR |
| bundle | represent a set, output similar to all inputs | elementwise majority |
| permute | mark position or role | rotate |

Cost over a d-bit hypervector packed into 64-bit words: bind is `d/64` XORs.
Bundle is a popcount-and-threshold per position, or `d/64` majority evaluations.
Permute is a rotate.

Chirality: `op-bxor`, `op-bor`, `op-band`, `op-shl`, `op-shr` are the complete
instruction set for binary-spatter-code VSA. This is the one family in this
capture that the tree could implement today with zero new primitives, no float,
and no RNG beyond initial symbol generation.

The 2512.14709 line "Attention as Binding" reads transformer attention through
this algebra. Unverified here and worth a follow-up.

### M33. A closed primitive set as the interchange format

The Neuromorphic Intermediate Representation (Nature Communications, 2024)
defines computation as a graph whose nodes are primitives specified as hybrid
continuous-time dynamical systems, deliberately with no discretisation or
hardware assumptions. It links 7 simulators and 4 hardware platforms.

Chirality already does the same thing one level down: `Op` at
`lib/prelude/prelude.chiral:36-39` is a **closed sum of 15 machine ops**, and
the header states the design reason: the op is validated once at the erase
boundary so every downstream consumer matches exhaustively, with no stringly
dispatch and no defensive halt for an unknown primitive. NIR is that discipline
applied to neuron dynamics.

Open: whether a neuron/layer primitive set belongs as a second closed sum beside
`Op`, or as data in a `.manifest`.

## Section 8: the honest counters

Three measured results that constrain everything above.

### C1. Rate-coded SNNs usually lose on digital hardware

Davidson and Furber (Frontiers in Neuroscience, 2021), TSMC 22FDX normalised
units, 1E ~ 60 fJ:

| operation | cost |
|---|---|
| 32-bit addition | 1E (~60 fJ) |
| 32x8 MAC | 5E (293 fJ) |
| 32-bit SRAM read | 5E (296 fJ) |
| SRAM writeback | 1E |

Their conclusion, quoted: "For the SNN energy to be lower than the ANN for this
technology would require the expected number of spikes used to transmit an
output to be <12E/7E or 1.72." And: "most rate-coded spiking network
implementations will not be more energy or resource efficient than the original
ANN, concluding that more imaginative uses of spikes are required."

Below 1.72 spikes per output the code is no longer a rate code. The break-even
therefore rules rate coding out and points at M16, M17 and M18.

### C2. Data movement dominates arithmetic

Horowitz, ISSCC 2014, 45 nm: a 32-bit add costs about 0.9 pJ, a 32-bit DRAM
access about 640 pJ. Roughly 700x.

Consequence: replacing a multiply with an add saves 5x on an operation that is
already 1/700th of the memory cost of fetching its operand. **The weight fetch
is the bill.** Ternary weights (M8) win mostly because 2 bits move instead of
16, and only secondarily because the multiply is gone.

### C3. Decode is memory-bound at batch 1

Matrix-vector multiply has arithmetic intensity around 1 FLOP per byte
regardless of dimension. At batch 1, transformer decode arithmetic intensity is
roughly 0.9 to 2. Every token reads every weight. A local single-user agent is
permanently at batch 1, so there is no second request to amortise the weight
read against.

This is the same sentence as the SpiNNaker2 language-model paper's own
bottleneck finding, arrived at from the opposite direction.

**Synthesis.** C1, C2 and C3 agree that the mechanic worth having is the one
that avoids reading a weight. Event-driven skipping (M14, M16, M30), ternary
packing (M8), and a fixed-size recurrent state instead of a growing cache (M29)
all attack the read. Replacing multiplies with adds attacks the cheap half.

## Section 9: what this tree has, measured 2026-09-02

| mechanic wants | tree state |
|---|---|
| Q-format multiply | `op-mul`, `op-mulhi`, `op-sar` at `lib/prelude/prelude.chiral:37-70`. Present |
| dyadic rescale | same three ops. Present |
| bit ops for VSA and spike masks | `op-band`, `op-bor`, `op-bxor`, `op-shl`, `op-shr`. Present |
| a sized local buffer with the size in the type | `lib/ports/pool.port`, `(Pool n)`, linear, `pool-write (off, bytes)`, `pool-read (off, len)`. Present |
| bounds-checked offsets | `refine` types; `pool.port` states that a constant offset is compile-time checked and a computed one falls back to runtime. Present |
| single-use enforcement | linear types, checker-enforced. Present |
| an arena | `lib/memory/arena.chiral`, mmap/mremap, 64 MB initial. Present |
| a byte buffer | `Bytes` with `blen`, `bget`, `bslice`, `bcat`, `brepeat`, `pack-u32`, `unpack-u32`. **Immutable.** There is no `bset` |
| an RNG | absent. Verified by grep across `lib/` and `prog/` |
| a float type | absent. `F64` and `Float` grep-clean in `lib/surface/` and `lib/typing/`. E153 minted, unbuilt |
| a tensor form | absent |
| autodiff | absent |
| a linear solve | absent |
| a model transport | `http-request`, `backend-open`, `chat-open` have no crossing-table entry. Carried in [[goals/local-ai]] |

### The `Bytes` finding

`Bytes` is immutable and has no indexed write. An accumulator loop that updates
one element of a vector must go through `bslice` and `bcat`, which is an O(n)
copy per element and O(n^2) per pass. Every mechanic in this capture that
touches a state vector (M19 membrane update, M29 linear-attention state, M22
eligibility traces, M32 bundling) needs an in-place indexed write.

`Pool` is the mutable store that exists, and its write takes a `Bytes` payload
at an offset while threading the linear cap. Whether a per-element `Pool` write
is affordable, or whether an unboxed mutable integer vector is owed, is the
first structural question this research raises. UNASSIGNED.

## Section 10: mappings claimed, and mappings left open

### Claimed

| neuromorphic mechanic | chirality thing | why |
|---|---|---|
| Q-format multiply (M1) | `op-mulhi` + `op-sar` | the widening high word is what a Q31 multiply reads |
| dyadic rescale (M2) | `op-mul` + `op-sar` | division-free by construction |
| VSA bind/bundle/permute (M32) | `op-bxor`, majority over `op-band`/`op-bor`, `op-shl` | complete, no new primitive |
| binary spike matmul (M9) | `op-band` + `op-add` over a `Bytes` bitset | mask and accumulate |
| core-local SRAM budget (M13) | `(Pool n)`, size in the type | the crossing verifies the size claim |
| TTFS single-spike (M17) | linear types | fire-once is a linearity obligation |
| closed primitive set (M33) | the `Op` sum, and its stated design reason | exhaustive match, no unknown-primitive halt |
| decomposition until it fits a core (M13) | the tiny-step rule in `.planning/MANAS-SKILL-GROWER.md` | same rule, different vocabulary |

### Left open

- AER (M11) as a port crossing, or as a data layout inside one process. No
  evidence either way was found in the tree.
- Multicast routing (M12) against `flow-fan`. The `Flow` algebra fans over a
  decided set; whether the routing table is the same object at another scale is
  unexamined.
- Whether a neuron/layer primitive set is a second closed sum beside `Op`, or a
  `.manifest`. E163, the `.manifest` module kind, is minted and unbuilt.
- Whether log-domain arithmetic (M10) earns anything over Q-format given
  `op-mulhi`.
- Whether the four-rung status ledger has a rung for a numerical claim. Every
  mechanic here carries an error bound, and an error bound is a measurement that
  `records/` is shaped for and `docs/definitions/status-ledger.md` may not be.

## Section 11: owed, all UNASSIGNED

No element number is minted by this document. `docs/decisions/decision-lane-split.md`
reserves `E184-E189` and `E190-E195` and nothing else; author call B in
[[records/author-calls]] asks for a block.

| owed | why it is first | UNASSIGNED |
|---|---|---|
| an integer RNG (KISS64 or xorshift) | 10 integer ops, no new primitive, unblocks stochastic rounding, reservoirs, dropout, and token sampling | yes |
| a mutable integer vector, or a measured verdict on `Pool` per-element writes | every state-vector mechanic depends on it | yes |
| the Q-format tower: `qmul`, `qdiv`, saturating add, the dyadic rescale | the base every other mechanic sits on | yes |
| integer `exp` by the i-exp decomposition | softmax, LIF decay, eligibility traces | yes |
| integer `sqrt` by bounded Newton | LayerNorm, RMSNorm | yes |
| a packed ternary dot product | the add-only inner loop | yes |
| a VSA layer over `Bytes` | the one family buildable today with zero new primitives | yes |

## Surprises

1. **SpiNNaker2 ran its language model in 32-bit float.** The flagship
   neuromorphic language-model result used the M4F's FPU and said so, in order to
   claim numerical equivalence with the GPU baseline. The fixed-point tower went
   unused. The integer discipline this tree would need is more neuromorphic than
   the neuromorphic paper's own language-model run.

2. **The linear-attention state update and the LIF membrane update are the same
   equation.** Decay the accumulator, add the new contribution, read it out.
   RWKV arrived at it from the RNN side and LIF from the neuron side. This is the
   single tightest join between the two spheres found in this pass, and SpikeGPT
   is the existing proof that the join is exploitable.

3. **The break-even for rate coding is 1.72 spikes.** Davidson and Furber's
   number rules out the textbook version of the neuromorphic advantage on digital
   hardware, and the authors say so plainly. Everything worth taking from the
   sphere is in the non-rate codes: delta, TTFS, graded, sigma-delta.

4. **TTFS is a linear type.** Fire at most once, be consumed. The checker that
   enforces this is built and gating.

5. **Three literatures wrote one mechanic.** k-WTA in neuromorphic, top-k MoE
   routing in transformers, and contextual-sparsity prediction in LLM serving are
   the same partial selection with three names, and the tree already has a gate.

6. **`Bytes` immutability is the blocker, and it has not been named.**
   [[goals/local-ai]] lists no float, no tensor and no autodiff as the honest
   limits. The absence of an indexed write is upstream of all three: without it
   there is no vector to make a tensor out of.

7. **The MoE CPU result cuts against event-driven dispatch.** Sparse expert
   routing measures *slower* than dense on CPU because dispatch overhead and
   cache misses outweigh the skipped work. Any event-driven design here has to
   beat that bar, and the bar is measured rather than theoretical.

## Sources

Neuromorphic platforms:
- SpiNNaker2 chip paper, arXiv 2607.24396: https://arxiv.org/html/2607.24396v1
- Language Modeling on a SpiNNaker2 Neuromorphic Chip, arXiv 2312.09084: https://arxiv.org/html/2312.09084v3
- Event-based backpropagation on SpiNNaker2, arXiv 2412.15021: https://arxiv.org/pdf/2412.15021
- sPyNNaker, Frontiers in Neuroscience 2018: https://www.frontiersin.org/journals/neuroscience/articles/10.3389/fnins.2018.00816/full
- Loihi 2 overview, Open Neuromorphic: https://open-neuromorphic.org/neuromorphic-computing/hardware/loihi-2-intel/
- Sigma-Delta Neural Network Conversion on Loihi 2, arXiv 2505.06417: https://arxiv.org/pdf/2505.06417
- Neuromorphic Intermediate Representation, Nature Communications 2024: https://www.nature.com/articles/s41467-024-52259-9

Integer arithmetic:
- I-BERT, arXiv 2101.01321: https://ar5iv.labs.arxiv.org/html/2101.01321
- I-ViT, arXiv 2207.01405: https://arxiv.org/pdf/2207.01405
- HAWQ-V3 dyadic quantization, arXiv 2011.10680: https://arxiv.org/pdf/2011.10680
- IntAttention / IndexSoftmax, arXiv 2511.21513: https://arxiv.org/abs/2511.21513
- Gupta et al., Deep Learning with Limited Numerical Precision, arXiv 1502.02551: https://arxiv.org/pdf/1502.02551

Low-bit and matmul-free:
- BitNet b1.58 2B4T technical report, arXiv 2504.12285: https://arxiv.org/pdf/2504.12285
- Scalable MatMul-free Language Modeling, arXiv 2406.02528: https://arxiv.org/pdf/2406.02528

Spiking transformers and language models:
- Spike-driven Transformer, NeurIPS 2023, arXiv 2307.01694: https://arxiv.org/pdf/2307.01694
- Spiking Transformer: Addition-Only Spiking Self-Attention, arXiv 2503.00226: https://arxiv.org/pdf/2503.00226
- SpikeGPT, arXiv 2302.13939: https://arxiv.org/abs/2302.13939

Linear attention:
- RWKV, arXiv 2305.13048: https://arxiv.org/abs/2305.13048
- RWKV-7 Goose, arXiv 2503.14456: https://arxiv.org/pdf/2503.14456

Sparsity:
- Delta Networks, arXiv 1612.05571: https://arxiv.org/abs/1612.05571
- Sigma Delta Quantized Networks, arXiv 1611.02024: https://arxiv.org/pdf/1611.02024
- Deja Vu, arXiv 2310.17157: https://arxiv.org/pdf/2310.17157
- Q-Sparse, arXiv 2407.10969: https://arxiv.org/pdf/2407.10969
- A Survey on Inference Optimization Techniques for MoE, arXiv 2412.14219: https://arxiv.org/pdf/2412.14219

Learning rules:
- EventProp, Scientific Reports 2021: https://www.nature.com/articles/s41598-021-91786-z
- Surrogate Gradient Learning in SNNs, arXiv 1901.09948: https://arxiv.org/pdf/1901.09948
- The Forward-Forward Algorithm, Hinton: https://www.cs.toronto.edu/~hinton/FFA13.pdf
- TESS local learning rule, arXiv 2502.01837: https://arxiv.org/pdf/2502.01837

Coding and reservoirs:
- Analyzing time-to-first-spike coding schemes, Frontiers 2022: https://www.frontiersin.org/journals/neuroscience/articles/10.3389/fnins.2022.971937/full
- T2FSNN, arXiv 2003.11741: https://arxiv.org/pdf/2003.11741
- Reservoir Computing: A New Paradigm for Neural Networks, arXiv 2504.02639: https://arxiv.org/pdf/2504.02639

Symbolic:
- HDC/VSA survey Part I, arXiv 2111.06077: https://arxiv.org/pdf/2111.06077
- Attention as Binding, arXiv 2512.14709: https://arxiv.org/pdf/2512.14709

Cost anchors:
- Davidson and Furber, Comparison of Artificial and Spiking Neural Networks on Digital Hardware, Frontiers 2021: https://pmc.ncbi.nlm.nih.gov/articles/PMC8055931/
- Horowitz, Computing's Energy Problem, ISSCC 2014: https://www.researchgate.net/publication/271463146_11_Computing's_energy_problem_and_what_we_can_do_about_it
- Memory-Bound but Not Bandwidth-Limited: Batch-1 LLM Decode, arXiv 2605.30571: https://arxiv.org/pdf/2605.30571
