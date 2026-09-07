---
node: translations-README
layer: reference
related: [definitions/working-discipline, decisions/decision-design-before-mint, index]
status: current
updated: 2026-09-07
---

# docs/translations/

One file per published external object, rendered into this tree's forms.

**The mathematics is external and it stays external.** A translation cites a
standard, it never restates one, and it never invents one. The work is showing
which chirality form carries each precondition of a published theorem, and what
that makes unconstructible.

A translation sits **upstream of a roster row**. An object can be translated
before anyone decides which row builds it, which is why this tier is its own
directory rather than a shape under `arcs/parts/`.

## The nine sections

`tools/xlat/xlat.sh new <object>` scaffolds them and `xlat check` verifies they
are present.

| # | section | holds |
|---|---|---|
| 1 | source | the gather manifest, with every `UNRUN` slot named as a hole |
| 2 | object | the mathematics: signature, laws, security notions, preconditions |
| 3 | conventional | the reference shape, one bug class per baked-in assumption |
| 4 | carriers | each precondition mapped to a chirality form, with a `lib/` precedent |
| 5 | refusals | what stops being constructible, derived from 4 |
| 6 | invariant core | what stays byte-identical, which keeps the published vectors valid |
| 7 | laws and pins | properties to test, and which vectors pin which constants |
| 8 | push | where the type system reaches past what the standard can enforce |
| 9 | limits | the binding obligations no carrier reaches |

**Section 6 is what separates a translation from a redesign.** An empty
invariant core means the arithmetic moved, the published vectors no longer
apply, and the artifact is mislabelled. The audit fails on it.

## Citations

External quotes carry a pinned citation in the tree's own `file:line` idiom:

    RFC8439:24 "The Poly1305 key MUST be unpredictable to an attacker."

`ledger-lint` check U resolves a quote against a tracked file and cannot reach
external material. Check AL runs `xlat check` over this directory, which is what
makes a pinned quote carry the same weight as an internal citation.

## Origin, and what a pin is worth

A pin records how the bytes were obtained. `raw` is the source. `transcribed`
is one session's reading of it, and a span absent from a transcription may still
be in the source. Every report that reads a non-raw pin says so, and a
translation resting on one carries that in section 1.
