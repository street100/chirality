---
node: benchmarks-text-matcher-prose-lint
layer: benchmark
status: measured
updated: 2026-09-02
---

# The native prose-lint against awk

`prog/prose-lint.prog` runs E173's partial-derivative matcher
(`lib/text/matcher.chiral`). `tools/prose-lint/prose-lint.sh` runs mawk. The two
agree on eight checks over the corpus, which E173's G9 row gates. This file
carries what G9 leaves out: the wall clock, and the memory.

⚑ **The native tool is 15x slower than awk on the corpus and it cannot finish
the tree's default scope at all.** It gets OOM-killed there. Both figures are
below with their method. The author's ruling on 2026-09-01 was to record the
wall clock rather than gate on it, so a bad number lands here instead of
blocking the element.

## Host, date, load

| | |
|---|---|
| host | `claude-sandbox`, rootless podman + libkrun microVM on the redrix laptop |
| kernel | Linux 6.12.91 x86-64 |
| cpu | Intel Xeon, 12 vCPU, 2496 MHz reported |
| memory | `MemTotal` 4,033,056 kB. `SwapTotal` **0** |
| date | 2026-09-02, tree at `339be61` |
| compiler | `bin/chirality-bin`, sha256 `ac8de63e5687fad4…` |
| awk | mawk 1.3.4 20200120, which `/usr/bin/awk` resolves to |
| load | `/proc/loadavg` read 0.26 before the runs and 0.33 after. Nothing else ran |

⚑ **One of the runs below is itself an OOM kill, and this session was warned
that agents have been OOM-killed on this box today.** 3.85 GB with zero swap makes every timing here noisy at
the tail and makes any memory figure a hard ceiling rather than a soft cost. Read
the bands. One sample proves nothing here.

## Method

- **min-of-N**, N=11 on the corpus and N=7 on the default scope. The min is the
  quietest sample the box gave, and the max beside it is the noise.
- The native side is the built ELF reading the path list on stdin. The awk side
  is `prose-lint --summary` over the same three directories. The two alternate,
  back to back, same shell, one sitting.
- **The awk side is `prose-lint --summary`.** BA-40: the shell tool carries two
  divergent check sets, and `cmd_lines` (`tools/prose-lint/prose-lint.sh:164`)
  is a hand-merged alternation missing `parallel-no` and four other branches.
  Timing against that form would compare against a reporter defect.
- The compile is excluded from the run figures and measured separately below.
- Peak memory is cgroup v2 `memory.peak`, one fresh cgroup per subject, capped
  at 2 GB so an overrun is a recorded `oom_kill` rather than a dead session.

```
for d in docs/arcs docs/decisions docs/definitions; do find $d -type f -name '*.md'; done > corpus.list
time ( ulimit -s unlimited; ./lint.elf < corpus.list >/dev/null )
time ( tools/prose-lint/prose-lint.sh --summary docs/arcs docs/decisions docs/definitions >/dev/null )
```

## The corpus

`docs/arcs`, `docs/decisions`, `docs/definitions`: **81 files, 609,872 bytes,
10,122 lines**. G9 in `docs/elements/specs/E173-total-matcher-SPEC.md` says 80.
One file has landed since. The added file scores zero on all eight, so the
totals both tools report are the SPEC's: em-dash 906, antithesis 392,
copula-negation 159, parallel-no 8, and zero for the other four. The differential
was re-run at `339be61` before the timing and it still agrees exactly.

The **default scope** is the second corpus: `docs`, `.planning`,
`.claude/skills` and the root `*.md`, being **544 files, 8,130,791 bytes**. It is
the scope whose size the 2.4x note gives as ~7 MB. The corpus has grown since.

## Wall clock, 81 files

Three subjects. `real` seconds, all eleven samples, sorted.

| subject | min | median | max |
|---|---|---|---|
| awk `--summary`, 10 checks | **0.097** | 0.107 | 0.188 |
| pre-E173 `prose-lint.prog`, 6 checks | **0.102** | 0.121 | 0.137 |
| post-E173 `prose-lint.prog`, 8 checks | **1.468** | 1.560 | 1.797 |

```
awk       0.097 0.098 0.105 0.105 0.106 0.107 0.107 0.108 0.122 0.181 0.188
pre-E173  0.102 0.109 0.110 0.114 0.114 0.121 0.122 0.126 0.128 0.129 0.137
post-E173 1.468 1.477 1.484 1.501 1.535 1.560 1.569 1.588 1.593 1.641 1.797
```

**The ratio is 15.1x, min against min.** Taking the two spreads at their
extremes the band is **7.8x to 18.5x**, and the honest reading is that the awk
side's tail (0.181 and 0.188 on two of eleven) is the box, while the native
side's whole distribution sits an order of magnitude above it. The medians give
14.6x and the user-time columns give 1.114 to 1.269 s against 0.041 to 0.061 s,
which is ~20x of CPU with no I/O term in it.

**The old 2.4x is beaten in the wrong direction, by a factor of six.**

## Memory, and the run that died

| subject | peak RSS, 81 files | peak RSS, default scope |
|---|---|---|
| awk `--summary` | 8,499,200 B | 17,612,800 B |
| pre-E173 `prose-lint.prog` | 4,112,384 B | completes |
| post-E173 `prose-lint.prog` | **1,111,769,088 B** | **OOM-killed, rc 137** |

⚑ **The post-E173 tool allocates 1.11 GB to scan 610 KB.** That is 131x what
mawk needs and 270x what its own predecessor needs. It is linear in input bytes
and nothing is released:

| files | input bytes | peak RSS | bytes of arena per input byte |
|---|---|---|---|
| 20 | 150,774 | 309,862,400 | 2,055 |
| 40 | 275,969 | 522,854,400 | 1,895 |
| 60 | 368,212 | 677,085,184 | 1,839 |
| 81 | 609,872 | 1,111,719,936 | 1,823 |

Fitting the first row against the last gives **1,747 B of arena per input byte,
over a floor near 46 MB**. Projected onto the 8,130,791-byte default scope that
is ~14.3 GB on a 3.85 GB box with no swap, so the kill is arithmetic. Confirmed
under a 2 GB cgroup: `rc=137`, `peak=1999998976`, `memory.events` reporting
`oom 1` and `oom_kill 1`. Seven unbounded attempts died the same way after 4.8
to 6.3 s.

**The tool's documented invocation cannot be run in this container.**
`prog/prose-lint.prog:7` shows `find docs .planning | chirality run
prog/prose-lint.prog`, and that command OOMs here.

## The two tools do unequal work

| tool | checks counted | checks named as absent | fence and span filter |
|---|---|---|---|
| `tools/prose-lint/prose-lint.sh` `_scan` (`:95-104`) | 10 | 0 | yes |
| `prog/prose-lint.prog` | 8 | 2, printed as NOT-CHECKED (`:254-255`) | yes |
| pre-E173 `prose-lint.prog` at `87f1e2a` | 6 | 3, printed as NOT-CHECKED | no |

`self-reference` and `first-person` are the two the native tool prints rather
than drops, which is the silent-vanish rule its own comment at `:244-248` holds
it to. **Correcting for the gap makes the native side look worse.** Per check on
this corpus the native tool spends 0.1835 s and mawk spends 0.0097 s, a ratio of
**18.9x**.

The pre-E173 row is a third workload again: six checks and no code filter at
all. Its 0.102 s is therefore a floor and its comparison against awk is loose in
its own favour.

## Why: the tool is still eight passes

E173's one pass is **per pattern**. `find-all` walks the buffer once for one
`Pat`. The tool did not fold its checks into one alternation:
`prog/prose-lint.prog:207-214` calls `count-pat` eight times over the same kept
lines, once per check. mawk's `_scan` does ten `gsub` per line for the same
reason.

So the pass count fell from **31 to 8**, and the wall clock rose 14x against the
same program's predecessor. The 31 is the one figure in that note that
reproduces exactly: `87f1e2a:prog/prose-lint.prog` holds 30 literal needles
across five `(List Str)` constants, plus the em-dash counted on its own, and
`sum-lit` and `sum-lc` walk the whole body once per needle. The cost moved out of the pass count and into the
per-byte derivative: `pd` builds a fresh `(List Pat)` per live thread per byte,
`norm` rebuilds the live set every step, and the arena never gives any of it
back. `.planning/PRIMITIVES-FOR-NATIVE-TOOLS.md:85-87` reads
`The algorithm is the cost, not the compiled code`, and on this measurement the
constant factor of the better algorithm is larger than the pass count it
removed.

## Compile cost, excluded above

`chirality run` pays this on every invocation. Three samples, min taken.

| leg | min real |
|---|---|
| `chirality_blob_file "lib:prog" prog/prose-lint.prog` | 1.188 s |
| `bin/chirality-bin` over the 806,129-byte blob | 0.768 s |
| total per `chirality run` | **~1.96 s** |

Against a 0.097 s awk run, an honest end-to-end figure for the documented
invocation is ~35x on the corpus, and undefined on the default scope because it
does not finish.

## Honest limits

- **The 2.4x has no surviving harness.** `.planning/PRIMITIVES-FOR-NATIVE-TOOLS.md:86`
  states it with no corpus, host, date, N or invocation. The
  before-and-after in the table above was taken the same way on both sides,
  because the pre-E173 program was rebuilt from `87f1e2a` against today's `lib/`
  and run under today's harness. It still does not reproduce the run that
  produced 2.4x, and nothing in this tree can.
- **2.4x does not reproduce here at all.** On the default scope, which is the
  corpus that figure names, the pre-E173 program measures 1.274 to 1.399 s
  against awk's 1.198 to 1.438 s. That is **1.06x**, parity, on six checks
  against ten. Whatever 2.4x measured, this box under this method gives a
  different answer.
- **Three workloads, one table.** 10 checks with a filter, 8 with a filter, 6
  with none. Every ratio here carries that.
- **Peak RSS is one run per subject.** No repeats, so it has no band.
- **The split inside the 1.468 s has no measurement.** How much belongs to `pd`
  and `norm` and how much to `keep-lines` and `blank-spans` would need an
  instrumented build, and none was made.
- **This is one host.** Absolute timings do not travel, per the README's first
  convention.

## What this licenses

A bar can now be set, which is what the ruling deferred it for. Nothing sets one
here.

The residue is real and has no element. `docs/elements/specs/E173-total-matcher-SPEC.md`
§6 already names a byte-set `Cls` over a 256-bit bitmap as *"a pure speedup that
changes no arm of `pd`"*, homed in `lib/text/matcher.chiral` "when a measurement
asks". This is that measurement. The allocation profile is the larger finding and
it belongs beside it.

⚑ **Both are `UNASSIGNED`.** `docs/arcs/text-tools-arc.md` holds no reserved
element block, `docs/decisions/decision-lane-split.md` reserves `E184-E189` and
`E190-E195` for other lanes, and the block is an open row in
`records/author-calls.md`. Per the deferral rule in
`docs/definitions/working-discipline.md`, naming a number here would be a phantom
dependency.

## Re-running this

```
. bin/chirality-resolve.sh
chirality_blob_file "$PWD/lib:$PWD/prog" prog/prose-lint.prog > lint.blob
( ulimit -s unlimited; bin/chirality-bin < lint.blob > lint.elf ) && chmod +x lint.elf
for d in docs/arcs docs/decisions docs/definitions; do find $d -type f -name '*.md'; done > corpus.list
TIMEFORMAT='%3R %3U %3S'
for i in $(seq 1 11); do time ( ulimit -s unlimited; ./lint.elf < corpus.list >/dev/null ); done
for i in $(seq 1 11); do time ( tools/prose-lint/prose-lint.sh --summary docs/arcs docs/decisions docs/definitions >/dev/null ); done
```

Bound the memory before pointing it at anything larger:

```
mkdir -p /sys/fs/cgroup/probe && echo 2000000000 > /sys/fs/cgroup/probe/memory.max
( echo $BASHPID > /sys/fs/cgroup/probe/cgroup.procs; ulimit -s unlimited; exec ./lint.elf < corpus.list >/dev/null )
cat /sys/fs/cgroup/probe/memory.peak
```

The pre-E173 side is `git show 87f1e2a:prog/prose-lint.prog`, which still builds
against the current `lib/` unmodified.
