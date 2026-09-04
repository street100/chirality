---
element: E151
slug: ord-dedup
title: **Give string comparison an owner** — the `string` module owns `str-cmp : (-> Str Str Ord)`, `str-lower`/`str-upper`, `str-trim`, `str-replace`, `str-pad`; the `string-utils.chiral` module as the owner (179 lines since E151a; was 39 — starts-with / strip-prefix / contains / split). Deliverable INCLUDES retiring the duplicates.
kind: BUILD-PROPER
example: examples/E151-ord-dedup.md
status: audited
updated: 2026-08-22
---

# E151 SPEC — give string comparison (and the text primitives) an owner

> ⚑ **TRIAGE 2026-09-04 — DONE-ALREADY.** 0 of 7 steps are executable at HEAD.
> `lib/prelude/string.chiral:209` carries `str-pad`;
> `lib/typing/row-infer.chiral:103` adopts `list-dedup-adj`. Bucket and
> evidence: `records/spec-tier-triage.md`. This file was not rewritten and its
> `status:` was not changed.

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.
>
> **Everything the change plan prescribes was executed end-to-end during this
> spec run** against a throwaway copy of `scaffold/lib/` in a scratchpad —
> nothing under `scaffold/`, `TUI/`, or `examples/` was touched. Each step below
> carries its measured verdict. Where a step was *not* measured it says so.
2026-09-04: the 2026-08-31 migration moved the tree out of scaffold/. The pre-migration paths kept here name no live directory.

## 1. Deliverable

- **After this runs:** `scaffold/lib/string-utils.chiral` is the sole definer of
  `str-cmp`, `str-contains`, `str-lower`, `str-upper`, `str-trim`, `str-replace`
  and `str-pad`; the seven surviving ad-hoc copies across `ty-cmp`, `row-infer`,
  `asm-reloc`, `compile-back`, `manas/core/match`, `manas/chatter/router`,
  `manas/core/flow` (plus the dead copy in `TUI/scriba/help.chiral`) are **deleted
  and replaced by `(import "string-utils")`**, the two surplus `(data Ord ())`
  re-declarations in `ty-cmp`/`row-infer` go with them, and
  `tools/ledger-lint/ledger-lint.py`'s `OWNERSHIP_BASELINE` is ratcheted down to match
  (`^\(def str-cmp ` 3 → **1**; `^\(data Ord \(\)` 4 → **2**), with **three**
  new entries pinned at **1** — `^\(def str-contains `, `^\(def str-lower ` and
  `^\(def str-trim `. (The SPEC first pinned only `str-contains`, which left §5's
  "Done when" clause for `str-lower`/`str-trim` mechanically unenforced —
  `check_l` fails only on growth past the baseline, `tools/ledger-lint/ledger-lint.py:507`, so a
  name with no entry is not watched at all.)
- **Non-goals:**
  - The **fourth `Ord`** (`TUI/samples/collections.chiral:156`) — an A3
    duplicate-module artefact, owned by **E155**. It is a **symlink** to
    `scaffold/lib/collections.chiral` (`ls -l`: `collections.chiral ->
    ../../scaffold/lib/collections.chiral`), *not* a hardlink — `ledger-lint.py`'s
    own comment at `:517` and the E155 catalog/ledger rows say "hardlinks", which
    is wrong; their mutation experiment proves *sharing*, and `ls -l` names the
    mechanism. Either way it is one file under two paths, so no content edit can
    lower the count and `data Ord` lands at 2, not 1.
  - **E154** (per-module label namespace). E151b *pays* the flat-namespace cost
    by hand, seven times; it does not remove the cost.
  - The **three** remaining **prefix-dodged** `str-contains` clones —
    `gate-contains` (`manas/core/gate.chiral:20`, comment `:16-19`), `str-has`
    (`manas/core/stop.chiral:15`, comment `:11-14`) and a *second* `str-has`
    (`manas/core/flow.chiral:266`, uncommented — audit-measured, the SPEC first
    counted two). They are not bare-name duplicates, the L ratchet does not see
    them, and the first two carry comments saying the prefix exists only to
    dodge the flat label space → home is **E154**.
  - Making `scaffold/build/resolve` accept **multiple roots** (see §3 #6).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E151 postdates the map snapshot. Treat as
  BUILD; the build-state facts below were measured directly during this run.

- **Live code this composes with — do NOT respec it:**
  - `lib/prelude/string.chiral` (179 lines, E151a, landed): `str-cmp` (:80)
    over `su-cmp-bytes` (:65), `str-lower` (:105), `str-upper` (:121),
    `str-trim` (:152) over `su-is-ws` (:129), `str-replace` (:175),
    `str-starts-with` (:10), `str-strip-prefix` (:15), `str-contains` (:22),
    `str-split` (:37). Internals all `su-`-prefixed (the E154 guard).
  - `lib/prelude/ord.chiral:14` owns `(data Ord () (lt) (eq) (gt))`;
    `string-utils.chiral:7` imports it precisely for that. `Ord` is **not** in
    E151b's scope as a thing to build — only as re-declarations to delete.
  - `tools/test/samples/e151_string_stdlib.prog` (113 lines) — E151a's
    runtime gate, exit 0 iff every case is right.
  - `tools/ledger-lint/ledger-lint.py:494` `OWNERSHIP_BASELINE` — the L ratchet
    (`:497`, "a shared name defined in N files has no owning module; N must never
    grow"). Lowering it is part of the deliverable, not a side effect.
  - **`bin/chirality-resolve.sh`** — `chirality_blob LIBDIR ROOT…`, post-order DFS over
    `(import "…")` with a shared visited set, pure shell, **no Python**. Already
    load-bearing in the repo: `bin/scriba:21` bootstraps the native resolver with
    it. This is the blob builder the change plan uses (§3 #6).

- **Measured census (Python file-walk, not `grep -r` — see §7):**

  | name | files | where |
  |---|---|---|
  | `(def str-cmp ` | 3 | `string-utils:80` (owner) · `ty-cmp:34` · `row-infer:35` |
  | `ar-str-cmp` / `cb-str-cmp` | 2 | `asm-reloc:79` · `compile-back:128` (prefix-dodged, same function) |
  | `(data Ord ()` | 4 | `collections:156` (owner) · `ty-cmp:16` · `row-infer:21` · `TUI/samples/collections:156` (E155) |
  | `(def str-contains ` | 3 | `string-utils:22` · `manas/core/match:19` · `TUI/scriba/help:198` |
  | `gate-contains` / `str-has` | **3** | `manas/core/gate:20` · `manas/core/stop:15` · `manas/core/flow:266` (prefix-dodged, same function; the flow copy was missed in the first census — audit-measured) |
  | `(def str-lower ` | 2 | `string-utils:105` · `manas/chatter/router:46` |
  | `(def str-trim ` | 2 | `string-utils:152` · `manas/core/flow:430` |
  | `(def str-pad ` | **0** | absent from the whole tree |

  Importers: `ty-cmp` — **none**. `row-infer` — `sig-driver.chiral` only.
  `asm-reloc` — `emit-core`, `alloc`, `mach`, `mach-listing`, `mach-x64`.
  `compile-back` — none in `lib/`; it is a compiler-blob **root**.
  `string-utils` — `TUI/scriba/render-str.chiral` and the E151a gate sample.

- **True delta:** eight source modules lose a definition and gain an import; one
  module (`string-utils`) gains `str-pad` and flips one argument order; one lint
  baseline drops. No new language capability — this is entirely an **ownership**
  change, which is what makes it verifiable by "the same programs still compile
  and still produce the same exit codes".

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|---|---|---|
| 1 | `str-pad` — in or out of E151b? | **RESOLVED — IN**, as its own purely-additive commit (**Step 5**; the decision first said "Step 6, last in the order", which contradicted §4 — Step 5 is `str-pad`, Step 6 is the coupled app-side unit and is last) | It is an *addition*, not a retirement, so it carries none of the fixpoint exposure of Steps 1–2 and cannot be sequenced-blocked by them. Putting it out would need a follow-on element; none exists, and minting one for a 15-line function would be a phantom dep (CLAUDE.md deferral rule). Catalog row E151 names it explicitly. |
| 2 | `str-contains` argument order: owner is `(needle s)`, `match.chiral:19` and `help.chiral:198` are `(haystack needle)` | **RESOLVED — flip the OWNER to `(haystack needle)`** | Haystack-first is the tree's settled convention, three ways: `prelude`'s `(extern str-find (-> Str Str I64))` is used as `(str-find s needle)` **inside the owner's own body** (`string-utils.chiral:24`); the owner's sibling `str-replace` is already `(haystack needle replacement)` (`string-utils.chiral:160`, in the `:159-165` header block); and both other definitions plus both prefix-dodged clones use haystack-first. The owner is the outlier against its own callee. |
| 3 | Does flipping #2 overturn `match.chiral:15-18` ("NOT imported from string-utils … (SPEC decision #3)")? | **RESOLVED — superseded by construction, not overridden** | That decision rests on two stated grounds: reversed arg order, and "importing it would double-define the name in a combined leaf blob". #2 removes the first; deleting the local def (rather than importing alongside it) removes the second. The decision's *conclusion* — don't import while both hold — is untouched; its premises stop holding. Nothing in it is reversed. |
| 4 | Atomic or incremental? | **RESOLVED — incremental, but in three coupled groups, not eight independent commits** | The constraint is per-blob. Measured: `asm-reloc`+`compile-back` convert together in the compiler blob and self-reproduce; `ty-cmp` and `row-infer` never co-occur (no common importer) and convert independently. **But the app-side is genuinely coupled**: `match`, `router` and `flow` all land in the `manas/chatter/turn` blob, so importing `string-utils` into *any one* of them collides with the other two's local defs. Measured verdict from adding the import to `match.chiral` alone: `duplicate label (an object def collides with the linked runtime): str-trim`. Those three are therefore ONE commit. |
| 5 | Does lowering the `data Ord` baseline need E155 first? | **RESOLVED — no; E151b's own target is 4 → 2** | `collections:156` is the owner's and stays; the fourth is `TUI/samples/collections.chiral`, an A3 **symlink** copy owned by **E155**. Sequencing is unnecessary — the two ratchets overlap by one file, which `tools/ledger-lint/ledger-lint.py:489-491` already records as honest rather than double-counted. |
| 6 | How does a source edit to `asm-reloc`/`compile-back` reach `scaffold/build/blob.chiral`? (the brief's named unverified gap) | **RESOLVED — measured, and the premise it rested on was wrong** | `blob.chiral` is **not** hand-ordered. `scaffold/tools/selfhost.py:34-53` `build_blob()` is a post-order DFS over `(import …)` from five roots (`sys-linkage`, `compile-front`, `compile-back`, `compile-emit`, `compile-all`). `bin/chirality-resolve.sh`'s `chirality_blob` runs the identical algorithm in **pure shell, no Python**, and reproduces `blob.chiral` byte-for-byte for the same sources (verified; the only diff is that the committed local `blob.chiral` is **stale** — see §7). So the recipe is one line and placement is automatic; the example's "hand-ordered blob, placement is a live decision" is false for `blob.chiral`. |
| 7 | Should the blob be regenerated with the fully-native `scaffold/build/resolve` instead of the shell? | **DEFERRED — home: `.planning/HANDOFF-SELF-WIELD.md:68`** ("import-DFS in chirality (`lib/source-fs`) … full shell-resolver replacement") | Measured: `scaffold/build/resolve` is **single-root** — `printf 'sys-linkage\ncompile-front\n…' \| resolve` exits 1. The compiler blob needs five roots, so the no-Python path today is the shell `chirality_blob`, which `bin/scriba` already sanctions. This is a tracked remaining slice, not a phantom dep. |
| 8 | `ty-cmp` still imports `data.chiral` for a vestigial `Ty` skeleton (`data.chiral:13-14` flags it "for ty-cmp.chiral only") | **DEFERRED — out of scope, home: the `data.chiral:13-14` residue note itself** | Orthogonal to ownership; touching it changes what `ty-cmp` *is*, not who owns `str-cmp`. Converting `ty-cmp` was measured to work with the `data` import left in place. |
| 9 | The `test-runner` binary (`chirality test-native` Phase 2) embeds the compiler blob | **RESOLVED — no action; it is a prebuilt binary and keeps passing** | `scaffold/tools/build_test_runner.py:21` (the five `ROOTS`), `:23` (`ENTRY = 'test-main'`) and `:51-53` build it as *compiler blob + test-runner source*, through the **interpreted Python** front end. B1 only accepts `compile-main`, so there is no native rebuild path. Post-E151b the committed binary is stale-but-green: it exercises the samples through its own embedded compiler. Flagged as a known staleness, not a gate. |
| 10 | `test_string_utils.py:54-55` encodes `str-contains(needle, haystack)` | **RESOLVED — update in the same commit as #2** | The Python floor is **ADVISORY**, not gating (`bin/chirality test`, "python ADVISORY … does NOT fail the gate"), but leaving it wrong would be a silent lie in the oracle. One-line edit, same commit. |

No NEEDS-AUTHOR. `status: draft`, not blocked.

## 4. Change plan (ordered, commit-sized)

**Ordering rationale.** Steps 1–2 first because they are the only ones exposed to
the self-hosting fixpoint, and because they are the proof that the shelf module
is linkable inside the *shipping* compiler — everything after is cheaper if that
holds and pointless if it does not. Steps 3–4 next: leaf modules, each gated by a
single consumer blob, and each one lowers a ratchet (Steps 1–2 lower nothing —
they retire *prefixed* names the ratchet does not count). Step 5 is purely
additive, so it cannot break 1–4 and does not want to be entangled with them.
Step 6 last and alone: it is the only coupled multi-module commit and the only
one that changes a signature.

### Step 0 — establish the baseline (verification only, no commit)

```sh
cd /workspace/chirality
. bin/chirality-resolve.sh
ulimit -s unlimited
chirality_blob scaffold/lib sys-linkage compile-front compile-back compile-emit compile-all > /tmp/blob.chiral
./scaffold/build/B1 < /tmp/blob.chiral > /tmp/B1p && chmod +x /tmp/B1p
cmp /tmp/B1p bin/chirality-bin        # must be byte-identical BEFORE any edit
```
2026-09-04: pre-migration scaffold/ path.

**Measured 2026-08-22: identical (1 020 280 bytes).** `scaffold/build/B1` is
*current* with respect to `scaffold/lib/`; it is `scaffold/build/blob.chiral` that
is stale (see §7). Do not skip this — it is what makes the Step 1/2 gate mean
something. `scaffold/build/` is gitignored; regenerate, never commit.

### Step 1 — `asm-reloc` imports the owner
- **Target:** `lib/lowering/mach/asm-reloc.chiral`
- **Change:** add `(import "string-utils")` after `(import "collections")` (:10);
  **delete lines 66-80** — `ar-cmp-i64`, `(declare ar-cmp-bytes)` + `ar-cmp-bytes`,
  `ar-str-cmp`; rename the two call sites `ar-str-cmp` → `str-cmp` (:88 `offs->tree`,
  :93 `resolve-label`). Semantics identical: `su-cmp-bytes` and `ar-cmp-bytes` are
  the same byte-lexicographic walk, prefix-before-extension, `""` least.
- **Size:** S (−15 lines, +1 import, 2 call sites)

### Step 2 — `compile-back` imports the owner
- **Target:** `lib/lowering/compile-back.chiral`
- **Change:** add `(import "string-utils")` after `(import "collections")` (:18);
  **delete lines 115-129** — `cb-cmp-i64`, `(declare cb-cmp-bytes)` + `cb-cmp-bytes`,
  `cb-str-cmp`; rename the two call sites in `dedup-str` (:133, :135).
- **Size:** S (−15 lines, +1 import, 2 call sites)

### Step 3 — `ty-cmp` imports the owner
- **Target:** `lib/typing/ty-cmp.chiral`
- **Change:** add `(import "string-utils")` after `(import "data")` (:14);
  **delete** `:16` `(data Ord () (lt) (eq) (gt))`, and `:24-34`
  (`(declare cmp-bytes)`, `cmp-bytes`, `str-cmp`). **KEEP** `cmp-i64` (:18) and
  `then` (:21) — locals, still used at :42/:46/:47. Every `str-cmp` call site is
  unchanged (same name, same type, same semantics).
- **Also:** `tools/ledger-lint/ledger-lint.py` `OWNERSHIP_BASELINE` → `str-cmp: 2`, `data Ord: 3`.
- **Size:** S (−13 lines, +1 import) + 1 lint line

### Step 4 — `row-infer` imports the owner
- **Target:** `scaffold/lib/row-infer.chiral`
- **Change:** add `(import "string-utils")` after `(import "effects")` (:16);
  **delete `:21-35` entire** — `data Ord`, `cmp-i64` (decl+def), `cmp-bytes`
  (decl+def), `str-cmp`. Unlike `ty-cmp`, `cmp-i64` here has no other caller, so it
  goes too. The `str-cmp` call site at `:111` is unchanged. Leave the "lean leaf"
  comment's *substance* but retire the claim it justifies — the clash it names is
  `data.chiral`-vs-`closconv` under the sig-driver, which importing `string-utils`
  (→ `collections` → `prelude`) does not reintroduce; measured.
- **Also:** `OWNERSHIP_BASELINE` → `str-cmp: 1`, `data Ord: 2`.
- **Size:** S (−15 lines, +1 import) + 1 lint line

### Step 5 — `str-pad` joins the shelf
- **Target:** `scaffold/lib/string-utils.chiral` (+ `scaffold/tests/samples/e151_string_stdlib.chiral`)
- **Change:** add `str-pad` beside `str-replace`, with `su-`-prefixed internals per
  the module's E154 guard (`string-utils.chiral:51-55`). **Signature PINNED 2026-08-22 (audit FLAG-1 — decided, not
  delegated): `str-pad : (-> Str I64 Str Str)`, called `(str-pad s width pad)` —
  subject-first, RIGHT-pad.** Delegating it would reproduce the exact defect this
  element exists to remove: `str-contains` diverged because nobody pinned the
  convention. Subject-first matches decision #2's flip and the sibling
  `str-replace (haystack needle replacement)`; right-pad is the column-display
  default and the only in-tree consumer shape (scriba render rows). A `width` at or
  below `(str-len s)` returns `s`; an empty `pad` returns `s` (total, no loop).
  The module's own conventions also bind: ASCII/byte-level,
  total, structural on a shrinking or bounded index, and a header comment stating
  the convention the way `str-replace`'s does. Extend the gate sample with cases for
  pad-shorter (no-op), pad-exact, pad-longer, empty input, and a multi-byte pad unit
  if the signature admits one.
- **Size:** S–M (~20 lines + ~6 gate cases)

### Step 6 — the app-side coupled unit (one commit, not three)
- **Targets:** `scaffold/lib/string-utils.chiral`, `scaffold/lib/manas/core/match.chiral`,
  `scaffold/lib/manas/chatter/router.chiral`, `scaffold/lib/manas/core/flow.chiral`,
  `TUI/scriba/help.chiral`, `scaffold/tests/test_string_utils.py`, `tools/ledger-lint/ledger-lint.py`
- **Change:**
  1. `string-utils.chiral:22-25` — flip to `(lam (haystack needle) (<=i 0 (str-find haystack needle)))`
     and update the header comment (decision #2).
  2. `match.chiral` — add `(import "string-utils")`; **delete** `:19-20` and rewrite
     the `:15-18` note to say the copy was retired and why the old decision's
     premises lapsed. Call sites (`:51`) are already haystack-first → unchanged.
  3. `router.chiral` — add `(import "string-utils")`; **delete `:33-47`**
     (`lc-alpha`, `(declare str-lower-go)` + `str-lower-go`, `str-lower`). Call
     sites at `:93 :122 :200 :339` unchanged; `string-utils`' fold is the same
     ASCII 65..90 table map, length-preserving.
  4. `flow.chiral` — add `(import "string-utils")`; **delete `:410-430`**
     (`cr-str`, `pp-is-ws`, `trim-left` decl+def, `trim-right` decl+def,
     `str-trim`). **`cr-str` (:410) goes too — the range is `:410-430`, not
     `:411-430`.** The SPEC
     first said "KEEP `cr-str` — it is used elsewhere"; that is **false**, and the
     audit measured it: a tree-wide walk of `scaffold/**` + `TUI/**` finds `cr-str`
     at exactly two lines, `flow.chiral:410` (the def) and `flow.chiral:412` (inside
     `pp-is-ws`, which this step deletes). Keeping it would leave a dead top-level
     def in the module the element is de-duplicating. Deleting `:410-430` was
     compiled and run: `turn`/`divide`/`orchestrate` → 42, `flow-test` → 0,
     `turn-test` → 0, `e136_core` → 0, byte-identical stdout to the pre-change
     tree. Whitespace sets are
     *identical*: `pp-is-ws` = {space, tab, LF, CR} via `cr-str`, `su-is-ws`
     (`string-utils:129`) = `{32, 9, 13, 10}`. The `flow-test.chiral:216`
     "str-trim must not eat trailing r's" regression is therefore preserved by
     construction — `su-is-ws` compares codepoints and never sees a literal
     `"\r"`.
  5. `TUI/scriba/help.chiral` — delete `:198-200` and add `(import "string-utils")`
     beside `:12 (import "prelude")`. **The import resolves — measured, no hedge.**
     `scaffold/lib/scriba` is a symlink to `TUI/scriba`, the native resolver
     hardcodes `libdir = "scaffold/lib"` (`resolve.chiral:292`) and searches
     importer-dir-then-libdir-root (`resolve.chiral:179-191`, same rule as the shell
     `chirality_blob`), so a `scriba/`-resident module importing `string-utils` falls
     back to `scaffold/lib/string-utils.chiral`. Proof by an existing case:
     `TUI/scriba/render-str.chiral:17` already carries `(import "string-utils")` and
     `echo 'scriba/render-str' | ./scaffold/build/resolve` exits 0 with the
     `string-utils` body in the output. Separately measured: **nothing** in `TUI/`
     imports `help.chiral` (regex walk over every `TUI/**/*.chiral`), so the module is
     dead and this is hygiene, not a gated change.
  6. `test_string_utils.py:54-55` — swap the argument order (decision #10).
  7. `OWNERSHIP_BASELINE` — add `r"^\(def str-contains ": 1`,
     `r"^\(def str-lower ": 1` and `r"^\(def str-trim ": 1`. All three are at 1
     once this step lands (audit-measured against `check_l`'s own source set:
     `scaffold/lib/**` + `TUI/**` minus `scaffold/lib/scriba/`).
- **Why one commit:** measured — adding the import to `match.chiral` alone, with
  `router`/`flow` untouched, fails the `manas/chatter/turn` blob with
  `duplicate label (an object def collides with the linked runtime): str-trim`.
  All three modules are in that blob. There is no valid intermediate state.
- **Size:** M (−40 lines across 4 chirality modules, +4 imports, 1 signature flip,
  2 test/lint lines)

## 5. Conformance gate

- **Golden behavior.** "The same programs still compile and still produce the same
  exit codes, with one definition instead of N." Ownership is not observable at
  runtime, so the gate is *differential against the pre-change tree*: every blob
  that compiled before compiles after, with the same exit code, and the compiler
  still reproduces itself.

**Per-step gate — every command below was run during this spec run; the verdicts
are measured, not predicted.**

| Step | must compile | must run | must byte-compare |
|---|---|---|---|
| **0** | — | — | `B1(regenerated blob) == bin/chirality-bin` ✅ measured identical |
| **1** | regenerated compiler blob → `C1` | `printf '(def compile-main (-> I64 I64) (lam (n) 42))' \| C1` → ELF exits **42**; `C1 < g151 blob` → ELF exits **0** (**load-bearing — see the teeth note**) | `C1 < blob > C2`; `cmp C1 C2` **identical** ✅; **and** `C1 < <pre-change blob> == bin/chirality-bin` byte-identical ✅ (the cross-compiler differential: the new compiler re-emits the old compiler exactly) |
| **2** | same as Step 1 (both converted) | same | ✅ measured: `C1 == C2`, 1 024 376 bytes (+4 096 vs B1 — the whole shelf links in) |
| **3** | `{ chirality_blob scaffold/lib ty-cmp; echo '(def compile-main (-> I64 I64) (lam (n) 42))'; } \| B1` | ELF exits **42** ✅ | — (`ty-cmp` is not in the compiler blob). 2026-09-04: pre-migration scaffold/ path. |
| **4** | `{ chirality_blob scaffold/lib sig-driver; echo '(def compile-main …42…)'; } \| B1` | ELF exits **42** ✅ | — (`row-infer` is not in the compiler blob). 2026-09-04: pre-migration scaffold/ path. |
| **5** | `{ chirality_blob scaffold/lib string-utils; cat tools/test/samples/e151_string_stdlib.prog; } \| B1` | ELF exits **0** ✅ (pre-change baseline confirmed) | —. 2026-09-04: pre-migration scaffold/ path. |
| **6** | `manas/chatter/turn`, `manas/chatter/divide`, `manas/chatter/orchestrate`, `manas/core/flow-test`, `manas/chatter/turn-test`, and `{ chirality_blob scaffold/lib prelude manas/core/types manas/core/match manas/core/assemble manas/core/stop; cat tools/test/samples/e136_core.prog; }` | `turn`/`divide`/`orchestrate` → **42**; `flow-test` → **0**; `turn-test` → **0**; `e136_core` → **0** — all four ✅ measured **identical before and after** the conversion (audit re-ran the full three-import variant, not just the one-import probe) | —. 2026-09-04: pre-migration scaffold/ path. |
| **all** | — | `bash tools/test/run-tests.sh` (GATING); `python3 tools/ledger-lint/ledger-lint.py` clean | — |

- **Gate teeth — measured by mutation, not asserted.** Each claim below was
  produced by breaking the change on purpose and watching the gate:
  - Step 3 without the `(import "string-utils")` line → `B1` exits 1,
    `load: unknown name Ord`. The leaf gates catch a missing import. ✅
  - Step 6 with the import added to `match.chiral` **alone** → the
    `manas/chatter/turn` blob fails `duplicate label (an object def collides with
    the linked runtime): str-trim`. The coupling claim is real. ✅
  - Step 6 **without** decision #2's argument flip → `e136_core` exits **1**
    (`e136_core.chiral:64` asserts `(str-contains <assembled prompt> "the doc")`).
    The flip is genuinely gated. ✅
  - **The one measured blind spot:** replacing `str-cmp` with a *reversed but
    still total* comparator passes the Step-1/2 fixpoint (`C1 == C2`, same
    1 024 376 bytes), the exit-42 program, **and** the cross-compiler
    differential — because the comparator is only ever a `Map` ordering
    (`offs->tree`/`resolve-label`/`dedup-str`), and `dedup-str` preserves
    first-occurrence order regardless. The ONLY gate that catches it is the
    **`e151_string_stdlib` sample** (exits 1 on the reversed comparator, cases
    1..8 at `:52-68`). So Step 1's `g151` leg is not decoration — it is the sole
    semantic pin on `str-cmp`, and it must be re-run on Steps 5 and 6 too, since
    both edit `string-utils.chiral`.

- **After Steps 1–2, the fixpoint must be stated as `C1 == C2`, never against the
  committed `B1`.** `C1 ≠ B1` is *expected and correct*: the compiler's own source
  changed. What must hold is that the new compiler reproduces itself.

- **Tests to add:** Step 5 only (the `str-pad` cases in
  `tools/test/samples/e151_string_stdlib.prog`, native floor). Steps 1–4 and 6
  add none by design — the whole point is that behavior is unchanged, and the
  gate is the pre/post differential above. Floors compared: **native** (gating,
  every row of the table), **python** (advisory: `test_string_utils.py`,
  `test_ty_cmp_chirality.py`, `test_row_infer_chirality.py` — expect churn, do not gate),
  **rocq** (untouched).

- **Green line:** 709 test functions / 77 files in `scaffold/tests/` → **still
  709 / 77**. The `str-pad` cases land in
  `tools/test/samples/e151_string_stdlib.prog`, a native `.chiral` gate
  sample, not a Python test function, so the Python count does not move (an
  earlier "≥ 709 … carrying ~6 more cases" read as if it did); `run-native.sh` green;
  `python3 tools/ledger-lint/ledger-lint.py` clean **with the ratchet at**
  `str-cmp: 1`, `data Ord: 2`, `str-contains: 1`, `str-lower: 1`, `str-trim: 1`.
- 2026-09-04: pre-migration scaffold/ path.

- **Done when:** `^\(def str-cmp `, `^\(def str-contains `, `^\(def str-lower `,
  `^\(def str-trim ` each match exactly one file (`string-utils.chiral`),
  `^\(data Ord \(\)` matches two (`collections.chiral` + the E155-owned TUI copy),
  a freshly regenerated compiler reproduces itself byte-identically, and
  `run-native.sh` plus every blob in the Step-6 row exits as it did before.

## 6. Residue & links

- **Deliberately unbuilt:**
  - `TUI/samples/collections.chiral:156`'s `Ord` → **E155** (A3 duplicate-module
    **symlink** to `scaffold/lib/collections.chiral`, not a hardlink; `data Ord`
    stops at 2 until E155 lands).
  - `gate-contains` (`manas/core/gate.chiral:20`) and the **two** `str-has` copies
    (`manas/core/stop.chiral:15`, `manas/core/flow.chiral:266`) → **E154**; the
    first two are self-documented as prefix dodges for the flat emitted-label
    space, the `flow` one is undocumented.
  - The prefix dodges E151b *creates no more of* but also cannot remove — every
    `su-` internal in `string-utils` → **E154**.
  - Multi-root `scaffold/build/resolve` (so the compiler blob can be regenerated
    with zero shell as well as zero Python) →
    **`.planning/HANDOFF-SELF-WIELD.md:68`**, the tracked import-DFS-in-chirality slice.
  - `ty-cmp`'s vestigial `data.chiral` dependency → the residue note at
    `scaffold/lib/data.chiral:13-14`.
  - The stale `scaffold/build/test-runner` binary (decision #9) — regains currency
    only when a native custom-entry build path exists.

- **Follow-on:** none blocked *on* E151b. E154 and E155 each become one file
  smaller in scope once it lands.

- **Related:** [[E151-ord-dedup]] · [[E154]] (per-module label namespace — the
  mechanism that makes cloning cheaper than importing) · [[E155]] (multi-root
  module search path — owns the fourth `Ord`) · [[banks/module]] (why "standard
  library" is not a category here — a module is individuated by its type, not its
  subject) · [[E27]] (the ordered `Map` whose explicit `(-> K K Ord)` argument is
  what makes the comparator a shared *value*).

## 7. Measurement notes (read before re-measuring anything here)

- **`scaffold/build/blob.chiral` is STALE, `scaffold/build/B1` is NOT.** The
  regenerated blob differs from the committed one in exactly three hunks
  (+26 lines / +1 600 chars): the E147 `kept-tys` / `arm-rw-ctx` block in
  `closconv`, present in `scaffold/lib/` and absent from `blob.chiral`.
  `B1(regenerated blob) == B1` byte-identical; `B1(stale blob.chiral)` differs from
  `B1` at char 3040. **Any claim that "B1 is one generation stale" is an artifact
  of compiling the stale blob** — it inverts which artifact drifted. `scaffold/build/`
  is gitignored; both are untracked local files.
  **The example still carries the inverted claim** — `examples/E151-ord-dedup.md`
  §2 research finding 4 says "the committed `B1` differs from the binary it builds
  … i.e. `B1` is one generation stale", and calls the fixpoint a "B2-vs-B3"
  comparison. That is wrong on both counts and this SPEC supersedes it: re-verified
  during the SPEC audit, `B1(regenerated blob) == scaffold/build/B1` at exactly
  1 020 280 bytes, and `blob.chiral` carries **0** occurrences of
  `kept-tys`/`arm-rw-ctx` against `closconv.chiral`'s **8**. Fixing the example is
  outside a SPEC-level audit's write surface; flagged to the author.
- **`grep -r` into `TUI/` can silently return nothing** — every census in §2 was
  taken with a Python `os.walk`, not `grep -r`.
- **`stat` misreports inodes and link counts in this sandbox** — no claim here
  rests on `stat`. The `TUI/samples/collections.chiral` sharing fact is settled by
  `ls -l`, which names the mechanism directly: it is a **symlink**
  (`collections.chiral -> ../../scaffold/lib/collections.chiral`). So is **every**
  shared foundation module, in one direction or the other: `TUI/samples/{prelude,
  collections,grid}`, `TUI/scriba/{prelude,ports}` and `TUI/vt-core/prelude` are
  symlinks into `scaffold/lib` (or into `TUI/vt-core`), while `scaffold/lib/{apc,
  grid,session,utf8,vt-parser,render}.chiral` and `scaffold/lib/scriba/` are
  symlinks the other way, into `TUI/`. `ls -l` on all twelve: zero hardlinks. `tools/ledger-lint/ledger-lint.py:489-491` (and its `:515-522`
  comment, and the E154/E155 catalog + ledger rows) call them *hardlinks*; the
  mutation experiment they cite proves **sharing**, which a symlink satisfies just
  as well, so the mechanism claim is wrong even though the conclusion — one file
  under several paths, no drift through ordinary editing — is right. Correcting
  those docs is out of this SPEC's write surface; flagged to the author.
- **B1 needs `ulimit -s unlimited`** or it segfaults on any blob of size.
- Full loop cost, **re-measured during the SPEC audit** (the first figures were
  ~10x optimistic on the blob leg): blob regenerate ≈ **1.1 s**
  (`real 1.079s`), `B1 < blob` ≈ **0.7 s** (`real 0.689s`), `C1 < blob` ≈
  **0.66 s** — so a full regenerate + build + self-reproduce is ≈ **2.4 s**, not
  1.2 s. Still cheap; run it on every one of Steps 1–2 rather than batching.
