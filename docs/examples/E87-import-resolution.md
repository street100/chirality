---
element: E87
slug: import-resolution
title: Import resolution — `(import "...")` handler + module bundler
kind: SELF-HOST
reference_class: IMPL/SPEC
ours_source: (none — surface.py load_file is the reference, shell resolver is the prototype)
status: drafted
updated: 2026-08-07
---

# E87 — Import resolution: module bundler for B1

> One worked example. Conventional bundler vs the chirality idea, ending in a
> clear-cut snippet to copy and modify for the implementation run.

## 1. Scope

- **Element:** E87 — the import-resolution phase: given a root module
  `(import "prelude")` → `(import "ports")` → …, walk the transitive dependency
  graph, deduplicate by basename, produce one ordered flat source blob for B1.
- **Kind:** SELF-HOST — replaces the shell resolver `bin/chirality-resolve.sh` and
  the Python `surface.py load_file` with a chirality-native bundler.
- **Why chirality needs its own:** B1's `(import "...")` dispatch at `parse.chiral:729`
  is a no-op. The self-compile works because the Python toolchain pre-assembles a
  flat blob. Scriba works only because symlinks make deps findable in CWD — the
  imports are still no-ops. A chirality-native bundler closes the gap: zero Python,
  zero shell in the compile path, and scriba compiles through real import
  resolution instead of symlink luck.

## 2. Research

- **Reference class:** IMPL / SPEC.
- **Key findings:**
  1. **Kalyn** (self-hosting Lisp→x86-64): the **bundler** is a distinct phase
     before the parser. It reads the main module, follows transitive imports
     via graph traversal, resolves file paths by parent-directory search, and
     produces a single flat source. The resolver phase then uniquifies names by
     prepending module prefixes. Two phases, compiler gets flat input.
     *(intuitiveexplanations.com/tech/kalyn, Bundler.hs)*
  2. **GHC `--make`**: the compiler itself follows imports — give it Main.hs,
     it finds every module by conventional name→path mapping, compiles in
     dependency order, links. One command, compiler-integrated.
  3. **chirality Python resolver** (`surface.py:59–76`): `load_file` resolves
     imports relative to the importing file's directory, appends `.chiral`,
     deduplicates by absolute path. Clean, recursive, 18 lines.
  4. **chirality shell resolver** (`bin/chirality-resolve.sh`): graph traversal in
     bash — parent-directory search (same dir → parent → libdir root),
     basename dedup, concatenation. Works for self-compile. Comment-skip
     via `sed '/^[[:space:]]*;/d'`. No cycle detection (cycles handled
     implicitly by the `seen` set).

## 3. Conventional (other-language) approach

Kalyn's bundler (Haskell):

```haskell
-- Bundler: read all modules transitively, produce flat source
bundle :: FilePath -> IO Text
bundle mainModule = do
    let resolve importPath fromDir =
            -- same dir → parent → lib root
            findFile [fromDir, parent fromDir, libRoot] importPath
    seen <- newIORef Set.empty
    order <- newIORef []
    let walk modPath = do
            s <- readIORef seen
            when (modPath `Set.notMember` s) $ do
                modifyIORef seen (Set.insert modPath)
                src <- readFile modPath
                let imports = parseImports src
                mapM_ (\imp -> walk (resolve imp (takeDirectory modPath))) imports
                modifyIORef order (++ [src])
    walk mainModule
    sources <- readIORef order
    pure (T.unlines sources)
```

- **Assumptions it bakes in:** unguarded file I/O (ambient `readFile`), no
  proof that the resolved graph is a DAG, no typed contract between modules
  (just concatenation), no memoization guarantee — the `IORef` is mutable state
  threaded through IO.

## 4. The chirality idea

- **Chirality features in play:**
  - **Effect membrane `->` vs `=>`:** file reading (openat/read) is effectful
    (`=>`). The bundler's pure core — the dependency walk, dedup, ordering —
    is `->`. The seam between them is typed: the pure core takes a list of
    (module-name, source) pairs, returns ordered source.
  - **Ports & capabilities:** the bundler receives a `LibDir` port (an open
    directory fd) rather than ambient filesystem access. Every file open
    crosses through that port.
  - **Errors as values:** missing modules, parse failures, circular imports
    return explicit error sums — no exceptions, no `die()`.
  - **Totality:** the dependency walk is structural recursion over a finite
    import graph. The dedup set bounds the recursion.
- **The reframing:** the bundler is a **chirality process** (`=>` entry), not a
  shell script. It takes a root module name and a libdir capability, produces
  either a flat source blob or an error. The pure core (graph walk + ordering)
  is separable and testable without file I/O.
- **What chirality makes impossible here:** ambient filesystem access (must go
  through a port), uncaught IO exceptions (every open/read returns a result
  sum), non-deterministic ordering (the walk order is deterministic given
  a fixed import graph).

## 5. Chirality example (fleshed)

```chirality
; E87 — chirality-native module bundler. Replaces chirality-resolve.sh.
; Takes a libdir prefix and root module, walks transitive imports,
; concatenates in dependency order with basename deduplication.
; Pure core: (-> (List Module) (List Module)) — the graph walk.
; Effectful driver: (=> Str Str Bytes) — libdir, root → flat source.

; A module, mid-resolution: its name, its source text, its imports.
(data Mod ()
  (mod (name Str) (path Str) (src Bytes) (deps (List Str))))

; Resolution error. No exceptions.
(data ResErr ()
  (re-not-found (name Str) (from Str))
  (re-read-err  (path Str) (msg  Str))
  (re-cycle     (cycle (List Str))))

; The result: either flat source or an error.
(data ResR ()
  (res-ok  (blob Bytes))
  (res-err (err ResErr)))

; ── Pure core: dependency-ordered walk with dedup ──

; seen-set insertion: return (pair new-seen was-new?)
(def seen-insert (-> (List Str) Str (Pair (List Str) Bool))
  (lam (seen name)
    (case (member Str str-eq seen name)
      (true  (pair seen false))
      (false (pair (cons name seen) true)))))

; Walk one module's imports, accumulating ordered modules.
; Threads the seen set and the accumulating order list.
; Pure (->) — no file I/O, works on already-loaded Mod records.
(def walk-imports
  (-> (List Str) (List Mod) (List Mod) Mod (Pair (List Str) (List Mod)))
  (lam (seen all-mods order mod)
    (case mod ((mod name path src deps)
      (let (p (seen-insert seen name))
        (case p ((pair seen2 is-new)
          (case is-new
            (false (pair seen2 order))
            (true
              ; Recurse into each dependency, then append self
              (let (r (walk-list seen2 all-mods order deps))
                (case r ((pair seen3 order2)
                  (pair seen3 (append-mod order2 mod))))))))))))))

; Walk a list of dependency names.
(def walk-list
  (-> (List Str) (List Mod) (List Mod) (List Str) (Pair (List Str) (List Mod)))
  (lam (seen all-mods order deps)
    (case deps
      (nil (pair seen order))
      ((cons d rest)
        (case (lookup-mod all-mods d)
          ((none)    (pair seen order))   ; skip unresolvable (caller checks)
          ((some m)  (let (r (walk-imports seen all-mods order m))
                       (case r ((pair seen2 order2)
                         (walk-list seen2 all-mods order2 rest))))))))))

; ── Effectful driver: read files, call pure core, emit blob ──

; Resolve one module name to its source, given a libdir fd.
; Returns either a Mod record or a ResErr.
(def resolve-mod (=> (1 d LibDir) Str (P ResErr Mod))
  (lam (d name)
    (let (path (str-cat name ".chiral"))
      (case (openat d path)
        ((<i fd 0) (p-err (re-not-found name "")))
        (else
          (let (src (read-fd-all fd))
            (close fd)
            (let (deps (parse-imports src))
              (p-ok (mod name path src deps)))))))))

; The entry point: libdir prefix (as Bytes path), root module name → blob.
(def bundle (=> Bytes Str ResR)
  (lam (libdir-path root-name)
    (case (openat AT_FDCWD libdir-path)
      ((<i d 0) (res-err (re-read-err "libdir" "cannot open")))
      (else
        (let (r (resolve-all (1 d) root-name nil nil))
          (close d)
          (case r
            ((res-err e) (res-err e))
            ((res-ok mods)
              ; Pure: order the modules by dependency
              (let (p (walk-list nil mods nil (list root-name)))
                (case p ((pair _seen ordered)
                  (res-ok (concat-mods ordered)))))))))))))

; The binary entry point: read root from env, libdir from arg.
(def compile-main (=> I64 I64)
  (lam (_)
    (let (libdir (env-get "CHIRALITY_LIBDIR"))
      (let (root   (env-get "CHIRALITY_ROOT"))
        (case (bundle (str->bytes libdir) root)
          ((res-err e) (put (reserr->str e)) 1)
          ((res-ok blob)
            (let (n (fd-write 1 blob))
              0)))))))
```

- **Knobs to modify:** the `find-module` search strategy (same-dir → parent →
  libroot is the Kalyn pattern; this example writes one search path for
  clarity). The dedup key (basename vs full path — basename matches the
  current shell resolver). The `parse-imports` function (currently a stub —
  the real implementation reuses `read-all-str` from E1's `sexp.chiral`).
- **Deliberately omitted:** cycle detection as a user-facing error (the
  `seen` set prevents infinite loops but doesn't report the cycle — cycles
  produce duplicate-free output in arbitrary order). Qualified imports,
  re-exports, public/private visibility. The `openat` crossing itself
  (E28/E51 — already built, imported from `ports.chiral` / `self-wield.chiral`).

## 6. Use / modify notes

- **Lands in:** `lib/module/resolve.chiral` (the stub already exists at
  `prog/scriba/resolve.chiral` — move it to the lib root and flesh
  it out). The shell resolver `bin/chirality-resolve.sh` stays as the bootstrap
  path until the chirality-native resolver self-compiles.
- **Conformance target:** given `scriba/scriba-main` as root and
  `scaffold/lib` as libdir, produces a blob byte-identical to the current
  `chirality-resolve.sh` output (79,045 bytes, 13 modules in dependency order).
- **Open questions:**
  1. Should the bundler be a separate binary or a library linked into B1?
     (Separate binary = Kalyn pattern, simpler; linked = self-loading
     compiler, needs the nested-pattern + forward-reference fixes from
     the import-handler brief.)
  2. Basename dedup vs full-path dedup? (Basename matches current resolver;
     full-path allows `lib/foo.chiral` and `app/foo.chiral` to coexist.)
  3. Where does `parse-imports` live? (Could be a separate pure function
     using E1's `read-all-str`, or inline in the bundler.)
- **Related:** [[IMPORT-HANDLER-BRIEF]] (the in-compiler alternative),
  [[E51-sys-face-linkage]] (the openat/read surface the bundler needs),
  [[E28-mmap-munmap]] (filesystem syscalls).
- 2026-09-04: the 2026-08-31 migration moved the tree out of scaffold/. The pre-migration paths kept here name no live directory.