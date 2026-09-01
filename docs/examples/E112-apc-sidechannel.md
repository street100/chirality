---
element: E112
slug: apc-sidechannel
title: Structured side-channel framing (APC transport) — encode a `Rendering` tree into an APC envelope + decode it back + a content-hash `block-id` per addressable node (handshake negotiation split to E128)
kind: BUILD-PROPER
reference_class: OURS/PAPER
ours_source: (none — design from TERMINAL-PORT-DESIGN §2/§8 + render.chiral Rendering + vt-parser ps-apc-string)
status: drafted
updated: 2026-08-11
---

# E112 — Structured side-channel framing (APC transport)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E112 — the lossless **(M)-tier** transport under the `Terminal`
  port. Three pieces, full scope: **(1) encode** a scriba `Rendering` tree into an
  **APC** envelope (`ESC _ … ESC \`, silently discarded by non-supporting
  terminals); **(2) decode/parse** an APC envelope back into the *same* `Rendering`
  tree (tables stay tables, sections stay foldable, holes stay addressable);
  **(3) the one-bit capability handshake** `term-structured?` negotiated once at
  acquisition, from which `term-draw` picks the tier.
- **Kind:** BUILD-PROPER — nothing is built. There is no APC serialize/parse
  primitive; `TUI/vt-core/vt-parser.chiral` has a `ps-apc-string` **stub** only
  (collects bytes until ST, then discards them); the envelope framing is an OPEN
  question (`TERMINAL-PORT-DESIGN.md §8.4`).
- **Why chirality needs its own:** this is the wire that makes the two-tier output of
  the `Terminal` seam real. Baseline ANSI (`render-to-ansi-full`, already built) is
  lossy-but-universal; the structured tier ships the `Rendering` tree **as itself**
  so a chirality emulator renders it natively. A *general* typed side-channel keyed to a
  language's own render tree is the open slice — no vendor ships it (§2 prior art).

## 2. Research

- **Reference class:** OURS/PAPER.
  - **OURS:** `TUI/scriba/render.chiral:6-12` (the `Rendering` sum + the
    `render-to-ansi-full` baseline); `TERMINAL-PORT-DESIGN.md` §2 (two-tier output,
    the degrade rule, `term-structured?`), §8.2 (block-id — SPEC-resolved to
    content-hash, dec #4), §8.4 (envelope framing — SPEC-resolved to APC, dec #1;
    handshake byte → E128); `TUI/vt-core/vt-parser.chiral:20,116,173-177`
    (the `ps-apc-string` decode seam).
  - **PAPER / prior art (real, thin):** kitty-graphics and notty's `ESC {`
    structured protocol both ride APC precisely *because non-supporting terminals
    silently discard it*; FinalTerm/iTerm2 FTCS + OSC 133 give command *boundaries*
    only; Arcan's typed-IPC argument. None is a typed side-channel keyed to a
    language's own render tree.
- **Key findings (web-verified against ECMA-48 / ISO-6429, not asserted from
  memory):**
  - **APC** (Application Program Command): 7-bit form = `ESC _` = **`0x1B 0x5F`**;
    8-bit C1 form = **`0x9F`**.
  - **ST** (String Terminator): 7-bit form = `ESC \` = **`0x1B 0x5C`**; 8-bit form
    = **`0x9C`**. A control string is *opening delimiter · graphic chars · ST*.
    (Sources: ECMA-48 §5.4 coded representations, wezfurlong.org/ecma48/04-coding;
    invisible-island xterm ctlseqs; confirmed against the live parser below.)
  - **The live parser already agrees:** `vt-parser.chiral` enters `ps-apc-string` on
    byte **95** (`0x5F`, `_`) after ESC, and every string state terminates on ESC
    (27) → ground — i.e. it already recognises the `ESC \` ST. E112's decoder hooks
    exactly at that `ps-apc-string` case, which today drops `buf`.
  - **APC payload is nominally *graphic* characters** (0x20–0x7E), not arbitrary
    binary — so the payload must be a **printable encoding**, not raw bytes. (This is
    why kitty base64-wraps its APC payloads.) The grammar in §5 is netstring-style
    printable ASCII for exactly this reason.

## 3. Conventional (other-language) approach

Outside chirality this is an ad-hoc byte protocol: printf an escape prefix, some
delimiter-joined fields, a terminator; on the read side, a stringly state machine
that pattern-matches tags and hopes the producer and consumer agree.

```python
# notty/kitty-style: a private escape, fields joined by ';', silently ignored
# by terminals that don't grok the introducer. No typed tree on either end.
def emit_section(title, collapsed, body_bytes):
    payload = b"chirality;s;%d;%s;" % (1 if collapsed else 0, title.encode())
    sys.stdout.buffer.write(b"\x1b_" + payload + body_bytes + b"\x1b\\")

def parse(buf):                      # buf is whatever was between ESC_ and ESC\
    kind, *rest = buf.split(b";")    # stringly dispatch; a bad tag is a KeyError
    if kind == b"s": ...             # or a silent wrong-branch — no coverage check
```

- **Assumptions it bakes in:** the wire is `bytes`, not a typed value; tag dispatch
  is a `str`/`int` compared at runtime (drift between producer and consumer is
  undetectable); a malformed frame throws (`KeyError`/index error) or silently
  mis-parses; `;`-joining breaks the moment a field contains `;`; the effect of
  "write these bytes" is ambient stdout, not a held capability.

## 4. The chirality idea

- **Chirality features in play:** the closed-sum **boundary parse** (parse once, tags as
  values — the standing directive); **result sums** for the decoder (errors are
  values, no throw); **structural recursion / totality** (the parser decreases on a
  cursor, "ran out of input" is a `p-err`, never a hang); the **effect membrane**
  (encode/decode are pure `->`; only `term-draw`'s write crosses `=>`); **ports &
  capabilities** (the write rides the linear `Terminal` cap, no ambient stdout);
  the **I64+Bytes floor** (frame is built from bytes, no floats).
- **The reframing:**
  - **Encode/decode are pure functions.** `enc : (-> Rendering Str)` and
    `dec : (-> Str I64 PR)` never cross the membrane — they transport/repack a value
    (the `RecvR` pattern). Only the final `term-draw` write is `=>`.
  - **The wire round-trips a *value*, not bytes-and-hope.** `dec` reconstructs the
    exact `Rendering` sum; a decode failure is a `p-err` carried as data with the
    cursor, so the blame position exists by construction — no exception, no silent
    wrong branch.
  - **Two tiers, one type, chosen by a held bit.** `term-structured?` answers a
    `Bool` *carried on the `Terminal` cap* (negotiated once at acquisition);
    `term-draw` cases on it: dumb terminal → `render-to-ansi-full` (baseline);
    chirality emulator → `enc-frame` over APC (lossless). Same app, same `Rendering`.
- **What chirality makes impossible here:** you cannot dispatch on a `Str` tag that the
  decoder forgot to handle — `case` over the `Rendering`/tag sum is coverage-checked,
  so a producer/consumer drift is a *type error at build time*, not a runtime
  mis-parse. And you cannot emit the frame without holding the `Terminal` cap — there
  is no ambient `stdout.write`.

## 5. Chirality example (fleshed)

Real chirality surface syntax, copy-and-modify ready. The `Rendering` sum and the
handshake/draw signatures are verbatim from `render.chiral` / `TERMINAL-PORT-DESIGN`.
The fleshed slice round-trips a `text`-inside-a-`section`; the full-tree cases
(`table`/`stream`/`tree`/`hole`) are named in `enc` and left as the obvious
extension (§ "Deliberately omitted").

```chirality
; ── the payload type (verbatim, render.chiral:6-12) ──
(data Rendering ()
  (r-text   (content Str) (bold Bool))
  (r-table  (headers (List Str)) (rows (List (List Rendering))))
  (r-section (title Str) (collapsed Bool) (body Rendering))
  (r-stream (source-id Str))
  (r-tree   (children (List Rendering)) (selected Rendering))
  (r-hole   (label Str)))

; ── APC envelope bytes (web-verified ECMA-48): APC = ESC _ (0x1B 0x5F),
;    ST = ESC \ (0x1B 0x5C). A single-byte Str via pack-u16 (LE) sliced to 1. ──
(def byte->str  (-> I64 Str)  (lam (n) (bytes->str (bslice (pack-u16 n) 0 1))))
(def apc-intro  (-> Unit Str) (lam (u) (str-cat (byte->str 27) (byte->str 95))))  ; ESC _
(def st         (-> Unit Str) (lam (u) (str-cat (byte->str 27) (byte->str 92))))  ; ESC \

; ── printable, APC-legal field grammar (netstring: <declen>:<chars>) ──
;    robust against ANY field content (no delimiter-escaping bug). ──
(def enc-str  (-> Str Str)  (lam (s) (str-cat (str-cat (i64->str (str-len s)) ":") s)))
(def enc-bool (-> Bool Str) (lam (b) (case b (true "1") (false "0"))))

; ── ENCODE: Rendering subtree → printable payload (pure `->`) ──
;    single-char tags: t=text s=section S=stream h=hole T=table r=tree
(def enc (-> Rendering Str)
  (lam (r)
    (case r
      ((r-text content bold)
        (str-cat "t" (str-cat (enc-bool bold) (enc-str content))))
      ((r-section title collapsed body)                 ; body recurses → foldable
        (str-cat "s" (str-cat (enc-bool collapsed) (str-cat (enc-str title) (enc body)))))
      ((r-stream sid)  (str-cat "S" (enc-str sid)))
      ((r-hole label)  (str-cat "h" (enc-str label)))   ; + block-id (content-hash; SPEC §4)
      ((r-table headers rows)      "T?")                ; full-tree: elided here
      ((r-tree children selected)  "r?"))))

(def enc-frame (-> Rendering Str)                        ; APC intro · payload · ST
  (lam (r) (str-cat (apc-intro unit) (str-cat (enc r) (st unit)))))

; ── DECODE: parse-result sums carry the cursor; a failure is a VALUE ──
(data PR () (p-ok (v Rendering) (pos I64)) (p-err (msg Str) (pos I64)))
(data SR () (s-ok (v Str)  (pos I64))       (s-err (msg Str) (pos I64)))
(data BR () (b-ok (v Bool) (pos I64))       (b-err (msg Str) (pos I64)))

(def digit-val (-> Str I64) (lam (c) (- (bget (str->bytes c) 0) 48)))  ; no str->i64 (unlowered in B1)
(def read-len (-> Str I64 I64 (Pair I64 I64))            ; decimal up to ':' — structural on the cursor
  (lam (src pos acc)
    (let ((c (str-sub src pos (+ pos 1))))               ; str-sub = [start,end)
      (case (str-eq c ":")
        (true  (pair acc (+ pos 1)))
        (false (read-len src (+ pos 1) (+ (* acc 10) (digit-val c))))))))
(def dec-str (-> Str I64 SR)
  (lam (src pos)
    (case (read-len src pos 0)
      ((pair len p2) (s-ok (str-sub src p2 (+ p2 len)) (+ p2 len))))))
(def dec-bool (-> Str I64 BR)
  (lam (src pos)
    (let ((c (str-sub src pos (+ pos 1))))
      (case (str-eq c "1") (true (b-ok true (+ pos 1))) (false (b-ok false (+ pos 1)))))))

(def dec (-> Str I64 PR)                                  ; tag → reconstruct the SAME sum
  (lam (src pos)
    (let ((tag (str-sub src pos (+ pos 1))))
      (cond
        ((str-eq tag "t")
          (case (dec-bool src (+ pos 1))
            ((b-ok bold p2)
              (case (dec-str src p2)
                ((s-ok content p3) (p-ok (r-text content bold) p3))
                ((s-err m p) (p-err m p))))
            ((b-err m p) (p-err m p))))
        ((str-eq tag "s")
          (case (dec-bool src (+ pos 1))
            ((b-ok collapsed p2)
              (case (dec-str src p2)
                ((s-ok title p3)
                  (case (dec src p3)                       ; body recurses
                    ((p-ok body p4) (p-ok (r-section title collapsed body) p4))
                    ((p-err m p) (p-err m p))))
                ((s-err m p) (p-err m p))))
            ((b-err m p) (p-err m p))))
        (else (p-err (str-cat "bad tag " tag) pos))))))    ; malformed = a VALUE, not a throw

(def dec-frame (-> Str PR)                                 ; strip APC intro (2) + ST (2), parse payload
  (lam (frame)
    (let ((n (str-len frame))) (dec (str-sub frame 2 (- n 2)) 0))))

; ── THE HANDSHAKE + tier selection (TERMINAL-PORT-DESIGN §2, verbatim sigs) ──
;    term-structured? answers a Bool CARRIED on the linear Terminal cap.
(declare term-structured? (=> (1 t Terminal) (Pair Bool Terminal)))
(declare term-write       (=> (1 t Terminal) Str DrawR))          ; raw byte write over the cap
(declare render-to-ansi-full (=> Rendering (Pair I64 I64) Unit))  ; baseline tier (already built)

(def term-draw (=> (1 t Terminal) Rendering DrawR)
  (lam (t r)
    (case (term-structured? t)
      ((pair structured t2)
        (case structured
          (true  (term-write t2 (enc-frame r)))            ; (M) emulator → lossless APC
          (false (let ((_ (render-to-ansi-full r (pair 24 80)))) (draw-ok t2))))))))  ; (R) → baseline ANSI
```

- **Knobs to modify:** the tag alphabet + field grammar (netstring vs a
  length-then-payload binary once an APC-binary transport is chosen); the
  block-id field on `r-section`/`r-hole` (the addressing surface — content-hash,
  SPEC §4); which `Rendering` constructors the full serializer covers.
- **Deliberately omitted:** the `table`/`tree` recursion (mechanical: a `count;`
  prefix then that many sub-nodes, same shape as `section`'s single-child recurse);
  UTF-8 multibyte length accounting (`str-len` here is byte length — fine for the
  ASCII slice, a real impl reuses `utf8.chiral`); the emulator-side wiring into
  `ps-apc-string` (§6).

## 6. Use / modify notes

- **Lands in:** a new `TUI/vt-core/apc-codec.chiral` (or `TUI/scriba/apc.chiral`) for
  `enc`/`dec`/`enc-frame`/`dec-frame`; the `term-draw` tier-selection folds into the
  `Terminal` port impl beside `render-to-ansi-full`; the **decoder hooks into
  `TUI/vt-core/vt-parser.chiral` `ps-apc-string`** (line 20 / case 173-177) — instead
  of dropping `buf` on ST, flip the accumulated codepoints to a `Str` and call
  `dec-frame`, emitting a `Rendering` (or a chirality-specific `Action`) up to the
  compositor.
- **Conformance target:** `dec (enc r) == r` structurally for every `Rendering`
  subtree (the round-trip proven below for `section`⊃`text`); and a non-supporting
  terminal receiving `enc-frame r` shows **nothing** (APC discarded) rather than
  garbage — the degrade guarantee.
- **Ground truth (B1, verbatim):** the §5 encode → APC frame → decode → structural
  equality of `(r-section "Diagnostics" false (r-text "no crossing" true))` compiles
  and runs under B1 (prelude prepended, no other imports; `str->i64`/`str-sub`
  substituted per the notes above). Frame length = **36 bytes** (`ESC _` + 32-byte
  payload `s011:Diagnosticst111:no crossing` + `ESC \`); the program returns **42**
  on structural match:
  ```
  compile rc=0
  ROUND-TRIP run rc=42   (42 = structural equality PASS)
  ```
- **Questions raised here, RESOLVED by the SPEC (`docs/elements/specs/E112-…-SPEC.md`):**
  1. **Envelope framing — APC vs private DCS** (`§8.4`). **RESOLVED → APC** (spec
     dec #1): APC has essentially no standard consumer so a chirality-private payload
     cannot collide, whereas DCS (`ESC P`) is claimed by Sixel/DECRQSS; the decode
     seam `ps-apc-string` is *already* wired at `ESC _`. Payload stays **printable**
     (0x20–0x7E) via the netstring grammar. The **handshake byte** is NOT part of
     E112 — it **split out to its own element `FMT·E128`** (2026-08-12); E112
     consumes the `term-structured?` `Bool`, E128 negotiates it.
  2. **Block-id scheme** (`§8.2`). **RESOLVED → content-hash** (spec dec #4, author
     `TUI-PRIMITIVES.md`): `block-id : (-> Rendering Str)`, FNV-1a-64 over the
     node's identity bytes (section = title+body, *excluding* `collapsed` so a fold
     doesn't re-key; hole = label) → 16 hex chars, **derived not stored** so
     `render.chiral` is untouched, emitted per section/hole and verified on decode.
     No longer an open TODO slot — fully specified in the SPEC §4.
- **Related:** [[E112-apc-sidechannel]] · the `Terminal` port seam
  (`TERMINAL-PORT-DESIGN.md`) · `render.chiral` `Rendering` / `render-to-ansi-full`
  (baseline tier) · `vt-core/vt-parser.chiral` `ps-apc-string` (decode seam) ·
  [[pattern-boundary-sums]] (tags-as-values).
