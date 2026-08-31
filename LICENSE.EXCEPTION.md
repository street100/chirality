# Chirality Runtime Exception

**Version 1.0, 2026-08-31.**

Additional permission under section 7 of the GNU Affero General Public License,
version 3 ("AGPLv3"), granted by the copyright holder of the Chirality
Programming Language.

## Why this exists

The chirality compiler resolves a program's imports and concatenates them into
one compilation unit, so the emitted binary contains parts of this work: the
prelude, the port floor, and whatever library modules the program imported.
Without this exception, every program compiled by chirality would be a
derivative work of chirality and would have to be licensed under AGPLv3.

That is not the intent. The license this replaced granted, in as many words,
the right to "building, running, and distributing your own works created with
the Licensed Work." This exception carries that grant across.

## The grant

You have permission to propagate a work formed by combining the Chirality
Runtime Library with a work you have written ("your program"), and to convey the
resulting work under terms of your choice, provided that your program is not
itself a chirality compiler or a modified version of one.

When you do so, the terms of AGPLv3 continue to apply to the Chirality Runtime
Library itself and to any modifications you make to it. Nothing here weakens
your obligations for the parts of this work you changed.

## The Chirality Runtime Library

For the purposes of this exception, the **Chirality Runtime Library** is the set
of modules the compiler resolves into a user program's compilation unit rather
than into the compiler's own: everything under `lib/`, including `lib/prelude/`,
`lib/ports/`, `lib/protocol/`, `lib/memory/`, `lib/runtime/`, `lib/capability/`
and `lib/evidence/`.

It does **not** include `lib/typing/`, `lib/surface/`, `lib/module/` or
`lib/lowering/`. Those are the language implementation. `LAYOUT.md` marks them
"language-implementation only", and a work containing them is a compiler.

## What is not excepted

Conveying the compiler itself, modified or unmodified, is governed by AGPLv3
with no exception. Offering the compiler to third parties over a network is the
case AGPLv3 section 13 exists for, and section 13 applies in full.

---

⚑ **Not reviewed by a lawyer.** This is modeled on the well-precedented Bison
parser exception and the GNU Classpath exception, both of which solve the same
problem for the same reason. The boundary in "The Chirality Runtime Library"
above is drawn from `LAYOUT.md`'s own two tiers, so it moves if that contract
moves. Have counsel read it before relying on it commercially.
