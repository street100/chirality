---
node: goal-readable-surface
layer: navigation
related: [goals/README, arcs/diagnostics-arc, arcs/file-types-arc, design-principles, index]
status: current
updated: 2026-09-01
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

The author's framing, 2026-09-01: actually live up to the readability and
convenience commitments, without either sacrificing values or leaving escape
hatches.

## What done means

1. **A diagnostic tells the reader what to do.** Not that something failed, and
   not only where. `docs/definitions/bug-classes.md` holds the classes the
   compiler refuses; each should reach the reader as a message they can act on.
2. **The convenient way is the safe way.** Where a check is conservative and
   taxes safe code, that is recorded as a debt against this goal, not absorbed
   silently by the person writing the code.
3. **No escape hatch that everyone takes.** An opt-out annotation whose usage
   rate is high is a failed default, and the measurement is the deliverable. If
   the annotation is load-bearing it stays, and the goal records why.
4. **Regularity holds at the surface.** One shape, one meaning. File kinds,
   syntax and error vocabulary are the current instances.

## State

**In flight, 2026-09-01.** This is the goal the diagnostics work has been serving
without a file to point at; its arcs previously named [[goals/self-tooling]],
which is where they land as *inputs* rather than what they are *for*.

Built and reaching: E157 typed diagnostics, E158 `Doc`, E181 `surface/pretty`,
E174 `r-row`, E175 ambient-face restore.

Against it, measured: `str-sub` reads past its buffer and reports the read length
while `string.chiral:14` claims in a comment that it clamps
([[records/baseline-alignment]] BA-35) — a regularity violation of the exact
shape [[design-principles]] names, since the comment teaches a behaviour the
primitive does not have.

## Arcs

- [[arcs/diagnostics-arc]] — errors, formatting, the reader-facing message.
- [[arcs/file-types-arc]] — file kinds and syntax. Kind-as-extension is a
  regularity claim before it is a tooling one, and today it is unchecked
  ([[records/baseline-alignment]] BA-30).

Both arcs also serve [[goals/self-tooling]], which is not a conflict: the tooling
goal is what the work is built *out of*, this goal is what it is built *for*.
[[arcs/README]] requires an arc to name exactly one goal, so each names this one
and cites the other in its body.

## Honest limits

**Convenience and enforcement pull against each other, and this goal does not
settle which wins.** `PRINCIPLES.md` §4 says the choice — reject some safe code,
demand annotation, or coarsen the type — is "a decision owed, not settled here".
It is still owed. This goal inherits that, and a decision belongs in
`docs/decisions/` before an arc acts on it.

**Convenience is measured on a reader, and there is one reader.** Every judgement
about what is convenient is currently the author's own, so the evidence for this
goal is weaker than for goals with a mechanical check. Where a claim here can be
made mechanical (an annotation's usage rate, a diagnostic's action verb) it
should be.
