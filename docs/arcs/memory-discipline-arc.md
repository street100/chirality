---
node: arc-memory-discipline
layer: navigation
related: [arcs/README, goals/local-ai, goals/self-hosting, benchmarks/text-matcher-allocation, records/author-calls, records/memory-discipline, arcs/text-tools-arc, arcs/parts/lowering-and-emit-LE25, arcs/parts/memory-discipline-M8, decisions/decision-effect-facets, status-ledger, index]
status: current
updated: 2026-09-30
---

# Arc: the value-cell heap's discipline

- goals: [[goals/local-ai]], condition 1: "a gated multi-agent run executes end
  to end inside this tree." This arc decides whether that run survives its own
  allocation.
- reserved element block: `E81-E85`, already minted. Bands may overlap and are
  advisory ([[decisions/decision-lane-split]], ruled 2026-09-06)
- build-state authority: [[status-ledger]]
- checklist: [[records/memory-discipline]], prefix `MD`, opened 2026-09-29.

Opened 2026-09-06. The design has existed since 2026-08-05 in
`.planning/MEMORY-DISCIPLINE-ARC.md`, five slices deep with `E81` built, and it
held no tracked arc. `records/author-calls.md` carried it as "which arc owns the
allocation gap" with two arguable routes, when what it needed was an arc file.

## Why this arc exists

chirality has two heaps and only one has a discipline seam. The byte-`Pool` heap
is governed by `(memory linear|region)` profile clauses, which `E22` does not carry.
The value-cell heap is governed by nothing. Every constructor bumps `heapptr`
with no reclamation on any path a compiled program takes, so peak RSS equals
total bytes ever allocated where it should equal the live set.

[[arcs/transport-arc]] delivers the model call and this gap decides whether the
run survives it.

## What the tree already holds

| what | where | rung |
|---|---|---|
| the `Alloc` policy seam and `alloc-bump` | `E81`, built at `d6ad519` | IMPLEMENTED |
| the byte-`Pool` discipline it parallels | `lib/memory/mem-linear.chiral`, `(memory linear\|region)` | SEEDED, zero importers. ⚑ **This row read `E22` at IMPLEMENTED and §2 above said the discipline *"was built as `E22`"*, both corrected 2026-09-18.** `docs/elements/ledger.md:164` reads `design` and `docs/elements/catalog.md:128` reads *"bump arena only; region *types* deferred"*, so `E22` is the allocator, region types and GC-outside-TCB beyond the bump arena and carries neither profile clause. The clauses' home module has zero importers |
| `mem-region`, the only reclamation discipline in the tree | `lib/memory/` | SEEDED, zero importers |
| the `Mach` record-of-functions precedent the seam copies | `mach-x64`, `mach-listing` | ENFORCED |
| a linear write in place, over bytes only | `pool-write` at `lib/ports/pool.port:27`, and its checked form `mem-put-checked` at `lib/memory/mem-linear.chiral:26-28`. The pool is written in place, but each write takes a `Bytes` cell and each `pool-read` (`lib/ports/pool.port:30`) returns a fresh one, and the pool lives in the byte heap, so it holds no `I64` word and no boxed value | SEEDED |
| a write into a value-cell buffer | `bput-u8` at `lib/lowering/tal/bytes.chiral:603-610` returns a fresh `Bytes`, so every indexed write copies the whole buffer | none in place |

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

1. **Peak is the live set.** Today it is the total ever allocated. Observed as
   peak RSS on the default-scope projection falling below this box's memory.
2. **A discipline is selected by profile**, per phase and per runtime, and the
   seam is erased at compile time by `specialize-singletons`.
3. **The reclamation discipline in the tree is reached.** `mem-region` has zero
   importers today.
4. **One `alloc-region` runs on every backend.** The discipline is
   ISA-agnostic, and ISA-specific allocation assembly stays in `Mach` primitives.
5. **A buffer is written in place.** One mechanism gives an indexed write that
   mutates in place and an indexed read that lowers to one load, over a handle
   tagged with its region, for every element type a consumer names: a byte for `M4`'s emit
   buffer, an `I64` word for [[arcs/text-tools-arc]] P2, P3 and P5, and a boxed
   value for `lowering-and-emit/LE25`'s id-keyed tables. Observed as a write
   whose cost does not grow with the buffer's length. ⚑ **This read *"under a
   linear binder"*, corrected 2026-09-30.** Under the author's seal ruling a
   linear handle makes every read hand the buffer back in a fresh cell, and a
   region-tagged handle inside the seal returns the value alone.
6. **A pure body uses a buffer.** A block that allocates, writes, reads and
   freezes a buffer inside a seal has a pure type, and no handle leaves the
   seal, bare or inside a closure. Observed as a `->` def calling the seal
   checking, and a returned handle and a returned closure over one each refused.

## Roster

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `memory-discipline/M1` | the `Alloc` policy seam and `alloc-bump`: the discipline dimension over the `Mach` seam, threaded orthogonally so a profile selects ISA and discipline independently | seam | primitive | new | 2 | built | `E81` |
| `memory-discipline/M2` | `alloc-region`: phases run in regions reset at their boundaries, so peak becomes the max-phase live set | discipline | law | new | 1 | open | `E82` |
| `memory-discipline/M3` | `alloc-reuse`, FBIP: a linear drop becomes an in-place reuse, and the map churn goes | discipline | law | new | 1 | open | `E83` |
| `memory-discipline/M4` | `alloc-dps`: a destination-passing emit buffer written through `M8`'s byte buffer, and `nb-bcat`'s quadratic goes | discipline | law | new | 1 | open | `E84` |
| `memory-discipline/M5` | compose and grade: per-phase and per-runtime profile composition, with an optional static size bound from `E38` | compose | law | connect | 2 | open | `E85` |
| `memory-discipline/M6` | `mem-region` is reached, or it moves to SEEDED with the reason. It is the only reclamation discipline in the tree and nothing imports it | discipline | tool | connect | 3 | open | `unminted` |
| `memory-discipline/M7` | one `alloc-region` runs on every backend, with ISA-specific allocation assembly left in `Mach` primitives | discipline | law | new | 4 | open | `unminted` |
| `memory-discipline/M8` | the region-indexed buffer: one mechanism, an in-place indexed write and a one-load indexed read, carrying bytes, `I64` words and boxed values, with the index bounded the way `mem-put-checked` bounds an offset. The handle is unrestricted and tagged with its region `s`; every operation is `=>` and names `s` in its effect; a read returns the value alone; the buffer is frozen before `M9`'s seal returns. ⚑ **This row read *"under a linear binder"* and stood at `designed`, corrected 2026-09-30.** A linear handle is what made the read allocate a result cell per read (`docs/arcs/parts/memory-discipline-M8.md:264-282`), and the author ruled the seal first with this row over it ([[records/author-calls]]). **Blocking condition**: `M9` | seam | primitive | new | 5 | open | `unminted` |
| `memory-discipline/M9` | the sandboxed seal, in the shape of `runST`: a rank-2 block `(=> (0 s (type 0)) … A)` whose operations on a region-`s` handle name `s` in their effect, so the result type and every escaping closure's type name `s` and scoping refuses them, and a seal rule that removes the region-`s` entries from the block's row and no others, which makes the block pure. The kernel takes the rank-2 block and refuses a result naming `s` today (`docs/arcs/parts/memory-discipline-M8.md:218-237`, S1, S2); the arrow is one bit (`lib/surface/syntax.chiral:12`), so a block calling an unrelated `=>` extern checks (S3) and a closure over the handle escapes (S4, S15). The region entry and the discharge rule are this row. **Blocking condition**: the Pi's effect-row seat with its row-variable seat (`docs/decisions/decision-effect-facets.md:77-83`), which is `E39`'s, at `design` and homed by nobody (`records/homing-triage.md:117`, an author call); and the call-level membrane `E171`, at `design` (`docs/elements/ledger.md:121`). Each is complete on its own and serves consumers beyond this row, so neither is rostered here. Its design owes the pinned soundness argument for `runST` and for region-carrying effects | seam | law | new | 6 | open | `unminted` |

### Coverage

Every requirement is served: 1 by M2, M3 and M4; 2 by M1 and M5; 3 by M6; 4 by
M7; 5 by M8; 6 by M9. Every row serves one. `M8` builds on `M9`. `M4` builds on `M8`, and so do
[[arcs/text-tools-arc]] P2, P3 and P5 and `lowering-and-emit/LE25`. `M5` and `M6` are `connect`: `E38`'s grading and
`mem-region` are built and nothing reaches either.

## Resume state

⚑ **2026-09-30: the seal joins the roster as `M9`, and `M8` stands over it.** The author ruled the buffer effectful and a `runST`-shaped seal its own item, then asked whether `M8` should be held complete without the seal. It should not: under the seal the handle is region-tagged and a read returns the value alone, so the linear-read fork is gone. `M8`'s design re-runs over a region-indexed handle. `MD-03` in [[records/memory-discipline]] holds the reasoning. **Next: `M9`, `element-design`**, whose preconditions `E39`'s row seat and `E171` are unhomed.

⚑ **2026-09-29: `M8` joins the roster.** The in-place indexed write had no row, and `M4`'s element `E84` names only the emit buffer. The author ruled on 2026-09-29 that the write is built properly and `LE25` over it ([[records/author-calls]]). **Next: `M8`, `element-design`.** `LE25`'s mint waits on that design. `MD-01` in [[records/memory-discipline]] holds the reasoning.

⚑ **2026-09-06: opened.** The design was five slices deep in `.planning/MEMORY-DISCIPLINE-ARC.md` since 2026-08-05 with `E81` built and no tracked arc. **Next: `M2`, `alloc-region`**, the slice the dependency graph puts first above the seam.
`E81` is built at `d6ad519` and `M2` is next, the slice the dependency graph
puts first above the seam. `.planning/MEMORY-DISCIPLINE-ARC.md` holds the
per-slice design, its gates and its sizes, and is the authority for how each
slice is cut.

The projection this arc exists to close: **~6.3 GB at the default scope against
3.85 GB with no swap**, after `9f46c6c` already cut peak 58.0%.
[[benchmarks/text-matcher-allocation]] holds the measurement, taken 2026-09-02
at `c23947e`.
