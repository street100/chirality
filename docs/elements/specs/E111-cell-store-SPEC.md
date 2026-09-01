---
element: E111
slug: cell-store
title: Bounded native cell array: a `Bytes`-backed (or fixed-size) mutable cell store for Grid/parser, replacing the O(n) `(List Cell)` row-major store (`grid.chiral:20-24`; `set-nth`/`drop-n` O(n)) — cuts per-cell cost for large grids
kind: BUILD-PROPER
example: examples/E111-cell-store.md
status: audited
updated: 2026-08-12
---

# E111 SPEC — Bounded native cell array: a Pool-backed linear `(Grid n)` cell store for Grid/parser

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.
>
> **Status = UNBLOCKED (design complete, turnkey; both hard deps now met).** E111's
> two structural dependencies are satisfied: `pool-read` = **E113** (audited
> 2026-08-12; native `pool-read` shipped by E120, `nb-pool-read-t`) and the native
> `pool-*` bindings (**E120/E122**, commit 604ce36). E111 is *sequenced*, not
> deferred: it is a committed part of vt-core for the emulator (T17); the blast
> radius (§2) is scheduled work, never a reason to defer. On priority it still sits
> *behind* the near-term scriba path (T13→T14→T18) — an ordering fact — but it is
> now ready to spec-audit → implement whenever the emulator lane is picked up.

## 1. Deliverable

- **After this runs:** the terminal `Grid` stops being a pure `(List Cell)`
  value and becomes a **linear, size-indexed `(Grid n)` that owns a `(Pool n)`**
  region of `rows*cols*16` bytes. A cell lives at byte offset `idx*16`; a single
  cell write is an O(1) in-place `pool-write` crossing instead of the O(rows*cols)
  `set-nth` spine rebuild that fires per printed glyph today. Concretely lands:
  1. a fixed-width **16-byte `Cell⇄bytes` codec** (`cell->bytes` / `bytes->cell`)
     built from `pack-u32`/`bput-u8`/`bget-u32`;
  2. the migrated `(Grid n)` type + its ops (`put-cell`, `clear`, `scroll-up`,
     `apply-sgr`) rewritten from `-> Grid Grid` to `=> (1 g (Grid n)) … (Grid n)`;
  3. every vt-parser Grid-threading function (15 of them, §2) moved onto the
     linear membrane so the store threads as a single-owner resource.
- **Non-goals:** the `pool-read` crossing itself (**E113**, already shipped —
  consumed here, not built); the native lowering of `pool-*` (**E120/E122**,
  already shipped — likewise consumed); grid resize/reallocation; grapheme-cluster
  cells (the codec is fixed 16-byte base-codepoint only — widening is §6 residue).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E111 postdates the map snapshot; treat as
  **BUILD**. The mutable primitive it stands on (`Pool`) is already built and the
  linear-region discipline is load-bearing, so this is BUILD-by-composition, not
  a new language feature.
- **Live code this composes with (do NOT respec):**
  - `scaffold/lib/ports.chiral:19,87-92` — `porttype Pool (n I64)`, `pool-create`,
    `pool-write (-> (0 n I64) (=> (1 p (Pool n)) I64 Bytes (Pool n)))`,
    `pool-close`. The in-place mutable primitive; `pool-write` threads the region
    linearly on the `=>` membrane.
  - `scaffold/lib/mem-linear.chiral:15,26` — `mem-put` (raw, runtime-witness
    offset) / `mem-put-checked` (compile-proven `{< n}` offset). E111 writes at a
    strided `idx*16` offset → runtime witness → uses `mem-put`/`pool-write`, not
    the checked form.
  - `scaffold/lib/mem-region.chiral` — the bump-arena precedent on `Pool`
    (`region-open`/`mem-alloc`/`region-close`); the pattern to imitate for
    owning-and-freeing the store as a unit.
  - `scaffold/lib/bytes-tal.chiral:523,532-548,557` — `cell-new` (N zeroed bytes),
    `bget-u16/u32-le`, `bput-u32-le`, `bput-u8`. The codec building blocks.
    **Load-bearing warning (verified):** `bput-u32-le`/`bput-u8` ALLOCATE a fresh
    Bytes (two `bslice` + two `bcat`) — they are NOT in-place. So the codec's
    per-cell 16-byte encode is a bounded constant-size allocation (fine); a
    Bytes-*value* whole-grid store would stay O(n) per write (rejected, §3 #1).
  - `TUI/vt-core/grid.chiral:4-16` — `Color` (closed sum: `color-default` /
    `color-indexed idx` / `color-rgb r g b`), `Attrs` (6 `Bool` +
    `fg Color` + `bg Color`), `Cell (cell (ch I64) (rend Attrs) (width I64))`.
    The exact shape the 16-byte codec must round-trip.
- **True delta (deliverable minus baseline):** the codec is genuinely new; the
  `Pool` primitive and linear discipline are reused verbatim; the bulk of the
  work is the **pure→linear migration** (see the blast radius below), not new
  primitives.

### Blast radius (do not minimize)

The current pure ops (`grid.chiral`):
`put-cell`, `clear`, `scroll-up`, `apply-sgr` (all `-> Grid … Grid`) plus the
`(List Cell)` helpers `blank-cells`, `set-nth`, `drop-n`, `cat-cells` — the
last four are **deleted/replaced** (the store is no longer a list).

Every Grid-threading function in `TUI/vt-core/vt-parser.chiral` moves from
`-> Grid … Grid` to `=> (1 g (Grid n)) … (Grid n)` and must thread the region
linearly (`case`, never `let` — a `let` would try to reuse the consumed owner):
`apply-action` (216), `apply-actions` (237), `exec-c0` (242), `exec-lf` (251),
`exec-cr` (265), `exec-bs` (273), `exec-tab` (283), `move-cursor` (295),
`move-cursor-by` (304), `erase-display` (313), `erase-display-after` (323),
`erase-display-before` (334), `erase-line` (389), `feed` (68/…), `parse` (69).
The `(List Cell)`-level erase helpers `erase-range`, `erase-range-go`,
`erase-range-to`, `list-copy`, `take-n` (grid.chiral-style list surgery) are
re-expressed as ranged `pool-write`/`pool-read` loops over the region.
**Parser call-sites that change:** `vt-parser.chiral:219` (`put-cell`), `228`
(`apply-sgr`), `259` (`scroll-up`), `318-319` (`clear`). This is the whole of
vt-core plus the parser — the migration is the cost, and it is large.

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Store representation: (a) Pool-backed linear `(Grid n)` + Cell codec, (b) `Bytes`-value store with functional `bput`, (c) defer / keep `(List Cell)` | **RESOLVED → (a)** | (b) is **strictly dominated** — `bput-u32-le`/`bput-u8` (`bytes-tal.chiral:543-557`) allocate a fresh Bytes per write, so a Bytes-value store is O(n)-per-write, buying only O(1) reads; it never beats the List for the hot `put-cell` path. (a) gives true O(1) in-place writes via `pool-write` and its cost is bounded because the mutable primitive already exists (`ports.chiral:87-92` + `mem-region.chiral`). (c) is a *scheduling* option, not a representation — dispositioned separately as #4. Design = (a). |
| 2 | The 16-byte Cell record byte layout | **RESOLVED** (cite `grid.chiral:4-16`) | Layout keyed to the `Cell`/`Attrs`/`Color` shape at `grid.chiral:4-16`: `[0..4)` ch as u32-LE codepoint; `[4]` flags byte = bits b0 bold, b1 underline, b2 italic, b3 reverse, b4 blink, b5 strike (the six `Attrs` `Bool`s, 1 bit each, b6-b7 reserved 0); `[5]` fg tag (0 `color-default`, 1 `color-indexed`, 2 `color-rgb`); `[6..9)` fg payload (indexed → `[6]`=idx; rgb → `[6]`=r,`[7]`=g,`[8]`=b); `[9]` bg tag; `[10..13)` bg payload (same encoding as fg); `[13]` width (u8); `[14..16)` pad (0). Total 16 bytes = one aligned record; `cell-bytes = 16`. Both `Color` variants fit 3 payload bytes since `color-rgb` is 3× 0..255 and `color-indexed` is one 0..255. |
| 3 | Scroll strategy: ring base-row (O(1)) vs row-block copy (O(cells)) | **RESOLVED → row-block copy for v1; ring is §6 residue** | The whole point of E111 is O(1) `put-cell`; `scroll-up` fires far less often (once per LF at bottom). A row-block `pool-read`/`pool-write` of `(rows-1)*cols` cells is O(cells) but correct-by-construction and needs no extra `(Grid n)` field. The ring base-row (O(1)) requires a top-row field + modular row indexing rippling through every offset computation — a second migration. Ship the row-block copy; track the ring as a follow-on optimization (§6). This keeps the linear-migration decision (#1) and the scroll optimization decoupled. |
| 4 | **SCOPE: when does E111 get built?** | **SEQUENCED after E113 — dep now met; not deferred, not perf-gated** | E111 is a committed part of vt-core for the emulator (T17, a planned deliverable) — it is built, not punted. The one real gate was a **structural dependency**: the linear `(Grid n)` must *read* cells back (`scroll-up`, `erase-range`, inspection), which needs `pool-read` = **E113** — now shipped (audited 2026-08-12, native `nb-pool-read`). So the dep is satisfied; there is no additional "if perf bites" trigger — that framing was an open-ended punt and is removed. Its blast radius (§2: 15 parser fns + grid.chiral pure→linear) is a **cost to schedule, not a reason to defer**. Priority note (ordering, not a gate): E111 sits *behind* the near-term scriba path (T13→T14→T18 renders scriba's own `Rendering`→ANSI and does not route through vt-core's grid), so it lands with the emulator wave — no later because of size. |
| 5 | Native `pool-*` bindings — can a Pool-backed Grid reach a native run? | **RESOLVED → shipped (E120/E122)** | Native `pool-create`/`pool-write`/`pool-read`/`pool-close` all lower to native as of commit 604ce36 (E120/E122): the crossing pairs are registered in `crossing-wraps.chiral:48-51` and the TAL bodies are `nb-pool-create`/`nb-pool-write`/`nb-pool-read`/`nb-pool-close` at `sys-tal.chiral:940,996,1030,1055`. A Pool-backed Grid therefore reaches a native ELF run today — no prerequisite remains. |
| 6 | `pool-read` crossing (O(1) indexed READ + cell decode) | **RESOLVED → shipped (E113)** | Reading a cell back — for `scroll-up` row copy, `erase-range`, and any inspection — needs `pool-read (off,len → Bytes + threaded (Pool n))`. That is catalog element **E113**, audited 2026-08-12 and shipped natively by E120 (`nb-pool-read`, single-arm `pr-r` result at `ports.chiral:38` threading the `(Pool n)` cap back beside the fresh `Bytes`, halt-on-OOB). Declared at `ports.chiral:91`. E111's read side is available now. |
| 7 | Dims (`rows`/`cols`) quantity | **RESOLVED → runtime (unerased) fields** | `rows`/`cols` are used at runtime to compute the row-major index `idx = cr*cols + cc`, so they must NOT be quantity-0 (the example-audit fix). Only the *bound* `n` on `(Grid n)` is the erased type-level size index; `rows`/`cols` are ordinary runtime fields of the `grid` constructor. |
| 8 | Threading discipline | **RESOLVED → `case`, never `let`** | The linear owner is consumed by each crossing and a fresh `(Grid n)` / `(Pool n)` threaded back inside the result constructor; destructure and re-thread with `case` on the returned record. A `let` binding the region would read as reuse of a consumed linear value and be rejected. |

Decision #4 (scope) resolves to *sequenced after E113* — and E113 has now landed
(audited 2026-08-12). Both structural deps are satisfied: #5's native `pool-*`
bindings (E120/E122, 604ce36) and #6's `pool-read` (E113, shipped natively by
E120). No gate remains — E111 is UNBLOCKED (INDEX `specced`); §4-§6 describe the
actual remaining work (the codec + the pure→linear migration + the sample),
turnkey to implement. No perf-trigger, no prerequisite.

## 4. Change plan (ordered, commit-sized)

**Prerequisites — already satisfied (no E111 work).** The native `pool-*`
bindings (decision #5 — E120/E122, `crossing-wraps.chiral:48-51` +
`sys-tal.chiral:940,996,1030,1055`) and `pool-read` (decision #6 — E113, audited
2026-08-12, `nb-pool-read`) are shipped, so a Pool-backed Grid reaches a native
ELF run today. E111's plan is purely its own deliverable — the codec + the
pure→linear migration + the sample:

### Step 1 — the 16-byte Cell codec — M
- **Target:** new `TUI/vt-core/cell-codec.chiral` (or folded into `grid.chiral`).
- **Change:** `cell-bytes = 16`; `cell->bytes (-> Cell Bytes)` and
  `bytes->cell (-> Bytes Cell)` per decision #2's layout, incl. `flags-byte` /
  its inverse (bit-pack the six `Attrs` bools) and `enc-color`/`dec-color`
  (tag+3-payload) for fg and bg. Pure, allocation-bounded (one `cell-new 16` +
  fixed `bput-*`/`bget-*`). Testable NOW (no Pool needed).
- **Size:** M. **First real E111 commit.**

### Step 2 — the linear `(Grid n)` type + grid.chiral ops — L
- **Target:** `TUI/vt-core/grid.chiral`.
- **Change:** replace `(data Grid () (grid rows cols (cells (List Cell)) cur pen))`
  with `(data Grid ((n I64)) (grid (rows I64) (cols I64) (1 store (Pool n)) (cur Cursor) (pen Attrs)))`.
  Migrate `put-cell`/`clear`/`scroll-up`/`apply-sgr` to
  `=> (1 g (Grid n)) … (Grid n)` (put-cell: encode + `mem-put` at `idx*16`;
  clear: ranged blank-cell fill; scroll-up: row-block `pool-read`+`pool-write`
  per decision #3). Delete `blank-cells`/`set-nth`/`drop-n`/`cat-cells`. Add a
  `grid-new`/`grid-open` that `pool-create`s `rows*cols*16` and blank-fills.
  Thread with `case` (decision #8).
- **Size:** L. **Depends on:** step 1.

### Step 3 — migrate the parser onto the linear membrane — L
- **Target:** `TUI/vt-core/vt-parser.chiral`.
- **Change:** move all 15 Grid-threading fns (§2 list) to `=> (1 g (Grid n)) … (Grid n)`;
  re-express `erase-range`/`-go`/`-to`/`list-copy`/`take-n` as ranged
  `pool-read`/`pool-write` loops; update call-sites (219/228/259/318-319). Thread
  linearly throughout.
- **Size:** L. **Depends on:** step 2.

### Step 4 — samples + gate wiring — S
- **Target:** `TUI/samples/` (codec round-trip; linear put-cell→pool-read),
  migrate `t4_grid.chiral`/`t4_minimal.chiral`/`t5_vt_parser.chiral` to `(Grid n)`.
- **Size:** S.

## 5. Conformance gate

- **Golden behavior:** byte-for-byte identical screen contents to the current
  `(List Cell)` grid on the T4/T5 corpus — same glyph at each `(row,col)`, same
  pen after any SGR sequence, same post-scroll contents. Behavior is UNCHANGED;
  only the store representation and the O(cost) change.
- **Tests to add:**
  - **Codec round-trip (pure — testable immediately):** a `Cell` with each `Color`
    variant (default / indexed / rgb) and all six attrs set → `cell->bytes` → 16
    bytes → `bytes->cell` → structurally identical `Cell`; a driver that exits
    **42** on all-pass. Add as a sample under `TUI/samples/` + a `scaffold/tests/`
    test.
  - **Linear-Grid round-trip — native floor:** a `put-cell`→`pool-read` sample
    (write a cell at cursor, read it back via `pool-read`, decode, compare; exit
    42). The `pool-*` crossings lower to native (E120/E122), so this runs as a
    **native ELF** — not oracle-only.
  - **Regression (after the grid + parser migration):** the existing T4/T5
    grid/parser samples (`t4_grid`, `t4_minimal`, `t5_vt_parser`) must still pass,
    migrated to `(Grid n)` — byte-identical screen contents, no behavioral
    regression.
- **Green line:** 704 test functions → ≥ 705 (codec round-trip); the linear-Grid +
  parser regression tests add as the migration lands; ledger-lint clean.
- **Done when:** the codec round-trip exits 42, and the migrated T4/T5 samples
  reproduce byte-identical screen contents to the `(List Cell)` grid **on the
  native floor** with `put-cell` as an O(1) in-place `pool-write`.

## 6. Residue & links

- **Built prerequisites (no longer residue):**
  - Native lowering of `pool-*` — **shipped (E120/E122, 604ce36)**;
    `crossing-wraps.chiral:48-51` + `sys-tal.chiral:940,996,1030,1055`.
  - `pool-read` crossing — **shipped (E113, audited 2026-08-12; E120
    `nb-pool-read`)**.
- **Deliberately unbuilt:**
  - Ring base-row O(1) scroll — follow-on optimization (§3 #3); v1 ships
    row-block copy.
  - Grapheme-cluster / >u8 color-index cells — the 16-byte record is fixed
    base-codepoint; widening the layout is future work.
  - Grid resize/reallocation (a `(Grid n)` → `(Grid m)` migration) — nobody's yet.
- **Follow-on:** unblocks a scrollback/large-grid consumer and any perf-sensitive
  vt-core workload; establishes the Pool-backed-codec pattern for other bounded
  native stores.
- **Related:** [[E111-cell-store]], E113 (`pool-read` dependency), E107 (shares
  the "`Pool n` erased but bounded read needs runtime length" question),
  [[port-bank]] (the `Pool` refraction), [[memory-discipline-arc]] (E81/E91
  linear regions), E30 (structs at the floor).
