# The AI lane: what has to be built, and how big it is

Four research notes exist (`AI-LANE-ENCODING`, `AI-LANE-NUMERICS`,
`AI-LANE-RECORDING`, `AI-LANE-EXECUTION`) plus `docs/banks/unit.md`'s own
census of the manas shard set. No arc holds any of it. This maps the four
notes and the census onto a row table, onto `goals/local-ai`'s conditions,
and onto a line-count estimate, using only measurements already on record.

## 1. The layer stack

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
| N8 | `Encoding` sum (`Rate`/`Latency`/`Population`) | L2 | primitive | new |
| N9 | encode/decode arithmetic over `Encoding` | L2 | law | new |
| N10 | `RecordRequest` sum (`record-spikes`/`record-membrane`/`record-weights`) | L2 | primitive | new |
| N11 | unbounded trace type paired against `RunManifest`, parallel to `RawCall` | L2 | primitive | new |
| N12 | spike/graded payload message-width contract | L2 | law | new |
| N13 | typed I/O on `Expert`, closing the `sees`/`returns` deferral | L3 | primitive | new |
| N14 | `ty-eq` shape-equality fix | L3 | law | new |
| N15 | a Process-like porttype for a neuron unit, distinct from `Backend` | L3 | port | new |
| N16 | one ProcessModel implementation per backend for that unit | L3 | port | new |
| N32 | per-compartment decay-rate state: one slow-decaying state variable per compartment, the ALIF mechanism for multi-timescale processing | L3 | primitive | new |
| N17 | `Population` construct | L4 | primitive | new |
| N18 | `Projection`/connector construct, addressed to a compartment inside a unit | L4 | primitive | new |
| N19 | routing table (address down to a compartment, plus fan-out) | L4 | primitive | new |
| N20 | lift `Population`/`Projection` through `Flow`, reusing shards C/D | L4 | law | connect |
| N31 | branch-targeted inhibition: shunting inhibition vetoes one branch, pathway-specific gating; a second routing target the topology layer must carry | L4 | primitive | new |
| N21 | `Advance` sum (`advance-tick`/`advance-on-event`/`advance-hybrid`) | L5 | primitive | new |
| N22 | per-member membrane discipline (`->` pure step, `=>` boundary) | L5 | law | new |
| N23 | build the membrane once per member; `Advance` picks the trigger, no shared queue | L5 | decision | new |
| N30 | inward feedback edge: a somatic spike back-propagates into the member's own dendrite; coinciding with a distal plateau it produces a high-gain burst. `Advance` crosses `=>` outward from a member when it fires and carries no constructor for a signal crossing back in | L5 | primitive | new |
| N24 | eligibility-trace type (per-synapse accumulator) | L6 | primitive | new |
| N25 | three-factor update rule (broadcast signal times trace, via `op-mulhi`) | L6 | law | new |
| N26 | a plasticity rule bound to a `Projection` (port), over a weight change or a structural placement change | L6 | port | new |
| N33 | a consolidation mode: an offline phase where structural plasticity reorganizes the network, distinct from the online updates N24-N26 assume | L6 | decision | new |
| N27 | `Expert`/`Flow`/`Skill` reused as the lane's composition layer | L7 | primitive | connect |
| N28 | `RunManifest`/golden oracle reused as the lane's audit record | L7 | primitive | connect |
| N29 | `SkillEntry` registry reused for population/skill entries | L7 | tool | connect |

N33's kind is `decision`. REM dendritic calcium spikes are implicated in
pruning and strengthening spines, and that finding names a phenomenon. The
phase's trigger, its scope, and its interaction with N24-N26's online rule
stay unpinned to any one shape, and each is an open question a builder still
has to close before N33 compiles.

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
lanes, and the catalog runs continuously past E188. None of the 33 rows
above gets an element number here. All 33 map to `unminted`, same as every
`UNASSIGNED` row in `goals/local-ai`'s own Owed table. Which element band
this lane draws from is an author call. It sits past what this doc can
measure.

## 4. The sizing

| by layer | rows | by kind | rows | by origin | rows |
|---|---|---|---|---|---|
| L0 | 5 | primitive | 17 | new | 28 |
| L1 | 2 | law | 9 | connect | 4 |
| L2 | 5 | port | 3 | bind | 1 |
| L3 | 5 | decision | 3 | | |
| L4 | 5 | tool | 1 | | |
| L5 | 4 | | | | |
| L6 | 4 | | | | |
| L7 | 3 | | | | |
| **total** | **33** | | **33** | | **33** |

L3, L4, L5 and L6 each carry the corrected row set: L3 gained N32, L4
gained N31, L5 gained N30, and L6 gained N33 alongside N26's widened scope.
L0, L1, L2 and L7 are unchanged from the first pass.

Line estimate per layer, reasoned against the tree's own comparable
modules (`flow.chiral` at 1,373 lines, the chatter layer at 2,057 lines,
shard K's `manifest.chiral`/`golden.chiral` pair):

| layer | estimate | reasoning |
|---|---|---|
| L0 | ~150 | five small compositions over existing ops; no new sum type |
| L1 | ~200 | two type-level generalizations of an existing porttype |
| L2 | ~550 | three sum types plus decode arithmetic plus a codec pair, scaled against shard K |
| L3 | ~650 | a typed-I/O closure, a bug fix, a new porttype, one ProcessModel per backend, plus one cheap per-compartment decay-rate variable (N32) |
| L4 | ~850 | two new constructs plus a routing table plus a `Flow` lift plus a branch-targeted inhibition target (N31), the most structural layer |
| L5 | ~750 | a sum type, a per-member discipline, the runner wiring it drives, plus an inward feedback-edge constructor (N30) that `Advance` has no analog for today |
| L6 | ~600 | one trace type and one update rule, widened to carry a structural placement change (N26), plus a distinct offline consolidation mode (N33) |
| L7 | ~300 | almost entirely reuse; the cost is wiring |
| **total** | **~4,050** | |

Four estimates moved: L3 by +50, L4 by +50, L5 by +50, L6 by +100. Each
matches the one row its layer gained, except L6, which gained one row
(N33) and had an existing row (N26) reworded for structural scope, so it
carries the larger revision.

The tree is 44,682 lines. `prog/manas/` is 9,990 of it. The estimate above
is roughly 9% of the tree and about 41% of manas's own size, smaller than
manas itself because L7, the layer closest to manas, is nearly all
`connect`.

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

The implication for section 2's 28 `origin: new` rows is that they were
never checked against the tree the way A-S were. `origin: connect` rows
(N1, N20, N27, N28, N29) cost a gate or a wiring line. `origin: new` rows
cost a subsystem. The L7 census undercounted what already existed before
this bank ran it. Some of the 28 `new` rows above are likely `connect` rows
nobody has looked for yet, and that grep should run before any of L1-L6 is
treated as a green field.

The four rows this correction pass added, N30 through N33, carry the same
gap. No census reached them either. Each could turn out to be a `connect`
row already sitting somewhere in the tree, and the new-to-connect ratio
above runs further toward `new` until that census exists.
