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

## Research in flight

Five `research` runs dispatched 2026-10-01, one finding each, merged serially
into `records/findings.md`:

| id | question |
|---|---|
| FD-66 | which defect classes the record attributes to surface syntax, and whether removing the construct removed the class |
| FD-67 | whether LangSec's design rules for parsers reach a programming language's source reader |
| FD-68 | whether a complete, implementable policy for Unicode in source exists, and how much of it compilers ship |
| FD-69 | what controlled evidence says about syntax and readability, s-expressions included |
| FD-70 | how to specify a grammar provably unambiguous and small with a verifiable parser, and a canonical s-expression form |

## Open

1. `SY1`: graduate the s-expression surface, or add a second notation over the
   same core. The author's.
2. Whether "source equals its canonical print" becomes a reader rule.
3. The Unicode policy: which characters a reader accepts in identifiers,
   strings, comments and whitespace, and what it does with each of the rest.
4. Whether the surface becomes declared records throughout, per the section
   above.

## Rejected

None yet.
