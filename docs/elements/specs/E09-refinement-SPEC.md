---
element: E09
slug: refinement
title: Refinement decision procedure: interval-with-holes + symbolic bounds, `entails`
kind: SELF-HOST
example: examples/E09-refinement.md
status: audited
updated: 2026-08-01
---

# E09 SPEC — Refinement decision procedure: interval-with-holes + symbolic bounds, `entails`

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** the **entailment decision procedure** added to
  `scaffold/lib/refine.chiral` (the file E10 also targets — E9 is the *engine*, E10
  the narrow layer) — a `Constraint` data type (interval-with-holes + symbolic
  `(op, level)` facts) and a pure, total `entails (-> Constraint Constraint Bool)`
  (+ `is-empty` and the constant/symbolic sub-checks) that, run on the RT
  interpreter, reproduces `scaffold/chirality/refine.py`'s `entails` (`:123`) /
  `is_empty` (`:106`) verdicts: interval containment + hole-subsumption + syntactic
  symbolic-subset, with emptiness decided first (vacuous truth).
- **Non-goals (residue → §6):**
  - **The full-predicate REFACTOR** — octagon/solver-backed entailment,
    inter-variable arithmetic (`v < n+1`), bases beyond I64. The map row's named
    end-state is a **procedure swap = REFACTOR**, gated on edge 3 / consumed by
    E41; this SPEC ports the *built decidable fragment* (decision #1).
  - Does **not** touch the kernel — refinement rides the value-form seams
    (`check/subtype/conv/quote_hooks`), "kernel UNTOUCHED" (map row).
  - Does **not** delete `refine.py`; it stays the oracle. **Provides `entails`/
    `Constraint` to [[E10-occurrence-typing]]** (whose `narrow` appends atoms this
    engine decides) — E10's stand-in `Env`/`Atom` resolve to these.

## 2. Baseline (what already exists)

- **Conformance-map verdict — two facets (this SPEC takes the fragment):** the E9
  row is `Refinement decision procedure | REFACTOR · L | "FULL predicates
  (v<n+1, inter-var arith, bases beyond I64)" | "Built as named fragment:
  interval+holes+syntactic symbolic, I64-only, literal/bare-Var operands"` — the
  *full-predicate* end-state is a procedure swap (REFACTOR); the **built fragment
  is sound+complete for constants, sound for symbolic** and is what this SELF-HOST
  ports. Kernel untouched (value-form seams isolate).
- **Live code this composes with (do NOT respec):**
  - `scaffold/chirality/refine.py` — the golden oracle. `entails` (`:123`, interval
    floor/ceiling + hole-subsumption + `sym2 <= sym1`), `is_empty` (`:106`, empty
    interval **or** finite range fully punched out), `_atom` (`:65`)/`_sym_atom`
    (`:82`, constant vs level-keyed symbolic atoms), `build` (`:88`), `satisfies`
    (`:95`). The constraint is `(lo, hi, excluded, sym)` with `None`-openable bounds.
  - `scaffold/lib/prelude.chiral` — `Maybe`/`List`/`Pair`/`Bool`, `=i <i <=i`; the
    refinement ops are exactly `>= > <= < <>` (`refine.py:_OPS`).
  - `scaffold/lib/refine.chiral` — **E10's narrow layer lands here too**; E9 adds the
    `Constraint`/`entails` engine that E10's atoms feed (shared file, composed).
- **True delta = the engine half of `refine.chiral`.** The wins over `refine.py`:
  the `(lo,hi,ex,sym)` tuple-with-`None` becomes a `Constraint` data type
  (`Maybe I64` bounds, `List I64` holes, `List (Pair SymOp I64)` facts); `entails`
  is a pure `->` total function (a decision procedure chirality proves terminates — no
  solver oracle, no partiality); emptiness is decided *first*, structurally, so
  vacuous truth cannot be forgotten (OURS's "call `is_empty` first or get an
  unsound answer" becomes a `case` arm).

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls:
RESOLVED only when derivable from a settled source (cited); DEFERRED to a named
home; genuinely novel design → NEEDS-AUTHOR, surfaced never answered.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | **Deliverable boundary** — the built fragment, or the full-predicate solver? | **RESOLVED — the fragment; solver deferred** | The map splits them: the fragment is *built* (sound+complete constants / sound symbolic), the full-predicate procedure is the **REFACTOR** end-state (octagon/solver, inter-var arith), gated on edge 3 and consumed by E41. Porting the fragment neither needs nor performs the swap. Deferred → the E9 REFACTOR facet + [[E41]]/edge 3. Derivable from the map's two-tier framing. |
| 2 | Does the self-hosted version **key symbolic facts by de-Bruijn level** (as OURS) or by name? | **RESOLVED — by level (matches OURS)** | `refine.py:_sym_atom` (`:82`) keys the symbolic fact by de-Bruijn *level* (`len(ctx) - 1 - idx`), so the port keys `(SymOp, I64-level)` identically — a faithful transcription, and level-keying is what keeps the fact stable under context extension. Derivable from `refine.py`. |
| 3 | The **`is_empty` finite-fully-punched-out** case (example §5 omits it, keeping only floor>ceiling). | **RESOLVED — include it; the port needs the FULL `is_empty`** | Completeness *depends* on `is_empty` (an uninhabited constraint vacuously entails everything). OURS `is_empty` (`:106`) has both conditions (empty interval **and** a finite range whose every point is a hole); the example elided the second for brevity, but a sound+complete port must include it, else `entails` wrongly rejects sound subtypings. Scoped in §4. Derivable from `refine.py`. |

All dispositioned; none blocking. `status: draft`.

## 4. Change plan (ordered, commit-sized)

### Step 1 — `Constraint` + constant-domain helpers
- **Target:** `scaffold/lib/refine.chiral` — `data SymOp` (`>= > <= < <>`),
  `data Constraint` (`(Maybe I64)` lo/hi, `(List I64)` excluded, `(List (Pair
  SymOp I64))` sym); `below-lo`/`above-hi`/`interval-empty`/`i64-mem`/`lo-ok`/
  `hi-ok`/`holes-ok`.
- **Change:** the example §5 data + constant helpers (verbatim); structural
  recursion on the hole list → total. All declares before defs.
- **Size:** ~M

### Step 2 — `is-empty` (BOTH conditions) + symbolic helpers
- **Target:** `refine.chiral` — `is-empty` (interval empty **or** finite range
  fully punched — decision #3, port `refine.py:106`), `sym-tag`/`fact-eq`/
  `fact-mem`/`sym-subset`.
- **Change:** the example's interval-empty **plus** the finite-punch case the
  example elided (walk `[lo,hi]`, every point in `excluded`); symbolic subset =
  syntactic (`sym2 ⊆ sym1`), level-keyed (decision #2). Total.
- **Size:** ~M

### Step 3 — `entails` (emptiness-first decision)
- **Target:** `refine.chiral` — `entails (-> Constraint Constraint Bool)`.
- **Change:** port `refine.py:entails` (`:123`): `is-empty c1` → true (vacuous);
  else `lo-ok ∧ hi-ok ∧ holes-ok ∧ sym-subset`. `case`-on-Bool, not value-`if`.
- **Size:** ~S

### Step 4 — differential test file
- **Target:** `scaffold/tests/test_refine_engine_chirality.py` (new; leave
  `test_refine.py` untouched).
- **Change:** load `lib/refine.chiral`, drive `entails`/`is-empty` with the `apply1`
  RT harness + a `Constraint` adapter over `refine.py`'s tuples. Assert parity with
  `refine.py.entails` over a corpus: `{>=5,<10} <: {>=0}` accept; `{>=0}` ⊄ `{>=5}`
  reject; an uninhabited `c1` entails everything (both `is_empty` conditions);
  symbolic `{v<n} <: {v<n}` accept, `{v<n} ⊄ {v<n+1}` reject (syntactic).
- **Size:** ~M

## 5. Conformance gate

- **Golden behavior:** `refine.chiral::entails` reproduces `refine.py.entails` on a
  corpus — interval containment (floor/ceiling), hole-subsumption (every hole c2
  punches, c1 punches or excludes by range), syntactic symbolic-subset (level-keyed),
  with `is-empty` (both conditions) decided first so an uninhabited c1 entails
  everything. Sound+complete for constants, sound for symbolic — no inter-var
  arithmetic (that's the deferred REFACTOR).
- **Floors compared:** the **chirality RT interpreter** running `refine.chiral` vs the
  **Python `refine.py` oracle** via a `Constraint` adapter — lib-level
  chirality-vs-golden (`test_json.py` shape).
- **Green line:** 355 → ≥ 355 + k (new `test_refine_engine_chirality.py`); full suite
  green, `refine.py` unchanged, ledger-lint clean.
- **Done when:** `test_refine_engine_chirality.py` passes — `entails`/`is-empty` match
  `refine.py` on the corpus (containment, holes, symbolic subset, both emptiness
  conditions).

## 6. Residue & links

- **Deliberately unbuilt:**
  - **Full-predicate procedure** (octagon/solver, inter-var arithmetic `v<n+1`,
    bases beyond I64) — the E9 **REFACTOR** facet, decision #1 → edge 3 / consumed
    by [[E41]] (region types); the built fragment is what E9-port delivers.
  - Retiring `refine.py` and wiring `entails` onto the live value-form seams —
    rides the checker self-host.
- **Follow-on:** **provides `entails`/`Constraint` to [[E10-occurrence-typing]]**
  (its `narrow` appends atoms this engine decides; E10's stand-in `Env`/`Atom`
  become these) and underlies every refinement subtyping / in-bounds check.
- **Related:** [[E09-refinement]] (rationale) · [[E10-occurrence-typing]] (the
  narrow layer sharing `refine.chiral`; consumes `entails`) · [[E41]] (region types,
  the full-predicate consumer; decision #1) · [[E04-bidir-universes]] (subtype calls
  `entails` at refinement seams) · [[E24-i64-arith]] (the exact-integer I64 floor).
