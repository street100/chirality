---
element: E168
slug: test-floor
title: "**The test floor the Python corpus migrates INTO** — an expectation declares where its value came from, and a gate carries a mutant it actually ran."
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: drafted
updated: 2026-08-25
---

# E168 — **The test floor the Python corpus migrates INTO** — an expectation declares where its value came from, and a gate carries a mutant it actually ran

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

- **Element:** E168 — the *shape* of the native test system: a chirality library in
  which a test is a **value** carrying (a) the **provenance** of its expected
  result and (b) for a gate, the **run result of a mutant**; plus the pure fold
  that turns a list of such values into a verdict. It is a **refinement of the
  suite we already have**, not a greenfield runner and not the migration itself.
- **Kind:** BUILD-PROPER.
- **Why chirality needs its own:** the corpus that must land here is **79 files /
  14,784 LOC / 709 test functions**, and it splits three ways — **335 assertions
  in 41 files are differentials against the Python checker** (they cannot be
  ported: delete Python and there is nothing left to differ against), **68 in 9
  files are B1-driven** and port mechanically, and **306 in 29 files are
  python-checker-only** and must be rewritten as chirality-in-chirality. *Those 306 are
  what needs a floor to land in.* Migrating 709 tests into today's shape bakes
  the defect in for another year; **migrating twice is worse than designing
  first**, and that is the whole reason this element is separate from the
  retirement it enables.
- **What it is NOT:** the migration. Re-founding the 335 differentials, and the
  file-by-file port of the other 374, are downstream work that consume this
  floor. One element, one blueprint.
- **Live baseline** (measured 2026-08-25, not the catalog's snapshot): the
  native suite is **eleven phases, 163 assertions, 82 roots, exit 0**;
  `lib/test-runner.chiral` is **68 L** and exposes ~~`test-main`~~ **`run-one` /
  `run-all` / `manifest` / `compile-main`** — ⚑ *corrected at the example audit,
  2026-08-25: there is no `test-main` anywhere in the tree (`grep -rn test-main
  scaffold/`, zero hits). §5's `test-main` is therefore NEW surface, and "adopted
  by `test-runner`" means that file is rewritten around it, not that an existing
  entry point is re-typed;* `scaffold/tests/samples/` holds 25 samples whose exit
  codes fix their meaning; `scaffold/tests/run-native.sh` is the per-phase shell
  harness. ⚑ The catalog row's stale *"nine phases, 135 assertions + 81 roots"*
  was flagged here and **is now fixed** (`acba825`, measured at `6acbf9a`); the
  pre-run was right not to touch it, a pre-run writing only under `examples/`.

## 2. Research

- **Reference class:** `OURS` — `docs/testing-floors.md` (the contract: the
  ranked expectation-provenance axis and the run-the-mutant rule),
  `scaffold/tests/` (79 files, the migration source), `lib/test-runner.chiral` +
  `scaffold/tests/run-native.sh` (the receiving floor), and
  `docs/pattern-boundary-sums.md` (the standing directive this design applies).
- **Finding 1 — the provenance axis has FOUR ranks, and rank 4 unlabelled is
  itself a finding.** `docs/testing-floors.md:164-179`: sources of an expected
  value are *not equal*, and "a gate row must be able to name its rank." Rank 1
  is an external implementation with **independent semantics** — "the only rank
  that survives a rewrite of the thing under test"; rank 2 is an independent
  in-house reference or a **fixed committed artifact**; rank 3 is
  meaning-of-the-form; rank 4 is implementation-derived-and-labelled. Advice in
  a doc is exactly what this repo has *had* while shipping gates that could not
  fail — hence "enforced structure rather than advice".
- **Finding 2 — ~~three shipped gates could not fail~~ three recorded shapes in
  which a gate could not fail, none of them shipped, and the failures were
  *adequacy*, not expectation.** **E156 G4** passed 14/14 with `list-sort`
  deleted from `row-of` (the input reversed into something accidentally sorted
  and `row-join` ate the duplicate before it reached the function under test).
  **E161 G0** reported `ok` with **both** providers emitting the same wrong
  marker — *a common-mode expectation is not an expectation* — and only the
  fixed committed blob (`testing-floors.md:199`, a rank-2 source outside both
  legs) caught it. **E166 G3**'s `m_mul` mutant **objdumped identically**. All
  three had *sound expectations*. That is why the mutant rule is a **separate
  axis** from the provenance rank and neither subsumes the other.
  *(Corrected after the fact, 2026-08-25 — the count and the verb were both
  wrong, and the lines this finding cites are what prove it.
  `testing-floors.md:183-187` records **two** near-misses, "the reason this is a
  rule and not advice": E156 G4's gate "named the right mutant and would have
  shipped green without it" (`:193-194`) — running the mutant CAUGHT it — and
  E161 G0, which "only the fixed committed blob … caught" (`:198-199`). E166 G3
  is not in that range at all: `:203` heads it "**E166, as the rule FOLLOWED
  rather than nearly missed**", and `.planning/specs/E166-mach-c-SPEC.md:579`
  records that the identically-objdumping `m_mul` was measured at design time
  and replaced before shipping — "naming it here would have been a mutant that
  could never fail". So: three shapes, two of them near-misses, zero of them
  shipped. Left visible rather than silently rewritten; the corrected framing
  is what `scaffold/lib/test-floor.chiral` and Phase 12 now carry.)*
- **Finding 3 — a gate must be behavioural, not textual.** E166 shipped 68 text
  assertions that pinned an **inverted comparison for two sessions**: the
  rendering matched while the thing rendered was wrong. A rendering is a
  *diagnostic*, never the deciding value.
- **Finding 4 — the second opinion is now plural and alive.** The C leg
  (`mach-c` → CompCert 3.17 / gcc) convicts **byte-identically**, and the Rocq
  leg's blocker is its SOURCES, not its toolchain — ⚑ *narrowed at the example
  audit against `banks/verification` §5 item 3: the rename is `From Stdlib
  Require Import` → `Require Import` **one line per file**, and past it "the
  formalization itself is still two files about one integer type". So the Rocq
  leg is not a rename away from being an oracle, and only the C leg is available
  as a rank-1 source today.* So "re-found the differentials" is a real option and
  not a wish — *provided* the floor treats the opinion source as a parameter. Declared,
  swapping Python→CompCert is a **data change**; implicit, it is **335
  rewrites**, which is precisely the bill now on the table.

## 3. Conventional (other-language) approach

The corpus as it exists — Python, assertions living inside control flow:

```python
def test_mul_encoding():
    # x86: imul r64, r64  (checked against the manual, once, in 2025)
    assert emit(Mul(RAX, RCX)) == b"\x48\x0f\xaf\xc1"

def test_checker_agrees(src):
    # differential: the chirality checker vs ours
    assert native_check(src) == py_check(src)      # meaning == the import above

def test_sort_gate():
    # mutant: deleting list-sort should break this   <-- it did not
    assert row_of(["b", "a"]) == ["a", "b"]
```

- **Assumptions it bakes in:**
  - **Provenance is a comment, or absent.** Nothing distinguishes "checked
    against Intel's manual" (rank 1) from "whatever the code printed the day I
    wrote it" (rank 4), so nothing can *report* the distinction and nothing can
    refuse an unlabelled rank 4.
  - **The second opinion is an `import`.** `py_check` is a module reference, so
    the differential's meaning is a link into the very implementation being
    deleted. Deleting it turns 335 assertions into either a syntax error or,
    worse, a silent re-point at the thing under test.
  - **Assertions are statements, not values** — they cannot be counted, folded,
    filtered by rank, or handed to a second checker. A suite has no *value* that
    another program can judge; it has an exit code.
  - **The mutant is a comment.** "Deleting X should break this" is untested
    prose; E156 G4 proves the prose can simply be false.
  - **Text equality masquerades as behaviour** — the cheapest assertion to write
    is `assert str(x) == "..."`, which is how an inverted comparison survives.

## 4. The chirality idea

- **Chirality features in play:** boundary sums (the standing directive), QTT
  linearity on capability ports, the `->` vs `=>` membrane, totality,
  categories A/B/C.
- **The reframing, in four moves:**
  1. **"Where did this expected value come from" is a which-of-N
     classification** — textbook `docs/pattern-boundary-sums.md`. So it becomes
     a **closed `Prov` sum carried in the `Expect` value**, parsed once at the
     authoring boundary. `prov-rank` is then a *total pure function* with no
     default arm: adding a fifth source forces every rank policy to be
     revisited, instead of silently ranking as "unknown".
  2. **The second opinion is a port you hold, not a module you import.** An
     `Oracle` is a capability; a differential takes **two linear oracle ports**.
     Linearity buys one refusal outright: **you cannot consult one port twice and
     bank the result as two opinions** — E159 (BUILT 2026-08-22, `7b2b87e`)
     refuses *"function parameter of a linear type at quantity omega"*, so the
     ω-quantified `Oracle` that would allow it does not load. Two ports carrying
     the same `OracleId` is likewise a **refusal** (`df-common-mode`), not a pass.
     Swapping the dying Python leg for the C or Rocq leg is then constructing a
     different value at the call site — the data change the catalog row demands.
     ⚑ **Corrected at the example audit, 2026-08-25 — this move used to read
     *"Linearity is what buys the E161 G0 refusal for free"*, and that is a false
     attribution to the mechanism.** E161 G0 was **provider-vs-provider**: two
     *genuinely distinct* providers (the shell resolver and the native one),
     mutated to emit the same wrong marker. Their `OracleId`s differ, so
     `df-common-mode` never fires and linearity never fires; `differ` returns a
     contented `df-agree`. What caught it was a **rank-2 `pv-fixed` source
     outside both legs** (`testing-floors.md:197-201`) — Rule 1 met in the wild,
     the mutation sitting ABOVE the branch point where both legs are wrong the
     same way. §2 Finding 2 said this correctly all along; this move contradicted
     it. Keeping the two mechanisms apart is the point of the element: **linearity
     and `df-common-mode` police the SOURCE COUNT; only provenance rank polices
     the source's INDEPENDENCE.**
  3. **The mutant is evidence, not a promise.** `MutRun` is only constructible
     from a *pair of observations that differ*, produced by actually building
     and running the mutated program. `mu-survived` is a first-class constructor
     and the runner scores it **RED**: E166 G3's identically-objdumping `m_mul`
     is `mu-survived`. ⚑ *Corrected 2026-08-25: this read "would have been a
     failing gate on the day it shipped rather than a finding two sessions
     later", which credits E166 with a defect it did not have — that mutant was
     measured identical at design time and replaced before the row shipped
     (`.planning/specs/E166-mach-c-SPEC.md:579`). What the floor changes is that
     the same shape is caught by a type instead of by an author noticing.*
  4. **Judgment is pure; only observation crosses.** The `=>` set is exactly
     `observe`, `mut-run`, `oracle-ask` and `oracle-drop` — they fork, build,
     exec, or spend a port — plus `differ`, which is `=>` because the effect row
     is inferred over the call graph and it calls the first two. ⚑ *Enumeration
     corrected at the example audit: it named only `observe` and `mut-run`, while
     §5 declares four more.* Everything that JUDGES is `->`: `check`, `prov-rank`,
     `diff-of`, `obs-cmp`, `gate-verdict`, `suite-fold` — and so is `oracle-id`,
     which peels a held port without exercising it (possession is not exercise). The verdict of an entire suite is therefore a pure
     fold over values — which is exactly what lets the Rocq leg or a second
     chirality build re-judge the *same* observations, and what makes the test floor
     testable by itself without recursion into a process.
- **Library or harness — the decision.** **Library.** Assertions are values in
  chirality; the runner folds them. The eleven-phase shell harness does not vanish,
  it *shrinks to its honest job*: it is the **process layer** — build a binary,
  build a mutant, invoke gcc/CompCert, invoke rocq — and it stops being where
  assertions live. A phase becomes one root that returns a `Suite` value, not a
  bag of `[ x = y ]` shell tests.
  ⚑ Corollary the spec must not smuggle in: the ~35% of suite wall-clock spent
  in `bin/chirality-resolve.sh` forking helpers is a **harness** cost. The floor
  does **not** own import resolution — owning it would make the test library a
  build system. Left open in §6, deliberately, rather than deferred to a
  follow-on element that does not exist.
- **What chirality makes impossible here:**
  - An expectation **without** a provenance — `ex` has no arity that omits it,
    and no `Prov` constructor means "unknown". The unlabelled rank 4 that
    `testing-floors.md` calls a finding is simply not constructible.
  - A gate **without** a mutant that ran — `gate` requires a `MutRun`, and a
    `MutRun` requires two observations.
  - A "differential" against a single source, or against two ports with the same
    identity.
  - A pass produced without an observation: `check` cannot manufacture an `Obs`;
    it can only compare one that a crossing produced.

## 5. Chirality example (fleshed)

```chirality
(import "prelude")
(import "collections")

; ===========================================================================
; 1. PROVENANCE — where the expected value came from, as a closed sum.
;    docs/testing-floors.md ranks four sources and calls an unlabelled rank 4
;    a finding.  Making it a sum makes "unlabelled" unconstructible.
; ===========================================================================
(data Prov ()
  (pv-external (tool Str) (ver Str))       ; rank 1 — an independent implementation
                                           ;   with independent semantics: CompCert
                                           ;   3.17 / gcc via mach-c, rocq, a
                                           ;   published ABI.  The only rank that
                                           ;   survives rewriting the thing under test.
  (pv-fixed    (path Str) (digest Bytes))  ; rank 2 — a fixed committed artifact, or an
                                           ;   in-house reference outside BOTH legs.
                                           ;   This is what caught E161 G0.
  (pv-meaning  (law Str))                  ; rank 3 — follows from the meaning of the
                                           ;   form: round-trip, idempotence, a law.
  (pv-derived  (why Str)))                 ; rank 4 — implementation-derived AND
                                           ;   labelled.  `why` has no empty case.

(declare prov-rank (-> Prov I64))
(def prov-rank (lam (p)
  (case p
    ((pv-external t v) 1)
    ((pv-fixed pa d)   2)
    ((pv-meaning l)    3)
    ((pv-derived w)    4))))                ; total, no default arm: a fifth source
                                            ; forces every rank policy to be revisited

; ===========================================================================
; 2. OBSERVATION — behaviour, never a rendering.
;    E166 shipped 68 text assertions that pinned an INVERTED comparison for two
;    sessions: the printout matched while the bytes were wrong.  A rendering may
;    ride along as diagnostics (`Report.render`), never as the deciding value.
; ===========================================================================
(data Obs ()
  (ob-exit  (code I64))                     ; the process said this
  (ob-bytes (b Bytes))                      ; the emitter produced these bytes
  (ob-int   (v I64)))                       ; the evaluator returned this

(data Verdict () (vd-pass) (vd-fail (got Obs) (want Obs)))

(declare obs-cmp (-> Obs Obs Verdict))      ; ; … structural, arm per constructor;
                                            ; mismatched constructors are vd-fail

; ===========================================================================
; 3. AN EXPECTATION IS A VALUE, AND JUDGMENT IS PURE.
;    Only observing and asking cross; the verdict of a whole suite is a fold, so a second
;    implementation (the rocq leg, another chirality build) can re-judge the SAME
;    observations without re-running anything.
; ===========================================================================
(data Expect () (ex (what Str) (want Obs) (src Prov)))

(declare check (-> Expect Obs Verdict))
(def check (lam (e got)
  (case e ((ex what want src) (obs-cmp want got)))))

; ===========================================================================
; 4. THE SECOND OPINION IS A PORT, NOT AN IMPORT.
;    The 335 differentials die with `py_check` precisely because their meaning
;    was a module reference.  Here it is a linear capability: swapping the dying
;    Python leg for the C leg is constructing a different value at the call
;    site — a data change, not 335 rewrites.
; ===========================================================================
(porttype Oracle)                            ; minted like backend.chiral:31's
                                             ; `(porttype Backend)` — the only two
                                             ; porttypes in the tree today are
                                             ; Backend and Secret, and Backend is
                                             ; Str-carried (E144), which is the
                                             ; carrier an Oracle wants.

(data OracleId ()
  (or-python)                                ; the leg being deleted
  (or-ccomp (ver Str)) (or-gcc (ver Str))    ; E166's mach-c leg, convicting byte-identically
  (or-rocq)                                  ; the rocq/ floor
  (or-fixed (path Str)))                     ; a committed artifact standing in as an opinion

; Reading a port's identity must THREAD the port back, exactly `be-peek`
; (backend.chiral:55-56, E145): a peel that took `(o Oracle)` unrestricted would
; be refused by E159's BUILT check -- `load: function parameter of a linear type
; at quantity omega -- a linear parameter must be declared (1 x T)` -- and one
; that took `(1 o Oracle)` without returning it could not then be asked.
(data OracleIdR () (oid-r (id OracleId) (1 o Oracle)))

(data DiffR ()
  (df-agree   (obs Obs))
  (df-differ  (a Obs) (b Obs))
  (df-common-mode (id OracleId)))            ; one source cannot be two opinions.
                                             ; ⚑ NOT what catches E161 G0 — see §4
                                             ; move 2; that was two DISTINCT
                                             ; providers wrong the same way, which
                                             ; only a rank-2 source outside both
                                             ; legs can see.

(declare oracle-id  (-> (1 o Oracle) OracleIdR))   ; PURE: possession is not exercise
(declare oracle-ask (=> (1 o Oracle) Bytes Obs))   ; consuming the port IS the crossing:
                                                   ; one opinion, asked once
(declare oracle-drop (=> (1 o Oracle) Unit))       ; E107-shaped consuming close, for the
                                                   ; port that is refused before it is asked
(declare id-eq  (-> OracleId OracleId Bool))       ; ; … arm per constructor
(declare diff-of (-> Obs Obs DiffR))               ; PURE: obs-cmp, then vd-pass =>
                                                   ; (df-agree a), vd-fail => (df-differ a b).
                                                   ; Comparing is never the crossing.

(declare differ (=> (1 a Oracle) (1 b Oracle) Bytes DiffR))
(def differ (lam (a b input)
  (case (oracle-id a) ((oid-r ida a2)
    (case (oracle-id b) ((oid-r idb b2)
      (if (id-eq ida idb)
          ; refuse WITHOUT asking, and spend both ports, so no observation is
          ; manufactured and nothing leaks
          (do (oracle-drop a2) (do (oracle-drop b2) (df-common-mode ida)))
          ; otherwise ask both -- each ask spends its own port exactly once, so
          ; neither port can be re-asked and neither can leak
          (diff-of (oracle-ask a2 input) (oracle-ask b2 input)))))))))

; ===========================================================================
; 5. THE MUTANT RULE — evidence, not a promise.  Three recorded shapes in which
;    a gate could not fail, NONE of which shipped: E156 G4 (14/14 with
;    `list-sort` deleted), E161 G0 (both providers wrong) — the two near-misses
;    — and E166 G3 (`m_mul` mutant objdumped identically, retired at design
;    time).  A MutRun exists only if a mutated program was BUILT and RUN, so
;    "I named a mutant" cannot be typed as "I ran one".  ⚑ Comment corrected
;    2026-08-25 (it read "Three gates shipped that could not fail"); the built
;    file carries the corrected wording.
; ===========================================================================
(data MutRun ()
  (mu-killed   (label Str) (base Obs) (mutated Obs))   ; the two observations differed
  (mu-survived (label Str) (obs Obs)))                 ; they did not — E166 G3 lives here

(porttype Builder)                          ; ⚑ NOT found in the tree under this or any
                                            ; name (§6): today's build-and-run authority is
                                            ; the AMBIENT `=>` externs `openat` / `run-elf`
                                            ; (test-runner.chiral:14-15), not a port.

; A Builder is spent by a build, so every crossing that uses one THREADS IT BACK
; -- the RecvR / BePeekR shape. Without this a suite could run exactly one gate:
; E159's built rule refuses the ω-quantified `(bld Builder)` that would allow
; two, and a `(1 bld Builder)` that is not returned is gone after the first use.
(data ObsR ()  (obs-r (obs Obs)    (1 b Builder)))
(data MutR ()  (mut-r (run MutRun) (1 b Builder)))

(declare observe (=> (1 bld Builder) Str ObsR))          ; builds the named root, runs it,
                                                         ; yields the Obs a check compares
                                                         ; against -- `check` can never
                                                         ; manufacture one
(declare mut-run (=> (1 bld Builder) Str Bytes MutR))    ; edits, builds, runs -- BOTH
                                                         ; observations, or no MutRun

; A gate cannot be constructed without its adequacy evidence.
(data Gate () (gate (name Str) (checks (List Expect)) (adequacy MutRun)))

(data GateR ()
  (g-green (name Str) (n I64) (worst I64))   ; worst = the weakest prov-rank present
  (g-red   (name Str) (why Verdict))
  (g-inadequate (name Str) (label Str)))     ; adequacy failed though every check passed

(declare gate-verdict (-> Gate (List Obs) GateR))
(def gate-verdict (lam (g got)
  (case g ((gate name checks adequacy)
    (case adequacy
      ((mu-survived label o) (g-inadequate name label))   ; scored RED before any check
      ((mu-killed label bs mu)
        ; ; … zip checks against got, fold with `check`; first vd-fail => g-red;
        ; ; … otherwise g-green carrying the count and the WEAKEST rank in the gate
        (fold-checks name checks got)))))))

(declare fold-checks (-> Str (List Expect) (List Obs) GateR))   ; the fold above, spelled out

; ===========================================================================
; 6. THE SUITE IS A FOLD.  A phase becomes ONE root returning a Suite value;
;    run-native.sh keeps only its process-level job (build a binary, build a
;    mutant, invoke gcc/CompCert/rocq) and stops being where assertions live.
; ===========================================================================
(data Suite () (suite (phase Str) (gates (List Gate))))

(declare suite-fold (-> Suite (List (List Obs)) (List GateR)))
(declare report     (-> (List GateR) Str))    ; rendering, deliberately downstream of
                                              ; the verdict so it can never decide it

(declare test-main (=> (1 c Console) (List Suite) I64))
; ⚑ Two build-state facts the audit attached, 2026-08-25. (1) `Console` does NOT
;   exist: `(porttype Backend)` and `(porttype Secret)` are the ONLY porttypes in
;   the tree, and reifying Console/Clock/Env behind `main` is **E80, `design` =
;   unbuilt**. Written this way the floor takes a dependency on E80; written with
;   today's ambient `print` it does not. That is a spec decision, not a typo.
; (2) `test-runner.chiral` has no `test-main` to adopt -- its roots are `run-one`
;   / `run-all` / `manifest` / `compile-main` (68 L). "Adopted by" means that file
;   is rewritten around this entry.
```

- **Knobs to modify:**
  - **`OracleId` arms** — this is the migration's steering wheel. Each of the 41
    differential files picks arms; `(or-python)` is expected to reach zero
    occurrences and can then be *deleted from the sum*, at which point the
    compiler enumerates every site that still depended on it. That enumeration
    is the point.
  - **`Obs` arms** — add the observation kinds a phase actually needs
    (`ob-signal`, `ob-fd`); resist adding `ob-text`, and if a phase truly needs
    one, it forces `pv-fixed` or `pv-derived` at the call site, which is the
    intended friction.
  - **The rank floor per phase** — `g-green` carries the *weakest* rank in the
    gate, so a phase can require e.g. "no gate weaker than rank 2" as a pure
    predicate over the report. That is policy, not floor; keep it out of the
    library.
  - `Bool` vs `I64` truth in `obs-cmp`'s internals — whichever `prelude`
    already exports. A knob, not a decision.
- **Deliberately omitted:**
  - Any actual migration of the 709 functions, and the per-file re-founding
    table for the 335 differentials.
  - Import resolution / the `bin/chirality-resolve.sh` fork cost — a harness fact
    (§4), not the floor's job.
  - Test *discovery* (getdents auto-discovery) — orthogonal, already tracked in
    the native-harness work.
  - Parallelism, timing, and any per-test reporting format beyond `report`.

## 6. Use / modify notes

- **Lands in:** a new `lib/test-floor.chiral` (the sums + the pure fold — the
  whole of §5 above), **adopted by** `lib/test-runner.chiral` (its existing
  `test-main` becomes the `=>` shell around `suite-fold`), with
  `scaffold/tests/run-native.sh` shrinking to process-level phases. ⚑ *Adopted*
  is load-bearing: this repo's measured failure mode is "built but unadopted"
  (four occurrences, E42 among them). A floor nobody's phase returns a `Suite`
  into is not a floor.
- **Conformance target (the golden behaviour):**
  1. The live suite stays **eleven phases / 163 assertions / 82 roots / exit 0**
     after re-expression, with **every** assertion carrying a `Prov` — no arm
     added to `Prov` to absorb the awkward ones.
  2. **The three known could-not-fail shapes go RED.** Re-expressed on this floor
     with their historical mutants, **E156 G4** (`list-sort` deleted) and **E166
     G3** (`m_mul`, which objdumped identically) must produce **`g-inadequate`**
     — in both cases the mutant survives, so `MutRun` is `mu-survived` and the
     gate is scored RED before a single check runs. **E161 G0 is NOT one of
     these, and the audit could not resolve what it becomes — see FLAG.** This is
     the only conformance target that proves the floor does something; a green
     re-expression alone proves nothing, since green is what all three already
     were.
     ⚑ **Corrected at the example audit, 2026-08-25.** This target read *"must
     produce `g-inadequate` / `df-common-mode` respectively"* — three gates
     against two outcomes, and the pairing was wrong where it was legible: E161
     G0's two providers are **distinct**, so `df-common-mode` (which fires only on
     two ports carrying the SAME `OracleId`) cannot fire, and a floor built to
     this target would ship its own could-not-fail gate — the exact defect the
     element exists to end. Left OPEN rather than resolved here, because what E161
     G0 becomes is a design call, not an arithmetic one.
  3. The C leg still convicts byte-identically when its `Oracle` is passed as
     `(or-gcc …)` / `(or-ccomp …)` rather than wired in.
- **Open questions (for the spec run to disposition, not deferrals):**
  - New `lib/test-floor.chiral` beside `test-runner`, or grown inside it? Two
    files risks the unadopted-floor failure; one file mixes a pure library with
    a `=>` entry point.
  - Who owns import resolution once phases stop forking helpers — the harness,
    the native resolver, or neither (the ~35% wall-clock question). Named here
    as **open**; no follow-on element is invented for it.
  - Do the 25 exit-code-fixed `scaffold/tests/samples/` become `pv-fixed`
    expectations (their exit codes are committed artifacts) or `pv-meaning`
    (the sample's meaning IS its exit code)? This decides ~25 rank labels.
  - Does `Builder` (the mutant builder capability) already exist under another
    name in the native harness, or is it new surface? ⚑ *Half-settled at the
    example audit, 2026-08-25: **no `Builder` exists in the tree under any name**
    (`grep -rn Builder scaffold/lib TUI` → 0 hits), and only `Backend` and
    `Secret` are porttypes at all. The build-and-run authority that DOES exist is
    ambient: the `=>` externs `openat` and `run-elf` (`test-runner.chiral:14-15`).
    So the real question is not "does it exist" but **whether the floor reifies
    that ambient authority into a port** — which is E80's question one element
    early, and which decides whether E168 depends on E80 or ships beside it.*
  - **What does E161 G0 re-express as on this floor?** The audit established what
    it is NOT (`df-common-mode` cannot fire on two distinct providers) and could
    not resolve what it IS. Candidates the spec must choose between: a rank floor
    (the gate is only green if some `Expect` in it carries `pv-fixed` or better,
    so a purely provider-vs-provider gate is `g-inadequate` by rank); a mutant
    obligation that must be applied ABOVE the branch point; or an honest
    concession that Rule 1 is not mechanizable at all and E161 G0 stays a
    discipline. This decides whether conformance target 2 has two members or three.
  - **How does a `DiffR` reach a `GateR`?** `differ` is the element's centrepiece
    and its result is currently orphaned: `Gate` holds `(List Expect)`,
    `gate-verdict` consumes `(List Obs)`, and nothing folds a `DiffR`. The natural
    reading is that `df-agree`'s `Obs` becomes the `want` of a `pv-external`
    expectation — but that is a seam the spec must state, not infer.
  - Is `mu-survived` ever legitimately green — e.g. a mutant that is
    semantically equivalent by construction? `testing-floors.md` says adequacy
    is **not** mechanizable; the floor's answer here decides whether there is an
    escape hatch and, if so, whether it is itself labelled.
- **Related:** [[testing-floors]] · [[pattern-boundary-sums]] · [[E166-mach-c]]
  · [[SELF-IMPLEMENT-CATALOG]]
