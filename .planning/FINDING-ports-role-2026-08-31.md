> **Tracked rows: `FD-05` (fixed) and `FD-06` (open, author-tier) in `records/findings.md`.** Those rows are what survive a fresh clone; this file is the long-form argument and stays because the principle condensation is undecided.

# FINDING: `ports/` names a property that is universal, so it cannot be a role

**2026-08-31.** Author-raised, from two directions in one breath: the `.chiral`
files in `lib/ports/` look misplaced, and the principle set wants refining
toward *everything is a port boundary*. Those are the same observation.

## The four files, and where their consumers put them

`MAP.md` says `ports/` is "the crossings themselves". Nine `.port` files fit.
The four `.chiral` do not, and each has a home already named by whoever imports it.

| file | imports | importers | mints | indicated home |
|---|---|---|---|---|
| `crossing-wraps.chiral` | prelude | `lowering/tal/sys-linkage`, `lowering/tal/erase` — **both in lowering/tal** | nothing | `lowering/tal/` |
| `inet.chiral` | prelude, ports/ports | `protocol/http` — **sole importer** | nothing | `protocol/` |
| `term.chiral` | prelude, ports/ports, **lowering/tal/bytes** | `capability/session`, scriba ×5 | nothing | `runtime/` or `protocol/` |
| `ports.chiral` | the nine registries | 48 modules | nothing | stays: it is the façade |

`crossing-wraps` is the clearest: its own header explains it is a leaf *because*
the erase image cannot import sys-linkage without a tal-ir collision. It exists
to serve two lowering modules and lives nowhere near them.

`inet` has exactly one importer and that importer is `protocol/http`.

`term` is 29 defs of terminal logic that reaches down to `lowering/tal/bytes`,
which no `.port` does.

## Why the directory is the problem, not the files

The nine `.port` files are not special because they are boundaries. Under the
refinement the author is reaching for, **everything** is a boundary, so being one
cannot distinguish a directory.

What is actually special about them is narrower and sharper: they are where a
boundary is **minted**. A `.port` introduces a capability type that did not exist
before, via `porttype`, and binds the externs that cross it. Every other module
in the tree *crosses* boundaries that were already minted somewhere else.

So the role is **the mint**, not "the crossings". Read that way the sort is
mechanical rather than a judgment call: `term`, `inet` and `crossing-wraps` mint
nothing, so they are not in the mint. `ports.chiral` mints nothing either, but it
is the façade over the nine that do, which is a different thing and should be
said out loud in `MAP.md` rather than inferred.

⚑ This also predicts the misfile happens again. Nothing checks it. A file lands
in `ports/` because it is *about* ports, which is subject matter, and
`MAP.md`'s own first rule is that subject matter names nothing. A `.port` is
already structurally testable (zero lambdas, at least one extern or porttype);
"lives in `ports/` iff it mints" is the same test pointed at the directory, and
could be a gate.

## The principle question

*"Everything is port boundaries"* as the refined root. It has real pull:

- **P2** says a process's type is its whole cost. **P3** says the port-check is
  the type-check. Compose them and the process and its boundary are one object
  seen twice, so the atom is the boundary rather than the process.
- **P3's "one leak"** stops being a leak. Time and space are currently awkward
  add-ons ("they affect the world by running rather than by calling"); if the
  boundary is the atom, spending time is crossing the boundary with the
  substrate that hosts you. A case, not an exception.
- **P1** reads as: a gap is an ungoverned path *because* it is a boundary with
  no name.
- **P4** reads as: cheap is a light boundary. The cost gradient is boundary
  weight.
- **P5** is where a boundary cannot be typed, so you replicate across several
  and compare.

**The test it has to pass**, and this is the whole question: an abstraction that
does not constrain is overhead. "Everything is X" forbids nothing by itself, and
a principle that forbids nothing is worse than the five it replaced, because it
reads as profound while permitting everything.

One concrete thing it already decides, which is evidence it is not vacuous: it
kills `ports/` as a subject-matter directory and replaces it with the mint test
above. If the refinement can be shown to decide two or three more open questions
that the current five leave open, it has earned the condensation. If it decides
only this one, the cheaper fix is to correct `MAP.md`'s sentence and leave
the principles alone.

Owed, and author-tier: whether to run the condensation at all. The 2026-07-20
seven-to-five pass is the precedent for how (adversarial review, a crosswalk
kept until a renumbering sweep). Nothing here should be edited into
`PRINCIPLES.md` before that call.

## Not the whole audit

The author's note that `PRINCIPLES.md` has more problems than audit 1 surfaced
is taken. That pass was a bundle-driven accuracy check: citations, build-state,
graph integrity. It was not a review of whether the five principles are the
right five. This finding is the first item of that second kind, and there is no
queue entry for that pass yet.
