# Language profile, compiler and emitted code, 2026-09

Analysis and measurement only. No tracked file changed. Machine: 12 vCPU microVM, CPU only, one agent in the tree, load 0.1 to 0.5 during every timing. HEAD `96f40ee`, `bin/chirality-bin` 1,257,848 B, sha256 prefix `3fd1b786e9fe1c4d00aa42ed`. Every probe, driver and tool named below lives in the session scratchpad under `lp/`.

## Log

- 2026-09-29 host has no `perf`, `gdb`, `valgrind`, `strace` or `ltrace`; it has `gcc`, `objdump` and `python3`. The ELF carries no section or symbol table (`readelf -S`: "There are no sections in this file").
- 2026-09-29 the clock port has no working crossing. `time-mono` is declared at `lib/ports/clock.port:32` and `crossing-wraps` (`lib/lowering/tal/crossing-wraps.chiral:13-57`) routes no row for it, so a pass boundary cannot read a clock from inside the program.
- 2026-09-29 pass driver `lp/prog/pfcc.prog`: `compile-all` rebuilt from its own steps (`load-source-batched`'s three phases, `tot-gate`, `specialize-singletons`, `closconv-sig`, `bridge-sig`, `lower-defs`'s loop, `filter-erasable`, `prune-fix`, `erase-list`, `emit-elf-m`'s steps and `emit-with-peep`'s steps), with `(trace "@M <pass> <heap-allocated>")` after each and every emitted label written as `@S <label> <offset>`. Built by `bin/chirality-bin`. A reader (`lp/pfrun.py`) stamps each marker on arrival with `perf_counter`, `/proc/<pid>/stat` CPU and `VmRSS`.
- 2026-09-29 driver on the compiler blob (`chirality_blob_file "lib:prog" prog/compiler.prog`, 851,722 B): output `cmp` equal to `bin/chirality-bin`. So the driver emits what the compiler emits, and its label dump (7,640 labels) is `bin/chirality-bin`'s symbol map. Same identity on `e185_apply_word`, `e173_matcher` and `e170_infer_arms`.
- 2026-09-29 driver, three runs each, `python3 lp/pfrun.py lp/pfcc.elf <blob> ...`: compiler blob 0.827 / 0.814 / 0.816 s wall, 0.72 to 0.74 user, 385 MB; `e170_infer_arms` (971,030 B) 0.996 / 0.979 / 1.012 s, 429 MB; `e173_matcher` (61,598 B) 0.024 / 0.025 / 0.026 s, 18 MB; `e185_apply_word` (9,718 B) 0.012 / 0.009 / 0.009 s, 7 MB.
- 2026-09-29 `bin/chirality-bin < compiler blob`, three runs: 0.796 / 0.827 / 0.799 s wall, 0.69 to 0.72 user, 0.07 to 0.12 sys, 385 MB, output `cmp` equal to itself.
- 2026-09-29 the 60 roots under `tools/test/samples/` resolve to two populations: 47 between 9.7 KB and 163 KB, and 13 between 938 KB and 971 KB. The large ones import `lib/evidence/test-floor.chiral`, which imports `lowering/compile-all` at `:34`.
- 2026-09-29 sampling profiler `lp/samp.c` (ptrace: stop the child every 500 us, read `rip`, walk the `rbp` chain up to 400 frames; the emitted prologue is `push rbp; mov rbp, rsp`, `lib/lowering/x64/mach.chiral:65`). Symbolized by `lp/sym.py` against the label dump, `$bN` block labels folded into the function above them.
- 2026-09-29 five sampled self-compiles of `bin/chirality-bin`, `lp/samp 500 400 ... -- bin/chirality-bin`: 9,357 samples, outputs `cmp` equal. Self time: `nb-beq` 29.9%, `nb-copy` 9.6%, `dctor-index` 9.2%, `assoc-core` 4.2%, `nb-beq-go` 2.6%, `lapp-tfn` 2.4%, `l-snoc` 1.9%, `append` 1.8%, `assoc` 1.5%, `x64-peep` 1.5%, `emap-get` 1.4%, `lits-mem` 1.3%, `ctor-tag` 1.2%, `in?` 1.1%. Runtime routines (`nb-*`) 44.6% of self time. Callers of `nb-beq`: `assoc-core` 21.5%, `dctor-index` 17.9%, `assoc` 8.4%, `lits-mem` 7.7%, `emap-get` 6.7%, `sig-assoc` 6.5%, `sv-ctor-fields` 5.9%, `in?` 5.4%, `find-ddata` 4.1%. Callers of `nb-copy`: `bcat-pairs` 56.5%, `read-fd-go` 17.1%.
- 2026-09-29 the same samples grouped by cause: linear name lookup by string equality (the scan loops plus `nb-beq`) 56% of self time, byte copying 11.3%, list append 6.4%. Inclusive `ctor-tag` 13.8%, `boxed-of` 3.5%.
- 2026-09-29 five sampled runs of the driver on the compiler blob with the sampler reading the stderr offset at each sample (`SAMP_ERR`), so every sample lands in the pass in progress. Shares are in the pass table below. The label dump pass is excluded: ptrace stops on its 7,640 `write`s and it is a probe cost.
- 2026-09-29 `objdump` of `nb-beq-go` at `0x400994`: 27 instructions per byte compared, every value through an `rbp` slot, and the self tail call re-runs the full prologue (`jmp 0x400994`).
- 2026-09-29 top-level constants are functions rebuilt at every reference. `crossing-wraps` lowers to 8,881 B of code that allocates each pair and cons cell on each call; `erase-instr-onto` calls `(cw-lookup crossing-wraps op)` per `i-prim`. `linux-syscalls` is 8,273 B of code, `prim-table` 1,071 B.
- 2026-09-29 `str-eq` microbench, 20,000,000 compares of two equal 24-byte strings: chirality `lp/prog/beqb.prog` 0.899 / 0.921 / 0.916 s; the same byte loop in C, `gcc -O0 -fno-builtin` 0.609 s, `gcc -O2 -fno-builtin` 0.267 s. The chirality loop carries its own loop-function overhead on top of `nb-beq`.
- 2026-09-29 whole suite under `lp/ptr` (ptrace exec/exit tracer, per process `schedstat` runtime and `VmHWM`), phase boundaries read off `run-tests.sh`'s own output stamped by `lp/ts.py`, run as `lp/ptr lp/suite.ptr -- bash -c "tools/test/run-tests.sh 2>&1 | python3 lp/ts.py > lp/suite.ts"`. Gate PASSED, 320.2 s wall, 62,387 processes, 223.8 s of process CPU. `CHIRALITY_COMPILE` unset, so phases 29 and 30 are counted the same as every other.
- 2026-09-29 compiles in that run: 459 by `bin/chirality-bin`, 75.1 s CPU, 76.3 s summed wall, median 0.036 s, max 1.137 s, peak 415 MB. 339 of them under 0.1 s sum to 8.7 s; 83 at or above 0.3 s sum to 61.6 s. Mutant compiler generations ran 355 times for 1.1 s. Chirality-built programs other than compilers 10.2 s, of which `prose-lint.prog` and its M11 mutant 8.5 s in phase 19. `bash` 54.2 s, `sed` 36.9 s, `grep` 31.4 s.
- 2026-09-29 `prog/prose-lint.prog` built by the driver, `cmp` equal to `bin/chirality-bin`'s build, 1,294,712 B, compile 0.846 s wall and 400 MB. Its blob is 888,065 B because it imports `lowering/compile-all` for `read-fd-all` (`prog/prose-lint.prog:42`).
- 2026-09-29 `prose-lint.prog` over the G9 corpus (`docs/arcs docs/decisions docs/definitions`, 154 files, 2,541,478 B), three runs: 4.05 / 3.98 / 3.99 s wall, 3.33 to 3.40 user, 0.50 to 0.53 sys, 1,986 MB. `prose-lint.sh --summary` on the same: 0.263 s wall, 0.14 user. 15.2x at quiet load.
- 2026-09-29 three sampled runs of `prose-lint.prog`, run from the tree root, 12,503 samples, output `cmp` equal: `nb-copy` 46.5% self (callers `str-split-go` 63.5%, `blank-go` 34.6%), `scan-go` 11.2%, `can-start` 6.4%, `pd` 4.6%, `cls-has` 3.5%, `pd-cat` 3.4%, `pd-threads` 2.3%, `nullable` 2.2%, `append` 1.9%, `or` 1.4%. Inclusive: `find-all` 45.5%, `str-split-go` 29.8%, `blank-go` 17.0%.
- 2026-09-29 heap split probe `lp/prog/plprof.prog` (`prose-lint.prog` with `heap-allocated` reads around `str-split`, `keep-lines` and the eight `count-pat` calls in `scan-doc`), output `cmp` equal: `str-split` 539.4 MB, `keep-lines` 344.4 MB, matching 1,186.3 MB, total 2,096.3 MB, 825 B per input byte.
- 2026-09-29 prototype `lp/prog/plprof2.prog`: split by walking an index with `str-find-from` and copying each piece once. Output `cmp` equal. `str-split` 539.4 MB to 3.7 MB; 2.71 / 2.72 / 2.72 s wall; 1,475 MB peak.
- 2026-09-29 prototype `lp/prog/plprof3.prog`, on top of plprof2: inline spans blanked run by run with `str-find-from` in place of `blank-go`'s per-byte `str-cat`. Output `cmp` equal. `keep-lines` 344.4 MB to 12.8 MB; 2.14 / 2.07 / 2.16 s wall, 1.71 to 1.77 user; 1,159 MB peak; total heap 1,229.1 MB.
- 2026-09-29 prototype driver `lp/prog/pfcc2.prog`: `lower-defs`'s loop conses onto a reversed accumulator and reverses once, and `filter-erasable`'s dry-run erase keeps each `NFn` it produced so `erase-list` does not run again. Output `cmp` equal to `bin/chirality-bin`'s on the compiler blob, `e170_infer_arms` and `e173_matcher`. Compiler blob, three runs: 0.721 / 0.732 / 0.723 s wall against 0.827 / 0.814 / 0.816, 331 MB against 385 MB. Lower+fold 75 to 78 ms to 57 to 59 ms and 80.3 MB to 52.3 MB; erase 70 ms and 29.0 MB to 0.2 ms and 0 MB. `e170_infer_arms`: 0.996 s to 0.861 s, 429 MB to 361 MB.
- 2026-09-29 largest corpus file 154,511 B (`docs/arcs/enforcement-arc.md`).

## Method and its limits

**Pass time.** Markers are `trace` writes to fd 2, which are unbuffered `write` syscalls, stamped by the reading process on arrival. Wall resolution is tens of microseconds; the CPU column comes from `/proc/<pid>/stat` at 10 ms ticks and is coarse below 20 ms. The driver adds one `trace` and one `heap-allocated` per pass, measured at under 1 ms total apart from the label dump, which is timed as its own pass and left out of every share.

**Pass memory.** `heap-allocated` is the bump cursor, total bytes ever allocated (`lib/ports/process.port:36`). The arena never frees, so this measures allocation per pass, and the live set is invisible to it. RSS is read at each marker as a second view: it includes the stack, which grows with deep non-tail recursion and is also never returned.

**Where the time goes inside a pass.** The sampler's `rbp` walk stops at 400 frames, so inclusive shares undercount functions that sit below deep recursion (`compile-main` reads 38.7% inclusive). Self shares have no such bias. A sample taken inside a prologue attributes its caller one frame late. Five runs give about 9,000 samples, so a share near 1% carries about 0.1 point of sampling noise.

**The suite census.** Every exec and exit under the suite, traced by ptrace, with no change to the suite and no `CHIRALITY_COMPILE`. A compile is an exec of `bin/chirality-bin`; mutant generations are counted apart by path. CPU is the leader's `schedstat` runtime, exact in nanoseconds. The tracer slows forks, so the 320 s wall is an upper figure for an untraced run.

## Time and memory per pass, self-compile

Compiler blob, 851,722 B in, 1,257,848 B out. Wall and heap from `pfrun` run 2; share from the five sampled runs, label dump excluded. Two larger roots beside it.

| pass | wall ms | heap MB | share of samples | what dominates the pass (self) | `e170_infer_arms` ms / MB | `e173_matcher` ms / MB |
|---|---|---|---|---|---|---|
| read stdin | 15.7 | 7.7 | 1.5% | `nb-copy` 96% | 20.1 / 9.9 | 0.4 / 0.3 |
| read s-expressions | 25.8 | 12.3 | 2.6% | `read-list*`, `nb-copy`, `rev-onto` | 28.6 / 13.8 | 1.7 / 0.7 |
| load data decls | 3.7 | 3.4 | 0.4% | | 5.0 / 4.5 | 0.5 / 0.0 |
| load forms (elaborate, check) | 127.3 | 44.4 | 12.8% | `nb-beq` 43%, `assoc` 9%, `in?` 7% | 181.4 / 47.5 | 2.7 / 2.7 |
| totality gate | 0.4 | 0.0 | 0.0% | | 0.3 / 0.0 | 0.2 / 0.0 |
| specialize singletons | 27.8 | 7.8 | 2.9% | `term-refs` 48% | 29.6 / 8.1 | 0.1 / 0.0 |
| closure conversion | 137.4 | 17.0 | 17.0% | `nb-beq` 57%, `assoc-core` 24% | 164.7 / 18.3 | 1.4 / 1.1 |
| bridge and peel | 28.9 | 5.5 | 4.8% | `nb-beq` 52%, `emap-get` 29% | 33.5 / 5.9 | 0.4 / 0.3 |
| back prep | 2.7 | 1.8 | 0.2% | | 3.0 / 2.0 | 0.3 / 0.1 |
| lower and fold | 78.5 | 80.3 | 10.7% | `lapp-tfn` 25%, `nb-beq` 24%, `l-snoc` 17% | 89.9 / 88.7 | 1.1 / 1.3 |
| filter-erasable (dry-run erase) | 69.2 | 29.2 | 9.5% | `dctor-index` 48%, `nb-beq` 27% | 90.1 / 37.0 | 0.7 / 0.9 |
| prune | 33.9 | 2.2 | 4.9% | `nb-beq` 55%, `lits-mem` 27% | 39.0 / 2.4 | 0.1 / 0.1 |
| erase | 70.2 | 29.0 | 10.1% | `dctor-index` 41%, `nb-beq` 32% | 89.4 / 36.8 | 0.6 / 0.9 |
| reify, link, E76 checks, dup check | 6.3 | 2.3 | 0.9% | `nb-beq` 91% in the dup check | 8.0 / 2.4 | 0.6 / 0.1 |
| emit-program | 45.9 | 60.7 | 6.3% | `nb-copy` 26%, `append` 23%, `nb-pack32` 12% | 48.9 / 64.5 | 2.8 / 3.5 |
| append data and fin | 5.6 | 3.6 | 0.8% | `append` 91% | 6.1 / 3.9 | 0.3 / 0.2 |
| peephole | 18.6 | 3.5 | 2.4% | `x64-peep` 67% | 18.5 / 3.8 | 1.1 / 0.2 |
| place labels | 2.6 | 0.4 | 0.4% | | 2.4 / 0.4 | 0.1 / 0.0 |
| label tree | 8.1 | 10.5 | 1.0% | `mk-node` 57% | 8.2 / 11.7 | 0.3 / 0.8 |
| materialize chunks | 19.3 | 9.5 | 3.0% | `mat-chunks` 48% | 20.4 / 10.1 | 0.7 / 0.5 |
| `bcat-all` | 55.2 | 27.1 | 7.0% | `nb-copy` 85% | 58.7 / 28.9 | 2.8 / 1.4 |
| assemble ELF | 5.2 | 3.8 | 0.8% | `nb-copy` 100% | 6.0 / 4.1 | 0.1 / 0.3 |
| **total** | 814 | 362.6 | | | 979 / 405.5 | 25 / 15.7 |

By half: front (read through peel) 367 ms and 98.0 MB, back 255 ms and 142.5 MB, emit 167 ms and 121.3 MB. The heap figures reproduce `.planning/OPTIMIZATION-GAPS-2026-09.md`'s stage split to the tenth.

RSS runs ahead of the heap in emit: 291 MB at the end of emit-program, 336 MB after the peephole, while the heap moved 7.1 MB. That is stack. `cat2` and `x64-peep` recurse once per item over a 141,851-item `Asm` list, and the stack pages they touch stay resident to the end.

**What allocates, and what survives.** The arena cannot say which bytes are live, so the survivor column is an estimate from what each pass hands to the next.

| allocation | MB | survives the pass | basis |
|---|---|---|---|
| `read-fd-go`'s `(bcat acc chunk)` per 64 KB (`lib/lowering/compile-all.chiral:52`) | 7.7 | 0.85 | measured heap; the blob is the only survivor |
| `lower-defs`'s append accumulator (`lib/lowering/compile-back.chiral:272`) | 28.0 | 0 | measured, the reversed accumulator removes it |
| the dry-run erase in `filter-erasable` | 29.2 | 0 in HEAD, all of it once reused | measured, the second erase removes 29.0 MB |
| emit-program's `Asm` list | 60.7 | about 8 | estimate: 141,851 items at a cons, a constructor and a short byte cell each; the rest is `cat2` copies and per-instruction `bcat`s in the encoders |
| label tree by persistent insert | 10.5 | about 0.4 | estimate: 7,640 nodes; path copies are garbage |
| `bcat-all`'s balanced rounds | 27.1 | 1.26 | measured output size |
| everything, end of compile | 362.6 | 1.26 at exit | the ELF |

## What a suite run costs in compiles

Suite of 2026-09-29 under the exec tracer, gate PASSED. "big" is a compile at or above 0.3 s: the compiler blob and roots that embed it.

| phase | wall s | all process CPU s | compiles | compile CPU s | big compiles | big CPU s | mutant compiler runs | built-program CPU s |
|---|---|---|---|---|---|---|---|---|
| 1 inline | 1.1 | 0.36 | 6 | 0.04 | 0 | 0 | 0 | 0 |
| 2 test-runner | 1.5 | 1.54 | 1 | 0.87 | 1 | 0.87 | 0 | 0.03 |
| 3 check CLI | 11.6 | 14.58 | 11 | 3.15 | 4 | 3.13 | 28 | 0 |
| 4 profile-target | 32.6 | 27.88 | 37 | 2.67 | 3 | 2.60 | 102 | 0 |
| 5 syscall manifest | 5.4 | 5.00 | 12 | 3.62 | 4 | 3.58 | 4 | 0 |
| 6 linear mint | 23.4 | 16.18 | 37 | 4.54 | 5 | 4.45 | 160 | 0 |
| 7 roots | 44.6 | 35.23 | 99 | 15.33 | 12 | 8.73 | 0 | 0 |
| 13 diag | 14.6 | 5.93 | 17 | 1.27 | 1 | 0.90 | 1 | 0 |
| 14 doc | 13.4 | 6.72 | 20 | 1.80 | 1 | 0.90 | 1 | 0.01 |
| 15 row | 21.1 | 9.24 | 31 | 0.72 | 0 | 0 | 0 | 0.02 |
| 16 face | 3.6 | 2.39 | 12 | 0.21 | 0 | 0 | 0 | 0.01 |
| 17 render-doc | 9.2 | 4.86 | 12 | 0.40 | 0 | 0 | 0 | 0.01 |
| 18 pretty | 12.9 | 7.40 | 19 | 1.24 | 0 | 0 | 0 | 0.02 |
| 19 matcher | 18.0 | 15.04 | 18 | 2.46 | 2 | 2.07 | 0 | 8.57 |
| 20 transport | 1.5 | 0.79 | 5 | 0.17 | 0 | 0 | 0 | 0 |
| 24 arity | 25.1 | 17.38 | 46 | 8.94 | 8 | 7.10 | 16 | 0.02 |
| 25 apply-word | 12.6 | 10.09 | 12 | 6.40 | 11 | 6.39 | 6 | 0.01 |
| 26 capture-fields | 4.9 | 3.52 | 6 | 2.01 | 6 | 2.01 | 0 | 0.01 |
| 27 defunc-blame | 9.3 | 7.13 | 6 | 4.47 | 5 | 4.46 | 11 | 0 |
| 28 apply-spine | 13.3 | 10.14 | 13 | 6.46 | 11 | 6.45 | 16 | 0.02 |
| 29 encoding | 3.8 | 2.24 | 5 | 0.06 | 0 | 0 | 0 | 1.07 |
| 30 recording | 3.3 | 1.40 | 10 | 0.08 | 0 | 0 | 0 | 0 |
| 31 crypto | 0.8 | 0.28 | 4 | 0.05 | 0 | 0 | 0 | 0.01 |
| 32 mul-widen | 8.0 | 5.38 | 8 | 2.79 | 3 | 2.65 | 4 | 0.01 |
| 33 span-over | 11.9 | 8.40 | 12 | 5.37 | 6 | 5.32 | 6 | 0.30 |
| registration | 13.8 | 4.73 | 0 | 0 | 0 | 0 | 0 | 0 |
| **total** | 321.2 | 223.82 | 459 | 75.11 | 83 | 61.62 | 355 | 10.15 |

Compiling is a third of the suite's CPU, 75.1 of 223.8 s, and 82% of that third is the 83 big compiles. Those are the compiler blob built as a generation (phases 24 to 33 build mutant and fresh compilers) and the 13 test-floor roots that carry the compiler inside them. The 339 small compiles cost 8.7 s together. So the suite's compile bill moves almost one for one with the self-compile's speed: halving the self-compile returns about 31 s of CPU. The shell tools cost more than the compiler, `bash`, `sed` and `grep` at 122.5 s together, which is the tooling side `.planning/OPTIMIZATION-GAPS-2026-09.md` ranked.

## `prose-lint.prog`'s hot spots

Over the G9 corpus, 3.99 s median wall against awk's 0.26 s, 2,096 MB allocated, 1,986 MB peak.

| where | time (samples) | heap | cause |
|---|---|---|---|
| `str-split` in `scan-doc` (`prog/prose-lint.prog:206`) | 29.8% inclusive, nearly all `nb-copy` | 539.4 MB | `str-split-go` (`lib/prelude/string.chiral:39-45`) copies the whole remaining suffix at every newline, `L * n / 2` bytes a file. Quadratic in file size, so the 154 KB file dominates |
| `blank-spans` in `keep-lines` | 17.0% inclusive | 344.4 MB | `blank-go` (`lib/text/matcher.chiral:583-599`) grows its accumulator by `str-cat` one byte at a time, `L^2 / 2` a line. `Bytes` has no indexed write to build into |
| the matcher, eight `count-pat` passes | 45.5% inclusive | 1,186.3 MB | Brzozowski derivatives per byte: `scan-go` (`:452`) spawns a `Thread` cell and a `Win` cell per offset, `pd` builds residual `Pat` trees, and `norm` (`:284`) sorts and dedups the live set by structural `pat-cmp` every byte. About 58 B allocated per input byte per pattern |
| page faults | 0.50 of 4.0 s is `sys` | | 2 GB of fresh arena touched once. Falls with the heap: 0.22 to 0.29 s after both prototypes |
| file reads | 0.6% | about 27 MB | `read-fd-all` per file, one 64 KB chunk for most files |

The emitted code under all of it has four shapes that cost everywhere. Every value lives in an `rbp` slot, 27 instructions per byte in `nb-beq-go`. Small helpers are calls with full frames: `or` alone is 1.4% self. Every `Win`, `Thread`, `Span` and `Maybe` is a heap cell. The unused compiler inside the binary costs compile time only: 0.85 s and 400 MB per build of a 1.29 MB ELF, twice per suite.

With both prototypes the run is 2.12 s and 1,229 MB, and the matcher is what is left: 1,186 MB and about 1.7 s of user time, 8x awk.

## Ranked language fixes

"Measured" means a prototype in the scratchpad produced output `cmp` equal to the tree's and was timed. "Estimated" means a measured share of the removed work, scaled. Times are per self-compile (0.81 s) unless a program is named. The rule is `.planning/protocol/reconcile.md` §"Proper or not at all"; each item names the proper form, or a proper smaller form that stands complete.

| # | fix | gain | size, and why | owner | check it carries |
|---|---|---|---|---|---|
| 1 | **Name lookup through an ordered map, pass by pass.** Every environment in the compiler is an association list scanned with byte-wise `str-eq`: `assoc` and `in?` in the elaborator (`lib/surface/surface.chiral:89-91`), `assoc-core` in closure conversion (`lib/lowering/upper/closconv.chiral:471`), `emap-get` at the peel (`lib/lowering/compile-front.chiral:93`), `lits-mem` in prune (`lib/lowering/compile-back.chiral:91`), `sig-assoc` in lowering (`lib/lowering/upper/lower.chiral:164`). `prelude/map`'s `Map Str` already exists and the emitter uses it for labels (`lib/lowering/mach/asm-reloc.chiral:68`) | 56% of self time is this scan, **measured**. About 0.35 to 0.45 s per big compile, **estimated**: closure conversion 17% of samples at 81% lookup, load forms 12.8% at about 60%, peel 4.8% at 81%, prune 4.9% at 82% | one proper smaller piece per pass, a day or two each: the map replaces the list inside one pass and changes no data type that crosses a pass boundary, so each piece stands alone. The whole of it is several days | none. No goal condition holds the compiler's own time (`docs/arcs/enforcement-arc.md:504`) | the BUILD RULE: C1 `cmp` against the tracked binary, since no emitted byte should move, then the suite |
| 2 | **Constructor tags resolved once.** `ctor-tag` (`lib/lowering/tal/erase.chiral:59`) walks every data declaration and every constructor by name for each `i-con` and each case branch; `boxed-of` (`:80`) does it again through `dname-of`. One `Map Str I64` of tags and one of owning types built from `datas` before the erase | 13.8% inclusive for `ctor-tag`, 3.5% for `boxed-of`, **measured**. After item 3 half remains, about 70 ms, **estimated** | a day. The env of `erase-fn` (`:276`) grows from the data list to a record holding it and the two maps | none | BUILD RULE fixpoint byte-identical, then the suite |
| 3 | **Erase once.** `filter-erasable` (`lib/lowering/compile-back.chiral:185`) erases every `TFn` as a dry run and discards the result; `erase-list` (`:128`) erases the survivors again. Keep the `NFn` beside its `TFn` through prune | 70 ms and 29 MB per self-compile, **measured** (with item 4: 0.816 s to 0.723 s, 385 MB to 331 MB peak, outputs `cmp` equal on three roots) | half a day. `erase-fn` is pure in its two arguments and `prune-fix` keeps an in-order subsequence, so a paired walk recovers the kept `NFn`s | none | BUILD RULE fixpoint byte-identical, then the suite |
| 4 | **`lower-defs` conses and reverses once** (`lib/lowering/compile-back.chiral:272`) | 20 ms and 28.0 MB, **measured** in the same prototype | an hour. Same list, same order | none; `.planning/OPTIMIZATION-GAPS-2026-09.md` item 7 | BUILD RULE fixpoint byte-identical |
| 5 | **Word-wide byte primitives.** `nb-beq-go`, `nb-copy` and `nb-bcat` (`lib/lowering/tal/bytes.chiral:60-126`) move one byte per self tail call through a full frame. A compare and a copy over eight-byte words with a byte tail, or `rep movsb` and `rep cmpsb`, as named operations the emitter lowers | `str-eq` runs 3.4x a `gcc -O2` byte loop and 1.5x `gcc -O0`, **measured**. `nb-beq` plus `nb-copy` are 42% of self-compile self time and 46.5% of `prose-lint.prog`'s; a 3x primitive returns about 25% of the compile before item 1 and about 10% after, **estimated** | two days. A word load is an `Op` the sum does not carry today (`lib/prelude/prelude.chiral:36-39`), so this is a new operation with its encoder | `emitted-speed` requirement 6 reads on the operation set; `OPT-CANDIDATES` C30 names block compare as absent (`docs/benchmarks/OPT-CANDIDATES-2026-09.md:346`) | an operand table over lengths 0 to 17 and misaligned offsets against the byte loop, then the BUILD RULE |
| 6 | **Substring views, or `str-split` by index.** The proper smaller fix is the library one: `str-split-go` walks with `str-find-from` and copies each piece once | `prose-lint.prog` 3.98 s to 2.72 s and 539.4 MB to 3.7 MB, **measured**, output `cmp` equal. Seven files beside `lib/prelude/string.chiral` call `str-split`, `prog/prose-lint.prog` among them | two hours for the library fix. A borrowed slice type that shares its parent's bytes is the language form and is larger than a week, since it needs a lifetime the arena cannot express yet | `text-tools`, no row | phase 19's G9 differential, plus the corpus output compared whole |
| 7 | **A linear byte builder.** `blank-go` builds by per-byte `str-cat` because `Bytes` has no write. An owned buffer with an in-place `bput`, consumed once into `Bytes`, is `memory-discipline/M4`'s destination-passing buffer | `prose-lint.prog` 2.72 s to 2.12 s and 344.4 MB to 12.8 MB, **measured** for the run-wise library rewrite; the builder serves `bcat-all` (27.1 MB, 55 ms) and emit-program's per-instruction `bcat`s too, **estimated** | the library rewrite, two hours. The builder is `E84`'s scope, M-sized, and keeps the linear discipline by construction since the buffer is linear | `memory-discipline/M4` (`E84`) | the BUILD RULE for `bcat-all`; G9 for `blank-spans` |
| 8 | **Register-resident values.** Every SSA value round-trips through an `rbp` slot. A location vocabulary (`B3`, `docs/benchmarks/OPT-CANDIDATES-2026-09.md:272`) and the checked allocator already ratified as `rd-packed` (`B19`, `:288`) | 1.5x to 3x on every compiled program including the compiler, **estimated** from the `str-eq` bench, where `gcc -O0`'s slot code sits 2.3x behind `gcc -O2` | weeks. `B3` changes the instruction set and the certificate checker is new code | none on a roster; `OPTIMIZATIONS-TODO` names `rd-packed` as the resumption point | a certificate per function checked by the rd-packed checker, then the BUILD RULE |
| 9 | **Top-level constants evaluated once.** A closed constant def lowers to a function that rebuilds its value at every reference: `crossing-wraps` is 8,881 B of allocating code called per erased `i-prim` | 0.7% self, **measured**; its allocation is unmeasured | two days. The value is built once into the data section or on first use, and the linear and region rules hold because a closed constant has no linear component | `lowering-and-emit`, no row | BUILD RULE fixpoint, then the suite |
| 10 | **Region reset per unit of work.** `prose-lint.prog` keeps every byte of every file's matching until exit | 1,159 MB peak to about 100 MB, **estimated**: the largest file is 6% of the corpus and matching allocates about 467 B per input byte | M. `memory-discipline/M2` (`E82`); its smaller proper slice is the scalar-result rewind (`OPT-CANDIDATES` D6, `:378`), a region whose body may return only an `I64`, which is `do-path`'s exact shape | `memory-discipline/M2` | peak RSS on the G9 run, and a type check that refuses a region body returning a pointer |
| 11 | **Inlining.** `or`, `at-byte`, `can-start` and `cls-has` are calls in the matcher's per-byte loop | unmeasured in isolation; `or` is 1.4% self and the four together 11.5% | `emitted-speed/X10` to `X12` | `emitted-speed/X11` | `enforcement/N23`'s per-rewrite value check, which requirement 7 puts on every adopted rewrite |
| 12 | **Reachability before lowering.** The back half lowers every def in the blob. `prose-lint.prog`, `paren-audit.prog` and `shape-census.prog` import `lowering/compile-all` for `read-fd-all` alone (`prog/prose-lint.prog:42`, `prog/paren-audit.prog:34`, `prog/shape-census.prog:55`), so each build lowers and emits the whole compiler | back and emit are 52% of a big compile; for these three roots about 0.4 s each and a 1.29 MB ELF, **estimated**. About 1 s per suite | a day for the prune from the entry over `block-calls`, which `prune-fix` already computes. Moving `read-fd-all` to its own module is an hour and is library hygiene | `lowering-and-emit`, no row | BUILD RULE fixpoint, and the ELF size of `prose-lint.prog` |

Items 3 and 4 are in hand today and measured together at 11%. Items 1 to 4 together are the "same bytes, less work" class: none moves an emitted byte, so the BUILD RULE is their whole check and none of them is a rewrite of emitted code. Items 5, 8, 9 and 11 change emitted code, so each enters as a checked rewrite under `docs/arcs/enforcement-arc.md:471` requirement 7.

## "Our math shouldn't take that long"

It should not, and the profile says where the extra goes. Of 0.81 s for the self-compile:

| share | what it is | necessary |
|---|---|---|
| 56% | finding a name in a list by comparing strings byte by byte | a map lookup or an interned id does it in under 2%, estimated |
| 11% | copying bytes: the stdin reader's quadratic, `bcat-all`'s log rounds, per-instruction `bcat`s | the output written once, under 1%, estimated |
| 6% | appending to the end of lists | none |
| about 27% | the parse, the type check, closure conversion, lowering and code generation proper | yes, apart from the second erase, whose non-lookup remainder is about 1.5% |

The second erase is 9% measured, and most of it is `ctor-tag`'s scan, already inside the 56%. So about a quarter of the compile is the work, and the self-compile would run near 0.2 s on the same code generator, estimated. The code generator then keeps every value in memory and calls every helper through a full frame; the `str-eq` bench puts that at 2x to 3x against `gcc -O2` on the same loop. The necessary work, compiled well, is on the order of 0.1 s, a ratio near 8 to 1. In suite terms: compile CPU is 75 of 224 s, and items 1 to 4 alone return about 45 s of it, estimated.

`prose-lint.prog` shows the same split one level up. Two library quadratics are 44% of its time and 42% of its heap, and removing them measured 1.9x. What remains is the matcher allocating 467 B per input byte and keeping all of it, which is an algorithm choice (derivatives with a sort per byte) meeting an arena that cannot give memory back.

## Caveats

- One run of the traced suite. Its wall is inflated by the tracer; its CPU figures are per process and exact.
- The driver's pass boundaries follow `compile-all`'s call structure. Load forms interleaves elaboration and checking per form, so the two are one row.
- Inclusive shares are truncated at 400 frames. Self shares and marker times carry the claims.
- The survivor column is estimated; no instrument in the tree reads a live set.
- The prototypes are scratch roots. The lookup maps, the tag table and the byte primitives have no prototype; their gains are estimates from measured shares.
- Fifteen `/tmp/tmp.*` directories dated 20:29 to 20:31 predate this run and were left in place.
