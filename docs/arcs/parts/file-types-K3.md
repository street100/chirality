---
row: file-types/K3
arc: file-types
title: `<name>.m.gram`: the surface syntax as a declared signature. Minted 2026-09-02 from this arc's own band, having been named a whole session with no row
kind: primitive
origin: new
req: 4, 6
status: blocked
updated: 2026-09-23
---

# file-types/K3: `<name>.m.gram`: the surface syntax as a declared signature. Minted 2026-09-02 from this arc's own band, having been named a whole session with no row

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** a declared grammar becomes a checked file kind, with its reader
  derived from the declaration and a named gate that runs, or the arc records in
  writing why it should not.
- **Serves:** requirement 6 of [[arcs/file-types-arc]], "`<name>.m.gram` either
  exists as a checked kind or the arc records why it should not. E190, minted
  2026-09-02. It is the one proposed kind that is a **new registry** rather than
  a view of an existing one, so it adds a judgment in all but name, and the
  argument for that comes before any implementation."
  ([`docs/arcs/file-types-arc.md:46-49`](../file-types-arc.md)). Requirement 4,
  the round-trip gate with a named mutant that is actually run, reaches one of
  the two positions this design separates and fails on the other.
- **Goal:** [[goals/readable-surface]], condition 4, regularity at the surface,
  whose three named instances are file kinds, syntax and the error vocabulary.
  [[goals/self-tooling]] takes the same row as material.
- **Three rulings of 2026-09-23 constrain the row before it starts**, and each is
  read off [[records/author-calls]] rather than off this artifact:
  `records/author-calls.md:56` names the kind `<name>.m.gram` instead of a flat
  `.grammar`; `:58` fixes the join point as an optional `{parse ->}` stage in
  front of upper, always `upper -> lower -> binary` below it; `:59` rules that a
  declared grammar is two functionally distinct positions and that the
  derivation rule survives in both.

## 2. What the tree holds

Measured 2026-09-23 unless a row dates itself otherwise.

- **Bank:** no bank carries "grammar" or "file kind" as its concept.
  `docs/banks/INDEX.md` lists thirteen rows and none of them is either. The two
  shards this row needs are already held: the program-facing grammar is shard D
  of [[banks/text]] (`docs/banks/text.md:50`, "the matcher, returning spans",
  E173), and the file-kind machinery is the module coordinate in
  [[banks/module]] (`docs/banks/module.md:79`). Both homes are occupied, so no
  phantom is at risk here. A `grammar` bank is owed if and only if §5's split
  lands, and it is not this run's artifact.

| what exists | where | rung | reached by |
|---|---|---|---|
| **a grammar as a value**: `Cls`, five constructors, and `Pat`, seven constructors, a pattern language held as data | `lib/text/matcher.chiral:24`, `:92`; the module is 602 lines, 41 defs, 25,732 bytes | ENFORCED | `prog/prose-lint.prog:43` imports it. Gated at Phase 19 by `tools/test/matcher.sh`, 18 assertions and 12 mutants, `docs/definitions/status-ledger.md:165` |
| **the interpreter that discharges the derivation rule below the floor**: `pd` the Antimirov residual at `lib/text/matcher.chiral:139`, `find-all` the one-pass scan at `:499`, `count-matches` over it at `:502` | the three defs above, all pure, category A, `(module text/matcher (cat A) (alt upper))` at `:18` | ENFORCED | the same Phase 19 gate |
| **grammars written by hand today**: 60 `Pat` and `Cls` constructor applications, every one of them a literal value with no `lam` | `prog/prose-lint.prog:72-115`, which is 44 lines holding 58 `Pat` and 2 `Cls` applications, counted 2026-09-23; further grammar values run on past `:115` | IMPLEMENTED | `prose-lint` itself |
| **no notation and no printer for `Pat`**: the module's 41 defs hold neither a reader from text into `Pat` nor a `show` out of it | `lib/text/matcher.chiral`, def census read 2026-09-23 | absent | nothing |
| **the compiler's own reader, hand-written**: the s-expression reader, the elaborator and the toplevel dispatch | `lib/surface/sexp.chiral` 315 lines / 47 defs, `lib/surface/surface.chiral` 321 / 30, `lib/surface/parse.chiral` 1466 / 81 | IMPLEMENTED | `docs/definitions/status-ledger.md:181`, live in every compile through `lib/lowering/compile-front.chiral` |
| **`Sig` has nine registries**: globals, prims, datas, latoms, ldatas, targets, profiles, kinds, sheets | `lib/typing/kernel.chiral:228-238` | ENFORCED | every compile |
| **`kinds` is not a file kind**: it holds `ModKind`, the `(cat A\|B\|C) (alt upper\|tal\|metal)` coordinate | `lib/typing/kernel.chiral:224`; installed by `handle-kind`, `lib/surface/parse.chiral:1166`, dispatched at `:1292` | ENFORCED | `docs/banks/module.md:79` |
| **the reflective floor**: a runtime's judgment is "staged-in, never granted-to, and not swappable after staging completes", and a judgment change is a fine-grained certified succession | `docs/decisions/decision-reflective-floor.md:27-28`, `:46-50` | DESIGNED | E45 names the freeze mechanism |
| **the differential gate the above-floor position would need**: two front-ends, one `Sig`, diffed over 198 `.chiral` files, with the s-expr side golden until the author retires it | `docs/arcs/surface-syntax-arc.md:157`, row `surface-syntax/SY4`, state `open`, element `unminted` | DESIGNED | its second front-end is `SY3`, itself blocked on `SY1` at `:154` |
| **the corpus that gate would run over**: 198 `.chiral` files under `lib/` and `prog/` | counted 2026-09-23 | measurement | the gate at `surface-syntax/SY4` |
| **the resolver cascade and its named refusal**: one `open-ext` probe per importable extension, one `open-ambig` arm per pair, `re-ext-collision` declared and raised | `lib/module/resolve.chiral:218-245`, `:123`, `:269`; the shell provider states the same rule at `bin/chirality-resolve.sh:58-62` | ENFORCED | every import |
| **the extension contract**: five kinds, three of them importable, "the extension is the file's kind. The resolver checks it." | `MAP.md:5`, `:13`, `:20` | ENFORCED | `MAP.md` is the tree contract |
| **the kind legitimacy test**: a kind is legitimate when what it declares is discharged by the signature rather than by a judgment added to the core, and a kind needing a new registry is a new judgment in all but name | `.planning/FILE-KIND-STRUCTURES.md:73-76` | DESIGNED | the test E190's cell applies |
| **the VIEW law and the ceiling**: `read (show v) = v` separates a view of the term language from a second language, and the author never writes control flow because conditionals and recursion live in the interpreter | `.planning/MANIFEST-DESIGN-MAP.md:38-40`, `:285-287` | DESIGNED | requirement 4 is this law |
| **E190 as minted**: one element, "the surface syntax as a declared signature, with the reader derived from it" | `docs/elements/catalog.md:502`, `docs/elements/ledger.md:323` | design | `docs/arcs/file-types-arc.md:46-49` |
| **the band**: `E190-E195` is Lane B's, and `E190` is the only number in it that is spent | `docs/decisions/decision-lane-split.md:31`, `:193`; a grep for each of the band's six numbers over the catalog and the ledger returns `E190` alone | measurement | §6's band |

**Two claims in E190's own cells are false against the rows above.**

1. `docs/elements/catalog.md:502` calls `<name>.m.gram` "the only one of the
   three with no seed in the tree". `lib/text/matcher.chiral` is a seed for the
   program-facing position: a grammar held as a value, with total pure functions
   over it, imported by a shipping program and gated at Phase 19.
2. The same cell argues that "a grammar feeds none of them, so the traversal
   must learn to consult a tenth". Below the floor that is wrong by
   construction: `Cls` and `Pat` are ordinary `(data ...)` declarations feeding
   `datas`, and `prog/prose-lint.prog:72-115` holds the grammar values in
   `globals`. `docs/elements/ledger.md:323` carries both claims in the same
   words.

**The line that separates the two positions already exists under another name.**
`docs/decisions/decision-reflective-floor.md:27-28` puts the judgment's
immutability at the small trusted core. A grammar a program applies to input
sits below that line and is data. A grammar the front end reads source with sits
inside the judgment, because it decides what a source file denotes.

## 3. The delta

The delta is a single kind covering two positions whose gates do not compose.

**The program-facing position is short one artifact.** The concept is built. The
value language, the interpreter over it and the gate all exist and are ENFORCED
(`lib/text/matcher.chiral:24`, `:92`, `:139`, `:499`;
`docs/definitions/status-ledger.md:165`). What is absent is the file kind
itself: a notation the `{parse ->}` stage of [[records/author-calls]] the join-point ruling reads,
a `show` back out of `Pat`, and the round trip `read (show v) = v` closing on
the value, which is requirement 4. Today a grammar is 60 constructor
applications inside a program (`prog/prose-lint.prog:72-115`, 44 lines), which is already
the `.m.conf` shape of requirement 1 and reaches no separate kind. The delta
over `file-types/K1` is exactly the notation plus its derived reader.

**The compiler-facing position is short an argument, and the argument it owes is
not the one E190 states.** E190's cell leads with a tenth registry
(`docs/elements/catalog.md:502`). That is the weaker objection, and it evaporates
below the floor where the same declaration feeds `datas`. The cost that does not
evaporate is that the grammar is the referent. Nothing internal can gate it:
`read (show v) = v` presupposes a fixed reading of the source, and here the
reading is the thing under test. The only gate available is differential against
the existing reader, which is `surface-syntax/SY4`
(`docs/arcs/surface-syntax-arc.md:157`), a row that is `unminted`. That row
carries **no blocking condition for the harness** and says both halves it joins
are built; what is missing is its second front-end, `SY3` at `:156`, which is
blocked on `SY1` at `:154`. Until `SY3` lands the harness runs one surface
against itself, which is what the row calls its acceptance test and is not a
differential against anything.

**So requirement 4 is unsatisfiable for one of the two positions**, and
requirement 6's framing, one kind whose cost is a new registry, is wrong in both
halves at once: too strong below the floor and off-target above it.

**Verdict:** a real delta, and the row splits at the reflective floor into two
rows with different obligations, different gates and different deliverables.

## 4. The shapes

### Shape A: one kind, one element, as E190 stands
- **Form:** `<name>.m.gram` is a single checked kind. The declaration is a
  grammar; the derived artifact is a reader. One catalog row, one conformance
  gate.
- **Costs:** the one gate has to be picked from two that do not overlap. Choosing
  the round trip ships a kind whose stated headline use, the compiler's own
  surface, cannot pass it, because the grammar is the referent (§3). Choosing
  the differential binds the whole kind to `surface-syntax/SY4`, which is
  `unminted`. Its harness carries no blocking condition
  (`docs/arcs/surface-syntax-arc.md:157`); its second front-end is `SY3` at
  `:156`, blocked on `SY1` at `:154`. So until `SY3` lands the gate runs one
  surface against itself and decides nothing about the program-facing half,
  whose own ENFORCED seed sits at `lib/text/matcher.chiral:24` with no kind
  over it.
- **Forbids:** shipping either half independently, and that is not wanted.

### Shape B: two rows split at the reflective floor
- **Form:** two elements. **Below the floor**, `<name>.m.gram` is a checked kind:
  a grammar notation, a reader derived from the declaration, a `show`, and
  requirement 4's round trip closing on the `Pat` value. It feeds `datas` and
  `globals`, adds no registry, and passes the legitimacy test at
  `.planning/FILE-KIND-STRUCTURES.md:73-76` on the same terms `.port` passes it.
  **Above the floor**, the compiler's own grammar is a separate element whose
  deliverable is the argument requirement 6 already admits as the alternative,
  with the shape the floor gives it: staged in at build time and changed only by
  certified succession is consistent with
  `docs/decisions/decision-reflective-floor.md:27-28` and `:46-50`; a runtime
  consultation to decide how to parse is not. Its only gate is differential, so
  it names `surface-syntax/SY4` as the gate it would need and does not pretend to
  hold one.
- **Costs:** two catalog rows, two ledger rows, and a rework of E190's cells,
  which state the superseded reading in both places. A `grammar` bank becomes
  owed, because the concept now has shards in two homes.
- **Forbids:** a single conformance gate over both positions, which §3 shows is
  not available anyway. It also forbids the below-floor kind from being read by
  the compiler's own front end, which is the point of the floor.

### Shape C: one kind, two facets discriminated inside the file
- **Form:** one `<name>.m.gram` kind carrying a clause that says which side of
  the floor it sits on, with the loader selecting the gate from the clause.
- **Costs:** it puts the floor inside a file the loader reads, which is the
  thing `docs/decisions/decision-reflective-floor.md:27-28` forbids by making
  the judgment not swappable after staging. It also collides head-on with the
  the `unreviewed` module-key call in [[records/author-calls]], because a facet
  set is exactly the arm of that call which is not yet chosen, so this shape
  cannot be drawn until the author rules.
- **Forbids:** nothing useful. It buys one catalog row and spends a decision the
  author has not made.

### Shape D: close the row, record why the kind should not exist
- **Form:** requirement 6's own alternative. The arc writes the argument against
  and mints no kind.
- **Costs:** it discards a seed that is ENFORCED
  (`docs/definitions/status-ledger.md:165`) and a use that is live
  (`prog/prose-lint.prog:43`, 60 hand-built constructor applications at `:72-115`).
- **Forbids:** the program-facing kind, on the strength of an objection that only
  holds above the floor. Rejected by §2's measurement.

### Shape E: one element, two slices
- **Form:** `E190` stays one element and ships in slices, the below-floor kind
  first and the compiler-facing argument second. The tree can express this: the
  ledger carries a slice qualifier inside a state cell already, `E173` reading
  `**BUILT 2026-09-01** (slice 1)` at `docs/elements/ledger.md:325` with
  captures named as unbuilt slice 2 at `docs/banks/text.md:50`.
- **The tree settles this one.** [[records/author-calls]] the grammar-split ruling rules that under
  the two-position reading "the element splits". A slice is one deliverable
  staged; the two halves here differ in kind, the below-floor half owing code
  and a gate and the above-floor half owing a document before it owes any code
  (§5 question 3), and a document slice sits on none of the four rungs.
- **Forbids:** citing either half alone, which the same ruling asks for.

### Shape F: defer the row until `surface-syntax/SY1` is ruled
- **Form:** no element moves until the stage-4 surface fork is settled, on the
  reading that a declared grammar is the thing that ruling picks.
- **The tree settles this one too.** [[records/author-calls]] the join-point ruling closes it by
  name: the kinds are independent of the surface-syntax fork, joining above
  upper does not require the kind to be expressible in the s-expression surface,
  so `file-types` does not wait on `surface-syntax/SY1`. Recorded because §4
  owes the shapes the tree has closed as well as the ones it leaves open.

## 5. The call

- **Chosen:** Shape B, because `docs/decisions/decision-reflective-floor.md:27-28`
  already draws the line the two positions fall on, and the two gates that line
  produces are disjoint: a round trip that closes on a value below it
  (`.planning/MANIFEST-DESIGN-MAP.md:38-40`) and a differential against the
  existing reader above it (`docs/arcs/surface-syntax-arc.md:157`). One element
  cannot carry both, and §3 measures that carrying either alone strands the other
  half. [[records/author-calls]] the grammar-split ruling rules the two positions functionally
  distinct and keeps the derivation rule in both, which is what makes the split a
  split rather than a cancellation.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Does the below-floor kind earn a suffix of its own, or is it already `<name>.m.conf`? | RESOLVED | The ruling that reaches the suffix is `records/author-calls.md:56`, not the pipeline-position one: the author's own words there name the set `{filename}.m.{conf,check,type,gram,etc.}` and the row records the author correcting the session's spelling back to `.gram`, so `gram` is a member of the set rather than an illustration of it. `:58` supplies the mechanism: a kind's translation is an optional `{parse ->}` stage in front of upper. A file of constructor applications needs no such stage and is requirement 1's kind. `<name>.m.gram` is distinguished by carrying a notation that stage reads, so the notation is the element's obligation rather than a decoration on it. Without a notation the below-floor half collapses into `file-types/K1` and mints nothing |
| 2 | Does the module key absorb the `.m.<facet>` suffix, so `x.m.gram` and `x.m.conf` are two keys or one key with facets? | DEFERRED([[records/author-calls]] the module-key call) | Already open and `unreviewed`. It decides what `try-exts` becomes at `lib/module/resolve.chiral:218-245` and whether `re-ext-collision` (`:123`, `:269`) is a check on keys or on facet sets. The design draws no probe until it is ruled. `file-types/K1` hits it first |
| 3 | Is the above-floor element's deliverable an argument or an implementation? | RESOLVED | Requirement 6 admits both and orders them: "the argument for that comes before any implementation" (`docs/arcs/file-types-arc.md:46-49`), and `docs/elements/ledger.md:323` repeats it. The element's artifact is the argument. Its conclusion may return as an author call, and opening that row is the argument's own job |
| 4 | What gates the above-floor element if its argument concludes in favour of building? | DEFERRED(`surface-syntax/SY4`) | The row exists at `docs/arcs/surface-syntax-arc.md:157` and is `unminted`, so no `E#` is named here. Its harness is `connect` over two built halves and its second front-end is `SY3`, which is blocked on `SY1` at `:154`. The dependency is recorded. Nothing here schedules it |
| 5 | Requirement 4 says each kind has a round-trip gate, and the above-floor position cannot hold one. Does the requirement bend or does the position leave the arc? | RESOLVED, and the arc owes the edit | §3 shows the round trip presupposes a fixed reading of the source, which above the floor is the thing under test. The requirement reaches the below-floor kind and the differential reaches the other. Requirement 4 names its two carriers explicitly, source for `.manifest` and bytes for `.protocol`, so it never claimed the grammar position; requirement 6 is the clause that needs rewriting. This artifact names the edit and does not make it |
| 6 | Does the concept now owe a bank? | RESOLVED | Yes, once the split lands: `docs/banks/INDEX.md` has no grammar row and the shards sit in `docs/banks/text.md:50` and `docs/banks/module.md:79`. Building it is not this run's artifact and it is not a blocker, because both shards already have principled homes |
| 7 | `E190` already occupies `file-types/K3`'s element cell. Does the below-floor element mint as a **second element on that same row**, the way `bridge/C4` carries `E40` and `E56` in one cell at `docs/arcs/bridge-arc.md:70`, or does the arc open a **new roster row** for it? | **NEEDS-AUTHOR** | Opened by the design audit of 2026-09-23, not by the design run. It changes the arc's roster, which is not a design's write surface, and `docs/decisions/decision-work-ids.md` states the contract in the singular: a row "maps to an element or to nothing", and the element cell "carries the `E#` or `unminted`". The two-element row exists in practice and the tooling reads it (`tools/pack/pack.py:235-246`, on `bridge/C4`, where "custody minted twice against the one row"), so both arms are drawable and neither is settled. [[records/author-calls]] the grammar-split ruling says only that "`file-types/K3` ... owe[s] the rework", which reaches the question and does not answer it. The arm chosen decides which roster cell check AE reads the new number out of |

**One NEEDS-AUTHOR**, question 7, opened by this artifact's audit and left
standing. The three rulings the row itself rests on were given on 2026-09-23 and
are written at `records/author-calls.md:56`, `:58` and `:59`; the other call
still open is question 2, which already has its row and belongs to
`file-types/K1`.

## 6. The mint packet

- **Elements:** two, and **the number is a no-op for one of them**. `E190` is
  already minted against this row (`docs/elements/catalog.md:502`,
  `docs/elements/ledger.md:323`), so nothing here mints a second number for the
  compiler-facing position. `E190` is **re-scoped** to that position and its two
  cells are rewritten, because as minted they read "the surface syntax as a
  declared signature, with the reader derived from it", which is the above-floor
  half only, and they argue a cost that §2 measures as false below the floor.
  One **new** number is minted for the program-facing position. They split
  because their gates are disjoint (§3) and neither constrains the other's
  shape: the below-floor kind is buildable today against an ENFORCED seed, and
  the above-floor element owes a document before it owes any code.
- **Band:** `E190-E195`, Lane B (`docs/decisions/decision-lane-split.md:31`,
  `:193`). `E190` is spent on this row already and the band's other five numbers
  are free, measured 2026-09-23 by grep over `docs/elements/catalog.md` and
  `docs/elements/ledger.md`. The two rows below carry `E<NN>` and no literal
  number. Two reasons. The number is the mint step's to allocate:
  `tools/pack/pack.py` takes the first free number in the band and substitutes
  it into both rows, matching them on that placeholder. And the deferral rule
  (`docs/definitions/working-discipline.md:76`) forbids naming an `E#` that is
  not minted, which this one is not while question 7 stands.
- **Catalog row** (the new element):

  ```
  | E<NN> | **`<name>.m.gram`: a grammar below the reflective floor, declared as a value with its reader derived.** The program-facing half of what `E190` was minted as one thing. [[records/author-calls]] the grammar-split ruling rules a declared grammar into two functionally distinct positions and keeps the derivation rule in both; `docs/decisions/decision-reflective-floor.md:27-28` is the line, and a grammar a program applies to input sits below it as ordinary data. The seed is live and gated: `lib/text/matcher.chiral:24` and `:92` hold `Cls` and `Pat` as a pattern language in 602 lines, 41 defs, 25,732 bytes, total and pure, imported by `prog/prose-lint.prog:43` and gated at Phase 19 by `tools/test/matcher.sh`. What is absent is the kind: a notation the `{parse ->}` stage of [[records/author-calls]] the join-point ruling reads, a `show` out of `Pat`, and the round trip closing on the value. It feeds `datas` and `globals` and adds no registry, so it passes `.planning/FILE-KIND-STRUCTURES.md:73-76` on the terms `.port` passes it. Today a grammar is 60 hand-written constructor applications at `prog/prose-lint.prog:72-115`. | Not built, minted from `E190-E195` (Lane B) by the split of 2026-09-23 at `docs/arcs/parts/file-types-K3.md` §5 | `IMPL` (Antimirov partial derivatives; lex/yacc declaration files; Kleene algebra as data) | SH |
  ```
- **Ledger row** (the new element):

  ```
  | E<NN> | file-kind | design | **`<name>.m.gram` below the reflective floor: a grammar as a declared value, its reader derived, its round trip closing on the value.** Split out of `E190` on 2026-09-23 under [[records/author-calls]] the grammar-split ruling. The seed is `lib/text/matcher.chiral` at ENFORCED (`docs/definitions/status-ledger.md:165`); the kind, the notation and the printer are the delta. Gate is requirement 4's round trip with a named mutant that runs. | ←E163, ←E173, ~E190 |
  ```
- **E190's two cells, rewritten** (a separate run executes this, and this
  artifact does not touch either file). **The mint step is not that run.**
  `tools/pack/pack.py` appends the two new rows and flips the roster cell; it
  never rewrites an existing element's cells. The stage that moves a minted
  element whose boundary has shifted is `revisit`, verdict RESCOPE, "the row's
  boundary moved · the roster row, and a split where the work divides"
  (`docs/decisions/decision-design-before-mint.md`, call 5), with the trigger
  named as [[records/author-calls]] the grammar-split ruling. What that run writes:
  - Catalog: retitle to **`<name>.m.gram` above the reflective floor: whether the compiler's own grammar may be declared.** Drop "the only one of the three with no seed in the tree", which `lib/text/matcher.chiral:24` falsifies. Drop the tenth-registry argument as the headline cost and replace it with the one that survives: the grammar is the referent, so no internal gate exists, and the only gate available is differential against the existing reader, `surface-syntax/SY4` at `docs/arcs/surface-syntax-arc.md:157`. Keep the LF / Twelf / Dedukti prior art and its cost, a signature gives rules declaratively and no decidable algorithm, and Dedukti's rewriting is sound only for a confluent and terminating system. Add the shape the floor gives the argument: staged in at build time and changed only by certified succession is consistent with `docs/decisions/decision-reflective-floor.md:27-28` and `:46-50`, and a runtime consultation to decide how to parse is not.
  - Ledger: same two corrections, and the deliverable stays a document. `state` stays `design`. `Related` gains the new number.
- **Size:**
  - The new element, the build: about **480 lines across 5 files**. Basis, all counted
    2026-09-23: `lib/surface/sexp.chiral` is a complete s-expression reader in
    315 lines / 47 defs and a grammar notation is a narrower language than that,
    so the reader half is estimated at 200 to 260 lines in a new
    `lib/text/gram.chiral`; the printer half is `show` over 12 constructors
    (`Cls` five at `lib/text/matcher.chiral:24`, `Pat` seven at `:92`) against
    the `Doc` precedent in `lib/surface/pretty.chiral`, estimated at 120 lines;
    the resolver probe is one `open-ext` call and one `open-ambig` arm per pair
    in the cascade at `lib/module/resolve.chiral:218-245` plus the matching
    entry in `bin/chirality-resolve.sh`, estimated at 40 lines across the two
    providers and **conditional on question 2 being ruled**; the gate is a new
    `tools/test/gram.sh`, estimated at 60 lines, and that figure is **not** read
    off its named comparable: `tools/test/matcher.sh` is 593 lines for 18
    assertions and 12 mutants, where this gate is one property, the round trip,
    over a fixture set. `MAP.md`'s extension table gains a row.
  - `E190`, re-scoped: **one document, about 150 lines, no change under `lib/` or
    `prog/`**. Basis: the deliverable is the argument requirement 6 admits, and
    the comparable artifact is a `docs/decisions/` note of that length.
- **Related:** [[arcs/file-types-arc]] requirements 4 and 6, [[banks/text]] shard
  D, [[banks/module]], [[decisions/decision-reflective-floor]],
  [[decisions/decision-lane-split]], [[decisions/decision-split-checker]],
  [[records/author-calls]] rows at `:56`, `:57`, `:58`, `:59`,
  `surface-syntax/SY4`, `file-types/K1`.

Every `E#` named here is already minted, with the single exception of the one
number this packet mints, which `E<NN>` stands for until the mint step allocates
it. The follow-on gate is named as the roster row `surface-syntax/SY4`, which
exists at `docs/arcs/surface-syntax-arc.md:157` and carries no element number.

- **What `pack.py --mint` can and cannot execute here.** Measured against
  `tools/pack/pack.py` on 2026-09-23. It reads §6, allocates the first free
  number in the band, substitutes it into the two `E<NN>` rows, appends one to
  `docs/elements/catalog.md` and one to `docs/elements/ledger.md`, and flips the
  roster cell. It does **not** rewrite `E190`'s cells, and it **refuses this row
  as it stands**: `mint_mode` reads the element cell first and dies on a row that
  already carries a number, "A row mints once" (`tools/pack/pack.py:1262-1264`),
  and `file-types/K3`'s cell reads `E190` (`docs/arcs/file-types-arc.md:62`). So
  the packet cannot run until question 7 is ruled, and under either arm the
  roster cell is written by hand rather than by the tool. Check AE then reads the
  new number out of whichever cell that ruling picks: "Every catalog element
  holds a roster row whose ELEMENT CELL carries its number"
  (`tools/ledger-lint/ledger-lint.py:2623-2627`).

- **Documents this packet makes wrong, and does not edit.** Named here because
  the run's stop condition is one artifact. Each is a separate unit of work.

| document | what is wrong |
|---|---|
| `docs/elements/catalog.md:502` | "the only one of the three with no seed in the tree" is false: `lib/text/matcher.chiral:24` is the seed and it is ENFORCED. The tenth-registry argument is the wrong headline cost, and the element covers one of two positions |
| `docs/elements/ledger.md:323` | carries the same two claims in the same words |
| `docs/arcs/file-types-arc.md:46-49` | requirement 6 states one kind whose cost is a new registry. Under [[records/author-calls]] the grammar-split ruling it is two positions, and the registry cost holds in neither of the two forms stated |
| `docs/arcs/file-types-arc.md` roster, row `K3` | the row's `what` was renamed to `<name>.m.gram` on 2026-09-23 under `records/author-calls.md:56` and still names one element, its `kind` field reads `primitive` for what is now a primitive and a decision, and its `req` is `6` alone |
| `docs/arcs/file-types-arc.md` requirements 1, 2, 4 | name `.manifest` and `.protocol` as flat extensions, stale under `records/author-calls.md:56` |
| `MAP.md:5`, `:13`, `:20` | the extension table is flat and five-kind, and lists no grammar row. Stale under `records/author-calls.md:56` |
| `.planning/FILE-KIND-STRUCTURES.md:73-76` | the legitimacy test itself stands. Its application to `<name>.m.gram` needs the floor split, because the verdict differs on the two sides |
| `.planning/FILE-KIND-STRUCTURES.md:234` | the bullet reads that the kind **has no seed**, and `lib/text/matcher.chiral:24` and `:92` falsify it in the same words §2 uses against `docs/elements/catalog.md:502`. The rename run of 2026-09-23 left it as out of scope for a rename and recorded that no residue row claimed it. This row claims it |
| `.planning/MANIFEST-DESIGN-MAP.md` | owes the join-point amendment already recorded at [[records/author-calls]] the join-point ruling |
| `docs/banks/INDEX.md` | thirteen rows and no grammar row, once the split lands |
