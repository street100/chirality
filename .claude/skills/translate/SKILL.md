---
name: translate
description: >-
  Translation run for chirality. Turn ONE published external object (a cipher, a
  permutation, a mode, a field, a scheme) into ONE artifact under
  docs/translations/: the object's own mathematics, what the conventional shape
  bakes in, which chirality form carries each precondition, what that makes
  unconstructible, and what stays byte-identical. Use when asked to "translate
  AEAD", "work up Keccak-f", "render this RFC into our forms", or before
  speccing any element whose reference class is an external standard.
---

# translate: the pre-roster translation run

Produce exactly **one** translation artifact per run, then **stop**.

The mathematics is published, analyzed and **external**. It belongs to the
literature, and this run leaves it alone. The work is showing which chirality form carries each
precondition of a published theorem, and what that makes unconstructible.

This runs **upstream of a roster row**. An object can be translated before anyone
decides which row builds it, so this writes no arc file, no roster row, no
catalog row and no ledger row, and it mints nothing.

## Hard rule: one run = one object = one artifact

Touch nothing under `lib/` or `prog/`. The only write surface is
`docs/translations/<object>.md` and the object's gather manifest.

## Cadence is serial

One stage at a time, one agent at a time
(`docs/decisions/decision-dispatch-cadence.md`).

## Step 0: the gather comes first

A translation rests on external material, so the sources are pinned before
anything is written. `.planning/sources/<object>.gather` is the manifest, one
row per slot, tab-separated: `slot`, `source-id`, `state`, `note`. State is
`run` or `UNRUN`.

Four slots are the floor, and the AEAD walk found the fourth by its absence:

| slot | holds |
|---|---|
| `construction` | the algorithm itself |
| `properties` | the published property enumeration for this class of object |
| `limits` | usage bounds, where they exist |
| `known-gaps` | the literature on what this construction lacks |

**A slot with no published home is declared `UNRUN` with the reason.** An
ungathered source that reads as an absence is the failure this manifest exists
to prevent.

**The gather is a `research` run.** Dispatch one per slot: it searches, pins
what it finds with `raw` origin, and writes an `FD` row saying what the source
settles and what it leaves open. A slot whose sources come back empty is a
declared `UNRUN` with a reason rather than a blank.

`pin` never fetches. Obtain the bytes, then:

```
tools/xlat/xlat.sh pin <ID> <URL> raw|transcribed|partial <FILE>
```

**Prefer `raw`.** A `transcribed` pin is one session's reading, and a span
absent from it may still be in the source. Every report says so, and §1 of the
artifact carries it.

## Step 1: the bundle (ONE command)

```
tools/xlat/xlat.sh bundle <object>
```

It returns the gather state, the RFC 2119 obligations in every pinned source
split into binding and weaker sets, the carrier forms live in `lib/` with line
citations, and the lowering gaps a proposed carrier must not walk into.

## Step 2: scaffold and fill

```
tools/xlat/xlat.sh new <object>
```

Nine sections, in order. Three of them are **generated rather than composed**,
and composing one instead is the error this run is built to avoid.

| § | how it is produced |
|---|---|
| 1 source | the manifest, with every `UNRUN` slot named as a hole |
| 2 object | **quoted from pins.** Never from memory. The property enumeration is the deliverable, and a partial one is worse than none because it reads as complete |
| 3 conventional | **generated from the binding obligations.** Each one is a duty the reference signature cannot carry, so each one is a bug class |
| 4 carriers | each precondition to a form, with the `lib/` precedent from the bundle. A carrier that hits a lowering gap is refused here |
| 5 refusals | derived from §4 |
| 6 invariant core | what stays byte-identical. **Empty means this is a redesign** |
| 7 laws and pins | properties to test, and which vectors pin which arbitrary constants. Constants carry no structure, so a vector is the only instrument that reaches them |
| 8 push | **generated**: properties the object lacks, crossed with carriers available |
| 9 limits | the binding obligations no carrier reaches, one by one |

Every external quote carries `ID:LINE "span"`.

## The rule that governs every section

**Nothing is written from memory.** A property set recalled rather than read is
the measured failure this tier was built after: a walk done from memory produced
2 of an object's 23 published properties and read as complete. If a fact is not
in a pin, either pin its source or record it as `UNRUN`.

## Step 3: verify before stopping

```
tools/xlat/xlat.sh check docs/translations/<object>.md
```

Exit 0, or the run has more to do. It resolves every citation into a pin,
reports a quote whose line has moved, fails a fabricated quote, fails a cited
source that lacks a pin, and names any absent stage.

## Done

End by naming the artifact path, the count of binding obligations and how many
are carried, the `UNRUN` slots, and the `xlat check` exit. Then **STOP**. The
gate that promotes it is `pipeline-audit` at TRANSLATE level.
