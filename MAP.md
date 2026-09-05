# The chirality tree map

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

On the basename alone, `mach` resolves three ways (`lowering/mach|x64|listing/`).
It was four, and `emit` resolved twice, until the C target was dropped. Taking
the path as the key means:

- the directory is the identity, not decoration;
- basename collision is unreachable rather than named. `ports/proc` and `proc` were
  the same key in the old tree; here they cannot be.

## `ports/` holds declarations, not code about ports

This is PRINCIPLES §3 applied to the tree. Programming here is coordinating
port boundaries and writing the logic that produces their inputs, so a
directory can name the declaration of a boundary. It cannot name a subject.

A file belongs in `ports/` iff it declares a crossing: an `extern` whose
implementation is bound at link time, or a `porttype` minting an opaque linear
atom. That is the same structural test the `.port` extension already carries,
pointed at the directory.

Being *about* ports does not qualify, and three files were in `ports/` for
exactly that reason. Each moved to the directory its own importers
already named:

| file | went to | because |
|---|---|---|
| `crossing-wraps` | `lowering/tal/` | both importers are `lowering/tal`, and its header says it is a leaf to dodge a tal-ir collision |
| `inet` | `protocol/` | its only importer is `protocol/http` |
| `term` | `protocol/` | 29 defs of terminal logic beside `vt-parser`, `apc`, `grid`, `render` |

None of the three declared a crossing. All three computed over crossings
declared elsewhere, which is what every other module in the tree does.

`ports/ports.chiral` declares nothing either and stays: it is the façade that
imports the nine registries, so `(import "ports/ports")` still names the whole
floor. That is a re-export, not a module about ports.

⚑ Nothing checks this. The rule is structural and could be a gate; today it is
prose, and prose is how the three got there.

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
    x64/  listing/        one directory per target
    ...        a new target lands in one new directory; nothing else moves
  ports/       where a crossing is DECLARED. Nothing else.
  capability/  what a held port is
  memory/      space as a port
  runtime/     running things
  protocol/    port-protocol data layers
  text/        matching and spans over Bytes
  evidence/    cross-checked truth
prog/          what chirality ships, as distinct from what it is
tools/         one folder per tool
/                  README.md · PRINCIPLES.md · MAP.md · CONTENTS.md, plus
                   LICENSE.md and LICENSE.EXCEPTION.md, plus CLAUDE.md for the
                   agent tier. A document at root is one a stranger or a tool
                   opens first; everything else sorts into a tier below.
                   Cleared: the three agent working files moved to
                   tracked homes, and PRINCIPLES-SLIM.md was cut as a condensed
                   twin of PRINCIPLES.md with nothing keeping the two in sync.
docs/
  index.md         the hub. Notes link by [[slug]], never by path, so a note
                   moves between roles without touching a single link.
  definitions/     one entry per named concept
  decisions/       one settled decision per entry, carrying its reason
  modules/         the module map, the module groups, the views
  banks/           the depth tier: one concept refracted into shards + homes
  examples/        CLOSED to new writes. 132 entries from the retired
                   worked-example pipeline; they fold into implementation/
  goals/           one per goal: what the project claims, which arcs serve it
  arcs/            one per arc: the goal, the requirements, the roster, the
                   resume state. Its measured history lives in records/
    parts/         one roster row worked up, before it has an element number
  elements/        the catalog, the ledger, and specs/ -- one per element.
                   A catalog row is written by the mint, at the end of design
  implementation/  the source tree described, as distinct from specified
  benchmarks/      measurements, with their dates
records/           one per arc: a claim beside its measurement, with a state.
                   NOT under docs/: docs/ is what a reader is handed, records
                   are what we measured. The one tier any agent may edit
.planning/         the agent tier: navigation, protocol, relational maps, queues,
                   handoffs, captures. Tracked, since the human
                   tier and the agent tier were split and both kept in git
                   (docs/decisions/decision-ai-tier.md). The element tier moved
                   to docs/elements/ the same day
```

## The doc tier sorts by role too

Source is individuated by kind (the extension) and placed by role (the
directory). Docs have one axis: a doc has no extension worth reading, so the
directory carries all of it. `decisions/` is not `definitions/` because a
decision is answerable and a definition is not; `banks/` is not `modules/`
because a bank is the refraction of one concept across many homes while a
module note describes one home.

`records/` is the mutable tier, and it sits outside `docs/` on purpose: `docs/`
is the tier a reader is handed, `records/` is what we measured about ourselves.
A record row is a claim this repo makes
about itself beside what was measured, carrying a state and a date. Every other
doc tier is written once and audited; a checklist is extended and amended in
place by whoever measures something. `records/README.md` states the row
format and the rules.

`records/` is not the agent tier. A record row is a claim beside a measurement
and its reader is a person. The agent tier is `.planning/`, `CLAUDE.md` and
`.claude/skills/`, and `docs/decisions/decision-ai-tier.md` draws the line.

## Goals, arcs, elements

Three tiers. A goal is a broad thing this project claims it is
doing. An arc is the list of work to be done for one goal, carrying that
goal's requirements as a roster. An element is one catalog item, an `E#`.

A roster row sits between the arc and the element. It is named when the arc
opens, cited as `<arc>/<id>`, and it becomes an `E#` only when its design passes
audit. `docs/decisions/decision-design-before-mint.md` settled that on
2026-09-05 and `docs/decisions/decision-work-ids.md` gives the id its stability
across the promotion.

`goals/` and `arcs/` are tracked because their reader is a person: a goal is
what the project claims and an arc is how it gets there.

They were made tracked for a narrower reason, now spent:
`.gitignore` excluded `.planning/`, so an element fact written there forked per
worktree. Two sessions minted `E173` independently and nothing caught it. The
whole agent tier is tracked as of the same day, so that reason no longer
distinguishes anything.

`elements/` holds `README.md` and nothing else. It is the tracked home for
element rows, and the shape of a row is an open author call: one file per
element, one per reserved band, or a single index. Underneath it sits the larger
question of whether the catalog and ledger move out of `.planning/` at all.
Element *status* does not originate there in any case: it comes from a
build-state authority, `docs/definitions/status-ledger.md`. The old tree kept ~171 status
lines by hand and grew the lint checks that exist to catch them drifting.

⚑ This paragraph replaced one that said `elements/` "is empty and stays empty
until something derives it", which was false from the day the first arc file
landed in it. `records/baseline-alignment.md` BA-18.
