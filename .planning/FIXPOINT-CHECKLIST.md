# Fixpoint checklist — the path from the memory arc to the rung-1 keystone

> **Goal:** finish the A4 fixpoint (Stage1 B1 == Stage2 B2, byte-identical, zero
> CPython in either compile). The blocker was memory: the native self-compile's
> no-reclaim bump churns ~12 GB+ and OOMs. The memory-discipline arc (E81–E85,
> `.planning/MEMORY-DISCIPLINE-ARC.md`) fixes that at the root. **Critical path to
> the fixpoint = E81 → E82 → A4.** E83/E84/E85 are post-fixpoint optimization.
>
> Each slice runs the full pipeline (example → audit → spec → audit → implement),
> each independently committed. Legend: `[x]` done · `[~]` in progress · `[ ]` not started.

## Critical path (do these until the fixpoint holds)

- [x] **E81 — the `Alloc` policy seam + `alloc-bump`.** Value-heap allocation is a
      composable discipline (policy over the Mach ISA vocabulary), threaded
      orthogonally, seam collapsed by specialize.
      **DONE-WHEN:** full suite green + program-level byte-identity (seam-carrying
      compiler emits a given program byte-for-byte as before).
      ✅ 668 green + 3 seam tests; program-level byte-identity verified (new B1 vs
      old B1 → identical ELF); new B1 works (exit 42). Committed d6ad519.
      *(Note: the compiler's OWN bytes (B1) legitimately changed — its source grew
      by a module — so "rebuilt B1 == old committed B1" was a mis-specified gate;
      the real gate is program-level byte-identity, which holds.)*

- [x] **A4 unblock — kill the emit memory quadratic (`materialize`).** ✅ commit
      4e7791b. The E82 pre-run investigation found the actual A4 blocker: NOT the
      absence of regions, but `materialize`'s right-nested `bcat` — O(N·M), ~12-16
      GB for a 660 KB self-compile image over ~10⁴ chunks (the core trapped
      exactly here, in `nb-bcat`). Fixed to balanced concat O(N log M) (`bcat-all`
      over `mat-chunks`), pure + byte-identical (bcat is associative), no new
      primitive. Suite 671 green. **This was the cheap, certain unblock; the E82
      region machinery is NOT required to clear A4** (its copy-out is complex —
      cells aren't self-describing, so it needs type-directed copiers).

- [x] **A4 — THE FIXPOINT. ✅ ACHIEVED 2026-08-05.** `python3 tools/selfhost.py
      stage2` → **`FIXPOINT: B1 == B2 (byte-identical, 659681 bytes)`**, in **1 s**,
      **peak 0.1 GB** (was ~12 GB+ — the `materialize` fix was the whole blocker;
      E82 regions NOT needed). Verified deterministic + stable 3× (stage2 twice +
      an independent `B1 < blob > B2'` manual run, all byte-identical). B2 (the
      self-compiled compiler) itself compiles+runs a program → exit 42, so it is a
      working compiler. **Zero CPython logic in the stage-2 compile** (python only
      redirects fds; B1 native does 100% of the work). **The rung-1 keystone: the
      CPython interpreter is evicted from the compile path — B1 self-reproduces
      natively.**
      - **Operational note:** the native compiler needs a large stack (deep
        non-tail recursion in `mat-chunks`/emit — thousands of frames);
        `selfhost.py` sets `RLIMIT_STACK=infinity` (`unlimit_stack`). A manual
        `build/B1 < blob` segfaults under bash's default 8 MB stack — run with
        `ulimit -s unlimited`. (Latent fragility, not a regression — old
        `materialize` was equally deep; a tail-recursive `mat-chunks` would retire
        it, a future cleanup.)

- [ ] **E82 — `alloc-region` (CONDITIONAL — only if A4 still OOMs on cell churn).**
      Phase-scoped regions over the value heap: `region-enter` marks heapptr,
      `region-exit` resets it; each phase runs in a region, its live result copied
      out at the boundary. Adds a save/restore-`heapptr` primitive to `Mach`;
      `alloc-region` composes it (ISA-agnostic, drops into the E81 seam).
      **Complexity (from the pre-run):** cells are NOT self-describing (no pointer
      map), so the copy-out must be **type-directed** (`copy-fr`/`copy-br`), not a
      generic GC copy. Only build this if the measured post-quadratic-fix peak
      still exceeds available RAM.
      **DONE-WHEN:** self-compile peak drops to max single-phase working set;
      cross-discipline differential (region == bump output); suite green.

## Post-fixpoint optimization (NOT gates for A4 — do if budget/'til tight)

- [ ] **E83 — `alloc-reuse` (FBIP).** Linear drop→reuse in place (rides E8
      linearity; Perceus near-free). Kills the persistent tree-map insert churn.
      **DONE-WHEN:** cross-discipline differential (bump vs reuse = identical
      result, lower peak); suite green.
- [ ] **E84 — `alloc-dps` (destination-passing).** Emit builds the ELF buffer by
      filling a linear destination instead of copy-concat (`nb-bcat`).
      **DONE-WHEN:** cross-discipline differential; emit peak flat in output size.
- [ ] **E85 — per-phase / per-runtime composition + E38 size-grade.** The
      `(memory …)` profile clause extended to the value heap; the compiler's
      profile composes region front/back, dps emit, reuse maps; interpreted vs
      native differ by profile.
      **DONE-WHEN:** the compiler profile selects `{Mach}×{Alloc}` per phase;
      optionally E38 bounds each region statically.

## After the fixpoint holds (rung 1 remainder, already scoped elsewhere)

- [ ] **B' — pack the Python seed** (priv keeps it as oracle; pub strips it,
      keeps tests). `.planning/RUNG1-CHECKLIST.md` Phase B. Contingent on A4.

## Notes / discipline
- One slice at a time through the full pipeline; commit each verified slice.
- The strongest gate is the **cross-discipline differential**: same program under
  two disciplines → identical output, with the reclaiming discipline's peak
  bounded by live-set.
- Heavy jobs (stage1 ~375s, stage2 native) run ONE at a time; check free mem first.
