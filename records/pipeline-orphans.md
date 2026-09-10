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

### The `design` orphans: a full review and mint, in a dedicated session

These are minted, unbuilt and unspeccable. The number is the only thing they
hold. No design was ever audited before them, because the stage that would have
produced one was retired, so each owes the pipeline from its first stage.

**A dispatched `element-design` run is the wrong instrument, and E163 measured
why.** One was dispatched 2026-09-10 against roster row `file-types/K1`. It
returned an artifact carrying five author calls: `prog/climb.manifest`'s
standing, whether a manifest may import computation, whether `GAP-04` and
`GAP-05` take rows of their own, the wiring-view fork, and whether Lane B may
write the fence into `parse`, `kernel` and `loader`. That is most of the design,
and an agent can take none of it. The five hold rows in [[records/author-calls]]
at `14e1e03`, and the artifact was reverted at `9325095`.

The same run stated the delta narrower than it is, by taking the arc's word that
`lib/lowering/tal/target-linux.manifest` conforms. It does not. It fails
`.planning/MANIFEST-DESIGN-MAP.md` requirement 4, which cites that file as the
reason the requirement exists: seven rows carry `16` at `:30-35` and `:60`, and
only comments tell them apart, which `sexp.chiral` drops at the lexer. It fails
requirement 3 as well, since `sys-row` is applied positionally.

**The route is a dedicated session with the author, structuring the design back
and forth before any artifact is written.** An orphan's design is where the
shapes get chosen, and the choosing is what the retired stage never recorded. An
agent can measure the tree for that session. It cannot settle a fork inside one,
and a design run that meets a fork has already left its own scope.

**Do not flip the roster row.** `open` beside an `E#` already says the number is
held and the pipeline is owed: [[arcs/README]] `:76` makes `open` the first
state, `:83` puts the `E#` in the element cell once minted, and `:65` fixes the
id across the mint. `docs/elements/ledger.md:29` glosses `design` as `unbuilt`,
so it asserts no stage either. The cataloging already says what these rows owe.
`pack.py` flips `open` to `designed` when it scaffolds a design, which erased
that on the one row carrying it. K1 was flipped and restored.

**The roster-row prerequisite, measured at `9325095`.** Of the 46 `design`
orphans, **14 hold a roster row** whose element cell carries the number and
**32 hold none**. Of those 32, **27 are named in no arc file at all**, so they
have no home to be reviewed in and some need an arc nobody has opened. The
figure moves as work lands: it read 47 earlier the same day, and
[[arcs/diagnostics-arc]] designing `L5` gave E176 an artifact and dropped it to
46. Run the recipe rather than quoting the number.

```
import importlib.util, glob, os, re, sys
spec = importlib.util.spec_from_file_location("pack", "tools/pack/pack.py")
pack = importlib.util.module_from_spec(spec); sys.argv = ["pack.py"]; spec.loader.exec_module(pack)
homed = {}
for f in sorted(glob.glob(os.path.join(pack.ARCDIR, "*-arc.md"))):
    arc = os.path.basename(f)[:-len("-arc.md")]
    text = open(f).read()
    for line in pack.roster_all(text):
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        for e in pack.row_elements(cells[-1]):
            homed.setdefault(e, []).append(arc + "/" + cells[0].strip("`").partition("/")[2])
named = {e for f in glob.glob(os.path.join(pack.ARCDIR, "*-arc.md"))
         for e in re.findall(r"\bE\d+\b", open(f).read())}
state = {}
for ln in open("docs/elements/ledger.md"):
    c = [x.strip() for x in ln.strip().strip("|").split("|")]
    if len(c) >= 3 and re.match(r"^\*{0,2}E\d+\*{0,2}$", c[0]):
        state.setdefault(re.sub(r"\D", "", c[0]), re.sub(r"[*`]", "", c[2]).split()[0].lower())
nums = [m.group(1) for m in (re.match(r"^\| E(\d+) ", l) for l in open("docs/elements/catalog.md")) if m]
orph = [n for n in nums if pack.pipeline_artifact("E%s" % n, "E%02d" % int(n))[0] is None
        and state.get(n) == "design"]
have = [n for n in orph if "E" + n in homed]
none = [n for n in orph if "E" + n not in homed]
print("design orphans %d | with a roster row %d | without %d | of those, in no arc at all %d"
      % (len(orph), len(have), len(none), len([n for n in none if "E" + n not in named])))
```

```
design orphans 46 | with a roster row 14 | without 32 | of those, in no arc at all 27
```

So the 32 need a home before they need anything else, which is an `arc-open` or
an arc amendment. Homing is the first work, and it is separable from the design
sessions that follow it.

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
