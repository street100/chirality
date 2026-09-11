# Bounds author calls: the relay

The five author calls raised 2026-09-10 by the enforcement arc's RESCOPE
(`records/enforcement-arc.md` EN-31, rows added to `records/author-calls.md` in
commit `1b692e5`). One section per call. Each section is a **proposal** and none
is a ruling.

**What this file is not.** Routing is not a ruling, an analogy is not a ruling,
and a session agreeing with a row is not a ruling. Four commits on 2026-09-06
closed eighteen author calls by routing and every one had to be reverted
(`records/author-calls.md`, the Restored 2026-09-07 banner). Every row in
`records/author-calls.md` stays `unreviewed` until the author says otherwise,
and no run that writes here may touch that file.

One call per run. Sections are written in the order the arc lists them.

---

## Call 1: A sixth done-condition for `docs/goals/enforcement.md`, memory safety

**PROPOSAL. Not a ruling.** The row at `records/author-calls.md:362` stays
`unreviewed`. Written 2026-09-10 against the tree at `bc8f4e2`. No file outside
this one was written by the run that produced this section.

### 1.1 The call, quoted verbatim

From `records/author-calls.md:362`, the row's second and third cells entire:

> **A sixth done-condition for [[goals/enforcement]], memory safety** · Opened
> 2026-09-10 by the enforcement arc's RESCOPE, `records/enforcement-arc.md`
> EN-31. | The goal's five conditions are about ledger rows, the tal floor,
> checker agreement, gate mutants and native tooling, and none observes whether
> a program can read outside a buffer. The goal's own State section names bounds
> among the five things the vocabulary cannot say, and
> `docs/definitions/bug-classes.md`'s "buffer overread and overwrite" row reads
> `none` with a blank element cell. Against: condition 1 is the general form and
> bounds is one class among 28, a condition per class turns a five-condition
> goal into a checklist, and `bug-classes.md` is `status: draft` and says a class
> with no element is expected. Authoring an ambition is the author's, so the
> revisit wrote no condition and four rows sit under a goal that may not claim
> their subject

The defect itself is established and is not re-derived here: `str-sub`, `bslice`
and `bget` read outside their buffers today, measured against the committed
binary and recorded at `records/enforcement-arc.md` EN-31 (`:354`).

### 1.2 The prior question answered: does the project already claim memory safety

`docs/arcs/README.md:35` reads *"Authoring a goal the project has never stated is
forbidden"* and `docs/goals/README.md:138-139` reads *"Adding a goal means citing
where the project already claims it."* So the call turns on whether the subject
is already claimed. The strict test used below: a **claim** says the project is
doing or has something. A **description** records a fact, a gap or a class. The
repo draws that line itself at `README.md:80-82`, which says *"Much of what
follows is a goal rather than a shipped thing"* and points at the table at
`README.md:236-243` as the separator.

**What is a claim.**

| statement | where | what it claims |
|---|---|---|
| "Non-logical bugs are mechanical solve guaranteed … the goal is that everything is a type carried from upper to lower before translation to machine code", citing `enforcement` and `bug-classes` | `README.md:23-28` | the whole non-logical class at programme strength. Buffer overread is inside it |
| "Give the dangerous thing a type and there is no door to reach for", citing `enforcement` | `README.md:42-45` | the escape hatch. Not the bound |
| "The bet is that everything can be expressed. That makes this a mechanical job. A class can be given a way to be said, and once it can be said the checker can refuse it." | `docs/definitions/bug-classes.md:14-16` | the programme over all 28 classes |
| "refinement carries bounds (converged; folds integer safety)" | `docs/definitions/memory-model.md:53` | that the mechanism for bounds is refinement, and that the fork is settled |
| "Memory bounds-safety and refinement are one chain, not two" | `docs/banks/memory.md:263-264` | the same, from the depth tier, grounded in the conformance map |
| "non-termination and unbounded allocation affect the world by *running* rather than by calling. They sit on the membrane next to I/O" | `PRINCIPLES.md:88-90`, `:103-105` | that space is a port. The commitment sits at the tier that governs the language |

**What is description, strictly.**

| statement | where | why it is not a claim |
|---|---|---|
| "buffer overread and overwrite \| bounds on indexing \| none. `str-sub` reads past its buffer today" | `docs/definitions/bug-classes.md:46` | a row in a list, with a blank element cell. The file is `status: draft` (`:5`) and `:19-22` says *"Adding a class with no element is expected"* |
| "no constructor exists for effects, termination, bounds, overflow or ABI agreement" | `docs/goals/enforcement.md:99-100` | inside `## State`, which `docs/goals/README.md:133-134` defines as where the goal stands. Naming an absence is not claiming the thing |
| "Time and memory are crossings too", and the `space as a crossing` row | `docs/goals/enforcement.md:108-109`, `:117` | both are subsections of `## State`, for the same reason |
| "An open set of classes is a program of work rather than a property the language has. Naming a class and checking it well are different achievements" | `docs/goals/enforcement.md:148-150` | the goal declining to convert the class list into a claim. This is the sharpest against-side sentence in the tree |
| "the whole reachable language is memory-safe with no forgery escape hatch" | `docs/definitions/trust-boundary.md:104-106` | memory safety appears as the precondition of a different claim, and `:114-115` states the guarantee as *"against an adversary by nothing yet"* |
| "a memory-safety hole in a language whose thesis is that such holes are untypeable" | `docs/elements/catalog.md:490` | a catalog row about one defect. It invokes a thesis and states none |

**The answer, in three parts.**

1. **The project claims the territory.** `README.md:23-28` and
   `docs/definitions/bug-classes.md:14-16` are claims, each citing the other, and
   the class at `bug-classes.md:46` is inside both. `PRINCIPLES.md:88-90` puts
   space on the membrane as a commitment. So the ambition is stated and
   `docs/arcs/README.md:35` does not bite.

2. **The claim is general and never names the subject.** `README.md:236-243`, the
   table this repo designates as the separator between claim and state, holds six
   rows: typed assembly, process-with-a-type, cost in the type, closed crossings,
   readable and self-hosting, frozen judgment. None is memory, bounds or
   indexing. Nowhere does the tree write that chirality is memory-safe or that it
   refuses an out-of-range index.

3. **`docs/goals/enforcement.md` does not claim it in the one section where a
   goal makes claims, and its cited authority does.** `## The claim, and where
   the project makes it` (`:11-21`) carries four bullets: the four rungs, the
   `MAP.md:86` ports rule, the SEEDED rung, and at `:16-17` **`PRINCIPLES.md` §3**.
   §3 is the principle that puts space on the membrane. Memory appears elsewhere
   in this goal file only under `## State`. So the goal's own cited authority
   covers the subject and none of the goal's five conditions observes it.

Part 3 is the whole prior question and it changes the act being proposed. A sixth
condition is not authoring an ambition the project has never stated. Whether it
**records** an existing claim or **widens** one is what is left, and
`docs/goals/README.md:140-141` already routes the second: *"Changing what a goal
claims changes what its arcs are for, so it is a decision and belongs in
`docs/decisions/` first."*

### 1.3 The two sides as the tree states them

**For a sixth condition.**

| what the tree says | where |
|---|---|
| the five conditions name ledger rows, the judgment vocabulary, the tal floor, gate mutants and native tooling. None names memory, a bound or an index | `docs/goals/enforcement.md:25-41` |
| the goal's own claim section cites `PRINCIPLES.md` §3, and §3 is where space becomes a port | `docs/goals/enforcement.md:16-17`, `PRINCIPLES.md:88-90` |
| the arc opened a fourth group for this subject because "none of them holds a rule that refuses an out-of-range index" | `docs/arcs/enforcement-arc.md:482-488` |
| four rows now sit in and beside that group, all `unminted`, and the band they would mint from is spent | `docs/arcs/enforcement-arc.md:509`, `:511`, `records/enforcement-arc.md:356` |
| the suite reads `412 passed, 0 failed` over a primitive that segfaults, because requirement 6 quantifies over rows that exist | `records/enforcement-arc.md:354` |

**Against a sixth condition.**

| what the tree says | where |
|---|---|
| condition 1 is the general form and quantifies over ledger rows | `docs/goals/enforcement.md:25-27` |
| the class list is a draft that expects rows with no element | `docs/definitions/bug-classes.md:5`, `:19-22` |
| the goal already declines to make the class list a property | `docs/goals/enforcement.md:148-150` |
| a goal carries no build state, so a condition cannot grade the class | `docs/goals/README.md:133-137`, `README.md:190-192` |
| changing what a goal claims is a decision before it is a condition | `docs/goals/README.md:140-141` |
| authoring an ambition the project has never stated is forbidden | `docs/arcs/README.md:35` |

**A third fact belongs to the for side and the call does not carry it: this tree
already enforces a bound, in one place, by killing the process.**
`lib/lowering/tal/sys.chiral:1006-1009` states the doctrine: *"A real bounds
violation is a corpse: on size<=0 or off/len out of range the body takes the
arena-fail shape (exit_group(-EINVAL), never returns) … so a fatal exit is
control flow, not a value sentinel."* `nb-arena-fail-t` is a live `ti-sys 231`
(`:118-122`) and `nb-arena-commit-t` reaches it on a ceiling overrun
(`:139-141`). So one carrier of the space boundary refuses an out-of-range offset
by dying, and the other returns a `Bytes` of 99 over a 3-byte buffer at exit 0
(`records/enforcement-arc.md:354`). No done-condition of this goal observes the
difference. `records/diagnostics-arc-record.md:248` measured the same asymmetry
from the repair side on 2026-09-10 and made the trap question 9 of
`docs/arcs/parts/diagnostics-L5.md` §5, `NEEDS-AUTHOR`; that is **call 3**'s
territory and is not reopened here.

### 1.4 The principle-by-principle test

`PRINCIPLES.md` is the authority under test. Bare line numbers are that file.
`PRINCIPLES.md:3-6` fixes its own subject: *"The semantics and type system in the
design base … have to satisfy these."* The subject is the language. Goals, arcs,
conditions, rungs and rosters appear nowhere in the document. That fact does most
of the sorting below and it is a result rather than an excuse.

#### P1, to control everything, you have to be able to express everything

**Decides the subject. Silent on the instrument.**

> "Anything that can happen outside it is, by definition, ungoverned, a hole, and
> intent does not close holes." (`:25-26`)

> "build a substrate that can do anything, so that everything it can do is named
> and therefore gateable." (`:27-28`)

A read outside a buffer is a thing the substrate does that nothing names. P1 puts
it inside what must be governed, with no qualification, and that settles half the
call: memory safety is not optional territory the goal may decline. P1 says
nothing about which document records the obligation, because no document tier is
in its scope.

**Where it reads onto the instrument, and only by analogy.** The seccomp figure
(`:47-50`) is the against side's argument inverted: *"The fix is never a longer
denylist; it is a model that covers the whole surface."* Read at the goal tier
that argues for the general form and against one condition per class, which is
the *against* side's own position arriving by the *for* side's route. The figure's
subject is a syscall table and not a condition list, so this section names the
analogy and does not lean on it.

**On the Honest limit.** Call 3 §3.3 established that P1 carries no paragraph
labelled *Honest limit* and that its qualifying paragraph is the reflective floor
(`:34-43`), whose subject is in-place judgment mutation. That holds here and is
not re-derived.

#### P2, everything is a process, and the type is the whole cost

**Decides one premise of the against side and is silent on the call.**

> "If any category of code opts out of the type, some things are 'just functions'
> the effect system does not inspect, that category is an ungoverned path, P1's
> hole restated. One atom with no exemptions is what makes the effect typing
> total." (`:55-58`)

The against side's strongest sentence is that bounds is one class among 28.
P2 refuses that arithmetic. `(extern str-sub (-> Str I64 I64 Str))`
(`lib/prelude/prelude.chiral:83`) is a signature the runtime falsifies, which is
the no-exemption clause violated by a live declaration rather than a row on a
draft list. A class whose instance is a principle violation is not
interchangeable with `config drift` (`docs/definitions/bug-classes.md:79`).

What P2 does not do is say that a goal must observe it. The type is the whole
cost is a rule about the language's atoms, and a done-condition is not an atom.

**On the Honest limit** (`:66-69`). Call 3 §3.3 established that the
over-approximation clause licenses an approximate *cost* and not a misstated
domain, so it does not rescue the signature that ships. That reading is carried,
not re-derived. Its second clause, the mediator's own budget, has no bearing on
this call.

#### P3, govern the ports, not the outputs; the interior is free

**Decides, and it carries the proposal.**

> "You can enumerate the ways it can affect anything outside itself: I/O, the
> capabilities it holds, the time and memory it spends. Those are finite, and the
> framework is total over them. The space of values stays infinite; the space of
> ports to the world is closed and named." (`:77-81`)

> "Time and space stop reading as an exception bolted onto I/O and read as what
> they are: the boundary with the substrate you are running on." (`:103-105`)

This is the principle that decides what kind of thing memory safety is. Under P3
it is not a bug class beside 27 others. It is one of three named port families,
and the goal that already cites P3 as one of the four places this project makes
its claim (`docs/goals/enforcement.md:16-17`) has therefore already claimed the
territory its conditions do not reach.

**Where P3 is thinner than it looks, stated because it matters.** P3's own
examples of the space port are *spends*: unbounded allocation and non-termination
(`:88-90`), and a ReDoS that pins a core (`:119-121`). Reading 96 bytes past a
3-byte buffer spends nothing extra. The clause that fits it is the middle item of
P3's own three-item enumeration at `:78-79`, **the capabilities it holds**: a
buffer handed to a routine is the exact extent of an authority, and an index
nothing bounds exercises authority the routine was never handed. That reading is
available in the text and P3 does not spell it. A reader who takes the space port
to mean spends alone gets a weaker P3 here, and the proposal below would then
rest on `:77-81`'s closed-set sentence alone.

**On the Honest limit** (`:107-117`), which cuts:

> "'closed and named' is only as complete as the channel model."

The limit names its own residue as *"the grade domains' mechanization, E38, and
filling info-flow's reserved seat"*. An unbounded index is neither a grade domain
nor, on the tree's current reading, an information flow. So the limit's own
enumeration of what stays open does not have a seat for this defect, which is the
limit applied to itself.

#### P4, the safe path should be the cheap path

**Silent on this call.**

P4 governs how a shape presents to a writer. Its whole apparatus, the ceremony
gradient, the marked partial case (`:144-148`), and the Honest limit about the
conservative checker taxing safe code (`:138-142`), bears on **which repair to
build**, which is `records/author-calls.md:364` and is call 3's subject, already
written at §3.3 above. Nothing in P4 speaks to whether a goal observes a
property. Its denylist sentence (`:125-126`) reads onto the instrument by the
same analogy P1's seccomp figure does and adds nothing P1 did not already carry.

Saying P4 is silent is the result. Stretching it to cover a document tier would
be the error this test exists to avoid.

#### P5, where proof runs out, split the truth and require agreement

**Silent on the call, and its own T0 row says why.**

> "T0 | Typed singleton | secrecy + integrity, by proof | only for the typeable,
> but there one copy is correct, proven" (`:171`)

`docs/banks/memory.md:257-259` already places this property inside the typeable
region: *"'The write is in bounds' is **not** a runtime memory-safety check in the
compile-time-provable case."* A property at T0 belongs to P2's regime, and P5
starts where proof runs out. No rung of T0 through T3 describes a range check,
and nothing here is a held truth with copies.

**Its one bearing clause is about visibility.**

> "Do what you can, and name it. … where finite resources force a lower rung, the
> shortfall is a visible fact in the type, not a silent hole." (`:191-195`)

A class that no judgment can say, under a suite that reads `412 passed, 0 failed`
(`records/enforcement-arc.md:354`), is a shortfall that is not visible anywhere a
reader looks. P5 asks that it become visible. It does not say the instrument is a
done-condition, and `enforcement/N21` is a row already scoped to the mechanical
half of exactly that visibility.

**On the Honest limit** (`:202-208`), which is a precedent rather than an
argument. P5 ends by demoting its own construct: *"the construct itself is a seed
rather than a built thing … so the sentence above states a design and not a
capability the tree has"*, citing `records/conformance-map.md:127`. `PRINCIPLES.md`
therefore models the discipline the against side asks for, which is a principle
stating an ambition and marking in the same paragraph that the tree lacks it.
That is available to the author as a shape for a sixth condition and it is not a
ruling that one should exist.

#### The Open edges section

**None of the five names this call's subject**, which Call 3 §3.3 established over
the same list (`:215-259`) and this section does not re-derive.

One structural observation is new and is offered as a reading rather than as
something the document says. Edge 2, how far the membrane reaches inward, is
recorded **largely answered** (`:226-234`): *"crossings are the effect row, spends
are grades, partiality is the mark, and information flow holds a reserved
lattice-valued grade seat."* Four seats. An out-of-range read fits none of them
cleanly: no port declares it, so it is not in the effect row; it costs nothing
extra, so it is not a grade; the silent over-read returns at exit 0, so it is not
partiality. The nearest fit is the fourth seat, reading bytes the program holds no
authority over as an information-flow event, and that seat is **reserved and
empty**, which `:117` names as open residue. So the edge that would hold this
question is settled in a shape that has no filled seat for it.

### 1.5 What the principles do NOT settle

This is the part that is genuinely the author's. Seven items, each specific.

1. **Whether a done-condition is the instrument at all.** `PRINCIPLES.md` has no
   tier model. Goal, arc, condition, roster row, rung and element appear nowhere
   in it, and `:3-6` fixes its subject as the semantics and the type system. The
   instrument question belongs to `docs/goals/README.md:24-25` and `:140-141`,
   neither of which is a principle. Every principle above either decides the
   subject or is silent, and none reaches the document.

2. **Recording an existing claim versus widening one.** §1.2 establishes that the
   goal's cited authority covers the subject and that the goal's claim section
   does not name it. Whether adding a condition over that gap records the claim
   or changes it decides the route: a condition, or a decision in
   `docs/decisions/` first (`docs/goals/README.md:140-141`). No principle picks,
   and the tree has no worked precedent for a condition added to an existing goal
   over a subject its cited authority already carried.

3. **Granularity.** The space membrane whole, or bounds alone. P1's seccomp figure
   argues for the general form and does so only by analogy, since its subject is a
   syscall table. `docs/goals/README.md:24-25` caps nothing except checkability
   and arc-naming, and no document in the tree states how coarse a done-condition
   should be.

4. **Whether condition 1 already reaches it.** Condition 1 quantifies over ledger
   rows (`docs/goals/enforcement.md:25-27`). `E176` has a ledger row and `bget`
   has no element at all (`records/enforcement-arc.md:354`), so condition 1
   reaches one routine of a population of at least two, and reaches it as a row
   rather than as a property. Whether a condition that quantifies over rows can
   observe a class with no rows is exactly the shape of **call 5**, and this
   section does not analyse it.

5. **Whether a trap is an outcome a done-condition may count.**
   `lib/lowering/tal/sys.chiral:1006-1009` answers an out-of-range offset with
   `exit_group`. `docs/definitions/status-ledger.md:138-140` defines ENFORCED as
   *"a check in the kernel, the loader or the suite"* that fails. A process that
   kills itself at runtime is none of those three, and the ladder does not say
   where it sits. No principle reaches the question. Where it becomes a question
   about whether a total runtime answer is an enforcement outcome it is **call
   3**, written above and not reopened.

6. **Whether the arena-versus-slice asymmetry is a goal's business.** One carrier
   of the space boundary refuses an out-of-range offset and the other does not
   (§1.3). Nothing in the five principles says whether an uneven property across
   two carriers of one boundary is observed at the goal tier, the arc tier or the
   element tier. `docs/arcs/README.md:31-32` makes goals and arcs many to many and
   is silent on which tier owns an inconsistency. Which arc would own it is
   **call 2**, and this section does not analyse it.

7. **What the observation would be, if one is written.**
   `docs/goals/README.md:24-25` requires each condition to be checkable. Two
   candidate observations exist in the tree and they are not the same: a judgment
   that can say a bound (`lib/typing/diag.chiral:97-110` holds 38 constructors and
   `docs/definitions/bug-classes.md:123-125` measures that none of them says
   bounds), and a gate that reddens when the property stops holding
   (`enforcement/N21`'s subject). The first is served by `enforcement/N18`, the
   second by `enforcement/N21`, and a condition naming one does not schedule the
   other. No principle chooses, and the choice decides which row the condition
   would name.

### 1.6 The proposal

**PROPOSAL.** Put to the author that this call is not the authoring act its row
treats it as, and that what is left is smaller and already has a route. The
subject is stated: `PRINCIPLES.md:77-81` closes the set of ways a program affects
anything outside itself over I/O, the capabilities it holds, and time and memory,
and `:103-105` names space as *"the boundary with the substrate you are running
on"*, while `docs/goals/enforcement.md:16-17` cites `PRINCIPLES.md` §3 as one of
the four places this project makes this goal's claim. So `docs/arcs/README.md:35`
does not bar a sixth condition here, because the ambition is not one the project
has never stated; what the goal lacks is a condition observing the part of its own
cited claim that concerns space, and §1.2 shows the subject reaching the goal file
only through `## State`, which `docs/goals/README.md:133-134` defines as where the
goal stands rather than what it claims. Two things follow and neither of them is a
condition. First, if the author reads a sixth condition as **recording** that
claim, the observation it would have to state is the one the arc already wrote its
rows against, whether a crossing of the space boundary can be made with an index
that nothing bounds, checkable through a judgment able to say a bound
(`lib/typing/diag.chiral:97-110` holds 38 constructors and none does,
`docs/definitions/bug-classes.md:123-125`) and a gate that fails when it stops
holding; and the claim it would cite is `PRINCIPLES.md:77-81` rather than
`docs/definitions/bug-classes.md:46`, which is a `status: draft` row and is where
the class is recorded rather than where the claim is made. Second, if the author
reads it as **widening** what the goal claims, `docs/goals/README.md:140-141`
already fixes the instrument: a decision in `docs/decisions/` first, with the
condition following it. The principle that carries this is **P3**: memory is a
port rather than a bug class, so a goal that already claims the membrane owes an
observation on the space half of it. P1 concurs on the subject and is silent on
the instrument, P2 refuses the against side's arithmetic by making the defect the
no-exemption clause violated by a live signature (`:55-58`,
`lib/prelude/prelude.chiral:83`) instead of one row among 28, P4 is silent, and P5
asks only that the shortfall stay visible (`:191-195`).

**What would falsify it.** A reading of `docs/goals/enforcement.md:16-17` that
takes its citation of `PRINCIPLES.md` §3 to reach only the
port-check-is-the-type-check clause and not the space-is-a-port clause kills the
argument outright, because the subject is then absent from the goal's claim
section and `docs/arcs/README.md:35` bars the condition as authoring. A
measurement showing condition 1 observing the property across the whole
population, where today it reaches `E176`'s ledger row alone, removes the need for a
sixth condition without touching the principle.

---

## Call 2: Which arc owns the bounds class

**PROPOSAL. Not a ruling.** The row at `records/author-calls.md:363` stays
`unreviewed`. Written 2026-09-10 against the tree at `26577e1`. No file outside
this one was written by the run that produced this section, and no roster row
was moved.

### 2.1 The call, quoted verbatim

From `records/author-calls.md:363`, the row's second and third cells entire:

> **Which arc owns the bounds class** · Opened 2026-09-10 by the same revisit. |
> Enforcement: the missing artifacts are a judgment and a gate, requirements 1
> and 6's subjects. Diagnostics: `E176` and `diagnostics/L5` already own the
> routine, and splitting one defect across two arcs is the collision `arc-open`
> exists to catch. Text-tools: [[banks/text]] shard A owns the slice territory
> and `text-tools/L6`, the length-indexed `Str`, is already owed there.
> [[decisions/decision-primitive-with-consumer]] explicitly does not rule on a
> pair whose halves sit in different arcs. `enforcement/N18` is written on the
> judgment-and-gate reading; if the call goes the other way the row moves whole
> and keeps its id

The defect itself is established and is not re-derived here: `str-sub`, `bslice`
and `bget` read outside their buffers today, measured against the committed
binary and recorded at `records/enforcement-arc.md` EN-31 (`:354`).

Three things committed since the row was written are taken as given. **Call 1's
result** (§1.2 above): `docs/goals/enforcement.md:16-17` cites `PRINCIPLES.md`
§3 inside the goal's own claim section, and §3 is where space becomes a port.
**The arena precedent**: `lib/lowering/tal/sys.chiral:1006-1009` already rules
that *"A real bounds violation is a corpse: on size<=0 or off/len out of range
the body takes the arena-fail shape (exit_group(-EINVAL), never returns)"*, with
`nb-arena-fail-t` a live `ti-sys 231` at `:118-122` reached by
`nb-arena-commit-t` at `:139-141`. **And `diagnostics/L5` §5 no longer holds as
written**: its shape set is five, and clamp-versus-trap at `nb-bslice` is
question 9, `NEEDS-AUTHOR`. Whichever arc owns the class, the repair shape is
unsettled, and that is **call 3**'s territory, not reopened here.

### 2.2 What each candidate arc actually holds today

An arc's claim on this class is only as good as the requirements it already
carries, so each is measured on its goal, its requirements, its rows and the
tree its work lands in.

**Enforcement** — `docs/arcs/enforcement-arc.md`.

| | measured |
|---|---|
| goal | [[goals/enforcement]] (`:12`), whose claim section cites `PRINCIPLES.md` §3 (`docs/goals/enforcement.md:16-17`) |
| band | `E184-E189`, shared with diagnostics (`:13`). **Spent**: `E189` is built (`docs/elements/ledger.md:327`), and `records/enforcement-arc.md:356` records the band spent with `docs/decisions/decision-lane-split.md:327` barring two focuses from minting from it concurrently |
| requirement 1 | *"A capability sits at ENFORCED, or its ledger row says why it does not."* Inherited verbatim from the goal (`:42-48`). Its open half is a `design` row stating why, over 66 rows |
| requirement 6 | *"Every gate row names a mutant that is actually run."* Inherited from the goal and from `docs/definitions/testing-floors.md:261` (`:372-374`) |
| the `safety` group | added 2026-09-10, the arc's fourth: *"What the compiler refuses about a program's own memory access … none of them holds a rule that refuses an out-of-range index"* (`:482-488`) |
| rows | `N18` safety · primitive · `pair` · req **1, 3** (`:509`); `N19` floor · law · `pair` · req 2, 3 (`:510`); `N20` safety · tool · new · req **1** (`:511`); `N21` tooling · tool · new · req **6** (`:512`). All four `unminted` |
| tree | *"`lib/lowering/` at top level …, `lib/lowering/upper/` …, `lib/lowering/tal/` (`ir`, `check`, `eval`), `bin/chirality`"* (`decision-lane-split.md:305`), and `:306`: *"Enforcement's whole footprint is `lib/lowering/` plus `bin/chirality`."* |

⚑ **The row's own account of which requirements is wrong, and the error is not
cosmetic.** The call says the judgment and the gate are *"requirements 1 and
6's subjects"*. Measured, `N18` serves 1 and 3 and `N21` serves 6, so the two
halves are carried by two rows against three requirements, and requirement 3,
*"The check agrees with the compiler it checks"*, is named by neither side of
the call. Neither requirement 1 nor requirement 6 states a memory property:
requirement 1 is satisfied by a ledger row that says why, and requirement 6 is a
quality check over gate rows that exist. Whether requirement 6 can see a class
with zero rows is **call 5** and is not analysed here.

**Diagnostics** — `docs/arcs/diagnostics-arc.md`.

| | measured |
|---|---|
| goals | [[goals/readable-surface]] (what it is built *for*) and [[goals/self-tooling]] (what it is built *out of*) (`:11`) |
| band | the same `E184-E189` (`:12`), and `:232-233` reads *"The next free number is E189, and `E189` is the last one left in the band"*, which `docs/elements/ledger.md:327` now measures built |
| requirements | five (`:48-70`). Requirement 2 is *"Layout is deferred, and the algebra stays closed. `lib/prelude/doc.chiral` has six constructors and no seventh."* Requirement 5 is *"The error-quality rows are closed. E182 arity evidence (closed 2026-09-02), E176 `str-sub`, E179 face registry."* |
| the row | `diagnostics/L5`, group `layout`, kind `law`, origin `new`, req **2**, state `designed`, element **`E176`** (`:257`) |
| coverage | *"2 by L1 to L5"* (`:266`) |
| tree | `lib/typing/diag.chiral`, `lib/surface/pretty.chiral`, `lib/protocol/render.chiral`, `render-doc.chiral`, a consumer under `prog/` (`decision-lane-split.md:302`); plus Lane A's may-write list, which names `lib/prelude/string.chiral` **(E176)** at `:153` |

⚑ **This arc reaches the defect through two cells and neither states a
property.** The roster cell says requirement 2, which is the closed-`Doc`-algebra
requirement and has nothing to do with memory. Requirement 5 reaches `E176` by
number, as a row to be closed. So diagnostics owns the **routine**, its element,
its design and its gate, and carries no requirement that a bound holds. Its goal
does name the defect, once, in `## State`: *"`str-sub` reads past its buffer and
reports the read length while `string.chiral:14` claims in a comment that it
clamps … a regularity violation"* (`docs/goals/readable-surface.md:60-64`).
Under the strict test §1.2 established, a `## State` sentence is description and
not a claim, and none of that goal's four done-conditions (`:34-56`) observes
memory.

**Text-tools** — `docs/arcs/text-tools-arc.md`.

| | measured |
|---|---|
| goal | [[goals/self-tooling]] (`:11`), whose claim section cites `decision-scope` and an author call and **no principle at all** (`docs/goals/self-tooling.md:11-19`) |
| band | `E260-E263`, reserved 2026-09-10 (`:12`). `decision-lane-split.md:82-83`: *"four slots against `P2`, `P3`, `P4` and E173's second slice"* — all four spoken for |
| requirements | four (`:200-210`). Requirement 1: *"Every primitive is total. A primitive whose cost is not bounded in its input cannot be typed here, per `PRINCIPLES.md` §2."* |
| rows | **four**: `P1` (`E173`, built), `P2`, `P3`, `P4`, all `unminted` (`:184-187`). There is no `L6` |
| shard A | *"the byte/string floor … `blen`, `bget`, `bslice`, `bcat` \| `lib/prelude/prelude.chiral`, extern \| **built**. `str-sub` is unclamped, E176 / BA-35"* (`docs/banks/text.md:47`), and the limits line at `:138` reads the same and ends *"E176, BA-35"* |
| tree | `lib/text/` — *"one file, `matcher.chiral`"* (`decision-lane-split.md:301`) |

⚑ **The text-tools side rests on a row that is in no roster.** A grep over the
tree for `text-tools/L6` returns four hits and all four are other files citing
it: `docs/arcs/enforcement-arc.md:509`, `docs/arcs/parts/diagnostics-L5.md:523`,
`records/author-calls.md:363`, and §3.4 of this file. The arc's own roster holds
`P1` to `P4`, and `decision-work-ids.md:85-92` fixes the letter: *"The id
alphabet is the arc's own … `text-tools` keeps `P` for primitive."* `L` is
diagnostics' letter, running `L1` to `L5` (`docs/arcs/diagnostics-arc.md:253-257`).
So `text-tools/L6` is a row name coined in diagnostics' alphabet, continuing
diagnostics' numbering, and filed against an arc that does not carry it. The
design that coined it says so in its own disposition cell: *"**DEFERRED** to
roster row `text-tools/L6`, **which does not yet exist and is not opened by this
run**"* (`docs/arcs/parts/diagnostics-L5.md:523`). And the thing the side
actually cites, shard A, routes the defect to **`E176`** in both places it
records it, which is diagnostics' element and not a text-tools row.

⚑ **Text-tools requirement 1 is nonetheless the only requirement in any of the
three arcs that states a property a bounds-unsafe primitive violates**, and it is
served by no row: `GAP-11`, *"converting the arc to the 8-column roster on
2026-09-05 showed requirement 1 served by none of P1 to P4"*
(`records/lenses/gaps.md:145-156`, `docs/arcs/text-tools-arc.md:191-195`).

**The write-set measurement, which is the part none of the three sides carries.**
`decision-lane-split.md:296-306` fixes a tree per arc. Against it, the four
artifacts this class needs sit in four places:

| what the class needs | where it lives | whose write set |
|---|---|---|
| a `Judg` arm that can say a bound | `lib/typing/diag.chiral:97-110`, 38 constructors and none says bounds | **diagnostics'** (`decision-lane-split.md:302`, and `:306`: *"`lib/typing/` belongs to diagnostics. The enforcement arc names no path under it"*) — yet `enforcement/N18` names exactly this file |
| the repair site | `lib/lowering/tal/bytes.chiral`, `nb-bslice-t` (`docs/arcs/parts/diagnostics-L5.md` §5) | enforcement's **directory** and not one of the three `tal/` files its write set names (`ir`, `check`, `eval`); the element that holds it is diagnostics' `E176` |
| an index for a bound to reference | `lib/surface/syntax.chiral:29`, `Str` is `t-primty` | no arc's |
| shard A's externs | `lib/prelude/prelude.chiral:83` and `:97` | no arc's. `decision-lane-split.md:309` shows the tree already handling one such file by naming it: *"`lib/prelude/doc.chiral` is written by no arc"* |
| the precedent that already refuses a bound | `lib/lowering/tal/sys.chiral:1006-1009`, `:118-122` | enforcement's directory, no arc's named file |
| the gate | a new phase under `tools/test/` | Lane A's, *"new Lane-A gates"* (`:153`) |

`decision-lane-split.md:336-341` left this open in so many words and for this
exact element: *"**E176's repair site.** … Whether the fix is a guard in
`lib/prelude/string.chiral` or a change under `lib/lowering/` decides whether
diagnostics reaches enforcement's tree. The element has no SPEC and nothing
settles it."* `diagnostics/L5` settled the **site**, under `lib/lowering/`, and
settled no ownership with it.

**What moving `enforcement/N18` would cost, measured rather than repeated.** The
row says it *"moves whole and keeps its id"* under `decision-work-ids`. Measured
against that document, the cheap half is real and the phrase is false for both
destinations.

*Cheap, and this is what "moves whole" correctly names.* The row is `unminted`,
so `docs/goals/README.md:27`'s *"An element belongs to exactly one arc"* has
nothing to bind yet, no catalog row moves, no ledger row moves, and
`records/lenses/unspoken.md` gains nothing.

*Not free.*

1. **The citable name is `<arc>/<id>`** (`decision-work-ids.md:48`), so the arc
   half changes at every citation. Fourteen exist, in four files:
   `docs/arcs/enforcement-arc.md` ×5 (`:486`, `:509`, `:523`, `:545`, `:550`),
   `records/enforcement-arc.md` ×3 (`:354`, `:355`, `:357`),
   `records/author-calls.md:363`, and this file ×5.
2. **Three of them sit in a file that is appended and not rewound**
   (`docs/arcs/README.md:113-114`): `records/enforcement-arc.md` EN-31. A moved
   row leaves EN-31 naming `enforcement/N18` permanently, correct as history and
   stale as a pointer.
3. **One sits in `records/author-calls.md`**, which no run writing this file may
   touch.
4. **The id letter does not travel.** `decision-work-ids.md:85-96` gives
   text-tools `P`, so `text-tools/N18` breaks that table and `text-tools/P5`
   breaks `records/README`'s *"Never renumber a row that already exists. Its ID
   is cited elsewhere"*, quoted at `decision-work-ids.md:54-56`. Diagnostics has
   `V`, `L`, `T`, `F` and `W` (`docs/arcs/diagnostics-arc.md:249-263`) and `L5`
   is taken. The invariant `decision-work-ids` actually protects is that
   **promotion to an `E#`** does not change the id (`:53-56`); it says nothing
   about transfer between arcs.
5. **The `req` cell does not travel.** `N18` reads `1, 3` against enforcement's
   six. Diagnostics has five and text-tools four, and
   `docs/arcs/README.md:96-102`'s coverage check requires every row to name at
   least one requirement of the arc it sits in, or it is *"out of scope, or §5 is
   missing one"*.
6. **The `group` cell does not travel.** `safety` was created for this row
   (`docs/arcs/enforcement-arc.md:482-488`) and exists in no other arc.
7. **`N20` either goes with it or is stranded.** The `safety` group holds two
   rows, `N18` and `N20` (`:486`), and `N20` is the census of which prelude
   externs read at a caller-supplied index (`:511`). Moving one leaves a one-row
   group whose subject is the row that left.

### 2.3 The three sides as the tree states them

**Enforcement.**

| what the tree says | where |
|---|---|
| the arc opened a fourth group for this subject because none of the three standing ones *"holds a rule that refuses an out-of-range index"* | `docs/arcs/enforcement-arc.md:482-488` |
| `N18` is written here, as `pair`, on the judgment-and-gate reading, and `N18` through `N21` are its rows | `:509-512`, `:523` |
| *"`N18` is the row to design first, because it is the one whose subject the tree has already built for another"* carrier | `records/enforcement-arc.md:357` |
| requirement 2's closure *"CAN CLOSE WHOLE AND A MEMORY-SAFETY HOLE STILL SHIPS"* | `docs/arcs/enforcement-arc.md:104-123` |
| the goal this arc serves cites `PRINCIPLES.md` §3, the principle that puts space on the membrane | `docs/goals/enforcement.md:16-17`, `PRINCIPLES.md:88-90`, `:103-105` |
| the tree the repair lands in is this arc's whole footprint | `decision-lane-split.md:305-306` |

**Diagnostics.**

| what the tree says | where |
|---|---|
| `E176` is this arc's element, `diagnostics/L5` its row, `designed` | `docs/arcs/diagnostics-arc.md:257`, `docs/arcs/parts/diagnostics-L5.md` |
| `E176` is the arc's declared next action | `docs/arcs/diagnostics-arc.md:83` |
| requirement 5 names `E176` as one of three rows whose closure the requirement is | `:66-70` |
| the roster's own contract calls a collision the thing the coverage check catches: every row's `origin` *"defensible from §3 … the phantom-feature error, caught here rather than four stages later"* | `docs/arcs/README.md:100-102` |
| `PRB-24`'s owner cell reads `E176` | `records/lenses/problems.md:328-339` |

**Text-tools.**

| what the tree says | where |
|---|---|
| shard A is *"the byte/string floor"* and holds `str-sub`, `bslice` and `bget` | `docs/banks/text.md:47` |
| the length-indexed `Str` is *"a language element belonging to [[arcs/text-tools-arc]] and its bank shard A, not to this arc"* | `docs/arcs/parts/diagnostics-L5.md:523` |
| requirement 1 is totality, per `PRINCIPLES.md` §2 | `docs/arcs/text-tools-arc.md:202-203` |
| the arc can mint today and enforcement cannot | `docs/arcs/text-tools-arc.md:12`, against `records/enforcement-arc.md:356` |

⚑ **The minting asymmetry is not a discriminator and the call does not say so.**
Author call B was ruled 2026-09-06: *"a band is advisory, and an arc without one
mints the next number free tree-wide, which `pack.py --mint` implements"*
(`docs/arcs/text-tools-arc.md:252-256`). So a spent band does not stop enforcement
from minting and a reserved band does not help text-tools, whose four slots are
already spoken for.

⚑ **A fourth thing the tree has done with this exact shape of question, which
the call's three candidates do not include.** `records/author-calls.md:64`:
*"**Which arc owns the allocation gap** · ⚑ **Routed 2026-09-06 to
[[arcs/memory-discipline-arc]], and routing is not a ruling.** An arc was opened
to hold the work, which answers where the work goes and leaves the fork this row
states standing. Back at `unreviewed`."* The arc file states the same from its
own side: the call *"carried it as 'which arc owns the allocation gap' with two
arguable routes, when what it needed was an arc file"*
(`docs/arcs/memory-discipline-arc.md:19-21`). Both halves of that precedent
matter here: a new arc answered where the work goes, and the author call it came
from is still open.

### 2.4 The principle-by-principle test

`PRINCIPLES.md` is the authority under test. Bare line numbers are that file.
`:3-6` fixes its subject: *"The semantics and type system in the design base …
have to satisfy these."* Arc, roster, row, group, requirement and owner appear
nowhere in the document. §1.4 established that fact against a goal-tier question;
against a placement question it is sharper, and the result below is mostly
silence reported as silence.

#### P1, to control everything, you have to be able to express everything

**Silent on the call.**

> "Anything that can happen outside it is, by definition, ungoverned, a hole, and
> intent does not close holes." (`:25-26`)

§1.4 established that this puts the class inside what must be governed. It says
nothing about which roster records the obligation, because no document tier is in
its scope. The seccomp figure (`:46-50`) argues that a model must cover a whole
surface; read onto the instrument it argues that the defect must be owned
*somewhere*, which no side of this call disputes.

**Where a side expected it to bear and it does not.** The diagnostics side's
strongest sentence is that *"splitting one defect across two arcs is the
collision `arc-open` exists to catch"*. P1's hole is a gap in the framework's
expressiveness. A defect recorded in two rosters is not a hole in the framework;
it is bookkeeping, and the authority against it is `docs/arcs/README.md:96-102`'s
coverage check, a document rule. Saying P1 does not supply it is the result.

**On the Honest limit.** §3.3 established that P1 carries no paragraph labelled
*Honest limit* and that its qualifying paragraph is the reflective floor
(`:34-43`), whose subject is in-place judgment mutation. That holds here and is
not re-derived.

#### P2, everything is a process, and the type is the whole cost

**Silent on the call, and it supplies one argument the call does not carry.**

> "The unit of computation is a process with a type. Function, value, statement,
> declaration are special cases of process, not separate kinds of thing."
> (`:51-54`)

Under P2 the declaration and the routine are **one object**, not two artifacts in
two trees. `(extern str-sub (-> Str I64 I64 Str))`
(`lib/prelude/prelude.chiral:83`) and `nb-bslice-t`
(`lib/lowering/tal/bytes.chiral`) are the type and the process of a single
thing. That is `decision-primitive-with-consumer`'s `pair` origin (`:84-92`)
arriving from the principles rather than from the roster, and it argues that the
halves are not separable at all — which strengthens the premise the call shares
with every side and picks no side.

**On the Honest limit** (`:66-69`). Over-approximate cost, and the mediator's own
budget. Neither bears on which document holds a row, and saying so is the result.

#### P3, govern the ports, not the outputs; the interior is free

**Decides the subject, as §1.4 established. It is the only principle that offers
a placement rule at all, and the rule's axis is the code tree.**

> "A directory named for a subject rather than for boundaries is a category
> error: `lib/ports/` holds files that *declare* a crossing and nothing else, and
> three modules that merely computed over crossings moved out because being
> *about* ports is subject matter. A module's interface is the boundaries it
> names; **a design question is answered by asking which boundary it moves**."
> (`:98-105`)

This is as close as `PRINCIPLES.md` comes to telling anyone where a thing goes,
and it is about directories and modules. Applied on its own terms the boundary is
space — *"the boundary with the substrate you are running on"* (`:103-105`) — and
the code that moves it is `lib/lowering/tal/`, which `decision-lane-split.md:306`
puts in enforcement whole. Applied to the roster it does not select among the
three, because all three arcs are named for subjects: errors, text tools, and
what the compiler claims. P3's own sentence says that naming a thing for its
subject rather than its boundary is the category error, which means the axis the
call offers is not the axis P3 discriminates on. That is a finding rather than a
verdict, and it is the sharpest thing any principle says here.

**On the Honest limit** (`:107-117`): *"'closed and named' is only as complete as
the channel model."* Its enumerated residue is the grade domains' mechanization,
E38, and the info-flow seat. Neither is placement. No bearing.

#### P4, the safe path should be the cheap path

**Silent, and one clause cuts against reading it onto the instrument at all.**

> "The model is physics, not policy: nothing forbids a wild outcome, the dynamics
> from P2's cost gradient just do not trend toward it, so code settles into the
> cheap, checkable region on its own." (`:129-132`)

P4 governs how a shape presents to a **writer**, and a roster has no gradient and
no author paying ceremony. Its denylist sentence (`:125-126`) reads onto the
instrument by the same analogy P1's seccomp figure does and adds nothing. Its
Honest limit (`:134-142`) is about a conservative checker taxing safe code, which
§3.3 read onto the repair choice and which reaches nothing here.

Saying P4 is silent is the result. It is also the principle `goals/readable-surface`
cites in its claim section (`docs/goals/readable-surface.md:11-20`), so the arc
with the most-developed claim on the routine is served by a goal whose cited
principle has nothing to say about this class.

#### P5, where proof runs out, split the truth and require agreement

**Silent, and its one analogous clause is an analogy this test declines to lean
on.**

> "the writers must be independent, not just the copies. One writer updating all
> N gets agreement that is all wrong." (`:172`, the T1 row)

Read onto the instrument that is a caution about two arcs recording one property
with no independent writer, which is the diagnostics side's collision argument in
other words. The subject of the row is a held truth with copies, not a roster,
and §1.4 already placed a range check at T0, inside P2's regime, citing
`docs/banks/memory.md:257-259`. Naming the analogy and not resting on it is the
discipline §1.4 applied to P1's seccomp figure.

**Its one genuinely bearing clause is about visibility.**

> "Do what you can, and name it. … where finite resources force a lower rung, the
> shortfall is a visible fact in the type, not a silent hole." (`:191-195`)

Applied to placement it asks that an unowned class be visible rather than silent.
That is already satisfied: the row exists, `unreviewed`, and `N18` through `N21`
carry the work in the open. P5 asks for the state the tree is in and picks no
owner.

**On the Honest limit** (`:202-208`). Zeroing on drop, and a construct the
paragraph itself demotes to a seed. No bearing.

#### The Open edges section

**None of the five names placement, arcs, or ownership**, which §1.4 and §3.3
established over the same list (`:215-259`) and this section does not re-derive.

One structural reading is new and bears directly. The closing paragraph is the
only place in `PRINCIPLES.md` where a question is answered by saying it is not a
principle's to answer:

> "**Govern the mediator, resolved structurally not as a principle.** … The
> answer is not a sixth principle that says verify the checker, and it is not a
> quorum." (`:250-259`)

It then points at two decision documents and a definition. That is the document's
own worked model for a question of this shape: it declines, says so in its own
text, and names where the answer lives. Call 2 is that shape, and
`docs/decisions/` is where this tree puts such answers.

### 2.5 What the principles do NOT settle

**Placement is a question the principles do not reach at all, and that is the
finding rather than a shortfall in the test.** `PRINCIPLES.md:3-6` fixes the
subject as the semantics and the type system. All five are silent on the call.
One, P3, offers a placement rule whose axis is the code tree rather than the
roster (`:98-105`), and applied on that axis it points at `lib/lowering/tal/`,
which is enforcement's directory and is not where enforcement's named files are.
What reaches placement instead is a set of document rules, and they leave eight
specific things open.

1. **What `decision-primitive-with-consumer`'s silence actually leaves open.** Its
   own section reads: *"**Which arc holds a pair whose halves sit in different
   arcs.** [[arcs/README]] already allows a goal to take work from several arcs
   and the relation is many to many. A pair spanning two arcs is a scheduling
   question, not a new fork"* (`:126-128`). Measured, the sentence cites the wrong
   relation. `docs/arcs/README.md:31-33` makes **arc↔goal** many to many — *"one
   arc can supply two goals at once, and one goal can take work from several
   arcs"* — while `docs/goals/README.md:27` makes **element↔arc** exactly one.
   This call is about the second relation and the decision answered with the
   first. So the many-to-many rule does **not** make the call a non-question and
   does not permit an answer either way: it is about an axis the call does not
   touch. What the decision does settle is that the two halves are one unit,
   `origin: pair` (`:84-92`), and one unit occupies one roster row, which makes
   the call sharper rather than looser.

2. **Whether the call bites before the row mints.** `docs/goals/README.md:27`
   binds elements. `enforcement/N18` and `N20` are `unminted` and `text-tools/L6`
   is not a row anywhere, so nothing in the tree is violated today and the
   invariant arrives the day the row mints. No principle and no document says
   whether a question that does not yet bite is answered now or at mint, and the
   tree's two nearest precedents point opposite ways:
   `docs/decisions/decision-design-before-mint.md` puts the design before the
   number, and `records/author-calls.md:64` shows a placement call routed and left
   open.

3. **Whether a new arc is a fourth candidate.** The call offers three.
   `records/author-calls.md:64` and `docs/arcs/memory-discipline-arc.md:19-21`
   record the tree doing a fourth thing on the same shape of question and
   recording explicitly that *"routing is not a ruling"*. No principle reaches it,
   and the precedent cuts both ways: the arc got written and the row stayed
   `unreviewed`.

4. **Whether a goal's cited authority selects the arc.** Call 1 established that
   `docs/goals/enforcement.md:16-17` cites `PRINCIPLES.md` §3 in its claim
   section. Measured against the other two: `goals/readable-surface` cites
   `PRINCIPLES.md` §4 and `design-principles` (`:11-28`), and `goals/self-tooling`
   cites `decision-scope` and an author call and no principle at all (`:11-19`).
   So exactly one of the three goals cites the principle that covers the subject.
   `docs/arcs/README.md:31-33` says an arc names every goal it serves and says
   nothing about a goal's cited authority reaching down into arc membership.
   **This is the precise point at which Call 1's result tilts Call 2 and does not
   settle it.**

5. **Whether the code tree decides.** §2.2 measures the four artifacts in four
   places, one of them (`lib/typing/diag.chiral`) inside a candidate's write set
   while a different candidate's row names it. Nothing says whether an arc owns a
   class because it owns the tree the repair lands in.
   `decision-lane-split.md:336-341` left exactly this open for `E176` and the
   `diagnostics/L5` design settled the site without settling the ownership.

6. **Whether `text-tools/L6` may be cited before it exists.**
   `docs/definitions/working-discipline.md:75-83` forbids deferring to an unminted
   `E#` and directs a run to *"Name a roster row instead"*, and
   `decision-work-ids.md:64-66` says an arc-local id *"claims identification"*. A
   row in no roster identifies nothing, and three documents now defer to
   `text-tools/L6`. Whether the deferral rule's relief extends to a row name never
   written into an arc is unstated, and it is what makes the text-tools side
   unmeasurable as the call states it.

7. **Whether a class may be owned before its extent is measured.**
   `enforcement/N20` is the census of which prelude externs read at a
   caller-supplied index and which clamp (`docs/arcs/enforcement-arc.md:511`).
   Until it runs, the population is two measured entries — `nb-bslice` under two
   surface names, and `bget` — out of an unmeasured set. Nothing says whether an
   arc takes a class whose size no instrument has reported.

8. **Whether `N18`'s `req` cell is right where it sits.** It reads `1, 3` and the
   call argues 1 and 6. Requirement 3 is *"The check agrees with the compiler it
   checks"*, which is about the tal checker against the compiler and not about a
   bound. Whether a judgment able to say a bound serves requirement 3 at all is
   an arc-internal question the coverage check would have to answer, and no
   principle reaches it. It is named here because the call's own framing of which
   requirements are at stake does not match the roster's.

### 2.6 The proposal

**PROPOSAL.** Put to the author that the principles reach none of this call, and
that as the row states it the choice is not three-way, because one candidate is
measurably unavailable and a second holds the routine rather than the class. On
text-tools: the side rests on `text-tools/L6`, and that row is in no roster
(`docs/arcs/text-tools-arc.md:184-187` holds `P1` to `P4`), its letter is
diagnostics' (`decision-work-ids.md:85-92` gives text-tools `P`), and the design
that coined it says in its own disposition cell that it *"does not yet exist and
is not opened by this run"* (`docs/arcs/parts/diagnostics-L5.md:523`), while
shard A, the thing the side actually cites, routes the defect to `E176` in both
places it records it (`docs/banks/text.md:47`, `:138`); so the text-tools side is
an argument for a row somebody still has to write, and writing it is a separate
act on the author's ruling. On diagnostics: its claim on the **routine** is real
and nothing in this call proposes to move it — `E176`, `diagnostics/L5` and the
gate stay where they are — but its claim on the **class** is carried by no
requirement it holds, since the row's `req` cell is 2, the closed-`Doc`-algebra
requirement (`docs/arcs/diagnostics-arc.md:52-58`, `:257`), and requirement 5
reaches `E176` by number as a row to close (`:66-70`). On enforcement: it is the
only candidate whose requirements are the ones under argument, and the row's
account of which ones is wrong in a way worth correcting before a ruling, since
`N18` serves 1 and 3 and `N21` serves 6 (`:509`, `:512`) rather than one row
serving 1 and 6. So the proposal is that **the class stays on enforcement and the
row does not move**, on the narrow ground that it is the only candidate carrying
requirements about the artifacts, that its goal is the one whose claim section
cites the principle covering the subject (`docs/goals/enforcement.md:16-17`,
Call 1), and that the tree the repair lands in is its whole footprint
(`decision-lane-split.md:305-306`); and that the residue the author should be
handed with it is not a fourth candidate but a measured fact: the four artifacts
sit in four trees and only one is inside a candidate's named file list (§2.2), so
whatever is ruled, `decision-lane-split`'s write-set table and
`docs/arcs/README.md:74`'s stale `origin` list are both owed an amendment that no
run has authority to make here. What carries the proposal is not a principle:
`PRINCIPLES.md:3-6` excludes the tier, P1, P2, P4 and P5 are silent, and P3's one
placement rule is about directories (`:98-105`) and points at `lib/lowering/tal/`
rather than at a roster. What carries it is `docs/arcs/README.md:96-102`'s
coverage check, which makes a row's home a claim about the requirements it
serves rather than about subject matter, and
`decision-primitive-with-consumer:84-92`'s `pair`, which makes the two halves one
unit and therefore one roster's.

**What would falsify it.** A ruling that a class belongs to whichever arc owns
the tree its repair lands in settles it for enforcement immediately and makes
§2.2's write-set table the whole answer rather than the residue, which would mean
this proposal reached the right result by the wrong instrument. In the other
direction, a `text-tools/L6` row actually written into
`docs/arcs/text-tools-arc.md` against a requirement it serves makes the
text-tools side measurable and kills the proposal's first leg outright; and a
ruling on **call 1** that the goal's cited `PRINCIPLES.md` §3 does not reach the
space-is-a-port clause removes the second of the three grounds above, leaving
enforcement's case resting on requirements and the write set alone.

---

## Call 3: Is a clamp an enforcement outcome, or does it discharge the class by hiding it

**PROPOSAL. Not a ruling.** The row at `records/author-calls.md:364` stays
`unreviewed`. Written 2026-09-10 against the tree at `0783558`. No file outside
this one was written by the run that produced this section.

### 3.1 The call, quoted verbatim

From `records/author-calls.md:364`, the row's second cell entire:

> **Is a clamp an enforcement outcome, or does it discharge the class by hiding
> it** · Opened 2026-09-10 by the same revisit, and it is the sharpest of the
> five. | `docs/arcs/parts/diagnostics-L5.md` §4 Shape A's own Forbids reads "an
> out-of-range call can no longer be detected. Silent truncation replaces silent
> over-read." For the clamp: it closes the memory-safety hole, and §2 measured
> the refinement route unconstructible over a `Str` with no index, so demanding a
> judgment blocks the repair behind a language element nobody has scheduled.
> Against: a clamp is a total runtime function that answers rather than a rule
> that refuses, so the capability lands at IMPLEMENTED and never at ENFORCED, and
> `bug-classes.md`'s row moves from `none` to something the language still cannot
> say. The goal's State section calls that "a bug the language happens to catch
> today." The call decides what state that row may read after `E176` builds, and
> `E176` is the next thing to build

The defect itself is established and is not re-derived here: `str-sub`, `bslice`
and `bget` read outside their buffers today, measured against the committed
binary and recorded at `records/enforcement-arc.md` EN-31 (`:354`).

### 3.2 The two sides as the tree states them

**For the clamp.**

| what the tree says | where |
|---|---|
| the clamp "closes the memory-safety hole" | `records/author-calls.md:364` |
| Shape A "reaches both surface names at once, all 250 call sites, because there is one routine" | `docs/arcs/parts/diagnostics-L5.md:245-246` |
| the refined signature the catalog row asked for is `load: unknown name s`, so `end ≤ (str-len s)` is "**not expressible**" | `docs/arcs/parts/diagnostics-L5.md:164` |
| the constructible refined form "requires a length index that `Str` does not have", so "the real cost of B is a length-indexed `Str`, which is a language element and not this row" | `docs/arcs/parts/diagnostics-L5.md:256-259` |
| that language element is roster row `text-tools/L6`, "owed and not opened" | `docs/arcs/parts/diagnostics-L5.md:375` |

**Against the clamp.**

| what the tree says | where |
|---|---|
| Shape A's own Forbids: "an out-of-range call can no longer be *detected*. Silent truncation replaces silent over-read" | `docs/arcs/parts/diagnostics-L5.md:239-241` |
| "a clamp is a total runtime function that answers rather than a rule that refuses, so the capability lands at IMPLEMENTED and never at ENFORCED" | `records/author-calls.md:364` |
| "A bug class comes off the list when it can be stated as a judgment and a gate fails when the judgment stops holding. Anything short of that is a bug the language happens to catch today." | `docs/goals/enforcement.md:93-95` |
| the vocabulary "does not contain … no constructor exists for effects, termination, bounds, overflow or ABI agreement" | `docs/goals/enforcement.md:99-100` |

A third statement in the tree belongs to the against side and the call does not
quote it. `docs/banks/memory.md:257-261`, concept C3: *"'The write is in bounds'
is **not** a runtime memory-safety check in the compile-time-provable case. It is
the refinement fragment discharging `{>=0, <n}` (`mem-put-checked`)."* The tree
has already built the refusing form of this exact obligation on a different
carrier (`lib/memory/mem-linear.chiral:26-28`, `docs/banks/memory.md:118-131`,
CONFORMS as scoped), which is why `enforcement/N18` is written as the byte floor
reaching a discipline the memory bank already holds
(`docs/arcs/enforcement-arc.md:509`).

### 3.3 The principle-by-principle test

`PRINCIPLES.md` is the authority under test. Line numbers are that file.

#### P1, to control everything you have to be able to express everything

**Decides, for the clamp, with a residue it names itself.**

> "Anything that can happen outside it is, by definition, ungoverned, a hole, and
> intent does not close holes." (`:25-26`)

> "A seccomp filter is only as complete as the syscall table it enumerates. The
> fix is never a longer denylist; it is a model that covers the whole surface, so
> 'deny by default' actually means everything." (`:47-50`)

The seccomp example sorts the four shapes and it does not sort them the way the
call's *against* side assumes. The enumerating form here is Shape D, a second
safe spelling `str-sub-safe` that callers may or may not reach for
(`docs/arcs/parts/diagnostics-L5.md:278-289`), and the L5 design refuses it on
exactly this ground: it "converts a memory-safety hole into a convention"
(`:288-289`). A clamp enumerates nothing. It is total over every `(s, i, j)`
(`docs/arcs/parts/diagnostics-L5.md:230-232`), which is what "covers the whole
surface" means for a function of three arguments.

**Where it cuts the other way.** P1's programme is that everything the substrate
can do be *named* and therefore gateable (`:27-28`). After the clamp, the event
"a caller asked for bytes it does not own" has no name anywhere in the language.
P1 answers its own objection at `:34-35`: *"'gateable' includes gated shut."* A
path closed is governed. P1 asks that no path be ungoverned and it does not ask
that every programmer error be nameable.

**On the Honest limit.** P1 carries no paragraph labelled *Honest limit*. Its
qualifying paragraph is the reflective floor (`:34-43`), whose subject is
in-place judgment mutation. That paragraph does not bear on this call, and
saying so is the result. The bearing clause is the one quoted above.

#### P2, everything is a process, and the type is the whole cost

**Decides, for the clamp.**

> "If any category of code opts out of the type, some things are 'just functions'
> the effect system does not inspect, that category is an ungoverned path, P1's
> hole restated. One atom with no exemptions is what makes the effect typing
> total." (`:55-58`)

> "In chirality that cost is in the type, or it does not type-check as cheap.
> There is no 'it is just a function' exemption hiding the fuel it burns."
> (`:72-74`)

Today `(extern str-sub (-> Str I64 I64 Str))` (`lib/prelude/prelude.chiral:83`)
is the exemption in its purest form. The type says total and the function faults.
P2's no-exemption clause is violated by the signature that exists now, and the
clamp is the repair that makes the written type true without writing a new one.
This is the cleanest reading in the whole test: it does not require anyone to
agree about detection, and it holds against today's tree rather than against a
hypothetical one.

**On the Honest limit** (`:66-69`), which cuts twice and lands on neither side
cleanly:

> "exact cost is undecidable, so the type carries an over-approximate bound, not
> an exact predictor."

It licenses approximation of *cost* and says nothing about a domain the type
misstates, so it does not rescue the signature that ships today. It does cut
lightly against the clamp on a second axis: three comparisons at 250 call sites
(`docs/arcs/parts/diagnostics-L5.md:126`) are runtime cost the type still does
not carry, and the limit covers over-approximation and not omission. That cost
is small and it is real, and P2 neither requires nor forbids recording it.

#### P3, govern the ports, not the outputs; the interior is free

**Decides, and it is the principle that carries the proposal.**

> "You cannot enumerate what a program will output. That is undecidable. You can
> enumerate the ways it can affect anything outside itself: I/O, the capabilities
> it holds, the time and memory it spends." (`:77-79`)

> "Time and space stop reading as an exception bolted onto I/O and read as what
> they are: the boundary with the substrate you are running on." (`:103-105`)

A read outside the buffer crosses the boundary with the substrate. It reaches
memory the process was never handed, which is the definition of a crossing that
no port declares. The clamp confines every read to the bytes the caller holds,
which is prevention at the membrane, at the one routine both surface names lower
to (`lib/lowering/tal/erase.chiral:115`).

What the clamp leaves behind is a caller whose arithmetic produced 99 where the
buffer holds 3, and whose answer is now a truncated string. That is a wrong value
computed inside the program, and P3 opens by declining to govern the interior.
`docs/definitions/bug-classes.md:11` draws the same line from the other side:
the list covers "every class of failure that is not you reasoning wrong", and
`:17` names the endpoint as "a mismatch between your specification and your
intent". After the clamp the residue sits on the far side of both lines.

**On the Honest limit** (`:107-117`), which cuts:

> "'closed and named' is only as complete as the channel model."

The clamp closes one routine. EN-31 measured `bget` (`lib/prelude/prelude.chiral:97`)
at the same position with no clamp, returning 0 for `(bget (str->bytes "abc") 99)`
and SIGSEGV at a large index (`records/enforcement-arc.md:354`), and `bcat`,
`brepeat`, `str-find-from` and the `nb-copy` callers are unmeasured
(`docs/arcs/enforcement-arc.md:511`, `enforcement/N20`). So the membrane closes
at one entry of a population nobody has sized, which is P3's limit stated over
this exact defect.

#### P4, the safe path should be the cheap path

**Decides, for the clamp, and its Honest limit cuts against the refusing route.**

> "Do not enforce good behavior by listing the bad and forbidding it. A denylist
> is fragile and never complete." (`:125-126`)

> "The model is physics, not policy: nothing forbids a wild outcome, the dynamics
> from P2's cost gradient just do not trend toward it." (`:129-132`)

After a clamp, safe costs nothing at all 250 call sites and there is no opt-in to
forget. That is the physics reading applied literally: the wild outcome stops
being reachable through this routine, with no author left to be careful. Shape D
is the denylist form and P4 refuses it for the same reason P1 does.

**On the Honest limit** (`:138-142`), which is the sharpest thing in the document
for this call:

> "'safe is cheap' holds only as far as the checker accepts naturally-safe code
> without ceremony; where a conservative check cannot see safety, the tax lands
> on safe code and the opt-out annotation stops being a signal."

`docs/arcs/parts/diagnostics-L5.md:135-142` makes that concrete and measured: 46
call sites are unreachable by construction (`end` is the subject's own length), 2
are structurally out of range, and 87 rest on local guards nobody has checked. A
refinement threaded through a hand-carried index taxes the 46 that are already
provably safe and the 87 whose guards a conservative check cannot see. The limit
names the failure mode and this census is an instance of it.

**Where P4 cuts the other way.** Its example is *"make partial the marked case"*
(`:144-148`): the language's own preferred repair for a partial function is a
mark that the caller opts into. A clamp erases the partiality instead of marking
it, so the mark P4 asks for never gets written. Read the other way, the invariant
the example states is that total is the default downhill, and a genuinely total
routine satisfies that invariant more strongly than a marked partial one. Both
readings are available in the text and the example does not adjudicate between
them. The proposal below takes the second, and this is the point where a reader
could take the first and reach a different answer.

#### P5, where proof runs out, split the truth and require agreement

**Silent on the call. It supplies vocabulary and does not rule.**

The tiers (`:169-174`) are a ladder for a held truth kept in several
representations. Nothing in this call is a held truth with copies, and no rung of
T0 through T3 describes a range check. P5's bearing is one paragraph, the verb
honesty (`:160-162`):

> "this principle is detection, where P1 through P4 are prevention. In the DMA
> example the actual safety comes from the IOMMU *denying* the write; the several-truths
> reconciliation only *notices* a drift after it happens."

That gives the tree's own ordering of the two verbs, and the ordering puts
prevention above detection. Trading a detection that the tree does not have for a
prevention it would have is not a downgrade in P5's terms. The nearest thing to a
ruling in P5 is `:191-195`, *"Do what you can, and name it … where finite
resources force a lower rung, the shortfall is a visible fact in the type, not a
silent hole."* That governs the bookkeeping and not the repair: it asks that
whatever the clamp fails to close stay visible, which is an argument about what
`docs/definitions/bug-classes.md:46` may read and not about whether to build the
clamp.

#### The Open edges section

**None of the five open edges holds this question.** Edge 1 is the non-process
boundary, edge 2 the membrane's inward reach (residue: the secrecy lattice and
declassification), edge 3 the cost gradient's mechanism, edge 4 a value's default
tier, edge 5 the reflective floor, and the closing paragraph governs the mediator
(`:215-259`). Bounds, indexing and memory safety appear in none of them. So this
call is not parked in the principles' own list of what they leave open. It falls
outside the document instead of inside its named residue, which is a result and
is reported as one.

### 3.4 What the principles do NOT settle

This is the part that is genuinely the author's. Six items, each specific.

1. **Clamp versus trap.** The principles do not choose between two total repairs.
   Clamp-and-return absorbs the caller's error; clamp-and-trap (a checked abort
   that names the bad call) closes the same crossing and keeps the signal. P1's
   "gated shut", P3's membrane and P4's physics are each satisfied by both.
   `docs/arcs/parts/diagnostics-L5.md:227-289` lists four shapes and this fifth
   is not among them, so the call as written at `records/author-calls.md:364` is
   a two-way fork that does not contain the option that would keep detection at a
   cost the tree can afford today. This is the largest specific gap.

2. **The state vocabulary.** `PRINCIPLES.md` has no state column and no rung
   ladder. It never says what `docs/definitions/bug-classes.md:46` may read.
   The ladder is `docs/definitions/status-ledger.md:133-140` and the class list
   is a `status: draft` document (`docs/definitions/bug-classes.md:5`) whose own
   note says a class with no element is expected (`:19`). Whether a
   runtime-total routine earns `partial`, earns `by construction` (`:32`, held
   today by exactly one row, `:44` and `:219`), or must stay `none` is an
   authorship decision over that document's vocabulary. No principle reaches it.

3. **Which document's criterion binds.** `docs/goals/enforcement.md:93-95` says a
   class comes off the list when it is a judgment with a gate. That sentence is a
   goal's criterion. `docs/definitions/bug-classes.md` has its own six-value state
   column, and `none` to `partial` is not "coming off the list". Whether the
   goal's sentence governs the definition's state column, or only the goal's own
   done-conditions, is a question about two documents and no principle arbitrates
   between them.

4. **Value correctness after truncation.** None of the five says whether a
   silently wrong answer is an acceptable price for a memory-safe one. P3
   declines to govern outputs by name (`:77-78`). `PRINCIPLES.md:11-16` routes
   the reader's-side question to `docs/definitions/design-principles.md`, which
   this call does not cite and which `docs/arcs/parts/diagnostics-L5.md:288-289`
   invokes against Shape D. Whether it also bites Shape A is unasked anywhere in
   the tree.

5. **Whether the clamp forecloses the refinement or floors it.** The principles
   say nothing about sequencing a weaker prevention ahead of a stronger one. P5's
   ladder does that for held truths and has no analogue for checks. If a clamped
   `nb-bslice` is later given a refined caller, the clamp becomes dead branches
   that the refinement has already discharged; if it is never given one, the
   clamp is the whole answer. Nothing in the tree states which is intended, and
   `enforcement/N18` and `text-tools/L6` are both written as though the
   refinement still lands (`docs/arcs/enforcement-arc.md:509`,
   `docs/arcs/parts/diagnostics-L5.md:375`).

6. **Whether the clamp's runtime cost belongs in the type.** P2 says the type is
   the whole cost. Three comparisons at 250 sites are cost no type carries, and
   P2's Honest limit covers over-approximation and not omission. The principles
   neither require nor forbid recording it, and no element in the tree records a
   cost of this shape.

**Where this analysis stops at another call.** The rung claim in the proposal
below is measured against `docs/definitions/status-ledger.md`'s ladder and not
against a goal condition; whether the rung it claims is creditable to
`docs/goals/enforcement.md` at all depends on **call 1**, because none of that
goal's five done-conditions observes whether a program can read outside a buffer,
and this section does not analyse call 1.

### 3.5 The cost of each side, measured

Every number below is taken from a measurement the tree already carries. Nothing
here was re-derived and no build was run.

**Building the clamp.**

| item | measurement | where |
|---|---|---|
| the element | `E176`, minted 2026-08-31, ledger state `design`, category `string` | `docs/elements/ledger.md:312`, `docs/arcs/parts/diagnostics-L5.md:417` |
| `lib/lowering/tal/bytes.chiral` | +25 to +40 lines, two further clamps in `nb-bslice-t` | `docs/arcs/parts/diagnostics-L5.md:461` |
| `lib/prelude/string.chiral` | +4 to +6 lines, `str-starts-with` gains its own guard | `:462` |
| `prog/scriba/completion.chiral` | +3 to +6 lines | `:463` |
| the gate | +120 to +200 lines, three range cases × two surface names, three mutants | `:464` |
| four files, the design's own estimate summed | +152 to +252 lines | arithmetic over `:461-464` |
| the real cost | the generation sequence, first agreement `C2 == C3`, and gen3 mandatory because an arm-tag inversion in this routine is invisible at gen1 and gen2 | `:356-368`, `:466-470`; `lib/lowering/tal/bytes.chiral:134-144` |
| reach | one routine, both surface names, all 250 calls | `:245-246`, `:126` |

**Building a refusing judgment.**

| item | measurement | where |
|---|---|---|
| the form the catalog row asked for | `load: unknown name s`, exit 1. A refinement atom cannot see an `=>` value binder | `docs/arcs/parts/diagnostics-L5.md:164` |
| the constructible form | `(-> (0 n I64) (=> Str I64 (refine I64 (<= n)) Str))` loads, refuses `(sub-safe 3 "abc" 0 99)` with `cannot prove refinement`, accepts `(sub-safe 3 "abc" 0 2)` | `:165-167` |
| what blocks it | `Str` is `t-primty`, a bare primitive type with no index for the bound to reference | `:172-178`, `lib/surface/syntax.chiral:29` |
| so the real cost | a length-indexed `Str`, "a language element and not this row" | `:256-259` |
| and it has no element | roster row `text-tools/L6`, "owed and not opened" by the L5 run or by EN-31 | `:375`, `docs/arcs/enforcement-arc.md:509` |
| the judgment half | `lib/typing/diag.chiral` holds 38 constructors and none says a bound | `docs/goals/enforcement.md:99-100`, `docs/arcs/enforcement-arc.md:509` |
| its row | `enforcement/N18`, `unminted`, because the arc's band `E184-E189` is spent and `docs/decisions/decision-lane-split.md:327` bars two focuses minting from it concurrently | `records/enforcement-arc.md:356` |
| the caller tax | 250 calls, of which 46 are unreachable by construction, 2 structurally out of range, and 87 rest on unchecked local guards | `docs/arcs/parts/diagnostics-L5.md:126`, `:135-142` |
| the option alternative (Shape C) | 250 call sites rewritten, and a sum built at the TAL floor in the same trapped routine | `:272-274` |

**What the detection actually costs today, measured.** The against side's
strongest empirical claim is that the clamp destroys detection. `diagnostics/L5`
§2 measured what detection exists: a small overrun, `(str-len (str-sub "abc" 0 99))`,
returns **99 at exit 0** with nothing red (`:97`); a large overrun segfaults, and
"whether it reads garbage or dies is a question about page mapping, not about the
code" (`:98`); a negative start returns 5 and reads before the buffer at exit 0
(`:99`). So of three out-of-range cases, today's tree detects one and detects it
by accident of page mapping. What the clamp forfeits is that accident.

**Scheduling, measured.** The clamp is buildable this week: its element exists,
its design is written, and its shapes are chosen (`docs/arcs/parts/diagnostics-L5.md:320-347`).
The refusing judgment cannot draw a number today: `text-tools/L6` is unopened,
`enforcement/N18` is `unminted`, and the band it would mint from is spent.

### 3.6 The proposal

**PROPOSAL.** Put to the author that a clamp **is** an enforcement outcome and
that it **does not** discharge the class, and that the two halves separate
cleanly. On the rung, the call's *against* side is wrong as
`docs/definitions/status-ledger.md` words it: ENFORCED is "structurally
guaranteed and **gated**: a check in the kernel, the loader or the suite fails
when the property stops holding" (`:138-140`), and the ladder "is about exposure
rather than quality", so a crude mechanism that reddens a mutant sits on it
(`:142-144`). `diagnostics/L5` §6 already sizes exactly that gate, three range
cases across both surface names with a mutant per clamp arm run at gen3
(`docs/arcs/parts/diagnostics-L5.md:464`, `:466-470`), so `E176` plus its gate
reaches ENFORCED for the property *"`nb-bslice` is total over its three range
cases"*, and never for *"no caller is out of range"*. On the class,
`docs/definitions/bug-classes.md:46` may move from `none` to `partial` and may
move no further, because after `E176` one routine is total while `bget` and the
unmeasured rest of the population are not (`records/enforcement-arc.md:354`,
`enforcement/N20`), and no judgment says a bound. The principle that carries it
is **P3**: a read outside the buffer crosses the boundary with the substrate
(`PRINCIPLES.md:103-105`) and the clamp closes that crossing at the membrane,
while what remains is a caller's arithmetic producing a wrong value inside the
program, which P3 declines to govern (`:77-78`) and which
`docs/definitions/bug-classes.md:11` already places outside the list this class
sits on. P2 concurs on the stronger ground that today's signature is the
no-exemption clause violated (`PRINCIPLES.md:55-58`), P4 concurs and its Honest
limit taxes the refusing route over 133 of the 250 sites (`:138-142`,
`docs/arcs/parts/diagnostics-L5.md:135-142`), and P5 is silent.

**What would falsify it.** A probe after the clamp showing `nb-bslice` still
reads outside the buffer, whether by overflow in the clamp arithmetic or by a
path to the routine that skips it, kills the rung claim outright. A demonstration
that a truncated value reaches a declared port as a safety outcome instead of a
wrong answer kills the P3 argument, because the truncation would then sit on the
membrane and P3 would read the other way.

---

## Call 4: Does the typed-assembly floor owe a bounds obligation

Not yet written. **Two inputs are recorded here first, because both arrived after
the call was opened and both change what the run has to establish.**

### Author direction, 2026-09-10, verbatim

> "typed assembly is the most hardened example of a type system i think? and so
> as we design the upper we need to make sure that even though the bit is
> everything from upper -> lower, the correctness is focused around the lower.
> It's too valuable of a focal point to ever not build around the correctness of"

and, immediately after, the correction that conditions it:

> "well theres nuance because it's our homebrew typed assembly not actual typed
> assembly"

So the direction is that correctness anchors at the floor rather than at the
surface, and the qualifier is that this tree's floor is its own construction and
may not be credited with the published line's hardening on the strength of
sharing its name.

### What the tree measures against that, 2026-09-10

Four measurements, taken when the direction was given. Each one is a reason the
call cannot be answered from the floor's current self-description.

| what | measured |
|---|---|
| the reference class is unrendered | `docs/translations/` holds one file, `aead-chacha20-poly1305.md`. Typed assembly has never been through the `translate` stage, though it is exactly the published external object that stage exists for, with `pipeline-audit` at TRANSLATE level gating it |
| the lineage is uncited | a grep over `lib/lowering/tal/*.chiral` for the literature returns zero. No author, no system, no paper. The name is borrowed and the debt is unstated |
| the golden object says it is provisional | `lib/lowering/tal/spec.chiral:4` reads `PROVISIONAL (2026-08-02, revisitable — the branch is the author's call)`, names `docs/tal-spec.md` as the trust root, cites its own path as the pre-migration `lib/tal-spec.chiral`, and lists "the Python reference" among the executors it validates, which was cut |
| the floor is not reached | `docs/definitions/bug-classes.md:85` gives miscompilation as covered by "typed assembly, checked at instruction level" and marks it **unwired**, because `lowering/tal/check` is not in the compiler binary. That is [[arcs/enforcement-arc]] requirement 2, open |

### What this obliges the call 4 run to do

**Establish what published typed assembly actually guarantees before asking what
our floor owes.** The call as written offers two options, target well-typedness
as the whole claim, or a bounds obligation on top. Call 3's fork was missing its
third option and the same risk stands here: if the published line that carries
index and bound relations at the assembly level is a *different* system from the
one this floor is named after, then the call's two options are the wrong two and
the run's job is to say so rather than to pick.

That is a question about the outside world with sources to pin, so it is the
`research` skill's, and `records/findings.md` is where its answer lands. **It is
not to be answered from memory.** This note names the question and does not
answer it.

**The standing risk this direction creates.** Anchoring correctness at the floor
is a claim about a component that is built, provisional, uncited and unreached.
Until requirement 2 closes, "build around the correctness of the lower" describes
an intention rather than a property, and any row written on the strength of it
inherits that gap.

---

## Call 5: Does `docs/goals/enforcement.md` condition 4 quantify over gate rows or over bug classes

Not yet written.
