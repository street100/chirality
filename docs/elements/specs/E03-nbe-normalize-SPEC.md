---
element: E03
slug: nbe-normalize
title: NbE: eval / quote / conv (+ eta)
kind: SELF-HOST
example: examples/E03-nbe-normalize.md
status: audited
updated: 2026-08-01
---

# E03 SPEC — NbE: eval / quote / conv (+ eta)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `scaffold/lib/kernel.chiral` exists and contains a
  chirality-source NbE core — `eval-term` / `vapp` / `clos-apply` / `quote-val` /
  `quote-neut` / `normalize` / `conv` / `conv-struct` / `conv-neut` over closed
  `Term` and mutual `Value`/`Clos`/`Neut` sums — that is **differentially equal**
  to `kernel.py`'s `eval_term`/`vapp`/`close_apply`/`quote`/`conv` on the
  closed-core fragment (var/type/pi/lam/app/let + neutral vars), *including*
  rejecting two `Pi`s that differ only in quantity or effect-seat.
- **Non-goals:** globals/prims (`NGlobal`/`NPrim`), data values (`VTCon`/`VCon`),
  the declining-hook extension mechanism (`sig.conv_hooks`/`quote_hooks`/
  `ext_eval`), `subtype`/universe-cumulativity, and literal/`PrimTy`/`Ann` forms
  — each homed in §6. This run ports the trusted **closed core**, not the full
  extensible kernel.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** the sole E3 row is **CONFORMS, size S** — "Full
  NbE core; the settled scaffold shape … Built complete; unknown value-forms
  fall through to conv/quote hooks." The Python reference is done and correct;
  this element is a **self-host transcription**, not a behavior change. The row's
  note — "Judgment core depends only on terms.py; extensions reached via
  declining hooks" — is the architectural fact that scopes the port: the closed
  core is portable now; the *hook* extension surface is not part of this element.
- **Live code (the reference being ported, do NOT respec):**
  - `kernel.py:223 eval_term`, `:261 vapp`, `:270 close_apply`, `:277 conv`,
    `:361 quote` — the exact functions this transcribes.
  - `kernel.py:321 subtype` — a **separate** function carrying universe
    cumulativity + row subsumption. conv is pure definitional equality; subtype
    is not E3's (decision #5).
  - The effect seat at **Pi position 2** is live `Seats(row, grades, totality)`
    (`row.py:35`), a canonical record whose `==` is total (`Row` is sorted/
    deduped, `row.py:28`). `conv` compares it by equality only
    (`kernel.py:298`, `a[2] != b[2]`).
  - Mutual-recursive `data` (needed for `Value`/`Clos`/`Neut`) is **built** —
    E79, commit `11aac83`; the example was re-audited post-E79 and elaborates.
- **True delta:** one new chirality-source file porting the closed-core NbE. The
  example's `(data Arr () (pure) (proc))` 2-point effect sum is a **pre-E39
  snapshot** and is replaced by an opaque `Seat` needing only `seat=` (decision
  #3). No `scaffold/chirality/*.py` changes; `lib/kernel.chiral` is RT-run chirality
  source (`chirality/` stays Python-only).

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | **Totality of `eval-term`/`conv`** — neither is structurally decreasing (beta grows the env on `t-app`; eta grows `lvl`), so the E11 structural + numeric-measure checker cannot pass them. NbE termination rests on the semantic strong-normalization (SN) argument over *well-typed* terms. | **NEEDS-AUTHOR** (trust-surface call). | SN is provable by **no current totality pillar** — not structural/numeric (E11), not sized types (E47), not mutual/lexicographic (E50); it needs a logical-relations model outside the syntactic checker. The author call is the **TCB trust posture**: (a) mark the core `partial` (honest, but the trusted core opts out of totality), or (b) admit it **trusted-total by an axiom tied to the well-typedness precondition** (keeps the totality story, adds one named unproven assumption to the TCB). **Recommended provisional so §4 is unblocked: (b)** — a `(total)`-asserted core with the SN assumption recorded as a named residue (§6), revisited if/when a logical-relations facet lands. Surfaced per the blocker protocol; not silently resolved. |
| 2 | **`nth`: precondition-guarded total helper, or a result sum?** | **RESOLVED → precondition-total (caller-discharged).** | Well-scopedness (`0 <= i < len env`) is discharged by E4's scope-checking *before* `eval` runs, so `nth` is total over its checked domain and needs no runtime guard — the example §4 stance, and the substrate reframe of `kernel.py:230`'s `raise`. The precondition **cannot be a refinement** (a variable list-length bound is outside E9's decidable fragment), so it stays caller-discharged — **same pattern as `E13-debruijn-SPEC`** (`uses_below`/`shift_close` preconditions). A result sum contradicts the pure-total-core goal (decision #6). |
| 3 | **Effect seat: example's `Arr` 2-point sum vs the live `Seats` record.** | **RESOLVED → opaque `Seat` + decidable `seat=`.** | `conv` only compares the seat by equality (`kernel.py:298`); `quote` carries it through unchanged (`kernel.py:371`). So E3 needs **only decidable equality**, never the seat's structure. Port it as an abstract `Seat` type with `seat=`; its `Row`/grades/totality internals are homed to **E12/E39** (`row.py`). This is the E39 baseline correction the **`E12-effect-membrane-SPEC`** already applied ("baseline corrected to the live row-based effects.py; the example's boolean snippet is a pre-E39 snapshot"). |
| 4 | **Extension nodes** — globals/prims (`NGlobal`/`NPrim`), data values (`VTCon`/`VCon`), and the `sig.*_hooks` declining-hook mechanism. | **DEFERRED.** | Data-value arms → **E6** (the `data.py` seam, the example's own "deliberately omitted"). Globals/prims + the hook architecture → deferred to **when the full shared `Term`/`Value` ADT assembles** (coverage-forced extension arms) — the **`E13-debruijn-SPEC` pattern** ("extension-node arms deferred to when the full shared ADT assembles"). This deferral is what lets the core functions **drop the `sig` parameter** the Python reference threads only for hooks/globals. |
| 5 | **`subtype` / universe cumulativity — in `conv` or separate?** | **RESOLVED → separate; DEFERRED to E4.** | Catalog partition: E3 = "eval/quote/conv **(+eta)**"; E4 = "bidirectional infer/check **+ universes/cumulativity**." The live code already separates them (`conv` `kernel.py:277` vs `subtype` `:321`). E3 ports pure definitional equality (eta + strict equality on type/quantity/seat); cumulativity (`Type l <= Type l'`) and row subsumption ride **E4/E39**. |
| 6 | **Unreachable arms** — `vapp` on a non-function head; `conv-struct`'s `v-lam` case (eta handles lams); coverage forces them written. | **RESOLVED → a pure `stuck` sentinel.** | These arms are dead code on checked terms (precondition: the head is a function / eta pre-filters lams, discharged by E4). They **cannot `raise`** — an alarm is a `=>` effect, and raising here would make `eval` effectful, breaking the pure-core guarantee. So they return a distinguished pure `stuck : Value`. This *reinforces* E3's purity story rather than denting it. |
| 7 | **Pi binder `name` field** — live Pi is `("Pi", q, seat, name, dom, cod)`; the example's `v-pi` drops `name`. | **RESOLVED → drop (display-only).** | `name` is carried through `quote` unchanged (`kernel.py:371`) and never touched by `conv`; it is a pretty-printer hint (E14), not judgment. The port omits it, matching the example. |

No NEEDS-AUTHOR is *blocking*: decision #1's recommended provisional (b) unblocks
§4, so this SPEC audited without `status: blocked`. The trust-posture call is
still surfaced for the author to ratify or overturn; either choice leaves §4
intact (it changes only the `(total)`/`(partial)` annotation and the §6 residue
line).

## 4. Change plan (ordered, commit-sized)

### Step 1 — the closed data layer + `Seat`
- **Target:** `scaffold/lib/kernel.chiral` (NEW FILE) — the `data` block.
- **Change:** `(import "prelude")`; define `Term` (`t-var`/`t-type`/`t-pi`/
  `t-lam`/`t-app`/`t-let`), the mutual `Value`/`Clos`/`Neut` group
  (`v-type`/`v-pi`/`v-lam`/`v-ne`; `clos`; `n-var`), and an **opaque `Seat`**
  with `seat=` (decision #3). `t-pi`/`v-pi` carry `(q I64)` and `(seat Seat)`
  (not the example's `Arr`). Forward-`declare` every function in the mutual NbE
  group **before any `def`** (the json.chiral idiom the example follows).
- **Size:** ~S.

### Step 2 — the evaluator
- **Target:** `lib/kernel.chiral` — `eval-term`, `vapp`, `clos-apply`, plus
  helpers `nth` (precondition-total, decision #2), `snoc`, `stuck` (decision #6).
- **Change:** transcribe `kernel.py:223/261/270` per the example §5, `case`-on-
  `Term`/`Value`, closures deferring substitution; `vapp`'s non-function arms
  return `stuck`. No `sig`, no range-guard `raise`.
- **Size:** ~S.

### Step 3 — readback (quote)
- **Target:** `lib/kernel.chiral` — `quote-val`, `quote-neut`, `spine->apps`,
  `normalize`, `fresh`.
- **Change:** transcribe `kernel.py:361`; the level→index move is `(- (- lvl 1)
  k)` at the `n-var` head (example §2 finding 2); `spine->apps` folds `t-app`
  over `(map (quote-val lvl) sp)`. `normalize = (quote-val 0 (eval-term nil t))`.
- **Size:** ~S.

### Step 4 — conversion (eta-first definitional equality)
- **Target:** `lib/kernel.chiral` — `conv`, `conv-struct`, `conv-neut`, and
  helpers `is-lam`, `app-either`, `seat=`.
- **Change:** transcribe `kernel.py:277`. Eta is checked **first** (either side a
  `v-lam` ⇒ apply both to one `fresh lvl`, recurse at `lvl+1`); `conv-struct`
  compares `v-type` levels with `=i`, and `v-pi` by `(=i q q2)` **and**
  `(seat= s s2)` **and** domain conv **and** codomain conv under a fresh var —
  the quantity and seat are part of definitional equality (`kernel.py:298`).
  `conv-neut` compares heads then spines pointwise. The `v-lam` arm of
  `conv-struct` is the coverage-forced dead arm → `false` (decision #6).
- **Size:** ~S.

### Step 5 — totality annotation
- **Target:** `lib/kernel.chiral` — the group's totality stance.
- **Change:** apply decision #1's ratified posture (provisional: assert the group
  `(total)` with the SN assumption recorded, OR mark `partial`). One-line change
  plus the §6 residue note; gated on the author call.
- **Size:** ~XS.

## 5. Conformance gate

- **Golden behavior:** two differentials, because eta lives in `conv`, not in
  readback. **(a) normalize** — for every well-typed **closed** core term `t`,
  `(normalize t)` is **structurally equal** to OURS `quote(sig, 0, eval_term(sig,
  [], t))` (de Bruijn makes alpha free; NbE readback is beta-normal, *not*
  eta-expanded — so this is plain term equality on a canonical serialization).
  **(b) conv** — `(conv lvl a b)` agrees with OURS `conv(sig, lvl, a, b)` on
  every pair, and this is where eta and seat/quantity sensitivity are exercised:
  `true` up to eta (`(t-lam (t-app f (t-var 0)))` ≡ `f` when `0 ∉ FV(f)`), and
  `false` for two `Pi`s that differ **only** in quantity (`0`/`1`/`w`) or
  effect-seat.
- **Tests to add:** a differential harness (new `tests/test_nbe_selfhost.py`, or
  a class in `test_kernel.py`) that, over a fixture corpus of closed core terms +
  `Pi`/quantity/seat pairs, runs the **chirality floor** (`lib/kernel.chiral` under
  the RT interpreter) against the **Python reference** (`kernel.py` NbE) and
  asserts agreement on both `normalize` (alpha-eta) and `conv` (Bool). The corpus
  must include: nested lambdas (level→index boundary), an eta pair, and the
  quantity-differ and seat-differ negative `Pi` cases.
- **Green line:** 355 → ≥ 355 + (fixture count, ≥ 5); ledger-lint clean.
- **Done when:** the chirality `lib/kernel.chiral` NbE and `kernel.py` NbE agree
  structurally on `normalize` output and Bool-for-Bool on `conv` across the
  corpus, with the eta and quantity/seat-sensitivity cases passing.

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - **SN termination proof** of `eval`/`conv` — no current pillar proves it
    (E11/E47/E50 all insufficient); it rests on a named assumption tied to the
    E4 well-typedness precondition until a logical-relations facet exists
    (decision #1). This is the one honest hole in the ported core's totality.
  - **Data-value arms** (`v-tcon`/`v-con`, quoting/conv over them) → **E6**.
  - **Globals/prims** (`n-global`/`n-prim`, the `sig` global environment) + the
    **declining-hook** extension mechanism → deferred to the full shared ADT
    assembly (decision #4).
  - **`subtype` / universe cumulativity / row subsumption** → **E4** / **E39**
    (decision #5).
  - **Literal/`PrimTy`/`Ann`** forms; `spine->apps` fold body detail (example
    elided with `; …`) — mechanical, land with the arms above.
- **Follow-on:** unblocks **E4** (bidirectional infer/check calls `conv`) and
  **E5** (QTT usage runs alongside the same `Pi` binders). E3 is the highest-
  leverage self-host target — every typing rule bottoms out in `conv`.
- **Related:** [[E03-nbe-normalize]], [[E04-bidir-universes]], [[E05-qtt-semiring]],
  [[E13-debruijn]] (precondition + deferral pattern), [[E12-effect-membrane]]
  (the seat baseline correction), [[decision-graded-kernel]] (totality modality),
  [[decision-effect-facets]] (the row the seat carries).
