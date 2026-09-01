# pack — migration notes

Carried as-is from `bin/metis-pack.py` (805 L), renamed `pack` (a tool inside the
chirality tree does not need to say "metis"). `ROOT` moved three levels up.

`pack` starts and prints usage:

```
usage: metis-pack.py E<#> [slug] [--no-index]
```

Everything past the usage line needs the **element pipeline**, which is not in this
tree:

| needs | for |
|---|---|
| `docs/elements/catalog.md` | the catalog row that is the pack's first input |
| `docs/elements/ledger.md`, `.planning/USER-LAYER-GAP.md`, `.planning/SCRIBA-PRIMITIVE-CHECKLIST.md` | the element's ledger rows |
| `records/conformance-map.md` | `--audit` / `--spec` build-state |
| `docs/elements/specs/` | `--spec` output dir + `--mark audited` |
| `examples/`, `examples/INDEX.md`, `examples/_CHEATSHEET.md` | the corpus it scaffolds into, and the idiom reference it prints |
| `scaffold/metis/*.py` | the **OURS Python baseline** it slices around named symbols |
| `scaffold/lib`, `scaffold/tests/test_*.py` | structural outlines + the live test count |

`scaffold/metis/` is gone **by decision** (the Python oracle is cut), so the pack's
"conventional-language baseline" half has no source at all here — not a path to
repoint, a missing input. The `.planning/` and `examples/` halves have no settled
destination in this tree (`docs/elements/` and `docs/examples/` exist and are empty;
whether they are the same thing is an author call).

Not repointed. A pack that scaffolds an example from an empty catalog is a blueprint
for nothing.
