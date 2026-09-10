# The pipeline repair queue

`.planning/protocol/workflow.md` states the pipeline: design, audit, mint, spec,
audit, implement, with revisit reaching any of them. The audit stages are what
make the rest sound, because a mint runs off a design audit's PASS and nothing
else licenses one.

Measured 2026-09-09 at `309994c`: **three of the four designs in the tree have
never been audited, and the one that was audited is the only one that reached
`built`.** This file is the live queue that gets the pipeline running again.

`docs/arcs/baseline-alignment-arc.md` requirement 4 carries the arc-side
statement, `ledger-lint exits 0, or each remaining failing check carries a row
saying why it cannot`, and its row `AL9` owns it. `AL1` owns the gates that pass
by looking at nothing. Items P6 through P9 below land on that arc. P10 is
already specified inside `docs/arcs/parts/enforcement-N14.md` §6 and belongs to
that row.

## What the tree measured before opening this

Taken 2026-09-09 at `309994c`, each by running something, so the queue starts
from facts rather than from the rows' own summaries.

| fact | where |
|---|---|
| four designs exist: one `audited`, three `draft` | `docs/arcs/parts/*.md`, `status:` field |
| the audited one, `emitted-speed/X7`, is the only design that reached `built` | E189, `c86b007` |
| `enforcement/N14` carries 3 line citations past end-of-file and 3 symbol citations off by 7 to 13 lines | `ledger-lint` checks G and R |
| `crypto-primitives/K1` is `blocked` on a `NEEDS-AUTHOR` its own §5 says owes an author-call row | `parts/crypto-primitives-K1.md:241`, `:245` |
| no such row was written | `grep -in 'fidelity\|CRYPTO-TRANSLATION' records/author-calls.md` returns nothing |
| check AK fails only on rows that exist, so a fork that never reaches the register is invisible to it | `tools/ledger-lint/ledger-lint.py`, check AK |
| M2, M3 and M4 rest on two throwaway probes and nothing in the tree re-derives them | `parts/enforcement-N14.md` §4, its own words |
| the figures those probes produced now sit in 7 documents, 2 of them `status: settled` | `grep -rln '22,742' docs/ records/` |
| `decision-def-partition.md` shipped `status: settled` carrying 5 lint failures | `ledger-lint` checks F, G, R |
| `run-tests.sh` prints `gate PASSED` while `tal-check.sh` and `opt-census.sh` run by hand | `registration.sh`, 21 dispatch lines, 6 scripts declared out |
| check I catches `FRONTIER.md` staleness and nothing catches `OVERVIEW.md` | `ledger-lint`, check I |
| `crypto-primitives-arc` resume reads `none designed` while `K1` is designed | arc file against `parts/crypto-primitives-K1.md` |
| all three gates are green: 422 passed 0 failed, 21 ok 0 FAIL, 8 passed 0 failed | run 2026-09-09 |

## The diagnosis, and it is one defect wearing three faces

The pipeline has a gate at every stage. No stage failed. In
all three cases **a document stated an obligation about itself and nothing
mechanically read it.**

- `crypto-primitives/K1` §5 says it owes an author-call row. Nothing checks.
- `parts/enforcement-N14.md` §4 says its numbers are re-derived by nothing.
  Nothing stopped them entering two settled decisions.
- Three designs sit at `status: draft`, which is the pre-audit state. Nothing
  reports an un-audited design as owed work.

`records/enforcement-arc.md` EN-25 convicted requirement 4 of exactly the third
shape, a closing figure resting on a probe nobody committed, and
`prog/optimizer-census.prog` was written to end it. It recurred on 2026-09-09 in
the design that cites EN-25 as its own precedent. A rule stated in prose and
read by no instrument is the failure mode this queue exists to close.

## The slices

Ordered. Items P1 through P5 unblock the pipeline with no new machinery and
depend on nothing. P6 through P9 are the instruments that stop it recurring.
P10 makes the propagated numbers real.

| # | item | owner | depends on |
|---|---|---|---|
| P1 | write `crypto-primitives/K1`'s missing author-call row, verbatim from its §5 question 6 | `records/author-calls.md` | nothing |
| P2 | `pipeline-audit` at DESIGN on `emitted-speed/X8` | `emitted-speed/X8` | nothing |
| P3 | `pipeline-audit` at DESIGN on `enforcement/N14` | `enforcement/N14` | row 73's verdict, if the audit reaches §5 decision 1 |
| P4 | `pipeline-audit` at DESIGN on `coding-turn/A1` | `coding-turn/A1` | nothing |
| P5 | correct `crypto-primitives-arc`'s resume state to read `K1` designed and blocked | that arc | nothing |
| P6 | check: every `NEEDS-AUTHOR` disposition in `docs/arcs/parts/` has a matching row in `records/author-calls.md` | `baseline-alignment/AL9` | nothing |
| P7 | report: designs at `status: draft` are owed audits, printed the way AN prints owed rulings | `baseline-alignment/AL9` | nothing |
| P8 | check: `OVERVIEW.md` staleness, mirroring check I on `FRONTIER.md` | `baseline-alignment/AL9` | nothing |
| P9 | check: an arc file's `updated:` predates the newest artifact under `docs/arcs/parts/` for that arc | `baseline-alignment/AL9` | nothing |
| P10 | `prog/peel-census.prog` and `tools/test/peel-census.sh`, so M2, M3 and M4 re-derive | `enforcement/N14` §6 | P3 |

**P3 is the highest-value single item.** An audit fixes what is decidable from
its bundle, and `.planning/protocol/workflow.md` names a stale citation as
exactly that class, so running it closes all six G and R violations as a side
effect of the stage that should have run first.

**P10 is already specified.** `parts/enforcement-N14.md` §6 sizes it at
`prog/peel-census.prog` 200 to 260 lines and `tools/test/peel-census.sh` 220 to
280 lines, on the `opt-census.sh` route with `not-a-phase:`, against
`prog/optimizer-census.prog`'s 225 and `opt-census.sh`'s 273. Nothing about it
needs re-deciding.

## What this queue owes the lens tier

P6 through P9 are defects with no lens coverage today. `records/lenses/` was
read before this queue was opened: `PRB-55` covers the mutant harness having no
phase, and the row at `problems.md:819` covers `tal-check.sh` staying
unregistered by decision. Neither reaches the three faces above. Each of P6
through P9 owes a `PRB` row in the six-field format before its fix lands, so the
claim and its measurement are recorded where a person reads them rather than
only here in the agent tier.

## What this queue does not take

**The author-tier forks.** Row 73's verdict, whether `revisit` AMEND may move a
`status: settled` decision, and `crypto-primitives/K1`'s fidelity call are the
author's and this queue schedules none of them. P1 makes the third one visible
and answers nothing.

**The two gates outside the suite.** `tal-check.sh` and `opt-census.sh` run by
hand, both green today. `registration.sh` already gates dispatch registration
and records six scripts as declared out for structural reasons. Whether either
should register is a live question and it belongs to `baseline-alignment/AL1`
rather than here.

**`decision-def-partition.md`'s five lint failures.** They are that document's
own, landed 2026-09-09, and the doc-tier loop in
`.planning/protocol/workflow.md` already routes them: run the lint, then
`tools/doc/doc.py audit`.

**The 98 AI violations.** 49 of them are one coupling, `docs/elements/catalog.md`
changing under 49 `UNS-` rows that cite it. The check is correct and the signal
is swamped by churn. Whether the coupling is the defect is `AL9`'s question.
