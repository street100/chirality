---
node: arc-ownership-and-trust
layer: navigation
related: [arcs/README, goals/ownership-and-trust, goals/independent-judgment, arcs/independent-judgment-arc, decision-scope, decision-work-ids, index]
status: current
updated: 2026-09-13
---

# Arc: the ownership and trust track

- goals: [[goals/ownership-and-trust]]
- reserved element block: **none**. Its rows carry arc-local ids `O1` and up,
  per [[decisions/decision-work-ids]], and all three map to elements minted long
  before this file: `E53`, `E71` and `E72`.
- build-state authority: [[status-ledger]]

## ⚑ Deferred by author call, 2026-08-31

`docs/decisions/decision-scope.md` puts this whole track out of current scope,
and [[goals/ownership-and-trust]] repeats the instruction: do not pull any of it
into current work, and do not audit its documents.

⚑ **Amended 2026-09-13.** That deferral is **build-deferred**, fixed under
§What "deferred" means here, exactly in the same file. It defers the build and
leaves the planning alone, so this arc holds rows while nothing on it is built.
The author ruled it 2026-09-10 at `d307682` and [[records/author-calls]] carries
the words, under "Whether the orphan program reaches the `OT` track". This file
had read the deferral the other way and declined seventeen rows on it.

**Nothing here is queued for build.** No session builds an `OT` element. Writing
and homing its rows is planning and stays open to a session. This arc exists
because the goal's own file was already carrying an arc's content, three minted
elements and a state for each, in the tier that holds goals.
`docs/arcs/README.md` puts that content here.

## Why this arc exists

`README.md` scope names the track: the re-bootstrap climb, DDC, the secure datum
model, the register root, the cascade. [[goals/ownership-and-trust]] cites it.
The design lives in [[secure-datum-model]], [[bootstrap]] and
[[trust-boundary]], and those documents stay as they are.

## Roster

Three, and each state is the catalog's, read 2026-09-02.

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `ownership/O1` | diverse double compilation, the trusting-trust climb. **CONTESTED and deferred.** The compare core is live at `lib/evidence/ddc.chiral` and imported by `lib/evidence/test-floor.chiral`. The driver it was paired with is evicted, and `ddc-bad-quorum` refuses a quorum of fewer than two legs of disjoint provenance, so on the measurement E166 records there is one leg left and this element cannot run | quorum | law | new | 1 | open | `E53` |
| `ownership/O2` | the golden-semantics restructure: the kernel spec as the golden object, every executor first among executors. **PROVISIONAL 2026-07-26, revisitable.** `docs/definitions/tal-spec.md` shipped and the data form is live at `lib/lowering/tal/spec.chiral` with zero importers. Two chirality reference executors are built and unreached, `lib/evidence/interp.chiral` and `lib/lowering/tal/eval.chiral`. Its SPEC audit on 2026-08-31 returned BLOCKED | golden | decision | new | 2 | open | `E71` |
| `ownership/O3` | the re-bootstrap artifact: the shipped form contains its own re-derivation, with no trusted binary in the forever story. **Requirement pinned in `.planning/SELF-HOST-PLAN.md`, nothing built.** Couples E71 and the E52 spec-size budget | bootstrap | primitive | new | 4 | open | `E72` |

The catalog's `OT` category holds 22 rows, counted 2026-09-15, and `E71` is one
of them. This arc names the three the track's own sentence in `README.md`
points at. **The other nineteen are owed a row here.** ⚑ The figure was 20 with
`E71` at `?`; the author sorted `E52` and `E71` to `OT` on 2026-09-15 and
`docs/elements/catalog.md` §UNSORTED carries both derivations. The track deferral
does not reach homing, per `docs/decisions/decision-scope.md` §What "deferred" means
here, exactly, so being deferred is no reason for an element to sit outside the
roster. Writing those rows is its own unit and this file schedules nothing.

**What an owed row records.** The author attached an instruction to the
2026-09-10 ruling: the row says what is actually wanted when the track begins,
and what stays deferred, and it names the blocking condition instead of the
track. `docs/decisions/decision-scope.md` separates the two and carries E63 and
the absent CHERI hardware as the author's worked example. A row whose only
reason for being unbuilt is the scope call says that and names no other.

### Coverage

⚑ **Requirement 3 is served by no row**, enumerated as `GAP-08`: reaching the
reference semantics in `lib/lowering/tal/spec.chiral` is adoption of a built
thing, and every row here is build-deferred, so nothing builds it. The row
`GAP-08` wants is owed on the same footing as those nineteen.

Requirements 1, 2 and 4 are served: 1 by O1, 2 by O2, 4 by O3. Every row serves
one. **Every row is build-deferred by author call**, so the coverage states what
would be built if the track resumed.

## REQUIREMENTS

Draft, and each is checkable if the track is ever resumed. None is scheduled.

1. **A quorum has two legs of disjoint provenance.** `ddc-bad-quorum` fires
   below that, with a mutant that is actually run. Observed by the refusal.
2. **The golden object is settled.** The provisional ruling of E71 is confirmed
   or replaced, and its SPEC leaves BLOCKED. Observed by the audit rerunning.
3. **The reference semantics is reached.** `lib/lowering/tal/spec.chiral` and the
   two reference executors gain an importer and a gate. Observed by the import
   graph.
4. **The shipped artifact carries its own re-derivation.** Observed by
   performing the climb from the spec.

## What this arc does not own

[[arcs/independent-judgment-arc]] shares the machinery and holds a different
question. That arc owns the live quorum: whether a second judgment core exists
in a different formulation, today, under [[goals/independent-judgment]]. This
arc owns the deferred climb and the artifact story around it. `E53` sits here
because the trusting-trust bootstrap is the ownership question, and the judgment
arc's rows stay `unminted` by their own choice.

## Resume state

**Where a session picks up.** The owed roster rows, and nothing that builds.
Resuming the build is an author decision and it belongs in `docs/decisions/`
before it is work.

**What would unblock the build.** A ruling that lifts the 2026-08-31 deferral.
Until then the honest state of all three rows is deferred, and the two that are
half-built say so above rather than reading as in flight.
