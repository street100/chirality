---
node: arc-bridge
layer: navigation
related: [arcs/README, goals/bridge, category-bridge, axis-typeability, decision-bridge-elaborator, decision-work-ids, certificate-discipline, split-role, status-ledger, index]
status: current
updated: 2026-09-02
---

# Arc: the supervisory bridge

- goal: [[goals/bridge]]
- reserved element block: **none**. Rows carry arc-local ids `C1` and up, per
  [[decisions/decision-work-ids]], and map to an element or to `unminted`.
- build-state authority: [[status-ledger]]

Opened 2026-09-02. [[thesis]] names C as "the part of Chirality that is new work
rather than borrowed" and the tree had no goal, no arc and no row against it.

## Why this arc exists

`lib/module/loader.chiral:295-300` holds `cat-fenced`, a total function of a
finished `Sheet` that refuses a module declaring `(cat A)` which reaches a
crossing. Its arms:

```
((cat-a) (case xs (nil none) ((cons x r) (some (sh-cat-crosses nm x)))))
(_       none)
```

A is fenced. B and C fall to the wildcard. So the coordinate that carries the
project's one claim to originality can be declared and owes nothing.

Meanwhile [[category-bridge]] states two obligations in prose: verify inbound,
confine outbound. Neither is a rule anything runs.

## What is in the tree already

| module | lines | note |
|---|---|---|
| `lib/surface/parse.chiral:1127` | n/a | produces `cat-c` from the surface. The coordinate is declarable |
| `lib/module/loader.chiral:279-300` | n/a | `SheetErr` has exactly one arm, `sh-cat-crosses`, and it is A's |
| `lib/lowering/tal/sys.chiral` | 1343 | calls itself "tal's C category in miniature" in prose, declares no coordinate |
| `lib/typing/kernel-core.chiral` | 60 | the certificate seam C would use where the property is provable. Zero importers, FD-09 |

Seven other modules name a category in a comment. Prose is how this axis is
carried today.

## REQUIREMENTS

Done when all four hold.

1. **A `(cat C)` module owes something.** `SheetErr` gains the C arms and
   `cat-fenced` stops answering `none` for two of three values.
2. **The two obligations are stated as decidable rules** rather than as prose:
   no B-derived value reaches A without becoming evidence, and no A value
   reaches B without being confined.
3. **Each has a mutant that is actually run.** A check aimed at a guess passes by
   looking at nothing.
4. **The bridge is one elaborator instantiated with an evidence element**, rather
   than a bridge written per referent
   ([[decisions/decision-bridge-elaborator]]).

## Rows

| row | what | state | element |
|---|---|---|---|
| `bridge/C1` | what a `(cat C)` module owes, written down as a decidable rule | not started. Requirement 1 and 2. `category-bridge` has the prose | `unminted` |
| `bridge/C2` | `cat-fenced` gains its B and C arms, with a mutant | not started. Today `(_ none)` covers both | `unminted` |
| `bridge/C3` | the modules that call themselves C in prose declare it instead | not started. `sys.chiral` and seven others | `unminted` |
| `bridge/C4` | custody as the first evidence element | `E40` SEEDED and conforming; `E56` is "vapor beyond secret seed" | `E40`, `E56` |
| `bridge/C5` | the bridge elaborator, one generic re-checker | not started. Open edge 12 owes it | `unminted` |

## Resume state

Nothing built for C1 to C3 or C5. C4 is the only row with minted elements and
they predate this arc: `records/conformance-map.md` §D assigned `E40`, `E42` and
`E56` on 2026-07-21.

**What blocks the arc.** No reserved element block, so nothing here can be
minted. That is an author call, and the rows carry arc-local ids meanwhile. The
same block sits on [[arcs/independent-judgment-arc]].

**The order that is forced.** C1 comes first and C2 cannot precede it: a fence
with no stated rule is a check aimed at a guess. C3 is cheap once C2 exists and
worthless before it, because declaring a coordinate that carries no obligation
adds a claim rather than a check.

**A dependency this arc does not own.** Where a C property is provable, the
mechanism is a certificate re-checked by `kernel-core`
([[certificate-discipline]]), and that module has zero importers. FD-09 and
`independent-judgment/J2` own the wiring. C5 cannot land before it.

## Constraints this arc works under

- **C is itself typed.** [[category-bridge]]: "A hole in the supervisor would be
  the thesis's gap restated, so C is implemented in typed code with no
  exemption." A bridge written in B fails to be a bridge.
- **Evidence falls short of proof, and the verb matters.** [[split-role]] and
  `PRINCIPLES.md` §5 name this a downgrade: detection rather than prevention. A
  row here that claims prevention is claiming the wrong tier.
- **The split is a partition.** [[axis-typeability]]: a module that seems to be
  two kinds at once still awaits its cut ([[splitting-law]]). Adding a C arm to a
  module that is already A is the wrong move; cutting it is the right one.
