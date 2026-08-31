# X1 — the coordinate, measured

**2026-08-22.** Output of X1 in `HARNESS-REFACTOR-CHECKLIST.md`: derive each lib
module's position on the three axes of `banks/module` §1 (typeability A/B/C ·
altitude upper→tal→metal · port-set). Measured over the real tree, symlinks
excluded so the A3 symlink web is not double-counted.

## ⚑ Four corrections to numbers I stated earlier in this session

| I said | actually | why I was wrong |
|---|---|---|
| 89 lib modules | **134** | `ls scaffold/lib/*.chiral` counts only the top level; `manas/`, `scriba/` etc. are subdirectories |
| 8 of 89 have a non-empty port set | **8 declare their own crossings; 63 of 134 REACH one** | I measured *own* `(=> )` externs and called it the port set |
| 4 root programs | **22** | 18 `manas/**/*-test` roots, all defining `compile-main` |
| 10 prose-annotated | **6** | my earlier `grep -l` pattern was broader than the annotation |

## ⚑ And one of those flips a recommendation

I told the author *"every axis is ~90% one value, so a suffix carries almost no
information — mark the exceptions and leave the default unmarked."*

**That is wrong for the port-set axis.** Measured transitively it is
**71 empty / 63 non-empty** — a ~53/47 split, which is the *most* informative
division available, not the least. "Mark the exceptions" was reasoning from a
number I had mismeasured. The altitude axis IS skewed (120/10/4) and the
exception-marking argument holds there.

## The measurement

**Port-set axis.** Note the honest bound — the precise answer is not computable today:
- **8** modules declare their own crossing (`(=> )`) externs:
  `ports` 33 · `proc` 2 · `resolve` 2 · `test-runner` 2 · `secret` 1 · `self-wield` 1 · `supervisor` 1 · `term` 1
- **63 of 134** *reach* a crossing through the import graph.
- The truth is between the two: importing a module that holds crossings does not
  mean *using* them. Resolving it needs per-def reachability — which is exactly
  what `row-infer.chiral` computes and exactly what **is not in the compiler**
  (measured this session; `infer-row`/`row-of`/`RowSig` are zero in the blob).
  **So adopting row-infer is the prerequisite for this axis being derived rather
  than guessed.** Do not pick either bound and call it the coordinate.

**Altitude axis** (heuristic, by module name — needs a real rule):
`upper` 120 · `tal` 10 · `metal` 4.

**Entry** (defines `compile-main`) — 22, and they split into two obvious groups:
- 4 tools: `compile-driver`, `resolve`, `self-wield`, `test-runner`
- 18 tests: `manas/**/*-test`

That 18 is itself a finding: a *test root* and a *tool root* are plainly different
things wearing the same shape, and nothing distinguishes them. It is the same gap
as a sample's expected exit code living in `test-runner`'s manifest instead of in
the sample.

**Typeability A/B/C** — NOT derived, and not derivable. `axis-typeability`'s test is
*"what does its correctness rest on"*: proof / an admitted untypeable hole /
cross-checked evidence about a hole. That is a judgment. Six modules state it in
prose (`prelude`, `ports`, `pretty`, `collections`, `string-utils`, `target-linux`);
the other 128 must be authored. **This is the expensive part of X1 and it cannot be
automated.**

## What X1 still owes

```
[ ] adopt row-infer into the compiler   -> makes the port-set axis derived, not guessed
[ ] a real altitude rule                -> name-prefix heuristic is not a rule
[ ] author typeability for 128 modules  -> the irreducible manual part
[ ] decide: is "test root" vs "tool root" a fourth mark, or a property of the entry?
```

Raw per-module data: `/tmp/coord.json` (regenerate; not committed).
