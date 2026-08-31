---
element: E71
slug: golden-restructure
title: Golden-semantics restructure: what floor agreement means once the Python reference executor is evicted — a chirality reference executor, or the spec as the golden object with the reference demoted to first-among-executors
kind: BUILD-PROPER
reference_class: OURS
ours_source: docs/floor-agreement.md (the note this restructures)
status: drafted
updated: 2026-07-22
---

# E71 — Golden-semantics restructure: who is "the reference" after the Python golden is evicted

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.
> **This is a DECISION-shaped element:** the example lays the fork out faithfully
> and marks its recommendation as a recommendation — the call is the author's.

## 1. Scope

- **Element:** E71, the restructure of `floor-agreement.md`'s trust anchor.
  Today the Python `TalMachine` *is* the definitional semantics ("a floor that
  disagrees with it is wrong by definition"). Self-hosting evicts every Python
  artifact from the trusted path — so the sentence loses its subject, and
  something else must be the thing a floor is wrong *against*.
- **Kind:** BUILD-PROPER (a decision note plus one artifact; no port).
- **Why chirality needs its own:** the golden object is the root of floor
  agreement, floor agreement is the admission rule for every executor and every
  new tal instruction, and both the fixpoint (Stage1==Stage2) and the E72
  re-bootstrap requirement need the semantics pinned in something that survives
  the death of any particular executor.

## 2. Research

- **Reference class:** OURS — `docs/floor-agreement.md`, plus the forcing
  inputs this session pinned: `certificate-discipline`, D7 (edge 11),
  E72 (`SELF-HOST-PLAN.md` ownership requirements), the fixpoint determinism
  debts (`trust-boundary`).
- **Key findings:**
  1. The golden is currently *definitional in an implementation*: reference
     interpreter = semantics. The collapse/validate/fuzz mechanism gradient and
     the differential harness do not depend on that choice — they survive
     either branch unchanged; only the *anchor* moves.
  2. chirality already made this call once, in miniature: division. The reference
     was not trusted to define `/` — it was **pinned to an external spec**
     (SMT-LIB's Euclidean `div`/`mod`) precisely so a solver-discharged
     refinement means at runtime exactly what it proved. The precedent is
     spec-first, and it is load-bearing in the refinement path today.
  3. Certificate discipline wants a **fixed demanded statement at the socket**:
     "agrees with the spec on these observables" is a demanded statement;
     "agrees with whatever the reference computes" is a moving one.
  4. The fixpoint's determinism debts (iteration order, encoding) must be
     pinned *somewhere*; an executor pins them by accident, a spec pins them on
     purpose.
  5. D7's honest tier: floor agreement is testing-grade. Two chirality executors
     cross-checking each other share provenance (residuals of one toolchain);
     their agreement is exactly the correlated-agreement theater edge 11 warns
     about.

## 3. Conventional (other-language) approach

Reference-implementation-as-spec — the CPython model. The semantics is whatever
the canonical implementation does; other implementations chase it.

```python
# "What does dict preserve insertion order across deletion?" — CPython model:
# run it and see. The behavior IS the spec; a divergent PyPy is wrong even if
# the divergence was a CPython accident (and CPython accidents have become
# language law this way — dict ordering itself was one, ratified post hoc).
def semantics_of(op, state):
    return canonical_impl.run(op, state)   # the golden is a program
```

- **Assumptions it bakes in:** the implementation's bugs are indistinguishable
  from semantics (an accident, observed, becomes law); the anchor dies with its
  runtime (no CPython, no answer); re-implementation requires archaeology of a
  codebase, not a read of a document; and the "spec" silently evolves with
  every release — the demanded statement is a moving target, which is exactly
  what certificate discipline forbids the socket to be. The alternative
  lineage — RISC-V, SMT-LIB — writes the spec first and demotes every
  implementation to a conformance candidate; chirality's division pin already chose
  that lineage once.

## 4. The chirality idea

- **Chirality features in play:** categories (the spec is the demanded statement —
  the audited A-artifact; executors are producers), certificate discipline
  (validate against a fixed statement, never spot-check against a peer),
  split-role (executor cross-checks remain the agreement-tier mechanism for
  the unprovable residue), totality (spec semantic functions are total, pure),
  the E72 ownership requirement.
- **The fork, faithfully:**
  - **(a) Reference-executor-as-golden (the E15 port inherits the crown).**
    The chirality reference interpreter becomes the definitional semantics.
    Cheapest continuation of today's text — one sentence changes. But the
    anchor is then a chirality program checked by the chirality checker it anchors
    (a soft circularity the current Python golden does not have), two chirality
    floors agreeing share provenance (D7's correlated-agreement problem
    moves *into* the trust root), and E72's weekend-reimplementer must read
    a codebase to learn the semantics.
  - **(b) Spec-as-golden.** A small tal-semantics artifact — per-instruction
    transition semantics plus pinned observables and test vectors — becomes
    the golden object. Every executor, *including* the reference, demotes to
    first-among-producers validated against it. Floor agreement's sentence
    becomes: "a floor that disagrees with the spec's vectors and semantic
    functions is wrong by definition." The determinism debts get pinned in it
    deliberately. E72's re-bootstrapper reads it in an afternoon.
- **What chirality makes impossible here (under (b)):** semantics-by-accident. An
  executor behavior not derivable from the spec is a bug *even if every
  executor agrees on it* — correlated agreement can no longer ratify an
  accident into law, which is precisely the failure mode of §3.

## 5. Chirality example (fleshed)

The spec artifact's shape — the golden object as data, not as an executor.
Two entries shown: the canonical floor-agreement failure (division, already
pinned Euclidean) and a byte op. The *prose reading* of each entry is the
human-audited anchor; the executable form is derived machinery (§6 circularity
note).

```chirality
(import "prelude")

; ---- the spec's vocabulary ------------------------------------------------
; An observable is what floor agreement compares: the returned value and the
; effect sequence. The spec speaks ONLY in observables — register allocation,
; encodings, arena layout are executor-private and deliberately unspecified.
(data Obs () (obs-val (v I64)) (obs-halt) (obs-sys (n I64) (args (List I64))))

; One spec entry: an instruction's transition as a TOTAL PURE function over
; the abstract machine state, plus pinned vectors. Pure -> is the point: the
; semantics of the floor is itself category-A, checkable, weekend-readable.
(data SpecEntry ((0 S (type 0)))
  (spec-entry
    (name Str)                      ; "div", "bput", ...
    (sem (-> S S))                  ; the transition, total by construction
    (vectors (List (Pair S Obs))))) ; pinned input/observable pairs — the
                                    ; determinism debts live HERE, on purpose

; ---- the two exemplar entries --------------------------------------------
; div: Euclidean, SMT-LIB aligned — the pin the reference already obeys.
; The vector list carries the whole sign grid INCLUDING the two inputs raw
; idiv faults on: INT_MIN/-1 -> wrapped INT_MIN, and /0 -> the fatal alarm.
; (def spec-div (SpecEntry MState)
;   (spec-entry "div" div-sem
;     (cons (pair (mstate -7 2)        (obs-val -4))     ; Euclidean, not trunc
;     (cons (pair (mstate int-min -1)  (obs-val int-min)); wraps, agreeing
;     (cons (pair (mstate 7 0)         obs-halt)         ; deliberate trap
;     ; ... the full sign grid ...
;     nil)))))

; bput: initialization write; an unwritten byte reads 0 on every executor —
; today a floor *contract*, under the spec a pinned vector like any other.

; ---- the demanded statement (the socket) ----------------------------------
; An executor is ADMITTED iff it matches the spec on every vector and on
; differential runs against the spec's semantic functions. This is the
; certificate-discipline shape: fixed statement, producers validated against
; it — the reference interpreter is just the first producer through the gate.
(data Verdict () (admitted) (diverged (at Str) (got Obs) (want Obs)))
(declare conform (-> (List (SpecEntry MState)) Executor Verdict))
```

- **Knobs to modify:** the observable set (add memory-visibility observables
  when concurrency lands); vector density per instruction; whether `sem` is
  authored per-instruction or per-family; the `MState` abstraction level.
- **Deliberately omitted:** the full `MState` machine-state shape (the real
  spec's first authoring decision); sysface entries' interaction with the
  effect row's tal shadow (E70 designs that); the executable-spec runner.

## 6. Use / modify notes

- **Lands in:** a rewrite of `docs/floor-agreement.md`'s "Statement" section
  (already begun — the note carries the provisional spec-as-golden banner
  today; the rewrite finalizes it on ratification) + a new `docs/tal-spec.md`
  (prose anchor) with `lib/tal-spec.chiral` (the data form above) — plus a home
  decision note recording the branch taken.
- **Conformance target:** every observable the current differential suite
  checks (division sign grid, byte-cell zero-read, the fold/native/reference
  triples) must be derivable from spec vectors — the existing tests become the
  spec's seed corpus, so the restructure changes the anchor without changing
  one passing test.
- **Open questions:** the executable-spec circularity — the `sem` functions
  are chirality code needing *some* executor to run, so the trust anchor is the
  spec's **prose reading** (human-audited, E72's weekend artifact) and the
  executable form is the first derived checker; whether that prose/executable
  dual lives in one file or two. Spec coverage of the sys face (real syscalls
  are not pure transitions — the spec pins the *register/observable contract*,
  not the kernel's behavior). Who curates vector growth as tal grows (edge 6:
  every new instruction is a new agreement obligation — under (b), a new spec
  entry *first*).
- **RECOMMENDATION → PROVISIONALLY ADOPTED (2026-07-26, revisitable — the call
  is the author's):** branch **(b), spec-as-golden.** The author provisionally
  took this branch ("go for a solution, may change"), so `floor-agreement.md`
  now carries the provisional banner and its reference-is-golden text is legacy
  pending ratification (the owed author call — E72 is its strongest argument).
  It is the division precedent generalized, the only branch compatible with
  E72's re-bootstrap requirement, the shape certificate discipline demands
  (fixed statement at the socket), and it takes the trust anchor *out* of D7's
  correlated-provenance problem instead of moving it in.
  The strongest counterargument: a spec is a second implementation wearing
  prose, and it can be wrong or incomplete where a running reference cannot be
  silent — mitigated, not erased, by seeding it from the existing differential
  corpus and keeping the reference as first-among-producers whose divergence
  from the spec is *investigated*, not auto-ruled against either side.
- **Related:** [[E15-reference-interpreter]] (demotes to first producer),
  [[E18-tal-check]] (the checker beside the semantics), E72 (re-bootstrap
  consumes the spec), E53 (DDC climbs against it), E70 (sysface shadow),
  `docs/floor-agreement.md` (the note this restructures), D7/edge 11 (where
  correlated agreement remains, honestly, for the floor's *executors*).
