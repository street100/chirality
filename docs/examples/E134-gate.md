---
element: E134
slug: gate
title: **The GATE / router (N2)** (Wave 2): the sparse-activation decision point — *which individual agents fire.* `run-gate : (-> (List GateRule) Str (List (Pair Str Str)) GateDecision)` folding condition predicates (`condition-fires`, `has-code-or-paths`, `has-spec`, `has-sibling-docs`, `has-examples`) over the input; pure `->` (the membrane **proves** the router never calls a model, so no hallucination can pick who fires), total (`else false` = don't fire), rules-first (keyword predicates; the worker-`decision` similarity path is later, ids-not-floats). `str-contains`/`str-downcase` are trivial pure defs over `str-find`. `scaffold/lib/manas/core/gate.chiral`
kind: BUILD
reference_class: OURS/SPEC/PAPER
ours_source: (none)
status: drafted
updated: 2026-08-15
---

# E134 — **The GATE / router (N2)** (Wave 2): the sparse-activation decision point — *which individual agents fire.* `run-gate : (-> (List GateRule) Str (List (Pair Str Str)) GateDecision)` folding condition predicates (`condition-fires`, `has-code-or-paths`, `has-spec`, `has-sibling-docs`, `has-examples`) over the input; pure `->` (the membrane **proves** the router never calls a model, so no hallucination can pick who fires), total (`else false` = don't fire), rules-first (keyword predicates; the worker-`decision` similarity path is later, ids-not-floats). `str-contains`/`str-downcase` are trivial pure defs over `str-find`. `scaffold/lib/manas/core/gate.chiral`

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E134, the GATE / router of the manas MoE orchestrator — the
  sparse-activation decision point that reads a document + its extra inputs and
  decides *which individual agents fire*. `run-gate` folds keyword-condition
  predicates over the input and returns a `GateDecision` (`gate-fired ids reason`
  | `gate-no-match reason`). Lands in `scaffold/lib/manas/core/gate.chiral`,
  Wave 2 of the METIS-PORT-SPEC build plan (§11).
- **Kind:** BUILD (a designed-but-unbuilt feature — nothing to shed, nothing to
  self-host; the current `coordinator` "route" is a stub returning the default
  model, and there is no `run-gate`/`condition-fires` in chirality yet, grep-clean).
- **Why chirality needs its own:** the gate is the point where a Mixture-of-Experts
  orchestrator commits to *who* runs. In the Python driver it is ~100 lines of
  keyword matching that *could* call a model to decide routing. chirality makes that
  structurally impossible: the arrow is `->` (empty effect row), so the membrane
  **proves** the router never crosses the backend seam — no hallucination can
  pick who fires. The decision is a pure function of the doc + rules, total
  (an unrecognized condition simply does not fire), and rules-first.

## 2. Research

- **Reference class:** OURS/SPEC/PAPER.
  - **SPEC** = `/workspace/manas/.planning/METIS-PORT-SPEC.md` §5 — the actual
    chirality code for `run-gate`, `condition-fires`, and the predicate helpers
    (`str-contains`, `str-downcase`, `has-code-or-paths`, `has-spec`,
    `has-sibling-docs`, `has-examples`), plus §1 (the `->` membrane proof that
    the GATE performs no backend call).
  - **OURS (the ground truth ruleset)** = `/workspace/manas/orchestration/processes.md`
    the `doc-refine` GATE block — the real conditions the gate evaluates:
    "cites code/paths? → claim-vs-source, anchor-sharpen"; "maps to a spec/reqs?
    → coverage-vs-spec"; "coupled to sibling docs? → cross-doc-drift"; "carries
    examples? → example-completeness, example-organization".
  - **PAPER** = gated MoE (Jacobs et al. 1991; Shazeer et al. 2017,
    arXiv:1701.06538) — sparse expert activation via a gating network. manas's
    GATE is rules-first (keyword predicates) rather than learned, but the
    sparse-activation model is the same.
- **Key findings (load-bearing):**
  1. **The GATE's arrow IS the safety property.** SPEC §1: "the GATE (`run-gate`)
     has type `->`. The membrane *proves* it performs no backend call. This
     matters because the GATE is the decision point — if the GATE could call a
     model, a hallucination could influence which experts fire. The type
     prevents that mechanically, not by convention." Every predicate and the fold
     are `->`; nothing touches `be-chat`.
  2. **The types are already built (E133).** `GateRule` (`gate-rule condition
     expert-ids`) and `GateDecision` (`gate-fired`/`gate-no-match`) live in
     `scaffold/lib/manas/core/types.chiral`. E134 imports them and adds ONLY the
     logic — no type redefinition.
  3. **"No match" is a normal outcome, not an error.** `gate-no-match` carries a
     reason string; the caller cases on the decision and always gets a value,
     never a bare `nil`, never a thrown exception (chirality has none). This is the
     boundary-sums directive: the decision is a closed sum at the boundary.
  4. **Total by construction.** `condition-fires` is a `cond` over recognized
     keyword predicates with `else false` — an unrecognized condition does not
     fire (sparse-by-default). The compiler proves there is no unhandled path.
  5. **`str-contains`/`str-downcase` are the only string primitives needed, both
     trivial over `str-find`.** `str-find` returns `-1` when absent
     (`string-utils.chiral:20`), so `str-contains h n = (<=i 0 (str-find h n))`.
     A full ASCII case-fold (`str-downcase`) needs single-byte reconstruction
     that the current Bytes externs (`bslice`/`bcat`/`brepeat`, no
     byte-from-int) do not give cheaply, so this element matches
     case-sensitively over authored (lowercase) condition keywords and checks
     the doc for the literal keyword — see §6 open questions.

## 3. Conventional (other-language) approach

The Python driver's gate is imperative keyword matching that both *could* call a
model and raises on the "nothing matched" path:

```python
def run_gate(rules, doc, extra_inputs):
    fired = []
    for cond, expert_ids in rules:
        c = cond.lower()                      # ambient case-fold
        if "code" in c and "path" in c:
            if _has_code_or_paths(doc):       # helper could, in principle,
                fired += expert_ids           #   call an embedding model
        elif "spec" in c or "req" in c:
            if "spec" in extra_inputs or "requirements" in extra_inputs:
                fired += expert_ids
        elif "sibling" in c:
            if "sibling_docs" in extra_inputs:
                fired += expert_ids
        elif "example" in c:
            if "example" in doc.lower():
                fired += expert_ids
    if not fired:
        raise NoRouteError("no gate conditions matched")   # control flow bypass
    return dedup(fired)
```

- **Assumptions it bakes in:** nothing stops a predicate from calling a model
  (routing could be steered by a hallucination); "no experts fired" is an
  exception that bypasses the return type (the caller can't see it in the
  signature); `fired` is a mutable accumulator; `dedup` order and the "no route"
  reason are implicit. chirality refuses all of it: the arrow is `->` (no backend
  call is even *expressible*), "no match" is a named variant carrying its reason,
  the fold is over an immutable list, and the recognized-condition set is a total
  `cond`.

## 4. The chirality idea

- **Chirality features in play:** the **effect membrane** (`->` = empty row — the
  load-bearing move: the GATE provably cannot cross the backend seam); **closed
  sums + `case` exhaustiveness** (`GateDecision` is the boundary sum; the caller
  must handle both `gate-fired` and `gate-no-match`); **totality** (`condition-
  fires` is a `cond` with `else false`, structural recursion in the fold — no
  unbounded loop, no partiality); the **boundary-sums directive** (a "no route"
  is a variant carrying a reason, never a raise or a nullable-without-reason);
  the **float→I64 wall** (this element carries no floats at all — the learned/
  similarity gate is later and crosses as ids, not floats).
- **The reframing:** the imperative accumulator-plus-raise becomes a pure fold.
  `run-gate` `filter`s the rules to those whose `condition-fires`, then either
  returns `gate-no-match` (empty) or `gate-fired` with the deduplicated union of
  the fired rules' expert-ids plus a human-readable reason built by `str-join`.
  Each predicate (`has-code-or-paths`, `has-spec`, `has-sibling-docs`,
  `has-examples`) is a pure `->` function over `Str` / `(List (Pair Str Str))`.
- **What chirality makes impossible here:** a predicate that calls a model (the
  arrow is `->`; any `=>` call is rejected at the application site); a route
  decision that fails silently or by exception (`gate-no-match` is a variant the
  caller must case on); a float sneaking into the decision (there is no float
  type and `GateDecision` has no float field); an unhandled condition (the `cond`
  is total — `else false`, sparse by default).

## 5. Chirality example (fleshed)

Imports `prelude` (str/bool/bytes prims) and the already-built `manas/core/types`
(`GateRule`, `GateDecision`) and `collections` (`filter`, `map-list`, `concat`,
`str-join`). Every arrow is `->`; there is no `=>` anywhere. `case` is exhaustive.

```chirality
; ================================================================ manas GATE / N2
; E134, Wave 2 (METIS-PORT-SPEC §5). The sparse-activation router: reads a doc +
; its extra inputs and decides WHICH agents fire. PURE (->) throughout — the
; membrane PROVES this function never crosses the backend seam, so no model call
; (and no hallucination) can steer routing. Total: an unrecognized condition does
; not fire (else false). No float anywhere. Types (GateRule/GateDecision) are
; E133 — imported, never redefined.

(import "prelude")             ; I64, Str, Bool, Pair, List, str-find, str-eq, <=i, and/or/not, cond
(import "collections")         ; filter, map-list, concat, str-join
(import "manas/core/types")    ; GateRule (gate-rule condition expert-ids), GateDecision

; ------------------------------------------------------------- string predicates
; does haystack contain needle? str-find returns -1 when absent (string-utils:20).
; Pure (->): a substring test is a byte scan, not a crossing. (SPEC §5.)
(def str-contains (-> Str Str Bool)
  (lam (haystack needle)
    (<=i 0 (str-find haystack needle))))

; is key present in the extra-inputs alist? Pure linear scan; str-eq compares keys.
(def has-key (-> (List (Pair Str Str)) Str Bool)
  (lam (extra k)
    (case extra
      (nil false)
      ((cons h t)
        (case h
          ((pair hk hv)
            (cond ((str-eq hk k) true)
                  (else (has-key t k)))))))))

; ------------------------------------------------------- the four gate predicates
; NOTE (case-fold): a full ASCII str-downcase needs single-byte reconstruction the
; current Bytes externs don't give cheaply, so matching is CASE-SENSITIVE over
; authored (lowercase) condition keywords; the doc checks probe literal keywords
; (has-examples probes "example" and "Example"). See §6. (SPEC §5, adapted.)

; cites code or paths? — a fenced block or a path-like "/" token.
(def has-code-or-paths (-> Str Bool)
  (lam (doc)
    (or (str-contains doc "```")
        (str-contains doc "/"))))

; maps to a spec / requirements? — extra inputs carry a spec or requirements key.
(def has-spec (-> (List (Pair Str Str)) Bool)
  (lam (extra)
    (or (has-key extra "spec")
        (has-key extra "requirements"))))

; coupled to sibling docs? — extra inputs carry a sibling_docs key.
(def has-sibling-docs (-> (List (Pair Str Str)) Bool)
  (lam (extra)
    (has-key extra "sibling_docs")))

; carries examples? — the doc mentions "example" (either common case).
(def has-examples (-> Str Bool)
  (lam (doc)
    (or (str-contains doc "example")
        (str-contains doc "Example"))))

; --------------------------------------------------------------- the evaluator
; condition-fires: does ONE rule's condition apply to this input? Pure. TOTAL —
; every recognized keyword maps to a predicate; an unrecognized condition hits
; `else false` (sparse-by-default). Keywords match the doc-refine GATE block
; (processes.md): code/paths, spec/reqs, siblings, examples.
(def condition-fires (-> Str Str (List (Pair Str Str)) Bool)
  (lam (condition doc extra)
    (cond
      ((or (str-contains condition "code") (str-contains condition "path"))
       (has-code-or-paths doc))
      ((or (str-contains condition "spec") (str-contains condition "req"))
       (has-spec extra))
      ((str-contains condition "sibling")
       (has-sibling-docs extra))
      ((str-contains condition "example")
       (has-examples doc))
      (else false))))

; ------------------------------------------------------------ dedup (first-wins)
; membership over a (List Str), and a first-occurrence-preserving dedup so a
; union of fired rules' ids has no repeats. Structural recursion, O(n^2), fine.
(def elem-str (-> Str (List Str) Bool)
  (lam (x xs)
    (case xs
      (nil false)
      ((cons h t)
        (cond ((str-eq h x) true)
              (else (elem-str x t)))))))

(declare dedup-go (-> (List Str) (List Str) (List Str)))
(def dedup-go
  (lam (seen xs)
    (case xs
      (nil nil)
      ((cons h t)
        (cond ((elem-str h seen) (dedup-go seen t))
              (else (cons h (dedup-go (cons h seen) t))))))))

(def dedup-str (-> (List Str) (List Str))
  (lam (xs) (dedup-go nil xs)))

; ----------------------------------------------------------------- the GATE proper
; run-gate: fold conditions over the input, return the fired experts + a reason,
; or gate-no-match. Pure (->). Total. The membrane PROVES no backend call.
; (SPEC §5.)
(def run-gate (-> (List GateRule) Str (List (Pair Str Str)) GateDecision)
  (lam (rules doc extra)
    (let ((fired-rules
            (filter GateRule
              (lam (r)
                (case r
                  ((gate-rule c ids) (condition-fires c doc extra))))
              rules)))
      (case fired-rules
        (nil (gate-no-match "no gate conditions matched; no experts fired"))
        ((cons _ _)
          (let ((ids (dedup-str
                       (concat Str
                         (map-list GateRule (List Str)
                           (lam (r) (case r ((gate-rule c ids) ids)))
                           fired-rules))))
                (reason (str-join "; "
                          (map-list GateRule Str
                            (lam (r)
                              (case r
                                ((gate-rule c ids)
                                  (str-cat c (str-cat " -> " (str-join ", " ids))))))
                            fired-rules))))
            (gate-fired ids reason)))))))
```

- **Knobs to modify:** the keyword→predicate map in `condition-fires` (add a new
  keyword branch to route a new agent class); the predicate bodies (e.g. a
  sharper path regex than the crude `"/"`); the reason format; whether dedup keeps
  first or last occurrence. A learned/similarity gate is a *different* function
  that would still return the same `GateDecision` (ids, not floats) — a later
  element.
- **Deliberately omitted:** the effectful worker calls (`call-expert`,
  `call-combiner` — Wave 3, `=>`); a full ASCII `str-downcase` (case-sensitive
  authored keywords suffice here — §6); the learned similarity gate; the pipeline
  *selection* step (`match-pipeline`, E136 — the gate runs *inside* a chosen
  pipeline).

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/manas/core/gate.chiral` (NEW — Wave 2). Imports
  `prelude`, `collections`, and `manas/core/types` (E133). No `ports`, no
  `backend`, no crossing — the whole file is `->`.
- **Conformance target:** reproduce the `doc-refine` GATE block
  (`orchestration/processes.md`): a doc that cites code/paths fires
  `claim-vs-source` + `anchor-sharpen`; one that maps to a spec/reqs fires
  `coverage-vs-spec`; one coupled to siblings fires `cross-doc-drift`; one
  carrying examples fires `example-completeness` + `example-organization`; a
  plain-prose doc with none of these returns `gate-no-match`. The behavioral test
  (§ implementation) builds this exact ruleset and asserts both a fired case
  (code+path+spec → the three ids) and the no-match case.
- **Open questions:**
  1. **`str-downcase` vs case-sensitive keywords.** TAKEN: case-sensitive over
     authored (lowercase) condition strings, with `has-examples` probing both
     `"example"` and `"Example"`. Sound because the `GateRule` conditions are
     values WE author (not user input), so their case is controlled. A real
     ASCII `str-downcase` is deferred until a single-byte-from-int Bytes op
     exists (or a 26-entry lookup is deemed worth it) — a knob, not a blocker.
     Deviates from METIS-PORT-SPEC §5 (which called `str-downcase`); noted.
  2. **Path detection crudeness.** `has-code-or-paths` uses `"```"` OR `"/"` — the
     same "crude, same spirit as Python regex" the spec notes. A sharper token
     scan is a predicate-body knob.
  3. **`Finding` RETURNS schema (deferred here from E133 §6 Q2).** The gate only
     decides *who* fires; the granular finding shape those agents RETURN is owned
     by the expert-call element (Wave 3), not E134.
- **Related:** [[E134-gate]] · [[E133-manas-core-types]] (`GateRule`/`GateDecision`
  — imported) · [[E135-bind]] (`bind-config` resolves the fired experts' slots) ·
  [[E136-match]] (`match-pipeline` selects the pipeline the gate runs inside).
