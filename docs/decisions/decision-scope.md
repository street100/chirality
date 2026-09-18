---
node: decision-scope
layer: decision
status: DECIDED
decided: 2026-08-31
related: [goals/ownership-and-trust, goals/self-hosting, goals/presentability, decisions/decision-self-verification, index]
updated: 2026-09-17
---

# Decision: the current track is self-hosting only

⚑ **Amended 2026-09-06: the native-stack track opened 2026-09-03.** The author
opened [[arcs/native-protocol-arc]] in session that day and its `N1` slices 1
and 2 are built and gated by `tools/test/crypto.sh`, which registers as suite
phase 31. [[arcs/native-window-arc]], [[arcs/display-calculus-arc]],
[[arcs/vocabulary-arc]] and [[arcs/canvas-arc]] opened after it under
[[goals/native-stack]], [[goals/display]] and [[goals/own-web]]. This decision
held the track to self-hosting only and the tree had already moved; recording
that is what closes the standing call in [[records/author-calls]]. The
ownership-and-trust track stays deferred, which is the other half this file
settles and which nothing has moved.

**Set by the author 2026-08-31.** Hoisted out of the root handoff on 2026-09-01,
where it had been the most-cited sentence in the repository and lived in a file
that a fresh clone was expected to read before anything else.

## The decision

**In scope:** the language compiling and checking itself, and being good enough
to write its own tooling. [[goals/self-hosting]] and [[goals/self-tooling]].

**Deferred, as a separate track:** the ownership and trust model — the
re-bootstrap climb, DDC, the secure datum model, the register root, the cascade.
[[goals/ownership-and-trust]] holds it.

Do not pull any of the deferred track into current work, and do not audit its
documents.

The reach of that sentence is fixed in the next section. It defers the build and
leaves the planning alone.

## What "deferred" means here, exactly

**Deferred is not deleted.** Its documents stay, its content stays, and it is
required only to be honestly marked unbuilt. Archiving one of its files for
inactivity is a defect, not a cleanup. Elements on this track include E53, E71
and E72.

This is the clause most likely to be misread by a pass that is trying to make the
tree smaller, so it is stated here rather than left to inference.

⚑ **Amended 2026-09-13: one word was carrying two deferrals and the tree read
the wrong one.** This file said "deferred" and left the reach to inference. The
author ruled it on 2026-09-10, at `d307682`: the deferral "is just an
implementation work defer. says literally nothing about planning".
[[records/author-calls]] records the ruling under "Whether the orphan program
reaches the `OT` track". The tree had taken the other reading and acted on it.
`docs/arcs/ownership-and-trust-arc.md:45-48` declines roster rows for seventeen
elements because they "stay deferred with the track", and thirteen unrostered
`design` elements were held out of a homing queue on the same reading. The
deferral itself is unchanged and the author reaffirmed it in the same ruling.

Two senses, and this decision carries only the first.

| sense | means | this track |
|---|---|---|
| **build-deferred** | no element on the track is implemented | **yes**, and this is the whole of what the sentence above defers |
| **plan-deferred** | the track's work stays out of the planning tier: it is named by no goal, it takes no roster row, it gets no design | **no** |

Homing an element is planning, so a deferred element still takes a roster row.
[[goals/ownership-and-trust]] and [[arcs/ownership-and-trust-arc]] exist because
this track was planned while unbuilt, and the rest of its rows are owed the same
treatment.

**The boundary past homing, ruled 2026-09-17.** A design under
`docs/arcs/parts/` and a SPEC under `docs/elements/specs/` are planning too.
`docs/decisions/decision-design-before-mint.md:75-86` lists the pipeline's
stages and puts `implement` last at `:83`. A design and a SPEC both sit above
that stage and neither one writes to `lib/` or `prog/`, so neither one
implements an element. `build-deferred` in the table above is the whole of what
the scope sentence defers. An `OT` element may therefore be designed and
specced while its build waits for the track. The audit instruction is separate
and stays as it is.

A second pair comes with the author's instruction attached to the ruling. A
deferred roster row records what is actually wanted when the track begins, and
what stays deferred, and it names the blocking condition instead of the track.

| why a row is unbuilt | lifts when |
|---|---|
| **track deferral**, the author's scope call and nothing else | the track resumes |
| **blocking condition**, a material fact that stops the work on its own | the fact changes |

E63 is the author's worked example. `docs/elements/catalog.md` carries it as
"docs-only, hardware-dependent; out of the CPU/RAM-only sandbox". No CHERI
hardware in the sandbox is a blocking condition, and it outlives the track
deferral.

## Why it is cited so often

Three tracked authorities lean on this decision to explain why something true is
nevertheless not being worked on:

- `docs/elements/catalog.md` marks rows `OT` against it, and cites it directly
  for the register-root custody and DDC rows.
- `docs/definitions/open-edges.md` defers a class of open edge to it.
- `docs/elements/ledger.md` uses it to separate the `SH` track from the `OT`
  track.

Without a tracked home those citations pointed at a root file, which is why this
note exists.

## Consequences that follow from it

1. **External judgment is cut** — Rocq, CompCert, and the Python oracle. The
   replacement is three semantically distinct judgment cores that must agree, and
   the criterion is *different formulations*: three encodings of one rule set
   would be worth nothing. [[goals/independent-judgment]] holds it. ⚑ **Amended
   2026-09-13: this read "unbuilt with zero arcs" and
   [[arcs/independent-judgment-arc]] opened 2026-09-01 at `5a58f2b`.** It is
   unbuilt and it is planned, which is the split the section above names. The
   `Mach`-to-C backend went with the cut on 2026-09-01 (`d8bcec5`, `d0c5dd5`).
2. **Every rung reading ENFORCED is enforcement against error, not against an
   adversary**, because 1 is unbuilt. [[status-ledger]]'s rungs measure reach:
   SEEDED means nothing calls it, IMPLEMENTED means reached and ungated, ENFORCED
   means gated. None of them means "an adversary tried".
3. **`bin/chirality-bin` is committed**, with the tree and harness that rebuild
   it. Build-new, test, promote; nothing replaces itself in place.

## Honest limit

The scope sentence names two clauses, in-scope and deferred, and some real work
falls in neither. The user layer is the known instance: `docs/decisions/`
legitimates it, no `U#` row exists in the catalog or ledger, and work on it
stopped mid-audit on 2026-08-30. An unclassified body of work is not the same as
a deferred one, and this decision does not cover it.

The 2026-09-10 ruling reaches the first clause of the deferral instruction and
stops there. "Do not audit its documents" is a second instruction standing on
its own reason, and it is unchanged. ⚑ **Amended 2026-09-17: the boundary
past homing is stated.** That ruling named homing as planning and fixed no
boundary past it, so whether a design or a SPEC for an `OT` element is planning
under this decision stood open here and belonged to the author. It is ruled,
the section above carries the boundary, and [[records/author-calls]] carries
the call beside its derivation.
