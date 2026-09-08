# Workflow

The pipeline, end to end. `docs/definitions/working-discipline.md` holds the
rule and `docs/decisions/decision-design-before-mint.md` settles the shape; this
holds the run.

## The tiers and the stages

```
goal        docs/goals/<name>.md                      goal-open
arc         docs/arcs/<name>-arc.md                   arc-open
─────────────────────────────────────────────────── pre-mint, no E# exists ──
translate   docs/translations/<object>.md              translate
audit       the translation                           pipeline-audit TRANSLATE
design      docs/arcs/parts/<arc>-<id>.md             element-design
audit       the design                                pipeline-audit
MINT        catalog + ledger + the roster row         the audit's PASS
─────────────────────────────────────────────────── post-mint ──────────────
spec        docs/elements/specs/E<NN>-<slug>-SPEC.md  design-to-spec
audit       the SPEC                                  pipeline-audit
implement   lib/, prog/, a gate                       no skill. See below
─────────────────────────────────────────────────────────────────────────────
revisit     any artifact above, against one trigger   revisit
```

**A translation runs only where the reference class is a published external
object**, and it is upstream of a roster row: an object can be translated before
anyone decides which row builds it. `docs/translations/README.md` holds the nine
sections and `tools/xlat/xlat.sh` pins the sources every quote resolves into.

**Minting is the graduation.** A unit of work is named in the arc's roster when
the arc opens, cited as `<arc>/<id>` per
`docs/decisions/decision-work-ids.md`, worked up in `parts/`, and given an `E#`
only when its design audit passes. The arc-local id never changes, so a citation
made before the number existed survives it.

## When the pipeline applies

Run it for a row **iff building it requires choosing between shapes the codebase
does not already settle.** The design's §4 is where that is decided: where the
tree settles the shape, §4 says so with the citation, §6 marks the row `direct`,
and the row mints and goes to implement with no SPEC. The defect is the
blueprint.

The design stage itself always runs. It is what measures the baseline, and its
§3 can find an empty delta and close the row without minting anything. That
outcome is a success: minting an element to build what exists is the failure it
prevents.

## The commands

| stage | command | writes | flip |
|---|---|---|---|
| goal | `pack.py --goal <name>` | `docs/goals/<name>.md` | the `goals/README.md` row |
| arc | `pack.py --arc <name>` | `docs/arcs/<name>-arc.md` | the `arcs/README.md` row |
| design | `pack.py <arc>/<id>` | `docs/arcs/parts/<arc>-<id>.md` | roster `state: designed` |
| audit | `pack.py <arc>/<id> --audit design` | the design, in place | `--mint` on PASS |
| spec | `pack.py E<#> --spec` | `docs/elements/specs/E<NN>-<slug>-SPEC.md` | roster `state: specced` |
| audit | `pack.py E<#> --audit spec` | the SPEC, in place | `--mark audited` on PASS |
| implement | none. See below | `lib/`, `prog/`, a gate | the roster row, by hand |
| revisit | `pack.py <target> --revisit <trigger>` | the artifact, and a `records/` row | per verdict |

Every bundle is the complete input for its stage. Read it, and grep only for a
specific fact it leaves out.

**Each skill is one run, one unit of work, one artifact, then stop.** Rolling
from a stage into the next inside a single run is the failure each skill exists
to prevent.

## The audit verdicts

| verdict | means | action |
|---|---|---|
| PASS | no blocking FLAG | run the flip. At design level the flip is the mint |
| CLOSED | design level: §3 found an empty delta | verify the shards cover it, set the roster row to `closed`, mint nothing |
| BLOCKED | at least one author-tier FLAG | do not flip. Report the questions verbatim; the answers feed a re-audit |
| REFUSED | the artifact carries `status: superseded` | `pack.py` stops before bundling. Report the successor |

An audit fixes what is decidable from its bundle: a wrong rung, a stale
citation, illegal syntax, arithmetic. It flags what is author-tier: genuine
values, taste, scope. A flag never gets resolved inside a fix.

## The revisit stage

An audit gates an artifact that has just been written. A **revisit** re-tests a
**settled** artifact against one named trigger: a measurement, a decision that
landed after it, a sibling row built, an author call answered, a finding, or a
`records/` row whose `checked:` date predates the last change to the files it
cites.

It reads the trigger before the artifact, and it never re-derives the artifact.
The verdict comes from a closed set: HOLDS, AMEND, RESCOPE, REOPEN, SUPERSEDE.
Every run writes a `records/<arc>.md` row in the six-field format, including a
HOLDS, because a check that leaves no trace gets redone.

If more than the trigger's reach is wrong, the verdict is REOPEN and the owning
stage re-runs. SUPERSEDE is surfaced and left for the author.

## The implement stage

No skill covers it, because it is ordinary work under the build rule.

**If the change touches `lib/` or `prog/`, it is compiler source and owes the
rebuild.** A comment-only edit counts.

`docs/definitions/working-discipline.md` carries the recipe and it is the only
copy: `build-new`, then test, then promote, nothing replacing itself in place,
generations built from the same blob until two consecutive ones are
byte-identical, a non-empty check before every `cmp`, and a stop at `C4`. **A
change that touched emission puts the first agreement at `C2 == C3`, so `C1 !=
C2` on its own reports a correct build** (E188, `032681f`). A fixpoint shows
stability and says nothing about correctness: a compiler reproducing itself byte
for byte is consistent with being wrong the same way twice.

Everything outside the compiler runs with `chirality run FILE`.

**The gate.** `tools/test/run-tests.sh` is the floor, and a green line is a
named phase there. The suite prints its unported phases by name and reason on
every run. A gate is sound when it has a mutant that is actually run: a check
aimed at a guess passes by looking at nothing.

**On the way out.** Set the roster row's `state` to `built` with the date and
what was measured. Put the build-state change in
`docs/definitions/status-ledger.md` on the rung it reached. If the run turned up
a gap between a document's claim and the tree, that is a row in `records/`, six
fields, with the row or element that owns the fix.

## The doc tier has its own loop

`doc-audit` is the sibling pipeline for documents.

```
python3 tools/ledger-lint/ledger-lint.py     # layer 1, the mechanical worklist
python3 tools/doc/doc.py audit <node>        # layer 2, one doc's semantic bundle
```

Run the lint first. If it is clean and the ask was to check the docs, say so and
stop. Inventing semantic work on a clean lint is its own defect. The fix
direction is fixed: `lib/` and `prog/` source with its tests sit above the
roster state and `records/conformance-map.md`, which sit above the decision
docs, which sit above a bank, which sits above a thin note. A doc is corrected
toward what is above it. When two authorities above it disagree, flag both
verbatim.

## Cadence

Serial. One stage at a time, one agent at a time.
`docs/decisions/decision-dispatch-cadence.md` is the authority, it overrides
every parallel-waves protocol written anywhere in this tree, and
`protocol/dispatch.md` is how a session runs a queue under it.
