# Reach: the connectivity model

**Opened 2026-09-05** from a design session with the author. This is the
connectivity half of `.planning/OWN-WEB-GAP.md`, worked in depth. It settles
shape and settles no build order. Nothing here is minted and no code is
touched.

The question this answers: **how does one instance get a value from another,
with IP's model kept out of the design and admitted only as a named
exception.**

**Author ruling, 2026-09-05.** IP is mostly ignored. The focus is the model in
its own terms. Where IP appears it is a primitive that breaks the model on
purpose, to join two remote instances that have no native route between them.

---

## §1 · The model

| | |
|---|---|
| a value has a mark | §3 specifies it. That is the entire naming system, and it names no machine, place or service |
| a medium carries parcels | bounded, opaque, to whoever is on it, with no addressing anything above it reads |
| reaching is asking | `ask M` goes out, `give M bytes` comes back, and the bytes are checked against `M` |
| forwarding is unprivileged | a peer that heard an ask and lacks the value may pass it on. Nothing designates a router, so nothing has to be trusted as one |
| parties are a separate mechanism | layered above, and only a mutable answer needs one |

Three verbs and one invariant. A fetch has no handshake, no session, no
identity and no cipher in it, because the address is the proof.

## §2 · The chain

| step | the web's mechanism | what we do | why |
|---|---|---|---|
| name a thing | URL, fusing scheme, host and path over a registered namespace | the mark | an address that is derived needs no issuer, so there is nothing to register, renew, revoke or seize |
| find who has it | DNS, a hierarchy of authorities with its own protocol and cache | put `ask M` on the medium, and whoever holds it answers | the answer is self-verifying, so the finder needs no authority and a lie costs one retry |
| reach them | IP routing to a location, source address on every packet | §4. A way list is folded into a hop list, and no hop is a location | a query has no destination, so route drops out of the model instead of being replaced by something else |
| move bytes | TCP, ordering and reliability and congestion control | a medium carries one bounded opaque parcel to whoever is on it | two operations, put out and hear, which a shm region, a serial line and radio all satisfy |
| trust the bytes | TLS plus a CA root store you did not choose | hash what came back against the mark you asked with | integrity belongs to the address, so nothing on the path is trusted with anything |
| trust the party | TLS, the same root store | required only when a party is asked for something mutable | fetching a value then holds no authentication step at all |

**Where the interference enters is the verb.** `connect` imports location, and
a source address, a destination address, a port number, a connection and a
route arrive with it. `ask` imports none of them. A point-to-point pipe is
connection-shaped, so building the first rung on one re-imports the model
quietly. A medium several parties hear does not.

## §3 · The mark

"Hash the content" specifies nothing. A mark is a typed record, and every
field is there because something reads it before the bytes arrive.

| field | what it is | who reads it, and when |
|---|---|---|
| `alg` | which digest, a closed sum | the verifier. Carrying it is what lets the digest change without breaking every mark ever written |
| `digest` | the bytes of the hash | the verifier, after the parcel lands |
| `size` | the total size of the value | the **receiver, before accepting anything**. It is what lets a bound be demanded rather than discovered |
| `chunk` | `whole`, or `chunked n` | the router, before asking. It is what lets one value be asked for in pieces |

**Verification, per chunk shape.**

| shape | what the digest commits to | what verifying one parcel proves |
|---|---|---|
| `whole` | the bytes | everything, once |
| `chunked n` | the root of a hash tree over the parcels | that parcel belongs to this value, on its own, with no other parcel present |

The chunked case is what makes a fetch resumable, splittable across several
peers at once, and verifiable piecewise. It is also the reason `size` and
`chunk` are separate fields: the parcel count is derivable from the two, so
nothing carries a count that can disagree with them.

⚑ **The four fields are what an asker holds. What crosses the wire is open,
and §12 and §13 hold it.** The first version of this section had a router
reading `size` and `chunk` before the bytes arrive. That is a level 4
disclosure under §8's ladder and it contradicts the author's 2026-09-05 ruling
that a hop learns nothing about what it carries. The field set survives the
correction. Its wire form does not follow from it.

**What a mark does not carry.** No location, no party, no time, no name, no
transport and no path. A mark that carried any of them would let a router
prefer one holder over another for a reason the address cannot justify, which
is the property being bought here.

**The dependency, stated once.** A mark needs a collision-resistant digest and
this tree has none. `lib/crypto/` holds ChaCha20 and Poly1305, which are a
cipher and a MAC. The only content hash in the tree is FNV-1a-64
(`apc.chiral:122-130`), a 64-bit non-cryptographic hash that is correct for
what E112 uses it for and wrong for this. **`mark-of` is therefore new work and
`block-id` is a precedent for the shape instead of an implementation to
rename.** The whole addressing model has exactly one cryptographic dependency
and `arcs/native-protocol-arc.md` already rosters it: `N1`'s hash slice, with
slices 1 and 2 built and 3 and 4 open.

## §4 · Routing

Routing is a **fold over an ordered list of ways**, so a deployment's reach
policy is a value and every new medium is one arm.

| type | is | shape |
|---|---|---|
| `Hop` | one place to try | the local hold, a bus, a named peer, a tether |
| `Way` | one strategy, a closed sum | `w-held`, `w-bus b`, `w-peer p`, `w-tether t`, `w-near` |
| `Table` | what this instance knows | buses it is on, tethers it holds, peers it has heard, marks it holds |
| `route` | the fold | `(-> Mark Table (List Way) (List Hop))` |

**The five properties, each checkable.**

1. `route` cases totally over the `Way` sum, so a new way is one arm and one
   function and the compiler names every site that has to grow.
2. The order is decidable from the value. The way list is the order, which is
   the same shape `fold-sgr` (`grid.chiral:232`) already has for style.
3. `route` reads the mark's fields and never the bytes, so routing a value is
   possible before holding any of it. ⚑ This property is stated for the
   **asker's own** router. A hop reading those same fields is the level 4
   disclosure §12 covers, and §8 records why the two cases separate.
4. A way that cannot serve a mark returns an empty hop list, so the fold
   continues instead of failing. Refusal is a value.
5. The table is data. A `.manifest` is pure declared data checked by the
   loader, and the tree ships two already (`prog/climb.manifest`,
   `lib/lowering/tal/target-linux.manifest`).

**What the modularity buys, stated as edits.**

| to add | the change |
|---|---|
| a new medium | one `Way` arm, one `.port` |
| a tether to another instance | one row in the table manifest, and no code |
| a local cache | one `Way` arm, placed ahead of the others in the list |
| a different reach policy per deployment | reorder the way list |
| a structured overlay later | one `Way` arm, `w-near`, and nothing above it moves |

**Chunking and routing compose.** A `chunked n` mark splits into one ask per
parcel, and each parcel ask routes on its own. One fetch can draw from a bus,
a cache and a tether at the same time, and each parcel verifies against the
tree root alone.

### Reachability: the gate sits here and nowhere else

**One security model, constant.** Everything is encrypted, routing is secured,
both ends are protected, and anonymity is available. None of that varies.

**One axis, two positions**, differing only in whether routability exists by
default.

| position | routability | everything downstream |
|---|---|---|
| open | follows from the mark | identical |
| gated | follows from the mark **and a grant** | identical |

| | signature |
|---|---|
| open | `route : (-> Mark Table (List Hop))` |
| gated | `route : (-> Mark Grant Table (List Hop))` |

An unauthorized party meets no refusal. It holds no function that yields hops,
so it has nowhere to send an ask. After route formation both positions run the
same code, the same envelope, the same cadence and the same anonymity, which is
why the security model is described once.

**Anonymity survives the gate**, because a `Grant` proves permission and never
proves identity. A bearer capability or a membership proof answers "you may"
without answering "who".

**The precedent is one system rather than two.** Tor v3 onion services with and
without client authorization are these two positions. Same crypto, same
both-ends-hidden property, same anonymity. Without client auth anyone resolves
the descriptor and reaches the service. With it the descriptor is encrypted to
credential holders, so the unauthorized cannot form the ability to reach it and
cannot learn it exists.

`w-near` is the only way that needs a structured overlay over digest space,
and it is the only one that needs a maintained peer table. Leaving it as one
unbuilt arm is what keeps a structured overlay out of the model's floor.

## §5 · Media, and the tether

A medium has two operations and no more: put a parcel out, and hear parcels.

| | fits natively | forces location addressing |
|---|---|---|
| media | a shm region several processes read, a serial line, radio, raw framing on a wire | IP |

A **`Tether`** is the named exception: exactly two participants, the same three
verbs, and no forwarding operation. Tailscale joining two remote instances is
the case it exists for.

| the tether's property | how it holds |
|---|---|
| the route ends there | it has no forwarding function, so a parcel arriving on one cannot be relayed onto the fabric as native |
| foreign addressing stops there | nothing above it has a representation for a dotted quad. `lib/protocol/inet.chiral` is already the pure translator and already sits outside `ports/` |
| it can be counted | every tether site is greppable, the discipline `lib/capability/secret.chiral` already uses for reveal sites under E40 |

## §6 · The set of things

| the thing | name | what it owns |
|---|---|---|
| the address of a value | **`Mark`** | §3. Four fields, one of which is the digest |
| the bounded unit a medium carries | **`Parcel n`** | opaque bytes with the bound in the type, the way `lib/ports/pool.port:3-5` does it today |
| a medium several parties hear | **`Bus`** | put out, hear. No addressing of its own |
| the three things you can say | a closed sum: ask, have, give | `lib/protocol/reach.chiral` |
| one place to try | **`Hop`** | §4 |
| one reach strategy | **`Way`** | §4, a closed sum |
| what this instance knows | **`Table`** | §4, a `.manifest` |
| the authority to form a route | **`Grant`** | §4. Proves permission and never identity, so the gate costs no anonymity |
| a medium that ends the route | **`Tether`** | two participants, no forwarding |

The constructor prefix wants choosing against the whole link set. `r-` is spent
on `Rendering`, and `arcs/native-protocol-arc.md` records real duplicate-label
collisions across a blob already (`St` and `st`, `OpenR`).

## §7 · What is in the tree

Measured 2026-09-05 against `lib/lowering/tal/crossing-wraps.chiral:39-53`.

| piece | state |
|---|---|
| a bounded region with its size in the type | **built.** `pool-create`, `pool-write`, `pool-read`, `pool-close`, all lowered. E120, E122 |
| a content hash at node granularity | **built and shipped**, and wrong for a mark. `apc.chiral:48`, FNV-1a-64, derived at each use, recomputed and verified by the decoder. E112 |
| a collision-resistant digest | **absent.** `lib/crypto/` holds ChaCha20 and Poly1305. This is `native-protocol/N1`'s open hash slice |
| declared data checked by the loader | **built.** Two `.manifest` instances ship |
| a bus among processes with a common ancestor | reachable today. A pool's backing memfd returns as a linear `Fd`, so a parent creates and children inherit |
| a bus among independently started processes | **blocked.** `sock-send-fd` has no crossing-wraps row, and `sock-listen` and `sock-accept` have no TAL body. There is no `bind` extern at all |
| the three verbs, `Mark`, `Way`, `route` | nothing |

## §8 · The observer ladder

What a party carrying traffic can learn, ordered by what hiding it costs. Each
level is an open design item below, and §14 holds the primitives every level
consumes.

| level | what leaks | what hiding it costs | item |
|---|---|---|---|
| 1 | traffic exists | cover traffic, permanently | §9 |
| 2 | size, timing, rate | padding and a cadence | §10 |
| 3 | who talks to whom | sourceless packets plus destinationless hops | §11 |
| 4 | which value is wanted | open research | §12 |
| 5 | the value itself | encryption, and an envelope deciding who opens what | §13 |

**The three-way tension.** Two of these three are available at once.

| | content-addressed | a hop learns nothing | stateless |
|---|---|---|---|
| the ask in the clear | yes | **no** | yes |
| per-link labels | yes | yes | **no**, a label needs setup |
| broadcast on one bus | yes | yes | yes, and it never leaves that bus |

**The implication, and it is the author's requirement that produces it.** The
2026-09-05 ruling is that a hop learns nothing about what it carries. A hop
learning nothing across a link requires per-link state, which requires a link,
which puts a party at the floor of the model. §15's `R1` is the fork that
records this, and the ruling reaches it.

## §9 · Discovery, and why it is the cover stream

### Three things wear the name

Separating them is what lets the design close.

| | the question | the mechanism |
|---|---|---|
| peer | who am I linked to | out of band pairing. The first hop is a human act and no network mechanism reaches it |
| existence | what is there to want | an index is a document. No new mechanism |
| content | who holds mark `M` | a holdings summary |

### Existence discovery needs no mechanism

A document carries the marks of other documents, so following a link is a
fetch. An index is a document listing marks, so searching is a fetch of
somebody's index. The one new thing is a mutable pointer, "the current index of
party `P`", which belongs to the naming layer and carries a signature. The rest
is already the three verbs.

This is why existence discovery costs nothing to design. It reduces to content
discovery plus one mutable pointer per party.

### The summary answers the open position only

A holdings summary answers "who holds what". For a gated mark that question is
askable only by a grant holder, so **a summary of gated holdings is itself
gated content**. The recursion closes with no new mechanism, and an open-tier
summary never contains a gated mark. Everything in this section is scoped to
the open position by that rule.

### Content discovery is a holdings summary

| | |
|---|---|
| what a peer publishes | a summary of the marks it holds. A Bloom filter is the reference shape, roughly 10 bits per mark at a 1% false positive rate, so ten thousand marks is about twelve kilobytes |
| what a false positive costs | one wasted ask, which is why the filter can be deliberately small |
| how a summary is exchanged | **the summary is a document with its own mark**, so fetching one uses the three verbs and needs nothing new |
| what it buys | with a summary per paired peer, a real ask goes to one peer instead of flooding. `route` reads them out of `Table` |

### Why this is the cover stream

Summary sync carries four properties that ordinary cover traffic lacks.

| property | why it holds |
|---|---|
| unlimited supply | a summary can always be re-fetched, at a higher resolution, or for a peer's peers |
| satisfiable by construction | it exists and it resolves, so the satisfiability floor below is met with no effort |
| real work | every synced summary makes some future real ask route in one hop |
| identical shape | a summary fetch **is** a fetch |

**More cover makes real routing cheaper.** Ordinary cover traffic is a tax.
This is a prefetch that happens to be indistinguishable from the thing it
hides, and that is the whole of low cost and high value. It is also why the
mechanism has to be discovery specifically and cannot be arbitrary filler.

**The satisfiability floor.** A cover ask has to be answerable. A holder that
can serve some asks and never others separates real from cover by which ones
hit. Summary sync meets this without trying, and it is the constraint that
kills the obvious cheap answer of asking for noise.

### Two adversaries, and cover answers one

| adversary | what it sees | what cover does |
|---|---|---|
| a hop or an on-path observer | that a slot was used | **solved.** Under per-link encryption and §10's cadence every slot is opaque and identical, and summary sync fills the idle ones |
| the peer being asked | exactly which mark was asked | **nothing.** A peer knows a summary fetch when it serves one, so summary traffic is no decoy against it |

This is the distinction the design turns on. Against a hop, cover is free and
the problem closes. Against the peer serving the ask, a decoy has to be a
plausible real ask, which means asking for values that are unwanted, which
leaks the neighbourhood of the wanted ones.

**One free contribution.** Bloom false positives produce genuine asks for
values the peer does not hold, and to that peer they are indistinguishable from
real asks. The filter's error rate is a decoy rate, and it is already being
paid for another reason.

### The spectrum, scoped to the peer being asked

The rows below apply to the second adversary only. Against the first, §10's
cadence already closed it.

| a decoy ask asks for | usefulness | what it leaks to the peer |
|---|---|---|
| marks that peer advertised | high. It fills the cache with real values | the interest, exactly |
| marks adjacent to what is already held | medium. It prefetches plausibly | the neighbourhood of the interest |
| marks drawn from a shared public set | low | nothing |
| a Bloom false positive | zero, and it is free | nothing, and it arrives without being chosen |

### The counterintuitive part, and it is deliberate

Re-fetching a whole summary is wasteful beside fetching a delta. The waste is
the cover, so the wasteful option is the better one here. A delta scheme would
need a mutable pointer per summary and would shrink the cover supply at the
same time.

### The disclosure this introduces

Publishing a summary tells anyone who fetches it what a peer holds. That
disclosure runs the opposite direction from every other one in §8, and it is
the price paid for one-hop routing. Whether a summary is public or per-link is
`R14`.

### What would settle it

The summary's shape and error rate, whether a summary is public or per-link,
and whether a decoy mix beyond Bloom false positives is spent at all.

### Notes to cover

- the summary's size and false positive rate, and who chooses them
- how often a peer republishes as its holdings change, and what the stale
  window costs a router
- whether a summary covers what a peer **holds** or what it can **reach**,
  which are different claims and the second one composes across hops
- a peer publishing a summary that claims everything, to attract asks. Nothing
  above refuses it and the cost lands on the asker
- how a peer's peers' summaries are named without a mutable pointer per peer
- bootstrapping an instance with zero peers, where pairing is the only entry
- what a peer does with a value it fetched as cover: hold it, or drop it
- whether cover asks are forwarded the way real ones are, and what that costs
  every peer downstream
- whether an idle instance is distinguishable from a busy one at any distance
- how this meets §10, since cover fills the idle slots and the cover rate is
  the slot rate minus real traffic

## §10 · Cadence

**The idea.** The timing defence is a constant rate. Timing then carries no
information, because the timing is a constant that the payload does not touch.

**Established.**

| property | what holds |
|---|---|
| timing leak | zero by construction, and it is a property that can be stated and gated |
| latency | bounded and deterministic, at most one slot interval |
| bandwidth | the slot rate, always, idle or busy |
| speed | purchasable. The cadence is the price, so consistency and speed are one knob here |

A schedule is a value. Emission is a total function of the schedule and the
queue, so "this link leaks no timing" is checkable in the same way a total
fold is.

**What would settle it.** Whether the cadence is per link, per medium or per
deployment, and what the queue does when it exceeds the slot rate.

**Notes to cover.**

- queue overflow is where the leak returns, and nothing here addresses it
- backpressure under a fixed cadence, and whether a sender may signal it at all
  without signalling load
- whether a cadence is negotiated between two peers or declared unilaterally
- a slot carries one parcel of one size, so a value spanning many slots leaks
  its size through the span length unless the span is padded too
- whether an instance that stops emitting is distinguishable from one that left
- which clock this needs, and whether `lib/ports/clock.port` supplies it

## §11 · Destinationless hops

**The idea.** Sourceless packets are the easy half. The harder half is that a
hop cannot know the destination, with the whole route committed at message
creation.

**Established.** Three things have to hold together.

| requirement | mechanism |
|---|---|
| a hop learns only its next link | a layered header, each layer opened by exactly one hop |
| a hop cannot tell where it sits in the path | the header is **fixed length and padded**. A header that shrinks per hop leaks position, and a hop that knows it is last knows the destination |
| a hop has no function that could read further | the hop's view is a distinct type with one readable field. There is no destination field in the value, so this holds by construction |

The third row is where this tree can enforce what the reference systems state
as a convention. A hop is handed a value whose type has one field. Reading the
payload is unavailable to it, in the sense that no function of that type
exists, which is `lib/capability/secret.chiral`'s custody rule under E40
pointed at wire fields.

**What would settle it.** Who selects a path and from what knowledge, and what
the maximum hop count is, since the header is padded to it on every message.

**Notes to cover.**

- the sender needs topology to build a route, and holding topology is itself
  information about the sender
- the maximum hop count is paid as padding on every message, including
  one-hop messages
- whether a reply retraces the path, and what a retraced path reveals
- whether every parcel of a chunked mark takes one path or many
- what a hop does when its next link is down. A hop that can report failure
  back to the sender has learned something about the sender
- whether a hop may refuse to forward, and how a refusal travels without
  naming the refuser

## §12 · Which value is wanted

**The state, stated plainly.** This is private information retrieval. The cheap
constructions cost far more than this model spends anywhere else, nothing
deployed does it well, and the author has
marked it as research. Content addressing hands this level out by
construction, because the mark **is** the identifier of the content, so anyone
who has seen that content recognises the ask. Encrypting the payload does
nothing about it.

**What is available short of solving it.**

| partial | what it buys |
|---|---|
| ask only peers there is a link with | the leak is bounded to peers that were chosen |
| per-link derived tags | one value asked on two links is unlinkable across them |
| the cover mix from §9 | an observer sees which asks happened and cannot say which were real |

None of those is a solution and each belongs in the doc as a mitigation.

**Notes to cover.**

- whether per-link derived tags earn their key schedule
- whether a holder can serve a value without learning which value it served
- an observer's confidence under a given cover mix is a number, and nobody has
  computed it here
- how much of this changes if the ask is for a chunk instead of a whole value

## §13 · The envelope

**The idea.** One parcel, several audiences, each reading its own slice, with
who may open what carried in the type.

| audience | what it may read |
|---|---|
| the hop | its next link, and the length |
| the holder | which value is wanted |
| the asker | the value |

**Established.** The type-level claim: a hop is handed a value that has no
field containing the payload. Opening it is unavailable instead of forbidden,
which is the same distinction §11 draws and the same E40 precedent.

**What would settle it.** How many sealed slices a parcel carries, since each
one costs a key derivation, and whether the holder's slice and the asker's
slice are one slice.

**Notes to cover.**

- nonce management across slices. One nonce reused across two slices under one
  key is the classic failure, and a long-lived link key makes it easier to hit
- replay of a sealed slice to a different hop
- whether the envelope shape is fixed or varies per medium
- **whether the type-level claim survives lowering.** The property has to hold
  after erasure, and that is a real question for this tree rather than a
  rhetorical one
- what a hop does with a slice it cannot open, and whether malformed and
  not-for-me are distinguishable to it

## §14 · The primitives

**The axis, and the author's ruling on it.** Compute belongs at message
creation and at reading. The amount sent does not drive the public-key cost.

| position | how often | what may sit here |
|---|---|---|
| per pairing | once per relationship, ever | public key work. The PQ KEM |
| per message creation | once per message | symmetric key derivation, one per layer |
| per hop | once per hop per message | one symmetric open |
| per parcel | every parcel | one AEAD open |

**The rule that falls out: no public-key operation sits on the forwarding
path.**

**The seven primitives.**

| primitive | needed by | position | approximate size | state |
|---|---|---|---|---|
| collision-resistant hash | marks, the chunk tree, the KDF base | per parcel | 32 B out | **absent.** `native-protocol/N1`'s open hash slice |
| KEM, PQ and classical hybrid | link establishment at pairing | per pairing | ~1.1 KB ciphertext, ~1.2 KB public key | absent |
| AEAD | the payload, each envelope slice, each layer | per parcel | 16 B tag, 12 B nonce | **built.** `lib/crypto/chacha.chiral`, `lib/crypto/poly1305.chiral` |
| KDF | per-layer and per-parcel keys from a link secret | per creation and per hop | 32 B out | absent, and it rides whichever hash is chosen |
| signature, PQ | the mutable naming layer only | per claim | ~3.3 KB signature | absent, and **it never touches the fetch path**, because a hash is the integrity proof |
| entropy | keys, nonces, cover selection | per use | one crossing | absent. `native-protocol/N2`, unstarted |
| constant-time judgment | all six above | a compile-time property | none | `native-protocol/N5`, unstarted |

Seven, and the tree holds one and a half of them.

**Sizes, from memory.** Egress is blocked from this sandbox, so these carry the
same VERIFY caveat `docs/decisions/decision-inspiration-policy.md` puts on its
license floor. ML-KEM-768 public key ~1184 B and ciphertext ~1088 B. ML-DSA-65
public key ~1952 B and signature ~3309 B. FALCON-512 signature ~666 B with a
float dependency. SLH-DSA public key 32 B with a signature in the tens of
kilobytes. X25519 public key 32 B. ChaCha20-Poly1305 tag 16 B.

**The onion header problem, and it is the sharpest thing in this file.**
Sphinx-style constant-size onion headers work by re-blinding one group element
at each hop, which is 32 bytes total whatever the path length. ML-KEM has no
equivalent re-randomisation, so that construction does not carry over.
**Post-quantum constant-size onion routing is open research.**

| option | header cost | what it gives up |
|---|---|---|
| one KEM ciphertext per hop | ~1.1 KB per hop, so ~3.3 KB at three hops | it fits nothing with a small MTU |
| classical re-blinding for the route, PQ for the payload | ~32 B of route header | content stays PQ-safe. An adversary who records traffic today could de-anonymise the **route** after a quantum machine exists |
| symmetric layered headers over PQ-established link keys | tens of bytes per layer, and zero public-key work on the forwarding path | the sender must already hold a key with every hop, so routing runs only through peers it has paired with |

**The finding worth deciding on purpose.** The third option does exactly what
the author's ruling asks: PQ runs once per link at pairing, message creation is
symmetric derivation per layer, forwarding is one symmetric open, and reading
is one symmetric open. **Pair-gating, which exists for access control, is also
what puts a shared key on every hop, which is what lets the expensive privacy
property be bought with symmetric primitives.** The thing that reads as a
restriction is what makes the cost affordable.

**Notes to cover.**

- key rotation and re-pairing, and what a rotated link key does to values
  already in flight
- forward secrecy on a link, and whether a compromised link key exposes traffic
  already recorded
- replay protection, and the counter or window it needs
- nonce management under a long-lived link key, which §13 also raises
- denial of service. Unprivileged forwarding means anyone can make a peer work,
  and §1 states forwarding as unprivileged
- the entropy crossing is unstarted and every level of §8 consumes it
- whether reach may state a requirement on the digest, or takes whatever
  `native-protocol/N1` picks

## §15 · Open forks

| id | the fork | why it decides something |
|---|---|---|
| R1 | `ask` and `give` over a shared medium, or a party in the loop from the start | the second turns a query into a conversation, which puts identity and a handshake under the floor and moves the whole crypto arc ahead of the model. ⚑ **The author's 2026-09-05 ruling reaches this fork.** §8 shows a hop learning nothing across a link requires per-link state, which requires a link. The fork stays open here because the author settles it, and §8 records that the requirement already implies one side |
| R2 | forwarding unprivileged, or a peer opts in to relaying | unprivileged is stated in §1 and it makes a peer's cost unbounded by anyone else's asks |
| R3 | the digest, and its width | it is `native-protocol/N1`'s slice and this roster consumes whatever that arc picks. Whether reach may state a requirement on it is the fork |
| R4 | the parcel size, and whether one instance may hold two | `pool.port` puts the size in the type, so two sizes are two types. A tether and a bus with different bounds is the case that forces this |
| R5 | whether `have` exists | ask and give are the floor. `have` saves everyone answering at once and adds a round trip. It is a real cost either way |
| R6 | `Bus` as the word | against the tree's register of `wire`, `pool`, `grid` and `span` |
| R7 | the cover mix | §9. Where on the usefulness-against-leak spectrum a cover ask sits, and whether the mix is a protocol constant or deployment policy |
| R8 | the cadence's home | §10. Per link, per medium or per deployment, and what the queue does when it exceeds the slot rate |
| R9 | the maximum hop count | §11. The header is padded to it on every message including one-hop messages, so the anonymity set and the standing overhead are the same number |
| R10 | who selects a path | §11. The sender needs topology to build a route, and holding topology is information about the sender |
| R11 | the onion header construction | §14. One KEM ciphertext per hop, classical re-blinding with a PQ payload, or symmetric layers over PQ-established link keys. The third is the only one that fits a small MTU and it constrains routing to paired peers |
| R12 | how many envelope slices | §13. Each slice costs a key derivation, and whether the holder's slice and the asker's slice are one slice is part of it |
| R14 | whether a holdings summary is open or per-grant | §9. Publishing one tells any fetcher what a peer holds, which runs opposite to every other disclosure in §8. A per-grant summary costs one per relationship and shrinks the cover supply |
| R15 | whether a summary claims what a peer holds or what it can reach | §9. The second composes across hops and turns the summary into routing state, which is most of a structured overlay arriving through the side door |
| R16 | gossip forwarding against hop blindness | §1 states forwarding as unprivileged and §11 states a hop learns nothing. A peer that gossips an ask has read it, which is the level 4 leak at every hop, and sealing the ask does not help because a gossiping peer must read it to know whether it holds the value. §9's summary is what makes gossip unnecessary and the two sections are one decision |
| R17 | per-packet unlinkability against a shared header | §17. Sharing one header across a value's packets is what makes HORNET fast and what makes its packets session-linkable at every hop. Blinding is inherently asymmetric, so per-packet unlinkability costs one scalar mult per hop per packet |
| R18 | `H`, the max hop count, and whether it is per medium | §17. It is the anonymity set, the standing overhead and the DoS amplification factor at once, and the 500 B radio profile cannot carry the same `H` as a pool |
| R19 | what bounds holder storage | §17. It is the one resource in the model with no bound in a type or a constant |
| R13 | whether the type-level opening claim survives lowering | §13. The property has to hold after erasure. This is the one fork that is a question about this compiler instead of about the protocol |

## §16 · Relation to the roster

`.planning/OWN-WEB-GAP.md` lanes X, L and J are drawn against the earlier
sketch and this file supersedes their content. Lane X's `Mark` and `Seal` split
survives. Lane L's identity, packet and link rows fall behind R1, because a
model with no party in the floor needs none of them to fetch a value. Lane J
collapses into §5, since a native medium is a `.port` and the tether is the
one named exception.

§8 through §14 are six open design items and §17 is the load budget under
them. None of the seven has a lane in that roster at all. The roster's lanes were drawn before the observer model existed.
Rewriting them against this file is owed. It stays undone here.

Rewriting those three lanes against this file is owed. It stays undone here.

## §17 · The load, by party

Every feature in this file lands as work on one of three parties. This section
is the same design read through that lens, with the wire cost beside each row,
because the wire is the constrained resource and §14's small-MTU media are
where it binds.

Sizes below are derived from the field set unless a source is named. HORNET's
300+ byte header and Sphinx's 2048 byte fixed payload are the two measured
figures and the rest is arithmetic over them.

### The sender

| process | runs | crypto | state touched | on the wire |
|---|---|---|---|---|
| pair with a peer | once per relationship, ever | 1 hybrid KEM encap, 1 KDF | writes one link secret | ~2.3 KB, once |
| select a path | per session | none | reads topology and summaries | nothing |
| establish a session | per session | 1 asymmetric op per hop | writes n opaque FSes | a setup packet, header grows with hop count |
| build the header | per message | n symmetric seals, padded to the max hop count | reads the session's FSes | the header budget below |
| build a SURB | per message wanting a reply | n symmetric | none | **doubles the header** |
| form an ask, session-linkable | per packet | n symmetric | none | one header, reused |
| form an ask, per-packet unlinkable | per packet | **n scalar mults** plus n symmetric | none | one header plus a blinding element |
| choose what fills a slot | per slot | none | reads the summary set and the queue | nothing |
| emit | **every slot, busy or idle** | none | none | one packet per slot, standing |
| verify a parcel | per parcel | 1 hash, plus log(n) siblings under a Merkle chunk tree | none | the sibling path rides the give |
| reassemble | per chunked value | none | writes the value | nothing |

Holds: one link secret per peer, one summary per peer, n FSes per live session.

**The feature this table states.** Every decision in the design is in this
column. Path selection, layer construction, cover choice and verification all
sit with the sender, which is what leaves the router with nothing to decide.

### The router

| process | runs | crypto | state touched | on the wire |
|---|---|---|---|---|
| mint its own FS | once per session crossing it | 1 asymmetric op | reads its local secret, **writes nothing** | one FS into the setup packet |
| open its FS | per packet | 1 symmetric | reads its local secret | nothing added |
| peel the payload | per packet | 1 symmetric | none | nothing added |
| blind the header | per packet, **only in the unlinkable corner** | 1 scalar mult, 1 wide-block transform | none | nothing added |
| re-pad the header | per packet | none | none | **constant length, which is the point** |
| check replay | per packet | 1 hash to key the cache | **reads and writes the replay cache** | nothing added |
| re-encrypt on the return leg | per reply packet | 1 symmetric | none | nothing added |

Holds: one long-term local secret, one key per neighbour, a bounded replay
cache with expiry.

**The features this table states, as absences.** A router does not choose a
next hop, does not learn a destination, does not learn its own position, does
not learn whether it is last, and keeps no per-flow or per-session state. Every
one of those is a row that is missing from the table rather than a check that
passes.

**The one thing it writes** is the replay cache, and §8's path-tracing attack
is why it cannot be dropped.

### The receiver

Two roles, loading differently.

**As a holder.**

| process | runs | crypto | state touched | on the wire |
|---|---|---|---|---|
| answer an ask | per ask | none beyond the forwarding it also pays | 1 lookup, 1 read | one give |
| build a summary | per republish | one hash per held mark | reads the whole holding set | nothing |
| serve a summary | per fetch | identical to any give | 1 read | ~10 bits per mark held |
| store a value | per value kept | none | **writes, and nothing bounds it** | nothing |

**As a recipient.**

| process | runs | crypto | state touched | on the wire |
|---|---|---|---|---|
| recognise its layer reads "yours" | per packet | 1 symmetric | none | nothing added |
| open the payload slice | per packet | 1 symmetric | none | nothing added |
| reply through the SURB | per reply | n symmetric, on a route it did not build | none | one packet |

**The feature this table states.** A recipient replies without ever learning
who it replies to, because the return route was built by the sender and arrives
with the message.

### The wire budget

The header is the optimisation target. Its fields, and whether each can shrink.

| field | size | who reads it | can it shrink |
|---|---|---|---|
| per-hop link id | 1 to 2 B | that hop | already minimal. It indexes that hop's own neighbours |
| per-hop key material | 16 to 32 B | that hop | **16 B if the hop expands a seed rather than carrying a key** |
| per-hop MAC | 16 B | that hop | 8 B truncated, at a stated cost in forgery resistance |
| the above, times the max hop count | ×`H` | | `H` is the triple-duty constant below |
| the blinding element | 32 B classical | every hop | **~1.1 KB under PQ. This is the wall** |
| the payload | a fixed size | the recipient | size classes, at a stated leak |
| the mark's digest | 32 B | the holder | 24 B buys 96-bit security instead of 128 |

**Three worked profiles**, at 34 B per hop record and a classical blinding
element.

| profile | `H` | payload | header | total | fits |
|---|---|---|---|---|---|
| pool or LAN | 8 | 2048 B | ~304 B | ~2.4 KB | trivially. This reproduces HORNET's measured 300+ B header |
| tether | 8 | 1024 B | ~304 B | ~1.3 KB | yes |
| **radio, 500 B MTU** | **3** | **256 B** | **~134 B** | **~390 B** | yes, and only at those numbers |

**The radio row is the constraint that binds.** A 500-byte MTU forces `H` down
to about 3 and the payload to about 256 B. It cannot carry the LAN profile at
any hop count, so a small-MTU medium runs a different `H` from a pool, which
makes `H` a per-medium parameter instead of a protocol constant.

**The PQ wall, priced.** Swapping the 32 B classical blinding element for a
~1.1 KB PQ ciphertext takes the LAN header from ~304 B to ~1360 B, a factor of
4.5, and takes the radio profile out of one frame entirely. That is §14's open
research problem expressed as a number.

### The optimisation levers

| lever | what it saves | what it costs |
|---|---|---|
| a hop expands a seed instead of carrying a key | ~16 B per hop, so ~128 B at `H` of 8 | one KDF per hop per packet |
| truncate the per-hop MAC to 8 B | ~64 B at `H` of 8 | forgery resistance, stated rather than assumed |
| lower `H` | linear in the header | anonymity set, per the triple duty below |
| payload size classes | most of the padding on small messages | log2 of the class count, in bits, per packet |
| amortise one header over a chunked value | the header, once instead of per parcel | **per-packet unlinkability. It is the same trade as HORNET against Sphinx** |
| carry the mark once per value instead of per parcel | 32 B per parcel | the parcels become linkable to each other, which the shared path already did |
| a 24 B digest | 8 B per mark | 96-bit security instead of 128 |

The fifth row is the one that matters most and it is the same fork as §14's:
sharing a header across packets is exactly what makes HORNET fast and exactly
what makes its packets session-linkable.

### Four asymmetries

**Asking is expensive and serving is cheap.** The sender pays path selection,
session setup, layering and verification. A holder pays one lookup and one
read. That is what lets the open position stay open without becoming a target.

**The max hop count `H` does three jobs on one number.**

| job | how it uses `H` |
|---|---|
| position hiding | the header is padded to it, so a hop cannot count |
| standing overhead | that padding is paid on every message, one-hop messages included |
| DoS amplification | one attacker packet costs `H` routers a decrypt and a send each |

Raising `H` buys anonymity and buys an attacker leverage in the same move.

**The replay cache is the only router state an attacker can grow.** It is the
one cell the router column writes to, and tags are free to generate. NDN's
Interest Flooding wearing different clothes, landing on the single piece of
state a router cannot do without.

**Holder storage is unbounded and nothing in the model touches it.** Every
other resource in all three tables carries a bound in a type or a constant.
What a holder keeps, and for how long, has neither.

### The two constants everything prices against

| constant | what it dials |
|---|---|
| `H`, the max hop count | anonymity set, standing header overhead, DoS amplification, and now per-medium feasibility |
| the session length | the linkable set against the asymmetric setup rate |
