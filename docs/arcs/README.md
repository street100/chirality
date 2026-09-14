---
node: arcs
layer: navigation
related: [goals/README, index, records/README, status-ledger, elements/README]
status: current
updated: 2026-09-05
---

# Arcs

An arc is the list of elements to be done for one goal. It carries the
requirements that must hold before the arc is done, and it carries its own
resume state, so a session starts from the arc file and needs nothing at root.

These files are TRACKED. `.planning/` is tracked too, since 2026-09-01
(`docs/decisions/decision-ai-tier.md`); the `.gitignore` header states the rule
and keeps out only the machine state Claude Code writes for itself. **The
exclusion that made this paragraph necessary is closed.** What survives it is
the reason an element fact lives here: two sessions minted `E173` independently
and nothing caught it until a merge put both INDEX rows side by side.
`records/baseline-alignment.md` BA-44 holds the measurement.

## The three tiers

| tier | unit | home |
|---|---|---|
| goal | a broad thing this project claims it is doing | `docs/goals/` |
| arc | elements assembled toward one goal, with requirements | `docs/arcs/` |
| element | one catalog item, an `E#` | `docs/elements/`, `docs/elements/catalog.md` |

An arc names every goal it serves, and a goal is served by every arc that names
it. The relation is many to many: one arc can supply two goals at once, and one
goal can take work from several arcs. Where no goal is written down, the arc's
`goal` field says `UNWRITTEN` and the arc stays open on an author call.
Authoring a goal the project has never stated is forbidden.

## What an arc file carries

Six sections, in order. `arc-open` scaffolds them and
`docs/decisions/decision-design-before-mint.md` settles the shape.

1. **The header fields.** `goals:` every goal it serves, or `UNWRITTEN`. The
   singular `goal:` is the same field and is what the arcs written before the
   relation opened up still spell. Beside it: the reserved element block or the
   arc-local id scheme, the build-state authority, and the `records/` checklist
   where one exists.
2. **Why this arc exists.** The goal condition, quoted, and what it takes to
   hold.
3. **What the tree already holds.** Measured, bank first, cited at `file:line`
   with the ledger rung. `docs/banks/INDEX.md` holds twelve banks and a feature
   that is one thing elsewhere is here a sum of shards, usually mostly built.
4. **What is missing, and its structure.** The groups in dependency order, and
   **the edges that run against that order**. An ordering with no stated
   back-edges reads as a build sequence, and reading it that way is usually
   wrong. `.planning/AI-LANE-GAP.md` names two such edges over eight layers.
5. **REQUIREMENTS.** Numbered, six or fewer, each one checkable with the
   observation stated beside it. A requirement with no way to observe it is a
   wish.
6. **The roster**, below, and then the resume state: where a session picks up,
   what blocks it, what was measured.

### The roster

One row per unit of work. Ids are arc-local and stable per
[[decisions/decision-work-ids]], and **the id never changes when the row mints**,
so a citation made before the number existed survives it.

| column | holds |
|---|---|
| `row` | `<arc>/<id>`, the citable name |
| `what` | one line, specific enough that two people would build the same thing |
| `group` | which group of §4 |
| `kind` | `primitive` · `law` · `port` · `decision` · `tool` |
| `origin` | `new` · `bind` (it exists and needs a surface) · `connect` (two built things need joining) · `pair` (a primitive and the consumer that exercises it, both named in `what`, both cited, per [[decisions/decision-primitive-with-consumer]]) |
| `req` | the numbered §5 requirements this row serves |
| `state` | `open` · `designed` · `minted` · `specced` · `building` · `built` · `direct` · `closed` |

`direct` is terminal and carries no design or SPEC. [[working-discipline]] runs
the pipeline for a row iff building it requires choosing between shapes the
codebase does not already settle, so a forced shape is its own blueprint.
`zero-python/Z5` is the case: file write is a syscall crossing the kernel ABI
fixes.
| `element` | the `E#` once minted, or `unminted` |

**The `state` column is the pipeline's authority for a row.** Build state on the
four rungs stays with [[status-ledger]], which measures a different thing. The
two sat side by side in `docs/examples/INDEX.md` until
[[decisions/decision-design-before-mint]] closed that corpus; the INDEX rows
survive for the elements built under the old pipeline.

### The coverage check

An arc states it before its resume state, and it is what keeps an arc from being
thin:

- every requirement in §5 is named by at least one row's `req`. A requirement no
  row serves is unscheduled;
- every row names at least one requirement. A row serving none is out of scope,
  or §5 is missing one;
- every row's `origin` is defensible from §3. A row marked `new` whose work §3
  shows already built is the phantom-feature error, caught here rather than four
  stages later. A `pair` row is defensible when §3 measures the absence of the
  primitive **and** names the consumer that wants it, per
  [[decisions/decision-primitive-with-consumer]].

### `parts/`

`docs/arcs/parts/<arc>-<id>.md` holds one roster row worked up: the obligation,
what the tree holds, the delta, the candidate shapes, the call, and the mint
packet. It is written by `element-design` before the row has an element number,
gated by `pipeline-audit`, and the gate's PASS is what mints. The file keeps its
arc-local name after the promotion.

An arc may keep a second file, `records/<arc>-record.md`, holding the measured
history: what landed, the traps that fired, the decisions that each cost a
measurement. The arc file is rewritten as work moves. The record is appended and
not rewound. That split is why [[records/diagnostics-arc-record]] exists as its
own file.

Records live in `records/` at the root, not under `docs/`. `docs/` is the tier a
reader is handed; `records/` is what we measured about ourselves. Keeping the
audit residue out of the reader's path is a requirement of
[[goals/presentability]].

## Naming

`docs/arcs/<arc>-arc.md`, slug-cased, link by `[[arcs/<arc>-arc]]`. The `-arc`
suffix is kept even though the directory says it, because two arc files carry
that basename in pointers outside this directory and because `records/` holds a
same-stem file for two of these arcs.

## Element numbers

Do not mint a number that does not exist. `docs/decisions/decision-lane-split.md` reserves `E184-E189` for
Lane A, `E190-E195` for Lane B, and `E196-E239` for the unit lane since
2026-09-05. `CLAUDE.md`'s deferral rule forbids naming an
element that has never been minted, and a deferral to a nonexistent element is a
phantom dependency.

An arc with no reserved block writes `UNASSIGNED` in the `element:` field of
anything owed a number, and carries its work as arc-local rows meanwhile.
`docs/decisions/decision-work-ids.md` settled that on 2026-09-01, replacing the
earlier rule that such an arc writes `UNASSIGNED` and stops. An arc-local id
claims identification and claims no place in a band, a catalog row, a ledger row
or a pipeline stage, so the deferral rule keeps its whole force over `E#`.

**Minting is the end of the design stage.** A row is named in the roster when
the arc opens, worked up in `parts/`, and given an `E#` only when its design
audit passes. `docs/decisions/decision-design-before-mint.md` settled that on
2026-09-05, and the reason is that a catalog row demands title, reference,
reference class, rationale, category, module and track at the moment least is
known.

The roster is the tracked collision detector. A number minted twice shows up as
two rows claiming it.

## The arcs

Each row's goal is the arc's own `goal:` field, and `ledger-lint` check V fails
when this table and an arc file disagree.

| arc | goal | state | reserved block |
|---|---|---|---|
| [[arcs/diagnostics-arc]] | [[goals/readable-surface]] | 5 built, 4 open | `E184-E189` shared with enforcement |
| [[arcs/enforcement-arc]] | [[goals/enforcement]] | 5 rows: E16 on the live path with its check unrun, E17/E18 built and unadopted, E70/E184 design | `E184-E189` |
| [[arcs/file-types-arc]] | [[goals/readable-surface]] | 0 of 4 built | `E190-E195` |
| [[arcs/text-tools-arc]] | [[goals/self-tooling]] | 1 of 4 primitives minted | none |
| [[arcs/zero-python-arc]] | [[goals/self-tooling]] | 0 of 14 `.py` files removed | none |
| [[arcs/baseline-alignment-arc]] | [[goals/presentability]] | 44 rows on 2026-09-04: 4 FIXED, 6 ACCEPTED, 34 open | none |
| [[arcs/presentability-arc]] | [[goals/presentability]] | 3 rows, none started | none |
| [[arcs/binary-split-arc]] | [[goals/presentability]] | 5 rows, none started | none |
| [[arcs/independent-judgment-arc]] | [[goals/independent-judgment]] | 5 rows, none started | none |
| [[arcs/bridge-arc]] | [[goals/bridge]] | 5 rows, C4 holds E40/E56 | none |
| [[arcs/module-split-arc]] | [[goals/module-split]] | 4 rows, none started | none |
| [[arcs/transport-arc]] | [[goals/local-ai]] | 4 rows, all four done 2026-09-02 and gated by Phase 20 | none |
| [[arcs/scriba-arc]] | [[goals/local-ai]] | 6 rows, `S18` built and five open | the `S` namespace |
| [[arcs/tuning-arc]] | [[goals/local-ai]] | opened blocked, no row written | none |
| [[arcs/ownership-and-trust-arc]] | [[goals/ownership-and-trust]] | 3 rows, all deferred by author call | none |
| [[arcs/native-protocol-arc]] | [[goals/native-stack]] | 9 rows: N1 slices 1 and 2 built, N7 example audited | the `N` namespace |
| [[arcs/native-window-arc]] | [[goals/native-stack]] | 4 rows, none started | none |
| [[arcs/native-document-arc]] | [[goals/native-stack]] | 4 rows, none started | none |
| [[arcs/display-calculus-arc]] | [[goals/display]] | 17 rows, none started | none |
| [[arcs/unit-lane-arc]] | [[goals/local-ai]] | 43 rows: `E196` and `E197` both built 2026-09-05, closing N8, N9, N10 and N43, 39 open | `E196-E239` |
| [[arcs/vocabulary-arc]] | [[goals/own-web]] | 12 rows, none started. `F3`'s shard is built and unmeasured | none |
| [[arcs/canvas-arc]] | [[goals/own-web]] | 16 rows, none started. Follows the vocabulary arc | none |
| [[arcs/crypto-primitives-arc]] | [[goals/own-web]] | 25 rows, none started. Opened 2026-09-07 on condition 4. Takes the layers `.planning/CRYPTO-MODEL.md` §2 marks `unscoped`, plus the translation and representation machinery. `native-protocol/N10` overlaps and the boundary is an author call | none |
| [[arcs/memory-discipline-arc]] | [[goals/local-ai]] | 7 rows, `E81` built and six open | `E81-E85`, minted |
| [[arcs/coding-turn-arc]] | [[goals/coding-agent]] | 13 rows after the 2026-09-09 rescope, A1 designed and its design owed a revisit. Opened 2026-09-08 on condition 1, orchestration. Takes the tool as a value, the `Expert.tools` grant read at both altitudes, a `Flow` node that fires a tool, the manifest, `overflow-guard`'s first caller, and the gate [[goals/coding-agent]] records as held by no row. Rows spell the letter `A`. Conditions 2, 3 and 4 stay unopened, and one author call is owed on whether requirement 5 gates the arc | none |
| [[arcs/emitted-speed-arc]] | [[goals/emitted-speed]] | 9 rows, none started. Opened 2026-09-08 on conditions 1 and 2, amended the same day to take condition 6 after a measurement voided its own exclusion of bucket C. Takes construction and leaves residency to [[arcs/memory-discipline-arc]] at the `Alloc` seam. Conditions 3, 4 and 5 stay unopened, and condition 4's budget and condition 6's instruction-set baseline are owed author calls | none |
| [[arcs/tool-authority-arc]] | [[goals/coding-agent]] | 12 rows, none started. Opened 2026-09-09 on condition 1's second half, the grant, beside [[arcs/coding-turn-arc]] which holds the first half. Takes the naming boundary whole (`openat` and `raw-proc-spawn` are declared outside `lib/ports/`), the inheritance default each crossing opens with, `sock-send-fd`'s missing routing line, a spawn whose child holds what it was handed, and the ask as a value citing `E43`. Rows spell `TA`. Three author calls from [[decisions/decision-tool-capability]] are open and carried on the rows they govern | none |
| [[arcs/part-split-arc]] | [[goals/module-split]] | 6 rows, none started. Opened 2026-09-09 on condition 1 at tier weight, beside [[arcs/module-split-arc]] which holds the same condition at file granularity. Schedules the move [[decisions/decision-part-layout]] §6 named and did not perform: `prog/prapanca/chatter/` plus `prog/prapanca/profile/` become `prog/samvada/`. Three rows are mechanical (27 files, 86 import lines, 93 prose citations, Phase 7 as the gate) and three are design (`compose.chiral`'s home, the stranded `Expert` accessors, scriba's cross-prog dependency). Rows spell `PS` | none |
| [[arcs/terminal-arc]] | [[goals/display]] | 9 rows, none started. Opened 2026-09-10 because `E128`, the APC handshake, sat under no arc and the homing triage could place it nowhere. Row ids are `TM1`-`TM9`: `T` was already spelled by `transport`, `zero-python` and `diagnostics`. Only the negotiation half serves a stated condition; the pty lifecycle, the line discipline and the emulator serve none, which the arc carries as its first FLAG | none |
| [[arcs/orchestration-engine-arc]] | [[goals/local-ai]] | 18 rows: 12 built, `E142` and `E143` minted and unbuilt, 4 unminted. Opened 2026-09-14 on condition 1 from the `orchestration-engine` proposal in [[records/homing-triage]], homing the fourteen engine elements no roster held. Takes the prapañca engine itself: [[arcs/transport-arc]] holds reachability, [[arcs/unit-lane-arc]] the model of computation beneath it, [[arcs/part-split-arc]] the file move and [[arcs/coding-turn-arc]] the manifest's consumer. Rows spell `OE`, two letters because a single `E` collides with the element numbers fourteen rows carry | none |

Four of the twenty hold a reserved `E` band, [[arcs/scriba-arc]] holds the
`S` namespace and [[arcs/native-protocol-arc]] holds the `N` namespace.
[[arcs/unit-lane-arc]] holds a band and still spells its own rows with the
same `N` letter, arc-local. The other fourteen cannot mint an element today,
and
`docs/decisions/decision-work-ids.md` settles the arc-local row id that lets
them name their work anyway. Every one of the fourteen spells its scheme in its own
`reserved element block:` field, and `ledger-lint` check V fails an arc that
holds neither a band nor a scheme.

A goal with no arc is a different shape and `docs/goals/README.md` states when
it is legitimate.
