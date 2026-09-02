---
node: records-author-calls
layer: record
related: [records/README, records/consolidation-handoff, arcs/README, elements/README, index]
status: current
updated: 2026-09-01
---

# Open author calls

Decisions only the author can make, that in-scope work is waiting on. Hoisted
from the root handoff on 2026-09-01; it was the one part of that file with no
tracked home.

This is not a findings list. A finding is a claim beside a measurement and lives
in [[records/baseline-alignment]] or [[records/findings]]. A row here is a fork
where the tree does not settle the answer and a pass must stop.

| the call | why it is blocking |
|---|---|
| Principle 1 has no Honest limit | The broadest claim in the file, the only one without one |
| P5's present tense | "a split value whose only exit is a guarded combine-process": CONFORMANCE-MAP calls it vapor beyond the seed |
| P3 vs open-edges | P3's limit says the membrane's inward reach is open; `open-edges` records it largely answered |
| `decision-split-checker` | `status: draft`, while PRINCIPLES states its content settled |
| what a `docs/elements/` file holds | one file per element, one per band, or a tracked index. `docs/elements/README.md` states the fork |
| Python: outside the tree, or inside it | [[goals/self-tooling]] and [[goals/local-ai]] point opposite ways, and the call decides whether they conflict at all. The two readings are below |
| A reserved element block for [[goals/local-ai]] | Its transport arc and its tuning arc write `UNASSIGNED` and stop. `docs/decisions/decision-lane-split.md` reserves `E184-E189` and `E190-E195` and nothing else |

## Closed since the hoist

- **`LANES.md`'s home** — it sat at root and was orthogonal to the goal-arc-element
  tiers. Moved 2026-09-01 to `docs/decisions/decision-lane-split.md`: it settles a
  division of work and reserves element bands, which is a decision, and 16 tracked
  files cite it for those bands.
- **The binary split's goal** — the arc laddered up to nothing written down. The
  author wrote [[goals/presentability]] on 2026-09-01 and assigned it there.

## Added by the consolidation

- **A reserved element block for [[arcs/text-tools-arc]]**, or a ruling that it
  mints into an existing one. Its P2 score, P3 edit script and P4 stable address
  are unnumbered and cannot be scheduled. `docs/decisions/decision-lane-split.md`
  reserves `E184-E189` and `E190-E195` and nothing else.
- **`.planning/METIS-PORT-SPEC.md`** is cited 5x as the contract for E133-E136 and
  is present nowhere in the tree. Whether those four built manas elements are
  re-grounded on a surviving document or recorded as ungrounded is a call.
- **The shape of a tracked element row** — one file per element, one per band, or
  a single index. `docs/elements/README.md` states the fork; the catalog and
  ledger were moved without reshaping so the question stays open.

## Added by the E173 SPEC audit, and closed

Both were raised by the SPEC-level audit at `4f233d4` and ruled on 2026-09-01.
The rulings are applied in `docs/elements/specs/E173-total-matcher-SPEC.md`.

- **E173 decision 4's leftmost-longest, which does not fall out of `norm`.** §4
  step 3 grounds the semantics in *"New threads are appended, so starts run
  non-decreasing along the live list"*, and `norm` returns the list sorted by
  `pat`. `Pat` carries no start, so from step 2 onward the order is `pat`-order
  and the `from` values in it are arbitrary. `list-sort` is stable and
  `list-dedup-adj` keeps the first of a run (`lib/prelude/list.chiral:113-145`,
  `:156`), so the survivor of a `pat`-run is whichever thread was earliest in the
  pre-sort list, which is the previous step's `pat`-order. Counterexample, under a
  `pat-cmp` that follows the `data Pat` declaration order (`p-alt` before
  `p-star`): pattern `a*|aa*` over `"aa"`. After byte 0 the live set is
  `[(0, a*), (1, a*|aa*)]` and `norm` returns `[(1, alt), (0, star)]`; after byte
  1 both derive to `a*`, the derived list is `[(1, a*), (0, a*)]`, and the dedup
  keeps `from = 1`. The thread anchored at 0 is dropped and the longest match at 0
  can no longer be found. Three shapes, and the SPEC settles none of them: (a)
  `norm` sorts with a `(pat, from)` comparator and dedups with the `pat`-only one,
  which the two primitives already allow since each takes its comparator
  separately, and which makes mutant M5 wrong as written; (b) leftmost-longest
  moves to slice 2 with the priority-ordered residual list decision 4 says it
  needs, and slice 1 ships an unordered set for the counting consumer that is
  indifferent to it; (c) something else.
  **Ruled 2026-09-01: shape (a).** `norm` sorts with a `(pat, from)` comparator
  and dedups with the `pat`-only one. The two primitives already allow it,
  because each takes its comparator separately
  (`lib/prelude/list.chiral:143`, `:184-186`), so no new primitive is owed.
  Sorting on `(pat, from)` puts the least start adjacent-first inside each
  `pat` run and the `pat`-only dedup keeps it. Leftmost-longest stays in
  slice 1. Applied in SPEC §4 step 3: two declared comparators, the old
  append-order rationale replaced by the sort key, and mutant M5 rewritten to
  neuter the sort key's `from` half.
  ⚑ The counterexample above is over-strong as spelled. `pd-cat` builds
  `(p-cat p-nil r)` without collapsing the `p-nil`
  (`docs/examples/E173-total-matcher.md:358-360`), so the residual of `a*` is a
  `p-cat` node, which sorts ahead of the freshly spawned `p-alt` and leaves
  that input's start order intact under the old `norm` too. What the row
  establishes is the class: a `pat`-only sort makes the survivor a function of
  the pre-sort order, and the pre-sort order is `norm`'s own previous output.
  Shape (a) removes the dependence, so the ruling rests on the property and
  not on that input. The SPEC's G6(a) asserts the property directly.
- **E173 gate row G9's wall-clock threshold.** G9 gates on a chirality-to-awk
  ratio `<= 1.0` and nothing has measured that number. §4 step 3 states the arrow
  as `O(n x ‖pat‖² log ‖pat‖)`, a merge sort over the live set at every input
  byte, against awk's compiled DFA with no per-byte allocation. Removing the 31
  passes is a large win and landing at or under 1.0 is a bet. Is `<= 1.0` the bar
  slice 1 must clear to land, or is the gate the pass count with the wall clock
  recorded rather than gated?
  **Ruled 2026-09-01: record, do not gate.** G9 keeps its correctness half,
  now the corpus differential against the awk tool, and the wall clock becomes
  a measurement written down with its host and its date under
  `docs/benchmarks/`. Gating on a number nothing has measured would block a
  correct implementation for a reason unrelated to correctness, and the ratio
  can be tightened later from a real number. Applied in SPEC §5: G9 rewritten,
  a recorded-not-gated bullet naming
  `docs/benchmarks/text-matcher-prose-lint.md`, and the cost of the ruling
  written down in §6 residue, which is that the n-pass driver shape now ships
  with no gate row that can convict it.

## Added by the local-ai goal, 2026-09-01

### Python: outside the tree, or inside it

`docs/goals/self-tooling.md` states done as no `.py` file anywhere under
`/workspace/chirality`, with `tools/` deleted. `docs/goals/local-ai.md`
criterion 4 carries the author's phrase *"wrap to use python for (fine tuning,
creating, full growing and changing set of interactions) transformer types"*.
Two readings survive that sentence and they permit different things.

| reading | what it permits | what it costs |
|---|---|---|
| Python as a spawned external process, its scripts living outside this repo | The whole of criterion 4, through E33's typed spawn, with [[goals/self-tooling]] intact and its file count still headed to zero. ollama and llama.cpp get wrapped by the same mechanism, so the author's "for now" clause needs one seam and not three | The training scripts live in a second repository. This tree cannot gate them and cannot claim them, so a capability the goal names is verified nowhere here |
| `.py` files inside the tree, under a carve-out | The scripts are tracked, testable and versioned beside the chirality that calls them | [[goals/self-tooling]]'s done condition becomes false as written and has to be reworded, which `docs/goals/README.md` makes a decision before it is an edit. `tools/` cannot be deleted |

Under reading one the two goals are independent. Under reading two one of them
has to change. Nothing in the tree settles it, which is why a pass stops here.

The mechanism the first reading rests on is built: E33 `proc-spawn` returns one
`SpawnRes` with a linear `Reap` obligation (`lib/runtime/proc.chiral`), and
`raw-proc-spawn` maps to `nb-run-cmd` at
`lib/lowering/tal/crossing-wraps.chiral:54`.

### A reserved element block for the local-ai goal

The transport arc (give `http-request`, `backend-open` and `chat-open` a runtime
referent) and the tuning arc (criterion 4) have no block, so every row in them
writes `UNASSIGNED`. This is the same block that stops
[[arcs/text-tools-arc]]'s P2, P3 and P4 rows, and that arc already carries its
own row above. One ruling can cover both.

The scriba half of this goal is exempt and needs no ruling: `S#` is namespaced
by its own letter per `docs/elements/ledger.md`, `S18` already has a SPEC at
`docs/elements/specs/S18-scriba-record-SPEC.md`, and
`.planning/SCRIBA-PRIMITIVE-CHECKLIST.md` numbers `S18` through `S30`.

`.planning/LOCAL-AI-ARC-REALIGNMENT.md` is the proposal both calls block.
