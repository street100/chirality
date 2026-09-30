---
node: shape-census
layer: foundation
related: [pattern-boundary-sums, working-discipline, status-ledger, arcs/errors-as-values-arc, banks/verification]
status: current
updated: 2026-09-29
---

# The shape census: the predicate register

A count over the declarations in `lib/` and `prog/` is cited by the id of the
predicate that produced it and the date it was read. This file is where each id
is defined. `prog/shape-census.prog` (E201) implements every row below as one
named arm, and `tools/test/shape-census.sh`, suite phase 34, pins what each row
reads today and fails when this file and the instrument disagree.

The register exists because five scans of the same quantity returned five
answers on 2026-09-23 and one of them reached `records/author-calls.md` as the
`EV3` row. Every scan was right about its own predicate. None of them wrote the
predicate down where a second scan could find it.

## The citation form

A tracked document writes a shape figure as

```
<n> (`SC-<id>`, <date>)
```

for example ``33 (`SC-err-arm-bare-str`, 2026-09-29)``. The id stays fixed while
the number moves. A figure with a date is a reading, and a stale one is a stale
reading with its date on it.

Two checks hold the form. Gate row R5 fails on any `SC-` id under `docs/` or
`records/` that has no row here. A bare figure citing no id is invisible to a
grep, so finding one stays a `doc-audit` obligation.

## The input

The tracked source list,
`git ls-files lib prog | grep -E '\.(chiral|port|prog)$'`, one path per line.
Tracked files only: a file the author has not committed cannot move a pinned
reading. `.manifest` files are import targets that declare no `data`, `def` or
`case`, and they are left out.

Each path is read with `read-all-forms` (`lib/surface/sexp.chiral:286`), the
compiler's own reader, so comments and string literals are gone before
anything is counted. A file the reader refuses, or cannot open, is printed as a
`skip` line and counted. It is never dropped.

## The rows

Fifteen rows: fourteen readings and one filter. Each reading prints one line,
`pred SC-<id> n=<all> closure=<in>`, and one `inst` line per instance.

| id | the rule | what it excludes | the instrument's arm |
|---|---|---|---|
| `SC-data-decl` | a top-level form whose head is `data` | a `data` form inside a comment or a string literal; the instrument prints the raw-text count beside it as `text data n=`, with no row of its own | `sc-data-decl`, over `count-data-forms` |
| `SC-result-sum` | a `data` with exactly one ok-side arm and at least one err-side arm, under the arm-name rule below | a sum with two ok-side arms; a sum whose error arm is spelled outside the rule, such as `-invalid` or `-none` | `result-sum?`, over `ok-side?` and `err-side?` |
| `SC-result-sum-2arm` | an `SC-result-sum` with exactly two arms | three arms or more | `sum-hits` |
| `SC-result-sum-nplus` | an `SC-result-sum` with three arms or more | two arms | `sum-hits` |
| `SC-err-arm-bare-str` | the err-side arm of an `SC-result-sum-2arm` carries exactly one field, and its type is `Str` | a `Str` beside another field; a `Str` inside a compound type such as `(List Str)` | `err-arm-hits` |
| `SC-err-arm-str-plus` | that err-side arm carries two fields or more, and at least one is typed `Str` | a single field | `err-arm-hits` |
| `SC-err-arm-declared` | that err-side arm carries exactly one field, typed by a name in the `SC-data-name` set | `Str`, `I64`, `Bytes` and every compound type | `err-arm-hits`, resolved by `take-cands` after the last file |
| `SC-rebuild-unchanged` | a `case` arm whose pattern is `(H b1 … bn)`, `H` err-side, `n ≥ 1`, every `bi` a symbol, and whose body is exactly `(K b1 … bn)` with `K` err-side. The `inst` line ends `same` when `K` is `H` and `cross` otherwise | binders reordered; a body that wraps a binder in a call; a pattern with a nested sub-pattern | `rebuild-arm?`, comparing binders in order with `same-seq` |
| `SC-passthrough-case` | a `case` with at least one err-side pattern, in which every arm whose pattern head is outside the ok side is an `SC-rebuild-unchanged` arm | a case with a wildcard `_` arm or any other arm that is neither ok-side nor a rebuild | `passthrough?` |
| `SC-hand-traverse` | a top-level `(def f …)` whose body holds a `case` arm with pattern `(cons h t)`, whose body in turn holds a `case` carrying an err-side pattern arm that does not call `f` and an arm that does | a recursion over a list with no fallible step; a fallible step with no early return | `traverse?`, over `cons-step?` and `fallible-step?` |
| `SC-def-name` | distinct top-level `def` names | `declare` and `extern` names; a `def` inside a string literal | `def-hits`, into a distinct-name set |
| `SC-data-name` | distinct `data` type names | constructor heads | `data-hits`, into a distinct-name set |
| `SC-ctor-head` | distinct constructor heads over every `data` arm | `def` names, which live in another namespace | `ctor-heads-of`, into a distinct-name set |
| `SC-ctor-head-sites` | constructor heads counted with multiplicity, one per `data` arm | nothing: two types sharing a head count twice here and once under `SC-ctor-head` | `ctor-heads-of`, tallied per head |
| `in-closure` | the filter. A file is inside when its module key closes a module in `prog/compiler.prog`'s blob, read from the blob's line-anchored `(end-module "<key>")` markers. Every reading above prints its inside count as `closure=` | `prog/compiler.prog` itself, which is the blob's root and carries no marker. The blob closes 61 modules and one of them, `lib/lowering/tal/target-linux.manifest`, is outside the input, so 60 input files carry the tag | the gate tags each input line with `closure`; the instrument resolves nothing |

## The arm-name rule

The rule behind `SC-result-sum` is `EV1`'s wide predicate,
`docs/arcs/parts/errors-as-values-EV1.md:75`.

- **ok side:** a head ending `-ok`, or the head `ok!`, or a head ending `-r` in
  a sum or a `case` that also carries an err-side head.
- **err side:** a head ending `-err`, `-bad` or `-fail`, or the head `bad!`.

The ground is `EV1`'s `:83-84`: `TimeR` (`lib/ports/clock.port:21-23`) spells
its arms `-r` and `-err`, `ChkR` (`lib/module/loader.chiral:62`) spells them
`ok!` and `bad!`, and whichever predicate the arc meant, those nine sums are
boundary sums. Whether the author meant the strict rule instead is an open
question under `records/author-calls.md:52` (`EV3`). A strict ruling changes
`ok-side?` and `err-side?` and re-pins the gate, and every number that ruling
states moves with it.

A field's type is the last element of its field form, so `(msg Str)` reads as
`Str` and `(1 why Reason)` reads as `Reason`.

## The four namespaces

`SC-def-name`, `SC-data-name` and `SC-ctor-head` are three namespaces and are
never summed. Extern names are the fourth, and no row counts them.

- A constructor head is a tag: *"Constructor names arrive as tag numbers
  (declaration order); only function names survive as strings"*
  (`lib/lowering/tal/ir.chiral:9-10`).
- `docs/arcs/parts/lowering-and-emit-LE18.md:127` states the consequence: any
  flat-space total that sums constructor heads into the label space is wrong.

A figure that adds two of these counts is wrong in kind, whatever it reads.

## What the register does not check

No gate row compares a row's words here with the arm it names. R1 compares the
two id sets, so a rule whose words drift from its arm stays green. The arm
column is what keeps that drift findable by hand.

## Related

[[arcs/errors-as-values-arc]] · [[pattern-boundary-sums]] ·
[[working-discipline]] · [[banks/verification]] · `E201` · `E1`
