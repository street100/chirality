---
element: E34
slug: elf-writer
title: ELF / executable format (ahead-of-time output instead of JIT-in-mmap)
kind: REPLACE-CRUTCH
reference_class: SPEC
ours_source: scaffold/chirality/native.py (the loader crutch), scaffold/lib/asm-reloc.chiral (the Asm stream this extends)
status: drafted
updated: 2026-07-22
---

# E34 — ELF / executable format (ahead-of-time output instead of JIT-in-mmap)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.
> Every concrete ABI number below is cited from `refs/ref-elf.md`, which is
> script-derived from local sources (`refs/gen-elf.py`) — regenerable, never
> hand-copied.

## 1. Scope

- **Element:** E34, emitting a standalone ELF64 executable from the Asm stream
  the chirality emitter already produces — ahead-of-time output, so a compiled
  program is a *file the kernel loads*, not bytes a Python process maps.
- **Kind:** REPLACE-CRUTCH. The crutch is the JIT-in-mmap loader:
  `native.py` maps RW, writes the emitted bytes, `mprotect`s R+X, and enters
  through a ctypes `CFUNCTYPE` trampoline (E20/E23). Every native run today
  has a Python process wrapped around it.
- **Why chirality needs its own:** "a binary Python never loads" is a named rung of
  actual self-hosting (SELF-HOST-PLAN milestone 5). With ELF output, the
  loader becomes the Linux kernel itself — the one component already in every
  trust story — and E20's residue shrinks to `execve`. It is also the E72
  ship-form: the tiny ownable artifact is a file, not a hosted session.

## 2. Research

- **Reference class:** SPEC — ELF64 + System V gABI / x86-64 psABI, taken from
  **local ground truth** per the refs discipline: `/usr/include/elf.h`
  (constants), struct offset math (field layout), `readelf` on `/bin/true`
  (cross-check). All in [refs/ref-elf.md](refs/ref-elf.md).
- **Key findings (each row cited in the ref):**
  1. The minimal static executable is **three concatenated byte runs**:
     Ehdr (64 bytes) + one Phdr (56 bytes) + code. Code file offset = 120
     (0x78); no sections, no interpreter, no dynamic linking
     (`e_shoff`/`e_shnum` = 0 is legal for an executable — sections are a
     linker/debugger courtesy, not a loader need).
  2. The load equation: one `PT_LOAD` (type 1) with `p_offset` 0 maps the whole
     file at `p_vaddr` 0x400000 (conventional base), `p_align` 0x1000;
     `e_entry = p_vaddr + 0x78`. `p_filesz = p_memsz` (no bss yet).
  3. The constants: ET_EXEC 2, EM_X86_64 0x3e, ELFCLASS64 2, ELFDATA2LSB 1,
     EV_CURRENT 1, PF_X 1 / PF_W 2 / PF_R 4 (so the one RX segment's
     `p_flags` = 5).
  4. Entry protocol (psABI): at `e_entry`, `rsp` points at
     `[argc][argv…][NULL][envp…][NULL][auxv]` — **argv/envp are stack data,
     not a syscall** (the E32 tie: `env-get` post-ELF reads entry-stack data
     the runtime captured, it does not cross). There is no caller to `ret` to:
     the program ends by `exit(2)` — syscall 60 — through the sys face.

## 3. Conventional (other-language) approach

How this is done outside chirality — the **pre-refactor** Python loader (since the
2026-07-29 E20 mechanism refactor the map and seal go through the chirality
`nb-sys-mmap`/`nb-sys-mprotect` crossings and only the `CFUNCTYPE` trampoline
stays Python; kept as the foil because the *shape* — a hosted session as the
program's whole existence — is exactly what remains true and what ELF retires):

```python
# pre-refactor native.py (abridged): the OS never sees a program, only a process
buf = mmap.mmap(-1, size, prot=PROT_READ | PROT_WRITE)
buf.write(code_bytes)                       # W...
mprotect(addr, size, PROT_READ | PROT_EXEC) # ...^X flip, then
entry = ctypes.CFUNCTYPE(c_int64)(addr)     # a ctypes trampoline ENTERS it
entry()                                      # Python is the loader + the OS face
```

- **Assumptions it bakes in:** a live CPython process is the loader, the
  entry trampoline, and the lifetime owner — the "executable" exists only
  inside a hosted session; the mapping's W^X discipline is Python code
  (trusted, unchecked); nothing on disk is the program (no artifact to hash,
  attest, or re-run); and the FFI boundary (ctypes) silently defines the
  entry ABI instead of the psABI defining it.

## 4. The chirality idea

- **Chirality features in play:** pure byte construction over `Bytes` (the
  `pack-u32`/`bcat` family from the bytes floor), the `asm-reloc.chiral`
  two-pass Asm discipline (bytes + labels + relocations already exist), the
  A/B/C cut (writing the file is category-A pure computation; only the final
  `write(2)` crosses, through the E51 seam), refinement for header sanity.
- **The reframing:** an ELF is **one more layout pass over the same Asm
  stream** the backend already emits. The emitter's output today is
  positioned bytes; the ELF writer prepends 120 bytes of header whose every
  field is a constant or simple arithmetic over `len(code)` (ref rows), and
  fixes the relocation base at 0x400078 instead of a JIT address. Pure
  function from code bytes to file bytes; the crossing that writes it is the
  ordinary sys face. W^X across stages: the minimal file is one RX segment
  (`p_flags` 5 — code only, no writable data yet); when the data/arena
  segment arrives it becomes a second PT_LOAD with `p_flags` 6 (RW), never
  one segment with 7 — the loader-time form of the same W^X rule the mmap
  path enforces at runtime.
- **What chirality makes impossible here:** entering code that was still
  writable (the kernel maps RX from the file; there is no W-then-X window at
  all — stronger than the mmap path's flip); a "program" that exists only
  inside a host process; an entry ABI defined by a ctypes accident rather
  than the psABI; and — once the header fields carry refinements
  (`e_phentsize = {I64 | = 56}` per the ref) — a header the checker cannot
  prove well-formed against the spec constants.

## 5. Chirality example (fleshed)

The clear-cut example — the header as pure byte construction. Every constant
cites its `refs/ref-elf.md` row (source: elf.h / struct math / derived).

```chirality
(import "prelude")
(import "collections")
; bytes floor: bcat + pack-u16/pack-u32 (LE) are prelude externs; there is NO
; pack-u64 today — composed here from two u32 halves. No shift ops exist in
; the pure fragment, so the split is Euclidean div/mod by 2^32 (all header
; values are nonnegative, where Euclidean = the usual quotient).
(def pack-u64 (-> I64 Bytes)
  (lam (n)
    (bcat (pack-u32 (% n 4294967296))     ; low 32 bits, LE first
          (pack-u32 (/ n 4294967296)))))  ; high 32 bits

; ---- layout constants (refs/ref-elf.md; sources: struct math + elf.h) ----
(def ehsize    I64 64)          ; Elf64_Ehdr total          [struct math]
(def phsize    I64 56)          ; Elf64_Phdr total          [struct math]
(def code-off  I64 120)         ; ehsize + phsize = 0x78    [derived]
(def load-base I64 4194304)     ; 0x400000 conventional     [derived]

; ---- e_ident: 16 bytes, fully constant (ref: Ehdr row 0) -----------------
; 7f 45 4c 46 | ELFCLASS64=2 ELFDATA2LSB=1 EV_CURRENT=1 | ABI 0 | 8 pad
(def e-ident Bytes
  (bcat (pack-u32 1179403647)             ; 0x464c457f LE = 7f 45 4c 46
  (bcat (pack-u32 65538)                  ; 02 01 01 00: class,data,version,abi
        (pack-u64 0))))                   ; padding

; ---- the Ehdr: field-by-field, offsets per the ref table -----------------
(def elf-ehdr (-> I64 Bytes)              ; codelen -> 64 header bytes
  (lam (codelen)
    (bcat e-ident
    (bcat (pack-u16 2)                    ; e_type   ET_EXEC     [elf.h]
    (bcat (pack-u16 62)                   ; e_machine EM_X86_64  [elf.h 0x3e]
    (bcat (pack-u32 1)                    ; e_version EV_CURRENT [elf.h]
    (bcat (pack-u64 (+ load-base code-off))  ; e_entry = 0x400078 [derived]
    (bcat (pack-u64 ehsize)               ; e_phoff: phdr follows ehdr
    (bcat (pack-u64 0)                    ; e_shoff: no sections
    (bcat (pack-u32 0)                    ; e_flags
    (bcat (pack-u16 ehsize)               ; e_ehsize  = 64  [readelf agrees]
    (bcat (pack-u16 phsize)               ; e_phentsize = 56 [readelf agrees]
    (bcat (pack-u16 1)                    ; e_phnum: one PT_LOAD
    (bcat (pack-u16 0)                    ; e_shentsize = 0
    (bcat (pack-u16 0)                    ; e_shnum     = 0
          (pack-u16 0))))))))))))))))     ; e_shstrndx  = 0 (no pack-u48 exists)

; ---- the one RX PT_LOAD (ref: Phdr table) --------------------------------
(def elf-phdr (-> I64 Bytes)
  (lam (codelen)
    (bcat (pack-u32 1)                    ; p_type PT_LOAD       [elf.h]
    (bcat (pack-u32 5)                    ; p_flags PF_R|PF_X=4|1 [elf.h]
    (bcat (pack-u64 0)                    ; p_offset: whole file from byte 0
    (bcat (pack-u64 load-base)            ; p_vaddr
    (bcat (pack-u64 load-base)            ; p_paddr (= vaddr, unused)
    (bcat (pack-u64 (+ code-off codelen)) ; p_filesz: ehdr+phdr+code
    (bcat (pack-u64 (+ code-off codelen)) ; p_memsz = filesz (no bss)
          (pack-u64 4096))))))))))        ; p_align 0x1000

; ---- the whole file: pure A-side value; writing it is the E51 crossing ---
(def elf-file (-> Bytes Bytes)            ; code -> executable file bytes
  (lam (code)
    (bcat (elf-ehdr (blen code))
    (bcat (elf-phdr (blen code)) code))))

; The code's relocation base changes from the JIT address to 0x400078: the
; SAME asm-reloc two-pass resolves against (+ load-base code-off). ; …
; Ending: no ret — the program's last crossing is exit(2), syscall 60,
; through sys-tal (the sys face owns it; see E51/E32).
```

- **Knobs to modify:** `load-base` (any page-aligned vaddr); a second RW
  PT_LOAD (`p_flags` 6) when the data/arena segment lands — bump `e_phnum`,
  keep segments W^X-disjoint; refinement-typed header fields
  (`(refine I64 (= 56))` on phentsize) once worth the ceremony.
- **Deliberately omitted:** sections, symbol/string tables, dynamic linking,
  PIE/relocatable output (ET_DYN), auxv parsing — a *minimal static ET_EXEC*
  is the whole scope; bss (`p_memsz > p_filesz`) until the arena needs it.

## 6. Use / modify notes

- **Lands in:** `lib/elf.chiral` (pure layout pass over the Asm stream, beside
  `asm-reloc.chiral`), plus a small `chirality emit` CLI face; retires
  `native.py`'s loader half stepwise (E20's residue becomes `execve`).
- **Conformance target:** `readelf -h`/`-l` accepts the output (field-for-field
  against the ref tables); the binary runs and exits with the expected code;
  differential: the same compiled function batch produces identical
  observable results via the mmap path and the ELF path (the two loaders are
  two floors of the same program — floor-agreement's discipline applied to
  loading).
- **Open questions:** where the entry stub lives (a tiny prologue that
  captures rsp's argc/argv/envp for the runtime — hand-tal like
  `bytes-tal`, or emitted?); when the arena moves into a second RW segment
  (and with it heapptr/heapend initialization — today the Python loader
  points them at a fresh mapping); whether the ELF writer itself becomes the
  first `specialize`/pregen customer (the header is 120 mostly-constant
  bytes — fold it at build time).
- **Related:** [[E20-loader]] (the crutch this retires), E23 (the trampoline
  that disappears), [[E51-sys-linkage]] (the write/exit crossings),
  [[E32]]-adjacent (env/argv become entry-stack data), [[E21-arena]] (the
  future RW segment), `lib/asm-reloc.chiral` (the stream this is one more
  pass over), `refs/ref-elf.md` + `refs/gen-elf.py` (the script-derived
  ABI bank).
