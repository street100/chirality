---
element: E172
kind: companion
status: drafted
updated: 2026-08-30
---

# E172 — the name map, produced before anything moves

**Map first, move later.** This is the inventory a rename wave needs and does not
have. Nothing here has been renamed; no file has moved.

Companion to `examples/E172-file-kinds.md` (the worked example), following the
`examples/E161-REQUIREMENTS.md` precedent for a companion beside an example.

## How this was produced

Deterministic, from `git ls-files '*.chiral'` plus four per-file predicates —
`^(def compile-main` (entry), `^(extern|^(porttype` (membrane),
`^(module … (cat …)` (E161 coordinate), and the basename. Re-runnable; if a number
here disagrees with the tree, the tree is right.

⚑ **The identity test matters and is E155's own.** Two files sharing a basename are
a **re-import** if they are the same bytes (the symlink web) and a **collision** only
if their identities differ. Conflating them inflates the problem by 9×; see below.

## §1 · Census — 402 tracked `.chiral`

| | count |
|---|---|
| defines `compile-main` → **`.prog`** | **177** |
| everything else → **`.chiral`** | **225** |
| declares `porttype`/`extern` (membrane) | 31 |
| carries an E161 coordinate `(module … (cat …) (alt …))` | **13** |
| …of which declare an altitude other than `upper` | **0** |

The extension column is **fully mechanical** — one grep, no judgment. The altitude
column is not: E160's row records altitude as *"partially derivable and still left
underived, since a check right two-thirds of the time gets suppressed."* So the
directory assignment below is **proposed with evidence**, never derived.

## §2 · `scaffold/lib` top level — 97 modules
2026-09-04: the 2026-08-31 migration moved the tree out of scaffold/. The pre-migration paths kept here name no live directory.

| proposed | count |
|---|---|
| `upper/` | 84 |
| `tal/` | 9 |
| `metal/` | 4 |
| → `.prog` | 5 |
| → `.chiral` | 92 |

### The 9 renames — every one drops an affix the directory now carries

| today | proposed | affix dropped |
|---|---|---|
| `tal-check` | `tal/check` | prefix |
| `tal-erase` | `tal/erase` | prefix |
| `tal-eval` | `tal/eval` | prefix |
| `tal-ir` | `tal/ir` | prefix |
| `tal-reify` | `tal/reify` | prefix |
| `tal-spec` | `tal/spec` | prefix |
| `tal-ssa` | `tal/ssa` | prefix |
| `bytes-tal` | `tal/bytes` | **suffix** |
| `sys-tal` | `tal/sys` | **suffix** |

That the same axis was written as a prefix seven times and a suffix twice is the
argument for the directory in one line.

`metal/` takes `emit-x64`, `mach-x64`, `asm-reloc`, `elf` — **proposed, not derived**;
a spec must confirm each against `axis-altitude`.

## §3 · Collisions — the number that was wrong

**Duplicate basenames today: 10 names over 23 files. Real collisions: 1.**

| basename | files | identities | verdict |
|---|---|---|---|
| `prelude` | 4 | 1 | re-import — E155 dedups |
| `grid` | 3 | 1 | re-import |
| `apc` `collections` `ports` `render` `session` `utf8` `vt-parser` | 2 each | 1 each | re-import |
| **`t1_child_wiring`** | 2 | **2** | **REAL** — `TUI/samples/` vs `scaffold/samples/`, different bytes. 2026-09-04: pre-migration scaffold/ path. |

⚑ **Correction owed to the E172 catalog row.** It says *"10 basenames already
collide."* The pre-run said **duplicated**; *collide* was my escalation, and E155
exists precisely to separate the two. The true figure is **1**, and it is between two
fixtures that never share a blob.

**Collisions introduced by the 9 renames: zero** — checked against the other 96 lib
modules and against all 402 tracked files.

The forward-looking risk stays real and belongs in the SPEC, stated as a *future*
condition rather than a present one: both resolvers key on the post-slash basename
(`bin/chirality-resolve.sh:53`, `resolve.chiral:422-429`), so a directory tree that
shortens names shrinks the key space every time it is used. Either E155's key becomes
the root-relative path, or each new altitude directory needs a collision check.

## §4 · What is mechanical, what needs judgment

| decision | status |
|---|---|
| `.prog` vs `.chiral` | **mechanical** — 177/225, one grep, checkable by the resolver |
| dropping a redundant affix | **mechanical** — the 9 above, zero collisions |
| `tal/` membership | **proposed**; 9 files, all currently affixed, high confidence |
| `metal/` membership | **proposed**; 4 files, needs a spec-level check per file |
| `upper/` as the default | **needs judgment** — 84 of 97 in one directory is a bucket, not a structure |
| TUI's own tree | **out of scope here** — `vt-core`/`mux`/`session`/`surface` are role or subject dirs and need their own pass |
| better *names* (beyond affixes) | **not attempted** — this map only removes redundancy; genuinely better naming is a separate judgment pass |

⚑ **The honest gap: `upper/` holding 84 of 97 is the same flat bucket one level down.**
Altitude sorts 13 files and leaves the rest undifferentiated. Either a second axis
earns a directory inside `upper/`, or the tree stops at two levels and the remaining
structure lives in the declaration. That is the open question this map surfaces and
does not answer.

## §5 · The tree — revised 2026-08-30 after the target-split finding

⚑ **Nothing has moved.** This is the map; the move is the SPEC's.

```
chirality/
  lib/
    prelude/     prelude · ord · list · map · set · alist · string
    typing/      kernel · kernel-core · qtt · ty-cmp · refine · totality
                 erased-nf · row-infer · pretty†
    surface/     sexp · parse · syntax · terms · data · surface
    module/      resolve · loader · load-batch · sig-derive · sig-driver
    lowering/
      upper/     lower · closconv · optimize · specialize-singleton · eff-lower
      tal/       ir check erase eval reify ssa spec bytes sys sys-check sys-linkage
      mach/      mach · emit-core · asm-reloc          ← target-INdependent
      x64/       mach-x64 · emit-x64 · elf
      c/         mach-c · emit-c · c-assemble    ← DROPPED 2026-09-01
      listing/   mach-listing
      cheri/     ← a new target lands here, and NOTHING else moves
    ports/       clock fd file pool process pty sock stdio tty · ports · crossing-wraps · term · inet
    capability/  lincoll · secret · session
    memory/      arena · alloc · alloc-fixed · alloc-growing · mem-linear · mem-region
    runtime/     proc · poll · supervisor
    protocol/    wire · apc · vt-parser · render · http · json · grid · utf8
    evidence/    harness · test-floor · ddc
  prog/          compiler.prog · resolve.prog · wield.prog · test-runner.prog · climb.prog
```

† `pretty` displays `Term`, so it is `type/`'s — but it is imported by nobody and
half-finished (6 of 11 formers). **E158 is the same idea correctly typed:** a formatter
returns `Doc` and flattening is an explicit choice (`doc->str` width-aware ·
`doc->rendering` into scriba's face tree · `doc->json`). Place it or stub it; do not
delete the idea.

### The three findings behind this revision

**1. `lowering/` already had two targets, written as filename suffixes.** (⚑ The C
target was dropped 2026-09-01, `d8bcec5`; this finding is left as it was measured.)
`mach-x64`/
`emit-x64` and `mach-c`/`emit-c`/`c-assemble`, plus `mach-listing` (*"a second conforming
Mach"*), against `emit-core` (*"target-independent code generation"*) and `asm-reloc`
(*"target-independent relocation"*). The tree already knows which files are shared and
which are per-target — it says so in filenames, the same affix-instead-of-structure
pattern as `tal-*`.
**The acceptance test this gives the tree: adding a target touches exactly one new
directory.** That is the additivity gate, applied to the file system.

**2. `collections` and `string-utils` are not floor-shelf oddities — they are unsplit
modules.** `collections.chiral` declares **three data types** (`Ord`, `Map`, `MinR`) and
carries List, Set (`s-*`/`ms-*`), alist and Maybe helpers. `banks/module`'s individuation
rule — *by its type, not its subject* — makes `Map` and `List` different modules, and
`LEDGER §VAL` already states the intent: these elements are *"**ownership** fixes, not
'add a library'"*, with E151's row naming *"the `string` module"* as the target. So they
split into `ord`/`list`/`map`/`set`/`alist` and `string`, and join `prelude` as the floor.

**3. `prog/` separates what chirality SHIPS from what it IS.** Entry-ness is already carried
by `.prog`, so `prog/` is not marking entries — it is the deliverable/library cut, and it
gives a one-file project a home instead of a floating root file. `test-runner` goes here
(it is the thing you run) while `evidence/` keeps `harness`/`test-floor`/`ddc`.

### Self-similarity — the claim, and its honest limit

Every directory above is meant to recur inside a chirality *program*, so "where does this go"
has one answer at every scale. Tested against the two programs that exist:
`ports`/`capability`/`protocol`/`runtime`/`memory`/`evidence`/`prog` transfer directly.
**`lowering/` transfers better than expected** — manas lowers Flow → ExpertCall → HTTP,
scriba lowers `Rendering` → ANSI *or* → APC frames, which is already a frozen contract
with two conforming legs, i.e. the `Mach` shape. `type`/`surface`/`module` are the ones
that may be compiler-only; a program with no syntax of its own has no `surface/`, and
that is the structure being honest rather than a gap.

**Consequence, and it is the point:** `fsm` is imported only by manas and its own header
says *"nothing here knows about HTTP or manas… the reusable control spine the profile
layer stands on."* Under this rule it is not language-level — it is `manas/runtime/fsm`,
until a second consumer appears.

## §6 · Three refinements (author, 2026-08-30)

**`type/` → `typing/`.** A porttype is a type; `Rendering` is a type; `Map` is a type.
`type/` names something that lives in every directory. `typing/` names the machinery of
the judgment, which is what the folder actually holds.

**The tree is a REFERENCE, not a skeleton.** `typing`/`surface`/`module` are for
implementing a *language*; a program has no checker, parser or resolver and simply does
not create those directories — you do not make folders you are not using.

⚑ *An earlier draft of this section called permanently-empty slots a failure mode that
teaches people the structure is advisory. That problem was invented: empty folders never
exist because nobody creates them.* The real value is the opposite and it is worth
stating in canon: chirality is extendable, so the full taxonomy is a **vocabulary to
consult** — when a program later grows a lowering path, a port surface or a protocol
codec, the name it belongs under already exists and is already the same name the
language uses. Self-similarity is for lookup, not for conformance.

**The extension is `.prog`, not `.main`.** `.main` named an implementation detail —
that the file happens to contain a def called `compile-main`. `.prog` names what the file
*is*, which is the same rule the rest of this design runs on: **name the type, not the
mechanism.** And because `prog/` and `.prog` share the word, their relation needs no
explanation: `prog/` is where the deliverable programs live, and `.prog` files also
appear in `evidence/` and the fixture dirs — `scriba-test-b1` is a program and a test;
the 137 fixtures are programs and none are deliverables.

## §7 · Primitive vs library — the rule for anything new

Measured on the two cases that exist:

| | `Str` (today) | `F64` (E153, unbuilt) |
|---|---|---|
| primitives | **7 externs in `prelude.chiral`**, part of the 32-extern floor | none — E153 must add the type, the reader literal, the externs, the TAL representation and x86-64 SSE codegen |
| where the primitive lives | the floor | **four directories**: `surface/` (literal) · `typing/` (type) · `lowering/tal/` (representation) · `lowering/x64/` (SSE) |
| the library over it | `string.chiral` — `starts-with`/`split`/`join`/`str-cmp`/`trim`/`replace`/`pad`, **zero new externs** | a future `float.chiral` — `abs`/`sqrt`/formatting |

**The rule: a PRIMITIVE spans surface/typing/lowering; the LIBRARY over it goes on the
base shelf.** So `string` belongs where it is, and `float` would not — until F64 exists,
after which its library joins the shelf exactly as `string` did.

⚑ Consequence for the shelf's name: every member is *a pure library over the extern
floor*, and only `prelude.chiral` is the auto-imported base — the rest are explicitly
imported. `prelude/` is therefore the wrong name for the directory. Still unnamed.
