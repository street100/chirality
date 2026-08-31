# Audit Map — Step 3 synthesis

2026-07-06. Synthesizes the seven family dossiers (`family-1` … `family-7` in this
directory). Those hold the per-element translation dossiers (paired snippets,
recipes); this file holds only what cuts across them: convergent findings, the
decision batch, defects, and the global ordering.

## Verdict roll-up (E1–E50)

- **PROPER (port/keep as-is):** E1 E3 E5 E7 E9 E11 E12 E13 E15 E19 E24 E35 E36 E37
- **EXTEND:** E2 E4 E6 E8 E10 E14 E16 E17 E18 E21 E27 E44
- **REDO:** E20 E23 E25 E26 E28 E29 E30 E31 E32 E33 (all = "CPython crutch, replace
  via the proven sys-slice / ELF path"; none are algorithmic rewrites)
- **UNBUILT:** E22 E34 E38 E39 E40 E41* E42 E43 E45 E46 E47 E48 E49 E50
  (*E41 mostly **dissolves** into E9 + linearity; residue = E52 brands)

No family found an algorithm that must be redesigned. Every REDO is a substrate
crutch with a known replacement recipe. The design docs held (family 6: zero REDOs).

## Convergent findings (independent multi-family hits — treat as settled facts)

1. **The Res decision gates the entire checker port.** Families 1, 2, and 4 all
   landed on it: chirality has no early-exit sugar, so a shared result/error type
   (CheckR/Res) + threading discipline (EmitR-style) must be pinned BEFORE any
   checker pass, or every pass gets rewritten. This is pass #0.
2. **New catalog elements** (multiple blind votes each):
   - **E51 — seam & linkage architecture under self-hosting.** Three faces of one
     question: how kernel seams (hook lists) are represented in a self-hosted
     checker (fams 1+2); a unified obligation/witness registry (fam 7); and the
     upper-effectful→sys-face linkage seam — today NOTHING in chirality-land can call
     the sys crossings except tests (fam 5; adjacent to E42/E43).
   - **E52 — fresh type-level brands** (generativity), the genuine residue of E41
     after refinements absorb the bounds checks (fam 6).
3. **tal-ir type erasure** (fam 3) is the single unblock for the pipeline family —
   typed `TalTy`/`TSig` in chirality retires Python `LIB_SIGS` and the Bool-only shuttle.
4. **ELF (E34) deletes work**: E20 loader and E23 trampoline are not ports, they
   evaporate on an ELF entry point. Family 5 sized ELF at M in the wire.chiral idiom.

## Defect ledger (real bugs/hazards found by the audit — fix cheap, before ports)

Status key: ✅ fixed+tested · ◑ partial (named+tested, follow-up flagged) · ⬜ open.

| # | What | Where | Severity | Status |
|---|------|-------|----------|--------|
| D1 | naive `k±1` at I64 extremes makes `{v>MAX}` = TOP | refine bound construction (E9/E11 port rule) | UNSOUND if ported naively | ⬜ open (port-time rule; no current bug) |
| D2 | silent >6-arg miscodegen (index ≥5 aliases r9) | `lib/mach-x64.chiral` arg-modrm | miscompile; add halt guard | ✅ `stp`/`lda` made effectful (like `bin`); x64 halts past 6 args; boundary test (6 ok, 7 halts) |
| D3 | native `idiv` faults on `INT_MIN/-1`, div-by-0 vs reference returns/raises | native vs runtime/tal | floor divergence; differential tests | ✅ mach-x64 guarded idiv: `INT_MIN/-1`→wrapped `INT_MIN` (all 3 floors agree, native tested across the domain); ÷0 traps deliberately (ud2) matching reference/fold `PortError` as fatal-not-value |
| D4 | unstated single-assignment invariant (stale fold facts; checker allows reg overwrite) | optimize/tal | latent; document + check | ✅ `fold()` enforces single-assignment as its precondition (correct layer — hand-tal reuses scratch & is never folded); `_fold_block` also clears stale facts on STR/BYTES const + fielded con (defense-in-depth); documented at `lower.py` fresh(); 3 tests |
| D5 | latent Var negative-index wrap | kernel eval | add assert | ✅ bounds-check → KernelError in `eval_term` + `Ctx.lookup`; both-direction test |
| D6 | doc-rot: claims truncating division | native.py:24 | trivial | ✅ fixed in native.py docstring + README |
| D7 | `bnew` zero-init agreement is accidental, not contractual | tal/native | pin as contract + test | ✅ contract documented (tal.py + mach-x64 + README); differential probe reads an unwritten byte → both floors return 0 and agree |

**Defect sweep (2026-07-06):** D2/D3/D4/D5/D6/D7 all fixed+tested (D3 native side
closed via the guarded idiv; D4 single-assignment enforced at the fold precondition).
D1 remains a port-time rule (no live bug — it's a rule for the future refinement
port, nothing to fix in the scaffold). Suite 191 → 200 green. The defect ledger is
now fully swept except D1 (which is correctly deferred to its port).
Next NOW-queue: the sys-slice verbatim recipe queue (E28 mmap first → completes the
E21 arena), then E38-s1 ∥ E44-reach ∥ E47-A ∥ E50-lex, then typed tal-ir.

**Sys-slice progress (2026-07-06):** `mmap`(9) + `munmap`(11) landed in
`lib/sys-tal.chiral` — mmap is the first crossing using all six syscall arg
registers. **E21 self-hosted arena now COMPLETE**: chirality creates (memfd), sizes
(ftruncate), maps (mmap MAP_SHARED), round-trips a byte through the mapping, and
releases (munmap) its own backing store — differentially tested native vs
reference. Suite 200 → 203 green. Remaining E28 slice: `mprotect`(10) + `close`(3);
then `open`(2), sockets (E29), poll (E31), spawn (E33). **manas-path note:** the
real gate is **E51 linkage** (upper-effectful → sys face) — these crossings are
test-reachable only until that seam exists; E51 + the edge-16 effect decision are
the pivot toward writing manas in chirality.

## The author-decision batch (blocks the middle of every ordering; decide together)

1. **Res/CheckR shape** (pass #0 prerequisite) — sum type + threading discipline.
2. **Edge 16 / effect algebra**: rows vs handlers (E39; absorbs alarms E26).
3. **E38 charging model** (what costs 1) — slice 1 needs NO decision, only slice 2.
4. **Edge 18** compositional-vs-global conformance + tier-weight compose (E44 sums).
5. **Edges 7/8**: Adhikara↔type correspondence; AUTH/AUDIT decomposition (E40/E43).
6. **E41 dissolve-vs-feature** (recommendation on file: dissolve into E9; keep E52).
7. **Stage-4 grammar**: graduate s-expr vs new notation (E49; co-gated with E38 binder).
8. **Reflective rung + gate mechanism** (E45, 4-rung ladder).
9. **Sized types as grade vs erased index** (E47-B; folds into the E38 call).

## Global ordering

**NOW — mechanical, no decisions needed (the "copying + boilerplate" queue):**
1. Defect fixes D2/D5/D6/D7 + D3 differential tests.
2. Sys-slice verbatim queue (recipe proven, all-integer): mmap(9) munmap(11)
   mprotect(10) close(3) open(2) socket(41) listen(50) accept(43) dup2(33)
   fork(57) exit_group(231). E28 first — completes memfd→ftruncate→mmap = E21 arena.
3. `nb-putle` helper, then poll(E31), sockaddr(E29-M), SCM_RIGHTS build-sheet (E30).
4. E38 slice 1 (pure semiring refactor) ∥ E44 reachability slice ∥ E47-A ∥ E50-lex.
5. E18 slice (a): typed tal-ir (`TalTy`/`TSig`) — unblocks the pipeline family.

**NEXT — the decision batch above (one sitting; most are small named choices).**

**THEN — the port campaign (order respects cross-family gates):**
- Pass #0: shared Term/Value/Qty/Ctx/Sig/Res data decls (fam-1 P0 + fam-2 gate;
  E27's alist registries ride along; E48 telescope early since Sig shape wants it).
- Checker: E5 → E1 → E13 → E12 → E3 → E9 → E10 → E11 → E4 → E6 → E7 → E8 → E14 → E2
  (fams 1+2 merged; Python checker stays the Tier-O differential oracle).
- Pipeline: E18(b) checker → E17 (earliest full self-host win) → E18(c,d) → E16
  (after E3/E13) → E15 last (golden oracle stays authoritative until differential match).
- Substrate/formats: E34 ELF (deletes E20/E23) → E33 spawn crossings → E42-A
  scheduler (needs poll) → E43 broker → E39 effects (absorbs E26) → E40 → E22
  allocator (Tier-F) → E52 brands → E41 retirements (after E9 completion).
- Theory tail: E50-mutual → E46-ledger → E47-B → E49 per decisions → E45 → E46-full.

## Pace ledger (for wave sizing)

7 auditors ≈ 1.02M subagent tokens total (range 126k–174k each; ~10 min each).
Interrupted agents resume from transcript at near-zero cost — resumes of fams 4/5/6
after the spend-limit cut cost ≈ one write step. Future waves: 2–3 agents per wave
is the right size at 5x.
