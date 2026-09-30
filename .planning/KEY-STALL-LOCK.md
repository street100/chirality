# Key stalls: the lock

Worked through with the author in session. `.planning/KEY-STALL-DISCUSSION.md`
holds the rulings and the rejections this file is checked against.

## Settled

| # | ruling |
|---|---|
| L1 | A lock is general. The author, 2026-09-30: *"a lock is general. the idea is just "you give the correct thing to this, access granted""* |
| L2 | The open question is the lock's own side: *"the complicated part for this bit is the opposite side of this and what solutions say about where structure needs to go"* |
| L3 | Access granted is successful decryption. The author: *"access granted is positionally identical to successful decryption"*. A lock is sealed data, and the correct thing is the key that opens it |
| L4 | The lock is read from what it asks of a key. The author: *"approach from what this asks of key perspective"* |
| L5 | Revocation and rotation reach a lock only where the lock and a stall meet, so a lock can be brought to a stall to be resealed under the new key. The author, 2026-09-30: *"a stall can move securely and lock can talk to a stall"*, and *"How can revocation apply to a lock if a lock can't be brought to a stall to be adjusted for the new key?"*. A lock that never meets a stall stays sealed under its old key |

## Consequences of L3

- A lock holds nothing secret. Holding a lock is holding ciphertext, so X4, a compromised lock, gains nothing beyond the ciphertext.
- Opening is local, so A9 holds by construction.
- Dropping a key makes every copy of the lock unopenable wherever it sits.

## Open: what the sealed data must carry

For "decrypts" to mean "the correct key", the structure has to sit in the ciphertext itself. Candidates, each unpinned:

| # | carried | without it |
|---|---|---|
| S1 | a commitment to the one key that opens it | a non-committing AEAD can decrypt successfully under two different keys, so success no longer names the key |
| S2 | the lock's context and domain | a lock opens as a different lock |
| S3 | the epoch | an old key opens a rotated lock. ⚑ The epoch carries no time. Expiry is the stall's alone, per `.planning/KEY-STALL-KEY.md` K7 |
| S4 | a nonce derived from the key and the content | a nonce counter is state that rollback (X6) can reuse |

## What opening asks of a key

Each candidate above is a demand on the key that opens it.

| # | the lock asks the key for |
|---|---|
| S1 | being the one key committed to, so one key per lock |
| S2 | knowing which lock it is for |
| S3 | carrying an epoch, and being refused at a lock of a later epoch |
| S4 | deriving the nonce itself, so the key carries no counter |

The key's states that answer these are the key's own, in `.planning/KEY-STALL-KEY.md`.
