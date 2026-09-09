---
element: E151
slug: ord-dedup
title: **Give string comparison an owner** — the `string` module owns canonical `str-cmp : (-> Str Str Ord)`, `str-lower`/`str-upper`, `str-trim`, `str-replace`, `str-pad`, homed in `scaffold/lib/string-utils.chiral`. Deliverable INCLUDES retiring the duplicates.
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: drafted
updated: 2026-08-22
---

# E151 — **Give string comparison an owner** — the `string` module owns canonical `str-cmp : (-> Str Str Ord)`, `str-lower`/`str-upper`, `str-trim`, `str-replace`, `str-pad`, homed in `lib/prelude/string.chiral`. Deliverable INCLUDES retiring the duplicates.

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E151 — **give string comparison and the text primitives an owner.**
  Not "add a standard library": *stdlib* is not a legible category in chirality, because
  a module "is individuated by its type, not its subject… Not a file. Not a folder.
  Not a topic/subject" (`docs/banks/module.md:37,64`; the framing was explicitly
  dropped in commit `b9162b3b`). The element is the **ownership** relation — which
  module owns `str-cmp`, `str-lower`, `str-upper`, `str-trim`, `str-replace`,
  `str-pad` — phrased in the ledger as "Give string comparison an owner"
  (`docs/elements/ledger.md:274`, category `VAL · Pure value modules`, renamed from
  "LIB · Standard library" on 2026-08-22, `docs/elements/ledger.md:258`). The file's
  slug `ord-dedup` is a legacy misnomer the ledger row itself records: `Ord`
  de-duplication is a *consequence* of importing, not the element (see §4).
- **Kind:** BUILD-PROPER.
- **Why chirality needs its own:** an unowned name is re-declared by every consumer.
  Measured today (the same scan `tools/ledger-lint/ledger-lint.py` check L runs, over
  `scaffold/lib/**` + `TUI/**`):
  - `^(def str-cmp ` in **3** files — `scaffold/lib/string-utils.chiral:80` (the
    canonical one, landed as slice **E151a**), plus the two surviving ad-hoc copies
    `scaffold/lib/ty-cmp.chiral:34` and `scaffold/lib/row-infer.chiral:35`.
  - two further comparators that are the *same function under a dodged name*:
    `ar-str-cmp` (`scaffold/lib/asm-reloc.chiral:79`) and `cb-str-cmp`
    (`scaffold/lib/compile-back.chiral:128`). The prefixes are not style — they are
    the flat-emitted-label workaround (**E154**), which is exactly the mechanism that
    makes modules clone rather than import.
  - `^(data Ord ()` in **4** files — `scaffold/lib/collections.chiral:156`,
    `scaffold/lib/ty-cmp.chiral:16`, `scaffold/lib/row-infer.chiral:21`, and
    `TUI/samples/collections.chiral:156` (a hardlinked foundation copy; that fourth
    one is an A3 duplicate-module artefact and belongs to **E155**, not here —
    `tools/ledger-lint/ledger-lint.py:489-491`).
  - text primitives homed inside the orchestration app for want of a shelf:
    `str-lower` at `scaffold/lib/manas/chatter/router.chiral:46`, `str-trim` at
    `scaffold/lib/manas/core/flow.chiral:430`.

  This is what the **L ownership ratchet** measures (`tools/ledger-lint/ledger-lint.py:497-498`:
  "A shared name defined in N files has no owning module; N must never grow").
  It is a **ratchet, not an absolute** — the tree *has* these violations, so the
  check records today's counts as a baseline (`tools/ledger-lint/ledger-lint.py:494` —
  `OWNERSHIP_BASELINE`, `str-cmp`: **3**, `data Ord`: 4, recorded and corrected
  2026-08-22; the `str-cmp` figure was briefly 4 by counting the already-prefixed
  `ar-str-cmp`/`cb-str-cmp` as the bare name, `tools/ledger-lint/ledger-lint.py:484-488`) and
  fails only on growth. Lowering that baseline is part of E151b's deliverable,
  not a side effect.

  **What consolidation does and does not buy.** It does *not* turn divergence into
  a syntax error — the opposite is true today: adding `(import "string-utils")` to a
  module that already defines `str-cmp` **double-defines the name in a combined leaf
  blob** (`prog/prapanca/core/match.chiral:15-18`, a shipped SPEC decision — the
  same note also records that `string-utils`' `str-contains` takes its arguments in
  the reverse order, `(needle s)` vs `(haystack needle)`; the *other* ad-hoc copy of
  that name, `TUI/scriba/help.chiral:198`, takes `(haystack needle)` as well — so
  `str-contains` is defined in **3** files, `string-utils.chiral:22` /
  `match.chiral:19` / `help.chiral:198`, and only the owner's order is the odd one out).
  Retiring a copy therefore
  means *deleting* the local definition and importing, not importing alongside it.
  What it buys is an owner: one definition to reason about, one place a fix lands,
  and a ratchet that mechanically refuses regrowth.

## 2. Research

- **Reference class:** OURS — the surviving ad-hoc comparators (`ty-cmp.chiral:34`,
  `row-infer.chiral:35`, and the renamed `asm-reloc.chiral:79` / `compile-back.chiral:128`),
  the app-homed text primitives (`router.chiral:46`, `flow.chiral:430`), and the
  repeated `Ord` declaration across the compiler.
- **Key findings:**
  1. Every `Map`-like structure keyed by `Str` needs a total comparator
     `(-> Str Str Ord)` — `m-insert`/`m-lookup` take the comparator as an explicit
     argument (`scaffold/lib/collections.chiral:228` `m-lookup`, `:240` `m-insert`).
     The comparator is therefore a
     genuinely shared value, and re-declaring it per consumer is an *ownership* gap,
     not a missing feature: nothing about it is unbuilt, it simply has no owner.
  2. `Ord` is declared identically in each consumer —
     `(data Ord () (lt) (eq) (gt))` at `scaffold/lib/collections.chiral:156`,
     `scaffold/lib/ty-cmp.chiral:16`, `scaffold/lib/row-infer.chiral:21`, plus the
     hardlinked `TUI/samples/collections.chiral:156`. (Note the constructor order and
     the empty parameter list: `()` then `(lt) (eq) (gt)`.) `collections` is already
     the de-facto owner — `string-utils.chiral:7` imports it precisely for `Ord`.
  3. **E151a has landed** — this is no longer a skeleton. `scaffold/lib/string-utils.chiral`
     is now 179 lines and already defines `str-cmp` (:80), `str-lower` (:105),
     `str-upper` (:121), `str-trim` (:152) and `str-replace` (:175) beside the
     original `str-starts-with` / `str-strip-prefix` / `str-contains` / `str-split`.
     Every internal helper carries an `su-` prefix as the deliberate E154 collision
     guard (`string-utils.chiral:51-55`). It is gated at runtime by
     `scaffold/tests/samples/e151_string_stdlib.chiral`, which exits 0 iff every case
     is right — a *runtime* gate on purpose, because `string-utils` is a shelf module
     nothing in a shipping blob links yet, so the self-host fixpoint cannot catch a
     bug in it (that file's own header, lines 5-9). `str-pad` from the catalog row is
     the one function still absent (no definition anywhere in the tree).
  4. So the **remaining** work is **E151b: retire the duplicates by making consumers
     import.** It touches four modules — `ty-cmp`, `row-infer`, `asm-reloc`,
     `compile-back` — but only two of them are actually *in* the compiler blob:
     `scaffold/build/blob.chiral` carries `cb-str-cmp` (:9075) and `ar-str-cmp`
     (:9557), exactly one `data Ord` (:2001, collections'), and no bare `str-cmp`
     at all. So unlike E151a the self-hosting fixpoint check applies — but only to
     `asm-reloc`/`compile-back`: the binary B1 builds from the blob, re-run over the
     same blob, must byte-reproduce itself. That is a **B2-vs-B3** comparison, never
     against `B1` — measured 2026-08-22, the committed `B1` differs from the binary
     it builds while B2 and B3 are byte-identical, i.e. `B1` is one generation stale
     and the fixpoint holds. `ty-cmp` and `row-infer` are gated by their own consumer
     blobs instead (see §6).
  5. **L ratchet, stated correctly** (`tools/ledger-lint/ledger-lint.py:497-498`): a shared name
     defined in N files has no owning module, and N must never grow. The baseline is
     today's count (`str-cmp` 3 / `data Ord` 4), not 2, and the check fails only on
     growth. E151b's deliverable
     includes lowering the `str-cmp` baseline toward 1.

## 3. Conventional (other-language) approach

Python's approach to comparison and string utilities:

```python
# Comparison: use built-in operators, return untyped int or bool
def str_cmp(a, b):
    if a < b: return -1
    elif a > b: return 1
    else: return 0

# String utilities: mutable and immutable mixed, no type constraint
def str_lower(s):
    return s.lower()  # ambient: no owner, no import, no signature to check against

def str_trim(s):
    return s.strip()  # whitespace set is the runtime's business, not the caller's

# Maps keyed by string: every data structure can redefine comparison locally
class StrMap:
    def __init__(self):
        self.data = {}
    
    def _cmp(self, a, b):
        # Each StrMap redefines comparison — no shared contract
        if a < b: return -1
        elif a > b: return 1
        else: return 0
    
    def insert(self, key, val):
        self.data[key] = val  # relies on Python's ambient key comparison
```

- **Assumptions it bakes in:**
  - **Untyped comparison results** (integers `-1`, `0`, `1` encode meaning; no type tag).
  - **Ambient allocation** (strings are interned/heap-allocated; memory model is implicit).
  - **Multiple definitions, same name**: Each module that needs a comparator defines it locally; redefinition is silent, no error if they drift.
  - **Partiality**: No proof that comparison is total; undefined behavior on invalid inputs is possible (e.g., comparing incomparable types).
  - **Ambient definition**: `str.lower`/`str.strip` are builtins nobody imports and nobody owns; their semantics (which bytes count as whitespace, what casing means above ASCII) are the runtime's, unstated at every call site.
  - **No ownership** of the canonical comparison function; if two modules disagree on comparison semantics, the conflict is invisible until runtime.

## 4. The chirality idea

- **Chirality features in play:** module individuation (a module is "individuated by
  its type, not its subject… Not a file. Not a folder. Not a topic/subject",
  `docs/banks/module.md:37,64`) · category A purity + totality (`->` throughout;
  the order is structural on a shrinking byte index) · **explicit comparator
  passing** — `m-insert`/`m-lookup` take `(-> K K Ord)` as an argument
  (`collections.chiral:240`), so ordering is a *value*, never an ambient method ·
  and the **one flat emitted-label namespace** at the metal altitude
  (cataloged as **E154**).

- **The reframing — ownership, not a shelf.** Python's answer is "put it in a
  string module and import it"; chirality has no such category to put it in. What
  makes `string-utils` the right home is not that it is *about* strings — it is
  that it is the single typed process that **owns** the inhabitant of
  `(-> Str Str Ord)` that `Map Str V` needs. Ownership is the whole element:
  `Ord` itself is *not* in scope here, because `collections` already owns it
  (`collections.chiral:156`) and `string-utils.chiral:7` imports `collections`
  precisely to get it. The `Ord` re-declarations in `ty-cmp`/`row-infer` are not
  a second deliverable — they fall out of importing, because a module that imports
  `string-utils` transitively receives `collections`' `Ord` and must therefore
  *drop* its own.

- **What chirality makes impossible here — and what it does not.** Coexistence is
  impossible: two definitions of the same name in one blob are a **compile
  refusal**, not a silent last-writer-wins. Measured with `B1` on hand-assembled
  blobs (2026-08-22):

  | blob | B1 verdict |
  |---|---|
  | `prelude + collections + string-utils` (+ a trivial `compile-main`) | exit 0, runs |
  | …plus a second `(def str-cmp …)` | `duplicate label (an object def collides with the linked runtime): str-cmp` |
  | …plus a second `(data Ord () …)` | `load: data redeclared: Ord` |

  Two different refusals at two different altitudes: the duplicate **type** is
  caught at *load* by the checker's type-identity judgment; the duplicate
  **function** is caught at *emit* by the flat label space. The `Ord` one fires
  first, which is why a half-converted co-blob reports `data redeclared: Ord` and
  never gets far enough to mention `str-cmp`.

  What chirality does **not** make impossible is the clone. The flat namespace makes
  `(import "string-utils")` *cost* something, so the cheap move is to write a
  prefixed copy — which is exactly what `ar-str-cmp` (`asm-reloc.chiral:79`) and
  `cb-str-cmp` (`compile-back.chiral:128`) are, and what
  `prapanca/core/match.chiral:15-18` records as a shipped SPEC decision. The pressure
  is not hypothetical or limited to functions: **constructors share the same flat
  space too** — co-blobbing `qtt.chiral` (`(data Qty () (q0) (q1) (qw))`, `:14`) with
  `effects.chiral` (`(data Qtt () (q0) (q1) (qw))`, `:32`) yields
  `load: q1 checked against a different data type`. That refusal is *order-sensitive*:
  it fires with `qtt` first, while with `effects` first the later `Qty` wins the
  constructor names and the blob compiles — collision, not commutativity, is what the
  loader guarantees. A co-load hazard of exactly this kind is why
  `row-infer.chiral:18-20` inlines its own comparator "so this stays a lean leaf",
  though the clash that comment actually names is `data.chiral` (dragged in by
  `ty-cmp`) against `closconv` under the sig-driver, not this one. So the constraint
  chirality supplies is *refusal on collision*; the thing
  that actually retires the clones is **an owner plus the L ratchet**
  (`tools/ledger-lint/ledger-lint.py:497`), and E151b is the act of paying the import cost once
  per consumer so the ratchet can be tightened.

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready. Every
form below was assembled into a blob and run through `./scaffold/build/B1`
(`ulimit -s unlimited`); the verdicts quoted are B1's own.

```chirality
; ═══════════════════════════════════════════════════════════════════════════
; BEFORE — lib/typing/ty-cmp.chiral:16-34, four defs nothing else may share
; ═══════════════════════════════════════════════════════════════════════════
(import "data")            ; the Ty ADT + prelude bytes ops

(data Ord () (lt) (eq) (gt))                          ; ← collections already owns this

(def cmp-i64 (-> I64 I64 Ord)                         ; ← KEEP: ty-cmp's own, not shared
  (lam (x y) (case (<i x y) (true (lt)) (false (case (<i y x) (true (gt)) (false (eq)))))))
(def then (-> Ord Ord Ord) (lam (o k) (case o ((eq) k) ((lt) (lt)) ((gt) (gt)))))

(declare cmp-bytes (-> Bytes Bytes I64 Ord))          ; ← DELETE: str-cmp's only callee
(def cmp-bytes (lam (ba bb i) ; … the byte walk …
  ))
(def str-cmp (-> Str Str Ord)                         ; ← DELETE: the unowned copy
  (lam (a b) (cmp-bytes (str->bytes a) (str->bytes b) 0)))

; ═══════════════════════════════════════════════════════════════════════════
; AFTER — the whole conversion is one added import and three deletions
; ═══════════════════════════════════════════════════════════════════════════
(import "data")            ; the Ty ADT + prelude bytes ops
(import "string-utils")    ; E151b: Ord (via collections) + the canonical str-cmp

; `data Ord`, `cmp-bytes` and `str-cmp` are GONE — they arrive through the import.
; Only genuinely-local helpers stay; they are not shared names and need no prefix.
(def cmp-i64 (-> I64 I64 Ord)
  (lam (x y) (case (<i x y) (true (lt)) (false (case (<i y x) (true (gt)) (false (eq)))))))
(def then (-> Ord Ord Ord) (lam (o k) (case o ((eq) k) ((lt) (lt)) ((gt) (gt)))))

; every call site is UNCHANGED — the imported str-cmp has the same name, the same
; type, and the same byte-lexicographic semantics as the copy it replaces.
(def ty-cmp (lam (a b)
  (case (cmp-i64 (ty-rank a) (ty-rank b))
    ((lt) (lt))
    ((gt) (gt))
    ((eq) (case a
      ((ty-tcon na aa) (case b ((ty-tcon nb ab) (then (str-cmp na nb) (ty-list-cmp aa ab))) (_ (eq))))
      ; … ty-var / ty-pi / ty-app, unchanged …
      ((ty-i64) (eq)))))))
```

**The resulting blob shape.** `(import "string-utils")` adds two modules to
`ty-cmp`'s transitive closure, and `resolve` emits them in DFS post-order:

```
; before:  prelude → qtt → refine → syntax → data → ty-cmp                       (869 lines)
; after:   prelude → qtt → refine → syntax → data → collections → string-utils → ty-cmp
;
; Ord      : declared ONCE, by collections
; str-cmp  : defined ONCE, by string-utils
; su-*     : su-cmp-bytes / su-lower-go / su-trim-lo / … — verified collision-free
;            against every `(def …)` in the tree (E154 guard, string-utils.chiral:51-55)
```

`B1` on the converted blob: **exit 0**; the binary runs, exit 0. The same edit
applied to `asm-reloc` and `compile-back` inside the real compiler blob
(`scaffold/build/blob.chiral`, `string-utils` co-loaded right after `collections`)
also compiles clean, byte-reproduces itself, and still compiles the E151a gate to
exit 0.
2026-09-04: the 2026-08-31 migration moved the tree out of scaffold/. The pre-migration paths kept here name no live directory.

- **Knobs to modify:** *which* names a given consumer deletes (`ty-cmp` sheds
  `data Ord` + `cmp-bytes` + `str-cmp` but keeps `cmp-i64`/`then`; `asm-reloc`
  sheds `ar-cmp-i64` + `ar-cmp-bytes` + `ar-str-cmp` and its two call sites lose
  the `ar-` prefix; `row-infer` sheds `data Ord` + `cmp-i64` + `cmp-bytes` +
  `str-cmp`) · **where `string-utils` is placed in the co-load order** for
  hand-assembled blobs · whether the local helper survives the deletion or was
  only ever `str-cmp`'s callee.
- **Deliberately omitted:** `str-pad` (genuinely absent from the whole tree — a
  separate addition to `string-utils`, not a retirement) · `str-lower`/`str-trim`
  in `router.chiral`/`flow.chiral` (same shape, app-side, and they are in a
  different blob from the compiler) · `str-contains`, whose two copies
  (`match.chiral:19`, `TUI/scriba/help.chiral:198`) take their arguments in the
  order *opposite* to `string-utils`, so retiring them is an argument-order
  change and not a pure deletion · the `Ord` copy in `TUI/samples/collections.chiral`
  (an A3 duplicate-module artefact: **E155**, not here).

## 6. Use / modify notes

- **Lands in:** `lib/typing/ty-cmp.chiral`, `lib/typing/row-infer.chiral`,
  `lib/lowering/mach/asm-reloc.chiral`, `lib/lowering/compile-back.chiral` — deletions
  plus one `(import "string-utils")` each. Nothing is added to
  `lib/prelude/string.chiral` except `str-pad`, if E151b takes it.
  `tools/ledger-lint/ledger-lint.py`'s `OWNERSHIP_BASELINE` is lowered in the same change.

- **Conformance target:** three gates, all already runnable.
  1. `scaffold/tests/samples/e151_string_stdlib.chiral` still exits 0 (E151a's
     runtime gate — proves the canonical functions are unchanged).
  2. Each converted module's own consumer blob compiles and runs: for `row-infer`
     that is the `sig-driver` blob (`echo sig-driver | ./scaffold/build/resolve`),
     which compiles and runs to exit 0 both before and after conversion.
  3. For `asm-reloc`/`compile-back`: **the self-hosting fixpoint.** They are the
     only two of the four that are actually *in* `scaffold/build/blob.chiral`
     (`ty-cmp` and `row-infer` are not — the compiler blob contains exactly one
     `data Ord`, collections', and no bare `str-cmp` at all). So `B1 < blob >
     chirality-bin.new`, then `chirality-bin.new < blob` must byte-reproduce `chirality-bin.new` —
     a **generation-2 vs generation-3** comparison. It is never a comparison
     against the committed `B1`, which is one generation stale at HEAD (measured
     2026-08-22: `B1` differs from the binary it builds; that binary and its own
     output are byte-identical). Measured: the conversion reproduces, both for
     `asm-reloc` alone and for both modules together, and the resulting compiler
     still builds and passes the E151a gate.

- **Atomic or incremental? — INCREMENTAL, one module per commit.** The constraint
  is **per-blob, not per-tree**: a name may be defined many times across the
  repository and only collides when two definitions land in the *same* blob.
  Evidence:
  - The only pair whose conversion could interact is `ty-cmp` + `row-infer`, and
    a blob containing both is rejected **identically before and after** converting
    either one — `load: data redeclared: Ord` in both cases. Converting one cannot
    break a combination that was already impossible.
  - They never co-occur anyway: nothing imports `ty-cmp`, and `row-infer` has one
    importer (`sig-driver.chiral:23`), which does not import `ty-cmp`. The
    co-blob is synthetic.
  - Converting `asm-reloc` alone *inside the real compiler blob*, leaving
    `compile-back`'s `cb-str-cmp` untouched beside it, compiles, self-reproduces,
    and works. Two consumers of the same shelf, one converted and one not, coexist
    in one blob — because the un-converted one's name is prefixed and does not
    collide.

  The real ordering constraint is **placement, not atomicity**: `string-utils`
  must appear *before* its first consumer in the co-load order. Inserting it just
  ahead of `asm-reloc` while `compile-back` (earlier in the blob) also referenced
  `str-cmp` produced `load: unknown name str-cmp`; moving the insertion to
  immediately after `collections` fixed it. For `resolve`-built blobs this is
  automatic (DFS post-order); for the hand-ordered compiler blob it is a real
  decision.

- **Open questions:**
  1. `str-pad` — in or out of E151b? It is the one catalog function with no
     definition anywhere, so it is an *addition*, not a retirement, and does not
     share E151b's fixpoint risk. Splitting it out keeps E151b purely subtractive.
  2. `str-contains`' argument order. `string-utils` takes `(needle s)`;
     `match.chiral` and `TUI/scriba/help.chiral` take `(haystack needle)`. One of
     the two must move, and `match.chiral:15-18` is a *shipped SPEC decision* —
     reversing it is a decision-tier change, not an implementation choice.
  3. Whether `ty-cmp` should keep importing `data.chiral` at all —
     `data.chiral:13-14` already flags the vestigial `Ty` skeleton as kept "for
     ty-cmp.chiral only" and names moving `ty-cmp` as residue.
  4. Does lowering the `data Ord` baseline require **E155** to land first? Of the
     four declarations E151b retires exactly **two** — `ty-cmp`'s and
     `row-infer`'s; `collections.chiral:156` is the owner's and stays, and the
     fourth is `TUI/samples/collections.chiral`, an A3 duplicate-module copy. So
     E151b's own target is 4 → 2, and 4 → 1 only once E155 removes that copy —
     unless the two are sequenced.

- **Related:** [[E151-ord-dedup]] · [[E154]] (per-module label namespace — the
  mechanism that makes cloning cheaper than importing; E151b pays its cost by
  hand four times) · [[E155]] (multi-root module search path — owns the fourth
  `Ord`) · [[banks/module]] (why "standard library" is not a category here) ·
  [[E27]] (the ordered `Map` whose explicit `(-> K K Ord)` argument is what makes
  the comparator a shared *value*).
