---
node: decision-design-before-mint
layer: decision
related: [arcs/README, goals/README, elements/README, working-discipline, decision-work-ids, decision-lane-split, decision-dispatch-cadence, decision-ai-tier, index]
status: settled
updated: 2026-09-05
---

# Decision: minting is the graduation, and design happens before it

**Settled 2026-09-05 by author directive.** Five calls, taken in session.

## The problem

Minting an element is the first act of work in this tree and it should be the
last. `pack.py E<#> <slug>` slices the element's row out of
`docs/elements/catalog.md`, so the row has to exist before the run starts. A
catalog row carries title, external reference, reference class, rationale,
category, module and track. All seven are demanded at the moment least is
known.

Four more defects follow from the same shape.

**The pipeline's first stage asks the wrong questions.** `worked-example` writes
six sections and three of them are a pitch. §3 demands a conventional
other-language approach for every element, and E184, E187 and E188 have no
conventional counterpart, so the slot gets filled with something invented. §4
asks the run to say what chirality makes impossible, which is a superiority
claim demanded on schedule in a tree whose cardinal working error is naming a
phantom feature. §5 asks for a fleshed snippet in real surface syntax before
anything has been measured: the baseline sits in the *following* artifact, SPEC
§2, so the answer is written and the next run then discovers what was already
built.

**The SPEC carries two jobs.** Its §2 baseline and §3 decisions are design. Its
§4 change plan and §5 conformance gate are the build. One audit gates both, so a
design defect and a plan defect are graded together.

**Goals and arcs have no producing process.** All 33 files were written by hand.
Section shapes vary from four to nine and the recurring headings appear in some
files and not others. `ledger-lint` check V reads the `goal:` and reserved-block
fields and nothing else, so detail is optional because nothing asks for it.

**Nothing reconsiders a settled artifact.** `docs/examples/INDEX.md` defines
`needs-rework` and no run produces it. `superseded` is reachable from any state
and is written by hand. Five `FINDING-*.md` files sit in `.planning/` with no
destination. E20's INDEX row carries a dated 2026-09-05 finding inside its
Status cell, recorded there as a disagreement left in place. New information
arrives and the only moves are a fresh pipeline run or a hand edit.

## What the tree already does

Three pieces of the answer are already here and none of them is formalised.

[[decisions/decision-work-ids]] settled on 2026-09-01 that an arc names its work
before the work has a number. A row carries `id`, `title`, `state` and
`element`, the id is arc-local and stable, and promotion assigns an `E#` while
the local id survives. Fourteen of the twenty-two arcs use it. Nothing produces
those rows and no stage works one up.

[[arcs/unit-lane-arc]] is the most detailed arc in the tree and its detail was
not authored in the arc file. `.planning/AI-LANE-GAP.md` holds 341 lines: a
layer graph, an edge table naming the two edges that run against the numbering,
a 43-row roster with layer, kind and origin columns, and a size estimate. Two of
its rows then minted as E196 and E197. That file is the missing stage, written
once by hand, in the tier a reader never opens.

The same arc holds the only reconsideration on record. E197's spec audit
measured that the roster under-reported what E197 builds, `unit-lane/N43` was
opened after the note, and the arc wrote a paragraph saying why. It worked, and
no process describes it.

## The pipeline

```
goal        docs/goals/<name>.md
arc         docs/arcs/<name>-arc.md
design      docs/arcs/parts/<arc>-<id>.md
audit       gates the design
MINT        docs/elements/catalog.md + ledger.md + the arc row
spec        docs/elements/specs/E<NN>-<slug>-SPEC.md
audit       gates the spec
implement   lib/, prog/, a gate

revisit     any artifact above, against one named trigger
```

Cadence is unchanged and [[decisions/decision-dispatch-cadence]] still governs
it: serial, one stage and one agent at a time.

The build rule's own test is unchanged too. A row runs the pipeline iff
building it requires choosing between shapes the codebase does not already
settle. The design stage now carries that test explicitly, in its §4: where the
tree settles the shape, the run says so and the row closes without minting.

## The five calls

### 1. Pre-mint work lands at `docs/arcs/parts/<arc>-<id>.md`

One file per roster row, scaffolded, beside the arc that owns it. It is cited as
`text-tools/P2` before any `E#` exists and the file survives the promotion under
the same name. The arc file stays a roster.

The alternative was a `###` block per row inside the arc file, which is what
[[arcs/diagnostics-arc]] and [[arcs/enforcement-arc]] already do. Those two are
247 and 633 lines, and that is the reason.

### 2. The seam falls at the mint line

Design is pre-mint and holds the research, the measured baseline, the delta, the
candidate shapes and the call. SPEC is post-mint and holds the change plan and
the conformance gate.

This is what makes minting a graduation. The design's §6 states the catalog row
and the ledger row the element would take, so the mint step writes what the
design produced.

### 3. `worked-example` is cut and the corpus folds into `docs/implementation/`

No further worked example is written. The 132 files in `docs/examples/` describe
elements that were built, which is the role `MAP.md` gives
`docs/implementation/`: the source tree described, as distinct from specified.
They move there unrewritten. Rewriting them to a formula that did not exist when
they were written would be narrating the edit, which [[protocol/tone]] forbids.

The conventional-language contrast survives as at most a line inside the design
§4, where another language is the source of a candidate shape. It gets no
section.

**Consequence: `docs/examples/INDEX.md` loses its home, so the roster carries
pipeline state.** [[decisions/decision-work-ids]] already gives a roster row a
`state` field, and the states are the pipeline's own. [[status-ledger]] stays
the authority for build state on the four rungs and this changes nothing about
it. The two were always different measurements and INDEX was the only place they
sat side by side.

### 4. `pack.py` grows the new stages

One tool, one bundle discipline, one place the stage table lives. The bundle
stays the agent's whole input, which is what makes a run cheap.

| command | does |
|---|---|
| `pack.py --goal <name>` | goal bundle, scaffolds `docs/goals/<name>.md` |
| `pack.py --arc <name>` | arc bundle, scaffolds `docs/arcs/<name>-arc.md` |
| `pack.py <arc>/<id>` | design bundle, scaffolds `docs/arcs/parts/<arc>-<id>.md` |
| `pack.py <arc>/<id> --audit design` | the design gate's bundle |
| `pack.py <arc>/<id> --mint` | allocates the `E#`, writes the catalog and ledger rows |
| `pack.py E<#> --spec` | unchanged |
| `pack.py E<#> --audit spec` | unchanged |
| `pack.py <target> --revisit <trigger>` | the revisit bundle, artifact beside its delta |

Minting runs on the design audit's PASS, where `--mark reviewed` runs today.
That is what puts the graduation behind a gate.

### 5. Revisit is a stage with its own skill

It takes one artifact and one named trigger, and it never re-derives the
artifact. The trigger is cited: a measurement, a decision, a sibling row built,
an author call, a finding.

| verdict | means | writes |
|---|---|---|
| HOLDS | the trigger changes nothing | a dated check line |
| AMEND | right shape, wrong detail | the fix in place, dated |
| RESCOPE | the row's boundary moved | the roster row, and a split where the work divides |
| REOPEN | the stage is invalidated | the row's state drops back one named stage |
| SUPERSEDE | the row stops being what gets built | the successor. An author call |

An audit gates a fresh artifact against a charter. A revisit re-tests a settled
one against a delta. Different input, different verdicts, different write
surface, so it is a separate skill. Folding a third job into one skill is the
defect this decision names in `worked-example`.

`needs-rework` gets a producer: it is what REOPEN writes. `SUPERSEDE` keeps the
hand-written successor, and it now has a run that reaches the question.

## The skills

| skill | turns | writes |
|---|---|---|
| `goal-open` | an author's stated ambition, or a derivation from repo text, into one goal | `docs/goals/<name>.md` |
| `arc-open` | one goal condition into one arc: requirements and a roster | `docs/arcs/<name>-arc.md` |
| `element-design` | one roster row into a design | `docs/arcs/parts/<arc>-<id>.md` |
| `pipeline-audit` | gates a design before minting, and a SPEC before implementing | the artifact under audit |
| `design-to-spec` | one minted element into an implementation SPEC | `docs/elements/specs/E<NN>-<slug>-SPEC.md` |
| `revisit` | one artifact against one trigger | the artifact, or its roster row |
| `doc-audit` | one doc, semantic pass against its live authorities | the doc under audit |

`worked-example` and `example-to-spec` are retired. `design-to-spec` is
`example-to-spec` repointed at a minted element and cut to the build half.

## What this costs

The 132-file corpus move touches every `[[links]]` pointer aimed at
`docs/examples/`, and `docs/examples/INDEX.md` is cited by `pack.py`,
`ledger-lint`, three skills and a count of docs measured at migration time. That
migration is the largest single piece of this decision and it is mechanical.

Neither `pack.py` nor `ledger-lint` knows any of the new forms on the day this
is settled. Until they do, a design run is a hand-written scaffold and no check
reads a roster row's state.
