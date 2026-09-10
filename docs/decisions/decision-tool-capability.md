---
node: decision-tool-capability
layer: decision
status: DECIDED
decided: 2026-09-09
related: [decisions/decision-orchestration-boundary, decisions/decision-syscall-governance, decisions/decision-scope, decisions/decision-lane-split, decisions/decision-work-ids, banks/capability, permission-model, elements/catalog, records/author-calls, working-discipline, index]
updated: 2026-09-09
---

# Decision: a tool is represented through the name-to-descriptor boundary

**Decided 2026-09-09.** Read this before adding a tool to a consumer prog, and
before reaching for the refinement engine to scope one.

[[decisions/decision-orchestration-boundary]] put the tool layer on the consumer
side and left what a tool *is* to the language open under its heading `What this
does not rule on / Tools`. This document starts where that stopped.

## The decision

### 1. A tool falls outside the language-level crossing test

`MAP.md:64-67` gives the test. A file belongs in `ports/` iff it declares a
crossing: an `extern` whose implementation is bound at link time, or a
`porttype` minting an opaque linear atom. `MAP.md:69` adds that being *about*
ports does not qualify, and `MAP.md:75-77` names the three files moved out for
exactly that reason: `crossing-wraps` to `lowering/tal/`, `inet` and `term` to
`protocol/`.

The built tools sit on the far side of that test. `prog/shilpa/tools-fs.chiral`
is 96 lines carrying two imports, `prelude/prelude` and `ports/ports` at
`:21-22`, and zero externs. `fs-edit` at `:88` declares nothing and reaches
every crossing through `fs-read` and `fs-write`.

The relation closes in neither direction. Most crossings serve no tool:
`nb-winsz-raw` at `lib/ports/tty.port:26` and `sock-send` at
`lib/ports/sock.port:67` are two of the 51 externs across the nine registries.
Some tools cross nothing at all: a calculator, a scratchpad, an in-memory
lookup.

### 2. The one thing every tool is represented through is naming authority

`lib/ports/file.port:3-7` already states the seam, in text written before this
decision:

```
; The two openat crossings are the only place in the port floor where a NAME
; becomes a descriptor. They are deliberately their own registry: naming
; `open-rw` is a strictly larger authority than naming `read`/`write-fd`, and a
; module that only shuffles already-open descriptors should not be able to
; reach for a path.
```

`lib/ports/fd.port:9-12` names the mechanism that carries it:

```
; What a registry buys is a NAMING boundary — which crossings a module may
; name — not a smaller binary: `native-lib ++ link-lib` is appended
; unconditionally at compile-emit.chiral:189, so importing one registry or all
; nine costs exactly the same bytes.
```

The registry separation is built and reasoned. Every tool is therefore
represented through one question: **may this hold turn a name into a descriptor,
or may it only operate on descriptors it was handed?**

### 3. The narrowing is structural, because it cannot be propositional

`lib/typing/refine.chiral:13-18` is the entire constraint language:

```
(data Constraint ()
  (constraint
    (lo  (Maybe I64))                  ; inclusive floor,  none = -inf
    (hi  (Maybe I64))                  ; inclusive ceiling, none = +inf
    (ex  (List I64))                   ; holes: forbidden values (v <> k)
    (sym (List (Pair SymOp I64)))))    ; symbolic bounds keyed by operand level
```

Five operators, `>= > <= < <>`, at `:11`. All numeric. `entails` at `:93`
decides integer intervals and holes and decides nothing else.

**So "scoped to this path prefix" falls outside every refinement this tree
can prove.** `(porttype Pool (n I64))` at `lib/ports/pool.port:13`
carries an index the engine can decide, because that index is an `I64`. A path
is a different kind of thing and the trick does not transfer to it.

[[decisions/decision-syscall-governance]] point 3 marks the line from the other
side. It puts the `ti-sys` immediate in a refinement so a profile can say which
syscalls a component may reach, and that design is sound because a syscall
number is an `I64`. The same construction over a path has nothing to stand on.

Security here is structural. You hold a descriptor or you do not. The other
reading, where you hold a path the checker proved was inside a subtree, is
unavailable while the fragment stays numeric. A reader coming to this problem
reaches for the refinement engine first; an earlier pass of this design did.
The engine is the wrong instrument for a path.

### 4. The goal toolset through that boundary

| tool | needs naming authority | otherwise needs |
|---|---|---|
| read | no, given an fd | `read` on a held `Fd` (`lib/ports/fd.port:34`) |
| write | no when overwriting a held fd, **yes to create** | `write-fd` (`lib/ports/fd.port:35`); creating a file is `open-create` |
| edit | no, given an fd | read, splice, write on one held `Fd` |
| grep | no, given fds | `read` plus `lib/text/matcher.chiral`, 602 lines, gated by suite Phase 19 (`tools/test/matcher.sh:2`), imported by `prog/prose-lint.prog:43` |
| ls | **yes** | enumeration. `E148` (`docs/elements/catalog.md:463`), `getdents64` plus `stat`, minted and unbuilt, zero `getdents` occurrences under `lib/` |
| find | **yes** | naming plus enumeration |
| bash | **yes, the most** | spawn, which resolves names and inherits descriptors |

**Three of the seven need no naming authority in any form, and a fourth needs
it only to create a file.** That is the payoff, and it is the finding this
decision rests on. The boundary falls inside the toolset, so most of the toolset
can be handed descriptors and stop there.

Two measurements qualify the table.

**The built spike hands every tool naming authority anyway.** `fs-read` at
`prog/shilpa/tools-fs.chiral:50` takes a `Str` path and calls `open-rw` itself at
`:52`; `fs-write` at `:62` takes a path and calls `open-create` at `:64`. The
header at `:11-13` records that `open-create` was chosen so the write tool can
create a new file. So the tools that need no naming authority hold it today, and
the table above describes the shape the tools can take rather than the shape
they have.

**The `write` row splits.** `docs/elements/catalog.md:464` mints `E149` for
filesystem mutation and says why the split from `E148` is on purpose: write
authority is its own grant, so a directory viewer need not hold the power to
delete. Overwriting a held descriptor and creating a name are two authorities,
and the goal toolset's single `write` tool spans both.

### 5. The registry boundary is a convention today

`MAP.md:86` says it: nothing checks the placement rule. The consequence for this
decision is measurable. **21 files outside `lib/ports/` declare an `extern`**,
and six of them re-declare a crossing that carries naming authority:
`prog/shilpa/turn.chiral:46` re-declares `raw-proc-spawn`, and five samples under
`prog/samples/` re-declare `open-rw`.

`prog/shilpa/turn.chiral:23-26` records why the agent does it: `tools-fs.chiral`
and `proc.chiral` both define a `nul-byte` global, so importing both collides in
the blob. The reason is good and the effect stands. A module reaches naming
authority by writing one line, and importing the narrow registry buys nothing
against a module willing to write it.

The `Fd` cap does not close this either. `adopt-fd` at `lib/ports/fd.port:32`
mints a linear `Fd` from any `I64`, and `:23-24` calls it trusted, with the
caller vouching that the fd is open and theirs. `read`, `write-fd` and `fcntl`
at `:34-36` take a raw `I64` and never see the cap. The linear `Fd` governs
closing exactly once. It does not govern reaching.

### 6. The crossing this tree lacks

`lib/ports/file.port:14-15` declares both openat crossings, and both take an
absolute NUL-terminated path:

```
(extern open-rw       (=> Bytes I64))     ; openat O_RDWR|O_NOCTTY, NUL-term path -> fd | -errno
(extern open-create   (=> Bytes I64))     ; openat O_RDWR|O_CREAT|O_TRUNC|O_NOCTTY|O_CLOEXEC, NUL-term path -> fd | -errno
```

**There is no dirfd-relative variant.** Every open starts at the process
namespace root, so "rooted at this subtree" is inexpressible today even
structurally, which is the one shape §3 leaves standing. This is the gap the
whole layer turns on.

Per [[working-discipline]]'s deferral rule, this document mints nothing and
names no `E#` for it. The absence is recorded without a number.

### 7. The two spawns have opposite shapes

| site | signature | what it takes |
|---|---|---|
| `lib/runtime/proc.chiral:110` | `raw-proc-spawn (=> Bytes SpawnRes)` | a NUL-framed argv packet. It resolves the program by name |
| `lib/ports/pty.port:47` | `spawn-in-pty (=> Bytes Bytes I64)` | ELF bytes and a slave path. You can spawn only what you already hold |

The pty spawn already has the capability shape. The proc spawn does not.
`prog/shilpa/turn.chiral:61-63` shows what the difference costs: `ag-bash` hands
`/bin/sh -c` and the model's string to `raw-proc-spawn`, which is the widest
authority in the tree reached from a tool schema.

This decision records the asymmetry and resolves nothing about it. Which shape
is the model is the third open call below.

## What attenuation exists, and that it is unwired

`lib/typing/kernel.chiral:796-798` describes the relation, and `:799` defines it:

```
; subtype = conversion + universe cumulativity + the VRefine rules (refine.py
; _subtype): refine<:refine = base-conv + entails; refine<:base = forget; base<:
; refine only if the refinement is trivial (TOP).
```

Narrow freely. Forget freely. Reach only ever shrinks. [[banks/capability]] records
what that buys today, at `:193-201`:

> **Build-state.** **The one live softness.** The subtype *mechanism* is
> IMPLEMENTED (`lib/typing/kernel.chiral:799`, cumulativity via subtype) but is
> **not yet applied to grant narrowing** … every piece exists, the wiring from
> `subtype` to grant-narrowing is the missing step.

`prog/prapanca/backend.chiral:56-57` is the built precedent for the other half.
`BePeekR` and `be-peek` derive a `Str` from a linear `Backend` while threading
the handle onward, in a pure arrow, through a `case` that accounts both binders
atomically. Any design where a holder derives a narrower capability without
losing its own starts from that shape.

## What this rejects

**A path-shaped parameter on a porttype.** `(porttype Pty)` at
`lib/ports/pty.port:14` takes no parameters, which is a real observation about
the port floor and is worth its line. Parameterizing it the way `Pool` is
parameterized is a different claim, and §3 disposes of it: `Pool`'s index is an
`I64` and the engine decides `I64`. An earlier pass of this design reached for
the refinement engine before checking that the fragment is integer-only.

**Gating on content.** Inspecting what is written to a terminal or handed to a
shell is what capability systems exist to avoid. It loses to quoting, to `$()`
and to `eval`, and it puts a parser of an adversary's input inside the trusted
part.

**Enumerating the safe paths.** [[decisions/decision-syscall-governance]] rules
the analogous case on the syscall surface: a denylist that covers what it
remembers has a hole at what it forgot, and the answer is default-deny at a
chokepoint. The same reading applies to a path allowlist and this decision does
not open it again.

## What this does not rule on

**The orchestration boundary.** [[decisions/decision-orchestration-boundary]]
owns it, and it already places the tool layer on the consumer side: a consumer
holds its own tools. Nothing here moves that line.

**Element status.** [[status-ledger]] is the one authority. No row here changes.

**Whether any of this is built.** This decision names a boundary and measures
what stands against it. It builds nothing and mints nothing.

## Three calls this decision carries out and leaves open

Each is the author's, each owes a row in [[records/author-calls]], and no row is
written by this document.

1. **Does `bash` exist in the goal toolset at all?** It is the one tool that
   hands back full naming authority, which makes every other narrowing
   decorative while it is present.

2. **Is the coding agent ever the holder of naming authority, or is it always
   handed its descriptors?** If always handed, the holder is scriba or a
   supervisor and that is a different prog's authority.

3. **Which spawn shape is the model**, the argv one or the ELF-bytes one.

## Honest limit

Nothing in this document is checked by anything. §5 measures the placement rule
as unenforced and §6 measures the crossing as absent, so the boundary this
decision names is one a module can step over in a single line and one no module
could stay inside if it wanted to. What the decision buys today is that a tool
gets a question to answer before it is written, that the refinement engine stops
being the place people look, and that the missing dirfd-relative open is a named
absence instead of an unremarked one.
