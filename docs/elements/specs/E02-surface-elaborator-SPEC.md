---
element: E02
slug: surface-elaborator
title: Surface elaborator (name→deBruijn, arrow/lam/case/do desugar, profile/target verify)
kind: SELF-HOST
example: examples/E02-surface-elaborator.md
status: audited
updated: 2026-07-31
---

# E02 SPEC — Surface elaborator (name→deBruijn, arrow/lam/case/do desugar, profile/target verify)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** a new `scaffold/lib/surface.chiral` containing the
  **`elab`/`resolve` core** — a total, pure, errors-as-values chirality function that
  lowers a parsed `Surf` node to a name-erased `Core` (kernel) term: resolves
  names to de Bruijn indices, dispatches every surface term form
  (`lit/var/type/->/=>/lam/let/case/do/cond/the/refine/apply`), and desugars
  `cond`/`the`/`refine`/multi-param-`lam`/`do` at elaboration time. Validated
  **differentially** against `surface.py`'s `elab` (chirality `Core` adapter-compared
  to the Python core term), running on the RT interpreter.
- **Non-goals (deferred *within* E2 — see decision #6, each with a home):**
  - The **profile/target/verify** machinery (`top_profile`/`top_target`/
    `verify_profiles`/`verify_targets`/`_target_rows`) — E2's second slice; the
    `verify-target` sketch in the example §5 is illustrative, not this slice.
  - **Data-declaration elaboration** (`top_data`/`_top_data_body`) and the
    **effect-row inference** (`_infer_row`/`_elab_stamped`) — the latter is
    E39-coupled (row shape), so not portable ahead of E39.
  - The **import loader** (`load_file`/`load_str`) — a separate effectful (`=>`)
    driver (decision #3), gated on the sys-face IO lane (E51).
  - The **CLI/entrypoint** (map row 3) — trivial plumbing, its own slice.
  - **Wiring `surface.chiral` in** as *the* elaborator / retiring `surface.py` —
    downstream of the kernel also being self-hosted + a bootstrap path
    (decision #4).

## 2. Baseline (what already exists)

- **Conformance-map verdicts:** three CONFORMS rows tagged E2 —
  *Surface elaborator* (M; "Fully built; elab/resolve, arrow/lam/let/case/do/
  cond/the/refine"), *Profiles + verify* (M), *CLI/entrypoint* (S). CONFORMS =
  the frame is settled; this is a faithful transcription of a complete artifact,
  and only concrete syntax (E49) is owed above it. This SPEC ports **row 1's
  core** (elab/resolve); rows 2–3 are the deferred slices above.
- **Live code this composes with (do NOT respec):**
  - `scaffold/chirality/surface.py` (727 lines — the golden oracle). Load-bearing
    bodies: `elab` (:384, the ~13-way form dispatch), `resolve` (:443, deBruijn
    search **then** 6-way signature fallback), `apply` (:460), `arrow` (:481),
    `lam` (:519), `let` (:532), `case` (:556), `_cond_to_case` (:581),
    `do_` (:603). *(The example §2's "583 lines" predates growth; 727 is live.)*
  - `scaffold/lib/prelude.chiral` — `List`/`Pair`/`Maybe`/`Bool`/`Unit`, `str-eq`,
    I64 ops. **No `PR`** — the elaborator declares its own polymorphic one
    (example §5, audited).
  - `scaffold/lib/json.chiral` / `sexp.chiral` (E1) — the established
    chirality-recursive-descent + result-sum idiom; E1's reader produces the `Surf`
    this consumes.
  - `terms.py` — the kernel term representation the chirality `Core` must mirror
    (the former set below); read at impl to pin exact shapes.
- **True delta:** one new chirality file porting the elab/resolve core. The
  recursion/result-sum idiom is established; E2's *new* content is (a) the
  full-fidelity `Surf`/`Core` former sets, (b) `resolve`'s six-way name
  resolution over a threaded signature-env, (c) the elab-time desugarings.

## 3. Decisions

The three example §6 questions + three seams the `surface.py` outline surfaced.
All decidable from the oracle + the E1 precedent; none author-tier. `status: draft`.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Desugaring inside `elab` or a pre-pass over `Surf`? | **RESOLVED — inside `elab`** | `surface.py` desugars at elab-time: `cond` → `elab(_cond_to_case(...))` (:417, "the kernel only ever sees `case`"), `the`→`Ann`, `refine`→`Refine`, `lam/let/case/do` are elab methods (:403–411). No separate `Surf`-rewriting pass. Match it. |
| 2 | QTT quantity threaded in `ctx`, or deferred to the kernel? | **RESOLVED — carried onto `Core` binders; usage-checked by the kernel** | The elaborator emits `q` on Pi/Lam binders; QTT usage-vector linearity is ENFORCED in `kernel.py` at binder exit + case-join (status-ledger; map E5), **not** in `surface.py`. `ctx` stays names-only — `resolve` iterates `scope[i] == name` (surface.py:445), a bare name stack. |
| 3 | Is `import` a separate `=>` phase; where does load memoization live? | **RESOLVED — separate effectful loader, deferred** | `load_file`/`load_str` (surface.py:59,77) are distinct from the pure `elab`; loading is an effectful (`=>`) driver needing file IO → the E51 sys-face lane. Once-only memoization lives in the loader's dedup. Out of this pure-`elab` slice. |
| 4 | *(seam)* How does the chirality `Core` reach the (Python) kernel? | **RESOLVED (E1 analogy) — differential validation, not wire-in** | Exactly as E1's reader vs `sexp.py`: build `surface.chiral`, run it on the RT interp, **adapter-compare its chirality `Core` to `surface.py`'s Python core** for the same `Surf`. Making `surface.chiral` *the* elaborator (chirality Core → chirality kernel, or a Core bridge) needs the kernel also self-hosted (**E3/E4/E13**) + a bootstrap path → **DEFERRED** there. |
| 5 | *(seam)* Does `resolve` need more than the local name stack? | **RESOLVED — thread a signature-env** | `resolve` (surface.py:443–458) searches local `scope`, **then** falls through to `CORE_ATOMS`/`atom_types`/`ctor_home`/`data`/`global_types`/`prim_types`. The chirality `elab`/`resolve` thread a `Sig`-env (those global tables) beyond `(List Str)`; the example's `ctx-find` modeled only the local half. |
| 6 | *(scope)* How much of the 727-line elaborator does this SPEC cover? | **RESOLVED — the `elab`/`resolve` core; the rest deferred within E2** | Staging a large port by *separable concern* is engineering, not an author call. Core slice = name→deBruijn + full form desugaring → `Core` (map row 1's heart). Deferred + named in §1 non-goals: verify/profiles (row 2, [[banks/profile]] shard G), data-decl elab, row inference (E39-coupled), import loader (E51), CLI (row 3). |

## 4. Change plan (ordered, commit-sized)

### Step 1 — data: `Surf`, `Core` (full former set), `PR`, `Sig`-env
- **Target:** `scaffold/lib/surface.chiral` (new — RT-run chirality source lives in
  `lib/`, matching E1's `lib/sexp.chiral`; `chirality/` is Python only. Relocating to
  `chirality/surface.chiral` at wire-in, if wanted, rides decision #4) — `(import "prelude")`;
  polymorphic `(data PR ((X (type 0))) …)` (example §5, audited); `data Surf`
  with the full surface form set (`s-lit`/`s-var`/`s-type`/`s-arr`/`s-lam`/
  `s-let`/`s-case`/`s-do`/`s-cond`/`s-the`/`s-refine`/`s-app`); `data Core`
  mirroring `terms.py`'s formers (`c-lit`/`c-var`/`c-type`/`c-pi`/`c-lam`/
  `c-ann`/`c-refine`/`c-con`/`c-tcon`/`c-primty`/`c-global`/`c-prim`/`c-case`);
  `data Arm`/`CArm` **pinned against surface.py `case` (:556) + `terms.py`** (the
  example's shapes are provisional); a `Sig`-env carrying the six resolution
  tables (decision #5).
- **Change:** promote the example §5 decls to the full-fidelity former sets read
  off `surface.py:384–458` + `terms.py`.
- **Size:** ~M

### Step 2 — `resolve` (name → deBruijn + signature fallback)
- **Target:** `surface.chiral` — `resolve (-> Sig (List Str) Str (PR Core))`
- **Change:** the example's `ctx-find` local search (→ `c-var`, index =
  depth-from-top, surface.py:445–447) **then** the five-way `Sig` fallback →
  `c-primty`/`c-con`/`c-tcon`/`c-global`/`c-prim`, unknown → `p-err`. Six
  resolution outcomes total (`c-var` + those five). Structural, total.
- **Size:** ~M

### Step 3 — `elab` dispatch (the ~13-way spine)
- **Target:** `surface.chiral` — `elab (-> Sig (List Str) Surf (PR Core))` + the
  per-form helpers (`elab-arr`/`elab-app`/`elab-case`/`elab-do`/`elab-the`/
  `elab-lam`, all declared in the example §5)
- **Change:** the coverage-checked `case` over `Surf` mirroring surface.py:384–441
  — each arm produces the matching `Core` former; errors thread as `p-err`. Pure
  `->`, total (structural on `Surf`).
- **Size:** ~L

### Step 4 — elab-time desugarings
- **Target:** `surface.chiral` — `cond-to-case` (surface.py:581), multi-param
  `lam`→nested `c-lam` (example §5 `elab-lam`, already correct), `do`→linear
  let-seq (surface.py:603), `arrow`→`c-pi` with the `eff` bit (surface.py:481)
- **Change:** port each desugar helper; `cond` desugars to `case` then re-elabs
  (decision #1).
- **Size:** ~M

### Step 5 — differential test
- **Target:** `scaffold/tests/test_surface.py` (new)
- **Change:** `test_json.py`-shape harness (`Elab().load_file(surface.chiral)`,
  `RT`, curried `apply1`); a chirality-`Core`→Python-core adapter; a form corpus
  covering every `elab` dispatch case + nested binders (deBruijn depth) + the
  desugarings; assert `surface.chiral`'s `elab` output adapter-equals
  `surface.py`'s `elab` for the same `Surf`, and `p-err` on the reject inputs
  (`unknown name`, `empty ()`, bad `the`/`refine`).
- **Size:** ~M

## 5. Conformance gate

- **Golden behavior:** for every surface form in the corpus,
  `surface.chiral::elab(sig, scope, surf)` yields a `Core` term adapter-equal to
  `surface.py.elab(form, scope)` — **identical de Bruijn indices**, identical
  desugaring of `lam`/`let`/`case`/`cond`/`do`, the arrow's `eff` bit set iff the
  source used `=>`, and the same six-way name resolution — returning `p-err`
  where `surface.py` raises `SurfaceError` (`unknown name`, `empty ()`, malformed
  `type`/`the`/`refine`). **Scope caveat:** the corpus exercises the `elab`/
  `resolve` core only; profile/target/data-decl/row-inference forms are the
  deferred slices (§1), not in this corpus.
- **Floors compared:** the **chirality RT interpreter** running `surface.chiral` vs the
  **Python `surface.py` oracle** (lib-level chirality-vs-golden, the `test_json.py`
  shape — not native/tal).
- **Green line:** 344 → ≥ 344 + k (`test_surface.py`); full suite green,
  `surface.py` unchanged, ledger-lint clean.
- **Done when:** `test_surface.py` passes — the chirality elaborator lowers the corpus
  to the same core terms as `surface.py`, with rejects surfacing as `p-err`.

## 6. Residue & links

- **Deliberately unbuilt (each homed):**
  - Profile/target/verify (`top_profile`/`verify_*`/`_target_rows`) — E2 slice 2;
    [[banks/profile]] shard G is its refraction.
  - Data-decl elaboration (`top_data`) — E2 slice; the kernel's `check_data` (E6)
    is the judgment it feeds.
  - Effect-row inference (`_infer_row`/`_elab_stamped`) — **E39-coupled** (needs
    the typed row shape); not portable ahead of E39.
  - Import loader (`load_file`/`load_str`) — effectful `=>` driver, **E51** sys-face
    lane (decision #3).
  - CLI/entrypoint (map row 3) — trivial plumbing, own slice.
  - Provisional `Arm`/`CArm`/`Env` shapes — pinned at impl against
    `surface.py:556` + `terms.py` (decision #5 / Step 1).
  - Wiring-in / retiring `surface.py` — downstream of the kernel self-host
    (**E3/E4/E13**) + a bootstrap path (decision #4).
- **Follow-on:** feeds the kernel/E-checker (**E3/E4**, which own the type +
  coverage judgment on the `Core` this emits); is superseded in concrete syntax by
  **E49**; its `Surf` input is produced by **E1**.
- **Related:** [[E02-surface-elaborator]] (rationale), [[E01-sexp-reader]]
  (produces `Surf`), [[E09-refinement-engine]] (decides `(the …)`/`refine`
  predicates), [[E26-alarms]] (the `p-err` position surfaces as a source alarm),
  [[banks/profile]] (the deferred verify slice).
