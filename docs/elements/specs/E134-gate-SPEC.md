---
element: E134
slug: gate
title: **The GATE / router (N2)** (Wave 2): the sparse-activation decision point — *which individual agents fire.* `run-gate : (-> (List GateRule) Str (List (Pair Str Str)) GateDecision)` folding condition predicates (`condition-fires`, `has-code-or-paths`, `has-spec`, `has-sibling-docs`, `has-examples`) over the input; pure `->` (the membrane **proves** the router never calls a model, so no hallucination can pick who fires), total (`else false` = don't fire), rules-first (keyword predicates; the worker-`decision` similarity path is later, ids-not-floats). `str-contains`/`str-downcase` are trivial pure defs over `str-find`. `scaffold/lib/manas/core/gate.chiral`
kind: BUILD
example: examples/E134-gate.md
status: audited
updated: 2026-08-15
---

# E134 SPEC — **The GATE / router (N2)** (Wave 2): the sparse-activation decision point — *which individual agents fire.* `run-gate : (-> (List GateRule) Str (List (Pair Str Str)) GateDecision)` folding condition predicates (`condition-fires`, `has-code-or-paths`, `has-spec`, `has-sibling-docs`, `has-examples`) over the input; pure `->` (the membrane **proves** the router never calls a model, so no hallucination can pick who fires), total (`else false` = don't fire), rules-first (keyword predicates; the worker-`decision` similarity path is later, ids-not-floats). `str-contains`/`str-downcase` are trivial pure defs over `str-find`. `scaffold/lib/manas/core/gate.chiral`

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `scaffold/lib/manas/core/gate.chiral` exists — a pure (`->`)
  module that imports `prelude`, `collections`, and `manas/core/types` (E133) and
  defines `str-contains`, `has-key`, the four gate predicates (`has-code-or-paths`,
  `has-spec`, `has-sibling-docs`, `has-examples`), `condition-fires`, the
  first-wins `dedup-str` (`elem-str` + `dedup-go`), and `run-gate :
  (-> (List GateRule) Str (List (Pair Str Str)) GateDecision)`. It compiles clean
  under B1 when pulled into a blob, and a behavioral entry program builds the
  `doc-refine` ruleset and exercises both a `gate-fired` case (code+path+spec →
  ids include `claim-vs-source`, `anchor-sharpen`, `coverage-vs-spec`) and a
  `gate-no-match` case (plain prose), printing PASS/FAIL and exiting 0 on all-pass.
- **Non-goals:** the effectful worker calls (`call-expert`/`call-combiner`, Wave 3,
  `=>`); a real ASCII `str-downcase` (case-sensitive authored keywords instead —
  decision #1); pipeline *selection* (`match-pipeline`, E136); the learned/
  similarity gate (later, crosses as ids not floats); the granular `Finding`
  RETURNS schema (Wave 3). Those live in §6.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E134 postdates the map snapshot (bundle §3
  confirms). Treat as **BUILD** (forward construction; nothing to reshape).
- **Live code it composes with:**
  - `prelude` — `str-find` (`extern (-> Str Str I64)`, returns `-1` when absent),
    `str-eq`, `str-cat`, `<=i`, `and`/`or`/`not`, `cond`/`else`, `Pair`
    (`pair`/`fst`/`snd`), `List` (`cons`/`nil`), `Bool` (`true`/`false`).
  - `collections` — `filter (-> (0 A) (-> A Bool) (List A) (List A))`,
    `map-list (-> (0 A) (0 B) (-> A B) (List A) (List B))`,
    `concat (-> (0 A) (List (List A)) (List A))`,
    `str-join (-> Str (List Str) Str)`.
  - `manas/core/types` (E133) — `GateRule` (`(gate-rule (condition Str)
    (expert-ids (List Str)))`) and `GateDecision` (`(gate-fired (expert-ids
    (List Str)) (reason Str))` / `(gate-no-match (reason Str))`). Imported, NOT
    redefined.
- **True delta:** one new file, ~10 pure `def`s (+1 `declare` for the recursive
  `dedup-go`), zero change to any existing file. `string-utils.chiral` already has
  a `str-contains` but with `(needle s)` arg order and behind an `str-downcase`-less
  design; E134 defines its own `str-contains (haystack needle)` locally (per the
  element brief and METIS-PORT-SPEC §5) rather than importing `string-utils`, to
  keep the module self-contained and avoid a redefinition clash.

## 3. Decisions

Every open question from the example §6, dispositioned. RESOLVED only when
derivable from a settled doc / the element brief; genuinely novel design → NEEDS-AUTHOR.

| # | Question (example §6) | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | `str-downcase` (a real ASCII case-fold, per METIS-PORT-SPEC §5) vs case-sensitive matching over authored keywords | **RESOLVED — case-sensitive** | The element brief explicitly sanctions it ("str-downcase = ASCII a-z→A-Z byte shift, OR match case-sensitively if simpler and note it"). Sound: `GateRule` conditions are values WE author (not user input), so their case is controlled; `has-examples` probes both `"example"` and `"Example"`. A real `str-downcase` needs a single-byte-from-int Bytes op the prelude does not give (only `bslice`/`bcat`/`brepeat`); deferred as a knob (§6). Documented deviation from §5. |
| 2 | Path-detection crudeness (`"```"` OR `"/"`) | **RESOLVED — keep crude** | METIS-PORT-SPEC §5 itself uses this ("crude, same spirit as Python regex"). A sharper token scan is a predicate-body knob, not load-bearing for the gate contract. |
| 3 | `Finding` granular RETURNS schema (deferred to E134 by E133 §6 Q2 / E133-SPEC decision #2) | **DEFERRED → Wave 3 (expert-call)** | The gate decides only *who* fires (returns expert-ids); the shape those agents RETURN is produced by `call-expert` (Wave 3, `=>`), not by E134. E133's provisional `(kind target body)` stands until then. Named home exists (Wave 3, METIS-PORT-SPEC §11); not a phantom defer. |
| 4 | Which combinator builds the fired-id union + reason (`map-list`/`concat` per METIS-PORT-SPEC §5) | **RESOLVED — `foldl`+`append`** | Found at BUILD: on this branch (e106) `map-list` does not lower in an isolated blob (B1 skips its label → `no emitted label for entry compile-main`), while `foldl`/`filter`/`append` lower and run. Semantically identical (a left fold over the fired rules accumulating a `(List Str)`), so the gate contract is unchanged; only the internal combinator differs. Documented in `gate.chiral`. A compiler-side follow-on (map-list monomorphization in a leaf blob) is a separate concern, not E134. |

No NEEDS-AUTHOR blocks §4 — all four resolve from the element brief / settled specs / a build-time compiler finding.

## 4. Change plan (ordered, commit-sized)

### Step 1 — write `scaffold/lib/manas/core/gate.chiral`
- **Target:** `scaffold/lib/manas/core/gate.chiral` (NEW; the `manas/core/` path
  already exists from E133).
- **Change:** the example §5 snippet essentially verbatim —
  `(import "prelude")` / `(import "collections")` / `(import "manas/core/types")`,
  then:
  1. `str-contains (-> Str Str Bool)` = `(<=i 0 (str-find haystack needle))`.
  2. `has-key (-> (List (Pair Str Str)) Str Bool)` — linear `str-eq` scan.
  3. the four predicates `has-code-or-paths`, `has-spec`, `has-sibling-docs`,
     `has-examples` (all `->`).
  4. `condition-fires (-> Str Str (List (Pair Str Str)) Bool)` — a total `cond`
     (code/path → `has-code-or-paths`; spec/req → `has-spec`; sibling →
     `has-sibling-docs`; example → `has-examples`; `else false`).
  5. `elem-str` + `(declare dedup-go …)` + `dedup-go` + `dedup-str` — first-wins dedup.
  6. `run-gate (-> (List GateRule) Str (List (Pair Str Str)) GateDecision)` —
     `filter` the rules by `condition-fires`, then `gate-no-match` (empty) or
     `gate-fired` with a `dedup-str`'d id union + a `str-join`ed reason, both
     accumulated by `foldl`+`append` (see decision #4 — `map-list`/`concat` do
     not lower in a leaf blob on this branch).
  Every arrow `->`; no `=>`; every `case` exhaustive; no float.
- **Size:** ~S. One commit (with the test entry, Step 2).

### Step 2 — the behavioral test entry
- **Target:** `scaffold/tests/samples/e134_gate.chiral` (kept, per the brief, so it
  can become the E141-era test).
- **Change:** `(import "manas/core/gate")` + `(import "ports")` (for `print`) +
  a local `mem (-> Str (List Str) Bool)`, and `(def compile-main (=> I64 I64) …)`
  that builds the four-rule `doc-refine` ruleset as a `(List GateRule)` and asserts:
  - **case a** — doc with a fenced block + a `foo/bar` path, extra-inputs
    `[("spec", …)]` → `gate-fired` with ids ⊇ {`claim-vs-source`, `anchor-sharpen`,
    `coverage-vs-spec`}. `print` PASS/FAIL.
  - **case b** — plain-prose doc, empty extra-inputs → `gate-no-match`. `print`
    PASS/FAIL.
  Exit `0` iff both pass, else `1`.
- **Size:** ~S.

## 5. Conformance gate

- **Golden behavior:** reproduce the `doc-refine` GATE block
  (`/workspace/manas/orchestration/processes.md`): cites-code/paths →
  `claim-vs-source` + `anchor-sharpen`; maps-to-spec/reqs → `coverage-vs-spec`;
  coupled-to-siblings → `cross-doc-drift`; carries-examples → `example-completeness`
  + `example-organization`; none-of-these → `gate-no-match`. The purity property
  is structural (the `->` arrow is checked by the compiler — a `=>` call in the
  gate would not type).
- **Tests to add:** `scaffold/tests/samples/e134_gate.chiral` — the `compile-main`
  entry above, driven through `resolve → B1 → run` (native floor). Two asserted
  cases (fired + no-match), process exit `0` on all-pass. This is the behavioral
  test; it becomes an E141-era harness case.
- **Green line:** 709 → 709 python test-functions (the new gate test is a native
  sample driven by the B1/resolve recipe, not a pytest); ledger-lint's
  pre-existing fails unchanged.
- **Done when:** a blob importing `manas/core/gate` compiles under B1 to a running
  ELF, and `e134_gate.chiral` runs to exit `0` with both PASS lines printed.

## 6. Residue & links

- **Deliberately unbuilt:** real ASCII `str-downcase` → knob, gated on a
  single-byte-from-int Bytes op (nobody's yet — a prelude extension, not a minted
  E#); effectful worker calls `call-expert`/`call-combiner` → **Wave 3**
  (METIS-PORT-SPEC §11); pipeline selection `match-pipeline` → **E136**; learned/
  similarity gate → later element (ids-not-floats); granular `Finding` schema →
  **Wave 3**.
- **Follow-on this unblocks:** E135 (`bind-config` resolves the fired experts'
  slots against a `Config`), E136 (`match-pipeline` selects the pipeline the gate
  runs inside), the Wave-3 runner (which calls `run-gate` then fires the experts).
- **Related:** [[E134-gate]] · [[E133-manas-core-types]] (`GateRule`/`GateDecision`
  — imported) · [[E135-bind]] · [[E136-match]].
