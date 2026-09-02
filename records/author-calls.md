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
| `docs/decisions/decision-lane-split.md`'s home | it sits at root and is orthogonal to the goal-arc-element tiers. Left at root because two live sessions read it |
| the binary split's goal | `docs/arcs/binary-split-arc.md` ladders up to nothing written down |

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

## Added by the E173 SPEC audit

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
  indifferent to it; (c) something else. Blocks the E173 SPEC audit.
- **E173 gate row G9's wall-clock threshold.** G9 gates on a chirality-to-awk
  ratio `<= 1.0` and nothing has measured that number. §4 step 3 states the arrow
  as `O(n x ‖pat‖² log ‖pat‖)`, a merge sort over the live set at every input
  byte, against awk's compiled DFA with no per-byte allocation. Removing the 31
  passes is a large win and landing at or under 1.0 is a bet. Is `<= 1.0` the bar
  slice 1 must clear to land, or is the gate the pass count with the wall clock
  recorded rather than gated?
