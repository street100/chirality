

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
- measured: RE-MEASURED 2026-09-05, unchanged: `find . -name '*.profile'` outside `.git` returns nothing. Zero files. Grepping `bin/` and `tools/test/run-tests.sh` for `.profile` returns three hits and all three are the prose that excludes it from probing. Nothing in the build reads one. The `(profile ...)` form that is actually used is a top-level clause inside a `.chiral` file, parsed at `lib/surface/parse.chiral:717`, which is a different thing from the extension. RE-VERIFIED 2026-09-07 after `MAP.md` gained a `docs/translations/` row: the insertion lands at `:144`, below both cited lines, and `MAP.md:12` and `:23` read exactly as quoted. Substance unchanged.
- evidence: `MAP.md:12`, `MAP.md:23`, `bin/chirality-resolve.sh:51`, `lib/surface/parse.chiral:717`
- checked:  2026-09-07
- owner:    none
- from:     BA-10

### PRB-07 "The two binaries" names one binary and one shell script

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    doc
- about:    MAP.md
- claim:    `MAP.md` has a section titled "The two binaries" naming `bin/chirality` as the CLI front door and `bin/chirality-bin` as the compiler.
- measured: `git ls-files bin/` returns three files. `bin/chirality` is a bash script, `bin/chirality-resolve.sh` is a bash library, and `bin/chirality-bin` is the one committed binary. RE-MEASURED 2026-09-05: **12** top-level `.prog` roots under `prog/` and **102** `.prog` files in total. ⚑ The 6 and the 96 this row carried were taken 2026-09-01 and both grew; the shape it names did not change. `bin/chirality` has no `build` subcommand: the build-new, test, promote rule lives only as prose in CLAUDE.md. RE-VERIFIED 2026-09-07 after `MAP.md` gained a `docs/translations/` row: the insertion lands at `:144`, below the cited span, and `MAP.md:89-92` still carries `The two binaries` with both entries. Substance unchanged.
- evidence: `MAP.md:89-92`, `bin/chirality:210-219`
- checked:  2026-09-07
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
- measured: RE-MEASURED 2026-09-07: **still true, the count held, and both gate citations drifted.** `lib/` and `prog/` comments carry **75** line-numbered citations across **35** files, the same figure taken 2026-09-06 and up from the 59 across 34 this row opened with. `check_g` moved from `:379` to `:407` and `check_r` from `:443` to `:471`, +28 lines each under the `Owed` class `d5b8fad` inserted at `:106`; `git diff d5b8fad^ HEAD` touches neither function body. Both still iterate `doc_tier()` at `:174`, which walks `docs/**/*.md` and nothing else, and both still require the citation inside a backtick code span, so not one of the 75 is read by any gate. AK, the one check added since this row was last measured, reads `records/author-calls.md` and widens the corpus by nothing.
- evidence: re-runnable: `grep -rhoE '[a-z0-9_/-]+\.(chiral|prog):[0-9]+' --include='*.chiral' --include='*.prog' lib/ prog/ | wc -l` returns 75, and the same with `-rl` returns 35. `tools/ledger-lint/ledger-lint.py:407` (check G), `:471` (check R), `:174` (`doc_tier`, the docs-only walk both use); commits `d5b8fad`, `e3ecd85`
- checked:  2026-09-07
- owner:    none
- from:     BA-19

### PRB-11 294 doc citations name a path that does not exist

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    tools/ledger-lint/ledger-lint.py
- claim:    the migration is complete and the map records where each original went.
- measured: **RE-MEASURED 2026-09-07: the figure that matters held and the corpus gained two.** `ledger-lint --census` reports **4,655 line-numbered spans and 3,063 resolving to a file on disk**, so **1,592 do not resolve**, the same 1,592 measured 2026-09-06 against 4,653 and 3,061. Neither commit touched the instrument: the tool at `d5b8fad^` prints the identical census over this tree, and `git diff d5b8fad^ HEAD` leaves `_find_src` and `check_g` alone. `_find_src` drifted from `:369` to `:397`, +28 lines under the new `Owed` class at `:106`. The class is unchanged: pre-migration paths (`scaffold/lib/...`, `chirality/...`) and basenames whose file was deleted, which G and R skip by design so the gate stays silent on them. ⚑ `docs/goals/presentability.md:96-97` still states the 294 and LIM-06's 161 as live figures, in a document this row may not edit. Reported and left standing.
- evidence: re-runnable: `python3 tools/ledger-lint/ledger-lint.py --census` prints 4655 spans and 3063 resolving. The same run against `git show d5b8fad^:tools/ledger-lint/ledger-lint.py` prints the identical figures. `tools/ledger-lint/ledger-lint.py:397` (`_find_src`), `.planning/MIGRATION-MAP.tsv`, `docs/goals/presentability.md:96-97`; commits `d5b8fad`, `e3ecd85`
- checked:  2026-09-07
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
⚑ **STILL TRUE, and it now has a definition and an owner, 2026-09-08.** Re-measured today: `ck-prog` and `ck-block` resolve only inside `lib/lowering/tal/check.chiral`, and `ck-fn`'s single caller outside that module is the gate probe `prog/optimizer-census.prog:78`. ⚑ **What changed is what would satisfy it.** `docs/decisions/decision-preserve-check.md` settles that `ck-prog` is neither rung of a preserve-check, because both its arguments are target-level ([[records/findings]] FD-20), so giving it a call site is a smaller thing than this row's title suggests and does not discharge the floor. `enforcement/N8` carries the call site and `enforcement/N13` carries the rung. ⚑ **This row's own `evidence:` already named `enforcement/N8` before the roster row existed to be named.**
- evidence: re-runnable: `grep -rn '(ck-prog\|(ck-block' --include='*.chiral' lib/` returns hits only in `lowering/tal/check.chiral`. `enforcement/N8`
- checked:  2026-09-06
- owner:    enforcement/N8
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

- state:    FIXED
- author:   unreviewed
- note:     none
- level:    doc
- about:    docs/banks/profile.md
- claim:    `docs/banks/profile.md:246` cites `chirality verify` to argue that the profile conformance gap is already covered.
- measured: RE-MEASURED 2026-09-07: FIXED, and the cited line drifted. `f4364d3` (2026-09-04, "profile bank: there is no verify, and the conformance check it named is gone") rewrote Shard G. The bank's one bare `chirality verify` now sits at `docs/banks/profile.md:198` inside a build-state marked "partly present, corrected 2026-09-04" that records the absence and repoints at `chirality check FILE` (`:161`). The cited `:246` region now carries a cross-cut naming the `chirality-verify` requirement type, a hyphenated name in the profile language and no subcommand. The floors half moved with it: `docs/definitions/testing-floors.md:10-18` was rewritten 2026-09-04 into a note stating that `chirality test-native`, `chirality test-rocq`, `chirality test-python` and `chirality verify` name nothing, `rocq/` is still absent, and the table now carries a single GATING row which reaches `chirality test`. So the bank no longer refutes the gap. The wider count is not this row's: 29 bare uses of the phantom subcommand survive across `docs/`, `bin/`, `lib/`, `prog/` and `tools/`, one of them the bank's own corrective sentence, and `presentability/D3` owns retiring them.
- evidence: re-runnable: `grep -n 'chirality verify' docs/banks/profile.md` returns one hit at `:198`, the corrective sentence; `grep -n 'test-rocq' docs/definitions/testing-floors.md` returns only `:16`, inside the note that says the name resolves to nothing; `grep -c GATING docs/definitions/testing-floors.md` returns 1
- checked:  2026-09-07
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
- evidence: `lib/prelude/prelude.chiral:83`, `lib/prelude/string.chiral:14`, `:17`, `.planning/FINDING-str-sub-range-2026-08-31.md:12`
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
- measured: RE-MEASURED 2026-09-07: unchanged in shape, and the SPEC's three line citations drifted by one. `HANDOFF-DIAGNOSTICS-ARC.md` is still absent from the working tree and from `git ls-files`. Six citations of it survive, three per artifact. The example holds at `:188` (the blob-size quote), `:199` (a binding decision) and `:661` (the empty-`cmp` trap). The SPEC moved to `:455` (the status table and Lane A queue), `:466` (a promotion step) and `:682` (the chain and the arc's binding decisions), one line past the `:454`, `:465`, `:681` this row recorded, after `b08d94f` (2026-09-04) repointed sixteen other citations across nine docs and left these six alone. Still not repaired, and for the reason first recorded: both artifacts are frozen-rationale tier and `records/consolidation-handoff.md` §2 binds this class to record-do-not-chase, the same stance BA-22 takes for the other 34.
- evidence: re-runnable: `grep -c HANDOFF-DIAGNOSTICS-ARC docs/examples/E181-pretty-term-doc.md docs/elements/specs/E181-pretty-term-doc-SPEC.md` returns 3 and 3, and `git ls-files | grep HANDOFF-DIAGNOSTICS` returns nothing. `records/consolidation-handoff.md`
- checked:  2026-09-07
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
- measured: RE-MEASURED 2026-09-06: **CONFIRMED, unchanged in substance, and the ledger citation has drifted 33 lines.** The SEEDED **Refinement types** row now sits at `docs/definitions/status-ledger.md:188`; `:155` holds a different row. Its text is verbatim what this row quotes, path-sensitivity over a constant and over a bare in-scope variable, with `a comparison-guarded branch learns the bound it proves`, and it still closes by recording that no phase exercises the refinement fragment. **The refusal reproduces in the fixture that surfaced it.** Substituting the inline spelling for the `max` call at `tools/test/samples/e173_matcher.prog:110` makes the file fail `bin/chirality check` at **exit 1** with `load: cannot prove refinement`, while the unmodified fixture passes at exit 0. Reduced to two parameters, `(def mx (-> I64 I64 I64) (lam (hi sz) (let ((hi2 (case (<i hi sz) (true sz) (false hi)))) hi2)))` fails identically, and the same `case` returned directly as the body of the `let` passes at exit 0, so FD-02's condition list holds unchanged. `lib/prelude/prelude.chiral:153` still declares `(def max (-> I64 I64 I64)` and the E173 fixture still routes through it. `lib/typing/refine.chiral` is unmoved. One workaround citation drifted: the e173 comment spans `:100-105` with `mx-go` at `:106-118`, where this row cited `:100-107`. `prog/paren-audit.prog:103-107` is exact. PRB-48 re-measured the two-line-minimum half of the same family on 2026-09-06 and confirmed it. The tension this row states is untouched, and FD-02's three coherent fixes still make it a blueprint before a patch.
- evidence: re-runnable: `grep -n 'Refinement types' docs/definitions/status-ledger.md` returns 188. A file holding `(import "prelude/prelude")` then `(def mx (-> I64 I64 I64) (lam (hi sz) (let ((hi2 (case (<i hi sz) (true sz) (false hi)))) hi2)))` fails `bin/chirality check` at exit 1 with `load: cannot prove refinement`; the same def with the outer `let` dropped, returning the `case`, passes at exit 0. `bin/chirality check tools/test/samples/e173_matcher.prog` exits 0, and the same file with `(max hi (length Thread ts1))` at `:110` rewritten to the inline `case` exits 1. `docs/definitions/status-ledger.md:188`, `lib/typing/refine.chiral`, `lib/prelude/prelude.chiral:153`, `tools/test/samples/e173_matcher.prog:100-105`, `:106-118`, `prog/paren-audit.prog:103-107`, `records/findings.md` FD-02
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
- measured: RE-MEASURED 2026-09-06: **every leg of this claim is repaired, the residue it left is closed, and the row stops being a defect.** The orchestration-substrate row has moved from `docs/definitions/status-ledger.md:149` to `:182`, and it no longer gives the crossing-table gap as its reason. It now records that `http-request` and `chat-open` are chirality defs over the socket caps since E130 and E131, that `backend-open` stays an extern and erases to `nb-id` under the E144 string carrier, and that every other extern under `lib/protocol/` and `prog/prapanca/` erases or crosses, citing `BA-42` and [[arcs/transport-arc]] by name. The owed table at `docs/goals/local-ai.md:116` carries the same correction, landed at `84fbcfb` on 2026-09-02. `.planning/LOCAL-AI-ARC-REALIGNMENT.md:10-17` carries an **Acted on 2026-09-02** banner naming `BA-42` as the corrected reading, over a section 3A body at `:64-65` that still reads the three-name gap. Every source measurement holds: `lib/protocol/http.chiral:437` and `:773`, `lib/lowering/tal/erase.chiral:123`, `prog/prapanca/backend.chiral:37`, and a grep of `lib/lowering/tal/crossing-wraps.chiral` for the three names returns **0**. ⚑ **The row's own conclusion, that no phase performs a model call, is refuted.** Phase 20 landed at `d7d7cfe` on 2026-09-02 as `tools/test/transport.sh`, dispatched at `tools/test/run-tests.sh:324`, and reads **`transport: 5 passed, 0 failed, 0 deferred`**: three hermetic and hard-gated rows, two endpoint-bound against `100.64.0.5:11434`, which answered. The floor is green at `assertions: 412 passed, 0 failed`, 93 roots, gate PASSED. `arcs/transport-arc` records `T1` built for the document repair and `T2` for the phase. ⚑ Two stale traces are left standing in documents this row may not edit, and are reported: `docs/definitions/status-ledger.md:194` still calls the three `Secret` externs the same shape as `http-request` and `backend-open` in the row above, which the row above has stopped describing, and `records/author-calls.md:210` still gives the transport arc's job as giving all three a runtime referent.
- evidence: re-runnable: `grep -n 'Orchestration substrate' docs/definitions/status-ledger.md` returns 182. `grep -c 'http-request\|backend-open\|chat-open' lib/lowering/tal/crossing-wraps.chiral` returns 0. `grep -n '(def http-request$\|(def chat-open$' lib/protocol/http.chiral` returns 437 and 773. `bash tools/test/transport.sh` exits 0 at `transport: 5 passed, 0 failed, 0 deferred`, with the two endpoint-bound rows deferring when `100.64.0.5:11434` is silent. `bash tools/test/run-tests.sh` exits 0 at `assertions: 412 passed, 0 failed`. `docs/definitions/status-ledger.md:182`, `:194`, `docs/goals/local-ai.md:116`, `.planning/LOCAL-AI-ARC-REALIGNMENT.md:10-17`, `:64-65`, `lib/lowering/tal/erase.chiral:123`, `prog/prapanca/backend.chiral:37`, `tools/test/run-tests.sh:324`, `records/author-calls.md:210`, commits `84fbcfb`, `d7d7cfe`
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

- state:    FIXED
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/upper/optimize.chiral
- claim:    `records/lane-a-record.md:149` says `lowering/upper/optimize` "holds the only `ck-fn` call in the tree, at `:250`".
- measured: RE-MEASURED 2026-09-06: the refutation holds and the sites moved. `(ck-fn ` now resolves to three places: `lib/lowering/upper/optimize.chiral:250` (the `re-check` this row was filed against), `lib/lowering/tal/check.chiral:303` inside `ck-fns`, which `ck-prog` folds over the program, and a comment at `lib/lowering/tal/sys-check.chiral:4`. So `optimize.chiral:250` was never the only call site, which is what this row established.
⚑ **FIXED 2026-09-08, and the claim had become false a second way.** `records/lane-a-record.md:165` still read `holds the only ck-fn call in the tree, at :250`. PRB-70's ruling removed `re-check` from `optimize.chiral` at `b613a8f`, so that module now holds **no** `ck-fn` call at all. Measured today, `(ck-fn ` resolves to `lib/lowering/tal/check.chiral:303` inside `ck-fns`, `prog/optimizer-census.prog:78`, and a comment at `lib/lowering/tal/sys-check.chiral:4`. The cell is corrected in place and carries both refutations.
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
⚑ **HALF ANSWERED 2026-09-08, and the row stays OPEN on the other half, which now has an owner.** The four classes half is closed by this row's own 2026-09-06 re-measurement and re-verified today: both `ddfbc27` repairs are live, `ck-scrut-dn:139-145` and `targs=?` at `:75`, and PRB-41 and PRB-42 are marked FIXED against them. **The instrument half stands.** `ck-prog` still has zero callers, so this row's four counts cannot be re-taken, and the committed census (`prog/optimizer-census.prog`) folds `ck-fn` per TFn rather than `ck-prog` whole-program. `owner:` is set to `enforcement/N12`, the row opened for exactly that census.
- evidence: re-runnable: `tools/test/opt-census.sh` reads `opt-census: 12 passed, 0 failed` and its R2 pins `tfns=1582 ok=1550 err=32`. `prog/optimizer-census.prog`, `tools/test/opt-census.sh`, `lib/lowering/tal/check.chiral`, `lib/lowering/compile-back.chiral`
- checked:  2026-09-06
- owner:    enforcement/N12
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

- state:    FIXED
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/upper/lower.chiral
- claim:    requirement 3 counts the `case on non-data register` class and leaves the side that is wrong unnamed.
- measured: THE CHECKER, in all 105. Every one is a scrutinee register typed `tt-word`. Zero are the other path to that same message, an unbound scrutinee register. The lowering performs a B1 recovery: `case-sty` calls `ctor-data` to read the data name out of the first arm's constructor whenever the scrutinee's tal type fails to be `tt-data`. That recovery stays inside the lowering's own bookkeeping and reaches the emitted instruction at no point, so the register keeps `tt-word` in the TFn. `ck-term`'s case arm carries no `tt-word` arm and falls through to its catch-all. The refusal contradicts the checker's own `tal-ty=?`, whose first arm makes `tt-word` compatible with every type. Giving `ck-term` the same `ctor-data` walk over `ce-datas` turns all 105 into accepts. Minimal rejecting TFn: `(tfn "sel" ((tt-word)) (tt-i64) (block nil (tt-case 0 ...)))`; respelling that parameter `(tt-data "Lst" nil)` makes the identical body accept. Its source twin, a case over a value read out of a polymorphic field, compiles, emits, links and runs correctly.
⚑ **FIXED, and verified live 2026-09-08.** The repair this row's attribution called for shipped at `ddfbc27` (2026-09-03) and is in the tree today: `ck-scrut-dn` (`lib/lowering/tal/check.chiral:139-145`) carries a `(tt-word)` arm that reads the data name out of the first branch's constructor through `ctor-dn`, which is the B1 recovery the row measured the lowering having and the checker lacking. `ck-term`'s case arm reaches it at `:261`. The 105 were the checker in all 105 and the checker now has the recovery.
- evidence: `lib/lowering/upper/lower.chiral:168-188`, `:304-306`, `:347-355`, `lib/lowering/tal/check.chiral:210-222`, `:67-69`, `lib/lowering/tal/ssa.chiral:17-20`
- checked:  2026-09-03
- owner:    none
- from:     EN-11

### PRB-42 the `argument arity` class splits, 70 to the checker and 5 to the lowering

- state:    FIXED
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/upper/lower.chiral
- claim:    requirement 3 counts the `argument arity` class and leaves the side that is wrong unnamed.
- measured: SPLITS 70 to the checker and 5 to the lowering. As counted, the 75 are 73 the erased argument list of EN-09 reaching `ck-app` through `ck-args`, all of them zero arguments against one, plus one data-name mismatch and one ground-type mismatch. Relaxing that one checker relation flips 70 of the 75 to accepts and leaves 5, which is where the split lives: the relaxation unmasks two rejects the argument-list failure had been hiding, because `ck-args` returns on its first failing position. Those two are the lowering, and they are a real defect. `build-binders` allocates a fresh register for every erased binder position and emits no instruction defining it, on the stated ground that a `q=0` binder has zero runtime uses; `outline` then passes the whole binder environment as the outlined call's arguments, so that undefined register is passed. The enclosing TFn's `params` holds the kept list, so nothing binds it there either. They are `emit-code` (4 params, undefined register 4) and `emit-args-res` (3 params, undefined register 3), where in both the offending index equals the parameter count, which is the first register `build-binders` allocates. The emitted native code reads an undefined register and the program still computes correctly, because the callee reads that argument at no point. The remaining 3 of the 5 sit inside `$apply` dispatchers and belong with the residue in EN-13. Minimal rejecting TFn: a caller of one parameter whose body is `(i-call 1 "inner" (0 2) (tt-i64))` where register 2 is bound by nothing; inserting a definition of register 2 makes it accept. Its source twin, an erased binder over a non-tail case, compiles, emits, links and runs correctly.
⚑ **FIXED on its checker half, and verified live 2026-09-08.** The relaxation the row's split called for shipped at `ddfbc27` and is in the tree today: `targs=?` sits in `tal-ty=?`'s `tt-data` arm at `lib/lowering/tal/check.chiral:75`, so the 73 zero-against-one erased argument lists no longer refuse and the 70 flip to accepts. ⚑ **CORRECTED 2026-09-08. The sentence that stood here was wrong reasoning and it is kept as the record of a bad closure.** It read: *the 5 the row assigns to the lowering are not owed here, PRB-43 measured that set as failing to reproduce and was ruled DISSOLVED.* That closes a defect because the INSTRUMENT stopped seeing it. PRB-43's survivors stopped reproducing because `emit-code` and `emit-args-res` now refuse on the outlined-block callee first and `ck-instrs` stops at the first refusal, which is PRB-73's masking rather than a repair. This row's own text calls its residue `a real defect` whose emitted native code reads an undefined register, and a census going blind does not fix that. ⚑ **The real provenance, and it is why FIXED still stands.** The erased-binder family was repaired at `40e8726` on 2026-09-03, `an erased binder's register is defined, and the compiler stops passing garbage`, measured as [[records/enforcement-arc]] EN-14. `build-binders` (`lib/lowering/upper/lower.chiral:398-410`) now returns a `BB` carrying a defining `(i-const d (tt-word) 0)` for each placeholder, and `compile-fn` seeds `tail`'s instruction list with them. Verified live 2026-09-08. The remaining survivors were the four `$apply` dispatchers, carried to EN-15 and ruled by [[decisions/decision-erased-word-level]] on 2026-09-04.
- evidence: `lib/lowering/upper/lower.chiral:383-397`, `:308-317`, `:399-406`, `lib/lowering/tal/check.chiral:99-107`, `:109-117`, `:237-242`
- checked:  2026-09-03
- owner:    none
- from:     EN-12

### PRB-43 six TFns survive both relaxations, and the repair shape is an author call

- state:    OPEN
- author:   ruled 2026-09-08
- note:     RULED 2026-09-08 by the author: DISSOLVED. Both questions this row was opened on were already answered, so nothing here waits on the author. The argument-list question was ruled 2026-09-03 (`records/author-calls.md`, "The `ck-prog` repair shape") and `targs=?` shipped at `ddfbc27`; refuse-or-carry was ruled 2026-09-04 ([[decisions/decision-erased-word-level]]). The measurement moved with them: the six survivors do not reproduce as a set, and of them `$apply5`, `$apply6` and `$apply7` accept in full while `$apply4`, `emit-code` and `emit-args-res` refuse on the outlined-block callee `<name>$0`. The live residue is the `CEnv`-plumbing gap this row's `owner:` already carries, `enforcement/N12`, and it is work rather than a fork. ⚑ The one fork hiding inside this row is SPLIT OUT as PRB-73, the fail-fast question: `ck-instrs` (`lib/lowering/tal/check.chiral:225-230`) stops at the first `tck-err`, which is why three of the six are unobservable and why the four reject classes stay un-taken.
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
- author:   ruled 2026-09-08
- note:     RULED 2026-09-08 by the author on the principles: **the fix is E154, and a shared module is a shorter denylist rather than a model.** `PRINCIPLES.md` §1's own example is this shape, `a seccomp filter is only as complete as the syscall table it enumerates. The fix is never a longer denylist; it is a model that covers the whole surface`. The `tck-` prefix enumerates the eleven names that collide today, so it is a denylist, and extracting five of them into a shared module closes five names and leaves the mechanism running. §4 gives the same answer from the cost side, `do not enforce good behavior by listing the bad and forbidding it`, and `docs/elements/catalog.md` E154 already diagnoses the inverted gradient in its own words: `when a shared name cannot be defined twice safely, modules write prefixed clones instead of importing`. So this row's title, and `lib/lowering/tal/check.chiral:20-30`'s `their honest fix is a shared module`, both under-shoot by one rung and are superseded here. ⚑ **The denylist is longer than E154's row counts.** That row says hand-patched three times; measured 2026-09-08 the live census is at least eight: `gate-contains`, `agent-ok2xx`, `cmd-types.chiral:2`'s inlining, `check.chiral`'s eleven `tck-`, `lib/typing/diag.chiral:27`'s wholesale `dg-` which names itself the same hand-patch for the same defect, E152's `ms-take`/`ms-drop`/`ms-merge`/`ms-sort-n` shipped as the E154-prefixed internals, `ar-str-cmp`/`cb-str-cmp` which E151's ledger row already calls E154 in the wild, and the clone set `puf-length`/`puf-reverse`, `se-length`/`se-reverse`, `list-nth` twice and `str-cmp` four times. ⚑ **What the five twins measured at, so the work is priced.** Token-normalized against `lib/lowering/upper/lower.chiral`, four of the five are identical modulo the prefix and `find-data` differs only in a bound variable, `ctors` against `cs`. There is no drift and no conflict of meaning to reconcile. ⚑ **The prefix stays load-bearing until E154 lands, and its reason moved 2026-09-08.** PRB-70's ruling took `check.chiral` out of the compiler blob, so `prog/optimizer-census.prog:51,53` is now the one place in the tree that co-blobs it with `lower.chiral`. Removing the prefix before E154 breaks the census gate. This row stays `OPEN` against E154 rather than closing, because nothing is built.
- level:    source
- about:    lib/lowering/tal/check.chiral
- claim:    none yet. The rename that made `lowering/tal/check` importable beside the compiler treated all eleven collisions alike, and for five of them that is a hand-patch over a different defect.
- measured: RE-MEASURED 2026-09-06: **unchanged, and the hand-patch is what makes it look fixed.** All five twins survive in `lib/lowering/tal/check.chiral` under a `tck-` prefix: `tck-sig-assoc`, `tck-find-data`, `tck-ce-prims`, `tck-ce-fns`, `tck-ce-datas`, one definition each, beside the unprefixed originals in `lib/lowering/upper/lower.chiral`. ⚑ A grep for the bare names in `check.chiral` returns zero, which reads as resolved and is a rename. The file's own header at `:20-30` calls them "byte-identical twins" whose "honest fix is a shared module", so the duplication stands and only the emitted-label collision was patched.
- evidence: re-runnable: `for s in sig-assoc find-data ce-prims ce-fns ce-datas; do grep -c "^(def tck-$s" lib/lowering/tal/check.chiral; done` returns 1 five times. `lib/lowering/tal/check.chiral:20-30`, `lib/lowering/upper/lower.chiral:163-194`
- checked:  2026-09-08
- owner:    E154
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
⚑ **PLACED 2026-09-08 by [[records/findings]] FD-18, and it lands on a different obligation than expected.** The published clause carries the abstraction's own body (`POLYDEFUNCX:112`), so a dispatcher disagreeing with its declared codomain is not a failure of the typing obligation this row was filed against. FD-18 places it on FD-15's TOTALITY rider instead, which `enforcement/N14` carries. ⚑ Not owned here, because N14's subject is `ttype` and this row's is `closconv`'s codomain agreement, and whether they are one delta is a design-stage question rather than a measurement.
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
- measured: RE-MEASURED 2026-09-06: **CONFIRMED, and the earlier finding that the fixture no longer parses is itself refuted.** `<i` is live. `lib/prelude/prelude.chiral:65` declares `(extern <i (-> I64 I64 Bool))`, and `prog/paren-audit.prog:110` calls it inside a file that passes `chirality check` at exit 0. The `load: unknown name <i` that run hit came from a fixture missing `(import "prelude/prelude")`, so it measured the import and never reached the checker. With the import the trigger reproduces exactly: `(def pa-min (=> I64 I64 I64) (lam (a b) (let (m (case (<i a b) (true a) (false b))) m)))` fails at `load: cannot prove refinement`, exit 1. All four conditions FD-02 named still gate it, each removed on its own and each then passing at exit 0: dropping the `let` and returning the `case` directly, handing the `Bool` in as a parameter instead of computing it, and returning the literals `1` and `2` from the arms. `cond` fails identically, as FD-02 recorded, since it desugars to `case`. The refusal site is unmoved by E182's 2026-09-02 pass over the same file: `lib/typing/kernel.chiral:1439-1440` still collapses two refusals into one `jg-refine-unproved`, and `unann-lit` (`:1426-1427`) answers `some` only for an integer literal or an annotation over one, so a `case` term reaches the `none` arm at `:1440`. `lib/typing/diag.chiral:454` renders that arm `cannot prove refinement`. The workaround stands with its comment at `prog/paren-audit.prog:103-110`.
- evidence: re-runnable: a file holding `(import "prelude/prelude")` then `(def pa-min (=> I64 I64 I64) (lam (a b) (let (m (case (<i a b) (true a) (false b))) m)))` fails `bin/chirality check` at exit 1 with `load: cannot prove refinement`; the same def with the `let` dropped, returning the `case` directly, passes at exit 0. `bin/chirality check prog/paren-audit.prog` exits 0. `lib/prelude/prelude.chiral:65`, `lib/typing/kernel.chiral:1426-1440`, `lib/typing/diag.chiral:454`, `prog/paren-audit.prog:103-110`, `records/findings.md` FD-02
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
⚑ **EXPLAINED 2026-09-08 by [[records/findings]] FD-18, and the explanation is a published precondition rather than a language limitation.** Defunctionalization's transformation requires an enumeration of EVERY abstraction in the program, each getting a tag that becomes a constructor of the closed sum (`DEFUNCWORK:226-228`). A bare `(lam ...)` written directly in a constructor argument position and never registered as a site therefore has a tag nobody minted, which is exactly the `no emitted label` this row measures. FD-18 named this row as the one the published obligation speaks to hardest. ⚑ **No roster row owns the site enumeration.** `enforcement/N16` covers `shape-eq`'s split criterion and not which abstractions get registered, so this stays unowned.
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
- measured: RE-MEASURED 2026-09-06: **unchanged in substance and still author-tier, with one citation that no longer resolves and one of the finding's two offered outcomes already taken.** `PRINCIPLES.md` still carries five principles, at `:23`, `:51`, `:76`, `:123` and `:149`, and nothing in it names the boundary as the atom. The 2026-09-04 pass at `32823ee` is the author's own and decided nothing here: it cut the seven-to-five crosswalk section entire and shortened the draft note to two lines, 2 insertions against 31 deletions. ⚑ **The `CLAUDE.md` citation has drifted off its target.** The root `CLAUDE.md` holds no doctrine under [[decisions/decision-ai-tier]] and states this rule nowhere. The sentence this row quotes is the finding's own at `.planning/FINDING-ports-role-2026-08-31.md:72-73`, and its tracked restatement is `docs/definitions/altitude-errors.md:197`. ⚑ **The finding's cheaper alternative was taken.** It offered a fork: earn the condensation by deciding two or three more open questions, or correct `MAP.md`'s sentence and leave the principles alone. `MAP.md:58-84` now carries the section ``ports/` holds declarations, not code about ports`` with the mint test the finding proposed, landed 2026-08-31 at `e1d0c91` and `0aefbc1`. The condensation itself stays untouched and unruled, which is what this row is about. The second half holds: `.planning/DOC-AUDIT-QUEUE.md:72` queues `PRINCIPLES.md` under the accuracy charter, and the three `PRINCIPLES.md` rows opened 2026-09-06 as `presentability/D4`, `D5` and `D6` carry accuracy claims about P1, P3 and P5. No entry anywhere asks whether the five are the right five. RE-VERIFIED 2026-09-07 after `MAP.md` gained a `docs/translations/` row: the insertion lands at `:144`, below the cited span, and `MAP.md:58` still carries the `ports/` section title this row cites. Substance unchanged.
- evidence: re-runnable: `grep -c '^## [1-5]\. ' PRINCIPLES.md` returns 5. `git show --stat 32823ee -- PRINCIPLES.md` reads 2 insertions, 31 deletions. `grep -c 'constrain' CLAUDE.md` returns 0 and `grep -n 'does not constrain is overhead' docs/definitions/altitude-errors.md` returns 197. `grep -n 'holds declarations, not code about ports' MAP.md` returns 58. `PRINCIPLES.md:23`, `:51`, `:76`, `:123`, `:149`; `MAP.md:58-84`; `.planning/FINDING-ports-role-2026-08-31.md:54-92`; `.planning/DOC-AUDIT-QUEUE.md:72`; `docs/arcs/presentability-arc.md:60`, `:87`; commits `32823ee`, `e1d0c91`, `0aefbc1`
- checked:  2026-09-07
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
⚑ **UNCHANGED, and now owned, 2026-09-08.** `enforcement/N9` (E70) takes the effect-side preserve-check, which `docs/decisions/decision-preserve-check.md` splits into a T0 and a T1 rung the same way it splits the value side. ⚑ **Nothing prices either rung yet.** Slice R7 of `.planning/TAL-CONFORMANCE-QUEUE.md`, the effect question, is `UNRUN`, so no finding says whether an effect claim is typeable at a target level at all or whether agreement between two evaluators can carry it. PRB-70's ruling did move this file: `eff-lower.chiral:20` was repointed from `lowering/tal/check` to `lowering/tal/ssa` at `b613a8f`, which changes its imports and not its subject.
- evidence: `lib/lowering/upper/eff-lower.chiral:1-17`, `lib/lowering/compile-back.chiral:181-210`, `lib/lowering/skip-diag.chiral:11`, `lib/lowering/tal/sys.chiral:1-12`, `docs/decisions/decision-effect-facets.md`, `lib/module/loader.chiral:280`
- checked:  2026-09-06
- owner:    enforcement/N9
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
- measured: RE-MEASURED 2026-09-07: unchanged, and two of the three doc citations drifted. `wc -l` reads `prog/paren-audit.prog` at 244 and `tools/paren-audit/paren-audit.py` at 154, the figures this row recorded. Nothing invokes the chirality port: a grep for `paren-audit.prog` over `lib/`, `prog/`, `tools/` and `bin/` returns its own two usage-header lines `:7` and `:8` plus the `tools/README.md:12` row that names it, and no invocation. That README row still reads the Python as running unchanged with equivalence **unverified**, so it is not retired and not deletable, and its line number holds. The two other doc citations moved: the zero-python claim now sits at `docs/arcs/zero-python-arc.md:123-125` under "Resume state" while `:97-99` holds the E33/E105 supply table, and the self-tooling claim now sits at `docs/goals/self-tooling.md:76-77` while `:67-68` holds an honest limit about `.manifest`. Its usage line, `prog/paren-audit.prog:7`, still needs a directory walk it does not have: `find lib prog -name '*.chiral' | chirality run prog/paren-audit.prog`. The differential run that would retire the Python has still never been taken.
- evidence: re-runnable: `wc -l prog/paren-audit.prog tools/paren-audit/paren-audit.py` returns 244 and 154; `grep -rn 'paren-audit.prog' lib/ prog/ tools/ bin/` returns three hits, none of them a call. `prog/paren-audit.prog:1-10`; `tools/README.md:12`; `docs/arcs/zero-python-arc.md:123-125`; `docs/goals/self-tooling.md:76-77`
- checked:  2026-09-07
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
- measured: RE-MEASURED 2026-09-07: **the source measurement is unchanged and the second half's cause has moved. `c763f11` puts BLAKE2s outside the quantum finding: it stands on security grounds, and §11's architecture is what displaces it.** `lib/protocol/apc.chiral` is still unmoved since `5856c85` on 2026-08-31: `fnv1a-go` at `:126`, `fnv1a` at `:130`, `hex16-go` at `:133` and `hex16` at `:137` under the header at `:122`, giving the span `:122-137`, with `block-id` at `:141-147` and both `:227` and `:244` still reading `(case (str-eq id (block-id node))`. The five `sha256sum` pin sites hold at `tools/test/doc.sh:595`, `face.sh:547`, `row.sh:665`, `pretty.sh:484` and `render-doc.sh:506`, with the comment at `render-doc.sh:514` making six lines; `records/tooling-classification.md:348-350` still carries 444, 547, 645, 379 and 482, so four of the five figures are drifted and `face.sh:547` alone is exact. "Step 3: BLAKE2s (slice 3)" holds at `docs/elements/specs/N01-crypto-kernels-SPEC.md:187`, and `docs/arcs/native-protocol-arc.md:60` still carries the MARKED 2026-09-06 pre-quantum banner with slices 3 and 4 open. ⚑ **§1 of `.planning/CRYPTO-MODEL.md` now grades each primitive against a quantum adversary.** The table at `:42-48` reads X25519 **genuinely dead** to Shor, Ed25519 dead on the same curve, ChaCha20 and Poly1305 standing, and **BLAKE2s at `:48` "stands on security grounds"**. `:50-54` concludes that exactly one of N1's four slices is retired by the security finding, that slice 4 is that one, and of slice 3 that it is "displaced by §11's architecture, which makes a digest a configuration of our own machine. Shor and Grover have no part in that displacement." So **the row's second half is true on its facts and was wrong on its reason**: BLAKE2s is still the specced kernel and a live re-scope still proposes to replace it, and that replacement is now an architecture and redundancy call. `:56-60` says the same of `C1`, which §1 re-reads as a cost question. ⚑ **Three of this row's `.planning/CRYPTO-MODEL.md` citations drifted under `c763f11`'s 122 insertions.** §2's layer 2 sponge row moved `:42` → `:68`, the §12 BLAKE2s-and-X25519 row `:304` → `:406`, and the collision-resistant-digest row `:305` → `:407`. The distinction the row exists to draw survives every reading: `lib/` holds a content hash and holds no cryptographic one, so the row stays **OPEN**.
- evidence: re-runnable: `grep -n '(def fnv1a\|(def hex16\|(def block-id' lib/protocol/apc.chiral` returns 126, 130, 133, 137 and 141. `grep -n 'stands on security grounds' .planning/CRYPTO-MODEL.md` returns 48. `grep -n 'no part in that displacement' .planning/CRYPTO-MODEL.md` returns 54. `grep -n 'collision-resistant digest' .planning/CRYPTO-MODEL.md` returns 407. `grep -n 'Step 3: BLAKE2s' docs/elements/specs/N01-crypto-kernels-SPEC.md` returns 187. `grep -n 'MARKED 2026-09-06' docs/arcs/native-protocol-arc.md` returns 60. `grep -rn 'sha256sum' tools/test/*.sh` returns six lines over five scripts. `lib/protocol/apc.chiral:122-137`, `:141-147`, `:227`, `:244`; `.planning/CRYPTO-MODEL.md:42-48`, `:50-54`, `:56-60`, `:68`, `:406-407`; `docs/elements/specs/N01-crypto-kernels-SPEC.md:187`; `docs/arcs/native-protocol-arc.md:60`; `records/tooling-classification.md:348-350`; commits `5856c85`, `f8018ee`, `c763f11`
- checked:  2026-09-07
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

- state:    FIXED
- author:   unreviewed
- note:     none
- level:    source
- about:    tools/test/map-integrity.sh
- claim:    `tools/test/map-integrity.sh:7-8` reads "Not a suite phase: the map lives under `.planning/`, which is not tracked, so a fresh checkout has no map to check."
- measured: RE-MEASURED 2026-09-06: still true, and the count moved. `tools/test/map-integrity.sh:7-8` still states the map lives under `.planning/`, "which is not tracked, so a fresh checkout has no map to check". `git ls-files .planning | wc -l` returns **162**, against the 147 this row recorded, and `.planning/` has been tracked since 2026-09-01 by `decision-ai-tier`. The stated reason for the exclusion has been false for five days.
⚑ **FIXED 2026-09-08, and the number was staler than the row.** `tools/test/map-integrity.sh:8-10` now records that the sentence was false from `docs/decisions/decision-ai-tier.md`'s tracking of `.planning/` on 2026-09-01, and carries today's measurement: `git ls-files .planning | wc -l` returns **327**, against the 162 this row last recorded and the 147 before that. The script keeps its `not-a-phase:` declaration at `:7`, whose reason was always the true one, so `tools/test/registration.sh` still reads `9 passed, 0 failed`. The 176 stale map rows are a separate defect this row never claimed.
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

- state:    FIXED
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/tal/eval.chiral
- claim:    `docs/arcs/independent-judgment-arc.md:38-42` lists what is in the tree already for the independence axes: `lib/evidence/ddc.chiral` at 213 lines with 1 importer, `lib/typing/kernel-core.chiral` at 60 lines with 0, and `lib/typing/reflect-floor.chiral` at 54 lines with 0.
- measured: RE-MEASURED 2026-09-06: unchanged and still omitted. `lib/lowering/tal/eval.chiral` is **187 lines with zero importers** and `:1-2` describes it as the reference tal interpreter. The arc's own table at `docs/arcs/independent-judgment-arc.md` lists `ddc.chiral` (213 lines, 1 importer), `kernel-core.chiral` (60, 0) and `reflect-floor.chiral` (54, 0), and omits the strongest member. ⚑ The arc names the omission in its prose at `:125` and has never put it in the table.
⚑ **FIXED 2026-09-08, on both halves and by different means.** The title's claim that no arc rows it is now false: `enforcement/N13` rows `lib/lowering/tal/eval.chiral` by name, opened at `8e97473` on [[records/findings]] FD-20 and `docs/decisions/decision-preserve-check.md`, which place it as the TARGET half of a preserve-check's T1 rung with `lib/evidence/interp.chiral` (109 lines, zero importers) as its source half. The omission half is repaired in place: the table at `docs/arcs/independent-judgment-arc.md:40-42` now carries the row, which its own `:125` had been contradicting.
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
- measured: RE-MEASURED 2026-09-06: **the drift this row named has widened, and the gap is now larger than the original figure.** Taking the table's own tiers again today: the gate tier `tools/test/*.sh` is **26 files at 10,744 lines** where the table carries 18 at 6,915; Python under `tools/` is **10 files at 6,664** where it carries 9 at 4,786; `tools/prose-lint/prose-lint.sh` at **223** and `bin/chirality` plus `bin/chirality-resolve.sh` at **526** are both unchanged. The surface outside the language is therefore **39 files at 18,157 lines**, against the **12,450** that `records/tooling-classification.md:52-59`, `docs/goals/enforcement.md:47-48` and `docs/arcs/enforcement-arc.md:249-252` still carry, and against the **12,671** `docs/arcs/enforcement-arc.md:232` corrected to on 2026-09-05. Native `.prog` tooling holds at **782** over the same five files, so the whole move is on the outside half. **The third drift is repaired**: the scope paragraph reads 119 at `records/tooling-classification.md:38-46`. **The second drift cannot be re-taken.** It rested on an independently written call-site scanner, and `records/tooling-classification.md:48` records that the scanner was a session script and is not tracked, so 506 against 504 stands where this row left it. **Nothing here is a defect in any original count.** Each figure was true when taken and the target moves under it, which is the class this row exists to name. RE-VERIFIED 2026-09-07 after `tools/xlat/xlat.sh` joined `tools/` and `records/tooling-classification.md` gained a note: all three evidence commands return what the row records, 26, 10744 and 10. `xlat.sh` sits under `tools/xlat/` rather than `tools/test/`, and no Python file was added, so the gate-tier and Python figures are untouched. Substance unchanged.
- evidence: re-runnable: `ls tools/test/*.sh | wc -l` returns 26 and `cat tools/test/*.sh | wc -l` returns 10744; `find tools -name '*.py' | wc -l` returns 10 and `find tools -name '*.py' | xargs wc -l | tail -1` returns 6664; `wc -l tools/prose-lint/prose-lint.sh bin/chirality bin/chirality-resolve.sh` returns 223, 220 and 306. Their sum is 18,157 against the 12,450 in the table. `records/tooling-classification.md:52-59`, `:38-48`; `docs/goals/enforcement.md:47-48`; `docs/arcs/enforcement-arc.md:232`, `:249-252`
- checked:  2026-09-07
- owner:    none
- from:     TC-14

### PRB-69 most record rows name no command that re-runs their measurement

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    doc
- about:    records/README.md
- claim:    records/README.md, Evidence is mandatory: "`evidence:` names files and line spans. A row nobody can re-run is worthless."
- measured: **RE-MEASURED 2026-09-07: the claim holds and now has an instrument. 197 of 276 evidence fields name no command; 79 name one, 67 of those through the `re-runnable:` opener.** The population is every `### ` row under records/ and records/lenses/, the two READMEs excluded because their `evidence:` line is the schema template and not a row. The classifier counts as a command a `re-runnable:` opener, a `python3` or `bash` invocation, a bare `tools/test` gate script (a gate cited with a `:LINE` suffix is a span and does not count), a `git log`, `ls-files`, `grep`, `show`, `diff`, `rev-list` or `cat-file`, a `grep -`, `wc -l`, `find`, `chirality run|check|compile|test`, `printf`, `cmp`, `nm -`, `readelf`, `objdump`, `awk` or `sed -n`. ⚑ **This row exhibited the defect it names.** Its `evidence:` was three bare paths and no command, and one of those paths was the file the row lives in, so every edit anywhere in that file reddened check AI on this row and no re-measurement could ever clear it. The census below replaces the self-citation with the thing the claim is actually about. The two earlier figures on this row, 123 of 153 on 2026-09-05 and 66 against 125 on 2026-09-06, were taken by a method the row never stated and neither is reproducible; they stand as history, and 197 of 276 is the first reading with a pasteable instrument behind it. The largest remaining block is still the TFn census, which three rows rest on and which is buildable as `enforcement/N12`.
- evidence: re-runnable: the census is `grep -rh '^- evidence:' records/ --exclude='READ*' | grep -cvE 're-runnable:|python3 |bash |tools/test/[a-z0-9-]+\.sh([^:]|$)|git (log|ls-files|grep|show|diff|rev-list|cat-file)|grep -|wc -l|find |chirality (run|check|compile|test)|printf |cmp |nm -|readelf|objdump|awk |sed -n'` and returns 197. Dropping the `v` from the second grep returns 79, and replacing `-cvE ...` with `wc -l` returns 276.
- checked:  2026-09-07
- owner:    enforcement/N12 for the census; the rest is per-row
- from:     none

### PRB-70 G18 is a true positive: check.chiral entered the compiler closure

- state:    FIXED
- author:   ruled 2026-09-08
- note:     RULED 2026-09-08 by the author: the checker stays OUTSIDE the compiler closure and the wiring is the defect. G18 keeps its polarity and is not inverted and not retired. Measured for the ruling: the typed tal IR the two importers say they want, `TalTy` / `Instr` / `Block` / `TalTerm` / `Branch` / `TFn`, is declared at `lib/lowering/tal/ssa.chiral:21-40` and not in `check.chiral`, which imports ssa for it. So `eff-lower.chiral:20` and `optimize.chiral:17` both carry a mis-citation, and repointing them at `lowering/tal/ssa` costs one line each and changes no behaviour. What is left holding `check.chiral` in the closure is `re-check` (`optimize.chiral:249-250`), the single `ck-fn` call site, and it goes. ⚑ The ruling reopens enforcement requirement 4, whose closure rests on that call. Accepted with three measurements behind it: the wiring put `ck-fn` in the blob and never `ck-prog`, so requirement 2's subject still has zero call sites; a compiler with `re-check` forced to answer `chk-ok` emits a byte-identical blob at 1,241,464 bytes, so the wiring buys no shipped byte; and keeping it charges the BUILD RULE on every edit of `check.chiral` and costs `tal-check.sh` the scratch-`lib/` mutant harness that G18 exists to license. `tools/test/opt-census.sh` gated the wiring at `12 passed, 0 failed` and retires with it, and `optimize.chiral:6-8`'s claim that the preserve-check lives in the signature comes out with it. Splitting the four-line `ck-prog` wrapper at `check.chiral:308-312` into another file was refused as the shape that turns G18's grep green with the checker still in the blob.
- level:    source
- about:    tools/test/tal-check.sh
- claim:    tools/test/tal-check.sh G18 asserts `lowering/tal/check is OUTSIDE the compiler blob`, and its own comment says: "If it ever goes red, check.chiral has entered the blob and the BUILD RULE's build-new -> test -> promote applies to every edit of it."
- measured: **FIXED 2026-09-08 BY THE TREE MOVING. G18 READS GREEN AND KEPT ITS POLARITY.** The ruling was carried out at `b613a8f` and `38ecdba`. `eff-lower.chiral:20` and `optimize.chiral:17` are repointed at `lowering/tal/ssa`, `re-check` and the `Checked` sum moved to `prog/optimizer-census.prog`, and `compile-back.chiral`'s `opt-tfns` adopts `(fold t)` unjudged. `C1 == C2` at 1,220,984 bytes against the tracked 1,241,464, the blob 840,440 against 855,545, `grep -c 'def ck-prog'` over it returning **0**. `bash tools/test/tal-check.sh` exits 0 at **`21 ok, 0 FAIL`**; `bash tools/test/run-tests.sh` exits 0 at `412 passed, 0 failed`, `93 roots built, 0 failed`, gate PASSED, matching a pre-change baseline taken in a clean worktree at HEAD. `tools/test/opt-census.sh` dropped R5, R6, M1 and M2, which asserted the wiring, kept R1 to R4 and M3 to M6, which measure the census, and reads `8 passed, 0 failed` over `census tfns=1548 ok=1517 err=31`. `docs/arcs/enforcement-arc.md` requirement 4 is REOPENED and `records/enforcement-arc.md` EN-26 carries the measurement. ⚑ The reading below is what this row measured on 2026-09-06 and it stands as the record of the red period. **IT WENT RED AND THE PREMISE HAS FLIPPED.** Measured 2026-09-06 on a blob built to its fixpoint: `grep -c 'def ck-prog'` returns **1**, and `lib/lowering/upper/optimize.chiral:17` and `lib/lowering/upper/eff-lower.chiral:20` both `(import "lowering/tal/check")`. So check.chiral is inside the closure and every edit to it owes the build rule. ⚑ **Present is not called.** `grep -rn '(ck-prog'` over lib/ and prog/ returns zero call sites outside its own definition, so the floor checker sits at SEEDED: compiled in, reached by nothing. That is enforcement requirement 2 half-moved, not met. G18 needs inverting to assert what the tree now wants, and the mutant harness below it assumes a scratch lib/ on the old premise.
- evidence: re-runnable: `bash tools/test/tal-check.sh` exits 0 at `21 ok, 0 FAIL` with G18 green; `. bin/chirality-resolve.sh && chirality_blob_file "lib:prog" prog/compiler.prog | grep -c 'def ck-prog'` returns 0. tools/test/tal-check.sh:399-406, lib/lowering/upper/optimize.chiral:17, lib/lowering/upper/eff-lower.chiral:20, lib/lowering/tal/check.chiral
- checked:  2026-09-08
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

### PRB-72 the tree's definition of `cascade` lives only in a superseded example

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    doc
- about:    .planning/CRYPTO-MODEL.md:376
- claim:    `.planning/CRYPTO-MODEL.md:375-381`, written 2026-09-07 by `c763f11`, states that "`cascade` is already this tree's word" and cites `docs/examples/C01-typed-style-value.md:138` for the sense, quoting *"an ordered, incremental fold"*, with `docs/examples/C1C2-style-round-trip.md` named beside it as the layer built on that fold.
- measured: **The citation resolves, and it resolves into a retired document.** `docs/examples/C01-typed-style-value.md` carries `status: superseded` at `:8` and `superseded_by: C1C2` at `:9`, under a "SUPERSEDED 2026-09-04 by C1C2" banner at `:15`. The quoted phrase appears **once** across `docs/examples/`, at `C01:138`, and once more in the whole tree at `.planning/CRYPTO-MODEL.md:377` where it is being quoted. The successor `docs/examples/C1C2-style-round-trip.md` is `status: reviewed` at `:8` and returns **0** for the phrase; its nearest line, `:21-22`, reads "C2 is the cascade as a total ordered fold with a stated law", which restates the shape and drops the word *incremental* along with the definitional framing. So **this tree's only stated definition of one of its own terms of art sits inside a document its own front matter retires**, and a design document one day old now rests on it. A reader who follows the supersession pointer to C1C2 finds no definition waiting there. Which side moves, the definition to the live document or the citation to the superseded one, is an author call.
- evidence: re-runnable: `grep -rn 'ordered, incremental fold' docs/examples/*.md` returns exactly one line, `docs/examples/C01-typed-style-value.md:138`. `grep -n '^status:\|^superseded_by:' docs/examples/C01-typed-style-value.md` returns `8:status: superseded` and `9:superseded_by: C1C2`. `grep -c 'ordered, incremental fold' docs/examples/C1C2-style-round-trip.md` returns 0. `docs/examples/C01-typed-style-value.md:8-9`, `:15`, `:138-139`; `docs/examples/C1C2-style-round-trip.md:8`, `:21-22`; `.planning/CRYPTO-MODEL.md:375-381`; commit `c763f11`
- checked:  2026-09-07
- owner:    none
- from:     none

### PRB-73 ck-instrs stops at the first refusal, so no census can see past it

- state:    OPEN
- author:   unreviewed
- note:     ⚑ DEFERRED to research, 2026-09-08 by the author. The fork was put to the author and the author routed it to a `research` run before ruling, on the ground that fail-fast against collect-all is settled practice in published checkers and this tree should read what they do before choosing. The row stays `unreviewed`: routing to research says where the answer comes from and leaves the fork standing, which is the defect `records/author-calls.md` records for 2026-09-06. The ruling lands here when the `FD` row lands in `records/findings.md`. ⚑ **The research landed 2026-09-08 as [[records/findings]] FD-14 (`c0253a9`), thirteen sources pinned, and it REFRAMED this fork rather than answering it.** The split between fail-fast and collect-all follows a structural fact and not a policy preference: a checker collects several refusals when the type of every value and the state at every block boundary is already written in the artifact under check, and a checker whose environment is produced by the check itself has three published shapes, stop at the first refusal, be made total so nothing is refused, or poison the continuation and suppress what it reports. `ck-instrs` threads a derived `REnv`, so this tree is in the second family and **plain collect-all with the rules unchanged is not among its options**, which is the shape this row was opened proposing. CompCert's `type_code` is `ck-instrs` deliberately, folding with `| Error _ => re`, and its reason transfers: `type_function_correct` constrains only the `OK` side, so a second error carries no verified meaning. TAL, the JVMS and WebAssembly all specify a yes/no judgment with no error object. The two systems that do collect, LLVM and Cranelift, afford it because every value carries a declared type, and the JVMS verifier reaches the same place by requiring StackMapTable frames instead of inferring them. The suppress shape is useless here: rustc's `TyKind::Error` and GHC's `cec_suppress` exist so knock-on errors are NOT reported, which is invisible to a census in the same way a skipped class is. **Three shapes survive for the author, and FD-14 prices each.** (a) Fail-fast stands and N12's four reject classes are withdrawn as un-takeable, on CompCert's precedent, which costs the three record rows resting on those classes a rewording. (b) A switched error sink, one walk and one rule set with an accumulator that is nil for the judgment and present for the census, on the `go/types` precedent (`panic(bailout{}) // record first error and exit`), which leaves the derived-environment problem untouched so the extra findings stay speculative, and FD-14 found **no measured cascade rate for type checking anywhere** to price them with. (c) The IR carries declared types at block boundaries, the Cranelift and StackMapTable route, which is the only shape that makes the four classes takeable with meaning because the continuation state is read rather than guessed, and which costs a change to `lib/lowering/tal/ssa.chiral` plus an annotation obligation on every producer. FD-14 also searched for and did not find any system running one rule set twice as two separate walks with a published agreement argument, so the two-instruments shape considered in session has no prior art in that form.
- level:    source
- about:    lib/lowering/tal/check.chiral
- claim:    `enforcement/N12` states the TFn census as folding `ck-prog` over every emitted TFn and reporting accept, reject and **the four reject classes**. Three record rows rest on that number. ⚑ **CORRECTED 2026-09-08, the day this row was opened: the four classes no longer exist and this row overstated its own stakes.** [[records/lenses/problems]] PRB-38, re-measured 2026-09-06, records their cause repaired at `ddfbc27` on 2026-09-03, `targs=?` into `tal-ty=?`'s `tt-data` arm and `ck-scrut-dn` giving `ck-term`'s case arm the `tt-word` recovery, the two repairs EN-09 and EN-11 named. The committed census reads one class, `call: unknown tal function`, and zero of each of the four. The three record rows carry those counts as history, and PRB-38 had already written that they do not reproduce two days before this row was opened.
- measured: `ck-instrs` (`lib/lowering/tal/check.chiral:225-230`) returns `(tck-err m)` on the first failing instruction and never walks the rest, so a TFn's judgment carries exactly one refusal no matter how many it holds. The census inherits that bound: over the compiler's own blob it reads one class, `call: unknown tal function`, 32 of 1,582, and cannot say whether a second class survives behind the first. PRB-43 measured the concrete cost: of its six named survivors, `$apply4`, `emit-code` and `emit-args-res` refuse on the outlined-block callee `<name>$0` and are therefore unobservable at the ground-versus-data shape they were named for. ⚑ **RE-MEASURED 2026-09-08 against PRB-38, and the cost is three functions rather than four classes.** The four classes were repaired out of existence on 2026-09-03, so what fail-fast hides today is the SECOND finding of `$apply4`, `emit-code` and `emit-args-res`, three TFns of 1,548, whose ground-versus-data disagreement sits behind the outlined-block callee refusal. ⚑ **And that hiding is temporary by construction.** The 31 refusals are all one class, the `CEnv`-plumbing gap that is `enforcement/N12`'s actual subject. Repair it and those refusals go, whatever sits behind them becomes the new first refusal, and it is then visible. Fail-fast does not hide a population permanently, it serialises discovery into waves, which is how CompCert operates and why FD-14's reading of `type_function_correct` constraining only the `OK` side makes that sound. So the fork this row was opened on is **dissolved by measurement rather than settled by preference**, and what is left for the author is one line: fail-fast stands, or the IR change in FD-14's shape (c) is bought to see every wave at once against a defect set of three functions.
- evidence: `lib/lowering/tal/check.chiral:225-230`, `lib/lowering/tal/check.chiral:308-312`, `docs/arcs/enforcement-arc.md` roster row `enforcement/N12`, [[records/findings]] FD-14
- checked:  2026-09-08
- owner:    enforcement/N12
- from:     PRB-43

### PRB-74 tal-ty=? is not transitive, so the checker's equality is not an equivalence

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/tal/check.chiral
- claim:    `docs/decisions/decision-erased-word-level.md:44` gives as its FIRST reason for keeping the erased word out of the kernel's `conv` relation: `Conversion is an equivalence relation, so it is transitive. A Word that converts with I64 and with (List Str) makes I64 convert with (List Str), which collapses the source type system.` `lib/lowering/tal/check.chiral:65-66` names `tal-ty=?` word-compatibility rather than nominal equality, and `lib/lowering/tal/ssa.chiral:23` says every value-defining form carries its result type annotation so the checker re-verifies independently of the kernel.
- measured: **`tal-ty=?` is not transitive, and the decision above is the argument for why that matters.** By its own arms at `lib/lowering/tal/check.chiral:68-77`: the `tt-word` arm returns `true` against every `b`, so `(tal-ty=? tt-i64 tt-word)` is `true` and `(tal-ty=? tt-word tt-str)` is `true`, while the `tt-i64` arm sends `tt-str` to the `_` arm, so `(tal-ty=? tt-i64 tt-str)` is `false`. The relation the checker uses in place of type equality is therefore not an equivalence. It escapes the source-type-system collapse the decision names by exactly the property that stops it being an equality at all. ⚑ **The production analogue IS an equivalence.** [[records/findings]] FD-16 measured GHC's `Cmm/Type.hs` `weak_eq`, the closest shape in a shipping compiler, partitioning its types into three classes, and it runs only in the lint. ⚑ **And FD-16 measured the discharge the tree does not pay.** The two surveyed systems that keep a checked target over a type language coarser than the source, the JVM and the WebAssembly GC proposal, charge the producer a runtime cast at every use site. `tal-ty=?` admits the collapse in the checker and charges nothing.
- evidence: `lib/lowering/tal/check.chiral:68-77`, `docs/decisions/decision-erased-word-level.md:44`, [[records/findings]] FD-16, [[records/findings]] FD-15
- checked:  2026-09-08
- owner:    enforcement/N15
- from:     FD-16

### PRB-75 three value-defining Instr forms carry no type, and ssa.chiral says every one does

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/tal/ssa.chiral
- claim:    `lib/lowering/tal/ssa.chiral:24-25`: `one typed SSA instruction. Every value-defining form carries its result type annotation (ty), so the checker re-verifies independently of the kernel.`
- measured: **Three value-defining forms carry no `ty`, so the claim is false for exactly the forms where the artifact records nothing.** `Instr` has eight constructors (`ssa.chiral:26-33`). Four carry `ty`: `i-const`, `i-prim`, `i-call`, `i-con`. Of the remaining four, `i-bput` defines no value, and `i-bnew`, `i-bget` and `i-blen` each bind a `dst` while carrying no annotation. The checker supplies their types from its own constants at `lib/lowering/tal/check.chiral:215-218`: `i-bnew` yields `(tt-bytes)`, `i-bget` yields `(tt-i64)` whatever was stored, `i-blen` yields `(tt-i64)`, and `i-bput` requires its value at `(tt-i64)`. So for these forms the checker does not re-verify against the artifact, it invents the answer, which is the opposite of the sentence above. ⚑ **A laundering path follows, and its reachability is UNMEASURED.** `tal-ty=?` (`check.chiral:68-77`) has `tt-word` matching `tt-i64`, so a register holding an erased value satisfies `i-bput`'s check, and `i-bget` returns it typed `(tt-i64)` unconditionally. A value whose source type was `tt-str` can therefore enter the heap erased and leave it an integer with every step accepted. Whether the lowering ever drives a non-`i64` through `Bytes` is not measured here, so the mechanism is confirmed and the instance is not. ⚑ **MEASURED 2026-09-08 by [[records/findings]] FD-19, and the instance is unreachable for a reason that sharpens the row.** Grepped over `lib/` and `prog/`, every appearance of the four byte forms outside `check.chiral` and `ssa.chiral` is a CONSUMER: `optimize.chiral:102-105,150-153,171-172,206-209` destructures and rebuilds them under a register remap, `eval.chiral:148-167` interprets them, and `erase.chiral:198-201` lowers them to the erased `n-*` forms. `lower.chiral` constructs none of them. **Nothing originates a byte instruction in the checked IR**, so the laundering path has no instance today. The real byte cells are hand-written in the erased `TalIr` BELOW the check (`bytes.chiral:54-67`, `sys-linkage.chiral:44-61`) and `ck-prog` never sees them. So the defect is not a live hole, it is three instruction forms sitting in a checked type system with no annotation and no producer, which become a hole on the day anything produces one, beside a byte layer the floor does not reach at all. ⚑ **This is where the published discharge goes.** [[records/findings]] FD-17 measured that the JVM puts `checkcast` and WebAssembly GC puts `ref.cast` at exactly the heap-read position, and that none of the five surveyed mechanisms discharges a coarse target type inside the checker's equality relation, which is where `tal-ty=?` does it.
- evidence: `lib/lowering/tal/ssa.chiral:24-25`, `lib/lowering/tal/ssa.chiral:26-33`, `lib/lowering/tal/check.chiral:215-218`, `lib/lowering/tal/check.chiral:68-77`, [[records/findings]] FD-17, [[records/findings]] FD-15
- checked:  2026-09-08
- owner:    enforcement/N17
- from:     FD-17

### PRB-76 shape-eq collapses all non-arrow domains, and two author calls were its symptoms

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/upper/closconv.chiral
- claim:    `lib/lowering/upper/closconv.chiral:337-340`: `NON-arrow type is one uniform word, so any two non-arrows are shape-equal ... This is what makes defunctionalization erasure-aware -- (-> A B), (-> I64 I64), (-> Str Bool) all share one family/key.`
- measured: **The domains collapse and the codomains do not, and that asymmetry produced two author calls neither of which named it.** `shape-eq` (`:343-350`) opens `(case (is-arrow a) (false (not (is-arrow b))))`, so any two non-arrows answer `true` and `I64` is shape-equal to `Str`. `cod-key-eq` (`:365-376`) is finer on the same types: ground against ground goes through `core-eq`, exact, so `Bool` splits from `I64`. A family therefore merges over its domains and splits over its codomain. ⚑ **The consequence is E185 and E186.** If `(-> I64 I64)` and `(-> Str I64)` share one dispatcher then that dispatcher's parameter position has to accept both, so it must be spelled as the erased word, which is E185's whole subject. A capture constructor is applied at one site so its fields never merge, which is why E186 ruled them `concrete`. Both calls were resolving symptoms of this criterion. ⚑ **The comment above `shape-eq` overstates `arrow-key-eq`.** It reads that `(-> I64 I64)` and `(-> Str Bool)` share one key. They do not: `cod-key-eq` splits `Bool` from `I64`. The sentence describes `shape-eq` alone. ⚑ **The published criterion is finer, and the tree's has no published occupant.** [[records/findings]] FD-18 measured Pottier and Gauthier giving two data types and two dispatchers where the tree gives one of each (`POLYDEFUNCX:172-173`), and found no source treating a split criterion coarser than source arrow-type equality and finer than one indexed sum. ⚑ **Two halves, and only one is `PRB-` shaped.** The false comment is a defect and keeps this row. The COARSENING itself is a deliberate design choice, `This is what makes defunctionalization erasure-aware`, whose cost is now measured, which is `LIM-` shaped and is carried by `.planning/TAL-CONFORMANCE-QUEUE.md` rather than by a second row restating this one. Whether to split is the author's, and it is cheap if taken: FD-18 measured route one as costing zero new `TalTy` constructors, zero new `Instr` forms and zero change to `tal-ty=?`, because `tt-data`, `i-con` and `tt-case` already are the closed sum, its injections and its dispatch, and the whole-program charge is paid by `closconv-sig` running over one whole `Sig`.
- evidence: `lib/lowering/upper/closconv.chiral:337-340`, `lib/lowering/upper/closconv.chiral:343-350`, `lib/lowering/upper/closconv.chiral:365-376`, [[records/findings]] FD-18, [[decisions/decision-erased-word-level]]
- checked:  2026-09-08
- owner:    enforcement/N16
- from:     FD-18

### PRB-77 the catalog calls preserve-check a translation validator, and the arity refutes it

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    element
- about:    docs/elements/catalog.md
- claim:    `docs/elements/catalog.md:484`, E169: `preserve-check is ALREADY a translation validator -- it re-checks every compiled body against its declared type, per-compilation, which is structurally the technique CompCert uses for the passes it does not prove outright.`
- measured: **False by arity, and [[records/findings]] FD-20 measured the definitions it fails.** A translation validator is a function of TWO programs. FD-20 pinned four statements of it: CompCert's `Validate(S, C)`, `check_function (rtl) (ltl) (env)` in `COMPCERTALLOC`, `V : Source x Target -> boolean` in `VALSCHED`, and `transf_c_program_correct` relating `Csem.semantics p` to `Asm.semantics tp`. `ck-prog` is `(-> CEnv Prog TckR)` (`lib/lowering/tal/check.chiral:308`) and both arguments are target-level, so accepting a program witnesses target well-typedness alone, which FD-20 places as TALTR's Corollary 6.3 over this target and nothing further. Re-checking a body against its DECLARED type is a target-internal judgment and the declared type is part of the same artifact, so no source program is consulted at any point. ⚑ **The tree already holds its own refutation as a measurement.** [[records/enforcement-arc]] EN-20: `arm-body`'s `(none)` arm emits `const 0`, the literal matched the declared return when the codomain was ground, `ck-prog` accepted, and the target returned `0` where the source returned `30`. A target-well-typedness check accepted a program that did not preserve the source's meaning, which is exactly the gap this catalog sentence claims is closed. ⚑ **And the honest version of the sentence is available.** FD-20 measured `lib/lowering/tal/eval.chiral` (187 lines) and `lib/evidence/interp.chiral` (109 lines) as the target and source halves a real validator would be built on, both with zero importers, re-measured 2026-09-08.
- evidence: `docs/elements/catalog.md:484`, `lib/lowering/tal/check.chiral:308`, [[records/findings]] FD-20, [[records/enforcement-arc]] EN-20
- checked:  2026-09-08
- owner:    none
- from:     FD-20

### PRB-78 `i64->str` segfaults on `INT64_MIN`, because negation overflows to itself

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/prelude/prelude.chiral
- claim:    `lib/prelude/prelude.chiral:87` declares `(extern i64->str (-> I64 Str))`, a total function over `I64` with no refinement narrowing its domain. Seventeen modules under `lib/` call it.
- measured: **2026-09-08: one input kills the process. `(put (i64->str (shl 1 63)))` dies with SIGSEGV, exit 139**, under the promoted compiler at `f639acf` and under every generation built during `E189`. Isolated with a two-line probe, and the control `(put (i64->str (- 0 1)))` prints `-1` and exits 0. The cause is in the TAL implementation: `erase.chiral:118` binds the extern to `nb-i64s`, whose body at `lib/lowering/tal/bytes.chiral:294-309` takes the negative branch through `(ti-prim 7 (op-sub) 1 0)`, which is `0 - n`. For `INT64_MIN` that wraps to `INT64_MIN` again, so the value stays negative, the digit loop never reaches its bound, and the write runs off the cell. **The defect predates `E189`** and was found by it: `E189`'s gate needs `2^63` as an operand, so `prog/e189-widening-multiply.prog` routes around it with 16-nibble unsigned hex rather than widening its own write surface, and says so at its `:16-21`.
- evidence: `lib/prelude/prelude.chiral:87`, `lib/lowering/tal/erase.chiral:118`, `lib/lowering/tal/bytes.chiral:294-309`, `prog/e189-widening-multiply.prog:16-21`, commit `c86b007`
- checked:  2026-09-08
- owner:    none
- from:     none
- element:  UNASSIGNED. No roster row holds it. `emitted-speed/X8` and `X9` are the nearest open rows and neither reaches the prelude's string layer

### PRB-79 `refine.chiral` defers its own second half to `E41`, which is region types

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/typing/refine.chiral:7
- claim:    `lib/typing/refine.chiral:7` closes the file's header with its non-goal and routes it: `Non-goal: the full-predicate REFACTOR (solver, inter-variable arith) -> E41.` That arrow is the one pointer the typing tier gives for who owns arithmetic over the refinement domain, and `:1-7` establishes that what E9 built is the decision procedure alone.
- measured: **2026-09-09: `E41` is a different subject and will never build it.** `docs/elements/catalog.md:168` gives `E41` as `Region types (retire runtime offset/bounds checks)`, edge 3, reference class `region calculus (Tofte–Talpin)`, track SH. Regions are a memory-lifetime discipline. That element carries no predicate solver, no arithmetic over `Constraint` (`lib/typing/refine.chiral:13-18`), and nothing that would derive one interval from another. So a reader following the deferral lands on an element whose title, reference class and edge are all about storage, and the deferred half stays unowned: a search of `docs/arcs/` for a roster row over inter-variable arithmetic returns none, and `GAP-23` records the absence. Recording the misdirected pointer is a fact about the tree, and this row defers nothing of its own. ⚑ **2026-09-10: the measurement above is half right, and the half that is wrong is load-bearing.** `docs/elements/specs/E41-region-types-SPEC.md` is `status: audited`, and its §1 deliverable is a *"**linear arith-expression bound**"*, a *"sum of atoms"* against an atom, `(<= (+ o s) cap)`, in `refine.py`'s entailment, with §3 decision 2 reading *"**RESOLVED: E41 owns it**"* and naming E22's refined cursor and E25's byte-cell faces as the consumers it owns it for. So E41 does carry arithmetic over `Constraint`, and it is the catalog row and the ledger row that omit the subject. What that SPEC puts outside E41 is *"the **general/nonlinear** refinement solver"*, in its own non-goals. The repoint this row asks for therefore splits two ways: the linear sum stays E41's, and the rest of `refine.chiral:7`'s `full-predicate REFACTOR` is `enforcement/N22`'s, which is a saturated application admitted as a refinement atom's operand plus a `=>` value binder visible to the atoms of the seats after it.
- evidence: `lib/typing/refine.chiral:1-7`, `lib/typing/refine.chiral:13-18`, `docs/elements/catalog.md:168`, `docs/elements/specs/E41-region-types-SPEC.md:29-42` (§1 deliverable and non-goals), `:75` (§3 decision 2), `docs/arcs/enforcement-arc.md` `enforcement/N22`
- checked:  2026-09-10
- owner:    `enforcement/N22`
- from:     none
- element:  `E41` is minted and owns the linear sum alone, so it is cited here and is half of the fix. `enforcement/N22` holds the other half and is `unminted`.

### PRB-80 the three-permutation ranking has no word-width column, and this substrate charges for width

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    doc
- about:    .planning/CRYPTO-TRANSLATION.md
- claim:    `.planning/CRYPTO-TRANSLATION.md:128` states that at a 256-bit mark three permutations are conformant and the choice falls to other terms, then ranks them in one table at `:131-135` on two columns, state and rounds: Ascon-p at 40 B and 12 rounds, Xoodoo at 48 B and 12, Keccak-f[400] at 50 B and 20. `:125` gives the reading the table serves, `ops per byte move hard. State size holds`.
- measured: **2026-09-09: lane width is a term this substrate charges for on every operation, and the ranking has no column for it.** Every lane in this tree is an `I64`, so a permutation whose lanes are narrower pays a mask wherever the value must wrap. Measured in the built kernel: `add32` (`lib/crypto/chacha.chiral:20`) is `(band (+ a b) M32)`, two prim applications against the one a 64-bit lane add costs, and `rotl32` (`:24-25`) is `(band (bor (shl x n) (shr x (- 32 n))) M32)`, five prim applications against the three the 64-bit rotate idiom costs. `docs/arcs/parts/emitted-speed-X8.md:358` counts the same expression as four operations with the constant subtract folded, and records that a 64-bit rotate primitive buys nothing here, because the wrapped bits of a 32-bit value land at bit 32 and above and a mask drops them. That design also records the 32-bit lane as `C32` and `B8` and states `docs/arcs/emitted-speed-arc.md` does not schedule it, so the cost stands for as long as the ranking is used. The fix owed is the column, and it is owed whichever way the column falls. ⚑ **No candidate's lane width is asserted here.** `.planning/sources/` pins `ASCONSPEC` and `FIPS202` and holds no Xoodoo specification; the only occurrence of the name under the pins is a navigation link in `KECCAKSUM.txt:106`. Turning this into a ranking needs a `research` run that pins each candidate's lane width first.
- evidence: `.planning/CRYPTO-TRANSLATION.md:125`, `.planning/CRYPTO-TRANSLATION.md:128`, `.planning/CRYPTO-TRANSLATION.md:131-135`, `lib/crypto/chacha.chiral:20`, `lib/crypto/chacha.chiral:24-25`, `docs/arcs/parts/emitted-speed-X8.md:358`, `.planning/sources/KECCAKSUM.txt:106`
- checked:  2026-09-09
- owner:    crypto-primitives/K2
- from:     none
- element:  unminted. `crypto-primitives/K2` is the permutation module row and inherits the choice directly. `crypto-primitives/K13` is the target declaration row, which is where width would become a stated term of a target.

### PRB-81 the compiler labels 182 body-compile failures as extern refusals

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/compile-back.chiral
- claim:    `docs/elements/catalog.md` E184 R2: `skipped`'s reason is itself a closed sum carrying evidence, `extern-with-no-wrapper naming the op`, `type-does-not-peel naming which type and where`, `callee-cascade naming the chain`, and E157's rule applies unchanged so a `str-cat`'d sentence here reintroduces what E157 removed.
- measured: **The compiler labels a body-compile failure as an extern refusal, 182 times.** `lib/lowering/compile-back.chiral:271` wraps EVERY term-level `le-skip` as `(mk-skrec name (sk-extern er))`, and `lib/lowering/skip-diag.chiral:28` renders `sk-extern` as the tag `"extern"`. Measured by [[records/enforcement-arc]] EN-28 over 69 roots: the term-level channel produces **182** records in three classes (`higher-order application` 162, `lambda stays upper` 10, `body is not a lambda chain` 10), and `filter-erasable` produces **5** genuine extern-with-no-wrapper refusals. All 187 carry the same constructor and the same tag, so **182 of 187 things the compiler calls an extern refusal are not one**, a 97% misattribution on that tag. ⚑ **Mechanical rather than cosmetic.** A reader or a gate counting `extern` skips reads 187 where 5 is the true figure, and the three real classes have no tag at all. E184's R2 names three reason constructors, and this is why one of them is doing four jobs. ⚑ **Mints nothing.** [[decisions/decision-def-partition]] settles that the partition is E184's R1 identically, so this is R2's evidence half and E184 owes it.
⚑ **RE-CLASSIFIED 2026-09-10 by [[records/findings]] FD-24: this row is UNDER-CLASSIFICATION and it was read as restatement drift in session.** The distinction decides an open decision. Under-classification is one constructor serving four causes, which is what the 182 of 187 measures, and it argues FOR a wider report sum. Restatement drift is a mirrored sum falling out of step with the source it copies, and FD-24 measured that **nothing in this tree is an instance of it**: GHC is the surveyed case, hand-maintaining `HsSyn` against `TH.Syntax` with its authors recording the drift, and its answer was to stop mirroring. Reading this row as drift put it on the wrong side of E184's decision 2.
- evidence: `lib/lowering/compile-back.chiral:271`, `lib/lowering/skip-diag.chiral:28`, `lib/lowering/skip-diag.chiral:15-16`, [[records/enforcement-arc]] EN-28, [[decisions/decision-def-partition]]
- checked:  2026-09-09
- owner:    E184
- from:     EN-28

### PRB-82 refine.chiral routes the solver refactor to E41, which is region types

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/typing/refine.chiral
- claim:    `lib/typing/refine.chiral:7`: `Non-goal: the full-predicate REFACTOR (solver, inter-variable arith) -> E41.` `docs/arcs/parts/enforcement-N18.md` §4 Shape 3 rests on that line, routing the widening of `operand-ok?`'s admissible operand to E41 and declining to open a row on the strength of it.
- measured: **E41 is about region-based memory management and its rows say nothing about a refinement solver.** `docs/elements/catalog.md` reads `E41 | Region types (retire runtime offset/bounds checks) | discipline lib only; edge 3 | region calculus (Tofte-Talpin) (PAPER)`, and `docs/elements/ledger.md` reads `E41 | regions | design | Region types (retire runtime offset/bounds checks)`. Neither mentions predicates, entailment, a solver or inter-variable arithmetic. Tofte and Talpin's region calculus is a memory-allocation discipline, so the reference class does not carry the subject either. ⚑ **The two subjects meet only at the phrase `bounds checks`.** A region type retires a bounds check by making the allocation's extent static; a refinement solver retires one by proving the index in range. Same symptom, different mechanism, and the tree's own `arc-open` collision rule is about exactly this. ⚑ **What rests on it.** `enforcement/N18` §4 Shape 3 is the enabling change every other shape in that design terminates at, and §5 chose Shape 6 **with Shape 3 as the mechanism and its ownership deferred**. That design states the residue in its own words: whether an application, as distinct from inter-variable arithmetic, is inside E41's scope `is named by no artifact in the tree`. This row is that artifact. Until it is settled, the widening has no owner: E41 by a comment whose element is about something else, or a row nobody has opened. ⚑ **SETTLED 2026-09-10 by E41's own SPEC, and the answer is a split.** `docs/elements/specs/E41-region-types-SPEC.md` (`status: audited`) §1 scopes that element's refinement half to a *"**linear arith-expression bound**"*, a sum of atoms against an atom, and lists *"the **general/nonlinear** refinement solver"* in its non-goals; §3 decision 2 reads *"**RESOLVED: E41 owns it**"* for that sum and names E22's cursor and E25's byte-cell faces as its consumers. **Two things follow.** First, the measurement above is true of the catalog and the ledger and false of the element: E41 does carry arithmetic over `Constraint`, and its two one-line rows omit it. Second, the widening is still outside E41, on the SPEC's own words: a saturated application falls outside that sum, and a binder's scope carries no arithmetic at all. **This contradicts `docs/arcs/parts/enforcement-N18.md` §5 question 5**, which recorded the narrower question as *"named by no artifact in the tree"*; the SPEC is that artifact, read from E41's side. `enforcement/N22` is the row, opened in `docs/arcs/enforcement-arc.md` on 2026-09-10 at `origin` `pair`, `req` 1, `state` `open`. `lib/typing/refine.chiral:7` is compiler source inside the blob and is left standing under [[working-discipline]]'s build rule. **What it should read**: the linear sum `(<= (+ o s) cap)` goes to E41, and the application operand and the `=>` binder scope go to `enforcement/N22`. ⚑ **2026-09-11: the citing side reads that, and this row stays OPEN on the comment.** A `revisit` of `docs/arcs/parts/enforcement-N18.md` against this row (`records/enforcement-arc.md` EN-34, commit `e58aa32`) returned AMEND and marked ten sites in that design: §2's routing paragraph, §3's verdict, §4 Shape 3's Owner, §4 Shape 6, the shape-dependency table, §5's call, §5 questions 4 and 5, and three places in §6. §5 now reads *"Shape 6, with Shape 3 as the mechanism, owned by `enforcement/N22`"*, and §4 Shape 3's claim that the narrower question *"is named by no artifact in the tree"* is corrected against E41's SPEC. Shape 3's capability, its term-keyed-fact cost and its `C1 == C2` build price were re-tested at HEAD `bffa265` and are intact, so only the ownership sentences moved. **This row stays `OPEN` because its subject is `lib/typing/refine.chiral:7`**, which still carries the whole arrow and is compiler source inside the blob, left standing under [[working-discipline]]'s build rule.
- evidence: `lib/typing/refine.chiral:7`, `docs/elements/catalog.md` E41, `docs/elements/ledger.md` E41, `docs/elements/specs/E41-region-types-SPEC.md:29-42`, `:75`, `docs/arcs/parts/enforcement-N18.md` §4 Shape 3 and §5, `docs/arcs/enforcement-arc.md` `enforcement/N22`, [[records/findings]] FD-26, `records/enforcement-arc.md` EN-34 (the 2026-09-11 AMEND, commit `e58aa32`)
- checked:  2026-09-11
- owner:    `enforcement/N22`
- from:     none

### PRB-83 check AE reads a prose mention as arc membership

- state:    FIXED
- author:   unreviewed
- note:     none
- level:    source
- about:    tools/ledger-lint/ledger-lint.py
- claim:    `docs/goals/README.md:27` states the invariant check AE enforces, and `tools/ledger-lint/ledger-lint.py:1866-1872` says the check refuses silence: an unbuilt element is named by an arc, or the unspoken lens carries it.
- measured: **AE tests a spelling.** `:1883` builds its `named` set with `re.findall(r"\bE(\d+)\b", f.read_text())` over the whole arc file, so any occurrence anywhere counts as belonging. `docs/arcs/tool-authority-arc.md:274` names E148 and E149 inside its boundary section, saying `ls` and `find` "need naming authority for a reason this arc does not address", which is the arc REFUSING them, and AE reads it as coverage. Three more of the same shape: `scriba/S6` is blocked on E132 rather than owning it, `docs/arcs/enforcement-arc.md` calls E154 "E154's fifth instance", and that same file says of E169 "no arc names it (UNS-45)" while the mention itself satisfies AE. Several arc-local row ids spell `E1` to `E4` at `docs/arcs/display-calculus-arc.md:127-130` and count too. `:1888` also skips `built` and `superseded` outright, which drops 95 of the 144 unrostered elements before any test runs. Measured 2026-09-10: **42 of 186 catalog elements hold a roster row and 144 hold none**, while AE reports nothing. The fix is to test roster membership, which `tools/pack/pack.py`'s `row_elements` already parses. ⚑ **FIXED 2026-09-13: the predicate reads the roster cell.** `check_ae` now calls `_homed()` (`tools/ledger-lint/ledger-lint.py:1882`), which walks every `docs/arcs/*-arc.md` through `tools/pack/pack.py`'s own `roster_all` and `row_elements`, loaded by `_load_pack()` (`:1865`) in the shape `_load_frontier()` (`:576`) already established, so this check and `pack.py --mint` hold ONE definition of what a roster row names. **Belonging is a roster row whose element cell carries the number.** A prose mention stops counting: `tool-authority`'s boundary section, `scriba/S6`'s blocked-on note, `enforcement-arc`'s two mentions of E154 and E169, and `display-calculus`'s `E1` to `E4` row ids all fall out, and `bridge/C4`'s cell ``E40`, `E56`` yields E40 and E56 with no E4 in it. The `built` and `superseded` skip is gone, per the author's ruling of 2026-09-10. Multiplicity is allowed and nothing counts seats: E183 reads `diagnostics/W1` and `file-types/K2` and passes on both. ⚑ **Measured against one tree, `5ab2c28` plus this edit: AE went from 0 findings to 100 standing.** 143 of 187 catalog elements hold no roster row; 43 of those carry a row in `records/lenses/unspoken.md`, which `docs/goals/README.md:27` accepts as the admission, so the check refuses the remaining **100**: 93 `built`, 4 whose ledger state cell `_ledger_state()` cannot parse, 2 `design` and 1 `superseded`. ⚑ **The 100 raise `Owed` under the noun `element home` and report five summary lines.** That is the reading check AN already took on 151 lens rulings, and it keeps the other forty checks readable: the full run reads `143 violations found, 100 element homes owed, 27 author calls owed, 173 lens rulings owed, 2 checks that checked nothing`, with every other check's count unmoved. The two mint limbs stay violations and suppress the owed count when either fires. ⚑ **One thing the prompt for this repair asserted is absent from the tree.** No ruling exempts a `superseded` row from homing: `records/homing-triage.md:257` question C asks it and stands unanswered, so E86 is reported rather than skipped, which is what the 2026-09-10 ruling's own words cover. ⚑ **Amended on merge 2026-09-13.** The run reported 100 owed and refused to exempt `superseded`, correctly, because no ruling was recorded. The author had given it on question C of `records/homing-triage.md` and the session had not written it down; it is now a `ruled` row in [[records/author-calls]] and the check reads it, so the owed count is **99** and `E86` is out.
- evidence: `tools/ledger-lint/ledger-lint.py:1865-1880` (`_load_pack`), `:1882-1904` (`_homed`), `:1906-1993` (`check_ae`), `:2616-2621` (the `GUIDE` row for AE), `records/author-calls.md:369`, `records/homing-triage.md:257`, and at `5ab2c28` `tools/ledger-lint/ledger-lint.py:1866-1872`, `:1883`, `:1888`, `docs/arcs/tool-authority-arc.md:274`, `docs/goals/README.md:27`, `records/homing-triage.md`, `tools/pack/pack.py` `row_elements` (`6e9c76a`)
- checked:  2026-09-13
- owner:    none
- from:     none

### PRB-84 one word carries two deferrals, and the tree reads the wrong one

- state:    FIXED
- author:   unreviewed
- note:     none
- level:    doc
- about:    docs/decisions/decision-scope.md
- claim:    `docs/decisions/decision-scope.md` defers the ownership-and-trust track and `docs/elements/ledger.md:36-38` bars `OT` work from current work and its documents from audit.
- measured: **Ruled by the author 2026-09-10: that deferral is an implementation deferral and says nothing about planning.** Homing an element is planning, so a deferred element still takes a roster row. The tree had read the single word the other way and acted on it: `docs/arcs/ownership-and-trust-arc.md:45-48` declines rows for seventeen elements because they "stay deferred with the track", and 13 unrostered `design` orphans were suppressed from the homing queue on the same reading. No vocabulary in the tree separates the two senses, so the next reader repeats it. **FIXED 2026-09-13.** The vocabulary landed at `eb70d68`: `docs/decisions/decision-scope.md:52-87` names **build-deferred** and **plan-deferred** and states that the scope call carries only the first, and `:79-87` separates the track deferral from a blocking condition, with E63 and the absent CHERI hardware as the worked example. This run carried that vocabulary into the two files that still contradicted it. `docs/elements/ledger.md:36-41` marks `OT` **build-deferred** and cites the section for the reach instead of restating one undifferentiated deferral; the audit exemption stands there on its own reason. `docs/arcs/ownership-and-trust-arc.md:53-66` replaces the sentence that declined rows for seventeen elements: those seventeen are owed a row, and the shape the author's attached instruction asks of each row is stated for whoever writes them. `:23-28`, `:71-75` and `:103-105` carry the same correction into the arc's header, its coverage and its resume state. No roster row was written and nothing was homed; that is its own unit. A search over `docs/` and `records/` found no third site declining to plan, name, roster or design on the strength of the track deferral. `docs/elements/catalog.md:54` repeats the decision's own instruction without a pointer to the reach section and declines no planning, so it is a restatement owed a pointer and no instance of this defect.
- evidence: `docs/decisions/decision-scope.md:52-87` and `:79-87`, `docs/elements/ledger.md:36-41`, `docs/arcs/ownership-and-trust-arc.md:23-28`, `:53-66`, `:71-75`, `:103-105`, `records/author-calls.md` the row "Whether the orphan program reaches the `OT` track", ruled at `d307682`, `records/baseline-alignment.md` BA-45, `docs/elements/catalog.md:54` (the source bullet the LEDGER Track column mirrors, given the same pointer on merge)
- checked:  2026-09-13
- owner:    none
- from:     none

### PRB-85 the one-arc invariant is written in three places and the author ruled it wrong

- state:    OPEN
- author:   ruled 2026-09-10
- note:     elements dont only belong to one arc fix that doc
- level:    doc
- about:    docs/goals/README.md
- claim:    `docs/goals/README.md:27` states "An element belongs to at least one arc, or the unspoken lens says nobody has ruled on it", and `:32` states that an element whose components serve two goals sits in both arcs.
- measured: **Ruled by the author 2026-09-10: elements do not belong to only one arc.** Two of the three homes were repaired 2026-09-13. The prose home now reads at-least-one, and `docs/goals/README.md:32` states the plural case outright with `E44` as its worked example, which dissolves the author call the old sentence created instead of answering it. The **48 `claim` fields** in `records/lenses/unspoken.md` re-quote the corrected sentence and all 48 rows stay open: each measures an element that no arc names at all, and zero arcs fails at-least-one as surely as it failed exactly-one. No `measured` field moved. The remaining home is `ledger-lint` check AE, where the defect is prose and never was behaviour: `check_ae` refuses only silence and carries no multiplicity test, so what still states the overturned invariant is the sentence quoted in its docstring at `tools/ledger-lint/ledger-lint.py:1868`. This row's count of three homes is low. `README.md:177` states the old rule live and outside the repair's write surface; `docs/decisions/decision-four-lenses.md:24` and `:60`, `records/author-calls.md:367`, `.planning/README-PLAN.md:108` and `.planning/BOUNDS-AUTHOR-CALLS.md:566` carry it as the argument of their own day. ⚑ **The tool home is repaired 2026-09-13, and it was two statements rather than the one this row counted.** `check_ae`'s docstring (`tools/ledger-lint/ledger-lint.py:1906`) now quotes `docs/goals/README.md:27` at its corrected wording and carries `:32`'s plural case in its own words, and `ledger-lint`'s `GUIDE` row for AE (`:2616-2621`), which restated the same invariant one screen away and which this row never named, was corrected in the same edit. `grep -rn 'exactly one arc' tools/` now returns nothing. The repair is prose only: `check_ae` never tested multiplicity, and the rewritten predicate passes E183 on two rosters. ⚑ **The row stays OPEN on one LIVE carrier, and `revisit` is the instrument for it.** `docs/decisions/decision-primitive-with-consumer.md:125-128` reads *"[[goals/README]] `:27` makes an element belong to exactly one arc, so the seat has to be picked and this document does not pick it"*, present tense, in a settled decision under `## What this does not rule on`. It states the dead rule and reasons from it, so a current decision document still carries the invariant and an open question of its own rests on a premise the ruling dissolved. ⚑ **And the last repair of that paragraph is now stale.** `records/bounds-residue.md:29-31` fixed it on 2026-09-10 by repointing it at `docs/goals/README.md:27`, which is the sentence overturned that same day, so that row's `FIXED` names a citation that no longer says what it was repointed to say. Neither document was in this unit's write scope. What closes this row is one `revisit` of [[decisions/decision-primitive-with-consumer]] against the ruling.
- evidence: `docs/goals/README.md:27`, `docs/goals/README.md:32`, `tools/ledger-lint/ledger-lint.py:1906-1915` and `:2616-2621` as repaired (at `5ab2c28` the docstring line was `:1868`), `docs/decisions/decision-primitive-with-consumer.md:125-128`, `records/bounds-residue.md:29-31`, `records/lenses/unspoken.md` (48 rows re-quoted), `README.md:177`, `records/homing-triage.md` question G, `README.md:177` (corrected on merge 2026-09-13), `docs/decisions/decision-primitive-with-consumer.md:125-128`, which is a LIVE dependency where the other five are history: it leaves "which arc holds a pair whose halves sit in different arcs" open **because** the invariant forced a single seat, so the ruling dissolves its premise and that open question is owed a `revisit`)
- checked:  2026-09-13
- owner:    none
- from:     none

### PRB-86 nothing measures the goal-arc-element chain

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    tools/lens/lens.py
- claim:    `docs/arcs/README.md:28-29` makes the chain the model: an arc is elements assembled toward one goal, an element is one catalog item. `docs/definitions/OVERVIEW.md` is the generated view across every arc, and `ledger-lint` runs forty-odd checks.
- measured: **The spine of the model is unmeasured.** 42 of 186 catalog elements hold a roster row and 144 hold none, measured 2026-09-10 at `d307682`; 106 of the 144 are named in no arc file at all. Nothing in the tree reported it, and it surfaced only because a session wrote a throwaway script. Both ends of the chain have holes: `docs/goals/self-hosting.md:70` says the goal carries no arc and none is owed, which by construction leaves 55 built elements with nowhere to sit, and `docs/arcs/terminal-arc.md` was opened 2026-09-10 serving a goal that states no terminal condition. PRB-83 is why the one check aimed at this reports nothing. A generated coverage view belongs beside `lens.py overview`, and the rungs it should report are settled by the author's rulings of 2026-09-10.
- evidence: `docs/arcs/README.md:28-29`, `docs/goals/self-hosting.md:70`, `records/homing-triage.md`, `docs/arcs/terminal-arc.md` FLAG 1, [[records/lenses/problems]] PRB-83
- checked:  2026-09-10
- owner:    none
- from:     none
