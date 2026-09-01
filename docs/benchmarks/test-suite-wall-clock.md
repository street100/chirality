---
node: benchmarks-test-suite-wall-clock
layer: benchmark
status: measured
updated: 2026-09-01
---

# The native suite's wall clock

`docs/definitions/testing-floors.md` named `.planning/BUILD-ORDER.md` as the
owner of this figure. `.gitignore:12` excludes `.planning/`, so the tree's
contract for its primary correctness gate cited a document a fresh clone does not
have. That is the reason this file exists.

⚑ **Every measurement below was taken before the 2026-08-31 migration**, against
`scaffold/tests/run-native.sh` and a `scaffold/lib/` that no longer exist at
those paths. The numbers are kept because they are the only measured figures the
suite has, and because what they retire matters more than what they assert. They
are **not** a baseline for the current tree. A re-measure has to be run before
any of them is quoted as current, and it has to follow the method in the last
section.

## There was never a ~4-minute budget

⚑ **THERE IS NO ~4-MINUTE BUDGET, AND THERE NEVER WAS ONE.** The figure was
asserted in conversation on 2026-08-25, propagated into three rows across the
ledger, the catalog and a handoff as a threshold the suite "is supposed to hold",
and was never measured against anything. Nothing in the tree enforced it, no run
established it, and it was invented twice: once as the budget and once as the
finding that the budget was breached.

It is retired. The replacement is **a range with its variance named**, never
another threshold. A number a run can be compared against has to come from runs.

## The range, and why it is a range

**The figure to quote is `5m07s–5m36s` on that host**, over seven runs. Five on
2026-08-25 at `8db4af0` clustered inside 4.9 s ≈ 1.5 %; two more at `568699e`,
serial on an otherwise idle box, ran 5m07.711s and 5m36.444s. Each of the seven
reported 163 `ok`, 0 FAIL, 82 roots, exit 0.

⚑ **That 1.5 % was a property of those five runs, not of the suite.** Two
back-to-back runs differ by 28.7 s ≈ 9.3 %. One phase moved further than the
whole published spread: the module-datasheet phase does identical work every time
(44 assertions in both runs, 1.2 s of its 35 s off-CPU, so nothing about it
should be load-sensitive) and measured **23.15 s** inside one run against
**35.04 s** inside the next, with three standalone readings at 34.7–35.5 s. Five
of six cluster; the 23.15 s is **not explained**, and is left unexplained rather
than guessed.

A suite whose fixed-work phase varies 1.5× on the same box in the same hour does
not have a ±1.5 % wall clock. The range is all these numbers license.

## Where the time went

One instrumented run at `568699e`, 5m36.444s total = `user` 2m41.699s + `sys`
1m33.415s + 1m21.3 s off-CPU. Eleven phases.

**Two phases were 75.5 % of the suite.** Downstream-roots-compile at 151.37 s
(45.0 %) and the external-compiler leg at 102.51 s (30.5 %). Everything else
together was 82 s.

⚑ **The dominant phase was not a compile cost. It was the shell resolver.**
Timing its two legs separately over 88 roots and 2,017 module resolutions:

| leg | time | share |
|---|---|---|
| the **shell** source provider | 118.556s | 81.9 % |
| the compiler, actually compiling 88 blobs | 22.305s | 15.4 % |
| the loop itself | ~3.9s | 2.7 % |

The provider forked ~7 external processes per module per root. Resolving one
large root's 53 modules cost `real 3.367s`; the same 53 files read by bash with
no fork at all cost **0.028s**, a **120× ratio**. That is also where the off-CPU
time was: 51.5 s of the suite's 81.3 off-CPU seconds were process creation and
image lookup in this one phase, not the compiler waiting on anything. **~35 % of
the whole suite's wall clock was bash spawning helpers.**

The native provider that replaces it already exists in chirality, so this is an
observation about the shell leg and not a missing capability.

⚑ The C leg's cost was the behavioural differential (64.61 s over 25 samples) and
the C compile (25.01 s for 2,171,314 B), not the gate. The ddc gate's growth from
13 to 36 cases, a named suspect, cost **0.23 s** and was not a suspect at all.

## Two figures that were falsified, without a bisect

Two wall clocks for the same commit and the same 163 assertions, written the same
day, disagreed with each other by 43 s. Both are **FALSIFIED**, and no historical
run was needed: both are below the measured cost of phases whose workload that
commit and HEAD shared exactly. 163 `ok` also *requires* the C leg, so a run
reporting it ran the differential and the C compile. That leaves 172 s to cover a
118.6 s fork-bound resolver plus a 35 s phase plus a 25 s C compile — 179 s before
counting eight other phases.

A historical run was **not attempted and would not have settled it**: the build
directory was gitignored, so a worktree at that revision has no compiler, and a
run there would be that tree's tests against *this* tree's binary. That is a
comparison across two binaries, which is not a comparison.

⚑ **What those two figures were taken over is still unknown**, and is left that
way.

## The method, which is the durable part

**Compare a phase only against the same phase measured over the SAME WORKLOAD,
and take the workload count from `git ls-tree`, not from a document.**

This was established by falsifying its own inference. One wave read the C leg at
6m0.541s, re-ran "the unchanged pre-W0 tree" at 4m18.478s against a recorded
2m21s, and concluded *"the machine is ~1.8× slower today"*. The two sides were
not the same workload: every baseline figure was taken when the differential
swept **25** samples, and the tree it was compared against had **36**, then
**39**.

Two back-to-back runs on an idle box, same binary, same C compiler, differing
only in the sweep:

| sweep | `real` | `user` | `sys` |
|---|---|---|---|
| 39 samples | 5m14.614s | 4m13.359s | 0m30.355s |
| 25 samples | 1m41.358s | 1m12.555s | 0m12.747s |

The 25-sample run reproduces the recorded 1m41.6s / 1m41.2s and sits inside the
recorded band. The arithmetic closes from the other side too: 101.4 s + 11 extra
fixtures × 15.2 s ≈ 4m29s against the 4m18.478s measured. **The corpus grew; the
box did not slow down**, and no machine-speed term is needed to account for a
second of it.

A suite wall clock is not comparable across revisions that touched the sample
corpus.

⚑ **Do not read a large total-to-total drop as one change's effect.** Where a
drop was attributed to a change, 213.3 s of it was the sweep and was measured
directly, back-to-back; the rest was the run-to-run spread this page documents.
Where a change's cost was wanted, the phase was run alone on either side of it
(23.555 s → 41.786 s) rather than inferred from a suite total that moved the
other way inside its own spread.

## The toolchain the figures were taken on

⚑ **It is not the one the sequencing document claimed.** `/opt/compcert` did not
exist in the container (checked 2026-08-26), so the C leg's preference order fell
through to **gcc 12.2.0**, and every figure in this file is a gcc figure. The
fallback was **reported and not silent** — the leg prints its chosen compiler on
every run, which is how it was noticed. The claim that the leg defaults to
CompCert was a claim about a machine state that did not survive, and `/opt` is
not on the workspace bind mount.

Read a run's provenance off its banner, never off a page.

⚑ **Never distribute a CompCert-built artifact.** INRIA's licence restricts *use*
and carries no output restriction; a one-off comparison is evaluation, and the
leg discards every artifact it builds on exit.

**How `ccomp 3.17` was obtained, and do not reach for opam.** Debian ships no
`compcert` package in any suite and does not need to: CompCert bundles Flocq and
MenhirLib, and every other prerequisite is in bookworm `main`. opam is the one
route that exhausted this box's fd table, twice.

```
apt-get install -y --no-install-recommends coq menhir ocaml-findlib libmenhir-ocaml-dev
curl -sSL -o v3.17.tar.gz https://github.com/AbsInt/CompCert/archive/refs/tags/v3.17.tar.gz
./configure x86_64-linux -prefix /opt/compcert && make -j2 all && make install
```

`make -j2 all` re-checks 259 Coq proof files then runs OCaml extraction. It
returned RC=0 with a floor of 1,369,324 kB `MemAvailable`, in about 20 minutes
unattended. [[banks/verification]] carries the build-state fact
(*"`ccomp 3.17` is built and working … with no `opam` involved"*); the recipe is
here because that is where the measurement needs it, and because `/opt` is not on
the workspace bind mount, so the install does not survive a container rebuild.

## One defect this measurement found

An environment override selecting which compiler the suite runs under was
honoured by the driver's inline phases only. Five sub-scripts re-derived the
binary path and ignored it, and two more went through a front door with its own
resolution. So an admission run claiming to exercise 135 assertions under the
C-built compiler had **6** genuine and **129** not.

All seven now resolve the override first, and `ledger-lint` **check P** fails any
suite script that names the build path without consulting it, so the convention
cannot rot back one new test script at a time — which is how it got there.
Re-run under a total override: 154 `ok`, 0 FAIL, exit 0, with 148 assertions that
had never once run under the C-built compiler, none divergent.
