# Dispatch queue

Serial. One agent at a time, per `docs/decisions/decision-dispatch-cadence.md` and
`.planning/protocol/dispatch.md`. The next run goes out after the previous one has
returned, been verified and been committed.

Opened 2026-09-28 from the author's priority order for what makes an outside
reader look at this tree, most important first: self-verification, error
handling, crypto, text tools, file types. `.planning/archive/handoffs/CRYPTO-DISPATCH-QUEUE.md`
stays the history of the crypto runs, and its live runs are pulled in here so
there is one queue.

## How the author calls move

Author calls are the bottleneck: `ledger-lint` check AK counts 41 `unreviewed`
rows in `records/author-calls.md` on 2026-09-28. They go to the author as one
batch after the dispatch work in flight has finished. The author ruled that on 2026-09-28 because interleaving gets messy.

Each call in a batch opens with a plain summary: what the thing is in one line,
why it matters, the options in ordinary words, and a recommendation. Row ids and
line citations follow as reference. The author holds this project by intuition
and the tree is documented densely so a session can keep up, so the summary is
where a session bridges the two. A call answered in session is written to its
row the same turn.

## Running

The author gave a green light on 2026-09-29, *"dispatch next stages for all, green light"*, after three concurrent runs the same day. Two run at once: one writer over the tools and one read-only review. Writers over docs and arcs wait, because a tool fix checks the docs they would be writing.

| # | run | serves | writes |
|---|---|---|---|
| none | the queue resumes at `LE25` (name lookup through maps), design stage. FD-57 leaves its design one question: whether per-pass `Map Str` is later replaced by id-keyed maps, which would make it an improper split | | |
| KR1-KR4 | **a second session runs the crypto research pre-wave beside this queue, by the author's request, 2026-09-29:** *"id like if you could work parallel to the other active agent working on optimizations and enforcement"*. One agent live in that session at a time. It writes `.planning/sources/` pins and one `FD` row per run, never runs the suite, and leaves `records/findings.md` uncommitted while the author's FD-52 to FD-54 are. The list is in `docs/arcs/crypto-primitives-arc.md` §Resume state | crypto | `.planning/sources/`, `records/findings.md` |

## Next, in order

**Anything that runs the suite runs alone**, from 2026-09-29: three suite runs failed on Error 24 whenever a second agent was live. Only read-only work may overlap a run that does not touch the suite.

The author asked on 2026-09-29 for the language fixes to go one by one through the full pipeline, vertically, *"until precomputing"*, which the author holds for discussion. Order by measured cost from the profile: erase once and `lower-defs` cons-then-reverse; name lookup through a map; constructor tags once; `str-split` by index and a linear byte builder; word-wide byte compare and copy (checked rewrite); constants once, region reset, inlining (waits on the author's `emitted-speed-arc.md` edits), register-resident values.

| # | run | serves | waits on |
|---|---|---|---|
| next | DT-06 with DT-02, then DT-03, DT-06 with DT-02, DT-05, DT-11, DT-09 with DT-08, DT-10 with DT-13, DT-12, one at a time, from `.planning/DOC-TOOLSET-REVIEW-2026-09.md`. DT-07 waits on the author | tooling | `tools/ledger-lint/ledger-lint.py` |

## Earlier running rows

| # | run | serves | writes |
|---|---|---|---|
| D1 | **done**, see Done. The documentation toolset reviewed for capability, correctness and ergonomics, report only, changes dispatched after the author reads it. Third live agent, by the author's one-off exception, 2026-09-29: *"i honestly wouldnt mind if you also dispatched a few documentation toolset improvements in another agent (must orient and research and report before we dispatch again for changes)"* | tooling | `.planning/DOC-TOOLSET-REVIEW-2026-09.md` |
| O1 | optimization gaps, **stopped 2026-09-29 by an API safeguard (`reasoning_extraction`) right after the orchestrator asked it to narrate as it worked**; it wrote nothing. A re-run would log dated results into its artifact in place of narration, and waits on the author. The brief: the highest-value day-sized items in the test and compile process, specified and missed. **Run alongside V1 by the author's one-off exception, 2026-09-29:** *"You can dispatch this one alongside current the usage is a bit better and i want to test how heavy 2 will be on my limits"*. The serial rule stands otherwise | speed | `.planning/OPTIMIZATION-GAPS-2026-09.md` |

## Waves

The author ruled on 2026-09-29 that work moves in horizontal waves by stage:
*"first wave is research and premint with a major focus on fully outlining
everything when one element reveals another is needed and not captured. then we
can work on mint wave and etc"*. A wave is a stage swept across every row. Agents
stay serial, one live at a time.

| wave | stage | exits when |
|---|---|---|
| 1 | research, then `element-design` on every row with no design | no design names a need the roster does not hold |
| 1b | reconcile, `.planning/protocol/reconcile.md`: every call wave 1 raised and every register row naming the arc's rows, one per run, each `DISSOLVED` verdict followed by its adversarial check | every call reads `dissolved`, or `unreviewed` with a plain summary |
| 2 | mint: `pipeline-audit` DESIGN on every design | every design PASS or BLOCKED on a carried call |
| 3 | `design-to-spec` on every minted element | every minted element holds a SPEC |
| 4 | `pipeline-audit` SPEC | every SPEC PASS or BLOCKED |
| 5 | implement, one element at a time under the BUILD RULE | the suite is green on each |

Every design prompt asks for a "needed and unrostered" table in its residue and
forbids editing the roster. The discoveries are batched into one arc `revisit`,
and each new row takes its own design inside wave 1.

**Scope of the current wave run: the enforcement arc**, with the speed rows as
checked rewrites. Rows already minted before this wave (`N2` `E185`, `N6` `E16`,
`N7` `E17`, `N8` `E18`, `N9` `E70`, `N1` `E184`, `N20` `E198`) enter at wave 3.
`N14` and `N18` are designed and enter at wave 2.

### Wave 1, enforcement

The author's 2026-09-29 direction the enforcement wave serves: *"we need to be honest
by actually building everything to support goals, and we need to optimize pretty
bad"*, with speed rows added to the enforcement arc as checked rewrites.

| # | run | waits on |
|---|---|---|
| E3 | `element-design` on each unminted, undesigned row, one run each: `N23` (designed), `N24` (designed), `N10` (designed), `N11` (designed), `N12` (designed), `N13` (designed), `N15` (a run was stopped by the harness 2026-09-29 and left a partial file uncommitted; re-run after reconcile), `N16`, `N17`, `N19`, `N21`, `N22` | E2 |
| E4 | `revisit` folding every "needed and unrostered" discovery into its roster. Standing from E2: an interprocedural constant fact for `X10` (`docs/benchmarks/OPT-CANDIDATES-2026-09.md:80-81`, emitted-speed condition 3 has no arc), a lift form for a quantity-0 value (waits on `records/author-calls.md:117`), and a region profiler (`records/findings.md:1527`). From `N23`: `eval-prim` covering fold's ops and `dead`'s path, answering `r-err` for an unknown op, and a literal table in `tal-eval` (`lib/lowering/tal/eval.chiral:86-95`, `:131`), owed a row in this arc, and a condition holding the compiler's own time and memory (`goal-open` amendment of emitted-speed, the author's). From `N24`: fold's static case dispatch, its third rule (`lib/lowering/upper/optimize.chiral:57`, `:124-136`), has no rule-level check. From the coverage map, U1-U10 in `docs/definitions/verification-coverage.md` §needed (phases 29 and 30 never test the candidate; check P reads `[ok]` on a subject that appears in no file; nothing triggers L2 or L3; `prose-lint --regress` as a gate; totality by default; the effect rule per compile; the tal-evaluator cross-check; `ddc-fold` over verdicts with formulation in `Prov`; the alignment register; adequacy per pair of cores). From call 1's ruling: the in-compile half of `N23` and `N13`, on the map and queued, with its three preconditions (PRB-70's reach over `eval.chiral` and `interp.chiral`, a compile budget, type-drawn inputs as evidence) and `interp.chiral:68` made total. From `N10`: one gate port per script under its port rule; the build steps made native; the `prose-lint` switch that never happened (`tools/prose-lint/prose-lint.sh:86-113`, text-tools P1); `mkdir` and `unlink` crossings (zero-python); `run-filter` ignoring its input (`lib/runtime/proc.chiral:133-148`, tool-authority). From `N11`: the suite tally reads the five `N ok, M FAIL` phases or refuses a log with no tally (`tools/test/run-tests.sh:134-138`), 50 rows run uncounted; `mutant.sh`'s matrix under a phase (PRB-55); falsifiers for `profile-target.sh`'s 11 uncovered rows (PRB-56) and `linear-mint.sh`'s 22; the three held-out gates' mutants reach a run; E168's `Gate` carries one `MutRun` per gate (`lib/evidence/test-floor.chiral:641`). From `N12`: one compiler function returning the shipped pre-erase program, so no census measures a stale copy (`prog/optimizer-census.prog:153-163` against `lib/lowering/compile-back.chiral:252-274`, lowering-and-emit, inside the closure); each TFn's own signature checked equal to its source signature (`lib/lowering/tal/check.chiral:293-298`). From `N13`: `interp.chiral` gains globals, prims, strings, constructors by name and a case default (`lib/evidence/interp.chiral:17-20`, `:31-38`), and returns a closed result with fuel where it now returns `(v-lit -1)` (`:52`, `:58`, `:105`), lowering-and-emit beside `LE19`; the checked `Sig` returned beside the lowered program (`lib/lowering/compile-front.chiral:369-373`), extending `N12`'s item. Then every row E3 surfaces, and a design for each new row. Repeats until a pass adds nothing | E3 |
| V0 | call 2 is paused: its register row reads `dissolved` by derivation (`ad95e20`), and the author has since said *"yes the tests count as the compiler checking itself"*, with self-verification proper coming from distinct judgment cores and their alignment, *"including where everything should agree and where not everything should"*. The row is left as it stands until the map lands and the author rules | V1 |
| E5 | reconcile, one call per run, in this order, as the author asked on 2026-09-29 (*"serially research and present updated summaries ... reseach against principles properly to filter for correct approaches"*). Each `DISSOLVED` is followed by its check run, and a call that needs a source gets a research run first. Order: 1 where the value check runs (`:116`); 2 whether a gate-side `ck-prog` discharges `N8` and goal condition 3; 3 census gates pin invariants or whole counts (`E201`, `N12`); 4 `N10`'s three; 5 `N11`'s three; 6 T1 over every definition or a counted reach; 7 lifting a quantity-0 value (`:117`); 8 a goal condition for the compiler's own time and memory; 9 the preserve-check tier line (`:83`) and the region owner (`:118`); 10 the fixpoint compare (`:112`); 11 `J1`; 12 `EV3` (`:52`); 13-15 checks H, M and AM; 16 `K2`'s number; 17 the three file-type calls. Calls held only in a design artifact get a register row first. **One at a time with the author**, ruled 2026-09-29: *"we'll go 1 by 1 too i need to make final call on each one before we move on"*. Each call's result goes to the author when it returns, and the next call waits for the author's ruling | E4 |

## Held from before the waves

These keep their order and join a wave when their arc's turn comes.

| # | run | serves | waits on |
|---|---|---|---|
| 2e | register `E201` as phase 34, and flip `EV12` to `built`. The diff is built and held, saved outside the tree | error handling | the R2 call below |
| 2f | `revisit` `docs/arcs/parts/errors-as-values-EV12.md` §4b: a file past `MAX-DEPTH` is read and counted, and the design says it errors | error handling | nothing |
| 3c | `E202` SPEC audit, then implement. The SPEC's done-when names a red suite that `90e9b4d` repaired | error handling | nothing |
| 3e | `revisit` `E201`'s register so its arm-name rule reads `res-val` and `res-why` before any boundary adopts `Result` | error handling | before run 8 |
| 3b | design `EV2`, `bind` and `map-err` over `E202`'s type | error handling | nothing |
| 3d | amend `docs/arcs/errors-as-values-arc.md` to the `E201` readings: its 76, 47, 30 and 202 are hand counts, and requirement 5 reads 30 where the committed predicate reads 33 | error handling | nothing |
| 4 | gate `K2` before it mints (was crypto queue 4b) | crypto | nothing for the audit, the `CRY` band for the mint |
| 5 | write the Keccak translation, off the gather `9a46243` ran (was crypto queue 6) | crypto, `crypto-primitives/K1` | nothing |
| 6 | `K2` spec and build, then `K3` and `K4`: one permutation, and hash, XOF, MAC and KDF as configurations of it | crypto | run 4, run 5 |
| 7 | differential of `prog/paren-audit.prog` against `tools/paren-audit/paren-audit.py`, then retire the Python (`PRB-60`). Then `prog/resolve.prog` (`PRB-59`) | text tools | nothing |
| 8 | `EV5`, `lib/protocol/apc.chiral`, the first adoption outside the compiler's closure | error handling | `EV3` |
| 9 | design `independent-judgment/J2` and `J5` | self-verification | `J1` |
| 10 | `file-types/E1`, the five emitters return `Doc` | file types | nothing |
| 11 | `README.md`'s suite figures: it reads 321 assertions and 87 roots from 2026-09-01, and the suite measured 441 and 95 on 2026-09-28 | presentability | nothing |

## Paused

Crypto queue runs 2, 4, 8, 9, 10, 12 and the open half of 13. Each widens the
crypto roster or walks `.planning/REACH-MODEL.md` against it, and the roster grew
from 25 rows to 36 between 2026-09-07 and 2026-09-22 with no module built. They
resume when `K4` is built.

## Owed to the author, blocking the queue

| call | blocks |
|---|---|
| `records/author-calls.md` the fixpoint phase call: the author read the compare as a manual step of the BUILD RULE on 2026-09-28, unconfirmed | `lowering-and-emit/LE24` |
| `J1`, ratify `docs/decisions/decision-formulation-distinctness.md` §3 | run 9 |
| `EV3`, condition 1 over the whole tree or the compiler only. The E201 SPEC splits it three ways: which predicate the ruling binds (any `Str` in the error arm, or a bare `Str`), whether the allowed count is the total or the outside-closure one, and whether EV1's wide arm-name rule is the intended one | run 8, and `E201`'s allowed value |
| the `CRY` band, or mint next free under the 2026-09-06 ruling that bands are advisory | `K2`'s mint in run 4 |
| the three file-types calls: facet mapping, mint shape, module key | `file-types/K1` to `K3` |
| check H: the not-equal operator is spelled `<>` or `!=`, and whether `op->symop` refuses a token it does not know. `lib/module/loader.chiral:20` reads any unknown token as not-equal | repointing H |
| check M: repoint it at one resolver root shadowing another, or delete it | M |
| does a census gate pin invariants or whole counts. `E201`'s R2 pins all fourteen readings whole, so almost any new `def` under `lib/` or `prog/` turns the suite red until someone re-reads the pin. `N12` faces the same question. Recommended for both: pin what a requirement gates, and print the other readings to be cited by date. No register row holds it yet | registering `E201` at phase 34, and `N12` |
| `95e8043` cites `FD-55` at working-tree line numbers in `records/findings.md`, which resolve only while the author's FD-52 to FD-54 are uncommitted. Repoint by id, or re-check once the author commits | nobody, clerical |
| the reader's depth guard: `MAX-DEPTH` at `lib/surface/sexp.chiral:44` is read by nothing, so a file nested past it crashes the reader. A defect to route, owed a `PRB` row | nobody yet |
| check AM: what counts as a quoted standard, any line naming it or only the pin-citation form. A standard written with a space is never gated today, `PRB-99` | closing `PRB-99` |

## Done

| # | run | landed |
|---|---|---|
| LE27 | `E203`, each function erased once: designed, audited PASS, minted, built `direct`. `C1 == C2`, C2 on HEAD's blob reproduced the old binary, suite alone 441 and 96 roots, phases 29 and 30 with `CC`. Self-compile 0.79 s to 0.73 s, 358 to 331 MiB. Agents: 92k, 87k, 63k tokens | this commit |
| R3 | text-tools RESCOPE against FD-56: requirement 5 (fastest published total algorithm), row `P5` (derivative automaton over a pattern list, literal prefilter, lazy fixed-capacity cache), record TT-02, one call registered (the cache capacity, a number only the author sets). AK 43 to 44, 252 violations unchanged | this commit |
| R2 | compute primitives research, FD-57, 25 pins. Constant division by `mulhu` (`A22`), `INT64_MIN` through an unsigned magnitude (PRB-78), word-wide compare and copy inside the 8-byte cell rounding, bit ops waiting on a unary IR form and a stated x86-64 level no document names. Hashing: a pure pass holds no seed, so an ordered map keeps the log bound, and interning is the faster shape. Open for `LE25`'s design: whether per-pass `Map Str` is later replaced by id-keyed maps, which would make it an improper split | this commit |
| R1 | text primitives research | `3022b41`, FD-56 |
| LE28 | `lower-defs` conses and reverses once. `C1 == C2`, C2 on HEAD's blob reproduced the old binary, the suite passed alone on C2 (441, 96 roots), phases 29 and 30 passed with `CC` exported. Self-compile 0.81 s to 0.79 s, 385 to 358 MiB. Row set `direct` | this commit |
| O1b | optimization gaps: 13 day-sized items, 11 never specified. `ledger-lint` F and AI memoized would take the lint from about 95 s to 10 s; Phase 7's subshell discards the resolver cache; items 2 to 6 take the suite from about 357 s to 265 s. The optimization items wait on the author's pick | `.planning/OPTIMIZATION-GAPS-2026-09.md` |
| DT-04 | `ledger-lint` exit codes 4, 3, 1, 2, 0; a check that cannot run errors; T, P, U, AD, Z, AI, S and ten more read their real subject. 231 to 238, then 236 after two moved citations were repointed. ⚑ Two agents running at once hit the VM's open-file limit (Error 24); the DT-04 run cleared it with a VM-wide cache drop, and the optimization run tried the same and was denied | `16afd16` |
| DT-01 | `pack.py` bundles are read-only, `--start` writes, one forward-only roster table, `--reopen` for REOPEN, unknown flags refused. Owed: `decision-design-before-mint.md:144-149` and `tools/README.md:16` describe the old default | `460ed88` |
| V1 | the verification coverage map, `docs/definitions/verification-coverage.md`, draft: four layers, 39 checks, L1 runs 3 of 14 owed-or-run, L2 1 of 22, L3 2 of 10, L4 none of 16. Ten questions for the author and ten discoveries (U1-U10). Verified U1: `run-tests.sh` never exports `CC`, so phases 29 and 30 test `bin/chirality-bin` whatever candidate is chosen | `a9dfb01` |
| E3f | `N13` designed, `status: blocked` on three calls: T1 reads the checked `Sig` through a bridge into `interp`'s own `Term`, adopts `E169` half (a), shares corpus and verdict with `N23`. Neither evaluator can run what it judges yet | `acc4455` |
| E3e | `N12` designed, `status: blocked` on two calls: the compiler's output accepts whole, 1,549 TFns and 38,333 across every root, and `opt-census`'s 31 refusals were its own. `opt-census.sh` is red at HEAD, held out | `d08013b` |
| E3d | `N11` designed, `status: blocked` on three author questions: trace lines per mutant and a witness that folds them. At least 34 counted rows have no run mutant, and the suite's 441 omits 50 rows that run | `644fc8d` |
| E3c | `N10` designed, `status: blocked` on three author questions: a native judge floor built by the promoted binary, a native registration witness, and a port rule where shell and native agree row by row before one commit switches and deletes | `87b41e6` |
| E3b | `N24` designed: each fold rule checked once against a bash reference from the definition, over eight operands including the imm32 edges, nine mutants, about 20 s as a phase, nothing in the closure. For the audit: its `mach.chiral:1005-1013` means `lib/lowering/x64/mach.chiral`, and three files carry that name | `15b80fa` |
| E3a | `N23` designed, `status: blocked` on the placement call. `eval-prim` returns a made-up `0` for 35 of 40 lowered ops, so both sides of a rewrite agree on it. Self-compile 0.78 s, 394 MB | `ef3b1ba` |
| L0 | lowering-and-emit RESCOPE: requirement 7 and `LE25` to `LE30`, the compiler's own passes | `cfc7add` |
| E2 | enforcement RESCOPE: requirement 7, rows `N23` (per-rewrite value check) and `N24` (each fold arm checked once), `N7` amended so `dead` re-enters only under `N23`. Three calls registered, AK 40 to 43. `docs/arcs/README.md:165` is stale and sits in the author's dirty file | `95e8043` |
| E1 | `FD-55`: every checked-rewrite design pays for its check per pass, once, or per compile, and each lands on a row the tree holds. Beating C by precomputing has evidence on general programs a generator specializes. Committed without the author's uncommitted FD-52 to FD-54 | `3bf4fa7` |
| 3a | `E202` SPEC, phase 35, four census readings move | `dcb2b6d` |
| fix | the suite was red from `4e9649f`, a gate committed without its phase. The gate now declares itself out until R2 is ruled | `90e9b4d` |
| 3 | `EV1` design audit PASS, eleven corrections, every wide-rule figure reproduced off `E201`. Minted `E202`, `Result` | `70c0191` |
| 2c | check AL fails when `xlat check` reaches no verdict, three mutants run | `fe5fd88` |
| 2d | `E201` built: register, instrument, fixtures and gate, 14 passed against the real index. Bare `Str` error arms read 33 where the arc said 30, a `Str` anywhere 49 where it said 47. Compiler blob unchanged. Not yet a suite phase | `4e9649f` |
| 2b | `E201` SPEC audit: PASS, nine corrections, the three EV3 flags carried as non-blocking | `edd9a6c` |
| 2 | `E201` SPEC: fifteen register rows, phase 34, six gate rows and eight mutants, the allowed count held as one ratchet-down value | `92a51b2` |
| 1 | check AM: `xlat unpinned` 2m37s to 2.5s, byte-identical to the old output, a pipefail race that let an unpinned quote pass removed, and a run that cannot finish now fails. Full `ledger-lint` 4m10s to 1m14s. H and M stay Vacuous on author calls | `fa4461a`, `PRB-99` |
