---
name: revisit
description: >-
  Reconsider ONE settled chirality artifact against ONE named trigger: a goal, an
  arc, a roster row, a design, a SPEC, or a built element, re-tested against new
  information. Closed verdict set (HOLDS / AMEND / RESCOPE / REOPEN / SUPERSEDE).
  Use when asked to "reconsider X against Y", "recheck this against the new
  finding", "is this still right", or when a decision, measurement or build has
  moved the ground under a settled artifact.
---

# revisit: re-test one settled artifact against one trigger

Produce exactly **one** verdict per run, then **stop**.

Every other stage in this pipeline takes an artifact forward. This one takes new
information and asks whether an artifact already behind that stage still holds.
Without it the only moves are a full pipeline re-run or a hand edit outside the
pipeline, and this tree carries the scars of the second one:
`docs/examples/INDEX.md` defines a `needs-rework` state that nothing produces,
`superseded` is written by hand, and E20's INDEX row carries a dated finding
inside its Status cell, left there as a disagreement because no stage reached
the question.

## The two hard rules

**A revisit names its trigger first, and cites it.** The trigger is read before
the artifact. A run that opens the artifact and goes looking for problems is an
audit, and it is the unbounded re-read this stage exists to replace.

**A revisit is bounded by the delta.** It never re-derives the artifact. If more
than the trigger's reach is wrong, the verdict is REOPEN and the owning stage
re-runs. A revisit that rewrites its artifact is a fresh run wearing this run's
name.

## What counts as a trigger

Each is citable, and the citation goes in the verdict.

| trigger | where it comes from |
|---|---|
| a measurement that contradicts a claim | a `records/` row, a gate result, a census |
| a decision that settled after the artifact was written | `docs/decisions/` |
| a sibling row built | the baseline an artifact's §2 measured has moved |
| an author call answered | `records/author-calls.md` |
| a finding | a `FINDING-*` note, a doc audit's FLAG |
| staleness | a `records/` row whose `checked:` date predates the last change to the files it cites |

`records/README.md` already states the last one as a rule and nothing acts on
it. That is the detector this run consumes.

## Step 1: get the bundle (ONE command)

```
python3 tools/pack/pack.py --revisit                      # list stale candidates
python3 tools/pack/pack.py <target> --revisit <trigger>   # the bundle for one
```

With no target, `pack.py` lists artifacts whose cited evidence changed after
their own date, worst first. That listing is a worklist and taking a row off it
is a separate run.

The bundle puts the artifact beside the trigger: the artifact, the trigger's
source text, the specific claims of the artifact the trigger reaches, and the
live state of every `file:line` the artifact cited. Nothing is scaffolded and no
status changes.

A REOPEN is the one backward roster move, and it has its own command:

```
python3 tools/pack/pack.py <arc>/<id> --reopen <state>
```

It takes a state earlier than the row's current one, from `open`, `designed`,
`minted`, `specced` and `building`, and leaves the element cell as it is. No
bundle command moves a row backwards; `pack.py` refuses that by name.

## Step 2: reach the verdict

Work only the claims the trigger reaches. For each, the artifact's claim beside
what is true now.

| verdict | when | writes |
|---|---|---|
| **HOLDS** | the trigger changes nothing | the `checked:` date on the records row, and the artifact stays as it is |
| **AMEND** | the shape is right, a detail is wrong | the correction, in place |
| **RESCOPE** | the row's boundary moved | the arc's roster row, and a new row where the work divides |
| **REOPEN** | the artifact's stage is invalidated | the roster row's `state` drops back to the named stage, with `pack.py <arc>/<id> --reopen <state>` |
| **SUPERSEDE** | the row stops being what gets built | the successor. **Author call, so it is flagged and not taken** |

**HOLDS is a real result and it is written down.** A check that found nothing
and left no trace gets redone by the next session. The dated row is the whole
point.

**REOPEN is the honest exit when the delta is too large to amend.** Report which
stage re-runs and why. Patching a large delta in place is how an artifact ends
up saying two things.

**SUPERSEDE is surfaced and left for the author.** It names which element owns
the work instead, and that is an author's decision. Report the question
verbatim.

## Step 3: write the record

Every run writes one row to `records/<arc>.md`, in the six-field format
`records/README.md` fixes: `state`, `claim`, `measured`, `evidence`, `checked`,
`element`. Mint the ID by taking the next number in the arc's prefix, and never
renumber an existing row.

| verdict | row state |
|---|---|
| HOLDS | unchanged, with a fresh `checked:` |
| AMEND, RESCOPE | `FIXED`, and `measured` says which side moved |
| REOPEN | `OPEN`, and `element` names the row whose stage re-runs |
| SUPERSEDE | flagged, and the row stays `OPEN` until the author rules |

`evidence:` names files and line spans. A row nobody can re-run is worthless.

## Where a correction goes in the artifact

An AMEND edits the artifact in place and marks the correction in this tree's
standing form, the `⚑` line: what the artifact said, what was measured, and the
date. `docs/goals/enforcement.md` carries three of them.

**Do not narrate the run.** A dated note about how the document got revised,
glued to the content it describes, stands between a reader and the thing.
Recording a correction is different and it belongs: the old claim was a fact
about the tree, and so is its replacement. `.planning/protocol/tone.md` draws
that line.

## Hard rule: one run = one artifact = one trigger

Two triggers against one artifact is two runs. One trigger against three
artifacts is three runs. Cadence is serial, one stage and one agent at a time,
`docs/decisions/decision-dispatch-cadence.md`.

## Done

- One verdict, from the closed set.
- The `records/<arc>.md` row written, six fields, `checked:` today.
- Any AMEND in place and marked `⚑`. Any RESCOPE or REOPEN reflected in the
  arc's roster row.
- Nothing under `lib/` or `prog/` changed. No element minted. No supersession
  taken.
- Final message: the verdict, the trigger cited, the record row ID, and the next
  step it implies. Stop.
