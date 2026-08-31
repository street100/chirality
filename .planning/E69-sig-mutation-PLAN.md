# E69 sig-mutation driver — scoping plan (req #2 of the E69/E70 completion)

> Durable scope for the LAST piece of the E69 port: the kernel-re-entry that
> INSTALLS the closure-conversion outputs into the signature. Written 2026-08-03.
> A fresh session executes from here. Companion: `.planning/HANDOFF.md` (session
> status), `scaffold/chirality/closconv.py` (the oracle), `lib/closconv.chiral` (the
> ported pure pipeline this consumes).

## 0. Corrected status — NOT blocked by the dedup debt

Earlier this session I reported #2 "blocked" after `closconv + data` failed to
co-load (`llen` redefined). **Re-analysis: #2 does not need to import
`closconv`.** It needs closconv's *outputs* (the synthesized `$clo` data + `$apply`
defs + rewritten bodies), which the ported pure pipeline (`lib/closconv.chiral`:
`synth`/`rewrite`/`arm-body`, all landed) already produces. Following the
take-as-data pattern used all session (sig-driver took ports/bound/calls as data),
the install driver **imports only `data` + `kernel` (verified: they co-load
cleanly — zero name overlap)** and takes the synth outputs + the `SigV` as bridged
data. So #2 is unblockable now; the dedup debt (§5) is a separate cleanup.

## 1. Deliverable

- **What:** `lib/sig-install.chiral` — the chirality image of `closconv.py`'s
  signature mutation (`closure_convert`'s tail, lines 470/479/642/818). Given the
  E69 pure pipeline's outputs, produce an **updated `SigV`** with the closure
  ctors + `$apply` dispatchers installed and the user bodies replaced, **each
  validated through the ported kernel judgments** (not trusted).
- **The three install ops** (mirroring the oracle's kernel calls):
  - `install-data` — a `$clo` closure-constructor data type → validate via E6
    coverage + E7 positivity (`data.chiral`), add to `SigV`. (oracle:
    `D.check_data`, closconv.py:470)
  - `install-def` — an `$apply` dispatcher (ty + body) → validate via E4
    `check`/`infer` (`kernel.chiral`), add to `SigV`. (oracle: `K.check_def`, :479)
  - `install-rewrite` — replace a user def's body with the rewritten (closure-
    converted) one → re-declare ty + finish body, re-validated. (oracle:
    `K.declare_def`+`finish_def`, :642/:818)
- **Non-goals:** the mutable CPython `Sig` (the chirality side is immutable — produce
  a new `SigV`); the ordering shuffle (`front`/`back`, closconv.py:853-857) unless
  a consumer needs it; native anything.

## 2. Approach (take-as-data, imports data+kernel only)

- **Imports:** `data` (check-data / positivity / coverage), `kernel` (infer /
  check). These co-load (verified). Do **NOT** import `closconv` (pulls `surface`,
  and `closconv llen` vs `data llen` clashes — §5).
- **Inputs as data:** the `SigV` (E69's read-only view: `tys` + `defs` as `Core`
  assoc-lists) + the synth outputs (the `$clo` data decls, the `$apply` (ty,body)
  pairs, the (name, new-ty, new-body) rewrites) — all as `Core`/assoc values,
  bridged in the test from a real `closure_convert(sig)` run (the oracle), exactly
  as E69 slice-3's test bridges a real sig into `SigV`.
- **Output:** an updated `SigV`. "Install" = validate + cons onto `tys`/`defs`.
  Immutable: `install-* : (-> SigV <decl> (Result SigV))` (errors-as-values —
  a failed judgment is `Left`, not a raise).
- **⚠ VERIFY FIRST (the one open risk):** the ported `data.chiral` / `kernel.chiral`
  expose the JUDGMENTS (positivity, coverage, infer, check) but may not expose a
  sig-EXTENDING entry (the scaffold's `check_data`/`check_def` mutate the kernel
  `Sig` in place). Confirm whether adding a decl to `SigV` + re-running the
  judgment against the extended `SigV` is expressible with what E4/E6/E7 ported,
  or whether a thin "extend SigV then judge" wrapper is the real first slice.
  (Grep `data.chiral` for the positivity/coverage entry points and `kernel.chiral`
  for `infer`/`check` signatures; do this before writing install-data.)

## 3. Change plan (commit-sized)

1. **install-data** — `SigV` + a `$clo` data decl → run positivity+coverage,
   cons the type into `SigV.tys`. Differential vs `D.check_data` (accept the E69
   `$clo` families; reject a synthetic non-positive one).
2. **install-def** — `SigV` + `($apply` name, ty, body`)` → `check` body against
   ty, cons `(name,ty)`/`(name,body)` into `SigV`. Differential vs `K.check_def`
   over the E69 `$apply` dispatchers.
3. **install-rewrite** — replace a user body → same as install-def but replacing
   an existing entry. Differential vs the `declare_def`+`finish_def` pair.
4. **install-all** — fold the three over a full `closure_convert` output → an
   updated `SigV` whose `defs`/`tys` match (as sets) the oracle sig's
   post-`closure_convert` `global_defs`/`global_types` (minus representation).

## 4. Conformance gate

- **Oracle:** `closconv.closure_convert(sig)` mutates a real `sig`; compare the
  resulting `global_defs`/`global_types`/data decls (as canonical sets) against
  the `SigV` `install-all` produces from the same pre-conversion inputs.
- **Tests (`scaffold/tests/test_sig_install_chirality.py`, NEW):** each install op vs
  its kernel-call oracle over the E69 corpus (the same defunctionalization corpus
  slice-4's `collect` test used — partial-app, function-value arg, escaping
  `(the .. (lam ..))`, HO Var-head, unsaturated poisoning); a negative (a
  non-positive `$clo` → install-data rejects); and `install-all` reproducing the
  post-conversion sig.
- **Green line:** 537 → ~+5; the pure suite stays green.
- **Done when:** installing the E69 outputs reproduces `closure_convert`'s sig
  mutation, validated (a bad decl is rejected, not silently added) — the E69 port
  is then complete (pure pipeline + sig install).

## 5. The dedup debt — REAL, but a SEPARATE cleanup (not a #2 blocker)

chirality has **no namespacing**; modules define their own helper globals, so
co-loading two that overlap fails ("global X redefined"). 48 names are defined in
>1 lib file (full inventory below). This is friction at composition points, not a
correctness bug — and #2 routes around it (§0). Categories:

- **The tal-IR duplication (the biggest structural item):** `lower.chiral`,
  `tal-check.chiral`, `tal-eval.chiral` each redefine the tal IR — `Instr`, `Block`,
  `Branch`, `TFn`, `TalTy`, `Prog`, `CEnv`, `DCtor`, `DData`, `TalSig`, + the
  `ce-*`/`find-*`/`sig-assoc` accessors. **Unify into one `tal-ir` module all
  three import.** This is what blocked composing `compile-fn` (lower) with
  `row-check` (eff-lower→tal-check) in ONE driver (the E70 emission residue). ~M–L,
  touches three tested modules (each has a differential to keep green).
- **Generic list/order helpers to hoist to a shared leaf:** `llen`, `snoc`, `nth`,
  `drop-last`, `fresh` (list), `Ord`, `cmp-i64`, `cmp-bytes`, `str-cmp` (order).
  Defined independently across closconv/data/kernel/lower/collections/ty-cmp/
  row-infer. Hoist into `prelude` (or a `listx`/`ord` leaf) + import. ~S–M each.
- **Same-concept re-declared (unify to the owning module):** `Term` (8 files —
  but check which are the shared kernel ADT vs coincidental), `Value`
  (interp/kernel), `Core` (lower/surface), `Verdict`, `CkR`, `CovR`.
- **Coincidental same names (LEAVE — genuinely different):** `PR` (json vs
  surface), `resolve` (asm-reloc vs surface), `walk` (data vs totality), `code`/
  `u8`/`esc-char` (json vs sexp), `Step` (fsm vs interp), `arm-body` (closconv vs
  interp). Do NOT force-merge these.

**Sequencing:** the dedup is NOT required for #2. Do #2 first (§1–§4). Then, if
the single-integrated-effectful-`lower-all` driver (E70 emission residue) or
future composition wants it, pay the tal-IR unification, then the helper leaf.
Each dedup step re-runs the touched modules' differentials.

### Full duplicate inventory (name : files)
```
data Term    : interp, kernel, lower, pretty, tal-check, tal-eval, terms, totality
data TFn     : lower, tal-check, tal-eval, tal-ir
data Verdict : kernel-core, reflect-floor, tal-spec, totality
data Block/Branch/Instr/TalTy : lower, tal-check, tal-eval
data Ord     : collections, row-infer, ty-cmp
def  llen    : closconv, data, lower
data Bound   : refine, totality
data CArm/Core/LBind : lower, surface
data CEnv/DCtor/DData/TalSig + ce-datas/ce-fns/ce-prims/find-ctor/find-data/sig-assoc : lower, tal-check
data CkR     : kernel, tal-check      data CovR : data, tal-check
data PR      : json, surface          data Prog : tal-check, tal-eval
data Step    : fsm, interp            data Value: interp, kernel
def  Cert/recheck : kernel-core, reflect-floor
def  arm-body: closconv, interp       def  cenv-get : emit-core, optimize
def  cmp-bytes/cmp-i64/str-cmp : row-infer, ty-cmp
def  code/esc-char/u8 : json, sexp    def  drop-last/fresh/snoc : kernel, lower
def  eval-term : kernel, tal-eval     def  nth : kernel, totality
def  resolve : asm-reloc, surface     def  strip-lams : lower, totality
def  walk : data, totality            def  zeros : asm-reloc, tal-eval
```
