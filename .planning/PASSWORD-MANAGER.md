# A password manager, as a thing to build

Captured 2026-09-23 by author statement: add a password manager to what we need
to make, and it needs a tiny, straightforward, secure means of storing things
and allowing access. The reason it lands here rather than in a goal file is that
the blocker is the crypto layer, not the application.

## It is already this tree's own worked example

`docs/examples/E40-secret-custody.md:48` states the problem `E40` exists to
solve as *"a password manager that cannot leak its vault"*, and `:84-85` writes
the conventional shape it refuses: `pw = vault.decrypt(entry)` returning plain
`Bytes` that anything downstream may copy, log or print. `E40` is **built**, as
the custody slice `Secret` in `lib/capability/secret.chiral`, filed `OT` on the
deferred ownership track.

So the tool is not a new idea here. It is the first consumer that makes the
whole crypto roster load-bearing at once.

## What is already ruled, and constrains it

`docs/decisions/decision-deployment-custody.md:29`: the secure store is
**per-instance custody plus derive-not-store, not a central vault**. That is a
settled position and it decides the architecture before any primitive is picked:
entries descend from one seed rather than sitting encrypted in a file, and no
single store holds everyone's material.

`:61-62` puts passphrase-derived software key levels on **rung 1**, not behind
the rung-2 metal deferral, so nothing about this waits on hardware.

## Required primitives, and where each stands

| primitive | what it does here | state |
|---|---|---|
| `crypto-primitives/K34` | the memory-hard derivation: master passphrase to root key, at a declared memory and time cost | `open`, `unminted`. Added 2026-09-22 |
| `crypto-primitives/K35` | the derivation hierarchy: every entry descends from one seed, a child revealing nothing about a sibling or a parent. **This is `derive-not-store` as a primitive** | `open`, `unminted` |
| `crypto-primitives/K4` | the sponge as KDF, the machine the hierarchy runs on | `open`, `unminted` |
| `crypto-primitives/K19` or `K26` | sealing whatever must sit at rest rather than be derived | `open`, `unminted` |
| `crypto-primitives/K30` | nonce discipline under a long-lived key, which a store is by definition | `open`, `unminted` |
| `crypto-primitives/K36` | the key-and-context index, so an entry decrypted under the wrong key does not construct | `open`, `unminted` |
| `E40` `Secret` | custody: a plaintext that cannot be copied, logged or printed | **built**, `lib/capability/secret.chiral` |
| a collision-resistant digest | integrity over the stored form | **absent.** `lib/crypto/` holds ChaCha20 and Poly1305 and nothing else |

Seven rows, six of them unminted, one built, and one primitive class with no
module anywhere. Nothing here is blocked on a decision. It is blocked on the
layer being built.

## What this tool does not need

No network, no identity, no party, no routing. It is the one consumer in view
that touches layer 0 and stops, which makes it the cheapest honest test of
whether the crypto roster produces something usable.

## The open question it does raise

Whether unlocking is a passphrase alone, or the two-layer rotating-code scheme
under discussion for pairing. A password manager is the case where a person is
present every time, so the human-carried half is affordable here in a way it is
not on a packet path.
