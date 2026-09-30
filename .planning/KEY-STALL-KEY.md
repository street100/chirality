# Key stalls: the key

Worked through with the author in session, after `.planning/KEY-STALL-LOCK.md`.
`.planning/KEY-STALL-DISCUSSION.md` holds the rulings and the rejections this
file is checked against.

## Settled

| # | ruling |
|---|---|
| K1 | A key has many states, and each state is what lets it provide what a lock asks. The author, 2026-09-30: *"the important bit is that any key actually kinda has a lot of different states to provide propers"* |
| K2 | Keeping a key at rest is the stall's job, and the key has no at-rest state. The author: *"at rest is stalls job"* |
| K3 | Open is shredded from memory as soon as possible. The author: *"open needs to be more specific about shred from memory asap"* |
| K4 | Split is Shamir over the key. Where the shares live is the stall's. The author: *"split here is shamir not stall stuff"* |
| K5 | An old key dies everywhere and is irrecoverable at expiration, except by a legitimate extension made before it. The author: *"can we make old keys just die all around? irrecoverrable at expiration (outside of legit expiration extension) should be the case right?"* |

## States, draft

Each move consumes the state it leaves, so a key is in one state at a time.

| state | what it is | answers the lock's |
|---|---|---|
| drawn | fresh from entropy, tied to nothing | none |
| bound | tied to one person, one lock, one epoch and one expiration | S1, S2, S3 |
| open | in memory for one operation. The operation consumes it, and it is shredded the moment the operation returns. It serves exactly one operation | S4 |
| split | Shamir shares of the key, K of N. Neither a share nor any set of fewer than K opens anything | none |
| dropped | destroyed, with every share of it. Irrecoverable | none |

⚑ Shredding is a language promise the machine can break: register spills, compiler copies, swap, and a dead-store eliminated zeroing write. `PRINCIPLES.md` §5 names it as the honest limit of zeroed-on-drop.

## Transitions, draft

| from | to | trigger |
|---|---|---|
| drawn | bound | tied to a person, a lock, an epoch and an expiration |
| bound | open | one seal or open operation starts |
| open | bound | the operation returns and the copy in memory is shredded |
| bound | split | shares are made for recovery |
| split | bound | K shares recombine, before expiration |
| bound | bound | a legitimate extension, made before expiration, moves the expiration later |
| bound | dropped | expiration passes, or an explicit drop |
| split | dropped | the same, and every share goes with it |

## What K5 costs

- **A lock sealed under a dying key dies with it** unless it is resealed under its successor first. Rotation is therefore a migration: open under the old key, seal under the new one, then drop the old key.
- **Expiration needs a clock, and a clock is a port.** On one device offline, a clock rolled back (X6) delays the drop. An epoch advanced by an event, such as a rotation or a revocation, needs no clock and is offline-safe. Expiration by time is only as strong as the time source.

## Open

Whether expiration is by time, by event, or both.
