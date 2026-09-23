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

## Amended 2026-09-02

A design session moved five things. The sections below stand as written except
where this block says otherwise.

**1. `.manifest` is a VIEW of an existing registry, and that is why it is
cheap.** `Sig` carries nine registries (globals, prims, datas, latoms, ldatas,
targets, profiles, kinds, sheets). A manifest feeds `globals`, whose entries are
`def`s; `.protocol` feeds `datas`. Neither needs the traversal to learn a new
slot, so neither adds a judgment. `.grammar` feeds none of the nine, which makes
it a new registry and a judgment in all but name; it is minted as **E190**
2026-09-02 and owes that argument before it owes an implementation.

**2. The round-trip law does a second job beyond formatting: it is the VIEW law.** `read (show
v) = v` is what separates a view of the term language from a second language you
translate to. A form that produces more than it shows cannot round-trip, so the
law decides the manifest-as-generator question by itself. See The law, below,
which stated the equation correctly and named it for the wrong job.

**3. The author's two guidelines, which permit fan-out.** Where the mechanic can
be conveyed plainly, the form carries a position naming it, so the fan-out is
visible in the file that causes it. Where the outcome is a judgement rather than
a mechanic, the author writes it and nothing generates it. `data` is the
precedent: it fans out into coverage, positivity, linearity and quantity, and
reads as regular because the form is declared to do that.

**4. The triple.** Everything is a question of what exists, what is allowed and
what happens, with `exists` containing `allowed` containing `happens`. `happens`
is derived and never authored, so a manifest is never a record of what a program
did. `.planning/FILE-KIND-STRUCTURES.md` holds the frame.

**5. Prior art says pure wiring works, and splits it three ways.** WIT's world is
"a complete description of both imports and exports of a component", and it
"only defines the surface of a component", leaving internal behaviour out.
CAmkES on seL4
is components, interfaces and connections, generating the glue rather than
containing it, and "the security policy is observed if communication can only
happen where it is explicitly allowed by the architecture". The seL4 stack keeps
**two** wiring layers, CAmkES ADL for the assembly and CapDL for the capability
distribution, and WIT adds a third question, one unit's own surface. Three
questions: what I need and offer, who is connected to whom, what authority each
starts with.

⚑ **The fork this opens, unresolved.** WIT and CAmkES are pure wiring because
their implementation language is a different language. This tree's premise is one
language and a manifest as a view of it. So either the wiring view is genuinely a
view of chirality terms and owes the round trip, or it is a second language and
the one-language claim weakens. Prior art took the second option and does not
carry this constraint.

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
| 4 | Anything distinguishing two rows is a field | **Seventeen of the forty `sys-row` entries** in `lib/lowering/tal/target-linux.manifest:22-61` share a number with another entry, across five groups: `0` three times, `1` twice, `16` seven times, `231` twice, `257` three times. Only comments tell them apart, and `sexp.chiral` drops comments at the lexer. **Seven of the seventeen carry no comment either** (`:22 :23 :30 :31 :32 :43 :46`), so those are distinguished by nothing in the file at all; three of the seven are `16`s, `nb-sys-winsz`, `nb-sys-tcgets` and `nb-sys-tcsets` at `:30-32`. ⚑ **Corrected 2026-09-23.** This cell read *"7 rows carry `16`"*, which counted one group and read as the whole. `FD-43` found the undercount and `.planning/protocol/dispatch.md` carries the same correction |
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

Field names are the type's own, verbatim. No transformation. `prog/prapanca/contract/manifest.chiral`
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

⚑ **Amended 2026-09-02: this law does a second job the section did not name.**
`read_Σ (show_Σ v) = v` is the condition that makes a kind a **view** of the term
language rather than a second language. A view is faithful by definition and a
generator is not, so a `.manifest` that elaborated into more than it shows would
fail the equation above. That is the whole argument against manifest-as-code-
generator, and it is already here.

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

- **The two existing manifests disagree about what a manifest may contain, and
  nothing rules.** Measured 2026-09-02. `lib/lowering/tal/target-linux.manifest`
  imports `lowering/tal/sys-check`, declares `(module lowering/tal/target-linux
  (cat B) (alt tal))`, and holds one `def` whose type comes from that import.
  `prog/climb.manifest` imports `prelude/prelude` and **declares three data types
  inline**, `ShipItem`, `Stage` and `Breaker`, before its three `def`s. So one
  manifest consumes a vocabulary and the other mints its own. Requirement 1
  ("every entry carries its type") is satisfied by both and says nothing about
  where the type came from. This decides whether a manifest can be purely about
  wiring: declaring a type is a different activity from wiring one thing to
  another, and `climb.manifest` does both in one file. Either the kind admits
  both and is a view of `globals` **and** `datas`, or the type declarations move
  and `climb.manifest` splits.
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
