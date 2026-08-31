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
| `MAP.md` | check C |
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
