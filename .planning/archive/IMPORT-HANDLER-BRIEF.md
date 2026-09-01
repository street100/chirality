> **ARCHIVED 2026-09-01. Superseded by `lib/module/resolve.chiral` and `bin/chirality-resolve.sh`, the two live resolvers, and by the E87 catalog row.** The nested-constructor-pattern limit this brief describes was fixed in the scriba slices, and the resolver comment-skip concern is moot at the current blob size.

# Import Handler — Implementation Brief

## Goal
Make B1's `(import "module")` work: read the named `.chiral` file, parse it,
merge its externs/definitions into the importing module's scope. Currently the
dispatch in `load-form` is a no-op:
```
((str-eq head "import")   (step-ok (sst sig env)))
```
This is confirmed by the comment on the same line: "import (needs the
file-reading sys face -- the NEXT slice)."

## Three interrelated issues

### 1. Nested constructor case patterns
B1's `parse-arm` parser (parse.chiral:311-330) cannot parse nested constructor
patterns in `case` branches. A pattern like `(cons a (cons b nil))` passes
through `syms->names` which expects every sub-element to be `s-sym` (a variable
name). The inner `(cons b nil)` is `s-list`, not `s-sym`, and fails.

**Root cause:** `SArm.vars` is `(List Str)` — flat. To represent nested patterns
like `(cons a (cons b nil))`, the Surf ADT needs a `Pat` type:
```
(data Pat () (p-var (nm Str)) (p-ctor (nm Str) (args (List Pat))))
```
and `SArm.vars` must become `(List Pat)`. This cascades through surface.chiral,
kernel.chiral, and the CArm/emit pipeline.

**Symptom:** "bad case branch (want (pattern body))" or "expected a symbol"
when the pattern contains nested constructor applications.

**Workaround available:** Flat patterns like `(cons a rest)` or `(cons a nil)`
where nil is treated as a variable name (shadowing the constructor) are accepted.
But `(cons a (cons b nil))` is not. All import-handler implementations need to
destructure `(import "name")` which is `(cons path (cons nil nil))` — a nested
cons with nil.

### 2. Forward-reference constraint
`load-source` is defined at the END of parse.chiral (line ~851). The import
handler dispatch lives in `load-form` at line ~717. Any new function that calls
`load-source` must be defined AFTER load-source, but the dispatch in `load-form`
needs it. Two approaches:

**A. Inline:** Replace the no-op dispatch with inline code that calls
`load-source`. Pro: no forward-reference issue (load-source is visible at that
point in the same function scope). Con: the inline code must fit inside the
existing `cond` branches of load-form without breaking paren structure.

**B. Separate function + declare:** Add `(declare load-source ...)` before
load-form, add `(declare handle-import ...)` before load-form, define
`(def handle-import ...)` after load-source. This SHOULD work (the compiler
uses `declare` → `def` for `handle-def` at lines 548→551), but caused
"global load-source redefined" in the Python checker when both declare and def
exist.

### 3. Paren-counting bug in chirality-resolve.sh
The shell resolver `bin/chirality-resolve.sh` uses `grep -oE '\(import "[^"]+"\)'`
to find module dependencies. This pattern matches inside comments and strings
in the source. When a source file contains `the (import "...") handler` in a
comment, the resolver tries to resolve `"..."` as a module path and fails.

**Fix:** Skip comment lines before grepping. Change line 37 from:
```sh
for dep in $(grep -oE '\(import "[^"]+"\)' "$f" ...)
```
to:
```sh
for dep in $(sed '/^[[:space:]]*;/d' "$f" | grep -oE '\(import "[^"]+"\)' ...)
```

## What was proven to work (incremental build tests)

Each step below compiles under the native compiler at FIXPOINT 676065:

1. `(import "ports")` + `(extern openat ...)` + `(extern close ...)` + file I/O
   helpers (`prd-go`, `parse-read-fd-all`, `parse-read-file-str`) — all in
   parse.chiral
2. `(declare handle-import ...)` before load-form, no body yet
3. handle-import with flat case patterns, no load-source call:
```
(def handle-import
  (lam (st rest)
    (case st ((sst sig env)
      (case rest
        ((cons pathS rest2)
          (case pathS
            ((s-str path) ...)
            (_ (step-err "import path"))))
        (_ (step-err "import form")))))))
```
4. Same as #3 but with `(read-all-str src)` and `(parse-read-file-str ...)` calls
5. Same as #4 with `(case (read-all-str src) ((a-err mp) ...) ((a-ok forms) ...))`

## What fails

Adding `(case (load-source src) ...)` inside handle-import fails with
"bad case branch (want (pattern body))" regardless of placement (inline,
separate function at end, etc.). The error is on the `(sst sig env)` branch
of some `case st` expression — not necessarily handle-import itself but
sometimes load-form's sst branch when inline code corrupts the cond structure.

The Python checker (reference implementation) ACCEPTS all versions of the code.
The native compiler's stricter parser is the bottleneck.

## Recommended attack plan (for fresh chat)

### Step 1: Fix nested case patterns in parse-arm
File: `scaffold/lib/parse.chiral`, function `parse-arm` (line 311-330)

Add a `Pat` type to surface.chiral:
```
(data Pat () (p-var (nm Str)) (p-ctor (nm Str) (args (List Pat))))
```
Change SArm.vars from `List Str` to `List Pat`.
Update `parse-arm` to recursively parse nested constructor patterns.
Update `elab-arm` in surface.chiral to handle the new Pat type.
Cascade through kernel.chiral's CArm and emit phases.

### Step 2: Write handle-import (EITHER approach)
Once nested patterns compile, write handle-import anywhere in parse.chiral
(preferably right after the declare for it, before load-form). It should:

1. Match `(import "module-name")` → extract path string
2. Add `.chiral` suffix → `fname`
3. `parse-read-file-str fname` → `src`
4. `load-source src` → merge prims/implicitly includes the sig
5. Return `(step-ok (sst merged-sig env))`

### Step 3: Test
```
echo '(import "prelude") (def f (-> I64 I64) (lam (x) (+ x 1))) (def compile-main (-> I64 I64) (lam (n) 0))' | build/B1
```
Should produce an ELF (no "unknown name +" error).

### Step 4: Scriba compilation
Remove the blob-resolver workaround. `scriba/cmd-op.chiral` should compile with
`(import "puffer")` etc. directly.

## Current state of the repo
- `scaffold/lib/parse.chiral`: git-clean (no import handler changes)
- `scaffold/lib/*.chiral` (all other files): all proven changes intact
  (Mach bgs, Fact type, TIFn 5-field, emit-core fact-safe, x-bgs, E57 staging)
- `bin/chirality-resolve.sh`: comment-skip fix NOT yet applied (safe to apply)
- `scaffold/build/B1`: 676065 bytes, FIXPOINT self-hosting
- `chirality test-native`: 6/6 green
- `scaffold/tests/test_staging.py`: 29/29 green
- scriba: compiles via blob resolver only, ELF 45281 bytes

## Files to touch (in order)
1. `scaffold/lib/surface.chiral` — add Pat type, change SArm.vars
2. `scaffold/lib/parse.chiral` — update parse-arm, add handle-import
3. `scaffold/lib/kernel.chiral` — possibly update CArm if needed
4. `bin/chirality-resolve.sh` — apply comment-skip fix (already drafted)
5. Remove `examples/`, `import-module.chiral`, `importer.chiral` if they exist
