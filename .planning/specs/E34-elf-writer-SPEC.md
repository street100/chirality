---
element: E34
slug: elf-writer
title: ELF / executable format (ahead-of-time output instead of JIT-in-mmap)
kind: REPLACE-CRUTCH
example: examples/E34-elf-writer.md
status: audited
updated: 2026-08-02
---

# E34 SPEC — ELF / executable format (ahead-of-time output instead of JIT-in-mmap)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `lib/elf.chiral` exists — a pure `elf-file : Bytes → Bytes`
  that wraps an emitted code batch in a minimal static **ET_EXEC** ELF64 header
  (64-byte Ehdr + one 56-byte RX PT_LOAD + code), readelf-accepted and
  byte-differential against `refs/ref-elf.md`; the emit path can resolve the
  same code batch's relocations at the ELF load address `0x400078` instead of a
  JIT address; a minimal hand-tal entry stub enters the batch and exits through
  the registered `nb-sys-exit-group` crossing; and a `chirality emit <path>` CLI
  produces a file that **runs and exits with the batch's computed result**.
- **Non-goals:** the argv/envp-capturing entry stub (this stub captures nothing
  from the psABI stack — §6); a second RW `PT_LOAD` for the arena/bss (§6);
  fully-chirality-side *named-file* creation (open/chmod crossings unregistered —
  Decision #4, §6); folding the header via `specialize`/pregen (§6);
  refinement-typed header fields (§6). The JIT/mmap loader is **not** retired —
  ELF is an additional output floor; the two are kept as differential peers.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** two rows.
  - *"ELF / AOT executable format" — BUILD / L / E34:* **Not built.** Current
    path is W^X JIT-in-mmap; SPEC-class (conform to ELF gABI); explicitly
    *orthogonal to the built JIT loader* — so this adds an output, it does not
    rip one out.
  - *"W^X loader" — REFACTOR / E20:* memory is **fully chirality-side since
    2026-07-29** (code buffer + arena via `nb-sys-mmap`, sealed via
    `nb-sys-mprotect`, all on the reference tal floor). The **sole** Python
    remainder is the `CFUNCTYPE` entry trampoline, which "moves with a real
    entry point (E23/E34)." E34 is that real entry point — but retiring the
    trampoline for the *JIT* path is E23's job; E34 gives the *ELF* path an
    entry that needs no trampoline at all (the kernel enters `e_entry`).
- **Live code this composes with (do NOT respec):**
  - `lib/asm-reloc.chiral` — the two-pass Asm discipline is already built:
    `assemble : (List Asm) → (Pair Bytes (List (Pair Str I64)))`,
    `materialize`/`place`/`resolve` place bytes and resolve labels against a
    base. E34 is *one more layout pass over this stream*; it reuses the pass,
    only changing the base the code resolves against.
  - Bytes floor (`lib/prelude.chiral:52-55`): `pack-u32`, `pack-u16` are externs
    (`I64 → Bytes`, little-endian). **There is no `pack-u64`** — the example's
    `pack-u64` = two `pack-u32` halves split by Euclidean `div`/`mod 2^32`
    (sound: all header values are nonnegative). `bcat` composes.
  - `chirality/tal.py` `SYSCALL_TABLE` — the registered crossings. `nb-sys-write`
    (1), `nb-sys-close` (3), `nb-sys-exit-group` (231) exist; **`exit`/60,
    `open`/`openat`, `chmod`/`fchmod` are NOT registered** (load-bearing — see
    Decisions #2, #4).
  - `chirality/native.py` `NativeBackend.compile()` — produces the code batch +
    label offsets today, then maps/seals/enters it. E34 taps the *bytes it
    already produces* before the map/seal/enter half.
  - `refs/ref-elf.md` + `refs/gen-elf.py` — every ABI constant is script-derived
    from `/usr/include/elf.h` + struct math + `readelf /bin/true`; the golden
    header test regenerates from here, never hand-copied.
- **True delta:** (a) `lib/elf.chiral` — `pack-u64` helper, the layout constants,
  `e-ident`/`elf-ehdr`/`elf-phdr`/`elf-file` (the example §5 is near-verbatim
  buildable); (b) a base-selectable code assembly so the batch resolves at
  `0x400078`; (c) a minimal hand-tal entry stub; (d) the `chirality emit` CLI +
  write. asm-reloc, the bytes floor, and the emitter are all reused unchanged.

## 3. Decisions

Every open question from the example §6, dispositioned.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Entry stub: where does it live, and does it capture the psABI stack (argc/argv/envp at `rsp`)? | **RESOLVED (this spec's stub) + DEFERRED (the capturing stub)** | The stub is **hand-tal**, a `sys-tal`/`bytes-tal` sibling — the sys face is already hand-authored tal, and the entry has no caller to `ret` to (psABI). This spec's stub is *minimal*: call the batch entry, move the i64 result to `edi`, issue the exit crossing — **it captures nothing**. The argv/envp-capturing prologue that feeds `env-get`/`main` is a **named follow-on** (§6), gated with [[E32]] (env = entry-stack data) and [[E80]] (cap-to-`main` delivery). |
| 2 | Exit crossing: the example cites "exit(2), syscall 60". | **RESOLVED** | The **registered** crossing is `nb-sys-exit-group` = **231** (`tal.py` `SYSCALL_TABLE`); `exit`/60 is not registered and adding it would need a `SYSCALL_TABLE` row + `nb-sys-*` def for no gain (exit_group is correct for a single-thread static exe and is what glibc issues). The stub exits through `nb-sys-exit-group`; the example's "60" is a rationale-text imprecision, not a contract. |
| 3 | When does the arena move into a second RW `PT_LOAD` (with heapptr/heapend init)? | **DEFERRED → [[E21-arena]]** | The minimal file is one RX segment (`p_flags` 5). The RW segment (`p_flags` 6, `e_phnum`→2, W^X-disjoint, `p_memsz > p_filesz` for bss) lands when the arena moves off the Python-pointed mapping — E21's future-segment residue. Out of scope here. |
| 4 | Named on-disk file creation (the `chirality emit <path>` write). | **RESOLVED (Python-hosted now) + DEFERRED (fully chirality-side) → [[E51-sys-linkage]] lane-A** | `nb-sys-write`/`close` are registered but **`open`/`openat` and `fchmod` are not** — chirality cannot create+chmod a *named* file yet (it can make an anonymous `memfd`, 319). So `chirality emit` produces the file **bytes** on the chirality side (pure `elf-file`) and the Python CLI does the `open`/`write`/`chmod +x` — the *same* stepwise-retirement posture E20 took (bytes are chirality's, the host syscall wrapper is the shrinking crutch). Fully-chirality-side named write = E51 lane-A adding open/openat+fchmod crossings. |
| 5 | Is the ELF writer the first `specialize`/pregen customer (fold the ~120 mostly-constant header at build time)? | **DEFERRED → [[E17-optimizer]] / TRAIT-OPTS T6** | The header is 120 bytes of constants + arithmetic over `blen code`; an appealing pregen target, but a pure optimization with no bearing on correctness. Rides the staging-modality policy (Fork C), not this spec. |

No NEEDS-AUTHOR blockers: every open question is either decidable-from-the-code
(resolved with a citation) or a clean deferral to a named home. Frontmatter
stays `status: draft`.

## 4. Change plan (ordered, commit-sized)

### Step 1 — `lib/elf.chiral`: the pure layout pass
- **Target:** `lib/elf.chiral` (NEW) — `pack-u64`, `ehsize`/`phsize`/`code-off`/
  `load-base`, `e-ident`, `elf-ehdr`, `elf-phdr`, `elf-file`.
- **Change:** transcribe the example §5 near-verbatim (it is already fleshed and
  load-checked in the example audit). `elf-file : Bytes → Bytes` =
  `bcat (elf-ehdr (blen code)) (bcat (elf-phdr (blen code)) code)`. All numeric
  constants carry their `refs/ref-elf.md` row. Pure `->`; no crossing here.
- **Size:** ~M.

### Step 2 — base-selectable code assembly (`0x400078`)
- **Target:** the emit driver in `chirality/native.py` `compile()` (and, if the
  base is threaded through chirality, `lib/asm-reloc.chiral` `materialize`/`place`
  already take a base arg — confirm the call site passes `load-base+code-off`).
- **Change:** add an ELF-output path that assembles the batch with the label
  base fixed at `0x400078` (= `load-base + code-off`) instead of the runtime
  mmap address, then hands the resolved code bytes to `elf-file`. The JIT path
  is untouched; this is an *added* branch.
- **Size:** ~S.

### Step 3 — minimal hand-tal entry stub
- **Target:** `lib/elf-entry-tal.chiral` (NEW, a `sys-tal` sibling) or a stanza
  in `lib/sys-tal.chiral`.
- **Change:** the ELF `e_entry` prologue: `call <batch-entry>`; `mov edi, eax`
  (i64 result → exit status, low 8 bits per psABI); `nb-sys-exit-group`. No
  frame, no `ret`. Placed first in the code batch so `e_entry = 0x400078` hits
  it. Hand-tal (never lowered), checked by `tal.check_fn` like the rest of the
  sys library.
- **Size:** ~S.

### Step 4 — `chirality emit <path>` CLI + write
- **Target:** `chirality/cli.py` (or `__main__.py`) — a new `emit` subcommand.
- **Change:** compile the batch, assemble at the ELF base (Step 2), run
  `elf-file` (Step 1) with the entry stub first (Step 3), write the resulting
  bytes to `<path>` and set the exec bit. Per Decision #4 the `open`/`write`/
  `chmod` is Python-hosted (the shrinking crutch); the *bytes* are the chirality
  artifact. Print the path.
- **Size:** ~S.

## 5. Conformance gate

- **Golden behavior:** the emitted file is a well-formed minimal static
  ET_EXEC that `readelf -h`/`-l` accepts field-for-field against the ref
  tables, and that **runs and exits with the batch's computed i64 (low 8
  bits)**; the pure header bytes are reproducible and base-exact.
- **Tests to add (`scaffold/tests/test_elf.py`, NEW):**
  1. **Golden header (pure, no floor):** `elf-file(code)` for a known
     `blen code` → assert the 120 header bytes equal the `refs/gen-elf.py`-
     derived expected header (Ehdr + Phdr field-for-field). Catches every
     constant/offset/`pack-u64`-split regression without executing anything.
  2. **readelf structural:** write the file, run `readelf -h -l`, assert
     `ET_EXEC`, `EM_X86_64`, `e_entry == 0x400078`, one `LOAD` segment with
     flags `R E`, `p_align 0x1000`, `p_filesz == p_memsz == 120 + len(code)`.
  3. **End-to-end exec:** emit a batch whose entry returns `42`, `execve` the
     file in a subprocess, assert exit code `42` (exercises Steps 2–4 + the
     entry stub + exit crossing).
  4. **Loader floor-agreement (differential):** the same compiled batch run via
     the mmap/JIT path (`NativeBackend`) and via the ELF file produce identical
     observable results — the two loaders as two floors of one program.
- **Green line:** 422 → **≥ 426** (the four tests above; baseline current as of
  2026-08-02 — E70 core + cluster seam + D-1 landed since the spec was drafted);
  `ledger-lint` clean.
- **Done when:** `chirality emit /tmp/a.out` on a return-42 batch yields a file
  `readelf` accepts and that `./a.out; echo $?` reports as `42`.

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - *argv/envp-capturing entry stub* — the psABI-stack-reading prologue that
    feeds `env-get`/`main`; hand-tal, lands with [[E32]] (env = entry-stack
    data) + [[E80]] (cap-to-`main` delivery). This spec's stub captures nothing.
  - *Second RW `PT_LOAD` (arena/bss)* — Decision #3, → [[E21-arena]].
  - *Fully-chirality-side named-file write (open/openat + fchmod crossings)* —
    Decision #4, → [[E51-sys-linkage]] lane-A. Until then Python hosts the
    `open`/`write`/`chmod`.
  - *Header pregen/fold* — Decision #5, → [[E17-optimizer]] / staging modality.
  - *Refinement-typed header fields* (`(refine I64 (= 56))` on `e_phentsize`) —
    the example's "once worth the ceremony"; edge-3/E9-arith-gated like E22/E25's
    dependent faces, not owed here.
- **Follow-on elements:** [[E23]] (retires the *JIT* trampoline — the RX-map
  entry path, distinct from E34's kernel-entered path), [[E20-loader]] (the
  crutch whose residue shrinks to `execve`), [[E72-re-bootstrap]] (the ELF file
  is the tiny ownable ship-form this feeds).
- **Links:** [[E51-sys-linkage]], [[E32]], [[E21-arena]], [[E17-optimizer]],
  `lib/asm-reloc.chiral` (the stream this is one more pass over),
  `refs/ref-elf.md` + `refs/gen-elf.py` (the script-derived ABI bank).
