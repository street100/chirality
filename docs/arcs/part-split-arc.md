---
node: arc-part-split
layer: navigation
related: [arcs/README, goals/module-split, arcs/module-split-arc, arcs/scriba-arc, arcs/coding-turn-arc, arcs/tool-authority-arc, decisions/decision-part-layout, decisions/decision-orchestration-boundary, decisions/decision-work-ids, decisions/decision-lane-split, splitting-law, joining-law, banks/module, banks/profile, status-ledger, working-discipline, index]
status: current
updated: 2026-09-09
---

# Arc: part-split

- goals: [[goals/module-split]], condition 1: "**A module's pieces have one type
  shape each.** Where two halves differ in effect, cost or tier weight they are
  two modules, and where they do not the split stays unmade."
- reserved element block: `none`, so rows carry arc-local ids per
  [[decisions/decision-work-ids]]. This arc spells the letters `PS`, for part
  split: `part-split/PS1` upward. `PS` is free tree-wide, verified 2026-09-09.
  Author call B was ruled 2026-09-06, so a band is advisory and an arc without
  one mints the next number free tree-wide. The two-letter form follows
  `baseline-alignment`'s `BA` and [[arcs/tool-authority-arc]]'s `TA`.
- build-state authority: [[status-ledger]]
- checklist: none. No `records/part-split.md` exists.
- sibling: [[arcs/module-split-arc]], same goal, same condition, a different
  granularity. That arc cuts one file by type shape. This one cuts one namespace
  by tier weight.

## Why this arc exists

Condition 1 gives three ways two halves can differ, and the goal file observes
only one of them. Its observation is `conv` leaving `lib/typing/kernel.chiral`,
where the difference is signature: `(-> I64 Value Value Bool)` against
`(-> Sig Ctx Term ...)`. `module-split/S1` schedules that. **The third way,
tier weight, has no row anywhere**, and `prog/prapanca/` is where the tree
measured it. [[decisions/decision-orchestration-boundary]] §1 states the
condition in the engine's own words: prapañca "knows nothing about what it
orchestrates", and `profile/` holds one product's 30 `Expert` values and 10
`Config` values. One namespace carries the frozen interface and one product's
inhabitants of it. Two arcs on one condition is established practice;
[[goals/local-ai]] condition 1 is served by both [[arcs/transport-arc]] and
[[arcs/unit-lane-arc]].

The type-shape half of the argument is measurable and it holds. `profile/`
carries 93 top-level defs, of which 11 are arrow-typed and 82 are constants,
over a single `data` declaration. The staying half carries 293 defs, of which
199 are arrow-typed, over 33 `data` declarations. One half is a function
library, the other a value table typed by it. `chatter/` sits between at 85
arrow-typed against 78 constants, and tier weight is what carries its half:
[[decisions/decision-orchestration-boundary]] §1 measures its marker
vocabularies, its reply templates and its four-intent routing table as product
decisions. [[decisions/decision-part-layout]] §6 names the destination and
performs none of it, and the author ruled 2026-09-09 that the move happens now.

## What the tree already holds

Measured 2026-09-09. [[banks/INDEX]] holds thirteen and two own this territory:
[[banks/module]] refracts the namespace, [[banks/profile]] refracts the frozen
base with named profiles over it.

| group | what exists today | where | rung |
|---|---|---|---|
| seam | the two imports the boundary decision named: `all-profiles`, `config-id`, `doc-refine-pipeline`, `expert-pool`, `expert-by-id`, `expert-slot-of` | `prog/prapanca/pipeline/compose.chiral:18-19` | IMPLEMENTED |
| seam | the pipeline registry, called in the file's own words "the analog of `all-profiles`". `all-pipelines` holds one entry, `doc-refine-pipeline` | `prog/prapanca/pipeline/compose.chiral:52-55` | IMPLEMENTED |
| seam | the whole module is 71 lines and its four other defs are generic: `ids-slots` `:25`, `pipeline-slots` `:36`, `compose-preflight` `:47`, `pipeline-by-id` `:58` | `prog/prapanca/pipeline/compose.chiral` | IMPLEMENTED |
| seam | two further reaches from the staying half, uncounted by that decision, both test roots | `prog/prapanca/core/flow-test.prog:28`, `prog/prapanca/pipeline/persist-test.prog:16` | IMPLEMENTED |
| seam | who imports `compose`: the TUI's command surface, one prapañca test root, one ungated fixture | `prog/scriba/command-loop.chiral:32`, `prog/prapanca/pipeline/persist-test.prog:15`, `tools/test/samples/s16_compose.prog:13` | IMPLEMENTED |
| accessors | `expert-id`, `expert-slot-of`, `pipeline-gate`, `expert-by-id`, all four accessors on prapañca-owned shapes, all four defined in a product file | `prog/prapanca/profile/doc-refine.chiral:16`, `:18`, `:23`, `:100` | IMPLEMENTED |
| accessors | five renamed private copies of the same accessors, with a comment at `:41-45` naming the duplicate-label collision they dodge and citing E140's flag | `prog/prapanca/pipeline/plan.chiral:46-50` | IMPLEMENTED |
| move | `chatter/`: 5 `.chiral` at 2,057 lines, plus 5 `-test.prog` roots, 10 files | `prog/prapanca/chatter/` | IMPLEMENTED |
| move | `profile/`: 10 `.chiral` at 1,226 lines, plus 7 `-test.prog` roots, 17 files | `prog/prapanca/profile/` | IMPLEMENTED |
| move | the skill registry, seven entries: `doc-edit`, `code-test`, `evidence-sift`, `evidence-sift-refined`, `research`, `deep-research`, `decision` | `prog/prapanca/profile/skills.chiral:34-48` | IMPLEMENTED |
| move | 86 import lines name the two subtrees. 34 sit inside them, 52 outside: 4 in the staying half, 13 in scriba, 29 in `prog/samples/`, 6 in `tools/test/samples/` | tree-wide | IMPLEMENTED |
| move | 93 prose citations of the two paths across 32 files under `docs/`, `records/`, `.planning/` and `tools/` | tree-wide | DESIGNED |
| move | the rename precedent, twice: 180 files at 860 insertions against 860 deletions, then 24 files | `b6065d1`, `da71912` | ENFORCED |
| dependents | the TUI's main root reaches the assistant's product data through its command surface | `prog/scriba/scriba-main.prog:12` into `prog/scriba/command-loop.chiral:32`, `:35`, `:36`, `:38` | IMPLEMENTED |
| dependents | 13 scriba import lines over 6 files reach the two subtrees: `chat-view.chiral:24-25`, `command-loop.chiral:35-38`, `chat.chiral:23-24`, `manas-runview.chiral:31-32`, `manas-mode.chiral:23-24`, `scriba-manas-test.prog:19-20` | `prog/scriba/` | IMPLEMENTED |
| dependents | Phase 7 compiles every root under `lib` and `prog` carrying `(def compile-main`. 103 roots, and 33 of them name the two leaving subtrees | `tools/test/run-tests.sh:172-177` | ENFORCED |
| dependents | no `run_phase` line fires a `prapanca-*` root. A grep over `tools/test/*.sh` for `prapanca-` returns nothing, and `s16_compose.prog` is named by its own SPEC and by `.planning/MIGRATION-MAP.tsv` and by no script | `tools/test/` | SEEDED |
| dependents | `prog/compiler.prog` imports one module, `lowering/compile-all`, and names prapañca zero times. The move changes no compiler source | `prog/compiler.prog:13` | ENFORCED |
| dependents | `records/conformance-map.md:209-210` still cites `scaffold/lib/manas/profile/skills.chiral` and `scaffold/lib/manas/chatter/{router,turn}.chiral`, stale paths renamed on 2026-09-08 | `records/conformance-map.md` | DESIGNED |

## What is missing, and its structure

| group | owns |
|---|---|
| G1 seam | where `compose.chiral` and its one-entry pipeline registry live once the product data leaves |
| G2 accessors | one home for the four generic accessors on `Expert` and `Pipeline`, and the retirement of the five renamed copies |
| G3 move | the bulk rename: 27 files, 86 import lines, 33 Phase 7 roots, 93 prose citations |
| G4 dependents | what scriba is declaring when it imports the assistant, stated once the import crosses a prog boundary |

### The edges that run against the order

| edge | direction | what crosses |
|---|---|---|
| G4 to G1 | against the numbering | `prog/scriba/command-loop.chiral:32` is the only production importer of `compose`. What the TUI needs from `all-pipelines` and `compose-preflight` decides where `compose` lands, so the seam call reads its answer from the group listed after it |
| G3 to G2 | against the numbering | the move does not create the accessor collision. `plan.chiral:41-45` records that the collision exists today and that renaming dodged it. What the move removes is the reason the dodge was tolerable: after it, the two copies sit in two progs and the surviving one is stranded on the wrong side. The bulk rename surfaces a design question that has to be settled before it |
| G3 to G4 | against the numbering | Phase 7 is the gate, and 33 of the 103 roots it compiles are inside the specimen. The gate proves the move only for the roots that survive it, and `prog/samples/prapanca-*` accounts for 18 of those 33. A root deleted instead of repointed makes the gate quieter and greener at once |

## REQUIREMENTS

Done when all six hold.

1. **Prapañca names no consumer.** [[decisions/decision-orchestration-boundary]]
   §4 states the rule and measures one violation. Observed by a grep over
   `prog/prapanca/` for `samvada` returning zero, and by the four reaches
   measured above (`pipeline/compose.chiral:18-19`,
   `pipeline/persist-test.prog:16`, `core/flow-test.prog:28`) each being gone.
2. **`compose.chiral` has one home and the pipeline registry has an owner.**
   Observed by the file existing at exactly one path, by `all-pipelines` having a
   written reason for sitting where it sits, and by its import list holding no
   product module.
3. **The four generic accessors are defined once tree-wide.** Observed by a grep
   for `(def expert-id`, `(def expert-slot-of`, `(def expert-by-id` and
   `(def pipeline-gate` returning one hit each, and by
   `prog/prapanca/pipeline/plan.chiral:41-50` either losing its five copies or
   restating a collision reason that is still true.
4. **The two subtrees are at `prog/samvada/` and every citation resolves.**
   Observed by `prog/prapanca/chatter/` and `prog/prapanca/profile/` not
   existing, and by a grep for `prapanca/chatter` and `prapanca/profile` over
   `.chiral`, `.prog`, `docs/`, `records/`, `.planning/` and `tools/` returning
   zero against the 86 import lines and 93 prose citations measured above.
5. **The suite is green from the same roots and the count is unchanged.**
   Observed by `tools/test/run-tests.sh` reporting the same phase count with
   Phase 7 compiling 103 roots and reporting no new failure, and by the 33 roots
   that name the two subtrees being repointed rather than dropped.
6. **Scriba's dependency on the assistant is written down.** Observed by each of
   the 13 import lines being either justified in one sentence or removed, and by
   `prog/scriba/scriba-main.prog` compiling with a stated answer to whether the
   editor's binary carries the assistant's skill table.

## Roster

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `part-split/PS1` | `compose.chiral`'s fate: whether the 71-line module follows its product data, splits at the registry, or stays generic with the registry handed in. Its four generic defs, `ids-slots` at `:25`, `pipeline-slots` at `:36`, `compose-preflight` at `:47` and `pipeline-by-id` at `:58`, against its product registry at `:52-55` and its two product imports at `:18-19` | G1 | decision | new | 1, 2 | designed | `unminted` |
| `part-split/PS2` | the four accessors on `Expert` and `Pipeline` get one home beside the shapes they case, retiring `doc-refine.chiral:16`, `:18`, `:23`, `:100` and the five renamed copies at `plan.chiral:46-50` | G2 | primitive | connect | 1, 3 | open | `unminted` |
| `part-split/PS3` | the bulk rename: 27 files from `prog/prapanca/{chatter,profile}/` to `prog/samvada/`, 86 import lines rewritten, the blob recipes in the 33 Phase 7 roots repointed. One symmetric diff, no logic changed, on the `b6065d1` and `da71912` pattern | G3 | tool | bind | 4 | open | `unminted` |
| `part-split/PS4` | the 93 prose citations across 32 files under `docs/`, `records/`, `.planning/` and `tools/`, plus the two stale `records/conformance-map.md:209-210` rows renamed away from `scaffold/lib/manas/` on 2026-09-08 | G3 | tool | bind | 4 | open | `unminted` |
| `part-split/PS5` | the gate: Phase 7 green over 103 roots with all 33 repointed, the four traps of the `b6065d1` pattern listed before the move, and the three ungated fixtures under `tools/test/samples/` named as ungated instead of counted as coverage | G3, G4 | tool | connect | 4, 5 | open | `unminted` |
| `part-split/PS6` | scriba's 13 import lines over 6 files, each ruled keep or cut, and the answer to whether `scriba-main.prog` carries the assistant's seven-entry skill table into the editor's binary | G4 | decision | connect | 6 | open | `unminted` |

### Coverage

The check was run and it passes on all three legs.

**Every requirement is named by a row.** 1 by `PS1` and `PS2`, 2 by `PS1`, 3 by
`PS2`, 4 by `PS3`, `PS4` and `PS5`, 5 by `PS5`, 6 by `PS6`.

**Every row names a requirement.** All six do.

**Every `origin` is defensible from the measurement above.** Four of six rows are
`bind` or `connect`, which is what a migration arc should look like: the code
exists and the question is where it sits.

- `PS1` is `new` because the question is unasked. `compose.chiral` is built and
  reached, and no document says where the pipeline registry belongs.
  [[decisions/decision-orchestration-boundary]] §4 names the import as a
  violation and rules nothing about the module holding it,
  [[decisions/decision-part-layout]] §6 repeats the citation and performs
  nothing. `PS1` settles a shape between built alternatives, which is the
  `coding-turn/A6` and `tool-authority/TA4` precedent for a `new` decision row.
- `PS2` is `connect` because both halves are built. Four accessors sit at
  `doc-refine.chiral:16`, `:18`, `:23`, `:100` and five copies of them sit at
  `plan.chiral:46-50`. The work joins two written things.
- `PS3` and `PS4` are `bind`: 27 files exist and need the prog surface
  [[decisions/decision-part-layout]] §6 named for them. Neither row writes a
  line of logic.
- `PS5` is `connect`: Phase 7 is built and green, the 33 roots are built, and
  the row joins them across the rename.
- `PS6` is `connect`: 13 import lines are written and compiling, and the row
  states what they mean once they cross a prog boundary.

### What this arc does not take

- **`prog/indriya/`.** It does not exist, and no row here creates it.
  [[decisions/decision-part-layout]] §3 places the tool layer and §4 draws its
  line against [[arcs/tool-authority-arc]]. The directory is filled by rows under
  [[arcs/coding-turn-arc]] and [[arcs/tool-authority-arc]]: `coding-turn/A1` is
  designed against the tool vocabulary as a value, `A2` against the four built
  tools reached through it, and `TA1` to `TA12` hold the authority mechanism
  under them. A grep for `indriya` over the tree returns one file,
  `docs/decisions/decision-part-layout.md`.
- **`prog/prapanca/manas.chiral`.** Both 2026-09-09 decisions carry it as an open
  author call, and both leave it open.
  [[decisions/decision-orchestration-boundary]] call 1 asks whether it is a
  consumer sitting inside the primitives. No row here moves it or renames it.
- **`prog/shilpa/`.** `da71912` performed that rename on 2026-09-09 with
  `agent.chiral` becoming `turn.chiral`. The three statements
  [[decisions/decision-part-layout]] §5 makes about it, the wire protocol moving,
  the duplicated transport going, and `ag-bash` being deleted, each belong to
  [[arcs/coding-turn-arc]].
- **The cut in `lib/typing/`.** `module-split/S1` through `S4` own the file-level
  half of this condition. No row here touches `lib/`.
- **`scriba/S4`.** That row splits the orchestrator out so the editor stops
  holding network authority, against a checklist measuring 87 network references
  in the editor's blob. `PS6` asks a smaller question, whether the editor's
  binary should carry one product's skill table, and answers nothing about
  network authority. The two are neighbours and `S4` keeps its subject.
- **[[joining-law]]'s typed connector.** `module-split/S1` owes it and
  [[goals/module-split]] condition 3 records that no row schedules it, as
  `GAP-07`. This arc's cut rejoins through imports across a prog boundary, which
  is a bare import by that law's test. Naming the gap is what this arc does about
  it.

## Resume state

Nothing built. Opened 2026-09-09, the same day both decisions this arc executes
were committed, `0aa1800` and `8c9a56e`.

**Where a session picks up.** `PS1`. The seam call gates `PS3`, and `PS2` gates
it in the other direction through the accessor question. Reading `PS1` first
also forces the G4 back-edge into the open: `prog/scriba/command-loop.chiral:32`
is `compose`'s only production importer, so the TUI's requirement is an input to
the ruling rather than a consequence of it.

**What blocks the arc.** No reserved element block, so no row here can mint. The
rows carry `PS` ids meanwhile per [[decisions/decision-work-ids]], and a band is
advisory since author call B was ruled 2026-09-06. The same block sits on
fourteen arcs.

**What the goal file does not yet say.** [[goals/module-split]] condition 1 names
`module-split/S1` and no other row. A back-pointer to this arc is owed there,
and this run writes only `docs/arcs/part-split-arc.md` and the
[[arcs/README]] row.

**What the build rule costs here.** `prog/compiler.prog` imports
`lowering/compile-all` and nothing else, and it names prapañca zero times, so the
move changes no compiler source. [[working-discipline]] asks for the
generation sequence when compiler sources change, and this arc owes none of it.
The gate is Phase 7 over 103 downstream roots and the suite total staying put.

**The trap list is owed before `PS3` runs.** `b6065d1` moved 180 files and four
names had to survive it: `/workspace/manas`, `manas-worker`, `manas-cursor` in
`face.sh`, and the three `.planning/MANAS-*.md` filenames. This move has its own
set, and `prog/scriba/manas-mode.chiral` and `prog/scriba/manas-runview.chiral`
are two filenames that keep the older word while importing what moves. `PS5`
owns listing them.
