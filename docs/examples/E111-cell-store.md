---
element: E111
slug: cell-store
title: Bounded native cell array — a Pool-backed mutable cell store for Grid/parser, replacing the O(n) `(List Cell)` row-major store
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none — design over the existing Pool/Region substrate)
status: drafted
updated: 2026-08-11
---

# E111 — Bounded native cell array: a Pool-backed mutable cell store for Grid/parser, replacing the O(n) `(List Cell)` row-major store

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E111, back the terminal Grid's row-major cell store with a bounded
  native region so a single cell write is O(1) instead of the O(n) list rebuild
  that `set-nth`/`drop-n`/`cat-cells` cost today (`grid.chiral:16-24,57-106`).
- **Kind:** BUILD-PROPER — but see §2: the mutable primitive it needs already
  exists (`Pool`). The unbuilt part is the *cell codec* + the *pure→linear Grid*
  migration, not a new language feature.
- **Why chirality needs its own:** the T4 terminal shipped Grid as a pure `(List
  Cell)` value. `put-cell` runs once per printed glyph and rebuilds the spine to
  the cursor index; on an 80×24 grid that is ~1920-cell traversal per character,
  and it grows with scrollback. This is the parser's innermost hot path.

## 2. Research

- **Reference class:** OURS — `TUI/vt-core/grid.chiral` (the store + `set-nth`),
  `scaffold/lib/bytes-tal.chiral` (surface Bytes ops), `scaffold/lib/ports.chiral`
  (`Pool` porttype + `pool-write`), `scaffold/lib/mem-linear.chiral`,
  `scaffold/lib/mem-region.chiral` (the linear arena discipline).
- **Load-bearing finding — surface `Bytes` writes ALLOCATE, they are NOT
  in-place.** `bput-u32-le` (`bytes-tal.chiral:543-548`) is literally:

  ```chirality
  (def bput-u32-le (-> Bytes I64 I64 Bytes)
    (lam (cell off val)
      (let (prefix (bslice cell 0 off))
        (let (word (pack-u32 val))
          (let (suffix (bslice cell (+ off 4) (blen cell)))
            (bcat prefix (bcat word suffix)))))))
  ```

  Two `bslice` + two `bcat` copy the whole buffer. `bput-u8` documents it in
  words: "return a FRESH Bytes ... never mutates in place, length-preserving."
  **So a `Bytes`-*value* cell store updated per cell is still O(n) copy per
  write and buys nothing over the List for writes** (reads via `unpack-u32`/
  `bget` are the only win — O(1)). The naive reading of the catalog row
  ("Bytes-backed store") is a trap; state it plainly.

- **Load-bearing finding — a genuine in-place mutable primitive DOES exist:
  `Pool`.** `ports.chiral:19,74`:

  ```chirality
  (porttype Pool (n I64))                                          ; size-indexed, linear
  (extern pool-write (-> (0 n I64) (=> (1 p (Pool n)) I64 Bytes (Pool n))))
  ```

  `pool-write` takes the region *linearly* (`1 p`), on the *process* membrane
  (`=>`), and returns the **same** `(Pool n)`. It writes in place (memfd-backed
  region, E81/E91) and threads the owner back. `mem-region.chiral` already builds
  a bump arena on it (`Region`, frees as a unit). Linearity (`q=1`) is the
  type-system story: because no alias can hold the region, the in-place mutation
  is unobservable except through the single owner — the same trick a
  uniqueness/linear-array system uses, already load-bearing here.

- **Also true but not the surface story:** the TAL floor has a raw in-place
  write, `ti-bput`, used on *fresh/unfrozen* cells (`bytes-tal.chiral:474-479`,
  the E30 "structs at the floor" idiom — `nb-put-u32-t` mutates the cell in
  register 0 and threads it back). It rests on an informal fresh-cell discipline
  and is not exposed safely at the surface; `Pool` is the surface-safe form.

- **Gap:** the region libs only ever *write* — there is no `pool-read`/peek
  crossing (`mem-region.chiral:17` even says "you cannot peek without threading",
  but only write ops exist). E111 must add a read-back crossing.

## 3. Conventional (other-language) approach

A terminal emulator (xterm, ghostty, alacritty) backs the screen with a flat
mutable cell buffer and writes cells by index:

```c
typedef struct { uint32_t ch; uint16_t attrs; uint8_t fg, bg, width; } Cell;
Cell *grid = calloc(rows * cols, sizeof(Cell));      // one contiguous region
grid[row * cols + col] = (Cell){ cp, pen_flags, fg, bg, 1 };   // O(1) write
memmove(grid, grid + cols, (rows-1)*cols*sizeof(Cell));        // O(n) scroll, tight
```

- **Assumptions it bakes in:** ambient heap allocation; unrestricted aliasing of
  `grid` (any pointer may mutate it — no owner tracking); no bounds proof
  (`row*cols+col` trusted); mutation is invisible in the type. Every one of
  these is a freedom chirality refuses — which is exactly why the naive port
  (`grid : Bytes`, functional `bput` per cell) silently reintroduces the O(n)
  cost the C version avoids.

## 4. The chirality idea

- **Chirality features in play:** the `Pool (n I64)` linear porttype (size in the
  type); QTT `q=1` making the region single-owner so in-place mutation is sound;
  the `=>` effect membrane (a cell write is a crossing, not a pure map);
  refinement types for the offset bound (`mem-put-checked`); a fixed-width
  `Cell⇄bytes` codec built from the existing `pack-u32`/`bput-u8` ops.
- **The reframing:** the Grid stops being a pure `(List Cell)` value and becomes
  a **linear `(Grid n)` that owns a `(Pool n)` of `rows*cols*CELL_BYTES` bytes**.
  A cell lives at byte offset `idx*CELL_BYTES`; `put-cell` encodes one 16-byte
  record and `pool-write`s it in place — O(1), no spine rebuild. The bound `n`
  rides in the type, so `(Grid 30720)` (80×24×16) is a distinct type from a
  resized grid, and the region frees as a unit.
- **What chirality makes impossible here:** you cannot alias the store and mutate it
  from two places (linearity rejects the second use); you cannot write past the
  region (the offset is bounds-checked — statically for constant offsets, a
  runtime witness otherwise); and the mutation cannot hide from the signature —
  `put-cell` moves from `->` to `=>`, so "this touches the screen buffer" is a
  typed fact. The cost of that honesty is the migration itself (see §6).

## 5. Chirality example (fleshed)

Recommended shape: **(a)** — a `Pool`-backed `(Grid n)` + fixed-width Cell codec.
Not a new primitive; a composition of `Pool` + a codec.

```chirality
(import "prelude")
(import "ports")          ; Pool, pool-write, pool-create
(import "mem-linear")     ; mem-put (raw, runtime witness) / mem-put-checked (compile-proven bound)

; ── fixed 16-byte cell record ────────────────────────────────────────────────
;   [0..4)  ch (u32 LE codepoint)         [9]      bg tag
;   [4]     flags: b0 bold b1 ul b2 it    [10..13) bg payload (idx | r,g,b)
;           b3 rev b4 blink b5 strike     [13]     width
;   [5]     fg tag (0 def 1 idx 2 rgb)    [14..16) pad
;   [6..9)  fg payload (idx | r,g,b)
(def cell-bytes I64 16)

; ── Color ⇄ 4 bytes at offset: tag byte + 3 payload bytes ────────────────────
(declare enc-color (-> Bytes I64 Color Bytes))       ; fresh 16B record, one encode
(def enc-color
  (lam (rec off c)
    (case c
      (color-default        (bput-u8 rec off 0))                       ; tag 0, payload 0
      ((color-indexed i)    (bput-u8 (bput-u8 rec off 1) (+ off 1) i)) ; tag 1, idx
      ((color-rgb r g b)    (bput-u8 (bput-u8 (bput-u8 (bput-u8 rec off 2)
                                      (+ off 1) r) (+ off 2) g) (+ off 3) b)))))

; flags: pack the six Attrs bools into one byte (0/1 per bit)
(declare flags-byte (-> Attrs I64))
(def flags-byte
  (lam (a)
    (case a
      ((attrs bold ul it rev bl st fg bg)
        ; bit i set iff the i-th bool is true — mechanical bit-or, elided
        ; (bool->0/1 shifted into bits 0..5)
        (the I64 0)))))                                ; … packed bits

; Cell -> a fresh 16-byte record (constant-size allocation, NOT O(grid))
(declare cell->bytes (-> Cell Bytes))
(def cell->bytes
  (lam (cl)
    (case cl
      ((cell ch rend width)
        (case rend
          ((attrs bold ul it rev bl st fg bg)
            (let ((rec  (cell-new cell-bytes))                 ; 16 zeroed bytes
                  (rec1 (bput-u32-le rec 0 ch))                ; codepoint
                  (rec2 (bput-u8 rec1 4 (flags-byte rend))))   ; flags
              (let ((rec3 (enc-color rec2 5 fg))               ; fg at [5..9)
                    (rec4 (enc-color rec3 9 bg)))              ; bg at [9..13)
                (bput-u8 rec4 13 width)))))))))                ; width

; ── the store is a LINEAR, size-indexed region ───────────────────────────────
(data Grid ((n I64))
  (grid (rows I64) (cols I64)                        ; runtime dims — the row-major index needs cols; the BOUND n rides in the type
        (1 store (Pool n))                           ; the mutable cell region
        (cur Cursor) (pen Attrs)))

; put-cell is now a CROSSING (=>) that threads the region back — O(1) write
(declare put-cell (-> (0 n I64) (=> (1 g (Grid n)) I64 (Grid n))))
(def put-cell
  (lam (n g cp)
    (case g
      ((grid rows cols store cur pen)
        (case cur
          ((cursor cr cc)
            (let ((idx (+ (* cr cols) cc))
                  (rec (cell->bytes (cell cp pen 1))))
              ; strided (computed) offset → runtime witness, so raw mem-put/pool-write
              ; (mem-linear.chiral:24-25: mem-put-checked needs a compile-proven {< n}
              ;  offset — a constant col could use it; the strided idx*cell-bytes cannot)
              (let ((store2 (mem-put n store (* idx cell-bytes) rec)))
                (grid rows cols store2 (cursor cr (+ cc 1)) pen)))))))))

; reading a cell needs a read-back crossing that does not exist yet (§6 gap):
(declare pool-read  (-> (0 n I64) (=> (1 p (Pool n)) I64 I64 RdR)))  ; off,len -> bytes
(data RdR ((n I64)) (rd-r (bs Bytes) (1 p (Pool n))))
(declare bytes->cell (-> Bytes Cell))               ; decode a 16-byte record

; scroll-up: O(1) via a ring base-row instead of memmove — bump the logical
; top-row and clear the freed row. (The O(n) alternative is a row-block copy.)
(declare scroll-up (-> (0 n I64) (=> (1 g (Grid n)) (Grid n))))
```

- **Knobs to modify:** `cell-bytes` / the record layout (widen for grapheme
  clusters or 32-bit color indices); the size index `n` on `(Grid n)`; whether
  scroll uses a ring base-row (O(1)) or a row-block copy (O(cells), tight); which
  offsets are constant (statically bounds-checked) vs computed (runtime witness).
- **Deliberately omitted:** the bit-packing body of `flags-byte`; the
  `bytes->cell` decoder (dual of `cell->bytes`); grid resize/reallocation; the
  `pool-read` extern's host side. Codepoint/attrs encoding is shown; the
  mechanical byte loops are elided with `; …`.

## 6. Use / modify notes

- **Lands in:** `TUI/vt-core/grid.chiral` (the `Grid` data + `put-cell`/`clear`/
  `scroll-up`/`apply-sgr`), plus a small `cell-codec` helper (new file or folded
  into grid.chiral), reusing `scaffold/lib/{ports,mem-linear,mem-region}.chiral`.
- **Conformance target:** byte-for-byte identical screen contents to the current
  `(List Cell)` grid on the T4 terminal test corpus — same glyph at each
  `(row,col)`, same pen after any SGR sequence, same post-scroll contents.
  Behavior is unchanged; only the store representation and the O(cost) change.
- **Open questions (real decisions for the SPEC):**
  1. **`pool-read` crossing must be added — this is catalog element E113.** The
     region libs only write today; reads/decoding a cell need a read-back extern
     (`off,len -> Bytes` threading the Pool). It is E111's one genuine primitive
     dependency, tracked as its own element (**E113**, `Pool` region read/peek
     crossing — surfaced by this pre-run) and shares the "`Pool n` is erased but
     a bounded read needs the length at runtime" question with E107.
  2. **The pure→linear Grid migration is the real cost, not the codec.** Every
     Grid-touching function (`put-cell`, `clear`, `scroll-up`, `apply-sgr`, and
     every parser caller) moves from `-> Grid Grid` to `=> (1 g (Grid n)) …
     (Grid n)` and must thread the region linearly. Blast radius across all of
     vt-core + the parser; this is where the effort actually is.
  3. **Scroll strategy:** ring base-row (O(1), needs a top-row field + modular
     row indexing) vs row-block copy (O(cells)). The ring is the terminal-
     emulator standard and the reason a native store is worth it.
- **Recommendation (a) over (b)/(c), with reasoning:**
  - **(b) Bytes-*value* store with functional updates is strictly dominated** —
    verified in §2: `bput-*` allocate, so per-cell writes stay O(n); it only wins
    reads. Reject.
  - **(c) "defer" is NOT a scope-out — it's a *sequencing* fact.** (a) depends on
    `pool-read` (E113), so it lands *after* E113 — not on a "revisit if perf bites"
    trigger. `put-cell` is the *per-glyph* path, so the O(n) list traversal bites
    early on any real-size grid: this is a genuine emulator need, not a speculative
    optimization to gate behind a measurement.
  - **(a) Pool-backed `(Grid n)` + Cell codec** gives true O(1) in-place writes
    and its cost is bounded *because the mutable primitive already exists*
    (`Pool` + `mem-region`); the only new surface is the fixed-width codec and
    the `pool-read` companion. Recommend building (a), **sequenced right after
    E113** — this file is the blueprint; the blast radius is a cost to schedule,
    never a reason to defer.
- **Related:** [[E111-cell-store]], [[port]] (the `Pool` refraction),
  [[memory]] (E81/E91 linear regions), E30 (structs at the floor),
  E113 (the `pool-read` companion this element depends on).
