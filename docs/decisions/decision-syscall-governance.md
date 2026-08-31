---
node: decision-syscall-governance
layer: decision
related: [trust-boundary, modules-substrate, permission-model, axis-typeability, node-architecture, open-edges]
status: settled
updated: 2026-07-28
---

# Decision: the syscall surface is closed by default-deny at an enforced chokepoint, not by enumerating it

## The contradiction

The self-hosted floor performs ~a dozen syscalls (`lib/sys-tal.chiral`); Linux
exposes 362 (`docs/syscall-map.md`). Two wrong readings of that gap were both
written and both retracted (2026-07-28): "we cross 12 and the rest are not
owed" (false — it is the seccomp-hole [[PRINCIPLES]] P1 names: a model that
covers only what it remembers has a hole at what it forgot), and "the other
339 are open ungoverned holes" (false the other way — no crossing exists for
them, so ordinary compiled chirality cannot invoke them). Neither is the real
state, and neither says what governance actually requires.

## The decision

**The whole surface is governed by default-deny at a single enforced
chokepoint — NOT by giving 362 syscalls typed names.** Enumerating the table
would be the "longer denylist" P1 explicitly rejects. Deny-by-default *is* a
model that covers the whole surface: everything not named is denied.

Concretely, three mechanisms, in dependency order:

1. **The chokepoint binds name to number and rejects the unregistered.**
   `ti-sys` already takes an immediate number and is confined to
   `sysface`-marked crossings ([[trust-boundary]]). Today that confinement is a
   *naming* rule (`nb-sys-*`), which does not check the number — a crossing
   named `nb-sys-write` could carry `ti-sys … 2` (open). The chokepoint becomes
   an **enumerated registry**: every `ti-sys` number must equal its crossing's
   registered number, and a `sys` op in any unregistered function is rejected at
   tal-check. The registry is the *permitted set*; a profile bounds it further
   (a profile may permit a subset of the built crossings, never a syscall no
   crossing declares). **Element E76.**

2. **On rung 1, the OS enforces the same set.** Rung 1 runs *on* Linux, so the
   process could issue a syscall through a non-chirality path (a native-codegen bug,
   the ctypes shuttle). A **seccomp-bpf default-deny filter, derived from the
   permitted set, installed at process start**, makes the kernel itself refuse
   everything the model does not name — the belt-and-suspenders that converts
   the type-level chokepoint into an OS-level one. On rung 2 this vanishes:
   chirality is the kernel and simply does not implement the unpermitted calls.
   **Element E77.**

3. **The number rides the type, so a profile attenuates per component.** The
   `ti-sys` immediate carried in a refinement ([[open-edges]] E9 machinery over
   the number) lets a profile say *which* syscalls a component may reach —
   `write` but not `socket` — as a subtyping/attenuation fact, not a runtime
   check. This is the capability discipline ([[permission-model]]) reaching the
   floor. **Element E78.**

## Why this resolves it

The number is small on purpose. The *performed* set (crossings hand-written as
programs need them) is dozens and grows; the *governance closure* over the whole
362 is **these three mechanisms, not 300-odd wrappers**. "Deny by default means
everything" (P1) is achieved by absence-plus-chokepoint, which is exactly a
model that covers the whole surface — the unwritten calls are denied, not
forgotten. The tiering is honest: E76 closes the type-level surface, E77 closes
the OS-level surface on rung 1, E78 is the per-component attenuation the
capability model already implies.

## Principle basis

P1 — *"the fix is never a longer denylist; it is a model that covers the whole
surface, so 'deny by default' actually means everything."* This note is that
sentence made mechanical: the chokepoint is the model, default-deny is the
coverage, and enumeration is the antipattern it avoids. P3 — the syscall
crossing set is a governance surface (the port set at the floor). P4 — the safe
shape (only registered, profile-permitted crossings) is the cheap default;
reaching an unpermitted syscall does not type-check and does not run.

## What is settled vs owed

- **Settled here (author-ratified 2026-07-28):** the three-mechanism model and
  that the surface is closed by default-deny, not enumeration. The scope
  question ("do we model 362?") is answered: **no.**
- **Owed (the elements):** E76 (chokepoint — the first slice, name↔number
  binding + registry, lands with this note; the profile-permitted-subset and
  the load-time gate follow), E77 (rung-1 seccomp), E78 (number-in-type
  attenuation). Per-profile syscall *policy* (which subset each profile permits)
  is profile-author taste, not settled here.

## Relationship to the other notes

- [[trust-boundary]] WATCH-equivalent: this note is what closes "the `sys`
  instruction carries an arbitrary numeric immediate; only the confinement mark
  gates it." E76 is the "closed by type, not by number" mechanism it named.
- [[permission-model]] / [[node-architecture]]: a permitted syscall is a
  crossing in a profile's port set; E78 makes that reach the raw floor.
- `docs/syscall-map.md` is the live coverage ledger; this note is why the
  UNMODELED count is correct-by-design, not a backlog.
