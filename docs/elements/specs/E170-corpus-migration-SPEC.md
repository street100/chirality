---
element: E170
slug: corpus-migration
title: **The corpus lands on the floor — the 709-function migration E168 exists to receive**
kind: BUILD-PROPER
example: examples/E170-corpus-migration.md
status: audited
updated: 2026-08-25
---

# E170 SPEC — **The corpus lands on the floor — the 709-function migration E168 exists to receive**

> ⚑ **TRIAGE 2026-09-04 — DEAD.** 0 of 0 steps are executable at HEAD. The
> 709-function corpus it migrates was deleted with `scaffold/`; only the
> `or-python` retirement survives as intent. Bucket and evidence:
> `records/spec-tier-triage.md`. This file was not rewritten and its `status:`
> was not changed.

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

**Every number below was measured on 2026-08-25 at `e463aa5` with the command
named beside it.** Where a figure is inherited from a dated measurement rather
than re-run, the date is written down instead.

## 1. Deliverable

- **After this runs:** `scaffold/tests/*.py` is empty and `scaffold/tools/selfhost.py`
  is gone; every one of the 709 source functions carries a typed `Disp` in
  `scaffold/lib/corpus-migrate.chiral`; `or-python` is deleted from `OracleId` and
  the compiler reports no residual site; and **at every intermediate commit** a
  reconciliation gate convicts a `.py` deleted without a record — which is what
  makes a half-finished migration report half-finished instead of green.
- **Non-goals**, each with its home:
  - rung-1's Python-deletion *policy* (which `.py` may exist at all) —
    `.planning/RUNG1-CHECKLIST.md` §C-inventory, and `ledger-lint` check O over it.
  - the harness's resolver fork cost (**~35 % of the suite's wall clock**,
    `.planning/BUILD-ORDER.md:555-565`) — the resolver/wielder lane. Settled as
    refused with **no element minted** (E168 SPEC decision 2); nothing here
    reopens it and nothing here waits on it.
  - E167 (`tal`→C leg) and E169 (lower coverage) — the *other* external opinions.
    Neither is built; §3 D1 fixes what E170 may assume of them.
  - E171 (call-level `->`/`=>` enforcement) and E80 (reifying the ambient
    build/exec crossings) — the two elements that would make a hand-written
    `MutRun`/`obk-given` unforgeable. E170 ships at detection-rung and says so.
  - E148 (`getdents64` + `stat`) — the crossing that would let the reconciliation
    survey run in chirality instead of in the harness. §3 D7 defers to it by name.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E170 postdates the map snapshot (bundle §3),
  so the element is **BUILD**. The *floor* it builds on is not: E168 is `built`
  (LEDGER:136) at **854 L** (`wc -l scaffold/lib/test-floor.chiral`).
- **Live code this composes with — named, not respecced:**
  | shard | live location | what it already does |
  |---|---|---|
  | the floor | `lib/evidence/test-floor.chiral` (854 L) | `ExProv`/`prov-rank` · `Obs`/`ObsKey`/`Expect` · `Builder` · `OracleId`/`Oracle`/`oracle-ask` · `differ`/`diff-expect`/`DiffExpect` · `MutRun`/`mut-run` · `Gate`/`gate-verdict` · `Suite`/`suite-fold` · `observe-exs`/`run-suites`/`test-main` |
  | the live adopter | `prog/test-runner.prog` | `sample-suite (-> MutRun Suite)` `:69` fed by `mk-suites (=> (1 bld Builder) SuitesR)` `:105` — the shape a per-file suite copies; `mutant-src` `:64` is the mutant idiom |
  | the resolver | `lib/module/resolve.chiral` (452 L) | `bundle (=> (List Str) Str BundleR)` `:351` — roots + root module → one blob string |
  | the C leg | `scaffold/tests/ddc-c-leg.sh` (464 L) | gcc 12.2.0 / ccomp 3.17; G4 convicting byte-identical at 1,077,624 B under both. 2026-09-04: the 2026-08-31 migration moved the tree out of scaffold/. The pre-migration paths kept here name no live directory. |
  | the rank-2 contract | `docs/testing-floors.md` §*Rank 2's anchor* `:216-260` | the five-part admission test for a NEW anchor |
  | the python tripwire | `tools/ledger-lint/ledger-lint.py` check O `:644-676` | fires on an EXISTING unclassified `.py`; a deletion cannot trip it |
- **The corpus, re-measured here with the method stated** (the catalog's figures
  are a 2026-08-23 measurement and they reproduce):
  - `ls scaffold/tests/*.py | wc -l` → **79** files;
  - `cat scaffold/tests/*.py | wc -l` → **14,784** LOC;
  - `grep -h "    def test" scaffold/tests/*.py | wc -l` → **709** functions;
  - `ls scaffold/tests/test_*.py | wc -l` → **77**; `grep -l 'def test' … | wc -l` → **76**.
  - The three files contributing zero counted functions are `__init__.py` (0 L),
    `ddc.py` (175 L — a helper, not a test module) and
    `test_stack_args_compile_run.py` (97 L), which **generates 5 cases at import
    time** through `_mk` + a loop over `CASES` (`:30,85,92`) and is therefore
    invisible to the counting method. **709 is a unit count under a stated
    method, not an assertion count** — §3 D10 dispositions this.
- **True delta — five constraints measured against the live floor, each of which
  the example's plan runs into.** These are the spec's real content; none of them
  is a defect in E168, and none is fixed by writing more suites.
  1. **The floor cannot ask an external leg.** `oracle-ask` answers `or-ccomp` /
     `or-gcc` / `or-rocq` with `ob-nobuild "an external leg the harness runs, not
     this floor: …"` (`test-floor.chiral:287-289`), so `differ` yields
     `df-unasked` and `diff-expect` returns `ex-refused (xr-unasked …)`. The two
     askable ids are `or-native` (rank 4) and `or-fixed` (rank 2). → **D6**.
  2. **`observe-exs` truncates at the first `obk-given`** — it returns an EMPTY
     list at that element (`:797`) rather than skipping it, so every later
     expectation loses its observation too; `fold-checks` then scores
     `g-inadequate (in-unobserved …)`. The file says the remedy in place: *"a
     gate that carries `obk-given` checks must be handed its observations rather
     than run through here"* (`:781-782`). → **D6**.
  3. **`observe` compiles ONE FILE.** It `openat`s the path, reads it, and hands
     the bytes to `run-src` → `compile-all` (`:490-497`), with no resolution
     step. Measured consequence: `grep -L "(import " scaffold/samples/*.chiral`
     returns **exactly 6 files** — `exit42`, `exit7`, `multi-def`, `boxed-a`,
     `boxed-b`, `enum-tag` — and those are **exactly** test-runner's 6-entry
     manifest (`test-runner.chiral:34-40`), while 62 of the 68 files in that
     directory import something. A rewritten chirality-in-chirality test needs `prelude`
     at minimum, so **as built, the floor cannot observe a single one of the 306
     rewrites.** → **D8**, the largest single item in the change plan.
  4. **An `or-fixed` leg and an `or-native` leg can never agree.** `or-fixed`
     returns `(ob-bytes …)` (`:278-284`) and `or-native` returns
     `(ob-exit …)` through `run-src` (`:200-204`); `obs-cmp`'s mismatched-
     constructor arms make that `ck-fail` (`:97-105`), so `diff-of` yields
     `df-differ` and `diff-expect` refuses. The example's §6 option (c) —
     "the leg mints an `or-fixed` artifact and the differential runs against
     that" — **cannot be built from these two ids**. → **D6**.
  5. **`oid-prov` ranks every `or-fixed` 2 regardless of the path** (`:225-233`).
     A file the harness wrote thirty seconds ago launders to rank 2 — clause 2 of
     the admission test (*not written by the build*) is exactly what the type
     cannot see. → **D9**.

## 3. Decisions

Every open question from the example §6, plus the five the baseline forced, plus
the two the SPEC audit raised as FLAGs and the author answered on 2026-08-25
(**D15**, **D16**) — recorded before the wave that depends on them, because a
decision written down after the thing it governs is a decision that thing already
made. RESOLVED only where a settled doc, a live measurement, or the author
decides it; the two author rows say so in the disposition cell.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| D1 | How many of the 335 can the `rocq/` floor re-found today? | **RESOLVED — zero, and E170 does not wait.** | `docs/banks/verification.md` §5 item 3: `coqc 8.16.1` is installed and `rocq/Chirality/*.v` are written against Rocq 9's `From Stdlib Require Import`, which 8.16 rejects; the formalization is two files about one integer type. LEDGER:135/137 keep E167 and E169(b) at `design`. A promised opinion is not a surviving one, so `or-rocq` appears in no `Disp` this element writes. |
| D2 | `scaffold/tests/fixed/` — right home and granularity, and what mints the first ones? | **RESOLVED, with a licence constraint the example did not carry.** | Home `scaffold/tests/fixed/`, **one fixture per gate** (an `or-fixed` names one path per `OracleId`, so per-gate is the only granularity the type has). Minting: **gcc only, never ccomp.** `ddc-c-leg.sh:29-35` states the constraint in the script itself — *"the artifacts this script builds are COMPARED AND DISCARDED, never distributed … NEVER ship, publish, or promote a ccomp-built binary out of here"*, which is what keeps the path inside INRIA's non-commercial licence. Committing a ccomp-produced artifact **is** distribution. Also refused by clause 5 of the admission test (`docs/testing-floors.md:256-258`): the 1,077,624 B conviction artifact is not reviewable and is not a candidate. Fixtures are small, reviewable, gcc- or hand-minted. 2026-09-04: pre-migration scaffold/ path. |
| D3 | Phases 1 and 3–11: one `Suite` per phase or per script? | **RESOLVED — one `Suite` per SCRIPT**, `(phase Str)` carrying the phase name. | The scripts are the units `run-native.sh` already invokes and each keeps its own pass/fail accounting. And `(phase Str)` is **carried and never read** — `suite-fold` (`:672`), `observe-suite` (`:823`) and `gate-line` (`:718`) all ignore it (measured) — so it is a label, and a label should name something a reader can point at. |
| D4 | Exact floor arities and constructor names. | **RESOLVED — attested in the example §5 and re-verified live here** (`test-floor.chiral:40,78,125,140,168,212,239,299,322,364,381,390,445,451,525,532,539,545,658` — every one of those nineteen lines is the `data` decl the example names). ⛑ **With ONE correction the example carries and must not be copied: `Obs` has THREE arms, not two.** Live at `:78-81`: `(ob-exit (code I64))`, `(ob-bytes (b Bytes))`, **`(ob-int (v I64))`** — the evaluator's answer — and `obs-cmp` (`:97-105`) cases all three. The example's attested block prints two and says *"no `ob-text` arm, on purpose"*, which is true of `ob-text` and silent about `ob-int`. A `case` over `Obs` copied from the example is refused: `load: non-exhaustive case` (measured 2026-08-25, `scaffold/build/B1` on a three-constructor probe). | No re-derivation in the implementation run **except `Obs`**, whose third arm is stated above because the example is the thing that would otherwise be copied. |
| D5 | Migration order: 68 mechanical first, or the 41 differential files first? | **RESOLVED — mechanical first, with ONE differential pilot closing that wave.** | The 68 are the cheap end-to-end proof that the per-file unit, the deletion rule and the conservation gate work; this repo's measured failure mode is *built but unadopted* (4 occurrences incl. E42 — memory index / `banks/verification` §5 item 4), which argues for proving adoption on the cheapest instance. The counter-risk — rebasing 335 assertions on a seam nobody exercised — is bought off by the pilot, not by reordering the bulk. |
| **D6** | **How does an external leg's observation reach a gate?** | **RESOLVED — a refinement of the example's shape (a): the harness RECORDS, generated source CARRIES, and `suite-fold` JUDGES. Options (b) and (c) are refused, with reasons.** | See the block below the table — this is the element's load-bearing decision. |
| **D7** | **What generates the `(List Mig)`?** | **RESOLVED — the harness surveys the tree and emits generated chirality source; the gate asserts a CONSERVATION LAW, not a running total. In-tree survey DEFERRED to E148.** | See the second block below the table. |
| D8 | The floor cannot observe a root with imports (baseline 3). | **RESOLVED — `observe` gains resolution by composing the built resolver**, which requires splitting `resolve.chiral`'s entry out. | `resolve.chiral:366` already exports `bundle (=> (List Str) Str BundleR)`. It also defined `compile-main`, at line 442 of `resolve.chiral` when this row was written; W0.1 has since moved that entry to `prog/resolve.prog:94` and `resolve.chiral` marks the library end at `:403`. Also defining it were `test-runner.chiral`, `compile-driver.chiral`, `compile-driver-c.chiral` and `self-wield.chiral` (`grep -ln "def compile-main" scaffold/lib/*.chiral` → 5 files), so importing it into the floor collides at every root. **The tree's own precedent is the fix:** `compile-all.chiral` (library) beside `compile-driver.chiral` (entry), and likewise `closconv-driver` / `sig-driver` — `test-runner.chiral:112-115` records why the split was needed. `resolve.chiral` → library + `resolve-driver.chiral`. ⛑ **This REVERSES half of E168 SPEC decision 2, and says so rather than sliding past it.** That decision reads *"not E168, and no element is minted for it … Owning resolution would make the test library a build system"*, and E168 §6 files the residue as **"Import resolution / the ~35% fork cost. Home: nobody's yet, and deliberately not minted."** Three things make the claim here narrow rather than a re-litigation. (i) The two halves are separable and only one moves: the **fork cost** stays refused and unowned (§1 non-goals), because `bundle` is an in-tree read with no `bin/chirality-resolve.sh` in it. (ii) The floor does not *own* resolution — it **calls** the resolver library that E155 already built and Phase 11 already gates; owning it would mean re-implementing module search inside `test-floor.chiral`, which is the thing decision 2 refused and nothing here does. (iii) E168's decision was *"not E168"* over a home recorded as **open**, not *"never anyone's"* — so the element that needs it claims it, which is the deferral rule run forwards. **Whose defect it is:** E170's work, not an E168 escape. E168's own adopter is Phase 2's six samples, and those six are **exactly** the six import-free files in `scaffold/samples/` (measured, baseline 3), so nothing in E168's delivered scope could observe the limit. It becomes a defect at the first imported root, and the first imported root is E170's. 2026-09-04: pre-migration scaffold/ path, and the split this row asks for has landed as `prog/resolve.prog` rather than `resolve-driver.chiral`. Row left as written. |
| D9 | `or-fixed` launders a build-written file to rank 2 (baseline 5). | **RESOLVED — the type cannot see it, so the check is mechanical and lives in the lint: new `ledger-lint` check S.** | Admission clauses 1–3 (`docs/testing-floors.md:246-252`) are properties of *git*, not of a run: tracked, not matched by `.gitignore`, digest argument non-empty. `ledger-lint.py` already greps sources and reads globs (check O `:644-676`), and the letters run A–R (`grep "^def check_"` → 18 defs, a–r, no `check_s`; `python3 tools/ledger-lint/ledger-lint.py` clean, measured 2026-08-25), so **S is free**. Clauses 4–5 stay review discipline and say so. ⛑ **The tree already holds ONE literal the check fires on, and it is not a bug — it must be dispositioned before S is added, or S ships red.** `grep -rn '(or-fixed "\|(pv-fixed "' --include=*.chiral .` returns **exactly one** hit tree-wide: `scaffold/tests/samples/e168_rank_floor.chiral:60`, `(pv-fixed "<illustrative: this floor never opens the path>" (str->bytes "<illustrative: this floor never checks the digest>"))`. That fixture judges rank *arithmetic* and its two fields are inert by design — its own comment (`:43-56`) says the strings used to name a file that never existed, that minting one today *"predates nothing and is a second false claim"*, and that the real close is *"a floor that OPENS the named path and compares the digest before honouring rank 2 — unbuilt, owned by nobody"*. **That orphan is E170's, and it splits in two along the type.** `or-fixed` is an `OracleId` and IS opened — W0.3 gives that arm the digest comparison, which is the fixture's own stated condition for closure. `pv-fixed` is an `ExProv` and is opened by **nothing**, now or after W0.3; the mechanical substitute is exactly check S, which is D9's argument. So the fixture's rejection of *"an artifact minted today to justify a sentence"* is honoured rather than reversed: the reason it was rhetorical was that nothing checked it, and W0.4 is the thing that checks it. The fixture is converted **in the W0.4 commit** to name a real, small, committed `scaffold/tests/fixed/` anchor meeting clauses 1–3, in the same commit that makes naming one mean something. Exempting `scaffold/tests/samples/` from check S is refused: a launder would hide there first. |
| D10 | What does "709" count? | **RESOLVED — `def test` occurrences, and the figure is a LOWER BOUND.** | `test_stack_args_compile_run.py:30,85,92` generates 5 cases dynamically and contributes 0 to the count. The conservation law in D7 is therefore over *the counted method*, identically applied on both sides; it cannot see a dynamically generated test appearing or vanishing, and §5 G4 says so as what the gate does not prove. ⛑ **The undercount is not merely invisible — it is a live leak, and D14 closes it.** Because the file counts 0, `mig-state` answers `m-complete` for `(fns 0, disps nil)`: the law lets `test_stack_args_compile_run.py` be deleted with **zero** dispositions recorded while both sums stay balanced, and 5 real assertions leave the tree green. Raising its `fns` to 5 is not available — the survey's side of the law would still say 0 and the fn law would go red for the rest of the migration — so the guard is D14's ordering plus a named precondition, not arithmetic. **A law stated over an undercount passes while coverage leaks; that is said here rather than left for the count to imply.** ⚑ **AMENDED by D15 (author, 2026-08-25):** the law is no longer stated over a global 709 at all — it is per-file, taking both sides from the same survey — so the vacuous-`m-complete` leak this row had to close with ordering discipline is closed by arithmetic instead. What stays exactly as written: 709 is still a unit count under a stated method, the five generated cases are still invisible on both sides, and `uncounted-disps` still carries them. |
| D11 | Digest comparison needs a hash function the tree does not have. | **RESOLVED — the digest IS the bytes, and no hash is invented.** | `grep -rln "sha\|digest\|md5\|fnv\|crc" --include=*.chiral scaffold/lib/` finds no hash implementation. `docs/testing-floors.md:250-252` already sanctions this: *"An anchor small enough to sit inside the gate file … is its own digest: `cmp` against the committed bytes IS the check."* Clause 5 (reviewable size) is what makes clause 3 buildable, so the two constraints are one design. 2026-09-04: pre-migration scaffold/ path. |
| D12 | Suite cost: 709 units on a 4m10s suite. | **RESOLVED — no budget exists to breach; E170 MEASURES per wave and records it.** | The `~4-minute budget` was retired as never-measured (LEDGER E166 row, FLAG RETIRED 2026-08-25). Measured here for one root through the shell path: resolve **1.936 s** + B1 compile **0.754 s** + run **0.020 s** ≈ 2.7 s (`chirality_blob_file` on `scaffold/tests/samples/e168_cap_thread.chiral` → 765,552 B blob, then `B1 <`). In-tree the resolve is the same work without ~7 forks per module (`BUILD-ORDER.md:555-565` measures that fork path at **120×** a fork-free read), so the per-root floor cost is dominated by the ~0.75 s compile. At **one root per source file** the budget is ≈ 77 base + 77 mutant builds ≈ 2 min added, not 709 × anything — which is only true because of D13. |
| D13 | Per-function gate or per-file gate? | **RESOLVED — one root and one gate per SOURCE FILE, exit code = the first failing internal case.** | The tree already ruled: `test-e168-floor.sh:124-127` — *"Its exit code is the number of the first failing internal case, 0 for all-pass — so a fixture with several cases still reports one assertion. Counting its cases would be how an inflated figure gets built."* A `Gate` holds a `(List Expect)` and one `MutRun`, so per-file is the granularity the floor's own cost model wants. |
| D14 | The **three** files that carry no counted test functions — how do they die? | **RESOLVED — `Mig` records with `fns 0`, deleted in the LAST commit of W5, and the third one carries a precondition the other two do not.** | The zero-contributors are `__init__.py` (0 L), `ddc.py` (175 L) **and `test_stack_args_compile_run.py` (97 L)** — measured 2026-08-25, `for f in scaffold/tests/*.py; do grep -c "    def test" $f; done`. `mig-state` answers `m-complete` for `(fns 0, disps nil)`, so the type alone would let all three go early while a surviving `.py` still imports them. The file half of the conservation law is over `scaffold/tests/*.py` = 79, so their deletion is visible; the ordering is discipline, stated here, not a type. ⛑ **The third is not a helper and must not be treated as one.** `test_stack_args_compile_run.py` carries **5 live assertions**, generated at import time by `_mk` + a loop over `CASES` (`:30,85,92`; `len(CASES)` = 5, measured), and every one of them is invisible to the counting method on both sides of the law (D10). Its **precondition for deletion, which the law cannot enforce:** its migrated `scaffold/tests/stack-args-compile-run.chiral` carries a gate covering all five cases, and each of the five gets a `Disp` — written into a **separate `(def uncounted-disps (List Disp) …)`** in `corpus-migrate.chiral`, NOT into the file's `Mig`, whose `fns` and `disps` both stay 0. That separation is forced, not stylistic: recorded `Disp`s are a term of the function law, so five of them beside an `fns 0` file would make the sum 714 against a survey that still says 709 and the gate would be red for the rest of the migration. `corpus-count.chiral` does not fold `uncounted-disps`; the report **prints** it, so the five are visible to a reader and inert to the arithmetic. The commit that deletes the file names the five. ⚑ **AMENDED by D15:** under per-file conservation the *reason* for the separation changes and the separation does not — five `Disp`s against an `fns 0` file break that FILE's own pair, which is a louder failure than the old global 709-vs-714, so `uncounted-disps` is still where they go. The deletion precondition is unchanged. |
| **D15** | **The 709 count misses 5 dynamically generated cases (audit FLAG 1). Widen the method once, on both sides, to 714 — or leave 709 standing?** | **RESOLVED — AUTHOR, 2026-08-25. Neither: 709 is not widened, and it stops being a law constant at all. The conservation law takes PER-FILE counts from the SAME survey on both sides.** | The law was written as two global sums against the fixed totals 79 and 709, which makes the totals load-bearing and makes every imperfection in the counting method a defect in the gate. Per-file conservation does not care what the method sees, only that it sees the same thing on both sides: for each surviving `.py` the survey's count, for each `m-complete` `Mig` the recorded `Disp` count, file by file. Two consequences, and both are the reason. **(i) The method is allowed to be imperfect, because it will be.** The audit already found one file whose cases are generated at import time (`test_stack_args_compile_run.py`, 5 of them, D10/D14); pinning the law to a global constant means the NEXT one leaks silently, and hand-enumerating dynamic cases into a global total is a method that drifts the first time somebody writes a loop. **(ii) No file can reach `m-complete` vacuously.** Under a global sum, D14's `fns 0` files balance while contributing nothing, which is the leak D14 had to close with ordering discipline instead of arithmetic; per-file, a file's own two counts must agree and the `fns 0` case is a statement about that file rather than a free pass through a total. **709 survives as a REPORTED total with its method named** — `grep -h "    def test" scaffold/tests/*.py | wc -l`, a unit count under a stated method — and no document above this SPEC is edited, because no document carried it as a law. **What this binds:** D7's survey emits per-file rows, not two integers; `corpus-count.chiral` folds pairs; G4's exit codes still mean file law / function law / both, now over the per-file join. **What it does NOT buy, stated as narrowly as D10 stated it:** the five generated cases stay invisible on both sides, and `uncounted-disps` + D14's ordering precondition remain exactly as written. A law robust to an imperfect method is not a law that fixes the method. |
| **D16** | **Does E170 own a mutant that re-inverts `mach-c.chiral:138` (audit FLAG 2)?** | **RESOLVED — AUTHOR, 2026-08-25. No. G6(a) is CITED, never re-executed here; it belongs to Phase 10. G6(b) stays E170's.** | Three reasons, all of them already in the G6 cell. **(i) Its observation channel IS Phase 10.** `ddc-c-leg.sh`'s own F3/G4 are what watch that mutation, and Phase 10 gates the conjunct today with or without E170 — a row that re-ran it would be borrowing Phase 10's strength and reporting it as its own. **(ii) It costs a full leg run** (2m21s `--no-admission`, ≈3m45s full) to re-establish a non-regression that the suite already re-establishes every time it runs. **(iii) A mutant maintained in two elements rots in at least one** — the two copies drift, and the one nobody runs is the one that stays green. So the G6 row cites Phase 10 for conjunct (a) and carries its own falsifier for conjunct (b), the `Oracle`-as-data half, which is what E170 actually delivers: change the recorded id in `c-leg-obs.chiral` from `(or-gcc "12.2.0")` to `(or-native "in-tree")` and the gate's provenance must fall from rank 1 to rank 4 and the verdict to `g-inadequate (in-no-anchor)`. A one-value edit that moves the verdict is what "passed as data" means, and it is the only half a corpus element can be evidence for. |

### D6 — the recording seam, in full

**What E170 builds.** `ddc-c-leg.sh` gains one step that writes **generated chirality
source** — `scaffold/build/generated/c-leg-obs.chiral` — carrying the leg's
identity and its verdicts as values, e.g.
`(def c-leg-id OracleId (or-gcc "12.2.0"))` and
`(def c-leg-g4 Obs (ob-exit 0))`. The Phase-10 suite root imports it and builds
gates whose checks are
`(ex (obk-given "e166/g4-byte-identical") c-leg-g4 (pv-external "gcc" "12.2.0"))`
— **rank 1**. Because `observe-exs` refuses `obk-given` (baseline 2), that root
does **not** call `test-main`; it calls `suite-fold`, which the floor already
documents for exactly this: *"`suite-fold` takes the observations rather than
making them, which is what lets a second chirality build or the Rocq leg re-judge
the SAME observations without re-running anything"* (`test-floor.chiral:654-657`).
The one new entry point is `suite-main (=> (List Suite) (List (List Obs)) I64)`
beside `test-main` — same `report` + exit code, no `Builder`, because nothing is
built.
2026-09-04: pre-migration scaffold/ path.

**Why not (b), a crossing that runs an external compiler.** The floor's whole
extern surface is `openat` / `close` / `run-elf` (`:173-175`), and its `Builder`
means *build-and-run in-tree chirality*. A cap that can exec `$PATH` toolchains is a
different authority, and reifying authority is E80's, not E170's. It would also
put a ccomp invocation inside every ordinary test run, against `ddc-c-leg.sh`'s
own licence discipline.

**Why not (c), an `or-fixed` artifact the leg minted.** Three independent
refusals: baseline 4 (an `or-fixed` leg and an `or-native` leg can never
`df-agree`, they return different `Obs` constructors); D2's licence constraint
(a ccomp-built artifact may not be committed); and admission clause 5 (the
1,077,624 B artifact is not reviewable).

**What the seam does NOT prove — stated as narrowly as the floor states its own
limits.** It does **not** prove the leg ran. The generated file is written by the
harness, and a hand-edited copy type-checks identically — **the same rung
`mu-killed` already occupies**, where `test-floor.chiral:425-443` records that a
hand-written `MutRun` compiles and scores green, deliberately, because five of
E168's own Phase-12 fixtures build them from literals. It does not prove the
recorded observation is gcc's: nothing signs it, and the floor never sees gcc.
What it buys is that the claim is **written down as a value, with tool and
version in `pv-external`, in the gate, beside its label, where `report` prints
it** — and that the file is either a *fresh* claim about a leg that just ran or
it is **absent**, an absent import failing to resolve rather than passing
quietly.

⛑ **That last property is NOT free, and the SPEC asserted it before it was
true.** The audit's finding, measured 2026-08-25: *deletion* and *staleness* are
different attacks, and only the first fails closed. A missing file fails to
resolve; a file present, old and wrong reads **byte-for-byte like a fresh one** —
nothing in it names a run, and no gate compares it to anything. And the chosen
home is the worst one for the claim: `scaffold/build/` is gitignored
(`.gitignore:8`) but it is an **accretion** directory, not a scratch one — it
holds **80 files spanning 2026-08-05 to 2026-08-25**, `B1-openat` from twenty
days ago among them, and `grep -rn "rm -rf .*scaffold/build\|rm -f scaffold/build"`
over every `.sh` and `.py` in the tree returns **nothing**. Files written there
survive for weeks by demonstrated behaviour. Meanwhile the leg's own artifacts go
to a `mktemp -d` `$W` under `trap cleanup EXIT` (`ddc-c-leg.sh:102-104`), so the
one artifact that must OUTLIVE `$W` is exactly the one `$W`'s discipline does not
cover — and the tree already records the incident where writing a leg artifact
outside `$W` was the defect (`ddc-c-leg.sh:494-502`, fixed 2026-08-25 by
`CHIRALITY_BUILD_DIR="$W"`).

**So the property is built rather than asserted, in two lines of shell that cost
nothing:**

1. `ddc-c-leg.sh` **`rm -f scaffold/build/generated/c-leg-obs.chiral` as its FIRST
   act**, before any gate runs. Then a script that dies at any gate, is
   interrupted, or is never run at all leaves the file **absent**, and staleness
   collapses into deletion — which does fail closed. This is the whole mechanism;
   without it the sentence above is a hope.
2. The write is the script's **LAST** step, carrying verdicts that already exist.
   Written early, a later gate failure would leave a file that is stale *within a
   single run* — the same attack at a shorter timescale.

**And the rank stays 1, for a stated reason rather than by default.** `prov-rank`
ranks the **provenance of the expected value**, not the identity of whoever
carried it: `pv-external` is *"an independent implementation with independent
semantics"* (`test-floor.chiral:41-44`), and gcc 12.2.0 is that whether the floor
watched it or a harness transcribed it. The floor already admits foreign
observations by construction — `obk-given` exists precisely to name *"an
observation somebody else made"* (`:130-132`) — so a transcribed external verdict
is a rank-1 claim at the floor's own **detection** rung, the same rung a
hand-written `MutRun` occupies and for the same reason. What rank 1 must NOT be
is *unfalsifiable*, and that is what step 1 buys: the claim is either fresh or it
is missing, and missing is loud. Unforgeability is E171's and E80's, named in
`test-floor.chiral:439-443`; nothing here waits on either.

### D7 — what generates the `(List Mig)`, and why the gate can fail

**The generator is the harness.** A `run-native.sh` step surveys the tree with
the same command that produced the baseline figures and writes
`scaffold/build/generated/corpus-survey.chiral`:
`(def survey-files I64 N)` and `(def survey-fns I64 M)`, where
N = `ls scaffold/tests/*.py | wc -l` and M = `grep -h "    def test" scaffold/tests/*.py | wc -l`.
Build-written, gitignored, regenerated every run, and **never** an anchor (D9's
check S would catch a `pv-fixed` pointed at it). ⛑ *"Regenerated every run" is
not the same as "cannot go stale", and the same measurement that corrected D6
corrects this: `scaffold/build/` accretes (80 files, 2026-08-05 → 2026-08-25;
nothing in the tree removes anything from it). So the survey step carries D6's
step 1 verbatim — `rm -f scaffold/build/generated/corpus-survey.chiral` before it
writes — which makes the file absent for any path that skips the survey, notably
running `test-e168-floor.sh` standalone rather than through `run-native.sh`. A
skipped survey must fail to resolve, not silently re-assert last week's totals.*

**The gate asserts a conservation law, not a running total.** A gate that
expected "79 files remain" would need editing in every migration commit, which
is a gate that tracks the migrator. ⚑ **D15 (author, 2026-08-25) narrows the law
from two global sums to a PER-FILE join: the survey emits one row per `.py` (its
path and its counted functions), not two integers, and `corpus-count.chiral`
pairs each row against that file's `Mig`. The two totals below stay as the
REPORTED figures with their method named; they stop being the constants the gate
compares against, which is what keeps an imperfect counting method from being a
defect in the gate. The exit codes and the mutant are unchanged.** Instead
`scaffold/tests/corpus-count.chiral` folds the survey against the records and
exits **0 balanced · 1 file law broken · 2 function law broken · 3 both**:

> surviving `.py` files + files with an `m-complete` `Mig` = **79**
> counted functions still in surviving files + recorded `Disp`s = **709**
> (both measured 2026-08-23 and re-measured 2026-08-25 at `e463aa5`)

The expectation is `(ex (obk-root "scaffold/tests/corpus-count.chiral") (ob-exit 0)
(pv-meaning "the corpus is a finite measured set and the migration conserves it"))`
— **rank 3**, which satisfies the floor's rank ≤ 3 companion rule for any gate in
the same suite carrying a differential. Exit codes are used because `run-elf`
returns a child status: **709 does not fit in an exit code**, and a verdict code
does.

**It can fail, and for the right reason.** Delete a `.py` with no record and the
survey drops while the records do not → sum < 709 → `ob-exit 1|2` → `g-red`.
Invent a record for a file that still exists → sum > 709 → red. Delete a `.py`
whose `Mig` is `m-partial` and BOTH laws break independently: the file law
because a partial `Mig` is not `m-complete`, the function law because the file's
counted functions leave the survey while fewer `Disp`s arrive than it had.

**The mutant is the survey decremented by one file, and it IS the tautology
conviction** — the two are one construction, not two. The tautology this gate
could otherwise be is *a program that computes both sides of the law from the
same input*, i.e. one that does not really read the survey. Decrement the survey
by one file and such a program's exit code **does not move**: base 0, mutant 0,
`mu-survived` → `g-inadequate` before a check runs. A program that does read it
exits 1 and the mutant is `mu-killed`. That is the whole argument, and it is the
survey — the one input that comes from the tree rather than from the migrator —
that carries it.

⛑ **Two corrections the audit forced here, both measured 2026-08-25.**

*(a) The `mig-state` stub does not do what this block claimed.* The SPEC read
*"stub `mig-state` to answer `m-complete` unconditionally and the mutant also
exits 0, giving `mu-survived`"*. Run the arithmetic at zero migrations: records
are empty, so `|m-complete Migs|` = 0 **under the stub as well as under the real
fold**; base is 79 + 0 = 79 → exit 0, mutant is 78 + 0 = 78 → exit 1. The mutant
is `mu-killed` **with the stub in place**, so the stub is not detected by it and
the sentence convicted nothing. What the stub actually launders is a *partially*
migrated file counting as complete — and that is caught by the **function** law,
which the stub does not touch, not by the mutant. The two laws are each other's
check; that is why there are two.

*(b) This gate's `MutRun` cannot be produced by `mut-run`, and the reason is
structural.* `mut-run` (`test-floor.chiral:501-515`) observes the **base by
PATH** — through `observe`, which W0.2 makes resolve — and the **mutant by
self-contained TEXT** through `run-src`, which W0.2 leaves unchanged. But
`corpus-count.chiral` is a root that imports both the generated survey and
`corpus-migrate`, and its mutant differs from it in **one generated constant**;
expressing that as a self-contained `Mutant` string would mean inlining the fold
and, by the end of W4, 709 `Disp` values — at which point it is a different
program and `mu-killed` means nothing. So the mutant is a **harness step**: the
survey is rewritten with `survey-files` decremented, `corpus-count` is rebuilt
and re-run, and the pair of exit codes is recorded through **D6's seam** as
`(mu-killed "survey decremented by one file" (ob-exit 0) (ob-exit 1))`. Same
rung, same disclosure — and, unlike a `MutRun` written from literals, it is a
mutant that was actually run.

**In-tree survey → DEFERRED to E148** (`getdents64` + `stat`, LEDGER:193,
CATALOG:413 — minted, `design`, `→scriba:S24`). Nothing here is deferred to an
unminted element, and nothing new is minted by this SPEC.

## 4. Change plan (ordered, commit-sized)

**Sizing reality:** 709 functions across 79 files is ~50 commits in five waves.
W0 and W1 touch **no `.py` at all**, so the first honest, reversible increment is
"the floor can receive, and the accounting convicts" — before anything is
deleted.

### W0 — floor prerequisites (no corpus touched, nothing deleted)

- **0.1 split the resolver's entry.** `scaffold/lib/resolve.chiral` → keep the
  library; move `compile-main` (`:442`), `parse-args`/`Cmd`/`Arg`/`classify-line`/
  `split-lines`/`default-roots` (`:370-424`) into new
  `scaffold/lib/resolve-driver.chiral`. Update every root list naming `resolve`
  as an entry. Gate: Phase 11 stays green. **Size M.**
- **0.2 `observe` resolves.** `test-floor.chiral` imports `resolve`; `observe`
  (`:490`) becomes `bundle (cons "scaffold/lib" nil) path` → `run-src` on the
  bundled text, with `BundleR`'s error arm mapped to `ob-nobuild` (so "the
  imports did not resolve" is not reported as "no such file"). `run-src` is
  unchanged — a `Mutant` stays a self-contained text, exactly as
  `test-runner.chiral:64` already writes one. **Size S.**
- **0.3 `or-fixed` checks its digest, and records its minting.** `oracle-ask`'s
  `or-fixed` arm (`:278-284`) compares the bytes it read against `dg` with
  `bytes=?` (D11: the digest is the bytes); add `(data Minting () (minted-by (o
  OracleId) (date Str)))` and carry it beside the fixture. A mismatch is neither
  `ob-nofile` nor `ob-nobuild`, so `ObsR` gains a fourth arm — measured blast
  radius: **5 case sites in `scaffold/lib/` and 5 in `scaffold/tests/samples/`**
  (`grep -rn "((ob-ok " --include=*.chiral`), every one of which the compiler
  enumerates. **Size M.**
- **0.4 `ledger-lint` check S** (D9): every `(or-fixed "…"` / `(pv-fixed "…"` path
  in `scaffold/**/*.chiral` is git-tracked, unmatched by `.gitignore`, with a
  non-empty digest argument. Same commit converts the tree's **one** live literal
  — `scaffold/tests/samples/e168_rank_floor.chiral:60` — to a real
  `scaffold/tests/fixed/` anchor, or check S ships red on the day it lands (D9).
  House style is checks P/Q/R: one `def check_s() -> list[str]` whose docstring
  is the incident, `[S] …` messages, registered in the tuple at
  `tools/ledger-lint/ledger-lint.py:874-876`; commit subject `lint(check S): …`. **Size S.**
- **0.5 `suite-main (=> (List Suite) (List (List Obs)) I64)`** beside `test-main`
  (`:845`) — `report` + exit code over `suite-fold`, no `Builder` (D6). **Size S.**

### W1 — the accounting spine (still zero deletions)

- **1.1 `scaffold/lib/corpus-migrate.chiral`** — `Loss` / `Disp` / `Mig` / `MigR` /
  `mig-state` / `mig-deletable`, exactly the example §5 shapes (`Disp` carries
  `(dig Bytes)`, not `Str`), plus an initially EMPTY record list. **Size M.**
- **1.2 the survey step** in `run-native.sh` — `rm -f` then write
  `scaffold/build/generated/corpus-survey.chiral` (D7; the delete is the freshness
  mechanism, not tidiness). **Size S.**
- **1.3 `scaffold/tests/corpus-count.chiral`** — the reconciliation root; folds
  survey against records, exits 0/1/2/3 (D7). **Size M.**
- **1.4 `corpus-gate` + its mutant** in the Phase-12 suite; the survey-decrement
  mutant (D7). **Green at zero migrations, and red the first time a `.py` is
  deleted without a record.** **Size S.**

### W2 — the 68 mechanical (9 files) + one differential pilot

One commit per source file: write `scaffold/tests/<name>.chiral` (one module, one
exported `(-> MutRun Suite)`, one gate, exit-code-of-first-failing-case per D13);
register it in its phase root; **delete the `.py`**; add its `Disp`s and `Mig`;
re-measure the RUNG1 C-inventory counts in the same commit (check O cannot see a
deletion — `ledger-lint.py:644-676` — so the counts are the discipline). Ends
with **one** differential file as the pilot, proving D6's seam before the bulk.
**10 commits.**
2026-09-04: pre-migration scaffold/ path.

### W3 — the 306 python-checker-only (29 files)

Same per-file shape, grouped by phase. These are the rewrites W0.2 exists to make
observable at all. **29 commits.**

### W4 — the 335 differential (41 files)

- **4.1 the classification survey** — one commit that walks the 41 files and
  assigns each of the 335 a predicted `Disp`, with the expected `d-retired` count
  *stated before* the migration rather than discovered mid-way (the example's Q1,
  answered by method rather than by guess; D1 fixes that `or-rocq` appears in
  none of them). ⛑ **The predictions must NOT go into the `Mig` records, and this
  is arithmetic rather than taste:** recorded `Disp`s are a term of the function
  law, so 335 predictions filed against 41 files that still exist make the sum
  709 + 335 = 1044 against a survey that still says 709 — **the conservation gate
  would be red for the whole of W4, which is 41 commits of a gate reporting a
  failure that is not one.** They land instead in
  `(def predicted (List Disp) …)` + `(def predicted-retired I64 K)` in
  `corpus-migrate.chiral`, which `corpus-count.chiral` does not fold. **And the
  prediction is judged, not merely made:** W5.3's commit re-counts `d-retired`
  across the real records with the same method and records predicted-vs-actual in
  its message. A prediction nothing later compares against is a guess with a
  timestamp. **Size L.**
- **4.2–4.42** one commit per file. Each surviving differential lands as a
  `d-refounded` on `pv-external` via D6's seam or a `d-reanchored` on an
  `or-fixed` fixture per D2/D11; each casualty lands as `d-retired` with a typed
  `Loss`. A gate with a differential and no rank ≤ 3 companion is
  `g-inadequate` by the floor's own rule (`gate-verdict:633-649`).

### W5 — the terminal move

- **5.1** re-express `run-native.sh` Phases 1 and 3–11 as `Suite` values, one per
  script (D3). Phase 10's suite root is the D6 seam, and the two shell lines that
  make its rank-1 claim falsifiable land in `ddc-c-leg.sh` in the same commit:
  `rm -f scaffold/build/generated/c-leg-obs.chiral` as the script's FIRST act, the
  write as its LAST. Without them the row is a claim about a file nobody's leg
  had to produce.
- **5.2** delete `or-python` from `OracleId` (`:213`); every site that still
  **names** it — `oid-prov:228`, `id-eq:259`, `oracle-ask:286`, and whatever the
  migration left — then refuses to load with `load: branch names a
  non-constructor` (measured 2026-08-25; §5 G7 corrects the earlier
  "no default arm" account, which described exhaustiveness and named the wrong
  mechanism). That enumeration is the completion check for part (a), and it is
  disarmed only by deleting the NAME, never by adding a default beside it.
- **5.3** delete `scaffold/tools/selfhost.py`, then the three zero-contributors —
  `ddc.py`, `__init__.py`, and `test_stack_args_compile_run.py` **only once its
  five generated cases carry `Disp`s in `uncounted-disps`** (D14); update the
  RUNG1 C-inventory rows; record predicted-vs-actual `d-retired` (W4.1);
  conservation gate green at 0/0.

## 5. Conformance gate

Each row names its **expectation-provenance rank** and **the mutant that
falsifies it** — a code mutation to be RUN and reverted, per the E166/E168
discipline (`docs/testing-floors.md:204-214`).

| # | Row | Rank & provenance | Mutant that falsifies it |
|---|---|---|---|
| **G1** | The floor observes a root **with imports**: new fixture `prog/samples/e170_imported_root.chiral` (imports `prelude`, exits 42) is `ob-ok (ob-exit 42)`. | **3** — `pv-meaning "the file's own main returns 42"`. In-gate `MutRun`: the import-free one-liner returning 41 (`test-runner.chiral:64`'s idiom) → `mu-killed`. | Revert W0.2: `observe` hands the raw file bytes to `run-src` ⇒ `ob-nobuild` ⇒ observation list short ⇒ `g-inadequate (in-unobserved (obk-root …))`. Today, before W0.2, that is the live behaviour — the row **cannot pass** at baseline, which is what makes it a gate. |
| **G2** | An **edited fixture is refused**: `scaffold/tests/fixed/` holds a committed fixture and a negative control whose bytes differ from the digest carried in chirality source. | **2** — `pv-fixed (path, digest)`; the fixture is its own digest (D11, `testing-floors.md:250-252`), minted by gcc or by hand, **never by ccomp** (D2). | Drop the `bytes=?` comparison from `oracle-ask`'s `or-fixed` arm ⇒ the negative control is accepted ⇒ the row goes green with a tampered fixture. (Before W0.3 the comparison does not exist, so the row starts red.) |
| **G3** | `ledger-lint` **check S** fires on a `pv-fixed`/`or-fixed` path that is gitignored, untracked, or digest-less. | **3** — `pv-meaning`: admission clauses 1–3 are properties of git, not of a run (`testing-floors.md:246-252`). | Add `(or-fixed "scaffold/build/blob.chiral" …)` to a sample: check S must fire — that path exists (708,039 B) and `git check-ignore -v` answers `.gitignore:8`, measured 2026-08-25. Then delete check S: the sample passes lint, and rank-2 laundering is live again. **Negative control, and it is the half that was missing:** on the tree as W0.4 leaves it, check S must report **zero** — `grep -rn '(or-fixed "\|(pv-fixed "' --include=*.chiral .` finds exactly one literal today (`e168_rank_floor.chiral:60`, illustrative), and W0.4 converts it in the same commit (D9). A lint that ships with a standing finding is a lint people learn to read past. |
| **G4** | The **conservation gate** is green at zero migrations and red on an unrecorded deletion. | **3** — `pv-meaning "the corpus is a finite measured set and the migration conserves it"`, over 79 files / 709 functions measured 2026-08-23 and re-measured 2026-08-25. | **Harness-run mutant, recorded through D6's seam** (it cannot be an in-gate `mut-run`: that observes the base by PATH and the mutant by self-contained TEXT — `test-floor.chiral:501-515` — while `corpus-count.chiral` imports the survey and the records; D7 corrects this). Rewrite the generated survey with `survey-files` decremented by one, rebuild and re-run: base `ob-exit 0`, mutant `ob-exit 1` ⇒ `mu-killed`. **That same mutant IS the tautology conviction:** a `corpus-count` that does not really read the survey exits 0 either way ⇒ `mu-survived` ⇒ `g-inadequate` before a check runs. ⚑ *The `mig-state`-stub construction this cell used to carry does NOT work and is retired — at zero migrations the stub changes neither side, so the mutant is `mu-killed` with it in place (D7 (a)); what the stub launders is caught by the FUNCTION law, not by this mutant.* ⚑ *Does NOT prove:* that a dynamically generated test was preserved — `test_stack_args_compile_run.py`'s 5 cases are invisible to the counting method on both sides (D10, D14). ⚑ *Per **D15**, the law this row gates is PER-FILE, so the rank-3 `pv-meaning` reads "the corpus is a finite measured set and the migration conserves it FILE BY FILE"; the survey mutant is unchanged (decrement one file's row) and so is the tautology argument it carries.* |
| **G5** | The **C-leg recording seam** carries a rank-1 expectation into a gate and is judged. | **1** — `pv-external "gcc" "12.2.0"`, transcribed by the harness (D6). | (i) Delete `scaffold/build/generated/c-leg-obs.chiral` ⇒ the suite root fails to resolve ⇒ the phase fails loudly rather than skipping. (ii) Route the same gate through `test-main` instead of `suite-main` ⇒ `observe-exs` truncates at the `obk-given` (`:797`) ⇒ `g-inadequate (in-unobserved)` — the floor refusing the shortcut, which is *why* the seam is `suite-fold`. **(iii) the STALENESS mutant, which (i) does not cover and which the audit added:** write a `c-leg-obs.chiral` by hand carrying a green verdict, do **not** run the leg, and run the suite. It must fail — because `ddc-c-leg.sh` deletes the file as its first act and never re-created it, so the import does not resolve. Delete that `rm -f` and the run goes green off a file nobody's leg produced: deletion fails closed, staleness does not, and only the `rm -f` makes them the same attack (D6). |
| **G6** | **E166's C leg still convicts byte-identically when its `Oracle` is passed as data** — the element's first target, handed over by E168 SPEC §6. | **1** — `pv-external`, G4 conviction at **1,077,624 B** under gcc 12.2.0 and ccomp 3.17 (`banks/verification.md` Shard 8; LEDGER E166 row). | ⚑ **Two mutants, because the row has two conjuncts and the recorded one falsifies only the first.** *(a) the leg still convicts* — ⚑ **D16 (author, 2026-08-25): CITED, NOT RE-RUN. E170 does not own this mutant.** For the record of what it is: re-invert `mach-c.chiral:138` (`((op-eqi) (c-infix "!="))` → `"=="`, line verified live 2026-08-25): one token, reversible, already run-and-reverted 2026-08-24 (`testing-floors.md:206-208`), F3 diverges on nearly every sample. **Its observation channel is `ddc-c-leg.sh`'s own F3/G4 — that is Phase 10, which gates this conjunct today with or without E170** — and it costs a full leg run (2m21s `--no-admission`, ≈3m45s full). It is a non-regression mutant, not evidence for anything E170 builds, and this cell says so rather than letting the row borrow Phase 10's strength. **D16 makes that the disposition and not just an observation: a mutant maintained in two elements rots in at least one, and the copy nobody runs is the one that stays green.** *(b) the `Oracle` is passed as DATA* — the conjunct E170 actually delivers, and it needs its own falsifier: change the recorded id in `c-leg-obs.chiral` from `(or-gcc "12.2.0")` to `(or-native "in-tree")` and re-run. `oid-prov` must turn the gate's provenance from `pv-external` (rank 1) into `pv-derived` (rank 4), and a gate carrying a differential with no rank ≤ 3 companion must fall to `g-inadequate (in-no-anchor)` — a one-value edit that moves the verdict is what "passed as data" means. If the verdict does not move, the id is decoration and the row is untestable. |
| **G7** | The **terminal enumeration** works: deleting `or-python` makes the compiler name every residual site. | **3** — `pv-meaning`: ⛑ *the mechanism is **name resolution**, not exhaustiveness, and the SPEC had it wrong.* Measured 2026-08-25 with `scaffold/build/B1` on a three-constructor probe: an arm naming a constructor the sum does not have is refused **`load: branch names a non-constructor`**; a case missing an arm with no default is refused **`load: non-exhaustive case`**. Deleting `or-python` is caught by the **first** — every residual site names it (`oid-prov:228`, `id-eq:259`, `oracle-ask:286`) and stops loading. Exhaustiveness is what catches an ADDED constructor. Also corrected: `id-eq` (`:256-264`) is exhaustive in its OUTER case but every INNER case carries `(_ false)`, so "no default arm" was never true of it. | ⛑ *The stated mutant — add a `(_ …)` arm to `oid-prov` — **cannot fail**, and is retired: with the `((or-python) …)` arm present the load fails by NAME whether or not a default sits beside it, and with that arm deleted the case is exhaustive over the remaining five either way. A default arm changes nothing in either direction.* **The mutant that can fail:** *replace* `oid-prov`'s `((or-python) (pv-derived …))` arm with a `(_ (pv-derived …))` catch-all, then delete `or-python` from `OracleId`. The tree now loads clean, `oid-prov` silently keeps answering rank 4 for whatever falls through, and the terminal move "finishes" with the enumeration disarmed — laundering by **removing the name**, which is the only way it is available. Revert restores the refusal. |

- **Green line.** Baseline **12 phases / 175 assertions / 82 roots / exit 0 /
  4m10.591s** at `f9441e4` (LEDGER E168 row, `ulimit -s unlimited; time bash
  scaffold/tests/run-native.sh`). W0 → +4 assertions (G1, G2 + its negative
  control, G3); W1 → +1 (G4); W2–W4 add one assertion per migrated file and
  **remove 79 `.py` files**; W5 → G5/G6/G7. Wall clock is **measured and
  recorded per wave**, not budgeted (D12). `ledger-lint` clean **A–S**.
- **W0 MEASURED (2026-08-25, `02a1d33`), per D12 — recorded because a number
  nobody attributes is a number the next wave inherits as a mystery.**
  **12 phases / 178 assertions / 82 roots / exit 0 / 11m18.589s.**
  - **+3 assertions, not +4, and the difference is a counting rule rather than a
    missing gate.** G1 (`e170_resolve_observe`) and G2 (`e170_fixed_digest`) are
    one suite assertion each — G2's negative control is its *case 9*, because a
    fixture reports one assertion whose exit code is the first failing case
    (`test-e168-floor.sh:124-127`, D13); counting its cases is how an inflated
    figure gets built. G3 is `ledger-lint` check S, which the suite does not run.
    The third new assertion is W0.5's `e170_suite_main`, which §4 did not list a
    row for.
  - **The wall clock is 2.7× the baseline, and MOST OF IT IS NOT THIS ELEMENT.**
    Phase 10 alone is **6m0.541s** of the total. The *unchanged* pre-W0 tree
    (`576963e`, run in a worktree against the same B1) runs that same phase in
    **4m18.478s** against the LEDGER's recorded **2m21s** — so the machine is
    ~1.8× slower today than when the baseline figures were taken, and the
    4m10.591s green line is not reproducible here independently of any change.
  - **E170 W0's own cost is +1m42s on Phase 10**, from F3 sweeping **39** samples
    instead of 36 (~34 s per fixture through mach-c → C → gcc → run). It is NOT
    the resolver import: that grows a test-floor-importing blob by **2 %**
    (`e168_cap_thread` 775,388 B → 794,099 B, measured by commenting the import
    out). Every fixture added to `scaffold/tests/samples/` in W2–W4 costs the C
    leg about half a minute, which is a real input to D13's per-file granularity.
  - ⚑ **CORRECTED 2026-08-26 — "the machine is ~1.8× slower" was a WORKLOAD
    comparison, and both halves of it are now settled.** The 4m18.478s at
    `576963e` was measured over **36** samples; the recorded 2m21s/1m41s were
    measured over **25** (`git ls-tree -r --name-only <rev> -- scaffold/tests/
    samples`: 25 at `e426a30`/`70ee90f`/`8db4af0`/`568699e`, 36 at `576963e`, 39
    at `880e0e0`). Two back-to-back `--no-admission` runs on an idle box the same
    day, same `B1`, gcc both, differing only in F3's marker column, gave
    **5m14.614s over 39 samples** and **1m41.358s over 25** — the second
    reproducing the recorded 1m41.6s/1m41.2s exactly, and 101.4 s + 11 × 15.2 s =
    4m29s accounting for `576963e`'s 4m18.478s with no machine-speed term. **The
    baseline is reproducible; the corpus is what grew.** Full table and method in
    `.planning/BUILD-ORDER.md`.
  - ⚑ **WHAT W2–W4 MUST DO WITH THEIR ~79 FIXTURES, now that F3 has a fourth
    marker (E166, 2026-08-26).** Every file added to `scaffold/tests/samples/`
    still needs a row in `ddc-c-leg.sh`'s table — an untabled file is a FAILURE,
    and that property is untouched. A fixture whose subject is the test floor is
    tabled **`floor`**, which asserts that `test-e168-floor.sh` judges it and is
    CHECKED against `--list` on every run; a fixture that exercises the backend is
    tabled with its documented exit code and swept. At 15.2 s per swept floor
    fixture, tabling the wave correctly is the difference between +20 s and +20
    minutes on every suite run — and marking one `floor` that the floor does not
    judge fails the leg rather than saving the time.
- **Done when:** `ls scaffold/tests/*.py` is empty, `grep -rn "or-python"
  scaffold/` returns nothing, `scaffold/tools/selfhost.py` is gone, and
  `bash scaffold/tests/run-native.sh` exits 0 with the conservation gate green
  at 0 files / 0 functions.

## 6. Residue & links

- **Deliberately unbuilt, each with its home:**
  - the in-tree survey (a directory crossing instead of a harness step) — **E148**
    (`getdents64` + `stat`, LEDGER:193 / CATALOG:413), which `test-runner.chiral:23`
    already names as the next crossing.
  - unforgeable `obk-given` observations and `MutRun`s — **E171** (a `->` body may
    not reach a crossing) and **E80** (the ambient build/exec externs), named in
    place at `test-floor.chiral:439-443`. E170 ships at detection-rung.
  - `emit-core.chiral`'s external coverage — **E167**; behavioural coverage of
    `lower.chiral` — **E169**. Neither is a surviving opinion (D1).
  - the resolver fork cost — `.planning/BUILD-ORDER.md:555-565`, refused, **no
    element minted** (E168 SPEC decision 2). Not reopened here.
  - dynamically generated tests, invisible to the survey method (D10, D14).
- **CLAIMED by this SPEC, and it was sitting unowned:** E168 §6 files *"Import
  resolution / the ~35% fork cost. Home: **nobody's yet**, and deliberately not
  minted."* E170 takes the **resolution** half (D8, W0.1/W0.2) because it is the
  element that needs it; the **fork-cost** half stays unowned and unminted, as
  E168 left it. Claiming an unowned residue is the deferral rule run forwards —
  no phantom element is invented, and the residue row stops being homeless.
- **Minted by this SPEC: nothing.** Every deferral above names an element that
  already exists, per CLAUDE.md's deferral rule.
- **FLAGs raised at the SPEC audit (2026-08-25) — BOTH ANSWERED BY THE AUTHOR
  the same day, before the wave that depends on them. Neither was ever blocking;
  both are now decisions with rows.** (1) *"709 counts `def test` occurrences and
  misses the 5 cases `test_stack_args_compile_run.py` generates at import time.
  Should the counting method be widened once, on both sides, to 714 … or should
  709 stand?"* → **D15: neither.** The count is not widened AND it stops being a
  law constant: conservation is per-file, both sides from the same survey, so the
  law conserves whatever the stated method sees and no file reaches `m-complete`
  vacuously. 709 stays a reported total with its method named, and the four
  documents that carry it are not edited, because none of them carried it as a
  law. (2) *"Should E170 own a mutant that re-inverts `mach-c.chiral:138` at
  all?"* → **D16: no.** G6(a) is cited to Phase 10 and never re-executed here;
  G6(b), the `Oracle`-as-data falsifier, stays E170's, because it tests what E170
  delivers.
- **FLAG routed here from the example audit — DISPOSITIONED, no edit needed.**
  The catalog row says `ddc-c-leg.sh 9/9` while `docs/banks/verification.md`
  Shard 8 and the script's `ok "` call sites say **10**. Measured 2026-08-25:
  `grep -c 'ok "' scaffold/tests/ddc-c-leg.sh` → **10**, and the tenth (`:447`,
  G3 admission) is guarded by `[ "$ADMISSION" = 1 ]` (`:429`), which
  `--no-admission` clears — *"skip G3 (what Phase 10 runs)"* (`:39`).
  **Both figures are right for different invocations:** 9 rows under Phase 10's
  `--no-admission` run, 10 under a full standalone run, which is also why the
  LEDGER E166 row carries *"10 gates green in 2m21s"* and *"9 gates green"* under
  ccomp without contradicting itself. The SPEC cites the count with the
  invocation named; no doc above this artifact is edited from here.
- **Related:** [[testing-floors]] · [[verification]] · [[E166-mach-c]] ·
  [[E170-corpus-migration]] · E168 (`scaffold/lib/test-floor.chiral` + its SPEC —
  the floor this lands on) · E148 (the deferred survey crossing) · E171 / E80
  (the unforgeability residue) · rung-1 `C3`/`C5`/`C6a`/`C6b`/`C7`.
