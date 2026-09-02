---
node: records-baseline-alignment
layer: navigation
related: [records/README, status-ledger, open-edges, testing-floors, index]
status: current
updated: 2026-09-01
---

# Baseline alignment arc

Author's framing: get current work to actually align with the goals we claim,
since apparently we do not. Every row is a claim this repo makes about itself
beside what was measured.

Row format, states and the rules for adding, changing and retiring a row are in
[[records/README]]. Prefix is `BA`.

This arc has NO reserved element number block. `docs/decisions/decision-lane-split.md` reserves E184-E189 and
E190-E195 for the two diagnostics lanes. Rows needing an element carry
`UNASSIGNED` until the author assigns a block.

Everything below was measured on 2026-09-01. Line citations are current as of
`b7d27f3`. Re-run a row's evidence before relying on it: a banner or an
insertion above a cited line moves it, which is BA-13.

## Gates that cannot fail

The repo's own cardinal error class, from CLAUDE.md: a gate aimed at a floor the
tree lacks, or at a guess, passes by looking at nothing.

### BA-01 map-integrity passes a row that has no destination

- state:    FIXED
- claim:    every `new_path` in the migration map exists; a row with no destination is skipped by the `[ -z "$new" ] && continue` guard, and a row pointing at a moved path is reported STALE.
- measured: the script moved, at `d4a0297`. Tab is IFS whitespace, so `IFS=$'\t' read` folded runs of tabs and a 4-column row with a blank `new_path` shifted `ext` into `$new`. Reproduced on an isolated fixture root before the change: the row `lib/gone.chiral<TAB><TAB>prog<TAB>retired` bound `new=prog`, `[ -e $ROOT/prog ]` was true, and the run printed `2 rows, 0 stale`, exit 0. The loop now reads through `tr '\t' '\001'`, and \001 is a non-whitespace delimiter, so an empty field stays empty. The same fixture prints `NODEST lib/gone.chiral`, `2 rows, 1 stale`, exit 1. The `-z` branch became a report instead of a skip: a row with no destination records nothing about where the file went, and a retired original says so with the brace form. The real map is unchanged at 869 rows, and the fixed script found one live STALE row, `scaffold/lib/pretty.metis -> lib/typing/pretty.chiral`, repointed at `lib/surface/pretty.chiral` against E181's rename in `0c53875`. `map-integrity` now exits 0.
- evidence: `tools/test/map-integrity.sh:19`, `:21`, `:26`, `:28`
- checked:  2026-09-01
- element:  none

### BA-02 ledger-lint checks G and R cannot see a `.chiral` citation

- state:    FIXED
- claim:    check G is "line-numbered code citations in docs still fit the file" and check R is "a line citation lands on the symbol it is cited FOR". R's own docstring cites `ddc.chiral:127` as the defect it was built for.
- measured: the checks moved, at `0f72a33`. Both regexes were `([A-Za-z0-9_/.-]+\.(?:py|chirality))` and nothing in the tree ends in `.chirality`, so all 456 line-numbered `.chiral` spans in docs failed both alternatives and the pair inspected 12 citations. Three changes: the alternation is `(?:py|chiral)`; a bare basename resolves to the one file under `lib/` or `prog/` carrying it, leaving `mach.chiral` (three homes) unresolvable; and the ctx a bare `:NN` binds to is cleared by an unresolvable path span and by a blank line. The ctx change is the second half of the same defect. Before it, `verification.md:193`'s `:129` was reported against `alloc-fixed.chiral` and `E174-r-row-width.md:158`'s `:360` against `doc.chiral`, neither of which those lines are about. Coverage is now 407 of 862 line-numbered spans, up from 12. G reports 17 and R 17, all under `docs/examples/`, which is BA-22. Proved on an isolated fixture root: a `.chiral` citation past end of file and one landing off its symbol both returned `0 issues` before and both fire after.
- evidence: `tools/ledger-lint/ledger-lint.py:323`, `:330`, `:345`, `:380`, `:452`
- checked:  2026-09-01
- element:  none

### BA-03 ledger-lint H and M are VACUOUS by decision

- state:    ACCEPTED
- claim:    `ledger-lint` runs 19 checks.
- measured: H and M print `VACUOUS` and say so in the run's own output. H verified the idioms cheatsheet against `refine.py`, cut with the Python oracle. M guarded a scaffold-to-TUI symlink web dissolved by the migration. Both subjects are genuinely gone, which is why this is ACCEPTED and not OPEN. H is repointable at `lib/typing/refine.chiral:11` and `lib/module/loader.chiral:20`, both live; that repoint was measured against live files. M has no live subject.
- evidence: `tools/ledger-lint/ledger-lint.py:450`, `:662`
- checked:  2026-09-01
- element:  none

### BA-04 the `check` CLI gate never exercises an emit-stage refusal

- state:    OPEN
- claim:    the header of the gate says the cases "pin that it ACCEPTS well-typed source and REFUSES ill-typed source", and that a checker which only ever says OK is not a checker.
- measured: 7 assertions. 3 positive, 4 negative. All four negatives are front-end refusals: two linear binder usage mismatches, one type mismatch, one unknown name. Zero exercise a lowering or emit refusal, which is where the E76 chokepoint, the H8 profile gate, duplicate label and the missing heapptr cell live. See BA-05 for why that matters.
- evidence: `tools/test/check-cli.sh:41-60`
- checked:  2026-09-01
- element:  UNASSIGNED

## The `check` subcommand

### BA-05 three failure classes collapse into one exit code

- state:    OPEN
- claim:    `bin/chirality check FILE` is documented as "type-check (compile, discard the ELF)".
- measured: `compile-all` maps `fr-err` (parse, elaborate, typecheck), `br-err` (lowering) and `elf-err` (emit) all to `ca-err`. `prog/compiler.prog` maps every `ca-err` to exit 1, and `cmd_check` reports any nonzero exit as `chirality check: FILE FAILED (exit 1)`. Reproduced with a well-typed program declaring `(profile p (ports halt) ...)` while calling `put`: the CLI printed `FAILED (exit 1)`, the same headline and the same exit code as `(def f (-> I64 I64 I64) (lam (n) n))`. The compiler's own message does survive to stderr (`E76 profile REFUSED emit: crossing put (wrap-put) is outside the declared profile port set`), so the reason survives. What is lost is the classification: nothing in the exit code or the CLI's verdict line separates the program's types from the emitter's verdict.
- evidence: `lib/lowering/compile-all.chiral:17-38`, `bin/chirality:174-178`, `bin/chirality:192`
- checked:  2026-09-01
- element:  UNASSIGNED

### BA-06 `cmd_check` runs the whole compiler, and defends it

- state:    ACCEPTED
- claim:    recorded here because BA-05 has a considered defense, quoted below.
- measured: `cmd_check` compiles the unit with the real compiler and discards the ELF. Its header states the reason: "checking is compiling and throwing the ELF away, the same front end, no second implementation to drift." That is a real argument and it is why BA-05 is a classification defect rather than an architecture defect. A second front end that only type-checks would drift from the one that compiles.
- evidence: `bin/chirality:155-159`, `bin/chirality:173`
- checked:  2026-09-01
- element:  none

### BA-07 `cmd_check` greps blob source text for the entry def

- state:    OPEN
- claim:    `bin/chirality-resolve.sh` documents this exact bug class as fixed for imports: a bare grep makes a doc comment that merely mentions an import form into a dependency, and the authoritative provider parses real s-expressions instead. Its own header comment is the proof.
- measured: `cmd_check` does `grep -q '(def compile-main' "$blob"` before appending a trivial entry. Same bug class, unfixed. LATENT rather than live: `grep -rn '(def compile-main' lib prog tools bin` returns 20 hits and every one is a real top-level definition at column 0. No file in the tree currently carries the string inside a comment or a string literal. A comment mentioning the form would suppress the appended entry and make the check fail on a file that has no entry.
- evidence: `bin/chirality:171-172`, `bin/chirality-resolve.sh:94-98`
- checked:  2026-09-01
- element:  UNASSIGNED

## Claims that do not match the tree

### BA-08 testing-floors still lists the cut external floors

- state:    OPEN
- claim:    `docs/definitions/testing-floors.md` lists a rocq floor invoked as `chirality test-rocq`, GATING on well-formedness, and a python oracle floor invoked as `chirality test-python`, ADVISORY.
- measured: external judgment is cut by author decision (CLAUDE.md, HANDOFF decision 5). `bin/chirality`'s dispatch accepts `compile`, `run`, `check`, `test`, `help` and nothing else. Neither subcommand exists. CLAUDE.md states the absence is deliberate: a subcommand dispatching to a floor this tree lacks is a gate that cannot fail.
- evidence: `docs/definitions/testing-floors.md:50-51`, `bin/chirality:210-219`
- checked:  2026-09-01
- element:  UNASSIGNED

### BA-09 the fixture count is off by 44

- state:    OPEN
- claim:    `docs/decisions/decision-scope.md`'s state table says `tools/test/samples/` holds 98 files.
- measured: `ls tools/test/samples/ | wc -l` counts 54. Four of the gap is the C-leg fixture drop at `d0c5dd5`, which removed `e166_c_assemble.prog`, `e166_ddc_legc.prog`, `e166_mach_c.prog` and `e166_mach_c_reject_lda6.prog`. The other 40 is older drift and is undiagnosed.
- evidence: `docs/decisions/decision-scope.md`:57` (the fixtures row), commit `d0c5dd5`
- checked:  2026-09-01
- element:  none

### BA-10 `.profile` is a documented kind with no instance

- state:    OPEN
- claim:    `MAP.md` lists `.profile` as one of five extensions, "a named frozen port set", and excludes it from import probing because "a profile names a module set, which the build consumes and nothing imports". `bin/chirality-resolve.sh` repeats the reason: "the BUILD consumes it".
- measured: `find . -name '*.profile'` outside `.git` returns nothing. Zero files. Grepping `bin/` and `tools/test/run-tests.sh` for `.profile` returns three hits and all three are the prose that excludes it from probing. Nothing in the build reads one. The `(profile ...)` form that is actually used is a top-level clause inside a `.chiral` file, parsed at `lib/surface/parse.chiral:717`, which is a different thing from the extension.
- evidence: `MAP.md:12`, `MAP.md:23`, `bin/chirality-resolve.sh:51`, `lib/surface/parse.chiral:717`
- checked:  2026-09-01
- element:  UNASSIGNED

### BA-11 "The two binaries" names one binary and one shell script

- state:    OPEN
- claim:    `MAP.md` has a section titled "The two binaries" naming `bin/chirality` as the CLI front door and `bin/chirality-bin` as the compiler.
- measured: `git ls-files bin/` returns three files. `bin/chirality` is a bash script, `bin/chirality-resolve.sh` is a bash library, and `bin/chirality-bin` is the one committed binary. There are 6 top-level `.prog` roots under `prog/` and 96 `.prog` files in total; the suite drives 87 roots. `bin/chirality` has no `build` subcommand: the build-new, test, promote rule lives only as prose in CLAUDE.md.
- evidence: `MAP.md:89-92`, `bin/chirality:210-219`
- checked:  2026-09-01
- element:  UNASSIGNED

### BA-12 the port floor is a naming boundary and buys zero bytes

- state:    ACCEPTED
- claim:    nine port registries under `lib/ports/`, one per concern, with `ports/ports.chiral` as the façade.
- measured: the file's own header says the split "is worth exactly 0 bytes at runtime", because the image is `native-lib` prepended to `link-lib` prepended to the object, unconditionally. Verified: `(let (image (app-tfn native-lib (app-tfn link-lib obj)))` with no reference to the declared port set. A program importing one registry and a program importing all nine emit the same size. So the port floor narrows what a module may NAME, and the H8 profile gate narrows what it may CALL, and neither narrows the emitted bytes. ACCEPTED because the header states it plainly. Recorded because two documents describe it as a floor without saying so.
- evidence: `lib/ports/ports.chiral:26-30`, `lib/lowering/compile-emit.chiral:295`
- checked:  2026-09-01
- element:  none

### BA-13 the ports header cites a line that moved

- state:    FIXED
- claim:    `lib/ports/ports.chiral`'s header attributes the unconditional append to `compile-emit.chiral:189`.
- measured: the header moved, at `de0da80`. The only `app-tfn native-lib` site is line 295; line 189 is the H7 chokepoint prose. Comment only, and verified inert under the BUILD RULE: the blob stays 772,967 B and the binary built from it is byte-identical to the committed `bin/chirality-bin`, so no promotion is owed. Suite 303 passed, 0 failed, 87 roots. ⚑ The repaired check R still cannot see this citation, for three independent reasons recorded in BA-19: it sits in a `.chiral` comment rather than a doc, it sits outside a code span, and `native-lib` is defined in `lowering/tal/bytes.chiral` rather than in the file cited. Calling it "the class check R was built to catch" was too broad.
- evidence: `lib/ports/ports.chiral:28`, `lib/lowering/compile-emit.chiral:295`
- checked:  2026-09-01
- element:  none

## Dead or unreachable code, deliberate and now recorded

### BA-14 `lib/evidence/ddc.chiral` has no callers for its DDC half

- state:    ACCEPTED
- claim:    already recorded as open edge 21. Cross-referenced here rather than restated.
- measured: `ddc-fold`, `ddc-legs`, `ddc-compare`, `ddc-verdict-code`, `ddc-leg0`, `ddc-leg1`, `ddc-legc`, `ddc-legcc`, `LegOut` and the `DdcR` sum have zero callers and zero assertions in `lib`, `prog` or `tools` after `d0c5dd5` deleted `e166_ddc_legc.prog`. The only grep hit outside the file is a prose mention. The file stays reachable because `lib/evidence/test-floor.chiral:31` imports it for `bytes=?`, the tree's only byte comparator, used at `test-floor.chiral:113` and `:365`.
- evidence: `lib/evidence/ddc.chiral:97-185`, `lib/evidence/test-floor.chiral:26`, `:31`, `docs/definitions/open-edges.md:657`
- checked:  2026-09-01
- element:  none, see [[open-edges]] 21

### BA-15 `lib/memory/alloc-fixed.chiral` has zero importers

- state:    ACCEPTED
- claim:    already recorded as open edge 22. Cross-referenced here rather than restated.
- measured: `grep -rn 'memory/alloc-fixed' lib prog tools` returns nothing. Kept on purpose so a future program can take it or `alloc-growing`. No gate compiles it.
- evidence: `docs/definitions/open-edges.md:696`
- checked:  2026-09-01
- element:  none, see [[open-edges]] 22

## Structure: what a tool program carries

### BA-16 four of six top-level roots have the identical 58-module closure

- state:    OPEN
- claim:    `prog/` is "what chirality ships, as distinct from what it is".
- measured: blob closures for the six top-level `.prog` roots, counted as `^(end-module "` markers and blob bytes:

  | root | modules | blob bytes |
  |---|---|---|
  | `prog/compiler.prog` | 58 | 772,967 |
  | `prog/paren-audit.prog` | 58 | 783,086 |
  | `prog/prose-lint.prog` | 58 | 780,557 |
  | `prog/wield.prog` | 58 | 774,101 |
  | `prog/test-runner.prog` | 61 | 865,722 |
  | `prog/resolve.prog` | 15 | 68,429 |

  `paren-audit` and `prose-lint` are text tools. They carry the whole compiler including the x64 backend and the ELF assembler because each imports `lowering/compile-all` for `read-fd-all`, a ten-line fd reader. A tools tier of `prelude/prelude`, `prelude/list`, `prelude/string`, `ports/fd`, `ports/stdio` resolves to 6 modules and 27,222 bytes, measured with a probe root.
- evidence: `prog/paren-audit.prog:34`, `prog/prose-lint.prog:32`, `lib/lowering/compile-all.chiral:41-48`
- checked:  2026-09-01
- element:  UNASSIGNED

### BA-17 the reader collision was routed around locally

- state:    OPEN
- claim:    a fix in one module is the tree's fix.
- measured: `lib/module/resolve.chiral` named its own fd reader `slurp-fd` and its header says the rename is load-bearing: `compile-all` defines a `read-fd-all` of its own, the two modules meet in one blob via `lib/evidence/test-floor.chiral`, and two defs of one name is `duplicate label`. So someone already hit the consequence of BA-16 and moved their own name out of the way. The reader is still duplicated and `read-fd-all` still lives inside the compiler's closure.
- evidence: `lib/module/resolve.chiral:58`, `lib/lowering/compile-all.chiral:47`
- checked:  2026-09-01
- element:  UNASSIGNED

## Navigation

### BA-18 `MAP.md` says `docs/elements/` is empty

- state:    FIXED
- claim:    "`elements/` is empty and stays empty until something derives it. Element status must come from a build-state authority."
- measured: both sides moved, 2026-09-01. The two files in `docs/elements/` were arc files, so they went to a new `docs/arcs/` tier by `git mv`; `docs/elements/` now holds a README stating what the tier is for and that the shape of a tracked element row is an open author call. `MAP.md`'s paragraph was replaced by a "Goals, arcs, elements" section describing what each of the three directories holds. The build-state-authority half of the claim survives unchanged: element status still comes from `docs/definitions/status-ledger.md`.
- evidence: `MAP.md` section "Goals, arcs, elements", `docs/elements/README.md`, `docs/arcs/README.md`
- checked:  2026-09-01
- element:  none

## Residue from the gate repair, 2026-09-01

BA-01 and BA-02 fixed two gates that could not fail. What follows is what the
repaired gates still cannot see, and what they saw once they could.

### BA-19 a citation inside a source comment is read by no gate

- state:    OPEN
- claim:    checks G and R are the tree's line-citation gates.
- measured: both walk `docs/**/*.md` and both require the citation to sit inside a backtick code span. `lib/` and `prog/` comments carry 59 line-numbered citations across 34 files, and not one is inside a code span or inside a doc. BA-13 is one of them: `(compile-emit.chiral:189)` in a `;` comment, bare parentheses. R could not reach it even with BA-02 fixed, and R's DEFINED-here limit rules it out a second time, because `native-lib` is defined in `lowering/tal/bytes.chiral:636` rather than in the file the comment cites. A gate for this class would be a third predicate. Neither existing one widens to reach it.
- evidence: `lib/ports/ports.chiral:28`, `lib/lowering/tal/bytes.chiral:636`, `tools/ledger-lint/ledger-lint.py:373`, `:455`
- checked:  2026-09-01
- element:  UNASSIGNED

### BA-20 294 doc citations name a path that does not exist

- state:    OPEN
- claim:    the migration is complete and the map records where each original went.
- measured: of 862 line-numbered citation spans in `docs/`, 294 name a file `_find_src` cannot open. They are pre-migration paths: `scaffold/lib/…`, `chirality/…`, and basenames whose file was deleted. G and R skip them by design, since naming an unbuilt file in residue is legitimate, so the count is the size of the class and not a defect list. Repointing them is a guess without the old tree, and `/workspace/metis-the-lang` is read-only reference. Nothing distinguishes a legitimately-unbuilt name from a rotted one today.
- evidence: `tools/ledger-lint/ledger-lint.py:345`, `.planning/MIGRATION-MAP.tsv`
- checked:  2026-09-01
- element:  UNASSIGNED

### BA-21 161 bare `:NN` spans have no subject a check can name

- state:    ACCEPTED
- claim:    the banks' detached convention is `ports.chiral` … (`:19`), a bare line span resolving against the last file named.
- measured: 161 of the 862 spans are a bare `:NN` whose paragraph names no resolvable file. Before BA-02's ctx fix they were read against whatever file resolved last, sometimes hundreds of lines earlier and about a different module. ACCEPTED because abstaining is the only sound option: a bare span read against the wrong file is a guess, and CLAUDE.md forbids aiming a check at one. Recovering them means the docs naming the file in the paragraph. The check guessing harder is the thing this row forbids.
- evidence: `tools/ledger-lint/ledger-lint.py:376`, `:458`
- checked:  2026-09-01
- element:  UNASSIGNED

### BA-22 34 citations under `docs/examples/` are stale, and repointing them is a policy call

- state:    OPEN
- claim:    worked examples are the design rationale for an element and are kept as written.
- measured: with BA-02 fixed, G reports 17 and R 17, every one under `docs/examples/`. No doc under `banks/`, `definitions/`, `decisions/`, `modules/` or `elements/` fails either check. G's 17 are 12 citations of `ports.chiral` at lines 70 through 185 against a 63-line façade, which is the pre-split monolith and needs the old tree to repoint; 2 of `alloc.chiral` at line 43 against 35 lines; 2 of `compile-emit.chiral` at 322 through 348 against 330; and one of `diag.chiral` at 704 against 693. R's 17 each cite a live symbol at a line other than its definition, some off by a banner (`backend.chiral` line 37 for `be-base`, defined at 38; `kernel.chiral` line 91 for `KCat`, defined at 101) and some at a line the element's own commits moved, where the surrounding prose quotes the pre-change source. Repointing that second group would make the narrative describe the wrong file. `docs/decisions/decision-scope.md` already records the same tier stance for the `ours_source:` paths and calls a bulk rewrite its own call. Nothing repointed here.
- evidence: `python3 tools/ledger-lint/ledger-lint.py` checks G and R, `docs/decisions/decision-scope.md`:194`
- checked:  2026-09-01
- element:  UNASSIGNED

### BA-23 check A reads a module key as a filesystem path

- state:    OPEN
- claim:    check A is "ledger evidence paths exist".
- measured: 5 issues, all module keys rather than paths: `surface/pretty`, `typing/pretty`, `surface/parse`, `typing/`. `is_pathish` accepts any token containing a slash, and `resolve` then tests `ROOT/surface/pretty`, which is nowhere a module lives. E181's row added the ones that fail today, so the check went red on a correct citation. It is the mirror of BA-02: a check whose resolver does not know the tree's own naming rule. `docs/decisions/decision-scope.md` still records check I as the only FAIL, which predates this.
- evidence: `tools/ledger-lint/ledger-lint.py:51`, `:71`, `docs/definitions/status-ledger.md:52`, `:54`
- checked:  2026-09-01
- element:  UNASSIGNED

## What the compiler claims to enforce and does not

Measured 2026-09-01 by writing a program that should be refused and running it.
Every row below was reproduced; none rests on a document. The method is the
importer count first, then a repro: a module with zero importers cannot refuse
anything, and in five of these rows that one number predicted the result.

### BA-24 a pure `->` function performs an effect and is accepted

- state:    OPEN
- claim:    `PRINCIPLES.md:62` "One atom with no exemptions" and `:89` "the port-check is the type-check". The membrane separates pure `->` from effectful `=>`.
- measured: `(declare pure-syscall (-> I64 Unit))` whose body calls `put` (declared `(extern put (=> Str Unit))` in `lib/ports/stdio.port:11`) passes `chirality check` and writes to stdout when run. A three-deep all-`->` chain does the same. What the arrow does enforce is nominal type identity: passing an `=>` value where `->` is demanded is `load: type mismatch`. So the arrow is a type tag, not a membrane. `typing/effects.chiral` holds three refusing rules; its two importers are both dead through `lib/module/sig-driver.chiral`, which has zero importers, and `typing/effects` is not in the 58-module compiler closure. README, `status-ledger` and `docs/banks/effect-and-alarm.md` disclose this accurately; `PRINCIPLES.md` does not.
- evidence: `lib/typing/effects.chiral`, `lib/module/sig-driver.chiral`, `lib/ports/stdio.port:11`, `PRINCIPLES.md:62`, `:89`
- checked:  2026-09-01
- element:  UNASSIGNED

### BA-25 termination checking never runs

- state:    OPEN
- claim:    `docs/definitions/totality.md` states that the checker refuses a divergent definition, and names the single-function spin loop as the example it refuses.
- measured: `lib/typing/totality.chiral` has zero importers. `(def spin (lam (n) (spin n)))` passes `chirality check`, compiles, and does not halt. E50's defining syntax is refused by the parser by name: `(declare f ty (measure structural 0))` gives `load: (declare name ty (measure ...)) -- measure attribute DEFERRED`. The feature has no front door. E50's `built` state was true of the Python oracle (`data.py _check_recgroup`), which was evicted; the state outlived its subject. `status-ledger.md:156` is correct and `docs/definitions/totality.md:97-104`, `:164-168` contradict it, stating that mutual and lexicographic recursion prove via syntax the parser rejects.
- evidence: `lib/typing/totality.chiral:11-12`, `lib/surface/parse.chiral:622`, `docs/definitions/totality.md:97-104`, `:164-168`, `docs/definitions/status-ledger.md:156`
- checked:  2026-09-01
- element:  E50

### BA-26 the TAL floor check is unreachable from the compile path

- state:    OPEN
- claim:    the tree lowers through typed assembly before machine code.
- measured: code does pass through TAL IR: `compile-emit` imports `lowering/tal/reify` and `lowering/x64/emit`. The check on that IR does not run. `ck-prog` and `ck-block` have zero callers. `ck-fn`'s only caller is `re-check` at `lib/lowering/upper/optimize.chiral:250`, and `optimize.chiral` has zero importers, so the one call site is unreachable. The compile path is `compile-front` then `compile-back` then `compile-emit`, and none of the three references a tal check.
- evidence: `lib/lowering/tal/check.chiral:223`, `:233`, `:242`, `lib/lowering/upper/optimize.chiral:250`, `lib/lowering/compile-emit.chiral:14-18`
- checked:  2026-09-01
- element:  UNASSIGNED

### BA-27 strict positivity accepts a nullary mutual cycle

- state:    OPEN
- claim:    strict positivity is enforced; the row reads `Built - ENFORCED`.
- measured: two mutually-referencing nullary datatypes are accepted, compile, and diverge at run time. The variance walk at `lib/surface/data.chiral:270`, `:284` recurses into a type constructor's arguments only, and a nullary type constructor has none, so the negative occurrence is never visited. This is a false ENFORCED row rather than a stale one: the check runs and returns the wrong answer.
- evidence: `lib/surface/data.chiral:247-294`, `:270`, `:284`
- checked:  2026-09-01
- element:  E07

### BA-28 refinement bounds wrap at the I64 extremes

- state:    OPEN
- claim:    a refinement that cannot be inhabited is refused.
- measured: `(def bad (refine I64 (> 9223372036854775807)) 0)` passes `chirality check`. The same file at `9223372036854775806` and at `10` both give `load: cannot prove refinement`, so the gate is armed and only the extreme escapes. `c-atom` builds `s-gt` as `(max-lo lo (+ k 1))` and `s-lt` as `(min-hi hi (- k 1))`; at `I64_MAX` the `+1` wraps to `I64_MIN` and the bound inverts to TOP. The non-adjusting operators `>=` and `<=` are correct at the same extremes. A contradictory `{v > MAX and v < MIN}` compiles, links and runs. `.planning/audit/AUDIT-MAP.md` records this as D1, "UNSOUND if ported naively, open, no current bug"; the port happened without the guard, so the last clause is false. E11 ported the same arithmetic with the guard (`lib/typing/totality.chiral:257`, `:262`), so the obligation was written once, into the other element's contract.
- evidence: `lib/typing/refine.chiral:118`, `:120`, `lib/typing/kernel.chiral:1349`, `:1488`, `lib/typing/totality.chiral:257`, `:262`
- checked:  2026-09-01
- element:  E09

### BA-29 profile requirements are not checked against providers

- state:    OPEN
- claim:    a profile is a frozen conformance contract; `MAP.md` sorts `.profile` as a kind and `docs/banks/profile.md` describes requirement checking.
- measured: `(target T (require run (-> I64 I64)))` with `run` absent, and the same with `run` present at the wrong type, both pass `chirality check` and emit an ELF. The conformance judgment (requirement to provider subtype) lived in `surface.py`, which was cut with the Python oracle; no chirality successor exists, and there is no ledger row or element number for one. Test phase 4's 31 assertions exercise the manifest grammar, not the judgment. Distinct from BA-10, which records that `.profile` has no instance.
- evidence: `docs/banks/profile.md`, `MAP.md:5`, test phase 4
- checked:  2026-09-01
- element:  UNASSIGNED

### BA-30 the file kind is never checked

- state:    OPEN
- claim:    `MAP.md:5` "the resolver checks it" and `:37-40` the kind is "checked by the loader". The extension is the kind.
- measured: a `.port` file containing a lambda compiles. A `.manifest` file with a computed body compiles and runs. Neither the resolver nor the loader has an implementation of a kind check. The argument that a large fraction of the tree never enters the resolution space, so the bad state is unrepresentable, rests on this check existing.
- evidence: `MAP.md:5`, `:37-40`, `bin/chirality-resolve.sh`, `lib/module/loader.chiral`
- checked:  2026-09-01
- element:  UNASSIGNED

### BA-31 a bank refutes a real gap with a command that does not exist

- state:    OPEN
- claim:    `docs/banks/profile.md:246` cites `chirality verify` to argue that the profile conformance gap is already covered.
- measured: `bin/chirality` offers `compile`, `run`, `check`, `test`, `help`. There is no `verify`. It is cited in 14 places, four of them under `docs/banks/`. The banks are the repo's mandated pre-flight read: CLAUDE.md requires reading a feature's bank before naming a gap, because naming a phantom is the cardinal error here. This row is that rule inverted, a phantom command used to dismiss a gap that BA-29 shows is real. `docs/definitions/testing-floors.md` is dated 2026-09-01 and lists `chirality test-native` and `chirality test-rocq` as GATING floors; neither exists and there is no `rocq/` directory. Overlaps BA-08, which records the floors table; this row is about the bank.
- evidence: `docs/banks/profile.md:246`, `bin/chirality`, `docs/definitions/testing-floors.md`
- checked:  2026-09-01
- element:  none

### BA-32 23 reject fixtures are skipped rather than asserted

- state:    OPEN
- claim:    the suite reports 303 assertions, 0 failed, and the `*_reject_*` fixtures exist to prove the compiler refuses what it should refuse.
- measured: `tools/test/run-tests.sh:174` reads `case "$rb" in *_reject_*) continue`, so phase 7 skips every reject root instead of asserting that it fails. All 23 were run by hand and all 23 still reject, so this is 23 assertions behind one `continue` rather than a defect in the compiler. Separately, 47 of the 53 fixtures under `tools/test/samples/` are referenced by no script at all; `run-tests.sh:18-24` records phases 8, 9, 11 and 12 as `NOT PORTED -- script owed`.
- evidence: `tools/test/run-tests.sh:174`, `:18-24`, `tools/test/samples/`
- checked:  2026-09-01
- element:  none

### BA-33 33 of 50 port crossings take no capability

- state:    OPEN
- claim:    every crossing is capability-mediated.
- measured: 33 of the 50 `extern` declarations under `lib/ports/` take no capability argument. `write-fd 1 <bytes>` writes to stdout while holding nothing. `mmap`, `mprotect`, `signal`, `socketpair` and `open-rw` are in the same list. The ports floor is a naming and routing boundary, which BA-12 records from the byte-cost side; this row is the authority side.
- evidence: `lib/ports/*.port`
- checked:  2026-09-01
- element:  UNASSIGNED

### BA-34 `Clock` and `Timer` are uninhabited

- state:    OPEN
- claim:    `lib/ports/clock.port` types a clock discipline.
- measured: every extern in the port consumes a `Clock` or `Timer` and none produces one, and the port types have no constructor, so no program can obtain either. `lib/runtime/supervisor.chiral` is uncallable for the same reason. The discipline is vacuously satisfied: it cannot be violated because it cannot be used.
- evidence: `lib/ports/clock.port`, `lib/runtime/supervisor.chiral`
- checked:  2026-09-01
- element:  UNASSIGNED

### BA-35 `str-sub` reads past the end of its string and reports the read length

- state:    OPEN
- claim:    indexing is bounds-checked. `lib/prelude/string.chiral:14` asserts in a comment that "str-sub clamps, so a too-long prefix is just false", and `starts-with?` at `:17` is written against that clamp.
- measured: `str-sub : (-> Str I64 I64 Str)` is `(s start end)`, half-open, and does not clamp. `(str-len (str-sub "abc" 0 99))` returns `99`: a three-character source yields a ninety-nine-character result, so the primitive reads past the end of the buffer and reports the out-of-range length as the string's length. The comment at `:14` is false and `starts-with?` rests on it. `.planning/FINDING-str-sub-range-2026-08-31.md:12` additionally records `(str-len (str-sub "abc" 2 1))` as SIGSEGV exit 139; that half did NOT reproduce on the current `bin/chirality-bin` (exit 0), so either the finding predates a change or the crash needs a condition the one-liner does not supply. Only the unbounded read is carried here as measured. E176 owns `str-sub` range discipline per `docs/decisions/decision-lane-split.md`.
- evidence: `lib/prelude/prelude.chiral:80`, `lib/prelude/string.chiral:14`, `:17`, `.planning/FINDING-str-sub-range-2026-08-31.md:12`
- checked:  2026-09-01
- element:  E176

### BA-36 ledger-lint exits 0 while three checks fail

- state:    OPEN
- claim:    `README.md:63` says `ledger-lint` exits 1. CLAUDE.md says the count of path mismatches is 0.
- measured: the run prints `[FAIL]` for A, I and T and `[VACUOUS]` for H and M, and exits 0. So a caller gating on the exit status sees a pass. Both documents are wrong and in opposite directions: the README describes a failing exit the tool does not produce, and CLAUDE.md describes a clean count the tool contradicts. Check A's own defect is BA-23.
- evidence: `python3 tools/ledger-lint/ledger-lint.py`, `README.md:63`, `CLAUDE.md`
- checked:  2026-09-01
- element:  none

## Residue from the `.planning` consolidation, 2026-09-01

### BA-37 the two E181 artifacts cite a file the consolidation deleted

- state:    OPEN
- claim:    a worked example and its SPEC are the design rationale for an element and are kept as written, so their citations resolve.
- measured: `HANDOFF-DIAGNOSTICS-ARC.md` was split into `records/diagnostics-arc-record.md` (binding decisions, traps) and `docs/arcs/diagnostics-arc.md` (live arc state) and deleted from the root. Six citations of it survive in the two E181 artifacts: three in the example (`:188` the blob-size quote, `:199` a binding decision, `:661` the empty-`cmp` trap) and three in the SPEC (`:454` the status table and Lane A queue, `:465` a promotion step, `:681` the chain and the arc's binding decisions). Each names a file that is not in the tree. Not repaired: both are frozen-rationale tier and `records/consolidation-handoff.md` §2 binds this class to record-do-not-chase, the same stance BA-22 takes for the other 34. Every other live citation of the deleted file was repointed in the same commit; `docs/decisions/decision-lane-split.md:5` and `records/diagnostics-arc-record.md:15` keep theirs as historical "was X, moved to Y" notes, which is correct.
- evidence: `docs/examples/E181-pretty-term-doc.md:188`, `:199`, `:661`, `docs/elements/specs/E181-pretty-term-doc-SPEC.md:454`, `:465`, `:681`, `records/consolidation-handoff.md`
- checked:  2026-09-01
- element:  UNASSIGNED

### BA-38 eleven citations point into another repository's untracked working material

- state:    OPEN
- claim:    `records/consolidation-handoff.md` §3 called these dead citations — `.planning/METIS-PORT-SPEC.md` "present nowhere in the tree" and "four `.planning/scriba-examples/S1`–`S3` files that do not exist". The wider claim behind the consolidation is that a fresh clone can follow what a tracked document cites.
- measured: not dead, and not this repo's. All eleven name files under `/workspace/manas/.planning/`, and all five exist on disk: `METIS-PORT-SPEC.md` (6 citations), `scriba-examples/S1-puffer.md` (2), `S1-puffer-AUDIT.md` (1), `S2-S3-rendering-loop.md` (1), `S2-S3-rendering-loop-AUDIT-v2.md` (1). The fragility is a different class: manas has no `.gitignore` rule for `.planning/` and tracks 45 files under it, but `git ls-files --error-unmatch` reports all five UNTRACKED, so they exist on one laptop's disk and a fresh clone of either repository reaches none of them. Two forms are also unopenable from this repo with manas present — `manas/.planning/...` at `S1-puffer-SPEC.md:6` and `[[../manas/.planning/...]]` at `:374`, `:375` are relative and resolve only from `/workspace/`. Not repaired: copying another repo's design spec in is an author call, and absolute `/workspace/manas/...` encodes one laptop's layout. Separately and genuinely dead: `docs/elements/specs/E94-form-type-capacity-SPEC.md:101` cites `.planning/E94-diagnostic.md`, which `find` locates in none of chirality, manas or metis-the-lang.
- evidence: `docs/elements/catalog.md:222`, `docs/examples/E133-manas-core-types.md:37`, `docs/examples/E134-gate.md:39`, `docs/examples/E135-bind.md:42`, `docs/examples/E136-match-assemble-stop.md:35`, `docs/examples/E138-run-loop.md:39`, `docs/elements/specs/S1-puffer-SPEC.md:6`, `:374`, `:375`, `docs/elements/specs/S2-rendering-SPEC.md:6`, `:7`, `docs/elements/specs/E94-form-type-capacity-SPEC.md:101`, `records/consolidation-handoff.md`
- checked:  2026-09-01
- element:  UNASSIGNED

### BA-39 E173's SPEC mutant M3 is inert, because termination is not enforced

- state:    OPEN
- claim:    `docs/elements/specs/E173-total-matcher-SPEC.md` §5 carries M3, a mutant that makes `pd`'s `p-star` arm recurse into `(p-star q)` instead of a strict subterm, and asserts `chirality check` refuses it. The SPEC passed its audit at `4769cd2`, and `.planning/protocol/workflow.md` requires every gate row to name a mutant that is actually run.
- measured: M3 does not fail. The mutant was built in a scratch `lib/` copy during E173 step 3 and the module compiled, rc 0. The reason is recorded one tier up and was not consulted by either SPEC audit: `docs/definitions/status-ledger.md:156` states "Termination is neither enforced nor classified in the built compiler", because `lib/typing/totality.chiral` is the built E11 classifier and no module imports it. Measured here: `grep -rn 'import "typing/totality"' lib/ prog/` returns 0. So a gate row asserting a termination refusal passes by looking at nothing, which `docs/decisions/decision-scope.md` names as the error the tree exists to avoid. Not repaired: step 6 owns Phase 19 and the mutant table, and the fix is a spec correction before that step, not a patch to a gate script that does not exist yet. Every function in `lib/text/matcher.chiral` still meets the written criterion of `docs/definitions/totality.md:48-53` by hand, checked at step 3, so the code is not in doubt. The check is.
- evidence: `docs/elements/specs/E173-total-matcher-SPEC.md` §5 M3, `docs/definitions/status-ledger.md:156`, `lib/typing/totality.chiral`, `.planning/protocol/workflow.md`
- checked:  2026-09-01
- element:  E11 (wiring the classifier is E11's remaining work; no new element is owed)
