# Key stalls: the contents view

A first view across the lock, the key and the stall: what each thing literally
contains, in each form it takes, where it sits and when it exists. It is
written to find where too much is shared, and it is tuned with the author
before any piece file adopts it. Draft 2026-09-30.

**Every size is a placeholder** chosen to make the view concrete. None is a
decision.

## Forms

| form | means |
|---|---|
| raw | the bytes themselves |
| bundled | several raw things laid end to end in one structure |
| hashed | a fixed-length digest of something, under a named domain |
| sealed | encrypted and tagged under a key, with a stated part left readable as associated data |
| split | Shamir shares of something |

## Every artifact, literally

| # | artifact | form | literal contents, placeholder sizes | where | when | readable by |
|---|---|---|---|---|---|---|
| C1 | `m` | raw | 32 B of entropy | memory | inside W3, W5, W6, W7 | the running stall |
| C2 | `b`, the binding | bundled | `p` 16 B ‖ `L` 16 B ‖ `e` 8 B ‖ `x` 8 B = 48 B | memory, and see C6, C8 | every work | see C6, C8 |
| C3 | `c`, the commitment | hashed | `H("commit" ‖ m ‖ b)`, 32 B | the lock, every share header | from W3 until the lock is gone | anyone who holds a lock or a share header |
| C4 | `s_i`, one share | split | one byte per byte of `m`, 32 B ‖ `i` 1 B | memory, then C7 | from W3 until W8 or W9 | inside C7 |
| C5 | `h_i`, a share header | bundled | `b` 48 B ‖ `c` 32 B ‖ `i` 1 B ‖ `K` 1 B ‖ `N` 1 B ‖ factor id 1 B = 84 B | inside C7 | same as C4 | **see C7** |
| C6 | a share at rest | sealed | `h_i` readable ‖ `seal_F(s_i)` 33 B + tag 16 B | the stall's storage, one per factor | from W3 until W8 or W9 | the header by **anyone reading the storage**, the share by the factor's holder |
| C7 | the bundle | bundled | every C6 the person holds on this device, across every lock and factor | the stall's storage | while the stall exists | its headers by **anyone reading the storage** |
| C8 | a lock | sealed | `b` 48 B readable ‖ `c` 32 B readable ‖ `n` 16 B ‖ ciphertext ‖ tag 16 B | wherever the sealed data is kept | from W3 until dropped | the header by **anyone holding the lock**, the content by the key |
| C9 | `k_op` | raw | `KDF("op" ‖ m ‖ b)`, 32 B | memory | one operation | the running stall |
| C10 | `n` | hashed | `H("nonce" ‖ m ‖ b ‖ content)`, 16 B | memory, then C8 | from sealing on | anyone holding the lock |

## Where too much is shared

| # | exposed | through | to | what it gives away |
|---|---|---|---|---|
| E1 | `p`, the person | C8, C6, C7 | anyone holding a lock; anyone reading a device's storage | whose lock it is, and that one person owns a set of locks |
| E2 | `L`, the lock id | C8, C6, C7 | the same | which locks exist, and which shares belong to which lock |
| E3 | `x`, the expiry | C8, C6, C7 | the same | when each lock dies. A thief (X2) learns what to copy before when |
| E4 | `e`, the epoch | C8, C6, C7 | the same | how often each lock rotates |
| E5 | `c`, the commitment | C8, C6 | the same | links every share to its lock without opening either |
| E6 | `K`, `N`, factor id | C6, C7 | anyone reading storage | how many factors a thief needs, and which ones |
| E7 | C7's shape | the bundle's size and count | anyone reading storage | how many locks the person holds |

## The tension this view shows

Q4 in `.planning/KEY-STALL-STALL.md` asks for the expiry readable from one share
without recombining, so W8 can shred on time. A header readable by the stall and
by nobody else needs a key of its own at rest, and a whole key at rest is what
K6 forbids. Making the header unreadable breaks Q4, and leaving it readable is
E1 to E6.

## Draft: the bundle as a lock

Proposed by the author: *"we should make the bundled thing locked itself in bundled state and we use the different handling with an extra key to our advantage because we can right?"*

| # | move | closes |
|---|---|---|
| B1 | the bundle is itself a lock, sealed under a bundle key. The bundle key is a key like any other: born split across the factors, no whole copy at rest (K6) | E1 to E6 at rest. Storage shows one sealed blob |
| B2 | every share header moves inside the bundle | E1 to E6 in storage |
| B3 | a lock's `b` and `c` move into the lock's entry in the bundle. The lock keeps an opaque handle, `n`, the ciphertext and the tag | E1 to E5 to anyone holding a lock |
| B4 | the bundle is padded to a size class | E7, down to the class |
| B5 | ⚑ superseded by K7 and T5: expiry is enforced at unlock, inside the bundle. Was: the bundle key's expiry is the earliest expiry inside it. Every open of the bundle reseals it under a fresh bundle key and drops expired entries, which is W7 applied to the bundle | an expired share recovered by opening the bundle after its expiry |

**What B5 costs.** If no legitimate open happens before the earliest entry expires, the bundle key dies and takes every entry with it. Grouping entries into several bundles by expiry band softens that, and it is the cascade: each band is a bundle, and the bands are entries of the band above.

## Draft: the factors are the shares, per bundle, per open

Proposed by the author: the factors are the unlock, *"in a way that the correct result is structurally unforgeable and required"*, and *"the factor should handle ephemerally per bundle"*, because *"if keys are "invisible" until factor unlocks it's ok if a genuine factor user can unlock all their keys but for an attacker trying to abuse the system it works against them"*. It replaces B1's shares sealed under factors.

| # | move | what it does |
|---|---|---|
| B6 | each bundle holds a fresh challenge `r`. Each factor answers it: `o_i = F_i(r)` | an output is good for one bundle and one open |
| B7 | at rest the stall keeps only masks, `mask_i = share_i ⊕ o_i` | a mask alone is uniformly random, so storage holds nothing worth taking |
| B8 | unlock: K factors answer `r`, the outputs strip the masks, the shares recombine into the bundle key, and `commit(key, binding) = c` is checked | a wrong output gives a wrong key, which the commitment refuses |
| B9 | every open ends by resealing the bundle under a fresh key, a fresh `r` and fresh masks, answered by the factors still present | a captured output is dead after the open it came from |
| B10 | in chirality the opened bundle is a type only combine constructs, from K factor outputs as linear values, and only on a commitment match. Opening requires that type | an open without real factors, or a result that skipped the check, does not typecheck |

**What it asks of each factor**: a function of a challenge that only the factor can compute. A device's secure element and a token each compute a keyed function inside, and FIDO2's `hmac-secret` is the unpinned precedent for a token. The person's secret through the memory-hard derivation `crypto-primitives/K34` costs a full derivation per bundle, so a person with many bundles pays that many times per session, and deriving once per session and then per bundle makes the session's secret the thing to capture.

## Draft: factors, local now, with a slot for later

Scope of this draft: local only, on one device. Anything across devices waits, and the structure keeps a slot for it.

| # | move | what it does |
|---|---|---|
| B11 | a factor is anything that answers a challenge. Whether the answer comes from this device or from elsewhere is a property of the factor, and the stall treats every answer the same | a later factor across devices, such as the author's own 2FA, plugs into the same slot with its own channel |
| B12 | an anchor is a factor an attacker cannot produce: a secure element on this device, or a hardware token plugged into it | |
| B13 | every check, the commitment and every tag, takes an anchor's answer | nothing at rest can confirm a guessed password, so offline guessing has nothing to test against |
| B14 | the memory password and the second password are layers. They join one memory-hard derivation together, so guessing costs the product of the two | |
| B15 | with no anchor present, as at rung 1 with no secure element and no token, the passwords are generated by the stall at 32 characters or more, about 210 bits | guessing is out of reach by entropy alone |

## Draft: expiry in the stall, and the clock

| attack | defence |
|---|---|
| the clock is rolled back while the stall is off | the stall keeps a time high-water mark inside the sealed bundle and refuses any clock earlier than it, at every unlock |
| the whole device is restored, bundle and mark with it | rung 1 cannot see it. Rung 2 closes it with the secure element's monotonic counter |
| the stall is off when an expiry passes | nothing opens without an unlock, and every unlock shreds expired entries before serving |

## Draft: shrinking bundles into smaller ones

| move | what it does |
|---|---|
| B16 bundles inside bundles | an entry can be a smaller bundle under its own key. One lock's open touches only the bundles on its path, and the reseal touches only those |
| B17 a forest at the top | several independent top-level bundles and nothing above them, so no key acts as a root (A8) |
| B18 split when full | a bundle past its size class splits in two, each resealed under a fresh key |
| B19 merge when thin | small bundles merge as entries die, so their count hides how much has died |
| B20 group by expiry | entries expiring close together share a bundle, so one shred takes a whole bundle |

Deeper bundles make each open touch less and put more keys on the reseal path. Shallower ones reseal less and hold more entries in memory at each open.

## Open

- The two rules, L5 and T4: how a lock is brought to a stall, and how a stall moves.
- B16 to B20, and how deep.
- B11 to B15.
- B6 to B10, and the person's-secret cost.
- B1 to B5, and whether the bands cascade.
- W8 now shreds when the bundle is opened, or when the bundle key dies. Whether that is soon enough.
