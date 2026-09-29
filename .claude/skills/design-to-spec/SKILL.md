---
name: design-to-spec
description: >-
  Build-half spec run for chirality. Turn ONE minted element's design
  (docs/arcs/parts/<arc>-<id>.md) into ONE implementation SPEC under
  docs/elements/specs/: what the live code forces, a commit-sized change plan,
  and a conformance gate. Use after an element is minted and before implementing
  it, or when asked to "spec E#", "write the spec", or "plan the build".
---

# design-to-spec: the build half

Produce exactly **one** implementation SPEC per run, then **stop**. The SPEC is
the contract an implementation run executes. The design at
`docs/arcs/parts/<arc>-<id>.md` stays the reasoning behind it, and this run
leaves it alone.

**The design already made the design decisions.** It measured the baseline,
sized the delta, listed the candidate shapes and took the call, and an audit
gated all of that before the element minted. This run does the other half:
finding out what the live code forces, sequencing the change, and making the
result checkable.

This is a **planning run, NOT an implementation run.** It writes one artifact
under `docs/elements/specs/`. It does not edit `lib/`, `prog/`, or the design.

## When to use

After an element is minted, which means its row in the arc's roster carries an
`E#` and `docs/elements/catalog.md` holds its row. If the row still reads
`unminted`, the design stage or its audit is still ahead of it, and
`element-design` comes first.

Where the design's §6 marked the row `direct`, there is no SPEC to write: the
tree settled the shape, the defect is the blueprint, and the row goes straight
to implement under the build rule. Say so and stop.

## Hard rule: one run = one element = one SPEC

Exactly one `E#`. Touch nothing under `lib/` or `prog/`, and do not edit the
design. End by naming the SPEC path and any revisit the run turned up, then
**STOP**.

## Cadence is serial

One stage at a time, one agent at a time.
`docs/decisions/decision-dispatch-cadence.md` is the authority.

## Step 1: get the input bundle (ONE command)

```
python3 tools/pack/pack.py E<#> --spec --start
```

This prints your **entire** input bundle: the catalog row, the full design
artifact, this element's `docs/definitions/status-ledger.md` rung, structural
outlines of every `lib/`/`prog/` file the design names, and the current test
baseline. `--start` is the write: it **scaffolds**
`docs/elements/specs/E<NN>-<slug>-SPEC.md` and moves the roster row's state from
`designed` or `minted` to `specced`. A row already past `specced` is refused by
name with nothing written. Without `--start` the command prints the same bundle
and writes nothing.

**Read that bundle and little else.** The outlines replace reading the target
files. If an outline lacks a body you genuinely need, a few *narrow* greps are
allowed. Each extra turn is the cost.

Cite the human tier: `docs/`, `records/`, the root spine, and the live source.
Write nothing into `.planning/`.

## Step 2: fill the scaffolded SPEC (five sections, in order)

### 1. Deliverable

The one-sentence observable delta, carried from the design's §5 call, plus
explicit non-goals. Where the design's §5 chose between shapes, name the chosen
one and cite the design. Do not re-argue it.

### 2. What the code forces

**The design chose a shape against structural outlines. This is where the live
files push back.** It is the section that exists because a shape that reads well
in a design meets a call site, an arity, an existing sum with no room in it, or
a module boundary in the wrong place.

For each target: what the design assumed, what the file actually admits, and
whether they agree. Cite at `file:line`.

Three outcomes, and the third is the one to get right:

- **They agree.** Say so in a line and move on. Most targets land here.
- **The code constrains the shape without changing it.** An ordering, an extra
  helper, a name already taken. Record it and carry it into §3.
- **The code will not admit the chosen shape.** **Stop, and do not re-decide it
  here.** That is new information against a settled artifact, which is a
  `revisit` on the design with this run as the trigger. Report it, name the
  design artifact, and leave the SPEC at `status: blocked`. Silently picking the
  other shape puts the design and the SPEC into disagreement, with the audit
  behind both of them.

### 3. Change plan

Ordered, commit-sized steps. Each names the target file and symbols, the precise
change, and its size.

**If a step touches `lib/` or `prog/`, it is compiler source and owes the build
rule.** `docs/definitions/working-discipline.md` carries the recipe and is the
only copy: `build-new`, test, promote, nothing replacing itself in place,
generations from the same blob until two consecutive ones are byte-identical, a
non-empty check before every `cmp`, and a stop at `C4`. A change that touched
emission puts the first agreement at `C2 == C3`, so `C1 != C2` on its own
reports a correct build. A comment-only edit counts as a change.

### 4. Conformance gate

Golden behavior made checkable. The gating floor is `tools/test/run-tests.sh`
and a green line is a named phase there.

State the baseline, the expected result, and a one-sentence "done when".

**A gate is sound when it has a mutant that is actually run.** A check aimed at
a guess passes by looking at nothing, and
`docs/decisions/decision-scope.md` carries that as a structural rule. Name the
mutant and what it breaks.

### 5. Residue and links

What is deliberately unbuilt, each with the home that owns it. Follow-on work,
named as a roster row or as an already-minted `E#`. `[[links]]`.

**Every `E#` named here is already minted.** Where one is owed, name a roster
row instead.

## Done

- `docs/elements/specs/E<NN>-<slug>-SPEC.md` filled, five sections.
- Frontmatter `status: draft`, or `blocked` where §2 found the code refusing the
  chosen shape.
- The roster row reads `specced` (the pack did it).
- Nothing under `lib/` or `prog/` changed; the design unchanged.
- Final message: the SPEC path, any §2 refusal with the revisit it implies, and
  the next pipeline step. Stop, and do not roll into implementation.
