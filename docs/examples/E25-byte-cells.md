---
element: E25
slug: byte-cells
title: Byte cells `[len][payload]` (bytearray reference is a crutch)
kind: REPLACE-CRUTCH
reference_class: OURS
ours_source: scaffold/chirality/tal.py
status: drafted
updated: 2026-07-13
---

# E25 — Byte cells `[len][payload]` (bytearray reference is a crutch)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E25, the runtime representation of `Bytes`: a value is **one
  word — a pointer to a `[len][payload]` cell** — with the four floor ops
  `bnew`/`bget`/`bput`/`blen`.
- **Kind:** REPLACE-CRUTCH. **Build-state note (audit-corrected 2026-08-01):**
  the crutch-replacement is **DONE** — the map row is CONFORMS: "Real path
  built + self-hosted; nb-* prims preserve-checked at load, arena cells
  execute; **bytearray is golden oracle** … *deliberate differential oracle,
  not unmet crutch*" (the honest framing the catalog pins). Both halves this
  example originally proposed exist: the native arena cells AND
  `lib/bytes-tal.chiral`. The tal.py `bytearray` interpreter **stays**, as the
  reference floor the native cells are differentially validated against. What
  remains — this example's real subject — is the **typed builder / refined-face
  layer** on top (§4–§5): the linear `BBuf` build-then-freeze discipline and
  the refined-bounds faces, neither of which the map owes (forward design, not
  an unmet obligation).
- **Why chirality needs its own:** every string, every parsed input, every value
  marshalled across the FFI seam (E23) bottoms out in these cells. The cells
  are owned; what is still only *convention* is the safety story above them —
  "initialization write only" is a comment (`tal.py:21`), bounds are dynamic,
  and a non-byte I64 is stopped by the host, not the checker. Lifting those
  into types is the residual work.

## 2. Research

- **Reference class:** OURS — `scaffold/chirality/tal.py` (the tal floor: typed
  register IR, its own checker, interpreter as the trusted drop).
- **Key findings:**
  1. **The ABI is already fixed by the tal instruction set:** `("bnew", dst,
     src_len)`, `("bget", dst, ptr, idx)`, `("bput", ptr, idx, val)`,
     `("blen", dst, src)`; the module header states "a Bytes value is one
     word: a pointer to a `[len][payload]` cell" (tal.py:28). The example must
     conform to this shape, not redesign it.
  2. **`bput` is an *initialization* write into a cell** (tal.py:21) — the
     model is build-then-freeze, not general mutation. Frozen cells are
     immutable, which is exactly what makes a one-word pointer copy safe to
     share under `->` purity.
  3. **The crutch:** the interpreter does `regs[dst] = bytearray(n)` for
     `bnew` (tal.py:244) — zero-fill, bounds errors, and the length header all
     come free from CPython. A comment at tal.py:239 already names the native
     replacement: "natively via the zero-mapped arena (mach-x64)".
  4. The tal checker types the ops (`bnew : I64 → Bytes`, `bget : Bytes ×
     I64 → I64`, tal.py:130–143) but bounds are checked **dynamically** by the
     interpreter; nothing at the tal level stops an out-of-range index —
     that safety currently lives in the bytearray.

## 3. Conventional (other-language) approach

How this is done outside chirality — the existing Python interpreter loop:

```python
elif op == "bnew":
    # bytearray(n); natively via the zero-mapped arena (mach-x64)
    regs[ins[1]] = bytearray(regs[ins[2]])
elif op == "bget":
    regs[ins[1]] = regs[ins[2]][regs[ins[3]]]   # IndexError if out of range
elif op == "bput":
    regs[ins[1]][regs[ins[2]]] = regs[ins[3]]   # mutation allowed anytime
elif op == "blen":
    regs[ins[1]] = len(regs[ins[2]])            # host tracks the length
```

- **Assumptions it bakes in:** ambient GC allocation (`bytearray(n)` from
  nowhere, freed by nobody); partiality as control flow (out-of-bounds raises
  `IndexError` — an exception, not a value); hidden unrestricted mutation
  (`bput` works at any time on any cell, so "initialization write" is a
  comment, not a rule); the length is host metadata (`len()`), not part of the
  cell's own layout; values 0–255 enforced by the host type, not the checker.

## 4. The chirality idea

How chirality's model reframes it.

- **Chirality features in play:** categories B/C (untyped arena, typed bridge),
  refinement types (in-bounds and byte-range by proof), QTT linearity (the
  builder discipline), `->` purity (frozen cells are values), totality (no
  `IndexError` path exists to need).
- **The reframing:** the arena itself — bump-allocated, zero-mapped raw
  memory, cells laid out `[len:word][payload:len bytes]` — is **Category B**:
  substrate the language cannot type. `lib/bytes-tal.chiral` is the **Category
  C bridge**: a typed face whose signatures carry the evidence the bytearray
  used to provide dynamically. Two moves do the work: (a) `bget`'s index is a
  *refined* I64, `(refine I64 (>= 0) (< (blen b)))`, so in-bounds is a proof
  obligation discharged by the caller and `bget` is **total** — the error
  path doesn't move into a result sum, it *disappears*; (b) "initialization
  write only" becomes a *type*: a fresh cell is a **linear builder** that
  `bput` consumes and returns, and `bfreeze` consumes for good, yielding
  unrestricted immutable `Bytes`. Sharing a one-word pointer to a frozen cell
  is then pure by construction.
- **What chirality makes impossible here:** indexing out of bounds (untypeable —
  no refinement proof, no call); writing to a cell after it is frozen (the
  linear builder is gone; `Bytes` has no write op); using an uninitialized
  cell as `Bytes` (only `bfreeze` produces one); leaking or double-consuming
  a builder (linearity: exactly once); stuffing a non-byte I64 into a cell
  (the value is refined to `[0,256)`).

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
(import "prelude")

; lib/bytes-tal.chiral — the Category C bridge over the Category B arena.
; Referent: bump-arena cells [len:word][payload:len bytes], zero-mapped.
; A Bytes value is ONE WORD: a pointer to a frozen cell.

; ---- frozen bytes: unrestricted, immutable, safe to share -------------
(declare blen (-> Bytes I64))                       ; reads the [len] header
; GATED FACE (edge 3): `(< (blen b))` is an EXPRESSION bound — E9's decidable
; fragment is constants + bare variables only (v<n landed 2026-07-06;
; function-application bounds did not). This refined face is the design target
; once expression bounds land (same gate as E22's cursor); until then bget's
; live face keeps the runtime witness.
(declare bget (-> (b Bytes)
                  (refine I64 (>= 0) (< (blen b)))  ; in-bounds BY PROOF (gated)
                  (refine I64 (>= 0) (< 256))))     ; a byte comes back out
; note: bget is total — no p-err, no exception; the bad call cannot typecheck.

; ---- building: a fresh cell is LINEAR until frozen --------------------
(data BBuf ((0 n I64))                ; length is an erased type index
  (bbuf (ptr I64)))                   ; the raw cell pointer (B-side referent)

(declare bnew (-> (n (refine I64 (>= 0)))
                  (BBuf n)))                        ; fresh zero-filled cell
(declare bput (-> (0 n I64)
                  (1 b (BBuf n))                    ; consume the builder...
                  (refine I64 (>= 0) (< n))         ; init index in bounds
                  (refine I64 (>= 0) (< 256))       ; a byte, not any I64
                  (BBuf n)))                        ; ...and hand it back
(declare bfreeze (-> (0 n I64)
                     (1 b (BBuf n))                 ; consumed for good:
                     Bytes))                        ; write-after-freeze is gone

; ---- derived ops: pure spine over the four primitives -----------------
; NOTE the linear-builder half (BBuf/bnew/bput/bfreeze/copy-into/bcat) is
; expressible TODAY: bput's (< n) bound is bare-var symbolic (landed), and the
; builder discipline is plain QTT linearity. Only the expression-bound faces
; (bget/bslice above/below) wait on edge 3.
(declare copy-into (-> (0 n I64) (1 b (BBuf n)) Bytes I64 (BBuf n)))
; structural recursion on the remaining-count measure;
; each step: (bput n b (+ off i) (bget x i))  ; …

(def bcat (-> Bytes Bytes Bytes)
  (lam (x y)
    (let ((n  (+ (blen x) (blen y)))       ; the erased index, bound once
          (b0 (bnew n))
          (b1 (copy-into n b0 x 0))        ; x's bytes at offset 0
          (b2 (copy-into n b1 y (blen x)))); y's bytes after them
      (bfreeze n b2))))

; GATED FACE (edge 3), like bget: `(<= (blen b))` is an expression bound.
; `(>= lo)` alone is bare-var symbolic and fine.
(declare bslice (-> (b Bytes)
                    (lo (refine I64 (>= 0) (<= (blen b))))
                    (hi (refine I64 (>= lo) (<= (blen b))))
                    Bytes))
; bslice allocates a fresh (- hi lo) cell and copies — cells never alias.
```

- **Knobs to modify:** the byte-range bound (256 here; a word-cell variant
  would drop it); whether `bput` threads the builder by value (shown) or the
  length index also tracks *how much* is initialized (a stricter
  `(BBuf n filled)` two-index variant); the slice-copies-vs-aliases choice
  (copy shown — aliasing would need a lifetime story the arena doesn't have);
  the refinement bounds on `bslice` (half-open `[lo,hi)` shown).
- **Deliberately omitted:** the mechanical copy loops (elided with `; …`);
  `str->bytes`/`bytes->str` codecs (a separate concern layered on top); the
  mach-x64 arena itself (bump pointer, zero-mapping — Category B, not
  expressible here); arena reclamation (bump-only for now); growth/realloc
  (cells are fixed-size at `bnew`).

## 6. Use / modify notes

- **Lands in:** the *builder layer* is NEW surface source (a `lib/bytes.chiral`
  bridge or a prelude extension — the SPEC's call), over the **existing**
  `lib/bytes-tal.chiral` floor library and native arena cells (both BUILT —
  see the §1 correction); `scaffold/chirality/tal.py`'s interpreter stays
  untouched as the reference drop / differential oracle.
- **Conformance target:** the original target (native arena substituted for
  `bytearray`, byte-for-byte vs tal.py) is **already met** — that differential
  is the built state. The residual target: the builder layer's `bcat`/`bslice`
  agree byte-for-byte with the existing prelude `bcat`/`bslice` behavior, and
  write-after-freeze / builder-reuse are *checker* rejections.
- **Open questions:** ~~can E9 decide the dependent bounds~~ — **RESOLVED at
  audit (2026-08-01), split:** bare-var bounds (`(< n)`, `(>= lo)`) discharge
  today (landed 2026-07-06); *expression* bounds (`(< (blen b))`) are outside
  the fragment — edge 3, the same gate as E22's cursor; the gated faces are
  annotated in §5. Does the linear-builder discipline live only at the C
  bridge while tal-level `bput` stays an untyped init-write instruction
  (likely yes — the floor re-checks types, not linearity)? Word size of the
  `[len]` header (one I64 word assumed). Arena reclamation: the linear `BBuf`
  is the natural hook for a region story later (ties E21's ArenaTok / E22).
- **Related:** [[E25-byte-cells]] — E23 (FFI trampoline: native buffers cross
  the seam as these cells), E9 (refinement engine decides the bounds
  predicates), E26 (alarms: result sums stay the error story *above* this
  floor; the floor itself is total).
