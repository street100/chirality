---
element: E97
slug: skip-chain-diagnostics
title: B1 lowering skip-chain diagnostics: accumulate `er-skip` reasons with blamed callee in `lower-defs` (compile-back.chiral:211-226); on missing entry label, report the drop chain root-first to stderr; resolve `native-prim?` (lower.chiral:143, apparently uncalled) to one documented authority or delete
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: drafted
updated: 2026-08-09
---

# E97 — B1 lowering skip-chain diagnostics: accumulate `er-skip` reasons with blamed callee in `lower-defs` (compile-back.chiral:211-226); on missing entry label, report the drop chain root-first to stderr; resolve `native-prim?` (lower.chiral:143, apparently uncalled) to one documented authority or delete

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E97, make B1's silent lowering drop *self-explaining* — when a def
  fails to lower because it (transitively) hits an op that does not lower, carry
  the reason and the blamed callee as a value, and on a missing entry label print
  the root-first blame chain to stderr instead of a bare "no emitted label".
- **Kind:** BUILD-PROPER (a designed diagnostic that does not exist yet; it does
  not change *what* lowers, only what is reported when lowering drops a def).
- **Why chirality needs its own:** the skip reason is manufactured in `lower.chiral`
  as a `Str` and then **thrown away** at `compile-back.chiral:225` — `(le-skip er)`
  recurses without recording `er`. When the entry def's whole transitive callee
  set is skipped, the *only* surviving symptom is a missing label for the entry
  (`compile-main`). That silence caused three consecutive misdiagnoses of the
  scriba blocker. The compiler must reconstruct and report its own drop, in chirality.

## 2. Research

- **Reference class:** OURS — `compile-back.chiral` (the `lower-defs` recursion and
  the entry-label gate, ~:211–226), `lower.chiral` (`le-skip` reason construction;
  `native-prim?` at :143), and the boundary comment at `tal-erase.chiral:87`. No
  Python baseline to port — this is a new diagnostic designed from the tree.
- **Key findings:**
  1. **The reason is born typed-as-string and dies unused.** `lower-defs` matches
     `(le-skip er)` and recurses *without* recording `er`; nothing downstream can
     name why a def vanished. The entry-label check at the top of the pipeline is
     the sole failure signal, and it is provenance-free.
  2. **The real drop is a *chain*, not a point.** `compile-main` is skipped only
     because it calls `command-loop`, which is skipped only because it calls
     `termios-set-raw`, which is skipped because it uses an extern (`band`) that
     op-parse rejects. Reporting requires following blame links to the leaf.
  3. **Membership-of-lowerable has two claimants.** `native-prim?` (lower.chiral:143)
     is defined but never called, while `tal-erase.chiral:87` states op-parse is
     **the** membership boundary. Two predicates for one fact is a drift hazard the
     types cannot catch. Disposition (decided here): **delete `native-prim?`** and
     fix the stale `compile-back.chiral:204` comment that alludes to it; op-parse
     stays the single authority. (Wiring it as *the* authority is rejected — an
     authority already exists; a second one only re-opens the drift.)
  4. **This is diagnostics-only.** No op newly lowers or stops lowering; the change
     is: enrich `le-skip`'s payload, thread a ledger through `lower-defs`, and walk
     it root-first on entry-label failure.

## 3. Conventional (other-language) approach

A conventional compiler (LLVM, GCC) hard-errors at the *first* unhandled construct
with a source location. The chirality codegen instead does a silent skip; the current
shape, sketched in Python, is:

```python
def lower_defs(defs):
    labels = {}
    for d in defs:
        r = lower_one(d)
        if r.ok:
            labels[d.name] = r.label
        # else: r.reason is a debug string — dropped on the floor
    return labels

# caller (the entry gate):
labels = lower_defs(defs)
if entry not in labels:
    raise CompileError(f"no emitted label for {entry}")   # provenance-free
```

- **Assumptions it bakes in:** the reason is a *debug aside*, not a value that must
  land somewhere; failure is a late control-flow `raise` at the entry gate with no
  causal chain; and "is this op lowerable?" is answered ad hoc in more than one
  place (`native-prim?` vs op-parse) with nothing keeping them agreed.

## 4. The chirality idea

- **Chirality features in play:** errors-are-values (result sums, no exceptions); a
  structurally-threaded accumulator (the ledger); totality (the blame walk is
  measure-bounded by fuel); the `->` vs `=>` membrane (writing stderr is a crossing,
  so the reporter is `=>` over a `Console` cap); single-authority discipline (op-parse
  as **the** membership boundary).
- **The reframing:** `le-skip` stops carrying a bare `Str` and carries a typed
  `SkReason` — either `sk-extern op` (a leaf: an op op-parse rejects) or
  `sk-callee name` (this def was dropped because a *def* it calls was dropped).
  `lower-defs` threads a `LowerOut` ledger (emitted labels **and** skip records) so
  the drop is a value that reaches the entry gate. On a missing entry label,
  `blame-chain` follows `sk-callee` links from the entry down to the leaf and
  reports it root-first over the Console cap, *then* returns the ordinary
  `p-err` — the failure is unchanged, but now it explains itself.
- **What chirality makes impossible here:** losing the reason to a control-flow `raise`
  — the reason is a constructor payload threaded through the return sum, so it is
  present at the gate by construction, not by remembering to log. And the second
  membership predicate is removed, so op-parse cannot silently disagree with a
  shadow. (Note: the reason value is ordinary unrestricted data — chirality does *not*
  force it to be consumed via linearity here; making `SkRec` linear to force
  every skip to be threaded-or-reported is a knob, listed below.)

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
(import "prelude")
(import "collections")   ; List, cons/nil, join

; --- Per-def lowering outcome ------------------------------------------------
; WAS: le-skip carried a bare Str reason, discarded at compile-back.chiral:225.
; NOW: the reason is typed, and names the *leaf op* or the *blamed callee def*.
(data SkReason ()
  (sk-extern (op   Str))     ; leaf: op-parse rejects this extern, e.g. "band"
  (sk-callee (name Str)))    ; propagated: a *def* this one calls was itself skipped

(data SkRec ()
  (mk-skrec (def-name Str) (why SkReason)))

(data LowerRes ()           ; result of lowering ONE def
  (le-ok   (label Str))
  (le-skip (rec SkRec)))     ; <- was (le-skip (er Str))

; --- The ledger threaded through lower-defs ----------------------------------
(data LowerOut ()
  (mk-lowerout (labels (List Str))     ; def-names that produced a label
               (skips  (List SkRec))))  ; def-names dropped, WITH blame

(declare out-add-label (-> LowerOut Str    LowerOut))
(declare out-add-skip  (-> LowerOut SkRec  LowerOut))
(declare lower-one     (-> Def LowerRes))          ; existing per-def lowering
(declare op-parse      (-> Str  (Maybe Op)))        ; tal-erase.chiral:87 — THE boundary

; --- lower-defs: the one-line drop becomes a recorded skip --------------------
(declare lower-defs (-> (List Def) LowerOut LowerOut))
(def lower-defs
  (lam (defs acc)
    (case defs
      (nil acc)
      ((cons d rest)
        (case (lower-one d)
          ((le-ok label)
            (lower-defs rest (out-add-label acc label)))
          ; WAS: (le-skip er) -> (lower-defs rest acc)   ; reason discarded!
          ((le-skip rec)
            (lower-defs rest (out-add-skip acc rec))))))))

; --- Root-first blame walk ----------------------------------------------------
; Follow sk-callee links from the entry down to the leaf extern. Total: the fuel
; measure bounds recursion even if a callee cycle sneaks in (each step -1).
(declare find-skip   (-> (List SkRec) Str (Maybe SkRec)))
(declare has-label?  (-> (List Str) Str Bool))

(declare blame-chain (-> (List SkRec) Str I64 (List Str)))
(def blame-chain
  (lam (skips name fuel)
    (if (=i fuel 0)
        (cons name nil)                        ; fuel out: stop honestly
        (case (find-skip skips name)
          (none (cons name nil))               ; not skipped -> chain tip
          ((some rec)
            (case (skrec-why rec)
              ((sk-extern op)                  ; leaf: "<name>: extern does not lower: <op>"
                (cons (leaf-label name op) nil))
              ((sk-callee callee)
                (cons name (blame-chain skips callee (- fuel 1))))))))))

; --- Reporting is a crossing: writing stderr needs the Console cap ------------
(declare eprint     (=> (1 e Console) Str Unit))
(declare leaf-label (-> Str Str Str))          ; name op -> "name: extern does not lower: op"

(declare report-drop (=> (1 e Console) (List Str) Unit))
(def report-drop
  (lam (e chain)
    ; "compile-main <- command-loop <- termios-set-raw: extern does not lower: band"
    (eprint e (join " <- " chain))))

; --- The entry gate: explain the drop, THEN fail as before -------------------
(declare emit-elf (-> LowerOut Str Bytes))
(declare compile-back (=> (1 e Console) (List Def) Str (PR Bytes)))
(def compile-back
  (lam (e defs entry)
    (let ((out (lower-defs defs (mk-lowerout nil nil))))
      (if (has-label? (lowerout-labels out) entry)
          (p-ok (emit-elf out entry) 0)
          (let ((chain (blame-chain (lowerout-skips out) entry 4096)))
            (do (report-drop e chain)
                (p-err (bcat (str->bytes "entry def not emitted: ")
                             (str->bytes entry)) 0)))))))
```

- **Knobs to modify:**
  - **Ledger scope:** record *all* skips (as above, cheap, one pass) vs only the
    entry's transitive cone. The root-first walk only reads the cone.
  - **Multi-callee blame:** here `blame-chain` follows the *first* skipped callee;
    a knob is to report *every* skipped branch (a tree, not a line).
  - **Force-consumption:** make `SkRec` linear (`(1 rec SkRec)`) so a skip must be
    threaded-or-reported, turning "reason lost" into a type error rather than a
    convention.
  - **Fuel:** the `4096` bound — raise it, or replace with a structural measure on
    a distinct-def-name set once the cone is deduped.
- **Deliberately omitted:** the byte mechanics of `emit-elf`, the real `lower-one`
  body, `op-parse`'s op table, and `join`/`leaf-label` string plumbing (`; …`).

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/compile-back.chiral` — `lower-defs` and the entry-label
  gate (~:211–226) gain the `LowerOut` ledger and `blame-chain`/`report-drop`; the
  `SkReason`/`SkRec`/`LowerOut` data can sit there or in a small `compile-diag.chiral`.
  `scaffold/lib/lower.chiral` — `le-skip` carries `SkRec` not `Str`, and **delete**
  `native-prim?` (:143, dead). `scaffold/lib/tal-erase.chiral:87` op-parse stays the
  sole membership authority; fix the stale `compile-back.chiral:204` comment.
- **Conformance target:** given the scriba entry `compile-main` whose transitive
  callees all skip, stderr shows
  `compile-main <- command-loop <- termios-set-raw: extern does not lower: band`
  *before* the `p-err`, replacing the bare "no emitted label for compile-main".
  Successful compiles emit byte-identically to today (diagnostics never touch the
  emit path).
- **Open questions:** should the report list *all* leaf branches when a def calls
  several skipped callees, or the first (as drafted)? Should the ledger dedup so
  the fuel bound can be dropped for a structural measure? Should `report-drop`
  route through the same `Console` cap the rest of the driver holds, or a dedicated
  stderr port?
- **Related:** [[E69-effectful-lowering]] [[E70-op-sum-emit]] (the lowering reach
  cluster this diagnoses).
