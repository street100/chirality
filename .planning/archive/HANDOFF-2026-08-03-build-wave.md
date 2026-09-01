> **ARCHIVED 2026-09-01. Superseded by the tracked root `HANDOFF.md`, which is a different document.** Renamed on archive for exactly that reason: two files named `HANDOFF.md` in one repo is how a session reads the wrong one. Last touched 2026-08-03, two days before the rung-1 fixpoint landed. It is kept and not cut because it carries per-element implementation provenance for E1-E52 that exists nowhere tracked.

# HANDOFF — the BUILD WAVE (rung-1 self-host) — READ THIS FIRST

> **⚑⚑ READ FIRST (2026-08-03): `.planning/RUNG1-CRITICAL-PATH.md`.** The piece-
> wise ports are done, but rung 1 is NOT "finish a few ports + wire the fixpoint."
> The verify-first for req #2 surfaced the real remaining core: the chirality kernel is
> **core-calculus only** (no globals/data/case), there is **no full `Sig`**, and
> **no compiler loader** — the whole "E2-loader / full-ADT assembly" seam. That
> subsystem (full `Sig` → full-ADT kernel → loader → native integration → fixpoint)
> is the long pole; req #2 is a sub-step of it, not standalone. That doc is the
> dependency-ordered roadmap and supersedes the "two remaining reqs" framing below.

> ## ⚑ CURRENT STATUS (2026-08-03, session 3 — the full-ADT kernel keystone)
>
> **570 green.** This session built **`RUNG1-CRITICAL-PATH.md` items 1+2 — the
> full `Sig` + the full-ADT kernel** (the keystone the whole spine rests on),
> driving the orphan `E04-full-adt-kernel-SPEC` through a spec-audit then
> implementing all 4 slices, 1-by-1, each differential vs `kernel.py`:
> - **spec-audit (BLOCKED→resolved):** found the SPEC's slice-4 plan assumed
>   baseline capabilities that didn't exist. Resolved with the author toward the
>   FAITHFUL path (no reductions — the reductions broke differential-is-oracle):
>   #4 lift `DataDecl` to kernel `Term` (proven needed: else `(List 5)` diverges);
>   #5 add linear registries to `Sig`; #6 wire narrow; #7 extract a leaf for the
>   Term-cycle. SPEC → `audited`.
> - **4a-i** `lib/syntax.chiral`: the shared full-ADT `Term`+`KArm`+`Seat` extracted
>   to a leaf (breaks the kernel↔data cycle the Term-unify triggers). Pure refactor.
> - **4a-ii** `DataDecl`/`Field` → kernel `Term`; E6 solver + E7 positivity
>   re-ported over `Term` (toward `data.py`'s oracle, which walks Terms); E8
>   untouched (self-contained).
> - **4b-i** the `con`/`tcon` typing arms + `Sig` linear registries + `is-linear`;
>   differential incl. the `(Box 5)` kind-MISMATCH rejection (#4's whole point) +
>   linear-field rule.
> - **4b-ii** the `case` arm (coverage/binding/QTT-usage/escapes/exhaustiveness);
>   differential over exhaustive/non-exhaustive/dup/default/field-bind/nested.
>
> **The chirality kernel now checks real programs** (globals+data+case+literals), so
> item 3 (the loader) is unblocked — that's NEXT.
>
> **DECISION #6 — NOW COMPLETE (session 3 cont., 588 green).** The narrow residue
> flagged above was DONE, not deferred: the full VRefine-in-kernel-Value
> integration was ported in three trusted-core slices, each differential vs
> `refine.py` (its hooks became closed-sum arms):
> - **R1+R2** (`653fd3b`): `t-refine`/`v-refine` + eval (fold operands into a
>   Constraint) + quote (normalizing `< 5`→`<= 4`) + conv (base-conv + structural
>   constraint eq) + subtype (refine<:refine via `entails`, forget, base<:refine
>   only-if-TOP) + infer (`check-refine`) + check-against (entailment OR a literal
>   that satisfies). `refine.chiral` gained the constraint builders (`c-atom` etc.).
>   9-case differential (eval/quote roundtrip, check literal in/out/nonzero, the 3
>   subtype rules).
> - **R3** (`36cc4e9`): `narrow-branch` in the case arm — the `_narrow` port
>   (comparison-spine unwind + `_LEARN` table + `ctx-narrow`, symbolic bounds by
>   de-Bruijn level), threaded via `scrut` through the branch helpers. 9-case
>   differential driven DIRECTLY on `refine.py._narrow` (`<i`/`<=i`/`=i` ±branch,
>   symbolic `(< i j)`, no-narrow shapes). The case arm is now fully faithful to
>   `kernel.py`, path-sensitivity included.
>
> **⚠ ONE residue left + the NEXT step:**
> 1. **ty-cmp residue (deferred, speculative):** the skeleton `Ty` is now
>    vestigial (only `ty-cmp.chiral` imports it). "Move ty-cmp to a `Term`/`Value`
>    order" — BUT it has no consumer yet (the fixpoint seen-set that would use it
>    isn't built), so the exact target is speculative; leave it until the fixpoint
>    exists rather than build the wrong order. Determinism debt, not blocking.
> 2. **ITEM 3 (the LOADER) — back half BUILT** (session 3 cont., 597 green).
>    `lib/loader.chiral`: the **Core→Term bridge** (`core->term`, decision #1) +
>    the **def driver** (`load-def`/`load-unit`, = kernel.py check_def) + the
>    **data driver** (`load-data`, = check_data: params-are-types, install-for-
>    recursion, fields typed + strictly-positive + linear-kind-judged). LItem =
>    def | data; `load-items` threads the growing Sig. **The chirality loader loads
>    real programs — data types + functions — and type-checks them, differential
>    vs `Elab().load_str`** (function cases + whole programs: data Bool+neg,
>    Box+unbox, parameterized Lst+case). `test_loader_chirality.py`.
>    - **FRONT HALF NOW BUILT (614 green):** `lib/parse.chiral` — `parse : Sexp→Surf`
>      (all 13 Surf forms) + the top-level loop threading a kernel `Sig` AND an elab
>      `SEnv`, handling `(def …)` and `(data …)` (the deferred E2 data-decl elab),
>      wrapped by **`load-source : Str → LoadR`**. Differential vs `Elab().load_str`,
>      17 accept/reject cases. **The loader is SOURCE-DRIVEN end to end for def+data
>      programs.** `test_parse_chirality.py`.
>    - **LOADER NOW COMPLETE (633 green) — see the SESSION-3 CHECKPOINT at the top
>      of `RUNG1-CRITICAL-PATH.md`.** `t-let` lifted (`let`/`do` check; `330bf7a`),
>      `extern`/`porttype` in the source loop (`fd39a49`), forward-`declare` +
>      `(def name body)` + **mutual/self recursion** (`561bd5c`). The whole
>      check path is chirality + source-driven; every construct the compiler's own
>      source uses is covered, differential vs `load_str`.
>    - **REMAINING = the back half (the long pole):** check → closconv(E69) →
>      lower(E16) → emit(`emit-x64`/`elf`, EXIST) → native → fixpoint → DDC. The
>      stages exist as ISOLATED differential ports and **don't yet compose** —
>      gated on the **tal-IR/`Core` rep-unification (the dedup debt)**. Then the
>      `compile` driver wires, the CPython `NativeBackend` is retired (item 4),
>      then Stage1==Stage2. Loader residue (smaller): `import` (file-read sys
>      face), double-finish, `measure`, indexed porttype. The rep-unification is a
>      cross-cutting design call — scope it WITH the author, not a blind chug.
>    - Known limit to lift before globals-in-types: `eval-term` doesn't unfold
>      globals (a type mentioning a global stays a stuck neutral) — the slice-3
>      eager-global-unfold residue; fine for the current corpus.
>
> Prior status block (session 2 — the E69/E70-port + sig-driver wave):

> ## ⚑ CURRENT STATUS (2026-08-03, session 2 — the E69/E70-port + sig-driver wave)
>
> **537 green.** This session drove the **E69→E70 port chain + the sig-driver**
> (the real remaining rung-1 work per the correction block below). Landed, in order:
> - **E70 port pure half** — `lib/eff-lower.chiral`: the reachable-crossings walk +
>   row-escape verdict (slice 1), `sysface` projection + `=>` gate `eff-gate`
>   (slice 2). Differential vs the real `lower.py._reachable_crossings`/`.sysface`.
> - **E02 row-inference** (`lib/row-infer.chiral`) — the sig-driver's ROW half: the
>   monotone call-graph closure producing `def_rows`, porting `surface._infer_row`.
>   **Scoped through the FULL pipeline** (example→audit→spec→audit, both PASS) then
>   implemented. Differential vs the real `surface._infer_row` over 7 closure paths.
> - **sig-driver Group A** (`lib/sig-derive.chiral`) — the last given-input
>   derivations: `prim-is-port` (kernel is_port), `bound-crossings`
>   (`lower._bound_crossings`), `scan-calls` (`surface._scan_unit` call graph).
> - **sig-driver Group B** (`lib/sig-driver.chiral`) — `EffSig(ports,bound,dr)` +
>   `build-effsig`/`eff-eligible?`/`check-def-row`. **The E70 floor check now runs
>   end-to-end on chirality-DERIVED data — no given inputs.** Design call (E02 SPEC
>   dec #1): a focused `EffSig` view, NOT a SigV extension.
> - **E70 emission (tal level)** — `compile-fn` emits a bound `=>` crossing as an
>   `i-prim`, byte-identical to `lower.py` (crossing sig fed through the prim
>   table; NO edit to tested E16). The E70 mechanism is complete end to end:
>   derive row → gate → emit crossing-as-prim → preserve-check.
>
> **The two E69/E70 completion reqs (of my "complete 1 by 1"):**
> 1. **E70 emission — DONE at the tal level** (above). Residue = native `prim
>    <crossing>` → E51-wrapper → syscall routing in the **mach layer** (native
>    codegen exists per DESIGN §7b — membrane relaxation + routing, not new
>    codegen); + a single integrated effectful `lower-all` driver.
> 2. **E69 sig-mutation kernel-re-entry driver** (declare/finish/check-def +
>    check-data installing the `$clo` data + `$apply` defs + rewritten bodies) —
>    **SCOPED, unblocked, ready:** `.planning/E69-sig-mutation-PLAN.md`. (I first
>    called it blocked on the dedup debt after `closconv+data` failed to co-load,
>    but re-analysis: #2 does **not** import `closconv` — it takes closconv's
>    OUTPUTS as data, imports only `data`+`kernel` (verified co-load clean), and
>    produces an updated `SigV` validated through the ported E4/E6/E7 judgments.
>    Take-as-data, the session's pattern. The plan has the change plan + gate +
>    the one verify-first risk.)
>
> **⚠ NEWLY-SURFACED DEBT (the #2 blocker + the session's recurring drag):** chirality
> has **no namespacing**, and many modules independently define the same helper
> globals — **`llen` in closconv/data/kernel/lower/collections; `Ord` in
> ty-cmp/data/collections/row-infer; `Instr`/`Block` in BOTH lower.chiral and
> tal-check.chiral** (an IR duplication). Co-loading any two that overlap =
> "global X redefined". Worked around thrice this session (inlined `str-cmp` into
> row-infer to drop the ty-cmp→data `llen`/`Ord`; kept sig-driver off closconv;
> ran the emission test in an isolated Elab). **The clean unblock for #2 (and
> future composition) is a dedup pass:** hoist the shared list/order helpers into
> a common leaf (or systematic rename), and unify the two tal-IR definitions. This
> is a cross-cutting refactor of trusted modules (each has a differential).
> **NOT a #2 prerequisite** (see #2 above / plan §5) — it's friction-reduction,
> chiefly for the single-integrated-effectful-`lower-all` driver (the E70 emission
> residue, which the tal-IR unification unblocks). Full inventory + categories in
> `.planning/E69-sig-mutation-PLAN.md` §5.
>
> All new files are differential-tested vs their Python originals (the real
> oracle). Prior status block (still valid for the checker/compiler port tiers):

> ## ⚑ CURRENT STATUS (2026-08-02)
>
> **Scoping is COMPLETE — every drafted element is `audited` or `implemented`**
> (`examples/INDEX.md` is authoritative). The only remaining rung-1 work is the
> **BUILD WAVE**: port the checker/compiler (E1–E18) from Python to chirality, then
> the capstone (E52 + E45 + the Stage1==Stage2 fixpoint + DDC). **This file is the
> implement worklist.** A new/compressed chat: read this top block + the 1-by-1
> loop + the checklist, then open the SPEC of the element you're building.
>
> **rung 1 = zero CPython in the check/compile/run path, on Linux.** Done when the
> fixpoint is byte-identical and DDC converges. (rung 2 = metal + app layer, later.)
>
> **Baseline: 430 tests green** (`python3 -m unittest discover -s scaffold/tests`).
> Determinism debts D-1/D-2 **scaffold-side PAID**; the port-side D-1 mirror is
> Tier 0 below. Lanes prep/1/2/3/4 are built (E39/E50/E69/E70 + syscalls).
>
> **Already implemented (past the pipeline):** E27, E28, E29, E30, E32, E34, E40
> (type-level), E50, E53, E69, E70, E71, E72, E79; partial: E31 (steps 2–3), E39
> (steps 1–6), E51 (v1). Codegen (E19) is already chirality. Everything else on the
> checklist is `audited` = SPEC-ready.
>
> **⚠ SCAFFOLD-vs-PORT correction (2026-08-03, verified against INDEX +
> CONFORMANCE-MAP, which win over this block):** the E69/E70 above are the
> **scaffold capability** (`scaffold/chirality/closconv.py` — 858 LOC, wired at
> `lower.py:394`, 14 tests green; the effectful `=>` gate). The **chirality-side
> port** (`lib/closconv.chiral`, `lib/*` effectful lowering) is what INDEX tracks
> as `audited` and what the fixpoint actually needs — Stage2's native compiler
> must contain its OWN closure-conversion/effectful-lowering pass, in chirality.
> **The two unchecked rows below are therefore NOT runnable steps** — the DDC
> harness's own docstring says the "true Stage1==Stage2 cross-stage fixpoint is
> out of scope until E70 leg-running lands" (its `ddc-converged` today is
> near-term admission + leg-0-twice reproducibility, `emit_leg0` still calls the
> CPython `NativeBackend`); CONFORMANCE-MAP: "true Stage1==Stage2 fixpoint +
> leg-running are E70-gated." The real remaining rung-1 chain is **E69-port →
> E70-port → full shared-`Term`/sig-driver → native self-emission → fixpoint →
> DDC**, not two checkboxes. **E69-port foundation slice LANDED 2026-08-03**:
> `lib/closconv.chiral` `free-indices`+`remap` over the `Core` IR (the pure
> de-Bruijn core all later phases rest on), differential vs `closconv.py`
> `_free_indices`/`_remap` (17 free-index + 119 remap cases), `test_closconv_chirality.py`,
> 493 green. **Slice 2 LANDED 2026-08-03**: the pure arrow-key + shape predicates
> — `core-eq` (structural equality, the chirality stand-in for `closconv.py`'s
> hash-based `_freeze`/`_arrow_key`, since chirality has no hashing), `peel-pi`,
> `pi-effs`, `is-arrow`, `arrow-key-eq`, `peel-lams`, `first-order-body` —
> differential vs the `_peel_pi_terms`/`_pi_effs`/`_is_arrow`/`_arrow_key`/
> `_peel_lams`/`_first_order_body` oracles, 499 green. **Slice 3 LANDED
> 2026-08-03**: the read-only sig-view + type queries — an immutable `SigV`
> (types + def-bodies as `Core` assoc-lists) + `sv-type`/`sv-def`/`arity`/
> `g-param-specs`/`ty-of`/`callee-doms`/`def-ctx` (+`DefCtx`), differential vs
> `_type_term`/`_arity`/`_g_param_specs`/`_ty_of`/`_callee_doms`/`_def_ctx` driven
> against a REAL loaded signature (quoted types bridged to `Core`), 504 green.
> **Slice 4 LANDED 2026-08-03** — `collect`, the classification walk (the heart):
> the Python pass mutates three dicts/sets (families/ho-keys/poisoned) through
> nested closures; the chirality port threads them as an immutable `CState`, deduping
> families by `arrow-key-eq` and closure ctors by `csite-key-eq` into assoc-lists
> (`Csite`/`Family`/`CState` + `cwalk`/`cwalk-app`/`reg-lam`/`scan-fvargs`/…).
> Differential vs `_collect` against a 7-def corpus exercising every path
> (partial-app, function-value arg, escaping `(the .. (lam ..))` literal,
> higher-order Var-head param, unsaturated-use poisoning): families + ho-keys +
> poisoned compared as canonical SETS, exact match, 506 green. **Slice 5 LANDED
> 2026-08-03** — `synth`'s term-building: `arm-body` (the de-Bruijn re-addressing
> for each dispatcher arm — g-site and lam-site substs), `mk-pi`/`mk-lams`, and
> the `$clo`/`$apply` assembly (`apply-ty`/`apply-body`/`ctor-name`/…).
> Differential vs `_arm_body` over every collect site + `_mk_pi`/`_mk_lams`/
> assembly, 511 green. **Determinism seam FLAGGED:** the ctor/family naming
> (`$clo<i>`/`$apply<i>`/`$k<i>_<j>`) rides `closconv.py`'s `sorted(key=repr)` —
> a repr-dependent order that reaches emitted names, so the port needs a
> source-reproducible canonical order (ty-cmp/D-1) adopted on BOTH stages; this
> is a new fixpoint-determinism item (postdates DETERMINISM-DEBTS). **Slice 6
> LANDED 2026-08-03 — the PURE PIPELINE IS COMPLETE.** `rewrite` (`rw`/`lam-con`/
> `cspine` + `Ckey`/`ApplyEnt`): the term→term body rewriter (capture-lam→`Con`,
> saturated HO Var-app→`$apply` call, partial Global→capture `Con`, value
> Global→nullary `Con`), driven by the synth map as a `(List ApplyEnt)` looked up
> by `arrow-key-eq`. Differential vs the oracle `rw` by driving the real
> collect→synth→rewrite install pipeline on a fresh sig and comparing each
> rewritten body (peeled of its param-lams) for-value, 518 green. **Oracle
> limitation surfaced:** `closconv.py` ITSELF crashes when a poisoned family's def
> also calls a converted peer (`$clo0` vs `(-> I64 I64)` mismatch at install) —
> so the rw install-differential uses a poison-free corpus (collect keeps the
> poison def, read-only). **What remains of E69-port is ONLY the deferred driver
> residue:** the stateful pass that mutates `sig` + re-enters the kernel
> (`_erase_q0`, `declare_def`/`finish_def`/`check_data`, the `$apply`-first
> reorder, the arrow-typed-param→`$clo` type rewrite) — homed at the E2-loader,
> per the E16 partition-slice precedent. The pure algorithmic core (free-indices,
> remap, arrow-key, sig-view, collect, synth term-building, rewrite) is all
> ported + differential-clean.

## How a build session works (the 1-by-1 loop)

1. **Pick** the top unchecked element whose deps are all `[x]` (the checklist is
   dependency-ordered — top-down is always safe).
2. **Read its SPEC** — `.planning/specs/E<NN>-*-SPEC.md`. The **§4 change plan is
   the contract**; §5 is the conformance gate; the `examples/E<NN>-*.md` is the
   rationale. (The SPEC's own §2/§3/§6 name its exact deps + residue.)
3. **Implement §4** into `scaffold/lib` / `scaffold/chirality`. Every port element is
   **differential vs its Python original** (the reference is the oracle).
4. **Gate:** run §5's named tests + the full suite; must stay green + match the
   differential. Trusted-core files (`kernel`/`terms`/`data`) — **show the diff
   explicitly** (standing discipline 5; these are the most sensitive class).
5. **Commit** the element (one element = one commit). Check it off here **and**
   flip its `examples/INDEX.md` row to `implemented` in the same commit.
6. **Stop or take the next.** The user drives cadence — **no unbidden agent
   spawns / batch spend**; "keep going" is direction, get an explicit go that
   names the element(s).

## THE IMPLEMENT CHECKLIST (dependency-ordered — top-down is safe)

Legend: `[ ]` not built · `[x]` implemented. Each row: element · target file ·
**deps** (must be `[x]`) · **unblocks**. SPEC at `.planning/specs/E<NN>-…-SPEC.md`.

### Tier 0 — prep tail · do first, parallel · unblocks the fixpoint
- [x] **D-1 port-side mirror** — **DONE 2026-08-03** — `ty-cmp : (-> Ty Ty Ord)` in
  `lib/ty-cmp.chiral`, a total STRUCTURAL order over data.chiral's closure-free `Ty`
  (mirrors the scaffold `_tyv_key = _freeze(quote tyv)`: the chirality `Ty` is already
  normal-form syntax so the "quote" is trivial; structure not `repr` = no collision).
  Strings compare byte-lexicographically via `str->bytes`+`bget` (no `bcmp` primitive
  needed — composed from the byte face). Differential vs an independent Python
  reference total order over ALL 14×14 pairs (equality/order/string-lex/list-length/
  every ctor) + total-order laws, `tests/test_ty_cmp_chirality.py`, 482 green. NOTE: no
  consumer yet — the chirality E8 linear walk is depth-BOUNDED, not seen-set-based; this
  is the seen-set key ready for the fixpoint (its determinism property is what's owed).
  See `DETERMINISM-DEBTS.md`.

### Tier 1 — foundation · no deps · unblocks everything · parallelizable
- [x] **E13** de Bruijn `Term` machinery → `lib/terms.chiral` · deps: none · unblocks E3/E6/E9/E2/E14 · **DONE 2026-08-02** (closed core `Term` + `uses-below`/`shift-close`, differential vs `terms.py`, `tests/test_terms_chirality.py`, 434 green)
- [x] **E5** QTT quantity semiring → `lib/qtt.chiral` · deps: none · unblocks E3/E4/E6/E15 · **DONE 2026-08-02** (`Qty` + 4 semiring ops + 4 vector ops, differential byte-equal vs `kernel.py` + semiring laws, `tests/test_qtt_selfhost.py`, 441 green)
- [x] **E1** S-expression reader → `lib/sexp.chiral` · deps: none · unblocks E2 · **DONE 2026-08-02** (byte-directed reader, errors-as-values, differential vs `sexp.py` incl. reject set, `tests/test_sexp.py`, 444 green; caught a real `;`-delimiter bug)

### Tier 2 — trusted spine · sequential critical path
- [x] **E3** NbE eval/quote/conv → `lib/kernel.chiral` · deps: E13, E5 · unblocks E4/E6/E14/E15 · **DONE 2026-08-02** (shared `Term`/mutual `Value`/`Clos`/`Neut`/`Seat` ADT defined here; eta-first conv, q+seat part of `=`; differential vs `kernel.py` NbE — normalize + conv incl. eta/qty/seat, `tests/test_nbe_selfhost.py`, 446 green. Trusted-core; core not asserted `(total)` per the fuel-verdict SN posture. **The shared ADT is now fixed — E4/E6 extend it here.**)
- [x] **E4** bidirectional infer/check + universes → `lib/kernel.chiral` · deps: E3, E5 · unblocks E6/E12 · **DONE 2026-08-03** (infer/check/subsume/subtype, errors-as-values + QTT usage vectors + Ctx; reshaped `q:I64→Qty` +t-ann, E3 unbroken; differential vs membrane-wired `kernel.py` — accept/reject + type + usage over 13 cases, `tests/test_bidir_selfhost.py`, 448 green. **SPINE COMPLETE.**)

### Tier 3 — data + checks · parallel once the spine exists
- [x] **E6** data: ctors/coverage/ctor-params → `lib/data.chiral` · deps: E3, E4 · **CORE DONE 2026-08-03** (grammar + coverage + solver, REAL differentials vs `data.py` live checker + `_infer_ctor_params`, `tests/test_data_selfhost.py`, 450 green). **Remaining: Step-4 check-con/check-case handlers → E10-gated** (narrow-hooks + VCon/VTCon eval arms) — a follow-on after E10.
- [x] **E7** strict positivity (beside E6) → `lib/data.chiral` · deps: E6 · **DONE 2026-08-03** (hit?/mentions?/walk/walk-args + compute-sp; unified `data.chiral` Ty; REAL differential vs `data.py` `_positivity` load accept/reject, `tests/test_positivity_selfhost.py`, 452 green)
- [x] **E8** linear-kind (beside E6) → `lib/data.chiral` · deps: E6 · **DONE 2026-08-03** (`linear-ty`/`fields-lin` bounded walk, three-valued `LinR`; REAL differential vs `data.py` `K.is_linear` on loaded decls, `tests/test_linear_selfhost.py`, 453 green)
- [x] **E9** refinement decision proc (built fragment; E41 arith is a later EXTEND) → `lib/refine.chiral` · deps: ~none · **DONE 2026-08-03** (`Constraint`+`is-empty`+`entails`, REAL differential vs `refine.py`, `tests/test_refine_engine_chirality.py`, 455 green; provides entails/Constraint to E10)
- [x] **E10** occurrence typing / narrow → `lib/refine.chiral` · deps: E9 · **DONE 2026-08-03** (`narrow` atom-selector; REAL differential driving `refine.py._narrow`, `tests/test_refine_narrow.py`, 457 green). **Unblocks E6 Step-4 check-case handlers.**
- [x] **E11** totality classifier → `lib/totality.chiral` · deps: E6, E50 (built) · **DONE 2026-08-03** (single-function classifier: structural + numeric-measure termination; assoc-list `Sizes`/`Bounds` mirror `data.py`'s dicts; the I64-wraparound obligation carried in `num-dec-ok` against real `I64-MAX`/`I64-MIN`; port adds `t-lit` over the example's 5-ctor `Term` for the numeric cases. SEMANTIC differential vs `data.py:_totality_reason` over 8 cases — 4 total/4 not-total spanning structural/symbolic/wraparound/value-use/unbounded/non-recursive, `tests/test_totality_chirality.py`, 463 green. Mutual/lex = E50; enforce-flip = EXTEND, gated on E47+E50 — both out of scope)
- [x] **E12** effect membrane → `lib/effects.chiral` · deps: E3/E4, E39 (built) · **DONE 2026-08-03** (3 rules over names-list row algebra; REAL differential vs `effects.py` Rules + `row_subsumes`, `tests/test_effects_chirality.py`, 461 green)
- [x] **E14** pretty-printer (non-trusted) · deps: E13, E3 · **CORE DONE 2026-08-03** (`lib/pretty.chiral` `show-term`, string-for-string differential vs `pretty.py`, `tests/test_pretty_chirality.py`, 458 green; full former set = extension at ADT assembly, `show-value` E3-gated)
- [x] **E2** surface elaborator → `lib/surface.chiral` · deps: E1, E13, E51 (v1 built) · **DONE 2026-08-03** (the elab/resolve CORE: name→deBruijn over an immutable `(List Str)` ctx, the ~13-way `Surf` dispatch, six-way `resolve` over a threaded `SEnv`, and elab-time desugar of cond/the/refine/multi-lam/let/do — all pure/errors-as-values via a polymorphic `PR`. `Core` mirrors `terms.py`'s tuples; Pi seat = the eff bit (EMPTY/DYN), q∈{0,1,w}→{0,1,2}. SEMANTIC differential vs `surface.py.elab` over 21 accept cases (every dispatch + resolution + desugar, deBruijn depth) + 3 rejects surfacing as `p-err`, `tests/test_surface.py`, 465 green. Deferred within E2 (each homed in SPEC §6): verify/profiles, data-decl elab, row inference (E39-coupled), import loader (E51), CLI)

### Tier 4 — pipeline tail
- [x] **E18** TAL checker + tal interp → `lib/tal-check.chiral` + `lib/tal-eval.chiral` · deps: E3-adjacent · **PROVIDES `ck-fn`/`ck-prog`** to E16/E17 · **DONE 2026-08-03** (two files. CHECKER: `ck-instr`/`ck-block`/`ck-term`/`ck-fn`/`ck-prog` over a typed IR, register Gamma `REnv` threaded not mutated, `CkR` errors-as-values, exhaustive `case` over `data Instr`; ports `tal.py` `check_fn`/`_check_block`/`_check_args`/`_fields`. INTERP: `tal-eval` with explicit threaded `Store` (cell=id, `bnew` zero-init, `bput` returns new Store) + strictly-decreasing fuel → `r-oot`; ports `TalMachine`. Pure floor only — sys/bptr omitted (§6). SEMANTIC differential vs `tal.py` — checker accept + 6 reject reason classes, interp values on 6 golden progs incl. byte rw through the store, fuel→r-oot, and the ck-ok⇒never-r-err soundness cross-check, `tests/test_tal_chirality.py`, 470 green)
- [x] **E16** lowering pure→tal → `lib/lower.chiral` · deps: E18 · **DONE 2026-08-03** (both halves). PARTITION: `ttype` + `eligible?`/`skip-reason` + `lower-all` (pure/total, `LowRes`), differential vs `lower.py.lower_all` — 4 defs exercising each gate branch in order (pure-ground→lowered, linear q=1→"quantified", function-param→"type does not lower", dependent→"dependent type"). EMISSION: `compile-fn` (Low.fn/tail/expr) — SSA fresh-register threading through a state `St` + non-tail-`case` OUTLINING into `name$k` (live-regs-as-params) — emits tal (ctor names match `tal-check.chiral`). **BYTE-IDENTICAL differential vs `lower.py.Low.fn`** on 5 defs incl. the outlined `pick1$0`, AND every emitted `TalFn` passes E18 `ck-prog` (the preserve-check). `tests/test_lower_chirality.py`, 474 green. NOTE: q=0 binders are closconv-erased and DO lower; str-const skipped (tal const is I64 at this floor). Residue: register/slot packing = E17 (decision #1); eligibility widening (closures/HO) separate)
- [x] **E17** optimizer → `lib/optimize.chiral` · deps: E18, E16 · **DONE 2026-08-03** (tal→tal passes on the TYPED IR `optimize.py` rewrites — `(import "tal-check")` reuses E18's IR + `ck-fn`, so the preserve-check is REAL not forward-declared. `fold` (const-arith + cmp→con + static case dispatch), `dead` (DCE via bounded liveness fixpoint), `specialize-raw` (remap + bind static args → residual = the pregen primitive), + `optimize`/`specialize` returning a `Checked` result sum via `re-check`(`ck-fn`). Differential vs `optimize.py` — fold BIT-IDENTICAL (incl. static-case inline), DCE drops exactly unused defs, specialize residual matches `_remap_block`, and `optimize` returns `chk-ok` passing the real E18 check. `tests/test_optimize_chirality.py`, 478 green. This EXCEEDS the SPEC's E18-gated scope (re-check was E18-gated; E18 landed so it's wired end to end). NOTE: SSA-precondition check skipped (fold assumes lowering's monotonic fresh, as the corpus provides); no cost claim (E38))
- [x] **E15** reference interpreter → `lib/interp.chiral` · deps: E3, E5 · **DONE 2026-08-03** (big-step tree-walk evaluator over the pure fragment in the fsm trampoline idiom: `Term`/`Value`/`Step` closed sums + `eval-step`/`eval`/`run`/`eval-args` mutual `=>` group; the `while True`+tail_jump becomes `run` tail-calling itself on `step-tail` — host RT PTC makes it constant-stack. Ports `runtime.py` `RT.run`/`apply1`. Differential vs `RT.run` — 10 fixtures (closure capture, case-arm-by-tag, multi-arg binding order = last-field-index-0, nested env indexing) + a 3000-deep let-chain returning WITHOUT RecursionError (the constant-stack claim), `tests/test_interp_chirality.py`, 480 green. Added `e-con` (the example's named Knob, needed to build a con VALUE for `e-case`); `step-stuck`→sentinel (unreachable on checked terms). Deferred (decision #2/§6): the extern/port/bridge face + linker (E51/E26); the small-step `->` Knob)

### Tier 5 — capstone · gated on the whole port above
- [x] **E52** cert split — chirality-side `recheck` → `lib/kernel-core.chiral` · deps: the ported kernel · **DONE 2026-08-03** (Phase B; Phase A Python seam stayed KILLED). `(import "kernel")` reuses E3/E4's `infer` — per finding #1 the elaborated term IS the derivation, so `recheck` = run the judgment + map `TcR`→`Verdict` (errors-as-values) + carrier guard; NO new judgment logic. Data: `JForm`/`SpecRule`/`Spec`, `ConvEv` (conv-rerun impl; conv-trace/conv-cached reserved), `Cert`, `Verdict` (v-accepted/v-rejected/v-wrong-carrier/v-fuel). Decisions: #1 conv-rerun-only (core contains eval); #2 = E3 dec#1 fuel-verdict posture — `v-fuel` RESERVED, conv not fuel-threaded in code (matches E3: core not `(total)`); wiring the fuel bound is the follow-on. Differential vs `kernel.py` infer — verdict-matches-oracle over the E4 corpus + the injected producer-bug CAUGHT as `v-rejected` (the seam's whole point) + stale carrier → `v-wrong-carrier`, `tests/test_certificate_chirality.py`, 485 green
- [x] **E45** freeze `Sig` (SigB→Frozen linear consume) · deps: the port · **DONE 2026-08-03** (`lib/reflect-floor.chiral` — TYPE-LEVEL artifact, the E40 pattern: no runtime code, enforcement is structural. `SigB` (linear write-capable builder) + `Frozen` (read-only, no write field) + `freeze : (-> (1 b SigB) Frozen)` the single linear consume; `install-former`/`install-vhook` thread the membrane (never fabricate); `reflect-formers` read-only; succession seam (`recheck`/`stage-successor`) forward-declared to E52. Seam stand-ins `Former`/`Rules`/`VHook` OPAQUE (`(declare … (type 0))`) so a writeback can't fabricate a `SigB`. Tests = what the checker accepts/rejects: freeze+reflect typecheck, REUSING the consumed builder is a QTT linearity rejection ("declared 1 … used 2"), and a writeback `Frozen→SigB` is unexpressible, `tests/test_reflect_floor.py`, 489 green. Python `Sig` untouched (interim discipline, decision #1 — enforcement lands with the kernel-core port))
- [ ] **fixpoint** — Stage1 == Stage2, byte-identical (Lane-prep compare harness localizes any diff) · deps: all of the above + Tier 0
- [ ] **E53 DDC** — run the ceremony across provenance-disjoint legs; require converged (harness built) · deps: fixpoint
- → **rung 1 COMPLETE**

## Load-bearing gotchas (carry into every build session)

- **Shared ADT:** E3/E4/E6 co-define `lib/kernel.chiral`'s `Term`/`Value` — the
  first element in fixes the shape everyone builds on; a later reshape ripples.
- **Differential is the oracle:** each ported element must agree with its Python
  original across the existing suite; that agreement *is* the correctness proof
  until the fixpoint. Don't drop it.
- **Trusted-core diffs shown explicitly** (`kernel`/`terms`/`data`/the carrier).
- **E52 #2 + E3 dec#1** — the SN/totality posture: recommended **fuel-bounded
  verdict** (structurally total core, no SN axiom in trusted code; SN as a P5
  claim in kernel-spec). Decide the two together when E3 lands.
- **Determinism:** Tier 0 before the fixpoint, always.
- **Settled (don't relitigate):** E52 #3 cert format → E12 bridge; #4 spec-size
  budget → deferred (no tooling); E80 sock-* re-sign → E29 follow-on.

## Do NOT pull in without an explicit scope decision (non-rung-1)

E42 (rung 2), E43/E44/E46 + E54–E63 (trust/custody novel core), E64–E68
(EXTENDs), E73–E78 (edge-walk mints), E35/E36 (desktop), E23/E37/E49
(disappearing/low). See `SELF-HOST-PLAN.md` "deliberately NOT in this window."
The security-completion wave (E73/E44/E59/E60) is *after* rung 1.

## Key references

- **The contracts:** `.planning/specs/E<NN>-*-SPEC.md` (§4 = the change plan).
- **Rationale:** `examples/E<NN>-*.md`; **live status:** `examples/INDEX.md`.
- **Build roadmap / lanes:** `handoffs/BUILD-LANES-HANDOFF.md`, `SELF-HOST-PLAN.md`.
- **Determinism ledger:** `.planning/DETERMINISM-DEBTS.md`.
- **Build-state truth:** `.planning/audit/CONFORMANCE-MAP.md`, `docs/status-ledger.md`,
  `docs/trust-boundary.md`.
- **Decisions:** `docs/decision-{split-checker,effect-facets,graded-kernel,backend}.md`.
- **Depth (read before naming a gap):** `docs/banks/*.md`.
- **Scoping-wave history (archived):** `handoffs/SCOPING-WAVE-HANDOFF.md`.

## Update protocol

- One element = one commit; check it off here **and** flip its `INDEX.md` row to
  `implemented` in the same commit. On any drift, `INDEX.md` wins.
- Keep this checklist dependency-correct: if you discover a new edge mid-build,
  record it on the affected row's `deps`/`unblocks` before moving on.
