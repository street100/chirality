# Key stalls: the stall

Worked through with the author in session, after the lock and the key.
`.planning/KEY-STALL-DISCUSSION.md` holds the rulings and the rejections this
file is checked against. A stall is one person's instance of the program on one
device (A8). Nothing is bound to it (A6), and nothing it does waits on another
party (A9). This file covers the stall on its own device, in process.

## Settled

| # | ruling |
|---|---|
| T1 | The stall is plotted by its works, and the works say what it asks of a key. The author, 2026-09-30: *"lets look at what a stall asks for of the key by plotting out stall works and then use that to finish speccing the key"* |

| T2 | The conflict below is resolved by factors on the device, as diverse as the spectrum needs. The author: *"yes we need to have diverse as shit factor stuff for the whole genuinely secure spectrum for em"* |
| T3 | The works list stands. The author: *"This is good enough"* |

## A conflict the works surfaced, resolved by T2

K6 in `.planning/KEY-STALL-KEY.md` binds expiry by holding no whole key at rest,
only Shamir shares. If those shares sit on other devices, opening a lock on this
device needs K of them, and the discussion file already rejects that under A9:
*"opening content by gathering K of N shares in daily use"*.

**Resolution, settled by T2.** The stall holds K shares on its own device,
each under a different custody factor, so opening stays local and no whole key
is ever at rest:

| factor | rung | what holding it takes |
|---|---|---|
| F1 device custody | 1: a file sealed to the device. 2: a secure element that will not export | the device |
| F2 the person's secret | 1 and 2: the memory-hard derivation, `crypto-primitives/K34`, salted per session | the person present |
| F3 a separate token | 2: a hardware token from another vendor | the token present |

A thief (X2) holding the device alone has F1 and falls short of K = 2. Shares
kept on the person's other devices serve recovery, and moving them crosses the
wire, which is the route layer's.

## Works

| # | work | what it does on the device |
|---|---|---|
| W1 | enroll | creates the person's stall on this device and sets up its custody factors |
| W2 | unlock | the person presents their factors. The stall holds nothing opened between operations, so unlock admits operations and opens nothing by itself |
| W3 | mint | makes a key for a new lock, seals the lock under it, splits the key across the factors, and shreds the whole key |
| W4 | hold | keeps shares at rest, each sealed under its factor, beside the public metadata of each lock the person holds |
| W5 | serve | one seal or open: gathers K shares, recombines, runs the one operation, shreds |
| W6 | extend | before expiry, moves a key's expiry later and reseals its lock under the new binding |
| W7 | rotate | advances a lock's epoch: opens under the old key, seals under a new one, drops the old |
| W8 | expire | at expiry by its own clock, shreds every share of the key it holds |
| W9 | drop | on request, shreds every share of a key and the lock's metadata entry |
| W10 | isolate | keeps two people's stalls on one device from reaching each other's shares, factors or operations |

## What the works ask of a key

| # | the stall asks | from the works |
|---|---|---|
| Q1 | a key that is born split: drawn, bound and split inside one work, with no whole key surviving it | W3 |
| Q2 | each share describes itself: person, lock, epoch, expiry, the lock's commitment, its index | W4, W5, W8 |
| Q3 | shares recombine only when those fields match, and only before expiry | W5, K6 |
| Q4 | the expiry is readable from one share without recombining | W8 |
| Q5 | open serves one operation and returns shredded, whatever the operation's outcome | W5 |
| Q6 | extension and rotation are each one operation from open, ending in a new split and a drop | W6, W7 |
| Q7 | drop is reachable from every state | W8, W9 |
| Q8 | a key names its person, so two stalls on one device cannot recombine each other's shares | W10 |

## Open

- The full factor set across the spectrum, rung 1 to rung 2.
- W1 and W2's own mechanics.
