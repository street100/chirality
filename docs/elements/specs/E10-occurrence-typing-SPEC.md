---
element: E10
slug: occurrence-typing
title: Path-sensitivity / occurrence typing (`_narrow`, `sig.narrow_hooks`)
kind: SELF-HOST
example: examples/E10-occurrence-typing.md
status: audited
updated: 2026-08-01
---

# E10 SPEC — Path-sensitivity / occurrence typing (`_narrow`, `sig.narrow_hooks`)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** a new `scaffold/lib/refine.chiral` carrying the
  **path-sensitivity layer** in chirality source — the `Guard`/`Bound` data and a
  pure, total `narrow (-> Env Guard Bool Env)` fact-transform — that, run on the
  RT interpreter, reproduces the *atom-selection* behavior of
  `scaffold/chirality/refine.py`'s `_narrow` (`:298`): on the `true` arm it appends
  the atom the guard proves, on the `false` arm the negated atom, and for an
  unrecognized guard it returns the environment unchanged.
- **Non-goals:**
  - Does **not** self-host the refinement **engine** — the predicate-conjunction
    datatype and its `entails`/`satisfies`/`is_empty` decision are **E9**
    (`refine.py:88–158`); this element only *produces* the atom that engine later
    decides. `narrow` is the occurrence-typing hook, not the solver.
  - Does **not** port the **comparison-spine unwinder** (a scrutinee term
    `(<i i n)` → `Guard`); the example §5 deliberately omits it and takes a
    `Guard` as given. It is a small follow-on (see §6), not E10's core.
  - Does **not** delete or wire-in `refine.py`. Its `_narrow` stays the
    bootstrap hook **and** the differential oracle; this SPEC validates the chirality
    transform, it does not make it *the* narrowing path (the value-form-seam
    wiring rides the whole E9/E10 self-host, downstream).
  - Does **not** touch the kernel — narrowing lives behind the
    `check_hooks`/`subtype_hooks`/`narrow_hooks` value-form seams (map row: "no
    reshape here").

## 2. Baseline (what already exists)

- **Conformance-map verdict:** `CONFORMS · S · E10` — "Guarded branch narrows
  compared var to proven bound; Built; `_narrow` + `_LEARN`, `Ctx.narrow` swaps
  ascribed type only (sound). Predicate richness rides on E9's fragment; no
  reshape here." CONFORMS ⇒ the frame is settled: this is a faithful
  transcription of a complete, sound artifact, not a reshape. The example gate
  already passed (`reviewed`); no decision is re-argued.
- **Live code this composes with (do NOT respec):**
  - `scaffold/chirality/refine.py` — the golden oracle. `_narrow` (`:298`) unwinds a
    comparison `App` spine and, for each operand that is a `var` already typed
    `VRefine I64`, installs the guard's atom via `Ctx.narrow`; `_atom` (`:65`) /
    `_sym_atom` (`:82`) build the constant / symbolic atoms; `entails` (`:123`),
    `_const_atoms` (`:145`), `build` (`:88`) are the **E9** engine `narrow`
    feeds. `_operand` (`:289`) / `_unann` (`:283`) are the operand classifier.
  - `scaffold/chirality/kernel.py` — `Ctx.narrow` (`:192`) swaps the ascribed type
    on the narrowed binder only (the soundness the map row cites); the
    `narrow_hooks` seam is declared at `:139` and consumed at `data.py:226`
    (per-`case`-arm narrowing).
  - `scaffold/lib/prelude.chiral` — the floor this is written over: `List`/`Pair`/
    `Maybe`/`Bool`/`Str`; comparisons are **`=i <i <=i` only** (no `>`/`>=`), so
    a `ge`/`gt` atom is represented as the negation it is, not a new operator.
  - The proven idiom to mirror: `scaffold/lib/json.chiral` / any `data`+`case`
    transform with forward-`declare`d helpers (json.chiral idiom).
- **True delta = one new library file's path-sensitivity slice.** The `data`+
  `case` fact-transform idiom is established; E10's *new* content is the `Guard`/
  `Bound` shapes, the true-vs-false atom selection (`pick-atom`), and the atom
  constructors (`lt-atom`/`le-atom`/`ge-atom`/`gt-atom`). Because E9's real
  `Env`/`Atom` are not yet in chirality, this element defines a **minimal stand-in
  representation** sufficient to run and test `narrow`'s selection logic
  (decision #4), which E9's self-host later replaces.

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls:
RESOLVED only when derivable from a settled source (cited); DEFERRED to a named
home; genuinely novel design → NEEDS-AUTHOR, surfaced never answered.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Does narrowing compose across **nested** guards by env threading, or need an explicit fact-merge? | **RESOLVED — env threading, no merge** | Derivable from the built oracle: `data.py:226` runs `narrow_hooks` **per `case` arm**, and `Ctx.narrow` (`kernel.py:192`) checks that arm under the already-narrowed ctx. Nested guards are nested arms, so the second `narrow` receives the env the first produced; the conjunction accumulates because `add-atom` *appends* to the operand's existing refinement rather than replacing it. No separate merge step exists or is needed — the example §5's threaded shape matches OURS exactly. |
| 2 | How does a **symbolic** bound "collapse to a constant" when the referenced variable is itself a refined constant? | **DEFERRED → E9** | This is an engine behavior, not a narrowing one: the status-ledger records "a symbolic bound collapses to a constant on instantiation (Pi re-evaluation), keeping subtyping sound" — that is `refine.py`'s `_sym_atom`/`entails`/instantiation path (**E9**). `narrow` only *emits* the `b-sym` atom; whether it later collapses is decided when the engine evaluates the refinement. Out of E10's scope; the atom E10 produces is forward-compatible with either outcome. Owner: [[E09-refinement]]. |
| 3 | Is `Env` **linear** (`1`) or **unrestricted**? | **RESOLVED — unrestricted (ω)** | `Env` is compile-time **judgment data** (a refinement environment), not a runtime resource, port, or capability. Only ports/capabilities/secrets carry `q=1` (P2; glossary "linear"). `narrow` is a pure `->` fact-transform that reads and rebuilds env freely, so its binders are unrestricted; a `1` would wrongly forbid the read-and-rebuild the transform needs. Derivable from P2 + the `->` purity the example §4 fixes. |
| 4 | *(surfaced by the bundle)* E9's real `Env`/`Atom` are **not yet in chirality** — what does E10's runnable `narrow` operate on? | **RESOLVED — minimal stand-in, E9 replaces it** | To hit the E01 runnable-differential bar without waiting on E9's self-host, E10 defines a thin `Atom` (an op-tagged `I64`/symbolic bound, i.e. `Bound` reused as the atom payload) and `Env` as an assoc-list `(List (Pair Str (List Atom)))`. This is enough to test *which atom lands on which branch* — E10's whole job — with zero engine logic. When E9 self-hosts its predicate-conjunction `Env`/`Atom`, `narrow`'s body is unchanged; only the stand-in types are swapped for E9's. Engineering scoping call, not author-tier; the E9 hand-off is named in §6. |

All dispositioned; none blocking. `status: draft` (not blocked).

## 4. Change plan (ordered, commit-sized)

### Step 1 — data shapes + the stand-in env
- **Target:** `scaffold/lib/refine.chiral` (new) — `(import "prelude")`; `data
  Bound` (`b-const (k I64)` / `b-sym (n Str)`), `data Guard` (`g-lt`/`g-le` each
  `(var Str) (bnd Bound)`, `g-none`), and the stand-in `data Atom`
  (`a-lt`/`a-le`/`a-ge`/`a-gt`, each over `Bound`) + `Env` alias
  `(List (Pair Str (List Atom)))` (decision #4).
- **Change:** exactly the example §5 `Bound`/`Guard` decls; `Bound` declared
  before `Guard` (json.chiral forward-order idiom); add the `Atom`/`Env` stand-in.
- **Size:** ~S

### Step 2 — atom constructors + true/false selector
- **Target:** `refine.chiral` — `lt-atom`/`le-atom`/`ge-atom`/`gt-atom
  (-> Bound Atom)`, `pick-atom (-> Bool Atom Atom Atom)`.
- **Change:** each `*-atom` wraps a `Bound` into the matching `Atom` ctor;
  `pick-atom on-true a-then a-else` returns the true-arm atom or its negation
  (mirrors OURS `_atom` picking the op vs its complement per `cname`). Total
  (no recursion). Forward-`declare` all before the `narrow` def.
- **Size:** ~S

### Step 3 — `add-atom` (append into the env)
- **Target:** `refine.chiral` — `add-atom (-> Env Str Atom Env)` + assoc helpers.
- **Change:** structural recursion over the assoc-list: find the var's entry,
  `cons` the new atom onto its atom-list (or insert a fresh singleton entry) —
  mirrors OURS appending an atom to the operand's refinement conjunction
  (`Ctx.narrow` + `build`). Total via structural recursion on the list.
- **Size:** ~M

### Step 4 — `narrow` (the hook, verbatim from example §5)
- **Target:** `refine.chiral` — `narrow (-> Env Guard Bool Env)`.
- **Change:** paste the audited example §5 `narrow` body (`case` on `Guard`;
  `g-none` → env; `g-lt`/`g-le` → `add-atom` of `pick-atom (lt/ge)`,
  `(le/gt)`). Already syntax-legal (`case`, no value-level `if`).
- **Size:** ~S

### Step 5 — differential test file
- **Target:** `scaffold/tests/test_refine_narrow.py` (new; keep the Python
  `test_refine.py` engine tests untouched).
- **Change:** load `lib/refine.chiral` via `Elab().load_file`, drive `narrow`
  with the curried `apply1` RT harness (test_json.py shape). Prefer a **live**
  differential over a transcribed table: from one source per case, build *both*
  (a) the OURS inputs — a scrutinee term
  `(App (App (Prim "<i") (Var i)) (Const k))` plus a `Ctx` binding the var to
  `("VRefine",_I64,TOP)` (or bare `_I64`) — call `refine.py:_narrow`, and read
  the atom(s) it installed off the narrowed binder via the returned ctx's
  `lookup`; and (b) the corresponding chirality `Guard`, run `narrow`, read back the
  resulting `Atom`. Assert op+bound agree per branch (`<`/`<=` → interval on
  `true`, negated `>=`/`>` on `false`; symbolic → `b-sym`/`_sym_atom`), and that
  `g-none` (unrecognized shape) ⇔ OURS `_narrow` returning `None` ⇔ chirality env
  unchanged. Transcription-with-cited-lines is a **fallback only** for a shape
  OURS cannot be driven into — not the default.
- **Size:** ~M

## 5. Conformance gate

- **Golden behavior:** for every `(Guard, branch)` pair, `refine.chiral::narrow`
  installs the same atom OURS `refine.py:_narrow` would install for the
  corresponding comparison/operand: `g-lt const` → `(< k)` on `true` / `(>= k)`
  on `false`; `g-le const` likewise with `<=`/`>`; symbolic bounds → the
  `b-sym`/`_sym_atom` atom, entailment untouched; `g-none` (and any operand that
  is not a var over a refinement) → env returned unchanged. Narrowing composes
  across nested guards by env threading (decision #1).
- **Floors compared:** the **chirality RT interpreter** running `refine.chiral` vs the
  **Python `refine.py` oracle** driven live (`_narrow` called on constructed
  scrut+ctx, the installed atom read back) — lib-level chirality-vs-golden, the
  `test_json.py` shape, not a native/tal differential. The engine decision
  (`entails`/`satisfies`) is **not** exercised here — it is E9's gate.
- **Green line:** 355 → ≥ 355 + k (the new `test_refine_narrow.py` functions);
  full suite stays green, `refine.py` unchanged, ledger-lint clean.
- **Done when:** `test_refine_narrow.py` passes — the chirality `narrow` selects the
  atom OURS selects on both branches for every recognized guard and is a no-op on
  every unrecognized one, over the stand-in `Env`/`Atom`.

## 6. Residue & links

- **Deliberately unbuilt:**
  - The refinement **engine** (`Env`/`Atom` as the real predicate-conjunction +
    `entails`/`satisfies`/`is_empty`) — **[[E09-refinement]]**. E10's
    stand-in `Env`/`Atom` (decision #4) are swapped for E9's when it self-hosts;
    `narrow`'s body is unchanged by that swap.
  - The **comparison-spine unwinder** (`(<i i n)` term → `Guard`) — a small
    follow-on that pairs the surface `case`-scrutinee with `narrow`; needed only
    when the chirality checker consumes `narrow` live. Home: the E9/E10 value-form-
    seam wiring, downstream of both being self-hosted. **This is also where the
    operand-prior-type gate lives** (verified `refine.py:298`): OURS narrows a
    variable operand whose looked-up type is `VRefine I64` **or a bare `I64`**
    (starting from `TOP`), and does the de-Bruijn operand classification
    (`_operand`/`_unann`). The delivered `narrow` takes an already-normalized
    `Guard` and is agnostic to the operand's prior type, so the unwinder inherits
    this gate — recorded here so a later run does not mistake "already `VRefine`"
    for the whole story.
  - **Symbolic→constant collapse** — decision #2, DEFERRED to E9.
  - `g-eq` (mirroring OURS `=i`) — an additive third guard shape; not in the
    example's recognized set, add when a fixture demands it.
  - Retiring `refine.py:_narrow` and wiring `narrow` onto the live
    `narrow_hooks`/`check_hooks` seams — rides the whole checker self-host, not E10.
- **Follow-on:** furnishes the path-sensitivity half that makes E9's refinement
  fragment *usable* (a plain `I64` narrowed into a `(refine I64 …)` obligation);
  pairs with [[E09-refinement]] in the same `lib/refine.chiral`.
- **Related:** [[E10-occurrence-typing]] (rationale) · [[E09-refinement]]
  (the engine this feeds; decisions #2, #4 owner) · [[E26-alarms]]
  (errors-as-values on a failed-bound path) · [[E24-i64-arith]]/[[E25-byte-cells]]
  (the I64 floor the bounds live on).
