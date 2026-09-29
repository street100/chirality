---
name: element-design
description: >-
  Pre-mint design run for chirality. Turn ONE arc roster row (<arc>/<id>) into ONE
  design artifact under docs/arcs/parts/: the obligation, what the tree already
  holds, the real delta, the candidate shapes, the call, and the mint packet.
  Runs BEFORE an element number exists. Use when asked to "design a row", "work
  up text-tools/P2", "scope a roster row", or before minting any catalog element.
---

# element-design: the pre-mint design run

Produce exactly **one** design artifact per run, then **stop**. It works one
arc-local roster row up to the point where minting an element is a mechanical
step rather than a guess.

This runs **before the element has a number.** `docs/decisions/decision-design-before-mint.md`
moved minting to the end of the pipeline, and this is the stage that earns it.

This is a **design run, NOT an implementation run.** It writes one artifact under
`docs/arcs/parts/`. It does not edit `lib/`, `prog/`, the arc file, the catalog
or the ledger.

## When to use

For any row in an arc's roster whose `element` field reads `unminted`. The row
is cited as `<arc>/<id>`, such as `text-tools/P2` or `unit-lane/N24`, per
`docs/decisions/decision-work-ids.md`.

If the row already carries an `E#`, the design stage is behind it. Use
`design-to-spec`.

## Hard rule: one run = one row = one artifact

Exactly one `<arc>/<id>`. Touch nothing under `lib/` or `prog/`, and do not mint
anything. The mint runs off the design audit's PASS. End by naming the artifact
path and the verdict of §3, then **STOP**.

## Cadence is serial

One stage at a time, one agent at a time.
`docs/decisions/decision-dispatch-cadence.md` is the authority and it overrides
every parallel-waves protocol in this tree, this file included.

## Step 1: get the input bundle (ONE command)

```
python3 tools/pack/pack.py <arc>/<id> --start
```

This prints your **entire** input bundle: the row itself, the arc's goal and
requirements, the arc's other rows, the banks that name this concept, the
`docs/definitions/status-ledger.md` rung for anything the row touches, and
structural outlines of the `lib/`/`prog/` files the row names. `--start` is the
write: it **scaffolds** `docs/arcs/parts/<arc>-<id>.md` with the six section
headers ready and moves the roster row's `state` from `open` to `designed`. A row
already past `open` is refused by name with nothing written, and the refusal
names the revisit REOPEN that would drop it back. Without `--start` the command
prints the same bundle and writes nothing.

**Read that bundle and little else.** If an outline lacks a body you genuinely
need, a few *narrow* greps for a specific symbol or fact are allowed. Each extra
turn is the cost.

Cite the human tier: `docs/`, `records/`, the root spine, and the live source.
`.planning/` is the agent tier and is tracked, so a citation into it resolves;
it is still the wrong tier for an artifact a person reads. Write nothing into
`.planning/`.

## Step 2: fill the scaffolded artifact (six sections, in order)

Edit `docs/arcs/parts/<arc>-<id>.md` top to bottom. **The order is the method.**
§2 measures before §3 names a gap, and §3 sizes the gap before §4 proposes a
shape for it. Writing §4 first is the failure this stage exists to prevent.

| § | asks | fails when |
|---|---|---|
| 1 | **The obligation.** The row restated as what must become true, and which numbered arc requirement it serves | it cannot name the requirement |
| 2 | **What the tree holds.** The bank first, then the shard census, the live outlines, the ledger rung. Every claim at `file:line` | a claim carries no citation |
| 3 | **The delta.** What is missing once §2 is subtracted | it restates §1 |
| 4 | **The shapes.** Two or more candidate forms, each with what it costs and what it forbids | only one shape is listed and the tree does not force it |
| 5 | **The call.** One shape, with its reason, or NEEDS-AUTHOR surfaced and carried out of the run | a decision is taken silently |
| 6 | **The mint packet.** One element or several, the band, the catalog and ledger rows this would write, the size | it defers to an unminted `E#` |

### §2 is where the cardinal error is caught

**Read the concept's bank before naming a gap.** `docs/banks/INDEX.md` holds
twelve. A feature that is one thing elsewhere is here a sum of shards, each in
its own home, usually mostly built. Naming a phantom feature is the cardinal
working error in this repository. If the concept has no bank, say so in §2 and
build one before continuing.

§2 is a measurement, so it carries citations and dates. A count, a size or a
line number appears only when something was measured.

### §3 can close the row

**An empty delta is a real verdict and it is the most valuable one this stage
produces.** If §2 finds the work already built, §3 says so, §4 and §5 read
`closed by §3`, §6 mints nothing, and the row's state goes to `closed`. Report
which shards cover it. That outcome is a success, and minting an element to
build what exists is the failure it prevents.

### §4 carries the build rule's own test

`docs/definitions/working-discipline.md`: the pipeline runs for a row **iff
building it requires choosing between shapes the codebase does not already
settle.** §4 is where that is decided.

- **Shapes genuinely differ.** List them, at least two, each with its cost and
  what it forbids. §5 takes one.
- **The tree settles the shape.** Say so with the citation. §5's call is that
  shape, and §6 marks the row `direct`: it mints and goes to implement with no
  SPEC, because the defect is the blueprint.

Another language belongs here only where it is the source of a candidate shape,
and it gets a line. It gets no section. A claim about what chirality makes
impossible belongs nowhere in this artifact: it is a pitch, and §4 is a
measurement of the available forms.

### §5 disposes every decision

**RESOLVED** only when derivable from a settled doc, and cite it. **DEFERRED**
only to an `E#` or a roster row that already exists. **NEEDS-AUTHOR** is
surfaced and carried out of the run: it sets `status: blocked` in the
frontmatter and earns a row in `records/author-calls.md`. Answering one silently
is the defect.

### §6 is the graduation packet

The mint step reads it, so it is written to be executed:

- how many elements this row becomes, and why it splits or does not. Where two
  parts constrain each other, one element covers both;
- the reserved band it draws from, per `docs/decisions/decision-lane-split.md`,
  or `UNASSIGNED` where the arc holds none;
- the `docs/elements/catalog.md` row verbatim: title, kind, external reference,
  reference class, rationale, track;
- the `docs/elements/ledger.md` row verbatim: category, module, state, track;
- the size, in files touched and lines, with the basis for the estimate.

**Every follow-on `E#` you name must already be minted.** Where one is owed,
name a roster row, or open one in the arc and say that you did.

## Done

- `docs/arcs/parts/<arc>-<id>.md` filled, six sections, every §2 claim cited at
  `file:line`.
- Frontmatter `status: draft`, or `blocked` with the NEEDS-AUTHOR list.
- Nothing under `lib/` or `prog/` changed. Nothing minted. The arc file
  unchanged.
- Final message: the artifact path, §3's verdict (a delta, or closed), any
  NEEDS-AUTHOR questions verbatim, and the next pipeline step. Stop, and do not
  roll into the audit or the mint.
