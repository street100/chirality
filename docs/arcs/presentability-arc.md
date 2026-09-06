---
node: arc-presentability
layer: navigation
related: [arcs/README, goals/presentability, goals/presentability, arcs/binary-split-arc, records/baseline-alignment, index]
status: current
updated: 2026-09-04
---

# Arc: presentability and documentation

- goal: [[goals/presentability]]
- reserved element block: **none**. Rows carry arc-local ids `D1` and up, per
  [[decisions/decision-work-ids]], and map to `unminted` until a block exists.
- checklist: [[records/baseline-alignment]], the rows in the reader-facing spine
- sibling arcs under the same goal: [[arcs/baseline-alignment-arc]], [[arcs/binary-split-arc]]

## What this arc is

The reader-facing surface, aimed at someone outside the project: `README.md`,
`MAP.md`, `CONTENTS.md`, `PRINCIPLES.md`, `docs/index.md`, and the doc tier those
four point into.

It is not the claim-fixing arc. [[arcs/baseline-alignment-arc]] establishes
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
   `chirality verify` was cited 14 times on 2026-09-01 and does not exist
   (BA-31). Observed by `ledger-lint` checks A and G. Check A reads 0 on
   2026-09-04 and BA-23's resolver defect stands under it; check G reports 74.
5. **The doc roles in `MAP.md` match the tree.** `MAP.md` sorts docs by role;
   `goals/`, `arcs/` and the records tier are new roles and are not in it.
   Observed by comparing the list to `ls docs/`.
6. **A tool binary carries only what the tool needs.** Delegated to
   [[arcs/binary-split-arc]]; listed here because it is a requirement of the
   goal, and an evaluator who measures a 780 KB text tool draws a conclusion
   about the architecture.

## Roster

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `presentability/D1` | reconcile the spine against the open problem rows in requirement 2 | claims | decision | new | 2 | open | `unminted` |
| `presentability/D2` | `MAP.md` doc-role table gains `goals/`, `arcs/`, records | roles | decision | new | 5 | open | `unminted` |
| `presentability/D3` | retire or build `chirality verify` and its 14 citations | claims | tool | new | 4 | open | `unminted` |

### Coverage

⚑ **Requirements 1 and 3 are served by no row**, enumerated as `GAP-09` (the
fresh-clone build running end to end) and `GAP-10` (every number in the spine
current or dated). Requirement 6 is delegated to [[arcs/binary-split-arc]] and
its `B5`, which the arc's own text records.

Requirements 2, 4 and 5 are served: 2 by D1, 4 by D3, 5 by D2. Every row serves
one, and every `origin` is `new`.

No element number is minted. This arc has no reserved block, and the deferral
rule in [[working-discipline]] forbids naming an element that does not exist. An
arc with no block gets one from the author.

## Resume state

**Where a session picks up.** Requirement 2, and specifically the `PRINCIPLES.md`
half of BA-24. `PRINCIPLES.md:62` says "One atom with no exemptions" and `:89`
says "the port-check is the type-check"; a pure `->` function performs a syscall
and is accepted. `README.md`, [[status-ledger]] and `docs/banks/effect-and-alarm`
all disclose this accurately; the spine's most-read document is the one that does
not.

**What blocks it.** Nothing mechanical. It is a wording decision about a
principle, so it may want a `docs/decisions/` note first: whether §3 states an
enforced property or an intended one, and how it says which.

[[records/baseline-alignment]] holds 44 rows, 34 open, measured 2026-09-04. It
held 36 rows with 27 open on 2026-09-01. Four cite the spine
directly: BA-24
(`PRINCIPLES.md`), BA-30 (`MAP.md:5`, `:37-40`), BA-31 (`docs/banks/profile.md`
and `docs/definitions/testing-floors.md`), BA-36 (`README.md:63`, `CLAUDE.md`).

## Working queues, and why there are two of them

Both are author directives opened 2026-08-31, and they are deliberately kept
apart from each other and from this file. Both are tracked, with the rest of
`.planning/`, since 2026-09-01 (`docs/decisions/decision-ai-tier.md`); `git
ls-files .planning` returned 145 files on 2026-09-04. **The fresh-clone argument
this paragraph used to carry is retired.** What stands in its place is the tier
split: `docs/` and `records/` are written for a human reader and the queues are
written for a session, so a finding a second reader needs goes to `records/`.
`records/baseline-alignment.md` BA-44 holds the measurement.

| file | what it does | what it is not |
|---|---|---|
| `.planning/DOC-AUDIT-QUEUE.md` | per-document audit against the authority gradient: build-state truth, line-evidence truth, settled-decision conformance, graph integrity, refraction honesty, plus goal / limits / structure | not a prose pass |
| `.planning/DOC-CLEANUP-PASS.md` | cut dead references, cut excess, de-complicate the prose, gated on `tools/prose-lint/prose-lint.sh --regress` | not a claim check |

Both run **serial, one document and one agent at a time**, by standing user
directive.

Two facts from those queues that a reader of this arc needs, repeated here
because the queues are the session tier and a reader handed `docs/` never opens
them:

- **Deferred is not deleted.** The ownership-and-trust track documents stay and
  their content stays. They are only required to be honestly marked unbuilt. See
  [[goals/ownership-and-trust]].
- **The two bootstrap documents are an unresolved author call.**
  [[bootstrap]] is the re-bootstrap climb with its four stages and gates;
  [[bootstrap-sequence]] is a foundation note. Both landed in `definitions/` from
  different places in the old tree. Whether they are one concept or two has not
  been decided, and auditing either is worthless until it is. This is a
  requirement-4 item that no element covers.

## Scope

[[goals/presentability]]'s outside-reader criteria cannot be finished from inside
the repo. This arc holds the part that can be: making the documents true,
findable and consistent.
