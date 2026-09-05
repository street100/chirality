# Handoff: 2026-09-04 evening

**Resume from this file.** It supersedes `.planning/HANDOFF-2026-09-04.md`, which
describes the morning state and is kept for its measurements.

Tracked, so a fresh clone gets it. Written at a clean tree with nothing
uncommitted.

## State

- **`ledger-lint` exits 0.** Every check at zero, `H` and `M` the two
  long-standing VACUOUS entries. First clean run in this tree's history.
- **Suite green:** `373 passed, 0 failed, 88 roots built, 0 failed, gate PASSED`.
- `bin/chirality-bin` **1,192,312 B**, generation two, fixpoint `B2 == B3`
  verified at `1157028`.
- **150 commits ahead of `origin/master`, unpushed.** The author pushes.
- The author worked the display-calculus arc in parallel all session. Their
  commits are interleaved. **Pathspec every commit.**

## The lint, before and after

`G 74→0 · R 132→0 · W 81→0 · X 32→0 · Y 6→0 · Z 5→0 · AB 18→0`

`AB` is new: it pairs `docs/elements/ledger.md`'s state column against
`docs/elements/catalog.md`'s prose assertion, which nothing had ever paired.
`ledger-lint.py` check N reads the ledger against `docs/examples/INDEX.md` and
never opens the catalog.

## What landed

**E185 built, promoted, gated.** The `$apply` dispatcher's erased domains are
stated at the lowering type level. Rejects went 4 to 2, not to 0, and the
residue is real: see EN-19 and EN-20.

**E186, E187, E188 minted.** `E189` is the last free number in Lane A's band,
shared with the diagnostics arc.

**Gate tier.** GA-13, GA-17, GA-19, GA-20, GA-21, GA-22, GA-23 and GA-24 closed
with measured red runs. `tools/test/registration.sh` is new: every script on disk
is either dispatched by a `run_phase` line or declares itself out in its own
header with a reason, and it prints seven `PEND` scripts that do not run.

**Docs.** `docs/banks/erasure.md` written, the eleventh bank. Bank tier clean on
every mechanical check. `records/spec-tier-triage.md`,
`records/tooling-classification.md`, `records/ledger-reconciliation.md` all new.

## ⚑ The live miscompile

`records/enforcement-arc.md` **EN-20**. `lib/lowering/upper/closconv.chiral:1057`
is `((none) (c-lit-i 0))`, commented `unreachable: g always has a def-ctx`. It is
reached: `def-ctx`'s `peel-lam-exact` refuses curried projectors whose type is
deeper than their body, and the arm emits a literal `0` as a whole function body.

Demonstrated with a fixture compiled by today's binary: `direct box-f: 30`,
`via $apply: 0`.

⚑ **`ck-prog` does not catch it.** When the family codomain is `I64`, `const 0`
matches the declared return and the check accepts silently. The two instances in
the blob redden only because their codomain happens to be a data type.

Blast radius today is zero and nothing measures that on purpose: `compile-fn`
skips those sites, so the dead dispatchers ride into the ELF uncalled. **E188**
owns it, unbuilt, needs the full pipeline.

## Resume point: E186, mid-pipeline

`docs/elements/specs/E186-capture-field-types-SPEC.md`, **`status: draft`**.

Pipeline so far: pre-run `ba6d29c`, EXAMPLE audit PASS `82c71a3`, SPEC `0507ef6`,
SPEC audit **BLOCKED** `1c4ec62` with two FLAGs, revision `15a369e` disposing
both.

**The next stage is a SPEC-level re-audit.** It was dispatched and died on a
session rate limit with nothing written. Re-dispatch it. What it owes:

1. **Does R4 have independent falsifying power now?** The first audit proved R4
   was implied by R2 ∧ R3 on the three-site fixture and was the sole red in none
   of four mutants. The revision added a fourth site capturing `Bytes`/`Str`/`I64`
   and a fifth mutant M5 claimed to redden R4 alone. Verify `nt-bytes` and
   `nt-str` appear in no golden's constant.
2. **Judge shipping an unbuilt M5.** Its needle was counted at 1; it was never
   built or run, because the fourth fixture site does not exist. The SPEC argues
   the `nobuild` risk is M2's exactly. GA-19 is the standing trap.
3. Verify FLAG A's disposal: Steps 1, 2 and 6 one shape, EN-17 **RULED** not
   ANSWERED and still `state: OPEN`, Step 6 forbidding a close on the author's
   row.

Then implement, with the full BUILD RULE.

## Blocked on the author

- **Phase numbers 21 through 23.** `run-tests.sh:332` and
  `decision-lane-split.md:30` reserve them for Lane B; `tal-check.sh:5` claims 22.
  Four scripts wait on the number. `records/author-calls.md` holds the row.
- **A reserved element block for the independent-judgment arc**, which keeps J1
  through J5 as arc-local rows.
- **J1 itself**, `docs/decisions/decision-formulation-distinctness.md`,
  `status: draft`, awaiting ratification. It gates 210 of the 240 gate-tier calls
  in enforcement requirement 5.
- **What E20 actually is.** Its row and the element disagree; there is no
  `nb-blit` and no code loader, and the W^X half is not held.
- **`records/author-calls.md:32`**, the capture-constructor row E186 rules on.
- The **refuse-or-carry** ruling, standing.

## The queue, in priority order

1. E186 SPEC re-audit, then implement.
2. E187, `closconv` states the lowering-level type of every name it invents.
3. E188, the miscompile.
4. Nine open GA rows: GA-01, GA-03, GA-04, GA-05, GA-07, GA-08, GA-10, GA-11,
   GA-25.
5. Requirement 5's conversion work, gated on J1.

## Rules that bit this session

- ⚑ **Serial dispatch: exactly ONE agent at a time.**
  `docs/decisions/decision-dispatch-cadence.md`. This session ran three to five
  concurrently and it cost what the rule prevents, twice: a `git stash` swallowed
  an agent's uncommitted work, and two agents collided through `diag.sh`'s
  tree-wide `grep '(r-relayed '`, putting the gating floor red. **Disjoint write
  sets are not disjoint when a gate reads the whole tree.**
- **Pathspec every commit.** The author edits live.
- `(ulimit -s unlimited; …)` on every compiler invocation.
- 3.85 GB, no swap. Run the suite once, never in a retry loop.
- `bin/chirality-resolve.sh` caches file bytes by path in `_CHIR_SRC`. Call it
  inside `( … )` as every gate script does.

## The finding worth carrying forward

Four independent passes hit the same thing: **artifacts frozen at authoring time
that no mechanism updates when the work lands.** 104 of 129 SPECs describe built
work while reading `status: audited`. 18 catalog cells said "Not built" against a
ledger saying built. Nine SPEC steps ask for work already in the tree. E185's own
rows cite coordinates its own commit moved.

The catalog now has a mechanism, check AB. **The SPEC tier has none**, and that is
the largest structural gap left in the doc tier.
