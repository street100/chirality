---
node: arc-display-calculus
layer: navigation
related: [arcs/README, goals/display, arcs/native-document-arc, arcs/native-window-arc, banks/module, decisions/decision-display-numerics, decisions/decision-work-ids, decisions/decision-scope, records/author-calls, status-ledger, index]
status: current
updated: 2026-09-04
---

# Arc: the style calculus

- goal: [[goals/display]]
- reserved element block: **none**. Rows carry arc-local ids per
  [[decisions/decision-work-ids]] and map to an element or to `unminted`. This
  arc keeps three letters instead of one, `C`, `E` and `H`, because the ids are
  the roster's in `.planning/DISPLAY-LAYER-GAP.md` and renumbering them would
  break every citation the roster already makes. ⚑ A row spelled `E1` here is
  arc-local, cited `display-calculus/E1`, and carries no claim on the element
  numbering.
- build-state authority: [[status-ledger]]

Opened 2026-09-04 by author statement, as the first of five conditions under
[[goals/display]]. The done-condition: **style is a typed value resolved by
total functions, and a property holds in every reachable rendering.** The arc
covers the surface-independent machinery and the element vocabulary it attaches
to. Every property vocabulary belongs to a lane and stays out, per the author's
lane ruling in [[records/author-calls]].

## What is in the tree already

Measured 2026-09-04. **Five parts of a style system exist and none of them
carries a type.**

| part | where | today | the defect |
|---|---|---|---|
| the value | `render.chiral:38` | `(face (name Str) (fg I64) (bg I64) (attrs I64))` | SGR indices in a bare `I64` and attrs a bitmask. Zero invariants |
| the registry | `render.chiral:148-161` | a hardcoded assoc list, 11 entries | it lives in `lib/`, and 6 of the 11 are one application's palette, spelled `manas-*` |
| the attachment | `doc.chiral:83` | `d-tag` carries a `Str` | the keyspace is open. Any string is a key and no key is required to exist |
| the resolution | `render.chiral:164` | `lookup-face` | its `nil` arm at `:167` returns `(face name -1 -1 0)` and reports nothing |
| the cascade | `render.chiral:366` | `face-join` | attrs accumulate by bitwise or, the inner's stated colour wins, and a negative colour inherits. A real rule with no law and no check |

**The coverage gap, measured 2026-09-04** by grepping `lib/` and `prog/` for
every emitted `d-tag` and `r-face` name against the registry. `TUI/` does not
exist in this tree; the terminal code the name pointed at lives at
`prog/scriba/`, already reached by the `prog/` half of the grep.

```
d-tag names emitted:  diag-head diag-site term-kw term-lit term-name term-qty term-var
faces defined:        comment default error keyword manas-bad manas-cursor
                      manas-field manas-header manas-ok manas-tag string
```

**Seven tags, eleven faces, zero overlap.** Every semantic tag the tree emits
resolves through the silent arm. The two emitters are the compiler's own
diagnostics, `lib/typing/diag.chiral`, and the term pretty-printer,
`lib/surface/pretty.chiral`. Six faces reach a consumer through `r-face`, and
five reach none: `default`, `error`, `manas-cursor`, `manas-tag` and `string`.
The registry and its consumers have drifted apart in both directions and
nothing reports it.

## What is missing

Grepped 2026-09-04 across `lib/` and `prog/`: zero hits for `theme`, zero for
`specificity`, and no declaration of a `Style`, `State` or `Length` data type.
The one `(data Env` hit is `EnvR` at `lib/ports/clock.port:28`, the process
environment. `cascade` appears four times and every one is a comment about
dropped-definition propagation in `lib/lowering/compile-back.chiral`.

## REQUIREMENTS

1. **A property value carries its invariant.** Every property is a sum whose
   invalid states have no representation, so a construction the vocabulary
   forbids fails the checker. The `Face` record's four bare fields are the
   baseline this replaces.
2. **The cascade is a total ordered fold with a stated law.** The order is
   decidable from the value, the fold is total, and the law is asserted in a
   gate that reddens when the fold changes. `face-join` is the rule that exists
   today with neither statement nor check.
3. **A role has no silent default.** Resolution is total over a closed role sum,
   so the silent-miss arm has no counterpart in the replacement. The seven tags
   above are the fixture: each one resolves to a named role or the build fails.
4. **A theme is a value a root supplies, and an incomplete one fails to
   compile.** The coverage check the compiler already runs on a closed sum is
   the whole gate. Done also evicts `manas-*` from `lib/`, which is checkable by
   the same grep that measured it.
5. **The every-state walk is a distinct mechanism from coverage, and it needs
   an interactive witness this arc has not chosen.** The phase enumerates the
   `(Env, State)` product and checks contrast, overflow, focus visibility and
   unstyled roles in each pair. Requirements 3 and 4 are the static check:
   a closed `Role` sum plus a total `Theme`, and the compiler's own
   exhaustiveness check is what finds the seven silently-resolving tags,
   because a theme omitting one of them fails to compile. The walk is a
   dynamic check over a state axis, and it needs a consumer that declares one.
   The cell-lane witness (`lib/typing/diag.chiral`, `lib/surface/pretty.chiral`)
   declares neither an `Env` nor a `State`, so its product is 1 and a walk over
   it would prove only that the phase runs. A meaningful instance needs an
   interactive consumer, and which one stands as its witness is an open author
   call ([[records/author-calls]]); `prog/scriba/` is the obvious candidate, on
   the evidence that the registry already carries a `manas-cursor` face for a
   navigable cursor row. ⚑ Its phase number is behind the standing
   suite-number call in [[records/author-calls]].

## Rows

| row | what | state | element |
|---|---|---|---|
| `display-calculus/C1` | typed property values, invalid states unconstructible. `primitive` | pre-run done, `23f6830`, `docs/examples/C01-typed-style-value.md`. Not yet audited | `unminted` |
| `display-calculus/C2` | the cascade as a total ordered fold. `law` | pre-run done, covered by C1's example (`23f6830`). Not yet audited | `unminted` |
| `display-calculus/C3` | attachment by a pure function over the node, no selectors and no specificity. `law` | not started; C1's example measures that this witness needs no conflict rule, without settling C3 itself | `unminted` |
| `display-calculus/C4` | the inherit sum wrapping every property value. `primitive` | pre-run done, covered by C1's example (`23f6830`). Not yet audited | `unminted` |
| `display-calculus/C5` | design tokens as typed bindings, and a theme as a root-supplied value. `primitive` | pre-run done, covered by C1's example (`23f6830`). Not yet audited | `unminted` |
| `display-calculus/C6` | the value expression algebra with the unit in the type. `primitive` | not started | `unminted` |
| `display-calculus/C7` | the environment as a declared ADT. `primitive` | not started | `unminted` |
| `display-calculus/C8` | state-driven style over a finite state sum. `law` | not started | `unminted` |
| `display-calculus/C9` | the every-state gate: a property checked in every reachable rendering. `tool` | not started; the cell-lane witness has no `Env`/`State` axis to walk, so this row waits on an interactive-consumer witness not yet chosen (resume state) | `unminted` |
| `display-calculus/C10` | resolution at compile time, as ordinary code the compiler evaluates. `law` | not started | `unminted` |
| `display-calculus/C11` | declared invalidation: the dependency is the argument list. `law` | not started | `unminted` |
| `display-calculus/C12` | shorthands as constructors that cannot reach an unnamed field. `primitive` | not started | `unminted` |
| `display-calculus/E1` | closed element sums per context, so invalid nesting is unconstructible. `primitive` | not started | `unminted` |
| `display-calculus/E2` | the semantic role as a required constructor field. `primitive` | not started | `unminted` |
| `display-calculus/E3` | the accessibility tree derived by a total function. `law` | not started | `unminted` |
| `display-calculus/E4` | every document has a text form, and nothing renders from it. `law` | not started | `unminted` |
| `display-calculus/H6` | the property walk, run as a suite phase. `tool` | not started; same witness gap as C9, which it instantiates | `unminted` |

The `kind` cell is the anti-monolith column of [[goals/display]]'s shape
condition. A row that cannot say which half it is has not been scoped.

## Resume state

The cell-lane pre-run ran 2026-09-04: `docs/examples/C01-typed-style-value.md`
at `23f6830`, covering C1/C2/C4/C5 as one decision, on U13's precedent for a
run that covers more than one row. Not yet audited.

The three owed measurements came back, and none killed the design outright,
though one sharpens a claim the arc states more strongly than it holds. The
`(Env, State)` product for the cell lane's two witnesses
(`lib/typing/diag.chiral`, `lib/surface/pretty.chiral`) is **1**: neither
declares an `Env` or a `State` axis, so C9's every-state walk would prove
only that the tool runs; convicting anything needs a bigger product. A
meaningful instance of C9/C8 needs an interactive consumer, out of this
witness's reach. **H1's "one style value drives both `Doc` and `Rendering`" is
narrower than written**: `d-tag`'s field stays `Str`, blocked by a stated
layering rule rather than only by cost. `lib/prelude/doc.chiral:13-16`:
*"`Doc` depends on nothing but Str/List/I64 and is needed by `typing/` (the
diagnostics renderer), by `protocol/` (the display exit) and by `prog/`. That
is 'the base shelf over the extern floor'."* Retyping `d-tag`'s field would
force that shelf to import a `protocol/`-tier type, independent of the BUILD
RULE fixpoint cost. What actually drives both ends is one closed `Role` sum,
projected as a bare string at the frozen `d-tag` seam and carried typed
everywhere `protocol/render` is free to type it (measured: `protocol/render`
sits outside the compiler's blob, `render-doc.chiral:19-24`). Attachment for
the seven tags needs no conflict rule: 35 call sites inside two ordinary
printer functions each choose at most one role by direct code, and nesting is
cascade rather than a race between two attachment functions, so D2 survives
unchanged.

**What this closes and what it does not.** Requirement 4's coverage closes on
the theme side: `Theme = (-> Role Style)` over the closed seven-plus-one-arm
`Role` sum, and an incomplete theme is a compiler refusal. It does not close
on the emission side: nothing stops a stray `d-tag` string literal elsewhere
in the tree from naming a role the closed sum has no arm for, because
`d-tag`'s field stays the open `Str` it is today. `rl-unknown` is the design's
answer, a named and loudly-styled failure state (reverse video in
`compiler-theme`) replacing the silent fabrication at
`lib/protocol/render.chiral:167`. That is an improvement over a fabricated
default, and the compiler's refusal stops at the theme.

The measured coverage gap reproduces exactly: seven `d-tag` names, eleven
registry faces, zero overlap, five faces with no consumer. The example's
`TUI/` grep is corrected to `lib/ prog/`; the tree carries no `TUI/`
directory today.

The design detail, the reference class per row and the full 59-row roster
this arc draws 17 rows from are `.planning/DISPLAY-LAYER-GAP.md`.

**`tools/pack/pack.py` has no adapter for this arc's rows.** It selects a
source adapter by element-id prefix, `E`, `U`, `S` or `N`
(`tools/pack/pack.py:27-37`); this arc's rows carry `C`, `E` and `H`, and its
own `E` prefix already names a different lane, core self-implementation. The
pre-run assembled its bundle by hand. `pack.py` is one of the seven Python
tools already counted against enforcement requirement 5's tooling surface
([[records/tooling-classification]] TC-11). This is a fact about running this
arc's pipeline.

**Suggested next element:** C1's example audit (`pipeline-audit`), then a
SPEC for C1/C2/C4/C5 together.

**The one experiment is the cell-lane element**, which instantiates C1, C2, C4,
C5 and the `Rendering` half of the seam against the terminal surface. It is one
experiment because it tests four unproven claims at once:

1. the state sum is finite and walkable;
2. attachment by function composes without specificity;
3. a theme's coverage is a compile-time check;
4. one style value drives both `Doc` and `Rendering`.

Three measurements are owed inside its pre-run, and each one can change the
shape:

| owed | why it decides something |
|---|---|
| the size of the `(Env, State)` product for the cell lane | requirement 5 walks it. Nothing has measured either sum, and a walk over an unbounded product cannot be a phase |
| the import closure a typed tag moves | `prelude/doc` is imported at `lib/typing/diag.chiral:58`, `lib/surface/pretty.chiral:36` and `lib/protocol/render-doc.chiral:105`, and two of the three are compiler modules. Retyping `d-tag`'s key owes a fixpoint. Deriving the registry from a role sum outside `doc.chiral` may buy the same property with no compiler change |
| what the seven emitted tags resolve to | requirement 4 checks a theme total against a role sum nobody has authored. The mapping, and the disposition of the five faces with no consumer, has to exist before coverage means anything |

**The staging risk this arc will not surface.** CSS carries specified, computed,
used and actual values because layout feeds back into style: a percentage width
needs the containing block and an `em` needs the parent's resolved size. The
roster assumes a single resolution pass before layout, and that assumption is
probably false. The cell lane cannot test it, because a character grid has no
percentages and no `em`. The row that surfaces it is `B5`, intrinsic sizing, in
the unopened geometry condition of [[goals/display]].
