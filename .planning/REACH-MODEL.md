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
   possible before holding any of it.
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

## §8 · Open forks

| id | the fork | why it decides something |
|---|---|---|
| R1 | `ask` and `give` over a shared medium, or a party in the loop from the start | the second turns a query into a conversation, which puts identity and a handshake under the floor and moves the whole crypto arc ahead of the model |
| R2 | forwarding unprivileged, or a peer opts in to relaying | unprivileged is stated in §1 and it makes a peer's cost unbounded by anyone else's asks |
| R3 | the digest, and its width | it is `native-protocol/N1`'s slice and this roster consumes whatever that arc picks. Whether reach may state a requirement on it is the fork |
| R4 | the parcel size, and whether one instance may hold two | `pool.port` puts the size in the type, so two sizes are two types. A tether and a bus with different bounds is the case that forces this |
| R5 | whether `have` exists | ask and give are the floor. `have` saves everyone answering at once and adds a round trip. It is a real cost either way |
| R6 | `Bus` as the word | against the tree's register of `wire`, `pool`, `grid` and `span` |

## §9 · Relation to the roster

`.planning/OWN-WEB-GAP.md` lanes X, L and J are drawn against the earlier
sketch and this file supersedes their content. Lane X's `Mark` and `Seal` split
survives. Lane L's identity, packet and link rows fall behind R1, because a
model with no party in the floor needs none of them to fetch a value. Lane J
collapses into §5, since a native medium is a `.port` and the tether is the
one named exception.

Rewriting those three lanes against this file is owed. It stays undone here.
