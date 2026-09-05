# Recording: neuron layer vs manas layer

Question: how does a neuron layer get observed, and how does that differ from
how manas already records itself. Two shapes, both owed by the AI lane.

## 1. What neuromorphic systems record

| signal | granularity | cost |
|---|---|---|
| spikes | discrete event: neuron id + timestamp, no magnitude | cheapest per event, scales with firing rate times population size |
| membrane potential (Vm) | continuous analog value, one sample per neuron per timestep | most expensive: exists at every step whether or not a spike fires |
| synaptic weights | one value per synapse, changes on a learning timescale | cheap per sample, sampled sparsely in time since weights move slowly |

A simulator advances state in fixed steps of `dt`. Nothing new exists between
steps, so a sampling interval finer than `dt` records duplicates and one that
lands between steps has no value to read. PyNN's `record()` enforces this:
`sampling_interval` must be an integer multiple of the simulation timestep, in
milliseconds. The constraint follows from the stepped substrate: the
simulator advances state in fixed steps, and a sampling interval is a count
of those steps.

## 2. The two shapes, contrasted

| | sampled trace | structured manifest |
|---|---|---|
| unit | one row per (neuron, timestep) | one row per completed run |
| addressing | dense, uniform, keyed on time | keyed on `run-id`, fields are named slots |
| what it holds | numbers: voltage, spike bit, weight | a decision history: routing, expert calls, patches |
| good for | replaying dynamics, comparing timing across runs, waveform analysis | audit, reproducing a decision, joining against config |

Neither substitutes for the other. A trace has no field for "which expert
fired" or "why this pipeline was chosen": it is numbers over time with no
decision semantics attached. A manifest has no notion of "sample at t":
manas's deliberation is an event sequence of variable-duration calls. Nothing
steps it at fixed `dt`. `RunManifest` is closer to a trial summary log
than to a physiological trace, and a neuron layer's trace is closer to
telemetry than to a decision record. The AI lane needs both because a
recurrent layer inside manas would have dynamics a manifest cannot address,
while the run around it still needs the manifest's decision shape.

## 3. The volume problem

A spike trace at 1ms over a population of hundreds to thousands of neurons
(Neuropixels-scale recordings run 1,000+ simultaneous units) produces a dense
matrix with no natural bound: neurons times timesteps times a recording
duration that keeps growing.

What the field does about it:

| move | mechanism |
|---|---|
| spikes on by default | NEST's `spike_recorder` records every spike from connected neurons with no configuration; it is the default collector |
| continuous state opt-in | NEST's `multimeter` records nothing until told which variables to pull; Vm capture is a deliberate ask |
| aggregate on the fly | binning spikes into firing-rate counts at 25ms or 50ms windows instead of storing every 1ms event |
| back off the storage tier | NEST's memory backend suits small interactive runs; larger volumes move to file/streaming backends because memory cannot hold them |

The pattern: cheap discrete events default to on, expensive continuous state
defaults to off and is asked for by name, and anything dense gets aggregated
before it is written down.

## 4. What a chirality type would carry

A recording request is a closed sum, one variant per class of interest, each
carrying its own scope:

```
(data RecordRequest ()
  (record-spikes   (population Str))
  (record-membrane (population Str) (sample-every I64))
  (record-weights  (population Str) (sample-every I64)))
```

A recorded result is parallel to the request: one shape per variant. There is
no single flat table. A spike result is a list of (neuron-id, time) events; a
membrane result is a list of (neuron-id, time, value) samples keyed at
multiples of `sample-every`. This is the trace shape from section 2, dense and
timestep-addressed.

`RunManifest` does not extend to cover this. Its own comment states the
contract: `ExpertCall` is "the DIGEST-ONLY conformance record kept bounded for
the manifest," and a dense per-timestep trace is exactly what "kept bounded"
excludes. Manas already carries the split this case needs: `RawCall` is
threaded out beside the manifest as the unbounded raw sibling of the
bounded `ExpertCall`, "so the manifest's round-trip schema stays unchanged."
A neuron trace owes the same pairing. `RunManifest` keeps a small
digest of a recording (which variables were captured, at what interval, how
many samples), and a second type, structurally parallel to `RawCall`, carries
the actual unbounded trace beside it.

## Sources

- [PyNN recording docs](https://pynn.readthedocs.io/en/latest/recording.html)
- [NEST spike_recorder](https://nest-simulator.readthedocs.io/en/stable/models/spike_recorder.html)
- [NEST recording from simulations](https://nest-simulator-jougs.readthedocs.io/en/latest/guides/recording_from_simulations.html)
- [Neuropixels-scale population recording, Steinmetz/IBL datasets via SpikeProphecy benchmark](https://arxiv.org/pdf/2605.12992)
