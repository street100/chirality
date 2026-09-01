# The self-compile frontier — measured map to the Stage1==Stage2 fixpoint

> Produced 2026-08-03 by instrumenting the **real** lowering eligibility gate over
> the compiler's own source (not from skip-reason strings or memory). Every number
> below is from `lower_all` / a pre-seeded intrinsic-census run. This is the
> "line everything up, then final pass implements" worklist. Supersedes the
> `RUNG1-CRITICAL-PATH` "strings + sys + scale" framing — measurement shows that
> framing both *over*-states (strings already lower) and *under*-states
> (polymorphism is a real erasure slice, not "scale").

## The finish line (unchanged, now sized)

**Stage1 == Stage2, byte-identical.** The chirality native compiler compiles its OWN
source — the transitive import closure of `compile-front`/`compile-back`/
`compile-emit`: **30 files, 8,026 LOC, 141 data decls, 1,648 `case`, ~1,076 string
literals** — twice, and the two ELF artifacts are byte-equal (`ddc.chiral
fixpoint=?`), then E53 DDC converges across provenance-disjoint legs.

The compiler is **three collision-forced images** (kernel-`Term` / lower-`TFn` /
emit-`TFn` can't share a flat namespace), joined by the con-value shuttle the
current driver already uses. The fixpoint compiles per-image.

## What is genuinely done (648 green)

Native path runs whole ELF programs, zero CPython in the compile path, for: I64,
prims, multi-def inter-calls, all-nullary enums, single-field boxed data,
first-order closures (ap/inc + escaping capture). **Strings already lower** —
measured: both a string-return def and a string-literal-arg def lower today. The
tal IR is already complete (`ti-lit` strings, `ti-sys` syscalls, `ti-cona`
multi-field boxed, full `t-case`, `ti-call` = recursion+mutual for free);
`emit-core` encodes all 12 `ti-*`. **The IR and emitter are NOT the wall.**

## PROGRESS LOG

- **2026-08-03 session 4 — the CHIRALITY compiler now compiles a large fragment
  natively (zero CPython in the compile path).** Drove the chirality-side mirrors:
  - **B1b** (chirality B1 emission): threaded q0/erased through the front→NDef→back→
    compile-fn→expr-app pipeline (nt-word, NDef.erased, term->ncore drops erased
    type-args, compile-fn placeholder-walk). Proven: poly `length` runs native.
  - **B2 chirality**: quantity-preserving `rewrite-ty` in closconv-driver. Proven:
    HO-poly `mapl`+`inc` defunctionalizes + runs native.
  - **externs**: FR/NPrim transport threads the sig's pure externs into the
    compile env. **strings**: literal-table mechanism (CEnv.lits, str-index,
    program-lits, shuttled to emit). Proven: `(blen "hello")` = 5 native.
  - **whole-program robustness**: back SKIPS non-lowerable defs + prune-fix drops
    orphaned callers (cascade), so most of prelude+collections compiles.
  - **native runtime library**: emit-elf links `native-lib` (bytes-tal.chiral);
    string ops (str-cat->nb-bcat etc.) run native.
  All 648 green throughout. **MILESTONE: the chirality compiler compiles the WHOLE
  prelude+collections module (every def, skip+prune for the residue) + a
  foldl/append program, running natively = 42.** The chirality compiler now handles
  poly, HO-poly, externs, strings, string-ops, whole multi-def modules.
  **Remaining to the Stage1==Stage2 fixpoint:** (a) feed the compiler's OWN
  30-file source (imports resolved -- concatenate, or a file-read loader);
  (b) the feature residue it surfaces (effect `=>` defs, closconv S6 nested
  closures like m-insert-new, the full data model at scale, mutual recursion at
  scale); (c) determinism for byte-identity (B7); (d) wire the byte-compare via
  ddc.chiral. No conceptual walls left -- coverage + wiring.



- **2026-08-03 — B1 + B1-followup + B4 landed (Python native + chirality partition).**
  Census climb (cascade-free intrinsic): compile-front **507 → 538**, compile-back
  **82 → 97/97 (COMPLETE)**. compile-front's only remaining sig-blocker is the 19
  higher-order poly fns (B2). All erased-position handling done: type (B1), value
  con (B1-followup), non-tail-case result (B4) — all via the uniform `WORD` model.
  648 green. **Next: B2 (HO poly / closconv), then the chirality EMISSION mirror
  (B1b), B3 (field-enc), B5 (sys), B6 (3-image), B7 (determinism), B8, B9.**

## ⚑ THE CHIRALITY-SIDE GAP (measured 2026-08-03) — the real bulk to the fixpoint

B1/B2 were built + proven in the PYTHON ORACLE. The fixpoint runs the CHIRALITY
compiler (`lib/*.chiral`), which lags: **proven by running the chirality 3-image
driver — it fails "the entry def does not lower" on a polymorphic `length`.**
The chirality side has B1's *partition* + B2's *arrow-key-eq*, but NOT B1's emission
or B2's defunctionalization. Closing this is the bulk of remaining work:

- **B1b — chirality B1 emission.** *Part 1 DONE* (tt-word carrier + word-compat in
  tal-ssa/tal-check/lower, 648 green). *Part 2 (substantial, PLAN below):* the
  chirality compile-fn peels only `len(params)` lambdas, so a q0 binder is left as an
  unlowered `(lam ..)` -- even VESTIGIAL q0 fails ("the entry def does not
  lower"). Pipeline-wide fix, edit-ordered:
  1. **lowspec.chiral** — `NTalTy` gains `(nt-word)`; `NDef` gains `(erased (List
     I64))` (the q0 binder positions, over all binders).
  2. **compile-back.chiral** — `ntalty->talty` `nt-word->tt-word`; `def-sigs` +
     `lower-defs` destructure the new `erased` field and pass it to compile-fn.
  3. **compile-front.chiral** — `term->ntalty` maps `(t-var _)` (an erased type
     var in a KEPT position, e.g. `if`'s `A A A`) → `nt-word`; **`peel-def` must
     track quantities** (peel-pi currently discards q): kept-filter params (drop
     q0), compute the `erased` position list, build the new `ndef`.
  4. **KEY FINDING — erased TYPE-ARGS in calls MUST be dropped at the front.**
     `(k I64 42)`'s `I64` arg is a type Term that `term->ncore` cannot convert
     (no t-primty/t-var-in-value arm), so the call fails today. So `term->ncore`
     needs a PER-GLOBAL erased map (computed once from the sig in compile-front /
     bridge-sig) and its App handling must peel the spine, look up the head
     global, and drop args at the head's erased positions. (Alternative: drop in
     `expr-app` via an erased-carrying fn-sig registry -- but the front-drop is
     forced anyway by the unconvertible type-arg, so do it there.)
  5. **compile-fn** (lower.chiral) — new `erased` param; walk ALL binders
     (placeholder register for each erased position, mirroring the q0-Let case
     already at expr's c-let/q=0), consuming kept `params` for the rest, so de
     Bruijn stays aligned. Then a poly `length`/`if`/`k` compiles + runs native
     through the chirality driver.
  Verify via `test_compile_run_chirality`'s MetisCompiler on poly programs. This is
  de-Bruijn-sensitive trusted-lowering work -- execute with fresh focus, one edit
  at a time, suite green after each.
- **B2 chirality — defunctionalization in `closconv-driver.chiral`.** Only
  `arrow-key-eq` is mirrored; the erased `$clo`/`$apply` synth + `$W` structural
  install + collection must be ported. Builds on B1b part 2.
- Then B3/B5 coverage, B6 (3-image, entangled w/ B2-layer-2), B7 determinism,
  B8 W^X, B9 wire. **No more conceptual walls (B1/B2 were the hard ones) — but
  several careful integration slices. The fixpoint is not one bit away.**

## Corpus lowerability TODAY (cascade removed, per image)

Intrinsic census = every def's signature pre-seeded so only its OWN blocker shows
(the "call target X not lowered" cascade is downstream noise — 243 of 282 front
skips were pure cascade).

| image | defs | lower now | poly "dependent" | other real leaf |
|---|---|---|---|---|
| compile-front | 558 | **507 (91%)** | 38 | 2 non-tail-case |
| compile-back  | 97  | **82 (85%)**  | 6  | (cascade on poly) |
| compile-emit  | 299 | **192 (64%)** | 37 | **17 field-enc-of-a-rel** + 3 non-tail-case |

The frontier is **narrow but layered**: a handful of low-level poly/HO/field
blockers gate a long cascade. Fix the leaves and the corpus climbs to near-total.

## The blockers, pinned to code

> **B1 STATUS 2026-08-03 — DONE (Python native + chirality partition mirror), 648
> green.** q0 erasure confined to the lowering pass (kernel sig untouched):
> `lower.py` `_peel` drops q0 Pi binders, `ttype(VNe)->WORD`, `lower_all` keeps
> the erased-position map, `Low.fn` walks all binders (q0 = placeholder reg),
> the App site drops q0 args; `tal.py` gains `WORD` + recursive `_wcompat`
> (I64/Str/Bytes/Data-pointers are all one word); `native.py` `_word_rep`
> accepts WORD. **Verified end-to-end: a polymorphic `length/append/reverse`
> program compiles + RUNS natively = 6.** Chirality mirror `lib/lower.chiral`:
> `u-erased` UT arm, `any-quant?` linear-only, `doms-lower?` skips q0.
> Census climb: front 507->537, back 82->94; the 38 first-order poly "dependent"
> blockers gone. **REMAINING B1 piece = the chirality EMISSION mirror** (`compile-fn`
> q0 placeholder + drop-erased-args + a real `tt-word` carrier with word-compat
> in the chirality tal-check) so the chirality compiler itself emits poly fns -- needed
> for the fixpoint; testable on its own (add a poly fn to ECORPUS).

### B1 — polymorphism rejected as "dependent" (the master blocker)
- **Site:** `lower.py:88` (`_peel`). Poly fns are typed
  `append : (-> (0 A (type 0)) (List A) (List A) (List A))`. The first param is
  **quantity-0** (erased), but `_peel` sees the codomain mention `A` and raises
  `"dependent type"` *before* checking the binder is q0.
- **~40 unique fns:** `llen reverse append snoc concat length if head with-default
  cat-maybes alist-get alist-put alist-has find` (first-order) + the HO ones (→B2).
- **De-risked:** the monomorphic `(-> (List I64) I64)` recursive length **lowers
  fine** — the type param is the *only* blocker. `ttype((List A))` and
  `ttype(bare A)` return **None** today (the second half of the fix).
- **Fix = representation-uniform q0 erasure (two parts):**
  1. `_peel` — when a Pi binder is q0, **drop it** (no runtime word) and continue
     peeling the codomain with the var bound to a neutral, instead of raising.
  2. `ttype` — map an erased/neutral type expr to the **uniform one machine word**:
     `bare A` → the word rep; `(List A)`/`(Maybe A)` → the same one-word pointer
     `(List I64)` already gets (element type is erased at runtime — all one word).
- **Payoff:** unblocks the ~90% cascade (243 front + the back/emit backs). All
  first-order poly fns fall out immediately.

> **B2 CRUX + DECISION (2026-08-03, scoped, not yet implemented).** Traced
> `map-list` through closconv: it is left UNTOUCHED because defunctionalization is
> demand-driven and the poly HO param's arrow `(-> A B)` never matches concrete
> call-site arrows `(-> I64 I64)`. **The fix primitive — erasure-aware arrow
> keying — is validated:** erase each `_arrow_key` dom/cod to a uniform word-shape
> (arity + effects) so `(-> A B)`/`(-> I64 I64)`/`(-> Str Bool)` share ONE
> `$clo`/`$apply`. A 15-line `_erase_shape` in `closconv.py` does it; the existing
> compile/native tests stay green (concrete families still group correctly).
>
> **The wall it exposes:** a merged `$apply` calls concrete functions (`inc`,
> `notb`) with word/poly-typed args, which the dependent kernel's `check_def`
> REJECTS (no "any word" type in the kernel; `context index out of range` on the
> poly param's dangling type Vars). This is the classic poly-HO-defunctionalization
> vs dependent-typing tension. Three ways out:
> 1. **Erasure + structural install (ride B1) — CHOSEN.** Build word-shaped
>    `$clo`/`$apply`, install them WITHOUT the kernel re-check for merged-poly
>    families (declare+finish structurally), let B1's WORD lowering + `_wcompat`
>    carry the representation. This is the SAME soundness posture the project
>    already ratified for the closconv driver (HANDOFF: "installs $clo/$apply
>    structurally, not kernel-re-checked ... sound -- the native run is the
>    end-to-end check + the pure conversion is oracle-differential"). Rides B1,
>    no explosion. Cost: relaxes the Python oracle `_synth`'s re-check for the
>    merged-poly case (concrete-only families keep re-checking).
> 2. **Monomorphize** map-list per instantiation -- kernel-clean but code
>    explosion + a whole new pass; the map already chose erasure over this.
> 3. **Kernel Word type** -- clean types but invasive to the trusted core; a
>    universal-word type weakens the kernel's guarantees far beyond closures.
>
> **Implementation plan for option 1 (next session, fresh context -- trusted-core
> care):** (a) `_erase_shape` + erased `_arrow_key`; (b) in `_synth`, build the
> `$clo`/`$apply` types over word-shaped domains (a `$word` opaque nullary data
> type, or reuse an existing one-word carrier) so they are well-formed AND lower
> via B1; (c) install merged-poly `$apply` via declare+finish (skip the semantic
> re-check that the concrete arms defeat), keeping concrete families on the
> re-checking path; (d) mirror in `lib/closconv.chiral` -- `arrow-key-eq`/`core-eq`
> erasure (the one differential that fired: `(-> I64 I64)` vs `(-> Bool I64)` now
> key-equal); (e) verify map-list/foldl/filter lower + a HO-poly program runs
> native. Gate: the 19 front + 37 emit HO-poly sig-blocks clear.

> **B2 LAYER 1 DONE (2026-08-03, 648 green) — erasure-aware defunctionalization.**
> Implemented option 1: `_erase_shape`/erased `_arrow_key` (unifies poly + concrete
> arrows by word-arity), an opaque `$W` word carrier declared in `closure_convert`,
> and `_synth`/`_rewrite` try-concrete-recheck / fall-back-to-`$W`-structural-install
> (self-detecting: concrete families keep re-checking; merged/poly ones install
> structurally and ride B1's WORD lowering, `$W`->WORD via `ttype`'s neutral case).
> `_rewrite` now preserves each binder's quantity+seat (q0 type params stay q0).
> Chirality mirror: `lib/closconv.chiral` `shape-eq`/`shapes-eq` + erased `arrow-key-eq`.
> **PROVEN NATIVE: map-list/inc = 44, foldl/add = 42, filter = 50** -- HO poly fns
> defunctionalize + lower + run. Concrete closconv path preserved (all compile/
> native tests green).
>
> **B2 LAYER 2 (follow-on, needed to fire on the COMPILER'S OWN HO calls):**
> closconv does not yet collect a concrete closure passed at a DEPENDENT/poly-
> instantiated callee position -- e.g. `(alist-get Str I64 str-eq offs l)` fails to
> register `str-eq` because alist-get's 3rd dom `(-> K K Bool)` mentions the poly K
> (closconv's `_g_param_specs` explicitly defers dependent doms). So in the isolated
> compile-front image the 19 HO-poly fns form families with 0 ctors -> no `$apply`
> minted -> stay upper. Fix: instantiate the callee telescope with the actual
> leading type-args when recovering an arg's arrow type, so `str-eq` registers.
> Then the compiler's foldl/map-list/alist-get/m-lookup calls convert.
>
> **B2 LAYER 2 IS ENTANGLED WITH B6 (finding 2026-08-03).** Tried to validate on
> the isolated compile-emit image: `$apply0` mints for the arity-1 family (3
> ctors) but alist-get's arity-2 family has 0 ctors -- because `str-eq` (its
> concrete arg in `resolve`, asm-reloc.chiral:50) is NOT LOADED in the isolated
> image (`str-eq in defs? False`). The concrete closure sites live across the
> 3-image split, so per-image lowerability UNDERCOUNTS and layer-2 collection
> cannot be cleanly validated until the image-loading story (B6: unify vs
> shuttle) is settled. Layer 2 + B6 should be scoped together.

### B2 — higher-order poly fns need closconv-at-scale
- `map-list foldl filter foldr find any-list maybe-map maybe-then` are poly **and**
  take a function param → defunctionalize. closconv handles `ap inc`; these are
  recursive-over-list HO closures (closconv.py §6 residue: nested/linear captures).
- **Also here:** the deferred hardening — closconv installs `$clo`/`$apply`
  *structurally*, not kernel-re-checked (sound today; re-check turns a conversion
  bug into a check alarm). And the closconv self-crash on a poisoned family calling
  a converted peer (surfaced in the emit-image census) needs handling for a full
  self-compile.

### B3 — function-typed data field ("field enc of a-rel", 17 emit defs)
- `asm-reloc.chiral:16` — `(a-rel (sz I64) (enc (-> I64 Bytes)) (l Str))`: a data
  ctor storing a **function value** in a field. Won't lower (the field is not a
  ground TalTy).
- **Fix (choose in-pass):** (a) closconv represents a function-typed field as a
  `$clo` pointer (defunctionalize the stored fn), or (b) rework `a-rel` to carry a
  tag+data instead of a closure. (a) is the general answer and composes with B2.

### B4 — non-tail case (5 defs)
- "non-tail case needs an expected type from context" — `ctor-field-types`,
  `parse-let` (front) + 3 emit. Known E16 gap: supply the expected type at the
  non-tail `case` site (the outlining path already exists for tail cases).

### B5 — sys face in the compile path
- `tal-reify` reifies `ti-const…ti-blen` but **not `ti-sys`/`ti-bptr`** (reify
  stops at line ~35). Wire those two arms. Plus the E70 native residue:
  `prim <crossing>` → E51 wrapper → syscall routing in the mach layer.
- **Scope note:** the compile CHAIN is largely pure; only 78 `=>` lines across the
  whole lib, mostly outside the 30-file self-compile closure. Needed for real I-O
  and any effectful compiler def, but not on the hot path for most of the 8K LOC.

## The fixpoint-gating slices (after the corpus lowers)

### B6 — the 3-image co-load collision (dedup / rep-unification)
- `compile-back`/`compile-emit` can't co-load: `data Term redeclared`,
  `global resolve redefined`; three duplicate tal IRs; kernel-`Term` vs
  surface-`Core` vs closconv-`Core` vs lower-`Core`.
- **Decision needed:** unify into ONE rep, **or** keep the per-image con-value
  shuttle the current driver already uses (compile each image separately, transport
  inert con-values). The shuttle already works for the toy fragment — extending it
  is the lower-risk path; the unification is the cleaner-but-cross-cutting one.

### B7 — determinism for byte-identity
- The `$clo`/family naming rides `closconv.py` `sorted(key=repr)` (repr-dependent →
  reaches emitted names). Needs the source-reproducible canonical order (ty-cmp/D-1
  is built but has no consumer yet) adopted on BOTH stages.
- Any other layout order (def emission order, literal-table interning) must be
  source-deterministic, not dict/hash-iteration order.

### B8 — W^X second RW PT_LOAD
- Currently one RWX segment; split code (RX) from data/literals (RW). Independent
  of the corpus work; can land any time.

### B9 — wire the fixpoint + DDC
- Drive `compile` over the compiler's own source (per-image, B6), twice,
  `fixpoint=?` byte-compare; retire `native.py` `NativeBackend` from `emit_leg0`;
  E53 DDC across provenance-disjoint legs (`ddc.chiral` core built).

## Dependency-ordered plan

```
B1 (q0 poly erasure)  ── the keystone; unblocks the cascade
 ├─► B2 (HO poly / closconv scale)   ┐
 ├─► B3 (fn-in-data-field)           ├─ parallel once B1 lands
 └─► B4 (non-tail case)              ┘
B5 (sys reify + native routing)      ── independent-ish; needed for effectful defs
B6 (3-image collision)   ── gates the fixpoint wiring  ── DECIDE: unify vs shuttle
B7 (determinism order)   ── gates byte-identity
B8 (W^X split)           ── independent, any time
B9 (wire fixpoint + DDC) ── last; decidable once B1–B7 run natively
```

## Per-slice discipline (unchanged from the build wave)

Each slice is **differential vs its Python original** (the real oracle): mirror the
erase/reify/case-fix in BOTH `lower.py`/`tal-reify.py`/… and the chirality `lib/*.chiral`
port, and require agreement across the suite. Trusted-core diffs (kernel/data/lower)
shown explicitly. One slice = one commit + INDEX/checklist flip. Re-run the
intrinsic census after B1–B4 to watch the corpus climb — that number is the
progress bar to the fixpoint.

## The reusable measurement (re-run to track progress)

The census script pattern: load each image, `closconv.closure_convert`, pre-seed
`env.fn_sigs` with every def whose type peels, compile each body, bucket the
intrinsic failures. Cascade-free lowerability per image is the progress metric.
```
lower now / defs, by image  →  fixpoint reachable when all three ≈ 100%
```
