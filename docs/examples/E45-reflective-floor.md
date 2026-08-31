---
element: E45
slug: reflective-floor
title: Reflective floor (what is reconfigurable from inside)
kind: BUILD-PROPER
reference_class: PAPER
ours_source: (none)
status: drafted
updated: 2026-07-22
---

# E45 — Reflective floor (what is reconfigurable from inside)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.
> **Rung-1 principled/infallible element:** the immutable-core line must be
> *drawn*, not just directional, for "self-modifying code cannot forge authority
> through the kernel" (P1) to hold. The D-walk (D3) settled the *direction*; this
> pre-run carries it into a mechanism, and does not re-derive it.

## 1. Scope

- **Element:** E45, the reflective floor — the line below which the running
  language *cannot reconfigure its own judgment*, even though it can *express*
  it (P1's expressible-vs-modifiable distinction, made mechanical).
- **Kind:** BUILD-PROPER (direction resolved in `docs/open-edges.md` edge 5 /
  the D-walk; zero code today — `Sig` is fully mutable).
- **Why chirality needs its own:** P1 says the kernel must be *expressible* (so every
  path through it is named and gateable) yet not *reconfigurable from within* (so
  self-modifying code cannot forge authority by editing the checker under itself).
  That second clause is a claim with no mechanism today: the judgment core is a
  live mutable object. Rung-1 "infallible primitives" is exactly this line drawn —
  without it, "the checker proved it" means nothing against code that can rewrite
  the checker.

## 2. Research

- **Reference class:** PAPER — reflective towers (Smith's 3-Lisp; Brown's tower
  of interpreters). Read for the *choice they make and we refuse*: in a 3-Lisp
  tower every level is reified and reconfigurable from the level above, an
  *infinite* tower with no floor. That is maximal reflective power and zero
  containment — the exact opposite end of the axis P1 forces us to.
- **Key findings (the direction is settled — carried, not re-derived):**
  1. **All dynamism is mesh dynamism** (D3): a running judgment is never mutated
     in place; change happens by *staging a successor runtime*, never by editing
     the live one. So "reconfigure from inside" was never the operation — the
     operation is *succession*, and succession is gateable.
  2. **The line:** a runtime's judgment (`kernel-core` + `kernel-spec`) is
     **staged-in, never granted-to, and not swappable after staging completes**.
     Reflection over it is *read-only* (inspect terms, generate typed terms —
     E58 `reflect-typed`); reconfiguration is *inexpressible*, not merely
     forbidden.
  3. **The mechanism reduces to one move:** freeze `Sig` at link/install
     completion. Today `Sig` (kernel.py:111) carries the whole judgment as
     mutable attributes — `ext_check`/`ext_eval` (term-former handlers),
     `rules` (the membrane), `check_hooks`/`subtype_hooks`/`conv_hooks`/
     `quote_hooks`/`narrow_hooks`/`linear_hooks`/`def_hooks`. Every one is a
     live dict or list. Freezing is a *linear consume* of the mutable builder
     into a read-only staged value, after which the mutable handle no longer
     exists to write through.
  4. **Succession is certified** (D3 + E52): a new judgment enters only by a
     stager whose core re-checks the successor's core against `kernel-spec` —
     the E52 certificate format *is* the succession payload. "What is modifiable
     from inside" becomes "what the trusted core will not certify."

## 3. Conventional (other-language) approach

The reflective-tower lineage, and our own scaffold, both leave the interpreter
open to itself:

```python
# 3-Lisp shape: every level is reconfigurable from above — infinite tower, no
# floor. Power maximal, containment nil: a program reifies the interpreter that
# runs it and rewrites its own evaluation rules, forever up.

# OURS today — scaffold/chirality/kernel.py: the judgment IS a live mutable object.
class Sig:
    def __init__(self):
        self.ext_check = {}      # term-former handlers — a mutable dict
        self.rules = None        # the effect membrane — a mutable attribute
        self.conv_hooks = []     # conversion — a mutable list
        # ... every seam of the judgment, writable at runtime
# install(sig, ...) mutates these as modules load. Nothing freezes them; any
# code holding `sig` can, in principle, register a rule that admits an
# ill-typed term — and then everything "the checker proved" is void.
```

- **Assumptions it bakes in:** the interpreter is perpetually open to itself
  (the tower has no floor); trust in "the checker accepted it" is unfounded if
  the checker is mutable by the checked; there is no distinction between
  *expressing* the kernel (fine — P1 wants it) and *reconfiguring the running*
  kernel (the forge hole); and reflection is all-or-nothing (read implies the
  power to write). chirality refuses exactly the read-implies-write and
  perpetually-open assumptions.

## 4. The chirality idea

- **Chirality features in play:** QTT linearity (the mutable builder is a linear
  resource, consumed once into the frozen form), staging (a new judgment arrives
  only as a staged successor — E57), certificate discipline (succession is
  re-checked, E52), categories (the frozen core is the trusted A-artifact;
  reflection is read-only over it), the effect membrane (installing a seam is a
  crossing that only the builder phase holds the port for).
- **The reframing:** "what is reconfigurable from inside" stops being a policy
  question (a denylist of protected operations) and becomes a *structural* one
  (P4): the write-capable handle to the judgment is a linear value that exists
  only during staging and is **consumed** when the runtime goes live. After that,
  the only value in scope is the frozen, read-only judgment. Reconfiguration is
  not blocked by a check at runtime — it is *unexpressible*, because the thing
  you would call to do it was moved away and cannot be named. A new judgment can
  still enter the mesh, but only by staging a *successor* runtime whose core the
  stager certifies against `kernel-spec` first (the succession wall).
- **What chirality makes impossible here:** editing the live judgment (the mutable
  builder was consumed — no handle survives to write through); a runtime
  silently swapping its own checker (swap = stage a successor = certified
  crossing, or it does not happen); reflection escalating to reconfiguration (the
  reflected view is read-only by type — E58 hands you typed *terms*, never the
  `Sig` write-seam); and an uncertified successor judgment entering the mesh (the
  stager's core refuses the certificate).

## 5. Chirality example (fleshed)

The floor as two types and one linear move. The *builder* is where seams are
installed (staging phase); the *frozen* judgment is what a live runtime holds —
read-only, no write-seam reachable.

```chirality
(import "prelude")

; ---- the write-capable judgment: a LINEAR builder, staging-phase only --------
; Holds the seams kernel.py exposes today (ext_check, rules, the hook lists).
; It is linear (quantity 1): it threads through staging and is consumed exactly
; once. There is no way to duplicate it, so no way to keep a write-handle live.
(data SigB ()
  (sig-b (formers  (List Former))     ; ext_check / ext_eval
         (membrane Rules)             ; the effect rules
         (vhooks   (List VHook))))    ; check/subtype/conv/quote/narrow/linear

; installing a seam CONSUMES the builder and returns a new one (linear update):
(declare install-former (-> (1 b SigB) Former SigB))
(declare install-vhook   (-> (1 b SigB) VHook  SigB))

; ---- the frozen judgment: what a LIVE runtime holds — READ ONLY --------------
; No field is a write-seam. The only operations are queries the checker runs.
; There is no (unfreeze : Frozen -> SigB): the inverse does not exist.
(data Frozen ()
  (frozen (formers (List Former)) (membrane Rules) (vhooks (List VHook))))

; ---- freeze: the one linear move that draws the floor -------------------------
; Consumes the builder (quantity 1 in) and yields the immutable judgment.
; After this call the SigB is GONE — reconfiguration is now unexpressible,
; not because a guard says no, but because no write-capable value is in scope.
(declare freeze (-> (1 b SigB) Frozen))
(def freeze
  (lam (b)
    (case b
      ((sig-b fs mem vh) (frozen fs mem vh)))))   ; builder consumed here

; ---- reflection over the frozen core is READ-ONLY (the E58 boundary) ---------
; You may look at the rules and generate typed terms; you may NOT get a SigB
; back. reflect-typed's type is Frozen -> (typed term), never Frozen -> SigB.
(declare reflect-formers (-> Frozen (List Former)))   ; inspect: fine
; (declare reflect-writeback (-> Frozen SigB))        ; UNTYPEABLE — no such fn

; ---- succession: a NEW judgment enters ONLY by certified staging (E52) -------
; A stager holds its own Frozen core; to bring up a successor it must present a
; certificate the stager's core re-checks against kernel-spec. Uncertified
; succession is refused — the wall. (recheck is E52's core; Cert its format.)
(declare recheck (-> Frozen Cert Verdict))            ; E52
(declare stage-successor (=> (1 self Frozen) Cert (StageR)))
;   body: (case (recheck self cert)
;           ((v-accepted)      (spawn-with cert))     ; the successor runs
;           ((v-rejected r at) (refuse r at)))        ; the wall holds
```

- **Knobs to modify:** which seams are in `SigB` (must be exactly the judgment
  seams — `formers`/`membrane`/`vhooks` cover kernel.py's set); whether `Frozen`
  exposes *any* structured reflection beyond `reflect-formers` (E58 owns that
  surface); the succession certificate's contents (E52).
- **Deliberately omitted:** E58 `reflect-typed`'s full read-only reflection API
  (this example only draws the boundary — read yes, write no); E57 staging's
  general machinery (succession is one use of it); the certificate format
  internals (E52).

## 6. Use / modify notes

- **Lands in:** a split of `scaffold/chirality/kernel.py`'s `Sig` into a
  builder/`Frozen` pair (or the chirality-side `kernel-core` port carrying the same
  split), with `install`-time seam registration on the builder and every
  post-stage judgment query reading `Frozen`. `freeze` is called at the end of
  link/load (the staging connector's completion point).
- **Conformance target:** every currently-passing check still passes with the
  judgment read from `Frozen`; and the negative test IS the element — a program
  that obtains a live runtime's judgment and attempts to register a rule (admit
  an ill-typed term) must be a *type error / unexpressible*, not a runtime
  refusal. The `SigB`→`Frozen` consume is what makes the write attempt fail to
  elaborate at all.
- **Open questions:**
  1. **The bootstrap-transition mutable path — DECIDED 2026-07-22.** During
     self-hosting the core is *still Python* (`kernel.py`), and Python `Sig` is
     mutable regardless of what the chirality-level types say — so mid-transition the
     floor is a discipline, not a structural guarantee. **Decision: accept the
     interim discipline as the stated rung boundary; no early partial freeze in
     the Python `Sig`.** Rationale (checked against `trust-boundary`:70,100): the
     whole language is discipline-not-enforcement on CPython by design, and the
     threat model carries *no Python-level adversary at this rung* — so an early
     freeze would add code to throwaway scaffold to defend a threat the model
     does not cover here. E45 becomes *enforcement* structurally when
     `kernel-core` is itself chirality with `Frozen` unforgeable (the `SigB`→`Frozen`
     split is a constraint ON that port, not a standalone prior step). Until then
     "frozen" is honored, not enforced — the same rung boundary the whole
     language already states.
  2. Whether `def_hooks` (post-def callbacks) count as judgment seams that must
     freeze, or are staging-only by construction.
  3. Whether *any* live re-staging of one's own core (hot self-upgrade) is
     wanted at rung 2, or succession is always a fresh peer — couples the
     live-environment workload.
- **Related:** [[E52-certificate-split]] (the succession payload / recheck),
  [[E58]] (reflect-typed — the read-only reflection this bounds),
  [[E57]] (staging — how a successor enters), [[E12-effect-membrane]] (the
  bootstrap bridge where the floor is interim-discipline), `docs/open-edges.md`
  edge 5 (D3 direction), `docs/decision-split-checker.md` (kernel-core).
