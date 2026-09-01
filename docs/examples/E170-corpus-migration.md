---
element: E170
slug: corpus-migration
title: **The corpus lands on the floor — the 709-function migration E168 exists to receive**
kind: BUILD-PROPER
reference_class: OURS
ours_source: scaffold/tests/ (79 files — a directory; the pack prints "none named")
status: reviewed
updated: 2026-08-25
---

# E170 — **The corpus lands on the floor — the 709-function migration E168 exists to receive**

> ⚑ **2026-09-01: the C leg this document treats as live is DROPPED**
> (`d8bcec5` the modules, `d0c5dd5` the four `e166_*` fixtures).
> `lib/lowering/c/{mach,assemble,emit}.chiral` and `prog/compiler-c.prog` are
> deleted, so every claim below that the second opinion is plural, alive, or
> convicting is **August's, and is left standing as the record**. The reason is
> the criterion: the leg shared `compile-front` and `compile-back` whole with the
> canonical instance and differed only at emit, which makes it a second target
> under one formulation, where self-verification needs different formulations.
> See `docs/decisions/decision-self-verification.md`. The findings about gates,
> mutants and provenance below are untouched by the drop.

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E170, the migration of the 709-function Python test corpus onto the
  E168 test floor — the step that lets the py floor and its driver
  (`scaffold/tools/selfhost.py` — measured live 2026-08-25; there is no
  `tools/selfhost.py` at the repo root) be deleted instead of merely deprecated.
- **Kind:** BUILD-PROPER. Not a port: only 68 of 709 assertions are mechanical.
- **Why chirality needs its own:** the corpus is currently *anchored on the thing being
  deleted*. 335 of its assertions are differentials against `py_check`; their
  content is not "this input yields that output" but "we and a second opinion
  agree". Delete the second opinion and the assertion does not become a porting
  task — it becomes a **lost proof**. E170 is the element that decides, per
  assertion, whether that proof is re-founded on a surviving opinion, re-anchored
  to a fixed committed artifact, or retired with its loss written down. Doing that
  by hand in 79 files, with the accounting in a comment, is how a corpus goes
  half-green and reports green.

## 2. Research

- **Reference class:** OURS — `scaffold/tests/` (79 files) as the source,
  `scaffold/lib/test-floor.chiral` (E168, shipped 2026-08-25) as the destination,
  `docs/testing-floors.md` as the contract, `docs/banks/verification.md` for the
  second opinions that survive.
- **Key findings:**
  1. **The split is measured, not estimated** (catalog row, measured 2026-08-23):
     79 files / 14,784 LOC / 709 test functions = **335 differential (41 files) +
     68 B1-driven (9 files) + 306 python-checker-only (29 files)**. Only the 68 are
     mechanical. 641 of 709 carry design content, and the 335 carry the hard kind.
  2. **A differential's meaning *is* its second opinion — and exactly one
     surviving opinion is BUILT.** ⛑ *Corrected at the example audit, 2026-08-25:
     the four opinions were listed as if they were four legs. They are one leg,
     two promises and a mechanism.*
     - **BUILT: E166's `Mach`→C leg** (gcc 12.2.0 / CompCert 3.17, G4 convicting
       byte-identical at 1,077,624 B under both — `docs/banks/verification.md`
       Shard 8). The gate is `scaffold/tests/ddc-c-leg.sh`, **10 `ok` rows** —
       that count measured 2026-08-25 as `ok "` call sites in the script and
       stated as 10 by Shard 8; the catalog row still says `9/9`, which is one
       row stale and is flagged rather than edited from here.
     - **NOT BUILT: E167's `tal`→C leg.** A catalog row (`banks/verification`
       Shard 8: *"E167 still a catalog row"*), and Shard 5 residue item 2 puts
       `emit-core.chiral` on in-house coverage only. Nothing can be re-founded on
       it until it exists.
     - **DOES NOT RUN TODAY: the `rocq/` floor.** `banks/verification` §5 item 3:
       `coqc 8.16.1` is installed but `rocq/Chirality/*.v` are written against
       Rocq 9's `From Stdlib Require Import` rename, which 8.16 rejects — a
       per-file source edit — *and* the formalization is still two files about
       one integer type. Treat it as promised, not available.
     - **AVAILABLE AS A MECHANISM: a fixed artifact**, i.e. `or-fixed` (below).
     Everything else in the corpus was differing against a corpse. The whole
     re-founding argument turns on this list, so it is stated as build-state
     rather than as an inventory.
  3. **E168 already convicts a bad re-founding.** A gate carrying a
     differentially-minted expectation (`DiffExpect`, minted at one site —
     `diff-expect`; ⛑ *audit correction: the constructor `dx-minted` is public
     like every other in this tree, so a caller CAN forge one. `test-floor.chiral`
     §6 says so in place and E168's G8 lint is the grep under it. Detection, not
     prevention*) is `g-inadequate` unless the same gate also holds an
     expectation at **rank ≤ 3** (`prov-rank` over `ExProv`). So the migration
     cannot quietly rebase 335 assertions onto a weaker opinion and call it done —
     the floor fails the gate. The floor decides *adequacy*; E170 decides
     *disposition*.
  4. **The rank-2 exemplar was MISDESCRIBED, and the doc has since been
     corrected.** ⛑ *Rewritten at the example audit, 2026-08-25.* This finding
     read that the canonical rank-2 artifact is `scaffold/build/blob.chiral` and
     is gitignored. The gitignore half is true (`.gitignore:8`; `git ls-files
     scaffold/build/` is empty, and the resolver re-derives the file) — but that
     blob was never the E161 G0 anchor. The anchor is the gate's **own expected
     blob**: `want-lib.chiral` / `want-root.chiral`, heredocs inside the tracked
     `scaffold/tests/test-module-kind.sh:465-480,490-499`, byte-compared by
     `blob_is` (`:195-207`). Both providers were mutated; that text was not.
     `docs/testing-floors.md` §*Rank 2's anchor* now records this and carries the
     five-part admission test for a NEW anchor, which is what §4 move 3 below
     builds on. **So the FLAG this example raised is answered, not open** — and
     the rank-2 definition was not weakened to answer it.

## 3. Conventional (other-language) approach

How this is done outside chirality — the existing Python corpus (representative of
the 335 differential assertions, the shape that cannot be ported):

```python
# scaffold/tests/… — one of 335 in 41 files
class TestBeta(unittest.TestCase):
    def test_beta_normalizes(self):
        src = "((lam (x) x) 7)"
        # the oracle is IMPORTED, never passed: py_check is ambient
        self.assertEqual(chirality_eval(src), py_check.normalize(parse(src)))

    def test_kernel_rejects_bad_app(self):
        with self.assertRaises(py_check.TypeError_):
            py_check.infer(parse("(7 7)"))
```

- **Assumptions it bakes in:**
  - **The oracle is ambient.** Nothing in the signature records that this
    assertion's meaning depends on `py_check`. Delete the import and the file
    raises `ImportError` — which *reads like a port task* and is actually a lost
    proof. The corpus cannot tell you which of its assertions still mean anything.
  - **Provenance and rank are nowhere.** "How do we know the expected value?" is
    answered by the author's memory, not by a field, so no tool can ask whether a
    re-anchoring was a downgrade.
  - **Collection is effectful.** Suites exist because import ran; there is no
    suite *value* to inspect, count, or reconcile against a measured total.
  - **The accounting lives in prose.** "29 files still to migrate" is a note in a
    checklist, not a checked assertion, so a partially-migrated corpus that exits 0
    is indistinguishable from a finished one.
  - **Second half of the corpus asserts on internals** (`py_check.TypeError_`,
    py-side data shapes) that have no chirality referent at all — these are not
    translatable in either direction.

## 4. The chirality idea

- **Chirality features in play:** boundary sums (parse the classification ONCE, carry
  it as a value); QTT linearity (`(1 o Oracle)`, `(1 bld Builder)` — the floor's
  own binders); the `->` vs `=>` membrane (a `Suite` is *built* purely and *run*
  across the membrane); exhaustive `case` coverage as the enumeration mechanism;
  totality (the migration terminates because the corpus is a finite measured list).
- **The reframing, in four moves:**
  1. **The oracle becomes data at the call site — necessary, and NOT
     sufficient.** `Oracle` is a single-ctor `data` over `OracleId`, handed to
     `differ` as an argument, so the *shape* of a re-founding is a data change:
     `(oracle (or-ccomp "3.17"))` or `(oracle (or-gcc "12.2.0"))` where
     `(oracle (or-python))` used to sit. When `or-python` reaches zero
     occurrences it is **deleted from the `OracleId` sum**, and every `case` that
     still depended on it fails coverage. **The compiler enumerates the residue**
     — no grep step, and no way to finish while a site still points at the
     deleted opinion.
     ⛑ **Measured at the example audit, 2026-08-25, because the data-change
     claim on its own is false.** `oracle-ask` (`test-floor.chiral` §5) answers
     `or-ccomp`, `or-gcc` and `or-rocq` with
     `(ob-nobuild "an external leg the harness runs, not this floor: …")` — the
     external legs are run by the SHELL harness and are not reachable from
     inside the floor. So `differ` over a C-leg `Oracle` yields `df-unasked`,
     `diff-expect` returns `ex-refused (xr-unasked …)`, and **nothing is
     minted**. The two `OracleId`s the floor can actually ask today are
     `or-native` (build-and-run in-tree, rank 4) and `or-fixed` (open a committed
     file, rank 2). Re-founding 335 differentials therefore needs one of: the
     harness supplying the C-leg observation and the gate carrying it as a
     hand-written `obk-given` `Expect`; a new crossing that spends build
     authority on an external compiler; or `or-fixed` against an artifact that
     leg minted. **Which of those E170 builds is an open question for the spec
     run (§6), not something this example settles.**
  2. **Disposition is a closed sum, not a comment.** Each of the 709 source
     functions is classified exactly once, at the migration boundary, into
     `d-ported` / `d-rewritten` / `d-refounded` / `d-reanchored` / `d-retired`,
     and the retirement carries a typed `Loss` — *what* stopped being provable —
     rather than a deleted line. Deleting an assertion is allowed; deleting it
     silently is not.
  3. **A rank-2 anchor gets a real definition and a real home — and the TYPE
     for it already exists.** The admission test (now carried by
     `docs/testing-floors.md` §*Rank 2's anchor*, which this example proposed and
     the author accepted): (a) **committed in this repo** and not gitignored;
     (b) **not written by the build** — anything a build or promote step
     regenerates is not fixed; (c) carrying its **digest in chirality source**;
     (d) recording **which oracle minted it and when**; (e) small enough to read
     in review. Proposed home: `scaffold/tests/fixed/`. By that test
     `scaffold/build/blob.chiral` **is not** a rank-2 artifact.
     ⛑ **Audit correction — do not mint a second type for this.** The floor
     already refracts a fixed artifact: `(or-fixed (path Str) (digest Bytes))`
     is an `OracleId`, and `oracle-ask`'s `or-fixed` arm `openat`s the path,
     reads it, closes the fd and returns `(ob-bytes …)`; `oid-prov` maps it to
     `(pv-fixed path digest)`, rank 2. What is genuinely **missing** is smaller
     and sharper than a new type: that arm **never compares `dg`** — the digest
     is carried and not checked (measured 2026-08-25 against the live floor) —
     and nothing records the minting oracle or date. E170's work here is the
     digest check plus the minting record, over `or-fixed`, not a parallel
     `Anchor` sum beside it.
  4. **The unit is the source file, and adoption is proved by absence.** One
     module and one exported `Suite` value per source `.py`, tagged with the phase
     it belongs to; a phase is a *list of suites*, not a mega-module — which
     `test-main (=> (List Suite) I64)` takes directly, so the aggregation shape is
     the floor's own. ⛑ *Two measured limits on this unit, 2026-08-25.* (i) The
     `(phase Str)` field is carried and **never read** — `suite-fold`,
     `observe-suite` and `gate-line` all ignore it — so "grouped by phase" is a
     convention the floor does not enforce today. (ii) A module with no
     `compile-main` is **not swept by Phase 7** (`banks/verification` §5 item 4
     records `lib/reflect-floor.chiral` going unnoticed for exactly that reason),
     so 79 suite-exporting modules need an importing root per phase or they
     compile nowhere. The
     done-condition per file is **the `.py` is deleted** — so this repo's measured
     "built but unadopted" failure (4 occurrences) is structurally impossible
     here: an unadopted suite is visible as a surviving `.py`, still classified in
     the rung-1 checklist, still failing `ledger-lint` check O.
- **What chirality makes impossible here — at E168's own honest rung.** ⛑ *Retitled
  at the audit: the floor's register is DETECTION, not prevention (`test-floor.chiral`
  §4 and §6 both say so of `Builder` and `dx-minted`), so "impossible" is claimed
  only where a type really refuses, and the rest is named as what it is.*
  - **Refused by the type:** an assertion whose second opinion is ambient —
    `Oracle` is a linear argument, and an `Expect` has no arity that omits its
    `ExProv`.
  - **Refused by the type:** a differential-minted expectation moved into
    `checks` to disarm the rank floor — `DiffExpect` is its own type, and the
    one-word field swap that used to compile is now `load: type mismatch`.
  - **Scored, not refused:** a differential silently rebased onto a weaker
    opinion — the gate scores `g-inadequate` (E168, Phase 12) when it runs. A
    gate nobody runs scores nothing.
  - **Convention plus a gate:** a "ported" test that no longer means anything —
    the only *typed* way to drop one is `d-retired` with a `Loss`. Nothing stops
    a hand deleting the line and the record together; what catches that is the
    reconciliation gate's totals, and only if its inputs come from the tree
    (§5's note on `corpus-gate`).
  - **NOT structural, and this is the load-bearing correction:** "a `.py` cannot
    be deleted while its `Mig` is `m-partial`". Nothing inside chirality enumerates
    `scaffold/tests/*.py` — the floor has no directory crossing (getdents is
    still the next one, `test-runner.chiral:23`), and `ledger-lint` check O reads
    GLOB patterns from the RUNG1 C-inventory, so it fires only on a file that
    EXISTS and matches none of them. A deletion cannot trip it. The deletion rule
    is a discipline plus a gate that has to be fed the tree; §6 states it that
    way.
  - **A suite that exists but never runs** is still dead code rather than a
    passing test — but construction is not purely `->`: a `Gate` needs a
    `MutRun`, which only `mut-run` produces, and `mut-run` is `=>`. The live
    adopter shows the shape — `sample-suite (-> MutRun Suite)` is pure *given*
    evidence gathered under a cap by `mk-suites` (`test-runner.chiral:69,105`).

## 5. Chirality example (fleshed)

```chirality
; scaffold/lib/corpus-migrate.chiral — the migration's own accounting.
; E168 built the floor (Expect / DiffExpect / Oracle / Gate / Suite / test-main
; and the rank rule).  This module adds ONLY what the migration needs that the
; floor deliberately does not know: what happened to each of the 709 source
; functions, and whether a source file has earned its deletion.

(import "prelude")
(import "test-floor")

; ---------------------------------------------------------------- dispositions
; Boundary sum (docs/pattern-boundary-sums.md): the migration classifies each
; source function ONCE and carries the classification as a value.  A "TODO port
; me" comment in a .py is exactly the disguise this sum removes.

(data Loss ()
  (l-no-second-opinion)            ; nothing survives to differ against
  (l-py-internal (sym Str))        ; asserted a py_check internal with no chirality referent
  (l-subsumed    (by Str)))        ; another gate already convicts this behavior

(data Disp ()
  (d-ported     (fn Str))                   ; (b) 68 B1-driven — mechanical
  (d-rewritten  (fn Str))                   ; (c) 306 checker-only — chirality-in-chirality
  (d-refounded  (fn Str) (o OracleId))      ; (a) 335 differential — surviving opinion
  (d-reanchored (fn Str) (dig Bytes))       ; (a) no opinion left, but a fixed artifact
                                            ;     ⛑ Bytes, not Str: the floor's own
                                            ;     digests are Bytes (`or-fixed` /
                                            ;     `pv-fixed`), and two spellings of one
                                            ;     digest is the drift this sum exists
                                            ;     to remove (audit, 2026-08-25)
  (d-retired    (fn Str) (why Loss)))       ; (a) meaning did not survive — loss recorded

; ------------------------------------------------------------- rank-2 anchors
; ⛑ REWRITTEN AT THE AUDIT (2026-08-25).  This section minted an `Anchor` sum
; beside the floor.  The floor already refracts a fixed artifact:
;   (or-fixed (path Str) (digest Bytes))   -- an OracleId  (test-floor.chiral §5)
;   oid-prov (or-fixed pa dg) => (pv-fixed pa dg)          -- rank 2
;   oracle-ask's or-fixed arm: openat, read-fd-all, close, (ob-bytes …)
; So the artifact-as-opinion mechanism EXISTS and is askable from inside the
; floor -- the one OracleId that is.  Two things are genuinely missing, and they
; are what E170 builds here:
;
;   (1) THE DIGEST IS CARRIED AND NEVER CHECKED.  `oracle-ask` returns the bytes
;       it read and ignores `dg`, so an edited fixture silently becomes the new
;       truth -- the exact failure the digest is there to refuse.  The check
;       belongs beside `or-fixed`'s arm, not in a second type.
;   (2) THE MINTING RECORD.  Which opinion produced the artifact, and when.
;       `docs/testing-floors.md` §*Rank 2's anchor* makes this admission test
;       (4) and it has no field anywhere yet.

(data Minting () (minted-by (o OracleId) (date Str)))    ; admission test (d)

; the check the floor is missing: read the fixture, compare against the digest
; carried in SOURCE, and answer honestly when the bytes do not match.
(declare anchor-check (=> (1 bld Builder) OracleId Minting ObsR))
; …  or-fixed arm only; every other OracleId is refused by name rather than
;    opened as a file (the `obk-given` mistake, one door down).
; NOTE: `scaffold/build/blob.chiral` fails the admission test on (a), (b) and (e)
; — gitignored, resolver-regenerated, and 660 KB.  It was also never the E161 G0
; anchor: that was the heredoc pin in test-module-kind.sh (§2 finding 4).

; ------------------------------------------------------- per-file bookkeeping
(data Mig () (mig (src Str) (fns I64) (disps (List Disp))))

(data MigR ()
  (m-complete)
  (m-partial (done I64) (of I64)))

(declare mig-state (-> Mig MigR))                ; pure: length disps vs fns
(def mig-state
  (lam (m)
    (case m
      ((mig src fns ds)
        (let ((n (length Disp ds)))           ; ⛑ `length` takes its erased type
          (if (=i n fns) (m-complete) (m-partial n fns)))))))

; A source .py may be deleted iff its Mig is m-complete AND its suite ran green.
; Both halves are values, so "is this file done?" is a check, not a judgement.
(declare mig-deletable (-> Mig GateR MigR))
; …  (m-complete only when mig-state is m-complete and the GateR carries no
;     CheckFail and no Inadequacy — copy the GateR ctor names from test-floor.chiral)

; ------------------------------------------------- one Suite per source file
; The migration unit is the SOURCE FILE: one module, one exported suite value,
; tagged with the run-native phase it belongs to.  A phase is a list of suites,
; not a module — that is what keeps 79 files from becoming one mega-module, and
; `test-main` takes `(List Suite)` directly.
;
; ⛑ AUDIT CORRECTION: "construction is PURE, the only crossing is test-main" is
; false.  A `Gate` cannot be built without a `MutRun`, and `mut-run` is `=>` —
; evidence is gathered BEFORE any gate exists.  The live adopter has the shape:
; `sample-suite (-> MutRun Suite)` is pure GIVEN evidence that `mk-suites`
; (`=>`, under its own cap) produced (test-runner.chiral:69,105).  So a per-file
; suite is a pure function of the evidence handed to it, and each file's root
; spends build authority once to gather that evidence.

(declare kernel-beta-suite (-> MutRun DiffExpect Suite))  ; scaffold/tests/kernel-beta.chiral
(def kernel-beta-suite
  (lam (adequacy minted)
    (suite "phase-4-kernel"
      (cons (beta-gate adequacy minted)
      (cons (app-mismatch-gate adequacy)
        nil)))))                                   ; …  one gate per source function

; ------------------------------------------ re-founding ONE differential (a)
; BEFORE (python):  assertEqual(chirality_eval(src), py_check.normalize(parse(src)))
; AFTER:  the second opinion is an ARGUMENT — but the minting is a CROSSING and
; the gate is pure in what it receives.
;
; ⛑ AUDIT: this block used to hand-write `(dx-minted (ex …))` inline.  That is
; the one thing E168's G8 lint forbids — `(dx-minted ` may be constructed at
; exactly one site, `diff-expect`'s — and forging it here would have shipped the
; example's own guardrail disarmed.  The minted value is a PARAMETER instead,
; produced upstream by `differ` + `diff-expect` under the cap:
;
;   (case (differ bld (oracle A) (oracle B) src)
;     ((differ-r d bld2)
;       (case (diff-expect (obk-given "beta/normalizes") d)
;         ((ex-refused why) …)                    ; xr-differ / -common-mode / -unasked
;         ((ex-ok minted)   … build the gate with `minted` …))))
;
; ⚑ And with A = `(or-ccomp "3.17")` today that path lands in `ex-refused
; (xr-unasked …)`: `oracle-ask` answers every external leg `ob-nobuild`.  §4
; move 1 and §6's open question own that; the shape below is what it looks like
; once an askable opinion exists.
(declare beta-gate (-> MutRun DiffExpect Gate))
(def beta-gate
  (lam (adequacy minted)
    (gate "beta/normalizes"
      (cons anchor-expect nil)                    ; rank ≤ 3 companion — the floor's rule
      (cons minted nil)
      adequacy)))
; …  `anchor-expect` is a hand-written `Expect` at rank ≤ 3 — `(ex (obk-root
;    "samples/beta.chiral") (ob-exit 7) (pv-meaning "…"))` is the cheap one, an
;    `or-fixed` artifact the rank-2 one.  Arities are the floor's — copy them.

; The gate above holds TWO expectations on purpose: the differential one, and a
; rank ≤ 3 companion.  Without the companion E168 marks the gate g-inadequate.
; That is the migration's guardrail against re-founding on nothing.

; ------------------------------------------ retiring ONE differential (a, cont.)
; Some of the 335 have no surviving opinion: they asserted py_check's own
; internals.  These are RETIRED, not transcribed — and the retirement is data.
(def retired-py-typeerror Disp                    ; ⛑ a value, not a nullary lam:
  (d-retired "test_kernel_rejects_bad_app"        ;    `(lam () …)` and `(-> T)` have
             (l-py-internal "py_check.TypeError_")))  ; zero precedent in scaffold/lib

; --------------------------------------------- the reconciliation is a GATE
; The anti-half-green device: the corpus accounting is asserted inside the
; suite, not tracked in a checklist.  It convicts when the dispositions do not
; sum to the measured corpus, or when a .py was deleted while m-partial.
;
; ⛑ AUDIT — THREE MEASURED CONSTRAINTS, because as first drafted this gate could
; not have been built, could not have gone green, and for its most important
; conjunct could not have failed.
;   (1) `(mut-run-none)` DOES NOT EXIST.  `MutRun` has exactly two arms,
;       `mu-killed` and `mu-survived`, and both carry observations `mut-run`
;       made.  There is no "this gate has no mutant" arm, on purpose.  So a
;       counting gate needs a REAL mutant: mutate the fold that computes the
;       totals (e.g. a `mig-state` that answers `m-complete` unconditionally),
;       build and run both, and the gate carries the resulting `mu-killed`.
;   (2) THE OBSERVATION MUST BE `obk-root`, NOT `obk-given`.  `observe-exs`
;       refuses an `obk-given` expectation by name and returns NO observations,
;       after which `fold-checks` scores the gate `g-inadequate (in-unobserved
;       …)`.  A gate of hand-computed `obk-given` counts run through `test-main`
;       is therefore never green.  The reconciliation has to be a PROGRAM that
;       folds the records and exits with the count, observed by building and
;       running it.
;   (3) WHERE `ms` COMES FROM IS THE WHOLE QUESTION.  If the `(List Mig)` is
;       hand-maintained beside the constants, this gate compares the migrator's
;       bookkeeping against the migrator's own totals: it convicts an arithmetic
;       slip and NOTHING ELSE — it cannot see a `.py` deleted with no record, or
;       a record for a file that no longer exists, because nothing here reads the
;       tree (no getdents crossing; `ledger-lint` check O cannot see a deletion
;       either).  For the gate to be able to fail for the reason it claims, `ms`
;       must be GENERATED from the tree and the totals must come from a dated
;       measurement outside it (709 / 79, 2026-08-23).  Otherwise it is a
;       tautology wearing a gate's clothes, which is the shape this element
;       exists to end.
(declare corpus-gate (-> (List Mig) MutRun Gate))
(def corpus-gate
  (lam (ms adequacy)
    (gate "corpus/reconciles"
      (cons (expect-total-fns 709)                 ; measured 2026-08-23, outside `ms`
      (cons (expect-files 79)
      (cons expect-no-partial-deleted nil)))
      (the (List DiffExpect) nil)                  ; no differential here — pure counting
      adequacy)))
; …  each `expect-*` is an `(ex (obk-root "tests/corpus-count.chiral") (ob-exit N)
;    (pv-fixed …|pv-meaning …))`; the root it names is the program that folds the
;    GENERATED `ms` and exits with the number.

; ------------------------------------------------------- the terminal move
; When `or-python` reaches zero occurrences, DELETE the constructor from
; OracleId in test-floor.chiral.  Every remaining `case` over OracleId then fails
; coverage and the compiler enumerates the sites that still depended on the
; deleted opinion.  That enumeration is the completion check for part (a).
```

- **Knobs to modify:** the `OracleId` a differential is re-founded on
  (`or-ccomp` / `or-gcc` / the `rocq/` floor / an `Anchor`); the `Loss`
  constructors, if a fifth kind of loss shows up in the 335; the phase string a
  file's suite is tagged with; the fixture root (`scaffold/tests/fixed/`); the
  measured totals in `corpus-gate` (they are *measurements* — update with the
  command that produced them, per the estimate-annotation convention).
- **Deliberately omitted:** the 79 per-file suites themselves (mechanical once
  this shape is fixed); the re-expression of run-native Phases 1 and 3–11 as
  `Suite` values (same shape, named here as the element's second half); anything
  about *how* `bin/chirality-resolve.sh` forks — see the cost note in §6.
- **⛑ The floor's arities, ATTESTED at the example audit (2026-08-25) rather than
  left as "copy from the floor" — read live from `scaffold/lib/test-floor.chiral`,
  854 L, so a spec run does not have to re-derive them:**
  - `(data ExProv () (pv-external (tool Str) (ver Str)) (pv-fixed (path Str)
    (digest Bytes)) (pv-meaning (law Str)) (pv-derived (why Str)))` — ranks 1–4
    via `prov-rank`, no default arm.
  - `(data ObsKey () (obk-root (path Str)) (obk-given (label Str)))` ·
    `(data Obs () (ob-exit (code I64)) (ob-bytes (b Bytes)))` — no `ob-text` arm,
    on purpose · `(data Expect () (ex (what ObsKey) (want Obs) (src ExProv)))`.
  - `(data OracleId () (or-python) (or-ccomp (ver Str)) (or-gcc (ver Str))
    (or-rocq) (or-fixed (path Str) (digest Bytes)) (or-native (nm Str)))` ·
    `(data Oracle () (oracle (id OracleId)))` · `(data Builder () (builder (via Str)))`.
  - `differ : (=> (1 bld Builder) (1 a Oracle) (1 b Oracle) Bytes DifferR)` ·
    `diff-expect : (-> ObsKey DiffR ExpectR)` ·
    `(data DiffExpect () (dx-minted (e Expect)))` ·
    `(data ExpectR () (ex-ok (e DiffExpect)) (ex-refused (why ExRefusal)))`.
  - `(data MutRun () (mu-killed (label Str) (base Obs) (mutated Obs))
    (mu-survived (label Str) (obs Obs)))` — **two arms, both carrying
    observations** · `mut-run : (=> (1 bld Builder) Str Mutant MutRunR)`.
  - `(data Gate () (gate (name Str) (checks (List Expect)) (diffs (List DiffExpect))
    (adequacy MutRun)))` · `(data Suite () (suite (phase Str) (gates (List Gate))))` ·
    `test-main : (=> (List Suite) I64)`.
  - `(data GateR () (g-green (name Str) (n I64) (worst I64)) (g-red (name Str)
    (why CheckFail)) (g-inadequate (name Str) (why Inadequacy)))` ·
    `(data Inadequacy () (in-mutant-survived (label Str)) (in-nothing-asserted)
    (in-no-anchor) (in-unobserved (what ObsKey)))`.

## 6. Use / modify notes

- **Lands in:**
  - `scaffold/lib/corpus-migrate.chiral` (new — the `Disp` / `Loss` / `Mig` /
    `Anchor` types and the reconciliation gate; ledger module `corpus-migrate`).
  - `scaffold/lib/test-floor.chiral` (edit — `OracleId` gains the surviving
    opinions and eventually loses `or-python`).
  - `scaffold/tests/<file>.chiral` × 79 (new — one module, one exported suite).
  - `scaffold/tests/fixed/` (new — committed rank-2 fixtures, never build-written).
  - `scaffold/tests/run-native.sh` (Phases 1, 3–11 re-expressed as `Suite` values).
- **Conformance target:** the element's first checkable target, handed over by the
  E168 SPEC §6 — **E166's C leg still convicts byte-identically when its `Oracle`
  is passed as data rather than wired in** (`ddc-c-leg.sh`, **10 `ok` rows** —
  `docs/banks/verification.md` Shard 8 and 10 `ok "` call sites measured
  2026-08-25; the catalog row's `9/9` is one stale, flagged not edited from here;
  G4 at 1,077,624 B under gcc 12.2.0 and CompCert 3.17). Then: every migrated file's suite green
  under `test-main` with zero `g-inadequate`, the reconciliation gate summing to
  the measured corpus, and finally `or-python` deleted with the compiler reporting
  no residual sites.
- **Per-file done-condition (the deletion rule):** a `.py` may be deleted iff
  (i) its `Mig` is `m-complete` — every source function in it has a `Disp`;
  (ii) its suite is registered and runs green; (iii) no gate in it is
  `g-inadequate` (differential without a rank ≤ 3 companion); (iv) the rung-1
  C-inventory's **counts** (`scaffold/tests/*.py`, currently *79 files /
  14,784 LOC*, owners `C3`/`C5`/`C6a`) are re-measured in the same commit.
  ⛑ *Conjunct (iv) said "so `ledger-lint` check O never sees an unclassified
  `.py`", and that is not how check O works — read live 2026-08-25
  (`tools/ledger-lint/ledger-lint.py:644-676`): it reads GLOB PATTERNS out of the C-inventory
  and fires only on a file that EXISTS and matches none of them. `scaffold/tests/*.py`
  classifies the corpus however many files remain, so a deletion can never trip
  it and no row needs editing to keep it quiet. What deletion actually rots is
  the COUNTS in that table, which nothing mechanical checks — so re-measuring
  them is the discipline, and check O is the tripwire for a NEW unclassified
  `.py`, not for this migration's deletions.* Partial migration stays honest only
  to the extent the reconciliation gate is fed from the tree (§5's constraint 3);
  a partial file's surviving `.py` is visible to a human and to nothing else.
- **Cost — what this element owns and what it refuses:** owned — the `Builder`
  is linear (`(1 bld Builder)`), so **the build-and-run authority is threaded
  through a whole suite and the type says how many programs a gate built**;
  `obs-list-r` / `obs-suite-r` are what carry the one cap across many
  observations. ⛑ *Audit correction: this read "a program is built once and
  observed many times", and the floor does not do that. `observe-exs` calls
  `observe` per `obk-root` expectation, and `observe` compiles and runs the file
  every time — two expectations naming one path build it twice; there is no ELF
  cache. `mut-run`'s own comment states the real property: "TWO observations are
  performed here, which is the whole point of the cap being linear rather than
  ambient". Batching the CAP is not batching the BUILD, and if per-file suites
  make the second one matter, that is a cost E170 measures rather than a property
  it inherits.* Refused — the fork cost of `bin/chirality-resolve.sh` (**~35 % of the
  suite's wall clock**, measured and reasoned in `.planning/BUILD-ORDER.md:555-565`:
  ~7 forks per module per root, 51.5 s of 81.3 s off-CPU in one phase, 120× slower
  than a fork-free read; the percentage and the current 4m10s wall clock are
  separate measurements and are not multiplied together here) is the *harness's*
  cost, fixed by the resolver/wielder lane, not by reshaping suites. That matches
  the settled disposition — E168 SPEC decision 2, *"not E168, and no element is
  minted for it"* — and no follow-on element is invented here either, per
  CLAUDE.md's deferral rule.
- **Open questions (for the spec run):**
  1. **How many of the 335 can the `rocq/` floor actually re-found today?** It
     needs a per-file `From Stdlib Require Import` → `Require Import` rename *and*
     the formalization is still two files about one integer type. If the honest
     answer is "almost none", the 335 land mostly on the C legs, `Anchor`s, and
     `d-retired` — and the expected `d-retired` count should be predicted here and
     measured later, not discovered mid-migration.
  2. **`scaffold/tests/fixed/` — right home and right granularity?** One fixture
     per gate, or one per file? And what mints the first ones, given that a
     fixture minted by the code under test is rank 4, not rank 2?
  3. **Phases 1, 3–11: one `Suite` per phase or per script?** The floor's `Suite`
     carries `(phase Str)`, which points at per-file suites aggregated by phase —
     but the shell phases are not per-file.
  4. Exact `differ` / `diff-expect` arities and the `GateR`/`Inadequacy`
     constructor names to case on (copy from `test-floor.chiral`).
  5. Migration order: 68 mechanical first (cheap proof the pipeline works), or the
     41 differential files first (they carry the risk)?
  6. ⛑ *Added at the example audit.* **How does an external leg's observation
     reach a gate?** `oracle-ask` answers `or-ccomp` / `or-gcc` / `or-rocq` with
     `ob-nobuild` — the harness runs those legs, the floor cannot. Three shapes,
     and the spec has to pick one: (a) the shell harness produces the observation
     and the gate carries a hand-written `obk-given` `Expect` (then the gate must
     be handed its observations rather than run through `observe-exs`);
     (b) a new crossing that spends build authority on an external compiler;
     (c) the leg mints an `or-fixed` artifact and the differential runs against
     that. Until one is built, "re-founded on the C leg" is a plan, not a gate.
  7. ⛑ *Added at the example audit.* **What generates the `(List Mig)`?** The
     reconciliation gate can only fail for the reason it claims if its records
     come from the tree rather than from the migrator's hand (§5 constraint 3),
     and nothing in the floor enumerates a directory — getdents is still the next
     crossing (`test-runner.chiral:23`). Shell-generated `ms`, a getdents
     crossing, or an honest narrowing of what the gate claims?
- **FLAG (raised here, ANSWERED upstream 2026-08-25 — kept as the record):**
  this example flagged that `docs/testing-floors.md:198-199` offered
  `scaffold/build/blob.chiral` as the canonical rank-2 "fixed committed artifact"
  while that path is gitignored. The author's ruling went further than either
  branch the FLAG offered: the *description* was wrong, not the rank. The E161 G0
  anchor was the gate's own heredoc pin in `scaffold/tests/test-module-kind.sh`,
  which is committed and is not build-written; the page now says so in
  §*Rank 2's anchor* and carries this example's five-part admission test for new
  anchors verbatim. Nothing here is open.
- **FLAG (bundle vs catalog) — ANSWERED upstream 2026-08-25.** The pack printed
  `OURS baseline — scaffold/chirality/tools/selfhost.py NOT FOUND` because
  `tools/pack/pack.py:552-563` takes the first backticked `.py` span in the
  catalog row and resolves it under `scaffold/chirality/`. The catalog row no longer
  writes that path in a code span, so the bundle now says "none named" and the
  reference column carries the real baseline (`scaffold/tests/`, 79 files). The
  live driver is `scaffold/tools/selfhost.py`; there is no `tools/selfhost.py` at
  the repo root.
- **Related:** [[testing-floors]] · [[verification]] · [[E166-mach-c]] ·
  E168 (`scaffold/lib/test-floor.chiral` + its SPEC — the floor this lands on) ·
  E167 (`tal`→C leg — a catalog row, NOT built; a promised opinion, not a
  surviving one) ·
  rung-1 checklist `C3`/`C5`/`C6a`/`C6b`/`C7` (the `.py` deletion accounting).
