---
node: records-ledger-reconciliation
layer: record
related: [records/README, elements/README, status-ledger, records/spec-tier-triage, goals/enforcement]
status: current
updated: 2026-09-04
---

# Ledger reconciliation, 2026-09-04

`docs/elements/ledger.md` is the build-state authority that
[[goals/enforcement]] requirement 1 rests on: *a capability sits at ENFORCED, or
its ledger row says why it does not*. `records/spec-tier-triage.md` reported
seven rows disagreeing with live source. Each was re-measured here. **Three were
real, one was a naming finding, and four were the triage reading the wrong
subject.** The triage's own count is corrected by this file.

The run that began this reconciliation was killed by a session rate limit
part-way through. What it had written was verified and committed at `138a3e3`;
the remainder was finished by hand and is below.

## Corrected

| E# | was | now | evidence |
|---|---|---|---|
| E69 | `design` | `built`, at IMPLEMENTED | `closconv.chiral:1` names itself E69; `compile-front` imports its driver; `apply-word.sh` is undispatched so no phase reddens when closconv breaks |
| E113 | `flight` | `built` | built under E120's number: `pool.port:30`, wrap at `crossing-wraps.chiral:52`, called at `grid.chiral:194` |
| E26 | `built` | `built`, qualified PARTIAL | crossing half real (`process.port:14`); the typed alarm is E42's named residue, hard-gated on E39, which is `design` |
| E185 | catalog `Not built` | catalog `BUILT` | landed `ccff8e8`, promoted `1157028`, fixpoint `B2 == B3` at 1,192,312 B. The ledger already read `built`; the two cells disagreed |

## Kept, with the reason added

| E# | state | why it stays |
|---|---|---|
| E70 | `design` | SEEDED. `sig-driver` has **zero importers** and `eff-lower`'s only importer is `sig-driver`, so the chain is unreached. Two comments naming E70 are not the element: the effect-row tal shadow is absent |
| E45 | `design` | SEEDED. `reflect-floor.chiral` (54 L) realizes the type-level floor and has **zero importers** |

## A finding rather than a cell edit

**E20.** The row and the element disagree about what E20 is. There is no
`nb-blit` and no mmap-to-mprotect *code loader* under `lib/`;
`lib/module/loader.chiral` is the **compiler's** module loader by its own
header, a different thing, and the name is a collision. The real
`mmap`/`mprotect` pair in `compile-emit.chiral` is E89/E91's arena
reserve-commit, never a W→X transition. **The W^X half is not held:**
`x64/elf.chiral:59-60` emits one RWX `PT_LOAD` in its own words and
`readelf -l bin/chirality-bin` reports a single `RWE` segment.
`docs/definitions/status-ledger.md` already demoted its W^X loader row for this
reason. Naming the surviving element is an author call.

## What the triage got wrong

Four of its seven reported disagreements do not exist. Recorded because a triage
that over-reports is the same defect class as a ledger that is stale.

- **E129** and **E130** already read `built`. Both are reached: `inet.chiral` has
  seven importers, `http.chiral` nine including `prog/agent/agent.chiral`.
- **E45** already carried its SEEDED annotation.
- **E24** is correct as `built`. The triage searched `lib/prelude/prelude.chiral`
  for `div`, `mod`, `divmod` and `try-div` and found none. E24's subject is the
  **x86-64 emitter**, which its catalog row states: `lib/lowering/x64/mach.chiral`
  emits `cqo`/`idiv` with the #DE guards at `:159-189`. Absent prelude wrappers
  say nothing about it.

## What this does to requirement 1

The requirement is not restored by this pass, and the reason is structural rather
than a count. Two of the six rows checked are SEEDED with the ledger reading
`design`, which the four rungs distinguish and this table's vocabulary does not:
`docs/definitions/status-ledger.md` separates DESIGNED from SEEDED (code exists,
nothing reaches it), and `docs/elements/ledger.md` has one cell for both. So a
row saying `design` cannot say whether the code is absent or merely unreached,
and the requirement's *or its ledger row says why it does not* half is carried by
prose in the title cell rather than by the state.

⚑ **`ledger-lint` check N does not pair the ledger's state against the catalog's.**
E185 sat `built` in one and `Not built` in the other and nothing flagged it. That
gap is why this reconciliation was needed at all.
