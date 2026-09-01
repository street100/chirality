> **ARCHIVED 2026-09-01. Superseded: its one ask, create a catalog element for the dispatch work, was done and E95 is recorded built in `docs/elements/ledger.md`.** ⚑ `docs/elements/catalog.md` still reads `Not built` for E95, which disagrees with the ledger. That disagreement outlives this file and belongs in `records/`; it is not fixed here.

# scriba dispatch — handoff for next session

## Current state (2026-08-08)

**B1 fixpoint:** 671986 bytes, byte-identical, at `scaffold/build/B1`.

### What compiles

| Element | Status | Files |
|---------|--------|-------|
| E89 checked entry stub | fixpoint | compile-emit.chiral |
| E90 nb-arena-grow TAL wrapper | fixpoint | sys-tal.chiral |
| E91 growing allocator | fixpoint | mach-x64.chiral |
| E94 batch loader | fixpoint | load-batch.chiral (NEW), compile-front.chiral (patched) |

### Scriba source — ready but blocked

`command-loop.chiral` has `try-dispatch` inlined before `command-loop-inner` with forward declare. Removed `(import "collections")`. Structurally verified (PARSE OK, all imports correct, dispatch wired to false arm of quit check). E92 audited.

### What blocks scriba compilation

`chirality_blob scaffold/lib scriba/scriba-main` produces a clean 334-form blob (use Python subprocess to capture stdout — shell `chirality_blob` leaks mktemp errors into the blob). Append linkage files (crossing-wraps, sys-check, target-linux, sys-tal, sys-linkage) and rename `scriba-main` → `compile-main`. Pipe through B1.

**Error:** `no emitted label for entry compile-main`

**Root cause:** B1's lowering/erase pipeline can't handle the mutual recursion `command-loop-inner` → `try-dispatch` → `command-loop-inner` through effectful (=>) calls.

**What's been ruled out:**
- Form/type capacity: E94 batch loader handles the full blob cleanly (334 forms, zero non-list)
- Arena/heap: 16GB arena + growing allocator, ample capacity
- Pre-scan: E93 confirmed `def-sigs` already collects all signatures before lowering
- Collections import poison: removed from command-loop.chiral
- Nested case patterns: flattened in command-loop.chiral
- Multi-expression case branches: all wrapped in `let` sequencing
- Declare ordering: `command-loop-inner` forward-declared before `command-loop` uses it

**What needs investigation:** Why the lowering pass at `lower.chiral` / `tal-erase.chiral` drops the entry label. The pre-scan (E93) provides signatures but something in the effect chain counting or erase step still fails. Isolated tests show pure mutual recursion compiles, effectful self-recursion compiles, but effectful mutual recursion fails.

### Pipeline state (INDEX)

| E# | Status |
|----|--------|
| E88 | audited — mark-region.chiral written, blocked on B1 str-edit compilation |
| E89 | implemented — checked entry stub |
| E90 | implemented — nb-arena-grow |
| E91 | implemented — growing allocator |
| E92 | audited — scriba dispatch wiring |
| E93 | audited — lowering pre-scan (documentation) |
| E94 | implemented — batch loader |

### Build workflow

```
# Edit source in chirality/scaffold/lib/
# Sync to chirality
cp scaffold/lib/*.chiral ../chirality/scaffold/lib/
# Build
cd ../chirality && ./build.sh
# Fixpoint
cp bin/chirality-bin.new bin/chirality-bin && ./build.sh
# Copy back
cp bin/chirality-bin.new ../chirality/scaffold/build/B1
```

### Scriba blob construction (clean)

```python
import subprocess, re
result = subprocess.run(['bash','-c',
    'source bin/chirality-resolve.sh 2>/dev/null; chirality_blob scaffold/lib scriba/scriba-main 2>/dev/null'],
    capture_output=True, text=True, timeout=30)
blob = re.sub(r'^mktemp:.*\n?', '', result.stdout, flags=re.MULTILINE)
blob = blob.replace('(def scriba-main', '(def compile-main')
for f in ['crossing-wraps','sys-check','target-linux','sys-tal','sys-linkage']:
    blob += open(f'scaffold/lib/{f}.chiral').read() + '\n'
# Pipe through B1
```

### Next: scope and pipeline the lowering/erase fix

The effect chain threshold in `lower.chiral` needs investigation. Create a catalog element (E95) and run the full pipeline (worked-example → audit → spec → audit → implement). The fix is likely a 2-3 line change in the erase step or effect counting — not a new architecture.
