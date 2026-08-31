---
node: benchmarks-language-performance
layer: benchmark
status: measured
updated: 2026-08-10
---

# Language performance — chirality native codegen vs `gcc -O2`

## Headline (measured)

The native-perf campaign **closed 2026-08-02**. Emitted chirality x86-64 machine
code, measured against `gcc -O2` on three micro-kernels, landed at:

> **~1.4× of `gcc -O2` on compute, 5–8× on memory/branch work** — a band,
> run-10 verified, honest-spread rule — down from **4.4× / 57× / 24×** two days
> earlier.

This is the closing claim quoted verbatim from the campaign's own wrap-up:
*"~1.4x of gcc -O2 on compute, 5–8x on memory/branch work, from 4.4x/57x/24x
two days earlier. The honest-spread rule (quote all three, name the load)
survives the campaign as its phrasing contract."*
(source: `scaffold/bench/RESULTS-2026-08-01.md`, "Tenth run (2026-08-02):
campaign close", and `scaffold/bench/OPTIMIZATIONS-TODO.md` header,
"CAMPAIGN CLOSED 2026-08-02").

The `rd-packed` register-discipline certificate was **ratified 2026-08-02** as
the parked resumption entry point (design done, zero code written): an untrusted
allocator proposes register placements, a small trusted checker verifies them,
emission consumes only verified certificates (source:
`scaffold/docs/rd-packed-cert.md`, "Status: RATIFIED 2026-08-02").

## What was benchmarked

Three kernels, each written with the *same algorithm* in chirality and in C, timed
as emitted x86-64 (chirality) against `gcc -O0` and `gcc -O2` (C). The chirality pure
fragment has no loop form, so loops are bounded-depth nested recursion; the C
sources transcribe that recursion function-for-function (at `-O2` gcc rewrites
it back into loops, so the `-O2` column doubles as the for-loop baseline).

- **arith** (integer compute, 1.0e8 iters): `acc = (acc*3 + i) mod 1048573`.
  Dependency chain runs through the mod; division strategy dominates.
- **bytesum** (memory walk, ~4.9e8 iters): sum the bytes of an L1-resident
  16 KiB cell across passes; measures per-element access machinery.
- **states** (branch/case heavy, 2.0e8 iters): a five-state machine driven by a
  cycling counter; measures branch + call machinery.

## Methodology

- **run-10 / honest-spread.** Ten measured runs across two days; 2 warmup + 5
  measured reps per kernel per side, reporting min/median/max. Because the host
  is a shared virtualized guest with no CPU pinning, **absolute ns/iter do not
  reproduce** (they moved 44–82% between two same-day runs) — only cross-side
  **ratios** are quoted, and the *band* (not any single best sample) is the
  claim. Quiet-vs-quiet runs (1/5/7) are the directly-comparable ones.
- **Anti-fold, verified by disassembly.** Inputs reach C via `argv` (`atoll`,
  opaque), results land in a `volatile` sink and are printed, and result
  equality is asserted across sides. The `-O2` disassembly was read to confirm
  the kernels actually run: bytesum's inner loop is a real 4-instruction scalar
  loop (no `psadbw`/`vpaddb` — the 56–72× gap is genuine scalar throughput, not
  SIMD or DCE); states keeps 75 live backward branches (iterated, not folded).
- **Execution mode verified.** The timed native side is a direct `CFUNCTYPE`
  call into `mmap`'d RX x86-64 code (Python is loader + trampoline only, one
  measured 179 ns crossing, reported not subtracted); the tal interpreter row
  runs 180–440× slower, corroborating the native rows are machine code.
- **Caveat owed.** `perf`/`perf_event_open` is blocked in the microVM, so this
  is wall-clock only — it cannot yet separate "emits more work" from "same work,
  stalls." A `perf stat` run for cycles/instructions-retired is owed on bare
  metal, where absolute ns would also become quotable.

## Measured per-kernel numbers

**Run 1 baseline (2026-08-01), the starting point.** Median ns/iter; ratios are
the defensible part, absolutes are machine/day-local (source:
`scaffold/bench/RESULTS-2026-08-01.md` §"Headline numbers" and §4 raw CSV):

| kernel  | chirality native | gcc -O0 | gcc -O2 | native/-O0 | native/-O2 |
|---------|-------------:|--------:|--------:|-----------:|-----------:|
| arith   | 16.72 | 11.69 | 3.80 | 1.43× | 4.4×  |
| bytesum | 14.45 |  9.83 | 0.26 | 1.47× | 56.6× |
| states  | 17.51 | 14.72 | 0.73 | 1.19× | 24.0× |

**Campaign trajectory (native/-O2 ratio), quiet-load runs.** Each step names the
transform that moved the number (source: `RESULTS-2026-08-01.md` runs 4–10):

| kernel  | run 1 | run 5 (trait tier) | run 7 (magic-mult) | run 9 (rd-param) | run 10 (close) |
|---------|------:|-------------------:|-------------------:|-----------------:|---------------:|
| arith   | 4.4×  | 1.73× | 1.37× | 1.38× | **1.39×** |
| bytesum | 56.6× | 6.0×  | 5.9×  | 5.2×  | **6.3×**  |
| states  | 24.0× | 9.5×  | 8.4×  | 6.7×  | **7.6×**  |

Attribution (all disassembly- or differential-verified): inline `bget` + fold
moved bytesum; tail-call elimination + immediate operands + pow2 strength
reduction and the trait tier (constant-divisor guard elision, total-call
folding, CSE, dense-tag jump tables) moved all three; magic-multiply constant
division moved arith's critical path (idiv → ~3-cycle multiply chain); rd-param
(pass-through param residency) moved states −17% and bytesum −8%. Fused
compare-and-branch + rax-residency (run 6) removed real instructions but did
*not* move the wall clock on these latency-bound kernels — honestly logged as a
negative result. The closing note: bytesum/states carry ±15–20% run-to-run
wobble even at quiet load, so run 9 was the best sample, not the typical one —
hence the **band** is the claim.

**Honest spread beyond `gcc`** (source: `OPTIMIZATIONS-TODO.md` "Where things
stand"): compute is the best kernel; on memory/branch work chirality is behind
mature unchecked own-backend languages (OCaml/Go/MLton 1.5–3×) and ~tied with
CakeML's 4–10× band. Say "1.4× on compute, 5–7× on memory/branch, trending
down" — never just the `1.38×`.

## Where the harness lives

The benchmark harness is **private-only** — `scaffold/bench/` is stripped from
the public mirror by `bin/make-public.sh`. This doc (under `docs/`) is the
public record of its results. In the private tree:

- `scaffold/bench/run.sh` — one-command driver (builds under `/tmp/chirality-bench`,
  runs all sides, disassembles evidence, prints the summary). Rerun: `cd
  scaffold/bench && sh run.sh`.
- `scaffold/bench/kernels.chiral`, `kernels.c` — the three kernels + C driver.
- `scaffold/bench/RESULTS-2026-08-01.md` — all ten measured runs (the authority
  for every figure above), raw CSV, execution-mode verification, disassembly
  evidence, environment/caveats.
- `scaffold/bench/OPTIMIZATIONS-TODO.md`, `OPT-LEDGER.md`, `TRAIT-OPTS.md` — the
  parked menu, what landed, the trait survey.
- `scaffold/docs/rd-packed-cert.md` — the ratified certificate design.

## Parked / aspirational (not yet measured)

The campaign closed by author call; the following are **designed or listed, not
measured** — do not quote a number for them (source:
`OPTIMIZATIONS-TODO.md` Tier A + open residue):

- **rd-packed** (slot-retiring register allocation) — the remaining ambient gap
  on all three kernels; certificate format ratified, **zero code written**. The
  resumption entry point.
- Cross-function inlining; loop-invariant motion; operand-aware chunking
  (peephole pattern B is pinned but dormant); instruction scheduling (blocked on
  perf counters / bare-metal run); jump-table threshold tuning (needs real
  dispatch-heavy workloads).
- A **macro-benchmark** (json-parse / FSM workload) so the landed trait tier is
  exercised on real code, not microkernels.
- **`perf stat` on bare metal** for cycles + instructions-retired, which would
  also make absolute ns quotable.
