---
node: banks/effect-and-alarm
layer: bank
tier: depth
related: [error-and-alarm, decision-graded-kernel, decision-effect-facets, open-edges, totality, vocabulary, glossary, status-ledger, banks/module, banks/profile, banks/runtime, banks/capability, banks/evidence-and-split, modules-broker, permission-model]
status: draft
updated: 2026-09-04
---

# Bank: effect-and-alarm

> **What a bank is.** The depth tier under the thin relational notes in `docs/`.
> A bank holds the full refraction of ONE concept: what it is, the shards it
> decomposes into with their principled homes and honest build-state, the
> cross-cuts where one of its shards *is* a shard of another concept, and the
> native monoliths it gets mistaken for. Thin notes ([[error-and-alarm]],
> [[decision-graded-kernel]]) link *into* here.
>
> **Why this bank exists — and why precision matters most here.** This is the
> **most cross-cutting concept in the language.** Three other banks refract
> *into* it independently: [[banks/module]] sends **revocation** here (a revoked
> port dies, the next crossing raises an alarm), [[banks/profile]] sends the
> **`(total)` clause** here (partiality is one effect on this membrane), and
> [[banks/runtime]] sends the **supervisor** here (the broker's revoke *is* a
> counter-effect). The effect membrane, the alarm, and the counter-effect are
> **one algebra**, and the genuinely-new shard — the mechanism that carries that
> algebra (edge 16 / E39) — was an **undecided author call** ([[DECISION-DOCKET]]
> D1) when this bank was written. **Resolved 2026-07-21:**
> [[decision-effect-facets]] — two facets (possession + exercise) joined by
> construction; handlers as the process at the other end of the port; resumption
> multiplicity graded by the continuation's QTT quantity; synthesized cancel;
> alarms are crossings (dated amendment in [[decision-graded-kernel]]). §5a is
> retained as the decision's input record — its evidence held. Build-state below is AUTHORITATIVE from
> [[status-ledger]] and `records/conformance-map.md`; where a facet is a
> Python crutch or docs-only, it is named as such, never rounded to built.

---

## 1. The concept in chirality

**The pinned truth.** An **alarm** is "a detected divergence, raised as a typed
effect, carrying what diverged from what" ([[glossary]]). A **counter-effect** is
"the effect that answers an alarm: re-key, re-derive, relocate, repair from
survivors, quarantine, halt" ([[glossary]]). The membrane is the surface these
effects live on. The one sentence that fuses all three: **a divergence is the
alarm, and the alarm is an effect answered by a counter-effect — the whole
detection-to-response loop is, at the language level, effect → counter-effect**
([[error-and-alarm]]).

Sharpened, the concept is a single algebra with three faces:

1. **The membrane** — the typed surface across which a process may affect the
   world at all. Every crossing is named in the type (P3, P4); compute is inert
   until it crosses.
2. **The alarm** — a *divergence detected on the membrane*, itself raised as a
   typed effect (not an out-of-band exception, not a silent failure). "Named in
   the type, and total: every way a thing can signal *this does not match the
   rest* is in the type, and code cannot drop an alarm without the drop showing
   in its type" ([[error-and-alarm]]).
3. **The counter-effect** — the *response*, itself an effect, drawn from a
   **named finite set** (re-key / re-derive / relocate / repair-from-survivors /
   quarantine / halt). Whether the response can **restore agreement** is
   **recoverable**; where it cannot, the counter-effect is halt or quarantine —
   **and which it is lives in the type**, so a fatal divergence cannot be
   silently treated as recoverable.

**What it IS.** One effect algebra riding the membrane: the coarse pure-vs-process
distinction is the built floor of it (the `eff` bit), the alarm is a divergence
lifted onto that same algebra, the counter-effect is the handler drawn from a
named set, and recoverable-vs-fatal is a fact *in the type* of the counter-effect.
Crucially, **partiality (non-termination) is one more effect beside the alarm and
the counter-effects** — it lives in the **totality modality**, not on the coeffect
grade ([[decision-graded-kernel]] item 2; §3).

**What it IS NOT.** Not an out-of-band exception channel. Not a silent failure /
error code you may forget to check. Not a control-flow escape hatch. Not
"something went wrong" as a string. And — the load-bearing negation —
**divergence is NOT the same axis as non-termination.** "`totality` governs
whether a process *ends*; an alarm governs whether what it produced or read
*agrees* with the rest. Different effects" ([[error-and-alarm]]). A conventional
`try/catch` fuses these; chirality deliberately un-fuses them (§4).

**How it is realized in code (evidence).** The `eff` bit is BUILT and CONFORMS
(E12). It rides the Pi as a **`Seat`**: `(t-pi (q Qty) (s Seat) (dom Term)
(cod Term))` with `(data Seat () (s-pure) (s-proc))`, both at
`lib/surface/syntax.chiral:21` and `:12`. It is **part of type
identity**: conv rejects two Pis whose seats differ, `(and (seat= s s2) …)` at
`lib/typing/kernel.chiral:715`, whose own comment reads "seat part of =", with
`seat=` at `:559`. The loader turns the parsed bit into the seat, `eff->seat`
(`lib/module/loader.chiral:19`) — so `->` is a pure arrow (`s-pure`) and `=>` an
effectful one (`s-proc`). The kernel *carries* this annotation structurally but does **not**
interpret it: meaning is decided in the `effects` module (Shard 2). ⚑ The alarm and
counter-effect faces are **not** on this algebra. What Shard 3 described, the
Python host exceptions of `alarms.py`, has **no live referent**; what remains is
the single `halt` extern, `(extern halt (-> (0 A (type 0)) (=> Str A)))` at
`lib/ports/process.port:14` (Shard 4). That gap is the honest residue (§5).

---

## 2. The refraction — the shards, their homes, their build-state

Build-state is authoritative from `records/conformance-map.md` (rows B/E12,
B/E39, B/E26) and [[status-ledger]].

### Shard 1 — the `eff` bit (the coarse membrane, carried) · **EXTEND (E12/E171)**
- **What.** The pure `->` vs process `=>` distinction: one bit saying whether a
  crossing may affect the world. This is the effect algebra collapsed to two
  points — the built floor everything else enriches.
- **Home.** the kernel *carries* it (Pi position 2, type-identity in conv); the
  `effects` module *interprets* it (Shard 2). "Built, matches scope; eff bit
  rides Pi pos 2, membrane in module not kernel" (CONFORMANCE-MAP B/E12).
- **Build-state.** ⚑ **Corrected 2026-08-25 (was `CONFORMS`, "no work owed within
  the coarse-bit scope").** The bit is *carried* — the `Seat` in the Pi
  (`lib/surface/syntax.chiral:21`), compared in conv by `seat=`
  (`lib/typing/kernel.chiral:715`, `:559`), attached by `eff->seat`
  (`lib/module/loader.chiral:19`), and read by
  `ty-crosses` (`lib/typing/kernel.chiral:315`) and the sheet-crossings
  readers. It is *refused* nowhere in the
  compiler that compiles everything: see Shard 2 and §5d. Work IS owed within the
  coarse-bit scope and its home is **E171**; the upgrade to a full algebra remains
  separate (E39, Shard 5).

### Shard 2 — the membrane seams (native, and reached by nothing) · **EXTEND (E12/E171)**
- **What.** The kernel carries the annotation; the *module* decides what it
  permits, at **exactly three judgment points**, all three now in this tree:
  - `on-apply-ok` (`lib/typing/effects.chiral:35`) — "may this application happen
    here": the callee's row must be contained in the context's permitted row,
    `(row-sub callee here)`;
  - `on-binder-ok` (`:44`) — "may a value of this type be bound at
    this quantity": a linear type binds only at `q1`, the port-linearity seam;
  - `erased-allow` (`:39`) — "what may run inside a quantity-0 position": a
    `q0` position is mapped to the empty row.
- **Home.** `lib/typing/effects.chiral` (category A port algebra), whose header
  states the split: "The membrane only GATES -- it interprets nothing" (`:5-6`).
  The generalization from the oracle's one-bit lattice to set-containment over the
  effect row is stated in the same header (`:1-3`).
- **Build-state.** ⚑ **EXTEND, corrected 2026-08-25 (was `CONFORMS`).** The **seam
  architecture** is right and is why the E39 upgrade is a module reshape, not a
  kernel reshape (§5) — the same kernel-carries / module-interprets split the whole
  language uses (P1). ⚑ **Re-measured 2026-09-04, and the 2026-08-25 reading is
  superseded:** the seams are no longer oracle-only. All three are native, at
  `lib/typing/effects.chiral:35`, `:39` and `:44`. What stays true is the part that
  mattered: **nothing calls them.** [[status-ledger]]'s Effects row measures the
  three as having no caller anywhere in the tree, and the module's only two
  importers, `lib/typing/row-infer.chiral:16` and
  `lib/lowering/upper/eff-lower.chiral:21`, take `row-join`, `row-sub` and
  `mem-str` and nothing else. The kernel names the absence in its own comments,
  `lib/typing/kernel.chiral:898` *"No allow_eff/erased_allow/on_binder -- the
  row/membrane layer is E12, kept as the seat"* and `:14-15` listing the membrane
  seams among what E12 still owes. So it is a pure row algebra nothing in the
  checker calls, and what E171 owes is the **caller**, not the rules. Measured, not
  inferred: §5d. Home for the extension: **E171**.

### Shard 3 — the alarm (a divergence as a typed effect) · **BUILD (and the crutch is gone too)**
- **What.** A detected divergence raised as a typed effect on the membrane,
  named in the type, total, carrying what-diverged-from-what. "An unnamed failure
  path would be the gap" ([[error-and-alarm]]).
- **Home.** the `effects` membrane (the effect row it would be named in — E39) +
  the detection sites (the inbound port check, custody, tier ladder). The *design*
  home is a typed effect.
- **Build-state.** **BUILD (E26), size M.** ⚑ **Re-measured 2026-09-04: the
  crutch this row described has no live referent.** `alarms.py` and its
  `MetisExit`, `MetisHalt` and `PortError` went with the Python oracle, and so did
  the `bridge.verify` tag-check that raised the last of them
  ([[banks/port]] Shard 4). CONFORMANCE-MAP B/E26 still reads "Python host
  exceptions … no effect row / no handler machinery … Python exceptions are floor
  plumbing to replace. **Hard-gated on E39** (its effect row); sequence after
  E39"; the "plumbing to replace" half is spent and the gate is unchanged. So the
  *thesis* ("an alarm is an effect") is stated, the crutch is gone, and what is
  live is `lib/runtime/supervisor.chiral`, where "an alarm is a CROSSING, not an
  ambient signal" (`:9`) over the coarse `=>` bit. The alarm is still not on the
  algebra.

### Shard 4 — the counter-effect (the named response set) · **partially built (halt only)**
- **What.** The handler for an alarm, itself an effect, drawn from a **named
  set**: re-key, re-derive from the register root, relocate, repair from
  survivors (robust decoding corrects *t* bad shares), quarantine the diverged
  source, halt ([[error-and-alarm]], [[glossary]]).
- **Home.** the effect row that names them (E39) + the modules that *perform*
  them: repair-from-survivors lives in the **split** (custody / [[banks/evidence-and-split]]),
  re-derive in register-root custody ([[banks/runtime]] Shard D/F), quarantine and
  halt in the broker/supervisor ([[modules-broker]]).
- **Build-state.** **Only `halt` is realized, and only as a bare extern.**
  `(extern halt (-> (0 A (type 0)) (=> Str A)))` at `lib/ports/process.port:14`,
  whose registry says "exit is the clean end, halt is the fatal alarm counter
  effect" (`:7`). It is an ordinary declared crossing and nothing special-cases
  it. ⚑ The runtime response this row named, raising `MetisHalt`, has no live
  referent. The *other* counter-effects (re-key / re-derive / relocate /
  repair / quarantine) have **no handler machinery** — they are named in the
  design and performed, where at all, by modules that are themselves mostly
  designed (custody redundancy BUILD, broker grant/revoke/audit DESIGNED —
  CONFORMANCE-MAP D). The counter-effect *set* is named; the *dispatch* is E26,
  gated on E39.

### Shard 5 — recoverable-vs-fatal in the type · **DESIGN, unbuilt (rides E39)**
- **What.** "Whether an alarm is recoverable is whether a counter-effect can
  restore agreement … The type says which, so a fatal divergence cannot be
  silently treated as recoverable" ([[error-and-alarm]]). This is the payoff of
  putting alarms on the algebra: recoverability is a *typed* fact, not a runtime
  guess.
- **Home.** the alarm's **protocol type**, not a row-entry shape: the row names
  the crossing; the crossing's handler signature carries a `KontMsg` sum
  (`k-resume v | k-cancel`), and offering **both** constructors means recoverable
  while `k-cancel` **alone** means fatal — `data`/`case` enforce it structurally,
  no new carrier field ([[decision-effect-facets]], direction found 2026-07-22
  in the E39 example, discharged by the E39 SPEC disposition recorded there).
- **Build-state.** DESIGN. This fact **cannot be represented** until the effect
  algebra exists (the coarse `eff` bool has no room for it). The D1 resolution
  fixed its mechanism (the constructor offering, above); it lands with E26 on
  top of the E39 row (specced, unbuilt — §5b).

### Shard 6 — partiality as one effect (the totality modality) · **CONFORMS as classified · EXTEND to enforce**
- **What.** Non-termination is **one effect beside the alarm and the
  counter-effects** — but it does **not** ride the coeffect grade. The settled
  graded-kernel decision places it in the **totality MODALITY**: "A property, not
  a grade: totality … the mark is a tracked modality, and it is the home of the
  effect algebra of edge 16 (partiality is one effect beside the alarm and
  counter effects)" ([[decision-graded-kernel]] item 2).
- **Home.** the totality modality ([[totality]]) — partiality's home **alone**
  since the amendment; the E39 effect algebra lives in the row seat *beside* it
  on the same Pi carrier, not in this modality. **Neither is a coeffect grade**:
  the decision explicitly refuses to force termination into the coeffect semiring
  ("termination is not a resource that scales"; [[decision-graded-kernel]] "Why
  this resolves it"). **Amended 2026-07-21:** alarms moved OUT of this modality —
  they are crossings in the effect row ([[decision-effect-facets]]); partiality
  stands alone here. The shared-home wording survives only inside the quoted
  pre-amendment item-2 text above.
- **Build-state.** All three totality pillars (positivity, coverage,
  structural+numeric termination) are BUILT and *classifying* into
  `sig.totality`; enforcement is on-demand (`sig.require_total` / the profile
  `(total)` clause) and **default-OFF** (CONFORMANCE-MAP A/E11 EXTEND, gated on
  E47 sized types + E50 mutual/lexicographic). See [[totality]]; do not
  re-document it here — the point *for this bank* is only that partiality is the
  alarm algebra's *neighbor seat* on the carrier: one more effect beside the row,
  no longer its housemate.

---

## 3. Cross-cuts — where a shard of effect/alarm IS a shard of another concept

This is the highest-value section: the concept is the convergence point of the
whole language, so nearly every governance concept lands one shard *here*.

**X1 · The alarm IS the terminus of revocation ([[banks/module]] C1, [[banks/runtime]] Shard D).**
Revocation is *not* a capability feature and *not* a module feature — it refracts
*into this bank*. A revoked linear port becomes a **dead port** in a module's
membrane; the **next crossing raises an alarm**, answered by a **counter-effect**
(quarantine / halt / re-derive), **mediated by the broker/supervisor**
([[permission-model]], [[modules-broker]]). "The runtime does not police at
runtime; it arranges that the *type* of the next crossing carries the failure"
([[banks/runtime]] §3). So the broker's *revoke* IS a counter-effect on this
membrane — same shard, two names. Build-state of the chain: broker
grant/revoke/audit DESIGNED (E43, edge-8 gated), so the revocation→alarm chain is
a *design* chain today, with only port death + `halt` realized.

**X2 · The alarm is "rich because everything is split" ([[banks/evidence-and-split]]).**
An alarm is diagnostic *by construction*, not by convention, and the reason is the
split. "Because the design splits every truth (T1 copies compared, T3 verifiable
split, the C bridges, the audit trail), a divergence is never opaque … the alarm
it raises carries what diverged from what: which copy disagreed (T1), which share
is bad, which MAC failed" ([[error-and-alarm]]). So the alarm's *payload richness*
is the same shard as the evidence/split machinery: the matching logic runs over
the full cross-checked set, and **that detail is the material a counter-effect
works with** (repair-from-survivors *needs* to know which share is bad). The
"repair from survivors" counter-effect and the split are two ends of one
operation — recovery material lives in the **split**, not in a handler (this is
load-bearing for the D1 fork; §5).

**X3 · the seat and `q` both ride the Pi, both are type-identity.** The `Seat`
and the QTT quantity are *siblings* in the same constructor,
`(t-pi (q Qty) (s Seat) (dom Term) (cod Term))`
(`lib/surface/syntax.chiral:21`), and conv rejects a mismatch in *either*
(`lib/typing/kernel.chiral:715`). But they are **different
kinds of thing** and go to different homes: `q` is a **coeffect grade** (it scales
under substitution, adds under sequencing — [[decision-graded-kernel]] item 1),
while `eff` is the seed of the **effect row** — the exercise facet of
[[decision-effect-facets]] (pre-amendment this read "a modality"; the 2026-07-21
amendment moved the algebra out of the modality, leaving partiality there). They
share a carrier slot and a type-identity discipline; they do **not** share an
algebra. Conflating them is the category error the graded-kernel decision exists
to prevent.

**X4 · Partiality ↔ the totality modality (Shard 6).** The `(total)` demand
lives in the totality modality; the alarm, since the 2026-07-21 amendment, lives
in the effect row — separate seats on the same carrier, no longer one modality
([[decision-effect-facets]]). The cross-cut survives at the carrier: a `q=0`
(erased) position requires empty row **and** total, so the two facets are checked
side by side. This is why [[banks/profile]]'s **`(total)` clause is a customer of
this bank**: the clause does not *implement* anything; it *demands* the totality
property beside the row the alarm algebra inhabits. "The profile is a customer of
the totality checker, exactly as revocation is a customer of the alarm system"
([[banks/profile]] §3). Two profile-side customers, one membrane.

**X5 · The supervisor IS the counter-effect dispatcher ([[banks/runtime]] Shard D).**
The runtime's supervisor shard — the E42 supervisor, with the E43 broker as its
grant/revoke arm — is where quarantine/halt/re-key are *performed* at system
scale. "Revocation lands as an effect/alarm … the
supervisor's revoke is a customer of the effect/alarm system" ([[banks/runtime]]
§3). The supervisor is DESIGNED-not-built (E42), so the *dispatch* end of the
counter-effect set is design; the *type-level naming* end is E39. Both ends are
unbuilt, from opposite directions — name them precisely, don't call the whole
loop present.

**X6 · The membrane seam IS the port algebra ([[banks/module]] Shard 4).** The
three seams at `lib/typing/effects.chiral:34-46` are the same mechanism as the
module's port-set membrane: `on-binder-ok`'s linear-kind check (`:44`) is
*exactly* what would force a port to be bound at `q=1`, and the rule that does
force it today is `linear-binder-bad` (`lib/typing/kernel.chiral:360`), which the
kernel calls at its Pi and let binders. So "a module's outward face" (module bank) and "where effect
meaning is decided" (this bank) are one seam viewed from two sides. Do not
re-document the port-set here — [[banks/module]] owns it.

---

## 4. Native → chirality translation (the misfire → the correction)

**"chirality needs exceptions / `try`-`catch`."**
→ Correction: `try`/`catch` **conflates four distinct things** chirality deliberately
un-fuses: the *signal* (something diverged), the *control-flow* (unwind the
stack), the *recovery* (what to do about it), and — silently — the "hung" case
(an infinite loop is not a catchable exception at all). In chirality these are four
separate shards in three homes: the **signal** is the alarm (a typed effect on the
membrane, Shard 3); the **recovery** is the counter-effect (a named set, Shard 4)
whose recoverable-vs-fatal status is *in the type* (Shard 5); the **control-flow**
is the settled mechanism's graded continuation — resume or synthesized cancel,
multiplicity graded by what the continuation captures
([[decision-effect-facets]]; §5a); and the **"hung" case is a completely separate axis** —
non-termination is the totality modality (Shard 6), *not* a divergence, "different
effects" ([[error-and-alarm]]). The single most important correction in this bank:
**`totality` and the alarm are orthogonal.** A `try/catch` that "catches" a
timeout is papering over exactly the axis chirality keeps separate.

**"chirality needs algebraic effects with handlers."**
→ Correction: **settled 2026-07-21 — and not as a handler primitive** (§5a,
[[decision-effect-facets]]). A handler is the **process at the other end of the
port**; handler surface syntax CPS-elaborates to ordinary linear closures (zero
new kernel forms — verified in the E39 worked example); resumption multiplicity
is not decreed but **graded by capture** (a continuation capturing a linear port
is one-shot at `q=1`; port-free capture stays ω, so multi-shot search and
backtracking remain legal); abort is a synthesized cancel. chirality's *own* model
(QTT linearity, totality) shaped the call exactly as this bank's evidence
predicted. Do not assume a Koka-style handler primitive; the algebra rides
ports + rows.

**"chirality needs a monadic effect system (`IO`, `State`)."**
→ Correction: the effect distinction is **structural, in the type of the arrow**
(`->` vs `=>`, Pi position 2), not a wrapper type threaded by a monad. Effects are
**facets carried in the type of the arrow** (the exercise row the `eff` bit
seeds — [[decision-effect-facets]]), not a functor over the result. The membrane decides
meaning at three judgment seams (Shard 2), which a monad's `bind` cannot do — the
seams are where the kernel *refuses* an effectful application in a pure position.
No monad transformer stack is owed.

**"chirality needs `Result`/`Either` for error handling."**
→ Correction: `Result`/`Either` is one candidate — **typed result rows** are close
to it (an effect is a tag in a row on the arrow; "handling" is subtraction). But a
bare `Result` conflates *ordinary alternate return* with *divergence*, and it
carries no notion of **recoverable-vs-fatal in the type** (Shard 5) or of the
**named counter-effect set** (Shard 4). The alarm is richer than `Either e a`
precisely because it is "rich because split" (X2): it carries *which* copy/share/
MAC diverged, which a sum type does not. `Result` is a *shadow* of the row
mechanism, missing the split-fed payload and the arrow-carried row.

---

## 5. What's genuinely new / unbuilt — the honest residue

The coarse `eff` bit is CARRIED and the three membrane seams are BUILT **only in
the retired oracle** (Shards 1–2; measured §5d, home E171). The
alarm, the counter-effect dispatch, and recoverable-vs-fatal are **not on the
algebra yet** — the single author call that blocked them (D1/edge 16) was
resolved 2026-07-21 ([[decision-effect-facets]]); what blocks them now is the
E39 build itself (specced, unbuilt). Gradients preserved; nothing rounded.

### 5a. The keystone: edge 16 / E39 / **D1** — the effect mechanism (**RESOLVED 2026-07-21**, retained as input record)

> **Resolution:** [[decision-effect-facets]]. The call landed at a strengthened
> (c): capability-passing with continuations graded by what they capture
> (captured linear ports force one-shot — the committed-crossing argument below
> held; port-free capture permits multi-shot, preserving backtracking), abort by
> synthesized cancel, alarms as crossings. The three bullets of evidence below
> were independently derived in the decision session and all held; kept as the
> input record.

This bank was the **substrate for D1**, laying the fork out faithfully before
the call. The `eff` slot is one bool; the design wants it to carry an algebra
([[open-edges]] edge 16; [[DECISION-DOCKET]] D1, **highest leverage** — it gates
E39, and downstream E26 alarms and E51 self-host). The fork has three positions:

- **(a) Algebraic effects with resumable handlers** (Koka/Frank/Eff lineage) —
  effects are operations; a handler can *resume* the computation. Richer control
  (generators, backtracking, async fall out), heavier metatheory.
- **(b) Typed result rows, no resumption** — an effect is a tag in a row on the
  arrow; "handling" is *subtraction* from the row; no re-entry. Lighter, composes
  cleanly with linearity and the membrane, but cannot express resumable control.
- **(c) A middle** — rows + **one-shot / affine resumption** (a handler may resume
  at most once).

**How chirality's own model constrains each** (this is the evidence the decision must
weigh, not a verdict):

- **Multi-shot resumption fights QTT linearity and totality.** A resumption
  re-enters a linear scope; but **a consumed `q=1` port cannot be re-run** — the
  membrane's `on-binder-ok` seam (`lib/typing/effects.chiral:44`) binds a port exactly once, and a
  handler that resumes twice would consume it twice. Multi-shot control and
  linear ports are in tension. Totality compounds it: an unrestricted resumption
  is a way to re-enter a loop the termination checker proved bounded (Shard 6).
  This is the argument *against* full (a).
- **Recovery material lives in the SPLIT, not the handler (X2).** The classic
  motivation for resumable handlers — "repair a share, then resume" — is, in
  chirality, **already answered by the split**: repair-from-survivors "yields a good
  value at the combine" (robust decoding corrects *t* bad shares in the
  custody/split module, [[banks/evidence-and-split]]). If the good value is
  produced at the combine, you don't need to resume the original computation from
  the raise site — which weakens the case for (a) and strengthens (b).
- **But a divergence AFTER a committed crossing can't re-drive from the top.**
  Once a process has crossed an effectful port (sent bytes, mutated the pool), a
  later alarm **cannot re-run from the beginning** — the crossing is committed and
  the world has moved. Re-driving from the top is unsound; the only sound
  resumption is *forward*, from the raise site. This is **the real argument for
  one-shot resume (c)** — enough to continue past a recovered divergence without
  re-committing, but not enough to re-enter arbitrarily.

**The shape of the shard.** The gradient the author must land on: *how much control
power does the membrane actually need — is a resumable handler load-bearing for
anything in the roadmap (the live-environment? the broker?), or is
subtraction-from-a-row enough, buying clean composition with linearity/totality at
the cost of resumption?* ([[DECISION-DOCKET]] D1). **This bank does not answer it.**
Evidence is tied above; the call is deferred to D1's home decision doc.

**What the reshape is, once decided** (CONFORMANCE-MAP B/E39, DECISION → then
REFACTOR-L): conv keeps seat *equality* (`lib/typing/kernel.chiral:715`); row
*subsumption*
lands as a new `v-pi` case in `subtype` (`lib/typing/kernel.chiral:799`) with contravariant
domains *(corrected 2026-07-22, E39-SPEC 2nd-order audit — subsumption inside
symmetric conv is unsound: conv compares Pi domains at a
contravariant position)*;
⚑ the `on-apply-ok`/`erased-allow` half of this list is **already done**:
`lib/typing/effects.chiral` generalized both from the oracle's one-bit lattice to
set-containment over the row, and says so in its header (`:1-3`). What remains is
the `allow_eff` threading bool → row across infer/check; the per-arrow
effect attachment; the Pi's `Seat` field *type* (a two-constructor sum → a row);
and the `ty-crosses` derivation. Critically, **the judgment seams stay put** — this is a
*module* reshape plus a *field-type* change, not a kernel-logic
reshape, exactly because Shard 2 already isolated meaning in the module. After the
edge-16 call, the E39 row-shape becomes a bounded EXTEND of the bit.

### 5b. E26 — alarms as a typed effect (BUILD, hard-gated on E39)

Once the effect row exists, the alarm becomes a *tag in it* and the Python
crutches (`MetisExit` / `MetisHalt` / `PortError`, `alarms.py`) would have
retired; they went with the oracle first, so E26 now builds onto an empty seat
rather than replacing one. "Forward
construction; Python exceptions are floor plumbing to replace. Hard-gated on E39
(its effect row); sequence after E39" (CONFORMANCE-MAP B/E26, size M). Shard 5
(recoverable-vs-fatal in the type) lands *with* E26 — it is the first thing the
row makes representable. Until then the alarm is a thesis with a crutch, not a
built effect.

### 5c. Downstream that waits on the same call

- **E51 sys-face linkage** — the self-host gate — "threads `allow_eff` through the
  same seam"; was DECISION-gated on edge 16, now resolved 2026-07-21
  ([[decision-effect-facets]]; [[DECISION-DOCKET]] D1 RESOLVED), so its gate is
  implementing the row shape (E39). The self-host lane no longer waits on a
  call — it waits on the build.
- **The counter-effect dispatch** (re-key/re-derive/relocate/quarantine) needs
  both the row (E39) *and* its performing modules (custody redundancy BUILD,
  broker E43 DESIGNED, register-root E42 DESIGNED — CONFORMANCE-MAP D/E). Only
  `halt` is realized today.
- **Cross-node alarm propagation** — "how loud a divergence in one node is to the
  nodes holding ports to it" — is a *separate* open edge (edge 17), surfaced by the
  distribution-native node view ([[banks/runtime]] §3, §5). Named here only so it
  is not folded into edge 16. **Shaped 2026-07-25** (edge 17 edge-walk): loudness =
  port-graph reachability (no ambient broadcast), subscription = holding the
  alarm-carrying port (the row-entry is the subscription, no ACL), tier = the
  outbound-confinement tier of the rich evidence — the last leg **blocked on
  outbound confinement** (Shard 5 / E44), the honest residual.

### 5d. ⚑ The membrane is not enforced at the CALL — measured 2026-08-25 (E171)

The finding that corrected Shards 1–2 and the gradient summary above. It came out
of the **E168 spec-level audit** at `4f64d91`, which needed the membrane to be
load-bearing (*"`Obs` is producible only inside an `=>` def, and a `->` function
cannot call one"*) and tested the premise instead of assuming it.

**Method, as run on 2026-08-25.** Each program written as a source file, resolved
with `bin/chirality-resolve.sh`, compiled by the promoted binary of the day
(1,077,624 B at `4f64d91`), then RUN. No Python anywhere in the path. Re-measured
independently at the mint. ⚑ The resolver root and the binary path have both moved
since: the root is `"lib:prog"` and the binary is `bin/chirality-bin`. The
measurement has **not** been retaken against them, so the five results below are
dated evidence rather than a present-tense claim.

1. a `(-> I64 I64)` def calling the `=>` extern `backend-open`
   (`prog/manas/backend.chiral:37`, `(=> Str Backend)`) — compiles, **exit 42**;
2. a `(-> I64 I64)` def calling the bound crossing `put`
   (`lib/ports/stdio.port:11`, `(=> Str Unit)`) — compiles, **and
   writes to stdout**;
3. `(def observe (=> Str I64) …)` beside
   `(def check (-> Str I64) (lam (s) (observe s)))` — compiles, prints,
   **exit 7**;
4. the **module coordinate does not catch it either**: the same program under
   `(module tfloor (cat A) (alt upper))` — *correctness by proof* — compiles and
   prints, because `crossings` is sense (a) BINDS: a def that CALLS a crossing has
   bound nothing. So `(cat A)` refuses a module that BINDS a `=>` extern and
   admits one that only CALLS an imported one. ⚑ The test file this clause quoted
   for both halves, `test-module-kind.sh`, has **no live referent** and
   `tools/test/` carries no module-coordinate script, so the refusal case is
   unasserted by any gate today;
5. the **membrane demo in `README.md` fails for the wrong reason**:
   `prog/demo/_eff.chiral:3` is `(def f (-> I64 Unit) (lam (n) (put 42)))`,
   and B1's `load: type mismatch` is the **argument** mismatch (`I64` supplied
   where `Str` is wanted). Repair it to `(put "x")` under the *same*
   `(-> I64 Unit)` signature and it compiles, runs and prints — so the demo could
   not have failed for the membrane, and never did.

**Why this is a principle-level hole, not a missing convenience.** P2 names it
exactly: *"If any category of code opts out of the type, some things are 'just
functions' the effect system does not inspect, that category is an ungoverned
path, P1's hole restated. One atom with no exemptions is what makes the effect
typing total."* P3: *"The port-check is the type-check."* Today typing a `->` def
does **not** tell you its ports — which is the one property [[banks/port]] Shard 3
rests on.

**The direction is settled; the design is not.** A `->` body must not reach a
crossing, transitively. What is genuinely open — the blast radius (every def in
the compiler that transitively reaches `put`/`openat` gets re-typed), whether the
intermediate state was deliberate staging by **E160/E161** (which moved the
port-set claim to MODULE granularity and dropped the authored per-def
`(pure)`/`(crosses)`: `lib/typing/kernel.chiral:304-305`, *"There is no declaration left for a
module to contradict"*), how the rule composes with the module coordinate and the
`Sheet`'s derived `crossings`, and whether the obligation is inferred from the
call graph or annotated — belongs to **E171**'s own pre-run and is deliberately
undecided here.

**Not blocking E168.** Its decision 4 was reopened NEEDS-AUTHOR by exactly these
probes; the author's call, 2026-08-25, is that E168 mints its own `Builder`
capability rather than wait for the membrane.

**Gradient summary.** ⚑ **Corrected 2026-08-25 — the previous sentence read "the
membrane's *coarse floor* (the `eff` bit + three seams) is ENFORCED/CONFORMS", and
it is not.** The bit is carried; the three seams are native at
`lib/typing/effects.chiral:34-46` and nothing calls them (§5d, and Shard 2's
2026-09-04 re-measure). In the compiler that compiles everything the coarse floor is
EXTEND, and E171 owns the extension. Partiality stands alone in the totality modality, beside
the row seat the algebra will fill (Shard 6, classified-built / enforce-EXTEND).
Everything else —
the alarm as an effect, the counter-effect set as a typed handler, recoverable-vs-
fatal in the type — was **blocked behind one author call (D1/edge 16)**, now
**resolved** ([[decision-effect-facets]], 2026-07-21): the evidence cut exactly
the way the decision landed — against unrestricted multi-shot (graded by capture
instead), with the split supplying recovery values and forward-only resume for
committed crossings. E39/E26/E51 are unblocked; see
`examples/PLAN-2026-07-21-effect-algebra.md` for the build sequence.

---

## 6. Relational anchors — thin notes that should link INTO this bank

- [[error-and-alarm]] — the thin note whose four sections (alarm-is-an-effect,
  rich-because-split, response-is-a-counter-effect, recoverable-or-fatal-in-the-
  type) are the summaries of Shards 3–5; its "Open" section is §5a. Point here for
  depth.
- [[decision-graded-kernel]] — item 2 (partiality in the totality modality; as
  amended 2026-07-21, alarms are crossings, not modality-mates) is Shard 6 + X3/X4.
- [[decision-effect-facets]] — the 2026-07-21 resolution of D1/edge 16 this bank
  was the substrate for; its dated amendment moves alarms out of the totality
  modality (Shard 6, X4, §5a).
- [[open-edges]] — edge 16 (the effect mechanism, §5a) and edge 17 (cross-node
  alarm, §5c).
- [[DECISION-DOCKET]] — D1 (RESOLVED 2026-07-21), the highest-leverage author
  call this bank was the substrate for.
- [[totality]] — the totality modality (Shard 6); the `(total)` pillars. Owns its
  own depth.
- [[glossary]] / [[vocabulary]] — the pinned `alarm`, `counter effect`, `port`,
  `effect` entries; point here for depth.
- [[banks/module]] — revocation (C1) refracts into X1; the port-set membrane is
  the same seam as Shard 2 (X6).
- [[banks/profile]] — the `(total)` clause is a customer of this bank (X4, Shard 6).
- [[banks/runtime]] — the supervisor/broker is the counter-effect dispatcher
  (X5); the revocation chain (X1); cross-node alarm (§5c).
- [[banks/evidence-and-split]] — "rich because split" (X2); repair-from-survivors
  as the counter-effect whose material lives in the split (§5a).
- [[modules-broker]] / [[permission-model]] — where quarantine/halt/revoke are
  performed (X1, X5); DESIGNED, edge-8 gated.
