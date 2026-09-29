---
node: verification-coverage
layer: foundation
related: [testing-floors, banks/verification, bug-classes, floor-agreement, split-role, certificate-discipline, decision-self-verification, decision-split-checker, decision-preserve-check, decision-formulation-distinctness, decision-floor-check-per-compile, goals/enforcement, goals/self-hosting, goals/independent-judgment, goals/presentability, goals/readable-surface, arcs/enforcement-arc, arcs/independent-judgment-arc, arcs/checker-core-arc, arcs/lowering-and-emit-arc, arcs/baseline-alignment-arc, records/author-calls, records/findings]
status: draft
updated: 2026-09-29
---

# Verification coverage: what the checks must cover, layer by layer

A draft for the author, and it rules on no call. `.planning/DISPATCH-QUEUE.md:30`
queues it as run `V1`, so that calls 1, 2, 5 and 6 are ruled against it.

The author's words of 2026-09-29, recorded at `.planning/DISPATCH-QUEUE.md:68`:
the tests count as the compiler checking itself, and self-verification proper
comes from distinct judgment cores and their alignment, *"including where
everything should agree and where not everything should"*. So a check belongs
at every layer where it can catch something, and the layers compose.

What this note adds is the axis of **when a check runs and on what**.
[[testing-floors]] holds the other two axes: what each instrument can see down
the pipeline (its coverage map and Rule 1, `docs/definitions/testing-floors.md:92-108`)
and where an expected value comes from (the four ranks and the run-the-mutant
rule, `:267-292`). [[banks/verification]] holds the shards. Neither is restated
here.

## 1. The layers

Four, tested against the tree. Two refinements to the brief's statement of them
follow the table.

| layer | subject | trigger today |
|---|---|---|
| **L1, every compile** | the program being compiled: a user's, or the compiler's own source during the self-compile | the compile itself, `prog/compiler.prog` through `compile-all` |
| **L2, the new compiler before promotion** | the candidate compiler and the tools that judge its output: its binary, its rules, its checker | the BUILD RULE, `docs/definitions/working-discipline.md:19-21`, a procedure a session runs |
| **L3, the whole tree on every change** | the tree's claims and instruments: gates, fixtures, docs, records | a session running the tools by hand |
| **L4, across distinct judgment cores** | the judgment itself: whether a verdict any layer relies on is right | nothing runs |

**Refinement 1: L2 and L3 split by subject.** The suite runs at both. At L2
its subject is the candidate compiler. At L3 its subject is the gate tier, whether
the suite still says what it claims after a gate or a fixture changed. A tree
change that leaves `lib/` and `prog/` alone cannot move a compiler judgment, and
one that touches them owes L2, so a compiler-judgment row reads `n.a.` at L3 in
§6. The L3 checks proper are the checks over checks: registration, the mutant
witness, the tally, `ledger-lint`, the lens check and `prose-lint`.

**Refinement 2: L4 is a dimension with no trigger of its own.** A core judges a
program, so a quorum of cores runs at L1 or L2. What makes a check L4 is its
question: L1 to L3 ask whether a judgment holds of a program, a binary or the
tree, and L4 asks whether the judgment is right. Where a quorum runs is question
2 in §9.

**How the layers compose into the compiler checking itself.** The author's
phrase has two readings and the map takes both. L1 run on the self-compile is
the compiler checking its own program on every generation, so once `ck-prog`
reaches L1 the BUILD RULE's `C1` is checked while it is produced. L2 is the
compiler's tests run on the binary that compile produced. A check at one layer
never discharges another layer's obligation, because the subjects differ, and
[[decisions/decision-floor-check-per-compile]] §6(f) already reads the census
that way: it stays requirement 3's instrument while condition 3 is owed on the
shipping compile.

**What runs where, measured 2026-09-29 at `ad95e20` with the author's working
tree as left.**

- `bash tools/test/run-tests.sh`: `assertions: 441 passed, 0 failed`,
  `compile-only: 96 roots built, 0 failed`, `gate PASSED`, exit 0, 7m17s wall
  beside a concurrent `ledger-lint` run. The log holds 491 `ok` lines, and the
  50-line gap is `docs/arcs/parts/enforcement-N11.md` Reading 1 reproduced.
  Registration printed `7 of 29 scripts are outside the dispatch table by their
  own declaration`.
- The BUILD RULE procedure of `docs/definitions/working-discipline.md:26-33`, run
  into a scratch directory: the blob is 851,722 bytes, `C1` and `C2` each built
  in about 1.2 s, `cmp C1 C2` and `cmp C1 bin/chirality-bin` both silent, all
  three 1,257,848 bytes.
- The compiler closure, walked from `prog/compiler.prog` over `lib:prog` by
  matching `(import "…")` forms: 61 `lib/` modules. It holds `typing/kernel`,
  `qtt`, `refine`, `totality` and `totality-check`, `lowering/tal/sys-check` and
  `lowering/upper/optimize`. It holds none of `typing/effects`,
  `typing/row-infer`, `lowering/tal/check`, `lowering/tal/eval`,
  `evidence/interp` or `typing/kernel-core`.
- `grep -rln '(import "<key>")' lib prog tools`: `lowering/tal/eval`,
  `evidence/interp`, `typing/kernel-core` and `lowering/tal/spec` have zero
  importers. `lowering/tal/check` has two, `prog/optimizer-census.prog` and
  `tools/test/tal-check.sh`. `evidence/ddc` has one, `lib/evidence/test-floor.chiral`.
- `.git/hooks` holds only samples, the tree has no CI configuration, and
  `.claude/` holds `skills/` alone. `bin/chirality:211-215` dispatches `compile`,
  `run`, `check`, `test` and `help`, and no subcommand promotes.
- `python3 tools/lens/lens.py check`: `197 row(s), 0 finding(s)`, exit 0.
- `tools/prose-lint/prose-lint.sh --regress`: exit 1, `140 file(s) worse than
  the baseline`.
- `python3 tools/ledger-lint/ledger-lint.py`: `231 violations found, 18 element
  homes owed, 42 author calls owed, 165 lens rulings owed, 2 checks that checked
  nothing`, exit 1, 2m17s.

## 2. L1: what every compile must check

The subject is one program. Each obligation is derived from a principle's
predicate, a goal condition or a settled decision, and each principle's honest
limit bounds what the obligation can claim.

| obligation | derived from | the honest limit it carries |
|---|---|---|
| **the whole source judgment runs, on every compile path** | P1's predicate, everything the substrate does is named and gateable (`PRINCIPLES.md:25-28`), with deny by default covering the whole surface (`:45-49`) | P1 governs only what the model names. The judgment vocabulary has no constructor for effects, termination, bounds, overflow or ABI agreement (`docs/definitions/bug-classes.md:123-125`), so L1 cannot refuse those classes until each gains a `Judg` arm |
| **no category of code opts out of its type**: the `->`/`=>` membrane and totality are judged | P2, one atom with no exemptions (`PRINCIPLES.md:53-58`) and the type carrying effects and termination (`:60-64`) | the type carries an over-approximate bound, and the checker's own budget is unfinished (`:66-69`) |
| **totality is the default and partiality the marked case** | P4's own example (`PRINCIPLES.md:144-147`) | the conservative-checker tax (`:134-142`), which [[goals/readable-surface]] condition 2 books as a debt (`docs/goals/readable-surface.md:40-44`) |
| **the membrane is checked where the program crosses it**: declared syscalls, the profile's port set, and the compiled artifact leaving for disk | P3, the port-check is the type-check (`PRINCIPLES.md:83-85`) | timing, cache pressure and speculation have no port (`:107-112`) |
| **the compile's own time and memory are held** | P3's time and space as ports (`PRINCIPLES.md:87-90`) and P2's mediator budget (`:66-69`) | exact cost is undecidable, so any bound over-approximates (`PRINCIPLES.md:66-67`). No goal condition holds the compile's cost today (`.planning/DISPATCH-QUEUE.md:67`) |
| **the typed-assembly floor runs on the program the compile produced, and its output is withheld on refusal** | [[goals/enforcement]] condition 3 (`docs/goals/enforcement.md:33-35`); call 2's survivor, `docs/decisions/decision-floor-check-per-compile.md` §9 | T0 is target well-typedness alone (`docs/decisions/decision-preserve-check.md:21`, `:86`) |
| **values agree: source against target, and each rewrite's input against its output** | T1, `docs/decisions/decision-preserve-check.md:22`, over the definitions that lower (`:119`); call 1's in-compile half, `records/author-calls.md:116` | T1 is detection. P5's verb honesty (`PRINCIPLES.md:159-162`) requires the downgrade be named |
| **every definition's fate is stated** | [[goals/enforcement]] condition 2 (`docs/goals/enforcement.md:29-32`) | a stated drop is still a drop: `docs/decisions/decision-preserve-check.md:94` settles dropping a definition as the defect, so attribution names the fate and repairs nothing |
| **byte access carries a bound**, or the floor states memory safety is outside its claim | `docs/arcs/enforcement-arc.md:105-122` measured `bget` at index 999999999 returning SIGSEGV through instructions `ck-prog` types | the call at `docs/arcs/enforcement-arc.md:683` is unmade |

**What runs at L1 today.** The load at `lib/lowering/compile-front.chiral:368`
runs the kernel judgment, QTT usage, `I64` refinement, coverage and positivity.
`tot-gate` runs at `:371` and classifies nothing unless a profile carries
`(total)`. `ck-tiprog` refuses an undeclared syscall at
`lib/lowering/compile-emit.chiral:296`, and `manifest-offender` refuses a crossing
outside a declared profile at `:299`. `opt-tfns` adopts `(fold t)` with nothing
consulted (`lib/lowering/compile-back.chiral:247-250`). `ck-prog`, both
evaluators and the effect rules sit outside the closure, measured in §1.

## 3. L2: what the new compiler must pass before promotion

The subject is the candidate compiler and the tools that judge its output.
`docs/definitions/working-discipline.md:19-21` states the rule, *build-new, test,
promote*, and [[goals/self-hosting]] condition 3 is *"Nothing replaces itself in
place"* (`docs/goals/self-hosting.md:49-51`).

| obligation | derived from | today | owed |
|---|---|---|---|
| **the suite judges the candidate in every phase** | *"you test that binary"* (`docs/definitions/working-discipline.md:19-21`) | `tools/test/run-tests.sh:45-46` reads `CHIRALITY_COMPILE` and exports nothing. `tools/test/encoding.sh:77-78` and `tools/test/recording.sh:109-110` read `CC`. Measured: with `CHIRALITY_COMPILE` naming a stub that exits 1, `encoding: 9 passed, 0 failed` and `recording: 12 passed, 0 failed` with the stub never called, while `arity.sh` called it 46 times and failed 11 rows | §7 row U1 |
| **the fixpoint holds**, stability only | `docs/definitions/working-discipline.md:35-50`, and its own limit at `:62-65`: a fixpoint *"says nothing about correctness"* | runs by hand, held today (§1) | `lowering-and-emit/LE24`, and the phase call at `records/author-calls.md:112` |
| **the checker agrees with the compiler over every root** | requirement 3 of [[arcs/enforcement-arc]] (`docs/arcs/enforcement-arc.md:123`) | `tools/test/opt-census.sh` declares `not-a-phase` and prints `PEND` in this run; `docs/arcs/parts/enforcement-N12.md` records it red at HEAD | `enforcement/N12` |
| **every rewrite rule matches its reference** | requirement 7 (`docs/arcs/enforcement-arc.md:471-474`) | nothing runs | `enforcement/N24` once per rule change; `enforcement/N23`'s gate, the *"Gate now"* of `records/author-calls.md:116` |
| **the checker's own relations are sound** | requirement 3 | `tools/test/tal-check.sh` prints `PEND` in this run | `enforcement/N15`, `N16`, `N17`; the three held-out gates in `.planning/DISPATCH-QUEUE.md:67` |
| **a mutant compiler is refused, and cutting the per-compile check reddens a row** | the run-the-mutant rule (`docs/definitions/testing-floors.md:287-292`) with the compiler as subject; `docs/decisions/decision-floor-check-per-compile.md` §6(c) | `tools/test/mutant.sh:21` declares itself *"a matrix driver a person runs by hand"* | PRB-55, `owner: none`, listed at `.planning/DISPATCH-QUEUE.md:67`; §6(c), queued by call 2's survivor |
| **every checking module sits inside the closure it claims** | [[goals/self-hosting]] condition 4(a) (`docs/goals/self-hosting.md:52-60`) | nothing asserts it | requirement 2 of `checker-core`, `lowering-and-emit` and `substrate-floor`; `sys-face` states no such requirement (`docs/goals/self-hosting.md:65-70`) |
| **each kernel refusal is read by an assertion** | `checker-core` requirement 1 (`docs/arcs/checker-core-arc.md:137-141`), which reads 4 of 36 | 4 of 36 by that row's count | `checker-core/CK19` and the `CK` rows |
| **promotion waits on the rows above** | self-hosting condition 3 | a session's procedure | §7 row U3 |

## 4. L3: what every change must pass on the whole tree

The subject is the tree's claims and the instruments that make them.
[[goals/presentability]] condition 1 asks that every claim be measured and
matching, with `ledger-lint` exiting 0 or each failing check carrying a row
(`docs/goals/presentability.md:34-37`), and condition 3 that a green suite mean
what it says (`:42-44`).

| check | today | owed |
|---|---|---|
| registration: every script dispatched or declared out | runs, `registration: 9 passed, 0 failed` | |
| the tally reads every phase or refuses | 441 reported against 491 `ok` lines | `enforcement/N11`'s first commit |
| every counted row has a run mutant | at least 34 rows have none (`docs/arcs/parts/enforcement-N11.md:106-107`) | `enforcement/N11`, call 5 |
| `ledger-lint` A to AN | exit 1, 231 violations. H and M print `VACUOUS`. **Check P prints `[ok]` and checks nothing**, measured 2026-09-29: `tools/ledger-lint/ledger-lint.py:819-850` fires only on a file naming `scaffold/build/B1`, and `grep -l` finds that string in zero of `tools/test/*.sh` and `bin/chirality` | baseline-alignment requirement 4; §7 row U2 |
| the lens check | runs, 197 rows, 0 findings | |
| `prose-lint --regress` | exit 1, 140 files worse. `.planning/protocol/tone.md:132-133` records it unwired | §7 row U4 |
| every bug class names a gate or a reason | nothing | `enforcement/N21` |
| the gate tier is chirality's | shell | `enforcement/N10` |
| a change runs L3 before it lands | a session's procedure | §7 row U3 |

## 5. L4: across distinct judgment cores

### What must hold

[[goals/independent-judgment]] states the bar: N semantically distinct cores,
each a different formulation of the rule set, run on the same input and required
to agree (`docs/goals/independent-judgment.md:27-29`).
`docs/decisions/decision-self-verification.md` §0 makes it the route, and
[[decisions/decision-formulation-distinctness]] §3 drafts what makes a pair
distinct: formulations differ (`:155`), closures are disjoint against the
subject, and each judge was built before the artifact it judges. Its
falsification obligation (`:185`) makes the E166 pair the standing mutant a
distinctness check must refuse. Rows `J1` to `J5` carry the work, and none is
built.

**What the tree already holds at L4, and it is one asset.**
`lib/lowering/tal/eval.chiral` is a second formulation over the tal floor, and
its header names the cross-check at `:10-11`: no `ck-ok` program ever evaluates
to `r-err`. Formulation-distinctness §4 qualifies it over that narrower subject.
It has zero importers and no roster row names that cross-check (§7 row U7).

### Where cores are expected to differ

The goal's text reads *"Disagreement is a refusal"*
(`docs/goals/independent-judgment.md:28-29`). The author's words add places where
not everything should agree. No document in the tree states an expected
disagreement as such, and five texts state one without the name:

| the tree's text | what it says may differ |
|---|---|
| `docs/decisions/decision-split-checker.md:67-68` | version skew produces valid disagreement while a spec change propagates to N implementations |
| `docs/decisions/decision-split-checker.md:72-73` | typing admits many valid derivations, so derivations are no comparable object |
| `docs/decisions/decision-self-verification.md:163` | L1 owes L0 faithfulness one way: *"accept implies an L0"* derivation exists. The converse is never asked |
| `docs/definitions/floor-agreement.md:45-46` | floors agree on the observable result, the returned value and the sequence of effects, and the note names no other compared property |
| `docs/arcs/parts/enforcement-N23.md:101-106` | a verdict is `agree`, `disagree` or `vacuous`, and value equality dereferences cells because cell ids are allocation order |

Two more bound the reading. `docs/decisions/decision-self-verification.md:225-231`:
where formulations are extensionally equivalent by construction, agreement is
worth close to nothing, and the value surfaces as a failed adequacy proof.
[[records/findings]] FD-32 surveyed expected-failure mechanisms in fourteen
harnesses and found *strict* expected failure, where an unexpected pass is
itself a failure.

**The reading, and it is this note's.** An alignment verdict over one judgment
form and one pair of cores is read through a relation declared for that pair
before the cores run:

| relation | the cores must | where it applies | a run reads |
|---|---|---|---|
| `equal` | return the same verdict, or the same observable | both cores complete over the fragment: the observable of floor agreement; accept or refuse where neither core is conservative | a difference is a refusal |
| `implies` | agree in one direction: the working core accepting implies the reference accepts | an algorithmic core against a declarative one, L1 against L0 | working accepts and reference refuses: a refusal, the soundness direction. Working refuses and reference accepts: a completeness gap, booked as a P4 tax under readable-surface condition 2 |
| `abstain` | say nothing | the subject lies outside one core's fragment; fuel runs out (`r-oot`, `lib/lowering/tal/eval.chiral:7-8`); an input violates a refinement the source requires | counted and printed. It is never read as agreement |
| `free` | differ freely | derivation shape; diagnostic wording and position; emitted bytes; allocation identity; cost | not read |
| `declared` | differ on a named case with a reason and a date | version skew during a spec change; a known gap under repair | printed as owed, and strict in FD-32's sense: the day it stops differing, the row reddens until the declaration goes |

Three rules keep the register from becoming a hole. Each is derived.

1. **Fixed before the run, changed only by a dated revisit.** A register written
   after a disagreement is a list of known bad cases, which P4's first sentence
   refuses (`PRINCIPLES.md:125-128`).
2. **Every `equal` and `implies` relation carries a run mutant that makes the
   cores disagree.** A relation no mutant can fire is a gate that cannot fail, and the
   run-the-mutant rule (`docs/definitions/testing-floors.md:287-292`) already
   asks a mutant of every gate row.
3. **The register is assertable only**, as the formulation axis is
   (`docs/decisions/decision-formulation-distinctness.md:73`). It bounds the
   claim and does not establish it, and a wrong specification makes every core
   agree and every core wrong (`:358`).

A diagnostic sits between `equal` and `free` in this reading: two cores refusing
one program agree on the refusal and on the `JForm` it falls under, and differ
freely on wording. That needs `JForm` to cover every judgment, which is `J5`.

## 6. The coverage matrix

Cells read `runs`, `owed` with its owner, or `n.a.` with the reason. A check
that runs short of its layer's obligation reads `owed`, per
`.planning/protocol/reconcile.md` §"Proper or not at all": nothing in a cell
stands in for the obligation.

| # | check | L1 every compile | L2 before promotion | L3 every change | L4 across cores |
|---|---|---|---|---|---|
| 1 | source judgment: types, conversion, QTT, `I64` refinement, coverage, positivity | runs | owed: `checker-core` req 1 and 6, `CK19` | n.a.: compiler subject, L2 holds it | owed: `J1`, `J3`, `J5` |
| 2 | totality | owed: the default flip, `E47`, unhomed | owed: `checker-core/CK12` | n.a.: compiler subject | owed: `J5`, no `JForm` |
| 3 | the `->`/`=>` membrane | owed: `E171`, unhomed | owed: `E171` | n.a.: compiler subject | owed: `J3`, `j-membrane` |
| 4 | declared syscalls, `ck-tiprog` | runs | runs, Phase 5, with poison mutants at `tools/test/syscall-manifest.sh:113-121` | n.a.: compiler subject | n.a.: set inclusion, one copy correct at T0 (`PRINCIPLES.md:171`) |
| 5 | the profile port set | runs | owed: PRB-56, `enforcement/N11` | n.a.: compiler subject | n.a.: set inclusion, T0 |
| 6 | bounds on byte access | owed: `enforcement/N18`, `N19` | owed: `enforcement/N20` | n.a.: compiler subject | owed: `J3`, once a bound is a judgment |
| 7 | every definition's fate stated | owed: `enforcement/N1`, `E184` | owed: `enforcement/N1` | n.a.: compiler subject | n.a.: bookkeeping of one compile, and no text asks a second reading |
| 8 | the typed-assembly floor, `ck-prog` | owed: `enforcement/N8`, call 2's survivor | owed: `enforcement/N12`; `tal-check.sh` undispatched | n.a.: compiler subject | owed: U7 |
| 9 | a TFn's signature equals its source signature | owed: E4's `N12` item | owed: E4's `N12` item | n.a.: compiler subject | n.a.: equality of two records, T0 |
| 10 | the checker's relations: `tal-ty=?`, `shape-eq`, typed byte instructions | n.a.: a property of the checker, judged at L2 | owed: `enforcement/N15`, `N16`, `N17` | n.a.: compiler subject | owed: U7 |
| 11 | each rewrite's value | owed: `enforcement/N23`, call 1's in-compile half | owed: `enforcement/N23`'s gate; E4's `eval-prim` item | n.a.: compiler subject | n.a.: one evaluator over two programs; its own truth is row 14's pair |
| 12 | `fold`'s arithmetic and comparison rules | n.a.: program-independent, discharged per rule change | owed: `enforcement/N24` | n.a.: compiler subject | n.a.: the bash reference is the second reading, rank 2 or 3 |
| 13 | `fold`'s case-dispatch rule | n.a.: program-independent | owed: E4's `N24` item | n.a.: compiler subject | n.a.: as row 12 |
| 14 | source-to-target value agreement, T1 | owed: `enforcement/N13` Arm A, calls 1 and 6 | owed: `enforcement/N13`'s gate; E4's `interp` item | n.a.: compiler subject | owed: `enforcement/N13` under `J1`, and U9 |
| 15 | the optimizer's re-check per rewrite | owed: `enforcement/N7` | owed: `enforcement/N7` | n.a.: compiler subject | n.a.: row 8 carries the tal rules |
| 16 | below tal: erase and emit | n.a.: the drop is a named axiom (`docs/decisions/decision-self-verification.md:248-250`), question 5 | owed: `lowering-and-emit/LE21`, parked | n.a.: compiler subject | n.a.: toolchain diversity is the deferred track |
| 17 | every compile path through the checked entry | owed: call 2's survivor, `decision-floor-check-per-compile.md` §9 finding 2 | n.a.: property of the entry, judged at L1 | n.a.: a listing gate is refused by §9 finding 2 | n.a.: no judgment to re-read |
| 18 | the compile's own time and memory | owed: no goal condition, queue call 8 | owed: the same condition, measured per candidate | n.a.: compiler subject | n.a.: a measurement |
| 19 | the suite judges the candidate in every phase | n.a.: no program subject | owed: U1 | owed: U2 | n.a.: harness plumbing |
| 20 | the fixpoint | n.a.: a property of a binary | owed: `lowering-and-emit/LE24`, `records/author-calls.md:112` | n.a.: compiler subject | n.a.: one formulation agreeing with itself (`docs/definitions/working-discipline.md:62-65`) |
| 21 | a mutant compiler refused; the per-compile check gated | n.a.: the compiler is the subject | owed: PRB-55; §6(c), queued by call 2's survivor | n.a.: compiler subject | n.a.: falsifies a gate |
| 22 | checking modules inside the compiler closure | n.a.: the compiler is the subject | owed: requirement 2 of three subject arcs | n.a.: compiler subject | n.a.: a reach fact |
| 23 | a trigger: promotion waits on L2, a change on L3 | n.a.: the compile is its own trigger | owed: U3 | owed: U3 | n.a.: a trigger |
| 24 | the suite's tally | n.a.: the gate tier is the subject | n.a.: the gate tier is the subject | owed: `enforcement/N11` | n.a.: counting |
| 25 | registration | n.a.: the gate tier | n.a.: the gate tier | runs | n.a.: counting |
| 26 | the mutant witness | n.a.: the gate tier | n.a.: the gate tier | owed: `enforcement/N11`, call 5 | n.a.: folds logs |
| 27 | `ledger-lint` A to AN | n.a.: docs | n.a.: docs | owed: baseline-alignment req 4 | n.a.: docs |
| 28 | the lens check | n.a.: records | n.a.: records | runs | n.a.: records |
| 29 | `prose-lint --regress` | n.a.: prose | n.a.: prose | owed: U4 | n.a.: prose |
| 30 | every bug class names a gate or a reason | n.a.: the register | n.a.: the register | owed: `enforcement/N21` | n.a.: the register |
| 31 | the gate tier native | n.a.: tooling | n.a.: tooling | owed: `enforcement/N10` | owed: `J1`, N10's Q5 |
| 32 | the distinctness criterion | n.a.: an L4 instrument | n.a.: an L4 instrument | n.a.: an L4 instrument | owed: `J1` |
| 33 | a second core, with `kernel-core` wired | n.a.: an L4 instrument, trigger is question 2 | n.a.: as L1 | n.a.: an L4 instrument | owed: `J2`, `J3` |
| 34 | the quorum refuses fewer than two disjoint legs | n.a.: an L4 instrument | n.a.: an L4 instrument | n.a.: an L4 instrument | owed: `J4` |
| 35 | the demanded statement is a form | n.a.: an L4 instrument | n.a.: an L4 instrument | n.a.: an L4 instrument | owed: `J5` |
| 36 | verdicts folded, formulation in `Prov` | n.a.: an L4 instrument | n.a.: an L4 instrument | n.a.: an L4 instrument | owed: U8 |
| 37 | the alignment register | n.a.: an L4 instrument | n.a.: an L4 instrument | n.a.: an L4 instrument | owed: U9 |
| 38 | adequacy per ordered pair | n.a.: an L4 instrument | n.a.: an L4 instrument | n.a.: an L4 instrument | owed: U10 |
| 39 | the ledger tells error from adversary | n.a.: a ledger claim | n.a.: a ledger claim | n.a.: a ledger claim, held at L4 by independent-judgment requirement 4 | owed: `GAP-06`, no row |

**Counts** over the 39 rows, tallied by script from the cells above.

| layer | runs | owed | n.a. |
|---|---|---|---|
| L1 every compile | 3 | 11 | 25 |
| L2 before promotion | 1 | 21 | 17 |
| L3 every change | 2 | 8 | 29 |
| L4 across cores | 0 | 16 | 23 |

Six cells run in all. The three at L1 are the source judgment and the two
membrane checks. The one at L2 is Phase 5. The two at L3 are registration and
the lens check.

**The biggest owed items**, by what each unblocks.

1. `ck-prog` on every compile (row 8, `enforcement/N8` under call 2), because
   it is the first check that judges the program the compiler actually emits.
2. The evaluators made able to run what they judge (E4's `eval-prim` and
   `interp` items), because rows 11 and 14 at both layers rest on them.
3. A trigger for L2 and L3 (U3). Every row at those layers runs today because a
   session remembered, which is the opt-in shape P4 inverts.
4. `J1` ruled, because the L4 column and N10's ports both wait on it.
5. The alignment register (U9), because the goal's own done-condition reads
   *"Disagreement is a refusal"* and the author has named places it is not.

## 7. Needed and unrostered

Grepped 2026-09-29 over every `docs/arcs/*-arc.md` roster row for `disagree`,
`alignment`, `ddc-fold`, `adequacy`, `Prov`, `promot`, `hook`,
`CHIRALITY_COMPILE`, `r-err`, `default` beside `total`, and `--regress`. Read
`.planning/DISPATCH-QUEUE.md:67`, the E4 row, and repeat none of its items. No
roster was edited.

| id | needed | evidence | arc it belongs to |
|---|---|---|---|
| U1 | phases 29 and 30 judge the candidate: `encoding.sh` and `recording.sh` honour `CHIRALITY_COMPILE`, or `run-tests.sh` exports the compiler it chose | `tools/test/run-tests.sh:45-46`; `tools/test/encoding.sh:77-78`; `tools/test/recording.sh:109-110`; the stub probe of §3, 21 rows green with the candidate never called | baseline-alignment, requirement 1. It is an instance of `baseline-alignment/AL1`'s class, and AL1's row names no instance |
| U2 | check P repointed at `CHIRALITY_COMPILE`, or reported `VACUOUS` beside H and M | `tools/ledger-lint/ledger-lint.py:819-850`; `scaffold/build/B1` in zero suite files and P printing `[ok]`, both measured 2026-09-29 | baseline-alignment, requirement 4, with BA-03 |
| U3 | a trigger: promotion runs L2 and refuses on a red row, and a commit runs L3 | `bin/chirality:211-215` has no promote subcommand; no hook and no CI measured in §1; `docs/definitions/working-discipline.md:19-21` states a procedure | none. Self-hosting conditions 1 to 3 carry no arc by that goal's design (`docs/goals/self-hosting.md:86-90`), so the home is question 6 |
| U4 | `prose-lint --regress` as an L3 gate | `.planning/protocol/tone.md:132-133`; exit 1 and 140 files worse, §1 | presentability, condition 1 |
| U5 | totality by default, P4's own example | `PRINCIPLES.md:144-147`; `lib/lowering/compile-front.chiral:371`; `docs/arcs/checker-core-arc.md:242-245` puts the flip on `E47`, unhomed, under author call B | none yet. `records/homing-triage.md:252-255` holds it as author call B, whether a goal is owed before `E47` can be scheduled |
| U6 | the `->`/`=>` membrane judged on every compile | `E171`, ledger state `design`; `typing/effects` outside the closure (§1); `records/homing-triage.md:225` proposes [[arcs/enforcement-arc]] | enforcement, requirement 1, when the element is homed |
| U7 | the tal floor's cross-check: no `ck-ok` program evaluates to `r-err` | `lib/lowering/tal/eval.chiral:10-11`; `docs/decisions/decision-formulation-distinctness.md` §4 qualifies the evaluator; `enforcement/N8` and `N13` name it only as T1's target side | independent-judgment, beside `J3`, over the narrower subject |
| U8 | `ddc-fold` over verdicts, `Prov` carrying formulation, and a distinctness predicate relative to a subject | `docs/decisions/decision-formulation-distinctness.md:291-335`; `docs/decisions/decision-self-verification.md:61-62` records no element minted | independent-judgment, after `J1` |
| U9 | the alignment register of §5: a relation per judgment form and pair, fixed before the run, each firing relation with a run mutant | `.planning/DISPATCH-QUEUE.md:68`; `docs/goals/independent-judgment.md:28-29` reads every disagreement as a refusal | independent-judgment. The goal's done-condition text owes the author's amendment |
| U10 | adequacy per ordered pair: an encoding, an adequacy argument and a conservativity direction | `docs/decisions/decision-self-verification.md:214-221` | independent-judgment. It may fold into `J3`'s design |

**Drift seen and left alone.** `docs/definitions/floor-agreement.md:72-75` says
the constant-folder imports the reference interpreter's arithmetic, and
`lib/lowering/tal/eval.chiral` has zero importers. A `doc-audit` item.

## 8. The queued calls, reframed

None is ruled here.

**Call 1, where the value check runs** (`records/author-calls.md:116`,
`ruled`). The ruling's two halves are two layers with two subjects, so neither
half is an interim for the other. The gate is L2: it checks the candidate's
rewrites over a named corpus before promotion, and under the author's later words
it is the compiler checking itself. The in-compile half is L1, and there the
program being compiled carries no corpus, so its inputs come from types or it has
nothing to run. That makes call 6 a precondition of call 1's L1 half. The ruling's third
precondition, whether type-drawn inputs count as evidence, meets §5's reading
there: an input outside the source's domain is `abstain`, and says nothing about
the rewrite either way. If the L1 half runs in the
checker process call 2 builds, §9's asymmetry of
[[decisions/decision-floor-check-per-compile]] goes, and the per-rewrite fallback
of its §6(e) goes with it. Question 7 carries that trade.

**Call 2, whether a gate discharges `N8` and condition 3**
(`records/author-calls.md:119`, `dissolved`, paused by
`.planning/DISPATCH-QUEUE.md:68`). The fork was framed as the gate or the
shipping compile. The map places `ck-prog` at both: at L1 on every compile, and
at L2 as the census over every root. The author's words make the census part of
the compiler checking itself, so option 1's census is a proper L2 check. It
still does not discharge condition 3, because that condition's observable is the
shipping compile (`docs/goals/enforcement.md:33-34`), an L1 subject. On this
note's reading the step-1 refusal holds across layers: a gate refused as L1's
check is admitted as L2's. The survivor is untouched as L1's placement, a checker process
outside the closure reading the TAL the compile wrote and withholding output.
The map adds two obligations beside it: the checker binary is itself an L2
subject, built before the artifact it judges (formulation-distinctness condition
3), and L4 wants a second reading of the tal rules (U7). Nothing in the map
revives options 2, 4, 5, 7 or 8.

**Call 5, `enforcement/N11`'s three** (`docs/arcs/parts/enforcement-N11.md:254-256`).
The mutant witness is an L3 check over the gate tier. **Q5, native or shell.** The
witness folds text logs and judges no compiler output, so `J1`'s question about
judges of compiler output (N10's Q5) does not reach it. Nativeness is then
condition 5's measure alone, which puts Q5 with N10's programme and off `J1`'s
path. That is this note's reading. **Q6, cost as a reason.** The layers give cost
a place to go. A mutant too costly for every change can run at L2 on each
promotion, beside PRB-55's matrix, so a cost line can name the layer where the
mutant runs and an exemption is left for impossibility. **Q7, red or green.** An
`OWED` line with a measured reason is an owed cell with an owner, the form this
map uses, and it claims no coverage. Landing red holds L3 red for every other
change until 34 or more rows are covered.

**Call 6, T1 over every definition or a counted reach**
(`docs/arcs/parts/enforcement-N13.md:245`). The settled words are *"value
agreement, over the same definitions"* (`docs/decisions/decision-preserve-check.md:22`).
Every definition is reachable per compile with inputs drawn from types, Shape P,
and a counted corpus is L2's natural form, Shape W. The two compose: Shape P at
L1 meets the decision's words, and Shape W at L2 adds the programs that run.
Choosing W alone narrows a settled decision, which a session may not do. §5's
reading, which is this note's, supplies what Shape P lacked: an input outside a refinement or past the fuel is
`abstain` and counted, and a disagreement on an in-domain input no program
produces is still a disagreement, because the source semantics defines it.

## 9. Questions only the author can settle

1. Is the L2 and L3 split by subject what you mean, or should L3 re-run the
   compiler's checks on every change?
2. Where does a quorum of cores run: on every compile, before promotion, or both?
   Every core at L1 multiplies the compile's cost, and no condition holds that
   cost.
3. Do the five relations of §5 read *"where not everything should"* the way you
   meant it? In particular: when the reference accepts and the working core
   refuses, is that an expected difference booked as a P4 tax, or a defect?
4. Does the alignment register live in the kernel spec, as part of `J5`'s form, or
   as its own artifact?
5. Does the map owe a check below tal, or does it record the drop as the named
   axiom it is today, with row 16 at `n.a.`?
6. Should promotion and commit be gated mechanically (U3), and which arc holds it,
   given self-hosting conditions 1 to 3 carry none by design?
7. Should call 1's in-compile half run in call 2's checker process? One process
   removes the asymmetry §9 of the call 2 note names and gives up refusing one
   rewrite at a time.
8. Check P: repoint it or retire it (U2)?
9. Is totality by default an L1 obligation now (U5), given it is P4's own example
   and author call B holds it?
10. The goal reads *"Disagreement is a refusal"*. Should it be amended to name the
    declared relations, or kept strict with the register as an arc-level refinement?
