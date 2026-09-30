---
node: arc-text-tools
layer: navigation
related: [arcs/README, goals/self-tooling, banks/text, arcs/zero-python-arc, arcs/binary-split-arc, records/text-tools, records/baseline-alignment, index]
status: current
updated: 2026-09-29
---

# Arc: the text primitives

- goal: [[goals/self-tooling]]
- reserved element block: **`E260-E263`**, [[decisions/decision-lane-split]], reserved 2026-09-10. Its rows are `P1` to `P4`, the arc-local id
  scheme [[decisions/decision-work-ids]] settles and this arc invented first.
- serves: [[arcs/zero-python-arc]] (the nine tools it replaces),
  [[arcs/binary-split-arc]] (what a tool binary carries)
- checklist: [[records/text-tools]], prefix `TT`, opened 2026-09-20 by the
  revisit of this arc against `GAP-13`, `PRB-59` and `PRB-60`.

The concept, refracted across its homes, is [[banks/text]]. Read it before
saying this arc is missing something.

## The bet

**Four primitives, not a tool set.** The classic text tools are compositions of a
very small number of operations, and this repo already has most of them. The work
is to find the smallest set that gives full coverage, not to port `grep`.

The test of the bet is the coverage table below: if a classic tool is not a short
composition of things in this repo, the primitive set is wrong.

⚑ **The coverage table tests one half of this arc.** It decides whether a classic
tool is a short composition of things here. It says nothing about whether the
classic tool stopped being run. That second half is REQUIREMENT 4, and it is the
deliverable: *"Each replacement is verified against the tool it replaces on the
same inputs"*. No roster row serves it. `GAP-13` is the row that enumerates the
hole, `open` at `records/lenses/gaps.md:173-185`. Every primitive here could be
built, every cell of the table could read **built**, and not one Python or shell
tool would have been replaced, with every gate in this arc still reading green.
§Adoption holds what that has already cost, measured twice.

## Coverage — what the primitives have to yield

| classic tool | composition | status |
|---|---|---|
| `grep` | `find-all` + `filter` | **built**, E173 slice 1 |
| `grep -c` | `find-all` + `length` | **built**, E173 slice 1 |
| `cut`, capture groups | `find-all` → spans → `str-sub` | spans built; capture groups need E173 slice 2 |
| `sed s///` | `find-all` + `str-replace` over spans | **built**, E173 slice 1 |
| `tr` | `map-list` over bytes | **built** |
| `sort` | `list-sort` with a caller's comparator | **built**, E152 |
| `uniq` | `list-dedup-adj` | **built**, E156 |
| `wc` | `foldl` | **built** |
| `head`, `tail` | `ms-take`, `ms-drop` | **built** |
| `fzf` | subsequence pattern + P2 score + `list-sort` | needs P2 |
| `diff` | P3 | needs P3 |
| `comm`, `join` | P3, or a sorted merge | needs P3 |
| `column`, `fmt` | `Doc` + `r-row` | **built**, E158/E174 |
| `jq` | `protocol/json` | **built** |
| citation checking | `find-all` + P4 addresses | needs P4 |

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
floor; two are enablers this arc depends on but does not own. `P5` is `P1`'s
cost, rostered apart from it because E173 is built and the automaton is new work.

### `text-tools/P1` — the matcher, returning spans · element **E173**

`find-all : Pat -> Bytes -> (List Span)`.

**The `Ctx` argument this sketch used to carry is gone.** The one-byte window an
assertion decides against is derived inside the scan from `(bs, i)`:
`(at-byte bs (- i 1))` and `(at-byte bs i)` build a `Win`, and `-1` reads as off
the end of the buffer. The type is named `Win` because
`lib/typing/kernel.chiral` already spends `Ctx` on the typing context, the loader
holds one namespace for data declarations, and `prog/prose-lint.prog` pulls both
modules into one blob.

Built as the **Antimirov partial-derivative** matcher the example drafted: `pd`
returns the residual set, `norm` is the line the live-set bound lives in,
`step-set` advances the set, `run-from` returns *the end offset, or -1*, and
`find-at` keeps the longest accept. The all-matches enumeration the draft owed is
`scan-go`, one pass whose live threads each carry the offset they started at.

**It returning spans rather than `Bool` is what makes it one primitive instead of
four.** A span answers "does it match", "where", "what did it capture" and "how
many" with one pass. Six rows of the coverage table collapse onto it.

State: **implemented for slice 1**, 2026-09-01. `lib/text/matcher.chiral`, 602
lines, with `prog/prose-lint.prog` as its first consumer. Gated by Phase 19,
`tools/test/matcher.sh`: 18 assertions and 12 mutants, none inert, each mutant
pinning the full verdict line. G9 compares the eight native checks against the
awk tool over 80 files through `prose-lint --summary` and the totals agree
exactly. Pipeline: example drafted and gated (`33204e6`), spec written
(`be2aa94`), spec audit BLOCKED on two author calls and re-audited to PASS once
they were ruled (`4769cd2`), implementation over six commits ending at
`e882568`.

⚑ **Slice 2 is unbuilt.** Captures are tagged derivatives for the 77 capture
sites the census counted, and they stay inside E173. ⚑ **The native tool carries
eight of the awk tool's ten checks**: `self-reference` and `first-person` print
NOT-CHECKED rows. ⚑ `BA-39` records a mutant in this element's own gate that
passed by looking at nothing; step 6 retargeted it as G10, which observes the
divergence under a stack and time ceiling instead of asserting a refusal the
compiler cannot make. ⚑ `BA-40` records the awk tool's two divergent check sets,
which is why G9 runs through `--summary`. ⚑ **The wall clock is measured,
twice.** This note read *"The wall clock is unmeasured"*. `prog/prose-lint.prog`
ran **9.35x** the awk tool min against min on 2026-09-04
([[benchmarks/text-matcher-prose-lint]], after `9f46c6c`), and **15.2x** on
2026-09-29 over a 154-file corpus (`.planning/LANGUAGE-PROFILE-2026-09.md:24`).
Corrected 2026-09-29.
`docs/elements/specs/E173-total-matcher-SPEC.md`.

⚑ **The built matcher is one-pass and linear, and it pays for its automaton at
every byte.** [[records/findings]] `FD-56` §1 measured it: `scan-go` conses a
thread per offset (`lib/text/matcher.chiral:452`), `pd` builds residual trees,
and `norm` (`:284`) sorts the live set at each byte, 1,186.3 MB over
the G9 corpus, and `prose-lint` runs it once per pattern, eight passes a line
(`prog/prose-lint.prog:207-214`). The published form that computes each residual
set once and scans every pattern in one pass is the derivative automaton, which
is new work with its own blocking conditions, so it is its own row,
`text-tools/P5`, with the literal prefilter the published engines put in front
of it. E173's `pd` and `norm` are P5's transition function, and
E173's scan is the path P5 falls back to when its cache thrashes, so nothing
built here is replaced.

⚑ **Slice 2's captures run inside a span already found.** RE2 locates first and
extracts second, and `FD-56` §7 finds the order forced: the scan finds the span,
then tagged derivatives or a one-pass table run over that span alone.

### `text-tools/P2` — match score · element `unminted`

`score : Pat -> Str -> I64`, pure, total.

The whole remaining gap between `completion.chiral` (64 lines, prefix-only) and
ranked select, because `list-sort` already takes the comparator. Small.

**The algorithm, from `FD-56` §8.** A subsequence filter under P1 keeps the
candidates, and an optimal alignment score is a dynamic program over query by
candidate, O(m·L) per candidate, which is fzf's default `v2`. Where unit-cost
edit distance suffices, Myers's bit-vector computes the same matrix a word at a
time, O(⌈m/w⌉·L), at 17 word operations per byte once a 256-entry table is built
per query. Both need a table written in place: `FD-56` item (k), the in-place
indexed write on an `I64` buffer under a linear binder, held since 2026-09-29 by
`memory-discipline/M8`, the linear indexed buffer.

### `text-tools/P3` — edit script over two sequences · element `unminted`

`diff : (-> (0 A) (-> A A Bool) (List A) (List A) (List Edit))`.

Generic in the element type, so it serves lines, spans, rows and records.
Yields `diff`, `comm` and `join`, and it is what makes reviewing a patch and
appending to a `-record.md` mechanical rather than manual.

**The algorithm, from `FD-56` §9.** Myers's O(ND) diff in linear space:
O((M+N)·D) time, O(M+N) space, and a recursion that halves D, whose bound M + N
is the termination measure. It updates two V vectors of O(D) integers in place
at every step; built from persistent lists it costs O(D²) cells, so it waits on
the same in-place indexed write as P2. **The signature above admits Myers and
refuses patience and histogram**, which count occurrences of each element and
so need an order or a hash on `A`. Histogram's output was judged better on code
changes in 62.6% of files against Myers's 16.9% (`FD-56` §9). `FD-57` §5 bears
on which: a hash's speed rests on a secret seed a pure `->` pass cannot hold, or
states a linear worst case, so the admitted carrier is an order, a comparator on
`A`. Whether P3 takes one is P3's design question.

### `text-tools/P4` — the stable address · element `unminted`

A payload type plus the discipline that mints an id and preserves it across an
edit. **Not merely a missing function**, which is why it is last and hardest.

`prog/prapanca/core/flow.chiral` has `ty-span`, and a span is a *position*.
Positions rot the way line numbers rot, and that rot is four rows in
[[records/baseline-alignment]] already: BA-13, BA-20 (294 citations naming a path
that does not exist), BA-21 (161 bare `:NN` spans with no subject a check can
name), BA-22.

A working scheme exists in this repo by hand — [[records/README]]'s row ids, with
the invariant written down: *"Never renumber a row that already exists. Its ID is
cited elsewhere."* That is an address, and it wants to be a type.

The render half is already built: `Doc`'s `d-tag` carries a semantic role at zero
width and zero text.

**The shape, from `FD-56` §10.** Identity belongs to atoms, and a span is two
anchored endpoints. An identifier is an (origin, sequence) pair of two
integers, resolved to an index through an order-statistic tree in O(log n), and
the resolve is typed `Maybe` because an identifier whose atom was deleted
resolves to nothing. The hand-kept row-id scheme is that pair with one origin.
`prelude/map` is balanced and carries a height per node and no subtree size
(`lib/prelude/map.chiral:19-21`), so the order-statistic query is one field
away. The tree is ordered by position, and `FD-57` §5 keeps it that way: an
ordered structure holds the O(log n) bound a type can state, where a public hash
states a linear one.

### `text-tools/P5`: the derivative automaton over a pattern list · element `unminted`

`P1`'s matcher paid for once per state, over every pattern in one pass, behind a
literal prefilter. Each span comes back with the index of the pattern that
matched it. Evidence: [[records/findings]] `FD-56` §1 to §6.

- **States.** A state is `norm`'s canonical residual set, and over a list of
  patterns it is a regular vector, one residual per pattern (Brzozowski, through
  Owens, Reppy and Turon). A memo from state to state number is `prelude/map`
  under `pat-cmp`. `FD-57` §5 is why the memo is ordered: a hash states a
  linear worst case or needs a seed a pure pass cannot hold, and a state number
  is an interned id compared in one instruction.
- **The scan.** One transition per (state, byte class), computed once. A match
  end is found forward and its start by the reversed pattern run backward from
  it, which is one more automaton. The scan allocates nothing, by construction;
  its wall clock is unmeasured.
- **A pattern that arrives at run time.** The E173 SPEC's decision 1 stands: a
  `Pat` is a runtime value, because `pack.py` builds one from `argv`
  (`docs/elements/specs/E173-total-matcher-SPEC.md:114-143`). Eager
  construction is exponential in the pattern, which totality refuses, so the
  automaton is built lazily in a cache of fixed capacity threaded through the
  scan as a linear value: O(m·n) worst case, space fixed at construction. When
  the cache thrashes, E173's scan runs. The capacity is a number that sets a
  bar, and [[records/author-calls]] holds it as *"The state capacity
  `text-tools/P5`'s lazy automaton holds"*.
- **A closed pattern set.** The same builder evaluated at compile time over a
  closed `Pat` yields a constant table. Emitting it is the lift
  [[records/author-calls]] holds as *"Whether a quantity-0 static value may be
  lifted into emitted code"*, `unreviewed`, and its carrier is
  `lowering-and-emit/LE29`'s closed constant. The lazy builder is complete for
  a closed set as well, so this row's run-time half stands whichever way the
  call goes, and nothing in it is replaced by the table.
- **Blocking conditions.** An in-place indexed write on an `I64` buffer under a
  linear binder, and an indexed read that lowers to one load: `FD-56` items (k)
  and (i), held by `memory-discipline/M8` since 2026-09-29.
- **The prefilter.** A required literal extracted from each pattern is
  searched ahead of the automaton, which confirms each candidate. Every one of
  `prose-lint`'s eight patterns carries one (`prog/prose-lint.prog:75-146`,
  `lib/text/matcher.chiral:103`), and ripgrep skips its regex engine outright
  when a literal hit is a match (`FD-56` §5). A `memchr`-shaped find-byte needs
  a word load and count-trailing-zeros, `FD-56` item (j), held by no roster row
  today; the same operation is the proper `str-split`. Shift-Or and BNDM need
  only `and`, `or`, `shl` and `+`, all in the `Op` sum, over at most 64
  positions a word (`FD-56` §6). Teddy needs a vector lane, which no row
  schedules. Which form the row carries is its design's.
- **Consumer.** `prog/prose-lint.prog`'s eight `count-pat` passes
  (`:207-214`) become one.

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

## Roster

Four primitives, and one row that carries `P1`'s cost. Their full prose is in the
sections above; this is the countable form.

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `text-tools/P1` | the matcher, returning spans | primitive | primitive | new | 3 | built | `E173` |
| `text-tools/P2` | match score | primitive | law | new | 3 | open | `unminted` |
| `text-tools/P3` | edit script over two sequences | primitive | law | new | 3 | open | `unminted` |
| `text-tools/P4` | the stable address | primitive | primitive | new | 3 | open | `unminted` |
| `text-tools/P5` | the derivative automaton over a pattern list behind a literal prefilter, each span with its pattern's index, built lazily in a fixed-capacity cache at run time, `FD-56` §1 to §6 | primitive | primitive | new | 5 | open | `unminted` |

### Coverage

⚑ **Requirements 1, 2 and 4 are served by no row**, and all three are
enumerated: `GAP-11` for totality, `GAP-12` for purity, and `GAP-13` for
differential verification against the tool each replaces. Each is a property
every primitive must carry rather than a deliverable of its own, which is why
the arc states them once instead of four times.

Requirement 3 is served by P1 to P4. Every row serves one, and every `origin` is
`new`.

Requirement 5 is a property every primitive carries, like 1 and 2, and P2, P3
and P4 carry it in their own rows. `P1` is built, so the cost its published form
owes beyond E173 is a row of its own, `P5`. The wall-clock half of
requirement 5 has a measurement for `P1` and none for the rest.

⚑ **`GAP-13` is a different kind of hole from `GAP-11` and `GAP-12`, and the
enumeration reads all three as one.** Totality and purity are properties of a
primitive, decidable on the primitive alone against its own type, which is why
stating them once for all four rows is enough. Differential verification is an
act taken on a tool after the primitive exists: it needs the Python or shell
original still on disk, one set of inputs, and a run of both. Nothing in P1 to
P4 carries it and no row schedules it. Filing it with the other two understates
what it costs.

⚑ **Coverage is not what failed here. Adoption is.** REQUIREMENT 3 ends *"Every
row is a short composition, or the primitive set is wrong and this arc changes
rather than the table"*, which licenses re-cutting this roster when a classic
tool turns out to want a primitive the set lacks. No cell of the coverage table
has failed that test. What has never been taken is the differential run, and
that belongs to REQUIREMENT 4. Precisely: the table holds and the replacements
did not happen.

⚑ **The roster is left uncut on purpose, 2026-09-20.** The proposal on the table
was to re-cut P1 to P4 so that replacement became the spine in place of
composition. The author refused it, in these words: *"implementation wise these
are the same primitives so maybe just doc it all and stop trying to cut out
content"*. The primitives are the same work under either cut, so a re-cut buys
nothing and costs content. The missing half is written down instead, in
§Adoption. This ruling was given in session and is **not** a row in
[[records/author-calls]]; that register is unchanged by it.

## Adoption — the half REQUIREMENT 4 asks for, and what it has cost twice

REQUIREMENT 4 inherits from [[arcs/zero-python-arc]] requirement 3, which states
the consequence plainly at `docs/arcs/zero-python-arc.md:33-35`: *"Each
replacement is verified against the tool it replaces, on the same inputs, before
the Python is removed. A port whose equivalence is unverified does not count as a
port."*

**This tree has already run that experiment twice, and both results are in.**
Both are ported programs that nothing adopted, which is REQUIREMENT 4 failing in
the only two places it has been tried. Figures below re-measured 2026-09-20 by
the revisit that wrote this section; the rows themselves are `records/lenses/`
history and are cited rather than edited.

**`prog/resolve.prog` has no consumer, and the shell resolver it would replace
spread.** `PRB-59`, `OPEN`, `records/lenses/problems.md:826-838`. `grep -rIn
'resolve\.prog' --include='*.sh' --include='*.chiral' --include='*.prog' .`
returns 2 hits outside the file itself, `lib/module/resolve.chiral:22` and
`:406`, both prose comments, so nothing executes it. `grep -rl
'chirality-resolve' tools/ bin/ | wc -l` returns **27**, against the 25 that row
measured on 2026-09-06 and the fifteen in its own title. The chirality provider
is live as a library and dead as a tool. ⚑ The E87 cell the row quotes has moved
from `docs/elements/catalog.md:117` to `:120`, where it still calls the two
providers *"pinned against each other and both live"*.

**`prog/paren-audit.prog` has no consumer, and the Python it ports is still the
one that runs.** `PRB-60`, `OPEN`, `records/lenses/problems.md:840-852`. `wc -l`
reads the port at **244** lines and `tools/paren-audit/paren-audit.py` at
**154**, the figures that row recorded. `grep -rn 'paren-audit\.prog' lib/ prog/
tools/ bin/` returns three hits and none is a call: `prog/paren-audit.prog:7` and
`:8` are its own usage header, and `tools/README.md:12` is the row that names it,
which reads the Python as running *"unchanged"* with equivalence
**"unverified"**, so the Python is neither retired nor deletable. The
differential that would retire it has never been run.

**P1 is the one row here where a differential was taken, and it covers output
only.** G9 lives at `tools/test/matcher.sh:514-534`: it runs the eight native
checks and the awk tool over one corpus through `prose-lint --summary` and fails
unless the totals agree, which is REQUIREMENT 4 met on output for one primitive.
Three things bound it. `tools/README.md:23` records `prose-lint.sh` surviving as
the front end for ranking, baseline, `--regress`, per-line output and
code-skipping, so the shell tool was reduced and not retired. ⚑ The wall clock is
measured: this sentence read *"The wall clock is still unmeasured"*, and
`prog/prose-lint.prog` ran 9.35x awk on 2026-09-04 and 15.2x on 2026-09-29, which
§Why the constraint picks the algorithm cites. Corrected 2026-09-29.
⚑ The corpus is a glob, `CORPUS="docs/arcs docs/decisions docs/definitions"` at
`tools/test/matcher.sh:515`, and it enumerates **137** `.md` files on
2026-09-20, against the 80 recorded in P1's state note; the floor the gate
refuses under is 40, at `:518`. Nothing about G9 generalises to P2, P3 or P4:
each will owe its own differential against the tool it displaces, and no row
holds that obligation today.

## REQUIREMENTS

1. **Every primitive is total.** A primitive whose cost is not bounded in its
   input cannot be typed here, per `PRINCIPLES.md` §2.
2. **Every primitive is pure `->`.** None reads a file or a directory. Corpus
   access is the caller's, which is what makes each testable without a fixture
   tree, and what makes each a `flow-pure` step in `prapanca/core/flow.chiral`.
3. **The coverage table holds.** Every row is a short composition, or the
   primitive set is wrong and this arc changes rather than the table.
4. **Each replacement is verified against the tool it replaces on the same
   inputs**, inherited from [[arcs/zero-python-arc]] requirement 3. ⚑ This is
   the arc's deliverable and no roster row serves it. `GAP-13` enumerates the
   hole and §Adoption holds the two measured instances, `PRB-59` and `PRB-60`.
5. **Every primitive runs the fastest published algorithm that is total and
   pure, and states that algorithm's bound in its inputs.** [[records/findings]]
   `FD-56` names each: the derivative automaton for `P1`, O(n) per scan over a
   built table and O(m·n) with a lazy cache, independent of the pattern count;
   a dynamic program behind a subsequence filter for `P2`, O(m·L) a candidate;
   Myers's diff for `P3`, O((M+N)·D) time in O(M+N) space; an order-statistic
   resolve for `P4`, O(log n). The wall clock is recorded against the tool each
   replaces, on requirement 4's inputs. The ratio it must reach is a bar and is
   the author's: [[records/author-calls]] holds it as *"The budget
   [[goals/emitted-speed]] condition 4 holds a shipped native tool to"*, and the
   author's 2026-09-01 ruling at `docs/benchmarks/README.md:29` records the
   clock and sets no bar until then.

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
count, which is also the fast one. The constraint and the performance win select
the same algorithm.

⚑ **E173 is one-pass and linear, and it runs once per pattern.** This section
read *"E173's partial-derivative matcher is that shape and it is built"*. It
also recomputes its automaton state at every byte: [[records/findings]] `FD-56` §1 and §4, 1,186.3 MB
allocated in matching over the G9 corpus (`.planning/LANGUAGE-PROFILE-2026-09.md:132`).
The shape that is all three is the derivative automaton, `text-tools/P5`, whose
transition function is E173's own `pd` and `norm`. **What totality rules out is
narrow** (`FD-56` §11): backtracking with no visited set, and eager subset
construction over a run-time pattern with no state cap. Corrected 2026-09-29.

⚑ **The 2.4x above is the pre-E173 figure, and the post-E173 ratio is
measured.** This paragraph read that no run had re-measured it and that
`docs/benchmarks/` had no file for it. [[benchmarks/text-matcher-prose-lint]]
measured **9.35x** awk on 2026-09-04, and `.planning/LANGUAGE-PROFILE-2026-09.md:24`
measured **15.2x** on 2026-09-29 over the grown corpus. REQUIREMENT 4 is met on
output by G9; requirement 5 records this clock. Corrected 2026-09-29.

## Resume state

Order is forced by dependency, not preference.

1. **P2 score**: small, and turns prefix completion into ranked select. ⚑ This
   item read *"unblocked by anything"*. Its dynamic program and its bit-vector
   table each need an in-place indexed write on an `I64` buffer (`FD-56` item
   (k)), held by `memory-discipline/M8`. Corrected 2026-09-29.
2. **P1 / E173**: **slice 1 is built**, 2026-09-01. The open fork this list used
   to carry is closed by the SPEC: a pattern is a runtime value, because a pattern
   in the corpus is built from `argv` and staticness buys no totality. What
   remains inside E173 is slice 2, the captures, whose first step is classifying
   the 77 capture sites into served-by-split-scan and needs-a-submatch.
3. **P3 diff**: independent of P1, and waiting on the same in-place indexed
   write as P2 for Myers's V vectors (`FD-56` §9).
4. **P4 addressing**: wants a decision before an example, because it changes a
   payload type that `Flow` already uses.
5. **P5 automaton**: waits on the in-place indexed write and a one-load indexed
   read (`FD-56` items (k) and (i)), and on the capacity call for its cache. Its
   compile-time table waits on the quantity-0 lift call as well; its run-time
   half does not. Its prefilter's word-wide form waits on a word load and
   count-trailing-zeros (`FD-56` item (j)); the Shift-Or form waits on nothing.

**That blocker is spent, 2026-09-06.** This section read "owed from the author: a
reserved element block ... until then P2, P3 and P4 stay unnumbered and cannot be
scheduled." Author call B was ruled that day: a band is advisory, and an arc
without one mints the next number free tree-wide, which `pack.py --mint`
implements. Nothing here waits on a block.

**Pulled forward 2026-09-10, and the reason is not this arc's own.**
[[goals/coding-agent]]'s edit tool is `P3` and `P4` wearing another name. Today
`fs-edit` (`prog/shilpa/tools-fs.chiral:88`) is read, first-occurrence
`str-splice`, write: a positional replace with no address that survives an edit.
`P4` is that address and `P3` is the edit script over it. The order stands as
written, `P4`'s decision before `P3`'s build, because `P4` changes a payload type
`Flow` already uses.
