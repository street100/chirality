---
node: arc-binary-split
layer: navigation
related: [arcs/README, goals/README, records/baseline-alignment, index]
status: draft
updated: 2026-09-01
---

# Arc: the binary split

- goal: [[goals/presentability]]
- reserved element block: **none**. Rows write `UNASSIGNED`.
- measurement this arc starts from: [[records/baseline-alignment]] BA-16 and
  BA-17.

TRACKED for the reason [[arcs/diagnostics-arc]] is.

## The goal

The field read `UNWRITTEN` until [[goals/presentability]] existed. The author
assigned it there: a text tool that ships the x64 backend and the ELF assembler
misrepresents the architecture to anyone who measures it, and an outside
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

## REQUIREMENTS, once a goal exists

Draft. Each is checkable.

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

## Duplicated facts

The closure table is copied from [[records/baseline-alignment]] BA-16. The
checklist row is the authority; this file repeats it so the arc reads on its own.
