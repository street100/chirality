> **ARCHIVED 2026-09-01. Superseded. The port these seven dossiers de-risked has LANDED: the checker, the analyses, the pipeline, the substrate and the sys/format layers are chirality in `lib/` and `prog/`. Successors are `docs/examples/` (the worked examples) and `docs/elements/specs/`, both TRACKED.** ⚑ Every source line cited below is an evicted `scaffold/chirality/*.py` path. Nothing here can be re-run. Its cross-family "candidate element" flags were checked 2026-09-01 before archiving and **every one resolved to a minted element** (E51 built, E42 built, E52 design-unresolved, E20/E21/E23/E26/E32 all minted), so no unminted phantom is lost with the file.

# Family 6a — designed-but-unbuilt, part 1: the load-bearing edges (E38–E44)

**Elements:** E38 graded cost/coeffect semiring · E39 effect algebra/typed rows ·
E40 capability/permission model · E41 region types · E42 runtime supervisor ·
E43 component broker AUTH/AUDIT · E44 whole-assembly conformance.

**State of the family.** All seven are BUILD-PROPER: the "source" of each
translation is a design doc, the "target" is a kernel-seam integration sketch.
The family is not uniform, though. E38 is *settled-and-specified*
(`docs/decision-graded-kernel.md`) and the kernel's quantity arithmetic is
already generic in exactly the way the decision assumes — it is the one element
here that can be made pass-ready, and this dossier does so. E44 has a real
working core (`verify_profiles`) and is EXTEND, not UNBUILT. E39 and E40 have
their *seats* built (the `eff` bit and the `rules` seam; linearity as Move) but
the algebra/protocol on top gates on named author decisions (edges 16, 7).
E41 mostly *decomposes into other elements* once you enumerate what it would
actually retire — the honest payoff list is short, and the genuinely regional
residue needs one new kernel capability (fresh type-level brands). E42 and E43
split sharply into "language feature" versus "a program written in chirality once
the language suffices," and that split changes their passes from kernel work
into mostly library/demo work.

Ground rules honored: read-only audit; quotes are verbatim with file:line; no
surface syntax invented — where a sketch would need a construct chirality lacks,
that is stated as a finding.

---

## E38 — Graded cost / coeffect semiring   [BUILD-PROPER · Tier P]

**Lives now:**
- Design (settled): `docs/decision-graded-kernel.md` (whole note; the fork-A
  decision), `docs/open-edges.md:20-27` (edges 2, 3), `docs/memory-model.md:28-33`
  (space is a port; cost mechanism unsettled → now settled),
  `docs/time-and-clocks.md:11-21` ("time you spend" = `cost-typed`),
  `docs/target-tomodachi.md:26-29` (the idle bound, edge 3's concrete test case).
- The scalar instance in code: `scaffold/chirality/terms.py:11` (`W = "w"`),
  `scaffold/chirality/kernel.py:64-90` (`qadd`/`qmul`/`qjoin`/`qfits`),
  `kernel.py:93-106` (`uzero`/`uadd`/`uscale`/`ujoin` usage vectors).
- Every site that consumes a quantity (the full enrichment touch list):
  - `kernel.py:379-382` (Var: usage 1 at its slot), `kernel.py:420,428`
    (App: `uadd(uf, uscale(q, ua))`), `kernel.py:432-436,477-481` (Let),
    `kernel.py:463-473,511-522` (Lam/`strip_binder`/`close_binder`: `qfits`),
    `kernel.py:284` (conv: `a[1] != b[1]` — grade equality is part of Pi identity),
    `kernel.py:410,433,469` (`rules.on_binder(q)`), `kernel.py:432,477`
    (`rules.erased_allow(q, ...)`).
  - `effects.py:35` (`q != 1 and K.is_linear` — the linear-factor projection),
    `effects.py:42` (`q != 0` — the erased-factor projection).
  - `data.py:84,129,189-191,222-232,438` (field quantities; `uscale(q, ua)` in
    `_check_con`; `ujoin` across branches at `data.py:234,241`).
  - `surface.py:34` (`QUANTS = {0: 0, 1: 1, Sym("w"): K.W}`), and its four uses
    at `surface.py:251,357,394` (+ defaults `K.W` at 253, 359, 396).
  - `lower.py:296-297` (`q != K.W` → Ineligible), `lower.py:151,244` (`q == 0`
    erased lets), `runtime.py:75` (`t[1] == 0` erased-let skip),
    `optimize.py`/`pretty.py` display and fold paths that pattern-match Pi/Let
    tuples positionally (they carry `t[1]` through unchanged).

**Verdict:** UNBUILT (design settled 2026-07-05; `kernel.py` still carries only
0/1/ω — `docs/status-ledger.md:98-99` names this gap explicitly).

**Explainer.** The decision doc already did the hard part: cost lives in the
kernel as an enrichment of the grade structure QTT carries, the factor width is
fixed now (usage × time × space × info-flow), the cost domain starts as ℕ∪{∞},
info-flow is a reserved trivial lattice, and totality/staging are explicitly
*not* grades. What remains is mechanical *only if* you notice the shape the
scaffold already has: every quantity operation in the tree goes through exactly
four functions (`qadd`/`qmul`/`qjoin`/`qfits`) plus four pointwise lifts, and
every *decision* made on a quantity elsewhere is a projection (`q != 1` asks the
usage factor about linearity; `q == 0` asks it about erasure). So the
enrichment is: grade = 4-tuple, the four ops go per-factor, and every existing
comparison becomes a named projection. Three traps a future pass must not miss.
(1) *The join is per-factor and differs per factor*: usage joins by
equal-or-saturate (`qjoin` today, `kernel.py:82-84`), cost joins by **max**
(branches: the bound is the worse branch), the flow lattice joins by lattice
join. Reusing `a if a == b else TOP` for cost would make every branching
function cost-∞. (2) *Erasure zeroes cost*: `qmul(0, x) = 0` must hold for the
whole grade — a 0-usage position never runs, so its time/space contribution is
0, and the existing `uscale(q, uv)` at Let/App then does the right thing for
free. This is why the product-semiring framing works at all. (3) *Fits is
per-factor and asymmetric*: usage keeps today's exact-or-ω rule
(`kernel.py:87-90`), cost is `computed ≤ declared` (a bound is an
over-approximation, `docs/modules-core.md:53-54`). Conversely `conv` at
`kernel.py:284` demands grade *equality* as part of Pi identity — grade
*subsumption* in subtyping (a cheaper function where an expensive one is
demanded) is a genuinely new judgment with variance questions; it is NOT part
of this pass (see cross-family flags, candidate E51). Finally: what a "step"
costs (does `+` cost 1? per-constructor allocation for space?) is **not settled
by the decision doc** — the charging model is an open author decision; the
semiring generalization does not need it (slice 1 below is charging-model-free).

**Translation dossier.**

*Source exemplar 1* — the settled shape, `docs/decision-graded-kernel.md:39-49`:

> 1. Coeffect grades, which compose in one product semiring: usage (the linear
>    0/1/w already present), time, space, and information flow. [...] The kernel
>    semiring is parametric over its grade set; the factor width is fixed now
>    (usage x time x space x info-flow) so adding a factor later is not a change
>    to the trusted structure. The cost grade domain starts as the naturals with
>    infinity (constant bounds), with size indexed grades as the promotion path

*Source exemplar 2* — the scalar instance to be enriched, `kernel.py:64-90`:

```python
def qadd(a, b):
    if a == 0:
        return b
    if b == 0:
        return a
    return W  # 1+1 and anything involving W saturate

def qmul(a, b):
    if a == 0 or b == 0:
        return 0
    if a == 1:
        return b
    if b == 1:
        return a
    return W

def qjoin(a, b):
    """Merge usage across case branches: divergent use saturates to W."""
    return a if a == b else W

def qfits(computed, declared):
    if declared == W:
        return True
    return computed == declared
```

*Target sketch* (Python, kernel side — the enrichment, in the terms.py/kernel.py
split the tree already draws):

```python
# terms.py — the grade constants (syntax layer, no judgment)
W = "w"                     # usage factor values stay 0 | 1 | "w"
INF = "inf"                 # cost factor: int >= 0 | "inf"
USAGE, TIME, SPACE, FLOW = 0, 1, 2, 3
def grade(u, t=INF, s=INF, f=0):      # today's scalars embed: grade(q)
    return (u, t, s, f)               # flow: trivial lattice {0}, reserved seat
GRADE_0, GRADE_1, GRADE_W = grade(0, 0, 0), grade(1), grade(W)

# kernel.py — per-factor ops; the four names and every call site are unchanged
def _cadd(a, b):  return INF if INF in (a, b) else a + b
def _cmul(a, b):
    if a == 0 or b == 0: return 0     # erasure zeroes cost: never runs
    return INF if INF in (a, b) else a * b
def qadd(a, b):
    return (_uadd(a[USAGE], b[USAGE]), _cadd(a[TIME], b[TIME]),
            _cadd(a[SPACE], b[SPACE]), max(a[FLOW], b[FLOW]))
def qjoin(a, b):                       # branches: usage saturates, cost is MAX
    return (_ujoin(a[USAGE], b[USAGE]), _cmax(a[TIME], b[TIME]),
            _cmax(a[SPACE], b[SPACE]), max(a[FLOW], b[FLOW]))
def qfits(computed, declared):         # usage exact-or-w; cost <= (a bound)
    return (_ufits(computed[USAGE], declared[USAGE])
            and _cle(computed[TIME], declared[TIME])
            and _cle(computed[SPACE], declared[SPACE])
            and computed[FLOW] <= declared[FLOW])
```

where `_uadd/_ujoin/_ufits` are verbatim today's `qadd/qjoin/qfits` bodies.
Projections replace raw comparisons at the consuming sites:
`effects.py:35` `q != 1` → `q[USAGE] != 1`; `effects.py:42` /
`runtime.py:75` / `lower.py:151` `q == 0` → `q[USAGE] == 0`;
`lower.py:296` `q != K.W` → `q[USAGE] != K.W`; `surface.py:34`
`QUANTS = {0: GRADE_0, 1: GRADE_1, Sym("w"): GRADE_W}`.

*Target sketch* (surface): no new binder syntax in slice 1 — `(1 x Ty)` /
`(0 n I64)` / `(w n I64)` (`surface.py:355-359`, exemplars all over
`lib/ports.chiral:48-49`) keep elaborating to the embedded grades. The
profile-level claim rides the existing clause shape: a `(cost ...)` clause
modeled exactly on the bare `(total)` clause of `demo/verify-total.chiral:25`
(`(profile p (ports halt) (target totalizer) (total))`) and the one-symbol
`(memory linear)` clause of `demo/profile-tomodachi.chiral:38`, parsed in
`surface.py:144-200` `top_profile` and reported as one more `chirality verify` row
(`cli.py:43-60`). **Finding:** a *per-binder* cost annotation (writing "this
arrow costs ≤ 5" in a def's type) has no existing surface form — the quantity
slot `(1 x Ty)` takes one token from `QUANTS`. Extending that slot to carry a
grade literal is new surface syntax and an author decision (stage-4 surface
work, E49); slice 1 deliberately does not need it because the interesting
grades (idle bound = time 0 between events) are *inferred* bounds checked
against profile claims, not written annotations.

*Mechanical recipe:*
1. COPY — today's `qadd/qmul/qjoin/qfits` bodies become the usage-factor
   helpers `_uadd/_umul/_ujoin/_ufits`, verbatim.
2. TRANSLATE (rule: scalar → 4-tuple, op per factor) — reimplement the four
   public names as per-factor maps as sketched; `uzero/uadd/uscale/ujoin`
   (`kernel.py:93-106`) are already pointwise over the vector and need only the
   zero element changed (`[GRADE_0] * n`). Wait — no: the usage *vector* counts
   variable uses and is per-binder usage only; it stays a vector of grades and
   the lifts are unchanged because they call the four public ops.
3. TRANSLATE (rule: raw quantity comparison → factor projection) — the eight
   consuming sites enumerated under "Lives now" (effects.py ×2, runtime.py ×1,
   lower.py ×3, surface.py QUANTS + defaults, data.py field-quantity guards).
   `conv` at `kernel.py:284` needs nothing: tuple equality is grade equality.
4. TRANSLATE (rule: display) — `pretty.py` renders `grade(1)` back as `1`
   when the cost factors are the defaults, so errors stay readable.
5. NEW (small) — the charging model: where does a nonzero TIME/SPACE grade
   *come from*? Slice 1: nowhere — all inferred grades are the embeddings, all
   tests stay green, and the trusted structure is fixed once (that is the
   decision's own build order: "the semiring shape unblocks the stage 3 kernel
   and is built first," `docs/decision-graded-kernel.md:96-99`). Slice 2
   (separate pass, gated on the charging-model decision): charge per
   application/constructor in `infer`, verify the tomodachi idle bound.
6. NEW (small) — the `(cost ...)` profile clause + verify row, mechanically
   identical to how `(total)` was added (`surface.py:168-175`, `cli.py:48-50`,
   `verify_profiles` at `surface.py:505-513`).

**Dependencies:** none must land first (the decision *is* the unblock). Gating
author decision for slice 2 only: the charging model (what costs 1). Unblocks:
E39 (partiality-as-modality sits *beside* grades; the seat must exist), E44
(tier weight / whole-assembly sums want a grade to sum), E47 sized types
(decision doc: size indexes reuse this machinery), `time-and-clocks` budgets,
and the info-flow factor's reserved seat for `modules-security`.

**Est. pass size:** M — slice 1 (semiring generalization, all 191 tests green,
no semantic change) is a tight single session; slice 2 (charging + idle-bound
demo) is a second. Do not merge them; slice 1 is pure refactor and should be
reviewed as such.

---

## E39 — Effect algebra / typed rows (alarms, counter-effects)   [BUILD-PROPER · Tier P]

**Lives now:**
- Design: `docs/error-and-alarm.md` (whole note: alarm = typed effect, response
  = counter effect from a named set: re-key, re-derive, relocate, repair,
  quarantine, halt), `docs/open-edges.md:166-172` (edges 16, 17),
  `docs/decision-graded-kernel.md:51-63` (item 2: the partiality *modality* "is
  the home of the effect algebra of edge 16"), `docs/modules-core.md:46-55`
  (`effects` is the port algebra).
- The coarse bit in code: `scaffold/chirality/effects.py:21-46` (the `Rules` object:
  `on_apply`/`on_binder`/`erased_allow`; one pure-vs-process bit),
  `kernel.py:33` (Pi carries `eff` structurally), `kernel.py:284` (eff is part
  of Pi identity in conv), `kernel.py:420` (`rules.on_apply` at application),
  `surface.py:281-282,350-367` (`->` vs `=>` arrows; only the last arrow of
  `=>` is effectful).
- The alarm crutch: `scaffold/chirality/alarms.py:12-24` (`MetisExit`/`MetisHalt`/
  `PortError` as Python exceptions), `lib/ports.chiral:76-78` (`exit`/`halt`
  externs, polymorphic escape), `cli.py:91-98` (alarms caught at the toplevel).
- The incumbent typed-row pattern already in use: `lib/ports.chiral:24-30`
  (`RecvR` with `recv-closed` — "a closed stream is a named event in the type,
  not a sentinel value"; `Poll2R`, `AccR`), `impl_ports.py:150-153` (the host
  side returning the named event).

**Verdict:** UNBUILT (the algebra). The *seat* is built and correctly placed —
the kernel consults `sig.rules` at exactly three judgment points and carries
`eff` structurally without knowing what it means (`effects.py:1-15`); that
placement is the design's and survives any edge-16 outcome.

**Explainer.** Edge 16 is an explicit open author decision: "algebraic effects
with resumable handlers, typed result rows, or effect handlers of another
shape" (`docs/error-and-alarm.md:56-60`). This audit must not decide it, but it
can state the evidence in the tree, which is lopsided: the scaffold already
practices the *typed result row* discipline everywhere a divergence is
recoverable — `recv-closed` is a constructor, not an exception; `poll2-r`
returns which side fired; `mem-alloc` returns `AllocR` or takes the `halt`
path (`lib/mem-region.chiral:37-44`). Only the *fatal* alarms (`halt`, `exit`)
are out-of-band, and they are typed as polymorphic escapes precisely so "an
alarm path can close what it holds and leave without faking an inhabitant of
its return type" (`lib/ports.chiral:76-78`). Resumable handlers, by contrast,
have no seed anywhere, and they interact badly with two built commitments: the
lowering floor is one-terminator tal with TCO (`lower.py:170-177` outlines
non-tail cases into calls; a resumable continuation has no home there), and
linearity + resumption is a known hard corner (a captured continuation aliases
the linear environment). What the algebra must deliver regardless of mechanism:
(a) the `eff` bit becomes a *set* of named effects so a type says *which*
crossings, not just "crosses"; (b) alarms are members of that set, so dropping
one shows in the type; (c) counter-effects are the named response set, and
"recoverable or fatal is in the type" (`error-and-alarm.md:48-53`); (d) per the
graded-kernel decision, partiality is one effect beside the alarms — this is
where E38's totality-property and E39 meet. Cross-family flag from E26
confirmed: `alarms.py`'s exceptions are the crutch this element retires — the
exception classes become effect names in the row, and the Python `raise`/
`except` at `cli.py:91-98` becomes the toplevel handler of last resort. The
row also subsumes the port-set conformance check: `used_ports`
(`surface.py:454-487`) currently recomputes "which crossings does this def
use" by walking terms for `Prim` — with effect rows that information is *in
the type*, and the frozen-port-set check becomes a subtype check (a genuine
simplification E44 inherits).

**Translation dossier.**

*Source exemplar 1* — the design, `docs/error-and-alarm.md:15-22`:

> A detected divergence is not an out-of-band exception and not a silent
> failure. It is raised as a typed effect, in the same port and effect algebra
> as everything else (P3, P4). So it is on the membrane, named in the type, and
> total: every way a thing can signal "this does not match the rest" is in the
> type, and code cannot drop an alarm without the drop showing in its type.

*Source exemplar 2* — the seat, `effects.py:22-29`:

```python
    def on_apply(self, sig, ctx, fty, allow_eff):
        """fty is the VPi being applied. Returns allow_eff for the argument."""
        q, eff = fty[1], fty[2]
        if eff and not allow_eff:
            raise KernelError("effectful application inside a pure function (use => not ->)")
```

*Target sketch* (kernel-seam integration). The Pi already carries `eff` at slot
2 (`kernel.py:33,231,284`); the enrichment mirrors E38's exactly one level up:
`eff: bool` → `eff: frozenset[str]` with `False ↦ frozenset()` and
`True ↦ {"io"}` (the coarse embedding). `Rules.on_apply` becomes set
inclusion — `if not eff <= allow_eff: raise ...` — and `allow_eff` threads as a
set through `infer`/`check` (it is already threaded everywhere as a parameter;
the *type* of the parameter changes, no new plumbing). `conv` at `kernel.py:284`
compares `a[2] != b[2]` — frozenset equality, unchanged. No new seam: the
membrane rules object (`sig.rules`) already owns the meaning of `eff`, which is
the whole point of the seam ("what the membrane permits is decided in this
module, not in the kernel," `effects.py:12-13`). Sig-level state: an effect-name
registry (`sig.effects: {name: decl}`) owned by the effects module, populated
from source the way atoms are (`declare_atom`, `kernel.py:562-566`).

*Target sketch* (surface): **finding — new surface needed.** Today's `=>` marks
one anonymous effect (`surface.py:281-282`). Writing `(=> ...)` with a *named*
effect set has no existing form; the closest grounded analogy is the quantified
binder slot `(1 x Ty)` inside an arrow (a structured item where a bare type
also goes, `surface.py:355-359`), but extending the arrow head itself is new
syntax and an author decision bundled with edge 16. Until then, the effect set
can be *inferred* (a def's row = union of its externs' rows, computable exactly
as `used_ports` computes crossings today) and *demanded* per-profile — a
`(effects ...)` clause listing permitted effect names, modeled on the `(ports
sock-connect ...)` clause of `demo/profile-tomodachi.chiral:31-33`, which is the
same check one level up. Counter-effects need no new form at all: `halt` is
already an extern (`lib/ports.chiral:78`), and the named counter-effect set
(quarantine, re-derive, ...) enters as externs/library defs the same way —
"Alarm counter effects (halt) are declared in chirality source (lib/ports.chiral)
like any extern; nothing here special-cases them" (`effects.py:13-14`) is the
pattern to keep.

*Mechanical recipe:*
1. COPY — the `Rules` seam and its three call sites stay exactly where they
   are; `RecvR`-style result rows in `lib/ports.chiral` stay the recoverable-
   divergence pattern (they are already the design's shape).
2. TRANSLATE (rule: bool → frozenset, `and`/`not` → `<=` inclusion) —
   `effects.py:24-26`, the `allow_eff` threading, `declare_extern`'s
   `is_port = is_port or tyv[2]` (`kernel.py:582` → `is_port or bool(tyv[2])`),
   `lower.py:295` (`any(e ...)` → `any(e != frozenset() ...)`), surface `=>`
   elaboration (`surface.py:366` `eff and is_last` → the coarse `{"io"}`).
3. TRANSLATE (rule: exception class → effect name) — `alarms.py`'s three
   classes become declared effect names; `halt`/`exit` externs get rows
   `{halt}`/`{exit}`; `cli.py:91-98` stays as the host-boundary handler.
4. NEW (blocked on edge 16) — the handler/discharge mechanism: what *removes*
   an effect from a row (a handler construct, or the rows-only answer where
   recoverable = result row and fatal = unhandleable). This is the author
   decision; the pass stops at classify-and-check (rows inferred, profiles
   demand) until it is made — the same classify-then-gate shape as totality
   (`docs/totality.md:104-119`).

**Dependencies:** edge-16 author decision (mechanism: resumable handlers vs
typed result rows vs other — the options are stated in
`docs/error-and-alarm.md:56-60`; the tree's evidence favors rows but that is
observation, not adjudication). E38 slice 1 is a sibling, not a blocker (the
decision doc places partiality/alarms as a modality *beside* the grades).
Unblocks: E43 (audit-mark as an effect), E44 (port-set check becomes typing),
E26 retirement, edge 17 (cross-node alarm loudness) becomes statable.

**Est. pass size:** M for the row enrichment + inference + profile clause
(mechanical, mirrors E38 slice 1); the handler mechanism is unsized until the
edge-16 decision (that decision is the real gate, not the code).

---

## E40 — Capability / permission model: grants, revocation, delegate, Adhikara-over-wire   [BUILD-PROPER · Tier P]

**Lives now:**
- Design: `docs/permission-model.md` (whole note — with its own honesty banner
  at lines 11-16: "Of the four grant operations only *Move* (linearity) is
  ENFORCED"), `docs/modules-broker.md:47-55` (adhikara: monotonic attenuation,
  no spontaneous rights, revocation transitivity), `docs/open-edges.md:40-45`
  (edges 7, 8), `docs/open-edges.md:123-131` (Adhikara carries the capability
  over the wire; G8 dissolved), `docs/vocabulary.md:79-88` (capability = a port
  held; grant/sidehand = a held port used at a crossing).
- Move, built: `effects.py:32-38` (`on_binder`: linear types bind at 1 only),
  `kernel.py:205-215` (`is_linear`), `data.py:69-91,127-135` (linear kinds
  through data), the whole `lib/ports.chiral` discipline.
- Attenuate's raw material: `kernel.py:307-316` (`subtype` + `subtype_hooks`;
  `docs/status-ledger.md:52` — "mechanism present; not applied to grant
  narrowing"), `refine.py:225-232` (`_subtype`: entailment-based narrowing —
  the exact shape attenuation needs), `lib/ports.chiral:19` (value-indexed
  porttype `(porttype Pool (n I64))`).
- The wire face, seeded: `lib/ports.chiral:39` (`sock-send-fd` — a capability
  physically crossing a socket), `impl_ports.py:135-141` (`send_fds`).
- Revoke-scoped's raw material: `docs/time-and-clocks.md:39-44` (deadline expiry
  fires a counter effect); nothing in code.

**Verdict:** UNBUILT (three of the four grant operations, the capability port
proper, and the Adhikara correspondence). Move is ENFORCED and is not this
element's work.

**Explainer.** The permission-model note's central claim — "everything that
does the work already exists" — is aspirational, and the note now says so
itself. The audit's sharpest finding is *why* attenuation has nothing to grab:
the scaffold's port types are **opaque atoms** (`porttype Sock`) with all
operations living in free-standing externs. There is no operation set *in the
port's type*, so there is no "type offering less" to narrow to — attenuation-
as-subtyping (`permission-model.md:88-90`) is currently vacuous. Two built
mechanisms point at the fix without new kernel machinery: (a) porttypes can
carry value indexes (`(porttype Pool (n I64))`, verified at the bridge,
`bridge.py:53-62`), and (b) refinement subtyping is entailment
(`refine.py:225-232`), which is *exactly* monotonic attenuation: a rights
index `r` with `(refine I64 (<= k))` can only ever shrink under subtyping, and
"widening is not expressible" falls out of `entails`. Delegate is then one more
attenuable dimension (the note says precisely this, `permission-model.md:90-92`).
Revoke splits three ways in the design and only one needs anything new:
linear-reclaim is Move reversed (built), re-key is custody work (out of this
family), and *scoped expiry* needs deadlines-fire-counter-effects, which is
E39 + time-and-clocks, not capability machinery. The Adhikara-over-wire half
(edges 7, 17) is genuinely unpinned — the note itself says "the exact mapping
is not pinned" — and `sock-send-fd` is the honest seed: an fd crossing a
socketpair *is* a Move over the wire, enforced today by the OS, not by both
ends agreeing on an algebra. What would make it Adhikara is the receiving
bridge verifying the *rights claim* the way it verifies the Pool size claim
(`bridge.py:58-61`). Do not let the pass conflate the two layers: the
type-theory face (this element) and the runtime supervisor face (E43) "must be
designed to agree; that correspondence is an open edge" (edge 7) — an author
decision on the shared invariant vocabulary comes first.

**Translation dossier.**

*Source exemplar 1* — the four operations, `docs/permission-model.md:85-97`:

> - Move. Transfer is linear and is the default. [...]
> - Attenuate. Narrowing a grant is subtyping: the attenuated port's type is a
>   subtype offering less, never more. Widening is not expressible.
> - Delegate. Whether a holder may pass a grant on is itself an attenuable
>   dimension of the port's type, narrowed like anything else.
> - Revoke. Three shapes by how the grant is held. [...]

*Source exemplar 2* — the entailment subtyping attenuation reuses,
`refine.py:225-232`:

```python
def _subtype(sig, lvl, a, b):
    if a[0] == "VRefine" and b[0] == "VRefine":
        return K.conv(sig, lvl, a[1], b[1]) and entails(a[2], b[2])
    if a[0] == "VRefine":                    # forget the refinement: a is a base
        return K.subtype(sig, lvl, a[1], b)
```

*Target sketch* (grounded in existing forms only). A rights-indexed port,
modeled on the value-indexed pool (`lib/ports.chiral:19`) plus a refinement
bound (`lib/mem-linear.chiral:27`):

```lisp
; modeled on: (porttype Pool (n I64))            [lib/ports.chiral:19]
(porttype Cap (r I64))                  ; r = rights, a bit-meaning by convention

; attenuation as a refinement-typed crossing, modeled on mem-put-checked:
;   (-> (0 n I64) (=> (1 p (Pool n)) (refine I64 (>= 0) (< n)) Bytes (Pool n)))
;                                                 [lib/mem-linear.chiral:26-28]
(extern cap-attenuate
  (-> (0 r I64) (=> (1 c (Cap r)) (refine I64 (>= 0) (<= r)) (Cap r))))
```

**Finding:** the result should be `(Cap r2)` for the *narrowed* `r2`, which
needs the dependent codomain to mention the refined argument — that is a
dependent Pi over a refined domain, which the kernel has (Pi is dependent) but
`lower.py:79-81` rejects and the surface can state only via the named-binder
arrow form. The sketch above returns `(Cap r)` (sound but lossy); the precise
version `(-> (0 r I64) (1 c (Cap r)) (-> ((1 r2 (refine I64 (<= r)))) (Cap r2))`-
style types are *expressible today* in the arrow-binder form
(`surface.py:355-359`) — this is a checking-fragment question, not new syntax.
The bridge verifies the rights claim at the crossing exactly as it verifies the
pool size (`bridge.py:58-61` — the `VLit` index compare); that clause
generalizes from `Pool`-only to any `linear_data` with a concrete index, a
five-line change.

*Mechanical recipe:*
1. COPY — Move stays as-is (it is E5's linearity); `sock-send-fd` stays the
   wire primitive.
2. TRANSLATE (rule: size-index → rights-index) — `bridge.py:59-61`'s
   Pool-specific index check becomes generic over indexed `linear_data`; the
   `(porttype Cap (r I64))` declaration reuses `surface.py:110-126` unchanged.
3. TRANSLATE (rule: refinement entailment = monotonic attenuation) — no code:
   `refine._subtype` already provides it once rights are refinements. Delegate
   = a second index dimension, same treatment.
4. NEW (gated) — the Adhikara invariant statement both layers check (edge 7):
   which algebra the static checker and the E43 broker share, and what the
   receiving end of a wire crossing verifies (edge 17). Author decision; the
   options are (a) rights-as-refinement-carried-in-the-type (all static, the
   wire claim verified like the Pool size) vs (b) a runtime rights word the
   broker co-signs. The permission-model note leans (a) — "no separate
   permission record to consult" (`permission-model.md:26-28`) — but the note
   is DESIGNED-status and this is exactly what edge 7 leaves open.
5. NEW (elsewhere) — scoped revocation waits on E39 counter-effects + deadline
   ports; re-key waits on custody (other family).

**Dependencies:** edge-7 author decision (the Adhikara correspondence) gates
the wire half; E9's symbolic refinement slice (built) suffices for constant
rights, arithmetic-expression bounds would widen it. Unblocks E43 (grant/revoke
need a grant object to move), the behavior-pack confinement story of
`target-tomodachi` (packs hold no ports — already checkable; packs hold
*attenuated* ports — needs this).

**Est. pass size:** M for the rights-indexed-port + generic bridge-claim slice
(pass-ready; grounded end to end). The Adhikara correspondence is unsized
until edge 7 is decided.

---

## E41 — Region types (retire runtime offset/bounds checks)   [BUILD-PROPER · Tier P]

**Lives now:**
- Design: `docs/memory-model.md:47-55` (regions = "the arena story for systems
  code without GC (deferred, unscheduled)"), `memory-model.md:106-114` (the
  naming trap: the region *library* is not region *types*; "Region types (the
  arena story the type system tells, retiring that runtime check) remain
  deferred"), `docs/open-edges.md` edge 3, `docs/modules-core.md:38-44` (region
  deferred to later slices).
- The discipline libraries it would subsume: `scaffold/lib/mem-linear.chiral`
  (esp. `mem-put-checked` at 26-28, which already retires the refinable case),
  `scaffold/lib/mem-region.chiral` (the arena: cap witness + cursor check).
- The runtime checks that are the payoff list (see Explainer).

**Verdict:** UNBUILT — and partially *dissolving*: enumerating the payoff shows
most of it belongs to other elements.

**Explainer.** The audit question was "which runtime checks would region types
retire — enumerate them." The full list of runtime bounds/lifetime checks in
the tree:

1. `impl_ports.py:196-199` — `pool-write` host check
   (`if off < 0 or off + len(data) > size: raise PortError(...)`).
2. `lib/mem-region.chiral:41-44` — `mem-alloc`'s cursor check
   (`(<=i (+ used len) cap)`) *and* the runtime `cap` witness field itself
   (`mem-region.chiral:8-13`: carried only because the erased `n` cannot be
   branched on).
3. `impl_pure.py:110-112` — `bget` index check (`out of range`).
4. `lib/bytes-tal.chiral:100-101` — `nb-bslice`'s stated obligation
   ("requires 0 <= i <= j <= len [...]; out-of-range faults instead of
   clamping — the honest alarm").
5. `native.py:17` — native arena exhaustion as a `ud2` fault.
6. The residual raw `mem-put` kept for "computed offsets the fragment cannot
   yet prove (e.g. a strided `(* y k)` write)" (`mem-linear.chiral:23-25`; the
   live example is `demo/sprites.chiral:71`, `(pool-write n p (* y 1024) ...)`).

Now the honest decomposition. Items 1, 3, 4, 6 are **arithmetic-expression
refinement bounds** — `off + len(bs) <= n`, `(* y 1024) < n` — i.e. the E9
promotion path the refine module's docstring already names as "still out of
the fragment" (`refine.py:26-29`: "only a bound that is an arithmetic
*expression* (`v < n+1`) is still out"). Item 2's cursor check and witness
field fall to the same completion (prove `used + len <= n` against the erased
index and the witness is unnecessary). Item 5 is the same one altitude down.
None of this is Tofte–Talpin. What region types *distinctively* add over
refinement-completion is **lifetime branding**: today `mem-alloc` returns a
bare `I64` offset (`mem-region.chiral:31-32`, `(alloc-r (off I64) ...)`), so an
offset can outlive its region — nothing stops code from stashing `off`,
closing the region, and… nothing, because there is no operation on a bare
offset without the region; linearity of the Region already forces every read/
write to thread the arena. So even the escape story is *mostly* covered by
built linearity. The genuinely irreducible residue: distinguishing offsets of
*different* regions of the same capacity (an `(Off r)` brand needs a fresh
type-level name per `region-open`), and subregion nesting/outlives-ordering.
The kernel has **no mechanism for fresh type-level names** — porttype indexes
are I64 *values*, not brands — and that is the new-seam finding: region types
proper need either existential indexes or a freshness discipline at binders,
which is real kernel surface. Given the payoff table above, the honest
recommendation to the author (a decision, not decided here): **let E41's
bounds-check payoff be claimed by the E9 arithmetic completion**, and keep
region types deferred until a use case needs cross-region branding that
linearity does not already forbid. The memory-model note already insists
"nothing here advances them" — this audit found the same from the code side.

**Translation dossier.**

*Source exemplar* — the runtime check + witness the types would retire,
`lib/mem-region.chiral:37-44`:

```lisp
(def mem-alloc (-> (0 n I64) (=> (1 r (Region n)) I64 (AllocR n)))
  (lam (n r len)
    (case r
      ((region p cap used)
        (case (<=i (+ used len) cap)
          (true (alloc-r used (region p cap (+ used len))))
          (false (do (pool-close n p)
                     (halt (AllocR n) "region: allocation past capacity"))))))))
```

*Target sketch* (the refinement-completion half — grounded): the checked write
already exists as the model, `lib/mem-linear.chiral:26-28`:

```lisp
(def mem-put-checked
  (-> (0 n I64) (=> (1 p (Pool n)) (refine I64 (>= 0) (< n)) Bytes (Pool n)))
  (lam (n p off bs) (pool-write n p off bs)))
```

The completion generalizes the refinement operand from "constant or bare
variable" (`refine.py:192-196`) to linear arithmetic expressions
(`(refine I64 (>= 0) (<= (- n (blen bs))))` shapes), at which point
`mem-alloc`'s guard branch *is* the proof and the `halt` arm is dead. **This
sketch is E9's pass, not E41's** — recorded here so the two dossiers do not
double-claim it. *Target sketch (the branding half):* none offered — the
`(Off r)` fresh-brand type is not expressible with any existing construct, and
per the spec that is a finding, not a sketch.

*Mechanical recipe:* (conditional on the author decision above)
1. TRANSLATE (E9's recipe) — extend `refine.py`'s operand fragment to
   arithmetic bounds; retire checks 1–4, 6 site by site, each retirement a
   test that the guard branch becomes provably dead.
2. COPY — `lib/mem-region.chiral`'s API shape survives unchanged (the types
   tighten inside the same defs; the discipline library was built to be
   subsumed this way).
3. NEW (large, deferred) — fresh type-level brands for `(Off r)`; do not start
   without the author decision and a driving use case linearity fails on.

**Dependencies:** E9 arithmetic-expression bounds (the real vehicle); the
author decision on whether region *types* stay a feature at all vs dissolving
into refinement + linearity (options above — the memory-model note and this
audit both lean dissolve, the catalog row keeps the seat). Unblocks: retiring
`_poolwrite`'s host check, dropping `Region`'s cap witness, native-arena
static exhaustion proofs.

**Est. pass size:** not separately sized — S *after* E9's arithmetic slice
lands (the retirements are then mechanical); L and unscheduled if the branding
half is ever commissioned.

---

## E42 — Runtime supervisor (critical sections, register-root custody, scheduler)   [BUILD-PROPER · Tier P]

**Lives now:**
- Design: `docs/modules-bridges.md:55-62` (the `runtime` module: "Critical
  sections, preemption control, register root custody, the scheduler. It holds
  the bounded clear window [...] It also meters cost for the partial,
  unbounded processes whose bound is not proven, which is the C twin of
  `cost-typed`"), `docs/process-and-runtime.md` (runtime = a process at system
  scale; the cascade), `docs/open-edges.md:84-88` (edge 11: bootstrap floor vs
  this module), `docs/time-and-clocks.md:39-44` (the runtime schedules
  deadlines).
- The different artifact wearing the name: `scaffold/chirality/runtime.py`
  (evaluator + linker — `docs/status-ledger.md:101` and the catalog both flag
  this; the name collision is real and should eventually be fixed by rename).
- Seeds of the supervisor-as-program: `demo/duo.chiral:9-18` (a node that
  stages its child and holds the one port), `impl_ports.py:163-171` (`poll2` —
  the blocking wait a scheduler multiplexes on), `lib/ports.chiral:57-65`
  (spawn = stage, teardown = move).

**Verdict:** UNBUILT — but the pass-defining finding is the *split*: most of
E42 is not a language feature.

**Explainer.** The audit question — separate language design from "a program
written in chirality once the language suffices" — cuts this element into three
strata. **(A) Ordinary chirality program, writable now:** the scheduler and
lifecycle half. A supervisor is a node that spawns children, holds their ports,
multiplexes on poll, restarts/quarantines on divergence — `demo/duo.chiral` is
already a two-node miniature of exactly this, and `docs/process-and-runtime.md`
insists there is no privileged runtime beneath everything ("a runtime manages
itself by being made of runtimes"). What blocks a *real* supervisor demo is
only the syscall surface: `poll2` is fixed at two sockets (`impl_ports.py:163`),
so a supervisor of N children needs pollN — that is E31's sys-slice recipe
(`DOSSIER-SPEC` pattern 2), not this element. Deadline scheduling likewise:
`poll2`'s timeout argument is already the mechanism; firing a counter effect on
expiry is E39. **(B) Language-gated:** cost metering for partial processes
("the C twin of `cost-typed`") needs E38's grades to exist before there is
anything to meter against — the runtime charges fuel exactly where the type
carries ∞. And the bounded clear window (`clear-window <= N`,
`docs/memory-model.md:68-74`) is custody linearity plus an E38 grade, checked
statically, with the supervisor only *enforcing the residue*. **(C) Substrate-
gated, unbuildable on this host:** critical sections, preemption control, and
register-root custody presuppose registers the language controls and a context
switch it can disable. CPython has none of these — a Python-level "critical
section" would be theater, the exact failure `docs/trust-boundary.md`-style
honesty forbids. This stratum waits for the native floor (E20/E23/E34 line)
and the bootstrap-floor design (edge 11 explicitly leaves open how this module
relates to the tuned-runtime set). The pass ordering that follows: build (A) as
a library + demo once pollN exists; reserve (B)'s seat in the same pass that
lands E38 slice 2; do not fake (C).

**Translation dossier.**

*Source exemplar 1* — the spec, `docs/modules-bridges.md:57-61` (quoted in
"Lives now"). *Source exemplar 2* — the supervisor seed, `demo/duo.chiral:15-18`:

```lisp
          (let ((1 peer (spawn "demo/profile-node-render.chiral"))
                (1 ni0 (sock-connect np))
                (1 ni1 (sock-send ni0 (str->bytes "\"EventStream\"\n"))))
            (sloop (the SSt (sst ni1 peer "" boot-mood)))))))))
```

*Target sketch* (stratum A — a supervisor library, every construct grounded):
a `lib/supervise.chiral` whose loop is shaped like `demo/duo.chiral`'s `sloop`
over `sensor-core`'s state datum: children as a `(List ...)`-like data of
linear ports (linear fields in data are built — `(1 sock Sock)` in `RecvR`,
`lib/ports.chiral:24-26`), the wait a pollN extern (E31), divergence handling by
casing `recv-closed` (the built pattern, `lib/ports.chiral:24-26`) with the
counter effect chosen per `docs/error-and-alarm.md`'s named set — today that is
`halt`/quarantine-by-closing; the richer set arrives with E39. **Finding:** a
data type holding a *list of linear ports* needs the linear-container story —
`lib/collections.chiral`'s assoc lists are ω-field; a linear cons exists as a
pattern (`(1 rgn (Region n))` fields) but a general `(LList Sock)` should be
checked against `data.py`'s `_linear_data` before the pass assumes it (it
should work: a 1-field makes the data linear, `data.py:83-85`).

*Mechanical recipe:*
1. COPY — `demo/duo.chiral`'s stage-hold-loop shape; `cli.py:101-144`
   `_spawn_run`'s child-side self-verification (already the AUTH handshake).
2. TRANSLATE (rule: 2 → N) — `poll2` → `polln` via the sys-slice recipe
   (E31's pass; `nb-sys-lseek` is the exemplar per DOSSIER-SPEC pattern 2).
3. NEW (small) — the supervisor library + a demo profile whose target requires
   it; the restart/quarantine policy table as plain chirality data.
4. NEW (deferred, seats only) — metering hooks (E38 slice 2), critical
   sections/root custody (native floor; do not mock).
5. Rename note (zero-cost, author's call): `runtime.py` → e.g. `eval.py` to
   free the name for the designed module; `status-ledger.md:101` already
   flags the collision as gap #5.

**Dependencies:** E31 pollN (hard, small), E39 counter-effects (for the
response set), E38 (metering seat), edge 11 (bootstrap-floor relation — author
decision, blocks only stratum C). Unblocks: E43 (the broker *is* this
supervisor wearing its authority hat — see E43), a real multi-node tomodachi.

**Est. pass size:** M for stratum A (library + demo + pollN prerequisite);
stratum B rides other elements; stratum C unsized (substrate-gated).

---

## E43 — Component broker: AUTH/AUDIT, grant/revoke/audit   [BUILD-PROPER · Tier P]

**Lives now:**
- Design: `docs/modules-broker.md` (the two brokers; component broker =
  "runtime supervisor of the part that cannot be decided at compile time:
  process and runtime lifecycle (spawn and teardown), dynamic grant and revoke,
  audit reconciliation against live state"), `docs/decision-brokers.md`
  (settled: push the statically decidable into types; only the irreducibly
  dynamic remains), `docs/open-edges.md:43-45` (edge 8: the four-part
  AUTH/AUDIT decomposition "is not yet specified").
- Built slice: `impl_ports.py:69-86` (`spawn`: socketpair + child process),
  `cli.py:101-144` (`_spawn_run`: the child verifies its own profile and its
  entry type *before* running — staging refused is the port closing),
  `runtime.py:50-53` (link-at-load: every extern must have a host binding
  before anything runs), `lib/ports.chiral:57-65` (spawn's typed face; "Who may
  stage is governed like any crossing: spawn sits in a profile's frozen port
  set or that profile cannot use it").
- Missing named: grant/revoke (E40's operations, dynamically exercised),
  audit-reconcile (`docs/modules-bridges.md:37-42`) and its A-half audit-mark
  (`docs/modules-security.md:47-48`).

**Verdict:** UNBUILT (the AUTH/AUDIT halves). The lifecycle half is
IMPLEMENTED and — the pass-defining finding again — the rest is mostly a
*program*, not a feature.

**Explainer.** `decision-brokers.md` already did the category split: the
static broker dissolved into the type checker (that half is *built* — it is
`kernel.py` + the frozen port set), and what remains is the supervisor of the
irreducibly dynamic. Apply the E42 test to each remaining duty. *Spawn/
teardown*: built, and built the right way round — authority to stage is a port
in the frozen set, and the child self-verifies (the current AUTH slice; the
`_spawn_run` refusal path is a real authorization check, just a static one).
*Dynamic grant*: once E40 gives grants a type, granting at runtime is **moving
a typed value over a live port** — and the primitive exists: `sock-send-fd`
physically moves an fd-backed capability today. What is missing is not a
broker feature but the receiving side's *claim verification* (bridge verify of
the rights index, E40's step 2) — after which "the broker grants X to child C"
is a chirality function that sends a port, i.e. a program. *Dynamic revoke*: the
three shapes of `permission-model.md:92-96` — reclaim is a move the child
cooperates with (program), expiry is a deadline counter-effect (E39), re-key
is custody. The only revoke with real mechanism content is *unilateral*
revocation of a delegated grant (revocation transitivity, the adhikara
invariant) — over the wire that means the transport must be severable
(closing the socket *is* severing; `recv-closed` is the revokee's evidence),
so scaffold-scale unilateral revoke = close the carrying socket, and the
transitive part is the broker not forwarding — checkable, but only as
discipline until adhikara (edge 7) pins what the *type* promises. *Audit*: the
trail is a program (append-only log of crossings the broker mediates); what is
language-level is `audit-mark` as an effect — an obligation in the row that
E39 must be able to express (the write-once trail then reconciled by
`audit-reconcile`, a C module comparing trail to live state — again a program
plus one bridge-verify shape). Edge 8's four-part AUTH/AUDIT decomposition is
explicitly unspecified — an author decision this dossier must not invent; the
options space the docs leave: decompose by operation (authn/authz/audit-write/
audit-reconcile, the dump-D13 reading) or by category residue (typed-face vs
evidence-face of each). What the audit *can* say: whichever decomposition,
each part lands as a chirality module in a broker *profile*, not as kernel
surface — the kernel diff for all of E43 should be zero.

**Translation dossier.**

*Source exemplar 1* — the duty roster, `docs/modules-broker.md:31-37` (quoted
in "Lives now"). *Source exemplar 2* — the built AUTH slice, `cli.py:110-116`:

```python
    if not el.sig.profiles:
        print("chirality: staging refused: no profile declared", file=sys.stderr)
        return 1
    for pname, tname, rows, violations, memory, total_viol in verify_profiles(el.sig):
        if any(not ok for _, ok, _ in rows) or violations or total_viol:
            print(f"chirality: staging refused: profile {pname} invalid", file=sys.stderr)
            return 1
```

*Target sketch* (grounded): the broker is a chirality node — a supervisor (E42
stratum A) whose profile's frozen port set includes `spawn` and `sock-send-fd`
and whose target requires the broker entry points; modeled on
`demo/profile-tomodachi.chiral:30-38` (ports clause + target + memory) and
`demo/duo.chiral` (stage-and-hold). Granting:

```lisp
; grant = move a held capability to a child over its staging port
; modeled on: (extern sock-send-fd (=> (1 s Sock) Bytes (1 f Fd) Sock))
;                                                  [lib/ports.chiral:39]
; usage shape as in demo/duo.chiral:15-17 (spawn then thread the peer)
```

— no new surface at all; the *typed* version of the payload waits on E40.
Audit-mark: **finding** — an obligation effect ("this crossing must also write
the trail") has no expressible form until E39 rows exist; until then the trail
is convention (the broker's own send wrapper), which is honest discipline, not
enforcement, and should be labeled as such in any interim demo.

*Mechanical recipe:*
1. COPY — `_spawn_run`'s verify-then-run (the child-side AUTH), `spawn`'s
   socketpair plumbing, `duo.chiral`'s holder shape.
2. TRANSLATE (rule: host-side one-shot → chirality-side loop) — the parent-side
   supervision from Python `subprocess` glue into the E42 supervisor library.
3. NEW (gated on E40) — grant/revoke as typed moves with bridge-verified
   claims; (gated on E39) audit-mark effect; (gated on edge 8, author) the
   four-part decomposition and which parts are separate modules.
4. NEW (small, anytime) — the append-only trail + reconcile-against-live-state
   as a plain chirality library over `Bytes` (T-shaped seed for audit-reconcile;
   its tamper-evidence upgrade is custody-family work).

**Dependencies:** E42 stratum A (the broker is a supervisor), E40 (grants),
E39 (audit-mark, counter-effects), edge-8 author decision (decomposition),
edge-7 (adhikara, for anything cross-node). Unblocks: edge 14's rendezvous
test case (one socket, event stream + request/reply), runtime module swap
(behavior packs installed through the broker per `target-tomodachi`).

**Est. pass size:** M once E42-A exists (the lifecycle+trail program); the
AUTH/AUDIT proper is unsized until edge 8 is decided.

---

## E44 — Whole-assembly conformance (totality, non-interference, tier weight)   [BUILD-PROPER · Tier P]

**Lives now:**
- Design: `docs/decision-profiles.md:69-99` (the conformance mechanism:
  requirement type / composite type / subtyping; "The open part is which
  target properties are compositional"), `docs/open-edges.md:196-201`
  (edge 18; tier weight "carried in the type but no note says how it composes"),
  `docs/totality.md:121-141` (the profile gate — the first whole-assembly
  property, built), `docs/vocabulary.md:37-39` (type includes tier weight).
- Built core: `surface.py:490-514` (`verify_profiles`: target rows by
  subtyping + frozen-port-set violations + memory report + `(total)` sweep),
  `surface.py:454-487` (`used_ports`: per-def crossing usage),
  `surface.py:517-536` (`verify_targets`/`_target_rows`), `cli.py:37-70`
  (the verify report), `surface.py:144-200` (`top_profile` clause parsing),
  `demo/verify-total.chiral` (worked example), `cli.py:113-116` (verify wired
  into staging — conformance is load-bearing, not advisory).

**Verdict:** EXTEND — the conformance *mechanism* is sound and running (three
reused checks, exactly as `decision-profiles.md:87-91` specifies, at scaffold
scale); the missing pieces are named properties and one scoping refinement.

**Explainer.** What `verify_profiles` already gives is easy to under-credit:
it is the G9 mechanism end to end — a target is a requirement type
(`sig.targets`), the composite is the loaded globals, conformance is subtyping
per requirement (`_target_rows`, using the real `K.subtype`), the frozen port
set is a whole-assembly *usage* check (every crossing any def performs must be
in the set), and `(total)` is the first genuine whole-assembly *property*
check, reported per-holdout with reasons. The extension shape is also already
regular: each property = one profile clause (parse in `top_profile`) + one
sweep over `sig` + one verify row — `(total)` and `(memory d)` were both added
this way, and that regularity is the mechanical recipe. What is genuinely
missing, in increasing order of gatedness: **(1) Reachability scoping** — the
composite is *all* loaded defs, so an unreachable helper that fails totality
invalidates the profile; `docs/totality.md:139-141` names this ("the same
refinement the port-set check wants"). Buildable now: `used_ports` already
walks bodies; a call-graph closure from the target's required entry points is
the same walk collecting `Global` heads. **(2) Whole-assembly sums** —
memory/time bounds *across* the composite (`memory-model.md:150-151`); gated
on E38 (there must be grades to sum) and on a compose rule (sum for space,
max-or-sum for time depending on concurrency — author decision territory).
**(3) Non-interference** — subtyping-checkable only if each module preserves
it, else global analysis (`decision-profiles.md:93-97`); gated on the
info-flow module existing at all (E38's reserved FLOW factor is its seat;
enforcement is stage 7-8 per the graded-kernel decision — far). **(4) Tier
weight** — the sharpest *decision* gap: the type carries it in design but no
note says how it composes or subtypes across a composite (edge 18 verbatim).
Options the docs support: max (weakest link — a composite is as weak as its
weakest datum's tier) vs per-requirement (the target names the tier per
datum, custody's edge-4 classification selects it). This dossier does not
pick; it flags that *nothing in E44 can check tier weight until that one
paragraph is written*, and that the check itself will then be a one-sweep
extension like `(total)`. Finally, the compositional-vs-global split (edge
18's core) is itself an author task, but it is *cheap* — a table over the
known properties (structural port demands: subtyping; totality: per-def sweep,
compositional given reachability; port set: anti-compositional by design,
global usage sweep; sums: compositional by semiring add) — and writing it
would convert every future property pass into the regular clause+sweep+row
shape in advance.

**Translation dossier.**

*Source exemplar 1* — the built whole-assembly property check,
`surface.py:505-513`:

```python
        total_viol = None
        if prof.get("total"):
            # the composite is the loaded globals, as for the port set; a def
            # is total when the checker recorded no reason it could not prove it
            total_viol = sorted(
                (name, sig.totality[name])
                for name in sig.global_defs
                if sig.totality.get(name) is not None)
        report.append((pname, prof["target"], target_rows, violations,
                       prof.get("memory"), total_viol))
```

*Source exemplar 2* — the open half, `docs/decision-profiles.md:93-97`:

> The open part is which target properties are compositional. A structural
> demand (offers port X) is plain subtyping. A whole-assembly property (every
> morphism total for chirality-verify, non-interference across the composite) is
> subtyping-checkable only if each module preserves it so the composite does;
> where it is not compositional it needs a global analysis.

*Target sketch* (the reachability slice — grounded, buildable now): no new
surface; the `(total)` clause's *meaning* tightens from "every loaded def"
to "every def reachable from the target's requirements." Implementation shape:
a `reachable(sig, roots)` sweep in `surface.py` modeled line-for-line on
`used_ports`' walker (`surface.py:456-483` — same nine-case term walk,
collecting `Global` heads instead of `Prim` port heads), rooted at the
requirement names of the profile's target (`sig.targets[prof["target"]]`),
then `total_viol`/`violations` filter to the reachable set. The port-set row
gets the same scoping for free — which `docs/totality.md:139-141` predicts.
*Target sketch* (future property rows): each lands as `(clause)` parse at
`surface.py:158-175` (the `(total)` branch is the copy source) + a sweep +
a `cli.py:43-60` row; the sums row waits on E38, the flow row on stage 7-8,
the tier row on the edge-18 author paragraph.

*Mechanical recipe:*
1. COPY — the term walker from `used_ports` (verbatim structure, swap the
   collection predicate).
2. TRANSLATE (rule: all-loaded → reachable-from-roots) — thread the reachable
   set into the two existing sweeps in `verify_profiles`.
3. NEW (tiny) — tests: an unreachable non-total def no longer invalidates a
   `(total)` profile; an unreachable port use no longer violates the set
   (deliberate semantics change — record it in the totality note, which
   already anticipates it).
4. NEW (author, cheap, high-leverage) — the edge-18 table: per property,
   compositional-by-subtyping / compositional-given-reachability / global.
   One page of `docs/`; unblocks every later row.
5. NEW (gated) — sums row (E38), flow row (stage 7-8), tier row (edge-18
   tier-weight paragraph + edge-4 classification).

**Dependencies:** none for the reachability slice (pass-ready now); E38 for
sums; the edge-18 author decision for tier weight and the general table;
E39 turns the port-set sweep into typing eventually (see E39). Unblocks:
chirality-verify as a real gate at scale (edge 9's remaining work), honest
staging refusal (already wired at `cli.py:113-116` — every property row added
here automatically strengthens spawn-time AUTH).

**Est. pass size:** S for the reachability slice. Later rows ride their
gating elements.

---

## Family footer

### Redo list

No REDOs. Nothing in this family was implemented as a shortcut — the family's
defining property is that the designs are ahead of the code, and the scaffold
has been honest about it (the status banners in `permission-model.md`,
`modules-broker.md`, `modules-security.md`, and `status-ledger.md`'s
sharpest-gaps list all pre-name the gaps this audit confirms). The one hygiene
item is the `runtime.py` name collision with the designed `runtime` module
(status-ledger gap #5): a rename, not a redo.

### Ordering (dependency-respecting passes)

1. **E38 slice 1** (semiring generalization; pure refactor, pass-ready now) —
   unblocks the most and risks the least.
2. **E44 reachability slice** (S, pass-ready now; independent of 1) — can run
   in parallel with 1.
3. **Author-decision batch** (no code; cheap, unblocking): edge-18 table
   (E44), edge-16 mechanism (E39), edge-7 adhikara correspondence (E40),
   edge-8 broker decomposition (E43), E38 charging model, E41
   dissolve-vs-feature. Several are one-page notes; scheduling them as a batch
   converts four unsized elements into sized ones.
4. **E39** (rows + inference + profile clause; after edge-16).
5. **E40** (rights-indexed ports + generic bridge claim; the M slice can start
   after 1–2, the wire half after edge-7).
6. **E42 stratum A** (supervisor library; after pollN/E31, using E39's
   counter-effects when available).
7. **E43** (broker program over 5+6; AUTH/AUDIT proper after edge-8).
8. **E38 slice 2** (charging + idle bound) — anywhere after 3's charging
   decision; the tomodachi idle bound is its acceptance test.
9. **E41** — after E9's arithmetic-expression refinement slice; likely
   dissolves into retirements rather than a feature pass.

### Cross-family flags

- **To E26 (alarms crutch):** confirmed fold-in — `alarms.py`'s exception
  classes become E39 effect names; the typed-result-row pattern
  (`RecvR`/`recv-closed`) is the built incumbent for the recoverable half.
  E26's pass should wait for edge-16 rather than porting exceptions as-is.
- **To E9 (refinement):** E41's bounds-check payoff (6 enumerated checks)
  transfers to E9's arithmetic-expression promotion — E9's dossier should
  claim that payoff list as its acceptance tests
  (`impl_ports.py:198`, `mem-region.chiral:41`, `impl_pure.py:112`,
  `bytes-tal.chiral:100`, `native.py:17` (`ud2`), `sprites.chiral:71`).
- **To E16 (lowering):** `lower.py:296-297` rejects quantified binders (`0/1
  stay upper`); E38 grades widen what "quantified" means — the eligibility
  predicate must project the usage factor, and eventually cost-graded pure
  functions should lower (their grades are claims, not runtime artifacts).
- **To E31 (poll):** E42-A hard-requires pollN; the poll sys-slice should
  design for N fds (a `pollfd` array), not another fixed arity.
- **To E14 (pretty):** grade display (render default cost factors invisibly)
  rides E38 slice 1.
- **Candidate E51 — grade subsumption / Pi grade variance:** "a function
  costing ≤3 where ≤5 is demanded" is subtyping over grades; today `conv`
  demands grade equality on Pi (`kernel.py:284`) and no element owns relaxing
  it. It touches the kernel judgment (variance of grades in domain vs
  codomain position) and should be its own decided element, not smuggled into
  E38.
- **Candidate E52 — fresh type-level brands:** E41's irreducible residue
  (region identity), also wanted eventually by session/protocol typestate
  (edge 14) and any "this port, not a port like it" distinction. No existing
  mechanism; kernel-surface-touching; needs its own decision if ever
  commissioned.
