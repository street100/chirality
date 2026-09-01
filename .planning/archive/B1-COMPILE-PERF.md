> **ARCHIVED 2026-09-01. Superseded by `docs/benchmarks/test-suite-wall-clock.md`, which is TRACKED and carries the measured-range method this file wanted, and by `.planning/BUILD-ORDER.md` for the per-phase attribution.** The E100 correctness sibling is a separate concern and is unaffected. Any re-measurement starts from the tracked note, not from here: every path below is pre-migration.

# B1 compile-time performance — refined asks (a standalone lane) — **⚑ CLOSED**

> **⚑ LANE CLOSED 2026-08-16 (Ask 0 — measured, then re-verified directly at 0.358 s).**
> **There is no compile-time problem.** The scriba tree compiles in **~0.36 s**, not
> minutes; the "4–6 min" figure below (§0) was a **thrashing-sandbox artifact** — an
> fd-exhausted/degraded ccbox microVM inflating a sub-second compile. On a healthy
> sandbox B1 is fast; the dominant pass is codegen (`emit-elf`+`lower` ~55–63%), and
> `closconv`/`$apply` is a 10–15% minority (hypothesis REFUTED). Asks 1–3 below are
> UNMOTIVATED and E100 (lane D) is **not** fused with any speed work. This doc is kept as
> the record + the **re-measure recipe** (see the Ask 0 result section) if a genuine
> slowdown ever recurs — but first check sandbox health (`MemAvailable`, fd count).
>
> ~~**Started 2026-08-16.** Goal: make the two slow blobs in the tree — scriba and B1's
> own source — compile in seconds instead of minutes.~~ (Premise refuted — see above.)

## 0. The evidence (measured 2026-08-16, this session)

Full B1 compile times, native (zero CPython — B1 is a 1.0 MB ELF, the self-hosted compiler):

| blob | size | fn-typed density | compile |
|---|---|---|---|
| tiny (pure arithmetic) | 90 KB | ~0 | **0.071 s** |
| manas-run (whole engine) | 247 KB | low (`foldl`, avoids `map-list`) | **<1 s** |
| **scriba** | 544 KB | **188 `(=>`-typed dispatch/closure sites** | **~4–6 min** |
| B1's own source (`blob.chiral`) | 563 KB | compiler-dense | ~similar |

> **⚠ §0 IS DEBUNKED (see the top banner + Ask 0 result).** The scriba/compiler "~4–6
> min" rows above were **sandbox-thrash artifacts** — re-measured on a healthy sandbox,
> scriba compiles in **0.358 s** and the compiler blob in ~0.6 s. There is no super-linear
> blow-up. The table is retained only to show what the wrong figures were. What follows in
> §1–§3 was written under that false premise; the Ask 0 result section is the correction.

## 1. The pass pipeline (where the time goes)

`compile-front` (`compile-front.chiral:280`, `Str -> FR`) runs, in order:
1. `load-source` — parse → elaborate → typecheck (`parse.chiral`)
2. `specialize-singletons` (`specialize-singleton.chiral`) — monomorphize singleton vtables
3. **`closconv-sig` (`closconv-driver.chiral` → `closconv.chiral`, 1224 lines) — defunctionalize HO defs; this is the `$apply` machinery**
4. `bridge-sig` / peel → `tal-erase.chiral`
5. `lower` (`lower.chiral`, 407) → `emit-elf` (`emit-core.chiral` 573, `compile-emit.chiral`)

**Hot-pass suspicion (to be confirmed by profiling, Ask 0):** `closconv.chiral` — it's the
biggest module, it runs over every higher-order def + fn-typed site (scriba has 188), it
holds **24 linear-scan list ops** (`assoc`/`elem`/`find`/`filter` over growing lists →
O(n²) when the environment/seen-set is a list), and grep found **no memoization**
(`memo`/`cache`/`seen`/`visited`) anywhere in `closconv`/`lower`/`emit-core`. The "needs
`ulimit -s unlimited`" deep recursion is unmemoized — the same subterms get re-walked.

## 2. Ask 0 — PROFILE FIRST (the gate; do this before any optimization)

Do NOT optimize on my suspicion. Instrument the driver to measure, on **one** scriba
compile:
- **Per-pass wall-clock** — deltas around `load-source`, `specialize-singletons`,
  `closconv-sig`, `bridge/tal-erase`, `lower`, `emit-elf` (`compile-all.chiral` /
  `compile-front.chiral` are the seams).
- **Counters** — # of `$apply` specializations generated; # of node-visits per pass; the
  max depth / size of the environment list that the linear scans walk.

Output: a per-pass breakdown that names the dominant pass. **This is one instrumented
heavy build** — cheaper than guessing wrong (which I already did once). Everything below
is contingent on what it shows.

## Ask 0 result (profiled this session) — hypothesis REFUTED; premise did not reproduce

**Headline: there is no perf problem to profile. The current committed B1 compiles the
full scriba tree in ~0.33 s, not 4–6 min.** The `closconv`/`$apply` hotspot hypothesis is
**refuted** — `closconv-sig` is a 10–15 % minority pass. The dominant cost is the codegen
back end (`emit-elf` + `back-program`/`lower`), and even that is tens of milliseconds.

**Mechanism.** No clock crossing is wired for compiler use: `time-mono`/`Clock` (E32) are
declared in `ports.chiral` but absent from `crossing-wraps.chiral`/`sys-linkage.chiral`, so
they don't lower — and the pure `->` passes couldn't hold a `Clock` cap anyway. So I used
**external stderr-line timestamping**: I temporarily inlined `compile-front`'s pure passes
into the effectful `compile-main` (`compile-all.chiral`) with a `trace` marker between each
(`trace` is a wired, unbuffered fd-2 write, one line per marker), rebuilt the compiler, and
timestamped each marker's arrival with `date +%s.%N` in a `while read` pipe. Force points
are exact: every pass result is `case`-scrutinised before its marker (sums directly;
`Sig` via `mk-sig`), and chirality is eager (no thunk/force/delay primitive exists), so each
timestamp is the true pass-completion instant.

**Output-invariance verified.** The instrumented compiler's ELF is **byte-identical** to
the uninstrumented control's on the compiler blob, and the committed B1 and the
instrumented B1 produce the **same 872 824 B scriba ELF**. Instrumentation added only
stderr prints; the success path (`emit-elf` → `put`) is untouched. (Throwaway: the
`compile-main` edit was reverted; nothing promoted, no fixpoint run.)

**Per-pass breakdown** (B1-inst, `ulimit -s unlimited`, healthy sandbox, MemAvail 3.3 GB):

| pass | scriba (548 713 B → 872 824 B ELF) | compiler blob (592 696 B → 1 012 088 B ELF) |
|---|---|---|
| load-source (parse+elaborate+typecheck) | 73.1 ms (22.0 %) | 123.9 ms (20.8 %) |
| specialize-singletons | 4.5 ms (1.4 %) | 24.0 ms (4.0 %) |
| **closconv-sig** (`$apply` defunctionalization) | **34.7 ms (10.4 %)** | **90.1 ms (15.1 %)** |
| bridge / tal-erase | 11.5 ms (3.4 %) | 25.9 ms (4.4 %) |
| **back-program / lower** | **93.8 ms (28.2 %)** | **168.9 ms (28.3 %)** |
| **emit-elf** | **115.4 ms (34.7 %)** | **163.5 ms (27.4 %)** |
| **total P0→P6** | **333 ms** | **596 ms** |

**Reading it.**
- **Dominant pass = the codegen back end**, not `closconv`: `emit-elf` (~35 % scriba /
  ~27 % compiler) + `back-program`/`lower` (~28 % both) = ~55–63 % of compile time.
- `closconv-sig` is 4th at 10–15 %. It *does* grow with closure density (34.7 → 90.1 ms
  ≈ 2.6× at similar input size), but from a small base and with no sign of the suspected
  super-linear blow-up — nothing remotely near minutes. The 24 linear-scan list ops are
  not a measurable bottleneck at current scale.

**Why the §0 "4–6 min" evidence didn't reproduce.** Two independent runs (committed B1
`time` = 0.375 s; instrumented B1 markers = 0.333 s) on a scriba blob that matches §0's
own 544 KB row (548 713 B, 236 `(=>` sites) both land at ~⅓ s and produce a valid 872 KB
ELF. The most likely explanation for §0's figure is a **degraded/thrashing sandbox** —
§0 and §4 both record an fd-exhaustion + refresh that same session, and the memory notes
record repeated OOM/thrash from stacked heavy jobs. A thrashing microVM can inflate a
sub-second compile into minutes without the compiler's asymptotics changing. (Ruled out:
wrong/too-small blob — sizes and the 872 KB ELF match; my instrumentation short-circuiting
work — byte-identical ELF to committed B1.)

**Consequences for the lane.**
- **Asks 1–3 are unmotivated as written** — there is no scriba/compiler compile-time
  problem on the current committed B1 in a healthy sandbox. Do **not** fuse a `closconv`
  speed rework with anything; the O(n²)-scan/`$apply`-intern work has no measured payoff.
- **E100 stays a pure correctness item** (the `$apply`/`map-list` lower-at-all gap), fully
  decoupled from speed. §5's "fuse D + Ask 1" option is **off** — the profile fingered a
  different area (codegen) *and* found no problem to fuse against.
- **If a real slow compile ever recurs, re-measure first** (this same mechanism, ~5 min
  of work) and check sandbox health (`MemAvailable`, fd count) before touching passes.
  Only *then*, if `emit-elf`/`lower` genuinely dominate a real slowdown, is Ask 3
  (residual O(n²) list/string ops in the back end) the place to look — not `closconv`.

## 3. Optimization asks (each contingent on Ask 0 confirming the pass)

- **Ask 1 — if `closconv`/`$apply` dominates (most likely):**
  - **1a. Kill the O(n²) scans.** Replace `closconv`'s linear-scan lookups (the ~24
    `assoc`/`elem`/`find` sites — env / seen-set as a list) with the AVL `Map` (E27,
    already in `collections.chiral`) → O(n log n).
  - **1b. Intern `$apply` specializations.** Cache generated apply-labels by
    `(fn-shape, type-args)` so the same specialization isn't recomputed/re-emitted per
    call-site. 188 fn-typed sites with repeated shapes → big win if they collapse.
- **Ask 2 — if the cost is the recursive walk:** add a **memo table** to the hot pass,
  keyed by node identity, so shared subterms are visited once (also relieves the deep
  stack that forces `ulimit -s unlimited`).
- **Ask 3 — if `emit`/`lower` dominates:** audit for residual **O(n²) list/string ops**
  (append-in-loop, concat-in-loop). One emit quadratic was already fixed to balanced
  concat (`4e7791b`); find its siblings. Replace with balanced concat / difference lists.

## 4. Guardrails — every change here is a rung-1-core change

- **Byte-identical output invariant (the safety net):** the optimized B1 MUST produce
  byte-for-byte identical ELF to the current B1 on the full test suite **+ scriba + the
  compiler's own blob**. This is a pure speed change — any output diff is a bug, full
  stop. Diff-check before trusting a run.
- **Self-host fixpoint per change:** new B1 compiles the compiler blob → B1′; B1′
  compiles the blob → B1″; assert `B1′ == B1″` byte-identical (it reproduces itself).
  Standard rung-1 fixpoint, one command.
- **Benchmark:** scriba compile wall-clock, before/after, is the metric. (`bin/scriba`'s
  compile step; ~4–6 min is the current baseline.)
- **Pace the compiles:** heavy builds stress the ccbox microVM's fds (this caused an fd
  exhaustion + refresh this session). One heavy compile at a time; never stack them.

## 5. Scope boundary vs E100 (they share a module)

E100 (the `$apply`/`map-list` residual = pickup lane **D**) is a **correctness** gap in
the SAME `closconv`/`$apply` machinery — it makes `map-list` over recursive-type fn-args
*lower at all* (today it fails `no emitted label $apply0`, forcing the `foldl`
workaround). This lane is **speed**, not correctness. They are distinct goals in the same
1224-line module, so the efficient play is: **run Ask 0's profile; if `closconv` is the
hotspot, do E100 (correctness) and Ask 1 (speed) as one `closconv` rework under one
fixpoint** — rather than paying two separate fixpoint cycles on the same file. If the
profile fingers a different pass, keep them separate.

## 6. Success metric

Target set **after** Ask 0 reveals the achievable ceiling. Aspiration: scriba from ~4–6
min → **under ~1 min** (or, more honestly, "restore sub-quadratic scaling in
closure/dispatch density"). No target is committed until the profile says what's real —
measure, then decide the machinery (the standing lesson: *measure churn before building
machinery*).

## 7. Relational anchors
- Slow blobs: `TUI/scriba/*` (the editor), `scaffold/build/blob.chiral` (the compiler).
- Passes: `compile-front.chiral`, `compile-all.chiral`, `closconv.chiral`,
  `closconv-driver.chiral`, `specialize-singleton.chiral`, `lower.chiral`, `emit-core.chiral`.
- Correctness sibling: **E100** (`.planning/LEDGER.md`, catalog row) = lane **D**.
- Precedent: the native-perf campaign optimized generated-code *runtime* (~1.4×/5–8× of
  gcc -O2); it never touched B1's own *compile throughput* — that's this lane.
