> **ARCHIVED 2026-09-01. Superseded by `docs/definitions/status-ledger.md`, tracked, which owns build state on the rungs.** The operational note it carried needs no hoist: `CLAUDE.md`s BUILD RULE already runs the whole ceremony under `ulimit -s unlimited` and already states that a fixpoint shows stability and says nothing about correctness.

# HANDOFF — the rung-1 fixpoint (read this first, then RUNG1-CHECKLIST.md)

## ✅✅✅✅ FIXPOINT ACHIEVED — 2026-08-05 (the rung-1 keystone)

**`python3 tools/selfhost.py stage2` → `FIXPOINT: B1 == B2 (byte-identical,
659681 bytes)`.** In **1 second**, **peak 0.1 GB**, deterministic + stable
(verified 3×). The native compiler B1 compiles the entire compiler source to a
byte-identical copy of itself, with **zero CPython logic in the compile** (python
only redirects fds). **A4 is DONE — the CPython interpreter is evicted from the
compile path; B1 self-reproduces natively.**

**What cleared it (this session):** the A4 OOM was NOT missing memory disciplines
— it was one quadratic. `materialize` (`lib/asm-reloc.chiral`) built the image via
right-nested `bcat`, O(N·M) ≈ 12-16 GB for the 660 KB self-compile image; the core
trapped exactly there (`nb-bcat`). Fixed to balanced concat O(N log M) (commit
4e7791b) → peak 12 GB → 0.1 GB. Also landed the E81 `Alloc` policy seam (composable
memory disciplines, commit d6ad519) — the pre-run investigation for its E82 sequel
is what surfaced the quadratic. **E82 regions are NOT needed for the fixpoint.**

**Operational note:** B1 needs a large stack (deep non-tail recursion);
`selfhost.py` sets `RLIMIT_STACK=infinity`. Manual `build/B1 < blob` needs
`ulimit -s unlimited` or it segfaults on bash's 8 MB default.

**NEXT = Phase B (pack the Python seed):** `scaffold/chirality/*.py` (~8k LOC) still
bootstrapped the first B1 via the interpreted stage1. Now that B1 self-reproduces,
commit B1 as the seed binary (bootstrap from it, no CPython) + pack the py seed
(priv keeps it as oracle; pub strips it, keeps tests). See RUNG1-CHECKLIST Phase B.
Authoritative slice ledger: `.planning/FIXPOINT-CHECKLIST.md`.

---

## ⚑⚑⚑⚑ (superseded by the block above) 2026-08-05 (B1 WORKS; fixpoint = run stage2 on the HOST)

**State: `main` @ 04834a0, clean, 668 green. `scaffold/build/` (bind-mounted,
survives VM restarts) holds a VERIFIED-WORKING B1 (659681 bytes), blob.chiral
(490097 chars), offsets.json (5185 labels).**

**B1 — the chirality compiler compiled by itself — WORKS**: `printf '(def
compile-main (-> I64 I64) (lam (n) 42))' | build/B1 > t.elf` → exit 0, and
t.elf runs → exit 42. Correct error messages on bad input. ZERO python in
that compile.

**THE ONE REMAINING STEP to the rung-1 keystone:** `cd scaffold && python3
tools/selfhost.py stage2` — **ON THE HOST, not the 4 GB VM** (the native
self-compile's bump heap OOM-killed the VM at ~3.5 GB / 14 s in; the stub
mmaps 12 GB NORESERVE, host RAM backs the touched set). stage2 runs
`B1 < blob > B2` (no python in the compile), auto-runs a B2 sanity
(compile+run 42) and, on byte mismatch, `selfhost.py diff` — which names the
differing FUNCTIONS via offsets.json. On a crash: `ulimit -c unlimited`,
re-run, then `python3 tools/selfhost.py crash` (symbolized backtrace).

**Rebuild loop if source changes:** `python3 tools/selfhost.py stage1` — now
~305s (was 1222s) with phase timing (front ~136s / back ~96s / emit ~38s +
35s offsets capture); heartbeat prints cpu (the working-vs-wedged signal; RSS
staying ~60-155 MB is NORMAL), periodic stack samples, SIGUSR1 on demand.

**This session's six root-caused fixes (all committed, none recurring):**
x64 SysV >6-arg (stp/cal + tail DEMOTION — jmp-tails can't carry stack args);
specialize/closconv/lower prune-retract soundness; chirality-front crossing-q0
erasure (halt's type arg) + case-on-word recovery + B4-default (back parity);
TWO label-namespace collisions (runtime data-defs renamed -t; minted labels →
$b/$lit; emitters REFUSE duplicate labels loudly); arena (1MB→12GB imm64
NORESERVE stub, 89 bytes, python mirror in lockstep); emit quadratics killed
(tree-map resolve-label + cons place + tree-set lit dedup — bytes unchanged).

**If the fixpoint FAILS:** diff names the functions; suspect determinism
first (D-2: emission order, map iteration — both designed deterministic) and
remember Stage-1(interpreted) vs Stage-2(native) must agree bit-for-bit:
any interpreted-vs-native semantic divergence in the COMPILER's own code
shows up as a B2 mismatch. `diff`'s per-function grouping + disasm
(objdump exists in the VM) localizes; the probe-image pattern
(now `tools/probe.sh` + `tools/probe-main.chiral`, B1-built, all five probes in
1.6s — `probe_image.py` was REPLACED 2026-08-22 in H4b; it existed only because a
library squatted the `compile-main` entry symbol, which H4 fixed) iterates
natively in ms once built.

**After the fixpoint holds:** B' = pack seed (priv keeps scaffold/chirality/*.py
as test oracle + tarball; pub strips seed, keeps tests) — per the RE-SCOPED
checklist (test rewrite is OFF the list; user call 2026-08-04).

---

**Goal (fixed, do not re-scope):** rung 1 = ZERO Python in the repo. All of
`scaffold/chirality/*.py` gone, a self-hosting native compiler, tests off Python.

**The ONE worklist is `.planning/RUNG1-CHECKLIST.md`** (A1..A4, B, C, each with a
`DONE-WHEN`). This file is the narrative + the exact next-step. Live task list is
in the harness (TaskCreate/TaskList) mirroring the checklist.

State: branch `main`, clean, **663 tests green**. Everything below is committed.

---

## ⚑⚑⚑ START HERE — FABLE HANDOFF 2026-08-04 (one bug from the first self-compiled ELF)

**Repo: `main`, clean, 663 green. All progress below is committed.**

**The whole "emit-code won't lower" mystery is SOLVED and the real blocker FIXED.**
The chirality loader never stored a forward-declared def's body — `load-declare`
installed a placeholder `(t-type 0)`, `load-finish` checked the real body but
returned the Sig unchanged. So every mutually-recursive/forward-declared def
(emit-code + the whole emit group + more) had a `t-type` body: fine for
type-checking, fatal for lowering. **FIXED (commit 6002de9):** `sig-set-global-body`
in `load-finish` stores the checked body. Verified: a forward-declared def now
lowers+runs+exits 42.

With that fixed, **Stage 1 runs the ENTIRE emission** (front+back+emit all execute
on the compiler's own source) and stops on the **ONE remaining blocker:**

### THE ONE REMAINING BLOCKER: x64 SysV >6-arg passing
`emit(x64): call/def with >6 args` — the x64 backend (`lib/mach-x64.chiral`) has no
SysV stack passing for the 7th+ argument. Compiler functions need it (`lower.chiral`
`outline`=9 args, `emit-call`/`expr-con`/`expr-case`/`build-outline`/`tail-case`=8;
these are erased-arg counts, all runtime). After this lands, `compile-main` emits →
B1 → Stage 2 → the byte-compare fixpoint. **This is the last thing.**

**I attempted it and REVERTED (buggy — do not look for it in the tree; rebuild).**
What I learned (save time):
- **Approach that's right:** make the `cal` field take the arg list
  (`(-> I64 Str (List I64) (List Asm))`) so x64 does the whole call itself — this
  avoids adding Mach-record fields (which would ripple 35 accessors). BUT it
  perturbed the specialize pass ("unknown global x64") — investigate why the
  q0-drop of the Mach arg at `emit`'s `(emit-with-peep x64 …)` interacts.
- **Incoming side is sound:** arg i≥6 sits at `[rbp + 16 + 8*(i-6)]` (after push
  rbp); fix `stp`'s false branch = `mov rax,[rbp+16+8*(ap-6)]; mov [rbp+slot],rax`.
  `store-params` already loops all params, so 6+ get stored once stp handles them.
- **Outgoing side has a PLACEMENT BUG I did not crack:** `sub rsp,align16(8*(N-6))`;
  write arg i≥6 to `[rsp+8*(i-6)]` (mov rax,[rbp+slot]; mov [rsp+off],rax); place
  reg args 0-5; CALL; `add rsp,S` (after storing rax→dst, which is rbp-relative).
  Encodings verified correct (`sub rsp,imm32`=48 81 EC; `add`=48 81 C4;
  `mov [rsp+d],rax`=48 89 84 24 d; `mov rax,[rbp+d]`=48 8B 85 d). YET a 7-arg fn
  returning its 7th arg gave **1**, an 8-arg gave **129** (expect 42). So either
  the alignment PADDING goes on the wrong side (args should be at the LOW end,
  [rsp+0]=arg6 — I did this, but re-verify vs native.py) or an rsp-timing issue.
  **DIFFERENTIAL AGAINST native.py** — it implements full SysV; compare the exact
  call byte sequence for `(f7 0 0 0 0 0 0 42)` (repro below).
- **Keep the <=6 path byte-identical** or the 663 suite + byte-identity test break.
- `test_native.py::test_seventh_arg_halts_emit` ASSERTS the old halt — update/remove
  it when the halt is replaced.

**Repro (fast, ~1s):**
```
cd scaffold && python3 -c "
import sys,os,tempfile,stat,subprocess; sys.path.insert(0,'tests')
from chirality.surface import Elab; from chirality.runtime import RT
from test_compile_run_chirality import _call
el=Elab()
for f in ['sys-linkage','compile-front','compile-back','compile-emit','compile-all']: el.load_file('lib/'+f+'.chiral')
rt=RT(el.sig)
src='(def f7 (-> I64 I64 I64 I64 I64 I64 I64 I64) (lam (a b c d e f g) g))\n(def main (-> I64 I64) (lam (n) (f7 0 0 0 0 0 0 42)))'
r=_call(rt,'compile-all',src,'main'); data=r[2][0]
fd,p=tempfile.mkstemp(suffix='.out'); os.write(fd,bytes(data)); os.close(fd); os.chmod(p,stat.S_IRWXU)
print('exit',subprocess.run([p]).returncode,'(want 42)'); os.unlink(p)"
```
Oracle to diff: `chirality/native.py` (full SysV). Grep it for how it places the 7th+
outgoing arg + the stack-adjust around the call.

---

## ⚑ SESSION UPDATE 2026-08-04 (effectful lowering DONE; next blocker = emit-code peel)

The "single blocker" below (chirality back can't lower effectful `=>` defs) is
**CLEARED + committed** (15f12ba, 8be873b). What landed:
- **Crossings lower/emit/RUN native.** `compile-fn` already emitted a bound
  crossing as `i-prim` (E70); the missing legs were ERASE and EMIT. Now:
  `lib/crossing-wraps.chiral` (prelude-only crossing→wrapper table, the one map the
  tal-ssa erase image can see); `tal-erase.chiral:erase-instr-onto` expands a
  crossing to `n-call <wrapper>` + (for Unit crossings only) an `n-con dst 0`
  overwrite that discards the raw syscall count — **type-aware**, so `read`
  (→Bytes) keeps its cell; `sys-linkage.chiral` derives `sys-bindings` from
  crossing-wraps + adds `link-lib`; `compile-emit.chiral` links `link-lib`.
- **Verified end to end:** chirality-compiled effectful programs run native with
  (stdout, exit) matching the NativeBackend oracle; a chirality-compiled binary
  **reads stdin and echoes it** (native I/O, zero CPython compile logic).
  `tests/test_effectful_compile_run_chirality.py` (5 tests).
- **Stage 1 now lowers read-fd-all/read-fd-go** (were dropped before).

**THE NEW BLOCKER (pinpointed 2026-08-04, diag2.py):** Stage 1 still fails at
`no emitted label for entry compile-main`. Cause: **`emit-code` (emit-core.chiral:428)
is the sole emit-chain function that fails to PEEL at the front** (`term->ncore`
returns none on its body); every caller (emit-fn→emit-program→emit-with→emit→
emit-elf→compile-all→compile-main) then cascade-drops at the back. Root: **`Mach`
(mach.chiral:26) is a record of ~36 FUNCTION fields** (a first-class dictionary of
machine-op closures), applied throughout emit-code as `((mach-ret m) src)` etc.
**closconv-sig does NOT defunctionalize a record-of-closures** (only 2 $clo/$apply
generated across the whole compiler).

**⚑ CORRECTED (the architecture's OWN answer, 2026-08-04):** NOT "monomorphize by
hand" or "extend closconv." The oracle already solves this: `lower.py:446` runs
**`specialize.specialize_singletons(sig)`** — a pass that monomorphizes a
singleton record-of-functions dictionary (the Mach/x64 vtable) at compile time
*without touching the source abstraction* (docstring: "the pass, not the
programmer, removes the seam"; P4 intact — Mach stays retargetable, mach-listing
stays a conforming second instance). **The chirality path never ported it.** THE FIX =
port `specialize_singletons` to chirality + wire into `compile-front` BEFORE
`closconv-sig` (lower.py's order). Algorithm (specialize.py, ~112 LOC):
  1. `_find_singletons`: data with ≥1 fn field, built exactly once (one global
     `(Con D ctor fields)`, only one inline Con D). → (gname,cname,fbodies,ftypes).
  2. lift each field body to a fresh global `gname$i` (typed from field type) —
     UNLESS body is `(Global g)` (the 24 x-* ref fields): point projector at g.
  3. `_find_projectors`: globals `(Lam (Case (Var0) [(cname,binds,(Var k))]))`
     (the mach-X accessors) → field index.
  4. `_rw`: `(App (Global proj) m)` → `(Global gname$i)` across all bodies.
  5. `_q0_dom`: retype every dict-typed Pi param to q=0 → B1 erasure drops params.
  6. prune dead projectors + the singleton value.
Differential vs specialize.py. Keeps the modular-backend-as-data design (the
point of the architecture conversation): source keeps Mach, compiler removes seam.

**⚑ PORTED + WIRED (commit bea663f, 663 green).** `lib/specialize-singleton.chiral`
runs before `closconv-sig` in compile-front. Verified: whole compiler still
lowers; synthetic singleton dicts (lambda/global-ref fields, multi-field
non-first projection, threaded) compile+run→exit 42; on the real 464k blob it
DETECTS Mach + builds a complete correct rewrite map (11 lifted, all 35
projectors: mach-ret→x64$7, mach-tca→x-tca, mach-clb→x64-clobbers).
**REMAINING last-mile bug:** emit-code STILL doesn't peel. Post-pass, emit-code's
body has NO mach-* refs (rewrite fired) AND NO x64$ refs — so the rewritten
emit-code still won't lower, cause not yet isolated. Candidates: the q0-retyped
Mach param; or the lifted lambda-field globals (x64$i) reintroduce a higher-order
form. NEXT DEBUG: print emit-code's full post-pass body (scratchpad diag6 pattern)
+ trace peel-def/term->ncore on it to find the exact non-lowering node. The
detection + map are proven correct, so the bug is in rewrite-application or a
downstream interaction, NOT detection.

After emit-code peels there may be further gaps; then the Stage1==Stage2 byte
compare, then B (delete seed), then C (tests off python). Honest: the fixpoint is
NOT one fix away — this cleared one blocker and precisely scoped the next.

---

## THE (now-CLEARED) blocker between here and a first fixpoint (A4)

**The chirality-authored back/emit pipeline (`lib/compile-back.chiral` / `lib/*emit*`)
does NOT lower effectful (`=>`) defs.** The E70 gate + crossing handling that the
Python `chirality/lower.py:lower_all` has (open the `=>` gate when every reached
crossing is E51-bound; drop q=0 args; the row-escape check) was never ported to
the chirality-side compile pipeline. So any def with a `=>` type — or any def that
*calls* one — fails to emit.

### Reproduce it (30 seconds)
```
cd scaffold && python3 -c "
import sys; sys.path.insert(0,'tests')
from chirality.surface import Elab; from chirality.runtime import RT
from test_compile_run_chirality import _call
el=Elab()
for f in ['sys-linkage','compile-front','compile-back','compile-emit','compile-all']: el.load_file('lib/'+f+'.chiral')
src='(data Unit () (unit))\n(extern put (=> Str Unit))\n(def hlp (=> I64 I64) (lam (n) (do (put \"x\") n)))\n(def main (-> I64 I64) (lam (n) (hlp 7)))'
print(_call(RT(el.sig),'compile-all',src,'main'))"
# -> ('ca-err', ('no emitted label for entry main',))   (main is PURE; it dies
#    because its effectful callee hlp never lowers in the chirality pipeline)
```
The same program compiles FINE through the Python `lower_all` (see
`tests/test_effectful_lowering.py::test_effectful_def_lowers_to_prim_crossing`),
so this is purely a gap in the CHIRALITY port of the back/emit path.

### Where to fix it
- `lib/compile-front.chiral:peel-def` peels a def iff its domains + cod + body all
  lower (`term->ntalty`, `term->ncore`). Check whether it (a) handles the `=>`
  effect SEAT on the Pi and (b) `term->ncore` handles a body that *calls a
  crossing* (`put`/`read`/`halt`). One of these silently returns `none`.
- Then `lib/compile-back.chiral:back-program` (compiles NDef→NFn) and the emit path
  need the equivalent of `lower.py`'s E70 gate (lines ~449-464: open `=>` if all
  reached crossings are bound) + q=0 erasure at crossing call sites (already ported
  for defs; a bound crossing like `read` also needs it — see the Python side,
  `lower.py` Prim branch, which I fixed there in commit "erase q=0 args for a
  crossing").
- Oracle to diff against: `chirality/lower.py:lower_all` (the whole effectful path) and
  `chirality/native.py` (crossing_sigs / how `prim <crossing>` routes to the wrapper).
- The 4 bound crossings today are `put/print/trace/halt` + the new `read`
  (`lib/sys-linkage.chiral:sys-bindings`). `halt` is the one the *compiler itself*
  reaches (`resolve-label`/`check-len` call `(halt …)`), so even without the I/O
  entry, self-compile needs effectful lowering in the chirality back.

Once effectful defs emit, `compile-main` (the entry) emits, and A4 is:

## A4 — the fixpoint, once the blocker is cleared
1. **Stage 1** (interpreted): compile the whole compiler source with `compile-all`,
   entry `"compile-main"` → `B1` (a native compiler ELF). The flattening + run
   harness is already written — `scratchpad/stage1.py` (copy it in):
   - it resolves the `(import …)` graph, concatenates modules dependency-ordered +
     dedup'd into a 447k-char blob (imports are no-ops in the front now), and runs
     `compile-all(blob, "compile-main")` on a 1 GB-stack thread with
     `sys.setrecursionlimit(2_000_000)` (the interpreter recurses deep on the big
     source — a CPython limit, not a chirality bug).
   - **Stage 1 already runs the FULL front→back→emit pipeline in ~235s and reaches
     `emit-elf`** — it fails ONLY at "no emitted label for entry compile-main"
     (the blocker above). So A4 is genuinely one subsystem away.
2. Write `B1` to a file, `chmod +x`.
3. **Stage 2**: run `B1` with the blob on stdin → its stdout is `B2` (an ELF).
4. **Check `fixpoint=? B1 B2`** (byte-identical) — `lib/ddc.chiral` has
   `fixpoint=?`/`bytes=?` ready. That's the keystone: zero CPython in the compile.

---

## What is DONE this session (all committed, do not redo)

The two HARD blockers are cleared:
- **The whole compiler lowers to native** — `lower_all` on the co-loaded compiler:
  `compile-front`/`back-program`/`emit-elf` all reach 0 unlowered. Got there via:
  poly-13 fix (closconv family-codomain keying), a closconv call-head fix, the
  **`Op` closed-sum refactor** (killed the stringly prim op + its defensive `halt`,
  making `op-bytes`/`emit-instr` PURE), a **fn_sig pre-pass** in `lower_all`
  (order-independent direct calls), crossing q=0 erasure, closconv case-arm binder
  types, and nested-case→`and`/`or` rewrites.
- **The front SELF-PARSES the whole compiler source** — `compile-front <447k src>
  "compile-all"` → `fr-ok`. Got there via: `(import)` as a no-op over a flattened
  blob (A1b); a **data-group loader** for mutually-recursive data
  (`lib/loader.chiral:load-data-group`, `lib/parse.chiral:load-source` now processes
  porttypes → data-group → rest); **indexed porttypes** (`(porttype Pool (n I64))`
  = empty data + linear, `sig-add-linear-data`).
- **One-Sig `compile-all : Str → ELF`** (`lib/compile-all.chiral`) is byte-identical
  to the old 3-RT shuttle and lowers to native. Plus `read-fd-all` + `compile-main`
  (the I/O entry) + the `read` port (bound to `nb-sys-read`) — all lower.

Key files touched: `chirality/closconv.py`, `chirality/lower.py`, `chirality/native.py`,
`chirality/impl_ports.py`, `lib/{prelude,tal-ir,erased-nf,tal-erase,mach-x64,mach,
emit-core,mach-listing,parse,loader,ports,sys-linkage,compile-all,kernel}.chiral`,
`lib/{bytes-tal,sys-tal}.chiral`. See `git log` since `647b467`.

---

## After A4 (the rest of the checklist — big but mechanical)

- **B** — delete `scaffold/chirality/*.py` (23 files, 8028 LOC); bootstrap from a
  committed native binary / self-seed. Contingent on A4.
- **C** — rewrite the 67-file / 13205-LOC test harness off Python (inventory →
  chirality test runner → port native+pure tests → replace differential-vs-Python
  with DDC → `git ls-files '*.py'` empty). The largest slice.

## Two live conventions (don't relitigate)
- **`Op` closed sum, not Str** for the tal prim op — a defensive `halt` masquerading
  as total was the whole reason `op-bytes` was effectful; the closed sum removed it.
  The nested-`case`-as-scrutinee → `and`/`or` rewrite recurs (case scrutinizing a
  case lowers to WORD not Data Bool → "case on non-data"); watch for it.
- The flattened-blob self-compile input relies on `(import)` being a NO-OP + a
  dependency-ordered dedup'd blob; a mis-ordered blob fails loudly on the first
  unresolved name (safe).

---

## ⚑ SESSION UPDATE 2026-08-04 (late) — THE REAL fixpoint blocker fixed; next = x64 stack args

The specialize-singleton investigation surfaced the ACTUAL blocker (not the Mach
vtable): **the chirality loader never stored a forward-declared def's body.**
`load-declare` installed a placeholder `(t-type 0)`; `load-finish` CHECKED the
real body but returned the Sig unchanged. So every forward-declared / mutually-
recursive def (emit-code + the whole emit group, and more) had a `t-type` body —
fine for type-checking (globals stay stuck neutrals), FATAL for lowering
(peel-def got `t-type`). **FIXED** (commit `<loader>`): `sig-set-global-body`
stores the checked body in `load-finish`. Verified: a forward-declared def now
lowers+runs+exits 42 (was "no emitted label"); 663 green.

With that fixed, **Stage 1 now RUNS the full emission** of the compiler (front +
back + emit all execute) and stops on the NEXT bounded blocker:
**`emit(x64): call/def with >6 args` — the x64 backend has no SysV stack passing
for the 7th+ argument.** Reduced my own offenders (sp-finish, lift-lifted); the
remaining ones are in `lib/lower.chiral`: `outline`(9), `emit-call`/`expr-con`/
`expr-case`/`build-outline`/`tail-case`(8). These are trusted-core, so the fix is
**implement SysV >6-arg passing in `lib/mach-x64.chiral`** (the `stp`/`lda` fields
currently `halt`):
  - INCOMING (`x-store-arg` for i>5): the 7th+ arg is at `[rbp + 16 + 8*(i-6)]`
    (after push rbp) — load it, store to the local slot. (~easy, ~10 lines.)
  - OUTGOING (`x-load-arg`/the call seq for i>5): reserve stack below rsp,
    16-align, place args 6+ there, place 0-5 in registers, CALL, restore rsp.
    (the harder half — touches `emit-args`/`mach-cal` in emit-core.)
Differential vs native.py (which handles the full SysV convention). After this,
compile-main should emit → B1 → Stage2 → the byte-compare fixpoint.

**Net:** the fixpoint's long-standing "emit-code won't peel" mystery is SOLVED
(a loader bug, now fixed); what remains before the first self-compiled ELF is one
known backend feature (x64 stack args). The specialize-singleton pass stays (it's
correct + the architecturally-right monomorphizer; it drops the Mach param so the
emit chain is ≤6 args after erasure).
