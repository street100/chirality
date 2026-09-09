---
element: E136
slug: match-assemble-stop
title: **Match + assemble + stop** (Wave 2, the pure-core remainder): `match-pipeline : (-> Str (List Pipeline) PipelineMatch)` (WHEN keyword overlap → `match-found`/`match-none`/`match-tied`); `assemble-prompt` (an agent's SEES cut + hits → prompt Str); `overflow-guard` (chars/4 vs `num_ctx`, pure arithmetic); `stop-policy : (-> Str I64 Bool)` (single / capped-N / loop-until-dry, swappable per pipeline — no magic constant). All pure `->`, unit-testable without a PTY or a backend. `scaffold/lib/manas/core/{match,assemble,stop}.chiral`
kind: BUILD
reference_class: OURS/SPEC
ours_source: (none)
status: drafted
updated: 2026-08-15
---

# E136 — Match + assemble + stop (the pure-core remainder)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E136 — the last three pure (`->`) functions of the manas MoE
  engine's core: `match-pipeline` (route a request to a pipeline by WHEN-text
  keyword overlap), `assemble-prompt` (build one agent's prompt string), and the
  stop pair `overflow-guard` + `stop-policy` (fit-check + loop control). None
  touch a backend, a PTY, or a model — they are the engine's decision arithmetic.
- **Kind:** BUILD (design from the spec; no OURS Python to port line-for-line —
  the Python driver's logic is sketched in METIS-PORT-SPEC §5/§7).
- **Why chirality needs its own:** these are the leaves the effectful pipeline
  (`call-expert`, the runner) sits on. Keeping them pure and total means the
  membrane *proves* routing/assembly/stop cannot call a model — a hallucination
  can never steer which pipeline runs or when the loop ends. They must be leaf
  modules with **no** backend/http import, so E136 takes the retrieved context as
  `(List Str)` (already-extracted content), not `(List Hit)`.

## 2. Research

- **Reference class:** OURS/SPEC — `/workspace/manas/.planning/METIS-PORT-SPEC.md`
  §1 (the pure signatures), §3.1 (`PipelineMatch` variants), §5 (`str-contains`),
  §7 (the `stop-policy` code + cap-of-3); `/workspace/manas/orchestration/processes.md`
  (the pipelines' real WHEN texts).
- **Key findings:**
  - `stop-policy` (SPEC §7) is `str-contains expert-id "sharpen"/"example"` →
    `(<i iteration 3)`, else `false`. The cap is *in the function*, not a magic
    constant — a different pipeline supplies a different policy (`stop-quick`,
    `stop-deep`). 1-indexed iteration.
  - `overflow-guard` (SPEC §1) is the chars/4 token estimate vs `num_ctx`, pure
    integer arithmetic — same as the Python driver, no float crosses the seam.
  - `match-pipeline` (SPEC §1/§3.1) scores the request against each pipeline's
    WHEN text; the three-variant `PipelineMatch` (found / none / tied) already
    exists in `types.chiral` (E133). The concrete scoring rule is *ours to choose*
    (SPEC leaves it as `(Maybe Pipeline)` sketch) — a pure keyword-overlap count.
  - The WHEN texts are literal strings in processes.md: doc-refine = "a doc must
    be checked against reality, sharpened, and its examples completed/organized";
    research = "a topic must be researched with cited sources".

## 3. Conventional (other-language) approach

A conventional (Python) router: an exception for a no-match, a float cosine
similarity for the route, `len(prompt)//4` guessed against a config int, and a
substring test on the expert id with a hard-coded `3`.

```python
def match_pipeline(request, pipelines):
    scored = [(p, similarity(request, p.when)) for p in pipelines]   # float!
    best = max(scored, key=lambda t: t[1])
    if best[1] == 0: raise PipelineMatchError(listing(pipelines))    # exception
    return best[0]

def overflow_guard(prompt, num_ctx): return len(prompt)//4 >= num_ctx
def stop_policy(expert_id, i):
    return i < 3 if ("sharpen" in expert_id or "example" in expert_id) else False
```

- **Assumptions it bakes in:** a **float** similarity crossing the seam; a
  **raised exception** for no-match (untyped control flow that bypasses the return
  type); a **tie** silently resolved by `max` picking the first; the retrieved
  context arriving as rich `Hit` objects that drag in the backend module.

## 4. The chirality idea

- **Chirality features in play:** the effect membrane (`->` proves no crossing), the
  float→I64 wall (scoring is an **integer** overlap count, never a cosine), errors
  as values (the closed `PipelineMatch` sum — found/none/**tied**, no exception),
  totality (structural folds, no unbounded loop), and leaf-module discipline
  (context as `(List Str)`, so no backend/http import leaks in).
- **The reframing:** the route is a pure keyword-overlap **count**, not a learned
  score; a no-match and a tie are *variants the caller cases on*, not an exception
  and not a silent first-wins. The stop cap lives inside the swappable policy.
- **What chirality makes impossible here:** returning a float (no float type); throwing
  (no exceptions — `match-none`/`match-tied` carry the listing); calling a model
  from the router (`->` membrane rejects any `=>`); a non-exhaustive route (the
  `case` over `PipelineMatch` must cover all three).

## 5. Chirality example (fleshed)

```chirality
; ---- match.chiral : route a request to a pipeline by WHEN keyword overlap ----
(import "prelude")            ; str-len, str-find, str-sub, <=i, <i, =i, +, cond/else
(import "collections")        ; foldl, filter, append
(import "prapanca/core/types")   ; Pipeline, PipelineMatch (match-found/none/tied)

; str-contains COPIED from gate.chiral (E134): (str-contains haystack needle) —
; does haystack contain needle? Not imported from string-utils (its arg order is
; the reverse (needle s), and importing it would double-define the name in a leaf
; blob). A byte scan, pure (->).
(def str-contains (-> Str Str Bool)
  (lam (haystack needle) (<=i 0 (str-find haystack needle))))

(def pipeline-id   (-> Pipeline Str)
  (lam (p) (case p ((pipeline id whn g o eids cmb stp yd) id))))
(def pipeline-when (-> Pipeline Str)
  (lam (p) (case p ((pipeline id whn g o eids cmb stp yd) whn))))
(def imax (-> I64 I64 I64) (lam (a b) (cond ((<i a b) b) (else a))))

; significant request words: split on space, keep length >= 4 (drop a/is/to/it).
; split is a local structural recursion on the shrinking suffix (str-split is not
; imported — string-utils would drag in its reverse-order str-contains).
(declare split-go (-> Str Str (List Str)))
(def split-go
  (lam (sep s)
    (let ((i (str-find s sep)))
      (cond ((<i i 0) (cons s nil))
            (else (cons (str-sub s 0 i)
                        (split-go sep (str-sub s (+ i (str-len sep)) (str-len s)))))))))
(def sig-words (-> Str (List Str))
  (lam (req) (filter Str (lam (w) (<=i 4 (str-len w))) (split-go " " req))))

; overlap COUNT: how many significant words occur in this WHEN text (integer).
; str-contains whn w = does the WHEN text contain this request word.
(def count-hits (-> (List Str) Str I64)
  (lam (words whn)
    (foldl Str I64
      (lam (acc w) (cond ((str-contains whn w) (+ acc 1)) (else acc)))
      0 words)))

; id->when listing (foldl+append; map-list does NOT lower in a leaf blob).
(def listing-of (-> (List Pipeline) (List (Pair Str Str)))
  (lam (pipes)
    (foldl Pipeline (List (Pair Str Str))
      (lam (acc p) (append (Pair Str Str) acc
                     (cons (pair (pipeline-id p) (pipeline-when p)) nil)))
      nil pipes)))

(def ids-of (-> (List Pipeline) (List Str))
  (lam (pipes)
    (foldl Pipeline (List Str)
      (lam (acc p) (append Str acc (cons (pipeline-id p) nil)))
      nil pipes)))

; highest count wins -> match-found; all-zero -> match-none; tie at top -> match-tied.
(def match-pipeline (-> Str (List Pipeline) PipelineMatch)
  (lam (req pipes)
    (let ((words   (sig-words req))
          (listing (listing-of pipes)))
      (let ((best (foldl Pipeline I64
                    (lam (acc p) (imax acc (count-hits words (pipeline-when p))))
                    0 pipes)))
        (cond
          ((=i best 0) (match-none listing))
          (else
            (let ((winners (filter Pipeline
                             (lam (p) (=i (count-hits words (pipeline-when p)) best))
                             pipes)))
              (case winners
                (nil (match-none listing))                 ; total; unreachable
                ((cons w rest)
                  (case rest
                    (nil          (match-found w (pipeline-when w)))
                    ((cons a b)   (match-tied (ids-of winners) listing))))))))))))

; ---- assemble.chiral : build one agent's prompt (pure string building) ----
; context is (List Str) — already-extracted content lines, NOT (List Hit): keeps
; this a pure leaf, free of the backend/http import.
(def pair-line (-> (Pair Str Str) Str)
  (lam (p) (case p ((pair k v) (str-cat k (str-cat ": " v))))))

(def render-extra (-> (List (Pair Str Str)) Str)
  (lam (extra)
    (str-join "\n"
      (foldl (Pair Str Str) (List Str)
        (lam (acc p) (append Str acc (cons (pair-line p) nil)))
        nil extra))))

(def assemble-prompt (-> Expert Str (List (Pair Str Str)) (List Str) Str)
  (lam (ex doc extra ctx)
    (case ex
      ((expert id lens sees returns slot tools)
        (str-cat (str-cat "# Lens\n"    (str-cat lens "\n\n"))
        (str-cat (str-cat "# You see\n" (str-cat sees "\n\n"))
        (str-cat (str-cat "# Document\n"(str-cat doc  "\n\n"))
        (str-cat (str-cat "# Extra\n"   (str-cat (render-extra extra) "\n\n"))
        (str-cat (str-cat "# Context\n" (str-cat (str-join "\n" ctx) "\n\n"))
                 (str-cat "# Return\n" returns))))))))))

; ---- stop.chiral : fit-check + loop control (pure arithmetic/string) ----
; str-contains COPIED from gate.chiral (E134), named str-has here so match.chiral's
; own copy and this one do not collide as duplicate defs in a combined leaf blob.
(def str-has (-> Str Str Bool)
  (lam (haystack needle) (<=i 0 (str-find haystack needle))))

; chars/4 token estimate >= num_ctx  => would overflow.
(def overflow-guard (-> Str I64 Bool)
  (lam (prompt num-ctx) (<=i num-ctx (/ (str-len prompt) 4))))

; sharpen/example experts loop-until-dry, capped at 3; everything else single-pass.
; str-has expert-id "sharpen" = does the expert id contain "sharpen" (SPEC §7).
(def stop-policy (-> Str I64 Bool)
  (lam (expert-id iteration)
    (cond
      ((or (str-has expert-id "sharpen") (str-has expert-id "example"))
       (<i iteration 3))
      (else false))))
```

- **Knobs to modify:** the significance threshold (`>= 4`) and the split
  separator in `sig-words`; the token divisor (`/ 4`) and the cap (`3`) — a
  `stop-deep` swaps `(<i iteration 5)`; the prompt section layout in
  `assemble-prompt`.
- **Deliberately omitted:** the worker-`decision` similarity path (a later,
  richer route than keyword overlap); ASCII case-folding (matching is
  case-sensitive over authored keywords, as in E134); the `Hit`→content
  extraction (upstream, in the effectful retrieve step).

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/manas/core/match.chiral`,
  `scaffold/lib/manas/core/assemble.chiral`, `scaffold/lib/manas/core/stop.chiral`.
- **Conformance target:** the WHEN texts of processes.md route correctly
  ("refine … against reality and sharpen it" → doc-refine; gibberish →
  match-none); `stop-policy` reproduces the Python cap-of-3 (§7);
  `overflow-guard` reproduces `len//4 >= num_ctx` (§1). Purity is structural (the
  `->` arrow is compiler-checked).
- **Open questions:** the exact overlap rule (threshold, stop-words) — a first-cut
  heuristic to be settled in the SPEC; whether `match-tied` should further
  tie-break (deferred — the caller decides).
- **Related:** [[E136-match-assemble-stop]] · [[E133-manas-core-types]]
  (`Pipeline`/`PipelineMatch`/`Expert` — imported) · [[E134-gate]] (`run-gate`
  decides *who* fires; match decides *which pipeline*) · [[E135-bind]] (binds the
  fired slots) · [[E138-runner]] (calls all three).
