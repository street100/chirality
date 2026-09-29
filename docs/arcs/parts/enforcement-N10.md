---
row: enforcement/N10
arc: enforcement
title: the gate tier becomes chirality: 10,719 lines of shell in `tools/test/` against 1,775 native, on the `prose-lint` precedent where the checks moved into a `.prog` and the shell kept only the front end
kind: tool
origin: new
req: 5
status: blocked
updated: 2026-09-29
---

# enforcement/N10: the gate tier becomes chirality

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** a gate's judgment runs in a chirality program that the suite
  actually dispatches, and the shell it replaced is deleted in the commit that
  switches the dispatch, after the two were shown to agree on the same inputs.
  The line ratio moves as a consequence. A native twin beside a live shell gate
  moves the ratio and adopts nothing, and this design counts it as no progress.
- **Serves:** requirement 5 of [[arcs/enforcement-arc]]
  (`docs/arcs/enforcement-arc.md:316`), "**Chirality's own tooling is
  chirality's.**" The row is `GAP-02`'s owner (`records/lenses/gaps.md`,
  GAP-02, `owner: enforcement/N10`), opened on the author's 2026-09-06 ruling
  *"native tests and harnesses"*, which the row's `note` field glosses as the
  gate tier becoming chirality along with the Python tools.
- **Goal:** [[goals/enforcement]], condition 5 (`docs/goals/enforcement.md:39-42`):
  *"Observed as the ratio of lines outside the language to native ones, and by
  reach rather than the ratio alone."* Reach is the half this design is built
  around.

## 2. What the tree holds

Measured 2026-09-29 at `fd3fd7d`, working tree as the author left it. Every
`file:line` below was opened this run.

- **Bank:** no bank holds the gate tier. [[banks/verification]] shard 7 ranks
  an expectation's source and is the one bank shard that bears on a gate's
  judgment; [[banks/text]] holds the matcher the `prose-lint` port uses. The
  concept here is a harness, and its refraction is already written as a module
  with a SPEC: E168's test floor, below. This run builds no bank, because
  `lib/evidence/test-floor.chiral:1-16` states the concept and its contract
  (`docs/definitions/testing-floors.md:161-214`) in place.

### Reading 1: the figures, re-measured

| figure | row (2026-09-06) | reproduced at `26f48fb`, last commit of 2026-09-06 | today, `fd3fd7d` | command |
|---|---|---|---|---|
| shell in `tools/test/*.sh` | 10,719 | 10,744 over 26 scripts | **12,183 over 29 scripts** | `wc -l tools/test/*.sh` |
| native `.prog` | 1,775 | **1,775 exactly**, every top-level `prog/*.prog`, 12 files | **2,557 over 14 files** | `wc -l prog/*.prog` |

The 1,775 is every top-level `.prog`, `prog/compiler.prog`'s 20 lines
included. The 10,719 does not reproduce at the day's last commit; it was taken
earlier that day. Both figures move with every gate.

The 12,183 splits, by an awk pass over the 29 scripts (session script, rule:
a line inside a heredoc body is heredoc, else a `#` line is comment, else blank,
else code): **5,976 code, 4,263 comment, 1,111 heredoc, 811 blank.** The
heredocs are mostly chirality source held as fixtures (`row.sh` holds 537 of
them). So the shell that executes is half the figure the row names.

Of the 2,557 native lines, nine files are **gate probes**: a program a shell
gate builds with the compiler under test, runs, and reads. Measured by grep
for the probe variable: `tools/test/apply-word.sh:99` (`e185-apply-word`),
`capture-fields.sh:99` (`e186-capture-fields`), `apply-spine.sh:108`
(`e188-apply-spine`), `encoding.sh:83` (`e196-encoding-sweep`),
`recording.sh:115` (`e197-recording-sweep`), `mul-widen.sh:118`
(`e189-widening-multiply`), `opt-census.sh:126` (`optimizer-census`),
`shape-census.sh:70` (`shape-census`), `matcher.sh:89` (`prose-lint`). The tenth
reached program is `prog/test-runner.prog`, Phase 2. Three are reached by
nothing: `paren-audit.prog` 244, `resolve.prog` 104, `wield.prog` 44.

### Reading 2: the precedent the row names does not hold

The row reads that on `prose-lint` *"the checks moved into a `.prog` and the
shell kept only the front end"*. `tools/prose-lint/README.md:6` and
`tools/README.md:23` say the same. **The shell tool still does the matching.**
`tools/prose-lint/prose-lint.sh:86-113` is `_scan`, an awk program carrying all
ten checks as `gsub` patterns, and `cmd_lines` at `:153-176` carries an eleventh
copy of the alternation. `prose-lint.sh` never names `prose-lint.prog`
(`grep -n 'prose-lint.prog' tools/prose-lint/prose-lint.sh` returns nothing).
The native program runs in exactly one place, `tools/test/matcher.sh:450-535`,
G5 and G9, a differential of the native eight checks against
`prose-lint --summary` on one fixture and a 137-file corpus.

So the row's precedent is a native twin verified against the tool it would
replace and never switched in. That is the failure
`docs/arcs/text-tools-arc.md:238-286` §Adoption measured twice (`PRB-59`
`resolve.prog`, `PRB-60` `paren-audit.prog`), and `prose-lint` is its third
instance. It is the one of the three where the differential exists, which makes
it the nearest to adoption and still unadopted.

### Reading 3: the pattern the tree actually runs

The dominant idiom in the gate tier is a native probe that prints and a shell
comparator that holds the constants. `tools/test/apply-word.sh:33-35`:
*"The probe PRINTS and asserts nothing, it always exits 0, and every comparison
below is bash against a string constant held here."* This is deliberate, and
`docs/goals/enforcement.md` states why: a comparator holding constants cannot be
fooled by a mutated compiler. The probe is the subject, built by the compiler
under test; the judge is bash, built by nobody.

| what exists | where | rung | reached by |
|---|---|---|---|
| the native test floor: `Expect` with provenance, `Gate` that cannot be built without a `MutRun`, a pure `gate-verdict` fold, `Suite` | `lib/evidence/test-floor.chiral:51-75`, `:641`, `:749`, `:774`; 1,023 lines | IMPLEMENTED | `prog/test-runner.prog:28`, Phase 2. **Its own gate, Phase 12, is unported** (`tools/test/run-tests.sh:423` prints it NOT PORTED; `lowering-and-emit/LE22`, `docs/arcs/lowering-and-emit-arc.md:222`) |
| observation kinds: exit code, emitted bytes, evaluator value; no text arm by rule | `test-floor.chiral:89-92`, rule at `:83-87` | IMPLEMENTED | the same |
| build-and-run in process: `run-src` compiles with the floor's own compiled-in `compile-all` | `test-floor.chiral:223-228`; import at `:34` | IMPLEMENTED | `observe` `:601`, `mut-run` `:615` |
| run an ELF, exit code back | `run-elf`, `test-floor.chiral:192`; lowered as `nb-run-elf`, `lib/lowering/tal/sys.chiral:441-450` | ENFORCED | Phase 2 |
| spawn a program by argv and capture its stdout | `proc-spawn`, `lib/runtime/proc.chiral:121-129`, `Child`'s `io` at `:33`; lowered natively, `lib/lowering/tal/crossing-wraps.chiral:54` | IMPLEMENTED. Measured this run: `prog/samples/a5_proc_spawn.prog` built by `bin/chirality-bin` prints `hi` and exits 42 | Phase 7 as a compile-only root |
| feed a child's stdin | `run-filter`, `proc.chiral:133-148`, takes `input` and never uses it | absent | nothing. `tool-authority/TA8` (`docs/arcs/tool-authority-arc.md:200`) rows a caller-supplied descriptor set |
| read a file | `openat` plus `read-fd-all` | ENFORCED | every probe |
| write a file | `open-create`, `lib/ports/file.port:15` | IMPLEMENTED (E105) | |
| make a directory, unlink | no extern in `lib/ports/` | absent | |
| directory walk | E148, `zero-python/Z2`, ledger `design` | absent | |
| argv | E150, `zero-python/Z3`, ledger `design`; `/proc/self/cmdline` works today | SEEDED | nothing |
| module resolution in chirality | `bundle-src`, `lib/module/resolve.chiral:395`; outside the compiler's closure (61 modules in `prog/compiler.prog`'s blob, `module/resolve` not among them, measured this run) | IMPLEMENTED | `test-floor.chiral:44`. The build path uses `bin/chirality-resolve.sh`, sourced by 28 files under `tools/` and `bin/` today (`PRB-59` read 25) |
| a mutant compiler built by the promoted binary, then put under a phase | `tools/test/mutant.sh:87`, `:144`, `:166` via `CHIRALITY_COMPILE` | IMPLEMENTED; library half under the suite | phases 3, 4, 6 |
| the dispatch table and its witness | `run_phase`, `tools/test/run-tests.sh:125-143`; 22 dispatch lines; `tools/test/registration.sh` | ENFORCED | `run-tests.sh` runs the witness after the table |
| the tally | `ok()` and `bad()` defined once per script, **24 copies** (`grep -hE '^(ok\|bad)\(\)' tools/test/*.sh`) | ENFORCED | `run_phase` parses `N passed, M failed` from each log |

`registration.sh`, run this session (9.7 s), prints `22 dispatch lines in
run-tests.sh, 29 scripts`, `7 of 29 scripts are outside the dispatch table by
their own declaration`, and `registration: 9 passed, 0 failed`. The seven are
`map-integrity.sh`, `mutant.sh`, `opt-census.sh`, `registration.sh`,
`run-tests.sh`, `shape-census.sh` and `tal-check.sh`.

### Reading 4: who builds a native judge

The seam that puts a candidate compiler under the whole suite is
`CHIRALITY_COMPILE` (`tools/test/mutant.sh:34-37`, `run-tests.sh:45-46`). Every
program a gate builds with `$CC` is built by the candidate. For a probe that is
right: the probe is the subject. For a judge it is the defect the draft
[[decisions/decision-formulation-distinctness]] names as the building-binary
axis (`:75`, and condition 3 at `:158-159`): *"the artifact under test compiling
the judge that grades it"*, attestable by requiring the judge's builder to
predate the artifact. `mutant.sh:87` and `:144` already build every mutant with
the promoted `bin/chirality-bin`, so the practice exists. Phase 2 does the
opposite: `run-tests.sh:93-96` builds `prog/test-runner.prog` with `$CC`, so in
a mutant run the runner is built by the mutant. Whether that is a defect or the
point of Phase 2 is outside this row.

The criterion that would license a native comparator is
`independent-judgment/J1` (`docs/arcs/independent-judgment-arc.md:96`), drafted
and unruled. `PRB-66` reads that the gate tier's judgments wait on it and was
re-measured 2026-09-06 at 421 call sites; the same command reads **502** today
(`grep -hoE '(^|[|;( ])(grep|sed|awk|sort)' tools/test/*.sh | wc -l`), 41 in
`matcher.sh`.

### Reading 5: cost of a native judge

`prog/test-runner.prog` resolves to a 944,477-byte blob over 64 modules and
builds in **0.90 s** under `bin/chirality-bin` to a 1,307,000-byte ELF;
`prog/prose-lint.prog`, 62 modules, 0.85 s, 1,294,712 bytes. Build time is no
obstacle. Size is [[arcs/binary-split-arc]]'s subject: each judge carries the
compiler because `read-fd-all` lives at `lib/lowering/compile-all.chiral:53`
(`binary-split/B1`). That costs bytes and presentability; it blocks nothing here.

## 3. The delta

**Verdict: a real delta, and it is four deliverables.**

What is built: the native floor a gate is a value in (E168), running an ELF
(`run-elf`), spawning with stdout capture (E33), resolution
(`module/resolve`), and nine probes that already put a gate's *extraction* in
chirality. What is missing is everything between a probe's output and a verdict
the suite counts, plus the adoption discipline the text-tools arc showed the
tree does not have.

1. **A native judge floor.** A judge program built by the promoted binary that
   reads the artifacts a front end built, runs them, compares against constants
   it holds, and prints the tally `run_phase` parses. `Obs` has no arm for a
   child's stdout (`test-floor.chiral:89-92`), `run-src` compiles with the
   judge's own compiled-in compiler (`:223-228`), which is the wrong compiler
   for a gate whose subject is `$CC`, and nothing builds a judge with the
   promoted binary as a rule.
2. **An adoption witness.** Nothing reddens when a native judge exists and no
   dispatch line reaches it, which is the `prose-lint` state today.
   `registration.sh` prints `PEND` for undispatched *shell* scripts and has no
   notion of a native judge.
3. **The ports themselves.** 29 scripts. Each is a separate differential and a
   separate deletion. Their judgments are gated on Reading 4's criterion.
4. **The build half.** Resolving a blob, invoking `$CC`, generating mutant
   compilers in a scratch tree. This is the shell that does not judge, and it
   cannot move today: feeding a blob to a candidate compiler needs a child's
   stdin (`TA8`) or argv (E150), and scratch trees need `mkdir` (absent).

Items 1 and 2 constrain each other: the witness is the floor's first consumer,
per [[decisions/decision-primitive-with-consumer]]. Items 3 and 4 wait on
different things, an author ruling and three enablers. **Proposed cut:** this
row mints items 1 and 2 as one element; items 3 and 4 become roster rows the
wave-1 revisit opens (residue table). The roster is unedited by this run.

## 4. The shapes

### Shape W, the whole-tier rewrite
- **Form:** one native harness replaces `run-tests.sh` and every phase at once,
  build half included.
- **Costs:** blocked today on E148, E150 or `TA8`, and on `mkdir`; roughly the
  12,183 lines rewritten in one pass; one differential over 29 gates.
- **Forbids:** any gate staying shell during the move. Nothing in the tree
  forces that and the enablers do not exist. Refused.

### Shape T, twin-then-switch per gate (the row as written)
- **Form:** per gate, a `.prog` judge beside the shell, a differential gate,
  switch later.
- **Costs:** cheap per gate.
- **Forbids:** nothing, and that is its defect. It is the shape `prose-lint`,
  `resolve` and `paren-audit` took, and all three stopped before the switch
  (Reading 2). A twin that nothing dispatches reads as native lines in the ratio
  and sits at SEEDED by the goal's reach test. Refused.

### Shape J, judge floor plus switch-in-one-commit
- **Form:**
  1. **Judge floor.** A module beside the test floor (outside the compiler's
     closure, so no BUILD RULE cycle) that gives a judge: a child-stdout
     observation carried as bytes from `proc-spawn`, a run of a pre-built ELF
     path, a comparison against constants the judge holds under an `ExProv`
     label, and the tally line. A judge is built by `bin/chirality-bin`, the
     promoted binary. `$CC` builds probes and nothing else; the front end that builds it says so
     and the witness checks it.
  2. **Front end stays shell for the build half.** The script resolves blobs,
     builds probes and mutant compilers with `$CC` as today, and hands the judge
     a list of artifact paths on stdin, the input idiom `prose-lint.prog`
     already uses.
  3. **The witness.** Registration moves native as the floor's first consumer.
     It reads `run-tests.sh` and the script list on stdin, carries G1 to G6,
     and adds a row: every judge `.prog` is reached by a dispatch line or
     declares itself out with a reason, else `PEND`. Its mutants M1 to M7 are
     edits of the table's text, done in memory by the judge, so the scratch-tree
     copy `registration.sh` makes today goes away.
  4. **The reach census.** The same judge prints condition 5's observation:
     shell lines, native lines, and native lines reached by a dispatch line.
     The goal's figures stop being hand counts (`PRB-68`).
  5. **The port protocol**, binding on every later port:
     - (a) before the switch, the shell gate and the native judge run on the
       same inputs: the base tree and every mutant the shell gate names, each
       producing a per-row verdict vector; the two vectors agree row for row,
       and the native judge has no fewer rows;
     - (b) the result is a `records/` row carrying the command, the commit and
       both vectors;
     - (c) one commit adds the judge, repoints the dispatch line, and deletes
       the shell judgment. At no commit are both live as alternatives;
     - (d) the witness's reach row keeps the judge dispatched after that.
- **Costs:** one element now, a port per gate later; the build half stays shell
  until its enablers land.
- **Forbids:** a native judge nobody dispatches (the witness reddens), a judge
  built by the candidate compiler, and a port whose equivalence was never run.
  All three are wanted.

### Shape F, freeze and count
- **Form:** state a target ratio and a rule that new gates are native; port
  nothing.
- **Costs:** nothing now.
- **Forbids:** nothing, and moves nothing. A rule with no floor to write native
  gates on is unsatisfiable today, since every new gate would have to invent
  its own judge. Refused.

## 5. The call

- **Chosen:** Shape J, because it is the one shape where adoption is the
  deliverable, which is the half the text-tools arc measured missing twice and
  the half the row's own precedent is missing. Its first consumer is chosen for
  the same reason: the witness is the gate that makes every later port's
  adoption checkable.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Who builds a native judge | **RESOLVED → the promoted `bin/chirality-bin`, never `$CC`** | the practice at `tools/test/mutant.sh:87`, `:144`; the building-binary axis is the one the draft grades attestable (`docs/decisions/decision-formulation-distinctness.md:75`). This settles the harness and the witness, whose subject is the dispatch table. It does not settle Q5 |
| 2 | How a child's stdout is observed | **RESOLVED → as bytes, compared byte for byte against a constant carrying an `ExProv` label** | `Obs`'s refusal of a text arm (`test-floor.chiral:83-87`) is aimed at a rendering deciding a verdict. The probe idiom already decides on printed values against constants (`apply-word.sh:33-35`), and moving the comparison native changes the judge's language and leaves what is observed alone. The SPEC names the arm |
| 3 | Which phase number a ported gate takes | **RESOLVED → it keeps its number** | a port repoints a dispatch line. The numbering rule is ruled (`records/author-calls.md` row *"Which suite phase number a new gate takes"*, `ruled` 2026-09-06; `tools/test/run-tests.sh:348-351`) |
| 4 | Whether this row is one element | **RESOLVED → one element now, two rows owed** | §3's cut. Opening the rows is the wave-1 revisit's (`.planning/DISPATCH-QUEUE.md` §Waves, E4) |
| 5 | May a gate's judgment of compiler output move into a native judge on the building-binary axis alone, before `independent-judgment/J1` is ruled? | **NEEDS-AUTHOR** | `PRB-66` reads that the gate tier's judgments wait on J1; J1 is drafted and unruled (`docs/arcs/independent-judgment-arc.md:96`, `:114`). A yes lets the port row start after this element; a no holds every port but the witness until J1 |
| 6 | Are new gates native from now on? | **NEEDS-AUTHOR, with a proposal** | proposed rule below |
| 7 | How condition 5 counts the retained bucket | **NEEDS-AUTHOR** | `docs/goals/enforcement.md` keeps comparators holding constants outside the language on purpose. `mul-widen.sh`'s bash reference and `enforcement/N24`'s planned bash derivation are that bucket. Whether those lines leave the ratio's numerator is a goal condition's measure, which is the author's |

**The new-gate rule this design proposes (question 6).** Refused as a blanket
rule today: there is no judge floor, so a native gate written now invents its
own judge, and one built with `$CC` is the common-mode defect of Reading 4.
Proposed instead: **from the commit that dispatches this element's witness, a
new gate's judgment half is a native judge on the floor, dispatched on the day
it lands; its build half may stay shell until the build-half row closes.**
Before that commit a new gate is shell and is counted. Applied to this week's
two: `tools/test/shape-census.sh` already conforms in spirit, the census is
native (`prog/shape-census.prog`) and the comparison shell, and it would be a
port like any other. `enforcement/N24`'s planned `fold-rules.sh` lands before
the witness and so stays shell under the rule; its bash-derived reference is
question 7's bucket either way.

Three NEEDS-AUTHOR, so `status: blocked`. Each earns a row in
[[records/author-calls]]; this run writes none, by its brief.

## 6. The mint packet

- **Elements: one.** The judge floor and the native registration witness
  constrain each other: the witness is the floor's first consumer, and a floor
  whose first consumer is anything else leaves the adoption check unwritten.
  The reach census rides the witness because both read the dispatch table.
  The port row and the build-half row are roster rows, listed in the residue.
- **Band:** `E184-E189` is spent (`docs/decisions/decision-lane-split.md:31-35`).
  The arc takes the next free number tree-wide at mint, which `pack.py --mint`
  recomputes; `N23` and `N24` are unminted and draw on the same pool, so the
  number depends on mint order.
- **Catalog row:**
  `| E<NN> | **The gate judge floor, adopted: a native judge built by the promoted binary reads the artifacts a shell front end built, observes them, compares against constants it holds, and prints the suite's tally; its first consumer is the registration witness, which reddens on a judge no dispatch line reaches and prints condition 5's reach census.** | tool | OURS (lib/evidence/test-floor.chiral, E168; prog/test-runner.prog; tools/test/registration.sh) | OURS | A port whose switch never happens is the measured failure of PRB-59, PRB-60 and prose-lint; the witness makes the switch checkable, and every later gate port runs under its protocol | SH |`
- **Ledger row:**
  `| E<NN> | gate-judge | design | Judge floor beside the test floor, built by the promoted binary; native registration witness with a reach row over judge programs; reach census; port protocol (same-input verdict differential over base and mutants, one-commit switch) | enforcement/N10 | SH |`
- **Size and closure.** Basis: `prog/test-runner.prog` is 134 lines on the
  floor; `tools/test/registration.sh` is 300 lines, 173 of them code;
  `prog/shape-census.prog` is 671 lines for a census over `lib/` and `prog/`.

  | file | change | lines | inside `prog/compiler.prog`'s closure |
  |---|---|---|---|
  | `lib/evidence/gate-judge.chiral` (new) | stdout observation, pre-built-ELF run, constant comparison under `ExProv`, tally | 150 to 250 | no |
  | `prog/gate-registration.prog` (new) | G1 to G6, the reach row, in-memory M1 to M7, the census | 300 to 450 | no |
  | `tools/test/registration.sh` | reduced to the front end: script list on stdin, judge built by `bin/chirality-bin` | 300 → 40 to 60 | no |
  | `tools/test/run-tests.sh` | the witness block builds the judge with the promoted binary | 5 to 15 | no |
  | `records/` | the port-protocol differential row for the witness itself | 1 row | no |

  About 500 to 700 chirality lines in, about 250 shell lines out. No closure
  file changes, so the BUILD RULE owes no cycle. `lowering-and-emit/LE22`,
  Phase 12, should land before this element's implement stage: the floor this
  builds beside has its own gate unported.
- **Related:** [[goals/enforcement]] condition 5 · [[arcs/zero-python-arc]]
  requirements 3 and 4 · [[arcs/text-tools-arc]] §Adoption ·
  [[arcs/binary-split-arc]] `B1` · [[arcs/independent-judgment-arc]] `J1` ·
  `records/lenses/problems.md` PRB-59, PRB-60, PRB-66, PRB-68 · E33, E105, E148,
  E150, E168, E173

Every `E#` named here is already minted.

## Residue

### Needed and unrostered

Grepped 2026-09-29 over `docs/arcs/*-arc.md` roster rows for `stdin`, `spawn`,
`E33`, `resolve.prog`, `prose-lint`, `mutant`, `registration`, `tally`,
`run-tests`, `E168`, `reach`, `building binary`. Rostered and not repeated here:
Phase 12 (`lowering-and-emit/LE22`), the two resolver providers
(`lowering-and-emit/LE16`), argv (`zero-python/Z3`, E150), the directory walk
(`zero-python/Z2`, E148), the child descriptor set (`tool-authority/TA8`),
`read-fd-all`'s home (`binary-split/B1`), the `paren-audit` port
(`zero-python/Z6`), J1.

| needed | evidence | arc it belongs to |
|---|---|---|
| the gate ports, one per script, each under this element's protocol and each `direct` once the element is built: 22 dispatched scripts and the declared-out ones that judge | `tools/test/*.sh`, 29 scripts, 12,183 lines; `registration.sh` output, this run | enforcement, requirement 5, beside `N10` |
| the build half moved native: blob resolution, `$CC` invocation and mutant compilers without a shell, once a candidate compiler can be fed a blob and a scratch tree can be made | `lib/runtime/proc.chiral:133-148` (`run-filter` ignores `input`); `lib/ports/file.port:15` is the only creating extern and no `mkdir` exists under `lib/ports/`; `mutant.sh:144` pipes a blob into the compiler | enforcement, requirement 5, beside `N10` |
| `prose-lint`'s switch: `prose-lint.sh` calls the native eight checks and loses its awk `_scan`, G9 as the recorded differential | `tools/prose-lint/prose-lint.sh:86-113`, `:153-176`; `tools/test/matcher.sh:450-535` | text-tools, requirement 4 (§Adoption), beside `P1` |
| `mkdir` and `unlink` crossings, so a native harness can make and clear a scratch tree | no extern in `lib/ports/*.port` (grep this run) | zero-python, enablers, beside `Z5` |
| `run-filter` feeds the input it takes, or drops the parameter | `lib/runtime/proc.chiral:133-148` | tool-authority, beside `TA8` |

### Drift against the brief, the row and the tree

- The row's figures are 2026-09-06 and dated nowhere in the row. 1,775
  reproduces exactly at `26f48fb`; 10,719 does not (10,744 there). Today 12,183
  and 2,557, Reading 1.
- The row's precedent is false as stated, Reading 2. `tools/README.md:23` and
  `tools/prose-lint/README.md:6` carry the same claim.
- `docs/goals/enforcement.md:41` reads *"No row serves this"* for condition 5.
  `N10` has served it since 2026-09-06 and `GAP-02` is closed with this row as
  owner.
- `docs/arcs/enforcement-arc.md:183` and `:433` read the suite-phase-number call
  as open. It is `ruled`, 2026-09-06.
- `tools/test/apply-word.sh:6-16` reads `UNREGISTERED`. `run-tests.sh:361`
  dispatches it as phase 25.
- `bin/chirality:193` says `test` builds `prog/test-runner.prog` and runs it.
  `:181` execs `tools/test/run-tests.sh`, which does that as its Phase 2.
- `lib/runtime/proc.chiral:108` and `:116` say spawn and reap are backed by
  a Python host binding. `crossing-wraps.chiral:54-55` lowers both natively, and
  `a5_proc_spawn.prog` ran green this session.
- `PRB-66`'s count is 502 today against its 421, by its own command.
- The brief's suite figure (441 assertions, 96 roots) is the brief's; this run
  did not take the suite.
  `registration.sh` was, and it reads 22 dispatch lines over 29 scripts.
