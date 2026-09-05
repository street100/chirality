---
node: working-discipline
layer: foundation
related: [index, status-ledger, elements/README, arcs/README, banks/INDEX, decisions/decision-dispatch-cadence, decisions/decision-scope, decisions/decision-ai-tier]
status: current
updated: 2026-09-05
---

# Working discipline

How work is done in this tree. `MAP.md` is the *tree* contract — extension is the
kind, directory is the role, the module key is the root-relative path. This is the
*work* contract.

## The build rule

**The compiler compiles everything. Python compiles nothing.**

`build-new → test → promote`. The existing `bin/chirality-bin` compiles a new
binary from the blob; you test that binary; you promote it. **Nothing replaces
itself in place.**

When the compiler's own sources changed, build generations from the same blob
until two consecutive ones are byte-identical:

```
. bin/chirality-resolve.sh
chirality_blob_file "lib:prog" prog/compiler.prog > /tmp/blob.chiral
(ulimit -s unlimited; bin/chirality-bin < /tmp/blob.chiral > /tmp/C1) && chmod +x /tmp/C1
[ -s /tmp/C1 ] && (ulimit -s unlimited; /tmp/C1 < /tmp/blob.chiral > /tmp/C2) && chmod +x /tmp/C2
[ -s /tmp/C2 ] && cmp /tmp/C1 /tmp/C2
# they differ: build C3 from C2 the same way, cmp C2 C3, then C4 against C3.
```

**Convergence is two consecutive generations agreeing, and the first agreement is
not always `C1 == C2`.** `C1` carries the new sources and was emitted by the old
code generator. Where the change touched emission and the compiler's own blob
holds a site that change reaches, `C1` and `C2` differ for that reason alone and
the build is correct. `C1` and `C2` carry the same sources and emit alike, which
puts the first agreement at `C2 == C3`. A change that leaves emission alone
converges at `C1 == C2`.

**Check the artifact is non-empty before every `cmp`, and keep the `(ulimit -s
unlimited; …)` on every build.** Two empty files compare equal, so an unguarded
`cmp` reports a fixpoint on a build that produced nothing.

**Stop after `C4`.** The paragraph above caps the first agreement at `C2 == C3`,
so a fourth generation that still differs is a defect rather than a slow
convergence, and an open-ended loop only repeats a compile that already told you
what it had to say. Report the sizes and the first differing char, and stop.

E188 measured the three-generation case (`032681f`, 2026-09-04). Its `B1` is the
tracked binary at 1,192,312 bytes, so its `B2`, `B3` and `B4` are `C1`, `C2` and
`C3` here: `C1` 1,192,312 bytes differing from the tracked binary at char 3040,
`C2` 1,184,120 differing from `C1` at char 98, `C3` 1,184,120 byte-identical to
`C2`. `C1` was emitted by the old code generator and was not the fixpoint, `C2`
was promoted, and **a run stopping at `cmp C1 C2` would have reported failure on
a correct build.** The change was the `(none)` arm of `arm-body`
(`lib/lowering/upper/closconv.chiral:1109`), which the compiler's own blob reaches
twice.

**A fixpoint shows stability and says nothing about correctness.** The compiler
reproducing itself byte-for-byte is consistent with it being wrong in the same way
twice. E188 is the second reason to believe that: the wrong code it repaired rode
into `$apply5` and `$apply6` under a green suite and a holding fixpoint.

⚑ **A comment-only edit to `lib/` or `prog/` is still a change to compiler
source** and owes the rebuild above. This is why `lib/typing/diag.chiral:32` still
names `LAYOUT.md`, six days after that file became `MAP.md`: the repoint is
correct and deliberately deferred rather than taken for free.

Everything that is not the compiler has no ceremony: `chirality run FILE`.

## The deferral rule

**Never defer work to a follow-on `E#` or `T#` that is not already minted.**

A deferral to a nonexistent element is a phantom dependency, and the "it's
deferred" note is a lie by omission: it reads as scheduled work and is not.

Name a roster row instead. [[decisions/decision-work-ids]] gives an arc-local
row a stable citable id that claims no place in a band, a catalog row, a ledger
row or a pipeline stage, so the deferral rule keeps its whole force over `E#`
while work still gets named. `docs/decisions/decision-lane-split.md` reserves
the bands; an arc outside them gets one from the author.

## Commits

**Atomic slices, and pathspec every commit** — `git commit -- <path> …`. A bare
commit sweeps another agent's staged work. That has happened twice in this tree.

## Reporting

**Report failures with their output. Name skipped work. Say "done" only when a
gate ran.**

The corresponding structural rule is in `docs/decisions/decision-scope.md`: a
subcommand dispatching to a floor this tree lacks is a gate that cannot fail. It
reads on documents as well as on code — a check aimed at a guess passes by looking
at nothing, which is why a stale citation is repointed at a verified target or
left alone and recorded.

## Before naming a gap

**Read the concept's bank first.** [[banks/INDEX]] holds twelve, and states the
rule: a feature that is one thing elsewhere is here a sum of shards, each in its
own home, usually mostly built. Naming a phantom feature is the cardinal working
error in this repository.

If a concept has no bank, build one rather than guess.

## The element pipeline

`design → audit → MINT → spec → audit → implement`, with `revisit` reaching any
artifact in it. [[decisions/decision-design-before-mint]] settled the shape on
2026-09-05 and `.planning/protocol/workflow.md` holds the run.

**Minting is the graduation.** A unit of work is named in its arc's roster when
the arc opens, cited as `<arc>/<id>` per [[decisions/decision-work-ids]], worked
up in `docs/arcs/parts/`, and given an `E#` only when its design audit passes.
The arc-local id survives the promotion, so a citation made before the number
existed still resolves.

The design stage always runs, because it is what measures the baseline. Two of
its outcomes end the row without building anything, and both are successes:

- **§3 finds an empty delta.** The work is already built. The row closes, names
  the shards that cover it, and mints nothing. Minting an element to build what
  exists is the failure this catches.
- **§4 finds the shape forced.** The codebase already settles it, so the row is
  `direct`: it mints and goes to implement with no SPEC. A bug-class fix whose
  shape is forced by the defect needs no blueprint, because the defect is the
  blueprint.

That second case is where this rule used to sit as a decision about whether to
run the pipeline at all. It is now a finding the pipeline produces, with a
citation behind it.

Cadence is serial, one stage at a time, one agent at a time. The authority is
[[decisions/decision-dispatch-cadence]].

## Where state lives

There is no state file at the root, and no `.planning/STATE.md`. This repo does
not use GSD, and a global instruction that routes work into GSD does not apply
here.

| what | where |
|---|---|
| build state, on the four rungs | [[status-ledger]] |
| what a goal claims and which arcs serve it | `docs/goals/` |
| an arc's requirements, element list and resume state | `docs/arcs/` |
| a roster row worked up, before it has a number | `docs/arcs/parts/` |
| the element catalog, the ledger, the specs | `docs/elements/` |
| a claim beside its measurement | `records/` |
| decisions only the author can make | `records/author-calls.md` |
| navigation, protocol, queues, handoffs, captures | `.planning/`, the agent tier, tracked since 2026-09-01 ([[decision-ai-tier]]) |

An arc file carries its own resume state, so a session starts from the arc and
needs nothing at the root.
