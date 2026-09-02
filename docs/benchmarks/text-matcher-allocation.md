---
node: benchmarks-text-matcher-allocation
layer: benchmark
status: measured
updated: 2026-09-02
---

# Where prose-lint's 1.11 GB goes

`docs/benchmarks/text-matcher-prose-lint.md` measured `prog/prose-lint.prog`
allocating 1,111,703,552 B to scan 609,872 B, fitted the growth at ~1,747 B of
arena per input byte, and closed with the line *"The split inside the 1.468 s
has no measurement."* This file measures the split for the **memory** half. The
wall clock's split stays unmeasured and is named as such below.

**Headline: the matcher takes 86.8% of it, the line machinery 6.8%, and
`str-split` 6.3%.** Inside the matcher's share the cost is the driver's
per-offset allocation rather than `pd` or `norm`: three heap cells that
`scan-go` builds at every offset for every pattern account for 77% of the
per-byte floor, and the arena never gives any of them back. The live set the
algorithm actually holds peaks at **8 threads** over the whole corpus.

## Host, date, rig

| | |
|---|---|
| host | `claude-sandbox`, rootless podman + libkrun microVM, 12 vCPU |
| memory | `MemTotal` 4,033,056 kB, `SwapTotal` **0** |
| date | 2026-09-02, tree at `c23947e` |
| compiler | `bin/chirality-bin`, sha256 `ac8de63e5687fad4…` |
| load | `/proc/loadavg` 0.15 at the start |
| corpus | `docs/arcs`, `docs/decisions`, `docs/definitions`: **81 files, 609,872 B**, 10,203 `str-split` pieces |
| kept bytes | **597,506** survive the fence filter, over 1,448 lines carrying a backtick |

The 10,203 pieces against the 10,122 lines the earlier file reports is one
trailing empty piece per file, since every file ends in a newline.

Every subject is a separate build of a scratch copy of `prog/prose-lint.prog`
with one stage of the pipeline removed or one check kept. `lib/` is copied to
scratch and mutated there, the way `tools/test/render-doc.sh:131-145` builds
`mutlib`. **Nothing under `lib/` or `prog/` in the tree was touched.**

Each run gets a fresh cgroup v2 with `memory.max` at 2 GB, `ulimit -s
unlimited`, and reports `memory.peak` with `memory.events`. Every figure below
is min-of-N with N at least 3; the observed spread is under 0.4% on every
subject.

## Why `memory.peak` is the right instrument here

The runtime is a bump allocator with **no reclamation anywhere**. `x-galo`
(`lib/lowering/x64/mach.chiral:509`) advances `heapptr` by `sz = 8 * (1 +
fields)` and stores; the only other motion is `nb-arena-grow`
(`lib/lowering/tal/sys.chiral:174`) doubling the committed prefix of a 64 GiB
`PROT_NONE` reservation from a 262,144 B floor
(`lib/lowering/compile-emit.chiral:49-50`). Nothing on any path a compiled
program takes ever frees, drops a region, or collects. **Peak RSS is therefore
total bytes ever allocated**, and a difference between two builds is the
allocation one of them does.

That 262,144 B floor is the measured floor: an empty loop over a 12,800 B buffer
reports `peak=262144` exactly.

Cross-check on the instrument. `str-split`'s payload can be predicted from the
corpus by arithmetic (below). The prediction is 69,353,244 B and the measured
delta is 70,074,368 B, **1.0% apart**. The residue is the cell headers the
arithmetic omits.

## The ladder: one stage added per build

Each row runs everything above it. 81 files, 609,872 B.

| rung | what the build adds | peak B | delta B | B per input byte | share of the delta |
|---|---|---|---|---|---|
| read | `read-fd-all`, `str-len` on the body | 3,907,584 | | | |
| split | `str-split "\n"` | 73,981,952 | 70,074,368 | 114.9 | **6.3%** |
| fence | `line-step`, `line-is-fence`, `keep-lines` | 74,498,048 | 516,096 | 0.8 | **0.05%** |
| blank | `blank-spans` on the 1,448 backticked lines | 150,167,552 | 75,669,504 | 124.1 | **6.8%** |
| match | the eight `count-pat` calls | 1,111,691,264 | 961,523,712 | 1,576.6 | **86.8%** |

⚑ **The prior that the fence filter and `str-split` dominate is refuted.** They
are 13.1% of the arena between them, and the fence filter proper is 0.05%. The
whole of the line machinery's cost is `blank-spans`.

The same ladder at 20 files (150,774 B) shifts the shares and keeps the ranking:
read 1,294,336, split 12,652,544, fence 12,886,016, blank 72,335,360, match
309,846,016. Matching is 76.7% there, `blank-spans` 19.2%, `str-split` 3.7%. The
matcher's per-byte rate is flat across the two corpora at 1,575 and 1,577 B,
because it is linear in bytes times patterns. The two others are quadratic per
unit and their share follows the file mix.

## The matcher's 961 MB, per check

Eight builds, each keeping one check. The base is the `blank` rung at
150,167,552.

| check | peak B | delta B | B per kept byte |
|---|---|---|---|
| `em-dash` | 220,938,240 | 70,770,688 | 118.4 |
| `connective` | 230,248,448 | 80,080,896 | 134.0 |
| `antithesis` | 234,708,992 | 84,541,440 | 141.5 |
| `not-but` | 238,997,504 | 88,829,952 | 148.7 |
| `parallel-no` | 261,980,160 | 111,812,608 | 187.1 |
| `throat-clearing` | 301,772,800 | 151,605,248 | 253.7 |
| `copula-negation` | 321,548,288 | 171,380,736 | 286.8 |
| `slop-word` | 367,165,440 | 216,997,888 | 363.2 |
| **sum of the eight** | | 976,019,456 | 1,633.5 |
| **all eight in one run** | 1,111,691,264 | 961,523,712 | 1,609.2 |

The sum overshoots the single run by 1.5%, which stays unattributed.

**`em-dash` is a three-byte literal that dies at its first byte on almost every
offset, and it still costs 118.4 B per kept byte.** That is the floor. The
spread from 118 to 363 is pattern size; the floor is the driver.

## The floor, one cell at a time

A ladder of six builds, each adding one construct to a bare loop over one
128,000 B buffer, measured against the same build over 12,800 B so the
difference is the per-byte cost. `p-lit "zqx"` throughout.

| build | body | B per input byte | delta |
|---|---|---|---|
| w0 | the loop, no allocation | 2.06 | |
| w1 | `+ (win (at-byte …) (at-byte …))` | 27.20 | **+25.1** |
| w2 | `+ (th i p)` | 65.99 | **+38.8** |
| w3 | `+ (cons … nil)` | 97.85 | **+31.9** |
| w6 | `+ (step-set k b ts)` | 116.16 | **+18.3** |
| w5 | `+ (norm …)` | 125.16 | **+9.0** |

`count-matches` over the same pattern on 64-byte lines measures 118.3 B per
byte, so the ladder accounts for the floor.

`scan-go` (`lib/text/matcher.chiral:396`) allocates the `Win`, the `Thread` and
the `cons` at **every offset, unconditionally, whatever the pattern does**. At
`8 * (1 + 2)` bytes each those three are 72 B of the 125 B floor by the cell
formula and 96 B by the ladder. **77% of the per-byte floor is three cells that
have nothing to do with matching**, and the tool pays it eight times over.

## The live set, which is the point

A probe built from `tools/test/samples/e173_matcher.prog`'s `mx-go`, run over
the same kept lines, reporting the largest `|ts|` the driver ever holds:

| pattern | max live threads |
|---|---|
| all eight as one alternation | **8** |
| `slop-word` | 4 |
| `em-dash` | 2 |

`norm`'s Antimirov bound holds exactly as `lib/text/matcher.chiral:271-286`
claims. Eight threads and their conses are about 400 B. The program allocates
961,523,712 B and holds 400 B of it. **Every byte the matcher allocates is dead
by the next offset, and the arena keeps all of it.**

## Hypotheses refuted

Each was tested by building a mutated `lib/` and re-measuring, on 64-byte lines
where the stack term is negligible. Slope is B per input byte.

| mutation | `p-lit` | `p-cls` | `pat-not-but` | `p-star` |
|---|---|---|---|---|
| baseline | 118.3 | 320.9 | 191.1 | 511.9 |
| `norm` replaced by the identity | 109.2 | 293.5 | 177.4 | **609.8** |
| `list-sort` dropped, `list-dedup-adj` kept | 118.3 | 320.8 | 191.1 | 518.8 |
| `pd-cat` collapsing `p-nil` into `r` | 118.3 | 320.8 | 188.8 | 466.4 |

- **`norm` is refuted as the cost.** Deleting it entirely buys 8%, 9% and 7% on
  the three bounded patterns and **loses 19%** on the star, where the live set
  stops being bounded. The merge sort inside it is free at these set sizes:
  dropping `list-sort` and keeping the dedup changes the figure by 0.0%.
- **`pd-cat` building `(p-cat p-nil r)` is refuted as the cost.** Collapsing the
  `p-nil` buys 0.0% on a literal and a class, 1.2% on `pat-not-but`, and 8.9% on
  a star. It is real and it is small.
- **`step-set`'s fresh list per byte is partly confirmed and small**: 18.3 of the
  125.2 B floor, 15%.
- **The fence filter is refuted**, at 0.05% of the ladder.

## The eight passes, measured

`prog/prose-lint.prog:207-214` calls `count-pat` once per check. A ninth build
folds the eight patterns into one `p-alt` and runs the driver once. The counts
merge, so this measures headroom rather than proposing a tool.

| | peak B | matching delta B |
|---|---|---|
| eight passes | 1,111,691,264 | 961,523,712 |
| one union pass | 692,772,864 | 542,605,312 |

**43.6% of the matching cost.** The saving is the seven copies of the per-offset
floor; what remains is the union's own live set, which is the 8 threads above.

## The two quadratics, with their causes

**`str-split`.** `lib/prelude/string.chiral:39-45` recurses as `(str-sub s (+ i
(str-len sep)) (str-len s))`, which **copies the whole remaining string at every
separator**. For a file of `n` bytes and `L` lines that is about `L * n / 2`
bytes. Summing the exact expression over the corpus predicts 69,353,244 B
against 70,074,368 B measured, 1.0% apart.

**`blank-spans`.** `lib/text/matcher.chiral:514-529` grows the accumulator by
`(str-cat acc one)` at every byte, so a line of `L` bytes costs about `L^2 / 2`.
`Bytes` carries `bget` and no `bset`, so there is no indexed write to build the
copy in place. Summing the exact expression over the 1,448 backticked lines
predicts 69,119,059 B against 75,669,504 B measured; the 8.7% residue is the
per-cell length words.

The distribution is extreme. **Five lines carry 65% of it and ten carry 76.8%:**

| payload B | line bytes | file |
|---|---|---|
| 13,886,963 | 5,838 | `docs/arcs/diagnostics-arc.md` |
| 10,630,164 | 5,122 | `docs/arcs/diagnostics-arc.md` |
| 7,869,809 | 4,356 | `docs/arcs/enforcement-arc.md` |
| 7,255,751 | 4,179 | `docs/arcs/diagnostics-arc.md` |
| 6,072,509 | 3,848 | `docs/arcs/diagnostics-arc.md` |

One markdown table row costs 13.9 MB of arena. This is also why the 20-file
slice puts `blank-spans` at 394 B per byte and the 81-file corpus puts it at
124: the long rows live in `docs/arcs`.

## A second finding: `scan-go` crosses the tail-call budget by one

`scan-go` grows the **stack** as well as the arena. Chunk length varied at
constant total input, 128,000 B either way:

| bytes per `count-matches` call | peak B |
|---|---|
| 64 | 15,454,208 |
| 4,096 | 16,502,784 |
| 16,000 | 21,213,184 |
| 64,000 | 39,563,264 |

Bisecting `ulimit -s` confirms the growth is stack: a 64,000 B call needs
between 16 and 24 MiB and a 32,000 B call needs between 8 and 12 MiB, about
320 to 380 B per input byte.

The cause is in the emitter and it is written down there.
`lib/lowering/mach/emit-core.chiral:435` demotes a tail call to `call` plus
`ret` when it carries more than six arguments, because a jump-style tail call
tears the frame down before the seventh argument could be read. **`scan-go` takes
seven parameters.** An arity ladder over a 128,000 B buffer with no allocation
in the loop:

| parameters | peak B |
|---|---|
| 4 | 512,000 |
| 5 | 512,000 |
| 6 | 524,288 |
| **7** | **20,959,232** |
| 8 | 23,056,384 |
| 9 | 27,250,688 |

A sharp cliff at seven, about 160 B of stack per iteration. `run-from` takes
five and stays flat.

On this corpus the term is small: the longest line is 5,838 B, so the deepest
`scan-go` costs about 2.2 MB against 1.11 GB, under 0.2%. It matters for a
different reason. A single line above roughly 25 KB overruns an 8 MiB stack and
the process dies on SIGSEGV. `bin/chirality:149` runs every program under
`ulimit -s unlimited`, which is what has kept this invisible.

## The default scope, projected rather than run

The earlier file recorded the OOM kill there and this session was directed away
from repeating it. An itemised model built from the three causes above, over the
scope as it stands today (**545 files, 8,142,676 B, 7,230,750 kept bytes**):

| term | projected |
|---|---|
| `str-split`, exact arithmetic | 1.61 GB |
| `blank-spans`, exact arithmetic | 0.87 GB |
| matching at the measured 1,609 B per kept byte | 11.63 GB |
| **total** | **14.12 GB** |

The earlier file's linear fit gave ~14.3 GB from four sample points. Two
independent routes agree to 1.3%, and the kill stays arithmetic. Its scope was
544 files and 8,130,791 B; one file has landed since.

## What stays unmeasured

- **The wall clock's split.** This run measured memory. Nothing here licenses a
  statement about where the 1,468 ms goes, and the millisecond column the probe
  printed is one sample under a cgroup rather than a timing claim.
- **The 1.5% by which the eight per-check deltas overshoot the single run.**
- **The 8 to 15 B by which the `Thread` and `cons` rungs of the cell ladder
  exceed `8 * (1 + fields)`.** The `Win` rung matches the formula exactly.
- **How much of `scan-go`'s 320 to 380 B per byte of stack is the demoted tail
  call.** The bare seven-parameter loop uses about 160 B per iteration and the
  excess has no attribution.
- **`pd`'s residual sizes.** The collapse mutant measures the effect of removing
  a `p-nil`; the residuals themselves were never counted.
- **The default scope.** It went unrun, per the direction above.

## The repair, and it has no number

The cause is clear enough to name a shape. Nothing here implements one.

1. **A region for the driver's per-offset garbage.** The measurement says the
   matcher holds 400 B live and allocates 961 MB. `lib/memory/mem-region.chiral`
   already carries the discipline that answers this: an arena *"dropped exactly
   once"* that *"frees as a unit"*. Scoped per line it would return the whole
   86.8%. This is the largest item and the one the attribution points at.
2. **One alternation instead of eight passes.** Measured headroom 43.6% of the
   matching cost, and it is a change to `prog/prose-lint.prog` alone. It
   requires the per-check counts to survive the fold, which slice 1 of E173 has
   no shape for.
3. **`str-split` and `blank-go` rewritten against an index** rather than against
   a rebuilt tail. Together 13.1% here and 17.6% at the default scope.
4. **`scan-go` under seven parameters**, which restores its tail call and
   removes the SIGSEGV on a long line.

⚑ **All four are `UNASSIGNED`.** `docs/arcs/text-tools-arc.md` holds no reserved
element block, `docs/decisions/decision-lane-split.md` reserves `E184-E189` and
`E190-E195` for other lanes, and the block is an open row in
`records/author-calls.md`. Per the deferral rule in
`docs/definitions/working-discipline.md`, a number written here would be a
phantom dependency.

The byte-set `Cls` over a 256-bit bitmap that
`docs/elements/specs/E173-total-matcher-SPEC.md` §6 parks *"when a measurement
asks"* is **not** what this measurement asks for. `cls-has` allocates nothing.

## Re-running this

```
mkdir -p /sys/fs/cgroup/cc-probe
echo "+memory" > /sys/fs/cgroup/cgroup.subtree_control
echo 2000000000 > /sys/fs/cgroup/cc-probe/memory.max
( echo $BASHPID > /sys/fs/cgroup/cc-probe/cgroup.procs; ulimit -s unlimited; exec ./subject.elf < corpus.list >/dev/null )
cat /sys/fs/cgroup/cc-probe/memory.peak
cat /sys/fs/cgroup/cc-probe/memory.events
```

`memory.peak` is cumulative, so the cgroup is recreated between runs. Each
subject is built by copying `lib/` and `prog/prose-lint.prog` to scratch,
editing the copy, and resolving against the copied root:

```
. bin/chirality-resolve.sh
chirality_blob_file "$SCRATCH/lib:$PWD/prog" "$SCRATCH/subject.prog" > subject.blob
( ulimit -s unlimited; bin/chirality-bin < subject.blob > subject.elf ) && chmod +x subject.elf
```

No scratch tree is committed. Every mutation above is one `sed` or one
replaced `scan-doc` body against the files named in each section.
