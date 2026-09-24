# Handoff: the def-name naming system

Captured 2026-09-23 in an author session. **Preflight material for whoever runs
[[arcs/file-types-arc]] next**, because that arc is already doing naming-system
work one tier up and the author ruled its half today.

The connection: `records/author-calls.md:56` was ruled 2026-09-23, a file kind
is a **compound suffix** `<name>.m.<conf|check|type|gram>` rather than a flat
extension. That is a naming system for files. What follows is the same question
for `def` names, and it is unruled. Deciding them apart is how two conventions
in one tree drift.

Owner for the code half: **`E154`**, `lowering-and-emit/LE18`, whose design is
`docs/arcs/parts/lowering-and-emit-LE18.md` (`status: blocked`). This file is
the convention half and holds no element.

## What the thirteen prefixes actually are

Three different problems wearing one convention. Measured 2026-09-23.

| class | instances | what the prefix carries |
|---|---|---|
| **private workers** | ~20: `su-cmp-bytes` `su-lower-go` `su-trim-lo` `su-is-ws` `su-pad-go` `su-replace-go` and five more (`lib/prelude/string.chiral`), `ms-take` `ms-drop` `ms-merge` `ms-sort-n` `dd-skip` (`lib/prelude/list.chiral`), `l-snoc` `l-llen` (`lib/lowering/upper/lower.chiral`), `opt-cenv-get` `opt-two-srcs` (`lib/lowering/upper/optimize.chiral`) | nothing. They exist inside one module and nothing outside wants them |
| **tier twins** | 7: `tck-ce-prims` `tck-ce-fns` `tck-ce-datas` `tck-sig-assoc` `tck-find-data` `tck-find-ctor` (`lib/lowering/tal/check.chiral`) against `lower.chiral`'s, plus `l-find-ctor` | real information, spelled unrecognisably. The distinction is **altitude**, which [[axis-altitude]] already names upper / tal / metal |
| **claimed common nouns** | 30: all of `dg-` (`lib/typing/diag.chiral`), e.g. `dg-msg` `dg-doc` `dg-subject` `dg-observed` `dg-declared` `dg-dd-name` | a module fencing off English words from the whole tree |

Plus the one-offs `doc-fits`, `dfr`, `DMode` (`lib/prelude/doc.chiral:42-48`),
`gate-contains` (`prog/prapanca/core/gate.chiral:17-21`), `agent-ok2xx`
(`prog/shilpa/turn.chiral:206-209`).

⚑ **The tracked cells say the defect bit THREE times.** `docs/elements/catalog.md:485`
and `docs/elements/ledger.md:151` both. It is thirteen over sixteen files, and
`dg-` at 30 defs, the largest instance in the tree, is named by **no** ledger,
catalog, arc or lens row. That staleness is reported here and not fixed here.

## What `E154` fixes, and what it does not

It removes the **emit** collision. It does **not** remove the source ambiguity.
There is no export list: `(module prelude/string (cat A) (alt upper))` carries
category and altitude and nothing else, so every def a module holds is visible
to its importers. Two modules both defining `find-ctor` are legal after E154,
and a third importing both takes one silently, by blob order.

So dropping prefixes on its own trades a loud failure for a quiet one.

## The rules

1. **The name says what it does. The module path says where it lives.** Never
   encode module identity in a name. After `E154` the label carries it, the
   import carries it, and [[MAP]] already makes the directory the role.
2. **A qualifier is allowed only when it distinguishes meaning, and then it is
   spelled out.** The tier twins differ by altitude, so `tal-find-ctor` and
   `upper-find-ctor`. A reader knows `tal`. Nobody knows `tck`.
3. **Private workers take no qualifier and get a descriptive name.**
   `su-lower-go` → `lower-go`. `ms-merge` → `merge-runs`. `dd-skip` →
   `skip-adjacent-dups`. `l-llen` → `list-length`.
4. **Common nouns belong to the general owner or to nobody.** `dg-msg` →
   `diagnostic-message`. `dg-doc` → `diagnostic-doc`. `dg-redeclared-msg` →
   `redeclared-message`. `dg-dd-name` → `decl-data-name`.
5. **Never abbreviate below recognition.** The failures are exactly the
   sub-four-character qualifiers: `su`, `dd`, `dg`, `l`, `dfr`. If someone who
   knows the project cannot expand it, it is not a name.
6. **Keep `-go` as a declared convention** for an accumulator loop. It is used
   consistently already and is the one abbreviation here that reads.

**Long names are explicitly fine.** The author's words, 2026-09-23: *"longer
names is totally fine here too"*.

## The companion that makes it safe, and it is cheap

**Wire `subj-def` to `r-redeclared` at load.** `lib/typing/diag.chiral:348`
already renders `"definition redeclared: "` and **no site raises it**: the
`subj-def` raise sites are `r-unbound` (`kernel.chiral:844`) and `r-judged`
(`loader.chiral:401`, `:424`, `:434`) only.

Data names, extern names and porttypes are all short and all safe, because the
loader refuses duplicates with an accurate message. `def` alone is prefixed
because the loader does not. **This is not a new system. It is the tree's own
existing pattern applied to the one namespace that lacks it.**

`docs/arcs/parts/lowering-and-emit-LE18.md` carries this as **Shape E**, its
fallback if the resolution work is refused. On this reading it is not a
fallback: it is the half that makes short names survivable, and the judgment,
the subject and the message all already exist.

So `E154` reads as two separable things: **mangle at emit** so co-existence is
legal, and **judge at load** so co-existence is deliberate.

## The revert question, and why its cost argument was wrong

`records/author-calls.md:114` asks whether the thirteen are reverted once
mangling lands. ⚑ **The session argued for deferring on rebuild cost and the
author corrected it: a rebuild is about two seconds per part.** The cost
argument came from the design prose, which reads "full rebuild-and-promote",
and nobody timed a build. With that gone the answer is the simple one: revert
all thirteen inside `E154`.

One part of it needs no revert at all. Five gate roots (`prog/e185-apply-word.prog:10`,
`e186-capture-fields.prog:27`, `e188-apply-spine.prog:17`,
`e189-widening-multiply.prog:33`, `prog/samples/e200-coverage-composite.prog:20`)
each state in their own headers that they import nothing under `lowering/tal/`
because of these names. What `E154` gives them back is **an import, not a
spelling**.

## For the file-types run, specifically

Three things to carry, not to re-derive:

- The compound-suffix ruling and these rules should agree on **one principle**,
  and the candidate is rule 1: the identifier says what the thing is, the path
  says where it lives. A file kind naming its form (`.m.gram`, `.m.check`) is
  that rule at the file tier.
- Rule 5's failure mode is already live at the file tier: `.manifest` was ruled
  *"too general"* by the author in the same session, which is rule 4, a common
  noun claimed too broadly.
- `dg-` is untracked work regardless of any ruling and needs a row somewhere.
  Thirty defs, the largest instance, named by nothing.
