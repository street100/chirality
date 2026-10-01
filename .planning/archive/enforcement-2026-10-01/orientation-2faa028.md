# Enforcement: orientation at HEAD 2faa028

Written 2026-09-30 from ten slice reports. A verifier checked each report: 240 claims held, 10 drifted, 1 was false and 0 were unverifiable. No slice was lost. Where a reader and its verifier disagree, this document uses the verifier's reading and lists the correction in section 8. On the question of what actually runs, the code-reach and gate-tier slices override the documents.

## 1. Enforcement in one paragraph

The goal is stated at `docs/goals/enforcement.md:25-42`. It says that anything chirality's compiler asserts about its own work is carried as a value with evidence, is refused when it does not hold, and is guarded by a gate that goes red when it breaks. Progress is measured on the four rungs defined at `docs/definitions/status-ledger.md:133-140`:

- **DESIGNED**: described, with no code.
- **SEEDED**: code exists, and nothing on a shipping path reaches it.
- **IMPLEMENTED**: reached, but no gate fails if it breaks.
- **ENFORCED**: "structurally guaranteed and gated: a check in the kernel, the loader or the suite fails when the property stops holding. Breaking it turns something red."

Under that last sentence, a kernel refusal that no fixture exercises is not ENFORCED. `docs/arcs/enforcement-arc.md` turns the goal's five conditions into seven requirements (`:43`, `:50`, `:123`, `:187`, `:316`, `:373`, `:471`) and 27 roster rows (`:539-565`).

At 2faa028, none of the five conditions and none of the seven requirements holds. Five roster rows read `built`. A sixth, N2/E185, is built even though its cell reads `open`. Three elements (E171 at phase 36, E204 at phase 37 and E186 at phase 26) are reached, gated and green in any checkout. E185, E187 and E188 (phases 25, 27, 28) go green only when a pre-change base binary is present, and this 50-commit shallow clone does not have one. The typed-assembly floor is the arc's centre, and it is built but nothing reaches it: `ck-prog` has no call site (`lib/lowering/tal/check.chiral:308-309`), and the shipping compile adopts `fold` with no judgment (`lib/lowering/compile-back.chiral:243-247`).

## 2. The goal's five conditions

| # | condition | serving rows | state today | evidence |
|---|---|---|---|---|
| 1 | A capability sits at ENFORCED, or its ledger row says why it does not (`goal:25-28`) | The goal names N1, N4 and syscall-custody-arc. Arc requirement 1 adds N18, N20, N22, N25, N26 and N27 (roster req column). The Coverage list at `arc:569` omits N27. | Open. N4/E187, N26/E171 and N27/E204 are built. N1/E184 has a draft SPEC and no code. Five built elements have no status-ledger row, and several rows sit on the wrong rung. | `docs/elements/ledger.md:121-122, :329-332`. `grep -n 'E18[5-8]\|E204' docs/definitions/status-ledger.md` returns nothing. Drift S1-S7. |
| 2 | A compiler claim is carried as a value with evidence, and refused when false (`goal:29-32`) | The goal names N2, N3 and N5. The arc also files N23 and N24 here through requirement 7 (`arc:471-475`). | Open. E185-E188 are built. The judgment vocabulary `Judg` carries 38 claims, but rewrites carry none. | `lib/typing/diag.chiral:99-113` (38 constructors). `fold` is adopted with no verdict at `compile-back.chiral:243-247, :267`. N23 and N24 are `designed`, `unminted` (`arc:561-562`). |
| 3 | The typed-assembly floor runs on the shipping path (`goal:33-35`) | The goal names N6-N9. Arc requirements 2 and 4 add N12, N13, N14, N17 and N19. | Open. No judgment of the floor runs. | `check.chiral:308-309` has no caller. `tools/test/tal-check.sh` G18 finds 0 `def ck-prog` in the 857,342-byte blob of `prog/compiler.prog`. PRB-70 (`records/lenses/problems.md:986`) keeps the checker outside the compiler. `records/author-calls.md:120` (dissolved 2026-09-29) and the draft `docs/decisions/decision-floor-check-per-compile.md` accept only a per-compile `ck-prog` in a process of its own. |
| 4 | Every gate row has a named mutant that is actually run (`goal:36-38`) | The goal says "No row serves this", which is stale. The arc names N11 and N21. GAP-03 is closed with owner N11 (`records/lenses/gaps.md:33-45`). | Rostered, unmet. | At least 34 counted rows have no run mutant (`docs/arcs/parts/enforcement-N11.md:100-107`). N11 is `status: blocked` (`N11.md:8, :254-258`). N21 is `open` and has no part file. |
| 5 | Chirality's own tooling is chirality's (`goal:39-42`) | The goal says "No row serves this", which is stale. The arc names N10. GAP-02 is closed with owner N10 (`gaps.md:19-31`). | Rostered, and moving away from done. | 21,536 lines sit outside the language against 782 native (section 8, G8). The goal states 12,450 at `:48`. N10 is `status: blocked` (`N10.md:8, :275-277`). `paren-audit.prog`, `resolve.prog` and `wield.prog` are invoked by no shell file or `bin/` entry; grep over `tools` and `bin` finds them only in two README files. |

## 3. The arc

### Seven requirements

The goal maps onto the requirements as follows:

- Goal condition 1 is requirement 1, word for word.
- Goal 2 is requirements 3 and 7.
- Goal 3 is requirements 2 and 4.
- Goal 4 is requirement 6.
- Goal 5 is requirement 5.

| req | subject | arc lines | rows (roster req column) | state |
|---|---|---|---|---|
| 1 | ENFORCED, or the ledger row says why | `:43-49` | N1, N4, N18, N20, N22, N25, N26, N27 | open. The arc treats the row-says-why half as mechanical work (`:43-49`). |
| 2 | The floor's checker judges what ships | `:50-122` | N6, N8, N9, N12, N13, N14, N17, N19 | open. Nothing runs. |
| 3 | The check agrees with the compiler it checks, in both directions (EN-20) | `:123-186` | N2, N3, N5, N13, N15, N16, N17, N19 | open. Its evidence gate `tal-check.sh` reads `21 ok, 0 FAIL` and is not dispatched. |
| 4 | The optimizer's re-check runs, or E17 says why not | `:187-314` | N7 | reopened 2026-09-08 by PRB-70. Neither branch holds: the re-check does not run, and `docs/elements/ledger.md:135` still says "Wired". |
| 5 | The tooling is chirality's | `:316-371` | N10 | open, rostered only |
| 6 | Every gate row names a mutant that is actually run | `:373-469` | N11, N21 | open |
| 7 | Every adopted rewrite carries evidence that it preserves meaning | `:471-507` | N23, N24 | open. Nothing runs. |

### The 27-row roster

The state column is the roster cell at `arc:539-565`. Tally: 5 built, 1 minted, 11 designed, 10 open. Where the tree disagrees with a cell, the cell is marked ⚑.

| row | what | req | state | element | next stage |
|---|---|---|---|---|---|
| N1 | Every def's fate is stated with evidence, and a fold refuses zero fates, two fates or an unclaimed label | 1 | open ⚑ SPEC at `status: draft` since 2026-09-11 | E184 | SPEC-level pipeline-audit. Step 9 is gated on `author-calls.md:86`. |
| N2 | `$apply` dispatcher domains spelled as the erased word at the lowering level | 3 | open ⚑ built (`ledger.md:329`, phase 25) | E185 | Roster cell owes `built`. |
| N3 | `$k<i>_<j>` capture-constructor field types, ruled concrete | 3 | built | E186 | done (phase 26) |
| N4 | `sk-defunc` blame channel | 1 | built | E187 | done (phase 27). R1 has no falsifier (EN-23). |
| N5 | `arm-body`'s "unreachable" arm, which returned a literal 0, repaired | 3 | built | E188 | done (phase 28) |
| N6 | Lowering pure code to tal. The preserve-check is now N13 plus N14. | 2 | open | E16 | waits on N13, N14 |
| N7 | Optimizer re-check runs, or E17 says why not. `dead` returns only under N23. | 4 | open | E17 | Write the why-not into `ledger.md:135`. `dead` waits on N23. |
| N8 | `ck-prog` gets a call site | 2 | open | E18 | Build the per-compile checker in the draft decision, after the author's veto window. |
| N9 | Effectful lowering: the effect row's tal shadow | 2 | open | E70 | Research slice R7, then N25. |
| N10 | The gate tier becomes chirality | 5 | designed, `status: blocked` | unminted | Register Q5-Q7, reconcile, then DESIGN audit. |
| N11 | Mutant-coverage witness | 6 | designed, `status: blocked` | unminted | Register Q5-Q7, reconcile, then DESIGN audit. |
| N12 | TFn census as a gate | 2 | designed, `status: blocked` | unminted | Revisit against `author-calls.md:120`, reconcile Q8, then audit. |
| N13 | Preserve-check T1: source and target evaluators agree | 2, 3 | designed, `status: blocked` | unminted (packet adopts E169) | Revisit against `:117`. Roster the evaluator repairs. Register Q3. |
| N14 | Peel census of the region `ttype` excludes | 2 | designed, `status: draft` | unminted | DESIGN audit, then mint. |
| N15 | `tal-ty=?` made transitive, with a written cast | 3 | designed, `status: blocked` | unminted | Author rules `:540-541`, then audit. |
| N16 | Defunctionalization family key splits its domains | 3 | designed, `status: blocked` | unminted | Author rules `:542`, then audit. |
| N17 | `i-bnew`, `i-bget` and `i-blen` carry a result type | 2, 3 | open, no part | none | element-design |
| N18 | The bounds relation | 1 | designed, `status: blocked` | unminted | Author rules `:94`, `:96`. Waits on N22. |
| N19 | Byte instructions carry an index-to-buffer relation, or the floor disclaims memory safety | 2, 3 | open, no part | none | element-design. `:98` picks the branch. |
| N20 | Census of caller-indexed byte access | 1 | minted | E198 | design-to-spec (no SPEC exists) |
| N21 | Every bug class at `none` or `partial` names a gate | 6 | open, no part | none | element-design. Scope depends on `:99`. |
| N22 | A refinement atom may name a value the program already has | 1 | open, no part | none | element-design. N18 waits on it. |
| N23 | Per-rewrite value check | 7 | designed, `status: blocked` ⚑ its call is ruled | unminted | Revisit against `:117`, roster the eval-prim row, then audit. |
| N24 | `fold`'s rules checked once | 7 | designed, `status: draft` | unminted | DESIGN audit, then mint. |
| N25 | Effect row on the Pi | 1 | designed, `status: blocked` | E39 | Author rules `:538-539`, then design-to-spec. |
| N26 | The `->`/`=>` membrane refused at the call | 1 | built | E171 | done (phase 36) |
| N27 | Extern honesty | 1 | built | E204 | done (phase 37) |

All 14 part files exist for the rows that need one, and ledger-lint AH reports nothing for this arc. AH cannot see a missing part on an `unminted` row, though (`tools/ledger-lint/ledger-lint.py:2339-2341`).

## 4. What is actually enforced today

The shipping compile is `bin/chirality` → `bin/chirality-bin`, entered at `prog/compiler.prog:18`. The code-reach reader recompiled the blob and got a byte-identical 1,261,944-byte binary. So the 61-module import closure is exactly what ships.

### ENFORCED: built, reached on the shipping path, gated by a dispatched phase

| capability | where | gate | caveat |
|---|---|---|---|
| Judgment vocabulary, 38 constructors | `lib/typing/diag.chiral:99-113`. Constructed in `kernel.chiral` and `loader.chiral`, both in the closure. | phase 13 `diag.sh`, 30 passed | The goal says 36 (`goal:99`). |
| E171 membrane refusal | `lib/typing/kernel.chiral:900` in `infer-app2`, with `seat-sub` at `:566-569` | phase 36 `membrane.sh`: 30 passed, 4 mutants | none |
| E204 extern honesty | `lib/module/loader.chiral:471` (called `:482`); `lib/lowering/compile-emit.chiral:350` (`pure-lib-offender`) | phase 37 `extern-honesty.sh`: 17 passed, 2 mutants plus 3 poisons | none |
| H8 profile port-set refusal at emit | `compile-emit.chiral:356-357` | phase 5 `syscall-manifest.sh:139-162`, 12 passed | No mutant targets `manifest-offender`. The goal cites `:300`. |
| E76 chokepoint (`ck-tiprog`) | `compile-emit.chiral:353-354` | phase 5 poison idiom | `status-ledger.md:192` files it SEEDED. |
| E186 capture fields | no `lib/` change (a ruling). Probe at `prog/e186-capture-fields.prog`. | phase 26 `capture-fields.sh`: 9 ok, M1-M5 run | none |
| E185, E187, E188 | `closconv-driver.chiral:127-145`, `closconv.chiral:692, :720, :1129-1144`, `compile-front.chiral:201-224` | phases 25, 27, 28 | ENFORCED only on a full-history checkout. In this VM each reads `5 ok, 1 FAIL` and skips 5 mutants. |

`arm-body` now builds a call spine, and `grep -c 'c-lit-i 0' lib/lowering/upper/closconv.chiral` returns 0. That confirms EN-20's defect is closed.

### Built, but unadopted or ungated

| capability | where | reach | gate |
|---|---|---|---|
| Floor checker `ck-fn` / `ck-prog` | `check.chiral:290`, `:308-309` | SEEDED. Outside the closure; imported only by `prog/optimizer-census.prog:53`. `ck-fn` runs only from `optimizer-census.prog:78` and `tools/test/tal-check.sh:301`. | `tal-check.sh` is green at 21 ok and undispatched. |
| Reference interpreter `tal-eval` | `lib/lowering/tal/eval.chiral` (187 lines) | zero importers | none. `eval-prim` covers only `+ - * / %` and returns `(v-i64 0)` for everything else, including `=i <i <=i` (`eval.chiral:86-95`), which `fold-cmp` folds (`optimize.chiral:68-73`). |
| Source evaluator | `lib/evidence/interp.chiral` (109 lines) | zero importers | none |
| Optimizer | `fold` is reached (`compile-back.chiral:247, :267`). `dead`, `optimize` and `specialize` are in the blob but uncalled (`optimize.chiral:256, :263`). | `fold` IMPLEMENTED; its re-check SEEDED (`optimizer-census.prog:78` only) | `opt-census.sh` is red and undispatched. |
| E70 effect lowering | `lib/lowering/upper/eff-lower.chiral` (183 lines) | SEEDED. Imported only by `lib/module/sig-driver.chiral`, which has zero importers. | none |
| Old three-rule membrane | `lib/typing/effects.chiral:35, :39, :44` | zero callers | none |
| E16 partition | `lower.chiral` `skip-reason :83`, `eligible? :94`, `lower-def :98`, `lower-all :104`, `ttype` | No caller outside the file. `ttype` appears elsewhere only in comments. | none |
| Skip attribution | `compile-back.chiral:265-266` tags every term-level skip `sk-extern`. `compile-front.chiral:231-232` drops a def with no record. `compile-all.chiral:35` discards the skips on success. | Recorded, and rendered only on failure (`compile-all.chiral:42-44`). A probe that has an unreached `=>` extern compiles silently. | No gate covers success-arm attribution. |
| Strict positivity | refusal text at `diag.chiral:468` | kernel | `status-ledger.md:163` files it ENFORCED. No fixture in `tools/` or `prog/` produces the refusal. |
| "Floor agreement of the arithmetic prims" | `status-ledger.md:164` | `eval.chiral` has zero importers | The row files itself ENFORCED "by construction", yet the tests that pinned it are CUT, and `eval-prim` answers 0 where `fold-cmp` computes. |

### Designed or open

- **E184 def-fate sum (N1).** No code. `grep FateRec\|ft-created\|def conserve` over `lib prog tools/test` returns nothing.
- **Floor work:** N12, N13, N14, N15, N16 are designed. N17 and N19 are open. N8 is open.
- **Checked rewrites:** N23 and N24 are designed.
- **Bounds.** N18 is designed, N20/E198 is minted, and N19, N21 and N22 are open. The class is open at HEAD:
  - `(bget (str->bytes "abc") 99)` exits 0.
  - `(blen (bslice (str->bytes "abc") 0 99))` exits 99.
  - `(str-find-from "abcabc" "c" -5)` returns 2.

  These are EN-31 and EN-33, reproduced by the record verifier through `./bin/chirality run` on a `compile-main (=> I64 I64)` root.
- **Effect row:** N25/E39 is designed. Native gate tier N10 and mutant witness N11 are designed.

## 5. The gating floor, live

`tools/test/run-tests.sh` is reached as `chirality test` (`bin/chirality:181`). It dispatches 24 `run_phase` scripts, runs inline Phases 1, 2 and 7, then runs `registration.sh`.

**Two full runs at 2faa028 in this VM** (4 CPUs, 16 GB, shallow clone of 50 commits):

| run | wall | user | verdict |
|---|---|---|---|
| gate-tier reader (`gate-run.log:998-1010`) | 4m31.146s | 4m6.234s | `chirality test: gate FAILED (3 failing check(s)/phase(s))`, `RUN_EXIT=1` |
| goal-requirements reader (`run-tests.out`) | 4m32.834s | 4m6.257s | same verdict |

Headline lines, verbatim: `assertions: 486 passed, 0 failed` and `compile-only: 96 roots built, 0 failed`.

The "0 failed" is wrong. `run-tests.sh:134-138` tallies a phase only when its log matches `N passed, M failed`. Phases 25, 26, 27, 28 and 31 print `N ok, M FAIL` (`apply-word.sh:290`, `capture-fields.sh:257`, `defunc-blame.sh:395`, `apply-spine.sh:376`, `crypto.sh:401`). As a result, 32 ok rows and all 3 FAIL rows stay out of the count; the log holds 519 `ok` lines. The verdict still goes red because exit codes gate.

**The three FAIL lines, verbatim:**

```
682:  FAIL  R6 the fixture's ELF is byte-identical under both binaries -- got 'nobase', want 'ok'
734:  FAIL  R6 the pre-change binary states no cause and this one does -- got 'nobase', want 'ok'
750:  FAIL  R6 the pre-change binary prints 0 and this one prints 30 -- got 'nobase', want 'ok'
```

Each R6 row reads `bin/chirality-bin` at a pinned revision:

| script | pinned revision |
|---|---|
| `apply-word.sh:114` | `30b288b` |
| `defunc-blame.sh:152` | `21e1b28` |
| `apply-spine.sh:122` | `4caf5f0` |

None of the three is in the clone: `git rev-parse --is-shallow-repository` returns `true`, and `git cat-file -t 30b288b` is fatal. With no base, each script skips its five mutants, so 15 mutants went unexecuted. The gate-tier reader fetched the three base binaries from a blobless clone and passed them through `E185_BASE_CC`, `E187_BASE_CC` and `E188_BASE_CC`. Each phase then read `11 ok, 0 FAIL` and ran its five mutants. The red comes from checkout depth; the same code is green on a full clone.

### Dispatched phases

| phase | script | subject | this run | mutants |
|---|---|---|---|---|
| 1 | inline, `run-tests.sh:73-83` | six programs against exit codes | 6/6 | none named |
| 2 | inline, `run-tests.sh:92-112` | `prog/test-runner.prog` over six samples | 6 checks, exit 0 | none named |
| 3 | `check-cli.sh` | QTT core, linear types | 12 passed | `mutant.sh` (`:118`) |
| 4 | `profile-target.sh` | memory discipline, frozen port set | 38 passed | M1-M3. 11 rows reddened by none (PRB-56). |
| 5 | `syscall-manifest.sh` | E76 chokepoint, H8 | 12 passed | poison idiom: 3 poisons and a control |
| 6 | `linear-mint.sh` | E159 | 38 passed | M1-M5. 22 of 32 rows uncovered (N11). |
| 7 | inline, `run-tests.sh:171-207` | compile-only sweep of 107 roots | 96 compiled, 8 reject skipped, 3 known-fail | none. Untallied by design. |
| 13 | `diag.sh` | E157 | 30 passed | 7 |
| 14 | `doc.sh` | E158 | 33 passed | M1-M17 |
| 15 | `row.sh` | E174 | 42 passed | run |
| 16 | `face.sh` | E175 | 38 passed | run |
| 17 | `render-doc.sh` | E158 c4 | 20 passed | run |
| 18 | `pretty.sh` | E181 | 71 passed | M1-M26 |
| 19 | `matcher.sh` | E173, plus the `prose-lint.prog` differential | 20 passed | own harness. 3 verdict rows reddened by none (GA-21). |
| 20 | `transport.sh` | E130/E131 | 3 passed, 2 deferred | none, by design (`transport.sh:34-37`) |
| 24 | `arity.sh` | E182 | 17 passed | run |
| 25 | `apply-word.sh` | E185 / N2 | **5 ok, 1 FAIL**, untallied | 5 skipped |
| 26 | `capture-fields.sh` | E186 / N3 | 9 ok, untallied | M1-M5 |
| 27 | `defunc-blame.sh` | E187 / N4 | **5 ok, 1 FAIL**, untallied | 5 skipped. R1 unfalsified. |
| 28 | `apply-spine.sh` | E188 / N5 | **5 ok, 1 FAIL**, untallied | 5 skipped |
| 29 | `encoding.sh` | E196 | 9 passed | run |
| 30 | `recording.sh` | E197 | 12 passed | run |
| 31 | `crypto.sh` | ChaCha20, Poly1305 | 8 ok, untallied | M1-M2 |
| 32 | `mul-widen.sh` | E189 | 10 passed | run |
| 33 | `span-over.sh` | E200 | 19 passed | four compiler generations |
| 36 | `membrane.sh` | E171 / N26 | 30 passed | 4 |
| 37 | `extern-honesty.sh` | E204 / N27 | 17 passed | m1-load-off, m2-emit-off |
| (none) | `registration.sh`, `run-tests.sh:408-426` | dispatch table against the directory | 9 passed | M1-M7 |

**Unported** (printed by name each run, `gate-run.log:991-996`):

| phase | element | state |
|---|---|---|
| 8 | E161 module datasheet, the reach gate the goal cites at `:119` | not ported |
| 9 | E156 | fixtures present, script not ported |
| 11 | resolver and build state | not ported |
| 12 | E168/E170 | fixtures present; script and mutant machinery not ported |
| 10 | external C leg | dropped by author decision |

**Gates nothing runs.** Seven scripts are outside the dispatch table ("7 of 31", `gate-run.log:971`). Two of them are `run-tests.sh` and `registration.sh`, which do run. The other five were run by hand:

| script | result by hand | mutants | stated reason for staying out |
|---|---|---|---|
| `tal-check.sh` (E18 / N8, N15) | green, `21 ok, 0 FAIL`, about 1s | 3 run | Three reasons, all stale: red on G18 (`run-tests.sh:357-359`, `tal-check.sh:8-10`), "claims 22" (`tal-check.sh:14`), and "21 owed to crypto.sh" (`status-ledger.md:35-38`). |
| `opt-census.sh` (E17 / N7, N12) | red, `2 passed, 2 failed, 4 mutants unmeasured`, exit 1 | 4 unmeasured | `not-a-phase` (`:5`) |
| `shape-census.sh` (E201) | red on R2, 5 passed 1 failed | 8 unmeasured | awaits an author ruling on R2 (`:2-3`) |
| `map-integrity.sh` | red, 176 of 869 rows stale | none | none owed by this arc |
| `mutant.sh --matrix` | exit 0 in 1m59s; all 7 declared mutants convicted, all fixpoint at C1==C2 | 7 | PRB-55 OPEN, owner none (`records/lenses/problems.md:770`) |

`opt-census.sh` pins `WANT_DEFS=1519 WANT_TFNS=1549 WANT_OK=1518 WANT_ERR=31` (`:143-147`). HEAD reads `census tfns=1562 ok=1531 err=31 defs=1532`. Its R3 still holds: one class, n=31, first `bput-u8`.

The census was already off its pins before E171. The code-reach reader measured 1551/1520 at `d47f5ce^`, and N12's design reading of 1551/1520/31 agrees. The record verifier did not re-take that snapshot. E171 and E204 moved it further.

**Mutant coverage (goal condition 4).** The condition is unmet:

- **Rows with no run mutant.** At least 34 counted rows have none: 11 in profile-target, 22 in linear-mint, and defunc-blame R1 (`enforcement-N11.md:100-107`).
- **Phases with no mutant.** Only `transport.sh` declares none by design (`:34-37`). Phases 1, 2 and 7 run no named mutant in this log, but N11 does not list them.
- **Mutants that did not run here.** In this VM, 15 mutants were skipped in phases 25, 27 and 28, and 12 more are unmeasured in the two red census gates.
- **The matrix.** The one tool that convicts every declared mutant, `mutant.sh --matrix`, is not dispatched.

## 6. The doc tier's enforcement

Hooks and CI:

- The only git hooks under `.git/hooks` are samples.
- There is no `.github`, and `git config core.hooksPath` is empty.
- `run-tests.sh` calls no doc linter. Grep finds `prose-lint` only in a comment at `:34` and in the phase-19 differential at `:289`.

| mechanism | kind | today |
|---|---|---|
| `tools/test/run-tests.sh` | hard gate (code) | red in this VM (section 5) |
| `pack.py` `roster_check` (`:383-412`) and `--mint` refusals (`:1311-1370`) | hard refusal per invocation | Refuses illegal roster moves and unfilled designs. It never reads an audit verdict: `awk 'NR>=1311&&NR<=1400' tools/pack/pack.py \| grep -ci audit` returns 0. |
| `pipeline-audit` skill (`.claude/skills/pipeline-audit/SKILL.md:114-158`) | agent-run gate | The N26 BLOCKED-then-fixed and N27 PASS verdicts live only in commits `d1d1274` and `31772bb`. The part files still read `status: draft`. |
| `ledger-lint.py`, checks A-AN (`:2757-2796`) | worklist | exit 1: `313 violations found, 18 element homes owed, 51 author calls owed, 170 lens rulings owed, 2 checks that checked nothing` |
| `lens.py check` (run by check AD) | worklist | 202 rows, 0 findings |
| `lens.py author` (check AN) | worklist | 170 of 202 unreviewed: problems 97/101, gaps 21/27, limits 22/23, unspoken 30/51 |
| `lens.py overview --check` | unwired | DRIFTED, 137 lines differ. `OVERVIEW.md:97` shows this arc at 22 rows. `decision-four-lenses.md:135-137` promises a lint check that fails a stale OVERVIEW, and none exists. |
| `prose-lint.sh` | worklist | The goal file is clean. `--regress` exits 1 with 139 files worse. The arc went from 7 to 27 hits. Parts N18 (24), N20 (9) and N13 (2) are new. |
| check AJ, the deferral rule | worklist | 0 issues |
| tone rules and citation density (`tone.md:54-58, :67-106`); pathspec commits and the reporting rule (`working-discipline.md:89-95`); the fixpoint build rule (`:23-50`); audit before mint | prose only | Where the fixpoint phase belongs is an unreviewed call (`author-calls.md:113`). |

**ledger-lint on the enforcement documents.** 16 of the 313 violations name enforcement documents:

| check | count | findings |
|---|---|---|
| F | 2 | `related: arc-enforcement` in `decision-def-partition.md:4` and `decision-preserve-check.md:4`. F resolves `arcs/enforcement-arc`. |
| G | 4 | `enforcement-N14.md:64` cites `skip-diag.chiral` lines past its 122 lines. `enforcement-N16.md:132` cites `closconv-driver.chiral:337-340`, which has 295 lines. |
| R | 6 | N14:61 (`lower-defs` is at `:249-250`), N14:106-107, N15:98 (`ttype`), N27:138 (`emit-elf-m`), N27:211 (`ty-crosses` is at `kernel.chiral:314-315`) |
| AI | 4 | EN-24, EN-25, EN-33, EN-35: the four OPEN record rows |

Seven more violations land on the SPECs and examples of the arc's own elements: E171 SPEC:48 (G), E187 SPEC:164 (G and R), E204 SPEC:56 (R), the E184 SPEC (AA), and `docs/examples/E184-def-fate-sum.md:73, :84` (R).

AI dates a file with `git log -1 --format=%cs` (`ledger-lint.py:2373-2374`). In this clone, 157 of the 232 AI findings rest on a file whose only visible commit is the graft `8ee3627`, and that includes EN-24, EN-25 and EN-33. Re-run `--only AI` on a clone with full history before revisiting any of them.

## 7. What the record teaches

`records/enforcement-arc.md` holds 38 rows. Its `state:` lines count 19 FIXED, 15 RETIRED and 4 OPEN (EN-24, EN-25, EN-33, EN-35). RETIRED usually means the row moved to a lens row (PRB-33 to PRB-46). FIXED also covers "reproduced exactly", since no fifth state exists.

1. **A figure is withdrawn.** EN-07 (`:92-99`) withdraws "1,352 of 1,402 defs emitted (96.4%)". It was measured through the dropped E166 C leg, and the real number stays unknown until E184 exists. `grep -rn '96\.4' --include='*.md'` finds no other citation.
2. **The floor's disagreement was mostly the checker.** EN-08 to EN-14 split a 50.9% reject rate over 1,481 TFns:
   - `ret`: 389 of 389 from one erased type-argument relation;
   - `con`: 184 of 185 from the same relation;
   - arity: 70 of 75 from the same relation;
   - case-on-non-data: 105 of 105 from a missing `tt-word` recovery;
   - 6 were real lowering defects.

   The probe was reverted (`:103-104`), so these figures cannot be re-run. `tal-check.sh` mutants M1 and M2 exercise the two repairs.
3. **An "unreachable" arm was reached.** EN-19 and EN-20 found `arm-body`'s `(none) -> 0` arm firing in the compiler's own blob; on a fixture, a value routed through `$apply` came out 0 instead of 30. The type check cannot see that when the codomain is I64. E188 closed it. EN-22 then corrected EN-20: the direct call's 30 came from the specializer.
4. **A shape check passes a miscompile.** EN-24 found that `ck-fn` accepts the residual of `dead`, even though `dead` alone grades `row.sh` at 33 passed, 9 failed. That is why only `fold` ships. EN-25 found that requirement 4 had closed on a probe nobody committed. EN-26 carried out PRB-70, which moved the checker out of the closure and reopened requirement 4. EN-36 added requirement 7 because a shape check cannot catch a miscompile.
5. **The partition was ruled "neither".** EN-27 found that `ttype` and its 84-line partition have zero consumers. EN-28 routed the author's "fix it the proper way" into E184's R1. EN-29, EN-30 and EN-32 settled the domain: the pre-pass set plus the created names, with deletion never a fate.
6. **Bounds are silently unrefused.** EN-31 and EN-33 found that 7 of the 34 prelude externs in the cited span carry a caller-supplied index and none of them clamps. The prelude now holds 35 externs (`bover` at `lib/prelude/prelude.chiral:130`).
7. **A class with zero rows is invisible to requirement 6.** EN-35 found four `Term` walks ending in an unowned `_` arm: `totality-check.chiral:103`, `data.chiral:217, :282` and `specialize-singleton.chiral:158`.
8. **Measurement discipline, as the record itself shows it:**
   - counts depend on the definition used (EN-05 gives 18, 27 or 17 zero-importer modules);
   - SPEC mutant pins were measured false (EN-21, EN-22, EN-23);
   - central figures rested on uncommitted probes (EN-24, EN-25, EN-28 F3);
   - a fixpoint took three generations (EN-22);
   - every count is pinned to one blob. EN-26's 840,440-byte blob reads 857,342 at HEAD.

## 8. Drift found in this pass

In the tier column, **doc** means a document tier file. **code** means behaviour under `lib/`, `prog/`, `tools/` or `bin/`. **comment** means a comment or header in a code file.

### The goal (`docs/goals/enforcement.md`, `updated: 2026-09-14`)

| id | what | where | evidence | tier |
|---|---|---|---|---|
| G1 | "No row serves this" for conditions 4 and 5 | `:36-42` | GAP-02 and GAP-03 were closed 2026-09-06 with owners N10 and N11 (`gaps.md:19-45`). Arc Coverage is at `:569-574`. | doc |
| G2 | "E171, unbuilt" | `:132-133` | commit `d47f5ce`; `ledger.md:121` built; `run-tests.sh:383` phase 36 | doc |
| G3 | Condition 2 lists only N2, N3, N5 | `:29-32` | The arc files N23 and N24 under it (`:471-475`), and N23:28 and N24:29 claim it. EN-36 says "the goal needed nothing new", so no record lists this as owed. | doc |
| G4 | "36 named judgments … no constructor exists for effects" | `:99-101`; also `docs/definitions/bug-classes.md:123` (against its own `:55`) and `enforcement-N18.md:81` | 38 at `diag.chiral:99-113`. `jg-pure-crossing` is at `:111` and `jg-extern-pure-crossing` at `:112`. It was 36 at `8ee3627` and 37 after `d47f5ce`. | doc |
| G5 | Profile refusal cited at `compile-emit.chiral:300`, gated by profile-target | `:115`; `docs/goals/self-hosting.md:156` | `:300` is `(declare plib-names …)`. The refusal is at `:356-357`, and the rows that exercise it are in `syscall-manifest.sh:139-162`. | doc |
| G6 | http-request, backend-open and chat-open "have no wrapper entry" | `:165-166` | Retired by BA-42 (`problems.md:420`): two are defs (`lib/protocol/http.chiral:437, :773`), and `backend-open` erases to `nb-id` (`erase.chiral:124`). | doc |
| G7 | Condition 3 conflicts with PRB-70 and cites no resolution | `:33-35` | `problems.md:986`. `grep floor-check-per-compile` over the goal and the arc returns nothing. `author-calls.md:120` carries the dissolution. | doc |
| G8 | Condition-5 figures: 12,450 outside, 6,915 gate shell, 223 prose-lint, nine Python files at 4,786, and "782 is every .prog file"; 240 invocations and 352 word uses | `:46-53` (figure at `:48`), `:50`, `:63-76` | Now: `tools/test/*.sh` 12,700 lines over 31 files; `prose-lint.sh` 245; ten `.py` files at 8,065; `bin/` 526; total 21,536. The five tools are still 782 lines, but `prog/*.prog` other than `compiler.prog` is 13 files and 2,537 lines. Word uses re-count at 544 (grep 224, sed 172, awk 118, sort 30). The invocation scanner is untracked, so 240 cannot be re-taken. | doc |
| G9 | J1's criterion "has not been written" | `:66-67` | `docs/decisions/decision-formulation-distinctness.md` exists, `status: draft`, and has no register row. | doc |

### The arc (`docs/arcs/enforcement-arc.md`)

| id | what | where | evidence | tier |
|---|---|---|---|---|
| A1 | "Twenty-six rows"; origins sum to 26 | `:514-519` | 27 rows at `:539-565` | doc |
| A2 | Requirement-1 Coverage and the effect group both omit N27 | `:569`, `:535` | N27's req cell reads 1 (`:565`) | doc |
| A3 | Coverage names N7, N8 and N13 as `connect` | `:574-576` | N12 (`:550`) and N23 (`:561`) are also `connect` | doc |
| A4 | Says `docs/arcs/README.md:74` lacks `pair` | `:579-582` | README:74 lists `pair` | doc |
| A5 | E185 described as open or unbuilt | `:540`, `:136`, `:1136`, `:1138` | The arc says built at `:57` and `:717`; `ledger.md:329` built; phase 25 | doc |
| A6 | N1 `open`, next stage design-to-spec on E184 | `:539`, `:681` | `docs/elements/specs/E184-def-fate-sum-SPEC.md` exists, `status: draft`, updated 2026-09-11, uncited | doc |
| A7 | Newest resume entry says N25 and N26 are `open`, next is element-design on N25 | `:600-608` | Later commits the same day: N25 designed (`d465f67`), N15/N16 designed, E171 built (`d47f5ce`), E204 built (`491936e`). No entry records N27, E171, E204 or the E198 mint. | doc |
| A8 | Header's owned-element list omits E198 and E204 | `:25-28` | roster `:558`, `:565` | doc |
| A9 | "The next free number is E189"; "E184 and E189 are the two design rows left" | `:1275-1285`, `:718-719` | E189 is built for another arc (`ledger.md:333`, phase 32). `docs/examples/INDEX.md` has no row for E189, E198 or E204. The next number is E205 (P5). | doc |
| A10 | Heading "Open: minted, not built" | `:783` | Four of its five elements are built | doc |
| A11 | Phase-number call "still open", barred to a session | `:183-186`, `:433-435` | Ruled 2026-09-06 at `author-calls.md:73`: "the first number colliding with nothing" | doc |
| A12 | N23 placement "is an author call" | `:498-506`, `:561` | Ruled "both" 2026-09-29 (`author-calls.md:117`) | doc |
| A13 | Registration: 26 scripts, 13 dispatched, 13 outside; GA-01/04/08/10 open | `:378-385`, `:434`, `:448` | `registration.sh` today: 24 dispatch lines, 31 scripts, 7 outside. The GA rows are RETIRED (`records/gate-audit.md:104, :147, :186, :207`). `:410` shows tal-check red, and the re-measured table at `:413-418` already shows 21 ok. | doc |
| A14 | Census 1548/1517, "8 passed, 0 failed" | `:96-97`, `:308-310`, `:1253` | Pins are 1549/1518. Live is 1562/1531, red. `docs/implementation/optimizer-inventory.md:354` carries 1548/1517 too. | doc |
| A15 | "The CEnv-plumbing gap … is still what stands between here and ck-prog" | `:99-100` | N12 measured `ck-prog` accepting 1,549 of 1,549 shipped TFns and traced the 31 refusals to opt-census's own CEnv (`enforcement-N12.md:62-81`). Not re-measured. | doc |
| A16 | Line citations moved | `:490` and `:562` (`compile-back.chiral:250`, fold is at `:247`); `:111` and `:557` (`ssa.chiral:31`, i-bget `:32`, i-bput `:33`); `:556` (`diag.chiral:97-110`, block `:99-113`); `:697`, `:700` (author-calls `:84-88`, `:85`; bounds ruling now `:95`); `:374` (`testing-floors.md:261`, rule at `:287-292`); `:324` (TC-13; the figure is in TC-14, `tooling-classification.md:627-632`); `:1136`, `:1138` (`apply-ty` at `closconv.chiral:1163-1165`, now `:1183`) | grep and sed at HEAD | doc |
| A17 | Floor line counts: lower 407, optimize 254, check 246 | `:1246`, `:1254`, `:1258`/`:1260` | `wc -l`: 420, 265, 312 | doc |
| A18 | "built, and adopted at one point only" | `:1231` | Its own body at `:1235-1239` says neither half runs. The one call is `fold`, which is a rewrite. | doc |
| A19 | E187 "INDEX row is OWED" | `:1167`, `:1169` | `docs/examples/INDEX.md:170` carries it | doc |
| A20 | E186 "takes no suite phase number" | `:1142`, `:1144` | phase 26 at `run-tests.sh:362` | doc |
| A21 | N10: "10,719 lines of shell … against 1,775 native"; resume says 7,136 | `:548`, `:732` | 12,700 over 31 scripts; `prog/*.prog` 2,557 over 14 files | doc |
| A22 | N27: "issues no syscall"; "44 lines" | `:565` | The design rejects that wording and enforces "reaches no crossing" (`enforcement-N27.md:120-130`). The grep reads 46 today, 2 of them E204 reject fixtures, and `ledger.md:122` says 38. None of the three counts states its predicate. | doc |

The goal-requirements reader flagged `:461` ("requirement 6 is satisfied throughout") as contradicting `:437-441`. **The verifier found this false.** The `:461` sentence is scoped to the `str-sub`/`str-starts-with` contact rows (`:457-463`). It says nothing about every gate row, and the arc does not contradict itself there.

### Design parts (`docs/arcs/parts/`)

| id | what | where | evidence | tier |
|---|---|---|---|---|
| P1 | N23 blocked on a call it cites as `author-calls.md:116`, `unreviewed` | `enforcement-N23.md:8, :193, :222-225, :229, :255` | `:117` is ruled "both"; `:116` is the inspiration-policy row | doc |
| P2 | N23: "203 is the number free today" | `:250-251`, `:277` | E200-E204 are minted, and `pack.py` gives 205 (P5) | doc |
| P3 | N23 and N24 say FD-55 resolves only in the working tree, at `:1236` or `:1282` | N23:296-299, N24:276-277 | FD-55 is committed at `records/findings.md:1475` | doc |
| P4 | N23: `not-a-phase` taken by "opt-census.sh and eight siblings" | `:234` | 7 scripts carry the marker | doc |
| P5 | N14 §6: mint takes "the lowest number free, 191". N15:276-277 and `docs/decisions/decision-lane-split.md:53` say the same. | N14:446-454 | `pack.py:1336-1346`: `num = max(taken) + 1` once a band is full, which gives 205 | doc |
| P6 | N13 and N14 route their gates `not-a-phase:` | N13:250, N14:423 | ruling `author-calls.md:73`; `opt-census.sh:6-7` calls that header stale | doc |
| P7 | N14 §6: the roster kind "moves from primitive to tool"; opt-census is 273 lines | N14:477-480, `:470` | The roster already reads `tool` (`arc:552`). `wc -l` gives 307. | doc |
| P8 | N12 Q9 NEEDS-AUTHOR; `req: 2, 3` | N12:198, `:7` | `author-calls.md:120` dissolved it and says N12's §1 and req cell owe a revisit. The roster says 2. | doc |
| P9 | N13 Q1 NEEDS-AUTHOR; cites `:83` and `ledger.md:155`; Q5 reads "NEEDS A ROW" | N13:243-244, `:69` | Q1 is ruled at `:117`. The tier line is at `:84`. E169 is at `ledger.md:156`. "NEEDS A ROW" is not a template disposition. | doc |
| P10 | DEFERRED to a queue item and to a residue row | N13:248, N24:218 | The element-design charter allows DEFERRED only to an existing E# or roster row (quoted in EN-38; the reader's citation `SKILL.md:122` is a blank line) | doc |
| P11 | N10 and N11: three NEEDS-AUTHOR each "earn a row"; none exists | N10:292-293, N11:258-259 | `grep -c 'enforcement/N10\|enforcement-N10' records/author-calls.md` returns 0, and the same for N11 | doc |
| P12 | N11: "7 of 29 scripts", "three scripts source the library"; cites `:98` | N11:113-114, `:120-122`, `:33` | 31 scripts; five scripts source it (`check-cli.sh:118`, `profile-target.sh:220`, `linear-mint.sh:437`, `membrane.sh:192`, `extern-honesty.sh:53`); condition-4 row at `:99` | doc |
| P13 | N15 and N16 say their author-call rows are unwritten | N15:299, N16:63-64, `:205` | The rows exist at `author-calls.md:540-542` | doc |
| P14 | N16's kind is `primitive` in its front matter and in the roster, and `law` in its §6 catalog row | N16:5, `:218` | Reader's report. The verifier confirmed the front matter and roster and did not re-read the §6 cell. | doc |
| P15 | Parts cite the agent tier, which the audit skill flags as a tier violation (`SKILL.md:36-41`) | N10:274, N11:303, N12:241, N13:109, `:248`, N14:488 | They cite `.planning/DISPATCH-QUEUE.md` and `.planning/TAL-CONFORMANCE-QUEUE.md` | doc |
| P16 | N18 author-call citations `:85`, `:363`, `:364` | N18:357, `:397`, `:402`, `:455`, `:456`, `:476`, `:477`, `:506`; N20:327-328 | Bounds ruling at `:95`, clamp call at `:96`. `:363-364` hold no call rows. | doc |
| P17 | N18 cites `operand-ok?` at `kernel.chiral:1390-1394` and refusals at `:1419`, `:1439-1440` | N18:66-68, `:118`, `:121`, `:159`, `:202`, `:420`, `:448`, `:545`, `:555`, `:590` | Now at `:1403-1407`, `:1432`, `:1452-1453` | doc |
| P18 | N20 and `catalog.md:650`: 34 externs, a 16/3/15 route split, `native-lib` 28 TIFns | N20:50, `:56-60`, `:137` | 35 externs; 16/3/16; 30 entries at `bytes.chiral:813-826` | doc |
| P19 | N20, N26 and N27 read `status: draft` | line 8 of each | N20 is minted; N26 and N27 are built | doc |
| P20 | N25 says the E39 ledger row is amended | N25:301-303 | `ledger.md:116` is unchanged | doc |
| P21 | Design-time figures that moved | N10:52-53, `:122`, `:148`; N11:120; N12:57 | ok() defined in 26 scripts (24 in the design); PRB-66 grep 513 (502); mutant helpers 35 in 21 scripts (36 in 20); opt-census 1562/1531 (1551/1520) | doc |

### The record (`records/enforcement-arc.md`)

| id | what | where | evidence | tier |
|---|---|---|---|---|
| R1 | "of which E184 is minted" | `:18` | The whole band is minted (`catalog.md:505-510`); `:357` says the band is spent | doc |
| R2 | EN-17's state is RETIRED; its note says it "stays state: OPEN" | `:189` vs `:225` | same row | doc |
| R3 | EN-25 is still OPEN | `:298` | EN-26 (`:305-312`) ruled and carried out its last defect. `run-tests.sh:359` still cites EN-25 as the reason tal-check stays out. | doc |
| R4 | EN-33 element reads UNASSIGNED | `:391` | N20 is minted as E198 | doc |
| R5 | EN-36 says N23 waits on an unreviewed row; EN-37 has N26 `open`; EN-38 has N27 `open`, `unminted` | about `:414-421`, `:424-431`, `:440` | `:117` ruled; the roster has N26 and N27 built. No EN row records the E171 or E204 builds or the E198 mint. The last commit touching the record is `d1d1274`. The date paragraph at `:25-27` stops at EN-35. | doc |
| R6 | Moved code citations | EN-20 `arm-body` at `closconv.chiral:1051-1058` (now `:1129-1144`); EN-24 at `:290`, which says `opt-tfns` calls `re-check` at `optimize.chiral:250` (no `re-check` exists in optimize); EN-29/EN-32 `compile-back.chiral:272` (now `:267`); `ctor-name` `:1099`/`:1114` (now `:1201`); `kernel.chiral:1319` (now `:1332`); EN-31 `:355` `diag.chiral:97-110`, a range EN-03 itself refuted | sed and grep at HEAD | doc |
| R7 | EN-26 blob 840,440 and binary 1,220,984 | `:309-310` | Now 857,342 and 1,261,944. This is expected drift after later builds. | doc |

### Status ledger, element ledger and catalog

| id | what | where | evidence | tier |
|---|---|---|---|---|
| S1 | Effects is filed under SEEDED while its own flag says E171 is built and gated | `status-ledger.md:190` (section `:185`) | Meets the ENFORCED definition at `:138-140` | doc |
| S2 | No rows for E185-E188 or E204 | whole file | phases 25-28 and 37 | doc |
| S3 | Syscall gating filed SEEDED | `:192` | phase 5; `ledger.md:199` reads E76 "built (ENFORCED)" | doc |
| S4 | Frozen-port-set conformance filed IMPLEMENTED ("no gate defends it") | `:180` | Its own text names phases 4 and 5, both dispatched | doc |
| S5 | Strict positivity filed ENFORCED with no gate | `:163` | No fixture produces the refusal | doc |
| S6 | "Floor agreement of the arithmetic prims" filed ENFORCED | `:164` | Tests CUT; `eval-prim` returns 0 for the comparisons; `eval.chiral` has no importers | doc |
| S7 | tal-floor row filed IMPLEMENTED while its text says neither half is on the path; names optimize and eff-lower as importers of check | `:174` | `optimize.chiral:28-29` and `eff-lower.chiral:19-21` import `tal/ssa`; the only importer is `optimizer-census.prog:53` | doc |
| S8 | Lowering attributed to the unreached E16 partition | `:175` | `ttype` has no caller | doc |
| S9 | preserve-check row: `re-check` is `ck-prog`'s one caller, nothing imports optimize, blocked on four `$apply` dispatchers | `:196` | `compile-back.chiral:16` imports optimize; `re-check` is at `optimizer-census.prog:78`; E185 is built | doc |
| S10 | Banner "Phases 13-20 and 24", "21 owed to crypto.sh", suite 339/87 | `:33-38`, `:99-102` | Phases 25-37 are dispatched; crypto is phase 31; this run 486 tallied plus 32 untallied, 96 roots | doc |
| S11 | E17: "Wired 2026-09-05 … lower-defs runs re-check"; "re-check runs on every compile"; 254 lines | `ledger.md:135`, `:450`; `catalog.md:117` | Cut 2026-09-08; `compile-back.chiral:243-247`; 265 lines | doc |
| S12 | E16 SPEC called DONE-ALREADY; E70's `=>` gate "live" | `records/spec-tier-triage.md:115`, `:208`; `E70-effectful-lowering-SPEC.md:13-15` | `ck-prog` has no caller; `sig-driver.chiral` has zero importers (`ledger.md:119` says so) | doc |
| S13 | E184 SPEC claims phase 33 | `E184-def-fate-sum-SPEC.md:446-447` | `run-tests.sh:378` gives 33 to `span-over.sh` | doc |

### Other documents

| id | what | where | evidence | tier |
|---|---|---|---|---|
| O1 | This arc's row reads "5 rows"; the arc tally says twenty-eight and twenty-seven | `docs/arcs/README.md:165`, `:207-210` | 27 roster rows; 39 arc files | doc |
| O2 | OVERVIEW is stale | `docs/definitions/OVERVIEW.md:97`, `:352` | 22 rows against 27; 94/90 problem rows against 101/97 | doc |
| O3 | tal-check as Phase 22 "as crypto.sh's is"; suite 339/87; `mutant_build :101`, `mutant_red :133` | `docs/definitions/testing-floors.md:69`, `:77`, `:456-459` | `mutant.sh:127`, `:167` | doc |
| O4 | syscall-custody-arc says it is unanchored; `compile-emit` cites `:259`, `:296`, `:299`; `ledger.md:196`; one seccomp line | `docs/arcs/syscall-custody-arc.md:285-290`, `:96-97`, `:292-296`, `:320`, `:84`, `:147` | The goal names it at `:27-28`. Now `:261`, `:353`, `:356`; `ledger.md:199`; 3 grep lines, still no filter. | doc |
| O5 | The run-the-mutant rule is inherited by "requirement 5" | `records/gate-audit.md:12-13` | It is requirement 6 (`arc:373`) | doc |
| O6 | E184 spelling row reads `unreviewed`; the bounds ruling cites N18 at `:510` and N21 at `:513`; `updated:` is older than rows `:538-542` | `records/author-calls.md:85`, `:95`, `:6` | The body records the decisions closed (`arc:679`); N18 is at `:556` and N21 at `:559` | doc |
| O7 | Gap headings read "has no roster row" | `records/lenses/gaps.md:19`, `:33` | both closed | doc |
| O8 | opt-census recorded green; PRB-81 cites `compile-back.chiral:271` | `problems.md:535`, `:607`, `:1147-1149` | red at HEAD; the wrap is at `:265-266` | doc |
| O9 | A malformed lens row "fails the same gate"; a lint check "fails [OVERVIEW] stale" | `docs/decisions/decision-four-lenses.md:131-137`; `records/lenses/README.md` | ledger-lint is wired nowhere and exits 1 | doc |
| O10 | Checks "live in prog/prose-lint.prog"; the per-line reporter runs a smaller set; baseline figures disagree | `tools/prose-lint/README.md:6-8`, `:84-90`, `:37`, `:116`, `:121`; `tone.md:26`, `:127`, `:132` | `prose-lint.sh` matches with awk and names no `.prog`. PRB-28 unified the check table (`prose-lint.sh:81-85`). The em-dash baseline appears as 17,533, 18,678 and 18,415. The TSV holds 521 rows summing to 23,279 against "23,231 across 515". | doc |
| O11 | Phase list, root count, known-fail count and fixtures are stale | `tools/test/MIGRATION-NOTES.md:17`, `:19`, `:142-144`, `:164-168`, `:172` | `run-tests.sh:173` has 3 KNOWN_FAIL; 96 compiled; fixtures present | doc |

### Code, behaviour

| id | what | where | evidence | tier |
|---|---|---|---|---|
| C1 | Census pins are stale; the gate is red and undispatched | `tools/test/opt-census.sh:143-147`, `:5` | exit 1; live 1562/1531/31, defs 1532 | code |
| C2 | The suite tally drops `N ok, M FAIL` phases, and the headline says 0 failed beside three FAILs | `run-tests.sh:134-138`, `:441` | `gate-run.log:682`, `:734`, `:750`, `:998` | code |
| C3 | R6 rows depend on git history: red in a shallow clone, with mutants skipped | `apply-word.sh:114`, `defunc-blame.sh:152`, `apply-spine.sh:122-126` | `git rev-parse --is-shallow-repository` returns `true` | code |
| C4 | AH skips `unminted` rows, which is where designed rows live | `ledger-lint.py:2339-2341` | no live violation today | code |
| C5 | No OVERVIEW staleness check exists | `ledger-lint.py:2699-2700` | `lens.py overview --check` exits 1 | code |

### Code, comments and headers

| id | what | where | evidence | tier |
|---|---|---|---|---|
| K1 | tal-check "exits 1 at 20 ok, 1 FAIL on G18" and check.chiral "has ENTERED the compiler closure"; the phase-22 claim is retired at `:5` and declared at `:14` | `tal-check.sh:5-14`; `run-tests.sh:356-360` | `21 ok, 0 FAIL`; 0 `def ck-prog` in the blob | comment |
| K2 | Dispatched gates call themselves UNREGISTERED | `apply-word.sh:5-7` (cites `run-tests.sh:332`), `capture-fields.sh:6-7`, `defunc-blame.sh:4-7`, `apply-spine.sh:5-8`, `crypto.sh:5-7`; banners of phases 25-30 | `run-tests.sh:361-367` dispatches them | comment |
| K3 | Header phase map stops at 24; comment says all sub-script tallies are added and Phase 7 roots are tallied | `run-tests.sh:11-36`, `:118-120`, `:436-437` | `:199-207` says Phase 7 is not tallied; phases 25-37 are dispatched | comment |
| K4 | "Three dispatched phases source this file"; "GA-01 is the open row" | `mutant.sh:162-163`, `:21-23` | five scripts; GA-01 RETIRED | comment |
| K5 | "Judg's 36 arms" | `lib/typing/diag.chiral:33` | 38 | comment |
| K6 | Invariant names `tests/test_effectful_lowering`, `test_e76` and `native.py` | `lib/lowering/tal/crossing-wraps.chiral:8-10` | no `tests/` directory; the Python oracle is CUT (`bin/chirality:15-18`) | comment |
| K7 | "TWO divergent check sets"; `cmd_lines` at `:164` | `tools/test/matcher.sh:57-68` | one table; `cmd_lines` is at `prose-lint.sh:186` | comment |
| K8 | The docstring check list enumerates A, B, C and names `docs/status-ledger.md` and `scaffold/` | `ledger-lint.py:9-16` | 40 checks registered at `:2757-2796` | comment |

### Corrections to the slice reports (verifier verdict: drifted)

- N12's Q9 is at `enforcement-N12.md:198`. The reader said `:200`.
- The DEFERRED rule is quoted in EN-38. `.claude/skills/element-design/SKILL.md:122` is blank.
- The floor line counts are at arc `:1246`, `:1254` and `:1258`/`:1260`. The reader was one line off each.
- Goal condition 2's missing rows are real. EN-36 says the goal needed nothing, so no record lists it as owed.
- N18's stale citations cover more sites than the reader listed. P16 and P17 give the full sets.
- On which rows a dispatched phase gates: N7 and N8 also have none, since their gates (`opt-census.sh`, `tal-check.sh`) are not dispatched. So 21 of 27 rows have no dispatched gate.
- Only `transport.sh` declares no mutant. Phases 1, 2 and 7 are the reader's observation.
- The condition-5 figure sits at `goal:48`, inside the paragraph `:46-53`.
- 5 unreviewed author-call rows name N15, N16 or N25 (`:538-542`). The reader said 7.
- 10 unreviewed rows name `goals/enforcement` or an `enforcement/N` row (`:84`, `:94`, `:98`, `:99`, `:113`, `:538-542`). The reader said 8.

## 9. Author calls owed on this arc

`python3 tools/ledger-lint/ledger-lint.py --only AK` reports 51 unreviewed rows tree-wide. By grep, 16 of them mention "enforcement", and 10 name `goals/enforcement` or an `enforcement/N` row.

| where | question | blocks |
|---|---|---|
| `author-calls.md:84` | Does decision-preserve-check's tier line move off `ttype`? | N13, N14. N14 calls itself settled; the row is still `unreviewed`. |
| `:85` | E184's six spelling decisions | Nothing live. The body records them closed, so the row can close. |
| `:86` | Does a created definition, and an origin that survives, take one fate arm or two? | E184 SPEC Step 9 (SPEC:389-391) |
| `:94` | Does the goal get a sixth condition, for memory safety? | goal scope; N18 |
| `:96` | Is a clamp an enforcement outcome, or does it hide the bounds class? | N18; E176 |
| `:97` | Clamp or trap at `nb-bslice-t` (owned by diagnostics/L5) | E176; affects N18, N21 |
| `:98` | Does the typed-assembly floor owe a bounds obligation? | N19's branch |
| `:99` | Does condition 4 quantify over gate rows or over bug classes? | N21 scope; N11 Q4 |
| `:113` | Where does the fixpoint compare's phase sit? | the build rule has no gate until this is ruled |
| `:118` | May a quantity-0 static value be lifted into emitted code? | no roster row holds it |
| `:119` | Which arc owns the region class (E22, E41)? | the arc's scope |
| `:538` | How are the effect row and the linear arrow written (with CK20)? | N25 |
| `:539` | What does a bare `=>` mean under effect rows? | N25 |
| `:540` | N15's discharge for `tal-ty=?`: B, C (recommended) or D | N15 |
| `:541` | Does N15 also remove the empty-argument-list wildcard? | N15 |
| `:542` | Does N16 split dispatch domains by type, or state the coarsening as a costed choice? | N16 |
| no register row | N10 Q5-Q7: native judges before J1; new gates native; how the retained constants bucket counts (`N10.md:275-277`) | N10 |
| no register row | N11 Q5-Q7: must the witness be native; is cost admissible on `no-mutant:`; does the witness land red or with 34+ rows declared OWED (`N11.md:254-256`) | N11 |
| no register row | N12 Q8: pin invariants or whole counts (`N12.md:197`, shared with E201 R2) | N12; how opt-census gets re-pinned |
| no register row | N13 Q3: T1 over every lowered definition, or over a counted corpus reach (`N13.md:245`) | N13 |
| no register row | J1 formulation-distinctness criterion (`decision-formulation-distinctness.md`, draft) | N10; the 210 gate-tier judgments |
| `:120` (dissolved) | The author's veto over `decision-floor-check-per-compile.md`, still `status: draft` | N8, N12, goal condition 3 |
| E184 SPEC, decision C | R7 conservation as a checked fold or as a linear obligation | E184; carried open |
| no register row | Whether gates may depend on git history; whether `mutant.sh --matrix` gets a phase (PRB-55); `shape-census.sh` R2; whether ledger-lint, `prose-lint --regress` or `overview --check` become phases | process |

Already ruled, for context:

| row | ruling |
|---|---|
| `:72` | the band is spent |
| `:73` | phase-number rule |
| `:87` | fate domain |
| `:88` | the partition |
| `:95` | bounds class belongs to both arcs |
| `:117` | value check: the gate now, the in-compile check scheduled; three preconditions left open |
| `:537` | E39 is homed on this arc |

Registering `tal-check.sh` needs no author call: `:73` already rules its number.

## 10. Where to resume

**The arc's own next row is spent.** The newest resume entry names element-design on N25 (`arc:600-608`). N25 was designed later the same day (`d465f67`) and is blocked on `:538-539`. The entry before that, design-to-spec on E184 (`arc:681`), is spent too, because the SPEC exists. The freshest plan in the tree is the agent-tier queue at `.planning/DISPATCH-QUEUE.md:79-91`:

1. finish designing N17, N19, N21 and N22;
2. fold the unrostered needs into the roster (queue item E4);
3. settle author calls one at a time;
4. run the design audits.

**Critical path across rows.** Goal condition 3 has the longest chain, with an author act at its head and two unrostered preconditions in its middle:

| chain | stages |
|---|---|
| condition 3 (requirements 2 and 4) | Author lets `decision-floor-check-per-compile` stand → N12 revisited (Q9 dissolved) and Q8 reconciled → N12 minted and built, its census gate registered → N8, the per-compile checker process. For a verdict to mean preservation, N15 (`:540-541`) and N17 (element-design) come first, and N13 (T1) needs the `eval-prim` repair and the `interp.chiral` repair. Neither repair has a roster row. |
| requirement 7 | Roster the `eval-prim` and literal-table row → build it (three missing comparison arms at `eval.chiral:86-95`) → N23 revisited against `:117`, audited, minted → N7, so `dead` can return. N24 runs in parallel: audit, then mint. |
| requirement 1 | E184 SPEC audit → build, with Step 9 on `:86`; N22 design → N18 (`:94`, `:96`); N25 (`:538-539`) → N9/E70 and memory-discipline/M9; N20/E198 design-to-spec. |
| requirements 5 and 6 | J1 ruled → N10 (Q5-Q7) → N11, if Q5 rules the witness native; N21 on `:99`. |
| requirement 4, second branch | One sentence at `ledger.md:135`. |

**Ranked next moves:**

1. **Make the gating floor honest in any checkout.** This means four things:
   - repair the tally at `run-tests.sh:134-138` so a phase printing `N ok, M FAIL` is counted, or fails when it prints no parseable tally;
   - make the R6 base binaries independent of clone depth, by fetching them on demand or by unshallowing in the environment setup;
   - register `tal-check.sh` at the first free number under `author-calls.md:73`;
   - re-pin `opt-census.sh`, noting that whole-count pins are N12 Q8's open question.

   *Reason:* every ENFORCED claim on this arc is a claim about this suite. Today it prints `0 failed` beside three FAIL rows, turns red in a default cloud checkout, skips 15 mutants there, and leaves both floor gates outside dispatch: one green and unrun, one red and unseen. No author call blocks the first three parts.
2. **Hold one author sitting on the blocking calls.** Start with `:538-542`, then `:94`, `:96`, `:98` and `:99`, and first write register rows for the eight unregistered NEEDS-AUTHOR (N10 Q5-Q7, N11 Q5-Q7, N12 Q8, N13 Q3) and for J1.

   *Reason:* nine of the eleven designed parts are `status: blocked` (`grep -H '^status:' docs/arcs/parts/enforcement-N*.md`). Five of their calls are already one-line register rows. N25, the arc's named next row, needs two of them. The eight unregistered calls are invisible to ledger-lint AK until they have rows.
3. **Run one arc revisit that brings the arc, goal and status ledger up to the tree**, including E17's why-not sentence.

   *Reason:* `ledger.md:135` is the whole of requirement 4's second branch, so one sentence closes a branch of a requirement. The same pass:
   - lifts N23's and N12's blocks (`:117` ruled, `:120` dissolved);
   - cites the draft decision that resolves condition 3 (G7);
   - corrects the resume pointer every session starts from (A6, A7);
   - moves the status-ledger rows that condition 1 is measured on (S1-S7).

Work ready without the author after those three:

- DESIGN audit of N24, then `pack.py --mint`. N24 is the one designed row with nothing blocking it.
- DESIGN audit of N14, expecting the fixes P5, P6, P7 and P15.
- SPEC audit of E184, with a phase number other than 33.
- design-to-spec on E198, with 35 externs, a 16/3/16 split and 30 `native-lib` entries.

## 11. Limits of this orientation

- **Slices lost:** none. The verification tally is 240 held, 10 drifted, 1 false, 0 unverifiable.
- **Figures that rest on probes nobody re-ran:**
  - EN-08 to EN-14's class split (the probe was reverted);
  - EN-24's 33 passed, 9 failed for `dead` on `row.sh`;
  - N12's `ck-prog` acceptance of 1,549 of 1,549;
  - N16's dispatcher probe;
  - N11's 441 and 491 row totals;
  - N14's `term->ntalty` figures;
  - N15's 955 of 1,531;
  - the census at `d47f5ce^` (one reader, and N12's design);
  - the 68 element-ledger rows at `design` (one reader).
- **Shallow clone.** HEAD 2faa028 has 50 commits back to the graft `8ee3627`. Commits the documents cite from before it cannot be resolved here, including `b613a8f`, `38ecdba`, `8d4009d`, `30b288b`, `21e1b28` and `4caf5f0`. 157 of the 232 ledger-lint AI findings rest on files that only the graft touches. Phases 25, 27 and 28 were confirmed green only with base binaries fetched from a blobless clone.
- **Unmeasurable.** The 240-invocation figure (`goal:63-76`) cannot be re-taken, because its scanner is untracked.
- **Unresolved from the slices:**
  - Whether E184 SPEC Step 10 is gated. `SPEC:389-391` names Step 9 as gated and lists Steps 1-8 and 11 as independent.
  - N16's §6 kind cell.
  - Pass counts for phases 4 and 5 outside the suite log.
- **Not read:**
  - the arc's prose outside the roster, the resume state and `:783-1285`;
  - SPECs other than E184, E171, E187 and E204;
  - the independent-judgment arc beyond J1's draft;
  - `banks/port` Shard 3;
  - whether the lens rows and the author-call register overlap.
- **Tree state.** `git status --short` is empty at 2faa028. No slice wrote to the tree.
- **Cost of this pass, from wall clock:**
  - two full suite runs at 4m31.146s and 4m32.834s (about 4m06s user each), one of which duplicated the other across slices;
  - the mutant matrix, 1m59s;
  - membrane.sh 47s and extern-honesty.sh 33s to 40s;
  - the self-compile about 1s; tal-check about 1s; opt-census about 2s per run;
  - the gate-tier reader's own total, about 7.5 minutes.

  Token usage is not visible from inside a slice, and this document does not report it.