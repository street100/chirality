---
element: E53
slug: ddc-bootstrap
title: Diverse double-compilation / trusting-trust bootstrap (the independence residue under E52)
kind: BUILD-PROPER
reference_class: PAPER
ours_source: (none)
status: drafted
updated: 2026-07-22
---

# E53 — Diverse double-compilation / trusting-trust bootstrap (the independence residue under E52)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E53, the answer to the one thing certificates cannot cover: the
  executable that *runs* the checker was itself built by a compiler, and a
  trojaned compiler can reproduce its trojan while compiling the compiler —
  invisible in source forever (Thompson). E52's certificates prove judgment
  steps; E53 cross-checks the *executor of the judgment* by rebuilding it
  through provenance-disjoint legs and comparing.
- **Kind:** BUILD-PROPER — direction only today (edge 11 / D7); nothing built.
- **Why chirality needs its own:** "actual self-hosting" ends with `kernel.py`'s
  port verified *by fixpoint + DDC, not by review* (SELF-HOST-PLAN). D7's
  recommended affordable independence rung for the floor is exactly
  "DDC + toolchain diversity" — this element is that recommendation's
  mechanism. And E72 (re-bootstrap) makes the same machinery load-bearing for
  *ownership*: the weekend-reimplemented interpreter is both the re-bootstrap
  path and a DDC leg. One build, two guarantees.

## 2. Research

- **Reference class:** PAPER — Thompson, "Reflections on Trusting Trust"
  (1984); Wheeler, "Fully Countering Trusting Trust through Diverse
  Double-Compiling" (2009); the bootstrappable-builds lineage as idea
  (re-runnable climbs, not archived binaries). Tier P: ideas only.
- **Key findings, mapped onto chirality's ACTUAL pipeline (not the abstract paper
  shape):**
  1. **Wheeler's move needs three things chirality will have anyway.** DDC =
     compile the compiler's source with an *independent trusted* compiler,
     then use that result to compile the source again, and compare against
     the suspect's self-build. It requires: the source (public), a
     provenance-disjoint second builder, and **deterministic builds** so
     comparison is meaningful. chirality's Stage1==Stage2 fixpoint (checker
     compiled by the Python-hosted chirality == checker compiled by itself,
     byte-identical) is already the determinism half — which is what makes
     the determinism debts load-bearing *now*: E8's finding that the
     linear-kind seen-set keys on Python `repr` (a borrowed canonicalizer),
     and trust-boundary's ordering/encoding pins, must be settled **before
     the port**, or the legs can never bit-agree and both fixpoint and DDC
     are dead on arrival.
  2. **chirality's legs are diverse *executors*, not diverse *codegens* — the
     chirality-specific simplification.** The code generator is chirality source
     (`emit-core` + `mach-x64`), so every leg *runs the same emitter*; a leg
     only needs to correctly execute chirality, not independently generate code.
     The honest leg inventory: **leg 0** — the self-hosted artifact (the
     suspect, and the fixpoint's subject); **leg 1** — the Python scaffold
     (historically prior, different language and toolchain; its DDC afterlife
     is the one reason the scaffold never fully dies — it retires *into* this
     role); **leg 2** — E72's weekend-reimplemented interpreter from the
     spec (a third provenance axis; re-bootstrap and DDC are the same
     machinery viewed twice).
  3. **Two comparison notions, kept distinct.** The *fixpoint* is
     **bit-identity of emitted artifacts** (self-compilation converges).
     *Executor admission* under E71's spec-as-golden recommendation is
     **observable conformance to the spec** (a leg is a valid executor iff it
     matches spec vectors). DDC's final compare is bit-identity again —
     cross-leg outputs of the one deterministic emitter — but a leg is only
     *entitled to sit in the quorum* by spec conformance first. Conformance
     admits the leg; bit-identity convicts the binary.
  4. **Independence is declared-and-checked, not assumed** (split-role):
     each leg carries a provenance vector (language, toolchain, author,
     epoch); the combine requires declared disjointness on the named axes.
     Honest limit: the author axis is nearly common-mode here (one author
     wrote or specified all three legs) — assertable, not attestable; name
     the rung, don't inflate it.

## 3. Conventional (other-language) approach

Binary bootstrap chains taken on faith — trust-by-archaeology:

```sh
# rustc needs rustc: every rustc was built by the previous rustc, back through
# years of binaries to an OCaml program nobody re-runs. gcc needs gcc — the
# Debian archive's build-dep loop bottoms out in binary seeds:
$ apt-get build-dep gcc     # ...which requires a gcc binary from the archive
# The seed binaries are TRUSTED, not verified. If one ancestor was trojaned
# (Thompson), every descendant is, and no amount of source auditing shows it.
```

- **Assumptions it bakes in:** the binary seed is trusted forever and never
  re-derived; builds are not deterministic, so nothing could be compared even
  if someone tried; there is no second leg (monoculture toolchains); and the
  chain is archaeology — it happened once, in history, and is not re-runnable.
  The entire trust story is "nothing bad happened in 30 years of ancestors."

## 4. The chirality idea

- **Chirality features in play:** categories (the compiler *binary* is a B
  artifact; the DDC ceremony is a C bridge holding evidence about it);
  split-role (legs = independent sources; provenance-disjointness typed;
  agreement is the verdict — this is the legitimate agreement-tier residue,
  exactly where the checker's certificate exit left it); alarms
  (divergence carries *which leg diverged from which* — rich because split);
  errors as result sums; the fixpoint's determinism pins.
- **The reframing:** DDC stops being a one-time heroic event and becomes a
  **re-runnable ceremony expressible in the language's own terms**: legs are
  processes, their provenance is data the combine checks, comparison is a
  pure fold, and the verdict is an ordinary result sum whose failure arm is a
  named alarm. Certificates (E52) and DDC are complementary, not redundant:
  certificates cover the *judgment* (this derivation is valid), DDC covers
  the *executor* (the machine that ran the judgment did not lie). Both are
  needed because a trojaned executor can emit valid-looking certificates.
- **What chirality makes impossible here:** silent divergence (the compare's
  failure arm names the leg and the artifact — an alarm, not a log line); an
  undeclared-provenance leg entering the quorum (the combine demands the
  vector, and disjointness on the named axes, before counting the vote);
  and *unrepeatable* trust — the ceremony is a program, so "was this ever
  actually checked?" has a running answer, not an archival one.

## 5. Chirality example (fleshed)

The DDC ceremony as a chirality orchestration skeleton — the shape a later
implementation copies. Pure comparison core; the leg-running is effectful
(spawn/exec is lane-A machinery) and elided.

```chirality
(import "prelude")
(import "collections")

; ---- provenance: declared, checked, never assumed (split-role) ----------
; Axes are the named ones; disjointness is checked on axes the threat names.
; Honest rung: language/toolchain are attestable-ish; author is assertable
; only (one author wrote all legs) — the combine records, not launders, that.
(data Prov ()
  (prov (language Str) (toolchain Str) (author Str) (epoch I64)))

(data Leg ()
  (leg (name Str) (p Prov)))
; the three real legs:
;   (leg "self-hosted" (prov "chirality"  "chirality-native"  "shred" 2026))  ; suspect
;   (leg "py-scaffold" (prov "python" "cpython3"      "shred" 2025))  ; prior
;   (leg "weekend"     (prov "any"    "independent"   "other" 2027))  ; E72

; ---- verdicts are values; divergence is named, not logged ----------------
(data DdcR ()
  (ddc-converged (artifact Bytes))            ; all legs emitted these bytes
  (ddc-diverged  (a Str) (b Str))             ; WHICH legs disagreed
  (ddc-bad-quorum (why Str)))                 ; provenance not disjoint / <2 legs

; a leg's run result: the bytes its execution of the one emitter produced
(data LegOut () (leg-out (l Leg) (bs Bytes)))

(declare bytes=? (-> Bytes Bytes Bool))       ; floor byte-equality ; …
(declare prov-disjoint? (-> (List Leg) Bool)) ; pairwise, on named axes ; …

; ---- the compare: a pure fold — first divergence wins, named -------------
(declare ddc-compare (-> (List LegOut) DdcR))
(def ddc-compare
  (lam (outs)
    (case outs
      ((nil) (ddc-bad-quorum "no legs"))
      ((cons first rest)
       (case first
         ((leg-out l0 bs0) (ddc-fold l0 bs0 rest)))))))

(declare ddc-fold (-> Leg Bytes (List LegOut) DdcR))
(def ddc-fold
  (lam (l0 bs0 rest)
    (case rest
      ((nil) (ddc-converged bs0))
      ((cons o more)
       (case o
         ((leg-out li bsi)
          (cond ((bytes=? bs0 bsi) (ddc-fold l0 bs0 more))
                (else (case l0 ((leg n0 p0)
                  (case li ((leg ni pi) (ddc-diverged n0 ni)))))))))))))

; ---- the fixpoint is the degenerate ceremony: one leg, run twice ---------
; stage1: self-hosted compiles the checker source. stage2: THAT output
; compiles the source again. bit-identity or the determinism debts are unpaid.
(declare fixpoint=? (-> Bytes Bytes Bool))    ; = bytes=?, named for the role

; the effectful runner (spawn each leg on the same source, collect LegOuts,
; check prov-disjoint? BEFORE comparing, raise the alarm crossing on
; ddc-diverged) is lane-A orchestration — elided here ; …
```

- **Knobs to modify:** the provenance axes (add hardware when rung-2 legs
  exist); the artifact compared (the checker binary is the load-bearing one;
  any deterministic emitter output works); quorum size and which milestones
  demand a fresh ceremony run.
- **Deliberately omitted:** the leg-running orchestration (spawn/exec — lane
  A, E33/E51); hashing (compare is whole-bytes equality — a digest is an
  optimization the floor doesn't need yet and has no prim for); the
  spec-conformance gate that *admits* a leg (E71's `conform` — cited, owned
  there).

## 6. Use / modify notes

- **Lands in:** a `tools/ddc` ceremony (chirality source once effectful lowering
  lands; a thin Python driver in the interim is acceptable *because the
  driver is not trusted* — the compare core is pure chirality and the verdict is
  re-derivable), plus the determinism pins landing wherever E8's
  canonical-form and trust-boundary's ordering/encoding debts get settled.
- **Conformance target:** the negative test is the point — inject a one-byte
  mutation into one leg's emitted artifact and the ceremony must return
  `ddc-diverged` naming that leg; run the true three-leg ceremony and it must
  return `ddc-converged` with the fixpoint also holding leg-0-twice.
- **Open questions:** whether a `ddc-converged` verdict becomes a
  *certificate* other nodes consume over Adhikara (a property-certificate
  evidence element per D4's class-3 machinery) or stays a local build-time
  fact; how the epoch axis interacts with re-runs (a re-run IS the point —
  verdicts should date, not accumulate); when the ceremony is *demanded*
  (every release? every kernel-spec change?); and the author common-mode —
  whether leg 2 must eventually be written by a genuinely different author
  for the vector to mean what it says.
- **Honest limits:** DDC detects compiler-inserted trojans; it cannot detect
  a backdoor *in the spec* — the spec is common-mode across all legs by
  construction, and that residue is handled by spec minimality plus
  certificates (split-role's honest-limits section), not by more legs.
- **Related:** E52 (certificates — the judgment half this completes), E72
  (re-bootstrap — the same climb, viewed as ownership), [[E71-golden-restructure]]
  (spec conformance admits a leg), [[E15-reference-interpreter]] (leg 1's
  core), E8 (the `repr` canonicalization debt), D7/edge 11 (the independence
  budget this mechanizes), `docs/split-role.md` (provenance vectors).
