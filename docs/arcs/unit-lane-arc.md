---
node: arc-unit-lane
layer: navigation
related: [arcs/README, goals/local-ai, banks/unit, decisions/decision-work-ids, decisions/decision-lane-split, status-ledger, index]
status: current
updated: 2026-09-05
---

# Arc: the unit lane

- goal: [[goals/local-ai]], condition 3: the model of computation the agents
  run under is chirality's own.
- reserved element block: **`E196-E239`**, [[decisions/decision-lane-split]].
  Rows carry arc-local ids `N1` and up, per [[decisions/decision-work-ids]],
  the same `N` (neuron-lane) letter `.planning/AI-LANE-GAP.md` already used
  for this roster.
- build-state authority: [[status-ledger]]

Opened 2026-09-05. `.planning/AI-LANE-GAP.md` drew the roster from four
research notes and from [[banks/unit]]'s own census, against
[[goals/local-ai]]'s condition 3: "the `Flow` algebra is total and
type-checked over every case, its skills are enumerable data, and a new
skill is added by writing a value into the registry," extended to cover a
neuron population and a transformer instance under the same abstraction.

## What is in the tree already

[[banks/unit]] holds the refraction. Measured 2026-09-04: 21 existing manas
shards, of which 16 are written and unreached by any gate.

## What is missing

`.planning/AI-LANE-GAP.md` holds the layer graph and the row table this
arc's Rows section carries below. Read it before adding a row here.

## REQUIREMENTS

1. One unit abstraction admits a neuron population, a transformer instance
   and a pure function, with the implementation selected separately from the
   interface.
2. A network is a value: populations, projections addressed to a
   compartment, and a connector vocabulary, assembled and run.
3. State advances under a declared discipline, with the membrane built per
   member.
4. Learning is local traces times a broadcast from a dedicated modulator,
   with the broadcast projection fixed and never trained.
5. The decomposition discipline has a gate below the deliberative layer,
   standing where `manifest-all-green?` stands above it.

## Rows

The `element` column carries the row's E# once it is minted, per
[[arcs/README]]. `unit-lane/N8` and `unit-lane/N9` are minted together as
**E196**, because a constructor's fields and its decode arithmetic constrain
each other and splitting them would settle one against a guess at the other.
`unit-lane/N10` is minted as **E197**. Every other row reads `unminted`.

| row | what | layer | kind | origin | element |
|---|---|---|---|---|---|
| `unit-lane/N1` | bind `op-mulhi` to a surface extern | L0 | primitive | bind | `unminted` |
| `unit-lane/N2` | integer square root routine | L0 | law | new | `unminted` |
| `unit-lane/N3` | saturating arithmetic wrapper | L0 | law | new | `unminted` |
| `unit-lane/N4` | polynomial evaluation (Horner) for i-GELU/i-Softmax | L0 | law | new | `unminted` |
| `unit-lane/N5` | scope `decision-display-numerics` to weight/state/accumulator/message scales | L0 | decision | new | `unminted` |
| `unit-lane/N6` | quantity-typed state slot generalizing `Backend` | L1 | primitive | new | `unminted` |
| `unit-lane/N7` | logical-step/timestamp time parameter carried in the type | L1 | primitive | new | `unminted` |
| `unit-lane/N8` | `Encoding` sum (`Rate`/`Latency`/`Population`) | L2 | primitive | new | `E196` |
| `unit-lane/N9` | encode/decode arithmetic over `Encoding` | L2 | law | new | `E196` |
| `unit-lane/N10` | `RecordRequest` sum (`record-spikes`/`record-membrane`/`record-weights`) | L2 | primitive | new | `E197` |
| `unit-lane/N11` | unbounded trace type paired against `RunManifest`, parallel to `RawCall` | L2 | primitive | new | `unminted` |
| `unit-lane/N12` | spike/graded payload message-width contract | L2 | law | new | `unminted` |
| `unit-lane/N13` | typed I/O on `Expert`, closing the `sees`/`returns` deferral | L3 | primitive | new | `unminted` |
| `unit-lane/N14` | `ty-eq` shape-equality fix | L3 | law | new | `unminted` |
| `unit-lane/N15` | a Process-like porttype for a neuron unit, distinct from `Backend` | L3 | port | new | `unminted` |
| `unit-lane/N16` | one ProcessModel implementation per backend for that unit | L3 | port | new | `unminted` |
| `unit-lane/N32` | per-compartment decay-rate state: one slow-decaying state variable per compartment, the ALIF mechanism for multi-timescale processing | L3 | primitive | new | `unminted` |
| `unit-lane/N35` | a `Modulator` unit kind: a small dedicated source with one output and large fan-out, holding no per-unit state, distinct from the neuron unit at N15 and from `Expert` | L3 | primitive | new | `unminted` |
| `unit-lane/N17` | `Population` construct | L4 | primitive | new | `unminted` |
| `unit-lane/N18` | `Projection`/connector construct, addressed to a compartment inside a unit | L4 | primitive | new | `unminted` |
| `unit-lane/N19` | routing table (address down to a compartment, plus fan-out) | L4 | primitive | new | `unminted` |
| `unit-lane/N20` | lift `Population`/`Projection` through `Flow`, reusing shards C/D | L4 | law | connect | `unminted` |
| `unit-lane/N31` | branch-targeted inhibition: shunting inhibition vetoes one branch, a second routing target the topology layer must carry | L4 | primitive | new | `unminted` |
| `unit-lane/N36` | construct a `Population` from a count, a unit model and parameters | L4 | law | new | `unminted` |
| `unit-lane/N37` | wire a `Projection` from a pre-population, a post-population and a connector | L4 | law | new | `unminted` |
| `unit-lane/N38` | connector vocabulary as a closed sum: all-to-all, one-to-one, fixed-probability, explicit list | L4 | primitive | new | `unminted` |
| `unit-lane/N39` | assemble populations and projections into a network value the execution layer can run | L4 | primitive | new | `unminted` |
| `unit-lane/N40` | dedication: a field on `Population` naming what the group is for | L4 | primitive | new | `unminted` |
| `unit-lane/N21` | `Advance` sum (`advance-tick`/`advance-on-event`/`advance-hybrid`) | L5 | primitive | new | `unminted` |
| `unit-lane/N22` | per-member membrane discipline (`->` pure step, `=>` boundary) | L5 | law | new | `unminted` |
| `unit-lane/N23` | build the membrane once per member; `Advance` picks the trigger, no shared queue | L5 | decision | new | `unminted` |
| `unit-lane/N30` | inward feedback edge: a somatic spike back-propagates into the member's own dendrite; `Advance` carries no constructor for a signal crossing back in | L5 | primitive | new | `unminted` |
| `unit-lane/N24` | eligibility-trace type (per-synapse accumulator) | L6 | primitive | new | `unminted` |
| `unit-lane/N25` | the learning-signal broadcast: one channel delivered through a fixed random projection whose weights are set once and never trained | L6 | law | new | `unminted` |
| `unit-lane/N34` | the metaparameter channels: learning rate, inverse temperature and discount factor, declared values a modulator sets, separate from the error channel | L6 | primitive | new | `unminted` |
| `unit-lane/N26` | a plasticity rule bound to a `Projection` (port), over a weight change or a structural placement change | L6 | port | new | `unminted` |
| `unit-lane/N33` | a consolidation mode: an offline phase where structural plasticity reorganizes the network, distinct from the online updates N24-N26 assume | L6 | decision | new | `unminted` |
| `unit-lane/N27` | `Expert`/`Flow`/`Skill` reused as the lane's composition layer | L7 | primitive | connect | `unminted` |
| `unit-lane/N28` | `RunManifest`/golden oracle reused as the lane's audit record | L7 | primitive | connect | `unminted` |
| `unit-lane/N29` | `SkillEntry` registry reused for population/skill entries | L7 | tool | connect | `unminted` |
| `unit-lane/N41` | the running end of the corpus write path: `be-log` and the worker schema exist, and no database was found under `/workspace/manas` | L7 | tool | new | `unminted` |
| `unit-lane/N42` | a neuron-layer acceptance gate, standing where `manifest-all-green?` stands for the deliberative layer | L7 | decision | new | `unminted` |

## Resume state

**E196 is built** (2026-09-05), so `unit-lane/N8` and `unit-lane/N9` are closed
and the next unminted row is `unit-lane/N10`. The SPEC at
`docs/elements/specs/E196-encoding-seam-SPEC.md` dispositioned six open
questions and none blocked: `Latency` gains `max`, the decode returns a
`DecodeR` result sum, the module lands at `prog/unit/encoding.chiral`, and the
gate declares itself out of the dispatch table under the standing
suite-phase-number call. Three new files landed, none under `lib/`:
`prog/unit/encoding.chiral`, `prog/e196-encoding-sweep.prog` and
`tools/test/encoding.sh`, the last reading `9 passed, 0 failed` over five rows
and four mutants. `prog/compiler.prog`'s blob is unmoved at 820,959 bytes with
zero hits on `unit/encoding`, and a copied `lib/typing/diag.chiral` importing
the module makes the same scan see it arrive, so the element owes no fixpoint.


The census ran 2026-09-05 at `471f688`. It checked 37 `origin: new` rows
against `lib/` and `prog/` and **moved none of them**, so the roster's
sizing holds and this lane is genuinely new work. Three hits were held at
`new` on inspection: a Horner scheme that decodes bytes rather than
evaluating a general polynomial, a `ty-eq` that exists and is reached where
the row wants a bug fixed inside it, and the effect membrane, which is
general and has no per-member application. Everything else was a homonym.
The display lane found roughly half its rows already built; this lane found
none, and that difference is the sizing answer. The one layer where a census did run,
`AI-LANE-NUMERICS` section 3 against L0, found `op-mulhi` already sitting in
the `Op` sum and unbound at surface: that finding is `unit-lane/N1`, and the
same primitive is now minted as `E189` ([[decisions/decision-lane-split]],
owned by neither this arc nor `native-protocol`). That was the census's one
catch, and it was taken before this arc opened; the sweep run on 2026-09-05
caught nothing further, so the cheap way out of the table is spent and every
remaining row is work.
