---
row: enforcement/N11
arc: enforcement
title: every gate row names a mutant that is actually run, checked mechanically rather than per gate by hand
kind: tool
origin: new
req: 6
status: blocked
updated: 2026-09-29
---

# enforcement/N11: every gate row names a mutant that is actually run, checked mechanically

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** after every suite run, a check that no gate script wrote reads
  what each gate printed and reddens on any counted row that no run mutant
  turned red, unless the row's own file declares why none can. Today that
  judgment exists only as hand audits in [[records/gate-audit]], and each one
  went stale the day it was taken.
- **Serves:** requirement 6 of [[arcs/enforcement-arc]]
  (`docs/arcs/enforcement-arc.md:373`), "**Every gate row names a mutant that
  is actually run.**" The row owns `GAP-03` (`records/lenses/gaps.md:33`,
  `owner: enforcement/N11` at `:44`), closed on the author's 2026-09-06 note
  *"native tests and harnesses. Carried with GAP-02: a native harness is what
  makes a mutant checkable mechanically"* (`:37`).
- **Goal:** [[goals/enforcement]], condition 4 (`docs/goals/enforcement.md:36-38`).
  Its text still reads *"No row serves this"*.
- **The open call this row carries and does not answer.**
  `records/author-calls.md:98` asks whether condition 4 quantifies over gate
  rows or over bug classes, at `unreviewed`. The two readings ask different
  things of this mechanism, and §4 prices both:
  - *Rows.* The mechanism below is the whole deliverable.
  - *Classes.* Each traced row also carries a class id from
    `docs/definitions/bug-classes.md`, and a second fold over that column and
    the class register reports classes with no covered row. That fold is
    `enforcement/N21`'s deliverable (`docs/arcs/enforcement-arc.md:552`). This
    row then owes only the column, reserved in the trace format, so either
    ruling costs no format change.

## 2. What the tree holds

Measured 2026-09-29 at `271c712`, with the author's working tree as left.
Every `file:line` below was opened this run.

- **Bank:** [[banks/verification]] shard 7, *expectation provenance and the
  run-the-mutant rule*, reads **DOCS ONLY** outside the native floor
  (`docs/banks/verification.md:260-264`). The rule's home is
  `docs/definitions/testing-floors.md:287-292`: a gate row must name a
  mutant that falsifies it, *"and the mutant must be RUN"*. The bank's
  one-line form is at `docs/banks/verification.md:95-97`. No bank shard holds
  a mechanical check of the rule, and this run builds none. The concept sits
  in shard 7, and its build-state line is the gap this row sizes.

### Reading 1: the suite, taken

`bash tools/test/run-tests.sh`, 4m44s wall, exit 0:
`assertions: 441 passed, 0 failed`, `compile-only: 96 roots built, 0 failed`,
`gate PASSED`. That reproduces the brief's figures.

**The 441 is short by 50.** `run_phase` reads a phase's count with
`grep -oE '[0-9]+ passed, [0-9]+ failed'` and adds nothing when the grep finds
nothing, with no `else` (`tools/test/run-tests.sh:134-138`). Five dispatched
phases print `N ok, M FAIL` instead: `apply-word.sh:290`,
`capture-fields.sh:257`, `defunc-blame.sh:395`, `apply-spine.sh:376`,
`crypto.sh:401`. Their 11 + 9 + 11 + 11 + 8 = 50 rows run and gate by exit
code, and the assertion count omits them. The log holds **491** `ok` lines
against the reported 441, and the 19 tallies that do parse sum to exactly 441.
The tally reads nothing from those five phases and reports that as nothing to
add, which is the shape `ledger-lint` checks AM and AL had until `fa4461a` and
`fe5fd88`.

### Reading 2: the inventory the brief asks for

Rows counted by their printed labels. Session script `inv.awk` over the suite
log; the rule: a counted `ok` line is a *mutant row* when its label starts
`M<n>` or carries `reddens`, `RUN:`, `mutant`, `poison` or `mutat`, else a
*base row*.

| measure | count |
|---|---|
| `ok` lines in the dispatched phases, phase 1 and the registration witness | 491 |
| mutant rows | 196 |
| base rows | 295 |
| mutant rows that print the observed red set (`G1:bad …`, `RUN: 'ok bad …'`, `reddens exactly [...]`) | 46 |
| mutant rows that print a count only (`1 row(s) red, exactly the pinned ones`) | 39 |
| mutant rows that print neither | 111 |

The label rule is itself a heuristic. `syscall-manifest.sh`'s four poison rows
(`tools/test/syscall-manifest.sh:113-121`) carry none of the markers and count
as base rows. That a script is needed to guess which rows are mutants is the
measurement: **no format in the tree says which row a mutant reddened**, so the
fraction of the 295 base rows with a run mutant cannot be read off the suite's
output today. It can be read for the 46 lines that print a vector, and the fold
over those reproduces three hand audits exactly:

| phases | fold over the printed vectors | the hand record it matches |
|---|---|---|
| 4, `profile-target.sh` | 11 of 34 base rows in no pinned red set | GA-04's *"eleven rows are reddened by nothing"* (`records/gate-audit.md:145`), carried on as PRB-56, `OPEN`, `unreviewed` (`records/lenses/problems.md:784`) |
| 6, `linear-mint.sh` | 22 of 32 in no pinned red set | GA-07's *"Ten of the thirty-two rows now have a falsifier"* (`records/gate-audit.md:174`), whose state reads `FIXED` |
| 25 to 28 | one row reddened by no mutant, `defunc-blame.sh` R1 | the script's own header, `R1 … graded, unfalsified` (`tools/test/defunc-blame.sh:29`) and `:96-98` |

So at least **34 counted rows carry no run mutant today**, inside a suite that
reads green, and GA-07's `FIXED` covers ten of its thirty-two.

**Mutants that run under no dispatched phase.** Three `PEND` gates carry
mutants the suite never executes: `shape-census.sh` eight
(`tools/test/shape-census.sh:34-46`), `opt-census.sh` four, `tal-check.sh`
three. The registration witness names all three as outside the table
(`registration.sh` output this run: `7 of 29 scripts are outside the dispatch
table by their own declaration`). `mutant.sh`'s matrix is PRB-55, `OPEN`,
`owner: none` (`records/lenses/problems.md:770`).

### Reading 3: the rule is re-implemented per script

`grep -nE '^[a-z0-9_]*(mutant|mut|mutlib|poison)[a-z_]*\(\)' tools/test/*.sh`,
excluding `mutant.sh`: **36 helper definitions in 20 scripts.** Three scripts
source the library instead (`check-cli.sh:118`, `profile-target.sh:220`,
`linear-mint.sh:434`). Ten scripts carry a header map from row to mutant in the
form `[M1,M2]` (`grep -cE '^#.*\[(M[0-9]+[a-z]?[, ]*)+\]'`). A map is a claim:
GA-21 found `matcher.sh`'s `[M4-adjacent]` beside a row M4's own pin leaves
green (`records/gate-audit.md:310`). One dispatched phase carries no mutant by
declaration, `transport.sh:34-37`.

| what exists | where | rung | reached by |
|---|---|---|---|
| the rule, stated | `docs/definitions/testing-floors.md:287-292` | DESIGNED | every gate author, by hand |
| the four silent failures, closed by assertion in one library | `tools/test/mutant.sh:39-57` | IMPLEMENTED | three dispatched phases |
| the full-line pin: a mutant's row pins the whole verdict, computed by the function that graded the base | GA-18, `records/gate-audit.md:283`; e.g. `tools/test/apply-word.sh:255-258` | ENFORCED where used | about ten scripts |
| the two-sources witness: directory against dispatch table, one declaration bit living in the file it describes | `tools/test/registration.sh:22-40`, `:103-104` | ENFORCED | `run-tests.sh:397` after the table |
| a counted loop, so a loop whose body never ran is a FAIL | `registration.sh:57-60` (GA-19) | ENFORCED | registration M1 |
| needles assembled, so the checker's own source cannot satisfy its check | `registration.sh:77-82` | ENFORCED | registration |
| native: a `Gate` cannot be built without a `MutRun` | `lib/evidence/test-floor.chiral:501-503`, `:641` | IMPLEMENTED | Phase 2 only |
| the native type's limit: one `MutRun` per gate, public constructors | `test-floor.chiral:506-513`, `:530-532`; `docs/definitions/testing-floors.md:389-390` | stated | nothing |
| the per-row verdict vector N10's port protocol asks for | `docs/arcs/parts/enforcement-N10.md:237-242` | DESIGNED, blocked | nothing |
| the hand audit | [[records/gate-audit]], 26 rows; three passes in 2026-09-04 and -05 | record | nothing re-derives it |

### Reading 4: N10's witness, and whether this is the same mechanism

`docs/arcs/parts/enforcement-N10.md` (`87b41e6`) claims four things
(`:228-246`): a native judge floor, registration moved native with a reach row
over judge programs, a reach census, and a port protocol whose clause (a)
has the shell gate and the native judge agree *"row for row"* over *"the base
tree and every mutant the shell gate names"*. Registration's subject is the
dispatch table. This row's subject is the per-row verdict under each mutant.
The two meet at one artifact: clause (a) needs a per-row vector per mutant,
and nothing prints one uniformly today (Reading 2). **Two mechanisms, one
data format.** §5 draws the line.

## 3. The delta

**Verdict: a real delta, three parts.**

1. **A trace.** Each gate prints, from the helper that grades it, one base
   line and one line per mutant carrying the mutant's name, whether it matched
   and built, and the observed vector over the gate's row ids. Today 111 of
   196 mutant rows print no vector and 39 print a count, and row ids are
   unstable labels in about half the scripts.
2. **A fold.** A witness no gate wrote reads the phase logs of the same run and
   reddens on: a counted row in no run mutant's red set with no declaration; a
   dispatched phase log with no trace and no declaration; a log with no
   parseable tally. The third is Reading 1's 50 rows, and the fold convicts it
   on its first run.
3. **A declaration.** One comment line per exempt row in the gate's own file,
   `no-mutant: <row> <reason>`, on registration's `not-a-phase:` shape.
   `defunc-blame.sh` R1, `transport.sh` and GA-08's `(memory ...)` rows are
   the cases today. Declared rows print as `OWED`, neither pass nor fail, as
   registration prints `PEND`.

Not in the delta: re-running mutants (each gate already runs its own, and the
fold reads that evidence), and the `PEND` gates' dispatch (author-held).

## 4. The shapes

### Shape S, parse the static maps
- **Form:** read the `[M…]` header maps and check that each row lists a mutant
  and that the mutant's name appears in a helper call.
- **Costs:** one script, no gate changes.
- **Forbids:** nothing about running. It reads claims, ten scripts carry them,
  and GA-21 measured one lying. It has exactly the shape this row exists to
  remove. Refused.

### Shape R, re-execute every mutant from outside
- **Form:** a meta-harness applies every declared mutant and re-runs the phase
  under it, the `mutant.sh --matrix` shape.
- **Costs:** 3m00s for seven mutants (GA-01, `records/gate-audit.md:102`);
  196 mutant rows would multiply the suite's 4m44s several times. It also
  re-implements each gate's mutation and so drifts from it.
- **Forbids:** a gate lying about a mutant it ran. That lie is already closed
  per gate by the full-line pin (GA-18). Refused on cost and duplication.

### Shape T, trace and fold
- **Form:** Part 1's trace from every helper, Part 2's fold as a witness that
  runs after the table in `run-tests.sh` on registration's route (GA-24's
  reason: a witness under its own `run_phase` line cannot fire), Part 3's
  in-file declaration.
- **Trace, one grammar:** `trace base <row>:<ok|bad> …`;
  `trace mutant <name> matched=<n> built=<yes|no> <row>:<ok|bad> … [class=<id>]`;
  printed from the observed vector, so a green run and the fold
  read the same evidence the gate graded.
- **The witness's own falsifiers,** each pinned on its full verdict line and
  run over copies of the real run's logs:
  - W1: every mutant trace line deleted in turn; the reddened set equals the rows
    that line alone covered, and the loop count equals the trace-line count;
  - W2: a trace at `built=no` or `matched=0`, which must cover nothing;
  - W3: an inert mutant whose vector equals base, which covers nothing;
  - W4: a phase log with its trace removed, which must redden;
  - W5: an empty log set, which must redden. The witness asserts it read one
    log per dispatch line, counted by registration's own `dispatched`;
  - W6: a `no-mutant:` line with its reason stripped;
  - W7: a trace naming a row absent from its base line.

  W4 and W5 are what keep the witness off AM's and AL's shape. A run that
  reaches no verdict reads red.
- **Costs:** one edit per helper, 36 in 20 scripts plus one in `mutant.sh`
  for three; stable row ids where a script has none; one new witness file.
  No compiler build, since the fold is text over logs.
- **Forbids:** a counted row with no run mutant and no stated reason; a gate
  that stops printing its trace; a tally format the suite cannot read.
  All wanted.

### Shape N, per-row `MutRun` on the native floor
- **Form:** every gate a `Gate` value, with `Gate`'s single `adequacy` field
  (`test-floor.chiral:641`) widened to one `MutRun` per check.
- **Costs:** the whole tier ported, which is N10's port programme; blocked on
  N10's Q5 (`docs/arcs/parts/enforcement-N10.md:275`) and on `J1`.
- **Forbids:** omission per row by construction. It inherits the floor's
  forgeability (`test-floor.chiral:506-513`). This is the endpoint, and it
  cannot start this year. Deferred, and the trace is the evidence format a
  port carries over.

## 5. The call

- **Chosen:** Shape T. It is the one shape that reads what was run, costs no
  compiler build, and lands without N10's blocked calls. It also supplies the
  per-row vector N10's port protocol clause (a) otherwise has to invent.

**The line against N10.** This row owns the trace grammar, the coverage fold
and the `no-mutant:` declaration. N10 owns the judge floor, registration's
port, the reach census and the port protocol, and its clause (a) consumes this
row's traces as the two vectors it compares. Neither row claims the other's
file. The witness is a new file beside `registration.sh`, and registration
gains nothing from this row.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | What counts as a gate row | **RESOLVED → a row the suite's assertion line counts** | `run-tests.sh:430` prints the count. Phase 2 grades itself through E168's per-gate `MutRun` and Phase 7 *"asserts nothing"* (`:433`), so both stay outside |
| 2 | Where the witness runs | **RESOLVED → after the table, by `run-tests.sh` itself, no phase number** | GA-24's reasoning, `registration.sh:1-11`; `run-tests.sh:380-397` |
| 3 | Trace from the pin or from the observation | **RESOLVED → the observation** | GA-18: the want is computed by the function that graded the base; a trace of the pin would be a second copy of a claim |
| 4 | Does condition 4 quantify over rows or classes | **DEFERRED → `records/author-calls.md:98`** | carried and unanswered. The `class=` field is reserved so either ruling costs no format change; the class fold is `enforcement/N21` |
| 5 | Does GAP-03's note, *"a native harness is what makes a mutant checkable mechanically"* (`records/lenses/gaps.md:37`), require this witness to be native, which sequences it behind N10's element and N10's three open calls? | **NEEDS-AUTHOR** | a no lets the shell witness land now and port later under N10's protocol like any gate; a yes makes it N10's second consumer |
| 6 | Is cost an admissible reason on a `no-mutant:` line, or only impossibility? | **NEEDS-AUTHOR** | GA-04's eleven rows are held on *"measured churn: eleven message-rename mutants and eleven compiler builds"* (`docs/arcs/enforcement-arc.md:442-444`), GA-08's on a consumer that does not exist. The witness cannot tell the two apart unless a ruling names which reasons count |
| 7 | Does the witness land red, or with every uncovered row declared | **NEEDS-AUTHOR, with a proposal** | at least 34 rows are uncovered today (Reading 2). Proposed: the landing commit writes one `no-mutant:` line per uncovered row with its measured reason, the suite stays green, and each `OWED` line is condition 4's open residue until it reaches zero. The alternative is a red suite until every row is covered |

Three NEEDS-AUTHOR, so `status: blocked`. Each earns a row in
[[records/author-calls]]. This run writes none, by its brief.

## 6. The mint packet

- **Elements: one.** The trace, the fold and the declaration constrain each
  other: the fold reads nothing without the trace, and the declaration is the
  fold's third source. The tally repair of Reading 1 rides the element's first
  commit because the fold's tally row convicts it on landing.
- **Band:** `E184-E189` is spent (`docs/decisions/decision-lane-split.md:31-36`,
  as N10 §6 read it). The next free number tree-wide at mint. N10, N23 and N24
  draw on the same pool, so the number depends on mint order.
- **Catalog row:**
  `| E<NN> | **The mutant witness: every counted gate row is turned red by a mutant the suite ran, or its own file says why none can** | Not built. Each gate's mutant helper prints a trace line per mutant carrying the observed per-row vector, from the function that graded the base; a witness beside `tools/test/registration.sh`, run by `run-tests.sh` after the table, folds the phase logs of the same run and reddens on a row in no run mutant's red set, a phase with no trace, and a log with no parseable tally. Exempt rows carry a `no-mutant:` line with a reason and print as OWED. Measured 2026-09-29: 34 counted rows uncovered in three phases where a vector is printed, 111 of 196 mutant rows printing no vector, and 50 rows missing from the assertion count | `OURS`; the hand audit `records/gate-audit.md` GA-04, GA-07, GA-21 | SH |`
- **Ledger row:**
  `| E<NN> | gate-witness | design | **The mutant witness.** Trace grammar with a reserved class column, coverage fold over one suite run's logs, in-file `no-mutant:` declaration, seven falsifiers W1 to W7, tally repair on five phases. The per-row vectors are the input `enforcement/N10`'s port protocol compares | →`enforcement/N10`, →`enforcement/N21`, ←E168 | SH |`
- **Size.** Basis: `tools/test/registration.sh` is 300 lines for six rows and
  seven mutants; a helper edit is a `printf` of the vector the helper already
  computes.

  | file | change | lines |
  |---|---|---|
  | `tools/test/mutant-witness.sh` (new) | trace parser, fold, `OWED` report, W1 to W7 | 250 to 350 |
  | 20 gate scripts, 36 helpers | print the trace line | 2 to 8 each, 100 to 250 in all |
  | `tools/test/mutant.sh` | the library's trace line, reaching phases 3, 4, 6 | 5 to 10 |
  | 5 gate scripts | tally line to `N passed, M failed` | 1 each |
  | gate scripts with unstable row ids | stable ids | unmeasured; `face.sh`, `pretty.sh`, `doc.sh` are the candidates |
  | uncovered rows | one `no-mutant:` line each, if Q7 takes the proposal | 34 or more |
  | `tools/test/run-tests.sh` | invoke the witness after registration | 10 to 20 |

  Nothing under `lib/` or `prog/`; no closure file, so the BUILD RULE owes no
  cycle. The suite's assertion count rises by 50 at the first commit, which is
  the repair and should be read as one.
- **Related:** [[goals/enforcement]] condition 4 · `GAP-03` · [[records/gate-audit]]
  GA-01, GA-04, GA-07, GA-18, GA-19, GA-21, GA-24 · PRB-55, PRB-56 ·
  `enforcement/N10`, `enforcement/N21` · E168

Every `E#` named here is already minted.

## Residue

### Needed and unrostered

Grepped 2026-09-29 over `docs/arcs/*-arc.md` roster rows for `mutant`,
`gate-audit`, `GA-`, `PRB-55`, `matrix`, `registration`, `tally`, `ok, 0 FAIL`,
`LE22`. Read `.planning/DISPATCH-QUEUE.md` E4 (`:67`) and repeat none of its
N10 items. Rostered and left out: Phase 12 (`lowering-and-emit/LE22`), the
class fold (`enforcement/N21`), the gate ports (N10's residue).

| needed | evidence | arc it belongs to |
|---|---|---|
| the suite's tally reads the five phases that print `N ok, M FAIL`, or refuses a phase log with no tally. Absorbed by this design's first commit if the element mints as sized; a row only if it should land sooner | `tools/test/run-tests.sh:134-138`; `apply-word.sh:290`, `capture-fields.sh:257`, `defunc-blame.sh:395`, `apply-spine.sh:376`, `crypto.sh:401`; 441 reported against 491 run | enforcement, requirement 6 |
| `mutant.sh`'s matrix under a phase or under the witness's route | PRB-55, `OPEN`, `owner: none` (`records/lenses/problems.md:770`) | enforcement, requirement 6 |
| a falsifier for each of `profile-target.sh`'s eleven uncovered rows, or Q6's ruling that cost exempts them | PRB-56, `OPEN` (`records/lenses/problems.md:784`); Reading 2 | enforcement, requirement 6 |
| a falsifier for `linear-mint.sh`'s 22 uncovered rows; GA-07 reads `FIXED` over ten of 32 | `records/gate-audit.md:174`; Reading 2 | enforcement, requirement 6 |
| the three `PEND` gates' mutants reach a run: `shape-census.sh` held on its R2 ruling (`:3`), `opt-census.sh` and `tal-check.sh` on phase numbers | registration output this run | enforcement, requirements 3 and 6 |
| E168's `Gate` carries one `MutRun` per gate, so the native floor quantifies over gates and a port to it loses per-row coverage | `lib/evidence/test-floor.chiral:641` | enforcement, beside `N10` |

### Drift against the brief, the row and the tree

- The suite figures reproduce: 441 and 96, 2026-09-29. The 441 omits 50 run
  rows, Reading 1.
- `records/gate-audit.md:174` GA-07 reads `FIXED` with ten of 32 rows covered.
  The row says so in its own text; the state word overstates it.
- `docs/goals/enforcement.md:37` reads *"No row serves this"* for condition 4.
  N11 has served it since 2026-09-06 and `GAP-03` is closed with this row as
  owner.
- `records/gate-audit.md:12` says requirement 5 inherits the mutant rule. It is
  requirement 6 (`docs/arcs/enforcement-arc.md:373`).
- `tools/test/defunc-blame.sh` R1 is an honest shortfall stated in its header
  (`:96-98`) with no machine-readable form. Part 3 gives it one.
