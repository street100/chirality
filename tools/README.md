# tools/

One folder per tool. Migrated from the old tree's `bin/`.

The `metis-` prefix is dropped. A tool inside the chirality tree has no need to say
which language it belongs to, and LAYOUT's rule is to name the thing rather than
the mechanism.

| folder | from | state |
|---|---|---|
| `test/` | `scaffold/tests/run-native.sh` + its phase scripts | **runs**: `bin/chirality test`, 7 of 12 phases ported |
| `paren-audit/` | `bin/paren-audit.py` | **runs** unchanged. ⚑ A chirality replacement exists, `prog/paren-audit.prog`. Equivalence against this Python is **unverified**, so the Python is still on disk and is not retired or deletable yet |
| `xlat/` | **new here** | **runs**: the translation tier's gather and check. Pins an external source with its origin and hash, scans it for RFC 2119 obligations, indexes the carrier forms live in `lib/` with the lowering gaps beside them, and resolves every `ID:LINE "span"` citation in a translation artifact. Shell for one reason: `.planning/ZERO-PYTHON-SCOPE.md` forbids a fifteenth `.py`, and grep, sed and sha256sum cover the whole job. ⚑ Shell is no more chirality than Python is, so this owes the same route the rest of the tier owes. `pin` takes bytes and never fetches: raw egress is blocked here, so a source obtained through a summarizing fetch is pinned `transcribed` and every report says so |
| `syscall-map/` | `bin/syscall-map.py` | **runs**: referent column empty (Python oracle cut) |
| `ledger-lint/` | `bin/ledger-lint.py` | **runs** (re-measured 2026-09-08): **40 checks A to AN**. 38 live, 2 named VACUOUS because their subject is absent (H cheatsheet ops, M duplicate-module ratchet). AK reports author calls as Owed rather than failing, AL resolves a translation's external quotes into a pin, and AN reports the four lenses' `author:` backlog as Owed, which AK does not see because AK reads `records/author-calls.md` alone. A full run takes about 50 seconds. The 35-checks-A-to-AJ figure was measured 2026-09-05 and the 19-checks-A-to-S figure 2026-08-31 |
| `pack/` | `bin/metis-pack.py` | **runs**. Every pipeline bundle and the scaffolder. Grew the pre-mint tier 2026-09-05 (`--goal`, `--arc`, `<arc>/<id>`, `--mint`, `--revisit`) per `docs/decisions/decision-design-before-mint.md`. The Python OURS baseline is CUT, so an E# row naming a compiler `.py` gets a bundle saying the baseline is gone rather than a path |
| `lens/` | **new here**, 2026-09-05 | **runs**: the four lenses over what this repo knows about itself, problems, gaps, limits and unspoken territory. `check` is the schema gate, called by `ledger-lint` check AD; `author` prints what awaits a ruling; `overview` regenerates `docs/definitions/OVERVIEW.md`; `chain` is the census over goal to arc to element, six rungs, and writes its summary into that same overview; `trace` and `new` are the query and the scaffolder. `docs/decisions/decision-four-lenses.md` |
| `frontier/` | `bin/metis-frontier.py` | starts; needs the doc ecosystem |
| `capture/` | `bin/metis-capture.py` | starts; needs `docs/banks/` + `.planning/capture/` |
| `doc/` | `bin/metis-doc.py` | starts; needs `docs/banks/` + the CONFORMANCE-MAP |
| `scriba-edit-smoke/` | `bin/scriba-edit-smoke.py` | starts; needs a scriba ELF (blocked on the prapanca slice) |
| `scriba-run-smoke/` | `bin/scriba-run-smoke.py` | starts; needs a scriba launcher (same block). **Not ported**: no chirality replacement exists, though `.planning/ZERO-PYTHON-SCOPE.md` puts it in wave 0, portable today |
| `prose-lint/` | **new here** | the checks moved to chirality, `prog/prose-lint.prog`; `prose-lint.sh` is now the front end only (ranking, baseline, `--regress`, per-line output, code-skipping), and 3 checks print NOT-CHECKED pending E173 |

Each folder carries a `MIGRATION-NOTES.md` saying exactly what it needs and what
was deliberately not mapped. **No tool was repointed at a guess.** A linter aimed at
a guess passes because it is looking at nothing.

Slice 7 hoisted the doc tier, so the guesses are gone. `ledger-lint` went from 14 of
14 inputs missing, to 7, to **0**: the 7 path mismatches were repointed at measured
answers, and the two checks whose subject the migration deleted are named VACUOUS
instead of counted as clean. See `HANDOFF.md`.

`prose-lint/` is the one tool not carried from `bin/`. It began in shell, to avoid
adding to what route step 1 has to remove. The checks then moved again, into
`prog/prose-lint.prog`: route step 1 says *replace the tools with chirality
programs*, and shell is no more chirality than Python is (`tools/prose-lint/README.md`).
`prose-lint.sh` stays as the front end. Three of its checks print NOT-CHECKED until
E173 lands a matcher.

## Not migrated, by decision

The Rocq leg, the CompCert/DDC C-leg scripts, and the Python oracle suite
(`scaffold/tests/test_*.py`). External judgment is cut; three semantically distinct
judgment cores replace it. `bin/chirality` therefore has no `test-rocq` and no
`test-python`. `lib/evidence/ddc.chiral` is source and is already here. Only the
external-leg shell scripts are absent.

## Not tools

`bin/chirality-resolve.sh` is the **source provider the build sources**, and
`bin/chirality` is the CLI front door. Both stay in `bin/`.

Python compiles nothing here. The compiler is `bin/chirality-bin`.
