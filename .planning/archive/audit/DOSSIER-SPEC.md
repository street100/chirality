> **ARCHIVED 2026-09-01. Superseded by the pipeline skills in `.claude/skills/` (`worked-example`, `example-to-spec`, `pipeline-audit`, `doc-audit`), which are the live artifact formats.** The seven dossiers this spec governs are written and the audit wave it scoped is finished. `CLAUDE.md` names those four skills and the example -> audit -> spec -> audit -> implement pipeline they drive.

# Audit Dossier Spec (Step 3)

Shared format for the per-family audit dossiers under `.planning/audit/`.
Consumed by the family auditor agents; keyed to `.planning/SELF-IMPLEMENT-CATALOG.md`
(elements E1–E50) and `docs/decision-inspiration-policy.md` (tiers R/O/P/F).

## Purpose

The audit's job is twofold:
1. **Map** — verdict per element: what's proper, what needs redoing differently,
   where dev goes next, in what order.
2. **De-risk the passes** — for each element, provide enough worked context
   (paired snippets, explainers, recipes) that the future implementation pass is
   **copying + minor translation + boilerplate**, not a big open-ended pass.

(2) is the binding requirement. A dossier without concrete paired code is a failure.

## Per-element format

For each assigned element:

```markdown
## E<N> — <name>   [<build-kind> · Tier <R|O|P|F>]

**Lives now:** `<file>:<line>` pointers (all of them; be exact)

**Verdict:** one of
  PROPER    — sound as-is; the pass is a straight port/keep
  EXTEND    — sound core, named missing pieces
  REDO      — implemented as a scaffold shortcut; must be done differently — say *how*
  UNBUILT   — designed only; cite the design doc

**Explainer:** 3–10 sentences of the nuance a future pass needs: the invariants,
the trap that isn't obvious from the code, why it's shaped the way it is, what the
scaffold papered over (be honest — naming gaps is the point).

**Translation dossier:** the make-it-mechanical section.
  - *Source exemplar* — an actual snippet from this repo (Python, .chiral, or design
    doc). Quote real code with file:line. Never paraphrase when you can quote.
  - *Target sketch* — what the ported/proper version looks like. Ground EVERY line
    in existing repo syntax: chirality sketches must be modeled on constructs that
    already appear in `scaffold/lib/*.chiral` or `scaffold/demo/*.chiral`, and you
    must cite the exemplar file you modeled each construct on. NEVER invent surface
    syntax. If the target needs a construct chirality doesn't have yet, SAY SO
    explicitly (that's a finding, not a sketch).
  - *Mechanical recipe* — numbered steps split into: COPY (verbatim), TRANSLATE
    (rule-governed rewrite; state the rule), NEW (genuinely novel; should be small
    — if NEW dominates, the element isn't pass-ready and you should say what
    context artifact would fix that).

**Dependencies:** which E#s (or decisions) must land first; what this unblocks.

**Est. pass size:** S (<1 session) / M (1–2) / L (needs slicing — propose slices).
```

## Family-level sections (top and bottom of each dossier)

- **Header:** family name, elements covered, one-paragraph state-of-the-family.
- **Footer:**
  - *Redo list* — every REDO/scaffold-shortcut found, ranked by how much it
    poisons downstream work.
  - *Ordering* — dependency-respecting sequence for the family's passes.
  - *Cross-family flags* — anything discovered that belongs to another family's
    elements or to no element (candidate E51+).

## Proven repo patterns (use these as the template spine)

1. **Kernel seam pattern** — features attach as modules behind Sig seams, never by
   editing the kernel core: `ext_check`/`ext_eval`/`check_hooks`/`subtype_hooks`/
   `conv_hooks`/`quote_hooks`/`linear_hooks`/`narrow_hooks`/`def_hooks`/`rules`.
   Exemplar: `scaffold/chirality/refine.py` (whole module behind 4 seams) and
   `data.py`'s `check_termination` via `def_hooks`.
2. **Sys-slice recipe** — a new syscall = (a) sig in `native.py` `LIB_SIGS`,
   (b) hand-authored tal in `scaffold/lib/sys-tal.chiral` (+ `sys-lib` list),
   (c) test in `tests/test_native.py`. Exemplar: `nb-sys-lseek` / `nb-sys-memfd`.
3. **Self-hosted-codegen pattern** — the Python→chirality port shape already proven by
   `lib/emit-core.chiral` / `lib/mach-x64.chiral` / `lib/asm-reloc.chiral` +
   `lib/tal-ir.chiral`. Study how those mirror their Python originals before
   sketching any SELF-HOST target.
4. **Floor agreement** — reference interpreter, const-fold, native must agree on
   VALUES; I64 is two's-complement, div/mod Euclidean (settled — do not revisit).
5. **Totality/refinement discipline** — checks CLASSIFY by default and enforce on
   demand (`sig.require_total`, profile clauses). New static checks should follow
   the same classify-then-gate shape.

## Auditor ground rules

- Read `.planning/SELF-IMPLEMENT-CATALOG.md` + `docs/decision-inspiration-policy.md`
  FIRST, then your family's code.
- Read-only on the codebase. You write exactly one file: your dossier.
- No web access (egress is blocked). Tier-P discipline: name papers, don't fetch.
- No git in this tree; don't look for history.
- Honest defaults: a gap named is a result; a gap papered over is a defect in the
  audit itself.
