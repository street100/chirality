---
element: E87
slug: import-resolution
title: Import resolution — module bundler for B1
kind: SELF-HOST
example: examples/E87-import-resolution.md
status: audited
updated: 2026-08-07
---

# E87 SPEC — Import resolution: module bundler for B1

> ⚑ **TRIAGE 2026-09-04 — DONE-ALREADY.** 0 of 5 steps are executable at HEAD.
> `lib/module/resolve.chiral:366` carries `bundle`. Bucket and evidence:
> `records/spec-tier-triage.md`. This file was not rewritten and its `status:`
> was not changed.

> Implementation contract. Bridges the worked example into an executable change
> plan. An implementation run follows THIS file.

## 1. Deliverable

- **After this runs:** `lib/module/resolve.chiral` — a chirality-native module
  bundler (~120 lines). Given a libdir prefix and root module name, walks
  transitive `(import "...")` deps, deduplicates by basename, concatenates in
  dependency order. Produces a flat source blob for B1. Replaces
  `bin/chirality-resolve.sh` as the resolver in `build.sh` and `bin/scriba`.
- **Non-goals:** B1-internal import handling (the nested-pattern /
  forward-reference path from IMPORT-HANDLER-BRIEF.md — deferred to a future
  compiler slice). Qualified imports, public/private visibility, re-exports.
  Cycle detection as a user-facing error (cycles are silently deduped, same
  behavior as the shell resolver today).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** no rows for E87 (element predates the map
  snapshot). The element is SELF-HOST — the Python `surface.py load_file` and
  shell `chirality-resolve.sh` are the existing implementations to replace.
- **Live code this change composes with:**
  - `lib/sexp.chiral` — `read-all-str` (E1 reader, parses source to Sexp list)
  - `lib/ports/ports.chiral` — `openat`, `read`, `close`, `fd-write` (syscall surface)
  - `lib/prelude.chiral` — `Str`, `Bytes`, `List`, `Pair`, `Maybe`, `str-cat`,
    `str-eq`, `blen`, `bcat`, `bslice`, `bytes->str`
  - `lib/prelude/list.chiral:74` — `find`. The assoc-list operations moved to `lib/prelude/alist.chiral`, and `member` has no live successor under that name; `lib/prelude/set.chiral:17` owns `s-member`
  - `bin/chirality-resolve.sh` — the shell resolver (stays as bootstrap path)
  - `prog/scriba/resolve.chiral` — 54-line stub (file I/O helpers,
    skeleton entry point — the scaffolding this SPEC fleshes out)
- **True delta:** move the stub from `scriba/resolve.chiral` to
  `lib/module/resolve.chiral`, flesh out the dependency-walk core and the
  effectful driver, wire `build.sh` and `bin/scriba` to use the native
  resolver once it self-compiles (shell resolver stays as the bootstrap).

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Separate binary or linked into B1? | **RESOLVED — separate binary** | Kalyn pattern (bundler is a distinct phase). Linked-in-compiler needs the nested-pattern + forward-reference fixes from IMPORT-HANDLER-BRIEF.md — those are a separate compiler slice. Separate binary composes with B1 today via pipe. |
| 2 | Basename dedup or full-path dedup? | **RESOLVED — basename** | Matches current shell resolver behavior and Python `self.loaded` (which uses absolute paths but the shell resolver uses basenames). Full-path allows `lib/foo.chiral` and `app/foo.chiral` to coexist — that's a future concern (DEFERRED to E87-wave-2). |
| 3 | Where does `parse-imports` live? | **RESOLVED — inline in resolve.chiral** | Uses `read-all-str` from E1's sexp.chiral, then grep for `(import "...")` patterns. The import form is simple enough that a dedicated parser module is overkill. Same approach as the shell resolver's `grep -oP`. |

## 4. Change plan (ordered, commit-sized)

### Step 1 — Move and clean the stub
- **Target:** `lib/module/resolve.chiral` (new location),
  `prog/scriba/resolve.chiral` (remove)
- **Change:** Move the 54-line stub from the scriba debris dir to
  `lib/module/resolve.chiral`. The stub already has `file-read-all`,
  `file-open`, `nul-byte`, and the skeleton `main` entry. Remove the
  `(import "collections")` line (not yet needed). Keep imports of
  `prelude` and `ports`.
- **Size:** S (file move + 2 edits)

### Step 2 — Implement the pure core
- **Target:** `scaffold/lib/resolve.chiral` — new functions
- **Change:** Add `parse-imports` (uses `read-all-str` to get Sexp list,
  filters for `(import "...")` forms, extracts the module name strings).
  Add `walk-imports` (recursive graph traversal with a `seen` set of
  basenames, accumulates modules in dependency order). Add list helpers
  (`seen-insert`, `lookup-mod` stubs — these become real when the dependency
  graph is loaded). The pure core takes `(List Mod)` and a root name,
  returns ordered `(List Mod)` — no file I/O, testable without a filesystem.
- **Size:** M (~60 lines)

### Step 3 — Implement the effectful driver
- **Target:** `lib/module/resolve.chiral` — `bundle` entry point
- **Change:** `bundle` takes a libdir Bytes path and root module Str, opens
  the libdir via `openat`, calls the pure core, concatenates all module
  sources via `bcat` into one Bytes blob. Error handling: missing modules →
  `(res-err (re-not-found ...))`, read errors → `(res-err (re-read-err ...))`.
  The `compile-main` entry reads libdir from `env-get "CHIRALITY_LIBDIR"` and
  root from `env-get "CHIRALITY_ROOT"`, calls `bundle`, writes the blob to
  stdout via `fd-write 1`.
- **Size:** M (~50 lines)

### Step 4 — Wire into bin/scriba and build.sh
- **Target:** `bin/scriba`, `bin/chirality-resolve.sh` (unchanged — bootstrap path)
- **Change:** `bin/scriba` already uses the shell resolver via `source
  bin/chirality-resolve.sh` + `chirality_blob`. Once resolve.chiral compiles to an
  ELF, `bin/scriba` switches to piping through the native resolver.
  `build.sh` follows the same pattern: shell resolver bootstraps the native
  resolver, then the native resolver takes over for subsequent builds.
- **Size:** S (script edits)

### Step 5 — Conformance test
- **Target:** `scaffold/tests/test_resolve_chirality.py` (new)
- **Change:** Given `scriba/scriba-main` as root and `scaffold/lib` as
  libdir, the native resolver produces a blob byte-identical to the shell
  resolver's output (79,045 bytes). Test verifies: module count (13),
  dependency order (prelude before ports before term before scriba modules),
  byte-identical output.
- **Size:** S (~30 lines)
- 2026-09-04: the Python oracle was cut, and scaffold/ went with it in the 2026-08-31 migration. The citations it left are kept as a record and have no live successor.

## 5. Conformance gate

- **Golden behavior:** `resolve.chiral` compiled with entry `compile-main`,
  invoked with `CHIRALITY_LIBDIR=scaffold/lib CHIRALITY_ROOT=scriba/scriba-main`,
  writes a flat source blob to stdout. That blob, when piped to B1, produces
  a compilable ELF (no "unknown name" errors from B1 — type errors in scriba
  are a separate concern tracked in the scriba compilation checklist).
  The blob is byte-identical to `chirality-resolve.sh` output for the same root.
- **Tests to add:**
  - `test_resolve_chirality.py` — blob identity vs shell resolver
  - `test_resolve_dedup.py` — basename dedup (two modules with same basename,
    first wins)
  - `test_resolve_missing.py` — missing module produces clean error, not crash
- **Green line:** 702 → ≥ 705; `ledger-lint.py` clean.
- **Done when:** `bin/scriba` compiles scriba through the native resolver
  (no shell in the hot path), blob matches shell resolver byte-for-byte,
  B1 produces zero "unknown name" errors from the resolved blob.
- 2026-09-04: pre-migration scaffold/ path.

## 6. Residue & links

- **Deliberately unbuilt:**
  - Cycle detection as a user-visible error (DEFERRED — cycles are silently
    deduped, same as shell resolver today)
  - Full-path dedup (DEFERRED to E87-wave-2)
  - In-compiler import handling — the nested-pattern + forward-reference
    approach from IMPORT-HANDLER-BRIEF.md (DEFERRED to a future compiler
    slice; gated on parse-arm Pat type refactor)
  - `parse-imports` using a proper Sexp walker rather than regex — the
    current approach (grep for `(import "...")` patterns on stripped source)
    matches the shell resolver and is sufficient
- **Follow-on:** scriba compilation through real import resolution (unblocks
  the scriba build pipeline — currently blocked on type errors in
  command-loop.chiral, init-loader.chiral, scriba-main.chiral)
- **Related:** [[IMPORT-HANDLER-BRIEF]] (the in-compiler alternative),
  [[E51-sys-face-linkage]] (openat/read surface), [[E28-mmap-munmap]]
  (filesystem syscalls)
