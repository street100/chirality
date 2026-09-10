---
node: records-pipeline-orphans
layer: record
related: [records/README, records/spec-tier-triage, elements/ledger, elements/catalog, examples/INDEX, decisions/decision-design-before-mint, arcs/file-types-arc, arcs/emitted-speed-arc, index]
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

Two counts. The file count asks which elements lack an example; the tool count
asks `pipeline_artifact()`, the function `--spec` calls, which of the two
artifacts it resolves. They differ by one element.

| | |
|---|---|
| elements in `docs/elements/catalog.md` | 186 |
| with a `docs/examples/E<NN>-*.md` | 122 |
| **without one** | **64** |
| of those, ledger state `design` | **47** |
| of those, ledger state `built` | 17 |
| of those, ledger state blank | 0 |
| of the 64, with no rationale artifact of either kind | **63** |
| of those, ledger state `design` | **47** |
| of those, ledger state `built` | 16 |

Every recipe below runs from the repo root and prints what is written beside it.

Reproduce the file count. Both sides pad to three digits first, because
`docs/examples/` zero-pads a single-digit element and `docs/elements/catalog.md`
does not:

```
ls docs/examples/E*.md | sed 's|.*/E0*\([0-9]*\)-.*|\1|' | awk '{printf "%03d\n",$1}' | sort -u > /tmp/ex
grep -o '^| E[0-9]\+' docs/elements/catalog.md | grep -o '[0-9]\+' | awk '{printf "%03d\n",$1}' | sort -u > /tmp/cat
wc -l < /tmp/cat                     # 186
wc -l < /tmp/ex                      # 122
comm -23 /tmp/cat /tmp/ex | wc -l    # 64
```

Reproduce the state split over those 64. Column 3 of the ledger row is the
state, read the way `ledger-lint` check N reads it
(`tools/ledger-lint/ledger-lint.py:956-963`): markup stripped, first token,
lowercased.

```
for n in $(comm -23 /tmp/cat /tmp/ex); do
  awk -F'|' -v e="E$((10#$n))" '{gsub(/[ *`]/,"",$2); if ($2==e) {gsub(/[*`]/,"",$4); split($4,a," "); print tolower(a[1]); exit}}' docs/elements/ledger.md
done | sort | uniq -c
```

```
     17 built
     47 design
```

Every one of the 64 has a state, so the 17 and the 47 account for all of them.

Reproduce the tool count by calling `pipeline_artifact()` directly, which is
what `--spec`, `--audit spec` and `--mark audited` all route through:

```
python3 - <<'PY'
import importlib.util, os, re, sys
from collections import Counter
spec = importlib.util.spec_from_file_location("pack", "tools/pack/pack.py")
pack = importlib.util.module_from_spec(spec); sys.argv = ["pack.py"]; spec.loader.exec_module(pack)
nums = [int(m.group(1)) for m in (re.match(r"^\| E(\d+) ", l) for l in open("docs/elements/catalog.md")) if m]
state = {}
for ln in open("docs/elements/ledger.md"):
    c = [x.strip() for x in ln.strip().strip("|").split("|")]
    if len(c) >= 3 and re.match(r"^\*{0,2}E\d+\*{0,2}$", c[0]):
        state[int(re.sub(r"\D", "", c[0]))] = re.sub(r"[*`]", "", c[2]).split()[0].lower()
orphans = [n for n in sorted(nums) if pack.pipeline_artifact("E%d" % n, "E%02d" % n)[0] is None]
print(len(orphans), Counter(state.get(n, "<blank>") for n in orphans))
PY
```

```
63 Counter({'design': 47, 'built': 16})
```

**The one element the two counts disagree on is `E189`, and the tool is right.**
It is `built`, it has no `docs/examples/E189-*.md`, and it is the only element
in the catalog whose rationale artifact is a design rather than an example:
roster row `emitted-speed/X7` carries the number and
`docs/arcs/parts/emitted-speed-X7.md` exists, so `design_rows` reaches it. That
resolution does not depend on the `row_elements` repair at `6e9c76a`. The cell
reads a single id, so the whole-cell comparison it replaced matched it too, and
the pre-`6e9c76a` `pack.py` returns the same 63 over the same catalog. The other
five designs under `docs/arcs/parts/` sit on rows that have not minted, and
`bridge/C4`, the two-element row `6e9c76a` was written for, has no design file,
so `E40` and `E56` still resolve to nothing.

So the 47 in `design` state are the actionable class: minted, unbuilt, and
unspeccable, and none of them is covered by the second rationale path. The 16
`built` orphans reached implementation by another route and can wait.

⚑ **This section read 73 without an example, split 47 `design` / 17 `built` /
9 blank, and the 73 and the 9 were both wrong.** That recipe compared unpadded
catalog numbers against zero-padded filenames, so `E1` through `E9` never
matched the eleven files `docs/examples/` holds for them, `E01-sexp-reader.md`
first. Those nine are the whole of the phantom "blank state" population: the
ledger gives every one a state, eight `built` and `E2` `part`, and every one of
them has an example. Dropping the nine leaves 64, and the 25 `built` in the bad
set falls to 17, which is how the old `built` figure came out right by
cancelling two errors. `pack.py` was never affected:
`tools/pack/pack.py:1587` builds the tag as `f"{prefix}{num:02d}{sfx}"`, so the
tool has always looked for `E01-*.md`.

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

**The two populations owe different work, and treating them alike is the
error this section exists to prevent.**

### The 16 `built` orphans: serial audit and adjustment, never a rerun

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

### There is no third population

The blank-state class this file used to name was the padding artifact recorded
above, and no element in the ledger carries an empty state cell.

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
