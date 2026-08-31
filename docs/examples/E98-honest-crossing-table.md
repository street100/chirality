---
element: E98
slug: honest-crossing-table
title: Honest crossing table: implement `nb-read-key` as a real raw read (ti-bnew + ti-bptr + `read(0,ptr,n)` + return cell, matching `nb-sys-read-t`); retire `nb-read-keyseq`/`nb-sys-spawn`/`nb-null-port`/`nb-sys-env-get` stubs — remove externs (ports.chiral), wraps rows (crossing-wraps.chiral), sys-lib entries (sys-tal.chiral), sys-rows (target-linux.chiral); scriba key-sequence assembly moves to its pure key-parser
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: reviewed
updated: 2026-08-09
---

# E98 — Honest crossing table: implement `nb-read-key` as a real raw read (ti-bnew + ti-bptr + `read(0,ptr,n)` + return cell, matching `nb-sys-read-t`); retire `nb-read-keyseq`/`nb-sys-spawn`/`nb-null-port`/`nb-sys-env-get` stubs — remove externs (ports.chiral), wraps rows (crossing-wraps.chiral), sys-lib entries (sys-tal.chiral), sys-rows (target-linux.chiral); scriba key-sequence assembly moves to its pure key-parser

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E98 — make the crossing table *honest*: implement `nb-read-key`
  as a real raw read (`ti-bnew` fresh cell + `ti-bptr` + `read(0, ptr, n)` +
  return the cell, mirroring `nb-sys-read-t`), and **retire** four live-but-fake
  rows — `nb-read-keyseq`, `nb-sys-spawn`, `nb-null-port`, `nb-sys-env-get` —
  by deleting their externs (`ports.chiral`), wraps rows (`crossing-wraps.chiral`),
  sys-lib wrappers (`sys-tal.chiral`), and the dead `nb-sys-mremap` sys-row
  (`target-linux.chiral`) that points at a wrapper which does not exist. Scriba's
  key-*sequence* assembly moves out of the crossing and into its **pure**
  key-parser.
- **Kind:** BUILD-PROPER (finish one real crossing; the rest is honest removal).
- **Why chirality needs its own:** a stub registered behind a live table row is a
  **lying row** — the row asserts "this crossing exists and works," the wrapper
  returns `-1` / an empty cell / issues `read(fd, cell, 0)` with **no**
  `ti-bptr` (the handle passed as a pointer, count zero: double-broken). This
  exact class produced the three-misdiagnosis cascade in
  `.planning/SCRIBA-UNBLOCK-MAP.md`. Removal is the honest form of "not built";
  the one crossing that *should* exist (`nb-read-key`) gets built for real.

## 2. Research

- **Reference class:** OURS — `sys-tal.chiral` (the `nb-sys-read-t` golden idiom
  at :39-53; the stub sys-lib entries at :~405-427), `crossing-wraps.chiral`
  (wraps rows), `ports.chiral` (externs), `target-linux.chiral` (sys-rows),
  `scaffold/lib/scriba/key-parser.chiral` (the pure consumer).
- **Key findings:**
  1. **The read idiom is cell-allocated, never surface-value-aliased.**
     `nb-sys-read-t` allocates a *fresh* cell with `(ti-bnew 2 1)`, takes its
     pointer with `(ti-bptr 3 2)`, issues `(ti-sys 4 0 …)` = `read(fd=0,
     buf=ptr, count=1)`, then branches on the returned byte count
     (`op-lei` vs `ti-const 0`) — EOF/short-read is a value, and the cell (never
     a caller value) is what the kernel writes into. `nb-read-key` must copy
     this shape exactly: fresh cell + `ti-bptr` + `ti-sys read` + return cell.
  2. **The current `nb-read-key`/`nb-read-keyseq` are double-broken.** They
     issue `read(fd, cell, 0)` — the *cell handle* is passed where a raw
     pointer belongs (no `ti-bptr`), and the count is `0` (a read of zero
     bytes). The fix is not a tweak; it is replacing the body with the idiom
     above.
  3. **The crossing returns `Bytes`; parsing is pure chirality downstream.** The
     kernel hands back raw input bytes. Turning `\x1b[A` into an arrow-key
     *value* is a total, pure function — it belongs in scriba's
     `key-parser.chiral`, off the effect membrane. So `nb-read-key`'s face is a
     raw-bytes signature; `Key`/`KeySeq`/`Keymap` data live with the parser.
  4. **Four rows have no honest implementation.** `nb-sys-spawn` returns `-1`,
     `nb-null-port` returns `-1`, `nb-sys-env-get` returns an empty cell,
     `nb-read-keyseq` is the broken zero-read; and `nb-sys-mremap` is a sys-row
     with no wrapper at all. Each is registered LIVE. The catalog delta is:
     delete the row + extern + wrapper for all four (+ the orphan mremap row).

## 3. Conventional (other-language) approach

How this is done outside chirality — a C/POSIX terminal front-end. The read and the
key-decode are fused, buffers are ambient, and unimplemented features are papered
over with sentinel returns that the caller is trusted to remember to check.

```c
/* One function reads AND decodes — effect and parse are fused. */
int read_key(void) {
    char c;
    if (read(0, &c, 1) != 1) return -1;          /* -1 sentinel = EOF-or-error */
    if (c != '\x1b') return c;                    /* plain byte */
    char seq[3];
    if (read(0, &seq[0], 1) != 1) return '\x1b';  /* lone ESC */
    if (read(0, &seq[1], 1) != 1) return '\x1b';
    if (seq[0] == '[') switch (seq[1]) {          /* decode inside the read */
        case 'A': return ARROW_UP;  case 'B': return ARROW_DOWN; /* … */
    }
    return '\x1b';
}

/* Unbuilt features ship as stubs that LIE via the return type. */
pid_t spawn(char **argv)   { return -1; }         /* "failed"? or "never built"? */
int   null_port(void)      { return -1; }         /* caller can't tell */
char *env_get(const char *k){ return ""; }        /* empty ≠ absent ≠ unimplemented */
```

- **Assumptions it bakes in:** effect and parse **fused** (the decode logic runs
  inside the crossing, so it can never be reasoned about as pure); **ambient
  buffers** (`&c` is a raw stack pointer, no allocation discipline); **sentinel
  overloading** (`-1`/`""` conflate "runtime failure," "EOF," and "this feature
  was never implemented" — three distinct facts collapsed into one untyped
  value); and **a registration table that cannot express "absent"** — a stubbed
  symbol is indistinguishable from a working one until it is called.

## 4. The chirality idea

chirality refuses the fusion and refuses the lie.

- **Chirality features in play:** the effect membrane (`=>` crossing vs `->` pure);
  categories A/B/C (the raw `read` is **B, untyped substrate**; the key decoder
  is **A, typed & total**); **boundary sums** (`docs/pattern-boundary-sums.md`,
  standing directive) — parse the raw bytes ONCE into a closed `Key` sum;
  cell-allocation discipline (`ti-bnew`+`ti-bptr`: the kernel writes only into a
  wrapper-owned cell, never a surface value); totality (the parser is structural
  recursion, "ran out of bytes" is a returned value not a hang).
- **The reframing:** the crossing shrinks to its irreducible core — *acquire raw
  bytes* — and returns `Bytes`. Everything the C version did *inside* `read_key`
  (recognising `\x1b[A` as an arrow) becomes a **pure** `parse-keys : Bytes ->
  KeySeq` in `key-parser.chiral`, a total `case` over a closed `Key` sum. Because
  the classification is a **value the parse produces** (not a re-decode at each
  call site), coverage is kernel-checked and the decoder stays off the effect
  membrane. Key-*sequence* assembly (`nb-read-keyseq`'s old job) is just this
  pure parser folding over the bytes — so the whole second crossing evaporates.
- **What chirality makes impossible here:** you **cannot** ship a lying row. A
  sentinel-`-1` stub is not a legal way to say "unbuilt" — the honest encoding
  is *removal*: no extern, no wraps row, no wrapper, no sys-row. A caller of a
  removed crossing fails **at check time** (unbound symbol), not at runtime with
  an ambiguous `-1`. And because the decoder is `->`, no key-parsing bug can ever
  masquerade as an I/O effect: the two failure domains are typed apart.

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
; ── The ONE real crossing: acquire raw bytes. Nothing else. ──────────────
; Face is a raw-bytes signature (S12(a) — spec fixes the exact arity). The
; crossing takes the stdin fd + a max count and returns the bytes read.
; `=>` because it crosses the membrane; it performs read(2) and NOTHING pure.
(declare nb-read-key (=> (fd I64) (n I64) Bytes))

; Wrapper body copies nb-sys-read-t EXACTLY (sys-tal.chiral:39-53):
;   ti-bnew  — allocate a FRESH cell of n bytes (kernel-writable, wrapper-owned)
;   ti-bptr  — take its raw pointer (this is the piece the broken stub OMITTED)
;   ti-sys 0 — read(fd, ptr, n)   ; syscall nr 0
;   branch on the returned count (op-lei vs const 0): short/EOF is a VALUE
;   return the cell (never a surface value — the kernel only ever wrote the cell)
; … TAL body elided — it is nb-sys-read-t with count `n` instead of the fixed 1.

; ── The PURE consumer: bytes → keys, off the effect membrane. ────────────
; Boundary sum (docs/pattern-boundary-sums.md): the byte classification is
; retyped ONCE into a closed sum, so every downstream `case` is exhaustive.
(data Arrow () (a-up) (a-down) (a-left) (a-right))
(data Key ()
  (k-char (c I64))        ; a plain printable byte
  (k-ctrl (c I64))        ; Ctrl-<c>
  (k-esc)                 ; a bare ESC (no CSI followed)
  (k-arrow (dir Arrow)))  ; a decoded CSI arrow — the reason IS the value

; A parsed run of keys + how many bytes it consumed (errors-are-values: a
; truncated escape returns k-esc + the bytes it did consume, never a hang).
(data KeySeq () (kseq (keys (List Key)) (used I64)))

; parse-esc : decode a CSI escape sequence. PURE (`->`).
; Elided body — the mechanical byte fold over the `[` + final byte.
(declare parse-esc (-> Bytes I64 KeySeq))

; cons-key : prepend a single Key onto a KeySeq. PURE (`->`).
(declare cons-key (-> Key KeySeq KeySeq))

; parse-keys : total, structural recursion on the byte cursor. PURE (`->`).
(declare parse-keys (-> Bytes I64 KeySeq))
(def parse-keys
  (lam (bs i)
    (case (not (<i i (blen bs)))             ; cursor past end?
      (true  (kseq nil i))
      (false
        (let ((b (bget bs i)))
          (case (=i b 27)                    ; 0x1b = ESC → try to decode a CSI
            (true  (parse-esc bs i))         ; may yield k-arrow or a lone k-esc
            (false (cons-key (byte->key b)   ; plain/ctrl byte → a Key value
                             (parse-keys bs (+ i 1))))))))))

; byte->key : the boundary sum itself — one total classification, no re-decode.
(declare byte->key (-> I64 Key))
; … maps control range → (k-ctrl b), printable → (k-char b); parse-esc reads
;   the '[' + final byte and returns (k-arrow a-up) etc., or (k-esc) on a lone
;   ESC. Both are pure structural folds — elided.
```

- **Knobs to modify:** the `nb-read-key` face — arity/argument order of
  `(fd I64) (n I64)` (S12(a), spec's call); the `n` read-count (1 for
  char-at-a-time like `nb-sys-read-t`, larger to drain a paste burst); the `Key`
  sum's constructor set (add `k-fn`, `k-home`, mouse events as scriba grows);
  which fd the crossing reads (0 = stdin, or a passed terminal port).
- **Deliberately omitted:** the full CSI grammar in `parse-esc` (a mechanical
  byte fold); the TAL wrapper bytes (mirror `nb-sys-read-t` verbatim); the
  raw-mode termios setup (E already covered by `RawR`/`TermiosR` in `term.chiral`);
  and — critically — **any wrapper for the four retired rows**: their honest
  form is *deletion*, shown in §6, not code here.

## 6. Use / modify notes

- **Lands in (five files, one build + four honest deletes):**
  - `scaffold/lib/scriba/sys-tal.chiral` — replace the broken `nb-read-key`
    body (the `read(fd,cell,0)` no-`ti-bptr` stub, :~405-427) with the
    `nb-sys-read-t` idiom (:39-53); **delete** the `nb-read-keyseq`,
    `nb-sys-spawn`, `nb-null-port`, `nb-sys-env-get` sys-lib wrappers.
  - `scaffold/lib/ports.chiral` — retype the `nb-read-key` extern to the raw
    `Bytes` face; **delete** the externs for the four retired crossings.
  - `scaffold/lib/crossing-wraps.chiral` — keep/fix the `nb-read-key` wraps row;
    **delete** the four retired wraps rows.
  - `scaffold/lib/target-linux.chiral` — **delete** the orphan `nb-sys-mremap`
    sys-row (points at a nonexistent wrapper).
  - `scaffold/lib/scriba/key-parser.chiral` — home of the pure `parse-keys` /
    `Key` / `KeySeq`; absorbs the key-*sequence* assembly the old crossing faked.
- **Conformance target:** (1) `nb-read-key` on stdin returns the actual bytes
  typed (differentially vs the py oracle's `read`), allocating a fresh cell and
  writing only into it — byte-identical to the `nb-sys-read-t` path for count 1;
  (2) after removal, a program referencing any of the four retired symbols fails
  **at check time** (unbound), and the full suite stays green with the four rows
  gone from every table; (3) `parse-keys` decodes `\x1b[A` → `(k-arrow a-up)` and
  a lone `\x1b` → `(k-esc)` as a pure total function.
- **Open questions:**
  - **S12(b) — RESOLVED (2026-08-09):** the author ratified retiring the
    `nb-read-keyseq`/`nb-sys-spawn`/`nb-null-port`/`nb-sys-env-get` stubs
    (+ the `nb-sys-mremap` orphan). Their honest form is deletion: no extern,
    no wraps row, no wrapper, no sys-row.
  - **S12(a):** the exact `nb-read-key` signature — `(=> I64 I64 Bytes)` as
    drafted, vs a port-parameterised face `(=> (1 p TermPort) I64 Bytes)` if the
    stdin fd should be a held capability rather than an ambient `0`.
  - Whether `parse-keys` should stream (return unconsumed-bytes tail for a
    partial escape spanning two reads) or assume a whole sequence per read.
- **Related:** [[E97-skip-chain-diagnostics]] (the boundary-sum exemplar this
  mirrors), [[pattern-boundary-sums]] (the standing directive), the effect
  membrane (`->` vs `=>`) and the `nb-sys-read-t` crossing idiom.
