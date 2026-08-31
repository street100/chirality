---
element: E27
slug: dict-set-to-maps
title: Data-structure registries (dict/set → chirality maps)
kind: REPLACE-CRUTCH
reference_class: PAPER/IMPL
ours_source: (none)
status: drafted
updated: 2026-07-13
---

# E27 — Data-structure registries (dict/set → chirality maps)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E27, the keyed-collection substrate — every place the checker
  today reaches for a CPython `dict` or `set` (symbol tables, ctor registries,
  seen-sets, env frames) becomes a first-class chirality `Map`/`Set` value.
- **Kind:** REPLACE-CRUTCH. CPython dicts are a host convenience we must shed;
  `lib/collections.chiral` seeds the replacement (assoc lists), and this example
  designs the proper structure it graduates into.
- **Why chirality needs its own:** the registries are load-bearing inside the
  trusted judgment, so they cannot stay as an untyped host builtin with ambient
  `__hash__`/`__eq__` and hidden mutation. A chirality map is a pure, total,
  immutable value whose ordering discipline is *in the type*, not borrowed from
  the interpreter.

## 2. Research

- **Reference class:** PAPER/IMPL. Okasaki, *Purely Functional Data Structures*
  (persistent balanced trees, structural sharing); Adams' weight-balanced BST
  (the algorithm behind Haskell `Data.Map`/`Data.Set`); the local
  `lib/collections.chiral` assoc-list seed as the naive baseline.
- **Key findings:**
  1. **Ordering, not hashing.** A persistent ordered map keys off a *total
     comparison* `K -> K -> Ord`, supplied explicitly. This sidesteps needing a
     `hash`/`__eq__` protocol and keeps everything on the I64/Bytes floor — no
     float hashing, no identity semantics.
  2. **Persistence via sharing.** Insert/delete return a new tree that shares
     all untouched subtrees; the old value stays valid. Mutation is never
     observable, so there is no aliasing hazard to reason about.
  3. **A balance invariant carries the cost bound.** Weight- (or rank-)balanced
     nodes keep height `O(log n)`; rebalance is a local rotation after each
     structural edit. The invariant is what a later refinement pass can assert.
  4. **Set is Map to Unit.** No second structure — `Set K = Map K Unit` — so the
     whole `set` surface collapses onto the same total core.

## 3. Conventional (other-language) approach

How this is done outside chirality — the current CPython crutch and its assoc-list
seed stand-in.

```python
# The crutch: an ambient builtin dict as a registry.
ctors: dict[str, CtorInfo] = {}
ctors[name] = info                     # in-place mutation, no obligation
info = ctors.get(name)                 # None on miss — a silent partiality
if key in seen:                        # set membership via __hash__/__eq__
    raise DuplicateError(key)          # error via control flow (an exception)
```

- **Assumptions it bakes in:** ambient allocation and in-place mutation (every
  `d[k] = v` mutates a shared object); an implicit `__hash__`/`__eq__` protocol
  the language cannot see or check; partial lookup that returns `None` and hopes
  the caller checks; errors as thrown exceptions; and identity/insertion-order
  semantics that leak into behavior. None of these are in a signature.

## 4. The chirality idea

How chirality's model reframes it.

- **Chirality features in play:** the `->` pure membrane (a map is inert data, never
  a port); errors-as-values (lookup returns `Opt`, duplicate-insert is a chosen
  policy, not a throw); totality (structural recursion on the tree, no
  unbounded loop); QTT-erased type params `(0 K (type 0))`; and the I64/Bytes
  floor (comparison bottoms out in `=i`/`<i` on I64 or `bcmp` on Bytes, never a
  hash of a float).
- **The reframing:** the registry stops being an object you mutate and becomes a
  value you thread. Every edit is a pure `Map K V -> Map K V`. Key ordering is a
  *parameter* — a total `(-> K K Ord)` handed in at the call site — so the map
  makes no assumption about keys it wasn't given evidence for. A miss is a
  representable `(none)`, forcing the caller to `case` on it.
- **What chirality makes impossible here:** you cannot silently mutate a shared
  registry (there is no in-place op); you cannot look a key up and forget the
  miss (the `Opt` is in the return type); you cannot compare keys by an unseen
  protocol (the comparator is an explicit argument); and a lookup can never
  throw or hang (total, errors are values).

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
(import "prelude")

; Three-way total comparison result — the ordering vocabulary.
(data Ord () (lt) (eq) (gt))

; Optional result — a miss is a value, never a throw.
(data Opt ((A (type 0)))     ; data params are (P ty) — surface.py:225; type
  (none)                     ; params of data are erased by the decl machinery
  (some (v A)))              ; [NB: SPEC resolves Opt -> reuse prelude Maybe,
                             ;  whose ctors are already none/some]

; A persistent ordered map: a balanced BST. `h` carries the height/weight the
; balance invariant reads. Type params are erased (0 ...) — no runtime cost.
(data Map ((K (type 0)) (V (type 0)))
  (mtip)
  (mnode (l (Map K V)) (k K) (v V) (r (Map K V)) (h I64)))

; A set is just a map to Unit — one core, two surfaces.
(declare Set (-> (type 0) (type 0)))
(def Set (lam (K) (Map K Unit)))

(declare m-empty (-> (Map K V)))
(def m-empty (lam () (mtip)))

; Pure lookup: threads a supplied total comparator; returns Opt, never partial.
(declare m-lookup
  (-> (0 K (type 0)) (0 V (type 0))
      (-> K K Ord)          ; the comparator is an explicit argument
      K (Map K V) (Opt V)))
(def m-lookup
  (lam (cmp key m)
    (case m
      ((mtip) (none))                       ; miss is a representable value
      ((mnode l k v r h)
        (case (cmp key k)
          ((lt) (m-lookup cmp key l))       ; structural recursion — total
          ((gt) (m-lookup cmp key r))
          ((eq) (some v)))))))

; Pure insert: returns a NEW map sharing every untouched subtree.
(declare m-insert
  (-> (0 K (type 0)) (0 V (type 0))
      (-> K K Ord) K V (Map K V) (Map K V)))
(def m-insert
  (lam (cmp key val m)
    (case m
      ((mtip) (mnode (mtip) key val (mtip) 1))
      ((mnode l k v r h)
        (case (cmp key k)
          ((lt) (rebalance (mnode (m-insert cmp key val l) k v r h)))
          ((gt) (rebalance (mnode l k v (m-insert cmp key val r) h)))
          ((eq) (mnode l key val r h)))))))  ; last-write-wins policy, explicit

; Set surface reuses the core; membership is a lookup, add is an insert.
(declare s-member (-> (0 K (type 0)) (-> K K Ord) K (Set K) Bool))
(def s-member
  (lam (cmp key s)
    (case (m-lookup cmp key s) ((some u) true) ((none) false))))

; --- elided skeleton (mechanical, out of the spine) ---
(declare rebalance (-> (Map K V) (Map K V)))   ; single/double rotation on skew
; (def rebalance ... ; …  read h, rotate when weight invariant breaks)
; i64-cmp / bytes-cmp : the concrete comparators handed to cmp above
;   (def i64-cmp (lam (a b) (cond ((=i a b) (eq)) ((<i a b) (lt)) (else (gt)))))
```

- **Knobs to modify:** the key type `K` and its comparator (`i64-cmp`,
  `bytes-cmp`, a composite for tuple keys); the collision policy on `eq`
  (last-write-wins here vs. a `(p-err "duplicate")` for insert-once registries);
  the value type `V` (`Unit` gives a set, a `CtorInfo` sum gives the registry);
  and the balance discipline in `rebalance` (weight- vs. rank-balanced).
- **Deliberately omitted:** the rotation body, delete/merge, ordered traversal
  (`m-fold`), and any refinement asserting the height invariant — all mechanical
  once the spine and the comparator contract are fixed.

## 6. Use / modify notes

- **Lands in:** `lib/collections.chiral` (graduating the assoc-list seed into the
  tree core), with the checker's symbol/ctor registries migrating off host
  `dict`/`set` onto `Map`/`Set` from there.
- **Conformance target:** golden behavior of a Python `dict` used as a registry —
  insert-then-lookup returns the stored value; overwrite replaces; a missing key
  yields the miss branch (not `KeyError`); set membership matches `in`. The
  chirality version must reproduce those results while being pure, total, and
  immutable (the old map still valid after an insert).
- **Open questions:** which comparator contract to standardize (a single
  `Ord`-returning `cmp` vs. a `<` + `=` pair); whether insert-once registries
  want a distinct `m-insert-new : ... -> PR (Map K V)` result-sum variant; and
  whether to prove the `O(log n)` height bound via refinement now or defer it.
- **Related:** [[E25-byte-cells]] (Bytes-keyed maps need `bcmp` over `[len]
  [payload]` cells) · [[E26-alarms]] (insert-once collision as a returned error
  value) · [[E27-dict-set-to-maps]].
