---
node: arc-zero-python
layer: navigation
related: [arcs/README, goals/self-tooling, arcs/diagnostics-arc, arcs/file-types-arc, index]
status: current
updated: 2026-09-05
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

## Roster

Groups are the waves the section below orders. `enabler` rows are the elements
the later waves need; `port` rows are the tool replacements themselves.

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `zero-python/Z1` | the total matcher, slice 1 built and gated by Phase 19. ⚑ Slice 2, the captures, is unbuilt | enabler | primitive | new | 3 | building | `E173` |
| `zero-python/Z2` | `getdents64`, the directory walk | enabler | port | new | 1 | open | `E148` |
| `zero-python/Z3` | argv. The capability exists via `/proc/self/cmdline` | enabler | port | new | 1 | open | `E150` |
| `zero-python/Z4` | typed process spawn | enabler | port | new | 1 | built | `E33` |
| `zero-python/Z5` | file write: a syscall crossing whose shape the kernel ABI forces, so it was built under the build rule with no blueprint | enabler | port | new | 1 | direct | `E105` |
| `zero-python/Z6` | wave 0: the three tools buildable today, `scriba-run-smoke`, `paren-audit` and `scriba-edit-smoke`, 336 LOC | wave-0 | tool | new | 1 | open | `unminted` |
| `zero-python/Z7` | wave 1: `syscall-map`, 244 LOC, behind `E150` | wave-1 | tool | new | 1 | open | `unminted` |
| `zero-python/Z8` | wave 2: `doc`, `capture`, `frontier`, `pack` and `ledger-lint`, 3,868 LOC re-measured 2026-09-04, behind `E148`, `E150` and `E173`. `doc` first, smallest, and the audit programme runs on it | wave-2 | tool | new | 1 | open | `unminted` |
| `zero-python/Z9` | delete `tools/` rather than empty it | wave-2 | decision | new | 2 | open | `unminted` |

### Coverage

⚑ **Requirement 4 is served by no row**, enumerated as `GAP-18`: every
replacement running on the tree's own test floor is a property each ported tool
carries rather than a deliverable of its own.

Requirements 1, 2 and 3 are served: 1 by Z2 to Z8, 2 by Z9, 3 by Z1. Every row
serves one, and every `origin` is `new`.

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
