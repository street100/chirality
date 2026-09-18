---
node: arc-substrate-floor
layer: navigation
related: [arcs/README, goals/self-hosting, arcs/memory-discipline-arc, arcs/sys-face-arc, arcs/lowering-and-emit-arc, arcs/checker-core-arc, arcs/enforcement-arc, arcs/runtime-loading-arc, arcs/display-calculus-arc, banks/memory, banks/runtime, status-ledger, bug-classes, working-discipline, memory-model, decisions/decision-scope, decisions/decision-work-ids, elements/catalog, elements/ledger, records/homing-triage, records/findings, records/lenses/problems, records/lenses/unspoken, records/author-calls, index]
status: current
updated: 2026-09-18
---

# Arc: substrate-floor

- goals: [[goals/self-hosting]], condition 5: "Every built element of the
  compiler holds a roster row in an arc." The same goal's condition 4 is served
  by requirements 1 and 2 below, which state over this arc's own code the reach
  and assertion that condition names. `docs/goals/self-hosting.md:97-102` is the
  table that names this arc, unopened, as the last of four subject arcs, and
  `:83-89` gives it both conditions in one sentence: each would "roster the
  elements of that subject that no arc rosters today, and state over the same
  code the reach and assertion requirements condition 4 names". No second goal
  is served. [[goals/local-ai]] and [[goals/enforcement]] were each tested
  against this roster and each is refused under *What this arc does not take*.
  **This arc claims conditions 4 and 5 alone.** A standing rule holds conditions
  1 to 3 and that goal's §Arcs says so.
- reserved element block: **none**. All sixteen rows carry an element minted long
  before this file, and the arc-local ids per [[decisions/decision-work-ids]]
  spell the letters `SU`, for substrate: `substrate-floor/SU1` upward. `SB` was
  rejected because a grep for `SB` followed by a digit hits
  `.planning/sources/UAX29.txt:2469` onward, where `SB1` to `SB6` are Unicode
  sentence-break rules, so the id would not be greppable. `SU` followed by a
  digit hits nothing in the tree, measured 2026-09-18. The two-letter form
  follows `sys-face`'s `SF`, `checker-core`'s `CK` and `lowering-and-emit`'s
  `LE`.
- build-state authority: [[status-ledger]]
- checklist: none. No `records/substrate-floor.md` exists.
- neighbour: [[arcs/memory-discipline-arc]], stated in full under *What this arc
  does not take*. That arc owns the value-cell heap's reclamation discipline
  under [[goals/local-ai]]. This arc owns the substrate those cells sit in.

## Why this arc exists

Condition 5 is the homing invariant [[goals/README]] states at `:27`. Measured
2026-09-18 against the working tree: `docs/elements/ledger.md` §MEM holds 22
rows, six of them already rostered (`E81` through `E85` by
[[arcs/memory-discipline-arc]], `E132` by [[arcs/runtime-loading-arc]]), and
**sixteen hold no roster row anywhere**. The goal's own cell for this arc names
thirteen. Three more sit in §MEM, hold no roster row, and fall inside the cell's
subject sentence: `E111` is the `Pool`-backed cell store the sentence's "linear
containers" reaches, and `E22` and `E41` are the region-type floor under "the
`Pool` region". So this arc takes sixteen rows and the seam is §MEM whole, minus
what two arcs already hold.

Condition 4 reads the same claim over the compiler's parts. Its failure shape is
`docs/definitions/bug-classes.md:171-173`: a part can be written, compile
cleanly, pass the suite, get marked built in the catalog, then run on no path.
This subject is where the shape is widest, because every compiled program stands
on this floor and no gate script names any of it. **A grep for `arena`,
`init-commit`, `reserve-bytes`, `heapend`, `x-galo` and `alloc-growing` over
`tools/test/*.sh` returns nothing, measured 2026-09-18**, and the one mention of
a `Pool` in any script names a file that does not exist.

## What the tree already holds

Measured 2026-09-18 against the working tree. [[banks/INDEX]] holds thirteen and
two own pieces of this territory. [[banks/memory]] refracts space-as-a-port
across eight shards and its first six are this arc's; [[banks/runtime]] carries
the native execution substrate and lists the W^X loader among the shards it
calls built.

| group | what exists today | where | rung |
|---|---|---|---|
| S1 the image | one `PT_LOAD`, `RWE`, wrapping code and heap cells in one segment. `readelf -l bin/chirality-bin` reports a single program header at `0x12a178` | `lib/lowering/x64/elf.chiral` 82 L, `:70` writes `p_flags` 7, `:59-60` says why | IMPLEMENTED |
| S1 the entry stub | `mmap`(9) of a 64 GiB `PROT_NONE` reservation, then `mprotect`(10) of a 256 KiB read-write prefix, then four arena cells stored at absolute vaddrs. Both syscalls checked, `exit_group` on failure | `lib/lowering/compile-emit.chiral` 330 L, `:36-43`, `:49-50`, `:62`, `:83` | IMPLEMENTED |
| S1 the FFI seam | nothing, and that is the finished shape. A grep for `ctypes` and `CFUNCTYPE` over `lib/` and `prog/` returns three comments about the evicted oracle and no binding | `lib/lowering/compile-emit.chiral:35`, `lib/lowering/tal/eval.chiral:4` | IMPLEMENTED |
| S2 the arena's growth | `nb-arena-grow`, a four-argument TAL body that reads the committed end, takes the larger of the doubling and the need, and calls `nb-arena-commit` to `mprotect` the new chunk. `nb-arena-fail` is `exit_group` on ceiling overrun | `lib/lowering/tal/sys.chiral` 1,343 L, `:166-199`, commit at `:133`, fail at `:120` | IMPLEMENTED |
| S2 the growing allocator | `x-galo` and the growing byte-cell arm: `jbe` past a `call arena-grow` and a `jmp` back to retry. The stub is emitted once per program in `x-fin` and relocates to `nb-arena-grow` | `lib/lowering/x64/mach.chiral` 1,766 L, `:515-526`, `:685-700`, stub at `:543-561` | IMPLEMENTED |
| S2 the discipline seam | the `Alloc` record of five functions with its two instances. `alloc-growing` binds `mach-galo` and `mach-gbnw` and is imported by the shipping emitter; `alloc-fixed` binds the trapping arms and has zero importers on purpose | `lib/memory/alloc.chiral` 35 L, `alloc-growing.chiral` 24 L, `lib/lowering/x64/emit.chiral:3-4` | IMPLEMENTED |
| S2 the second growth story | `init-heap`, a 64 MB `MAP_NORESERVE` map, and `arena-grow`, an `mremap` doubling. Zero importers, outside the closure, and its own header at `:5` claims the bump allocator calls it | `lib/memory/arena.chiral` 44 L, `:26-33`, `:36-44` | SEEDED |
| S3 the word | I64 two's-complement arithmetic emitted by the x64 encoder, including the deliberate `ud2` on a zero divisor and the `INT_MIN`/`-1` branch | `lib/lowering/x64/mach.chiral:178-184`, `x-trap-if-zero` at `:259` | IMPLEMENTED |
| S3 the byte | byte cells `[len][payload]` over native arena cells, 645 lines with eleven importers, inside the closure | `lib/lowering/tal/bytes.chiral` | IMPLEMENTED |
| S3 the containers | the AVL `Map` at 173 lines with three importers, inside the closure. `Set` at 46 lines with zero importers, outside it | `lib/prelude/map.chiral`, `lib/prelude/set.chiral` | IMPLEMENTED / SEEDED |
| S4 the `Pool` region | the size-indexed linear porttype, its result carriers, and four externs. Every one has a crossing row and a TAL body: `nb-pool-create` at `lib/lowering/tal/sys.chiral:1015`, write at `:1071`, read at `:1104`, close at `:1130` | `lib/ports/pool.port` 31 L `:13-31`, `lib/lowering/tal/crossing-wraps.chiral:50-53`, `lib/lowering/tal/sys.chiral` | IMPLEMENTED |
| S5 the linear cap container | `SockVec`, a purpose-built linear list whose head and tail are both `1`-fielded, so the whole value registers linear and the ops preserve it by construction. Four negative fixtures refuse with the right message | `lib/capability/lincoll.chiral` 91 L, `:26-28`, `:31` | IMPLEMENTED |
| S5 the cell store | a linear size-indexed `(Grid n)` whose store is a `Pool`, one 16-byte cell per index, written and read in place. `grid.chiral:194` is the only `pool-read` call in the tree | `lib/protocol/grid.chiral` 242 L, `:28`, `:52`, `:194`; membrane at `lib/protocol/vt-parser.chiral:57` | IMPLEMENTED |
| S6 the region library | `(data Region ((n I64)) (region (1 pool (Pool n)) (cap I64) (used I64)))` with `mem-alloc` advancing a cursor. The capacity check is a runtime branch against a runtime witness | `lib/memory/mem-region.chiral` 75 L, `:37`, `:41`. Zero importers | SEEDED |
| S6 the region types | nothing. `E41`'s audited SPEC scopes the element's refinement half to a linear arith-expression bound and names the general solver a non-goal | `docs/elements/specs/E41-region-types-SPEC.md`, `records/lenses/problems.md` PRB-82 | DESIGNED |

**`lib/memory/` is 233 lines across six files**, which reproduces
`.planning/DISPLAY-LAYER-GAP.md:39`'s baseline of 2026-09-04 exactly: `alloc` 35,
`alloc-growing` 24, `alloc-fixed` 23, `arena` 44, `mem-linear` 32, `mem-region`
75. The same line's second claim, that the only writable region is a `Pool`
written by `pool-write` at an offset, holds for the byte heap and is false of the
value heap: `x-galo` and the growing byte arm write the arena directly through
`heapptr`, and `nb-heap-allocated` at `lib/lowering/x64/mach.chiral:565-573`
reads the cursor out. Four of the six modules have zero importers.

## What is missing, and its structure

| group | owns |
|---|---|
| S1 the image and its entry | the ELF the kernel enters, the two syscalls the prepended stub issues, and the FFI seam that evaporated with the oracle. All built and universal. What is absent is the name of the element the surviving W^X work belongs to, which is an author call carried on a `built` row, and any assertion over the stub |
| S2 the arena and its growth | the arena's base and end, the TAL grow wrapper, the growing allocator instance, and the policy seam that selects it. All built and inside the closure. What is absent is a path that crosses the 256 KiB commit boundary, and two state cells read the opposite of what the code says |
| S3 the value floor | I64 arithmetic, byte cells, and the map and set containers. Every compile runs all of it. What is absent is any assertion that discriminates one of them from a wrong version of itself |
| S4 the `Pool` region | the porttype, its four crossings, their TAL bodies and their `crossing-wraps` rows. Built and inside the closure. What is absent is a caller a phase reaches: the only `pool-read` call in the tree sits outside the closure |
| S5 the linear stores above it | the linear cap container and the `Pool`-backed grid. Both built, both outside the closure, with six roots and four negative fixtures that pass when run by hand and no script that names one |
| S6 the type-level floor | the region types that would discharge `mem-region`'s capacity branch statically. Unbuilt, admitted by two rows of `records/lenses/unspoken.md`, and which arc owns the class is an open author call |

### The edges that run against the order

| edge | direction | what crosses |
|---|---|---|
| S6 to S3 and S4 | against, and the loudest | S6 reads as last and its consumers are two groups below it. `docs/elements/specs/E41-region-types-SPEC.md` §3 decision 2 names `E22`'s cursor and `E25`'s byte-cell faces as the consumers of the linear sum it resolves, so the deferred group's first customers are `SU8` and `SU15`, both built. Reading S6 as last leaves `lib/memory/mem-region.chiral:41` a runtime branch and leaves the class unowned |
| S2 to S1 | against | `E20`'s open author call asks which element the surviving W^X work belongs to, and the `mmap`/`mprotect` pair its title claims is S2's reserve-commit. So the S1 question is answered by measuring S2 rather than by opening S1, which is what `SU1`, `SU3` and `SU5` record and what [[arcs/runtime-loading-arc]]'s `RL1` already found |
| S2 to S2 | against | the tree carries two arena growth stories. The shipped one commits more of a `PROT_NONE` reservation with `mprotect`; the unreached one doubles with `mremap`. `E90`'s row names the second mechanism and the first is what runs, so the cheapest-looking reconciliation is a state correction rather than a build |
| S4 and S5 to outside this arc | out of reach | the phase machinery that would dispatch these roots is `lowering-and-emit/LE22`'s Phase 12, printed NOT PORTED at `tools/test/run-tests.sh:22` and `:413`. Requirement 1 cannot be finished from here, and the rows that serve it say what they need |
| S2 to outside this arc | out of reach | whether `lib/memory/mem-region.chiral` is reached is `memory-discipline/M6`. `SU4` and `SU5`'s question is the sibling one over `lib/memory/arena.chiral`, and reading S2 as self-contained puts two arcs on one six-file directory |

## REQUIREMENTS

Six, each with the observation beside it, measured 2026-09-18.

1. **Every element of this arc is discriminated by an assertion a phase runs.**
   Observed as the element's root basename appearing in a `tools/test/*.sh`
   script some `run_phase` line names, or as a script asserting a value over the
   element's code, which is goal condition 4(b)'s own observation. Today zero of
   sixteen. Six roots exist and were run here: `e106_drain_control` exits 42,
   `t4_codec` 42, `t4_grid` 42, `slices4_open_create` 42, `t4_minimal` 0, and
   `e106_sockvec_accept` exits 1 for the reason its own header at `:10-12`
   gives, that `sock-close` has no `crossing-wraps` row. Four negative fixtures
   refuse correctly and exit 1: `e106_reject_drop_tail`, `e106_reject_length`,
   `e106_reject_list_cap` and `e106_reject_nonlinear_field`. No script names any
   of the ten.

2. **Every module an element of this arc names sits inside the compiler's import
   closure, or the row says why not.** Observed by resolving `(import "...")`
   transitively from `prog/compiler.prog` over `lib:prog` across the three
   importable extensions `MAP.md:19` names, which is goal condition 4(a)'s own
   observation. Today 61 targets and 17,654 lines against `lib/`'s 105 modules
   and 26,598, with 44 modules outside. Five of this arc's are outside:
   `lib/capability/lincoll.chiral` 91, `lib/protocol/grid.chiral` 242,
   `lib/prelude/set.chiral` 46, `lib/memory/arena.chiral` 44 and
   `lib/memory/mem-region.chiral` 75.

3. **Every state claim over one of this arc's elements names code that says what
   the claim says.** Observed by opening each cited span and reading it. Today
   four fail: `E90`'s catalog cell reads *"Not built"* and cites a file that does
   not exist, `E91`'s reads *"Not built"* over a retry loop the shipping emitter
   selects, `E25`'s cell counts sixteen importers against eleven, and `E24`'s
   puts `mach.chiral` at 1,737 lines against 1,766. This is the class
   [[records/findings]] FD-27 states and `E76` worked.

4. **The arena's growth path is crossed by something that runs.** Observed as an
   assertion that allocates past the 256 KiB `init-commit`, returns a value, and
   fails if the commit is refused. Today the reservation is 64 GiB and the commit
   256 KiB (`lib/lowering/compile-emit.chiral:49-50`), no `tools/test/*.sh`
   names `arena-grow`, `nb-arena-grow`, `init-commit` or `reserve-bytes`, and
   every root in the tree finishes inside the first commit.

5. **One arena growth story, or two with the second's status stated.** Observed
   as `lib/memory/arena.chiral` reached from something a phase runs, or moved to
   SEEDED with the reason and its header's claim corrected. Today it has zero
   importers, sits outside the closure, opens by naming itself
   `lib/arena.chiral`, a path the 2026-08-31 migration retired, and asserts at
   `:5` that the bump allocator calls it.

6. **A constant offset into a region discharges its bounds check at compile
   time.** Observed as `lib/memory/mem-region.chiral:41`'s `(<=i (+ used len)
   cap)` branch absent from the emitted code for a constant offset. Today it is
   a runtime branch. It tests a runtime capacity witness, the erased `n` plays
   no part in it, and it `halt`s on overflow.

## Roster

Sixteen rows. Every one carries an element minted long before this file and homed
by no roster until now. Ids spell `SU`. **This arc mints nothing and allocates no
number.**

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `substrate-floor/SU1` | the loader that is no longer one, and the open author call sitting on it. `docs/elements/catalog.md:126` reads *"BUILT native and no longer a loader"* and cites the entry stub's `mmap` and `mprotect` at `lib/lowering/compile-emit.chiral:43,62,83`, which are `SU3`'s reserve-commit. The W^X half is absent: `lib/lowering/x64/elf.chiral:59-60` writes one `RWE` segment in its own words and `:64` calls the split *"the named W^X follow-on"*, and `readelf -l bin/chirality-bin` reports one `RWE` `PT_LOAD`, re-verified 2026-09-18. **Wanted**: the element the surviving W^X work belongs to, named. **Blocking condition**: **the author call carried on this element's ledger row**, verbatim under FLAGs. The mechanism is `E132`'s and [[arcs/runtime-loading-arc]] holds it | S1 | primitive | bind | 1, 3 | built | `E20` |
| `substrate-floor/SU2` | the FFI trampoline, discharged by eviction and by no build, which is what the element asked for. `docs/elements/catalog.md:129` reads *"There is no FFI trampoline and no host to trampoline from"* and the ledger title reads *"evaporates on ELF"*; a grep for `ctypes` and `CFUNCTYPE` over `lib/` and `prog/` returns three comments about the evicted oracle and no binding, measured 2026-09-18. The artifact is an ELF entered at `_start`, written by `lib/lowering/x64/elf.chiral` at 82 lines, which the catalog cell counts correctly. **Wanted**: one assertion that no crossing enters through a host trampoline, so the discharge is gated rather than stated in prose. **Blocking condition**: none measured. This is the one element on the roster with no SPEC and no `docs/examples/` artifact, which is why it is the only row `ledger-lint` check AH raises | S1 | port | bind | 1, 3 | built | `E23` |
| `substrate-floor/SU3` | the entry stub's reserve-commit split, built and universal, with its own name one version behind. `lib/lowering/compile-emit.chiral:36-37` describes the `PROT_NONE` reserve then the read-write commit, `:49` sets `reserve-bytes` to 68,719,476,736 and `:50` sets `init-commit` to 262,144, `:62` issues `mmap`(9) and `:83` issues `mprotect`(10), both checked with `exit_group` on failure. `docs/elements/catalog.md:356` records that the function is still *named* `entry-stub-v2` at `:59` and that its header cites the evicted oracle three times plus a byte-identity test that no longer exists. **Wanted**: the stale header and the version in the name repaired, and one assertion that the stub's two syscalls are the only two a program issues before its entry. **Blocking condition**: none measured | S1 | primitive | bind | 1, 3, 4 | built | `E89` |
| `substrate-floor/SU4` | the arena as a bump region with a base and an end, built on both halves and pinned by no instrument. The stub stores the four cells at absolute vaddrs (`lib/lowering/compile-emit.chiral:37`), `x-fin` emits them page-aligned at `lib/lowering/x64/mach.chiral:537-543`, and `lib/memory/alloc.chiral` plus `lib/memory/alloc-growing.chiral` bump the cursor, all inside the closure through `lib/lowering/x64/emit.chiral:3-4`. `docs/elements/catalog.md:127` carries its own ⚑ that `lib/memory/arena.chiral` has **zero importers**, re-verified 2026-09-18. **Wanted**: the typed-arena bridge's status stated, and one assertion that reads `heapptr` back after a known allocation. **Blocking condition**: none measured. Whether `mem-region` is reached is `memory-discipline/M6` and this row takes neither it nor the reclamation question | S2 | primitive | bind | 1, 2, 5 | built | `E21` |
| `substrate-floor/SU5` | the arena grow wrapper, built, and its two authorities name a mechanism the tree does not use. `nb-arena-grow` is a four-argument TAL body at `lib/lowering/tal/sys.chiral:174-199`, registered in the linkage table at `:1340`, calling `nb-arena-commit` at `:133` which `mprotect`s the next chunk and `nb-arena-fail` at `:120` which is `exit_group`. `docs/elements/catalog.md:357` reads *"Not built; `sys-tal.chiral` has raw `nb-sys-mremap` but no higher-level wrapper"*: no `sys-tal.chiral` exists in the tree, and a grep for `nb-sys-mremap` over `lib/` returns nothing. The `mremap` doubling both titles name is `lib/memory/arena.chiral:37-44`, zero importers and outside the closure. **Wanted**: the cell re-derived, the mechanism corrected from mremap doubling to mprotect commit, and the second story's status stated. **Blocking condition**: none measured | S2 | primitive | bind | 1, 3, 4, 5 | built | `E90` |
| `substrate-floor/SU6` | the growing allocator, built by adding an instance beside the trap rather than by replacing it, which is what its title claims. `x-galo` at `lib/lowering/x64/mach.chiral:515` and the growing byte-cell arm at `:685` each `jbe +7` past a `(a-rel 5 e-call "arena-grow")` and `jmp` back to retry (`:521-523`, `:697`); the stub carrying the six-register save and the `nb-arena-grow` relocation is emitted once in `x-fin` at `:543-561`; `lib/memory/alloc-growing.chiral:18-24` binds `mach-galo` and `mach-gbnw` into the `Alloc` seam and `lib/lowering/x64/emit.chiral:4` imports it, so the growing arms are the shipping path. **`x-trap` survives at `lib/lowering/x64/mach.chiral:461`, `:493` and `:671`** as `x-alo` and the trapping byte arm, which `lib/memory/alloc-fixed.chiral` selects and which has zero importers by that file's own decision. `docs/elements/catalog.md:358` reads *"Not built; call mechanism exists (`x-cal` at line 753)"*. **Wanted**: the cell re-derived, the title restated as an instance beside the trap, and the retry loop asserted. **Blocking condition**: none measured | S2 | primitive | bind | 1, 3, 4 | built | `E91` |
| `substrate-floor/SU7` | I64 two's-complement arithmetic, emitted by every compile and cross-checked by nothing since the oracle went. `lib/lowering/x64/mach.chiral:178-184` states the divisor contract and `x-trap-if-zero` at `:259` is the deliberate `ud2`; `docs/elements/catalog.md:130` says in its own words that *"nothing in the tree cross-checks the wrap semantics"* and puts the file at 1,737 lines against 1,766 measured 2026-09-18. A grep for `x-div`, `x-mod`, `idiv`, `op-div` and `INT_MIN` over `tools/test/*.sh` returns nothing. **Wanted**: one assertion per arithmetic family against a known answer, including the wrap at `INT_MIN` and the two guarded divisors. **Blocking condition**: none measured. The widening multiply is `emitted-speed/X7` and `tools/test/mul-widen.sh` belongs to `E189`, and this row takes neither | S3 | primitive | bind | 1, 3 | built | `E24` |
| `substrate-floor/SU8` | byte cells `[len][payload]`, 645 lines inside the closure with eleven importers, and the count in its own cell is wrong. `docs/elements/catalog.md:131` reads *"645 L, 16 importers"*; a grep for `import "lowering/tal/bytes"` over `lib/` and `prog/` returns eleven files, measured 2026-09-18, of which `lib/lowering/compile-emit.chiral` is the one inside the closure. One `tools/test/*.sh` mentions the module and it is a comment at `tools/test/opt-census.sh:77`. `E41`'s SPEC names this element's byte-cell faces as a consumer of the linear bound `SU16` carries. **Wanted**: the importer count re-derived, and one assertion over a cell's length header surviving a write at a nonzero offset. **Blocking condition**: none measured. `prog/samples/e109_bput_u16_le.prog` asserts the u16 writer and is `lowering-and-emit/LE13`'s | S3 | primitive | bind | 1, 3 | built | `E25` |
| `substrate-floor/SU9` | the container registries, built as chirality modules, with one of the two reached by nothing. `lib/prelude/map.chiral` is the 173-line AVL `Map` with three importers and sits inside the closure; `lib/prelude/set.chiral` is 46 lines with **zero importers** and sits outside it, measured 2026-09-18. `docs/elements/catalog.md:133` names both plus `list`, `alist` and `ord`, and says `map`, `list` and `ord` are in the compiler blob, which holds. **Wanted**: the `Set` half reached or moved to SEEDED with the reason, and one assertion over the AVL rebalance that a wrong rotation would fail. **Blocking condition**: none measured. The de-duplicator ownership is `E165`'s and this row takes it nowhere | S3 | primitive | bind | 1, 2 | built | `E27` |
| `substrate-floor/SU10` | the native `pool-create` mint, built, and the mint the other three `Pool` rows gate on. `pool-create` is declared at `lib/ports/pool.port:26` as `(=> (w n I64) (PoolR n))` with `PoolR` at `:15` carrying the region and its backing memfd as two linear fields; its crossing row is `lib/lowering/tal/crossing-wraps.chiral:50` and its TAL body `nb-pool-create` is at `lib/lowering/tal/sys.chiral:1015`. **No script exercises it**: the only `Pool` mention in `tools/test/*.sh` is `tools/test/linear-mint.sh:160`, which names `lib/ports/pool.chiral`, a file that does not exist. **Wanted**: one root that mints a `Pool`, writes it, reads it back and closes it, under a phase. **Blocking condition**: the phase is `lowering-and-emit/LE22`'s Phase 12 | S4 | port | bind | 1 | built | `E122` |
| `substrate-floor/SU11` | the native `Pool` write, read and close bodies, built, with the bound erased and the offset checked at runtime. `pool-write` is declared at `lib/ports/pool.port:27` and `pool-close` at `:31`, both taking the bound as an erased `(0 n I64)`; the three crossing rows are `lib/lowering/tal/crossing-wraps.chiral:51-53` and the bodies are `nb-pool-write` at `lib/lowering/tal/sys.chiral:1071` and `nb-pool-close` at `:1130`. `nb-pool-read` at `:1104` bounds-checks `off + len` against the size read out of the witness cell and calls `nb-arena-fail` with `-22` on either failure, so the check is a runtime branch, which is the shape `SU16` would retire. **Wanted**: one assertion over the refusal, and the size witness read back. **Blocking condition**: the phase is `lowering-and-emit/LE22`'s Phase 12 | S4 | port | bind | 1 | built | `E120` |
| `substrate-floor/SU12` | the `Pool` read crossing, built under `E120`'s number, with the one caller in the tree sitting outside the closure. `pool-read` is declared at `lib/ports/pool.port:30` with its result carrier `PoolReadR` at `:19` naming this element in the comment above it, and `lib/protocol/grid.chiral:194` calls it to scroll the grid, which is the only `pool-read` call anywhere. `docs/elements/ledger.md` records the rung and the reason: `grid.chiral` is reached only by `lib/protocol/vt-parser.chiral` and four `prog/scriba/samples/` roots, which Phase 7 compiles and executes none of. Re-verified 2026-09-18: `t4_grid` exits 42 when run by hand and no script names it. **Wanted**: that root under a phase, which is the one assertion that would catch a `pool-read` returning the wrong span. **Blocking condition**: the phase is `lowering-and-emit/LE22`'s Phase 12 | S4 | port | bind | 1, 2 | built | `E113` |
| `substrate-floor/SU13` | the linear collection of caps, built on the branch the element's own Stage 1 predicted, with the sharpest negative fixtures on this roster and no phase behind them. `lib/capability/lincoll.chiral:26-28` declares `SockVec` with `(1 hd Sock)` and `(1 tl SockVec)`, so the whole value registers linear and `sv-push` at `:31` preserves it by construction. Measured 2026-09-18: `e106_reject_drop_tail`, `e106_reject_length`, `e106_reject_list_cap` and `e106_reject_nonlinear_field` each refuse with a distinct message and exit 1, `e106_drain_control` exits 42, and `e106_sockvec_accept` exits 1 for the reason its header at `:10-12` states, that `sock-close` has no `crossing-wraps` row. No script names one of the six. The module is outside the closure at 91 lines. **Wanted**: the four refusals and the accept under a phase, which is the only place in the tree where a linearity rule has a purpose-built negative corpus. **Blocking condition**: the phase is `lowering-and-emit/LE22`'s Phase 12 | S5 | law | bind | 1, 2 | built | `E106` |
| `substrate-floor/SU14` | the `Pool`-backed cell store, built as the thing its own cell said the language could not express, and undispatched. `lib/protocol/grid.chiral:28` declares `(data Grid ((n I64)) (grid (rows I64) (cols I64) (1 store (Pool n)) (cur Cursor) (pen Attrs)))`, a linear size-indexed native region with `cell-bytes` 16 at `:52` and one O(1) `pool-write` per cell; `lib/protocol/vt-parser.chiral:57` is the membrane that threads the linear grid. Measured 2026-09-18: `t4_codec` exits 42, `t4_grid` 42, `t4_minimal` 0, and no `tools/test/*.sh` names any of the three. `records/homing-triage.md:177` proposes [[arcs/display-calculus-arc]] and reads `clear`; **verified 2026-09-18 that that arc rosters no element at all**, its twenty element cells all reading `unminted`, and `display-calculus/C1` names this element inside its `what` cell while carrying `unminted`. **Wanted**: the three roots under a phase. **Blocking condition**: the phase is `lowering-and-emit/LE22`'s Phase 12 | S5 | primitive | bind | 1, 2 | built | `E111` |
| `substrate-floor/SU15` | the allocator beyond the bump arena: region types and a collector outside the TCB. `docs/elements/catalog.md:128` reads *"bump arena only; region types deferred (edge 3)"* and the ledger reads `design`, which the roster's closed vocabulary has no word for and which is written `open` here. `records/lenses/unspoken.md` UNS-01 admits it as unhomed and stands at `open` with `author: unreviewed`; that row's `measured` field reads *"no file in docs/arcs/ names E22"* and is false as of `docs/arcs/memory-discipline-arc.md:26,39`, where that arc names the element in its prose and in its §3 table and rosters `E81` through `E85` instead. **Wanted when the class has an owner**: the profile's memory clause, linear or region, given a type-level meaning, with `E41`'s linear sum as the mechanism. **Blocking condition**: **which arc owns the bounds and region class**, an open author call carried verbatim under FLAGs. The reclamation discipline over the value-cell heap is `memory-discipline/M2` through `M5` and this row takes none of it | S6 | law | new | 6 | open | `E22` |
| `substrate-floor/SU16` | region types retiring the runtime offset and bounds checks, the type-level half of the same class. `lib/memory/mem-region.chiral:41` is the branch it would discharge, `(<=i (+ used len) cap)` against a runtime witness, in a 75-line module with zero importers. `docs/elements/specs/E41-region-types-SPEC.md` reads `status: audited` and §1 scopes the element's refinement half to a linear arith-expression bound, a sum of atoms against an atom, with the general solver a non-goal. `records/lenses/problems.md` PRB-82 stands `OPEN` on `lib/typing/refine.chiral:7`, which routes a solver refactor here and is compiler source inside the blob. `records/lenses/unspoken.md` UNS-07 admits the element as unhomed. **Wanted when the class has an owner**: the linear sum `(<= (+ o s) cap)` decided at compile time for a constant offset. **Blocking condition**: **the same author call as `SU15`**. The application operand and the `=>` binder scope are `enforcement/N22`'s by PRB-82's 2026-09-10 settlement and this row takes neither | S6 | law | new | 6 | open | `E41` |

### Coverage

Run 2026-09-18 against the table above.

- **Every requirement is served.** 1 by `SU1` through `SU14`; 2 by `SU4`, `SU9`,
  `SU12`, `SU13` and `SU14`; 3 by `SU1`, `SU2`, `SU3`, `SU5`, `SU6`, `SU7` and
  `SU8`; 4 by `SU3`, `SU5` and `SU6`; 5 by `SU4` and `SU5`; 6 by `SU15` and
  `SU16`. No requirement is unscheduled.
- **Every row serves a requirement.** All sixteen name at least one. No row is
  out of scope.
- **Fourteen rows are `built` and two are `open`, and the requirements they
  serve are unmet, which is this arc's premise.** The state column is the
  pipeline's authority for a row; the elements are built and what the rows carry
  is the residue. Goal condition 4 is exactly the requirement that a built part
  run on a path something asserts.
- **Every `origin` is defensible from the measurement.**
  - `SU15` and `SU16` are `new` because the deliverable exists nowhere: no
    type-level discharge of a capacity check anywhere in the tree, and
    `lib/memory/mem-region.chiral:41` still branches at runtime.
  - The other fourteen are `bind` because the code is built and what is absent
    is a surface onto it: an assertion that discriminates it, a dispatch line
    for a root that already passes, or a state cell that matches the code. Each
    names the span measured.
  - No row is `connect`. The two joins this subject would want, a root reaching
    the grow path and a phase reaching the `Pool` roots, both terminate in
    machinery another arc owns, which the edges section states.

## What this arc does not take

- **The value-cell heap's reclamation discipline.**
  [[arcs/memory-discipline-arc]] serves [[goals/local-ai]] condition 1 and
  rosters `M1` through `M7`: the `Alloc` policy seam and `alloc-bump` as `E81`,
  then `alloc-region`, `alloc-reuse`, `alloc-dps` and the profile composition as
  `E82` through `E85`, plus two unminted rows over `mem-region`'s reach and a
  per-backend `alloc-region`. Its four requirements reach peak RSS, profile
  selection, `mem-region` being reached, and one discipline running on every
  backend. **The boundary is the axis the two arcs read the arena on.** That arc
  asks what the discipline over the arena reclaims. This arc asks whether the
  arena, its growth and the cells inside it are reached and judged at all. The
  seam is exact on one module: `SU4` and `SU6` state the `Alloc` record and its
  growing instance as the substrate `E81` threads a dimension over, and take no
  discipline slice. ⚑ **That arc's §3 table at `:39` rates `E22` IMPLEMENTED and
  its §2 at `:26` says the byte-`Pool` discipline *"was built as `E22`"*, while
  `docs/elements/catalog.md:128` and `docs/elements/ledger.md` both read `design`
  and *"bump arena only"*.** The mention sits in a §3 context and that roster's
  element cells are `E81` through `E85`, so that arc does not roster `E22`, and
  `SU15` takes it. If the author seats the region class there instead, `SU15` and
  `SU16` retire and the elements move with their ids intact.
- **The crossing surface.** [[arcs/sys-face-arc]] rosters nineteen crossing
  elements through `SF1` to `SF20` and owns the `.port` sheets, the linkage
  table, the carrier lifecycles and the module coordinate. `E28`'s
  `mmap`/`munmap`/`mprotect`/`memfd`/`ftruncate` family is the set of crossings
  the `Pool` bodies and the entry stub call, and that arc owns those crossings.
  **Verified 2026-09-18: that file names none of this arc's sixteen anywhere**,
  so there is no refusal to read against and no claim to compete with. `SU10`,
  `SU11` and `SU12` take the `Pool` region's own representation and take no
  crossing.
- **The emit path and the phase machinery.** [[arcs/lowering-and-emit-arc]]
  rosters twenty-four rows through `LE1` to `LE24` and owns `E34`'s ELF wrapper
  as `LE15`, the x64 encoder as `LE14`, the test floor and its absent Phase 12
  as `LE22`, and the fixpoint compare as `LE24`. `SU1` states the segment flags
  exactly as `LE15` does and asks for no change to them; `SU7` states the
  arithmetic the encoder emits and takes neither the widening multiply nor
  `tools/test/mul-widen.sh`; and five rows here name `LE22`'s Phase 12 as their
  blocking condition rather than proposing a phase. The eighteen fixtures
  importing `lib/evidence/test-floor.chiral` are that arc's census and none of
  the ten artifacts counted here is among them.
- **The W^X floor and the resident loader.** [[arcs/runtime-loading-arc]] rosters
  `E132` as `RL2` and owns a resident binary mapping a freshly compiled artifact
  with a load-time port fence. Its `RL1` names `E20` inside its `what` cell while
  carrying `unminted`, and that arc's FLAGs at `:221-226` say in its own words
  that the run leaves the call open. `SU1` homes the element, states the
  `RWE` segment as the emitter writes it, and carries the same call. Under
  [[goals/README]] at `:27` and `:32` an element sits in every arc that claims
  it, so `RL1` adopting `E20` later is no competition.
- **The bounds class as an enforcement question.** [[arcs/enforcement-arc]]
  rosters `N1` through `N22` and owns what the compiler states about its own
  work. **Verified 2026-09-18 that its twenty-three element cells are `E184`
  through `E188`, `E16`, `E17`, `E18`, `E70` and `E198`, with thirteen
  `unminted`, and that they hold no `E41` and no `E22`.** `E41` appears twice in
  that file, at `:514` inside `enforcement/N22`'s `what` cell and at `:549` in
  its resume state, both stating what `E41`'s SPEC settles rather than claiming
  the element. `records/homing-triage.md:118` proposes that arc or
  [[arcs/memory-discipline-arc]] for `E41` and reads **author-call**, citing
  `docs/arcs/enforcement-arc.md:572` as an open call of the same shape.
  `enforcement/N22` owns the refinement-atom widening by PRB-82's 2026-09-10
  settlement, and `SU16` takes the region half and no part of the solver.
- **The display tier over the cell store.** [[arcs/display-calculus-arc]] rosters
  twenty rows and no element. `display-calculus/C1` names `E111` in its `what`
  cell as the tier its typed property values are built in, with `unminted` in its
  element cell. `SU14` takes the element where its three roots sit, and if the
  author prefers the display seat the row retires and the element moves with its
  id.
- **The wider root census.** 84 of the 103 roots Phase 7's own selector returns
  are named by no gate script, which [[arcs/lowering-and-emit-arc]] measured and
  corrected [[arcs/checker-core-arc]]'s 81 to. **Of the 84, five belong to
  elements of this roster**, and requirement 1 schedules those five plus four
  negative fixtures and one root that refuses natively for a stated reason. The
  `prapanca` families are [[arcs/orchestration-engine-arc]]'s and the `scriba`
  families are [[arcs/scriba-arc]]'s, with the three `t4_*` roots the exception:
  they sit under `prog/scriba/samples/` and verify `E111`, which this roster
  homes.
- **Repairing the catalog, the ledger and the banks.** Requirement 3 is what
  `SU1`, `SU2`, `SU3`, `SU5`, `SU6`, `SU7` and `SU8` buy, and this run edits
  none of the three.

## FLAGs

⚑ **`E20`'s ledger row carries an open author call and this run does not take
it.** The row's own words, `docs/elements/ledger.md` §MEM: *"⚑ **FINDING
2026-09-04, the row and the element disagree about what E20 is, and the cell is
left with this note rather than moved.** The name in the title is a collision.
There is no `nb-blit` and no mmap-to-mprotect *code loader* anywhere under
`lib/`; `lib/module/loader.chiral` is the **compiler's** module loader by its
own header, a different thing. What is real is the entry stub in
`lib/lowering/compile-emit.chiral`, and its `mmap`(9) + `mprotect`(10) pair is
the **E89/E91 arena reserve-commit** (PROT_NONE reserve, then
PROT_READ|PROT_WRITE commit, `:36-38`, `:60-61`), never a W→X transition. **The
W^X half is NOT HELD:** `lib/lowering/x64/elf.chiral:59-60` emits one RWX
`PT_LOAD` in its own words (*"RWX (PF_R\|PF_W\|PF_X = 7), not RX"*) and names the
split as *"the named W^X follow-on"*; `readelf -l bin/chirality-bin` reports a
single `RWE` segment, re-verified 2026-09-04.
`docs/definitions/status-ledger.md` already demoted its W^X loader row for this
reason. Naming the surviving element is an author call."*

**What this run measured against it, at HEAD on 2026-09-18.** Every limb holds.
`readelf -l bin/chirality-bin` reports one program header, `LOAD` with flags
`RWE` at `0x12a178`. `lib/lowering/x64/elf.chiral:70` writes `p_flags` 7 and
`:59-64` gives the reason, the heap cells sharing the segment, and names the
second RW `PT_LOAD` as the follow-on. The `mmap`/`mprotect` pair is
`lib/lowering/compile-emit.chiral:62` and `:83`, and the reserve and commit
constants are `:49` and `:50`, so the pair is `SU3`'s reserve-commit rather than
a W→X transition. A grep for a code loader under `lib/` returns
`lib/module/loader.chiral`, the compiler's module loader, and nothing else.
**The entanglement is three-way and its shape is now exact**: `E20`'s title
describes work that does not exist, `E89` owns the reserve half, `E91` owns the
commit-on-demand half, and the W^X mechanism is `E132`'s, rostered by
[[arcs/runtime-loading-arc]]. `SU1`, `SU3` and `SU6` home the three elements and
answer nothing.

⚑ **Which arc owns the bounds and region class is an open author call, and
`SU15` and `SU16` are drawn while it is out.** `records/homing-triage.md:259-261`
carries it, and its words are: *"**D. Which arc owns the bounds and region
class?** E41 region types. `docs/arcs/enforcement-arc.md:572` is already an open
call of this shape for the bounds class, and E41 is the type-level half the same
question reaches."* The same file's row for the element, at `:118`, reads
*"[[arcs/memory-discipline-arc]] or [[arcs/enforcement-arc]] | **author-call**"*,
and the row for `E22` at `:101` proposes [[arcs/memory-discipline-arc]] and reads
`clear`.

**No ruling on question D is recorded anywhere in the tree, measured
2026-09-18.** `records/author-calls.md` carries six named calls and none is this
one; a grep over that file for `E41`, `question D` and `bounds and region`
returns nothing. Four homing rulings are recorded there and each answers a
different question: that homing covers built rows, that `superseded` is exempt,
that the orphan program reaches the `OT` track, and that a design and a SPEC for
an `OT` element are planning. The two rows are drawn here on the same footing
[[arcs/sys-face-arc]] drew `SF20` and [[arcs/lowering-and-emit-arc]] drew `LE24`:
the element is homed, the call is carried, and if the author seats the class
elsewhere both rows retire and the ids follow the elements.

⚑ **Two state cells read the opposite of what a grep returns, and both are in
one group.** `E90`: `docs/elements/catalog.md:357` reads *"Not built;
`sys-tal.chiral` has raw `nb-sys-mremap` but no higher-level wrapper"*. No
`sys-tal.chiral` exists in the tree, `nb-sys-mremap` appears nowhere under
`lib/`, and `nb-arena-grow` is a four-argument TAL body at
`lib/lowering/tal/sys.chiral:174-199` registered in the linkage table at
`:1340`. `E91`: `docs/elements/catalog.md:358` reads *"Not built; call mechanism
exists (`x-cal` at line 753)"*. `x-cal` is at `lib/lowering/x64/mach.chiral:1648`
and the emitted calls are at `:522` and `:697`, each an
`(a-rel 5 e-call "arena-grow")` with a retry jump; the stub is
emitted at `:545`, and `lib/lowering/x64/emit.chiral:4` imports the instance
that selects them. Both ledger rows read `built` and the code agrees with the
ledger. `ledger-lint` check AB pairs the catalog's build column against the
ledger's state column and reports zero issues, so both drifted in the direction
AB cannot see. **Two further citations are stale and belong to a milder class**:
`E25`'s cell counts sixteen importers against eleven and `E24`'s puts
`mach.chiral` at 1,737 lines against 1,766. Neither file is in this run's write
scope. [[arcs/sys-face-arc]] found four of the opposite-reading class on
2026-09-17, [[arcs/checker-core-arc]] four on 2026-09-18 and
[[arcs/lowering-and-emit-arc]] two, which makes twelve in four arcs.

⚑ **Two triage rows read `clear` against arcs that roster nothing of the kind.**
`records/homing-triage.md:101` routes `E22` to [[arcs/memory-discipline-arc]]
citing `docs/arcs/memory-discipline-arc.md:67`; that line is the text of that
arc's requirement 2 and names no element, the element cells of that roster are
`E81` through `E85` and two `unminted`, and the element is named at `:26` and
`:39` in prose and in a §3 table. `records/homing-triage.md:177` routes `E111` to
[[arcs/display-calculus-arc]] citing `:79` and *"cashed by row `C1` at `:115`"*;
`:79` is the text of that arc's requirement 1, `C1` names the element inside its
`what` cell, and **that arc's twenty element cells are all `unminted`**, which
`tools/lens/lens.py chain` reports independently. [[arcs/checker-core-arc]] and
[[arcs/lowering-and-emit-arc]] each found the same shape, which makes this the
third arc in a row to disagree with a `clear` verdict for a measured reason.

⚑ **`records/lenses/unspoken.md` UNS-01 and UNS-07 admit `E22` and `E41` as
unhomed, both stand at `open` with `author: unreviewed`, and one of the two
carries a false measurement.** `SU15` and `SU16` give each a home, so both rows
are owed a state change and a `checked:` date. UNS-01's `measured` field reads
*"no file in docs/arcs/ names E22"* and `docs/arcs/memory-discipline-arc.md:26`
and `:39` name it, so that field was already false before this run. The two rows
are also why the element homes owed count falls by fourteen and not by sixteen:
check AE exempts an element an unspoken row admits, so neither was inside the
owed 32. That file is outside this run's write scope and another session is
editing it.

⚑ **[[banks/runtime]] carries the W^X loader among its built shards in four
places and the code contradicts it.** `docs/banks/runtime.md:78`, `:215`, `:317`
and `:377` list the W^X loader in the native execution substrate and call that
substrate built; `:225-226` already records the demotion in [[status-ledger]] and
*"the built path emitting one RWX `PT_LOAD`"*, so the bank disagrees with itself
across its own sections. `readelf -l bin/chirality-bin` reports one `RWE`
segment, re-verified 2026-09-18. [[arcs/runtime-loading-arc]] raised the same
disagreement on 2026-09-14 and the correction is still owed. The bank is outside
this run's write scope.

⚑ **This arc is unanchored on `arc -> goal done-condition`.**
`docs/goals/self-hosting.md` conditions 4 and 5 each name
`[[arcs/sys-face-arc]]` and nothing else, and `tools/lens/lens.py:255` reads a
condition's arc from the `[[arcs/...]]` links in its body. So `lens.py chain`
reports this file in that rung's uncovered set beside
[[arcs/checker-core-arc]] and [[arcs/lowering-and-emit-arc]], moving the rung
from 34 of 36 to 34 of 37. The goal file is outside this run's write scope and
the edit is owed as one batch for all four arcs: conditions 4 and 5 each name
the four, the table at `:97-102` moves this row from unopened to opened with its
element count corrected from 13 to 16, the sentences reading *"The other three
subject arcs"* and *"The three unopened arcs"* go, the honest limit's *"39 of the
compiler's own built elements"* falls by this roster's fourteen non-exempt rows,
and the list of arcs opened in this shape at `:104-108` gains an eighth.

⚑ **`ledger-lint` check AH raises two violations against this roster and both
are real.** AH has two limbs: a row in a pipeline state with no
`docs/arcs/parts/<arc>-<local>.md`, suppressed when a `docs/examples/E<NN>-*.md`
exists for the element (`tools/ledger-lint/ledger-lint.py:2164-2170`), and a row
in `specced`, `building` or `built` with no
`docs/elements/specs/<elem>-*-SPEC.md` (`:2187-2189`). **This roster has no
exposure to AH's known zero-padding misreport**: that misreport needs a
single-digit element whose SPEC is zero-padded on disk while the cell is written
bare, and the lowest element here is `E20`, every cell carrying two or three
digits spelled the same way in both places. Measured 2026-09-18: thirteen of the
fourteen `built` rows are suppressed on limb one by an existing `docs/examples/`
artifact and each holds a SPEC, and `SU2`/`E23` holds neither, so it raises both
limbs alone. `SU15` and `SU16` read `open`, a state AH does not read. That is why
nine of [[arcs/checker-core-arc]]'s thirteen AH violations were padding
artifacts, none of [[arcs/lowering-and-emit-arc]]'s eight were, and two of these
are.

## Resume state

Opened 2026-09-18 against [[goals/self-hosting]] condition 5, on the author's
approval of the four subject arcs when that goal was amended at `2d8dbac` and the
direction of 2026-09-17 to finish them. This is the last of the four. Sixteen
rows, six requirements, nothing designed. Rows spell `SU`. Every row carries an
element minted before this file and this run mints nothing.

**The census.** `docs/elements/ledger.md` §MEM holds 22 element rows. Six hold a
roster row already: `E81` through `E85` in [[arcs/memory-discipline-arc]] and
`E132` in [[arcs/runtime-loading-arc]]. Sixteen hold none: `E20`, `E21`, `E22`,
`E23`, `E24`, `E25`, `E27`, `E41`, `E89`, `E90`, `E91`, `E106`, `E111`, `E113`,
`E120` and `E122`. All sixteen are rostered above, which is §MEM whole. Fourteen
read `built`; `E22` and `E41` read `design`, which the roster's closed vocabulary
has no word for and which is written `open`, following
[[arcs/checker-core-arc]]'s handling of `part` and `flight`. No element of §MEM
is `superseded`. **The goal's own cell names thirteen and this arc takes
sixteen**: `E111` is the `Pool`-backed cell store its subject sentence reaches
under "linear containers", and `E22` and `E41` are the region-type floor under
"the `Pool` region", each in §MEM and each homed by nobody.

**The row to take up first is `SU5`.** Its whole content is a four-line grep: the
file its cell cites does not exist, the extern its cell cites does not exist, and
the body it says is absent is 26 lines with a linkage-table row. `SU6` is the
second for the same reason, and its correction changes the element's title from a
replacement to an instance. `SU12` is the third: its root exits 42 today and
needs one `run_phase` line once `lowering-and-emit/LE22` ships Phase 12. `SU13`
is the fourth, because its four negative fixtures are the only purpose-built
linearity refusal corpus in the tree and every one of them already returns the
right message.

**What was measured before any row's state was written.** The closure census
resolves `(import "...")` transitively from `prog/compiler.prog` over `lib:prog`
across the three importable extensions `MAP.md:19` names and returns 61 targets
and 17,654 lines against `lib/`'s 105 modules and 26,598, with 44 modules
outside; the line total reproduces HEAD's figure exactly. `lib/memory/` is 233
lines across six files, reproducing `.planning/DISPLAY-LAYER-GAP.md:39`, with
`alloc` and `alloc-growing` inside the closure and the other four at zero
importers. Ten artifacts were run by hand: six roots, whose exit codes sit on
`SU13` and `SU14`, and four negative fixtures, all four refusing with exit 1 and
a distinct message. `readelf -l bin/chirality-bin` returned one `RWE` `PT_LOAD`.
The gate census greps `arena`, `init-commit`, `reserve-bytes`, `heapend`,
`x-galo`, `alloc-growing`, `nb-bcat`, `bytes.chiral`, `prelude/map`, `x-div`,
`idiv` and `pool` over `tools/test/*.sh` and returns three comments and no
assertion.
