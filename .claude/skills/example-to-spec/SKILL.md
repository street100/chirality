---
name: example-to-spec
description: >-
  Spec run for chirality self-implementation. Turn ONE drafted worked example
  (docs/examples/E<NN>-*.md) into ONE implementation SPEC under
  docs/elements/specs/ with a baseline delta, dispositioned decisions, a
  commit-sized change plan and a conformance gate. Use after a pre-run exists and before
  implementing that element, or when asked to "spec E#", "example to spec", or
  "write the spec".
---

# example-to-spec: the chirality spec run

Produce exactly **one** implementation SPEC per run, then **stop**. The SPEC is
the contract a later implementation run executes; the worked example stays the
design rationale behind it. This run turns the example's §6 handoff ("lands in /
conformance target / open questions") into an executable plan.

This is a **planning run, NOT an implementation run.** It writes one artifact
under `docs/elements/specs/`. It does not edit `lib/` or `prog/`, and it does not
edit the example.

## When to use

After a drafted example exists for an `E#` and the element is headed for
implementation. If there is no `docs/examples/E<NN>-*.md` yet, stop and say so.
The `worked-example` pre-run comes first.

## Hard rule: one run = one element = one SPEC

Exactly one `E#`. Touch nothing under `lib/` or `prog/`, and do not edit the
example. End by naming the SPEC path, the NEEDS-AUTHOR decisions (if any), and
the single suggested next element, then **STOP**. Rolling into implementation is
the failure this prevents.

## Cadence is serial

One stage at a time, one agent at a time. The decision spells out what that
excludes: a batch, a wave, three.
`docs/decisions/decision-dispatch-cadence.md` is the authority and it overrides
every parallel-waves protocol in this tree, this file included. So there is no
`--no-index` and no orchestrator-patches-rows: this run updates its own INDEX
row, because nothing races it.

## Step 1: get the input bundle (ONE command)

```
python3 tools/pack/pack.py E<#> --spec
```

This prints your **entire** input bundle: the catalog row, the full drafted
example (your primary input), this element's rows from
`records/conformance-map.md` (the build-state authority), structural outlines of
every `lib/`/`prog/` file the example names, and the current test baseline. It
also **scaffolds** `docs/elements/specs/E<NN>-<slug>-SPEC.md`, flipping the element's
`docs/examples/INDEX.md` row to `specced` with a SPEC link.

**Read that bundle and little else.** The outlines replace reading the target
files; the map rows replace the conformance map; the example replaces its
sources. If an outline lacks a body you genuinely need, a few *narrow*
greps/reads (specific symbol, specific fact) are allowed. Each extra turn is the
cost.

`.planning/` is untracked scratch that forks per worktree. Do not cite it and do
not write a SPEC into it.

## Step 2: fill the scaffolded SPEC (six sections, in order)

Edit `docs/elements/specs/E<NN>-<slug>-SPEC.md`, top to bottom:

1. **Deliverable**: the one-sentence observable delta + explicit non-goals.
2. **Baseline**: what the map verdicts + live outlines say already exists;
   name the built shards this composes with (check the refraction in
   `docs/banks/INDEX.md`: do not respec a shard that exists); state the true
   delta.
3. **Decisions**: every open question from the example §6, dispositioned:
   **RESOLVED** only when derivable from a settled doc (cite it), **DEFERRED**
   to a named E#/docket edge that is *already minted*, or **NEEDS-AUTHOR**,
   which is surfaced and carried out of the run. Answering one silently is the
   defect. A blocking NEEDS-AUTHOR sets
   `status: blocked` and earns a row in `records/author-calls.md`.
4. **Change plan**: ordered, commit-sized steps: target file + symbols, the
   precise change (adapting the example's §5 snippet where it applies), size.
   If a step touches `lib/` or `prog/`, it owes the build rule in
   `docs/definitions/working-discipline.md`: build-new, test, promote, and for
   compiler source a byte-compare with a non-empty check first.
5. **Conformance gate**: golden behavior made checkable. The gating floor is
   `tools/test/run-tests.sh`, and the green line is a named phase there. State
   baseline → expected and a one-sentence "done when".
6. **Residue & links**: deliberately unbuilt (each with its home), follow-on
   elements, each one minted, `[[links]]`.

## Done

- `docs/elements/specs/E<NN>-<slug>-SPEC.md` filled, all six sections;
  frontmatter `status: draft` (or `blocked` with the NEEDS-AUTHOR list).
- `docs/examples/INDEX.md` row shows `specced` + SPEC link (the pack did it).
- Nothing under `lib/` or `prog/` changed; the example unchanged.
- Final message: SPEC path + NEEDS-AUTHOR decisions (if any) + the single
  suggested next element. Stop.
