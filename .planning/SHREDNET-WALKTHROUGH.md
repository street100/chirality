### Outlining the actual happenings of shrednet for clarity

## PIECES

1. Encryption

2. Shrinking encrypted bundle

3. Transport

4. Trust

Tags, not sections. Each step below names which pieces it touches.

## SHAPE OF A STEP

| slot | fills with |
|---|---|
| who acts | the parties present |
| holds first | what they must already have |
| produces | what exists after that did not before |
| on the wire | what an observer sees, or `nothing` |
| learns | one line per party present |
| missing | what this step needs that does not exist |

## PRIVATE first

# Trust process leads as most surface part

1. Server mints a socket, gets key · *trust*

| | |
|---|---|
| who acts | server, alone |
| holds first | nothing |
| produces | the socket handle, and the key behind it |
| on the wire | nothing. Local |
| learns | nobody |
| missing | what a socket **is** as a type. Whether one handle exists or one per caller. `REACH-MODEL:745` measures `Mark`, `Parcel`, `Bus`, `Way`, `route` and the verbs as **nothing** |

2. Client uses a ceremony that uses an ephemeral identity and public lanes for a
   secure exchange (Need to plan, physical confirmation, offline exchange of
   different levels, etc.) · *trust, encryption*

| | |
|---|---|
| who acts | client and server, plus an out-of-band channel |
| holds first | the out-of-band secret. **Not** the server's public material: a PAKE authenticates without it |
| produces | a shared secret, and from it the client's per-caller handle |
| on the wire | opaque bytes on the public lane, the same path as any public value, `REACH-MODEL:123` |
| learns | a ceremonial hop: an exchange passed, not whose. The server: a new caller, not who they are anywhere else |
| missing | which construction of the three at `REACH-MODEL:268-274`. What a `Grant` is, `crypto-primitives/K31`. The two-code scheme below is in no file |

### The out-of-band secret, two layers

| layer | what it is | why |
|---|---|---|
| the rotating code | both sides hold a generator; the pairing secret is what it shows now, not a fixed string | a captured code is worthless once it rotates, so the channel carries nothing with a lifetime |
| the sync | a small temporary code brings two generators into agreement | the durable thing is generator state. A person only ever handles short codes |

Two weak codes compose here because the framework removes grinding. A PAKE gives
one **online** guess against a live counterparty, never an offline dictionary,
so rotation adds a deadline to a problem that already had no shortcuts. Not
added entropy. Added constraints.

Recovered: jala pairs with a rotating code plus a passphrase, out of band, used
as the handshake's salt. `REACH-MODEL:268-274` carries SPAKE2, the short
authentication string and the PQ-KEM hybrid, and carries neither.

3. Introduction over the ceremonial route · *trust, transport*

Mechanism and who-learns-what already written at `REACH-MODEL:230-241`.

4. The splice joins two ephemeral half-routes · *transport*

Four steps and a per-party knowledge table at `REACH-MODEL:238-249`.

5. The session · *encryption, shrinking, transport*

Marks still verify, so integrity never depends on the session, `REACH-MODEL:311`.

## PUBLIC after

0. Resolution: a seal from a document becomes something reachable

The private path never needs this, because a human carried the bootstrap. The
public path always does. **No mechanism anywhere in the tree.**

1. Ask by seal for the party's signed pointer. This verb does not exist:
   `REACH-MODEL:719-722` has three verbs, all keyed by a mark

2. Verify the signature against the seal. Identity **is** expected in public;
   only an immutable fetch by mark escapes it, `REACH-MODEL:34`, `:37-40`

3. Ask for the index by mark, then the content marks it names

## NO MECHANISM YET

| gap | where |
|---|---|
| resolution, seal to reachable | public 0 |
| ask-by-seal, the fourth verb | public 1 |
| freshness: a signature cannot prove no newer pointer exists | public 2 |
| revocation, anywhere | both |
| the two-code pairing scheme | private 2 |
| what a `Grant` is | private 2 |
