---
node: insp-emacs
layer: application
related: [live-environment, insp-smalltalk, splitting-law, axis-typeability, open-edges]
status: draft
updated: 2026-07-20
---

# Emacs

The residential ideal narrowed to a text editor, and the most familiar member of
the lineage. Its command loop reads an event, looks it up in a keymap, and calls a
command written in the same Lisp you extend it in. Modes are bundles of
buffer-local state and keymaps. Packages load into the running image and redefine
whatever they like.

**Lights up:** the residential invariant of [[live-environment]] at the interface
layer. The command-loop-plus-registry shape maps onto a dispatch process over a
named-op registry, and "extend it live in its own language" is the whole point.

**chirality takes:** the dispatch/registry shape (a keymap is a registry lookup;
`M-x` is a named op), self-documentation, and extension as the normal act.

**chirality rejects three things at once:** the single thread (a slow command freezes
everything; on the mesh a slow op runs in its own node and the loop polls),
text-as-universal-substrate (uniformity moves to the port, not the data,
[[axis-typeability]]), and the empty floor (any package can do anything; chirality
draws open-edge 5). A mode becomes a profile with a frozen port set, decided by
the [[splitting-law]], not a pile of buffer-local variables.
