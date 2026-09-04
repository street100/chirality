---
element: E109
slug: bput-u16-le
title: `bput-u16-le`: little-endian u16 in-place writer in bytes-tal — inverse of the existing `bget-u16-le` reader, mirror of `bput-u32-le`/`bput-u8`
kind: BUILD-PROPER
example: examples/E109-bput-u16-le.md
status: audited
updated: 2026-08-12
---

# E109 SPEC — `bput-u16-le`: little-endian u16 in-place writer in bytes-tal — inverse of the existing `bget-u16-le` reader, mirror of `bput-u32-le`/`bput-u8`

> ⚑ **TRIAGE 2026-09-04 — DONE-ALREADY.** 0 of 2 steps are executable at HEAD.
> `lib/lowering/tal/bytes.chiral:628` carries `bput-u16-le`. Bucket and
> evidence: `records/spec-tier-triage.md`. This file was not rewritten and its
> `status:` was not changed.

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** one new surface `def bput-u16-le (-> Bytes I64 I64 Bytes)`
  exists in `lib/lowering/tal/bytes.chiral`, placed immediately after `bput-u8`
  (`:610`), mirroring `bput-u32-le` (`:596`): it packs a 16-bit little-endian
  value into a `Bytes` cell at a byte offset, length-preserving, returning a
  FRESH cell — the direct inverse of the existing `bget-u16-le` reader (`:585`).
  Today B1 reports `load: unknown name bput-u16-le`; after this it resolves and
  is callable, closing the writer-symmetry gap (readers for both widths + the
  u8/u32 writers already exist; only the u16 writer is missing).
- **Non-goals:** no true in-place TAL `nb-put-u16` primitive (a two-`ti-bput`
  store mirroring `nb-put-u32-t` at `:535`) — the surface splice is the mirror
  the catalog row names and is enough to close the gap (residue → §6). No
  rewrite of `pack-winsize` call sites (OPTIONAL follow-on, §6). No new
  out-of-range `off` validation policy (inherits `bslice`'s fault-on-`i>j`).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** BUILD (E109 postdates the CONFORMANCE-MAP
  snapshot — no rows name it; treat as a fresh build). Ledger row: `E109 =
  CG/byte-prims`, reference class `OURS` (the `bput-u32-le`/`bput-u8` idiom).
- **Live code this composes with (all built — do NOT respec):**
  - `pack-u16 (-> I64 Bytes)` — prelude extern, `lib/prelude/prelude.chiral:88`;
    lays down little-endian (low byte first). Its inverse `unpack-u16` is
    `:89`.
  - `bslice`, `bcat`, `blen` — the `Bytes` floor (`bslice` is
    `(cell, START, END)`, END exclusive, faults on `i>j`).
  - `bput-u32-le` — `bytes-tal.chiral:543`, the exact shape to mirror
    (prefix ++ word ++ suffix splice), carrying the load-bearing hazard comment
    at `:538-542`.
  - `bput-u8` — `bytes-tal.chiral:557`, the insertion neighbour.
  - `bget-u16-le` — `bytes-tal.chiral:532`, the reader this inverts; used as the
    round-trip witness in the gate.
  - `cell-new (-> I64 Bytes)` — `:523`, zeroed-cell constructor (used only by
    the OPTIONAL winsize residue example, not by the deliverable).
- **True delta:** exactly ONE new surface `def` in one file. No new TAL routine,
  no new `nb-*` body, no addition to `native-lib` (`:569`) — like its siblings
  `bput-u32-le`/`bput-u8`, `bput-u16-le` is a pure surface wrapper over existing
  primitives, not a native runtime routine. No import churn, no new module.

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Suffix END index: pass `(blen cell)` (an END index) vs. a length. | RESOLVED-with-citation | `bslice` is `(cell, start, END)`, END exclusive; passing a length is the E103 truncation bug. `bput-u32-le`'s own in-code comment (`bytes-tal.chiral:538-542`) fixes this: suffix MUST be `[off+2, blen)` with `(blen cell)` as the end. Mirror it exactly. |
| 2 | Boundary `off+2 == blen cell` (writing the last two bytes): guard it (like `bput-u8`) or not (like `bput-u32-le`)? | RESOLVED-with-citation | `i==j` is a legal empty slice; `bput-u32-le` (`:543-548`) uses NO guard and proves it (`bslice cell blen blen` → empty tail). `bput-u8`'s `cell-new` guard (`:562-565`) is historical over-caution, not required. Follow `bput-u32-le`: no guard. |
| 3 | Byte order (which byte at `off` vs `off+1`). | RESOLVED-with-citation | Fixed once by `pack-u16` (prelude extern, LE — `prelude.chiral:88`), which `bget-u16-le`'s `unpack-u16` inverts. `258 = 0x0102` → bytes `[0x02, 0x01]`. Not a convention between two functions. |
| 4 | Add a true in-place TAL `nb-put-u16` primitive? | DEFERRED (later perf call) | Out of scope; a fresh-cell surface splice is the deliverable. Home: a future performance element, not E109 (§6). |
| 5 | Rewrite `pack-winsize` (`term.chiral:48`) call site to use in-place writes? | DEFERRED (OPTIONAL follow-on) | Non-goal for this element; noted as residue (§6). The `pack-u16 + bcat` allocation idiom there (`term.chiral:50`) is the demonstrable win but is a separate change. |

No NEEDS-AUTHOR items. `status: draft` (unblocked).

## 4. Change plan (ordered, commit-sized)

### Step 1 — add the `bput-u16-le` surface def
- **Target:** `lib/lowering/tal/bytes.chiral` — new `def bput-u16-le`, inserted
  immediately after `bput-u8` (after `:610`), before `native-lib` (`:636`).
- **Change:** paste the example §5 def verbatim (mirrors `bput-u32-le` with two
  deltas: `pack-u16` instead of `pack-u32`, and `(+ off 2)` instead of
  `(+ off 4)` for the suffix start). Keep a short comment mirroring the
  `bput-u32-le`/`bput-u8` hazard notes (END-index-not-length; suffix end MUST be
  `(blen cell)`; no boundary guard needed since `i==j` is a legal empty tail):
  ```chirality
  (def bput-u16-le (-> Bytes I64 I64 Bytes)
    (lam (cell off val)
      (let (prefix (bslice cell 0 off))
        (let (word (pack-u16 val))
          (let (suffix (bslice cell (+ off 2) (blen cell)))
            (bcat prefix (bcat word suffix)))))))
  ```
- **Size:** ~S (one def + comment).

### Step 2 — round-trip verify + core-blob gate
- **Target:** a behavioral sample (Step 2 of §5) + the blob self-host cmp.
- **Change:** compile the sample with B1, run, assert exit 42; then run the
  core-blob cmp gate (§5). Reblob + promote only if B1 changes.
- **Size:** ~S (no source change beyond the sample).

Commit cadence: two commits — (1) the def; (2) the sample + gate evidence (the
def commit is self-contained and compiles; the sample commit carries the
behavioral witness). If the blob cmp shows a byte change, the reblob/promote
lands with commit (2).

## 5. Conformance gate

- **Golden behavior — round trip + boundary:**
  1. **Round trip:** `(bget-u16-le (bput-u16-le cell 0 258) 0)` = `258`; the
     written cell's first two bytes are `[0x02, 0x01]` (LE of `0x0102`); the
     cell length is unchanged and every byte outside `[off, off+2)` is
     untouched.
  2. **`i==j` boundary:** write the last two bytes of a 2-byte cell —
     `(bput-u16-le cell2 0 v)` where `off+2 == blen cell2` — yields a legal
     empty tail via `bslice cell2 2 2`, no fault.
- **Behavioral sample:** add `prog/samples/e109_bput_u16_le.prog`
  (compile+run, exit **42** on success — the repo's behavioral-witness
  convention). A round trip alone is NOT sufficient: reading back at offset 0
  returns the packed word regardless of a suffix off-by-one (which shifts the
  tail / changes length but leaves bytes 0–1 intact), and `pack-u16`/`unpack-u16`
  are inverses by construction regardless of byte order. So the exit-42 program
  MUST assert the full golden behavior at a NONZERO offset:
  1. Write `258` (`= 0x0102`) at a nonzero offset into a cell longer than
     `off+2` (e.g. `(bput-u16-le c 2 258)` on an 8-byte cell). Assert the two
     RAW bytes via `bget`: `(bget r 2) = 0x02` (low) and `(bget r 3) = 0x01`
     (high) — this is what catches byte order and confirms placement at `off`.
  2. Assert length preservation: `(blen r) = (blen c)` — catches a suffix
     off-by-one (`+ off 1`/`+ off 4`) which the round trip alone misses.
  3. Assert neighbors untouched: at least one byte below `off` and one at/above
     `off+2` retain their pre-write values — catches a prefix/suffix mistake.
  4. Round-trip witness: `(bget-u16-le r 2) = 258`.
  5. `i==j` boundary: the last-two-bytes write yields no fault.
  `exit 42` iff all hold. Compile with B1, run, check exit code — no Python in
  the path (per BUILD RULE). This is the differential floor: the native B1
  binary's runtime `pack-u16`/`unpack-u16`/`bslice` codecs, exercised end to end.
- **Core-blob gate (self-host):** `bytes-tal` is imported into B1's blob
  (`scaffold/build/blob.chiral:11948`). After Step 1, rebuild B1 from the blob
  and byte-compare against the committed binary:
  ```
  chirality_blob | B1 < blob | cmp - bin/chirality-bin
  ```
  (concretely: `../chirality/bin/chirality-bin < scaffold/build/blob.chiral > /tmp/B1.new
  && cmp /tmp/B1.new bin/chirality-bin`). Expected byte-IDENTICAL — `bput-u16-le`
  is an unreferenced surface def that B1 itself never calls, so a
  reachability-pruned blob should reproduce the same binary. **If it differs**
  (the blob pipeline retains the new def), that is acceptable: reblob + promote
  per `bin/make-public.sh`, then run the promoted binary over the same blob once
  more and byte-compare (`B2 == B1` fixpoint) — the committed tree must be the
  tree that built the committed binary.
- **Green line:** 704 test functions → ≥ 705 (the new sample). ledger-lint clean.
- **Done when:** the sample compiles under B1 and exits 42, AND the core-blob
  cmp is byte-identical (or, if it differs, the reblobbed B1 reproduces itself
  `B2==B1`).
- 2026-09-04: the 2026-08-31 migration moved the tree out of scaffold/. The pre-migration paths kept here name no live directory.

## 6. Residue & links

- **Deliberately unbuilt:**
  - True in-place TAL `nb-put-u16` primitive (two `ti-bput` stores, mirror of
    `nb-put-u32-t` at `bytes-tal.chiral:482`) — home: a later performance
    element, not E109. The fresh-cell splice is the deliverable.
  - Out-of-range `off` validation — home: nobody's yet; inherits `bslice`'s
    fault-on-`i>j`, deliberately not added.
- **Follow-on (OPTIONAL):** rewrite `pack-winsize` (`lib/protocol/term.chiral:48`,
  currently `(bcat (bcat (pack-u16 rows) (pack-u16 cols)) (pack-u32 0))` at
  `:50`) to write the two u16 fields in place into a `(cell-new 8)` zeroed cell
  (`rows@0`, `cols@2`; `xpixel@4`/`ypixel@6` stay 0) via `bput-u16-le`. Demonstrates
  the allocation win; separate change, gated on E109 landing.
- **Related:** [[E109-bput-u16-le]] (the drafted example — rationale),
  [[E103-bput-u32-le]] (the mirror + the `[i,j)`/`blen`-as-end hazard),
  the `bget-u16-le` reader it inverts, and T2 `pack-winsize` /
  `TUI/examples/T02-tiocswinsz.md` (the call-site that stops allocating).
