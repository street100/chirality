# chirality — design principles

What chirality commits to, and why. `.planning/projects/02-language-design.md` must
satisfy these; if a choice there contradicts one of them, the choice is wrong or the principle
is. Change it here first, on purpose, either way. Bhumi's disciplines govern the OS; these
govern the language that OS gets written in. The reader-side principles live in
`docs/definitions/design-principles.md`; regularity bridges: P4 and "make the language behave as
it looks" are one commitment from each side. Condensed seven to five on 2026-07-20; old citations
resolve through the crosswalk at the end. Ordered foundation-first; date the big changes.

## 1. To control everything, you have to be able to express everything

You can only mediate what the framework can express; anything outside it is ungoverned,
a hole, and intent does not close holes. So chirality must express its own kernel,
compiler, runtime, and self-modifying code: a gap in the substrate is an ungoverned path
through, and the fix is never a longer denylist but coverage of the whole surface.

Expressible is not modifiable from inside. The language must *express* its own
capability kernel (the case the reflective floor forces), yet that kernel is not
reconfigurable from within the running language, which stops self-modifying code from
forging authority through it; in-place judgment mutation is forbidden as *unsound*, not
as policy. `docs/decisions/decision-reflective-floor.md` (2026-07-27) draws the line: the
judgment (kernel-spec + kernel-core) staged-in and frozen at staging completion, changed
only by certified succession; everything above it freely reflectable because it is
re-checked.

## 2. Everything is a process, and the type is the whole cost

The unit of computation is a process with a type; function, value, statement, declaration
are special cases, not separate kinds. No category opts out of the type (P1's hole). An
empty signature is the cheap composable base case; every effect, fuel, authority sits in
the type and makes it heavier (the gradient P4 runs on; see Open edges).

Honest limit: exact cost is undecidable, so the type carries an over-approximation. The
checker that reads the type has a cost of its own; accounting for the mediator's budget is
unfinished, and bites first where checking is interactive (Open edges).

## 3. Govern the ports, not the outputs; the interior is free

What a program will output cannot be enumerated (undecidable); every way it can affect
the world outside itself can: I/O, capabilities held, time and memory spent. Finite,
framework-total there; the value-space stays infinite/free. Crossing the membrane is
where computation becomes checkable and mediated; that crossing *is* the type-check.

Time and space are ports too: interior compute still spends them, so non-termination and
unbounded allocation affect the world by *running*, not by calling (this catches ReDoS).
They sit on the membrane beside I/O as what they are: the boundary with the substrate you run on,
not an implicit interior cost.

**What this makes programming.** Read forward rather than as restriction: **programming in
chirality is coordinating port boundaries and writing the logic that produces their inputs.**
The boundaries are the program's shape; everything else stays free because it isn't shape. A
directory named for a subject rather than for boundaries is category error. `lib/ports/` holds
files that *declare* a crossing and nothing else (three modules that merely computed over
crossings moved out on 2026-08-31); a module's interface names the boundaries it moves. A design
question resolves to "which boundary do I move?"

Honest limit: "closed and named" holds as well as the channel model does. Timing, cache pressure,
speculation are world-affecting effects with no explicit port; covert channels between processes
with disjoint port sets run through a shared cache. That is P1's seccomp hole one level down.
Closing it is security-properties layer work (constant-time, information-flow, taint); named
rather than waved away, and how far the membrane reaches inward is an open edge.

## 4. The safe path should be the cheap path

Do not enforce good behavior by listing and forbidding the bad. A denylist gets nowhere. Make
well-behaved (typed, bounded, terminating) the easy default and risky opt-in loud: most code is
safe because safe was *the* cheap path, not because authors are careful. The model is physics,
not policy: nothing forbids a wild outcome; dynamics just don't trend there (P2), so code settles
into the checkable region on its own.

Honest limit: "cheap" is two things and P4 cleanly governs only one. Writer-side ceremony is smooth
(an empty type is low ceremony, a heavy one is a climb). Runtime cost isn't: isolation or copies at a
boundary are not a slope but a step (a cliff in the gradient at the membrane). And "safe is cheap"
holds only as far as the checker accepts naturally-safe code without ceremony. Where its conservative
check can't see safety, the tax lands on safe code and the opt-out annotation loses its signal; what
gets sacrificed there (reject some safe code / demand annotations / coarsen the type) is a decision
owed, not answered here.

Example: make partial the marked case. Functions are total unless annotated otherwise. The common case
is provably terminating; unbounded recursion has to say so. Annotation is the climb; totality is the
downhill default.

## 5. Where proof runs out, split the truth and require agreement

Some things won't come under types as proofs: DMA, raw pointers, hardware that writes memory with no MMU in the path. No single provable source of truth is available for them; keep several independent representations and *require* they match. Disagreement is how you notice one was corrupted. A single source of truth is right where proof applies (P2: type-as-the-proof), wrong otherwise, because without a proof you can't detect if a copy changed.

Verb honesty: P1 through 4 are prevention; this is *detection*. In the DMA example the actual safety comes from the IOMMU *denying* the write; multi-truth reconciliation only notices drift afterward. Name that downgrade rather than let "governable" imply prevented.

Tiering is the operational detail: splitting into three separable goals, keeping secret, honest, and available; different mechanisms gain different ones, so name the tier you mean (see `docs/definitions/split-role.md`).

| Rung | Holds how             | Buy                              | Catch                                                    |
| ---- | --------------------- | -------------------------------- | -------------------------------------------------------- |
| T0  | typed singleton       | secret + integrity by the proof  | only what's typable; there one copy is the right call.   |
| T1  | N copies, compared    | untypable for honesty            | need writer independence (one writer updating all N gives a match). No secrecy.                 |
| T2  | Shamir K-of-N                  | secret + availability + split authority | shares meaningless alone; combine inside guarded process only; not tamper-evident.        |
| T3  | verifiable split (VSS/robust) | T2 plus integrity       | commitments/named catches a corrupted share and names it; tolerates *t* bad shares.          |

Plain Shamir hides but doesn't notice the tampered one, which silently reconstructs the wrong value, so anything for whom silent corruption matters lives on T1 or T3 and never T2. What stacks up: operate on shares without joining (no moment to steal); layer independent splits (breaking one gives nothing at the end). The reconciler itself is a trusted component: the T0 singleton defending T1 material. Its trust is an assumption, not derived.

The default is the point: declaring a split should be as cheap as declaring a variable (P4), so splitting sensitive state stays normal and not project. In chirality that's one type whose only exit is guarded combined process, shares are move-only and zeroed-on-drop, reconstruction is an effect, verification sits in-type: secret-share, capability, effects, linearity all become *the same construction*.

Do what you can and name it once more: the ladder above holds for every true value. Containment, independence, verdict integrity each earn their own rung; if finite resources force a lower rung, that shortfall is a visible fact inside type (not a silent hole). Proprietary components and audited-down ones sit at *their* honest rungs **and** at the floor of containment (port set); they are not pretended away. Spend strong rungs where the load bears; floor intentionally all the rest.

Honest limit: "zeroed on drop" is a language-semantics promise machines can break, via register spills, compiler-introduced copies, swap (and even dead-store elimination of the zero write itself). That's P5 inside its own feature; carrying zeroing down to typed-assembly floor-as-checked-property is the intended answer. Unfinished.

---

## Crosswalk (old seven to new five)

Pre-condensation notes still cite old P1 through P7; they resolve this way until a sweep renumbers, the same in-flight-rename discipline used for `door` to `port`. Docs written or updated after the 2026-07-20 condensation cite the new numbers directly (this file's own current usage needs no crosswalk); the table below only resolves pre-condensation citations. A post-condensation doc cannot mean P5-new without meaning it, and per ledger-lint check B any P6/P7 citation is old.

| Old | New | Outcome |
| ---- | ---:| ------ |
| P1  express-everything    | **1**   | Keep; sharpened to expressible/modifiable            |
| P2  all processes        | **2** | keep; real content is the cost gradient              |
| P3  ruling over ports     | **3** | keep |
| P4  compute inactive until it crosses into ports || **3**: absorbed — inner free-view is just inside-of "ruling-over-ports"; its own caveat (time/space being ports) now core of P3 |
| P5  safe path is cheap    | **4** | keep, with two kinds of cheap limits in hand           |
| P6  split what can't be typed | **5**   | keep |
| P7  layers for holding true     || **5**: absorbed — already operations detail inside old text  |

## Open edges (to resolve in the language-design project)

- **Non-process boundary** (1 vs 5). The membrane B is a named small set of hole-crossings through a bridge; type-level computation crosses nothing, so it's description not process. Residue stays: whether an untyped oracle at check-time folds crossing into its own elaboration effect line (`docs/definitions/open-edges.md`, edge 1, shaped 2026-07-25).
- **Membrane reach into interior** (3): I/O for sure, time/space necessarily; grading termination, information-flow, covert channels or scoping-out on purpose — mostly answered by effect facet seats in decision `decision-graded-kernel.md` + `decision-effect-facets.md`; info flow holds reserved lattice-valued grade seat with non-interference as typed proof over the grade not in it. Residues: concrete secret lattices + declassification rules, and interaction of a declassifying crossing with effect line.
- **Cost gradient mechanics** (2, 4): settled 2026-07-05, amended 07-21 — parametric Coeffect semiring enriching QTT grades; total property besides them; staging is modality (`decision-graded-kernel.md`).
- **What decides value's default tier** (5) — direction resolved and broadened (edge 4), not settled.
- **Reflective floor** (1): settled 2026-07-27; boundary sits at *provable* boundary (trusted core can't certify from within). Stands to be done: state handover across relaunched stages, staging cost (unmeasured).
- **Ruling the mediator**, resolved structurally not as principle: checker is the strongest-authority process, self-hosting makes trust circular — but it cannot prove *itself*, and can be proven against external spec; LCF/de Bruijn discipline shrinks trusted base to small core rechecking non-trusted producers' certificates onto audited specs (`docs/decisions/decision-split-checker.md`, `certificate-discipline.md`). Matching across independent sources reserved for the genuinely unprovable residues only (see split-role).
