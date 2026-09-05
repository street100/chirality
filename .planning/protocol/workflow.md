# Workflow

The element pipeline, end to end. `docs/definitions/working-discipline.md` holds
the rule; this holds the run.

## When the pipeline applies

Run it for an element **iff implementing it requires choosing between shapes the
codebase does not already settle.** A bug-class fix whose shape is forced by the
defect skips it, because the defect is the blueprint. When in doubt, run it: the
pipeline is one cheap turn and a wrong shape is expensive.

## The five stages

```
example  ->  audit  ->  spec  ->  audit  ->  implement
drafted     reviewed   specced   audited    implemented
```

The status chain lives in one place, the Status section of
`docs/examples/INDEX.md`. `superseded` is the chain's one exit, reachable from
any state, and it names a successor element in a `superseded_by:` field. That is
an author's call and is set by hand.

| stage | command | writes | flip |
|---|---|---|---|
| example | `pack.py E<#> <slug>` | `docs/examples/E<NN>-<slug>.md` | scaffolds the row at `drafted` |
| audit | `pack.py E<#> --audit example` | the example, in place | `--mark reviewed` on PASS |
| spec | `pack.py E<#> --spec` | `docs/elements/specs/E<NN>-<slug>-SPEC.md` | scaffolds and flips to `specced` |
| audit | `pack.py E<#> --audit spec` | the SPEC, in place | `--mark audited` on PASS |
| implement | none. See below | `lib/`, `prog/`, a gate | the row, by hand |

`pack.py E<#> --audit` with no level audits the furthest artifact. Every bundle
is the complete input for its stage: read it and grep only for a specific fact
it leaves out.

Each of the four skills is one run, one element, one artifact, then stop.
Rolling from a stage into the next one inside a single run is the failure each
skill exists to prevent.

## The audit verdicts

| verdict | means | action |
|---|---|---|
| PASS | no blocking FLAG | run the `--mark` flip |
| BLOCKED | at least one author-tier FLAG | do not mark. Report the questions verbatim; the answers feed a re-audit |
| REFUSED | the artifacts carry `status: superseded` | `pack.py` stops before bundling. Report the successor |

An audit fixes what is decidable from its bundle: a wrong build-state, a stale
citation, illegal syntax, arithmetic. It flags what is author-tier: genuine
values, taste, scope. A flag never gets resolved inside a fix.

## The implement stage

No skill covers it, because it is ordinary work under the build rule.

**If the change touches `lib/` or `prog/`, it is compiler source and owes the
rebuild.** A comment-only edit counts.

`docs/definitions/working-discipline.md` carries the recipe, and it is the only
copy: `build-new`, then test, then promote, nothing replacing itself in place,
generations built from the same blob until two consecutive ones are
byte-identical, a non-empty check before every `cmp`, and a stop at `C4`. **A
change that touched emission puts the first agreement at `C2 == C3`, so `C1 !=
C2` is not a failure on its own** (E188, `032681f`). A fixpoint shows stability
and says nothing about correctness: a compiler reproducing itself byte for byte
is consistent with being wrong the same way twice.

Everything outside the compiler runs with `chirality run FILE`.

**The gate.** `tools/test/run-tests.sh` is the floor, and a green line is a
named phase there. The suite prints its unported phases by name and reason on
every run. A gate is sound when it has a mutant that is actually run: a check
aimed at a guess passes by looking at nothing.

**On the way out.** Flip the `docs/examples/INDEX.md` row to `implemented` with
the date and what was measured. Put the build-state change in
`docs/definitions/status-ledger.md` on the rung it reached. If the run turned up
a gap between a document's claim and the tree, that is a row in `records/`, six
fields, with the element that owns the fix.

## The doc tier has its own loop

`doc-audit` is the sibling pipeline for documents.

```
python3 tools/ledger-lint/ledger-lint.py     # layer 1, the mechanical worklist
python3 tools/doc/doc.py audit <node>        # layer 2, one doc's semantic bundle
```

Run the lint first. If it is clean and the ask was to check the docs, say so and
stop. Inventing semantic work on a clean lint is its own defect. The fix
direction is fixed: `lib/` and `prog/` source with its tests sit above
`records/conformance-map.md` and `docs/examples/INDEX.md`, which sit above the
decision docs, which sit above a bank, which sits above a thin note. A doc is
corrected toward what is above it. When two authorities above it disagree, flag
both verbatim.

## Cadence

Serial. One stage at a time, one agent at a time.
`docs/decisions/decision-dispatch-cadence.md` is the authority, it overrides
every parallel-waves protocol written anywhere in this tree, and
`protocol/dispatch.md` is how a session runs a queue under it.
