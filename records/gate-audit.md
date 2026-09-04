---
node: records-gate-audit
layer: navigation
related: [records/README, records/baseline-alignment, testing-floors, arcs/enforcement-arc, status-ledger, index]
status: current
updated: 2026-09-04
---

# Gate audit

Which gate rows cannot fail. `docs/definitions/testing-floors.md:287` states the
rule: a gate row must NAME a mutant that falsifies it, and the mutant must be
RUN. `docs/arcs/enforcement-arc.md` requirement 5 inherits it.

Row format, states and the rules for adding, changing and retiring a row are in
[[records/README]]. Prefix is `GA`.

Every row below was measured 2026-09-04 against `37e9443`, on a 3.85 GB box with
no swap, one compiler build at a time under `(ulimit -s unlimited)`. Each
`measured` field carries the command that produced it. A gate row absent from
this file was left untested, and this file says nothing about it.

This arc has no reserved element number block. A row needing an element carries
`UNASSIGNED`.

Scope of this pass: the five phase scripts `tools/test/mutant.sh:154` names, plus
the registration of the harness itself. The eight remaining registered phases
were left untested.

Scope of the second pass, GA-12 onward, measured 2026-09-04 against `706e69b`
with `lib/` and `tools/` clean in `git status`. It asks one question of each
mutant a phase script names: whether the mutant is EXECUTED, whether it changes
the file it names, and whether the row it claims to falsify is the row that
reddens. The third question was measured rather than read, by applying each
mutant to a scratch copy of the whole tree and re-running the phase there, so a
mutant block whose check paraphrases its row shows up as a disagreement.
`pretty.sh`, `face.sh` and `row.sh` were covered. `matcher.sh`, `render-doc.sh`,
`doc.sh` and `arity.sh` were left untested: twice during the pass the box stopped
being able to exec any dynamically linked binary, the loader reporting `cannot
close file descriptor: Error 24` while `/proc/sys/fs/file-nr` read 160 of 402840
and the shell held four descriptors. A run taken during such a window reports
every `sed` and every `sha256sum` as a failure and is discarded on sight. This
file says nothing about those four.

Scope of the third pass, GA-18 onward, measured 2026-09-04 against `be40dc0`
with `lib/` and `tools/` clean in `git status`. It covers the four the second
pass left untested, and its subject is the `mutant NAME WANT-VERDICT PATH SED`
idiom the five earlier scripts did not use. All four ran green in this session,
which is what makes each script's declared pin the measured red set:
`arity.sh` 13 passed, `doc.sh` 26, `matcher.sh` 18, `render-doc.sh` 19, zero
failed in each. The questions asked of each script were whether a mutant that
fails to build can wear a red row, whether the want-verdict is computed by the
function that emitted the base rows, and which rows no declared mutant reddens.

Scope of the repair pass, 2026-09-04, commits `ebec76a`, `d3ab4d3`, `3a71658`
and `f7caf96`. Five rows moved to FIXED: GA-13, GA-17, GA-19, GA-21 and GA-22,
the five whose defect is one shape, a gate row no mutant falsifies. Each gained
a mutant that reddens that row and nothing it was not pinned for, run in the
phase it belongs to. Four rows were left alone and are named here so the file
says why: GA-20 is a dedup rather than a hole, GA-23 is a fixture idiom whose
repair is a larger change, GA-24 is structural, and GA-03 is the profile gate.

## The instrument

### GA-01 the harness that audits the gates has no phase in the gate

- state:    OPEN
- claim:    `tools/test/mutant.sh:1-45` is the run-the-mutant rule made mechanical, and `docs/definitions/testing-floors.md:287` binds every gate row to a mutant that is RUN.
- measured: `grep -n '^run_phase' tools/test/run-tests.sh` returns thirteen dispatch lines (`:144-147`, `:216`, `:225`, `:236`, `:252`, `:268`, `:284`, `:303`, `:326`, `:345`) and none of them names `mutant.sh`. The only occurrence of the string in that file is a comment at `:292` pointing a different element at a different harness. So the matrix runs by hand or it runs never. Two SPECs already rest a gate on it: E52 re-founds the surviving half of its conformance gate on `mutant.sh` (`docs/elements/specs/E52-certificate-split-SPEC.md:255`, `:311`) and E173 cites `mutant_differs` (`docs/elements/specs/E173-total-matcher-SPEC.md:399-401`). Cost measured today: `bash tools/test/mutant.sh --matrix` completed in **3m00s** wall clock, control green, seven mutants built at about 7 s each. The suite's own budget already carries phases costing more.
- evidence: `tools/test/run-tests.sh:144-147`, `:292`, `:345`; `tools/test/mutant.sh:154`
- checked:  2026-09-04
- element:  UNASSIGNED

### GA-02 the declared matrix, re-run and reconciled

- state:    ACCEPTED
- claim:    `tools/test/mutant.sh:156-196` declares seven mutants, each with the rule it is expected to convict.
- measured: `bash tools/test/mutant.sh --matrix`, 2026-09-04, control green on all five phases before any mutation. All seven built, all seven differ from the base, all seven reach a self-hosting fixpoint. Every one is convicted by at least one phase, so no declared mutant is a live coverage hole today. The table, `RED` meaning the phase caught it:

  | mutant | check-cli | profile-target | linear-mint | syscall-manifest | diag |
  |---|---|---|---|---|---|
  | `qfits-q1-accepts-all` | RED | green | RED | green | RED |
  | `qfits-q0-accepts-all` | green | green | RED | green | RED |
  | `qjoin-q1-no-saturate` | green | green | RED | green | green |
  | `qjoin-q0-no-saturate` | green | green | RED | green | green |
  | `strip-binder-off` | RED | green | RED | green | RED |
  | `close-binder-off` | green | green | RED | green | RED |
  | `port-purity-off` | green | RED | green | green | green |

  `linear-mint.sh` carries six of the seven alone, and the two `qjoin` arms have it as their only convicting phase. `syscall-manifest.sh` is green on every row, which is correct: all seven mutate `lib/typing/` or `lib/surface/parse.chiral` and its subject is the syscall registry, covered by its own poisons (GA-06).
- evidence: `tools/test/mutant.sh:156-196`, `:198-223`
- checked:  2026-09-04
- element:  none

## Gates that cannot fail

### GA-03 the `(total)` profile gate is convicted by no phase in the suite

- state:    OPEN
- claim:    `profile-target.sh` gates the composition manifest, and four of its rows carry the `(total)` clause. `lib/lowering/compile-front.chiral:24` imports `typing/totality-check` for E11's profile gate, and `:340` calls `tot-gate` on the shipping path.
- measured: a new mutant, `total-clause-dead`, built through `mutant_build` against `lib/surface/parse.chiral:956` with the declared count 1: `(case (mf-find-clause cs "total") (none false) ((some x) true))` becomes the same form ending `false`. The `(total)` clause then parses, validates and stores a dead flag, so `tot-profile-demands` (`lib/typing/totality-check.chiral:134`) always answers false and `tot-gate` always returns `tot-proven`. Built at **1,188,216 B**, byte-differing from the base, self-hosting fixpoint **yes**. Semantic witness, so the mutant is demonstrably live: a file carrying `(profile P (ports) (target Svc) (total))` beside `(def loop (lam (n) (loop n)))` is REFUSED by the base with `profile (total): def loop not proven total: no argument position decreases ...` and is answered `OK` by the mutant. Scored against every phase `mutant.sh:154` names: `check-cli` green, `profile-target` green, `linear-mint` green, `syscall-manifest` green, `diag` green. **It survives all five.** Bounding the claim over the rest of the suite: `grep -lE 'profile|tot-gate|totality' tools/test/*.sh` names only `mutant.sh`, `doc.sh`, `matcher.sh`, `run-tests.sh`, `syscall-manifest.sh` and `profile-target.sh`, and `grep -l '(total)' tools/test/*.sh` names `profile-target.sh` alone. The one artifact in the tree declaring `(total)` outside `lib/` is `prog/demo/verify-total.chiral:25`, which defines no `compile-main`, so Phase 7's root sweep never compiles it, and its own header at `:6` still invokes `python3 -m chirality verify`.
- evidence: `lib/surface/parse.chiral:955-957`, `:985`; `lib/typing/totality-check.chiral:133-156`; `lib/lowering/compile-front.chiral:24`, `:340`; `tools/test/profile-target.sh:60-68`, `:98`; `prog/demo/verify-total.chiral:6`, `:25`
- checked:  2026-09-04
- element:  UNASSIGNED

### GA-04 profile-target.sh licenses one of its 31 rows

- state:    OPEN
- claim:    `tools/test/profile-target.sh:6-12` says the point of its cases is the REFUSALS, and that a parser accepting everything freezes nothing.
- measured: `bash tools/test/profile-target.sh` reports **31 passed, 0 failed** in 1.85 s. Nine rows are positive, twenty-two are refusals. The script declares zero mutants of its own: it has no `mutant`, `poison` or scratch-tree helper anywhere. One declared mutant in `mutant.sh` reaches it, `port-purity-off`, and running it turns exactly **one** row red, `port is PURE (does not cross)`, leaving 30 passed. So 30 of the 31 rows have no run falsifier anywhere in the tree, and GA-03 is one measured consequence.
- evidence: `tools/test/profile-target.sh:6-12`, `:57-121`; `tools/test/mutant.sh:192-195`
- checked:  2026-09-04
- element:  UNASSIGNED

### GA-05 check-cli.sh licenses two of its 7 rows

- state:    OPEN
- claim:    `tools/test/check-cli.sh:3-9` says the cases pin that `chirality check` accepts well-typed source and refuses ill-typed source, and that a checker only ever saying OK fails to be a checker.
- measured: `bash tools/test/check-cli.sh` reports **7 passed, 0 failed** in 0.64 s. Three positive rows, four refusals. Zero mutants declared in the script. Two declared mutants reach it: `strip-binder-off` turns `linear cap used twice` and `linear cap dropped` red (5 passed, 2 failed), and `qfits-q1-accepts-all` reddens the same pair. The remaining two refusals, `arity / type mismatch` and `unknown name`, carry no run falsifier, and neither do the three positive rows. `records/baseline-alignment.md` BA-04 already holds the separate finding that all four refusals are front-end and none reaches a lowering or emit refusal; this row is about the falsifier rather than the stage.
- evidence: `tools/test/check-cli.sh:3-9`, `:41-60`; `records/baseline-alignment.md` BA-04
- checked:  2026-09-04
- element:  UNASSIGNED

### GA-06 syscall-manifest.sh honours the rule in its own idiom

- state:    ACCEPTED
- claim:    a pre-dispatch grep scored this script at 0 gate rows and 0 mutants.
- measured: both halves of that count are wrong, and the correction belongs here because it changes where the hole is. `bash tools/test/syscall-manifest.sh` reports **12 passed, 0 failed**. Its assertion helpers are `prof` (`tools/test/syscall-manifest.sh:49`) and `poison` (`tools/test/syscall-manifest.sh:79`), which a grep for `check` or `ok` misses. `poison` is a mutant harness built into the phase: it seds the compiler's own blob, rebuilds a compiler from the poisoned stream, and asserts the rebuilt compiler refuses to emit. Four call sites at `tools/test/syscall-manifest.sh:113`, `:115`, `:118`, `:121`, of which the first is the positive control (`p;d`, the clean blob still compiles) and three are real mutants of the registry rows in `lib/lowering/tal/target-linux.manifest:23`, reached through the compiler's own blob. The harness closes three of `mutant.sh`'s four silent failures independently: `cmp -s` against the base blob refuses a poison that matched nothing (`tools/test/syscall-manifest.sh:83-85`), a build failure is reported as its own FAIL (`tools/test/syscall-manifest.sh:86-89`), and the control row runs first. It carries no equivalent of `mutant_differs` at the binary level, and the blob `cmp` stands in for it at the source level.
- evidence: `tools/test/syscall-manifest.sh:49`, `:79-101`, `:113-123`
- checked:  2026-09-04
- element:  none

### GA-07 linear-mint.sh's rows name a mutant only an unregistered harness runs

- state:    OPEN
- claim:    `tools/test/linear-mint.sh:248-251` records that a mutant SURVIVED ALL FIVE PHASE SCRIPTS, that these rows are the re-founding, and that the run which produced them is what says they are needed. `:253-259` names two `qjoin` mutants and the measured 2x2 diagonal. `:330-333` names `qfits-q0-accepts-all`.
- measured: `bash tools/test/linear-mint.sh` reports **32 passed, 0 failed**, the largest row count of the five phases audited. The script declares zero mutants of its own: `grep -cE '^\s*mutant' tools/test/linear-mint.sh` returns 0 and it defines no scratch-tree helper. Every falsifier its comments cite lives in `tools/test/mutant.sh:156-196`, which GA-01 measures as reachable by no `run_phase` line. Re-running the matrix reproduces the cited diagonal exactly: `qjoin-q1-no-saturate` and `qjoin-q0-no-saturate` each turn `linear-mint` red and leave the other four phases green. So the rows are genuinely falsifiable and the falsification is genuinely outside the gate. Fixing GA-01 fixes this row.
- evidence: `tools/test/linear-mint.sh:248-271`, `:326-334`; `tools/test/mutant.sh:156-196`
- checked:  2026-09-04
- element:  UNASSIGNED

### GA-08 the profile's memory discipline is stored and read nowhere

- state:    OPEN
- claim:    `tools/test/profile-target.sh:8` documents the manifest form as `(profile name (ports p...) (target t) [(memory d)] [(total)])` and four of its rows exercise `(memory ...)`: two positives, `unknown memory discipline gc`, and `malformed (memory)`.
- measured: `grep -rn 'mk-profile' lib/ prog/ --include=*.chiral` finds one constructor site (`lib/surface/parse.chiral:984`) and three destructurings. `lib/typing/totality-check.chiral:134` reads the `to` field, `lib/lowering/compile-front.chiral:272` reads the `po` field, `lib/typing/kernel.chiral:260` reads `pn` for the redeclare lookup. The `me` field is read by nothing after `handle-profile-body` validates it, and so is `tg`. The four `(memory ...)` rows therefore assert a parse message over a value the compiler discards, and no mutant of the discipline's meaning can exist while nothing consumes it. Recorded as a zero in the shape `docs/definitions/testing-floors.md` uses for E170 lane E: a field with no reader is a gate row quantified over an empty set of consumers.
- evidence: `lib/surface/parse.chiral:938-953`, `:984`; `lib/typing/kernel.chiral:260`; `lib/lowering/compile-front.chiral:272`; `lib/typing/totality-check.chiral:134`
- checked:  2026-09-04
- element:  UNASSIGNED

## The method

### GA-09 size and the fixpoint carry no signal, re-measured

- state:    ACCEPTED
- claim:    `tools/test/mutant.sh:34-41` records, measured 2026-08-31, that five semantic mutants of the QTT usage audit each produced a compiler of exactly 1,098,104 B and four reached a byte-identical self-hosting fixpoint.
- measured: reproduced today at a new base size. `bin/chirality-bin` is 1,188,216 B. All seven declared mutants and the new `total-clause-dead` built at **exactly 1,188,216 B**, and **all eight** reached a self-hosting fixpoint under `mutant_fixpoints`. Eight for eight, including a compiler with the lam binder usage audit disabled and a compiler with the E11 totality gate disabled. Reading a survival off a size or off a fixpoint would have scored every one of them correct.
- evidence: `tools/test/mutant.sh:34-41`, `:125`, `:142-147`
- checked:  2026-09-04
- element:  none

### GA-10 four phase scripts have no dispatch line

- state:    OPEN
- claim:    `docs/definitions/testing-floors.md:69` records `tools/test/tal-check.sh` as unregistered in `run-tests.sh` by decision, on the `crypto.sh` precedent, so the suite's 339 excludes it.
- measured: `ls tools/test/*.sh` lists eighteen scripts and `run-tests.sh` dispatches thirteen. The five outside the dispatch are `run-tests.sh` itself, `crypto.sh`, `tal-check.sh`, `map-integrity.sh` and `mutant.sh`. Two of the four carry a written decision (`crypto.sh`, `tal-check.sh`). `map-integrity.sh` is reached by a separate route: `docs/goals/self-hosting.md:58` names it beside `bin/chirality test` as a thing a person runs, and `records/baseline-alignment.md` BA-01 is its own row. `mutant.sh` carries no decision anywhere in `docs/`, and GA-01 is that gap. Assertion counts for the unregistered pair audited here: `crypto.sh` and `tal-check.sh` were left unmeasured by this pass.
- evidence: `tools/test/run-tests.sh:144-147`, `:345`; `docs/definitions/testing-floors.md:69`; `docs/goals/self-hosting.md:58`
- checked:  2026-09-04
- element:  UNASSIGNED

### GA-11 mutant.sh's header count of five disagrees with its own parenthetical

- state:    OPEN
- claim:    `tools/test/mutant.sh:5-9` reads that every phase script honouring the rule re-implemented it, that `diag.sh` does so at the fixture level, and that "the five phases that did not honour it" were indistinguishable from the ones that did.
- measured: `git log --diff-filter=A -- tools/test/mutant.sh` puts the file at `58f4f7c`, where `run-tests.sh` dispatched exactly five sub-scripts: `check-cli`, `profile-target`, `syscall-manifest`, `linear-mint` and `diag`. `MUT_PHASES` (`:154`) is that same list, and it needs `diag.sh` as a positive control. The set of sub-script phases that did NOT honour the rule at that commit is four, since the same sentence exempts `diag.sh`, and GA-06 removes `syscall-manifest.sh` from it as well, leaving three. Today the suite dispatches thirteen phases and the count has moved again. The number in the header is a snapshot with no date beside it, which is the shape `docs/definitions/testing-floors.md` calls a figure that rots.
- evidence: `tools/test/mutant.sh:5-9`, `:154`; `tools/test/run-tests.sh:144-147`
- checked:  2026-09-04
- element:  UNASSIGNED

## Gates that do fail, measured

### GA-12 pretty.sh runs all seventeen of the mutants it names

- state:    ACCEPTED
- claim:    `tools/test/pretty.sh:22-38` maps thirteen gate rows G1 to G13 onto seventeen mutants M1 to M17, and every one of the seventeen is named in a row heading.
- measured: `bash tools/test/pretty.sh` reports **61 passed, 0 failed** in 6.4 s. The pre-dispatch grep predicted ~51 rows and 17 mutants; the mutant count is right and the row count is 61, of which 17 are mutant rows and 44 are gate rows. All seventeen mutants are EXECUTED. Fourteen go through `mutlib` (`tools/test/pretty.sh:103-117`), which copies `lib/` to scratch, refuses a symlinked scratch tree, and `cmp`s the mutated file against the tree so a stale anchor is reported as a FAIL instead of reading as a pass; three are inline (M10 over the eight sha256 pins, M11 over the registration grep, M14 over the cross-assertion scan). All seventeen changed the file they name. Sixteen redden a row the header attributes to them, measured by copying the whole tree to scratch, applying the mutant's own `sed` to that copy's `lib/`, and re-running the phase against it: M2 turns G2 red (and thirteen G1 goldens with it), M3 turns G3's width-40 row red, M4 turns G3's width-12 row red, M5 turns G4 red, M6 turns G5 red, M7 turns G6 red, M8 turns G7 red, M16 turns G11b red. M9, M12, M13, M15 and M17 convict compositionally: each re-runs the row's own predicate (`census` at `:473`, `closure` at `:552`, `code_only` at `:501`, `build_err` at `:89`) over the mutated tree, so the conviction is the gate row's own comparison with one input changed. M1 is GA-13.
- evidence: `tools/test/pretty.sh:22-38`, `:89-94`, `:103-117`, `:199`, `:222`, `:250`, `:259`, `:275`, `:294`, `:311`, `:330`, `:399`, `:410`, `:414`, `:432`, `:439`, `:464`, `:486`, `:505`, `:573`
- checked:  2026-09-04
- element:  none

### GA-13 pretty.sh's M1 reddens the build, and eight of G1's goldens have no falsifier

- state:    FIXED
- claim:    `tools/test/pretty.sh:22-23` attributes G1, *"all sixteen formers byte-exact at width 10^6, plus KArm, RfAtom and the dc-ty site -- twenty goldens"*, to M1, and `:45` says coverage is asserted by ARM DELETION, one arm at a time.
- measured: G1 emits **twenty-one** goldens where the header says twenty. M1 deletes ONE arm, once, `t-lit-i`'s (`tools/test/pretty.sh:199`), so *one arm at a time* is a description of a loop the script does not run. Applied to the tree the fixture stops compiling with `load: non-exhaustive case`, the phase aborts at its first row, and the run reports **0 passed, 2 failed**. So what M1 falsifies is the fixture's build, which the compiler's exhaustiveness check on `Term` already forces: the same header at `:40-45` records that a seventeenth constructor reddens `prog/compiler.prog` on the un-E181'd tree for that reason and calls such a row false. No G1 golden moves under M1. Taking the union over every mutant that does move one (M2, M3, M5, M6, M7, M8), thirteen of the twenty-one goldens have a run falsifier. The eight that have none anywhere in the script are `w6-08` (`f`), `w6-09` (`str-cat`), `w6-10` (`I64`), `w6-11` (`42`), `w6-12` (the escaped string), `w6-13` (`Nil`), `w6-15` (`Unit`) and `w6-20` (`declared type I64`): the atom and leaf formers. `w6-11` is the golden of the very arm M1 deletes, so the one former the coverage claim is written about is a former whose printed bytes nothing here can falsify. **FIXED in `3a71658`.** `pretty.sh` gains M18-M25, one per leaf former, each changing what that former prints and compiling clean: M18 `t-global`, M19 `t-prim`, M20 `t-primty`, M21 `t-lit-i` one too high, M22 `t-lit-s` unquoted, M23 the nullary ctor, M24 the nullary tcon, M25 the `dc-ty` site in `typing/diag`. Each pins the FULL set of goldens it moves, because `I64` is a `t-primty` inside six other goldens and `42` a `t-lit-i` inside six more: M18 `[w6-05 w6-08 w6-19]`, M19 `[w6-09]`, M20 `[w6-03 w6-04 w6-07 w6-10 w6-16 w6-18 w6-20]`, M21 `[w6-06 w6-07 w6-11 w6-14 w6-17 w6-18 w6-22]`, M22 `[w6-12]`, M23 `[w6-13]`, M24 `[w6-15]`, M25 `[w6-20]`. All eight of the goldens named above are in that union. `expect` now records label and golden as it grades and `g1_reds` reads that record, so the mutants compare against the value the base row compared against; `BUILD:fail` is the token for a mutant that did not compile and no pin holds it. Measured: `bash tools/test/pretty.sh` -> **69 passed, 0 failed** in 12.9 s, was 61.
- evidence: `tools/test/pretty.sh:22-23`, `:40-45`, `:143-152`, `:197-205`, `:215-235`, `:237-258`, `:260-301`
- checked:  2026-09-04
- element:  none

### GA-14 face.sh honours the rule on all thirteen

- state:    ACCEPTED
- claim:    `tools/test/face.sh:56` reads that EVERY ROW CARRIES A NAMED MUTANT THAT IS RUN, and `:50-53` that the thirteenth mutant exists because G7(c)'s arity scan was the one row here nothing could redden.
- measured: `bash tools/test/face.sh` reports **38 passed, 0 failed** in 2.5 s. The pre-dispatch grep predicted ~40 rows and 13 mutants; the mutant count is right and the row count is 38, of which 19 are mutant rows over 13 distinct mutants and 19 are gate rows. All thirteen are EXECUTED: nine through `mutlib` (`:133`), which carries the same scratch-tree and `cmp` guards as `pretty.sh`, and four inline (M8 over the five sha256 pins, M9 over the four registrations, M12 a declared seven-argument caller, M13 the arity scanner over a probe file). All thirteen changed what they name. Every one reddens the row the header attributes to it, measured the same way as GA-12 by re-running the whole phase against a mutated scratch tree: M1 turns G1 and G5 red, M2 turns G1 red, M3 turns G2 and G3 red, M4 and M5 each turn G4 red, M6 turns G4(b) red while leaving G4(a) byte-identical, which is exactly what `:475-477` predicts and the stated reason shape (b) exists at all; M7 turns G6 red and nothing else, the cell map staying put, which is the stated reason G6 is a raw-byte row; M10 and M11 break the G8 compiles. M8, M9 and M13 convict compositionally by re-running the row's own function (`sha_of`/`pin` at `:547-548`, `reg` at `:579`, `ARITY_AWK` through `arity_scan` at `:615`) over a changed input. Two rows carry no mutant and both are labelled controls: the fixture-builds row and G8's own control. This script is the shape the rule asks for.
- evidence: `tools/test/face.sh:36-61`, `:133-147`, `:354`, `:370`, `:401`, `:449`, `:462`, `:478`, `:519`, `:547-568`, `:579-591`, `:615-641`, `:658`, `:671`, `:699`
- checked:  2026-09-04
- element:  none

### GA-15 the idiom that makes a mutant row convict its own gate row

- state:    ACCEPTED
- claim:    `docs/definitions/testing-floors.md:287` binds a gate row to a mutant that is RUN, and `tools/test/mutant.sh:26-30` names the third silent failure: the mutant reddens some other row, or reddens nothing while the script still reports it as convicting.
- measured: the three scripts audited here close that failure by a shape worth naming, because it is what separates them from the five phases GA-03 to GA-08 found holes in. A mutant row either re-runs the gate row's own function over a mutated input (`census`, `closure`, `pin_check`, `sha_of`, `reg`, `screen`, `cell_sgr`, `ARITY_AWK`) or compares the same expression at the same coordinates against a different expected value. `tools/test/row.sh:517-526` carries the strongest form of it, `g4_mutant`, which re-runs `g4_report` over the mutated tree and asserts by NAME which constructor row went red, so a mutant reddening some other row is reported as a FAIL by the script itself. Where a mutant block instead paraphrases the row, the paraphrase can drift from the row and GA-13 is that drift measured. The whole-tree re-run is what tells the two apart, and it costs one `cp` and one phase run: 6.4 s for `pretty.sh`, 2.5 s for `face.sh`.
- evidence: `tools/test/mutant.sh:26-30`; `tools/test/pretty.sh:473`, `:501`, `:552`; `tools/test/face.sh:547-548`, `:579`, `:615`; `tools/test/row.sh:517-526`
- checked:  2026-09-04
- element:  none

### GA-16 row.sh runs all thirteen, and `g4_mutant` names the row it reddens

- state:    ACCEPTED
- claim:    `tools/test/row.sh:20-22` reads that every row that matters renders through `render-to-ansi` and READS THE EMITTED BYTE STREAM, and that every row carries a named mutant that is RUN. `:24-35` maps eight gate rows G1 to G8 onto thirteen mutants.
- measured: `bash tools/test/row.sh` reports **41 passed, 0 failed**. The pre-dispatch grep predicted ~28 rows and 13 mutants; the mutant count is right and the row count is 41, of which 16 are mutant rows over 13 distinct mutants and 25 are gate rows. All thirteen are EXECUTED and all thirteen change the file they name, `mutlib` (`:125-136`) carrying the `cmp` guard that reports a stale anchor as a FAIL. Its `mutlib` omits the scratch-tree symlink check `pretty.sh:106-108` and `face.sh:136-138` both carry. Six of them go through `g4_mutant` (`:517-526`), which is the strongest form of the rule found in this pass: it re-runs `g4_report`, the same function that emitted the base rows, and asserts by NAME which constructor row went red. Measured red lists, one row each: M2 `r-stream`, M3 `r-face`, M11 `r-tree`, M4 `r-row`, M13 `r-table`, M10 `r-section`. The other seven convict by re-running the row's own predicate over a changed input (`census`, `sha_of` against the pin, `reg`, `g3_map`, `build_run`, `build_err`), and three of those were confirmed against the whole tree by copying the repository to scratch, applying the mutant's `sed` to that copy's `lib/`, and re-running the phase: M1 turns G3's cell map red, M6 turns G1's `apc.chiral` row red with `load: non-exhaustive case`, M7 turns G2 red at case 9, which is the case its own row names.
- evidence: `tools/test/row.sh:20-35`, `:125-136`, `:361`, `:385`, `:418`, `:517-526`, `:531-556`, `:597-607`, `:622-630`, `:655-668`, `:683-689`, `:730-734`, `:752-757`
- checked:  2026-09-04
- element:  none

### GA-17 row.sh's `r-hole` width row is falsified by nothing

- state:    FIXED
- claim:    `tools/test/row.sh:548-552` says M13 was added beyond the SPEC's twelve because *"without it the r-table row is the one row in G4 with NO mutant, and a row nothing can redden is a row that exercises nothing"*.
- measured: G4 emits **nine** constructor rows and the six `g4_mutant` calls redden six of them, one each. The three left over are `r-text`, `r-lines` and `r-hole`. M1 covers the first two as collateral, which `:414-417` records in as many words and which the whole-tree run confirms: under M1 the red set is `r-text r-face r-lines r-row r-tree r-section`. `r-hole` appears in no red set anywhere in the script. It holds no `r-text`, so M1's off-by-one never reaches it; the other twelve mutants touch other arms or other files. So the sentence at `:548-552` is true of `r-hole` today, by its own wording, and the mutant that would answer it was never written. This is the same shape as GA-13 one script over: the reasoning that mints a mutant is present and correct, and the enumeration it is applied to stops one row short. **FIXED in `f7caf96`.** `row.sh` gains M14, which drops `rnd-hole-mark` from the WIDTH arm of `rnd-cols` and leaves the emitter painting it, so the two disagree by the mark's three columns and G4's (a) and (c) both fail for that constructor. Measured red set: `r-hole` alone. Not a mutation of `rnd-hole-mark` itself, which both readers take and which therefore moves them together and reddens nothing. Measured: `bash tools/test/row.sh` -> **42 passed, 0 failed**, was 41.
- evidence: `tools/test/row.sh:29`, `:38-42`, `:414-417`, `:455`, `:531-556`, `:548-552`, `:558-573`
- checked:  2026-09-04
- element:  none

## The `mutant NAME WANT-VERDICT PATH SED` idiom

### GA-18 the full-line pin closes all four silent failures, and the entry-point hazard with them

- state:    ACCEPTED
- claim:    `tools/test/arity.sh:75-79` reads that a build which did not happen scores `nobuild` and never `bad`, and that no pinned line below ever expects that token, so a mutant that merely fails to compile cannot wear a red row and be read as a conviction. `tools/test/mutant.sh:19-40` names the four ways the measurement fails silently, and this idiom is a second implementation of the same rule.
- measured: all four scripts ran green in this session: `arity.sh` **13 passed, 0 failed** in 12 s, `doc.sh` **26 passed, 0 failed**, `matcher.sh` **18 passed, 0 failed**, `render-doc.sh` **19 passed, 0 failed**. A green phase is what makes each declared pin the measured red set, and every row below reads off that. The idiom closes all four failures, three of them by an assertion and the fourth by the pin itself. (1) A mutation that matched nothing is refused by `cmp -s` against the tree under test, in every copy of `mutlib` (`arity.sh:161-163`, `matcher.sh:161-163`, `render-doc.sh:145-147`) and inline in `doc.sh:119-121`. (2) A mutant that did not build produces a token no pin holds: `verdict` scores `nobuild` per row group (`arity.sh:275`, `:283`, `:290`) or collapses the whole line to `BUILD:fail` (`matcher.sh:229`, `render-doc.sh:247`), and `doc.sh`'s `build_run` returns 255 (`doc.sh:64-74`). Read against every pin in the four files, five in `arity.sh` (`:361`, `:371`, `:382`, `:393`, `:402`), nine in `matcher.sh` (`:314-384`), seven in `render-doc.sh` (`:332-392`) and five case numbers 1, 3, 4, 8 and 14 in `doc.sh` (`:127`, `:131`, `:136`, `:190`, `:196`), no want string carries `nobuild`, `BUILD:fail` or 255. So the entry-point hazard is closed by string equality rather than by care, and a mutant that fails to build is reported as a FAIL of its own row. (3) A semantically inert mutant produces an all-`ok` line, which no pin holds either. (4) A red base is caught first: each script asserts `verdict "$REPO/lib"` equals `ALLOK` before any mutation (`arity.sh:300-301`, `matcher.sh:266-267`, `render-doc.sh:294-295`), and `doc.sh` runs its fixture over the real tree at `:97-100`. The want-verdict is computed by the function that emitted the base rows in all four: `verdict` takes the library directory as its only argument (`arity.sh:270`, `matcher.sh:227`, `render-doc.sh:245`) and `doc.sh` calls one `build_run` over one fixture for both legs (`:66`, `:97`, `:122`). Nothing is re-derived anywhere a mutation cannot reach.
- evidence: `tools/test/arity.sh:75-79`, `:152-165`, `:270-293`, `:300-301`, `:325-334`; `tools/test/matcher.sh:146-160`, `:227-260`, `:266-267`, `:297-307`; `tools/test/render-doc.sh:131-145`, `:245-288`, `:294-295`, `:315-325`; `tools/test/doc.sh:64-74`, `:97-100`, `:109-125`
- checked:  2026-09-04
- element:  none

### GA-19 arity.sh's ten-tag golden is falsified by nothing, and M1 falsifies the compile

- state:    FIXED
- claim:    `tools/test/arity.sh:59` lists `G1 the tenth tag, over all ten Reason arms [M1]`, and `:251` holds the golden `redeclared,mismatch,usage,linear,arrow,unbound,skipped,judged,relayed,arity,`.
- measured: G1 reads `ok` in the base line and in all five pinned verdict lines (`:361`, `:371`, `:382`, `:393`, `:402`), so no mutant in the script moves it. M1 is graded beside the line rather than inside it (`:337-352`): it deletes the `r-arity` arm from `dg-reason-tag`, the module then stops compiling, and the row asserts the refusal text `load: non-exhaustive case`, which the run reproduced. That refusal is the compiler's exhaustiveness check on `Reason` doing the work, and it holds for any deleted arm of any sum. The header at `:341-343` states the trade and calls the result the eight-renderer property as a checked row. What it leaves unsaid is the consequence: the ten tag STRINGS then have no falsifier anywhere in the script. A mutant renaming one arm's tag, `"arity"` to anything else, would redden G1 and compile clean, and no such mutant is declared. Same shape as GA-13, where `pretty.sh` M1's arm deletion reddens the build and leaves eight goldens standing. **FIXED in `ebec76a`.** `arity.sh` gains M9, which renames one tag string at a time inside `dg-reason-tag`'s `case` and compiles clean. The `arity` arm carries the FULL verdict line, pinned `G1:bad G2:ok G3:ok G4:ok G5:ok G6:ok`, so collateral on G2-G6 is caught the way every other mutant here catches it; the other nine call `g1_verdict`, the function `verdict` itself calls, over a mutated tree, and the reddened count is asserted at 9 so a loop that never ran is a FAIL. `g1_verdict` was extracted for that reason: a want re-derived beside the loop is a want the mutation cannot reach. `nobuild` is not `bad`, so a rename that stopped compiling is a FAIL of the row. Measured: `bash tools/test/arity.sh` -> **15 passed, 0 failed**, was 13; base line `G1:ok`, M9/arity's pin `G1:bad`, the nine-loop 9 of 9.
- evidence: `tools/test/arity.sh:59`, `:232-234`, `:251`, `:270-281`, `:337-352`, `:418-459`
- checked:  2026-09-04
- element:  none

### GA-20 arity.sh's G3 is G2's predicate written a second time

- state:    OPEN
- claim:    `tools/test/arity.sh:60-61` lists G2 and G3 as separate rows, and `:240-244` says G3 reads the same two sentences for their noun alone, extracted with the rest of each sentence ANCHORED, so one arm serving a type-parameter site and a constructor-argument site is graded on the only thing that differs.
- measured: the two rows carry one predicate. G2 holds iff `a` equals `G2A_WANT` and `b` equals `G2B_WANT` (`:279`). G3's two extractors anchor the whole sentence as a literal around a single capture (`:267-268`) and the pair is compared against `arguments|type parameters` (`:254`), which holds iff the capture is `arguments` and `type parameters`, which holds iff `a` and `b` are those same two strings. Run over fifteen pairs built from the true sentence, a moved count, a moved noun, an empty field and a trailing suffix crossed with three data sentences, G2 and G3 agreed on all fifteen. The pins agree from the other side: G2 and G3 are `bad` together under M2 (`:361`) and under M3 (`:371`) and are never apart in any pin. So the verdict line names six rows and carries five predicates, and no mutant can ever separate G3 from G2. The anchoring the comment describes is what makes them identical rather than what makes them different.
- evidence: `tools/test/arity.sh:60-61`, `:240-244`, `:254`, `:267-268`, `:279-280`, `:361`, `:371`
- checked:  2026-09-04
- element:  UNASSIGNED

### GA-21 matcher.sh: three of eleven verdict rows are reddened by nothing

- state:    FIXED
- claim:    `tools/test/matcher.sh:25-27` reads that every mutant pins the full verdict line, so a mutant reddening a row outside its own pin is impossible to miss. The row table at `:41-55` names a mutant beside each row.
- measured: the nine mutants pin eleven tokens each, and the union of the rows they redden is G1 (M6), G2 (M1, M8), G3 (M2, M12), G4 (M2, M12), G6a (M2, M5, M12), G6c (M9), G6d (M4) and G7c (M7). G6b, G7a and G7b read `ok` in all nine pins and in `ALLOK` (`:261`). The table is honest about two of the three: G7a and G7b carry `[-]` (`:49-50`). G6b carries `[M4-adjacent]` (`:46`) and M4's own pin reads `G6b:ok` (`:332`), so the one row whose attribution is not `[-]` is a row that mutant leaves green. G7a and G7b are the fence property, that a fenced block is skipped, asserted differentially against awk and against the hand-derived `100010001`. The nearest cover is G5, whose written fixture carries a fenced block holding an em-dash that would score if the fence leaked (`:451-467`), so a fence regression would move G5's differential; no declared mutant aims at it either, and M11 moves a needle inside a check rather than the fence toggle. G6b, leftmost-longest over overlapping alternatives, has no cover at all: M4 reaches `find-at` and G6b reads `find-all`. **FIXED in `d3ab4d3`.** `matcher.sh` gains M13 and M14. M13 narrows `scan-go`'s tie test from `<=i` to `<i`, so a second accept from the same start no longer displaces the first and `alt("ab","abc")` over `"xabc"` answers 1-3; measured against the base fixture, field 6 is the only field that moves, so the pin is `G6b:bad` and ten `ok`. M4 is the same property one function over, in `run-from`, which `find-all` never calls, and the table now says `[M13]` instead of `[M4-adjacent]`. M14 stops `line-step`'s `ls-fence` arm flipping back to `ls-prose`, so the first toggler swallows the file and the bitmap reads `100000000` for nine lines that mean `100010001`; field 10 is the only field that moves and both G7a and G7b read it, G7a against awk's toggle over the printed bytes and G7b against the constant. Measured: `bash tools/test/matcher.sh` -> **20 passed, 0 failed** in 8.8 s, was 18.
- evidence: `tools/test/matcher.sh:25-27`, `:41-55`, `:246`, `:249-253`, `:261`, `:314-384`, `:388-400`, `:402-415`
- checked:  2026-09-04
- element:  none

### GA-22 render-doc.sh's G1f sits inside a group both its named mutants leave green

- state:    FIXED
- claim:    `tools/test/render-doc.sh:53-54` lists `G1 a-f the text survives the conversion, 5 pairs + the proof that the widths actually differ [M1,M2]`, and `:46-49` reads that every mutant pins the full verdict line because a mutant reddening a row outside its own pin is the shape that produced nine toothless rows in this arc.
- measured: G1f is the `ne` at `:262`, the assertion that the two widths took different layout decisions. It reads `ok` in all seven pins (`:332`, `:341`, `:350`, `:360`, `:371`, `:381`, `:392`), M1's and M2's included. Both mutate `lib/protocol/render-doc.chiral`, and G1f compares two fields that come from `doc->str`, which is Phase 14's and which no mutant in this file touches. So the `[M1,M2]` attribution covers G1a to G1e and stops one letter short. The two rows this script declares unfalsifiable, G0 and G0p, carry `[-]` (`:51-52`) and are controls of the kind GA-14 accepted: G0p is the layout pin the rest of the gate is written against, and it is the row that would catch a `doc->str` that moved. G1f is the same kind of row carrying a mutant attribution instead. This is the only hole found in `render-doc.sh`, and every other row in its fifteen is reddened by a named mutant that ran. **FIXED in `f7caf96`.** `render-doc.sh` gains M13, which makes `doc-fits` answer false on an exhausted worklist so no group ever flattens and width 1000 lays out exactly as width 8, collapsing fields 1 and 3 into one string. Pinned in full: `G1f:bad G2c:bad` and thirteen `ok`. G2c is the collateral and it is the same fact read off the tag tree, the width-1000 face list picking up a second `error` for the row the break creates. `lib/prelude/doc.chiral` is already this file's mutation target at M10, and the row grades this gate's own FIXTURE rather than Phase 14's law: that the document being compared is one the width can move. Measured: `bash tools/test/render-doc.sh` -> **20 passed, 0 failed**, was 19. ⚑ THE PIN CASCADE was taken in full in the same commit: `row.sh` is pinned by `render-doc.sh:497` and `pretty.sh:371`, `render-doc.sh` by `pretty.sh:373`, and `pretty.sh` by nothing, so the chain terminates in one pass. Both moved pins were re-taken in the commit that moves the file. `face.sh:537-539` does not pin `row.sh`, by its own statement.
- evidence: `tools/test/render-doc.sh:46-49`, `:51-55`, `:256`, `:262`, `:289`, `:332-392`, `:396-414`, `:469-500`
- checked:  2026-09-04
- element:  none

### GA-23 doc.sh keeps the fixture idiom the other three were upgraded away from

- state:    OPEN
- claim:    `tools/test/doc.sh:18-20` reads that every row that matters carries a NAMED MUTANT and that a row whose mutant also passes exercises nothing. Its table at `:23-30` maps eight gate rows onto seven mutants. `tools/test/arity.sh:27-31` records the upgrade this arc paid for and adopted verbatim: the fixture asserts nothing and always exits 0, because a fixture that grades itself can be wrong twice in the same direction, and one that exits at its first failure masks every later row from every mutant.
- measured: `samples/e158_doc.prog` is the pre-upgrade shape on both counts. It grades itself with `dt-first-bad` (`:46-53`) over fourteen cases and returns the 1-based number of the FIRST failing case (`:39`, `:143-199`). The five fixture mutants pin cases 1, 3, 4, 8 and 14 (`doc.sh:127`, `:131`, `:136`, `:190`, `:196`). Nine of the fourteen cases carry no mutant: 2, 5, 6, 7, 9, 10, 11, 12 and 13. Eight of those nine are G3's evidence arms, the element's own row, so of the nine `Reason` arms the fixture walks only case 8's `r-usage` has a falsifier; the ninth arm is asserted outside the fixture with M9 (`doc.sh:247-277`). `doc.sh:139-141` states the masking in its own words and works around it for one row by writing a standalone `g2only.prog` probe carrying the G2 assertion alone. Two further zeros measured in the same pass. Case 5 asserts `data redeclared: Box` and `Box` on the same string (`samples/e158_doc.prog:163`), and the second needle is a substring of the first, so that half of the row holds for free. G5(b), `Doc has exactly 6 constructors` (`doc.sh:308-310`), is never run against a mutated tree even though M5's own substitution produces one: applying M5's sed (`:336`) to a scratch `lib/` and running `doc_ctors` over the result reads seven arms, `d-text d-cat d-line d-nest d-group d-tag d-fill`, which M5 never asks about, since it asserts the compile refusal instead (`:344-346`). `arity.sh`'s M7 is the same census row done the other way, running `judg_arms` over the mutated tree and requiring the count to move to 37 (`arity.sh:451-460`). The rows named here still redden on a real regression, because the base leg runs over the real tree; what none of them has is evidence that it is sensitive at all.
- evidence: `tools/test/doc.sh:18-30`, `:97-100`, `:109-125`, `:127`, `:131`, `:136`, `:139-141`, `:190`, `:196`, `:308-310`, `:333-346`; `tools/test/samples/e158_doc.prog:39`, `:46-53`, `:143-199`, `:163`; `tools/test/arity.sh:27-31`, `:451-460`
- checked:  2026-09-04
- element:  UNASSIGNED

### GA-24 a registration row that names its own phase cannot fire, and six phases are witnessed by nothing

- state:    OPEN
- claim:    `tools/test/doc.sh:466`, `tools/test/arity.sh:471` and `tools/test/pretty.sh:403-407` each read that an unregistered gate is a gate that never runs, and each asserts the `run_phase` line of the script it is written in.
- measured: `run-tests.sh` dispatches thirteen phases (`:144-147`, `:216`, `:225`, `:236`, `:252`, `:268`, `:284`, `:303`, `:326`, `:345`). Grepping the tree for a check on each number: 13 and 14 are asserted by three scripts each (`doc.sh:464-466`, `row.sh:686-687`, `face.sh:588-589`), 15 by two (`row.sh:687`, `face.sh:589`), 16 by one besides itself (`face.sh:589`). Phase 17 is asserted only inside `render-doc.sh`, 18 only inside `pretty.sh` (`:404-407`), 24 only inside `arity.sh` (`:470`). Phases 3, 4, 5, 6, 19 and 20 are asserted nowhere: outside `run-tests.sh` the string `run_phase 19` occurs only in `docs/`. A row asserting its own registration is circular, because deleting the `run_phase` line stops the script that holds the row from running. So `matcher.sh`, one of the four subjects here, can be dropped from the suite with nothing anywhere going red, and `arity.sh` and `render-doc.sh` can each be dropped with only their own row noticing, which by then it cannot. `matcher.sh` is also covered by no sha256 pin: `pretty.sh:366-373` pins five gate scripts and three fixtures, and `matcher.sh`, `arity.sh` and `transport.sh` are outside that set. This is GA-01 and GA-10 one layer in: those rows are about a harness nothing dispatches, this one is about a dispatch line nothing checks.
- evidence: `tools/test/run-tests.sh:144-147`, `:303`, `:326`, `:345`; `tools/test/doc.sh:462-473`; `tools/test/arity.sh:465-477`; `tools/test/pretty.sh:366-373`, `:403-411`; `tools/test/row.sh:683-689`; `tools/test/face.sh:585-591`
- checked:  2026-09-04
- element:  UNASSIGNED
