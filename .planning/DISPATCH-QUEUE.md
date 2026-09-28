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
| 1 | the three vacuous `ledger-lint` checks, H, M and AM: diagnose, fix AM at its cost, repoint H, and record | self-verification, `baseline-alignment/AL1` | `tools/xlat/xlat.sh`, `tools/ledger-lint/ledger-lint.py`, one `PRB` row |

## Queued, in order

| # | run | serves | waits on |
|---|---|---|---|
| 2 | the committed census predicate as a check, so the 76, 47 and 29 figures reproduce | error handling, `errors-as-values/EV12` (`E201`) | nothing |
| 3 | audit `EV1`'s design, then design `EV2` | error handling | nothing |
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
| `EV3`, condition 1 over the whole tree or the compiler only | run 8 |
| the `CRY` band, or mint next free under the 2026-09-06 ruling that bands are advisory | `K2`'s mint in run 4 |
| the three file-types calls: facet mapping, mint shape, module key | `file-types/K1` to `K3` |

## Done

none yet.
