---
element: E14
slug: pretty-printer
title: Pretty-printer (display, non-trusted)
kind: SELF-HOST
example: examples/E14-pretty-printer.md
status: audited
updated: 2026-08-01
---

# E14 SPEC — Pretty-printer (display, non-trusted)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** a new `scaffold/lib/pretty.chiral` carrying the term/value
  **pretty-printer** in chirality source — `show-term` (a pure, total `(List Str) →
  Term → Str` walk over the closed `Term` sum, coverage-checked) and `show-value`
  (`quote` the value to a term, then `show-term`) — that, run on the RT interpreter,
  reproduces `scaffold/chirality/pretty.py`'s rendered strings (`show_term:19`,
  `show_value:15`): the same s-expr per former, the same `names`-threaded de-Bruijn
  rendering, the same `#i` for an out-of-scope `Var`, the same opaque `(case ...)`.
- **Non-goals (residue → §6):**
  - **`quote` self-host** — `show-value` calls the kernel's `quote` (NbE, **E3**),
    not yet self-hosted; so `show-value`'s *runnable* differential rides E3, while
    `show-term` (the renderer proper) is differentiable now. (Coupling, decision #a.)
  - **Full `Case` rendering** — reproduce OURS's opaque `(case ...)`; per-arm
    printing is a display enhancement, decision #b.
  - **Width-aware / indenting layout** — OURS is flat s-expr; decision #c.
  - Does **not** delete or wire-in `pretty.py`; it stays the golden oracle, and the
    renderer stays **out of the judgment path** (error-path only, non-trusted).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** `Pretty-printer (display) | CONFORMS · S · E14 |
  "Display only, kernel-error paths, cannot unsound checker; Built; no judgment
  path consults it (lazy shims). Low priority; no work owed."` CONFORMS ⇒ faithful
  transcription of a complete 59-line artifact; the example gate passed
  (`reviewed`, load-verified: 8 defs, 6 data types).
- **Live code this composes with (do NOT respec):**
  - `scaffold/chirality/pretty.py` — the golden oracle. `show_term` (`:19`) tag-dispatch
    → s-expr per former (`Pi`→`->`/`=>`, `Lam`/`App`/`Let`/`TCon`/`Con`/`Refine`),
    `names`-threaded de-Bruijn with the `#i` out-of-scope fallback, opaque
    `(case ...)`, and the `<k>` catch-all the closed sum makes dead; `show_value`
    (`:15`) = `K.quote` then `show_term`.
  - `scaffold/chirality/kernel.py` — `quote` (`:361`, the NbE reification `show-value`
    calls; **E3**, not yet self-hosted). `scaffold/lib/prelude.chiral` — `List`/`Str`,
    `str-cat`, `i64->str`, `nil`/`cons`.
  - The `Term` sum this walks is E1/E3/E13's (the example's is a representative
    subset); E79 mutual-data available if a full `Term`↔`Arm` (the `Case` arm) is needed.
- **True delta = one new library file's renderer.** The wins over `pretty.py`:
  coverage-checked `case` over closed `Term` (the `<k>` catch-all *cannot exist* —
  a forgotten former is a compile error), structural-recursion totality (no hang),
  and `->` purity (a "printer" that touches a port is untypeable) — all on the
  component that could never unsound the checker (the P2 "no exemption" point).

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls:
RESOLVED only when derivable from a settled source (cited); DEFERRED to a named
home; genuinely novel design → NEEDS-AUTHOR, surfaced never answered.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| a | Does `show-value` keep the **`quote` dependency** (E3) or take an already-quoted `Term`? | **RESOLVED — keep `quote` (matches OURS); the renderer is quote-free** | OURS `show_value` (`:15`) = `quote` then `show_term`, so a faithful port keeps it; `quote` is E3's NbE (not yet self-hosted), so `show-value`'s runnable differential rides E3 while **`show-term` is self-contained and differentiable now**. Same coupling shape as E16/E17→E18. Owner: [[E03-nbe-normalize]]. Derivable from `pretty.py`. |
| b | How much of a **`Case`** to render? | **RESOLVED — opaque `(case ...)`, matching OURS** | `pretty.py:98–99` renders `Case` as the literal `(case ...)`; the port reproduces it. Full per-arm printing is a display enhancement (a knob), not owed by a faithful port. Derivable from OURS. |
| c | **Width-aware / indenting layout?** | **RESOLVED — no; flat s-expr, matching OURS** | `pretty.py` emits flat s-expressions with no line-breaking; the port matches. Pretty-layout is the first thing a *human-facing* printer (vs this error-path one) would add — a future element, not E14. Derivable from OURS. |

All dispositioned; none blocking. `status: draft`.

## 4. Change plan (ordered, commit-sized)

### Step 1 — `show-term` + display helpers
- **Target:** `scaffold/lib/pretty.chiral` (new) — `(import "prelude")`; the string
  helpers `sp`/`parens`/`names-snoc`/`nth-name` (the `#i` out-of-scope fallback),
  and `show-term` over the **full** `Term` former set (subset in the example;
  add `t-pi`/`t-tcon`/`t-con`/`t-refine`/`t-case`/`t-global` — coverage forces each).
- **Change:** the example §5 spine, extended to `pretty.py` former parity; `Pi`
  renders `->`/`=>` on the effect bit and drops the quantity when `W`; `Case` opaque
  `(case ...)` (decision #b); `Var` → `nth-name` (decision: `#i` fallback). Total,
  pure `->`.
- **Size:** ~M

### Step 2 — `show-value` (quote ∘ render)
- **Target:** `pretty.chiral` — `show-value (-> I64 Value Str)`.
- **Change:** `(show-term nil (quote lvl v))` — `quote` is E3's (coupling, dec. #a).
- **Size:** ~S

### Step 3 — differential test file
- **Target:** `scaffold/tests/test_pretty_chirality.py` (new; leave any Python pretty
  tests untouched).
- **Change:** load `lib/pretty.chiral`, drive `show-term` with the `apply1` RT harness
  + a Python↔chirality `Term` adapter. Assert `show-term names t` equals
  `pretty.py.show_term(t', names)` string-for-string over a former corpus (each
  former; nested binders threading `names`; an out-of-scope `Var` → `#i`; `Case` →
  `(case ...)`). `show-value`'s end-to-end differential is **E3-gated** (dec. #a) —
  until then test `show-term` (the self-contained renderer).
- **Size:** ~M

## 5. Conformance gate

- **Golden behavior:** `pretty.chiral::show-term` reproduces `pretty.py.show_term`'s
  string on a term corpus — the same s-expr per former, `names`-threaded de-Bruijn
  rendering (a bound `Var` → its name, an out-of-scope `Var` → `#i`), the opaque
  `(case ...)` for `Case`, flat layout. It is total (every term renders, no hang)
  and `->` (no port). `show-value`'s end-to-end match rides E3's `quote`-in-chirality.
- **Floors compared:** the **chirality RT interpreter** running `pretty.chiral` vs the
  **Python `pretty.py` oracle** via a `Term` adapter — lib-level chirality-vs-golden
  (`test_json.py` shape), not native/tal.
- **Green line:** 355 → ≥ 355 + k (the new `test_pretty_chirality.py` functions); full
  suite stays green, `pretty.py` unchanged, ledger-lint clean.
- **Done when:** `test_pretty_chirality.py` passes — the chirality renderer matches
  `pretty.py.show_term` string-for-string on the corpus (all formers, `names`
  threading, `#i` fallback, opaque `Case`).

## 6. Residue & links

- **Deliberately unbuilt:**
  - **`show-value`'s `quote` self-host** — **[[E03-nbe-normalize]]** (dec. #a); the
    renderer `show-term` is quote-free and differentiable now.
  - **Full `Case` arm rendering** (beyond opaque `(case ...)`) — decision #b, a
    display enhancement; nobody's yet.
  - **Width-aware / indenting layout** — decision #c, the first add for a
    *human-facing* printer (vs this error-path one); nobody's yet.
  - Retiring `pretty.py` and wiring `pretty.chiral` onto the kernel's error path —
    rides the checker self-host; keeps the renderer out of the judgment path.
- **Follow-on:** unblocks nothing hard — E14 is the low-stakes leaf; it demonstrates
  the discipline reaches even the non-trusted display component (P2).
- **Related:** [[E14-pretty-printer]] (rationale) · [[E03-nbe-normalize]] (the
  `quote` `show-value` calls; dec. #a) · [[E13-debruijn]] (the `Term`/index
  machinery walked) · [[E01-sexp-reader]] (the inverse — this un-parses to the
  s-expr the reader parses) · [[E24-i64-arith]] (the I64 index/level floor).
