---
node: arc-presentability
layer: navigation
related: [arcs/README, goals/presentability, goals/honest-claims, arcs/binary-split-arc, records/baseline-alignment, index]
status: current
updated: 2026-09-01
---

# Arc: presentability and documentation

- goal: [[goals/presentability]]
- reserved element block: **none**. Rows write `UNASSIGNED`.
- checklist: [[records/baseline-alignment]], the rows in the reader-facing spine
- sibling arc under the same goal: [[arcs/binary-split-arc]]

TRACKED for the reason [[arcs/README]] gives.

## What this arc is

The reader-facing surface, aimed at someone outside the project: `README.md`,
`MAP.md`, `CONTENTS.md`, `PRINCIPLES.md`, `docs/index.md`, and the doc tier those
four point into. Opened 2026-09-01 when the author named NLnet and Tangent as
submission targets.

It is **not** the claim-fixing arc. [[arcs/baseline-alignment-arc]] establishes
whether a claim is true; this arc decides whether a stranger can find it, read it
and act on it. Where the two meet, baseline-alignment moves first — presenting a
false claim more clearly is a worse outcome than the present state.

## REQUIREMENTS

Each is checkable, per [[arcs/README]]. A requirement with no way to observe it
is a wish.

1. **Fresh-clone build.** The BUILD RULE in `CLAUDE.md` runs end to end from a
   clean clone and the byte-compare holds. Observed by running it.
2. **No reader-facing claim is false.** Every `BA-` row whose `claim:` cites
   `README.md`, `MAP.md`, `CONTENTS.md`, `PRINCIPLES.md` or `docs/index.md` is
   `FIXED`, `ACCEPTED` or `RETIRED`. Observed by reading the checklist. Open
   today: BA-30, BA-31, BA-36, and BA-24's `PRINCIPLES.md` half.
3. **Every number in the spine is current or dated.** A count with no date is a
   claim about now. Observed by grep for bare figures.
4. **No spine document cites a path or command that does not exist.**
   `chirality verify` is cited 14 times and does not exist (BA-31). Observed by
   `ledger-lint` checks A and G once BA-23 and BA-02 land.
5. **The doc roles in `MAP.md` match the tree.** `MAP.md` sorts docs by role;
   `goals/`, `arcs/` and the records tier are new roles and are not in it.
   Observed by comparing the list to `ls docs/`.
6. **A tool binary carries only what the tool needs.** Delegated to
   [[arcs/binary-split-arc]]; listed here because it is a requirement of the
   goal, and an evaluator who measures a 780 KB text tool draws a conclusion
   about the architecture.

## Elements

| element | what | state |
|---|---|---|
| UNASSIGNED | reconcile the spine against the open `BA-` rows in requirement 2 | not started |
| UNASSIGNED | `MAP.md` doc-role table gains `goals/`, `arcs/`, records | not started |
| UNASSIGNED | retire or build `chirality verify` and its 14 citations | not started |

No element number is minted. This arc has no reserved block, and `CLAUDE.md`'s
deferral rule forbids naming an element that does not exist. An arc with no block
gets one from the author.

## Resume state

**Where a session picks up.** Requirement 2, and specifically the `PRINCIPLES.md`
half of BA-24. `PRINCIPLES.md:62` says "One atom with no exemptions" and `:89`
says "the port-check is the type-check"; a pure `->` function performs a syscall
and is accepted. `README.md`, [[status-ledger]] and `docs/banks/effect-and-alarm`
all disclose this accurately, so the spine's most-read document is the one that
does not. That is the highest-value single fix in this arc.

**What blocks it.** Nothing mechanical. It is a wording decision about a
principle, so it may want a `docs/decisions/` note first: whether §3 states an
enforced property or an intended one, and how it says which.

**What was measured, 2026-09-01.** [[records/baseline-alignment]] holds 36
rows, 27 open. Of the 13 added that day, four cite the spine directly: BA-24
(`PRINCIPLES.md`), BA-30 (`MAP.md:5`, `:37-40`), BA-31 (`docs/banks/profile.md`
and `docs/definitions/testing-floors.md`), BA-36 (`README.md:63`, `CLAUDE.md`).

## Why this arc exists separately from its goal

[[goals/presentability]] cannot be finished from inside the repo: every criterion
is about a reader who is not us. This arc holds the part that can be done from
inside — making the documents true, findable and consistent — and stops at the
line where the remaining question is whether an outsider actually understood.
