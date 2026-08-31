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
