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
| L3 | the unit: stateful, typed ports, one implementation per backend | `Expert` (shard A) is stateful with named fields, but `sees`/`returns` are `Str` prose by explicit deferral (`types.chiral:64`). `Backend` (shard G) is one porttype, one backend shape. No Process/ProcessModel split for a neuron unit exists |
| L4 | topology: populations, projections, connectors, routing tables | `Flow`/`Pipeline`/`Order` (shards C, D) are the tree's only compositional primitives, and they route `Expert` calls. No `Population`, `Projection`, connector, or routing table exists |
| L5 | execution protocol: the `Advance` sum | Given as a design shape in `AI-LANE-EXECUTION` section 4, unbuilt. The tree's own loop is a Mealy FSM (shard Q, E66, "already chirality") driving one flat step (shard P): one discipline picked once for the whole run |
| L6 | plasticity: a rule bound to a projection | Absent. `docs/banks/unit.md` section 5 point 7 measured that `ExpertCall`/`RunManifest` are append-only: nothing folds a later verdict back into an earlier record, which is the revision channel a plasticity rule needs |
| L7 | deliberative composition: `Flow`, `Skill`, `Expert` | Built. Shards A, C, H, K, O are all **compiled**: present, complete, compiling on every suite pass, executed by none of it, per section 2's own census |

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
| N17 | `Population` construct | L4 | primitive | new |
| N18 | `Projection`/connector construct | L4 | primitive | new |
| N19 | routing table (address plus fan-out) | L4 | primitive | new |
| N20 | lift `Population`/`Projection` through `Flow`, reusing shards C/D | L4 | law | connect |
| N21 | `Advance` sum (`advance-tick`/`advance-on-event`/`advance-hybrid`) | L5 | primitive | new |
| N22 | per-member membrane discipline (`->` pure step, `=>` boundary) | L5 | law | new |
| N23 | build the membrane once per member; `Advance` picks the trigger, no shared queue | L5 | decision | new |
| N24 | eligibility-trace type (per-synapse accumulator) | L6 | primitive | new |
| N25 | three-factor update rule (broadcast signal times trace, via `op-mulhi`) | L6 | law | new |
| N26 | a plasticity rule bound to a `Projection` (port) | L6 | port | new |
| N27 | `Expert`/`Flow`/`Skill` reused as the lane's composition layer | L7 | primitive | connect |
| N28 | `RunManifest`/golden oracle reused as the lane's audit record | L7 | primitive | connect |
| N29 | `SkillEntry` registry reused for population/skill entries | L7 | tool | connect |

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
shard; L6's plasticity rule closes the append-only gap unit.md's residue
point 7 measured.

`decision-lane-split` reserves `E184-E189` and `E190-E195` for two other
lanes, and the catalog runs continuously past E188. None of the 29 rows
above gets an element number here. All 29 map to `unminted`, same as every
`UNASSIGNED` row in `goals/local-ai`'s own Owed table. Which element band
this lane draws from is an author call. It sits past what this doc can
measure.

## 4. The sizing

| by layer | rows | by kind | rows | by origin | rows |
|---|---|---|---|---|---|
| L0 | 5 | primitive | 14 | new | 24 |
| L1 | 2 | law | 9 | connect | 4 |
| L2 | 5 | port | 3 | bind | 1 |
| L3 | 4 | decision | 2 | | |
| L4 | 4 | tool | 1 | | |
| L5 | 3 | | | | |
| L6 | 3 | | | | |
| L7 | 3 | | | | |
| **total** | **29** | | **29** | | **29** |

Line estimate per layer, reasoned against the tree's own comparable
modules (`flow.chiral` at 1,373 lines, the chatter layer at 2,057 lines,
shard K's `manifest.chiral`/`golden.chiral` pair):

| layer | estimate | reasoning |
|---|---|---|
| L0 | ~150 | five small compositions over existing ops; no new sum type |
| L1 | ~200 | two type-level generalizations of an existing porttype |
| L2 | ~550 | three sum types plus decode arithmetic plus a codec pair, scaled against shard K |
| L3 | ~600 | a typed-I/O closure, a bug fix, a new porttype, one ProcessModel per backend |
| L4 | ~800 | two new constructs plus a routing table plus a `Flow` lift, the most structural layer |
| L5 | ~700 | a sum type, a per-member discipline, and the runner wiring it drives |
| L6 | ~500 | narrow in scope, one trace type and one update rule, but numerically dense |
| L7 | ~300 | almost entirely reuse; the cost is wiring |
| **total** | **~3,800** | |

The tree is 44,682 lines. `prog/manas/` is 9,990 of it. The estimate above
is roughly 8.5% of the tree and about 38% of manas's own size, smaller than
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

The implication for section 2's 24 `origin: new` rows is that they were
never checked against the tree the way A-S were. `origin: connect` rows
(N1, N20, N27, N28, N29) cost a gate or a wiring line. `origin: new` rows
cost a subsystem. The L7 census undercounted what already existed before
this bank ran it. Some of the 24 `new` rows above are likely `connect` rows
nobody has looked for yet, and that grep should run before any of L1-L6 is
treated as a green field.
