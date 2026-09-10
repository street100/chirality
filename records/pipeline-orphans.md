---
node: records-pipeline-orphans
layer: record
related: [records/README, records/spec-tier-triage, elements/ledger, elements/catalog, examples/INDEX, decisions/decision-design-before-mint, arcs/file-types-arc, index]
status: current
updated: 2026-09-10
---

# Pipeline orphans — elements that cannot reach a SPEC

**47 minted, unbuilt elements have no rationale artifact, so `pack.py` refuses
to spec them.** They are not blocked on a decision or on the substrate. They are
blocked on a stage of the pipeline that no longer exists.

This file carries no build-state authority. `docs/elements/ledger.md` and
`records/conformance-map.md` hold that.

## The mechanism

`docs/decisions/decision-design-before-mint.md` moved minting to the end of the
pipeline on 2026-09-05 and retired the worked-example stage with it.
`docs/examples/` is CLOSED to new writes, which `MAP.md` records.

`pack.py --spec` writes a SPEC from one of exactly two rationale artifacts: a
`docs/examples/E<NN>-*.md`, or a design at `docs/arcs/parts/<arc>-<id>.md`
reached from a roster row whose element cell carries the number. An element
minted under the old flow that never got an example has neither, and now never
can get the first one.

## The measurement, 2026-09-10

| | |
|---|---|
| elements in `docs/elements/catalog.md` | 186 |
| with a `docs/examples/E<NN>-*.md` | 122 |
| **without one** | **73** |
| of those, ledger state `design` | **47** |
| of those, ledger state `built` | 17 |
| of those, ledger state blank | 9 |

Reproduce:

```
ls docs/examples/E*.md | sed 's/.*\/E\([0-9]*\)-.*/\1/' | sort -u > /tmp/ex
grep -o '^| E[0-9]\+' docs/elements/catalog.md | grep -o '[0-9]\+' | sort -u > /tmp/cat
comm -23 /tmp/cat /tmp/ex          # the 73
```

The 47 in `design` state are the actionable class: minted, unbuilt, and
unspeccable. The 17 `built` ones reached implementation by another route and are
not urgent. Only six design artifacts exist under `docs/arcs/parts/` in total, so
effectively none of the 73 is covered by the second rationale path.

## The worked case: E163

A `design-to-spec` run on **E163** was dispatched 2026-09-10 and refused at step
one. `python3 tools/pack/pack.py E163 --spec`:

```
no rationale artifact for E163: no example examples/E163-*.md and no design at
docs/arcs/parts/<arc>-<id>.md reached from a roster row whose element cell reads E163.
A SPEC is written from one of the two
```

`--audit spec` refuses identically, and `--mark audited` routes through the same
`pipeline_artifact()` path, so a hand-written SPEC could never have been gated.
The dispatched agent declined to write one for that reason, which was correct.

E163's escape is that its roster row `file-types/K1` already carries the element,
so `element-design` on that row produces the missing artifact and the mint step
is a no-op. `docs/arcs/file-types-arc.md`'s resume state records that route and
the five measurements it turned up.

## What is owed, and it is not decided here

**Whether every orphan has a roster row is unmeasured.** E163 does; the other 46
were not checked. An orphan with a row takes E163's route. An orphan with no row
needs one, which is an `arc-open` or an arc amendment, and for an element minted
years into a track that may be an arc nobody has opened.

Three shapes, none chosen:

1. **Route each orphan through `element-design` on its roster row**, as E163
   does. Correct per the pipeline and costs one design run per element.
2. **Let `pack.py --spec` accept a minted element with no rationale artifact**,
   writing the SPEC from the catalog and ledger rows. Cheaper and weaker: the
   design stage is what measures the baseline, and skipping it is what
   `decision-design-before-mint` exists to prevent.
3. **Triage first.** Count how many of the 47 hold a roster row before choosing,
   since that number decides whether 1 is 47 dispatches or 47 plus an arc.

⚑ **Author-tier.** Whether an element minted under the old flow keeps its number
when its design run finds an empty delta. `element-design` §3 can close a row
without minting; an already-minted orphan has nothing to withhold.
