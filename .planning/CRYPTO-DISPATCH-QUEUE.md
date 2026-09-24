# Crypto dispatch queue

Serial. One agent at a time, per `docs/decisions/decision-dispatch-cadence.md` and
`.planning/protocol/dispatch.md`. The next stage goes out after the previous one
has returned, been verified and been committed.

⚑ **Opened 2026-09-23 after a violation.** Two agents were dispatched live at
once, the second was stopped, and this file exists so the queue is a tracked
object rather than something a session holds in its head.

## Running

| # | run | writes | dispatched |
|---|---|---|---|
| 1 | route the eight unowned defects found 2026-09-21 to 2026-09-23 | `records/lenses/`, `records/findings.md` | 2026-09-23 |

## Queued, in order

| # | run | skill | writes |
|---|---|---|---|
| 2 | the six design conclusions from the 2026-09-23 discussion | capture | `.planning/MARK-AND-HANDLE-DISCUSSION.md` |
| 3 | gate `K2` before it mints | `pipeline-audit` DESIGN | `docs/arcs/parts/crypto-primitives-K2.md` |
| 4 | where a mark actually appears on the wire, and what a 64-byte mark does to §12's budget | `research` | an `FD` row |
| 5 | the gather for `K1` | `research` | `.planning/sources/keccak-p.gather` |
| 6 | write the Keccak translation | `translate` | `docs/translations/keccak-p.md` |
| 7 | gate the AEAD translation, on a level that has never run against real work | `pipeline-audit` TRANSLATE | `docs/translations/aead-chacha20-poly1305.md` |
| 8 | six `REACHES` documents the census found, one walk each | `revisit` | the crypto roster |
| 9 | `goals/password-manager` conditions 1, 4, 3, 2 | `arc-open` | one arc per condition |
| 10 | retag every attack axis security against obfuscation, two ceilings each | `revisit` | `.planning/ROUTE-ATTACK-AXES.md` |

## Blocked on the author

`K2` cannot mint until the `CRY` band question is answered, which makes it a gate
on run 3's exit rather than on its start.

| # | the call | blocks |
|---|---|---|
| 1 | the `CRY` band: adopt `E114`-`E119`, or mint next free and correct the ledger | `K2`'s mint |
| 2 | `C2`, Ascon-p an instance or a second design | carried non-blocking by `K2` |
| 3 | `C6`, constant time before or after the kernels | answered by default if kernels land first |
| 4 | the digest width, 32 against 64 | run 4 researches it |
| 5 | `T13`, one design or two | the same fork from the other side |
| 6 | `T7`, Keccak-f[25] a real module or test-only | `K16` |
| 7 | `C7`, vectors as declared data. Implies the first category B under category C, which is not crypto work | `K24`, and an arc that does not exist |
| 8 | `N10`'s boundary | who owns the post-quantum re-scope |

## What is not in this queue and is owed

The reach layer has no arc file, so nothing in `.planning/REACH-MODEL.md` can be
rostered. Every finding against it since 2026-09-21 has come back with no home:
the replay cache, the tether exposures, the tag rotation schedule, the
cross-process linkage axis.
