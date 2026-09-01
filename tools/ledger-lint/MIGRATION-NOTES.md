# ledger-lint — migration notes

Carried as-is from `bin/ledger-lint.py` (1033 L). One mechanical change: `ROOT` is
now three levels up (`tools/<name>/<name>.py`), not two.

## It cannot run against this tree, and the reason is not a path

`ledger-lint` is the **doc tier's** mechanical sorter: checks A–S cross-check
documentation claims against the conformance map, the link graph, line citations
against live files, and the cheatsheet's ops against the Python oracle. **None of
its inputs exist here** — this tree has source and tools, and its `docs/` is three
empty directories (`examples/`, `definitions/`, `elements/`).

First failure, unmodified:

```
FileNotFoundError: .../docs/status-ledger.md
```

That is check A. Every later check fails the same way on a different file.

## What it needs, exactly

Concrete files (each read directly, no fallback):

| path | used by |
|---|---|
| `docs/status-ledger.md` | check A |
| `CONTENTS.md` | check C |
| `docs/open-edges.md` | check D |
| `.planning/audit/CONFORMANCE-MAP.md` | the build-state authority for every bank shard claim |
| `.planning/SELF-IMPLEMENT-CATALOG.md` | element-row existence |
| `.planning/LEDGER.md`, `.planning/RUNG1-CHECKLIST.md` | ledger rows |
| `examples/INDEX.md`, `examples/_CHEATSHEET.md` | the worked-example corpus |
| `docs/FRONTIER.md` | the frontier digest |

Directories globbed: `docs/*.md`, `docs/banks/*.md`, `docs/decision-*.md`,
`examples/E*-*.md`, `.planning/`, `TUI/`, `scaffold/`, `bin/`.

Two of those are **gone by decision**, not merely unmapped:

- `scaffold/metis/kernel.py` and `scaffold/metis/refine.py` — the Python oracle.
  The cheatsheet-ops check (`refine.py`) has no authority to check against here.
- `bin/metis-frontier.py` → now `tools/frontier/frontier.py`; the reference is a
  string in a message, not an import.

## What is NOT decided, and must not be invented

The new tree's doc tier is `docs/{examples,definitions,elements}/` — a different
shape from `docs/*.md` + `docs/banks/` + `examples/` + `.planning/`. Whether
`docs/elements/` replaces `.planning/SELF-IMPLEMENT-CATALOG.md` + the CONFORMANCE-MAP,
and whether `docs/definitions/` replaces `docs/banks/`, is an **author decision that
has not been made**. Rewriting the checks against a guess would produce a linter that
passes because it is looking at nothing — the exact failure class this tool exists
to catch. Left pointing at the old shape until the doc tier is settled.

## 2026-08-31: it runs

The 14 required inputs are present. Seven were path mismatches after the doc
role sort and the source migration, and all seven had a recorded destination in
`.planning/MIGRATION-MAP.tsv`, so this was a repoint rather than a guess:

| was | now |
|---|---|
| `docs/status-ledger.md` | `docs/definitions/status-ledger.md` |
| `docs/open-edges.md` | `docs/definitions/open-edges.md` |
| `docs/FRONTIER.md` | `docs/definitions/FRONTIER.md` |
| `examples/` | `docs/examples/` |
| `examples/INDEX.md` | `docs/examples/INDEX.md` |
| `examples/_CHEATSHEET.md` | `docs/examples/_CHEATSHEET.md` |
| `scaffold/` | `lib/` + `prog/`, via `src_files()` |

Checks G and R skip a citation whose file does not resolve, so pointing them at
the live tree could not manufacture findings. Both report clean.

`doc_tier()` walks `docs/` recursively. Before that, four checks globbed
`docs/*.md`, which after the role sort was one file.

**Two checks now report VACUOUS instead of ok.** Their subject is gone, and an
empty loop returning no errors is a gate that passes forever:

- **H cheatsheet ops** verified the cheatsheet's refine operators against
  `refine.py`'s `_OPS`. That is the Python oracle, cut by author decision, so
  nothing verifies those operators now.
- **M duplicate-module ratchet** guarded the `scaffold/lib` to `TUI` symlink
  web against a link being replaced by a real file. The migration dissolved
  that web: 153 entries resolved to 147 real files.

First real run: 19 checks, 12 clean, 2 vacuous, 5 failing with 152 findings.
Those findings are the doc tier's actual state and have not been triaged. A
large share of check A and all of check O are the Python oracle's paths, which
are gone by the same decision that made H vacuous.
