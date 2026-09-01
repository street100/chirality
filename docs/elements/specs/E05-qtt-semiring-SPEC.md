---
element: E05
slug: qtt-semiring
title: QTT quantity semiring + usage-vector linearity accounting
kind: SELF-HOST
example: examples/E05-qtt-semiring.md
status: audited
updated: 2026-08-01
---

# E05 SPEC — QTT quantity semiring + usage-vector linearity accounting

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `scaffold/lib/qtt.chiral` exists — the grade set `Qty`
  (`q0`/`q1`/`qw`) plus eight total, coverage-checked ops: the semiring
  `qadd`/`qmul`/`qjoin`/`qfits` and the usage-vector algebra
  `uzero`/`uadd`/`uscale`/`ujoin` over `(List Qty)` — differentially **byte-equal**
  to `kernel.py`'s `qadd`/`qmul`/`qjoin`/`qfits`/`uzero`/`uadd`/`uscale`/`ujoin`.
  This is the file E3/E4's `lib/kernel.chiral` imports for the `Qty` type + ops it
  declared as seams (resolves E4 decision #5's Qty-home concretely).
- **Non-goals:** the **linear-kind enforcement** (`on_binder` at `q=1`, erasure
  forcing `q=0` — the conformance map's "membrane half" facet) → **E8**/**E12**,
  not the arithmetic; the **E38 product-semiring** instance (cost×time×space×info)
  → its own element; the judgment traversal that *calls* these ops → **E3/E4**;
  context machinery → **E13**.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** three CONFORMS/S rows name E5, but only the first
  is E5's *port surface* — "quantity semiring (0/1/w) + usage vectors … qadd/
  qmul/qjoin/qfits + usage vectors." The second row (**linear-kind enforcement at
  `on_binder`**) and third (**Prelude A-floor**) are adjacent facets whose
  *enforcement* is **E8/E12** and whose floor is already built; E5 ports the
  arithmetic, not the enforcement wiring. Self-host transcription of a correct
  reference.
- **Live code (the reference being ported, do NOT respec):**
  - `kernel.py:65 qadd`, `:73 qmul`, `:83 qjoin`, `:88 qfits`, `:94 uzero`,
    `:98 uadd`, `:102 uscale`, `:106 ujoin` — verified byte-exact against the
    example's tables (0-unit/saturating `qadd`; 0-annihilating/1-unit `qmul`;
    `qjoin` = `a if a==b else W`; `qfits` = W-admits-all-else-exact).
  - **The two enforcement formulas** the ops serve, in the consumers (not built
    here): application `uadd(uf, uscale(q, ua))` (`kernel.py:455`, E4) and let-exit
    `uadd(ub[:-1], uscale(q, uv))` after `qfits(used, q)` (`:540/548`, E4).
  - **Prelude** (`lib/prelude.chiral`, CONFORMS) supplies `List`/`cons`/`nil`/`<=i`
    /`-` — E5's only dependency, so its differential runs standalone.
- **True delta:** one new `lib/qtt.chiral` with the 8 pure ops over a 3-constructor
  `Qty` sum. No `scaffold/chirality/*.py` change; `kernel.py` stays the bootstrap
  referent.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | **How grade-set parametricity is realized** — the four ops as a first-class record (closures at the floor → **E69**) vs per-instance specialization via `specialize`/pregen (zero closures → **E17**). | **DEFERRED → E38 / E52.** | Parametricity is *not exercised* by E5's port: the ops are concrete total tables over the concrete `Qty` sum. It only bites when the **E38 product instance** swaps in, and the record-vs-specialize lowering choice belongs to the **kernel-core lowering** call (E52) informed by E69 (record route) vs E17 (staging route). E5's job is the *shape* — vector algebra parametric through exactly the four ops (the reserved seat) — which it delivers. Not a blocker; not E5's call. |
| 2 | **`qfits` returns `Bool` or a diagnostic sum?** | **RESOLVED → `Bool`.** | The live code keeps `qfits : Bool` (`kernel.py:88`) and lifts the diagnostic **one level up** at `strip_binder`/`close_binder` (`:540`), which are E4's and return `CkR`. Errors-as-values is satisfied at the binder-exit boundary, not in the hottest inner op — keeping `qfits` a cheap `Bool` matches both the reference and E4's `CkR` design. Decidable → decided. |
| 3 | **Vector-length invariant** — `(List Qty)` of length = context depth is a discipline; `(UVec n)` in the type wants value-indexed data. | **RESOLVED (now) → caller-discharged; DEFERRED (typed form) → E48.** | The invariant (vector length = context depth) is maintained by the judgment traversal (E3/E4) — same caller-discharged-precondition pattern as E3's `nth`. The example's structural recursion is total and truncates gracefully on mismatch (no `zip` shortest-wins footgun to inherit). Encoding the length in the type (`UVec n`) needs value-indexed telescopes → **E48**. |
| 4 | **File home** — example says `lib/qtt.chiral`; E3/E4 put the shared ADT in `lib/kernel.chiral` and imported `Qty`/ops as seams. | **RESOLVED → `lib/qtt.chiral`, imported by `lib/kernel.chiral`.** | Clean separation: `qtt.chiral` = the grade algebra (E5); `kernel.chiral` = the term/value ADT + judgment (E3/E4). E4's "declare `Qty`" becomes "import from `qtt.chiral`." This is the first file of the kernel-core port tree (E52). |

No NEEDS-AUTHOR: every open question is decidable-and-decided or defers to a
named home; the change plan is fully unblocked (audited without `status:
blocked`).

## 4. Change plan (ordered, commit-sized)

### Step 1 — the grade set + semiring
- **Target:** `lib/qtt.chiral` (NEW FILE) — `Qty` + `qadd`/`qmul`/`qjoin`/`qfits`.
- **Change:** `(import "prelude")`; `(data Qty () (q0) (q1) (qw))`; transcribe the
  four ops as the coverage-checked `case` tables in example §5 (verified byte-
  equal to `kernel.py:65–91`). Every arrow `->` (accounting performs no crossing).
- **Size:** ~S.

### Step 2 — the usage-vector algebra
- **Target:** `lib/qtt.chiral` — `uzero`/`uadd`/`uscale`/`ujoin`.
- **Change:** `uzero` by numeric-measure recursion (`n` toward 0, the E11 measure
  fragment proves total); `uadd`/`uscale`/`ujoin` by structural recursion over
  `(List Qty)` (explicit `case`, floor-friendly shape). Matches `kernel.py:94–107`
  on equal-length vectors (the maintained invariant, decision #3).
- **Size:** ~S.

## 5. Conformance gate

- **Golden behavior:** the chirality `lib/qtt.chiral` ops are differentially **byte-
  equal** to `kernel.py`'s across: the full 3×3 tables of `qadd`/`qmul`/`qjoin`
  (9 pairs each), the `qfits` truth table (9 pairs), and `uzero`/`uadd`/`uscale`/
  `ujoin` over sampled equal-length vectors. Plus the **semiring laws as property
  checks**: `qadd` associativity + commutativity, `qmul` distributes over `qadd`,
  `q0` as `qadd`-unit and `q1` as `qmul`-unit.
- **Standalone:** unlike E4, this gate needs **nothing else built** — only prelude
  (CONFORMS). The differential runs the chirality floor (`lib/qtt.chiral` under the RT
  interpreter) against the Python reference (`kernel.py` q-ops) directly.
- **Tests to add:** `tests/test_kernel.py` (or a `test_qtt_selfhost.py`) with the
  table + law + vector cases above, comparing the two floors.
- **Green line:** 355 → ≥ 355 + (case count, ≥ 6); ledger-lint clean.
- **Done when:** chirality and Python agree on all 36 table entries, the sampled
  vector ops, and the semiring-law properties.

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - **Linear-kind enforcement** (`on_binder` q=1, erasure q=0, `is_linear`
    `kernel.py:208`) → **E8** / **E12** — the "membrane half" facet, not the
    arithmetic.
  - **E38 product-semiring instance** (the grade enrichment) → **E38**; E5 only
    reserves the swappable seat.
  - **Parametricity lowering** (record/E69 vs specialize/E17) → **E38/E52**
    (decision #1).
  - **`(UVec n)` typed length invariant** → **E48** (decision #3).
- **Follow-on:** unblocks **E3/E4** (they import `Qty` + ops from here — the seam
  they declared), **E8** (linear-kind reads `q=1`), **E39** (the graded-
  continuation law the application formula enforces), **E52** (kernel-core is this
  file + the traversal).
- **Related:** [[E05-qtt-semiring]], [[E03-nbe-normalize]], [[E04-bidir-universes]]
  (the consumers), [[E38-graded-cost]] (the enrichment instance),
  [[E39-effect-row]] (the law the app formula enforces), [[E13-debruijn]]
  (context machinery), [[E08-linear-kinds]] (the enforcement half),
  [[decision-graded-kernel]] (the parametric coeffect semiring).
