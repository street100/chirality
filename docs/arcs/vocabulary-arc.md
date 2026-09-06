---
node: arc-vocabulary
layer: navigation
related: [arcs/README, goals/own-web, goals/display, arcs/canvas-arc, arcs/display-calculus-arc, arcs/file-types-arc, banks/text, decisions/decision-work-ids, records/author-calls, status-ledger, index]
status: current
updated: 2026-09-05
---

# Arc: the document vocabulary

- goal: [[goals/own-web]], condition 1
- reserved element block: **none**. Rows carry arc-local ids per
  [[decisions/decision-work-ids]] and map to `unminted`. This arc keeps two
  letters, `M` for the mark and `F` for the form it becomes, because
  `.planning/OWN-WEB-GAP.md` already cites them and renumbering would break
  every citation. [[arcs/display-calculus-arc]] keeps four letters for the same
  reason.
- build-state authority: [[status-ledger]]

Opened 2026-09-05 by author statement. The done-condition: **a document is a
typed value with one text form, and nothing that reads it can be surprised by
it.**

This arc is **stage 4 of the pipeline** `.planning/OWN-WEB-GAP.md` lane P
tables: the waist that many lenses read into and many views read out of.
Everything in [[arcs/canvas-arc]] narrows through it, which is why it is first.

## What is in the tree already

Measured 2026-09-05.

| where | what |
|---|---|
| `lib/prelude/doc.chiral:77` | the closed six-constructor `Doc` algebra, Lindig's strict renderer. **A layout algebra where a document vocabulary is wanted**: it has no heading, no list, no link and no table |
| `lib/prelude/doc.chiral:83` | `d-tag` carries a `Str` over an open keyspace, which is the only extension point `Doc` has and the wrong one to use |
| `lib/text/matcher.chiral` | the idiom the vocabulary copies: a closed constructor set as the value of a class |
| `lib/protocol/apc.chiral:48` | `block-id`, a content address per addressable node, derived and never stored, recomputed and verified by the decoder. E112, built |
| `lib/surface/sexp.chiral` | E1, a byte-directed S-expression reader, pure, errors as values. **Stage 2 arrives free for any s-expression-shaped lens** |
| `lib/surface/pretty.chiral` | E181, `Term` to `Doc`, and its output is chirality source. The working proof that a round-trip law is gateable |

`Doc` is inside the compiler's blob, imported by `lib/typing/diag.chiral` and
`lib/surface/pretty.chiral`, and its algebra is fenced by two run mutants. So
extending it owes a fixpoint, which is why the vocabulary is a new type in a
new module that lowers into `Doc` for text surfaces.

## What is missing

Grepped 2026-09-05: no document file kind, no element sum split by context, no
role type, no declared `State` or `Request` sum, no chunked-value commitment.

## REQUIREMENTS

1. **Invalid nesting is unconstructible.** The constructor set is split by
   context, so the defect has no representation and the validator is retired.
2. **The mark round-trips through its own text form**, byte-identical, in a
   gate. `C1C2`'s gate root is the shape: exit 1 on today's tree, exit 42 once
   the property holds.
3. **An unknown mark is refused and an unhandled version is named.** The
   constructor set is closed, and forward compatibility is a version field the
   reader totals over, so degradation is never silent.
4. **The role is a required field and the document carries no style.** A theme
   is the host's value, which is `display-calculus/C5` and `H4` pointed at a
   document the host did not write.
5. **A document declares its size bound and a reader demands it before
   accepting anything.** The bound rides the type, the way `pool.port:3-5` puts
   a size in the port type.

## Roster

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `vocabulary/M1` | the mark has a file kind and the loader checks it. not started. Behind the file-kind decision below | mark | primitive | new | 2 | open | `unminted` |
| `vocabulary/M2` | a generated document is a program that emits a mark, so the language is the template language. not started | mark | law | new | 2 | open | `unminted` |
| `vocabulary/M3` | the round-trip law and its gate. not started. Requirement 2 | mark | law | new | 2 | open | `unminted` |
| `vocabulary/M4` | an unknown mark is refused. not started | mark | law | new | 3 | open | `unminted` |
| `vocabulary/M5` | the version field, and a total handler over it. not started | mark | primitive | new | 3 | open | `unminted` |
| `vocabulary/M6` | a role carried, and no style. not started. Requirement 4 | mark | primitive | new | 4 | open | `unminted` |
| `vocabulary/F1` | closed element sums per context. not started. Absorbs `display-calculus/E1` | form | primitive | new | 1 | open | `unminted` |
| `vocabulary/F2` | the size bound in the type. not started. Requirement 5 | form | primitive | new | 5 | open | `unminted` |
| `vocabulary/F3` | node addressing. **the shard is built.** `apc.chiral:48` ships with two importers under `tools/`. Measuring its reach is the class of row `display-calculus/A1` is | form | primitive | connect | 1 | open | `unminted` |
| `vocabulary/F4` | one text form, and nothing renders from it. not started. Absorbs `display-calculus/E4` | form | law | new | 4 | open | `unminted` |
| `vocabulary/F5` | two readers agree by construction, compared structurally. not started. `prog/manas/contract/golden.chiral` is the precedent | form | law | new | 2 | open | `unminted` |
| `vocabulary/Q1` | the round-trip gate. not started. Pairs with M3 | gate | tool | new | 2 | open | `unminted` |

### Coverage

Groups are the mark itself, the document form, and the gate over both. Every
requirement is served: 1 by F1 and F3; 2 by M1, M2, M3, F5 and Q1; 3 by M4 and
M5; 4 by M6 and F4; 5 by F2. Every row serves one.

## Resume state

**Where a session picks up.** The file-kind decision, which is `M1` and blocks
the first three rows and stage 1 of the pipeline. `.manifest` fits a static
document and refuses a generated one, because a manifest's every `def` body is
a literal, so either a document is a manifest and generation is `M2`'s separate
`.prog`, or `MAP.md` grows a sixth kind. `.planning/MANIFEST-DESIGN-MAP.md` and
`.planning/FILE-KIND-STRUCTURES.md` are the inputs and
[[arcs/file-types-arc]] is the arc that owns `MAP.md`'s kinds.

**What blocks the arc.** No reserved element block, so every row writes
`unminted` and none can be scheduled as catalog work. That is the standing
author call [[records/author-calls]] carries.

**What is reachable now.** Every row here is a local primitive over a file on
disk, with no crossing and no compiler change, so the arc sits inside the
standing scope ruling whole.

**One shard is built and unmeasured.** `F3`'s `block-id` reaches two importers
under `tools/` and no shipping producer, which is the same condition
`display-calculus/A1` records for the `Doc` to `Rendering` path.

**The design is `.planning/OWN-WEB-GAP.md`**, lanes M, F and P, and its §5
carries the decisions this arc waits on.

**Row state and order live in `.planning/OWN-WEB-CHECKLIST.md`**, which carries
both arcs' rows grouped by pipeline stage, with `design`, `blocked`, `decide`
and `owed` against `docs/decisions/decision-design-before-mint.md`.
