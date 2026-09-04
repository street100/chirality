---
name: worked-example
description: >-
  Pre-run for chirality self-implementation. Turn ONE catalog element (E#) into ONE
  documented, conventional-vs-chirality worked example: scoped, researched, and
  ready to copy-and-modify into a real implementation. Use before implementing
  any element from docs/elements/catalog.md, or when asked to
  "produce a worked example", "scope an element", or "do a pre-run".
---

# worked-example: the chirality pre-run pipeline

Produce exactly **one** documented example per run, then **stop**. Contrast the
conventional (other-language) approach against the chirality idea and leave a
clear-cut snippet a later implementation run copies.

This is a **documentation pre-run, NOT an implementation run.** It writes one
artifact under `docs/examples/`. It does not edit `lib/` or `prog/`, add tests,
or build the feature.

## When to use

Before implementing any `E#` from `docs/elements/catalog.md`, or when told to
"do a pre-run", "scope this", or "produce a worked example".

The build rule for whether an element needs the pipeline at all is in
`docs/definitions/working-discipline.md`: run it iff implementing the element
requires choosing between shapes the codebase does not already settle.

## Hard rule: one run = one element = one artifact

Exactly one `E#`. Touch nothing under `lib/` or `prog/`. End by naming the
single suggested next element, then **STOP**: do not roll into it or start
implementing. A second element or a source edit is the failure this prevents.

## Cadence is serial

One stage at a time, one agent at a time. The decision spells out what that
excludes: a batch, a wave, three.
`docs/decisions/decision-dispatch-cadence.md` is the authority and it overrides
every parallel-waves protocol in this tree, this file included. So there is no
`--no-index`, no orchestrator-appends-rows, and no `PLAN-<date>.md`: each run
updates its own INDEX row, because nothing races it.

## Step 1: get the input bundle (ONE command)

```
python3 tools/pack/pack.py E<#> <slug>
```

This prints your **entire** input bundle: the catalog legend, your element row
from `docs/elements/catalog.md`, and the chirality idioms/vocabulary reference.
It also **scaffolds** `docs/examples/E<NN>-<slug>.md` (frontmatter filled, six
section headers ready) plus its `docs/examples/INDEX.md` row.

The **OURS Python baseline is CUT.** The old oracle tree is gone by decision, so
the bundle has no conventional-language source to slice; §3 comes from a named
language and your own knowledge. The bundle says so where the baseline used to
print. Do not go looking for it.

**Read that bundle output and nothing else.** The reference section replaces the
glossary, PRINCIPLES and the lib-style files. Do not read those, and do not read
sibling `docs/examples/E*.md`. If (and only if) you need one specific fact the
bundle lacks, `grep` for just that fact.

`.planning/` is the **agent tier, and it is tracked**.
`docs/decisions/decision-ai-tier.md` settled that on 2026-09-01 and removed the
`.gitignore` exclusion (`git ls-files .planning` returns 148 on 2026-09-04), so a
citation into it resolves in a fresh clone. The old reason for this rule is gone
and the tier reason stands: the artifact you write lives in `docs/`, the tier a
person reads, while `.planning/` holds navigation, queues and handoffs written
for a session, much of it spent (`records/consolidation-handoff.md` holds the
prune queue). Cite the human tier: `docs/`, `records/`, the root spine. The
artifact goes to `docs/examples/`. Write nothing into `.planning/`.

## Step 2: fill the scaffolded artifact (six sections, in order)

Edit `docs/examples/E<NN>-<slug>.md`, sections top to bottom:

1. **Scope**: what the element is + why chirality needs its own (its kind).
2. **Research**: reference class + the 2–4 load-bearing findings. Cite, don't
   transcribe; use your own knowledge for PAPER/IMPL/SPEC. Do not web-fetch.
3. **Conventional (other-language) approach**: a named language: a short
   snippet + the assumptions it bakes in (untyped effects, ambient allocation,
   floats, partiality…).
4. **The chirality idea**: how chirality's model reframes it (QTT/usage, `->` vs `=>`
   membrane, ports/capabilities, categories A/B/C, refinement, totality, the
   float→I64 wall). Say what chirality makes *impossible* here.
5. **Chirality example (fleshed)**: a concrete, commented snippet in **real surface
   syntax** rather than pseudocode: the thing a later run copies, plus **Knobs
   to modify** and **Deliberately omitted**. Keep it a skeleton; elide mechanical
   loops with `; …`.
6. **Use / modify notes**: the `lib/` or `prog/` file it lands in, the
   conformance target (golden behavior to reproduce), open questions, `[[links]]`.

Before you name a gap in §1 or §4, read the concept's bank: `docs/banks/INDEX.md`
holds eleven. A feature that is one thing elsewhere is here a sum of shards, each
in its own home, usually mostly built. Naming a phantom feature is the cardinal
working error in this repository.

Every `E#` you defer to must already be minted. If you name a follow-on,
mint its catalog row and its ledger row in the same change, or write `UNASSIGNED`
and stop.

## Done

- `docs/examples/E<NN>-<slug>.md` filled, all six sections, snippet is real
  surface syntax; frontmatter comments cleaned.
- Its `docs/examples/INDEX.md` row is present (the pack added it), status `drafted`.
- Nothing under `lib/` or `prog/` changed.
- Final message: artifact path + the single suggested next element. Stop.
