---
node: goals
layer: navigation
related: [index, arcs/README, records/README, status-ledger, open-edges]
status: current
updated: 2026-09-17
---

# Goals

Three tiers organise the work.

| tier | what it is | where it lives |
|---|---|---|
| goal | a broad thing this project claims it is doing | `docs/goals/` |
| arc | the work that serves one goal, with its requirements and roster | `docs/arcs/` |
| roster row | one unit of work, cited as `<arc>/<id>` before it has a number | the arc's roster, worked up in `docs/arcs/parts/` |
| element | one catalog item, an `E#` | `docs/elements/`, `docs/elements/catalog.md` |

A goal file says what the goal claims, cites where the project claims it, names
the arcs that serve it, and states what `done` means. An arc file names every
goal it serves.

**A goal states done as NUMBERED conditions, each checkable, each naming its arc
or saying it is unopened.** `ledger-lint` check AF fails a goal that does not.

**An element belongs to at least one arc, or the unspoken lens says nobody has
ruled on it.** That invariant was unsatisfiable while 48 unbuilt elements sat
orphaned; [[decisions/decision-four-lenses]] gave territory with no ruling a
home, and check AE now refuses only silence.

**An element whose components serve two goals sits in both arcs.** The author
ruled it on 2026-09-10 and `E44` is the case: totality belongs to
[[goals/enforcement]], and non-interference and tier weight belong to
[[goals/ownership-and-trust]]. Nothing here forces such an element to pick one.

**Minting is the last step of the design stage**, per
[[decisions/decision-design-before-mint]].

Every goal below is derived from text already in the repo. The citation is in
the goal file. A goal nobody has written down does not go here: it goes in the
arc's `goal` field as `UNWRITTEN`, and it is an author call.

## The goals

| goal | state | arcs |
|---|---|---|
| [[goals/self-hosting]] | held since 2026-08-05, maintained by the BUILD RULE | none open, and see Rules |
| [[goals/self-tooling]] | in flight | [[arcs/zero-python-arc]], [[arcs/text-tools-arc]] |
| [[goals/readable-surface]] | in flight | [[arcs/diagnostics-arc]], [[arcs/file-types-arc]], [[arcs/surface-syntax-arc]] |
| [[goals/presentability]] | in flight | [[arcs/baseline-alignment-arc]], [[arcs/presentability-arc]], [[arcs/binary-split-arc]] |
| [[goals/enforcement]] | in flight | [[arcs/enforcement-arc]], [[arcs/syscall-custody-arc]] |
| [[goals/independent-judgment]] | stated, unbuilt | [[arcs/independent-judgment-arc]] |
| [[goals/bridge]] | stated 2026-09-02, unbuilt | [[arcs/bridge-arc]] |
| [[goals/module-split]] | in flight, one measured miss | [[arcs/module-split-arc]], [[arcs/part-split-arc]] |
| [[goals/local-ai]] | stated 2026-09-01, unbuilt in this tree | [[arcs/transport-arc]], [[arcs/scriba-arc]], [[arcs/tuning-arc]], [[arcs/unit-lane-arc]], [[arcs/orchestration-engine-arc]], [[arcs/memory-discipline-arc]], [[arcs/runtime-loading-arc]] |
| [[goals/native-stack]] | in flight: all four conditions hold an arc | [[arcs/native-protocol-arc]], [[arcs/native-window-arc]], [[arcs/native-document-arc]] |
| [[goals/display]] | stated 2026-09-04, unbuilt: two arcs opened, three conditions unopened | [[arcs/display-calculus-arc]], [[arcs/terminal-arc]] |
| [[goals/own-web]] | stated 2026-09-05, unbuilt: three arcs opened, two conditions unopened | [[arcs/vocabulary-arc]], [[arcs/canvas-arc]], [[arcs/crypto-primitives-arc]] |
| [[goals/emitted-speed]] | stated 2026-09-08, unbuilt: one arc opened, four conditions unopened | [[arcs/emitted-speed-arc]] |
| [[goals/coding-agent]] | stated 2026-09-08, half built: two arcs opened, three conditions unopened | [[arcs/coding-turn-arc]], [[arcs/tool-authority-arc]] |
| [[goals/ownership-and-trust]] | deferred out of scope 2026-08-31 | [[arcs/ownership-and-trust-arc]], deferred with the track |
| [[goals/password-manager]] | stated 2026-09-23, unbuilt: five conditions, all unopened | none open, and see that goal's Arcs section |

`independent-judgment` carries an arc as of 2026-09-01 and still has no element.
`README.md` lists it under Honest limits, and
`docs/decisions/decision-self-verification.md` records the call. Its four rows
carry arc-local ids per [[decisions/decision-work-ids]], because the arc has no
reserved element block.

[[goals/presentability]] and [[goals/readable-surface]] are author calls rather
than derivations from existing text, and say so in their own first section.

[[goals/local-ai]] is an author call too, stated verbatim on 2026-09-01 and
says so in its own first section. Three of its arcs opened 2026-09-02 from
`.planning/LOCAL-AI-ARC-REALIGNMENT.md`, which also says which existing arcs
supply pieces without being re-pointed. Two rows in [[records/author-calls]]
still block work inside them: [[arcs/tuning-arc]] is blocked whole and
[[arcs/transport-arc]] can be worked as far as its first row. A fourth,
[[arcs/unit-lane-arc]], opened 2026-09-05 for condition 3, carrying the
roster `.planning/AI-LANE-GAP.md` drew from [[banks/unit]].

[[goals/bridge]] was opened 2026-09-02 and is a derivation rather than a new
ambition: [[thesis]] and [[category-bridge]] both call C "the part of Chirality
that is new work rather than borrowed", and no goal, arc or row stood against
it. Its arc has no reserved block, so its rows take arc-local ids.

[[goals/display]] was stated 2026-09-04 and is an author call, the fourth
after [[goals/presentability]], [[goals/readable-surface]] and
[[goals/local-ai]]. It says so in its own first section. Three of its five
done-conditions hold no arc file and stay conditions in the goal, so this
table lists the two arcs that exist. [[goals/native-stack]] condition 3 becomes
a consumer of it, and whether [[arcs/native-document-arc]] survives the overlap
is a row in [[records/author-calls]].

[[goals/module-split]] was opened 2026-09-02, also a derivation:
[[splitting-law]] and [[joining-law]] are standing rules with a decidable test
and nothing was scheduled against either. It is separate from
[[goals/readable-surface]] because that goal is the *surface*, its own done
clauses naming syntax, diagnostics and file kinds, and separate from
[[goals/presentability]] because that one is truth and outside-reader
orientation. This is how the source itself is cut.

[[goals/emitted-speed]] was opened 2026-09-08 and is a derivation:
[[benchmarks/OPTIMIZATIONS-TODO]] calls itself the resumption contract for a
campaign the author closed on 2026-08-02, [[benchmarks/language-performance]]
publishes its band as a standing claim, and [[goals/own-web]] condition 4
depends on a crypto floor that [[benchmarks/crypto-kernel-allocation]] measured
as violated on 2026-09-07. It is separate from [[goals/self-hosting]] because
that goal claims a fixpoint, which its conditions 1 to 3 hold by a standing
gate with no arc, and separate from [[goals/enforcement]] because that one
claims a check runs rather than what a compiled program costs.
[[arcs/emitted-speed-arc]] takes conditions 1 and 2, and four of the six stand
unopened. [[arcs/memory-discipline-arc]] holds the nearest
scheduled work, under [[goals/local-ai]] and against peak RSS, and the goal file
states the overlap.

[[goals/coding-agent]] was stated 2026-09-08 and is an author call, the fifth
after [[goals/presentability]], [[goals/readable-surface]], [[goals/local-ai]]
and [[goals/display]]. It says so in its own first section. It is separate from
[[goals/local-ai]] because that goal claims an orchestration engine and a
cockpit to drive it, and none of its four criteria names a codebase; this one
claims the thing that acts on one, which is tool use inside the type system,
filesystem reach, least-privilege over what a step may touch, and the routes and
keybinds that make it usable. The tree cuts them apart in code:
`prog/shilpa/turn.chiral` runs a tool-call turn and uses none of the engine, and
no file under `prog/prapanca/` reads the `tools` field it declares. Its arcs column
carries [[arcs/coding-turn-arc]], opened the same day against condition 1, and
[[arcs/tool-authority-arc]], opened 2026-09-09 against the same condition.
Conditions 2, 3 and 4 hold no arc, which is **not** the standing-gate shape
[[goals/self-hosting]] conditions 1 to 3 carry: no rule maintains them on every
change, and the goal's own first honest limit says the absence is scheduling
owed.

[[goals/password-manager]] was stated 2026-09-23 and is a derivation rather
than a new ambition: `docs/examples/E40-secret-custody.md:48` already gives
`E40` its reason for existing as *"a password manager that cannot leak its
vault"*, `prog/demo/passman-min.chiral` ships 32 lines of it, and
`docs/decisions/decision-deployment-custody.md:29` rules the architecture as
per-instance custody with `derive-not-store`. Four standing goals were tested
against it and none reaches it. [[goals/ownership-and-trust]] holds the
re-bootstrap climb, DDC, the secure datum model, the register root and the
cascade, and its four conditions name quorum legs, the golden object, the
reference semantics and a shipped artifact's re-derivation. [[goals/self-tooling]]
claims the replacement of `tools/`, and a vault replaces no Python tool.
[[goals/own-web]] claims one design language and one native surface, and its
condition 4 supplies the crypto this goal consumes without claiming the consumer.
[[goals/native-stack]] comes closest, and its condition 4 store splits a value
t of n by Shamir so nothing authoritative sits whole in one place, which is the
opposite shape to one holder with a derived key. Its arcs column reads
`none open` and that is the scheduling hole rather than the standing-gate shape:
no rule maintains any of its five conditions, and the goal's own Arcs section
says so.

[[goals/ownership-and-trust]] carries an arc as of 2026-09-02 and every row in
it is deferred. The arc holds three minted elements, `E53`, `E71` and `E72`,
that were sitting in the goal file. A deferred goal keeps its arc unscheduled,
and the arc says so in its own resume state.

## Rules

- A goal file carries a dated summary of where its goal stands, in `## State`,
  and of what still falls short, in `## Honest limits`. It carries no element or arc
  rows. [[status-ledger]] is the authority for what is built on the four rungs
  and [[records/README]] for a claim beside its measurement, so a summary that
  disagrees with either is a defect in the summary.
- Adding a goal means citing where the project already claims it. Authoring a
  new ambition is an author call.
- Changing what a goal claims changes what its arcs are for, so it is a decision
  and belongs in `docs/decisions/` first.
- **A condition held by a standing gate carries no arc, and that is its
  finished shape.** An arc schedules work toward a condition that is open. Where
  a rule that already runs maintains it on every change, there is no work to
  schedule and an arc would be an empty file. [[goals/self-hosting]] conditions
  1 to 3 are the case: the BUILD RULE in [[working-discipline]] holds them on
  every change whose deliverable enters the compiler's import closure. That
  goal's conditions 4 and 5 are open and both name [[arcs/sys-face-arc]]. Its
  goal file names the gates, its first condition records that no suite phase
  runs the fixpoint compare, and its honest limits say what a fixpoint does not
  prove. A goal carrying such a condition says `none open` in the table above:
  `ledger-lint` check V reads that as the recorded reason for a goal no arc
  serves, and check AF reads it as the reason a condition there names no arc. A
  goal with neither an arc nor a gate is a hole and check V fails it.
