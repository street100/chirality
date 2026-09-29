# Handoff: the test audit, and the recatalog it stopped in the middle of

**Written 2026-08-31.** Session ended on a spend limit mid-dispatch. Read this,
then `HANDOFF.md`'s SCOPE section, then pick up at "Next action".

## What this session was

An adversarial audit of the test suite, aimed at making it strong enough to
support self-verification. It turned into a scope problem, which is where it
stopped.

## Landed and committed (swept into slice 8 by a concurrent session)

- `tools/test/mutant.sh` (257 L). The run-the-mutant rule mechanized. Mutates a
  rule in `lib/`, builds a compiler from the mutated tree (2.4s), puts it under a
  whole phase via `CHIRALITY_COMPILE`. Closes four ways the measurement lies
  silently: unmatched anchor, unbuilt mutant, inert mutant, already-red base.
  `--matrix` runs every mutant against every phase, `--list` prints them.
- `tools/test/linear-mint.sh` sections E and F, 11 new rows, 21 -> 32.
  - **E, the case merge.** Found by mutation: weakening `qjoin`'s branch-merge
    saturation survived ALL FIVE phase scripts. A q1 capability burned in one
    case arm and dropped in the other type-checked. Needs TWO mutants, not one:
    `qjoin` has two independent non-trivial arms and a clean 2x2 diagonal was
    measured. One mutant would have licensed one row and left the other arm bare.
  - **F, the erased binder.** `qfits`'s q0 arm was convicted by ONE phase in the
    whole suite (`diag.sh`) and only incidentally. Section B's two rows with ZERO
    in the name do NOT reach it: their values are linear porttypes, refused
    earlier by a dedicated check. They read as q0 coverage and are not.
- `tools/test/run-tests.sh`: Phase 7's compile-only roots no longer tally into the
  assertion count. They were 36 of 149. A compile carries no expected value and
  cannot be ranked, so folding it into a ranked count broke the rule that a gate
  row must name its rank.

## Uncommitted, mine, still on disk

- `bin/chirality-resolve.sh` — **caching, 5.9x on the Phase 7 shape.** The
  resolver was the dominant cost of every gate: resolving `prog/compiler.prog`
  cost 1657ms against 744ms to COMPILE the blob it produces. Three fork sources
  removed (probe subshell, imports subshell, `cat` per module per blob), all
  memoized on pure functions of a static tree. `seen`/`order` stay per-call.
  ⚑ Verified byte-identical: imports over all 398 source files, all 39 roots'
  blobs, five reference blobs, compiler rebuilds at 1,098,104 B, fixpoint holds,
  missing-module stderr identical.
  ⚑ A pure-bash rewrite of `chirality_imports` was tried and is SLOWER (660ms ->
  1294ms). The `sed | grep | sed` pipeline stays; the header records why so it is
  not re-attempted.
- `docs/decisions/decision-self-verification.md` (290 L). Godel/Lob as the bound,
  Milawa's per-level faithfulness as the permitted move, cross-formulation
  adequacy through a hub, the axiom column named. Section 6 records where it
  restates already-minted elements, including that E52 had already resolved the
  conversion question its first draft called the largest open one.

## The result that should change how claims are worded

Seven semantic mutants of the checker, including one with the linear-usage audit
switched off, EACH reach a byte-identical self-hosting fixpoint at exactly
1,098,104 B. The fixpoint distinguishes nothing, and neither does binary size.
`HANDOFF.md` says "a fixpoint is stability, never correctness"; that is now
measured rather than asserted.

## Two SPEC audits ran. Both BLOCKED. Both wrote their fixes in place.

`.planning/specs/E52-certificate-split-SPEC.md` and
`E71-golden-restructure-SPEC.md` are edited and NOT marked audited (BLOCKED does
not earn a flip).

**E52.** Half its conformance gate cited the evicted Python producer/checker pair
and cannot be re-founded: it needs a second judgment implementation and none
exists. The surviving half is a mutant and re-founds on `mutant.sh`. The audit
wrote down what the re-founded gate MAY claim (the seam refuses a producer bug)
and may not (no TCB reduction, no independence, no agreement, no DDC result).
⚑ Sharpest finding: `recheck`'s body IS `infer`, on the same term in the same
core. That is L1 re-execution, not L0 re-derivation. Also `lib/typing/kernel-core.chiral`
has zero importers, `reflect-floor.chiral:53` forward-declares `recheck` at a
DIFFERENT signature so the two cannot compose, and `recheck` passes a literal
empty `Sig`, so only closed core terms are certifiable.

**E71.** Half built and nobody records it: `docs/definitions/tal-spec.md` and the
`floor-agreement.md` Statement shipped, `lib/tal-spec.chiral` does not exist. Its
gate cited the evicted Python `TalMachine`. §5 was re-founded at rank 3,
hand-derived, with the reason recorded: rank 2 may NOT found this artifact,
because a vector taken from an executor is semantics-by-accident, which
`tal-spec.md` itself exists to forbid.
⚑ Two chirality reference executors ALREADY exist and are built,
`lib/evidence/interp.chiral` (E15) and `lib/lowering/tal/eval.chiral` (E18), both
unreached and ungated. The SPEC says "eventually a chirality reference executor".
⚑ Rot inside E71's own shipped output: `tal-spec.md:19-21` still lists the Python
`TalMachine` first among executors, and `:74-75` cites `tests/test_tal_spec.py`,
a file that never existed and would be Python.

**Unresolved across both, author-tier:** no element builds `kernel-spec`. E52
calls it a non-goal "couples E71", E71 delivers tal-spec instead, E72 merely
couples it. In code, `Spec`/`SpecRule` at `kernel-core.chiral:28-29` have nothing
populating them, so `recheck` is spec-shaped rather than spec-directed.

## Why the queue stopped

E72 and E53 were next. `HANDOFF.md`'s SCOPE (author, 2026-08-31) puts the
ownership and trust model in a deferred track by name, including the re-bootstrap
climb and DDC, and says **do not audit its documents**. Auditing them would have
been directly against a standing instruction. Nothing was dispatched.

⚑ Open question that gates resuming: is E52/E71 in the deferred track, or does the
tal floor stay in scope while E72, E53 and kernel-spec wait? E71's own audit put
this first and it is right.

## Next action: the recatalog, dispatched and lost to the spend limit

It wrote nothing. Re-dispatch it. Measured case, verify before acting:

- 166 element rows in `.planning/SELF-IMPLEMENT-CATALOG.md`.
- **63 of them** cite a Python file, Python, CPython or ctypes as their
  State/location. Those files do not exist. A reader picking up E3 is sent to
  `kernel.py`.
- **23 rows cite `scaffold/`**, deleted in the migration.
- The header taxonomy (catalog lines 19-21) defines two of three build-kinds BY
  Python: SELF-HOST is "Python we wrote that must become chirality source",
  REPLACE-CRUTCH is "a CPython/ctypes/libc convenience". The axis the catalog
  sorts on no longer exists.
- **Zero occurrences** of "self-hosting only", "ownership track" or "separate
  track" in the catalog or the LEDGER. The scope split lives only in `HANDOFF.md`,
  so the two documents that say what to build cannot say what is in scope.

The dispatch must mark the deferred track WITHOUT auditing it, must not mint any
element (kernel-spec's owner is an author call), and must return anything
ambiguous as UNSORTED rather than guessing. An element wrongly marked in-scope
pulls deferred work into current work, which is what the scope statement exists
to prevent.

⚑ `HANDOFF.md` records that `refs/gen-*.py` are sliced by `pack` as the OURS
baselines for four worked examples, so "the Python is gone" is not uniformly
true. Check before asserting it.

## Working notes for whoever picks this up

- The tree is shared and moved twice mid-session (slices 7 and 8, plus a history
  switch). Pathspec every commit. Re-verify measurements taken before a slice
  landed: the suite went 36 roots to 85 under me, and one assertion-count change I
  reported was a concurrent agent's new root, not my edit.
- Serial dispatch only, one subagent at a time, and tell it not to delegate. A
  `general-purpose` agent has the Agent tool and will fan out if not told.
- I twice stated an unmeasured number beside measured ones: a "15 minute" matrix
  cost that measured 2m30s, inferred from my own polling latency. Measure wall
  clock with `$SECONDS`, not with impressions.
