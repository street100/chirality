---
node: records-doc-rot
layer: record
related: [records/README, records/baseline-alignment, working-discipline, index]
status: current
updated: 2026-09-04
---

# Doc rot: the five classes, and what counts as a defect

Opened 2026-09-04, after four ad hoc sweeps closed roughly thirty files and
left the shape of the problem unmeasured. This is the measured shape, so a
later session resumes from a number rather than a hunch.

`records/baseline-alignment.md` holds one finding per row. This holds one
*class* per row, with a count, because these five recur across hundreds of
files and a per-file row would bury the pattern.

## What decides a defect

`MAP.md` sorts the doc tier by role, and the role decides whether a dead
reference is rot or history.

| tier | role | a dead reference is |
|---|---|---|
| `docs/definitions/`, `docs/modules/`, `docs/banks/` | the present tense of the system | a **defect** |
| `docs/decisions/` | one settled fork carrying its reason | context, until it is cited as live |
| `docs/goals/`, `docs/arcs/` | what is claimed, and where work stopped | a **defect** |
| `docs/examples/`, `docs/elements/specs/` | pipeline artifacts, staged | see below |
| `records/`, `docs/benchmarks/` | a claim beside its measurement, dated | history by construction |

For the pipeline corpora the status in `docs/examples/INDEX.md` decides it.
An artifact at any pre-build status is a live blueprint and must describe the
live tree: `minted`, `drafted`, `reviewed`, `specced`, `audited`. `audited`
reads *spec audit passed; implement-ready* in that index and holds 44 of the
116 rows, which makes it the heaviest blueprint state in the corpus. One at
`implemented` is a record of what was examined, and it earns a dated banner
rather than a rewrite. **Rewriting an implemented example to match today's
compiler falsifies the record.** `needs-rework` and `superseded` are left alone
for the same reason: both already say the artifact stopped being followed.

## The classes, measured 2026-09-04 by `ledger-lint`

`tools/ledger-lint/ledger-lint.py` checks **W, X, Y, Z and AA** carry the five.
Each is a detector for one class, and the count below is what its own run
reports at `0bd65dd`.

The earlier figures here were grep over the whole tree, an upper bound on
defects. These are a lower bound. A check counts only files the tier rule above
admits: 111 live-tier docs, the 4 skill files, and the 98 pipeline artifacts
whose `docs/examples/INDEX.md` status is pre-build (`minted`, `drafted`,
`reviewed`, `specced`, `audited`). 213 files in all.

| class | check | files | references | where the weight is |
|---|---|---|---|---|
| **DR-1** cut-Python: `chirality/*.py`, `scaffold/`, `python3 -m chirality` | `W` | 81 | 474 | 73 pipeline artifacts, 8 live-tier docs |
| **DR-2** dead pre-migration paths: `lib/sys-tal.chiral`, `lib/ports.chiral`, `lib/collections.chiral`, `typing/pretty` | `X` | 32 | 62 | 26 pipeline, 6 live-tier |
| **DR-3** `chirality verify`, a subcommand that has no referent | `Y` | 6 | 8 | 5 live-tier, 1 spec |
| **DR-4** `.planning/` called untracked, or `.gitignore:12` cited for it | `Z` | 5 | 5 | 3 skill files, 2 arcs |
| **DR-5** superseded figures: suite 303 or 321, binary 1,147,256 or 1,098,104 | `AA` | 0 | 0 | closed in the scanned tiers |

The disposition is unchanged: a live-tier hit is rewritten, a pipeline artifact
is dated. Six DR-4 instances were closed on 2026-09-03 and 2026-09-04
(`b5994d0`, `4139662`), and the count above is measured after those.

DR-5 reads zero because every live-tier instance already carries the date it
measured, which is the disposition the class was given. The grep bound of 15
files sits almost entirely in `records/` and the element registries, which the
tier rule never scans.

## What the detectors do not see

Stated because a check that hides its blind spot is worse than one that names
it. All five under-report by construction: a check that cries wolf is a check
nobody reads.

- **`records/` and `docs/benchmarks/` are never scanned.** History by
  construction, per the table above. Three DR-4 instances live there
  (`records/README.md:113`, `records/lane-a-record.md:33`,
  `records/consolidation-handoff.md:87`) and stay unflagged.
- **`docs/decisions/` is skipped.** A settled fork legitimately carries the
  reference it retired, and no mechanical rule separates that from a citation
  read as live.
- **`.planning/` is skipped.** The tier mixes present-tense protocol with dated
  pass records and the two do not split by path. Grep put 47 DR-1 and 4 DR-3
  instances there.
- **`docs/elements/catalog.md`, `docs/elements/ledger.md` and
  `docs/examples/INDEX.md` are skipped.** Each row is one dated build record,
  and flagging it invites the rewrite this document exists to prevent.
- **A dated or retired block excuses its references.** The excuse is the
  paragraph, or the table row when the hit is inside one, and it fires on a
  date or on a retirement word. It suppressed 456 of 937 raw cut-Python
  matches. Some of the 456 are real defects that happen to share a paragraph
  with a date. That trade is deliberate.
- **`AA` passes a dated figure that disagrees with another dated figure.**
  `docs/goals/self-hosting.md:33` reads *321 assertions, 0 failed, 87 roots,
  last recorded run 2026-09-01 in [[status-ledger]]*, and
  `docs/definitions/status-ledger.md:46` records 303 assertions and 88 roots
  for that same run. Both carry their date, so the check clears both. The
  disagreement is semantic and belongs to a doc audit.

## Two claims that were false rather than stale

Both spread across files before anyone measured them, which is why they get
their own rows.

- **`lib/typing/totality.chiral` is imported by nothing.** False since
  termination was wired 2026-09-02: `typing/totality-check.chiral:62` imports
  it and `lowering/compile-front.chiral:24` imports that. Retired in
  `status-ledger`, `docs/examples/INDEX.md` and `module-split-arc`. ⚑ The real
  limit survives and must travel with every retirement: the classifier gates
  only where a profile carries `(total)`, and no phase fails when it breaks.
- **E50 lexicographic and mutual descent is built.** False: `totality.chiral:11-13`
  scopes both out of E11, no `(measure ...)` form exists in `lib/` or `prog/`,
  and the catalog reads not built. Retired in `docs/definitions/totality.md`
  at `1fcb019`.

## Owed

- **A mechanical detector per class** is built and the item is closed.
  `ledger-lint` checks `W`, `X`, `Y`, `Z` and `AA` name DR-1 through DR-5 in
  that order, added 2026-09-04. Each was demonstrated against a constructed
  file that trips it before the file was deleted. Checks `A` to `V` are
  untouched and their counts hold: `G(74)`, `R(132)`, the rest clean or
  vacuous.
- **`tools/syscall-map/syscall-map.py` is broken.** Line 122 matches
  `(def nb-sys-\S+ TFn` where the live defs are `TIFn`, so it finds zero
  crossings and would emit `BUILT 0 / FACED 20 / UNMODELED 342` against
  `docs/definitions/syscall-map.md`'s `13 / 10 / 339`. Regenerating is worse
  than the stale file. The one-line fix recovers 26 crossings, double the
  doc's 13, so a repaired generator rewrites the table substantially.
  `UNASSIGNED`.
- **`G(74)` and `R(132)`**, the `file:line` citation classes. Ruled
  record-do-not-chase; the structural fix is the stable address, `P4` in
  `docs/arcs/text-tools-arc.md`, `UNASSIGNED`.
