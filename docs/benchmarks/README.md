---
node: benchmarks
layer: navigation
status: draft
updated: 2026-09-02
---

# Benchmarks

Consolidated speed/scale measurements for chirality. Four docs live here:

- **[language-performance.md](language-performance.md)** — codegen/runtime speed:
  chirality-emitted native x86-64 vs `gcc -O2` on three micro-kernels
  (arith / bytesum / states). The native-perf campaign (closed 2026-08-02).
- **[test-suite-wall-clock.md](test-suite-wall-clock.md)** — the native
  behavioural suite's own cost: the measured range, the per-phase breakdown, the
  retirement of a "~4-minute budget" nobody ever measured, and the method for
  comparing two runs. ⚑ Every figure in it predates the 2026-08-31 migration and
  is not a baseline for the current tree.
- **[growing-allocator-scale.md](growing-allocator-scale.md)** — E91 growing
  allocator (reserve-commit arena): bump-allocation + on-demand `mprotect`
  doubling on a fixed 64 GiB `PROT_NONE` reservation, exercised from 16 MiB
  up to 32 GiB plus a deterministic hard-ceiling test.
- **[text-matcher-prose-lint.md](text-matcher-prose-lint.md)**: E173's
  partial-derivative matcher in `prog/prose-lint.prog` against the mawk tool it
  replaces, over 81 files / 609,872 B on 2026-09-02. ⚑ The native side measures
  **15.1x slower** (min-of-11, band 7.8x to 18.5x), allocates **1.11 GB** to scan
  610 KB, and is **OOM-killed** on the tree's default scope. Records the wall
  clock per the author's 2026-09-01 ruling; sets no bar.

## Shared conventions

These conventions apply to every figure in all four docs; they exist because this
project has a false-summit history and will not carry an unsourced number.

- **Every result cites host specs + a date.** Absolute timings do not travel
  across machines (virtualized guests, no CPU pinning); a number without its
  host and date is not a claim.
- **Honest-spread rule.** Report the real min–max *band*, not a cherry-picked
  best run. Where a point estimate carries run-to-run wobble, the band is the
  claim and the wobble is named (e.g. "~1.4× on compute, 5–8× on memory/branch"
  — never just the single best sample). Name the machine load with any ratio.
- **Checksum-as-exit-code for allocator/scale tests.** Each scale rung returns
  an independently-predicted checksum as its process exit code, so a *wrong
  value* (silent corruption from a bad grow) is caught as a distinct failure
  from a crash signal (137 OOM-kill, 139 SIGSEGV, 132 ud2 trap, 1/2 clean
  arena-fail). PASS means the exit code equalled the prediction.
- **Anti-fold discipline for speed tests.** Inputs arrive at runtime (argv),
  results flow into a volatile sink and are cross-checked for equality across
  sides, so a deleted or partially-evaluated kernel fails the equality check
  rather than posting a fake fast number.
- **Re-runnable where the harness exists.** Scripts are named per doc. Note
  that the codegen harness (`scaffold/bench/`) is **private-only** — it is
  stripped from the public mirror by `bin/make-public.sh`; these docs (under
  `docs/`) are the public record of its results.

*Authority for these docs is the private tree (`/workspace/chirality`);
they sync to the public mirror via `bin/make-public.sh`. Edit here.*
