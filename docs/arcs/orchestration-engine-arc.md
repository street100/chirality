---
node: arc-orchestration-engine
layer: navigation
related: [arcs/README, goals/local-ai, arcs/transport-arc, arcs/unit-lane-arc, arcs/part-split-arc, arcs/coding-turn-arc, arcs/scriba-arc, arcs/tuning-arc, banks/unit, banks/port, banks/profile, banks/verification, banks/capability, decisions/decision-work-ids, decisions/decision-orchestration-boundary, decisions/decision-scope, decisions/decision-design-before-mint, records/author-calls, records/homing-triage, status-ledger, working-discipline, index]
status: current
updated: 2026-09-14
---

# Arc: orchestration-engine

- goals: [[goals/local-ai]], condition 1: "**Full orchestration.** A gated
  multi-agent run executes end to end inside this tree: match, gate, bind, fan
  out, combine, stop, and emit a typed `RunManifest` that a golden oracle
  accepts. It runs under `bin/chirality-bin` and the Linux syscall surface with
  no other language beneath it. Checkable by a phase in
  `tools/test/run-tests.sh` that runs the pipeline and asserts the conformance
  verdict." (`docs/goals/local-ai.md:48-54`). This arc serves that condition
  alone. The fourteen elements it homes are all track `SH`
  (`docs/elements/ledger.md:265-278`), so no second goal's components sit
  inside them.
- reserved element block: **none**. Rows carry arc-local ids `OE1` upward per
  [[decisions/decision-work-ids]]. `OE` is spelled with two letters because a
  single `E` collides visually with the element numbers fourteen of these rows
  already carry, which is the same reason `baseline-alignment` spells `BA`.
  Fourteen rows hold a minted `E#`; the four rows that hold `unminted` are
  blocked from a number by the author call quoted as FLAG 3.
- build-state authority: [[status-ledger]]
- checklist: none. This arc opens without a `records/` file.

## Why this arc exists

Fourteen minted elements build the engine condition 1 describes and no roster
row held any of them. `records/homing-triage.md:234` proposed this arc and the
author approved opening it on 2026-09-14. The evidence the triage gives is that
condition 1's own arc sentence (`docs/goals/local-ai.md:53-54`) hands the
condition to [[arcs/transport-arc]] for "the reachability half" and to
[[arcs/unit-lane-arc]] for "the model of computation beneath it", while
`docs/goals/local-ai.md:40` calls catalog rows E133 to E143 "the engine's
element set". [[arcs/part-split-arc]] moves the engine's files and
[[arcs/coding-turn-arc]] reads its manifest. The engine itself had no owner.

What it takes for the condition to hold is a phase that runs the pipeline and
asserts a conformance verdict. Twelve of the fourteen elements are `built`, so
the work left is connection rather than construction: no phase in
`tools/test/run-tests.sh` executes any root of this subtree, the conformance
oracle reads a golden that lives outside this repository, and the trust
boundary the engine declares in its own types is produced by nothing. Those
three are what this arc's requirements name.

## What the tree already holds

Bank first. [[banks/unit]] is this concept's refraction and it already measured
the subtree on 2026-09-04: 7,289 lines over 40 files, 18 fixture roots, 21
sample roots, and zero of either executed by a `tools/test/*.sh` phase. The
figures below were re-taken on 2026-09-14 against the working tree and the
subtree has grown since the bank's pass.

| group | what exists today | where | rung |
|---|---|---|---|
| G1 core | the pure data model, 182 lines and 16 `data` declarations, imported by 58 files | `prog/prapanca/core/types.chiral` | IMPLEMENTED |
| G1 core | the gate, the binder, the matcher, the prompt assembler and the stop policy, all pure `->` | `prog/prapanca/core/{gate,bind,match,assemble,stop}.chiral` | IMPLEMENTED |
| G1 core | `stop.chiral` is imported by exactly one file, an ungated fixture. `overflow-guard` and `stop-policy` have no production caller | `tools/test/samples/e136_core.prog:18` | SEEDED |
| G1 core | `PreflightResult` and its three variants, the trust boundary in its runtime form. Declared once and occurring nowhere else in any `.chiral` or `.prog` | `prog/prapanca/core/types.chiral:106-109` | SEEDED |
| G1 core | the four `Config` profiles and the `doc-refine` `Pipeline` as typed values, 17 importers | `prog/prapanca/profile/{profiles,doc-refine}.chiral` | IMPLEMENTED |
| G2 seam | the `Backend` linear porttype and its `be-*` ops, 262 lines, 29 importers | `prog/prapanca/backend.chiral` | IMPLEMENTED |
| G2 seam | `be-log`, the worker crossing, posting to a worker outside this tree | `prog/prapanca/pipeline/log.chiral` | IMPLEMENTED |
| G3 run | the Mealy `Step` spine, 51 lines, imported by the breaker and the reference cycle | `prog/prapanca/fsm.chiral`, read at `prog/prapanca/manas.chiral:21` and `prog/prapanca/pipeline/guarded.chiral:15` | IMPLEMENTED |
| G3 run | the pure plan spine and the effectful fan-out loop. `run-pipeline` is read by `flow.chiral` and by the breaker; scriba reads `call-expert` and `call-combiner` | `prog/prapanca/pipeline/{plan,runner}.chiral`, `prog/scriba/manas-runview.chiral:30` | IMPLEMENTED |
| G3 run | `guarded-run`, the breaker folded over `cycle-step`. Its only importers are three `prog/samples/` roots | `prog/prapanca/pipeline/guarded.chiral` | SEEDED |
| G3 run | the reference cycle, 46 lines, zero importers anywhere in the tree | `prog/prapanca/coordinator.chiral` | SEEDED |
| G4 record | the manifest serializer, its inverse, and the structural conformance judgment | `prog/prapanca/contract/{manifest,golden}.chiral` | IMPLEMENTED |
| G5 gate | Phase 7 sweeps every root carrying `(def compile-main` and compiles it. Twenty-two of those roots name prapanca or shilpa | `tools/test/run-tests.sh:175`, `prog/samples/` | ENFORCED |
| G5 gate | eight element fixtures, `e134_gate` through `e141_conformance`. A grep over `tools/test/*.sh` for any of their basenames returns nothing | `tools/test/samples/` | SEEDED |
| G5 gate | zero files matching `*.golden.json` under this repository | tree-wide | DESIGNED |
| G5 gate | the conformance fixture reads an absolute path outside this tree. The file is present on this host and outside the repository | `tools/test/samples/e141_conformance.prog:119` | SEEDED |
| G5 gate | two conformance roots read `/workspace/chirality-the-lang/scaffold/tests/golden/manas-smoke-doc-refine.golden.json`, and that directory does not exist on this host | `prog/samples/prapanca-run-conform.prog:66`, `prog/samples/prapanca-flow-conform.prog:71` | SEEDED |
| G6 type-level | the two runtime first cuts the minted upgrades replace: `BindResult`'s `bind-miss` and `PreflightResult`'s `preflight-cloud` | `prog/prapanca/core/bind.chiral`, `prog/prapanca/core/types.chiral:106-109` | SEEDED |
| G6 type-level | `LocalZone` and `CloudZone` appear in one comment and in no declaration | `prog/prapanca/core/types.chiral:103-104` | DESIGNED |

Totals re-taken 2026-09-14: 7,741 lines across the subtree's `.chiral` files,
9,990 counting its `.prog` roots.

## What is missing, and its structure

| group | owns |
|---|---|
| G1 core | the pure data model and the pure decisions the whole engine is typed against |
| G2 seam | the linear model handle and the worker crossing beside it |
| G3 run | the fan-out loop, the breaker, and the reference cycle they compose over |
| G4 record | the `RunManifest`, its two serializers, and the conformance judgment |
| G5 gate | the phase that executes the engine, and the golden object it judges against |
| G6 type-level | the two minted upgrades that move a runtime sum into the type |

### The edges that run against the order

| edge | direction | what crosses |
|---|---|---|
| G5 to G4 | against the numbering | the golden decides what the oracle can assert. `manifest-conforms` is built and compares structurally; which fields are stable is fixed by the object it compares against, and that object sits outside this repository at two different absolute paths. The gate group is listed last and its answer is an input to the group before it |
| G6 to G1 | against the numbering | both minted upgrades are priced against a G1 sum. `PreflightResult` is produced by nothing today, so E142 would replace a check that has never run, and its cost cannot be weighed until G1's residue is measured. E143 stands in the same relation to `bind-config`, whose `bind-miss` does fire |
| G3 to G2 | against the numbering | whether the run loop can be gated hermetically decides what the seam may reach. `be-log` posts to a worker at `:8080` that is absent from this tree, and [[banks/unit]] §5 item 5 records that whether that worker sits inside the self-hosting track is unruled. The loop's gate is listed after the seam and settles the seam's admissible shape |

## REQUIREMENTS

Six. Each is checkable and each is this arc's own; none restates condition 1's
sentence, which is served jointly with [[arcs/transport-arc]] and
[[arcs/unit-lane-arc]].

1. **The engine's fourteen elements each hold a roster row.** Observed by
   `python3 tools/lens/lens.py chain`: the `catalog element -> arc roster row`
   rung rises by fourteen. Observed a second way by
   `python3 tools/ledger-lint/ledger-lint.py`, whose `element homes owed` count
   falls by twelve, because E142 and E143 were already admitted by an unspoken
   lens row and sat outside that count already. FLAG 8 carries the two rows.
   This file meets the requirement and the resume state holds both readings.

2. **A phase executes the engine and asserts on it.** Today
   `tools/test/run-tests.sh:175` compiles every root and no `run_phase` line
   names a prapanca root or any of the eight `e134_` through `e141_` fixtures,
   measured 2026-09-14 by grep over `tools/test/*.sh`. Observed by a
   `run_phase` line naming one of them, by the registration check at
   `tools/test/run-tests.sh:390` witnessing that line, and by the suite's
   assertion total moving.

3. **The conformance oracle reads a golden this repository holds.**
   `find . -name '*.golden.json'` returns nothing today, and three roots name
   two absolute paths outside the tree (`tools/test/samples/e141_conformance.prog:119`,
   `prog/samples/prapanca-run-conform.prog:66`,
   `prog/samples/prapanca-flow-conform.prog:71`). Observed by a golden object
   under this repository and by those three roots naming a repository-relative
   path.

4. **The trust boundary the engine declares is produced by something.**
   `PreflightResult`, `preflight-ok`, `preflight-missing` and `preflight-cloud`
   occur only at `prog/prapanca/core/types.chiral:106-109`, measured 2026-09-14
   by grep over every `.chiral` and `.prog` in the tree. `compose-preflight`
   (`prog/prapanca/pipeline/compose.chiral:47-49`) carries the preflight name
   and returns E135's `BindResult`. Observed by an occurrence of
   `preflight-cloud` outside its own declaration together with a caller that
   cases it.

5. **Every module of the engine is reached, or its unreach is recorded with a
   reason.** `prog/prapanca/coordinator.chiral` has zero importers and
   `prog/prapanca/core/stop.chiral` has one, an ungated fixture. Observed by an
   importer on a shipping path, or by a `records/` row that moves the module to
   SEEDED and states why it stays there.

6. **E142 and E143 each name the compiler fact that blocks them.** Both are
   `design` in `docs/elements/ledger.md:277-278` and absent from the code.
   `docs/elements/catalog.md:251` gates E142 on "how far the
   refinement/quantity fragment reaches" and nothing in the tree has measured
   that reach. Observed by each of the two rows below carrying the blocking
   fact cited at `file:line`, per the author's 2026-09-10 instruction that an
   owed row names the real blocking condition and never the track.

## Roster

Eighteen rows. Fourteen carry an already-minted `E#` and this arc mints
nothing. A row whose state reads `open` beside an `E#` holds a number with its
pipeline owed.

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `orchestration-engine/OE1` | the FSM engine, the Mealy `Step` spine: `Step`, `drive`, `run-fsm` over 51 lines, read by the breaker and by the reference cycle | G3 | primitive | new | 1 | built | `E66` |
| `orchestration-engine/OE2` | the manas orchestration profile and the coordinator cycle. `manas.chiral`'s `cycle-step` is composed by `guarded.chiral:14`; `coordinator.chiral`'s 46 lines have zero importers, which is this row's residue and requirement 5's first case | G3 | primitive | new | 1, 5 | built | `E67` |
| `orchestration-engine/OE3` | the model-server backend seam, OpenAI-compatible: `be-chat`, `be-chat-stream`, `be-health`, `be-models`, `be-embed`, `be-search` over 262 lines with 29 importers | G2 | port | new | 1 | built | `E68` |
| `orchestration-engine/OE4` | the pure data model the whole engine is typed against, 16 `data` declarations over 182 lines. Its residue is `PreflightResult` at `prog/prapanca/core/types.chiral:106-109`, declared and produced by nothing, which is requirement 4 | G1 | primitive | new | 1, 4 | built | `E133` |
| `orchestration-engine/OE5` | the GATE and router: `run-gate` folding condition predicates, pure `->`, so the membrane proves the router calls no model | G1 | law | new | 1 | built | `E134` |
| `orchestration-engine/OE6` | config binding, slot to model: `bind-config` resolving each fired agent's slot to a `(model, num_ctx)` pair, a miss returned as a `bind-miss` value | G1 | law | new | 1 | built | `E135` |
| `orchestration-engine/OE7` | match, assemble and stop, the pure-core remainder. Its residue is `stop.chiral`, whose only importer is `tools/test/samples/e136_core.prog:18` and which no phase runs, so `stop-policy` has no production caller. `coding-turn/A8` holds `overflow-guard`'s first caller and this row leaves that half there | G1 | law | new | 1, 5 | built | `E136` |
| `orchestration-engine/OE8` | `Backend` as a linear porttype: every `be-*` takes `(1 b Backend)` and returns a fresh handle in its result sum, so a run is a proven-unbroken linear chain | G2 | port | bind | 1 | built | `E137` |
| `orchestration-engine/OE9` | the multi-agent run loop: gate, fan out over the fired experts, combine, under a stop policy with the breaker folded in. Its residue is the catalog's own deferral of the live fan-out run to an integration pass, which is requirement 2 | G3 | primitive | new | 1, 2 | built | `E138` |
| `orchestration-engine/OE10` | `be-log`, the worker seam op, with the LOG-01 and LEARN-01 serializers beside it and the per-call fan-out fired | G2 | port | connect | 1 | built | `E139` |
| `orchestration-engine/OE11` | the four `Config` profiles and the `doc-refine` `Pipeline` as typed chirality values, the payload the binding seam consumes. `part-split/PS3` moves these two files and owns the move; this row owns the element | G1 | primitive | new | 1 | built | `E140` |
| `orchestration-engine/OE12` | golden-manifest conformance: `manifest-from-json` and `manifest-conforms`, comparing structurally on the stable fields. Its residue is the catalog's own deferral of the live run-to-golden compare, and the golden it reads sits outside this repository, which is requirement 3 | G4 | law | new | 1, 3 | built | `E141` |
| `orchestration-engine/OE13` | trust-zone capability tokens: `LocalZone` and `CloudZone` as erased proof tokens `be-chat` requires, so binding a cloud model under a local-zone run is a compile refusal. **What is actually wanted and what is owed first:** the runtime first cut this upgrades, `PreflightResult`, is produced by nothing, so requirement 4 stands in front of it. **The blocking condition is unmeasured.** `docs/elements/catalog.md:251` gates the row on "how far the refinement/quantity fragment reaches" and no measurement of that reach exists in this tree, which is requirement 6 | G6 | law | new | 1, 4, 6 | open | `E142` |
| `orchestration-engine/OE14` | a dependent config-coverage type: `Config` parameterized by the slots it covers, with `bind-config` taking an erased coverage proof, so a config that fails to cover a pipeline's slots is refused at definition. **What is actually wanted:** the compile-time form of the `bind-miss` that `bind-config` already returns, which does fire. **The blocking condition is unmeasured.** `docs/elements/catalog.md:252` names the `Pool n` refinement at `ports.chiral:20` and E39 row-subsumption as the precedents and prices neither, which is requirement 6 | G6 | law | new | 1, 6 | open | `E143` |
| `orchestration-engine/OE15` | a phase in `tools/test/run-tests.sh` that executes the engine and asserts a conformance verdict, over the roots and fixtures that exist and are run by nothing. Which root it fires is a design question this row does not answer: two under `prog/samples/` already carry the exit contract and eight fixtures under `tools/test/samples/` carry per-element assertions | G5 | tool | connect | 2 | open | `unminted` |
| `orchestration-engine/OE16` | a golden object inside this repository, and the three roots repointed onto a repository-relative path. The absolute path at `tools/test/samples/e141_conformance.prog:119` resolves on this host today and the one at `prog/samples/prapanca-run-conform.prog:66` resolves nowhere, so the two are different failures with one repair | G5 | tool | connect | 3 | open | `unminted` |
| `orchestration-engine/OE17` | a producer for `PreflightResult` and a caller that cases it, so the trust boundary the engine declares is checked somewhere. `compose-preflight` is the named candidate and returns `BindResult` today | G1 | law | connect | 4 | open | `unminted` |
| `orchestration-engine/OE18` | `prog/prapanca/coordinator.chiral` reached by a shipping path, or moved to SEEDED in `records/` with the reason it stays unreached. `guarded.chiral` composes `manas.chiral`'s `cycle-step` and reaches the coordinator for nothing | G3 | tool | connect | 5 | open | `unminted` |

### Coverage

**Every requirement is named by at least one row.** 1 by all fourteen element
rows; 2 by `OE9` and `OE15`; 3 by `OE12` and `OE16`; 4 by `OE4`, `OE13` and
`OE17`; 5 by `OE2`, `OE7` and `OE18`; 6 by `OE13` and `OE14`. None is
unscheduled.

**Every row names at least one requirement.** All eighteen carry a `req` cell.

**Every `origin` is defensible from the section above, and the twelve `built`
rows need the test stated plainly.** `origin` records what the work was when it
happened; `state` records where the row stands now. A `built` row marked `new`
therefore claims nothing absent, because its state cell says the work landed
and the table above cites the file. The four rows that are open and unminted
are each `connect`: `OE15` joins a built engine to a built suite, `OE16` joins a
built oracle to an object this tree lacks, `OE17` joins a declared sum to a
producer, and `OE18` joins an unreached module to a path or to a record. `OE13`
and `OE14` are `new` and their work is measured absent: `LocalZone` and
`CloudZone` have no declaration anywhere, and no erased coverage proof exists.
`OE8` is `bind` because `Backend` existed as plain data and the element gave it
a linear surface. No row here is the phantom-feature error.

## What this arc does not take

- **Reachability.** [[arcs/transport-arc]] holds the four rows that gave
  `http-request`, `backend-open` and `chat-open` a runtime referent, and Phase
  20 gates that path. No row here touches `lib/protocol/`.
- **The model of computation.** [[arcs/unit-lane-arc]] holds condition 3 and
  its 43 rows over the `E196-E239` band. `prog/prapanca/core/flow.chiral`, 1,432
  lines, carries no element number in the catalog and no row here claims it.
  [[banks/unit]] §5 items 1 and 2, typed I/O on `Expert` and `ty-eq`'s blind
  spot, are `Flow` residue and belong with that lane.
- **The file move.** [[arcs/part-split-arc]] moves `prog/prapanca/chatter/` and
  `prog/prapanca/profile/` into `prog/samvada/`, which reaches E140's two
  files. That arc owns the move and its boundary section already declines
  `prog/prapanca/manas.chiral`, which is E67's other half, on
  [[decisions/decision-orchestration-boundary]] call 1. `OE2` names the
  coordinator and leaves `manas.chiral`'s home to that call.
- **The manifest's consumer.** [[arcs/coding-turn-arc]]'s `A7` records a
  crossing beside a `RunManifest` without changing its 15 keys, and that arc's
  own boundary section states the split. `OE12` owns the conformance judgment
  and owns no consumer of it.
- **The allocation gap.** [[banks/unit]] §5 item 6 names it as threatening
  every unit in this bank at scale. [[arcs/memory-discipline-arc]] holds it.
- **Fine tuning and the transformer verbs.** [[arcs/tuning-arc]] holds
  condition 4, blocked whole on author call A.

## FLAGs

⚑ **FLAG 1: this arc lands in the unanchored set of the goal-arc census.**
`python3 tools/lens/lens.py chain`'s `arc -> goal done-condition` rung reads
which arcs no goal condition names. `docs/goals/local-ai.md:53-54` hands
condition 1 to [[arcs/transport-arc]] and [[arcs/unit-lane-arc]] and does not
name this arc, so the census reports this arc beside the four already there.
The goal file is outside this run's write surface and the repair is one
sentence in it.

⚑ **FLAG 2, an author call carried verbatim from `records/author-calls.md:149-151`.**
It is the contract for four of the elements homed here:

> **`.planning/METIS-PORT-SPEC.md`** is cited 5x as the contract for E133-E136 and
> is present nowhere in the tree. Whether those four built manas elements are
> re-grounded on a surviving document or recorded as ungrounded is a call.

The call as written names E133 to E136. `docs/elements/catalog.md`'s reference
cells cite the same absent document for E137 through E143 as well, measured
2026-09-14, so it stands over eleven of this arc's fourteen element rows. E66,
E67 and E68 are the three that cite something else.

⚑ **FLAG 3, an author call carried verbatim from `records/author-calls.md:252-261`.**
It is why `OE15` through `OE18` read `unminted`:

> The transport arc (give `http-request`, `backend-open` and `chat-open` a runtime
> referent) and the tuning arc (criterion 4) have no block, so every row in them
> writes `UNASSIGNED`. This is the same block that stops
> [[arcs/text-tools-arc]]'s P2, P3 and P4 rows, and that arc already carries its
> own row above. One ruling can cover both.
>
> **Widened 2026-09-02.** The same ruling now blocks three more arcs, so it is one
> call over six rather than two

This arc is the seventh. Its four unminted rows name measured work and the
numbering is what is absent, which is that call's own diagnosis.

⚑ **Two open author calls do not reach this arc, and saying so is part of the
homing.** Whether a design or a SPEC for an `OT` element counts as planning
(`docs/decisions/decision-scope.md:131-132`) reaches `OT` rows alone, and all
fourteen elements here are `SH` at `docs/elements/ledger.md:265-278`. The `?`
track call is named for the six rows E52, E71, E77, E78, E166 and E167
(`records/author-calls.md:369`) and none of the fourteen is among them. Four of
the six were ruled 2026-09-15 and the call stands open on E166 and E167, which
moves neither half of this paragraph.

⚑ **FLAG 4: the catalog's E138 signature and the live code disagree.**
`docs/elements/catalog.md:247` gives `run-pipeline` as
`(=> (1 b Backend) (1 e Exit) (0 z LocalZone) Pipeline Config Str Str (List (Pair Str Str)) (=> Str Unit) (Pair Str RunManifest))`.
`prog/prapanca/pipeline/runner.chiral:188` reads
`(=> (1 b Backend) Str (List Pipeline) (List Expert) Config Str (List (Pair Str Str)) RunR)`.
`Exit` and `LocalZone` appear in neither the signature nor any declaration, and
`LocalZone` survives only in a comment at `runner.chiral:9` and at
`types.chiral:103`. The catalog is outside this run's write surface.

⚑ **FLAG 5: `records/homing-triage.md` contradicts itself on this arc's size.**
`:76-77` reads `orchestration-engine` (13) and `:239` reads "That count is 14 plus
5 plus 1 plus 1, which is 21". Fourteen is the figure that reconciles, and the
row at `:234` lists fourteen element numbers. That file is outside this run's
write surface.

⚑ **FLAG 6: the triage's account of check AE is stale.** Its §Method states
that `tools/ledger-lint/ledger-lint.py:1883` matches `\bE(\d+)\b` over a whole
arc file, so prose reads as coverage. The live `_homed` at
`tools/ledger-lint/ledger-lint.py:1882-1903` reads the element cell alone
through `pack.row_elements`, whose docstring fixes the cell as "a
comma-separated list of E# and nothing else". Prose naming an element no longer
homes it, which is why this arc's element numbers in prose cost the owed count
nothing.

⚑ **FLAG 7: homing four of these rows makes `ledger-lint` check AH fail, and
the failure is the honest report.** AH asks a `built` row for the artifact its
state claims. It exempts work built before
[[decisions/decision-design-before-mint]] by looking for a worked example at
`docs/examples/E<NN>-*.md`. `OE1`, `OE2`, `OE3` and `OE8` hold E66, E67, E68 and
E137, and those four have neither a worked example nor a SPEC, so eight AH rows
fire against this file. The other eight built rows are exempt because E133 to
E141 each carry both. Writing a design or a SPEC is outside this run's unit, and
the four rows are the tree's own record that those elements were built with no
pipeline artifact behind them.

⚑ **FLAG 8: two lens rows are stale the moment this arc lands.**
`records/lenses/unspoken.md` UNS-37 and UNS-38 read "E142 is unbuilt and no arc
names it" and the same for E143, each measuring that "no file in docs/arcs/
names" the element. `OE13` and `OE14` name both. Those two rows are also why
check AE's owed count falls by twelve here instead of fourteen: an element
admitted by an unspoken row was already outside that count.
`records/lenses/` is outside this run's write surface.

⚑ **FLAG 9: `docs/arcs/README.md`'s closing paragraph counts twenty arcs and
its table lists more.** Adding this arc's row makes that paragraph one further
out of date. The write surface for this run is the table row alone.

## Resume state

Opened 2026-09-14 on the author's approval of the `orchestration-engine`
proposal in `records/homing-triage.md:234`. Nothing built by this arc. Twelve of
its eighteen rows were built between 2026-08-15 and 2026-08-16 under the
pipeline that preceded [[decisions/decision-design-before-mint]], and two more
hold a number with the pipeline owed.

**Where a session picks up.** `OE16`, the golden. It gates `OE15`, because what
a phase can assert is decided by the object it judges against, and the census
edge G5 to G4 is the same fact. `OE16` is also the cheapest of the four to
settle: the object exists on this host at
`/workspace/manas/orchestrator/golden/3dde39e42ec84ef0a94dd72e204d0572-manifest.json`
and the question is whether this tree copies it in or generates its own.

**What blocks the arc.** No reserved element block, so `OE15` through `OE18`
cannot mint. FLAG 3 carries the call. FLAG 2's missing contract stands over
seven of the built rows and nothing in this arc depends on it being answered
first.

**Requirement 1's two observations, taken 2026-09-14 either side of this
file.** `python3 tools/lens/lens.py chain` moved the `catalog element -> arc
roster row` rung from 44 of 187 to 58 of 187, a rise of fourteen, and moved
`roster row -> arc requirement` from 297 of 297 to 315 of 315, so all eighteen
rows name a requirement and none is orphaned. `python3 tools/ledger-lint/ledger-lint.py`
moved `element homes owed` from 99 to 87, a fall of twelve, and FLAG 8 holds the
reason the two figures differ.

**What was measured, 2026-09-14.** The subtree at 7,741 `.chiral` lines and
9,990 counting its roots; 22 roots under `prog/samples/` naming prapanca or
shilpa and 8 fixtures under `tools/test/samples/`, with zero of the thirty
named by any `tools/test/*.sh`; zero `*.golden.json` under this repository;
`PreflightResult` at one occurrence, its own declaration;
`prog/prapanca/coordinator.chiral` at zero importers.
