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
An artifact at `drafted`, `reviewed` or `specced` is a live blueprint and
must describe the live tree. One at `implemented` is a record of what was
examined, and it earns a dated banner rather than a rewrite. **Rewriting an
implemented example to match today's compiler falsifies the record.**

## The classes, measured 2026-09-04 at `1fcb019`

Counts are files matched by grep, so they are an upper bound on defects
rather than a defect count. The disposition column is what closes the class.

| class | files | where the weight is | disposition |
|---|---|---|---|
| **DR-1** cut-Python: `chirality/*.py`, `scaffold/`, `python3 -m chirality` | 310 | elements 119, examples 105, `.planning` 47 | present-tense tiers rewritten; pipeline corpora dated |
| **DR-2** dead pre-migration paths: `lib/sys-tal.chiral`, `lib/ports.chiral`, `lib/collections.chiral`, `typing/pretty` | 131 | elements 57, examples 41 | same |
| **DR-3** `chirality verify`, a subcommand that has no referent | 21 | definitions 4, banks 4, `.planning` 4 | rewritten wherever it reads as live |
| **DR-4** `.planning/` called untracked, or `.gitignore:12` cited for it | 18 | elements 8, examples 5, records 5 | **false in every instance.** `git ls-files .planning` returns 145 |
| **DR-5** superseded figures: suite 303 or 321, binary 1,147,256 or 1,098,104 | 15 | elements 4, records 3 | dated at what they measured, the `status-ledger` pattern |

Six DR-4 instances were closed on 2026-09-03 and 2026-09-04 (`b5994d0`,
`4139662`). The remaining count above is measured after those.

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

- **A mechanical detector per class.** `tools/ledger-lint/ledger-lint.py`
  carries checks A to V and none of these five. Until a check names a class,
  it regrows silently, which is how all five reached these counts. This is the
  structural fix and it is `UNASSIGNED`.
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
