# chirality — design principles

What chirality commits to, and why. The semantics and type system in
`.planning/projects/02-language-design.md` have to satisfy these. If a choice there contradicts one of
these, the choice is wrong, or the principle is, in which case change it here
first, on purpose.

These came out of bhumi. bhumi's disciplines govern the OS; these govern the
language the OS gets written in.

These are the architecture principles, what the language governs. The
reader's-side principles, how it presents to a human, live in
[docs/definitions/design-principles.md](docs/definitions/design-principles.md).
Regularity is the bridge: "the safe path is the cheap path" (P4) and "make the
language behave as it looks" are the same commitment from the writer's side here
and the reader's side there.

Draft, 2026-06-14. Condensed seven to five on 2026-07-20: an adversarial review
found the old P4 (inert interior) and P7 (tiering) carried no weight independent
of P3 (ports) and P6 (redundancy), and the old P2's real content was its
cost mechanism, not its slogan. The crosswalk at the end preserves existing
P-number citations across the base until a sweep renumbers them. Ordered
foundation-first. Add to it, argue with it, date the big changes.

---

## 1. To control everything, you have to be able to express everything

You can only mediate what the framework can express. Anything that can happen
outside it is, by definition, ungoverned, a hole, and intent does not close holes.
So total control runs backwards from the obvious: build a substrate that can do
anything, so that everything it can do is named and therefore gateable.
Expressiveness is not the enemy of control; it is the surface control acts on.
This is why chirality has to express its own kernel, compiler, runtime, and
self-modifying code, not for power, but because a framework with a gap has an
ungoverned path through the gap.

Expressible is not the same as modifiable from inside, and "gateable" includes
gated shut. The reflective floor is the case that forces the distinction: the
language must be able to *express* its own capability kernel, yet that kernel is
not *reconfigurable from within* the running language, which is what stops
self-modifying code from forging authority through it. The line was drawn
2026-07-27 (`docs/decisions/decision-reflective-floor.md`): the judgment —
kernel-spec + kernel-core — is staged-in and frozen at staging completion,
changed only by certified succession; everything above it is freely reflectable
because it is re-checked. In-place judgment mutation is forbidden as *unsound*,
not as policy.

Example: a sandbox that blocks the syscalls it knows about, running on a kernel
with syscalls it does not model, has a hole at exactly the calls it forgot. A
seccomp filter is only as complete as the syscall table it enumerates. The fix is
never a longer denylist; it is a model that covers the whole surface, so "deny by
default" actually means everything.

## 2. Everything is a process, and the type is the whole cost

The unit of computation is a process with a type. Function, value, statement,
declaration are special cases of process, not separate kinds of thing. A function
is a process whose type says it has no effects. This is not tidiness. If any
category of code opts out of the type, some things are "just functions" the effect
system does not inspect, that category is an ungoverned path, P1's hole restated.
One atom with no exemptions is what makes the effect typing total.

A process's place on the cost gradient is the weight of its type: its effects, the
resources it spends, whether it terminates. An empty signature is the cheap,
composable base case; every effect and every unit of fuel shows up in the type and
makes it heavier. Authority and resource use are not two accounts. They are both
the process's type. This gradient is the mechanism P4 runs on.

Honest limit: exact cost is undecidable, so the type carries an over-approximate
bound, not an exact predictor. And the checker that reads the type is itself a
process with a cost; accounting for the mediator's own budget is unfinished, and
bites first where checking is interactive (the open edges).

Example: in most languages `parse(s) -> Json` looks pure and the compiler agrees,
while it can allocate without bound and never return. In chirality that cost is in the
type, or it does not type-check as cheap. There is no "it is just a function"
exemption hiding the fuel it burns.

## 3. Govern the ports, not the outputs; the interior is free

You cannot enumerate what a program will output. That is undecidable. You can
enumerate the ways it can affect anything outside itself: I/O, the capabilities it
holds, the time and memory it spends. Those are finite, and the framework is total
over them. The space of values stays infinite; the space of ports to the world is
closed and named. A program can compute anything internally, and as long as it
never crosses a port it has no effect on the world, so you govern the membrane it
must cross, not the interior. Crossing a port is the point a computation becomes
checkable, and the point it is mediated. The port-check is the type-check.

The one leak, which is why time and space are ports too: interior compute still
spends time and memory, so non-termination and unbounded allocation affect the
world by *running* rather than by calling. They sit on the membrane next to I/O,
not implicit in the interior.

**What this makes programming.** Read forward rather than as a restriction:
**programming in chirality is coordinating port boundaries and writing the logic
that produces their inputs.** The boundaries are the program's shape. Everything
else is the computation that feeds them, and it is free precisely because it is
not the shape.

That is the working outlook, and it decides things. A directory named for a
subject rather than for boundaries is a category error: `lib/ports/` holds files
that *declare* a crossing and nothing else, and three modules that merely
computed over crossings moved out on 2026-08-31 because being *about* ports is
subject matter. A module's interface is the boundaries it names; a design
question is answered by asking which boundary it moves. Time and space stop
reading as an exception bolted onto I/O and read as what they are: the boundary
with the substrate you are running on.

Honest limit: "closed and named" is only as complete as the channel model.
Timing, cache pressure, and speculation are effects on the world with no explicit
port, and two processes with disjoint port sets can still signal through a shared
cache. That is P1's seccomp hole one level down. Closing it is the
security-properties layer's work (constant-time, information-flow, taint), named
here rather than waved away, and how far the membrane reaches inward is open.

Example: a regex that ReDoS-es never opens a file or a socket. To an I/O-only
effect system it is pure and harmless, and it still pins a core indefinitely.
Treating time and space as ports is what catches it.

## 4. The safe path should be the cheap path

Do not enforce good behavior by listing the bad and forbidding it. A denylist is
fragile and never complete. Enforce it by making the well-behaved shape (typed,
bounded, terminating) the easy, default, low-ceremony thing, and the risky shape
the one you opt into loudly. Then most code is safe not because the author was
careful but because safe was the path of least resistance. The model is physics,
not policy: nothing forbids a wild outcome, the dynamics from P2's cost gradient
just do not trend toward it, so code settles into the cheap, checkable region on
its own.

Honest limit: "cheap" is two things, and this principle only cleanly governs one.
Writer-side ceremony is smooth (an empty type is low-ceremony, a heavy one is a
climb). Runtime cost is not (isolation and copying at a port boundary are a step,
not a slope), so the gradient has a cliff at the isolation boundary. And "safe is
cheap" holds only as far as the checker accepts naturally-safe code without
ceremony; where a conservative check cannot see safety, the tax lands on safe code
and the opt-out annotation stops being a signal. What gets sacrificed when that
bet fails (reject some safe code, demand annotation, or coarsen the type) is a
decision owed, not settled here.

Example: make partial the marked case. Functions are total unless annotated
otherwise. The common case is then provably terminating, and a programmer who
wants unbounded recursion has to say so. The annotation is the climb; total is the
default downhill.

## 5. Where proof runs out, split the truth and require agreement

Some things cannot be brought under a type as a proof: DMA, raw pointers, hardware
that writes memory with no MMU in the path. For these there is no single provable
source of truth. Instead you keep several independent representations and require
them to agree; disagreement is how you notice one was corrupted. A single source
of truth is right when the thing is provable (P2, the type is the proof) and wrong
when it is not, because in the unprovable region one copy means you can never tell
it changed.

Verb honesty: this principle is detection, where P1 through P4 are prevention. In
the DMA example the actual safety comes from the IOMMU *denying* the write; the
several-truths reconciliation only *notices* a drift after it happens. Name that
downgrade rather than let "governable" imply "prevented."

The tiering is the operational detail. Splitting a truth is three separate goals:
keep it secret (no unauthorized read), keep it honest (no undetected change), keep
it available (survives loss). Different mechanisms buy different ones, so name the
tier you mean.

| Rung | How it is held | Buys | Catch |
|---|---|---|---|
| T0 | Typed singleton | secrecy + integrity, by proof | only for the typeable, but there one copy is correct, proven |
| T1 | N copies, compared | integrity for the untypeable | the writers must be independent, not just the copies. One writer updating all N gets agreement that is all wrong. No secrecy. |
| T2 | Shamir split, K-of-N | secrecy + availability + split authority | one share is meaningless; combine only inside a guarded process. Not tamper-evident. |
| T3 | Verifiable split (VSS / robust) | T2 plus integrity | commitments or robust decoding catch a tampered share and name it; tolerate *t* bad shares |

Plain Shamir (T2) hides a secret but will not notice a tampered share, which just
reconstructs the wrong value silently. Tamper-evidence is T3. So anything where
silent corruption matters lives at T1 or T3, never T2. Two things stack on top:
operate on the shares and never reassemble the secret, so there is no moment it
exists in one place to steal; and layer independent splits so breaking one gets
nothing. Note the reconciler itself is a trusted component, a T0 singleton
guarding T1 material, whose own trust is assumed, not derived.

The default is the point: declaring a split should be as cheap as declaring a
variable (P4), so splitting sensitive state is normal, not a project. In chirality
that is one type, a split value whose only exit is a guarded combine-process, whose
shares are move-only and zeroed on drop, whose reconstruction is an effect, and
whose verification is in the type. Secret-sharing, capabilities, effects, and
linearity are then the same construct.

Do what you can, and name it. The tiers above are a ladder for every held truth, not
only secrets: containment, independence, and verdict integrity each have their own
rungs. A requirement names the minimum rung per axis it needs, and where finite
resources force a lower rung, the shortfall is a visible fact in the type, not a
silent hole. Proprietary and un-auditable components are seated at their honest rung
and contained at the floor (their port set) rather than pretended away. Spend the
strong rungs where they are load-bearing; floor the rest on purpose. See
`docs/definitions/split-role.md`.

Honest limit: "zeroed on drop" is a language-semantics promise the machine can
break, through register spills, compiler-introduced copies, swap, and dead-store
elimination of the zeroing write itself. That is a P5 problem inside P5's own
feature; carrying zeroing as a property checked down to the typed-assembly floor is
the intended answer, unfinished.

Example: a three-tier lock (cold, soft, hard, distinct passphrases) and quorum
key-release are tiered truth done by hand in Rust today. The principle is that
chirality expresses them directly, instead of each tool re-implementing the ceremony.

---

## Crosswalk (old seven to new five)

Notes across the base still cite the old P1 through P7. They resolve through this
table until a sweep renumbers them, the same in-flight-rename discipline the
`door` to `port` change used.

Convention during the rename window: a doc **written or updated after the
2026-07-20 condensation cites the new five directly** — that is this file's own
current usage, so it needs no crosswalk. The crosswalk resolves *pre-condensation*
citations only. Since P6 and P7 exist solely in the old scheme, a citation of P6 or
P7 is always old; P1–P5 in a post-condensation doc are always new. (The ledger-lint
check B flags P6/P7 in any doc dated after the condensation.)

| Old | New | Fate |
|---|---|---|
| P1 express everything | **1** | kept, refined with expressible-vs-modifiable |
| P2 everything is a process | **2** | kept; its real content is the cost gradient |
| P3 govern the ports | **3** | kept |
| P4 compute is inert until a port | **3** | folded: the interior-free view is the inside of govern-the-ports, and its own caveat (time and space are ports) is now P3's core |
| P5 safe path is cheap path | **4** | kept, with the two-cheapnesses limit |
| P6 split what you cannot type | **5** | kept |
| P7 tier how you hold a truth | **5** | folded: the tiering is P5's operational detail, as the old text already said |

---

## Open edges (resolve in the language-design project)

- **Non-process boundary** (1 vs 5): where pure description ends and untypeable
  substrate begins, and whether type-level computation counts as a process.
  **Shaped 2026-07-25** (`docs/definitions/open-edges.md`, edge 1): the boundary is
  the membrane already drawn — B is a small named set of holes reached through the
  bridge, and type-level computation performs no crossing, so it is description,
  not process. Residue: whether a check-time call to an untyped oracle puts a
  crossing into the elaboration's own effect row.
- **How far the membrane reaches inward** (3): I/O for sure, time and space
  necessarily; termination, information flow, covert channels. Grade them or scope
  them out on purpose. **Largely answered**
  (`docs/decisions/decision-graded-kernel.md`,
  `docs/decisions/decision-effect-facets.md`; the info-flow seat shaped
  2026-07-25):
  crossings are the effect row, spends are grades, partiality is the mark, and
  information flow holds a reserved lattice-valued grade seat, with
  non-interference a typed proof over that grade rather than the grade itself.
  Residue: the concrete secrecy lattice and its declassification rule, and a
  declassifying crossing's interaction with the effect row.
- **The cost gradient's mechanism** (2, 4) — **settled**
  (`docs/decisions/decision-graded-kernel.md`, 2026-07-05; amended by
  `docs/decisions/decision-effect-facets.md`, 2026-07-21): a parametric coeffect
  semiring enriching QTT's grades; totality a property beside them; staging a modality.
  The mediator's-own-budget clause remains open inside edge 3's residue.
- **What picks a value's default tier** (5): a per-value annotation, or a
  classification carried in the type that auto-selects the minimum rung, so
  forgetting to split a secret is a type error. Resolved in direction,
  broadened (edge 4); not settled.
- **The reflective floor** (1) — **settled**
  (`docs/decisions/decision-reflective-floor.md`, 2026-07-27): the judgment is frozen at
  staging completion, changed only by certified succession; the line sits at
  the provable boundary (what the trusted core cannot certify from inside). Still
  owed: state handover across relaunch, and staging economics (unmeasured).
- **Govern the mediator, resolved structurally not as a principle.** If the
  port-check is the type-check (3), the checker is the maximal-authority process,
  and self-hosting makes its trust circular (trusting-trust). The answer is not a
  sixth principle that says verify the checker, and it is not a quorum. The checker
  cannot prove *itself* but can be proven against an external spec, so it is a small
  trusted core that re-checks untrusted producers' certificates (the LCF / de Bruijn
  discipline), the trusted base shrunk to the audited spec plus that small core. See
  `docs/decisions/decision-split-checker.md` and
  `docs/definitions/certificate-discipline.md`. Agreement across independent
  sources is reserved for the genuinely-unprovable residue
  (`docs/definitions/split-role.md`).
