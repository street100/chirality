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

## The gap is closed, and it was an 18-element class

`ledger-lint` gained **check AB** on 2026-09-04: the LEDGER's state column against
the CATALOG's own prose assertion. Check N pairs the LEDGER against
`docs/examples/INDEX.md` and never opens the catalog, so the two documents that
both assert a build state could disagree with nothing watching.

The check is deliberately narrow, for check N's stated reason: it flags only pairs
that cannot both be true. The catalog's state is prose rather than a column, so it
reads **only** an unambiguous `Not built` opening the description cell, against a
LEDGER row reading `built`. Hedged cells (`partially built`, `not built as
specified`, `not built;`) are left alone. A check aimed at a guess passes by
looking at nothing.

**It fired on 18 elements**, of which E185 was the one found by hand:

`E34 · E97 · E101 · E106 · E107 · E109 · E110 · E111 · E112 · E113 · E121 · E124 ·
E129 · E151 · E155 · E157 · E159 · E182`

Three spot-checked, all genuine and all the same shape, a catalog cell frozen at
authoring time and never updated when the element landed:

- **E121** opens *"Not built — no fcntl crossing (grep clean)"*. `lib/ports/fd.port:36`
  declares `(extern fcntl (=> I64 I64 I64 I64))` with an `E121:` comment on the line.
- **E157** opens *"Not built. The outcome is already a sum; the reason is a string"*.
  `lib/typing/diag.chiral` carries 22 `Reason` arms; the sum is closed.
- **E182** opens *"Not built."* Its gate is `tools/test/arity.sh`, dispatched as
  Phase 24 and green.

⚑ **The remaining 15 are not corrected here and must be verified one at a time.**
This same file records a triage that over-reported four of seven, and a
mass-edit driven by a lint hit would repeat that. The check names the worklist; it
does not license a sweep.

⚑ This is the SPEC tier's disease in a second register.
`records/spec-tier-triage.md` found 104 of 129 SPECs describing work already in the
tree while reading `status: audited`. Both are artifacts frozen at authoring time
that no mechanism updates on landing. The catalog now has one; the SPEC tier does
not.
