> **ARCHIVED 2026-09-01. Superseded by `docs/examples/E40-secret-custody.md`, tracked, which carries the same content including the funding-milestone framing and the deferred secret-load / secret-eq / module-privacy list.**

---
task: 260715-6jx
slug: secret-custody
element: E40
date: 2026-07-15
status: complete
---

# E40 — Secret custody (minimal slice) — SUMMARY

Built the minimal custody primitive scoped in `examples/E40-secret-custody.md`:
an opaque, move-only `Secret` whose plaintext is reachable only through one
audited exit, so leaking it to a port is a compile-time type error. This is the
NLnet Milestone-1 proof: *watch the checker refuse the leak.*

## What landed

- `scaffold/lib/secret.chiral` — `(porttype Secret)` (opaque linear atom, like
  `Sock`/`Fd`), a `RevealR` result wrapper, three externs (`secret-seal`,
  `secret-reveal`, `secret-wipe`), and the `send-revealed` demo def.
- `scaffold/chirality/impl_ports.py` — host bindings behind the membrane. A Secret
  is the runtime value `("secret", bytearray)`; `secret-reveal` returns the
  plaintext (wrapped in `reveal-r`) and zeroes its own copy; `secret-wipe`
  zeroes and drops.
- `scaffold/demo/passman-min.chiral` — the proof in miniature: the `leak` def
  kept COMMENTED as the rejected case, plus `unlock-and-send` (seal → reveal at
  the one exit → send) that type-checks.
- `scaffold/tests/test_secret.py` — 9 tests, all green.

## Conformance target — met

- (a) leak `(sock-send s pw)` **rejected** — type mismatch, message names both
  `Bytes` and `Secret`.
- (b) `send-revealed` / a fresh reveal-then-send **accepted**; `secret-wipe`
  accepted.
- (c) sealed-but-never-used **rejected** (`declared 1 but used 0`).
- (d) secret revealed twice **rejected** (`binder pw declared 1 but used w`).
- (e) `send-revealed` **runs** on the reference interpreter: peer socket
  receives `b"hunter2"`, the returned Sock is the moved port, and the host copy
  behind the Secret is zeroed after reveal.

Full suite: **281 passed, 0 regressions** (`python3 -m unittest discover -s tests`).

## Design deviation from the scope (honest note)

The scope's snippet had `secret-reveal : (=> (1 s Secret) Bytes)` and a
`(do (<- bytes (secret-reveal pw)) (sock-send s bytes))`. That does **not**
type-check against the real `sock-send`: its `Bytes` argument is unannotated, so
QTT defaults it to quantity `w`. Feeding a `do`-bound (linear, quantity-1)
result into a `w` slot forces the usage back to `w`, and since a `Secret` is a
porttype it can only be bound at `1` — an actual impossibility, not a typo.

The fix is the idiom the port floor already uses everywhere: **every** result in
`lib/ports.chiral` (`RecvR`, `AccR`, `PoolR`) is a data wrapper, precisely so an
unrestricted value can escape a linear effect. `secret-reveal` now returns a
`RevealR`; `case`-ing it binds the plaintext as an ordinary (w) `Bytes` field,
which the stock `sock-send` accepts, with no change to `ports.chiral` and no new
send primitive. This matches the scope's own "Knobs" note (the `RevealR`
variant) and is arguably the more correct design: `secret-reveal` joins the
port-result family. The audited exit is now "grep `secret-reveal` / `reveal-r`."

## Honest limits (not overclaimed in code or comments)

- The guarantee is **type-level**, against a well-behaved program, on the
  CPython + OS base.
- Once revealed, the `Bytes` are ordinary and untracked — the leak surface is
  **reduced to named exits, not eliminated** (that stronger property is
  information-flow labelling, E44, deferred).
- **No crypto**: `secret-seal` takes already-plaintext bytes; sealing is custody,
  not encryption (KDF/AEAD is a separate dependency).
- Who-may-reveal / revocation (the full E40) remain deferred.

## Notes

- No git repo in-tree (per project convention) — no commits; changes are live in
  `scaffold/`.
- Deferred next steps for the fundable package: information-flow upgrade (E44),
  `secret-load` from an `Fd` so plaintext is never loose `Bytes`, constant-time
  `secret-eq`, and module privacy (E49) to access-control the reveal.
