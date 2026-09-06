---
node: goal-bridge
layer: navigation
related: [goals/README, thesis, axis-typeability, category-bridge, category-typed, category-untyped, decision-bridge-elaborator, certificate-discipline, split-role, splitting-law, joining-law, status-ledger, index]
status: current
updated: 2026-09-05
---

# Goal: A governs B, and the bridge is what carries it

## The claim, and where the project makes it

- [[thesis]]: "the design splits cleanly because the thesis splits cleanly. Where
  proof holds, you are in [[category-typed]]. Where proof runs out, you are in
  [[category-untyped]]. The apparatus that lets the first govern the second is
  [[category-bridge]], and **it is the part of Chirality that is new work rather
  than borrowed**."
- [[category-bridge]] says the same in its own words: "A is borrowed prior art; B
  is an honest admission of holes. C is the apparatus that makes the holes
  governable, and it is where the design spends its originality."
- `PRINCIPLES.md` §5: where proof runs out, split the truth and require
  agreement. C is that principle's home.
- [[axis-typeability]]: every module is exactly one of A, B, C, and the placement
  is a partition rather than a spectrum.

This is the project's one claim to originality, stated twice in its own
foundation documents.

## What done means

[[category-bridge]] states two obligations, and they are the first two
conditions. A module declaring `(cat C)` is held to both, the way a module
declaring `(cat A)` is already held to its own.

1. **Inbound, B to A, verify.** A C module "must never return a B derived value
   into A without first turning it into evidence." Observed by `cat-fenced`
   answering for the C arms instead of `(_ none)`.
   [[arcs/bridge-arc]] rows `C1`, `C2` and `C3`.
2. **Outbound, A to B, confine.** It "must never emit an A value into B without
   first confining it": stripped of what must not leak, carrying no live
   capability into ungoverned substrate. Observed on the first evidence
   element, custody. [[arcs/bridge-arc]] row `C4`.
3. **Each obligation has a mutant that is actually run.** A check aimed at a
   guess passes by looking at nothing. **No row serves this**, and the hole is
   enumerated as `GAP-01`. [[arcs/bridge-arc]].
4. **The bridge is one elaborator instantiated with an evidence element**
   rather than a bespoke bridge per referent
   ([[decisions/decision-bridge-elaborator]]). Observed by one generic
   re-checker serving every referent. [[arcs/bridge-arc]] row `C5`.

## State

**The axis is built and fenced on one of its three values.** Measured 2026-09-02.

`lib/surface/parse.chiral:1127` produces `cat-c` from the surface, so the
coordinate is declarable. `lib/module/loader.chiral:295-300` consumes it:
`cat-fenced` is a total function of the finished `Sheet` that refuses a module
declaring `(cat A)` which reaches a crossing, with a named message: "declared
(cat A) -- correctness by proof -- but reaches the crossing X (a crossing is an
admitted hole; this module is B or C)".

Its arms are `((cat-a) ...)` and then `(_ none)`. **So A carries an obligation
the loader enforces, and B and C carry none.** A module may declare itself the
supervisory bridge and owe nothing for it, which is the goal's whole gap in one
line.

Elements already exist for the payload and predate this goal file: `E40` secret
custody (SEEDED, CONFORMS), `E56` custody redundancy and datum policy ("vapor
beyond secret seed", assigned 2026-07-21), `E42` register-root custody.
`records/conformance-map.md` §D holds their rows.

⚑ Correction of a claim this session made before measuring: the typeability axis
is **not** inert. Altitude is (`lib/typing/kernel.chiral:102-106` says so in its
own comment). Typeability has both a producer and a consumer, and only its B and
C values are unattached.

## Arcs

[[arcs/bridge-arc]]. It carries no reserved element block, so its rows take
arc-local ids `C1` and up per [[decisions/decision-work-ids]].

## Honest limits

- The C obligations are prose in [[category-bridge]] today. Nothing in the tree
  states them as a checkable rule, so "done" above names a fence that does not
  exist rather than one that is failing.
- [[certificate-discipline]] is the mechanism C would use where the property is
  provable, and it is unwired: `lib/typing/kernel-core.chiral` has zero
  importers (`records/findings.md` FD-09).
- `lib/lowering/tal/sys.chiral` calls itself "tal's C category in miniature" in
  its header and declares no coordinate. Seven other modules mention a category
  in prose the same way. Prose placement is how modules sit on this axis today.
