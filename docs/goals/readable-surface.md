---
node: goal-readable-surface
layer: navigation
related: [goals/README, arcs/diagnostics-arc, arcs/file-types-arc, design-principles, index]
status: current
updated: 2026-09-14
---

# Goal: the surface is convenient without buying it back in escape hatches

## The claim, and where the project makes it

- `PRINCIPLES.md` §4, **the safe path should be the cheap path**: enforce good
  behaviour by making the well-behaved shape the low-ceremony default and the
  risky shape the one you opt into loudly, so most code is safe because safe was
  the path of least resistance.
- `PRINCIPLES.md` §4's own **honest limit** states the failure mode this goal
  exists to avoid: *"'safe is cheap' holds only as far as the checker accepts
  naturally-safe code without ceremony; where a conservative check cannot see
  safety, the tax lands on safe code and the opt-out annotation stops being a
  signal."* An annotation everyone writes is an escape hatch with a polite name.
- [[design-principles]] states the reader's-side test, **regularity**: things
  that look the same behave the same, and things that behave differently look
  different. Its violation "defeats recognition", so every instance must be
  re-reasoned from scratch.
- [[design-principles]] also names the deliberate **trade of concision for
  safety** — this project already accepts paying in keystrokes, which is what
  makes convenience a goal rather than a preference.

The author's framing: live up to the readability and convenience commitments
without either sacrificing values or leaving escape hatches.

## What done means

1. **A diagnostic tells the reader what to do**, beyond that something failed
   and where. `docs/definitions/bug-classes.md` holds the classes the compiler
   refuses, and each should reach the reader as a message they can act on.
   Observed by every `Reason` arm carrying evidence a reader can open.
   [[arcs/diagnostics-arc]] rows `V1`, `V2` and `V4`.
2. **The convenient way is the safe way.** Where a check is conservative and
   taxes safe code, that is recorded as a debt against this goal rather than
   absorbed silently by the person writing the code. Observed by each such tax
   carrying a limit row with its coverage state. **Unopened, and it holds no
   arc file**: `records/lenses/limits.md` is the home and nothing schedules the
   sweep.
3. **No escape hatch that everyone takes.** An opt-out annotation whose usage
   rate is high is a failed default, and the measurement is the deliverable. An
   annotation that is load-bearing stays and the goal records why. Observed by
   a counted usage rate per annotation. **Unopened, and it holds no arc file.**
4. **Regularity holds at the surface.** One shape, one meaning. Observed on the
   three current instances: file kinds, syntax and the error vocabulary.
   [[arcs/file-types-arc]] for the kinds, [[arcs/diagnostics-arc]] for the
   vocabulary, [[arcs/surface-syntax-arc]] for the syntax.

## State

Built and reaching: E157 typed diagnostics, E158 `Doc`, E181 `surface/pretty`,
E174 `r-row`, E175 ambient-face restore.

Against it: `str-sub` reads past its buffer and reports the read length
while `string.chiral:14` claims in a comment that it clamps
([[records/baseline-alignment]] BA-35) — a regularity violation of the exact
shape [[design-principles]] names, since the comment teaches a behaviour the
primitive does not have.

What makes an opinionated language hard is the amount you have to hold in your
head. Where the checker is wired the load is off you; where it is not, the shape
is light because nothing is weighing it.

| what | state | where | limit |
|---|---|---|---|
| usage on binders | enforced, gated | `lib/typing/qtt.chiral`, Phase 6 | |
| refinement types | enforced, gated | `lib/typing/refine.chiral` | `I64` only, `jg-refine-i64` |
| totality as the default | reached, ungated | `lib/typing/totality.chiral` through `typing/totality-check` | `tot-gate` runs at `compile-front.chiral:340`, and a source declaring no `(total)` profile pays nothing. No termination judgment in `diag.chiral`, and no suite phase runs the one demo that declares one |
| `->` against `=>` | carried, refused nowhere | `lib/typing/effects.chiral` | E171 |
| `paren-audit` diagnosis | built, runs | `prog/paren-audit.prog` | reports a count where a position is wanted |
| `paren-audit` repair | not built | | needs P1 spans and P4 addresses in [[arcs/text-tools-arc]] |

`paren-audit` is the method at its smallest: name the class, build the primitive,
stop paying attention to it. 244 lines of chirality that name the form, the line
it opens on, and the delta. The repair half turns unbalanced parens into
something you never consider again.

## Arcs

- [[arcs/diagnostics-arc]] — errors, formatting, the reader-facing message.
- [[arcs/file-types-arc]] — file kinds and syntax. Kind-as-extension is a
  regularity claim before it is a tooling one, and today it is unchecked
  ([[records/baseline-alignment]] BA-30).
- [[arcs/surface-syntax-arc]] holds the third instance condition 4 names,
  syntax, which neither sibling states. Opened 2026-09-14.

[[arcs/diagnostics-arc]] and [[arcs/file-types-arc]] also serve
[[goals/self-tooling]]: that goal is what the work is built *out of*, this one
is what it is built *for*. Both name both.

## Honest limits

**Convenience and enforcement pull against each other, and this goal does not
settle which wins.** `PRINCIPLES.md` §4 says the choice — reject some safe code,
demand annotation, or coarsen the type — is "a decision owed, not settled here".
It is still owed. This goal inherits that, and a decision belongs in
`docs/decisions/` before an arc acts on it.

**Two of the four typing rows are unreached**, so on those the low ceremony is
absence rather than design. The claim is about load rather than about
correctness: a checker you never argue with may simply have stopped looking.

**Convenience is measured on a reader, and there is one reader.** Every judgement
about what is convenient is currently the author's own, so the evidence for this
goal is weaker than for goals with a mechanical check. Where a claim here can be
made mechanical (an annotation's usage rate, a diagnostic's action verb) it
should be.
