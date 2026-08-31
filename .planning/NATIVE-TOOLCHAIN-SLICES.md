# Native toolchain — slice checklist

What exists in Python, needs to become chirality-native. Ordered by dependency.

## Slice 0 — scriba QTT pass ✅ COMPILES (2026-08-08)

- **What:** Fixed linear binder issues in scriba files
- **Gate met:** `chirality_blob scriba/scriba-main | B1` produces ELF (131KB)
- **What runs:** terminal setup → read-key loop (beeps on every key, quits on "quit") → terminal restore
- **NOT yet:** cannot edit text or dispatch operations — blocked by B1 effect chain threshold
- **Files:** 18 scriba files, all parens balanced, 0 collections imports in active chain

## Slice 1 — native oracle (chirality check with line numbers)
- **What:** A chirality binary that type-checks source and reports errors with file:line
- **Why:** Replaces `python3 -m chirality check` — same checker rules as B1, not Python's
- **How:** Port surface.py's line tracking (`form, line` pairs from read_all) into
  parse.chiral's load-source. Wrap each loaded form with its source position.
  On error, print "file:line: error" instead of just "type mismatch."
- **Files:** scaffold/lib/parse.chiral (add position tracking to StepR/LoadR),
  maybe new scaffold/lib/check.chiral (entry point that loads + checks + reports)
- **E#:** New (E88? — "native type-check oracle")
- **Blocks:** unblocks all scriba debugging, makes B1 errors actionable

## Slice 2 — fix resolve.chiral native compilation
- **What:** Make resolve.chiral actually compile through B1 and run as a binary
- **Current state:** Python checker passes (97 defs), B1 can't compile standalone
  because resolve.chiral uses externs (openat, close, env-get) that need the full
  compiler backend pipeline
- **Fix:** Either compile resolve.chiral as part of the self-compile blob (like
  compile-all.chiral), or build a minimal runtime that links externs
- **Files:** scaffold/lib/resolve.chiral, build.sh (add resolve to blob)
- **Gate:** `./resolve` binary works as drop-in for chirality-resolve.sh
- **Blocks:** unblocks zero-shell compile path

## Slice 3 — native check wired into chirality binary
- **What:** Single `chirality` binary that does `chirality check file.chiral`
- **How:** The oracle (Slice 1) as the check subcommand. Entry `chirality-main`
  dispatches on argv[1] — "check" → run oracle, future: "run", "build", etc.
- **Files:** scaffold/lib/chirality-main.chiral (new), bin/chirality (update wrapper)
- **Gate:** `chirality check scriba/scriba-main.chiral` gives line-numbered errors
- **Blocks:** nothing, standalone slice

## Slice 4 — native runner (chirality run)
- **What:** Execute chirality programs natively (no Python interpreter)
- **Existing:** E15 reference interpreter (runtime.py), E16 lowering, E19 codegen
- **How:** compile program to ELF → execute ELF → capture exit code. The
  "runner" is just the compiler + exec. For effectful programs, externs need
  host implementations linked in.
- **E#:** E15 (already cataloged)
- **Gate:** `chirality run program.chiral` runs and returns exit code
- **Blocks:** needed for scriba to actually launch

## Slice 5 — native verify (chirality verify)
- **What:** Profile/target verification native
- **Existing:** Python verify_profiles/verify_targets in surface.py
- **E#:** Part of E2 (profiles) + G9 conformance
- **Lower priority** — scriba doesn't use profiles yet

## Dependency order

```
Slice 0 (scriba QTT) ✅ DONE — unblocks everything
  │
Slice 1 (oracle) ── unblocks systematic scriba debugging
  │
Slice 2 (resolve native) ── needs oracle for debugging, unblocks zero-shell path
  │
Slice 3 (chirality binary) ── wires oracle into CLI
  │
Slice 4 (native runner) ── unblocks scriba launch
  │
Slice 5 (verify) ── lowest priority
```

## What's already chirality-native (no work needed)

| Python command | Chirality equivalent | Status |
|---------------|-----------------|--------|
| lower | lower.chiral + compile-back.chiral | Built |
| emit | emit-core.chiral + emit-x64.chiral + mach*.chiral | Built |
| resolve (shell) | resolve.chiral | Built (Slice 2 needed for native) |
| compile (shell) | B1 (bin/chirality-bin) | Built |
| check | nothing | Slice 1 |
| run | nothing | Slice 4 |
| verify | nothing | Slice 5 |
