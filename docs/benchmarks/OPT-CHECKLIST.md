# Emitter optimization checklist (benchmark-driven)

Survey of where the measured -O2 gap actually lives in the code, written
against `RESULTS-2026-08-01.md`. Each item names the mechanism, the exact
code seat, the estimated change size, and which kernel gap it attacks.
Ordered by payoff-per-line; `[x]` items are landed and measured (RESULTS
third + fourth runs: after items 1–3 bytesum native/-O0 1.43–1.47× → 1.11×;
after the Mach face items 4+5+7 all three kernels beat gcc -O0 outright
(TCO does what -O0 won't) and the -O2 gap fell to 1.8×–12× from 4.4×–57×).
Items 6+8 landed 2026-08-01 EOD: emitted code is
disassembly-verified free of setcc and of adjacent same-slot store→load
pairs, but wall-clock on these LATENCY-BOUND kernels is flat (run 6 —
the removed work was OOO-shadow-hidden; honest negative result). The
remaining named lever on this list's kernels: magic-multiply constant
division + real regalloc (both E17-lane). Separate from the E16/E17 example→spec lane — items that
grow past "minor" belong there, and the tal→tal items must eventually land
as ports of `optimize.py`, not as Python-only divergence.

The standing safety property that makes all of this cheap to attempt: every
tal→tal transform is preserve-checked (`optimize.py` discipline — output
re-runs `tal.check_fn`), and the native path is differentially tested
against the reference floor. A wrong optimization is a floor alarm or a
differential failure, not a shipped miscompile.

## Minor (small diffs, big measured effect)

- [x] **1. Inline the byte ops — stop calling `nb-bget` per byte.**
  `native.py` `PRIM2LIB` routes the `bget`/`blen`/`bput` prims to *calls*
  into `lib/bytes-tal.chiral` wrappers, but `nb-bget` is literally one
  instruction plus return (`bytes-tal.chiral:29`: `(ti-bget 2 0 1)(t-ret 2)`),
  and the inline machine op already exists and is emitted for hand-tal
  (`mach-x64.chiral` `x-bgt`: load/load/movzx/store, no call). Map
  `prim bget → ti-bget` in `_conv_code` (`native.py:192-200`); `blen` /
  `str-len` likewise (`nb-blen` is the same one-instruction shape,
  `bytes-tal.chiral:26`). NOT `bput`: no upper prim routes there —
  `ti-bput` is hand-tal-only initialization writes (`tal-ir.chiral:28`). Attacks: **bytesum's dominant cost** — one full
  call+frame per byte becomes four inline instructions. This is most of
  the 56–72× bytesum gap that isn't register allocation.

- [x] **2. Wire `optimize.py` into the native path.** `fold`+`dead` exist,
  are preserve-checked and tested, and `NativeBackend.compile`
  (`native.py:415`) never calls them (`RESULTS` §6 notes this). One call
  per function before `tal_to_tfn`. Also lets the erased-binder
  placeholder `const dst,0` instructions (`lower.py:157`) drop when unused.
  Attacks: little on these three kernels (no foldable constants in the hot
  loops) — but it's ~3 lines, and it makes every later tal→tal item
  automatically apply to the native path.

- [x] **3. Fold comparisons too.** `optimize.py` `_FOLDABLE` is
  `{+,-,*,/,%}` only; constant `=i/<i/<=i` don't fold, so a statically
  decidable guard keeps its cmp+setcc and its case. Add the three
  comparison ops emitting the known Bool constructor as a nullary `con`
  (ctor order verified: `true` first → tag 0, `prelude.chiral:8`), which
  feeds the existing static-branch-selection via `_fold_block`'s
  `('c', cname)` facts.

- [x] **4. Immediate operands.** Every `bin` loads both operands from
  slots (`mach-x64.chiral` `mach-bin`: `x-load-rax a; x-load-rcx b`), even
  when b was just a `const`. Teach emit-core to track "register r is the
  constant v" (it already walks the instruction list) and emit
  `add/sub/cmp rax, imm32` forms. Cuts one slot store + one slot load per
  constant operand. Attacks: arith and states, a slice of the 1.0–1.5×
  vs -O0 residue.

- [x] **5. Euclidean strength reduction, power-of-two only.** Because
  chirality `/` and `%` are *Euclidean* (settled, floor-agreed), `% 2^k` is
  exactly `and (2^k - 1)` and `/ 2^k` is exactly `sar k` — for **all**
  signed inputs, no correction sequence needed (truncated semantics would
  need one; Euclidean makes the cheap encoding the correct one). Verified
  empirically against `impl_pure.i64_div`/`i64_mod` (the floor-agreement
  arithmetic): 60 cases across k∈{0,1,3,10,62} including INT_MIN,
  INT_MIN+1, and negative dividends — all equal. Emit
  these in `op-bytes`/`mach-bin` when the divisor is a known power-of-two
  constant (needs item 4's const tracking). Replaces the ~20-instruction
  guarded cqo/idiv sequence. The *general* constant-divisor
  magic-multiply (what gcc does to arith's prime 1048573) is NOT minor —
  defer to the E17 lane.

## Medium (structural, the real -O2 gap; candidates for the E16/E17 specs)

- [x] **6. Fused compare-and-branch.** Today `(case (=i a b) ...)` costs:
  load a, load b, cmp, setcc+movzx, store bool to slot, reload slot,
  cmp tag-imm, jne — a store+reload round-trip of the bool and two
  compares where one cmp+jcc would do. Peephole at emit-core level: a
  `ti-prim` comparison whose dst is used *only* as the immediately
  following case scrutinee emits cmp + jcc directly. Attacks: **states**
  (branch-bound, 24–31× gap) and every guard in every loop.

- [x] **7. Tail-call elimination.** The shape is already explicit in the
  IR: `t-seq (ti-call dst f args) (t-ret dst)` → place args, tear down
  frame, `jmp` instead of `call`. New Mach op (mach-tailcall) + emit-core
  pattern match. Attacks: every loop (the kernels are all
  recursion-shaped): removes call+prologue+epilogue per iteration AND
  removes the stack-depth ceiling (`bench_sizes.py` sizes are currently
  chosen to stay under 8 MB stack — TCO deletes that constraint, a
  correctness win beyond speed). This is the single transform gcc -O2
  uses to turn the transcribed recursion back into loops.

- [x] **8. Poor-man's register allocation: rax residency tracking.**
  The memory-machine design (`mach-x64.chiral` header: every vreg in a
  stack slot, rax/rcx scratch) means every instruction ends
  `store rax→slot` and the next begins `load slot→rax` — usually the
  *same* slot (single-assignment chains). Track "rax currently holds
  vreg r" across adjacent instructions in emit-core and skip the
  reload (stores stay, so slots remain truthful for later reads).
  Not a full allocator — a one-value residency cache. Attacks: the
  1.0–1.5× vs -O0 band itself; this is the first step of the regalloc
  the RESULTS attribute the -O2 gap to. Full linear-scan allocation is
  E16-lane work, not this list.

## Not on this list (deliberately)

- **General magic-number division, jump tables, inlining across
  functions, loop-invariant motion** — real -O2 passes, not minor;
  they belong to the E16/E17 spec lane when it lands.
- **`specialize`/pregen auto-application** — exists
  (`optimize.py:264`), is a staging-policy question, not a peephole.
- **perf counters** — owed on bare metal (`RESULTS` reproduction
  section); measurement infra, not codegen. Rerun the benchmark after
  items 1+6+7 land: those three should close most of the bytesum and
  states gaps; the arith gap stays until general strength reduction.

## Sequencing note

Items 2→1→3 landed 2026-08-01 (the Python-side minor tier, measured:
bytesum native/-O0 1.43–1.47× → 1.11×).

**Re-decided later on 2026-08-01: the E16/E17 specs turned out to be
self-host PORTS of lower.py/optimize.py (zero machine-level speedup; the
Mach face is in neither change plan), so the face was built as scaffold
engineering under explicit user go — one interface extension (bini + tca),
then items 4+5+7 on top. Items 6+8 remain open. Superseded reasoning kept
below for the record.** Item 4 looked minor but its real seat is not: `mach-bin`
receives *slots*, so constant knowledge cannot stay inside the x64 Mach —
it must cross the Mach contract (`mach.chiral`: a 22-field record with 23
positional accessors, plus `mach-x64`, `mach-listing`, and `emit-core`
signature threading). Items 5/6/7/8 each need the same surgery (new ops:
bini, fused cjcc, tailcall, plus emit-state). The right engineering unit
is therefore ONE **optimization face** added to Mach — the established
extension pattern (milestone 2 heap face, 3 byte face, 4 sys face) — done
once, in the E16/E17 implementation whose audited specs own these files.
Doing item 4 alone would rewrite the accessor file twice and pre-empt the
lane. Every future item still lands with: differential test vs the
reference floor + preserve-check + a benchmark rerun in a dated RESULTS
file.
