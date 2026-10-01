# Syntax rework

**Opened 2026-10-01.** A discussion in progress, kept as a file per
`.planning/protocol/placement.md` §Writing is mostly amending. It feeds
`surface-syntax/SY1` in `docs/arcs/surface-syntax-arc.md`, the stage-4 fork,
which is the author's to rule. Nothing here rules it. The kinds frame it leans
on is `.planning/FILE-KIND-STRUCTURES.md`; this file points at it and restates
none of it.

## The author's words, verbatim, 2026-10-01

> "Can i ask you to play around and lmk what its like to deal with chirality on
> a syntax level? Can you also weigh in on if the lisp likeness is a good or bad
> idea if the goal is universal readability but also like not having vuln
> issues from syntax first"

> "How much of syntax stuff is documented? I honestly think a total clarity and
> minimality syntax rework with better parsing is probably a big deal if the
> field is wicked covered. I dont want syntax vulns. And we'd reimplement
> unicode securely too anyways so its like."

> "I mean documented in general like in the wide field sense web search
> thoroughly required"

> "Theres a pretty straightforward requirements structure for like, kind of
> everything here right? Like the required fields of programs with different
> purposes and elements and subelements of them"

Read together: a rework toward total clarity and minimality, with a better
parser, a secure Unicode reimplementation, and no syntax-caused vulnerability
class, gated on how thoroughly the wider field documents the territory.

## What writing chirality was like

Measured 2026-10-01 at `94d371e` with `bin/chirality`. About a dozen programs
written from scratch and about 30 probes that break them the way a newcomer
would. Four problems were filed with a one-line reproducer each:

| row | what |
|---|---|
| PRB-102 | the reader accepts bidi controls, zero-width characters and confusable letters in source |
| PRB-103 | a reader error names a position in the resolved blob (`591:48`) instead of the writer's file |
| PRB-104 | shipping refusals name neither the definition, the place, nor what was expected |
| PRB-105 | `do` binds every `<-` at quantity 1 and requires each plain step to return `Unit` |

All four are in `records/lenses/problems.md`.

**What held up.** A compile takes 45 to 75 ms. The 47-line program below became
a 37 KB native binary and printed `sum = 49` and `bad field 1: x7`.
Exhaustiveness, linearity and types caught every structural mistake made. A
goto-fail-shaped misplaced paren in a two-step verify was refused as a
non-exhaustive case. Passing `-3` where `(refine I64 (> 0))` is required fails
to compile, and a `(<i 0 n)` guard makes the call legal. Three refusals say
what to do: `effectful application at a pure seat (use => not ->)`,
`last clause must be (else body)`, and `unknown name lenght`.

**What hurt, worst first.**

1. Positions in a file the writer never opened (PRB-103).
2. Refusals that name nothing (PRB-104): `type mismatch` for a wrong type and
   for a wrong argument count alike, `non-exhaustive case` without the missing
   case, `field binder usage mismatch` for a leaked socket and for a socket
   closed twice, `unknown name put` with no hint that it lives in `ports/ports`.
3. `do` (PRB-105), whose refusals name a `let` and a `case` the writer never
   wrote.
4. Nesting. The program below reaches ten levels and closes on `)))))))))`.
   Prefix arithmetic such as `(+ (* acc 10) (- c 48))` costs effort to read,
   and names sit apart from their types: `(-> Bytes I64 I64 I64 (Maybe I64))`
   in the signature, `(lam (b i j acc) ...)` beneath it.
5. Silent wrong answers, each already held elsewhere: `str->i64 "12abc"`
   returns 0 ([[arcs/errors-as-values-arc]] requirement 2, `EV14`), an
   out-of-range `bget` returns adjacent bytes (`records/author-calls.md:96`,
   ruled 2026-10-01), and a zero divisor dies as `Illegal instruction`
   (`enforcement/N31`).

The sample, kept so a reworked surface can be measured against the same
program:

```
; sum a comma-separated list of integers; report the first bad field
(import "prelude/prelude")
(import "ports/ports")

(data Res () (ok (v I64)) (bad (field I64) (text Str)))

; parse digits of b in [i, j) into acc, or none on a non-digit
(def digits (-> Bytes I64 I64 I64 (Maybe I64))
  (lam (b i j acc)
    (case (<i i j)
      (false (some acc))
      (true
        (let (c (bget b i))
          (case (<i c 48)
            (true (none))
            (false
              (case (<i 57 c)
                (true (none))
                (false (digits b (+ i 1) j (+ (* acc 10) (- c 48))))))))))))

; walk fields separated by ',' (44)
(def walk (-> Bytes I64 I64 I64 I64 Res)
  (lam (b start i field sum)
    (let (n (blen b))
      (case (<i i n)
        (true
          (case (=i (bget b i) 44)
            (true
              (case (digits b start i 0)
                ((none) (bad field (bytes->str (bslice b start i))))
                ((some v) (walk b (+ i 1) (+ i 1) (+ field 1) (+ sum v)))))
            (false (walk b start (+ i 1) field sum))))
        (false
          (case (digits b start n 0)
            ((none) (bad field (bytes->str (bslice b start n))))
            ((some v) (ok (+ sum v)))))))))

(def report (=> Res I64)
  (lam (r)
    (case r
      ((ok v) (do (put (str-cat "sum = " (i64->str v))) (put "\n") 0))
      ((bad f t) (do (put (str-cat "bad field " (str-cat (i64->str f) (str-cat ": " t)))) (put "\n") 1)))))

(def compile-main (=> I64 I64)
  (lam (n)
    (let (r1 (report (walk (str->bytes "12,7,30") 0 0 0 0)))
      (+ r1 (report (walk (str->bytes "12,x7,30") 0 0 0 0))))))
```

## The session's read on the Lisp-likeness

Given to the author 2026-10-01, before any research run. An analysis, unruled,
and due a re-read once FD-66 to FD-70 land.

**Against syntax-caused vulnerabilities, s-expressions are the strongest
available choice.** They remove by construction operator precedence, the
dangling `else`, `switch` fallthrough, `=` written for `==`, and a stray `;`
after an `if`. What remains of paren misplacement the type system mostly
catches, as the goto-fail probe showed.

**The two live syntax vulnerabilities owe nothing to Lisp.** Unicode, PRB-102:
bidi controls in comments and strings are Trojan Source, and `vаl` with a
Cyrillic `а` compiles as a distinct function from Latin `val`. Indentation that
lies about structure: `paren-audit` checks balance only. The fix proposed for
the second is that source must equal its canonical print, the `E181` printer in
`lib/surface/pretty.chiral`, so layout cannot disagree with structure. Both
fixes apply to any surface.

**For universal readability, plain s-expressions are a barrier.** Prefix
arithmetic, paren stacks and deep nesting are what most programmers turn away
at. Three repairs fit inside s-expressions: names on the arrow,
`(-> (b Bytes) (i I64) I64)`, since arrow items already parse as binders; a
sequencing form that binds without linearity; a pipeline form to flatten
nesting. Infix arithmetic and indentation-shaped blocks do not fit.

**The recommendation given:** s-expressions stay the one canonical form the
checker, the tools and agents read, and a human notation is added as a lossless
projection of it. `surface-syntax/SY4`, the judge that diffs two front ends,
checks the round trip. The notation keeps the safety properties when it has no
hidden precedence (mixing operators needs parens), lets the formatter own
layout, and goes through the same hardened reader. Its cost is a second parser
to secure and the one-shape-one-meaning risk, which the judge contains. This is
the second arm of `SY1`. The row and linear-arrow spellings ruled 2026-10-01
(`records/author-calls.md:538`, `:539`) clear part of `SY1`'s blocking
condition.

**Cheapest wins under either arm:** the reader refuses bidi, invisible and
confusable characters; errors are positioned in the writer's file; refusals
name the definition, the missing case and the expected type.

## The requirements structure the author asked about

The tree holds it, as the author framed it on 2026-09-02 and 2026-09-23, in
`.planning/FILE-KIND-STRUCTURES.md`: the triple *what exists, what is allowed,
what happens*, nested one layer inside the next; a kind specified by its
positions (position, what it becomes, which layer consumes it, what obligation
it creates); `data` as the working precedent; and the author's four points of
2026-09-23, whose second is *"the parser handles generalizable things under the
hood, with required fields or structures"*. Point 4 is unfilled and is the
author's.

The measurement that file carries is the one a rework turns on: **declaration to
reader is total for a record and not for a grammar.** A form declared as a head
with named, required positions gets its reader mechanically, and the reader can
refuse with the missing position named. A grammar reaches ambiguity,
termination and confluence. The session's read, unruled: a minimal surface is
one where every form is such a record and the grammar shrinks to the one rule
that reads records, so a program's kind (`.prog`, `.port`, a profile against
its target) and each element and sub-element inside it are declared positions
the reader checks. FD-70 asks what the field publishes on keeping a grammar
small and unambiguous.

## What the field documents, landed 2026-10-01

The five runs returned the same day and their rows are in `records/findings.md`
under *What the field documents about surface syntax, its parser and its
reader*: 194 pins, every citation resolving. Each row carries its quotes; this
section carries the conclusions and points at the row.

| id | answer in one line | coverage |
|---|---|---|
| FD-66 | six defect classes are attributed to C-family syntax, each with its construct (CWE-483, 481, 480, 783, 484, 1007); seven languages removed a construct; no source measures a class disappearing afterwards | taxonomy and compiler mitigations well covered; incidents partly; measurement thin |
| FD-67 | LangSec's rules (recognize fully first, deterministic context-free or weaker, refuse malformed input, bound depth, size and expansion) are written for protocols and files; no source applies them as a set to a source reader, Lisp's included | protocols and files well covered; source readers thin |
| FD-68 | Unicode publishes most of a source policy as numbered, selectable requirements with versioned data; compilers each ship a subset, Elixir the nearest whole; what a reader does with an invisible character inside a literal is specified nowhere | identifiers and normalization well covered; bidi display partly; invisible characters in literals thin |
| FD-69 | controlled syntax studies exist, small and mostly on students in Java, C and Pascal; two headline effects failed replication; no study of any kind compares s-expressions with an alternative | mainstream details partly covered; s-expressions absent |
| FD-70 | a deterministic grammar class gives unambiguity by construction and a verified parser closes the gap (CompCert C, CakeML); Rivest's s-expressions are RFC 9804 with a two-rule canonical form; nothing measures how small a usable grammar can be | formal results and production practice well covered; size and usability unmeasured |

**Read as a whole.** How to make a reader safe is documented well, in pieces
nobody has put together for a source reader. How to make a surface readable is
documented thinly, and for s-expressions against anything else it is not
measured at all. A rework can therefore build its safety on published rules and
has to measure any readability claim it makes.

## The reader the five findings support

Each rule is supported by at least one finding, and the rows hold the quotes.
Together they are a reader specification no single source states.

1. **The reader reads data and runs nothing.** No read-time evaluation, no
   reader extension chosen from inside the file, no macro expansion in editors
   over untrusted source. Impossible by construction, since Common Lisp and
   Clojure guard it with a flag that defaults on (FD-66, FD-67, FD-70).
2. **The datum grammar is deterministic, LL(1), and checked by a tool.** Every
   disambiguation sits in a production. There are no precedence declarations,
   no ordered choice and no rule resolved in prose. Parsing takes no feedback
   from bindings (FD-67, FD-70).
3. **Recognize the whole file before anything reads it,** and hand the
   compiler a type that cannot hold an unread form (FD-67).
4. **Refuse rather than repair, one spelling per datum.** Numbers carry an
   explicit radix prefix, and a leading `0` before a digit is refused (FD-66,
   FD-67, FD-70).
5. **Bound nesting depth, token length, file size and any expansion,** with a
   refusal naming the bound. Untrusted symbols stay out of any global
   intern table (FD-66, FD-67).
6. **A declared Unicode policy** (FD-68):
   - name the Unicode version and the UAX #31 requirements met, by number;
   - identifiers are XID-based under a declared profile with NFC, refusing
     non-NFC or equating it, and NFKC is avoided;
   - the twelve `Bidi_Control` code points are refused outside literals and
     comments, and inside them either when unpaired or always;
   - invisible characters outside literals are a hard error naming the code
     point;
   - UTS #39 Restricted characters and mixed-script identifiers are refused,
     and confusables are detected by `bidiSkeleton`;
   - all seven line terminators end a line, or NEL, LS and PS are refused.
7. **Source equals its canonical print.** One printer driven by the tree, a
   reader and printer proved inverse in the shape of HOL4's `parse_print`, and
   indentation that disagrees with the parentheses refused. Columns, where any
   rule reads them, do not depend on tab width (FD-66, FD-69, FD-70).
8. **The syntax tree is lossless, with an exact offset in the writer's file on
   every node** (FD-70). This answers PRB-103.
9. **Every error state has a message listing what was expected,** and the
   states are enumerated, as Menhir and CompCert do. Known paren misuse is
   refused by name (FD-69, FD-70). This answers PRB-104 at the reader.
10. **Any human notation added over the canonical form maps one to one onto the
    tree, carries no hidden precedence, and has its readability measured**
    before a gain is claimed, by PLIERS or Stefik's placebo design (FD-69).
11. **"No syntax-caused vulnerability" is shown class by class:** a refusal
    test per named class, since no source measures a class disappearing
    (FD-66).

**What the sources leave open, and so the author or a measurement settles:**
what a reader does with U+200B, U+2060, variation selectors or tag characters
inside a string literal; whether bidi controls in literals are refused when
unpaired or always; whether a confusable is a warning or an error, and over
what scope; which bounds a reader carries and their values; whether
s-expressions read harder or easier than infix or indentation for anyone.

## How the session's read stands against the findings

Dated 2026-10-01, after the five rows landed. The read above stays as given.

- *"S-expressions remove precedence, the dangling `else`, fallthrough, `=` for
  `==`"*: SRFI-105 drops precedence on purpose, and the rest is the session's
  inference. FD-66 finds no source measuring any class disappearing for any
  language. The claim stands by construction only.
- *"For universal readability, plain s-expressions are a barrier"*: FD-69
  finds no controlled evidence either way. Every Lisp-family move off
  parentheses rested on adoption judgment or case study. The claim is the
  field's folklore and goes unmeasured.
- *"Source equals its canonical print"*: supported by three rows (FD-66,
  FD-69, FD-70) and by RFC 9804's canonical form.
- *"Keep s-expressions canonical and add a projection"*: consistent with every
  row, and FD-69 attaches a condition, that the projection's readability is
  measured.

## Typed text instead of refusals, the author's turn, 2026-10-01

> "Wouldnt we want to approach this different? Like we make a typed extendible
> unicode system so you just cant abuse and get a functioning piece. And then
> ill ask again if the required fields per semantic type of prog in chirality
> are obviously reppable"

The session's reading, unruled. The eleven rules above are refusals at the
reader. The author's shape moves them into construction: no constructor
produces the abused value, so there is nothing to refuse downstream. It is the
tree's own doctrine at the bottom layer, *the dangerous thing has a type*
([[goals/enforcement]] §The dangerous thing has a type), and FD-67's
parse-don't-validate result: code past the reader holds a type that cannot
carry an unread form.

**The triple, applied to text** (`.planning/FILE-KIND-STRUCTURES.md` §The
triple):

| question | for text in source | authored |
|---|---|---|
| what exists | the Unicode data at a pinned version: categories, `XID`, `Bidi_Control`, default-ignorables, identifier status, confusable skeletons, held as typed data | yes, imported from the standard |
| what is allowed | a text profile per position: identifier, literal spelling, comment, whitespace, each a refinement over code points, with its normalization form | yes, declared per module |
| what happens | the scripts and characters a file used | derived by the checker |

**What construction does to each abuse FD-66 and FD-68 name.**

- *Malformed UTF-8* has no code point value, so it yields no token. The one
  decoder is `lib/protocol/utf8.chiral`, which sits off the reader's path
  today.
- *A homoglyph name.* An identifier value is built only by its profile's
  constructor, so a Cyrillic `а` in a Latin-profile module has no identifier
  value at all. Where the profile admits both scripts, a scope is keyed by the
  name's confusable skeleton: a second name with the same skeleton is the same
  key, so its binding collides and is refused, and a reference finds the one
  binding. A look-alike cannot become a second working function. Every
  compiler FD-68 surveyed only warns on confusables.
- *Bidi and invisible characters in a literal.* The string value may hold any
  code point. Its source spelling admits only visible characters, and every
  other code point is spelled as an escape such as `\u{200B}`, which is what the
  canonical print emits. With source equal to its canonical print, a raw
  invisible byte in a literal fails the round trip. That settles by
  construction the question FD-68 found no source settling.
- *Unpaired direction controls* in text meant for display. A display type
  carries direction as structure, isolates as nodes, so an unpaired control
  has no representation.

**Extendible.** A profile is a declared value of a profile type: the Unicode
version, the scripts admitted at each position, the normalization form, the
confusable table's version. Adding a script is a new profile value, and the
reader's code stays untouched. Widening a module's profile is a declared,
visible act, as widening a port set is, and at rung 2 it is ceremony. A basic
profile is the default, the way the basic semiring embeds in
`.planning/GRADE-ARCHITECTURE.md`. FD-68 advised a warning for confusables
because skeletons change between Unicode versions; pinning the version in the
profile makes the key stable, and an upgrade is a profile change that
re-checks everything under it.

**What stays a judgment or a trust.** The Unicode data is trusted input, pinned
by version. Confusability is a relation between names, so it is checked where
names meet: a scope, and module exports, both keyed the same way. The decoder
and the tables join the reader's trusted base. Text a running program prints
belongs to the display type, a separate seat from source.

**Prior art to check before this is ruled.** The PRECIS framework, RFC 8264,
defines string classes with profiles layered on them, and IDNA2008 restricts
domain labels by derived property. Both are typed, extendible Unicode in the
author's sense, as this session recalls them; neither is pinned here.

## The required fields per kind of program, asked again 2026-10-01

**Representable, and the tree already does it twice.** A record type with
named required fields is a `data` declaration, and `ctor-fields` gives the
field names (`lib/typing/kernel.chiral:1026`). `lib/lowering/tal/target-linux.manifest`
is a file whose content is one value of a declared type, `SysReg`, built from
`(data SysRow () (sys-row (name Str) (num I64)))`. So a kind of program is a
declared type its file must inhabit, and a missing field is a missing
constructor argument, refused with the field's name.

The semantic requirements are types too: the ports a program may use (its
profile's port set), the effects it may perform (the row), the guarantees it
owes (totality, refinements, grades). A program fits its purpose when its type
satisfies the requirement type, the conformance [[decisions/decision-profiles]]
already states.

The fields nest. A program's fields are typed records, their elements and
sub-elements are typed records, and at the bottom each name or literal is a
typed text value from the section above. One mechanism runs from the program's
kind down to its characters.

**What is unbuilt**, measured in `.planning/FILE-KIND-STRUCTURES.md`: no file is
checked against its kind (contents checked for 0 of 6 extensions); a `.prog` is
checked only for defining its entry; conformance needs the subtyping
`modules-core` defers; no `.profile` file exists; `SpecRule.statement` is a
`Str`.

## Raw stays, a coder surface over it, ruled 2026-10-01

> "We need to go over elements and subelements that are required for
> different things so we can make syntax simpler and required fields
> straightforward, while using the structural knowledge to continue curbing
> possible syntax issues. Also, i do want s-expressions to remain a part of the
> language, just not the only way. Maybe raw becomes its own syntax a simpler
> coder surface elaborates too. Already doing file types so as long as it can
> translate to and from raw its useful"

The second half settles `surface-syntax/SY1`, written to its register row in
`records/author-calls.md` the same turn: s-expressions stay as raw, a simpler
coder surface is added over the same core, and the coder surface owes a
translation to raw and back. Whether raw is named as a kind of its own is left
open by the author's *"maybe"*.

The first half is the review the inventory serves. `.planning/FORM-INVENTORY.md`
is the extraction: every level from bytes to program purpose, each form's slots
with what each becomes, whether it is required, the refusal when it is wrong,
its redundancy and its hazard. It feeds `surface-syntax/SY2`, and the author
goes over it before the coder surface's slots are drawn.

## The kind map, outlined 2026-10-01

The author outlined which file kind carries which surface: `.chiral` is raw,
with a schema for splitting a codebase that every other kind is parsed to;
`.prog` is the coder view; `.port` the pure port-maker view; `.manifest` the
whole manifest realm; further kinds are drawn from the raw split. When one
program requires another, the requirement is navigable as file structure. The
words and the map are in `.planning/FILE-KIND-STRUCTURES.md` §Amended
2026-10-01, which is their home.

## Next

- A `revisit` of [[arcs/surface-syntax-arc]] against FD-66 to FD-70, folding
  the reader rules above into its roster as rows, with PRB-102 to PRB-104 as
  their evidence. Queued as `SR6` in `.planning/DISPATCH-QUEUE.md`.
- `SY1` goes to the author with the findings behind it.

## Open

1. ⚑ *Ruled 2026-10-01, see §Raw stays.* `SY1`: graduate the s-expression
   surface, or add a second notation over the same core. Open from it: whether
   raw is named as a kind of its own.
2. The Unicode choices the sources leave open, listed above.
3. Whether the surface becomes declared records throughout, per the section on
   the requirements structure.
4. Typed text in place of reader refusals, per the author's turn above, after a
   research run on PRECIS, IDNA2008 and typed-text precedents.
5. The required fields per kind of program, as declared types each file must
   inhabit.

## Rejected

None yet.
