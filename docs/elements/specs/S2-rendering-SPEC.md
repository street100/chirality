---
element: S2
slug: rendering
title: The rendering engine — Rendering tree, structural diff, ANSI emission
kind: SCRIBA-PRIMITIVE
example: manas/.planning/scriba-examples/S2-S3-rendering-loop.md
example-audit: manas/.planning/scriba-examples/S2-S3-rendering-loop-AUDIT-v2.md
status: audited
updated: 2026-08-10
---

# S2 SPEC — the rendering engine

> Implementation contract produced from the worked example + v2 audit (PASS).
> The example + audit cover both S2 and S3 paired; this SPEC isolates the S2
> boundary — types, diff, ANSI emission, renderer registry. S3's command loop
> is the caller.

## 1. Deliverable

- **After this runs:** `scaffold/lib/scriba/render.chiral` has real `def` bodies
  for every declared function. `diff-node` does structural comparison of `Rendering`
  trees. `render-to-ansi` walks a `Rendering` tree and emits ANSI escape sequences
  via `put`. `render-to-ansi-full` clears the screen and renders from (1,1).
  `render-to-ansi-delta` does a full-reset re-render for Phase 1 (per-node diffing
  deferred). `lookup-renderer` and `register-renderer` are pure operations on an
  immutable renderer registry. All types compile through B1.

- **Non-goals:** does NOT implement type-specific renderers (str-renderer,
  list-renderer, etc. — those land in `renderers/` and are registered at init
  time). Does NOT implement per-node screen-coordinate tracking for targeted
  ANSI diffs (Phase 2). Does NOT implement `r-stream` live rendering (scroll
  regions, subscription — Phase 3). Does NOT touch S3's command loop or S1's
  puffer type (imports only). Does NOT import `collections` — inline
  `alist-get` as a local helper.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** BUILD — S2 is Phase 1, Wave 2. Depends on S1
  (puffer type) for the renderer registry key (`type-name Str` field on Puffer).
  No prior conformance rows to reconcile.
- **Live code this change composes with:**
  - `scaffold/lib/prelude.chiral` — I64, Str, Bool, Unit, List, Maybe, Pair,
    `+`, `-`, `=i`, `<i`, `<=i`, `not`, `and`, `or`, `str-cat`, `str-len`,
    `str-eq`, `str-sub`, `i64->str`. Binary `and`/`or` only. No `>=i`/`==i`.
    `str-cat` is binary `(-> Str Str Str)`.
  - `scaffold/lib/ports.chiral` — `put (=> Str Unit)` for ANSI emission.
    No other ports needed. `print`, `halt`, `read` available but unused.
  - `scaffold/lib/scriba/render.chiral` — the current stub (45 lines). Has
    all data declarations (`Rendering` with 6 ctors, `RendererFn` wrapper,
    `Diff`) but every function body is a stub. `diff-node` always returns
    `diff-same`. `render-to-ansi*` stubs return `unit`.
  - `scaffold/lib/scriba/puffer.chiral` — S1's puffer type. S2 imports
    `Puffer` and `PufTypeR`/`PufValueR` for the renderer dispatch path (the
    caller in S3 extracts the type-name and value, S2 just provides the
    registry and ANSI emission).
- **True delta:** remove `(import "collections")` line 2, inline `alist-get`
  as a local helper, implement `diff-node` body (real structural comparison
  across all 6 `Rendering` constructors), implement `render-to-ansi` body
  (recursive tree walk with ANSI emission), implement `render-to-ansi-full`
  body (clear + home + delegate), implement `render-to-ansi-delta` body
  (Phase 1: full-reset via `render-to-ansi-full`), add ANSI helper constants
  (`ansi-clear-line`, `ansi-goto`).

## 3. Types — the design proven in concrete chirality

### 3.1 Data declarations

```chirality
; Rendering — the intermediate representation between a typed value
; and the terminal grid. Type-specific renderers produce this tree.
; The ANSI emitter walks it and writes escape sequences.
;
; Each variant maps to a terminal layout pattern:
;   r-text   → wrapped lines of text
;   r-table  → aligned columns with headers
;   r-section → bordered box with title bar
;   r-stream → scroll-follow region for live output
;   r-tree   → nested indented structure with selection
;   r-hole   → placeholder for unrendered regions
(data Rendering ()
  (r-text   (content Str) (bold Bool))
  (r-table  (headers (List Str)) (rows (List (List Rendering))))
  (r-section (title Str) (collapsed Bool) (body Rendering))
  (r-stream (source-id Str))
  (r-tree   (children (List Rendering)) (selected Rendering))
  (r-hole   (label Str)))

; RendererFn — wraps a renderer function in a data type.
; This avoids the "declare-as-type" B1 pitfall: a bare `declare`d
; term cannot appear in type position (e.g. as a type argument to
; `Maybe` or `List`). Wrapping it in a data constructor makes it
; a first-class type that can appear in `(List (Pair Str RendererFn))`.
;
; The function itself: given Unit (type-erased value) and terminal
; dimensions (rows, cols), produces a Rendering tree. Pure — no
; ANSI emission, no stdout.
(data RendererFn ()
  (rf (fn (-> Unit (Pair I64 I64) Rendering))))

; Diff — result of comparing two Rendering trees structurally.
; diff-same: the subtrees are equivalent — no redraw needed.
; diff-changed: the subtree changed — carries the new node for redraw.
(data Diff ()
  (diff-same)
  (diff-changed (node Rendering)))
```

### 3.2 API arrows — `->` vs `=>`, effect rows, purity

```chirality
; ---- Pure functions (->) ----

; diff-node: compare two Rendering nodes structurally.
; Recursive structural equality across all 6 constructors.
; r-text: compare content (str-eq) and bold flag (bool-eq).
; r-table: compare headers element-wise + pairwise row diff.
; r-section: compare title + collapsed + recursive body diff.
; r-stream: always diff-changed (live content, no structural equality).
; r-tree: compare selected node (recursive) + children pairwise.
; r-hole: compare labels (str-eq).
; Returns diff-same when equivalent, diff-changed with the new node otherwise.
(declare diff-node (-> Rendering Rendering Diff))
(def diff-node
  (lam (old new)
    (case old
      ((r-text s1 b1)
        (case new
          ((r-text s2 b2)
            (case (and (str-eq s1 s2) (bool-eq b1 b2))
              (true diff-same)
              (false (diff-changed new))))
          (_ (diff-changed new))))
      ((r-table h1 rows1)
        (case new
          ((r-table h2 rows2)
            (case (list-all-eq-str h1 h2)
              (true
                (case (list-all-diff-same rows1 rows2)
                  (true diff-same)
                  (false (diff-changed new))))
              (false (diff-changed new))))
          (_ (diff-changed new))))
      ((r-section t1 c1 b1)
        (case new
          ((r-section t2 c2 b2)
            (case (and (str-eq t1 t2) (bool-eq c1 c2))
              (true (diff-node b1 b2))
              (false (diff-changed new))))
          (_ (diff-changed new))))
      ((r-stream _)
        (case new
          ((r-stream _) (diff-changed new))
          (_ (diff-changed new))))
      ((r-tree ch1 s1)
        (case new
          ((r-tree ch2 s2)
            (case (diff-node s1 s2)
              (diff-same
                (case (list-all-diff-same ch1 ch2)
                  (true diff-same)
                  (false (diff-changed new))))
              (_ (diff-changed new))))
          (_ (diff-changed new))))
      ((r-hole l1)
        (case new
          ((r-hole l2)
            (case (str-eq l1 l2)
              (true diff-same)
              (false (diff-changed new))))
          (_ (diff-changed new)))))))

; bool-eq: structural equality for Bool.
; Inlined — no =b in prelude.
(declare bool-eq (-> Bool Bool Bool))
(def bool-eq
  (lam (a b)
    (case a
      (true (case b (true true) (false false)))
      (false (case b (true false) (false true))))))

; list-all-eq-str: element-wise Str list equality.
; Pure recursion. Used in r-table header comparison.
(declare list-all-eq-str (-> (List Str) (List Str) Bool))
(def list-all-eq-str
  (lam (a b)
    (case a
      (nil (case b (nil true) (_ false)))
      ((cons ha ta)
        (case b
          (nil false)
          ((cons hb tb)
            (and (str-eq ha hb) (list-all-eq-str ta tb))))))))

; list-all-diff-same: element-wise Rendering list diff.
; Returns true only when ALL pairs are diff-same.
; Pure recursion. Used in r-tree children and r-table rows.
(declare list-all-diff-same (-> (List Rendering) (List Rendering) Bool))
(def list-all-diff-same
  (lam (old new)
    (case old
      (nil (case new (nil true) (_ false)))
      ((cons ho to)
        (case new
          (nil false)
          ((cons hn tn)
            (case (diff-node ho hn)
              (diff-same (list-all-diff-same to tn))
              (_ false))))))))

; lookup-renderer: pure lookup in the renderer registry.
; Takes the registry as a parameter — no mutation, no deref.
; Returns Maybe to handle unregistered types cleanly.
; Uses inlined alist-get (no collections import).
(declare lookup-renderer
  (-> (List (Pair Str RendererFn)) Str (Maybe RendererFn)))

; register-renderer: returns a NEW registry with the entry prepended.
; Pure — no mutation. Used at init time to build the registry.
; Callers thread the result:
;   (def reg' (register-renderer reg "Str" (rf str-renderer)))
(declare register-renderer
  (-> (List (Pair Str RendererFn)) Str RendererFn (List (Pair Str RendererFn))))

; ---- ANSI helpers (pure string constants and constructors) ----

; ansi-goto: move cursor to (row, col), 1-indexed.
; Pure string construction.
(declare ansi-goto (-> I64 I64 Str))
(def ansi-goto
  (lam (row col)
    (str-cat (str-cat (str-cat "\x1b[" (i64->str row)) ";")
             (str-cat (i64->str col) "H"))))

; ---- Effectful functions (=>) ----

; render-to-ansi: walk a Rendering tree and emit ANSI escapes.
; The ONLY function in S2 that calls `put`. Everything upstream is pure.
;
; Parameters:
;   node  — the Rendering subtree to emit
;   dims  — (rows, cols) terminal dimensions
;   prev  — previous Rendering tree for this region (Maybe — none on
;           full redraw, (some old) for incremental diff)
;   row   — current cursor row (1-indexed)
;   col   — current cursor column (1-indexed)
;   drow  — display origin row (for window positioning in S6)
;   dcol  — display origin column (for window positioning in S6)
;
; Effect row: bare (=>) — pushes the "put" extern. No named row
; to avoid collision with the function name.
(declare render-to-ansi
  (=> Rendering (Pair I64 I64) (Maybe Rendering)
      I64 I64 I64 I64 Unit))

; render-to-ansi-full: clear screen, render from (1,1).
; Used on first paint and after SIGWINCH resize.
; Effect row: bare (=>) — calls put + render-to-ansi.
(declare render-to-ansi-full (=> Rendering (Pair I64 I64) Unit))

; render-to-ansi-delta: diff and emit only changed regions.
; Phase 1: full-reset re-render — calls render-to-ansi-full.
; Phase 2: targeted ANSI diff using per-node screen coordinates
;   (deferred — needs coordinate tracking from the first render pass).
; Effect row: bare (=>) — calls render-to-ansi-full (transitive put).
(declare render-to-ansi-delta (=> Rendering Rendering (Pair I64 I64) Unit))
```

### 3.3 Effect row discipline

| Crossing | What it means |
|----------|---------------|
| `put` (ports.chiral) | Write a Str to stdout. The only effectful crossing in S2. |

All other functions are pure `->`. The membrane boundary is clean:
`render-to-ansi` is the single function that calls `put`. Its callers
(`render-to-ansi-full`, `render-to-ansi-delta`) are `=>` because they
transitively call `put` — the effect row propagates.

The renderer registry (`lookup-renderer`, `register-renderer`) is pure:
immutable parameter threading, no mutation, no I/O.

### 3.4 Build wave — single wave (native compilation)

All types and functions compile in one wave. No special compilation-time
annotations beyond the data declarations and `declare`/`def` pairs. The
`=>` functions require `put` to be available from ports.chiral (already
in B1's build source). No new externs needed.

Wave 1 deliverables (all land in `scaffold/lib/scriba/render.chiral`):
1. Data declarations: Rendering, RendererFn, Diff (already present, unchanged)
2. Pure helper `def` bodies: bool-eq, list-all-eq-str, list-all-diff-same
3. Pure `def` bodies: diff-node, lookup-renderer, register-renderer
4. Pure ANSI helper: ansi-goto
5. Effectful `def` bodies: render-to-ansi, render-to-ansi-full, render-to-ansi-delta

## 4. Decisions

| # | Question | Disposition | Rationale |
|---|----------|-------------|-----------|
| 1 | Collections import: keep or remove? | RESOLVED → remove, inline alist-get | Task directive: "MUST be removed (collections import poison)." The worked example's `lookup-renderer` uses `alist-get` from collections.chiral — inline the alist-get helper locally instead. The E100 fix resolved the underlying 2-type-param lowering issue but the B1 binary may not have the fix rebuilt in yet. Safer to remove the import. |
| 2 | `RendererFn`: data wrapper vs bare `declare`? | RESOLVED → data wrapper | Current stub (lines 12-13) uses `(data RendererFn () (rf (fn (-> Unit (Pair I64 I64) Rendering))))`. This is correct — a bare `(declare renderer-fn ...)` cannot appear in type position (e.g. `(Maybe renderer-fn)` fails with "pi domain is not a type"). The data wrapper makes it a first-class type. |
| 3 | `render-to-ansi-delta`: full-reset vs targeted diff? | RESOLVED → full-reset for Phase 1 | Per task context: "deferrable to Phase 1 — full re-render works for Day 1." The function body calls `render-to-ansi-full` (clear + repaint). Targeted per-node ANSI diff needs screen-coordinate tracking from the first render pass — Phase 2. |
| 4 | `r-stream` diff: always changed? | RESOLVED → always `diff-changed` | Live content from external sources. No structural equality — the stream source may have identical text at different times. The `source-id` field is metadata; the actual content lives in the puffer's port. `r-stream` nodes are always re-rendered. |
| 5 | `r-table` diff: per-row or whole-table? | RESOLVED → whole-table for Phase 1 | If any row changed, mark the entire table as `diff-changed`. Per-row diffing needs row-index tracking and targeted ANSI cursor moves — same coordinate-tracking problem as `render-to-ansi-delta` (Phase 2). The pairwise helper `list-all-diff-same` handles (List Rendering) lists — reuse it for both r-table rows and r-tree children. |
| 6 | `r-table` diff input: (List Rendering) pairs? | RESOLVED → flatten rows first | `r-table` rows are `(List (List Rendering))`. The diff compares `rows1` and `rows2` — both are lists where each element is itself a `(List Rendering)`. The pairwise diff needs to compare the two outer lists element-by-element, diffing each inner list's items. For Phase 1: compare outer list lengths, then pairwise diff. Helper `list-all-diff-same` takes `(List Rendering)` — flatten each row's children into a single `Rendering` list before comparing. |
| 7 | Effect rows: named vs bare `=>`? | RESOLVED → bare `=>` | The `put` extern in ports.chiral uses bare `=>`. S2's effectful functions propagate this — no named row to avoid collision with function names. The membrane tracks effects via the `(extern put (=> Str Unit))` in ports.chiral. |
| 8 | `render-to-ansi` row/col threading: return or mutate? | RESOLVED → mutate via put positioning | The row/col are effectfully threaded: each node type emits its content at the current position, advances row/col as needed, and the next node continues from there. No return type threading — the effect row captures the position advancement via ANSI cursor moves. Pure functions upstream don't need to know about screen coordinates. |
| 9 | ANSI helpers: which ones to define? | RESOLVED → keep existing + add `ansi-goto`, `ansi-clear-line` | Current stub has `ansi-clear`, `ansi-home`, `ansi-reset`, `ansi-red`, `ansi-bold`, `ansi-underline`. Add `ansi-clear-line` ("\x1b[K") for clearing from cursor to end of line, and `ansi-goto` (-> I64 I64 Str) for cursor positioning. These are pure Str constants/functions — no new externs. |
| 10 | `render-to-ansi` prev param: used in Phase 1? | RESOLVED → accepted but unused | The `(Maybe Rendering)` prev parameter exists for the targeted-diff future (Phase 2). In Phase 1, `render-to-ansi` ignores it — always full-render. `render-to-ansi-full` passes `none`. `render-to-ansi-delta` passes the old rendering as `(some prev)`. The param stays in the signature so callers don't change when Phase 2 lands. |
| 11 | `r-section` collapsed state rendering? | RESOLVED → emit title only when collapsed | When `collapsed` is `true`, render just the title line (with a collapsed indicator). When `false`, render title line + body subtree. The body subtree is rendered at row+1, indented. |
| 12 | `r-tree` children rendering? | RESOLVED → indented list with selection highlight | Each child is rendered on its own line, indented by 2 spaces. The selected child gets ANSI bold/inverse highlighting. The `selected` field points to one of the children (by structural equality — the renderer matches it during traversal). |

## 5. Change plan (ordered, commit-sized)

### Step 0 — Remove collections import
- **Target:** `scaffold/lib/scriba/render.chiral` — line 2
- **Change:** Delete `(import "collections")`. Only `(import "prelude")`
  remains (line 1). The `import "prelude"` is required for Bool, Str, I64,
  Unit, List, Pair, Maybe.
- **Size:** ~S (delete 1 line)

### Step 1 — Inline alist-get helper
- **Target:** `scaffold/lib/scriba/render.chiral` — after imports, before
  data declarations
- **Change:** Add a local `alist-get` helper as a pure recursive function:
  ```chirality
  (declare alist-get
    (-> (0 K (type 0)) (0 V (type 0))
        (-> K K Bool) (List (Pair K V)) K (Maybe V)))
  (def alist-get
    (lam (K V eq alist key)
      (case alist
        (nil (none V))
        ((cons (pair k v) rest)
          (case (eq k key)
            (true (some V v))
            (false (alist-get K V eq rest key)))))))
  ```
  The erased type params `(0 K (type 0)) (0 V (type 0))` are implicit —
  call sites don't pass them. Pattern: `(alist-get reg name)` where
  `reg : (List (Pair Str RendererFn))` and `name : Str`.
- **Size:** ~S (~10 lines)

### Step 2 — Wire lookup-renderer and register-renderer to use inlined alist-get
- **Target:** `scaffold/lib/scriba/render.chiral` — lines 23-27
- **Change:** 
  - `lookup-renderer` body: replace `(alist-get Str RendererFn renderer-eq reg name)` with `(alist-get reg name)` — the inlined version uses erased type params so callers don't pass them.
  - Remove `(declare renderer-eq (-> Str Str Bool))` and `(def renderer-eq str-eq)` — the inlined alist-get uses a generic `eq` function. The lookup-renderer body becomes:
    ```chirality
    (def lookup-renderer
      (lam (reg name) (alist-get str-eq reg name)))
    ```
  - `register-renderer` body: unchanged (it's a simple `cons` — no alist involved).
- **Size:** ~S (~3 lines changed)

### Step 3 — Implement diff-node body and pure helpers
- **Target:** `scaffold/lib/scriba/render.chiral` — line 31 (current stub:
  `(def diff-node ... (lam (a b) (case (str-eq "x" "x") (true diff-same) (false (diff-changed a))))`)
- **Change:** Replace with the full structural comparison across all 6
  Rendering constructors (see §3.2 for the complete body). Add `bool-eq`,
  `list-all-eq-str`, and `list-all-diff-same` helper defs before `diff-node`
  (they're called from it). The helpers are pure `->` functions — no effects.
- **Size:** ~M (~60 lines — the full structural diff across 6 ctors)

### Step 4 — Add ANSI helper: ansi-goto and ansi-clear-line
- **Target:** `scaffold/lib/scriba/render.chiral` — after existing ANSI constants
  (lines 32-37)
- **Change:** Add:
  ```chirality
  (def ansi-clear-line Str "\x1b[K")
  (declare ansi-goto (-> I64 I64 Str))
  (def ansi-goto
    (lam (row col)
      (str-cat (str-cat (str-cat "\x1b[" (i64->str row)) ";")
               (str-cat (i64->str col) "H"))))
  ```
- **Size:** ~S (~6 lines)

### Step 5 — Implement render-to-ansi body
- **Target:** `scaffold/lib/scriba/render.chiral` — lines 38-39 (current stub:
  `(declare render-to-ansi ...)) (def render-to-ansi (lam (...) unit))`)
- **Change:** Implement the recursive tree walker. For each `Rendering`
  variant:
  - `r-text`: emit `ansi-bold` if bold, then the content via `put`, then
    `ansi-reset`. Each \n in content advances row.
  - `r-table`: emit headers (bold), separator line, then each row. Columns
    aligned with padding. Uses `ansi-goto` for column positioning.
  - `r-section`: emit title bar (bordered), then body (indented, row+1).
    If collapsed, emit only the title bar with a collapse indicator.
  - `r-stream`: emit a placeholder line indicating the stream source.
    Actual streaming deferred to Phase 3.
  - `r-tree`: emit each child on its own line (indented 2 spaces), with the
    selected child highlighted via `ansi-bold`.
  - `r-hole`: emit a placeholder with the label in dim text.
  
  The function does NOT return row/col — the effect row captures the
  cursor position advancement via ANSI escapes. The `put` extern is the
  only effect.
- **Size:** ~L (~80 lines — one branch per Rendering variant)

### Step 6 — Implement render-to-ansi-full body
- **Target:** `scaffold/lib/scriba/render.chiral` — lines 42-43 (current stub)
- **Change:** Replace the stub with:
  ```chirality
  (def render-to-ansi-full
    (lam (tree dims)
      (let (_ (put ansi-clear))
        (let (_ (put ansi-home))
          (render-to-ansi tree dims none 1 1 1 1)))))
  ```
  Clear screen, home cursor, then delegate to `render-to-ansi` with
  `prev=none`, starting at row=1, col=1, origin=(1,1).
- **Size:** ~S (~5 lines)

### Step 7 — Implement render-to-ansi-delta body (Phase 1: full-reset)
- **Target:** `scaffold/lib/scriba/render.chiral` — lines 44-45 (current stub)
- **Change:** Replace the stub with:
  ```chirality
  (def render-to-ansi-delta
    (lam (prev new dims)
      (case (diff-node prev new)
        (diff-same unit)
        (diff-changed _ (render-to-ansi-full new dims)))))
  ```
  Phase 1: diff the trees. If unchanged, do nothing. If changed,
  full-reset re-render. Phase 2: use the `diff-changed` node to
  emit targeted ANSI for only the changed region.
- **Size:** ~S (~5 lines)

### Step 8 — Verify B1 compilation and paren balance
- **Target:** `scaffold/lib/scriba/render.chiral` — verification only
- **Change:** Verify paren balance with the Python sexp reader:
  ```bash
  cd /home/shea/.Sandbox/Claude/workspace/chirality
  PYTHONPATH=scaffold python3 -c "
  from chirality.sexp import read_all
  list(read_all(open('scaffold/lib/scriba/render.chiral').read(),'f'))
  print('OK')
  "
  ```
  Build a minimal blob (prelude + ports + render) and pipe through B1
  to verify all functions emit labels. No `collections` import.
  
  Blob construction:
  ```bash
  cat scaffold/lib/prelude.chiral \
      scaffold/lib/ports.chiral \
      scaffold/lib/scriba/render.chiral > /tmp/s2-test.chiral
  scaffold/build/B1 < /tmp/s2-test.chiral > /tmp/s2-test.elf 2>&1
  ```
  Verify: no "no emitted label", no "unknown name", no "type mismatch".
  The blob is self-contained — render.chiral only needs prelude + ports
  (put extern). No scriba dependencies.
- **Size:** ~S (test run)

## 6. Conformance gate

- **Golden behavior:**
  1. `diff-node (r-text "hello" false) (r-text "hello" false)` → `diff-same`.
     `diff-node (r-text "hello" false) (r-text "world" false)` → `(diff-changed (r-text "world" false))`.
  2. `diff-node (r-stream "log") (r-stream "log")` → `(diff-changed (r-stream "log"))` —
     r-stream is always changed (live content).
  3. `diff-node (r-section "Title" false (r-text "body" false)) (r-section "Title" true (r-text "body" false))` →
     `(diff-changed ...)` — collapsed flag changed.
  4. `diff-node (r-tree (cons (r-text "a" false) (cons (r-text "b" false) nil)) (r-text "a" false))
     (r-tree (cons (r-text "a" false) (cons (r-text "c" false) nil)) (r-text "a" false))` →
     `(diff-changed ...)` — second child changed.
  5. `render-to-ansi-full tree dims` clears screen, homes cursor, renders tree.
     The ANSI output is deterministic: same `(Rendering, rows, cols)` → same
     ANSI escape sequence bytes.
  6. `render-to-ansi-delta prev prev dims` → `unit` (no-op when identical).
  7. `render-to-ansi-delta prev new dims` → full clear + render when trees differ.
  8. `lookup-renderer reg "Str"` where reg contains `(pair "Str" (rf str-renderer))` →
     `(some (rf str-renderer))`. When reg has no "Str" entry → `none`.
  9. `register-renderer reg "Str" (rf str-renderer)` → new list with entry prepended.
     Original `reg` is unchanged (pure — returns new list).

- **Tests to add:** no new test files for this wave — S2 provides types and
  rendering operations. The integration test is S3's command loop calling
  `render-to-ansi-full` / `render-to-ansi-delta` after each state change.
  Structural verification: paren balance, B1 compilation, no linear annotation
  violations, no collections import.

- **Green line:** all functions have real `def` bodies (not stubs). B1
  compiles the blob (prelude + ports + render) without errors. `diff-node`
  returns correct results for the golden cases above. `render-to-ansi`
  emits proper ANSI escape sequences. Zero `(import "collections")`.
  `lookup-renderer` uses inlined `alist-get`.

- **Done when:** `scaffold/lib/scriba/render.chiral` has zero stubs. Every
  `declare` has a real `def`. The file parses cleanly and compiles through
  B1 in a minimal blob (prelude + ports + render). The six golden diff cases
  produce correct results (can be verified by inspection of the case arms).

## 7. Residue & links

- **Deliberately unbuilt:**
  - Per-node screen coordinate tracking — the foundation for targeted ANSI
    diffs in Phase 2. `render-to-ansi` doesn't record (row, col, height, width)
    per node. When it does, `render-to-ansi-delta` can skip unchanged regions
    and only emit ANSI for changed subtrees.
  - `r-stream` live rendering — scroll regions (`\x1b[top;bottom r`), line
    appending, subscription callbacks. Phase 3. The `source-id` field exists
    in the type; the actual stream plumbing needs port-layer support.
  - `r-section` box-drawing borders — box-drawing characters (┌─┐│└─┘).
    Pure string composition from title + dimension params. ~30 lines.
    Phase 1 renders title-only (no borders).
  - `r-tree` expand/collapse — the `selected` field identifies the active
    child, but expand/collapse state isn't in the Rendering type. When
    added, `render-to-ansi` skips collapsed children.
  - `r-hole` rich rendering — currently a plain label. Future: typed holes
    with type-appropriate actions (similar to Hazel).
  - Type-specific renderers — `renderers/str.chiral`, `renderers/list.chiral`,
    etc. Each lives in its own file and calls `register-renderer` at init
    time. S2 provides the registry and ANSI emission; the renderers themselves
    are pure `->` functions.
  - Word wrapping — the `str-renderer` in the worked example does simple
    line splitting. Real word-boundary wrapping, zero-width/double-width
    Unicode handling, tab expansion. ~100 lines of pure string ops.
  - Cursor rendering — the cursor position belongs to the puffer's zipper (S1),
    not the Rendering tree. The ANSI emitter receives the cursor position from
    the command loop and emits `\x1b[row;colH` after the render pass.

- **Follow-on:** S3 (command loop) imports `Rendering`, `Diff`, `RendererFn`,
  `diff-node`, `render-to-ansi-full`, `render-to-ansi-delta`,
  `lookup-renderer`, `register-renderer` from this module. The command loop
  drives rendering: reads a key, dispatches an op, calls `render-puffer` (pure,
  produces new Rendering), then calls `render-to-ansi-delta`.

- **Related:** [[S1-puffer-SPEC]] (S1 SPEC — puffer type
  with `type-name` field used by renderer registry), [[SCRIBA-SLICES]] (the
  S1-S17 slice rows, successor to the old SCRIBA-CATALOG.md),
  [[SCRIBA-UNBLOCK-MAP]] (build plan, S2 is Phase 1 Wave 2).
  ⚑ Two targets are left unlinked because they live outside this tree.
  S2-S3-rendering-loop named the worked example and S2-S3-rendering-loop-AUDIT-v2
  its audit (PASS, 0 BLOCKED findings). Both files exist on one laptop's disk
  under /workspace/manas/.planning/scriba-examples/ and are untracked there, so a
  fresh clone of either repository reaches neither.
  `records/baseline-alignment.md` BA-38 holds the measurement and records that
  copying them in is an author call.
