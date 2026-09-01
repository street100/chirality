---
element: E18
slug: tal-check
title: TAL checker + reference tal interpreter
kind: SELF-HOST
example: examples/E18-tal-check.md
status: audited
updated: 2026-08-01
---

# E18 SPEC — TAL checker + reference tal interpreter

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** two new files — `scaffold/lib/tal-check.chiral` (the tal
  **checker**: `ck-instr`/`ck-block`/`ck-term`/`ck-fn`/`ck-prog` over the typed IR,
  a register-file Gamma `REnv` threaded not mutated, `CkR` errors-as-values) and
  `scaffold/lib/tal-eval.chiral` (the **reference interpreter**: `tal-eval`, an
  explicit `Store`, a strictly-decreasing fuel measure for totality) — porting the
  two halves of `scaffold/chirality/tal.py` (`check_fn:114`, `TalMachine:253`). Run on
  the RT interpreter they reproduce `tal.py`'s verdicts and values: `ck-*` accepts
  exactly what `check_fn` accepts (same reason class on reject), and `tal-eval`
  yields the same values as `TalMachine` on the golden programs.
- **Non-goals (residue → §6):**
  - **Typed-init on byte cells** (linear `bput`-before-read) — the map row calls
    this "bounded hardening, **not owed by E18**" (the authored byte lib only
    writes fresh cells); decision #a.
  - **The Category-B production drop** + how it attests agreement with `tal-eval`
    (evidence hooks / sampling) — floor-agreement + evidence territory, decision #c.
  - **The `sys`/`bptr` sysface rules** — the port/effect story (E51/E76), not the
    pure floor; the example already omits them.
  - Does **not** delete or wire-in `tal.py`; it stays the golden oracle **and** the
    trusted drop. **This element PROVIDES `check-fn` to [[E16-lowering]]/[[E17-optimizer]]**
    (their preserve-check), which are scoped around this coupling.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** `TAL floor: checker + trusted interpreter | CONFORMS
  · S · E18,E19 | "Typed TAL checked independently of kernel; Built; check_fn types
  every instr, TalMachine trusted drop, sysface marked. One honest soundness limit
  vs Morrisett: no typed-init on byte cells (authored lib only writes fresh) —
  bounded hardening, not owed by E18."` CONFORMS ⇒ faithful transcription of a
  complete artifact. The example gate passed (`reviewed`, load-verified: 7 defs, 18
  data types).
- **Live code this composes with (do NOT respec):**
  - `scaffold/chirality/tal.py` — the golden oracle (both halves). **Checker:**
    `check_fn` (`:114`) seeds Gamma from params; `_check_block` (`:121`) is the
    per-instruction rule table — `const` (range-checks the literal), `prim`/`call`/
    `con` (annotation must equal the looked-up sig's return), `bnew/bget/bput/blen`
    (byte floor), the `case` terminator (coverage or default); `_check_args`
    (`:235`, arity+type); `_fields` (`:244`). tal types are
    `("I64",)/("Str",)/("Bytes",)/("Data",dname,targs)`. **Interpreter:**
    `TalMachine` (`:253`), `call` (`:263`), `_block` (`:270`) — note `bnew` =
    `bytearray(n)` (zero-init contract), a **cell is an id/buffer not an address**
    at the pure floor.
  - `scaffold/lib/tal-ir.chiral` — the type-**erased** executable IR
    (`TInstr`/`TCode`/`TFn`) the emitter+drop consume; **the checker's typed IR
    (this element's `TalTy`/`Instr`/`Block`/`Term`/`TFn`/`Prog`) is separate**, tied
    to it by erasure (example §6d). `scaffold/lib/prelude.chiral` — `Maybe`/`List`/
    `Pair`/`Bool`, `=i <i <=i`; mutual-data (`E79`) for `Block↔Term↔Branch`.
- **True delta = two new library files.** The wins over `tal.py`: the instruction
  union becomes a coverage-checked `case` over `data Instr` (a new IR constructor
  with no rule is a **compile** error, not `tal.py`'s runtime "bad instruction"
  catch-all); the checker returns `CkR` (error path in the signature, not a raised
  `TalError`); the interpreter's ctypes buffers become an explicit threaded `Store`
  (replayable) and non-termination is tamed by a fuel measure (`r-oot`, not a hang),
  so the meaning function is total; both are `->` (Category A).

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls:
RESOLVED only when derivable from a settled source (cited); DEFERRED to a named
home; genuinely novel design → NEEDS-AUTHOR, surfaced never answered.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| a | Should fresh byte cells be **linear** (`bput`-before-read as a typed fact) rather than a convention? | **RESOLVED — no; scaffold-honest limit, not owed by E18** | The conformance-map row states it directly: "no typed-init on byte cells (authored lib only writes fresh) — **bounded hardening, not owed by E18**." The port reproduces `tal.py`'s discipline (write-before-read a convention; only fresh cells written). Linear typed-init is a future hardening toward Morrisett's typed-init flags, its own work. Derivable from the map row. |
| b | **Fuel source** — a refinement-bounded constant, or a budget granted through a port? | **RESOLVED — refinement-bounded I64 (matches the example)** | The reference interpreter is Category-A pure (`->`); its fuel is a `(refine I64 (>= 0))` constant that strictly decreases at each `i-call` — the totality measure, no port needed. A port-granted budget would make the *oracle* effectful, contradicting its Category-A purity. The refinement bound rides [[E09-refinement]]. Derivable from the `->` purity + E9. |
| c | How does the real **trusted drop** attest agreement with `tal-eval`? | **DEFERRED → floor-agreement + evidence** | This is the Category-B production drop agreeing with the Category-A oracle — the `floor-agreement` discipline (the drop is "first among executors," spec-as-golden per E71), attested by evidence hooks (sampling vs exhaustive on the golden set). Not E18's checker/interp port; homed to `docs/floor-agreement.md` + the evidence bridges ([[E55]]). |
| d | The **typed↔erased IR** relationship — two IRs, or annotate `tal-ir`? | **RESOLVED-in-direction — two IRs (typed-for-check + erased-for-run), erasure connects them** | `tal.py` *reads* annotations (does not infer), so a **typed** IR is required for the checker; `tal-ir.chiral` already exists as the **erased** executable IR — so the natural, faithful shape is two IRs joined by erasure (exactly what `tal.py` does with one tuple the interpreter's type-blind). Whether erasure is a separate pass or the annotations are added onto `tal-ir` is a downstream representation detail (residue). Derivable from `tal.py` + the existing `tal-ir`; not author-tier. |

All dispositioned; none blocking. `status: draft`.

## 4. Change plan (ordered, commit-sized)

### Step 1 — the typed checker IR + `TalTy`
- **Target:** `scaffold/lib/tal-check.chiral` (new) — `(import "prelude")`;
  `TalTy` (`tt-i64`/`tt-str`/`tt-bytes`/`tt-data`), the typed `Instr`,
  `Block`↔`Term`↔`Branch` (mutual, E79), `TFn`, `Prog`, `TalSig`, `REnv`, `CkR`.
- **Change:** the example §5 data block verbatim (load-verified: 7 defs, 18 data
  types). Registers are I64 indices; instructions carry `TalTy` (mirrors `tal.py`).
- **Size:** ~M

### Step 2 — `ck-instr` (the per-instruction rule table)
- **Target:** `tal-check.chiral` — `ck-instr` + helpers `renv-get`/`tal-ty=?`/
  `const-fits?`/`prim-sig`/`prog-sig`/`ck-app`/`ck-con`.
- **Change:** port `_check_block`'s per-op rules (`tal.py:125–201`): `const`
  range+type, `prim`/`call`/`con` annotation-equals-sig, `bnew/bget/bput/blen`
  byte floor; `case`-on-Bool (not value-`if`); errors → `ck-err`. Total.
- **Size:** ~L

### Step 3 — `ck-block`/`ck-term`/`ck-fn`/`ck-prog`
- **Target:** `tal-check.chiral` — the block/terminator/function/program spine.
- **Change:** port the `case` terminator (coverage-or-default, `tal.py:209–230`),
  `t-ret` vs declared return, `ck-fn` seeding Gamma from params, `ck-prog` folding
  `ck-fn`. Structural recursion (Block↔Term↔Branch) → total.
- **Size:** ~M

### Step 4 — the reference interpreter (`lib/tal-eval.chiral`)
- **Target:** `scaffold/lib/tal-eval.chiral` (new) — `Val`/`Store`/`RunR` +
  `tal-eval` (+ `eval-block`/`eval-instr`).
- **Change:** port `TalMachine._block` (`:270`) with an explicit threaded `Store`
  (a cell is an id, not an address; `bnew` appends zero-init, `bput` returns a new
  Store) and a strictly-decreasing **fuel** at each `i-call` → `r-oot` on exhaust
  (decision #b). Pure `->`. Sysface (`sys`/`bptr`) omitted (decision/§6).
- **Size:** ~L

### Step 5 — differential test file
- **Target:** `scaffold/tests/test_tal_chirality.py` (new; leave `test_tal.py` untouched).
- **Change:** load both chirality files, drive `ck-prog`/`tal-eval` with the `apply1`
  RT harness + a `TFn`/typed-IR adapter over `tal.py`'s tuples. Assert: `ck-*`
  accepts exactly what `check_fn` accepts and rejects with the same reason class
  (const-out-of-range, prim/call/con annotation-mismatch, non-exhaustive case,
  bad register type); `tal-eval` yields the same `Val` as `TalMachine` on the
  golden programs; and **no `ck-ok` program ever evaluates to `r-err`** (the
  operational soundness cross-check).
- **Size:** ~M

## 5. Conformance gate

- **Golden behavior:** `tal-check.chiral::ck-prog` accepts exactly the programs
  `tal.py:check_fn` accepts and returns `ck-err` with the same reason class on
  every reject (const range/type, `prim`/`call`/`con` annotation vs sig, arg
  arity/type, non-exhaustive `case`, `ret` vs declared); `tal-eval.chiral::tal-eval`
  reproduces `TalMachine`'s `Val` on the golden programs, with `r-oot` on fuel
  exhaustion and **no `ck-ok` program ever yielding `r-err`** (progress+preservation
  operationally). Byte cells are ids over a threaded `Store` (write-before-read a
  convention, decision #a); sysface omitted.
- **Floors compared:** the **chirality RT interpreter** running `tal-check.chiral`/
  `tal-eval.chiral` vs the **Python `tal.py` oracle** (`check_fn`/`TalMachine`), via
  a typed-IR adapter — lib-level chirality-vs-golden (`test_json.py` shape).
- **Green line:** 355 → ≥ 355 + k (the new `test_tal_chirality.py` functions); full
  suite stays green, `tal.py` unchanged, ledger-lint clean.
- **Done when:** `test_tal_chirality.py` passes — the chirality checker's verdicts match
  `check_fn` (accepts + reason classes), the chirality interpreter's values match
  `TalMachine`, and the ck-ok⇒never-r-err soundness cross-check holds.

## 6. Residue & links

- **Deliberately unbuilt:**
  - **Typed-init on byte cells** (linear `bput`-before-read) — decision #a; the
    map's "bounded hardening, not owed by E18" (toward Morrisett typed-init flags).
  - **The Category-B production drop + its attestation** of agreement with
    `tal-eval` — decision #c → `docs/floor-agreement.md` + evidence bridges [[E55]].
  - **The `sys`/`bptr` sysface rules** — the port/effect story ([[E51-sys-linkage]]
    / E76), not the pure floor.
  - **The erasure pass** connecting the typed checker IR to `tal-ir` (or annotating
    `tal-ir` instead) — decision #d, a representation detail.
  - Retiring `tal.py` and wiring these onto the toolchain — rides the checker self-host.
- **Follow-on:** **provides `check-fn` to [[E16-lowering]] and [[E17-optimizer]]**
  (their preserve-check / re-check — both scoped around this coupling); the tal
  floor half of the self-hosted compiler, paired with E19 (the x86-64 Mach drop).
- **Related:** [[E18-tal-check]] (rationale) · [[E16-lowering]]/[[E17-optimizer]]
  (consume `check-fn`) · [[E15-reference-interpreter]] (the upper twin — this is the
  lower-altitude reference interp) · [[E09-refinement]] (the fuel/index bounds,
  decision #b) · [[E24-i64-arith]]/[[E25-byte-cells]] (the I64/Bytes floor) ·
  `docs/floor-agreement.md` (the drop-agreement discipline, decision #c).
