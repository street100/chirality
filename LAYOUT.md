# chirality — the tree

Clean instance, built 2026-08-30. Not a rename of the old tree: a fresh repo laid
out to the shape the `E172` name map settled, with the language renamed from metis.

## Extensions — the file's KIND, checked by the resolver

| ext | kind | structural test |
|---|---|---|
| `.chiral` | module — importable computation | the default |
| `.prog` | program — has an entry, never an import target | defines the entry symbol |
| `.port` | port registry — mints capability types; where authority enters | declarations only, **zero lambdas**, ≥1 extern/porttype |
| `.profile` | profile — a named frozen port set | zero lambdas, zero externs, names a module set |
| `.manifest` | manifest — pure data; the replacement for JSON/TOML config | zero lambdas, zero externs |

**Extension = type. Directory = role.** Subject matter goes in neither — a module is
individuated by its type, not its topic, so there is no `stdlib/`, no `compiler/`.

⚑ **Ambiguity is a named error.** With one extension a basename could not be
ambiguous; with five it can (`foo.chiral` beside `foo.prog`). The resolver refuses it
by name rather than picking — the same rule that makes a basename collision an error
instead of a silent drop.

## Tiers

**Universal** — recurs in any chirality program: `prog` · `ports` · `capability` ·
`protocol` · `runtime` · `memory` · `evidence` · `lowering` · the base shelf.

**Language-implementation only** — `typing` · `surface` · `module`. A program has no
checker, parser or resolver and simply does not create these. The full taxonomy is a
**vocabulary to consult**, not a skeleton to fill: when a program grows a lowering
path or a port surface, the name already exists and is the same name the language
uses.

## The tree

```
lib/
  prelude/     the floor: the base shelf over the extern floor
  typing/      the judgment — what a type is and every check on it
  surface/     what you write, and how it is read
  module/      module identity, resolution, loading
  lowering/
    upper/     upper -> tal
    tal/       the typed-assembly floor
    mach/      the frozen contract + target-independent codegen
    x64/  c/  listing/      one directory per target
    ...        a new target lands in ONE new directory and nothing else moves
  ports/       the crossings themselves
  capability/  what a held port IS
  memory/      space as a port
  runtime/     running things
  protocol/    port-protocol data layers
  evidence/    cross-checked truth
prog/          what chirality ships, as distinct from what it is
tools/         one folder per tool
docs/
  examples/    one entry per code example
  definitions/ one entry per named concept + a dictionary map
  elements/    one entry per element: status, relationships, explanation
```

**The acceptance test for `lowering/`:** adding a target touches exactly one new
directory. If it touches two, the split is wrong.
