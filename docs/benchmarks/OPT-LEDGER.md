# The optimization ledger + the structural elements worth carrying forward

Companion to `OPT-CHECKLIST.md` (the worklist, now closed), `TRAIT-OPTS.md`
(the trait survey), and `RESULTS-2026-08-01.md` (six measured runs). Two
lists, both written as TRANSLATIONS — the conventional compiler term on the
left, what that thing actually is in chirality on the right — because the
translation is the point: some rows translate 1:1, some collapse to
something simpler here, and some have no conventional source at all.

## List 1 — actual optimizations (all landed 2026-08-01 unless marked)

### Landed, conventional-shaped (we play gcc's game, cheaper)

| # | Conventional name | What it is in chirality | Why it's cheaper here |
|---|---|---|---|
| 1 | Intrinsic inlining | `bget`/`blen` prims route to the machine op instead of the one-instruction `nb-*` wrapper call (`native._conv_code`) | The "intrinsic" IS the wrapper's whole body; no inliner, a routing table |
| 2 | Constant folding + propagation | `optimize.fold`'s `cenv` over SSA (`+,-,*,/,%`, `=i,<i,<=i`) | Folds delegate to the runtime's own arithmetic — bit-identical by construction, no float/UB caveats |
| 3 | Branch folding / SCCP-lite | Static case selection on a known constructor (`_fold_block`) | Constructor facts are first-class (`('c', cname)`); no lattice |
| 4 | CSE / value numbering | `optimize.cse` over the lowered fragment | Unconditional: purity is in the arrow, strictness kills the lazy-sharing hazard, SSA (checked) kills invalidation — no dominance analysis |
| 5 | Dead code elimination | `optimize.dead` incl. nullary cons | The pure/no-alloc set is definitional, not analyzed |
| 6 | Operand folding (imm forms) | emit-core const-tracking → `bini` (add/sub/imul/cmp rax,imm32) | The const env survives from the IR; redefinition-kill keeps hand-tal sound |
| 7 | Strength reduction (pow2) | `/2^k → sar`, `%2^k → and` | **Correction-free because division is Euclidean** — the semantics choice made the cheap encoding the correct one; truncated semantics (C) needs fixups |
| 8 | Value-range check elimination | Constant-divisor guard elision (`x-div-imm`/`x-mod-imm`) | The range "analysis" is a constant compare at emit time; `/-1`, `%1`, `%-1` collapse to no idiv at all |
| 9 | Tail-call optimization / loop conversion | `t-seq(ti-call d f a)(t-ret d)` → args + teardown + `jmp` (`tca`) | The pattern is explicit in the IR; also deletes the stack-depth ceiling — loops need no loop construct at the floor |
| 10 | Switch lowering (lookup tables) | All-const enum case → inline table load (`ltb`) | **No density analysis and no bounds check**: tags are dense 0..n-1 by declaration order and coverage is total — soundness by representation (OCaml's position, one floor lower) |
| 11 | Compare/branch fusion (isel) | `fcp/fci` + per-tag `fjc`; one cmp feeds both Bool arms (flags survive taken jumps; every arm terminates) | The bool is never materialized; its slot is never written |
| 12 | Peephole / local regalloc slice | Byte-level rax-residency pass (`x64-peep`): `store [s],rax; load rax,[s]` drops the load at chunk boundaries | Sound by bytes, not by analysis: labels are list elements, so jump targets can't lose their load |

### Landed, no conventional source (the trait-native rows)

| # | chirality name | What it is | Conventional equivalent |
|---|---|---|---|
| 13 | Totality-licensed comptime | A call whose whole call-graph closure is PROVEN total (`sig.totality`) + constant args evaluates at compile time via the reference interpreter (`_total_const_call`) | **None.** Zig comptime = fiat (can hang); C++ constexpr = fuel limits; total languages = totality-only programming. Proof-gated unbounded evaluation in a partial language is chirality's own row |

### Named, not landed (each with its lane)

| # | Name | Why it matters | Lane |
|---|---|---|---|
| 14 | Magic-multiply constant division | **LANDED 2026-08-02** — divmagic pass, HD 10-1 pair + exact Euclidean fixup, three synthetic prims (mulhi/sar/shr) through the existing prim seams, zero IR/Mach-record change. Run 7: arith 1.73x -> **1.37x** of -O2 | done |
| 15 | Real register allocation | Residency overlay deepened (pattern B: rcx reloads → reg moves — pinned but DORMANT in real emission: the b-operand load sits mid-chunk behind the a-load; run 8). An allocator that RETIRES slots is the remaining piece and collides with element 1 — a named design decision, not an incremental patch | design decision (author + E16/E17) |
| 16 | Control-flow jump tables | **LANDED 2026-08-02** — jtb: indexed jump through inline (a-rel 4) entries, zero new reloc machinery (element 7 survived). Correct + differential-pinned; states measured WITHIN NOISE (+3% point estimate — indirect-branch prediction at small varying-target n; gcc's own chain preference vindicated). Win case: large/unpredictable dispatch | done (tuning open) |
| 17 | Cross-function inlining, loop-invariant motion | Standard -O2 residue | E17 |
| 18 | Fact-carrying lowering | Refinement + quantity facts surviving into tal — unlocks Euclidean-correction elision (dividend ≥ 0), bounds-free byte ops beyond constants, and linear in-place reuse | E9 × E16, the architectural prize |
| 19 | Auto-pregen / specialization policy | **First bounded policy LANDED 2026-08-02** (`optimize.autospec`): const-arg sites -> deduped residuals, recursion+size guards, 3 cascade rounds, D-2 deterministic; plus pure-call CSE + memoized comptime evaluator. The unbounded principled policy stays with the staging modality | Fork C (author) for unbounded |

## List 2 — structural elements of the current floor to carry forward

The current emitter is "-O0-class" only in the sense of doing little; its
*structure* is not scaffolding, and several elements should survive into the
self-host ports, future Mach targets, and the language design as named
principles. Ranked by how load-bearing they proved this week:

1. **Slots stay truthful; registers are a cache.** The memory-machine design
   (every vreg in a slot) means machine state is inspectable and resumable at
   every boundary, and every optimization so far *refines* that baseline
   without obliterating it (the peephole drops reloads, never stores). Carry
   forward as the register-allocation philosophy: regalloc as an overlay on a
   truthful memory image, not a replacement of it — it is why the byte-level
   peephole had a three-line soundness argument, and it is a debuggability /
   auditability property the E16 port should keep on purpose.

2. **Single assignment as a checked precondition, not an accident.**
   Lowering emits SSA (monotonic `fresh`), and `_check_single_assignment`
   enforces it at every pass entry. Every fact system built this week (cenv,
   CSE keys, fusion soundness) leaned on "facts are never invalidated."
   Carry: SSA is the lowered fragment's contract, stated in the E16 SPEC's
   port, forever — hand-tal stays exempt and therefore stays unfolded.

3. **Preserve-check as the transform license.** Every pass output re-checks
   at the floor; an optimizer bug is an alarm, not a miscompile. This is what
   made an 8-item optimization day *safe to do fast*. Carry: no pass ever
   ships without it, including the chirality-side ports (E17's `Checked` sum
   makes the license un-forgettable in the type).

4. **Differential floors as the second license.** Reference interpreter,
   tal machine, and native must agree; and when wall-clock says nothing
   (run 6), the *disassembly* is the arbiter. Carry: `TalMachine` remains
   the permanent oracle even after self-host; every negative result gets a
   mechanical verification, not a shrug.

5. **Carry facts down; never re-derive them.** The week's organizing
   principle (P5 applied to codegen): cenv carries IR constants to the
   emitter, `sig.totality` carries the termination proof to the fold,
   dense tags carry coverage to the table emitter. Conventional compilers
   *analyze because their IR forgot*. Carry: fact-carrying lowering (#18)
   is this principle's next rung, and any future IR change should be
   scored by what facts it preserves.

6. **Choose semantics so the cheap encoding is the correct one.** Euclidean
   division made pow2 strength reduction correction-free; wrapping i64 made
   fold delegation trivial. This is a language-design test, not a compiler
   trick: when a semantic choice is open, prefer the one whose fast path
   needs no fixup. Carry into every future semantics decision (shifts,
   string indexing, overflow families).

7. **Emit-local structures over global machinery.** The `ltb` table lives
   inline (jmp-over + rip-relative backward lea, all displacements known at
   emit time); the division guards compute their own jump distances with
   `blen`. Zero new relocation kinds all week. Carry: prefer op-local layout
   knowledge; every reloc kind NOT added keeps `asm-reloc` — trusted floor
   machinery — small.

8. **The Mach face discipline.** Capability faces land as milestone-shaped
   record extensions (heap, byte, sys, optimization), a target is a
   conforming value, and the listing machine must render every op — so every
   codegen decision stays eyeball-checkable in text. Carry: an optimization
   that cannot be rendered in the listing does not land; a new target gets
   the whole optimization face by conforming, for free.

9. **Terminator-only blocks.** Every arm ends the block; nothing falls
   through. That single IR invariant is what made flags-survival (fusion)
   and frame-teardown (TCO) locally provable. Carry through the E18 tal
   self-host unchanged.

10. **Deliberate traps, never UB.** Division by zero is a chosen `ud2`, kept
    even on the statically-elided paths (d=0 still traps). The floor has no
    undefined corner; errors are loud. Carry into the effect floor: when
    alarms (E26/E39) reach tal, today's traps become typed crossings — the
    trap sites are already exactly where those crossings go.

11. **Determinism as a hard constraint on every pass (D-2).** Emission is
    total-key ordered; every pass added this week is a pure function of its
    input, so the Stage1==Stage2 byte-identity fixpoint (E53/DDC) survives
    an entire optimization campaign untouched. Carry: any future pass with
    nondeterministic iteration order (hash maps, parallel emission) is a
    DDC regression even if semantically correct.

## Element-by-element: enforcement status (verified 2026-08-01)

Each List-2 element checked against the code — is it ENFORCED (structural,
cannot regress silently), PINNED (a test breaks if it regresses), or
CONVENTION (held only by habit)? Conventions are the fragile ones; two got
pinned during this pass.

| # | Element | Status | Evidence / action taken |
|---|---|---|---|
| 1 | Slots truthful / stores never dropped | **PINNED (this pass)** | `test_backend.TestPeepholeContract`: 4 chirality-level tests against `x64-peep` itself — adjacent reload dropped, label blocks the pair (jump targets keep loads), different slot kept, store side survives |
| 2 | SSA as checked precondition | **ENFORCED** | `_check_single_assignment` at both pass entries (`optimize.py:218` fold, `:294` cse); hand-tal exempt by never being folded |
| 3 | Preserve-check as transform license | **ENFORCED** | `optimize()` ends in `tal.check_fn` (`:440`); the native path runs `optimize` per fn (`native.py:521`); `test_illtyped_pass_output_is_rejected` pins the alarm |
| 4 | Differential floors | **PINNED** | the suite: every native feature lands with a TalMachine differential; run 6's null result was settled by disassembly, recorded in RESULTS |
| 5 | Carry facts down | CONVENTION (by design) | a principle, not a mechanism — its enforcement IS the fact-carrying-lowering work (List 1 #18, E9×E16). Until then each new pass re-affirms it by review |
| 6 | Semantics-first encodings | **RECORDED** | settled in `docs/chirality-division-euclidean` + decision docs; the carry-forward is applying the test to future semantics decisions (author-tier, flagged not self-resolved) |
| 7 | Emit-local structures | **VERIFIED HELD** | `git log` on `lib/asm-reloc.chiral`: zero commits through the entire optimization campaign — the whole Mach face added no reloc kinds |
| 8 | Mach face + listing renders every op | **PINNED (this pass)** | `test_listing_renders_the_optimization_face` (table) + the cd golden (fused cmp, immediate, tailcall): every face op now has a listing assertion |
| 9 | Terminator-only blocks | **ENFORCED by grammar** | `TCode` (`tal-ir.chiral:42-44`) has no fallthrough form — unrepresentable, not checked |
| 10 | Deliberate traps, never UB | **PRESENT, partially pinnable** | 16 ud2 sites in the emitted artifact (grep of run-6 disasm); d=0 keeps the trap on the elided path by code. NOT test-pinned: a native /0 test would SIGILL the test process — the honest pin arrives with the effect floor (alarms as typed crossings, E26/E39), when the trap becomes catchable |
| 11 | Determinism (D-2) | **PINNED** | `test_ddc` bit-identity of two independent emissions — stayed green through all 13 optimizations, which is the strongest evidence the discipline holds under change |

Fragility ranking after this pass: element 5 is the only load-bearing
convention left without a mechanism (by design — its mechanism is the E9×E16
lane), and element 10's pin is honestly deferred to the effect floor.

## What the week proved about the two lists together

The conventional rows (1–12) bought the measured movement: 4.4×–57× behind
gcc -O2 down to 1.7×–9.5×, and 2–6× ahead of -O0. The trait rows (7, 8, 10,
13) are the ones a C compiler cannot copy, and each cost a fraction of its
conventional counterpart *because* a structural element from List 2 was
already holding (density by construction, semantics-first encoding, proofs
as licenses). That is the compounding to protect: List 2 is why List 1 was
cheap — optimize the floor, but do not optimize away its structure.
