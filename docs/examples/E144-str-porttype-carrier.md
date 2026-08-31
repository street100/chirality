---
element: E144
slug: str-porttype-carrier
title: **Non-word (Str) porttype carrier** — a `porttype` whose runtime carrier is `nt-str` (the handle IS a string), reached by `nb-id` identity peels. Extends the E123 word-carrier; unblocks E137 (Backend porttype).
kind: BUILD
reference_class: OURS
ours_source: (none)
status: drafted
updated: 2026-08-16
---

# E144 — Non-word (Str) porttype carrier

> Worked example for a compiler-floor change: let a `porttype` carry a *pointer/string*
> (`nt-str`), not only a *word* (`nt-i64`, E123). The first client is `Backend` (E137).

## 1. Scope

- **Element:** E144, the `nt-str` porttype carrier + its `nb-id` identity peels.
- **Kind:** BUILD (compiler-floor; extends E123's word-carrier).
- **Why chirality needs its own:** a linear `Backend` porttype (E137) holds a base-URL
  **string**, not an fd. E123's carrier maps porttypes only to `nt-i64` (a word); a
  non-word carrier was E123's explicitly-deferred §6 residue. Without it, `term->ntalty`
  drops any def threading a `Backend` (no entry label) and `be-url` can't recover the
  base `Str` from an opaque handle. E137 is blocked on exactly this.

## 2. Research

- **Reference class:** OURS. Sources: `compile-front.chiral` `term->ntalty` /
  `porttype-word?` (E123), `tal-erase.chiral` `prim2lib-table` (the `adopt-fd → nb-id`
  identity-peel precedent), `E123-native-porttype-carrier-SPEC.md` §6 (the non-word
  carrier is the named deferred residue).
- **Key findings:**
  1. `term->ntalty`'s `t-primty` case maps `I64/Str/Bytes` to their carriers and a
     `porttype-word?` member to `nt-i64`; everything else → `(none)` = "stays upper" =
     the def is **dropped** (no peel, no entry label). This is the E137 Blocker 1.
  2. `adopt-fd : (-> I64 Fd)` lowers to **`nb-id`** (a runtime identity re-type) via
     `prim2lib-table`. The exact same mechanism re-types a `Str` into a str-carried
     porttype and back — no new native op, just a registered `nb-id` peel.
  3. An `nt-str` is register-sized (a pointer), and `Str` already flows through the
     whole tal-ssa/reg-alloc/erase/emit pipeline — so a porttype mapped to `nt-str`
     has **zero downstream ripple** (verified: the compiler fixpoints unchanged).

## 3. Conventional (other-language) approach

Rust `repr(transparent)` newtype: `struct Backend(String)` erases to its single field's
representation at runtime while staying a distinct type for the borrow/move checker.
The retype is a compile-time no-op.

```rust
#[repr(transparent)] struct Backend(String);   // runtime == String; distinct type
fn open(s: String) -> Backend { Backend(s) }    // identity at runtime
```

- **Assumptions it bakes in:** the type system's move/borrow discipline is the only thing
  distinguishing `Backend` from `String`; the compiler must know the carrier is a pointer.

## 4. The chirality idea

- **Chirality features in play:** the `nt*` carrier classification in `term->ntalty`;
  `porttype` opacity + linearity (E8 linear-kind); the `nb-id` identity peel (E124
  `adopt-fd`); the boundary-sums-clean single-predicate carrier check.
- **The reframing:** a `porttype` gets a *pointer* carrier (`nt-str`) exactly as E123
  gave fd-porttypes a *word* carrier (`nt-i64`). `backend-open : (-> Str Backend)` and
  `be-base : (-> Backend Str)` are runtime no-ops (`nb-id`); the linear no-dup/no-drop
  discipline is enforced purely at the type level, and the handle carries its base URL
  as its own runtime value.
- **What chirality makes impossible here:** a `Backend` value that duplicates or is dropped
  without discharge (linearity) — while paying zero runtime cost for the wrapper.

## 5. Chirality example (fleshed)

Two compiler-floor edits (both landed + fixpointed):

```chirality
; (1) compile-front.chiral — a str-carried porttype predicate beside porttype-word?,
;     STOPGAP name-list (the general per-porttype carrier registry is E123 §6's
;     deferred refinement); consulted in term->ntalty BEFORE porttype-word?.
(def porttype-str? (lam (n)
  (case (str-eq n "Backend") (true true) (false false))))

;   ... in term->ntalty's t-primty case, before the porttype-word? branch:
(false (case (porttype-str? n) (true (some (nt-str)))
  (false (case (porttype-word? n) (true (some (nt-i64))) (false (none))))))

; (2) tal-erase.chiral prim2lib-table — the Str<->Backend identity peels (nb-id),
;     the adopt-fd mechanism verbatim:
(cons (pair "backend-open" "nb-id") (cons (pair "be-base" "nb-id") ...))
```

```chirality
; the verification program (compiles + runs exit 0 under the rebuilt B1):
(porttype Backend)
(extern backend-open (-> Str Backend))
(extern be-base      (-> Backend Str))
(def compile-main (=> I64 I64)
  (lam (n)
    (let (b (backend-open "http://ok:11434"))
      (case (str-eq (be-base b) "http://ok:11434") (true 0) (false 1)))))
```

- **Knobs to modify:** add names to `porttype-str?` (until the registry lands); the peel
  extern names in `prim2lib-table`.
- **Deliberately omitted:** the general declared-carrier registry (E123 §6 residue);
  `backend-close`'s drop-lowering and the linear be-* threading (that's E137).

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/compile-front.chiral` (`porttype-str?` + `term->ntalty`
  branch), `scaffold/lib/tal-erase.chiral` (`prim2lib-table` peels). Compiler-source
  change → rebuild B1 + **self-hosting fixpoint** (verified byte-identical) + regression
  (E134/E138 tests unchanged).
- **Conformance target:** (a) the promoted compiler reproduces itself (`B1 == B1(B1)`);
  (b) a `Backend` porttype program lowers and round-trips through the peels (exit 0);
  (c) no regression in existing programs (the new branch only fires for `porttype-str?`
  members, absent from all existing code).
- **Open questions:** the general per-porttype carrier **registry** (declared carrier,
  consulted like `latoms`) is the honest refinement over the `porttype-str?` name-list —
  a real follow-on when a second non-word carrier appears; the name-list is the stopgap.
- **Related:** [[E123-native-porttype-carrier]] (word carrier) · [[E124-adopt-fd]]
  (the `nb-id` peel) · [[E137-backend-porttype]] (the first client, now unblocked).
