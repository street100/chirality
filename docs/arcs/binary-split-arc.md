---
node: arc-binary-split
layer: navigation
related: [arcs/README, goals/README, records/baseline-alignment, index]
status: current
updated: 2026-09-02
---

# Arc: the binary split

- goal: [[goals/presentability]]
- reserved element block: **none**. Rows carry arc-local ids `B1` and up, per
  [[decisions/decision-work-ids]], and map to `unminted` until a block exists.
- measurement this arc starts from: [[records/baseline-alignment]] BA-16 and
  BA-17.

TRACKED for the reason [[arcs/diagnostics-arc]] is.

## The goal

The author assigned this arc to [[goals/presentability]]: a text tool that
ships the x64 backend and the ELF assembler misrepresents the architecture to anyone who measures it, and an outside
evaluator measures it.

Two supporting arguments, neither of which is the goal: `MAP.md` says `prog/` is
what chirality ships as distinct from what it is, and documents `.profile` as a
named frozen port set.

## What was measured, on disk, 2026-09-01

Blob closures for the six top-level `.prog` roots, counted as `^(end-module "`
markers.

| root | modules | blob bytes |
|---|---|---|
| `prog/compiler.prog` | 58 | 772,967 |
| `prog/paren-audit.prog` | 58 | 783,086 |
| `prog/prose-lint.prog` | 58 | 780,557 |
| `prog/wield.prog` | 58 | 774,101 |
| `prog/test-runner.prog` | 61 | 865,722 |
| `prog/resolve.prog` | 15 | 68,429 |

`paren-audit` and `prose-lint` are text tools. They carry the whole compiler
including the x64 backend and the ELF assembler, because each imports
`lowering/compile-all` for `read-fd-all`, a ten-line fd reader. A tools tier of
`prelude/prelude`, `prelude/list`, `prelude/string`, `ports/fd`, `ports/stdio`
resolves to 6 modules and 27,222 bytes, measured with a probe root.

## The author's proposed split, unverified in this tree

Stated by the author. Five binaries:

| binary | modules |
|---|---|
| `chirality-tools` | 6 |
| `chirality-resolve` | 15 |
| `chirality-check` | 23 |
| `chirality-listing` | 44 |
| `chirality-x64` | 58 |

The 6 and the 15 reproduce against the measurements above. The 23 and the 44
have no source I could find in the tree, so they are recorded as stated and
dated. Re-measure before relying on them.

## REQUIREMENTS

Each is checkable.

1. **A text tool's closure contains no backend.** Measured as `^(end-module "`
   markers on its blob.
2. **One fd reader, one home.** `read-fd-all` lives where a tool can import it
   without importing the compiler.
3. **The `ports/ports` façade does not force the whole port floor.** Importing
   one crossing costs one registry.
4. **`.profile` has an instance and a consumer**, or the kind is withdrawn from
   `MAP.md`.
5. **Every binary reproduces itself** under the BUILD RULE, and the split does
   not cost the fixpoint.

## The four blockers

1. **`read-fd-all` lives inside the compiler's closure**, at
   `lib/lowering/compile-all.chiral:47`. It is a ten-line fd reader that every
   text tool imports the compiler to get. `lib/module/resolve.chiral:58-59`
   already names its own reader `slurp-fd` to dodge the resulting duplicate
   label, so someone has hit this and routed around it locally. That is BA-17.
2. **The `ports/ports` façade.** `lib/ports/ports.chiral` is 63 lines that
   re-export the nine registries, so `(import "ports/ports")` names the whole
   floor. `MAP.md:82-84` records it as a deliberate re-export.
3. **No root over `compile-front`.** There is no entry that stops at the front
   end, so a checker-only binary has no root to build from today.
4. **`compile-emit.chiral:295` appends unconditionally.**
   `(let (image (app-tfn native-lib (app-tfn link-lib obj)))` prepends the
   compiler's own compiled-in runtime to every image. A `native-lib` change is
   therefore only visible at GEN3: gen1 and gen2 compiling proves nothing. This
   cost one wrong fix on 2026-08-31.

## Also true

`.profile` is documented in `MAP.md` as one of the five kinds, with zero
instances in the tree and no consumer. `find . -name '*.profile'` returns
nothing, measured 2026-09-01. That is BA-10, and it is requirement 4 above.

## Roster

One row per blocker, in the order the measurement suggests. Groups are the
blockers named above, plus the build rule that gates them all.

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `binary-split/B1` | give `read-fd-all` a home a text tool can import without the compiler. Blocker 1, measured as `BA-17` | blocker-1 | primitive | connect | 2 | open | `unminted` |
| `binary-split/B2` | a way to import one crossing without the whole port floor. Blocker 2. `MAP.md` records the re-export as deliberate, so this is a design change | blocker-2 | port | new | 3 | open | `unminted` |
| `binary-split/B3` | a root that stops at the front end, so a checker-only binary has something to build from. Blocker 3 | blocker-3 | primitive | new | 1 | open | `unminted` |
| `binary-split/B4` | `.profile` gains an instance and a consumer, or the kind leaves `MAP.md`. Blocker 4, measured as `BA-10`. ⚑ **A consumer is proposed 2026-09-05: [[arcs/canvas-arc]] row `G3`**, where a canvas's port set is its border and the profile machinery already live at `kernel.chiral:60` and `compile-front.chiral:301` gets its first instance | blocker-4 | decision | new | 4 | open | `unminted` |
| `binary-split/B5` | the split binaries each reproduce under the BUILD RULE, through blocker 4's GEN3 trap. It gates the other four | build-rule | law | new | 5, presentability/req6 | open | `unminted` |

### Coverage

Every requirement is served: 1 by B3, 2 by B1, 3 by B2, 4 by B4, 5 by B5. Every
row serves one. `B1` is `connect` because `read-fd-all` is built and the gap is
where it lives; the other four are `new`.

## Resume state

**Where a session picks up.** B1. It is one ten-line fd reader, it is the reason
two text tools carry a backend, and `lib/module/resolve.chiral` already routes
around it with a second reader under another name.

**What blocks the arc.** No reserved element block, so every row above writes
`unminted` and none can be scheduled as catalog work. That is the author call
[[records/author-calls]] carries for the arcs with no band.

**A trap already recorded.** `compile-emit.chiral` prepends the compiler's own
compiled-in runtime to every image unconditionally, so a runtime change is
invisible until GEN3: gen1 and gen2 compiling proves nothing about it. That cost
one wrong fix on 2026-08-31, and B5 is measured through it.

**Two figures with no source.** The 23-module and 44-module binaries in the
author's proposed split reproduce nowhere in this tree. Re-measure before
building to them.

## Duplicated facts

The closure table is copied from [[records/baseline-alignment]] BA-16. The
checklist row is the authority; this file repeats it so the arc reads on its own.
