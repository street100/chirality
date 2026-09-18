---
node: arc-runtime-loading
layer: navigation
related: [arcs/README, goals/local-ai, arcs/scriba-arc, banks/runtime, banks/module, live-environment, decisions/decision-user-layer-extensibility, decisions/decision-scope, decisions/decision-work-ids, status-ledger, elements/catalog, elements/ledger, records/homing-triage, index]
status: current
updated: 2026-09-14
---

# Arc: runtime-loading

- goals: [[goals/local-ai]], condition 2: "**TUI through scriba for full
  interaction.** Every part of a run is authored, composed, fired, watched and
  revised from `prog/scriba/`, with no step that requires leaving the editor."
- reserved element block: **none**. One row carries `E132`, minted 2026-08-14,
  and the other three carry arc-local ids per [[decisions/decision-work-ids]]
  spelling the letters `RL`, for runtime loading: `runtime-loading/RL1` upward.
  A grep for `RL` followed by a digit over `docs/`, `records/` and `.planning/`
  returns nothing, verified 2026-09-14. `R` was already spelled by
  [[arcs/display-calculus-arc]].
- build-state authority: [[status-ledger]]
- checklist: none. No `records/runtime-loading.md` exists.
- sibling: [[arcs/scriba-arc]], same goal, same condition. That arc owns the
  cockpit surfaces and the editor's own state, including `S11`, the init-file
  load. This arc owns the mechanism `S11` is blocked on.

## Why this arc exists

Condition 2 asks for a run revised from the editor with no step that leaves it.
Changing what the editor does today means editing source, recompiling with
`bin/chirality` and starting a new process, which is the seam
[[live-environment]] invariant 1 exists to remove:
*"The environment is the program. You extend it in its own language, live, and
it describes and modifies itself. No edit-compile-run seam."*
[[decisions/decision-user-layer-extensibility]] ruled on 2026-08-22 that the user
layer extends in chirality, live, and named the gate in its own words: `S11`
*"is **blocked on `E132`** (runtime dynamic loading: a resident binary loads a
freshly-compiled artifact)"*. [[records/homing-triage]] measured `E132` as held
by no roster and proposed this arc; the author approved opening it 2026-09-14.

**The ownership check was run before this arc claimed anything, and the sharp
case is scriba.** `docs/arcs/scriba-arc.md:76` names `E132` inside the `what`
cell of row `scriba/S6`; that row's **element cell reads `S11`**, the S-namespace
id, and the arc mints nothing in the `E` bands by its own header at `:14`.
Its coverage paragraph at `:84` repeats the same sentence, *"`S6` is blocked on
E132, which its own cell records"*. Being blocked on an element is a dependency.
`scriba-arc` carries no boundary section; its nearest statement is what
blocks the arc at `:92-95`, which names `transport/T2` and `E146` as the two
things it waits on and claims neither. No roster row anywhere in `docs/arcs/` carries
`E132` in its element cell, verified 2026-09-14.

## What the tree already holds

Measured 2026-09-14 against the working tree. [[banks/INDEX]] holds thirteen and
[[banks/runtime]] owns this territory, a process at system scale changing as
configured. Its Shard C is the staging connector, the act that births a runtime
from a profile, and it is recorded there as having **no live referent** since
2026-09-04 (`docs/banks/runtime.md:148-160`). Loading is the same axis after
birth and the bank's residue list reaches it nowhere.

| group | what exists today | where | rung |
|---|---|---|---|
| G1 the floor | the ruling this arc serves: the user layer is code compiled at runtime and linked into the resident binary, with the capability kernel as the floor. It names `E132` the real gate and refuses a data-config stopgap as scaffolding against a cataloged element | `docs/decisions/decision-user-layer-extensibility.md` §The decision, §What was rejected | DECIDED |
| G1 | ⚑ **the floor `E132`'s cell cites is absent in the shape it cites.** `docs/elements/catalog.md:461` names *"the E20 loader floor"*, and `docs/elements/ledger.md:162` records of `E20` that *"There is no `nb-blit` and no mmap-to-mprotect *code loader* anywhere under `lib/`"*, that its `mmap`/`mprotect` pair is the E89/E91 arena reserve-commit, and that the W^X half is **NOT HELD** | `docs/elements/ledger.md:162` | contested |
| G1 | the live image confirms the ledger. One `RWE` `PT_LOAD` of 0x12a178 bytes, and the emitter says why in its own words: *"RWX (PF_R\|PF_W\|PF_X = 7)"*, with the split named as *"the named W^X follow-on"* | `readelf -l bin/chirality-bin` run 2026-09-14, `lib/lowering/x64/elf.chiral:59-66` | IMPLEMENTED |
| G1 | the real `mmap` users: the typed arena over `mmap`/`mremap`, and the entry stub that reserves a `PROT_NONE` range and commits `PROT_RW` | `lib/memory/arena.chiral:20-30`, `lib/lowering/compile-emit.chiral:36-43`, `:62` | ENFORCED |
| G1 | the other half of the citation, and this half the catalog states honestly: symbol resolution is compile time. `E51` binds the port externs to the `sys.chiral` crossings inside the blob | `lib/lowering/tal/sys-linkage.chiral`, 112 lines, `docs/elements/catalog.md:149` | ENFORCED |
| G2 the load | the compiler that would produce the fresh artifact, self-hosted and reachable from a program: `bin/chirality` compiles, and `proc-spawn` returns a linear `Reap` | `bin/chirality:211`, `lib/runtime/proc.chiral` | ENFORCED |
| G2 | ⚑ **nothing maps a second artifact executable.** A grep for `mmap` over `lib/`, `prog/`, `bin/` and `tools/` returns the arena, the entry stub, the port declaration and the crossing row. Every hit is the process's own memory | measured 2026-09-14 | absent |
| G2 | ⚑ **the one self-extend artifact reaches a new program by leaving the process, and its compiler path is gone.** `prog/samples/self-extend-probe.prog:18` drives the model to run `./scaffold/build/B1 < /tmp/selfext.chiral > /tmp/selfext.elf` and execute the result; `ls scaffold` reports no such directory, and a grep for the basename over `tools/` and `bin/` returns nothing, so no phase runs it and it asserts nothing | `prog/samples/self-extend-probe.prog:15-22` | SEEDED |
| G2 | ⚑ **the catalog's two citations for the Knob 1 phantom are stale by 266 lines.** `docs/elements/catalog.md:461` gives `init-loader.chiral:360,369`; the two comments are at `:626` and `:635` of a 638-line file | `prog/scriba/init-loader.chiral:626`, `:635` | IMPLEMENTED |
| G2 | ⚑ **the catalog's third citation names a file that holds nothing of the kind.** It gives `shilpa/turn.chiral` self-extend; a grep for `self-extend` and `hot-acquire` over `prog/` returns one comment in `prog/shilpa/tools-fs.chiral:13` and the probe above. `prog/shilpa/turn.chiral` is 452 lines and holds neither term | measured 2026-09-14 | absent |
| G2 | the consumer, deferred in the source in the element's own words: `init-load` returns `init-default` and the comment reads *"Until the chirality runtime loads compiled artifacts, init-load returns init-default"* | `prog/scriba/init-loader.chiral:626-638` | SEEDED |
| G3 the fence | the per-program port check the fence would extend: the crossings an object program calls must lie inside the declared frozen port set, computed over the program's own fns and refused at emit | `lib/lowering/compile-emit.chiral:200-202`, `manifest-offender` at `:259`, refused at `:299` | ENFORCED |
| G3 | the declaration-side check the same seam already runs: a profile's port clause is rejected for pure ports and unknown crossings | `lib/surface/parse.chiral:906-919` | ENFORCED |
| G3 | ⚑ **the structural floor the ruling leans on is a file nothing imports.** `decision-user-layer-extensibility` item 4 assigns the init file's reach to `E45` *"structurally"*; `E45` is `design`, 54 lines, **zero importers**, so nothing is ever frozen, and its track is `OT` | `docs/elements/ledger.md:235`, `lib/typing/reflect-floor.chiral` | SEEDED |
| G4 the gate | the phase registry a demonstration would join, and the shape of a phase that runs a root and reads its exit code | `tools/test/run-tests.sh`, `tools/test/transport.sh` as the worked example | ENFORCED |
| G4 | ⚑ **the failure shape this arc must avoid is already in the tree twice.** [[goals/local-ai]] §Honest limits records `prog/samples/prapanca-run-conform.prog` and its twin as roots that carry a full exit contract, name a golden at a path absent from this tree, appear in no `tools/test/*.sh`, and are swept compile-only by Phase 7 | `docs/goals/local-ai.md` §Honest limits | SEEDED |

Three facts from that table govern the roster. **The element's stated floor does
not exist in the shape it is stated**, so the design stage starts from the
measurement above. **The resident image is already `RWX`**, which removes a W^X
transition from the problem and removes a W^X protection from the answer.
**Nothing anywhere maps a second artifact**, so the load itself is new work with
no shard to connect.

## What is missing, and its structure

| group | owns |
|---|---|
| G1 the floor | what `E132` stands on, stated from the code. The arena's `mmap`, the entry stub's reserve-commit and the single `RWE` segment are what exist; the W^X code loader the citation names does not |
| G2 the load | a resident process that maps a freshly compiled artifact, resolves its imports against the image that loaded it, enters it, and keeps running. `E132` |
| G3 the fence | a loaded artifact whose ports lie inside the resident process's frozen set, refused at load. The emit-time half is built and the load-time half has no seam to sit in |
| G4 the gate | a registered phase that compiles, loads, calls and asserts, with a mutant that fails it |

### The edges that run against the order

| edge | direction | what crosses |
|---|---|---|
| G3 to G2 | against, and the loudest | the fence decides what a load may admit, so a load built first fixes an admission rule the fence then has to undo. `decision-user-layer-extensibility` item 4 states the stop condition in its own words: if building `S11` reveals a path from init code to kernel reconfiguration *"that is an `E45` defect and stops the work"*. A stop condition is a precondition, and G3 sits after G2 in dependency order alone |
| G4 to G2 | against | the gate is the only thing that makes a claim here checkable, and the tree holds three artifacts of exactly the shape a missing gate produces: the self-extend probe with no assertion, and the two conform roots with a full exit contract and no phase. Ordering the gate last is how a fourth gets written |
| G1 to outside the arc | out | which element the surviving W^X work belongs to is an author call carried on `E20`'s ledger row, and `E20` is `built`. G1 corrects a premise and mints nothing, so the arc cannot close that call and cannot wait on it either |
| G3 to outside the arc | out | the structural floor is `E45`, which is `OT` and deferred by [[decisions/decision-scope]]. G3 cannot rest on a frozen judgment while nothing imports the file that freezes one, so the fence it builds is the emit-time check moved to load time |

## REQUIREMENTS

Five, each with the observation beside it, measured 2026-09-14.

1. **A resident process enters code it did not start with.** Observed as a root
   that compiles an artifact at runtime, maps it, calls its entry, prints the
   result and keeps running, with no `exec` and no second process holding the
   result. Today a grep for `mmap` over `lib/`, `prog/`, `bin/` and `tools/`
   returns the arena, the entry stub, the port declaration and the crossing row,
   and every one of them is the process's own memory.

2. **Every artifact `E132`'s floor citation names resolves to code that does
   what the citation says.** Observed by reading each.
   `docs/elements/catalog.md:461` names the `E20` mmap floor, and
   `docs/elements/ledger.md:162` records that no mmap-to-mprotect code loader
   exists under `lib/` and that the W^X half goes unheld. `readelf -l
   bin/chirality-bin` reports one `RWE` segment, run 2026-09-14.

3. **A fresh artifact's imports resolve against the image that loaded it.**
   Observed as a loaded artifact calling a function defined in the resident
   binary and getting that binary's definition. Today resolution is compile
   time: `lib/lowering/tal/sys-linkage.chiral` binds port externs to crossings
   inside the blob and no runtime symbol table exists anywhere.

4. **A loaded artifact cannot widen the resident process's port set.** Observed
   as a load refused when the artifact calls a crossing outside the resident
   profile's frozen set, with a mutant that tries. Today the same test runs at
   emit over an object program's own fns
   (`lib/lowering/compile-emit.chiral:259`, refused at `:299`) and nothing runs
   it at load, because nothing loads.

5. **The two deferrals this element was minted for can be lifted.** Observed as
   `prog/scriba/init-loader.chiral`'s two Knob 1 comments having a mechanism to
   point at, and as a self-extend loop acquiring a port with no restart. Today
   `init-load` is `(lam (_) (init-default unit))` at `:633-638`, and
   `prog/samples/self-extend-probe.prog` reaches a new artifact by spawning
   `./scaffold/build/B1`, a path `ls` does not find in this tree.

## Roster

Four rows. One carries `E132`, minted 2026-08-14 and homed by no roster until
now; three are connective and carry arc-local ids. Ids spell `RL`. **This arc
mints nothing and allocates no number.**

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `runtime-loading/RL1` | the floor stated from the code: what a resident load can stand on, given that the W^X code loader `E132`'s cell names does not exist, the image is one `RWE` segment, and `E51` is compile-time linkage. The three artifacts that do exist are the arena's checked `mmap` (`lib/memory/arena.chiral:20-30`), the entry stub's reserve-commit (`lib/lowering/compile-emit.chiral:36-43`) and the crossing vocabulary (`lib/lowering/tal/crossing-wraps.chiral`). **Blocking condition**: none measured. The `E20` naming call below is carried rather than waited on | G1 | decision | bind | 2 | open | `unminted` |
| `runtime-loading/RL2` | runtime dynamic loading: a resident chirality binary maps a freshly compiled chirality artifact, resolves its imports against the resident image, enters it and keeps running. Retires the Knob 1 phantom at `prog/scriba/init-loader.chiral:626` and `:635`, and turns the self-extend loop from a spawn into an acquire. Nothing in the tree maps a second artifact. **Blocking condition**: `RL1`, because the design would otherwise be written against a floor the ledger records as absent, and `RL3`, because the admission rule decides what the load may accept | G2 | primitive | new | 1, 3, 5 | open | `E132` |
| `runtime-loading/RL3` | the load-time fence: the crossings a loaded artifact calls must lie inside the resident process's frozen port set, refused at load with a mutant that tries to widen it. Both halves it joins are built, the per-program scan at `lib/lowering/compile-emit.chiral:259` and the declaration-side check at `lib/surface/parse.chiral:906`, and neither runs after the process is resident. **Blocking condition**: none measured. It does not wait on `E45`, which is `OT`, `design` and imported by nothing | G3 | law | connect | 4 | open | `unminted` |
| `runtime-loading/RL4` | the gate: a registered phase that compiles an artifact, loads it into the running process, calls it, asserts the result, and carries a mutant that fails. `tools/test/transport.sh` is the worked shape, five roots each compiled, refused if empty, run under a `timeout` and judged against its header's exit code. **Blocking condition**: `RL2`, since there is nothing to run until the load exists. Named now because the tree holds three artifacts with a full exit contract and no phase | G4 | tool | new | 1, 5 | open | `unminted` |

### Coverage

Run 2026-09-14 against the table above.

- **Every requirement is served.** 1 by `RL2` and `RL4`, 2 by `RL1`, 3 by `RL2`,
  4 by `RL3`, 5 by `RL2` and `RL4`. No requirement is unscheduled.
- **Every row serves a requirement.** All four name at least one. No row is out
  of scope.
- **Every `origin` is defensible from the measurement.**
  - `RL1` is `bind` because the three mechanisms exist and the claim over them
    is wrong. The arena's `mmap`, the stub's reserve-commit and the single
    `RWE` segment are all live, and `docs/elements/catalog.md:461` describes
    them as a W^X code loader.
  - `RL2` is `new` because a grep for `mmap` over `lib/`, `prog/`, `bin/` and
    `tools/` returns four sites and every one of them is the process's own
    memory. No shard of a second-artifact load exists to bind or connect.
  - `RL3` is `connect` because both halves are built and run at the wrong time.
    `manifest-offender` computes the offending crossing today and is called
    from `emit-elf-m`; what is missing is the same call on a load path.
  - `RL4` is `new` because no phase in `tools/test/run-tests.sh` runs a load and
    the one self-extend root asserts nothing.
- **One row reads `E132` and three read `unminted`.** `E132` carries ledger
  state `design` (`docs/elements/ledger.md:183`) with no design artifact at
  `docs/arcs/parts/runtime-loading-RL2.md`, no SPEC under
  `docs/elements/specs/` and no file under `docs/examples/`, so the roster state
  is `open`: the number is held and the pipeline is owed.

## What this arc does not take

- **`S11`, the init-file load.** [[arcs/scriba-arc]] rosters it as
  `scriba/S6` with `S11` in its element cell, and its requirement 3, *"Authoring
  a config can save it"*, is that arc's. This arc owns the mechanism that row is
  blocked on and writes no row into that file. Requirement 5 here observes the
  deferral being liftable and claims no part of lifting it.
- **The rest of [[goals/local-ai]] condition 2.** The cockpit surfaces `S14`,
  `S15`, `S16` and `S17`, the buffer list, buffer-local state, the `:` command
  registry and the orchestrator split are all `scriba-arc` rows. **No row of
  that arc is edited by this run.**
- **The hook shape, `S25`.** `decision-user-layer-extensibility`'s section on
  hooks settles it as the observation half of the same ruling and records that
  `E132` extends handlers for free because they are ordinary chirality. This arc
  builds no event sum and no handler list.
- **Where the A/B line inside the kernel module falls.** That decision's residue
  names it `E45` and edge 5, *"direction resolved, line not drawn, no code"*.
  `E45` is `OT` and deferred by [[decisions/decision-scope]]. `RL3` builds the
  port fence at load time out of the emit-time check that already runs and
  rosters `E45` nowhere.
- **The W^X split itself.** `lib/lowering/x64/elf.chiral:63-66` names a second
  `RW` `PT_LOAD` at the code-off page boundary as the follow-on, and
  `docs/elements/ledger.md:162` puts naming the surviving element to the author.
  `RL1` states what the floor is and proposes no element for the split.
- **Repairing the catalog and the ledger.** Requirement 2 is what `RL1` buys and
  this run edits neither file.

## Resume state

Opened 2026-09-14 against [[goals/local-ai]] condition 2, on the author's
approval of the `runtime-loading` proposal in [[records/homing-triage]]. Four
rows, five requirements, nothing designed. Rows spell `RL`. The one element on
the roster was minted 2026-08-14 and this run mints nothing.

**The row to take up first is `RL1`.** It turns on no open call, its whole
content is reading four files and one `readelf` line, and `RL2` is blocked on
it. `RL3` is the second: it turns on no open call either, and it is the other
thing `RL2` waits on.

⚑ **`E20`'s ledger row carries an open author call and this run does not take
it.** The row's own words, `docs/elements/ledger.md:162`: *"Naming the surviving
element is an author call."* Its context, from the same cell: *"the row and the
element disagree about what E20 is, and the cell is left with this note rather
than moved. The name in the title is a collision."* `RL1` is the row that
carries it.

⚑ **[[banks/runtime]] and the `E20` ledger row disagree, and the code agrees
with the ledger.** `docs/banks/runtime.md:380` lists the *"W^X loader"* among
the shards that are built and instructs the reader *"Do not describe the built
shards as missing"*. `docs/elements/ledger.md:162` records the W^X half as NOT
HELD, and `readelf -l bin/chirality-bin` reports a single `RWE` segment on
2026-09-14. The bank was outside that run's write scope. ⚑ Taken 2026-09-18:
[[banks/runtime]] carries the demotion at all four mentions and at `:225-226`.

⚑ **This arc is unanchored on `arc -> goal done-condition`.**
`docs/goals/local-ai.md` condition 2 names `[[arcs/scriba-arc]]` and no second
arc, so `tools/lens/lens.py chain` reports this file in that rung's uncovered
set. Two arcs on one condition is established practice, condition 1 of the same
goal being served by four. The goal file is outside this run's write scope and
the edit is owed.

⚑ **`E132` carries no row in `records/lenses/unspoken.md`.** A grep for the
number over that file returns nothing on 2026-09-14, so `ledger-lint` check AE
counted it among the elements owed a home, and this roster row removes it from
that count. `E49`, homed the same day by [[arcs/surface-syntax-arc]], carries
`UNS-14` and moves no count, which is why two elements homed move the owed
figure by one.

**What was measured before any row's state was written.** `E132` has no SPEC,
no example and no design artifact, checked 2026-09-14, and its catalog cell's
own verdict is *"Not built"* with the grep it rests on stated as *"grep-clean
for a second-artifact mmap/exec"*. That grep was re-run 2026-09-14 and still
holds. Three of the cell's citations are stale in a direction that widens the
work: `init-loader.chiral:360,369` are now `:626` and `:635`,
`shilpa/turn.chiral` holds no self-extend term, and the E20 floor the cell
stands on is the one the ledger contests. The fourth, `E51` symbol resolution
being compile-time only, the cell states correctly and the tree agrees.
