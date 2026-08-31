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
| `.manifest` | manifest — pure data; the replacement for JSON/TOML config | **DECLARED, not derived** — see below |

**Extension = type. Directory = role.** Subject matter goes in neither — a module is
individuated by its type, not its topic, so there is no `stdlib/`, no `compiler/`.

## Importability — the partition that does the work

Two of the five kinds are **not import targets**, by definition rather than by rule:

| | importable | why |
|---|---|---|
| `.chiral` `.port` `.manifest` | **yes** | ordinary modules, port registries, and data a module reads |
| `.prog` | **no** | an entry cannot be imported — two entries in one blob is `duplicate label`. Measured: no entry is imported anywhere in the tree |
| `.profile` | **no** | a profile names a module set; the build consumes it, nothing imports it |

**Consequences, all of them free:**

- The resolver probes **three** extensions, not five, and **44% of files (the 177
  programs) never enter the resolution space at all.**
- **Extension ambiguity is not a new collision class.** `foo.chiral` beside
  `foo.port` is the *existing* basename-collision rule — same key, different identity,
  already a named error, not a silent drop. Nothing new to build.
- `.profile`'s cosmetic clash with the shell's `~/.profile` cannot reach resolution,
  because a profile is never resolved by name. It is an editor-highlighting concern
  only, and the editor's mode registry is ours.

This is the P4 move: the bad states are **unrepresentable** rather than detected. An
earlier draft of this file made ambiguity a new named error and had the resolver
probing all five — both were solving problems the partition removes.

## `.manifest` is declared, and the module key is the path

**`.manifest` cannot be sniffed.** The working shape is crisp — *a module whose every
`def` body is a literal value: constructor applications and literals, no `lam`, no
computation* — and `target-linux` (one def, a list of `(sys-row "nb-sys-openat" 257)`)
and `climb` (*"this file is that chain as data"*) both satisfy it. But it is a property
of **term structure, not of lines**, so a resolver grep cannot see it; only the loader,
which has the terms, can. A first attempt at a line-based test caught nine files, of
which two were manifests: the other seven were ADT-declaration modules (`(data …)` with
no defs) and `sys-tal`.

So the kind is **declared in the file and checked by the loader**, exactly as `.prog` is
a checked projection of `compile-main`. `E163` owns the declared form — and
⚑ **`sys-tal` is evidence for it, not a counter-example**: its 64 defs are `(t-seq …)` /
`(ti-ret …)` constructor applications, i.e. hand-authored tal functions *written as
data*, which genuinely satisfies the working shape. Whether "a program in another
language, as data" is a manifest or needs a further clause is E163's question.

## The module key is the ROOT-RELATIVE PATH

`(import "lowering/x64/mach")`, not `(import "mach")`.

Forced by measurement: dropping the affix a directory now carries yields **`mach` four
times** (`lowering/mach|x64|c|listing/`) and **`emit` twice**. Both resolvers previously
keyed on the post-slash basename, which makes those ambiguous.

The alternative was to keep affixes on exactly those six files — reintroducing the
redundancy this tree removed, inconsistently, only where forced. Taking the path as the
key instead means:

- **the directory is load-bearing rather than decorative** — it *is* the identity;
- the basename-collision class becomes **unreachable** rather than merely named. The old
  tree's collision error exists because `ports/proc` and `proc` were the same key; here
  they cannot be.

## The two binaries

`bin/chirality` — the CLI front door (`compile` · `run` · `check` · `test`).
`bin/chirality-compile` — the compiler: a blob on stdin, an ELF on stdout.

⚑ **No `-c` suffix.** `metisc`/`rustc`/`javac` name a *mechanism* and exist because a
flat `$PATH` had to distinguish the language from its compiler. Here `prog/` makes that
distinction structurally, and this tree's rule is **name the type, not the mechanism** —
so the compiler is spelled out. `chiralc` would also have been built from the adjective
while the language is `chirality`.

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
