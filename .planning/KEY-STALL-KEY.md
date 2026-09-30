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
| K6 | Decryptability is structurally bound to expiry. The author, 2026-09-30: *"make ability to decrypt structurally bound to expiry so its literally just unable to be decrypted outside of"*, and *"we can totally bind this"*. It binds because no whole key exists at rest: shares at rest (K4), whole only for one operation (K3). Every share and the lock's commitment (S1) carry the expiry, shares recombine only with shares of the same epoch and expiry, and each share is shredded at expiry. After expiry nothing exists to recombine. What remains: K stalls compromised before expiry, the one-operation copy read from memory, and a clock rolled back on K stalls |
| K7 | ⚑ K6's mechanism corrected by the author, 2026-09-30: *"if you're suggesting new material for extend, then expiry works wrong. Shouldn't expiry be stall only? this would suggest a criticial security issue around clock being left open"*. Expiry is the stall's alone (`.planning/KEY-STALL-STALL.md` T5). The binding carries no time, the commitment covers no time, and an extension moves the expiry in the stall's schedule with no new material. Decryptability is bound to expiry by the stall shredding, by L5 in the lock file, and by T4 in the stall file |

## Draft for review: works, parts, states

Written 2026-09-30 from the stall's asks Q1 to Q8 in `.planning/KEY-STALL-STALL.md`, and open to the author's correction.

### The works a key takes part in

| work | the key's part in it |
|---|---|
| W1 enroll | none |
| W2 unlock | none. Factors become available and no key changes state |
| W3 mint | born: drawn, bound, sealed into its lock, split, whole copy shredded |
| W4 hold | rests as shares, unchanged |
| W5 serve | recombined for one seal or open, then shredded |
| W6 extend | replaced by a successor at the same epoch and a later expiry |
| W7 rotate | replaced by a successor at the next epoch |
| W8 expire | every share shredded at expiry |
| W9 drop | every share shredded on request |
| W10 isolate | its person field keeps other stalls' shares from recombining with it |

### The key's parts

| # | part | secret | what it is |
|---|---|---|---|
| P1 | `m`, the material | yes | fresh from entropy. Its length is open |
| P2 | `p`, person | no | whose key it is |
| P3 | `L`, lock | no | the lock and its domain (S2) |
| P4 | `e`, epoch | no | advanced by rotation (S3) |
| P5 | `x`, expiry | no | ⚑ K7: held in the stall's schedule only. It is no part of the key |
| P6 | `b`, binding | no | `(p, L, e)`, with no time in it (K7) |
| P7 | `c`, commitment | no | `commit(m, b)`, kept in the lock (S1) |
| P8 | `s_i`, share | yes | Shamir share `i` of `m`, K of N |
| P9 | `h_i`, share header | no | `(b, c, i, K, N, factor)`, kept inside the bundle |
| P10 | `k_op`, operation subkey | yes | `KDF(m, b)`, for one operation |
| P11 | `n`, nonce | no | derived from `m`, `b` and the content (S4) |

### States, and the parts each one holds

| state | holds | where | lasts |
|---|---|---|---|
| drawn | P1 | memory | inside W3 only |
| bound | P1, P6, P7 | memory | inside W3, W6 and W7 only (Q1) |
| split | P8 and P9 for each share. **No P1** | the stall, each share under its factor | until expiry or drop |
| open | P1, P6, P7, P10, P11 | memory | one operation (Q5) |
| dropped | nothing. P7 stays in the lock and is public | nowhere | forever |

Every state a key can rest in holds no P1. P1 exists only inside a work.

### Each work, step by step

| work | steps, with the state after each |
|---|---|
| W3 mint | draw `m` → **drawn**. Set `b = (p, L, e₀, x)`, compute `c` → **bound**. Derive `k_op` and `n`, seal the lock, write `c` and `b` into it → **open**. Split `m` into `s_1 … s_N` with headers `h_i` → hand to the stall. Shred `m`, `k_op` → **split** |
| W5 serve | gather K shares whose headers match `b` and `c`, with `x` after now (Q3) → recombine `m` → check `commit(m, b) = c`, and on a mismatch shred and refuse → **open**. Derive `k_op` and `n`, run one seal or open. Shred `m`, `k_op` whatever the outcome (Q5) → **split**, the shares unchanged |
| W6 extend | before `x`: the stall moves the entry's expiry to `x′` in its schedule. Nothing else changes (K7) |
| W7 rotate | the same as W6 at `(p, L, e + 1, x′)` |
| W8 expire | at every unlock, before anything is served: the stall refuses a clock earlier than its time high-water mark, raises the mark, and shreds every entry whose `x` has passed → those keys **dropped** |
| W9 drop | from any state: shred every share and any copy in memory → **dropped** |
| W10 isolate | recombining refuses a share whose `p` differs from the request's |

⚑ **Superseded by K7.** W6 drew fresh material, which made an extension a rotation and left the clock open wherever expiry sat. An extension is now a change to the stall's schedule.

## What K5 and K6 cost

- **A lock sealed under a dying key dies with it** unless an extension reseals it under the new expiry first.
- **Each stall reads its own clock.** A clock rolled back (X6) keeps that stall's share alive, so it takes K rolled-back stalls to open after expiry.

## Open

What an extension requires, and who may make one.
