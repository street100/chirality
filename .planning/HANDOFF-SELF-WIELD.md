# HANDOFF — chirality wields itself (native resolver/driver, no shell wrapper)

> **Goal:** replace the shell wrapper (`bin/chirality` + `bin/chirality-resolve.sh` in the
> public mirror) with a **native chirality** that resolves its own imports and drives
> its own compile — "chirality wields itself." Moves source-resolution from untrusted
> shell glue INTO the checked language; makes the SourceProvider seam a real chirality
> module (pluggable per profile); dogfoods the ports/effect membrane (reading a
> file is a capability-mediated crossing). Started 2026-08-05, session 8.

## The plan (slices — commit each; keep the shell wrapper as fallback until native verified)

1. **`openat` crossing (THE one missing substrate piece).** Everything else
   exists: `read-fd-all : (=> I64 Bytes)` reads ANY fd; `compile-all : Str→ELF`;
   write + `nb-sys-execveat`. Bound crossings today (lib/crossing-wraps.chiral) are
   ONLY `put/print/trace/halt/read`. Add `openat` (open a file by path → fd):
   - `lib/sys-tal.chiral`: a `nb-sys-openat` tal wrapper. openat nr = **257**;
     args (dirfd=AT_FDCWD=-100, pathname ptr, flags=O_RDONLY=0, mode=0). Mirror
     the existing `nb-sys-read`/`nb-sys-execveat` wrappers (search "nb-sys-").
     The pathname must be a **null-terminated** C string: take a path `Bytes`,
     `bcat` a `\0`, pass its payload address (the `bpr` op gives payload ptr).
   - `lib/crossing-wraps.chiral`: add `(pair "openat" "nb-sys-openat")` to the
     `crossing-wraps` table (the single authority; sys-linkage derives bindings +
     the erase image reads it).
   - declare the extern in the resolver module: `(extern openat (=> Bytes I64))`
     (path → fd), or with flags. Verify a chirality program can `openat` a file +
     `read-fd-all` it → bytes.
   - **Gotcha:** the syscall governance (E76) may require registering the number.
     Check `lib/sys-check.chiral` / SYSCALL_TABLE if openat is refused at tal-check.

2. **`lib/source-fs.chiral` — the filesystem SOURCE PROVIDER, in chirality.** Given a
   root module name + a lib dir prefix (`Bytes`), `openat`+`read-fd-all` each
   module, parse its `(import "X")` refs (the parser already recognizes import
   forms — reuse or string-scan), post-order DFS with a visited set, concat in
   dependency order → `Str`. This is the exact algorithm in `bin/chirality-resolve.sh`
   and `tools/selfhost.py:build_blob`, ported to chirality. It is the pluggable
   provider: a node/content-addressed provider is a different module with the same
   interface.

3. **Driver entry.** A def (e.g. `chirality-main`) that: reads the root name (from a
   fixed convention or stdin), calls source-fs to get the blob, `compile-all`,
   writes the ELF to fd 1 (or `execveat` to run it). argv is deferrable (E80
   env-to-main); start with root-on-stdin or a compiled-in root + fixed lib path.

4. **Wire + verify.** Compile the driver with `chirality-bin` → a native `chirality` binary.
   Test: it compiles a program that `(import "prelude")` + uses `+` → exit 42,
   entirely native (no shell resolver). Then the shell `bin/chirality` becomes the
   documented fallback. Keep the fixpoint (`./build.sh`) green throughout.

## Ground truth (verified 2026-08-05)
- Bound crossings: `lib/crossing-wraps.chiral` — put/print/trace/halt/read only.
- `read-fd-all` (lib/compile-all.chiral) takes an fd arg. `compile-main` reads fd 0.
- `nb-sys-execveat` exists (lib/sys-tal.chiral ~line 153) — can exec a memfd.
- No `openat` anywhere in the sys face (grep-confirmed).
- The self-hosting fixpoint holds (`FIXPOINT: B1==B2`, `main@<HEAD>`); the native
  compiler is `scaffold/build/B1` (private) / `bin/chirality-bin` (public mirror).
- Public mirror (../chirality) is Python-free; shell wrapper works there now.

## Rebuild/verify commands
- rebuild native compiler after lib changes: `(cd scaffold && python3 tools/selfhost.py stage1)` → build/B1 (~340s, python stage-0 bootstrap, private only).
- fixpoint check: `(cd scaffold && python3 tools/selfhost.py stage2)` → `FIXPOINT: B1==B2`.
- full suite: `(cd scaffold && python3 -m unittest discover -s tests)` (671 green baseline).
- a chirality program reading a file (once openat lands): openat "path" → fd; read-fd-all fd.

## STATUS (update as you go)
- [x] Slice 1 — openat crossing (committed; type-checks; rebuild+fixpoint pending)
- [x] Slice 2/3 — wield-main driver (lib/self-wield.chiral): openat+read+compile a file, WORKS natively (exit 42, no shell/python)
- [x] native wielder minted (build/chirality-wield); B1 now carries openat, fixpoint at stage2 (byte-identical)
- [x] Slice 4 — native wielder shipped (mirror bin/chirality-native) + verified (exit 42); shell bin/chirality = full-featured fallback. REMAINING: import-DFS in chirality (lib/source-fs) to follow (import ...) across files -> full shell-resolver replacement.

## Concrete technique notes (figured out 2026-08-05)
- **Null-terminate a path for `openat`:** the wrapper passes `bptr(path)` (payload
  ptr) straight to the syscall, so the caller MUST NUL-terminate. Idiom (no new
  primitive): `(bcat path (bslice (pack-u32 0) 0 1))` — `pack-u32 0` is 4 zero
  bytes, `bslice … 0 1` takes one. Same trick `mach-x64.chiral` uses for `b1`.
- **`openat` extern signature for callers:** `(extern openat (=> Bytes I64))`
  (NUL-terminated path bytes → fd, or negative errno). It's a crossing (`=>`).
- **The driver is compiler-internal** (it calls `read-fd-all` + `compile-all`,
  which live in `lib/compile-all.chiral`). So add the driver as a new entry there
  (or a `lib/self-wield.chiral` that imports compile-all), NOT as standalone input.
  Building the self-wield binary = compile that driver entry with `chirality-bin`
  (its own entry name, e.g. `wield-main`), exactly like `compile-main` is built.
- **Simplest slice-2 (manifest, less chirality than import-DFS):** driver reads a
  newline-separated list of module PATHS on fd 0, loops: NUL-term each →
  `openat` → `read-fd-all fd` → accumulate `bcat`, → `compile-all blob
  "compile-main"` → write ELF to fd 1. The ordered path list is trivial to
  produce (even the committed 39-module order). Import-DFS-in-chirality (true
  `source-fs`) is the fuller slice-2; manifest-first is the cheap landing.
- **Build the native wielder:** `printf '<driver-blob>' | chirality-bin > bin/chirality-native`
  once the driver entry exists — i.e. resolve+compile the compiler-with-driver via
  the shell path ONE more time to mint the native wielder, then it wields itself.
- **NEEDS NEW B1:** the driver uses `openat`, only in the post-slice-1 lib, so it
  must be compiled by the rebuilt B1 (in progress). Interpreted `compile-all` also
  works for testing without waiting.

## Fallback / invariants
- Keep `bin/chirality` + `bin/chirality-resolve.sh` (shell) working until the native
  wielder is verified — they are the fallback, not deleted.
- Every lib change: keep `./build.sh` at the fixpoint (byte-identical) and the
  671-test suite green. Commit each slice.
- Private keeps all Python (oracle/tooling); public mirror stays Python-free.
