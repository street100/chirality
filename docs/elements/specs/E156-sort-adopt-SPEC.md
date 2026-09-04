---
element: E156
slug: sort-adopt
title: **`row-infer` adopts the sort owner** — retire its private `ins-sorted`/`sort-dedup` in favour of `list-sort` + a new `list-dedup-adj`, both owned by `collections`
kind: BUILD-PROPER
example: examples/E156-sort-adopt.md
status: audited
updated: 2026-08-23
---

# E156 SPEC — `row-infer` adopts the sort owner

> ⚑ **TRIAGE 2026-09-04 — DONE-ALREADY.** 0 of 6 steps are executable at HEAD.
> `lib/prelude/list.chiral:186` carries `list-dedup-adj`;
> `tools/test/samples/e156_dedup_adj.prog` exists. Step 4's Phase number is
> owed, not free. Bucket and evidence: `records/spec-tier-triage.md`. This
> file was not rewritten and its `status:` was not changed.

> Implementation contract produced by the `example-to-spec` run.
>
> **Authority order for this file:** live CODE > the reviewed example
> (`examples/E156-sort-adopt.md`) > the catalog/ledger rows. Every disagreement
> found while writing this spec is recorded in **§6.4**, not silently reconciled.
> Four of them are load-bearing: `collections` **is** a compiler source (so the
> fixpoint obligation applies), **nothing in the tree compiles `row-infer`**, the
> Python oracle that used to is **already red at HEAD**, and the sample that gates
> E152 is **run by no automated phase**.

---

## 1. Deliverable

**After this runs:** `scaffold/lib/collections.chiral` owns
`list-dedup-adj : (-> (0 A (type 0)) (-> A A Ord) (List A) (List A))` — a pure,
total, comparator-passed adjacent-run compressor whose **survivor rule is
written down: the FIRST element of each `(eq)` run** — and
`scaffold/lib/row-infer.chiral` has **no private sort and no private dedup left**:
`row-of` is `(list-dedup-adj Str str-cmp (list-sort Str str-cmp (drop-dyn xs)))`,
and `ins-sorted` / `sort-dedup` are **deleted**. A new native gate
(`run-native.sh` Phase 9) compiles and runs both — including the **first
automated compile+run of `row-infer` in the tree's history** — and pins the
survivor rule through a key-projection comparator where it is observable.

**Non-goals (residue homes in §6):**

- **No fused `list-sort-dedup` convenience.** It would relocate the concealment
  this element exists to remove (example §5, "deliberately omitted").
- **No change to `row-join`** (`effects.chiral:23`). Decision D2 resolves it as a
  *different operation*, not a de-duplicator — see §3.
- **No change to `closconv.chiral:39`'s `ins-uniq` or `compile-back.chiral:116`'s
  `dedup-str`.** Decision D3 defers both to **E165, whose catalog + ledger rows
  this change mints in Step 0** — the deferral rule admits no bare follow-on.
- **No keep-*last* variant and no survivor flag.** A caller wanting keep-last
  reverses, dedups, reverses back; that is the honest cost of the non-composing
  rule (example §5, "knobs").
- **No repair of the Python oracle floor.** It is already red at HEAD for reasons
  that predate E156 (§6.4 finding 3); E156 neither fixes nor worsens it, and
  must not be reported as if it did.

---

## 2. Baseline (what already exists)

**Conformance-map verdict:** none — E156 postdates the map snapshot; the pack
prints `(none — treat as BUILD)`. The build-state authority is therefore the
ledger rows (`docs/elements/ledger.md:275` E152 `built`, `:276` E156 `design`) plus
the live code below, each line re-read and, where it mattered, **run**.

**Live code this composes with — do NOT respec it:**

| shard | home | state |
|---|---|---|
| `list-sort` — comparator-passed, **stable**, pure `->`, top-down merge sort | `collections.chiral:397-399` | ships (E152) |
| `ms-take` / `ms-drop` / `ms-merge` / `ms-sort-n` — the E154-prefixed internals `dd-skip` copies the convention of | `collections.chiral:352-395` | ships |
| `Ord = (lt)/(eq)/(gt)` — **owned by `collections`**, not by `string` | `collections.chiral:162` | ships |
| `str-cmp : (-> Str Str Ord)` — byte-wise, so `(eq)` implies value equality on `Str` | `string-utils.chiral:91-92` | ships (E151a) |
| `row-infer` already imports the canonical `str-cmp` | `row-infer.chiral:17` | ships (E151b, 2026-08-22) |
| `drop-dyn` — discards the `"*"` marker before canonicalisation | `row-infer.chiral:85-91` | ships, untouched |
| `infer-row` — the one consumer of `row-of` | `row-infer.chiral:140-142` | ships, untouched |
| `e152_list_sort.chiral:151` — the key-projection comparator `ls-t-key` over `(Pair I64 Str)` whose `(eq)` does **not** imply value equality | `scaffold/tests/samples/` | ships. **Run by no automated phase** — §6.4 finding 4. 2026-09-04: the 2026-08-31 migration moved the tree out of scaffold/. The pre-migration paths kept here name no live directory. |
| `run-native.sh` Phases 1–8, and the four helpers of `test-module-kind.sh` | `scaffold/tests/` | ship. 2026-09-04: pre-migration scaffold/ path. |

**The incumbent, exactly as it stands (re-read; the catalog's `:106,117` is drift):**

```
row-infer.chiral:93-102   (declare/def ins-sorted (-> Str (List Str) (List Str)))
row-infer.chiral:104-106  (declare/def sort-dedup (-> (List Str) (List Str)))
row-infer.chiral:108-109  (def row-of ... (lam (xs) (sort-dedup (drop-dyn xs))))
```

`row-of` is `sort-dedup`'s only caller; `infer-row` (`:142`) is `row-of`'s only
caller; `sig-driver.chiral:23` is `row-infer`'s only importer.

**Measured baselines (2026-08-23, `scaffold/build/B1`, zero Python):**

| probe | result |
|---|---|
| `bash tools/test/run-tests.sh` | **exit 0** — Phase 1 6, Phase 2 test-runner 0 (6 samples), Phase 3 7, Phase 4 31, Phase 5 12, Phase 6 21, Phase 7 81 roots compiled / 0 failed / 12 known, Phase 8 44. **121 assertions + 81 roots** |
| `chirality_blob scaffold/lib row-infer` + a `compile-main` probe, `B1` | compiles **rc 0**, ELF **exit 42** — `infer-row` over a fixture with a duplicate callee and a `"*"` returns `["put"]`. This is the golden Step 4 pins, and it is the **first** time anything in the tree compiled `row-infer`. 2026-09-04: pre-migration scaffold/ path. |
| the incumbent's survivor rule, generalised to `(Pair I64 Str)` + a key comparator | ELF **exit 42** asserting tags `d,c,e` — the incumbent really keeps the **LAST** of each run |
| the proposed `list-sort` ∘ `list-dedup-adj` on the same input | ELF **exit 42** asserting tags `b,a,e` — keep-**FIRST**. The two rules are distinguishable by a runnable program, and the mutant is the shipped incumbent |
| `row-join (cons "x" (cons "x" nil)) nil` | ELF **exit 42** asserting `x,x` — `row-join` does **not** de-duplicate its own first argument (D2's evidence) |
| `python3 -m unittest discover -s tests` | **348 ran, 23 failures, 318 errors** — already red at HEAD. `test_row_infer_chirality.py` and `test_collections.py` both die in `setUpClass` with `prelude.chiral:15: unknown toplevel form module` (`chirality/surface.py:218`). 2026-09-04: cut Python oracle, no live successor. |

**True delta:** two new defs in `collections` (~18 lines), a three-line rewrite of
`row-of` plus one import line and a 17-line deletion in `row-infer`, one new
runtime sample, one new gate script, and one new `run-native.sh` phase — plus
Step 0's minted E165 rows and Step 5's citation correction.

---

## 3. Decisions

Every open question from the example §6 and every question the code raised while
writing this spec, dispositioned. No silent design calls.

| # | Question | Disposition | Rationale / owner |
|---|---|---|---|
| **D1** | Does `list-dedup-adj` land in `collections` **inside E156**, or become its own element? | **RESOLVED — inside E156.** | Three citations, none of them taste. (a) The **deferral rule** (`CLAUDE.md`, "no defer without a cataloged dep") makes a separate element cost a minted catalog+ledger row for a ~18-line function whose only consumer is this element's own change — the row would be born and closed in the same session. (b) The **half-fix argument is the element's whole reason to exist**: `docs/elements/ledger.md:275` records E152 as *"adding the owner is the element; the conversion is separate"*, and E156 **is** the conversion; a conversion that leaves a private generic *dedup* in `row-infer` has swapped "row-infer owns a sort" for "row-infer owns a dedup". (c) `docs/elements/ledger.md:274` (E151b) states the finished shape as *"`str-cmp` … now each have **exactly one definition**"* — leaving a private dedup behind reproduces the exact defect E151b just cleared from this same file. |
| **D2** | Does `row-join` (`effects.chiral:23`, "dedup union", used at `row-infer.chiral:16` and `eff-lower.chiral:46,52`) adopt the owner too? | **RESOLVED — NO, and no follow-on element is owed.** | It is not a de-duplicator. Read at `effects.chiral:23-26`: it takes **no `Ord`**, consults **`mem-str`** (equality, not comparison), **preserves the caller's order** rather than sorting, and — **measured today, ELF exit 42** — `row-join [x,x] []` returns `[x,x]`: it does not de-duplicate its own first argument at all. Its actual contract is *union of an already-canonical row into another*, which is a **different operation** from sorted-unique. And there is nothing to adopt: `collections` owns `Map`/`s-add`/`s-member` and `list-sort`, but **no list union**. Adopting would therefore mean *minting a new owner*, which is an OWNER element, not this ADOPTION element. This is a decision that it does **not** adopt — not a deferral — so no phantom row is created. If a `list-union` owner is ever wanted it gets its own minted row at that time. |
| **D3** | Does E156 grow to cover `closconv.chiral:39`'s `ins-uniq` (and, by the same argument, `compile-back.chiral:116`'s `dedup-str`)? | **RESOLVED — NO. DEFERRED to E165, whose catalog + ledger rows Step 0 mints in this same change.** | `ins-uniq` **is** the same ownership gap (`free-indices`, `closconv.chiral:51-108`, folds it left-to-right over indices — that fold *is* an insertion sort), so leaving it unnamed would be "built but unadopted" a fifth time. But it is **not the same change**: (a) `closconv.chiral` and `compile-back.chiral` are **compiler sources in the blob**, so converting them risks codegen for a leaf migration's benefit; (b) the conversion is not mechanical — `ins-uniq` maintains an *incremental* sorted accumulator, so adopting `list-sort` means restructuring `free-indices` to sort once at the end, a shape choice with real perf content that the codebase does not settle; (c) `dedup-str` is a **tree-set** dedup and its adoption target is `s-add`/`s-member`, not `list-sort`. That is design content ⇒ **E165 takes its own pipeline run** (`CLAUDE.md`'s amended criterion). E165 is free: E164 is the highest row in both the catalog and the ledger, and `E165` appears nowhere under `.planning/`. Step 0 is not optional — the deferral rule requires the row in the **same change** as the deferral. |
| **D4** | Should E156 correct the catalog row's `row-infer.chiral:106,117` citation? | **RESOLVED — YES, in Step 5.** | `docs/elements/ledger.md:276` was already corrected at the example audit; `docs/elements/catalog.md:418` still carries `:106,117` and the false *"the only sort in the tree"* claim. Leaving one of two rows corrected is drift with a second source. After this change those lines do not exist at all, so the corrected row must cite them as **retired**, not relocated. `tools/ledger-lint/ledger-lint.py` checks line citations against live files (`CLAUDE.md`, doc tier), so an uncorrected row is a lint finding this change would be creating. |
| **D5** | Which duplicate survives — first or last? | **RESOLVED — FIRST**, and now **measured**, not only argued. | The example §4 settles it on three grounds (composes with stability into a one-sentence spec; matches the in-tree convention at `compile-back.chiral:84,113` and the universal external one; cheaper — no pending candidate carried through the run). The measurement adds the part an argument cannot supply: the rules are **observably different** (`b,a,e` vs `d,c,e` on a key comparator, both run today) and the incumbent's keep-last is confirmed to be an accident of recursion order, not a behaviour anyone chose. |
| **D6** | Does the self-hosting fixpoint obligation apply? | **RESOLVED — YES, and the example §6 is wrong to say it does not.** | `grep -c 'end-module "collections"' scaffold/build/blob.chiral` = **1**: `collections` **is** in the compiler blob (via `string-utils`), so Step 1 changes **compiler sources**. `CLAUDE.md`'s build rule — *"only when the compiler's OWN sources changed: run the promoted binary over the same blob once more and byte-compare"* — therefore fires. The example's "no fixpoint obligation" is true of `row-infer` (`end-module "row-infer"` count **0**) and false of `collections`. §5 runs the full `.planning/BUILD-ORDER.md:290-315` ceremony. 2026-09-04: pre-migration scaffold/ path. |
| **D7** | Where does the gate live, given that nothing currently compiles `row-infer`? | **RESOLVED — a new `run-native.sh` Phase 9**, `scaffold/tests/test-e156-dedup.sh`. | Measured: nothing imports `sig-driver`, and neither `sig-driver` nor `row-infer` defines `compile-main`, so **Phase 7's root sweep never reaches `row-infer`** — and Phase 7 sweeps `scaffold/lib TUI agent scaffold/samples`, which does not include `scaffold/tests/samples/` at all. Phase 2's `test-runner` manifest is **six hardcoded tiny samples** (`test-runner.chiral:50-55`). So there is no existing phase this gate can join, and shipping the sample without a phase reproduces exactly the E152 state §6.4 finding 4 records. 2026-09-04: pre-migration scaffold/ path. |
| **D8** | The Python oracle floor is **red at HEAD** (348 ran / 23 F / 318 E). Repair it, formally retire it, or leave it? | **NEEDS-AUTHOR — non-blocking.** | ⚑ *Attribution corrected at the spec audit, 2026-08-23, by measuring a worktree of `4f26c20` (pre-E161).* The draft said E161's `(module …)` form broke it. **It did not.** Before E161 the same two tests died with `prelude.chiral:13: unknown toplevel form kind` — **E160's** form, which `chirality/surface.py` never learned either — and the suite was already red at 348 ran / **12 F / 343 E**. E161 renamed the form the oracle already could not read; it changed the counts (fewer errors, more failures), not the fact. The honest statement is that the oracle has been unable to load the annotated modules since E160 landed on 2026-08-22, and was substantially red before that. Not E156's call and not E156's damage: the breakage predates this element and is project-scoped (the oracle's retirement is the `oracle-retirement-floors` / RUNG1-CHECKLIST Phase C arc). It is surfaced here because **E156 must not be reported against a green Python line that does not exist**, and because `test_row_infer_chirality.py` — the *only* thing that ever exercised `row-infer` — is one of the casualties, which is what forces D7. §4 and §5 are unblocked: E156's gate is native and adds nothing to the Python suite. |

No decision blocks §4. `status: draft`.

---

## 4. Change plan (ordered, commit-sized)

### Step 0 — mint E165 (required by the deferral rule, lands first)
- **Target:** `docs/elements/catalog.md` (a row after E164) and
  `docs/elements/ledger.md` (a matching row).
- **Change:** mint **E165 — the remaining private de-duplicators adopt their
  owners**: `closconv.chiral:39-49` `ins-uniq` (`List I64`, folded by
  `free-indices` `:51-108` — an insertion sort) → `list-sort` + `list-dedup-adj`;
  `compile-back.chiral:116` `dedup-str` (tree set) → `collections`' `s-add` /
  `s-member`. Record the reasons it is *not* E156 (D3: both are compiler sources
  in the blob; the `free-indices` conversion is a restructuring with perf
  content; `dedup-str`'s target is the Map set, not the sort) and mark it
  **needs the pipeline** — example → audit → spec → audit → implement.
- **Size:** S. **Do not skip:** a deferral without this row is a phantom dep.

### Step 1 — `collections` owns `list-dedup-adj`
- **Target:** `scaffold/lib/collections.chiral` — append after `list-sort` (`:399`).
- **Change:** add `list-dedup-adj` + its `dd-` internal exactly as example §5
  gives them (binder order `(0 A) cmp xs`, identical to `list-sort`, so the two
  compose with no adapter; `dd-` prefix per E154; structural recursion, no fuel,
  total per E11). Keep the contract comment: this is `uniq`, **not** `sort -u` —
  global de-duplication is the *composition* with `list-sort`, and the survivor
  is the **first** of each run, which after a stable sort is the earliest
  occurrence in input order.
- **⚑ Compiler source (D6).** Run the §5 ceremony for this commit; a new `B1`
  beside a stale `blob.chiral` is the promotion trap `BUILD-ORDER.md:310-313`
  names. **Promote both together.**
- **Size:** S (~18 lines).

### Step 2 — `row-infer` adopts, and the private copies are deleted
- **Target:** `scaffold/lib/row-infer.chiral` — `:17` region, `:93-109`.
- **Change:** add `(import "collections")   ; list-sort (E152), list-dedup-adj (E156), Ord`
  beside the existing `string-utils` import (`collections` is already in the blob
  transitively via `string-utils`, and the resolver's post-order DFS de-duplicates,
  so the explicit import changes the blob's *text* only, not its module set);
  rewrite `row-of` to
  `(list-dedup-adj Str str-cmp (list-sort Str str-cmp (drop-dyn xs)))`;
  **delete** `ins-sorted` (`:93-102`) and `sort-dedup` (`:104-106`), declares
  included. `drop-dyn` and `infer-row` are untouched. Deletion is the deliverable,
  exactly as in E151b — a left-behind copy is the failure this element names.
- **Size:** S (+4 / −17 lines).

### Step 3 — the runtime sample
- **Target:** new `tools/test/samples/e156_dedup_adj.prog`, in the shape of
  `e152_list_sort.chiral` (a flat `Bool` list, `ls-t-first-bad`-style first-false
  index as the exit code, exit **0** on all-pass).
- **Change:** the G1–G3 cases of §5 — `str-cmp` shapes, the **key-projection
  survivor row** (`b,a,e`, the measured value), and the unsorted-input row that
  pins "compresses runs only". Header comment states the survivor rule and points
  at this SPEC §3 D5.
- **Size:** M (~120 lines).

### Step 4 — the gate script and the phase that runs it
- **Target:** new `scaffold/tests/test-e156-dedup.sh`; `tools/test/run-tests.sh`
  (new Phase 9 + its banner in the header comment block, `:12-29`).
- **Change:** the script builds each blob with `chirality_blob` / `chirality_blob_file`,
  compiles with `$CHIRALITY_BIN`, runs the ELF, and compares exit codes — the
  `test-module-kind.sh` house shape, zero Python. It runs: the E156 sample; the
  **`row-infer` adoption probe** (a `compile-main` program over
  `chirality_blob scaffold/lib row-infer`, asserting `infer-row`'s golden — the first
  automated compile+run of `row-infer`, D7); the retirement greps; **and the
  already-written-but-unrun `e151_string_stdlib` and `e152_list_sort` samples**
  (§6.4 finding 4 — a phase that runs one of three identically shaped gates and
  leaves two manual is this element's own half-fix pattern, one directory over;
  they are two lines here and they close a live measurement trap).
- **Size:** M.
- 2026-09-04: pre-migration scaffold/ path.

### Step 5 — the rows tell the truth
- **Target:** `docs/elements/catalog.md:418`, `docs/elements/ledger.md:276`.
- **Change:** correct the catalog citation (`:106,117` → *retired from `:93-106`*)
  and the false *"the only sort in the tree"* claim (D4); flip both rows to
  **built** with the measured evidence: fixpoint `C1==C2` byte size, Phase 9
  assertion count, `run-native.sh` exit 0, the mutants actually reverted, and the
  honest note that the Python oracle was already red before this change (D8).
- **Size:** S.

---

## 5. Conformance gate

**Golden behavior.** (i) `infer-row` returns a list **byte-identical** to the
pre-change implementation for every input — the E141 golden, and it holds because
`str-cmp`'s `(eq)` implies value equality on `Str`, so first and last occurrence
are the same value. (ii) Where `(eq)` does **not** imply value equality, the
survivor rule is **first**, and that is a runnable, falsifiable claim. (iii) No
private sort or dedup remains in `row-infer`.

**⚑ Why a `str-cmp`-only test cannot be the gate.** It is impossible for such a
test to fail the decision this element makes: on `Str` the two rules return equal
lists. The teeth are entirely in the key-projection row (G2), which is why it is
specified against a **measured** expected string rather than a derived one.

### Tests to add — `scaffold/tests/test-e156-dedup.sh`, driven as `run-native.sh` Phase 9
2026-09-04: pre-migration scaffold/ path.

`channel` is `sample` (a runtime sample compiled by B1 and run, exit compared),
`probe` (a purpose-built `compile-main` program over a library blob), or `grep`.
Every row names the mutant that makes it fail.

| # | n | channel | case | mutant it must catch |
|---|---|---|---|---|
| **G1** | 3 | sample | **`str-cmp` shapes.** `list-dedup-adj Str str-cmp` over: `nil` → `""`; a sorted list with no duplicates → unchanged; `list-sort` ∘ `list-dedup-adj` over `["b","a","c","a","b"]` → `"a,b,c"`, and over `["z","z","z"]` → `"z"` | make `list-dedup-adj` the identity, or make `dd-skip`'s `(eq)` arm re-emit `y` → the all-same and duplicate rows fail. Also catches a `dd-skip` that never opens a new run (returns `nil` after the first survivor) |
| **G2** | 2 | sample | **THE SURVIVOR ROW — the only row with teeth on D5.** Mirror `e152_list_sort.chiral:151`: `(Pair I64 Str)`, comparator on the **key only**, input `(2,"a") (1,"b") (2,"c") (1,"d") (3,"e")`. Assert `list-dedup-adj ∘ list-sort` tags = **`"b,a,e"`** and keys = `"1,2,3"` | **the mutant is the shipped incumbent.** Replace `list-dedup-adj` with `row-infer`'s fused `ins-sorted`/`sort-dedup` rule and the tags are **`"d,c,e"`** — *measured today, both programs compiled with B1 and run to exit 42 against their respective expectations.* Also catches any later "optimisation" that reverses the accumulator, and catches losing stability in `list-sort` (`ms-merge`'s `(eq)` arm taking from the right → `"d,c,e"` again) |
| **G3** | 2 | sample | **the contract: `uniq`, not `sort -u`.** `list-dedup-adj` **alone** on the unsorted `["b","b","a","b"]` → `"b,a,b"` (runs compressed, the split `"b"` kept); and on `["a","b","a"]` → unchanged | an implementation that carries a seen-set and de-duplicates **globally** passes G1 and G2 and fails here. This row is what stops the function from being silently sold as global dedup — the concealment E156 exists to remove, re-entering through the new owner |
| **G4** | 3 | probe | **the adoption, and the E141 golden.** Blob = `chirality_blob scaffold/lib row-infer` + a `compile-main` probe. (a) it **compiles** — measured rc 0 at HEAD, and this is the **first** automated compile of `row-infer` in the tree (D7); (b) `infer-row` over a `RowSig` whose callee list carries a duplicate port and a `"*"` returns the golden `["put"]` — **measured, exit 42, pre-change**; (c) a multi-port fixture returns its row sorted ascending with no adjacent duplicates | forget `drop-dyn` → `"*"` appears → (b) fails. Drop the `list-dedup-adj` call from `row-of` → the duplicate survives → (b) fails. Drop the `list-sort` call → (c) fails on order. Break `row-infer`'s type-checking at all → (a) fails, which is the failure **nothing in the tree could see before this row existed**. 2026-09-04: pre-migration scaffold/ path. |
| **G5** | 2 | grep | **retirement is real.** `ins-sorted` and `sort-dedup` **absent** from `scaffold/lib/`; `list-dedup-adj` and `dd-skip` **present exactly once**, in `collections.chiral` | leaving either private copy behind → the absent grep fails. Defining `list-dedup-adj` twice (the E154 flat-label collision, and the E151 defect verbatim) → the present-once grep fails. The "built but unadopted" guard, made mechanical |
| **G6** | 2 | sample | **the two gates that were written and never run.** `e151_string_stdlib.chiral` and `e152_list_sort.chiral`, each blobbed against its own library root and run — exit **0** each | any regression in `str-cmp` or `list-sort`. Measured: at HEAD these are executed by **no** automated phase (§6.4 finding 4), so today the mutant is undetected by construction |

**Green line, counted by running the gate.** Native: `run-native.sh` goes from
**121 assertions + 81 roots, exit 0** (measured 2026-08-23: P1 6 · P2 test-runner
exit 0 over 6 samples · Phase 3 7 · Phase 4 31 · Phase 5 12 · Phase 6 21 · Phase 7 81/0/12 · Phase 8 44) to
**135 assertions** — Phase 9 adds **14** (3+2+2+3+2+2). Phase 7's root count is
unchanged (`row-infer` still defines no `compile-main`; it is reached by G4's
probe, not by the sweep). **Python: unchanged and still red** — 348 ran / 23
failures / 318 errors. Not broken by this change, and **not broken by E161
either**: measured against a worktree of `4f26c20`, the pre-E161 tree was already
348 ran / 12 F / 343 E, with the same two tests dying on **E160's** `kind` form.
The oracle has not been able to load an annotated module since 2026-08-22
(`chirality/surface.py:218` knows neither `kind` nor `module`); E156 adds no Python test and the
oracle is not a gate (`CLAUDE.md` build rule). Re-run it after the change and
report the same three numbers; a *different* number is a finding.
`tools/ledger-lint/ledger-lint.py` checks A–H clean (Step 5 is what keeps check-D honest).

### Build ceremony — `collections` IS a compiler source (D6), so the full five steps run

```
cd /workspace/chirality
ulimit -s unlimited ; . bin/chirality-resolve.sh
chirality_blob scaffold/lib sys-linkage compile-front compile-back compile-emit compile-all compile-driver > /tmp/blob.new
./scaffold/build/B1 < /tmp/blob.new > /tmp/C1 && chmod +x /tmp/C1
/tmp/C1 < /tmp/blob.new > /tmp/C2 && cmp /tmp/C1 /tmp/C2        # byte-identical fixpoint
#  behavioural gates -- the fixpoint is NOT a correctness check:
bash scaffold/tests/test-e156-dedup.sh                          # G1-G6
cp /tmp/C1 bin/chirality-bin && chmod +x bin/chirality-bin
cp /tmp/blob.new scaffold/build/blob.chiral                      # BOTH, together
./scaffold/build/B1 < scaffold/build/blob.chiral > /tmp/V && cmp /tmp/V bin/chirality-bin
bash tools/test/run-tests.sh                               # all nine phases, exit 0
```
2026-09-04: pre-migration scaffold/ path.

Then **rebuild `scaffold/build/test-runner`** against the promoted B1 — a runner
built by the previous compiler is the stale-artifact trap `BUILD-ORDER.md`
records and E161 hit live. **No two-stage bootstrap is needed**: E156 adds no new
toplevel form and no new head, only new defs, so the committed B1 reads the new
blob directly. Step 2 alone (`row-infer`) touches no compiler source and needs
only *compile with B1, run*.

**Done when:** on the promoted compiler, `run-native.sh` exits 0 with Phase 9
reporting **14 passed, 0 failed**; `grep -rn 'ins-sorted\|sort-dedup' scaffold/lib/`
is empty (G5); `list-dedup-adj` composed after `list-sort` returns `b,a,e` on the
key-projection fixture while the incumbent's rule returns `d,c,e` (G2 — teeth
proved by reverting the mutant, not by assertion); `row-infer` compiles and
`infer-row` returns its pre-change golden (G4); E165's catalog and ledger rows
exist (Step 0); and `B1` reproduces itself byte-identically over the promoted
blob.
2026-09-04: pre-migration scaffold/ path.

---

## 6. Residue & links

### 6.1 Deliberately unbuilt

- **`closconv.chiral:39` `ins-uniq` and `compile-back.chiral:116` `dedup-str`** —
  home: **E165**, minted by Step 0. Not residue-without-a-home.
- **A `list-union` owner in `collections`** — nobody's yet, and deliberately not
  minted (D2): `row-join` is not waiting on one, and minting a row for a function
  no consumer wants is the phantom dep in the other direction.
- **A fused `list-sort-dedup`** — never; it restores the concealment (example §5).
- **A keep-last variant / survivor flag** — never; reverse-dedup-reverse is the
  honest cost (example §5).
- **The Python oracle's repair or formal retirement** — home: the
  `oracle-retirement-floors` arc / RUNG1-CHECKLIST Phase C. Surfaced as **D8
  NEEDS-AUTHOR**, not absorbed here.

### 6.2 Follow-on

- **E165** — the remaining private de-duplicators adopt their owners (Step 0).
- E156 completes E152's a/b pair: `collections` now owns both halves of
  "sorted unique", and `row-infer` owns neither.

### 6.3 Related

[[E156-sort-adopt]] · [[E151-ord-dedup]] (the a/b precedent; E151b already
retired this file's `str-cmp` copy) · E152 (`list-sort`, the owner adopted here)
· E154 (the flat-label `dd-`/`ms-` prefix convention) · E11 (totality —
structural recursion) · [[E141-golden-conformance]] (the byte-identical golden
G4 leans on) · E165 (minted by this change).

### 6.4 Where the code contradicted the example or the catalog

Recorded under the authority order (live CODE first), not silently reconciled.

1. **The fixpoint obligation DOES apply.** The example §6 and the catalog row
   both say *"`row-infer` is not in the compiler blob, so there is no fixpoint
   obligation"*. True of `row-infer` (`end-module "row-infer"` count **0**) —
   but E156 also edits **`collections`**, whose marker count in
   `scaffold/build/blob.chiral` is **1**. Compiler sources change, so the full
   ceremony runs (D6). Reading this as "light ceremony" would ship a `B1` and a
   `blob.chiral` out of sync, which `CLAUDE.md` names as the tree-vs-binary lie.
2. **Nothing in the tree compiles `row-infer`.** Measured: no file imports
   `sig-driver`, and neither `sig-driver` nor `row-infer` defines
   `compile-main`, so Phase 7's root sweep cannot reach it. The example assumed
   the gate was *"the sample-test suite plus its one importer,
   `sig-driver.chiral:23`"* — but that importer is itself unreachable. G4 is the
   first automated compile of this file, and it is measured green at HEAD, so the
   row starts honest rather than papering over an unknown.
3. **The Python oracle is already red at HEAD** — 348 ran, 23 failures, **318
   errors**; `test_row_infer_chirality.py` and `test_collections.py` both die in
   `setUpClass` on `prelude.chiral:15: unknown toplevel form module`, i.e. E161's
   new toplevel form, which `chirality/surface.py:218` does not implement. Two
   consequences: the pack's *"709 test functions across 77 files"* is a count of
   `def test_` lines and **not** a green line, and the only test that ever
   exercised `row-infer` cannot serve as this element's gate. Surfaced as D8.
4. **`e152_list_sort.chiral` is run by no automated phase.** Phase 2's
   `test-runner` manifest is six hardcoded samples (`test-runner.chiral:50-55`);
   Phase 7 sweeps `scaffold/lib TUI agent scaffold/samples`, which does not
   include `scaffold/tests/samples/`. E152's gate lives only as a manual
   procedure in `BUILD-ORDER.md:304-307`. Step 4 registers it, `e151`, and the
   new `e156` sample in Phase 9.
5. **The catalog row's citation is drift** (`:106,117`; live `:93,104-106,108`)
   and its *"only sort in the tree"* claim is false — corrected by Step 5 (D4).
   The ledger row was already corrected at the example audit; the catalog was not.
6. **`row-join` is not a de-duplicator at all** — measured, not inferred:
   `row-join [x,x] []` returns `[x,x]`. The name *"dedup union"* at
   `effects.chiral:22` overstates it; it de-duplicates only *against* its second
   argument and relies on its first being an already-canonical row. Recorded
   here rather than renaming the comment, which is not E156's file to touch.


### 6.4b Found while BUILDING it — the gate fixture that could not see its own mutant

⚑ **The most important finding of the implementation, and it invalidates a row
this spec wrote.** G4's first cut used the fixture shape §5 specified, and
**dropping `list-sort` from `row-of` left the gate at 14 passed, 0 failed.** The
row was decoration. Two independent causes, both measured:

1. **`irow` conses each newly reached port onto the front**, so the accumulator
   arrives in *reverse first-encounter order*. The fixture's ports were written
   `write, read, open`, which reverses into `open, read, write` — already
   ascending. A sort mutant cannot be seen through an input that is sorted by
   accident. The fixture now uses an encounter order whose reversal is not
   sorted.
2. **`row-join` (`effects.chiral:23`) de-duplicates its first argument only
   *against* its second, never within itself** — D2's own finding, one level
   down and biting the gate rather than the design. A repeated callee is eaten by
   `row-join` and **never reaches `row-of` as a duplicate**, so the golden could
   not observe `list-dedup-adj` at all. The fixture now routes the duplicate
   through a *stamped* row (`h → ["put","put"]`, first among `f`'s callees) so it
   lands on an empty accumulator and survives to `row-of`.

The lesson generalises past E156: **a golden fixture must be checked against its
own mutants, not only against the pre-change output.** Byte-identical to the old
implementation is exactly what a fixture that exercises nothing also achieves.

### 6.4c Two smaller SPEC premises the build corrected

- **`dd-skip` must be defined BEFORE `list-dedup-adj`.** The example §5 puts the
  entry first with a forward `(declare dd-skip …)`; that is refused with
  `load: unknown name dd-skip`. The loader resolves in blob order and `declare`
  does not create a forward binding — which is why `ms-take`/`ms-merge` already
  precede `ms-sort-n`.
- **A bare library blob cannot be compiled at all.** G4(a)'s "it compiles" needs
  a trivial `compile-main` appended: `chirality_blob scaffold/lib row-infer | B1` is
  refused with `no such def: compile-main`, because the compiler is a
  whole-program emitter. Every def in the blob is still checked, which is the
  claim the row makes.
