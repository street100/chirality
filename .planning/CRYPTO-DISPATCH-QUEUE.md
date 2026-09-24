# Crypto dispatch queue

Serial. One agent at a time, per `docs/decisions/decision-dispatch-cadence.md` and
`.planning/protocol/dispatch.md`. The next stage goes out after the previous one
has returned, been verified and been committed.

⚑ **Opened 2026-09-23 after a violation.** Two agents were dispatched live at
once, the second was stopped, and this file exists so the queue is a tracked
object rather than something a session holds in its head.

## Running

none.

## Done

| # | run | landed |
|---|---|---|
| 1 | route the eight unowned defects found 2026-09-21 to 2026-09-23 | `285c219` |
| 13b | whether randomized hashing reaches content addressing. **FD-52.** It does not: eTCR's adversary commits before the key is sampled, Halevi-Krawczyk answer the publisher case with a liability rule, and NIST states it as a limit. Chunk and leaf binding separates domains and raises no bound. The one context-bound content address buys it with an issuer | pins at `8bdb033`; `FD-52` in the author's tree |
| 3 | the post-quantum sizes, pinned to FIPS 203, 204, 205 and the FALCON spec. **FD-50.** The radio profile fits classically with 110 B of slack, and is unreachable under PQ at every parameter set: ML-KEM-512's 768 B ciphertext alone is 268 B past the whole 500 B MTU. **A 64-byte mark moves no profile total** | pins committed; `FD-50` left in the author's working tree |

## Queued, in order

| # | run | skill | writes |
|---|---|---|---|
| 2 | the six design conclusions from the 2026-09-23 discussion | capture | `.planning/MARK-AND-HANDLE-DISCUSSION.md` |
| ~~3~~ | done, see above. **replace the remembered post-quantum sizes with pinned ones.** `.planning/REACH-MODEL.md:528-533` carries ML-KEM-768, ML-DSA-65, FALCON-512, SLH-DSA and X25519 from memory, and the wire budget and the 1.1 KB wall rest on them. Reordered ahead of the budget work 2026-09-24, because that work would otherwise compute against remembered numbers | `research` | an `FD` row |
| 4 | where a mark actually appears on the wire, and what a 64-byte mark does to §12's budget, against run 3's pinned figures | `research` | an `FD` row |
| 4b | gate `K2` before it mints | `pipeline-audit` DESIGN | `docs/arcs/parts/crypto-primitives-K2.md` |
| 5 | the gather for `K1` | `research` | `.planning/sources/keccak-p.gather` |
| 6 | write the Keccak translation | `translate` | `docs/translations/keccak-p.md` |
| 7 | gate the AEAD translation, on a level that has never run against real work | `pipeline-audit` TRANSLATE | `docs/translations/aead-chacha20-poly1305.md` |
| 8 | six `REACHES` documents the census found, one walk each | `revisit` | the crypto roster |
| 9 | `goals/password-manager` conditions 1, 4, 3, 2 | `arc-open` | one arc per condition |
| 10 | retag every attack axis security against obfuscation, two ceilings each | `revisit` | `.planning/ROUTE-ATTACK-AXES.md` |
| 11 | amend the blocked-egress premise. ⚑ **Measured 2026-09-24: raw egress works.** `curl` to rfc-editor returns 200 and DNS resolves from the shell | `revisit` | `docs/decisions/decision-inspiration-policy.md` |
| 12 | **audit each settled crypto ruling against `PRINCIPLES.md`.** `T1` was audited by hand 2026-09-23 and came back supporting principles 1, 2 and 5 and in tension with 3 and 4, and the tension was real enough to force a measurement. `T9`, the maximize ruling, and every design this arc settles owe the same pass | `revisit` per ruling | the ruling's own file, and a `records/` row |
| 13 | the unconfident areas, one research run each: whether two hops' pre-issued tag sequences for one route are independent, which the whole unlinkability claim rests on and no file states; whether randomized hashing has ever been applied to content addressing, and what is done about the publisher-as-adversary case | `research` | `FD` rows |

## Owed, found while running

| what | where |
|---|---|
| **`ledger-lint` check AM is vacuous and silently became so.** `check_am` shells to `tools/xlat/xlat.sh unpinned` under `subprocess.run(timeout=180)` and converts any exception to `Vacuous`. At 660 pins the tool exceeds that, so the check reports having checked nothing. Three checks now check nothing: H, M, AM. `docs/definitions/working-discipline.md` names a gate that cannot fail as the cardinal error | a `PRB` row, and a tool fix. Neither written |

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
