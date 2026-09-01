---
element: E112
slug: apc-sidechannel
title: Structured side-channel framing (APC transport): encode a `Rendering` tree into an APC envelope (`ESC _ … ESC \`, silently discarded by non-supporting terminals) + decode/parse it back + a content-hash `block-id` per addressable node — the lossless (M)-tier transport under the `Terminal` port (handshake negotiation split to E128)
kind: BUILD-PROPER
example: examples/E112-apc-sidechannel.md
status: audited
updated: 2026-08-12
---

# E112 SPEC — Structured side-channel framing (APC transport)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** a new module `TUI/apc.chiral` provides `enc`/`enc-frame`
  (a `Rendering` tree → a printable APC frame, `ESC _ … ESC \`) and
  `dec`/`dec-frame` (an APC frame → the *same* `Rendering` tree) via a
  netstring grammar with single-char constructor tags; a pure **`block-id :
  (-> Rendering Str)`** that assigns every addressable node (`r-section`/`r-hole`)
  a stable **content-hash address** (FNV-1a-64 over the node's identity bytes →
  16 hex chars), emitted as a leading netstring field on those two frames so the
  receiver can fold / re-run / diff a block by a name that survives re-render;
  `TUI/vt-core/vt-parser.chiral` `ps-apc-string` stops discarding the accumulated
  payload and instead reverses+decodes it into a new `act-apc-render` `Action`;
  and the `Terminal` port's `term-draw` selects tier from `term-structured?` —
  lossless APC on (M), `render-to-ansi-full` on (R). The observable delta: a
  `Rendering` survives a full `enc-frame → parser → dec-frame` round-trip
  structurally, and each section/hole round-trips with a stable, verifiable
  content-hash address.
- **Non-goals (each named, owned, not silently dropped):** the wire negotiation
  protocol that *sets* `term-structured?`'s bit (the handshake query/response
  byte) is a **separable element** — decision #5, now minted as its own catalog
  row (`FMT·E128 apc-handshake`), not folded into the codec; UTF-8 multibyte length
  accounting in the codec (byte-length netstring is the ASCII slice; a real impl
  reuses `utf8.chiral`). Residue in §6. **Block-id is NO LONGER a non-goal** — it
  is specified here (decision #4, resolved to content-hash), not left as an empty
  slot.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E112 postdates the CONFORMANCE-MAP
  snapshot; treated as **BUILD** (BUILD-PROPER). Nothing in the codec exists yet.
- **Live code this composes with:**
  - `TUI/scriba/render.chiral:6-12` — the `Rendering` sum (six constructors:
    `r-text`/`r-table`/`r-section`/`r-stream`/`r-tree`/`r-hole`) is the payload
    type, verbatim; `render-to-ansi-full` (already built) is the baseline tier.
  - `TUI/vt-core/vt-parser.chiral:20` — `ps-apc-string (buf (List I64))` state;
    `:116` enters it on byte `95` (`0x5F`, `_`) after ESC; `:174-177` is the
    decode seam — on ESC (`27`) it returns `(pair ps-ground nil)` **discarding
    `buf`**, else accumulates `(cons b buf)` (reverse order). `Action` sum at
    `:24-40`; `feed` step returns `(Pair PState (List Action))`.
  - `TUI/docs/TERMINAL-PORT-DESIGN.md §2` — the two-tier output, the degrade
    rule, and the verbatim `term-structured? : (=> (1 t Terminal) (Pair Bool
    Terminal))` signature; §8 items 2 and 4 are the two live NEEDS-AUTHOR slots.
- **True delta:** (a) new `TUI/apc.chiral` (encode + decode + envelope + the
  netstring/tag codec); (b) `vt-parser.chiral`: one new `Action` variant
  `act-apc-render (r Rendering)` + the `ps-apc-string`/ESC case body flips from
  discard to reverse→`Str`→`dec-frame`→emit; (c) the `Terminal` port's
  `term-draw` tier `case` on `term-structured?`. No change to `render.chiral`.

## 3. Decisions

Every open question from the example §6 (and the TERMINAL-PORT-DESIGN §8 slots it
inherits), dispositioned. RESOLVED only when derivable from a settled doc or the
transport itself (cited); genuinely novel design → NEEDS-AUTHOR, surfaced, never
answered on the author's behalf.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Envelope framing — APC vs a private DCS (`§8.4`) | **RESOLVED-with-citation** | APC. `TERMINAL-PORT-DESIGN §2:102-104` + example §2/§6: APC (`ESC _`) has essentially no standard consumer, so a chirality-private payload cannot collide, whereas DCS (`ESC P`) is claimed by Sixel/DECRQSS; kitty-graphics + notty precedent ride APC precisely because non-supporting terminals silently discard it (the degrade guarantee). The decode seam `ps-apc-string` is *already* wired at `ESC _` (`vt-parser.chiral:116,174`), so APC costs zero new parser state. |
| 2 | Payload encoding — printable netstring + single-char tags | **RESOLVED-with-citation** | ECMA-48 §5.4: APC payload is nominally *graphic* chars (0x20–0x7E), not binary (web-verified in example §2). Netstring `<declen>:<chars>` is delimiter-bug-free for any field content; tags `t`=text `s`=section `S`=stream `h`=hole `T`=table `r`=tree, recursing on `section` body / `table` rows / `tree` children. Printable-safe by construction. |
| 3 | Handshake tier selection (`term-draw` on `term-structured?`) | **RESOLVED-with-citation** | `TERMINAL-PORT-DESIGN §2:108-112` degrade rule, verbatim signature. `term-draw` cases on the `Bool` carried on the linear `Terminal` cap: `true` → `enc-frame` over APC (M/lossless); `false` → `render-to-ansi-full` (R/baseline). |
| 4 | Block-id scheme (`§8.2`) — how an `r-section`/`r-hole` is named/addressed for fold/re-run/diff | **RESOLVED → content-hash** (author, `TUI-PRIMITIVES.md` §Decisions row 4, 2026-08-12: "Block-id = content-hash") — **fully specified, not a slot** | **Scheme:** `block-id : (-> Rendering Str)`, a pure function, **derived not stored** — so `render.chiral`'s `Rendering` is untouched and both endpoints compute the same address from the same content. **Hash:** FNV-1a-64 over the node's **identity bytes**, folded byte-by-byte with `bxor` + `*` on wrapping I64 (`op-bxor` + Euclidean `*` both lower in B1 — verified `tal-erase.chiral:105`, `mach-x64.chiral:383,997`); rendered to **16 lowercase hex chars** via `band 15` + `shr 4` (`op-band`/`op-shr`, both built — `mach-x64.chiral:379,377`) — printable-safe (graphic ASCII, satisfies decision #2). **Constants as DECIMAL i64 literals** (the sexp reader is decimal-only — `sexp.chiral:133` `acc*10`; E1 dec #4): FNV offset basis = `-3750763034362895579` (the two's-complement i64 whose bit pattern is `0xcbf29ce484222325`), prime = `1099511628211` (`0x100000001b3`). No `0x` literal may appear in the implementation. **Identity bytes (the load-bearing choice):** for `r-section`, hash `enc-str title ++ enc body` and **exclude the `collapsed` bit** — so toggling a fold does NOT re-key the block (a section stays addressable across its own collapse/expand); for `r-hole`, hash `enc-str label` (a hole is empty by definition, its label is its identity). **Wire:** emitted as a leading `enc-str` netstring field on the `s`/`h` frames (`s <id> <collapsed> <title> <body>`, `h <id> <label>`); the decoder reads it, **recomputes** `block-id` on the reconstructed node, and verifies emitted==computed (integrity; mismatch degrades the frame to `act-ignore`, never a wrong branch). Redundant-but-explicit: a non-chirality receiver reads the address directly; a chirality receiver can recompute. Sequence-id rejected (silently re-points on reflow — the addressing surface must survive re-render). |
| 5 | Exact handshake *query byte* (`§8.4`) — what the emulator answers to set `term-structured?` | **SEPARATE ELEMENT → `FMT·E128 apc-handshake`** (not folded into E112; owed a catalog+LEDGER row) | The query/response byte is a protocol invention, not an inherited ECMA-48 sequence, and it is genuinely a *different unit of work* from the codec (it negotiates the bit; the codec consumes it). **E112 does not need it:** `term-structured?` returns a `Bool` *carried on the cap, negotiated once at acquisition* (§2:108-109) — the chirality-emulator port answers `true` by construction, a tty port answers `false`. So E112 is complete without it. The negotiation protocol is minted as its **own tracked element** `FMT·E128` (not a floating NEEDS-AUTHOR): recommended design = an APC query `ESC _ ? … ST` with an APC reply so a dumb terminal stays silent (timeout ⇒ `false`), aligned with decision #1's transport. Its spec-decisions (exact query/reply bytes, timeout) are E128's to resolve. **`FMT·E128` is now minted** — catalog row (`SELF-IMPLEMENT-CATALOG.md` §IV, after E127) + `LEDGER.md` FMT row, both `design`, 2026-08-12. |
| 6 | `str->i64` unlowered in B1 | **RESOLVED-with-citation** | Example §5 + §6 "Ground truth": `str->i64` does not lower under B1; the codec reads decimal lengths with byte-arithmetic `digit-val` (`(- (bget (str->bytes c) 0) 48)`) inside a cursor-structural `read-len`. This is why §5 compiles. |
| 7 | `str-sub` bounds convention | **RESOLVED-with-citation** | Example §5 + §6: `str-sub src start end` is half-open `[start,end)`. `dec-frame` strips APC intro (2) + ST (2) via `(str-sub frame 2 (- n 2))`; `read-len`/`dec-str` slice with the same convention. |

No NEEDS-AUTHOR remains: #4 is resolved and **fully specified in §4** (content-hash
addressing, not a reserved slot); #5 is carved out as its own element `FMT·E128`
(the codec consumes a `Bool`, complete without it), now minted in the catalog +
LEDGER. `status` stays `draft` (spec-audit + implement still ahead), §4–§6 fully
specified.

## 4. Change plan (ordered, commit-sized)

### Step 1 — `TUI/apc.chiral`: the netstring codec (encode + decode)
- **Target:** new file `TUI/apc.chiral` — imports `prelude` + `render` (for the
  `Rendering` sum). Contents from example §5: `byte->str`/`apc-intro`/`st`
  (ECMA-48 bytes 27/95/92); `enc-str`/`enc-bool`; `enc` (six-tag serializer,
  recursing on `section`/`table`/`tree`) + `enc-frame`; the `PR`/`SR`/`BR`
  parse-result sums; `digit-val`/`read-len`/`dec-str`/`dec-bool`; `dec` (tag →
  reconstruct the same sum, `else` → `p-err` as a value) + `dec-frame`.
- **Change:** promote the example's fleshed `text`+`section` slice to the **full**
  six-constructor codec — `table` (`count;` prefix then that many
  `(List Rendering)` rows, each itself a `count;`-prefixed sub-node list),
  `stream`, `tree` (children list + selected sub-node), `hole` — encode and decode
  in matching order. Byte-arithmetic length read only (decision #6); half-open
  `str-sub` (decision #7). The `s`/`h` frames gain the leading `block-id` field
  (Step 1b): encode `s <enc-str id> <enc-bool collapsed> <enc-str title> <enc body>`
  and `h <enc-str id> <enc-str label>`; decode reads `id` first, then verifies it.
- **Size:** ~M

### Step 1b — `block-id`: the content-hash addressing function
- **Target:** `TUI/apc.chiral` — a pure `block-id : (-> Rendering Str)` + its
  FNV-1a-64 helper `fnv1a : (-> Bytes I64)` + `hex16 : (-> I64 Str)`.
- **Change (decision #4):** `fnv1a` folds bytes with `hash := (* (bxor hash b)
  prime)` on wrapping I64 from offset basis `-3750763034362895579`, prime
  `1099511628211` (**decimal literals only** — the reader is decimal-only,
  `sexp.chiral:133`; the offset-basis decimal is the two's-complement i64 of
  `0xcbf29ce484222325`). `hex16` emits 16 lowercase hex chars via `band … 15` +
  `shr … 4` per nibble (`op-band`/`op-shr`, built). `block-id` cases the node:
  `r-section title _ body` → `hex16 (fnv1a (str->bytes (str-cat (enc-str title)
  (enc body))))` — note it hashes title+body and **excludes `collapsed`** so a fold
  toggle keeps the same address; `r-hole label` → `hex16 (fnv1a (str->bytes
  (enc-str label)))`; non-addressable nodes → a defined sentinel (empty `""`) —
  only section/hole are addressable. Pure `->`, allocation-bounded. **No change to
  `render.chiral`.**
- **Size:** ~S

### Step 2 — `vt-parser.chiral`: wire the decode into `ps-apc-string`
- **Target:** `TUI/vt-core/vt-parser.chiral` — `Action` sum (`:24-40`) + the
  `ps-apc-string` ESC case (`:174-177`). Add `(import "apc")` (and, transitively,
  `render`).
- **Change:** add one `Action` variant `(act-apc-render (r Rendering))`. In the
  `ps-apc-string` ESC(27) case, replace `(pair ps-ground nil)` — instead reverse
  `buf` (accumulated tail-first via `cons`), map the codepoints to a `Str`, call
  `dec-frame`, and on `p-ok` emit `(cons (act-apc-render r) nil)` up with
  `ps-ground`; on `p-err` emit `(cons act-ignore nil)` (a malformed frame degrades
  to a no-op, never a throw — the frame stays a value). The `else` accumulate
  branch (`(cons b buf)`) is unchanged.
- **Size:** ~S

### Step 3 — `Terminal` port: `term-draw` tier selection
- **Target:** the `Terminal` port impl (beside `render-to-ansi-full`; the
  `term-structured?`/`term-write`/`term-draw` declares from example §5, per
  `TERMINAL-PORT-DESIGN §2`).
- **Change:** `term-draw` `case`s `(term-structured? t)`; `true` →
  `(term-write t2 (enc-frame r))` (M, lossless APC); `false` →
  `render-to-ansi-full` then `draw-ok` (R, baseline). The write is the only `=>`
  crossing; `enc`/`dec` stay pure `->`.
- **Size:** ~S

### Step 4 — conformance sample
- **Target:** new `TUI/samples/t6_apc_roundtrip.chiral` (compile-with-B1-and-run).
- **Change:** the audited case `(r-section "Diagnostics" false (r-text "no
  crossing" true))` → `enc-frame` → `dec-frame` → structural equality → return
  **42**; plus at least one more shape exercising Step 1's new branches — a nested
  `r-tree` (children + selected) or an `r-table` (headers + rows) — round-tripped
  the same way. **Plus the block-id checks (Step 1b):** (a) **stability under fold**
  — `block-id (r-section t false b)` == `block-id (r-section t true b)` (collapse
  does not re-key); (b) **content-sensitivity** — a section with a different body
  hashes differently; (c) **integrity** — a frame whose emitted id is corrupted
  decodes to `act-ignore`, not a wrong node. All-pass ⇒ 42.
- **Size:** ~S

## 5. Conformance gate

- **Golden behavior:** for every `Rendering` subtree, `dec-frame (enc-frame r)`
  reconstructs `r` structurally (tables stay tables, sections stay foldable, holes
  stay addressable); **every section/hole round-trips with a content-hash address
  that is stable under fold-toggle and verified on decode** (emitted==recomputed;
  mismatch ⇒ `act-ignore`); a malformed frame yields a `p-err` value (no throw, no
  silent wrong branch); a non-supporting terminal shown `enc-frame r` renders
  **nothing** (APC discarded) — the degrade guarantee.
- **Tests to add:**
  - `TUI/samples/t6_apc_roundtrip.chiral` — compile with B1, run; exit **42** iff
    the `r-section⊃r-text` case AND the second shape (nested `r-tree` or `r-table`)
    both round-trip to structural equality. This is the whole-codec floor
    (encode → bytes → decode), the example §6 ground-truth extended to a full-tree
    shape.
  - Regression: `TUI/samples/t5_vt_parser.chiral` still compiles-with-B1 and passes
    unchanged — the new `act-apc-render` variant + `ps-apc-string` decode must not
    perturb ground/CSI/OSC/print behavior (coverage-checked `case` guarantees the
    other `Action`s are untouched).
- **Green line:** these are B1 compile-and-run programs under `TUI/`, not the
  pytest oracle — the gate is `t6_apc_roundtrip` exit 42 + `t5_vt_parser` no
  regression. No fixpoint (non-compiler program). ledger-lint clean.
- **Done when:** `t6_apc_roundtrip.chiral` compiled by B1 exits 42 and
  `t5_vt_parser.chiral` still passes.

## 6. Residue & links

- **Built here (was previously deferred, now specified):**
  - Block-id addressing on `r-section`/`r-hole` — **decision #4, resolved to
    content-hash and fully specified** (§4 Step 1b): derived `block-id`
    (FNV-1a-64 → 16 hex), stable under fold, verified on decode, `render.chiral`
    untouched. No longer a reserved slot.
- **Deliberately separate (named + tracked, not dropped):**
  - Handshake negotiation query byte — **decision #5 → its own element
    `FMT·E128 apc-handshake`**; home = `TERMINAL-PORT-DESIGN §8 item 4`. E112
    consumes the `Bool`; the wire protocol (recommended APC query, timeout→false)
    is E128's scope. **`FMT·E128` is minted** (catalog §IV after E127 + LEDGER FMT,
    both `design`, 2026-08-12).
  - UTF-8 multibyte length accounting in the codec — reuse `TUI/vt-core/utf8.chiral`
    when the payload leaves the ASCII slice; byte-length netstring suffices now.
    (Note: block-id hashes `enc`-produced bytes, which are ASCII netstrings, so the
    address is UTF-8-safe already — the hash is over encoded bytes, not raw glyphs.)
- **Follow-on:** the handshake negotiation protocol (decision #5); the compositor
  consuming `act-apc-render` into a `Surface` (`TERMINAL-PORT-DESIGN §5/§7,
  §8 item 6`); the input-half / writer-identity surface (the actual differentiator,
  §2:126) rides this transport once block-ids land.
- **Related:** [[E112-apc-sidechannel]] · `TERMINAL-PORT-DESIGN.md` (§2 two-tier +
  degrade, §8 items 2/4) · `render.chiral` `Rendering`/`render-to-ansi-full`
  (baseline tier) · `vt-core/vt-parser.chiral` `ps-apc-string` (decode seam) ·
  [[boundary-sums]] (tags-as-values) · [[chirality-terminal-emulator-arc]].
