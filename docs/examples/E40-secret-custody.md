---
element: E40
slug: secret-custody
title: Secret custody — opaque linear Secret with a single guarded exit
kind: BUILD-PROPER
reference_class: PAPER
ours_source: scaffold/lib/ports.chiral
status: implemented
updated: 2026-07-15
---

# E40 — Secret custody (opaque linear `Secret` with a single guarded exit)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

> Scoping note: E40 in the catalog is the *full* capability/permission model
> (grants, revocation, delegate, Adhikara-over-wire). This pre-run scopes the
> **minimal custody slice** of it: a value that structurally cannot be leaked to
> an ungoverned port, built on machinery that *already exists* with no new type
> theory. It is the fundable Bucket-2 proof deliverable; the full E40 (who may
> reveal, revocation, information-flow labels) stays deferred.

> Implemented 2026-07-15 (`.planning/quick/260715-6jx-secret-custody/`). One
> change from the §5 snippet below: `secret-reveal` returns a `RevealR` wrapper,
> not bare `Bytes`. Bare `Bytes` cannot feed `sock-send` (whose `Bytes` slot is
> unrestricted `w`) out of a linear `Secret` without forcing the `Secret` to `w`
> too — an impossibility. The wrapper is the idiom `ports.chiral` already uses for
> every port result (`RecvR`/`AccR`/`PoolR`): `case` it to bind the plaintext as
> an ordinary `w` field. This is the scope's own "Knobs" variant, and needed no
> change to `ports.chiral`. Lives in `scaffold/lib/secret.chiral` +
> `scaffold/chirality/impl_ports.py` + `scaffold/demo/passman-min.chiral`;
> `scaffold/tests/test_secret.py` (9 tests) green, full suite 281 green.

## 1. Scope

- **Element:** the minimal custody primitive — an opaque, move-only `Secret`
  whose plaintext bytes are reachable *only* through one named, auditable
  `secret-reveal`, so passing a secret to `sock-send`, a log, or a model call is
  a **compile-time type error**.
- **Kind:** BUILD-PROPER — a designed-but-unbuilt feature (the capability
  family), scoped to the smallest version that is real.
- **Why chirality needs its own:** this is P3/P4 for data — "compute is inert until
  it crosses a port," applied to a secret. On a normal stack a decrypted secret
  is just bytes and nothing structurally stops it flowing to a socket. The whole
  point of chirality is that the leak is *not expressible*, not *defended against*.
  This primitive is the smallest artifact that demonstrates that claim on a
  problem a person understands (a password manager that cannot leak its vault).

## 2. Research

- **Reference class:** PAPER — object-capabilities and sealed abstractions.
  Reviewed the *shape*, grounded against `scaffold/lib/ports.chiral`:
  sealer/unsealer pairs (Morris 1973), the object-capability model (Miller,
  *Robust Composition*), abstract data types (Liskov/CLU — a type whose
  representation is hidden so its only operations are the exported ones), and the
  practical Haskell `newtype`-with-hidden-constructor secret idiom.
- **Key findings:**
  - **A sealer is exactly "an opaque type whose only eliminator is a designated
    function."** That is the classic confinement primitive: you can hold the
    sealed thing, pass it around, store it — but you cannot look inside except
    through the one unsealer. Confinement is structural, not a runtime check.
  - **chirality's `porttype` already *is* a sealer.** `ports.chiral` documents it:
    "porttype introduces an opaque linear atom: the kernel learns nothing about
    it except that it exists and that B-ness lives in the type." No public data
    constructor exists, so you **cannot `case` it open**; the only operations are
    the `extern`s whose types name it (exactly how `Sock`/`Fd`/`Pool` work). So
    the sealer needs **no new type-system feature** — it is a naming exercise
    over machinery the scaffold ships.
  - **Linearity comes free with the porttype.** A porttype value "can only ever
    be bound with quantity 1," so a `Secret` also cannot be silently duplicated
    or dropped — the Phase-0 no-copy/no-drop property is inherited, not rebuilt.
  - **The honest limit is the reveal boundary.** Once `secret-reveal` yields
    `Bytes`, chirality no longer tracks those bytes. So the guarantee is "plaintext
    appears only at named, greppable reveal sites" — the leak surface is *reduced
    to auditable points*, not *proven never to reach a socket*. That stronger
    property is information-flow labelling (E44), deliberately deferred.

## 3. Conventional (other-language) approach

How this is done outside chirality — a decrypted secret is ordinary bytes.

```python
# A password manager in the normal world: the plaintext is just a value.
pw = vault.decrypt(entry)        # -> bytes
sock.send(pw)                    # compiles, runs, leaks. nothing objects.
log.debug(f"unlocked {pw!r}")    # also fine. also a breach.
```

- **Assumptions it bakes in:** the secret has the *same type* as any other bytes,
  so every sink that accepts bytes accepts the secret. Non-leakage is a matter of
  developer discipline, reviewed by hand, enforced by nothing. Garbage collection
  copies it, logs capture it, and there is no point in the type system where the
  wrong move becomes impossible rather than merely inadvisable.

## 4. The chirality idea

- **Chirality features in play:** `porttype` (opaque linear atom — the sealer); QTT
  linearity (move-only, no copy/drop); the effect membrane (`=>` on the reveal so
  the plaintext-producing step is on the process side and greppable); categories
  A/B/C (the secret's bytes are a B referent, reachable only through the typed C
  crossing that is `secret-reveal`).
- **The reframing:** the secret is not `Bytes`. It is `Secret`, an opaque type
  with no constructor. Every ordinary sink — `sock-send`, `put`, a model call —
  is typed to take `Bytes`. Since `Secret` is not `Bytes` and cannot be coerced
  (no constructor to open it), *the sink cannot accept it*. The **only** bridge
  from `Secret` to `Bytes` is `secret-reveal`, so the plaintext exists in the
  program at exactly the call sites where someone wrote that word.
- **What chirality makes impossible here:** `(sock-send s a-secret)` does not
  type-check — full stop, at elaboration, not at review time. You also cannot
  duplicate a `Secret` to keep one copy while sending another (linear), and you
  cannot silently forget one (linear: unused is rejected). The conventional
  freedom removed is "a secret is just bytes you can put anywhere."

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
; lib/secret.chiral — the minimal custody primitive. No new kernel feature:
; Secret is a porttype (opaque, linear) exactly like Sock/Fd in ports.chiral.

(import "prelude")   ; Bytes, Unit
(import "ports")     ; Sock, sock-send, put

; ---- the sealed type -------------------------------------------------------
; Opaque linear atom. No constructor exists, so no `case` can prise out its
; bytes; the kernel holds every caller to move-only threading automatically.
(porttype Secret)

; ---- the ONLY operations that mention Secret --------------------------------
; seal: wrap already-plaintext Bytes into a Secret (real vaults would load from
; an Fd so plaintext never appears loose — see Knobs). Effectful: it is a
; category-C crossing that mints a capability-shaped value.
(extern secret-seal   (=> Bytes Secret))

; reveal: the single guarded exit. Consumes the Secret (linear) and yields the
; plaintext. THIS is the one place `Bytes` come back — audit by grepping the
; one name. Returns the plaintext; host impl zeroes its own copy on the way out.
(extern secret-reveal (=> (1 s Secret) Bytes))

; wipe: discharge a Secret you decide not to use. Linearity forbids dropping it
; silently, so this is how a secret leaves scope without being revealed.
(extern secret-wipe   (=> (1 s Secret) Unit))

; ---- the DEMO: the leak that will not compile ------------------------------
; This is the proof. `sock-send : (=> (1 s Sock) Bytes Sock)` wants Bytes in its
; second slot; `pw : Secret` is not Bytes and cannot be coerced. TYPE ERROR at
; the application site, before anything runs.
;
;   (def leak (=> (1 pw Secret) (1 s Sock) Sock)
;     (lam (pw s) (sock-send s pw)))         ; <-- rejected: expected Bytes, got Secret
;
; (kept commented so the module still loads; the test asserts it is rejected.)

; ---- the DEMO twin: compiles, because it uses the exit ----------------------
; Legal: reveal turns the Secret into Bytes at one named, auditable point, then
; the ordinary sink accepts them. Consumes pw (in reveal) and s (in send).
(def send-revealed (=> (1 pw Secret) (1 s Sock) Sock)
  (lam (pw s)
    (do (<- bytes (secret-reveal pw))        ; the single audited Secret -> Bytes
        (sock-send s bytes))))

; a secret that is sealed and never used at all is ALSO rejected (linear, unused):
;   (def forget (=> Bytes Unit) (lam (b) (do (<- s (secret-seal b)) unit)))  ; <-- rejected
```

- **Knobs to modify:** replace `secret-seal (=> Bytes Secret)` with
  `secret-load (=> (1 f Fd) Secret)` so plaintext is never even a loose `Bytes`
  in chirality-land; make `secret-reveal` hand the `Secret` back alongside the bytes
  (`(=> (1 s Secret) RevealR)` with `(data RevealR () (reveal-r (bs Bytes) (1 s Secret)))`)
  for multi-use instead of one-shot; add `secret-eq` for constant-time compare
  (Phase 3) as another operation that never yields the bytes.
- **Deliberately omitted:** the KDF/AEAD crypto (seal takes already-plaintext
  bytes — decryption is a separate dependency, out of scope for the *type-level*
  custody claim); information-flow tracking of the revealed bytes (E44 — this
  primitive reduces the leak surface to named exits, it does not eliminate it);
  who-may-reveal access control and revocation (the full E40); the native
  backend and lowering (the guarantee is a `check`-time property — nothing needs
  to run to demonstrate the rejection).

## 6. Use / modify notes

- **Lands in:** a new `scaffold/lib/secret.chiral` (the `porttype` + the three
  extern signatures), plus ~15 lines of host binding in
  `scaffold/chirality/impl_ports.py` (`secret-seal` stores the bytes behind a handle;
  `secret-reveal` returns them and zeroes the host copy; `secret-wipe` zeroes and
  drops), plus a demo `scaffold/demo/passman-min.chiral`.
- **Conformance target:** the golden behaviour to reproduce —
  (a) the `leak` def is **rejected** by `python3 -m chirality check` with a type error
  at the `sock-send` site (expected `Bytes`, got `Secret`);
  (b) `send-revealed` is **accepted**, and run on the reference interpreter it
  actually sends the revealed bytes;
  (c) a def that seals and never reveals/wipes is **rejected** (linear, unused),
  and one that reveals twice is **rejected** (linear, used-twice) — reuse the
  existing `test_kernel.py` linear machinery, pointed at `Secret`.
  This is the whole NLnet Milestone-1 proof: *watch the checker refuse the leak.*
- **Open questions:** does reveal one-shot-consume (hygiene) or return the secret
  (ergonomics)? Should `secret-seal` be barred in favour of `secret-load` from an
  Fd from day one, so plaintext never appears as loose `Bytes` even briefly? Is a
  scoped `with-secret` bracket worth adding before there is module privacy (in a
  flat namespace it adds no *enforcement* over raw reveal — it is ergonomics
  until E49 gives real modules)?
- **Related:** [[E12-effect-membrane]] (the `=>` the reveal rides on),
  [[E44-noninterference]] (the information-flow upgrade that would track the
  revealed bytes), [[E49-real-surface-syntax]] (module privacy that would let
  `secret-reveal` be access-controlled, not just single-named).
