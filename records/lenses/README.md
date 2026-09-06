---
node: lenses
layer: navigation
related: [records/README, records/author-calls, decisions/decision-four-lenses, decisions/decision-work-ids, arcs/README, goals/README, status-ledger, index]
status: current
updated: 2026-09-05
---

# The four lenses

Four kinds of thing this repo knows about itself, each fully enumerated, each in
its own file, each row citing what it is about.
[[decisions/decision-four-lenses]] settles the shape and the reason.

| lens | prefix | file | holds | the test |
|---|---|---|---|---|
| problem | `PRB-` | `problems.md` | the tree does something wrong, or a claim disagrees with a measurement | a fix is owed |
| gap | `GAP-` | `gaps.md` | something wanted that nothing schedules yet | it could be scheduled today |
| limit | `LIM-` | `limits.md` | a shortfall against what the project claims | it bounds a claim, and the claim is cited |
| unspoken | `UNS-` | `unspoken.md` | territory with no stated intent | nobody has ruled whether it is a gap or a limit |

A limit is a shortfall, present or absent. It can bound a capability that
exists: "refinement refuses out-of-range values for `I64` and for no other type"
bounds something built.

## The graduation chain

```
unspoken  ──►  gap  ──►  roster row  ──►  element
  UNS-          GAP-      <arc>/<id>         E##
```

A `UNS-` row leaves the lens only on an author ruling: to a `GAP-` row where the
work is wanted, to a `LIM-` row where it is not. A `GAP-` row graduates when an
arc takes it into its roster. A roster row mints per
[[decisions/decision-design-before-mint]].

**Every graduation keeps the predecessor's id in the successor's `from:`
field.** A citation made at any stage survives every later stage, which is the
invariant [[decisions/decision-work-ids]] already holds for roster rows.

Problems sit off the chain. A `PRB-` row is a defect and its fix is owed now.

## The row format

One row is one `###` block. Fields one per line, in this order.

```
### <ID> <short title>

- state:    <the lens's own closed set>
- author:   unreviewed | ruled <YYYY-MM-DD>
- note:     the author's words, verbatim, when ruled. Otherwise `none`
- level:    goal | arc | row | element | doc | source
- about:    the unit this concerns: [[goals/x]], <arc>/<id>, E##, or file:line
- claim:    what the repo says, and where it says it
- measured: what was observed
- evidence: file:line spans a reader can open
- checked:  YYYY-MM-DD
- owner:    the roster row or minted element that would close it, or `none`
- from:     the id this graduated from, or `none`
```

The heading is the ID and a short title. State lives on its own line, so
changing it is a one-line diff and the heading anchor never moves.

`owner:` never reads `UNASSIGNED`. [[decisions/decision-work-ids]] replaced that
form on 2026-09-01: name an arc-local roster row, or `none`.

## The state axis

| lens | states |
|---|---|
| `PRB-` | `OPEN` · `FIXED` · `RETIRED` |
| `GAP-` | `open` · `scheduled` · `closed` |
| `LIM-` | `accepted` · `to-plan` · `planned` · `in-works` · `covered` |
| `UNS-` | `open` · `ruled` |

`ACCEPTED` is gone from the problem lens. It read "the gap is real and
deliberately kept", which is a limit at `accepted`.

**A limit's five states are its journey down the chain**, read from the
shortfall's side:

| state | means |
|---|---|
| `accepted` | deliberately kept. `note:` says why, in the author's words |
| `to-plan` | wanted, and nothing owns it yet |
| `planned` | a `GAP-` row or a roster row owns it. `owner:` names which |
| `in-works` | that owner is being built |
| `covered` | closed. `measured:` says what closed it |

## The author axis

| marker | means |
|---|---|
| `unreviewed` | never put to the author |
| `ruled <YYYY-MM-DD>` | the author gave input, and `note:` carries it verbatim |

**`note:` holds the author's own words.** Paraphrasing a ruling loses the reason
it was made, and the reason is what stops the question being reopened.

**Every limit is walked with the author and marked when the ruling comes.**
[[records/author-calls]] is the register and states the obligation. The count of
`LIM-` rows at `unreviewed` is the outstanding sweep, and it is measurable.

A `PRB-` row the author accepts becomes a `LIM-` row at `accepted`, carrying the
ruling. A `UNS-` row cannot leave its lens without a ruling, because deciding
whether the project wants a thing is an author call by definition.

## Rules

Any agent may extend or amend a lens without asking. These exist so concurrent
edits merge.

**Adding a row.** Append to the end of its section. Mint the ID by taking the
next number in the lens prefix. Two agents appending at once can pick the same
number; git puts both blocks adjacent and the later one gets renumbered.
**Never renumber a row that already exists.** Its ID is cited elsewhere.

**Changing a row.** Edit `state:` and `checked:` together. A state change with a
stale `checked:` is a guess. Where the subject moved, update `evidence:` in the
same edit.

**Retiring a row.** Set the lens's retired state and leave the row in place.
Never delete one. The record of what was once wrong is why the file exists.

**Re-verifying.** A row whose `checked:` predates the last change to the files it
cites is unverified. `python3 tools/pack/pack.py --revisit` lists them, and the
`revisit` skill works one off.

**Evidence is mandatory.** `evidence:` names files and line spans. A row nobody
can re-run is worthless.

**Field text migrated from a records row is carried verbatim.** A row is a
record of what was claimed and what was measured, so rewriting its prose to suit
a linter would falsify it. `problems.md` and `unspoken.md` carry `prose-lint`
findings for that reason, and their baseline rows in
`.planning/PROSE-BASELINE.tsv` are frozen at the migration. Prose written fresh
into a lens is held to zero like any new file.

**Write `ruled` only for a ruling the author actually gave.** `author: ruled`
over an invented `note:` is the worst defect this format admits, because every
later reader treats it as settled.

## What enforces it

`python3 tools/lens/lens.py check` reads every row against this schema.
`ledger-lint` calls it, so a malformed row fails the same gate every other doc
claim fails.

`python3 tools/lens/lens.py author` prints what is awaiting a ruling, across all
four lenses. `python3 tools/lens/lens.py overview` regenerates the derived
orienting view.
