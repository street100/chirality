---
element: E39
slug: effect-row
title: Effect algebra / typed rows (alarms, counter-effects)
kind: BUILD-PROPER
reference_class: PAPER
ours_source: (none)
status: drafted
updated: 2026-07-22
---

# E39 — Effect algebra / typed rows (alarms, counter-effects)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.
> This example is also the **verification vehicle for the zero-new-kernel-forms
> hypothesis** of `decision-effect-facets` (2026-07-21): handler syntax must
> CPS-elaborate to ordinary linear closures, or the decision gets a dated
> amendment. Verdict: **survived, with two sharpenings** (§5).

## 1. Scope

- **Element:** E39, the effect algebra — the coarse `eff` bit grown into a
  typed row of crossings, carrying alarms and counter-effects.
- **Kind:** BUILD-PROPER.
- **Why chirality needs its own:** the settled shape (`decision-effect-facets`) is
  not any off-the-shelf effect system: the row is the *exercise* facet
  (crossings performed, inferred from the call graph) beside the *possession*
  facet (linear ports held), joined by construction; handlers are port-peer
  processes, not control-operator magic; resumption multiplicity is QTT-graded.
  No existing algebra has this split, and E26 alarms, E51 sys-linkage, and E70
  effectful lowering are all its direct customers.

## 2. Research

- **Reference class:** PAPER — algebraic effects & handlers (Koka/Frank/Eff
  lineage), row types; read for the fork they lost: multi-shot resumable
  handlers duplicate the continuation, which duplicates captured linear state —
  unsound against QTT. The settled mechanism keeps rows for *bookkeeping* and
  replaces handler magic with capability-passing (Effekt-adjacent) plus
  CPS-elaboration.
- **Key findings (load-bearing):**
  1. `decision-effect-facets`: row inferred from transitive extern crossings;
     `->` = empty row; declared bounds only at module/profile boundaries;
     row-variable seat reserved in the carrier. The mapped reshape
     (`banks/effect-and-alarm` §5a, as corrected 2026-07-22): conv keeps row
     equality; **row subsumption** lands in `subtype` (contravariant
     domains); the `on_apply`/`erased_allow` seams go boolean →
     **set-containment**; Pi position 2 bool → row. The judgment seams stay
     put — a module reshape plus one carrier field-type change (a trusted-core
     edit, reviewed as one per the decision's carrier clause), not a
     kernel-logic reshape.
  2. The continuation-quantity law ("captured linear ports ⇒ one-shot") needs
     no new rule: it *is* QTT usage accounting. Binding a closure at ω scales
     its captured usages by ω; a captured 1-Sock scaled to ω fails the
     existing check. The law is enforced at bind/apply sites for free.
  3. Resume and cancel cannot be two closures — both would capture the same
     linear inventory (double use, untypeable). One closure over a message
     sum resolves it (§5).

## 3. Conventional (other-language) approach

How this is done outside chirality — exceptions, or first-class handlers:

```python
# Python: the alarm is an exception; recovery is a catch block.
try:
    data = sock.recv(64)
except ProtocolError as e:      # signal, control-flow, recovery all fused
    sock.close()                 # cleanup is by convention, not checked
    raise SystemExit(1)          # or silently swallow — nothing stops you
```

```koka
// Koka-style handler: resumable control, resume is multi-shot by default
effect protocol { fun diverged(ev : evidence) : bytes }
with handler { fun diverged(ev) { resume(repair(ev)) } }  // may resume twice
```

- **Assumptions it bakes in:** the signal is out-of-band (droppable,
  forgettable); cleanup of held resources is convention; resumption is
  unrestricted (a second `resume` re-runs code holding already-consumed
  resources); "hung" and "diverged" are conflated; nothing says in the type
  whether recovery is possible.

## 4. The chirality idea

- **Chirality features in play:** QTT quantities & usage accounting, the two-facet
  membrane (possession + exercise), ports & capabilities, alarms-as-crossings,
  totality, result sums.
- **The reframing:** an alarm is a *crossing* on a port the process holds; the
  handler is the *process at the other end* of that port; suspending is
  building an ordinary closure over the live inventory and moving it to the
  handler; the handler answers through that closure exactly once — resume with
  a repaired value, or cancel. The elaborator CPS-transforms `raise` sites
  into closure construction + a handler crossing. **Zero new kernel term
  forms**: `data`, `case`, `lam`, application, and the existing quantity
  arithmetic carry the whole mechanism.
- **What chirality makes impossible here:** dropping an alarm (the continuation is
  linear — it must be consumed); resuming twice into consumed resources
  (usage accounting rejects ω-binding of a port-capturing closure); leaking
  the suspended inventory on the fatal path (the cancel branch must consume
  it or the closure body doesn't typecheck); "catching" non-termination
  (partiality is the totality mark, a different axis entirely).

## 5. Chirality example (fleshed)

The scenario: a receive loop mid-protocol; the stream closes unexpectedly; a
divergence alarm crosses to the handler; the handler repairs (resume) or
aborts (cancel). Direct-style source first, then the CPS elaboration the
elaborator emits — every form ordinary.

```chirality
(import "prelude")
(import "ports")

; ---- the alarm protocol (E26 ties) --------------------------------------
; Evidence carries what-diverged-from-what (rich because split).
(data DivEv () (div-ev (msg Str)))

; What a handler may send back through the continuation: exactly one of
; resume-with-repaired-value or cancel. ONE sum, because the continuation
; must be ONE closure (two closures would double-capture the inventory).
(data KontMsg ((A (type 0)))
  (k-resume (v A))       ; recoverable: continue forward from the raise site
  (k-cancel))            ; fatal: discharge the captured inventory, stop

(data Res () (res-ok (bs Bytes)) (res-halted))

; ---- the handler seat ---------------------------------------------------
; The handler is the process at the other end of this crossing. Its ONLY
; way to touch the suspended process is the linear continuation m: no other
; exit exists, so "handled exactly once" is the type, not a promise.
; The 1 on the continuation binder is part of the protocol type; a caller
; passing a port-capturing closure at any other quantity is rejected by the
; ordinary usage arithmetic (uscale), not by a new rule.
(declare handle-div
  (=> (w ev DivEv) (1 k (=> (1 m (KontMsg Bytes)) Res)) Res))

; ---- direct style (what the programmer writes; surface sugar) -----------
; (def recv-line (=> (1 s Sock) Res)
;   (case (sock-recv s 64)
;     ((recv-r bs s2)   (finish bs s2))
;     ((recv-closed s2) (raise div (div-ev "closed-mid-protocol")))))
;                        ^ raise = suspend-and-cross; s2 is live inventory

; ---- CPS elaboration (what the elaborator emits; ordinary forms only) ----
(declare finish (=> Bytes (1 s Sock) Res))

(def recv-line-cps
  (=> (1 s Sock) Res)
  (lam (s)
    (case (sock-recv s 64)
      ((recv-r bs s2) (finish bs s2))
      ((recv-closed s2)
       ; the raise site becomes: build the one-shot continuation and cross.
       ; The lam captures linear s2 — QTT usage accounting therefore forces
       ; this closure to be consumed exactly once (the graded-continuation
       ; law, for free). The k-cancel branch is SYNTHESIZED by the
       ; elaborator from the capture set it just closed over: it knows the
       ; inventory is {s2 : Sock} and Sock's discharge crossing is
       ; sock-close, so the branch is the close sequence + the fatal result.
       (handle-div (div-ev "closed-mid-protocol")
         (lam (m)
           (case m
             ((k-resume bs2) (finish bs2 s2))     ; forward-only resume
             ((k-cancel)                          ; synthesized cancel branch
              (let ((u (sock-close s2)))
                res-halted)))))))))

; A multi-shot handler needs no special case: a continuation whose capture
; set holds no ports is an ordinary w-closure; binding it unrestricted
; scales only w-usages, which succeed. Backtracking survives untouched.
```

- **The hypothesis verdict (the point of this example):** **survived** —
  every construct above is existing surface (`data`/`case`/`lam`/apply +
  quantities); no delimited-control primitive, no `handle` core form, no new
  kernel rule. Two sharpenings the implementation must honor:
  1. **The law lives in the accounting, not the types.** A closure's type
     (`(=> (1 m (KontMsg A)) Res)`) does not record that it captured a port —
     the linear-kind hook cannot see capture. Soundness comes from the
     *bind/apply-site* usage arithmetic (ω-binding a port-capturing closure
     fails uscale). Consequence: alarm-protocol externs must declare their
     continuation parameters at quantity 1 by convention; the checker
     enforces it against violators at the call site.
  2. **Synthesized cancel is a branch, not a function.** Resume/cancel as two
     values would double-capture the inventory. The continuation is one
     linear closure over a `KontMsg` sum; the elaborator synthesizes the
     `k-cancel` branch from its elaboration-time capture set, closing each
     captured port via its porttype's declared discharge crossing. The
     branch's own crossings appear in the row honestly.
- **Knobs to modify:** the evidence payload (`DivEv`), the resume type `A`,
  the result sum, the discharge crossing per porttype, which crossings count
  as raise sites.
- **Deliberately omitted:** the concrete row *representation* on the Pi
  (set-of-crossing-names vs porttype-keyed — an implementation decision this
  example does not preempt); grade interaction (E38); cross-node alarm
  mobility (continuations move within a node only — edge 17 carries only
  evidence across).

## 6. Use / modify notes

- **Lands in:** the E39 reshape mapped in `banks/effect-and-alarm` §5a (as
  corrected 2026-07-22) — `terms.py` Pi position-2 field bool → row;
  `kernel.py` conv keeps equality, row subsumption in `subtype`
  (contravariant domains); `effects.py` `on_apply`/`erased_allow`
  boolean → set-containment; `surface.py` per-arrow attachment. [SPEC
  supersedes 2026-07-22: the `with-handler`/`raise` sugar elaborating to the
  CPS shape above is **E26's**, not part of this reshape — the elaborator is
  an untrusted producer and the kernel only ever sees the ordinary forms, so
  it rides after the carrier edit; `E39-effect-row-SPEC.md` §1 non-goals.]
- **Conformance target:** every existing membrane test stays green with the
  bit read as the empty/nonempty projection of the row; the tomodachi alarm
  paths (close-what-you-hold-and-halt) re-derive as instances of the
  synthesized cancel branch.
- **Open questions — now dispositioned by `E39-effect-row-SPEC.md` §3
  (2026-07-22; the SPEC is authoritative):** the row representation →
  RESOLVED, set-of-crossing-names with sorted-tuple canonical form
  (disposition a); **recoverable-vs-fatal in the type** → RESOLVED, and it is
  **not a row-entry shape**: the row names the crossing, and the crossing's
  handler extern signature carries the `KontMsg` sum — fatal-only offers
  `k-cancel` alone, recoverable offers both; `data`/`case` enforce it
  structurally (disposition b); declared-row syntax at module/profile
  boundaries → DEFERRED to E51 (disposition c); row-variable surface →
  reserved seat, unpopulated.
- **Related:** E26 (alarms ride this), E51 (threads the row through the sys
  seam), E70 (lowers it), E12 (the seams being reshaped), E38 (grade seats
  beside the row seat).
