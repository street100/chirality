# Dispatch queue

Serial. One agent at a time, per `docs/decisions/decision-dispatch-cadence.md` and
`.planning/protocol/dispatch.md`. The next run goes out after the previous one has
returned, been verified and been committed.

Opened 2026-09-28 from the author's priority order for what makes an outside
reader look at this tree, most important first: self-verification, error
handling, crypto, text tools, file types. `.planning/CRYPTO-DISPATCH-QUEUE.md`
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

| # | run | serves | writes |
|---|---|---|---|
| E1 | research: checked-optimization designs (nanopass, `cp0`, partial evaluation and staging, translation validation, allocation fast paths), each with its correctness obligation in chirality | enforcement, speed as checked rewrites | pins, one `FD` row |

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
| E2 | `revisit` `docs/arcs/enforcement-arc.md` against the 2026-09-29 direction: the speed rows as checked rewrites, reconciled with emitted-speed's `X10` to `X12`, which that arc keeps | E1 |
| E3 | `element-design` on each unminted, undesigned row, one run each: `N10`, `N11`, `N12`, `N13`, `N15`, `N16`, `N17`, `N19`, `N21`, `N22`, then every row E2 adds | E2 |
| E4 | `revisit` folding every "needed and unrostered" discovery from E3 into the roster, then a design for each new row. Repeats until a pass adds nothing | E3 |
| E5 | reconcile the enforcement calls: the register rows at `records/author-calls.md` 83, 84, 85, 93, 95, 96, 97 and 98, then every call E3 and E4 raise | E4 |

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
| `E201` pin R2: it pins all fourteen readings whole, so almost any new `def` under `lib/` or `prog/` turns the suite red until someone re-reads the pin. Recommended: R2 pins only what a requirement gates, and the other readings print and are cited by date | registering phase 34 |
| the reader's depth guard: `MAX-DEPTH` at `lib/surface/sexp.chiral:44` is read by nothing, so a file nested past it crashes the reader. A defect to route, owed a `PRB` row | nobody yet |
| check AM: what counts as a quoted standard, any line naming it or only the pin-citation form. A standard written with a space is never gated today, `PRB-99` | closing `PRB-99` |

## Done

| # | run | landed |
|---|---|---|
| 3a | `E202` SPEC, phase 35, four census readings move | `dcb2b6d` |
| fix | the suite was red from `4e9649f`, a gate committed without its phase. The gate now declares itself out until R2 is ruled | `90e9b4d` |
| 3 | `EV1` design audit PASS, eleven corrections, every wide-rule figure reproduced off `E201`. Minted `E202`, `Result` | `70c0191` |
| 2c | check AL fails when `xlat check` reaches no verdict, three mutants run | `fe5fd88` |
| 2d | `E201` built: register, instrument, fixtures and gate, 14 passed against the real index. Bare `Str` error arms read 33 where the arc said 30, a `Str` anywhere 49 where it said 47. Compiler blob unchanged. Not yet a suite phase | `4e9649f` |
| 2b | `E201` SPEC audit: PASS, nine corrections, the three EV3 flags carried as non-blocking | `edd9a6c` |
| 2 | `E201` SPEC: fifteen register rows, phase 34, six gate rows and eight mutants, the allowed count held as one ratchet-down value | `92a51b2` |
| 1 | check AM: `xlat unpinned` 2m37s to 2.5s, byte-identical to the old output, a pipefail race that let an unpinned quote pass removed, and a run that cannot finish now fails. Full `ledger-lint` 4m10s to 1m14s. H and M stay Vacuous on author calls | `fa4461a`, `PRB-99` |
