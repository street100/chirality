---
element: E26
slug: alarm-control-flow
title: Alarms / control flow (exceptions-as-control-flow is a crutch)
kind: REPLACE-CRUTCH
reference_class: PAPER
ours_source: scaffold/chirality/alarms.py
status: drafted
updated: 2026-07-22
---

# E26 — Alarms / control flow (exceptions-as-control-flow is a crutch)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E26, the alarm machinery — how a chirality program signals that a
  computation diverged (`MetisExit` for a deliberate process exit, `MetisHalt`
  for a fatal internal alarm, `PortError` for a protocol violation) without the
  CPython exception mechanism doing the plumbing.
- **Kind:** REPLACE-CRUTCH. `scaffold/chirality/alarms.py` leans on Python's
  `Exception` class hierarchy and its `raise`/unwind machinery. That unwind is
  an untyped, ambient, non-local control-flow escape hatch that chirality cannot
  keep once it self-hosts. **Build-state note (audit-added 2026-08-01):** the
  gate this element sat behind has PARTLY opened — **E39 steps 1–6 are BUILT
  (2026-07-28)**: the effect row is live on the Pi seat (call-graph-inferred,
  containment-gated, subtype row-subsumption), so E26 is **unblocked at the row
  level and is "the next construction"** ([[error-and-alarm]]). The handler
  machinery / row subtraction explicitly **rides E26** (the E39 map row). The
  fatal tier's `Exit`-port gating below is the **E80 reification class**:
  today `halt`/`exit` are ambient externs (`lib/ports/process.port:13-14`, the same
  named-violation class as `env-get`); the grant-to-`main` delivery lands with
  E80.
- **Why chirality needs its own:** shed the CPython crutch. In chirality an alarm is not
  a stack-unwinding side channel — it is either a **value** the caller must
  `case` on (recoverable divergence) or a **single top-level effect** performed
  through a held port (fatal halt). The error path has to appear in the type, so
  `raise` — which is invisible to a signature — has to go.

## 2. Research

- **Reference class:** PAPER — algebraic effects & handlers (Koka's `effect`/
  `handler`, Frank's abilities, Eff's operations). The catalog ties this to E12
  and edge 16 (the effect membrane). The grounding OURS is the three-exception
  docstring in `alarms.py` and `docs/error-and-alarm.md`'s "halt counter effect".
- **Key findings** (mechanism settled 2026-07-21, `decision-effect-facets` —
  the open-fork framing this element used to carry is resolved):
  1. Algebraic effects split "what can go wrong" into a **declared operation
     signature** and a **handler** that decides the continuation — the exact
     opposite of `raise`, where the signature says nothing and the nearest
     `except` wins ambiently. chirality takes the *signature-visible* half
     wholesale: an alarm and its counter-effect are **crossings in the effect
     row** (the `halt`/`exit` extern precedent; per the dated amendment in
     `decision-graded-kernel`, alarms are NOT modality-mates of partiality —
     partiality stands alone in the totality modality). For plain recoverable
     errors no handler machinery is needed at all: those are result sums,
     decided at the `case`, no dynamic handler search.
  2. Where a handler IS needed, the settled shape is: **handler = the process
     at the other end of the port**; handler syntax CPS-elaborates to ordinary
     linear closures (zero new kernel forms — E39's verification target), and
     **resumption multiplicity is the captured continuation's QTT quantity**:
     captured linear ports ⇒ quantity 1, one-shot (Koka's `final ctl` case is
     the forced case here, not a style choice); port-free capture ⇒ ω,
     multi-shot legal. Abort discharges by **synthesized cancel** — elaboration
     emits the closes of the captured inventory (each porttype names its
     discharge crossing), checked by ordinary linearity.
  3. Handlers give an effect a **denotation without ambient authority** — an op
     only fires if its ability/port is in scope. That is our capability rule:
     `MetisExit` becomes a `(=> (1 e Exit) ...)` process that must *hold* the
     exit port; a pure `->` function provably cannot halt the program.
  4. Totality (the whole tree is structurally recursive) means "ran out of
     input" is a returned `*-err`, never a throw or a hang — so the recoverable
     tier needs no unwinding primitive at all.

## 3. Conventional (other-language) approach

The OURS baseline: three subclasses of Python's `Exception`, signalled with
`raise` and caught with `try/except` somewhere up the stack.

```python
class MetisExit(Exception):
    def __init__(self, code):
        super().__init__(f"exit {code}")
        self.code = code

class MetisHalt(Exception):    # fatal alarm, message says what diverged
    ...
class PortError(Exception):    # a port op diverged from its protocol
    ...

def read_frame(sock):
    hdr = sock.recv(4)
    if len(hdr) != 4:
        raise PortError("short header")   # invisible non-local jump
    ...
```

- **Assumptions it bakes in:**
  - **Untyped effects / invisible control flow** — `read_frame`'s signature is
    silent about `PortError`; any caller anywhere can (or can forget to) catch
    it. The failure path is not in the type.
  - **Ambient authority to halt** — `raise MetisExit(1)` works from any function,
    pure-looking or not. Nothing had to hold an exit capability.
  - **Non-local unwind** — `raise` skips arbitrary frames; there is no proof the
    program terminates or that resources on the skipped frames were released.
  - **Partiality** — a function "returns an int or explodes"; the type says int.

## 4. The chirality idea

- **Chirality features in play:** the `->` vs `=>` effect membrane; ports &
  capabilities (no ambient authority); errors-as-values result sums; totality;
  QTT linearity on the exit port.
- **The reframing:** alarms split into two tiers.
  - **Recoverable** (was `PortError`, parse failure): the op returns an explicit
    result sum. `read-frame : (=> (1 s Sock) (FrameR))` where
    `(data FrameR () (fr-ok (v Frame)) (fr-err (msg Str)))`. The caller *must*
    `case`; the error path is in the signature. No handler, no unwind — the
    `case` is the "handler", decided statically.
  - **Fatal** (was `MetisHalt`/`MetisExit`): a single abortive effect at the
    top, performed by holding a linear `Exit` port granted only to `main`.
    `halt : (=> (1 e Exit) (I64) Never)`. It is *performed*, not *raised*, and
    only code that was handed the port can perform it.
- **What chirality makes impossible here:** a pure `->` function cannot halt, exit,
  or signal a port error — it holds no port, and the membrane is a typed fact.
  A caller cannot silently ignore a recoverable alarm — `case` coverage is
  checked. There is no `try/except`: no ambient catch, no non-local jump, no
  partiality hidden behind a total-looking return type.
- **Where this sits in the settled algebra:** both tiers are the *exercise*
  facet of `decision-effect-facets` — a fatal alarm is a crossing in the
  effect row, its counter-effect is a crossing, and the alarm payload is rich
  by construction (it carries *what diverged from what* — the split feeds it,
  `docs/error-and-alarm.md`). Recoverable-vs-fatal *in the type*: the
  **mechanism** is settled (the `KontMsg` constructor offering — both
  `k-resume`/`k-cancel` = recoverable, `k-cancel` alone = fatal — discharged in
  the E39 SPEC disposition), and it **lands with E26** on top of the built row
  ("the first thing the row makes representable" — [[banks/effect-and-alarm]]
  Shard 5).

## 5. Chirality example (fleshed)

```chirality
(import "prelude")

; --- recoverable tier: alarms are values, not throws -------------------
; What used to be `raise PortError(...)` is a variant the caller must handle.
(data FrameR ((0 A (type 0)))
  (fr-ok  (v A))                 ; protocol held, here is the frame
  (fr-err (msg Str) (pos I64)))  ; diverged — reason + offset, in the TYPE

; Reading crosses the membrane (holds a Sock), so it is a `=>` process.
; The error path is visible in the return type; no exception can escape.
; LINEARITY (the E29 lesson — error arms must be linearity-correct): `recv`
; CONSUMES the 1-bound sock; on success the result threads a live sock back
; (the RecvR pattern, ports.chiral), on failure the sock was consumed by the
; divergence — so `s` is never touched again after the call, in either arm.
(declare read-frame (=> (1 s Sock) (FrameR Bytes)))  ; result type is an application, args are bare
(def read-frame
  (lam (s)
    (case (recv s (the I64 4))
      ((rc-ok hdr s2)  (read-body s2 hdr))  ; header ok -> continue on the THREADED sock
      ((rc-err e p)    (fr-err e p)))))     ; short/again -> value, not throw; sock consumed
; recv / read-body / dispatch / log-drop / boot: elided helpers (recv returns
; (rc-ok (hdr Bytes) (1 s Sock)) | (rc-err (msg Str) (pos I64))) ; …

; The caller is FORCED to case-split; forgetting the err arm won't compile.
(declare handle (=> (1 s Sock) Unit))
(def handle
  (lam (s)
    (case (read-frame s)
      ((fr-ok f)     (dispatch f))
      ((fr-err m p)  (log-drop m p)))))     ; recover locally, keep going

; --- fatal tier: a halt is a PORT, held only by main ------------------
; `Exit` is a linear capability. `Never` = this call does not return.
; A `->` pure function CANNOT call this: it holds no `Exit`.
(declare halt (=> (1 e Exit) I64 Never))

(declare main (=> (1 e Exit) Unit))
(def main
  (lam (e)
    (case (boot)
      ((b-ok st)  (serve st))
      ((b-err c)  (halt e c)))))            ; deliberate exit, authority in hand
```

- **Knobs to modify:** the payload type param `(0 A (type 0))` of `FrameR`; the
  error payload (swap `(msg Str) (pos I64)` for a refined code
  `(refine I64 (>= 0) (< 256))`); whether `Exit` is a distinct port or folded
  into the process's root capability; add a `fr-again` variant for a retryable
  (vs terminal) recoverable alarm.
- **Deliberately omitted:** the `recv` primitive's own signature, the byte-loop
  inside `read-body` (elided `; …`), and the handler/continuation machinery —
  for the value tier the `case` *is* the handler; the port-peer handler shape
  (CPS-elaborated linear closures, QTT-graded resumption, synthesized cancel —
  `decision-effect-facets`) is real but out of this element's scope: E26 is
  the crutch replacement, E39 owns the row/handler machinery.

## 6. Use / modify notes

- **Lands in:** replaces `scaffold/chirality/alarms.py`. The recoverable tier becomes
  result-sum `data` decls in `lib/` (near the port/`Sock` protocol types); the
  fatal tier becomes the `Exit` port type + a `halt` primitive threaded from
  `main`. `TRUE/FALSE/UNIT/mbool` migrate to the prelude as plain `con` values.
- **Conformance target:** reproduce the three OURS behaviors — (a) a deliberate
  exit with an `I64` code (`MetisExit.code`), (b) a fatal alarm carrying a
  "what diverged" message (`MetisHalt`), (c) a port-protocol divergence
  (`PortError`) — but with (a)/(b) as a held-`Exit` effect and (c) as a returned
  `fr-err` that the caller must `case` on. No `try/except` anywhere.
- **Open questions:** does `Never` need first-class bottom-type support in the
  kernel, or is it a 0-ctor `data`? Is `Exit` one global linear port or one per
  process zone (the grant-*delivery* shape is E80's; the port-shape choice is
  this element's)? Should `halt`'s message be `Str` or a structured alarm record so
  the top-level logger can format it without parsing? Which discharge crossing
  does each alarm-relevant porttype name (Sock → `sock-close`, Pool →
  `pool-close`) so synthesized cancel can close an aborted path's inventory?
- **Related:** [[E12-effect-membrane]] (the `->`/`=>` wall this rides on),
  [[E09-refinement]] (refined error codes), E39 (the effect row + handler
  machinery this tier plugs into; recoverable-vs-fatal in the type lands
  there), and `decision-effect-facets` (edge 16, resolved 2026-07-21).
