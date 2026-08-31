---
node: modules-lowering
layer: module
implements: [category-typed, category-bridge]
refines: [axis-altitude]
related: [module-map, modules-staging, decision-backend, modules-substrate, joining-law]
status: draft
updated: 2026-06-16
---

# Lowering modules

The lower stratum: the typed assembly floor, the path down to it, and the proof
that the path keeps the type. This is where the no untyped bottom rule from
[[axis-altitude]] is enforced.

## tal, typed assembly

The lowest IR, and it carries types. It has its own A, B, C: typed instructions
(proof), raw or unsafe instructions such as the literal store to a device
register (B), and guarded sequences such as the bounded preemption disabled
critical window (C). The dumps reach this independently: asm as surface is the
floor, not a tier, with no erasure point in the user facing stack (dump C12).
What is new versus prior typed assembly work is that this floor is human writable
and keeps raw hardware access. Where exactly the instruction vocabulary is drawn
is an open edge; see [[open-edges]].

## translate and lower

The lowering chain: upper core, to mid IR, to tal, to machine code. Each step is
type preserving or type refining. It may sharpen the A, B, C structure; it may
never erase it.

Together with `preserve-check` this is the lowering connector of the
[[joining-law]]: the across-altitude join, upper to lower, whose preserved
invariant is the type. An erasing lowering is the connector's one failure mode,
the untyped bottom.

## preserve-check

The proof that a lowering step opened no hole. This is the lower stratum's
version of the type checker, and it is how no untyped bottom is verified rather
than asserted. Its first concrete customer is `constant-time` in
[[modules-security]], which is checked at lowering.

## Where erasure goes

Erasure does not vanish. It relocates into one trusted, machine code emission
step below tal that the programmer never edits. Preservation is checked all the
way down to tal; below tal is physics. That single emission step is the only
erasure site, and it sits inside the trusted base.

## cheri-floor

Optional. Where CHERI or equivalent tagged capability hardware exists, the B type
mark is enforced in silicon, so the membrane declared in a signature is also real
at the metal. This is the only thing that makes B typed at the very bottom rather
than only above tal. It is an additive multiplier, not a requirement: the type
level mark holds without it. This is consistent with the secure datum model,
where hardware adds prevention on top of the portable floor. See
[[category-untyped]] and [[decision-b-in-type]].

## Backend

The codegen below tal is the chirality-authored Mach path: a target-independent
emitter (`emit-core`) over a frozen target interface (`Mach`), with each hardware
target a conforming implementation admitted under [[floor-agreement]]
(reconciled 2026-07-22 — no LLVM/Cranelift/QBE in the trusted path; they remain
encoding cross-check oracles only). It never round trips through C source, which
would be an untyped bottom. See [[decision-backend]].
