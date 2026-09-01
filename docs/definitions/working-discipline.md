---
node: working-discipline
layer: foundation
related: [index, status-ledger, elements/README, arcs/README, banks/INDEX, decisions/decision-dispatch-cadence, decisions/decision-scope]
status: current
updated: 2026-09-01
---

# Working discipline

How work is done in this tree. `MAP.md` is the *tree* contract — extension is the
kind, directory is the role, the module key is the root-relative path. This is the
*work* contract.

Hoisted 2026-09-01 from a gitignored agent-instruction file at the root. Every
rule below was load-bearing and none of it survived a fresh clone, which meant a
new reader could not learn how to build the compiler from the repository itself.

## The build rule

**The compiler compiles everything. Python compiles nothing.**

`build-new → test → promote`. The existing `bin/chirality-bin` compiles a new
binary from the blob; you test that binary; you promote it. **Nothing replaces
itself in place.**

When the compiler's own sources changed, run the promoted binary over the same
blob once more and byte-compare:

```
. bin/chirality-resolve.sh
chirality_blob_file "lib:prog" prog/compiler.prog > /tmp/blob.chiral
(ulimit -s unlimited; bin/chirality-bin < /tmp/blob.chiral > /tmp/C1) && chmod +x /tmp/C1
[ -s /tmp/C1 ] && (ulimit -s unlimited; /tmp/C1 < /tmp/blob.chiral > /tmp/C2) && cmp /tmp/C1 /tmp/C2
```

**Check the artifact is non-empty before the `cmp`.** Two empty files compare
equal, so an unguarded `cmp` reports a fixpoint on a build that produced nothing.

**A fixpoint shows stability and says nothing about correctness.** The compiler
reproducing itself byte-for-byte is consistent with it being wrong in the same way
twice.

⚑ **A comment-only edit to `lib/` or `prog/` is still a change to compiler
source** and owes the rebuild above. This is why `lib/typing/diag.chiral:32` still
names `LAYOUT.md`, six days after that file became `MAP.md`: the repoint is
correct and deliberately deferred rather than taken for free.

Everything that is not the compiler has no ceremony: `chirality run FILE`.

## The deferral rule

**Never defer work to a follow-on `E#` or `T#` that is not already minted.** If
you name one, mint its catalog row and its ledger row in the same change.

A deferral to a nonexistent element is a phantom dependency, and the "it's
deferred" note is a lie by omission: it reads as scheduled work and is not.

Where an arc needs an element and has no reserved block, it writes `UNASSIGNED`
and stops. `docs/decisions/decision-lane-split.md` reserves `E184-E189` and
`E190-E195`; an arc outside those gets a block from the author.

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

**Read the concept's bank first.** [[banks/INDEX]] holds eleven, and states the
rule: a feature that is one thing elsewhere is here a sum of shards, each in its
own home, usually mostly built. Naming a phantom feature is the cardinal working
error in this repository.

If a concept has no bank, build one rather than guess.

## The element pipeline

`example → audit → spec → audit → implement`.

Run it for an element **iff implementing it requires choosing between shapes the
codebase does not already settle.** A bug-class fix whose shape is forced by the
defect does not need a blueprint; the defect is the blueprint. When in doubt, run
it: the pipeline is one cheap turn and a wrong shape is not.

Cadence is serial, one stage at a time, one agent at a time. The authority is
[[decisions/decision-dispatch-cadence]].

## Where state lives

There is no state file at the root, and no `.planning/STATE.md`. This repo does
not use GSD.

| what | where |
|---|---|
| build state, on the four rungs | [[status-ledger]] |
| what a goal claims and which arcs serve it | `docs/goals/` |
| an arc's requirements, element list and resume state | `docs/arcs/` |
| the element catalog, the ledger, the specs | `docs/elements/` |
| a claim beside its measurement | `records/` |
| decisions only the author can make | `records/author-calls.md` |
| untracked working scratch | `.planning/`, excluded by `.gitignore` |

An arc file carries its own resume state, so a session starts from the arc and
needs nothing at the root.
