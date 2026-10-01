# Grade architecture: patterns, interpretation, brokers

A discussion in progress, opened 2026-10-01 from the author's session while
`records/author-calls.md`'s lift call (`:118`) waited on research. Nothing here
is settled. It is the relay `.planning/protocol/placement.md` asks for: the
author's words verbatim, what the tree already says, what collides, and what is
queued. A decision note comes after the research below lands.

## The author's words, verbatim, 2026-10-01

> "Should the actual language eventually have a system for the value that is
> theta or wtv being able to be handled specifically by things like the user and
> capability model? Cant we retain the semiring principles if we just.. extend
> how we handle values"

> "i mean simiring built for the basically broker like things that a user and
> capability model will be (because the goal is retaining no ambient authority)"

> "the thing im picturing and trying to confirm if im right too is that
> currently our semiring means putting a little bit too much authority in the
> "broker" for both models, and we need to pull what we can to how semiring gets
> judged. Id imagine its a {semiring patterns - interpretation - brokers} model so
> we can make the semiring patterns modular and extendible with ceremony when we
> do the ceremony stuff and the logic carries to extending or making new brokers
> and extending interpretation"

> "lets continue discussion so this is clear before we do this large rescoping.
> Like i want to make sure that basic semiring can be used, like if something
> runs by itself outside of an capability or user model simiring integrate, able
> to use the basic semiring we have now (because a lot doesnt need the
> interpretation at primitives right? Just making sure we can code some
> primitives like ceremony to have full auth and capability semiring but a tiny
> thing that runs under something with special semiring can just use basic?"

> "Can i also confirm if programming full error handling feedback enough to pre
> prevent if someone rights a basic one under a specifically capable one and
> doesnt do anything about what if someone does some shit they cant? We have
> like. Basically all the information possible in basically all scenarios for a
> lot of error handling and i need primitives to continue to be outlined"

> "I want it to be kinda hard to be able to get a broken program. P sure we
> mathmatically are guaranteed able to solve everything below logic issues
> which is hefty"

> "i want to clarify i meant specifically doesnt compile unless error handled,
> feedback is great even if tests arent thorough (because tests should be for
> logic bugs anyway and we neee a specific different realm of thinking outside
> of this to consider how to require meaningful logical tests as far as coverage
> can be spread by humans and machines over time), and error handling is made
> more convenient/straightforward for all cases we can detect"

## The model as stated

| layer | is | today's nearest home |
|---|---|---|
| semiring patterns | the grade factors the kernel judges, each with its own laws, modular, added by ceremony | the kernel semiring, "parametric over its grade set" (`docs/decisions/decision-graded-kernel.md:43-44`); `lib/typing/qtt.chiral:7` calls the grade instance "the swappable seat" |
| interpretation | what a grade means, shared by the judgment and every broker, including rules that read several patterns at once | Adhikara, "the shared algebra so the static checker and the runtime supervisor agree on what a capability is" (`docs/modules/modules-broker.md:52-53`), today scoped to capabilities |
| brokers | thin runtime components that perform only the irreducibly dynamic events, under the shared interpretation, and can be added | the component broker of `docs/decisions/decision-brokers.md:26-31`, one of two, with the static half dissolved into the type system (`:23-25`, `:30-31`) |

Goal named by the author: no ambient authority, held by the judgment rather
than by the brokers.

## Evidence the author's read is right

Adhikara's invariants are stated as protocol invariants the brokers uphold
(`docs/modules/modules-broker.md:53-55`; `docs/definitions/permission-model.md:103-104`),
and the frozen factor set has no authority factor
(`docs/decisions/decision-graded-kernel.md:39-49`), so the judgment checks none
of them. Each invariant reads as an ordered-semiring law once authority is a
pattern:

| Adhikara invariant | as a law of an authority pattern | what stays dynamic |
|---|---|---|
| monotonic attenuation | multiplication only narrows: `r · s ≤ r` | nothing |
| no spontaneous rights | a term's grade is bounded by what its context supplies, and `0` annihilates | the grant event that supplies it |
| revocation transitivity | a derived right is a product `r · s`, so a revoked `r` zeroes every product | the revoke event, the expiry deadline |
| translation preserves or reduces rights | a monotone map between pattern instances across layers | the wire itself |

So the laws can be judged, and the brokers keep the events: revoke, expiry,
audit reconciliation against live state, and grants decided on runtime facts.
This is `decision-brokers`' own line, *push everything statically decidable into
the type system* (`docs/decisions/decision-brokers.md:30-31`), carried to the
invariants the broker currently holds.

## The basic semiring embeds

The author's requirement: code that mentions only usage, the 0/1/ω semiring
`lib/typing/qtt.chiral:14` holds today, keeps checking unchanged and runs under
a context with richer patterns. A ceremony primitive declares the full
authority and capability patterns; a helper it calls declares none of them.

The shape that meets it: a term written against the basic semiring is read in
the product with every pattern it does not mention left **polymorphic**, taking
its caller's value, and interpretation fixes each pattern's default.

| pattern | default for a term that does not mention it | why that default |
|---|---|---|
| usage | the term's own 0/1/ω | it is the basic semiring |
| authority | none needed | a term that originates no authority is the pure case; authority it is handed as a parameter it carries and never originates, which is the no-ambient-authority property |
| information flow | the caller's label | a fixed `public` default would let a basic helper launder a secret it was handed |
| binding time | either stage | a primitive runs at compile time or run time alike |
| time, space | inferred, or unbounded where no bound is required | a missing claim is no claim, and a context that requires a bound refuses an unbounded callee |

What this buys: primitives consult no interpretation, since every pattern they
leave unmentioned is polymorphic; the checker pays for a pattern only where a
term mentions it; and the 0/1/ω programs in the tree today embed with no change.

The condition it rests on: each pattern needs a default that is safe to assume
for a term that never mentions it. Information flow shows a fixed default can be
unsafe, so the default is chosen per pattern in interpretation, and a pattern
with no safe default makes every term mention it.

## Where a broken program is stopped

The author's aim is that a broken program is hard to get. Under the patterns,
a failure lands in one of two places, and neither is a handler the writer can
forget.

| what goes wrong | where it is stopped | built today |
|---|---|---|
| a basic term reaches for authority it was never handed | refused at check: its inferred requirement exceeds its declared one, which is none | the one bit, E171 and E204, Phases 36 and 37; the authority pattern is planned |
| a term handed a capability does more than the capability allows | refused at check, by subtyping on the narrowed type | the mechanism exists, unwired to grants ([[status-ledger]], the Subtyping row) |
| a grant is revoked, expires or is denied while the program runs | a typed result the caller must case on, and a missing arm is refused | `jg-nonexhaustive`, ENFORCED; the result carrier is `errors-as-values/EV1` (E202), specced |
| a one-shot continuation is dropped | refused at check by linearity | planned, `enforcement/N25` |

What the refusal tells the writer is goal condition 2's subject: a judgment with
evidence naming the right that was missing and where. Today a def, declare or
extern refusal is flattened to text on the shipping path
([[bug-classes]], *A typed refusal is flattened on the shipping path*), so the
feedback the author describes is designed and not yet delivered.

**The author's requirement, 2026-10-01: a program does not compile unless every
detectable error is handled, and handling is made convenient.** Three
mechanisms meet it, and the first two are basic-semiring properties, so they
hold in a helper that mentions no other pattern:

| mechanism | what it refuses | state |
|---|---|---|
| an error result is linear: its error arm carries quantity 1 | dropping a result unconsumed, through `r-usage` | the usage rule is ENFORCED for binders; no carrier is declared linear, and `errors-as-values` states no requirement that a result cannot be dropped |
| a case over a result is exhaustive | ignoring one error arm, through `jg-nonexhaustive` | ENFORCED |
| a failure that crosses a boundary sits in the effect row, and the row is discharged by a handler before the profile boundary | an alarm that reaches `main` unhandled | the row is `enforcement/N25`, designed; handlers are E26's |

Convenience is P4's: `bind` and `map-err` as declared combinators
(`errors-as-values` requirement 1), handlers that keep the plumbing out of the
body, and a refusal that names the missing arms with evidence (goal condition
2). Tests stay with logic, and how a program's logic tests are required is
recorded as territory nobody has ruled on, `records/lenses/unspoken.md` UNS-52.

**What the mathematics guarantees, and what it does not.** A checker can be made
sound for each class, so that it accepts no program with the failure. It cannot
in general be complete as well: any non-trivial semantic property is
undecidable, so soundness is bought by restricting the language (total by
default, bounded refinements), by asking the writer for an annotation or a
proof, or by refusing some correct programs. P4 names that price as the
conservative checker's tax (`PRINCIPLES.md:137-142`). Four things stay outside
the guarantee whatever the language does: a specification that says the wrong
thing, which is the logic error the author already excludes; the checker's own
correctness, which `docs/decisions/decision-self-verification.md` makes
relative and gives to independent judgment cores; channels with no port, such
as timing and cache (`PRINCIPLES.md:108-111`); and the hardware below the
floor.

## Extendible with ceremony

`decision-graded-kernel` froze the factor width so that adding a factor later
would not change the trusted structure (`:44-46`). The author's version replaces
the freeze with ceremony: a new pattern enters as a change to the judgment, and
the judgment changes only by certified succession
(`docs/decisions/decision-reflective-floor.md:9`). The rung-2 ceremony is where
*"the ceremony governs which ports a session holds"*
(`.planning/ROADMAP-RUNG2-CEREMONY-ARC.md:10-11`).

Certified succession is `E45`, build-deferred with the ownership-and-trust track.
At rung 1 the BUILD RULE's rebuild and fixpoint is what succession is, so the
architecture can be laid out now and the ceremony gate joins it when that track
resumes.

## What it collides with

| settled text | what would move |
|---|---|
| `decision-graded-kernel.md:39-49`, point 1 | the factor set gains an authority pattern, and the width becomes ceremony-extensible instead of frozen |
| `decision-graded-kernel.md:66-75`, point 3 | binding time as a pattern (availability), the staging modality kept for multi-stage code; the separate lift call |
| `decision-effect-facets.md:32-38` | authority is held as possession (linear port values) and exercise (the effect row). P2 keeps authority and resource use in one account (`PRINCIPLES.md:63`), so an authority pattern has to subsume or interpret those two; a third account beside them breaks that |
| `decision-brokers.md` | two brokers become a layer of brokers; Adhikara widens from capabilities to every pattern |
| `docs/definitions/permission-model.md:85-102` | the four grant operations, "none a new mechanism", become operations of the authority pattern |

The 2026-10-01 rulings on the row's spelling and the bare `=>`
(`records/author-calls.md:538-539`) stand under any of these; the open question
is what the row is checked as.

## The two factor arguments, as given 2026-10-01

Given to the author in session before this file was opened, and recovered here
from the session's transcript so the reasoning survives it. Neither is ruled.
G3 decides both.

**Binding time as a factor beside usage.** How many times a value is used and
when it is available vary independently: a value known at compile time can be
used once or many times. A new value θ inside 0/1/ω would need meanings for
`θ + 1` and `θ · ω`. As a factor of its own, each binder carries a pair, uses
and availability. `0` stays erasure, and `(ω, static)` is a value needed at run
time and known at compile time, the one value a lift could embed as a constant.
A product of semirings is a semiring, so the laws come with no new proof.
Point 3 keeps binding time out of the semiring because staging concerns when a
value is available (`docs/decisions/decision-graded-kernel.md:67`, `:85`).
Information flow concerns who may see a value, which is equally far from an
amount, and point 1 admits it as a factor (`:39-49`). FD-64 found binding time published beside information flow
(the Core Calculus of Dependency) and nowhere beside usage counts. A factor
cannot give code as a value, quote and splice, which point 3 wants for
multi-stage work. The shape argued for: availability as a factor, with `E57`'s
modality kept for multi-stage code.

**Authority as a factor.** A binder's authority grade is the set of rights the
term needs from its context. In coeffect terms a grade states what the context
must supply, which is what a broker grants.

- `+` joins requirements: two subterms need the union of their rights.
- `·` attenuates along composition: a capability used inside a narrower grant
  is scaled down to it.
- `0` is no authority. It annihilates, and it lines up with the pure `->`.
- Delegation is one dimension of the rights lattice, *may pass on*, as
  `docs/definitions/permission-model.md` already describes it.
- Revocation stays with the component broker, because it is an event in time.

With join as `+` and meet as `·`, a bounded distributive lattice of rights is
a semiring, so the factor sits beside information flow and leaves 0/1/ω alone.
No ambient authority then follows from the typing rules: every right a term
uses appears in its context grade, and only a grant discharges it.
⚑ *2026-10-01, after FD-65: true only where the root grant cannot be minted
from a plain value. See §What FD-65 asks of this file, repair 2.*

**Why the window is now.** The factor list locks when `E38` is built, which is
`enforcement/N30`. Nothing of it is built, so a factor costs planning today and
a change to the trusted kernel after.

## What FD-65 asks of this file, 2026-10-01

Two repairs, owed before `G3` states anything as a law.

1. **Fix the order before stating the invariants.** The law table writes
   attenuation as `r · s ≤ r` in the subset order. The graded papers order the
   set semiring by `⊇` and state the same fact as multiplication increasing.
   The decision note picks one order and writes every law in it.
2. **No ambient authority holds only when the root grant cannot be minted.**
   §The two factor arguments says it follows from the typing rules. FD-65 finds
   the claim true only where a capability cannot be made from a plain value:
   Granule's example grants a set by wrapping `()`, and Hack's default context
   is a large ambient set. Pony's private-constructor token, a capability type
   with no constructor, and Craig et al.'s capability-safe `import` are the
   published shape of the fix. In this tree that shape is a linear port value
   handed down by the profile as the only source of an authority grade.

Three readings it gives the open questions below, unruled: question 1 has no
published case of an authority grade absorbing linear possession, and where a
system holds both, the requirement set plays the effect row's part and the
value bounds it, the has-versus-does split [[decisions/decision-effect-facets]]
already draws; question 5's "none needed" default for authority matches Hack,
Scala and Effekt, and Hack documents that an unbounded polymorphic context
cannot be called from a default caller; and extension by ceremony has no
precedent, since Granule adds a semiring by changing its implementation.

## Open questions

1. Does the authority pattern subsume the effect row, the linear possession, or
   both, and which one becomes the other's view.
2. Where cross-pattern rules live. The lift rule reads binding time, information
   flow and authority at once: lift a value only when it is static, its label
   permits embedding it in the image, and its type is no capability or secret.
   Modularity holds per pattern; rules that read several patterns belong in
   interpretation, declared, or the modularity is nominal.
3. Whether interpretation is in the trusted base, and how small it stays.
4. How a broker is added: what it must declare against interpretation, and what
   the judgment refuses it.
5. Whether every pattern admits a safe default, so the basic semiring embeds
   with the rest polymorphic. Information flow needs the caller's label, never
   a fixed one. A pattern with no safe default would end the embedding.

## Queue

| # | run | waits on |
|---|---|---|
| G1 | `research` FD-64, binding time and the lift, with the author's grade strand. **Done 2026-10-01**: every lift surveyed uses a stage marker kept apart from erasure, defined per type and refused at function types and resources; no erasure discipline lets erased data reach run time; no source puts binding time in a grade beside usage counts, and DCC places it beside information flow; the parameter-level marker (Zig `comptime`, Rust const generics) is a smaller complete two-level shape | done |
| G2 | **Done 2026-10-01, FD-65**: authority is published as a set-lattice grade in Granule, Petricek's coeffects and Hack, with `+` as union, `·` as intersection, `0` the empty set, and attenuation as subsumption; delegation and revocation have no algebraic treatment anywhere, revocation is a runtime forwarder (caretaker, membrane); no source shares one algebra between a static checker and a runtime enforcer; embedding uses a fixed permissive default everywhere and no source defaults an unmentioned grade to a polymorphic one; no source lets an authority grade absorb linear possession. `research` FD-65: do published capability-safe type systems carry authority as a grade or coeffect, how attenuation, delegation and revocation map onto semiring operations, and whether any separates grade algebra, interpretation and runtime enforcement as layers | G1, since both append to `records/findings.md` |
| G3 | a decision note on the frozen factor set and the three layers, for the author's ruling. ⚑ *Ruled 2026-10-01, every part as recommended (*"I take your recommendations"*), register row in [[records/author-calls]]. Next: the decision note under `docs/decisions/`, and the law table restated in superset order* | G1, G2 |
| G4 | the primitive outline, which the author asked to continue: every prelude primitive and extern with its pattern signature (basic only, or which patterns it mentions), its failure modes (bounds, zero divisor, overflow, junk parse) and what it does today on each, and the row that owns it. `enforcement/N20`'s census (E198) and [[bug-classes]] supply most of the rows; `.planning/PRIMITIVES-FOR-NATIVE-TOOLS.md` and `.planning/LANGUAGE-INVENTORY.md` are read first | nothing |
| G5 | a [[bug-classes]] row for an error result discarded unhandled, and the requirement it owes in [[arcs/errors-as-values-arc]]: a declared carrier whose error arm is linear, so a dropped result does not compile | the rescoping |

## Rejected

None yet.
