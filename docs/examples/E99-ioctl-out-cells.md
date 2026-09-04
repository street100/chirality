---
element: E99
slug: ioctl-out-cells
title: Honest ioctl surface: per-request-family crossings that allocate out-cells INSIDE the wrapper and return fresh values (`nb-tcgets` fd→60B cell, `nb-winsz` fd→8B cell; TCSETS keeps value-in shape); rework term.chiral on top so no surface-allocated Bytes is kernel-mutated (removes the pure-fragment immutability violation that fold/CSE strengthening would miscompile)
kind: BUILD-PROPER
reference_class: OURS/IMPL
ours_source: (none)
status: drafted
updated: 2026-08-09
---

# E99 — Honest ioctl surface: per-request-family out-cell crossings

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E99 — replace the single generic 3-arg `ioctl` crossing (which
  hands the kernel a *surface-allocated* `Bytes` to mutate in place) with
  **per-request-family crossings that allocate the out-cell INSIDE the wrapper
  and return a fresh value**: `nb-winsz` (fd → fresh 8-byte cell, TIOCGWINSZ),
  `nb-tcgets` (fd → fresh 60-byte cell, TCGETS). TCSETS keeps the value-in shape
  because the kernel only *reads* that cell. Rework `term.chiral` on top so no
  surface-allocated `Bytes` is ever kernel-mutated.
- **Kind:** BUILD-PROPER (a designed-but-partially-built seam; one generic
  crossing exists and works, but on an unsound footing).
- **Why chirality needs its own:** the generic `ioctl` crossing is the **only**
  kernel-writing crossing in the tree that mutates a `Bytes` produced by
  `cell-new` (a pure `->`). The purity floor believes that cell is immutable
  zeros, so every post-`ioctl` `bget` is typed "pure" — and a *legal* fold/CSE
  strengthening could constant-fold `tiocgwinsz` to `rows=0/cols=0`. It is sound
  today only because fold/CSE is weak; that is an accident, not a guarantee.
  Every other kernel-writing crossing (`nb-sys-read-t`, sys-tal.chiral:39-53)
  already allocates its out-cell *inside* the wrapper (`ti-bnew` + `ti-bptr`)
  and returns a fresh value. E99 makes ioctl conform to that idiom.

## 2. Research

- **Reference class:** `OURS` — the alloc-inside idiom already used by
  `nb-sys-read-t` (sys-tal.chiral:39-53), `term.chiral`, and `ports.chiral` line 150
  (the generic `ioctl` extern `(=> I64 I64 Bytes I64)`). `IMPL` — Rust `nix`'s
  `ioctl_read!` / `ioctl_write!` macro families.
- 2026-09-04, citation repair: E99 retired the generic `ioctl` extern and H11 split the port floor into nine `.port` registries under `lib/ports/`. The `ports.chiral` line above is kept as a record and has no live successor.
- **Key findings:**
  1. **The direction/size of ioctl's third arg is request-dependent, and legacy
     tty requests (the `0x54xx` block) encode neither** in the request number.
     `TIOCGWINSZ` (0x5413) *writes* 8 bytes back; `TCGETS` (0x5401) *writes*
     ~36; `TCSETS` (0x5402) only *reads*. There is no generic, safe "one ioctl
     wrapper" — which is exactly why `nix` converged on **per-request typed
     macros** (`ioctl_read!` mints a read-direction wrapper that owns its
     out-buffer; `ioctl_write!` a read-only-in wrapper). E99 is that same
     convergence expressed as chirality crossings.
  2. **Oversizing the out-cell is safe; undersizing is UB.** `struct termios`
     is ~36 bytes; a **60-byte** cell is oversized-safe, and `c_lflag` (the raw
     field term.chiral edits) sits at **offset 12** in both the classic and the
     kernel `termios`/`termios2` layouts. `winsize` is 8 bytes: `u16 ws_row` at
     offset 0, `u16 ws_col` at offset 2.
  3. **The fix restores an invariant, not a feature.** The alloc-inside wrapper
     returns a value the caller did not previously hold, so there is no `cell-new`
     zeros-fact for fold to trust: the cell's contents are *unknown* to the pure
     fragment by construction. This is the boundary-sums discipline applied to
     memory provenance — the fresh cell *is* the evidence that a crossing happened.

## 3. Conventional (other-language) approach

C hands the kernel a pointer to caller-owned, mutable storage; the type system
says nothing about who allocates it, its direction, or its size:

```c
struct winsize ws;                    /* caller stack, uninitialised */
ioctl(fd, TIOCGWINSZ, &ws);           /* kernel writes 8 bytes back  */
printf("%d x %d\n", ws.ws_row, ws.ws_col);
```

And the current chirality shape mirrors that C shape — the hazard this element removes:

```chirality
; ports.chiral:150 — the generic crossing (works at runtime, pty-verified)
(declare ioctl (=> I64 I64 Bytes I64))
; term.chiral today:
(let ((cell (cell-new 8)))            ; PURE `->`: floor believes = immutable zeros
  (ioctl fd TIOCGWINSZ cell)          ; kernel mutates `cell` in place — invisible
  (ws-r (bget cell 0) (bget cell 2))) ; "pure" bget over a secretly-mutated cell
```

- **Assumptions it bakes in:** ambient/caller allocation of the out-buffer;
  **hidden mutation** of a value the type system has certified immutable; a
  direction/size the type system cannot see; no proof obligation that the read
  reflects a crossing. A stronger fold/CSE is *entitled* to replace the two
  `bget`s with `0` — the source of a latent miscompile.

## 4. The chirality idea

- **Chirality features in play:** the effect membrane (`->` pure vs `=>` process),
  categories A/B/C (the raw wrapper is category-B substrate under a category-C
  typed crossing), boundary sums (errno-or-value results), and the pure-fragment
  immutability floor.
- **The reframing:** each request family gets its **own crossing that allocates
  its out-cell inside** (`ti-bnew` + `ti-bptr`, the `nb-sys-read-t` idiom) and
  returns a **fresh** `Bytes` — never a surface `cell-new`. Because the returned
  cell is minted by the crossing, the pure fragment has **no prior fact** about
  its contents: reads over it are genuinely pure over an unknown value, and no
  fold can invent `0`. The result is a boundary sum — `WinsizeR` /`TermiosR` —
  so the errno path lives in the signature, not in a sentinel. `TCSETS` is
  *already* honest (value-in, kernel read-only) and keeps its shape.
- **What chirality makes impossible here:** handing the kernel a pointer to a value
  the type system believes is immutable. After E99 there is no crossing that
  mutates surface-allocated `Bytes`; the "kernel wrote here" fact is carried by
  the *freshness of the returned cell*, which fold/CSE cannot see through — so
  strengthening the optimizer can never again fold a live ioctl result to a
  constant.

## 5. Chirality example (fleshed)

```chirality
; ── boundary sums: the crossing result carries its own errno path ──
;    (term.chiral already uses this WinsizeR/TermiosR/RawR family)
(data WinsizeR ()
  (ws-r   (rows I64) (cols I64))
  (ws-err (errno I64)))

(data RawR ()                       ; a fresh, kernel-written cell, or an errno
  (raw-r   (cell Bytes))
  (raw-err (errno I64)))

; ── the crossings: fd IN, a FRESH value OUT (alloc-inside idiom) ──
;    each wrapper does `ti-bnew N` + `ti-bptr` internally, so the kernel only
;    ever writes a cell the wrapper owns — never a surface `cell-new` Bytes.
(declare nb-winsz-raw  (=> (fd I64) RawR))   ; TIOCGWINSZ 0x5413, fresh 8-byte cell
(declare nb-tcgets-raw (=> (fd I64) RawR))   ; TCGETS     0x5401, fresh 60-byte cell

; TCSETS 0x5402 keeps the value-IN shape: kernel only READS the cell, so passing
; a surface Bytes is already honest — no mutation, no fold hazard.
(declare nb-tcsets (=> (fd I64) (cell Bytes) I64))   ; -> errno (0 = ok)

; ── pure decoders: no crossing. The cell is frozen the instant the crossing
;    returns, so these `bget`s are genuinely pure AND total over an unknown value.
(declare rd-u16-le (-> Bytes I64 I64))
(def rd-u16-le
  (lam (c off)
    (+ (bget c off) (* (bget c (+ off 1)) 256))))   ; little-endian u16

(declare winsz-decode (-> RawR WinsizeR))
(def winsz-decode
  (lam (r)
    (case r
      ((raw-err e) (ws-err e))
      ((raw-r c)   (ws-r (rd-u16-le c 0)          ; ws_row at offset 0
                         (rd-u16-le c 2))))))      ; ws_col at offset 2

; ── term.chiral reworked: was `(ioctl fd TIOCGWINSZ <surface cell-new>)`;
;    now fresh-cell crossing + pure decode. No surface Bytes touches the kernel.
(declare tiocgwinsz (=> (fd I64) WinsizeR))
(def tiocgwinsz
  (lam (fd) (winsz-decode (nb-winsz-raw fd))))

; ── pure byte-writer helper: builds a fresh Bytes with u32 at offset
(declare bput-u32-le (-> Bytes I64 I64 Bytes))

; ── the TCSETS path stays value-IN and pure-to-build: bput-u32-le allocates and
;    COPIES, so the cell handed down is a surface value the kernel only reads.
(declare termios-set-raw (=> (fd I64) (base Bytes) I64))
(def termios-set-raw
  (lam (fd base)
    (let ((raw (bput-u32-le base 12 (raw-lflag base))))  ; clear ICANON|ECHO at c_lflag (offset 12)
      (nb-tcsets fd raw))))
; raw-lflag: pure mask of c_lflag — mechanical bit-twiddle elided …
```

- **Knobs to modify:** the request family (mint `nb-<req>-raw` per request:
  its request constant, its cell size, its decoder offsets); oversize the cell
  freely (60 for termios is deliberate headroom); swap `rd-u16-le`/`bput-u32-le`
  for the field widths a given struct needs.
- **Deliberately omitted:** the `ti-bnew`/`ti-bptr` bodies of the category-B
  wrappers (that is sys-tal/native territory, the alloc-inside mechanism already
  proven by `nb-sys-read-t`); the full `termios` field map; the `nb-tcgets-raw`
  decoder (mirror of `winsz-decode` at the `c_lflag` offset); and the fate of the
  old generic `ioctl` extern (see Open questions).

## 6. Use / modify notes

- **Lands in:** the crossing wrappers in **`scaffold/lib/sys-tal.chiral`** (beside
  `nb-sys-read-t`, sys-tal.chiral:39-53) **or** a new **`term-tal`** leaf — this
  home split is **S12(c), AUTHOR-pending** (see Open questions). The surface
  reworks land in `scaffold/lib/scriba/term.chiral` (`tiocgwinsz`, `tcgetattr`,
  `termios-set-raw`); the generic extern lives at `scaffold/lib/ports.chiral:150`.
- **Conformance target:** `tiocgwinsz` under a pty returns the true
  `(ws-r rows cols)` (the runtime-verified TIOCGWINSZ behavior today), and
  `termios-set-raw` still puts the terminal into raw mode — but with **no
  surface-allocated `Bytes` handed to the kernel for mutation**. The negative
  gate: after E99 there is no `cell-new` → `ioctl` mutation pattern anywhere, so
  a *strengthened* fold/CSE cannot fold any live ioctl result to a constant.
- **Open questions:**
  1. **S12(c) — wrapper home (AUTHOR):** put the per-request crossings in
     `sys-tal.chiral` next to `nb-sys-read-t` (keeps all syscall wrappers in one
     leaf; sys-tal grows a tty section), **or** carve a new `term-tal` leaf
     (keeps tty/ioctl specifics out of the generic syscall floor; one more file).
     Present both, no silent resolution.
  2. **Fate of the generic `ioctl` extern (ports.chiral:150):** (a) **retire it**
     — nothing else uses it once term.chiral is reworked, and leaving it standing
     re-admits the surface-mutation hazard; **or** (b) **demote it** to a
     non-surface primitive usable only over wrapper-owned cells (documented,
     narrower type). **Recommend (a) retire**; keep (b) noted as the fallback if
     a future request family needs an escape hatch before its typed wrapper exists.
- **Related:** [[E97-skip-chain-diagnostics]] (boundary sums — the
  `WinsizeR`/`TermiosR`/`RawR` errno-or-value shape reused here);
  [[pattern-boundary-sums]] (the standing directive: the fresh cell *is* the
  crossing evidence); `nb-sys-read-t` (sys-tal.chiral:39-53, the alloc-inside
  precedent).
