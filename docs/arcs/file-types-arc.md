---
node: arc-file-types
layer: navigation
related: [arcs/README, goals/readable-surface, arcs/diagnostics-arc, records/author-calls, decisions/decision-reflective-floor, status-ledger, index]
status: current
updated: 2026-09-23
---

# Arc: file types

- goals: [[goals/readable-surface]] (what it is built *for*), [[goals/self-tooling]] (what it is built *out of*)
- reserved element block: `E190-E195` (`docs/decisions/decision-lane-split.md`, Lane B)
- build-state authority: [[status-ledger]]
- lane: B. It runs in a separate session; `docs/decisions/decision-lane-split.md` holds the division and what
  enforces it.

TRACKED for the reason [[arcs/diagnostics-arc]] is.

## ⚑ Amended 2026-09-23: three rulings absorbed, three calls left open

This arc was written 2026-09-04 against a concept set the author replaced on
2026-09-23. Everything below is superseded where this section says so, and every
ruling is read off [[records/author-calls]] rather than off this file.

| ruling | row | what it does to this arc |
|---|---|---|
| a kind is named `<name>.m.<facet>`, a compound suffix | `records/author-calls.md:56` | requirements 1, 2 and 6 name flat extensions. Every one of those names is stale |
| the join point is an optional `{parse ->}` stage in FRONT of upper, with `upper -> lower -> binary` always below | [[records/author-calls]] the join-point ruling | no kind owes a binary-equivalence gate, and this arc does not wait on `surface-syntax/SY1`. Requirement 4's source clause is reached |
| a declared grammar is two positions split at the reflective floor, and the derivation rule survives both | [[records/author-calls]] the grammar-split ruling | requirement 6 is wrong in both halves, and requirement 4 is unsatisfiable for the above-floor position |

**Three calls stay open and this amendment resolves none of them.** A row whose
shape depends on one carries it as a blocking condition in the roster below.

| call | row | rows it blocks |
|---|---|---|
| which facet each EXISTING kind takes | [[records/author-calls]] the suffix-mapping call | `K1`, `K2`. Only `gram` is assigned. `.manifest` to `.m.conf` is a guess and `.protocol` has no evident member at all |
| whether the below-floor grammar element mints onto `K3` beside `E190` or onto a new roster row | [[records/author-calls]] the mint-shape call | `K3`. Opened by the DESIGN audit of `docs/arcs/parts/file-types-K3.md`, which is `status: blocked` on it |
| whether `<name>.m.conf` and `<name>.m.check` are one module key with facets or two keys | [[records/author-calls]] the module-key call | `K1` first, then `K2`. It decides what `try-exts` becomes at `lib/module/resolve.chiral:218-245` and whether `re-ext-collision` (`:123`, `:269`) checks keys or facet sets |

⚑ **A design run on `file-types/K3` was driven ahead of this amendment**, which
was a sequencing error: a frame that reshapes the arc cannot be homed in one
`parts/` artifact. `docs/arcs/parts/file-types-K3.md` stands and this run does
not edit it. Its §3 verdict and its residue table are what this amendment
discharges for the arc's own surface.

⚑ **The artifact cites two of the three rulings at stale line numbers.**
`docs/arcs/parts/file-types-K3.md:33-39` reads them at `:56`, `:58` and [[records/author-calls]] the module-key call.
Two rows opened between that artifact and this one, so the join-point ruling is
now [[records/author-calls]] the join-point ruling and the grammar ruling is `:61`, while `:58`
and [[records/author-calls]] the module-key call are two of the three open calls tabled above. Correcting that artifact
is a separate unit of work.

## Why this arc exists

`MAP.md` states that the extension is the file's kind and the resolver checks it.
Two of the five kinds are declared and unbuilt. Meanwhile five codecs are
hand-written: `http` 780 lines, `vt-parser` 402, `json` 361, `apc` 252, `wire` 96,
totalling 1,891 lines, 177 defs and 122 byte-ops. Each hand-rolls its framing.
`apc`'s went stale twice in one session: its `enc` missed two `Rendering` arms
and shipped red, and its `dec` ends in an `else`, so new branches are invisible
to the compiler. E174 repaired both.

**One law, two carriers.** A declared form, a derived codec, a round-trip gate.
`.manifest` round-trips against chirality source, `parse(source(v)) == v`.
`.protocol` round-trips against bytes. That is why `Doc` serves one and not the
other: bytes have no layout freedom.

⚑ **Superseded in part 2026-09-23 on two counts.** The two names are stale under
`records/author-calls.md:56` and their facets are open at `:57`, so read the
paragraph for its law and not for its filenames. And the carrier count is now
three rather than two: [[records/author-calls]] the grammar-split ruling splits a declared grammar at
the reflective floor, and the above-floor position has no internal round trip at
all, because the grammar is the referent. The law that survives everywhere is
the derivation rule. What discharges it varies by position.

## REQUIREMENTS

Done when all six hold.

1. **The pure-data kind exists as a checked kind.** A module whose every `def`
   body is a literal value: constructor applications and literals, no `lam` and
   no computation. Declared in the file and checked by the loader, because the
   property is one of term structure and the resolver cannot see it. E163.
   Observed by the loader refusing a file of that kind holding a `lam`.
   ⚑ **The kind's NAME is stale and this run does not guess it.** The
   requirement said `.manifest`; `records/author-calls.md:56` rules the compound
   suffix `<name>.m.<facet>` and `:57` leaves the facet for this kind
   `unreviewed`. `.m.conf` is the obvious reading and is still a guess, so the
   requirement names the kind by its property until `:57` is ruled.
2. **The wire-format kind exists as a checked kind**, and `MAP.md` gains it.
   E183. Observed by `MAP.md`'s extension table carrying a row the resolver
   agrees with. ⚑ **Its name is stale on the same terms as requirement 1**, and
   worse placed: [[records/author-calls]] the suffix-mapping call records that this kind has no
   evident member of the illustrated set at all, since it carries a wire format
   rather than a configuration and `type` reads as a type declaration. Blocked
   on `:57`.
3. **Codecs are derived from the declared form** rather than hand-written.
   Observed by the five hand-written codecs losing their framing code and the
   1,891-line total falling. Unreached by the three rulings of 2026-09-23.
4. **Every kind whose declaration has a referent outside the gate carries a
   round-trip gate**, with a named mutant that is actually run: source for the
   pure-data kind, bytes for the wire-format kind. ⚑ **Amended 2026-09-23 on
   three counts.**
   - [[records/author-calls]] the grammar-split ruling makes this requirement **unsatisfiable for the
     above-floor grammar position**, where the grammar IS the referent, so
     `read (show v) = v` presupposes the reading it is meant to test. That
     position is exempt by construction and its only available gate is
     differential against the existing reader, `surface-syntax/SY4` at
     `docs/arcs/surface-syntax-arc.md:157`, which is `unminted`.
     `docs/arcs/parts/file-types-K3.md` §3 measures it.
   - [[records/author-calls]] the join-point ruling reaches the source clause: a kind may skip the
     s-expression reader, so a round trip stated against chirality source binds
     only a kind whose translation runs through that reader. The property the
     requirement holds is the round trip on the kind's own carrier.
   - The same ruling means **no kind owes a binary-equivalence gate.** One path
     exists below the term language, so anything converging above upper produces
     the same bytes by construction. This requirement never asked for one and
     now cannot acquire one.
5. **The five emitters return `Doc`**, gated at widths 1, 40 and 10^6. E146.
   Observed by the gate row at those three widths. Unreached by the three
   rulings of 2026-09-23.
6. **A declared grammar is settled in both of its two positions**, split at the
   reflective floor per [[records/author-calls]] the grammar-split ruling, with the derivation rule
   surviving both. ⚑ **Rewritten 2026-09-23. The previous text was wrong in
   both halves**: it stated one kind whose cost is a new registry.
   - **Below the floor**, a grammar a program applies to input is ordinary data,
     and `<name>.m.gram` either exists as a checked kind or the arc records why
     it should not. The registry cost is false here by construction: the same
     declaration feeds `datas` and `globals` and adds no registry, which is how
     `.port` passes the legitimacy test at
     `.planning/FILE-KIND-STRUCTURES.md:73-76`. The seed is live and ENFORCED,
     `lib/text/matcher.chiral:24` and `:92` gated at Phase 19
     (`docs/definitions/status-ledger.md:165`). Observed by requirement 4's
     round trip closing on the value.
   - **Above the floor**, the compiler's own grammar sits inside the judgment
     `docs/decisions/decision-reflective-floor.md:27-28` freezes, because it
     decides what a source file denotes. The registry cost is the weaker
     objection here too. The cost that survives is that the grammar is the
     referent, so no internal gate exists. The deliverable is the argument, and
     it comes before any implementation. Observed by that argument existing as a
     written artifact with the floor's shape stated: staged in at build time and
     changed only by certified succession is consistent with the floor, and a
     runtime consultation to decide how to parse is not.
   - ⚑ **E190 is minted as one thing and its two cells still read that way.**
     `docs/elements/catalog.md:502` and `docs/elements/ledger.md:323` carry the
     superseded single reading and the registry cost, and both call this the one
     kind of the three with no seed in the tree, which
     `lib/text/matcher.chiral:24` falsifies. Re-scoping E190 onto the
     above-floor position is a `revisit` run at verdict RESCOPE
     (`docs/decisions/decision-design-before-mint.md:166`) and it has not run.
     Where the below-floor element lands is [[records/author-calls]] the mint-shape call. This
     run answers neither.

## Roster

Four rows, one per element. Groups: `kind` is a declared file kind, `codec` is
what is derived from a declared form, and `emit` is the value-to-source path.

⚑ **Amended 2026-09-23. No row opened and no row closed.** Three of the four
carry a blocking condition they did not carry before, and the `req` column on
`K1`, `K2` and `K3` was widened to state what each row already owed. The roster
count is unchanged because every consequence of the three rulings lands inside a
row that exists, and the one consequence that would add a row, where the
below-floor grammar element lives, is [[records/author-calls]] the mint-shape call and belongs
to the author.

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `file-types/K1` | the pure-data kind: a declared form, a derived codec, a round-trip gate on its own carrier. ⚑ **Blocked on two calls**, [[records/author-calls]] the suffix-mapping call for the facet its name takes and [[records/author-calls]] the module-key call for whether the module key absorbs the suffix. The second is the first thing a SPEC here touches, because the probe at `lib/module/resolve.chiral:218-245` differs under all three arms | kind | primitive | new | 1, 3, 4 | open | `E163` |
| `file-types/K2` | the wire-format kind: the same law carried in bytes. Minted 2026-08-31 by [[arcs/diagnostics-arc]], which holds its prose. ⚑ **Blocked on [[records/author-calls]] the suffix-mapping call**, which records that this kind has no evident member of the illustrated facet set at all | kind | primitive | new | 2, 3, 4 | open | `E183` |
| `file-types/K3` | `<name>.m.gram`, and since 2026-09-23 two positions rather than one. E190 covers the above-floor position, whose deliverable is the argument. ⚑ **Blocked on [[records/author-calls]] the mint-shape call**: whether the below-floor element mints onto this row beside `E190` or onto a new roster row. Worked up at `docs/arcs/parts/file-types-K3.md`, `status: blocked` on that same call | kind | primitive · decision | new | 4, 6 | designed | `E190` |
| `file-types/E1` | value to source: the five emitters return `Doc`. Imports `surface/pretty`, which E181 landed | emit | law | new | 5 | open | `E146` |

### Coverage

Run again 2026-09-23 against the amended requirements.

**Every requirement is named by at least one row.** 1 by K1, 2 by K2, 3 by K1
and K2, 4 by K1, K2 and K3, 5 by E1, 6 by K3. **Every row names at least one
requirement.** **Every `origin` is defensible from the section above**: all four
read `new`, and no file kind in this arc exists as a kind today. The seed under
requirement 6's below-floor half is ENFORCED (`lib/text/matcher.chiral:24`,
`docs/definitions/status-ledger.md:165`) and the kind over it is not, which is
why that row stays `new` rather than `bind`. ⚑ **That distinction is thin and
the next design run on it should re-test it**: a notation, a `show` and a round
trip over a `(data Pat ...)` that already exists is closer to a surface over a
built thing than the word `new` suggests.

⚑ **Requirements 3 and 4 still hold no row of their own**, and both are
enumerated: `GAP-04` in `records/lenses/gaps.md:47` for requirement 3, codecs
derived rather than hand-written, and `GAP-05` at `:61` for requirement 4. Both
are properties K1, K2 and K3 each carry rather than deliverables of their own.
The 2026-09-23 amendment attaches them to the rows that owe them in the `req`
column, which closes the coverage hole on paper and leaves the gap rows standing
on the question they actually ask: whether a property carried by three rows
earns a row that gates it once.

⚑ **Requirement 4's coverage now carries a stated exemption rather than a hole.**
K3's above-floor position cannot hold a round trip ([[records/author-calls]] the grammar-split ruling),
so requirement 4 reaches K3 through its below-floor half alone. The above-floor
half is gated by `surface-syntax/SY4` (`docs/arcs/surface-syntax-arc.md:157`),
which this arc does not own and does not schedule.

## Resume state

**Where a session picks up, 2026-09-23: nowhere on the kind rows, and
`file-types/E1` is the one row an agent can start.**

Three of the four rows are blocked on an open author call, tabled in the
amendment section above. `K1` is blocked twice, on [[records/author-calls]] the suffix-mapping call
and [[records/author-calls]] the module-key call. The module-key call is the harder of the two: a design cannot draw the resolver probe
before the module-key arm is chosen. `K2` is blocked on [[records/author-calls]] the suffix-mapping call. `K3` is blocked
on [[records/author-calls]] the mint-shape call and its design artifact already says so. `E1` carries requirement 5,
which the three rulings of 2026-09-23 do not reach, and its dependency landed
when E181 moved the term printer to `lib/surface/pretty.chiral`.

**What the author can unblock with three rulings**, in the order that frees the
most work: `:57` frees `K1`'s and `K2`'s names, [[records/author-calls]] the module-key call frees `K1`'s SPEC, `:58`
frees `K3`'s mint. Nothing else in this arc is waiting on a measurement.

⚑ **The 2026-09-10 block below is superseded as a resume instruction and kept as
a measurement.** It directs a session to `element-design` on `file-types/K1`,
which [[records/author-calls]] the module-key call now blocks. Its five measured bullets still stand except where the
2026-09-23 rulings rename what they measure.

**Where a session picked up, 2026-09-10: `element-design` on `file-types/K1`.**
Not `design-to-spec`. A spec run on **E163** was dispatched and refused at step
one by the tool itself: `python3 tools/pack/pack.py E163 --spec` reports "no
rationale artifact for E163 ... A SPEC is written from one of the two", and
`--audit spec` refuses identically. E163 is an **orphan of the pipeline change**:
minted under the old flow, it has no `docs/examples/E163-*.md` and no row in
`docs/examples/INDEX.md`, and [[decisions/decision-design-before-mint]] retired
the example stage on 2026-09-05, so it never will get one. Its roster row `K1`
carries the element and no design artifact exists at
`docs/arcs/parts/file-types-K1.md`. **The design run must be told the mint is a
no-op**, because E163 already holds its number.

⚑ **Measured for that run, 2026-09-10, and each changes its scope.**

- **The precedent `MAP.md` names does not exist.** `MAP.md:39-41` says the loader
  checks the kind "the same way `.prog` is a checked projection of
  `compile-main`". There is no such check: `lib/module/resolve.chiral:405-407`
  records that the entry and its protocol moved out to `prog/resolve.prog`, and
  the projection is **E172**, ledger state `design`, unbuilt. K1 either invents
  the check or builds one with E172.
- **The extension layer is live and the structural layer is not.**
  `bin/chirality-resolve.sh:65` probes `.manifest` and
  `lib/module/resolve.chiral:218-245` resolves it, so a manifest is a working
  import target today. Nothing tests any `def` body.
- **The two `.manifest` files disagree with the stated test.**
  `lib/lowering/tal/target-linux.manifest` (62 lines, one `def`, pure
  constructor spine) passes. `prog/climb.manifest` (79 lines) passes on the `def`
  test but also carries three `data` declarations and an `import`, so the check
  owes an explicit admitted-form set and a ruling on whether a manifest may
  import computation. It carries **no `(module …)` datasheet**, so a check keyed
  inside the datasheet refuses it, and it is **imported and referenced by
  nothing** across `bin/ lib/ prog/ tools/`. Whether it is a conformance target
  or is deleted is author-tier.
- **`MAP.md`'s own open question is misnamed.** `MAP.md:42-44` raises `sys-tal`;
  the file is `lib/lowering/tal/sys.chiral`, 64 defs over 1,343 lines with 674
  carrying `t-seq`/`ti-ret`. E172's rename already happened.
- **The catalog and ledger premise is stale in a narrowing direction.**
  `docs/elements/catalog.md:475` and `docs/elements/ledger.md:305` both say
  `target-linux.chiral` "already IS one". That file is now
  `target-linux.manifest`, so it already carries the extension and the delta is
  smaller than the rows state.


**Design session 2026-09-02, author-led.** The arc's framing widened: a kind is a
**view** of the term language rather than a subset a predicate admits, and it is
legitimate when it round-trips, which is what requirement 4's gate already
demands without saying so. `<name>.m.gram` and a checker kind joined
`.manifest` and `.protocol`, and the author set two guidelines that let a kind
fan out without being mystical: mechanical is declared, judgement is written.
The shared structure is tracked in `.planning/FILE-KIND-STRUCTURES.md`, which
points at `.planning/README-PLAN.md` for the end-game requirements and
`.planning/MANIFEST-DESIGN-MAP.md` for `.manifest`'s own design. None of it is
minted, and E190-E195 is untouched.

Nothing built. E181 landed and moved the term printer to
`lib/surface/pretty.chiral`, so E146's dependency is in the tree. Two cross-lane
facts, neither gate-enforceable:

1. **The printer's module key is `surface/pretty`.** Root-relative keys make the
   directory the identity, so `typing/pretty` is a different module. E146 imports
   `surface/pretty`. Its API is `pp-of : (-> Str Term Doc)` and
   `pp-term-doc : (-> Term Doc)`.
2. **E181 promoted `bin/chirality-bin`**, 1,130,872 to 1,147,256 B, blob 755,238
   to 772,110 B, measured when E181 landed. Both figures are superseded:
   `40e8726` promoted again on 2026-09-03 and `bin/chirality-bin` is 1,188,216 B
   with the blob at 807,767 B ([[status-ledger]]). Any measurement taken before a
   promotion was taken against a different compiler, and a byte comparison across
   the merge will differ for a reason unrelated to this arc.

The round-trip law `parse(source(t)) == t` is E146's row and cannot be E181's:
`parse`, `elab` and `core->term` live behind `module/loader`, which imports
`typing/diag`, which imports the printer. A `surface/pretty` to `module/loader`
edge would close a cycle. Phase 18's G13 runs that closure walk as a checked row.

Also true, since the round-trip depends on the printed form: a `case` prints
multi-line at every width and makes every enclosing form multi-line too, because
`doc-fits` refuses a hard break anywhere inside the group it measures
(`lib/prelude/doc.chiral:131`). A fixture assuming single-line output at a wide
width will be surprised.

## Constraints this arc works under

- **Lane B must not write its own term printer.** E158's G6 greps `lib prog
  tools` for every `prelude/doc.chiral` binding and fails on a duplicate
  definition, with M6 proving it can see one. This is the duplicate-owner defect
  this repo has already fixed four times: `str-cmp`, `list-sort`,
  `list-dedup-adj`, `Ord`.
- **`Doc`'s algebra is closed.** Six constructors and no seventh. A lane needing
  more converts into `Doc`. Adding an arm reddens two phases in mutants that are
  actually run.
- **The demanded statement this arc's kinds are checked against is prose, and
  unreached.** Measured 2026-09-02, `records/findings.md` FD-09. Under
  [[decisions/decision-split-checker]] each kind is an untrusted producer whose
  output `kernel-core` re-checks against a fixed statement, which is what lets a
  kind be added without growing the trusted base. In the tree that statement is
  `SpecRule.statement`, a `Str`, in `lib/typing/kernel-core.chiral`, which no
  module imports and no phase runs. So the argument that a new kind is cheap
  rests on a seam that is written and not wired. It does not block a kind from
  being built. It does mean a kind cannot claim its certificate is checked.
  `independent-judgment/J5` owns the fix and this arc does not.
- ⚑ **This arc does not wait on `surface-syntax/SY1`.** Recorded 2026-09-23,
  because deferring until the stage-4 surface fork is ruled was a live shape
  until [[records/author-calls]] the join-point ruling closed it by name. Joining above upper does
  not require a kind to be expressible in the s-expression surface, so a kind
  may ship while `SY1` stands open. `SY4` is still the only gate the above-floor
  grammar position can use, and that dependency runs the other way: this arc
  names it and does not schedule it.
- ⚑ **The reader is 8-bit clean, and what does NOT exist is normalization or a
  confusable check.** Measured 2026-09-23. `lib/surface/sexp.chiral:74-78` makes
  `is-delim` exactly trivia plus `()` `"` `;`, so every byte at or above 128 is
  a non-delimiter and passes into symbols and strings unchanged, and
  `lib/text/matcher.chiral:5-6` states the same byte rule for the text layer.
  Codepoints are owned by one module, `lib/protocol/utf8.chiral`, which decodes
  on the terminal side and is not on the reader's path. So encoding is settled
  and needs no decision from this arc. The hole is that two crossing names
  differing only by a Cyrillic homoglyph are distinct to `str-eq` and identical
  to a reviewer, which for a kind that names capabilities is a security
  property rather than an encoding question. **No row in this arc or anywhere
  else carries it**, and it serves none of the six requirements, so this arc
  records it and leaves it unhomed rather than absorbing it.
- ⚑ **Caching is deferred, and the dependency is cross-arc.** Recorded
  2026-09-23. `records/file-types.md` `FT-01` carries the figures: resolution
  already costs more than compilation, measured 2026-08-31 at
  `bin/chirality-resolve.sh:84-87`, where resolving `prog/compiler.prog` cost
  1657ms against 744ms to compile the 732 KB blob it produces, and the file's
  own reading at `:86-87` is *"The provider was the dominant cost of every gate
  in the tree, and none of it was compilation."* An optional parse stage in
  FRONT of upper adds to that side. The remedy is a content-addressed cache and
  it is unconstructible here today: `FT-03` records zero hits for `blake`,
  `sha256`, `digest` and `hash` across `lib/prelude/prelude.chiral` and every
  file in `lib/ports/`. The digest is rostered in another arc, at
  `docs/arcs/crypto-primitives-arc.md:165`, as `crypto-primitives/K4`, *"the
  sponge module: hash, XOF, MAC and KDF as configurations of `K2`, one
  machine"*, `state: open` and `element: unminted`. **This arc names that row
  and schedules nothing. The deferral has an exact trigger: `K2` built, then
  `K4` built.** `K4` is configurations of `K2` and `docs/arcs/crypto-primitives-arc.md:163`
  reads `K2` as `open`, so the wait is on both in that order. `FT-01`, `FT-02`
  and `FT-03` each read `OPEN` and each name the same trigger, so this is work
  waiting on a dated dependency and is never a gap the arc keeps. `docs/decisions/decision-work-ids.md` makes a roster
  row citable before it mints, which is what
  `docs/definitions/working-discipline.md`'s deferral rule requires in place of
  an `E#` that does not exist. ⚑ **The workaround is the status quo.** The arc
  proceeds with no cache and every facet's parse stage re-runs per invocation,
  which is what import resolution already does: `bin/chirality-resolve.sh:76-77`
  says *"Scope is one shell process. `bin/chirality` sources this file per
  invocation, so `chirality check` gets a cold cache every time"*. No kind ships
  slower than the tree runs today, and no roster row here gains a cost budget.
- ⚑ **Cross-kind use must not put the kind into the import statement.**
  Measured 2026-09-23, and it holds today. An import spells a module key and the
  resolver supplies the extension by probing `CHIRALITY_EXTS`, declared
  `(.chiral .port .manifest)` at `bin/chirality-resolve.sh:65` and executed at
  `:174-199`. Both directions are live in the tree: `lib/ports/ports.chiral:32`
  reads `(import "ports/fd")` against `lib/ports/fd.port`, eight more of that
  shape follow at `:33-40`, and `lib/lowering/tal/target-linux.manifest:9` reads
  `(import "lowering/tal/sys-check")` against
  `lib/lowering/tal/sys-check.chiral`. `MAP.md:18-30` §Importability is the
  authority on which kinds are import targets, and it draws the second
  consequence itself: *"extension ambiguity is not a new collision class.
  `foo.chiral` beside `foo.port` is the existing basename collision, already a
  named error."* That error is raised at `bin/chirality-resolve.sh:190-197`.
  **So a broker importing the types it brokers costs an import statement and
  nothing else.** A facet scheme that made the importer spell the facet would
  reverse a property the tree gets for free, and would turn one key into as many
  keys as there are facets. This bears on [[records/author-calls]] the
  module-key call, which decides exactly that: whether `<name>.m.conf` and
  `<name>.m.check` are one module key with facets or two keys.
  `records/file-types.md` `FT-05` is the measurement that call is decided
  against.
- ⚑ **The derivation this arc's law names has no mechanism in the tree, and three
  of the four rows assume one.** Recorded 2026-09-23. `records/file-types.md`
  `FT-06` carries the measurement: `.planning/MANIFEST-DESIGN-MAP.md:238` lists
  *"Schema-consulting printer over `Sig`"* in its `new` column beside `:237`'s
  *"Type-directed elaboration"*, and the schema those would read is built,
  `sig-data` at `lib/typing/kernel.chiral:401` and `ctor-fields` declared at
  `:460` and defined at `:1013`. All seven of their call sites judge: five in the
  kernel's own checking and two redeclaration tests in `lib/module/loader.chiral`
  at `:550` and `:571`. **The sequencing consequence is what this arc owes.**
  `K1`, `K2` and `K3` each carry requirement 3 in the roster's `req` column at
  `:169-171`, and `docs/arcs/parts/file-types-K3.md:105` says what `K3` adds over
  `K1` *"is exactly the notation plus its derived reader"*. Each row is a kind
  and none is the mechanism, so ruling the three open author calls above unblocks
  three designs that each reach the same absent substrate. `records/lenses/gaps.md`
  `GAP-04` was amended the same day: its 2026-09-05 diagnosis, that requirement 3
  is a property each kind carries, is superseded in place by this one and kept.
- ⚑ **Requirement 5 is five hand-written walks under the mechanism's absence, and
  `G6` cannot see that class.** Recorded 2026-09-23, measured at
  `records/file-types.md` `FT-07`. The five are `GateRule`
  (`prog/prapanca/core/types.chiral:14`), `Binding` (`:28`), `Config` (`:36`),
  `Expert` (`:66`) and `Pipeline` (`:82`), 21 fields over five constructors, and
  the last of them reaches two further closed sums, `Order` (`:52`) and
  `StopPolicy` (`:57`). `docs/elements/catalog.md:466` records that
  `prog/prapanca/contract/emit.chiral` does not exist, which holds today. The
  hand-written shape is in the tree once already as a pair,
  `prog/prapanca/contract/manifest.chiral:135` and `:182`, 334 lines whose two
  halves agree by reading. **The constraint above is about a name and this is
  about a shape.** `G6` at `tools/test/doc.sh:509-545` censuses a second
  **defining** occurrence of a `lib/prelude/doc.chiral` name, with `M6` proving
  it sees one; five emitters over five types define five names, so it returns
  clean over five copies of one walk. The four prior duplicate-owner repairs the
  constraint names were all name collisions. **This arc opens no row for it**:
  `FT-07` bears on `file-types/E1`'s design stage, where an `E1` that writes five
  walks and an `E1` that derives them are different elements.
- **Files Lane B may write**: `lib/manifest/**` (new),
  `lib/protocol/{json,http,wire,apc,vt-parser}.chiral`, `prog/` emitters, new
  Lane-B gates.
