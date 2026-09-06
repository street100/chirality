---
node: decision-scope
layer: decision
status: DECIDED
decided: 2026-08-31
related: [goals/ownership-and-trust, goals/self-hosting, goals/presentability, decisions/decision-self-verification, index]
updated: 2026-09-01
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

## What "deferred" means here, exactly

**Deferred is not deleted.** Its documents stay, its content stays, and it is
required only to be honestly marked unbuilt. Archiving one of its files for
inactivity is a defect, not a cleanup. Elements on this track include E53, E71
and E72.

This is the clause most likely to be misread by a pass that is trying to make the
tree smaller, so it is stated here rather than left to inference.

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
   would be worth nothing. [[goals/independent-judgment]] holds it, and it is
   **unbuilt with zero arcs**. The `Mach`-to-C backend went with the cut on
   2026-09-01 (`d8bcec5`, `d0c5dd5`).
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
