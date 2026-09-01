> **ARCHIVED 2026-09-01. Successor: `docs/elements/catalog.md` and
> `docs/elements/ledger.md`, which carry the E69, E70, E71 and E72 rows, both
> TRACKED.** E69 and E70 landed; E71 and E72 are `design` on the
> ownership-and-trust track, deferred out of scope for *work* on 2026-08-31 and
> **not dropped** — `ledger.md:136` and `:248`, `catalog.md:262` and `:268`.
>
> This file is a run log for one overnight session and every implementation
> detail in it names `lower.py`, `native.py`, `surface.py` or a `scaffold/` path.
> All of those are evicted. It is kept as provenance for what was decided and
> when, not as a work order.
>
> Its AUTONOMY CONTRACT banner is retired in place below. It is not a standing
> authorization and was not one after 2026-08-02.

# E69→C-cluster implementation checklist (autonomous run 2026-08-02)

## ⚑ AUTONOMY CONTRACT — **RETIRED 2026-09-01. NOT A STANDING AUTHORIZATION.**

> The authorization below was given for **one overnight run on 2026-08-02** and
> expired with it. It says it persists across context compression, which was true
> inside that session and is not true across sessions. **A session reading this
> file today is NOT authorized by it.** It is struck rather than deleted because
> the pacing instruction it carries is the record of how that run was asked to be
> paced, and because a deleted banner cannot be recognised if it is quoted
> somewhere else.
>
> Nothing replaces it. Standing operating discipline lives in `CLAUDE.md` and in
> `HANDOFF.md`; neither carries an autonomy grant, and minting one is an author
> call.

### The retired banner, kept verbatim

The user gave an EXPLICIT standing go for autonomous work and then went to sleep.
**This authorization PERSISTS across context compression.** If you are re-reading
this after a compression/summary: you are AUTHORIZED and EXPECTED to continue the
work below without waiting for a new go — do NOT stall asking "should I proceed?".
Re-orient heavily (read this file, the E69 DESIGN IMPLEMENTATION STATE block, the
[[chirality-selfhost-corpus]] memory, `git log`), then resume the next unchecked item.

- **Order:** finish E69 blockers → E70 (in stages I decide as issues surface) →
  rest of C (E71/E72, proper `--audit spec`-then-implement stages) → then STOP.
- **Pacing (the user's explicit instruction):** do a SMALL chunk, commit when
  green, then WAIT ~30 min via a background timer (`Bash sleep 1800`,
  run_in_background) so the 5x session limit is not exhausted before refresh.
  Keep pacing so I never stall out on the session limit. Two waits ~covers the
  first hour; then keep self-pacing. Do not rush; small steps + waits.
- **Discipline:** closconv is wired into ALL lowering — probe each slice in
  isolation, run the full suite, commit only when green. One committed unit at a
  time (commit before the next).
- Update the checkboxes + Log below as you go, so progress survives compression.

## E69 blockers (do first)
- [x] §6 nested closures — DONE (402 green, commit pending). Fully-applied nested
      lambdas (`((f 1) 2)`) collapse to one d-ary closure via `_peel_lams`
      skipping `Ann` + a saturation guard + family POISONING (an unsaturated use
      excludes the family wholesale, so a bare $clo apply never survives).
      Escaping intermediates (§6b, Clo_mid/Clo_in split) stay deferred → SKIPPED.
- [x] q=0 erasure — DONE (404 green). `_erase_q0` runs first (sig-level): drops
      vestigial q=0 params from non-dependent lam-chain defs whose every use is a
      saturated direct call (else skip → falls through to closure conv), + drops
      the arg at every such call site; de Bruijn body remap + quantity-preserving
      Pi rebuild + re-check. Tests: first-position + middle-position erasure.

**BOTH E69 BLOCKERS DONE. E69's implementable fragment is complete.** Deferred
within E69 (documented, off critical path): §6b escaping intermediates, self-
referential closure cells, linear/effectful closures (→ E70).

## E70 — effectful lowering (in stages)
Spec already `audited` (802f225) → implement directly. SCOPED against live code
(findings recorded in E70 DESIGN §7b). Two corrections + the real crux:
- Check must be the EFFECTFUL PROJECTION (not full def_rows) — E69 conversion
  makes pure `->` fns reach pure prims their stale def_rows omit (apply-it→'+').
- Check runs on lower.py tal IR (UPPER vocab) — §7 PRIM2LIB-inversion is a
  native-backend concern, not the check.
- CRUX: opening the gate ≠ sufficient. `(put s)` fails "extern put does not
  lower" (ports excluded from prim_sigs). Emission must route put→wrap-put via
  the E51 rep SEAM (Str↔BYTES=nb-id, Unit synthesized from discarded count) +
  wire E51 bindings/_WRAP_SIGS into lower_all + native backend compiles wrappers.
- [x] (a) wire E51 bindings into lower_all env — DONE (410 green, additive).
      `TalEnv.crossing_sigs` field + `lower.crossing_sigs(sig)`/`_bound_crossings`
      helpers (read `sys-bindings` via an RT probe; runtime doesn't import lower,
      no cycle). Resolves put/print/trace → `[Str]->Unit`. Nothing consumes it
      yet → pure baseline untouched. (_WRAP_SIGS stay native.py-side per the
      refined seam: `prim <crossing>` in tal IR, wrapper translation in native.)
- [x] (b) lower.py App emitter: bound port lowers as `prim <name>` via
      crossing_sigs (no rep cast — Str==Bytes at the floor). DONE.
- [x] (c) native backend compiles the wrappers alongside lowered defs — DONE.
      Backend loads sys-linkage.chiral; admits wrap-* to lib_tfns; membrane
      relaxed (nb-sys-* MUST be sys-faced, wrap-* MAY be); `_conv_code` routes
      `prim <crossing>` → `ti-call wrap-<crossing>` + synthesizes Unit (discards
      the byte-count). `sys_bindings` threaded through tal_to_tfn/_conv_code.
- [x] (d) open the => gate — DONE. Gate opens iff every reached PORT crossing
      (def_rows ∩ ports) is E51-bound; open row (rowvar) or any unbound crossing
      keeps the def upper.
- [x] (e) effectful-projection row check + row-escape negative test — DONE.
      `_reachable_crossings` walks the lowered footprint (body + outlined arms);
      `RowEscape` (a HARD module rejection, not a skip) if reached ⊄ declared.
      check_fn's prim handler consults crossing_sigs. 8 tests in
      tests/test_effectful_lowering.py.
      **SOUNDNESS FIX found+fixed:** DCE(`dead`)/CSE(`cse`) treated `prim` as
      pure — dropped/merged effectful `prim put` (the `(do (put s)(put s))`→one
      write bug). Both now take a `crossings` set (exempt from drop/share),
      threaded from env_tal.crossing_sigs in optimize() + specialize().
- [x] (f) sysface = shadow ∩ sys-crossings — DONE (430 green). `lower.sysface(
      sig, name) = def_rows ∩ bound-crossings` — the queryable effectful
      projection (DESIGN §0), a derived READ. Deliberately does NOT recompute the
      `TalFn.sysface` membrane bit (that would mark effectful lowered defs
      sys-faced → the floor membrane would refuse them; the bit stays the raw
      sys/bptr-op property). Tests: sysface projection (pure→∅, effectful→ports)
      + SPEC test 5 determinism (row derivation order-independent). **E70 COMPLETE.**
NOTE: additive/gated behind the closed => gate, so the pure baseline (404) is not
at risk IN PRINCIPLE — BUT opening the gate (d) couples to native codegen (c):
once effectful defs lower, any test that native-compiles all defs hits _conv_code
with no `prim put` case → Unsupported. So (c)(d) can't land as separate safe
increments; E70 needs the full path together. RISK POINT: does native codegen
handle the wrappers' ti-sys ops? (they run in build_sys_linkage's TalMachine
today, not native). => E70 DEFERRED to a focused session; findings + refined
seam + 6-point build order in E70 DESIGN §7b. Not rushed in this paced run.

## Routing (2026-08-02): E70 native integration deferred → doing rest of C
E70's buildable-now half is coupled to native syscall codegen (see above) — a
focused session, not a paced autonomous chunk. Per the user's "move to rest of C
if you hit issues", proceeding to E71/E72 whose buildable-now parts are doc/
chirality-data authoring, decoupled from E70.

## E70 TOPPED OFF FOR THE NEXT WAVE (2026-08-02) — IMPLEMENT-READY
DE-RISKED: the "risk point" (native syscall codegen) is RESOLVED — `nb-sys-*`
(sys-tal.chiral, via `ti-sys`) already compile into every native emission and are
tested (E21 arena / sockets / process-externs). E70 is now a MODERATE WIRING
effort, not a large integration. The next-wave implementer follows the E70 DESIGN
§7b build order (a)-(f); the E70 SPEC now carries an IMPLEMENTATION-READY callout
(read-this-first) with the 3 findings folded in. Concretely for step (c): relax
the `native.py:478` sysface membrane to admit the `wrap-*` E51 wrappers into the
native lib (they compile for free since they call `nb-sys-write`) + route
`prim <crossing>` -> `ti-call wrap-<crossing>`. Green line 410 -> ≥414; land
(a)-(f) one tested commit each; pure baseline stays green (additive/gated).
Ready to start implements next wave.

## Rest of C (if E69+E70 done)
- [x] E71 golden-semantics — DONE (407 green, commits 5d43dde/2db33f7/705c569).
      Spec `--audit spec` passed (1 FIX: stale green-line). Implemented all 4
      steps: lib/tal-spec.chiral (Obs/MState/SpecEntry/Verdict + conform, 2
      exemplar entries from the live corpus, all total) + tests/test_tal_spec.py
      (+3) + docs/tal-spec.md (prose anchor) + floor-agreement.md Statement
      rewrite (spec-as-golden, provisional). ledger-lint clean.
- [x] E72 capstone — buildable-now DONE (410 green, commits 248c618/fafd7af).
      Spec `--audit spec` passed (1 FIX: stale green-line). lib/climb.chiral
      (ShipItem/Stage/Breaker + climb stages 0-4 + breakers + ship-list, all
      total) + BOOTSTRAP.md (the chain in prose) + tests/test_climb.py (+3:
      total, manifest<->prose agreement, breaker coverage). ledger-lint clean.
      Running climb (Step 4) stays GATED on E70 + determinism debts — named in
      breakers/§6, not faked.

## E69⊗E70 CLUSTER SEAM — effectful closures NOW DONE (2026-08-02, 420 green)
E69's explicitly-deferred "effectful closures" are built — the SPEC's test 2
(effectful `apply-*` from E69's conversion lowers). The gap: `closconv._synth`
minted the defunctionalized `$apply` with a PURE arrow, so its crossing arm
failed the kernel's "effectful application inside a pure function." Fix (three
small closconv edits, all behind the existing conversion, 418→420):
- `_arrow_key` now includes COARSE per-arrow effect flags (`_pi_effs`) — pure
  and effectful families never collide, while a DYN higher-order use and a
  concrete-row ctor of one effectful shape still unify (coarse, not the row).
- `_mk_pi(dom, cod, effs)` mints `=>` arrows (DYN_SEATS) where `effs[i]` — DYN
  subsumes any dispatched closure's crossings; the precise row_union is E70's
  computed bottom-up shadow (synthesized defs skip the verify per SPEC §2).
- `_rewrite`: a def's type rewrite (`f:(=>..)`→`$clo`) now PRESERVES the def's
  own effect flags (`orig_effs`), or run-it's re-checked effectful body fails.
VERIFIED end-to-end: `(run-it act s)` with `act=(put s)` → E69 defunctionalizes
to an effectful `$apply0` → E70 lowers → native → real write(2) → "via-closure".
tests/test_effectful_lowering.py +2 (defunctionalize+lower; run native through
the closure). This is the cluster CAPSTONE — the E69⊗E70 co-dependence realized.

## STATUS (2026-08-02): cluster C buildable scope COMPLETE
- E69: complete (404 green).  E71: complete (407).  E72 buildable: complete (410).
- E70: native integration DEFERRED to a focused session — the one large piece.
  Fully scoped (E70 DESIGN §7b: findings + refined seam + 6-point build order +
  the gate/native-syscall-codegen coupling that blocks safe paced increments).
- Remaining C work is exactly: E70 native (a focused session) → then E72's gated
  running-climb + fixpoint (needs E70 + D-1/D-2 determinism debts). Clean stop
  point: everything decoupled-from-E70 is done, green, and committed.

## Log
- start: 401 green (commit 281b17b). E69 common cases (higher-order params,
  partial app, escaping lambda literals) + gate #3 linearity all live.
- 2026-08-02 E70 resumed on the user's "Section C ready for implementation"
  handoff. Step (a) landed additively: `crossing_sigs` table (put/print/trace →
  [Str]->Unit) wired into `lower_all`'s env_tal; 410 green, pure baseline safe.
  Next: (b) App emitter emits `prim <crossing>` for bound ports, then the
  integrated (c)+(d)+(e) unit (native wrapper routing + open the gate + row
  check) since they can't land separately-green.
- 2026-08-02 E70 core landed (418 green, +8 tests): steps (b)(c)(d)(e) as one
  integrated commit + a real soundness fix (DCE/CSE were dropping/merging
  effectful crossings). PAYOFF VERIFIED: `(def hello (=> Str Unit) (lam (s)
  (put s)))` lowers → compiles native → real write(2) → stdout "payload-42",
  CPython out of the crossing path. print appends \n; `(do (put s)(put s))`→
  "xx"; row-escape hard-rejects an under-declared row. Only (f) remains
  (deferred, its own increment). **E70's valuable half is DONE.**
