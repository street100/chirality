# limits

One row per entry. The schema, the states and the two axes are in `README.md`.

### LIM-01 ledger-lint H and M are VACUOUS by decision

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    tools/ledger-lint/ledger-lint.py
- claim:    `ledger-lint` runs 36 checks, A through AJ, re-measured 2026-09-05. It ran 19 when this row was written.
- measured: H and M print `VACUOUS` and say so in the run's own output. H verified the idioms cheatsheet against `refine.py`, cut with the Python oracle. M guarded a scaffold-to-TUI symlink web dissolved by the migration. Both subjects are genuinely gone, which is why this is ACCEPTED and not OPEN. H is repointable at `lib/typing/refine.chiral:11` and `lib/module/loader.chiral:20`, both live; that repoint was measured against live files. M has no live subject.
- evidence: `tools/ledger-lint/ledger-lint.py:517` (check H), `:729` (check M)
- checked:  2026-09-05
- owner:    none
- from:     BA-03

### LIM-02 `cmd_check` runs the whole compiler, and defends it

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    records/baseline-alignment.md
- claim:    recorded here because BA-05 has a considered defense, quoted below.
- measured: `cmd_check` compiles the unit with the real compiler and discards the ELF. Its header states the reason: "checking is compiling and throwing the ELF away, the same front end, no second implementation to drift." That is a real argument and it is why BA-05 is a classification defect rather than an architecture defect. A second front end that only type-checks would drift from the one that compiles.
- evidence: `bin/chirality:155-159`, `bin/chirality:173`
- checked:  2026-09-01
- owner:    none
- from:     BA-06

### LIM-03 the port floor is a naming boundary and buys zero bytes

- state:    accepted
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/ports/ports.chiral
- claim:    nine port registries under `lib/ports/`, one per concern, with `ports/ports.chiral` as the façade.
- measured: the file's own header says the split "is worth exactly 0 bytes at runtime", because the image is `native-lib` prepended to `link-lib` prepended to the object, unconditionally. Verified: `(let (image (app-tfn native-lib (app-tfn link-lib obj)))` with no reference to the declared port set. A program importing one registry and a program importing all nine emit the same size. So the port floor narrows what a module may NAME, and the H8 profile gate narrows what it may CALL, and neither narrows the emitted bytes. ACCEPTED because the header states it plainly. Recorded because two documents describe it as a floor without saying so.
- evidence: `lib/ports/ports.chiral:26-30`, `lib/lowering/compile-emit.chiral:295`
- checked:  2026-09-01
- owner:    none
- from:     BA-12

### LIM-04 `lib/evidence/ddc.chiral` has no callers for its DDC half

- state:    accepted
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/evidence/ddc.chiral
- claim:    already recorded as open edge 21. Cross-referenced here rather than restated.
- measured: `ddc-fold`, `ddc-legs`, `ddc-compare`, `ddc-verdict-code`, `ddc-leg0`, `ddc-leg1`, `ddc-legc`, `ddc-legcc`, `LegOut` and the `DdcR` sum have zero callers and zero assertions in `lib`, `prog` or `tools` after `d0c5dd5` deleted `e166_ddc_legc.prog`. The only grep hit outside the file is a prose mention. The file stays reachable because `lib/evidence/test-floor.chiral:31` imports it for `bytes=?`, the tree's only byte comparator, used at `test-floor.chiral:113` and `:365`.
- evidence: `lib/evidence/ddc.chiral:97-185`, `lib/evidence/test-floor.chiral:26`, `:31`, `docs/definitions/open-edges.md:657`
- checked:  2026-09-01
- owner:    none
- from:     BA-14

### LIM-05 `lib/memory/alloc-fixed.chiral` has zero importers

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    docs/definitions/open-edges.md
- claim:    already recorded as open edge 22. Cross-referenced here rather than restated.
- measured: `grep -rn 'memory/alloc-fixed' lib prog tools` returns nothing. Kept on purpose so a future program can take it or `alloc-growing`. No gate compiles it.
- evidence: `docs/definitions/open-edges.md:696`
- checked:  2026-09-01
- owner:    none
- from:     BA-15

### LIM-06 161 bare `:NN` spans have no subject a check can name

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    tools/ledger-lint/ledger-lint.py
- claim:    the banks' detached convention is `ports.chiral` … (`:19`), a bare line span resolving against the last file named.
- measured: 161 of the 862 spans are a bare `:NN` whose paragraph names no resolvable file. Before BA-02's ctx fix they were read against whatever file resolved last, sometimes hundreds of lines earlier and about a different module. ACCEPTED because abstaining is the only sound option: a bare span read against the wrong file is a guess, and CLAUDE.md forbids aiming a check at one. Recovering them means the docs naming the file in the paragraph. The check guessing harder is the thing this row forbids.
- evidence: `tools/ledger-lint/ledger-lint.py:369` (`_find_src`), `:379` (check G)
- checked:  2026-09-05
- owner:    none
- from:     BA-21

### LIM-07 the declared matrix, re-run and reconciled

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    tools/test/mutant.sh
- claim:    `tools/test/mutant.sh:156-196` declares seven mutants, each with the rule it is expected to convict.
- measured: `bash tools/test/mutant.sh --matrix`, 2026-09-04, control green on all five phases before any mutation. All seven built, all seven differ from the base, all seven reach a self-hosting fixpoint. Every one is convicted by at least one phase, so no declared mutant is a live coverage hole today. The table, `RED` meaning the phase caught it: | mutant | check-cli | profile-target | linear-mint | syscall-manifest | diag | |---|---|---|---|---|---| | `qfits-q1-accepts-all` | RED | green | RED | green | RED | | `qfits-q0-accepts-all` | green | green | RED | green | RED | | `qjoin-q1-no-saturate` | green | green | RED | green | green | | `qjoin-q0-no-saturate` | green | green | RED | green | green | | `strip-binder-off` | RED | green | RED | green | RED | | `close-binder-off` | green | green | RED | green | RED | | `port-purity-off` | green | RED | green | green | green | `linear-mint.sh` carries six of the seven alone, and the two `qjoin` arms have it as their only convicting phase. `syscall-manifest.sh` is green on every row, which is correct: all seven mutate `lib/typing/` or `lib/surface/parse.chiral` and its subject is the syscall registry, covered by its own poisons (GA-06).
- evidence: `tools/test/mutant.sh:156-196`, `:198-223`
- checked:  2026-09-04
- owner:    none
- from:     GA-02

### LIM-08 syscall-manifest.sh honours the rule in its own idiom

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    tools/test/syscall-manifest.sh
- claim:    a pre-dispatch grep scored this script at 0 gate rows and 0 mutants.
- measured: both halves of that count are wrong, and the correction belongs here because it changes where the hole is. `bash tools/test/syscall-manifest.sh` reports **12 passed, 0 failed**. Its assertion helpers are `prof` (`tools/test/syscall-manifest.sh:49`) and `poison` (`tools/test/syscall-manifest.sh:79`), which a grep for `check` or `ok` misses. `poison` is a mutant harness built into the phase: it seds the compiler's own blob, rebuilds a compiler from the poisoned stream, and asserts the rebuilt compiler refuses to emit. Four call sites at `tools/test/syscall-manifest.sh:113`, `:115`, `:118`, `:121`, of which the first is the positive control (`p;d`, the clean blob still compiles) and three are real mutants of the registry rows in `lib/lowering/tal/target-linux.manifest:23`, reached through the compiler's own blob. The harness closes three of `mutant.sh`'s four silent failures independently: `cmp -s` against the base blob refuses a poison that matched nothing (`tools/test/syscall-manifest.sh:83-85`), a build failure is reported as its own FAIL (`tools/test/syscall-manifest.sh:86-89`), and the control row runs first. It carries no equivalent of `mutant_differs` at the binary level, and the blob `cmp` stands in for it at the source level.
- evidence: `tools/test/syscall-manifest.sh:49`, `:79-101`, `:113-123`
- checked:  2026-09-04
- owner:    none
- from:     GA-06

### LIM-09 size and the fixpoint carry no signal, re-measured

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    tools/test/mutant.sh
- claim:    `tools/test/mutant.sh:34-41` records, measured 2026-08-31, that five semantic mutants of the QTT usage audit each produced a compiler of exactly 1,098,104 B and four reached a byte-identical self-hosting fixpoint.
- measured: reproduced today at a new base size. `bin/chirality-bin` is 1,188,216 B. All seven declared mutants and the new `total-clause-dead` built at **exactly 1,188,216 B**, and **all eight** reached a self-hosting fixpoint under `mutant_fixpoints`. Eight for eight, including a compiler with the lam binder usage audit disabled and a compiler with the E11 totality gate disabled. Reading a survival off a size or off a fixpoint would have scored every one of them correct.
- evidence: `tools/test/mutant.sh:34-41`, `:125`, `:142-147`
- checked:  2026-09-04
- owner:    none
- from:     GA-09

### LIM-10 pretty.sh runs all seventeen of the mutants it names

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    tools/test/pretty.sh
- claim:    `tools/test/pretty.sh:22-38` maps thirteen gate rows G1 to G13 onto seventeen mutants M1 to M17, and every one of the seventeen is named in a row heading.
- measured: `bash tools/test/pretty.sh` reports **61 passed, 0 failed** in 6.4 s. The pre-dispatch grep predicted ~51 rows and 17 mutants; the mutant count is right and the row count is 61, of which 17 are mutant rows and 44 are gate rows. All seventeen mutants are EXECUTED. Fourteen go through `mutlib` (`tools/test/pretty.sh:103-117`), which copies `lib/` to scratch, refuses a symlinked scratch tree, and `cmp`s the mutated file against the tree so a stale anchor is reported as a FAIL instead of reading as a pass; three are inline (M10 over the eight sha256 pins, M11 over the registration grep, M14 over the cross-assertion scan). All seventeen changed the file they name. Sixteen redden a row the header attributes to them, measured by copying the whole tree to scratch, applying the mutant's own `sed` to that copy's `lib/`, and re-running the phase against it: M2 turns G2 red (and thirteen G1 goldens with it), M3 turns G3's width-40 row red, M4 turns G3's width-12 row red, M5 turns G4 red, M6 turns G5 red, M7 turns G6 red, M8 turns G7 red, M16 turns G11b red. M9, M12, M13, M15 and M17 convict compositionally: each re-runs the row's own predicate (`census` at `:473`, `closure` at `:552`, `code_only` at `:501`, `build_err` at `:89`) over the mutated tree, so the conviction is the gate row's own comparison with one input changed. M1 is GA-13.
- evidence: `tools/test/pretty.sh:22-38`, `:89-94`, `:103-117`, `:199`, `:222`, `:250`, `:259`, `:275`, `:294`, `:311`, `:330`, `:399`, `:410`, `:414`, `:432`, `:439`, `:464`, `:486`, `:505`, `:573`
- checked:  2026-09-04
- owner:    none
- from:     GA-12

### LIM-11 face.sh honours the rule on all thirteen

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    tools/test/face.sh
- claim:    `tools/test/face.sh:56` reads that EVERY ROW CARRIES A NAMED MUTANT THAT IS RUN, and `:50-53` that the thirteenth mutant exists because G7(c)'s arity scan was the one row here nothing could redden.
- measured: `bash tools/test/face.sh` reports **38 passed, 0 failed** in 2.5 s. The pre-dispatch grep predicted ~40 rows and 13 mutants; the mutant count is right and the row count is 38, of which 19 are mutant rows over 13 distinct mutants and 19 are gate rows. All thirteen are EXECUTED: nine through `mutlib` (`:133`), which carries the same scratch-tree and `cmp` guards as `pretty.sh`, and four inline (M8 over the five sha256 pins, M9 over the four registrations, M12 a declared seven-argument caller, M13 the arity scanner over a probe file). All thirteen changed what they name. Every one reddens the row the header attributes to it, measured the same way as GA-12 by re-running the whole phase against a mutated scratch tree: M1 turns G1 and G5 red, M2 turns G1 red, M3 turns G2 and G3 red, M4 and M5 each turn G4 red, M6 turns G4(b) red while leaving G4(a) byte-identical, which is exactly what `:475-477` predicts and the stated reason shape (b) exists at all; M7 turns G6 red and nothing else, the cell map staying put, which is the stated reason G6 is a raw-byte row; M10 and M11 break the G8 compiles. M8, M9 and M13 convict compositionally by re-running the row's own function (`sha_of`/`pin` at `:547-548`, `reg` at `:579`, `ARITY_AWK` through `arity_scan` at `:615`) over a changed input. Two rows carry no mutant and both are labelled controls: the fixture-builds row and G8's own control. This script is the shape the rule asks for.
- evidence: `tools/test/face.sh:36-61`, `:133-147`, `:354`, `:370`, `:401`, `:449`, `:462`, `:478`, `:519`, `:547-568`, `:579-591`, `:615-641`, `:658`, `:671`, `:699`
- checked:  2026-09-04
- owner:    none
- from:     GA-14

### LIM-12 the idiom that makes a mutant row convict its own gate row

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    tools/test/mutant.sh
- claim:    `docs/definitions/testing-floors.md:287` binds a gate row to a mutant that is RUN, and `tools/test/mutant.sh:26-30` names the third silent failure: the mutant reddens some other row, or reddens nothing while the script still reports it as convicting.
- measured: the three scripts audited here close that failure by a shape worth naming, because it is what separates them from the five phases GA-03 to GA-08 found holes in. A mutant row either re-runs the gate row's own function over a mutated input (`census`, `closure`, `pin_check`, `sha_of`, `reg`, `screen`, `cell_sgr`, `ARITY_AWK`) or compares the same expression at the same coordinates against a different expected value. `tools/test/row.sh:517-526` carries the strongest form of it, `g4_mutant`, which re-runs `g4_report` over the mutated tree and asserts by NAME which constructor row went red, so a mutant reddening some other row is reported as a FAIL by the script itself. Where a mutant block instead paraphrases the row, the paraphrase can drift from the row and GA-13 is that drift measured. The whole-tree re-run is what tells the two apart, and it costs one `cp` and one phase run: 6.4 s for `pretty.sh`, 2.5 s for `face.sh`.
- evidence: `tools/test/mutant.sh:26-30`; `tools/test/pretty.sh:473`, `:501`, `:552`; `tools/test/face.sh:547-548`, `:579`, `:615`; `tools/test/row.sh:517-526`
- checked:  2026-09-04
- owner:    none
- from:     GA-15

### LIM-13 row.sh runs all thirteen, and `g4_mutant` names the row it reddens

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    tools/test/row.sh
- claim:    `tools/test/row.sh:20-22` reads that every row that matters renders through `render-to-ansi` and READS THE EMITTED BYTE STREAM, and that every row carries a named mutant that is RUN. `:24-35` maps eight gate rows G1 to G8 onto thirteen mutants.
- measured: `bash tools/test/row.sh` reports **41 passed, 0 failed**. The pre-dispatch grep predicted ~28 rows and 13 mutants; the mutant count is right and the row count is 41, of which 16 are mutant rows over 13 distinct mutants and 25 are gate rows. All thirteen are EXECUTED and all thirteen change the file they name, `mutlib` (`:125-136`) carrying the `cmp` guard that reports a stale anchor as a FAIL. Its `mutlib` omits the scratch-tree symlink check `pretty.sh:106-108` and `face.sh:136-138` both carry. Six of them go through `g4_mutant` (`:517-526`), which is the strongest form of the rule found in this pass: it re-runs `g4_report`, the same function that emitted the base rows, and asserts by NAME which constructor row went red. Measured red lists, one row each: M2 `r-stream`, M3 `r-face`, M11 `r-tree`, M4 `r-row`, M13 `r-table`, M10 `r-section`. The other seven convict by re-running the row's own predicate over a changed input (`census`, `sha_of` against the pin, `reg`, `g3_map`, `build_run`, `build_err`), and three of those were confirmed against the whole tree by copying the repository to scratch, applying the mutant's `sed` to that copy's `lib/`, and re-running the phase: M1 turns G3's cell map red, M6 turns G1's `apc.chiral` row red with `load: non-exhaustive case`, M7 turns G2 red at case 9, which is the case its own row names.
- evidence: `tools/test/row.sh:20-35`, `:125-136`, `:361`, `:385`, `:418`, `:517-526`, `:531-556`, `:597-607`, `:622-630`, `:655-668`, `:683-689`, `:730-734`, `:752-757`
- checked:  2026-09-04
- owner:    none
- from:     GA-16

### LIM-14 the full-line pin closes all four silent failures, and the entry-point hazard with them

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    tools/test/arity.sh
- claim:    `tools/test/arity.sh:75-79` reads that a build which did not happen scores `nobuild` and never `bad`, and that no pinned line below ever expects that token, so a mutant that merely fails to compile cannot wear a red row and be read as a conviction. `tools/test/mutant.sh:19-40` names the four ways the measurement fails silently, and this idiom is a second implementation of the same rule.
- measured: all four scripts ran green in this session: `arity.sh` **13 passed, 0 failed** in 12 s, `doc.sh` **26 passed, 0 failed**, `matcher.sh` **18 passed, 0 failed**, `render-doc.sh` **19 passed, 0 failed**. A green phase is what makes each declared pin the measured red set, and every row below reads off that. The idiom closes all four failures, three of them by an assertion and the fourth by the pin itself. (1) A mutation that matched nothing is refused by `cmp -s` against the tree under test, in every copy of `mutlib` (`arity.sh:161-163`, `matcher.sh:161-163`, `render-doc.sh:145-147`) and inline in `doc.sh:119-121`. (2) A mutant that did not build produces a token no pin holds: `verdict` scores `nobuild` per row group (`arity.sh:275`, `:283`, `:290`) or collapses the whole line to `BUILD:fail` (`matcher.sh:229`, `render-doc.sh:247`), and `doc.sh`'s `build_run` returns 255 (`doc.sh:64-74`). Read against every pin in the four files, five in `arity.sh` (`:361`, `:371`, `:382`, `:393`, `:402`), nine in `matcher.sh` (`:314-384`), seven in `render-doc.sh` (`:332-392`) and five case numbers 1, 3, 4, 8 and 14 in `doc.sh` (`:127`, `:131`, `:136`, `:190`, `:196`), no want string carries `nobuild`, `BUILD:fail` or 255. So the entry-point hazard is closed by string equality rather than by care, and a mutant that fails to build is reported as a FAIL of its own row. (3) A semantically inert mutant produces an all-`ok` line, which no pin holds either. (4) A red base is caught first: each script asserts `verdict "$REPO/lib"` equals `ALLOK` before any mutation (`arity.sh:300-301`, `matcher.sh:266-267`, `render-doc.sh:294-295`), and `doc.sh` runs its fixture over the real tree at `:97-100`. The want-verdict is computed by the function that emitted the base rows in all four: `verdict` takes the library directory as its only argument (`arity.sh:270`, `matcher.sh:227`, `render-doc.sh:245`) and `doc.sh` calls one `build_run` over one fixture for both legs (`:66`, `:97`, `:122`). Nothing is re-derived anywhere a mutation cannot reach.
- evidence: `tools/test/arity.sh:75-79`, `:152-165`, `:270-293`, `:300-301`, `:325-334`; `tools/test/matcher.sh:146-160`, `:227-260`, `:266-267`, `:297-307`; `tools/test/render-doc.sh:131-145`, `:245-288`, `:294-295`, `:315-325`; `tools/test/doc.sh:64-74`, `:97-100`, `:109-125`
- checked:  2026-09-04
- owner:    none
- from:     GA-18

### LIM-15 the Python tier makes no classic-tool call

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    tools/ledger-lint/ledger-lint.py
- claim:    [[arcs/zero-python-arc]] treats the Python tier as tooling to be replaced, and enforcement requirement 5 counts its 4,786 lines in the 12,450 outside the language.
- measured: the count is right and the shape is different from the shell's. Nine `.py` files under `tools/` make **zero** invocations of a classic Unix tool. Every `subprocess` call is to `git` (`tools/ledger-lint/ledger-lint.py:1038`, `:1047`, `:1588`; `tools/frontier/frontier.py:254`) or to `sys.executable` re-entering a tool in this tree (`tools/doc/doc.py:204`; `tools/capture/capture.py:225`, `:444`). The classic-tool jobs are done in process: 172 `re` operations, 60 sorts, 15 directory walks and 9 `hashlib` uses, of which `ledger-lint.py` holds 87 regex operations and 27 sorts. None of it runs inside a gate, so this tier has no 1a and no 1b, and a per-tool port is the only shape available. Accepted as a measurement rather than a defect.
- evidence: `tools/ledger-lint/ledger-lint.py:1046`, `:1055`, `:1597`, `:2097` (every subprocess call is to git); `tools/frontier/frontier.py:250-254`; `tools/doc/doc.py:204`
- checked:  2026-09-05
- owner:    none
- from:     TC-10

### LIM-16 E20 ledger says built and the pipeline index says audited

- state:    accepted
- author:   unreviewed
- note:     none
- level:    element
- about:    E20
- claim:    docs/elements/ledger.md marks E20 `built`; docs/examples/INDEX.md marks it `audited`, awaiting implementation.
- measured: records/ledger-reconciliation.md measured the two cells as naming different things. There is no nb-blit and no mmap-to-mprotect code loader under lib/; lib/module/loader.chiral is the compiler's module loader by its own header and the name is a collision. The mmap/mprotect pair in compile-emit is E89/E91's arena reserve-commit, never a W-to-X transition, and the W^X half is not held: x64/elf.chiral:59-60 emits one RWX PT_LOAD. Naming the surviving element is an author call.
- evidence: records/ledger-reconciliation.md, lib/lowering/x64/elf.chiral:59-60
- checked:  2026-09-05
- owner:    none
- from:     none

### LIM-17 E26 ledger says built and the pipeline index says audited

- state:    accepted
- author:   unreviewed
- note:     none
- level:    element
- about:    E26
- claim:    docs/elements/ledger.md marks E26 `built`; docs/examples/INDEX.md marks it `audited`.
- measured: records/ledger-reconciliation.md qualified it PARTIAL 2026-09-04. The crossing half is real, halt declared at lib/ports/process.port:14, and the typed alarm is not built: E42 built the shape instead and names the typed alarm as residue, hard-gated on E39, which is still `design`.
- evidence: records/ledger-reconciliation.md, lib/ports/process.port:14
- checked:  2026-09-05
- owner:    none
- from:     none

### LIM-18 E101 ledger says built and the pipeline index says audited

- state:    accepted
- author:   unreviewed
- note:     none
- level:    element
- about:    E101
- claim:    docs/elements/ledger.md marks E101 `built`; docs/examples/INDEX.md marks it `audited`.
- measured: records/ledger-reconciliation.md measured a genuine PARTIAL on E26's precedent. The element's title names two files: lib/surface/sexp.chiral landed in full and lib/surface/parse.chiral did not, its p-err still carrying a bare string with no position.
- evidence: records/ledger-reconciliation.md, lib/surface/sexp.chiral:137
- checked:  2026-09-05
- owner:    none
- from:     none
