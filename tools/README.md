# tools/

One folder per tool. Migrated from the old tree's `bin/`.

The `metis-` prefix is dropped: a tool inside the chirality tree does not need to
say which language it belongs to, and LAYOUT's rule is to name the thing, not the
mechanism.

| folder | from | state |
|---|---|---|
| `test/` | `scaffold/tests/run-native.sh` + its phase scripts | **runs** — `bin/chirality test`, 7 of 12 phases ported |
| `paren-audit/` | `bin/paren-audit.py` | **runs** unchanged |
| `syscall-map/` | `bin/syscall-map.py` | **runs** — referent column empty (Python oracle cut) |
| `ledger-lint/` | `bin/ledger-lint.py` | refuses by name: the doc tier it lints does not exist here |
| `pack/` | `bin/metis-pack.py` | starts; needs `.planning/` + `examples/` + the Python baseline |
| `frontier/` | `bin/metis-frontier.py` | starts; needs the doc ecosystem |
| `capture/` | `bin/metis-capture.py` | starts; needs `docs/banks/` + `.planning/capture/` |
| `doc/` | `bin/metis-doc.py` | starts; needs `docs/banks/` + the CONFORMANCE-MAP |
| `scriba-edit-smoke/` | `bin/scriba-edit-smoke.py` | starts; needs a scriba ELF (blocked on the manas slice) |
| `scriba-run-smoke/` | `bin/scriba-run-smoke.py` | starts; needs a scriba launcher (same block) |

Each folder carries a `MIGRATION-NOTES.md` saying exactly what it needs and what
was deliberately not mapped. **No tool was repointed at a guess** — the doc tier's
shape here (`docs/{examples,definitions,elements}/`) is an open author decision, and
a linter aimed at a guess passes because it is looking at nothing.

## Not migrated, by decision

The Rocq leg, the CompCert/DDC C-leg scripts, and the Python oracle suite
(`scaffold/tests/test_*.py`). External judgment is cut; three semantically distinct
judgment cores replace it. `bin/chirality` therefore has no `test-rocq` and no
`test-python`. `lib/evidence/ddc.chiral` is source and is already here — only the
external-leg shell scripts are absent.

## Not tools

`bin/chirality-resolve.sh` is the **source provider the build sources**, and
`bin/chirality` is the CLI front door. Both stay in `bin/`.

Python compiles nothing here. The compiler is `bin/chirality-compile`.
