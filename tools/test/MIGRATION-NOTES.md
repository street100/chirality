# test — migration notes

`tools/test/` is the gating floor, ported from the old tree's
`scaffold/tests/run-native.sh` (12 phases) and the phase scripts beside it.
Entry point: `bin/chirality test` → `tools/test/run-tests.sh`.

## Ported — 7 of 12

| phase | source | here | assertions |
|---|---|---|---|
| 1 inline behavioral | `run-native.sh` inline | `run-tests.sh` inline | 6 |
| 2 the test-runner | `run-native.sh` inline | `run-tests.sh` inline | 6 checks, in-binary |
| 3 check CLI | `test-check-cli.sh` | `check-cli.sh` | 7 |
| 4 composition manifest | `test-profile-target.sh` | `profile-target.sh` | 31 |
| 5 syscall manifest enforced | `test-syscall-manifest.sh` | `syscall-manifest.sh` | 12 |
| 6 linear mint (E159) | `test-linear-mint.sh` | `linear-mint.sh` | 21 |
| 7 downstream roots compile | `run-native.sh` inline | `run-tests.sh` inline | 11 roots |

## New here — Phases 13 and 14

| phase | source | here | assertions |
|---|---|---|---|
| 13 typed diagnostics (E157) | old tree's `test-diag.sh` | `diag.sh` + `samples/e157_diag.prog` | 30 |
| 14 layout algebra (E158) | none — written here | `doc.sh` + `samples/e158_doc.prog` | 26 |

E157 landed in the old tree after the migration snapshot, so it has **no old-tree
phase number to inherit**. It is 13 rather than 8: 8–12 are names still owed, and
reusing one would have made an unported gate look ported. E158 takes **14** for
the same reason, and its registration line beside 13's is a *required* line, not
a courtesy — an unregistered `doc.sh` is a gate that never runs, which `doc.sh`
itself asserts as a row (G7c) so the registration cannot vanish silently.

Phase 14 grades **evidence survival**, never byte-identity. E157's nine goldens
pin `dg-msg` byte-for-byte and that constraint is E157's; `doc->str` must not
inherit it, so `doc.sh` carries no golden row over the plain-text exit and pins a
**sha256** of `diag.sh` and `samples/e157_diag.prog` to prove E158 did not move
E157's gate. (A `git diff --stat` row would report ok for the rest of time once
the E158 commits land, so it is deliberately not used.)

Two things changed in the port beyond the mechanical rewrites:

- **`tools/test/samples/`, not `prog/samples/`.** The fixture is a `.prog` (it
  defines an entry), but it is consumed by *this gate*, not by a shipped program.
  `prog/samples/`'s six fixtures are read **by path at runtime** by
  `prog/test-runner.prog`, which is shipped, so they must sit inside the shipped
  tree. This one must not. It is therefore also outside Phase 7's root sweep
  (`lib prog`), so E157's assertions are counted once, by E157's own phase.
- **G6's name census is shell, not Python.** The old `test-diag.sh` walked the
  tree in an inline `python3` heredoc. Here the names are read out of
  `lib/typing/diag.chiral` itself — so a new arm is censused without editing the
  script — and searched with `grep -R`, **not** `grep -r`, which does not follow
  symlinks and would let a skipped file read as a clean census.

`probe-main.metis` is in the old tree's E157 commit and is **not** ported: it is
`scaffold/tools/probe-main.metis`, a compiler-debug probe with zero rows in
`MIGRATION-MAP.tsv` and no counterpart here. Its one-line change
(`(trace m)` → `(trace (dg-msg m))`) has nothing to apply to; if the probe is ever
migrated it carries that line with it.

The port was mechanical: `bin/metis` → `bin/chirality`, `metis_blob*` →
`chirality_blob*`, `$REPO/scaffold/lib` → the `lib:prog` search path,
`bin/metisc`/`scaffold/build/B1` → `bin/chirality-bin`, `METISC_BIN` →
`CHIRALITY_COMPILE`, `.metis` → `.chiral`, and the import keys the fixtures use
rewritten to root-relative form (`(import "ports")` → `(import "ports/ports")`,
`"prelude"` → `"prelude/prelude"`, `"collections"` → `"prelude/collections"`,
`"string-utils"` → `"prelude/string"`, `"parse"` → `"surface/parse"`).

Phase 5's harness rebuilds the compiler from a *poisoned copy of its own blob*; its
blob line became `chirality_blob_file "lib:prog" prog/compiler.prog`, since the
entry now lives in `prog/compiler.prog` rather than a `compile-driver` module.

Phase 2 keeps the property the old tree fought for: **the rebuild is part of the
phase.** The runner is compiled from `prog/test-runner.prog` on every run and lands
in a scratch dir (`CHIRALITY_BUILD_DIR` overrides), never in a promoted location, so
a stale binary cannot report green.

## Not ported — 5 of 12, each with its reason

**Phase 8 — module datasheet (E161).** `test-module-kind.sh`, 808 lines. Every
fixture declares a module coordinate `(module <n> …)` and the check is that the
compiler *refuses* a coordinate contradicting what it derives. The coordinate names
are old-tree module keys; the new key is the root-relative path, so each fixture's
declared name has to be re-derived, not substituted. That is a rewrite of the
fixtures' subject matter, not a port.

**Phase 9 — sort adoption (E156).** Needs
`scaffold/tests/samples/{e151_string_stdlib,e152_list_sort,e156_dedup_adj}.metis`.
The fixtures tree (~204 files) is not migrated — a separate slice.

**Phase 10 — the external-compiler C leg (E166).** **DROPPED, not blocked.**
External judgment is cut by author decision; three semantically distinct judgment
cores replace it. `ddc-c-leg.sh` (540 L), the CompCert/gcc path, and the
`metis test-rocq` / `metis test-python` subcommands are all gone for the same
reason. `lib/evidence/ddc.chiral` stays — it is source, already migrated; it is only
the external-leg shell scripts that are not ported.

**Phase 11 — resolver + build state (E155).** Two halves, both stale here.
(a) The basename-collision assertions test a class the new tree makes
*unreachable*: the key is the path, so `ports/proc` and `proc` cannot collide. The
live collision class is now `module extension collision` (`x.chiral` beside
`x.port`), which is a different assertion, not a renamed one.
(b) The negative control re-resolves the compiler blob and `cmp`s it against a
committed `scaffold/build/blob.metis`. This tree commits no blob artifact, so there
is nothing to compare against. The equivalent guarantee here is the fixpoint
(`bin/chirality-bin < blob > C1; ./C1 < blob > C2; cmp C1 C2`), which is run by
hand and is not yet a phase.

**Phase 12 — the test floor (E168/E170).** `test-e168-floor.sh`, 677 lines. Needs
`scaffold/tests/samples/e168_*` and `e170_*` fixtures, and its mutant machinery
copies `scaffold/lib` wholesale and mutates a named file inside it
(`kernel.metis`, `qtt.metis`, …) by exact line text. Both the fixtures and the
line-exact mutation targets are old-tree; the fixtures tree is not migrated.

## Phase 7's known-fail list

9 roots are known-failing and are listed by name in `run-tests.sh`. A known-failing
root that starts *passing* is reported (`NEWPASS`) and fails the gate, so the list
cannot rot silently.

- `scriba-main.prog`, `scriba-manas-test.prog`, `scriba-runview-test.prog`,
  `scriba-runview-stream-test.prog`, `scriba-test-b1.prog`, `flow-view-test.prog`
  — import `manas/core/*`, `manas/chatter/*`, `manas/pipeline/*`, `manas/profile/*`;
  only `prog/manas/{backend,coordinator,fsm,manas}` were migrated. Separate slice.
- `t5_utf8.prog`, `t5_vt_parser.prog`, `t6_apc_roundtrip.prog` — pre-existing TUI
  breakage, carried over verbatim from the old tree's own KNOWN_FAIL list.

## The six samples under `prog/samples/`

Phase 2's manifest names six fixtures. They were **not** in the migrated tree, so
Phase 2 could not have run at all. Six one-line programs were created at
`prog/samples/{exit42,exit7,multi-def,boxed-a,boxed-b,enum-tag}.prog` (byte-identical
bodies to `scaffold/samples/*.metis`) and `prog/test-runner.prog`'s manifest was
repointed at them.

⚑ **The destination is a judgment call and it is flagged.** `MIGRATION-MAP.tsv` has
**zero** rows for `scaffold/samples/`, so the samples tree has no settled home.
`prog/samples/` follows LAYOUT's rule — each file defines an entry (`main`, which is
what `run-src` compiles), so it is a `.prog` — and the old map's precedent of putting
fixtures under the program they exercise. If the samples slice picks a different
home, these six move with it and the manifest follows.
