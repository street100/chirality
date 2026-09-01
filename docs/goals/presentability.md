---
node: goal-presentability
layer: navigation
related: [goals/README, arcs/presentability-arc, arcs/binary-split-arc, goals/honest-claims, index]
status: current
updated: 2026-09-01
---

# Goal: a reader outside this project can evaluate it

## The claim, and where the project makes it

This goal is an **author call, made 2026-09-01**, and is recorded as one rather
than derived from existing text. [[goals/README]] requires that: adding a goal
means citing where the project already claims it, and authoring a new ambition
is the author's to make. The author's words: get to a good state for sending in
to NLnet or Tangent.

The repo does already carry the shape of it, which is why this is a goal and not
a chore:

- `LICENSE.md` is **AGPL-3.0-or-later** with `LICENSE.EXCEPTION.md`, and
  `docs/decisions/decision-license.md` records why. A licence chosen on purpose
  is a submission precondition already met.
- `README.md:60-75` carries a standing **Honest limits** section, and every
  principle in `PRINCIPLES.md` carries its own. An outside evaluator reads that
  form as a claim about the project's method, so its accuracy is load-bearing in
  a way it is not for an internal reader. This is where this goal meets
  [[goals/honest-claims]].
- `MAP.md` and `CONTENTS.md` exist to orient a reader who has not seen the tree.
  Their audience is exactly the audience this goal serves.

## What done means

An evaluator who has never seen this repo can, without asking anyone:

1. **Build it.** The BUILD RULE in `CLAUDE.md` runs from a fresh clone and the
   byte-compare holds.
2. **Read a claim and trust it.** Every claim in `README.md`, `MAP.md`,
   `CONTENTS.md` and `PRINCIPLES.md` is either true or carries its limit beside
   it. Owned jointly with [[goals/honest-claims]]; this goal is why it matters to
   a stranger, that goal is the mechanism.
3. **Run the tests and read the result.** A green suite means what it says.
4. **See the shape of the thing.** What is built, what is designed, what is
   deferred, without reading `.planning/`.
5. **Take a tool without taking the compiler.** A text tool that ships the x64
   backend and the ELF assembler misrepresents the architecture to anyone who
   measures it. That is [[arcs/binary-split-arc]].

## State

**In flight, 2026-09-01.** Opened when the author named the submission targets.

The starting measurement is unflattering and is the reason the goal exists.
[[records/baseline-alignment]] holds 36 rows, 27 open, most of them claims in
the reader-facing spine that the tree does not support. `README.md:63` describes
a `ledger-lint` exit code the tool does not produce (BA-36). `MAP.md:5` and
`:37-40` describe a file-kind check that has no implementation (BA-30).
`docs/banks/profile.md:246` refutes a real gap with a command that does not
exist (BA-31).

## Arcs

- [[arcs/presentability-arc]] — the reader-facing spine and the submission
  material itself.
- [[arcs/binary-split-arc]] — its `goal` field read `UNWRITTEN` until this file
  existed. The author assigned it here 2026-09-01.

[[goals/honest-claims]] and its [[arcs/baseline-alignment-arc]] are a
prerequisite, not a member. Presentability without honest claims is a worse
outcome than the present state, because it presents wrong claims more
persuasively.

## Honest limits

**Presentability is not a licence to trim caveats.** The one failure this goal
can cause is removing an honest limit to make a document read cleanly. A caveat
cut makes the page better and the project worse, and an evaluator who finds one
missing limit discounts every other claim. `⚑`, "unbuilt", "UNVERIFIED",
"VACUOUS", "SEEDED", and every measured number with its date stay.

**A submission deadline is not a build gate.** Nothing here licenses marking
something ENFORCED because a form asks whether it is. The four rungs mean what
[[status-ledger]] says they mean.

**This goal cannot be finished from inside the repo.** Every criterion above is
about a reader who is not us. Until someone outside reads it, "done" is inferred.
