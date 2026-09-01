# Primitives owed before `tools/` can be chirality

**2026-08-31.** Route step 1 is "replace the Python tools with chirality programs
and delete `tools/`." This is the measured gap between that goal and the floor as
it stands, taken from actually writing one of them (`prog/prose-lint.prog`)
rather than from reading the list.

Method: every row below was checked against the tree, not recalled. A row that
says BUILT names the extern or def that provides it.

## What already exists

Most of it. This is the short answer to "why not write the tools in chirality":
almost nothing was missing, and I reached for shell out of habit.

| need | provided by | where |
|---|---|---|
| read a file by path | `openat` → `read-fd-all` | `crossing-wraps.chiral:20`, `compile-all.chiral:47` |
| read stdin | `read-fd-all 0` | same |
| write a file | `open-create` + `write-fd` (E105) | `file.port:15`, `fd.port:35` |
| write stdout / stderr | `put`, `print`, `trace` | `stdio.port:10-12` |
| substring search | `str-find`, `str-find-from` (primitive, → `nb-bfind-from`) | `prelude.chiral:81-82` |
| slice, length, concat | `str-sub`, `str-len`, `str-cat` | `prelude.chiral:80,75,83` |
| bytes | `blen`, `bget`, `bslice`, `bcat`, `str->bytes`, `bytes->str` | `prelude.chiral:88-95` |
| integer formatting | `i64->str` | `prelude.chiral:84` |
| integer division | `/` | `prelude.chiral:61` |
| split, trim, pad, case-fold | `str-split`, `str-trim`, `str-pad`, `str-lower` | `prelude/string.chiral` |
| sorting, with a caller's comparator | `list-sort` (E152), `list-dedup-adj` (E156) | `prelude/list.chiral` |
| ordered map / set | `m-insert`, `m-lookup`, `m-fold`, `s-add` (E27) | `prelude/map.chiral`, `prelude/set.chiral` |
| exit code | `compile-main : (=> I64 I64)`'s return | every `.prog` |

So a tool that takes its inputs on stdin, computes, prints, and exits with a
status is fully expressible **today**.

## What is missing

Three things, and only the third needs minting.

### 1. Directory enumeration — **E148**, minted, `design`, not built

`getdents64` (nr 217) + `stat`/`statx`. Zero occurrences in the tree.

This is the one that bit. Without it a tool cannot find its own inputs, so every
tool that walks a corpus needs the list handed to it. The catalog already counts
its standing workarounds as the justification, and the count is now **four**:

| workaround | where |
|---|---|
| scriba's flook/dired, 264 lines written and inert | `prog/scriba/flook.chiral` |
| the manas setup library's `index.json` enumeration | `SCRIBA-STATE.md` P4 |
| `test-runner`'s bundled manifest | `test-runner.chiral:7` |
| **`prose-lint` reading a path list on stdin** | `prog/prose-lint.prog` (new, 2026-08-31) |

E149 (`fs-mut`: `unlink` + `rename` + `mkdir`) is split from it on purpose and is
NOT needed for the tools. None of them mutates the tree.

### 2. `argv` — **E150**, minted, `design`, not built

Scope was corrected 2026-08-22 and the correction matters here: the capability
**already exists** via `/proc/self/cmdline` over the existing `openat` + `read`,
with zero new crossings, proven by a 15-line probe. What is owed is the pure
wrapper `argv : (=> Unit (List Str))` plus the entry-stack route for targets with
no `/proc`.

Without it every tool is stdin-driven and no tool can take a flag. `prose-lint`'s
six subcommands (`--summary`, `--baseline`, `--regress`, …) have nowhere to live
in the native version, which is why it has none.

`E80-cap-to-main-SPEC.md` decision #2 already settled that argv is input rather
than authority, so this is not a capability question.

### 3. A matcher — **E173**, minted by this document

Everything a check needs beyond a literal substring. `prose-lint`'s shell version
has three checks its chirality version cannot express, and they are printed as
NOT-CHECKED on every run rather than dropped:

- `not-but` — `not <word> but`, a literal with a hole in the middle
- `parallel-no` — `no <word>, no <word>`
- code-skipping — "outside a fenced block, outside `inline spans`", which is a
  state machine over lines rather than a search

The literal-only workaround also costs 13 lines of `cons` chains spelling
alternations that a matcher gives for free, and it forces a full-buffer scan per
needle: 31 passes over 7 MB where one pass would do. That is why the native
version is 2.4x slower than the awk one. The algorithm is the cost, not the
compiled code.

**Deliberately not "regex".** A backtracking regex engine has unbounded cost, and
P2 says a process's cost is its type. The shape that fits is a total matcher with
a bounded arrow, which is a real design question and is what the element is for.

## The rows minted here

Per the deferral rule, nothing above is deferred to an element that does not
exist. E148 and E150 were already minted. E173 is minted by this change, in
`SELF-IMPLEMENT-CATALOG.md` and in `LEDGER.md` §VAL, in the same commit.

## What this does NOT block

`prose-lint` needed none of the three to be useful, and neither do most of the
tools. The ranking, the baseline file, the regress comparison, and code-skipping
are all ordinary work on top of what exists. `paren-audit` and `syscall-map` read
files whose paths are already known. The blocked ones are the corpus walkers:
`ledger-lint`, `frontier`, and `doc`.
