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

## What is owed, and it splits by state

**The three populations owe different work, and treating them alike is the
error this section exists to prevent.**

### The 17 `built` orphans: serial audit and adjustment, never a rerun

These elements are **implemented**. The work exists in the tree, and in most
cases it was audited under the old flow before it landed. What is missing is the
rationale artifact, not the deliverable.

**Do not run `element-design`, `design-to-spec` or an implementation pass on any
of them.** A design run on built work is the phantom-feature error
`docs/definitions/working-discipline.md` names as the cardinal one, and its §3
empty-delta close is the pipeline catching that error rather than a route to
take deliberately. Re-speccing implemented work produces a change plan aimed at
a tree that already carries it, which is exactly the DEAD and DONE-ALREADY
buckets `records/spec-tier-triage.md` measured across 129 SPECs.

What they owe instead is **an audit of the record against the tree, and an
adjustment where the two disagree.** One element per run, serially, per
`docs/decisions/decision-dispatch-cadence.md`. Per element: open the catalog row
and the ledger row, open what is actually in `lib/` or `prog/`, and correct the
rows where they disagree. `doc-audit` is the skill shaped for this; the
implementation pipeline is not.

The output is a corrected row and a `records/` line, not a new artifact under
`docs/elements/specs/`.

### The 47 `design` orphans: a rationale artifact, then the ordinary pipeline

These are minted, unbuilt, and unspeccable. They need what the retired stage
would have produced. E163's route is the model: `element-design` on the roster
row that already carries the element, after which the mint step is a no-op
because the number is held.

**The prerequisite nobody has measured: whether each of the 47 holds a roster
row.** E163 does. The other 46 were not checked. An orphan with a row costs one
design run; an orphan without one needs a row first, which is an `arc-open` or
an arc amendment, and for an element minted deep in a track that may be an arc
nobody has opened. **Count that before choosing anything**, since it decides
whether this is 47 dispatches or 47 plus arc work.

### The 9 blank-state orphans: triage first

The ledger carries no state for them. Which of the two populations above they
join is unknown, and reading the tree for each is the first step.

## What was considered and rejected

**Letting `pack.py --spec` write from the catalog and ledger rows** when no
rationale artifact exists. Cheaper and weaker: the design stage is what measures
the baseline, and skipping it is precisely what
`docs/decisions/decision-design-before-mint.md` exists to prevent. It would also
manufacture SPECs for the built population, which is the rerun this file rules
out.

**A sweep.** Whatever the route, it runs one element at a time.
`docs/decisions/decision-dispatch-cadence.md` is the authority and
`records/consolidation-handoff.md` records the case that established it: a
consolidation pass dispatched over all 138 remaining files at once, stopped for
that reason.

⚑ **Author-tier.** Whether an element minted under the old flow keeps its number
when its design run finds an empty delta. `element-design` §3 can close a row
without minting; an already-minted orphan has nothing to withhold.
