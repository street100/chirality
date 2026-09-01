> **ARCHIVED 2026-09-01. Superseded by `records/findings.md` row `FD-04`, which is TRACKED.** The finding resolved: mutually-recursive `data` landed 2026-08-01 as E79 and is chirality today at `lib/surface/parse.chiral:1319-1446`, not the `surface.py`/`data.py` this file cites. Every `scaffold/` and `.py` path below is a dead reference and is kept only as provenance for what was measured and when.

# FINDING — mutual-recursive data types are an unbuilt prerequisite

**Date:** 2026-07-31 · **Status:** **RESOLVED — BUILT 2026-08-01 as E79**
*(id note: first slotted as "E73", a collision with §XI's outbound-confinement
membrane — renumbered E79 2026-08-01; commit messages retain the old id)*
(commit `11aac83`: `surface.py` `_scan_data_groups`/`top_data_group` +
`data.py` `check_data_group`; 355 tests green, 11 new). E3/E4/E11 are
unblocked — their examples re-enter the gate as-drafted (`--audit example`),
where the leftover mechanical defects below get applied. Two deltas from the
recommendation as written: (1) plain forward (DAG) references are supported
too, not just cycles — SCC-topo processing subsumes it at no cost and keeps
the install-then-judge invariant; (2) termination needed **no** change — the
structural token chain is type-agnostic and already descends through sibling
types (verified by test). · **Blocked:** E3 / E4 / E11 (confirmed, all
parked at example audit); E6 checked clean; E13 audit in flight — either way
no longer blocked · **Surfaced by:** E3
(`E03-nbe-normalize`) example audit.

## The finding (one line)

chirality's surface elaborator cannot express **mutually-recursive `data` types**, and
the self-hosted checker stack fundamentally requires them. This is a missing
table-stakes capability, not a design choice — and the fix is shallow and standard.

## Evidence (empirical, reproducible)

Run against `scaffold/` with `chirality.surface.Elab`:

```
(data A () (a-mk (b B)))      ; A references B, declared later
(data B () (b-mk (a A)))      ; B references A  -> genuine cycle
=> SurfaceError: unknown name B          # FAILS

(data L () (nil) (cons (hd I64) (tl L)))  # self-recursion
=> OK                                     # WORKS

(data V () (v-lam (f (-> V V))))          # HOAS: V left of an arrow
=> SurfaceError: ... V occurs to the left of a function arrow;
                     data types must be strictly positive   # REJECTED
```

## Root cause

- `surface.py` `top_data` (:337) registers a **per-type provisional** DataDecl for
  the *current* name before elaborating its own body — this is why *self*-recursion
  (`List` inside `List`) resolves, and nothing more.
- `_scan_unit` (:96) pre-registers **`def` call-graphs** (for effect-row
  inference), **not** data-type names.
- So a forward reference to a not-yet-elaborated *type* fails name resolution.
  A `Value`↔`Clos` cycle can't be ordered around (both directions reference the
  other), so no declaration order resolves it.

## Why it's table stakes (not optional, not a fork)

A self-hosting compiler is mutually-recursive types top to bottom: the **AST**
(terms ↔ patterns ↔ arms), the **NbE value domain** (value ↔ closure ↔ neutral),
the kernel's own **term representation**. `kernel.py` represents all of these as
plain mutually-referencing Python tuples with zero trouble; at the machine level
they are just tagged heap cells with pointer fields. Nothing deep is missing —
only the elaborator's single-pass name binding is in the way.

**Rejected non-fixes:**
- **Inline the closure** (drop `Clos`, carry `(env (List Value))`+`(body Term)` in
  `v-lam`/`v-pi`): positivity-safe and works per-site, but does NOT scale — you
  cannot inline a whole self-hosted checker's worth of mutual types. A local
  escape hatch, not the fix.
- **HOAS** (`v-lam (body (-> Value Value))`): rejected by strict positivity
  (negative occurrence). Out.
- **Module/port-wrap the two types**: category error. The recursion is one heap
  object graph (a `Clos` nested in a `v-lam` nested in a `List Value`…), not two
  processes crossing a membrane. A closure is data you *pattern-match* and apply
  *purely*; a port is an opaque linear effect-crossing. Routing closure-apply
  through a port would make `eval` effectful — destroying the "NbE is pure, touches
  no port" property that is the whole reason NbE sits safely in the TCB (P6:
  governs a boundary that isn't there; P1: a spurious governed path). Wrong at
  every level, machine code included.

## The fix (recommended)

The textbook two-pass move for recursive binding groups:

1. **Name pre-pass** — in the unit load / `toplevel` loop, register *every*
   `(data Name (params…) …)` in the unit as a provisional DataDecl (name + params,
   empty ctors) **before** elaborating any constructor body. Then forward
   references resolve. ~15 lines in `surface.py` (a pre-scan beside `_scan_unit`,
   or a two-phase `top_data`). Standard in every ML/Haskell/Agda front end.
2. **Positivity + termination over the group** — extend `data.py`'s strict-positivity
   (`_positivity`/variance cache) and the structural-recursion/termination checks to
   reason over the **mutual group** (a type is positive w.r.t. all members; a
   structural measure may descend through a sibling type), not one type in
   isolation. Real but bounded — the variance machinery already exists (E7); this
   generalizes its scope.

**Files:** `scaffold/chirality/surface.py` (load/`toplevel` loop, `top_data`/
`_top_data_body`), `scaffold/chirality/data.py` (`check_data`, `_positivity`,
termination). **Trusted-core sensitivity:** `data.py` is part of the checker —
review the diff as such (positivity is a soundness gate).

## Dependents to check during the pass

- **E3** (NbE) — BLOCKED (`Value`/`Clos`/`Neut` mutual).
- **E4** (bidirectional infer/check) — **BLOCKED, CONFIRMED 2026-07-31**: §5 declares
  `Clos` (refs `Val`) before `Val`, the same cycle. Leftover mechanical defects for
  its re-audit: value-level `if` in `subsume` → `case`; `subtype`'s `case a` covers
  only `v-type` (non-exhaustive over `Val`'s 4 ctors); undefined helpers `env-of`,
  `ck-err-to-tc` need declares. Its lands-in (`lib/kernel.chiral`) is already correct.
- **E6** (data: ctors/coverage) — **NOT blocked** (its own Ty/Field/Ctor/DataDecl
  model is acyclic; reviewed 2026-07-31). Mutual data is what E6 *checks*, not how
  it's written.
- **E11** (totality) — **BLOCKED, CONFIRMED 2026-07-31 (parked)**: its `Term` ADT
  has `t-case (arms (List Arm))` and a real `Arm` holds a `Term` body → `Term`↔`Arm`
  cycle (avoidable by inlining arms as `(List (Pair … Term))`, same inline-vs-support
  choice as E3). The example left `Arm` undefined to dodge it. Also heavily elided:
  ~6 undefined working types (`Arm`/`Sizes`/`Bounds`/`Calls`/`Walked`/`DecSet`, the
  last carrying `v-ok`/`v-err` used in shown code) + ~11 undefined helpers
  (count-lams/strip-lams/sizes-init/bounds-init/calls-empty/calls-empty?/
  intersect-all/is-self/calls-push/walk-children/walk-arms). Leftover mechanical
  defects for its re-audit: value-level `if`→`case` (check-termination, walk ×2);
  `str=?`→`str-eq`. The termination *algorithm* itself (structural + numeric-measure
  + the I64 wraparound-exclusion obligation) is sound and well-presented.
- **E13** (term de-Bruijn machinery) — the term sum may reference mutual sub-forms;
  verify at its audit (likely the same `Term`↔`Arm`).

## Sequencing recommendation

*(Followed 2026-08-01.)* Build "**mutual/recursive data groups**" as its own
**foundational element that lands before the checker stack** — slotted as
**E79** in catalog §I (its own row, not folded into E6: group semantics is its
own soundness surface; the self-host side rides E2 (scan) + E6 (judgment)).
Once built,
**E3's example is expressible exactly as drafted** — the `Value`/`Clos` model is
correct and kernel-faithful; no re-draft, just unblocked.

## Leftover E3 mechanical defects (fix on E3 re-audit, once unblocked)

Not applied now (the example returns through the gate after the prereq lands):
- value-level `if` in `conv` → `case`-on-Bool (`if` is never called at value level
  in any lib — same class as E1/E2).
- `conv-struct`'s `case` on `Value` omits the `v-lam` arm → non-exhaustive; must be
  written even though the eta branch makes it unreachable (the example's own `vapp`
  states this principle).
- 8 undefined-but-called helpers need `declare`s: `nth`, `snoc`, `stuck`, `is-lam`,
  `app-either`, `arr=`, `conv-neut`, `spine->apps`.
- lands-in should be `scaffold/lib/kernel.chiral`, not `scaffold/chirality/` (chirality/ is
  Python-only — the E2 right-homes precedent).
