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

`.planning/AI-LANE-GAP.md` holds the layer graph and the 42-row table this
arc's Rows section carries below. Read it before adding a row here. The
roster is 43 rows: `unit-lane/N43` was opened by this arc, after the note, on
the SPEC evidence its own row records.

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
`unit-lane/N10` is minted as **E197**, and so is `unit-lane/N43`, the row this
arc opened on 2026-09-05 to carry what E197's SPEC decision 4 scoped in. The
roster drew N10 as the sum alone and the pricing law had no row, which the
SPEC audit measured as the roster under-reporting what E197 builds. The pairing
reason is the one N8 and N9 carry: the no-pricing counterfactual compiles and
kills `VolumeR`, `rr-wrap` and `RunShape`, whose sole consumer is `rr-samples`,
so splitting settles the field against a guess at the law. `N43` is arc-local
per [[decisions/decision-work-ids]] and takes no second element number. Every
other row reads `unminted`.

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
| `unit-lane/N43` | price a `RecordRequest` against the run it is aimed at | L2 | law | new | `E197` |
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

**E197 is built** (2026-09-05), so `unit-lane/N10` and `unit-lane/N43` are
closed. Three new files, none under `lib/`: `prog/unit/recording.chiral`,
`prog/e197-recording-sweep.prog` and `tools/test/recording.sh`, which reads
`12 passed, 0 failed` over R1 to R6 and M1 to M6. The twenty golden lines came
out byte-identical to the SPEC's on the first compile. R2 asserts the
refinement's compile refusal in both directions, `25` building and `0` and `-3`
both giving `load: cannot prove refinement`, which is what replaces the
negative-interval sweep row decision 2 made unconstructible. All six mutants
were built and run and every moved-line set matches the SPEC's table, including
the two the element turns on: M3 reddens four rows through `rr-interval` alone
while not one `samples=` figure in the file moves, and M5 reddens nineteen of
twenty through `xspk` while R4's per-arm recomputation names the four
`samples=` rows exactly. No fixpoint is owed and the scan was proved sensitive
rather than silent: the blob holds zero `unit/recording` and a copied
`lib/typing/diag.chiral` importing the module makes the same scan see it
arrive. `registration.sh` holds at `9 passed, 0 failed`, 11 of 24 to 12 of 25.
⚑ **The blob and binary byte figures are not the SPEC's**: a concurrent Lane A
session promoted a new `bin/chirality-bin` at 1,241,464 B, against the SPEC's
HEAD figure of 1,188,216 B, and moved `lib/` while this run was open, so the
blob reads 855,545 B here against 820,959. Both halves of the scan were taken
on the same binary and the same `lib/`, and the golden lines and probe verdicts
are unchanged by the move.

**The next row is `unit-lane/N11`**, the unbounded trace type paired against
`RunManifest` and parallel to `RawCall`, at L2 and `unminted`. E197's residue
lands on it twice: what the `rr-fields` digest becomes is N11's answer to give,
and rate-bin aggregation sits behind it because it needs a trace to aggregate.
The mint is the arc session's event and comes first.

The record below is the state E197 was implemented from.
`unit-lane/N10` was minted as E197 and its worked example sits at
`docs/examples/E197-record-request.md`, twenty-one golden lines and five
mutants. The EXAMPLE audit reproduced every figure independently and returned
six fixes, the largest being a fifth mutant for the spikes pricing arm, which
the gate asserted and no stated mutant convicted. **The SPEC is audited**
(`beaa237`, `69874b1`), `docs/elements/specs/E197-record-request-SPEC.md`. Its
audit reproduced the four refinement probes, the twenty golden lines and all
six mutants off-tree on HEAD's binary, measured that gate row R4 localizes M5
to the four spikes rows where R3 reddens 19 of 20 and points nowhere, and
landed four fixes. Decision 4 was tested on its own terms and holds two ways:
the no-pricing counterfactual kills `VolumeR`, `rr-wrap` and `RunShape`, whose
sole consumer is `rr-samples`, and dropping the refinement leaves all twenty
golden lines byte-identical. **The stage that followed was implementation**, ordinary
work under the build rule: `prog/unit/recording.chiral`,
`prog/e197-recording-sweep.prog` and `tools/test/recording.sh`. Nothing landed
under `lib/`, so no fixpoint was owed and the sensitivity half of the scan was.

**Both items this arc owed are closed.** The volume law E197's decision 4
scoped in is `unit-lane/N43` in the table above, opened by this arc on
2026-09-05 and covered by E197, so the roster is 43 rows and the arc no longer
under-reports the element. `tools/pack/pack.py:644`, which wrote the INDEX SPEC
link one directory too shallow and was repaired by hand for E187 at `857a005`
and again for E197, is fixed and proved off-tree. [[records/findings]] FD-12
holds the measurement.

The example carries five open questions and the audit moved two of them without
answering either. Question 2 asked whether the refinement engine decides
`(> 0)` on `sample-every` today: it does, measured, `25` compiles and `0` and
`-1` are refused with `load: cannot prove refinement`. Question 4 is the one
that decides the element's size, whether the pricing function `rr-samples`
belongs to E197 at all, and it rested on a claim the audit refutes: M3 reddens
four rows through `rr-interval` alone, so the sum is gateable with no pricing
at all, and what `rr-samples` gates is a volume law closer in shape to `N9`
than to `N10`. The call is the SPEC's.

The mint is its own event and it comes first: `pack.py` refuses to scaffold an
example for a number `docs/elements/catalog.md` does not carry, so a pre-run
dispatched before the catalog and ledger rows exist cannot run. E196 hit this
first and the ordering was not written down until E197 hit it again.

**E196 is built** (2026-09-05), so `unit-lane/N8` and `unit-lane/N9` are closed.
The SPEC at
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
