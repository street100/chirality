---
element: E166
slug: mach-c
title: A conforming `Mach` that emits C, and the external-compiler DDC leg it unlocks
kind: BUILD-PROPER
example: examples/E166-mach-c.md
status: implemented
updated: 2026-08-24
---

# E166 SPEC — `mach-c`, and the external-compiler DDC leg it unlocks

> ⚑ **TRIAGE 2026-09-04 — DEAD.** 0 of 7 steps are executable at HEAD. The
> `Mach`-to-C backend was cut 2026-09-01; the SPEC records a build that no
> longer exists. Bucket and evidence: `records/spec-tier-triage.md`. This file
> was not rewritten and its `status:` was not changed.

> ⚑ **THE C BACKEND WAS DROPPED ON 2026-09-01** (`d8bcec5`, `d0c5dd5`). Every
> file this contract builds is deleted: `lib/lowering/c/{mach,assemble,emit}.chiral`,
> `prog/compiler-c.prog`, and the four `e166_*` fixtures. **Nothing below is
> rewritten.** A SPEC is the record of a contract that was signed and met, and
> editing it to match today would destroy that record.
>
> The reason is the criterion. The leg shared `compile-front` and `compile-back`
> whole with the canonical instance and differed only at emit, which makes it a
> second **target** under one formulation. Self-verification here goes through N
> semantically distinct judgment cores that must agree on *different
> formulations*; three encodings of one rule set are worth nothing, and one
> encoding emitted twice is less. See `docs/decisions/decision-self-verification.md`.
>
> The gates below all ran and all passed while the leg stood. They cannot be
> re-run: their subject is gone.
>
> ⚑ **This banner shifted every line below it by +20.** The four places citing
> `:556` for the could-never-fail mutant sentence are repointed at the measured
> line, **579**; that citation was already off by three before the banner.

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** a third conforming `Mach` value, `mach-c`, renders the
  abstract codegen ops as C-as-portable-assembly; a C-mode assembler turns the
  flat `Asm` stream into a compilable translation unit; a freestanding shim (89 C code lines +
  27 asm, one trusted drop counted at its sum) supplies the heap, the one
  crossing, and the ops C spells differently than chirality does; and a build script drives
  **`chirality source → C → gcc *or* ccomp → chirality-bin-c`**, which is then **admitted** to the DDC
  quorum by observable conformance and **convicts** by bit-identity against
  `chirality-bin`. `ddc.chiral` gains `ddc-legc`, giving diverse double-compilation a
  second leg whose `toolchain` provenance is genuinely disjoint — the leg that
  must stand before the Python leg is deleted.
- **Non-goals:** the canonical instance still compiles through `mach-x64`
  (`docs/decision-backend.md`, author scope note 2026-08-23) — nothing here
  proposes shipping chirality through C. No CompCert in the delivered leg (gcc is
  the committed toolchain). ⚑ *Amended 2026-08-25, and this non-goal is now
  RETIRED rather than qualified: `ccomp 3.17` builds here, the shim split landed
  (`aa055ec`), and CompCert is the leg's DEFAULT compiler in the committed tree.
  What survives of the non-goal is decision 9's constraint — never distribute a
  CompCert-built artifact — and the honest limit that CompCert proves C→asm, not
  chirality→C.*
  No optimization (`x64-peep` has no C analogue and needs none). No ELF emission
  on this target (the C toolchain links). No leg-*running* orchestration beyond
  one script — `ddc.chiral`'s header scopes that out and this run honours it.
  **No change to `emit-core.chiral`**: that is conformance gate G0, not a wish.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E166 postdates the map snapshot, so it is
  **BUILD** throughout. Adjacent authority: `banks/verification` Shard 8 records
  the C legs as **DESIGN, not built**; Shard 4 records the DDC compare core as
  **BUILT (E53, CONFORMS, `CONFORMANCE-MAP.md:45`)** with leg 1 terminal.

- **Live code this composes with — do NOT respec any of it:**
  - `lib/mach.chiral` (137 L) — `Mach`, **37** function fields, accessors
    `mach-pro … mach-gbnw`. Only `stp`, `lda`, `fjc`, `clb` are `=>`; the rest
    are `->`. This is the conformance contract; it does not change.
  - `lib/mach-listing.chiral` (136 L) — the existence proof and the template:
    text into `a-bytes`, `e-noenc` on every relocation, all 37 arms in 136 lines.
    Defines top-level `line`, `r`, `noenc`, `slots`, `lbl-list`, `lcat`,
    `l-args`, `listing`.
  - `lib/emit-core.chiral` (573 L) — `emit-program` / `emit-data` /
    `emit-with` / `emit-with-peep` / `emit-with-param`, all parameterised over
    `(Mach, Alloc)`. **`(mach-sys m)` has exactly ONE call site in the whole
    codegen, `:167`.** Untouched by this element.
  - `lib/emit-x64.chiral` (**14 lines**) — the wiring precedent, and the single
    most useful discovery in this bundle: selecting a target is already a
    ten-line module, `(emit-with-peep x64 alloc-growing x64-peep fns lits)`.
  - `lib/asm-reloc.chiral` — `Asm` = **four** constructors `a-bytes` / `a-label` /
    `a-rel` / **`a-align`**, `EncTag` (14 ctors incl. `e-noenc`), `place`,
    `apply-enc`, `materialize`, `assemble`.
  - `lib/alloc.chiral` (39 L) — the **`Alloc`** seam, a *second* record-of-
    functions the example never mentions, with exactly one instance
    `alloc-growing`.
  - `lib/ddc.chiral` (120 L) — `Prov` / `Leg` / `DdcR` / `LegOut`, `bytes=?`,
    `fixpoint=?`, `leg2-disjoint?`, `prov-disjoint?`, `ddc-compare`,
    `ddc-leg0`:111, `ddc-leg1`:112, `ddc-verdict-code`:114.
  - `lib/prelude.chiral` — `Op` (15 ctors, `:36-39`), `str-cat`:83,
    `i64->str`:84.

- **⚑ True delta, and it is a different shape than the example assumed.**
  Three facts measured from the bundle move the plan:

  1. **`mach-c` and `mach-x64` CANNOT COEXIST IN ONE BLOB.**
     `specialize-singleton.chiral:78-84`: *"a fn-bearing type built >1 time
     returns `none` here, so it is not specialized → it threads as a runtime
     fn-valued dict → the lowering path er-skips it → a visible compile failure.
     This is the correct behavior: two distinct fn-bearing instances (e.g. two
     Alloc disciplines) cannot coexist in one blob, and the pass must NOT
     silently pick one (the `16d6d1a` count>=1 relaxation did exactly that — an
     order-dependent silent miscompile; reverted)."* `test_alloc_seam.py:83`
     guards it. So E166 is **a second blob, not a second import** — see
     decision 1. The good news is that this is also exactly what the DDC
     construction wants, and the example's Choice 4 survives intact (below).
  2. **The target-selection seam already exists and is 14 lines.**
     `emit-c.chiral` is the analogue of `emit-x64.chiral`. It cannot call
     `emit-with-peep` (which hardwires `assemble`), so it inlines that body with
     `c-assemble` substituted — ~12 lines, and `emit-core` stays byte-identical.
  3. **`Alloc` is a second conforming interface, and it is the right home for
     the fixed-vs-growing choice** — not the `galo`/`gbnw` `Mach` arms, which is
     where the example put it. `Alloc` never received the interface/instance
     split `Mach` has (`mach.chiral` + `mach-x64` + `mach-listing`): its type,
     its five accessors and its single instance all live in one 39-line file,
     and that file carries `(import "mach-x64")` at `:8`.
     **⚑ This is not optional to fix. `emit-core.chiral:12` imports `alloc`, so
     ANY blob containing `emit-core` transitively pulls in the `x64` instance
     and trips fact 1. Blob A needs `emit-core`. Breaking that import is a
     precondition for E166 existing at all**, which is why Step 0 is now a
     structural split rather than the speculative one-line deletion the first
     draft proposed (author call, 2026-08-24: *"go flexible for canonical and
     tests just run with an instance using fixed"*).

  Net new surface: **4 new files (~430 L chirality + ~70 L C), 1 one-line edit,
  1 new `ddc.chiral` constant, 1 new native phase.** `emit-core.chiral`,
  `mach.chiral`, `mach-x64.chiral`, `mach-listing.chiral`, `asm-reloc.chiral`
  unchanged.

- **The DDC construction, re-derived against fact 1 (it still works):**
  B1 is a native binary carrying its own `mach-x64`; the blob it reads is
  separate. So — blob **A** = the compiler emitting through `mach-c` (contains
  `mach-c`, no `mach-x64`). `B1 < A` → `chirality-bin-emit-c`, a native x86-64 binary
  that emits **C**. Feed it the ordinary compiler blob **B** (which contains
  `mach-x64`) → C source for the compiler → gcc → **`chirality-bin-c`**, whose own
  codegen is `mach-x64`. Therefore `chirality-bin-c < B` and `chirality-bin < B` are two
  x86-64 artifacts of the *same emitter* and **are** byte-comparable.
  **Admission applies to `chirality-bin-c`; conviction to what it emits.**

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Can `mach-c` live beside `mach-x64`, or does it need its own blob? | **RESOLVED — its own blob** | Forced, not chosen: `specialize-singleton.chiral:78-84` returns `none` for a fn-bearing type built >1 time, producing "a visible compile failure", and explicitly refuses to pick one silently (reverted commit `16d6d1a`). `test_alloc_seam.py:83` pins it. New root `compile-driver-c`; blob A never imports `mach-x64`. |
| 2 | Does `c-assemble` sit beside `assemble` in `asm-reloc.chiral`, or its own file? | **RESOLVED — own file** | `asm-reloc.chiral` is target-independent today (its own header: *"kept a-rel target-independent"*). Putting a C mode in it makes a general module target-aware — `BUILD-ORDER.md` §1 A1, a thing living below the level of generality that owns it. New `lib/c-assemble.chiral`. |
| 3 | Fixed-vs-growing heap: baked into `mach-c`, or a selectable discipline? | **RESOLVED — a selectable `Alloc` instance (author, 2026-08-24)** | Canonical stays `alloc-growing`; the C leg runs `alloc-fixed`. The seam already exists and merely lacked the interface/instance split `Mach` has. Policy in a named value beats policy smeared across two `Mach` arms — and it satisfies `specialize-singletons` by construction, one instance per blob. `mach-c`'s `galo`/`gbnw` arms become unreachable under `alloc-fixed`, so they render as `alo`/`bnw` plus the emitted bounds check: total, honest, never invoked. |
| 3b | Where does the fixed-heap bounds check `exit` from, given `galo`/`gbnw` return `(List Asm)` and cannot cross? | **RESOLVED — it never crosses** | The arm emits a *call*; the trap lives in the shim. This is `mach-x64`'s own idiom: `:175-185` — *"divisor 0 traps deliberately (ud2, native's fatal-error idiom until the effect floor lands)"*. `m_trap()` is `ud2`. No effect row, no port, arms stay `->`. |
| 4 | Is `chirality-bin-c`'s admission vector the existing suite or a smaller named vector? | **RESOLVED — the native behavioural suite** | `docs/testing-floors.md` makes `chirality test-native` the **primary correctness gate**, zero Python: nine phases, 135 assertions + 81 roots, exit 0. Admission = *"observable conformance … on an input vector"*; the gating vector we already trust is that suite. Inventing a second vector would give admission weaker provenance than the gate it feeds. |
| 5 | Retirement sequencing against S12 / rung-1 | **RESOLVED — admit before delete, and it is a hard ordering** | `banks/verification` C6 + Shard 4: `ddc-bad-quorum` refuses a quorum below two disjoint legs, so deleting leg 1 before `ddc-legc` is admitted leaves **no quorum at all**. G3 (admission) is the precondition on the S12 row, not a suggestion. |
| 6 | chirality name → C identifier mangling (raised by the example audit) | **RESOLVED — total injective escape, parsed once** | chirality labels carry `-`, and `closconv.chiral:1097-1098` generates `$clo0`/`$apply0`; neither is an ISO C identifier. Injectivity is load-bearing (two names colliding = a silently miscompiled leg). Escape `_`→`_U`, `-`→`_D`, `$`→`_S`, prefix `m_`; injective by construction because the escape character is itself escaped. Lands in `c-assemble.chiral` beside `CLbl` — one boundary pass, `docs/pattern-boundary-sums.md`. **⚑ AMENDED by Step 1 (2026-08-24, built `de5d529`): those three escapes are NOT total.** The live def-name alphabet in `scaffold/lib` includes `>`, `=`, `?`, `*` — and **`offs->tree` is a real, called def at `asm-reloc.chiral:68`** (3 uses), which the three-escape scheme renders `m_offs->tree`, not a C identifier at all. A `_x<two lowercase hex digits>` fallback now covers every remaining non-`[A-Za-z0-9]` byte. Injectivity survives: `x ∉ {U,D,S}`, the hex run is always exactly two digits, and `_` stays escaped, so the encoding decodes uniquely. |
| 7 | Where `mc-line` / `mc-lcat` / `mc-r` should live | **DEFERRED → E154** (minted: catalog 1 row, ledger 4 refs — verified by this audit, no phantom dep) | They are `mc-`-prefixed only because emitted labels share one flat namespace and `mach-listing` owns `line`/`lcat`/`r`. `BUILD-ORDER.md` §1 A2 catalogues the mechanism; **E154** (per-module label mangling at lowering) is the minted home. Post-E154 the answer is a shared text-emit shelf. No phantom dep — E154 has catalog + ledger rows. |
| 8 | `a-align` — the fourth `Asm` constructor the example never mentions | **RESOLVED — drop it, totally** | Only `mach-x64.chiral:559` emits `(a-align 4096)` (page alignment for `mprotect`); `mach-c` emits none, and C alignment is the C compiler's job. `c-assemble` still `case`s it exhaustively and emits nothing — coverage-checked, not defensive. |
| 9 | CompCert licensing (`banks/verification` §5 item 6) | **RESOLVED by the author, 2026-08-24** | INRIA NC restricts *use of CompCert* and carries **no output restriction**; a one-off comparison run is *"evaluation"* on its face. gcc is the default leg. ⚑ *`Prov ("c" "gcc-12" …) → ("c" "compcert-3.x" …)` was recorded here as a **one-line swap**; MEASURED 2026-08-25, it is the one line **plus two changes**: `scaffold/rt/chirality-rt.c`'s three GNU-asm constructs must move into a `.s` (CompCert refuses local register variables, file-scope `__asm__`, and the `"a"`/`"D"`/`"S"`/`"d"` constraints outright), and `ddc-c-leg.sh:94`'s `CFLAGS` must become per-compiler. With both applied out of tree the leg's 9 gates pass and G4 convicts byte-identical at the same 1,077,624 B, so the claim was right about the OUTCOME and wrong about the COST. `mach-c`'s generated C needs nothing.* chirality's own BUSL-1.1 is untouched — CompCert is never vendored, linked, or redistributed. **Constraint carried into Step 5: never distribute a CompCert-built artifact.** |
| 10 | String-building cost — does rendering a whole compiler's C through `str-cat` need a `Bytes` builder? | **DEFERRED — to a measurement inside Step 5, with a named fallback** | Not a design question; the example says so (*"a measurement, not a guess"*). Checkpoint: if `chirality-bin-emit-c < B` exceeds 120 s or 2 GiB, switch `mc-line` to accumulate `Bytes` via `bcat` instead of `str-cat`. Recorded so a slow first run is a known branch, not a surprise. **⚑ AMENDED by Step 1: `str-cat` is not the only cost risk, and the second one has a measured precedent.** `c-classify` resolves each label against the emitted fn-name list with a linear `ca-member?`, so classification is **O(labels × fns)** — and `asm-reloc.chiral:63-66` records that *exactly* this shape (*"~15k relocations against ~6k labels … the emit's dominant cost (~10^8 interpreted string compares)"*) is what forced `place` onto an **E27 ordered `Map`**. A self-compile through `c-assemble` hits the same wall. Same fix (build a `(Map Str I64)` once and thread it), but it moves `c-classify` off the `(List Str)` Step 1 delivers — so it is a Step 5 measurement branch, not a Step 1 defect. **⚑ A THIRD branch, from Step 2:** `mc-c-byte-list` renders one literal byte per `str-cat`, making the literal pool **O(bytes²)**. Same fix, same gate. Three named branches now, so a slow first self-compile is a diagnosis rather than a mystery. |
| 11 | **What the memory divergence IS** — `mach-x64` grows, `mach-c` cannot | **RESOLVED — it is the category boundary, and it belongs visible (author, 2026-08-24)** | Choice 4 requires *"`mach-c` must not accept programs `mach-x64` refuses"*; the heap is the **inverse**, so programs exist that `mach-x64` accepts and `mach-c` refuses. **This is not a defect to engineer away — it is `docs/axis-typeability.md`'s axis showing up where it should.** `arena.chiral:1` already self-describes: *"category-C bridge: typed arena over mmap/mremap"*. Growth takes its memory from a syscall, so the cell "pointer" is an integer no theorem can follow — correctness rests on **evidence over an admitted hole (C)**, not proof. `alloc-fixed` is one static object indexed in bounds — correctness rests on **proof, one copy correct (A)**. The axis's own test decides it, not our preference. **So `testing-floors` Rule 1 has a second axis:** a differential covers what is below its branch point in the *pipeline*, and also what is inside its branch point in the **category**. The C leg covers the **provable fragment**; growing programs sit above that line and are governed by P5 — agreement between independent representations — which is what DDC already *is*. Scope, stated; not a gap confessed. **⚑ An earlier draft "fixed" this by capping `arena-grow` at a shared 4 GiB ceiling. That was wrong and was reverted (`16d3dce`):** it degraded canonical — took a real capability from the shipping compiler — so that a verification instrument's edge would stop showing. P5 says the opposite: *"where finite resources force a lower rung, the shortfall is a visible fact in the type, not a silent hole."* Capping manufactured the silent hole. Canonical keeps unbounded growth exactly as it is. **Per-blob is the right granularity** — not a concession to `specialize-singletons`, but because "is this program in the provable fragment?" is a whole-program property, not a per-call-site one. **Honest limit:** fixed is not *fully* A either — the kernel writes into `m_heap` through an address `m_bptr` handed out, outside any C-level theorem. That is **one named axiom** versus an unbounded provenance hole: a difference in kind, not degree. **Two instrumentation requirements survive independently of the reverted cap, because neither depended on it:** the shim reports its **high-water words vs `M_WORDS`** on exit, so the margin over the measured 313.1 MiB is a number that drifts visibly rather than an assumption; and the bounds trap **names the allocation** that blew it, as `mach-x64:1663` names its `>6 args` refusal. Re-measure before widening the leg's job beyond "compile one known program" — the 4 GiB reserve is sized against that job, not against chirality programs in general. |
| 11b | **Encoding the tier: index `Alloc`, wrap it, or neither** | **REJECTED — the invariant is already structural; no encoding is warranted (measured 2026-08-24, Step 0 dispatch)** | The SPEC previously resolved this as *"index `Alloc` as `(data Alloc ((0 c MemCat)) …)` so `emit-c` demands `mem-typed`"*. **Two measurements killed it, and the second is the one that matters.** ⑴ **It does not lower.** `((0 c MemCat))` is not surface syntax at all — `parse.chiral:479-493`'s `build-params` calls `extract-2`, wanting exactly `(P kind)`, and rejects a quantity with `bad data parameter (want (P kind))`. The unquantified `((c MemCat))` parses and type-checks, then dies at lowering: `specialize-singleton.chiral`'s `proj-idx` (`:99-118`) matches a projector as exactly one `t-lam`, and `_sp-rw` (`:120+`) rewrites exactly one application, so an index turns every accessor into a two-lambda chain that is never rewritten — `alo-cell: extern does not lower: body is not a lambda chain`. **Independent of the count>1 guard**; one instance still fails. Filed as a language GAP in `.planning/LANGUAGE-INVENTORY.md` §4 — no consumer, so not minted. ⑵ **Even if it lowered, it would be overhead.** Decision 1 already establishes that two `Alloc` instances cannot coexist in a blob — **measured**, mutant M2: a blob with both dies with `alloc-growing: extern does not lower: lambda stays upper`. Blob A imports `alloc-fixed` and not `alloc-growing`, so **there is no growing allocator present to wire by mistake**. An index would restate in the type what the module graph already makes unrepresentable: global principle 6's overhead (constrains nothing) reached via global principle 5's anti-pattern (a seam check over a structural invariant), on top of global principle 4's *modularity is conformance, not configuration* — `Alloc` is already a frozen interface with named instances, and a category index is a configuration axis bolted onto a conformance seam. **What replaces it:** the split itself (unindexed, proven green below), **G0b** re-aimed at the structural fact rather than a proxy for it, and the category recorded where claims live — a header line in each instance module citing `docs/axis-typeability.md`, with the reasoning in `banks/verification` Shard 8b. |

## 4. Change plan (ordered, commit-sized)

### Step 0 — split `Alloc` into interface + instances (NO index — see decision 11b)
- **Target:** `scaffold/lib/alloc.chiral` (shrinks), new
  `scaffold/lib/alloc-growing.chiral`, new `scaffold/lib/alloc-fixed.chiral`,
  `scaffold/lib/emit-x64.chiral` (one import line)
- **Change:** apply to `Alloc` the split `Mach` already has. **No index** — that
  was tried, measured, and rejected (decision 11b).
  ⚑ **This half is already PROVEN GREEN** (Step 0 dispatch, 2026-08-24, reverted
  per its stop condition): fixpoint `C1 == C2` byte-identical at 1,077,624 B ·
  native suite 9 phases / 135 `ok` / 0 failed / 81 roots, exit 0 ·
  `ledger-lint` clean A–O · **`emit-core.chiral` completely untouched.**

  ⚑ **No `MemCat` sum.** An earlier draft minted
  `(data MemCat () (mem-typed) (mem-bridge))` here to index `Alloc`. Decision
  11b rejects the index, and a sum with no consumer is worse than no sum — it
  reads as an enforced fact while enforcing nothing. The category is recorded as
  a **header line in each instance module** citing `docs/axis-typeability.md`,
  and the reasoning lives in `banks/verification` **Shard 8b**.

  | module | holds | imports |
  |---|---|---|
  | `alloc.chiral` | the `Alloc` type + `alo-cell`/`alo-bytes`/`alo-renter`/`alo-rexit`/`alo-drop`. **No instance, no index** (decision 11b). | `prelude`, `asm-reloc`, `mach` — **not `mach-x64`** |
  | `alloc-growing.chiral` | `(def alloc-growing Alloc …)` — canonical, `mach-galo`/`mach-gbnw`, `mremap` doubling. Header cites `axis-typeability`: **category C**, evidence over an admitted hole | **`alloc`** + `mach` |
  | `alloc-fixed.chiral` | `(def alloc-fixed Alloc …)` — the C leg, routing `cell`/`bytes` to `mach-alo`/`mach-bnw`. Header cites `axis-typeability`: **category A**, proof, one copy correct | **`alloc`** + `mach` |

  *(The `imports` column previously omitted `alloc` from both instance modules —
  that is where the `Alloc` type and the `alloc` constructor live, so the table
  as written did not resolve. Found by the Step 0 dispatch.)*

  `emit-core.chiral` keeps `(import "alloc")` and is **untouched — byte-identical,
  and that is now measured, not hoped.** It only ever uses the accessors, and
  `Alloc` is already a parameter of `emit-with*`.
  ⚑ **Why the earlier draft's "three signature rewrites, zero logic" was wrong,
  kept as the reason not to retry this:** `Alloc` appears **ten** times in
  `emit-core.chiral` (`:146, 200, 204, 353, 395, 524, 537, 556, 564, 570`), and a
  bare mention of an indexed tcon is a hard load error (`Alloc wrong number of
  type parameters`). Indexing would have required all ten signatures, ten lambda
  binders, ~20 internal call sites, and the two accessor applications at
  `:151`/`:163` — logic, not signatures — and the index could not even be named
  `c`, because `emit-instr` already binds `c` for the const-env. Off by more than
  3×, and it made G0 as originally written unachievable.

- **⚑ The prior deletion was a DIFFERENT thing — cite it so nobody re-collapses
  this.** `test_alloc_seam.py:75` records *"The old separate alloc-growing.chiral
  module (two-instance design) was deleted; specialize-singletons requires
  exactly one fn-bearing instance."* That was two instances **in one blob**.
  Interface/instance split with one instance **per** blob is not that, and the
  `mach` / `mach-x64` / `mach-listing` trio is the standing proof it is legal.
  Indexing by discipline is orthogonal (chirality already indexes `Grid`, `AllocR` at
  value-level). `test_alloc_seam.py`'s live assertions still pass: blob B keeps
  `alloc-growing` present and `alloc-fixed-trap` absent.
- **Why first:** decision 1 makes this the gate on everything else. If the `x64`
  instance cannot be kept out of blob A, `mach-c` cannot be lowered at all.
- **⚑ Expect the blob to byte-differ, and do not read that as a defect.** Moving
  a def between modules renumbers per-def indices. The W0-1 precedent measured
  exactly this shape — *"ELF same size, ~180K bytes differ (per-def index
  renumbering)"*. The fixpoint check is `B1`-compiling-`B1` (`C1 == C2`), which
  still holds; "before vs after differs" is not the check.
- **Size:** M. **⚑ Compiler source → self-hosting fixpoint check + full native
  suite required.**

### Step 1 — `lib/c-assemble.chiral`: the boundary pass
- **Target:** new file — `CLbl` sum, `c-mangle`, `c-classify`, `c-assemble`
- **Change:** `(data CLbl () (c-fn (n Str)) (c-local (n Str)) (c-lit (i I64)))`.
  Classify each `a-label` **once**, against the emitted function-name set, at
  the boundary — no arm downstream string-sniffs a name
  (`docs/pattern-boundary-sums.md`, standing directive). `c-mangle` implements
  decision 6. `c-assemble` consumes `(List Str)` (fn names) + `(List Asm)` and
  emits `Bytes`: `a-bytes` passes through; `a-rel` contributes only its **name**
  to the forward-declaration prologue; `a-label` becomes `}` + a new function
  signature, a C label, or a data symbol; `a-align` emits nothing (decision 8).
- **Size:** M (~100 L, up from the example's 80 — mangling was not costed).

### Step 2 — `lib/mach-c.chiral`: the 37-arm conforming value
- **Target:** new file — `mc-line` / `mc-lcat` / `mc-r` / `mc-a`, `COp`, `c-op`,
  `c-expr`, `c-bin-text`, `c-lda`, `c-args`, `c-sysargs`, `(def mc Mach …)`
- **Change:** adapt the example §5 snippet verbatim — it is post-audit and its
  every top-level form is paren-balanced. **37** arms, not 38.
  **⚑ One place the example is WRONG and must not be copied.** Its §2 finding 1
  says *"Only two of the 37 are effectful: `stp` and `lda`."* Measured against
  `mach.chiral` (`grep -oE '^\(def mach-[a-z]+ \(-> Mach \(=>'`): **four** are
  — `mach-stp`:66, `mach-lda`:68, **`mach-fjc`:118**, **`mach-clb`:122**. An
  implementer copying the example's claim would write `mach-c`'s `fjc` and `clb`
  arms as `->` and hit a type error. This audit's write surface is the SPEC
  alone, so the example still carries the error; **correct it before or during
  Step 2**, and treat this line as the authority meanwhile. All helpers
  `mc-`-prefixed (decision 7). Only `stp`/`lda`/`fjc`/`clb` are `=>`. Six ops
  stay infix (`band bor bxor eqi lti lei`); the other nine route to shim helpers
  because chirality I64 **wraps** and C's signed `+ - * <<` are UB on overflow.
  `jtb` is a `switch`, never a computed `goto` (GNU extension; CompCert refuses).
  `lda` reproduces `mach-x64.chiral:1663`'s >6-args refusal — the legs must accept
  the same language.
- **Size:** L (~250 L, against `mach-listing`'s 136 for the same 37 arms).

### Step 3 — `scaffold/rt/chirality-rt.c`: the entire C deliverable
- **Target:** new file (new directory `scaffold/rt/`)
- **Change:** the ~70-line freestanding shim — no libc, no headers, no GC.
  (1) one static heap. **⚑ DEFAULT CORRECTED to 1 GiB by Step 3 (built, 2026-08-24):
  4 GiB does not execute in this environment.** A 4 GiB-`.bss` static binary
  **segfaults at load** here — measured directly, exit 139, against `MemTotal`
  3,933 MiB and `vm.overcommit_memory=0`, which *accounts* a `.bss` mapping
  rather than reserving it lazily the way `MAP_NORESERVE` does. A 1 GiB binary
  runs clean (exit 0). So the SPEC's 4 GiB would have made `chirality-bin-c`
  unrunnable in the box where the work happens — the leg must RUN to be a leg.
  **1 GiB against the measured 313.1 MiB peak self-compile is 3× headroom**, and
  the shim carries an `#ifndef M_HEAP_BYTES` override for anyone who needs more.
  ⚑ **The correction shipped TWICE, and the first attempt was a claim without a
  constant behind it.** `e0fbd82`'s commit message says *"4 GiB → 1 GiB heap"*
  while the constant it shipped still read 4 GiB; `50b18d0` is what actually
  changed the number. **A claim in a commit message is not a constant in a
  file** — read the diff, not the subject line.
  ⚑ **If the reserve is ever raised past ~2 GiB, `-mcmodel=medium` becomes
  mandatory** — at 3 GiB the link fails outright with
  `relocation truncated to fit: R_X86_64_PC32 against '.bss'`, because the heap
  pushes later static objects past the small model's ±2 GiB. *(The `1L << 29`
  words = 4 GiB spelling below is superseded; the shim spells the quantity in
  bytes so a reader does not have to multiply by eight.)*
  Historical: `M_WORDS = 1L << 29` = **4 GiB of address space**,
  demand-paged by `.bss` exactly as `MAP_NORESERVE` is, against a **measured
  313.1 MiB** peak self-compile, and reporting its own high-water mark on exit
  (decision 11).
  ⚑ **Newly documented in the shim by Step 3, and REQUIRED not optional:**
  the link needs `-Wl,--defsym,m_entry=m_<mangled root>`. `m_entry`
  (`chirality-rt.c:179`) is declared, never defined — it is an alias for whatever
  the emitted translation unit calls its root, and without the `--defsym` the
  link fails outright. `ddc-c-leg.sh:95` supplies
  `m_entry=m_compile_Dmain`; the shim's own gate defines it itself.
  (2) `m_sys`, the one crossing, 7 lines of
  `__asm__ volatile ("syscall")`; (3) the memory face (below); (4) the
  wrapping/Euclidean op helpers incl. the D3 guard (`m_trap()` = `ud2`, per
  decision **3b**); (5) `_start`.
- **⚑ CORRECTED by Step 2 (built `ded38a2`): "`m_bptr`, the ONLY int→ptr cast"
  is not achievable, and the reason is structural rather than a preference.**
  `lea` (`emit-core.chiral:162`) puts a **literal cell's** address into the same
  register file that `bln` / `bgt` / `bpr` consume, and `c-assemble`'s frame
  contract already fixed literals as standalone `unsigned char m_<n>[]` objects
  **outside any heap array** — so no single index space addresses both. A cell
  pointer is therefore a real address in a `long`, exactly as on x64. What the
  shim still buys, and what must be claimed instead: **every cast is behind one
  of eight named accessors** — `m_getf` `m_setf` `m_tag` `m_bget` `m_bput`
  `m_blen` `m_addr` `m_bptr` — so the unsafe surface is enumerated rather than
  scattered. The trusted drop is the same size as before; it is now *named*
  instead of *buried*, which is the honest version of the claim.
- **The prototypes are already published.** `mach-c.chiral`'s `mc-preamble`
  declares the 24 shim symbols the emitted C references. The shim must match
  that block exactly, symbol for symbol — a mismatch is a link error at best
  and a silently different function at worst.
- **Size:** S (~70 L was the pre-Step-2 estimate; the eight-accessor memory face
  and the nine wrapping/Euclidean helpers put it nearer **~110 L**).
  **Its size IS the element's honesty check** — a shim that grows into a runtime
  has moved the trusted drop, not shrunk it. If it passes ~150 L, stop and say
  so rather than letting it drift.
- **⚑ AMENDED 2026-08-25 (`aa055ec`) — THE SHIM IS TWO FILES, AND THE CHECK IS
  THEIR SUM.** Making the leg build under CompCert forced `m_sys`, `m_trap` and
  `_start` out of the C and into `scaffold/rt/chirality-rt.s`: `ccomp` refuses GNU
  local register variables, file-scope `__asm__`, and the `"a"`/`"D"`/`"S"`/`"d"`
  operand constraints, with no flag that reaches any of them. **A `.s` beside the
  shim is a SECOND TRUSTED ARTIFACT, so the threshold above is now measured as C
  code lines + asm code lines, SUMMED** — decided by the author, on the ground
  that moving code across a file boundary must not be able to shrink the number
  that measures how much we are trusting, or the honesty check becomes a filing
  trick. Measured with the same non-comment/non-blank rule on each side:

  | file | rule | code lines |
  |---|---|---|
  | `scaffold/rt/chirality-rt.c` | `grep -cvE '^[[:space:]]*(//|/\*|\*|$)'` | **89** |
  | `scaffold/rt/chirality-rt.s` | `grep -cvE '^[[:space:]]*(#|$)'` | **27** |
  | **sum** | | **116** |

  **116 is under ~150, so the check still PASSES and the threshold is NOT
  widened.** ⚑ And the trap that must not be "fixed" back into the C, recorded
  in `chirality-rt.s` above the crossing: relaxing the constraints to generic `"r"`
  **compiles clean under `ccomp` and emits a bare `syscall` with no operand
  reaching any register**, result uninitialized. "It built" is not evidence for
  a crossing.

### Step 4 — `lib/emit-c.chiral` + the `compile-driver-c` root
- **Target:** new file, plus a driver root mirroring `compile-driver`
- **Change:** the `emit-x64.chiral` analogue, ~12 L. It cannot call
  `emit-with-peep` (that hardwires `assemble`), so it inlines that one body with
  `c-assemble` substituted. **Signature demands `(Alloc mem-typed)`**, selecting
  `alloc-fixed` at the call site:
  `(c-assemble fn-names (cat2 (emit-program mc alloc-fixed fns 0 false) (cat2 (emit-data mc lits 0) (mach-fin mc))))`.
  No peephole (`rd-truthful` is the identity). The driver root gives blob A its
  `compile-main`, and imports **no** `mach-x64`.
- **Size:** S (~30 L across both).

### Step 5 — the leg script: chirality → C → gcc → `chirality-bin-c`

> **✅ BUILT 2026-08-24 — the leg is one command, and it is `run-native.sh`
> Phase 10.**
>
> `bash scaffold/tests/ddc-c-leg.sh` exits 0 with **10 gates green in 2m21s**
> standalone: **G0b** (blob A **674,612 B, 51 modules**; `mach-c` +
> `alloc-fixed` present, `mach-x64` + `alloc-growing` absent) · **G1**
> (`B1 < blobA` → `chirality-bin-emit-c`, **1,007,992 B**) · the **shim gate 51/51** ·
> **G2** (an exit-42 program through `mach-c` → C → gcc) · **F3** (25 samples
> swept; 14 more tabled `floor` and judged by Phase 12 — amended 2026-08-26) ·
> `chirality-bin-c` built (**2,171,314 B** of C → an **813,656 B** binary) · **G4**
> conviction (`chirality-bin-c < blobB` and `B1 < blobB` byte-identical at
> **1,077,624 B**) · the emitted artifact then **RUNS** — it compiles a program
> to exit 42, so bit-identity is not standing in for "it works" · **G5**
> (`prov-disjoint?` + 23 quorum cases) · **G3** admission (the whole native
> suite under `chirality-bin-c`: **154 assertions, 0 failed, 82 roots** — re-measured
> 2026-08-25; the **135** first recorded here counted 129 rows that actually
> ran under `B1`, see the G3 gate row).
>
> **Step 6 landed with it** (`a9eebcd`): `ddc.chiral` carries
> `(def ddc-legc Leg (leg "c-external" (prov "c" "gcc-12" "shred" 2026)))`,
> gated by `scaffold/tests/samples/e166_ddc_legc.chiral` (**23 cases** since
> 2026-08-25; 13 as first built) rather
> than by the fixpoint — **`ddc.chiral` is a SHELF module the fixpoint cannot
> see.** Nothing in a shipping blob imports it, so a leg whose provenance
> overlapped leg 0 would byte-reproduce the compiler perfectly. The teeth have
> to be a program that runs.
>
> **The full native suite with Phase 10 wired in: exit 0, 144 `ok` assertions,
> 0 FAIL, 82 roots compiled / 0 failed / 12 known-negative / 0 newly passing,
> 2m17s** — 135 baseline + 9 Phase 10 rows. Self-compile heap high-water
> **36,547,557 words = 292 MiB**, inside the 1 GiB reserve (134,217,728 words).
>
> ⚑ **F3 carries TWO expectations per sample**, and this is the part that makes
> it a gate rather than a comparison: the two legs must **agree**, AND the
> agreed exit code must match the one the sample's own header documents.
> **Agreement alone is not correctness** — a differential that only compares the
> legs to each other is the E161 G0 shape, two providers wrong the same way
> reporting `ok`.
>
> ⚑ **F3 does NOT subsume the shim gate**, and that must be said wherever this
> leg's adequacy is discussed. Mutant (c) below — dropping `m_div`'s Euclidean
> correction — is caught by the shim gate and by G4 and **is not caught by F3**:
> no sample in `scaffold/tests/samples/` divides negatively. A behavioural
> differential covers what its input vector reaches, which is not the same as
> what the ops span.

#### History — the two defects, and why the gates did not see them

> **⚑ Everything in this subsection is HISTORY as of 2026-08-24, not live
> state.** Steps 0–6 are built and every gate above passes. It is kept because
> the diagnostic path is the instructive part of this element — a polarity flip
> three layers down presented as a missing definition, and the gate that should
> have caught it was textual — and because re-walking it cost two sessions.
>
> **The symptom, while it was live.** `chirality-bin-c` built cleanly, read its input,
> did real work (**726,004 heap words = 5.8 MB** on the compiler blob) and then
> reported **`no such def: compile-main`** — on an input that certainly contains
> it and that `B1` compiles fine. Same failure on a 23 KB input and on the
> 42-byte trivial program. At `-O2` it **SIGSEGVed** before reaching that error;
> `-O0`/`-O1` reached it. Those were **two separate defects**, and the second
> masked the first.
>
> **⚑ The evidence in Step 4's commit message was overstated.** `7d8604d` said
> *"the leg runs"* on the strength of a program that ran and returned 42. That
> program is `(lam (n) 42)`: it exercises `con` and `ret` and essentially
> nothing else — no crossing, no heap, no bytes, no literals, no jump table. It
> was never evidence that the leg works. This is `docs/testing-floors.md`'s own
> lesson — *"byte-identical to the old implementation is also what a fixture
> that exercises nothing achieves"* — walked into one step after quoting it.
>
> **The adequacy gap that let it through:** Step 2's 68-assertion sample checks
> the **emitted text** of each arm. Nothing checked the **runtime behaviour of
> the composition**. An arm can render plausible C and still be wrong. That gap
> is what F3 closes, and closing it is why F3 became Phase 10 rather than a
> one-off probe.
>
> **⚑ DEFECT 1 — `mach-c` inverted the polarity of the three comparison ops.**
> `Bool` is `(data Bool () (true) (false))`, so **`true` is tag 0**. `mach-x64`
> therefore emits the *inverted* condition when materializing a comparison as a
> **value**: `mach-x64.chiral:367` `((op-eqi) (bcat x-cmp-rcx (x-setcc 149)))` —
> cc **149 is `setne`**, not `sete`; `:369` uses **`setge`** for `op-lti`;
> `:371` uses **`setg`** for `op-lei`. `mach-c`'s `c-op` mapped them to C's
> `==`, `<`, `<=` — all three backwards, so every materialized `Bool` was
> negated. The fix inverts them (`!=`, `>=`, `>`), including the
> immediate-operand paths (`bini` / `binir`), whose x64 counterpart at
> `mach-x64.chiral:981` carries the identical `x-setcc 149`.
>
> **Why every earlier probe passed, and this is the instructive part.**
> `(case (=i x y) …)` does not materialize a `Bool` — it **fuses** into `fjc`
> (compare-and-branch), and Step 2 had already corrected `fjc`'s ternary to
> `? 0 : 1`. **Two errors that cancelled.** So the read path, `str-eq` and sum
> dispatch all worked; only code needing a `Bool` as a **value** hit the broken
> path — and `or`/`and`/`not` are exactly that. Measured, C leg vs native:
> `or(false,false)` → **true**, `and(true,true)` → **false**, `not(true)` →
> **true**; native correct on all three.
>
> **The consequence chain, end to end:** `is-trivia` (four `=i` folded with
> `or`, `sexp.chiral`) returned **true for every byte** → `skip-trivia b 0`
> returned **4 on `"abcd"`** where native returns 0 → `read-all-str` returned
> **`(a-ok nil)`** — zero forms, reported as success → the `Sig` had no globals
> → `glookup` returned `none` → **`no such def: compile-main`**.
>
> **Why the gates missed it:** three of Step 2's 68 text assertions were
> *pinning* the defect. `op-eqi` rendering `==` looks right and is semantically
> inverted. **A text assertion cannot see polarity — only running the
> composition can.**
>
> **⚑ DEFECT 2 — `_start` never realigned the stack.** Bisected the 44-flag
> `-O2`-over-`-O1` delta to **`-ftree-slp-vectorize` alone**, then split by
> translation unit (the emitted C, not the shim), then took a **core dump** and
> read the faulting instruction: `movaps %xmm0,(%rsp)` in `m_read_Dall` with
> **RSP ≡ 8 (mod 16)**. The kernel enters a process with RSP **16-aligned and no
> return address**, while gcc compiles a plain C `_start` assuming it *was
> called* (entry RSP ≡ 8 mod 16). Every frame was therefore skewed by 8 from the
> SysV invariant, so any 16-byte SIMD spill faulted. `-O1` emits none, which is
> why it looked like an optimizer bug for two sessions. **It was not an
> optimizer bug.** `_start` is now top-level asm doing `andq $-16, %rsp` once
> before calling `m_boot`.
>
> **Ruled out by measurement along the way — do not re-try these.** For defect 1:
> not E94's capacity-bounded loader (plain `load-source` and
> `load-source-batched` failed identically), not input-dependent (a literal
> source string and a `str-cat`-built one both gave 0), and seven subsystems
> tested clean during diagnosis — `con`/`ret`/arithmetic, the `sys` crossing +
> `read-fd-all`, `bcat`/`blen`/byte copy, `str-eq` in both polarities and
> literal-vs-heap-built, literal cells (`lea`/`dat`), and sum tag dispatch
> (`lsb`/`cjne`/`jtb`) with multi-field cells (`alo`/`fld`). For defect 2: not
> scale (failed on the trivial input), not tail calls
> (`-fno-optimize-sibling-calls` still faulted), not signed overflow (`-fwrapv`
> still faulted), not strict aliasing (already disabled), not literal alignment
> (507 literals forced to `aligned(8)`, still faulted), not global alignment
> (`m_arg`/`m_heap`/`m_used` are all 32-aligned), not stack depth (insensitive
> to `ulimit -s`).
>
> ⚑ **Separate finding, latent, recorded not fixed:** `-foptimize-strlen` and
> `-ftree-loop-distribute-patterns` each turn a shim loop into a call to
> `strlen`, which does not link under `-nostdlib`. Harmless at plain `-O2` today
> because other passes reshape those loops first — so the freestanding build
> survives by luck rather than by design. The shim has libc-recognisable loops
> in `m_say` and `m_blew`.
>
> ### The staged fix — all four done
>
> - **F1 — ✅ DONE 2026-08-24 (`0ba2004`).** Inverted the three comparisons in
>   `c-op` plus the `bini`/`binir` immediate paths. The chain re-checked after
>   the fix: `skip-trivia "abcd" 0` → 0, `read-all-str` → 1 form, `load-source`
>   → 1 global, and `chirality-bin-c < blob` producing an artifact.
> - **F2 — ✅ DONE 2026-08-24 (`20ba530`).** `_start` realigns (defect 2 above).
>   The leg builds and convicts at **`-O2`**: artifact byte-identical, G3
>   admission 154 ok / 0 FAIL / 82 roots (**135** as first recorded, before the
>   `CHIRALITY_BIN` override was total — see G3), shim gate 51/51. The `-O1` qualifier
>   that G3 originally carried is **retired** — admission is now measured on the
>   `-O2` build.
> - **F3 — ✅ DONE 2026-08-24 (`e426a30`).** The adequacy gap is closed by a
>   **behavioural** differential over `scaffold/tests/samples/`: **25 samples**
>   (swept; 14 further fixtures are tabled `floor` and judged by Phase 12 —
>   amended 2026-08-26, see the F3 gate row)
>   compiled through `mach-c` → gcc → run, each carrying the two expectations
>   named above. It is the gate that would have caught F1 on the day Step 2
>   landed, it generalises (every future arm defect surfaces here), and it is
>   now `run-native.sh` **Phase 10** rather than a one-off probe. Its limit is
>   stated, not glossed: it does not subsume the shim gate.
> - **F4 — ✅ DONE 2026-08-24.** Step 5 (`e426a30`, the leg script) and Step 6
>   (`a9eebcd`, `ddc-legc`) both landed. DDC has two legs with disjoint
>   toolchain provenance.
- **Target:** new `scaffold/tests/ddc-c-leg.sh`
- **Change:** build blob A (roots ending at `compile-driver-c`, **never**
  `compile-all` — `BUILD-ORDER.md` records that the stale list produces a 0-byte
  compiler whose `cmp` then *passes*); `B1 < A` → `chirality-bin-emit-c`; run it over
  blob B → C source;
  `$CC $CFLAGS_LEG -o chirality-bin-c` + `chirality-rt.c` + `chirality-rt.s` — ⚑ **the flags are
  PER-COMPILER since 2026-08-25**: gcc keeps
  `-O2 -fno-strict-aliasing -ffreestanding -nostdlib -static` byte for byte,
  while `ccomp` gets `-O2 -nostdlib -static` (the two dropped flags are
  `Unknown option` to it and semantic no-ops for it; `-finline-asm` is not
  needed, the shim split having left no inline asm in the C)
  (⚑ **`-O2`, not `-O1`, and this is load-bearing:** `mach-c`'s `tca` arm
  renders a tail call as `return f();`, gcc enables `-foptimize-sibling-calls`
  at `-O2` but **not** at `-O1`, and this compiler recurses through tail calls —
  at `-O1` the C stack is the limit. Pass the flag explicitly if the `-O` level
  ever moves. Found by Step 2, `ded38a2`.);
  then G3 and G4 below. Carries decision 9's constraint as a comment: the
  artifact is compared and discarded, never distributed. Carries decision 10's
  measurement checkpoint.
- **Size:** M.

### Step 6 — `lib/ddc.chiral`: admit the leg   ✅ BUILT 2026-08-24 (`a9eebcd`)
- **Target:** `scaffold/lib/ddc.chiral` — beside `ddc-leg0`:111 / `ddc-leg1`:112
- **Change:** `(def ddc-legc Leg (leg "c-external" (prov "c" "gcc-12" "shred" 2026)))`.
  `leg2-disjoint?` requires both `language` and `toolchain` to differ:
  `("c","gcc-12")` vs `("chirality","chirality-native")` differs on both. **Record, do
  not launder, that `author` stays `"shred"`** — `ddc.chiral:14` already concedes
  *"author is assertable only"*. What this buys is **toolchain** disjointness,
  the axis a Thompson attack lives on.
- **⚑ AMENDED 2026-08-25 — a SECOND constant, and the disjointness it does NOT
  buy.** `ddc-legcc (leg "c-compcert" (prov "c" "compcert-3.17" "shred" 2026))`
  is added *beside* `ddc-legc`, not over it, so each constant names a toolchain
  that actually built something — both do, the leg being 9/9 green under either.
  **The two C legs are NOT disjoint from each other:** they share `"c"`, and
  `leg2-disjoint?` demands BOTH axes, so a quorum is leg 0 plus **exactly one**
  of them and a driver listing both has one leg fewer than it thinks. Running
  the leg under two compilers buys more evidence about the SAME leg, never a
  third leg. `scaffold/tests/samples/e166_ddc_legc.chiral` grows **13 → 36
  cases** to assert this pairwise (18), as a list (20), and — since `f713ec8` —
  inside `ddc-compare` itself (21, 24–36). ⚑ **The 23-case draft of this
  paragraph named the seam and then blessed it:** it read *"and at the seam
  where `ddc-compare` folds bytes without consulting provenance at all (21)"*,
  with case 21 asserting that the two C legs on identical bytes CONVERGE. That
  was the defect written into the contract. `ddc-compare` now consults
  `prov-disjoint?` before reading a byte, so the pair is refused, and the
  obligation is the core's rather than every driver's.
- **Size:** S. **⚑ Compiler source → fixpoint check.**

## 5. Conformance gate

Every row names its **expectation provenance rank** (`docs/testing-floors.md`)
and a **mutant that falsifies it — and the mutant MUST BE RUN**, reverted, with
its measured failure recorded. Naming a mutant is a claim; running it is the
evidence. E156 G4 passed 14/14 with `list-sort` deleted; E161 G0 reported `ok`
with both providers wrong. Both named the right mutant.

| # | Gate | Rank | Mutant to RUN |
|---|------|------|---------------|
| **G0** | **`emit-core.chiral` byte-identical** — `git diff --exit-code` over it, plus `mach.chiral`, `mach-x64.chiral`, `mach-listing.chiral`, `asm-reloc.chiral`. **Now achievable and measured**, because decision 11b dropped the index that would have forced ten signature rewrites through it | 2 (fixed committed artifact) | Touch one byte of `emit-core.chiral` → G0 must fail. If `emit-core` *had* to change, decision 2's seam choice was wrong and the element is mis-scoped. ⚑ The earlier draft weakened this to "diff confined to `Alloc` → `(Alloc c)` occurrences" to accommodate the index; with the index gone the strong form is back, and it is the form that actually validates Choice 1's seam. |
| **G0b** | ✅ **PASSED 2026-08-24.** Blob composition — the invariant, tested where it actually lives. `ddc-c-leg.sh` resolves blob A at **674,612 B, 51 modules**, with `mach-c` and `alloc-fixed` **present** and `mach-x64` and `alloc-growing` **absent**. ⚑ **The module count is 51, not 68** — a blob carries one `end-module "<name>"` marker per module, but the marker is also *mentioned in source comments*, so the count must be **anchored**: `grep -c '^(end-module '`. Measured here 2026-08-24 on the committed compiler blob (`scaffold/build/blob.chiral`, 707,125 B): **anchored 52, unanchored 69**. The earlier "69 modules" in this row was the unanchored number and is corrected. | 3 (meaning of the form) | **RUN** — adding `(import "mach-x64")` to `compile-driver-c` fails **this gate and G1**, with `mc: extern does not lower: lambda stays upper`. Reverted. Step 0's M1/M2 measured the same shape for a second `Mach` (`x64: …`) and a second `Alloc` (`alloc-growing: …`). So the violation is not merely detected by this gate, it is **unbuildable** — the gate exists to name the failure early rather than to prevent it. That is the honest description; do not upgrade it to prevention. |
| **G1** | ✅ **PASSED 2026-08-24.** Blob A lowers: `mach-c` inhabits all 37 arms and `B1 < blobA` produces `chirality-bin-emit-c` at **1,007,992 B**, asserted non-zero. | 3 (meaning of the form) | **RUN** — `(import "mach-x64")` added to `compile-driver-c` fails G0b and this gate with `mc: extern does not lower: lambda stays upper`, exactly the lowering failure decision 1 predicts. Reverted. That mutant is the one that proves fact 1 was read correctly, and it was the cheapest insurance in this gate. (Deleting one arm → the coverage check rejects; the arm count was already pinned by Step 2.) |
| **G2** | ✅ **PASSED 2026-08-24.** A one-function program (exit 42) through `mach-c` → C → gcc → runs → **exit 42**. ⚑ **State its scope honestly:** this gate proves the *toolchain path composes end to end*, not that the arms are right. Its program is `(lam (n) 42)` — `con` and `ret` and essentially nothing else — and Step 4's commit message overclaimed exactly this vector as "the leg runs". F3 is the row that carries arm correctness. | 3 | **RUN, and it lands on a different row than this one.** Dropping `m_div`'s Euclidean correction is caught by the **shim gate** (`FAIL [1] m_div(-7,2): got -3 want -4`, plus [3] and [13], exit 1) and by **G4**; dropping the `& 63` shift mask is caught by the shim gate (exit 24). Neither is falsifiable by G2's own vector, which divides nothing and shifts nothing — so those mutants belong to the shim gate and G4, and naming them here was naming a mutant this row could never fail. Recorded rather than quietly re-homed. |
| **G3** | ✅ **PASSED 2026-08-25, and the 2026-08-24 pass was OVERSTATED.** Admission — the whole native behavioural suite run under `chirality-bin-c`, the compiler chosen by exporting `CHIRALITY_BIN`: **exit 0, 154 ok, 0 FAIL, 82 roots compiled / 0 failed**, inside `ddc-c-leg.sh`'s 10 green gates (`bash scaffold/tests/ddc-c-leg.sh`, ~3m45s). ⚑ **What the earlier *135 assertions* actually measured.** `CHIRALITY_BIN` was honoured by `run-native.sh`'s own inline phases only: the five sub-scripts it drives re-derived the compiler from `bin/chirality-bin` → `scaffold/build/B1`, and two more reached it through `bin/chirality`, which had its own resolution. So of those 135 rows, **6** (Phase 1) ran under `chirality-bin-c` and **129** (Phases 3/4/5/6/8/9) ran under `B1` while being reported as C-leg coverage — the claim was materially narrower than it read. Phase 7's 82 root compiles were genuine, that phase being inline. Fixed at `ce593c4` (all five sub-scripts plus `bin/chirality` now resolve `CHIRALITY_BIN` first) and mechanized as `ledger-lint` **check P**. **The re-run is the real result: 148 assertions that had never once run under the C-built compiler now do, and NOTHING diverged** — phases 3/4/5/6/8/9/11 pass identically under `chirality-bin-c` and `B1`. (154 = the suite's 163 `ok` at `70ee90f` minus Phase 10's 9 rows, which admission skips by construction.) ⚑ **Three honest caveats.** (a) **Phase 2 does not test the C leg** — it runs the prebuilt `scaffold/build/test-runner` binary (dated Aug 23), which `$CHIRALITY_BIN` does not rebuild; that is `BUILD-ORDER`'s stale-test-runner finding, and those rows are not evidence here. (b) **Phase 10 is skipped during admission** (`CHIRALITY_C_LEG_SKIP`) — the leg does not re-enter itself. So **9 of the 11 phases are genuine `chirality-bin-c` coverage**, and the 11th is the leg being gated. (c) ⚑ **The `-O1` qualifier this row originally carried is RETIRED.** It read: *"the admitted binary is an `-O1` build, because `-O2` still SIGSEGVs (F2, open)."* **F2 is fixed** (`20ba530`, the `_start` realignment), and admission is measured on the **`-O2`** build. | 1 (external: gcc's codegen is not ours) | ⚑ **The originally-named mutant DOES NOT WORK, and Step 3 proved why.** `m_mul` → signed `a*b` leaves the gate **green**: `objdump` of both spellings is **byte-identical** (`mov %rdi,%rax; imul %rsi,%rax; ret`), because at a cross-TU call boundary with no LTO gcc-12 has no signed-overflow assumption to exploit. *No value assertion can distinguish them.* The unsigned spelling still earns its keep — it buys back the licence under LTO or a different compiler — but it is **not falsifiable by this gate**, and naming it here would have been a mutant that could never fail. Use a **value-changing** mutant instead: break `m_div`'s Euclidean correction (measured: `FAIL [1] m_div(-7,2): got -3 want -4`, plus [3] and [13], exit 1) or drop the `& 63` shift mask (measured: exit 24). This is `docs/testing-floors.md`'s *"the honest limit"* met in the wild — expectation-correctness is mechanizable, test-**adequacy** is not. |
| **G4** | ✅ **PASSED 2026-08-24 (F1).** Conviction — `chirality-bin-c < blobB` and `B1 < blobB` both produce **1,077,624 B, byte-identical** (`cmp` clean; both asserted non-zero first, since two empty files compare equal). The emitted artifact was then **executed** and correctly compiled a program to exit 42, so byte-identity is not standing in for "it works". Self-compile heap high-water **36,547,557 words = 292 MiB**, inside the 1 GiB reserve and consistent with the 313.1 MiB measured under `B1`. | 2 | Patch one instruction byte into `chirality-bin-c`'s output path → `bytes=?` must report the first divergence and localize it. ⚑ Beware the trap `BUILD-ORDER` records: **`cmp` of two empty files passes.** Assert non-zero size before comparing, or G4 passes on a build failure. |
| **G5** | ✅ **PASSED 2026-08-24 (Step 6, `a9eebcd`).** `prov-disjoint?` returns `true` for `(ddc-leg0, ddc-legc)` and `ddc-compare` no longer returns `ddc-bad-quorum`, checked in the leg script and pinned by `scaffold/tests/samples/e166_ddc_legc.chiral` — **36 cases** (13 as first built; ten added 2026-08-25 for the CompCert leg; thirteen more the same day when `ddc-compare` was fixed to consult `prov-disjoint?`), exit 0 iff every case holds, otherwise the 1-based number of the first failing case. Gated by a running program because **`ddc.chiral` is a SHELF module** no shipping blob imports, so the fixpoint cannot see one byte of it. | 3 | **The mutant is expressed as assertions rather than as an edit, which is stronger:** cases 4–6 assert that a leg sharing **either** axis is refused — `(prov "c" "chirality-native" …)` and `(prov "chirality" "gcc-12" …)` are both constructed and both must fail `leg2-disjoint?` — so "disjoint" cannot degrade to "differs somewhere". Case 9 pins the state the ordering constraint exists to prevent: **leg 0 alone is `ddc-bad-quorum`**, which is what deleting leg 1 before this leg was admitted would have left behind (decision 5). ⚑ **Cases 17–21 (2026-08-25) pin the arithmetic of the second C compiler:** `ddc-legcc` is disjoint from leg 0, the two C legs are **NOT** disjoint from each other, and a three-leg list carrying both is refused by `prov-disjoint?` — so nobody can bank gcc-and-ccomp as three legs. Mutants run: the naive relabel fails at case 15, and the *laundering* mutant that relabels **and** fixes the axis assertion to match fails at **case 18**. ⚑ **AND THIS ROW WAS INCOMPLETE UNTIL `f713ec8`, in the way that matters most:** every case above interrogates `prov-disjoint?`, which has always answered correctly. None of them asked whether `ddc-compare` ever CONSULTS it — and it did not. It folded bytes, so leg 0 + BOTH C legs came back `ddc-converged`, and case 21 asserted that convergence. A gate that pins the defect cannot catch it. Cases 21 and 24–36 now cover the compare path: reasons stay distinguishable (24/27/28/34), the gate fires **before** the fold (32 — non-disjoint legs with DIFFERENT bytes are bad-quorum, never diverged), it answers to BOTH axes (35/36), and it does not over-refuse (31/33). Mutants RUN with a first-failure sweep over all 36, each reverted: gate removed → 21 24 25 26 29 30 32 35 36; head-vs-rest only → 29 30; a second routine checking language only → 35; toolchain only → 21 24 29 30 32 36; the two refusal strings collapsed → 24 26 30 34. |
| **F3** | ✅ **PASSED 2026-08-24 (`e426a30`).** The behavioural differential the element was missing, and now `run-native.sh` **Phase 10**: **25 samples** from `scaffold/tests/samples/` compiled through `mach-c` → gcc → run. ⚑ **Two expectations per sample, deliberately:** the two legs must **agree**, AND the agreed exit code must match the one the sample's own header documents. Agreement alone is not correctness — that is the E161 G0 shape. | 1 (external: gcc's codegen is not ours) + 2 (the header's documented code is a fixed committed expectation) | **RUN** — re-inverting `mach-c.chiral:138`'s `!=` back to `==` (the F1 defect) makes F3 **diverge on nearly every sample** while **G2's exit-42 program still passes**. That pair is exactly how the defect hid for two sessions, and it is why this row exists. Reverted. ⚑ **Honest limit, and it must be stated wherever adequacy is discussed: F3 does NOT subsume the shim gate.** Dropping `m_div`'s Euclidean correction is caught by the shim gate and by G4 and **not** by F3 — no sample divides negatively. A behavioural differential covers what its input vector reaches, not what the ops span. ⚑ **AMENDED 2026-08-26 — THE CORPUS IS NOW MARKED BY WHAT EACH SAMPLE EXERCISES, and F3's job is stated rather than inherited from a directory glob.** `scaffold/tests/samples/` held **39** `.chiral` files when this was measured and holds **42** at 2026-08-26 (E170 lane C added three floor fixtures); F3 sweeps **25** and tables the other **17** under a fourth marker, `floor` — E168's and E170's test-floor fixtures, whose subject is `scaffold/lib/test-floor.chiral`. **What F3 covers is unchanged**: this row's job is `mach-c`'s 37 arms against `mach-x64`'s, and a fixture that exercises the test floor reaches no arm the swept 25 do not. **What it deliberately does NOT cover, said plainly:** those 17 files' behaviour under the C toolchain; they are judged natively by Phase 12 (`test-e168-floor.sh`), which asserts their exit codes and, for the five refusals, their diagnostics — an assertion the `refused` marker never made, and the reason no row carries `refused` today. **The cost that motivated the correction, measured 2026-08-26** as the difference between two back-to-back `--no-admission` runs on an idle box under gcc 12.2.0: **5m14.614s** over 39 samples against **1m41.358s** over 25, i.e. **15.2 s per floor fixture**, against 0.5–1.7 s for a typical swept sample — and E170's W2–W4 add ~79 more fixtures to the same directory. A scope correction with a cost benefit, not a cost cut. **The marker is a TRANSFER, not an exemption, and that is CHECKED:** a `floor` row claims Phase 12 judges the sample, and F3 verifies the claim against the judge itself — `test-e168-floor.sh --list` makes that file's own `verdict_ok`/`refuses` call sites name their fixture instead of running it, so the list cannot drift from the runs; fail-closed if the floor cannot be asked; table totality untouched (an untabled file is still a FAILURE). **Mutants RUN 2026-08-26 and reverted, both caught in one leg run (exit 1, 8 passed / 2 failed):** (i) `e166_mach_c` marked `floor` while the floor does not judge it → *"tabled 'floor' (judged by Phase 12), but test-e168-floor.sh --list does not name it"*; (ii) the floor's own `e170_suite_main` call site commented out → the identical failure on that row. Neither end of the transfer can be removed quietly. |

- **Green line, re-measured by this audit (2026-08-24), not inherited.**
  `ulimit -s unlimited && bash scaffold/tests/run-native.sh` →
  **9 numbered phases, 135 `ok` assertions, 0 failed, exit 0**, with Phase 7
  reporting *"downstream roots: 81 compiled, 0 failed, 12 known/negative,
  0 newly passing"*. `python3 tools/ledger-lint/ledger-lint.py` → **clean** (checks A–N; the
  one `[N] E52` line is a flagged known disagreement, not a failure). Those are
  the numbers the SPEC's arithmetic rests on and they are now confirmed rather
  than quoted from the handoff.
  **After E166 — MEASURED 2026-08-24, not projected: 10 phases, 144 `ok`
  assertions, 0 FAIL, 82 roots compiled / 0 failed / 12 known-negative /
  0 newly passing, exit 0 in 2m17s, `ledger-lint` clean.** That is 135 baseline
  + **9** Phase 10 rows. ⚑ **Two figures in the projection were wrong and are
  corrected against the measurement, not rounded to it:** the roots figure said
  **81**, which was the *pre-E166* number (the live count is **82**, and G3
  already reported 82 before this line was written — the projection simply
  carried the old one forward); and the assertion figure said **≥ 140**, a
  floor where a measured count now exists. ⚑ The **≥ 141** in the first draft was unsourced — it did not
  correspond to any enumerated set of new rows. The gate rows do not map 1:1
  onto native-suite assertions, and the SPEC must say which is which or the
  arithmetic is decoration:
  - **Native-suite rows** (the new Phase 10, ≥ 5 assertions): **G1** (blob A
    lowers), **G2** (exit-42 program through gcc), **G4** (conviction
    byte-equality), **G5** (`prov-disjoint?`).
  - **Not native-suite rows** — they run in the leg script or the build, and
    must be reported there rather than silently counted: **G0** (a source-diff
    shape check), **G0b** (a *compile failure* is the pass condition, so it
    cannot be an assertion inside a suite that must compile), **G3**
    (admission — it re-runs the whole suite *under `chirality-bin-c`*, so it is a
    second full run, not one more row in the first).
  - Self-hosting fixpoint `C1 == C2` byte-identical after Steps 0 and 6, with
    `C1` asserted non-zero **before** `cmp` (see G4).
- **Done when — ✅ SATISFIED 2026-08-24.** `bash scaffold/tests/ddc-c-leg.sh`
  exits 0 in **2m21s** with **10 gates green**, having built `chirality-bin-c` through
  gcc, passed the native suite with it (**admission**, 154 / 0 FAIL / 82 roots
  as re-measured 2026-08-25; 135 as first recorded, when seven phases were still
  running under `B1` — see G3),
  byte-matched its emitted compiler against `chirality-bin`'s (**conviction**,
  1,077,624 B), and reported `prov-disjoint? = true` — with every mutant above
  run and reverted.

## 6. Residue & links

- **Deliberately unbuilt:**
  - **`emit-core.chiral` (573 L) stays externally uncovered.** Rule 1 —
    a differential only covers what is BELOW its branch point. Both legs drive
    the *same* `emit-core`, which is what makes E166 cheap and is exactly why it
    cannot see one line of the 573 above it. Home: **E167** (`tal-c`).
  - **Bisection needs both legs.** `tal→C` disagrees while `Mach→C` agrees ⇒
    `emit-core`; both disagree ⇒ `mach-x64`. **Neither leg alone localizes.**
    Home: **E167**.
  - **CompCert.** gcc carries the whole of gcc in the TCB, so the *gcc* leg buys
    *provenance disjointness*, **not** TCB reduction. Only CompCert shrinks the
    trusted drop. Say it that way or the element is oversold. ⚑ *Amended
    2026-08-25, twice over — `ccomp` is no longer absent AND no longer held back
    by our shim.* The split landed (`aa055ec`), the flags went per-compiler, and
    **`ccomp 3.17` is now `run-native.sh` Phase 10's DEFAULT** at 9/9 green and
    G4 byte-identical at the same 1,077,624 B, at 1m41.6s / 1m41.2s against gcc's
    1m51.7s / 1m40.1s — two overlapping samples each, so the leg is
    *indistinguishable* between the compilers rather than faster under either.
    `ddc.chiral` carries **both** `ddc-legc ("c" "gcc-12")` and
    `ddc-legcc ("c" "compcert-3.17")` — ⚑ *and they are NOT two legs*:
    `leg2-disjoint?` needs both axes and they share `"c"`, so a quorum is leg 0
    plus **exactly one** of them. Decision 9's constraint is unchanged and now
    live: never distribute a CompCert-built artifact — build, compare, discard.
  - **Growth on this target.** `arena-grow` / `galo` / `gbnw` render as
    `alo`/`bnw` + a trapping bounds check, and are unreachable under
    `alloc-fixed`. Settled by decision 11: this is the **category boundary**, not
    a gap — the C leg covers the provable (A) fragment, and growing programs are
    C, governed by P5's agreement-between-representations, which is what DDC is.
    Canonical keeps unbounded growth untouched.
  - **The tier is declared for `Alloc` only.** `Mach` instances have categories
    too — `mach-x64` emits raw bytes whose referent is B — and so do `Prov` legs.
    Generalising the index beyond memory discipline is **not** in this element
    and has **no minted home**; naming a follow-on here without minting its rows
    is the phantom dep `CLAUDE.md` forbids. Recorded as an observation, not a
    deferral.
  - **The kernel writes into `m_heap` through an address C handed out.** Invisible
    to any C-level theorem. An axiom every verified-compiler-plus-syscalls story
    carries — **named here, not buried in the `volatile`**.
  - **Shared text-emit shelf** for `mc-line`/`mc-lcat`/`mc-r`. Home: **E154**.
- **Follow-on this unblocks:** **E167** `tal-c` (the bisecting second seam) ·
  **S12 / rung-1** Python-leg deletion — **its DDC precondition is DISCHARGED as
  of 2026-08-24**: G3 admission passed and `ddc-legc` is in `ddc.chiral`, so
  deleting `ddc.py`'s leg 1 no longer leaves the tree without a quorum. What
  still gates the *corpus* deletion is E168's receiving shape, not DDC ·
  **E168** test-floor, which inherits `ddc-legc` as a declared expectation source.
- **Related:** [[E166-mach-c]] · [[E53]] (`lib/ddc.chiral`) · [[E70]] (the closed
  `Op` sum `c-op` mirrors) · [[E91]] (`galo`/`gbnw`) · [[E154]] (label namespace)
  · [[E167]] · [[testing-floors]] · [[banks/verification]] ·
  `docs/decision-backend.md` · `docs/pattern-boundary-sums.md` ·
  `docs/axis-altitude.md` (the trusted drop this moves and shrinks).
