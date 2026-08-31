# Determinism debts — the Stage1==Stage2 fixpoint ledger

**Purpose.** The self-host fixpoint is convergence-bound and terminal: the checker
compiled by Python-hosted chirality (Stage1) must be **byte-identical** to the checker
compiled by itself (Stage2). It converges cleanly ONLY if every place the
checker/compiler's *output* (emitted bytes, or an accept/reject verdict) depends on
CPython-specific behavior has been pinned to a canonical form first. This document
is the debt ledger the port pays down before **Lane 5** (native self-emission); it
is also the concrete substrate for **E53** (diverse double-compilation) — DDC can
only certify the climb once these debts are zero, because a residual CPython
canonicalizer would make Stage1 and Stage2 diverge for reasons unrelated to a
trusting-trust attack and mask the signal DDC is looking for. It couples tightly to
**E27** (dict/set → chirality ordered maps): most structural debts below are latent
today *only because CPython's `dict` preserves insertion order* — they surface the
instant the port swaps in a hash map.

Every row is grounded in a `file:line` under `scaffold/chirality/` that was read and
confirmed. "Reaches output?" distinguishes true fixpoint debts (emitted bytes or a
verdict) from display/error-path noise (catalogued separately, NOT fixpoint debts).

> **Audited 2026-07-22 (orchestrator):** D-1 (`data.py:72`), D-2 (`lower.py:295`,
> `native.py:386-392`, `:424-427`), D-3 (`native.py:245-247`, tags via
> `decl.order`), D-4 (`surface.py:528`, `:549`) all site-verified against live
> source. Clean claims re-grepped independently: no `float(`/`hash(`/`id(` in the
> checker-reachable core; no bare true-division outside docstrings. Already-pinned
> models verified: `refine.py:243-248` `sorted()` canonical quote; `pretty.py:28`
> `repr` display-only.

## Fixpoint debts — reach emitted output or a checker verdict

| # | file:line | dependence | reaches-output? | proposed pin | couples-to |
|---|-----------|------------|-----------------|--------------|------------|
| D-1 | ~~`data.py:72`~~ (now `data.py` `_tyv_key`) | Was `key = (tyv[1], repr(tyv[2]))` — the linear-kind cycle-detection `seen` set keyed on CPython `repr()` of the type-args value vector. `repr` format is host-specific; a format change alters collision/cycle-break behavior. | **YES — checker verdict.** Feeds `is_linear`, which drives QTT linearity acceptance/rejection. A repr collision → early `False` → wrong linearity verdict → different program acceptance → non-convergence. | **SCAFFOLD SIDE PAID 2026-08-02.** `_linear_data` now keys on `_tyv_key(sig, tyv) = _freeze(K.quote(sig, 0, tyv))` — the QUOTED normal form (the checker's own canonicalizer, no closures), frozen to a hashable structural tuple. Reproducible from source alone; strictly sounder than repr (quote normalizes, so definitionally-equal redex/reduct type-args key identically → catches more cycles). Test-locked: `test_kernel.test_linear_kind_key_is_structural_not_repr` + the two non-uniform cycle tests. **PORT-SIDE MIRROR PAID 2026-08-03.** `lib/ty-cmp.chiral` `ty-cmp : (-> Ty Ty Ord)` — a total STRUCTURAL order over data.chiral's closure-free `Ty` (`ty-var`/`ty-tcon`/`ty-pi`/`ty-app`/`ty-i64`). Since the chirality `Ty` is already normal-form syntax (no closures), the scaffold's quote is trivial and the key is direct structural comparison — the same "structure not `repr`" guarantee. Strings compare byte-lexicographically via `str->bytes`+`bget` (no `bcmp` primitive needed — composed from the existing byte face, so the E25 sequencing note is moot). Differential vs an independent Python reference total order over all 14×14 corpus pairs + total-order laws (`test_ty_cmp_chirality.py`). *No consumer yet: the chirality E8 linear walk (`lib/data.chiral`) is depth-bounded, not seen-set-based; `ty-cmp` is the seen-set key ready to wire when the self-hosted linear walk adopts cycle detection — its determinism property (structural, reproducible from source) is what the fixpoint needs.* | E08 (seed), E27, E25 |
| D-2 | ~~`native.py compile`~~ | Emission **sequence** derived from `dict` insertion order (function offsets + literal-table byte layout). | **YES — emitted bytes.** | **PAID 2026-07-28.** `native.compile` now sorts `fns` by name before emission (`fns = sorted(fns, key=lambda f: f.name)`), so byte layout is reproducible from source alone, independent of definition/insertion order. Proven order-independent: `test_emission_is_source_order_independent` (same functions in three source orders → byte-identical; teeth-verified — fails without the sort). The chirality port reaches the SAME order by building its fn list from the comparator-sorted E27 map, so both stages agree. *(The lowering LOOP is deliberately left in dependency order — callee-before-caller — since sorting it would break the preserve-check's forward-reference resolution; only the emission order, which is what becomes bytes, is sorted.)* | E27 (port side) |
| D-3 | `native.py:245` `for dname, decl in sig.data.items()` (builds `ctor_tag`) | Iterates `sig.data` to populate the constructor→global-tag map. | **Borderline — VALUES are pinned.** Each tag is `decl.order.index(cname)` (native.py:247, an explicit list), and constructors are globally unique (`ctor_home`, data.py:431). So the map *values* are order-independent. Debt only if ctor uniqueness is ever relaxed OR a future path emits tags in `sig.data` iteration order rather than via `decl.order`. | Keep tags sourced from `decl.order` (already correct); preserve global ctor uniqueness as an invariant. Track alongside D-2. | E27 |
| D-4 | `surface.py:549` `for tname, reqs in sig.targets.items()`; `surface.py:528` `for pname, prof in sig.profiles.items()` | `verify_targets` / `verify_profiles` build their report **list** in dict insertion order. | **Verdict: NO** (pass/fail and CLI exit code are order-independent — cli.py:60/69 fold over rows). **Emitted list order: YES if the report is treated as canonical output.** Per-row content is sorted (surface.py:530/536), only the outer list order rides insertion order. | If verify output is ever hashed/diffed as an artifact, sort the outer list by a total key; otherwise rely on the E27 insertion-order guarantee. Low severity. | E27 |

**Count that reaches emitted output or a verdict: 2 hard (D-1, D-2)** + 2 conditional
(D-3 safe under current invariants, D-4 display-order-only). **D-2 PAID 2026-07-28
(sorted emission); D-1 SCAFFOLD SIDE PAID 2026-08-02 (quote+freeze structural key,
`data.py` `_tyv_key`).** Both hard scaffold-side debts are now discharged — the
running checker's emitted bytes AND its linearity verdict are reproducible from
source alone, no CPython `repr`/insertion-order dependence in the verdict path.
D-3/D-4 stay conditional/low. The one REMAINING item is the port-side mirror of
D-1: the chirality `tyv-cmp` comparator for the self-hosted checker, which mirrors the
now-pinned quote+freeze reference (mechanical, E27 follow-on after E25 `bytes-cmp`).
So the scaffold's determinism gate before the fixpoint is CLEAR; only the chirality
re-implementation of the D-1 key remains, and its reference behavior is fixed.

## Confirmed already-pinned (verified holds — do NOT redo)

- **Two's-complement + Euclidean arithmetic.** `impl_pure.py:19-45`: `wrap64`
  reduces into signed 64-bit range; `i64_div`/`i64_mod` are Euclidean
  (`0 ≤ r < |b|`), explicitly correcting Python's `//`/`%` (the `r < 0` fixups) so
  the result is host-independent. The constant-fold path delegates to the *same*
  functions (`optimize.py:37-51`, `_fold_prim` → `i64_div`/`i64_mod`/`wrap64`), and
  the native drop is Euclidean by construction (`native.py:25-26`). Matches
  `docs/floor-agreement.md`. **Verified: bit-for-bit agreement across
  reference/fold/native; no int-width divergence. Do not re-argue (per
  chirality-division-euclidean memory).**
- **Refinement quote — canonical atom ordering.** `refine.py:243-248` `_quote`:
  the forbidden-value set and the symbolic `(op, level)` bound set are emitted into
  the quoted `Refine` term through `sorted()` over **total keys** (ints;
  `(str, int)` tuples — `_const_atoms` at refine.py:151, `sorted(v[2][3])` at
  refine.py:246). This is the pin done right: frozenset iteration order never reaches
  the quoted term un-canonicalized. Conversion checking therefore sees a stable form.
- **Constructor tag numbering.** `decl.order` (`data.py:19`, a list captured in
  source order at `surface.py:241`) is the canonical tag basis, consumed by
  `native.py:246-247` and `lower.py:69` — never raw `ctors` dict iteration.
- **String encoding — always explicit UTF-8.** `impl_pure.py:101-102`
  (`.encode("utf-8")` / `.decode("utf-8","replace")`), `native.py:181,333,441`
  (explicit `"utf-8"`). No implicit `.encode()`/`.decode()` reaching output; the
  `"replace"` error mode is deterministic. Strings are byte-indexed UTF-8
  (`native.py:27`).

## Display / error-path only — NOT fixpoint debts

- `pretty.py:28` `repr(t[2])` — string literal display in the pretty-printer, which
  `kernel.py:13` documents as display-only, reached only on error/show paths.
- `data.py:430` `for cname, fields in ctors.items()` in `check_data` — raises on the
  first bad constructor; only the **error-message** identity is order-sensitive. The
  success-path effect (`ctor_home` registration) is order-independent.
- `data.py:398` `decl.ctors.items()` in `_sp_params` and `data.py:82`
  `decl.ctors.items()` in `_linear_data` — both compute an **order-independent
  boolean** (ANY non-positive field → not-clean; ANY linear field → linear).
- `native.py:144` / `native.py:231` `ctors.values()` inside `all(...)` — boolean,
  order-independent.
- `native.py:148` `_dname_of` `for dname, decl in sig.data.items()` — returns the
  first (unique, by `ctor_home`) match; order-independent result.
- `runtime.py:53` `', '.join(sorted(missing))` — error message, already sorted.
- `impl_ports.py:63,184` `ms / 1000.0` (float) and `impl_ports.py:359+` `json` —
  runtime host transport/timing (sleep, HTTP), never the checker's compiled output
  or a verdict. Float appears **only** here, on the runtime port boundary.
- `native.py:389` `intern`'s `payload not in index` — keyed by **value equality** on
  `bytes`/`int` (`val.encode("utf-8")` or `val`), not `repr`/`hash`/`id`. Order of
  the table is the D-2 concern; the key mechanism itself is sound.
- `lower.py:90` `for name in sig.prim_types` (`prim_sigs`) — builds a name-keyed
  lookup dict for the tal type-checker; the native emitter uses the module
  constant `_PRIM_SIGS` (`native.py:369`), not this map, and a keyed lookup's
  result is iteration-order-independent. *(Dispositioned 2026-07-22 —
  2nd-order audit flagged it as uncatalogued in the lowering path.)*

## Coverage

Grep patterns run across `kernel.py terms.py effects.py data.py refine.py
surface.py native.py lower.py optimize.py tal.py bridge.py runtime.py pretty.py`
(plus `impl_pure.py impl_ports.py alarms.py sexp.py cli.py` for callers):

- dict/set iteration: `\.keys\(\)|\.items\(\)|\.values\(\)|for .* in .*(dict|set|env|ctx|table|seen|cache|reg|defs|sigs)` — every hit read and classified above.
- `repr\(|\bhash\(|\bid\(` — only two hits total: `data.py:72` (D-1) and `pretty.py:28` (display). **No `hash()` or `id()` used as a key or canonical form anywhere.**
- float: `float\(|[0-9]\.[0-9]|` bare `/` division — the only true-division/`.0` in checker-reachable code is the fold path, which routes through Euclidean `i64_div`; the only float literals are `impl_ports.py` runtime timing.
- `sorted\(|min\(|max\(` — all confirmed: refinement quote (total keys), profile/target reports (total keys / order-independent verdict), universe-level `max` (ints), bound-narrowing `min`/`max` (ints), error-path `sorted(missing)`.
- encoding: `\.encode\(|\.decode\(|utf|ascii|latin` — every `encode`/`decode` carries an explicit `"utf-8"`.
- set→list / frozenset: `list\(set|set\(|frozenset` — refinement bound frozensets reach output only via the D-list `sorted()` quote; all other sets are membership/cycle guards.
- int-width bit ops: `&|>>|<<` — masks are `& 255`, `& ~7`, `1 << 20`, page-align `& ~(_PAGE-1)`; none diverge from I64 (they operate on already-wrapped values or byte/size arithmetic).

**Residual risk (honest note).** (1) Coverage is over the named trusted core +
adjacent emitters; a canonicalizer reaching output through a *chirality-source library*
(`lib/*.chiral`) rather than the Python scaffold would not be caught by these greps —
but per the port model those libraries are re-derived by the chirality checker itself and
are subject to the same fixpoint, so they can only *inherit* D-1/D-2, not add a new
CPython dependence. (2) D-2/D-3/D-4 are all latent behind CPython dict
insertion-order; they are invisible until the E27 port lands, which is exactly why
they are catalogued now rather than discovered at fixpoint time. (3) The `intern`
table (D-2) and function layout order share one root cause — insertion-ordered
iteration of `sig.global_defs`/`sig.data` — so a single **emission-order pin**
(sort by total key at emission, applied in BOTH stages — see the D-2 re-pin)
discharges the entire structural cluster at once. (4) *Sequencing (2026-07-22):*
the structural-cluster discharge is transitively gated on **E25** — sort-by-name
and `tyv-cmp` both need a `Bytes` comparator, and no `bcmp` primitive exists yet.
Order: E25 → E27 `bytes-cmp` → `tyv-cmp` → the D-1/D-2 pins land.
