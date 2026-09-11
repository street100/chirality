---
node: decision-primitive-with-consumer
layer: decision
status: DECIDED
decided: 2026-09-10
related: [working-discipline, decisions/decision-design-before-mint, decisions/decision-work-ids, arcs/README, elements/README, records/author-calls, records/lenses/README, banks/INDEX, index]
updated: 2026-09-10
---

# Decision: a gap is scheduled as a primitive and its consumer, together

**Decided 2026-09-10 by the author.** Read this before naming a gap, before
opening a roster row, and before deciding that a measured absence has no home.

## The ruling

The author's words, verbatim:

> "we need to do bare primitives + stuff that uses them"

and, on what is owed when a gap is found:

> "If it's a gap it needs to be fucking docced, and a solution pre-minted at
> least. Always."

Two obligations, and neither discharges the other.

1. **A gap is written down when it is found.** Not reported in a session and
   carried on. `.planning/protocol/placement.md` already states the general form
   under *Writing is mostly amending*: a thing learned mid-task is written where
   it belongs in the same move, because reporting it in a message loses it when
   the session ends. This decision makes the specific case binding.
2. **A gap is scheduled as a pair**: the bare primitive, and the thing that uses
   it. One without the other is half a row, and half a row is what the tree has
   been producing.

## What this repairs

Three defects, measured 2026-09-10, that made the pair inexpressible.

### 1. The blocking rule was never tracked

"Mint on first real need", and its stronger form "minting an element with no
consumer creates the opposite phantom: a catalog row nobody will ever pull",
live in `.planning/LANGUAGE-INVENTORY.md` and nowhere else. A grep over
[[working-discipline]], [[decisions/decision-design-before-mint]],
[[arcs/README]], `docs/elements/README.md` and the four files under
`.planning/protocol/` returns no statement of it.

A rule that gates minting is doctrine. It sat in a working file, was applied as
doctrine, and could not be argued with because it was not written where rules
are written.

### 2. The two rules face opposite directions and deadlock

[[working-discipline]] `:78` forbids a consumer from naming an unminted
element: a deferral to a nonexistent element is a phantom dependency. The
untracked rule above forbids minting a primitive with no consumer.

So the primitive waits for a consumer and the consumer may not name the
primitive. Nothing in the tree broke the tie.

**The worked case.** The indexed record-of-functions,
`(data Alloc ((c MemCat)) ...)`, parses and type-checks and does not lower:
`proj-idx` (`lib/lowering/upper/specialize-singleton.chiral:98-116`) matches a
projector as exactly one lambda, so an indexed accessor's two-lambda chain is
never rewritten and lowering refuses it at
`lib/lowering/upper/lower.chiral:417`. Any fn-bearing record is affected. It was
measured 2026-08-24 and carries no element, no roster row and no arc, because
E166 turned out not to need it and the untracked rule then said GAP rather than
mint. Seventeen days, a measured language-level defect, unscheduled.

### 3. The roster cannot spell a pair

[[arcs/README]] `:74` gives `origin` three values: `new`, `bind` (it exists and
needs a surface), `connect` (two built things need joining). None of the three
means *a primitive and the first thing that uses it, as one unit*. The coverage
check at `:100` then requires every row's `origin` to be defensible from the
arc's §3, so a paired row is split into two, and the primitive half is the half
that cannot mint.

## What changes

**`origin` gains a fourth value: `pair`.** A `pair` row names both halves in its
`what` cell: the primitive, and the consumer that exercises it. Both are cited.
The coverage check reads a `pair` row as defensible when §3 measures the absence
of the primitive **and** names the consumer that wants it.

**A `pair` row mints as one element where the halves are unbuildable apart, and
as two rows that mint together where they are separable.** The precedent is
`docs/arcs/parts/part-split-PS1.md` §6, which argued one element on exactly this
ground: "Two elements would each be unbuildable without the other."

**A measured absence with no consumer is still written down.** It becomes a
`GAP-` row naming the consumer it lacks, rather than a note in a working file.
Finding the consumer is then the work, and it is visible work.

## What this rejects

**A primitive minted alone, with no named consumer.** The old rule's concern is
kept: a catalog row nobody pulls is a phantom in the other direction. The answer
is to name the consumer, not to decline to schedule.

**A consumer scheduled against a primitive that does not exist and is not
named.** [[working-discipline]]'s deferral rule stands whole. What changes is
that the pair is one unit, so the primitive is named in the same row rather than
deferred to.

**Leaving a measured gap in a session transcript or a `.planning` working file.**
This is the practice the ruling is aimed at.

## Why the consumer set is the real constraint

Measured 2026-09-10. Outside `prog/prapanca/`, `prog/scriba/`, `prog/shilpa/`
and `prog/samvada/`, the tree's programs are `compiler.prog`, `prose-lint.prog`,
`paren-audit.prog`, `test-runner.prog`, `optimizer-census.prog`, `resolve.prog`,
`wield.prog`, `climb.manifest`, and six `e1NN-*.prog` gate roots.

A rule requiring a consumer, applied over that set, justifies every new
primitive against the AI stack or the editor. That is the mechanism by which the
language grows toward the two directories that already hold programs, and it is
why this decision names the pair rather than the primitive.

## What this does not rule on

**Which arc holds a pair whose halves sit in different arcs.** [[goals/README]]
`:27` makes an element belong to exactly one arc, so the seat has to be picked
and this document does not pick it. The question is left open.

**The 47 orphan elements.** They are minted already and their defect is a
retired stage rather than a missing consumer. `39be4bb` measures them and lays
out three shapes, none chosen.

**Element status.** [[status-ledger]] stays the one authority. This document
mints nothing and defers to no `E#`.
