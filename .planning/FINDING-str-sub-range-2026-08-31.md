> **Tracked row: `FD-01` in `records/findings.md`.** That row is what survives a fresh clone; this file is the long-form measurement and stays because the `end > len` half is still open.

# FINDING: `str-sub` has no range discipline

**2026-08-31.** Found while writing `prog/prose-lint.prog`, the first program to
call `str-sub` with a computed index at a string boundary.

`str-sub : (-> Str I64 I64 Str)` is `(s start end)`, half-open, and lowers to
`nb-bslice` (`lib/lowering/tal/erase.chiral:114`). Two range cases are unguarded.

## 1. `end < start` kills the process

```
(str-len (str-sub "abc" 2 1))     ; SIGSEGV, exit 139
```

Reproduced standalone, no file I/O, no recursion. The slice length is computed as
`end - start`, and a negative length reaches the allocator.

This is reachable from ordinary code. The call that found it was
`(str-sub s i 1)`, written under the belief that the third argument was a
*length*. Under `(start, end)` that expression is inverted for every `i > 1`, and
the program dies rather than returning a wrong answer or an error.

## 2. `end > len` does not clamp, and a caller already depends on the clamp

```
(str-len (str-sub "abc" 0 99))    ; => 99
```

The result is a `Str` of length 99 over a 3-byte buffer: 96 bytes of whatever
follows it in memory, with no error and no truncation.

`lib/prelude/string.chiral:14` states the opposite, in a comment that is load
bearing rather than decorative:

```
; does s begin with prefix? (str-sub clamps, so a too-long prefix is just false)
(def str-starts-with (-> Str Str Bool)
  (lam (prefix s)
    (str-eq (str-sub s 0 (str-len prefix)) prefix)))
```

`str-starts-with` with a prefix longer than `s` therefore compares the prefix
against a view that runs past `s`. It returns `false` today, which is the right
answer, reached by reading memory it does not own and finding that the bytes
happen to differ. `str-starts-with` is called across the tree, including in
`str-strip-prefix` directly below it.

Verified correct and NOT a defect: the argument order is `(prefix, s)`, so
`str-starts-with "ab" "abcdefgh"` asking whether `"abcdefgh"` begins with `"ab"`
is `true` as it should be. The first reading of this finding had that backwards.

## Why this is the interesting kind of bug

P1: a gap is an ungoverned path. Both cases are a typed call, in category A, at
`alt upper`, that leaves the region the type describes. `Str` carries no length
relation between its bounds, so the checker cannot see either case, and the tal
floor's `nb-bslice` takes the numbers it is given.

P4 also bites: the safe path is not the cheap path here. Writing the guard at
every call site is ceremony that the one-line spelling omits, so the omission is
the default.

## Not fixed here, and why

`str-sub` is a primitive on the compiler's own path. Changing its behaviour
changes emitted code for every module that uses it, which puts a self-host
fixpoint on the change. That is a deliberate slice, not a drive-by.

The shape of the fix is a real decision and should be chosen, not assumed:

- **clamp both ends** (`start` to `[0,len]`, `end` to `[start,len]`), which makes
  the comment at `string.chiral:14` true and every existing caller correct;
- **return `(Maybe Str)`**, making the partiality visible and forcing callers to
  case on it, at the cost of touching every call site;
- **refine the type** so the bounds relation is checked, which is the answer the
  language is actually for and the most expensive.

The clamp is the smallest change that closes both cases and repairs a claim the
tree already relies on.

## Owed

No `E#` is minted for this yet, so nothing above is deferred to a phantom. Mint
the catalog and ledger rows in the same change that picks the fix, per the
deferral rule.

Workaround in the tree today: `prog/prose-lint.prog`'s `lc-at?` spells the
one-character slice as `(str-sub s i (+ i 1))` and guards `i < (str-len s)`
itself.

## Attempted 2026-08-31, reverted (superseded, see below)

Tried the obvious fix at the tal floor: clamp a negative length to zero in
`nb-bslice-t` (`lib/lowering/tal/bytes.chiral:130`). The primitive computes
`len = j - i` with `ti-prim (op-sub)` and hands it straight to `ti-bnew`, so an
inverted range allocates a negative length. The change added
`ti-prim (op-lti)` against a zero const and a `ti-tcase` with two arms: the
original body on the false arm, `ti-bnew` of zero on the true arm.

**It type-checks and it does not work.** Build sequence:

    G1 = committed(new sources)   1,102,200 B   compiles fine
    G2 = G1(new sources)          1,102,200 B   compiles fine
    G3 = G2(new sources)          0 B           FAILS

G2 is the first binary carrying the new `nb-bslice` as its *own* runtime, and a
compiler built with it cannot compile. So the emitted tal is wrong, not merely
mis-sized: bumping `nregs` from 9 to 12 changed nothing, which rules out
register exhaustion.

Reverted. The committed binary was never promoted, and a rebuild is byte-identical
to it.

⚑ **The generation lag is the trap here.** G1 compiles, which reads as success.
The defect only appears at G3, two generations in, because a change to
`native-lib` does not reach the running runtime until the compiler has been
rebuilt by a binary that already contains it. Any future attempt at this must
run to **gen3 and compare gen2 to gen3**; stopping at "the new compiler builds"
proves nothing.

Unexplored, and where the next attempt should start: whether `ti-tcase` arms may
allocate registers the way I assumed, whether an arm may reference a register
bound before the `tcase`, and whether both arms must agree on the shape they
return. `nb-rep-go-t` in the same file is the working two-arm example to
copy from rather than to imitate loosely.


## FIXED 2026-08-31 — the inverted-range half

`nb-bslice-t` clamps an inverted range to the empty slice. Fixpoint holds at
gen2==gen3, 1,102,200 B, and the promoted binary rebuilds byte-identically.

### What I got wrong

**`ti-tcase` tag 0 is TRUE and tag 1 is FALSE.** Bool at this floor is the enum
tag `0=true 1=false`, which `bytes.chiral`'s own header states. I read tag 0 the
C way, put the empty-`bnew` on the arm where the comparison does NOT hold, and
built a `nb-bslice` that returned empty for every well-formed slice and the full
slice for inverted ones. A compiler whose string-slicing is inverted cannot
parse its own source, which is why gen3 was 0 bytes with
`load: unsupported toplevel form ` — and the trailing space in that message is
the tell, because the parser's own `str-sub` had returned empty.

The fix also compares `j < i` on the two params directly rather than computing
the length and testing it against zero: one register cheaper, and the compare
sits immediately before the `ti-tcase` so the emitter's cmp+jcc fusion fires.

### Hypotheses eliminated, with evidence — strike these from any future attempt

- *arms must allocate disjoint registers* — **false**. A shape using r7 in both
  arms reaches a clean gen3 fixpoint.
- *an arm may not read a register bound before the tcase* — **false**. The
  landed fix reads r3 across the tcase, as `nb-rep-go-t` already did.
- *both arms must agree on what they return* — vacuous. Both return `tt-bytes`
  and the checker enforces it anyway.
- *register exhaustion* — confirmed false. `nregs` only sizes the frame.

Three candidate shapes were built to gen3 to establish this. Only the
arms-swapped one failed, reproducing the original signature exactly.

### Why the generation lag exists

`lib/lowering/compile-emit.chiral:295` prepends the compiler's own compiled-in
`native-lib` value to every emitted image. So gen1 carries new compiler *logic*
with the OLD runtime tail; gen2 is the first image whose own `nb-bslice` is new;
gen3 is the first compile performed BY that runtime. G1 and G2 differ at char
3315, just past the ELF headers, which is where the prepended runtime sits.

**Any change to `native-lib` must be verified at gen3.** Two generations of
"compiles fine" is not evidence.

### Still owed

The `j > len` half is untouched: an over-long end still reads past the buffer
and reports the length it was asked for, and `str-starts-with` currently depends
on that read returning differing bytes. Separate change. Still no `E#` minted.
