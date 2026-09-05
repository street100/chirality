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
  arc keeps four letters instead of one, `C`, `E`, `H` and `A`, because the
  first three are the roster's in `.planning/DISPLAY-LAYER-GAP.md` and
  renumbering them would break every citation the roster already makes. ⚑ A
  row spelled `E1` here is arc-local, cited `display-calculus/E1`, and carries
  no claim on the element numbering. **`A` is the fourth letter, minted by the
  C01 EXAMPLE audit.** `A1` and `A2` measure reach into what already exists in
  the tree rather than propose a goal, so no lane in the roster fits them.
- build-state authority: [[status-ledger]]

Opened 2026-09-04 by author statement, as the first of five conditions under
[[goals/display]]. The done-condition: **style is a typed value resolved by
total functions, and a property holds in every reachable rendering.** The arc
covers the surface-independent machinery and the element vocabulary it attaches
to. Every property vocabulary belongs to a lane and stays out, per the author's
lane ruling in [[records/author-calls]].

## What is in the tree already

Measured 2026-09-04. **Six parts of a style system exist and none of them
carries a type.**

| part | where | today | the defect |
|---|---|---|---|
| the value | `render.chiral:38` | `(face (name Str) (fg I64) (bg I64) (attrs I64))` | SGR indices in a bare `I64` and attrs a bitmask. Zero invariants |
| the registry | `render.chiral:148-161` | a hardcoded assoc list, 11 entries | it lives in `lib/`, and 6 of the 11 are one application's palette, spelled `manas-*` |
| the attachment | `doc.chiral:83` | `d-tag` carries a `Str` | the keyspace is open. Any string is a key and no key is required to exist |
| the resolution | `render.chiral:164` | `lookup-face` | its `nil` arm at `:167` returns `(face name -1 -1 0)` and reports nothing |
| the cascade | `render.chiral:366` | `face-join` | attrs accumulate by bitwise or, the inner's stated colour wins, and a negative colour inherits. A real rule with no law and no check |
| the theme | `render.chiral:42-43`, `Mode`'s `faces` field | `init-loader.chiral:614-616` registers three modes, each carrying its own face list | `command-loop.chiral:96` destructures `((mode r faces))` and discards `faces`. A root-supplied theme already exists and reaches no consumer |

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
`lib/surface/pretty.chiral`. **Eight** faces reach a consumer through `r-face`:
six by a literal name at the call site (`comment`, `keyword`, `manas-header`,
`manas-ok`, `manas-bad`, `manas-field`), and two through a computed name:
`manas-tag` (`prog/scriba/init-loader.chiral:222`, registered at `:244`) and
`manas-cursor` (`prog/scriba/manas-mode.chiral:918`, also `:1002`). **Three
reach none: `default`, `string`, `error`.** A grep for `r-face "NAME"` finds
only the literal six; a name bound to a variable before the call does not
match that pattern, so a literal grep undercounts reach and the true orphan
count is three rather than the five such a grep reports. The registry and its
consumers have drifted apart in both directions and nothing reports it.

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
| `display-calculus/C1` | typed property values, invalid states unconstructible. `primitive` | **built, in one tier.** `lib/protocol/grid.chiral:12` is `Attrs`, six named `Bool`s over the closed `Color` sum at `:6`; E111, `built`. The C01 pre-run is `superseded`. The residue is a conversion to the emit side's `Face`, taken over by `docs/examples/C1C2-style-round-trip.md` (pre-run 2026-09-04) | `unminted` |
| `display-calculus/C2` | the cascade as a total ordered fold. `law` | **the fold is built and the law is unstated.** `apply-one` (`grid.chiral:215`) cases totally over `Sgr` and `fold-sgr` (`:232`) folds it in order. No gate feeds `face-sgr`'s bytes into it. The C01 pre-run is `superseded`; `docs/examples/C1C2-style-round-trip.md` (pre-run 2026-09-04) states the round-trip law | `unminted` |
| `display-calculus/C3` | attachment by a pure function over the node, no selectors and no specificity. `law` | not started; C1's example measures that this witness needs no conflict rule, without settling C3 itself | `unminted` |
| `display-calculus/C4` | the inherit sum wrapping every property value. `primitive` | not started. Covered by the C01 pre-run, which went `superseded` 2026-09-04; C1C2 does not take this row over. `Color`'s `color-default` (`grid.chiral:6`) is a default and `Face`'s `-1` is a sentinel, so neither is the constructor this row asks for | `unminted` |
| `display-calculus/C5` | design tokens as typed bindings, and a theme as a root-supplied value. Cashes the `Mode.faces` shard `render.chiral:42-43` already carries and `command-loop.chiral:96` discards. `primitive` | not started. Covered by the C01 pre-run, which went `superseded` 2026-09-04; C1C2 does not take this row over. [[banks/render]] shard V measures the theme value as `absent` | `unminted` |
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
| `display-calculus/A1` | the `Doc` to `Rendering` path is reached. `law` | measured 2026-09-04, and re-measured the same day: `grep -rn '"protocol/render-doc"' lib/ prog/` returns zero, and `dg-doc` (`lib/typing/diag.chiral:561`) has zero consumers outside its own file. ⚑ The scope is load-bearing. Two importers live under `tools/`, `tools/test/samples/e158_render.prog:58` and a heredoc probe at `tools/test/render-doc.sh:423`, and Phase 17 (`tools/test/run-tests.sh:268`) builds the first and runs it (`tools/test/render-doc.sh:110`). What this row asks for is a SHIPPING producer, and there is none. No `d-tag` in this tree reaches `lookup-face`. **Precondition for any C1 gate that can fail** | `unminted` |
| `display-calculus/A2` | `Mode`'s `faces` reaches the renderer. `law` | measured 2026-09-04: `command-loop.chiral:96` discards it. The shard C5 cashes | `unminted` |

The `kind` cell is the anti-monolith column of [[goals/display]]'s shape
condition. A row that cannot say which half it is has not been scoped.

## Resume state

### Checkpoint, 2026-09-04, session paused mid-pipeline

`C1C2` cleared every gate except the last. The pipeline stands at:

| stage | artifact | state |
|---|---|---|
| pre-run | `docs/examples/C1C2-style-round-trip.md` | `reviewed`, `f15e688` |
| example audit | same file | PASS, `f15e688` |
| SPEC | `docs/elements/specs/C1C2-style-round-trip-SPEC.md` | `audited`, `bf90ac6` |
| SPEC audit | same file | PASS, every execution claim reproduced |
| **implement** | `lib/`, `prog/`, `tools/test/` | **not started.** The run died at baseline capture on an API rate limit and wrote nothing. Working tree verified clean |

**Resume by re-dispatching the implementation of the SPEC's change plan.** It
needs no re-derivation: the SPEC's author ran steps 1 through 5 off-tree against
scratch copies, compiled with `bin/chirality-bin`, and the SPEC audit reproduced
all five claims independently in its own copy.

The one requirement that governs the run: **the gate root exits 1 on today's
unmodified tree and 42 after the two `parse-sgr` rows land.** Today's tree is
mutant 1. Demonstrate both, in that order, in the commit message. A run that
cannot show that transition has not built this element.

Baselines to capture first and compare after: suite 373 passed 0 failed with 88
compile-only roots and `gate PASSED`, Phase 16 at 38/0, Phase 17 at 20/0,
`registration.sh` at 9/0 with 13 dispatch lines and 20 scripts and 7 PEND. The
suite is memory-hungry on this box and [[status-ledger]] records it left
deliberately unrun once over OOM history, so run it whole at each end and run
only the affected phases between steps.

Two things the SPEC leaves to the implementer, both settled here.
`docs/elements/ledger.md` comes off the step 7 target list, because decision 5
declines to reopen E111's row and routes the residue to `records/gate-audit.md`
beside GA-25. And `banks/render:328` still enumerates the pre-correction tally,
13 plus 6 plus 1 running with J and K unreached, against a header that now reads
21 running and 1 unreached; step 7 makes the paragraph agree with the header.

Nothing in the change enters the compiler's blob, verified twice at 812,351
bytes over 17,335 lines, so it ships under a plain `chirality run` with no
fixpoint. Step 6 lands that as a checked gate row on `render-doc.sh:555-566`,
which is G9 plus its paired mutant M11. Re-verify on the real tree before and
after; if a needle enters the blob, stop and promote nothing.

Open and not blocking: the suite phase number is an author call carried in
[[records/author-calls]], so the gate ships `# not-a-phase:` and claims no suite
conformance. Two gate holes are measured and stated rather than closed. A
reorder of `face-params`' output disagrees on 0 of 14,256 probes while the
emitted bytes differ at character 3, so parameter order is guarded by nothing in
either tier. Narrowing the `bg` upper bound to `-1` drops the asserted set to
1,584 with exit 42 still, because every registry `bg` is `-1`.


The cell-lane pre-run ran 2026-09-04 as `docs/examples/C01-typed-style-value.md`
at `23f6830`, covering C1/C2/C4/C5 as one decision, on U13's precedent for a
run that covers more than one row. **It went `superseded` the same day at
`8928028`, and the replacement is `docs/examples/C1C2-style-round-trip.md`,
covering C1 and C2. It passed its example gate at `f15e688` and is `specced` at
`docs/elements/specs/C1C2-style-round-trip-SPEC.md`.** [[banks/render]] found the reason: C01 proposes
building a typed style value and a total ordered fold, and both are on disk.
`lib/protocol/grid.chiral:12` is `Attrs`, six named `Bool`s over the closed
`Color` sum at `:6`; `apply-one` (`:215`) cases over `Sgr` arm-per-arm with no
default clause and `fold-sgr` (`:232`) folds it in order. E111, `built`.

**The measurement that reshaped the rows.** `face-sgr` (`render.chiral:188`)
emits `ESC[3m` for attribute bit 4 and `parse-sgr` (`grid.chiral:201`) names 23
codes, code 3 among none of them, so 8 of the 16 attribute masks lose italic on
the way back. `fg` 10 through 17 emit `ESC[40m` through `ESC[47m` and decode as
a **background** change. Over `default-faces` the trip closes, because all
eleven entries sit in the sub-domain. So C1 and C2 own a conversion between two
built representations plus the law relating them, and C1C2 states it. C4 and C5
lost their pre-run with C01 and return to `not started`.

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

**`A1` is the precondition for any C1 gate that can fail.** No `d-tag` in this
tree reaches `lookup-face` today: `protocol/render-doc` has zero importers
under `lib/` and `prog/` and `dg-doc` (`lib/typing/diag.chiral:561`) has zero
consumers outside its own file. Its two importers are both under `tools/`,
so the reach it has is a gate fixture rather than a program a user runs. A gate that walks a theme's coverage over a `Role` sum nothing produces
would pass by looking at nothing, the same failure mode
[[decisions/decision-scope]] names for a subcommand dispatching to a floor the
tree lacks. `A1` closing is what makes a future C1 gate a gate rather than a
formality.

The measured coverage gap reproduces exactly: seven `d-tag` names, eleven
registry faces, zero overlap, three faces with no consumer once the two
computed-name reaches are traced (§ above). The example's `TUI/` grep is
corrected to `lib/ prog/`; the tree carries no `TUI/` directory today.

The design detail, the reference class per row and the full 59-row roster
this arc draws 17 rows from are `.planning/DISPLAY-LAYER-GAP.md`.

**`tools/pack/pack.py` has no adapter for this arc's rows.** It selects a
source adapter by element-id prefix, `E`, `U`, `S` or `N`
(`tools/pack/pack.py:27-37`); this arc's rows carry `C`, `E`, `H` and `A`, and
its own `E` prefix already names a different lane, core self-implementation.
The pre-run assembled its bundle by hand. The same prefix gate blocks `--mark
reviewed` (`tools/pack/pack.py:20`, `:462`, `:548`): the id regex refuses any
prefix outside `E`/`U`/`S`/`N` before `mark_mode` ever runs, so a `C`, `E`
(arc-local) or `H` row has no way to flip `drafted` to `reviewed` even after a
PASS. **This arc's pipeline has no deterministic finish, on a PASS or
otherwise.** `pack.py` is one of the seven Python tools already counted
against enforcement requirement 5's tooling surface
([[records/tooling-classification]] TC-11); [[arcs/enforcement-arc]] carries
the pointer to this gap. This is a fact about running this arc's pipeline.

**Suggested next element:** the SPEC audit of
`docs/elements/specs/C1C2-style-round-trip-SPEC.md` (`pipeline-audit` at SPEC
level), then implementation. The SPEC's change plan was executed off-tree in the
spec run and the gate root reached exit 42, so what the audit grades is citation
truth and gate soundness rather than feasibility. `pack.py` runs neither: its id regex refused
`C1C2` on 2026-09-04 with *"element id must look like E13 / U13 / S19 / N1"*,
which is the same prefix gate this section records below.

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
| what the seven emitted tags resolve to | requirement 4 checks a theme total against a role sum nobody has authored. The mapping, and the disposition of the three faces with no consumer, has to exist before coverage means anything |

**The staging risk this arc will not surface.** CSS carries specified, computed,
used and actual values because layout feeds back into style: a percentage width
needs the containing block and an `em` needs the parent's resolved size. The
roster assumes a single resolution pass before layout, and that assumption is
probably false. The cell lane cannot test it, because a character grid has no
percentages and no `em`. The row that surfaces it is `B5`, intrinsic sizing, in
the unopened geometry condition of [[goals/display]].
