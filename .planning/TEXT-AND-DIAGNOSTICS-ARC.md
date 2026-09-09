# Text & diagnostics arc — E157 + E158 (handoff, 2026-08-22)

**Self-contained.** A fresh chat should be able to pick this up without reading the
session that produced it. Two elements, in dependency order, both pipeline-bound.

> **Scope discipline:** this arc is NOT on the current build path
> (`.planning/BUILD-ORDER.md`). It was surfaced while working E150/E151 and is
> parked here deliberately so it can be run by a dedicated agent in its own chat.
> Do not interleave it with the W1–W7 queue.

---

## 1. The finding that started it

chirality flattens text to `Str` at the earliest possible moment, everywhere, and the
structure is destroyed before anything can use it.

**The compiler's own errors are the sharpest case.** The *outcome* is a proper closed
sum; the *reason* is a `str-cat`'d string:

```
loader.chiral:233,254   (ld-err (str-cat "data redeclared: " dn))
kernel.chiral:636       (ck-err "linear binder usage mismatch")   ; :313 pre-E159/E161
kernel.chiral:648       (ck-err "let binder usage mismatch")      ; the untested twin
```

So `docs/pattern-boundary-sums.md` — *a which-of-N is a closed sum, never a string* —
is honoured at the outer layer and violated inside the error. A compiler diagnostic is
the canonical which-of-N.

**The habit is systemic, not local:**

| site | what it flattens |
|---|---|
| `prapanca/core/assemble.chiral:51-56` | an LLM prompt — sections, roles, provenance — as a 10-deep nested `str-cat` closing `))))))))))` |
| `pretty.chiral` (45 L) | a term printer that hardcodes `parens`/`sp` and goes straight to `Str`. **Imported by nobody** |
| every log / status line | `str-cat` chains; no padding or alignment until `str-pad` landed in E151 |

**The counter-example is already in the tree.** `skip-diag.chiral` (E97) has
`SkReason` as a real closed sum (`sk-extern` / `sk-callee`) plus a blame chain — and it
is what turned "phantom B1 bugs" into a diagnosable paren slip. The right shape exists;
it is confined to one diagnostic family.

Only `render.chiral`'s `Rendering` tree resists flattening, and it is display-specific.

---

## 2. E157 — diagnostics as typed values  *(first; this is where the value is)*

Give `ld-err` / `ck-err` a closed `Reason` sum carrying **evidence**, not prose:

- redeclaration → **both** declaration sites
- type mismatch → expected vs actual, as types
- linear misuse → the binder, its declared quantity, its uses
- skip / prune → E97's blame chain, generalized

**Why this beats a Python traceback, concretely.** Python's traceback is excellent and
it is a *string produced at raise time*; jumping to a frame or folding a chain needs an
IDE protocol reparsing it. Here the compiler is written in chirality and scriba is a port
viewer that renders typed values — so a diagnostic is *directly* navigable: expand the
blame chain, jump to both sites of a redeclare, fold a skip chain, filter by reason.
That is a category Python reaches only via LSP; here it is just what the value is.

**Design content (why it takes the pipeline):** the `Reason` taxonomy itself. Too
coarse and it is a string with extra steps; too fine and every new check mints a
constructor. E97's `SkReason` is the precedent to generalize from, not to copy.

**Do not skip:** `skip-diag.chiral`'s header records a real constraint — *"every case on
`SkRec`/`SkReason` lives inside a small accessor def so callers never pattern-match
these types inside case arms. This avoids the B1 'unknown name' bug triggered by nested
case patterns over newly-defined data types."* Any new diagnostic sum inherits that.

---

## 3. E158 — `Doc`, the structured formatter  *(second; consumes E157)*

**The move: printf fuses a template with a flatten. Split them.** The template becomes
a value; flattening becomes a choice.

```
(data Doc ()
  (d-text  (s Str))
  (d-cat   (a Doc) (b Doc))
  (d-line)                          ; a break point
  (d-nest  (n I64) (body Doc))      ; indentation scope
  (d-group (body Doc))              ; flat-if-it-fits
  (d-tag   (name Str) (body Doc)))  ; semantic marker, NOT a face
```

Exits are explicit and plural: `doc->str` (width-aware) · `doc->rendering` (into
scriba's tree, `d-tag` → `r-face`) · `doc->json`.

**The ladder stays a ladder.** `str-cat` for trivia — nobody should build a `Doc` to say
`"err: " ++ msg`. `str-join` for lists (already exists, `collections.chiral:102`,
underused). `Doc` when structure is real.

**Ordering is load-bearing: E157 first.** A `Doc` that prettifies
`"data redeclared: Ord"` still cannot say where the other declaration is — `str-cat`
destroyed that before the formatter ever saw it. Formatting is not the fix; it is the
rendering half of the fix.

**Open design calls:** the algebra's exact shape (Wadler's `group`/`nest` vs something
smaller); whether `Doc` unifies with `Rendering` or stays separate and converts;
whether a **dependently-typed printf** rides on top — chirality has the dependent fragment,
so a format expression whose *type is computed from the format string* is expressible
here in a way it is not in C. That would give arity- and type-checked formatting that
produces a `Doc` rather than bytes.

**Reference:** Wadler, *A prettier printer* (1998). Idris/Agda for the typed-printf half.

---

## 4. Payoff sites, already in the repo

1. **`assemble-prompt`** — prompt sections stay sections until the wire. Enables
   per-section provenance tagging, rendering a prompt into scriba for inspection, and
   **structural diffing of two prompts** instead of text diffing.
2. **`pretty.chiral`** — real nesting and grouping instead of hardcoded parens, and
   reusable inside diagnostics rather than orphaned.
3. **Run-view / logs** — messages carrying structure the run-view already knows how to
   display.

---

## 5. Pipeline obligations

Both elements take the **full pipeline** per the `CLAUDE.md` criterion (*an element goes
through the pipeline iff implementing it requires choosing between shapes the codebase
does not already settle*) — E157's taxonomy and E158's algebra are both real choices.

```
python3 tools/pack/pack.py E157 <slug>          # worked example
python3 tools/pack/pack.py E157 --audit example # gate
python3 tools/pack/pack.py E157 --spec          # spec
python3 tools/pack/pack.py E157 --audit spec    # gate
# then implement; same five for E158
```

**Standing lessons that apply here** (learned the hard way this session):

- **A fixpoint check is not a correctness check.** A reversed-but-total comparator
  passed the self-host fixpoint, a 42-test, *and* a cross-compiler differential; only a
  behavioural sample caught it. Gates must be behavioural.
- **ELF size is not a signal** — the image is zero-padded; identical size hid 300KB of
  changed content.
- **This sandbox runs as uid 0**, which masks permission errors. Re-run
  permission-sensitive probes under a dropped uid.
- **`grep -r` does not follow symlinks**; the foundation modules are symlinked. Use
  `grep -R` or a Python file-walk.
- **The flat emitted-label namespace (E154) bites every new module.** Two modules in one
  blob cannot define the same name — prefix internals (`d-`/`dg-`) and census them
  before committing.
- **B1 compiles everything. Python compiles nothing, ever.**

## 6. Anchors

`.planning/LEDGER.md` (E157, E158 rows) · `.planning/SELF-IMPLEMENT-CATALOG.md` ·
`docs/pattern-boundary-sums.md` (the discipline being violated) ·
`scaffold/lib/skip-diag.chiral` (E97, the in-tree precedent) ·
`scaffold/lib/render.chiral` (`Rendering`, the one structure that resists flattening) ·
`scaffold/lib/manas/core/assemble.chiral:51-56` and `scaffold/lib/pretty.chiral` (the two
worked payoff sites) · `.planning/BUILD-ORDER.md` (the queue this arc is NOT on).
