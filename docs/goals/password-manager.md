---
node: goal-password-manager
layer: navigation
related: [goals/README, goals/own-web, goals/ownership-and-trust, goals/native-stack, arcs/custody-executes-arc, arcs/crypto-primitives-arc, examples/E40-secret-custody, decisions/decision-deployment-custody, decisions/decision-scope, decisions/decision-work-ids, trust-boundary, modules-custody, status-ledger, records/author-calls, records/crypto-primitives, index]
status: current
updated: 2026-09-23
---

# Goal: a password manager whose vault cannot leak

Stated by the author 2026-09-23, in session: a password manager belongs on the
list of things to make, and it is *"a tiny straightforward and secure means of
storing things and allowing access"*. The same statement ties it to the layer
under it: *"we really need to get crypto primitives and tools done."*

The statement is the trigger. The claim itself derives from text the repo
already carries, on the precedent [[goals/README]] records for [[goals/bridge]]
and [[goals/module-split]].

## The claim, and where the project makes it

- `docs/examples/E40-secret-custody.md:48` gives `E40` its reason for existing.
  The custody primitive is *"the smallest artifact that demonstrates that claim
  on a problem a person understands (a password manager that cannot leak its
  vault)"*.
- The same file at `:85-86` writes the conventional shape the project refuses:
  `pw = vault.decrypt(entry)` yields plain `Bytes`, and the line under it,
  `sock.send(pw)`, *"compiles, runs, leaks. nothing objects."*
- `prog/demo/passman-min.chiral:1-2` already ships a fragment of the thing,
  32 lines calling themselves *"the E40 proof in miniature: a password-manager
  fragment whose vault secret STRUCTURALLY cannot be sent to a socket"*.
- `docs/decisions/decision-deployment-custody.md:29` rules the architecture the
  tool has to take. The secure store is *"per-instance custody +
  `derive-not-store`"*, and the row it sits in refuses a central vault.
  [[decisions/decision-deployment-custody]] is the note.
- The same file at `docs/decisions/decision-deployment-custody.md:61-62` puts
  *"**Software key levels** (passphrase-derived, split-K-of-N,
  tier-by-classification)"* on **rung 1**, ahead of the rung-2 metal deferral.
- [[arcs/crypto-primitives-arc]] already rosters the primitives the author's
  second sentence asks for. It opened 2026-09-07 under [[goals/own-web]]
  condition 4 and carries 36 rows today.
- [[modules-custody]] holds the module family this tool is the first consumer
  of, and `docs/modules/modules-custody.md:13-14` marks it DESIGNED with
  custody-split, redundancy and datum-policy unbuilt.

## The shape condition

The author's words carry a constraint on the tool as well as a request for it:
**tiny and straightforward**. Three consequences, each a test.

1. **It composes and implements nothing.** Observed by the tool's own sources
   defining no cryptographic kernel and importing every one from `lib/crypto/`.
2. **It is one program on the tree's own floor.** Observed by one `.prog` under
   `prog/` with a named phase in `tools/test/run-tests.sh`, the shape
   `prog/demo/passman-min.chiral` already has without the phase.
3. **It mints nothing of its own in the crypto layer.** Observed by every
   primitive it needs standing as a roster row in an arc that already exists,
   cited as `<arc>/<id>` per [[decisions/decision-work-ids]].

## What done means

Five conditions. **One holds an arc file and four do not**, and the reason is in
`## Arcs` below.

1. **The leak does not compile, and a gate says so on every run.** Observed by
   `tools/test/run-tests.sh` carrying a named phase that elaborates
   `tools/test/samples/e170_reject_secret_leak.prog` and fails when the leak arm
   type-checks. That fixture is 30 lines on disk and no line of
   `tools/test/*.sh` names it, so nothing runs it today. **Unopened, and it
   holds no arc file.**
2. **The vault at rest is sealed by chirality's own crypto.** Observed by the
   stored file's format being produced by `crypto-primitives/K19` or
   `crypto-primitives/K26` and by the tool importing no cipher from outside
   `lib/crypto/`. Both rows read `open` and `unminted` in
   [[arcs/crypto-primitives-arc]], which serves [[goals/own-web]] condition 4.
   **Unopened, and it holds no arc file under this goal.**
3. **The vault key is derived from the person's secret and is never stored.**
   Observed by no file the tool writes holding key material, and by the
   derivation being `crypto-primitives/K34`, the memory-hard row, at a declared
   memory and time cost with a refusal for a target that cannot pay them.
   `crypto-primitives/K35` carries `derive-not-store` itself as a primitive, the
   hierarchy in which a child key reveals nothing about a sibling. Both read
   `unminted`. **Unopened, and it holds no arc file.**
4. **Every plaintext exit is one named call and the count is published.**
   Observed by `lib/capability/secret.chiral:41`'s `secret-reveal` staying the
   only extern that yields `Bytes` out of a `Secret`, and by a grep for it over
   the tool's sources returning the number the tool's own doc states.
   `prog/demo/passman-min.chiral` has one such site, reached through
   `send-revealed` at `lib/capability/secret.chiral:53`. **Unopened, and it
   holds no arc file.**
5. **The custody type executes rather than only type-checking.** Observed by
   `bin/chirality compile` accepting a root whose `compile-main` reaches
   `secret-seal`, `secret-reveal` and `secret-wipe`, declared at
   `lib/capability/secret.chiral:36`, `:41` and `:45`, and by that binary
   running to an exit a caller judges. Today the compile refuses with
   `extern does not lower: secret-seal`, measured 2026-09-23 by
   `docs/arcs/custody-executes-arc.md`, and two independent gates produce that
   refusal: the front peel at `lib/lowering/compile-front.chiral:37-45`
   classifies no carrier for `Secret`, and neither the 44-row crossing table at
   `lib/lowering/tal/crossing-wraps.chiral:14-57` nor the 24-row peel table at
   `lib/lowering/tal/erase.chiral:112-143` names one of the three. Which of the
   two routes custody takes is `custody-executes/CU1`, so this condition names
   neither. [[arcs/custody-executes-arc]] holds it.

⚑ **Condition 5 gave the crossing table 45 rows and it holds 44, and it made a
crossing row the observable when a crossing row is one of two routes.** Measured
2026-09-23: `grep -c '(cons (pair' lib/lowering/tal/crossing-wraps.chiral`
answers 44 over `:14-57` and `docs/arcs/sys-face-arc.md:178` reads the same 44.
The 45 is the count of closing parentheses on `:58`, one of which closes the
`def`. `records/author-calls.md:52` carries the same 45 uncorrected. The route
half is `adopt-fd`, declared `(=> I64 Fd)` at `lib/ports/fd.port:32`, which
executes and appears in no row of the crossing table because it lowers through
the identity peel at `lib/lowering/tal/erase.chiral:120`. If
`custody-executes/CU1` rules for that route, the old observable goes red on a
build that satisfies the condition.

## Arcs

One open. [[arcs/custody-executes-arc]] opened 2026-09-23 on condition 5, the
first of the five to take an arc, with seven rows `CU1` to `CU7` all `open` and
none designed. Its `## Which rows the scope call governs` at
`docs/arcs/custody-executes-arc.md:191` sorts those rows against the author call
at `records/author-calls.md:52`, and `CU1` is the only one schedulable whichever
way that call goes.

Conditions 1 to 4 hold no arc, and this is **not** the standing-gate shape
[[goals/self-hosting]] conditions 1 to 3 carry. No rule that already runs
maintains any of the four on every change. The absence is scheduling owed, and
the first honest limit below prices it.

The nearest scheduled work sits under another goal.
[[arcs/crypto-primitives-arc]] holds every primitive conditions 2 and 3 name,
serving [[goals/own-web]] condition 4, so its `goal` field points there and this
goal gains no arc from it. The precedent for naming a cross-goal dependency
without claiming the arc is [[goals/emitted-speed]], which reads
[[arcs/memory-discipline-arc]] the same way under [[goals/local-ai]].

This section carries no element rows and no roster.

## State

Stated 2026-09-23, unbuilt, with one 32-line fragment standing.

| what exists | measured 2026-09-23 |
|---|---|
| `lib/capability/secret.chiral` | 56 lines: `porttype Secret`, three externs, `send-revealed` as the sole legal path |
| `prog/demo/passman-min.chiral` | 32 lines, type-checks, run by no suite phase |
| `lib/crypto/` | ChaCha20 at 163 lines and Poly1305 at 245 lines, gated as suite phase 31 by `tools/test/run-tests.sh:367` |
| `tools/test/samples/e170_reject_secret_leak.prog` | 30 lines, named by no line of `tools/test/*.sh` |
| the primitives conditions 2 and 3 need | seven rows, `crypto-primitives/K4`, `K19`, `K26`, `K30`, `K34`, `K35` and `K36`, every one `open` and `unminted` |
| a collision-resistant digest | absent. `docs/arcs/crypto-primitives-arc.md:62` states it has no module anywhere |

`E40`'s state has two readings and they disagree. `docs/elements/ledger.md:234`
carries the coarse state `built`. `docs/definitions/status-ledger.md:195`
records the same slice as **type-level discipline only**, and `records/conformance-map.md:126`
reads *"SEEDED slice conforms as far as it claims"*. The ledger's own header
hands the authority to the conformance map, so the honest state of the custody
slice is SEEDED.

### The scope verdict

`E40` is filed `OT` at `docs/elements/ledger.md:234` and
[[decisions/decision-scope]] build-defers that track. Three readings decide
whether this goal is in current scope, and two of them are settled in tracked
text.

| question | authority | verdict |
|---|---|---|
| may the goal be opened at all | [[decisions/decision-scope]], amended 2026-09-13, splits `build-deferred` from `plan-deferred` and carries only the first | **yes.** A goal, a roster row, a design and a SPEC for an `OT` element are all planning |
| is the crypto half in current build scope | [[records/crypto-primitives]] `CP-02` reads `docs/decisions/decision-deployment-custody.md:61` as *"what keeps the password KDF inside scope"* | **yes.** [[arcs/crypto-primitives-arc]] is open and worked under [[goals/own-web]] |
| is `E40`'s remaining custody build in current build scope | nothing | **undecided**, and it is an author call |

The third row is the live one. What `E40` still owes this goal is the lowering
of its three externs and the memory custody [[status-ledger]] records as absent,
and both are `OT` work. The rung-1 placement at
`docs/decisions/decision-deployment-custody.md:61-62` is evidence that the
software key levels come forward, and a rung is the hardware ladder in
[[trust-boundary]] while the track is a scope call in
[[decisions/decision-scope]]. No tracked decision joins them, so the call
belongs to the author and [[records/author-calls]] carries the row.

## Honest limits

- **The blocker is a layer being built, and no decision stands in the way.**
  Conditions 2 and 3 name seven rows in [[arcs/crypto-primitives-arc]] and every
  one of the seven reads `unminted`, as do all 36 rows in that arc. Each is its
  own `element-design` dispatch before anything is minted, so the distance is
  seven design runs and their builds, counted and not estimated.
- **A collision-resistant digest is absent from the whole tree.** `lib/crypto/`
  holds a stream cipher and a one-time MAC. Nothing in it hashes, so the vault
  format of condition 2 has no integrity primitive to name yet.
- **The custody type type-checks and does not execute, and two gates stop it
  independently.** The carrier gate refuses first: `porttype-word?` at
  `lib/lowering/compile-front.chiral:37-45` names six types and `porttype-str?`
  at `:52-55` names one, `Secret` is in neither, so `term->ntalty` at `:60-72`
  answers `(none)` and `prim->n` at `:326-333` drops all three externs before
  any routing table is read. The routing gate refuses second: the 44-row
  crossing table at `lib/lowering/tal/crossing-wraps.chiral:14-57` and the
  24-row peel table at `lib/lowering/tal/erase.chiral:112-143` name none of the
  three. `docs/arcs/custody-executes-arc.md` measured both 2026-09-23 by probe.
  That is condition 5, [[arcs/custody-executes-arc]] holds it, and the author
  call in `## State` sorts its rows as `## Arcs` records.
- **Nothing gates the rejection the goal is named for.**
  `tools/test/samples/e170_reject_secret_leak.prog` is a fixture with no runner,
  which makes condition 1 a claim held by a file rather than by a gate.
- **Rung 1 cannot make the guarantee the title implies.**
  `docs/definitions/trust-boundary.md:127-129` states that under a preemptive
  kernel the tree does not control there is no register custody, keys spill to
  RAM on a context switch, and secret custody stays OS-trusted until rung 2. So "cannot leak its vault" is a
  statement about what the program can express, and it says nothing about a
  reader of the process's memory.
- **`ledger-lint` check AF reads this goal now and it passes.** The check adds
  a goal whose `docs/goals/README.md` arcs cell opens `none open` to its
  `gated` set and skips its done-conditions,
  `tools/ledger-lint/ledger-lint.py:1993-1998`. That cell names
  [[arcs/custody-executes-arc]] as of 2026-09-23, so the skip is gone.
  Condition 5 names its arc, which `:2019` reads, and conditions 1 to 4 carry
  the **unopened** mark, which `:2017` reads.
- **The author's phrase reaches wider than the five conditions.** *"storing
  things"* is wider than passwords, and the conditions are written for entries
  of bytes. Whether a vault entry is a typed value with a declared form, the
  shape [[goals/own-web]] condition 1 gives a document, is unruled here.
- **The store under [[goals/native-stack]] is a different object.** That goal's
  condition 4 seals a value and splits it t of n by Shamir so nothing
  authoritative sits whole in one place. This goal's store is the per-instance
  custody `docs/decisions/decision-deployment-custody.md:29` rules, one holder
  and a derived key. The two share the crypto layer and share no condition.
