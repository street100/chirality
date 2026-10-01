# File kind structures

**Opened 2026-09-02.** The structure shared across `.manifest`, `.protocol`,
`<name>.m.gram` and the checker kind. Amend as the design changes.

Two documents already hold pieces of this. This file points at them:

| already written | holds |
|---|---|
| `.planning/README-PLAN.md:308-322` | the end-game requirements, and the honest limit that `<name>.m.gram` is named nowhere in the tree |
| `.planning/MANIFEST-DESIGN-MAP.md` | the one-translator model, `.manifest`'s three shapes, the round-trip law, built-versus-new |

⚑ **Scope widened 2026-09-02.** This opened as a file-kind note. The session
found the kinds are downstream of a semantic split that had no home, so the
split is recorded first and the kinds follow from it.

## The triple

Author's frame, 2026-09-02. Every layer asks three questions:

| question | is | authored |
|---|---|---|
| **what exists** | the vocabulary. Which things there are at all | yes |
| **what is allowed** | the bound. Which of them this may use | yes |
| **what happens** | the record. Which it actually used | **no, derived** |

They stand in inclusion: `exists` contains `allowed` contains `happens`. That is
not an analogy. It is the port discipline as
[[decisions/decision-effect-facets]] already states it: "crossings subset of
capabilities in scope" is `allowed` grounded in `exists`, and profile
conformance is `happens` inside `allowed`.

**`what happens` is never written by a person.** The effect row is "inferred by
elaboration from the transitive closure of extern crossings in the call graph",
and `Sheet.crossings` is marked "derived, WHICH not whether". E161 derives it
with no surface production at all. So a layer has two authored forms and one
derived view, and a kind proposed for `happens` is a kind that should not exist.

### The recursion

`what is allowed` is itself composite. Settling it means stringing together a
configuration of some other layer's own exists, allowed and happens. A profile
says which crossings a module may perform, and to say that it names a port set,
which is an `exists` one level down, and a target, which is that level's
`allowed`. So the triple nests, and the recursion terminates where a layer's
`exists` is a primitive the language declares rather than composes.

### The same triple, four layers

| layer | exists | allowed | happens |
|---|---|---|---|
| crossings | `.port` registry | cap value, arrow, profile | the effect row |
| types | `data` declarations | what is imported into scope | which are used |
| grades | the semiring | the annotation on the binder | the usage vector |
| rules | the signature table | this module's subset | the derivation |

### Five carriers, three questions

The boundary shows up in five places in the source and they collapse onto the
triple, with `allowed` asked at three scopes rather than three times over.

| carrier | question | scope |
|---|---|---|
| `.port` file | exists | the tree |
| linear cap value | allowed | a term |
| `->` against `=>` (`Seat`) | allowed | a signature |
| the profile | allowed | a module |
| the effect row | happens | a term, derived |

⚑ The tight thing that makes this cheap: [[decisions/decision-effect-facets]]
joins possession and exercise by construction rather than by any new judgment, because
every crossing takes its capability as a parameter. "Nothing new enters the
kernel judgment for containment." That gives a test for any proposed kind: **a
kind is legitimate when what it declares is discharged by the signature rather
than by a judgment added to the core.** `.port` passes. A kind needing a new
registry the traversal must learn to consult is a new judgment in all but name.

## Two claims, checked 2026-09-02

**1. `.manifest` is universal, because everything is types and types go to
core.** Partly true, and the ceiling is already written.
`.planning/MANIFEST-DESIGN-MAP.md` states it: "The format expresses any inert
value. Coverage is bounded by what interpreters exist to read the data.
Ceiling: the author never writes control flow. Conditionals and recursion live
in the interpreter." So a manifest is universal over inert values and stops at
computation. It needs no judgment of its own, which is the half of the claim
that holds.

**2. Anything expressible in upper must go through lower.** FALSE, in both
directions, and deliberately.

- Erased content never arrives. `lib/lowering/upper/lower.chiral:65` says "a
  binder stays upper only when LINEAR (q=1); q=0 is erased (dropped)", `:70`
  says "only the KEPT (q!=0) binders' domains must lower",
  `lib/lowering/compile-front.chiral:90` says "the callee's erased positions are
  dropped, an erased arg is a TYPE Term", and `closconv.chiral:1177` carries
  `drop-erased-args`. Types and proofs live at upper and stop there.
- Lower holds content that never came from upper. `sys-tal`'s 64 hand-authored
  defs are written at tal directly, and `erased-nf.chiral` records that its
  shape is "EXACTLY the subset of tal-ir a lowered pure function can reach, no
  ti-sys / ti-bptr (hand-authored sys tal only)".

So altitude fails to be a projection in either direction. The erasure boundary is
where upper stops, and hand-authored tal is where lower starts without it.

## The frame

One translator, one configuration per kind. A kind is a **view** of the term
language, and it is a legitimate view exactly when it round-trips:
`read (show v) = v`. `MANIFEST-DESIGN-MAP.md` states the law and renounces its
converse in writing.

Under `docs/decisions/decision-split-checker.md` each kind is an **untrusted
producer**. It elaborates to core and `kernel-core` re-checks the result against
a fixed demanded statement. `certificate-discipline.md` puts no bound on how many
producers there are ("arbitrarily many"), so adding a kind adds no trusted
surface. This is the reason the answer to "is three kinds realistic" is yes, and
the count of kinds is free.

⚑ The certificate tier is a **target**. It is unbuilt.
`decision-split-checker.md` says the checker's present-day assurance is
agreement, and calls the move to certificates a tier climb "not a switch already
thrown." An argument that leans on the trusted base being small is leaning on
something unbuilt.

## The template

A kind is specified by its positions. For each position: what it becomes, which
layer consumes it, and what obligation it creates.

| column | question |
|---|---|
| position | the slot in the form the author writes |
| becomes | the artifact the parser or loader produces from it |
| layer | what consumes that artifact |
| obligation | the check that now exists and did not before |

## `data`, the working precedent

The one form in the tree that already fans out this way. Measured
`lib/module/loader.chiral:547-595`, `lib/surface/data.chiral`.

| position | becomes | layer | obligation |
|---|---|---|---|
| `<name>` | a `t-tcon` former; a row in `Sig`'s data table | `Term`, `Sig` | redeclaration is `r-redeclared` |
| `<params>` | kinds; de Bruijn positions inside field types | kernel | `check-dparams` |
| ctor `<name>`s | `t-con` formers | `Term` | coverage on every later `case`: `cov-missing`, `cov-dup`, `cov-unknown` |
| field `<type>`s | field entries | positivity, linearity | `compute-sp` strict positivity, cached per group; `LinR` |
| field `q` | a quantity | `Qty` | the semiring in `typing/qtt` |

The author writes names and types. Coverage, positivity and linearity are never
written and always checked. That is the load already sitting on the parser and
lowering chain.

## The two guidelines

Author's call, 2026-09-02. These are what keep fan-out from being mystical, and
they are why `data` reads as regular rather than as a regularity break.

1. **Mechanical is declared.** Where the mechanic can be conveyed plainly, the
   form carries a position that names it. An error declares which error-handling
   type must handle it. The fan-out is then visible in the file that causes it.
2. **Judgement is written.** Where the outcome is a judgement rather than a
   mechanic, the author writes it. Nothing generates it.

Corollary the author drew: **the checker does not author its own logic.** That
logic needs a home, which is a kind.

## The kinds

| kind | state, measured 2026-09-02 | seed in the tree |
|---|---|---|
| `.manifest` | 2 tracked files, resolver probes it, content property checked nowhere | `lib/lowering/tal/target-linux.manifest`, `prog/climb.manifest` |
| `.protocol` | absent from `MAP.md` and from the tree. E183, minted, unbuilt | 5 hand-written codecs, 1,891 L, 177 defs, 122 byte-ops |
| `<name>.m.gram` | named nowhere in the tree; `README-PLAN.md`'s end-game list carries it as a flat `.grammar`, superseded by `records/author-calls.md:56` | none |
| checker kind | unnamed | `Spec` / `SpecRule`, `lib/typing/kernel-core.chiral:28-29`, declared and unpopulated |

⚑ `SpecRule` is `(spec-rule (form JForm) (name Str) (statement Str))`. The
demanded statement is a `Str`. That is the same prose-in-a-field shape as
`Expert.sees` in manas, and it sits at the point where vacuity is pinned:
`certificate-discipline.md` says the single surviving vacuity is whether the
demanded statement is meaningful. A statement held as prose cannot be checked to
be meaningful by anything.

## Where a separation can ride

Measured 2026-09-02 by counting constructor uses across `lib` and `prog`.

| separates | rides on | values | consumer | uses |
|---|---|---|---|---|
| how many times a binding is used | `t-pi`, `t-let` | `q0 q1 qw` | `typing/qtt` semiring, linearity | 178 |
| whether a crossing may happen | `t-pi` | `s-pure s-proc` | kernel membrane check | 14 |
| a predicate over a base type | `t-refine` | `RfAtom` | 7 modules, incl. totality and lowering | 29 |
| which form charged a name | `Sig` | `eh-def eh-data eh-extern eh-porttype` | the exports datasheet | 4 |
| typeability | the `(module ...)` form | `cat-a b c` | `cat-fenced`, but **only the `cat-a` arm** | 3, 2, 2 |
| altitude | the `(module ...)` form | `alt-upper tal metal` | nothing | 2 each |
| what the file is | the filename | 6 extensions | resolver probes 3 of 6; content checked for 0 of 6 | n/a |

The first three ride inside `Term` and all have consumers. The last three ride
beside it and have almost none. `lib/typing/kernel.chiral:102-106` says the
altitude axis has "neither a producer nor a consumer" in its own comment.

⚑ **Corrected 2026-09-02.** An earlier version of this row said typeability had
no consumer, which was measured wrong. `lib/surface/parse.chiral:1127` produces
`cat-c`, and `lib/module/loader.chiral:295-300` consumes the axis:
`cat-fenced` refuses a module declaring `(cat A)` that reaches a crossing. Its
arms are `((cat-a) ...)` and `(_ none)`, so **A carries an enforced obligation
and B and C carry none**. That asymmetry is [[goals/bridge]]'s whole gap, and
the goal and [[arcs/bridge-arc]] opened 2026-09-02 off it. Altitude's row stands
as written.

Consequence for the goal of moving load onto the parser and lowering chain: a
layer carries load only once something consumes it. `cat` and `alt` at 2 to 3
uses are decoration, as are 5 of the 6 extensions. A requirement
added to them is inert until they have a reader.

Available job for altitude, untaken: name which producer emitted a term and
what certificate it owes. `preserve-check` already runs that pattern in four
lowering modules (`eff-lower`, `optimize`, `lower`, `sig-driver`), which is the
part of the chain altitude is supposed to be about.

## Open

- **The demanded statement's form.** `SpecRule.statement` is prose. Until it is
  structured, every kind's certificate is checked against something unverifiable,
  which is the one vacuity the discipline says it cannot absorb.
- **Where generated artifacts live.** A file in the tree can be edited out of
  sync with its source. Inlined at elaboration, it cannot be read or grepped.
  Nothing settles which.
- **Elaboration-time effects.** `PRINCIPLES.md` open edge 1 residue: whether a
  check-time call to an untyped oracle puts a crossing into the elaboration's own
  effect row. A kind whose parser runs producer logic during elaboration is
  inside that open question.
- **`<name>.m.gram` has no seed.** The other three each point at something in
  the tree. This one points at nothing, so its positions cannot be drawn from
  what existing code does.
- **The pilot.** scriba proposed as the forcing case, 41 files, 10,351 L.
  Measured: no scriba file is manifest-shaped today, every one has at least 2
  `lam`. `init-loader.chiral` is 638 L with 52 `lam` and is the config path.

## Amended 2026-09-23, author-led

A session ruled three things, measured four, and gave a four-point statement of
what the kind family must provide whose fourth point it left unfilled. The
sections above stand except
where this block says otherwise. Every ruling is `ruled` in
`records/author-calls.md` with the author's words quoted. Cite that row.

### What the family must provide

Author's statement, 2026-09-23, given as four points. Three are recorded here in
the author's own terms. The fourth is an empty slot the author has not filled.

1. **A structured view for some type of domain, using a parser.** The kind is
   the view and the parser is what produces it. This is §The frame's round-trip
   law seen from the authoring side: a view is legitimate exactly when
   `read (show v) = v`.
2. **The parser handles generalizable things under the hood, with required
   fields or structures.** What every member of the family shares rides in the
   parser, and a member declares the fields it requires. `data` is the working
   precedent already measured above: the author writes names and types, and
   coverage, positivity and linearity are never written and always checked
   (`lib/module/loader.chiral:547-595`, `lib/surface/data.chiral`).
3. **Work outside the category goes in another file entirely, instead of
   under-the-hood or generalized logic.** The author's example: a broker
   `.m.check` using types from one or more `.m.type` files. So the escape hatch
   from a kind's generality is a second file of a second facet, and the
   generalized path is left alone.
4. ⚑ **UNFILLED.** The author's words, verbatim: *"something else important i
   just forgot but really need to remember"*. The slot is recorded open. Nothing
   here fills it and no session should guess at it; it is the author's to
   complete.

⚑ **Point 3 is constructible today in shape**, measured 2026-09-23 and recorded
as `FT-05` in `records/file-types.md`. A file of one kind already imports a file
of another, because an import statement spells a module key and carries no
extension: the resolver supplies it by probing `CHIRALITY_EXTS`, declared
`(.chiral .port .manifest)` at `bin/chirality-resolve.sh:65` and executed at
`:174-199`. Both directions are live. `lib/ports/ports.chiral:32` reads
`(import "ports/fd")` against `lib/ports/fd.port`, and
`lib/lowering/tal/target-linux.manifest:9` reads
`(import "lowering/tal/sys-check")` against
`lib/lowering/tal/sys-check.chiral`. A broker importing the types it brokers
therefore costs an import statement and no new mechanism. What stays open is
whether the facets of one filename are one module key or several, which is
[[records/author-calls]] the module-key call, and `docs/arcs/file-types-arc.md`
§Constraints this arc works under now carries the measurement it is decided
against.

### The three rulings

**1. A kind is named `<name>.m.<facet>`, superseding the flat extension**
(`records/author-calls.md:56`). The author's reason: a manifest-shaped file with
structure rules for semantically similar scenarios is the durable beginning, and
`.manifest` is too general to identify anything. The scheme makes the shared
machinery visible in the filename, which is what §The frame already claims in
prose: one translator, one configuration per kind.

⚑ **Only `gram` is assigned.** The author gave the set as
`{filename}.m.{conf,check,type,gram,etc.}` with `something like` and `etc.` in
the sentence, then re-asserted `gram` specifically against this session's drift.
Which facet each EXISTING kind takes is `unreviewed` at
[[records/author-calls]] the suffix-mapping call. `.protocol` has no evident member: it carries a
wire format, `conf` is configuration, and `type` reads as a type declaration,
which is a third thing.

**2. The join point is an optional `{parse ->}` stage in FRONT of upper**
([[records/author-calls]] the join-point ruling), with `upper -> lower -> binary` always below it.
A kind may skip the s-expression reader. It may not skip the kernel check or the
lowering chain.

Two consequences. **ELF identity is free rather than owed**: one path exists
below the term language, so anything converging above upper produces the same
bytes by construction and no kind owes a binary-equivalence gate. **The kinds are
independent of the surface-syntax fork**: joining above upper does not require a
kind to be expressible in the s-expression surface, so `file-types` does not wait
on `surface-syntax/SY1`, which is itself co-gated on `E38` and `E39`.

⚑ This supersedes `.planning/MANIFEST-DESIGN-MAP.md`'s model line, which says the
pretty parser emits upper chirality **source**, text to text and auditable by
reading. Source is a third position the ruling neither takes nor forbids, and
that file owes the amendment.

**3. A declared grammar is two positions, and the derivation rule survives both**
([[records/author-calls]] the grammar-split ruling). The line is the reflective floor:
`docs/decisions/decision-reflective-floor.md` settles that a runtime's judgment is
"staged-in, never granted-to, and not swappable after staging completes". A
grammar the front end reads source with is inside that judgment because it decides
what a source file denotes. A grammar a program applies to input is ordinary data
below it.

**The derivation rule holds on both sides. What changes is what discharges
it.** Below the floor the round trip `read (show v) = v` closes on the value.
Above it the grammar IS the referent, so no internal gate exists and the only one
available is differential against the existing reader.

⚑ This makes §The kinds' `.grammar` row wrong in both halves, and makes the
"new registry" cost the weaker objection. Below the floor the same declaration
feeds `datas` and `globals` and adds no registry at all.
`docs/arcs/parts/file-types-K3.md` works the split up and is `status: blocked` on
one author call.

### What was measured, and has no other home

**The reader is 8-bit clean and UTF-8 needs no decision.** `lib/surface/sexp.chiral`
is byte-directed and its `is-delim` at `:74-78` is exactly ` \t\r\n();"`, so every
byte >= 128 is a non-delimiter and passes into symbols and strings unchanged.
`lib/text/matcher.chiral:5-6` states the same rule for the text layer: "Bytes
throughout. A UTF-8 lead byte is >= 194 and fails every ASCII range." Codepoints
are owned by one module, `lib/protocol/utf8.chiral` (RFC 3629), which is a
terminal-side decoder and is not on the reader's path.

⚑ **What does NOT exist is normalization or a confusable check**, and for a kind
that names capabilities that is a live hole rather than an encoding question. Two
crossing names differing only by a Cyrillic homoglyph are distinct to `str-eq` and
identical to a reviewer. No row anywhere carries this.
⚑ *2026-10-01: `records/lenses/problems.md` PRB-102 carries it now, measured
with bidi controls and zero-width characters beside the confusable letter.
`.planning/SYNTAX-REWORK.md` holds the surface rework it feeds, and reads this
file's record-against-grammar measurement as the frame for a minimal surface.*

**ELF is not load-bearing and is the wrong place to look for security.**
`lib/lowering/x64/elf.chiral` is 4,845 B over 9 defs, and its own header says
"minimal static ET_EXEC ELF64 header, as PURE byte layout ... No sections, no
symbol/string tables, no dynamic linking". `lib/lowering/x64/emit.chiral` is 644 B.
Replacing the container is cheap in lines and costs the kernel loader, `execve`
and every existing tool, and would need a loader of our own, which grows the
trusted base in the direction the rest of the design shrinks it. The one argument
that survives is carrying the certificate beside the code, and
`docs/decisions/decision-split-checker.md` calls that tier a target rather than a
switch already thrown, so there is no evidence to carry yet.

**The grammar-as-value seed exists and two element rows deny it.**
`lib/text/matcher.chiral:24` (`Cls`) and `:92` (`Pat`) hold a pattern language as
a value, 602 lines, 41 defs, total and pure, imported by `prog/prose-lint.prog:43`
and gated at Phase 19 (`docs/definitions/status-ledger.md:165`).
`docs/elements/catalog.md:502` and `docs/elements/ledger.md:323` both call the kind
"the only one of the three with no seed in the tree". That has been false since
E173 landed. `.planning/FILE-KIND-STRUCTURES.md:234` above carries the same false
claim and is now named in that artifact's residue table.

**Declaration to reader is total for a record and not for a grammar.** This is
why `gram` does not sit beside `conf`, `check` and `type` as a fourth
configuration of one mechanism. `ctor-fields` gives field names, the ascription
gives the tag, the list type gives `cons`/`nil`, and the reader falls out
mechanically. Grammar to parser is not total: ambiguity, termination and
confluence are all reachable. `docs/elements/catalog.md:502` already prices this
off the prior art, a signature giving rules declaratively and no decidable
algorithm.

### Rejected this session

- **Joining the pipeline below upper, "the same thing chirality raw would produce
  for ELF".** Proposed and withdrawn by the author in the same session. The trap:
  joining below the kernel check makes the kind a second TRUSTED producer, which
  destroys the `decision-split-checker` argument that adding kinds costs no
  trusted surface. It also buys nothing, because converging above upper already
  gives byte-identical output.
- **A custom executable container in place of ELF**, on security grounds. See the
  measurement above.
- **Leading with "a tenth registry" as the cost of a compiler-facing grammar.**
  It is the weaker objection and it evaporates below the floor.
- **Renaming `.manifest` and `.protocol` on the obvious reading.** The scheme is
  ruled and the per-kind mapping is not. [[records/author-calls]] the suffix-mapping call holds it.


## Amended 2026-10-01, author-led: the kind map

The author's words, verbatim:

> "i want to outline that .chiral will be raw s-expression stuff with a nice
> schema to follow for splitting up files into a navigable and modular codebase
> and set the split that the rest of files translate to (the reason they are
> specific purpose but just parsed to this). .prog will be the new coder view.
> .port for a dedicated pure port maker view, .manifest for the whole realm of
> manifest stuff, and then i think we should outline more? im not sure what is
> meaningful beyond those tbh but we can rip from how we structure split for
> the high level raw. The whole structurally requires this other program needs
> to be a file structure navigable thing"

It follows the `surface-syntax/SY1` ruling of the same day
(`records/author-calls.md`, the stage-4 fork row): raw s-expressions stay, and
a coder surface translates to raw and back.

### The map as outlined

| kind | is | relation to raw |
|---|---|---|
| `.chiral` | **raw**: s-expressions, with a schema for splitting a codebase into navigable, modular files | the target. Every other kind is parsed to it, which is why the others can be specific in purpose |
| `.prog` | **the coder view**, the simpler surface | translates to raw and back |
| `.port` | **the pure port-maker view**: declaring crossings and nothing else | translates to raw |
| `.manifest` | **the whole realm of manifest kinds**: inert data and its facets | translates to raw. The `<name>.m.<facet>` family ruled 2026-09-23 (`conf`, `check`, `type`, `gram`) reads as this realm's members |
| more | open. The author: *"rip from how we structure split for the high level raw"* | the split for raw is the source the next kinds are drawn from |

**One structural requirement across all of it:** when one program requires
another, the requirement is navigable as file structure. The tree already keys
a module by its root-relative path (`MAP.md` §The module key), so an import is
a path. The author extends that to every structural requirement a program
states: what it needs from another program reads as a place in the tree.

### What this moves, recorded and not yet made

- `MAP.md` §Extensions gives `.prog` as *"program with an entry"*. Under this
  map `.prog` is the coder view, so where an entry lives is reopened: a raw
  `.chiral` defining one, or any kind declaring one as a field. `MAP.md` owes
  the amendment, and it is the tree's contract, so the amendment is its own run.
- `.profile` is absent from the outline. Its content is a frozen port set
  naming a module set, which reads as a member of the manifest realm; that
  reading is the session's and unruled.
- The schema for splitting raw is the thing the next kinds are drawn from. The
  tree's existing rules for it are `docs/definitions/splitting-law.md` (where
  one module ends), `docs/definitions/joining-law.md` (the four typed
  connectors between modules) and `MAP.md` (path as key, directory as role).
  Collecting them into one schema a `.chiral` file follows is the first piece
  of work this map asks for.
- The form inventory, `.planning/FORM-INVENTORY.md`, measures that no file's
  content is checked against its kind today (0 of 5 extensions). Each kind in
  this map therefore owes its content check.

### Candidate kinds beyond the four, from the split, unruled

Drawn from what the split for raw already separates, offered for the author's
outline and decided by nobody yet:

| candidate | what the raw split already separates | nearest seed |
|---|---|---|
| a protocol or wire-format view | a port-protocol data layer, `lib/protocol/` | `.protocol`, E183, minted and unbuilt |
| a grammar view | a grammar as a value | `<name>.m.gram`, ruled as a manifest facet |
| a checker or rule view | the judgment's rules, `SpecRule` | the checker kind of §The kinds, unnamed |
| a profile or target view | a frozen port set and a requirement type | `.profile`, unused, and the `target` and `profile` forms |
| a test or evidence view | fixtures, gates and their expected values | `lib/evidence/`, the test floor |

## Rejected

- **A kind emits checker code.** Rejected 2026-09-02. It breaks the view law: a
  form that produces more than it shows cannot round-trip. Superseded in part by
  the two guidelines above, which permit declared fan-out. The distinction that
  survives is declared versus mystical.
- **"Do not grow the trusted base" as an argument against generation.** Withdrawn
  2026-09-02. The certificate tier is unbuilt, so the argument leans on a
  structure that does not exist yet.
