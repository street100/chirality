---
row: file-types/K1
arc: file-types
title: `.manifest`: a declared form, a derived codec, a round-trip gate against source
kind: primitive
origin: new
req: 1, carrying 3 and 4 as properties
status: blocked
updated: 2026-09-10
---

# file-types/K1: `.manifest`: a declared form, a derived codec, a round-trip gate against source

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

⚑ **This row's element is already minted. §6 is a NO-OP and says why.** `E163`
was minted under the flow [[decisions/decision-design-before-mint]] retired on
2026-09-05, so it holds a number, a catalog row and a ledger row while holding no
rationale artifact. `python3 tools/pack/pack.py E163 --spec` refuses at step one
and `--audit spec` refuses identically ([[records/pipeline-orphans]] §"The worked
case: E163"). This run produces the missing artifact so the element can reach a
SPEC. It mints nothing and it touches neither `docs/elements/catalog.md` nor
`docs/elements/ledger.md`.

⚑ `pack.py` printed `[note] file-types/K1 already carries E163. The design stage
is behind it; use --spec`. That note fires on any row whose element cell names an
element and assumes the normal order where a design precedes a mint. Here the
order is inverted and `--spec` is the command that refuses.

## 1. The obligation

- **The row:** a module can declare itself a manifest, and a compile refuses it
  when any `def` it charges has a body outside the inert fragment. The declaration
  and the refusal are one mechanism, so writing a second manifest is
  instantiation rather than imitation.
- **Serves:** requirement 1 of [[arcs/file-types-arc]], "**`.manifest` exists as
  a checked kind.** A module whose every `def` body is a literal value:
  constructor applications and literals, no `lam` and no computation. Declared in
  the file and checked by the loader, because the property is one of term
  structure and the resolver cannot see it. E163."
- **Also carries**, as properties rather than deliverables, requirement 3
  (codecs derived from the declared form) and requirement 4 (a round-trip gate
  with a named mutant that is actually run). The arc enumerates these as `GAP-04`
  and `GAP-05` and gives them no row.
- **Goal:** [[goals/readable-surface]], condition 4, regularity at the surface,
  one shape one meaning, observed on file kinds.

## 2. What the tree holds

Measured 2026-09-10 against the working tree, every citation opened in this run.

- **Bank:** the concept is refracted across two, and neither is missing.
  [[banks/module]] holds the module half: shard 2 typeability placement
  (`docs/banks/module.md:106-125`), shard 5 individuation by type
  (`:182-196`), shard 8 versioned / composed / replaced (`:232`). A file kind is
  a claim about what individuates a module, which is shard 5's own subject.
  [[banks/profile]] holds the misfire: `docs/banks/INDEX.md:26` files
  *dependency manifest* under profile, and `docs/banks/profile.md:85-97` shard A
  is the **roster of modules a profile composes**, a different referent from a
  `.manifest` file. `docs/banks/profile.md` opens with the warning against
  arriving to say the tree is missing a config format. No third bank is owed.

### The extension layer, live

| what exists | where | rung | reached by |
|---|---|---|---|
| `.manifest` in the shell provider's probe set | `bin/chirality-resolve.sh:65`, `CHIRALITY_EXTS=(.chiral .port .manifest)` | IMPLEMENTED | every `bin/chirality` invocation, via `:180` |
| `.manifest` in the native provider's probe | `lib/module/resolve.chiral:218-245`, `try-exts` | IMPLEMENTED | `prog/resolve.prog` |
| the two providers pinned against each other on the collision refusal | `bin/chirality-resolve.sh:59-61` | IMPLEMENTED | `test-resolver-collision.sh` |
| a manifest is checked as any def is, with no separate loader path | `lib/module/loader.chiral:388-400` `load-def` | ENFORCED | every compile |

So a manifest is a working import target today and its defs are type-checked
like any other. Nothing anywhere tests a `def` body's shape.

### The structural layer, absent

| what exists | where | rung | reached by |
|---|---|---|---|
| the authored datasheet, exactly two clauses | `handle-kind` at `lib/surface/parse.chiral:1166`, `handle-kind4` at `:1192` | ENFORCED | every `(module …)` form |
| the datasheet record, three authored fields and three derived | `lib/typing/kernel.chiral:174-180` `Sheet` | IMPLEMENTED | `build-sheet` |
| the per-module close-time derivation | `lib/module/loader.chiral:248-252` `build-sheet` | IMPLEMENTED | `close-sheet` |
| **the fence**, a total function of the finished record that refuses | `lib/module/loader.chiral:295-300` `cat-fenced` | ENFORCED | `close-sheet` at `:321-327`, reached by `sig-close-extent` `:344-348` and `sig-add-kind` `:335-339` |
| the refusal value and its message | `lib/module/loader.chiral:279-280` `SheetErr`, `:282-287` `sh-msg` | ENFORCED | the `ld-err` / `step-err` boundary |
| `lib/manifest/` | does not exist. `ls lib/manifest` refuses, 2026-09-10 | absent | nothing |

`cat-fenced` is the whole precedent this row needs. It reads one authored field
against one derived field, decides once, and returns a value in a closed sum. It
is 6 lines. `SheetErr` is 2 and `sh-msg` is 6.

### The material the check would consume, all already in the Sig at close time

| fact | where |
|---|---|
| a module's own charged names, tagged with the head that installed them | `lib/typing/kernel.chiral:224-226`, `ModKind.exports : (List (Pair Str ExpHead))` |
| every def's body Term, stored by the atomic form | `lib/module/loader.chiral:397` `sig-add-global` |
| every def's body Term, stored by the `declare` + `def` split | `lib/module/loader.chiral:439` `sig-set-global-body`. `load-declare` at `:416` stores a placeholder body and `load-finish` overwrites it, so both forms land the real body |
| the term language, 16 constructors | `lib/surface/syntax.chiral:18-34` |
| a saturated constructor application is ONE `t-con` with no `t-app` spine | `lib/surface/surface.chiral:191` folds the application into `(c-con home nm cargs)`; `lib/module/loader.chiral:43` maps it to `t-con` |
| field and constructor names, the mechanical key source | `lib/surface/data.chiral:31-33` `Field.fname`, `Ctor.cname`; `sig-data` at `lib/typing/kernel.chiral:401`, `ctor-fields` at `:1013` |

`build-sheet` already takes the whole `Sig` (`lib/module/loader.chiral:248`), and
`def->export` at `:198-205` already reaches into it per charged name. A derived
inertness field costs no new plumbing.

### The printer half, landed

| what exists | where | rung | reached by |
|---|---|---|---|
| the term printer, `Term` to `Doc` | `lib/surface/pretty.chiral`, 399 lines, `pp-of` at `:395`, `pp-term-doc` at `:398` | ENFORCED | Phase 18, `tools/test/run-tests.sh:270` |
| `Doc`, six constructors, closed | `lib/prelude/doc.chiral` | ENFORCED | Phases 14 and 17 |
| Lane B's gate phases 21, 22, 23 | unused. `tools/test/run-tests.sh` runs 20 at `:305` and 24 at `:328` | absent | nothing |

### The two files on disk

| file | lines | forms | datasheet | imported by |
|---|---|---|---|---|
| `lib/lowering/tal/target-linux.manifest` | 62 | one `import` at `:9`, one `(module …)` at `:18`, one `def` at `:20` whose body is a pure `sys-reg` / `cons` / `sys-row` spine | `(module lowering/tal/target-linux (cat B) (alt tal))` | `lib/lowering/tal/sys-linkage.chiral:23` |
| `prog/climb.manifest` | 79 | one `import` at `:29`, three `data` at `:32`, `:39`, `:57`, three `def` at `:42`, `:60`, `:72`, each body a pure constructor spine over string and integer literals | **none** | **nothing**, measured across `bin/ lib/ prog/ tools/` |

⚑ **Drift against the arc's resume state, and it widens one question.** The
resume state reads the import as `climb.manifest`'s alone. Both files import.
`target-linux.manifest:9` imports `lowering/tal/sys-check`, which is computation,
and the def's own type `SysReg` comes from that import. So *may a manifest import
computation* bites the conforming file too and cannot be settled by ruling on
`climb.manifest`.

### What the record says, and where it has gone stale

| claim | where | state |
|---|---|---|
| the loader checks the kind "the same way `.prog` is a checked projection of `compile-main`" | `MAP.md:38-40` | **the precedent does not exist.** No stage refuses a `.chiral` defining `compile-main` or a `.prog` that does not. `bin/chirality:171-172` does the opposite: `chirality check` greps the blob for `(def compile-main` and **appends a stub when it is absent**. `bin/chirality:88-90` fixes the entry symbol and `_blob_for` aliases rather than refuses. The projection is E172, ledger state `design`, unbuilt |
| the open question names `sys-tal` | `MAP.md:42-44` | **misnamed.** The file is `lib/lowering/tal/sys.chiral`, 1,343 lines, 64 `def`s, 674 lines carrying `t-seq` or `ti-ret`, no `(module …)` datasheet. E172's rename already happened |
| `target-linux.chiral` "already IS one" | `docs/elements/catalog.md:475`, `docs/elements/ledger.md:305` | **stale in a narrowing direction.** The file is `target-linux.manifest` and already carries the extension, so the delta is smaller than both rows state |
| the compiler is filename-blind, cited as `compile-driver.chiral:9` | `docs/elements/catalog.md:498` | **true fact, dead path.** The live statement is `prog/compiler.prog:9-10`, "Read source from stdin (fd 0)". `compile-driver.chiral` does not exist |
| the demanded statement a kind's certificate is checked against | `records/findings.md:114-120` FD-09, state **RETIRED**, moved 2026-09-05 to `records/lenses/problems.md:727` PRB-52, which carries the live state. `lib/typing/kernel-core.chiral:28` `SpecRule.statement`, a `Str` | **written and unreached.** No file imports `typing/kernel-core`, measured again here: the grep over `lib/ prog/ tools/ bin/` returns nothing. A kind can be built. A kind cannot claim its certificate is checked. `independent-judgment/J5` owns the fix |

`MAP.md`, the catalog and the ledger are outside this run's write surface. The
four rows above are `doc-audit` and `revisit` residue and they are named here so
the SPEC run does not inherit them.

## 3. The delta

Subtracting §2, five things are missing and one thing is not.

**Not missing, and the catalog row says otherwise:** resolution, the extension,
the type-check of a manifest's defs, the term printer, the layout algebra, and
the per-module close-time judgment machinery. The delta is the structural check
and the codec. The plumbing is already built.

**Missing:**

1. **A marker in the file.** The datasheet grammar admits exactly two clauses,
   `(cat …)` then `(alt …)`, and nothing after (`lib/surface/parse.chiral:1192`
   onward, the comment at `:1187-1191` states the shape). There is no slot for a
   third axis value and no other authored per-module form.
2. **An admitted-form set over `Term`, written down.** "Constructor applications
   and literals" names four of the sixteen constructors and rules on none of the
   other twelve. `MAP.md:34-35` and the arc's requirement 1 are the same sentence
   and neither is a predicate.
3. **The admitted TOP-LEVEL form set.** Both live files `import`. One declares
   three `data` types inline. The requirement speaks only of `def` bodies, so a
   manifest that mints its own vocabulary and a manifest that consumes one are
   both admitted by the stated test and they are different kinds of file.
4. **The derived field and the fence arm**, the `cat-fenced` sibling. `GAP-04`
   and `GAP-05` hang off this: a codec derived from the declared form has nothing
   to derive from until the form is declared.
5. **`lib/manifest/`**, and a Lane-B gate phase running a round-trip mutant.

**Verdict: a real delta, narrower than `docs/elements/catalog.md:475` states,
and wider than the arc's requirement 1 states.** Narrower because the extension
and the type-check are built. Wider because the requirement names a `def` body
test and the two files on disk disagree about the form set around it.

## 4. The shapes

The question is one seam and one carrier: where the declaration lives, and what
refuses.

### Shape A: a third datasheet clause, fenced at close of extent

- **Form:** `(module lowering/tal/target-linux (cat B) (alt tal) (kind manifest))`.
  `Sheet` gains one authored field and one derived field, `inert`, computed in
  `build-sheet` by folding the module's own `eh-def` charges against
  `Sig.globals`. A `manifest` claim over a non-empty non-inert list refuses,
  exactly as `(cat A)` over a non-empty `crossings` refuses today.
- **Costs:** three files inside the compiler's closure.
  `lib/surface/parse.chiral` (the two-clause grammar at `:1192`),
  `lib/typing/kernel.chiral` (`Sheet` at `:174`, `ModKind` at `:224`),
  `lib/module/loader.chiral` (`build-sheet`, `SheetErr`, the fence). The closure
  is real: `lib/lowering/compile-front.chiral:18` imports `surface/parse`, and
  `prog/compiler.prog:13` reaches it through `lowering/compile-all`. So the
  deliverable enters `bin/chirality-bin` and owes a promote with the precondition
  [[decisions/decision-lane-split]] states.
- **Forbids:** a manifest with no datasheet. `sig-close-extent`
  (`lib/module/loader.chiral:344-348`) is a no-op when no coordinate is open, so
  `prog/climb.manifest` escapes the fence. It is never judged at all.
- **Buys:** one carrier for every kind in the arc. `.protocol` (E183) and
  `.grammar` (E190) take the same slot, so three kinds cost one grammar change
  between them.

### Shape B: extension-keyed, the projection `MAP.md` asserts

- **Form:** the resolver refuses a `.manifest` whose defs fall outside the inert
  fragment, the way
  `MAP.md:38-40` says it already does.
- **Costs:** it is unconstructible where it is stated. Both providers see bytes
  and import lines. `bin/chirality-resolve.sh:65` probes extensions and
  `lib/module/resolve.chiral:218-245` opens files; neither holds a `Term`.
  Building it means either a second front end in the resolver, which is the
  duplicate-owner defect [[decisions/decision-lane-split]] names four prior
  instances of, or handing the compiler a filename, which `prog/compiler.prog:9`
  is written to never receive.
- **Forbids:** nothing reachable. `MAP.md:37` states the refutation in its own
  words two lines above the claim: the property is one of term structure, so the
  resolver cannot see it.
- **Where it actually lives:** E172, `docs/elements/ledger.md:320`, state
  `design`. E172's projection is entry-ness, a fact about which symbol a file
  defines, which the resolver **can** see from the import list it already parses.
  The two projections share a sentence in `MAP.md` and share no mechanism.

### Shape C: a standalone judgment under `lib/manifest/`, run by a gate

- **Form:** `lib/manifest/inert.chiral` exports a predicate over `Term` and a
  module-level fold over a `Sig`. A new Lane-B gate at Phase 21 loads each
  `.manifest` in the tree and asserts the verdict, with a mutant that perturbs a
  body into a `lam` and pins the refusal line.
- **Costs:** the loader never runs it. Requirement 1 says the loader checks it.
  `chirality check` on a bad manifest still exits 0.
- **Buys:** it lands entirely inside Lane B's writable set,
  `lib/manifest/**` plus a new Lane-B gate
  ([[decisions/decision-lane-split]] §"File ownership"), touches nothing in the
  compiler's closure, and needs no promote. It is also the only shape that can
  judge `prog/climb.manifest`, which carries no datasheet for A to key on.
- **Forbids:** nothing at compile time. A property nothing refuses is a lint.

### Shape D: C, then A

- **Form:** the predicate, the derived codec and the round-trip gate first, under
  `lib/manifest/` and Phase 21. The datasheet clause and the fence second, as one
  commit against the three closure files, with the promote.
- **Costs:** two commits and a window in which the check exists and refuses
  nothing at `chirality check` time.
- **Buys:** the sequencing [[decisions/decision-lane-split]] already chose for
  this lane once, "Lane B starts on the half that does not need it". It also puts
  the fence arm last, when the admitted-form set has been run against both files
  on disk and is no longer a guess.

**What the tree settles and what it does not.** The tree settles the
**mechanism**: `cat-fenced` is the only per-module close-time judgment that
exists, it is 6 lines, and Shape B's alternative is refuted by `MAP.md`'s own
sentence at `:37`. The tree does not settle the **seam**, loader against gate,
because that is a lane-ownership question and the three files Shape A needs are
absent from Lane B's enumerated writable set.

## 5. The call

- **Chosen: Shape D.** Shape A is the target form, because requirement 1 says the
  loader checks it, and a kind that refuses nothing at compile time leaves the
  word *checked* empty.
  Shape B is refuted. Shape C alone stops short of the requirement. D reaches A
  by the route that keeps the first commit inside Lane B's own files and defers
  the promote until the admitted-form set has been measured against both live
  manifests rather than proposed.
- **The check is E163's alone and does not wait on E172.** E172's projection
  reads a filename against which symbol a file defines, and the resolver can see
  that. This projection reads a filename against term structure, and `MAP.md:37`
  says the resolver cannot. One sentence in `MAP.md` covers two mechanisms. A
  joint build would couple an unbuilt element to this one for a shared sentence.

### The admitted-form set, proposed

Over the sixteen constructors at `lib/surface/syntax.chiral:18-34`:

| verdict | constructors | reason |
|---|---|---|
| admit | `t-con`, `t-tcon`, `t-lit-i`, `t-lit-s`, `t-primty` | constructor applications and literals, the requirement's own words. `surface.chiral:191` makes a saturated application one `t-con`, so no spine walk is needed |
| admit, conditionally | `t-ann` | the ascription requirement 1 of `.planning/MANIFEST-DESIGN-MAP.md` demands. Admitted with an inert `tm`; the `ty` position is a type and is judged by the kernel already |
| admit, conditionally | `t-global` | admitted only when the name is charged to the same module and its own body is inert. Cross-module would make inertness non-local, and the close holds only its own module's charges (`ModKind.exports`, `kernel.chiral:226`) |
| refuse | `t-lam`, `t-app`, `t-case`, `t-let`, `t-var`, `t-prim`, `t-pi`, `t-type`, `t-refine` | `t-lam` and `t-case` are the requirement's named exclusions. `t-app` survives only as an unsaturated spine, which is a partial application and therefore computation. `t-prim` is a crossing. `t-pi` and `t-type` in a body are a type-valued def, which is a different kind of module |

`t-var` is unreachable at the top of an inert body because every binder is
refused, and it is written out anyway so a new constructor is a compile error
here rather than a silent admission, which is the totality discipline
`def->export` states at `lib/module/loader.chiral:192-193`.

### Dispositions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Does the check ride the resolver or the loader | RESOLVED | the loader. `MAP.md:37`, the property is term structure and the resolver holds bytes |
| 2 | Is the check built jointly with E172 | RESOLVED | no. Two mechanisms, one sentence. `docs/elements/ledger.md:320` for E172's own projection |
| 3 | Which `Term` constructors are admitted | RESOLVED | the table above, derived from requirement 1 and `lib/surface/syntax.chiral:18-34` |
| 4 | May a `t-global` appear in an inert body | RESOLVED | same-module and itself inert only. A close holds one module's charges, so non-local inertness is undecidable there |
| 5 | Where does the refusal value live | RESOLVED | a `SheetErr` arm, `lib/module/loader.chiral:279`. The house shape, a value in a closed sum rendered at the `ld-err` boundary |
| 6 | Which gate phase | RESOLVED | Phase 21. Lane B's reservation, unused: `tools/test/run-tests.sh` runs 20 at `:305` and 24 at `:328` |
| 7 | Can the kind claim its certificate is checked | RESOLVED | no. `records/lenses/problems.md:727` PRB-52, the live row FD-09 moved to. `independent-judgment/J5` owns the fix and this arc does not |
| 8 | Is `prog/climb.manifest` a conformance target or is it deleted | **NEEDS-AUTHOR** | carried verbatim below. It decides whether the check must judge a datasheet-less file, which decides between Shape A alone and Shape D |
| 9 | May a manifest declare its own `data` types, and may it import computation | **NEEDS-AUTHOR** | carried verbatim below. It is the admitted top-level form set, and it bites both live files |
| 10 | Do `GAP-04` and `GAP-05` take rows of their own | **NEEDS-AUTHOR** | carried verbatim below. Already flagged by the arc |
| 11 | May Lane B write the three closure files, and promote | **NEEDS-AUTHOR** | carried verbatim below. New at this run |
| 12 | Is a wiring view a view of chirality terms, or a second language | **NEEDS-AUTHOR** | carried verbatim below. Raised by the author's own 2026-09-02 session |

### FLAGS: author-tier, carried verbatim, answered by nobody in this run

> **Whether it is a conformance target or is deleted is author-tier: FLAG it, do
> not decide it.**
> (`docs/arcs/file-types-arc.md`, resume state, on `prog/climb.manifest`)

> the check owes an explicit admitted-form set and a ruling on whether a manifest
> may import computation
> (`docs/arcs/file-types-arc.md`, resume state)

> Either the kind admits both and is a view of `globals` **and** `datas`, or the
> type declarations move and `climb.manifest` splits.
> (`.planning/MANIFEST-DESIGN-MAP.md`, §Open)

> ⚑ **Requirements 3 and 4 are served by no row**, and both are enumerated:
> `GAP-04` for requirement 3, codecs derived rather than hand-written, and
> `GAP-05` for requirement 4, each kind having a round-trip gate with a named
> mutant. Both are properties K1, K2 and K3 must each carry rather than
> deliverables of their own, so whether they take rows is an author call.
> (`docs/arcs/file-types-arc.md`, §Coverage)

> ⚑ **The fork this opens, unresolved.** WIT and CAmkES are pure wiring because
> their implementation language is a different language. This tree's premise is
> one language and a manifest as a view of it. So either the wiring view is
> genuinely a view of chirality terms and owes the round trip, or it is a second
> language and the one-language claim weakens. Prior art took the second option
> and does not carry this constraint.
> (`.planning/MANIFEST-DESIGN-MAP.md`, §Amended 2026-09-02)

**New at this run, and it has no prior statement to quote.** Shape A's second
commit writes `lib/surface/parse.chiral`, `lib/typing/kernel.chiral` and
`lib/module/loader.chiral`. [[decisions/decision-lane-split]] §"File ownership"
lists Lane B's writable files as `lib/manifest/**`, `lib/protocol/{json,http,wire,apc,vt-parser}.chiral`,
`prog/` emitters and new Lane-B gates. None of the three appears there, and none
appears in the "neither writes these" list either, so the seam is unstated rather
than refused. All three are inside `prog/compiler.prog`'s closure via
`lib/lowering/compile-front.chiral:18`, so the commit also promotes
`bin/chirality-bin` under the two obligations that decision names. **Question:
does Lane B get that grant, does the fence move to Lane A, or does it become its
own element.**

⚑ **These five FLAGs owe rows in `records/author-calls.md` and do not have
them.** This run's write surface is one file and `records/` is outside it. The
orchestrating session owes those rows.

## 6. The mint packet

⚑ **NO-OP. Nothing is minted by this artifact.** `E163` already holds its number
(`docs/elements/catalog.md:475`), its ledger row (`docs/elements/ledger.md:305`)
and its roster row (`docs/arcs/file-types-arc.md`, `file-types/K1`). No number is
allocated, no band is drawn from, and neither element document is touched. The
packet below records what the element **is**, for the SPEC run that follows.

- **Elements:** one. The declaration, the predicate, the codec and the gate
  constrain each other: a codec derived from the declared form cannot be written
  before the form is declared, and the round-trip law is what decides whether the
  admitted-form set is a view rather than a second language
  (`.planning/MANIFEST-DESIGN-MAP.md`, §The law). Splitting them would hand the
  first half a shape the second half rules out.
- **Band:** none drawn. `E190-E195` stays untouched. E163 predates the band.
- **Catalog row:** unchanged. `docs/elements/catalog.md:475` stands as written.
  ⚑ Its premise is stale in a narrowing direction: it says `target-linux.chiral`
  "already IS one" and the file is `lib/lowering/tal/target-linux.manifest`, which
  already carries the extension. Its "OPEN CHOICE" clause asks whether `manifest`
  is a fourth axis value, a `(kind … (data))` claim, or a target-shaped form; §5
  answers the first and defers the rest. Correcting the row is `revisit` or
  `doc-audit` work and falls outside this run.
- **Ledger row:** unchanged. `docs/elements/ledger.md:305`, state `design`,
  module `manifest-kind`, track `SH`. The state is already correct for an element
  that now has a design and no SPEC.
- **Size**, in two commits:

| commit | files | lines | basis |
|---|---|---|---|
| 1, Lane B's own | `lib/manifest/inert.chiral` (new), `lib/manifest/show.chiral` (new), `tools/test/manifest.sh` (new), one line in `tools/test/run-tests.sh` | ~450 to 550 | the predicate is a total case over 16 constructors plus the `KArm` and `RfAtom` walks, and `def->export` at `lib/module/loader.chiral:198-205` is the shape at 8 lines for 4 arms. The printer is a fragment of `lib/surface/pretty.chiral`, 399 lines for the whole term language. The gate is sized against `tools/test/matcher.sh`, Phase 19 |
| 2, the fence, gated on FLAG 11 | `lib/surface/parse.chiral`, `lib/typing/kernel.chiral`, `lib/module/loader.chiral` | ~80 to 120, plus a promote | measured directly: `cat-fenced` is 6 lines (`loader.chiral:295-300`), `SheetErr` 2 (`:279-280`), `sh-msg` 6 (`:282-287`), `build-sheet` 5 (`:248-252`), and the three existing derivations are 6, 11 and 9 (`:206-211`, `:218-228`, `:233-241`). `Sheet` gains 2 fields, `ModKind` 1, `handle-kind4` one clause |

- **Related:** [[arcs/file-types-arc]] · [[decisions/decision-lane-split]] ·
  [[decisions/decision-design-before-mint]] · [[records/pipeline-orphans]] ·
  [[banks/module]] · [[banks/profile]] · `MAP.md` ·
  `.planning/MANIFEST-DESIGN-MAP.md` · `.planning/FILE-KIND-STRUCTURES.md` ·
  E183 (`file-types/K2`) · E190 (`file-types/K3`) · E146 (`file-types/E1`) ·
  E172 (`docs/elements/ledger.md:320`) · E161 (the datasheet this rides).

Every `E#` named here is already minted.
