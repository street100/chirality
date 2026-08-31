---
element: E72
slug: re-bootstrap
title: Re-bootstrap artifact: the shipped form contains its own re-derivation — kernel-spec + a reference semantics simple enough to reimplement in a weekend in any language, + DDC (E53) to verify the climb; no trusted binary in the forever-story. Couples E71 (spec-as-golden) and the E52 spec-size budget
kind: BUILD-PROPER
reference_class: OURS/PAPER
ours_source: (none)
status: drafted
updated: 2026-07-22
---

# E72 — Re-bootstrap artifact: the shipped form contains its own re-derivation

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.
> This element is the OWNERSHIP requirement made checkable: "anyone can take
> chirality and self-host it, in whatever form they want, forever" is true iff the
> climb chain below exists, ships with the artifact, and is verified — not hoped.

## 1. Scope

- **Element:** E72, the re-bootstrap artifact: the shipped form of chirality
  contains its own re-derivation from prose — a climb chain from "any Linux box
  plus any programming language" back up to a native, self-checked chirality, with
  **no trusted binary anywhere in the forever-story**.
- **Kind:** BUILD-PROPER (requirement pinned in `SELF-HOST-PLAN.md` — nothing
  built — this pre-run is the chain's first concrete enumeration).
- **Why chirality needs its own:** self-hosting creates a binary-seed regress — you
  need a running chirality to build chirality. Every other language answers it with
  archaeology (see §3). chirality's answer must be structural, because ownership is
  a design goal with the same rank as safety: you own the language iff you can
  audit the spec and regenerate everything else. E72 is where that stops being
  a slogan and becomes a shipped, checkable manifest. It is also half of E53:
  the weekend leg IS the provenance-disjoint compiler Wheeler's Diverse
  Double-Compiling needs — re-bootstrap and DDC are one machinery.

## 2. Research

- **Reference class:** OURS (kernel-spec / tal-spec / the source tree /
  `examples/refs/`) + PAPER — the bootstrappable-builds lineage (stage0, hex0,
  GNU Mes, Wheeler's DDC) as *ideas*: their move is "shrink the seed until a
  human can audit it." The chirality form is its own: the seed is not a tiny
  binary, it is **prose plus vectors** (E71's spec-as-golden — cited as the
  standing recommendation, awaiting author ratification — E72 is unbuildable
  without it, which is itself an argument in that decision).
- **Key findings:**
  1. **The seed's floor is the tal spec, not the upper language.** A weekend
     implementer cannot write an NbE evaluator for full QTT from prose in a
     weekend — but a tal executor (a register machine over I64 + byte cells,
     one instruction table, the pinned vectors) plus an s-expression reader is
     exactly weekend-sized. So the climb enters at the FLOOR, and everything
     above the floor climbs as *checked chirality artifacts*, not as re-implemented
     semantics.
  2. **Therefore the checker and compiler must ship in two forms:** upper chirality
     source (the thing being trusted-from-spec) AND their preserve-checked
     tal lowering (the thing the weekend executor can actually run). The
     shipped tal is not a trusted binary — it is *checkable text*: the weekend
     implementer also writes the spec'd **tal checker** (small, part of the
     tal spec) and verifies every shipped tal function against its signature
     before running any of it. No-untyped-bottom is what makes this possible:
     the lowest shipped artifact is still typed, still auditable.
  3. **The chain closes with a fixpoint, not a promise.** Stage 3 regenerates
     the shipped tal from the upper source using the climbed compiler; the
     regenerated tal must match the shipped tal (the tal fixpoint), and the
     DDC compare (E53) runs the same regeneration through a second, foreign
     climb. Divergence anywhere names a lie: in the spec, the shipped tal, or
     the climb.
  4. **The ref banks are part of the ownership story.** `examples/refs/`
     (gen-scripts deriving every ABI number from local headers/ctypes/readelf)
     means the platform facts re-derive on the *taker's* box — the artifact
     carries no unexplained constants.

## 3. Conventional (other-language) approach

How the binary-seed regress is handled everywhere else — it mostly isn't:

```text
# rustc: to build rustc N you need rustc N-1. Recurse to 2015, then OCaml.
# gcc:   ships "bootstrap instructions" that begin with a working cc.
# CPython: the semantics IS the codebase; re-implementing means reading it
#          (dict-ordering became law because the implementation did it).
# The bootstrappable-builds project exists precisely because none of these
# chains bottom out in anything a human can audit: the seed is a binary
# someone once had, and trusting-trust rides the whole chain (Thompson).
```

- **Assumptions it bakes in:** a prior blessed binary exists and is trusted
  (the regress is cut by fiat, not by audit); the semantics lives in an
  implementation, so re-derivation is archaeology; platform constants are
  copied folklore; and verification of the climb — where it exists at all —
  is "it compiled," never a fixpoint or a diverse compare. The RISC-V/SMT-LIB
  lineage is the exception shape: spec first, implementations as conformance
  candidates — the lineage chirality's division pin (Euclidean, SMT-LIB-aligned)
  already joined.

## 4. The chirality idea

- **Chirality features in play:** spec-as-golden (E71 — the demanded statement in
  prose + vectors), no-untyped-bottom (the shipped tal is checkable text),
  preserve-check (the shipped tal carries its signatures), certificate
  discipline (the spec is the fixed statement — every executor and every climb
  is an untrusted producer validated against it), E53 DDC (the verified
  compare), the E52 spec-size budget (the constraint that keeps stage 1
  honest).
- **The reframing:** "bootstrap" stops being a historical event and becomes a
  **shipped, re-runnable verification chain**. The artifact = spec (prose +
  vectors) + upper source + preserve-checked tal + ref-bank scripts + this
  manifest. Anyone, forever, on any Linux-ish box: write the weekend
  interpreter from prose → check the shipped tal with the spec'd tal checker →
  run the (checked) chirality checker over the upper source → run the (checked)
  compiler to go native → regenerate the tal and demand the fixpoint → DDC
  against a second independent climb. Trust bottoms out in exactly two
  places: the audited prose, and the human reading it.
- **What chirality makes impossible here:** a step that needs a specific prior
  binary (every stage's input is text the previous stage checked); semantics
  living outside the spec (a behavior not derivable from spec+vectors is a bug
  even if every executor agrees — E71's anti-ratification rule); silent spec
  drift (the fixpoint + DDC compare turn drift into a named divergence);
  unexplained platform constants (ref banks re-derive them locally).

## 5. Chirality example (fleshed)

The climb manifest as checkable data — this is the artifact that ships, and
the shape a `chirality climb --verify` command would consume.

```chirality
(import "prelude")

; ---- what ships (stage 0): every item text, every item checkable ---------
(data ShipItem ()
  (ship-prose   (path Str))              ; kernel-spec.md, tal-spec.md (+vectors)
  (ship-source  (path Str))              ; upper chirality source tree
  (ship-tal     (path Str) (sig Str))    ; preserve-checked tal lowering + sigs
  (ship-genref  (path Str)))             ; refs/gen-*.py — ABI facts re-derive

; ---- the climb: each stage names what it does and what checks it ----------
; A stage's check is against the SPEC or a previous stage's output — never
; against a shipped binary, because there is none.
(data Stage ()
  (stage (n I64) (does Str) (checked-by Str)))

(def climb (List Stage)
  (cons (stage 0 "unpack: prose + source + checked tal + gen-refs"
               "human audit of the prose; gen-refs re-run locally")
  (cons (stage 1 "weekend leg: implement tal executor + tal checker + sexp reader from tal-spec prose, in ANY language"
               "tal-spec vectors (pinned input/observable pairs per instruction) — the executor is admitted like any floor (E71)")
  (cons (stage 2 "verify shipped tal against its signatures with the stage-1 tal checker — then RUN the chirality checker (as checked tal) over the upper source, and the compiler over itself"
               "the shipped tal's preserve-check re-derived independently, plus the checker's verdicts on the source")
  (cons (stage 3 "go native: the checked compiler emits machine code; then REGENERATE the shipped tal from upper source"
               "regenerated tal == shipped tal, byte-for-byte: the tal fixpoint. A mismatch names a lie somewhere.")
  (cons (stage 4 "DDC: a second party's independent stage-1..3 climb, comparing final artifacts"
               "Wheeler's compare — the weekend leg is the provenance-disjoint compiler DDC needs (E53)")
  nil))))))

; ---- chain-breakers: what must be PINNED or the climb dies ---------------
; (each is a named obligation on other elements, not a hope)
(data Breaker ()
  (breaker (what Str) (pinned-by Str)))

(def breakers (List Breaker)
  (cons (breaker "semantics not in the spec (iteration order, encodings, arithmetic edges)"
                 "fixpoint determinism debts -> tal-spec vectors, on purpose (E71, the division-pin precedent)")
  (cons (breaker "a stage needing a prior binary"
                 "stage inputs are text, and stage 1 is human+prose only — the E52 spec-size budget keeps 'weekend' true, so spec growth is a tracked cost")
  (cons (breaker "spec drift from implementation"
                 "fixed demanded statement (certificate discipline) + stage-3 fixpoint + stage-4 DDC — drift becomes a named divergence")
  nil))))
```

- **Knobs to modify:** the weekend-leg scope (tal executor + checker + reader
  is the floor — a taker MAY climb via an upper evaluator instead: slower to
  write, skips the shipped-tal question entirely); vector density; the DDC
  party count (2 is Wheeler-minimal — more parties, more independence).
- **Deliberately omitted:** the tal-spec's own content (E71 owns the spec
  artifact — E72 consumes it); the `chirality climb` tooling; non-Linux climbs
  (the ref-bank discipline generalizes — a new platform re-runs gen-scripts
  against its own headers — but the sys-face crossings are Linux-shaped
  today, said plainly).

## 6. Use / modify notes

- **Lands in:** a `docs/definitions/bootstrap.md` (the human-facing climb instructions — the
  manifest above in prose) + `lib/climb.chiral` (the checkable manifest data) +
  the ship-list wired into whatever packaging stage 9 ends with. Gated on:
  E71 ratified (spec-as-golden — E72 is that decision's strongest argument),
  E52's spec artifact existing, **the native compiler — E70 (effectful
  lowering) + E69 (closure conversion): the checker/compiler are closure-heavy,
  effectful code, so stage 3's "go native + regenerate the shipped tal" fixpoint
  cannot run until they lower (the conformance map pins the fixpoint +
  leg-running as E70-gated)**, the tal fixpoint being achievable (E15/E16
  determinism), E53 tooling for the compare.
- **Conformance target:** a fresh party with no chirality binary completes stages
  1–4 and every check passes — and a deliberately corrupted shipped-tal (one
  instruction changed) is CAUGHT at stage 2 by the independently-implemented
  tal checker — the negative test IS the ownership claim.
- **Open questions:** **what form the checker/compiler ship in for stage 2** —
  upper source alone needs an upper evaluator (not weekend-sized), so the
  chain as drawn ships their preserve-checked tal, which sharpens "no trusted
  binary" into "no *unverifiable* artifact": the shipped tal is present but
  independently checkable, and stage 3's fixpoint re-derives it. Is that the
  honest final form, or does a minimal spec'd upper evaluator earn its
  spec-budget cost to make even the shipped tal optional? Also: the weekend
  bound as a *measured* claim (someone must actually run the climb and clock
  it — a target-note-style requirement, not an estimate); and how the chain
  versions when the spec grows (re-climb per release, or fixpoint against the
  previous release's artifacts).
- **Related:** [[E71-golden-restructure]] (the spec this consumes — its
  ratification is this element's precondition), E53 (DDC — one machinery),
  E52 (spec-size budget — the "weekend" constraint), [[E18-tal-check]] /
  [[E15-reference-interpreter]] (what stage 1 reimplements from prose),
  [[E34-elf-writer]] (stage 3's native artifact), `examples/refs/README.md`
  (the ABI-fact re-derivation discipline), `.planning/SELF-HOST-PLAN.md`
  (ownership requirements 1–2).
