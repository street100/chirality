---
element: E02
slug: row-inference
title: Effect-row inference — the call-graph monotone closure producing `def_rows` (the sig-driver slice E70/E51 consume)
kind: SELF-HOST
reference_class: OURS/PAPER
ours_source: scaffold/chirality/surface.py
status: implemented
updated: 2026-08-03
---

# E02 (row-inference slice) — Effect-row inference: the call-graph monotone closure producing `def_rows`

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.
>
> **Scope note.** This is the deferred E2 §6 slice ("Effect-row inference
> (`_infer_row`/`_elab_stamped`) — E39-coupled"), now unblocked (E39's row
> carrier is built scaffold-side). It is the first half of the **sig-driver**:
> the chirality-side derivation of `sig.def_rows`, the per-def effect row that E70's
> lowering gate + preserve-check (`lib/eff-lower.chiral`: `eff-gate`, `row-check`,
> `sysface`) and E51 currently take as a *given* input. The second half — the
> chirality signature representation that carries `def_rows` (+ `sys-bindings` +
> port classification) for `lower-all` to consult — is a sibling slice (§6).

## 1. Scope

- **Element:** the chirality-side port of `surface._infer_row`/`_elab_stamped` —
  infer each definition's **effect row** (the crossings it *transitively*
  performs) by a monotone closure over the syntactic call graph, seeded by port
  classification, and record it as `def_rows[name]`.
- **Kind:** SELF-HOST — Python `surface.py` → chirality source (shrink the TCB; put
  the compiler's own row derivation in the check/compile path).
- **Why chirality needs its own:** the rung-1 fixpoint requires **zero CPython in
  the check/compile path**. E70's floor gate and preserve-check are already
  ported (`lib/eff-lower.chiral`) but consume `def_rows` as a given — they cannot
  run over a self-compiled program until chirality *derives* those rows itself. This
  slice is that derivation: the sig-driver's row half.

## 2. Research

- **Reference class:** OURS — `surface.py._infer_row` (the monotone closure) +
  `_elab_stamped` (the write-back). PAPER — a monotone dataflow fixpoint over a
  finite lattice `℘(crossing-names)`.
- **Key findings (load-bearing):**
  1. **The row is a monotone worklist closure, and every non-leaf expands to
     syntactic callees.** From the seed name: a `prim_is_port` name is a **leaf**
     that contributes *itself*; an already-stamped global's `def_rows` is a
     **leaf** that contributes its *final row* (no re-descent — imports/earlier
     units are final); any other name expands to `_calls[n]` (its syntactic
     callees). `seen` bounds the walk; `row_of` (sorted, de-duplicated) makes the
     result a **total canonical form** — decidable, order-independent equality,
     which is exactly what the fixpoint's "reached?" test and Lane determinism
     need.
  2. **Two loader-seam inputs.** `prim_is_port` (which externs cross — derived at
     kernel elaboration from the eff bit) and `_calls` (the syntactic call graph,
     accumulated *during* elaboration). E39-coupled because the row's typed shape
     is E39's; that carrier is now built, so the port is unblocked.
  3. **Dependency ordering carries the fixpoint.** Imports and earlier globals
     are stamped first, so they are final leaves; a **mutual-recursion SCC**
     (E79 groups) is the only place the closure must iterate to a joint fixpoint.
     The `n != name` guard stops a global short-circuiting on *itself*, so
     self-recursion correctly expands to callees rather than reading a
     half-built row.
  4. **DYN is discarded.** The higher-order `*` placeholder (`ROW_DYN_NAME`) is
     dropped from the result — E69 defunctionalizes its only source before the
     floor, so a lowered body's rows are always precise (this is why E70 never
     represents DYN).

## 3. Conventional (other-language) approach

The OURS Python — a mutable-set worklist:

```python
def _infer_row(self, name):
    seen, stack, names = set(), [name], set()
    while stack:
        n = stack.pop()
        if n in seen: continue
        seen.add(n)
        if self.sig.prim_is_port.get(n):        # a crossing extern: a leaf
            names.add(n); continue
        r = self.sig.def_rows.get(n)            # an already-final global: a leaf
        if r is not None and n != name:
            names.update(r.names); continue
        stack.extend(self._calls.get(n, ()))    # otherwise: expand to callees
    names.discard(ROW_DYN_NAME)
    return row_of(names)                        # sorted canonical
```

Mainstream compilers, by contrast, treat effect/purity as an **unchecked
attribute** (`__attribute__((pure))`, LLVM `readonly`) — asserted, never
re-derived; or, in effect-typed languages (Koka/Frank), inferred as a row but
without a *floor* re-check after lowering.

- **Assumptions it bakes in:** mutable set accumulation + ambient dict lookups
  (`self.sig.…`); an unbounded `while` with no totality obligation on the
  fixpoint; the inferred row is trusted downstream (in the conventional world it
  is never re-checked at codegen — the very gap E70 closes).

## 4. The chirality idea

- **Chirality features in play:** the effect membrane's **exercise facet** (the row
  = the crossings a term performs, `->` empty vs `=>` nonempty); inference *from
  the call graph* rather than a written annotation; **totality** (the closure is
  a bounded monotone walk — it must be expressed with a decreasing measure, not
  a `while`); the **canonical sorted set** as the row's normal form.
- **The reframing:** the row is a **derived typed fact**, threaded immutably.
  The mutable `seen`/`stack`/`names` become threaded `(List Str)` accumulators;
  the unbounded `while` becomes a **fuel-bounded** structural recursion whose
  measure is the finite node count (`|names in the graph|` — every non-skip step
  grows `seen`, so it terminates: E11 numeric-measure termination). `row_of`
  becomes a byte-lexicographic sort (D-1's `ty-cmp`/`str->bytes` order) so the
  result is a unique normal form.
- **What chirality makes impossible here:** a **nondeterministic** row (the sorted
  canonical form forces one normal form — Lane determinism); an **unchecked**
  row (this derivation feeds E70's `row-check`, which *re-derives and compares*
  at the floor — the claim is never trusted, unlike the conventional attribute);
  a **non-terminating** inference (no `while` — the measure is mandatory).

## 5. Chirality example (fleshed)

```chirality
; ---- the loader seam, as immutable data (given; a sibling slice builds it) ----
;   ports   : prim_is_port  -- the crossing externs (a name is a leaf iff here)
;   calls   : the syntactic call graph  (name -> its callees)
;   stamped : def_rows of already-final globals  (imports + earlier units)
(data RowSig ()
  (rowsig (ports   (List Str))
          (calls   (List (Pair Str (List Str))))
          (stamped (List (Pair Str (List Str))))))

; ---- infer-row: the monotone call-graph closure (ports surface.py _infer_row) -
; Result = the crossings `name` transitively performs, sorted + deduped (row_of).
(declare infer-row (-> RowSig Str (List Str)))
(def infer-row (lam (sg name)
  ; fuel = node count: seen strictly grows on every non-skip step, so the walk
  ; terminates by that numeric measure (E11) -- the chirality stand-in for `while`.
  (row-of (irow sg name (node-count sg) (cons name nil) nil nil))))

; irow: the worklist.  (stack seen names) threaded; fuel is the measure.
(declare irow (-> RowSig Str I64 (List Str) (List Str) (List Str) (List Str)))
(def irow (lam (sg name fuel stack seen names)
  (case stack
    (nil names)                                   ; drained -> the accumulated row
    ((cons n rest)
      (case (mem-str n seen)
        (true  (irow sg name fuel rest seen names))            ; already visited
        (false (irow-visit sg name fuel n rest (cons n seen) names)))))))

; irow-visit: classify n -- PORT leaf / STAMPED-global leaf / expand to callees.
(declare irow-visit (-> RowSig Str I64 Str (List Str) (List Str) (List Str) (List Str)))
(def irow-visit (lam (sg name fuel n rest seen names)
  (case (mem-str n (rowsig-ports sg))
    (true  (irow sg name fuel rest seen (cons n names)))       ; a crossing: leaf
    (false
      (case (stamped-row sg n name)                            ; (Maybe (List Str))
        ((some r) (irow sg name fuel rest seen (row-join r names)))  ; final: leaf
        (none     (irow sg name fuel                                 ; expand
                        (append (callees sg n) rest) seen names))))))))

; helpers (declared; mechanical -- field reads via `case`, assoc lookups, the
; byte-lex sort. chirality has no auto-accessors, so each field read is its own
; declared helper that case-destructures the RowSig.) ; …
(declare rowsig-ports (-> RowSig (List Str)))               ; the ports field
(declare node-count   (-> RowSig I64))                      ; the fuel bound
(declare callees      (-> RowSig Str (List Str)))           ; calls[n], or nil
(declare stamped-row  (-> RowSig Str Str (Maybe (List Str)))) ; stamped[n] iff n != name
(declare row-of       (-> (List Str) (List Str)))           ; sort + dedup + DYN-discard (canonical)
```

- **Knobs to modify:** the seed name (`infer-row sg name`); the port set
  (`rowsig-ports` — swap in the real `prim_is_port`); the fuel measure
  (`node-count` — any finite over-approximation of the reachable graph works);
  the canonical order (`row-of` — byte-lex today).
- **Deliberately omitted:** the **mutual-SCC joint fixpoint** (E79 groups —
  inferring a recursive clique to a shared fixpoint; single-def closure here);
  building `calls`/`ports` (the elaboration write-back + port classification —
  sibling sig-driver slices, §6); `_elab_stamped`'s *stamping the row onto the
  type's effect arrows* (the write-back into the elaborated `Core`, separate);
  DYN beyond discard.

## 6. Use / modify notes

- **Lands in:** the E2 port surface (`lib/surface.chiral`) or a focused
  `lib/row-infer.chiral`. It **produces** `def_rows`, the input
  `lib/eff-lower.chiral` (E70: `eff-gate`/`row-check`/`sysface`) and E51 consume.
- **Conformance target:** differential vs `surface._infer_row` over a corpus of
  call graphs — a port leaf, an already-stamped-global leaf, a transitive chain,
  a self-recursive def (the `n != name` guard), a DYN discard, an empty (`->`)
  row — **byte-identical sorted rows** each.
- **Open questions:**
  - **The sig-driver's second half:** the chirality signature representation that
    *carries* `def_rows` (+ `sys-bindings` + `prim_is_port`) so `lower-all`
    consults it — E69's `SigV` holds only `tys`/`defs`; this slice needs the row
    columns added. Is that an extension of `SigV`, or a new `RowSig`-like view
    bridged by the loader? (Decide in the spec.)
  - **How `_calls` and `prim_is_port` are built chirality-side** — the elaboration
    write-back (record each call as it elaborates) and the kernel port
    classification (the eff-bit seed). Own slices, or folded into the E2 elab
    port?
  - **Mutual-SCC iteration** — is the joint fixpoint in scope for the fixpoint
    milestone, or deferred to E79's group machinery?
- **Related:** [[E39-effect-row]] (the row carrier this fills), [[E70-effectful-lowering]]
  (the consumer — gate + preserve-check), [[E51-sys-linkage]] (sys-bindings /
  ports), [[E79]] (mutual data / SCC groups — the joint fixpoint), [[E2-surface-elaborator]]
  (the parent element; this is its deferred §6 row-inference slice), [[E11]]
  (the numeric-measure termination the fuel bound uses).
