---
element: E157
slug: typed-diagnostics
title: **Diagnostics as typed values** — a closed `Reason` sum with evidence, replacing the `str-cat`'d message inside `ld-err`/`ck-err`.
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: drafted
updated: 2026-08-23
---

# E157 — **Diagnostics as typed values** — a closed `Reason` sum with evidence, replacing the `str-cat`'d message inside `ld-err`/`ck-err`.

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E157 — give the compiler's error *outcomes* a typed *reason* that
  carries **evidence** (both sites of a redeclare, expected-vs-actual as terms,
  a binder's declared-vs-observed quantity) instead of a `str-cat`'d sentence.
- **Kind:** BUILD-PROPER.
- **Why chirality needs its own:** because the compiler *is* chirality and scriba renders
  typed values, a diagnostic here can be **navigable by construction** — jump to
  both sites, fold a chain, filter by reason — a category other languages reach
  only by bolting an IDE protocol over re-parsed strings.

**⚑ The baseline is not "nothing exists" — it is sharper than the catalog row says.**
The catalog claims the reason is a string and cites `str-cat` sites. True, but
incomplete: **a typed reason sum already exists and is thrown away at birth.**
`loader.chiral:60-73` (added by **E159**, days old) declares:

```chirality
(data XErr ()
  (x-redeclared  (n Str))
  (x-not-a-type  (n Str))
  (x-linear-pure (n Str) (r Str)))
(declare x-msg (-> XErr Str))
```

with a header comment that states the intent exactly right — *"decided ONCE at the
point of decision and rendered to a message only at the `ld-err` boundary"*. It is
then used like this, at three call sites (`:464`, `:472`, `:480`):

```chirality
((some x) (ld-err (x-msg (x-redeclared name))))
```

`x-msg` is applied **at the construction site**, not at the boundary. The sum is
built and collapsed in the same expression, so it never survives one function call.
Not because the author was careless — the comment proves the opposite — but because
the container forbids it: `(data LoadR () (ld-ok (s Sig)) (ld-err (msg Str)))`.
**The field type is the defect.** That reframes the element: the taxonomy is not
missing, it is *unable to survive*, and E157's core is widening the payload so it can.

## 2. Research

- **Reference class:** `OURS` — the two in-tree precedents plus the shape of
  structured diagnostics in production compilers.

**Key findings:**

1. **`SkReason` survives; `XErr` does not — and the only difference is the
   container's field type.** `skip-diag.chiral` (E97) keeps `(sk-extern op)` /
   `(sk-callee name)` as *values* through a blame chain, and it is what turned
   "phantom B1 bugs" into a diagnosable paren slip. `XErr` has an equally good
   taxonomy and dies immediately, because `LoadR`'s payload is `Str` while
   `SkRec`'s is a `SkReason`. This is the controlled experiment: same discipline,
   same codebase, two outcomes, one variable. **It is decisive evidence that E157
   is a field-type change, not a taxonomy-invention exercise.**

2. **Three containers flatten, not one, and they disagree with each other.**
   `loader.chiral:55` `(ld-err (msg Str))` · `loader.chiral:56` `(bad! (msg Str))` ·
   `kernel.chiral:410` `(ck-err (msg Str))`. A fourth, `tal-check.chiral:30`, declares
   **another `CkR` with the same `ck-ok`/`ck-err` constructor names** and a different
   payload (`REnv` vs `(List Qty)`). Any unification must reckon with that collision
   — it is E154's flat emitted-label namespace sitting inside the diagnostic types
   themselves, and it is the reason a single shared `Diag` type is a *decision*, not
   an obvious win.

3. **Even the existing sum loses the evidence.** `x-redeclared` carries `(n Str)` —
   the name only. At `loader.chiral:464` the incumbent `x` is bound *in the very
   pattern that detects the clash* and is discarded. Same at `:555`/`:576` for
   `data redeclared`, where `d` is in hand. The second site is never absent at the
   point of decision; it is always dropped. Carrying it costs a field.

4. **Prior art agrees on the shape and on the split.** rustc's `Diagnostic` is a
   record of a primary span plus labelled secondary spans and structured
   suggestions; GCC's `rich_location` carries multiple ranges and fix-it hints.
   Both learned the same lesson — a diagnostic is a *record with locations*, and
   its rendering is a separate, late pass. Neither can go as far as chirality can:
   their consumers still receive rendered text over a protocol, whereas here the
   consumer (scriba) is in the same language and receives the value.

## 3. Conventional (other-language) approach

The conventional compiler formats the message where the error is detected:

```python
# The shape everywhere from CPython to a hand-rolled parser: format at raise time.
def add_data_decl(sig, decl):
    prior = sig.data.get(decl.name)
    if prior is not None:
        # `prior` is RIGHT HERE -- and it is dropped into a sentence.
        raise LoadError(f"data redeclared: {decl.name}")
    ...
```

A caller that wants to be structured must then *undo* this:

```python
m = re.match(r"data redeclared: (\w+)", str(e))   # re-parsing our own message
```

- **Assumptions it bakes in:**
  - **The message is the error.** Anything not in the sentence is unrecoverable —
    `prior`'s location is in scope at the raise and gone one frame later.
  - **One rendering, chosen at the worst moment.** Width, colour, verbosity and
    audience are all decided at detection time, deep inside the checker.
  - **Consumers re-parse.** Structure is recovered by regex, or by an out-of-band
    protocol (LSP) that re-derives what the compiler already knew.
  - **Partiality as control flow.** The `raise` is an unannotated escape hatch; no
    signature says this function can fail, and no `case` forces the caller to cope.

## 4. The chirality idea

- **Chirality features in play:** boundary sums (the standing directive) · closed-sum
  exhaustive `case` · errors-as-values (no exceptions) · totality · the `->` purity
  membrane · the accessor-function discipline E97 records for B1.

- **⚑ This is a SETTLED principle, not a new argument.** `docs/error-and-alarm.md:38`
  already rules: *"An alarm here is diagnostic by construction, not a stringly
  'something went wrong.'"* E157 does not propose that — it **implements it where
  the compiler currently violates it**. Scope it precisely, though: that note and
  `banks/effect-and-alarm` §X2 are about **runtime alarms**, whose payload richness
  is the same shard as the evidence/split machinery (which copy disagreed, which
  share is bad). A **load/check-time compiler diagnostic** is a *different shard
  under the same principle* — E157 must not be described as building the alarm
  payload, which is already refracted elsewhere and would be a phantom claim.

- **The reframing.** The outcome sum was always right; the *payload* is the
  boundary that was left untyped. `Str` in `(ld-err (msg Str))` encodes
  which-of-N-things — the pattern reference's own test for "a sum wearing a
  disguise". Widen the field to a closed `Reason`, and the sum that E159 already
  wrote finally survives past its construction site. Rendering becomes a *later,
  plural* choice (`reason-msg` now, `doc->str` / `doc->rendering` once E158 lands)
  instead of a call fused into the detection.

  The taxonomy question — the reason this takes the pipeline — resolves on a
  stated line: **one constructor per EVIDENCE SHAPE, not per message.** What a
  reason *is about* varies far more than what it *carries*, so the varying part
  becomes a separate `Subject` sum and the constructors stay few. A new check
  mints a constructor only when it brings a genuinely new shape of evidence;
  otherwise it reuses one with a new `Subject`. Too coarse (`(r-other Str)`) is a
  string with extra steps; too fine (a constructor per call site) is the failure
  the catalog row warns about. This line is checkable at review time, which is
  what makes it a rule rather than taste.

- **What chirality makes impossible here.** Once `ld-err : (-> Reason LoadR)`, you
  **cannot construct a redeclaration diagnostic without both sites** — the
  constructor demands them, so dropping the incumbent stops being a style lapse
  and becomes a type error. Exhaustive `case` means adding a `Reason` arm breaks
  every renderer until each is updated: a new diagnostic cannot silently fall into
  a catch-all. And because `Reason` is pure data, every consumer that only
  inspects a diagnostic stays on the `->` side of the membrane — reading an error
  is provably not an effect.

## 5. Chirality example (fleshed)

```chirality
; diag.chiral -- E157: the compiler's diagnostics as typed values.
; E154 note: internals are `dg-` prefixed; two co-blobbed modules cannot define
; the same emitted label, and this module is imported by loader AND kernel.
(import "prelude")
(import "skip-diag")   ; SkRec -- `r-skipped` JOINS E97's chain rather than copying it
; ⚑ `Term` and `Qty` (used by r-mismatch / r-usage below) are the CHECKER's types.
;    Importing them here is what makes diag.chiral non-leaf, and it is open question
;    5 in §6: either diag imports them, or those two fields degrade to Str.

; ---- WHERE a judgment was made ---------------------------------------------
; The reader already carries a byte offset (E101 `p-err … (pos I64)`); this is
; that same coordinate KEPT rather than discarded on the way up.
(data Site () (site (unit Str) (pos I64)))

; ---- WHAT the judgment is about ---------------------------------------------
; The axis that varies most. Splitting it out is what keeps `Reason` small:
; a new kind of subject costs a `Subject` arm, not a `Reason` arm.
(data Subject ()
  (subj-data   (n Str))
  (subj-extern (n Str))
  (subj-def    (n Str))
  (subj-atom   (n Str))
  (subj-binder (n Str)))

; ---- WHY it failed: one constructor per EVIDENCE SHAPE ----------------------
; The taxonomy is keyed on what a reason CARRIES, never on what it says.
(data Reason ()
  ; a taken name: BOTH sites -- the evidence `str-cat` destroyed at loader:464/555
  (r-redeclared (what Subject) (incumbent Site) (newcomer Site))
  ; a shape disagreement, expected vs actual as TERMS -- not rendered text
  (r-mismatch   (what Subject) (expected Term) (actual Term) (at Site))
  ; a usage disagreement: what the binder promised vs what it did (kernel:313)
  (r-usage      (what Subject) (declared Qty) (observed Qty) (at Site))
  ; E159's x-linear-pure, generalised: a linear result behind an all-`->` spine
  (r-arrow      (what Subject) (result Str) (at Site))
  ; a name with no binding, PLUS the scope that was searched
  (r-unbound    (what Subject) (scope Str) (at Site))
  ; a lowering skip/prune -- E97's chain JOINED here, not copied
  (r-skipped    (chain (List SkRec))))

; ---- The containers carry the VALUE, not its rendering ----------------------
; was: (data LoadR () (ld-ok (s Sig)) (ld-err (msg Str)))       loader.chiral:55
(data LoadR () (ld-ok (s Sig)) (ld-err (why Reason)))
; was: (data ChkR () (ok!) (bad! (msg Str)))                    loader.chiral:56
(data ChkR () (ok!) (bad! (why Reason)))
; was: (data CkR () (ck-ok (use (List Qty))) (ck-err (msg Str)))  kernel.chiral:410
(data CkR () (ck-ok (use (List Qty))) (ck-err (why Reason)))

; ---- ACCESSOR-FUNCTION PATTERN (inherited from skip-diag.chiral, E97) --------
; Every `case` on Reason/Subject/Site lives inside a small accessor def, so
; callers never pattern-match these types inside case arms. This avoids the B1
; "unknown name" bug triggered by nested case patterns over newly-defined data
; types. Any new diagnostic sum inherits this constraint -- it is not optional.
(declare dg-reason-tag (-> Reason Str))
(def dg-reason-tag
  (lam (r)
    (case r
      ((r-redeclared w i n)   "redeclared")
      ((r-mismatch   w e a s) "mismatch")
      ((r-usage      w d o s) "usage")
      ((r-arrow      w x s)   "arrow")
      ((r-unbound    w c s)   "unbound")
      ((r-skipped    c)       "skipped"))))

; the sites a diagnostic points at -- what makes it NAVIGABLE in scriba.
; Plural by construction: a redeclare has two, and neither is privileged.
(declare dg-sites (-> Reason (List Site)))
(def dg-sites
  (lam (r)
    (case r
      ((r-redeclared w i n)   (cons i (cons n nil)))   ; TWO, neither privileged
      ((r-mismatch   w e a s) (cons s nil))
      ((r-usage      w d o s) (cons s nil))
      ((r-arrow      w x s)   (cons s nil))
      ((r-unbound    w c s)   (cons s nil))
      ((r-skipped    c)       nil))))                    ; a chain, not a site

; ---- Rendering is a SEPARATE, LATER, PLURAL choice --------------------------
; `x-msg` does not die -- it is RETYPED and MOVED. Same job, at the edge now
; instead of fused into detection. E158's `doc->str` / `doc->rendering` join it
; as siblings; this one stays for the plain-text exit.
(declare dg-subject-name (-> Subject Str))   ; the one accessor dg-msg leans on
(declare dg-msg (-> Reason Str))
(def dg-msg
  (lam (r)
    (case r
      ((r-redeclared w i n)
        (str-cat (dg-subject-name w) " redeclared"))     ; `str-cat` for TRIVIA is fine
      ; … one arm per constructor. NO `_` arm, on purpose: §4 claims a new
      ;   Reason must break every renderer loudly, and a catch-all here would
      ;   be exactly the silent fallback that claim forbids.
      ((r-mismatch   w e a s) (dg-mismatch-msg w e a))
      ((r-usage      w d o s) (dg-usage-msg w d o))
      ((r-arrow      w x s)   (dg-arrow-msg w x))
      ((r-unbound    w c s)   (dg-unbound-msg w c))
      ((r-skipped    c)       (dg-chain-msg c)))))

; ---- The call sites, before and after ---------------------------------------
; loader.chiral:555 -- was:
;   ((some d) (ld-err (str-cat "data redeclared: " dn)))
; `d` -- the INCUMBENT -- is bound by the very pattern that detects the clash,
; and was dropped. Now the constructor will not let it be dropped:
;   ((some d) (ld-err (r-redeclared (subj-data dn) (dg-decl-site d) here)))
;
; loader.chiral:464 -- was:
;   ((some x) (ld-err (x-msg (x-redeclared name))))
; the sum was built and collapsed in ONE expression. Now it survives:
;   ((some x) (ld-err (r-redeclared (subj-extern name) (dg-decl-site x) here)))
```

- **Knobs to modify:**
  - **`Subject` arms** — the cheap axis; adding a judged category costs one arm here.
  - **`Site`'s coordinate** — `(unit Str) (pos I64)` mirrors E101's reader offset;
    a line/column pair or a span (`start`/`end`) is a drop-in widening.
  - **Which containers convert first** — `LoadR` alone is a viable first commit;
    `ChkR`/`CkR` can follow, and the two `CkR`s need not unify to get the win.
  - **`r-mismatch`'s payload** — `Term` if the checker has one in hand, `Str` as a
    staging step if threading a term proves expensive at a given call site.

- **Deliberately omitted:**
  - **Width-aware / structured formatting** — that is E158 (`Doc`). This element
    stops at `dg-msg : (-> Reason Str)`, deliberately no better than today's text.
  - **Warnings, severities, and suggested fixes** — a severity axis is a separate
    decision; nothing in the tree emits a warning yet.
  - **`SkReason` migration** — `r-skipped` *joins* E97's chain by reference. E97
    works; rewriting it is churn this element does not need.
  - **The scriba navigation UI** — `dg-sites` is the seam that makes it possible;
    building the jump-to-site command is scriba-lane work.

## 6. Use / modify notes

- **Lands in:** a new `scaffold/lib/diag.chiral` (the shared home — `loader` and
  `kernel` both import it; neither can own it without the other importing its
  owner). Edits follow in `scaffold/lib/loader.chiral` (`:55`, `:56`, `:60-73`,
  `:428`, `:438`, `:464`, `:472`, `:480`, `:494`, `:555`, `:576`) and
  `scaffold/lib/kernel.chiral` (`:313`, `:410`).

- **Conformance target:** the **existing** diagnostics must still be produced, byte
  for byte where they are asserted — and the audit measured exactly where that is,
  because the draft overstated it. **`linear binder usage mismatch` IS a hard
  golden**, asserted literally in both floors: `test-check-cli.sh:50,54` and
  `test-linear-mint.sh:205` (native) and `test_e106_linear_cap.py:126` +
  `test_e42_supervisor.py:130,134` (oracle). **`extern redeclared` is asserted
  NOWHERE** — it is a measured runtime string, not a golden. That asymmetry is
  load-bearing for open question 3: retiring `XErr` is cheaper than the draft
  assumed, because no test pins its wording. **A behavioural gate, not a fixpoint:** a self-host
  fixpoint proves stability, not correctness, and E156 showed a gate fixture can be
  blind to its own mutant. The gate must therefore (a) reproduce each message, and
  (b) assert on the *evidence* — that a redeclare's `dg-sites` returns **two**
  sites and that they differ — since (a) alone passes with the second site dropped.

- **Open questions (for the spec to disposition, not for this run):**
  1. **Does the loader have positions at all?** `Site` assumes one. E101 gives the
     *reader* a `pos`, but `LoadR` works over elaborated `Core`/`DataDecl`, which
     may carry none. If positions are not threaded, either this element threads
     them (widening its scope considerably) or `Site` degrades to `(unit Str)` and
     "jump to both sites" waits. **This is the single biggest scoping risk and the
     spec must measure it before committing to the shape.**
  2. **One `Reason` or one per container?** `tal-check.chiral:30` and
     `kernel.chiral:410` both define `CkR` with the same constructor names and
     different payloads — E154's flat label namespace, inside the diagnostic types.
     A single shared `Diag` may be blocked until E154 lands.
  3. **Does `XErr` retire or become a `Subject`?** Its three arms map cleanly onto
     `r-redeclared` / `r-mismatch` / `r-arrow`, which argues for retirement — but it
     is days old and E159's gate asserts on its messages.
  4. **Where does `here` come from** in the call-site rewrites above — a threaded
     parameter, or a field already on the item being loaded?
  5. **Does `diag.chiral` stay below the checker?** `r-mismatch` carries `Term` and
     `r-usage` carries `Qty` — both the checker's types — so a shared `diag` module
     imports them, and `loader`/`kernel` then import `diag`. The spec must confirm
     that ordering has no cycle, or degrade those two fields to `Str` (losing
     expected-vs-actual *as types*, which is half the point of `r-mismatch`).

- **Related:** [[pattern-boundary-sums]] (the standing directive being violated) ·
  [[error-and-alarm]] (the settled *diagnostic-by-construction* rule this
  implements) · [[banks/effect-and-alarm]] (§X2 — the alarm-payload shard this must
  NOT be confused with) · [[certificate-discipline]] (evidence carried as a value
  rather than re-derived).
  *(Element refs kept as plain text, not `[[wiki]]` links: the audit found that
  `E158-doc` / `E97-skip-chain-diagnostics` / `E159-linear-mint` / `E154-label-ns` /
  `E101-sexp-error-context` have no notes, so those anchors resolved to nothing and
  the KB slice came back nearly empty.)* Elements in play: **E158** (the rendering
  half; consumes this) · **E97** (the precedent `r-skipped` joins) · **E159** (wrote
  `XErr`; the sharpest evidence for this element) · **E154** (gates the
  single-shared-type option) · **E101** (the `pos` that `Site` would carry).
