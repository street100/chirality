

### PRB-01 the `check` CLI gate never exercises an emit-stage refusal

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    tools/test/check-cli.sh
- claim:    the header of the gate says the cases "pin that it ACCEPTS well-typed source and REFUSES ill-typed source", and that a checker which only ever says OK is not a checker.
- measured: 7 assertions. 3 positive, 4 negative. All four negatives are front-end refusals: two linear binder usage mismatches, one type mismatch, one unknown name. Zero exercise a lowering or emit refusal, which is where the E76 chokepoint, the H8 profile gate, duplicate label and the missing heapptr cell live. See BA-05 for why that matters.
- evidence: `tools/test/check-cli.sh:41-60`
- checked:  2026-09-01
- owner:    none
- from:     BA-04

### PRB-02 three failure classes collapse into one exit code

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/compile-all.chiral
- claim:    `bin/chirality check FILE` is documented as "type-check (compile, discard the ELF)".
- measured: `compile-all` maps `fr-err` (parse, elaborate, typecheck), `br-err` (lowering) and `elf-err` (emit) all to `ca-err`. `prog/compiler.prog` maps every `ca-err` to exit 1, and `cmd_check` reports any nonzero exit as `chirality check: FILE FAILED (exit 1)`. Reproduced with a well-typed program declaring `(profile p (ports halt) ...)` while calling `put`: the CLI printed `FAILED (exit 1)`, the same headline and the same exit code as `(def f (-> I64 I64 I64) (lam (n) n))`. The compiler's own message does survive to stderr (`E76 profile REFUSED emit: crossing put (wrap-put) is outside the declared profile port set`), so the reason survives. What is lost is the classification: nothing in the exit code or the CLI's verdict line separates the program's types from the emitter's verdict.
- evidence: `lib/lowering/compile-all.chiral:17-38`, `bin/chirality:174-178`, `bin/chirality:192`
- checked:  2026-09-01
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

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    doc
- about:    docs/definitions/testing-floors.md
- claim:    `docs/definitions/testing-floors.md` lists a rocq floor invoked as `chirality test-rocq`, GATING on well-formedness, and a python oracle floor invoked as `chirality test-python`, ADVISORY.
- measured: external judgment is cut by author decision (CLAUDE.md, HANDOFF decision 5). `bin/chirality`'s dispatch accepts `compile`, `run`, `check`, `test`, `help` and nothing else. Neither subcommand exists. CLAUDE.md states the absence is deliberate: a subcommand dispatching to a floor this tree lacks is a gate that cannot fail.
- evidence: `docs/definitions/testing-floors.md:50-51`, `bin/chirality:210-219`
- checked:  2026-09-01
- owner:    none
- from:     BA-08

### PRB-05 the fixture count is off by 44

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    doc
- about:    docs/decisions/decision-scope.md
- claim:    `docs/decisions/decision-scope.md`'s state table says `tools/test/samples/` holds 98 files.
- measured: `ls tools/test/samples/ | wc -l` counts 54. Four of the gap is the C-leg fixture drop at `d0c5dd5`, which removed `e166_c_assemble.prog`, `e166_ddc_legc.prog`, `e166_mach_c.prog` and `e166_mach_c_reject_lda6.prog`. The other 40 is older drift and is undiagnosed.
- evidence: `docs/decisions/decision-scope.md`:57` (the fixtures row), commit `d0c5dd5`
- checked:  2026-09-01
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
- measured: blob closures for the six top-level `.prog` roots, counted as `^(end-module "` markers and blob bytes: | root | modules | blob bytes | |---|---|---| | `prog/compiler.prog` | 58 | 772,967 | | `prog/paren-audit.prog` | 58 | 783,086 | | `prog/prose-lint.prog` | 58 | 780,557 | | `prog/wield.prog` | 58 | 774,101 | | `prog/test-runner.prog` | 61 | 865,722 | | `prog/resolve.prog` | 15 | 68,429 | `paren-audit` and `prose-lint` are text tools. They carry the whole compiler including the x64 backend and the ELF assembler because each imports `lowering/compile-all` for `read-fd-all`, a ten-line fd reader. A tools tier of `prelude/prelude`, `prelude/list`, `prelude/string`, `ports/fd`, `ports/stdio` resolves to 6 modules and 27,222 bytes, measured with a probe root. ⚑ Re-measured 2026-09-04 against `1fcb019`, by the same method. The shape holds and every figure moved, because E11 put `typing/totality` and `typing/totality-check` into the compiler's closure: | root | modules | blob bytes | |---|---|---| | `prog/compiler.prog` | 60 | 807,767 | | `prog/paren-audit.prog` | 60 | 817,886 | | `prog/prose-lint.prog` | 61 | 844,110 | | `prog/wield.prog` | 60 | 808,901 | | `prog/test-runner.prog` | 63 | 900,522 | | `prog/resolve.prog` | 15 | 69,581 | The 2026-09-01 column above stands as what it measured. `prose-lint` gained one module over the other text tools and still carries the x64 backend and the ELF assembler for a ten-line fd reader, so the row stays OPEN on its own terms.
- evidence: `prog/paren-audit.prog:34`, `prog/prose-lint.prog:32`, `lib/lowering/compile-all.chiral:41-48`
- checked:  2026-09-04
- owner:    none
- from:     BA-16

### PRB-09 the reader collision was routed around locally

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/module/resolve.chiral
- claim:    a fix in one module is the tree's fix.
- measured: `lib/module/resolve.chiral` named its own fd reader `slurp-fd` and its header says the rename is load-bearing: `compile-all` defines a `read-fd-all` of its own, the two modules meet in one blob via `lib/evidence/test-floor.chiral`, and two defs of one name is `duplicate label`. So someone already hit the consequence of BA-16 and moved their own name out of the way. The reader is still duplicated and `read-fd-all` still lives inside the compiler's closure.
- evidence: `lib/module/resolve.chiral:58`, `lib/lowering/compile-all.chiral:47`
- checked:  2026-09-01
- owner:    none
- from:     BA-17

### PRB-10 a citation inside a source comment is read by no gate

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/ports/ports.chiral
- claim:    checks G and R are the tree's line-citation gates.
- measured: ⚑ citations repointed 2026-09-05 after ledger-lint.py grew ~400 lines; the measurement itself was NOT re-taken, so this row stays unverified. both walk `docs/**/*.md` and both require the citation to sit inside a backtick code span. `lib/` and `prog/` comments carry 59 line-numbered citations across 34 files, and not one is inside a code span or inside a doc. BA-13 is one of them: `(compile-emit.chiral:189)` in a `;` comment, bare parentheses. R could not reach it even with BA-02 fixed, and R's DEFINED-here limit rules it out a second time, because `native-lib` is defined in `lowering/tal/bytes.chiral:636` rather than in the file the comment cites. A gate for this class would be a third predicate. Neither existing one widens to reach it.
- evidence: `lib/ports/ports.chiral:28`, `lib/lowering/tal/bytes.chiral:636`, `tools/ledger-lint/ledger-lint.py:379` (check G), `:443` (check R)
- checked:  2026-09-01
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

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    tools/ledger-lint/ledger-lint.py
- claim:    check A is "ledger evidence paths exist".
- measured: 5 issues, all module keys rather than paths: `surface/pretty`, `typing/pretty`, `surface/parse`, `typing/`. `is_pathish` accepts any token containing a slash, and `resolve` then tests `ROOT/surface/pretty`, which is nowhere a module lives. E181's row added the ones that fail today, so the check went red on a correct citation. It is the mirror of BA-02: a check whose resolver does not know the tree's own naming rule. `docs/decisions/decision-scope.md` still records check I as the only FAIL, which predates this. ⚑ Re-measured 2026-09-04: check A reports 0 issues, and the row stays OPEN because that is no fix. `is_pathish` at `tools/ledger-lint/ledger-lint.py:64` is unchanged since `ffffb9a`, and it still reads any token holding a slash as a filesystem path. What moved is the subject: `b5994d0` rewrote the ledger and the module keys it cites now sit in bold rather than inside the backtick code spans check A scans, so `typing/pretty` at `docs/definitions/status-ledger.md:66` is invisible to the check. The next module-key citation written inside a code span fires it again. Do not close this row on the green check.
- evidence: `tools/ledger-lint/ledger-lint.py:64` (`is_pathish`), `docs/definitions/status-ledger.md:66`, `:68`
- checked:  2026-09-05
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
- measured: code does pass through TAL IR: `compile-emit` imports `lowering/tal/reify` and `lowering/x64/emit`. The check on that IR does not run. `ck-prog` and `ck-block` have zero callers. `ck-fn`'s only caller is `re-check` at `lib/lowering/upper/optimize.chiral:250`, and `optimize.chiral` has zero importers, so the one call site is unreachable. The compile path is `compile-front` then `compile-back` then `compile-emit`, and none of the three references a tal check. ⚑ Re-measured 2026-09-04, and the row stays OPEN. The unreachability is unchanged: `ck-prog` has zero callers, `ck-fn`'s only caller is `re-check` at `lib/lowering/upper/optimize.chiral:250`, `optimize.chiral` has zero importers, and `compile-emit` imports `lowering/tal/reify` and `lowering/x64/emit` and no tal check. Two blockers under it moved. `5b4fb71` prefixed eleven of the module's internal names `tck-`, so `lib/lowering/tal/check.chiral` loads beside `typing/kernel` without the `data redeclared: CkR` collision its own header at `:26` records, which is what wiring it needs. `ddfbc27` made `ck-prog` agree with the compiler and added Phase 22 as `tools/test/tal-check.sh`: 16 hand-built TFns, nine REJECT rows, three mutants. ⚑ Phase 22 is unregistered in `tools/test/run-tests.sh` by decision, the `crypto.sh` precedent, so the suite's 339 excludes it and it runs by hand. `tools/test/tal-check.sh:380` gate G17 pins this row's subject as a green assertion: no module under `lib/` or `prog/` imports both `typing/kernel` and `lowering/tal/check`.
- evidence: `lib/lowering/tal/check.chiral:26`, `:289`, `:308`, `lib/lowering/upper/optimize.chiral:250`, `lib/lowering/compile-emit.chiral:14-18`, `tools/test/tal-check.sh:380`
- checked:  2026-09-04
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
- measured: `(def bad (refine I64 (> 9223372036854775807)) 0)` passes `chirality check`. The same file at `9223372036854775806` and at `10` both give `load: cannot prove refinement`, so the gate is armed and only the extreme escapes. `c-atom` builds `s-gt` as `(max-lo lo (+ k 1))` and `s-lt` as `(min-hi hi (- k 1))`; at `I64_MAX` the `+1` wraps to `I64_MIN` and the bound inverts to TOP. The non-adjusting operators `>=` and `<=` are correct at the same extremes. A contradictory `{v > MAX and v < MIN}` compiles, links and runs. `.planning/audit/AUDIT-MAP.md` records this as D1, "UNSOUND if ported naively, open, no current bug"; the port happened without the guard, so the last clause is false. E11 ported the same arithmetic with the guard (`lib/typing/totality.chiral:257`, `:262`), so the obligation was written once, into the other element's contract.
- evidence: `lib/typing/refine.chiral:118`, `:120`, `lib/typing/kernel.chiral:1349`, `:1488`, `lib/typing/totality.chiral:257`, `:262`
- checked:  2026-09-01
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
- measured: not dead, and not this repo's. All eleven name files under `/workspace/manas/.planning/`, and all five exist on disk: `METIS-PORT-SPEC.md` (6 citations), `scriba-examples/S1-puffer.md` (2), `S1-puffer-AUDIT.md` (1), `S2-S3-rendering-loop.md` (1), `S2-S3-rendering-loop-AUDIT-v2.md` (1). The fragility is a different class: manas has no `.gitignore` rule for `.planning/` and tracks 45 files under it, but `git ls-files --error-unmatch` reports all five UNTRACKED, so they exist on one laptop's disk and a fresh clone of either repository reaches none of them. Two forms are also unopenable from this repo with manas present — `manas/.planning/...` at `S1-puffer-SPEC.md:6` and `[[../manas/.planning/...]]` at `:374`, `:375` are relative and resolve only from `/workspace/`. Not repaired: copying another repo's design spec in is an author call, and absolute `/workspace/manas/...` encodes one laptop's layout. Separately and genuinely dead: `docs/elements/specs/E94-form-type-capacity-SPEC.md:101` cites `.planning/E94-diagnostic.md`, which `find` locates in none of chirality, manas or metis-the-lang.
- evidence: `docs/elements/catalog.md:222`, `docs/examples/E133-manas-core-types.md:37`, `docs/examples/E134-gate.md:39`, `docs/examples/E135-bind.md:42`, `docs/examples/E136-match-assemble-stop.md:35`, `docs/examples/E138-run-loop.md:39`, `docs/elements/specs/S1-puffer-SPEC.md:6`, `:374`, `:375`, `docs/elements/specs/S2-rendering-SPEC.md:6`, `:7`, `docs/elements/specs/E94-form-type-capacity-SPEC.md:101`, `records/consolidation-handoff.md`
- checked:  2026-09-01
- owner:    none
- from:     BA-38

### PRB-27 E173's SPEC mutant M3 is inert, because termination is not enforced

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/typing/totality-check.chiral
- claim:    `docs/elements/specs/E173-total-matcher-SPEC.md` §5 carries M3, a mutant that makes `pd`'s `p-star` arm recurse into `(p-star q)` instead of a strict subterm, and asserts `chirality check` refuses it. The SPEC passed its audit at `4769cd2`, and `.planning/protocol/workflow.md` requires every gate row to name a mutant that is actually run.
- measured: M3 does not fail. The mutant was built in a scratch `lib/` copy during E173 step 3 and the module compiled, rc 0. The reason is recorded one tier up and was not consulted by either SPEC audit: `docs/definitions/status-ledger.md:157` states "Termination is neither enforced nor classified in the built compiler", because `lib/typing/totality.chiral` is the built E11 classifier and no module imports it. Measured here: `grep -rn 'import "typing/totality"' lib/ prog/` returns 0. So a gate row asserting a termination refusal passes by looking at nothing, which `docs/decisions/decision-scope.md` names as the error the tree exists to avoid. Not repaired: step 6 owns Phase 19 and the mutant table, and the fix is a spec correction before that step, not a patch to a gate script that does not exist yet. Every function in `lib/text/matcher.chiral` still meets the written criterion of `docs/definitions/totality.md:48-53` by hand, checked at step 3, so the code is not in doubt. The check is. ⚑ Superseded 2026-09-04, and the row stays OPEN on a different mechanism. The zero-importer half is FALSE and had been since termination was wired on 2026-09-02: `lib/typing/totality-check.chiral:62` imports `typing/totality` and `lib/lowering/compile-front.chiral:24` imports `totality-check`, so both sit in the compiler's 60-module closure. What keeps M3 inert is the opt-in: `tot-gate` at `lib/typing/totality-check.chiral:152` reads the composite's profile list first and returns `tot-proven` without classifying a single def unless some profile carries `(total)`. `prog/prose-lint.prog` carries no profile clause, so M3 still observes divergence rather than proving termination and the gate row still passes by looking at nothing. BA-25 carries the repro on both sides of the gate.
- evidence: `lib/typing/totality-check.chiral:62`, `:152`, `lib/lowering/compile-front.chiral:24`, `prog/prose-lint.prog`, `docs/elements/specs/E173-total-matcher-SPEC.md` §5 M3, `.planning/protocol/workflow.md`
- checked:  2026-09-04
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
- measured: a running maximum spelled inline as `(let ((sz (length Thread ts1))) (case (<i hi sz) (true sz) (false hi)))` does not load: `load: cannot prove refinement`. Narrowing a case guard over two *let-bound* `I64`s produces an obligation nothing discharges; two params of a named function are fine, which is what `lib/prelude/prelude.chiral:150`'s `max` is, and the E173 step 6 fixture routes through `max` instead, carrying the measurement as a comment beside the workaround (`tools/test/samples/e173_matcher.prog:100-107`). Surfaced writing that fixture. The mechanism is the family `FD-02` in [[records/findings]] already holds, where the four conditions that trigger it and the refuted first hypothesis are recorded, and `prog/paren-audit.prog:103-107` carries the same workaround for a two-line minimum. What is new here is the alignment: the ledger's path-sensitivity claim and this refusal are both about a comparison guard narrowing an `I64`, and the tension is stated rather than resolved. FD-02 records three coherent fixes differing in what they preserve, so this needs a blueprint before a patch.
- evidence: `docs/definitions/status-ledger.md:155`, `lib/typing/refine.chiral`, `lib/prelude/prelude.chiral:150`, `tools/test/samples/e173_matcher.prog:100-107`, `prog/paren-audit.prog:103-107`, `records/findings.md` FD-02
- checked:  2026-09-01
- owner:    none
- from:     BA-41

### PRB-30 the transport gap is stated in three names, and two of them stopped being externs

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    docs/definitions/status-ledger.md
- claim:    `docs/definitions/status-ledger.md:149`, the orchestration-substrate row, gives the reason the substrate cannot run as `http-request` and `backend-open` having no entry in `lib/lowering/tal/crossing-wraps.chiral`. The owed table in `docs/goals/local-ai.md` adds `chat-open` and says the three have no runtime referent. `.planning/LOCAL-AI-ARC-REALIGNMENT.md` section 3A rests its whole first arc on that reading.
- measured: two of the three are chirality `def`s. `http-request` is defined at `lib/protocol/http.chiral:437` over the socket caps and `chat-open` at `:773`; the catalog files E130 and E131 BUILT for exactly that swap, with the module's own header recording it. `backend-open` is still an `extern` in `prog/manas/backend.chiral` and is erased to `nb-id` at `lib/lowering/tal/erase.chiral:123` under the E144 string carrier, so a crossing entry is the wrong home for it. Every `extern` declared under `lib/protocol/` and `prog/manas/` was checked against both lowering tables: `backend-close`, `backend-open`, `be-base` and `be-peek` erase, `close` crosses, and nothing is unmapped. The conclusion the row draws may still hold, and its stated reason does not: Phase 7 of `tools/test/run-tests.sh` sweeps every root compile-only, no phase performs a model call, and the one root binding a client connect sits on that phase's known-failing list needing a live peer. Repair is `arcs/transport-arc` row T1.
- evidence: `docs/definitions/status-ledger.md:149`, `docs/goals/local-ai.md`, `lib/protocol/http.chiral:437`, `:773`, `lib/lowering/tal/erase.chiral:123`, `lib/lowering/tal/crossing-wraps.chiral`, `tools/test/run-tests.sh:170-174`
- checked:  2026-09-02
- owner:    none
- from:     BA-42

### PRB-31 S18 is recorded as owed in two documents and was built on 2026-08-23

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    docs/goals/local-ai.md
- claim:    the owed table in `docs/goals/local-ai.md` records the `Scriba` state record as a SPEC that exists and is unbuilt. `.planning/LOCAL-AI-ARC-REALIGNMENT.md` section 3B builds its scriba arc on the same reading and makes `S18` the first row.
- measured: `prog/scriba/editor-state.chiral` defines `data Scriba` and is imported across the command layer. `.planning/SCRIBA-PRIMITIVE-CHECKLIST.md:106` records the landing as BUILT 2026-08-23 with two commits and its own correction that every figure in the original row was low: 78 signatures, 367 argument sites over 318 lines, nine threading shapes where the SPEC predicted one 11-parameter thread, and net LOC 0 against a 14.8% blob-byte fall. The cost the goal file cites for the record it calls unbuilt is therefore a cost already paid. Repair is `arcs/scriba-arc` row S1.
- evidence: `docs/goals/local-ai.md`, `prog/scriba/editor-state.chiral`, `.planning/SCRIBA-PRIMITIVE-CHECKLIST.md:106`
- checked:  2026-09-02
- owner:    none
- from:     BA-43

### PRB-32 five documents cite `.gitignore:12` as excluding `.planning/`, and that file says the opposite

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    doc
- about:    docs/elements/README.md
- claim:    `docs/arcs/README.md`, `docs/elements/README.md:16`, `docs/arcs/presentability-arc.md`, `docs/definitions/status-ledger.md:67` and `docs/decisions/decision-dispatch-cadence.md:17` all cite `.gitignore:12` for the planning tier being excluded from git. Three of them draw doctrine from it: a fact written under `.planning/` forks per worktree, dies with it, and cannot be relied on by a second reader.
- measured: `.gitignore:1-9` is a banner headed "the agent tier is tracked", and it names `.planning/`, `CLAUDE.md` and `.claude/skills/` as the agent half of two audiences in one repository, both tracked, citing `docs/decisions/decision-ai-tier.md` for the ruling. Line 12 is a comment introducing `.claude/*`, and the only rules in the file's first block are `.claude/*`, the `!.claude/skills/` exception, `.claude-*/`, `.scratch/`, `*.orig` and `*.rej`. `git check-ignore -v .planning/LOCAL-AI-ARC-REALIGNMENT.md` matches no rule and `git ls-files .planning` returns 140 files. The doctrine those documents carry, that a tracked fact belongs in `docs/` or `records/`, is settled by `docs/decisions/decision-ai-tier.md` on its own terms and survives without the citation. `docs/definitions/status-ledger.md:67` is the harder one: it attributes the exclusion to a master decision that the planning tier is private, so this row is a conflict between two recorded decisions and needs the author before an edit. Not repaired here, and no document was rewritten on one measurement. ⚑ Superseded 2026-09-04. Three of the five are repaired: `docs/definitions/status-ledger.md` at `b5994d0`, `docs/arcs/README.md` and `docs/arcs/presentability-arc.md` at `4139662`. `4139662` also retired two instances the row never listed, both in `docs/arcs/zero-python-arc.md` over `.planning/ZERO-PYTHON-SCOPE.md`, which makes the sixth and seventh. The `status-ledger` case the row sent to the author was settled there: the tier split in `docs/decisions/decision-ai-tier.md` is the live decision and the privacy reading was retired. `git ls-files .planning` returns 145 today, up from 140. The class is wider than five. Eight files carry `.gitignore:12` at `1fcb019`: `docs/elements/README.md:16` and `docs/decisions/decision-dispatch-cadence.md:17` from the row's own list, and `docs/arcs/enforcement-arc.md:17`, `docs/arcs/diagnostics-arc.md:18`, `records/README.md:113`, `records/lane-a-record.md:33`, `docs/benchmarks/test-suite-wall-clock.md:11`, `.planning/DOC-CLEANUP-PASS.md:17`. ⚑ `docs/decisions/decision-dispatch-cadence.md` is repaired in the author's uncommitted working tree, leaving seven on disk. `docs/arcs/diagnostics-arc.md` is also in the author's working tree and was left alone. The other six are outside this stage's scope and stay unrepaired.
- evidence: `.gitignore:1-14`, `docs/elements/README.md:16`, `docs/arcs/enforcement-arc.md:17`, `records/README.md:113`, `records/lane-a-record.md:33`, `docs/benchmarks/test-suite-wall-clock.md:11`, `.planning/DOC-CLEANUP-PASS.md:17`
- checked:  2026-09-04
- owner:    none
- from:     BA-44

### PRB-33 the lowered/skipped ratio is unmeasured, and `skip-reason` is not the mechanism

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/upper/lower.chiral
- claim:    `records/lane-a-record.md` says a large fragment of the language never lowers, and that the lowered/skipped ratio is unmeasured.
- measured: `skip-reason` has no caller. It, `eligible?`, `lower-all`, `lower-def` and `LowRes` are referenced nowhere outside `lib/lowering/upper/lower.chiral`; the live path imports `lower` for `compile-fn` only. So the four exclusions those functions name (dependent type, effectful, quantified binder, type does not lower) are never produced by a real compile. The actual drop points are `compile-fn`'s `le-skip` (`compile-back.chiral:238-239`), `filter-erasable` (`:190`), `prune-fix`'s cascade (`:210`), and `peel-globals`' silent `(none)` (`compile-front.chiral:203-210`). Of those four, only the first three record anything, and `compile-all.chiral:34-38` discards even that on the `elf-ok` arm. Attribution is not measurable today.
- evidence: `lib/lowering/upper/lower.chiral:83-93`, `lib/lowering/compile-back.chiral:15`, `:190`, `:210`, `:238-239`, `lib/lowering/compile-front.chiral:203-210`, `lib/lowering/compile-all.chiral:34-38`
- checked:  2026-09-01
- owner:    E184
- from:     EN-01

### PRB-34 `optimize.chiral:250` is not the only `ck-fn` call site

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/upper/optimize.chiral
- claim:    `records/lane-a-record.md:149` says `lowering/upper/optimize` "holds the only `ck-fn` call in the tree, at `:250`".
- measured: REFUTED as stated. A second call sits inside `check.chiral` itself, in `ck-fns`, which `ck-prog` folds over the program. So `check.chiral` is the defining module and it calls its own `ck-fn`. The corrected claim is that `optimize.chiral:250` is the only call site outside `check.chiral`. The downstream conclusion survives unchanged: nothing on the compile path calls `ck-fn`.
- evidence: `lib/lowering/upper/optimize.chiral:250`, `lib/lowering/tal/check.chiral:240-241`, `:250-256`, `:259-263`
- checked:  2026-09-01
- owner:    none
- from:     EN-02

### PRB-35 the `Judg` and `Reason` line ranges are two lines off

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/typing/diag.chiral
- claim:    `Judg` is declared at `diag.chiral:97-110` and `Reason` at `:120-137`, with 38 constructors and 9 reasons. Repeated in three places.
- measured: the line ranges are REFUTED. `(data Judg ()` opens at `:99` and closes at `:112`; `(data Reason ()` opens at `:122` and closes at `:140`. Line 97 is prose in the preceding comment and line 120 is blank. The counts are CONFIRMED: 38 `Judg` constructors and 9 `Reason` shapes. This is BA-13's class, a citation that a later insertion moved, and it has been copied forward into three documents.
- evidence: `lib/typing/diag.chiral:99-112`, `:122-140`, `docs/definitions/bug-classes.md:109`, `records/lane-a-record.md:176`
- checked:  2026-09-01
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
- measured: CONFIRMED in shape, with counts that moved with the tree. Today's compiler blob emits 1,481 TFns: 727 accept and 754 reject (50.9%), in the same four classes at 389 `ret`, 185 `con`, 105 `case on non-data register`, 75 `argument arity`. The delta traces to E182, which landed at `65bec90` and `d26d7a1` on 2026-09-02 over `lib/typing/diag.chiral` and `lib/typing/kernel.chiral`, both inside the compiler's closure. Method: a scratch probe living outside `lib/` and `prog/`, importing `lowering/compile-all`, re-running `lower-defs`' per-def loop over the `NDef` list `compile-front` produces, and folding a copy of `check.chiral` over every emitted TFn under the `CEnv` `ck-prog` rebuilds. The copy exists because `check.chiral` cannot be imported beside the compiler: E154's fifth instance, eleven colliding top-level names. Each name in the copy carries a prefix; every accept and reject decision is the original's, and only the verdict strings differ, plus `ck-args` returning a reason string where the original returns a `Bool`. The probe was reverted. The same source reaches a byte fixpoint the same day: `bin/chirality-bin` over the blob yields a 1,188,216-byte binary that reproduces itself byte for byte.
- evidence: `lib/lowering/tal/check.chiral:260-263`, `lib/lowering/compile-back.chiral:231-240`, `lib/lowering/compile-all.chiral:18-33`, commits `65bec90`, `d26d7a1`, `docs/definitions/working-discipline.md:30-38`
- checked:  2026-09-03
- owner:    none
- from:     EN-08

### PRB-39 the `ret` class is the checker: an erased type-argument list, 389 of 389

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/upper/lower.chiral
- claim:    requirement 3 counts the `ret` class and leaves the side that is wrong unnamed.
- measured: THE CHECKER, in all 389, and the shape is uniform. Every one is `tt-data` against `tt-data` under the same data name, with the register's type carrying zero type arguments and the declared return carrying one (375) or two (14). Zero are an unbound register, zero are a data-name mismatch, zero are a ground-type mismatch. The register's type comes from `expr-con`, which annotates every constructed value `(tt-data dn nil)`; the declared return comes from `ntalty->talty`, which carries the arguments through from `compile-front`'s `t-tcon` peel. `tal-ty=?`'s `tt-data` arm demands `tys=?`, and `tys=?` refuses an empty list against a non-empty one. The arguments carry no checking power anywhere else in the checker: `ck-con` and `ck-term`'s case arm both resolve a data type by its name alone. Relaxing `tal-ty=?` so that an empty argument list on either side matches, the wildcard role `tt-word` already plays for a whole type, turns all 389 into accepts. Minimal rejecting TFn: a def declared to return `(tt-data "Lst" (tt-i64))` whose whole body is `(i-con 0 "Lst" "lnil" nil (tt-data "Lst" nil))` then `(t-ret 0)`; respelling the declared return as `(tt-data "Lst" nil)` makes the identical body accept. Its source twin compiles, emits, links and runs correctly. ⚑ The lowering carries a contributing defect that would close none of the class on its own: `expr-con` binds an expected type `exty` and reads it at no line.
- evidence: `lib/lowering/upper/lower.chiral:288-296`, `lib/lowering/compile-back.chiral:29`, `lib/lowering/compile-front.chiral:68`, `lib/lowering/tal/check.chiral:67-80`, `:207-209`, `:140-142`, `:213`
- checked:  2026-09-03
- owner:    none
- from:     EN-09

### PRB-40 the `con` class is that same erased argument list, 184 of 185

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/tal/check.chiral
- claim:    requirement 3 counts the `con` class and leaves the side that is wrong unnamed.
- measured: THE CHECKER for 184 of 185, by the mechanism EN-09 names, arriving through `ck-con`'s field check instead of through the terminator. `expr-con` types each field argument by walking `expr`, so a nested constructed value comes back `(tt-data dn nil)` while the declaring constructor's field type carries its arguments, peeled by `field-tys->n` and widened by `ndctors->dctors`. All 184 carry zero arguments against one (182) or two (2). The 185th is a ground-type conflation inside `$apply7`, a register typed `(tt-data "List" ...)` in a field position declared `tt-str`, and it belongs with the residue in EN-13. Minimal rejecting TFn: a two-level con whose outer constructor declares its second field `(tt-data "Lst" (tt-word))` while the inner con's register is `(tt-data "Lst" nil)`; annotating that inner register `(tt-data "Lst" (tt-word))` makes it accept. Its source twin compiles, emits, links and runs correctly.
- evidence: `lib/lowering/tal/check.chiral:134-146`, `:99-107`, `lib/lowering/upper/lower.chiral:288-296`, `lib/lowering/compile-front.chiral:216-223`, `lib/lowering/compile-back.chiral:66-69`
- checked:  2026-09-03
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
- measured: RE-CHECKED 2026-09-05 against a fixpoint binary (C1 == C2 == tracked, 1,241,464 bytes), with `tal-check.sh` (20 ok, 1 FAIL on G18), `apply-word.sh` (11 ok), `apply-spine.sh` (11 ok), `defunc-blame.sh` (11 ok), `capture-fields.sh` (9 ok) and `arity.sh` (17 passed) all run. **The two reject CLASSES are live**: tal-check G8 `EN-12's undefined register -- still REFUSED` and G10 `EN-13's ground against data -- still REFUSED`. **The CENSUS is not reproducible.** No gate in `tools/test/` re-derives 1,475 of 1,481, and the relaxation probe that produced it is not in the tree, so the counts stand as a dated 2026-09-03 reading and the classes stand as of today. This row is exactly what PRB-69 measures. With both checker relaxations applied, the one EN-09 names and the one EN-11 names, 1,475 of 1,481 TFns accept and six reject. Two are the undefined erased-binder register of EN-12, in `emit-code` and `emit-args-res`. Four are the closure-conversion dispatchers `$apply4`, `$apply5`, `$apply6` and `$apply7`, where a register's tal type disagrees with the expected type across the ground-versus-data boundary instead of inside a type-argument list: two `tt-i64` against `(tt-data "List" ...)`, one data-name mismatch, one `(tt-data "List" ...)` against `tt-str`. `closconv.chiral:362` already records that two families of different concrete type must stay unmerged, which is the shape these four have. Those six are lowering defects the checker is right about, and they are 0.4% of 1,481. So the 50.6% disagreement is 99.2% one checker relation and one missing checker arm. ⚑ Two questions stay open and this slice answers neither. The first is the author's: "Is the argument-list disagreement repaired by relaxing the checker so that an erased argument list is a wildcard, or by making the lowering carry the arguments into the IR?" `LCore` is type-erased, so the second option may be unreachable at the constructor sites. The second question is the refuse-or-carry ruling already standing in [[records/author-calls]], which this slice leaves untouched.
- evidence: `lib/lowering/upper/closconv.chiral:362`, `:1098`, `lib/lowering/upper/lower.chiral:116-123`, `:385-397`, `lib/lowering/mach/emit-core.chiral:178`, `:200`
- checked:  2026-09-03
- owner:    none
- from:     EN-13

### PRB-44 five of `check.chiral`'s eleven collisions are duplication, and the honest fix is a shared module

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/tal/check.chiral
- claim:    none yet. The rename that made `lowering/tal/check` importable beside the compiler treated all eleven collisions alike, and for five of them that is a hand-patch over a different defect.
- measured: `sig-assoc`, `find-data`, `ce-prims`, `ce-fns` and `ce-datas` were **byte-identical** in `lib/lowering/tal/check.chiral` and `lib/lowering/upper/lower.chiral` up to whitespace: the same association-list lookup, the same `DData` lookup, and three `CEnv` field accessors over the same `(cenv p f d l)` shape, whose type `lowering/tal/ssa.chiral` already declares for both. That is duplication rather than a conflict of meaning, so the `tck-` prefix leaves the tree with two copies of one function instead of one copy in one place. The other six are genuine homonyms and the prefix is right for them: `CkR`/`ck-ok`/`ck-err` name a different sum from `typing/kernel.chiral`'s, `CovR`/`cov-ok` a different sum from `surface/data.chiral`'s, and `find-ctor` walks `(List DCtor)` where the kernel's walks `(List Ctor)`. The extraction was deliberately **not** taken in the rename slice: `lower.chiral` is inside the compiler's blob, so lifting five defs out of it changes compiler source and owes `build-new → test → promote` with a fixpoint, which is a larger slice than making one module importable. E154's row already records the flat emitted-label namespace as the live, recurring, hand-patched defect this is the fifth instance of; per-module label mangling is the structural fix and remains unbuilt.
- evidence: `lib/lowering/tal/check.chiral:20-35`, `:101-110`, `:51-53`, `lib/lowering/upper/lower.chiral:163-168`, `:192-194`, `lib/lowering/tal/ssa.chiral`, `docs/elements/catalog.md:480`
- checked:  2026-09-03
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
- checked:  2026-09-04
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
- checked:  2026-09-05
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
- measured: `(let (m (case (<i a b) (true a) (false b))) m)` fails with "cannot prove refinement". The trigger needs all four at once: a `case`, a **computed** comparison as scrutinee rather than a `Bool` that arrived as a variable, arms returning **bound variables** rather than literals, and a `let`-bound result rather than a direct return. Any one of the four removed and it passes. `cond` fails identically, as expected, since it desugars to `case`. The first hypothesis in the investigation was REFUTED by its own diagnosis section; the mechanism is recorded there. Three coherent fixes exist and they differ in what they preserve, so this needs a blueprint rather than a patch.
- evidence: `lib/typing/kernel.chiral:1439-1440`, `lib/typing/diag.chiral:20-25`, `:314-315`, `:346`, `lib/typing/pretty.chiral:15-20`, `prog/paren-audit.prog`, `.planning/FINDING-let-bound-case-refinement-2026-08-31.md`
- checked:  2026-09-01
- owner:    none
- from:     FD-02

### PRB-49 the closure refusal is about a bare lambda, not about capture

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/upper/closconv.chiral
- claim:    `.planning/USER-LAYER-GAP.md` §10 records "k>=1, real capture -> REFUSED" and reads it as a language limitation: captured closures in a record do not lower.
- measured: RE-CHECKED 2026-09-05 against a fixpoint binary (C1 == C2 == tracked, 1,241,464 bytes), with `tal-check.sh` (20 ok, 1 FAIL on G18), `apply-word.sh` (11 ok), `apply-spine.sh` (11 ok), `defunc-blame.sh` (11 ok), `capture-fields.sh` (9 ok) and `arity.sh` (17 passed) all run. Not re-run: the fixture pair this row rests on, a bare `(lam ...)` in a data-constructor argument position against the same lambda wrapped, is described in `.planning/FINDING-captured-closures-2026-08-30.md` and is not a gate. PRB-69's case again. REFUTED in both directions by a single fixture pair. A fixture with **zero** captures and a bare `(lam ...)` written directly in a data-constructor argument position is refused; the same lambda with the same captures wrapped in `(the (-> ...) ...)` lowers, runs and exits 0, as does a call that returns a closure. The discriminator is purely syntactic: a bare `(lam ...)` in constructor position is never registered as a closure-conversion site. A second, independent limitation is real and separate: the closure-returning projector shape works at one instance and fails at two, exactly as `specialize-singleton.chiral` documents. **Nothing has been applied.** The run's write surface was the finding plus fixtures under a `scaffold/tests/samples/_wip/` path the migration has since evicted, so the fixtures are gone and §10 still carries the wrong table.
- evidence: `lib/lowering/upper/closconv.chiral`, `lib/lowering/upper/specialize-singleton.chiral`, `.planning/FINDING-captured-closures-2026-08-30.md` (§0, §1.3, §6), `.planning/USER-LAYER-GAP.md` §10
- checked:  2026-09-01
- owner:    none
- from:     FD-03

### PRB-50 whether to condense the five principles to "everything is a port boundary"

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    doc
- about:    PRINCIPLES.md
- claim:    the same finding proposes the boundary, not the process, as the atom, and shows each of P1-P5 reading as a case of it.
- measured: undecided, and author-tier by the finding's own statement. The test it has to pass is `CLAUDE.md`'s own: an abstraction that does not constrain is overhead, and "everything is X" forbids nothing by itself. One concrete thing it decides is already banked as FD-05, which is evidence it is not vacuous but is only one. The finding says nothing here should be edited into `PRINCIPLES.md` before the call, and names the 2026-07-20 seven-to-five pass as the precedent for how. Separately: the author's note that `PRINCIPLES.md` has more problems than audit 1 surfaced is taken and there is no queue entry for that second kind of pass.
- evidence: `PRINCIPLES.md`, `.planning/FINDING-ports-role-2026-08-31.md` (§"The principle question", §"Not the whole audit"), `.planning/DOC-AUDIT-QUEUE.md`
- checked:  2026-09-01
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
- measured: the statement is a `Str`. `(data SpecRule () (spec-rule (form JForm) (name Str) (statement Str)))`, so the artifact the whole scheme's non-vacuity rests on is unstructured prose, and nothing can check it says anything. The decomposition beside it is unreached: the six `JForm` constructors (`j-check`, `j-infer`, `j-conv`, `j-usage`, `j-data`, `j-membrane`) have **one use each**, their own declaration line; `JForm` 2, `SpecRule` 2, `Spec` 3. No file imports `typing/kernel-core`; the only mention of it anywhere in `lib`, `prog`, `tools` or `bin` is a comment at `reflect-floor.chiral:16` calling it work the port "must carry". It compiles clean standalone (`chirality check` exits 0) and no suite phase runs it, so `recheck` has never been executed against a populated `Spec`. Two live checking concerns have no `JForm` at all: totality (`typing/totality.chiral`, `typing/totality-check.chiral`) is presumably folded into `j-data` and nothing says so, and refinement (`typing/refine.chiral`, `t-refine` at 29 uses across 7 modules) has no form. `docs/arcs/independent-judgment-arc.md` already records the module as "written, unreached" and row `J2` owns wiring it; what is new here is that the statement is prose and that the form set is both inert and incomplete.
- evidence: `lib/typing/kernel-core.chiral:27-29`, `:53-60`, `lib/typing/reflect-floor.chiral:16`, `docs/definitions/certificate-discipline.md`, `docs/decisions/decision-split-checker.md`, `docs/arcs/independent-judgment-arc.md`
- checked:  2026-09-02
- owner:    none
- from:     FD-09

### PRB-53 the effect row is supplied to lowering rather than derived by it

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/upper/eff-lower.chiral
- claim:    [[decisions/decision-effect-facets]] states the row is "inferred by elaboration from the transitive closure of extern crossings in the call graph", a call-graph fact rather than a consequence of port-holding. `Sheet.crossings` is marked derived, naming WHICH crossings rather than whether, and E161 derives crossings with no surface production at all. So the third leg of the triple, what happens, is documented as never authored.
- measured: on the lowering path it is authored, by being handed in. `lib/lowering/upper/eff-lower.chiral:9-15` says its two loader-derived inputs, `crossing_sigs` (the E51-bound port names) and `def_rows` (E39's inferred per-def effect rows), remain unported chirality-side, " (E39 row inference lives in the deferred E2-loader seam)", so the slice "takes them as GIVEN inputs" and "deriving them is deferred residue with an E2-loader / E51 home". The preserve-check itself is ported and real: re-derive the reached crossings from a lowered tal footprint and demand `reached <= declared`. What is missing is the `declared` side's provenance. The fallback when a def cannot lower is a prune rather than a refusal: `lib/lowering/compile-back.chiral:181-210` drops the function and records `sk-extern op` for a direct extern or `sk-callee cn` for the transitive case, iterated to a fixpoint (`lib/lowering/skip-diag.chiral`, E97). Two further gaps on the same path are DELIBERATE and fall outside this row: erased q=0 content never lowers (`lib/lowering/upper/lower.chiral:65,70`, `drop-erased-args` in `closconv.chiral:1177`), and the crossing floor is hand-authored tal that never came from upper (`lib/lowering/tal/sys.chiral`, 1343 L of `TIFn` values, whose header states the membrane argument: "lowered pure code has no surface path to ti-sys/ti-bptr").
- evidence: `lib/lowering/upper/eff-lower.chiral:1-17`, `lib/lowering/compile-back.chiral:181-210`, `lib/lowering/skip-diag.chiral:11`, `lib/lowering/tal/sys.chiral:1-12`, `docs/decisions/decision-effect-facets.md`, `lib/module/loader.chiral:280`
- checked:  2026-09-02
- owner:    none
- from:     FD-10

### PRB-54 Lane A's reserved gate phases were spent by other arcs

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    docs/decisions/decision-lane-split.md
- claim:    `docs/decisions/decision-lane-split.md:30` reserves gate phases **18, 19, 20** for Lane A and **21, 22, 23** for Lane B, and `:33-35` says phases 1-7 and 13-17 are taken while 8-12 are names owed to unported old-tree phases that must never be reused.
- measured: all three of Lane A's are gone as of 2026-09-02 and only one went to Lane A. Phase 18 is `pretty.sh`, E181, which is Lane A's own. **Phase 19 is `matcher.sh`, E173, the text-tools arc** (`tools/test/run-tests.sh:301`). **Phase 20 is `transport.sh`, the transport arc** (`:324`, commit `d7d7cfe`). So E182 needed a gate number and its reservation held none, while Lane B's 21-23 sit unused. The E182 SPEC was written against Phase 20 and was overtaken between its audit and its implement run. E182's gate takes **Phase 24**, outside both reservations and clear of the forbidden 8-12. Same class as the two independently minted `E173`s: a reservation that nothing enforces, discovered after the collision.
- evidence: `docs/decisions/decision-lane-split.md:30`, `:33-35`, `tools/test/run-tests.sh:301`, `:324`, `docs/elements/specs/E182-arity-evidence-SPEC.md` §5
- checked:  2026-09-02
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
- measured: `grep -rn 'mk-profile' lib/ prog/ --include=*.chiral` finds one constructor site (`lib/surface/parse.chiral:984`) and three destructurings. `lib/typing/totality-check.chiral:134` reads the `to` field, `lib/lowering/compile-front.chiral:272` reads the `po` field, `lib/typing/kernel.chiral:260` reads `pn` for the redeclare lookup. The `me` field is read by nothing after `handle-profile-body` validates it, and so is `tg`. The four `(memory ...)` rows therefore assert a parse message over a value the compiler discards, and no mutant of the discipline's meaning can exist while nothing consumes it. Recorded as a zero in the shape `docs/definitions/testing-floors.md` uses for E170 lane E: a field with no reader is a gate row quantified over an empty set of consumers. ⚑ RE-MEASURED 2026-09-05 at `b12c29e`, unchanged. `grep -rn 'mk-profile' lib/ prog/ --include=*.chiral` finds one constructor site (`lib/surface/parse.chiral:984`), the declaration (`lib/typing/kernel.chiral:60`) and three destructurings: `lib/typing/kernel.chiral:260` reads `pn`, `lib/lowering/compile-front.chiral:294` reads `po`, `lib/typing/totality-check.chiral:134` reads `to`. `me` is read by nothing and neither is `tg`. LEFT OPEN, and it is not a gate row's defect. `ba62549` closed GA-03 by giving `(total)` rows that read what the flag DOES, and the same repair is unavailable here for a reason worth stating: `to` had a consumer to point a row at, and `me` has none. A falsifier for the discipline's MEANING cannot exist until something in `lib/` consumes the field, which is a compiler change and an author call about what a memory discipline is for. The four `(memory ...)` rows are reddened by `known-clause-refuses-all` since `ba62549`, so they are no longer rows nothing can move. What they still are is rows quantified over an empty set of consumers, and that is the zero this row records.
- evidence: `lib/surface/parse.chiral:938-953`, `:984`; `lib/typing/kernel.chiral:60`, `:260`; `lib/lowering/compile-front.chiral:294`; `lib/typing/totality-check.chiral:134`
- checked:  2026-09-05
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
- measured: the chirality provider is live as a library and dead as a tool. `grep -rIn 'resolve\.prog'` over the tree returns seven hits and every one is prose: two comments in `lib/module/resolve.chiral` (`:22`, `:406`), the E87 catalog row, `docs/examples/E172-NAME-MAP.md:141`, `docs/decisions/decision-lane-split.md:256`, `docs/arcs/binary-split-arc.md:41` and two size rows in `records/baseline-alignment.md`. No shell script, no gate phase and no `.prog` compiles or runs it. Against that, `grep -rIln 'chirality-resolve' tools bin` names **fifteen shell files**: `bin/chirality` and fourteen of the eighteen gate scripts. The four that do not are `check-cli.sh`, `linear-mint.sh`, `map-integrity.sh` and `profile-target.sh`. None of the resolver's nine classic-tool sites is a judgment, so its adoption on the build path waits on nothing in `arcs/independent-judgment-arc`.
- evidence: `prog/resolve.prog:1-20`; `docs/elements/catalog.md:117`; `bin/chirality-resolve.sh:115-117`, `:138-140`, `:273-276`, `:304`
- checked:  2026-09-04
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
- measured: `wc -l lib/text/matcher.chiral` returns **602**. The file grew after those rows were written: `git log --follow` puts the last change at `9f46c6c`, "matcher: the two constructions scan-go built and threw away", and the figure was taken at the E173 slice-1 landing on 2026-09-01. The consumer count is unchanged and correct: `grep -rIn 'import "text/matcher"' lib prog` returns exactly one shipping consumer, `prog/prose-lint.prog:43`, plus the gate fixture `tools/test/samples/e173_matcher.prog:37`. Its own imports are `prelude/prelude`, `prelude/list`, `prelude/ord` and `prelude/string`, which is what makes its closure small enough to be a judge everywhere except over itself. ⚑ **This row named three documents and there are seven.** `grep -rln` for the figure over `docs/` returns `docs/definitions/status-ledger.md:165`, `docs/elements/catalog.md:499`, `docs/elements/ledger.md:321`, `docs/banks/text.md:50`, `docs/examples/INDEX.md:164`, `docs/goals/local-ai.md:103` and `docs/arcs/text-tools-arc.md:87`, where the last wraps the number onto the following line. **Three repointed at `8b65108`**: `status-ledger`, `catalog`, `ledger`. The other four stay owed; `docs/banks/text.md` was held by a concurrent bank pass at the time and was not opened.
- evidence: `docs/arcs/text-tools-arc.md:87`; `docs/banks/text.md:50`; `docs/examples/INDEX.md:164`; `docs/goals/local-ai.md:103`; `lib/text/matcher.chiral:10-13`; `prog/prose-lint.prog:43`
- checked:  2026-09-04
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

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    docs/decisions/decision-lane-split.md
- claim:    `docs/decisions/decision-lane-split.md:30` reserves gate phases **21, 22, 23** for Lane B, which owns E146, E163 and E183. `tools/test/run-tests.sh:332` repeats it: "21-23 are Lane B's".
- measured: two scripts that are not Lane B elements sit in that block. `tools/test/tal-check.sh:3` reads "The Phase 22 gate" and `:5-9` takes 22 explicitly, leaving 21 to `crypto.sh` "which was written first and whose registration is already owed". `docs/definitions/testing-floors.md:69` records tal-check.sh as Phase 22 and describes "the `crypto.sh` precedent holding phase 21". Reading `crypto.sh` in full, it claims **no phase number**: `:6-8` says only that registration is owed and that "21-23 are free at this writing". So three documents place phase 21 with a script that has never asked for it, and phase 22 with EN-09/EN-11 work rather than with Lane B's E163 or E183. Recorded as an open allocation question. No number was assigned by this pass. Re-read at `67d3d54`: `crypto.sh:8` still claims no number and still records 21 through 23 as free. **`docs/definitions/testing-floors.md:69` repointed at `096ba33`**: it no longer asserts the precedent, and it names all four positions with the author call beside them. **No number was assigned.** The allocation stays open, and `records/author-calls.md:30` holds it.
- evidence: `docs/decisions/decision-lane-split.md:30`; `tools/test/run-tests.sh:332`; `tools/test/tal-check.sh:3`, `:5-9`; `tools/test/crypto.sh:6-8`; `docs/definitions/testing-floors.md:69`; `records/author-calls.md:30`
- checked:  2026-09-04
- owner:    none
- from:     TC-08

### PRB-65 map-integrity.sh's stated reason for exclusion has been false since 2026-09-01

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    tools/test/map-integrity.sh
- claim:    `tools/test/map-integrity.sh:7-8` reads "Not a suite phase: the map lives under `.planning/`, which is not tracked, so a fresh checkout has no map to check."
- measured: ⚑ citations repointed 2026-09-05 after ledger-lint.py grew ~400 lines; the measurement itself was NOT re-taken, so this row stays unverified. `.planning/` has been tracked since 2026-09-01 by `docs/decisions/decision-ai-tier.md`. `git ls-files .planning | wc -l` returns **147**, and `git ls-files .planning/MIGRATION-MAP.tsv` returns the map itself, so a fresh checkout does have a map to check. This is the same false claim `ledger-lint` check Z drives to zero in the doc tier; Z scans `docs/` and `.claude/skills/` and reports 5 live instances, and it does not scan `tools/`, so this one is invisible to the lint. The exclusion may still be right for another reason. The reason written down is not.
- evidence: `tools/test/map-integrity.sh:7-8`; `docs/decisions/decision-ai-tier.md`; `tools/ledger-lint/ledger-lint.py:1597`
- checked:  2026-09-04
- owner:    none
- from:     TC-09

### PRB-66 288 gate-tier calls are blocked on a criterion nobody has written

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/evidence/ddc.chiral
- claim:    `docs/goals/enforcement.md:41-45` and `docs/arcs/enforcement-arc.md:84-88` read that some of the tooling surface is correct and stays, because a comparator holding constants cannot be fooled by a mutated compiler, and that over-claiming that bucket replaces a safety property with a dependency.
- measured: the caution is right and the bucket is much smaller than "the gate tier". **15 of 506** call sites are irreducible, all in `tools/test/matcher.sh`, whose subject is the module a matcher-based judge would itself be built from. The other **288** are judgments for which this tree already owns an independence axis: formulation (`lib/lowering/tal/eval.chiral`, 187 lines, zero importers), profile and frozen port set ([[banks/profile]] §1), runtime ([[banks/runtime]] §1), import-closure disjointness (already computed in bash at `tools/test/pretty.sh:552-573` and gated as G13 with M17 as its mutant), and the building binary (`tools/test/mutant.sh:110-116` builds every mutant with the promoted `$MUT_B1`). `lib/evidence/ddc.chiral:207-213` and `docs/definitions/open-edges.md:672` both record that `leg2-disjoint?` is the wrong criterion for this threat, that `Prov` has no formulation axis and that `ddc-fold` compares bytes where formulations agree on verdicts. **The independence is already in the tree. What is missing is the criterion.** `docs/arcs/independent-judgment-arc.md:92` rows J1, the distinctness criterion written down, as `not started`; the `ddc` repoint is open edge 21 with no element minted; and `:107` records that the arc has no reserved element block, so nothing there can be minted at all. Nothing in the 288 can honestly convert until J1 lands, and every one of them stays owed work meanwhile.
- evidence: `lib/evidence/ddc.chiral:207-213`; `docs/definitions/open-edges.md:672`, `:687-699`, `:701`; `docs/arcs/independent-judgment-arc.md:92`, `:100`, `:107`; `tools/test/pretty.sh:552-573`; `tools/test/mutant.sh:110-116`
- checked:  2026-09-04
- owner:    none
- from:     TC-12

### PRB-67 the reference tal interpreter is the tree's strongest formulation asset and no arc rows it

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/tal/eval.chiral
- claim:    `docs/arcs/independent-judgment-arc.md:38-42` lists what is in the tree already for the independence axes: `lib/evidence/ddc.chiral` at 213 lines with 1 importer, `lib/typing/kernel-core.chiral` at 60 lines with 0, and `lib/typing/reflect-floor.chiral` at 54 lines with 0.
- measured: the table omits the strongest member. `lib/lowering/tal/eval.chiral` is **187 lines with zero importers**, and `:1-2` describes it as the reference tal interpreter, the Category-A oracle that defines what checked programs mean, ported from `TalMachine.call`. Its register file and byte store are explicit and threaded so evaluation is replayable by construction, and a strictly decreasing fuel makes the meaning function total, with "out of fuel" a constructor rather than a hang. Its imports are `prelude/prelude` and `lowering/tal/ssa` only, so its closure excludes `typing/`, `surface/`, `lowering/compile-*` and `lowering/tal/check` entirely. That makes it disjoint from the compiler on both the formulation axis and the closure axis. By contrast `kernel-core.chiral` imports `typing/kernel` and `typing/diag` (`:23-24`) and is **not** closure-disjoint from the modules it would judge. `lib/typing/reflect-floor.chiral` was confirmed at 54 lines with zero importers. Three written modules, 301 lines, and nothing reaches any of them.
- evidence: `lib/lowering/tal/eval.chiral:1-20`; `lib/typing/kernel-core.chiral:23-24`; `docs/arcs/independent-judgment-arc.md:38-42`, `:93`
- checked:  2026-09-04
- owner:    none
- from:     TC-13

### PRB-68 the surface figures started drifting the day they were taken

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    doc
- about:    records/tooling-classification.md
- claim:    the table above and both goal-tier documents read a gate tier of **6,915** lines and **12,450** lines outside the language, measured 2026-09-04 against `dda00b9`. This file's scope paragraph read **122** gate-tier `grep` invocations.
- measured: three separate drifts, none of them a defect in the original count. **One.** Four commits after `acc70d6` (`ebec76a`, `d3ab4d3`, `3a71658`, `f7caf96`, all falsifier work on `tools/test/*.sh`) took the gate tier to **7,136** lines, so the surface outside the language reads **12,671** at `67d3d54` and the 12,450 is already behind. Neither figure was repointed: `tools/test/` was held by a concurrent gate pass and the target moves under it. **Two.** The same four commits added no classic-tool call site, so **506 stands as 504** under an independently written scanner following this file's stated rule, with `tools/test/doc.sh` at 47 against 48 and `tools/prose-lint/prose-lint.sh` at 23 against 24, one `sort` and one `wc` this pass could not place. Every other file and 17 of the 19 tools agree exactly, and the gate-tier four-tool count reproduces at **240** site for site. **Three.** The 122 above disagreed with this file's own per-tool table and is corrected to 119 in the same commit as this row.
- evidence: `records/tooling-classification.md:36-46`; `docs/goals/enforcement.md:32-33`; `docs/arcs/enforcement-arc.md:74`, `:87-90`, `:130`; `git log acc70d6..67d3d54 -- tools/test/`
- checked:  2026-09-04
- owner:    none
- from:     TC-14

### PRB-69 most record rows name no command that re-runs their measurement

- state:    OPEN
- author:   unreviewed
- note:     none
- level:    doc
- about:    records/README.md
- claim:    records/README.md, Evidence is mandatory: "`evidence:` names files and line spans. A row nobody can re-run is worthless."
- measured: measured 2026-09-05 over every live row in records/ and records/lenses/: **123 of 153 carry file:line evidence and name no command**. 30 name a re-runnable one (a tools/test gate, a python3 tool, git ls-files, find). A file:line span shows WHERE a thing was seen and does not reproduce the NUMBER: PRB-43 claims 1,475 of 1,481 TFns accept under two checker relaxations, and no gate in tools/test/ reproduces that census, so check AI can say the row is unverified and nobody can say what it reads today. This is why 60 AI findings cannot be closed by reading.
- evidence: records/README.md, tools/test/tal-check.sh (the nearest gate, which measures 20 ok 1 FAIL and not the census), records/lenses/problems.md
- checked:  2026-09-05
- owner:    none
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
