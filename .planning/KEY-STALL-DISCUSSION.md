# Key stalls: the discussion

The relay for the key-stall design, opened 2026-09-30 from a session with the
author. It holds the author's rulings verbatim, what was proposed and rejected
with the reason, and the adversary list the piece designs are checked against.
The pieces are designed one file each, in order: the lock, then the key, then
the stall.

| piece | file | state |
|---|---|---|
| lock | `.planning/KEY-STALL-LOCK.md` | dispatched 2026-09-30 |
| key | `.planning/KEY-STALL-KEY.md` | after the lock |
| stall | `.planning/KEY-STALL-STALL.md` | after the key |

## Where it came from

The crypto pre-wave (`records/findings.md` FD-58 to FD-61) found that a keyless
digest's collision resistance cannot be guaranteed, only bounded, and that the
public mark's length is set by that bound. The author asked whether a
per-instance map changes that, and the model below grew from the answer.

## The author's rulings, verbatim

| # | ruling |
|---|---|
| A1 | *"cant we mathmatically guarantee no collision attacks work and shrink? p sure 1 of the 3 main failures is something we can solve in chirality"* |
| A2 | *"what if the intermediary for larger to smaller were a per instance thing"* |
| A3 | *"if we make the key managing systen the key generating system and keys are per person per lock and many locks are per instance in general. it just begs for a key bundle right?"* |
| A4 | *"new bundle member = new per instance tool? we also have code to sync and syncing codes before that planned already so im not sure how collision immunity isnt achievable here"* |
| A5 | *"flesh this out with storage custody, external verification (confirming with other "key stalls" as in instances of this key maker and storer program), and under the hood shamir and crypto used internally to strengthen model"* |
| A6 | *"nothing should be bound to stall"* |
| A7 | *"we can view this literally as per key contracts with differebt stalls with a way to rehome and a way to revoke stall and drop keys"* |
| A8 | *"each stall instance is per keyring on device, no root"*, corrected at once: *"not per keyring i meant per person"*. A stall is one person's instance on one device, and there is no root secret |
| A9 | *"you wrote out expectations of connectivity guarentee in core security protocol. massively backwards"*. No security property may depend on reaching another party |
| A10 | *"we also control the locks too btw. and how they work"* |
| A11 | *"lets design each individual piece to its own file starting with lock, so we can do key, so we can do stall"* |

## Rejected, and why

| proposal | rejected because |
|---|---|
| a public mark shortened by keyed hashing alone | the publisher picks the instance after crafting two contents, FD-52 |
| names carrying the issuing stall, `(stall, lock, counter)` | breaks A6: a lost stall orphans its names, rehoming renames content, the name leaks which device made it |
| a per-person root, with lock keys derived from it | breaks A8 |
| names issued from counter blocks leased from a quorum | breaks A9: issuing waits on reaching the quorum |
| a stall trusting a quorum's high-water mark after a restore | breaks A9 |
| opening content by gathering K of N shares in daily use | breaks A9: a person offline cannot use their own key |
| a lock allocating the names for what it holds | binds every name to one lock, the A6 defect with a new owner |
| the lock as the one place equivocation is decided | a single point of trust, which A5's splitting exists to remove |
| a symmetric challenge-response in which the lock holds each person's key | concentrates custody in the lock and away from the stalls A5 puts it in |
| "no public-key crypto on the lock path", stated without checking enrollment and strangers | a claim with nothing under it |

The last four were one reply, and the author called it *"shoddier"*. The
lesson for every piece design: each mechanism is checked against every ruling
and every adversary below before it is written, and a mechanism that breaks one
is recorded here as rejected.

## Adversaries, draft

Drafted by the session and open to the author's correction. A piece design
tests itself against each row and may add a row, which it states.

| # | adversary | controls |
|---|---|---|
| X1 | an outsider | the network: reads, drops, delays, replays and injects any message |
| X2 | a thief | one device, with every stall on it, at rest or running |
| X3 | a compromised stall | one person's instance on one device, its state and its code |
| X4 | a compromised lock | one lock's state and code |
| X5 | a dishonest co-holder | a person legitimately holding a key to a shared lock |
| X6 | a restorer | rolls a device, a stall or a lock back to an earlier state |
| X7 | a coercer | one person, made to act |
| X8 | a stranger | a party with no key and no pairing, verifying something shown to them |
