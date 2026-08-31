---
element: E52
slug: certificate-split
title: Kernel-core certificate split: kernel-spec artifact + small trusted core re-checking untrusted producers' certificates + certificate / proof-object format (LCF / de Bruijn)
kind: BUILD-PROPER
reference_class: PAPER
ours_source: scaffold/chirality/kernel.py
status: drafted
updated: 2026-07-22
---

# E52 — Kernel-core certificate split: kernel-spec + kernel-core + the certificate format

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.
> **Trust-lane element: every open call below is marked as the author's.** This
> pre-run shapes kernel-spec itself; nothing here is decided by the example.

## 1. Scope

- **Element:** E52, the LCF/de Bruijn split of the checker: **kernel-spec** (the
  type theory as a small, human-audited requirement type), **kernel-core** (one
  small trusted derivation re-checker), and the **certificate format** untrusted
  producers emit and the core re-runs.
- **Kind:** BUILD-PROPER — settled in `decision-split-checker`, zero code *for
  the kernel-core split*: today `kernel.py` conflates spec and implementation,
  and there is **no certificate seam in the kernel judgment** — `surface.py`
  elaborates and hands straight to `kernel.finish_def` (kernel.py:567), which
  checks the body and installs it with nothing re-derived (elaboration is
  trusted de facto). The certificate *discipline* itself is not absent from
  chirality: its flagship `preserve-check` is **BUILT** at the lowering seam
  (`lower.py:432`); E52 is the generalization of that proven-once pattern to the
  checker. The gap contradicts the settled trust story every day it persists.
- **Why chirality needs its own:** this split IS the trust story. Trust and volume
  decouple only when the evolving bulk (elaborator, optimizers, solvers,
  staging) is trusted for nothing because a small core re-checks its work
  against a fixed statement. It is also the ownership story: you own the
  language iff you can read kernel-spec in a sitting and audit kernel-core
  against it (`SELF-HOST-PLAN` ownership requirement 1 — the **spec-size budget
  is a design constraint on this element, not taste**).

## 2. Research

- **Reference class:** PAPER — LCF (trusted-kernel/derived-rules architecture),
  the de Bruijn criterion (proofs re-checkable by a small independent checker),
  CakeML/MetaCoq as existence proofs that a checker can be verified against an
  external spec. Tier P: lineage read for shape; no canonical kernel cribbed.
- **Key findings:**
  1. **Bidirectional typing makes the typing certificate nearly free.** The
     judgment is syntax-directed on annotated terms: given a fully elaborated
     core term (ascriptions at the non-syntax-directed points), re-checking is
     deterministic re-derivation — **the elaborated term IS the derivation**
     (edge 12 already records E39's elaborated-handler-term as the existence
     proof for the producer side). No separate proof tree is owed for typing.
  2. **Conversion is the hard part, and it decides the TCB's size.** A
     conversion claim `T ≡ U` is one line to state and unboundedly expensive to
     re-derive. Whatever the certificate carries for conversion determines what
     kernel-core must *contain*: re-run NbE and the core contains an evaluator;
     accept traces and the core shrinks to a step-checker but certificates
     balloon; accept cached hashes and re-checking amortizes but drops a tier.
  3. **The demanded statement lives at the socket** (certificate-discipline):
     the producer never chooses what it proves. Vacuity is pinned in exactly
     one place — is kernel-spec's demanded statement meaningful — audited once.
  4. **The certificate format versions with the carrier freeze.** Certificates
     must cover the FULL frozen carrier — quantities, effect row, grade vector,
     totality mark (`decision-effect-facets`, `decision-graded-kernel`) — so
     the format bumps when the seat set bumps and never per-feature. A
     certificate that covers only part of the carrier silently un-checks the
     rest: the exact gap the split exists to close.

## 3. Conventional (other-language) approach

Three conventional shapes, each refusing something chirality needs:

```python
# (a) OURS today — the def-entry seam is surface.py `toplevel` handing to
# kernel.py: spec and impl are one artifact, and elaboration output flows
# straight into the judgment. No boundary object — whatever `elab` produced is
# checked and installed with nothing re-derived (trusted de facto):
#   surface.py toplevel: body = self.elab(form[3], []); K.finish_def(sig,name,body)
def finish_def(sig, name, body):              # kernel.py:567 — elaborator output enters
    tyv = sig.global_types[name]              # the "spec" is this code itself
    check(sig, Ctx(), body, tyv, EMPTY_ROW)   # no certificate; no re-check seam
    sig.global_defs[name] = body              # installed as-is

# (b) LCF-in-ML: an abstract `thm` type. Sound, but the evidence is a value of
# a protected module — there IS no artifact to re-check; trust rides the
# module boundary and dies with the process.
# (c) Coq/Lean compiled caches (.vo): proof objects exist, but day-to-day
# trust flows through opaque compiled files accepted from disk — a cache
# trusted by provenance, not re-derivation.
```

- **Assumptions they bake in:** the spec is the implementation (its bugs are
  unappealable — no external statement to audit the checker against); evidence
  is process-local (nothing survives to be re-checked by a *different* core —
  exactly what D3 succession needs); caches are trusted by file provenance;
  and the checking cost structure is fixed by the kernel's internals rather
  than chosen per-tier and named.

## 4. The chirality idea

- **Chirality features in play:** categories (kernel-spec is the demanded
  statement; producers are untrusted C-adjacent bulk; kernel-core is the one
  trusted A-artifact), certificate-discipline (re-run, never spot-check;
  tiered evidence, named), the frozen carrier, result sums, totality (the core
  itself must be total), D3 succession (staged-in judgment).
- **The reframing:** the monolith splits into three artifacts with one
  direction of trust. **kernel-spec**: the judgment forms as data — a
  requirement type enumerating the rules, under an explicit size budget
  (readable in a sitting; every carrier seat spends from it). **kernel-core**:
  a pure total function `recheck : Spec → Cert → Verdict` — the only
  trusted code, spec-directed, small because everything non-syntax-directed
  arrives annotated. **certificates**: the elaborated core term (typing) plus
  conversion evidence at a *named tier*. The elaborator becomes the first
  untrusted producer; `install` consumes verdicts, never producer output.
- **What chirality makes impossible here:** an elaborator bug becoming a soundness
  bug (its output is re-derived, not believed); a certificate of the wrong
  statement (the demanded statement is fixed at the socket, per-producer
  choice inexpressible); a partial-carrier certificate (the format covers all
  seats or it does not parse); an amortized re-check masquerading as a fresh
  one (the tier is in the evidence constructor, named — certificate-discipline's
  tiering made structural).

## 5. Chirality example (fleshed)

```chirality
(import "prelude")
(import "collections")

; ---- kernel-spec, as data: the demanded statement ------------------------
; The spec is an ARTIFACT the core is directed by, not prose beside it.
; Budget constraint (ownership req 1): this enumeration is the thing an owner
; reads in a sitting — every rule and every carrier seat spends the budget.
(data JForm ()
  (j-check)                 ; Γ ⊢ t ⇐ T   (checking)
  (j-infer)                 ; Γ ⊢ t ⇒ T   (synthesis)
  (j-conv)                  ; T ≡ U        (conversion)
  (j-usage)                 ; carrier accounting: q · row · grades · totality
  (j-data) (j-membrane))    ; the seam judgments (positivity/coverage; row rules)

(data SpecRule ()
  (spec-rule (form JForm) (name Str) (statement Str)))  ; statement: the pinned
                                                        ; prose reading (E71 tie)
; kernel-spec = (List SpecRule) + the frozen carrier arity. One value, audited.

; ---- the certificate: what a producer must show --------------------------
; Typing: the elaborated core term IS the derivation (bidirectional =>
; deterministic re-run). CoreTerm is the annotated term rep (E13/E3 port).
;
; Conversion: the evidence tier is EXPLICIT and named — the author call.
(data ConvEv ()
  (conv-rerun)                          ; tier 1: core re-runs NbE itself.
                                        ;   cert is empty; core CONTAINS eval.
  (conv-trace (steps (List Str)))       ; tier 2: step evidence; core = tiny
                                        ;   step-checker; certs can balloon.
  (conv-cached (nf-hash Bytes)          ; tier 3: content-hash of a prior
             (sig Bytes)))              ;   check, signed. Amortized — WEAKER,
                                        ;   and the constructor says so.

(data Cert ()
  (cert (tm CoreTerm)                   ; the annotated term = typing evidence
        (conv ConvEv)                   ; conversion evidence, tier named
        (carrier-ver I64)))             ; bumps with the seat freeze, never
                                        ; per-feature — partial coverage
                                        ; cannot parse as current

; ---- kernel-core: the one trusted function -------------------------------
; Pure, total, spec-directed. Verdicts are values; rejection carries the rule
; that failed (rich alarms, the house pattern). Totality of recheck itself is
; a spec-level obligation: conversion fuel / normalization argument — see §6.
(data Verdict ()
  (v-accepted)
  (v-rejected (rule Str) (at Str))
  (v-wrong-carrier (want I64) (got I64)))

(declare recheck (-> Spec Cert Verdict))
; … syntax-directed walk over (cert-tm): each node re-derives its judgment
;   against the spec's rules; conv sites dispatch on ConvEv's tier; usage,
;   row, grades, and totality mark are re-accounted at every binder — the
;   full carrier, or v-wrong-carrier. Structural recursion on the term. ; …

; ---- the producer seam ----------------------------------------------------
; The elaborator (surface.py's port) is producer #1: it emits Certs and holds
; no trust. install consumes VERDICTS only:
;   (case (recheck spec cert)
;     ((v-accepted)        (install-def …))
;     ((v-rejected r at)   (report r at))     ; producer bug != soundness bug
;     ((v-wrong-carrier w g) (report-version w g)))
;
; D3 succession rides the same seam: a stager's core runs (recheck spec
; successor-core-cert) before staging it — the certificate format IS the
; succession payload.
```

- **Knobs to modify:** the ConvEv tier mix per context (author call — see §6);
  the SpecRule statement granularity; the carrier version discipline;
  Verdict's diagnostic payload.
- **Deliberately omitted:** the CoreTerm annotation set (which ascriptions the
  bidirectional judgment needs is the E3/E4 port's design); the serialized
  certificate encoding (needs the canonical-form decision — E8's `repr`
  finding, a fixpoint determinism debt); producer #2+ (optimizer already has
  preserve-check; solvers per inspiration-policy Tier O).

## 6. Use / modify notes

- **Lands in:** `docs/kernel-spec.md` (the audited prose artifact — E71's
  spec-as-golden sibling; one budget governs both) + a `kernel-core` module
  (the `recheck` port of kernel.py's judgment, shrunk to spec-directed
  re-derivation) + the elaborator emitting Certs. The Python `kernel.py`
  becomes the reference producer/checker pair during transition.
- **Conformance target:** differential — every definition the current kernel
  accepts is accepted by `recheck` on the elaborator's certificate, every
  rejection matches, across the whole existing suite; then one deliberate
  elaborator-bug injection must be CAUGHT by recheck (the seam's negative
  test — the whole point of the split).
- **Open questions (ALL author calls, this element is the substrate):**
  1. **The conversion-evidence tier mix** — **RESOLVED 2026-07-26 →
     per-instance** (catalog §VII): the tier is chosen *per certificate site*,
     not one global setting — `conv-rerun` where the check is decidable & cheap
     (conversion / NbE), `conv-trace` (LCF/de Bruijn proof-object) for
     undecidable producer outputs (solvers, elaboration), `conv-cached` only
     where perf dominates and the trust is acceptable; the TCB is the union of
     the tier-checkers actually used. The tradeoff the resolution rests on:
     tier 1 (re-run) puts NbE *inside* the trusted core, so the spec-size budget
     and the core's size are decided HERE, not in the typing rules; tier 2 keeps
     the core tiny but certificate size is unbounded; tier 3 must never
     masquerade as fresh. The per-site pick this licenses: tier 1 for the core's
     own working set, tier 3 for warm re-checks, tier 2 reserved for cross-core
     succession (D3) where re-running a foreign core's work is the exact thing
     you refuse.
  2. Totality of `recheck` itself. Totality of the *carried input* is already
     settled discipline, not an open call: the totality mark is a carrier seat
     (`decision-effect-facets`, the Pi carrier `(q, row, grades, totality-mark,
     …)`) re-checked as a **declared measure** — "declared, never inferred —
     certificate discipline: the checker only re-checks the measure, and a false
     one is rejected" (`totality.md`; classify-not-enforce). `recheck`
     re-accounts that mark like any other seat. The genuine residual is
     narrower: `recheck`'s **own** operational termination when it re-runs
     **conversion** (the one site with no declared measure). Author call: is that
     conversion-termination a spec-level normalization claim stated in
     kernel-spec, or fuel-bounded with a fuel-exhaustion verdict? (Ties
     [[E03-nbe-normalize]] dec#1 — the same SN-posture question; decide them
     together.)
  3. The E12 bootstrap bridge: during transition, chirality-side producers emit
     Certs checked by the still-Python core — which requires the serialized
     format *before* self-hosting, hence the canonical-form dependency.
  4. Spec-size budget enforcement: what "readable in a sitting" is measured
     as (page/rule count?), and who signs off a budget spend (a carrier seat,
     a new judgment form).
- **Related:** `decision-split-checker` (the settled split), 
  `certificate-discipline` (re-run-not-spot-check; the tiering), [[E39-effect-row]]
  (elaborated-term-as-certificate existence proof), [[E71-golden-restructure]]
  (sibling spec artifact; one ownership budget), [[E12-effect-membrane]] (the
  bootstrap bridge), [[E03-nbe-normalize]]/[[E04-bidir-universes]] (the
  judgment being split), E53 (DDC — the build-time independence under this),
  E72 (the re-bootstrap artifact kernel-spec anchors).
