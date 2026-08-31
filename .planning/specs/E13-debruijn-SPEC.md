---
element: E13
slug: debruijn
title: Term de-Bruijn machinery (`uses_below`, `shift_close`)
kind: SELF-HOST
example: examples/E13-debruijn.md
status: audited
updated: 2026-08-01
---

# E13 SPEC — Term de-Bruijn machinery (`uses_below`, `shift_close`)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** a new `scaffold/lib/terms.chiral` carrying the two de-Bruijn
  walkers in chirality source — `uses-below (-> I64 Term Bool)` and `shift-close
  (-> I64 Term Term)` (each with its depth-threading `-at` core) — as pure, total,
  coverage-checked structural recursions over a closed `data Term`, that, run on
  the RT interpreter, reproduce `scaffold/chirality/terms.py`'s `uses_below` (`:21`)
  and `shift_close` (`:55`) verdict-for-verdict on the ported term constructors.
- **Non-goals (residue → §6):**
  - **Full constructor parity now.** The example ports the binder-bearing core
    subset (`t-var`/`t-app`/`t-lam`/`t-pi`/`t-let`); the **extension nodes**
    (`TCon`/`Con`/`Case`/`Refine`/`Ann` — the `EXT_TERMS` terms.py also walks) are
    the *same traversal at wider arity*, owned by the elements that own those
    constructors (`Case`→E6, `Refine`→E9, the ADT→E1/E3). They are added — in
    lockstep to *both* walkers, coverage-forced — when the full shared `Term` ADT
    is assembled; deferred (§6), not a new idea.
  - Does **not** delete or wire-in `terms.py`; it stays the bootstrap plumbing
    **and** the differential oracle (retired only when the chirality kernel E3/E4
    imports `terms.chiral`).
  - Does **not** turn `shift-close`'s "lowered range unused" precondition into a
    refinement on the argument (decision #2) — it stays a caller obligation, as in
    OURS. Does **not** touch the kernel (this is syntax *beneath* judgment).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** `Term de-Bruijn machinery | CONFORMS · S · E13 |
  "Pure syntactic layer beneath judgment; Built; uses_below/shift_close over all
  formers incl. EXT_TERMS. Syntax-beneath-judgment line drawn cleanly."` CONFORMS
  ⇒ a faithful transcription of a complete, sound 83-line artifact, not a reshape.
  The example gate already passed (`reviewed`).
- **Live code this composes with (do NOT respec):**
  - `scaffold/chirality/terms.py` — the golden oracle (the whole file *is* the
    baseline, "depends on nothing"). `uses_below` (`:21`) folds `Var` leaves to a
    `Bool` over the window `[depth, depth+bound)`; `shift_close` (`:55`) rewrites
    free `Var` leaves by `-delta` under the docstring precondition "valid only
    when none of the lowered range is used." Both are one `go(t, depth)` closure
    recursing at `depth+1` under each binder (`+len(names)` for `Case`).
  - `scaffold/lib/prelude.chiral` — the floor: `Bool`/`and`/`or`, `I64` with
    `+ - <i <=i`; comparisons `=i <i <=i` only (the walkers need only `<i`/`<=i`).
  - `scaffold/lib/collections.chiral` idiom (pure, structural `case`, forward-
    `declare`d) — the style this mirrors.
  - The chirality `Term` ADT is E1/E3's (the example's `data Term` is a subset of it);
    the mutual-data support (E79, built 2026-08-01) is available if a future full
    `Term`↔`Arm` needs it (the `Case` arm).
- **True delta = one new library file's two walkers over a closed `Term` sum.**
  The idea is not new (textbook de-Bruijn; OURS implements it); E13's *content* as
  a self-host is: the closed `data Term` making dispatch coverage-checked (killing
  OURS's silent `return t`/`return False` fallthrough), the structural recursion
  making termination a *proof* not an observation, the `->` purity making "binding
  plumbing touches no port" a typed fact, and the precondition made a caller
  obligation the kernel's QTT usage vector already discharges.

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls:
RESOLVED only when derivable from a settled source (cited); DEFERRED to a named
home; genuinely novel design → NEEDS-AUTHOR, surfaced never answered.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Does `uses-below` stay a **standalone walker**, or does the chirality kernel derive it from the QTT usage vector it already computes? | **RESOLVED — standalone (matches OURS); derivation is a later optimization** | The conformance target is "reproduce `terms.py`," and OURS is a standalone walker; a CONFORMS port transcribes it faithfully. Folding `uses-below` into the E5 usage vector (removing a second traversal) is a *kernel-integration optimization* available only once the chirality kernel (E3/E4/E5) is self-hosted and would need a proof that the two agree — out of E13's syntax-beneath-judgment scope. Homed as residue → [[E05-qtt-semiring]]. Derivable from the CONFORMS verdict. |
| 2 | Is `shift-close`'s "lowered range unused" precondition best a **refinement on the argument** or **discharged at the kernel call site**? | **RESOLVED — caller-discharged, as in OURS** | OURS leaves it a docstring precondition the binder-elimination caller holds via its usage accounting; the port mirrors that. A refinement-typed precondition would need to express "`(uses-below delta t)` is false" — a **computed-`Bool` predicate**, outside E9's refinement fragment (I64 interval/symbolic atoms only; `refine.py:_OPS`). So a refinement encoding is not expressible today regardless; the caller obligation is the sound, available choice. Owner of any future strengthening: [[E09-refinement]] (predicate-over-computation, out of fragment). |
| 3 | How are **many-binder `Case` branches** counted once the full `Term` sum is restored? | **RESOLVED — `depth + (length names)`, with the extension nodes** | The example's own "knobs" answer it: a `Case` branch arm threads `depth + (length names)` instead of `+ 1`, matching `terms.py`'s `depth + len(names)`. This lands with the deferred extension-node arms (non-goal / §6), coverage-forced in both walkers. Derivable from OURS. |

All dispositioned; none blocking. `status: draft` (not blocked).

## 4. Change plan (ordered, commit-sized)

### Step 1 — the core `Term` sum
- **Target:** `scaffold/lib/terms.chiral` (new) — `(import "prelude")`; `data Term`
  = `t-var (idx I64)` / `t-app (fn Term) (arg Term)` / `t-lam (body Term)` /
  `t-pi (dom Term) (cod Term)` / `t-let (val Term) (body Term)` (example §5).
- **Change:** the example §5 `Term` decl verbatim (binder-bearing core subset).
- **Size:** ~S

### Step 2 — `uses-below` (+ `-at` core)
- **Target:** `terms.chiral` — `uses-below-at (-> I64 I64 Term Bool)` +
  `uses-below (-> I64 Term Bool)`.
- **Change:** verbatim from example §5: `t-var` → `(and (<=i depth i) (<i i (+
  depth b)))`; binder nodes recurse at `(+ depth 1)`; `t-app`/`t-pi`/`t-let`
  `or`/`and`-combine subterms. Forward-`declare` the `-at` core. Total
  (structural), pure (`->`).
- **Size:** ~S

### Step 3 — `shift-close` (+ `-at` core)
- **Target:** `terms.chiral` — `shift-close-at (-> I64 I64 Term Term)` +
  `shift-close (-> I64 Term Term)`.
- **Change:** verbatim from example §5: `t-var` → `(case (<i i depth) (true (t-var
  i)) (false (t-var (- i delta))))`; binder nodes recurse at `(+ depth 1)`. The
  precondition stays a caller obligation (decision #2), noted in a comment.
- **Size:** ~S

### Step 4 — differential test file
- **Target:** `scaffold/tests/test_terms_chirality.py` (new; leave any Python
  terms tests untouched).
- **Change:** load `lib/terms.chiral`, drive both walkers with the `apply1` RT
  harness (test_json.py shape) + a Python↔chirality `Term` adapter (build the same
  nameless term on both sides). Assert: for a fixture corpus of core terms,
  `uses-below b t` = `terms.py.uses_below(t', bound)` for every `(t, b)`; and for
  every `(t, delta)` **satisfying the precondition**, `shift-close delta t` yields
  the term `terms.py.shift_close(t', delta)` yields. Fixtures: bound vs free var
  at several depths, nested `lam`/`pi`/`let` binder threading, `app` both sides.
- **Size:** ~M

## 5. Conformance gate

- **Golden behavior:** over a corpus of core (`t-var`/`t-app`/`t-lam`/`t-pi`/
  `t-let`) terms, `terms.chiral::uses-below` agrees with `terms.py.uses_below` for
  every `(term, bound)` (including the window-boundary cases `i = depth` and
  `i = depth+b-1` vs `i = depth+b`), and `terms.chiral::shift-close` yields the
  identical lowered term as `terms.py.shift_close` for every `(term, delta)`
  satisfying the "lowered range unused" precondition — with bound indices
  (`i < depth`) left untouched and binder nodes threading `depth+1`. Extension
  nodes are **out of scope** (added with the full `Term` ADT, §6).
- **Floors compared:** the **chirality RT interpreter** running `terms.chiral` vs the
  **Python `terms.py` oracle**, via a `Term` adapter — lib-level chirality-vs-golden
  (`test_json.py` shape), not native/tal.
- **Green line:** 355 → ≥ 355 + k (the new `test_terms_chirality.py` functions);
  full suite stays green, `terms.py` unchanged, ledger-lint clean.
- **Done when:** `test_terms_chirality.py` passes — both chirality walkers match
  `terms.py` on the core-term corpus, including the window boundaries and the
  bound-vs-free split.

## 6. Residue & links

- **Deliberately unbuilt:**
  - **Extension-node arms** (`TCon`/`Con`/`Case`/`Refine`/`Ann`) to reach full
    `terms.py` parity — added in lockstep to both walkers (coverage-forced) when
    the shared full `Term` ADT is assembled; `Case`'s `depth + (length names)`
    counting (decision #3) lands here. Homes: `Case`→[[E06]], `Refine`→[[E09-refinement]],
    the ADT→[[E01-sexp-reader]]/[[E03-nbe-normalize]].
  - **`uses-below` folded into the QTT usage vector** (one traversal instead of
    two) — a kernel-integration optimization, decision #1 → [[E05-qtt-semiring]].
  - **Precondition as a refinement type** — out of E9's fragment (computed-Bool
    predicate), decision #2 → [[E09-refinement]].
  - Retiring `terms.py` and importing `terms.chiral` into the chirality kernel — rides
    the checker self-host (E3/E4).
- **Follow-on:** the syntactic floor the self-hosted [[E03-nbe-normalize]] /
  [[E04-bidir-universes]] kernel and the chirality ports of `data.py`/`lower.py` reuse.
- **Related:** [[E13-debruijn]] (rationale) · [[E05-qtt-semiring]] (the usage
  vector that already knows `uses_below`/the precondition; dec. #1/#2) ·
  [[E11-totality-checker]] (certifies both walkers structural) · [[E06]] (the
  coverage-checked `case`) · [[E02-surface-elaborator]] (produces the indices) ·
  [[E24-i64-arith]] (the I64 index floor).
