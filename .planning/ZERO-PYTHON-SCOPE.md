# Zero Python: the scope

**2026-08-31.** Goal, standing instruction: **no `.py` anywhere in
`/workspace/chirality`**.

⚑ **2026-09-07: `tools/xlat/xlat.sh` was written in shell for this rule**, 353
lines, and `tools/README.md` records that shell is no more chirality than Python
is, so it owes the same route. The file count below is unchanged and no `.py`
was added; `ledger-lint.py` grew by checks AK and AL. This is the work, sized per file, with what each one
needs from the language and in what order it can be done.

14 files, 4,654 LOC (was 4,629; `pack.py` grew 806 → 831 in the round-off pass
that produced this re-measure). Measured, every count below is a `grep -c` over
the actual file, re-run 2026-08-31 (second pass). The greps are written down under the
table so the next re-measure reproduces the number rather than a new methodology.

## What the whole set demands

| need | call sites | across | status |
|---|---|---|---|
| pattern matching | **142** | 13 of 14 files | **E173**, minted 2026-08-31, not built |
| directory walk | 27 | 6 files | **E148** `getdents64`, minted, not built |
| argv / flags | 20 | 8 files | **E150**, minted, not built; capability already exists via `/proc/self/cmdline` |
| process spawn | 13 | 5 files | **BUILT** — `runtime/proc.chiral`, `proc-spawn` (E33) |
| file write | 13 | 8 files | **BUILT** — `open-create` + `write-fd` (E105) |
| content hash | 6 | 2 files | **nothing.** See the open question below |

The greps, so the count is reproducible rather than re-derived. One `grep -c` per
file over all 14, comment lines included:

| need | pattern |
|---|---|
| pattern matching | `re\.(match\|search\|findall\|sub\|finditer\|split\|fullmatch\|compile)\(` |
| directory walk | `glob\.glob\|\.rglob(\|\.glob(\|os\.listdir\|os\.walk\|os\.scandir` |
| argv / flags | `sys\.argv` |
| process spawn | `subprocess` |
| file write | `open([^)]*, *["'][wa]` |
| content hash | `hashlib\|md5\|sha256` |

⚑ **What moved since the first pass, and why.** Only `argv` reproduced exactly.
`pattern matching` was 141 and is 142 (`ledger-lint` 56→57, `capture` 14→15, and
`pack` 36→35 because *this* pass deleted a dead `re.findall` from it). `directory
walk` was 22 and is 27: `ledger-lint` was credited 7 and has 13, because its walks
are `Path.rglob`/`Path.glob` rather than `glob.glob`, and `pack` went 6→5 in this
pass. `process spawn` kept its 13 but was filed across 4 files; it is 5, since
`docs/examples/refs/gen-elf.py` was inside the 13 and outside the 4. `file write`
was counted over `tools/` only (10 across 6); over all 14 files it is 13 across 8.
`content hash` said *frontier only*, which contradicted this document's own Wave 3
row: `scriba-edit-smoke` has 4 md5 lines. The file set itself did not drift.

Three elements gate almost everything, and **E173 is the one that matters**:
142 sites against 27 and 20. A matcher unblocks more of this than the other two
combined.

## Per file, in the order it can be done

### Wave 0 — buildable today, no new elements

| file | LOC | regex | why it is unblocked |
|---|---|---|---|
| `tools/scriba-run-smoke/scriba-run-smoke.py` | 51 | 1 | one file in, one verdict out. Takes its path on stdin like `prose-lint.prog` does |
| `tools/paren-audit/paren-audit.py` | 154 | 2 | pure per-file counting over source text. Its two regexes match `^\(def ` and `^\(data `, which are literal prefixes, so `str-find-from` covers them |

`prose-lint.prog` is the worked precedent for both: stdin path list, `openat`,
`str-find-from`, tab-separated rows out, exit code as the verdict.

### Wave 1 — needs E150 (argv) only

| file | LOC | regex | note |
|---|---|---|---|
| `tools/syscall-map/syscall-map.py` | 244 | 4 | reads `unistd_64.h` and the tal defs, counts three buckets. ⚑ Currently reports `BUILT: 0` because its regex says `TFn` where the defs say `TIFn` — 180 occurrences invisible. **Fix that before porting**, or the port faithfully reproduces a broken measurement |

### Wave 2 — needs E148 + E150 + E173

Every one of these walks a directory, takes flags, and matches patterns.

| file | LOC | regex | walk | what it is |
|---|---|---|---|---|
| `tools/doc/doc.py` | 330 | 8 | 1 | assembles one audit bundle per doc |
| `tools/capture/capture.py` | 620 | 15 | 1 | VISION note → scaffolded bank/node stubs |
| `tools/frontier/frontier.py` | 651 | 14 | 5 | extracts the digest. Also needs a hash |
| `tools/pack/pack.py` | 831 | 35 | 5 | the pipeline's input bundles |
| `tools/ledger-lint/ledger-lint.py` | 1128 | 57 | 13 | 19 checks. The largest, and the most regex-dense in the tree |

Order within the wave: `doc` first (smallest, and the audit programme runs on
it), then `capture`, `frontier`, `pack`, `ledger-lint` last. `ledger-lint` is
1128 LOC and 57 match sites; it is the one to port when the matcher has been
exercised by four smaller users.

### Wave 3 — the smoke tests

`tools/scriba-edit-smoke/scriba-edit-smoke.py` (131 LOC, 2 walks, 4 hash uses).
Drives a PTY and compares screen state. `ports/pty` exists and `proc-spawn`
exists, so the crossings are there; the hash uses are screen-state digests and
have the same open question as frontier's.

## Two things that are not ports, and need a decision

**1. `docs/examples/refs/gen-*.py` — 502 LOC across four files.**

These are not tools. They are the **OURS baselines**: the conventional-language
implementation that each worked example is compared against, sliced into the
bundle by `pack`. Their whole function is to be *not chirality*.

Porting them to chirality destroys what they are for. Deleting them leaves four
examples with no baseline. So the zero-python goal meets a real conflict here,
and it wants an author call rather than a port:

- keep them, and accept the goal means "zero python that chirality is built
  from or verified by", which is rung-1's own boundary;
- keep the content, drop the extension: they are read as text and never
  executed by the pipeline, so `gen-elf.py.txt` satisfies the letter;
- delete them and let those examples carry no baseline;
- rewrite the baselines in a third language, which keeps the contrast and moves
  the problem.

⚑ Two of them (`gen-elf.py`, `gen-fdpass.py`) are *executed*, not only read —
they shell out and they write files. Those two are closer to tools than to
baselines and should probably be split from the other two.

**2. The content hash. Nothing in the tree computes one.**

`frontier` hashes its 140 sources to detect staleness; `scriba-edit-smoke`
digests screen state. There is no `sha256` anywhere in `lib/`, and the LEDGER's
CRY category is reserved and unbuilt — six named slots, E114–E119
(entropy, bit-floor, hash, KDF, symmetric, asymmetric), none of them started.

It does not have to be cryptographic. Staleness detection needs a deterministic
digest, not collision resistance, and that is a few lines over `bget`. Screen
state is the same. If a real hash is wanted for other reasons it is a new
element and a real one; if not, this is a small pure function and no element at
all. **Deciding which is cheaper than building the wrong one.**

## The honest total

- **205 LOC** portable today (wave 0).
- **244 LOC** behind E150 alone.
- **3,560 LOC** behind E173, of which all of it also wants E148 and E150.
- **502 LOC** that should probably not be ported at all, pending the call above.
- **143 LOC** of smoke tests behind the hash question.

So the sequence that actually gets to zero is: **E173, then E148, then E150** —
in that order, because the matcher unblocks 13 of 14 files and the other two
unblock 6 and 8. Building E148 first would leave everything still waiting on
matching. The re-measure moved every figure it touched by a few points and left
that ranking exactly where it was.

Nothing here is blocked on a decision except the `refs/` question and the hash
shape. Everything else is elements that are already minted and unbuilt.

## Author decisions, 2026-08-31

**The `refs/` question is answered: zero Python is absolute.** Not "zero Python
that chirality is built from or verified by". No `.py` in the tree, full stop.
The route is: **drop everything not required**, then **catalog what must be
built** to replace what survives that cut with chirality forms. Renaming to
`.py.txt` was rejected as a dodge. Whether a read-only baseline is required is
itself part of the cut, and is decided per file, not per category.

**The hash question is answered: a small pure function.** A deterministic digest
over `bget`, a few lines, no element and no ledger row. `frontier`'s staleness
detection and `scriba-edit-smoke`'s screen-state digest are both satisfied by it.
The LEDGER's CRY category stays reserved and unstarted — corrected 2026-09-01,
it is not *empty*: E114–E119 are six named, slotted, unbuilt rows, and E116
(`crypto-hash`, SHA-256/512, SHA-3) is real cryptographic hashing. The decision
stands precisely because of that distinction: a staleness digest is not what E116
is for, so it takes none of E116's ground and mints nothing.
