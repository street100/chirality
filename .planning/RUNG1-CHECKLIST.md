# RUNG 1 — THE checklist (single source of truth)

> **⚑ 2026-08-10 — PYTHON RETIREMENT IS NOW A BACKGROUND MIGRATION, NOT A
> BLOCKER.** The floor architecture landed: `chirality test` gates on **native**
> (behavioral) + **rocq** (external spec), and runs the **python oracle as an
> ADVISORY floor** (reported, never fails the gate). Contract + discipline:
> `docs/testing-floors.md`. This un-removes old Phase C but in a non-monolithic shape —
> coverage migrates *feature-by-feature* (sample-with-feature), so "zero python"
> arrives as a byproduct of normal chirality/scriba work rather than a stop-the-world
> rewrite. Removing python is confirmed **not mechanical** (python compiles
> nothing; the fixpoint re-checks most behavior transitively) — it's the rung-1
> milestone gate. The **rocq/** external-spec leg is seeded (I64 pure fragment,
> faithful to `impl_pure.py`) and grinds under an autonomous CoqHammer+model loop
> (`rocq/hammer/loop.sh`); it exists because the fixpoint proves *stability*, not
> *correctness* — something external must still catch a consistent miscompile
> once the oracle goes. See revised **Phase B** and **Phase C** below.
>
> **⚑ 2026-08-05 — READ `.planning/HANDOFF-RUNG1-FIXPOINT.md` TOP FIRST.**
> **B1 — the self-compiled native compiler — WORKS** (stdin source → runnable
> ELF, exit 42, correct errors; zero python in that compile). 668 green.
> Phase A is done through A3; **A4 = ONE host command:**
> `cd scaffold && python3 tools/selfhost.py stage2` (the 4 GB VM OOMs on the
> self-compile heap). Artifacts + symbol table live in `scaffold/build/`
> (bind-mounted). On mismatch/crash: `selfhost.py diff` / `crash`.


**Definition of done (RE-SCOPED BY USER 2026-08-04):** full selfhost = the A4
fixpoint (Stage1 == Stage2, byte-identical, zero CPython in either compile).
Then: the Python seed is **packed up, not deleted** in this (priv) repo — kept
as fallback + test oracle — and **stripped from the public mirror except
tests**. The test-harness rewrite (old Phase C) is **OFF the list** (user call,
2026-08-04: "Take the test rewrite off the list").

This file is the ONLY worklist. Items are checked off here as they land; no new
ad-hoc lists. Each item has a concrete **DONE-WHEN** (a runnable check).

Legend: `[x]` done · `[~]` in progress · `[ ]` not started.

> **PROGRESS (2026-08-04):** The two HARD blockers are cleared —
> **(1) the whole compiler lowers to native** (front/back/emit, 0 unlowered) and
> **(2) the front SELF-PARSES the whole 447k-char compiler source** (`compile-front
> … "compile-all"` → `fr-ok`). A1 is DONE. Remaining is mechanical-but-substantial:
> **A2** the native I/O driver (read port + `compile-main`), **A4** the fixpoint
> byte-compare, then **B** (delete 8028 LOC of Python, contingent on A4) and **C**
> (rewrite 13205 LOC of tests off Python — the largest slice). NEXT: **A2a**.

---

## Phase A — the self-compile fixpoint (evicts the CPython compile logic)

Already in place (inspected 2026-08-04, do not redo):
- [x] The whole compiler lowers to native (compile-front / back-program / emit-elf: 0 unlowered).
- [x] One-Sig `compile-all : Str → ELF` exists, byte-identical to the 3-RT shuttle, and lowers.
- [x] Byte-compare harness `ddc.chiral` (`fixpoint=?`, `bytes=?`, `ddc-fold`).
- [x] Sys hand-tal for read/write/lseek/memfd (`lib/sys-tal.chiral`); write/exit + execveal run path.

### A1 — front self-parse (the gate: the front must parse+typecheck the whole compiler source)
- [x] **A1a — NOT NEEDED as a separate seed (verified 2026-08-04).** The front already
      handles in-source `(extern …)`; `compile-all` compiles `(extern + …)(def main …
      (+ 20 22))` → ELF exit 42. The compiler's OWN source declares its externs via
      `(import "prelude")`, so A1b (import handling) brings them in — there is no
      separate prelude-seed on the fixpoint path.
- [x] **A1b — DONE (flattened blob).** `(import)` is a NO-OP over the dependency-ordered dedup'd blob (tools/selfhost.py builds it).
      ~~handle `(import "name")` in `load-source`.~~ Currently unhandled
      (a `step-err`). Either read the imported file via the sys face, OR flatten the
      module set into one source before `load-source` (decide during A1b).
      DONE-WHEN: `compile-all` compiles a 2-module program that uses `(import …)`.
- [x] **A1c — MOOT (verified 2026-08-04).** The compiler source uses ONLY
      def/declare/data/extern/porttype/**import** as top-forms (measured across all
      `lib/*.chiral`); no `target`, `profile`, or `(measure …)` declares exist. The
      front already handles all of those except `import` — so A1b is the ENTIRE front gap.
- [x] **A1d — DONE 2026-08-04.** `compile-front <whole-compiler-source> "compile-all"`
      returns **`fr-ok`** — the whole 447k-char / 34-module compiler source PARSES +
      TYPE-CHECKS through the chirality front. Cleared via A1d.1 (data-group loader) +
      A1d.2 (indexed porttypes). 652 green.
      - [ ] **A1d.1 — data-group loading (mutually-recursive data).** `load-forms` is
            LINEAR and `load-data` (loader.chiral) adds ONE decl then checks its ctors —
            fine for self-recursion, but the source has mutually-recursive data types
            (`Surf` ↔ `SBind` in surface.chiral; likely others) → "unknown name SBind".
            FIX (precise): mirror the Python `check_data_group` (data.py:492) — in
            `load-source`, pull ALL `(data …)` forms, register every data NAME in the
            SEnv + Sig, elaborate every decl, add all decls, THEN check all ctors; then
            process the remaining def/declare/extern/import forms linearly. (Maximal
            grouping is sound: data names are distinct in the flat namespace, and a data
            decl only references other data types + its params.) This is a real loader
            change on the path the 652 tests exercise — do it carefully, full suite each step.
            DONE-WHEN: `compile-front <whole-source>` gets past all data-mutual-recursion.
      - [x] **A1d.1 — DONE** (commit: data-group loader + porttype-before-data ordering;
            mutual-recursive data compiles to a running ELF; 652 green).
      - [x] **A1d.2 — DONE** (indexed porttypes load; whole blob parses). The source has `(porttype Pool (n I64))`
            (parameterized linear atoms: `Pool n`) which `handle-porttype` defers. The
            front must at least PARSE + declare them (they're imported via `ports.chiral`
            → `mach-x64`, so must load even though codegen doesn't use them).
            DONE-WHEN: `compile-front <whole-source>` gets past the indexed-porttype error.
      - [x] **A1d.3+ — DONE** (front self-parse complete; Stage 1 runs end to end).

> **A4 BLOCKER FOUND (2026-08-04):** The chirality-authored back/emit pipeline
> (`compile-back`/`emit`) does NOT lower **effectful (`=>`) defs** — the E70 gate +
> crossing handling that Python's `lower_all` has was never ported to the chirality
> back. Proof: a pure `main` calling ANY effectful helper → `emit-elf` "no emitted
> label for entry main". Stage 1 (interpreted compile-all on the whole 447k-char
> source, entry `compile-main`) runs the FULL pipeline in 235s and reaches emit,
> failing only here. Since the compiler still has effectful defs (`resolve-label`/
> `check-len` reach `halt`; the I/O entry), **A4 is blocked on porting E70
> effectful-def lowering into the chirality back** — a real subsystem port, the next
> concrete work. (A2a/A2b chirality-side + Python read impl are done + lower.)

### A2 — the native I/O driver (a binary that reads source + writes ELF)
- [x] **A2a — DONE** (`read` bound crossing; native binaries read stdin — verified at 486k).
      ~~a `read` port, bound like `put`.~~ Inspected: `nb-sys-read` hand-tal
      exists but reads ONE byte (`read(0, buf, 1)`, hardcoded fd/count) and is NOT
      bound as a crossing. Need either a `read-N`/`read-all` tal primitive (one syscall
      into an N-byte buffer) or a read-1-byte loop, + the `(extern read …)` port +
      `bind-sys "read" …` + wrapper. DONE-WHEN: a chirality program reads fd 0 and echoes it, native.
- [x] **A2b — DONE 2026-08-05.** B1 (self-compiled) reads source on fd 0, writes a
      runnable ELF on fd 1 (42-program verified; correct errors on stderr).
      ~~`compile-main` entry.~~ read source (fd 0 / a memfd) → `compile-all` →
      write ELF (fd 1 / a memfd). DONE-WHEN: a NATIVE binary of `compile-main` reads a
      source file and writes an ELF that itself runs (exit 42 on the 42 program).

### A3 — strings-as-constants at compiler-source scale
- [x] **A3 — DONE 2026-08-05** (verified the hard way: two label-namespace
      collisions found + fixed; B1's full literal table works natively).
      DONE-WHEN: `compile-all <whole-compiler-source>` produces an ELF (no literal-table
      overflow / interning gap) — falls out of A1d + A2b but verify explicitly.

### A4 — the fixpoint
- [x] **A4 — ✅ ACHIEVED 2026-08-05.** `python3 tools/selfhost.py stage2` →
      `FIXPOINT: B1 == B2 (byte-identical, 659681 bytes)`, 1 s, peak 0.1 GB,
      deterministic 3×. The 4 GB-VM OOM was a single emit quadratic (`materialize`
      right-nested `bcat`, O(N·M) ~12 GB), fixed to balanced concat O(N log M)
      (commit 4e7791b) → peak 0.1 GB, fits the VM trivially. B2 is a working
      compiler (compiles+runs 42). **Zero CPython logic in the stage-2 compile —
      the rung-1 keystone: B1 self-reproduces natively, the interpreter is evicted
      from the compile path.** (E81 `Alloc` seam also landed, d6ad519; E82 regions
      NOT needed.)

---

## Phase B — demote the bootstrap seed (REVISED 2026-08-10; was "pack the seed")
The floor architecture supersedes the tarball framing: the seed/oracle is now
**demoted, not archived** — `chirality test` runs `scaffold/chirality/*.py` as an
ADVISORY floor (`docs/testing-floors.md`), so it no longer gates while it drifts, and
it drops away as native+rocq cover its ground. No stop-the-world step.
- [x] **B1' — python demoted to advisory (priv).** `chirality test` gates on
      native+rocq; python runs, reports its delta, never fails the gate
      (`bin/chirality` `cmd_test`, flags `--strict`/`--no-python`/`--only`). Landed
      2026-08-10.
- [ ] **B2' — strip the seed from the public mirror, keep tests.** The pub export
      excludes `scaffold/chirality/*.py` (the seed) but keeps `tests/`. Unchanged
      goal; now framed as "drop-as-covered," not a single strip.
      DONE-WHEN: pub mirror re-export contains no seed .py, native+rocq green.

---

## Phase C — retire the Python oracle by FLOOR MIGRATION (UN-REMOVED 2026-08-10)
Old Phase C ("rewrite 13k LOC of tests off Python") was removed 2026-08-04 as a
monolith. It is back in a **non-monolithic** shape: not a rewrite, a migration.
Contract + per-change discipline: `docs/testing-floors.md`. Triage each existing test
into three buckets — **delete** (tests the py floor's internals / subsumed by
the fixpoint; ~93% of the suite is white-box floor tests whose subject is
leaving), **sample** (behavioral → native-behavioral sample), **prove**
(semantic property → a rocq obligation). Never port test *code* to Coq — mine
it for the *property*, re-state it about chirality.
- [x] **C0 — floor system + advisory classification.** `bin/chirality test` +
      `docs/testing-floors.md`. Landed 2026-08-10.
- [x] **C1 — rocq external-spec leg seeded.** `rocq/` (I64 pure fragment,
      faithful to `impl_pure.py:19-92`), 19 obligations, autonomous
      CoqHammer+model loop (`rocq/hammer/loop.sh`, coqc-gated), obligation→test
      map in `rocq/HAMMER-MANIFEST.md`. Arithmetic slice is the warm-up.
- [~] **C2 — grind the arithmetic slice.** Local hammer on the host is closing
      it (wrap64/addi/muli/bitwise families proved; Euclidean + `wrap64_wrap_add`
      congruence are the residue). DONE-WHEN: `rocq/` zero-admit, coqc-green.
- [ ] **C3 — triage pass over the 79 py test files.** Classify delete/sample/
      prove + extract each test's intended property (LLM-proposes / Claude-
      verifies; the classify tier of the retirement). Output: bucket sizes + the
      prove-list the rocq leg must carry. DONE-WHEN: manifest of all 79 files.
      *(Count corrected 2026-08-24: the row said 76, `ls scaffold/tests/*.py`
      says **79**. A DONE-WHEN of "all 76" ticks green with three files
      unclassified — the row's own gate could not see its own scope.)*
- [ ] **C4 — grow rocq slices: comparisons → refinement soundness → checker.**
      The checker/kernel soundness slice is the CompCert-shaped core and the
      grant unlock; large, the real proof work. Growth plan in HAMMER-MANIFEST.md.
- [ ] **C5 — sample the behavioral bucket** into `scaffold/tests/run-native.sh`
      + `scaffold/samples/` as features migrate (sample-with-feature).
- [ ] **C6a — delete covered/floor-internal py tests** (`scaffold/tests/*.py`,
      79 files / 14,784 LOC). DONE-WHEN: `scaffold/tests` holds no `.py`,
      native+rocq green.
- [ ] **C6b — delete the seed** (`scaffold/chirality/*.py`, 23 files / 8,451 LOC),
      last, because C6a's differential bucket dies with it. DONE-WHEN:
      `scaffold/chirality` is gone, native+rocq green.
- [ ] **C7 — the in-scope python OUTSIDE those two directories** (§C-inventory
      below, ~988 LOC). C3/C5/C6 name only `scaffold/tests` and
      `scaffold/chirality`, so nothing owned these; they are the reason "zero python
      in repo" was not reachable from C6's own deliverable.
      DONE-WHEN: every row in the inventory's IN-SCOPE table is gone or ported.

      *(C6 was one checkbox over 102 files and 23k LOC with DONE-WHEN "zero
      python in repo" — a scope its own deliverable did not cover. Phase C was
      un-removed on 2026-08-10 specifically to stop being a monolith; it had
      quietly become one again. Split 2026-08-24.)*

### C-inventory — the full slice list (measured 2026-08-24)

Total in-tree python: **133 files / 29,243 LOC** (`find . -name '*.py'`,
excluding `.git` and `.claude/worktrees`). The boundary is **not** "in the git
tree" — it is *what chirality is built from, verified by, or runs on*. The authoring
harness that drives an AI session is not chirality and never was in rung-1 scope; it
is scaffolding for this interface until **manas** replaces it.

**IN SCOPE — owned**

| surface | files | LOC | owner |
|---|---|---|---|
| `scaffold/tests/*.py` | 79 | 14,784 | C3 · C5 · **C6a** |
| `scaffold/chirality/*.py` | 23 | 8,451 | **C6b** |

**IN SCOPE — was unowned until this entry; now C7**

| file | LOC | why it is chirality |
|---|---|---|
| `scaffold/tools/selfhost.py` | 442 | the legacy test oracle. `CLAUDE.md` calls it *"LEGACY — a test oracle pending retirement (S12/rung-1)"*, but **no C-row named it** |
| `bin/syscall-map.py` | 238 | generates/checks the syscall table — the crossing surface |
| `bin/scriba-edit-smoke.py` | 126 | a PTY smoke that **tests scriba** — a chirality test living outside `scaffold/tests`, so C3/C5/C6 cannot see it |
| `scaffold/tools/balance.py` | 113 | form-balance checking over chirality source |
| `bin/scriba-run-smoke.py` | 40 | as above |
| `scaffold/bin/stage1-selfcompile.py` | 29 | bootstrap |
| **total** | **988** | |

**JUDGMENT CALL — in the tree, arguably not in scope**

| surface | LOC | the argument |
|---|---|---|
| `scaffold/mock/*.py` | 277 | simulates a niri/Wayland compositor for scriba tests. You do not rewrite the outside world in chirality; an external simulator is the honest shape. Decide on purpose, do not let it drift. |
| `scaffold/bench/*.py` | 398 | measures chirality; does not build or verify it. Low priority — but a published benchmark is a claim, and a claim measured by the floor being retired is the E161-G0 shape. |

**OUT OF SCOPE — the authoring harness (dies with manas, not with rung 1)**

`tools/pack/pack.py` · `tools/doc/doc.py` · `bin/chirality-frontier.py` ·
`bin/chirality-capture.py` · `tools/ledger-lint/ledger-lint.py` · `bin/paren-audit.py` ·
`examples/refs/*.py` (the OURS baselines the pack slices) · `.scratch/*.py` ·
`.planning/capture-fixtures/*.py` — **~4,400 LOC.**
These pipeline the interface between the author and an AI; they are not part of
the language, its build, or its verification. Recorded here so the boundary is
**stated and dated** rather than re-litigated every time someone counts `.py`
files and gets a scary number. *(It was re-litigated on 2026-08-24 by exactly
that mistake: a sweep counted all 133 files and reported ~5,700 LOC "unowned",
of which ~4,400 was this harness.)*

**NOT scope gaps — two claims that measured false, kept so they are not re-raised**

- **`refine.py:41`'s `_OPS` is NOT a stranded semantics fact.**
  `scaffold/lib/refine.chiral:11` already owns the op set as a closed sum,
  `(data SymOp () (s-ge) (s-gt) (s-le) (s-lt) (s-ne))`. The Python is cited as
  *authority* by `CLAUDE.md`, `README.md:156`, `docs/status-ledger.md:82`,
  `docs/memory-model.md:130` and `docs/totality.md:24` — that is **doc rot on
  the A5 claim-altitude axis**, a `doc-audit` item, not a migration blocker.
- **`interp.chiral` does not run on python.** It imports `prelude` only; its
  `:6` comment *"runtime.py stays the oracle"* records that it is differentially
  **checked against** `runtime.py`, not that it calls it. Losing that second
  opinion is the oracle-retirement cost already owned by **E169**
  (`banks/verification` Shard 9), not an unowned dependency.

**The check that keeps this honest.** This inventory rots the moment a `.py`
lands. `tools/ledger-lint/ledger-lint.py` already mechanizes the catalog axis (checks J/K/L/M);
the matching row here is: **every `.py` in the tree resolves to an IN-SCOPE
owner, a JUDGMENT row, or the dated OUT-OF-SCOPE list — or lint fails.** That is
the same move `BUILD-ORDER.md` §3 prescribes for its own taxonomy (*"both are
one-command checks — make them lint rows"*). Until it is a lint row this table
is policy, not physics.

### C-shape — what the python-checker-only slice ASSERTS (measured 2026-08-29)

§C-inventory counts the corpus by *surface*. This counts the same corpus by
**what an assertion claims**, because the two answer different questions and only
the second says whether the rewrite E170 plans is evidence or reassurance.

> A chirality-native test that says *"this term must normalize to that"* is a
> **regression test**: it locks in current behaviour, and a wrong understanding is
> encoded just as faithfully in chirality as it was in Python. Rewriting decorrelates
> the *implementation*, not the *intent* — and the oracle correlation lives in the
> intent. A test that says *"these two must agree"*, *"turning this rule off must
> not move a term that never mentions it"*, or *"this is refused under every
> profile lacking the rule"* states a **property**: it survives a rewrite, it is
> checkable without knowing the answer in advance, and it can be **generated from
> the rule set** instead of hand-written.

**The answer: it skews outcome-locking, hard. 267 / 312 = 85.6 % A.**

#### Method (every number has its command; the judgment calls are named)

1. **Enumeration.** Test functions are counted by Python `ast`, not by grep:
   every `def test*` that is a method of a `ClassDef`, over `scaffold/tests/*.py`.
   This returns **709**, agreeing exactly with the E170 SPEC's
   `grep -h "    def test" scaffold/tests/*.py | wc -l` — and inheriting the same
   blind spot (§D10: the 5 cases `test_stack_args_compile_run.py` generates at
   import time are invisible to both).
2. **Bucketing.** The 335 / 68 / 306 triple is a *derived* figure whose per-file
   membership was **never recorded anywhere in the tree** (`git log -S"306
   python-checker-only"` → `e099cf86`, which states the totals and no method).
   It was reconstructed here from a stated rule: a file is **differential** if its
   own module docstring or a named helper asserts agreement with a second producer
   (`differential vs …`, `oracle`, `must agree`, `cross-check`); **B1-driven** if
   an assertion depends on `subprocess`-ing `scaffold/build/B1`; **python-checker-
   only** otherwise. That yields **42 / 329 · 10 / 68 · 27 / 312** against the
   recorded **41 / 335 · 9 / 68 · 29 / 306** — see *Does 306 hold* below.
3. **Assignment, one label per function, first match wins.** R1 expected side
   produced by another implementation or path evaluated inside the test ⇒ **B1**;
   R2 same output asserted across a toggled knob ⇒ **B2**; R3 uniform verdict
   quantified over a family of *configurations* ⇒ **B3**; R4 `f∘g = id` ⇒ **B4**;
   R5 a known input transformation with a predicted output relation ⇒ **B5**;
   R6 a structural/totality/well-formedness predicate over a class ⇒ **B6**;
   R7 loads / exists / imports, no behavioural claim ⇒ **C**; else ⇒ **A**.
4. **The tie-break rule, stated because it moves the number: classify on the
   FORM OF THE EXPECTED VALUE AS WRITTEN, not on the docstring's intent.** A
   literal is A even when the sentence above it names an invariance. Chosen over
   "any-relational-wins" because the whole question is whether the *test* states a
   property — a property named in a comment and asserted as a literal does not
   survive the rewrite, which is precisely the failure mode being measured. It is
   also the only rule that reproduces: intent is not greppable.
   ⚑ **This is where the count is soft, and it is soft in a direction worth
   knowing.** At least four A's are relational in intent and one line from being
   relational in form — `test_kernel::test_erased_let_not_evaluated_at_runtime`
   (erasure must not change the value: asserts `== 7`),
   `test_json::test_whitespace_tolerated` (invariance under whitespace: asserts a
   literal), `test_balance::test_parens_in_strings_are_ignored` (same shape), and
   the `subtype`/`conv` argument-swap pairs in `test_effect_row` (assert both
   verdicts as literals rather than the relation between them). Written as the
   relation they name, each becomes B2/B5 **and costs nothing to migrate that
   way**.
5. **Sampling.** Every one of the 312 was assigned from its extracted assertion
   lines; no pattern-only extrapolation. A blind random sample of **20**
   (`random.seed(1701)`) was re-read in full: **1 revision candidate**
   (`test_extern_type_owned_by_declaration`, an accept with no explicit assert —
   A or C), **0** crossings of the A↔B boundary. Estimated error ≈ **5 %,
   confined to the A/C edge**, which does not move the headline.

#### The split, per file

| file | fns | A | B1 | B2 | B3 | B4 | B5 | B6 | C |
|---|---|---|---|---|---|---|---|---|---|
| `test_kernel.py` | 103 | 101 | 0 | 1 | 0 | 0 | 1 | 0 | 0 |
| `test_kernel_fulladt_chirality.py` | 29 | 11 | 14 | 0 | 0 | 4 | 0 | 0 | 0 |
| `test_refine.py` | 23 | 23 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| `test_backend_stream.py` | 16 | 16 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| `test_collections.py` | 16 | 10 | 4 | 0 | 0 | 0 | 1 | 1 | 0 |
| `test_memory.py` | 15 | 14 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| `test_backend.py` | 12 | 11 | 0 | 0 | 0 | 0 | 0 | 1 | 0 |
| `test_json.py` | 9 | 7 | 0 | 0 | 0 | 2 | 0 | 0 | 0 |
| `test_secret.py` | 9 | 8 | 0 | 0 | 0 | 0 | 0 | 0 | 1 |
| `test_backend_iface.py` | 8 | 8 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| `test_fd_passing.py` | 8 | 5 | 2 | 0 | 0 | 1 | 0 | 0 | 0 |
| `test_sockets.py` | 8 | 7 | 0 | 0 | 0 | 0 | 0 | 0 | 1 |
| `test_balance.py` | 7 | 6 | 0 | 0 | 0 | 0 | 0 | 1 | 0 |
| `test_effect_row.py` | 7 | 6 | 0 | 0 | 0 | 0 | 0 | 1 | 0 |
| `test_proc.py` | 6 | 6 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| `test_cond.py` | 5 | 4 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |
| `test_manas.py` | 5 | 5 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| `test_reflect_floor.py` | 4 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 2 |
| `test_sig_chirality.py` | 4 | 4 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| `test_string_utils.py` | 4 | 4 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| `test_tal_erase_chirality.py` | 4 | 2 | 1 | 0 | 0 | 0 | 0 | 0 | 1 |
| `test_climb.py` | 3 | 0 | 2 | 0 | 0 | 0 | 0 | 1 | 0 |
| `test_http.py` | 3 | 3 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| `test_coordinator.py` | 2 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| `test_fsm.py` | 2 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| **total (25 files)** | **312** | **267** | **24** | **2** | **0** | **7** | **2** | **5** | **5** |

`__init__.py` (0 L) and `ddc.py` (a helper) are the slice's other two files and
carry no test functions.

**A = 267 (85.6 %) · B = 40 (12.8 %) · C = 5 (1.6 %).**

⚑ **B3 = 0. Not one assertion in the slice quantifies over configurations.**
`grep -n "for prof\|for profile\|PROFILES\|for cfg\|for target" scaffold/tests/*.py`
returns **one** hit, and it loops over refinement *constraints*, not profiles
(`test_refine.py:70`). Every refusal in the corpus is a refusal in *one*
configuration, pinned to an exact error-message fragment. Since a profile in
chirality is exactly the knob that adds or removes a rule, this says the
moduleset/profile axis — the axis `PRINCIPLES.md` calls conformance-not-
configuration — has **no negative coverage at all**, in any of the three buckets.
That is the same class of defect as E156 G4 and E161 G0, one level up: not a gate
that passed while wrong, but an axis with no gate on it.

**So the author's question is answered against the reassuring reading:** the 306
are not a written-down semantics awaiting translation. They are 267 recorded
outcomes plus 40 properties, and the 267 carry their expected values from
whoever wrote them. Rewriting them in chirality moves the implementation and keeps
the intent — including the wrong intent, wherever there is one. The 40 are the
part that is already semantics.

#### The generatable subset — 33 of the 40, and from what

Generatable means: the rule set the assertion is about is **already a closed sum
or a declared table in the tree**, so a generator enumerates it and the test
bodies are a fold, not prose.

| family | n | source rule set | generator shape |
|---|---|---|---|
| **B4 round-trip** (eval/quote, parse/print, erase/reify, send/recv-fd) | 7 | `(data Term …)` / `(data Value …)` in `scaffold/lib/kernel.chiral`; `Sexp` in `sexp.chiral`; the SSA↔IR ctor pairs in `tal-erase.chiral` | enumerate the sum's arms; for each, build a minimal inhabitant and assert `quote(eval t) = t` / `show(parse s) = s` / `reify(erase f) = f`. One generator per inverse pair, N arms of test for free. |
| **B1 agreement, in-tree** (`test_kernel_fulladt_chirality`'s `assert_infer_agrees`, `test_cond`'s two-forms, `test_climb`'s manifest-vs-prose) | 17 | the 19 `infer` arms enumerated at `scaffold/lib/kernel.chiral` (`t-var … t-refine`); the desugaring table for `cond`; `climb.chiral`'s stage list | `assert_infer_agrees` is *already* the generator's inner loop hand-unrolled 12 times. The fold is over the arm list, not over a written corpus. |
| **B6 well-formedness** (canonical row sorted, all defs total, no ISA name in `emit-core`, all shipped files balance) | 5 | `(data SymOp …)` / row canonicalisation in `refine.chiral` + `effects.chiral`; the file glob | already written as folds over a family — these are the four that need no generator, only re-expression. |
| **B5 metamorphic** (linear-kind key is structural, map fold order) | 2 | `(data Ty …)` + `ty-cmp.chiral`'s total order (D-1) | enumerate two build orders per type / two insertion orders per map; assert equality of the key. |
| **B2 non-interference** | 2 | — | the two that exist are hand-shaped (`rollback on failure`, `two disciplines over one substrate`); no table to fold. |
| *not generatable* | 7 | — | the `struct.pack` ABI pairs and the mocked-transport agreements: their second source is outside the rule set. |

**The rule set that does the generating is the sum, not a spec document.** The
19 `infer` arms, the `OracleId`/`ExProv`/`ObsKey` sums in
`scaffold/lib/test-floor.chiral`, `SymOp` in `refine.chiral:11`, and `Qty`/`Seat`
in `kernel.chiral` are all closed and all enumerable by the compiler. Deleting an
arm and watching the generator's arity change is the same mechanism E170 D7
already relies on for `or-python` — *"when `or-python` reaches zero occurrences
it is deleted from the `OracleId` sum and the compiler enumerates the
remainder."* Nothing new is needed for the generator; what is missing is that
**no B3 generator can exist yet, because there is no closed sum of profiles** —
see the residue below.

#### ⚑ Judgment-rule coverage — which rules a test can distinguish from their absence

A rule has **isolated** coverage if some test fails when *only that rule* is
wrong. Rules enumerated from the `infer` case arms (`scaffold/lib/kernel.chiral`,
19 arms `t-var … t-refine`) plus the named side-condition procedures
(`data.chiral` positivity/coverage/linearity, `effects.chiral`, `refine.chiral`,
`totality.chiral`, `qtt.chiral`).

| rule | coverage | where |
|---|---|---|
| `t-var` / `ctx-lookup` index bounds | **isolated** | `test_kernel::test_var_index_bounds` |
| `t-type` + cumulativity | **isolated** | `test_universe`, `test_cumulativity` |
| `t-lam` un-annotated refused | **isolated** | `test_lambda_needs_annotation` |
| `t-let` quantity scaling | **isolated** | `test_let_scaling`, `test_linear_let_ok` |
| `t-global` / `t-prim` / `t-primty` / literals | **isolated** | `test_unknown_name`; `fulladt::test_prim_synthesizes_declared_type`, `test_primty_is_a_type`, `test_literals` |
| `t-tcon` kind check | **isolated** | `fulladt::test_tcon_kind_ok` / `_mismatch` |
| `t-con` arity / field type / param inference | **isolated** | `test_ctor_arity`, `test_ctor_field_type`, `test_constructor_infers_params_without_annotation` |
| `t-case` exhaustive / duplicate / default / binder | **isolated** | `test_exhaustiveness`, `test_default_branch`, `fulladt::test_case_*` |
| `t-refine` base + atom well-formedness | **isolated** | `test_base_must_be_i64`, `test_bad_atom_rejected` |
| strict positivity (direct, double-negative, through container, mutual) | **isolated** | `test_kernel` five cases |
| mutual data group load + rollback | **isolated** | `test_mutual_data_*` (rollback is the slice's one B2) |
| QTT linear once / twice / unused / split-across-branches | **isolated** | `test_kernel` four cases |
| erased-at-runtime refused, erased-in-type allowed | **isolated** | `test_erased_runtime_use_rejected`, `test_erased_type_use_ok` |
| porttype linear atom, linear-kind wrapper | **isolated** | `test_porttype_is_linear_atom`, `test_linear_kind_wrapper_*` |
| linear-kind cycle key determinism (D-1) | **isolated** | `test_linear_kind_key_is_structural_not_repr` (B5) |
| effect-in-pure / via-alias / in-erased refused | **isolated** | `test_effect_row`, `test_kernel` |
| row inference from the call graph; canonical sort | **isolated** | `test_row_inferred_from_call_graph`, `test_canonical_form_is_sorted` |
| totality: structural / numeric-guarded / symbolic / mutual-lex / escaping-self | **isolated** | `test_kernel` six cases |
| refinement entailment, is-empty, narrow both branches, symbolic forward, arithmetic-bound refusal | **isolated** | `test_refine` |
| ⚑ **`infer-pi`** | **ISOLATED 2026-08-29 — generated, on the floor** | Was: exercised by every `def` that has a type; no test fails on `infer-pi` alone. Now **`scaffold/tests/samples/e170_infer_arms.chiral`** check G (`test-e168-floor.sh` D1) — `(Pi q s A A)` lands in A's own universe, quantified over the closed `Qty` × `Seat` sums (3 × 2) × 5 type witnesses, with the non-type domain and codomain refused at all 6 combinations. Mutant `(v-type (max-lvl l1 l2))` → `(v-type (+ 1 …))`: **RED**, and only G |
| ⚑ **`infer-app`** | **ISOLATED 2026-08-29 — generated, on the floor** | Was: every application in every fixture, the subject of none. Now check F — applying the identity AT T to each arm of the `Term` sum synthesizes T, and an identity at any other type is refused (62 refusals). Mutant: `infer-app2` stops checking the argument against the domain → **RED**, and only F |
| ⚑ **`infer-ann`** (`the`) | **ISOLATED 2026-08-29 — generated, on the floor** | Was: used as a *tool* in dozens of fixtures, the subject of none. Now check E — `(the T t)` synthesizes T with t's usage for every arm, and annotating with any other type is refused (62 refusals). Mutant: `infer-ann2` stops checking the term against the annotation → **RED**, and only E |
| **`subtype` universe/cumulativity leg** | **combination only — measured still open 2026-08-29** | reached through `check`, never driven. The Lane D generator does **not** close it: mutating `(<=i la lb)` to `(=i la lb)` leaves `e170_infer_arms` GREEN, because no witness in its family checks a term at a *strictly* larger universe. Named here rather than rounded into the row above |
| **usage-vector algebra** (`uzero`/`uadd`/`uscale`/`ujoin`) | **combination only in this slice — measured still open 2026-08-29** | isolated only in `test_qtt_selfhost.py` — a **differential**, so it dies with the oracle. Lane D's check B compares usage vectors across the two modes, which catches a vector DROPPED at the boundary but not a wrong table: `close-binder` losing its `uscale q uv` leaves `e170_infer_arms` GREEN (its let-bound value has zero usage). An open row, not a closed one |
| ⚑ **`conv` eta** | **RE-FOUNDED 2026-08-26 — isolated, on the floor** | Was: `grep -ln eta scaffold/tests/*.py` → the only checker-side hit is `test_nbe_selfhost.py`, a differential. Now **`scaffold/tests/samples/e170_conv_eta.chiral`** (Phase 12, `test-e168-floor.sh` C1) — a metamorphic law over a family of five neutral heads (a neutral converts with its 1- and 2-level eta-expansion, in both orders), its refusals over all 25 ordered pairs, and a control that separates "eta is gone" from "conv is broken". Two harness-run mutants |
| ⚑ **QTT semiring tables** (`qadd`/`qmul`/`qjoin`/`qfits`) | **RE-FOUNDED 2026-08-26 — isolated, on the floor** | Was: `grep -ln "qadd\|qfits\|qmul"` → `test_qtt_selfhost.py` only — a differential. Now **`scaffold/tests/samples/e170_qtt_semiring.chiral`** (C2) — algebraic laws exhaustive over the closed `Qty` sum (3 singles / 9 pairs / 27 triples) **plus a pin**, because the laws alone are not enough: with `qadd`'s `1+1` reverted to `(q1)` every law check stays GREEN (measured) and only the pin — `qadd`/`qjoin` composed with `qfits` the way the checker's own accounting composes them — goes red. Two harness-run mutants |
| ⚑ **`base <: refine` only-if-TOP** | **RE-FOUNDED 2026-08-26 — isolated, on the floor** | Was: `grep -ln "base<:refine\|only-if-TOP"` → `test_refine_kernel_chirality.py` only — a differential. Now **`scaffold/tests/samples/e170_refine_top.chiral`** (C3) — the tree's **first refusal-universality check**: 22 non-TOP constraints generated by walking the closed `SymOp` sum × 3 bases = 66 refusals, with the controls that stop "refuse everything" from passing it and a mutant that reddens each. Two harness-run mutants. ⚑ *It is NOT a `B3`: B3 is quantification over a family of CONFIGURATIONS (`:310`) and this quantifies over a family of constraints. B3 stays 0 and the row below stays open* |
| ⚑ **every rule, under a profile that lacks it** | **NO coverage anywhere** | B3 = 0 across all 709; there is no closed sum of profiles to quantify over |

**The finding, stated plainly.** Three named rules — eta-conversion, the QTT
semiring tables, and the `base <: refine` TOP side-condition — have their *only*
isolated coverage inside the 335 differentials, i.e. inside the leg E170 deletes.
E170 §D1 already records that `rocq/` can re-found **zero** of the 335 today, so
unless those three are re-founded by name they lose isolated coverage entirely
and become rules nothing can distinguish from their absence. They are added here
as a named obligation on E170's differential leg, not a new element.

⚑ **DISCHARGED 2026-08-26 — the three are re-founded and the obligation is
closed; the rows above carry where.** Three fixtures on the E168 floor
(`e170_conv_eta`, `e170_qtt_semiring`, `e170_refine_top`, judged by
`test-e168-floor.sh` as C1/C2/C3) plus **six harness-run mutants**, a pair per
rule. What was built and what was measured:

- **The shapes are relational, not outcome-locking** — a metamorphic eta law, an
  algebraic law suite quantified over a closed sum, a refusal quantified over a
  generated family. An outcome lock would have encoded the intent exactly as
  faithfully as the oracle did, i.e. moved the tautology into chirality.
- **Laws alone would have re-founded nothing, and that is measured, not argued.**
  Reverting `qadd`'s `1+1` saturation to `(q1)` leaves commutativity,
  associativity, identity, absorption, distribution AND the `qfits` partial order
  all GREEN; only the pin (the two tables composed the way the checker's
  accounting composes them) is red. The ⚑ in the brief was right.
- **The falsifier needed a new shape.** `mut-run` observes the base by PATH and
  the mutant by self-contained TEXT, and a checker-rule mutant is neither, so
  `test-e168-floor.sh` grew `mutant_red`: it edits a scratch copy of
  `scaffold/lib`, re-resolves the fixture against it, and asserts red **for a
  named reason** — plus that the mutation matched something, that the mutant
  still built, and that the fixture carries the written `MutRun` claim the
  mutation implements, so the claim and the run cannot drift.
- **Isolation is established rather than believed:** a 6×3 matrix of every mutant
  against every fixture is a clean diagonal — each mutant reddens its own fixture
  and leaves the other two green.
- **Cost:** Phase 12 23.555 s → 41.786 s (+18.2 s, 9 assertions); the suite is
  **12 phases / 187 `ok` / 0 FAIL / 82 roots / exit 0 in 3m07.828s**.

**Still open, and NOT closed by this:** the fourth ⚑ row — *every rule under a
profile that lacks it* — is untouched, and `B3` is **still 0**. The refusal
fixture quantifies over a family of *constraints*, which is the same discipline
one axis over; B3 is quantification over a family of **configurations** (`:310`),
and there is still no closed sum of profiles to quantify over. Naming the new
fixture a B3 would close that row by relabelling, which is the move this section
exists to refuse.

#### ⚑ LANE D — the generator, and the SUBSUMPTION MATRIX (2026-08-29)

**Built:** `scaffold/tests/samples/e170_infer_arms.chiral`, judged by
`test-e168-floor.sh` row **D1** with **seven harness-run mutants**. Eight
properties folded over the closed `Term` sum instead of one hand-written instance
per arm; `ia-tag` is an exhaustive `case` over `(data Term)`, so a 17th
constructor is a **compile error** and a deleted one **moves check A's count** —
the same enumeration mechanism E170 D7 already relies on for `or-python`. What it
quantifies over: `(data Term)`'s 16 constructors (checks A/B/C/D/E/F/H), `Qty` ×
`Seat` (check G), and a five-member set of pairwise-unrelated wants that drives
**62 refusals per negative half**. Suite **12 phases / 195 `ok` / 0 FAIL / 82
roots / exit 0 / 3m24s**; Phase 12 24 → 32 assertions.

⚑ **The measured count of `infer` arms is 16, not 19.** `scaffold/lib/kernel.chiral:820-836`
and `scaffold/lib/syntax.chiral:18-34` both enumerate sixteen. The "19 `infer` arms"
written above (`:429`, `:445`) is a **count error, not a stale count** — no
constructor has been removed since — and it is corrected here rather than in place,
because the rows above are a dated measurement and the generator is what re-counted
them. Nothing else in the classification depends on the figure.

**What it buys, and it is ADDED COVERAGE rather than retired locks.** The three
rules the table above lists as *combination only* — `infer-pi`, `infer-app`,
`infer-ann` — now have isolated coverage (rows corrected above), and so does the
`infer`→`check` boundary itself, which no test in any of the three buckets drove.
That is the yield. It is not a licence to delete.

⚑ **The honest limit, stated before the matrix.** `assert_infer_agrees` compared
chirality's `infer` against kernel.py's — a **second producer**. Nothing in-tree
replaces that (E170 §D1: the Rocq leg re-founds zero of the 335). What the
generator quantifies is infer-against-**check**: two paths through **one** rule
set, which under E168's ranks is implementation-derived and cannot catch a rule
that is wrong in a self-consistent way. Lane E is the lane that reaches
correctness; this one reaches coherence, exhaustively.

##### The matrix — 13 mutants of rules the corpus outcome-locks, RUN against the generator

Method: each mutation applied to a scratch copy of `scaffold/lib`, the fixture
re-resolved against it, compiled by B1 and executed (the `mutant_red` procedure,
run standalone). RED = the generated property fails, and the check it names is
recorded. No Python was run; the locks' verdicts are read from the literal each
one asserts, which the mutant demonstrably moves.

| # | rule, and the lock(s) that own it | mutant | generator | verdict |
|---|---|---|---|---|
| S1 | `t-var` / `ctx-lookup` index bounds — `test_kernel::test_var_index_bounds` | out-of-range index returns `tc-ok` | **GREEN** | **lock STAYS** — the family has no ill-formed witness |
| S2 | `t-type` universe bump — `test_universe`, `test_cumulativity` | `Type l : Type l` | **GREEN** | **lock STAYS** — every check re-derives the level, so both sides move together |
| S3 | `t-lam` un-annotated refused — `test_lambda_needs_annotation` | the arm synthesizes the very Pi `check` would introduce | **RED — check D** | **lock RETIRABLE** |
| S4 | `t-let` quantity scaling — `test_let_scaling`, `test_linear_let_ok` | `close-binder` drops its `uscale q uv` | **GREEN** | **lock STAYS** — the let witness binds a literal, whose usage is zero |
| S5 | unknown name — `test_kernel::test_unknown_name` | `infer-global` reads the prim table | **RED — check D** | **lock stays, CAVEATED** (below) |
| S6 | `t-lit-i : I64` — `fulladt::test_literals` | the arm synthesizes `Str` | **RED — check D** | **lock stays, CAVEATED** (below) |
| S7 | `t-lit-s : Str` — `fulladt::test_literals` | the arm synthesizes `I64` | **GREEN** | **lock STAYS** — nothing in the family consumes a Str |
| S8 | `t-primty : Type 0` — `fulladt::test_primty_is_a_type` | the arm synthesizes `Type 1` | **GREEN** | **lock STAYS** |
| S9 | `t-case` exhaustiveness — `test_kernel::test_exhaustiveness` | a missing ctor branch is `cov-ok` | **GREEN** | **lock STAYS** |
| S11 | `t-refine` base well-formedness — `test_refine::test_base_must_be_i64` | any base admitted | **GREEN** | **lock STAYS** |
| S12 | `subtype` cumulativity | `(<=i la lb)` → `(=i la lb)` | **GREEN** | no lock to retire; the row above is corrected to say it is still open |
| S13 | `conv` at the top | `(_ (conv lvl a b))` → `(_ true)` | **RED — check C** | Lane C's C1 already owns this rule; the generator concurs |
| S10 | the seven committed falsifiers (B/C/D/E/F/G/H) | see `test-e168-floor.sh` D1 rows | **RED, each naming its own check** | this is what makes the eight checks evidence |

⚑ **Why S5 and S6 are RED and still not a licence to delete.** Neither is caught by
a property *about* that rule. They are caught by check D's err-count, because other
witnesses in the family **consume** the mutated arm — `t-app (t-prim "pf") (t-lit-i 5)`
stops synthesizing when a literal's type moves, and `t-global "gi"` stops when the
global table is misread. That coupling is a property of the witness list, not of the
rule set, and **nothing pins it**: check A counts tags, not what a witness applies to.
Retiring those locks would be betting on an accident of the family. They stay until
the coupling is itself pinned, and saying so is the difference between a matrix and
an argument.

##### Check A's own falsifiers, run out of band (2026-08-29)

Checks A and the vacuity term guard the **fixture's own family**, not a library
rule, so `mutant_red` — which mutates `scaffold/lib` — cannot express them. A row
that cannot fail is the defect class this whole phase exists for, so they get no
row rather than a decorative one, and the three falsifiers were run by hand:

| falsifier | result |
|---|---|
| a 17th constructor added to `(data Term)` (`syntax.chiral`) | **`load: non-exhaustive case`** — the fixture does not compile, which is the intended failure mode: a new arm cannot be silently uncovered |
| the `t-lit-s` witness deleted from `ia-arms` | **exit 1**, report names check A ("the family IS the closed Term sum…") |
| the `v-primty "Nope"` want deleted from `ia-wants` | **exit 1**, report names check A — the vacuity term, so the negative halves cannot quietly shrink |

##### The verdict, in numbers

- **1 of the 267 outcome locks is retirable** — `test_kernel::test_lambda_needs_annotation`,
  because check D is a property *about* the mode switch (`infer` refuses exactly this
  arm; `check` introduces exactly this arm against a Pi and refuses it against a
  non-function) and its mutant reddens D alone.
- **2 more are RED but caveated** (S5, S6) and are **not** retired.
- **The other 264 stay**, labelled **rank-4 regression locks**: eight of the nine
  rule rows above are GREEN under a mutant an outcome lock catches, and the reason is
  structural rather than fixable by adding witnesses — a relational property over
  `infer` re-derives the arm's result on both sides of the relation, so a mutant that
  moves an arm's result moves the relation with it. **This is the same finding as Lane
  C's `qadd` measurement, one level up:** laws alone re-found nothing there, and
  coherence alone subsumes nothing here.
- **In-tree successors for the relational half:** the **12 `assert_infer_agrees` call
  sites** (`test_kernel_fulladt_chirality.py:255-377`) and the eval/quote share of the B4
  round-trip family now have one — at the weaker infer-vs-check rank, which is stated
  in the fixture header rather than left to be inferred.

**So the deletion gate stands where Lane C put it, and the generator does not move
it.** Lane C re-founded the three rules that had no isolated coverage at all; that
is what makes deletion defensible. The generator adds coverage for four more rules
that had none, and retires one lock. Anyone reading "the generator subsumes the
outcome locks" should read this matrix instead.

##### Left scoped, inside E170 (no new element minted, and none is owed)

The generatable table above names five families. Lane D built the two that fold
over sums the fixture already had to enumerate: the **`infer` arms** (the 12
`assert_infer_agrees` sites) and the **eval/quote half of the B4 round-trip**.
The other three are *not* cheap once this machinery exists, because the machinery
that was expensive is the witness family, and each of them needs its own:

- **`Sexp` parse/print round-trip** — a different module (`sexp.chiral`) with its
  own sum and its own minimal inhabitants; nothing in `e170_infer_arms` transfers
  except the shape.
- **`SymOp` + row canonicalisation (B6, 5 tests)** — the table above already says
  these "need no generator, only re-expression", so they belong to the migration
  and not to this instrument.
- **`Ty` + `ty-cmp`'s total order (B5, 2 tests)** — two build orders per type; a
  small family, but again its own.

They stay E170's, in the same row Lane C and Lane D are recorded in. **No follow-on
element is named for them**, because naming one that does not exist is the phantom
dep the deferral rule refuses.

**Still zero, and still honestly zero:** `B3` — quantification over a family of
**configurations** (`:310`). Lane D quantifies over `Term`, `Qty` and `Seat`; none of
those is a profile, and there is still no closed sum of profiles to quantify over.
The row stays open.

#### ⚑ LANE E — PORT-TYPE NEGATIVES, and THE PER-PORT MAP (2026-08-29)

**The operational test, and why it is the only one here that reaches
correctness.** A port type carries meaning **iff there exists a wrong
implementation satisfying its shape that the type rejects** — mutation testing
with the *type* as the test and the *implementation* as the mutant. Lane C
measured a `qadd` mutant leaving all five algebraic laws green; Lane D measured
eight of thirteen rule mutants leaving the generated relational suite green,
because a relational property over `infer` re-derives the arm on both sides of
the relation. Both instruments establish *coherence*. A port type is a claim
about the world, so it is the one instrument left pointed at a rule that is wrong
in a self-consistent way — and per the arc's weak-statement floor, **Lane B reads
this map**: a certificate's statement is only as strong as the type it names, so a
weak-provable statement is exactly a port whose type rejects too little.

**Built:** `scaffold/tests/samples/e170_port_twin.chiral` (the minimal-pair base),
six `e170_reject_*.chiral` refusals, `e170_port_zeros.chiral` (the accepted wrong
implementations), and two generated halves + an enumeration guard in
`test-e168-floor.sh` — Phase 12 rows **E1–E10**, +11 assertions (32 → 43).

##### The enumeration, and how it was made

Three greps over `scaffold/lib`, all re-run every suite pass as row **E10**, which
fails with *"the port surface moved; RE-MEASURE the Lane E map"* the moment any of
them moves. Named at its honest rung, exactly as G8 is: a grep is detection, not
proof.

| what | count | command |
|---|---|---|
| porttypes (shard 1, the opaque linear atoms) | **10** | `grep -rh '^(porttype ' scaffold/lib \| wc -l` |
| externs (shard 2, the declared contracts) | **97** | `grep -rh '^(extern ' scaffold/lib \| wc -l` |
| of those, **crossings** (`=>` in the declared type) | **62** | `… \| grep -c '=>'` |
| of those, taking a **held capability** `(1 x T)` | **23** | `… \| grep -c '(1 '` |
| **crossings taking NO capability at all** | **42** | `… \| grep '=>' \| grep -vc '(1 '` |

The ten porttypes: `Sock` · `LSock` · `Fd` · `Pool (n I64)` · `Pty` · `Clock` ·
`Timer` · `Env` · `Backend` · `Secret`. Beside them, and **not** counted as
porttypes because they are not: the cap-shaped **`data`** obligations — `Reap`
(`proc.chiral:27`), `Builder`/`Oracle` (`test-floor.chiral`), `SockVec`
(`lincoll.chiral`) — which are linear by their fields rather than by a registry.
They get their own row below because the answers differ.

##### The per-port map

Seven facets, because "does this port type carry meaning" is not one question.
**M** = a wrong implementation satisfying the shape is REJECTED; **0** = it is
ACCEPTED, and the fixture that proves it is committed. The evidence column names
the Phase 12 row.

| port | custody (drop / duplicate) | nominal distinctness | value content in the type | non-forgeable | cap required to act | what the crossing DOES | reachable |
|---|---|---|---|---|---|---|---|
| **Sock** | **M** — E2, E3, E8 | **M** — E4 | **M** — E5 (`sock-recv`'s `(refine I64 (> 0))`) | **0** — `sock-connect` / `sock-listen` / `socketpair` mint from ambient | partial — send/recv/close take it; `nb-poll`, `nb-sock-connect-in` are bare `Bytes` | **0** — E7b/Z1 | yes |
| **LSock** | **M** — E8 | **M** — E4 (the same pair, other side) | none in the type | **0** — `sock-listen` | **M** — `sock-accept`/`lsock-close` are the only ops, both take it | **0** | yes |
| **Fd** | **M** — E8 | shape-only (no sibling atom to confuse it with) | none | **0** — `adopt-fd : (=> I64 Fd)`, E7b/Z2 | **0** — `read`/`write-fd`/`fcntl` do the real syscall on a bare `I64`, E7b/Z3 | **0** | yes |
| **Pool** | **M** — E8 | **M** — E6 | **M** — E6, the tree's ONLY value-indexed porttype; and **0** for offsets, E7b/Z5 | **0** — `pool-create` from a bare size | **M** — all four pool ops take it | **0** | yes |
| **Pty** | **M** — E8 | shape-only | none | **0** — `adopt-pty : (=> I64 Pty)` | **0** — `nb-ptsno-raw`/`nb-ptunlock`/`nb-dup2`/`spawn-in-pty` are all bare | **0** | yes |
| **Clock** | **M** — E8 | **M** — measured out of band: a `Timer` where a `Clock` is wanted → `load: type mismatch` | none | — | — | **0** | **NO — uninhabited** |
| **Timer** | **M** — E8 | **M** — same measurement | none | — | — | **0** | **NO — uninhabited** |
| **Env** | **M** — E8 | shape-only | none | **0** — `env-open : (=> Unit Env)` mints from nothing | **M** — `env-view` is the only env read in the tree | **0** | yes |
| **Secret** | **M** — E8 | **M** — E7, the custody claim | none | **0** — `secret-seal : (=> Bytes Secret)` | **M** — `secret-reveal`/`secret-wipe` are the only ops | **0** — and secret.chiral says so: revealed bytes are untracked (E44) | yes |
| **Backend** | **M** — E8 | shape-only | none | **0** — `backend-open : (=> Str Backend)` | **M** — every `be-*` consumes the handle | **0** | yes |
| **cap-shaped `data`** (`Reap`, `Builder`, `Oracle`, `SockVec`) | **partial** — conserved at `(1 x T)`, but **0 at omega**: `(w r Reap)` is admitted and one `Reap` becomes two, E7b/Z6 | — | — | **0** — constructible from nothing (`e168_cap_thread.chiral` already says so of `Builder`) | — | **0** | yes |

##### What that adds up to, said plainly

- **Custody is the one facet that carries meaning everywhere, and it is ONE
  mechanism, not ten answers.** Every porttype is an opaque linear atom, so
  every one refuses a dropped or duplicated capability for the same reason.
  Row E8 quantifies that over the family read off the tree (10/10 refused) and
  row E9 is its direction control (10/10 twins admitted) — without E9 a checker
  that refused every program would score E8 green, which is the trap
  `e170_refine_top`'s check C exists for.
- **Three ports carry something BEYOND custody, and they are the whole yield of
  the per-port question:** `Sock`'s refinement on `sock-recv`'s length,
  `Pool`'s value index, and `Secret`'s nominal identity standing between a sealed
  value and a sink. Everything else in the "value content" column is empty.
- **⚑ THE WIDEST ZERO: no port type in the tree says anything about what a
  crossing DOES.** `pe-send-noop` — a `sock-send` stand-in with the crossing's
  exact type that reports success and sends nothing — typechecks. The port types
  govern *custody of the authority*, not *the effect*. Every row of the last-but-one
  column is a 0, and that is the honest ceiling on what "the port-check is the
  type-check" buys today.
- **⚑ Non-forgeability is ZERO for every port**, because every cap has an ambient
  mint: `adopt-fd` and `adopt-pty` from a bare `I64`, `env-open` from `Unit`,
  `secret-seal` from `Bytes`, `backend-open` from `Str`, `pool-create` from a
  size, `sock-connect`/`sock-listen`/`socketpair` from ambient authority. Holding
  a cap is evidence of a *threading obligation discharged*, not of provenance.
- **⚑ `Clock` and `Timer` are UNINHABITED.** No extern in `scaffold/lib` returns
  either, and a porttype has no constructor, so no term anywhere can produce one:
  `time-mono` and `sleep-ms` are crossings no program can reach, and
  `supervisor.chiral`'s `(1 c Clock)` parameter makes it uncallable from a root.
  Their types still refuse a dropped or duplicated cap — a refusal quantified over
  an empty set of callers. Recording that as "meaning" without the reachability
  column would be this lane's own gate-that-cannot-fail.
- **⚑ A SHARPER E171 MEASUREMENT than the one it was minted on.** `docs/banks/port.md`
  shard 3 (2026-08-25) measured a `->` def calling a `=>` **def**. `pe-pure-write`
  calls the `=>` **extern** directly and compiles, so not even the declared crossing
  is confined to an effectful context. E171 is unbuilt; this is the floor under it.
- **⚑ PROTOCOL STATE IS NOT IN THE TYPE beyond the `Sock`/`LSock` split.**
  `recv-closed (1 sock Sock)` (`ports/sock.chiral:24`) hands back a *plain*
  `Sock`, so a send on a socket the peer has already closed typechecks
  (`pe-send-after`, E7b/Z7). `docs/banks/port.md` shard 8 says *"do not assert
  ports are session-typed"*; this is that sentence as a program, and it is why
  the map above gives `Sock` no protocol column to score.
- **⚑ The omega guard is porttype-only.** `(w s Sock)` is refused outright
  (*"function parameter of a linear type at quantity omega"*); `(w r Reap)` is
  admitted and `(pe-two-reap r r)` duplicates the obligation. `test-e168-floor.sh`'s
  G8 comment already named this as a measured gap decision 10 takes on purpose;
  `e170_port_zeros.chiral` is the exploit, committed, so the day it closes the row
  goes red.

##### How "the wrongness is SEMANTIC and not structural" is established

A negative refused for a typo, a wrong arity or a missing constructor proves
nothing about the port type — that is the gate-that-cannot-fail class this floor
exists for, and this tree has shipped four of them. Two mechanisms, both run:

1. **Every refusal is a MINIMAL PAIR against a definition in
   `e170_port_twin.chiral`**, which compiles (row E1): same imports, same declared
   type, same arity, every name bound, every constructor real. In three of the six
   the entire difference is one identifier (`s2` → `s`) or one literal (`1` → `0`,
   `16384` → `4096`). A structural defect would have taken the twin down too.
2. **E4 is the sharpest case and it is worth naming separately:** `Sock` and
   `LSock` are *both* nullary opaque linear atoms — identical structure, identical
   kind, identical linearity, no fields to disagree about. There is nothing
   structural left to object to, so the only thing that can refuse
   `e170_reject_port_swap.chiral` is the two atoms' **nominal identity**.
3. **The generated family is a one-identifier pair by construction** — `(pe-fam x y)`
   against `(pe-fam x x)`, same `data`, same declared type, same constructor at the
   same arity.

##### The guards, falsified — run, with measured output

| falsifier | result |
|---|---|
| E8 disarmed: the "wrong" half generated as `(pe-fam x y)` — i.e. no longer wrong | **`FAIL E8  0 of 10 porttypes refuse a duplicated capability; Secret DUPLICATED and accepted; …`** |
| E9's control armed: the twin generated as `(pe-fam x x)` — what a "refuse everything" checker looks like | **`FAIL E9  0 of 10 twins compile; Secret threaded ONCE EACH was refused: load: linear binder usage mismatch; …`**, with E8 still green — which is exactly the reading E9 exists to separate |
| E10 with the map's cap-taking count moved 23 → 24 | **`FAIL E10 the port surface moved; RE-MEASURE the Lane E map …; cap-taking externs 23 (map says 24)`** |

The six `refuses` rows carry their own falsifier by construction: each asserts the
diagnostic *text*, not merely exit 1, so a refusal for another reason is red.

##### ⚑ B3 is NOT closed, and this lane did not move it

`B3` is refusal-universality over a family of **CONFIGURATIONS**
(`RUNG1-CHECKLIST.md:310`). E8 quantifies over a family of **PORTS**. There is
still no closed sum of profiles to quantify over, `B3` is still **0**, and the
fourth ⚑ row in the judgment-rule table above — *every rule, under a profile that
lacks it* — is untouched. Lane C refused this relabelling and Lane D refused it;
a per-port negative is not a per-profile negative.

**Cost and state.** Phase 12 41.786 s → ~66 s (+24 s, 11 assertions); suite
**12 phases / 206 `ok` / 0 FAIL / 82 roots / exit 0 / 3m29.509s**. F3's swept/floor
split moves 18 → 26 floor rows. No `.py` run, none deleted; `scaffold/build/B1` and
`blob.chiral` untouched, and nothing this lane adds is in the compiler blob, so no
fixpoint is owed.

#### Does 306 hold?

**No — it is reproducible only to ±6 functions and ±2 files, and its membership
is unrecoverable.** The triple sums correctly (335 + 68 + 306 = 709; 41 + 9 + 29
= 79), so nothing is double-counted, but the per-file assignment was never
written down and the two published sub-figures are **mutually inconsistent**:

- Placing `test_resolve_chirality.py` (6 fns) in the differential bucket makes the
  differential total **exactly 335** — over **43** files, not 41.
- Placing it in the B1-driven bucket makes that bucket **exactly 68** over
  **9** files — and the differential total 329, not 335.

Both cannot hold at once, so at least one of the published sub-counts is off by
this one file. The reconstruction that keeps the *rule* consistent (an assertion
is B1-driven iff it depends on running B1) gives **differential 42 / 329 ·
B1-driven 10 / 68 · checker-only 27 / 312**, and 312 is the slice classified
above. The recorded 306/29 is within one file's worth of that and is **not
corrected in the rows above** — it is a dated 2026-08-23 measurement and the
delta is one classification call, not an error to overwrite. What is corrected
is the claim that the split is a fact you can act on file-by-file: it is not,
until E170 W1 writes the per-file `Mig` records that make it one. E170 §D15
already moved the conservation law to a per-file join for exactly this reason;
this measurement is the independent evidence that the global triple could not
have carried it.


---

## Order / dependencies
A1a → A1b → A1c → A1d (front); A2a → A2b (driver) in parallel with A1;
A1d + A2b + A3 → A4 (fixpoint); A4 → B' (demote + pub strip). Full selfhost = A4.
Phase C runs as a **background migration** (does NOT gate chirality/scriba feature
work): C0/C1 done → C2 grinding → C3 (triage) unblocks C4/C5/C6. "Zero python"
= C6, reached feature-by-feature via the sample-with-feature discipline.
