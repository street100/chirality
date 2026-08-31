# Rung 1 — the real critical path (surfaced 2026-08-03, session 2)

> ## ⚑⚑⚑⚑⚑⚑⚑ SESSION-7 STATE (2026-08-05, 668 green, main@fbe5103+) — B1 WORKS
> **Authority moved: read `.planning/HANDOFF-RUNG1-FIXPOINT.md` top +
> `.planning/RUNG1-CHECKLIST.md`.** The self-compiled compiler (B1) compiles
> programs natively end to end; Phase A is done through A3. A4 = the byte
> compare, ONE host command (`python3 tools/selfhost.py stage2`). The blocks
> below are history.

> ## ⚑⚑⚑⚑⚑⚑ SESSION-4 STATE (2026-08-04, 652 green) — THE WHOLE COMPILER LOWERS + ONE-SIG DRIVER
> The long-standing "back half doesn't lower / the stages don't compose" blocker
> is **GONE**. Every function all three compiler entry points reach lowers to
> native with **zero unlowered**: `compile-front`, `back-program`, `emit-elf`.
> And there is now a single native-compilable compiler function `compile-all :
> Str → ELF` (`lib/compile-all.chiral`) whose output is **byte-identical** to the
> 3-RT con-value shuttle (verified, `TestOneSigCompileAll`) and which itself
> **lowers to native**. What got us here this session:
> - **poly-13** (the closconv family-codomain-keying bug) fixed; a second closconv
>   head-position bug fixed.
> - **`Op` closed sum** replaced the stringly tal prim op + its defensive `halt`,
>   making `op-bytes`/`emit-instr` pure (the E70 row-escape stopped *existing*).
> - **fn_sig pre-pass** in `lower_all` → order-independent direct calls (631→905).
> - three emit/front leaves (crossing q=0 erasure, closconv case-arm binder types,
>   two nested-case-scrutinee → and/or rewrites) → **the whole compiler lowers.**
>
> **HONEST remaining distance to the fixpoint (NOT one step — do not over-claim):**
> 1. **Front self-parse.** `compile-all` compiles prim-free programs byte-identically,
>    but a program using `+` fails "unknown name +" — `compile-front`/`load-source`
>    does not seed the prelude externs into the program's Sig, and does not handle
>    `(import …)` (needs a file-read sys face). To self-compile, the front must parse
>    + typecheck the WHOLE compiler source (imports, prelude env, full language, at
>    scale). This is the real remaining front-end work.
> 2. **I/O driver.** A native `compile-all` binary must read its source + write the
>    ELF via the sys face (the face + a zero-python run path already exist —
>    `test_chirality_driver_execs_elf_no_python`); wire an entry that does read→compile-all→write.
> 3. **Strings-as-constants at compiler-source scale.**
> 4. **The fixpoint itself:** compile `compile-all`'s own source with `compile-all`,
>    twice, byte-compare (`ddc.chiral`). Evicts the CPython compile interpreter.
> Then B (delete the `scaffold/chirality/*.py` seed, contingent on the fixpoint) and
> C (test harness off Python, ~13k LOC, the hidden mountain) for FULL rung 1
> (= zero python in the repo). A is close; B+C are not this-session work.


> ## ⚑⚑⚑⚑⚑ SESSION-3 STATE (648 green) — CHIRALITY COMPILES + RUNS WHOLE NATIVE PROGRAMS
> The chirality compiler compiles + runs native x86-64 ELF binaries, ZERO CPython in
> the compile path, for a real fragment: **whole programs (multi-def + inter-def
> calls), enum AND boxed/heap-allocating data, AND higher-order functions/closures**
> (`d9d60b3` — the E69 closconv driver built + wired: `$clo`/`$apply` install +
> body rewrite; both `ap inc` and an escaping capturing `lam` run + exit 42). The
> whole compile runs across three collision-forced images (check/lower/emit) joined
> by neutral con-value transports; CPython only writes+exec()s the bytes (Decision
> #4) + shuttles inert values. Every stage is differential vs its Python oracle +
> independently re-verified. Commit chain this session: full-ADT kernel → #6 →
> loader (source-driven, recursion) → tal-IR unify → erasure → compile+run → multi-
> def → arena/heap → closures.
>
> **REMAINING to the Stage1==Stage2 fixpoint (compile the compiler's OWN source,
> twice, byte-compare):** (a) the fragments the compiler source still uses that
> aren't in the native path yet — **strings-as-constants**, the **sys/I-O face**
> (syscalls for real output), and any HO shapes closconv leaves (nested/linear
> captures = closconv.py §6 residue). (b) **deferred hardening:** the closconv
> driver installs `$clo`/`$apply` STRUCTURALLY, not kernel-re-checked (sound — the
> native run is the end-to-end check + the pure conversion is oracle-differential —
> but re-check would turn a conversion bug into a check alarm). (c) the **W^X second
> RW PT_LOAD** split (currently one RWX segment). (d) then wire the fixpoint
> byte-compare via `ddc.chiral`/Lane-prep + DDC. The HARD fragments (data, heap,
> closures) are DONE; the remaining is strings+sys+scale+the fixpoint wiring.
>
> ## ⚑⚑⚑⚑ SESSION-3 MILESTONE (642 green) — CHIRALITY COMPILES + RUNS A PROGRAM
> **A chirality-compiled program RAN natively and exited 42, ZERO CPython in the
> compile path** (`cb13f81`). `(def main (-> I64 I64) (lam (n) 42))` and
> `(+ 20 22)` each go source → parse → elaborate → typecheck → lower → erase →
> emit x86-64 → ELF, all in chirality; the Python harness only writes the bytes +
> exec()s them (the acknowledged Decision-#4 host crossing) and shuttles inert
> con-values between images. The WHOLE pipeline is proven end to end for the first
> time. Structural reality: the compile runs across THREE images (check `Term` /
> lower tal-ssa `TFn` / emit tal-ir `TFn`) that can't share a Sig (flat namespace,
> the same refraction as the erasure seam) — joined by neutral con-value transports
> (`lowspec`/`compile-front`/`compile-back`/`compile-emit`). Entry stub is
> byte-identical to `native.py`'s oracle.
>
> **Remaining to full rung-1:** whole-PROGRAM emission (the driver compiles the
> entry def only — multi-def + the hand-tal library + user-data at the erase step
> is the next slice), then the **Stage1==Stage2 fixpoint** (compile the compiler's
> OWN source, twice, byte-compare via the Lane-prep/`ddc.chiral` harness) + DDC.
> The pieces all exist + compose now; it's scale + the fixpoint wiring.
>
> ## ⚑⚑⚑ SESSION-3 CHECKPOINT (633 green) — THE FRONT HALF OF RUNG 1 IS DONE
> The **whole check path is now chirality, source-driven**: `lib/parse.chiral`
> `load-source : Str → LoadR` reads bytes (E1) → parses `Sexp→Surf` → elaborates
> (E2) → bridges `Core→Term` → type-checks into a `Sig` with the full-ADT kernel.
> Every construct the compiler's OWN source uses is covered + differential-clean
> vs `Elab().load_str`: defs, data (con/case/positivity/linear), `let`/`do`,
> `extern`/`porttype`, forward-`declare`, and **mutual + self recursion**. The
> full-ADT kernel (items 1+2), decision #6 (VRefine+narrow), and the loader
> (items 3.back + 3.front) all landed this session, each verified.
>
> **REMAINING = THE BACK HALF (the acknowledged long pole):** check → **closconv
> (E69)** → **lower (E16)** → **emit (`emit-x64`/`elf`)** → native → **fixpoint**
> → DDC. The native codegen EXISTS in chirality (`mach-x64`/`emit-x64`/`elf`/`backend`;
> `emit : (List TFn) → bytes`), and `ddc.chiral` is the compare harness — BUT the
> stages were each built as ISOLATED differential ports (hand-built inputs matching
> their Python oracle), so **they don't yet compose**: wiring them is GATED on the
> **tal-IR / `Core` representation unification (the "dedup debt")** — three
> duplicate tal `TFn`/`Block` IRs (`lower`/`tal-check`/`tal-eval`/`tal-ir`) + the
> kernel-`Term` vs surface-`Core` vs closconv-`Core` split must become ONE. That
> rep-unification is the next real slice; then the `compile : source → native`
> driver wires cleanly, then the CPython `NativeBackend` (`native.py`, used by
> `cli.py:135`) is retired from the run path (item 4), then Stage1==Stage2. Loader
> residue (smaller): `import` (needs a file-read sys face) + the double-finish /
> `measure` / indexed-porttype edges. **This is where to scope WITH the author —
> the rep-unification is a cross-cutting design call, not a blind chug.**

> **⚑ UPDATE 2026-08-03, session 3 — items 1+2 DONE (the keystone).** The full
> `Sig` (item 1) and the **full-ADT kernel** (item 2) are built: `E04-full-adt-
> kernel` slices 1–4 all landed. `lib/kernel.chiral` `infer`/`check` are now
> `Sig`-parameterized over globals/prims/literals/**con/tcon/case**, the data
> layer's `DataDecl`/`Field` carry kernel `Term` (E6/E7 re-ported over `Term`, a
> leaf `lib/syntax.chiral` breaks the cycle), and the `Sig` carries linear
> registries. A real def body (globals+data+case+literals) type-checks in chirality
> matching `kernel.py`, differential-clean. **570 green.** Two residues surfaced,
> both then addressed: **(#6) DONE** — the full VRefine-in-kernel-Value
> integration was ported (t-refine/v-refine + eval/quote/conv/subtype/check +
> `narrow-branch` in the case arm), differential vs `refine.py` in three slices,
> **588 green**; the case arm is now fully faithful incl. path-sensitivity.
> **(ty-cmp)** the vestigial-`Ty` order is left as a determinism debt (no consumer
> yet — the fixpoint seen-set that would use it isn't built).
> **ITEM 3 (the loader) — IN PROGRESS, back half DONE (session 3 cont., 597
> green).** `lib/loader.chiral`: the **Core→Term bridge** (`core->term`, decision
> #1) + the **def driver** (`load-def`/`load-items`/`load-unit` = kernel.py
> check_def: declare the type-is-a-universe, install for recursion, check the
> body) + the **data driver** (`load-data` = check_data: params are types,
> install-for-recursion, each field a type + strictly positive + linear-kind).
> Differential vs the Python loader: function defs (id/const/HO/type-mismatch/
> lambda-vs-nonfn) AND whole programs (data Bool+neg, Box+unbox, parameterized
> Lst+case) — the chirality loader loads real programs and type-checks them,
> matching `Elab().load_str`. **Remaining for a SOURCE-driven loader (the front
> half):** the parser `Sexp→Surf` (E1 sexp → surface, all 13 Surf forms) + the
> top-level form loop (`Sexp→LItem`, incl. the deferred data-decl elaboration +
> prim/extern `declare`s). Then items 4 (native emission) + 5 (fixpoint/DDC).
> A known limit to lift: `eval-term` doesn't unfold globals (types mentioning a
> global stay stuck) — fine for the current corpus, needed before globals-in-types.
>
> **⚑ FRONT HALF NOW DONE (session 3 cont., 614 green) — the "Remaining" above is
> BUILT.** `lib/parse.chiral`: `parse : Sexp→Surf` (all 13 Surf forms, mirroring
> `surface.py`) + the top-level loop threading BOTH a kernel `Sig` and an elab
> `SEnv`, handling `(def name ty body)` and `(data Name (params) ctors)` (the
> deferred E2 data-decl elaboration), wrapped by **`load-source : Str → LoadR`**.
> Differential vs `Elab().load_str`, 17 cases (functions, `the`, Sig-threaded
> two-defs, data+case, field con/case, param'd `Lst`, default, `cond`; rejects:
> codomain mismatch, lambda-vs-nonfn, non-positive data, non-exhaustive case,
> wrong ctor arity). **Item 3 (the loader) is SOURCE-DRIVEN end to end for
> def+data programs.**
>
> **⚑⚑ UPDATE (627 green) — the loader now also handles `let`/`do` + `extern`/
> `porttype`:** **(a)** `t-let` LIFTED in the kernel (QTT let rule; `t-let` carries
> a `Qty`; `let`/`do` check end to end — `do` desugars to a linear let, reuse
> rejected; differential incl. usage vectors) — `330bf7a`. **(b)** top-level
> `(extern name ty)` (→ Sig `prims`) + `(porttype Name)` (→ linear `latoms`) in the
> source loop, differential vs `load_str` (extern used, undeclared-prim rejected,
> non-type-extern rejected, linear-port `w`-field rejected) — `fd39a49`. The
> `(declare …)` head is the FORWARD-DECL for mutual recursion (not extern — oracle
> finding). **Remaining loader residue:** the `(declare name ty)`/`(def name body)`
> forward-decl split (mutual recursion — the compiler's OWN source needs it);
> `(import "path")` (needs a file-reading sys face); `target`/`profile`/`measure`;
> indexed `porttype`; eval-global-unfold. **Then the big integration:** wire
> `compile : source → check → lower(E16) → emit(mach-x64/elf, exist)`; the E70
> native residue (DDC harness still calls CPython `NativeBackend` for leg-0); the
> Stage1==Stage2 fixpoint byte-compare; DDC.

> Written after the E69/E70-port + sig-driver session drove the piece-wise ports
> as far as they go and hit the actual remaining core. This reshapes the rung-1
> picture: it is NOT "finish a few ports + wire the fixpoint." Read this before
> planning the next rung-1 work. Grounded in greps, not memory (see §1).

## 1. The finding (verified against the live lib)

The chirality-side checker/compiler is a set of **piece-wise ported functions**, each
differential-tested against its Python original — but they are **pieces, with no
spine tying them together, and the trusted pieces are the CLOSED CORE only:**

- **The kernel judgment is core-calculus-only.** `lib/kernel.chiral` `Term` =
  `t-var/t-type/t-pi/t-lam/t-app/t-let/t-ann` — **no `t-global`, no data
  constructor, no `t-case`, no literals** (the file says so: line 14, "globals/
  prims, data values, let, literals -> E6/full-ADT assembly"). `infer`/`check` are
  `(-> Ctx Term _)` — **no `Sig` parameter**, so a global reference cannot even be
  *represented*, let alone resolved. E3/E4's differential ran over core-calculus
  cases only.
- **There is no full signature representation.** The only sig-ish view is E69's
  read-only `SigV` = `(tys defs)` (function types + bodies as `Core`). It has **no
  data-decls field, no prim-types, no def_rows** — it cannot hold an installed
  `data` type or an extern. Grep confirms: no `data Sig|Module|LoadedSig` anywhere.
- **There is no compiler loader/orchestration in chirality.** Nothing parses a
  `.chiral` unit, elaborates it into a sig, checks it, lowers it, and runs it, in
  chirality. (`coordinator`/`backend` are the *manas* AI cycle, unrelated.) The
  scaffold's `Elab`/`load_file`/`lower_all` orchestration is all still CPython.

So **every deferral this project made — "E6/full-ADT assembly", E2's "import
loader", the E69 "sig-mutation driver", row-inference's "sig-representation second
half" — is the SAME missing subsystem**: the full-ADT kernel + a real signature +
the loader that assembles and drives it. That subsystem is rung 1's long pole.

## 2. Why the piece-ports don't add up to rung 1 yet

Rung 1 = **zero CPython in the check/compile/run path + Stage1==Stage2 byte-
identical + DDC converges.** For that, a chirality program must be *run through a
chirality compiler*. Today each stage exists as a tested chirality function, but:
- they speak **incompatible representations** (kernel `Term` ≠ surface `Core` ≠
  lower `Core` ≠ closconv `Core`; three duplicate tal IRs — see the dedup debt);
- the trusted judgment **can't check real programs** (no globals/data/case);
- **nothing drives** parse→check→lower→emit→run end to end in chirality.
The fixpoint has nothing to run until this spine exists.

## 3. The remaining subsystem, dependency-ordered

1. **A full signature representation** — `Sig` carrying types + def bodies + data
   decls + prim/extern types (+ the def_rows/ports/bound the sig-driver already
   derives). The one structure the loader writes and every judgment reads. This
   is the recurring "sig-representation" decision, now unavoidable. Unify the
   `Core` representations here (kernel/surface/lower/closconv all need ONE).
2. **The full-ADT kernel** — extend `infer`/`check` to `(-> Sig Ctx Term _)` and
   the `Term`/`Value` ADT with globals (resolve in `Sig`), data constructors +
   `t-case` (via the E6/E7 checks, already ported), and literals. THE "E6/full-ADT
   assembly" the kernel comment names. Trusted-core — scope + differential each arm.
3. **The loader / orchestration** — a chirality driver: read (E1 `sexp`, done) →
   elaborate (E2 `surface`, core done + the deferred write-backs: `_calls`
   [`scan-calls`, done], row inference [`infer-row`, done], `_elab_stamped`) →
   **install into `Sig`** (this is req #2, the E69 sig-mutation — now seen as a
   sub-step of the loader over the full `Sig`, not a standalone driver) → check
   (full-ADT kernel) → lower (E16 + the E70 effect layer, done) → emit.
4. **Native-emission integration** — the E70 native routing (`prim <crossing>` →
   wrapper → syscall, mach layer) + the tal-IR unification (dedup debt) so a
   single effectful `lower-all` driver exists.
5. **The fixpoint harness + DDC** — Stage1==Stage2 byte compare (Lane-prep built)
   + E53 DDC across provenance-disjoint legs. Decidable once (3)+(4) run natively.

## 4. What IS done (so the next session doesn't redo it)

- Trusted core calculus: NbE + bidirectional (E3/E4), core-only.
- Data checks: coverage/positivity/linear-kind (E6/E7/E8) — as judgments over a
  `DataDecl`, ready for the full-ADT kernel to call.
- Refinement (E9/E10), totality (E11), effects membrane (E12), pretty (E14),
  interp (E15), lowering pure+partition (E16), tal check/interp (E18),
  optimizer (E17) — all ported + differential.
- **The entire effect/sig-driver layer** (this session): row inference
  (`row-infer`), the input derivations (`sig-derive`: ports/bound/calls), the
  EffSig assembly + E70 gate + preserve-check (`sig-driver`), and E70 emission at
  the tal level. The E70 floor check runs on chirality-derived data. These feed
  straight into the `Sig` (item 1) and the loader (item 3).
- 537 green.

## 5. Corrected disposition of the "two remaining reqs" (from the HANDOFF)

- **#1 E70 emission** — done at the tal level; native routing is item 4.
- **#2 E69 sig-mutation driver** — **NOT a standalone buildable piece.** The
  verify-first fired: its validation half needs the full-ADT kernel (item 2, the
  judgments can't represent `$apply`/`$clo`'s globals+data+case), and its assembly
  half needs the full `Sig` (item 1, `SigV` can't hold data decls). It is the
  install sub-step of the loader (item 3). Do it there, not before.
  (`.planning/E69-sig-mutation-PLAN.md` is superseded on this point — kept for its
  oracle map + dedup inventory.)

## 6. Recommendation

The next rung-1 build is **item 1 (the full `Sig`) then item 2 (the full-ADT
kernel)** — the keystone the whole spine rests on, and trusted-core, so it wants
its own pipeline scoping (worked-example → spec → audit) before implementation,
NOT a fast chug. Everything downstream (loader, #2, fixpoint) is gated on it. The
dedup debt (`.planning/E69-sig-mutation-PLAN.md` §5) is folded into item 1's
`Core`/tal-IR unification.
