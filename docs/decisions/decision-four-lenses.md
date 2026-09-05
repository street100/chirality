---
node: decision-four-lenses
layer: decision
related: [records/README, records/lenses/README, records/author-calls, arcs/README, goals/README, decision-design-before-mint, decision-work-ids, working-discipline, open-edges, index]
status: settled
updated: 2026-09-05
---

# Decision: four lenses, each enumerated, each carrying an author marker

**Settled 2026-09-05 by author directive.**

## The problem

This repo has a whole system for tracking what it knows about itself and almost
none of it is tracked by a tool. Measured 2026-09-05:

| claim | measured |
|---|---|
| `records/` is checked | `ledger-lint` reads **one** of 14 records files, `conformance-map.md`, in checks E and Q. The other 13 hold **156 rows** that nothing checks |
| the six-field row format holds | **49 of 169 rows carry none of the six fields**, concentrated in `lane-a-record` (14), `conformance-map` (13), `author-calls` (6) |
| the four states hold | five rows carry free-text `state:` values outside the closed set, one of them the literal `<STATE>` from the README's own example |
| an element belongs to exactly one arc | **48 unbuilt elements are named by no arc.** 74 more are built orphans, which is history and legitimate. 16 arc-owned elements have no ledger row |
| `element:` resolves | 49 rows read `UNASSIGNED`, the form [[decisions/decision-work-ids]] replaced on 2026-09-01. `records/README.md` still instructs it |
| gaps have a home | **8 of 22 arcs** carry a `What is missing` section |
| problems have a home | three, none authoritative: `records/findings.md` (12 rows), five `.planning/FINDING-*.md` files, and 68 `OPEN` rows across 13 files |

Underneath the counts is one confusion. **Three different things share every
home.** A defect, a piece of unbuilt work, and an honest shortfall are three
kinds of claim, and this tree files all three as a `records/` row, an
`open-edges` entry, or a paragraph under `## Honest limits`, interchangeably.

The clearest instance: `records/README.md` defines the `ACCEPTED` state as *"the
gap is real and deliberately kept"*. That is a limit, written as a state of a
problem row. Fifteen rows carry it.

## The four lenses

Each is fully enumerated, individually numbered, tracked in its own file, and
cites what it is about.

| lens | prefix | holds | the test |
|---|---|---|---|
| **problem** | `PRB-` | the tree does something wrong, or a claim disagrees with a measurement | a fix is owed |
| **gap** | `GAP-` | something wanted that nothing schedules yet | it could be scheduled today |
| **limit** | `LIM-` | a shortfall against what the project claims | it bounds a claim, and the claim is cited |
| **unspoken** | `UNS-` | territory with no stated intent | nobody has ruled whether it is a gap or a limit |

**A limit is a shortfall, present or absent.** The earlier framing of "absent and
accepted" was wrong twice: a limit can bound something that exists, and
acceptance is one of five dispositions rather than the definition. "Refinement
refuses out-of-range values for `I64` and for no other type"
([[goals/enforcement]]) is a limit on a built capability.

**The unspoken lens is what the 48 orphaned elements need.** Calling them gaps
would claim someone scheduled them. Calling them limits would claim someone
accepted them. Both are false: they are territory with no ruling, and today that
reads as a violation of
"an element belongs to exactly one arc" when it is really a queue nobody can
see.

## The graduation chain

Three of the four sit on one chain, and it is the chain
[[decisions/decision-design-before-mint]] already built:

```
unspoken  ──►  gap  ──►  roster row  ──►  element
  UNS-          GAP-      <arc>/<id>         E##
```

A `UNS-` row graduates when the author rules: to a `GAP-` row where the work is
wanted, or to a `LIM-` row where it is not. A `GAP-` row graduates to a roster
row when an arc takes it. A roster row mints. Every graduation keeps the
predecessor's id in the successor's `from:` field, so a citation made at any
stage survives.

Problems sit off the chain: a `PRB-` row is a defect, and its fix is owed now.

## Two axes on every row

Every row in every lens carries a state **and** an author marker with a note.

### The state axis

| lens | states |
|---|---|
| `PRB-` | `OPEN` · `FIXED` · `RETIRED` |
| `GAP-` | `open` · `scheduled` (a roster row owns it) · `closed` |
| `LIM-` | `accepted` · `to-plan` · `planned` · `in-works` · `covered` |
| `UNS-` | `open` · `ruled` (it became a `GAP-` or a `LIM-`) |

`ACCEPTED` leaves the problem lens. It was always a limit.

**A limit's five states are its journey down the chain.** `accepted` is
deliberately kept with the note saying why. `to-plan` is wanted with nothing
owning it. `planned` means a `GAP-` row or a roster row owns it. `in-works`
means it is being built. `covered` means it closed, and the note says what
closed it. That is the same spine, read from the shortfall's side.

### The author axis

| marker | means |
|---|---|
| `unreviewed` | never put to the author |
| `ruled <YYYY-MM-DD>` | the author gave input. `note:` carries it verbatim |

Two states, because the question a row answers is whether the author has been
over it.

**`note:` holds the author's own words.** Paraphrasing a ruling loses the reason
it was made, and the reason is what stops the question being reopened.

## `records/author-calls.md` becomes the register

It stops being six ad-hoc rows and becomes the index over every row in every
lens that is awaiting input or has been ruled.

**Every limit is walked with the author and marked when the ruling comes.** That
obligation is stated in the register, and it is measurable: the count of `LIM-`
rows at `unreviewed` is the outstanding sweep.

The same logic reaches the other three lenses. A `PRB-` row the author accepted
becomes a `LIM-` row at `accepted` with the ruling in its note. A `UNS-` row
cannot leave the unspoken lens without a ruling, because deciding whether the
project wants a thing is an author call by definition.

## What enforces it

`tools/lens/lens.py` owns the schema, the checks and the derived views.
`ledger-lint` calls its check pass, so a malformed row fails the same gate every
other doc claim fails.

The orienting view is generated on the precedent `docs/definitions/FRONTIER.md`
already sets, and a hand edit to it is a defect: `layer: generated`, pure extraction,
byte-identical on a re-run, and a lint check that fails it stale.

## What this costs

169 existing rows migrate. 49 of them carry no fields at all and cannot be
sorted mechanically, so each needs a reading. The 15 `ACCEPTED` rows move to the
limit lens leaving a pointer, the 48 orphaned elements seed the unspoken lens,
and the prose under every goal's `## Honest limits` becomes `LIM-` rows.

Every migrated row lands at `author: unreviewed`, because none of them has been
walked. That number is the honest size of the sweep this decision creates.
