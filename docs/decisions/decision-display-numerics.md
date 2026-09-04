---
node: decision-display-numerics
layer: decision
related: [goals/display, arcs/display-calculus-arc, decisions/decision-numeric-width-pluggable, decisions/decision-scope, working-discipline, records/author-calls, index]
status: settled
updated: 2026-09-04
---

# Decision: display geometry is fixed point, and the scale rides the type

**Settled 2026-09-04 by author directive.**

## The problem

Every geometric row of [[goals/display]] needs a sub-integer coordinate. A glyph
sits between two pixels, a percentage width divides, a transform scales, and a
depth buffer interpolates. The obvious instrument is a float, and this tree has
no float type.

Adding one is a compiler change with a fixpoint attached, so the alternative has
to be refused on the record. A row that quietly assumes `F64` and a row that
quietly assumes fixed point produce two incompatible geometries, and the
disagreement surfaces at integration.

## What the tree already does

**The `Op` sum is closed at fifteen integer ops.** `lib/prelude/prelude.chiral:37-39`
carries them: add, sub, mul, div, mod, eqi, lti, lei, mulhi, sar, shr, band, bor,
bxor, shl. The header above the sum states why it is closed: an op is validated
once at the erase boundary and every downstream consumer matches it
exhaustively.

**The wall is already a stated design position.** Measured 2026-09-04 across
`docs/examples/`: the phrase `float→I64 wall` appears in 14 documents, and the
word `float` appears in 26. Two of the 14 are the compiler's own worked
examples, `E11-totality-checker.md` and `E24-i64-arith.md`.

**Adding `F64` touches seven places.** The `Op` sum, `op-parse`, `op-name`,
`op-bytes`, a new kernel base type, the TAL checker, and the x64 emitter's
register classes, because xmm is a separate class with its own calling
convention and its own allocation. All of it is compiler source, so
[[working-discipline]]'s BUILD RULE applies and the change owes a byte-identical
fixpoint.

## The proposal

**Fixed point, with the scale in the type.** A mixed-scale arithmetic is a type
error. Lane Z's 3D shading is the one place a float would earn its keep, and it
stays refused.

Two independent reasons carry it.

**The reference class runs on fixed point.**

| system | representation | why |
|---|---|---|
| FreeType | 26.6, coordinates in 1/64 px | grid rounding is bit arithmetic: `round(x) == (x + 32) & -64` |
| Blink and WebKit `LayoutUnit` | 1/64 px, chosen September 2012 | avoids precision loss converting to `Length`, and avoids integer division |
| Cairo | 24.8 for path coordinates | rasterizer-internal precision |

Sources: <https://freetype.org/freetype2/docs/glyphs/glyphs-6.html> and
<https://trac.webkit.org/wiki/LayoutUnit>.

**The second reason applies here and in none of them.** This tree verifies a
byte-identical fixpoint on every promotion. Float rounding varies across emit
paths, which makes it a reproducibility hazard against the one property the
build rule already gates on. Fixed point preserves that property by
construction.

## What it leaves open

The scale is a per-lane choice and this ruling does not fix one number. A
character grid needs no fraction at all, and 1/64 px is the precedent for the
pixel lanes. [[decisions/decision-numeric-width-pluggable]] already makes the
integer width a moduleset-configured conformance axis, so a scale bound to a
width is bound to a profile and not to the language.
