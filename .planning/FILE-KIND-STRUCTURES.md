# File kind structures

**Opened 2026-09-02.** The structure shared across `.manifest`, `.protocol`,
`.grammar` and the checker kind. Amend as the design changes.

Two documents already hold pieces of this. This file points at them:

| already written | holds |
|---|---|
| `.planning/README-PLAN.md:308-322` | the end-game requirements, and the honest limit that `.grammar` is named nowhere in the tree |
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
| `.grammar` | named nowhere in the tree except `README-PLAN.md` | none |
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
- **`.grammar` has no seed.** The other three each point at something in the
  tree. This one points at nothing, so its positions cannot be drawn from what
  existing code does.
- **The pilot.** scriba proposed as the forcing case, 41 files, 10,351 L.
  Measured: no scriba file is manifest-shaped today, every one has at least 2
  `lam`. `init-loader.chiral` is 638 L with 52 `lam` and is the config path.

## Rejected

- **A kind emits checker code.** Rejected 2026-09-02. It breaks the view law: a
  form that produces more than it shows cannot round-trip. Superseded in part by
  the two guidelines above, which permit declared fan-out. The distinction that
  survives is declared versus mystical.
- **"Do not grow the trusted base" as an argument against generation.** Withdrawn
  2026-09-02. The certificate tier is unbuilt, so the argument leans on a
  structure that does not exist yet.
