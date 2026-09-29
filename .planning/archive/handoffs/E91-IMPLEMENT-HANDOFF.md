# E91 growing allocator — implementation handoff (post-validation)

> **STATUS: E91 COMPLETE (2026-08-10, independently verified).** The growing
> allocator genuinely grows — value + byte cells past the 256 KiB committed
> prefix grow across ~9 doublings, the self-compile grows its own arena, fixpoint
> = **790904B**, suite 703, public synced. Commits: Step A `237c1e5`, Step E
> `1a6be67`, Steps B+C `70cca90`, Step F `7650cf7`. Implementation record lives
> in `.planning/specs/E91-growing-allocator-SPEC.md` §7 (status: implemented).
> This file is kept for provenance (the six-theory validation + the blueprint).
>
> **CORRECTION to this handoff's own summit line.** The state block below said
> "`nb-arena-grow`/`nb-arena-commit` ARE built (real mprotect doubling)" as if
> only WIRING remained. That was an untested summit: the primitives were built
> but MIS-MARSHALLED — they read/wrote the arena cells through `nb-get-u64`/
> `nb-put-u64`, which lower to `ti-bget`/`ti-bput` at the boxed-payload offset
> `+8`, while the arena cells are RAW 8-byte slots. The actual fix was the
> **`-8` offset** on those cell accesses (skip the phantom header). Until that
> landed, growth silently touched the wrong 8 bytes — so "built and correct" was
> false; it was "built and wrong-by-8-bytes."

Date: 2026-08-10. Supersedes the pre-validation handoff. Authority for the
implementation contract: `.planning/specs/E91-growing-allocator-SPEC.md`
(status: implemented). This file is the durable record of the six-theory
validation that the SPEC cites, plus the exact mechanical blueprint of the work.

## The finding (verified: research → repro → adversarial audit → mechanical-fit)

**E91's growing allocator has NEVER grown — a false summit across all three
prior attempts.**

- `x-galo`/`x-gbnw` (mach-x64.chiral:509/659) emit `x-trap` (`76 02 0f 0b`,
  `jbe +2; ud2`) — byte-identical to the fixed allocator. No grow call, no retry.
- The `"arena-grow"` label in `x-fin` is DEAD (no `e-call` reaches it) and was
  mis-marshalled for a signature that never existed.
- The self-host fixpoint (762106B) survives ONLY on a 16 GiB
  `PRIVATE|ANON|NORESERVE` demand-paged arena. Shrinking the emitted arena makes
  every ELF SIGILL (`ud2`) at `heapend` — proven at 256 KiB / 1 MiB.
- `nb-arena-grow`/`nb-arena-commit` (sys-tal.chiral:171/133) ARE built (real
  mprotect doubling) but unreachable.
- The "two-instance limitation" that drove the prior attempts was a
  MISDIAGNOSIS: not a B1 constructor bug, but the `specialize-singletons`
  singleton precondition. A single `Alloc` instance is required; both a
  Mach-field and a lambda-wrap `alloc-growing` lower and self-host (lambda
  fields are hoisted by `lift-lifted`), so **Mach-editing is NOT required**.
- The JIT floor (native.py) also can't grow (flat 1 MiB arena, `heapreserve`
  never initialized) — but that's a retiring Python oracle, not the binary.
  chirality has NO in-process JIT (E34 chose AOT); it AOTs to ELF and `run-elf`s.

## State (committed on main, this session)

- `294c9cb` — clean base: single-instance alloc-growing, provenance restored
  (committed source now builds the committed B1 762106B byte-identically);
  debris + broken heapbase edits dropped.
- `e80ef9c` — SPEC corrected (Decisions #2/#6/#7 + baseline).
- SPEC marked `audited` (spec-audit PASS; verified `nb-arena-grow` never
  returns <0 against sys-tal.chiral:117-192).
- `1a6be67` — Step E done: `16d6d1a` gate reverted to loud `count==1`
  (was a silent-miscompile hazard); rebuilt B1, fixpoints byte-identical,
  proving the lib has exactly one fn-bearing instance.

## Remaining work — the certified 4-edit set (mechanical-fit CERTIFIED possible)

Order: A → B → C together (growth needs all three), then D (optional), then F.
Keep `INIT_COMMIT` at 256 MiB through A (self-compile peak ≈0.1 GB fits, no
regression); verify growth by TEMPORARILY shrinking `INIT_COMMIT` to 256 KiB;
restore after. B1-only builds; re-fixpoint after every compiler-source change
(3-generation convergence when pregen tables shift); commit per verified unit.

### Step A — reserve-commit entry stub (chirality ⇄ native.py byte-identical)
Mirror `native.py._entry_stub` (the 214-byte v3 reference at native.py:760):
`mmap(0, RESERVE_BYTES, PROT_NONE, PRIVATE|ANON, -1, 0)` → test/jns →
`mprotect(base, INIT_COMMIT, PROT_RW)` → test/jns → init FOUR cells
`heapptr=base`, `heapbase=base`, `heapend=base+INIT_COMMIT`,
`heapreserve=base+RESERVE_BYTES` → `xor edi,edi; call entry; mov edi,eax;
exit_group(231)`; fail_tail writes "can't allocate arena\n" + exit_group(1).
- **`48 a3` moffs64 hazard:** `mov moffs64,rax` stores RAX only — build each sum
  in `rax` first (`mov rax,rdi; movabs rsi,K; add rax,rsi; 48 a3 &cell`).
- Rewrite `compile-emit.chiral` `entry-stub-v2` to this (hand-translate to bcat
  byte literals); add `reserve-bytes`/`init-commit` defs = native.py constants;
  bump `entry-stub-len` to match (214, +8 if heapbase added to both).
- `mach-x64.chiral` `x-fin`: add `a-label "heapbase"` + `(a-bytes (b8 0))` slot.
- `compile-emit.chiral` `assemble-elf`/`emit-elf`: currently `emit-elf` passes 4
  args to a (now-to-be) 5-arg `assemble-elf` and looks up only heapptr/heapend
  — thread `heapbase`+`heapreserve` offsets through both.
- Add the `heapbase` store to `native.py._entry_stub` too; unskip
  `test_entry_stub_matches_native_byte_for_byte`.

### Step B — grow-retry loop in x-galo/x-gbnw (inline rel8, Decision #6)
Replace `(a-bytes x-trap)` with, at the site (recommended Shape B, no per-site
labels — only the global `e-call "arena-grow"` is relocated):
```
(retry) a-rel 7 e-ldheap  "heapptr"     ; rax = *heapptr           (loop top)
        a-bytes (x-lea-bump sz)         ; rcx = rax + sz
        a-rel 7 e-cmpheap "heapend"     ; cmp rcx, *heapend
        a-bytes  76 07                  ; jbe +7  (fits -> skip call+jmp)
        a-rel 5 e-call "arena-grow"     ; miss -> grow
        a-bytes  EB E2                  ; jmp -30 -> retry
(commit) <stores> ; recompute bump ; a-rel 7 e-stheap "heapptr"
```
`jbe +7` skips the 5-byte call + 2-byte back-jmp. `jmp -30` = -(7+7+7+2+5+2)
measured from the jmp's end. `x-gbnw` substitutes the byte-cell size sequence
for `x-lea-bump`. VERIFY displacements programmatically (the E102 discipline).

### Step C — correct the "arena-grow" stub in x-fin (Decision #2)
Real callee: `nb-arena-grow(base=rdi, reserve_end=rsi, need=rdx,
heapend_cell=rcx) -> new_end(rax)`, NEVER returns <0 (fails via `exit_group`).
Stub body: save regs (8-push align); `need = rcx - *heapend` (`e-ldrsi
"heapend"` then `48 29 f2` sub rdx,rsi after moving rcx→rdx); `base←heapbase`
(`e-ldrdi`); `reserve_end←heapreserve` (`e-ldrsi`); `heapend_cell←&heapend`
(`e-learcx`); `a-rel 5 e-call "nb-arena-grow"`; restore; `ret`. DELETE the bogus
`stheap heapend` (nb-arena-commit publishes it via nb-put-u64). The encoders
`e-ldrdi/e-ldrsi/e-ldrdx/e-learcx` already exist (asm-reloc.chiral). Ensure the
`e-call "arena-grow"` in B and this label are consistent IN THIS TREE.

### Step D (optional) — lambda-wrap, revert Mach fields
`alloc.chiral` alloc-growing → `(lam (m dst tag fs) (x-galo dst tag fs))` /
`(lam (m dst len) (x-gbnw dst len))`; revert `mach.chiral` galo/gbnw fields +
mach-x64 table rows. Byte-identity expected. Skip if churn not worth it.

### Step F — cleanup + docs
Delete dead `scaffold/lib/alloc-growing.chiral`. Re-work the example
(`worked-example`) to match the validated SPEC (it still claims two-disciplines
/ returns-<0 / check-first-not-done). Then `bin/make-public.sh`.

## Conformance gate (SPEC §5)
1. Fixpoint reconverges after each compiler-source change.
2. Growth: `INIT_COMMIT` shrunk to 256 KiB → a program allocating past it GROWS
   and completes (correct result), NOT ud2/SIGILL.
3. Clean exhaustion past RESERVE_BYTES = nb-arena-fail exit, never SIGSEGV/ud2.
4. Full py suite green; `test_entry_stub_matches_native_byte_for_byte` unskipped
   and passing.
5. make-public sync clean.

## Standing rules (do not re-derive)
- B1 compiles everything; python compiles nothing. Fixpoint after compiler-
  source changes only.
- Before believing any "B1 limitation": build the minimal repro (this saga was
  7 phantom B1 diagnoses).
- Paren slips that stay globally balanced are the pathogen — check def arity
  with the chirality sexp reader (read-all-str) / bin/paren-audit.py, not by eye.
- One heavy build at a time (CPU-only, ~4GB RAM, ulimit -s unlimited).

## Off-path findings recorded (NOT E91)
- Scoped in-process eval for population-editing (reflective floor, edge 5) is
  unspecified but likely required by the residential no-seam invariant — kernel
  hot-swap JIT stays forbidden (unsound). Its own catalog element.
- Runtime modularity = profiles × staging × mesh, built-but-embryonic; the grain
  is the node, not intra-process moduleset dispatch. Its own arc.
