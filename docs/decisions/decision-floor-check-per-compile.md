---
node: decision-floor-check-per-compile
layer: decision
related: [decision-preserve-check, decision-split-checker, decision-self-verification, index]
status: draft
updated: 2026-09-29
---

# Decision: the floor checker runs on every compile, as its own process outside the compiler closure

Derived 2026-09-29 under `.planning/protocol/reconcile.md`, verdict `DISSOLVED`.
It is `draft` until the check run that follows every dissolution has tried to
revive an eliminated option, and the author keeps a veto
([[records/author-calls]], the row this note is cited from).

## 0. The fork

**Does a `ck-prog` call in a gate outside the compiler closure discharge
`enforcement/N8` and goal condition 3, or do they still owe a check on the
shipping compile?**

Three texts meet here. `enforcement/N8` keeps *"the call site `ck-prog` has
never had, PRB-15"* (`docs/arcs/enforcement-arc.md:539`). [[goals/enforcement]]
condition 3 is observed by *"the floor checker and the optimizer's re-check
running in the shipping compile"* (`docs/goals/enforcement.md:33-34`). PRB-70
ruled 2026-09-08 that *"the checker stays OUTSIDE the compiler closure and the
wiring is the defect"* (`records/lenses/problems.md:986`), naming
`lowering/tal/check`, where `ck-prog` is defined
(`lib/lowering/tal/check.chiral:309-312`). `docs/arcs/parts/enforcement-N12.md`
§5 raised it as question 9 (`:198`) and its §1 reads the census gate as
requirement 2's remaining half (`:21-23`).

**The answer.** The gate does not discharge either text. Both owe `ck-prog` run
over the program each shipping compile produces, refusing the output when it
answers `tck-err`, in a process of its own whose closure the compiler's does not
hold. That placement meets condition 3's words and PRB-70's words at once, and
it is the one reading under which the author's two standing texts agree.

## 1. The options

| # | option | shape |
|---|---|---|
| 1 | the census gate over every root counts as `N8`'s call site and as condition 3's observable | improper split |
| 2 | `back-program` calls `ck-prog` inside the compiler and refuses on `tck-err`, `enforcement-N12.md` Shape D | proper |
| 3 | every shipping compile runs `ck-prog` in a separate checker process over the program that compile produced, the compile's output is withheld on `tck-err`, and a gate reddens when the check is cut | proper |
| 4 | option 2 or 3 run only on a flag or a profile | a narrower claim |
| 5 | not at all: `N8` and condition 3 are written as undone | not at all |
| 6 | condition 3 is amended to name the gate | improper split |
| 7 | the four-line `ck-prog` wrapper moves to another file inside the closure | proper in form |
| 8 | the lowering is proved type-preserving once, so no target check runs | proper in form |

## 2. Refused at step 1

**1 and 6.** Each counts a gate over a named corpus where condition 3 asks for a
check on the shipping compile, and 6 adopts the narrower claim by rewriting the
condition. `.planning/protocol/reconcile.md` §Proper or not at all refuses both
by name: *"a gate standing where a check was required"* and *"a narrower claim
adopted because the full one is hard"*. The tree already reads it this way.
`docs/arcs/enforcement-arc.md:89-100` records after PRB-70 that *"no judgment of
the floor runs on the shipping path"* while the census kept running, so the arc
never counted the census as the shipping path.

## 3. Eliminated

**2, by PRB-70's words.** The ruling names `lowering/tal/check` and keeps it out
of the closure, and `tools/test/tal-check.sh:409-410` G18 asserts zero `def
ck-prog` in the compiler blob. Shape D forbids itself in its own design
(`docs/arcs/parts/enforcement-N12.md` §4). Reopening a ruling is the author's.

**7, by PRB-70's words.** The ruling refused it outright: *"Splitting the
four-line `ck-prog` wrapper at `check.chiral:308-312` into another file was
refused as the shape that turns G18's grep green with the checker still in the
blob."*

**4, by P4.** `PRINCIPLES.md:125-128` makes the well-behaved shape the default
and the risky shape *"the one you opt into loudly"*. A check reached by a flag
leaves the default compile unchecked and makes the checked one the climb, the
inverted gradient. Its in-closure form also falls to PRB-70.

**5, by scope.** "Not at all" is admitted only for work out of scope and never
lowers a requirement. [[goals/enforcement]] is open, condition 3 is scheduled on
`N6` to `N9`, and scope is the author's (`docs/decisions/decision-scope.md`).

**8, by the goal's observable and the cut judgment.** Condition 3 is observed by
the floor checker running, and a proof replaces that observable, which is the
author's to change. FD-20 prices this route as a verified compiler, and FD-55 §4
(`records/findings.md:1512`) as CompCert's, 76% proof in Coq. External judgment
is cut (`docs/decisions/decision-self-verification.md:11`) and the tree carries
no proof assistant.

## 4. The survivor against the principles

**P1** (`PRINCIPLES.md:26-28`, `:44-49`): everything the substrate does is named
and gateable, and deny by default covers the whole surface. Option 3 judges
every program the shipping compile produces, so no compiled program escapes the
floor. Its completeness rests on every compile passing through the checked
entry, and 28 scripts under `tools/` name `bin/chirality-bin` directly today
(measured below). Left open, that would be P1's seccomp hole, a check over the
entry points someone listed. §6 (b) queues the one-entry invariant and its gate,
which is the written reason 3 passes.

**P2** (`:56`, `:66-70`): no category of code opts out of the type, and the
checker's own budget is unfinished. Every emitted program carries its target
typing through a check, and no build is exempt. The check's cost has a separate
process to be measured in, which suits the unfinished budget clause. It prices
nothing, so it separates nothing.

**P3** (`:83-85`): govern the membrane, the port-check is the type-check. The
compiled artifact leaving the compiler for a disk or a loader is the crossing,
and option 3 checks there, with the compiler's interior left free. The check's
time and memory sit on that membrane and no goal condition holds them, §6 (d).

**P4** (`:125-131`, honest limit `:134-142`): the checked compile is the default
path. The limit's conservative-checker tax is measured at zero today: `ck-prog`
accepts 38,333 of 38,333 TFns over 97 roots
(`docs/arcs/parts/enforcement-N12.md` Reading 4). The writer-side ceremony PRB-70
priced, the BUILD RULE on every edit of `check.chiral`, stays uncharged, because
the checker is its own root.

**P5** (`:154-156`, `:181-182`): a provable thing is held as a typed singleton,
and the reconciler's own trust is assumed. `ck-prog` is T0 target
well-typedness (`docs/decisions/decision-preserve-check.md`), a proof and one
copy. `docs/decisions/decision-split-checker.md:56-59` settles the checker as a
small core that re-checks what untrusted producers emit. The compiler is the
producer, and a checker in a process of its own is the LCF split at the floor.
Trusting-trust stays, because `bin/chirality-bin` compiles the checker too, and
that is the build-time residue the split-checker note already names.

## 5. Constraints read at their words

- **PRB-70.** The checker stays outside `prog/compiler.prog`'s closure and G18
  keeps its polarity under option 3. The ruling's own carrying-out put `ck-fn`
  in `prog/optimizer-census.prog`, a root that imports the compiler's library
  beside `check.chiral`, so a root of that kind is inside the ruling. Its three
  measurements: the wiring put `ck-fn` in the blob and never `ck-prog` (option 3
  calls `ck-prog`); the in-closure guard changed no shipped byte (option 3
  withholds output on refusal, and Reading 3 of the N12 design shows `ck-prog`
  refusing a mutant compiler's output); the BUILD RULE charge and the
  scratch-`lib/` harness (both left as they stand). ⚑ **This reads "the wiring"
  as the in-closure import and call the ruling cut at `b613a8f`.** The check run
  owes a test of that reading.
- **Goal condition 3.** "The shipping compile" is read as the compile whose
  output ships, which is also the goal's heading, *"runs on the shipping path"*
  (`docs/goals/enforcement.md:33`). The reading that puts the check inside the
  compiler binary makes condition 3 and PRB-70 contradict, and nothing in the
  tree records the author intending that.
- **The value-check ruling** (`records/author-calls.md:116`): *"Gate now plus a
  check inside every compile *on the map queued* obviously."* Its words name the
  value-agreement check, so they do not reach `ck-prog` and this row is not
  `ruled` on them. The derivation agrees with them: a check on every compile,
  with a gate.
- **`docs/decisions/decision-self-verification.md:172-176`**, `draft`, places the
  check *"per compilation"* against *"each emitted artifact"*. Option 3 is that
  placement.

## 6. What it leaves open

Each of these is work the survivor queues. None is a reason to build less.

**(a) What the checker reads.** Either the compiler writes the TAL program it
produced as an artifact the checker parses, which checks this run's program, or
the checker recomputes it through one function it shares with `back-program`,
the first row of `docs/arcs/parts/enforcement-N12.md` §Residue. FD-20 pins the
consumer-side form, NECTHESIS:2159: the receiver does not *"have to trust the
certifying compiler because it has other means to verify that the emitted"*
code. The replica loop in `prog/optimizer-census.prog:153-163` is a stand-in for
the shipped program and does not qualify for this role. The design stage picks
between the two admitted forms.

**(b) One checked entry.** `chirality compile`, `run` and `check`
(`bin/chirality:211-213`), the BUILD RULE's generations
(`docs/definitions/working-discipline.md:29`), and Phase 7's roots all produce
programs the tree ships or runs. Each goes through the checked entry, and a gate
reddens on a direct call that bypasses it.

**(c) A gate over the check itself.** A row that reddens when the per-compile
call is cut and a mutant compiler the check refuses. Requirement 4 closed once
with no such row and the suite stayed green with the wiring cut
(`docs/arcs/enforcement-arc.md:209-236`).

**(d) A budget.** No goal condition holds the compiler's own time or memory
(`.planning/DISPATCH-QUEUE.md:68`, call 8).

**(e) Condition 3's other half.** The optimizer's re-check (`N7`, requirement 4)
keeps or refuses one rewrite at a time, which needs `ck-fn` inside `opt-tfns`,
inside the closure PRB-70 bars. Option 3 refuses a whole compile, so it covers
the re-check's type property at program granularity and leaves the per-rewrite
fallback unanswered. That fork is `N7`'s own. The same limit applies to the
value-check ruling's in-compile half, whose check keeps the input per rewrite.

**(f) `enforcement/N12`.** Its §1 and question 9 read the census as requirement
2's half (`docs/arcs/parts/enforcement-N12.md:21-23`, `:198`). The census stays
requirement 3's instrument, the checker agreeing with the compiler over every
root, and its `req: 2, 3` cell owes a revisit against this note.

## 7. Measured

2026-09-29 at `df8e77d`, `lib/` unchanged at `824820d`, with the committed
`bin/chirality-bin` under an unlimited stack.

| subject | wall | max RSS |
|---|---|---|
| self-compile of the 851,722-byte `prog/compiler.prog` blob, two runs, byte-identical to the tracked binary | 0.803 s, 0.796 s | 394,240 KB |
| build `prog/optimizer-census.prog` | 0.473 s | 227,456 KB |
| run it over the compiler blob, two runs: front and back recomputed, `ck-fn` over 1,551 TFns twice | 0.478 s, 0.502 s | 155,712 KB |

The census run bounds the recompute form of (a) from above on the tree's largest
program, about 0.5 s and 156 MB beside a 0.8 s compile. `grep -rlE
'chirality-bin' tools/ --include='*.sh'` returns 28 files, the count behind (b).

## 8. Sources

FD-20 (`records/findings.md:201`): TAL states the independence as the feature,
TALTR:54 *"the safety of the resulting assembly code can be checked
independently of the source code or"* the compiler, and TALT:75 names the
checker as the thing still trusted. NECTHESIS:2159 puts the check on the
receiving side. What that lineage assumes is a checker distinct from the
producer, and `docs/decisions/decision-split-checker.md` holds the same shape,
so it transfers. FD-55 §4 (`records/findings.md:1512-1517`): the per-compile
validators that run inside a compiler are Tristan and Leroy's, proved inside
CompCert, which rests on a proof assistant this tree does not carry. Alive2 and
the nanopass driver run outside the shipping compile over a named corpus, which
is the census gate's shape and places nothing per compile.
