---
row: errors-as-values/EV12
arc: errors-as-values
title: the census becomes a check: a two-arm ok/err sum whose error arm is exactly one `Str` field fails it. Reads 30 today. Registers as a suite phase or as a `ledger-lint` check, and that placement is part of the row
kind: tool
origin: new
req: 5, and the observables of 1 and 3
status: draft
updated: 2026-09-23
---

# errors-as-values/EV12: the census becomes a check

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** a shape count over `lib/` and `prog/` becomes **re-derivable by a
  named predicate**, and the one predicate this arc's requirement 5 names
  becomes a gate that fails when it grows. A number written into a tracked
  document cites the predicate that produced it and the date it was read, so the
  citation survives the number changing.
- **Serves:** requirement 5 of [[arcs/errors-as-values-arc]], *"**A new boundary
  sum cannot land with a bare `Str` error arm.** Observed by a check that fails
  on the census predicate: a two-arm ok/err sum whose error arm carries exactly
  one `Str` field. It reads 30 today, and the number it is allowed to read is
  settled by `EV3`'s ruling."*
- **And the observables of requirements 1 and 3**, which this row does not own
  and which no other row can honour without it. Requirement 1 is observed by
  *"the rebuild-unchanged count falls from its 2026-09-23 baseline of 202"*, and
  requirement 3 by each converted constructor's arm count *"matching the distinct
  classes the census recovers from its own construction sites"*. Both are stated
  against counts that no committed instrument produces, so both are today
  unfalsifiable in the sense [[decisions/decision-scope]] names: a gate aimed at
  a guess passes by looking at nothing.
- **Goal:** [[goals/readable-surface]], condition 2. The row is also the only
  thing on this arc that touches [[goals/self-tooling]] condition 3, and §5
  question 1 is where that is disposed rather than borrowed.

⚑ **The obligation is larger than the row's sentence, and the evidence is in the
tree's own registers.** `records/author-calls.md`'s first row published
`76 / 47 / 29` for these quantities on 2026-09-23 and now carries, in the same
cell, *"The figures above are UNREPRODUCED and the call now carries a precondition
… No committed script implements any predicate, which is why the third answer
keeps appearing"*, and it names this row as what it waits on. `records/findings.md`
`FD-48` §11 reached the same wall from the other side, independently, and its
`evidence` field states the cause in one sentence: *"the scan script is not
committed and the method is stated in the row so it can be rerun."*

## 2. What the tree holds

Measured 2026-09-23. The bank comes first.

- **Bank:** this row's concept is a **check**, and [[banks/verification]] is its
  bank: *instruments, plural and independent*, each ranked by expectation
  provenance. [[banks/text]] refracts the same shard from the other side and
  states the composition this row is an instance of: *"a check is a matcher plus
  an authority"* (`docs/banks/text.md:148`, shard D).
  [[banks/effect-and-alarm]] is the **arc's** bank and does not reach this row:
  its subject is the alarm, and a count over declarations is not one.
- **The arc's own §3 already names the shard gap in prose**, in the
  `carrier` and `payload` rows whose `where` cell reads *"tree-wide census over
  `lib/` and `prog/`"* and *"same census"* with no instrument behind it.

### 2a. What counts the code today

| what exists | where | rung | reached by |
|---|---|---|---|
| **a committed census instrument, written because its figure was not reproducible.** `prog/optimizer-census.prog`, 225 lines, reads the compiler blob on stdin, runs `ck-fn` over every TFn and prints `census tfns=… ok=… err=…` plus a class line and a per-instance line | `prog/optimizer-census.prog:18`, *"⚑ IT EXISTS BECAUSE THE FIGURE IT PRINTS WAS NOT REPRODUCIBLE"*; the header at `:1-46` | IMPLEMENTED | `tools/test/opt-census.sh`, run by hand; and Phase 7, which compiles it |
| **the instrument asserts nothing; the verdict is a separate artifact.** Stated as a rule with its reason | `prog/optimizer-census.prog:24-26`, *"⚑ IT ASSERTS NOTHING AND ALWAYS EXITS 0. Every comparison lives in bash … A gate that re-derives its own verdict is green under any mutant that changes what the verdict says"* | IMPLEMENTED | — |
| **the verdict half**: four rows pinning the whole census line, four mutants, each pinning the WHOLE verdict rather than one row | `tools/test/opt-census.sh:88` (GA-19, no mutant removes an arm), `:94` (GA-21/GA-22, each mutant pins the whole line), `:140-148` the `WANT_*` pins | IMPLEMENTED | run by hand |
| **a chirality root that scans `lib/` and `prog/` source directly**, line at a time, path list on stdin, tab-separated rows out, exit code as the verdict | `prog/paren-audit.prog:1-27`; the enumeration reason at `:3-8` | IMPLEMENTED | by hand; and Phase 7 |
| **the same front end, stated as the tree's idiom and as the model a replacement follows** | `prog/prose-lint.prog:3-21`; [[arcs/zero-python-arc]] requirement 4 names it | IMPLEMENTED | Phase 19 gates the matcher underneath it |
| **the s-expression reader**, byte-directed, pure, errors as values. `read-all` at `:269`, `read-all-str` at `:272`, `read-all-forms` at `:286` returning `(List FormPos)` with a byte offset per top-level form | `lib/surface/sexp.chiral:269`, `:272`, `:286`; `Sexp` at `:12`, `FormPos` at `:35` | ENFORCED (E1, in the compiler blob; `docs/elements/catalog.md:95`) | three importers, **all inside the compiler front end**: `lib/surface/parse.chiral:42`, `lib/module/resolve.chiral:45`, `lib/module/sig-derive.chiral:15`. **No root under `prog/` reads source through it** |
| **the total matcher**, Antimirov partial derivatives, `pd`/`norm`/`find-all`, 602 lines | `lib/text/matcher.chiral`; `docs/elements/ledger.md:325` | IMPLEMENTED, slice 1 (E173); captures are slice 2 and unbuilt | `prog/prose-lint.prog:43`, Phase 19 |
| **a shape ratchet over source, in Python**: five exact-name regexes with a per-pattern baseline, failing only when a count GROWS | `OWNERSHIP_BASELINE` at `tools/ledger-lint/ledger-lint.py:728`, and `check_l` at `tools/ledger-lint/ledger-lint.py:732` | IMPLEMENTED | every `ledger-lint` run |
| **the only other reads of `.chiral` source by a tool**: a basename index (`:397`), a path-literal check (`:1092`), and `pack`'s structural outline, which splits on a bare `\(` | `tools/ledger-lint/ledger-lint.py:397`, `:1092`; `tools/pack/pack.py:405` | IMPLEMENTED | — |

⚑ **Nothing in the tree counts a declaration's shape.** Check L matches five
literal prefixes and knows nothing about arms or field types.
`prog/paren-audit.prog` counts parentheses. `prog/optimizer-census.prog` counts
TFns through the compiler. `tools/syscall-map/syscall-map.py:122` matches
`\(def (nb-sys-\S+) TFn` and is a single-purpose extractor. That is the whole
inventory, and the quantity this arc's three requirements are stated against is
in none of it.

### 2b. How a number in a tracked document is tied to its predicate today

Three conventions exist, and the tree uses all three. None of them is named, so
none of them is reachable by a citation.

| convention | the instance | what it buys | what it costs |
|---|---|---|---|
| **publish the predicate beside the number** | `.planning/ZERO-PYTHON-SCOPE.md:28-40`: a table of one `grep -c` pattern per need, under the sentence *"The greps, so the count is reproducible rather than re-derived"* | the number is re-derivable by hand, and `docs/arcs/zero-python-arc.md:44-47` cites the file for exactly this reason | nothing runs it, so both sides rot together |
| **the tool reads its patterns out of the document** | `ledger-lint` check O, `tools/ledger-lint/ledger-lint.py:784`, whose docstring reads *"The patterns are READ FROM THE DOC, not duplicated here — a second copy in code is a thing that drifts from the table it is supposed to enforce"*, over `.planning/RUNG1-CHECKLIST.md` §C-inventory | one authority, and the doc is it | the doc holds the rule, so the tool cannot independently pin the reading |
| **derive rather than trust, and fail on disagreement** | `ledger-lint` check Q, `:855`, which recomputes `records/conformance-map.md`'s LIVE tally from the file's own published counting rule | the claim and its measurement are compared on every run | it needs a published counting rule to transliterate |

⚑ **The row's defect is that the arc's numbers use none of the three.**
`docs/arcs/errors-as-values-arc.md`'s §3 table, `records/author-calls.md`'s first
row and `records/findings.md` `FD-48` §11 all carry figures whose predicate is a
sentence, and `FD-48` §11 is the measurement of what that costs: of six facts it
re-derived, **four moved and one was refuted**, and the `77 / 73 / 4` row reads
*"No predicate this run tried reproduces 77/73/4"*.

### 2c. Where a new gate goes, and what it costs to register one

| fact | where | rung |
|---|---|---|
| **Phase 7 sweeps EVERY root in the tree** by `grep -rl '^(def compile-main' lib prog`, so a new `prog/` root is compiled by the suite with **zero** registration | `tools/test/run-tests.sh:175`, and `:153-155` states the property | ENFORCED |
| **a compile is not an assertion**, and Phase 7's rows are deliberately outside the suite's assertion count | `tools/test/run-tests.sh:203-208` | ENFORCED |
| **the suite-phase-number question is RULED**, 2026-09-06: *"native tests and harnesses, and this file is the only authority for a phase number"*, and a gate takes the first number colliding with nothing. 8-12 stay owed, 21-23 stay Lane B's | `tools/test/run-tests.sh:347-353`; `records/author-calls.md:73`, token `ruled` | ENFORCED |
| **the last registered phase is 33**, so **34 is the first free number** | `tools/test/run-tests.sh:378` | measured |
| **`registration.sh` witnesses the dispatch table**, and a gate outside it must declare `not-a-phase:` with a reason | `tools/test/registration.sh:4`, `:34`, `:82` | ENFORCED |
| ⚑ **`opt-census.sh`'s own `not-a-phase:` reason is stale** against that ruling: `tools/test/opt-census.sh:5-11` cites the phase-number call as standing. Already recorded as `PRB-93`, *"a ruled question is still documented as a standing author call"* | `records/lenses/problems.md:1308`, `:1316` | OPEN, owner absent |

### 2d. The zero-python constraint, measured

| fact | where |
|---|---|
| [[arcs/zero-python-arc]] requirement 1: **"No `.py` file anywhere under the repo root, `tools/` and the four `docs/examples/refs/gen-*.py` generators included"**; requirement 2: `tools/` is **deleted** rather than emptied; requirement 4: every replacement runs on the tree's own test floor **the way `prog/prose-lint.prog` does** | `docs/arcs/zero-python-arc.md:30-37` |
| `tools/ledger-lint/ledger-lint.py` is **2,987 lines today**, against the **1,375** the arc records for it on 2026-09-04. It is the largest single item in wave 2, the last wave, behind `E148`, `E150` and `E173`-slice-2, none of which is built | `wc -l`, 2026-09-23; `docs/arcs/zero-python-arc.md:43`, `:76`, `:117` |
| ⚑ **zero-python does not cover the shell gate tier.** `GAP-02` records the 2026-09-06 ruling widening the target to *"native tests and harnesses"* and states the scope explicitly: *"The ruling widens this beyond zero-python, which covers the nine `.py` tools and not the shell gate tier."* 10,719 lines of shell under `tools/test/` against 1,775 native `.prog` lines | `records/lenses/gaps.md:20-28` |
| [[goals/self-tooling]] condition 3 is *"Every tool it held runs as a chirality program on the same test floor as the rest of the tree,"* observed by **each replacement having a phase in `tools/test/run-tests.sh`**, and **no row serves it** (`GAP-18`) | `docs/goals/self-tooling.md:29-32`; `records/lenses/gaps.md:243` |

### 2e. The name predicates are four namespaces, not one

Re-verified 2026-09-23 at each location.

| fact | where |
|---|---|
| **a constructor head is not a label.** *"Constructor names arrive as tag numbers (declaration order); only function names survive as strings, because they become labels"* | `lib/lowering/tal/ir.chiral:9-10` |
| **`r-redeclared` is raised for three subjects only**: `subj-extern`, `subj-atom` and `subj-data` (twice) | `lib/module/loader.chiral:460`, `:490`, `:551`, `:572` |
| **`subj-def` reaches `r-unbound` and `r-judged` and never `r-redeclared`** | `lib/typing/kernel.chiral:844`; `lib/module/loader.chiral:401`, `:424`, `:434`. No other site in `lib/` or `prog/` builds `subj-def` |
| **so `lib/typing/diag.chiral:348` renders a message nothing raises**, *"definition redeclared: "*, and the same holds for the `subj-ctor`, `subj-prim` and `subj-field` arms at `:346`, `:347`, `:349` | `lib/typing/diag.chiral:340-354` |

**A census that sums `def` names, `data` names, constructor heads and extern
names into one number is wrong in kind**, because the four are judged
differently at load and one of them is not judged at all. The register this row
writes carries that as a rule beside the three name predicates, not as a
comment; extern names are the fourth namespace and get no predicate here.

⚑ **This finding is not new and the tree already holds it.**
`docs/arcs/parts/lowering-and-emit-LE18.md:118-124` makes the same call from the
label space's side, on the same `lib/lowering/tal/ir.chiral:9-10` citation and a
probe of the same shape: two co-blobbed modules declaring distinct data types
that share a constructor head compile to a 33,144 B ELF and exit 0.
`docs/arcs/parts/lowering-and-emit-LE18.md:127` states the consequence in
general terms, *"any flat-space total that sums constructor heads into the label
space is wrong"*, and `docs/arcs/parts/lowering-and-emit-LE18.md:134-151` runs
the name census by a column-0 line method it states and does not commit. So the
three name predicates arrive with a prior reading and a prior method the
register has to reconcile rather than with a blank slate.

## 3. The delta

Three things are missing, and the third is the one that closes the defect.

1. **An instrument that reads a declaration's shape.** §2a's inventory counts
   parens, TFns and five literal names. Nothing reads a `data` form's arms, an
   arm's field types, or a `case` arm's binders. `lib/surface/sexp.chiral` is
   built, gives exactly that tree, and **no root under `prog/` uses it**.
2. **A verdict.** Requirement 5's *"a check that fails"* has no artifact. The
   ratchet shape it wants exists in Python at `ledger-lint.py:728` and reaches
   five fixed names.
3. **A register, so a document cites a predicate rather than a number.** §2b's
   three conventions are each used once and none is named, so a document has no
   way to say *which* count it means. This is the part that fixes the recorded
   defect: `records/author-calls.md`'s figures did not rot because the tree
   changed, they were never re-derivable, and a second correct scan cannot tell
   itself apart from a fifth wrong one.

**What is NOT missing, and is worth saying, because it changes the size.** The
reader, the matcher, the front-end idiom, the instrument-plus-gate split, the
mutant discipline, the phase number and the Phase 7 sweep all exist and are
cited above. This row composes them. It asks the substrate for nothing:
`prog/paren-audit.prog` proves a source scanner runs today, and
`prog/optimizer-census.prog` proves a census-plus-gate pair does.

**Verdict:** a real delta, three parts, one element.

## 4. The shapes

### 4a. Placement, which the row's own text makes part of the work

**Shape A: a new `ledger-lint` check (AO).**
- **Form:** one `check_ao()` in `tools/ledger-lint/ledger-lint.py`, an s-expression
  scan over `src_files()`, a `SHAPE_BASELINE` dict beside `OWNERSHIP_BASELINE`.
- **Costs:** no new file, and the ratchet idiom already exists at `:728`. Adds
  roughly 250 to 400 lines to a file that is **already 2,987 against the 1,375
  [[arcs/zero-python-arc]] budgeted for it**, in wave 2, the last wave, behind
  three unbuilt enablers. A paren-balanced reader in Python is a second
  implementation of `lib/surface/sexp.chiral` that the port will then have to
  reconcile with the first.
- **Forbids:** running on the test floor. `ledger-lint` is not a suite phase, so
  [[goals/self-tooling]] condition 3 and [[arcs/zero-python-arc]] requirement 4
  are both closed off by the choice, and `GAP-18` grows rather than shrinks.
- **The charter objection does NOT hold and should not be used**: `check_l` at
  `tools/ledger-lint/ledger-lint.py:732` matches five regexes over `lib/` and
  `prog/` source and ratchets on the counts, and check S at
  `tools/ledger-lint/ledger-lint.py:1092` reads each source file, blanks its
  comment lines and matches `(def <name> Str "literal")` out of the text, which
  is a declaration-shape read. So a code census is inside `ledger-lint`'s
  charter. The reason to decline it is the budget, not the scope.

**Shape B: a chirality census root plus a bash verdict gate.**
- **Form:** `prog/shape-census.prog` reads a newline-separated path list on
  stdin, parses each file with `read-all-forms`, and prints one
  `pred <id> n=<count>` line per predicate plus per-instance lines. It asserts
  nothing and exits 0. `tools/test/shape-census.sh` holds every pin and every
  mutant, and registers as `run_phase 34`.
- **Costs:** two new files plus a register document, roughly 750 to 1,050 lines
  in total. The gate half is shell and adds to the 10,719 lines `GAP-02`
  measures, which is a cost Shape C is charged for below and this shape pays
  too, smaller and with the counting native. Slower than Python: `prose-lint`
  runs 15.1x slower than mawk
  (`records/author-calls.md`, the emitted-speed budget row). No budget binds it
  (the 2026-09-01 ruling at `docs/benchmarks/README.md:29` makes wall clock a
  recorded number that sets no bar).
- **Forbids:** enumeration inside the tool, until `E148` lands. The caller hands
  over the path list, which is what `prog/prose-lint.prog:11-21` already states
  and gives the reason for.

**Shape C: a suite phase alone, in shell.**
- **Form:** `tools/test/shape-census.sh` does the counting itself in awk.
- **Costs:** one file, and it registers. But the counting and the verdict then
  live in the same artifact, which is the defect `prog/optimizer-census.prog:24-26`
  names by its own rule: a gate that re-derives its own verdict is green under
  any mutant that changes what the verdict says. It also adds to the 10,719
  lines of shell `GAP-02` measures, against a ruling that widened the target to
  cover exactly that tier.
- **Forbids:** a paren-balanced read. FD-48 §11's first row is the price: 12 of
  the 493 textual `(data ` occurrences are inside comments or string literals,
  and a line-oriented awk pass counts them.

**The tree settles this, and the citation is two-sided.**

1. **Shape B's instrument/gate split is forced by an existing worked instance
   built for this row's exact cause.** `prog/optimizer-census.prog:18` exists
   *because the figure it printed was not reproducible*; `:24-26` states why the
   instrument must not judge; `tools/test/opt-census.sh:88,94` states how the
   judgment is mutant-graded. Three of the five questions this row was told to
   answer are already answered in those files, with reasons.
2. **Shape A is debt against a stated goal requirement, and Shape C against a
   ruling that supersedes it.** `docs/arcs/zero-python-arc.md:30` forbids a new
   `.py`; growing the largest wave-2 file is the same debt without a new file.
   `GAP-02`'s 2026-09-06 ruling puts the shell gate tier inside the target too.
   Shape B is the only one of the three that **pays** requirement 4 rather than
   borrowing against it, and it is the only one that reaches `GAP-18`.

**The two legs are not the same strength, and saying so is the point.** Leg 1
is forced: `prog/optimizer-census.prog:24-26` states the instrument-must-not-judge
rule generally, names `prog/e188-apply-spine.prog` and `prog/e197-recording-sweep.prog`
as following it, and that settles the two-artifact split for any census here.
Leg 2 is a judgment on cited facts rather than a ruling: `zero-python-arc.md:30`
forbids a new `.py` and Shape A adds none, so what Shape A actually costs is
2,987 lines growing further at `:43`'s 1,375 budget in the last wave, and what
Shape B actually buys is a requirement (`:37`) and a goal condition
(`docs/goals/self-tooling.md:29-32`) that `GAP-18` records as served by no row.
Every fact behind leg 2 is tracked and every one points one way, so §5 takes it
as RESOLVED and no author call is owed. It is not, however, a fork the tree
already closed.

### 4b. The instrument's reader, which IS a live fork

**Shape R1: parse with `lib/surface/sexp.chiral`.**
- **Form:** `(import "surface/sexp")`, `read-all-forms` per file, then classify
  `Sexp` trees.
- **Costs:** the census depends on the compiler's own reader, so a reader defect
  moves the census. `MAX-DEPTH` is 200 (`:44`) and a file exceeding it yields
  `a-err` rather than forms, which the census must report rather than drop.
- **Forbids:** counting anything the reader drops. Comments and whitespace are
  gone at the lexer, which is exactly right here and is the thing FD-48 §11's
  481-against-485 row measures; it also means a predicate about **comments**
  has no expression. No predicate in §5's set wants one.
- **Buys:** the four namespaces (§2e) are structural rather than textual, so
  `(def f …)` inside a string literal cannot be counted, and a constructor head
  is read from its declaration rather than from a prefix.

**Shape R2: a hand-rolled line scanner, the `paren-audit` shape.**
- **Form:** fold over lines, track paren depth and in-string state, match
  `^\(data ` and `^\(def ` at column 0.
- **Costs:** re-implements the reader's string and comment handling, which is
  the source of the drift this row exists to remove. `prog/paren-audit.prog:14-20`
  gives the reason it chose lines (recursion depth over a 2,545-line file), and
  `read-all-forms` has the same exposure.
- **Forbids:** any predicate below the top-level form. `SC-rebuild-unchanged`
  and `SC-passthrough-case` are about a `case` arm's binders, which a line
  scanner cannot see. Three of the thirteen predicates are unreachable under it.
- **Buys:** no dependency on the front end, and a bounded stack.

**The call is R1**, on the third bullet: three of the predicates the arc's
requirements need are sub-form, and R2 cannot express them. The recursion
exposure is a real cost and §6's gate carries a row for it.

### 4c. How a document cites a predicate, which is the other live fork

**Shape P1: the gate is the citation.** A document writes the number and cites
the gate row that pins it. `tools/test/opt-census.sh`'s shape.
- **Costs:** the number is in two places and moves in one. When it moves the gate
  reddens, which is the point, but the document is edited by hand and can be
  missed. `records/lenses/problems.md:876` records four of five figures drifted
  in exactly this arrangement.
- **Forbids:** a document citing a predicate it has no reading for.

**Shape P2: the register is the authority and the tool reads it.** Check O's
shape, `tools/ledger-lint/ledger-lint.py:784`.
- **Costs:** the expected readings live in the document, so the tool cannot pin
  them independently and a wrong edit to the document is a green run.
- **Forbids:** the tool disagreeing with the document, by construction, which is
  the wrong thing to forbid here: disagreement is the signal.

**Shape P3: the citation names the predicate and the date, and the number is a
dated reading.** A tracked document writes ``30 (`SC-err-arm-bare-str`,
2026-09-23)``. The register `docs/definitions/shape-census.md` carries one row
per predicate: the id, the exact rule in words, what it deliberately excludes,
and the instrument's arm. The gate pins today's readings independently.
- **Costs:** every existing shape figure in the tree owes an amendment, and
  three of those files are live under another session right now.
- **Buys:** the id is stable while the number moves, which is the property §1
  asks for, and it is the only one of the three that has it. A stale number then
  reads as a stale **reading** with a date on it, which is what a record is for
  (`records/README.md:45-56`, the six-field row with `measured` and `checked`).
- **Forbids:** a number that cites nothing from being mistaken for a measured
  one. Half of that is mechanical: an `SC-` id with no register row is a grep.
  The other half, a bare number with no id, is not mechanically decidable and
  stays a `doc-audit` obligation. §5 question 4 says so rather than claiming the
  check is total.

- **Also costs:** the register holds each rule in words and the instrument holds
  it in code, and no gate row compares the two. R1 compares set membership, so a
  register row whose words drift from the arm it names is green. That is the
  residue P3 leaves where P2 leaves its own, and the register row naming the
  instrument's arm is what keeps the drift findable by hand.

**The call is P3 carried by P1's mechanism.** P3 is the citation form; the gate
still pins each reading independently, so a reading that moves reddens R2 and a
register row with no arm reddens R1. P2 is declined on its one cost: it makes
disagreement unrepresentable.

## 5. The call

- **Chosen:** Shape **B** for placement, **R1** for the reader, **P3 over P1**
  for the citation. One element: `prog/shape-census.prog` as the instrument,
  `tools/test/shape-census.sh` as the verdict at suite phase 34, and
  `docs/definitions/shape-census.md` as the predicate register that a tracked
  number cites.

### The predicate set

Thirteen predicates and one filter, fourteen register rows. Each is a register
row and one arm of the instrument.

| id | the rule | why it is separate |
|---|---|---|
| `SC-data-decl` | a top-level `data` declaration, read through `read-all-forms` so comments and string literals are gone before counting | the base every shape predicate refines, and the one figure `FD-48` §11 already re-derived (**481**, against an asserted 485) |
| `SC-result-sum` | a `data` whose arm set contains one ok-shaped arm and one err-shaped arm, under a **stated** arm-name rule the register spells out | this is the predicate that returned five answers. The rule is the deliverable, and the register carries what it admits and what it declines |
| `SC-result-sum-2arm` | `SC-result-sum` with exactly two arms | requirement 5's subject is the two-arm case |
| `SC-result-sum-nplus` | `SC-result-sum` with three or more | `FD-48` §11 found this band *"at minimum 13, not 4"* and named two instances |
| `SC-err-arm-bare-str` | the err arm of an `SC-result-sum-2arm` carrying **exactly one** field, of type `Str` | **requirement 5's gate predicate.** The arc reads **30** (`docs/arcs/errors-as-values-arc.md:75`, `:136`) and it has exactly one reading; the 47 it refines read **47**, **45** and **49** across the three scans `records/author-calls.md`'s first row records. The **29** that row also carries is the outside-closure count, which is `EV3`'s floor and not a second reading of this predicate |
| `SC-err-arm-str-plus` | the err arm carrying a `Str` beside at least one other field | the arc's §3 separates 30 from 17 and nothing re-derives the split |
| `SC-err-arm-declared` | the err arm's single field typed by a declared `data` name | the target shape, and requirement 2's observable |
| `SC-rebuild-unchanged` | a `case` arm that destructures an error constructor and applies a constructor to the same binders in the same order | **requirement 1's observable.** Read **196** (the figure `FD-48` §11 was handed), **199** (its own re-derivation, of which 147 carry an error-shaped constructor name), **202** (`docs/arcs/errors-as-values-arc.md:72`, `:115`), and **231**, which this design run produced and which no tracked document holds |
| `SC-passthrough-case` | a `case` whose every non-ok arm is an `SC-rebuild-unchanged` arm | what a `bind` deletes whole, as opposed to one arm at a time |
| `SC-hand-traverse` | a `def` that recurses over a cons list, applies a fallible operation per element, and returns on the first err arm | the shape an adoption row replaces with a combinator, and it is countable only sub-form |
| `SC-def-name` | distinct top-level `def` names | ⚑ §2e. Four namespaces, **never summed**. Extern names are the fourth and get no predicate here, because no requirement on this arc reads them; the register's namespace rule still names all four |
| `SC-data-name` | distinct `data` type names | ⚑ §2e |
| `SC-ctor-head` | distinct constructor heads, reported beside `SC-ctor-head-sites`, their total occurrence count | ⚑ §2e. `docs/arcs/parts/lowering-and-emit-LE18.md:147-151` records an earlier **1,367** heads, a re-measure at **1,147** heads / **1,180** sites, and its own scan at **1,169** / **1,202** (`:141`), by a method it states at `:134` and does not commit |
| *(filter)* `in-closure` | membership of `prog/compiler.prog`'s import closure, applied to any predicate above and reported as a second column | requirement 4 orders adoption by it, and it is a property of the file rather than of the declaration |

**What makes the set complete, and what it costs to add one.** The set is not
closed and cannot be, so the completeness test is stated the other way round:
**every shape figure in a tracked document resolves to a register row.** The
half that is mechanical is the gate's R5 row, a grep for `SC-` ids across `docs/`
and `records/` that fails on an id with no register row. The half that is not is
a bare number with no id, which no check can find, and which stays a `doc-audit`
obligation. The cost to add a predicate is **one register row, one arm in the
instrument, one pin in the gate**, on the order of 30 lines, and the register row
is written first because it is what the arm implements.

### Disposition

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Where it lives, against [[arcs/zero-python-arc]] requirement 1 | **RESOLVED** | §4a. `docs/arcs/zero-python-arc.md:30` forbids a new `.py` and `:43` with `:76` puts `ledger-lint` in the last wave at twice its recorded size, so Shape A is debt against a stated requirement. `records/lenses/gaps.md:20-28` (`GAP-02`) records the 2026-09-06 ruling widening the target to the shell gate tier, which reaches Shape C. `prog/optimizer-census.prog:18,24-26` is the worked instance of Shape B, built for this row's exact cause |
| 2 | Gate, report, or both | **RESOLVED — both, and the split across two artifacts is forced** | The instrument reports and asserts nothing, `prog/optimizer-census.prog:24-26` with its reason. The gate asserts. `EV12`'s own sentence (*"a check that fails"*) demands the gate half; requirement 1's falling baseline and requirement 3's per-boundary arm counts demand the report half, since a pass/fail carries no count to compare |
| 3 | How a tracked document cites a predicate | **RESOLVED** | §4c, Shape P3 over P1. The register `docs/definitions/shape-census.md` is the citable authority and the gate pins each reading independently, so the two can disagree. Shape P2 (`ledger-lint.py:784`, check O) is declined because it makes disagreement unrepresentable |
| 4 | What makes the predicate set complete | **RESOLVED, and the answer is partial by construction** | The test is that every `SC-` id cited in the tree resolves to a register row (gate row R5). The converse, a bare number citing nothing, is not mechanically decidable and is named as a `doc-audit` obligation rather than claimed |
| 5 | The gate for this row | **RESOLVED** | §6's gate block. The load-bearing row is R3, the hand-counted fixture: pinning the live readings alone grades a predicate against itself, which is the failure `records/lenses/problems.md` PRB-83 and `tools/test/opt-census.sh:94` both convict |
| 6 | The threshold `SC-err-arm-bare-str` ratchets **to** | **DEFERRED to `errors-as-values/EV3`** | That row exists on the arc's roster and its author call is already open, `records/author-calls.md` first row, token `unreviewed`, which names this row as its own precondition. The **direction** needs no ruling: the ratchet fails on growth above the pinned reading, which is `check_l`'s shape at `ledger-lint.py:732`. The **floor** (0 on the wide reading, 29 on the narrow) is `EV3`'s |
| 7 | The element number and band | **RESOLVED** | `UNASSIGNED`. [[arcs/errors-as-values-arc]] reserves no block and `docs/decisions/decision-lane-split.md` reserves none for it. The mint takes the next number free tree-wide, which is the disposition `docs/arcs/parts/errors-as-values-EV1.md` §6 already took for this arc |
| 8 | Whether a `.sh` gate is itself zero-python debt | **RESOLVED** | `records/lenses/gaps.md:20-28`: zero-python *"covers the nine `.py` tools and not the shell gate tier"*, and the 2026-09-06 ruling that widens the target names `prog/prose-lint.prog` and `prog/test-runner.prog` as the precedent, both of which keep a shell front end and move the checks into chirality. That is exactly Shape B's arrangement |

**No NEEDS-AUTHOR.** Every fork this row reaches is either settled by a tracked
document cited above or is `EV3`, which already carries an open author-call row.
No new row is written to `records/author-calls.md`.

## 6. The mint packet

- **Elements:** **one.** The instrument, the verdict and the register constrain
  each other in both directions: the register row is what the instrument's arm
  implements, and the gate's R5 row reads the register. Splitting the instrument
  from its gate reproduces `prog/optimizer-census.prog`'s own shape as two
  elements, which the tree did not do when it built that pair.
- **Band:** `UNASSIGNED`, per §5 question 7. The mint takes the next number free
  tree-wide; the highest in `docs/elements/catalog.md` today is **E200**.
- **Catalog row**, in the live five-column form at `docs/elements/catalog.md:93`:

  ```
  | E<NN> | **The shape census: a count over `lib/` and `prog/` that a document can cite by name** | Not built. Three new files and one edited line: `prog/shape-census.prog` reads a path list on stdin, parses each file with `read-all-forms` (`lib/surface/sexp.chiral:286`), and prints one `pred <id> n=<count>` line per predicate plus per-instance lines, asserting nothing and exiting 0; `tools/test/shape-census.sh` holds every pin and every mutant and registers as `run_phase 34`; `docs/definitions/shape-census.md` is the predicate register a tracked number cites as `` `SC-<id>`, <date> ``. Thirteen predicates and an `in-closure` filter, covering [[arcs/errors-as-values-arc]] requirement 5's gate predicate and the observables of its requirements 1 and 3. ⚑ **It exists because five scans of the same quantity returned five answers in one session and one of them reached `records/author-calls.md`**, whose first row now carries the precondition and names this row; `records/findings.md` `FD-48` §11 hit the same wall independently and re-derived four of six handed facts as moved and one as refuted. `prog/optimizer-census.prog:18` is the in-tree precedent, written for the same cause, and its `:24-26` rule that the instrument must not judge its own output is what forces the two-artifact split. ⚑ **`SC-def-name`, `SC-data-name` and `SC-ctor-head` are three namespaces and are never summed**: `lib/lowering/tal/ir.chiral:9-10` says a constructor head is a tag and not a label, and `subj-def` reaches `r-unbound` and `r-judged` only (`lib/typing/kernel.chiral:844`, `lib/module/loader.chiral:401,424,434`), so `lib/typing/diag.chiral:348` renders a redeclaration message nothing raises | `OURS`; `ledger-lint` check L's ratchet (`tools/ledger-lint/ledger-lint.py:728`) and `prog/optimizer-census.prog` are the two in-tree baselines (`IMPL`) | SH |
  ```

- **Ledger row**, in the live six-column form `## VAL · Pure value modules`
  carries at `docs/elements/ledger.md:298` (`E# | Module | State | Title | Cites
  | Track`). `:80` is the CK section's five-column header and is not this row's:

  ```
  | E<NN> | census | design | **The shape census: a count over `lib/` and `prog/` that a document can cite by name.** The gate half of [[arcs/errors-as-values-arc]], covering `errors-as-values/EV12` and serving requirement 5 directly and the observables of requirements 1 and 3. `prog/shape-census.prog` (instrument, asserts nothing), `tools/test/shape-census.sh` (verdict, phase 34), `docs/definitions/shape-census.md` (the predicate register). Reader is `lib/surface/sexp.chiral`'s `read-all-forms`, so three sub-form predicates are expressible that a line scanner cannot reach. Pays [[arcs/zero-python-arc]] requirement 4 and [[goals/self-tooling]] condition 3 rather than borrowing against them, which `GAP-18` records as served by no row | →`EV3`, →`EV5`-`EV11`, ←E1, ←E173 | SH |
  ```

- **Size:** three new files, one edited line, **roughly 750 to 1,050 lines**.
  - `prog/shape-census.prog`, **400 to 550**. Basis: `prog/paren-audit.prog` is
    244 lines for one predicate over a hand-rolled scanner and
    `prog/optimizer-census.prog` is 225 for a census with three output shapes.
    This one gets its reader free and spends the difference on thirteen
    classifiers and a per-predicate report.
  - `tools/test/shape-census.sh`, **250 to 350**. Basis: `tools/test/opt-census.sh`
    is **306** lines (`wc -l`, 2026-09-23) for four rows and four mutants over one
    instrument; this gate carries six rows and five mutants.
  - `docs/definitions/shape-census.md`, **80 to 150**. Fourteen rows plus the
    namespace rule and the citation form.
  - `tools/test/run-tests.sh`, **one `run_phase 34` line** plus its comment
    block, on the pattern of `:375-378`.
  - **No fixpoint obligation.** `prog/shape-census.prog` is a `prog/` leaf and is
    not in `prog/compiler.prog`'s closure, so `chirality_blob_file "lib:prog"
    prog/compiler.prog` is unchanged by this element, which is itself a gate
    assertion (the shape `prog/optimizer-census.prog:12-14` states for the same
    reason). `bin/chirality-bin` does not move. Phase 7's root sweep gains one
    root.

- **Gate**, answering §5 question 5. Six rows, and R3 is the one that separates
  a predicate that is correct from one that is merely self-consistent:
  1. **R1 — the census runs and reports every register row.** A register row
     with no reading fails, and a reading with no register row fails. This is
     the row that keeps the register and the instrument in step.
  2. **R2 — the live readings, pinned whole.** One line per predicate over
     `lib/` and `prog/`, the whole verdict line as the pin, per
     `tools/test/opt-census.sh:94` (GA-21, GA-22).
  3. **R3 — a hand-counted fixture.** One file under `tools/test/samples/`
     whose every declaration is classified by hand in its own comments, with at
     least one deliberate trap per predicate: a `(data ` inside a comment, a
     `(def ` inside a string literal, two co-blobbed data types sharing a
     constructor head, a three-arm result sum, an err arm carrying `Str` beside
     `(pos I64)`, and a `case` arm that rebuilds a **different** constructor from
     the same binders. Every predicate's reading over the fixture equals its hand
     count. `tools/test/tal-check.sh`'s 16 hand-built TFns is the precedent.
  4. **R4 — the ratchet.** `SC-err-arm-bare-str` does not exceed its pinned
     reading. Direction only; the floor is `EV3`'s (§5 question 6).
  5. **R5 — every `SC-` id cited under `docs/` and `records/` resolves to a
     register row.** A grep, so it costs nothing and needs no Python.
  6. **R6 — the reader's own failure is reported, not dropped.** A file that
     `read-all-forms` answers `af-err` on, or that exceeds `MAX-DEPTH`
     (`lib/surface/sexp.chiral:44`), appears in the output as a named skip and
     is counted. A census that silently drops a file it could not read is the
     failure `tools/test/run-tests.sh:153-155` names for Phase 7's own list.
  - **Mutants, each reverted, each pinning the whole verdict line** and none
     removing an arm (GA-19, `tools/test/opt-census.sh:88`):
     **M1 comment-blind** — the classifier reads raw bytes instead of the parsed
     tree, which must move `SC-data-decl` by the 12 textual occurrences `FD-48`
     §11 measured and is that finding in executable form.
     **M2 arm-rule-widened** — the err-arm name rule admits `bad`, `invalid` and
     `none`, which must move `SC-result-sum` and every predicate under it and
     nothing else. This is the exact spelling difference that produced two of the
     five scans.
     **M3 namespaces-summed** — `SC-ctor-head` counts `def` names too, which must
     move two readings and is caught by R2 rather than by R1.
     **M4 rebuild-loosened** — `SC-rebuild-unchanged` stops comparing binder
     order, which must move that reading alone and leave `SC-passthrough-case`
     behind it.
     **M5 register-row-dropped** — one row is cut from
     `docs/definitions/shape-census.md`, which must redden R1 and R5 together
     and no other row.

- **Related:** [[arcs/errors-as-values-arc]] · [[goals/readable-surface]] ·
  [[goals/self-tooling]] condition 3 · [[arcs/zero-python-arc]] requirements 1
  and 4 · [[banks/verification]] · [[banks/text]] shard D ·
  [[records/findings]] `FD-48` §11 · `records/author-calls.md` first row ·
  `records/lenses/gaps.md` `GAP-02`, `GAP-18` ·
  `records/lenses/problems.md` `PRB-93` · `E1` · `E173`

**Residue carried out of this run, for the arc amendment.**

1. **The arc's own numbers owe an amendment once this lands.**
   `docs/arcs/errors-as-values-arc.md` requirement 1's `202`, requirement 3's
   five per-boundary arm counts and requirement 5's `30` are all stated as bare
   figures. Under §4c's call each becomes a reading with a predicate id and a
   date. That is a doc edit across the arc file, `records/author-calls.md`'s
   first row and `records/findings.md` `FD-48` §11, and **two of those three
   files are live under another session today**, so it is named here and not
   taken.
2. **`PRB-93`'s residue reaches this element's gate.**
   `tools/test/opt-census.sh:5-11` states the phase-number call as standing when
   it was ruled on 2026-09-06. This element registers at 34 under the ruling, so
   the new gate must not copy `opt-census.sh`'s `not-a-phase:` header. Recorded
   at `records/lenses/problems.md:1308`, owner absent, and this row does not
   claim it.
3. **`GAP-18` is partly served and the arc cannot close it.**
   [[arcs/zero-python-arc]] requirement 4 has no roster row, and this element is
   one replacement running on the floor rather than the property being carried.
   Named, not claimed.
4. **Two decision documents disagree about whether an unbanded arc can mint,
   and this packet rides on the later one.** `docs/decisions/decision-work-ids.md:15-16`
   still reads *"minting one needs a reserved band"*, while
   `docs/decisions/decision-lane-split.md:60-61` carries the 2026-09-06 ruling,
   *"An arc with no band still mints. It takes the next free number and records
   the range it landed in"*, and `:48-49` makes a band *"where to look first"*
   rather than a claim. §6's `UNASSIGNED` is sound under the later and unsound
   under the earlier. Named here, owned by neither this row nor this arc.
5. Neither 1 nor 2 nor 3 nor 4 is deferred to anything unminted.
