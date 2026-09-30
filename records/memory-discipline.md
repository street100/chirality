---
node: records-memory-discipline
layer: navigation
related: [records/README, arcs/memory-discipline-arc, records/author-calls, arcs/text-tools-arc, arcs/parts/lowering-and-emit-LE25, index]
status: current
updated: 2026-09-29
---

# Memory discipline arc

Every row is a claim [[arcs/memory-discipline-arc]] makes, beside what was
measured against it. The prefix is `MD`. [[records/README]] fixes the six fields
and the rule that a row whose `checked:` date predates the last change to the
files it cites is unverified.

The file opens with `MD-01`, created by the first revisit this arc's skill owed
a row, on the precedent of [[records/text-tools]]. The arc header points here.

### MD-01 three consumers need an in-place indexed write and no roster row held it

- state:    FIXED
- claim:    `docs/arcs/memory-discipline-arc.md` at `2a8c0af` carried `memory-discipline/M4` as *"`alloc-dps`: a destination-passing emit buffer, and `nb-bcat`'s quadratic goes"*, on element `E84`, and four requirements, none of which names an indexed write. [[arcs/text-tools-arc]] and [[arcs/parts/lowering-and-emit-LE25]] both name `M4` as the nearest home of that write.
- measured: the trigger is the `ruled` row in [[records/author-calls]] whose question opens *"Whether `lowering-and-emit/LE25` mints as ordered `Map Str` environments now"*: option (b), the indexed write first and `LE25` over it. ⚑ **Three consumers need one write, over three element types.** Text tools P2, P3 and P5 need it on an `I64` buffer (`docs/arcs/text-tools-arc.md:154-156`, `:239-241`, `:465-476`, which say no roster row holds it); `M4` needs it on bytes for the builder that removes `nb-bcat`'s quadratic (`docs/elements/catalog.md:334`); `LE25` needs a table that holds a `TalSig`, a boxed value (`docs/arcs/parts/lowering-and-emit-LE25.md:168-173`). ⚑ **The tree holds a linear write in place, over bytes only.** `pool-write` (`lib/ports/pool.port:27`) copies into the pool in place, and `mem-put-checked` (`lib/memory/mem-linear.chiral:26-28`) bounds its offset by refinement. Each write takes a `Bytes` cell and each `pool-read` (`lib/ports/pool.port:30`) returns a fresh one, and the pool sits in the byte heap, so it carries no `I64` word at one store and no boxed value. Every value-cell `Bytes` write copies the buffer (`lib/lowering/tal/bytes.chiral:603-610`). ⚑ **M4 does not widen.** `M4` is a discipline `law` whose gate is an emit peak flat in output size, post-rung-1 (`.planning/MEMORY-DISCIPLINE-ARC.md:94`), and `E84` is minted as that discipline (`docs/elements/catalog.md:334`). Carrying the buffer inside it would make two arcs' rows wait on a discipline and give one element two things to be. The write is a primitive the discipline consumes, so it takes its own row. ⚑ **One mechanism carries every element type.** A byte-only or `I64`-only row would stand in for the shared write with the rest deferred, which `.planning/protocol/reconcile.md` §"Proper or not at all" refuses. `M8` carries all three element types; how a byte packs beside a word is its design's question. The verdict is RESCOPE: REQUIREMENT 5 added, `M8` added (`seam`, `primitive`, `unminted`), `M4`'s cell now builds on `M8` with `E84` unchanged, coverage and resume state updated. The arc side moved. ⚑ **Residue left for other runs.** `docs/arcs/text-tools-arc.md:154-156`, `:239-241` and `:465-476` and `docs/arcs/parts/lowering-and-emit-LE25.md:172-173` still read that no row holds the write, or that `M4` does; each is outside this run's write surface.
- evidence: records/author-calls.md:533; docs/arcs/memory-discipline-arc.md; docs/arcs/text-tools-arc.md:154-156, :239-241, :465-476; docs/arcs/parts/lowering-and-emit-LE25.md:168-173; lib/lowering/tal/bytes.chiral:603-610; lib/memory/mem-linear.chiral:26-28; lib/ports/pool.port:27, :30; docs/elements/catalog.md:334; .planning/MEMORY-DISCIPLINE-ARC.md:94
- checked:  2026-09-29
- element:  `memory-discipline/M8`, `unminted`; its `element-design` runs next, and `lowering-and-emit/LE25`'s mint waits on it

### MD-02 the M8 buffer stays effectful under E159, and a seal owed separately gives its pure consumers purity

- state:    FIXED
- claim:    `docs/arcs/parts/memory-discipline-M8.md` at `4269f04` held §5 question 1 as NEEDS-AUTHOR and recommended splitting E159 so the buffer's operations carry `->`, and counted the loader change in its 450-line size.
- measured: the trigger is the `ruled` row in [[records/author-calls]] whose question opens *"Whether E159 tells a memory porttype from an authority porttype"*: the operations stay `=>`, E159 is unchanged, and a sandboxed seal in the shape of `runST` gives a pure block its purity. The author then ruled that the buffer and the seal are two separate items. The artifact moved: question 1 is RESOLVED, the catalog row states `=>`, and the size drops to about 420. `bin/chirality check` probes S1 to S16 over scratch sources measured the seal. The kernel takes a rank-2 block and refuses a result type naming the block's region (`load: unknown name s`). It accepts a block calling an unrelated `=>` extern, because the arrow is one bit (`lib/surface/syntax.chiral:12`). It lets a handle escape inside a closure whose type does not name the region, linear or not (S15). With no seal, a returned closure over a q1 buffer is called twice and checks OK (S16), which contradicts `docs/examples/E39-effect-row.md:157-159`. So the seal needs the region named in the effect row, which `docs/decisions/decision-effect-facets.md:77-83` reserves and nothing builds, plus `E171`. NEEDS-AUTHOR 2 stands. A value-only read lowers to one load, since erase routes by name and ignores the arrow (`lib/lowering/tal/erase.chiral:157-172`, `:217-227`). But a value-only read consumes a linear handle (S6 refused, S10 OK), and this row keeps the linear handle so that it is complete without the seal.
- evidence: records/author-calls.md:535-536; docs/arcs/parts/memory-discipline-M8.md §3 item 7, §5 question 1 and NEEDS-AUTHOR 2, §6; lib/surface/syntax.chiral:12; lib/typing/kernel.chiral:26; lib/lowering/tal/erase.chiral:157-172, :217-227; docs/decisions/decision-effect-facets.md:77-83; docs/examples/E39-effect-row.md:157-159; docs/elements/ledger.md:121; PRINCIPLES.md:55-58
- checked:  2026-09-30
- element:  `memory-discipline/M8`, `unminted`, still `designed` and blocked on NEEDS-AUTHOR 2 alone; the seal and the closure-capture defect are recorded in its §6 "Needed and unrostered" and have no roster row
