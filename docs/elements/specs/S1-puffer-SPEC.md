---
element: S1
slug: puffer
title: The puffer (port-buffer) — scriba's typed, port-backed, zipper-cursored atom
kind: SCRIBA-PRIMITIVE
example: manas/.planning/scriba-examples/S1-puffer.md
status: audited
updated: 2026-08-10
---

# S1 SPEC — the puffer (port-buffer)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `scaffold/lib/scriba/puffer.chiral` has real `def` bodies
  for every declared function — the puffer type is no longer a stub. `puffer-new`
  creates a puffer over a Port (effectful, consumes the port). `puffer-close`
  closes a puffer and releases its port. `puffer-port-type` and `puffer-value`
  are pure accessors that thread the puffer back (read-and-return pattern).
  `puffer-str-insert` delegates to S5's str-edit operations. Every pure
  accessor handles its failure case in the result type — no `halt` inside
  `->` functions. All types compile through B1.

- **Non-goals:** does NOT implement zipper navigation (forward/backward/down/up
  — those are pure structural ops on the zipper, deferred to a later pass when
  the value is available from the port). Does NOT implement `puffer-read` or
  `puffer-write` (port I/O — those need the actual port read/write externals,
  deferred to S3's command-loop integration). Does NOT create the puffer
  registry (puffer list — S3 territory). Does NOT touch S5's `TextZipper` or
  `str-edit.chiral` (already implemented, import-only). Does NOT import
  `collections` — inline any needed helpers.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** BUILD — S1 is Phase 1, Wave 1. No prior
  conformance rows to reconcile. The puffer type is the foundation scriba
  builds on.
- **Live code this change composes with:**
  - `scaffold/lib/prelude.chiral` — I64, Str, Bool, Unit, List, Maybe, Pair,
    `+`, `-`, `=i`, `<i`, `<=i`, `not`, `and`, `or`, `str-cat`, `str-len`,
    `str-eq`, `str-sub`, `i64->str`. Binary `and`/`or` only. No `>=i`/`==i`.
    `str-cat` is binary `(-> Str Str Str)`.
  - `scaffold/lib/ports.chiral` — `Port` as `(data Port () (port))` (not a
    porttype — B1 extern emit constraint, resolved 2026-08-08). `put`, `print`,
    `halt`, `read-key`, etc. available as externs.
  - `scaffold/lib/scriba/str-edit.chiral` — S5's text editing operations on
    `TextZipper`. S1's `puffer-str-insert` delegates to S5's operations.
    Already implemented (699 lines, B1-compiles).
  - `scaffold/lib/scriba/puffer.chiral` — the current stub (30 lines). Has all
    data declarations but every function body is a stub (`(lam (puf s) puf)`,
    `(lam (port name) (puf-err "not implemented"))`, `(lam (puf) unit)`).
    Missing: `puf-value-none` constructor on `PufValueR`. Bug: `puffer-new`
    declared as `->` but must be `=>` (consumes linear Port).
- **True delta:** add `puf-value-none` to `PufValueR`, fix `puffer-new` arrow
  (`->` → `=>`), implement all 5 function bodies, inline collection helpers
  as needed.

## 3. Types — the design proven in concrete chirality

### 3.1 Data declarations

```chirality
; Zipper — a pure cursor into a typed value.
; focus: the value at the cursor position (none at boundaries / empty).
; path:  navigation path from root as a list of child indices.
; Only prelude types: Maybe A, List I64.
(data Zipper ((A (type 0)))
  (zipper (focus (Maybe A)) (path (List I64))))

; Puffer — a named view over a typed port with a zipper cursor.
; id:        monotonic counter, 1-based. I64 never wraps.
; name:      human-readable. "*scratch*", "main.chiral", etc.
; type-name: key into the renderer registry (S2) and op dispatch (S3).
;            Set at creation, immutable. "Str", "(List FileInfo)", etc.
; handle:    linear port handle. The (1) quantity is mandatory —
;            B1 only accepts linear annotations on atom types (Port, Fd).
;            Compound types carrying linear fields use => for linearity.
; zipper:    pure cursor. Navigation produces a new zipper.
; dirty:     true when modified since last save. Single Bool.
(data Puffer ((A (type 0)))
  (puffer (id I64) (name Str) (type-name Str) (1 handle Port)
          (zipper (Zipper A)) (dirty Bool)))

; NewPufR — result of creating a new puffer.
; puf-ok:  the new puffer, ready to use.
; puf-err: creation failed (resource exhaustion, bad port, etc.).
;          Carries a message for the caller to surface.
(data NewPufR ((A (type 0)))
  (puf-ok  (p (Puffer A)))
  (puf-err (msg Str)))

; PufTypeR — accessor result for type-name.
; The puffer is returned alongside the extracted value.
; This is the read-and-return pattern for linear threading:
; every branch of the case must return the puffer.
; Only one constructor: type-name is always set at creation time.
; No failure case needed — this field is immutable and always present.
(data PufTypeR ((A (type 0)))
  (puf-type-ok (type-name Str) (puf (Puffer A))))

; PufValueR — accessor result for the zipper's focus value.
; puf-value-ok:   the focus holds a value of type A.
; puf-value-none: the focus is empty (none). The puffer is returned
;                 so the caller can decide what to do — beep, show
;                 empty-state rendering, or halt in an effectful context.
;                 The puffer is threaded back in BOTH constructors.
;                 This is mandatory: puffer-value is pure (->), and
;                 halt is effectful (=>). Pure functions cannot halt.
;                 The error case lives in the type, not in an effect.
(data PufValueR ((A (type 0)))
  (puf-value-ok   (val A)      (puf (Puffer A)))
  (puf-value-none              (puf (Puffer A))))
```

### 3.2 API arrows — `->` vs `=>`, effect rows, purity

```chirality
; ---- Pure accessors (->) ----

; Extract the type-name from a puffer. Pure — field access only.
; The type-name is set at creation and immutable. No failure case.
; (0 A (type 0)) is erased — exists only at compile time for the
; checker to verify the puffer's type parameter.
(declare puffer-port-type (-> (0 A (type 0)) (Puffer A) (PufTypeR A)))

; Extract the value at the zipper focus. Pure — reads the zipper's
; focus field. Returns puf-value-none when focus is none (empty puffer
; or boundary position). The puffer is threaded back so the caller
; can continue using it.
(declare puffer-value (-> (0 A (type 0)) (Puffer A) (PufValueR A)))

; Insert a string at the zipper focus in a Str puffer. Pure —
; structural zipper manipulation. Delegates to S5's str-edit ops.
; Returns a new puffer with the updated zipper and dirty=true.
; Only valid for (Puffer Str) — the checker enforces this at the
; call site. No erased type param needed (monomorphic to Str).
(declare puffer-str-insert (-> (Puffer Str) Str (Puffer Str)))

; ---- Effectful operations (=>) ----

; Create a new puffer over a Port.
; Effectful (=>): consumes the linear Port. The port moves into
; the puffer's (1 handle Port) field. Caller cannot use the
; original port handle after this call.
;
; Effectful (=>): consumes the linear Port. The port moves into
; the puffer's (1 handle Port) field. Caller cannot use the
; original port handle after this call.
; Effect row is bare (=>) — the membrane tracks it via the
; (extern port …) stub. No named row to avoid collision with
; the function name.
;
; Monomorphic to Str for Phase 1.
(declare puffer-new (=> Port Str (NewPufR Str)))

; Close a puffer, consuming its port.
; Effectful (=>): the port handle is consumed by the close extern.
; Returns Unit — nothing to thread forward. Failure variant
; (e.g. PufCloseR) deferred to Phase 2 when real port layer exists.
; For Phase 1 the close extern is a stub that always succeeds.
; Effect row is bare (=>) — tracked via (extern port-close …).
;
; Monomorphic to Str for Phase 1.
(declare puffer-close (=> (Puffer Str) Unit))
```

### 3.3 Effect row discipline

| Crossing | What it means |
|----------|---------------|
| `port` (extern stub) | Creating a puffer consumes a Port. The counter is global mutable state (extern). |
| `port-close` (extern stub) | Closing a puffer releases the Port. The extern closes the underlying fd/socket. |

The pure accessors (`puffer-port-type`, `puffer-value`, `puffer-str-insert`)
have NO effect row — they are structural field reads and zipper manipulations.
The `=>` arrow on `puffer-new` and `puffer-close` exists because they consume
or release a linear `Port` resource, not because they touch the zipper.
The membrane rows are `port` and `port-close` (extern stubs in puffer.chiral) —
bare names, no collision with function names.

### 3.4 Build wave — single wave (native compilation)

All types and functions compile in one wave. No special compilation-time
annotations beyond the data declarations and `declare`/`def` pairs. The
effect rows `puffer-new` and `puffer-close` require matching `extern`
declarations (stub them during development; the real crossings land when
the port layer provides actual implementations).

Wave 1 deliverables (all land in `scaffold/lib/scriba/puffer.chiral`):
1. Data declarations: Zipper, Puffer, NewPufR, PufTypeR, PufValueR
2. Pure accessor `def` bodies: puffer-port-type, puffer-value, puffer-str-insert
3. Effectful operation `def` bodies: puffer-new, puffer-close

## 4. Decisions

| # | Question | Disposition | Rationale |
|---|----------|-------------|-----------|
| 1 | `puffer-new` arrow: `->` vs `=>`? | RESOLVED → `=>` | Consumes linear `Port`. Must be effectful. The current stub (puffer.chiral:27) incorrectly declares `->`. |
| 2 | `PufValueR` missing `puf-value-none` constructor? | RESOLVED → add it | `puffer-value` is pure `->`. When zipper focus is `none`, there is no value to return. `halt` is effectful (`=>`). The failure case must live in the result type. Both constructors thread the puffer back — linear threading is preserved. |
| 3 | `PufTypeR` failure case? | RESOLVED → no failure case needed | `type-name` is set at puffer creation and immutable. The field is always present. Single constructor `puf-type-ok` is correct. |
| 4 | Zipper focus: `(Maybe A)` vs bare `A`? | RESOLVED → `(Maybe A)` | Empty puffers and boundary positions are real states. `none` represents them honestly in the type. The worked example §5.8 Knobs confirms this choice. |
| 5 | Zipper path encoding: `(List I64)` vs `(List PathStep)`? | RESOLVED → `(List I64)` | Minimal encoding. Works for lists (index into list), trees (index into children), and text (character position). `PathStep` with named constructors is deferred — graduate when multi-type zipper ops become confusing. |
| 6 | Linear annotations on function params? | RESOLVED → NO `(1 ...)` on compound types | B1 rejects `(1 p (Puffer A))` in function params (field binder usage mismatch). The `=>` arrow on effectful functions enforces linearity for any linear values carried inside. Only atom-type fields in data declarations get `(1 ...)`: `(1 handle Port)` on Puffer. |
| 7 | `puffer-new` monomorphic (Str-only) vs polymorphic? | RESOLVED → Str-only for Phase 1 | The first puffer type is Str. The `A` type parameter exists on the Puffer type itself (for the renderer and accessors), but creation and teardown are monomorphic until multi-type puffers exist. Generalize with `(0 A (type 0))` when needed. |
| 8 | `puffer-str-insert` delegates to S5 or implements inline? | RESOLVED → delegates to S5 | S5's `str-edit.chiral` (699 lines) already implements text editing on `TextZipper`. S1 calls S5's operations. The bridge from `(Zipper A)` to `TextZipper` is a thin adapter. |
| 9 | Effect rows named or bare? | RESOLVED → bare `=>` | Named rows `puffer-new`/`puffer-close` collide with function names. Use bare `=>`; the membrane tracks effects via the `(extern port …)` and `(extern port-close …)` stubs. The names `port`/`port-close` are the row identifiers. |
| 10 | Collections import? | RESOLVED → inline helpers | Per scriba-development constraints: `(import "collections")` kills entry labels through B1 (E100 fix not yet rebuilt into B1 binary). Inline `reverse`, `length`, and any other needed helpers as local `def`s. |
| 11 | `puffer-close` failure path? | RESOLVED → Unit return, deferred | Keep `Unit` for Phase 1. Close extern is a stub. Error variant (e.g. `PufCloseR` with `puf-closed` / `puf-close-err`) deferred to when real port layer exists. Documented in §7 residue. |
| 12 | `puffer-str-insert` on empty puffer? | RESOLVED → caller gate, no error variant | Caller checks `puffer-value` first. On empty puffer (focus=none, path=nil), S5's insert treats nil path as beginning-of-buffer — pure structural, no failure mode. Documented in golden behavior §6. |
| 13 | Existing extern stubs disposition? | RESOLVED → remove all 7, add 2 | The 7 stubs at puffer.chiral:8-14 (`port`, `port-close`, `puffer-read`, `puffer-write`, `zipper-nav`, `str-edit`, `poll`) are pre-E98 residue. Replace with only: `(extern port (=> Unit Unit))` for puffer-new's effect row, `(extern port-close (=> Unit Unit))` for puffer-close's effect row. Added as Step 0 of change plan. |

## 5. Change plan (ordered, commit-sized)

### Step 0 — Remove orphan extern stubs, add needed ones
- **Target:** `scaffold/lib/scriba/puffer.chiral` — lines 8-14 (7 extern stubs)
- **Change:** Remove all 7 orphan stubs: `port`, `port-close`, `puffer-read`,
  `puffer-write`, `zipper-nav`, `str-edit`, `poll`. These are pre-E98 residue —
  B1 can't use them (not in crossing-wraps, not in B1 build source).
  Replace with two extern stubs the module actually needs:
  ```chirality
  (extern port (=> Unit Unit))        ; effect row for puffer-new
  (extern port-close (=> Unit Unit))  ; effect row for puffer-close
  ```
- **Size:** ~S (remove ~7 lines, add ~2)

### Step 1 — Fix data declarations
- **Target:** `scaffold/lib/scriba/puffer.chiral` — lines 5-7 (data decls)
- **Change:** Add `puf-value-none` constructor to `PufValueR`. No changes
  needed to `Zipper`, `Puffer`, `NewPufR`, or `PufTypeR` — those are correct.
  The new `PufValueR` becomes:
  ```chirality
  (data PufValueR ((A (type 0)))
    (puf-value-ok (val A) (puf (Puffer A)))
    (puf-value-none (puf (Puffer A))))
  ```
- **Size:** ~S (2 lines added)

### Step 2 — Fix `puffer-new` arrow and implement body
- **Target:** `scaffold/lib/scriba/puffer.chiral` — lines 27-28
- **Change:** 
  - Fix `declare`: `(-> Port Str (NewPufR Str))` → `(=> Port Str (NewPufR Str))`
  - Effect row uses existing `(extern port (=> Unit Unit))` from Step 0 — no new extern needed
  - Implement body: extract id from global counter, construct `(puffer id name "Str" port zipper false)`, return `(puf-ok ...)`.
  - The zipper starts as `(zipper none nil)` — empty puffer, no value yet.
  - On failure (bad port, resource exhaustion): return `(puf-err "message")`.
- **Size:** ~S (~10 lines)

### Step 3 — Implement `puffer-close` body
- **Target:** `scaffold/lib/scriba/puffer.chiral` — lines 29-30
- **Change:**
  - Effect row uses existing `(extern port-close (=> Unit Unit))` from Step 0 — no new extern needed
  - Implement body: destructure puffer, close the port handle via the extern,
    return `unit`.
  - The port is consumed — the close extern releases the underlying fd/socket.
  - Keep the `declare` as-is: `(=> (Puffer Str) Unit)` is correct.
  - Returns `Unit` — close failure variant deferred to Phase 2.
- **Size:** ~S (~5 lines)

### Step 4 — Implement `puffer-port-type` body
- **Target:** `scaffold/lib/scriba/puffer.chiral` — line 23 (declare only, no def)
- **Change:**
  - Add `def` body: destructure `(puffer id name type-name handle zipper dirty)`,
    return `(puf-type-ok A type-name (puffer id name type-name handle zipper dirty))`.
    Every field is reconstructed — the puffer is threaded back.
  - Single constructor return: `type-name` is always present.
- **Size:** ~S (~8 lines)

### Step 5 — Implement `puffer-value` body
- **Target:** `scaffold/lib/scriba/puffer.chiral` — line 24 (declare only, no def)
- **Change:**
  - Add `def` body: destructure puffer, destructure zipper, case on focus.
    `(some val)` → `(puf-value-ok A val rebuilt-puffer)`.
    `none` → `(puf-value-none A rebuilt-puffer)`.
    Both branches return the puffer — linear threading preserved.
- **Size:** ~S (~12 lines)

### Step 6 — Implement `puffer-str-insert` body (delegate to S5)
- **Target:** `scaffold/lib/scriba/puffer.chiral` — lines 25-26
- **Change:**
  - Replace the stub body `(lam (puf s) puf)` with a real implementation
    that bridges `(Zipper Str)` to S5's `TextZipper`, calls S5's insert
    operation, and reconstructs the puffer with the updated zipper and
    `dirty=true`.
  - The bridge: `TextZipper` is a different type from `(Zipper Str)` —
    S5 defines its own zipper with `LineCtx`. S1 constructs a `TextZipper`
    from the `(Zipper Str)` and calls S5's `str-insert-char`.
  - Set `dirty=true` on the returned puffer.
  - The function is pure `->` — no port I/O, just structural zipper
    manipulation.
- **Size:** ~M (~20 lines — the bridge logic)

### Step 7 — Inline any needed collection helpers
- **Target:** `scaffold/lib/scriba/puffer.chiral` — top of file (after imports)
- **Change:** If the implementation needs `reverse`, `length`, or other
  collection functions, inline them as local `def`s. Do NOT add
  `(import "collections")`. Pattern from S5's `str-edit.chiral`: `rev-onto`,
  `reverse`, `length` defined inline with erased type binders.
- **Size:** ~S (0–15 lines, depends on what's actually needed)

### Step 8 — Verify B1 compilation
- **Target:** `scaffold/lib/scriba/puffer.chiral` — verification only
- **Change:** Build a minimal blob (prelude + ports + puffer + str-edit) and pipe
  through B1. Verify all 5 functions emit labels. S5 (str-edit.chiral)
  is required because `puffer-str-insert` delegates to `str-insert-char`. The blob must compile
  with zero errors. Verify paren balance with the Python sexp reader.
  Verify no `(1 ...)` annotations on compound types (grep for `(1 ` and
  confirm only `(1 handle Port)` appears).
- **Size:** ~S (test run)

## 6. Conformance gate

- **Golden behavior:**
  1. `puffer-new` with a valid Port returns `(puf-ok (puffer 1 "*scratch*" "Str" port (zipper none nil) false))`.
     The id is 1 (monotonic counter, 1-based). The port is consumed — caller
     cannot use the original port handle.
  2. `puffer-close` on a puffer consumes the puffer and returns `unit`.
     The port handle is released.
  3. `puffer-port-type` on a `(Puffer Str)` returns
     `(puf-type-ok "Str" same-puffer)`. The puffer is unchanged (pure access).
  4. `puffer-value` on a puffer with zipper focus `(some "hello")` returns
     `(puf-value-ok "hello" same-puffer)`. On a puffer with zipper focus
     `none`, returns `(puf-value-none same-puffer)`.
  5. `puffer-str-insert` inserts a string at the cursor position and returns
     the updated puffer with `dirty=true`. Callers should verify the puffer has
     content via `puffer-value` before calling insert. On an empty puffer
     (focus=none, path=nil), S5's insert operation treats the nil path as
     beginning-of-buffer — pure structural, no failure mode.
- **Tests to add:** no new test files for this wave — S1 provides types and
  basic operations. The integration test is S3's command loop calling these
  operations. Structural verification: paren balance, B1 compilation,
  no linear annotation violations.
- **Green line:** all 5 functions have real `def` bodies (not stubs). B1
  compiles the blob (prelude + ports + puffer + str-edit) without errors.
  `puf-value-none` exists on `PufValueR`. `puffer-new` uses `=>`. Zero
  `(1 ...)` annotations on compound types.
- **Done when:** `scaffold/lib/scriba/puffer.chiral` has zero stubs. Every
  `declare` has a real `def`. `PufValueR` has both constructors.
  `puffer-new` is `=>`. The file parses cleanly and compiles through B1
  in a minimal blob (prelude + ports + puffer + str-edit).

## 7. Residue & links

- **Deliberately unbuilt:**
  - Zipper navigation (`puffer-forward`, `puffer-backward`, `puffer-down`,
    `puffer-up`) — pure structural ops on the zipper. Deferred until the
    value is available from the port (post-read). The zipper type exists;
    navigation is a thin layer of path manipulation.
  - `puffer-read` / `puffer-write` — port I/O. Needs the actual read/write
    externals and a result type that handles blocking, EOF, and errors.
    Deferred to S3 (command-loop integration) where the event loop drives
    port reads.
  - Puffer registry (`puffer-list`) — the global list of live puffers.
    S3 territory (rendered by `C-x C-b` equivalent).
  - Polymorphic `puffer-new`/`puffer-close` — currently monomorphic to Str.
    Add `(0 A (type 0))` when multi-type puffers exist.
  - `puffer-close` failure variant — currently returns `Unit`. When real port
    layer exists, add `PufCloseR` with `puf-closed`/`puf-close-err` constructors
    to handle EBADF, EINTR, and other close failures.
  - `PufTypeR` has no error constructor — `type-name` is always set at
    creation. If this invariant proves false (e.g., a puffer created before
    the type-name is known), add `puf-type-err` with the puffer threaded
    back. Currently not needed.
- **Follow-on:** S2 (rendering engine) imports `Puffer`, `PufTypeR`,
  `PufValueR` from this module. S3 (command loop) imports `Puffer`,
  `NewPufR` for puffer lifecycle. S5's `str-edit.chiral` is called by
  `puffer-str-insert` (this spec's Step 6).
- **Related:** [[S1-puffer]] (worked example), [[S1-puffer-AUDIT]] (audit,
  3 FLAGs resolved, 6 FIXes applied), [[SCRIBA-CATALOG.md]] (catalog
  entry), [[SCRIBA-UNBLOCK-MAP.md]] (build plan, S1 is Phase 1 Wave 1),
  [[../manas/.planning/scriba-examples/S1-puffer.md]] (worked example
  with research and design rationale), [[../manas/.planning/scriba-examples/S1-puffer-AUDIT.md]]
  (audit with FLAG resolution and FIX application).
