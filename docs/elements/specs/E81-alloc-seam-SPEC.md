---
element: E81
slug: alloc-seam
title: Value-heap alloc seam + `fixed-trap` / `growing` disciplines
kind: BUILD-PROPER
example: examples/E81-alloc-seam.md
status: audited
updated: 2026-08-09
---

# E81 SPEC — Value-heap alloc seam + `fixed-trap` / `growing` disciplines

> Implementation contract produced by the `example-to-spec` run from the
> reviewed S17-E extended example. Bridges the drafted worked example into an
> executable change plan. An implementation run follows THIS file; the example
> remains the design rationale behind it.
>
> **BASE SEAM is SHIPPED** (commit `d6ad519`, byte-identical): `lib/alloc.chiral`
> defines the `Alloc` policy record with five ops + projectors + `alloc-bump`;
> `lib/emit-core.chiral` threads `(0 disc Alloc)` through the emit chain; the two
> allocation sites (`ti-cona` / `ti-bnew`) route through `alo-cell`/`alo-bytes`;
> `lib/emit-x64.chiral` supplies `alloc-bump`. `specialize-singletons` collapses
> the singleton → byte-identical. **This SPEC extends that shipped seam** with a
> second live instance: rename `alloc-bump` → `alloc-fixed-trap`, add
> `alloc-growing` beside it, and add the per-floor selection that chooses which
> discipline a build compiles under.

## 1. Deliverable

- **After this runs:** the shipped `alloc.chiral` gains its second live `Alloc`
  instance. `alloc-bump` is renamed `alloc-fixed-trap` (its policy is now in the
  name); `alloc-growing` joins it — both are bump-family disciplines over the
  same `Mach` vocabulary, differing only in which `Mach` cell/bytes primitive
  their fields select. Two selection points name the per-floor discipline:
  `alloc-for-elf` (→ `alloc-growing`) and `alloc-for-jit` (→
  `alloc-fixed-trap`). The emit-x64 supply site switches from raw `alloc-bump`
  to the selection alias. The `Alloc` record's field names stay unchanged
  (`cell`/`bytes`/`renter`/`rexit`/`adrop`); projectors stay `alo-cell`/
  `alo-bytes`/`alo-renter`/`alo-rexit`/`alo-drop`. Byte-identity is
  **discipline-parametric**: two compiles under the same discipline agree
  byte-for-byte; switching discipline legitimately changes bytes (`ud2` sites
  become `jbe`/`call arena-grow`).
- **Non-goals:** the growing allocation *sequences* themselves (`x-galo`/
  `x-gbnw` → E91), the shared `"arena-grow"` stub + `mprotect` crossing
  (`nb-arena-grow` → E90), the check-first reorder of the trap sequence
  (E91 step 1), the reserve-commit arena init (E89-EXT), any non-bump
  discipline (region → E82, reuse → E83, dps → E84), per-phase profile
  wiring (E85).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E81 postdates the map snapshot. The base
  seam is shipped and verified (d6ad519), and the precedents it composes with
  are all built (verified in outlines), so this is a structural extension, not
  new metatheory.
- **Live code this composes with (do NOT respec):**
  - **`Alloc` record + projectors + `alloc-bump`** (`lib/alloc.chiral`, 49
    lines): the shipped discipline seam. `(data Alloc () (alloc (cell …) (bytes
    …) (renter …) (rexit …) (adrop …)))`. Five projectors (`alo-cell` through
    `alo-drop`). One instance `alloc-bump` — delegates `cell`/`bytes` to bare
    Global refs `mach-alo`/`mach-bnw` (currying match → specialize rewrites
    straight to them → byte-identity); `renter`/`rexit`/`adrop` are no-ops.
  - **`Mach` record + projectors** (`lib/mach.chiral`, `lib/mach-x64.chiral`):
    the ISA-vocabulary seam. `alo` field (`mach.chiral:38`) → `mach-alo`
    projector; `bnw` field (`:42`) → `mach-bnw`. The x64 instance `x64`
    (`mach-x64.chiral:786`) fills them with `x-alo` (`:239`) and `x-bnw`
    (`:291`). E91 will add `galo`/`gbnw` fields → `mach-galo`/`mach-gbnw`
    projectors — E81 only references them by name from the future `Mach`
    vocabulary.
  - **The emit chain** (`lib/emit-core.chiral`): `emit-instr` (`:146`), the
    whole chain through `emit-with*`, all carry `(=> Mach Alloc …)` with `disc`
    as the `Alloc` param. Two allocation sites: `:151` `((alo-cell disc) m dst
    tag fields)` for `ti-cona`; `:163` `((alo-bytes disc) m dst len)` for
    `ti-bnew`. No logic change needed — the discipline swap is transparent at
    the call site.
  - **The supply site** (`lib/emit-x64.chiral`): three `emit-with*` calls
    (`:23`/`:26`/`:32`) pass `x64 alloc-bump` — `x64` as Mach, `alloc-bump` as
    Alloc. The extension changes `alloc-bump` → the selection alias.
  - **`specialize-singletons`** (`lib/specialize-singleton.chiral`): run before
    `closconv-sig` in `compile-front`; auto-detects per-build singletons and
    collapses them. Because each build picks exactly one discipline,
    `specialize-singletons` still collapses the per-build singleton — a growing
    build pays no more indirection than a trap build.
- **True delta:** rename one def + add one def + add two selection aliases in
  `alloc.chiral`; swap the name at the emit-x64 supply site; update three Python
  test string-literals referencing `\"alloc-bump\"` (`test_alloc_seam.py:4,69`,
  `test_backend.py:59`). That's it. The
  sequences `alloc-growing` names (`mach-galo`/`mach-gbnw`) are E91's
  deliverables — E81 only references them.

## 3. Decisions

Every open question from the example §6, dispositioned.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Byte-identity: how does `alloc-bump`'s delegation avoid an inline step? | **RESOLVED — base seam shipped (d6ad519).** The bare Global-ref currying match (`mach-alo` has the same type as `cell` field by currying) hits specialize's Global-ref case → `((alo-cell disc) m …)` rewrites to `(mach-alo m …)` = today's site. Verified byte-identical. | Shipped implementation; no change needed for the extension — `alloc-fixed-trap` keeps the same bare Global refs. |
| 2 | `region-enter`/`region-exit` signature — what `Mach` primitive expresses save/restore? | **RESOLVED for E81 (type only); mechanism DEFERRED → E82.** The op type is `(-> Mach I64 (List Asm))` (m + mark-slot id). Both bump-family instances supply no-op bodies; neither emits a region call site. E82 adds the save/restore-`heapptr` `Mach` primitive and decides the slot's home. The type is fixed here so downstream instances conform. | Arc decision (`.planning/MEMORY-DISCIPLINE-ARC.md`, E82 row). |
| 3 | Rename `alloc-bump` → `alloc-fixed-trap` — is this safe? | **RESOLVED.** The name `alloc-bump` appears in `alloc.chiral` (one def) and `emit-x64.chiral` (three supply-site calls). Renaming is a mechanical find-replace across two chirality source files. Python tests (`test_alloc_seam.py`, `test_backend.py`) reference `\"alloc-bump\"` as a string literal for global-value lookup; those strings must also be updated. The shipped byte-identity is preserved: renaming doesn't change emitted bytes. | Grep of lib/ confirms only `alloc.chiral` + `emit-x64.chiral` use the name; tests use it as a string key. |
| 4 | Should `alloc-growing`'s `cell`/`bytes` fields reference `mach-galo`/`mach-gbnw` by bare Global ref, even though those Mach fields don't exist yet? | **RESOLVED — yes, by forward reference.** `alloc-growing` names `mach-galo`/`mach-gbnw` as bare Global refs, identical in shape to how `alloc-fixed-trap` names `mach-alo`/`mach-bnw`. These are forward references — the Mach fields land in E91. The compiler blob resolves them at compile time. Until E91 lands, `alloc-growing` can't be the selected discipline in a build that compiles and runs, but it can be defined and type-checked. | Forward references are valid chirality; B1 resolves all globals regardless of definition order in the blob. |
| 5 | The selection site — where exactly does the profile fix `{Mach} × {Alloc}` per floor? | **RESOLVED for E81 (aliases); wiring DEFERRED → E85.** E81 defines two selection aliases: `alloc-for-elf = alloc-growing` and `alloc-for-jit = alloc-fixed-trap`. The emit-x64 supply site uses `alloc-for-elf` (the compiler's own build is an ELF image). The JIT floor's supply of `alloc-for-jit` is E85's concern — E81 only provides the named aliases. | Aliases are the seam; which alias each floor selects is profile wiring (E85). |
| 6 | Discipline-parametric byte-identity — does switching disciplines break determinism? | **RESOLVED — no.** Fix the discipline and bytes are deterministic. Two compiles under `alloc-fixed-trap` agree; two under `alloc-growing` agree. Switching flips `ud2` sites to `jbe`/`call arena-grow` — a legitimate, deterministic change driven by the discipline, not nondeterminism. E91's check-first reorder is a separate one-time byte-diff → refixpoint, owned there. | Byte-identity is discipline-parametric: `bytes = f(source, discipline)`, and `f` is deterministic for each fixed discipline. |

No NEEDS-AUTHOR: the load-bearing shape decision (separate policy record over the
Mach vocabulary) was ratified in the base example audit and shipped; the
extension's renaming and selection are mechanical.

## 4. Change plan (ordered, commit-sized)

### Step 1 — `lib/alloc.chiral`: rename `alloc-bump` → `alloc-fixed-trap`, add `alloc-growing`, add selection aliases
- **Target:** existing file `lib/alloc.chiral` (49 lines). Edit in place.
- **Change:**
  1. Rename `(def alloc-bump Alloc …)` → `(def alloc-fixed-trap Alloc …)`.
     Body unchanged — same bare Global refs `mach-alo`/`mach-bnw`, same no-op
     lam bodies for `renter`/`rexit`/`adrop`.
  2. Add `(def alloc-growing Alloc (alloc mach-galo mach-gbnw (lam (m slot) (the
     (List Asm) nil)) (lam (m slot) (the (List Asm) nil)) (lam (m src) (the
     (List Asm) nil))))` — `mach-galo`/`mach-gbnw` are bare Global refs (forward
     references to E91's Mach fields); `renter`/`rexit`/`adrop` are same no-ops.
  3. Add two selection aliases:
     `(def alloc-for-elf Alloc alloc-growing)` and
     `(def alloc-for-jit Alloc alloc-fixed-trap)`.
  4. Update the file comment to reflect the two-instance state.
- **Size:** ~S (rename + ~8 new lines).
- **Dependency:** `mach-galo`/`mach-gbnw` don't exist yet (E91). `alloc.chiral`
  will still type-check because bare Global refs are valid references — the
  compiler resolves them at compile time against whatever Mach instance is in
  the blob. Until E91 lands, `alloc-growing` works for type-checking but can't
  be the selected discipline in a build that compiles and runs.

### Step 2 — `lib/emit-x64.chiral`: swap supply-site name
- **Target:** the three `emit-with*` calls (`:23`/`:26`/`:32`).
- **Change:** replace `alloc-bump` → `alloc-for-elf` in all three calls. The
  compiler's own build is an ELF image — it should grow on exhaustion. (If the
  growing `Mach` primitives aren't ready yet, pin `alloc-for-jit` instead;
  switch to `alloc-for-elf` once E91 lands.)
- **Size:** ~S (three one-word replacements).

### Step 2a — Python tests: update `\"alloc-bump\"` string-literals
- **Target:** `scaffold/tests/test_alloc_seam.py` (lines 4, 69) and
  `scaffold/tests/test_backend.py` (line 59).
- **Change:** replace the string `\"alloc-bump\"` → `\"alloc-fixed-trap\"` in the
  docstring comment (line 4), the name-set assertion (line 69), and the
  `rt.global_value` lookup (line 59). `specialize.py:85` comment is
  informational and can stay as-is.
- **Size:** ~S (three string replacements).

### Step 3 — verify byte-identity under fixed discipline
- **Target:** no code change. Verify that under `alloc-fixed-trap` (the
  renamed `alloc-bump`), byte-identity holds identically to the shipped base.
- **Check:** rebuild B1 with `alloc-for-jit` pinned as the discipline; diff the
  ELF against the committed `build/B1` from d6ad519 — same bytes (modulo
  legitimate changes from the rename string itself: `"alloc-bump"` → `"alloc-
  fixed-trap"` in the string table is a one-time expected diff).
- **Size:** ~S (verification only).

## 5. Conformance gate

- **Golden behavior:** **discipline-parametric byte-identity.** Fix the
  discipline and bytes are deterministic. Under `alloc-fixed-trap`, a program
  compiles to the same bytes it did under the pre-rename `alloc-bump` (modulo
  the `"alloc-bump"` → `"alloc-fixed-trap"` string-table diff — a one-time
  expected change, not drift). The compiler's own self-compile under
  `alloc-fixed-trap` reproduces byte-for-byte (fixpoint); under `alloc-growing`,
  it also reproduces byte-for-byte (new fixpoint, pending E91's sequences).
- **Tests:**
  - Existing suite is the gate — `test_compile_run_chirality.py`,
    `test_effectful_compile_run_chirality.py`, `test_native.py`, `test_alloc_seam.py`
    must pass unchanged under `alloc-fixed-trap`. Existing assertions in
    `test_alloc_seam.py` and `test_backend.py` that reference `\"alloc-bump\"`
    by string literal must be updated to `\"alloc-fixed-trap\"` (Step 2a).
  - `test_alloc_seam.py` extends with: (a) `Alloc` record loads and `alloc-
    fixed-trap` + `alloc-growing` both type-check; (b) `alloc-for-elf` and
    `alloc-for-jit` resolve to the correct instances; (c) compiling under
    `alloc-fixed-trap` produces bytes equal to the pre-rename baseline (modulo
    string-table diff).
  - Future gate (post-E91): compiling a small program under `alloc-growing`
    produces different bytes than `alloc-fixed-trap` (the discipline is doing
    its job — `jbe`/`call arena-grow` vs `ud2`), and two compiles under
    `alloc-growing` agree.
- **Green line:** full suite green + `test_alloc_seam` passes the
  discipline-parametric checks above. The growing discipline's real soak
  (self-compile with ~9 mprotect doublings, fixpoint byte-identical) is
  E91/E90/S17-F's gate, not this seam's.
- **Done when:** `alloc-fixed-trap` build is byte-identical to the shipped base
  (modulo string-table rename); `alloc-growing` def type-checks; selection
  aliases resolve correctly; full suite green under `alloc-fixed-trap`.

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - *Growing allocation sequences (`x-galo`/`x-gbnw`) + check-first reorder of
    trap sequence* → [[E91-growing-allocator]].
  - *Shared `"arena-grow"` stub + `nb-arena-grow` `mprotect` crossing* →
    [[E90-arena-grow-crossing]].
  - *Arena reserve-commit init (establishes the arena growing commits into
    before the first allocation)* → [[E89-arena-init]].
  - *`region-enter`/`region-exit` bodies + save/restore-`heapptr` `Mach`
    primitive* → [[E82-alloc-region]].
  - *`drop`/reuse-token plumbing (FBIP)* → [[E83-alloc-reuse]].
  - *Destination-passing* → [[E84-alloc-dps]].
  - *Per-phase/per-runtime `{Mach}×{Alloc}` profile selection* →
    [[E85-alloc-compose]].
- **Follow-on:** unblocks **E91** (the `mach-galo`/`mach-gbnw` Mach fields
  `alloc-growing` forward-references) — E91's sequences land in `Mach` and E81's
  growing instance picks them up automatically. Unblocks **E90** (the grow stub
  `alloc-growing`'s selected sequences jump to). Unblocks **E82** (the A4
  fixpoint unblock — first non-bump instance drops into this seam).
- **Related:** [[E81-alloc-seam]] (rationale example), the S17-E siblings:
  [[E91-growing-allocator]], [[E90-arena-grow-crossing]], [[E89-arena-init]];
  precedents: `Mach` record-of-closures (`lib/mach.chiral`),
  `specialize-singleton` (`lib/specialize-singleton.chiral`). Arc authority:
  `.planning/MEMORY-DISCIPLINE-ARC.md`; extension authority:
  `.planning/SCRIBA-UNBLOCK-MAP.md` §"S17 makeup" (S17-E).
