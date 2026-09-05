---
name: pipeline-audit
description: >-
  Audit run for the chirality pipeline: one tool, two levels. DESIGN level gates a
  design artifact before the element mints (citation truth / phantom feature /
  shape honesty / decision discipline / mint-packet soundness); SPEC level gates a
  SPEC before implementation (citation truth / code-forces honesty / plan
  sizing / gate soundness / residue). Use when asked to "audit the design",
  "audit E#", "audit the spec", or before promoting an artifact to the next stage.
---

# pipeline-audit: the gates between pipeline stages

The pipeline is **design → audit → MINT → spec → audit → implement**
(`docs/decisions/decision-design-before-mint.md`). The design is
`docs/arcs/parts/<arc>-<id>.md`, the SPEC is
`docs/elements/specs/E<NN>-<slug>-SPEC.md`, and the build-state authority is
`docs/definitions/status-ledger.md`.

This skill is both gates: same tool, level picked by which artifact is under
audit. Produce exactly **one** audited artifact per run, then **stop**.

**The design gate is the one that mints.** On PASS it allocates the element
number and writes the catalog and ledger rows from the design's §6. That is what
makes minting a graduation, and it is why the design charter's fifth check is
the mint packet.

An audit's ONLY write surface is the artifact under audit, plus the deterministic
flip its verdict triggers. It never touches `lib/`, `prog/`, the other artifact,
or any doc.

## Tier

`.planning/` is the agent tier and it is tracked
(`docs/decisions/decision-ai-tier.md`), so a citation into it resolves in a fresh
clone and is **not a dangling reference**. Flag it as a tier violation instead:
the artifact is read by a person, and `.planning/` is written for a session. The
authorities an artifact may cite are the human tier (`docs/`, `records/`, the
root spine) and the live source. Write nothing into `.planning/`.

Cadence is serial, one stage and one agent at a time
(`docs/decisions/decision-dispatch-cadence.md`), and that decision overrides
every parallel-waves protocol in this tree.

## Step 1: get the bundle (ONE command, read-only)

```
python3 tools/pack/pack.py <arc>/<id> --audit design   # pre-mint gate
python3 tools/pack/pack.py E<#> --audit spec           # implement-ready gate
python3 tools/pack/pack.py E<#> --audit                # the furthest artifact
```

The bundle opens with the level's **audit charter** and contains everything the
checks run against: the artifact under audit, the arc's goal and requirements,
the ledger rungs in range, and **KB slices**: the docs-tier notes resolved from
the artifact's own `[[links]]` plus every bank naming this concept, cut to the
blocks that carry its shards, cross-cuts and residue. SPEC level adds the design
as rationale, live target outlines, and the test baseline.

Nothing is scaffolded and no status changes. The bundle is pure input.

**Read the bundle and little else.** Each slice header says how many blocks were
elided. Grep a cited note narrowly before judging a claim its slice does not
settle. Silence in a slice is never grounds for calling a citation wrong.

## The DESIGN charter

| # | check | fails when |
|---|---|---|
| 1 | **Citation truth** | a §2 claim's `file:line` does not say what the artifact says it says, or carries no citation at all |
| 2 | **Phantom feature** | §3's delta names work the bank refraction shows already built. This is the cardinal working error and this check is why the gate exists |
| 3 | **Shape honesty** | §4 lists one shape with no citation that the tree settles it, or lists shapes that are one shape described twice |
| 4 | **Decision discipline** | a §5 RESOLVED cites no settled doc, a DEFERRED points at something unminted, or a NEEDS-AUTHOR was answered inside the run |
| 5 | **Mint packet soundness** | §6's band is unreserved, a row is incomplete, the split reason does not hold, or it names an unminted `E#` |

## The SPEC charter

| # | check | fails when |
|---|---|---|
| 1 | **Citation truth** | a cited `file:line` does not carry what the SPEC claims |
| 2 | **Code-forces honesty** | §2 asserts agreement on a target it did not open, or re-decided a shape the design settled instead of reporting the refusal |
| 3 | **Plan sizing** | a §3 step exceeds one commit, or a step touching `lib/`/`prog/` omits the build rule |
| 4 | **Gate soundness** | §4 names no mutant, or names one nothing runs. A check aimed at a guess passes by looking at nothing |
| 5 | **Residue** | §5 names an `E#` that was never minted |

## Step 2: run the charter

Work the checks in order. For every defect:

- **FIX**: mechanical and decidable from the bundle (a wrong rung, a stale
  citation, illegal syntax, arithmetic). Edit the artifact in place, and verify
  each fix against the slice you used.
- **FLAG**: author-tier (genuine values, taste, scope). Record the exact
  question in the report. Resolving one takes an author's decision, and burying
  one inside a fix hides that you took it.

## Step 3: verdict

**PASS**, no blocking FLAG. Run the deterministic flip:

```
python3 tools/pack/pack.py <arc>/<id> --mint    # DESIGN level: allocates the E#,
                                                # writes catalog + ledger + the roster row
python3 tools/pack/pack.py E<#> --mark audited  # SPEC level
```

**CLOSED**, design level only. The design's §3 found an empty delta and §6 mints
nothing. Verify the close: open the shards §2 named and confirm they cover the
obligation. Where they do, set the roster row to `closed` and report which
shards cover it. **Minting an element to build what already exists is the defect
this outcome prevents**, so a sound close is a success and not a failed run.

**BLOCKED**, at least one author-tier FLAG. Do NOT mint, do NOT mark. Report the
FLAG list verbatim; the author's answers feed a re-audit.

**REFUSED**, superseded. `pack.py` stops before bundling when the artifact
carries `status: superseded`. There is nothing to gate, because the row will not
be built. Report the successor and stop. Supersession is reachable from any
state and it is an author's call, so this run never writes it.

## When the trigger is new information rather than a fresh artifact

An audit gates an artifact that has just been written. Re-testing a **settled**
artifact against something that changed after it is the `revisit` skill, and it
has its own closed verdict set. Running an audit for that job re-reads the whole
artifact unbounded, which is what `revisit` exists to replace.

## Done

- The artifact carries every FIX; nothing else in the repo changed.
- The flip ran only on PASS, or the row was closed only on a verified CLOSED.
- Final message: verdict, FIX summary, FLAG list with the questions verbatim,
  and the single next pipeline step. Stop, and do not roll into speccing or
  implementing.
