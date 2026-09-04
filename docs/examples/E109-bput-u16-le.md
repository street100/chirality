---
element: E109
slug: bput-u16-le
title: `bput-u16-le`: little-endian u16 in-place writer in bytes-tal — inverse of the existing `bget-u16-le` reader, mirror of `bput-u32-le`/`bput-u8`
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: drafted
updated: 2026-08-11
---

# E109 — `bput-u16-le`: little-endian u16 in-place writer in bytes-tal — inverse of the existing `bget-u16-le` reader, mirror of `bput-u32-le`/`bput-u8`

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E109, a `bput-u16-le` writer that packs a 16-bit little-endian
  value into a `Bytes` cell at a byte offset, length-preserving, returning a
  fresh cell — the direct inverse of the existing `bget-u16-le` reader.
- **Kind:** BUILD-PROPER (a designed-but-unbuilt primitive; the reader half and
  both neighbouring writer widths already exist).
- **Why chirality needs its own:** the byte library must be symmetric. `bytes-tal`
  ships `bget-u16-le`/`bget-u32-le` readers and `bput-u8`/`bput-u32-le` writers,
  but no `bput-u16-le`. Every place that packs a u16 field into a struct
  (`struct winsize` in T2, escape-sequence params in T4) is forced to build a
  fresh cell with `pack-u16` + `bcat` instead of writing into an existing cell.
  Closing this gap makes offset-writing a struct uniform across widths.

## 2. Research

- **Reference class:** OURS — the existing `bytes-tal.chiral` idioms. Design from
  the two sibling writers (`bput-u32-le` at `:543`, `bput-u8` at `:557`) and the
  reader it inverts (`bget-u16-le` at `:532`). No external port source.
- **Key findings:**
  1. **Byte order is settled by the repo's own codecs.** `nb-pack16`
     (`bytes-tal.chiral:158`) stores `val mod 256` (the low byte) at index 0 and
     `(val / 256) mod 256` (the high byte) at index 1; `nb-unpack16` (`:193`)
     reads `byte[0] + 256 * byte[1]`. That is little-endian: least-significant
     byte at the lowest address — matching the general definition (LSB at the
     lowest address) and the x86-64 target chirality emits to. So `bput-u16-le` of
     `258 = 0x0102` must lay down bytes `[0x02, 0x01]`.
  2. **The shape to mirror is `bput-u32-le`.** prefix = `(bslice cell 0 off)`,
     the packed word = `(pack-u16 val)` (already a 2-byte LE cell), suffix =
     `(bslice cell (+ off 2) (blen cell))`, then `(bcat prefix (bcat word
     suffix))`. Semantically this is the two byte stores the catalog names —
     low byte at `off`, high byte at `off+1` — expressed as a splice; the
     `pack-u16` word already carries them in that order.
  3. **The `[i,j)`/length hazard is load-bearing.** Surface `bslice` is
     `(cell, start, END)` — the third argument is the exclusive END INDEX, not a
     length — and it FAULTS when `i > j`. The E103 `bput-u32-le` truncation bug
     was exactly this: an earlier version passed `(blen - (off+4))` (a length) as
     the end index, silently dropping the tail. The suffix end MUST be
     `(blen cell)`. `i == j` is allowed (empty slice), so writing the last two
     bytes — `off + 2 == blen cell` — needs no special guard, unlike the older
     `bput-u8` which cases the boundary explicitly.
  4. **"In-place" is loose.** Like `bput-u32-le`, this returns a FRESH,
     length-preserving cell (prefix ++ word ++ suffix); it does not mutate the
     argument. The fresh-cell discipline is deliberate and shared across the
     writer family.

## 3. Conventional (other-language) approach

In C you scribble the two bytes straight into the buffer, unchecked:

```c
/* write a little-endian u16 at offset off */
buf[off]     = (uint8_t)(val & 0xFF);   /* low byte  */
buf[off + 1] = (uint8_t)(val >> 8);     /* high byte */
```

- **Assumptions it bakes in:** raw in-place mutation of shared memory; no bounds
  proof (`off+1` past the end is undefined behaviour, not an error value); the
  writer is a `void` statement whose only evidence it ran is the side effect;
  endianness is a naked shift the reader must agree with by convention. chirality
  refuses the unchecked mutation and the silent out-of-bounds, and it will not
  let the byte order be an unwritten agreement between two functions.

## 4. The chirality idea

- **Chirality features in play:** the I64 + `Bytes` floor (no floats, everything is
  `[len][payload]` cells with `blen`/`bslice`/`bcat`/`pack-*`); totality (the
  writer is a straight-line splice, no loop, no partiality); the pure effect row
  (`->`, empty) — packing a value into a byte cell crosses no port, so it stays
  off the effect membrane; symmetry as an invariant (a reader `bget-u16-le`
  implies a writer `bput-u16-le` of the same width and byte order).
- **The reframing:** the write becomes a total, pure `Bytes -> Bytes`
  transformation — cut the cell at the offset, splice in the 2-byte LE word,
  keep the rest — returning a fresh length-preserving cell. Byte order is not a
  convention between two functions; it is fixed once by `pack-u16`, which
  `bget-u16-le`'s `unpack-u16` already inverts, so the round trip is correct by
  construction.
- **What chirality makes impossible here:** the unchecked past-the-end store (the
  slice bounds are values the codec must respect; a `i > j` end index faults
  rather than corrupting silently) and the divergent byte order (both directions
  route through the same `pack`/`unpack` pair).

## 5. Chirality example (fleshed)

Real surface syntax, mirroring `bput-u32-le` at `bytes-tal.chiral:543`. Copy this
in beside `bput-u8`; the only deltas from the u32 writer are `pack-u16` and the
`+ off 2` suffix start.

```chirality
; bput-u16-le: write a little-endian u16 at byte offset `off`, length-preserving,
; returning a FRESH Bytes (same fresh-cell discipline as bput-u32-le / bput-u8;
; never mutates in place). The two byte stores the catalog names — low byte at
; off, high byte at off+1 — are carried by the (pack-u16 val) word, which lays
; them down LE (low first). Inverse of bget-u16-le.
;
; HAZARD: surface `bslice` is (cell, START, END): the third arg is the EXCLUSIVE
; END INDEX, not a length, and it FAULTS on i>j. The suffix end MUST be
; (blen cell) — passing a length here is the E103 truncation bug. Writing the
; last two bytes (off+2 == blen cell) yields an empty tail via i==j, which is
; allowed, so no boundary guard is needed.
(def bput-u16-le (-> Bytes I64 I64 Bytes)
  (lam (cell off val)
    (let (prefix (bslice cell 0 off))            ; [0, off)
      (let (word (pack-u16 val))                 ; 2-byte LE: [lo, hi]
        (let (suffix (bslice cell (+ off 2) (blen cell)))  ; [off+2, blen)  <- blen, not a length
          (bcat prefix (bcat word suffix)))))))

; --- round-trip witness: write then read back through the existing reader ---
; 258 = 0x0102  ->  bytes [0x02, 0x01]  ->  bget-u16-le reads 2 + 256*1 = 258.
(def roundtrip-258 (-> Bytes I64)
  (lam (cell)
    (bget-u16-le (bput-u16-le cell 0 258) 0)))   ; = 258

; --- call-site win: T2's pack-winsize, in-place instead of allocate-and-concat ---
; today (term.chiral:48) it builds a fresh 8-byte cell by concatenating words:
;   (bcat (bcat (pack-u16 rows) (pack-u16 cols)) (pack-u32 0))
; with bput-u16-le it writes the two u16 fields into a zeroed cell at their
; struct offsets (rows@0, cols@2; xpixel@4/ypixel@6 stay 0):
(def pack-winsize-inplace (-> I64 I64 Bytes)
  (lam (rows cols)
    (let (z (cell-new 8))                         ; 8 zeroed bytes
      (bput-u16-le (bput-u16-le z 0 rows) 2 cols))))
```

- **Knobs to modify:** the offset `off` (any field position), the value `val`
  (the u16 to pack). Change nothing about the byte order — it is fixed by
  `pack-u16`.
- **Deliberately omitted:** an out-of-range `off` policy (the codec inherits
  `bslice`'s fault-on-`i>j` behaviour rather than validating); a separate TAL
  `nb-put-u16` in-place primitive (a two-`ti-bput` store mirroring `nb-put-u32-t`
  at `:482`) — the surface splice above is the mirror the catalog row names, and
  is enough to close the gap.

## 6. Use / modify notes

- **Lands in:** `lib/lowering/tal/bytes.chiral`, a single new surface `def`
  immediately after `bput-u8` (`:610`), mirroring `bput-u32-le` (`:596`).
  One-home change — no new module, no import churn.
- **Conformance target:** for any `cell`, `off`, and `val` in `[0, 65535]`,
  `(bget-u16-le (bput-u16-le cell off val) off)` = `val`, and `bput-u16-le`
  leaves `(blen cell)` and every byte outside `[off, off+2)` unchanged. The
  worked witness: `258 -> [0x02, 0x01] -> 258`.
- **Open questions:** none blocking. Whether to also add a true in-place TAL
  `nb-put-u16` primitive (vs. the fresh-cell splice) is a later performance
  call, not part of this element; the surface writer is the deliverable.
- **Related:** [[E103-bput-u32-le]] (the mirror + the `[i,j)`/`blen`-as-end
  hazard), the `bget-u16-le` reader it inverts, and T2 `pack-winsize` /
  `TUI/examples/T02-tiocswinsz.md` (the call-site that stops allocating).
