---
element: E144
slug: str-porttype-carrier
title: Non-word (Str) porttype carrier — nt-str carrier + nb-id peels; unblocks E137
kind: BUILD
example: examples/E144-str-porttype-carrier.md
status: implemented
updated: 2026-08-16
---

# E144 SPEC — Non-word (Str) porttype carrier

## 1. Deliverable

The compiler lowers a str-carried `porttype` (carrier `nt-str`) and its `nb-id`
identity peels, so a def threading such a handle compiles instead of being dropped.
Concretely: `scaffold/lib/compile-front.chiral` gains `porttype-str?` + an `nt-str`
branch in `term->ntalty`; `scaffold/lib/tal-erase.chiral` `prim2lib-table` gains the
`backend-open`/`be-base` → `nb-id` peels. B1 is rebuilt from source and fixpoints.

- **Non-goals:** the general declared-carrier registry (E123 §6 residue) — the
  `porttype-str?` name-list is the stopgap; `backend.chiral`'s porttype + linear
  threading (E137); `backend-close`'s drop-lowering (E137).

## 2. Baseline

- **Verdict:** BUILD (extends E123's word-carrier; E123 §6 named this the deferred
  non-word residue). No conformance-map row.
- **Live code composed with:** `compile-front.chiral` `term->ntalty`/`porttype-word?`
  (E123); `tal-erase.chiral` `prim2lib-table` + `nb-id` (E124 `adopt-fd`); `bytes-tal.chiral`
  `nb-id-t`. No new native op.
- **True delta:** one `porttype-str?` def + one `case` branch in `term->ntalty`; two
  `prim2lib-table` entries. Both are compiler sources → a rebuild + fixpoint.

## 3. Decisions

| # | Question | Disposition | Rationale |
|---|----------|-------------|-----------|
| 1 | Carrier declaration: name-list vs general registry? | **RESOLVED — name-list (stopgap)** | Mirrors the existing `porttype-word?` closed set (also a hardcoded name-list). The general per-porttype registry (declared carrier consulted like `latoms`) is E123 §6's explicit deferral; a real follow-on when a 2nd non-word carrier appears. Documented as the refinement, not silently skipped. |
| 2 | Layering: `Backend` (orchestration) name in the compiler core? | **RESOLVED — accept, documented** | A known smell (the word-set is all `ports.chiral` system types; `Backend` is app-level). The `adopt-fd → nb-id` precedent already registers a specific extern's lowering in the compiler. Mitigated by the registry being the future; narrow + no broad behavior change. |
| 3 | Runtime carrier for a str-porttype? | **RESOLVED — `nt-str`** | The handle IS its base string at runtime; `nt-str` is pointer-sized, already flows through the whole pipeline (zero ripple — the compiler fixpoints unchanged). |

## 4. Change plan

### Step 1 — `compile-front.chiral`
Add `porttype-str?` (name-list: `Backend`) + an `nt-str` branch in `term->ntalty`'s
`t-primty` case, before the `porttype-word?` branch. ~S.

### Step 2 — `tal-erase.chiral`
Add `("backend-open" "nb-id")` and `("be-base" "nb-id")` to `prim2lib-table`. ~XS.

### Step 3 — rebuild + fixpoint + promote
`chirality_blob scaffold/lib sys-linkage compile-front compile-back compile-emit compile-all`
→ B1 compiles it → B1.new; B1.new self-compiles byte-identically (fixpoint); promote to
`scaffold/build/B1` (gitignored — sources are the committed artifact).

## 5. Conformance gate

- **Golden behavior:** (a) self-host fixpoint `B1 == B1(B1)` byte-identical; (b) a
  `Backend` porttype program lowers + round-trips through the peels (`backend-open s`
  → `be-base` = `s`) → exit 0; (c) NO regression — E134 gate + E138 spine tests exit 0
  under the new B1 (the new branch only fires for `porttype-str?` members, absent from
  existing code).
- **Tests:** the compiler fixpoint (build.sh recipe) + the Backend repro (kept in the
  example §5). E137 exercises it in anger.
- **Green line:** unchanged; ledger-lint's pre-existing C/F/I fails unchanged.
- **Done when:** all three gates pass. **(All verified 2026-08-16.)**

## 6. Residue & links

- **Deliberately unbuilt:** the declared-carrier **registry** (E123 §6 residue) — the
  stopgap name-list's honest refinement; `backend-close` drop-lowering + linear be-*
  threading → **E137**.
- **Follow-on this unblocks:** **E137** (Backend porttype) — no longer compiler-blocked.
- **Related:** [[E144-str-porttype-carrier]] · [[E123-native-porttype-carrier]] · [[E137-backend-porttype]].
