# Crypto, identity and routing recovery: the design worked out in session

A mining run over past Claude Code transcripts, 2026-09-22. It recovers the
**key exchange**, **post-quantum bundle** and **onion-routing-between-physicals**
design the author states was fleshed out in past sessions, and it says for each
piece whether a tracked file carries it today.

`.planning/SHREDNET-RECOVERY.md` ran the day before over the term `shrednet` and
recovered the author's own turns on the identity model as `I1` to `I9`. This run
started from the design vocabulary instead, scanned every chirality transcript,
and adds the half that run did not take: **the constructions themselves**, most
of which were written out by a session and then corrected, accepted or built on
by the author. `.planning/SHREDNET-RECOVERY.md:548` onward carries seven of the
author turns quoted here; the session designs beside them are new, and the
author turn at `6ecf719d…`:785 is new.

This run decides nothing. It reconciles no reading, proposes no goal, no arc and
no roster row, compares no published scheme on its own account, and applies no
ruling to an open author call. Every quote is verbatim, including the author's
spelling.

## How to read a row

| label | means |
|---|---|
| `AUTHOR` | the user typed it. A `message.role` of `user` carrying a text block |
| `SESSION` | a past assistant turn wrote it. Evidence of what that session proposed, and no evidence of what the author decided |

A `SESSION` row carries the author's response beside it wherever one exists. A
transcript address is `<project slug>/<session uuid>`, a line number in that
`.jsonl`, and the entry's own timestamp in UTC.

**One session holds almost all of it.**
`-workspace-chirality/6ecf719d-2349-4be1-a4e4-9913547c5d46`, 2026-09-05 18:52 to
23:33 UTC, 1,464 lines, is the design conversation. It opens on the visual layer
and turns to connectivity at `:160`. Its output is `.planning/REACH-MODEL.md`,
committed across `01aa3dd`, `d51af4c`, `7c338d6`, `85dc669` and `6398035`, which
is why so much of what follows resolves to a line in that file rather than to
`NOWHERE`.

---

## §1 · Multiple ways for key exchange

### K1 · The author rules that a router may learn nothing, and the session answers with a per-link budget

| | |
|---|---|
| whose words | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 476, 2026-09-05T19:40:55.024Z |
| tree | `.planning/REACH-MODEL.md:422-484` §9, the observer ladder |

> ME ASKING A QUESTION IS NOT QUE TO DECIDE A BUNCH OF SHIT YOURSELF. How can we
> pq crypto everything while retaining the model with features we want is not
> straightforward. We want a speedy system. We also want a secure system. We need
> to wrap up a lot of information in a way that can only be dissected where it
> should be. A router shouldn't be able to gather a bunch of actual info about
> whatever its carrying

The session's answer at `:479`, 19:42:25.592Z, is where the per-link position of
the key exchange first appears.

| | |
|---|---|
| whose words | `SESSION` |
| where | `-workspace-chirality/6ecf719d…`, line 479, 2026-09-05T19:42:25.592Z |
| tree | the sizes at `.planning/REACH-MODEL.md:528-533`; the per-link ruling at `:505-513` |

> ## The PQ budget
>
> Approximate sizes, which are what make this concrete:
>
> | primitive | size |
> |---|---|
> | ML-KEM-768 public key / ciphertext | ~1.2 KB / ~1.1 KB |
> | ML-DSA-65 public key / signature | ~2 KB / ~3.3 KB |
> | X25519 public key | 32 B |
> | ChaCha20-Poly1305 tag | 16 B |
>
> Two consequences fall straight out.
>
> **PQ can never touch the per-parcel path.** A single ML-KEM ciphertext does not
> fit in one parcel on a 500-byte radio MTU. PQ is a per-link setup cost of
> roughly two kilobytes, amortised over everything the link carries afterward,
> with symmetric crypto in steady state. ChaCha20 and Poly1305 are already in
> `lib/crypto/` and are the fast path.
>
> **There are no signatures on the fetch path at all.** Content addressed by hash
> needs no signature, because the hash is the integrity proof. A PQ signature is
> needed only when a party makes a claim, which is the mutable naming layer. That
> removes the single most expensive PQ primitive from the common case entirely.

### K2 · The author names the compute axis, and the session reads back three ways to place the exchange

| | |
|---|---|
| whose words | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 489, 2026-09-05T19:47:59.104Z |
| tree | `.planning/REACH-MODEL.md:504-505` states the axis |

> 6 encryption is medium cheap but the discussion is important because we need to
> make sure we have docced all crypto primitive requirements + a pq bundle is
> large so we need to do something to put the compute load on the message
> creation and reading instead of amount of send

The session at `:492`, 19:49:57.973Z, turns that into the first enumeration of
exchange placements.

| | |
|---|---|
| whose words | `SESSION` |
| where | `-workspace-chirality/6ecf719d…`, line 492, 2026-09-05T19:49:57.973Z |
| tree | the three-row table is **`NOWHERE`**. `.planning/REACH-MODEL.md:537-548` holds the successor discussion, with Outfox and KEM Sphinx and no hybrid row |

> **Sphinx-style constant-size onion headers work by re-blinding one group
> element at each hop.** With X25519 that is 32 bytes total regardless of path
> length. ML-KEM has no equivalent re-randomisation, so the classical trick does
> not carry over. Post-quantum constant-size onion routing is an open research
> area, and this is the specific place where "PQ everything" stops being
> straightforward.
>
> The options, with what each costs per message:
>
> | option | header cost | what it gives up |
> |---|---|---|
> | one KEM ciphertext per hop | ~1.1 KB per hop, so ~3.3 KB at three hops | fits nothing with a small MTU |
> | hybrid: classical re-blinding for the route, PQ for the payload | ~32 B route header | content stays PQ-safe. A future quantum adversary who recorded traffic could de-anonymise the **route** later |
> | **symmetric layered headers over PQ-established link keys** | tens of bytes per layer, and zero public-key operations on the forwarding path | the sender must already hold a key with every hop, which means routing only through peers it has paired with |
>
> That third row is the one I want you to look at, because it does exactly what
> you asked for. PQ runs **once per link, ever**, at pairing. After that, message
> creation is symmetric key derivation per layer, forwarding is one symmetric
> decrypt, and reading is one symmetric decrypt. The public-key cost is amortised
> over the lifetime of a relationship rather than paid per send.
>
> **The thing that looks like a restriction is what makes it affordable.**
> Pair-gating, which is there for access control, is also what puts a shared key
> on every hop, which is what lets the expensive privacy property be bought with
> symmetric primitives.

The seven-primitive requirement list in that same turn is the ancestor of
`.planning/REACH-MODEL.md:515-524`, which now carries eight rows with the PAKE
added.

> | primitive | needed for | state in tree |
> |---|---|---|
> | collision-resistant hash | marks, the chunk hash tree | **absent.** `native-protocol/N1`'s open slice |
> | KEM, PQ and classical hybrid | link establishment at pairing | absent |
> | AEAD | payload, and each onion layer | **ChaCha20 and Poly1305 built**, `lib/crypto/` |
> | KDF | per-layer and per-parcel keys from a link secret | absent, and it rides whatever the hash turns out to be |
> | signature, PQ | the mutable naming layer only | absent, and **it never touches the fetch path**, since a hash is the integrity proof |
> | entropy | keys, nonces, cover selection | absent. `native-protocol/N2`, not started |
> | constant-time judgment | every one of the above | `native-protocol/N5`, not started |

The author accepted the write-up two turns later at `:502`, 19:50:52.168Z:
*"Expand docs with these and notes to cover before i start suggesting stuff"*,
and immediately corrected its size at `:508`, 19:52:57.882Z: *"wdym writing all
three that is six items that are open design ideas to complete"*.

### K3 · The author asks for auth implied before the exchange, and the session answers with Noise patterns and four gate mechanisms

| | |
|---|---|
| whose words | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 583, 2026-09-05T20:07:19.860Z |
| tree | `.planning/REACH-MODEL.md:98-134` §4 carries the outcome after the author's correction at `K4` |

> wait maybe discovery is wrong. What models do we need to look at for answering
> the ease of integration question? something that might change this: we're
> trying to imply level of auth beforehand. We want to be able to have a very
> easily accessible public site form that can provide security for boths ends,
> plus a secure model underneath where routing is secured, while just being
> reachable. We also need more guarded forms where you cannot just route to it
> without some form of authorization that is built into the model. The project is
> probably outlining for us to do chirality native crypto and heavily intertwine
> it with this as the networking model

The session's reply at `:586`, 20:08:50.190Z, is the **only enumeration of key
exchange patterns anywhere in the corpus**, and no tracked file carries it.

| | |
|---|---|
| whose words | `SESSION` |
| where | `-workspace-chirality/6ecf719d…`, line 586, 2026-09-05T20:08:50.190Z |
| tree | **`NOWHERE`**. `docs/arcs/native-protocol-arc.md:63` names *"Noise reference class"* for `N4` and no file names a pattern |

> ## "Imply level of auth beforehand" already has a formal vocabulary
>
> **Noise handshake patterns.** The pattern name literally encodes what each side
> knows about the other before the handshake starts, which is your sentence
> restated.
>
> | pattern | initiator knows | responder knows | what it is |
> |---|---|---|---|
> | `NK` | responder's static key | nothing about initiator | **the public site.** Anyone connects, the site is authenticated, the visitor is not |
> | `KK` | responder's static key | initiator's static key | **the gated form.** Neither side can start without already holding the other's key |
> | `XX` | nothing | nothing | mutual auth negotiated in band, the open case |
>
> `N`, `K` and `X` are exactly "no key, key known beforehand, key transmitted
> during". This is the model to reach for, it is formally analyzed, and PQNoise
> extends it, which is where the PQ question lands.
>
> ## Four ways to make a thing unroutable, with what each costs
>
> | mechanism | how it works | cost |
> |---|---|---|
> | **bearer mark** | the mark is unguessable, so knowing it is the authorization | free, needs no protocol. Unrevokable, and delegating means telling |
> | **key-gated handshake** | `KK`. You cannot complete the exchange without holding their static key | revokable by re-keying, needs per-party state |
> | **encrypted descriptor** | how to reach it is itself encrypted to authorized parties. Tor v3 client auth does this | the unauthorized cannot even learn it exists, which is the strongest form |
> | **attenuable token** | present a capability with caveats, verified offline | delegation with attenuation, revocation by expiry |

The same turn carries an eight-row reading list, and one row of it survives into
the tree.

> | model | what to take | why this one |
> |---|---|---|
> | **Noise patterns** | the N/K/X vocabulary for pre-shared knowledge | it is your requirement, already formalized |
> | **Tor v3 onion, client auth** | encrypted descriptors, so the unauthorized cannot find the introduction point | the working example of unroutable-without-authorization |
> | **Tahoe-LAFS caps** | write-cap to read-cap to verify-cap derivation, address and key in one value | content addressing and capabilities already fused, with a tier ladder built in |
> | **object-capability literature** | attenuation, no ambient authority | already Tier P in `decision-inspiration-policy` for E40, so the reading policy is settled |
> | **macaroons and biscuits** | attenuable tokens with caveats, verified offline | delegation with no central authority |
> | **Reticulum destination types** | single, group, plain as a typed destination | the tier as a constructor, which is the shape this tree would use |
> | **CGA, HIP, self-certifying names** | proving you own the address is proving you own the key | why a derived address needs no PKI |
> | **Signal sealed sender and private groups** | proving membership without revealing identity | the gated tier's "prove you may without saying who" |

`.planning/REACH-MODEL.md:129-133` carries the Tor v3 row. A grep of
`.planning/`, `docs/` and `records/` for `Tahoe`, `macaroon`, `biscuit`,
`sealed sender`, `PQNoise`, `client auth`, `bearer mark` and
`encrypted descriptor` returns zero.

### K4 · The author collapses the two tiers, and the exchange becomes one function signature

| | |
|---|---|
| whose words | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 596, 2026-09-05T20:11:22.988Z |
| tree | `.planning/REACH-MODEL.md:100-116` §4 |

> so i know you dont understand because public is not a separate thing from
> sealed. This is what i mean. I said we're trying to retain the secure model for
> public. The bit is anonymity being possible for both, one side has naturally
> easy routing that provides security for both ends, and one side has a
> requirement of actually forming the ability to route before anything else.

| | |
|---|---|
| whose words | `SESSION` |
| where | `-workspace-chirality/6ecf719d…`, line 599, 2026-09-05T20:12:14.031Z |
| tree | held, `.planning/REACH-MODEL.md:106-116`, near-verbatim |

> ## What "forming the ability to route" is
>
> The gate sits at route formation and nowhere else.
>
> - open: `route : (-> Mark Table (List Hop))`
> - gated: `route : (-> Mark Grant Table (List Hop))`
>
> An unauthorized party is not refused. It has no function that yields hops, so
> there is nowhere to send an ask. Everything after that point is the same code,
> the same envelope, the same cadence, the same anonymity. The security model
> gets described once because it genuinely is one thing.
>
> ## Why anonymity survives both
>
> The grant proves **permission, not identity**. A bearer capability or a
> membership proof answers "you may" without answering "who". So gating does not
> cost anonymity, which is what makes the two positions differ in reachability
> alone.

The author's acceptance is at `:603`, 20:13:57.508Z: *"Cool spiel update design
idea."*

### K5 · The author asks for a key a person carries and types in, and the session answers with PAKE

| | |
|---|---|
| whose words | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 826, 2026-09-05T20:55:17.991Z |
| tree | `.planning/REACH-MODEL.md:256-276` §6, key entry |

> does it have to cost stateless or can we just build an orientation ceremony
> type of thing? as in, build an easy way for routers to use a ceremonial path in
> addition to the normal ones so you can just... use a secure route already
> established (also we can do like a key entering process where if someone knows
> the number verbally or from another source they can just have it and enter on
> the other end to already be able to derive)

| | |
|---|---|
| whose words | `SESSION` |
| where | `-workspace-chirality/6ecf719d…`, line 829, 2026-09-05T20:56:26.781Z |
| tree | held, `.planning/REACH-MODEL.md:258-276`. The `jala` sentence is **`NOWHERE`** |

> ## The key-entry half
>
> The primitive you are describing is **PAKE**, password-authenticated key
> exchange. The important distinction:
>
> **A short human-transferable secret cannot be the key. It can authenticate the
> exchange that produces the key.**
>
> Six digits spoken aloud is around 20 bits. That is nowhere near a key, and it
> is plenty to authenticate a full-strength exchange, because a PAKE is designed
> so an attacker gets one online guess rather than an offline dictionary attack.
>
> | construction | what it is |
> |---|---|
> | SPAKE2 | the standard balanced PAKE. What magic-wormhole uses, with codes like `7-crossover-clockwork` |
> | SAS, short authentication string | ZRTP style. Both sides read a short string aloud and compare, authenticating a key exchange already done |
> | short secret authenticating a PQ KEM | the practical hybrid. PQ PAKEs exist and are less mature, so letting the short secret authenticate an ML-KEM exchange is the conservative route |
>
> jala's own pairing design is already this: a rotating code plus a passphrase,
> out of band, used as the handshake's salt.
>
> ## The two compose, and that is the nice part
>
> **The ceremony is authenticated by a human-transferable code.** Route
> establishment and peer pairing become one mechanism with one primitive under
> it, differing only in what gets established at the end. A route ceremony is a
> pairing whose output is a shared routing key rather than a link secret.

The last sentence is tracked at `.planning/REACH-MODEL.md:275-276`. The `jala`
sentence naming *"a rotating code plus a passphrase, out of band, used as the
handshake's salt"* appears in no tracked file: a grep of the tree for
`rotating code` and for `salt` in this sense returns nothing.

### K6 · The author asks for an exchange that transfers onto a fresh ephemeral route, and the session answers with the splice

| | |
|---|---|
| whose words | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 839, 2026-09-05T21:02:15.736Z |
| tree | `.planning/REACH-MODEL.md:236-252` §6, the splice |

> 1. this is what the public perspective i brought up was a thing 2. I mean that
> exchange transfers to a different emphemeral route on the network. Like, if
> many people use the public setup which would be the point, why not make the
> infra able to handle {new identiy -> private endpoint} by having {new identity
> connected to the web -> ephemeral route over public nodes that keeps up
> encryption goals -> private endpoint} (so you have {key} sent to differently
> fully complete ephemeral line to {priv endpoint}

| | |
|---|---|
| whose words | `SESSION` |
| where | `-workspace-chirality/6ecf719d…`, line 873, 2026-09-05T21:05:32.615Z |
| tree | held, `.planning/REACH-MODEL.md:238-254` |

> ## The splice
>
> Your second point is Tor's rendezvous and the details confirm. The asker builds
> its own ephemeral half-route to a node **it** picked and hands it a one-time
> secret; the introduction goes over the ceremonial route sealed to the endpoint,
> naming that node; the endpoint builds **its own** half-route there. Tor's docs
> call it a dumb splice: it forwards opaque cells between two circuits it cannot
> decrypt, and both ends hold a shared key that neither the introduction point
> nor the splice ever possessed.
>
> That is a **third instance of §11's idiom**: a value with two link fields and
> no key field. Hop view, envelope, splice. One construction, three places.

### K7 · The jala identity bundle, read into the session as the existing key material shape

| | |
|---|---|
| whose words | `SESSION`, reporting a file it read at `/workspace/jala` |
| where | `-workspace-chirality/6ecf719d…`, line 230, 2026-09-05T19:01:41.802Z |
| tree | **`NOWHERE`**. `.planning/OWN-WEB-GAP.md:63-66` measures *"zero for an identity bundle, zero for a destination"* |

> | layer | jala's shape |
> |---|---|
> | Identity | long-term bundle: PQ-KEM pk + PQ-sig pk + classical ECC pk + metadata. Private material never in process memory (bija holds it) |
> | Address | **BLAKE3 of the bundle, 32 bytes, is the global address.** Plus a 4-8 byte session alias that rotates |
> | Destination | typed: single, group, plain, link. **Pair-gated: strangers route but cannot address.** Model B is default, bundles are never flooded |
> | Packet | **no src field on wire**, ever. Dest routing hash, TTL, version byte, per-interface negotiated MTU, cover-traffic padding hook |
> | Link | PQ-hybrid handshake then per-packet ratchet, MUX streams |
> | Interface | a trait: send, recv, mtu, is_up, id, identity_hint, stats |

The author's response at `:242`, 19:03:37.705Z, is the ruling on what this
material is for:

> again. its an inspo and idea thing. We arent going to use rust and a lot of the
> things outlined (like theme stuff) is irrelevant here. we need to pull thoughts
> and translate to chirality best form (because chirality literally allows the
> best for every best choice for something like this)

**This row is also the answer to subject 2's framing.** The author's 2026-09-23
recollection of *"pq encrypting and then like hashing the bundle to a smaller
thing"* matches this table exactly: a bundle of post-quantum public keys, at
roughly 1.2 KB plus 2 KB plus 32 B, hashed by BLAKE3 to a 32-byte global address,
with a 4 to 8 byte rotating session alias below it. Nothing in the chirality tree
carries the bundle, the hash-to-address, or the alias.

### Where the key exchange stands in the tree

`.planning/REACH-MODEL.md:507-513` §11 fixes the positions:

> | position | how often | what may sit here |
> |---|---|---|
> | per pairing | once per relationship, ever | public key work. The PQ KEM, the PAKE |
> | per ceremony | once per route, until rotation | public key work |
> | per message creation | once per message | symmetric derivation, one per layer |
> | per hop | once per hop per message | one symmetric open |
> | per parcel | every parcel | one AEAD open |

**Six ways were outlined across this session and the tree holds four of them.**
The hybrid PQ-and-classical KEM at pairing, the PAKE over a spoken secret, the
short authentication string, and the ceremony whose output is a routing key are
at `.planning/REACH-MODEL.md:518`, `:521` and `:268-276`. The Noise `NK`/`KK`/`XX`
pattern vocabulary and the jala identity bundle with its BLAKE3 address are in no
tracked file.

---

## §2 · PQ encrypting, then hashing the bundle down to something smaller

### P1 · The author states the size lever

This turn is the run's central find. `.planning/SHREDNET-RECOVERY.md` does not
carry it.

| | |
|---|---|
| whose words | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 785, 2026-09-05T20:48:19.758Z |
| tree | the mechanism is **`NOWHERE`**. One consequence of it sits at `.planning/REACH-MODEL.md:633` and `:640-641` |

> well no we want the pq, whats the reason we cant add another operation to
> shrink what we have to send and put the load on deriving the bundle from
> compact form before using bundle? like a mutual piece both sides have that take
> a smaller thing to get the way to see the real thing, and then if you do that
> you still need to unencrypt

It is the reply to the session's `:781`, 20:45:14.226Z, which had priced the wall
and closed the question:

> **The PQ wall as a number:** swapping the 32 B classical blinding element for a
> ~1.1 KB PQ ciphertext takes the LAN header from ~304 B to ~1360 B, and takes
> radio out of a single frame entirely.

### P2 · The construction, written out

| | |
|---|---|
| whose words | `SESSION` |
| where | `-workspace-chirality/6ecf719d…`, line 819, 2026-09-05T20:50:58.471Z |
| tree | partially. `.planning/REACH-MODEL.md:640-641` states the conclusion in one sentence and the construction, the obstruction, the three ways out and the sizes are **`NOWHERE`** |

> Your idea works, and it is corner three of a trichotomy I stated too absolutely.
> Here it is precisely.
>
> ## The construction you are describing
>
> Sender and hop share a secret `K` from setup. Per packet:
>
> 1. sender picks a fresh nonce `N`, derives `k = KDF(K, N)`, seals the hop's
>    record under `k`
> 2. hop derives `k = KDF(K, N)` and opens it
>
> Wire cost: `N` at 8 to 16 bytes, instead of a 1.1 KB PQ ciphertext. Every
> packet's record is fresh bits, so it is bitwise unlinkable. Symmetric only. The
> load is in the derivation, exactly as you said.
>
> ## The obstruction, stated exactly
>
> **The hop has to know which `K` to use.** Three ways out and they cost
> different things:
>
> | way out | cost |
> |---|---|
> | trial-decrypt over active sessions | O(sessions) per packet |
> | carry a session tag in the clear | that tag is the linkable thing you just removed |
> | **pre-issue rotating tags, hop keeps a lookahead table** | O(1) lookup, and **per-session state at the hop** |
>
> The third is yours, and **QUIC ships it at internet scale**.
> `NEW_CONNECTION_ID` frames pre-issue identifiers, the peer rotates through
> them, the receiver keeps a table, and the stated purpose is preventing
> linkability across path changes.
>
> ## The trichotomy
>
> Pick two.
>
> | | stateless hop | symmetric per packet | per-packet unlinkable |
> |---|---|---|---|
> | Sphinx, Outfox | yes | **no** | yes |
> | HORNET | yes | yes | **no** |
> | **your proposal** | **no** | yes | yes |
>
> The reason all three cannot hold: the sender would have to encrypt under a key
> only the hop can derive, and that is the definition of public-key encryption.
> So one of them always goes.
>
> **Statelessness was HORNET's scale optimisation** for internet-scale forwarding
> at 93 Gb/s. We are building a mesh. It is plausibly the cheapest of the three to
> give up.
>
> ## What it costs, in the §17 budget
>
> | | per-hop record | header at `H`=8 | radio at `H`=3 |
> |---|---|---|---|
> | classical blinding | 34 B | ~304 B | ~134 B, fits |
> | **PQ blinding element** | 34 B + ~1.1 KB shared | **~1360 B** | does not fit a 500 B frame |
> | **rotating tag, your version** | tag 16 + sealed 16 + MAC 16 = 48 B | **~384 B, no blinding element at all** | ~132 B, **fits** |
>
> So the header stays HORNET-sized while gaining per-packet unlinkability and full
> PQ. Hop state at a 64-tag lookahead, 16 B tags, 1000 active sessions is about
> 1 MB, which is nothing.
>
> **PQ is paid once at session setup**, where the sender establishes a secret with
> every hop on the path. That is exactly your ruling: compute at creation and
> reading, small on the wire.

The same turn withdraws the session's earlier claim that the construction was
unpublished:

> ## One correction to what I told you
>
> PQ Sphinx is no longer fully open research. Two constructions exist:
>
> | work | what it does |
> |---|---|
> | **Outfox** (2024) | replaces key exchange with KEMs, removes one of Sphinx's two key exchanges, compact per-hop header, PQ-capable. Optimised for **fixed-length layered routes** like Loopix, which is what makes dropping the second exchange safe. Keeps bitwise unlinkability and request-reply indistinguishability, and needs **no pre-shared state** |
> | **KEM Sphinx** (2023) | doubles processing speed, increases header size |
>
> And the one PQ primitive that preserves Sphinx's actual re-blinding trick is
> **CSIDH/CTIDH**, because isogenies are a group action and support the same
> blinding. That is the "obvious variant" in the same paper. Its problems are
> speed and a contested security-parameter story.

`.planning/REACH-MODEL.md:537-548` carries the Outfox, KEM Sphinx and CSIDH rows.
`:550-565` carries the four corners with the rotating-tag row as
*"per-session rotating tags | no | yes | yes | O(active sessions), unbounded by
topology"* at `:559`. `:633` carries the wire row as *"ceremonial, rotating tag |
8 | 2048 B | ~384 B, **no blinding element** | ~2.4 KB"*. `:640-641` compresses
the construction to *"the per-packet key comes from a route key plus a nonce and
no element is carried"*.

**What no tracked file carries:** the two-step derivation, the `k = KDF(K, N)`
form, the 8-to-16-byte nonce against the 1.1 KB ciphertext, the obstruction that
the hop must know which `K`, the three ways out, the QUIC `NEW_CONNECTION_ID`
precedent as prose, the 48-byte field breakdown, and the 1 MB hop-state figure.
A grep of `.planning/`, `docs/` and `records/` for `pre-issue`, `lookahead
table`, `trial-decrypt`, `64-tag` and `KDF(K` returns zero, and the only QUIC
occurrence outside `.planning/sources/` is the bare URL at
`.planning/REACH-MODEL.md:852`.

### P3 · The author moves the state bound from traffic to topology

| | |
|---|---|
| whose words | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 823, 2026-09-05T20:54:13.931Z, restated at line 826, 20:55:17.991Z |
| tree | `.planning/REACH-MODEL.md:205-230` §6, the ceremony |

> does it have to cost stateless or can we just build an orientation ceremony
> type of thing? as in, build an easy way for routers to use a ceremonial path in
> addition to the normal ones so you can just... use a secure route already
> established

| | |
|---|---|
| whose words | `SESSION` |
| where | `-workspace-chirality/6ecf719d…`, line 829, 2026-09-05T20:56:26.781Z |
| tree | held, `.planning/REACH-MODEL.md:207-230` and `:555-560` |

> ## Per-route instead of per-session
>
> | | state at a hop | bounded by |
> |---|---|---|
> | per session | one entry per active session | traffic. Thousands |
> | **per route** | one entry per route crossing it | **topology. Tens** |
>
> If a route is shared infrastructure that many senders use, the hop's state stops
> scaling with traffic and starts scaling with the graph. That is the whole
> difference.
>
> The routing-layer key is shared by everyone on the route; the payload stays
> sealed end to end. So a co-sender on the route learns "a packet is going to next
> hop L", which the hop already knew, and learns nothing about any payload. The
> sharing is safe because the two layers are separate.
>
> **And it is strictly better for anonymity, not merely cheaper.** With
> per-session state a hop can count sessions and count packets per session. With a
> shared route it sees one undifferentiated stream and cannot separate senders at
> all.

The honest costs in the same turn are `NOWHERE` as a table:

> | cost | detail |
> |---|---|
> | a route is a fixed target | censorship and compromise both get a stable thing to aim at |
> | whole-route compromise | everyone on it loses routing-layer privacy at once. Payloads survive |
> | coordination | establishing and rotating a route is an event, not a local act |
> | failure handling | you cannot route around a break inside a fixed route. You switch routes, and which route you pick leaks a little |
> | key rotation | routes must re-ceremony on a schedule, and that schedule is a new constant |

`.planning/REACH-MODEL.md:675` carries *"the route lifetime"* as one of four
constants. The other four cost rows appear nowhere.

### P4 · Deriving a large object from a small seed, the same lever at the primitive layer

| | |
|---|---|
| whose words | `AUTHOR` |
| where | `-workspace-chirality/f2b186e5-128e-4800-8758-dccec015fb3d`, line 458, 2026-09-07T21:44:51.851Z |
| tree | `.planning/CRYPTO-TRANSLATION.md:477-504` §14 |

> can we optimize any more with the derive a large thing from a smaller thing and
> a process of derivation

| | |
|---|---|
| whose words | `SESSION` |
| where | `-workspace-chirality/f2b186e5…`, line 461, 2026-09-07T21:46:22.672Z |
| tree | held, `.planning/CRYPTO-TRANSLATION.md:483-502`. The seed-concentration half is **`NOWHERE`** |

> | object | materialized | derived from | ratio |
> |---|---|---|---|
> | ML-KEM public matrix `A` at k=4 | 16 polynomials, 256 coefficients, 12 bits each, **6,144 B** | the 32-byte seed `ρ`, expanded by SHAKE128 | **~190x** |
> | ML-KEM-1024 decapsulation key | 3,168 B expanded | a **64-byte** seed | **~50x** |
> | a hash-based scheme's `2^h` one-time keys | astronomically large | one seed and a PRF | unbounded |
> | the Merkle authentication path | the full tree | BDS traversal over a frontier | tunable |
> | Keccak round constants | 22 to 24 lanes of table | an 8-bit LFSR | the table disappears |
> | Keccak `ρ` offsets and the `π` permutation | 25 entries plus a mapping | `t(t+1)/2 mod w`, and `(x,y) → (y, 2x+3y)` | the tables disappear |
> | GF(256) log and antilog | 512 B | bit operations | the table disappears, **and the secret-indexed lookup with it** |
>
> ML-KEM's encapsulation key checks out exactly against this: 4 × 256 × 12/8 =
> 1,536 bytes of `t̂` plus 32 bytes of `ρ` is 1,568, which is the published figure.
> Without deriving `A`, that key would be 7.7 KB.

> **Seed concentration, and this one is structural.** The more you derive, the
> more a single seed is worth. A 64-byte value that regenerates every key a device
> holds is the most concentrated authority in the system, and derivation makes it
> more so. That lands directly on `decision-quorum-store`'s rule that nothing
> authoritative sits whole in one place, and on `native-protocol/N7` and `N8`.
> **Derivation and quorum-splitting are complements**: the smaller you make the
> root of authority, the more it wants splitting.

`.planning/CRYPTO-TRANSLATION.md:477-504` carries the dial and the inventory.
A grep of the tree for `seed concentration` returns zero.

### P5 · The author on Reticulum putting identity and routing inside the encrypted part

| | |
|---|---|
| whose words | `AUTHOR` |
| where | `-workspace-chirality/036d10bc-e770-4ee5-a34f-c44807e823a0`, line 2117, 2026-09-09T04:31:44.036Z |
| tree | **`NOWHERE`** as a routing statement. `.planning/SHREDNET-RECOVERY.md` carries it as `I8` |

> I meant like, making the things we are trying to put in the empty space over
> time a separate pass and store using types, and then apply the logic one would
> apply for something like how riticulum puts identity and routing in the contents
> of the encrypted piece, to the logic for filling up all bits

| | |
|---|---|
| whose words | `SESSION` |
| where | `-workspace-chirality/036d10bc…`, line 2125, 2026-09-09T04:33:00.221Z |
| tree | **`NOWHERE`** |

> The Reticulum move maps cleanly onto that second one. Reticulum's win is that
> identity and routing live **inside** the payload instead of in a cleartext
> header, so there's no metadata to leak and no header to pay for. The analog
> here: **the layout is known by the type at compile time, not by a tag at
> runtime.** No discriminator byte, no length field, no shape word — the container
> is just bits and the checker knows what's in them. That's the same structural
> trick, out-of-band metadata, applied to occupancy instead of addressing.

---

## §3 · Onion routing between physicals

### O1 · The author asks what a router is, and the session answers that there is none

| | |
|---|---|
| whose words | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 603, 2026-09-05T20:13:57.508Z |
| tree | `.planning/REACH-MODEL.md:278-352` §7 |

> Cool spiel update design idea. Next: what routing is and elements, so we can
> figure out how a router is genuinely just a dumb router

| | |
|---|---|
| whose words | `SESSION` |
| where | `-workspace-chirality/6ecf719d…`, line 620, 2026-09-05T20:16:13.745Z |
| tree | held, `.planning/REACH-MODEL.md:316-334`. The seven-element table is **`NOWHERE`** in this form |

> ## There is no router
>
> That is the strongest form of the thing you are asking for. No peer holds a
> router role. Forwarding is a function any peer runs, and it has two operations:
>
> 1. open my own layer with my link key
> 2. send what is left on the link it named
>
> Nothing else. No lookup, no table consulted, no decision.
>
> ## The elements
>
> | element | who computes it | what it costs |
> |---|---|---|
> | `Link` | local to each peer, an index into its own links | the sender must know each hop's local numbering |
> | `Path` | the sender | the sender needs topology |
> | `Layer` | the sender, one per hop | one key derivation per hop |
> | `Route` | the sender, padded to the max hop count | constant overhead on every message, one-hop messages included |
> | `Surb` | the sender, so a reply carries its own return route | roughly doubles the header |
> | forwarding | the hop | one symmetric open, one send |
> | replay guard | the hop | bounded memory |
>
> Every element that requires a decision is computed by the sender. The hop's
> column has two rows.
>
> ## The four things that would make a hop smart
>
> | smartness | how it is removed |
> |---|---|
> | choosing where to send | it does not choose. Its layer names the link |
> | knowing the destination | no destination field exists in the value it holds |
> | knowing its position | the header is fixed length and padded, so it cannot count |
> | knowing whether it is last | its layer reads "next link L" or "this is yours". A hop seeing "next link L" cannot tell whether L leads to another hop or to the recipient |
>
> `Surb` is what removes the fifth. A recipient replies using a return route the
> sender built, so no hop remembers who sent what and the recipient never learns
> who to reply to.
>
> ## Where dumb has a floor
>
> Replay. A hop with no memory cannot detect a resent parcel, and replay is how
> you trace a path: send it again and watch where it goes. So a bounded replay
> cache with expiry is mandatory, and it is the one piece of state a hop genuinely
> needs.

### O2 · The author rejects the sender-knows-everything shape, and the session researches it

| | |
|---|---|
| whose words | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 624, 2026-09-05T20:18:01.583Z |
| tree | **`NOWHERE`** as an author statement |

> well we do want to optimize a bit. You're describing something that cant exist i
> think. There is a limit to what we can keep on sender. I'm thinking most
> optimized form is bare minimum setup to split router load to be a series of
> knowing the next hop. But then again that is not secure. Can we look at other
> things that are reaching for this using web research rq?

| | |
|---|---|
| whose words | `SESSION` |
| where | `-workspace-chirality/6ecf719d…`, line 685, 2026-09-05T20:21:16.688Z |
| tree | **`NOWHERE`**. `.planning/REACH-MODEL.md:558` names HORNET in the corner table and no file carries the forwarding-segment mechanism |

> ## HORNET's forwarding segment
>
> The trick: a router's own state is encrypted **under that router's own
> long-term local key** and carried in the packet.
>
> | | |
> |---|---|
> | what an FS holds | the next hop, the shared session key, and the session expiry |
> | who can read it | only the node that minted it, using one long-term local secret |
> | where it lives | in the packet header, on every packet |
> | what the router stores | nothing. No per-flow state at all |
> | what the sender knows | an opaque blob per hop. No topology, no per-hop key, no link numbering |
>
> Setup runs once per session using a modified Sphinx that anonymously collects an
> FS from each node on the path, and the modification is specifically to keep those
> FSes secret and to reveal no topology to any node. After that, every packet
> carries the Anonymous Header holding the FSes, each node extracts its own,
> decrypts it with its local key, peels one layer, forwards. **Data forwarding is
> symmetric only**, and it runs at over 93 Gb/s.
>
> So "a series of knowing the next hop" is exactly right, and it is secure, because
> the next hop is sealed to that hop under a key the sender never holds.
>
> **This is your ruling restated as a published system**: asymmetric once at
> session setup, symmetric forever after, compute at creation and reading, nothing
> per send.

The landscape table in the same turn is `NOWHERE`:

> | system | forwarding state lives | asymmetric per | dumb router | the cost |
> |---|---|---|---|---|
> | Tor circuits | router, per circuit | circuit | no | state exhaustion, scaling |
> | **HORNET** | **the packet, sealed to each hop** | session | **yes, zero state** | 300+ byte headers, session expiry |
> | Sphinx / Loopix / Nym | the packet | **every packet, per hop** | yes | slow. Asymmetric on the data path |
> | LAP, Dovetail | the packet | minimal | yes | **header leaks path information** |
> | PHI | the packet | minimal | yes | fixes that leak, 30x larger anonymity sets, 120 Gbps |
> | NDN, PIT | router, per pending interest | none | no | Interest Flooding Attacks exploit the PIT |
> | TARANET | the packet | session | yes | HORNET's shape plus traffic-analysis resistance |

The session also withdrew the pair-gating restriction in that turn:

> - my claim that paths run only through paired peers was wrong, and §14's third
>   onion option should be restated: the sender does not need a pre-shared key with
>   every hop

### O3 · The author proposes backtracking between physical hops

| | |
|---|---|
| whose words | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 695, 2026-09-05T20:22:31.425Z |
| tree | **`NOWHERE`** as an author statement. `.planning/REACH-MODEL.md:335-352` carries the corridor trap |

> Question: topologically, could a router send a packet to another router closer
> to destination in terms of hops, and then do a thing where it hops back to a
> point in between initial state and current, and continues from there? for
> obsfuscation that can become inexpensive in a good network with a good logic
> behind it

| | |
|---|---|
| whose words | `SESSION` |
| where | `-workspace-chirality/6ecf719d…`, line 711, 2026-09-05T20:24:25.612Z |
| tree | partially. The corridor trap and the stratified alternative are at `.planning/REACH-MODEL.md:335-352`; the free-budget argument and the replay interaction are **`NOWHERE`** |

> ## Why it costs the routers nothing
>
> In a source-routed onion model the sender picks the entire sequence. A backtrack
> is just a path that revisits a region. No hop knows it is a backtrack, because no
> hop knows the destination or its own position. **It requires zero new mechanism
> and the router stays dumb.** It is purely a sender-side path-selection choice.
>
> ## The attack it actually defends against
>
> Real and named. Even with perfect onion encryption, a router that knows the graph
> learns the **direction** a packet moved. If paths are shortest-path or greedy over
> some metric, direction points at the destination, and a few observations narrow
> the destination set hard.
>
> The property you want, stated formally: **the distribution of next-hop,
> conditioned on the observed previous-hop, is independent of the destination.**
> Monotonic paths violate it. Non-monotonic paths approach it.
>
> ## The economics are better than "inexpensive"
>
> §11 already requires the header be padded to a fixed maximum hop count so a hop
> cannot infer its position. That padding is paid on **every** message, one-hop
> messages included.
>
> So every hop slot below the maximum is already bought and currently wasted.
> **Spending them on backtracking costs zero header bytes.** It costs only latency
> and link bandwidth. The budget already exists and is currently being thrown away.
>
> ## The trap
>
> **Corridor leak.** Backtracking to a point between the origin and the current
> position keeps the packet inside the corridor it already traversed. An adversary
> holding several nodes in that corridor now sees the packet more times, and
> repeated observation reconstructs the corridor, which points at both endpoints.
>
> ## One mechanical interaction to check
>
> Sphinx-family formats carry replay protection, where a mix remembers seen packet
> tags. A path that revisits a node makes that node see the packet twice. Each hop
> transforms the packet, so the second visit should present a different tag, but
> "the same packet arrives twice at one node" is precisely what replay detection
> exists to catch.

### O4 · The author requires per-hop packet identity to be unique

| | |
|---|---|
| whose words | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 718, 2026-09-05T20:32:03.025Z |
| tree | `.planning/REACH-MODEL.md:455-475` §9 |

> So we also need per hop packet identity to be unique right? there should be no
> way to see two correlatable packets at any point. is that possible? like in the
> packet from one hop to another sense.

| | |
|---|---|
| whose words | `SESSION` |
| where | `-workspace-chirality/6ecf719d…`, line 734, 2026-09-05T20:33:40.300Z |
| tree | held, `.planning/REACH-MODEL.md:459-475` and `:550-565`. The HORNET AHDR sentence is **`NOWHERE`** |

> ## The bitwise question: yes, needed, and it is solved
>
> Sphinx does exactly this, as a designed and proven property:
>
> | mechanism | what it kills |
> |---|---|
> | the ephemeral key is **blinded** at each hop | successive nodes cannot correlate by key value |
> | LIONESS wide-block encryption on the payload | every payload bit changes, and any modification invalidates the whole payload |
> | fixed 2048-byte payload | varying size would leak position and allow size correlation |
> | padding and filler keep the header constant length | length carries nothing |
>
> ## HORNET does not have it
>
> This is the correction. Confirmed from the paper's own description: for all data
> packets within a session, nodes use only symmetric cryptography to retrieve state
> and process the AHDR, and **the same AHDR is constant throughout a session, so
> nodes can link packets belonging to the same session together.**
>
> HORNET's claim is that a node does not learn source or destination. It is not a
> claim that packets are unlinkable. Every packet of a session is taggable at every
> hop on its path, and that is inherent to why it is fast.
>
> ## The three-way, and I think it is fundamental
>
> | | stateless router | symmetric only | per-packet unlinkable |
> |---|---|---|---|
> | HORNET | yes | yes | **no** |
> | Sphinx | yes | **no**, asymmetric blinding per hop per packet | yes |
> | symmetric ratchet | **no**, the hop holds ratchet state | yes | yes |
>
> The deeper reason: **blinding is inherently an asymmetric operation.**
> Re-randomizable encryption exists in group-based settings and does not exist
> symmetrically, which is why Sphinx uses a group element at all. The sender cannot
> re-randomize an FS it cannot decrypt.
>
> So per-packet bitwise unlinkability costs one asymmetric operation per hop per
> packet. That is the price and I do not think it is negotiable.

That price is what the author overturned four turns later at `:785`, and `P2`
above is the overturning.

### O5 · What a physical hop is

The author's *"literally between physicals"* resolves to two places in the
session. The first is the medium.

| | |
|---|---|
| whose words | `SESSION` |
| where | `-workspace-chirality/6ecf719d…`, line 896, 2026-09-05T21:19:25.160Z |
| tree | held, `.planning/REACH-MODEL.md:134-194` §5 |

> **The difference between native and IP is exactly the presence of a
> medium-layer address.**
>
> On a shm pool, a serial line or a radio there is no addressing anywhere in the
> stack. A broadcast has no source field to omit, because the concept does not
> exist at that layer. IP always has one. Everything else in the design matches on
> both sides.

> **An Ethernet segment is a bus.** A broadcast domain has exactly the two
> operations a medium needs: put a frame out, hear frames. So the native model runs
> over a LAN with link-layer broadcast and no tether at all, with the bus anonymity
> intact.
>
> That means native is not confined to shm and radio. Any single broadcast domain
> qualifies, which covers a building, a site, a mesh of cheap radios, and anything
> bridged into one segment. The tether is needed only to cross between segments.

The gap table in the same turn is `NOWHERE`:

> | property | native bus (shm, radio, serial) | over IP with a tether |
> |---|---|---|
> | content confidentiality | hidden | hidden |
> | which value was asked | hidden | hidden |
> | destination hidden from hops | hidden | hidden |
> | source | **absent from the wire entirely** | absent from the fabric wire, and **IP carries one underneath** |
> | timing and volume | cadence | cadence, and it works identically |
> | link adjacency | **hidden by the shared medium** | **exposed to the IP infrastructure** |
> | membership in the network | hidden if the medium is closed | **exposed** |
> | attribution to a person or org | none. A radio has no registrar | **the address was issued to someone** |
>
> The bottom three rows are the entire gap, and none of them is fixable by
> cryptography, because they are properties of using an addressed network you did
> not build.

> So constant cadence turns IP's correlation problem from a **flow disclosure**
> into a **topology disclosure**. You lose who is adjacent to whom. You keep
> everything else.

The author's response at `:906`, 21:22:45.485Z, closes one branch and accepts the
rest:

> ok we would drop ip change stuff because its pointless but this is great so far.
> Probably time to consolidate and condense docs and then work on refining exact
> specificiations

`.planning/REACH-MODEL.md:138-140` holds the bus list and `:148-160` holds the
tether. The per-link ephemeral address analysis and the eight-row gap table are in
no tracked file, recorded in the commit message of `6398035` as closed.

### O6 · The physical hop the author had asked about: ephemeral IP per hop

| | |
|---|---|
| whose words | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 893, 2026-09-05T21:18:14.399Z |
| tree | **`NOWHERE`**. Recorded as closed in the commit message of `6398035` and in no file |

> ok wait we plotted enough that we can have individual ephemeral instances of ip
> for every hop?  lets analyse gaps for with ip and without (like ip is still
> correlatable no matter what right? even if content stays hidden

| | |
|---|---|
| whose words | `SESSION` |
| where | `-workspace-chirality/6ecf719d…`, line 896, 2026-09-05T21:19:25.160Z |
| tree | **`NOWHERE`** |

> ## What per-hop ephemeral IP actually buys
>
> Two things, and the second is the real one:
>
> | buys | how |
> |---|---|
> | breaks long-term link stability | an adversary reading flow logs sees many short flows instead of one persistent one, so building the graph over time gets harder |
> | **breaks the star pattern** | if one instance uses one address for all its links, every link it has is correlated by that address, which exposes its degree and its whole neighbour set. Per-link addresses break that |
>
> ## What it cannot buy
>
> **An address is issued, and issuance is attribution.** You can rotate which
> address you use. You cannot rotate the fact that some entity was issued it. If
> your ephemeral pool comes from one cloud account, the account is the identity;
> from a residential ISP, the subscriber is.
>
> Costs to weigh: an address per link multiplies address consumption, NAT traversal
> happens per link, and the cadence must hold per link, so standing bandwidth scales
> with degree. At degree 10, 100 ms slots and 2 KB packets that is 200 KB/s
> standing, always.

### O7 · The mechanics, walked

| | |
|---|---|
| whose words | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 883, 2026-09-05T21:10:43.059Z |
| tree | **`NOWHERE`** as an author statement. `.planning/REACH-MODEL.md:678-730` §13 is its product |

> Ok wait lets pause and walk through the mechanics from a few perspectives. what
> does reaching a public endpoint look like first time and after that? what does
> reaching a private one look like? are we going to have room to keep the model
> perfect where we need it (full native) and break it a little bit to use IP as
> securely as we can for the long road that will be requiring IP for broad infra?
> (like mechanically how does it happen questions)

| | |
|---|---|
| whose words | `SESSION` |
| where | `-workspace-chirality/6ecf719d…`, line 886, 2026-09-05T21:12:15.632Z |
| tree | held, `.planning/REACH-MODEL.md:678-730` §13 |

> ## Reaching a private endpoint
>
> | step | what happens | what learns what |
> |---|---|---|
> | 0 | you hold a `Grant`, from out of band or a PAKE ceremony | without it you cannot form step 3, so you cannot route to it |
> | 1 | you build an ephemeral half-route to a splice **you** picked | the splice knows it was picked |
> | 2 | you hand the splice a one-time secret | the splice holds a secret and no keys |
> | 3 | you send an introduction over the ceremonial route, sealed under the grant, naming the splice and the secret | ceremonial hops see an introduction passed |
> | 4 | the endpoint builds **its own** half-route to the splice | the endpoint's hops learn only their own next link |
> | 5 | the splice joins the two halves | it forwards opaque parcels and decrypts nothing |
> | 6 | the session runs; marks still verify inside it | |

The same turn found the contradiction that reworded §5:

> | statement | verdict |
> |---|---|
> | a tether ends the fabric route | **too strong.** It forbids the deployment you are describing |
> | no IP router is ever a fabric hop | **correct, and it is what was meant** |
>
> A tether is an edge between two adjacent hops. The IP infrastructure underneath
> carries bytes between those two hops and never appears in the route at all. A
> fabric route can then cross many tethers, and IP is still not transit at the
> fabric layer, because IP routers are not hops.

`.planning/REACH-MODEL.md:155` and `:159-160` carry the surviving half. The purity ladder
in the same turn is `NOWHERE`:

> | deployment | media | what holds |
> |---|---|---|
> | local mesh | shm pools, serial, radio | the model exactly as designed, with bus anonymity for free |
> | mixed | buses joined by tethers | full model. Bus-hidden where there is a bus, route-hidden where there is a tether |
> | broad infra | mostly tethers | full model, and every link's anonymity comes from routing rather than from the medium |

---

## §4 · What the tree lost

Designs worked out in session that no tracked file carries. Highest value first.

| # | what | whose | where | why it matters |
|---|---|---|---|---|
| 1 | **the rotating-tag construction**: `k = KDF(K, N)` per packet, `N` at 8 to 16 B against a 1.1 KB PQ ciphertext, sealed hop record, symmetric only | `SESSION` accepted by the author's design direction at `:785` | `6ecf719d…`:819, 20:50:58.471Z | this is the answer to the author's *"shrink what we have to send"*. `.planning/REACH-MODEL.md:640-641` states its conclusion in one sentence and holds none of the steps |
| 2 | **the obstruction and its three ways out**: the hop must know which `K`; trial-decrypt at O(sessions), a clear session tag that reintroduces linkability, or pre-issued rotating tags with a hop-side lookahead table at O(1) | `SESSION` | `6ecf719d…`:819 | without it the tree's `ceremonial, rotating tag` row at `:633` rests on nothing stated |
| 3 | **the sizes**: per-hop record tag 16 + sealed 16 + MAC 16 = 48 B, header ~384 B at `H` of 8, ~132 B at radio `H` of 3, hop state ~1 MB at a 64-tag lookahead over 1000 sessions | `SESSION` | `6ecf719d…`:819 | the tree carries `~384 B` and no field breakdown, so the number cannot be rederived |
| 4 | **the QUIC precedent**: `NEW_CONNECTION_ID` pre-issues identifiers, the peer rotates, the receiver keeps a table, and the stated purpose is preventing linkability across path changes | `SESSION` | `6ecf719d…`:819 | `.planning/REACH-MODEL.md:852` carries the bare URL and no prose |
| 5 | **the author's own size-lever turn**, quoted at `P1` | `AUTHOR` | `6ecf719d…`:785, 20:48:19.758Z | no tracked file and no prior recovery file carries it |
| 6 | **the Noise `NK`/`KK`/`XX` vocabulary** for what each side knows before the exchange, and PQNoise as the post-quantum extension | `SESSION` | `6ecf719d…`:586, 20:08:50.190Z | `docs/arcs/native-protocol-arc.md:63` cites *"Noise reference class"* for `N4` with no pattern named |
| 7 | **the four unroutability mechanisms**: bearer mark, key-gated handshake, encrypted descriptor, attenuable token, each with its revocation and delegation cost | `SESSION` | `6ecf719d…`:586 | `.planning/REACH-MODEL.md:98-134` §4 keeps the outcome and drops the option space |
| 8 | **the eight-model reading list** for the gate and the exchange: Noise, Tor v3 client auth, Tahoe-LAFS caps, ocap literature, macaroons and biscuits, Reticulum destination types, CGA and HIP self-certifying names, Signal sealed sender | `SESSION` | `6ecf719d…`:586 | one row of eight survives, at `.planning/REACH-MODEL.md:129-133` |
| 9 | **the jala identity bundle**: PQ-KEM pk + PQ-sig pk + classical ECC pk + metadata, BLAKE3 of the bundle at 32 bytes as the global address, a 4 to 8 byte rotating session alias, and a PQ-hybrid handshake with a per-packet ratchet | `SESSION` reading a file, ruled *"inspo"* by the author at `:242` | `6ecf719d…`:230, 19:01:41.802Z | `.planning/OWN-WEB-GAP.md:63-66` measures *"zero for an identity bundle, zero for a destination"*. This is the closest thing in the corpus to the author's *"hashing the bundle to a smaller thing"* |
| 10 | **jala's pairing design**: a rotating code plus a passphrase, out of band, used as the handshake's salt | `SESSION` | `6ecf719d…`:829, 20:56:26.781Z | `.planning/REACH-MODEL.md:268-274` carries SPAKE2, SAS and the PQ-KEM hybrid and never the salt |
| 11 | **HORNET's forwarding segment**: a hop's own state sealed under that hop's long-term local key and carried in the packet, holding next hop, session key and expiry, collected once at setup by a modified Sphinx | `SESSION`, and it was the answer to the author's `:624` | `6ecf719d…`:685, 20:21:16.688Z | the tree names HORNET four times and never says how it works, so `.planning/REACH-MODEL.md:558`'s corner row is unexplained |
| 12 | **the seven-system landscape**: Tor circuits, HORNET, Sphinx/Loopix/Nym, LAP and Dovetail, PHI, NDN with its PIT, TARANET, each with where forwarding state lives and what it costs | `SESSION` | `6ecf719d…`:685 | `.planning/REACH-MODEL.md:838-852` carries the URLs and none of the comparison |
| 13 | **the author's backtracking question and its free-budget answer**: every hop slot below the maximum is already paid for by the position padding, so a detour costs zero header bytes | `AUTHOR` at `:695`, `SESSION` at `:711` | `6ecf719d…`:695, 20:22:31.425Z | `.planning/REACH-MODEL.md:335-352` carries the corridor trap and drops the budget argument that motivated it |
| 14 | **the replay interaction**: a path that revisits a node makes that node see the packet twice, which is what replay detection exists to catch | `SESSION` | `6ecf719d…`:711 | the tree makes the replay cache mandatory at `:332` and never states this interaction |
| 15 | **per-hop ephemeral IP**: what it buys (breaking the star pattern), what it cannot buy (an address is issued and issuance is attribution), and the eight-row native-against-IP gap table | `AUTHOR` at `:893`, `SESSION` at `:896` | `6ecf719d…`:893, 21:18:14.399Z | the author closed the branch at `:906` and the analysis lives only in the commit message of `6398035` |
| 16 | **the purity ladder**: local mesh, mixed, broad infra, and what holds at each | `SESSION` | `6ecf719d…`:886, 21:12:15.632Z | `.planning/REACH-MODEL.md:134-194` §5 carries the bus and the tether and not the ladder |
| 17 | **the ceremonial route's five honest costs**: a fixed target, whole-route compromise, coordination, no routing around a break, and scheduled re-ceremony | `SESSION` | `6ecf719d…`:829 | `.planning/REACH-MODEL.md:675` carries the route lifetime as a constant and none of the other four |
| 18 | **seed concentration**: derivation makes a single seed worth more, which is why derivation and quorum splitting are complements | `SESSION` | `f2b186e5…`:461, 2026-09-07T21:46:22.672Z | `.planning/CRYPTO-TRANSLATION.md:477-504` carries the dial and the inventory and not this consequence |
| 19 | **the Reticulum move applied to layout**: identity and routing inside the payload becomes the layout known by the type at compile time rather than by a runtime tag | `AUTHOR` at `:2117`, `SESSION` at `:2125` | `036d10bc…`:2117, 2026-09-09T04:31:44.036Z | `.planning/SHREDNET-RECOVERY.md` carries the author half as `I8`; the session's mapping is in no file |
| 20 | **the seven routing elements by who computes them**: `Link`, `Path`, `Layer`, `Route`, `Surb`, forwarding, replay guard | `SESSION` | `6ecf719d…`:620, 20:16:13.745Z | `.planning/REACH-MODEL.md:285-291` holds a four-row type table with different members |

### An author ruling on an open call

One, and it is procedural rather than technical.

`.planning/REACH-MODEL.md:747-786` §15 carries the forks. `R17`, the per-packet
unlinkability against statelessness fork, was opened by the session at `:781` and
**the author overturned its premise at `:785`** by refusing the closure and
directing the shrink. The session recorded the effect in its own words at `:873`,
21:05:32.615Z:

> ## Ceremonial routes answer `R17` without the cost I claimed

`records/author-calls.md` holds no row for it and `.planning/REACH-MODEL.md`'s
fork list carries no `R17` state column entry naming the author as its source.
Recorded here and not applied.

No transcript contained a ruling on any other of the 38 open calls across
`.planning/CRYPTO-MODEL.md` §13, `.planning/CRYPTO-TRANSLATION.md` §16,
`.planning/REACH-MODEL.md` §15 and `records/author-calls.md`. Every one of those
documents postdates the session that produced this material.

### Contradictions between history and the tracked tree

| # | the tracked claim | what history shows |
|---|---|---|
| 1 | `.planning/REACH-MODEL.md:624` prices the blinding element at *"~1.1 KB under PQ. This is the wall"* | the author refused that wall at `6ecf719d…`:785 and the session conceded at `:819` that *"the header stays HORNET-sized while gaining per-packet unlinkability and full PQ"*. The wall row and the ceremonial row at `:633` sit four lines apart with nothing saying the second answers the first |
| 2 | `.planning/REACH-MODEL.md:559` bounds rotating tags at *"O(active sessions), unbounded by topology"* | the construction the author asked for was never per-session. `6ecf719d…`:829 moved it to per route before it was written down, and `:560` carries that as a separate row rather than as the same construction rebounded |
| 3 | `.planning/REACH-MODEL.md:522` states the PQ signature *"never touches the fetch path"* | `:689` puts a signature verification at step 3 of every first fetch of a mutable pointer. `records/crypto-primitives.md` already reports this and the file is unchanged |
| 4 | `docs/arcs/native-protocol-arc.md:63` gives `N4` *"Noise reference class"* with no pattern | the session that introduced Noise named `NK`, `KK` and `XX` as the requirement's own vocabulary at `6ecf719d…`:586, and the arc row predates and does not cite it |
| 5 | `.planning/REACH-MODEL.md:632` fits the radio profile in ~390 B at `H` of 3 with a classical blinding element | `6ecf719d…`:819 gives the rotating-tag radio figure as ~132 B with no element at all, and `:633` carries only the `H` of 8 column for that row |

---

## §5 · What this does not recover

Searched, and found nothing.

| subject | what was searched | result |
|---|---|---|
| the author's phrase *"between physicals"* | `physical`, `physicals`, `between physical` over every chirality transcript, user turns only | **zero.** The phrase is the author's 2026-09-23 recollection and appears in no earlier turn. The design it names resolves to `6ecf719d…`:896's medium-layer-address statement and `:886`'s tether rewording, neither of which uses the word |
| the author's phrase *"hashing the bundle"* | `hash the bundle`, `hashing the bundle`, `hash the`, `hashing the` over every chirality transcript | **zero author turns.** The nearest author statement is `:785`'s *"deriving the bundle from compact form before using bundle"*, and the nearest construction is the jala BLAKE3 bundle address read at `:230` |
| the author's phrase *"multiple ways"* | `multiple ways`, `multiple way` over every project transcript | **zero.** The author never counted the exchange methods in any session. Six are enumerable from `6ecf719d…`:492, `:586` and `:829` |
| `LoRa` | word-boundary `lora`, `LoRaWAN`, `SX127`, `radio module` over every chirality transcript | **zero.** `radio` occurs throughout as a generic medium with a 500 B MTU and no radio technology is ever named. The 2,600-odd bare `lora` substring hits are inside other words |
| `mixnet`, `cover traffic`, `chaff` | every chirality transcript | `mixnet` and `cover traffic` occur only in `6ecf719d…` and in the session dispatching this run. `chaff` occurs once, in `.planning/RUNG2-MICROVM-MAP.md` as read text, and in no author turn |
| a key a person speaks aloud, beyond `:826` | `verbal`, `speak`, `spoken`, `type it in`, `say it`, `read aloud` over author turns | one turn, `6ecf719d…`:826, already quoted at `K5`. No second author statement on key entry exists |
| `ratchet` as an author word | every chirality transcript, user turns only | **zero author turns.** Every one of the hits is a session's word, a tool result, or the unrelated *"a ratchet beats a prose claim"* idiom in `tools/ledger-lint` |
| `dilithium`, `kyber` as author words | every project transcript, user turns only | **zero.** Both appear only in session text and tool results. `ML-KEM` and `ML-DSA` are likewise session vocabulary |
| a routing or crypto design outside `6ecf719d` and `f2b186e5` | the full vocabulary list over all 163 chirality top-level transcripts, user turns only | four author turns elsewhere, all already homed: `43cf1dc1…`:58 and `:525` on scope and Shamir, `f2b186e5…`:549 on Shamir, `036d10bc…`:2117 on Reticulum. No other session carries a connectivity design turn |
| the `jala` pairing source | `/workspace/jala/.planning/ARCHITECTURE.md`, cited by `6ecf719d…`:829 | the session read part of it at `:222` and the rotating-code-plus-passphrase sentence appears in no tool result inside the transcript. Recoverable only from the sibling project, which this run does not read |
| a second onion-routing session | `onion` recursively over every project | four files. `6ecf719d…`, the session dispatching this run and its five subagents, and `-workspace-workstuffs-HA-natures-storehouse-operations-dashboard`, whose five hits are a grocery product catalogue |

---

## §6 · What was searched, and what was skipped

| project | transcripts | files with a design hit | how it was searched |
|---|---|---|---|
| `-workspace-chirality` | 163 top-level, 339 under `subagents/` | **2 top-level.** `6ecf719d…` and `f2b186e5…` | every top-level `.jsonl` scanned line by line for `onion`, `hop`, `key exchange`, `keyex`, `handshake`, `ratchet`, `ephemeral`, `blinding`, `encapsulat`, `KEM`, `kyber`, `dilithium`, `lattice`, `post-quantum`, `pq`, `bundle`, `hash the`, `hashing the`, `smaller`, `shrink`, `MTU`, `LoRa`, `radio`, `mesh`, `physical`, `relay`, `mixnet`, `cover traffic`, `chaff`, `identity`, `keypair`, `pairing`, `ceremony`, `passphrase`, `verbal`, `speak`, `out of band`, `sealed`, `envelope`, `route`, `routing`, `shamir`, `PAKE`, then filtered to user-role text turns and read at bounded ranges around each hit |
| `-workspace-metis-the-lang` | 88 top-level | 0 | `onion`, `kyber`, `ML-KEM`, `post-quantum`, `shrednet`. One `onion` hit, in a subagent file. Five `shrednet` hits, all a hosts file naming `control.shrednet.conn` and a repository listing |
| `-workspace-workstuffs` | 22 top-level | 0 | same terms. 23 `ML-KEM` hits, every one inside a subagent file under two sessions, and none in a user turn |
| `-workspace-workstuffs-HA-natures-storehouse-operations-dashboard` | 71 | 0 | `onion` returns five files, all a grocery catalogue |
| `-workspace-workstuffs-natures-understory` | 32 | 0 | same terms, zero hits |
| `-workspace-chirality-prog` | 4 | 0 | 28 `post-quantum` hits, all inside two subagent files and one main session's own text |
| `-workspace`, `-workspace-manas`, `-workspace-metis-the-lang--claude-worktrees-agent-*` | 9 | 0 | `shrednet` returns one hit each: a tailnet resolution probe, a firewall script name, nothing |
| `-open-org`, `-workspace-emacatron`, `-workspace-minecraft`, `-workspace-moneyplans`, `-workspace-niri-tempsetup`, `-workspace-shredtower-setup`, `-workspace-workstuffs-inktags` | 0 | 0 | none of these holds a `.jsonl` |

**Subagent transcripts carry no author turn.** A file under
`<session>/subagents/` holds an orchestrator's prompt and an agent's work and no
user-typed turn. The `onion` and `ML-KEM` hits inside them are agent text.

`9fa15336-d71e-4159-9008-3742828e2b46.jsonl` was skipped on instruction.
`619b6457-a2f5-4f60-b744-4eb049f8dc14.jsonl`, the session dispatching this run,
was skipped for design content and used only to confirm which terms are the
brief's own.

No transcript was read whole. Every read was a bounded line range located by a
prior scan.

### Where the design lives outside this tree

`6ecf719d…`:230, 2026-09-05T19:01:41.802Z, is the session reporting what it found
after the author said at `:160` *"Review shrednet thoughts"*:

> `/workspace/shrednet` was rescoped on 2026-04-24 down to **TOML config schemas,
> no runtime, no daemon**. Its own PROJECT.md says so, and it explicitly orphans
> the 7-crate Rust mesh VPN sitting in `shrednet/shrednet/` (authorized as a quarry
> to mine, not a base).
>
> **The protocol thinking lives in `jala` and `jala-setu`.** jala is a clean-room
> Rust reimplementation of **Reticulum**.

**So one piece of this subject has a location and not a transcript.** The
identity bundle, the BLAKE3 address, the destination typing, the pair-gate, the
src-less packet, the PQ-hybrid handshake with its per-packet ratchet and the
pairing salt are files under `/workspace/jala` and `/workspace/jala-setu`. This
run did not read them. `K7` above is the only view of them any chirality
transcript holds, and it is one table a session typed from a reading that ended
at `6ecf719d…`:226.
