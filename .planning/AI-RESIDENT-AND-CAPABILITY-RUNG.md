---
node: ai-resident-and-capability-rung
layer: design
refines: [TUI/docs/TERMINAL-PORT-DESIGN, permission-model, banks/capability]
related: [node-architecture, permission-model, banks/capability, decision-effect-facets, decision-b-in-type, decision-profiles, trust-boundary, live-environment, status-ledger, RUNG2-SECURITY-MODEL, SELF-IMPLEMENT-CATALOG]
status: draft
updated: 2026-08-11
---

# AI-RESIDENT-AND-CAPABILITY-RUNG — where an AI stands in the port graph, and what the capability rung actually contains

**Status: DRAFT / design-only (2026-08-11).** This doc **specifies a position and a
non-goal**; it changes no code and settles no `NEEDS-AUTHOR` item. It exists because
the orchestration-medium goal (the reason the TUI arc is being built at all) makes
demands on the capability system that the current notes do not name, and because two
tempting architectures for it are wrong in ways that are cheap to avoid now and
expensive to unpick later. §6–§7 extend it to the install-time user model and the
crypto boundary, which turn out to be the same separation question asked earlier in
the boot order.

**Provenance note:** derived from a design session, grounded against
`TUI/docs/TERMINAL-PORT-DESIGN.md` §0/§2/§3/§4/§8, `docs/permission-model.md`,
`docs/banks/capability.md` §1, and the `ROADMAP.md` audit backflow (the erased-
position rule, §3.3 below). Where this doc asserts something the sources do not, it
is flagged **NEW**. Author has not ratified; §9's list is a proposal, not a plan.

---

## 0. The invariant — scriba has no say in capability

**scriba does not grant, hold-on-behalf-of, distribute, mediate, or attenuate
authority. It reflects the capability system; it does not participate in it.**

This is not a new rule. It is `permission-model`'s "no gate holds it and no owner
adjudicates it" and `banks/capability` §1's "there is no permission record to
consult" applied to the one program most likely to violate them by convenience —
the program that is on screen, holds the user's attention, and already owns a
command dispatcher.

Three candidate positions for an AI consumer were considered. Two are rejected here
so they are not re-derived later:

| Position | Shape | Verdict |
|---|---|---|
| **Proxy** | agent asks scriba to act; scriba acts holding *scriba's* caps | **FATAL.** Agent authority = scriba authority = everything. Containment degrades to policy inside a 291 KB program with a fast-moving command surface. Violates P3 directly. |
| **Broker** | scriba holds caps and hands sub-caps to the agent | **REJECTED.** Better than proxy — the agent acts holding what it was given — but it makes scriba a *distributor of authority*, which is a principal wearing a different hat (§3.1: there is no principal). It also seats an application in the display TCB. |
| **Reflector** | agent receives its caps from the profile; scriba renders the graph and can alter nothing in it | **ADOPTED.** §1–§3 below. |

The failure mode to watch for is that **proxy is what happens by default under time
pressure** — it is the shape you get by wiring the agent to the existing dispatcher
and moving on. Name it as a non-goal in T13's worked example.

---

## 1. Where an AI resident stands

**Beside scriba, not downstream of it.** An AI resident is a peer above the same
`Terminal` port, holding its own caps, granted the same way scriba's are granted:
from above, at init (`RUNG2` P3, "init = cap-grant"; E80 is the rung-1 vehicle).

This is `TERMINAL-PORT-DESIGN` §0's separation invariant applied to the far end.
§0 says scriba never learns which terminal it is talking to. The symmetric half:
**the port never learns which resident is holding it.** A resident is exactly the
caps it holds; there is nothing else about it to know.

Consequences that are inherited rather than built:

- **Isolation.** An agent granted a read cap on pane 3's text layer and no write cap
  cannot touch pane 4 — not because a check refuses, but because it cannot *name*
  pane 4's `Surface` (§3.2: unforgeable, un-duplicable, no ambient authority).
  Spoofing and reach are inexpressible, not policed.
- **Supervision.** `mux` (T9) holds N `Session` caps under one event loop with
  concurrent progress and **serial mutation — one linear writer at a time**.
  Substitute agents for shells and the concurrency safety of an agent supervisor is
  inherited from linearity rather than implemented as lock discipline.
- **Session as value.** Because the VT grid is a chirality value held alongside the
  `Pty` cap (§4), detach/reattach is serialize-the-value. For an agent that is
  snapshot / fork / diff of a run: branch a session at a decision point and execute
  both legs. **NEW** — §4 states the property for terminals; the agent reading is
  not in the sources.

**scriba is still central.** It owns `Cmd`, the `Rendering` tree, the r-stream node
kinds, and the view-anything identity (`live-environment`: "screen is a port"). An
agent speaks that vocabulary. What it does *not* do is receive authority through it.
The distinction is **vocabulary vs. authority**: types come from scriba, caps come
from the profile. An agent may call scriba's dispatch as a pure function over caps
*it brought to the call* — dispatch cannot reach anything it was not handed, and the
cap threads back through the result sum on the existing corpse-on-error idiom
(`ports.chiral:28`). scriba in the path adds no authority because it has none to add.

---

## 2. Why the structured side-channel is the weaker half

§2's structured tier (`Rendering` serialized as itself over APC, lossless on (M),
degrading to ANSI on (R)) is the right *output* answer and is mostly built. It is
not, by itself, the demonstration.

Every terminal vendor is shipping some version of structured output. The claim
nobody else can make is on the **input/authority** half. Per
`decision-effect-facets`: possession bounds exercise, joined by construction once
every crossing takes its capability as a parameter. An agent that reads a typed tree
but acts by synthesizing keystrokes has structured possession-of-nothing and
unbounded exercise — the worst combination, and the one every current agentic
terminal ships.

So the pairing to build is:

- **Output:** `Rendering` tree, tier-selected (§2). Already designed.
- **Input:** typed `Cmd` values over held caps, not keystrokes. Makes the action
  stream checkable before execution and inspectable after — "what did it do" is a
  list of values, not a byte log re-parsed.
- **Affordance:** `Rendering`'s existing **`hole`**, which §2 keeps addressable in
  the structured tier. An addressable hole is precisely *a region a named cap-holder
  may fill* — the natural write affordance for a resident that should not hold a
  whole `Surface`. **NEW.**

### 2.1 Per-consumer projection, not one tuned format

The instinct to format specifically for an AI consumer is right, and cheap for the
reason the author names: the pretty-printer is typed and pregen'd, so a projection
costs approximately nothing at run time. That argues for making projections
**plural and disposable** rather than tuning one well:

- `render.chiral`'s `RendererFn` registry already supports keying a renderer by type.
- `decision-profiles` gives the manifest: an agent profile declares its renderer set
  the way `profile-cpu-only` declares its layer set — named, testable, conformant,
  not a runtime toggle.
- The typed tree is the durable artifact; projections are throwaway. Coupling the
  medium to one consumer's preferred format couples it to a consumer whose
  preferences turn over on a several-month cycle.

This is the author's own moddability/optimization stance: what makes per-consumer
formatting free is that the content was declarative to begin with.

---

## 3. Reflection without authority — the erased witness

The open question §0 raises: if scriba holds nothing, how does it *show* the
capability graph faithfully?

### 3.1 The mechanism

Use the quantity split the kernel already has. Authority to **act** is a cap held at
quantity 1. Authority to **display** rides a **0-quantity** binding of the same
thing: present in the type, erased at runtime, structurally unable to be exercised.

### 3.2 Render a datum indexed by the witness, not the witness itself

A 0-quantity binding has no runtime content to render. So scriba does not render the
cap; it constructs and renders an ordinary datum **indexed by** the erased graph
term:

```chirality
(data CapView (0 g : CapGraph) ...)   ; shape sketch, not a spec
```

scriba builds and renders `CapView`s freely — that is `Rendering` and `Cmd` doing
exactly what they already do — but **a view that disagrees with the graph it was
indexed by does not typecheck**. Fabrication is not caught; it is inexpressible.
This is `decision-b-in-type` again: the property lives in the type, not the
packaging.

It is also **E52's pattern reused**: an untrusted producer emits an artifact, and a
small trusted thing re-checks it against a spec. scriba is an untrusted producer of
views; the index is the check. The discipline exists; this applies it to a second
customer.

### 3.3 Dependency — the erased-position rule must be real

**This pattern is only sound if erasure is real.** The 2026-07-06 audit backflow
already found the rule: *erased (0) positions must be effect-free, or 0 is not
erasure* — and flagged it as something **edge 2's membrane question has to say
explicitly**. Today that is an audit finding and a design obligation, **not
enforcement**. If a 0-bound position can carry an effect, a "display-only" witness
can act, and §3.1 collapses.

So: **the witness pattern's prerequisite is closing edge 2's statement of the
erased-position rule and enforcing it.** Do not build the reflection UI on top of an
unenforced erasure claim and describe it as structural. Until then it is
DESIGNED-conforming, not ENFORCED — `status-ledger` row accordingly.

### 3.4 Why this is the right job for scriba

`RUNG2-SECURITY-MODEL` §6 (via §3.5) says the trust is **legible in the port graph**.
Legibility needs a viewer. scriba renders the cap graph *without participating in
it*, which makes an agent's authority something you can look at in the same viewer
as everything else, with no ability to alter what it shows.

**Boundary:** scriba's authority views live in scriba's own region. The
compositor-reserved indicator region (§3.4 of the port design) stays
compositor-owned and is not a scriba surface. That separation is the entire reason
the reserved region exists; a reflection feature is exactly the thing that would
erode it by looking like a good enough substitute.

---

## 4. The honest residue — freshness

Typing gets you **"this view is faithful to a graph."** It does not get you **"to
*the* graph, *now*."** Freshness is not a type property, so a correct-but-stale
render is still expressible. An attack whose goal *is* staleness — show the operator
the authority set from before the grant — is not addressed by §3.

Two candidate answers, neither free:

1. **Reserved region.** Anything where staleness is itself the attack goes in the
   compositor-reserved region (§3.4), painted by the compositor, no app cap covering
   those cells.
2. **Linear observation token.** Thread a linear token that each render *consumes*,
   so a view cannot be re-derived from a stale observation. Enforcement rather than
   discipline; cost is a token discipline through the view path.

This is a **NEEDS-AUTHOR sibling to port-design §8 item 1**, and it is the one place
where "scriba cannot lie" quietly means "cannot lie about content, can lie about
when." Record it before it is discovered.

---

## 5. What the AI resident actually demands of the capability system

The value of the AI-augment arc to the capability lane is that it is the **first
consumer that needs all four grant operations for real**. Everything before it needed
Move. This is why the sequencing in §9 is right, and it is worth being explicit about
which demand comes from where:

| Demand | Why the agent case forces it | Current state |
|---|---|---|
| **Grant at init** — caps reified to the entry, ambient acquisition retired | An agent's containment claim is vapor while `Terminal` arrives by interim ambient crossing | **E80**, audited, not implemented |
| **Attenuate** — grant narrowing wired to the subtype mechanism | "read pane 3's text layer, write nothing" is an attenuation, not a distinct cap | mechanism IMPLEMENTED, **not wired** to grant narrowing |
| **Delegate** — a holder passing a sub-authority onward | A supervisor agent spawning a worker agent is delegation or it is proxy | design only |
| **Revoke** — as a customer of the alarm system, not a new mechanism | Stopping a running agent is the first case where revocation is operational, not theoretical | design only; **E43** broker half |
| **Cap granularity** — read/write/geometry split, per-layer `LayerCap` | Agent grants are exactly where a god-`Terminal` becomes unusable | port-design §8 item 3, **open** |
| **Witness** — erased reflection (§3) | Authority you cannot inspect is authority you cannot supervise | **NEW**; blocked on §3.3 |

---

## 6. The user model — "user" is two different things

The install-time model (set up an instance, create users, choose what each
position's access is locked behind — anything from nothing to a passphrase to a
keyfile to a hardware token, tunable per position) is coherent, but it uses one
word for two objects that live on opposite sides of the grant. Separating them is
the whole of the design work; fusing them re-mints the principal that §3.1 forbids,
and it will re-mint it wearing the friendly face of *the user who owns this file*.

### 6.1 Unlock position vs. holder

| | **Unlock position** | **Holder** |
|---|---|---|
| What it is | a key-derivation slot with an auth method attached | a resident that has been handed caps |
| Lives in | crypto + custody | the capability model |
| When | pre-compositor, pre-decryption, at boot | after the grant, for the life of the runtime |
| Governed by | `decision-deployment-custody`'s key-level ladder | `permission-model`, `banks/capability` |
| Plural? | yes — N positions, heterogeneous methods | yes — every resident, including agents |

**One arrow, one direction: authentication SELECTS a grant; it does not
authorize.** Unlock succeeds → key material exists → a manifest instantiates →
`main` receives its ports. Nothing downstream ever asks *who you are*: P3 survives
intact, because by the time anything is running, identity has already been spent
and what remains is a set of held ports.

This is what keeps the auth modules brutally swappable. None / passphrase / keyfile
/ token are interchangeable **evidence producers behind one typed face** — the
replaceability axiom paying out exactly where the product surface wants it. "No
security" is not a special case or a bypass; it is the empty module, and it
composes like any other.

Give the two objects **different words in the notes now**. The cost of the rename
later is every reader who learned the fused version.

### 6.2 File ownership, re-expressed

`node-architecture` says nothing owns anything, and rung 2 has no filesystem — port
views over blocks. So *user owns file* has to be re-expressed or it smuggles an ACL
row into a model built to make ACL rows inexpressible:

> This block range is encrypted under a key derived at unlock position X, and the
> port view over it is what the unlock instantiated.

Same observable behavior, no principal. Ownership is precisely the monolith
`banks/capability` was written to stop being re-minted — it belongs on that note's
list of native monoliths the concept gets mistaken for.

### 6.3 The join problem — per-position tunability is a conformance property

Individually tunable positions mean the composite's strength is a **join, not a
list**. If position A unlocks with nothing and position B with a hardware token,
and both reach the same protected range, B's token bought exactly nothing.

That is a whole-assembly property, which `decision-profiles`' D4 already classifies.
So it wants a **conformance row** — key-material reachability across positions,
checked at verify time the way the frozen port set and the `(total)` clause are —
**not** a deployment guideline in a manual. Written as a guideline, "individually
tunable" is a footgun aimed at whoever configures the instance; written as a
conformance row, it is a feature.

### 6.4 The session guard is the bootstrap of the trusted path

Something must take a passphrase *before* the compositor holds the framebuffer cap
and *before* anything is decrypted. That window cannot use the trusted-path
machinery of port-design §3.4, because that machinery is not running yet. It is not
a §3.4 problem; it is §3.4's **base case**.

It lands on `RUNG-2-MAP` Cluster 1's boot-path row — CPU bring-up, master secret
established in registers at boot, measured boot for the pre-IOMMU window — which is
docs-only with **no catalog element**, its only artifact a 55-line June draft. See
the doc-debt ledger, item 4.

**The conflict to settle first.** `bootstrap-sequence` describes **a** master
secret: one passphrase, one key schedule, in-register. The model above is **N
positions with heterogeneous methods**. Do all positions derive the same master
secret by different paths, or does each hold distinct material? That single answer
decides whether §6.3's join is even well-formed. Cheap on paper now; ruinous after a
manifest format exists.

### 6.5 The piece that admits a holder

Admission is not a new subsystem, because `spawn` already is one: a profile staged
into a child runtime that self-verifies before running, held through one linear
port, torn down by consuming it. E80's own row says the profile hands `main` its
caps *the way `spawn` hands `node-main` its peer port*. So:

- **admit** = spawn with a profile manifest (the manifest *is* the grant)
- **authority** = what the profile granted plus what was delegated
- **revoke** = consume the port; teardown already works this way
- **the record** = the port graph itself — no registry, per edge 8

The unsolved piece is delegation arithmetic: linearity means handing a cap away
loses it, so "parent keeps its authority, child gets a weaker one" needs
attenuate-then-split with the join of the shares no greater than the original. Two
carriers exist and neither is chosen — the subtype mechanism (implemented, unwired
to grant narrowing) or the coeffect semiring (**E38**, where sums-to-no-more-than is
the native operation). **E78** is the same motion at the syscall floor. One decision
covers all three; see §9.

---

## 7. Crypto at the membrane — inbound verifies, outbound confines

Handling crypto as a port boundary is right, and it is not a new seam: `open-edges`
G4 already resolved the membrane in both directions — inbound (B→A) **verifies**,
governing integrity; outbound (A→B) **confines**, governing confidentiality,
capability containment, and the exposure window. G4's own "still open" is a port
that is outbound then inbound as one protocol, filed as edge 14's port protocol.
**Encrypt-then-read-back is exactly that shape.** So crypto lands on an existing
open edge with the machinery already drawn.

### 7.1 Split by direction, not by "crypto"

"We type the inputs and admit we can't type the outputs" concedes more than
necessary. Crypto is half of each discipline, and the membrane already has both:

- **Verification is inbound and IS checkable.** A signature check, a MAC check, an
  attestation — each produces evidence, which is what a bridge's inbound verify
  consumes, and divergence is already an alarm with a counter-effect.
- **Encryption and key derivation are outbound.** No refinement characterizes
  ciphertext; that half is *confined* rather than verified.

Writing it as one untypeable blob collapses a distinction the rest of the model
depends on.

### 7.2 The primitive is B; the protocol is A — and the protocol is where the bugs are

Typeable without proving any cryptography:

- **Nonce uniqueness as quantity-1.** A nonce that must be consumed exactly once is
  a linear value. Nonce reuse is the catastrophic AEAD failure mode, and QTT makes
  it *inexpressible*. Highest-value typed property in symmetric crypto, and free.
- **Key/context indexing in the erased fragment** — the §3 witness move applied to
  ciphertext: indexed by 0-quantity key and context terms. Proves nothing about the
  cipher; makes decryption under the wrong key or in the wrong context fail to
  typecheck. Key confusion and cross-context decryption are most of the real CVEs.
  Carries §3.3's dependency.
- **Length and shape refinements** — ordinary E9 work.
- **E40's linear `Secret` with a single guarded exit** (type-level seed exists) and
  **E38's `clear-window <= N`** exposure grade. Both already seated in RUNG-2-MAP
  Cluster 2.

Unprovable strength, highly typeable plumbing. State it that way or the note talks
itself out of the wins.

### 7.3 The minimal secure runtime is a profile, not a construct

"A tiny secure crypto runtime wrapped in full chirality" needs nothing new. A runtime is
a configuration of modules; `spawn` stages a profile into a child that self-verifies
and is held through one linear port; `decision-profiles` makes profiles additive
manifests over a frozen port set. So it is **a small manifest plus one port** —
which is also what principle 6 and deployment-custody's anti-centre argument would
independently produce.

**Rung honesty to record alongside it:** at rung 1 the split buys architectural
clarity and blast-radius bounding, **not** isolation. `trust-boundary` says the whole
custody model is discipline on a Linux we do not control until metal, and
derive-not-store with the register root is rung 2.

**A threat-model call, not a default:** which way data crosses the boundary.
Key-never-leaves means plaintext crosses *in*, which is more exposure surface than
holding a linear `Secret` locally and crossing with ciphertext. Decide it explicitly.

---

## 8. The capability rung is not a system

`banks/capability` opens with the warning that applies to its own name:

> The recurring misfire is to see the monolith "missing" and say *you need a
> capability system / a permission layer / a revocation mechanism*. You mostly
> don't.

Authority is already a linear port whose type is the authority; non-forgeability is
already a four-tier conjunction; revocation is already a customer of the alarm
system. So **"build the capability system" is the phantom the bank exists to
prevent.** The real content of this rung is the §5 table: six named shards, most
with homes already assigned, one of them (Move) enforced, one (Attenuate)
built-but-unwired, and one (Witness) new.

Framing it as a rung is still right — it is a coherent focus with a completion
condition. But the completion condition is *those rows go green*, not *a subsystem
exists*.

---

## 9. Sequencing — the two lanes hiding in one word

The order moved during the session that produced this doc, and the movement was a
*disambiguation*, not a reversal. "Crypto" names two lanes:

- **Crypto-as-agreement** — attestation, MACs, splits, a bridge's inbound verify.
  This is downstream of capabilities, for the reason `permission-model` already
  gives: guard the name, leave the resource open, and you have theater. Agreement
  says the evidence lined up; it never says who could reach the crossing at all.
  Ship it over an unbounded caller set and it is conditioned on nothing.
- **Crypto-as-confidentiality** — at-rest encryption, key derivation from a
  passphrase / keyfile / token, session unlock. This is *upstream of everything*,
  because it is what the boot-time grant is derived from. It is not guarded by
  capabilities; it is their precondition.

So the working order is **TUI substrate → AI augment → crypto-as-confidentiality +
boot (install ceremony inside the boot lane) → capability shards →
crypto-as-agreement → fully self-hosted role**, and the two claims below are what
hold the remaining ordering up.

**Capability before crypto-as-agreement.** As above — and the author's original
read ("the capability work has to come before crypto or the crypto doesn't matter")
is correct for this lane specifically. The doc base already supports it.

**Confidentiality before capability.** The install ceremony establishes the key
material an unlock position derives, and the unlock is what selects the manifest
that grants the first ports (§6.1). A capability model whose initial grant comes
from nowhere has an ambient root at t=0. `bootstrap-sequence` is where this lands,
and per §6.4 it is the least-current note in the base.

**AI augment before capability.** Less obvious and worth stating: the augment arc is
what makes the capability shards *specifiable*. Attenuation, delegation, and
revocation have been design-only for a long time not because they are hard but
because nothing yet needed them concretely enough to fix their shape. An autonomous
resident needs all three on day one. Building them first would be speculative;
building them second means the worked examples write themselves.

**The exception — draw before deep.** Delegation and revocation should be *drawn*
(a decision note, not elements) **before** the agent work goes deep, because the
agent implementation will otherwise bake assumptions about both, and those
assumptions become the de facto design. Cost is one docket item and one decision
note, not a build lane.

**Design-now / build-later applies to the whole of §6.** The install ceremony is
rung 2 by the project's own trust boundary — hardware key levels are seated there,
and at rung 1 key handling is discipline on a Linux we do not control. But drawing
it now is cheap and high-leverage, because it constrains what a *manifest* is, which
is E80's shape, which rung 1 needs regardless. Design at the rung where it is free;
build at the rung where it stops being theater.

---

## 10. NEEDS-AUTHOR — do not silently resolve

> **⚑ RESOLVED / DRAWN 2026-08-11 (author ratified).** The items below were the open
> list; the author ratified all recommendations. Settled + leans, keyed to the numbers:
> **1 Freshness** — LEAN linear observation token (drawn; `TERMINAL-PORT-DESIGN §8.8`).
> **2 Witness shape** — SETTLED **per-cap with composition** (locality; whole-graph
> wrong at scale). **3 Erased-position rule** — NOT open: **already enforced**
> (`effects.py:48`); only the edge-2 *prose* is outstanding (doc-debt 3). **4 Cap
> granularity** — SETTLED **split early**, compositor retains + grants narrowed
> read/write/geometry + per-layer `LayerCap` (`TERMINAL-PORT-DESIGN §3.6`). **5
> Delegation semantics** — LEAN bounded re-delegation + attenuation record (ties to
> 11; draw before deep). **6 Catalog letter** — LEAN cap **shards stay `E#`**,
> AI-resident **program** = new series / `T20+`. **7 One master secret or N** — author,
> rung-2, draw later. **8 Key-material reachability** — SETTLED **yes, a conformance
> row** at `chirality verify` (D4). **9 Naming** — SETTLED **"unlock-position" vs
> "holder"**. **10 Crypto data direction** — LEAN **ciphertext-out** (hold a linear
> `Secret` locally). **11 Delegation carrier** — LEAN **E38 coeffect semiring** (native
> sums-to-no-more-than; one answer covers Attenuate/Delegate/E78; draw before deep).
> Terminal deltas (§0–§3 reflector/input-half/granularity) folded into
> `TERMINAL-PORT-DESIGN`; the witness (§3) into `docs/banks/capability.md` Shard H.

1. **Freshness** (§4) — reserved region, linear observation token, or accepted as
   discipline. Sibling to port-design §8 item 1.
2. **Witness shape** (§3.2) — is `CapView` indexed by a whole `CapGraph`, or per-cap
   with a composition rule? Whole-graph is simpler and probably wrong at scale.
3. **Erased-position rule** (§3.3) — this is edge 2's outstanding statement. It is
   now load-bearing for a second customer; does that promote it in the docket?
4. **Cap granularity** (port-design §8 item 3) — this doc's §5 argues split-early and
   compositor-retains-and-grants, on the Clock/Timer precedent. Author's call.
5. **Delegation semantics** — does a delegated cap carry an attenuation record, and
   is re-delegation bounded? Affects whether §5's Delegate row is one element or
   three.
6. **Does the agent resident get its own catalog letter?** It is not `E#` (not the
   language) and arguably not `T#` (not the terminal). A third series, or `T20+`.
7. **One master secret or N?** (§6.4) — do all unlock positions derive the same
   master secret by different paths, or hold distinct material? Blocks §6.3.
8. **Is key-material reachability a conformance row?** (§6.3) — D4 says the join is
   a whole-assembly property; does `chirality verify` check it, as it does `(total)`?
9. **Naming** (§6.1) — the two senses of "user" need two words before either
   appears in a manifest format or a public note.
10. **Crypto boundary data direction** (§7.3) — plaintext crosses in, or ciphertext
    crosses out? Threat-model call; changes the exposure surface, not the types.
11. **Delegation carrier** (§6.5, §8) — subtype narrowing or the E38 semiring. One
    answer covers Attenuate, Delegate, and E78; three answers triples the rung.

---

## Relational anchors

`TUI/docs/TERMINAL-PORT-DESIGN.md` (§0 separation invariant, §2 structured tier, §3
capability/identity model, §3.4 trusted-path residue, §4 Pty cap, §8 open questions)
· `docs/permission-model.md` (four grant operations, altitude split, guard-must-lower)
· `docs/banks/capability.md` §1 (capability = port held; the monolith warning) ·
`docs/decision-effect-facets.md` (possession bounds exercise) ·
`docs/decision-b-in-type.md` (property in the type, not the packaging) ·
`docs/decision-profiles.md` (additive manifests; renderer sets) ·
`.planning/RUNG2-SECURITY-MODEL.md` (cap-not-principal; legible in the port graph) ·
`docs/live-environment.md` (screen is a port; view-anything) ·
`ROADMAP.md` backflow 2026-07-06 (erased positions must be effect-free) ·
`docs/bootstrap-sequence.md` (register root, pre-IOMMU window — least-current note
in the base, see doc-debt item 4) · `docs/open-edges.md` G4 (inbound verifies /
outbound confines) + edge 14 (port protocol) + edge 8 (no global registry) ·
`docs/node-architecture.md` (nothing owns anything) ·
`.planning/RUNG-2-MAP.md` Cluster 1 (boot path, no catalog element) + Cluster 2
(secret root) · `.planning/SELF-IMPLEMENT-CATALOG.md` (E33, E38, E40, E43, E52,
E61, E76–E78, E80)
