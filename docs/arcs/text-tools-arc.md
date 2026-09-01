---
node: arc-text-tools
layer: navigation
related: [arcs/README, goals/self-tooling, banks/text, arcs/zero-python-arc, arcs/binary-split-arc, records/baseline-alignment, index]
status: current
updated: 2026-09-01
---

# Arc: the text primitives

- goal: [[goals/self-tooling]]
- reserved element block: **none**. New rows write `UNASSIGNED`.
- serves: [[arcs/zero-python-arc]] (the nine tools it replaces),
  [[arcs/binary-split-arc]] (what a tool binary carries)

The concept, refracted across its homes, is [[banks/text]]. Read it before
saying this arc is missing something.

## The bet

**Four primitives, not a tool set.** The classic text tools are compositions of a
very small number of operations, and this repo already has most of them. The work
is to find the smallest set that gives full coverage, not to port `grep`.

The test of the bet is the coverage table below: if a classic tool is not a short
composition of things in this repo, the primitive set is wrong.

## Coverage — what the primitives have to yield

| classic tool | composition | status |
|---|---|---|
| `grep` | `find-all` + `filter` | needs P1 |
| `grep -c` | `find-all` + `length` | needs P1 |
| `cut`, capture groups | `find-all` → spans → `str-sub` | needs P1 |
| `sed s///` | `find-all` + `str-replace` over spans | needs P1 |
| `tr` | `map-list` over bytes | **built** |
| `sort` | `list-sort` with a caller's comparator | **built**, E152 |
| `uniq` | `list-dedup-adj` | **built**, E156 |
| `wc` | `foldl` | **built** |
| `head`, `tail` | `ms-take`, `ms-drop` | **built** |
| `fzf` | subsequence pattern + P2 score + `list-sort` | needs P1, P2 |
| `diff` | P3 | needs P3 |
| `comm`, `join` | P3, or a sorted merge | needs P3 |
| `column`, `fmt` | `Doc` + `r-row` | **built**, E158/E174 |
| `jq` | `protocol/json` | **built** |
| citation checking | `find-all` + P4 addresses | needs P1, P4 |

Two results fall out of writing this table:

**`tr` and case-folding need no primitive.** A byte-class map is `map-list` over
`Bytes`, and `str-replace` covers the literal case. An earlier draft of this arc
listed a byte map as owed; it is not.

**Fuzzy matching needs no matcher of its own.** A subsequence test is the pattern
`.*n.*e.*e.*d.*l.*e.*` under P1. What fzf actually needs beyond P1 is the *score*,
because `list-sort` already takes the caller's comparator. That is P2, and it is
small.

## The primitives, as elements

An arc is a group of elements and each of these is one element. Four are the text
floor; two are enablers this arc depends on but does not own.

### P1 — the matcher, returning spans · **E173**, minted, `design`

`find-all : Ctx -> Pat -> Bytes -> (List Span)`.

Already drafted at `docs/examples/E173-total-matcher.md` as an **Antimirov
partial-derivative** matcher: `pd` returns the residual set, `step-set` advances
it, `accepts` decides, and `run-from : Bytes -> I64 -> I64 -> (List Pat) -> I64
-> I64` already returns *the end offset, or -1*. So the drafted design is span
-shaped at the bottom; what is owed above it is the all-matches enumeration.

**It returning spans rather than `Bool` is what makes it one primitive instead of
four.** A span answers "does it match", "where", "what did it capture" and "how
many" with one pass. Six rows of the coverage table collapse onto it.

State: worked example drafted, **no spec, audit gate not run**.

### P2 — match score · `UNASSIGNED`

`score : Pat -> Str -> I64`, pure, total.

The whole remaining gap between `completion.chiral` (64 lines, prefix-only) and
ranked select, because `list-sort` already takes the comparator. Small.

### P3 — edit script over two sequences · `UNASSIGNED`

`diff : (-> (0 A) (-> A A Bool) (List A) (List A) (List Edit))`.

Generic in the element type, so it serves lines, spans, rows and records.
Yields `diff`, `comm` and `join`, and it is what makes reviewing a patch and
appending to a `-record.md` mechanical rather than manual.

### P4 — the stable address · `UNASSIGNED`

A payload type plus the discipline that mints an id and preserves it across an
edit. **Not merely a missing function**, which is why it is last and hardest.

`prog/manas/core/flow.chiral` has `ty-span`, and a span is a *position*.
Positions rot the way line numbers rot, and that rot is four rows in
[[records/baseline-alignment]] already: BA-13, BA-20 (294 citations naming a path
that does not exist), BA-21 (161 bare `:NN` spans with no subject a check can
name), BA-22.

A working scheme exists in this repo by hand — [[records/README]]'s row ids, with
the invariant written down: *"Never renumber a row that already exists. Its ID is
cited elsewhere."* That is an address, and it wants to be a type.

The render half is already built: `Doc`'s `d-tag` carries a semantic role at zero
width and zero text.

### Enablers this arc depends on and does not own

- **E148** `getdents64`, the corpus walk. Minted, `design`, no example, no spec.
  `flook.chiral` holds 264 inert lines waiting for it.
- **E150** `argv`. Minted, `design`; example and spec exist and the capability is
  proven by a 15-line probe over `/proc/self/cmdline`.

A content digest is owed by [[arcs/zero-python-arc]] (3 call sites, 2 files) and
is **not** a text primitive; it is provenance. It stays that arc's author call.

## How this is actually used

Three layers, and only the third is a packaging choice.

**1. A feature is a module.** `lib/text/*`, imported the way `prelude/string` is.
Inside a chirality program a primitive is an import and nothing more. This is not
a decision; it is how the module key works.

**2. A tool is an entry.** `MAP.md`: *"a `.prog` defines an entry, and two entries
in one blob is a duplicate label."* One entry per blob is structural, so a tool is
a `.prog`.

**3. One entry or many is a packaging decision, and it is cheap either way.**

- **Many:** one tiny `.prog` per tool. [[arcs/binary-split-arc]] measured the
  tools tier at **6 modules, 27,222 bytes** against the 780 KB a tool costs today
  by importing `lowering/compile-all` for a ten-line fd reader. A per-tool binary
  over the text tier is in that range.
- **One:** a single entry dispatching on `argv`. `bin/chirality` already does
  exactly this for `compile | run | check | test | help`, so the precedent is in
  the tree.

The measured cost says there is no bundling pressure. A multi-call entry needs
E150 anyway, and E150 is needed regardless. **So the library is the artifact and
the entry shape can change later without touching a primitive.** This arc does not
settle it, and does not need to.

## REQUIREMENTS

1. **Every primitive is total.** A primitive whose cost is not bounded in its
   input cannot be typed here, per `PRINCIPLES.md` §2.
2. **Every primitive is pure `->`.** None reads a file or a directory. Corpus
   access is the caller's, which is what makes each testable without a fixture
   tree, and what makes each a `flow-pure` step in `manas/core/flow.chiral`.
3. **The coverage table holds.** Every row is a short composition, or the
   primitive set is wrong and this arc changes rather than the table.
4. **Each replacement is verified against the tool it replaces on the same
   inputs**, inherited from [[arcs/zero-python-arc]] requirement 3.

## Why the constraint picks the algorithm

`.planning/PRIMITIVES-FOR-NATIVE-TOOLS.md`, measured from writing `prose-lint`:

> it forces a full-buffer scan per needle: 31 passes over 7 MB where one pass
> would do. That is why the native version is 2.4x slower than the awk one. **The
> algorithm is the cost, not the compiled code.**

and:

> A backtracking regex engine has unbounded cost, and P2 says a process's cost is
> its type. The shape that fits is a **total matcher with a bounded arrow**.

A backtracking matcher cannot be typed here, so it cannot be written. What can be
typed is a one-pass automaton, linear in the input and independent of the pattern
count, which is also the fast one. E173's drafted partial-derivative design is
that shape. The constraint and the performance win select the same algorithm.

## Resume state

Order is forced by dependency, not preference.

1. **P2 score** — unblocked by anything, small, and turns prefix completion into
   ranked select. Cheapest real progress in the arc.
2. **P1 / E173** — needs the pipeline: example exists, spec does not, audit not
   run. Its open fork belongs in that spec: are patterns fixed at pack time, fully
   bounded and checkable at compile time, or accepted at run time, bounded per
   pattern with a dynamic set? That changes the type.
3. **P3 diff** — independent of P1; can run in parallel with it on another day.
4. **P4 addressing** — wants a decision before an example, because it changes a
   payload type that `Flow` already uses.

**Owed from the author:** a reserved element block, or a ruling that this arc
mints into an existing one. Until then P2, P3 and P4 stay unnumbered and cannot
be scheduled.
