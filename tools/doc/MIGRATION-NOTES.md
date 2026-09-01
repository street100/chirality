# doc — migration notes

Carried as-is from `bin/metis-doc.py` (313 L), renamed `doc`. `ROOT` moved three
levels up. It starts and prints usage:

```
usage: metis-doc.py audit <doc> | new-bank <name> [E# …]
```

`audit <node>` prints one claim-beside-authority bundle; `new-bank` scaffolds a
schema-conformant bank. Both need the tier they operate on:

| needs | for |
|---|---|
| `docs/banks/` (+ `docs/banks/INDEX.md`) | the audited node and `new-bank`'s output dir |
| `records/conformance-map.md` | the build-state authority every claim is checked against |
| `examples/INDEX.md` | pipeline rows for a named element |
| `docs/*.md` | linked-note heads |
| `bin/ledger-lint.py` | the mechanical findings it folds in — now `tools/ledger-lint/ledger-lint.py`; the reference is a message string, not an import |

It also reads `scaffold/lib` and `scaffold/metis` for the code lines behind a
citation. The `scaffold/metis` half is gone by decision (Python oracle cut); the
`scaffold/lib` half maps cleanly onto `lib/`, but repointing only that half would
produce an audit that silently checks half its citations — worse than one that
refuses. Not repointed.
