

### PRB-01 the `check` CLI gate never exercises an emit-stage refusal

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    tools/test/check-cli.sh
- claim:    the header of the gate says the cases "pin that it ACCEPTS well-typed source and REFUSES ill-typed source", and that a checker which only ever says OK is not a checker.
- measured: RE-MEASURED 2026-09-06: unchanged, and the residue the 2026-09-06 partial re-run left is settled. `bash tools/test/check-cli.sh` reads **12 passed, 0 failed**, exit 0: the 7 assertions this row counted plus 5 mutant rows added 2026-09-05, so the CASE list is still the same 7 and the gate grew only by falsifiers. Read case by case, the 4 negatives are `linear cap used twice` and `linear cap dropped` (both wanting `linear binder usage mismatch`), `arity / type mismatch` (wanting `type mismatch`) and `unknown name`. All three messages are produced in `lib/typing/diag.chiral`, at `:364`, `:359` and `:419-423`, which is the typing front end. **Zero of the 4 reaches an emit-stage refusal**, so the claim holds in full and the row stays OPEN.
- evidence: re-runnable: `bash tools/test/check-cli.sh` reads 12 passed, 0 failed and exits 0; its 4 negative cases are `tools/test/check-cli.sh:68-79`. `grep -n 'linear binder usage mismatch\|"type mismatch\|"unknown name' lib/typing/diag.chiral` puts all three refusal messages in the typing diagnostics. `tools/test/check-cli.sh`, `lib/typing/diag.chiral`
- checked:  2026-09-06
- owner:    none
- from:     BA-04

### PRB-02 three failure classes collapse into one exit code

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/compile-all.chiral
- claim:    `bin/chirality check FILE` is documented as "type-check (compile, discard the ELF)".
- measured: RE-MEASURED 2026-09-06: unchanged. `lib/lowering/compile-all.chiral` still maps all three failure classes onto one constructor: `fr-err` at `:21`, `br-err` at `:24` and `elf-err` at `:42`, each becoming `ca-err`. `prog/compiler.prog` maps every `ca-err` to exit 1, so a parse failure, a lowering failure and an emit failure are indistinguishable to a caller reading the exit code.
- evidence: re-runnable: `grep -n 'fr-err\|br-err\|elf-err' lib/lowering/compile-all.chiral` returns `:21`, `:24`, `:42`, each mapping to `ca-err`. `lib/lowering/compile-all.chiral`
- checked:  2026-09-06
- owner:    none
- from:     BA-05

### PRB-03 `cmd_check` greps blob source text for the entry def

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    bin/chirality-resolve.sh
- claim:    `bin/chirality-resolve.sh` documents this exact bug class as fixed for imports: a bare grep makes a doc comment that merely mentions an import form into a dependency, and the authoritative provider parses real s-expressions instead. Its own header comment is the proof.
- measured: `cmd_check` does `grep -q '(def compile-main' "$blob"` before appending a trivial entry. Same bug class, unfixed. LATENT rather than live: `grep -rn '(def compile-main' lib prog tools bin` returns 20 hits and every one is a real top-level definition at column 0. No file in the tree currently carries the string inside a comment or a string literal. A comment mentioning the form would suppress the appended entry and make the check fail on a file that has no entry.
- evidence: `bin/chirality:171-172`, `bin/chirality-resolve.sh:94-98`
- checked:  2026-09-01
- owner:    none
- from:     BA-07

### PRB-04 testing-floors still lists the cut external floors

- state:    FIXED
- author:   unreviewed
- note:     none
- level:    doc
- about:    docs/definitions/testing-floors.md
- claim:    `docs/definitions/testing-floors.md` lists a rocq floor invoked as `chirality test-rocq`, GATING on well-formedness, and a python oracle floor invoked as `chirality test-python`, ADVISORY.
- measured: RE-MEASURED 2026-09-06: **the claim no longer holds and the row closes.** `docs/definitions/testing-floors.md` was rewritten against the live tree on 2026-09-04 at `53c3d3a`. Both floor rows now read `CUT 2026-09-01` in the Command column with `none` in the Gates? column (`:70-71`), and a banner at `:10-20` states that `rocq/`, `scaffold/` and every `chirality/*.py` are absent from the tree and that `chirality test-native`, `chirality test-rocq`, `chirality test-python` and `chirality verify` name nothing. `test-rocq` and `test-python` now occur exactly once each in the whole file, inside that banner. `bin/chirality:210-219` dispatches `compile`, `run`, `check`, `test` and `help` and nothing else, so the note and the dispatch agree. The doctrine the row rested on is untouched: a subcommand dispatching to a floor this tree lacks is a gate that cannot fail (`docs/definitions/working-discipline.md`).
- evidence: re-runnable: `grep -c 'test-rocq' docs/definitions/testing-floors.md` returns 1 and `grep -c 'test-python'` returns 1, both hits being the banner that says the command names nothing. `grep -c 'CUT 2026-09-01' docs/definitions/testing-floors.md` returns 2, one per cut floor row. `docs/definitions/testing-floors.md:10-20`, `:70-71`, `bin/chirality:210-219`
- checked:  2026-09-06
- owner:    none
- from:     BA-08

### PRB-05 the fixture count is off by 44

- state:    FIXED
- author:   unreviewed
- note:     none
- level:    doc
- about:    docs/decisions/decision-scope.md
- claim:    `docs/decisions/decision-scope.md`'s state table says `tools/test/samples/` holds 98 files.
- measured: RE-MEASURED 2026-09-06: **the document this row names never carried the figure, and no live document carries a fixture count now, so the row closes.** `docs/decisions/decision-scope.md` is 84 lines and holds no state table: `grep -c '98'` returns **0** and `grep -c 'samples'` returns **0**, and both returned 0 at the note's first commit too. The 98 came from the dissolved root `HANDOFF.md`, whose state table read `| fixtures | tools/test/samples/ 98 files |` from `ca8b3e7` (2026-08-31). `1c2dd3d` (2026-09-01) dissolved that file and carried only the SCOPE sentence and its three consequences into `decision-scope.md`; the fixtures row went with the rest of the state table and was dropped. The citation `decision-scope.md:57` therefore named the wrong home the day it was written. The count moved as well: `ls tools/test/samples/ | wc -l` reads **62** today, 61 `.prog` files plus the `_wip/` directory, against the **54** this row measured on 2026-09-01. The C-leg drop at `d0c5dd5` stands as history. Nothing in the tree is off by 44. ⚑ One trace survives in a document this row may not edit: `docs/arcs/baseline-alignment-arc.md:127-129` still lists `BA-09` as next work, still attributes the 98 to `decision-scope.md`, and still gives the live count as 54. Reported and left standing.
- evidence: re-runnable: `grep -c '98' docs/decisions/decision-scope.md` and `grep -c 'samples' docs/decisions/decision-scope.md` both return 0. `ls tools/test/samples/ | wc -l` returns 62. `git show ca8b3e7 | grep 'fixtures'` shows the state-table row that held the 98 and `git show 1c2dd3d --stat` shows the file that held it leaving the tree. `docs/decisions/decision-scope.md`, `docs/arcs/baseline-alignment-arc.md:127-129`, commits `ca8b3e7`, `1c2dd3d`, `d0c5dd5`
- checked:  2026-09-06
- owner:    none
- from:     BA-09

### PRB-06 `.profile` is a documented kind with no instance

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    MAP.md
- claim:    `MAP.md` lists `.profile` as one of five extensions, "a named frozen port set", and excludes it from import probing because "a profile names a module set, which the build consumes and nothing imports". `bin/chirality-resolve.sh` repeats the reason: "the BUILD consumes it".
- measured: RE-MEASURED 2026-09-05, unchanged: `find . -name '*.profile'` outside `.git` returns nothing. Zero files. Grepping `bin/` and `tools/test/run-tests.sh` for `.profile` returns three hits and all three are the prose that excludes it from probing. Nothing in the build reads one. The `(profile ...)` form that is actually used is a top-level clause inside a `.chiral` file, parsed at `lib/surface/parse.chiral:717`, which is a different thing from the extension.
- evidence: `MAP.md:12`, `MAP.md:23`, `bin/chirality-resolve.sh:51`, `lib/surface/parse.chiral:717`
- checked:  2026-09-05
- owner:    none
- from:     BA-10

### PRB-07 "The two binaries" names one binary and one shell script

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    doc
- about:    MAP.md
- claim:    `MAP.md` has a section titled "The two binaries" naming `bin/chirality` as the CLI front door and `bin/chirality-bin` as the compiler.
- measured: `git ls-files bin/` returns three files. `bin/chirality` is a bash script, `bin/chirality-resolve.sh` is a bash library, and `bin/chirality-bin` is the one committed binary. RE-MEASURED 2026-09-05: **12** top-level `.prog` roots under `prog/` and **102** `.prog` files in total. ⚑ The 6 and the 96 this row carried were taken 2026-09-01 and both grew; the shape it names did not change. `bin/chirality` has no `build` subcommand: the build-new, test, promote rule lives only as prose in CLAUDE.md.
- evidence: `MAP.md:89-92`, `bin/chirality:210-219`
- checked:  2026-09-05
- owner:    none
- from:     BA-11

### PRB-08 four of six top-level roots have the identical 58-module closure

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    prog/paren-audit.prog
- claim:    `prog/` is "what chirality ships, as distinct from what it is".
- measured: RE-MEASURED 2026-09-06 and **the shape has changed: the four are no longer identical.** Counting `^(end-module "` markers per root: `test-runner` 65, `prose-lint` 63, and `wield`, `paren-audit` and `compiler` at 62 each. Twelve roots build in total, and the small ones are far below: `optimizer-census` 37, the three E185-E188 sweeps 27, `resolve` 15, `e196-encoding-sweep` 5, `e197-recording-sweep` 3. This row recorded four of six at an identical 58. **Three still coincide at 62**, so the concern holds in weakened form: a tool that ships the whole compiler closure misrepresents the architecture, and `binary-split/B1` owns it.
- evidence: re-runnable: `. bin/chirality-resolve.sh; for r in prog/*.prog; do chirality_blob_file "lib:prog" $r | grep -c '^(end-module "'; done`. `docs/arcs/binary-split-arc.md`
- checked:  2026-09-06
- owner:    none
- from:     BA-16

### PRB-09 the reader collision was routed around locally

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/module/resolve.chiral
- claim:    a fix in one module is the tree's fix.
- measured: RE-MEASURED 2026-09-06: unchanged. `lib/module/resolve.chiral` still carries `slurp-fd` (4 occurrences) and `lib/lowering/compile-all.chiral` still defines its own `read-fd-all` (1). The collision was routed around by a local rename rather than by giving the reader one home, which is `binary-split/B1`'s subject: a text tool cannot import the reader without importing the compiler.
- evidence: re-runnable: `grep -c slurp-fd lib/module/resolve.chiral` returns 4; `grep -c read-fd-all lib/lowering/compile-all.chiral` returns 1. `docs/arcs/binary-split-arc.md` row `B1`
- checked:  2026-09-06
- owner:    none
- from:     BA-17

### PRB-10 a citation inside a source comment is read by no gate

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/ports/ports.chiral
- claim:    checks G and R are the tree's line-citation gates.
- measured: RE-MEASURED 2026-09-06: still true and the count grew. `lib/` and `prog/` comments carry **75** line-numbered citations across **35** files, against the 59 across 34 this row recorded. Checks G and R both walk `docs/**/*.md` and both require the citation inside a backtick code span, so not one of the 75 is read by any gate.
- evidence: re-runnable: `grep -rhoE '[a-z0-9_/-]+\.(chiral|prog):[0-9]+' --include='*.chiral' --include='*.prog' lib/ prog/ | wc -l` returns 75. `tools/ledger-lint/ledger-lint.py:379` (check G), `:443` (check R)
- checked:  2026-09-06
- owner:    none
- from:     BA-19

### PRB-11 294 doc citations name a path that does not exist

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    tools/ledger-lint/ledger-lint.py
- claim:    the migration is complete and the map records where each original went.
- measured: **RE-MEASURED 2026-09-06 with a command.** `ledger-lint --census` reports **4,653 line-numbered spans and 3,061 resolving to a file on disk**, so **1,592 do not resolve**. This row read 862 spans and 294 unresolvable. The ratio moved from about a third to about a third, and both absolute figures grew with the corpus. The class is unchanged: pre-migration paths (`scaffold/lib/...`, `chirality/...`) and basenames whose file was deleted, which G and R skip by design so the gate stays silent on them.
- evidence: re-runnable: `python3 tools/ledger-lint/ledger-lint.py --census`. `tools/ledger-lint/ledger-lint.py:369` (`_find_src`), `.planning/MIGRATION-MAP.tsv`
- checked:  2026-09-06
- owner:    none
- from:     BA-20

### PRB-12 34 citations under `docs/examples/` are stale, and repointing them is a policy call

- state:    FIXED
- author:   unreviewed
- note:     none
- level:    source
- about:    tools/ledger-lint/ledger-lint.py
- claim:    worked examples are the design rationale for an element and are kept as written.
- measured: **FIXED, measured 2026-09-06.** `ledger-lint --only G,R` reports **0 and 0**. This row recorded 17 and 17, every one under `docs/examples/`, and asked whether repointing them was a policy call. They are gone, so the policy question is moot: nothing under `docs/examples/` fails either check today.
- evidence: re-runnable: `python3 tools/ledger-lint/ledger-lint.py --only G,R` reports 0 and 0. `docs/decisions/decision-scope.md:194`
- checked:  2026-09-06
- owner:    none
- from:     BA-22

### PRB-13 check A reads a module key as a filesystem path

- state:    FIXED
- author:   unreviewed
- note:     none
- level:    source
- about:    tools/ledger-lint/ledger-lint.py
- claim:    check A is "ledger evidence paths exist".
- measured: **FIXED, measured 2026-09-06.** `ledger-lint --only A` reports **0 issues**. This row recorded 5, every one a module key rather than a path: `surface/pretty`, `typing/pretty`, `surface/parse`, `typing/`. `is_pathish` accepted any token containing a slash and `resolve` then tested `ROOT/surface/pretty`, which is nowhere. The check no longer reads a module key as a filesystem path.
- evidence: re-runnable: `python3 tools/ledger-lint/ledger-lint.py --only A` reports 0. `tools/ledger-lint/ledger-lint.py:64` (`is_pathish`), `docs/definitions/status-ledger.md:66`, `:68`
- checked:  2026-09-06
- owner:    none
- from:     BA-23

### PRB-14 a pure `->` function performs an effect and is accepted

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/typing/effects.chiral
- claim:    `PRINCIPLES.md:62` "One atom with no exemptions" and `:89` "the port-check is the type-check". The membrane separates pure `->` from effectful `=>`.
- measured: `(declare pure-syscall (-> I64 Unit))` whose body calls `put` (declared `(extern put (=> Str Unit))` in `lib/ports/stdio.port:11`) passes `chirality check` and writes to stdout when run. A three-deep all-`->` chain does the same. What the arrow does enforce is nominal type identity: passing an `=>` value where `->` is demanded is `load: type mismatch`. So the arrow is a type tag, not a membrane. `typing/effects.chiral` holds three refusing rules; its two importers are both dead through `lib/module/sig-driver.chiral`, which has zero importers, and `typing/effects` is not in the 58-module compiler closure. README, `status-ledger` and `docs/banks/effect-and-alarm.md` disclose this accurately; `PRINCIPLES.md` does not. ⚑ Re-measured 2026-09-04: the closure is 60 modules, grown by `typing/totality` and `typing/totality-check`, and `typing/effects` stays outside it. `grep -rn 'module/sig-driver' lib/ prog/` still returns no import, so the two dead importers are dead by the same route. The row is unchanged apart from the count.
- evidence: `lib/typing/effects.chiral`, `lib/module/sig-driver.chiral`, `lib/ports/stdio.port:11`, `PRINCIPLES.md:62`, `:89`
- checked:  2026-09-04
- owner:    none
- from:     BA-24

### PRB-15 the TAL floor check is unreachable from the compile path

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/tal/check.chiral
- claim:    the tree lowers through typed assembly before machine code.
- measured: RE-MEASURED 2026-09-06: still true. `ck-prog` and `ck-block` appear only inside `lib/lowering/tal/check.chiral` itself, 3 occurrences there and zero anywhere else under `lib/`. The TAL IR is on the compile path, `compile-emit` importing `lowering/tal/reify` and `lowering/x64/emit`, and the check over that IR is reached by nothing. ⚑ `check.chiral` has since ENTERED the compiler closure (PRB-70), so the module is compiled in while its entry point stays uncalled: the SEEDED rung exactly.
- evidence: re-runnable: `grep -rn '(ck-prog\|(ck-block' --include='*.chiral' lib/` returns hits only in `lowering/tal/check.chiral`. `enforcement/N8`
- checked:  2026-09-06
- owner:    none
- from:     BA-26

### PRB-16 strict positivity accepts a nullary mutual cycle

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/surface/data.chiral
- claim:    strict positivity is enforced; the row reads `Built - ENFORCED`.
- measured: two mutually-referencing nullary datatypes are accepted, compile, and diverge at run time. The variance walk at `lib/surface/data.chiral:270`, `:284` recurses into a type constructor's arguments only, and a nullary type constructor has none, so the negative occurrence is never visited. This is a false ENFORCED row rather than a stale one: the check runs and returns the wrong answer.
- evidence: `lib/surface/data.chiral:247-294`, `:270`, `:284`
- checked:  2026-09-01
- owner:    E07
- from:     BA-27

### PRB-17 refinement bounds wrap at the I64 extremes

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/typing/refine.chiral
- claim:    a refinement that cannot be inhabited is refused.
- measured: **RE-RUN 2026-09-06 against a fixpoint binary and CONFIRMED exactly.** `(def bad (refine I64 (> 9223372036854775807)) 0)` passes `chirality check` at exit 0. The same file at `9223372036854775806` and at `10` both fail with `load: cannot prove refinement`. So the bound wraps at the I64 maximum: the one value that should be impossible to satisfy is the one the checker accepts.
- evidence: re-runnable: `printf '(def bad (refine I64 (> 9223372036854775807)) 0)' > /tmp/t.chiral && ORIG_DIR=/tmp bin/chirality check /tmp/t.chiral` exits 0; the same at `...806` exits 1. `lib/typing/kernel.chiral`, `lib/typing/refine.chiral`
- checked:  2026-09-06
- owner:    E09
- from:     BA-28

### PRB-18 profile requirements are not checked against providers

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    doc
- about:    docs/banks/profile.md
- claim:    a profile is a frozen conformance contract; `MAP.md` sorts `.profile` as a kind and `docs/banks/profile.md` describes requirement checking.
- measured: RE-RUN 2026-09-05 against `bin/chirality-bin` at its fixpoint (C1 == C2 == the tracked binary, 1,241,464 bytes). **Four cases, all exit 0.** A file holding only `(target Svc (require run (-> I64 I64)))` with no `run` anywhere: OK. With `run` at the declared type: OK. With `run` at `(-> I64 I64 I64)`, an arity mismatch: OK. With `run` as a bare `I64`: OK. So the requirement is checked against nothing at all, which is stronger than the original reading. It emits too: the same file plus `(def compile-main (-> I64 I64) (lam (n) 42))` compiles to a 33,144-byte ELF that runs and exits 42.
- evidence: re-runnable: `printf '(target Svc (require run (-> I64 I64)))
(def run I64 7)' > /tmp/t.chiral && ORIG_DIR=/tmp bin/chirality check /tmp/t.chiral` exits 0. `docs/banks/profile.md`, `MAP.md:5`, `tools/test/profile-target.sh` (phase 4, which tests parsing and not conformance)
- checked:  2026-09-05
- owner:    none
- from:     BA-29

### PRB-19 the file kind is never checked

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    MAP.md
- claim:    `MAP.md:5` "the resolver checks it" and `:37-40` the kind is "checked by the loader". The extension is the kind.
- measured: RE-RUN 2026-09-05 against the fixpoint binary. **Both hold.** A `.port` file carrying `(porttype Cap)`, an `extern`, and `(def illegal-in-a-port (-> I64 I64) (lam (n) n))` passes `chirality check` at exit 0, against `MAP.md:12` which fixes a `.port` as "declarations only, zero lambdas". A `.manifest` whose defs are a lambda and a call passes check, compiles, and the ELF runs at exit 7, against `MAP.md:14` and `:35-40` which fix a manifest as every `def` body a literal value with no `lam` and no computation. Neither the resolver nor the loader implements a kind check.
- evidence: re-runnable: `printf '(def computed (-> I64 I64) (lam (n) n))
(def compile-main (-> I64 I64) (lam (n) (computed 7)))' > /tmp/t.manifest && ORIG_DIR=/tmp bin/chirality compile /tmp/t.manifest && /tmp/t` exits 7. `MAP.md:5`, `:12`, `:35-40`, `bin/chirality-resolve.sh`, `lib/module/loader.chiral`
- checked:  2026-09-05
- owner:    none
- from:     BA-30

### PRB-20 a bank refutes a real gap with a command that does not exist

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    doc
- about:    docs/banks/profile.md
- claim:    `docs/banks/profile.md:246` cites `chirality verify` to argue that the profile conformance gap is already covered.
- measured: `bin/chirality` offers `compile`, `run`, `check`, `test`, `help`. There is no `verify`. It is cited in 14 places, four of them under `docs/banks/`. The banks are the repo's mandated pre-flight read: CLAUDE.md requires reading a feature's bank before naming a gap, because naming a phantom is the cardinal error here. This row is that rule inverted, a phantom command used to dismiss a gap that BA-29 shows is real. `docs/definitions/testing-floors.md` is dated 2026-09-01 and lists `chirality test-native` and `chirality test-rocq` as GATING floors; neither exists and there is no `rocq/` directory. Overlaps BA-08, which records the floors table; this row is about the bank.
- evidence: `docs/banks/profile.md:246`, `bin/chirality`, `docs/definitions/testing-floors.md`
- checked:  2026-09-01
- owner:    none
- from:     BA-31

### PRB-21 23 reject fixtures are skipped rather than asserted

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    tools/test/run-tests.sh
- claim:    the suite reports 303 assertions, 0 failed, and the `*_reject_*` fixtures exist to prove the compiler refuses what it should refuse.
- measured: RE-MEASURED 2026-09-06: still true, and the citation moved. `tools/test/run-tests.sh:179` reads `case "$rb" in *_reject_*) r_skip=$((r_skip+1)); continue ;; esac`, so phase 7 counts every reject root as skipped instead of asserting that it fails. The line was `:174` when this row was written.
- evidence: re-runnable: `grep -n '_reject_' tools/test/run-tests.sh` returns the skip at `:179`
- checked:  2026-09-06
- owner:    none
- from:     BA-32

### PRB-22 33 of 50 port crossings take no capability

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    doc
- about:    records/baseline-alignment.md
- claim:    every crossing is capability-mediated.
- measured: 33 of the 50 `extern` declarations under `lib/ports/` take no capability argument. `write-fd 1 <bytes>` writes to stdout while holding nothing. `mmap`, `mprotect`, `signal`, `socketpair` and `open-rw` are in the same list. The ports floor is a naming and routing boundary, which BA-12 records from the byte-cost side; this row is the authority side.
- evidence: `lib/ports/*.port`
- checked:  2026-09-01
- owner:    none
- from:     BA-33

### PRB-23 `Clock` and `Timer` are uninhabited

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/runtime/supervisor.chiral
- claim:    `lib/ports/clock.port` types a clock discipline.
- measured: every extern in the port consumes a `Clock` or `Timer` and none produces one, and the port types have no constructor, so no program can obtain either. `lib/runtime/supervisor.chiral` is uncallable for the same reason. The discipline is vacuously satisfied: it cannot be violated because it cannot be used.
- evidence: `lib/ports/clock.port`, `lib/runtime/supervisor.chiral`
- checked:  2026-09-01
- owner:    none
- from:     BA-34

### PRB-24 `str-sub` reads past the end of its string and reports the read length

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/prelude/prelude.chiral
- claim:    indexing is bounds-checked. `lib/prelude/string.chiral:14` asserts in a comment that "str-sub clamps, so a too-long prefix is just false", and `starts-with?` at `:17` is written against that clamp.
- measured: `str-sub : (-> Str I64 I64 Str)` is `(s start end)`, half-open, and does not clamp. `(str-len (str-sub "abc" 0 99))` returns `99`: a three-character source yields a ninety-nine-character result, so the primitive reads past the end of the buffer and reports the out-of-range length as the string's length. The comment at `:14` is false and `starts-with?` rests on it. `.planning/FINDING-str-sub-range-2026-08-31.md:12` additionally records `(str-len (str-sub "abc" 2 1))` as SIGSEGV exit 139; that half did NOT reproduce on the current `bin/chirality-bin` (exit 0), so either the finding predates a change or the crash needs a condition the one-liner does not supply. Only the unbounded read is carried here as measured. E176 owns `str-sub` range discipline per `docs/decisions/decision-lane-split.md`.
- evidence: `lib/prelude/prelude.chiral:80`, `lib/prelude/string.chiral:14`, `:17`, `.planning/FINDING-str-sub-range-2026-08-31.md:12`
- checked:  2026-09-01
- owner:    E176
- from:     BA-35

### PRB-25 the two E181 artifacts cite a file the consolidation deleted

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    doc
- about:    docs/examples/E181-pretty-term-doc.md
- claim:    a worked example and its SPEC are the design rationale for an element and are kept as written, so their citations resolve.
- measured: `HANDOFF-DIAGNOSTICS-ARC.md` was split into `records/diagnostics-arc-record.md` (binding decisions, traps) and `docs/arcs/diagnostics-arc.md` (live arc state) and deleted from the root. Six citations of it survive in the two E181 artifacts: three in the example (`:188` the blob-size quote, `:199` a binding decision, `:661` the empty-`cmp` trap) and three in the SPEC (`:454` the status table and Lane A queue, `:465` a promotion step, `:681` the chain and the arc's binding decisions). Each names a file that is not in the tree. Not repaired: both are frozen-rationale tier and `records/consolidation-handoff.md` §2 binds this class to record-do-not-chase, the same stance BA-22 takes for the other 34. Every other live citation of the deleted file was repointed in the same commit; `docs/decisions/decision-lane-split.md:5` and `records/diagnostics-arc-record.md:15` keep theirs as historical "was X, moved to Y" notes, which is correct.
- evidence: `docs/examples/E181-pretty-term-doc.md:188`, `:199`, `:661`, `docs/elements/specs/E181-pretty-term-doc-SPEC.md:454`, `:465`, `:681`, `records/consolidation-handoff.md`
- checked:  2026-09-01
- owner:    none
- from:     BA-37

### PRB-26 eleven citations point into another repository's untracked working material

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    doc
- about:    docs/elements/catalog.md
- claim:    `records/consolidation-handoff.md` §3 called these dead citations — `.planning/METIS-PORT-SPEC.md` "present nowhere in the tree" and "four `.planning/scriba-examples/S1`–`S3` files that do not exist". The wider claim behind the consolidation is that a fresh clone can follow what a tracked document cites.
- measured: RE-MEASURED 2026-09-06: unchanged. `/workspace/manas/.planning/METIS-PORT-SPEC.md` is still on disk and the citations still point outside this repository, into another tree's untracked working material. A fresh clone of chirality alone cannot follow any of them.
- evidence: re-runnable: `ls /workspace/manas/.planning/METIS-PORT-SPEC.md` succeeds from this box and would not from a fresh clone. `docs/elements/catalog.md:222`, `docs/examples/E133-manas-core-types.md:37`
- checked:  2026-09-06
- owner:    none
- from:     BA-38

### PRB-27 E173's SPEC mutant M3 is inert, because termination is not enforced

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/typing/totality-check.chiral
- claim:    `docs/elements/specs/E173-total-matcher-SPEC.md` §5 carries M3, a mutant that makes `pd`'s `p-star` arm recurse into `(p-star q)` instead of a strict subterm, and asserts `chirality check` refuses it. The SPEC passed its audit at `4769cd2`, and `.planning/protocol/workflow.md` requires every gate row to name a mutant that is actually run.
- measured: RE-MEASURED 2026-09-06: unchanged. `tot-gate` (`lib/typing/totality-check.chiral:153-156`) reads `tot-demanded` over the composite's profile list first and answers `tot-proven` without classifying one def when no profile carries `(total)`. Its single call site is `lib/lowering/compile-front.chiral:371`. Measured over `prog/`: **zero** roots declare a `(profile ...)` clause at all, `prog/prose-lint.prog` among them, so M3 still observes divergence and the E173 gate row still passes by looking at nothing.
- evidence: re-runnable: `grep -l '(profile' prog/*.prog` returns nothing, and `sed -n '152,156p' lib/typing/totality-check.chiral` shows the `false` arm answering `tot-proven`. `lib/typing/totality-check.chiral`, `lib/lowering/compile-front.chiral`, `docs/elements/specs/E173-total-matcher-SPEC.md`
- checked:  2026-09-06
- owner:    E11 (wiring the classifier is E11's remaining work; no new element is owed)
- from:     BA-39

### PRB-28 prose-lint's per-line reporter runs a smaller check set than its counter

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    tools/prose-lint/prose-lint.sh
- claim:    `tools/prose-lint/prose-lint.sh:85` states that "both the counter and the per-line reporter read through this same filter, so a worklist number and its lines agree". `.planning/protocol/tone.md` tabulates ten checks as what the tool enforces.
- measured: the two paths carry different check sets. `_scan`, the counter behind `--worklist`, `--summary` and `--baseline`, runs ten `gsub` checks at `:95-104`. `cmd_lines`, the per-line reporter reached by the `prose-lint PATH...` form, runs one hand-merged alternation at `:164` that drops `parallel-no` entirely and drops four needles from four other checks: `isn.t|aren.t` from `copula-negation`, `[Ii]n other words` from `throat-clearing`, `Additionally,` from `connective`, and `[Pp]lethora|[Mm]yriad|[Pp]ivotal` from `slop-word`. Over `docs/arcs/*.md docs/decisions/*.md docs/definitions/*.md`, 80 files, the reporter prints 1457 hits and the counter prints 1465. All 8 of the difference are `parallel-no`, across 6 files: `docs/arcs/zero-python-arc.md:51`, `docs/arcs/text-tools-arc.md:142`, `docs/definitions/insp-smalltalk.md:24`, `docs/definitions/memory-model.md:37` and `:98`, `docs/definitions/secure-datum-model.md:4`, `docs/definitions/target-tomodachi.md:36` and `:51`. Each was confirmed against awk's own `parallel-no` regex through `grep -nE`. The smallest case reproduces alone: `prose-lint --summary docs/definitions/insp-smalltalk.md` reports 2 and `prose-lint docs/definitions/insp-smalltalk.md` prints 1. The other four omissions score 0 over these 80 files, so they are latent rather than visible today. A hypothesis that `_scan`'s `c["name"] = gsub(...)` assignment form discards an earlier line's count was tested and refuted: all ten keys are reassigned on every line and `tot[FILENAME SUBSEP k] += c[k]` runs after the ten, so totals accumulate. `_scan` is correct on all four checks that fire over this corpus, and E173's native `prog/prose-lint.prog` matches it exactly, 906 / 392 / 159 / 8. Not repaired: E173 slice 1 ports the counter, and the shell tool is scheduled for replacement.
- evidence: `tools/prose-lint/prose-lint.sh:85`, `:95-104`, `:153-171`, `.planning/protocol/tone.md`
- checked:  2026-09-01
- owner:    none
- from:     BA-40

### PRB-29 the SEEDED refinement row claims path-sensitivity, and a guard over two let-bound `I64`s leaves an obligation nothing discharges

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    docs/definitions/status-ledger.md
- claim:    `docs/definitions/status-ledger.md:155`, the SEEDED **Refinement types** row, claims path-sensitivity for I64 atoms over "a constant or a bare in-scope variable": *"a comparison-guarded branch learns the bound it proves"*.
- measured: RE-MEASURED 2026-09-06: **CONFIRMED, unchanged in substance, and the ledger citation has drifted 33 lines.** The SEEDED **Refinement types** row now sits at `docs/definitions/status-ledger.md:188`; `:155` holds a different row. Its text is verbatim what this row quotes, path-sensitivity over a constant and over a bare in-scope variable, with `a comparison-guarded branch learns the bound it proves`, and it still closes by recording that no phase exercises the refinement fragment. **The refusal reproduces in the fixture that surfaced it.** Substituting the inline spelling for the `max` call at `tools/test/samples/e173_matcher.prog:110` makes the file fail `bin/chirality check` at **exit 1** with `load: cannot prove refinement`, while the unmodified fixture passes at exit 0. Reduced to two parameters, `(def mx (-> I64 I64 I64) (lam (hi sz) (let ((hi2 (case (<i hi sz) (true sz) (false hi)))) hi2)))` fails identically, and the same `case` returned directly as the body of the `let` passes at exit 0, so FD-02's condition list holds unchanged. `lib/prelude/prelude.chiral:150` still declares `(def max (-> I64 I64 I64)` and the E173 fixture still routes through it. `lib/typing/refine.chiral` is unmoved. One workaround citation drifted: the e173 comment spans `:100-105` with `mx-go` at `:106-118`, where this row cited `:100-107`. `prog/paren-audit.prog:103-107` is exact. PRB-48 re-measured the two-line-minimum half of the same family on 2026-09-06 and confirmed it. The tension this row states is untouched, and FD-02's three coherent fixes still make it a blueprint before a patch.
- evidence: re-runnable: `grep -n 'Refinement types' docs/definitions/status-ledger.md` returns 188. A file holding `(import "prelude/prelude")` then `(def mx (-> I64 I64 I64) (lam (hi sz) (let ((hi2 (case (<i hi sz) (true sz) (false hi)))) hi2)))` fails `bin/chirality check` at exit 1 with `load: cannot prove refinement`; the same def with the outer `let` dropped, returning the `case`, passes at exit 0. `bin/chirality check tools/test/samples/e173_matcher.prog` exits 0, and the same file with `(max hi (length Thread ts1))` at `:110` rewritten to the inline `case` exits 1. `docs/definitions/status-ledger.md:188`, `lib/typing/refine.chiral`, `lib/prelude/prelude.chiral:150`, `tools/test/samples/e173_matcher.prog:100-105`, `:106-118`, `prog/paren-audit.prog:103-107`, `records/findings.md` FD-02
- checked:  2026-09-06
- owner:    none
- from:     BA-41

### PRB-30 the transport gap is stated in three names, and two of them stopped being externs

- state:    FIXED
- author:   unreviewed
- note:     none
- level:    source
- about:    docs/definitions/status-ledger.md
- claim:    `docs/definitions/status-ledger.md:149`, the orchestration-substrate row, gives the reason the substrate cannot run as `http-request` and `backend-open` having no entry in `lib/lowering/tal/crossing-wraps.chiral`. The owed table in `docs/goals/local-ai.md` adds `chat-open` and says the three have no runtime referent. `.planning/LOCAL-AI-ARC-REALIGNMENT.md` section 3A rests its whole first arc on that reading.
- measured: RE-MEASURED 2026-09-06: **every leg of this claim is repaired, the residue it left is closed, and the row stops being a defect.** The orchestration-substrate row has moved from `docs/definitions/status-ledger.md:149` to `:182`, and it no longer gives the crossing-table gap as its reason. It now records that `http-request` and `chat-open` are chirality defs over the socket caps since E130 and E131, that `backend-open` stays an extern and erases to `nb-id` under the E144 string carrier, and that every other extern under `lib/protocol/` and `prog/manas/` erases or crosses, citing `BA-42` and [[arcs/transport-arc]] by name. The owed table at `docs/goals/local-ai.md:116` carries the same correction, landed at `84fbcfb` on 2026-09-02. `.planning/LOCAL-AI-ARC-REALIGNMENT.md:10-17` carries an **Acted on 2026-09-02** banner naming `BA-42` as the corrected reading, over a section 3A body at `:64-65` that still reads the three-name gap. Every source measurement holds: `lib/protocol/http.chiral:437` and `:773`, `lib/lowering/tal/erase.chiral:123`, `prog/manas/backend.chiral:37`, and a grep of `lib/lowering/tal/crossing-wraps.chiral` for the three names returns **0**. ⚑ **The row's own conclusion, that no phase performs a model call, is refuted.** Phase 20 landed at `d7d7cfe` on 2026-09-02 as `tools/test/transport.sh`, dispatched at `tools/test/run-tests.sh:324`, and reads **`transport: 5 passed, 0 failed, 0 deferred`**: three hermetic and hard-gated rows, two endpoint-bound against `100.64.0.5:11434`, which answered. The floor is green at `assertions: 412 passed, 0 failed`, 93 roots, gate PASSED. `arcs/transport-arc` records `T1` built for the document repair and `T2` for the phase. ⚑ Two stale traces are left standing in documents this row may not edit, and are reported: `docs/definitions/status-ledger.md:194` still calls the three `Secret` externs the same shape as `http-request` and `backend-open` in the row above, which the row above has stopped describing, and `records/author-calls.md:210` still gives the transport arc's job as giving all three a runtime referent.
- evidence: re-runnable: `grep -n 'Orchestration substrate' docs/definitions/status-ledger.md` returns 182. `grep -c 'http-request\|backend-open\|chat-open' lib/lowering/tal/crossing-wraps.chiral` returns 0. `grep -n '(def http-request$\|(def chat-open$' lib/protocol/http.chiral` returns 437 and 773. `bash tools/test/transport.sh` exits 0 at `transport: 5 passed, 0 failed, 0 deferred`, with the two endpoint-bound rows deferring when `100.64.0.5:11434` is silent. `bash tools/test/run-tests.sh` exits 0 at `assertions: 412 passed, 0 failed`. `docs/definitions/status-ledger.md:182`, `:194`, `docs/goals/local-ai.md:116`, `.planning/LOCAL-AI-ARC-REALIGNMENT.md:10-17`, `:64-65`, `lib/lowering/tal/erase.chiral:123`, `prog/manas/backend.chiral:37`, `tools/test/run-tests.sh:324`, `records/author-calls.md:210`, commits `84fbcfb`, `d7d7cfe`
- checked:  2026-09-06
- owner:    none
- from:     BA-42

### PRB-31 S18 is recorded as owed in two documents and was built on 2026-08-23

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    docs/goals/local-ai.md
- claim:    the owed table in `docs/goals/local-ai.md` records the `Scriba` state record as a SPEC that exists and is unbuilt. `.planning/LOCAL-AI-ARC-REALIGNMENT.md` section 3B builds its scriba arc on the same reading and makes `S18` the first row.
- measured: RE-MEASURED 2026-09-06: **half closed. The goal file is repaired and the proposal is not.** `docs/goals/local-ai.md` has stopped recording the `Scriba` record as a specced and unbuilt owed row. The owed entry is now `Buffer list and switching, S19` at `:117`, and it states that the record gating it is BUILT, 2026-08-23, `prog/scriba/editor-state.chiral`, naming `BA-43` and [[arcs/scriba-arc]]. That landed at `84fbcfb` on 2026-09-02. What survives in that file is `:227`, which still argues the scriba half is unblocked because `S18` already has a SPEC, a sentence that reads as scheduled work. `.planning/LOCAL-AI-ARC-REALIGNMENT.md` section 3B at `:83-99` still makes `S18` the first row of its scriba arc, under the **Acted on 2026-09-02** banner at `:10-17` that names `S18` being unbuilt as `BA-43`, so the body is disclaimed and uncorrected. **The build measurement holds exactly.** `prog/scriba/editor-state.chiral:58` defines `(data Scriba ()`, three modules under `prog/` import it, and `.planning/SCRIBA-PRIMITIVE-CHECKLIST.md:106` still carries BUILT 2026-08-23 with `5a88be3` and `130062f` and every figure this row quotes: **78** signatures, **367** argument sites over **318** lines, **nine** threading shapes against the SPEC's one 11-parameter thread, net LOC **0** at 2,545 lines before and after, and the 155,291 to 132,287 byte fall of **14.8%**. ⚑ `docs/arcs/scriba-arc.md:42-45` and its roster row `scriba/S1` both say two documents carry `S18` as unbuilt. One does. That over-count sits in a document this row may not edit and is reported.
- evidence: re-runnable: `grep -n 'BUILT, 2026-08-23' docs/goals/local-ai.md` returns 117, the owed row that used to carry the record as unbuilt. `grep -n '(data Scriba' prog/scriba/editor-state.chiral` returns 58. `grep -rl 'scriba/editor-state' prog/ | wc -l` returns 3. `grep -n 'BUILT 2026-08-23' .planning/SCRIBA-PRIMITIVE-CHECKLIST.md` returns 106 and 327. `docs/goals/local-ai.md:117`, `:227`, `.planning/LOCAL-AI-ARC-REALIGNMENT.md:10-17`, `:83-99`, `docs/arcs/scriba-arc.md:42-45`, `:71`, commit `84fbcfb`
- checked:  2026-09-06
- owner:    scriba/S1
- from:     BA-43

### PRB-32 five documents cite `.gitignore:12` as excluding `.planning/`, and that file says the opposite

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    doc
- about:    docs/elements/README.md
- claim:    `docs/arcs/README.md`, `docs/elements/README.md:16`, `docs/arcs/presentability-arc.md`, `docs/definitions/status-ledger.md:67` and `docs/decisions/decision-dispatch-cadence.md:17` all cite `.gitignore:12` for the planning tier being excluded from git. Three of them draw doctrine from it: a fact written under `.planning/` forks per worktree, dies with it, and cannot be relied on by a second reader.
- measured: RE-MEASURED 2026-09-06: unchanged. `.gitignore:1` is still the banner "the agent tier is tracked", so the five documents citing `.gitignore:12` as the line excluding `.planning/` cite a line that says no such thing. `.planning/` has been tracked since 2026-09-01.
- evidence: re-runnable: `head -1 .gitignore` prints the agent-tier-is-tracked banner. `.gitignore`, `docs/decisions/decision-ai-tier.md`
- checked:  2026-09-06
- owner:    none
- from:     BA-44

### PRB-33 the lowered/skipped ratio is unmeasured, and `skip-reason` is not the mechanism

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/upper/lower.chiral
- claim:    `records/lane-a-record.md` says a large fragment of the language never lowers, and that the lowered/skipped ratio is unmeasured.
- measured: RE-MEASURED 2026-09-06: unchanged. `skip-reason` and its neighbours appear only in `lib/lowering/upper/lower.chiral`, 6 occurrences there and none anywhere else under `lib/`. Nothing calls it, so the lowered-to-skipped ratio the compiler could report is still unmeasured.
- evidence: re-runnable: `grep -rc 'skip-reason' --include='*.chiral' lib/` returns a nonzero count only for `lowering/upper/lower.chiral`. `lib/lowering/upper/lower.chiral`
- checked:  2026-09-06
- owner:    E184
- from:     EN-01

### PRB-34 `optimize.chiral:250` is not the only `ck-fn` call site

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/upper/optimize.chiral
- claim:    `records/lane-a-record.md:149` says `lowering/upper/optimize` "holds the only `ck-fn` call in the tree, at `:250`".
- measured: RE-MEASURED 2026-09-06: the refutation holds and the sites moved. `(ck-fn ` now resolves to three places: `lib/lowering/upper/optimize.chiral:250` (the `re-check` this row was filed against), `lib/lowering/tal/check.chiral:303` inside `ck-fns`, which `ck-prog` folds over the program, and a comment at `lib/lowering/tal/sys-check.chiral:4`. So `optimize.chiral:250` was never the only call site, which is what this row established.
- evidence: re-runnable: `grep -rn '(ck-fn ' --include='*.chiral' lib/` returns three hits. `lib/lowering/tal/check.chiral:303`, `lib/lowering/upper/optimize.chiral:250`
- checked:  2026-09-06
- owner:    none
- from:     EN-02

### PRB-35 the `Judg` and `Reason` line ranges are two lines off

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/typing/diag.chiral
- claim:    `Judg` is declared at `diag.chiral:97-110` and `Reason` at `:120-137`, with 38 constructors and 9 reasons. Repeated in three places.
- measured: RE-MEASURED 2026-09-06: the drift widened from the ranges to the counts, and this row's own corrected figures have gone stale with the claim's. `(data Judg ()` opens at `:99` and its last constructor sits on `:111`; `(data Reason ()` opens at `:121` and closes at `:141`. The counts moved: **36** `Judg` constructors against the 38 this row confirmed, and **10** `Reason` shapes against 9. Both moves are E182 on 2026-09-02. `65bec90` added `r-arity`, the shape carrying both counts as integers, and `d26d7a1` retired the two nullary arms it replaced, `jg-ctor-arg-arity` and `jg-tparam-arity`. The three sites are unrepaired and each now carries four wrong figures where it carried two: `docs/definitions/bug-classes.md:110-111`, `records/lane-a-record.md:192` and `docs/elements/specs/E158-doc-formatter-SPEC.md:90` all still read `:97-110`, `:120-137`, 38 and 9. This stays BA-13's class, a citation a later insertion moved and three documents copied forward. ⚑ `records/lane-a-record.md:99` plans E182 as retiring 3 of the 38 arms. It retired 2.
- evidence: re-runnable: `grep -n '(data Judg' lib/typing/diag.chiral` returns 99 and `grep -n '(data Reason' lib/typing/diag.chiral` returns 121. `sed -n '99,111p' lib/typing/diag.chiral | grep -o '(jg-[a-z0-9-]*)' | wc -l` returns 36. `sed -n '121,141p' lib/typing/diag.chiral | grep -c '^  (r-'` returns 10. `lib/typing/diag.chiral:99-111`, `:121-141`, `docs/definitions/bug-classes.md:110-111`, `records/lane-a-record.md:99`, `:192`, `docs/elements/specs/E158-doc-formatter-SPEC.md:90`, commits `65bec90`, `d26d7a1`
- checked:  2026-09-06
- owner:    none
- from:     EN-03

### PRB-36 the compile-only verdict line is at `:298`, not `:280`

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    tools/test/run-tests.sh
- claim:    two documents cite `tools/test/run-tests.sh:280` as the line printing `compile-only: N roots built, N failed -- gates, but asserts nothing`.
- measured: REFUTED, and RE-MEASURED 2026-09-06: the compile-only verdict line is now `:422`, having been `:298` when this row refuted the `:280` it was filed against. `run_phase 18` is at `:284`. The quoted text stays correct and only the citation was ever wrong, which is the EN-03 class: a line number that moved.
- evidence: re-runnable: `grep -n 'roots built' tools/test/run-tests.sh` returns `:422`; `grep -n 'run_phase 18' ...` returns `:284`
- checked:  2026-09-06
- owner:    none
- from:     EN-04

### PRB-37 the zero-importer count is definition-dependent and the definition is not stated

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    records/lane-a-record.md
- claim:    `records/lane-a-record.md:144` records 18 zero-importer modules in `lib/`, 2,086 LOC.
- measured: CONFIRMED, but only under the definition where an importer is a file under `lib/` or `prog/`. Counting importers within `lib/` alone gives 27 modules and 4,769 LOC. Counting importers anywhere in the repo gives 17 modules and 1,828 LOC, the one-module difference being `protocol/render-doc`, whose sole importer is `tools/test/samples/e158_render.prog`. Three defensible definitions, three different numbers, and the figure is quoted without the one it used. State the definition wherever the number is used.
- evidence: `records/lane-a-record.md:144`, `lib/protocol/render-doc.chiral`, `tools/test/samples/e158_render.prog`
- checked:  2026-09-01
- owner:    none
- from:     EN-05

### PRB-38 the four diagnostic classes reproduce, and the instrument is a probe

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/tal/check.chiral
- claim:    [[arcs/enforcement-arc]] requirement 3 records `ck-prog` accepting 743 of 1,504 TFns and rejecting 761 (50.6%), in four classes: 392 `ret`, 187 `con`, 107 `case on non-data register`, 75 `argument arity`.
- measured: RE-MEASURED 2026-09-06: the shape moved on both halves and the row stays OPEN on one of them. **The four classes no longer reproduce.** Their cause was repaired at `ddfbc27` (2026-09-03): `targs=?` went into `tal-ty=?`'s `tt-data` arm (`lib/lowering/tal/check.chiral:90-95`) and `ck-scrut-dn` gave `ck-term`'s case arm the `tt-word` recovery (`:139-146`), the two repairs EN-09 and EN-11 named. **A census is committed now, for a different instrument.** `prog/optimizer-census.prog` and `tools/test/opt-census.sh` landed at `7a62965` and `d7ccad8` (2026-09-05) and re-derive the SHIPPING path's census over the compiler's own blob: `census tfns=1582 ok=1550 err=32 defs=1551 skipped=10 unfolded-ok=1550`, one class, `call: unknown tal function`, zero `ret`, zero `con`, zero `case on non-data register`, zero `argument arity`. ⚑ **The `ck-prog` census is still a reverted probe, which is why this row stays OPEN.** That instrument folds `ck-prog` whole-program; the committed one runs `re-check` per TFn on the shipping `CEnv` (`lib/lowering/compile-back.chiral:239-246`). `ck-prog` has zero callers today, so this row's own four counts cannot be re-taken, and `enforcement/N12` still owns that at `open` / `unminted`.
- evidence: re-runnable: `tools/test/opt-census.sh` reads `opt-census: 12 passed, 0 failed` and its R2 pins `tfns=1582 ok=1550 err=32`. `prog/optimizer-census.prog`, `tools/test/opt-census.sh`, `lib/lowering/tal/check.chiral`, `lib/lowering/compile-back.chiral`
- checked:  2026-09-06
- owner:    none
- from:     EN-08

### PRB-39 the `ret` class is the checker: an erased type-argument list, 389 of 389

- state:    FIXED
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/upper/lower.chiral
- claim:    requirement 3 counts the `ret` class and leaves the side that is wrong unnamed.
- measured: RE-MEASURED 2026-09-06: **FIXED, by the relaxation this row named.** `targs=?` (`lib/lowering/tal/check.chiral:90-95`) makes an empty type-argument list on either side match, which is the change this row said would turn all 389 into accepts. It landed at `ddfbc27` on the author's ruling of 2026-09-03, `records/author-calls.md` "The `ck-prog` repair shape". Both ends of the diagnosis still read as written: `expr-con` annotates every constructed value `(tt-data dn nil)` (`lib/lowering/upper/lower.chiral:291-299`), and `ck-con` and `ck-term`'s case arm resolve a data type by name alone. The shipping census over the compiler's own blob completes 1,550 of 1,582 TFns with **zero** `ret` rejects, and the 32 that refuse stop earlier, on `call: unknown tal function`. `tools/test/tal-check.sh` G1 pins the accept, and mutant M2 reddens G1, G5 and G6 when the wildcard is cut. ⚑ The contributing defect this row flagged survives: `expr-con` binds `exty` at `lower.chiral:291` and reads it at no line.
- evidence: re-runnable: `tools/test/tal-check.sh` reads `20 ok, 1 FAIL` with G1 green and M2 live; the single FAIL is G18, whose subject is the closure claim and lies outside this row. `lib/lowering/tal/check.chiral`, `lib/lowering/upper/lower.chiral`, `records/author-calls.md`
- checked:  2026-09-06
- owner:    none
- from:     EN-09

### PRB-40 the `con` class is that same erased argument list, 184 of 185

- state:    FIXED
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/tal/check.chiral
- claim:    requirement 3 counts the `con` class and leaves the side that is wrong unnamed.
- measured: RE-MEASURED 2026-09-06: **FIXED, by the same repair EN-09 got.** `ck-con`'s field check (`lib/lowering/tal/check.chiral:184-196`) runs `ck-args` into `tal-ty=?`, whose `tt-data` arm now calls `targs=?` (`:90-95`), so the 184 carrying zero arguments against one or two accept. The shipping census over the compiler's own blob completes 1,550 of 1,582 TFns with **zero** `con` rejects, and the 185th accepts with them: `$apply7` carries no refusal today. `tools/test/tal-check.sh` G5 pins the accept through `ck-con` specifically, and mutant M2 reddens it when the wildcard is cut. ⚑ The 185th's disappearance goes unattributed here. This row routed it to EN-13 as a ground-type conflation, and E185 through E188 all landed over the `$apply` dispatchers in the interval.
- evidence: re-runnable: `tools/test/tal-check.sh` G5 reads `a3 EN-10's field position -- ACCEPT`, with M2 live over the same relation. `lib/lowering/tal/check.chiral`, `lib/lowering/upper/lower.chiral`
- checked:  2026-09-06
- owner:    none
- from:     EN-10

### PRB-41 the `case on non-data register` class is the checker lacking the recovery the lowering has, 105 of 105

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/upper/lower.chiral
- claim:    requirement 3 counts the `case on non-data register` class and leaves the side that is wrong unnamed.
- measured: THE CHECKER, in all 105. Every one is a scrutinee register typed `tt-word`. Zero are the other path to that same message, an unbound scrutinee register. The lowering performs a B1 recovery: `case-sty` calls `ctor-data` to read the data name out of the first arm's constructor whenever the scrutinee's tal type fails to be `tt-data`. That recovery stays inside the lowering's own bookkeeping and reaches the emitted instruction at no point, so the register keeps `tt-word` in the TFn. `ck-term`'s case arm carries no `tt-word` arm and falls through to its catch-all. The refusal contradicts the checker's own `tal-ty=?`, whose first arm makes `tt-word` compatible with every type. Giving `ck-term` the same `ctor-data` walk over `ce-datas` turns all 105 into accepts. Minimal rejecting TFn: `(tfn "sel" ((tt-word)) (tt-i64) (block nil (tt-case 0 ...)))`; respelling that parameter `(tt-data "Lst" nil)` makes the identical body accept. Its source twin, a case over a value read out of a polymorphic field, compiles, emits, links and runs correctly.
- evidence: `lib/lowering/upper/lower.chiral:168-188`, `:304-306`, `:347-355`, `lib/lowering/tal/check.chiral:210-222`, `:67-69`, `lib/lowering/tal/ssa.chiral:17-20`
- checked:  2026-09-03
- owner:    none
- from:     EN-11

### PRB-42 the `argument arity` class splits, 70 to the checker and 5 to the lowering

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/upper/lower.chiral
- claim:    requirement 3 counts the `argument arity` class and leaves the side that is wrong unnamed.
- measured: SPLITS 70 to the checker and 5 to the lowering. As counted, the 75 are 73 the erased argument list of EN-09 reaching `ck-app` through `ck-args`, all of them zero arguments against one, plus one data-name mismatch and one ground-type mismatch. Relaxing that one checker relation flips 70 of the 75 to accepts and leaves 5, which is where the split lives: the relaxation unmasks two rejects the argument-list failure had been hiding, because `ck-args` returns on its first failing position. Those two are the lowering, and they are a real defect. `build-binders` allocates a fresh register for every erased binder position and emits no instruction defining it, on the stated ground that a `q=0` binder has zero runtime uses; `outline` then passes the whole binder environment as the outlined call's arguments, so that undefined register is passed. The enclosing TFn's `params` holds the kept list, so nothing binds it there either. They are `emit-code` (4 params, undefined register 4) and `emit-args-res` (3 params, undefined register 3), where in both the offending index equals the parameter count, which is the first register `build-binders` allocates. The emitted native code reads an undefined register and the program still computes correctly, because the callee reads that argument at no point. The remaining 3 of the 5 sit inside `$apply` dispatchers and belong with the residue in EN-13. Minimal rejecting TFn: a caller of one parameter whose body is `(i-call 1 "inner" (0 2) (tt-i64))` where register 2 is bound by nothing; inserting a definition of register 2 makes it accept. Its source twin, an erased binder over a non-tail case, compiles, emits, links and runs correctly.
- evidence: `lib/lowering/upper/lower.chiral:383-397`, `:308-317`, `:399-406`, `lib/lowering/tal/check.chiral:99-107`, `:109-117`, `:237-242`
- checked:  2026-09-03
- owner:    none
- from:     EN-12

### PRB-43 six TFns survive both relaxations, and the repair shape is an author call

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/upper/closconv.chiral
- claim:    none. This row records what the diagnosis leaves behind.
- measured: RE-MEASURED 2026-09-06: **the residue moved, and both questions this row left open are answered.** The argument-list question was ruled on 2026-09-03, `records/author-calls.md` "The `ck-prog` repair shape": repaired in the checker, and `targs=?` shipped at `ddfbc27`. The refuse-or-carry question was ruled on 2026-09-04, `records/author-calls.md` "The `$apply` dispatcher's erased domains". **The six survivors fail to reproduce as a set.** `prog/optimizer-census.prog` over the compiler's own blob prints `census tfns=1582 ok=1550 err=32`, one class, `call: unknown tal function`. Of this row's six, `$apply5`, `$apply6` and `$apply7` accept in full, while `$apply4`, `emit-code` and `emit-args-res` refuse on the outlined-block callee `<name>$0` and never reach the ground-versus-data shape. ⚑ **Three of the six are therefore unobservable.** `ck-instrs` (`lib/lowering/tal/check.chiral:225-230`) stops at the first `tck-err`, so this census cannot say whether the disagreement survives inside those three. The live residue is the `CEnv`-plumbing gap `enforcement/N12` and EN-25 carry. `lib/lowering/upper/closconv.chiral:360-364` still records that two families returning different ground types must stay unmerged.
- evidence: re-runnable: `tools/test/opt-census.sh` reads `opt-census: 12 passed, 0 failed`; the probe's `err` lines number 32, every callee a `<name>$0`, and `$apply5`, `$apply6` and `$apply7` are absent from them. `prog/optimizer-census.prog`, `lib/lowering/upper/closconv.chiral`, `lib/lowering/tal/check.chiral`
- checked:  2026-09-06
- owner:    enforcement/N12
- from:     EN-13

### PRB-44 five of `check.chiral`'s eleven collisions are duplication, and the honest fix is a shared module

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/tal/check.chiral
- claim:    none yet. The rename that made `lowering/tal/check` importable beside the compiler treated all eleven collisions alike, and for five of them that is a hand-patch over a different defect.
- measured: RE-MEASURED 2026-09-06: **unchanged, and the hand-patch is what makes it look fixed.** All five twins survive in `lib/lowering/tal/check.chiral` under a `tck-` prefix: `tck-sig-assoc`, `tck-find-data`, `tck-ce-prims`, `tck-ce-fns`, `tck-ce-datas`, one definition each, beside the unprefixed originals in `lib/lowering/upper/lower.chiral`. ⚑ A grep for the bare names in `check.chiral` returns zero, which reads as resolved and is a rename. The file's own header at `:20-30` calls them "byte-identical twins" whose "honest fix is a shared module", so the duplication stands and only the emitted-label collision was patched.
- evidence: re-runnable: `for s in sig-assoc find-data ce-prims ce-fns ce-datas; do grep -c "^(def tck-$s" lib/lowering/tal/check.chiral; done` returns 1 five times. `lib/lowering/tal/check.chiral:20-30`, `lib/lowering/upper/lower.chiral:163-194`
- checked:  2026-09-06
- owner:    none
- from:     EN-16

### PRB-45 the `$kI_J` capture constructor's field types are a second instance, and a separate call

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    .planning/RESEARCH-EN15-prior-art.md
- claim:    EN-15 reads the four `$apply` rejections and the `$apply7` rejection as one cause, and an earlier session reading took the two instances to have the same answer. The 2026-09-04 ruling on the erased-word type ([[decisions/decision-erased-word-level]]) settles the dispatcher's domains and says nothing about the capture constructor's fields.
- measured: RE-CHECKED 2026-09-05 against a fixpoint binary (C1 == C2 == tracked, 1,241,464 bytes), with `tal-check.sh` (20 ok, 1 FAIL on G18), `apply-word.sh` (11 ok), `apply-spine.sh` (11 ok), `defunc-blame.sh` (11 ok), `capture-fields.sh` (9 ok) and `arity.sh` (17 passed) all run. The subject is live and unresolved: `decision-erased-word-level` settled the level and left the capture-constructor instance open, and `capture-fields.sh` passing 9 rows measures E186's predicate rather than closing the prior-art split. Citation `closconv.chiral:1099` has drifted: that line now sits inside the `g-subst-go` comment block. A CORRECTION, and the prior art splits the two instances. `.planning/RESEARCH-EN15-prior-art.md` §7: both published answers keep constructor fields CONCRETE. Pottier and Gauthier's `succ : Arrow int int` carries concrete field types beside concrete arrow indices, and the dispatcher's branch recovers the indices from the GADT equation; Minamide, Morrisett and Harper's typed closure conversion hides a heterogeneous environment behind `∃` with the fields concrete inside the pack, and Huang and Yallop's label-context entry keeps the captures at their source types. The reason the two differ is structural: a capture constructor (`ctor-name`, `lib/lowering/upper/closconv.chiral:1099`, spelling `$k<i>_<j>`) is applied at exactly one site, its own definition site, so nothing forces its field types to merge with another constructor's, while the shared dispatcher's argument position is constrained by every member of the family at once. Under that shape the constructor is the concrete side and the dispatcher the varying side, which is the OPPOSITE arrangement to the measured `$apply7`: that one reddens through `ck-con`'s field check (`lib/lowering/tal/check.chiral:183-196`) instead of through `ck-args` (`lib/lowering/tal/check.chiral:148-156`). So whether the two instances are one defect or two is unsettled, and the E185 spelling ruling may or may not reach the fields. ⚑ Nothing here is a miscompile today, for the same reason EN-15 gives: every one of these values is one word at runtime and the emitted code is correct. What is wrong is the type the IR carries, and `ck-prog` cannot be wired to refuse on the shipping path while either instance stands. ⚑ **SCOPE CORRECTED 2026-09-04 by EN-20.** The sentence above holds for the capture constructor's field types and does not generalize to the pass. `arm-body`'s `(none)` arm (`lib/lowering/upper/closconv.chiral:1051-1058`) is reached and emits the literal `0` as a whole function body, which is a live wrong-code defect and is **E188**, minted 2026-09-04. The field-type call this row holds is unaffected.
- evidence: `.planning/RESEARCH-EN15-prior-art.md` §7, `lib/lowering/upper/closconv.chiral:1099`, `lib/lowering/tal/check.chiral:183-196`, `:148-156`, `docs/decisions/decision-erased-word-level.md`, [[records/author-calls]]
- checked:  2026-09-06
- owner:    E186 (minted 2026-09-04 by E185's SPEC run; the author call stands and the element carries the pipeline after it) ⚑ **E185 no longer waits on this row, measured against the SPEC's disposition 2026-09-04.** `docs/elements/specs/E185-type-preserving-upper-SPEC.md` states the dispatcher's parameter types at the lowering type level as the erased word. `tal-ty=?` (`lib/lowering/tal/check.chiral:68-70`) has the erased word matching everything, so `$apply7`'s field check in `ck-con` passes on the parameter side while the constructor's declared fields stay concrete, which is the arrangement research §7 finds in the prior art. So the four dispatchers accept with this row open. What the row still blocks is whether the constructor's fields are honest, which is E186. ⚑ **Evidence coordinate corrected 2026-09-04 by the E186 example audit, appended rather than rewritten.** The evidence line above cites `ctor-name` at `lib/lowering/upper/closconv.chiral:1099`. `ctor-name` is at **`:1114`**, with `clo-name` at `:1112` and `apply-name` at `:1113`; `:1099` was correct when this row was written and E185's own comment insertion (`ccff8e8`, 15 lines above the three defs) moved them. The measured text is unaffected. Two more spans in this file carry the same 15-line drift and are left standing as the record they are: EN-18's evidence `closconv.chiral:1079-1099` and EN-13's `:1098`. The maintained coordinates live in `docs/elements/catalog.md` and `docs/elements/ledger.md`, both repointed in the same change. ⚑ **RULED 2026-09-04 by E186: `concrete`, and the ruling is recorded in [[decisions/decision-erased-word-level]].** The capture constructor's field types stay at the capture's own source type, and the erased word is reached only where that source type has no ground spelling. That is what `site-fields->term` (`lib/lowering/upper/closconv-driver.chiral:153-163`) already writes, so the ruling changes no compiler source; what E186 built is the ruling written down plus a gate that separates the two answers, `tools/test/capture-fields.sh`, four rows and five mutants at `9 ok, 0 FAIL`. The measurement is EN-21. ⚑ **The word is RULED and this row stays `state: OPEN`.** EN-15 reads ANSWERED because the author closed its call. This row's call is still live in [[records/author-calls]] and closing it is the author's own act, so this note records where the ruling landed and nothing more. Nothing in the tree waits on the row: the ruling is written, the gate grades it, and `element: E186` carries the pipeline after it.
- from:     EN-17

### PRB-46 two dispatchers disagree with their own declared CODOMAIN, and `cod-key-eq` was assumed to have made that impossible

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/upper/closconv.chiral
- claim:    `docs/elements/specs/E185-type-preserving-upper-SPEC.md` §2 files the codomain under "what is already honest, and stays untouched", on the ground that `cod-key-eq` keeps a ground codomain concrete so two families returning different ground types never merge. EN-18 measures that assumption failing for two families.
- measured: RE-CHECKED 2026-09-05 against a fixpoint binary (C1 == C2 == tracked, 1,241,464 bytes), with `tal-check.sh` (20 ok, 1 FAIL on G18), `apply-word.sh` (11 ok), `apply-spine.sh` (11 ok), `defunc-blame.sh` (11 ok), `capture-fields.sh` (9 ok) and `arity.sh` (17 passed) all run. `arity.sh` 17 passed and `apply-word.sh` R6 reports the fixture ELF byte-identical under both binaries, so the codomain path is exercised and green. The row's own verdict is REFUTED-and-honest already; what it points at, EN-20's miscompile, is recorded as FIXED in the enforcement record. **REFUTED, and the codomain is honest. `cod-key-eq` did what its comment claims, no merge happened, and what is wrong is the emitted CODE. That is a live miscompile and it is EN-20.** The EN-08 probe was rebuilt outside `lib/` and `prog/` in three passes and reverted: pass one recovers the typed `TFn` list by re-running `lower-defs`' per-def `compile-fn` loop over `compile-front`'s `NDef` list and threads a register environment beside `ck-block`'s, so every `t-ret` names its own register's tal type; pass two re-runs `collect` over the pre-closconv `SigV` and dumps each kept family's sites with `def-ctx`'s verdict per site; pass three re-runs `filter-erasable` and `prune-fix`. Blob 812,351 bytes, 1,484 TFns, `bin/chirality-bin` 1,192,312 bytes at sha256 `fbcd2aeffbaba86e0d1ad451a5afb9a3a1732c3cc79026e83cc1faeedf325754`, the B3 EN-18 promoted. **THE RETURNING REGISTER, NAMED.** `$apply5` has nine arms. Eight return something `tal-ty=?` accepts against `(List Asm)`: `$k5_1` to `$k5_5` return `(tt-data "List" ((tt-data "Asm" nil)))`, `$k5_0` and `$k5_6` return `(tt-data "List" nil)` which `targs=?` matches, `$k5_7` returns `(tt-data "List" ((tt-word)))` which `tal-ty=?`'s `tt-word` arm matches. The ninth, `$k5_8`, is two instructions: `r179 = const 0 : i64` then `RET r179`. `$apply6` is the same shape, three arms returning `(List Asm)` and `$k6_3` returning `r23 = const 0 : i64`. So the register is `tt-i64` and the checker is refusing an integer literal against a list return. **WHERE THE INTEGER COMES FROM, AND IT IS NOT THE CODOMAIN.** Family 5's nine sites are `x-galo`, `x-ltb`, `x-sys`, `x-bpt`, `x-bgt`, `x-fld`, `x-alo`, `x-cal`, `mach-gbnw`; family 6's four are `x-binir`, `x-binr`, `x-bini`, `mach-galo`. `def-ctx` (`lib/lowering/upper/closconv.chiral:582-596`) returns a `dctx` for every site except `mach-gbnw` and `mach-galo`, where `peel-lam-exact` (`:590`) fails. `arm-body` (`:1051-1058`) has exactly one arm for that case, `((none) (c-lit-i 0))`, carrying the comment `unreachable: g always has a def-ctx`. It is reached, twice, in the compiler's own blob. `(c-lit-i 0)` occurs once in `closconv.chiral` and never in `closconv-driver.chiral`, so nothing else in the pass can produce that arm. **WHY `peel-lam-exact` FAILS.** `mach-galo` is `(-> Mach (-> I64 I64 (List I64) (List Asm)))` (`lib/lowering/mach/mach.chiral:134-135`) and `mach-gbnw` is `(-> Mach (-> I64 I64 (List Asm)))` (`:136-137`). `peel-pi-doms` peels the whole curried chain, four binders and three, while each body is one `lam` deep over a `case`. `def-ctx` requires the body to be exactly as deep as the type, so a curried projector is refused. `alloc-growing` (`lib/memory/alloc-growing.chiral:18-25`) is what puts both globals in value position. **SO THE ASSUMPTION E185's SPEC RESTED ON IS SOUND.** All thirteen sites across the two families have ground codomain `(List Asm)`, and `cod-key-eq`'s ground arm is `core-eq`, exact. The declared `(List Asm)` is the honest codomain of every member. Traversal order changes nothing here, because any member yields the same cod. This is the opposite of EN-15's domains, where the key spelled one arbitrary member's concrete types across an erasure `shape-eq` had already performed. ⚑ **ERASING THE CODOMAIN WOULD HIDE A LIVE DEFECT.** `tal-ty=?`'s first arm makes `tt-word` match everything (`lib/lowering/tal/check.chiral:68-70`), so a `tt-word` return accepts `const 0` and both rows go green with the wrong code still emitted. The `ret` refusal is today the only thing in the tree pointing at this, and it points by accident: EN-20's fixture has an `I64` codomain, where `const 0` matches the declared return and nothing reddens at all. ⚑ **NOT E186 AND NOT E187.** E186 is the capture constructor's field types and E187 is stating the lowering-level type of every name `closconv` invents. Both state types. A body returning the wrong VALUE is not repaired by stating a type, so this residue belongs to neither element. It needs its own Lane A element; `docs/decisions/decision-lane-split.md:31` reserves `E184-E189` and `E184`, `E185`, `E186`, `E187` are spent. The mint belongs to the pipeline stage that earns it. ⚑ **The earlier reading is retired.** EN-18 carried "whether this is `cod-key-eq` merging two families it should not, or an arm returning a value the member's own `TalSig` types differently" as the open question. It is the second, and the value is wrong at runtime as well as in the type.
- evidence: `lib/lowering/upper/closconv.chiral:365-376`, `:582-596`, `:590`, `:1051-1058`, `lib/lowering/mach/mach.chiral:134-137`, `lib/memory/alloc-growing.chiral:18-25`, `lib/lowering/tal/check.chiral:68-70`, `:256-258`, `lib/lowering/compile-back.chiral:220-240`, `docs/elements/specs/E185-type-preserving-upper-SPEC.md`, `docs/decisions/decision-lane-split.md:31`
- checked:  2026-09-06
- owner:    none
- from:     EN-19

### PRB-47 `str-sub` clamps, says a load-bearing comment

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/prelude/string.chiral
- claim:    `lib/prelude/string.chiral:14` says "str-sub clamps, so a too-long prefix is just false", and `str-starts-with` is written to depend on it.
- measured: two range cases were unguarded. `end < start` computed a negative length, reached the allocator and killed the process (`(str-len (str-sub "abc" 2 1))`, SIGSEGV, exit 139). `end > len` did not clamp: `(str-len (str-sub "abc" 0 99))` returned 99, a `Str` of length 99 over a 3-byte buffer, 96 bytes of adjacent memory, no error and no truncation. The inverted-range half was FIXED 2026-08-31: `nb-bslice-t` clamps an inverted range to the empty slice, fixpoint held at gen2==gen3 at 1,102,200 B and the promoted binary rebuilt byte-identically. **The `end > len` half is untouched**, so the cited comment is still false and `str-starts-with` still depends on a read past the buffer returning differing bytes. That is why this row is OPEN and not FIXED.
- evidence: `lib/prelude/string.chiral:14-17`, `lib/lowering/tal/erase.chiral:114`, `lib/lowering/tal/bytes.chiral` (`nb-bslice`, `nb-bslice-t`), `.planning/FINDING-str-sub-range-2026-08-31.md`
- checked:  2026-09-01
- owner:    none
- from:     FD-01

### PRB-48 a `let` over a `case` on a computed comparison cannot be proven

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/typing/kernel.chiral
- claim:    refinement checking accepts a two-line minimum function. Found porting `tools/paren-audit/paren-audit.py` to `prog/paren-audit.prog`, which needed one and could not have one.
- measured: RE-MEASURED 2026-09-06: **CONFIRMED, and the earlier finding that the fixture no longer parses is itself refuted.** `<i` is live. `lib/prelude/prelude.chiral:64` declares `(extern <i (-> I64 I64 Bool))`, and `prog/paren-audit.prog:110` calls it inside a file that passes `chirality check` at exit 0. The `load: unknown name <i` that run hit came from a fixture missing `(import "prelude/prelude")`, so it measured the import and never reached the checker. With the import the trigger reproduces exactly: `(def pa-min (=> I64 I64 I64) (lam (a b) (let (m (case (<i a b) (true a) (false b))) m)))` fails at `load: cannot prove refinement`, exit 1. All four conditions FD-02 named still gate it, each removed on its own and each then passing at exit 0: dropping the `let` and returning the `case` directly, handing the `Bool` in as a parameter instead of computing it, and returning the literals `1` and `2` from the arms. `cond` fails identically, as FD-02 recorded, since it desugars to `case`. The refusal site is unmoved by E182's 2026-09-02 pass over the same file: `lib/typing/kernel.chiral:1439-1440` still collapses two refusals into one `jg-refine-unproved`, and `unann-lit` (`:1426-1427`) answers `some` only for an integer literal or an annotation over one, so a `case` term reaches the `none` arm at `:1440`. `lib/typing/diag.chiral:454` renders that arm `cannot prove refinement`. The workaround stands with its comment at `prog/paren-audit.prog:103-110`.
- evidence: re-runnable: a file holding `(import "prelude/prelude")` then `(def pa-min (=> I64 I64 I64) (lam (a b) (let (m (case (<i a b) (true a) (false b))) m)))` fails `bin/chirality check` at exit 1 with `load: cannot prove refinement`; the same def with the `let` dropped, returning the `case` directly, passes at exit 0. `bin/chirality check prog/paren-audit.prog` exits 0. `lib/prelude/prelude.chiral:64`, `lib/typing/kernel.chiral:1426-1440`, `lib/typing/diag.chiral:454`, `prog/paren-audit.prog:103-110`, `records/findings.md` FD-02
- checked:  2026-09-06
- owner:    none
- from:     FD-02

### PRB-49 the closure refusal is about a bare lambda, not about capture

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/upper/closconv.chiral
- claim:    `.planning/USER-LAYER-GAP.md` §10 records "k>=1, real capture -> REFUSED" and reads it as a language limitation: captured closures in a record do not lower.
- measured: **RE-RUN 2026-09-06 against a fixpoint binary, and CONFIRMED with a fixture pair that now exists as a command.** `(data Box () (bx (f (-> I64 I64))))` with a bare `(lam (x) x)` written directly in the constructor argument position and **zero captures** fails to compile: `no emitted label for entry compile-main`, exit 1. The identical lambda bound to a `def` first and passed by name compiles to a 33,144-byte ELF that runs and exits 7. So the refusal is about the bare lambda in constructor position and not about captures, which refutes `.planning/USER-LAYER-GAP.md` §10's reading of it as a language limitation on captured closures.
- evidence: re-runnable: `printf '(data Box () (bx (f (-> I64 I64))))
(def compile-main (-> I64 I64) (lam (n) (case (bx (lam (x) x)) ((bx g) (g 7)))))' > /tmp/t.chiral && ORIG_DIR=/tmp bin/chirality compile /tmp/t.chiral` exits 1; binding the lambda to a def first exits 0. `lib/lowering/upper/closconv.chiral`, `.planning/FINDING-captured-closures-2026-08-30.md`, `.planning/USER-LAYER-GAP.md` §10
- checked:  2026-09-06
- owner:    none
- from:     FD-03

### PRB-50 whether to condense the five principles to "everything is a port boundary"

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    doc
- about:    PRINCIPLES.md
- claim:    the same finding proposes the boundary, not the process, as the atom, and shows each of P1-P5 reading as a case of it.
- measured: RE-MEASURED 2026-09-06: **unchanged in substance and still author-tier, with one citation that no longer resolves and one of the finding's two offered outcomes already taken.** `PRINCIPLES.md` still carries five principles, at `:23`, `:51`, `:76`, `:123` and `:149`, and nothing in it names the boundary as the atom. The 2026-09-04 pass at `32823ee` is the author's own and decided nothing here: it cut the seven-to-five crosswalk section entire and shortened the draft note to two lines, 2 insertions against 31 deletions. ⚑ **The `CLAUDE.md` citation has drifted off its target.** The root `CLAUDE.md` holds no doctrine under [[decisions/decision-ai-tier]] and states this rule nowhere. The sentence this row quotes is the finding's own at `.planning/FINDING-ports-role-2026-08-31.md:72-73`, and its tracked restatement is `docs/definitions/altitude-errors.md:197`. ⚑ **The finding's cheaper alternative was taken.** It offered a fork: earn the condensation by deciding two or three more open questions, or correct `MAP.md`'s sentence and leave the principles alone. `MAP.md:58-84` now carries the section ``ports/` holds declarations, not code about ports`` with the mint test the finding proposed, landed 2026-08-31 at `e1d0c91` and `0aefbc1`. The condensation itself stays untouched and unruled, which is what this row is about. The second half holds: `.planning/DOC-AUDIT-QUEUE.md:72` queues `PRINCIPLES.md` under the accuracy charter, and the three `PRINCIPLES.md` rows opened 2026-09-06 as `presentability/D4`, `D5` and `D6` carry accuracy claims about P1, P3 and P5. No entry anywhere asks whether the five are the right five.
- evidence: re-runnable: `grep -c '^## [1-5]\. ' PRINCIPLES.md` returns 5. `git show --stat 32823ee -- PRINCIPLES.md` reads 2 insertions, 31 deletions. `grep -c 'constrain' CLAUDE.md` returns 0 and `grep -n 'does not constrain is overhead' docs/definitions/altitude-errors.md` returns 197. `grep -n 'holds declarations, not code about ports' MAP.md` returns 58. `PRINCIPLES.md:23`, `:51`, `:76`, `:123`, `:149`; `MAP.md:58-84`; `.planning/FINDING-ports-role-2026-08-31.md:54-92`; `.planning/DOC-AUDIT-QUEUE.md:72`; `docs/arcs/presentability-arc.md:60`, `:87`; commits `32823ee`, `e1d0c91`, `0aefbc1`
- checked:  2026-09-06
- owner:    none
- from:     FD-06

### PRB-51 the secure-datum model's threat split is drawn in the wrong place

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    doc
- about:    docs/definitions/secure-datum-model.md
- claim:    `docs/definitions/secure-datum-model.md` §2 puts peripheral DMA **write** (tamper, replay/rollback) in scope and CPU code execution out of scope, and §1 says the register root "is unreachable by the threat".
- measured: on the stated hardware (no TPM, no IOMMU relied on) DMA write is arbitrary physical memory write, which is a routine path to CPU code execution: overwrite kernel text, a function pointer or a page-table entry. PCILeech, which §2 names as the in-scope tool, ships kernel implants that do exactly this. So the out-of-scope list is a consequence of a power the model grants rather than a power the attacker lacks, and the document's own §1 supplies the verdict, that N layers sharing one dependency collapse to one. What survives intact is the whole model against a **read-only** DMA adversary, the evil-maid and Thunderbolt-snapshot case: register root, derive-not-store, the interrupt-disabled window and every §4 confidentiality multiplier are sound there. Three edits are owed and none applied: split §2 into A_read and A_write with a guarantee per half, move write/tamper/rollback out of the confidentiality stack into an integrity section whose verb is *detect*, and say that A_write requires the IOMMU the document lists as optional.
- evidence: `docs/definitions/secure-datum-model.md` §1, §2, §4, `.planning/FINDING-datum-model-write-adversary-2026-08-31.md`
- checked:  2026-09-01
- owner:    none. Document-tier, not an element. If the split becomes a language obligation, that mints a row. ⚑ FD-07 is on the ownership-and-trust track, which is [[goals/ownership-and-trust]], deferred out of scope for *work* on 2026-08-31. The row is here because the document is in the reader-facing tier and is wrong today. Deferred is not deleted: `.planning/FINDING-datum-model-write-adversary-2026-08-31.md` stays where it is.
- from:     FD-07

### PRB-52 the demanded statement is prose, and the judgment's decomposition is unreached

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/typing/kernel-core.chiral
- claim:    [[certificate-discipline]] states that a certificate's one surviving vacuity is whether the demanded statement is meaningful, and pins it by fixing that statement at the socket as part of the small audited spec, so vacuity "lives in exactly one place ... one small thing audited once". [[decisions/decision-split-checker]] names `kernel-spec` as "the type theory as a small, human-audited requirement type" and one of the three parts the checker splits into.
- measured: RE-MEASURED 2026-09-06: unchanged. `lib/typing/kernel-core.chiral:28` still reads `(data SpecRule () (spec-rule (form JForm) (name Str) (statement Str)))`, so the artifact the whole certificate scheme's non-vacuity rests on is unstructured prose. `independent-judgment/J5` owns the fix and the arc rosters it.
- evidence: re-runnable: `grep -n spec-rule lib/typing/kernel-core.chiral` returns `:28` with `(statement Str)`. `lib/typing/reflect-floor.chiral:16`, `docs/definitions/certificate-discipline.md`
- checked:  2026-09-06
- owner:    none
- from:     FD-09

### PRB-53 the effect row is supplied to lowering rather than derived by it

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/upper/eff-lower.chiral
- claim:    [[decisions/decision-effect-facets]] states the row is "inferred by elaboration from the transitive closure of extern crossings in the call graph", a call-graph fact rather than a consequence of port-holding. `Sheet.crossings` is marked derived, naming WHICH crossings rather than whether, and E161 derives crossings with no surface production at all. So the third leg of the triple, what happens, is documented as never authored.
- measured: RE-CHECKED 2026-09-06: unchanged. `lib/lowering/upper/eff-lower.chiral:9-15` still names its two loader-derived inputs, and the row is handed in rather than derived by elaboration. on the lowering path it is authored, by being handed in. `lib/lowering/upper/eff-lower.chiral:9-15` says its two loader-derived inputs, `crossing_sigs` (the E51-bound port names) and `def_rows` (E39's inferred per-def effect rows), remain unported chirality-side, " (E39 row inference lives in the deferred E2-loader seam)", so the slice "takes them as GIVEN inputs" and "deriving them is deferred residue with an E2-loader / E51 home". The preserve-check itself is ported and real: re-derive the reached crossings from a lowered tal footprint and demand `reached <= declared`. What is missing is the `declared` side's provenance. The fallback when a def cannot lower is a prune rather than a refusal: `lib/lowering/compile-back.chiral:181-210` drops the function and records `sk-extern op` for a direct extern or `sk-callee cn` for the transitive case, iterated to a fixpoint (`lib/lowering/skip-diag.chiral`, E97). Two further gaps on the same path are DELIBERATE and fall outside this row: erased q=0 content never lowers (`lib/lowering/upper/lower.chiral:65,70`, `drop-erased-args` in `closconv.chiral:1177`), and the crossing floor is hand-authored tal that never came from upper (`lib/lowering/tal/sys.chiral`, 1343 L of `TIFn` values, whose header states the membrane argument: "lowered pure code has no surface path to ti-sys/ti-bptr").
- evidence: `lib/lowering/upper/eff-lower.chiral:1-17`, `lib/lowering/compile-back.chiral:181-210`, `lib/lowering/skip-diag.chiral:11`, `lib/lowering/tal/sys.chiral:1-12`, `docs/decisions/decision-effect-facets.md`, `lib/module/loader.chiral:280`
- checked:  2026-09-06
- owner:    none
- from:     FD-10

### PRB-54 Lane A's reserved gate phases were spent by other arcs

- state:    FIXED
- author:   unreviewed
- note:     none
- level:    source
- about:    docs/decisions/decision-lane-split.md
- claim:    `docs/decisions/decision-lane-split.md:30` reserves gate phases **18, 19, 20** for Lane A and **21, 22, 23** for Lane B, and `:33-35` says phases 1-7 and 13-17 are taken while 8-12 are names owed to unported old-tree phases that must never be reused.
- measured: **FIXED 2026-09-06 by the phase-number ruling.** The row measured Lane A's reserved 18, 19 and 20 spent by other arcs: 18 is `pretty.sh` (E181, Lane A's own), 19 is `matcher.sh` (E173, text-tools) and 20 is `transport.sh`. All three still read that way. The defect was the RESERVATION, and reservations no longer exist: `run-tests.sh` is the only authority and a gate takes the first number colliding with nothing, which is how 25 through 31 were allocated.
- evidence: re-runnable: `grep -E '^run_phase (18|19|20) ' tools/test/run-tests.sh`. `docs/decisions/decision-lane-split.md`, `tools/test/run-tests.sh`
- checked:  2026-09-06
- owner:    E182 took Phase 24 and moved on. Whether Lane A gets a fresh reservation is an author call
- from:     FD-11

### PRB-55 the harness that audits the gates has no phase in the gate

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    tools/test/run-tests.sh
- claim:    `tools/test/mutant.sh:1-45` is the run-the-mutant rule made mechanical, and `docs/definitions/testing-floors.md:287` binds every gate row to a mutant that is RUN.
- measured: RE-MEASURED 2026-09-06: still true for `mutant.sh`, and the surrounding count moved. `run-tests.sh` now carries **21** dispatch lines against 13 when this row was written, and none names `mutant.sh`. It declares `not-a-phase:` as a sourceable library plus a matrix driver a person runs by hand, which is a structural reason rather than a pending number.
- evidence: re-runnable: `grep -c '^run_phase' tools/test/run-tests.sh` returns 21; `grep -n mutant.sh tools/test/run-tests.sh` returns nothing
- checked:  2026-09-06
- owner:    none
- from:     GA-01

### PRB-56 profile-target.sh licenses one of its 31 rows

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    tools/test/profile-target.sh
- claim:    `tools/test/profile-target.sh:6-12` says the point of its cases is the REFUSALS, and that a parser accepting everything freezes nothing.
- measured: `bash tools/test/profile-target.sh` reports **31 passed, 0 failed** in 1.85 s. Nine rows are positive, twenty-two are refusals. The script declares zero mutants of its own: it has no `mutant`, `poison` or scratch-tree helper anywhere. One declared mutant in `mutant.sh` reaches it, `port-purity-off`, and running it turns exactly **one** row red, `port is PURE (does not cross)`, leaving 30 passed. So 30 of the 31 rows have no run falsifier anywhere in the tree, and GA-03 is one measured consequence. ⚑ RE-MEASURED 2026-09-05 and PARTLY CLOSED, which is not closed. `ba62549` gives `profile-target.sh` a mutant block, three new rows and three mutants, so the count is 23 of 34 rows reddened by something, where it was 1 of 31. The count is honest and the coverage is not what the count looks like. TWENTY of the twenty-three come from ONE COARSE MUTANT, `known-clause-refuses-all`, which makes no profile clause head recognisable and reddens seven positives and thirteen refusals together. What that establishes is that those rows RUN and that the manifest path is load-bearing. It does not establish that any one row's own message is what holds it up. The two discriminating mutants redden one row each, `port-purity-off` and `total-clause-dead`. ELEVEN ROWS ARE REDDENED BY NOTHING: `target with one requirement`, `target with several requirements`, `profile with one clause`, `profile name is not a symbol`, and the seven `top_target` refusals. LEFT OPEN on the churn, measured rather than guessed: each of the eleven wants its own message-rename mutant and its own compiler build, eleven builds at about 2.4 s plus eleven legs at about 2 s, on a phase that cost 2 s before this block and 27 s after it. The residue is named at the head of the file's own mutant block, so the next author reads it there instead of rediscovering it.
- evidence: `tools/test/profile-target.sh:6-12`, `:57-121`; `tools/test/mutant.sh:192-195`; after the partial repair `tools/test/profile-target.sh:196-205`, `:268-278`
- checked:  2026-09-05
- owner:    none
- from:     GA-04

### PRB-57 the profile's memory discipline is stored and read nowhere

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/surface/parse.chiral
- claim:    `tools/test/profile-target.sh:8` documents the manifest form as `(profile name (ports p...) (target t) [(memory d)] [(total)])` and four of its rows exercise `(memory ...)`: two positives, `unknown memory discipline gc`, and `malformed (memory)`.
- measured: RE-MEASURED 2026-09-06: unchanged in shape. `mk-profile` appears in four modules, one construction at `lib/surface/parse.chiral` and destructurings in `lib/typing/kernel.chiral` (2), `lib/typing/totality-check.chiral` and `lib/lowering/compile-front.chiral`. The memory discipline the profile carries is stored and no consumer reads it, so `(memory linear|region)` parses, validates and changes nothing.
- evidence: re-runnable: `grep -rc 'mk-profile' --include='*.chiral' lib/ prog/` returns four nonzero files. `lib/surface/parse.chiral`, `lib/typing/kernel.chiral`
- checked:  2026-09-06
- owner:    none
- from:     GA-08

### PRB-58 four phase scripts have no dispatch line

- state:    FIXED
- author:   unreviewed
- note:     none
- level:    source
- about:    tools/test/run-tests.sh
- claim:    `docs/definitions/testing-floors.md:69` records `tools/test/tal-check.sh` as unregistered in `run-tests.sh` by decision, on the `crypto.sh` precedent, so the suite's 339 excludes it.
- measured: **FIXED 2026-09-06.** This row measured eighteen scripts against thirteen dispatch lines, five outside. The tree now holds **26 scripts and 21 dispatch lines**, and the six outside are `run-tests.sh` itself, `registration.sh`, `mutant.sh`, `opt-census.sh`, `map-integrity.sh` and `tal-check.sh`. The first five declare out for structural reasons and `tal-check.sh` stays out on the open G18 question (PRB-70). Every gate that was waiting on a phase number registered at 25 through 31 under the native-tests ruling.
- evidence: re-runnable: `bash tools/test/registration.sh` reads 9 passed, 0 failed at 21 dispatch lines
- checked:  2026-09-06
- owner:    none
- from:     GA-10

### PRB-59 `prog/resolve.prog` has no consumer and fifteen shell files use the bash resolver

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    prog/resolve.prog
- claim:    `docs/elements/catalog.md:117` (E87) reads that two providers are "pinned against each other and both live": `bin/chirality-resolve.sh`, the one the build rule uses, and `lib/module/resolve.chiral`, imported by `prog/resolve.prog` and `lib/evidence/test-floor.chiral`.
- measured: RE-MEASURED 2026-09-06: still true, and the shell count grew. `grep -rIn 'resolve\.prog'` outside the file itself returns **2** hits, both prose, so nothing executes it. Meanwhile **25** files under `tools/` and `bin/` source `bin/chirality-resolve.sh`, against the fifteen this row recorded. The chirality provider is live as a library and dead as a tool, and the shell one it would replace is reached more widely than when this was written.
- evidence: re-runnable: `grep -rIn 'resolve\.prog' --include='*.sh' --include='*.chiral' --include='*.prog' .` returns 2 prose hits; `grep -rl 'chirality-resolve' tools/ bin/ | wc -l` returns 25. `prog/resolve.prog:1-20`, `bin/chirality-resolve.sh`
- checked:  2026-09-06
- owner:    none
- from:     TC-03

### PRB-60 `prog/paren-audit.prog` has no consumer and the Python it replaces is live

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    prog/paren-audit.prog
- claim:    `prog/paren-audit.prog:10` reads that it is a port of `tools/paren-audit/paren-audit.py` (154 LOC), wave 0 of the zero-python arc.
- measured: `prog/paren-audit.prog` is 244 lines and nothing invokes it. `tools/paren-audit/paren-audit.py` is 154 lines and still on disk. `tools/README.md:12` records the Python as running unchanged with equivalence against the chirality replacement **unverified**, so it is not retired and not deletable. `docs/goals/self-tooling.md:67-68` and `docs/arcs/zero-python-arc.md:97-99` carry the same. Its usage line, `prog/paren-audit.prog:7`, needs a directory walk it does not have: `find lib prog -name '*.chiral' | chirality run prog/paren-audit.prog`. The differential run that would retire the Python has never been taken.
- evidence: `prog/paren-audit.prog:1-10`; `tools/paren-audit/paren-audit.py:1-12`; `tools/README.md:12`; `docs/arcs/zero-python-arc.md:97-99`
- checked:  2026-09-04
- owner:    none
- from:     TC-04

### PRB-61 `lib/text/matcher.chiral` is 602 lines and three documents say 533

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    docs/arcs/text-tools-arc.md
- claim:    `docs/arcs/text-tools-arc.md:87`, `docs/definitions/status-ledger.md:165` and `docs/goals/local-ai.md:103` each record `lib/text/matcher.chiral` at **533 lines**.
- measured: RE-MEASURED 2026-09-06: unchanged. `wc -l lib/text/matcher.chiral` returns **602**, the same figure this row recorded, so the file has not moved since `9f46c6c` and the three documents citing smaller line counts are still stale against it.
- evidence: re-runnable: `wc -l lib/text/matcher.chiral` returns 602. `lib/text/matcher.chiral`
- checked:  2026-09-06
- owner:    none
- from:     TC-05

### PRB-62 `lib/` has a content hash, and the planned kernel is BLAKE2s

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/protocol/apc.chiral
- claim:    the dispatch for this pass read that there is no hash anywhere in `lib/`, and that a native hash would replace the gate tier's `sha256sum` calls.
- measured: both halves need correcting. `lib/protocol/apc.chiral:122-130` defines `fnv1a-go`, `fnv1a` and `hex16`, an FNV-1a-64 content hash rendered as 16 hex characters, and `:141-147` uses it as `block-id`, the content address on every `r-section` and `r-hole`; `:227` and `:244` re-verify it on decode. It is a content hash and it is not cryptographic, which is the distinction the claim wanted. Separately, the planned cryptographic kernel is **BLAKE2s** rather than SHA-256: `docs/elements/specs/N01-crypto-kernels-SPEC.md:181` is "Step 3: BLAKE2s (slice 3)" and `docs/arcs/native-protocol-arc.md:60` records slices 1 and 2 built and gated with 3 and 4 open. The five pin sites are 1b rather than bucket 3, because the independence axis is the building binary and only the hash is missing.
- evidence: `lib/protocol/apc.chiral:122-147`, `:227`, `:244`; `docs/elements/specs/N01-crypto-kernels-SPEC.md:181`; `docs/arcs/native-protocol-arc.md:60`
- checked:  2026-09-04
- owner:    none
- from:     TC-06

### PRB-63 three written gate scripts have no dispatch line

- state:    FIXED
- author:   unreviewed
- note:     none
- level:    source
- about:    tools/test/run-tests.sh
- claim:    `tools/test/crypto.sh:6-8` and `tools/test/tal-check.sh:11-15` each read NOT YET REGISTERED, with the `run_phase` line owed to the suite-owning session. `tools/test/map-integrity.sh:7-8` reads that it is not a suite phase.
- measured: **FIXED 2026-09-06.** The three written-but-undispatched gates this row named are dispatched: `crypto.sh` at phase 31, and the E185 to E188 gates at 25 through 28. `run-tests.sh` carries 21 dispatch lines against the thirteen this row counted, and the full suite reads 412 assertions passed, 0 failed with them in.
- evidence: re-runnable: `grep -c '^run_phase' tools/test/run-tests.sh` returns 21; `tools/test/run-tests.sh` reads `gate PASSED`
- checked:  2026-09-06
- owner:    none
- from:     TC-07

### PRB-64 gate phases 21 and 22 are allocated twice

- state:    FIXED
- author:   unreviewed
- note:     none
- level:    source
- about:    docs/decisions/decision-lane-split.md
- claim:    `docs/decisions/decision-lane-split.md:30` reserves gate phases **21, 22, 23** for Lane B, which owns E146, E163 and E183. `tools/test/run-tests.sh:332` repeats it: "21-23 are Lane B's".
- measured: **FIXED 2026-09-06.** The row measured 21 and 22 allocated twice: `tal-check.sh` claiming 22 in its header while `crypto.sh` claimed 21, neither dispatched. `grep -E '^run_phase (21|22|23) '` now returns **nothing**: no gate holds any of the three. `crypto.sh` registered at phase 31 and `tal-check.sh`'s phase-22 claim is retired in its own header, which is the file that carried the contradiction.
- evidence: re-runnable: `grep -E '^run_phase (21|22|23) ' tools/test/run-tests.sh` returns nothing; `bash tools/test/registration.sh` reads 9 passed, 0 failed. `tools/test/tal-check.sh:3-11`, `tools/test/crypto.sh:6`
- checked:  2026-09-06
- owner:    none
- from:     TC-08

### PRB-65 map-integrity.sh's stated reason for exclusion has been false since 2026-09-01

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    tools/test/map-integrity.sh
- claim:    `tools/test/map-integrity.sh:7-8` reads "Not a suite phase: the map lives under `.planning/`, which is not tracked, so a fresh checkout has no map to check."
- measured: RE-MEASURED 2026-09-06: still true, and the count moved. `tools/test/map-integrity.sh:7-8` still states the map lives under `.planning/`, "which is not tracked, so a fresh checkout has no map to check". `git ls-files .planning | wc -l` returns **162**, against the 147 this row recorded, and `.planning/` has been tracked since 2026-09-01 by `decision-ai-tier`. The stated reason for the exclusion has been false for five days.
- evidence: re-runnable: `git ls-files .planning | wc -l` returns 162. `tools/test/map-integrity.sh:7-8`, `docs/decisions/decision-ai-tier.md`
- checked:  2026-09-06
- owner:    none
- from:     TC-09

### PRB-66 288 gate-tier calls are blocked on a criterion nobody has written

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/evidence/ddc.chiral
- claim:    `docs/goals/enforcement.md:41-45` and `docs/arcs/enforcement-arc.md:84-88` read that some of the tooling surface is correct and stays, because a comparator holding constants cannot be fooled by a mutated compiler, and that over-claiming that bucket replaces a safety property with a dependency.
- measured: RE-MEASURED 2026-09-06 and the census moved with the tree. `grep -hoE '(^|[|;( ])(grep|sed|awk|sort)' tools/test/*.sh` now counts **421** call sites against the 506 this row recorded, and **38** of them are in `tools/test/matcher.sh`, whose subject is the module a matcher would replace. The shape holds: the irreducible bucket is a small fraction and not "the gate tier". `enforcement/N10` now owns the replacement, opened 2026-09-06 on the native-harness ruling.
- evidence: re-runnable: `grep -hoE '(^|[|;( ])(grep|sed|awk|sort)' tools/test/*.sh | wc -l` returns 421; the same over `matcher.sh` returns 38. `lib/evidence/ddc.chiral:207-213`, `docs/definitions/open-edges.md:672`
- checked:  2026-09-06
- owner:    none
- from:     TC-12

### PRB-67 the reference tal interpreter is the tree's strongest formulation asset and no arc rows it

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/tal/eval.chiral
- claim:    `docs/arcs/independent-judgment-arc.md:38-42` lists what is in the tree already for the independence axes: `lib/evidence/ddc.chiral` at 213 lines with 1 importer, `lib/typing/kernel-core.chiral` at 60 lines with 0, and `lib/typing/reflect-floor.chiral` at 54 lines with 0.
- measured: RE-MEASURED 2026-09-06: unchanged and still omitted. `lib/lowering/tal/eval.chiral` is **187 lines with zero importers** and `:1-2` describes it as the reference tal interpreter. The arc's own table at `docs/arcs/independent-judgment-arc.md` lists `ddc.chiral` (213 lines, 1 importer), `kernel-core.chiral` (60, 0) and `reflect-floor.chiral` (54, 0), and omits the strongest member. ⚑ The arc names the omission in its prose at `:125` and has never put it in the table.
- evidence: re-runnable: `wc -l lib/lowering/tal/eval.chiral` returns 187; `grep -rl 'lowering/tal/eval' --include='*.chiral' lib/ prog/` returns nothing. `lib/lowering/tal/eval.chiral:1-20`, `docs/arcs/independent-judgment-arc.md:125`
- checked:  2026-09-06
- owner:    none
- from:     TC-13

### PRB-68 the surface figures started drifting the day they were taken

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    doc
- about:    records/tooling-classification.md
- claim:    the table above and both goal-tier documents read a gate tier of **6,915** lines and **12,450** lines outside the language, measured 2026-09-04 against `dda00b9`. This file's scope paragraph read **122** gate-tier `grep` invocations.
- measured: RE-MEASURED 2026-09-06: **the drift this row named has widened, and the gap is now larger than the original figure.** Taking the table's own tiers again today: the gate tier `tools/test/*.sh` is **26 files at 10,744 lines** where the table carries 18 at 6,915; Python under `tools/` is **10 files at 6,664** where it carries 9 at 4,786; `tools/prose-lint/prose-lint.sh` at **223** and `bin/chirality` plus `bin/chirality-resolve.sh` at **526** are both unchanged. The surface outside the language is therefore **39 files at 18,157 lines**, against the **12,450** that `records/tooling-classification.md:52-59`, `docs/goals/enforcement.md:47-48` and `docs/arcs/enforcement-arc.md:249-252` still carry, and against the **12,671** `docs/arcs/enforcement-arc.md:232` corrected to on 2026-09-05. Native `.prog` tooling holds at **782** over the same five files, so the whole move is on the outside half. **The third drift is repaired**: the scope paragraph reads 119 at `records/tooling-classification.md:38-46`. **The second drift cannot be re-taken.** It rested on an independently written call-site scanner, and `records/tooling-classification.md:48` records that the scanner was a session script and is not tracked, so 506 against 504 stands where this row left it. **Nothing here is a defect in any original count.** Each figure was true when taken and the target moves under it, which is the class this row exists to name.
- evidence: re-runnable: `ls tools/test/*.sh | wc -l` returns 26 and `cat tools/test/*.sh | wc -l` returns 10744; `find tools -name '*.py' | wc -l` returns 10 and `find tools -name '*.py' | xargs wc -l | tail -1` returns 6664; `wc -l tools/prose-lint/prose-lint.sh bin/chirality bin/chirality-resolve.sh` returns 223, 220 and 306. Their sum is 18,157 against the 12,450 in the table. `records/tooling-classification.md:52-59`, `:38-48`; `docs/goals/enforcement.md:47-48`; `docs/arcs/enforcement-arc.md:232`, `:249-252`
- checked:  2026-09-06
- owner:    none
- from:     TC-14

### PRB-69 most record rows name no command that re-runs their measurement

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    doc
- about:    records/README.md
- claim:    records/README.md, Evidence is mandatory: "`evidence:` names files and line spans. A row nobody can re-run is worthless."
- measured: **RE-MEASURED 2026-09-06: 66 rows name a command, against 30 when this row was filed.** 125 still carry file:line only. The 36 that moved were closed by writing the instrument rather than the number: `ledger-lint --census` for the span counts, printf-and-run fixtures for the compile probes, and named gates for the rest. ⚑ The single biggest remaining block is the TFn census, which three rows rest on and which is now buildable as `enforcement/N12`. ORIGINAL READING: measured 2026-09-05 over every live row in records/ and records/lenses/: **123 of 153 carry file:line evidence and name no command**. 30 name a re-runnable one (a tools/test gate, a python3 tool, git ls-files, find). A file:line span shows WHERE a thing was seen and does not reproduce the NUMBER: PRB-43 claims 1,475 of 1,481 TFns accept under two checker relaxations, and no gate in tools/test/ reproduces that census, so check AI can say the row is unverified and nobody can say what it reads today. This is why 60 AI findings cannot be closed by reading.
- evidence: records/README.md, tools/test/tal-check.sh (the nearest gate, which measures 20 ok 1 FAIL and not the census), records/lenses/problems.md
- checked:  2026-09-06
- owner:    enforcement/N12 for the census; the rest is per-row
- from:     none

### PRB-70 G18 is a true positive: check.chiral entered the compiler closure

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    tools/test/tal-check.sh
- claim:    tools/test/tal-check.sh G18 asserts `lowering/tal/check is OUTSIDE the compiler blob`, and its own comment says: "If it ever goes red, check.chiral has entered the blob and the BUILD RULE's build-new -> test -> promote applies to every edit of it."
- measured: **IT WENT RED AND THE PREMISE HAS FLIPPED.** Measured 2026-09-06 on a blob built to its fixpoint: `grep -c 'def ck-prog'` returns **1**, and `lib/lowering/upper/optimize.chiral:17` and `lib/lowering/upper/eff-lower.chiral:20` both `(import "lowering/tal/check")`. So check.chiral is inside the closure and every edit to it owes the build rule. ⚑ **Present is not called.** `grep -rn '(ck-prog'` over lib/ and prog/ returns zero call sites outside its own definition, so the floor checker sits at SEEDED: compiled in, reached by nothing. That is enforcement requirement 2 half-moved, not met. G18 needs inverting to assert what the tree now wants, and the mutant harness below it assumes a scratch lib/ on the old premise.
- evidence: tools/test/tal-check.sh:399-406, lib/lowering/upper/optimize.chiral:17, lib/lowering/upper/eff-lower.chiral:20, lib/lowering/tal/check.chiral
- checked:  2026-09-06
- owner:    enforcement/N8
- from:     none

### PRB-71 sock-send-fd is missing from crossing-wraps and nothing reaches a screen

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/tal/crossing-wraps.chiral
- claim:    lib/lowering/tal/crossing-wraps.chiral carries one entry per lowered crossing, and prog/demo/ is described as running.
- measured: `grep -c sock-send-fd` over crossing-wraps returns **0** while `prog/demo/wl-client.chiral:201` calls it and two profiles declare it in their port sets (`profile-tomodachi.chiral:31`, `profile-node-render.chiral:14`). A declared crossing with no wrapper entry does not lower, so **nothing in this tree reaches a screen**. It went unnoticed because no gate reads `prog/demo/`.
- evidence: lib/lowering/tal/crossing-wraps.chiral, prog/demo/wl-client.chiral:201, prog/demo/profile-tomodachi.chiral:31, prog/demo/profile-node-render.chiral:14
- checked:  2026-09-06
- owner:    native-window/W5
- from:     none
