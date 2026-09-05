# Reach: the connectivity model

**Opened 2026-09-05** from a design session with the author. The connectivity
half of `.planning/OWN-WEB-GAP.md`, worked in depth. It settles shape and
settles no build order. Nothing here is minted and no code is touched.

The question this answers: **how one instance gets a value from another, with
IP's model kept out of the design and admitted only as a named exception.**

Author rulings, 2026-09-05.

| ruling | consequence |
|---|---|
| the web layer is designed first | the layers under it are shaped by what a document, an address and a reader turn out to be |
| IP is mostly ignored, and enters as a primitive that breaks the model on purpose | §5 |
| compute belongs at message creation and at reading | the amount sent does not drive the public-key cost. §11 |
| a hop learns nothing about what it carries | §7, §9, §10 |
| the security model does not vary with reachability | §4 |
| `/workspace/jala` and `/workspace/jala-setu` are idea sources | their language, crate structure, daemon shapes and policy plumbing stop at the door |

The inspiration is the author's own design notes and
`docs/decisions/decision-inspiration-policy.md` has no tier for that case, so
the ruling above stands alone. The policy does reach the reference class:
Reticulum is external prior art at **Tier P**, its protocol description read
and its Python reference unread, with its license unverified from this sandbox.

---

## §1 · The model

| | |
|---|---|
| a value has a mark | §3. That is the entire naming system, and it names no machine, place or service |
| a medium carries parcels | bounded, opaque, to whoever is on it, with no addressing anything above it reads |
| reaching is asking | `ask M` goes out, `give M bytes` comes back, and the bytes are checked against `M` |
| a party is a separate mechanism | layered above, and only a mutable answer needs one |

Three verbs and one invariant. A fetch of an immutable value carries no
handshake, no session, no identity and no cipher, because the address is the
proof.

**Forwarding.** A hop forwards what its own layer tells it to forward, and
never reads an ask to decide whether it could serve it. §8 holds the reason and
the mechanism that makes the alternative unnecessary.

## §2 · The chain

| step | the web's mechanism | what we do | why |
|---|---|---|---|
| name a thing | URL, fusing scheme, host and path over a registered namespace | the mark | an address that is derived needs no issuer, so there is nothing to register, renew, revoke or seize |
| find who has it | DNS, a hierarchy of authorities with its own protocol and cache | a holdings summary says who has it, and the ask goes to them | the answer is self-verifying, so the finder needs no authority and a lie costs one retry |
| reach them | IP routing to a location, source address on every packet | §7. A way list folds into a hop list and no hop is a location | a query has no destination, so route drops out of the model instead of being replaced |
| move bytes | TCP, ordering and reliability and congestion control | a medium carries one bounded opaque parcel to whoever is on it | two operations, put out and hear, which a shm region, an Ethernet segment, a serial line and radio all satisfy |
| trust the bytes | TLS plus a CA root store you did not choose | hash what came back against the mark you asked with | integrity belongs to the address, so nothing on the path is trusted with anything |
| trust the party | TLS, the same root store | required only when a party is asked for something mutable | fetching a value holds no authentication step at all |

**The interference lives in the verb.** `connect` imports location, and a
source address, a destination address, a port number, a connection and a route
arrive with it. `ask` imports none of them. A point-to-point pipe is
connection-shaped, so building on one re-imports the model quietly.

## §3 · The mark

"Hash the content" specifies nothing. A mark is a typed record and every field
is read by something before the bytes arrive.

| field | what it is | who reads it, and when |
|---|---|---|
| `alg` | which digest, a closed sum | the verifier. Carrying it lets the digest change without invalidating every mark ever written |
| `digest` | the bytes of the hash | the verifier, after the parcel lands |
| `size` | the total size of the value | the **receiver, before accepting anything**. It demands a bound instead of discovering one |
| `chunk` | `whole`, or `chunked n` | the **asker's own** router, before asking. It lets one value be asked for in pieces |

| shape | what the digest commits to | what verifying one parcel proves |
|---|---|---|
| `whole` | the bytes | everything, once |
| `chunked n` | the root of a hash tree over the parcels | that parcel belongs to this value, alone, with no other parcel present |

The chunked case makes a fetch resumable, splittable across peers and
verifiable one parcel at a time. `size` and `chunk` are separate fields so the
parcel count is derivable from both and nothing carries a count that can
disagree with them.

**What a mark does not carry.** No location, no party, no time, no name, no
transport, no path. A mark carrying any of those would let a router prefer one
holder for a reason the address cannot justify.

⚑ **These four fields are what an asker holds. What crosses the wire is
separate**, because a hop reading `size` and `chunk` is §9's level four
disclosure. §10 holds the envelope that decides it.

**The one cryptographic dependency.** A mark needs a collision-resistant
digest. E112's `block-id` is FNV-1a-64, correct for what it does and far too
narrow for an address, so **`mark-of` is new work and `block-id` is a precedent
for the shape**. That is the whole addressing model's only cryptographic
dependency. §14 holds what the tree has.

## §4 · Reachability: open and gated

**One security model, constant.** Everything is encrypted, routing is secured,
both ends are protected, anonymity is available. None of that varies.

**One axis, two positions**, differing only in whether routability exists by
default.

| position | signature | everything downstream |
|---|---|---|
| open | `route : (-> Mark Table (List Hop))` | identical |
| gated | `route : (-> Mark Grant Table (List Hop))` | identical |

An unauthorized party meets no refusal. It holds no function that yields hops,
so it has nowhere to send an ask. **The gate sits at route formation and
nowhere else**, which is why the security model is described once.

**Anonymity survives the gate**, because a `Grant` proves permission and never
proves identity. A bearer capability or a membership proof answers "you may"
without answering "who".

**Two reasons to be private, priced differently.**

| what is wanted | mechanism | cost |
|---|---|---|
| the content must be unreadable | seal the value. It rides the **open** infrastructure as opaque bytes and only grant holders read it | nearly free. The same path as any public value |
| the existence and reachability must be hidden | gate the route, and §6's introduction and splice | two half-routes plus a live splice |

Most things that feel private want the first. Unreadable and unreachable are
separate purchases and the rest of this file prices the second.

**The precedent is one system.** Tor v3 onion services with and without client
authorization are these two positions: same crypto, same both-ends-hidden
property, same anonymity, differing in whether the descriptor is encrypted to
credential holders.

## §5 · Media, and the one thing IP costs

A medium has two operations and no more: put a parcel out, and hear parcels.

| fits natively | forces a medium-layer address |
|---|---|
| a shm region several processes read, **an Ethernet broadcast domain**, a serial line, radio | IP |

**An Ethernet segment is a bus.** A broadcast domain has exactly those two
operations, so the native model runs over a LAN with no tether at all. Native
covers more than shm and radio: a building, a site, a radio mesh,
and anything bridged into one segment. A tether is needed only to cross between
segments.

### The tether

A **`Tether`** joins two instances through something foreign, IP being the
case it exists for.

| property | how it holds |
|---|---|
| **no IP router is ever a fabric hop** | a tether is one edge between two adjacent hops. The IP infrastructure underneath carries bytes between them and never appears in a route |
| foreign addressing stops at it | nothing above has a representation for a dotted quad. `lib/protocol/inet.chiral` is already the pure translator and already sits outside `ports/` |
| it can be counted | every tether site is greppable, the discipline `lib/capability/secret.chiral` uses for reveal sites under E40 |

A route may cross many tethers. The earlier wording, that a tether ends the
route, forbade broad IP deployment and said more than was meant.

### What IP costs, exactly

**The difference between native and IP is the presence of a medium-layer
address.** On a bus there is no addressing anywhere in the stack, so a
broadcast has no source field to omit. IP always has one. Everything else in
this design matches on both sides.

| property | native bus | over a tether |
|---|---|---|
| content, which value, destination from hops | hidden | hidden |
| timing and volume | cadence | cadence, working identically |
| source | absent from the wire entirely | absent from the fabric wire, and IP carries one underneath |
| link adjacency | hidden by the shared medium | **exposed to the IP infrastructure** |
| membership | hidden if the medium is closed | **exposed** |
| attribution to a person or organisation | none. A radio has no registrar | **the address was issued to someone** |

The last three rows are the whole gap and none is fixable by cryptography.

**What the cadence converts the leak into.** With constant-rate fixed-size
tethers an observer sees traffic that never varies with what anyone is doing.
So IP's correlation becomes a **topology disclosure** instead of a **flow
disclosure**: the link graph and membership leak, and no flow on the graph
does. That is a much smaller loss than the bare statement suggests.

**The purity ladder is continuous.**

| deployment | media | what holds |
|---|---|---|
| local | shm, one Ethernet segment, serial, radio | the model exactly, with bus anonymity free |
| mixed | buses joined by tethers | the full model, bus-hidden where there is a bus and route-hidden where there is a tether |
| broad | mostly tethers | the full model, with every link's anonymity coming from routing instead of the medium |


## §6 · Routes: ceremonial, ephemeral, and the splice

**One channel authenticates and a different channel carries.**

| layer | route kind | who uses it | state, and where |
|---|---|---|---|
| introduction | **ceremonial**, published, long-lived | everyone, and that is the point | per route at each hop, bounded by topology |
| rendezvous | one node acting as a **splice** | one connection | per live splice, at that node only |
| session | two **ephemeral** half-routes joined at the splice | one connection | per live connection, at the endpoints |

§4's open position is the ceremonial layer. The route is shared, so the
anonymity set is everyone using it, and heavy use improves the property rather
than degrading it.

### The ceremony

A ceremonial route is established once and reused. The reference class is the
**mix cascade** against free-route mixnets: a cascade gives a larger anonymity
set and a simpler analysis, a free route gives resilience and scale, and
Loopix's stratified topology is the modern middle.

| problem, and where it is stated | how the ceremony answers it |
|---|---|
| §11's corner table: per-packet unlinkability costs statelessness | state becomes per route, bounded by topology instead of by traffic |
| §7's corridor trap: direction leaks the destination | one path for everyone, so direction carries nothing about anyone |
| `R10`: the sender must hold topology | it holds a route handle, and everyone holds the same ones |

**A shared route is stronger than per-session state, and cheaper.** Per-session
state lets a hop count sessions and count packets within one. On a shared route
it sees one undifferentiated stream and cannot separate senders at all.

The routing-layer key is shared by everyone on the route and the payload stays
sealed end to end, so a co-sender learns that a packet went to the next hop,
which that hop already knew.

### The splice

A gated endpoint never appears on a ceremonial route. The published layer
carries an introduction and the session runs elsewhere.

| step | what happens |
|---|---|
| 1 | the asker builds its own ephemeral half-route to a node **it** picks, and hands that node a one-time secret. That node is the splice |
| 2 | the asker sends an introduction over the ceremonial route, sealed to the endpoint under its grant, naming the splice and the secret |
| 3 | the endpoint builds **its own** ephemeral half-route to the splice |
| 4 | the splice joins the two halves and forwards opaque parcels between them |

| party | what it learns |
|---|---|
| a ceremonial hop | that an introduction passed. Not for whom |
| the introduction point | that someone introduced. It learns neither the splice's role nor the session |
| **the splice** | two half-routes exist and it joins them. It holds neither key and decrypts nothing |
| either endpoint | its own half. Never the other's path |

Tor's own documentation calls the rendezvous point a **dumb splice**, and the
property it names is the one this file reaches for: both ends hold a shared key
that neither the introduction point nor the splice ever possessed.

**A third instance of one idiom.** A splice holds a value with two link fields
and no key field, a hop holds a value with no destination field, and a router
holds a value with no payload field. Decrypting, routing and reading are
unavailable in the same structural sense, three times.

### Key entry

A short secret a person can carry, spoken or written, bootstraps both a pairing
and a route ceremony.

**A short human-transferable secret cannot be the key, and it can authenticate
the exchange that produces the key.** Six spoken digits is around twenty bits,
nowhere near a key and ample to authenticate a full-strength exchange, because
the construction gives an attacker one online guess instead of an offline
dictionary attack.

| construction | what it is |
|---|---|
| SPAKE2 | the standard balanced PAKE. `magic-wormhole` uses it with codes shaped like `7-crossover-clockwork` |
| a short authentication string | ZRTP style. Both sides read a short string aloud and compare, authenticating an exchange already completed |
| a short secret authenticating a PQ KEM | the conservative hybrid. PQ PAKEs exist and are less mature |

A route ceremony is a pairing whose output is a shared routing key instead of a
link secret, so one primitive serves both.

## §7 · Routing, and the dumb hop

**There is no router role.** Forwarding is a function any peer runs, and it has
two operations: open its own layer, and send what is left on the link that
layer named.

| type | is | shape |
|---|---|---|
| `Hop` | one place to try | the local hold, a bus, a named peer, a tether |
| `Way` | one strategy, a closed sum | `w-held`, `w-bus b`, `w-peer p`, `w-tether t`, `w-near` |
| `Table` | what this instance knows | buses it is on, tethers it holds, peers it has heard, marks it holds, routes it has joined |
| `route` | the fold | `(-> Mark Table (List Way) (List Hop))` |

| property | what holds |
|---|---|
| totality | `route` cases over the `Way` sum, so a new way is one arm and the compiler names every site that has to grow |
| order | decidable from the value. The way list is the order, the shape `fold-sgr` (`grid.chiral:232`) already has for style |
| refusal is a value | a way that cannot serve returns an empty hop list, so the fold continues |
| the table is data | a `.manifest` is declared data checked by the loader, and the tree ships two already |

⚑ `route` reading a mark's fields is stated for the **asker's own** router. A
hop reading them is §9's level four disclosure.

**What the modularity buys, as edits.**

| to add | the change |
|---|---|
| a new medium | one `Way` arm, one `.port` |
| a tether to another instance | one row in the table manifest, and no code |
| a local cache | one `Way` arm, placed ahead of the others |
| a different reach policy per deployment | reorder the way list |
| a structured overlay later | one `Way` arm, `w-near`, and nothing above it moves |

`w-near` is the only way needing a metric over digest space and a maintained
peer table, and leaving it unbuilt keeps a structured overlay out of the floor.

**Chunking composes with routing.** A `chunked n` mark splits into one ask per
parcel and each routes on its own, so one fetch can draw from a bus, a cache
and a tether at once, with each parcel verifying against the tree root alone.

### The four things that would make a hop smart

| smartness | how it is removed |
|---|---|
| choosing where to send | it does not choose. Its layer names the link |
| knowing the destination | no destination field exists in the value it holds |
| knowing its position | the header is fixed length and padded, so it cannot count |
| knowing whether it is last | its layer reads "next link L" or "this is yours", and a hop seeing the first cannot tell whether L leads to another hop or to the recipient |

A `Surb` removes the fifth. A recipient replies on a return route the sender
built, so no hop remembers who sent what and the recipient never learns whom
it answers.

**Where dumb has a floor.** Replay. A hop with no memory cannot detect a resent
parcel, and replay traces a path by resending and watching. A bounded replay
cache with expiry is the one piece of state a hop genuinely needs.

### Non-monotonic paths

A sender may route through a point it has already passed. No hop can tell,
since none knows the destination or its own position, so it costs no mechanism.

**The budget is already spent.** The header is padded to the maximum hop count
so a hop cannot infer position, and that padding is paid on every message. Every
hop slot below the maximum is bought and currently wasted, so spending it on a
detour costs zero header bytes and only latency.

⚑ **The corridor trap.** A detour that stays between the origin and the current
position keeps the packet inside the corridor it already traversed, and an
adversary holding several nodes there sees it repeatedly. Research on DHT
anonymity found redundancy in routing *introducing* leaks that weakened both
AP3 and Salsa, so added path structure fails to be automatically additive.
Ceremonial routes make the question moot by removing the metric to be greedy in.


## §8 · Discovery

### Three things wear the name

| | the question | the mechanism |
|---|---|---|
| peer | who am I linked to | out of band pairing. The first hop is a human act |
| existence | what is there to want | an index is a document. No new mechanism |
| content | who holds mark `M` | a holdings summary |

**Existence discovery needs no mechanism.** A document carries the marks of
other documents, so following a link is a fetch, and an index is a document
listing marks, so searching is a fetch of somebody's index. The one new thing
is a mutable pointer, "the current index of party `P`", which is §13's fourth
verb and carries a signature.

### The holdings summary

| | |
|---|---|
| what a peer publishes | a summary of the marks it holds. A Bloom filter is the reference shape, roughly 10 bits per mark at a 1% false positive rate, so ten thousand marks is about twelve kilobytes |
| what a false positive costs | one wasted ask, which is why the filter can be deliberately small |
| how it is exchanged | **the summary is a document with its own mark**, so fetching one uses the three verbs |
| what it buys | with a summary per paired peer, a real ask goes to one peer instead of searching. `route` reads them out of `Table`, and §1's gossip problem never arises |

A summary answers who holds what. For a gated mark that question is askable
only by a grant holder, so **a summary of gated holdings is itself gated
content**, the recursion closes with no new mechanism, and an open summary
never carries a gated mark.

### Why this is the cover stream

| property | why it holds |
|---|---|
| unlimited supply | a summary can always be re-fetched, at higher resolution, or for a peer's peers |
| satisfiable by construction | it exists and it resolves |
| real work | every synced summary makes some future real ask route in one hop |
| identical shape | a summary fetch **is** a fetch |

**More cover makes real routing cheaper.** Ordinary cover traffic is a tax.
This is a prefetch that happens to be indistinguishable from the thing it
hides, which is why cover has to be discovery specifically.

**The satisfiability floor.** A cover ask has to be answerable, because a
holder that serves some asks and never others separates real from cover by
which ones hit. Summary sync meets it without trying, and it kills the obvious
cheap answer of asking for noise.

**Re-fetching a whole summary beats fetching a delta**, because the waste is
the cover. A delta scheme would need a mutable pointer per summary and would
shrink the cover supply at once.

### Two adversaries, and cover answers one

| adversary | what it sees | what cover does |
|---|---|---|
| a hop or an on-path observer | that a slot was used | **solved.** Under per-link encryption and §9's cadence every slot is opaque and identical |
| the peer being asked | exactly which mark was asked | **nothing.** A peer knows a summary fetch when it serves one |

Against the second a decoy has to be a plausible real ask, which means asking
for unwanted values, which leaks the neighbourhood of the wanted ones. **Bloom
false positives are free decoys** there: genuine asks for values the peer does
not hold, indistinguishable from real ones to that peer, and the error rate is
already being paid for another reason.

**The disclosure this introduces.** Publishing a summary tells any fetcher what
a peer holds, running opposite to every other disclosure in §9, and it is the
price of one-hop routing.

## §9 · The observer ladder, and the three defences

| level | what leaks | the defence |
|---|---|---|
| 1 | traffic exists | cover, and §8 supplies it |
| 2 | size, timing, rate | a cadence, below |
| 3 | who talks to whom | sourceless parcels, destinationless hops, §7 |
| 4 | which value is wanted | **open research.** Below |
| 5 | the value itself | encryption, and §10 decides who opens what |

**What the ruling costs.** A hop learning nothing across a link requires
per-link state, which requires a link, which puts a party at the floor of the
model. §11's corner table prices the three ways out. `R1` records the fork and
the ruling reaches it.

### Cadence

The timing defence is a constant rate, so timing carries no information because
the payload does not touch it.

| property | what holds |
|---|---|
| timing leak | zero by construction, and statable and gateable |
| latency | bounded and deterministic, at most one slot |
| bandwidth | the slot rate, always, idle or busy |
| speed | purchasable. **Consistency and speed are one knob here** |

| slot | with a 2048 B packet |
|---|---|
| 100 ms | 20 KB/s per link, always |
| 10 ms | 200 KB/s per link, always |

A schedule is a value and emission is a total function of the schedule and the
queue, so "this link leaks no timing" is checkable. Standing bandwidth scales
with degree, and §8's cover fills the idle slots.

### Bitwise unlinkability

| mechanism | what it kills |
|---|---|
| the ephemeral key is blinded at each hop | successive nodes cannot correlate by key value |
| wide-block payload encryption | every payload bit changes, and any modification invalidates the whole payload |
| a fixed payload size | varying size would leak position and allow size correlation |
| padding and filler at constant header length | length carries nothing |

Sphinx provides all four as a proven property and HORNET provides none of
them, for the reason §11's corner table gives.

**All three defences or none of them matter.** Perfect bitwise unlinkability
with a 5 ms forwarding delay and no cover is correlatable with a stopwatch,
which is why HORNET cannot beat an adversary at both ends despite being
cryptographically sound.

### Which value is wanted

This is private information retrieval. Its constructions cost far more than
this model spends anywhere else, nothing deployed does it well, and the author
has marked it research. Content addressing hands the level out by construction,
because the mark **is** the identifier and anyone who has seen the content
recognises the ask.

§8's two-adversary table is where the mitigations live, and every one of them
bounds this level without closing it.

## §10 · The envelope

One parcel, several audiences, each reading its own slice, with who may open
what carried in the type.

| audience | what it may read |
|---|---|
| the hop | its next link, and the length |
| the holder | which value is wanted |
| the asker | the value |

A hop is handed a value that has no field containing the payload, so opening it
is unavailable instead of forbidden. Same construction as §7's hop view and
§6's splice.


## §11 · The primitives

**The axis.** Compute belongs at message creation and at reading, and **no
public-key operation sits on the forwarding path.**

| position | how often | what may sit here |
|---|---|---|
| per pairing | once per relationship, ever | public key work. The PQ KEM, the PAKE |
| per ceremony | once per route, until rotation | public key work |
| per message creation | once per message | symmetric derivation, one per layer |
| per hop | once per hop per message | one symmetric open |
| per parcel | every parcel | one AEAD open |

| primitive | needed by | position | approximate size | state |
|---|---|---|---|---|
| collision-resistant hash | marks, the chunk tree, the KDF base | per parcel | 32 B out | **absent.** `native-protocol/N1`'s open slice |
| KEM, PQ and classical hybrid | link and route establishment | per pairing, per ceremony | ~1.1 KB ciphertext, ~1.2 KB public key | absent |
| AEAD | payload, each envelope slice, each layer | per parcel | 16 B tag, 12 B nonce | **built.** `lib/crypto/chacha.chiral`, `lib/crypto/poly1305.chiral` |
| KDF | per-layer and per-parcel keys from a link secret | per creation and per hop | 32 B out | absent, riding whichever hash is chosen |
| PAKE | pairing and ceremony from a short human-carried secret | per pairing, per ceremony | ~2 round trips | absent |
| signature, PQ | the mutable pointer layer only | per claim | ~3.3 KB signature | absent, and **it never touches the fetch path** |
| entropy | keys, nonces, cover selection | per use | one crossing | absent. `native-protocol/N2`, unstarted |
| constant-time judgment | all seven above | a compile-time property | none | `native-protocol/N5`, unstarted |

Eight, and the tree holds one and a half.

**Sizes, from memory.** Egress is blocked from this sandbox, so these carry the
VERIFY caveat `docs/decisions/decision-inspiration-policy.md` puts on its
license floor. ML-KEM-768 public key ~1184 B and ciphertext ~1088 B. ML-DSA-65
public key ~1952 B and signature ~3309 B. FALCON-512 signature ~666 B with a
float dependency. SLH-DSA public key 32 B with a signature in the tens of
kilobytes. X25519 public key 32 B. ChaCha20-Poly1305 tag 16 B.

### The onion header problem

Sphinx-style constant-size headers work by re-blinding one group element at
each hop, 32 bytes whatever the path length. ML-KEM has no equivalent
re-randomisation, so that construction does not carry over. **Post-quantum
constant-size onion routing was open, and two constructions now exist.**

| work | what it does |
|---|---|
| **Outfox**, 2024 | replaces key exchange with KEMs, removes one of Sphinx's two key exchanges, compact per-hop header, PQ-capable. Optimised for **fixed-length layered routes** like Loopix, which is what makes dropping the second exchange safe. Keeps bitwise unlinkability and request-reply indistinguishability, and needs no pre-shared state |
| **KEM Sphinx**, 2023 | doubles processing speed, increases header size |
| **CSIDH/CTIDH Sphinx** | the one PQ primitive that preserves the actual re-blinding trick, because isogenies are a group action. Costs speed and carries a contested security-parameter story |

### The four corners

All three of stateless hop, symmetric per packet, and per-packet unlinkability
cannot hold together. The reason is exact: the sender would have to encrypt
under a key only the hop can derive, which is the definition of public-key
encryption.

| construction | stateless hop | symmetric per packet | per-packet unlinkable | state at a hop |
|---|---|---|---|---|
| Sphinx, Outfox | yes | no | yes | none |
| HORNET | yes | yes | no | none |
| per-session rotating tags | no | yes | yes | O(active sessions), unbounded by topology |
| **ceremonial routes** | no | yes | yes | **O(routes crossing it)** |

**Statelessness was HORNET's scale optimisation** for internet-scale forwarding
at over 93 Gb/s with no per-flow state. In a mesh it is plausibly the cheapest
of the three to give up, and §6's ceremony is what bounds the resulting state
by topology instead of by traffic.

## §12 · The load, by party, and the wire budget

Sizes below are derived from the field set unless a source is named. HORNET's
300+ byte header and Sphinx's 2048 byte fixed payload are the two measured
figures.

### The sender

| process | runs | crypto | state touched | on the wire |
|---|---|---|---|---|
| pair with a peer | once ever | 1 hybrid KEM encap, 1 KDF, or a PAKE | writes one link secret | ~2.3 KB once |
| join a ceremonial route | once per route | 1 asymmetric op | writes a route key | one ceremony |
| build the header | per message | n symmetric seals, padded to `H` | reads route or session keys | the budget below |
| build a SURB | per message wanting a reply | n symmetric | none | **doubles the header** |
| form an ask | per packet | n symmetric, plus n scalar mults in the unlinkable corner | none | one header |
| choose what fills a slot | per slot | none | reads summaries and the queue | nothing |
| emit | **every slot, busy or idle** | none | none | one packet per slot, standing |
| verify a parcel | per parcel | 1 hash, plus log(n) siblings under a chunk tree | none | the sibling path rides the give |

Every decision in the design sits in this column, which is what leaves the hop
with nothing to decide.

### The hop

| process | runs | crypto | state touched | on the wire |
|---|---|---|---|---|
| open its layer | per packet | 1 symmetric | reads its route or local key | nothing added |
| peel the payload | per packet | 1 symmetric | none | nothing added |
| re-pad the header | per packet | none | none | **constant length, which is the point** |
| check replay | per packet | 1 hash to key the cache | **reads and writes the replay cache** | nothing added |
| re-encrypt on the return leg | per reply packet | 1 symmetric | none | nothing added |

Holds: one long-term local secret, one key per neighbour, one entry per route
crossing it, a bounded replay cache.

**The features are the absent rows**, enumerated in §7. The one cell this
column writes is the replay cache.

### The receiver

| process | runs | crypto | state touched | on the wire |
|---|---|---|---|---|
| answer an ask | per ask | none beyond the forwarding it also pays | 1 lookup, 1 read | one give |
| build a summary | per republish | one hash per held mark | reads the whole holding set | nothing |
| store a value | per value kept | none | **writes, and nothing bounds it** | nothing |
| sign a pointer | per publication | 1 signature | reads its key | ~3.3 KB |
| open its own slice | per packet | 1 symmetric | none | nothing added |
| reply through a SURB | per reply | n symmetric on a route it did not build | none | one packet. **It never learns whom it answers** |

### The wire budget

| field | size | who reads it | can it shrink |
|---|---|---|---|
| per-hop link id | 1 to 2 B | that hop | already minimal |
| per-hop key material | 16 to 32 B | that hop | **16 B if the hop expands a seed instead of carrying a key** |
| per-hop MAC | 16 B | that hop | 8 B truncated, at a stated cost in forgery resistance |
| the above, times `H` | ×`H` | | the triple-duty constant below |
| the blinding element | 32 B classical | every hop | **~1.1 KB under PQ. This is the wall** |
| the payload | a fixed size | the recipient | size classes, at a stated leak |
| a mark's digest | 32 B | the holder | 24 B buys 96-bit security instead of 128 |

| profile | `H` | payload | header | total | fits |
|---|---|---|---|---|---|
| pool, LAN segment | 8 | 2048 B | ~304 B | ~2.4 KB | trivially, and it reproduces HORNET's measured header |
| tether | 8 | 1024 B | ~304 B | ~1.3 KB | yes |
| **radio, 500 B MTU** | **3** | **256 B** | **~134 B** | **~390 B** | yes, and only at those numbers |
| ceremonial, rotating tag | 8 | 2048 B | ~384 B, **no blinding element** | ~2.4 KB | yes, and radio at `H` of 3 fits too |

**The radio row binds.** A 500 byte MTU cannot carry the LAN profile at any hop
count, so `H` is a per-medium parameter instead of a protocol constant.

**The PQ wall, priced.** Swapping the 32 B classical blinding element for a
~1.1 KB PQ ciphertext takes the LAN header from ~304 B to ~1360 B and takes
radio out of one frame. The ceremonial row avoids it entirely, because the
per-packet key comes from a route key plus a nonce and no element is carried.

| lever | saves | costs |
|---|---|---|
| a hop expands a seed instead of carrying a key | ~128 B at `H` of 8 | one KDF per hop per packet |
| truncate the per-hop MAC to 8 B | ~64 B at `H` of 8 | forgery resistance, stated |
| lower `H` | linear in the header | the anonymity set |
| payload size classes | most of the padding on small messages | log2 of the class count, in bits, per packet |
| share one header across a value's packets | the header, once instead of per parcel | **per-packet unlinkability. The same trade as HORNET against Sphinx** |
| a 24 B digest | 8 B per mark | 96-bit security instead of 128 |

### Four asymmetries

**Asking is expensive and serving is cheap.** The sender pays path selection,
setup, layering and verification; a holder pays one lookup and one read. That
is what lets the open position stay open without becoming a target.

**`H` does three jobs on one number**: the padding that hides position, the
standing overhead on every message, and the DoS amplification factor, since one
attacker packet costs `H` hops a decrypt and a send. Raising it buys anonymity
and attacker leverage together.

**The replay cache is the only hop state an attacker can grow.** Tags are free
to generate. NDN's Interest Flooding wearing different clothes, landing on the
one piece of state a hop cannot drop.

**Holder storage is unbounded and nothing in the model touches it.**

### The constants everything prices against

| constant | what it dials |
|---|---|
| `H`, the max hop count | anonymity set, standing overhead, DoS amplification, per-medium feasibility |
| the session length | the linkable set against the asymmetric setup rate |
| the route lifetime | the same trade, at the ceremonial layer |
| the slot interval | latency against standing bandwidth |

## §13 · Three walkthroughs

### Reaching a public site, first time

The asker holds a `Seal`, the party's address, from a link in another document
or typed in.

| step | what happens | what the network learns |
|---|---|---|
| 1 | ask, on the ceremonial route, for that party's current signed pointer | that someone asked. Not who |
| 2 | any holder answers with `{seal, index mark, sequence, expiry, signature}` | nothing it did not already hold |
| 3 | verify the signature against the seal | nothing |
| 4 | ask for the index by mark, verify the hash | nothing |
| 5 | ask for the content marks the index names | nothing |

**No session, no splice, no handshake, ever.** A signed pointer is itself a
value, so anyone can cache and serve it and the signature makes an untrusted
holder as good as the party. **A public site is a sequence of values one of
which is signed, and a thing to fetch instead of a thing to connect to.**

### Reaching it again

| situation | cost |
|---|---|
| the pointer is inside its expiry | **zero network** |
| expired, sequence unchanged | one ask, one signature check |
| sequence changed | the new index, then only the marks that differ |

**Cache invalidation is free**, because unchanged content has unchanged marks.
A partial update fetches exactly what changed, with no protocol support for it.

### Reaching a gated endpoint

§6 holds the mechanism and who learns what at each step. What this walkthrough
adds is the precondition and the price.

| | |
|---|---|
| precondition | the asker holds a `Grant`, from out of band or a PAKE ceremony. Without it §6's introduction is unformable, so the endpoint is unreachable and its existence unlearnable |
| against the public case | two half-routes at `H` each, one introduction, one handshake, one live splice |
| end to end | at `H` of 3 that is six hops, which is where Tor lands |
| inside the session | marks still verify, so integrity never depends on the session |

### What the walkthroughs expose

**A fourth verb.** §1 has three verbs and all are keyed by a mark. Step 1 above
asks **by seal**, for the latest signed pointer of a party. Everything mutable
needs it and the model does not have it.

**Freshness.** A pointer's signature proves authenticity and cannot prove that
no newer pointer exists. Expiry bounds it, asking several peers bounds it
better, neither closes it. The standard rollback problem, unaddressed here.

## §14 · What is in the tree

Measured 2026-09-05 against `lib/lowering/tal/crossing-wraps.chiral:39-53`.

| piece | state |
|---|---|
| a bounded region with its size in the type | **built.** `pool-create`, `pool-write`, `pool-read`, `pool-close`, all lowered. E120, E122 |
| a content hash at node granularity | **built and shipped**, and too narrow for a mark. `apc.chiral:48`, FNV-1a-64, recomputed and verified by the decoder. E112 |
| a collision-resistant digest | **absent.** `lib/crypto/` holds ChaCha20 and Poly1305. `native-protocol/N1`'s open slice |
| declared data checked by the loader | **built.** Two `.manifest` instances ship |
| a length bound riding a type | **built.** `pool.port:3-5` puts a size in the port type, `sock.port:69` takes a `(refine I64 (> 0))` |
| a bus among processes with a common ancestor | reachable today. A pool's backing memfd returns as a linear `Fd` |
| a bus among independently started processes | **blocked.** `sock-send-fd` has no crossing-wraps row, `sock-listen` and `sock-accept` have no TAL body, and there is no `bind` extern |
| the profile machinery a reader would freeze its ports with | **live in the compiler.** `kernel.chiral:60`, `compile-front.chiral:293-301`, `totality-check.chiral:130-139`, and zero `.profile` instances |
| `Mark`, `Parcel`, `Bus`, `Way`, `route`, the verbs | nothing |

## §15 · Open forks

| id | the fork | state |
|---|---|---|
| R1 | a shared medium with no party, or a party at the floor | §9's ruling reaches it: a hop learning nothing needs per-link state, which needs a link |
| R2 | forwarding unprivileged, or a peer opts in to relaying | narrowed by §1: a peer that reads an ask has read it, so §8's summary replaces gossip |
| R3 | the digest and its width | `native-protocol/N1` picks. Whether reach may state a requirement is the fork |
| R4 | the parcel size, and whether one instance holds two | `pool.port` makes two sizes two types. A tether and a bus with different bounds forces it |
| R5 | whether `have` exists | ask and give are the floor. `have` saves everyone answering and adds a round trip |
| R6 | `Bus` as the word | against `wire`, `pool`, `grid`, `span` |
| R7 | the cover mix | §8. Where on the usefulness-against-leak spectrum, and whether it is constant or policy |
| R8 | the cadence's home | §9. Per link, per medium or per deployment, and what the queue does when it exceeds the slot rate |
| R9 | `H`, and the anonymity set it defines | §12. It is also the standing overhead and the DoS amplification |
| R10 | who selects a path | §6's ceremony reduces it to holding a route handle everyone holds |
| R11 | the onion header construction | §11's four corners, four options now |
| R12 | how many envelope slices | §10. Each costs a key derivation |
| R13 | whether the type-level opening claim survives lowering | §10. The one fork about this compiler instead of the protocol |
| R14 | whether a holdings summary is open or per-grant | §8. Publishing tells any fetcher what a peer holds |
| R15 | whether a summary claims what a peer holds or what it can reach | §8. The second composes across hops, which is a structured overlay through the side door |
| R16 | gossip against blindness | §1 states the resolution and the author has not ruled |
| R17 | per-packet unlinkability against a shared header | §11's corner table |
| R18 | whether `H` is per medium | §12's radio row says it has to be |
| R19 | what bounds holder storage | §12. The one unbounded resource in the model |
| R20 | ceremonial against free routes | §6. The oldest settled-into-a-tradeoff question in the field |
| R21 | route lifetime | §6. A third constant beside `H` and the session length |
| R22 | whether the authenticate-here carry-there split is enforced by type | §6 |
| R23 | the fourth verb, ask-by-seal, and how a pointer's freshness is bounded | §13. Everything mutable needs it |
| R24 | whether unreadable and unreachable are priced separately | §4. Most private things want only the first |

### Closed

- **Per-hop ephemeral IP addressing.** Dropped by the author 2026-09-05. It
  breaks long-term link stability and breaks the star pattern that exposes a
  node's degree and neighbour set, and it cannot touch attribution, because an
  address is issued and issuance is attribution. Against that it multiplies
  address consumption, moves NAT traversal per link, and leaves the supply
  itself as the identity. §5 states what remains: the cadence already converts
  the IP leak from a flow disclosure into a topology disclosure, and rotation
  chips at what is left for a cost the property does not repay.

## §16 · Notes to cover

**Discovery.** Who chooses what a cover ask asks for and out of what set;
whether answering a cover ask is useful work; what a peer does with a value
fetched as cover; whether an idle instance is distinguishable from a busy one;
how often a peer republishes and what the stale window costs; a peer publishing
a summary claiming everything to attract asks; how a peer's peers' summaries
are named; bootstrapping an instance with zero peers.

**Cadence.** Queue overflow, which is where the timing leak returns;
backpressure without signalling load; negotiated against unilateral; a value
spanning many slots leaking its size through the span length; whether an
instance that stops emitting is distinguishable from one that left; which clock
this needs and whether `lib/ports/clock.port` supplies it.

**Routes and hops.** How a ceremonial route is published, and whether the
publication is a document with a mark; who may propose a route and what stops a
hostile one being adopted; the rotation schedule; how a splice is chosen and
whether choosing badly is detectable; what a splice does when one half goes
away; whether a node may refuse to be a splice and what a refusal reveals; the
introduction point's load, being the one public role whose request rate ties to
one endpoint; whether an endpoint runs several introduction points and what the
count leaks; whether a reply retraces a path; whether every parcel of a chunked
mark takes one path.

**The envelope and the keys.** Nonce management across slices and under a
long-lived key; replay of a sealed slice to a different hop; whether the
envelope shape is fixed or per medium; what a hop does with a slice it cannot
open, and whether malformed and not-for-me are distinguishable; key rotation
and re-pairing, and what a rotated key does to values in flight; forward
secrecy on a link; how a PAKE's single online guess is rate limited, given that
the limiter is the endpoint an attacker is trying to reach.

**The values.** What bounds holder storage and for how long; garbage
collection; the flat parcel list against a Merkle chunk tree, where the tree
wins as soon as a value is large or partially fetched; a size-class scheme for
payloads; the error and refusal vocabulary, since a refusal with no name is the
silent arm `render.chiral:167` already demonstrates.

## §17 · Relation to the roster

`.planning/OWN-WEB-GAP.md` lanes X, L and J were drawn before this file existed.
**They are now one pointer section there and this file is the authority for all
three**, so nothing is stated twice. Lane X's `Mark` and `Seal` split survives
in §3 and §4, lane L's identity, packet and link rows sit behind `R1`, and lane
J is §5.

That roster keeps the document half: the vocabulary, the canvas and the lens
pipeline, which is where a value comes from and where it goes after §1's three
verbs have moved it.

## §18 · Sources

- Reticulum, Tier P: protocol description read, Python reference unread
- HORNET: <https://arxiv.org/abs/1507.05724>
- TARANET: <https://arxiv.org/pdf/1802.08415>
- PHI, and the LAP and Dovetail header leaks: <https://petsymposium.org/popets/2017/popets-2017-0007.php>
- Dovetail: <https://www.petsymposium.org/2014/papers/Sankey.pdf>
- Loopix: <https://arxiv.org/pdf/1703.00536>
- Sphinx packet format: <https://nym.com/docs/network/cryptography/sphinx>
- Outfox: <https://arxiv.org/html/2412.19937v2>
- Post Quantum Sphinx: <https://eprint.iacr.org/2023/1960>
- Tor onion services: <https://community.torproject.org/onion-services/overview/>
- DHT anonymity failure modes: <https://www.freehaven.net/anonbib/cache/wpes09-dht-attack.pdf>
- NDN stateful forwarding and Interest Flooding: <https://arxiv.org/pdf/1902.09033>
- QUIC connection ID rotation: <https://quicwg.org/load-balancers/draft-ietf-quic-load-balancers.html>
