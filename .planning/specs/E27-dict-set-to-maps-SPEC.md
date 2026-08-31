---
element: E27
slug: dict-set-to-maps
title: Data-structure registries (dict/set → chirality maps)
kind: REPLACE-CRUTCH
example: examples/E27-dict-set-to-maps.md
status: audited
updated: 2026-07-27
---

# E27 SPEC — Data-structure registries (dict/set → chirality maps)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `lib/collections.chiral` gains a persistent ordered
  `Map K V` (a balanced BST keyed on an explicitly-supplied total comparator
  `(-> K K Ord)`) with the total, pure core — `m-empty`, `m-lookup`,
  `m-insert`, `m-insert-new`, `m-delete`, `m-fold` — plus the `Set K = Map K Unit`
  surface (`s-empty`, `s-member`, `s-add`) and the two concrete comparators
  `i64-cmp` / `bytes-cmp`. Every operation is a pure `Map K V -> …` value:
  deterministic iteration order (ascending by the comparator), miss is `Maybe`,
  the pre-insert map stays valid.
- **Non-goals:** (1) porting the Python checker's `Sig` dict/set registries onto
  these maps — that is the self-hosting / determinism-debt-pin arc this core
  *unblocks*, tracked in §6, not built here; (2) a refinement proof of the
  `O(log n)` height invariant (decision #4, deferred); (3) the alarm/`PR`-carrying
  insert-once error facet (decision #2, E26); (4) ordered set-algebra (union /
  intersect / diff) beyond the single-key spine.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** the one row naming E27 is **EXTEND / M** —
  *"Seed only; 20 List/Pair combinators, no assoc-map/set yet … Additive: add
  assoc-map/set, migrate checker dict registries (E27's real payload)."* So the
  change is purely additive to an existing library file; nothing is refactored
  away.
- **Live code (compose with, do NOT respec):**
  - `scaffold/lib/collections.chiral` — the seed. Already provides `Maybe`-based
    optionals (`head -> (Maybe A)`, `cat-maybes`, `maybe-map`, `maybe-then`,
    `with-default`), `foldl`/`foldr`, and the **assoc-list map seed**
    `alist-get` / `alist-put` / `alist-has` (lines 116/128/141). The tree core
    graduates *these three*; the `Maybe` vocabulary is reused as-is.
  - The trusted-core registries the payload eventually targets live in the `Sig`
    class, `scaffold/chirality/kernel.py:115–150`: symbol tables `global_types` /
    `global_defs` / `global_values`, ctor registries `data` (dname→DataDecl) /
    `ctor_home` (cname→dname), the linear-port set `linear_data`
    (`kernel.py:122`), the coverage seen-set `covered` (`data.py:202`), and the
    linearity walk's `seen` (`data.py:69–87`, keyed on `repr(tyv[2])` — debt D-1
    in `.planning/DETERMINISM-DEBTS.md`; threaded from `kernel.py:207`
    `is_linear`). All are `str`-keyed CPython dicts / sets — the determinism
    debt. [Orchestrator audit 2026-07-22: earlier draft cited a `_seen` at
    `data.py:216`, which does not exist — corrected to the real sites.]
- **True delta:** the balanced-tree `Map`/`Set` core + comparators in
  `lib/collections.chiral`, and its tests. The `Sig` migration is deliberately
  *out* of this delta (§6).

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Comparator contract: a single `Ord`-returning `cmp : (-> K K Ord)` vs a `<` + `=` predicate pair | **RESOLVED → single `cmp : (-> K K Ord)`** | Deterministic iteration requires a *total* order, and `Ord = {lt,eq,gt}` makes trichotomy an **exhaustive `case`** the totality/coverage checker verifies — the `<`+`=` pair leaves the "neither" outcome implicit (an unchecked "gt") and costs two predicate calls per node (2×`O(log n)`) vs one. The example's fleshed §5 already commits to `Ord`; the pair is listed only as the rejected alternative. Bottoms out in `=i`/`<i` (I64) or `bcmp` (Bytes) — no hash, no float, no identity. |
| 2 | Do insert-once registries want a distinct `m-insert-new : … -> PR (Map K V)` result-sum variant? | **Split: RESOLVED (pure form) + DEFERRED → E26 (effectful form)** | Ship `m-insert-new : … -> (Maybe (Map K V))` now — `none` = key already present, `some m'` = inserted. This is the pure, alarm-free collision-detecting primitive (a collision is a *value*), needs no new machinery, and is exactly what a ctor registry needs ("can't declare a ctor twice"). The richer `PR`/alarm-carrying facet (collision as a raised crossing) is E26's territory (decision-effect-facets; alarms-are-crossings) — DEFERRED there, layered over this core. |
| 3 | Standardize on `Opt` (example §5) or the existing `Maybe`? | **RESOLVED → reuse `Maybe`** | `collections.chiral` already threads `Maybe` through `head`/`cat-maybes`/`maybe-map`/`with-default`. Introducing a parallel `Opt` would fork the optional vocabulary in the same file. `m-lookup` returns `(Maybe V)`; the example's `Opt` becomes `Maybe`, and its ctor names need **no** change — prelude's `Maybe` ctors are literally `none`/`some` (`lib/prelude.chiral:13-15`; audit 2026-07-22 — an earlier draft guessed `just`/`nothing`). Note the collision is load-bearing, not stylistic: ctors are globally unique (`ctor_home`), so a parallel `Opt` with `none`/`some` would fail to load against the prelude at all. |
| 4 | Prove the `O(log n)` height bound via refinement now, or defer? | **DEFERRED → refinement follow-on (E27-height, unscheduled)** | The balance invariant is maintained *operationally* by `rebalance`; asserting it in the type needs **inductive refinement over a recursive datatype**, beyond `refine.py`'s current I64 constant-/symbolic-bound fragment. The example itself lists the height-invariant refinement under "deliberately omitted … mechanical once the spine is fixed." Correctness (lookup/insert/delete results) does not depend on it; only the cost bound does. |
| 5 | Does an `Ord` datatype already exist in the prelude? | **RESOLVED → absent; Step 1 adds it** | Settled by orchestrator grep 2026-07-22: no `Ord` / `(lt)` / `(gt)` anywhere in `scaffold/lib/*.chiral`. Step 1 adds the 3-nullary-ctor `data` to `collections.chiral`. |

No decision blocks §4: #1/#2(pure)/#3/#5 are resolved, #4 is out of scope, #2(effectful) is non-blocking.

## 4. Change plan (ordered, commit-sized)

### Step 1 — `Ord` vocabulary + comparators
- **Target:** `scaffold/lib/collections.chiral` — new `Ord` data (guard on prelude
  per decision #5) + `i64-cmp` / `bytes-cmp`.
- **Change:** `(data Ord () (lt) (eq) (gt))` (confirmed absent from lib —
  decision #5); then
  `i64-cmp = (lam (a b) (cond ((=i a b) (eq)) ((<i a b) (lt)) (else (gt))))` —
  (`cond`, not `if`: the surface has no `if` form — `surface.py:293`; audit
  2026-07-22 corrected the example's spelling) — this is
  the immediately-buildable total leaf order. `bytes-cmp` over the
  `[len][payload]` byte cell is **gated on E25** (drafted, not implemented; no
  `bcmp` primitive exists in the tree today — orchestrator grep 2026-07-22):
  land `i64-cmp` + the Map core now, add `bytes-cmp` when E25's cell/compare
  primitive exists.
- **Size:** ~S

### Step 2 — the `Map` type + `m-empty` / `m-lookup`
- **Target:** `scaffold/lib/collections.chiral` — new `Map` datatype and read spine.
- **Change:** adapt example §5, with the parser-legal data-param spelling —
  `(data Map ((K (type 0)) (V (type 0))) (mtip) (mnode (l (Map K V)) (k K) (v V) (r (Map K V)) (h I64)))`
  (data params are 2-element `(P ty)` per `surface.py:225`; the example's
  quantified `((0 K (type 0)) …)` is rejected by `top_data` — prelude idiom is
  `((A (type 0)))`, `lib/prelude.chiral:13`; audit 2026-07-22); `m-empty`;
  `m-lookup : (-> (0 K) (0 V) (-> K K Ord) K (Map K V) (Maybe V))` by structural
  recursion on the tree (total — the coverage checker sees the exhaustive `case`
  on `Ord`). Uses `Maybe` per decision #3.
- **Size:** ~S

### Step 3 — `rebalance` + `m-insert`
- **Target:** `scaffold/lib/collections.chiral` — the write spine + the balance body
  the example left elided.
- **Change:** `rebalance : (-> (Map K V) (Map K V))` — read `h`, single/double
  rotation on skew (weight- or rank-balanced; pick one and note it inline);
  height/weight recomputed from children. `m-insert` per §5 (last-write-wins on
  `eq`), wrapping recursive results in `rebalance`. Structural recursion → total.
- **Size:** ~M

### Step 4 — `m-insert-new`, `m-delete`, `m-fold`
- **Target:** `scaffold/lib/collections.chiral`.
- **Change:** `m-insert-new : (-> … (Maybe (Map K V)))` (decision #2 pure form —
  `none` on present-key, else `some` of the inserted tree); `m-delete` (BST
  delete + `rebalance`, standard successor-splice); `m-fold : (-> (0 K)(0 V)(0 B)
  (-> B K V B) B (Map K V) B)` in-order (ascending) — the deterministic-iteration
  primitive that is the whole determinism point.
- **Size:** ~M

### Step 5 — the `Set` surface
- **Target:** `scaffold/lib/collections.chiral`.
- **Change:** `(def Set (lam (K) (Map K Unit)))`; `s-empty = m-empty`;
  `s-member` (via `m-lookup`, returns `Bool`); `s-add` (via `m-insert … unit`);
  optional `s-add-new` (via `m-insert-new`). One core, two surfaces.
- **Size:** ~S

### Step 6 — retire the assoc-list seed's callers (in-file only)
- **Target:** `scaffold/lib/collections.chiral` — leave `alist-*` present but
  document the tree core as the graduation; do **not** touch the Python `Sig`
  sites (that is §6 follow-on).
- **Change:** doc comment marking `alist-get/put/has` as the superseded seed;
  no behavior change. Keeps the migration honest and traceable.
- **Size:** ~S

## 5. Conformance gate

- **Golden behavior (from example §6):** a Python `dict`/`set` used as a registry
  — insert-then-lookup returns the stored value; overwrite replaces
  (last-write-wins); a missing key yields the miss branch, never `KeyError`; set
  membership matches `in`. The chirality `Map`/`Set` must reproduce these while being
  pure (pre-insert map still valid), total (checker admits every op without a
  `require_total` failure), and deterministic (`m-fold` visits keys in ascending
  comparator order regardless of insertion order).
- **Tests to add** (`scaffold/tests/test_collections.py`):
  1. `insert→lookup` hits; `lookup` of absent key = miss branch (differential:
     reference-eval floor vs the Python `dict` oracle).
  2. overwrite = last-write-wins; original map unchanged after insert
     (persistence).
  3. `m-insert-new`: `some` on fresh key, `none` on duplicate.
  4. `m-fold` yields keys sorted by `i64-cmp`, independent of insertion order
     (the determinism assertion) — compared against Python `sorted(...)`. [The
     `bytes-cmp` ordering assertion joins when the E25-gated `bytes-cmp` lands
     (Step 1); it is not part of this element's gate — audit 2026-07-27.]
  5. `Set`: `s-member` matches Python `in`; `s-add` idempotent.
  6. totality: the checker classifies every `m-*`/`s-*` def total (structural
     recursion), asserted via the `(total)` gate.
- **Green line:** 281 → ≥ 287 (the 6 named test functions; audit 2026-07-27
  aligned the floor to the named list — the earlier ≥ 293 assumed a
  double-count incl. the E25-gated `bytes-cmp` half); `ledger-lint.py` clean.
- **Done when:** `test_collections.py` proves insert/overwrite/miss/delete +
  ascending `m-fold` order + persistence + set membership, all defs pass the
  totality gate, and the pre-insert map is observably still valid.

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - **`Sig` registry migration** — the "real payload." Ordered first-migration
    list (the sites, by priority): **(1)** `Sig.ctor_home` + `Sig.data`
    (`kernel.py:147/146`) — the ctor registry, the canonical case, and the
    duplicate-ctor error that exercises `m-insert-new`; **(2)** `Sig.global_types`
    / `global_defs` / `global_values` (`kernel.py:115–117`) — the name→X symbol
    tables; **(3)** the seen-sets → `Set`: `linear_data` (`kernel.py:122`),
    `covered` (`data.py:202`), the linearity walk's `seen` (`data.py:69–87`,
    debt D-1 — needs the `tyv-cmp` follow-on below). Home: the checker
    self-hosting / determinism-debt-pin arc (Stage1==Stage2 fixpoint), NOT this
    element — this core is its prerequisite.
  - **The emission-order role (D-2 re-pin, 2026-07-22):** this map's
    comparator-sorted iteration IS the canonical emission order — the D-2 pin
    is "emit sorted by a total key in BOTH stages," so the Python scaffold's
    `lower_all`/`native.compile` must adopt the same sort when the pin lands
    (they follow dict insertion order today; see DETERMINISM-DEBTS D-2). An
    insertion-ordered map variant is explicitly NOT this element's job.
  - **`tyv-cmp : (-> TyV TyV Ord)`** — the D-1 canonical key over type
    values, by structural recursion over the TyV sum; an E27 follow-on
    sequenced after E25 (`bytes-cmp` for name keys). Assigned 2026-07-22
    (2nd-order audit: previously unowned across E08/ledger/this SPEC).
  - **`O(log n)` height refinement** — decision #4, refinement follow-on.
  - **Alarm/`PR` insert-once facet** — decision #2, E26.
  - **Set algebra** (`s-union`/`s-inter`/`s-diff`), ordered range queries,
    `m-merge` — mechanical extensions once the spine lands; nobody's yet.
- **Follow-on:** unblocks the determinism debt-pin (deterministic checker
  registries → Stage1==Stage2), and E26's collision-as-crossing insert-once.
- **Related:** [[E25-byte-cells]] (`bytes-cmp` over `[len][payload]` cells) ·
  [[E26-alarms]] (insert-once collision as returned error value) ·
  [[E27-dict-set-to-maps]].
