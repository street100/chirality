# The AI lane: what has to be built, and how big it is

Four research notes exist (`AI-LANE-ENCODING`, `AI-LANE-NUMERICS`,
`AI-LANE-RECORDING`, `AI-LANE-EXECUTION`) plus `docs/banks/unit.md`'s own
census of the manas shard set. No arc holds any of it. This maps the four
notes and the census onto a row table, onto `goals/local-ai`'s conditions,
and onto a line-count estimate, using only measurements already on record.

## 1. The layer graph

L0 through L7 are labels. Reading them in order as a build sequence is
wrong. Two edges run against the numbering: L7 drives the modulator at L3,
and N30's back-propagating spike crosses inward at L5. The sequence
reading breaks on both: L3 would have to build before L7 supplies the
modulator's broadcast, and L5 would need every outward crossing finished
before the one inward edge it also carries exists.

| | layer | what exists today |
|---|---|---|
| L0 | fixed-point numerics | `decision-display-numerics`'s fixed-point ruling extends here. `shl/shr/sar` cover every power-of-two rescale. `op-mulhi` sits in the `Op` sum (`lib/prelude/prelude.chiral:37-39`) with no surface extern. Integer sqrt, saturating arithmetic, polynomial evaluation are composable from existing ops and none is written |
| L1 | the region: `Pool`, linear, size in the type | `Backend` (shard G) is the one instance: a single-flight linear porttype. Nothing generalizes it to a quantity-typed slot (`0 or 1 or many`) or carries a logical-step or timestamp the way `Pool` carries a size |
| L2 | the event codec: address plus payload on a channel | Named nowhere in the tree. `AI-LANE-ENCODING` states it directly: "nothing in the tree names this seam today." `RunManifest`/`RawCall` (shard K) is the nearest existing pattern a spike trace would pair against |
| L3 | the unit: stateful, typed ports, one implementation per backend, with a branch-level compartment as the addressable structure inside it | `Expert` (shard A) is stateful with named fields, but `sees`/`returns` are `Str` prose by explicit deferral (`types.chiral:64`). `Backend` (shard G) is one porttype, one backend shape. No Process/ProcessModel split for a neuron unit exists, and no unit carries a compartment structure inside it either |
| L4 | topology: populations, projections, connectors, and a routing table addressed to a compartment inside a unit | `Flow`/`Pipeline`/`Order` (shards C, D) are the tree's only compositional primitives, and they route `Expert` calls. No `Population`, `Projection`, connector, or routing table exists, and none carries an address finer than a whole unit |
| L5 | execution protocol: the `Advance` sum | Given as a design shape in `AI-LANE-EXECUTION` section 4, unbuilt. The tree's own loop is a Mealy FSM (shard Q, E66, "already chirality") driving one flat step (shard P): one discipline picked once for the whole run |
| L6 | plasticity: a rule bound to a projection, over a weight change or a structural placement change | Absent. `docs/banks/unit.md` section 5 point 7 measured that `ExpertCall`/`RunManifest` are append-only: nothing folds a later verdict back into an earlier record, which is the revision channel a plasticity rule needs |
| L7 | deliberative composition: `Flow`, `Skill`, `Expert` | Built. Shards A, C, H, K, O are all **compiled**: present, complete, compiling on every suite pass, executed by none of it, per section 2's own census |

### The edges

| edge | direction | what crosses |
|---|---|---|
| L7 -> L3 | against the numbering | L7's own composition (`Flow`/`Skill`/`Expert`) drives the modulator (N35) |
| L3 -> L6 | with the numbering | the modulator's broadcast reaches L6: N25's learning signal, N34's metaparameter channels |
| L5 -> L3 | against the numbering | N30's spike crosses inward, from the execution protocol's outward (`=>`) boundary into the member's own dendrite |

The L3/L4 boundary above sits one atom finer than the row first drawn it.
`AI-LANE-DENDRITES` measured the branch as the atom carrying nonlinearity,
gating and memory together. A projection landing on a whole unit only adds
one more term to a single shared threshold, and that erases the coincidence
structure a branch computes: a branch's AND behavior lives at the branch's
own threshold, one level inside the unit. L3 still ends at the unit
boundary; the unit now exposes a compartment as structure inside it. L4's
routing table takes that compartment as its address, down to which branch
of which unit, or every dendritic effect the note found collapses back into
the single per-unit sum a perceptron already computes.

## 2. The row table

No arc owns this work, so no letter prefix is established. Ids below use
`N` (neuron-lane) as an arc-local placeholder only; none is an element
number (section 3).

| id | what | layer | kind | origin |
|---|---|---|---|---|
| N1 | bind `op-mulhi` to a surface extern | L0 | primitive | bind |
| N2 | integer square root routine | L0 | law | new |
| N3 | saturating arithmetic wrapper | L0 | law | new |
| N4 | polynomial evaluation (Horner) for i-GELU/i-Softmax | L0 | law | new |
| N5 | scope `decision-display-numerics` to weight/state/accumulator/message scales | L0 | decision | new |
| N6 | quantity-typed state slot generalizing `Backend` | L1 | primitive | new |
| N7 | logical-step/timestamp time parameter carried in the type | L1 | primitive | new |
| N8 | `Encoding` sum (`Rate`/`Latency`/`Population`), gaining a `max` on `Latency` and a `DecodeR` result. **BUILT as E196**, `prog/unit/encoding.chiral` | L2 | primitive | built |
| N9 | encode/decode arithmetic over `Encoding`. **BUILT as E196**, gated by `tools/test/encoding.sh` at nine rows with four mutants | L2 | law | built |
| N10 | `RecordRequest` sum (`record-spikes`/`record-membrane`/`record-weights`) | L2 | primitive | new |
| N11 | unbounded trace type paired against `RunManifest`, parallel to `RawCall` | L2 | primitive | new |
| N12 | spike/graded payload message-width contract | L2 | law | new |
| N13 | typed I/O on `Expert`, closing the `sees`/`returns` deferral | L3 | primitive | new |
| N14 | `ty-eq` shape-equality fix | L3 | law | new |
| N15 | a Process-like porttype for a neuron unit, distinct from `Backend` | L3 | port | new |
| N16 | one ProcessModel implementation per backend for that unit | L3 | port | new |
| N32 | per-compartment decay-rate state: one slow-decaying state variable per compartment, the ALIF mechanism for multi-timescale processing | L3 | primitive | new |
| N35 | a `Modulator` unit kind: a small dedicated source with one output and large fan-out, holding no per-unit state, distinct from the neuron unit at N15 and from `Expert` since it computes nothing locally and exists only to broadcast | L3 | primitive | new |
| N17 | `Population` construct | L4 | primitive | new |
| N18 | `Projection`/connector construct, addressed to a compartment inside a unit | L4 | primitive | new |
| N19 | routing table (address down to a compartment, plus fan-out) | L4 | primitive | new |
| N20 | lift `Population`/`Projection` through `Flow`, reusing shards C/D | L4 | law | connect |
| N31 | branch-targeted inhibition: shunting inhibition vetoes one branch, pathway-specific gating; a second routing target the topology layer must carry | L4 | primitive | new |
| N36 | construct a `Population` from a count, a unit model and parameters | L4 | law | new |
| N37 | wire a `Projection` from a pre-population, a post-population and a connector | L4 | law | new |
| N38 | connector vocabulary as a closed sum: all-to-all, one-to-one, fixed-probability, explicit list | L4 | primitive | new |
| N39 | assemble populations and projections into a network value the execution layer can run | L4 | primitive | new |
| N40 | dedication: a field on `Population` naming what the group is for | L4 | primitive | new |
| N21 | `Advance` sum (`advance-tick`/`advance-on-event`/`advance-hybrid`) | L5 | primitive | new |
| N22 | per-member membrane discipline (`->` pure step, `=>` boundary) | L5 | law | new |
| N23 | build the membrane once per member; `Advance` picks the trigger, no shared queue | L5 | decision | new |
| N30 | inward feedback edge: a somatic spike back-propagates into the member's own dendrite; coinciding with a distal plateau it produces a high-gain burst. `Advance` crosses `=>` outward from a member when it fires and carries no constructor for a signal crossing back in | L5 | primitive | new |
| N24 | eligibility-trace type (per-synapse accumulator) | L6 | primitive | new |
| N25 | the learning-signal broadcast: one channel delivered through a fixed random projection whose weights are set once and never trained | L6 | law | new |
| N34 | the metaparameter channels: learning rate, inverse temperature and discount factor, declared values a modulator sets, separate from the error channel | L6 | primitive | new |
| N26 | a plasticity rule bound to a `Projection` (port), over a weight change or a structural placement change | L6 | port | new |
| N33 | a consolidation mode: an offline phase where structural plasticity reorganizes the network, distinct from the online updates N24-N26 assume | L6 | decision | new |
| N27 | `Expert`/`Flow`/`Skill` reused as the lane's composition layer | L7 | primitive | connect |
| N28 | `RunManifest`/golden oracle reused as the lane's audit record | L7 | primitive | connect |
| N29 | `SkillEntry` registry reused for population/skill entries | L7 | tool | connect |
| N41 | the running end of the corpus write path: `be-log` and the worker schema exist (`interactions`, `expert_calls`, `models`, `training_runs`), and no database was found under `/workspace/manas`, so what is missing is whatever runs and fills them | L7 | tool | new |
| N42 | a neuron-layer acceptance gate, standing where `manifest-all-green?` stands for the deliberative layer. Without it the decomposition discipline has no enforcement below L7 | L7 | decision | new |

N33's kind is `decision`. REM dendritic calcium spikes are implicated in
pruning and strengthening spines, and that finding names a phenomenon. The
phase's trigger, its scope, and its interaction with N24-N26's online rule
stay unpinned to any one shape, and each is an open question a builder still
has to close before N33 compiles.

N25 narrows to the broadcast channel itself. The plasticity layer draws on
four dedicated channels. Dopamine carries the reward-prediction error, the
learning signal N25 broadcasts. Acetylcholine sets the learning rate,
noradrenaline sets the inverse temperature, and serotonin sets the discount
factor: three metaparameters N34 carries as declared values, separate from
the error channel. N25's own channel runs through a fixed random
projection: e-prop's own literature already describes this as resembling a
neuromodulator, and random e-prop keeps these weights fixed and never
learns them. A weight that stays untrained carries zero plasticity
machinery of its own, so N25 costs a wiring line where a learned projection
would cost a subsystem. N35 gives that broadcast a unit kind of its own,
distinct from the neuron unit at N15 and from `Expert`: a modulator
computes nothing locally, holds no per-unit state, and exists to broadcast
one output across a large fan-out.

N36 through N39 give the roster verbs. Every row above names a type:
`Population`, `Projection`, `Encoding`, `Advance`, `Modulator`. PyNN's own
API is constructive: `Population(n, cellclass, params)` builds a
population value and `Projection(pre, post, connector)` wires one. Manas
today declares an `Expert` and cannot construct one. N36 and N37 are that
constructor pair. N38 is the connector sum N37 draws its third argument
from. N39 assembles the constructed populations and projections into the
network value the execution layer runs, the role `Pipeline` plays for
`Flow` today.

N40 gives dedication a field. `Expert` carries `lens`, `sees`, `returns`
and `slot`, prose descriptors of what the expert is for. `Population`
carries none. Dedication is the L7 concept reaching down to L4: it states
what the group is for. That is what turns a population into a lobe.
Without it a population is a bag of units with no purpose attached.

## 3. Mapping to the tree's units of work

`goals/local-ai.md` names four conditions: full orchestration, TUI through
scriba, a full framework for chirality AI, and the Python wrap for tuning.
Three arcs already own conditions 1, 2, 4 (`transport-arc`, `scriba-arc`,
`tuning-arc`). Condition 3 has no arc; the goal doc calls it "largely
built," with one lint row as its own gap.

Only L7's connect rows (N27-N29) sit under condition 3: they reuse the
manas machinery that already carries that condition's claim. Every other
row, L0 through L6, the neuromorphic stack, serves none of the four named
conditions. It answers a further question `AI-LANE-*` and unit.md section 5
point 7 raised, whether one abstraction covers a transformer instance and a
neuron population, and the goal doc has not adopted that as a fifth
condition.

No arc owns L0-L6. Even a placeholder is missing. An arc is owed. Its
done-conditions, read off the row table: L2's `Encoding`/`RecordRequest`
sums round-trip through a codec paired against shard K; L4's `Population`/
`Projection` topology compiles and lifts through `Flow` the way `Pipeline`
does today; L5's `Advance` sum drives a runner with a gate in
`tools/test/run-tests.sh` that executes it, unlike every existing manas
shard; L6's plasticity rule, over a weight change or a structural placement
change, closes the append-only gap unit.md's residue point 7 measured.

`decision-lane-split` reserves `E184-E189` and `E190-E195` for two other
lanes, and the catalog runs continuously past E188. None of the 35 rows
above gets an element number here. All 35 map to `unminted`, same as every
`UNASSIGNED` row in `goals/local-ai`'s own Owed table. Which element band
this lane draws from is an author call. It sits past what this doc can
measure.

## 4. The sizing

| by layer | rows | by kind | rows | by origin | rows |
|---|---|---|---|---|---|
| L0 | 5 | primitive | 22 | new | 37 |
| L1 | 2 | law | 11 | connect | 4 |
| L2 | 5 | port | 3 | bind | 1 |
| L3 | 6 | decision | 4 | | |
| L4 | 10 | tool | 2 | | |
| L5 | 4 | | | | |
| L6 | 5 | | | | |
| L7 | 5 | | | | |
| **total** | **42** | | **42** | | **42** |

L3, L4, L5 and L6 each carry the corrected row set: L3 gained N32, L4
gained N31, L5 gained N30, and L6 gained N33 alongside N26's widened scope.
This pass splits N25 into three rows: N25 narrows to the broadcast channel,
N34 carries the three metaparameter channels, and N35 gives the broadcast
its own unit kind at L3. L3 now also carries N35; L6 now also carries N34.
L0, L1, L2 and L7 are unchanged from both passes.

This pass adds five rows, all at L4: N36 and N37 (kind law), N38 through
N40 (kind primitive), all origin new. L4 moves from 5 rows to 10. Kind
moves from 19/9/3/3/1 to 22/11/3/3/1 (primitive/law/port/decision/tool).
Origin moves from 30/4/1 to 35/4/1 (new/connect/bind). L0, L1, L2, L3, L5,
L6 and L7 are unchanged this pass.

This pass adds two rows at L7. N41 is a tool and N42 a decision, both
origin new. L7 moves from 3 rows to 5. Kind moves from 22/11/3/3/1 to
22/11/3/4/2 (primitive/law/port/decision/tool). Origin moves from 35/4/1 to
37/4/1. The correction behind N41: an earlier reading of
`.planning/MANAS-STATE-VS-GOAL.md` treated the corpus as accumulating. The
write path and the schema are real. No database file was found, so the
running end is the gap and the row names that rather than the data.

Line estimate per layer, reasoned against the tree's own comparable
modules (`flow.chiral` at 1,373 lines, the chatter layer at 2,057 lines,
shard K's `manifest.chiral`/`golden.chiral` pair):

| layer | estimate | reasoning |
|---|---|---|
| L0 | ~150 | five small compositions over existing ops; no new sum type |
| L1 | ~200 | two type-level generalizations of an existing porttype |
| L2 | ~550 | three sum types plus decode arithmetic plus a codec pair, scaled against shard K |
| L3 | ~700 | a typed-I/O closure, a bug fix, a new porttype, one ProcessModel per backend, one cheap per-compartment decay-rate variable (N32), plus one stateless broadcaster unit kind (N35) |
| L4 | ~1,150 | two new constructs plus a routing table plus a `Flow` lift plus a branch-targeted inhibition target (N31), plus the construction API that builds and wires them (N36-N39), plus a dedication field (N40), the most structural layer |
| L5 | ~750 | a sum type, a per-member discipline, the runner wiring it drives, plus an inward feedback-edge constructor (N30) that `Advance` has no analog for today |
| L6 | ~650 | one trace type (N24), a fixed-random broadcast channel (N25) costing a wiring line, a small metaparameter-channel construct (N34), a plasticity rule widened to carry a structural placement change (N26), plus a distinct offline consolidation mode (N33) |
| L7 | ~450 | mostly reuse, and the cost is wiring. N41 adds a runner for the existing write path, N42 a gate |
| **total** | **~4,600** | |

Four estimates moved: L3 by +50, L4 by +50, L5 by +50, L6 by +100. Each
matches the one row its layer gained, except L6, which gained one row
(N33) and had an existing row (N26) reworded for structural scope, so it
carries the larger revision.

This pass moves two more. L3 moves by +50 again, for N35's stateless
broadcaster. L6 moves by +50 net: N34 adds a small metaparameter-channel
construct, and N25 now costs less than the bundled three-factor rule once
did, since a weight that never trains needs no training machinery of its
own. The two changes leave L6's net move at +50 rather than the sum of
each change taken alone.

This pass moves one more. L4 moves by +300, for the five rows in the
construction group and dedication (N36-N40): two constructor functions, a
closed connector sum, a network-assembly value, and a dedication field.

The tree is 44,682 lines. `prog/prapanca/` is 9,990 of it. The estimate above
is roughly 10% of the tree and about 45% of manas's own size, smaller than
manas itself because L7, the layer closest to manas, is nearly all
`connect`.

Section 6's census checked all 37 `origin: new` rows against the tree.
Zero moved. Kind and origin hold at 22/11/3/4/2
(primitive/law/port/decision/tool) and 37/4/1 (new/connect/bind), the same
totals this section already carried.

## 5. The discovery ratio

The display lane found that roughly half of its first rows already existed
in the tree, unreached. Section 2 of `docs/banks/unit.md` runs the
equivalent count for the AI lane's own existing layer, L7.

| state | count |
|---|---|
| written, unreached by any gate or shipping code (shard letters A,B,C,D,E,F,H,I,J,K,M,O,P,Q,R,S) | 16 |
| written, hand-run once outside any gate (shards G, L) | 2 |
| written, reached from the real scriba binary (shard N) | 1 |
| catalogued and absent, no shard letter (E142, E143) | 2 |

Nineteen of twenty-one entries already exist as code. Two are genuinely
absent. That ratio, 90% already written, runs well past the display lane's
"roughly half," and it covers only L7. L0-L6 never got an equivalent
tree-side census: the four `AI-LANE-*` notes did literature research
against neuromorphic hardware and simulators. A grep-for-existing-code pass
the way this bank ran for shards A-S never happened at those layers.

`AI-LANE-NUMERICS` section 3 is the one place in L0-L6 where that pass did
run, and it found the same pattern at smaller scale: `op-mulhi` already
sits in the `Op` sum, unbound at surface, one hit out of five gap-table
rows. That is row N1, and it is the cheapest row in the whole table: a
bind rather than a build.

The implication for section 2's `origin: new` rows was that they were never
checked against the tree the way A-S were. `origin: connect` rows (N1, N20,
N27, N28, N29) cost a gate or a wiring line. `origin: new` rows cost a
subsystem. The L7 census undercounted what already existed before this bank
ran it. Section 6 runs that grep. 37 `new` rows checked, zero moved to
`connect`, three ambiguous hits held at `new` and recorded there.

The four rows this correction pass added, N30 through N33, carried the same
gap before section 6's census. All four returned no hit. None moved.

This pass adds N34 and N35 and narrows N25 to the broadcast channel alone.
Section 6's census reached all three. No hit for any, no move.

This pass adds N36 through N40, the construction row group and dedication.
Section 6's census reached all five. No hit for any, no move.

## 6. Built so far

**E196 closed N8 and N9 on 2026-09-05**, the first element of the lane through
the full pipeline. `prog/unit/encoding.chiral` is 174 lines, gated by
`tools/test/encoding.sh` at nine rows with four mutants, none of which reddens
an arm it does not own. The suite held at 373 passed and 0 failed, the blob was
byte-identical at 820,959 bytes, and no fixpoint was owed.

Two of the design's defects were found by measurement rather than review:
`Latency` carried no scale, which made two arms of one sum decode onto two
domains, and `Population` decoded a silent window as a floor value. Both were
repaired inside the element, and giving `Latency` a `max` unified the error law
across all fourteen scalar rows.

**40 of 42 rows remain.** Against the roster's ~4,600-line estimate, E196 spent
roughly 174 lines of module plus its root and gate, so the remaining estimate is
approximately 4,400 lines.

## 7. The L0-L6 census

The grep pass section 5 called for, run 2026-09-05 against every row in
section 2 marked `origin: new`: 37 rows. Method, one or two targeted greps
per row over `lib/` and `prog/`, for the type name, constructor name or
function name the row's own text names. No source file opened; a grep hit
alone decided the verdict. A hit naming a different domain's homonym
counted as no hit: `Network` on sockets (`lib/ports/sock.port`,
`lib/protocol/http.chiral`), `Projection` on data-shape projection
(`lib/prelude/list.chiral:160`, `lib/typing/effects.chiral:29`), `router` on
chat dispatch (`prog/prapanca/chatter/router`), `Advance` on the English word
(`lib/surface/sexp.chiral:81`, `lib/protocol/render.chiral:451`), `trace` on
the type-checker's conversion trace or the stdio debug port
(`lib/typing/kernel-core.chiral:34`, `lib/ports/stdio.port:12`),
`consolidat-` on chat-message consolidation (`prog/scriba/chat.chiral:17`),
`eligibility` on the lowering pass's own eligibility partition
(`lib/lowering/upper/lower.chiral:1`).

| result | rows |
|---|---|
| checked | 37 |
| moved | 0 |
| ambiguous, held at `new` | 3 |

| row | hit | why it holds at `new` |
|---|---|---|
| N4 | `lib/lowering/tal/bytes.chiral:388`, a Horner-scheme byte decode | decodes an integer from eight bytes; not a polynomial evaluator over arbitrary coefficients for i-GELU/i-Softmax |
| N14 | `prog/prapanca/core/flow.chiral:75-77`, `ty-eq` defined and used from `prog/prapanca/core/flow-test.prog:38` | `ty-eq` exists and is reached; the row wants a shape-equality bug fixed inside it, not `ty-eq` built |
| N22 | `lib/typing/effects.chiral:1-6`, "the effect membrane" gating `->` against `=>` | the same two symbols, a general purity system already wired everywhere; no per-member, per-neuron application of it exists |

Zero rows moved. The 34 remaining `origin: new` rows returned no hit under
this method. N1's bind, `op-mulhi` sitting unbound in the `Op` sum, does not
repeat at N2 through N42: no second row is sitting unbound in an existing
sum or reachable function the way `op-mulhi` was. The three ambiguous hits
above are the closest this census came, and each holds at `new` on the
conservative rule: a hit naming the general mechanism a row would build on,
not the row's own concept, does not move it.
