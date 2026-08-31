# The chirality tree

## Extensions

The extension is the file's kind. The resolver checks it.

| ext | kind | structural test |
|---|---|---|
| `.chiral` | module, importable computation | the default |
| `.prog` | program with an entry | defines the entry symbol |
| `.port` | port registry, mints capability types | declarations only, zero lambdas, at least one extern or porttype |
| `.profile` | a named frozen port set | zero lambdas, zero externs, names a module set |
| `.manifest` | pure data, the replacement for JSON/TOML config | declared in the file, not derived |

Extension is the type, directory is the role. Subject matter is neither, so there is
no `stdlib/` and no `compiler/`.

## Importability

`.chiral`, `.port` and `.manifest` are import targets. The other two are not:

- a `.prog` defines an entry, and two entries in one blob is a duplicate label;
- a `.profile` names a module set, which the build consumes and nothing imports.

Two consequences:

- the resolver probes three extensions, not five, and the 177 programs never enter
  the resolution space;
- extension ambiguity is not a new collision class. `foo.chiral` beside `foo.port`
  is the existing basename collision, already a named error.

## Manifests are declared

A manifest is a module whose every `def` body is a literal value: constructor
applications and literals. No `lam` and no computation.

That is a property of term structure, not of lines, so the resolver cannot see it.
Only the loader holds the terms. The kind is therefore declared in the file and
checked by the loader, the same way `.prog` is a checked projection of
`compile-main`.

Open: whether a program in another language written as data is a manifest or needs a
further clause. `sys-tal` is the case, its 64 defs being `(t-seq ...)` and
`(ti-ret ...)` constructor applications.

## The module key is the root-relative path

Write `(import "lowering/x64/mach")`, not `(import "mach")`.

On the basename alone, `mach` resolves four ways (`lowering/mach|x64|c|listing/`)
and `emit` twice. Taking the path as the key means:

- the directory is the identity, not decoration;
- basename collision is unreachable rather than named. `ports/proc` and `proc` were
  the same key in the old tree; here they cannot be.

## The two binaries

- `bin/chirality` is the CLI front door: `compile`, `run`, `check`, `test`.
- `bin/chirality-bin` is the compiler: a blob on stdin, an ELF on stdout.

## Tiers

| tier | directories |
|---|---|
| universal | `prog` `ports` `capability` `protocol` `runtime` `memory` `evidence` `lowering`, and the base shelf |
| language-implementation only | `typing` `surface` `module` |

## The tree

```
lib/
  prelude/     the base shelf over the extern floor
  typing/      what a type is, and every check on it
  surface/     what you write, and how it is read
  module/      module identity, resolution, loading
  lowering/
    upper/     upper to tal
    tal/       the typed-assembly floor
    mach/      the frozen contract and target-independent codegen
    x64/  c/  listing/      one directory per target
    ...        a new target lands in one new directory; nothing else moves
  ports/       the crossings themselves
  capability/  what a held port is
  memory/      space as a port
  runtime/     running things
  protocol/    port-protocol data layers
  evidence/    cross-checked truth
prog/          what chirality ships, as distinct from what it is
tools/         one folder per tool
docs/
  examples/    one entry per code example
  definitions/ one entry per named concept, plus a dictionary map
  elements/    one entry per element: status, relationships, explanation
```
