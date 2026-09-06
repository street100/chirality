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

### C-inventory — the full slice list (re-measured 2026-08-31)

Total in-tree python: **14 files / 4,629 LOC**
(`find . -name '*.py'`, excluding `.git` and `.claude`).

Was 133 files / 29,243 LOC on 2026-08-24. The drop is not work: the migration
to `/workspace/chirality` simply did not carry the Python oracle, its 79-file
test suite, the Wayland mock, the bench harness or the bootstrap scripts. They
are still in `/workspace/metis-the-lang`. Nothing was rewritten to get here.

The boundary is **not** "in the git tree" — it is *what chirality is built from,
verified by, or runs on*.

⚑ **The repo-level goal is stricter than rung 1.** Standing instruction,
2026-08-31: *zero python anywhere in `/workspace/chirality`* by the end of the
tools-replacement stage. That overrides the OUT-OF-SCOPE reasoning below for
the purpose of deletion — those files are still out of rung-1 scope, and they
are still scheduled to go. Route step 1 replaces `tools/` with chirality
programs and deletes the directory.

**IN SCOPE — owned (C7)**

| file | LOC | why it is chirality |
|---|---|---|
| `tools/syscall-map/syscall-map.py` | 244 | generates/checks the syscall table — the crossing surface |
| `tools/scriba-edit-smoke/scriba-edit-smoke.py` | 131 | a PTY smoke that **tests scriba**, so it is a chirality test |
| `tools/scriba-run-smoke/scriba-run-smoke.py` | 51 | as above |
| **total** | **426** | |

**OUT OF RUNG-1 SCOPE — the authoring harness (dies with manas), but still slated for deletion by the zero-python goal**

| file | LOC |
|---|---|
| `tools/ledger-lint/ledger-lint.py` | 1852 |
| `tools/pack/pack.py` | 1522 |
| `tools/frontier/frontier.py` | 651 |
| `tools/capture/capture.py` | 620 |
| `tools/lens/lens.py` | 404 |
| `tools/doc/doc.py` | 331 |
| `tools/paren-audit/paren-audit.py` | 154 |
| `docs/examples/refs/*.py` | 502 |
| `.planning/capture-fixtures/*.py` | 12 |
| **total** | **6,048** |

**GONE — not carried by the migration, by decision**

`scaffold/tests/*.py` (79 files, 14,784 LOC) · `scaffold/chirality/*.py` (23,
8,451) · `scaffold/tools/selfhost.py` (442) · `scaffold/tools/balance.py` (113)
· `scaffold/bin/stage1-selfcompile.py` (29) · `scaffold/mock/*.py` (277) ·
`scaffold/bench/*.py` (398). External judgment is cut (HANDOFF decision 5), and
the oracle went with it. Check H of `ledger-lint` reports VACUOUS for exactly
this reason: it verified the cheatsheet's operators against `refine.py`, and
nothing verifies them now.

## Order / dependencies
A1a → A1b → A1c → A1d (front); A2a → A2b (driver) in parallel with A1;
A1d + A2b + A3 → A4 (fixpoint); A4 → B' (demote + pub strip). Full selfhost = A4.
Phase C runs as a **background migration** (does NOT gate chirality/scriba feature
work): C0/C1 done → C2 grinding → C3 (triage) unblocks C4/C5/C6. "Zero python"
= C6, reached feature-by-feature via the sample-with-feature discipline.
