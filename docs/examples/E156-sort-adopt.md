---
element: E156
slug: sort-adopt
title: **`row-infer` adopts the sort owner** — replace its private `ins-sorted`/`sort-dedup` (`row-infer.chiral:106,117`) with `list-sort` from `collections`.
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: drafted
updated: 2026-08-23
---

# E156 — **`row-infer` adopts the sort owner** — replace its private `ins-sorted`/`sort-dedup` with `list-sort` from `collections`.

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E156 — the **consumer migration** that makes E152's ownership real.
  E152 gave `List` sorting an owner (`list-sort`, `scaffold/lib/collections.chiral:397`);
  E156 is the half where a consumer actually adopts it. `row-infer` currently carries
  a private fused insertion sort: `ins-sorted` (`scaffold/lib/row-infer.chiral:93`)
  and `sort-dedup` (`:104`), reached through the single call site `row-of` (`:109`),
  which is itself called once, from `infer-row` (`:142`).
- **Kind:** BUILD-PROPER.
- **Why chirality needs its own:** *an owner nothing adopts is only half the ownership
  fix* — the a/b shape E151 needed (E151a added canonical `str-cmp`; E151b retires
  the copies). E152 is that shape's first half and E156 its second. The element was
  minted rather than left as loose residue precisely because of the deferral rule:
  a named follow-on gets a row in the same change, or it is a phantom dep.
- **The design content that earns the pipeline** (per the amended criterion — an
  element takes the pipeline iff implementing it requires *choosing* between shapes
  the codebase does not already settle): `sort-dedup` **fuses** sorting with
  de-duplication. Splitting it onto `list-sort` forces a question the fused code
  never had to answer — **which duplicate survives, the first or the last** —
  because `list-sort` is *stable*, which makes the distinction visible without
  settling it. A naive migration picks one silently. §4 and §5 settle it out loud.

## 2. Research

- **Reference class:** `OURS` — the port source is our own tree, read directly:
  `scaffold/lib/row-infer.chiral:93–109`, `scaffold/lib/collections.chiral:162,397`,
  `scaffold/tests/samples/e152_list_sort.chiral`, plus the two sibling fused
  sort/dedup sites found while scoping (`closconv.chiral:39`, `compile-back.chiral:116`).

**Load-bearing findings.**

1. **The current code keeps the LAST duplicate — as an accident of recursion order.**
   `sort-dedup` sorts the *tail* first and then inserts the head
   (`row-infer.chiral:106`: `(ins-sorted x (sort-dedup r))`), while `ins-sorted`'s
   `(eq)` arm returns `(cons y r)` (`:99`) — dropping the *newly inserted* `x` and
   keeping the `y` already in the accumulator. Since the accumulator was built from
   elements that appear *later* in the input, the survivor is the **last** input
   occurrence. Nothing in the code says so; no comment claims it; it is emergent.
   That is the sharpest argument for the split: a fused op can hold a decision
   nobody ever made.

2. **`list-sort` is stable, and the E152 suite already proves stability is
   observable through a non-injective comparator.**
   `scaffold/tests/samples/e152_list_sort.chiral:151` sorts `(Pair I64 Str)` by key
   alone and asserts the tag order `"b,d,a,c,e"` — equal keys, distinguishable
   payloads, input order preserved. So for a comparator whose `(eq)` does *not*
   imply value equality, first-vs-last is a genuinely different answer. The choice
   must be settled in the generic contract even where today's call site cannot see it.

3. **The tree already has a keep-FIRST dedup convention.** `compile-back.chiral:84,113`
   documents `dedup-str` as "first-occurrence dedup"; `closconv.chiral:38,107`
   describes its accumulator as "sorted-unique … sorted ascending, deduplicated".
   Keep-first is also the ambient convention outside chirality (C++ `std::unique` keeps
   the head of each run, Haskell `nubBy`, `dict.fromkeys`). Nothing in-tree keeps last
   on purpose — `row-infer` only does so by accident (finding 1).

4. **E151b has ALREADY LANDED, so there is no sequencing question at all.**
   ⚑ *Corrected at the example audit, 2026-08-23, against the live file.* The draft
   said `row-infer.chiral:35` still holds an ad-hoc `str-cmp` copy that E151b will
   retire, and reasoned about which element should land first. It does not:
   E151b shipped 2026-08-22, and `row-infer.chiral:17` now reads
   `(import "string-utils")   ; E151b: the owner of str-cmp (and, via collections, of Ord)`
   with a comment at `:19` recording that the comparator *used to be* inlined. The
   `str-cmp` this element composes with `list-sort` is therefore **already the
   canonical one**, and half the ownership fix for this file is already done.
   Separately, `row-infer` imports `row-join`, "dedup union", from `effects`
   (`row-infer.chiral:16`) — a *third* de-duplicator reachable from this one file,
   out of scope here but noted in §6.

## 3. Conventional (other-language) approach

Outside chirality, "sorted unique" is one call, and the survivor question is answered
by a footnote in the manual — or not at all.

```python
row = sorted(set(names))          # survivor: whichever set() happened to retain
row = sorted(dict.fromkeys(names))  # survivor: first — but only incidentally
```

```cpp
std::sort(v.begin(), v.end());                      // NOT stable
v.erase(std::unique(v.begin(), v.end()), v.end());  // keeps the head of each run
```

- **Assumptions it bakes in:** that de-duplication is a *property of the container*
  (`set`) rather than a decision about a comparator; that equality and comparison
  agree, so "which duplicate" is a question with no observable answer; that an
  unstable sort is an acceptable default, which makes the question unanswerable
  rather than merely unasked; and that fusing the two operations costs nothing —
  when in fact the fusion is exactly what conceals the decision.

## 4. The chirality idea

- **Chirality features in play:** module **ownership** (a module is individuated by its
  type, not its subject — there is no "stdlib" bucket to dump a sort into); QTT-erased
  type params `(0 A (type 0))`; the `->` purity membrane; totality by structural
  recursion; and principle 6 — *an abstraction must constrain behavior or it is overhead*.
- **The reframing.** The conventional move is to port `sort-dedup` to a generic
  `list-sort-dedup` and call it done. chirality refuses that: it would relocate the
  fusion rather than dissolve it, and a fused convenience wrapper constrains nothing.
  Instead the fused private op **splits into two owned ops**, composed at the call site:
  `list-sort` (already owned, E152) and **`list-dedup-adj`** (new, landing beside it
  in `collections`). Each has one job, each states its contract, and the contract that
  was previously emergent becomes written down.
  The split also stops E156 from repeating the very failure it exists to fix: leaving
  a private *dedup* helper behind in `row-infer` would swap "row-infer owns a sort" for
  "row-infer owns a dedup" — half the fix again, a third time.
- **The decision, settled: `list-dedup-adj` KEEPS THE FIRST of each run.**
  Three reasons, in weight order:
  1. **It is the only rule that composes with stability into a one-sentence spec.**
     `list-sort` is stable, so an `(eq)`-run appears in input order; keeping its head
     means the pipeline reads *"the stable sort's answer, with later duplicates
     deleted."* Keep-last would make the result depend on run *length* as well as
     order, and no sentence describes it.
  2. **It matches the in-tree convention** (`compile-back.chiral:84,113` first-occurrence
     dedup) and the universal external one (finding 3). Keep-last is in the current code
     only as an accident of recursion order (finding 1) — there is no incumbent
     behavior to preserve, only an incumbent accident to stop inheriting.
  3. **It is the cheaper shape:** keep-first emits each survivor as it is met, one
     comparison per adjacent pair and no lookahead; keep-last must carry a pending
     candidate through the whole run.
- **The observable consequence for `row-infer`'s callers: none, today — and saying so
  is part of the deliverable.** The live comparator is `str-cmp` on `Str`, whose `(eq)`
  *does* imply value equality, so the first and last occurrences are the same value and
  `row-of`/`infer-row` return identical lists either way. Its one importer
  (`sig-driver.chiral:23`) cannot observe the change. This is what makes E156 a *safe*
  refactor with a byte-identical golden (§6) — and it is exactly why the choice must be
  argued rather than discovered: it is free to get right now and expensive to discover
  later, the first time someone passes `list-dedup-adj` a key-projection comparator like
  the one `e152_list_sort.chiral:151` already tests.
- **What chirality makes impossible here:** you cannot smuggle the survivor rule in as an
  implementation detail. The comparator is a *parameter* of an owned, generic function,
  so `(eq)` is whatever the caller says it is and the function must declare which
  witness of an `(eq)` class it returns. There is no `set` to hide behind, no ambient
  equality, and — both functions being `->` — no way to make the tie-break depend on
  anything outside the arguments.

## 5. Chirality example (fleshed)

```chirality
; ================= scaffold/lib/collections.chiral — beside list-sort (E152)

; list-dedup-adj: drop every element that is (eq) to its IMMEDIATE PREDECESSOR.
; Binder order matches list-sort exactly -- (0 A) type, comparator, list -- so the
; two compose with no adapter and the arg-order convention E151b already refused to
; relitigate stays put.
;
; CONTRACT. This is `uniq`, NOT `sort -u`: on an unsorted list it compresses runs
; only. De-duplication is GLOBAL solely as the COMPOSITION with list-sort, and only
; because a sort groups (eq) elements adjacently.
; SURVIVOR: the FIRST element of each run. Composed after the STABLE list-sort, that
; is the earliest occurrence in INPUT order. (E156 §4; the fused ins-sorted this
; replaces kept the LAST, by accident of recursion order, observably never.)
(declare list-dedup-adj (-> (0 A (type 0)) (-> A A Ord) (List A) (List A)))
(def list-dedup-adj
  (lam (A cmp xs)
    (case xs
      (nil nil)
      ((cons x r) (cons x (dd-skip A cmp x r))))))     ; x survives; drop its run

; dd-skip: emit ys with every (eq)-to-`keep` element removed, opening a new run at
; each survivor. `dd-` matches the `ms-` internals convention of list-sort (and the
; flat-label workaround, E154). Structural recursion on ys => total (E11), no fuel.
(declare dd-skip (-> (0 A (type 0)) (-> A A Ord) A (List A) (List A)))
(def dd-skip
  (lam (A cmp keep ys)
    (case ys
      (nil nil)
      ((cons y r)
        (case (cmp keep y)
          ((eq) (dd-skip A cmp keep r))                ; duplicate: DROP the later one
          ((lt) (cons y (dd-skip A cmp y r)))          ; new run opens at y
          ((gt) (cons y (dd-skip A cmp y r))))))))     ; unsorted input: same move

; ================= scaffold/lib/row-infer.chiral — replacing :93-109

(import "collections")   ; list-sort (E152), list-dedup-adj (E156), Ord
; str-cmp is ALREADY the canonical one: E151b (built 2026-08-22) retired this file's
; local copy, and :17 imports string-utils for it. Nothing about the comparator is
; owed here -- half the ownership fix for row-infer is done, and this is the other half.

; row-of: the canonical row -- drop the dynamic marker, sort, compress runs.
; WAS (:109): (sort-dedup (drop-dyn xs)), a private fused insertion sort whose
; dedup rule nobody had chosen. Same result for str-cmp; now it is a stated one.
(def row-of (-> (List Str) (List Str))
  (lam (xs)
    (list-dedup-adj Str str-cmp
      (list-sort Str str-cmp (drop-dyn xs)))))

; ins-sorted (:93) and sort-dedup (:104) are DELETED, not left dead -- retiring the
; duplicate is the deliverable, exactly as in E151b. row-of was their only caller.
```

- **Knobs to modify:** the element type and its comparator (`Str`/`str-cmp` here;
  `list-dedup-adj` is generic over both). A caller wanting keep-*last* does not get a
  flag — it reverses the list, dedups, and reverses back, which is the honest cost of
  asking for the non-composing rule. A caller wanting *global* dedup on an unsorted
  list without reordering wants `compile-back.chiral:116`'s tree-set `dedup-str`, not
  this.
- **Deliberately omitted:** a fused `list-sort-dedup` convenience (it would restore the
  concealment this element exists to remove); any change to `row-join`'s dedup-union
  (`effects.chiral`, see §6); `closconv.chiral:39`'s `ins-uniq`; and any counting or
  multiplicity variant (`group`/`run-lengths`) — nothing needs one.

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/collections.chiral` (new `list-dedup-adj` + `dd-skip`,
  beside `list-sort`) and `scaffold/lib/row-infer.chiral` (rewrite `row-of`, delete
  `ins-sorted` + `sort-dedup`). Nothing else. **Scope call:** the new function lands in
  `collections`, inside E156, rather than being deferred — E156 *is* the adoption
  element, and adopting an owner while keeping a private generic helper is the same
  half-fix twice. If the author instead wants it minted separately, the deferral rule
  applies: a catalog row + ledger row in the same change, never a bare "follow-on".
- **Conformance target (golden):** `infer-row` returns a **byte-identical** list to the
  pre-change implementation for every input — sorted ascending by `str-cmp`, no
  adjacent duplicates. `row-infer` is not in the compiler blob, so there is **no
  fixpoint obligation**; the gate is the sample-test suite plus its one importer,
  `sig-driver.chiral:23`. New tests belong on `list-dedup-adj` itself, where the
  survivor rule *is* observable: mirror `e152_list_sort.chiral:151`'s key-projection
  comparator over `(Pair I64 Str)` and assert the surviving tags are the first of each
  key-run. (A test that only uses `str-cmp` cannot fail the decision this element makes.)
- **Open questions (for the spec stage):**
  1. Does `row-join` — "dedup union", `effects.chiral:23`, imported at
     `row-infer.chiral:16` and also used by `eff-lower.chiral:46,52` — become a consumer
     of the owner too, or does a union over an accumulator stay its own linear scan?
     (It is the third de-duplicator in this one file; E156 does not touch it.)
  2. `closconv.chiral:39`'s `ins-uniq` is a second private fused sorted-unique insertion
     — the same shape over `(List I64)`. Does E156 grow to cover it, or does it need its
     own adoption row? Related: the ledger's claim that `ins-sorted` was "the only sort
     in the tree before E152" appears **false** — `ins-uniq` is an insertion sort too.
  3. The catalog/ledger row cites `row-infer.chiral:106,117`; the live lines are **93**
     (`ins-sorted`) and **104–105** (`sort-dedup`), with `row-of` at 109. Should E156
     correct the row's citation as part of its change?
- **Related:** [[E151-ord-dedup]] (the a/b precedent; its b-half already retired this
  file's `str-cmp` copy, so E156 is the same move one helper over)
  · E152 (`list-sort`, the owner being adopted — skipped the pipeline by the
  settled-shape criterion) · E154 (the flat-label prefix convention `dd-`/`ms-` follows)
  · E11 (totality — structural recursion) · [[E141-golden-conformance]] (the
  byte-identical golden this element's gate leans on).
