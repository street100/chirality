---
node: syntax-evolution
layer: foundation
related: [design-principles, decision-graded-kernel, open-edges, modules-core, joining-law, status-ledger]
status: draft
updated: 2026-07-06
---

# Syntax evolution

The surface is open s-expressions with contextual keywords in head position, so
almost every new construct is *additive*: a new head symbol that leaves existing
forms untouched. The exceptions are the features that change what an *existing
slot* means — those cannot arrive without either a breaking change or a shape
reserved in advance. This note classifies the upcoming forms and reserves the two
shapes that would otherwise force a break. It is [[design-principles]]'s
regularity test extended over time: the same syntax must keep the same meaning
across versions, or a reader's recognition is worth less each release.

## The rule

A surface change is **safe** when it is additive — a new form existing code never
wrote, so no existing program's meaning changes. It is **dangerous** when it
mutates an *occupied slot* — a position existing code already fills, whose
reading the feature widens. The dangerous kind must have its final shape reserved
while the slot has only one inhabitant, so the widening is a *generalization the
old form still satisfies*, not a *reinterpretation that breaks it*.

## Reserve now (slot-mutating)

### The grade-vector binder

Today a binder carries one scalar multiplicity — `(1 x Ty)`, `(0 A (type 0))`,
`(w p Ty)` — from the fixed set `{0, 1, w}`. The graded kernel
([[decision-graded-kernel]] Fork A; edges 2/3 in [[open-edges]]) will make the
grade a *product* — usage × time × space × information-flow — so the slot must
hold a vector, not a scalar. Arriving as fresh syntax, that breaks every existing
signature.

**Reservation (semantic, not literal):** the quantity slot *is* a grade, and
`0/1/w` are the **usage projection** of a grade whose other factors default.
`(q x Ty)` stays the usage-only shorthand; the general form names factors,
Granule-style. The exact literal is Fork A's to settle — a keyed form
`((use 1) (time 3) x Ty)` or a vector `([1 3 0] x Ty)` — but whatever it picks,
`(q x Ty)` must be its one-factor special case and `0/1/w` must remain the usage
projection. **The break to avoid: a *parallel* grade syntax that leaves
`(q x Ty)` a legacy scalar.** Reserve the superset; do not fork the slot.

This is the charter's "spend verbosity where it is signal" ([[design-principles]]):
the grade is signal, under-specified today as one scalar. The reservation is what
lets it grow into full signal without a break.

### The named-effect label

Today the effect is one boolean bit — the last arrow is `=>` (some effect) or
`->` (none), with no way to say *which* effect. Edge 16 (alarms and
counter-effects) needs named effects or rows. Arriving as fresh syntax, bare `=>`
becomes a legacy "unlabeled" form.

**Reservation:** `=>` is the **default, widest effect label**, and a labeled form
is a *refinement* of it, not a replacement. Bare `=>` keeps meaning "some
effect"; the labeled form annotates the same arrow, Koka-style —
`(=>{io} a b)` or `(=> (eff io) a b)` [sketch]. Bare `=>` must remain the widest
effect a labeled arrow is a subtype of, so existing effectful signatures keep
type-checking. **The break to avoid: modeling named effects as a *new arrow kind*
disjoint from `=>`.** Refine the arrow; do not replace it.

### Implicit arguments — co-design with the grade vector

Removing the `(0 A (type 0))` erased-type-parameter boilerplate is the charter's
"reclaim verbosity where it is noise" applied to the largest remaining source of
it. But it is not mechanical sugar — it is a design fork, on two counts:

- **The win needs inference, not parsing.** Shortening the *declaration* is sugar;
  removing `A` from every *call site* — the actual noise — requires the checker to
  synthesize the erased argument at each application by solving it from the
  explicit arguments. The surface elaborator is untyped (the kernel does the
  typing), so this cannot live in the elaborator; it is a kernel feature (holes
  plus a bounded solver), built deliberately, not dumped in (the Fork discipline).
- **The syntax lands in the reserved binder slot.** An implicit marker on a
  binder mutates the same `(q name ty)` slot reserved above for the grade vector.
  Whether "implicit" is a grade factor, a separate marker, or a quantity is a
  choice that must be made *with* the grade-vector shape, or the two collide — the
  regularity-over-time break the reservation exists to prevent.

Reserve nothing unilaterally here: design implicit arguments together with the
grade-vector binder (Fork A) and the checker's inference story (stage 4). Until
then the `(0 A (type 0))` form stays explicit. (The constructor-parameter
inference shipped 2026-07-06 is the bounded, kernel-safe cousin — it solves a
*constructor's* type arguments from its fields, re-checked, no holes; implicits
for *functions* are the larger step.)

## Additive (safe to defer, no reservation needed)

New head symbols or generalizations no existing program wrote — build them when
the feature lands:

- **Staging.** A `(Code T)` type former plus bracket/splice term forms
  (MetaOCaml-style, arbitrary nesting fits the self-similar process model);
  `spawn` stays the "run the next level" primitive. Two-level first per the docs'
  plan, then generalize.
- **Variable-bound refinements.** Generalize the refinement atom from `(op int)`
  to `(op expr)`, resolving the operand in scope; the all-constant case stays the
  decidable, solver-free fragment (existing atoms are its special case).
  Optionally name the refinement variable for readability.
- **Nested and literal patterns**, to flatten the case pyramids. New pattern
  shapes; flat cases unaffected. (The **do-bind** `(<- x e)` — binds an effectful
  step's result linearly for the rest of a `do` — is built as of 2026-07-06.)
- **Qualified / selective imports**, before the flat namespace bites at scale.

## Neither — the token-regularity repairs (resolved: keep as-is)

Two forms were flagged as candidate regularity breaks — the multiplicity marker
being a symbol (`w`) while `0/1` are ints, and `the`'s type-first order. Examined
against the family chirality *is* — an s-expression Lisp, not an ML — neither is a
defect, and each "repair" would cost regularity rather than buy it:

- **`the`'s type-first order is the convention it already follows.**
  `(the ty e)` is exactly Common Lisp's `the` (`(the fixnum x)`), and the form is
  named after it. Type-first is the Lisp reading; the "ecosystem expr-first"
  critique imported an ML lens (`e : ty`) that an s-expr surface does not share.
  Flipping to `(the e ty)` would break *from* the convention, not toward one.
- **The marker's int-vs-`Sym` split is invisible to readers.** A reader sees three
  glyphs — `0 1 w`; that `0/1` intern as ints and `w` as a symbol is a
  parser-internal detail, not a surface distinction. And the *visual* difference
  between the two exact counts and the unbounded `w` is intentional
  look-difference for behavior-difference — [[design-principles]]'s regularity in
  its correct form, not a violation. There is one `w` site in the whole corpus,
  and respelling omega now would mutate the grade-vector slot reserved above —
  the premature commitment that reservation exists to prevent.

So: no break. The debt is retired by ruling it not-a-defect, not by editing source.
The lesson is a regularity-of-analysis one — measure a form against its own
language family before calling it irregular.

## Summary

| Form | Class | Action |
|---|---|---|
| grade-vector binder | slot-mutating | **reserve the superset now** (`0/1/w` = usage projection) |
| named-effect label | slot-mutating | **reserve now** (`=>` = default widest, labels refine it) |
| staging `(Code T)` + brackets | additive | build with the feature |
| variable-bound refinements `(op expr)` | additive | build with the feature |
| nested/literal patterns | additive | build when ergonomics warrant |
| `(<- x e)` do-bind | additive | **built 2026-07-06** |
| qualified imports | additive | build before the namespace bites |
| `w`-vs-`0/1`, `the` order | regularity repair | **resolved: keep as-is** (both are Lisp-family regular) |

## Why this is a foundation note

Regularity across versions is regularity ([[design-principles]]): a reader's
recognition of `(1 x Ty)` or `=>` is an asset the language must not silently
devalue. The two reservations cost nothing now — each slot has one inhabitant —
and prevent a forced break later. Everything else is genuinely additive because
the surface is open s-expressions, which is itself a regularity dividend: an open
grammar means new meaning arrives as new *form*, not as a reinterpretation of old
form.
