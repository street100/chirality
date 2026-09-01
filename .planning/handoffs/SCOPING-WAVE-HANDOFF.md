# HANDOFF — the SCOPING WAVE (read this first)

> ## ⚑ CURRENT STATUS (2026-08-02, end of session) — READ THIS FIRST
>
> **THE SCOPING WAVE IS COMPLETE — every drafted element is `audited`.** The
> build wave is the sole remaining work. (E52 + E80, the last two un-audited,
> were driven through the full pipeline on 2026-08-02; see below.)
> - **Cluster C (§IX) is IMPLEMENTED, not just scoped:** E69 (closure conversion
>   incl. effectful closures), E70 (effectful lowering — all steps a–f), E71
>   (golden-semantics), E72 (manifest) are all built. **E34 (ELF writer) is
>   IMPLEMENTED** — `chirality emit file.chiral out` produces a runnable static ELF64.
>   **430 tests green.** Determinism debts **D-1 + D-2 scaffold-side PAID**
>   (`data.py _tyv_key` structural key + sorted emission).
> - **Scoping this session (6 elements to `audited`):** E38, E47, E48 (§VI designed
>   features), E45 (§VI — its edge-5 wall was stale; `decision-reflective-floor`
>   settled it), **E41** (region types + the edge-3 arith bound), **E22**
>   (region types — E41 unblocked it). See each SPEC in `.planning/specs/`.
> - **The last two, both AUDITED 2026-08-02:**
>   - **E52** (cert split, rung-1 trust core) — full pipeline this session. All 4
>     author calls dispositioned: #1 per-instance (resolved), #2 carried-input
>     totality settled + conversion-residual fuel posture PROVISIONAL (coupled to
>     E3 dec#1, decide at the port), #3 cert format → E12 bridge, #4 budget
>     enforcement → deferred as premature. **Priority call RESOLVED: no throwaway
>     Python — E52 = the chirality-side seam only, gated on the checker port (Lane 5).**
>   - **E80** (capability-to-`main`) — full pipeline this session (worked-example
>     → example audit → spec → spec audit). Buildable now (NOT gated on the
>     checker port; same cap-infra class as E29/E32), **security-completeness, not
>     a self-host blocker.** Delivers Console/NetCap + `main:(=> (1 g Grant) Unit)`
>     + profile `(grants …)` clause + checker rule + entry minting. sock-* NetCap
>     re-sign + caller ripple → E29 follow-on (E80 unblocks); ambient retirement
>     profile-scoped (default back-compat → 430 stay green). Queue position =
>     author cadence call.
> - **What's next after E52/E80:** the **BUILD WAVE** — port the §I checker stack
>   (E1–E18) from Python to chirality. All `audited`/implement-ready. That is rung 1
>   (see `SELF-HOST-PLAN.md`); the kernel core (E3/E4/E5) is the trusted sequential
>   spine, the checks are parallelizable. Sequence: determinism (mostly done) →
>   port E1–E18 → E52 trust split → the Stage1==Stage2 fixpoint (E72 running climb).
>
> Everything below is the original scoping-wave handoff; the checklist at the
> bottom is updated. `examples/INDEX.md` is authoritative on per-element status.

Entry point for a **new chat**. The scoping-wave priority (drive every drafted
element to `audited`) is now ~complete (see status above); what remains is the
2 author-gated elements + the build wave. You do not need this session's
conversation — everything load-bearing is in the repo.

The build-phase roadmap (the lanes + fixpoint you execute *after* scoping) is
preserved at `handoffs/BUILD-LANES-HANDOFF.md` + `.planning/SELF-HOST-PLAN.md`.

## Why this wave (the finding that motivates it)

As of 2026-08-01: the **entire §I checker stack is now `audited`.** The
2026-08-01 **E10–E19 pass** carried E10–E13 + E15–E18 to `audited`; the
**2026-08-01 E3–E8 pass** then carried the *deepest* checker core — **E3** (NbE
eval/quote/conv), **E4** (bidirectional infer/check + universes), **E5** (QTT
semiring), **E6** (data/coverage), **E7** (positivity), **E8** (linear-kind) — to
`audited`, one element per run, each `--spec` → `--audit spec` → `--mark audited`
(commits `6c2862a`…`d29f0f9`). With **E9** (refinement, audited earlier) and E1/E2,
**all of §I (E1–E18) is fully scoped.** The next unaudited targets are the
substrate/backend (§III+) and the trust/custody core (§VII) below.
A drafted example is an *unvalidated scope guess* — and every one carried this
cycle surprised us structurally (the E10–E19 pass alone found: E15's pure/`=>`
split doesn't typecheck, E16/E17 mis-attributed the tal checker to E15, E17
imported a non-existent `lib/tal.chiral`, E18's example mis-sourced its typed IR):

- **E29**'s example (2026-07-13) put NetCap capability-gating in scope; the code
  says it is **hard-blocked** on cap-reification-to-`main`. The spec audit had to
  defer a third of the element.
- **E29**'s caller ripple was a real "L" (10 files, linearity-correct error arms),
  not the "add an arm" the example implied.
- **E51**'s example §5 described a wrapper mechanism that isn't expressible.
- **E30** was accurate **only because** a 2026-07-25 audit re-scoped it first.

The pattern is consistent: **drafted examples systematically under-model
integration seams, cross-cutting dependencies, and caller ripple; the audit
gates are what catch it.** So: audit-gate everything to `audited` before
building. The checker stack + compiler pipeline (E1–E18) is the highest-value,
least-validated target; **E1–E2 + E10–E13 + E15–E18 are `audited` (2026-08-01)**,
leaving **E3–E8** (the deepest checker core; E9 audited 2026-08-01) as the next `--spec`→`--audit` batch,
then the substrate/backend (§III+) and the trust/custody core (§VII).

## The goal per element

`drafted → reviewed → specced → audited`. **`audited` = fully-scoped**: baseline
delta honest, every open question dispositioned (RESOLVED-with-citation /
DEFERRED-to-a-named-home / NEEDS-AUTHOR surfaced), commit-sized change plan, a
conformance gate. That is "fleshed out." Implementation is a later wave.

## The pipeline (one element per run — exact commands + skill)

Each stage is ONE `tools/pack/pack.py` call, wrapped by a skill (invoke the skill;
it front-loads the bundle and enforces the discipline). A run writes only its own
artifact — never `scaffold/`/`lib/`.

| From | Run (skill · command) | Writes | On PASS |
|------|-----------------------|--------|---------|
| `drafted` | **`pipeline-audit`** · `chirality-pack.py E# --audit example` | fixes the example in place | `chirality-pack.py E# --mark reviewed` |
| `reviewed` | **`example-to-spec`** · `chirality-pack.py E# --spec` | `.planning/specs/E#-*-SPEC.md` (pack sets `specced`) | — |
| `specced` | **`pipeline-audit`** · `chirality-pack.py E# --audit spec` | fixes the SPEC in place | `chirality-pack.py E# --mark audited` |

A drafted example that a later decision invalidated may need a fresh
**`worked-example`** run first (re-draft), then the gates. `chirality-pack.py E# --kb`
prints this element's scoped KB slice standalone.

## The 1-by-1 loop (how a session works this handoff)

1. Pick the top unchecked element in the checklist (checker stack first).
2. Run its next gate (the command its status implies, table above).
3. **FIX** mechanical/decidable findings in the artifact; **FLAG** author-tier
   ones (surface verbatim, never self-resolve — see Author calls).
4. On PASS: `--mark`, then **update this checklist** (new status + next command;
   `[x]` when `audited`), and commit.
5. Stop, or take the next — the user drives cadence (no unbidden agent spawns).

**Main-pass blocker protocol (user directive 2026-07-31):** when an audit hits a
*blocking* gap (a genuine author call or an unbuilt prerequisite), **do NOT stop
to resolve it** — record it in *Blockers discovered this pass* below (+ a finding
doc if it's substantial), leave the element `drafted`/unchecked, and **continue
the pass**. The user batches these after the whole scoping pass is through. Keep
auditing so the pass surfaces the full set of blockers, not just the first.

## Systematic drafting defects (non-blocking — fixed inline as found)

The unblocked checker-stack examples share recurring, mechanical defects (each
fixed in place at its example audit; logged here as a pattern for any batch
re-draft of the *unaudited* elements E10–E13, E15–E18…):
1. **value-level `if`** — `(if c a b)` does NOT typecheck (if's erased type arg
   isn't inferred: "expected (type 0), got Bool"). Use `case`-on-Bool. (E2/E3/E4/
   E5/E6/E7). `cond` is fine (E8).
2. **forward-reference ordering** — a `def` that calls a later-declared function
   fails ("unknown name"); recursion groups need all `declare`s *before* the
   first `def` (json.chiral idiom). Seen 3×: E6 `cov-go`, E7 `walk-args`, E8
   `linear-ty`/`fields-lin`. (A declared fn's `def` must also drop its inline
   type, else "global redefined".)
3. **`str=?`/`str=` for string equality** → prelude `str-eq` (Bool). Wildcard is
   `_`, not `else`/`_else`. Polymorphic calls need an explicit type arg
   (`(any-list Ty …)`, `(len Field …)`, `(reverse T …)`).
E9 had none of these — it was drafted correctly. The example gate + empirical
`Elab` load catches all of them.

## Blockers discovered this pass (user handles post-pass)

- **E22 (regions) — RESOLVED 2026-08-02: E41 scoped the enabler, E22 now `audited`.**
  The blocker below was the unscoped E9-arith bound; **E41 (region types) was
  scoped from scratch to `audited` and OWNS that edge-3 linear arith-expression
  bound** (`o+s ≤ cap`, `refine.py` — verified genuinely absent, `refine.py:29`).
  E22 then drove to `audited` as E41's production-region-types consumer. Original
  blocker finding preserved below for context:
- **E22 (regions) — BLOCKED at the example gate, 2026-08-01 [RESOLVED — see above].** Two findings:
  (1) *Phantom caught:* the example designed `lib/region.chiral` from
  Tofte–Talpin "because there is no OURS" — but the region **library is BUILT**
  (`lib/mem-region.chiral`, `(memory region)` clause; banks/memory Shard 5).
  Audit-corrected in place (scope note + ours_source + lands-in); the T–T
  ρ-brand sketch survives as the kernel-tier design direction. (2) *Unbuilt +
  unscoped prerequisite:* E22's REFACTOR tier (refined cursor retiring
  `mem-alloc`'s runtime `(<=i (+ used len) cap)` halt) is hard-gated on **E9
  arithmetic-expression bounds** (`cursor+size ≤ cap`, edge 3) — which the
  audited E9 SPEC deferred to E41/edge-3 and which is neither built nor
  scoped. Scoping E22 on top of an unscoped enabler is the under-modeled-seams
  failure this wave exists to prevent. **Left `drafted`; needs the E9-arith/E41
  facet scoped first (or an author call to scope E22 contingent).**

- **E18 example — RESOLVED 2026-08-01 (re-drafted, `reviewed`).** *First-pass
  call was too harsh:* I flagged it "phantom IR" from `tal-ir.chiral` alone, but
  `tal.py`'s CHECKER IR **is** type-annotated (`const/prim/call/con` carry a
  taltype; `TalTy`=I64/Str/Bytes/Data), so the example's typed instructions were
  faithful. The genuine defects were narrower and are fixed in place: the false
  "typed IR lives in `tal-ir`" claim (tal-ir is the type-**erased** sibling —
  `TInstr/TCode/TFn`; the checker's typed IR is E18's own, erasure connects them),
  **Str→I64** registers, value-`if`→`case` ×2; load-verified (7 defs, 18 data
  types). E18 is now `reviewed` and headed to `--spec`. One design open-question
  recorded in the example §6(d): keep two IRs (typed-for-check + erased-for-run,
  as tal.py effectively does) or annotate `tal-ir` directly.

- **Mutual-recursive data types** — **RESOLVED: BUILT 2026-08-01 as E79**
  *(id note: commits `11aac83`/`f0d3a34` say "E73" — a mint collision with §XI,
  renumbered E79; the docs are authoritative)*
  (commit `11aac83`; user-directed mid-pass build). Unit SCC scan + group
  install-then-judge in `surface.py`/`data.py`; 355 tests green (11 new). **E3,
  E4, E11 are unblocked** — re-run `--audit example` on each; the examples are
  correct as-drafted, and the leftover mechanical defects to apply at re-audit
  are itemized per element in `.planning/FINDING-mutual-data-2026-07-31.md`.
  Forward (DAG) data references now work too, not just cycles.

---

## THE CHECKLIST (the worklist — keep it updated)

`examples/INDEX.md` is the **authoritative** status (the pack maintains it on
`--mark`). This checklist mirrors it as the human worklist + next-command; on
drift, INDEX wins — reconcile here in the same edit that advances an element.

Legend: `[ ]` not yet audited · `[x]` audited (fully scoped). Status = current
pipeline stage; the arrow is the next gate command (all `tools/pack/pack.py`).

### §I — Checker stack · the TCB, highest value + highest scope-risk · **DO FIRST**
*The trusted judgment ported to chirality. Context: catalog §I; `docs/decision-split-checker.md`, `docs/decision-graded-kernel.md`; banks `docs/banks/*`.*

- [x] **E1** S-expression reader · `audited` — fully scoped, implement-ready
- [x] **E2** Surface elaborator (name→deBruijn, desugar, profile/target verify) · `audited` — fully scoped (elab/resolve core; verify/data/rows/loader/CLI deferred within E2, each homed)
- [x] **E3** NbE: eval / quote / conv (+ eta) · `audited` — SPEC ports the closed-core NbE (eval/vapp/quote/conv +eta over closed `Term` + mutual `Value`/`Clos`/`Neut`) → `lib/kernel.chiral`, differential vs `kernel.py`. Seat baseline-corrected to E39's `Seats` record (opaque `Seat`+`seat=`; example's `Arr` was pre-E39). `nth` precondition-total (E13 pattern); data-values→E6, subtype/cumulativity→E4, globals/prims+hooks deferred to full-ADT assembly. 1 audit FIX (normalize=structural/beta-normal, eta lives in conv). **NEEDS-AUTHOR (non-blocking):** TCB totality posture — mark core `partial` vs trusted-total-by-SN-axiom; no current pillar (E11/E47/E50) proves NbE strong-normalization. Recommended provisional (b).
- [x] **E4** Bidirectional infer/check + universes/cumulativity · `audited` — SPEC ports the pure bidirectional + cumulativity skeleton (`infer`/`check`/`subsume`/`subtype`, errors-as-values `TcR`/`CkR`, QTT usage vectors) into E3's `lib/kernel.chiral`, extending its ADT (t-ann, Qty binders, Ctx). Membrane seams + `allow_eff` row-threading → E12; subtype Pi row-subsumption → E39; `Qty` type+ops → E5 (E3-I64/E4-Qty converge there); `conv` totality inherits E3 dec#1. 1 audit FIX (gate honesty: type-level-Pi-smuggle *rejection* is E12-gated, E4 owns only on-binder call placement; differential needs E3+E5 built).
- [x] **E5** QTT quantity semiring + usage-vector linearity · `audited` — SPEC ports the 8 pure ops (`Qty` sum + `qadd`/`qmul`/`qjoin`/`qfits` + `uzero`/`uadd`/`uscale`/`ujoin`) → NEW `lib/qtt.chiral` (imported by E3/E4's kernel.chiral; resolves E4's Qty-home). Tables verified byte-exact vs `kernel.py:65–107`. Standalone gate (only prelude needed — first checker-core element whose differential needs nothing else built). Linear-kind enforcement→E8/E12; E38 product = swappable seat; UVec-in-type→E48; parametricity-lowering→E38/E52. ZERO-fix audit.
- [x] **E6** Data: ctors, coverage, param-unification · `audited` — SPEC ports the coverage verdict (`check-coverage`/`cov-go`→CovR) + the bounded sound-by-recheck ctor-param solver (`bare-param`/`solve-go`/`infer-ctor-params`→SolveR) + the Con/Case check-handlers → NEW `lib/data.chiral` (Ty = shared kernel ADT). Positivity→E7, linear-kind→E8, termination→E11, eval-arms→E3, telescopes→E48 (flat model is the reference's real behavior). Gate split: coverage=behavioral diff (inlined in `_check_case`), solver=direct fn diff (`_infer_ctor_params` standalone). 1 audit FIX (that diff distinction). **FLAG (non-blocking):** should the self-hosted core drop the `default`-branch escape hatch (weaker coverage) for totality? Port keeps it (conformance requires).
- [x] **E7** Strict positivity / variance analysis · `audited` — SPEC ports the one walk / two targets (`hit?`/`mentions?`/`walk`/`walk-args`→PosR) + `compute-sp` cache → `lib/data.chiral` (beside E6). Reject/allow sets verified vs `data.py:296–428`. **Baseline correction:** example's "mutual families refuse, same as OURS today" is stale — post-E79 the live `_positivity` handles mutual groups (`under` = frozenset, non-uniform sibling refused); E7 ports single-`under`, defers the group-frozenset wiring to the group-install assembly. Boolean cache kept (lattice deferred-until-needed). 1 audit FIX (walk↔walk-args is a mutual pair → E50 termination, not E11; example's "no E50" was only about mentions?/walk). Mostly-standalone gate (syntactic, needs Term ADT not eval/conv).
- [x] **E8** Linear-kind decision for data · `audited` — SPEC ports the bounded abstract walk (`linear-ty`/`fields-lin`→three-valued `LinR`) → `lib/data.chiral` (beside E6/E7), differential vs `data.py:_linear_data` (lin-yes→True, lin-no/lin-defer→False). Three-valued LinR RESOLVED (deferral-as-value; **forward contract to E12**: on-binder/on-apply must case on lin-defer). Seen-key = structural `tyv=` (replaces the `repr` crutch; broad canonical-type-form→determinism debts). Kernel is_linear fast-path+hook-plumbing→assembly; instantiation re-judgment→E12; capture→E39/E69 (shapes-not-captures boundary). 1 audit FIX (linear-ty↔fields-lin is a mutual pair → E50, fuel the measure — consistent w/ E7). Gate: RecvR→yes, (List Sock) rejected at instantiation.
- [x] **E9** Refinement decision procedure (interval + symbolic bounds) · `audited` — SPEC ports the *built decidable fragment* (`entails`/`is-empty`/`Constraint`) → `lib/refine.chiral` (shared with E10's narrow layer; provides `entails` to E10). Full-solver/inter-var-arith is the REFACTOR facet, deferred → edge 3 / E41. Level-keyed symbolic (OURS); full `is_empty` (both conditions). 0 SPEC FIXes.  ·  ZERO-fix: example elaborates+typechecks clean as-drafted (first clean one)
- [x] **E10** Path-sensitivity / occurrence typing · `audited` — SPEC clean; E9-engine coupling scoped via a stand-in `Env`/`Atom` (E9 swaps it later), `narrow` atom-selection live-differentially gated vs `refine.py:_narrow` (3 audit FIXes: E9 link slug, bare-I64 unwinder nuance, live-vs-transcribed gate)
- [x] **E11** Totality: structural + numeric-measure termination · `audited` — SPEC scopes the **self-host port of the classifier** (`lib/totality.chiral`, live-differential vs `data.py:_totality_reason`); enforce-by-default flip explicitly deferred (map EXTEND facet, gated E47+E50), mutual/lex deferred to E50; I64 wraparound obligation faithful to `_num_dec_ok`. 1 audit FIX (localize I64-MAX/MIN).
- [x] **E12** Effect membrane (pure `->` vs process `=>`) · `audited` — SPEC ports the 3 membrane rules → `lib/effects.chiral` over the row algebra; baseline corrected to the **live row-based** `effects.py` (E39 steps 1–6 built 2026-07-28; the example's boolean snippet + the E12 map row are pre-E39 snapshots). Row carrier → E39, is-linear → E8, wiring → E3/E4. 0 SPEC FIXes. **Doc-rot noted:** `banks/effect-and-alarm` Shard 2/§5a still describe the pre-E39 boolean effects.py — owed a doc-audit.
- [x] **E14** Pretty-printer (display, non-trusted) · `audited` — worked-example pre-run (new, was stage 0) → gates. `show-term` = pure total `Term→Str` over the closed sum (coverage kills OURS's `<k>` catch-all), `#i` out-of-scope fallback keeps it total, `show-value`=`quote`(E3)∘render. Theme: the lowest-stakes checker member still gets totality+coverage+`->` for free (P2). Snippet load-verified (8 defs); `show-value` runnable differential rides E3's `quote`; `Case` opaque + flat layout per OURS. 0 SPEC FIXes.
- [x] **E13** Term de-Bruijn machinery · `audited` — SPEC ports `uses_below`/`shift_close` → `lib/terms.chiral` (core-subset `Term`; extension-node arms deferred to when the full shared ADT assembles, coverage-forced). Precondition stays caller-discharged (a refinement encoding is out of E9's fragment). Live differential vs `terms.py` with boundary-case fixtures. 0 SPEC FIXes (cleanest — pure OURS transcription).

### §II — Compiler pipeline (codegen is already chirality; these are the rest)
*Context: catalog §II; `docs/decision-backend.md`.*

- [x] **E15** Reference interpreter (golden semantics, tree-walk + TCO) · `audited` — example audited (7 FIX classes, empirically load-verified 48 defs OK; the "pure `->` step vs `=>` driver" split doesn't typecheck → whole evaluator `=>`, small-step pure stepper kept as a Knob) → SPEC ports the big-step evaluator → `lib/interp.chiral` (extern/port face + linker deferred to bridge/E51; erasure→E5; E15≠E42). **Author call surfaced (non-blocking):** lead big-step vs small-step.
- [x] **E16** Lowering: pure→tal, alloc, outlining, preserve-check · `audited` — example audited (5 FIX classes: value-`if`→case ×2, `let` pair-destructure→case-on-pair, def type-repetition ×3, **cross-ref E15→E18** — the tal checker is `tal.py`=E18, confirmed by the module bank) → SPEC ports `lower.py`→`lib/lower.chiral` (partition differentiable now; tal emission + `check-fn` coupled to **E18**; packing→E17; 0/1 stay upper). 0 SPEC FIXes.
- [x] **E17** Optimizer: const-fold, DCE, specialize/pregen · `audited` — example audited (import `tal`→`tal-ir`, real names TFn/TInstr/TCode, flat `check-fn` not `tal.check-fn`, E18-coupled checker forward-declared; snippet loads 11 defs OK) → SPEC ports `optimize.py`→`lib/optimize.chiral` (fold/dead/specialize transforms differentiable now; `check-fn` re-check rides **E18**; end-recheck suffices; cost→E38). 0 SPEC FIXes. (E17 is the home for E16's deferred register-packing pass.)
- [x] **E18** TAL checker + reference tal interpreter · `audited` — example **re-drafted + audited 2026-08-01, load-verified (7 defs, 18 data types OK)** (first-pass "phantom-IR" call corrected: `tal.py`'s checker IR IS type-annotated, so the example's typed instructions were faithful; real defects were the false "lives in tal-ir" claim [tal-ir is the *erased* sibling], Str→I64 registers, value-`if` ×2) → SPEC ports `tal.py` `check_fn`+`TalMachine` → `lib/tal-check.chiral` + `lib/tal-eval.chiral` (differential vs tal.py; `ck-ok`⇒never-`r-err` soundness cross-check; fuel-total interp; typed↔erased-IR resolved as two-IRs-by-erasure; byte-cell typed-init not owed; drop-attestation→floor-agreement/E55). **PROVIDES `check-fn` to E16/E17.** 0 SPEC FIXes.

### §III — Substrate floor (REPLACE-CRUTCH)
*Context: catalog §III; banks `docs/banks/memory.md`.*

- [x] **E20** Loader: RW mmap → W^X mprotect → exec · `audited` — example audited (1 FIX: load-batch's page-count witness was erased-0 but consumed at runtime by map-rw → `w`, the pool-create pattern) → SPEC lifts the already-self-hosted W^X *mechanism* into the *type*: NEW `lib/loader.chiral` (`MapRW`/`MapRX`/`MapTail` + `seal-exec` consuming the writable handle) + floor blit `nb-blit` (the write path is STILL ctypes.memmove — the map row's "only CFUNCTYPE stays Python" rounds; SPEC names it) + `compile()` rewire. Prefix seal RESOLVED from the reference (`code_end=heapptr`, split-at-witness, both indices erased — no type arithmetic, E9 fragment limit); errno→typed-alarm→E26; arena porttype→E21. 1 SPEC FIX (load-batch bundle supersedes example's whole-seal shape). Doc-rot noted: `banks/runtime` Shard F still says "mprotect/close missing" (stale post-E28) — owed a doc-audit.
- [x] **E21** `mmap` arena + bump-allocator base/end · `audited` — example audited (6 FIXes: build-state stale — the mapping milestone is COMPLETE + native.py maps via `nb-sys-mmap` since 2026-07-29, so the delta is the TYPED layer only; value-`if`→case; bitwise `(and (+ n 7) (not 7))` Pythonism→`align8` mod helper; `(porttype MapPort)` declared; lands-in corrected; arena-porttype open question added per E20's deferral) → SPEC: NEW `lib/arena.chiral` (pure total `bump`, `a-err` exhaustion; `arena-map` behind MapPort) + setup rewire + 3-way bump differential (typed vs `alloc_bytes` vs emitted-inline). **E20's deferred call DECIDED:** `Arena` = transparent data carrying a `(1 tok ArenaTok)` linear witness — linear-kind by E8's walk (structural ω-rejection) while cur/end stay readable. Exhaustion both-by-level (typed `a-err`, floor keeps `ud2`); refined cursor→E48 (dependent field); region-evidence→E22; grant delivery→E80. 0 SPEC FIXes. Doc-rot: `memory-model` + `banks/memory` §5 both still say "mprotect/close missing" (stale post-E28; bank self-contradicts its Shard 1).
- [x] **E22** Allocator / region types / GC-outside-TCB · `audited` (2026-08-02) — **UNBLOCKED by E41** (which now owns the edge-3 arith bound). Scoped as the production region-TYPES consumer of E41: Tier 1 REFACTOR reshapes the BUILT `lib/mem-region.chiral` (refined cursor, halt → type obligation), Tier 2 BUILD-L kernel ρ-brand (use-after-free/double-free/cross-region = type errors; O(1) free; no GC in TCB). E41/E22 are the coupled pair the CONFORMANCE-MAP lists jointly.
- [x] **E24** I64 two's-complement arithmetic · `audited` — example audited (4 FIXes: `/=`→`<>` throughout — the refine ops are exactly `>= > <= < <>`, no `/=`; its own "does a disequality atom exist?" open question RESOLVED — it's `<>`; the "unproven division is impossible" overclaim tempered — raw `/` stays plainly typed, PortError at zero; try-div comment precision) → SPEC: the refined safe path (`div`/`mod`/`divmod` at `(refine I64 (<> 0))` + `try-div` Maybe climb) → prelude pure-defs. Floors-agreement is BUILT non-goal (fold imports impl_pure; D3 guarded idiv). Law-home migration→E71/E72; guarded-variable discharge→E10 wiring (bonus-test only). 0 SPEC FIXes. **FLAG (non-blocking):** should the prelude `/` face itself become refined (P4 leans yes; caller ripple + surface semantics = author call)?
- [x] **E25** Byte cells `[len][payload]` · `audited` — example audited (build-state rounding FIXED: the crutch-replacement is DONE per the map — native cells + `bytes-tal.chiral` BUILT, bytearray = the pinned differential oracle "not unmet crutch"; the example's residual = the typed builder/refined-face layer, split: linear-builder half expressible today, expression-bound faces `(< (blen b))` edge-3-gated like E22; bcat's missing erased-index arg fixed) → SPEC: NEW `lib/bytes.chiral` linear builder (`BBuf`/`bnew`/`bput`/`bfreeze` — write-after-freeze/double-use/leak/range become CHECKER rejections; bare-var `(< n)` + `(< 256)` discharge today), declared optional-forward (map owes nothing). Dependent faces → edge 3/E41 beside E22 (one gate, two customers). tal-level bput stays untyped init-write (floor re-checks types, not linearity). 1 SPEC FIX (symbol-anchor the alloc_bytes cite — native.py under live concurrent edit).
- [x] **E26** Alarms / control flow · `audited` — rework audited hard (4 FIXes: E39-steps-1–6-BUILT unblock note — E26 is "the next construction" per error-and-alarm; Exit-gating = the E80 reification class, halt/exit ambient today; recoverable-vs-fatal attribution corrected — KontMsg mechanism discharged in E39's SPEC, Shard 5 *lands with E26*; §5 linearity bug — recv consumed `s` then read-body reused it → threaded-sock arms, the E29 lesson) → SPEC: the E39-rider construction — KontMsg + structured Alarm payload + handler CPS-elaboration to ONE linear closure (zero kernel forms) + row subtraction + synthesized cancel via a declared porttype→discharge table + host-boundary repositioning of MetisExit/Halt/PortError. Decisions: no `Never` (built polymorphic-A bottom idiom; 0-ctor data hits "empty case"); Exit per-process (spawn/node-main direction), delivery→E80; Clock/Timer/Env discharge→E80; Console step-7 author call stays out. 0 SPEC FIXes.

### §V — External formats & ABIs
- [x] **E34** ELF writer (static ELF64) · **IMPLEMENTED** (2026-08-02) — `lib/elf.chiral`
  pure ET_EXEC layout + `chirality emit file.chiral out [entry]` CLI → runnable static
  ELF64 (readelf-accepted + exec-verified; caught an invalid-EI_DATA constant bug).
  Entry stub is a 16-byte raw-x86 shrinking crutch → hand-tal follow-on; ELF is an
  added floor, JIT not retired. `tests/test_elf.py` (6).

### §VI — Designed features not yet built (BUILD-PROPER)
*Context: catalog §VI; `docs/open-edges.md`.*

- [x] **E38** Graded cost / coeffect semiring (carrier-adjacency slice) · `audited` (2026-08-02) — REFACTOR-L reshape of the E5 semiring to the product domain, populating the reserved `Seats.grades`; ω-absorption/per-arrow DEFERRED to edges 2/3, reuse `refine.entails` RESOLVED, `graded` wrapper PROVISIONAL
- [x] **E45** Reflective floor (SigB→Frozen; freeze at stage-complete) · `audited` (2026-08-02) — **the edge-5 wall was STALE**: `decision-reflective-floor` settled it. Type-level chirality artifact (`lib/reflect-floor.chiral`, E40 pattern); Python `Sig` stays interim-discipline (decided), enforcement lands at the chirality kernel-core port
- [x] **E47** Sized types (termination promotion) · `audited` (2026-08-02) — BUILD-L size channel in `data.py check_termination`; **fast-follow, NOT rung-1 critical** (E50 owns the mutual heart); inclusion gated on a post-E48/E50 checker-source audit
- [x] **E48** Dependent records / telescopes · `audited` (2026-08-02) — BUILD-M field dependence in `data.py _ctor_field_types`; **language-completeness, NOT a self-host blocker** (extrinsic checker, matches SELF-HOST-PLAN self-removal). 4 stale `data.py` cites fixed
- [x] **E41** Region types (retire runtime bounds) + the **edge-3 arith bound** · `audited` (2026-08-02, NEW element scoped from scratch) — owns `refine.py`'s `o+s ≤ cap` linear arith-expression bound (the facet the E9 SPEC deferred here) + a typed region layer; **unblocked E22**
- [x] **E80** Capability reification to `main` (profile-grants-to-entry) · `audited` (2026-08-02) — full pipeline this session (worked-example → example audit → spec → spec audit). SPEC `.planning/specs/E80-cap-to-main-SPEC.md`: buildable-now (NOT checker-port-gated; same cap-infra class as E29/E32), security-completeness not a self-host blocker. Delivers Console/NetCap porttypes + Console successors + `main:(=> (1 g Grant) Unit)` + profile `(grants …)` clause + checker rule + entry minting. Decidable §6 calls all resolved (Grant-record · argv-as-data via E32 · new grants-clause); sock-* NetCap re-sign + caller ripple → E29 follow-on; ambient retirement profile-scoped. Queue position = author cadence.

### §VII — Trust & custody (the novel core)
- [x] **E52** Kernel-core certificate split (kernel-spec + core + cert format) · `audited` (2026-08-02) — full pipeline this session. Two-phase SPEC (`.planning/specs/E52-certificate-split-SPEC.md`): **Phase A** = buildable-now Python reference producer/checker pair (reify the cert seam, errors-as-values `recheck`, injected-elaborator-bug negative test); **Phase B** = chirality `lib/kernel-core.chiral` recheck, **gated on the checker port (Lane 5)**. All 4 author calls dispositioned (#1 per-instance · #2 carried-measure settled + fuel provisional-w/-E3-dec#1 · #3 → E12 bridge · #4 deferred-premature). **Open author priority call: build Phase A now vs defer all to Lane 5 (SPEC §4).** (the example's §6 opens; tier-mix #1 already RESOLVED per-instance): **#2** `recheck` totality = normalization claim vs fuel-bounded? · **#3** the **certificate serialization format** (canonical form, needed before self-hosting) · **#4** spec-size-budget enforcement. These are the trusted-core's defining decisions — genuinely author-tier.

### §IX — The lowering reach (BUILD-PROPER)
*Context: catalog §IX; `docs/decision-effect-facets.md`, `DELEGATION-MAP-2026-07-21.md`.*

- [x] **E69** Closure conversion + quantities-to-tal · **IMPLEMENTED** — `closconv.py` defunctionalizes all escaping-closure site kinds (higher-order params, partial-app captures, escaping lambdas, nested, q=0 erasure) AND **effectful closures** (the E69⊗E70 cluster seam: an effectful callback through a higher-order fn defunctionalizes to an effectful `$apply` and lowers). Native==reference==python, D-2 deterministic.
- [x] **E70** Effectful lowering (the row's tal shadow + preserve-check) · **IMPLEMENTED** (all steps a–f) — effectful defs lower AND run native through real syscalls (`(put s)` → `write(2)`), CPython out of the crossing path. `crossing_sigs` table + `=>` gate + `RowEscape` check + `sysface` projection (step f). Found+fixed a real DCE/CSE soundness bug (crossings were being dropped/merged). `tests/test_effectful_lowering.py` (13).
- [x] **E71** Golden-semantics restructure · **IMPLEMENTED** — `lib/tal-spec.chiral` (Obs/SpecEntry/conform + exemplars) + `docs/tal-spec.md` + `floor-agreement.md` spec-as-golden (provisional, ratification non-gating).
- [x] **E72** Re-bootstrap artifact · **buildable MANIFEST IMPLEMENTED** (`lib/climb.chiral` + `docs/definitions/bootstrap.md` + ship-list). The **RUNNING climb** (stages 2/3) stays gated on the chirality checker port (the build wave) + E52 — honestly named in breakers, not this handoff.

### Already scoped — `audited`, ready for the BUILD wave (not this handoff)
- [x] **E31** poll — *steps 2–3 built; steps 4–6 (typed-readiness surface) E51/E70-gated*
- [x] **E33** process spawn (socketpair + fork/execve/clone)
- [x] **E39** effect algebra / typed rows — *steps 1–6 built; step 7 (Console reification) unblocked by E51 v1*
- [x] **E51** sys-face linkage — *v1 seam built; lane-A crossings + full impl_ports retirement remain*

### Built (past the pipeline) — for reference
E27 (maps) · E28 (mmap/mprotect/close) · E29 (sockets v1) · E30 (fd-passing) ·
E32 (clock/exit/env) · E40 (secret, type-level) · E50 (mutual termination) ·
E53 (DDC harness). **All substrate/backend — the checker stack above is 0% built.**

---

## Update protocol (keep this current)

- **`examples/INDEX.md` is the source of truth** (pack-maintained). When you
  advance an element, the `--mark` command updates INDEX; edit this checklist in
  the same commit (status word + next command; `[x]` at `audited`). On any drift,
  INDEX wins.
- A `status: blocked` SPEC (a blocking NEEDS-AUTHOR) is **not** `audited` — leave
  its box unchecked and record the open question under Author calls.
- Nice-to-have (not built): a `ledger-lint` check J that flags HANDOFF↔INDEX
  drift, the same forcing function as checks C/I. Until then, reconcile by hand.

## Standing disciplines (non-negotiable — apply to doc work too)

1. **Audit producer output before propagating it.** Re-run gen-scripts, read the
   snippet, verify every cited `file:line` exists. This cycle caught real defects
   that way (a linear double-use, a wrong binder quantity, a mis-typed cap).
2. **Verification scales with generation, or it's abuse.** Auto-check against
   machine-checkable ground truth (does it parse, do cited lines exist, does the
   gate map to a real test, do refs regen deterministically).
3. **Decide decidable things; check the decision; don't defer by default.**
   "Author's call" is for genuine values/taste/scope only. Everything
   architectural/engineering is yours — settle it, verify against code/decisions.
4. **No unbidden agent spawns / batch spend.** The user drives wave cadence.
   "Keep going" is direction, not a launch order.
5. **Trusted-core edits are reviewed as such** — `kernel.py`/`terms.py`/the
   carrier are the most sensitive class; show the diff explicitly.

## Author calls (blocking — surface, never silently resolve)

- **Mutual-recursive data types** — **RESOLVED 2026-08-01: built as E79**
  (user-directed mid-pass; commit `11aac83`, catalog §I row added). See
  *Blockers discovered this pass* above for the unblock instructions.
- **E29 NetCap ↔ cap-reification-to-`main`** — **RESOLVED 2026-08-01: build,
  not defer — slotted as E80** (catalog §VI, profile-grants-to-entry). The
  direction was already recorded in `decision-effect-facets` ("handed to `main`
  by the profile the way `spawn` already hands `node-main` its peer port");
  the author call ratified building it as its own element. E29's deferred
  NetCap third + the `Clock`/`Timer`/`Env` shared edge land with it (forward
  contract: E29 SPEC §6). Enters the pipeline at `worked-example` (no example
  yet); build order is the user's post-pass call.
- **D7** — RESOLVED-IN-DIRECTION 2026-07-26 (two levels; DDC + re-derivability).
- **E71** spec-as-golden — PROVISIONAL 2026-07-26 (revisitable).
- **E52** — **ALL 4 author calls DISPOSITIONED 2026-08-02 (SPEC audited):**
  **#1** tier mix = per-instance (resolved 2026-07-26). **#2** `recheck`
  totality: carried-input totality is settled (carrier seat · declared-measure ·
  classify-not-enforce); the conversion residual takes the fuel-bounded-verdict
  posture — **PROVISIONAL, coupled to [[E03-nbe-normalize]] dec#1** (decide
  together at the port). **#3** certificate serialization format → **DEFERRED to
  the E12 bridge** (decide with the real need in front of us). **#4**
  spec-size-budget enforcement → **DEFERRED as premature** (documented intent,
  no tooling; revisit only on bloat). **One open author *priority* call remains:**
  **RESOLVED 2026-08-02 — do NOT build Phase A.** Phase A adds Python to the
  check path that the fixpoint only deletes later (anti-rung-1) and shrinks no
  TCB. Defer all of E52 to Lane 5; build the seam once, in chirality, after the
  checker port. Phase A stays in the SPEC as design reference only.
- **E80** — **AUDITED 2026-08-02** (full pipeline). No blocking author calls: the
  build was ratified 2026-08-01, and the three §6 design questions were decided in
  the SPEC (Grant-record · argv-as-entry-stack-data via E32 · new `(grants …)`
  clause). Only non-blocking input owed: *when* to build it (buildable now, but a
  security-completeness element, not a self-host blocker — author cadence).
- Triage pile: `.planning/EDGE-CANDIDATES-2026-07-22.md` + `SELF-HOST-PLAN.md`.

## When scoping is done → the build

Once the checklist is all `[x]`, the entry point is the build roadmap:
`handoffs/BUILD-LANES-HANDOFF.md` (lanes + the convergence fixpoint) and
`.planning/SELF-HOST-PLAN.md` (rung model). The one strategic fact carried over:
the Stage1==Stage2 fixpoint is convergence-bound and last; pay the determinism
debts (`DETERMINISM-DEBTS.md`) before it.

## Key references

- **Pipeline**: `CLAUDE.md` (the worked-example / example-to-spec / pipeline-audit
  discipline), `examples/INDEX.md` (live status).
- **Build-state truth**: `.planning/audit/CONFORMANCE-MAP.md`, `docs/status-ledger.md`,
  `docs/trust-boundary.md`.
- **Decisions**: `docs/decision-effect-facets.md`, `decision-graded-kernel.md`,
  `decision-split-checker.md`, `decision-backend.md`.
- **Depth (read before naming a gap)**: `docs/banks/*.md` — the refractions.
- **Frontier digest** (cheap "where things stand"): `docs/FRONTIER.md`.
