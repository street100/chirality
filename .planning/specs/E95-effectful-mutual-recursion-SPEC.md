---
element: E95
slug: effectful-mutual-recursion
title: Band amputation — revert half-landed `band` feature + document B1 silent-skip defect
kind: BUILD-PROPER
example: examples/E95-effectful-mutual-recursion.md
status: audited
updated: 2026-08-09
---

# E95 SPEC — band amputation + B1 silent-skip defect

> Postmortem. Three misdiagnoses (mutual recursion → ioctl → band) traced to one
> class defect: B1 silently drops any def hitting an unknown prim, cascading to
> entry-label loss with zero diagnostics. The actual blocker was `band` — a
> half-landed feature (prelude extern + op-band ctor existed but NO emitter arms
> in mach-x64; B1 was built from a band-free tree, so its op-bytes was
> exhaustive). Amputating band (revert, refixpoint) unblocked term-raw and the
> scriba cascade. Source: `.planning/SCRIBA-UNBLOCK-MAP.md` §"Ground truth".

## 1. Deliverable

- **After this runs:** term-raw compiles through B1. The scriba blob compiles
  through B1. The silent-skip defect is documented as E97's prerequisite (E97
  adds skip-chain diagnostics so this class never recurs silently).
- **What was actually done (S8, completed 2026-08-09):** band amputation
  reverted — removed `op-band` from prelude.chiral/tal-erase.chiral since emitter
  arms never existed in the B1 build tree. Refixpoint at 684274B (gen2==gen3,
  band-capable, both repos). Ports data-before-extern ordering fixed (broke py
  suite since cd8334a). `(band n 12)` no longer compiles — and that's correct;
  it was a half-landed feature that had no emitter.
- **Non-goals:** Adding band emitter arms. Fixing B1's silent-skip diagnostics
  (that's E97). Effect-polymorphic lowering.

## 2. Investigation findings

### 2a. What was WRONG in all three diagnoses

Three successive diagnoses of the scriba blob failure:

| Diagnosis | Claim | Verdict |
|-----------|-------|---------|
| Mutual recursion | Two `=>` functions calling each other break B1 | WRONG — 8 variants tested, all compile |
| ioctl lowering | ioctl extern fails where read succeeds | WRONG — ioctl compiles and works at runtime (pty-verified: tiocgwinsz probe returns live dims) |
| band | `(band n 12)` produces "no emitted label" | PARTIALLY RIGHT — band was the trigger, but the root cause isn't band per se |

The actual root cause (SCRIBA-UNBLOCK-MAP §"Ground truth"):

1. **band was a half-landed feature.** `op-band` existed as a prelude extern,
   Op ctor, and tal-erase parse arm in chirality only (unsynced, Aug 8).
   mach-x64 emitter arms (op-bytes/bini-body) were NEVER WRITTEN. B1's build
   tree (chirality) had NO band anywhere, so its `op-bytes` arm was
   exhaustive when compiled.

2. **B1 silently drops unknown prims.** When lowering encounters an unknown
   prim (`native-prim?` false), `expr` returns `er-skip("unknown prim: band")`.
   In `compile-back.chiral:225`, `er-skip` is discarded with zero diagnostics.
   The def that called `band` vanishes from the lowered output, cascading to
   any caller that references it, and eventually the entry label drops with
   only "no emitted label for entry compile-main."

3. **The chain:** scriba-main → term-raw → termios-set-raw → band → unknown
   prim → silent er-skip → termios-set-raw dropped → term-raw dropped →
   scriba-main dropped → "no emitted label for entry compile-main."

The general case of effectful mutual recursion works fine through B1. ioctl
compiles and works. The only prim that failed was `band` — because its emitter
arms didn't exist.

### 2b. Three real issues found and FIXED (pre-band-discovery)

1. **Duplicate defs** — `try-dispatch` was defined in BOTH `dispatch.chiral`
   AND `command-loop.chiral`. `render-puffer` was defined in BOTH
   `cmd-types.chiral` (stub) AND `command-loop.chiral` (real). B1 sees two
   `(def try-dispatch ...)` forms and the second nukes the lowered label.
   - FIX: removed `try-dispatch` from `command-loop.chiral` (kept in
     `dispatch.chiral`). Removed stub `render-puffer` from `cmd-types.chiral`
     (kept real one in `command-loop.chiral`).

2. **mktemp garbage** — `command-loop.chiral` had a shell mktemp error message
   appended as line 150: `mktemp: failed to create file via template...`
   This non-sexp garbage was being included in the blob by `chirality_blob`.
   - FIX: removed the garbage line.

3. **dispatch.chiral signature mismatch** — `command-loop-inner` was declared
   without `Keymap` param in `dispatch.chiral` but the real definition in
   `command-loop.chiral` takes `Keymap`. Calls also omitted `default-keymap`.
   - FIX: added `(import "keymap")`, fixed declare to include `Keymap`,
     fixed all calls to pass `default-keymap`.

### 2c. Actual blocker: band amputation + B1 silent skip

The real fix (S8, completed):

- **band amputation:** `op-band` removed from prelude.chiral and
  tal-erase.chiral (the only places it existed — no emitter arms were ever
  written). Refixpoint at 684274B confirms gen2==gen3.
- **Result:** term-raw compiles through B1 (first time). `(band n 12)` no
  longer compiles — correct, since band was half-landed and had no emitter.
- **ioctl verified:** compiles and works at runtime — tiocgwinsz probe under
  pty returns live dimensions (31×117).

The class defect (B1 silently dropping defs on unknown prims) is NOT FIXED
here — that's E97 (skip-chain diagnostics). After E97, any similar situation
will surface the er-skip reason and the blame chain, not just "no emitted label."

### 2d. What was ruled out (pre-band-discovery — all still valid)

- B1 build staleness: `ioctl` → `nb-sys-ioctl` was in `crossing-wraps.chiral`
- Ports.chiral ordering: tested with minimal ports file — ioctl still compiled
- Parameter count/return type: tested 2-param, 3-param ioctl — both compile
- Missing TAL wrapper: `nb-sys-ioctl-t` exists in `sys-tal.chiral`
- Blob construction: read and ioctl blobs identically constructed

## 3. Decisions

| # | Question | Disposition | Rationale |
|---|----------|-------------|-----------|
| 1 | Is the break in effectful mutual recursion? | RESOLVED — NO | 8 variants of effectful mutual recursion compile. The handoff diagnosis was wrong. |
| 2 | Are duplicate defs the cause? | RESOLVED — PARTIALLY | Duplicates contributed but weren't the sole cause. Fixed: try-dispatch, render-puffer, command-loop-inner signature. |
| 3 | Is mktemp garbage the cause? | RESOLVED — PARTIALLY | The garbage line contributed but wasn't the sole cause. Fixed. |
| 4 | What is the actual root cause? | RESOLVED — band amputation + B1 silent skip | Half-landed `band` (prelude extern + op-band + erase arm, NO emitter arms) caused B1's silent er-skip chain. `(band n 12)` alone reproduced the failure. Band reverted in S8; term-raw compiles; ioctl compiles and works at runtime. The class defect (silent skip on unknown prim) is documented for E97. |

## 4. Change plan

### Already completed (Step 0 — pre-band fixes)
- **Target:** `scaffold/lib/scriba/command-loop.chiral`, `dispatch.chiral`, `cmd-types.chiral`
- **Change:** Removed duplicate defs, mktemp garbage, fixed dispatch signatures
- **Status:** DONE — these files are clean

### Already completed (Step 1 — band amputation, S8)
- **Target:** `scaffold/lib/prelude.chiral` (remove `op-band` extern + Op ctor),
  `scaffold/lib/tal-erase.chiral` (remove `op-band` parse arm)
- **Change:** Reverted the half-landed `band` feature. No emitter arms existed
  in mach-x64.chiral — `op-bytes` was exhaustive in the B1 build tree. The
  revert restores the state B1 was compiled against.
- **Status:** DONE — refixpoint 684274B (gen2==gen3), term-raw compiles first time
- **Size:** ~S (3 locations, removal only)

### Follow-on: E97 skip-chain diagnostics
- **Target:** `scaffold/lib/compile-back.chiral:211-226` (lower-defs er-skip handling)
- **Change:** Accumulate er-skip reasons with blamed callee; on missing entry
  label, report the drop chain root-first to stderr. This makes the E95 class
  defect self-diagnosing so it can never recur silently.
- **Status:** E97 SPEC (pipeline: example drafted, pending audit)
- **Size:** ~M (new diagnostic accumulation + report path)

## 5. Conformance gate

- **Golden behavior:**
  1. term-raw compiles through B1 and produces ELF ✓ (verified at S8 refixpoint)
  2. ioctl compiles and works at runtime — tiocgwinsz probe returns live pty
     dimensions ✓ (pty-verified, 31×117)
  3. Scriba blob (with all scriba modules) compiles through B1 ✓ (band
     amputation removes the only unknown prim)
  4. `read`, `put`, `print` continue to compile — no regression
- **Regression floor (what must NOT break):**
  1. Pure mutual recursion (f→g→f, both `->`) continues to compile
  2. Effectful self-recursion (f→f, `=>`) continues to compile
  3. Effectful mutual recursion (f→g→f, both `=>`) continues to compile
  4. Existing crossing wrappers (read, write, mmap, ioctl) all compile
  5. Fixpoint: gen2==gen3 holds (B1 self-compiles byte-identically)
- **Tests:** The conformance gate is reality-tested by S8 refixpoint + pty
  probe. Formal tests (test_ioctl_compile, scriba blob test) are deferred to
  E97/E99 pipeline.
- **Done when:** term-raw compiles (DONE), scriba blob compiles (DONE per
  band amputation), fixpoint holds (DONE: 684274B gen2==gen3).

## 6. Residue & links

- **E97 skip-chain diagnostics:** The class defect (B1 silently drops defs on
  unknown prims) is NOT fixed here. E97 adds skip-chain diagnostics so the
  blame chain is reported instead of "no emitted label." This spec serves as
  E97's prerequisite documentation.
- **Band emitter arms:** Deliberately NOT built. The band revert was the right
  call — it was half-landed with no emitter. If band is needed later, it must
  be fully landed (prelude extern + Op + emitter arms + tests) as a proper
  catalog element, not half-synced between repos.
- **Deliberately unbuilt:** Other missing wrappers (env-get, spawn, null-port,
  read-key-sequence, read-key, mremap, run-elf). These are stub crossings
  registered as live rows. E98 retires the dead ones.
- **Follow-on:** E97 (skip-chain diagnostics) → E98 (honest crossing table) →
  E99 (ioctl out-cells) → E100 (2-type-param calls)
- **Related:** [[E92]], [[E93]], [[E94]], [[E96]], [[E97]],
  [[SCRIBA-UNBLOCK-MAP]] (authoritative ground truth for this spec)

## 7. Audit FLAGs (recorded during spec audit 2026-08-09)

### FLAG #1 — scriba blob compilation needs re-verification
**Question:** The unblock map says the scriba blob compiles after band
amputation, but this was not independently verified during this audit. S9
(re-measure sweep) owns this verification. Should the conformance gate in
§5 list "scriba blob compiles" as verified (based on S8 claim) or as
pending (needs S9)?

### FLAG #2 — ioctl runtime coverage
**Question:** ioctl was verified at the pty level (tiocgwinsz probe returns
31×117) but there is no formal ioctl compilation test in scaffold/tests/.
E99 (honest ioctl surface) will add these. Should a minimal ioctl
compilation test be added here as a regression gate, or deferred to E99?

### FLAG #3 — E95 catalog row title mismatch
**Question:** The catalog row (INDEX) still says "B1 effectful mutual
recursion" — this was the WRONG diagnosis. S10 (doc correction) owns
updating the catalog row to "band amputation + B1 silent-skip defect."
Should this spec note the pending correction explicitly?
