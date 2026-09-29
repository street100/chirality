---
row: lowering-and-emit/LE27
arc: lowering-and-emit
title: each function erased once
kind: primitive
origin: connect
req: 7
status: draft
updated: 2026-09-29
---

# lowering-and-emit/LE27: each function erased once

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** the back half calls `erase-fn` once per `TFn` that reaches it,
  and the `NFn` that call produced is the one emitted, in def order.
- **Serves:** requirement 7 of [[arcs/lowering-and-emit-arc]], "A compile does
  each piece of its work once, finds a name without scanning a list, and lowers
  only what the entry reaches", in its limb "each function is erased once".
- **Goal:** [[goals/self-hosting]] condition 5 through the arc, and
  [[goals/emitted-speed]] condition 4 over `bin/chirality-bin`, which requirement
  7 serves short of that condition's gate.

## 2. What the tree holds

Measured 2026-09-29 at HEAD `3db3830`, with `LE28` landed at `85bdc0a`.

### The bank first

[[banks/erasure]] row **I**, annotation erasure, is the shard this row touches:
`lib/lowering/tal/erase.chiral` drops the `TalTy` annotations and flattens
`Block`/`TalTerm` into seq-structured code (`docs/banks/erasure.md:86`). The bank
states erasure is no phase (`docs/banks/erasure.md:62-63`); this row changes how
often one IR-to-IR function runs, and no shard's content.

### The live code

| what exists | where | rung | reached by |
|---|---|---|---|
| `erase-fn`, one `TFn` to `XF`, `xf-ok` carrying the `NFn` | `lib/lowering/tal/erase.chiral:182`, `:276-280`; `XF` at `:30` | IMPLEMENTED | `filter-erasable` and `erase-list` |
| `filter-erasable`, the dry-run erase: calls `erase-fn` on every `TFn`, on `xf-err` records `sk-extern op`, on `xf-ok nf` keeps `f` and drops `nf` | `lib/lowering/compile-back.chiral:186-195`; call at `:189`, the drop at `:194-195` | IMPLEMENTED | `lower-defs`' `nil` arm at `:257` |
| `prune-pass` and `prune-fix`, the callee-missing cascade over `(List TFn)`, keeping an in-order subsequence | `lib/lowering/compile-back.chiral:205-213`, `:215-221` | IMPLEMENTED | `lower-defs` at `:258` |
| `erase-list`, the second erase: `erase-fn` again on each survivor, returning `br-ok` with `lits` unchanged and `nil` skips | `lib/lowering/compile-back.chiral:127-135`; `BR` at `:126` | IMPLEMENTED | `lower-defs` at `:259` |
| `lower-defs`' `nil` arm: `filter-erasable` over `(rev-tfn-onto acc nil)`, then `prune-fix`, then `erase-list` | `lib/lowering/compile-back.chiral:257-261` | IMPLEMENTED | `compile-back`'s driver at `:336` |
| `LE28`'s reversed accumulator, one `rev-tfn-onto` in the `nil` arm, so the list `filter-erasable` receives is in def order | `lib/lowering/compile-back.chiral:144`, `:257`, `:274` | IMPLEMENTED | as above |

`erase-fn` reads its two arguments and nothing else (`erase.chiral:276-280`), so
a second call on the same `datas` and `TFn` returns what the first returned.
Nothing outside `compile-back.chiral` calls `filter-erasable`, `prune-fix` or
`erase-list`: a grep over `*.chiral`, `*.prog` and `*.sh` finds one other hit,
the comment at `tools/test/span-over.sh:107-108`, which pins the skip string
`filter-erasable`'s `xf-err` arm produces.

### The measurement

The only figure is the joint prototype of this row and `LE28`
(`.planning/LANGUAGE-PROFILE-2026-09.md:29`, the arc's G7 row at
`docs/arcs/lowering-and-emit-arc.md:123`): compiler blob 0.827 / 0.814 / 0.816 s
to 0.721 / 0.732 / 0.723 s, 385 MB to 331 MB peak, the erase 70 ms and 29.0 MB
to 0.2 ms and 0 MB, output `cmp` equal to `bin/chirality-bin`'s on the compiler
blob, `e170_infer_arms` and `e173_matcher`. The profile's pass table puts the
dry-run erase at 69.2 ms and 29.2 MB, 9.5% of the compile
(`.planning/LANGUAGE-PROFILE-2026-09.md:58`). `LE28` alone, built, measured
0.81 s and 385 MiB to 0.79 s and 358 MiB (the arc's `LE28` row,
`docs/arcs/lowering-and-emit-arc.md:270`). This row's own share is therefore
about 0.79 s to 0.72 s and 358 to 331 MB, by subtraction, estimated; the two
figures mix MB and MiB.

### Names can repeat in the list

Two `TFn`s with one name reach `filter-erasable` and `prune-fix` today: the
duplicate is caught only at emit, by `first-dup-go` at
`lib/lowering/compile-emit.chiral:304-305`, the case requirement 5 of the arc
measures. `prune-pass` judges each `TFn` by its own calls, so it can keep one of
two same-named functions and drop the other.

### Drift from the row's text

- The row cites `filter-erasable` at `:184-193` with the drop at `:192`; they
  are at `:186-195` and `:194-195`, moved by `LE28`. `erase-list`'s call is at
  `:259`, cited `:257`.
- `tools/test/span-over.sh:108` cites `filter-erasable`'s `xf-err` arm at
  `compile-back.chiral:188-191`; it sits at `:190-193`.

## 3. The delta

One thing is missing: the `NFn` from the dry run survives to the end of the
pipeline. Today `:194-195` discards it and `:259` recomputes it for every
survivor of `prune-fix`. Nothing else moves: the skip records, their order, the
`BR` the `nil` arm returns, and the order of the emitted `NFn`s all stay what
they are.

**Verdict:** a real delta, one file, one pass.

## 4. The shapes

### Shape A: the pair travels through prune

- **Form:** `filter-erasable` returns `(List (Pair TFn NFn))` for the kept
  functions. `prune-pass` and `prune-fix` take and return that list, reading
  the `TFn` half for `block-calls`, the name and the count. The `nil` arm
  projects the `NFn` halves in order and builds `(br-ok nfns lits skips)`
  directly. `erase-list` loses its only caller and is deleted.
- **Costs:** the signatures of `filter-erasable`, `prune-pass` and `prune-fix`
  change, plus two monomorphic helpers (the name list and the count over pairs,
  or one projection to `TFn`s) and one projection to `NFn`s. All inside
  `compile-back.chiral`, with no caller elsewhere.
- **Forbids:** a kept `NFn` belonging to any `TFn` other than its own. The
  pairing is held by the list's element type. Wanted.

### Shape B: parallel lists and a paired walk

- **Form:** the row's text. `filter-erasable` returns kept `TFn`s and, beside
  them, their `NFn`s. `prune-fix` is untouched. After it, a walk over the kept
  `TFn`s, their `NFn`s and the pruned `TFn`s emits an `NFn` wherever the pruned
  head matches the kept head.
- **Costs:** prune stays as it is. The walk needs a match test. `TFn` carries no
  identity beyond its fields, so the test is a name compare, or a structural
  compare of whole bodies, which costs a second walk per function of the size
  this row removes.
- **Forbids:** nothing it should. With the name compare, two same-named `TFn`s
  where prune keeps the second pair the second's `TFn` with the first's `NFn`,
  and emit then sees one label and no duplicate, so the wrong body ships
  silently. §2 shows the input exists today. The row's correctness argument
  (pure erase, in-order subsequence) holds; its match test does not carry it.

### Shape C: prune over the erased form

- **Form:** erase first and keep only `NFn`s; `prune-fix` reads calls from the
  erased code.
- **Costs:** a second call reader over `NFn` code, and an argument that it finds
  the same callee set `block-calls` does, which no measurement supports.
- **Forbids:** nothing wanted, and it moves prune's authority to a new IR for no
  gain over Shape A.

## 5. The call

- **Chosen:** Shape A. It is the only shape whose correctness is carried by the
  type: the `NFn` cannot part from its `TFn`. Shape B is correct only where names
  are unique, which the tree does not hold before emit (§2); Shape C adds an
  unmeasured equivalence.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | pair through prune, or parallel lists matched after | RESOLVED | Shape A; the duplicate-name input is measured at `lib/lowering/compile-emit.chiral:304-305` and requirement 5 of the arc |
| 2 | order of the emitted `NFn`s | RESOLVED | def order, unchanged: `filter-erasable` and `prune-pass` each rebuild by `cons` in input order (`compile-back.chiral:194-195`, `:209-210`), and the input is `LE28`'s single reverse at `:257` |
| 3 | does enforcement requirement 7's checked rewrite apply | RESOLVED, no | `docs/arcs/enforcement-arc.md:471` reaches a rewrite the optimizer adopts. This row rewrites no function and moves no emitted byte, so the BUILD RULE converging at `C1 == C2` is the whole check (`docs/definitions/working-discipline.md:19-33`, `:35-41`) |
| 4 | `erase-list`'s `br-err "erase: "` path | RESOLVED | it is dead under today's code, since every `TFn` it sees already erased once and `erase-fn` is pure (`erase.chiral:276-280`); deleted with the function |
| 5 | does the row go `direct` | RESOLVED, yes | the shapes differ and §5 takes one here; what remains for a SPEC is the diff itself, one file, with the BUILD RULE as its gate, the same footing `LE28` built on |

No NEEDS-AUTHOR.

## 6. The mint packet

- **Elements:** one. The dry run keeping its result and the second erase going
  away are one change: neither stands without the other.
- **Band:** `UNASSIGNED`. The arc holds no reserved block
  (`docs/arcs/lowering-and-emit-arc.md:34`).
- **Catalog row:**
  ```
  | E<NN> | **Each function erased once**: `filter-erasable`'s dry-run erase keeps each `NFn` paired with its `TFn` through `prune-fix`, and the kept `NFn`s are emitted in def order; `erase-list` and the second `erase-fn` per function are deleted | Not built. `lib/lowering/compile-back.chiral`, `lower-defs`' `nil` arm | `lowering-and-emit/LE27`, `.planning/LANGUAGE-PROFILE-2026-09.md` rank 3 (internal) | SH |
  ```
- **Ledger row:**
  ```
  | E<NN> | compile-back | design | Erase once: the dry run's `NFn` paired with its `TFn` through prune; the second erase deleted. Check: BUILD RULE `C1 == C2`, then the suite | `lowering-and-emit/LE27` | SH |
  ```
- **Size:** one file, `lib/lowering/compile-back.chiral`. About 30 lines touched
  and about 10 removed net: three signatures, two or three small helpers, the
  `nil` arm, and `erase-list` (`:127-135`) deleted. Basis: the functions in §2
  total 43 lines and the prototype carried the same change.
- **Check, as the build runs it:** blob regenerated, `C1` and `C2` built from
  it, each non-empty before `cmp`, `C1 == C2`; `C2` compiling the blob
  reproduces the prior `bin/chirality-bin` byte for byte; the suite on `C2`
  before promotion. A sampled self-compile re-reads requirement 7's figure and
  gates nothing.
- **Related:** [[arcs/lowering-and-emit-arc]], [[banks/erasure]],
  [[arcs/enforcement-arc]].

### Residue

**Needed and unrostered.**

| need | why | where it would go |
|---|---|---|
| repoint `tools/test/span-over.sh:108`'s citation of `filter-erasable`'s `xf-err` arm | stale since `LE28` at `:188-191` against `:190-193`, and this row moves it again | whichever row owns `span-over.sh`, or folded into this row's build |
| repoint the row's own cited lines and the G7 row at `docs/arcs/lowering-and-emit-arc.md:123` after the build | both cite `:184-193` and `:192` | clerical, at the build's roster update |
