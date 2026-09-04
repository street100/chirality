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
