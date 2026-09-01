---
element: E98
slug: honest-crossing-table
title: Honest crossing table: implement `nb-read-key` as a real raw read (ti-bnew + ti-bptr + `read(0,ptr,n)` + return cell, matching `nb-sys-read-t`); retire `nb-read-keyseq`/`nb-sys-spawn`/`nb-null-port`/`nb-sys-env-get` stubs — remove externs (ports.chiral), wraps rows (crossing-wraps.chiral), sys-lib entries (sys-tal.chiral), sys-rows (target-linux.chiral); scriba key-sequence assembly moves to its pure key-parser
kind: BUILD-PROPER
example: examples/E98-honest-crossing-table.md
status: audited
updated: 2026-08-09
---

# E98 SPEC — Honest crossing table

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `nb-read-key` is a real raw `read(2)` crossing that allocates a
  fresh cell, takes its raw pointer via `ti-bptr`, issues `read(fd, ptr, n)`, and
  returns the cell — byte-identical shape to `nb-sys-read-t` (sys-tal.chiral:39-57).
  Five lying rows are **deleted** from every table: `nb-read-keyseq`, `nb-sys-spawn`,
  `nb-null-port`, `nb-sys-env-get` (wrappers + wraps rows + externs) and
  `nb-sys-mremap` (orphan sys-row in target-linux.chiral only — no wrapper ever
  existed). Scriba's pure `key-parser.chiral` already owns `Key`/`KeySeq` parsing;
  the removal of `read-key-sequence`/`read-keyseq` is a delete-only delta on the
  crossing layer — zero parser changes needed.

- **Non-goals:** new `Key` constructors (the parser's sum is adequate for S4);
  `Keymap`/`KeySeq` relocation (they stay in `ports.chiral` as surface types the
  parser imports); raw-mode termios setup (already covered by `term.chiral`
  `RawR`/`TermiosR`); a port-parameterised terminal face (S12(a) deferred — see
  §3); streaming partial-escape handling (parser already returns position — caller
  threads it).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** BUILD — E98 postdates the map snapshot. No prior
  conformance rows to reconcile.
- **Live code this change composes with:**
  - `scaffold/lib/sys-tal.chiral` — `nb-sys-read-t` at :39-57 (the GOLDEN IDIOM
    to copy: `ti-bnew` fresh cell → `ti-bptr` raw pointer → `ti-sys read` →
    branch on count → return cell). The five stub wrappers to delete at
    :455-492. The `sys-lib` cons chain at :494-505.
  - `scaffold/lib/crossing-wraps.chiral` — the `crossing-wraps` list
    (:13-33): five entries to delete, one entry (`"read-key" → "nb-read-key"`)
    to keep with a retyped extern.
  - `scaffold/lib/ports.chiral` — `read-key` extern at :150 (current face:
    `(=> Unit Key)`, changes to `(=> I64 I64 Bytes)`); `read-key-sequence` at
    :151, `null-port` at :149, `env-get` at :99, `spawn` at :88 — all five to
    delete. `Key`/`KeySeq`/`Keymap` data types at :138-148 stay (the parser
    imports them).
  - `scaffold/lib/target-linux.chiral` — `nb-sys-mremap` orphan sys-row at :18
    (points at a wrapper that does not exist).
  - `scaffold/lib/scriba/key-parser.chiral` — 237-line pure parser already
    exists: `parse-key` at :197, `parse-single-byte` at :36, `parse-csi` at
    :140, `csi-dispatch-ansi` at :93, `csi-dispatch-dec` at :104. Imports
    `ports` for the `Key` type. ZERO changes needed — it already consumes raw
    `Bytes` and returns `(Maybe Key)`.
- **True delta:** one TAL wrapper body rewrite (`nb-read-key-t`: replace the
  broken `read(fd,cell,0)` no-`ti-bptr` stub with the `nb-sys-read-t` idiom,
  changing arity from 1→2 params); five deletions × 3 layers (wrappers + wraps
  rows + externs) + 1 orphan sys-row delete; one extern retype
  (`read-key: (=> Unit Key)` → `(=> I64 I64 Bytes)`).

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | S12(b): retire `nb-read-keyseq`/`nb-sys-spawn`/`nb-null-port`/`nb-sys-env-get` stubs + orphan `nb-sys-mremap`? | RESOLVED | Author ratified 2026-08-09: honest form is deletion — no extern, no wraps row, no wrapper, no sys-row. S12b RESOLVED ack'd. |
| 2 | S12(a): `nb-read-key` signature — `(=> I64 I64 Bytes)` (fd + count) vs port-parameterised `(=> (1 p TermPort) I64 Bytes)`? | RESOLVED → `(=> I64 I64 Bytes)` | Mirrors the existing `(extern read (=> I64 I64 Bytes))` pattern (ports.chiral:95). The port-parameterised face (`TermPort` capability) is deferred — it requires a new port type + termios binding, which is scriba architecture territory, not crossing-table honesty. This run does the minimum honest delta: real `read(2)` with explicit fd + count. |
| 3 | Should `nb-read-key` delegate to `nb-sys-read` or have its own body? | RESOLVED → own body | The example explicitly says "replace the body with the `nb-sys-read-t` idiom." Delegation via `ti-call` to `nb-sys-read-t` would require the wrapper to be in `sys-lib` at B1 build time and adds an intermediate call. Own body is simpler, proven (the idiom is already verified in `nb-sys-read-t`), and the crossing-wraps entry maps `"read-key"` → `"nb-read-key"` directly — no re-routing needed. |
| 4 | `parse-keys` streaming — return unconsumed-bytes tail vs assume whole sequence per read? | RESOLVED → already handled | `key-parser.chiral` `parse-key` returns `(Pair (Maybe Key) I64)` with the new cursor position. The caller (command-loop) threads the position through successive calls. No streaming redesign needed — the parser already supports partial consumption. |

All decisions RESOLVED. Zero NEEDS-AUTHOR blocks.

## 4. Change plan (ordered, commit-sized)

### Step 1 — Delete five orphan/stub entries from `crossing-wraps.chiral`
- **Target:** `scaffold/lib/crossing-wraps.chiral` — the `crossing-wraps` list (:13-33)
- **Change:** Remove five `(cons (pair …) …)` entries from the list:
  `"env-get"` (:24), `"spawn"` (:26), `"null-port"` (:27),
  `"read-key-sequence"` (:28), `"mremap"` (:32). Keep `"read-key"` (:29) —
  it stays, pointing at the now-honest `nb-read-key`. Adjust the closing parens
  count: 5 fewer cons entries = 5 fewer close-parens.
- **Size:** ~S

### Step 2 — Retype `read-key` extern + delete four retired externs from `ports.chiral`
- **Target:** `scaffold/lib/ports.chiral`
- **Change:**
  - Retype `read-key` (:150): `(extern read-key (=> Unit Key))` → `(extern read-key (=> I64 I64 Bytes))` — fd + count args, raw `Bytes` return.
  - Delete `null-port` (:149), `read-key-sequence` (:151), `env-get` (:99), `spawn` (:88) — four extern lines.
  - `Key`/`KeySeq`/`Keymap` data types (:138-148) and `Port` (:137) stay — the parser imports them.
- **Size:** ~S

### Step 3 — Replace `nb-read-key-t` body, delete four stub wrappers, update `sys-lib` in `sys-tal.chiral`
- **Target:** `scaffold/lib/sys-tal.chiral`
- **Change:**
  - **Replace** `nb-read-key-t` (:477-483): change arity from 1→2 params (`(ti-fn "nb-read-key" 2 11)`), replace the broken `read(fd,cell,0)` body with the `nb-sys-read-t` idiom (:39-57) — `ti-bnew` fresh cell of `n` bytes → `ti-bptr` raw pointer → `ti-sys 0 read(fd, ptr, n)` → branch on returned count → return cell (or empty cell on EOF/short-read).
  - **Delete** `nb-sys-env-get-t` (:455-461), `nb-sys-spawn-t` (:465-468), `nb-null-port-t` (:471-474), `nb-read-keyseq-t` (:486-492) — four stub defs.
  - **Update** `sys-lib` (:494-505): remove `nb-sys-env-get-t`, `nb-sys-spawn-t`, `nb-null-port-t`, `nb-read-keyseq-t` from the cons chain. `nb-read-key-t` stays (now honest). Adjust close-paren count: 4 fewer cons entries.
- **Size:** ~M (TAL body rewrite + paren counting)

### Step 4 — Delete orphan `nb-sys-mremap` sys-row from `target-linux.chiral`
- **Target:** `scaffold/lib/target-linux.chiral` — the `linux-syscalls` SysReg (:11-33)
- **Change:** Remove `(cons (sys-row "nb-sys-mremap" 25) …)` from the cons chain (:18). Adjust close-paren count: 1 fewer cons entry.
- **Size:** ~S

### Step 5 — Verify fixpoint + test suite
- **Target:** B1 rebuild via `chirality/build.sh`, then `chirality test` in `chirality`
- **Change:** No source edits — verification only.
- **Size:** ~S (command-only)

## 5. Conformance gate

- **Golden behavior:**
  1. `nb-read-key` on stdin fd 0 returns the actual bytes typed into a fresh
     cell (differentially vs the py oracle's `read`), byte-identical to the
     `nb-sys-read-t` path for the same fd + count. The cell is wrapper-allocated
     (`ti-bnew`) and kernel-written (`ti-bptr` + `read(fd, ptr, n)`); no
     surface value is aliased.
  2. After removal, a program referencing any of the five retired symbols
     (`read-key-sequence`, `spawn`, `null-port`, `env-get`, `nb-sys-mremap`)
     fails **at check time** (unbound symbol / extern not found), not at
     runtime with a lying sentinel.
  3. The full test suite stays green with the five rows gone from every table
     (crossing-wraps, ports.chiral, sys-tal.chiral, target-linux.chiral). Scriba's
     `key-parser.chiral` continues to import `ports` for `Key` and parse
     normally — the parser was never coupled to the retired crossings.
  4. `parse-key` decodes `\x1b[A` → `(some k-up)` and a lone `\x1b` → `null`
     (caller handles the `pos` return for streaming) as a pure total function
     — unchanged from current state.

- **Tests to add:**
  - `test_e98_read_key`: differential test — `nb-read-key(0, 1)` vs py oracle
    `read(0, 1)`, same bytes returned, cell-allocation path matches
    `nb-sys-read-t` for count=1.
  - `test_e98_retired_symbols_unbound`: verify that each of the five retired
    symbols (`read-key-sequence`, `spawn`, `null-port`, `env-get`,
    `nb-sys-mremap`) is absent from ports.chiral, crossing-wraps.chiral,
    sys-tal.chiral, and target-linux.chiral. Verify that a blob referencing any
    fails at check time.
  - `test_e98_fixpoint`: B1 self-compile fixpoint holds (B1 byte-identical
    after rebuild). The retired symbols were never called by B1's own compile
    path, so the fixpoint should be a no-op delta.

- **Green line:** 726 → ≥ 729; `chirality test` full suite green; `chirality test-native`
  passes. B1 fixpoint holds.

- **Done when:** `nb-read-key` reads actual bytes from stdin into a fresh cell
  (verified differentially against py `read`), all five retired symbols are
  absent from every table, `chirality test` is green, and B1 fixpoint holds.

## 6. Residue & links

- **Deliberately unbuilt:**
  - Port-parameterised terminal face (`(=> (1 p TermPort) I64 Bytes)`) —
    deferred to scriba architecture (decision #2). The explicit `(fd I64)`
    parameter is honest and sufficient for S4.
  - `spawn` real implementation — retired here, not rebuilt. Its honest form
    is deletion. When scriba needs process spawn, it will be a NEW catalog
    element with a proper spec.
  - `null-port` real implementation — retired here. Same logic: deletion is the
    honest encoding of "not built."
  - `env-get` real implementation — retired here. The cap-gated successor
    `env-view` already exists in `ports.chiral` (:127).
  - `mremap` real implementation — the wrapper never existed (orphan sys-row
    only). When arena growth needs mremap, it gets its own E#.
  - `Key` constructor set expansion (`k-fn`, `k-home` already exist; mouse
    events deferred) — parser sum is adequate for S4.
  - The `read-key` extern no longer returns `Key` — it returns raw `Bytes`.
    The caller threads through `parse-key` (already exists in key-parser.chiral)
    to get `(Maybe Key)`. The membrane split (effectful byte acquisition vs pure
    parsing) is now enforced by the types.

- **Follow-on:** E98 unblocks honest scriba input — the command-loop can call
  `read-key` to get raw bytes, then `parse-key` to decode. The three-misdiagnosis
  cascade in `.planning/SCRIBA-UNBLOCK-MAP.md` (broken stubs masquerading as
  working crossings) is resolved.

- **Related:** [[E97-skip-chain-diagnostics]] (boundary-sum exemplar),
  [[pattern-boundary-sums]] (standing directive), effect membrane (`->` vs `=>`),
  `nb-sys-read-t` crossing idiom (sys-tal.chiral:39-57),
  `.planning/SCRIBA-UNBLOCK-MAP.md` (the misdiagnosis cascade this fixes).
