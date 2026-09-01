---
node: checklists-baseline-alignment
layer: navigation
related: [checklists/README, status-ledger, open-edges, testing-floors, index]
status: current
updated: 2026-09-01
---

# Baseline alignment arc

Author's framing: get current work to actually align with the goals we claim,
since apparently we do not. Every row is a claim this repo makes about itself
beside what was measured.

Row format, states and the rules for adding, changing and retiring a row are in
[[checklists/README]]. Prefix is `BA`.

This arc has NO reserved element number block. `LANES.md` reserves E184-E189 and
E190-E195 for the two diagnostics lanes. Rows needing an element carry
`UNASSIGNED` until the author assigns a block.

Everything below was measured on 2026-09-01. Line citations are current as of
`b7d27f3`. Re-run a row's evidence before relying on it: a banner or an
insertion above a cited line moves it, which is BA-13.

## Gates that cannot fail

The repo's own cardinal error class, from CLAUDE.md: a gate aimed at a floor the
tree lacks, or at a guess, passes by looking at nothing.

### BA-01 map-integrity passes a row that has no destination

- state:    OPEN
- claim:    every `new_path` in the migration map exists; a row with no destination is skipped by the `[ -z "$new" ] && continue` guard, and a row pointing at a moved path is reported STALE.
- measured: `IFS=$'\t' read -r old new ext why` collapses runs of tabs, so a 4-column row with a blank `new_path` shifts `ext` into `$new`. Reproduced with a synthetic row `lib/gone.chiral<TAB><TAB>prog<TAB>retired`: the loop bound `new=prog`, `ext=retired`, `why=` empty, the `-z` guard did not fire, and `[ -e $ROOT/prog ]` was true, so the row passed. The `-z` branch is unreachable for any 4-column row. Retired rows currently dodge this by using the brace form, which the `*"{"*` branch skips.
- evidence: `tools/test/map-integrity.sh:14`, `:16`, `:18`, `:19`
- checked:  2026-09-01
- element:  UNASSIGNED

### BA-02 ledger-lint checks G and R cannot see a `.chiral` citation

- state:    OPEN
- claim:    check G is "line-numbered code citations in docs still fit the file" and check R is "a line citation lands on the symbol it is cited FOR". R's own docstring cites `ddc.chiral:127` as the defect it was built for.
- measured: both regexes are `([A-Za-z0-9_/.-]+\.(?:py|chirality))`. The tree's extension is `.chiral`, which neither alternative matches. Docs carry 279 spans of the form `path.chiral:NN` and zero of them can match. 624 spans do match the regex, all Python, and `_find_src` resolves 12 of them to a file that still exists. So G and R together inspect 12 citations out of roughly 903. Both report `[ok] 0 issues`.
- evidence: `tools/ledger-lint/ledger-lint.py:342`, `:412`, `:316`
- checked:  2026-09-01
- element:  UNASSIGNED

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
- claim:    `HANDOFF.md`'s state table says `tools/test/samples/` holds 98 files.
- measured: `ls tools/test/samples/ | wc -l` counts 54. Four of the gap is the C-leg fixture drop at `d0c5dd5`, which removed `e166_c_assemble.prog`, `e166_ddc_legc.prog`, `e166_mach_c.prog` and `e166_mach_c_reject_lda6.prog`. The other 40 is older drift and is undiagnosed.
- evidence: `HANDOFF.md:57` (the fixtures row), commit `d0c5dd5`
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

- state:    OPEN
- claim:    `lib/ports/ports.chiral`'s header attributes the unconditional append to `compile-emit.chiral:189`.
- measured: the only `app-tfn native-lib` site is line 295. Line 189 is elsewhere in the file. Found while verifying BA-12. This is the class check R was built to catch and cannot, per BA-02.
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

- state:    OPEN
- claim:    "`elements/` is empty and stays empty until something derives it. Element status must come from a build-state authority."
- measured: `docs/elements/` holds `diagnostics-arc.md`, 37.7 KB, added by `9016bef` and revised by `c273971`. Its opening states why it is hand-written and tracked: `.planning/` is git-ignored, so an element fact a second reader needs cannot live there. The two positions are both defensible and they contradict. MAP.md is the contract, so the contract is the side that is stale.
- evidence: `MAP.md:159`, `docs/elements/diagnostics-arc.md:11-19`
- checked:  2026-09-01
- element:  UNASSIGNED
