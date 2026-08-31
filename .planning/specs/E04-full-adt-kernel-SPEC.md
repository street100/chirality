---
element: E04
slug: full-adt-kernel
title: The full-ADT kernel — Sig-parameterized infer/check + the globals/data/case/literals arms (rung-1 keystone)
kind: SELF-HOST
example: examples/E04-full-adt-kernel.md
status: audited
updated: 2026-08-03
---

# E04 SPEC — the full-ADT kernel (rung-1 keystone, `RUNG1-CRITICAL-PATH.md` items 1+2)

> Contract for the trusted-core build that lifts the ported chirality kernel from the
> closed λ-core to the full ADT language, so it can check real programs. Written
> directly (the pack's --spec globs the original E4 example, not this orphan).
> **Trusted-core — every slice shows its diff explicitly and keeps the E3/E4
> differentials green.** The Core-unification is DECIDED (extend the kernel `Term`
> in place; example §6 / commit 011154d).

## 1. Deliverable

> **SPEC-AUDIT STATUS (2026-08-03):** slices **1–3 are IMPLEMENTED** (commits
> `dabc2be`/`e72dcb4`/`a067df8`; `Sig` + lookups, the `Term`/`Value` extensions,
> the eval/quote/conv arms, and the `Sig`-threaded global/prim/lit infer arms).
> `sig.chiral` was **absorbed into `kernel.chiral`** during the build (slice-3
> ⚠ layering note) — there is no `sig.chiral` file. The **remaining delta is
> slice 4** (the `con`/`tcon`/`case` typing arms) **plus its now-resolved
> representation lift**. Live baseline: **555 green**. The spec-audit surfaced
> three trusted-core decisions, all **RESOLVED by the author 2026-08-03** (§3
> rows #4–#6): **(#4)** lift `DataDecl` to carry kernel `Term` for param-kinds +
> field types and re-port E6/E7/E8 over `Term` — the designed Step-4 integration,
> proven necessary (else `(List 5)` diverges from kernel.py); **(#5)** add linear
> registries to `Sig` + port kernel.py's registry `is_linear`; **(#6)** wire E10
> `narrow` directly into the `case` arm. Slice 4 is now scoped as **two sub-
> slices** — see §4.

- **After this runs:** `lib/kernel.chiral`'s `Term`/`Value` carry the full-ADT
  forms and `infer`/`check` are `Sig`-parameterized with the six deferred arms —
  `t-global`, `t-prim`, `t-lit`, `t-con`, `t-tcon`, `t-case` — so a real def body
  (globals + constructors + `case` + literals) type-checks against a loaded `Sig`,
  differential to `kernel.py`. Plus `lib/sig.chiral`: the full `Sig`
  (globals + prims + datas) the judgment reads and the loader (item 3) writes.
- **Non-goals (residue §6):** the loader that BUILDS the `Sig` (item 3 / req #2 —
  install-* over this `Sig`); the full three-way `Core` unification (deferred — we
  bridge surface `Core` → the extended `Term` at install); native anything; effect
  rows in the arms (the row layer is built — sig-driver — and threads via the
  existing `allow_eff` seat, unchanged here).

## 2. Baseline (what already exists)

- **CONFORMANCE-MAP:** E4 "Bidirectional infer/check + universes" = CONFORMS/Built
  — but that is the **Python scaffold**. The **chirality port** (`lib/kernel.chiral`,
  E3/E4) is the **closed core only** (`Term` = var/type/pi/lam/app/let/ann; no
  Sig; verified). This SPEC extends the chirality port to match `kernel.py`'s reach.
- **Live code this composes with (do NOT respec):**
  - `lib/kernel.chiral` E3/E4 — `Term`/`Value`/`Clos`/`Neut`, `eval`/`quote`/`conv`,
    `infer`/`check`/`subtype`, `Ctx`, `TcR`/`CkR`. The core arms stay; they gain a
    threaded `Sig` and the new ctors gain arms.
  - `lib/data.chiral` (E6/E7) — `check-coverage` (:96), `_infer_ctor_params`
    (ctor field types), positivity. **kernel + data co-load clean (verified).**
    The `con`/`case` arms CALL these; they are not reimplemented.
  - E69 `SigV` + sig-driver `EffSig` — partial sig views (tys/defs; ports/bound/
    def_rows). The full `Sig` here is their superset; keep them as projections or
    fold them in (decision §3#3).
- **True delta:** (a) `lib/sig.chiral` (the full `Sig` + lookups); (b) the `Term`/
  `Value` ctor extensions in `kernel.chiral`; (c) the new `eval`/`quote`/`conv`
  arms for them; (d) the `Sig` param + six judgment arms; (e) a `Ty`↔`Term` bridge
  for the E6/E7 reuse (decision §3#2).

## 3. Decisions

| # | Question | Disposition | Rationale |
|---|----------|-------------|-----------|
| 1 | The `Core` unification. | **RESOLVED — extend the kernel `Term` in place; defer the full three-way unification** (example §6 / 011154d). | Low-risk, reversible; unblocks the build without refactoring surface/lower/closconv; matches `kernel.py`'s single-Term shape. The loader bridges surface `Core` → the extended `Term` at install (item 3). |
| 2 | How the E6/E7 data checks (over `data.chiral` `Ty`/`DataDecl`) plug into the `con`/`case` arms (over `Term`/`Value`). | **RESOLVED (author, 2026-08-03) — SUPERSEDED by #4's Term-unify: no bridge.** Once `DataDecl` fields ARE kernel `Term` (#4), the arm evals them directly: `eval-term (reverse targs) fty`. **The env is REVERSED targs** — kernel.py evals `Var i → env[len-1-i]` (newest-at-back) while chirality `nth env i` is newest-at-front, so a field `t-var ix` resolves to param `nparams-1-ix` only under reversed targs (verified in code). The `case` arm looks the scrutinee's tcon up in `Sig.datas` and reuses `check-coverage`/`bare-param` (re-ported over `Term`). | A skeleton `Ty→Term` bridge would be lossy — `ty-pi` drops the quantity `conv` checks on → arrow-field divergence. The Term-unify removes the bridge. |
| 4 | **param-kinds — NEEDED, proven.** `_check_tcon` checks each param arg against the decl's param KIND; `check_data` (data.py:466) runs `expect_universe` on every kind. The live `data.chiral` `DataDecl` carries only `nparams : I64` → chirality would accept `(List 5)` that kernel.py rejects = **Stage1≠Stage2 divergence**. Also: E7/E8 walk the skeleton `Ty`, itself a *reduction* of the oracle's Term walk (`data.py._positivity` walks Terms). | **RESOLVED (author, 2026-08-03) — scope A: the designed Step-4 integration.** Lift `DataDecl` to carry kernel `Term` for param-kinds AND field types (data.chiral:9–12 named the kernel Term "the Step-4 integration target"). Re-port E6 `bare-param` solver + E7 positivity `walk` + E8 linear walk over `Term` (moves them TOWARD `data.py`'s oracle). Ripple bounded: 3 `data-decl` sites + trivial `find-decl`; `ty-cmp`/`totality`/`surface` untouched. Retires the skeleton `Ty` as the decl representation. | The skeleton was scaffolding for exactly this slice; the faithful fix is the integration, not a local patch. One representation, fully oracle-faithful. |
| 5 | **linearity registry.** The `con` arm's linear-field check (a `w` field may not hold a port) needs `is_linear`; kernel.py `is_linear` (`:208`) reads `sig.atom_types`/`sig.linear_data` registries the chirality `Sig` does NOT carry. | **RESOLVED (author, 2026-08-03) — add the linear registries to `Sig`.** Extend `Sig` with atom/tcon linearity (`atom_types`/`linear_data` analogues) and port kernel.py's registry `is_linear` faithfully; the loader (item 3) populates them at `check_data`. E8's structural `linear-ty` stays the recursive hook it already is (now over `Term`, per #4). | Faithful to kernel.py; the registry is the right `Sig` shape for the full-ADT kernel, not a bridge. |
| 6 | **narrow-hooks.** `_check_case` uses E10 `narrow_hooks` (per-branch path-sensitivity); the chirality `Sig` is a closed sum with no hook registry and E10 `narrow` is not wired to the kernel `Ctx`. | **RESOLVED (author, 2026-08-03) — wire E10 `narrow` directly into the `case` arm now.** Call `narrow` on the kernel `Ctx` per branch (no hook indirection), coupling the case arm to `refine.chiral` and wiring the `Ctx`↔`narrow` representation. Faithful path-sensitivity in slice 4, not deferred. | The author chose the full path-sensitive case arm over deferral. |
| 7 | **Term-layering cycle** (surfaced attempting 4a). `kernel` imports `data` (for `DataDecl`); making `DataDecl`'s fields kernel `Term` (#4) means `data` needs `Term`, which `kernel` owns → **import cycle**. `terms.chiral` (E13) can't absorb it — its `Term` is the closed core (no data forms), differential-clean vs `terms.py`. | **RESOLVED (decide-and-check, 2026-08-03) — extract the shared syntax to a leaf.** New leaf `lib/syntax.chiral` (imports only prelude+qtt) defines the full `Term` + `KArm` + `DataDecl`/`Ctor`/`Field`. Both `data.chiral` and `kernel.chiral` import it; `kernel` drops its `Term`/`KArm`/decl defs (keeps `Value`/`Clos`/`Neut`/`Sig`/eval/infer/arms). Same relocation-to-break-a-cycle move that homed `Sig` in kernel (slice-3 ⚠). No new representation — one `Term`, now leaf-homed. | The cycle is structural, not incidental; a leaf is the standard break. `terms.chiral` stays the E13 closed-core artifact (untouched). |
| 3 | Does `Sig` subsume `SigV`/`EffSig`? | **RESOLVED — `Sig` is the superset; `SigV`/`EffSig` become projections.** | `Sig` = globals(type+body) + prims + datas; `SigV` = its (tys,defs) projection, `EffSig` = its (ports,bound,def_rows) projection. Don't fork a fourth carrier; provide `sig->sigv`/`sig->effsig` if a consumer needs the narrow view. |

## 4. Change plan (ordered, commit-sized — trusted-core, diffs shown)

### Slice 1 — `lib/sig.chiral` + the E6/E7 bridge spike (decision #2)
- The `Sig` ADT (globals: `(List (Pair Str (Pair Term Term)))`, prims:
  `(List (Pair Str Term))`, datas: `(List DataDecl)`) + `sig-global-ty`/
  `sig-global-body`/`sig-prim-ty`/`sig-data` lookups. Imports kernel + data.
- **Spike decision #2:** confirm `check-coverage`/`_infer_ctor_params` are
  callable with a `Sig.datas` entry and that ctor field `Ty` → `Value` converts
  totally. Differential: the lookups vs a bridged real `kernel.py` sig.
- ~M. NON-trusted (new file).

### Slice 2 — extend `Term`/`Value` + `eval`/`quote`/`conv` (TRUSTED)
- Add `t-global`/`t-prim`/`t-lit`/`t-con`/`t-tcon`/`t-case` to `Term`; `v-con`/
  `v-tcon` + global/prim neutral heads to `Value`. Add the matching `eval`/
  `quote`/`conv` arms (globals/prims → neutral heads; con/tcon → structural;
  case → eval scrutinee then select the arm; lit → `v-lit`). **Show the diff.**
- Gate: the **E3 differential stays byte-identical** on the core corpus (the new
  ctors are additive; core terms unchanged), plus new eval/quote/conv cases vs
  `kernel.py` `eval_term`/`quote`.
- ~M–L. Trusted-core.

### Slice 3 — `Sig` param + the lookup arms (`t-global`/`t-prim`/`t-lit`) (TRUSTED)
- **⚠ LAYERING (found during the build):** `Sig` must live IN `kernel.chiral`, not
  in `sig.chiral` (slice 1). `infer` needs `Sig`; `Sig` holds `Term`; if `sig.chiral`
  defined it, `kernel` importing `sig` while `sig` imports `kernel` (for `Term`)
  would **cycle**. Fix (clean — verified `data.chiral` imports only prelude, so no
  cycle): **`kernel.chiral` imports `data`** (for `DataDecl`) and **defines `Sig` +
  its lookups**, absorbing slice-1's `sig.chiral` (relocate the `Sig` decl +
  `sig-global-ty`/`-body`/`sig-prim-ty`/`sig-data`; point `test_sig_chirality` at
  `kernel`). slice-1's sig.chiral was a reasonable first cut but the cycle forces
  the move.
- Thread `Sig` through the 9 judgment fns (`infer`, `check`, `subsume`,
  `infer-pi`/`-pi2`/`-app`/`-app2`/`-ann`/`-ann2`; `subtype` stays value-only).
  Add the three lookup arms (global/prim → `Sig` lookup → eval its type; lit →
  its I64/Str type). Core arms unchanged, just pass `Sig` down. Optionally add the
  eager global-unfold in `eval` (slice-2 residue) — but the lookup arms don't need
  it (only conv-completeness for global-typed conversions does; can stay deferred).
- Gate: **E4 differential green** (core cases, now Sig-threaded with an empty
  `Sig`) — the byte guardrail catches any threading slip; new arms vs `kernel.py`
  `infer` over globals/prims/lits. Update `test_bidir_selfhost`'s
  `call("infer", ctx, t)` → `call("infer", sig, ctx, t)`.
- ~M–L. Trusted-core; broad-but-mechanical + guardrailed.

### Slice 4a — the representation lift (TRUSTED, decisions #4/#5/#6/#7) — do FIRST
The typing arms need faithful representations; build them before the arms so the
differential is against the real thing, not a lossy stand-in.
- **Extract shared syntax to a leaf `lib/syntax.chiral`** (decision #7, do this
  step 0). Move the full `Term` + `KArm` + `DataDecl`/`Ctor`/`Field` out of
  `kernel.chiral`/`data.chiral` into a prelude+qtt-only leaf both import — breaks the
  cycle #4 triggers. `kernel.chiral` keeps `Value`/`Clos`/`Neut`/`Sig`/eval/infer.
  **Show the trusted-core diff** (this moves the E3/E4 `Term`; the E3/E4
  differentials are the guardrail — they must stay byte-green after the move).
- **`DataDecl` → kernel `Term`** (decision #4). `Field` fty `Ty → Term`; field `q`
  stays `I64` (matches kernel.py's int q); add param kinds:
  `(data-decl (dname Str) (params (List Term)) (ctors (List Ctor)))` — `params`
  carries each param's kind Term (kernel.py `check_data` `expect_universe`s them),
  and `nparams = (llen params)`. Update the 3 `data-decl` match sites (data.chiral:99,
  :292; kernel.chiral:83 `find-decl`) + `bare-param`/`solve-go` (E6, now over `Term`
  `t-var`) + E7 positivity `walk`/`mentions?`/`hit?` (over `Term`: `t-tcon`/`t-var`/
  `t-pi`/`t-app`) + E8 linear walk (over `Term`, or via the `Sig` registry of #5).
  **Each keeps its differential** — re-point the E6/E7/E8 test corpora from `Ty`
  tuples to `Term` tuples; the ports move TOWARD `data.py` (which walks Terms).
  **Show the trusted-core diff** for data.chiral + kernel.chiral.
- **`Sig` linear registries** (decision #5): extend `Sig` with atom/tcon linearity
  and port kernel.py `is_linear` (`:208`) — `VPrimTy` → atom flag, `VTCon` →
  `linear_data` membership. (The loader populates them at `check_data`; here the
  differential builds a `Sig` with a known linear atom/tcon.)
- Gate: **E6/E7/E8 differentials stay green** over the re-pointed `Term` corpora;
  the E3/E4 core differentials untouched. ~L. Trusted-core.

### Slice 4b — the `con`/`tcon`/`case` typing arms (TRUSTED) — THE BIG ONE
- **The full data type-checker: a port of `data.py`'s `_check_tcon` (:131) /
  `_check_con` (:193) / `_check_case` (:222)** + `_ctor_field_types` (:148) /
  `_infer_ctor_params` (:166) / `_ensure_escapes` (:279), now over the lifted
  `Term`-based `DataDecl` (4a). Folded into the closed-sum `infer`/`check`
  dispatch (not Python's `ext_check` dict): each handler takes a `(Maybe Value)`
  expected → `TcR`; `check` calls it with `(some want)`, `infer` with `none`.
  No `allow_eff` (the chirality kernel's row layer is the existing E12 seam, §1).
  - **`check-tcon`:** look up decl; arity vs `(llen params)`; check each param arg
    against its **param kind** (`check sig ctx arg (eval-term env pkind)`, usage
    erased), eval into `env`; result `VType 0`; if expected, `subtype`.
  - **`check-con`:** expected `VTCon` OR infer params (reuse `bare-param` over
    `Term`, solving slot p from the arg's inferred `Value`); `ctor-field-types`
    evals field `Term`s under `reverse targs` (decision #2 env) AND judges the
    **linear-field** rule via #5's `is_linear`; check each arg against its field
    type; accumulate QTT usage (`uadd`/`uscale q`).
  - **`check-case`:** infer scrutinee → `VTCon`; per branch: coverage
    (dup/unknown/missing via `check-coverage`), `ctor-field-types` for the binders,
    **E10 `narrow` on the kernel `Ctx`** (decision #6, called directly per branch),
    bind fields with their qtys, infer/check the body, check each field binder's
    usage with `qfits`, `ujoin` the branch usages, `ensure-escapes` (local
    `uses-below`/`shift-close` over kernel `Term`), exhaustiveness/default.
- Gate: differential vs `kernel.py` over a corpus — ctor app (±arity, param-inferred
  vs annotated), exhaustive/missing/dup/nested case, a field-binder usage violation,
  a **kind-mismatch param** (`(List 5)` — now representable and REJECTED, matching
  kernel.py), a linear-field violation (via #5).
- ~L (the largest slice). Trusted-core; the payoff: real data+case programs check,
  faithfully, no reductions.

## 5. Conformance gate

- **Golden:** `infer`/`check` reproduce `kernel.py`'s accept/reject + inferred
  type over a corpus exercising every new arm (global, prim, I64/Str lit, ctor
  ±arity, exhaustive/non-exhaustive/nested case), over a REAL loaded `Sig`
  (bridged from `kernel.py`'s sig, as E69's tests bridge `SigV`).
- **Tests:** slices 2–4 land in `test_kernel_fulladt_chirality.py` (the slice-2/3
  differential file, extended); `test_sig_chirality.py` covers the `Sig` lookups.
  Keep `test_nbe_selfhost.py` / `test_bidir_selfhost.py` byte-green (the
  additive-ctor invariant is the load-bearing check).
- **Green line:** **555** (live; slices 1–3 landed) → +~8–12; **the E3/E4
  differentials stay green**.
- **Differential floor (post-resolution):** with decisions #4/#5/#6 resolved
  FAITHFULLY, the corpus has NO reduction residue. It covers: ctor app (±arity,
  annotated + bare-param-inferred), a **kind-mismatch param** (`(List 5)` REJECTED
  per #4), exhaustive/missing/dup/nested `case`, a field-binder usage violation, a
  linear-field violation (#5 registry), and a **refinement-narrowed branch** (#6)
  where the guard tightens a binder's type. Each accept/reject + inferred type
  matches `kernel.py`.
- Slice 4 lands in **two commits** (4a representation lift, 4b typing arms), each
  gated + green before the next (commit cadence).
- **Done when:** a real def body (globals + data + case + literals) type-checks in
  chirality matching `kernel.py` — the chirality kernel can check real programs, unblocking
  the loader (item 3) and req #2's install-validation.

## 6. Residue & links

- **Deliberately unbuilt:** the loader building the `Sig` (item 3 / req #2); the
  full `Core` unification (deferred dedup, `E69-sig-mutation-PLAN.md` §5); native
  emission (item 4 of the critical path); effect-row arms (built, threaded via the
  existing seat).
- **Follow-on:** unblocks item 3 (loader) → the fixpoint (item 5).
- **Related:** [[RUNG1-CRITICAL-PATH]] (items 1+2), [[E04-full-adt-kernel]] (the
  rationale), [[E3]] (the core this extends), [[E6]] (the data checks reused),
  [[E69-sig-mutation]] (the install that writes this `Sig`).
