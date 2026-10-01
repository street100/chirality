# Enforcement, 2026-09-30 to 2026-10-01: the source reports

Spent material, kept because tracked documents rest on it. Every file here was
written by an agent of one session against `2faa028`, in a 50-commit shallow
clone, and sat in that session's scratch directory until the author asked on
2026-10-01 for the untracked work to be recovered. The tracked documents at
their current versions win wherever one of these disagrees with them.

| file | what wrote it | where its content landed |
|---|---|---|
| `orientation-2faa028.md` | the synthesizer of a 21-agent workflow, from ten slice reports each checked by a verifier: 251 claims, 240 held, 10 held with a citation a line or two off, 1 false | [[goals/enforcement]] §State, [[status-ledger]], [[arcs/enforcement-arc]] and `records/enforcement-arc.md` EN-39. Its cost is in `.planning/protocol/dispatch.md` §What a fan-out costs |
| `cascade-A-principle-obligations.md` | one research agent: the obligations `PRINCIPLES.md`, the settling decisions and `docs/definitions/design-principles.md` imply | [[bug-classes]] §From the principles, the 86 obligations |
| `cascade-B1-class-cascade.md` | one agent: the cascade cells, J to M, for each of the 28 classes carried before | [[bug-classes]] category tables and §The cascade |
| `cascade-B2-judgment-coverage.md` | one agent: the 38 `Judg` and 10 `Reason` constructors, fixture and mutant per arm, with 12 unfixtured refusals probed on the shipping binary | [[bug-classes]] §Counts, [[goals/enforcement]] §State, and `FE4` in `.planning/DISPATCH-QUEUE.md` |
| `cascade-C-cross-arc.md` | one agent: enforcement-shaped rows in the other arcs, and which arc owns each class | the `owner` cells of [[bug-classes]], and `FE2` to `FE12` |
| `cascade-D-apparatus.md` | one agent: the gates themselves, tally, depth, registration, closure, fixpoint, ledger against dispatch | [[goals/enforcement]] condition 4, `enforcement/N36` to `N38` |

⚑ The reports cite `scratchpad/...` paths, such as probe programs under
`scratchpad/bc/probe/` and a row index in `scratchpad/rowlines.txt`. Those lived
in the session's scratch directory and are gone. A claim resting on one is
re-measured against the tree before it is relied on.

⚑ What this session found after these reports was written into the tree the
same day: the author's rulings in `records/author-calls.md`, FD-63 and FD-64 in
`records/findings.md`, the grade architecture in
`.planning/GRADE-ARCHITECTURE.md`, the errors-as-values principles in
[[arcs/errors-as-values-arc]], and the syntax discussion in
`.planning/SYNTAX-REWORK.md`.
