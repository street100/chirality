---
node: arc-memory-discipline
layer: navigation
related: [arcs/README, goals/local-ai, goals/self-hosting, benchmarks/text-matcher-allocation, records/author-calls, status-ledger, index]
status: current
updated: 2026-09-06
---

# Arc: the value-cell heap's discipline

- goals: [[goals/local-ai]], condition 1: "a gated multi-agent run executes end
  to end inside this tree." This arc decides whether that run survives its own
  allocation.
- reserved element block: `E81-E85`, already minted. Bands may overlap and are
  advisory ([[decisions/decision-lane-split]], ruled 2026-09-06)
- build-state authority: [[status-ledger]]

Opened 2026-09-06. The design has existed since 2026-08-05 in
`.planning/MEMORY-DISCIPLINE-ARC.md`, five slices deep with `E81` built, and it
held no tracked arc. `records/author-calls.md` carried it as "which arc owns the
allocation gap" with two arguable routes, when what it needed was an arc file.

## Why this arc exists

chirality has two heaps and only one has a discipline seam. The byte-`Pool` heap
is governed by `(memory linear|region)` profile clauses and was built as `E22`.
The value-cell heap is governed by nothing. Every constructor bumps `heapptr`
with no reclamation on any path a compiled program takes, so peak RSS equals
total bytes ever allocated where it should equal the live set.

[[arcs/transport-arc]] delivers the model call and this gap decides whether the
run survives it.

## What the tree already holds

| what | where | rung |
|---|---|---|
| the `Alloc` policy seam and `alloc-bump` | `E81`, built at `d6ad519` | IMPLEMENTED |
| the byte-`Pool` discipline it parallels | `E22`, `(memory linear\|region)` | IMPLEMENTED |
| `mem-region`, the only reclamation discipline in the tree | `lib/memory/` | SEEDED, zero importers |
| the `Mach` record-of-functions precedent the seam copies | `mach-x64`, `mach-listing` | ENFORCED |

Four of the six modules under `lib/memory/` have zero importers, `mem-region`
included.

## What is missing, and its structure

`E81` gave allocation a discipline dimension over the `Mach` seam. The four
slices above it each add one discipline, and the last composes them.

| group | owns |
|---|---|
| `seam` | the policy record and the bump default. Built |
| `discipline` | region, reuse and destination-passing, one slice each |
| `compose` | per-phase and per-runtime selection by profile |

### The edge that runs against the order

`compose` reaches back into `seam`: a profile selecting `{ISA} x {discipline}`
independently is what `E81` was shaped for, so the last slice is the one that
proves the first was right.

## REQUIREMENTS

1. **Peak is the live set, not the total.** Observed as peak RSS on the
   default-scope projection falling below this box's memory.
2. **A discipline is selected by profile**, per phase and per runtime, and the
   seam is erased at compile time by `specialize-singletons`.
3. **The reclamation discipline in the tree is reached.** `mem-region` has zero
   importers today.
4. **One `alloc-region` runs on every backend.** The discipline is
   ISA-agnostic; ISA-specific allocation assembly stays in `Mach` primitives.

## Roster

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `memory-discipline/M1` | the `Alloc` policy seam and `alloc-bump`: the discipline dimension over the `Mach` seam, threaded orthogonally so a profile selects ISA and discipline independently | seam | primitive | new | 2 | built | `E81` |
| `memory-discipline/M2` | `alloc-region`: phases run in regions reset at their boundaries, so peak becomes the max-phase live set | discipline | law | new | 1 | open | `E82` |
| `memory-discipline/M3` | `alloc-reuse`, FBIP: a linear drop becomes an in-place reuse, and the map churn goes | discipline | law | new | 1 | open | `E83` |
| `memory-discipline/M4` | `alloc-dps`: a destination-passing emit buffer, and `nb-bcat`'s quadratic goes | discipline | law | new | 1 | open | `E84` |
| `memory-discipline/M5` | compose and grade: per-phase and per-runtime profile composition, with an optional static size bound from `E38` | compose | law | connect | 2 | open | `E85` |
| `memory-discipline/M6` | `mem-region` is reached, or it moves to SEEDED with the reason. It is the only reclamation discipline in the tree and nothing imports it | discipline | tool | connect | 3 | open | `unminted` |
| `memory-discipline/M7` | one `alloc-region` runs on every backend, with the ISA-specific allocation assembly left in `Mach` primitives | discipline | law | new | 4 | open | `unminted` |

### Coverage

Every requirement is served: 1 by M2, M3 and M4; 2 by M1 and M5; 3 by M6; 4 by
M7. Every row serves one. `M5` and `M6` are `connect`: `E38`'s grading and
`mem-region` are built and nothing reaches either.

## Resume state

`E81` is built at `d6ad519` and `M2` is next, the slice the dependency graph
puts first above the seam. `.planning/MEMORY-DISCIPLINE-ARC.md` holds the
per-slice design, its gates and its sizes, and is the authority for how each
slice is cut.

The projection this arc exists to close: **~6.3 GB at the default scope against
3.85 GB with no swap**, after `9f46c6c` already cut peak 58.0%.
[[benchmarks/text-matcher-allocation]] holds the measurement, taken 2026-09-02
at `c23947e`.
