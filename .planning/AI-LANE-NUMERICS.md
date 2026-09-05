# Research note: AI lane numerics

Question: what arithmetic the AI lane needs, against what the tree already has.
`decision-display-numerics` settled fixed point for the display lane. This note
checks whether that ruling covers the AI lane or the lane owes its own.

## 1. The numeric contract per quantity

Loihi 2's contract is the reference point, because it is a shipped chip running
this exact primitive set (IF, LIF, CuBa-LIF) at production scale.

| quantity | width | why |
|---|---|---|
| weight | 8-bit, 16-bit optional | the trained parameter; 8-bit is the smallest width Loihi 2's synapse array holds without losing the learned signal |
| state (`u`, `v`) | 16 to 24-bit | a membrane or synaptic value decays and accumulates across many timesteps; narrower width wraps before the decay term drains it |
| accumulator (dendritic sum) | 24 to 32-bit | sums many weighted spikes in one timestep before the per-step decay is applied; this sum is the widest intermediate in the pipeline |
| message (spike / graded payload) | up to 32-bit | the unit a routing fabric moves between cores; sized for the worst-case accumulator it must carry |
| scale | power of two only | a rescale between bit-width stages must be a shift; Loihi 2's microcode restricts every rescale to bit-shift for exactly this reason |

The pattern: three widths (weight, state, accumulator) and one rule for
moving between them. That rule is shift; division never enters it.

## 2. What each equation needs, as operations

Discretized CuBa-LIF:

```
u(t+1) = (1 - dt/tau_syn)*u(t) + w_in*(dt/tau_syn)*i(t+1)
v(t+1) = (1 - dt/tau_mem)*v(t) + (dt/tau_mem)*v_leak + R*(dt/tau_mem)*u(t)
```

`dt`, `tau_syn`, `tau_mem`, `R` are build-time constants for a given neuron
population. `(1 - dt/tau_syn)` and `(dt/tau_mem)` are precomputed fixed-point
coefficients baked in at build time; no division runs at inference. Both
lines reduce to multiply-accumulate against constant coefficients:

| step | operation |
|---|---|
| decay term | mul (state times precomputed coefficient) |
| input term | mul (weight times input) |
| combine | add |
| rescale after mul | shr / sar (shift back to the state's scale) |
| spike test | lti / lei (state against threshold) |

No transcendental appears. IF is the same shape with the decay term dropped.
Linear, Conv, and Affine are the same multiply-accumulate repeated over a
weight matrix; Threshold is the comparison step alone.

e-prop's eligibility trace is a second instance of this decay-and-accumulate
shape, run per-synapse. The weight update,

```
dE/dw_ij = sum over t of L_j^t * e_ij^t
```

is a broadcast value (`L_j`, one per neuron) times a per-synapse trace
(`e_ij`), summed over time: one more multiply-accumulate, with the two
already-scaled fixed-point factors producing a double-width product that must
be renormalized by a shift before it re-enters the sum. That renormalization
step is where a wide multiply is load-bearing rather than incidental.

## 3. The gap table

| operation | the lane needs it for | what the tree has | gap |
|---|---|---|---|
| wide multiply, product kept before the shift | e-prop's `L_j * e_ij`; any product between two already-scaled fixed-point values | `op-mulhi` exists in the `Op` sum (`lib/prelude/prelude.chiral:37-39`) with no surface extern | bind a surface name to the existing op; no new op required |
| integer square root | i-LayerNorm's iterative integer sqrt | not in the floor; no sqrt op of any kind | compose from `shl shr sub lti`, non-restoring bit-by-bit method; the missing piece is a library routine, and it needs no new op |
| saturating arithmetic | clamping a 24-bit accumulator before it is packed into a narrower state or message width | `+ - *` wrap silently on overflow | compose: run the op, compare the result against a min/max bound with `lti/lei`, select; the op sum needs nothing added |
| polynomial evaluation | i-GELU's quadratic erf approximation, i-Softmax's exp approximation | `mul add` present, no fused multiply-add, no lookup-table op | Horner's method is directly expressible in `mul` + `add`, so this row closes on the existing floor |
| power-of-two rescale | every width transition between weight, state, accumulator, message | `shl shr sar` present | no gap; this is the floor's fit to the contract in section 1 |

Two real gaps: `op-mulhi` has no surface name, and integer square root has no
home. Saturating arithmetic and polynomial evaluation are composition
exercises against ops the tree already exposes.

## 4. Does the display ruling extend here

Position: the fixed-point answer extends, the ruling that produced it does
not fully cover this lane.

What extends without argument: `decision-display-numerics` establishes that a
mixed-scale arithmetic is a type error and that the scale rides the type, not
the language. Both apply verbatim to weight, state, accumulator, and message,
each of which is a distinct scale in the sense that decision already names.
The reproducibility argument, that this tree gates every promotion on a
byte-identical fixpoint and float rounding varies across emit paths, applies
at least as strongly here: NIR inference is a determinism-sensitive execution
path in the same way display geometry is, and Loihi 2's own restriction of
rescaling to bit-shift is an independent hardware precedent for the same
conclusion FreeType and Blink supplied for pixels.

What the display decision does not settle: it never had to name `op-mulhi` or
integer square root, because glyph and layout math needs neither. The AI lane
does. Those two are additive scope: they extend the inherited ruling instead
of contesting fixed point against float, so they do not reopen
`decision-display-numerics`. They need a narrow follow-on: bind `op-mulhi` to
a surface extern, and place integer
square root as composed library code rather than a new op. Call that the
lane's own decision, scoped to those two items, sitting on top of the
inherited fixed-point ruling rather than replacing it.
