---
node: arc-text-tools
layer: navigation
related: [arcs/README, goals/self-tooling, arcs/zero-python-arc, arcs/diagnostics-arc, records/baseline-alignment, index]
status: current
updated: 2026-09-01
---

# Arc: text tools as packable features

- goal: [[goals/self-tooling]]
- reserved element block: **none**. New rows write `UNASSIGNED`.
- serves: [[arcs/zero-python-arc]] (the tools it replaces), [[arcs/diagnostics-arc]]
  (the render half it shares)

## The shape

Not nine programs. A set of **tiny pure features**, each one an arrow between two
payload types, that a config packs into a set. `grep`, `fzf`, `cut`, `sort`,
`uniq`, `diff`, `wc` are not tools here; they are compositions of these features,
and a tool is a named pack plus an entry.

This is why the arc exists separately from [[arcs/zero-python-arc]]: that arc
tracks the nine Python files leaving, this one tracks the floor they leave onto.
A feature lands once and every tool downstream gets it.

Each feature is pure `->`, so it is a `flow-pure` step in
`prog/manas/core/flow.chiral` and needs no backend. The composition is checked by
`flow-ty` before anything runs.

## REQUIREMENTS

1. **Every feature is total.** A feature whose cost is not bounded in its input
   cannot be typed here, per `PRINCIPLES.md` §2. This is the requirement that
   picks the algorithm, see *Why the constraint helps* below.
2. **Every feature is pure `->`.** No feature reads a file or a directory. Corpus
   access is the caller's, which is what makes a feature testable without a
   fixture tree.
3. **Every feature is reachable from a pack, not only from a call site.** A
   feature no config can name is a library function, not a feature.
4. **Each replacement is verified against the tool it replaces on the same
   inputs**, inherited from [[arcs/zero-python-arc]] requirement 3.

## Why the constraint helps rather than costs

`.planning/PRIMITIVES-FOR-NATIVE-TOOLS.md`, measured from writing `prose-lint`:

> it forces a full-buffer scan per needle: 31 passes over 7 MB where one pass
> would do. That is why the native version is 2.4x slower than the awk one. **The
> algorithm is the cost, not the compiled code.**

and the constraint that follows:

> A backtracking regex engine has unbounded cost, and P2 says a process's cost is
> its type. The shape that fits is a **total matcher with a bounded arrow**.

A backtracking matcher cannot be typed here, so it cannot be written. What can be
typed is a one-pass automaton whose cost is linear in the input and independent of
the pattern count, and that is also the fast one. The language's constraint and
the performance win select the same algorithm. That is the argument for building
these here rather than shelling out, and it is measurable rather than aesthetic.

## The floor that already exists

Do not rebuild these.

| feature | provided by | element |
|---|---|---|
| read a file by path, read stdin | `openat` → `read-fd-all` | built |
| write a file, write stdout | `open-create` + `write-fd`, `put`/`print` | E105 |
| literal search, one needle | `str-find`, `str-find-from` (extern) | built |
| slice, length, concat | `str-sub`, `str-len`, `str-cat` (extern) | built |
| split on a separator | `str-split` | built |
| trim, pad, join, replace, case-fold | `prelude/string` | built |
| compare two strings | `str-cmp` | E151 |
| sort with a caller's comparator | `list-sort` | E152 |
| dedup adjacent | `list-dedup-adj` | E156 |
| take, drop, map, filter, fold, find | `prelude/list` | built |
| ordered map and set | `prelude/map`, `prelude/set` | E27 |
| layout: text, cat, line, nest, group, tag | `Doc` — `prelude/doc.chiral` | E158 |
| horizontal composition, tables | `Rendering` + `r-row` | E174 |
| print a chirality `Term` | `surface/pretty` | E181 |
| UTF-8 | `protocol/utf8` | built |
| JSON | `protocol/json` | built |

`Doc`'s `d-tag` carries a semantic role at **zero width and zero text**. That is
the render-side half of addressing, and it is already built.

## Minted, owed, and blocking

| element | feature | state | blocks |
|---|---|---|---|
| E173 | multi-pattern matcher, one pass, bounded | design. Example drafted, **no spec**, audit not run | everything below the line; 142 Python call sites |
| E148 | directory walk, `getdents64` | design. **No example, no spec** | every corpus tool; `flook.chiral` has 264 inert lines |
| E150 | `argv` | design. Example **and** spec exist; capability proven by a 15-line probe | pack selection at runtime |
| E176 | `str-sub` range discipline | design | correctness of every slice; BA-35 |

E173 is the keystone twice over: it is the fix for the 2.4x, and it is the
general operation that would open `PureFn`'s closed sum of six constructors.

## Owed, unminted — the author call

Five features with no element. Per `CLAUDE.md`'s deferral rule none is named as a
number anywhere until minted, and this arc holds no reserved block.

| feature | arrow | why it is owed |
|---|---|---|
| **subsequence predicate** | `Str -> Str -> Bool` | fuzzy select's core test. `completion.chiral` is 64 lines and prefix-only |
| **match score** | `Str -> Str -> I64` | ranking. `list-sort` already takes the comparator, so this is the whole remaining gap between prefix completion and fzf |
| **stable address** | a `Ty`, not a position | the one that matters. See below |
| **line diff / LCS** | `(List Str) -> (List Str) -> (List Edit)` | reviewing a patch, and the `-record.md` append discipline |
| **content digest** | `Bytes -> Str` | 3 call sites, 2 files. Named as an author call in [[arcs/zero-python-arc]] and still unminted |

### Addressing is the one that is not just a missing function

`prog/manas/core/flow.chiral` has `ty-span`, and a span is a **position**.
Positions rot exactly the way line numbers rot, and that rot is already four
rows in [[records/baseline-alignment]]: BA-13, BA-20 (294 citations naming a path
that does not exist), BA-21 (161 bare `:NN` spans with no subject a check can
name), BA-22.

A working stable-address scheme already exists in this repo, by hand:
[[records/README]]'s row IDs, with the invariant written down — *"Never renumber a
row that already exists. Its ID is cited elsewhere."* That is an address, and it
wants to be a type rather than a convention.

The output half is built (`Doc`'s `d-tag`). What is missing is the payload type
and the discipline that mints and preserves an id across an edit.

## What packing means, and what it needs

A pack is a named set of features. `MAP.md` already documents `.profile` as *"a
named frozen port set … which the build consumes and nothing imports"*, and
[[arcs/binary-split-arc]] measures what packing buys: a text tool that imports
`lowering/compile-all` for a ten-line fd reader carries 780 KB, where a tools tier
resolves to 27,222 bytes.

Two open questions this arc does not settle:

1. **Where a pack is declared.** `.profile` is documented with zero instances and
   no consumer (BA-10), while `prog/manas/profile/` holds nine working profiles
   written as `.chiral` values. The author has said `.chiral` is fine for now.
2. **Whether patterns are fixed at pack time or accepted at run time.** A pack of
   literal needles is fully bounded and checkable at compile time; runtime
   patterns are bounded per pattern but the set is dynamic. This changes E173's
   type and belongs in its spec.

## Resume state

Nothing is in flight. The order is forced by the dependency, not by preference:

1. **E173** — needs the pipeline run: worked example exists, spec does not, audit
   not run. Its fork is question 2 above.
2. **E148** — needs a worked example first; nothing exists.
3. **subsequence + score** — small, and unblocked by either. Two pure functions
   that turn `completion.chiral` from prefix-only into ranked select. The cheapest
   real progress in this arc.
4. **addressing** — wants a decision before an example, because it changes `Ty`.

**Owed from the author:** a reserved element block, or a ruling that this arc
mints into an existing one. Until then the five features above stay unnumbered and
this arc cannot schedule them.
