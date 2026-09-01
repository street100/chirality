# .manifest — structure, and the pretty parser's configuration space

**Written 2026-09-01.** Design map for E163, ahead of its pre-run. Documentation,
not a handoff. Lane B's cross-lane asks live in `LANES.md`.

## The model

```
.manifest  →  pretty parser  →  upper chirality  →  tal  →  mach  →  machine code
.protocol  →       ↑↓
other      →  (one configuration per file type)
```

The pretty parser is the front end. It emits upper chirality **source**, so
`.manifest` ↔ source is text to text and auditable by reading. Below upper the
existing pipeline runs unchanged, including `preserve-check`.

One translator. Each file type is a configuration of it. No file type gets a
hand-written reader, which is what keeps them honest: a configuration's reader is
derived from the type declaration, so there is no second implementation to audit.

Types are carried across surface↔upper, upper↔tal and tal↔mach. Below tal is the
single trusted drop, which `axis-altitude` already states as the axiom.

## The three shapes

```
(module lowering/tal/target-linux (cat B) (alt tal))
(profile linux-x86-64)
(import "lowering/tal/sys-check")

; table: one constructor, header row, bare rows
(def linux-syscalls SyscallRegistry
  (: crossing            number   note)
  (nb-sys-read                0)
  (nb-sys-write               1)
  (nb-sys-close               3)
  (nb-sys-fcntl              72   "F_GETFD / F_SETFD")
  (nb-sys-winsz              16   "TIOCSWINSZ 0x5414")
  (nb-sys-ptsno              16   "TIOCGPTN 0x80045430"))

; record: fields by name
(def linux-target TargetProfile
  (architecture  "x86-64")
  (byte-order    little)
  (word-width    64))

; sum: tag leads, fields follow it, no header
(def ship-list (List ShipItem)
  (ship-prose  "docs/tal-spec.md")
  (ship-source "lib")
  (ship-tal    "lib (lowered)" "preserve-checked signatures per fn")
  (ship-genref "examples/refs"))
```

Parens stay. Alignment carries readability. Lists are variadic, so adding a row
touches one line.

`target-linux.manifest` ends today with 43 closing parens on one line. The sum shape
above is that file's `ship-list` with the cons chain removed.

## Six requirements

| # | Requirement | What forces it |
|---|---|---|
| 1 | Every entry carries its type | Seeds check mode. Without it elaboration is inference |
| 2 | A sum row leads with its constructor tag | `ShipItem` has 4 constructors, 3 are `(path Str)` alone |
| 3 | Constructors have named fields | `ctor-fields` is the only mechanical key source |
| 4 | Anything distinguishing two rows is a field | 7 rows carry `16`; only comments tell them apart, and `sexp.chiral` drops comments at the lexer |
| 5 | Type parameters closed by the ascription | Nothing else supplies them |
| 6 | The module coordinate | Says which layer the file is truth for |

Tag elision is allowed only for a single-constructor type. aeson's `UntaggedValue`
and serde's `untagged` resolve this first-match-wins in declaration order, which
aliases silently.

Requirement 4 is Unison's move: Unison drops comments on commit and promotes
documentation into the abstract syntax as a typed value.

## Derived rather than authored

| Thing | Source |
|---|---|
| The `(: ...)` header row | `ctor-fields`. Printer emits it, reader validates it, which catches a field reorder |
| Column alignment | The printer |
| Constructor name for a single-constructor type | The ascription |
| `cons` / `nil` | The list type |
| Single-field wrapper collapse | `SyscallRegistry` around a list adds a level and no information |

Field names are the type's own, verbatim. No transformation. `prog/manas/contract/manifest.chiral`
is 334 L of hand-written field-diggers and its `run-id` against `run_id` mismatch is
exactly the `fieldLabelModifier` knob this avoids.

## The pretty parser's configuration space

Configuration lives at the exit. E158's rule: a width is an argument to the exit,
never a field of the value. Denotation never moves.

| Axis | Values |
|---|---|
| exit | `doc->str`, `doc->rendering`, `doc->json` |
| width | integer |
| layout | table, one field per line, compact |
| header row | emitted or suppressed |
| display names | verbatim or styled (`Crossing  Number  Note`) |
| notes | own column, or trailing |
| ordering | declaration order, or sorted |

**A configuration is legal iff `read (show_c v) = v`.** The round-trip gate runs once
per configuration. A compact mode dropping the note column fails mechanically.

The scriba rendering is editable, confirmed 2026-09-01, for the ownership and access
model. So `doc->rendering` is an admissible configuration and owes the round trip.
A rendering may show nothing the file does not contain: a duplicate-value hint
computed over the value is legal, a hint sourced from outside it is not.

## Parser configuration versus file content

Ambient settings may fix what is admissible and what may be elided. They may not
change what a complete file denotes.

| In config | In the file |
|---|---|
| types in scope, admissibility rules, unknown-field rejection, numeric literal forms, escape set | byte order, word width, architecture |

The file names its profile instead of restating it. `(profile linux-x86-64)` keeps it
self-contained by reference.

Mechanically, profiles follow `sys-check` / `target-linux`: the mechanism is compiled
and frozen and knows no profile, profiles are values in an imported manifest, adding
one is a row plus `build-new → test → promote`. A file naming a profile the compiler
lacks is a named error, following `module extension collision`.

`(profile P (ports ...) (target T) (memory linear) (total))` already parses, gated by
Phase 4, 31 assertions. `(target Svc (require run (-> I64 I64)))` carries requirements
and holds no machine facts, so putting architecture there extends what a target is.

## The law

```
read_Σ (show_Σ v) = v          structural equality on Term, fixed Σ
```

Renounced in writing:

```
show_Σ (read_Σ s) = s          FALSE
```

False on four measured axes: whitespace, comments, elidable quantities
(`parse-binder` defaults to `2`), application spine spelling (`((f a) b)` and
`(f a b)` elaborate identically).

Replaced by quotient equality with a canonizer:

```
canon (show_Σ (read_Σ s)) = canon s
```

`fmt = show ∘ read` is idempotent. That is the formatter law and the only claim a
`.manifest` formatter should make.

⚑ The law is relative to a `Sig`. `t-con` and `t-tcon` carry a home module `dn`, the
surface has no qualified-constructor syntax, so `show` drops `dn` and `read` recovers
it from the `Sig`. Two modules exporting one constructor name breaks it.

## Built versus new

| Piece | State |
|---|---|
| `sexp.chiral`, 315 L | built. Errors as values, per-form offsets, comments dropped |
| `parse.chiral`, 1466 L | built. Closed error sum |
| `surface.chiral`, 321 L | built. Type-blind |
| `Field.fname`, `Ctor.cname` | built, `data.chiral:31-33` |
| `sig-data`, `ctor-fields` | built, `kernel.chiral:401,460` |
| `Doc` | built, E158 |
| `surface/pretty.chiral` | **built 2026-09-01**, E181. Phase 18 gates it on emitted bytes |
| `.manifest` resolution | built, `resolve.chiral:224-244` |
| A manifest checked as any def is | built. No separate loader, no untyped path |
| Type-directed elaboration | new |
| Schema-consulting printer over `Sig` | new |
| Admissibility predicate | new. `handle-kind` at `parse.chiral:1164` has no manifest clause, `lib/manifest/` does not exist |
| Sub-form positions | new |
| Round-trip gate and mutant | new |

The security half is done. What is missing is the minimal notation and the reverse
direction.

## Open

- **Escape hatch.** `show` over `Term` is total, so it needs a fallback arm or a
  carved-out `MTerm` for the admissible fragment. A fallback arm is the untyped hole
  the design forbids. `MTerm` costs a conversion and an injectivity argument.
- **Sub-form positions.** A refinement failure on row 27 of 40 reports the whole
  `def`. `FormPos` carries offsets for top-level forms only.
- **`t-ann` field order.** `(t-ann (tm Term) (ty Term))` against surface `(the ty e)`.
  A printer emitting declaration order produces a term that re-elaborates differently.
  One such case in `Term` today, and no gate would find a second.
- **String escaping.** `render.chiral:175-176` emits `\n \t \" \\` only. Whether
  `show` re-emits the same escape for the same byte is unchecked.
- **First-run diff churn.** `show ∘ read` rewrites all 43 payload lines of
  `target-linux.manifest`. Land the note-field promotion in a separate commit from the
  normalization.

## Sphere

The format expresses any inert value. Coverage is bounded by what interpreters exist
to read the data.

Reachable: permitted syscall set, bootstrap chain, checker rule table (`Spec` and
`SpecRule`, unpopulated in `kernel-core.chiral`), broker routing rules, state machine
transitions, protocol message layouts (E183), and a program in another language
(`sys-tal`, 64 defs of `(t-seq ...)` and `(ti-ret ...)`, flagged open in MAP.md).

Ceiling: the author never writes control flow. Conditionals and recursion live in the
interpreter. A file with no computation cannot do what the interpreter does not
already permit.
