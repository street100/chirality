---
node: testing-floors
layer: foundation
related: [floor-agreement, certificate-discipline, axis-altitude, decision-backend, modules-lowering, decision-split-checker, split-role, status-ledger, trust-boundary, open-edges]
status: current
updated: 2026-09-04
---

# Testing floors

> **⚑ THE EXTERNAL FLOORS ARE CUT, and this note was rewritten against the live
> tree 2026-09-04.** External judgment went by author decision
> ([[decisions/decision-scope]]). `rocq/` and `scaffold/` are both absent from
> the tree, and so is every `chirality/*.py`. `bin/chirality` dispatches
> `compile`, `run`, `check`, `test` and `help`, so `chirality test-native`,
> `chirality test-rocq`, `chirality test-python` and `chirality verify` name
> nothing. [[status-ledger]] carries that fact as the build-state authority and
> this note points at it rather than restating it.
>
> Every passage below describing a rocq obligation, a Python differential, a
> CompCert leg, or a path under `scaffold/` is **historical**, and dated where it
> stands. `records/baseline-alignment.md` BA-08 and BA-31 are the rows that
> found it.
>
> **What the cut does NOT retract.** Rules 1, 2 and 3, the run-the-mutant rule,
> the expectation-provenance ranking and the anchor admission test were paid for
> by E156, E161, E166, E168 and E170. A rule learned from a floor outlives the
> floor. What is retracted is the coverage.

> **⚑ THE `Mach`→C LEG IS DROPPED, 2026-09-01** (`d8bcec5`, `d0c5dd5`).
> `lib/lowering/c/{mach,assemble,emit}.chiral`, `prog/compiler-c.prog` and the
> four `e166_*` fixtures are gone. Every claim below that the leg is built,
> admitted, registered or running is **historical**, and dated as such where it
> stands. The reason is the criterion itself, and says nothing about the leg's
> quality: it shared
> `compile-front` and `compile-back` whole with the canonical instance and
> differed only at emit, which makes it a second **target** under one
> formulation. Self-verification here goes through N semantically distinct
> judgment cores that must agree, and `CLAUDE.md` says why a second encoding of
> one rule set buys nothing. See [[decision-self-verification]].
>
> **What the drop does NOT retract.** Rules 1, 2 and 3 below, the run-the-mutant
> rule, and the expectation-provenance ranking were all paid for by E166 and all
> still bind. A rule learned from a leg outlives the leg. What is retracted is
> only the coverage: the `Mach` ops row of the map below has **no** instrument
> now, in-house or external, and nothing else moved in to take it.
>
> ⚑ **This banner shifted every line below it by +24.** Any citation of the form
> `testing-floors.md:NNN` written before 2026-09-01 now lands 18 lines early. Most
> of them also carry the pre-migration path `docs/testing-floors.md`, which has
> not existed since the hoist, so they were already unusable; the offset is
> recorded here rather than repointed one by one at a guess.

chirality is tested by **multiple independent floors** (see `floor-agreement.md`).
Removing the Python oracle is a rung-1 *milestone goal*, **not** a mechanical
prerequisite for anything: Python compiles nothing (B1 self-hosts), and the
self-host fixpoint re-checks most existing behavior transitively. So the oracle
is retired as a **background migration** while chirality and scriba keep moving.

This file is the contract that makes that possible: which floors **gate** and
which are **advisory**, and the discipline that migrates coverage feature by
feature so the retirement completes as a byproduct of normal work.

## The floors

| Floor | Command | Role | Gates? |
|---|---|---|---|
| **native-behavioral** | `tools/test/run-tests.sh`, reached as `chirality test` | primary correctness gate — compile a `.chiral` program whose *meaning* fixes an exit code, run it natively, check it. Zero Python. **Measured 2026-09-04: 339 passed, 0 failed, 87 roots, `gate PASSED`.** ⚑ *Every figure in the rest of this cell was measured against the pre-migration tree and is kept at the date it was taken.* **Eleven phases; 163 ok / 0 FAIL / 82 roots, exit 0, measured 2026-08-25**; wall clock **5m07s–5m36s** over seven runs 2026-08-25 — the range, the per-phase breakdown, and the fact that the earlier "~4-minute budget" was never measured all live in [[benchmarks/test-suite-wall-clock]], which owns the figure. ⚑ Every figure there predates the 2026-08-31 migration and is not a baseline for the current tree. Orientation only: **75 % of it is two phases** (Phase 7 at 45 %, Phase 10 at 30 %), and 82 % of Phase 7 is `bin/chirality-resolve.sh` forking helpers rather than anything compiling. ⚑ *The "3m35s at `70ee90f`" this row used to carry disagreed with [[benchmarks/test-suite-wall-clock]]'s **2m52s** for the same commit and the same 163 assertions, and both are now FALSIFIED: phases whose workload that commit and HEAD share exactly (94 roots, 25 F3 samples) cost more than either figure allows for the whole run. A floors contract should not carry a rival wall clock.* Phase 10 is E166's external-compiler leg, run in its `--no-admission` form so the suite does not re-enter itself; **Phase 11** is the resolver + build-state gate (E155/E161, 19 assertions), wired in at `70ee90f` after sitting orphaned. *The "Ten phases; 144 ok" this row carried was the 2026-08-24 measurement, one phase out of date.* | **GATING** |
| **tal floor checker** | `tools/test/tal-check.sh` | Phase 22, the independent checker over the typed IR: 16 hand-built TFns, nine REJECT rows, three mutants that each turn a named row red. Added `ddfbc27`. | ⚑ **unregistered** in `run-tests.sh` by decision: the `run_phase` line is owed to the suite-owning session, as `crypto.sh`'s is, so it runs by hand and the suite's 339 excludes it. ⚑ **The 22 is the script's own claim, and the number is contested.** `tools/test/tal-check.sh:5` takes 22 and leaves 21 to `crypto.sh`; `tools/test/crypto.sh:8` claims **no** phase number and records 21 through 23 as free at this writing; `tools/test/run-tests.sh:332` and `docs/decisions/decision-lane-split.md:30` reserve 21 through 23 for **Lane B**, which owns E146, E163 and E183. Which suite phase a new gate takes is a standing author call, `records/author-calls.md`. Until 2026-09-04 this cell read that a `crypto.sh` precedent held phase 21; `crypto.sh` has never made that claim. TC-08 in `records/tooling-classification.md` carries the collision, and nothing here assigns a number |
| **rocq (external spec)** | ⚑ **CUT 2026-09-01** | an independent formalization of chirality semantics under `coqc`, which caught a *consistent* miscompile the fixpoint cannot. `rocq/` and `rocq/HAMMER-MANIFEST.md` are absent from the tree. Historical row, kept because the reasoning below cites it by name. | none |
| **python oracle** | ⚑ **CUT 2026-09-01** | a differential second opinion via the reference interpreter, known-drifting when it went. Historical row. | none |

`chirality test` execs `tools/test/run-tests.sh` and passes iff it passes
(`bin/chirality:181`), forwarding its arguments. ⚑ *The `--strict`,
`--no-python` and `--only <native|rocq|python>` flags this row carried until
2026-09-04 selected among floors that no longer exist, and `run-tests.sh` has no
option parser.* **Live figure, measured 2026-09-04: 339 passed, 0 failed, 87
roots, `gate PASSED`.** [[status-ledger]] owns it.

### What the cut costs, stated rather than absorbed

The fixpoint proves chirality reproduces chirality: *stability*, and nothing
about *correctness*. A compiler that miscompiles consistently still fixpoints.
Something outside the tree was what caught that class, and the rocq floor was
the plan for it. ⚑ **Nothing took its place.** Since 2026-09-01 the tree has one
gating floor and it shares an author, a toolchain and a rule set with the thing
it tests, which is the common-mode case Rule 1 below names. `docs/decisions/decision-self-verification.md`
holds the reasoning that a second encoding of one rule set buys nothing; the
consequence, that the consistent-miscompile class now has no instrument at all,
is recorded here rather than argued away.

## The coverage map — what each instrument can see

The floors table says which suites *gate*. It does not say what any of them can
*see*. This map does, stage by stage down the pipeline; every claim elsewhere in
this file, and every gate row anywhere, must agree with it.

| stage | lines | in-house instrument | external instrument |
|---|---|---|---|
| upper → tal | `lower.chiral` 407 | `interp` vs `tal-eval` (**not built** — E169) | Rocq-verified **`preserve-check`** (E169's external half) |
| tal → `Mach` ops | `emit-core.chiral` 573 | `tal-eval` vs a native run | **tal→C leg** (E167) |
| `Mach` ops → machine | `mach-x64.chiral` **1,737** | — | **`Mach`→C leg (E166) — BUILT 2026-08-24, DROPPED 2026-09-01. The rest of this cell is the record of what it did while it stood; the row has no live instrument now.** `mach-c` + `gcc-12`; registered as `ddc-legc` (`ddc.chiral:162`), disjoint from `ddc-leg0` on the toolchain axis. `bash scaffold/tests/ddc-c-leg.sh` = 10 gates green: **admission** — the native suite run under `chirality-bin-c`, **154 ok / 0 FAIL / 82 roots compiled, exit 0** (re-measured 2026-08-25) — and **conviction** — `chirality-bin-c < blob` and `B1 < blob` byte-identical at 1,077,624 B. Gated as Phase 10 of the native suite. ⚑ **Its differential's corpus is SCOPED BY MARKER since 2026-08-26** — 25 samples swept through the C leg, 17 test-floor fixtures tabled `floor` and judged by Phase 12 instead, each row checked against the judge; what the leg covers is unchanged and Rule 3's amendment below states what it deliberately does not. ⚑ **The "135 ok" this row used to carry was a false attribution, not a stale count.** `CHIRALITY_BIN` was honoured by `run-native.sh`'s own inline phases only, so of those 135 rows exactly **6** (Phase 1) ran under `chirality-bin-c` and **129** (Phases 3/4/5/6/8/9) ran under `B1` while being reported as C-leg coverage; Phase 7's 82 root compiles were genuine, being inline. The five sub-scripts and `bin/chirality` now resolve `CHIRALITY_BIN` first (`ce593c4`), `ledger-lint` check P keeps it total, and the re-run put **148 assertions under the C-built compiler that had never once run under it — all green, nothing diverged**. |
| the checker | — | — | **Rocq spec** (the `rocq/` floor; `rocq/README.md:81` — *"checker soundness is the next slice"*) |

Two rules generate that map. They are stated as rules because reading them off
the table after the fact is how a differential gets built that tests nothing.

**Rule 1 — a differential only covers what is BELOW its branch point.**
Everything above the branch is common-mode: both legs run the same code, so both
legs are wrong the same way and the comparison reports `ok`. This is why E166's
`Mach`→C leg covers `mach-x64`'s 1,737 lines and **not** `emit-core` — both legs
drive the *same* `emit-core`, unchanged; that is exactly the property that makes
E166 cheap, and exactly the reason it cannot see one line of the 573 above it.

**Rule 2 — a differential is worth building only when the new translator is much
smaller than what it tests.** The ratio is the whole economics:

| leg | new code | covers | ratio | verdict |
|---|---|---|---|---|
| `mach-c` (E166) — **built, then dropped 2026-09-01** | 403 raw / **190 code** | `mach-x64` 1,737 raw / **620 code** | **1:4.3 raw · 1:3.3 code** | ✓ |
| `tal-c` (E167) — estimate | ~200–400 raw | 2,310 raw | ~1:6 – 1:11 | ✓ |
| upper→C — estimate | ~2,000 raw | ~2,700 raw | ~1:1.3 | ✗ |

A 1:1.3 "differential" is a **rewrite wearing a differential's clothes** — you
have written a second compiler of comparable size and complexity, with its own
bug population, and learned nothing about which of the two is right. That is why
upper→tal gets Rocq (E169) instead of a C leg.

⚑ **The built row is measured, and it is less flattering than the estimate that
authorized it — say it that way.** E166 was scoped at ~136–380 L against 1,737,
i.e. ~1:5 – 1:12. The built leg is 403 raw lines, of which 190 are code
(`wc -l` and `grep -cvE '^[[:space:]]*(;|$)'`, measured 2026-08-24) — and the
`covers` column's 1,737 is `mach-x64`'s **raw** count, whose own code count is
620. Compared like against like the real ratio is **1:3.3**, at or under the low
end of the estimate, not the 1:9 that mixing the two methods produces. Rule 2's
verdict is unchanged — 1:3.3 is still nothing like upper→C's 1:1.3 — which is the
point worth keeping: the rule survives the honest number, so there is no reason
to report the flattering one. The two unbuilt rows remain raw-line estimates and
are marked as such.

The shape this produces is worth naming: **the C trick covers the machine-ward
half, Rocq covers the proof-ward half, and they meet at tal** — which is what
[[axis-altitude]] already says tal is for (*"Typeability is preserved down
to tal and checked the whole way (`preserve-check`) … tal is the floor and it is
typed. Below tal is the single trusted drop to the metal."*).

**What the built leg bought, stated so it was not oversold** (past tense since 2026-09-01). `ddc-legc` recorded
`("c" "gcc-12" "shred" 2026)` against `ddc-leg0`'s `("chirality" "chirality-native"
"shred" 2026)`: what that differs on is **toolchain**, which is the axis a
trusting-trust attack lives on. It is **not** a smaller trusted base — gcc
carries the whole of gcc. CompCert is what shrinks the drop, and **it is now
built and default** — ⚑ *this passage twice said `ccomp` is absent and that
swapping one constant is the whole of that change; both halves were measured
false, and the work is now landed.*

`ccomp 3.17` builds here (Debian `main`'s coq/ocaml/menhir plus the INRIA
tarball; **no opam** — see [[banks/verification]] §5 item 6 for the recipe), and
**`ddc-c-leg.sh` now runs under it by default**: 9 gates pass, G4 byte-identical
at the same 1,077,624 B gcc produces, in **1m41.6s / 1m41.2s** against gcc's **1m51.7s / 1m40.1s** — ⚑ *two samples each, and they OVERLAP: the leg is indistinguishable between the two compilers at this precision, so read "ccomp costs nothing", never "ccomp is faster". The reliable comparison is at suite level, where the two runs differed by 21 ms.* What it
cost, since the "one constant" story is the one to bury:

- **The shim split.** `m_sys`, `m_trap` and `_start` moved to
  `scaffold/rt/chirality-rt.s`; CompCert refuses local register variables,
  file-scope `__asm__`, and the `"a"`/`"D"`/`"S"`/`"d"` constraints outright.
  ⚑ The trap recorded beside them: relaxing those constraints to generic `"r"`
  **compiles clean and emits a bare `syscall` with no operand reaching any
  register**. "It built" is not evidence for a crossing.
- **Per-compiler `CFLAGS`.** `-ffreestanding`/`-fno-strict-aliasing` are
  `Unknown option` to `ccomp` and semantic no-ops for it. `-finline-asm` is
  **not** needed — the split left no inline asm in the C at all.
- **A second `Prov`, not a swap.** `ddc-legcc ("c" "compcert-3.17" …)` sits
  beside `ddc-legc`, each naming a toolchain that actually built something. ⚑
  **They are not two legs**: `leg2-disjoint?` needs both axes to differ and they
  share `"c"`, so a quorum is leg 0 plus *exactly one*. Asserted by cases 17–20
  of `scaffold/tests/samples/e166_ddc_legc.chiral`. ⚑ That fixture is **deleted**
  (2026-09-01, `d0c5dd5`). `ddc-legc` and `ddc-legcc` are still defined in
  `lib/evidence/ddc.chiral`, and now nothing asserts anything about either.
- **Two files, one trusted drop.** The size check is the **sum**: 89 C code
  lines + 27 asm code lines = **116**, against the SPEC's ~150. Moving code
  across a file boundary must not shrink the number that measures how much we
  are trusting.

`mach-c`'s 2.1 MB of generated C itself needed nothing.

### Rule 3 — a conforming-target gate must be BEHAVIOURAL, not textual

E166 paid for this rule and it belongs beside the other two. The leg is gone as of
2026-09-01; the rule it bought is not, and applies to the next conforming target. `mach-c`'s first
gate was **68 assertions over each arm's emitted C text**, and it passed while
three of those assertions were *pinning a defect*: `true` is tag 0, so a
comparison materialized as a value must yield the tag, and `op-eqi` rendering
`==` **looks** right while being semantically inverted. Text cannot see polarity.
Nothing observed the runtime behaviour of the *composition* until the whole
compiler was built and run, two sessions later.

The answer was **F3**, the behavioural differential (dropped with the leg on
2026-09-01; what follows is what it measured while it ran): the programs in
`scaffold/tests/samples/` (**25 rows swept**, each carrying the exit code its own
header documents, so agreement alone cannot pass it — Rule 1's lesson from E161
G0) compiled through both legs and compared on what it *does*. Re-inverting
`mach-c.chiral:138`'s `!=` back to `==` — the original defect, **run as a mutant
on 2026-08-24 and reverted** — makes F3 diverge on nearly every sample while
G2's single exit-42 program still passes. That is precisely how the defect hid
for two sessions.

⚑ **AMENDED 2026-08-26 — F3's corpus is MARKED by what each sample exercises,
and its count is a scope statement rather than a directory total.** The directory
held **39** `.chiral` files when this was measured and holds **51** today — E170
lane C added three (`e170_conv_eta`, `e170_qtt_semiring`, `e170_refine_top`),
lane D one (`e170_infer_arms`), and lane E eight (`e170_port_twin`,
`e170_port_zeros`, six `e170_reject_*`), and the marker is the reason adding them
cost Phase 10 nothing. F3 sweeps **25**
through the C leg and tables the other **26** under a fourth marker, `floor`:
E168's and E170's test-floor
fixtures, whose subject is `scaffold/lib/test-floor.chiral` and not one `mach-x64`
arm. Pushing them through `mach-c` → C → `$CC` → run reaches nothing the swept 25
do not already reach and costs **15.2 s each** — measured as the difference
between two back-to-back `--no-admission` runs on an otherwise idle box,
**5m14.614s** over 39 samples against **1m41.358s** over 25 (Δ 213.3 s ÷ 14),
gcc 12.2.0 both times. This is **Rule 1 applied to the corpus** rather than to the
pipeline: a differential covers what its input vector reaches, and a fixture whose
subject is the floor is evidence about the floor. It is a scope correction that
happens to cost less, not a cost cut — what F3 covers is unchanged, and E170's
W2–W4 fixtures land in the same directory at the same ~15 s each.

**The marker ASSERTS something, and F3 CHECKS it** — otherwise a fourth marker is
just a way to switch a test off and keep the green, which is the shape this page
already records three times. A `floor` row claims Phase 12 judges that sample, and
the claim is verified on every run **against the judge**:
`scaffold/tests/test-e168-floor.sh --list` makes that file's own
`verdict_ok`/`refuses` call sites print their fixture instead of running it, so a
fixture deleted or commented out there stops being listed by the same edit that
stops it running. Fail-closed: if the floor cannot be asked at all, every `floor`
row FAILS. Table totality is untouched — an untabled file is still a failure,
which is how E168 caught eight of them — and the dropped differential coverage is
visible per file in the table instead of implicit in a directory listing or a
sampling rule. **Mutants RUN 2026-08-26 and reverted, both caught in one leg run
(exit 1, 8 passed / 2 failed):** marking `e166_mach_c` — which the floor does not
judge — as `floor` gave *"e166_mach_c — tabled 'floor' (judged by Phase 12), but
test-e168-floor.sh --list does not name it"*; and commenting out the floor's own
`e170_suite_main` call site gave the identical failure on that row. Neither end of
the transfer can be removed quietly.

**What F3 deliberately does NOT cover, said rather than inferred from a count:**
those 17 fixtures' behaviour under the C toolchain. They are judged on one leg,
natively, by Phase 12 — which asserts their exit codes and, for the five
refusals, their diagnostics, an assertion F3's `refused` marker never made. ⚑ And
so **no row carries `refused` today**: those five refusal fixtures are floor
fixtures, their `refused` rows cost 17–20 s a run (resolve + one refusal compile
for the five measures 13.9 s; the branch does two), and the leg's own note says
that comparison **cannot fail** — both legs got the same blob, both front ends
came from the same pre-migration `scaffold/lib`, and every refusal happened at
LOAD, above both backends. (The C leg was DROPPED 2026-09-01 and Phase 12 is not
ported, so `scaffold/lib` has no successor to repoint at here: this sentence is
the record of what the leg's note said while the leg stood.) The branch stays for the day a sample is refused during *lowering*,
where the two backends genuinely differ, and is documented as unused.

**The honest limit: F3 does not subsume the per-arm gates.** A third mutant, also
run and reverted, dropped `m_div`'s Euclidean correction from the C runtime
shim. The shim's own gate (**51 hand-derived checks over `chirality-rt.c`**) caught
it, and G4 conviction caught it; **F3 did not** — no sample in the corpus divides
negatively. A behavioural differential covers the behaviour its corpus
*exercises*, and a corpus is not a specification. Keep the arm-level and shim
gates standing beside the differential: neither is a superset of the other, which
is §*The honest limit* below reaching one stage further down the pipeline.

## Expectation provenance — where an assertion's expected value comes from

Every assertion has a **source** for its expected value, and the source must be
**independent of the thing under test**. Sources are not equal. Ranked:

1. **External** — Rocq, CompCert. Independent authorship, independent toolchain,
   independent semantics. The strongest, and the only rank that survives a
   consistent miscompile in our own tree.
2. **Independent in-house reference** — `tal-eval`, `interp`, or a **fixed
   committed artifact** (a golden blob that predates the change). Same author, so
   correlated blind spots, but genuinely a second computation.
3. **The meaning of the form, hand-derived** — the expected value written down
   from what the program is *supposed to mean*, by hand, before running anything.
4. **Implementation-derived** (golden capture — record what the code does today
   and assert it keeps doing that). Permissible **only when labelled as a
   regression net**, never as a correctness claim. A golden capture of a wrong
   answer is a wrong answer with a test defending it.

A gate row must be able to name its rank. Rank 4 unlabelled is a finding.

### The run-the-mutant rule

A gate row must **name a mutant that falsifies it, and the mutant must be RUN** —
reverted afterwards, with its measured failure recorded. Naming a mutant is a
claim about the gate; running it is the evidence. The two come apart constantly,
and this session produced two near-misses that are the reason this is a rule and
not advice:

- **E156 G4.** The first fixture passed **14/14 with `list-sort` deleted from
  `row-of`.** Two independent causes: `irow` conses onto the front, so the input
  reversed into something *accidentally sorted*; and `row-join` de-duplicates its
  first argument only against its second, so the duplicate was eaten before it
  ever reached the function under test. The gate named the right mutant and would
  have shipped green without it. Lesson, stated so it cannot be softened:
  ***"byte-identical to the old implementation" is also what a fixture that
  exercises nothing achieves.***
- **E161 G0.** Making **both** providers emit the same wrong marker left the
  provider-vs-provider differential reporting **ok**. Only the gate's own
  expected blob — a rank-2 source outside both legs — caught it. Lesson: **a
  common-mode expectation is not an expectation.** This is Rule 1 above, met in
  the wild, one stage away from where the map predicts it (what that blob is, and
  what a new one must satisfy, is §*Rank 2's anchor* below).

**E166, as the rule followed rather than nearly missed.** Three mutants were run
against the C leg on 2026-08-24 and reverted, and all three results are recorded
because the third is the one that constrains the story. (a) Re-inverting
`mach-c.chiral:138` — F3 diverges on nearly every sample, while G2's exit-42
program still passes. (b) Adding `(import "mach-x64")` to blob A — G0b and G1
both fail with *"mc: extern does not lower: lambda stays upper"*, which is the
module graph refusing two `Mach` instances rather than a check over it. (c)
Dropping `m_div`'s Euclidean correction from the shim — caught by the shim gate
and by G4 conviction, **missed by F3**. A mutant a gate *misses* is as much a
measurement as one it catches, and it is the only kind that tells you where the
gate stops.

### Rank 2's anchor — what E161 G0's anchor actually was, and what a new one must be

⚑ *Corrected 2026-08-25.* This page called that anchor **"the fixed committed
blob"** for two sessions, and the phrase names nothing checkable: read literally
it is `scaffold/build/blob.chiral`, the compiler blob, which could not have been
the anchor and cannot be one. All of `scaffold/build/` is gitignored
(`.gitignore:8`; `git ls-files scaffold/build/` returns nothing), so it is not
**committed**; and the resolver re-derives it from `scaffold/lib/` — Phase 11's
negative control exists to re-resolve it and `cmp` the result
(`scaffold/tests/test-resolver-collision.sh:281-290`) — so it is not **fixed**
either. E161's own gate script says as much where it refuses to rest a row on the
promoted pair (`scaffold/tests/test-module-kind.sh:504-508`).

What actually convicted the mutant is the gate's **own expected blob**:
`want-lib.chiral` and `want-root.chiral`, two hand-written heredocs inside the
tracked gate script (`scaffold/tests/test-module-kind.sh:465-480` and `:490-499`)
that `blob_is` (`:195-207`) byte-compares against each provider's output. ⚑ That
script has **no successor in this tree**: Phase 8 is one of the five the
migration did not port, because every fixture declares an old-tree module
coordinate and the live key is the root-relative path
(`tools/test/MIGRATION-NOTES.md`, "Not ported"). The three citations above are
therefore left pointing at the pre-migration tree as the record of what convicted
the mutant, not repointed. Both providers were mutated; the expectation was not,
because it is text in a committed file rather than anything either leg emits.
**The history is unchanged and so is the rank:** a fixed expectation held
constant across two runs is what caught a defect a provider-vs-provider
differential could not see, which is rank 2 by its second clause — *a reference
outside BOTH legs*, the form the built floor records at
`lib/evidence/test-floor.chiral:56-58`. The rank-2 definition above is not
loosened to fit this instance; the instance was described wrongly.

**The admission test for a NEW anchor.** The old wording survived because it
named an artifact nobody had to point at. From here on an artifact minted as a
`pv-fixed` anchor must be, and a gate row citing one must be able to show, all
five of:

1. **committed in-repo** — tracked by git, matched by no `.gitignore` rule;
2. **not written by the build** — no build, promotion or resolve step regenerates
   it, so "fixed" is a property of the file rather than of the last run;
3. **its digest carried in chirality source** — the `(digest Bytes)` argument of
   `pv-fixed` filled with the artifact's real digest, not a placeholder. (An
   anchor small enough to sit inside the gate file, as G0's two are, is its own
   digest: `cmp` against the committed bytes *is* the check.)
4. **its minting oracle and date recorded** — what produced the expected value
   and when. Without that an anchor is a golden capture with better manners, i.e.
   rank 4 (`:174-177`), and it is admissible only under rank 4's label rule;
5. **small enough to review** — a reader can say what it means. Nobody can tell a
   wrong 660 KB anchor from a right one, which is the other reason the compiler
   blob is not a candidate.

E161 G0's pin meets 1, 2, 3 and 5 and predates 4; the 335 assertions that will
ask for anchors under E170 have to meet all five, and it is E170 that mints them.

### Why this is a design property and not a checklist item

**Expectation source is a parameter of the test, not a hardcoded assumption.**
If a test *declares* where its expected value comes from, swapping Python for
CompCert later is a **data change**. If the source is implicit — baked into the
assertion's shape, as it is across the differential corpus today — the swap is
**335 rewrites**. That bill is on the table right now, and it is on the table for
exactly this reason. E168 exists to make the source declared rather than implicit
*before* the migration, not after.

⚑ **E168 BUILT 2026-08-25**, so the sentences above are now carried by a type
rather than by this page. `scaffold/lib/test-floor.chiral` makes an `ExProv` a
constructor argument with no omitting arity, so an unlabelled expectation cannot
be written; a `Gate` takes a `MutRun`, which `mut-run` produces from two
programs it built and ran (⚑ *the arity makes the mutant claim unomittable, not
unforgeable — the constructors are public and a hand-written `MutRun` scores a
gate green, measured 2026-08-25; `test-floor.chiral` §7 states the gap*); and a
differential mints its `Expect` at the
weaker leg's provenance, so swapping a leg really is the data change claimed
above. All three shapes recorded here — the **two near-misses** above and
E166 G3, which was a mutant retired at design time rather than a near-miss —
have fixtures that go RED on the floor, in `scaffold/tests/run-native.sh` Phase
12: **E156 G4** as `e168_mut_survived`, **E161 G0** as `e168_rank_floor`,
**E166 G3** as `e168_mut_identical`. What is NOT done is the migration: the eleven phases E168
did not re-express still carry this page's rules by hand, and that is **E170**.

### The honest limit

An external reference supplies the expected **behaviour**. It cannot tell you the
test asked the right **question**. Expectation-correctness is mechanizable;
test-**adequacy** is not. Both E156 G4 and E161 G0 were adequacy failures with
perfectly sound expectations — which is why the mutant rule is separate from the
provenance rank, and why neither replaces the other.

### Orphaned rules — coverage a deletion takes with it, and how it is re-founded

Adequacy has a second failure mode the mutant rule does not reach, and it only
appears when a *floor* is retired rather than a gate: a rule whose only isolated
coverage lives inside the leg being deleted. Nothing is red before the deletion
and nothing is red after it — the rule simply stops being distinguishable from
its absence, which is the could-not-fail class one level up.

**Measured 2026-08-26 at `3c5d35c`** (`.planning/RUNG1-CHECKLIST.md`, the
judgment-rule coverage table): of the checker rules enumerated from `infer`'s 19
arms plus the named side-condition procedures, **three** have no isolated
coverage anywhere outside the 335-assertion differential leg E170 deletes —
`conv`'s **eta** rule, the **QTT semiring tables** (`qadd`/`qmul`/`qjoin`/
`qfits`), and **`base <: refine` only-if-TOP**. E170 D1 records that the `rocq/`
floor re-founds **zero** of the 335 today, so the deletion would have removed the
only thing that could tell those three from their absence.

**Re-founded 2026-08-26 on the E168 floor**, Phase 12, three fixtures and six
harness-run mutants (`e170_conv_eta`, `e170_qtt_semiring`, `e170_refine_top`).
Three properties of the shape are worth stating as contract, because each is a
way a re-founding fails silently:

- **Relational, not outcome-locking.** An outcome lock ("this term normalizes to
  that") encodes the intent exactly as faithfully as the oracle did, so rewriting
  it in chirality *moves* the tautology rather than breaking it. The three are a
  metamorphic law (a neutral converts with its eta-expansion and with nothing
  else), algebraic laws quantified over the whole of a closed sum, and a refusal
  quantified over a generated family.
- **Laws alone are not a re-founding, and this was measured rather than argued.**
  Reverting `qadd`'s `1+1` saturation to `(q1)` leaves the commutativity,
  associativity, identity, absorption, distribution and partial-order checks ALL
  GREEN — a wrong-but-consistent table satisfies them. Only the *pin*, which
  composes `qadd`/`qjoin` with `qfits` the way the checker's own accounting does,
  goes red. A law suite over a table needs at least one check that says what the
  table MEANS.
- **The falsifier is a library mutant, which `mut-run` cannot express.**
  `mut-run` observes the base by PATH and the mutant by self-contained TEXT, and
  breaking a checker rule is neither — it is an edit to the library the fixture
  resolves against. `test-e168-floor.sh`'s `mutant_red` is that shape: it edits a
  scratch copy of `scaffold/lib`, re-resolves, and asserts red for a named
  reason, plus that the mutation matched something, that the mutant still built,
  and that the fixture carries the written `MutRun` claim the mutation
  implements. **Isolation is established, not asserted:** a 6×3 matrix of every
  mutant against every fixture is a clean diagonal. ⚑ That script is Phase 12,
  one of the five the migration did **not** port
  (`tools/test/MIGRATION-NOTES.md`), so both `scaffold/` names above stand as the
  pre-migration record and neither is repointed. The *shape* survived:
  `tools/test/mutant.sh` is this tree's library-mutant harness — `mutant_build`
  (`:101`) copies `lib prog bin` into a scratch tree, mutates one named file
  under a declared anchor count, re-resolves and rebuilds, and `mutant_red`
  (`:133`) runs a chosen phase under the mutant. It carries the anchor-matched
  and still-built assertions; the `MutRun`-claim assertion has no counterpart,
  there being no fixture-side claim here to check against.

⚑ **B3 = 0 before this.** The corpus classification found no refusal-universality
test anywhere in the 709, so `e170_refine_top` is the tree's first. What such a
check has and an outcome lock does not is a way to pass vacuously — refuse
everything, or quantify over an empty family — so it ships with its controls as
separate expectations (the TOP refinement IS admitted; the family is non-TOP by
this file's *own* predicate and not by the function under test) and with a mutant
that reddens each.

### The generator — E170 lane D, 2026-08-29

Lane C re-founded three named rules. Lane D asks the next question: how much of
the corpus can be **generated** from the closed sums already in the tree instead
of migrated. `scaffold/tests/samples/e170_infer_arms.chiral` (Phase 12 row **D1**,
seven harness-run mutants) is that instrument — eight properties folded over
`(data Term)`'s 16 constructors, `Qty` × `Seat`, and a five-member want set, with
`ia-tag`'s exhaustive `case` making a new constructor a compile error rather than
a silent gap. It gives `infer-pi`, `infer-app`, `infer-ann` and the
`infer`→`check` boundary their first isolated coverage; all four were
*combination only* in every one of the three corpus buckets.

**Two results from it belong in the contract rather than in a commit message.**

- **Coherence is not correctness, and the fixture says so in its own header.**
  `assert_infer_agrees` compared against kernel.py — a second producer. What
  survives the oracle is infer-against-`check`: two paths through **one** rule
  set, which under E168's ranks is implementation-derived (rank 4) and cannot
  catch a rule wrong in a self-consistent way. A generator over the rule set can
  only ever establish that the rules agree with themselves.
- **A generated property does NOT subsume the outcome lock it looks like it
  replaces, and this is measured per rule.** Thirteen mutants of rules the corpus
  outcome-locks, run against the generator: **eight GREEN**. The reason is
  structural — a relational property over `infer` re-derives the arm's result on
  *both* sides of the relation, so a mutant that moves an arm's result moves the
  relation with it and the property stays green while a literal assertion
  reddens. **This is Lane C's `qadd` finding one level up:** laws alone re-founded
  nothing there; coherence alone subsumes nothing here. The per-rule matrix is
  `.planning/RUNG1-CHECKLIST.md`; exactly **one** of the 267 outcome locks is
  retirable on its evidence, and the deletion gate is still Lane C's.

### The port-type negatives — E170 lane E, 2026-08-29

Lanes C and D both establish **coherence**: that the implementation is faithful
to the rules and that the rules agree with themselves. Both measured, at their
own level, that a wrong-but-self-consistent rule survives — a `qadd` mutant left
every algebraic law green, and eight of thirteen rule mutants left the generated
relational suite green. Lane E is the one instrument in the arc pointed at that
gap, because a **port type is a claim about the world** rather than a claim
inside the rule set.

**Its operational test, and the shape it puts on the floor.** A port type carries
meaning *iff there exists a wrong implementation satisfying its shape that the
type rejects* — mutation testing with the type as the test and the implementation
as the mutant. Phase 12 rows **E1–E10**: six refusals, each a **minimal pair**
against a compiling twin in `e170_port_twin.chiral` (in three of them the whole
difference is one identifier or one literal, which is what makes the wrongness
semantic rather than structural); a refusal quantified over the porttype family
**read off the tree** by grep, so an eleventh porttype joins it with no edit
(E8/E9, and E9 is the direction control without which a checker that refused
everything would score E8 green); and an enumeration guard (E10) that reddens
when the port surface moves.

**Three results belong in the contract.**

- **The zeros are the deliverable, and they are committed as ASSERTIONS.**
  `e170_port_zeros.chiral` holds six semantically wrong implementations the port
  types **accept**, and Phase 12 asserts that they compile. A zero written as a
  note rots; a zero written as a row goes red the day the type gets strong enough
  to refuse it, and forces the map to be re-measured. The widest of the six: **no
  port type in the tree says anything about what a crossing DOES** — a
  `sock-send` stand-in with the crossing's exact type that reports success and
  sends nothing typechecks. Port types govern custody of the authority, not the
  effect.
- **Custody is ONE mechanism, not ten answers.** Every porttype is an opaque
  linear atom, so every one refuses a dropped or duplicated capability for the
  same reason — which is why the per-port question collapses to *what else does
  this port's type carry*, and only three ports answer: `Sock`'s refinement on
  `sock-recv`'s length, `Pool`'s value index, `Secret`'s nominal identity.
- **Reachability is a column, not a footnote.** `Clock` and `Timer` are
  **uninhabited** — no extern returns either and a porttype has no constructor —
  so their refusals are quantified over an empty set of callers. Scoring them
  "meaning" without saying so would be this floor's own gate-that-cannot-fail.

The per-port map, its facets, and the falsification of each guard are
`.planning/RUNG1-CHECKLIST.md` §Lane E. Cost: Phase 12 41.786 s → ~66 s.

## The discipline that retires Python (do this on every change)

**Every new chirality/scriba feature ships with the floor that covers it:**

1. **Behavioral feature** (a scriba band, a pty probe, term-raw; codegen; a new
   syscall crossing) → add a **native-behavioral sample**: a program whose exit
   code encodes the expected result, wired into `tools/test/run-tests.sh` Phase 1
   inline, or into a phase script under `tools/test/` with its fixtures in
   `tools/test/samples/`. This is the gate for the work. ⚑ *Until 2026-09-04 this
   step named `scaffold/tests/run-native.sh` and `scaffold/samples/`, both gone in
   the 2026-08-31 migration. Phase 2 walks a six-sample manifest bundled inside
   `prog/test-runner.prog` rather than a directory, so dropping a file into
   `tools/test/samples/` reaches no phase by itself: BA-32 measures 47 of the 56
   entries there as referenced by no script.*

2. **Semantic property** (an arithmetic law, refinement soundness, a type-checker
   invariant) → ⚑ **this step has had no floor since 2026-09-01.** It read: add a
   rocq obligation, a `Lemma … . Proof. Admitted. (* HAMMER:<name> *)` in the
   matching `rocq/Chirality/*Spec.v` faithful to the chirality source it mirrors,
   let the hammer loop close it, and record the obligation-to-test mapping in
   `rocq/HAMMER-MANIFEST.md`. Both paths went with the floor. The live substitute
   is a fixture on the E168 test floor (`lib/evidence/test-floor.chiral`) carrying
   its own provenance rank and a run mutant, which is rank 2 or 3 where the
   obligation was rank 1. That drop is the cut's real cost and it is stated here
   rather than absorbed.

3. ⚑ **Retired 2026-09-04, and done rather than owed.** It read: whatever the new
   floors cover, drop from Python. Never port Python test *code* to Coq. Mine it
   for the *property* and re-state that about chirality. The oracle was cut whole on 2026-09-01 instead of
   drained feature by feature, so nothing remains to drop. `ledger-lint` check O
   keeps the accounting over `.planning/RUNG1-CHECKLIST.md`'s C-inventory and
   reports 0 issues.

⚑ *The sentence this section closed on, "coverage moves with each feature; the
uncovered surface shrinks monotonically; zero Python arrives without a
stop-the-world rewrite", described a migration that ended by decision instead.
[[arcs/zero-python-arc]] holds the residue and its own measured count.*

### Scope lives next door, and this note does not restate it

This note is the **discipline** — how each piece of coverage migrates, and which
floor gates. **What is in scope** is a separate, enumerated question, and its
authority is
[`.planning/RUNG1-CHECKLIST.md`](../../.planning/RUNG1-CHECKLIST.md)'s **Phase C
§C-inventory**: every `.py` in the tree, classified IN-SCOPE (with the C-row
that owns it), JUDGMENT, or the dated OUT-OF-SCOPE authoring harness — with
`ledger-lint` **check O** failing on any file that matches none of the three.

The split matters because the two questions rot differently. Discipline rots
when a feature ships without its floor; scope rots the moment a `.py` lands.
Keeping the file list here would put an inventory inside a contract and give the
lint row two masters. **"Zero python" means the C-inventory's IN-SCOPE tables
are empty — not "no `.py` under `find`."** The authoring tooling that pipelines
an AI session is not chirality and never was in rung-1 scope; that boundary is
stated and dated there, once.

## Triage buckets (for retiring an existing Python test)

⚑ **Historical since 2026-09-01. No test remains to triage** and the `prove`
bucket's destination is gone with `rocq/`. Kept because the three-way split is
the shape the next floor retirement should reach for.

- **delete** — tests the Python floor's internals, or is subsumed by the
  fixpoint. No replacement needed.
- **sample** — behavioral: re-express as a native-behavioral sample (floor 1).
- **prove** — a semantic property only a proof settles universally: a rocq
  obligation (floor 2).
