---
node: records-consolidation-handoff
layer: navigation
related: [records/README, arcs/presentability-arc, goals/presentability, elements/README, index]
status: current
updated: 2026-09-01
---

# Handoff: the `.planning` consolidation

**Resume from this file.** It is for a session that did not do the work below.
Tracked, so a fresh clone gets it.

## What this is

`.planning/` was 267 files of untracked working material that 76 tracked
documents cited, across 156 distinct paths. A fresh clone got the goals, the arcs,
the records and the build state, and then every element row they pointed at was
missing. The consolidation moves what is load-bearing into git and archives what
is spent.

## Done

**The element tier is tracked** (`8d8ddb6`). Moved, not reshaped — byte-for-byte
what it was, at a new path:

| from | to |
|---|---|
| `.planning/SELF-IMPLEMENT-CATALOG.md` | `docs/elements/catalog.md` |
| `.planning/LEDGER.md` | `docs/elements/ledger.md` |
| `.planning/specs/` (126 files) | `docs/elements/specs/` |
| `.planning/audit/CONFORMANCE-MAP.md` | `records/conformance-map.md` |

71 reference sites rewritten. Four tools built their paths programmatically and
were repointed separately — `frontier`'s spec glob and catalog path,
`ledger-lint`'s ledger, catalog and conformance-map paths. **No `.gitignore`
change**: moving the tier out of `.planning/` makes it tracked and leaves the
ignore rule simple.

**One consolidation pass ran** (`0136859`, `4a3e8ec`, `49db58b`, `b7d279f`):
the six `FINDING-*` files became tracked rows in `records/findings.md`;
`BUILD-ORDER.md` split, its A1–A6 altitude taxonomy into
`docs/definitions/altitude-errors.md` and its wall-clock numbers into
`docs/benchmarks/test-suite-wall-clock.md`; `presentability-arc` now names its two
working queues instead of duplicating them; `CONTENTS.md` repointed off `UMBRELLA`.

`.planning/` is now **138 files, 89 live and 49 archived**, from 267. Measured
2026-09-01, whole files, not `.md` only:

| | count |
|---|---|
| live, top level | 66 |
| live, in subdirectories | 23 — `capture/` 8, `handoffs/` 6, `scriba-examples/` 5, `capture-fixtures/` 2, `audit/` 2 |
| live, total | 89 |
| `archive/` | 49 — 29 at its top, plus `audit/` 9, `handoffs/` 7, `projects/` 3, `quick/` 1 |

Counting `.md` alone it is **86 live and 49 archived**, which is what
`.planning/DOC-AUDIT-QUEUE.md` carries and it is correct there. The three
non-`.md` live files are `MIGRATION-MAP.tsv`, `PROSE-BASELINE.tsv` and
`capture-fixtures/frontier-stub.py`.

⚑ This file previously said "66 live files and 33 archived". 66 counted the top
level and dropped the 23 files in subdirectories. **33 matches no count anyone
can state**: the archive holds 29 at its top and 49 in total. Its top plus
`projects/` plus `quick/` sums to 33, but that subset drops `audit/` and
`handoffs/` for no reason, so it is arithmetic and not a measurement.
`.planning/` is untracked, so no history recovers what the number counted.
Recorded as wrong rather than explained away.

## Open, and how to continue

**Cadence: serial, one document at a time, one agent at a time.** Standing author
directive, restated in `.planning/DOC-AUDIT-QUEUE.md`. The first pass was
dispatched as a sweep over all 138 remaining files and was stopped for that
reason. Do not repeat it. Iterative passes, each one checkable.

### 1. The rest of `.planning/` — 89 live files, 86 of them `.md`

Evidence, not orders: `/workspace/chirality-docmap/rows/DOCS.tsv`, 267 rows, one
per document, verdict in column 11 and target in column 12. Its paths are stale
for anything moved since. Verify each against the tree before acting.

Rules that bind the work:

- **Deferred is not deleted.** The ownership/trust track — re-bootstrap climb,
  DDC, secure datum model, register root, cascade; E53, E71, E72 — stays.
  `RUNG2-*`, `AI-RESIDENT-*`, `AUTH-HARNESS-MAP`, `VISION-deployment-custody`,
  `capture/deployment-custody-*` are in this class. Never archived for inactivity.
- **Never cut an honest limit.** `⚑`, "unbuilt", "UNVERIFIED", "VACUOUS",
  "SEEDED", every measured number with its date.
- **An archive with no named successor is not an archive.** If no successor can be
  named, it is a KEEP and the reason is written down.
- **A standing directive inside an archived file is hoisted, not buried.** Two
  known and still open: `E69-E72-CHECKLIST.md` carries an AUTONOMY CONTRACT, and
  `HARNESS-REFACTOR-CHECKLIST.md` carries a "migrating to rocq" invariant that is
  false since external judgment was cut.
- **Do not mint an element number.** `LANES.md` reserves `E184-E189` and
  `E190-E195`; anything else writes `UNASSIGNED`.

Files that need an author call rather than a pass:

- `PRIMITIVES-FOR-NATIVE-TOOLS.md` and `ZERO-PYTHON-SCOPE.md` are live, and
  `docs/arcs/zero-python-arc.md` records that the duplication between the arc and
  the scope file is unresolved. Do not resolve it silently.
- `PERSONA.md` is cited from `docs/index.md` as "how to work here", so it is
  reachable from tracked docs and cannot simply be archived.

### 2. The citation rot tracking exposed

`ledger-lint` went from 3 failing checks to 7 when the element tier entered a
scanned doc role:

```
before   A(5) I(1) T(1)                              7 issues
after    A(5) B(5) F(27) G(77) I(1) R(112) T(1)    228 issues
```

**None of it is new breakage.** Those citations were always wrong; they sat where
the doc-role scan did not reach. Re-ignoring the directory to make the number fall
would be the gate-that-cannot-fail error `CLAUDE.md` names as cardinal.

The 221 new issues are almost all inside `docs/elements/specs/`. `records/`
BA-20, BA-21 and BA-22 already record this class: a citation is `file:line` and
line numbers rot. Repointing 221 of them by hand is the wrong fix and the arc
knows it — the right one is the stable address, which is
`docs/arcs/text-tools-arc.md` P4 and is unminted.

**So: record them, do not chase them.** A pass that repoints line numbers will be
undone by the next insertion above them.

### 3. Five dead citations, recorded not repaired

Visible only after the move, dead before it:

- `.planning/METIS-PORT-SPEC.md` — cited 5×, named as the source spec for
  E133–E136 in `docs/elements/catalog.md`. Present nowhere in the tree.
- `.planning/E94-diagnostic.md`
- four `.planning/scriba-examples/S1`–`S3` files that do not exist; the directory
  holds S13–S17 instead.

`METIS-PORT-SPEC` is the one worth an author call: four built manas elements cite
it by section as their contract.

## What not to do

- **Do not sweep.** One slice, one commit, checked.
- **Do not edit `lib/` or `prog/` for citations.** A comment-only change is still
  a change to compiler source and owes a fixpoint rebuild. Six such edits were
  made and reverted during the move for this reason; the precedent is
  `lib/typing/diag.chiral:32`, which still reads `LAYOUT.md` and is deliberately
  deferred.
- **Pathspec every commit** — `git commit -- <paths>`. A bare commit sweeps
  another agent's staged work. That has happened twice here.
