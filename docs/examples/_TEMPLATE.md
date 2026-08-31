---
element: E<NN>
slug: <slug>
title: <human title>
kind: SELF-HOST | REPLACE-CRUTCH | BUILD-PROPER
reference_class: OURS | SPEC | PAPER | IMPL
ours_source: scaffold/chirality/<file>.py
status: drafted
updated: <YYYY-MM-DD>
---

# E<NN> — <human title>

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E<NN>, <what it is in one line>.
- **Kind:** <SELF-HOST | REPLACE-CRUTCH | BUILD-PROPER>.
- **Why chirality needs its own:** <the reason — shrink the TCB / shed a CPython
  crutch / build a designed-but-unbuilt feature>.

## 2. Research

- **Reference class:** <OURS/SPEC/PAPER/IMPL> — <the specific sources reviewed>.
- **Key findings:** <the 2–4 load-bearing facts from the reference — the core
  algorithm move, the ABI shape, the invariant. Cite; don't transcribe.>

## 3. Conventional (other-language) approach

How this is done outside chirality — the existing Python and/or a named language.

```<python-or-lang>
<short representative snippet>
```

- **Assumptions it bakes in:** <untyped effects / ambient allocation / floats /
  partiality / hidden mutation / no proof obligation — whatever chirality will refuse>.

## 4. The chirality idea

How chirality's model reframes it.

- **Chirality features in play:** <QTT quantities & usage / effect membrane `->` vs
  `=>` / ports & capabilities / categories A/B/C / refinement / totality /
  profiles & targets / the float→I64 wall>.
- **The reframing:** <what changes in the design, and why>.
- **What chirality makes impossible here:** <the conventional freedom it removes>.

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
; <well-commented chirality snippet — data/declare/def, QTT binders (0 A (type 0)),
;  -> pure vs => process. This is the artifact a later implementation run copies.>
```

- **Knobs to modify:** <what a reuser changes — the type params, the port set,
  the refinement bounds…>.
- **Deliberately omitted:** <what's out of scope so the example stays clean>.

## 6. Use / modify notes

- **Lands in:** <the `scaffold/…` file this becomes, or `lib/<name>.chiral`>.
- **Conformance target:** <the golden behavior it must reproduce to be correct>.
- **Open questions:** <the unresolved bits a real implementation must decide>.
- **Related:** [[E<NN>-<slug>]] … <linked elements>.
