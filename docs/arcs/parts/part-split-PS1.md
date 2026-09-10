---
row: part-split/PS1
arc: part-split
title: "`compose.chiral`'s fate: whether the 71-line module follows its product data, splits at the registry, or stays generic with the registry removed"
kind: decision
origin: new
req: 1, 2
status: draft
updated: 2026-09-10
---

# part-split/PS1: `compose.chiral`'s fate

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** `prog/prapanca/pipeline/compose.chiral` must hold no import of a
  module that moves to `prog/samvada/`, and the pipeline registry `all-pipelines`
  must have a home whose reason survives the move.
- **Serves:** requirement 1 of [[arcs/part-split-arc]], "**Prapañca names no
  consumer.** [[decisions/decision-orchestration-boundary]] §4 states the rule and
  measures one violation"; and requirement 2, "**`compose.chiral` has one home and
  the pipeline registry has an owner.** Observed by the file existing at exactly
  one path, by `all-pipelines` having a written reason for sitting where it sits,
  and by its import list holding no product module."
- **Goal:** [[goals/module-split]], condition 1. Where two halves differ in
  effect, cost or tier weight they are two modules.
- **Why it is first.** `prog/prapanca/pipeline/compose.chiral:18-19` is the one
  violation [[decisions/decision-orchestration-boundary]] §4 measures. `PS3` moves
  `prog/prapanca/profile/` to `prog/samvada/`. Run in that order, the import at
  `:18-19` becomes prapañca importing samvada, which is the direction §4 forbids.

## 2. What the tree holds

Measured 2026-09-10 against the working tree.

- **Bank:** [[banks/module]]. Its load-bearing clause is that a module is
  "individuated by its type, not its subject" (`docs/banks/module.md:50-56`),
  and shard 5 gives that operational content: a split is real iff the two halves
  have different type, spurious iff the same type shape
  (`docs/banks/module.md:182-186`). `MAP.md:163` lowers the same rule onto the
  tree: "Source is individuated by kind (the extension) and placed by role (the
  directory)." [[banks/profile]] owns the second half of the territory: a profile
  is a name, a manifest, a frozen port set and a target
  (`docs/banks/profile.md`, §1). `all-profiles` and `all-pipelines` are the two
  registries that name what a profile picks from.

### The file under the row

| what exists | where | rung | reached by |
|---|---|---|---|
| the module, 71 lines, 7 `def` | `prog/prapanca/pipeline/compose.chiral` | IMPLEMENTED | `prog/scriba/command-loop.chiral:32`, `prog/prapanca/pipeline/persist-test.prog:15`, `tools/test/samples/s16_compose.prog:13` |
| `ids-slots`, dangling id dropped, total | `prog/prapanca/pipeline/compose.chiral:25` | IMPLEMENTED | `compose.chiral:40` only |
| `pipeline-slots`, the conservative selection-time slot set | `prog/prapanca/pipeline/compose.chiral:36` | IMPLEMENTED | `compose.chiral:49`, `tools/test/samples/s16_compose.prog:35` |
| `compose-preflight`, pure glue over E135's `bind-config` | `prog/prapanca/pipeline/compose.chiral:47` | IMPLEMENTED | `prog/scriba/command-loop.chiral:1467`, `tools/test/samples/s16_compose.prog:45` and `s16_compose.prog:49` |
| `all-pipelines`, the pipeline registry, one entry, under a comment at `compose.chiral:51-53` calling it "the analog of all-profiles" | `prog/prapanca/pipeline/compose.chiral:54` | IMPLEMENTED | `prog/scriba/command-loop.chiral:1260`, `command-loop.chiral:1281`, `command-loop.chiral:1488`, `command-loop.chiral:1491`, `prog/prapanca/pipeline/persist-test.prog:79` |
| `pipeline-by-id`, list handed in | `prog/prapanca/pipeline/compose.chiral:58` | IMPLEMENTED | `prog/scriba/command-loop.chiral:1260`, `command-loop.chiral:1491` |
| `pipeline-ids`, list handed in | `prog/prapanca/pipeline/compose.chiral:68` | IMPLEMENTED | `prog/scriba/command-loop.chiral:1281`, `command-loop.chiral:1488` |
| `config-ids`, list handed in | `prog/prapanca/pipeline/compose.chiral:70` | IMPLEMENTED | `prog/scriba/command-loop.chiral:1283`, `command-loop.chiral:1494` |

**Correction to the row title.** It says "four generic defs". There are seven
`def` in the file and six of them are generic: `ids-slots` `:25`,
`pipeline-slots` `:36`, `compose-preflight` `:47`, `pipeline-by-id` `:58`,
`pipeline-ids` `:68`, `config-ids` `:70`. The seventh is `all-pipelines` `:54`,
and it is the only one that names a product value. Three of the six already take
their list as a parameter.

### What the two product imports actually carry

| symbol, at its defining site | brought in by | used in `compose.chiral` |
|---|---|---|
| `all-profiles`, `prog/prapanca/profile/profiles.chiral:51` | `compose.chiral:18` | never. `compose.chiral:52` mentions it in a comment |
| `config-id`, `prog/prapanca/profile/profiles.chiral:15` | `compose.chiral:18` | `compose.chiral:71`, a generic accessor on `Config` |
| `doc-refine-pipeline`, `prog/prapanca/profile/doc-refine.chiral:124` | `compose.chiral:19` | `compose.chiral:55`, inside `all-pipelines` |
| `expert-pool`, `prog/prapanca/profile/doc-refine.chiral:88` | `compose.chiral:19` | never |
| `expert-by-id`, `prog/prapanca/profile/doc-refine.chiral:100` | `compose.chiral:19` | `compose.chiral:30`, a generic accessor on `Expert` |
| `expert-slot-of`, `prog/prapanca/profile/doc-refine.chiral:18` | `compose.chiral:19` | `compose.chiral:31`, a generic accessor on `Expert` |

Two of the six are dead in this file. Three are generic accessors that case an
E133 shape. **One product value crosses the seam, `doc-refine-pipeline` at
`:55`.**

### Why the dead imports are live anyway

The loader holds one flat name space and refuses a duplicate by name, "exact at
any distance, across any number of intervening imports"
(`lib/module/loader.chiral:145-147`). An import therefore republishes every name
it reaches. `prog/scriba/command-loop.chiral` imports neither
`prapanca/profile/profiles` nor `prapanca/profile/doc-refine` (its full import
list is `:15-38`), and it uses `all-profiles` at `:1283`, `:1494` and
`expert-pool` at `:1467`. It reaches both through `compose.chiral:18-19`.

`compose.chiral:18` and half of `:19` exist to republish product names into
scriba. The other two importers do not need that: `persist-test.prog:16` imports
`prapanca/profile/profiles` directly and `s16_compose.prog:15-16` imports both
product modules directly.

### The sibling that answered the same question the other way

| what exists | where | rung | reached by |
|---|---|---|---|
| `plan.chiral` imports no product module. Its import list is `:21-26`, all `prelude` and `prapanca/core` | `prog/prapanca/pipeline/plan.chiral:21-26` | IMPLEMENTED | the run loop |
| five private accessors renamed to dodge the flat-namespace collision, with the reason written at `:41-45` citing E140's duplicate-label FLAG | `prog/prapanca/pipeline/plan.chiral:46-50` | IMPLEMENTED | `find-expert` at `:54`, the plan spine |
| `find-expert`, which is `expert-by-id` under another name | `prog/prapanca/pipeline/plan.chiral:53-54` | IMPLEMENTED | the plan spine |

`plan.chiral` is 187 lines and `compose.chiral` is 71. Two sibling files in
`prog/prapanca/pipeline/` need the same three accessors. One copies them
privately and imports no product module. The other imports two product modules.
The tree holds both answers.

### The mirror defect in the file that moves

`prog/prapanca/profile/profiles.chiral` is 7 `def`: `config-id` `:15`,
four `Config` values `:21`, `:29`, `:36`, `:44`, the registry `all-profiles`
`:51`, and `profile-by-id` `:60`. Two generic accessors wrapped around four
product values and one registry. `compose.chiral` is the same mixture inverted:
six generic defs wrapped around one registry.

### The reason the current home was chosen

`docs/elements/specs/S16-manas-compose-SPEC.md:425-434` decision D2 puts the pure
core in the manas library "because `pipeline-slots` is genuinely a library
concern" and "a library home keeps it unit-testable ... with no scriba, no PTY".
The rejected alternative was `manas-mode.chiral`, inside scriba. D7 at `:473-478`
rules `all-pipelines` "a `def`, not a new element ... a trivial in-file value,
not a catalog row", justified as "the analog of `all-profiles`
(`profiles.chiral:51`)".

D2 argues against a scriba home. It says nothing about prapañca against samvada,
because neither name existed on 2026-08. D7's justification is the analogy to
`all-profiles`, and `all-profiles` is in a file that moves.

### Build state and gates

| what | where | rung |
|---|---|---|
| `compose.chiral` has no `docs/elements/catalog.md` row and no `docs/elements/ledger.md` row. It is S16, a scriba-track SPEC | `docs/examples/INDEX.md:189` | IMPLEMENTED |
| the types it is written against | E133, `prog/prapanca/core/types.chiral` | built (`docs/elements/ledger.md:266`) |
| the pre-flight it wraps | E135 `bind-config`, `prog/prapanca/core/bind.chiral` | built (`docs/elements/ledger.md:268`) |
| the product data it reaches | E140, `prog/prapanca/profile/{profiles,doc-refine}.chiral`, whose catalog row names the five local accessors and states "E133 has none" | `docs/elements/catalog.md:246` |
| Phase 7 compiles every root under `lib` and `prog` carrying `(def compile-main`, so `persist-test.prog` is gated and `s16_compose.prog` is not | `tools/test/run-tests.sh:172-177` | ENFORCED for the first, ungated for the second |

## 3. The delta

`compose.chiral` holds one product value, `doc-refine-pipeline` at `:55`, and
republishes four more names into scriba through `:18-19`. Nothing in the tree
decides where that value and that republication belong once
`prog/prapanca/profile/` becomes `prog/samvada/`.

The delta is a decision that does not exist, and the tree holds two live answers
that disagree:

1. `plan.chiral:41-50` answers "a spine module copies the accessor privately and
   imports no product module", and writes the reason down.
2. `compose.chiral:18-19` answers "a pipeline module imports the product module",
   and writes no reason for the product half.

Neither file cites the other. `docs/elements/specs/S16-manas-compose-SPEC.md`
D2 settles compose against a scriba home and does not reach this question.
[[decisions/decision-orchestration-boundary]] §4 names `:18-19` as a violation
and leaves the repair open: its second open call at `:154-157` is whether the two
subtrees move now or trail, and it names `compose.chiral:18-19` as "the one seam
that has to be cut either way" without saying how to cut it.

Three further facts are unsettled and belong to this row:

- `all-profiles` and `expert-pool` reach scriba only through
  `compose.chiral:18-19`. Cutting the seam breaks `prog/scriba/command-loop.chiral`
  at `:1283`, `:1467`, `:1494` unless scriba imports the product module itself.
- `prog/prapanca/pipeline/persist-test.prog` is a prapañca test root that reads
  `all-pipelines` `:79` and `all-profiles` `:79` through `:15-16`. Requirement 1
  measures itself by a grep over `prog/prapanca/` returning zero, and this root is
  inside that grep.
- `tools/test/samples/s16_compose.prog` imports compose `:13` and both product
  modules `:15-16`, and no `run_phase` line fires it.

**Verdict:** a real delta. It is a placement ruling plus a two-line code change,
and no artifact in the tree states the ruling today.

## 4. The shapes

Four forms carry the registry and the imports. Two more are listed and refused.

### Shape A: the whole file follows its product data into `prog/samvada/`

- **Form:** `prog/prapanca/pipeline/compose.chiral` becomes
  `prog/samvada/compose.chiral`. Its imports at `:18-19` stop crossing a prog
  boundary. `prog/scriba/command-loop.chiral:32` imports `samvada/compose`.
- **Costs:** the file's six generic defs leave prapañca. `pipeline-slots` `:36` is
  the selection-time analog of `plan-run`'s runtime bind at
  `prog/prapanca/pipeline/plan.chiral:111`, and the two stop being siblings.
  `compose-preflight` `:47` is pure glue over E135, which stays. A second
  consumer wanting a pre-flight either imports samvada or copies 25 lines.
  `prog/prapanca/pipeline/persist-test.prog` keeps its two product imports and
  gains a third reach, so requirement 1's grep still returns hits.
- **Forbids:** a prapañca-side pre-flight. It also makes the TUI declare a
  dependency on the assistant for a computation that has nothing product-specific
  in it. That is unwanted: `docs/banks/module.md:50-56` individuates by type, and
  `MAP.md:163` places by role. Six of seven defs have a generic type and a
  generic role.

### Shape B: split at the registry, `all-pipelines` lands beside its one entry

- **Form:** delete `all-pipelines` `:54-55` and the imports at `:18-19`. Define
  `all-pipelines` in `prog/prapanca/profile/doc-refine.chiral` under
  `doc-refine-pipeline` `:124`, so it moves with `PS3` and arrives as
  `prog/samvada/doc-refine.chiral`. `compose.chiral` keeps its six generic defs
  and stays at `prog/prapanca/pipeline/compose.chiral`. It takes `expert-by-id`,
  `expert-slot-of` and `config-id` from wherever `PS2` puts them.
- **Costs:** `prog/scriba/command-loop.chiral` gains two import lines, for
  `samvada/doc-refine` and `samvada/profiles`, replacing the republication it
  gets today. `prog/prapanca/pipeline/persist-test.prog` gains one, and stays a
  reach requirement 1 counts. `compose.chiral` becomes empty of product data and
  gains a hard dependency on `PS2` landing the three accessors somewhere
  prapañca-side.
- **Forbids:** a prapañca module ever naming a pipeline. `all-pipelines` grows as
  pipelines are minted, and after this it grows in samvada. That is wanted:
  `docs/elements/specs/S16-manas-compose-SPEC.md:473-478` justified the registry
  by the analogy to `all-profiles`, and the analogy carries the registry to
  wherever `all-profiles` goes.

### Shape C: registry removed, the list is a parameter everywhere

- **Form:** delete `all-pipelines` `:54-55` and the imports at `:18-19`, and
  define no replacement. Every caller builds its own list. `pipeline-by-id`
  `:58`, `pipeline-ids` `:68` and `config-ids` `:70` already take theirs as a
  parameter, so the change is two deleted lines and five repaired call sites in
  `prog/scriba/command-loop.chiral` and `prog/prapanca/pipeline/persist-test.prog`.
- **Costs:** the registry stops being one name. `prog/scriba/command-loop.chiral`
  writes `(cons doc-refine-pipeline nil)` at four sites, or defines a local
  registry, which is Shape B with the registry landing in scriba instead of
  samvada. `prog/prapanca/pipeline/persist-test.prog:79` builds a fifth. Adding a
  second pipeline then edits every site.
- **Forbids:** requirement 2's second clause. "`all-pipelines` having a written
  reason for sitting where it sits" has no subject once no `all-pipelines`
  exists. The requirement would have to be amended to read that no registry
  exists, and the amendment would have to survive `PS6`'s ruling on whether
  scriba defines one.

### Shape D: the registry stays in prapañca and is emptied

- **Form:** `all-pipelines` stays at `:54` and becomes `nil`. Consumers append
  their own entries.
- **Costs:** a `def` whose name says registry and whose value is empty. Every
  consumer must remember to append, and a consumer that forgets gets an empty
  picker instead of a compile error.
- **Forbids:** nothing, which is the objection.
  [[docs/definitions/working-discipline]] and `docs/banks/module.md:50-56` both
  test an abstraction by what it constrains. This one constrains nothing and
  costs a name.

### Shape E: the registry becomes a manifest module

- **Form:** `all-pipelines` becomes an instance of E163's manifest kind, pure
  B-referent data with an empty port set, and the home question is answered by
  the manifest rule rather than by this row.
- **Costs:** E163 is `design` state (`docs/elements/ledger.md:305`) and its own
  row carries an OPEN CHOICE on whether `manifest` is a fourth axis value, a
  `(kind … (data))` claim, or a target-shaped form. `PS3` is blocked meanwhile.
- **Forbids:** nothing today, because nothing is built. Refused as the call, and
  recorded as the shape this row's answer should stay compatible with: Shape B
  puts the registry in one file as a plain data value, which is the shape E163
  would later name.

### Shape F: prapañca gets an exception for registry modules

- **Form:** [[decisions/decision-orchestration-boundary]] §4 gains a carve-out
  permitting a prapañca module to import a consumer when the import is a
  registry.
- **Costs:** the decision's stated purpose. `:127-129` reads "Prapañca knowing
  its callers. The engine importing a profile is the coupling this decision
  exists to name. `compose.chiral` is the one live instance." An exception fitted
  to the one live instance dissolves the rule.
- **Forbids:** requirement 1. Refused.

### What the tree already settles, and what it leaves open

The tree settles that Shape A is wrong and that a split happens. Three citations
converge:

1. `docs/banks/module.md:182-186`, shard 5: a split is real iff the two halves
   have different type. `all-pipelines : (List Pipeline)` is data with no arrow.
   The other six defs are pure arrows over lists handed in. Different type shape,
   so the split is real by the law.
2. `MAP.md:163`: source is placed by role. Six of the seven defs have the role
   of a generic pre-flight, and one has the role of a product registry.
3. `prog/prapanca/pipeline/plan.chiral:41-50`: the sibling spine module already
   answers this way, with the reason written down and cited to E140's FLAG.

What the tree leaves open is which of B and C carries the registry, because
`docs/elements/specs/S16-manas-compose-SPEC.md:473-478` justifies `all-pipelines`
only by analogy and the analogy does not say whether the registry must exist at
all.

## 5. The call

- **Chosen:** Shape B. The split is real by `docs/banks/module.md:182-186`, the
  role placement is forced by `MAP.md:163`, and the sibling precedent at
  `prog/prapanca/pipeline/plan.chiral:41-50` already runs it. B is preferred over
  C because requirement 2 asks the registry to have an owner with a written
  reason, and C answers by deleting the subject. B lands the registry beside
  `doc-refine-pipeline` at `prog/prapanca/profile/doc-refine.chiral:124`, which
  keeps the one-entry list and its one entry in one file, and carries both to
  `prog/samvada/doc-refine.chiral` under `PS3` with no separate move.

**The ruling, stated for the mint.**

1. `prog/prapanca/pipeline/compose.chiral` stays in prapañca. It holds no import
   of a module that moves.
2. `all-pipelines` is product data. It is defined in the file that defines its
   entries, `doc-refine.chiral`, and it travels with that file.
3. The republication at `:18` and half of `:19` ends. `prog/scriba/command-loop.chiral`
   imports what it uses.
4. The three accessors `compose.chiral` genuinely needs are `expert-by-id`,
   `expert-slot-of` and `config-id`. Their home is `PS2`'s, and this ruling
   requires only that the home be prapañca-side.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Does `compose.chiral` move to `prog/samvada/`? | RESOLVED, no | `docs/banks/module.md:50-56` individuates by type and `MAP.md:163` places by role. Six of seven defs are generic in both |
| 2 | Where does `all-pipelines` live? | RESOLVED | `prog/prapanca/profile/doc-refine.chiral`, beside `doc-refine-pipeline` `:124`, moving to `prog/samvada/doc-refine.chiral` with `PS3`. `docs/elements/specs/S16-manas-compose-SPEC.md:473-478` justified it as the analog of `all-profiles`, and `all-profiles` is in a file that moves |
| 3 | Where do `expert-by-id`, `expert-slot-of` and `config-id` live? | DEFERRED to `part-split/PS2` | `PS2` owns the accessor home. This row constrains it to a prapañca-side home and adds `config-id` at `prog/prapanca/profile/profiles.chiral:15` and `profile-by-id` at `:60` to the four its row already names |
| 4 | Does `prog/scriba/command-loop.chiral` import `samvada/doc-refine` and `samvada/profiles` directly? | DEFERRED to `part-split/PS6` | `PS6` rules scriba's import lines keep or cut. This row records that the count rises from 13 to 15 under the ruling, because `:18-19`'s republication ends |
| 5 | Does `prog/prapanca/pipeline/persist-test.prog` stay in prapañca? | DEFERRED to `part-split/PS5` | It reads `all-pipelines` and `all-profiles` at `:79` to round-trip a generic codec. Requirement 1's grep counts it. `PS5` owns the gate and the ungated-fixture census |
| 6 | Does `docs/elements/specs/S16-manas-compose-SPEC.md` D7 get amended? | RESOLVED, no amendment by this row | D7 ruled `all-pipelines` is a `def` and not a catalog row. That survives. Only its file changes, and `PS4` owns the 93 prose citations including this SPEC's paths |
| 7 | Does `prapanca/pipeline/compose` importing `prapanca/pipeline/plan` for the accessors satisfy the ruling? | RESOLVED, no | It makes a 71-line leaf depend on the 187-line spine for three one-line accessors, and `plan.chiral:41-45` states its copies are private and renamed against a collision. `PS2`'s shared home is the answer |

No NEEDS-AUTHOR. The one author-shaped question in this territory, whether
`chatter/` and `profile/` move now or trail
([[decisions/decision-orchestration-boundary]] `:154-157`), was ruled 2026-09-09
in favour of moving now, and this row assumes that ruling.

## 6. The mint packet

- **Elements:** one. The registry's home and the import cut are the same change:
  deleting `:18-19` is only sound once `:55`'s one product reference is gone, and
  moving `all-pipelines` is only sound once its callers have another way to name
  it. Two elements would each be unbuildable without the other.
- **Band:** `UNASSIGNED`. [[arcs/part-split-arc]] holds no reserved element block
  and author call B ruled 2026-09-06 that a band is advisory, so the mint takes
  the next number free tree-wide.
- **Catalog row:**
  `| E<NN> | **The compose seam: `all-pipelines` is product data and `compose.chiral` is not.** `prog/prapanca/pipeline/compose.chiral:18-19` is the one import [[decisions/decision-orchestration-boundary]] §4 measures as a violation, and its six generic defs against its one product registry are why. The registry moves to the file that defines its entries; the module stays generic and imports no module that moves | Not built. Measured 2026-09-10: 7 `def` over 71 lines, one naming a product value (`:55`); two of the six imported product symbols are dead in the file (`all-profiles`, `expert-pool`), reaching `prog/scriba/command-loop.chiral` only by the loader's flat name space (`lib/module/loader.chiral:145-147`) | `OURS` (`plan.chiral:41-50`'s private-accessor precedent; `docs/banks/module.md:182-186` shard 5; `MAP.md:163`) | SH |`
- **Ledger row:**
  `| E<NN> | manas-moe | design | The compose seam: `all-pipelines` defined beside `doc-refine-pipeline` and travelling with it; `compose.chiral:18-19` deleted; `prog/scriba/command-loop.chiral` importing what it uses | →part-split/PS3 | SH |`
- **Track:** `direct`. The tree settles the shape, by
  `docs/banks/module.md:182-186`, `MAP.md:163` and
  `prog/prapanca/pipeline/plan.chiral:41-50`. §4's Shapes A, C, D, E and F are
  each refused against a citation. The change is a two-line delete, a two-line
  add and five repaired call sites, and no SPEC would say more than §5 already
  says.
- **Size:** four files, roughly 20 lines net.

  | file | change | lines |
  |---|---|---|
  | `prog/prapanca/pipeline/compose.chiral` | delete `:18-19`, delete `:51-55`, repair the comment at `:57` that cites `profiles.chiral:60` | 7 deleted, 1 edited |
  | `prog/prapanca/profile/doc-refine.chiral` | add `all-pipelines` under `:124`, with the comment naming why it sits with its entry | 4 added |
  | `prog/scriba/command-loop.chiral` | add imports of `prapanca/profile/doc-refine` and `prapanca/profile/profiles` beside `:32`, with the comment saying what each carries | 2 added, 0 call sites moved |
  | `prog/prapanca/pipeline/persist-test.prog` | add an import of `prapanca/profile/doc-refine` at `:15` | 1 edited |

  Basis: the seven `def` and six imported symbols were counted at
  `prog/prapanca/pipeline/compose.chiral` on 2026-09-10; the five `all-pipelines`
  call sites are `prog/scriba/command-loop.chiral:1260`, `:1281`, `:1488`,
  `:1491` and `prog/prapanca/pipeline/persist-test.prog:79`, and none of them
  change text under Shape B because the name survives. `tools/test/samples/s16_compose.prog`
  needs no change: it imports both product modules directly at `:15-16` and uses
  `pipeline-slots` and `compose-preflight`, both of which stay.
- **Gate:** `tools/test/run-tests.sh` Phase 7 compiles every root under `lib` and
  `prog` carrying `(def compile-main` (`:172-177`), which covers
  `prog/scriba/scriba-main.prog` and `prog/prapanca/pipeline/persist-test.prog`.
  A grep over `prog/prapanca/pipeline/compose.chiral` for `prapanca/profile`
  returning zero is the direct observation.
- **Sequencing:** this element lands before `part-split/PS3`. Running `PS3` first
  turns `compose.chiral:18-19` into prapañca importing samvada, which is the
  violation the boundary decision exists to remove. It lands after or with
  `part-split/PS2`, which owes `compose.chiral` a prapañca-side home for
  `expert-by-id`, `expert-slot-of` and `config-id`.
- **Related:** [[arcs/part-split-arc]], [[decisions/decision-orchestration-boundary]],
  [[banks/module]], [[banks/profile]], [[goals/module-split]],
  `docs/elements/specs/S16-manas-compose-SPEC.md`, E133, E135, E140, E163.
