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

## Queue

| # | run | waits on |
|---|---|---|
| G1 | `research` FD-64, binding time and the lift, with the author's grade strand. **Done 2026-10-01**: every lift surveyed uses a stage marker kept apart from erasure, defined per type and refused at function types and resources; no erasure discipline lets erased data reach run time; no source puts binding time in a grade beside usage counts, and DCC places it beside information flow; the parameter-level marker (Zig `comptime`, Rust const generics) is a smaller complete two-level shape | done |
| G2 | `research` FD-65: do published capability-safe type systems carry authority as a grade or coeffect, how attenuation, delegation and revocation map onto semiring operations, and whether any separates grade algebra, interpretation and runtime enforcement as layers | G1, since both append to `records/findings.md` |
| G3 | a decision note on the frozen factor set and the three layers, for the author's ruling | G1, G2 |

## Rejected

None yet.
