---
node: arc-zero-python
layer: navigation
related: [arcs/README, goals/self-tooling, arcs/diagnostics-arc, arcs/file-types-arc, index]
status: current
updated: 2026-09-04
---

# Arc: zero Python

- goal: [[goals/self-tooling]]
- reserved element block: **none**. Rows needing one carry arc-local ids `T1`
  and up, per [[decisions/decision-work-ids]], and map to `unminted`.
- working detail: `.planning/ZERO-PYTHON-SCOPE.md`, tracked with the rest of
  `.planning/` since 2026-09-01 (`docs/decisions/decision-ai-tier.md`). The facts
  a reader of this arc needs are copied below.

TRACKED for the reason [[arcs/diagnostics-arc]] is.

## Why this arc exists

`CLAUDE.md` states the target: zero Python in this repo, and `tools/` deleted.
The author call of 2026-08-31 made it absolute. It does not mean zero Python in
the compile path, which has been true for the whole migration.

## REQUIREMENTS

Done when all four hold.

1. **No `.py` file anywhere under the repo root**, `tools/` and the four
   `docs/examples/refs/gen-*.py` generators included.
2. **`tools/` is deleted rather than emptied.**
3. **Each replacement is verified against the tool it replaces**, on the same
   inputs, before the Python is removed. A port whose equivalence is unverified
   does not count as a port.
4. **Every replacement runs on the tree's own test floor**, the way
   `prog/prose-lint.prog` does.

## What the whole set demands

14 files, 4,962 LOC, re-measured 2026-09-04 (4,826 on 2026-09-01, 4,654 on
2026-08-31). The file count holds and the total climbs because the Python tools
keep being repaired: `ledger-lint` reads 1,375 lines, `pack` 891, `doc` 331. The
line counts here are `wc -l`, which reproduces every 2026-09-01 per-file figure.
The call-site counts below are a `grep -c` over the actual file, and the patterns
are recorded in `.planning/ZERO-PYTHON-SCOPE.md` so a re-measure reproduces the
number rather than a new methodology. That file's own totals were taken on
2026-08-31 and read 4,654.

| need | call sites | across | element |
|---|---|---|---|
| pattern matching | 142 | 13 of 14 files | E173, minted. Slice 1 built 2026-09-01, `lib/text/matcher.chiral`, Phase 19. Captures are slice 2 and unbuilt |
| directory walk | 27 | 6 files | E148 `getdents64`, minted, unbuilt |
| argv and flags | 20 | 8 files | E150, minted, unbuilt |
| process spawn | 13 | 5 files | BUILT, `runtime/proc.chiral` (E33) |
| file write | 13 | 8 files | BUILT, `open-create` plus `write-fd` (E105) |
| content hash | 3 | 2 files | nothing. `hashlib.sha256` in `frontier`, `hashlib.md5` twice in `scriba-edit-smoke`. A small pure function, a deterministic digest over `bget`. No element, no ledger row: author call |

E173 is the one that matters: 142 sites against 27 and 20. A matcher unblocks
more than the other two combined.

## Element list

| element | title | state |
|---|---|---|
| E173 | the total matcher | slice 1 BUILT 2026-09-01: `lib/text/matcher.chiral`, gated by Phase 19 `tools/test/matcher.sh`. The pipeline ran end to end, example `33204e6` through implementation `e882568`. ⚑ Slice 2, the captures, is unbuilt |
| E148 | `getdents64`, the directory walk | minted, unbuilt |
| E150 | argv | minted, unbuilt. The capability exists via `/proc/self/cmdline` |
| E33 | typed process spawn | BUILT |
| E105 | file write | BUILT |

The three arcs that supply the rest are [[arcs/diagnostics-arc]] (printing and
reporting) and [[arcs/file-types-arc]] (declared forms and derived codecs).

## The files, in the order they can be done

**Wave 0, buildable today, no new elements.** Three files.
`tools/scriba-run-smoke/scriba-run-smoke.py` (51 LOC),
`tools/paren-audit/paren-audit.py` (154 LOC) and
`tools/scriba-edit-smoke/scriba-edit-smoke.py` (131 LOC). The last was missing
from this list until 2026-09-01: the file count said 14 and the waves covered
13. It uses `hashlib.md5` twice, which is the unminted digest below, so it is
wave 0 only if the smoke check can compare bytes instead of a digest. `prog/prose-lint.prog` is the
worked precedent: a path list on stdin, `openat`, `str-find-from`,
tab-separated rows out, exit code as the verdict.

**Wave 1, needs E150.** `tools/syscall-map/syscall-map.py` (244 LOC).

**Wave 2, needs E148 plus E150 plus E173.** `tools/doc/doc.py` (331),
`tools/capture/capture.py` (620), `tools/frontier/frontier.py` (651),
`tools/pack/pack.py` (891), `tools/ledger-lint/ledger-lint.py` (1375), all
re-measured 2026-09-04. Order within the wave is `doc` first, smallest and the
audit programme runs on it.

## Resume state

**Wave 0 is NOT done.** `prog/paren-audit.prog` exists and
`tools/paren-audit/paren-audit.py` is still on disk at 154 LOC; their
equivalence is unverified, which requirement 3 forbids treating as a port.
`tools/scriba-run-smoke/scriba-run-smoke.py` was never ported at all.
`prose-lint` had no `.py` left to replace, so citing it as wave-0 evidence
inflated the claim.

Two known defects to settle before their file is ported, because a faithful port
reproduces a broken measurement:

- `tools/syscall-map/syscall-map.py` reports `BUILT: 0`. Its regex says `TFn`
  where the defs say `TIFn`, so 180 occurrences are invisible. Fixing it changes
  what the tool measures.
- `prog/prose-lint.prog` counts eight of the shell tool's ten checks. `not-but`,
  `parallel-no` and code-skipping all landed with E173 slice 1. The two it leaves
  out are `self-reference` and `first-person`, printed as NOT-CHECKED rows every
  run and recorded in the source as E173 residue. Read 2026-09-04.

Open decision, author-tier: the four `docs/examples/refs/gen-*.py` generators
(502 LOC) are sliced into pipeline bundles by `pack` as the OURS baselines.
Deleting them costs four worked examples their comparison. Renaming them to
`.py.txt` was rejected as a dodge.

## Duplicated facts

The measurement table and the wave ordering are copied from
`.planning/ZERO-PYTHON-SCOPE.md`, which is tracked. Two copies of one measurement
will drift, and these two have: the totals here were re-measured on 2026-09-04
and that file's were taken on 2026-08-31. Which one is authoritative is an author
call that this arc does not make.
