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

## New here — Phases 13, 14, 15, 16, 17, 18 and 24

| phase | source | here | assertions |
|---|---|---|---|
| 13 typed diagnostics (E157) | old tree's `test-diag.sh` | `diag.sh` + `samples/e157_diag.prog` | 30 |
| 14 layout algebra (E158) | none — written here | `doc.sh` + `samples/e158_doc.prog` | 26 |
| 15 horizontal composition (E174) | none — written here | `row.sh` + `samples/e174_row.prog` | 41 |
| 16 ambient face restore (E175) | none — written here | `face.sh` + `samples/e175_face.prog` | 38 |
| 17 `doc->rendering` (E158 c4) | none — written here | `render-doc.sh` + `samples/e158_render.prog` | 19 |
| 18 the term printer (E181) | none — written here | `pretty.sh` + `samples/e181_pretty.prog` | 61 |
| 24 the arity evidence (E182) | none — written here | `arity.sh` + `samples/e182_arity.prog` | 13 |

E157 landed in the old tree after the migration snapshot, so it has **no old-tree
phase number to inherit**. It is 13 rather than 8: 8–12 are names still owed, and
reusing one would have made an unported gate look ported. E158 takes **14** for
the same reason, and its registration line beside 13's is a *required* line, not
a courtesy — an unregistered `doc.sh` is a gate that never runs, which `doc.sh`
itself asserts as a row (G7c) so the registration cannot vanish silently.

**Phase 18** is E181's, and it is 18 for the reason 17 was 17. Two things about
it are worth writing down rather than rediscovering. First, **every row reads
emitted bytes** — the fixture prints and asserts nothing, and it always exits 0,
because the toothless shape for a printer gate is a row that walks the produced
`Doc` and checks it has the constructors you expected: the same information
twice, and green under any mutant that changes what those constructors *say*.
Second, it carries **the one row in this suite that could not pass before its
element landed**. `typing/pretty.chiral` was unimportable twice over — its own
five-constructor `Term` gave `load: data redeclared: Term` beside
`surface/syntax`, and its hand-rolled `nlen` gave `duplicate label …: nlen`
beside `lowering/tal/erase` — and both colliding modules are inside
`prog/compiler.prog`'s own blob, so nothing in the tree ever compiled the file.
Phase 7 sweeps *roots*, and no root reached it. The fixture co-imports all three
on purpose, which is what makes G9 a row and not a claim.

⚑ The printer also **moved**, `typing/pretty` → `surface/pretty`. Module keys are
root-relative, so those are different modules and the move is a rename with
consumers, not a tidy-up.

**Phase 15 (E174)** takes 15 for the same reason, and its gate is the first here
that reads the *emitted byte stream*: `doc.sh`'s `build_run` discards stdout, and
E174's whole invariant is that `rnd-cols` and `render-to-ansi` agree, which only
the bytes can show. `row.sh` adds a **screen reducer** (`od` + `awk`, zero
Python) that turns ANSI output into a cell map — one `row col bytes` line per
painted cell, SGR ignored because it paints none — and every layout row is an
assertion about that map. It pins E158's pair by sha256 the way `doc.sh` pins
E157's, so each element's gate is held by the next one.

⚑ The reducer advances **one column per codepoint**, the same unit `str-cols`
counts in. So Phase 15 grades agreement between the width function and the
emitter, **not** agreement with a real terminal: CJK is two cells and combining
marks are none. That is **E177**, and E177's landing must move `str-cols` and
this reducer together.

**Phase 17 (E158 commit 4)** takes 17 for the reason 16 took 16, and it is a
*new* phase rather than two rows added to `doc.sh` because the four existing
gate scripts must stay byte-unchanged — `doc.sh` carries sha256 pins over
`diag.sh`, and `render-doc.sh` now carries pins over all four. Its shape is the
finding that produced it: the cheap `doc->rendering` re-wraps every emitted
*leaf* in its whole tag stack, which is screen-correct and was **measured** to
produce a cell map byte-for-byte identical on the pre-E175 emitter — so a gate
over that design would have passed on the broken emitter and reported E175 as an
unused dependency. Building the face *tree* instead (one `r-face` per `d-tag`
occurrence per line) is what makes M4 (E175 reverted) convict. Every mutant here
pins the **full fifteen-row verdict line**, not merely "a row went red", so a
mutant that reddens a row it was not paired with fails the same assertion as one
that reddens nothing. `render-doc.sh` copies `face.sh`'s SGR reducer verbatim —
there is no shell-library tier under `tools/test/` and sourcing a sibling gate
would *run* it — and pins the copy byte-identical rather than asking a reader to
believe it.

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

**One** root is known-failing and is listed by name in `run-tests.sh`. A
known-failing root that starts *passing* is reported (`NEWPASS`) and fails the
gate, so the list cannot rot silently.

- `t5_utf8.prog` — an unported old-tree root carrying **zero** `(import …)` lines,
  so `Unit` never resolves. A migration gap, not a codec one, and no `enc` fix
  can move it.

Two departures, both already recorded beside the list in `run-tests.sh`:

- the six `scriba-*` / `flow-view-test` roots left when the manas subtree landed
  (slice 4). They were never broken — they imported twelve manas keys that
  resolved to nothing, and nothing in them was edited to fix it.
- `t5_vt_parser.prog` and `t6_apc_roundtrip.prog` **left in E174.** The old note
  called all three remaining entries "pre-existing TUI breakage"; two of them
  were nothing of the kind. They were `load: non-exhaustive case` out of
  `lib/protocol/apc.chiral`'s `enc`, left six-of-eight when `r-lines` and
  `r-face` joined the `Rendering` sum — `t5_vt_parser` reaching it through
  `vt-parser.chiral`'s `(import "protocol/apc")`. E174 repaired the codec on both
  sides and both roots now run to their own exit-42 sentinel. **The list moved in
  the same commit as the fix**, because Phase 7 goes red *on success*: a
  known-failing root that starts compiling is a `NEWPASS` and a gate failure.

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
