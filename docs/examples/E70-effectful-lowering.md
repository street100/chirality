---
element: E70
slug: effectful-lowering
title: Effectful lowering: the effect row's tal shadow + preserve-check over the effect claim, making `=>` arrows lowerable (the compiler is effectful — self-hosting cannot go native without this)
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: drafted
updated: 2026-07-22
---

# E70 — Effectful lowering: the effect row's tal shadow + preserve-check over the effect claim, making `=>` arrows lowerable (the compiler is effectful — self-hosting cannot go native without this)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E70, the floor representation of the effect row (the **tal
  shadow**) plus the extension of `preserve-check` that verifies it — the
  mechanism that makes a `=>` arrow *eligible to lower* at all.
- **Kind:** BUILD-PROPER (design from `decision-effect-facets` + our own
  lowering pipeline; no external artifact to conform to).
- **Why chirality needs its own:** today an effect arrow is ineligible for the
  floor *by construction* — `lower.py:299` raises
  `Ineligible("effectful (crossings stay upper)")`. Fine for the tomodachi
  (eleven crossings stay on the interpreter); fatal for self-hosting, because
  the checker and compiler are themselves effectful, closure-heavy code. No
  `=>` at the floor ⇒ no native compiler ⇒ no self-host. And the thesis makes
  the *shape* of the fix non-negotiable: if lowering erased the effect claim,
  effects would die at exactly the altitude where a gap is worst
  (no-untyped-bottom applies to the row, not just to types).

## 2. Research

- **Reference class:** OURS — `lower.py` (the eligibility gate and the
  preserve-check discipline), `tal.py` (`TalFn.sysface`, the floor's one-bit
  prototype), `decision-effect-facets` (the row), the E51 pre-run (the
  binding table that gives every crossing a floor landing point).
- **Key findings:**
  1. **The gate is one line.** `lower.py:299` rejects any `=>` arrow; the
     Pi's eff annotation is already peeled and visible during lowering
     (`lower.py:74`), so the *information* needed to lower a row is present —
     only its floor representation and check are missing.
  2. **The shadow's prototype already exists and is enforced.** `TalFn.sysface`
     is a per-function bool; the backend refuses the `sys` instruction outside
     the deliberate sys library. That is a one-entry row ("performs sys-family
     crossings: yes/no") with containment checked at the floor. E70 is that
     mechanism generalized from one bit to the row.
  3. **`preserve-check` currently discharges the type claim only.** The tal
     checker re-checks a compiled body against the tal image of its declared
     *type*; nothing re-checks its declared *effects*. Floor-agreement's
     lesson (type preservation ≠ value preservation) has an effect-side
     analogue: type preservation ≠ effect preservation. The row needs its own
     re-derivation at the floor.
  4. **E51's binding table defines what a crossing compiles TO.** An upper
     crossing (`fd-write`) lands on a bound floor function (`wrap-write` →
     `nb-sys-write`). So "the crossings reachable from a compiled body" is a
     well-defined, computable set: walk calls, map through the table.

## 3. Conventional (other-language) approach

Mainstream compilers erase effect information at the IR boundary and trust
unchecked attributes where any survives:

```llvm
; LLVM: effect info is an unchecked HINT. Nothing verifies `readonly`;
; a wrong attribute is a silent miscompile, not a rejected module.
declare i64 @get_time() #0
attributes #0 = { readonly nounwind }

; C: same story, worse spelling — the compiler TRUSTS this claim and will
; happily CSE/reorder/duplicate calls on its basis:
;   __attribute__((pure)) long lookup(long key);
```

- **Assumptions it bakes in:** effect claims are hints, not obligations —
  asserted by the author, verified by no one; effect info dies before codegen,
  so the optimizer reorders or duplicates calls on trust; the linker sees only
  symbols (a "pure" function can `write(2)` and nothing structural notices);
  and there is no notion of *which* effects — at best one coarse
  readonly/side-effecting split, the same one-bit ceiling our scaffold has.

## 4. The chirality idea

- **Chirality features in play:** the two-facet membrane (the row = exercise), the
  lowering connector + `preserve-check` (the joining law's discipline: every
  drop is checked), the sysface confinement mark (the prototype), category C
  (the floor seam the crossings land on), no-untyped-bottom.
- **The reframing:** the row lowers *with* the function. A tal signature gains
  a **row shadow** — the set of crossings the compiled body is entitled to
  reach — and `preserve-check` grows a second obligation: re-derive, from the
  compiled body alone, the set of floor crossings transitively reachable
  (direct `sys` use, calls into bound floor functions, calls into other tal
  functions' shadows), and demand it be **⊆ the declared shadow**. The upper
  eligibility gate then opens: a `=>` function lowers exactly like a pure one,
  its crossings compiling to calls into the E51 binding table's floor
  functions, and its claim travels down *checked*, the same way its type does.
- **What chirality makes impossible here:** a native function that performs a
  crossing its row does not name (the floor re-check rejects the module — a
  lowering or optimizer bug is a floor alarm, never shipped); an optimizer
  pass *introducing* a crossing (fold/dead/specialize outputs re-enter the
  same check); and the conventional attribute lie — there is no trusted
  effect annotation anywhere, only re-derived ones.

## 5. Chirality example (fleshed)

```chirality
; ---- the shadow: the tal image of E39's effect Row -----------------------
; The row shadow attaches to the TYPED tal signature (the checker-side IR — the
; E18 typed sibling of the type-ERASED lib/tal-ir.chiral TFn, same erased-vs-
; typed split E18 records). Its content is the tal image of E39's upper Row
; (row.py): a canonical SORTED SET of crossing-name strings. That row is
; already inferred + stored upper-side (sig.def_rows — "the E51/E70 artifact"
; per the E39 map row), so E70 CARRIES it down, it does not recompute it. A set,
; not a multiset — WHICH crossings are licensed, not how many times (counts/
; order are floor-agreement's differential obligation, not the row's).
(data TalRow () (tal-row (crossings (List Str))))  ; mirrors row.py Row.names

(data TalSigE ()                       ; the type signature + its row shadow
  (tal-sig-e (params (List TalTy)) (ret TalTy) (row TalRow)))

(data TalFnE ()                        ; a tal function carrying its shadow
  (tal-fn-e (sig TalSigE) (code TCode)))

; ---- the check, stated as a result sum (the preserve-check extension) ----
; Re-derive reachable crossings from the compiled body: direct sys use maps
; through the E51 binding table to its upper name; a call into another tal
; function contributes THAT function's declared shadow (transitively).
; Verdict: reachable ⊆ declared, or the module is rejected at the floor.
(data RowCheckR ()
  (row-ok)
  (row-escape (fn Str) (crossing Str)))  ; named: WHICH fn reached WHAT

(declare tal-row-check
  (-> TalFnE (List SysBinding) RowCheckR))
; walk calls -> map through bindings -> union callee shadows -> subset test
; (structural recursion over the instruction list; skeleton, body elided ; …)

; ---- what it licenses: an effectful function LOWERS ----------------------
; Upper (unchanged from lib style):
;   (declare log-line (=> (1 f Fd) Str WriteR))     ; inferred row {fd-write}
; Its tal signature after E70:
;   params: [ptr, ptr]   ret: ptr   row: (tal-row (cons "fd-write" nil))
; Its compiled body calls wrap-write -> nb-sys-write; the checker re-derives
; {fd-write} via the binding table; {fd-write} <= {fd-write}: row-ok.
;
; A fold pass that DUPLICATES the call: reachable set unchanged -> row-ok
; (counts are not the row's claim). A pass that inlines a crossing into a
; declared-pure function: reachable {fd-write} vs declared {}: row-escape --
; the floor alarm that refuses to ship it.
```

- **Knobs to modify:** whether sys-family crossings get a distinguished
  sub-shadow (re-deriving today's `sysface` as `row ∩ sys-family ≠ ∅`); subset
  semantics for the migration window (an unbound crossing = automatically an
  escape). (The shadow's element type is NO LONGER a knob: E39 settled the upper
  Row as a canonical sorted crossing-name set — `row.py`; the shadow is its tal
  image.)
- **Deliberately omitted:** closure captures at the floor (EDGE-CANDIDATES C3
  — capture visibility is E69's seam, named not designed); the `runtime.py`
  dispatch refactor (E51's implementation run); grade shadows (E38 — the cost
  seats lower separately); alarm-payload representation at the floor.
  Note the floor shadow is always PRECISE: the only source of E39's DYN row
  (`"*"`) is a higher-order `=>` in a non-spine position, which does not lower
  until E69 defunctionalizes it to concrete calls (each carrying its own precise
  row) — so DYN never reaches the floor, and a lowered body's calls are always
  to named functions with precise shadows.

## 6. Use / modify notes

- **Lands in:** `lower.py` (the `:298` gate opens for `=>` when the declared
  row `sig.def_rows[name]` is available; crossings compile to binding-table
  calls), `tal.py` (the row field on the TYPED tal signature — the checker-side
  `fn_sigs` / E18 typed IR, NOT the type-erased `lib/tal-ir.chiral` TFn;
  `tal-row-check` beside the existing type re-check), `optimize.py` (its outputs
  re-enter the extended check — no pass change needed, the invariant is in the
  substrate).
- **Conformance target:** the tomodachi's eleven upper crossings lower and
  run with observables identical to the interpreter path (differential, both
  floors); every currently-lowered pure function re-checks with row `{}`
  unchanged; `sysface` re-derives exactly as the sys-family projection of the
  shadow (no behavior change to the backend's refusal).
- **Resolved since drafting (by the built E39/E51 substrate):**
  - *Vocabulary — check across the table.* The shadow speaks upper crossing
    names (E39's `sig.def_rows`, canonical sorted); the body speaks floor
    symbols (wrapper calls / `nb-sys-*`); E51's binding table is the mapping
    witness, itself re-checked, not trusted. Confirmed by `row.py` (rows stored
    in upper names) + the E51 `bind-sys` table.
  - *Outlined functions — computed, not declared.* `lower.py` already re-checks
    the synthesized non-tail functions (`low.extra`, `lower.py:313`), so the row
    check computes their reachable set bottom-up and carries it, while verifying
    user defs against their declared `sig.def_rows`.
  - *halt/alarm — explicit row.* `halt` is an ordinary extern (`effects.py`:
    "nothing special-cases them"; E26 settled alarms-as-crossings), so it enters
    a shadow only when actually reachable — never implicitly in every shadow.
- **Open (author-tier, scope):** does E70 ship standalone, or must it land WITH
  E69? Neither alone takes the closure-heavy checker/compiler native — E70 is
  the row shadow + floor check; E69 makes higher-order calls concrete so the
  footprint applies. Whether the conformance target (the tomodachi's eleven
  crossings) is reachable by first-order lowering alone, or needs E69 first, is
  the deliverable-boundary call the spec must make.
- **Related:** [[E39-effect-row]] (the upper row this shadows),
  [[E51-sys-linkage]] (the binding table the check spans),
  [[E69]] (closure conversion — the sibling wall), [[E16-lowering]]
  (the pipeline being extended), [[E18-tal-check]] (the checker gaining the
  second obligation), E38 (grade seats lower separately).
