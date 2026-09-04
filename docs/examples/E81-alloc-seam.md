---
element: E81
slug: alloc-seam
title: Value-heap alloc seam + `fixed-trap` / `growing` disciplines
kind: BUILD-PROPER
reference_class: OURS/IMPL
ours_source: (none)
status: drafted
updated: 2026-08-09
---

# E81 — Value-heap alloc seam + `fixed-trap` / `growing` disciplines

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.
>
> **EXTENDED 2026-08-09** for the arena-dynamism arc
> (`.planning/SCRIBA-UNBLOCK-MAP.md` §"S17 makeup", sub-slice **S17-E**). E81's
> seam and its first instance are **implemented** (commit `d6ad519`,
> `scaffold/lib/alloc.chiral` — byte-identical). The extension adds a **second
> named `Alloc` instance**: the shipped `alloc-bump` is reframed as
> `alloc-fixed-trap` (its policy = trap on exhaustion), and `alloc-growing`
> joins it beside — the trap-vs-grow choice becomes a selectable discipline. The
> exhaustion-sequence internals belong to **E91** (per-site check-first reorder +
> `jbe`+retry; unimplemented) and **E90** (stub glue + the `mprotect` crossing;
> crossings live since `686d51a`); E81 owns only the *seam*, the *two instances*,
> the *selection*, and the *byte-identity* contract. **Live-tree note (audit
> 2026-08-09):** the caller side of the rename is already committed
> (`emit-x64.chiral:24,27,33` reference `alloc-fixed-trap` since `be3df92`; the
> tests expect all four new names since `f2632c1`) while `alloc.chiral` line 43 still
> defines `alloc-bump` — the def-side landing below is what closes that gap.
> **2026-09-04, citation repair:** that gap is closed. `alloc-bump` is gone from the tree
> (`grep -rn alloc-bump lib prog` returns nothing) and `alloc.chiral` is now the 35-line
> `Alloc` seam with its five accessors, so line 43 has no live successor.

## 1. Scope

- **Element:** E81, thread the value-cell allocation ops (`x-alo` and the
  heapptr/heapend bump/trap sequence in `lib/mach-x64.chiral`, which stay `Mach`
  primitives) through a **discipline record** — a set of ops `alo-cell`/`alo-bytes`/`region-enter`/`region-exit`/
  `drop` — the way `Mach` is a record of machine-op closures. `alloc-bump` is the
  first conforming instance = today's exact behavior (region/drop = no-ops), and
  `specialize-singletons` removes the seam at compile time.
- **Kind:** BUILD-PROPER.
- **Why chirality needs its own:** chirality has **two heaps** and only the byte-Pool one
  has a discipline seam. The value-cell heap has an *allocation-site* seam already
  (Mach's `alo` field) but no *discipline dimension* — only one bump behavior, no
  reclamation, so cost = Σ-allocation — historically the 12 GB the self-compile
  churned before the arena `ud2` (that churn was the right-nested-`bcat` emit
  quadratic, fixed at `4e7791b` → ~0.1 GB peak; the growing arc's live sizing is
  256 KiB → ~128 MiB peak). E81 adds the discipline dimension as a **policy layer
  over the Mach ISA vocabulary**: a separate `Alloc` record whose ops are
  ISA-agnostic and compose Mach primitives, threaded orthogonally to `Mach` so a
  profile selects `{ISA} × {discipline}` independently. E82 (region), E83 (reuse),
  E84 (dps) each land as one ISA-agnostic `Alloc` instance without touching any
  backend. The gate is **byte-identity to today** — E81 changes structure, not a
  single emitted byte.
- **S17-E extension (this revision):** the seam gains its **second live
  instance**, the first proof that the dimension carries more than one policy.
  Today's shipped `alloc-bump` is a bump-with-`ud2`-trap policy; now that a
  sibling with a *different* exhaustion policy exists, it is renamed
  `alloc-fixed-trap` (name = its policy) and `alloc-growing` is added beside it.
  `alloc-growing`'s `alo-cell`/`alo-bytes` select the **check-first + `jbe`-to-
  shared-grow-stub** allocation sequence; `alloc-fixed-trap`'s select the
  **`ud2`-trap** sequence (today's policy, preserved as an explicit discipline;
  write-then-check today, check-first after E91 Step 1). The *sequences themselves* are E91's deliverables —
  `x-alo`/`x-bnw` (trap) surfaced through the `Mach` vocabulary
  (`mach-alo`/`mach-bnw`), `x-galo`/`x-gbnw` (grow) lambda-wrapped inside the
  `Alloc` record (E91 SPEC decision #7: zero `Mach` changes); the grow stub +
  `mprotect` crossing are E90's (`nb-arena-fail`/`-commit`/`-grow` live in
  `sys-tal.chiral` since `686d51a`; the shared `"arena-grow"` stub body still
  owed). E81 owns only the
  **selection** (ELF defaults `growing`; JIT/tests pin `fixed-trap`) and the
  **byte-identity contract under a fixed discipline**.

## 2. Research

- **Reference class:** OURS (the `Mach` record-of-closures + the ported
  `specialize-singletons` monomorphizer are the whole precedent) + IMPL (Zig's
  allocator-as-parameter convention).
- **Key findings:**
  1. **`Mach` is the ISA-vocabulary seam, and allocation already rides it**
     (`lib/mach.chiral`): a record of ~36 first-class machine-op *function* fields,
     applied at each emit site as `((mach-ret m) src)`, with two conforming
     instances (`mach-x64`, `mach-listing`). Allocation is **already a `Mach`
     field** — `alo` (`mach.chiral:38`), filled by `x-alo` in the x64 instance
     (`mach-x64.chiral:805`); pre-E81 the emit site called `((mach-alo m) dst tag
     fields)` directly — since `d6ad519` it reads `((alo-cell disc) m dst tag
     fields)` (`emit-core.chiral:151`), never inlined. `Mach` is therefore the
     right home for ISA *primitives*, not for memory *policy* — the two are
     different axes.
  2. **The one correct shape: discipline as ISA-agnostic policy over the Mach
     vocabulary.** The discipline can't fold into `Mach` (that couples policy × ISA
     → each `{discipline}×{ISA}` becomes a full ~39-field `Mach` instance,
     combinatorial), and it can't be a per-ISA `Alloc` (that re-writes the region
     logic per backend — not orthogonal). The only design that keeps the axes
     orthogonal is a **separate `Alloc` record whose ops take the `Mach` and
     compose its primitives** — so `alloc-region` is written *once* and runs on
     x64 and listing alike. Profile selects `{Mach instance} × {Alloc instance}`
     independently. Where a discipline needs a primitive the ISA doesn't expose
     (region mark = save/restore `heapptr`), **extend the `Mach` primitive
     vocabulary** (E82's concern), never add a discipline-specific `Mach` field.
  3. **`specialize-singletons` removes BOTH seams** (`lib/specialize-
     singleton.chiral`, ported this session): a record-of-functions built exactly
     once has each field lifted to a fresh global, projectors rewritten to the
     lifted global, and the dict param q0-retyped so B1 erasure drops it. It runs
     over the singleton `Mach` today; the singleton `Alloc` is a second dict the
     same pass collapses. Byte-identity for `alloc-bump`: its `cell`/`bytes`
     fields are the bare Global refs `mach-alo`/`mach-bnw` (curried projector
     types match the field types exactly), so the Global-ref case rewrites the
     call site projectors straight to them — the emit site collapses back to
     `((mach-alo m) …)` = exactly the pre-seam site (the source site is
     `((alo-cell disc) m …)`, `emit-core.chiral:151`). No inline step
     needed; the byte-identity obligation is met by the currying match.
  4. **`x-alo` (`lib/mach-x64.chiral`) is the x64 alloc primitive the policy
     composes:** `a-rel ldheap heapptr` → `a-bytes` (store-tag + fields + advance
     rcx) → `a-rel cmpheap heapend` → `a-bytes x-trap` (jbe+2 ; ud2) → `a-rel
     stheap heapptr`. RIP-relative through `a-rel`; the `ud2` is the arena alarm.
     A region discipline's `region-enter`/`exit` will compose *new* x64 primitives
     (save/restore the heapptr cell) the same way — added to Mach, not to Alloc.
  5. **Zig** (IMPL) validates the shape — caller decides strategy by passing an
     allocator — but chirality's version is *typed + erased*: the discipline dict is
     q0-retyped by specialize, zero runtime cost, unlike Zig's runtime vtable.

## 3. Conventional (other-language) approach

Zig threads an allocator as an ordinary runtime value; the caller picks the
strategy:

```zig
fn buildNode(a: std.mem.Allocator, tag: u32, fields: []const u64) !*Node {
    const n = try a.create(Node);   // vtable dispatch through `a` at runtime
    n.tag = tag; n.fields = fields;
    return n;
}
// caller: buildNode(arena.allocator(), ...) vs buildNode(gpa.allocator(), ...)
```

- **Assumptions it bakes in:** the allocator is a **runtime** value — every
  `a.create` is an indirect call through a vtable, paid on every allocation; the
  choice is dynamic, invisible to the type system, and cannot be proven away. The
  discipline is configuration, not a checked conformance. (chirality's *current* value
  heap already routes allocation through the `Mach` `alo` field — the allocation
  *site* is seam'd — but there is only the one bump behavior and no discipline
  *dimension* (region/reuse/drop) to choose among.)

## 4. The chirality idea

- **Chirality features in play:** the `Mach`-style record-of-closures seam; QTT q0
  erasure (specialize q0-retypes the dict params so B1 erasure drops them);
  `specialize-singletons` (the pass, not the programmer, removes the seam — P4); "conformance, not configuration"
  (modularity principle).
- **The reframing:** two orthogonal seams. **`Mach`** = the ISA vocabulary (how to
  emit each primitive, incl. the `alo` cell-alloc and — from E82 — save/restore
  `heapptr`). **`Alloc`** = the memory *policy* (when to allocate / mark / restore
  / reuse / drop), written as ISA-agnostic ops that take the `Mach` and compose its
  primitives. The emit chain threads both as ordinary dict params (`(=> Mach
  Alloc …)`, `emit-core.chiral:146` — the dicts are *used*, so they cannot be q0
  at the source; `specialize-singletons` q0-retypes them after its rewrite, and
  B1 erasure then drops them); the pre-seam `((mach-alo m) …)` became
  `((alo-cell disc) m …)`. `alloc-bump`
  delegates `alo-cell` straight to `mach-alo` and no-ops region/drop, so
  `specialize-singletons` (run before `closconv-sig`) collapses the `Alloc`
  singleton just as it does `Mach` — its Global-ref case rewrites the manual
  projector straight to the bare `mach-alo` Global that fills the field, and
  the saturated call `(mach-alo m …)` is identical to today's site → **byte-
  identity**. Because the policy is expressed over the vocabulary, `alloc-region`
  (E82) is one instance that runs on *every* ISA — the composability the arc wants.
- **Discipline is a compile parameter, not a runtime switch (S17-E).** Which
  `Alloc` instance a build compiles under is fixed **once**, where the profile
  assembles the `{Mach} × {Alloc}` product — never a value the emitted program
  branches on. The ELF profile supplies `alloc-growing`; the JIT and the
  differential test floors pin `alloc-fixed-trap` (until E89-EXT/S17-D decides
  whether the JIT's `_map_rw` adopts reserve-commit). Because each build picks
  exactly one, `specialize-singletons` still collapses the per-build singleton,
  so a *growing* build pays no more indirection than a *trap* build did.
- **Byte-identity is discipline-parametric (E81's standing claim, re-cast).**
  Under a **fixed** discipline the emitted bytes are a deterministic function of
  the source: two compiles under `alloc-fixed-trap` agree byte-for-byte, and two
  under `alloc-growing` agree byte-for-byte — selection smuggles in no
  nondeterminism. **Switching** disciplines legitimately changes bytes (a growing
  image carries `jbe`/`call arena-grow` where a trap image carries `ud2`); that is
  the discipline doing its job, not a regression. (Orthogonally, E91's Step-1
  check-first *reorder* is a one-time expected byte-diff → refixpoint, owned
  there — a change to the trap sequence itself, distinct from the discipline
  switch.)
- **What chirality makes impossible here:** a discipline choice **cannot leak into
  runtime cost** (erased + specialized → zero indirection, unlike Zig's vtable);
  you **cannot add a discipline that isn't a conforming instance of the frozen
  `Alloc` op set** (no "general-purpose allocator knob"); and policy **cannot be
  coupled to an ISA** — a discipline is written once against the `Mach` vocabulary,
  so `{ISA}×{discipline}` never becomes a combinatorial set of hand-written records
  (the growing instance's lambda-wrapped `x-galo`/`x-gbnw` is the one resolved,
  contained exception — E91 SPEC decision #7).

## 5. Chirality example (fleshed)

The clear-cut example — real surface syntax, copy-and-modify ready.

```chirality
; ── the POLICY seam: a frozen record of memory-discipline ops ───────────
; Orthogonal to Mach. Mach = ISA vocabulary (how to emit each primitive);
; Alloc = policy (WHEN to alloc/mark/restore/drop). Every op TAKES the Mach
; and composes its primitives, so an instance is ISA-agnostic — one
; alloc-region runs on x64 AND listing. Ops return (List Asm) the emitter splices.
; Manual projectors (alo-cell, alo-bytes, alo-renter, alo-rexit, alo-drop)
; extract the fields; projector names differ from the field names below.
(data Alloc ()
  (alloc
    (cell   (-> Mach I64 I64 (List I64) (List Asm)))   ; m dst tag fields -> cell
    (bytes  (-> Mach I64 I64 (List Asm)))              ; m dst len -> byte cell
    (renter (-> Mach I64 (List Asm)))                  ; m mark-slot -> save heapptr
    (rexit  (-> Mach I64 (List Asm)))                  ; m mark-slot -> restore heapptr
    (adrop  (-> Mach I64 (List Asm)))))                ; m src -> release a cell

; ── the first conforming instance: today's behavior, exactly ────────────
; cell/bytes delegate to the ISA's alloc primitives as BARE Global refs
; (mach-alo/mach-bnw are ordinary projectors whose curried type matches the
; field types — no inline step needed). specialize-singletons' Global-ref
; case rewrites call sites straight back to ((mach-alo m) …) → byte-identity.
; renter/rexit/adrop are no-ops (bump never reclaims).
(def alloc-bump Alloc
  (alloc
    mach-alo                                    ; delegate to ISA cell-alloc (bare Global ref)
    mach-bnw                                    ; delegate to ISA byte-alloc (bare Global ref)
    (lam (m slot) (the (List Asm) nil))         ; renter: no-op
    (lam (m slot) (the (List Asm) nil))         ; rexit:  no-op
    (lam (m src)  (the (List Asm) nil))))       ; adrop:  no-op

; ── the call site: emit-core threads BOTH dicts as ordinary params ──────
; m already threaded; disc is the sibling. The dicts are USED in the body, so
; they are unrestricted at the source; specialize collapses both singletons —
; its Global-ref case rewrites alo-cell (a manual projector extracting the
; `cell` field) straight to mach-alo (the bare Global that fills that field),
; so ((alo-cell disc) m …) emits exactly what ((mach-alo m) …) did — and then
; q0-retypes the dead dict params so B1 erasure drops them.
(declare emit-con (-> Mach Alloc I64 I64 (List I64) (List Asm)))
(def emit-con
  (lam (m disc dst tag fs)
    ((alo-cell disc) m dst tag fs)))  ; was: ((mach-alo m) dst tag fs)

; … the rest of the emit chain gains the same `disc Alloc` seat beside its
;   existing `m Mach`; the compiler's profile supplies {mach-x64} × {alloc-bump}. …
```

- **Knobs to modify:** the `Alloc` op set (adding a discipline = a new
  `(def alloc-<name> Alloc …)` written *once* against the `Mach` vocabulary, never
  a new call-site branch and never per-ISA); which `{Mach}×{Alloc}` pair the
  profile supplies (E85 makes this per-phase/per-runtime). E82/E83/E84 each fill in
  `renter`/`rexit`/`adrop` by composing `Mach` primitives.
- **Deliberately omitted:** the region mark/restore *bodies* (E82 — bump's are
  no-ops; E82 also *adds* the save/restore-`heapptr` primitives to `Mach`),
  reuse-token plumbing (E83), destination-passing (E84), and the profile wiring
  that selects a pair per phase (E85). E81 is only the seam + the
  behavior-preserving `alloc-bump` instance.

### The S17-E extension — `growing` as a second discipline beside `fixed-trap`

The seam above shipped with **one** instance (`alloc-bump`). S17-E lands the
**second**, proving the dimension carries more than one policy. `alloc-bump` is
renamed `alloc-fixed-trap` (its name now states its *exhaustion policy* — trap on
overflow, today's behavior), and `alloc-growing` joins it. Both are `(alloc …)`
values; they differ only in which alloc sequences their `alo-cell`/`alo-bytes`
select — `mach-alo`/`mach-bnw` (the `Mach` projectors → `x-alo`/`x-bnw`, `ud2` on
exhaustion) vs `x-galo`/`x-gbnw` **lambda-wrapped inside the record**
(`jbe`-to-shared-grow-stub; E91 SPEC decision #7 resolved lambda-wrapping over
new `Mach` fields — zero `Mach` changes, the x64-coupling of the *growing
instance* accepted since `specialize-singletons` can't inline through a lambda
anyway). Those sequences, the shared `"arena-grow"` stub, and the
`nb-arena-grow` `mprotect` crossing are **E91's and E90's** deliverables
(per-site `jbe`+retry = E91, unimplemented — `x-alo`/`x-bnw` still run
write-fields-then-check today, the check-first reorder is E91 Step 1; stub glue
+ crossing = E90, crossings live since `686d51a`, stub body still owed) — E81
only *names* and *selects* them; it does not redesign the sequences.

```chirality
; alloc.chiral — TWO conforming instances side by side: trap over the Mach
; vocabulary, growing lambda-wrapping the x64 sequences (E91 SPEC decision #7).
; region/drop stay no-ops for both (bump-family disciplines never reclaim); they
; differ only in the exhaustion policy their cell/bytes primitives encode.

; the trap discipline: today's alloc-bump, renamed for its policy. Its cell/bytes
; select the ud2-trap Mach primitives (write-then-check today; E91 step 1
; reorders them to check-first).
(def alloc-fixed-trap Alloc
  (alloc
    mach-alo                                  ; x-alo, ud2 on overflow (check-first after E91 step 1)
    mach-bnw                                  ; x-bnw, ud2 on overflow (check-first after E91 step 1)
    (lam (m slot) (the (List Asm) nil))       ; renter: no-op
    (lam (m slot) (the (List Asm) nil))       ; rexit:  no-op
    (lam (m src)  (the (List Asm) nil))))     ; adrop:  no-op

; the growing discipline: cell/bytes LAMBDA-WRAP the growing x64 sequences
; (E91 SPEC decision #7: no new Mach fields; the wrap ignores m — the growing
; instance is x64-coupled by that resolved decision). The sequences replace the
; ud2 with `jbe`-to-shared-grow-stub + retry (E91 step 2). The stub body + the
; mprotect crossing it calls are E90's — referenced by name.
(def alloc-growing Alloc
  (alloc
    (lam (m dst tag fs) (x-galo dst tag fs))  ; check-first x-galo, jbe->"arena-grow"+retry
    (lam (m dst len)    (x-gbnw dst len))     ; check-first x-gbnw, jbe->"arena-grow"+retry
    (lam (m slot) (the (List Asm) nil))       ; renter/rexit/adrop unchanged — same no-ops
    (lam (m slot) (the (List Asm) nil))
    (lam (m src)  (the (List Asm) nil))))

; ── selection: fixed ONCE where the profile assembles {Mach} × {Alloc} ──────
; The discipline is a COMPILE parameter, not a runtime branch. ELF defaults to
; growing (self-hosting arena that commits its own pages); the JIT and the
; differential test floors pin fixed-trap. Same {Mach}, different {Alloc}.
(def alloc-for-elf  Alloc alloc-growing)      ; ELF image: grow on exhaustion
(def alloc-for-jit  Alloc alloc-fixed-trap)   ; JIT / tests: trap (pin today's policy)
; … the emit chain's `disc Alloc` seat is filled with whichever the profile
;   chose; specialize-singletons collapses that per-build singleton either way. …
```

- **Byte-identity, re-verified (E81's standing claim, discipline-parametric):**
  compiling twice under an *unchanged* discipline stays program-level
  byte-identical — `alloc-fixed-trap` self-reproduces byte-for-byte, and so does
  `alloc-growing`. *Switching* fixed-trap → growing legitimately changes bytes
  (`ud2` sites become `jbe`/`call arena-grow`); that is the discipline, not drift.
  (E91's Step-1 check-first reorder is a separate one-time byte-diff → refixpoint,
  owned there.) The rename `alloc-bump` → `alloc-fixed-trap` is itself name-only:
  global names key the label/offset side of the emission (`emit` returns
  `(Pair Bytes offsets)`; no name string enters the image), so a fixed-trap
  build is byte-identical across the rename.
- **Reference, don't redesign:** `x-galo`/`x-gbnw` (the growing sequences),
  the `"arena-grow"` shared stub, and `nb-arena-grow` (the `mprotect` crossing)
  are E91/E90 interfaces. E81's extension is exactly the two `(def alloc-… Alloc)`
  values above plus the selection point.

## 6. Use / modify notes

- **Lands in (base E81, SHIPPED):** `scaffold/lib/alloc.chiral` (the `Alloc`
  policy record + its projectors + the first instance) — kept separate from
  `lib/mach.chiral` because policy and ISA are the two orthogonal axes;
  `lib/emit-core.chiral` (call sites thread `disc Alloc` beside the existing
  `m Mach`, unrestricted — `(=> Mach Alloc …)`, `emit-core.chiral:146`; specialize
  q0-retypes them); `lib/compile-front.chiral` (`specialize-singletons` already runs
  before `closconv-sig` and collapses the `Alloc` singleton as it does `Mach`).
  Built in commit `d6ad519`, byte-identical.
- **Lands in (S17-E extension):** `scaffold/lib/alloc.chiral` in place — rename
  `alloc-bump` → `alloc-fixed-trap` and add `alloc-growing` (the two `(def …
  Alloc)` values in §5); plus the profile-selection site where `{Mach} × {Alloc}`
  is assembled (ELF → `alloc-growing`, JIT/tests → `alloc-fixed-trap`). **Live
  state (2026-08-09):** the caller side landed ahead of the defs — `emit-x64.chiral`'s
  `emit`/`emit-truthful`/`emit-param` (lines 24/27/33, the live `{x64}×{Alloc}`
  assembly site, consumed by `compile-emit.chiral:153` for the ELF path and by the
  py `NativeBackend` `DISCIPLINES` table for the JIT/tests) already reference
  `alloc-fixed-trap` (`be3df92`), and the tests expect all four new names
  (`f2632c1`), while `alloc.chiral` line 43 still defined `alloc-bump`; today all three
  wrappers pin ONE discipline for every floor, so the per-floor split is part of
  this landing (open question 3 pins the exact wiring). `x-galo`/`x-gbnw`
  (lambda-wrapped per E91 SPEC decision #7) and the `"arena-grow"` stub body are
  E91/E90 landings this extension only references — not yet built;
  `nb-arena-fail`/`-commit`/`-grow` are live in `sys-tal.chiral` since `686d51a`.
- **Conformance target (base):** **byte-identity.** `compile-all` under the
  first instance produces the *exact same ELF bytes* as the pre-seam compiler;
  the test suite and the byte-identity test pass unchanged. Verify by rebuilding
  B1 and diffing against the committed `build/B1` (same blob → same bytes).
- **Conformance target (S17-E):** **discipline-parametric byte-identity.** Fix
  the discipline and the bytes are deterministic — two compiles under
  `alloc-fixed-trap` agree, two under `alloc-growing` agree. Switching flips
  `ud2` sites to `jbe`/`call arena-grow` (a legitimate change). The growing
  discipline's real soak is the self-compile itself (256 KiB → ~9 mprotect
  doublings → ~128 MiB peak, fixpoint byte-identical) — that soak and the
  failure-injection goldens are E91/E90/S17-F's gate, not this seam's.
- **Design decision (RESOLVED — the discipline shape):** a **separate `Alloc`
  policy record whose ops take the `Mach` and compose its primitives**, threaded
  orthogonally to `Mach`. Not folded into `Mach` (that couples discipline × ISA
  into combinatorial full-record instances) and not per-ISA (that re-writes region
  logic per backend). This is the only shape that keeps `{ISA} × {discipline}`
  independently selectable — the arc's composability requirement. Instances are
  ISA-agnostic in the norm (one `alloc-region` for all backends); the growing
  instance is the resolved exception (E91 SPEC decision #7 lambda-wraps
  `x-galo`/`x-gbnw` — x64-coupled, accepted). ISA-specific alloc asm stays
  in `Mach` primitives (`alo`, `bnw`, and E82's save/restore-`heapptr`).
- **Open questions (for the spec, not this pre-run):**
  1. **Byte-identity via inline — RESOLVED.** The shipped implementation
     (`commit d6ad519`) uses bare Global refs (`mach-alo`/`mach-bnw`) whose
     curried types match the `cell`/`bytes` field types exactly, so
     `specialize-singletons`' Global-ref case rewrites the call site straight to
     `(mach-alo m …)` — no inline step required. The byte-identity obligation is
     met by the currying match, already verified.
  2. `region-enter`/`region-exit` signature — does the saved mark need a stack
     slot, a dedicated cell, or a register, and what `Mach` primitive
     (save/restore `heapptr`) does E82 add to express it? (Moot for bump/E81 — its
     region ops are no-ops — but the `Alloc` op *type* is fixed here, so its shape
     must anticipate E82.)
  3. **(S17-E) The selection site.** Where exactly the profile fixes
     `{Mach} × {Alloc}` per floor (ELF vs JIT/tests), and whether the JIT's
     `_map_rw` adopts reserve-commit or pins `fixed-trap` — E89-EXT/S17-D decides
     the JIT half; the SPEC pins the wiring point in the profile.
- **Related:** [[E82-alloc-region]] (the A4 unblock, first non-trivial instance),
  [[E83-alloc-reuse]] (FBIP), [[E84-alloc-dps]] (destination-passing),
  [[E85-alloc-compose]] (per-phase/per-runtime composition); the S17-E siblings
  this extension composes: [[E91-growing-allocator]] (the check-first reorder +
  `x-galo`/`x-gbnw` + the per-site `jbe`-to-shared-stub — the sequences
  `alloc-growing` selects; unimplemented), [[E90-arena-grow-crossing]]
  (`nb-arena-grow`: the `mprotect`-doubling crossing + the shared `"arena-grow"`
  stub; crossings live since `686d51a`, stub body owed),
  [[E89-arena-init]] (reserve-commit startup that establishes the arena the
  growing discipline commits into); and the precedents: the `Mach`
  record-of-closures + `specialize-singleton` monomorphizer. Arc authority:
  `.planning/MEMORY-DISCIPLINE-ARC.md`; extension authority:
  `.planning/SCRIBA-UNBLOCK-MAP.md` §"S17 makeup" (S17-E).
