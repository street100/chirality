---
element: E181
slug: pretty-term-doc
title: **The term printer, repointed at the real `Term` and returning `Doc`** — a rewrite, because today's file declares a five-constructor `Term` of its own that the checker's sixteen-constructor one cannot be co-compiled with.
kind: BUILD-PROPER
reference_class: OURS/IMPL
ours_source: legacy tree `scaffold/metis/pretty.py:19-59` (`show_term`) — the file `lib/typing/pretty.chiral:1` says it was ported from
status: reviewed
updated: 2026-08-31
---

# E181 — **A term printer that prints the checker's terms**

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E181 — rewrite `lib/typing/pretty.chiral` so it walks
  `lib/surface/syntax.chiral`'s `Term` and returns `Doc`.
- **Kind:** BUILD-PROPER.
- **Why chirality needs its own:** the value being printed is chirality's own
  nameless de-Bruijn core, and the target grammar is chirality's own surface. No
  off-the-shelf printer knows either. The reference is the Python `show_term`
  this file was ported from (§3), which covers **fifteen** of the sixteen
  formers — every one but `t-ann`, which falls to its `<{k}>` catch-all — and
  gets **four** of them wrong for round-trip (§2 finding 9). *(Audit fix: the
  earlier "eleven" was the catalog row's "grow eleven arms", a different
  number — 16 minus the 5 the current file renders.)*

**⚑ The brief's constructor count is off by one, and the tree already says so.**
The real `Term` has **sixteen** constructors, not fifteen
(`lib/surface/syntax.chiral:18-34`); a line-based count returns 15 because
`t-lit-i` and `t-lit-s` share line 30. `lib/typing/diag.chiral:501` already reads
*"the real 16-constructor `Term`"*. Sixteen arms, plus `KArm` and `RfAtom`, is the
coverage this element owes.

**⚑ And the target is not "unimported". It is UNIMPORTABLE.** Two measured
refusals, both from probes run on this branch (§2, findings 2 and 3):

```
(import "typing/pretty") (import "surface/syntax")      -> load: data redeclared: Term
(import "typing/pretty") (import "lowering/tal/erase")  -> duplicate label (an object def
                                                           collides with the linked runtime): nlen
```

So the honest statement of the defect is not *"nobody imports it"* — it is:

> **No module that has the checker's `Term` in scope is ABLE to import it**, and
> one of its six helpers is a live E154 duplicate that no gate can see, because
> nothing in the tree ever co-compiles the file with anything.

That is why `lib/typing/diag.chiral` had to ship `dg-term-tag` — a flat,
one-level accessor — beside `dg-doc`: not because a printer was hard, but because
the printer in the tree **could not be linked** (`diag.chiral:493-501`).

**Explicitly NOT in scope:** `Doc` itself — its algebra is closed at six
constructors and E181 adds nothing to it (§4.6); the face registry E181's new
`d-tag` keys land in (E179, minted); `dg-msg`'s wording (E157 owns its goldens);
value→source emission (E146, **Lane B** — E181 is its prerequisite and must not
pre-empt it).

## 2. Research

- **Reference class:** `OURS/IMPL`. `lib/typing/pretty.chiral:1` names its
  baseline: *"Ported from pretty.py show_term"*. That file is
  `scaffold/metis/pretty.py:19-59` in the legacy tree — 41 lines, eleven formers
  (§3). The rest of the reference is this tree: `Term`, the parser, the
  elaborator, the `Core → Term` bridge, and E158's `Doc`.

**Key findings — measured on `e158-doc` at `efac8b2`, 2026-08-31. Every probe was
compiled with `bin/chirality-bin` and run; nothing below is read off source
alone.**

1. **The target, re-measured.** 51 lines. Its own `Term` at `:15-20`
   (`t-type`/`t-var`/`t-lam`/`t-app`/`t-let`) — five of sixteen, and its `t-lam`
   carries an `nm Str` the real one does not have. `show-term : (-> (List Str)
   Term Str)`, so it flattens at every step. `sp` and `parens` are `Str`
   functions. Zero importers tree-wide.

2. **⚑ It is not compiled by anything, either.** Phase 7 sweeps
   `grep -rl '^(def compile-main' lib prog` — *roots* — and no root reaches
   `typing/pretty`. Phases 13–17 name it nowhere; `doc.sh:37` explicitly lists
   *"any `pretty.chiral` behaviour"* as **not a row**. So its current state is
   unverified, not merely unadopted. A probe importing it **alone** does compile
   and run, which is the only evidence that exists that it is well-formed at all.

3. **⚑ Two live collisions, both measured as refusals.** `Term` against
   `surface/syntax`'s `Term` (`load: data redeclared: Term`); and `nlen`, defined
   at `pretty.chiral:28-29` **and** at `lib/lowering/tal/erase.chiral:34-35`
   (`duplicate label (an object def collides with the linked runtime): nlen`).
   The second is exactly the E154 defect class this repo has fixed four times
   (`str-cmp`, `list-sort`, `list-dedup-adj`, `Ord`) and it is invisible today
   only because the file is unreachable. `nlen` and `get-at` are also hand-rolled
   duplicates of `prelude/list`'s `length` and an index — the rewrite deletes
   both rather than renaming them.

4. **⚑ The names exist ONE LAYER UP, and the bridge throws them away.**
   `lib/surface/surface.chiral:50-64` declares `Core`, a *second* de-Bruijn core,
   in which `c-pi` (`:55`), `c-lam` (`:56`) and `c-let` (`:57`) each carry a
   `bname Str`. (`:28-48` is `Surf`, the *named* surface AST — a different sum.)
   `lib/module/loader.chiral:17-18` says what happens next in its own words —
   *"Drops the surface-only binder NAMES (Term is de-Bruijn)"* — and `:39` is the
   line: `((c-lam bn body) (t-lam (core->term body)))`.
   **The consequence is the good news, not the bad news:** because `Term` is
   nameless, an invented name is not a lossy approximation of a name that was
   lost — it is a *free* choice, and every choice that resolves back to the same
   indices round-trips **exactly**. There is no capture-avoidance problem here.

5. **There is exactly one obligation on an invented name, and it is
   one-directional.** `surface.chiral:118-132`: `resolve` searches `ctx`
   (locals, innermost first) **before** atoms, ctors, datas, globals and prims.
   So a local always wins. The hazard is therefore not that a bound occurrence
   escapes — it is that a **`t-global "x0"` printed as `x0` under an invented
   binder named `x0` re-elaborates to the binder**. One direction, one check: an
   invented name must not equal a free name the term itself carries.

6. **The elaborator's own binder order, which the printer should adopt.**
   `push-all` (`surface.chiral:95`) and `wrap-lams` (`:97`) cons each binder on,
   so the **last** parameter is innermost and `ctx-find` counts from the head.
   Today's `pretty.chiral` uses the opposite convention (`names-snoc` +
   `names[len-1-i]`, `:26-38`), which is a second spelling of one fact.

7. **The quantity is expressible in the surface and has a default.**
   `parse.chiral:50-56` — a quantity token is the integer `0`, the integer `1`,
   or the symbol `w`. `try-qbinder` (`:61-79`) reads a `(q name rhs)` triple for
   **arrow binders, let bindings and data fields alike**, and `parse-binder`
   /`parse-lbind` default to `2` (= `qw`) when there is no token. So
   `(let (x v) b)` and `(let (w x v) b)` elaborate to the same `t-let (qw) …`:
   **printing the quantity is round-trip-safe, and so is eliding `w`.** The
   choice is about evidence, not correctness (§4.4).

8. **There is no precedence problem.** `parse-list` (`parse.chiral:173-192`)
   dispatches on the head symbol — `-> => lam let case do cond the refine type` —
   and everything else is an application. Parens are structural. The brief's
   "minimal parens vs always parens" question **does not arise**; what the
   hardcoded `parens` actually hides is that a paren pair and a group boundary
   are the same `Str` object today, and they must become two different `Doc`
   objects (§4.6).

9. **Four places the Python baseline does not round-trip**, all of which the
   rewrite must fix rather than port:
   - `(case ...)` is literally elided (`pretty.py:52-53`).
   - A refinement prints as `{base | v > 3}` (`:54-56`); the surface is
     `(refine base (> 3) …)` (`parse.chiral:190, 385-393`), ops spelled
     `>= > <= < !=` (`loader.chiral:21-24`).
   - An application prints as `((f a) b)` (`:40-41`); the surface is n-ary
     (`s-app (head Surf) (args (List Surf))`), so the spine must be flattened.
   - A string literal goes through `repr` (`:27-28`), i.e. Python's escaping —
     chirality's is `\n \t \" \\` and nothing else (`render.chiral:175-176`).

10. **`t-ann`'s fields are in the opposite order from its surface form.**
    `(t-ann (tm Term) (ty Term))` (`syntax.chiral:25`) against `(the ty e)`
    (`parse-the`, `parse.chiral:219-230`; `elab`, `surface.chiral:164-168`). A
    printer that emits its fields in declaration order silently produces a term
    that re-elaborates to a *different* annotation.

11. **`t-con`'s `dn` and `t-tcon`'s `dn` are recoverable and must NOT be
    printed.** `resolve` (`:124-127`) looks the home up:
    `(assoc name (se-ctors sig))` returns it. The surface has no syntax for a
    qualified constructor, so printing `dn` would not parse.

12. **⚑ The forcing consumer's gate survives adoption — measured, and it is
    luck worth writing down.** `tools/test/samples/e158_doc.prog:169-171` grades
    the `r-mismatch` arm with `dt-has2 … "expected I64" "actual Str"` over
    `(t-primty "I64")` / `(t-primty "Str")`. `dg-term-tag`'s `t-primty` arm
    returns `n` (`diag.chiral:681`, inside the `dg-term-tag` body at `:669-685`);
    a source printer's `t-primty` form is also
    `n`. **The two agree on exactly the terms the fixture chose**, so replacing
    those two calls leaves Phase 14's row 7 green and `doc.sh` need not move —
    which matters, because `doc.sh` is one of four scripts `render-doc.sh`
    sha256-pins (`render-doc.sh:469-490`). The **third** `dg-term-tag` call site,
    `dg-decl-doc`'s `dc-ty` arm (`diag.chiral:660-663`), is graded by nothing:
    fixture rows 5 and 6 use `dc-data`.

13. **⚑ E181'S OWN DELIVERABLE JOINS THE COMPILER'S CLOSURE — the first in this
    arc that does.** Measured (re-measured at the example audit, same numbers):
    `prog/compiler.prog`'s blob is 755,238 bytes over 65 modules; it contains
    `dg-term-tag` 7×, `(end-module "typing/diag")` and `(end-module
    "prelude/doc")`, while `show-term` and `(end-module "typing/pretty")` appear
    **0×**. The moment `typing/diag` imports `typing/pretty`, the file joins the
    compiler's own source.

    ⚑ **Corrected at the example audit — "the first element in this arc inside
    the closure" was wrong, and the distinction it was reaching for is sharper.**
    `prelude/doc` has been inside since E158 commit 2, and **E158 commit 4
    already carried the build-rule obligation** for a comment edit to
    `lib/prelude/doc.chiral`: `HANDOFF-DIAGNOSTICS-ARC.md` records *"blob 753401
    → 753702 bytes, emitted compiler byte-identical at 1126776 bytes, nothing to
    promote, `N1 == N2` re-run anyway"*. What E174, E175 and E158 commit 4 each
    recorded as *"outside the closure → no fixpoint, no promotion"* was
    `protocol/render` and `protocol/render-doc` — their **deliverables**. E181 is
    the first whose deliverable module *enters* the blob, and the first whose
    closure change is **semantic** rather than a comment, so it is the first that
    must actually **promote a changed binary** rather than observe a byte-identical
    one. It carries the full BUILD RULE: build-new → test → promote, then run the
    promoted binary over the same blob and byte-compare — **with the new binary
    verified non-zero before `cmp`**, because `cmp` of two empty files passes
    (`HANDOFF-DIAGNOSTICS-ARC.md`'s own binding decision).

    ⚑⚑ **And a precondition E181 does not create but will be blamed for.**
    Measured on `e158-doc` at the example audit, three generations over the same
    755,238-byte blob, each build deterministic (re-run byte-identical):

    | | bytes | |
    |---|---|---|
    | `bin/chirality-bin` (promoted at `2df9fa4`, E158 commit 2) | 1,126,776 | |
    | `C1 = B1(blob)` | 1,130,872 | **≠ B1** |
    | `C2 = C1(blob)` | 1,130,872 | **≠ C1** (1,012,469 bytes differ) |
    | `C3 = C2(blob)` | 1,130,872 | **= C2** |

    The committed binary is **one generation behind the tree** — `bc321a8` merged
    master into `e158-doc` after commit 4's measurement — so *today*, before E181
    touches anything, a single build-new → promote → byte-compare pass **reports a
    failure**. The fixpoint is at the second generation. G9 must be run against a
    re-promoted binary, or it convicts E181 of a defect the master merge left.

14. **The intended shape compiles today.** A probe root importing
    `surface/syntax` + `prelude/doc` + `typing/diag`, with a
    `(-> (List Str) Term Doc)` sketch covering all sixteen arms, compiles
    (blob 103,005 B) and runs (exit 3 = `str-len "I64"`). Deleting one arm gives
    `load: non-exhaustive case`. *(Both re-measured at the example audit on an
    independently written 16-arm probe: compiles, exit 3, and deleting the
    `t-tcon` arm gives `load: non-exhaustive case`.)* So the import set is legal, the walk typechecks,
    and **coverage is a compile-time invariant** — which makes "delete an arm"
    and "add a seventeenth `Term` constructor" working mutants rather than hoped-for
    ones.

15. **New `d-tag` keys are free at the renderer.** `lookup-face`
    (`render.chiral:164-173`) returns `(face name -1 -1 0)` for an unknown key,
    and `d-tag` is zero-width in both `doc-fits` and `doc-best`
    (`doc.chiral:123,151`) — so a tag can never move a break. The five keys §4.5
    introduces are exactly the ad-hoc-key population **E179** is minted to make
    authoritative: a cross-cut, not a blocker.

16. **E154 census for every name this element introduces**, run tree-wide over
    `lib prog tools`: `pp-term pp-form pp-call pp-lines pp-args pp-spine pp-arm
    pp-arms pp-dflt pp-atom pp-atoms pp-qty pp-seat pp-op pp-name-at pp-fresh
    pp-free-names pp-safe-prefix pp-quote pp-vars term-kw term-qty term-var
    term-lit term-name` — **zero hits, all of them**. `pp-` is not a virgin
    prefix (`pp-is-ws`, `pp-recover-or-lines` exist) but no name collides.
    ⚑ **The census must be word-boundaried, and this is not pedantry:** a
    fixed-string `grep -F pp-args` returns **16 hits**, every one of them
    `app-args` in `lowering/upper/closconv.chiral`. Re-run at the example audit
    with `(^|[^A-Za-z0-9_-])NAME([^A-Za-z0-9_-]|$)`: **zero hits, all 25 names.**
    ⚑ `symop->s : (-> SymOp Str)` **already exists**, at
    `lib/lowering/upper/closconv-driver.chiral:31` — so `pp-op` may not be spelled
    that way, and `typing/` importing `lowering/` is the wrong direction anyway
    (§6). Likewise `dg-qty-name` (`diag.chiral:286`) prints `"omega"`, not `"w"`:
    a source printer genuinely needs the other spelling, so `pp-qty` is a second
    function and not a duplicate.

## 3. Conventional (other-language) approach

```python
# scaffold/metis/pretty.py:19-59 (the file this one was ported from) — shape
def show_term(t, names=None):
    if names is None: names = []
    k = t[0]
    if k == "Var":
        i = t[1]
        return names[len(names) - 1 - i] if i < len(names) else f"#{i}"
    if k == "Pi":
        arrow = "=>" if t[2] else "->"
        q = "" if t[1] == terms.W else f"{t[1]} "        # <-- elides the default
        return f"({arrow} ({q}{t[3]} {dom}) {cod})"
    if k == "Lam":
        return f"(lam ({t[1]}) {show_term(t[2], names + [t[1]])})"   # <-- t[1] is a NAME
    if k == "App":
        return f"({show_term(t[1])} {show_term(t[2])})"              # <-- ((f a) b)
    if k == "Case":
        return "(case ...)"                                          # <-- elided
    if k == "Refine":
        atoms = ", ".join(f"v {op} {show_term(o)}" for op, o in t[2])
        return "{" + show_term(t[1]) + " | " + atoms + "}"           # <-- not the surface
    return f"<{k}>"                                                  # <-- a catch-all
```

Three properties of this shape are worth naming, because two of them are
unavailable here and the third is a defect:

- **It prints from a term that still has names.** `t[1]` in the `Lam` arm *is*
  the binder's name. The Python core kept them; chirality's `Term` does not
  (finding 4). So the conventional printer never faced the question this one
  must answer first.
- **It returns a string, so every layout decision is made at the innermost
  call.** This is the defect `Doc` exists to remove, stated in
  `doc.chiral:3-10` with this file named as one of the two examples.
- **It has a catch-all** (`f"<{k}>"`). A new former gets a printer that silently
  prints `<Whatever>` forever. The chirality version has no `_` arm and a new
  former is a compile error (finding 14).

The wider conventional practice — GHC's `Outputable`/`showsPrec`, `pretty-printer`
libraries generally — adds *precedence-driven minimal parenthesisation*, which is
the only part of the conventional design that has no analogue here at all: an
S-expression surface has no precedence to recover (finding 8).

## 4. The chirality idea

- **Chirality features in play:** closed sums with enforced coverage (sixteen
  arms, no `_`) · `Doc`'s deferred flatten (E158) · the `->` membrane (a printer
  provably crosses no port; `(module typing/pretty (cat A))`'s derived crossing
  set stays empty) · PRINCIPLES §5, push the invariant into the substrate — the
  one correctness obligation on an invented name becomes a *computed prefix*
  rather than a convention two functions agree about.

**1. ⚑ ONE printer, and its output is SOURCE. This is the decision the others
hang off.**
Two consumers want a `Term` rendered: diagnostics (`r-mismatch` carries two)
and E146, value→source (Lane B). The tempting answer is two printers — a pretty
one and a faithful one. Refused, and not on taste:

- `docs/decisions/decision-lane-split.md` forbids Lane B writing a term printer. So E181 must be the printer
  E146 can use, or Lane B is blocked or in violation.
  ⚑ **Audit correction — do not lean on G6 for this.** `docs/decisions/decision-lane-split.md`'s own sentence
  is *"a second printer **defining the same names** is caught the same way"*, and
  `doc.sh`'s G6 (`tools/test/doc.sh`, the census) enumerates **only
  `lib/prelude/doc.chiral`'s own bindings** — the `(def|data|declare)` heads plus
  every `d-`/`brk-`/`m-`/`dfr` name — and greps `lib prog tools` for a second
  *definition of one of those*. A Lane-B term printer under different names
  (`src-term`, say) is **not** mechanically caught. The enforcement here is
  `docs/decisions/decision-lane-split.md`'s file ownership plus review; the two legs below are the ones that
  do not depend on a gate.
- Two printers over one sum is the **duplicate-owner defect this repo has fixed
  four times** (`str-cmp`, `list-sort`, `list-dedup-adj`, `Ord`) — and
  `dg-term-tag` is already the third of them, alive today.
- The premise that a "display" form would be nicer is **false here**: chirality's
  surface is S-expressions, so the source form *is* the readable form, save at
  the two places the Python baseline invented a display syntax (`{b | v > 3}`,
  `(case ...)`) — both of which are strictly less informative than the source.

So: `pp-term` emits text that `parse` + `elab` + `core->term` maps back to the
term it was given. Round-trip is not asserted by E181 (the loader is not on its
import path — §6, open question 2), but nothing in it is allowed to make the
property false, and every deviation in finding 9 is a bug to fix, not a style to
port.

**2. ⚑ Invented names are FREE, not lossy — and the de Bruijn question dissolves
into one collision check.**
The brief frames this as *invent names (and then guarantee freshness and
capture-avoidance) or print indices*. Finding 4 collapses it: `Term` is nameless,
so there is no name to be faithful to, and any consistent naming that resolves
back to the same indices is **exactly** right rather than approximately right.
What remains is not capture-avoidance and not a freshness search:

- **Between invented names there is no hazard by construction.** The binder at
  environment depth `d` is `prefix ++ d`. Two binders in scope simultaneously
  have different depths, hence different names. Nothing to check.
- **Against free names there is exactly one hazard, in one direction** (finding
  5): a global spelled like an invented binder. That is a *property of the term*
  and is computable from it.

So the prefix is a **parameter**, and `pp-safe-prefix` computes one from the
terms about to be printed: `"x"` unless the terms carry a free name of the form
`x⟨digits⟩`, in which case a prefix longer than every free name is used, which
cannot equal one. Two branches, both total, no search, no counter threaded
through the walk.

⚑ The prefix is a parameter for a second reason that is not optional:
`r-mismatch` prints **two** terms, and they must use the **same** prefix or the
diagnostic invents two vocabularies for one comparison. `pp-safe-prefix` takes a
`(List Term)` for exactly this.

**3. Printing indices instead is a real option and is refused with its cost.**
`(lam #0)` needs no prefix, no free-name scan and no environment. It is also not
chirality source, it makes E146 impossible without a second printer (§4.1), and
it is *less* readable in precisely the case that motivated the element — an
`r-mismatch` between two function types, where every `#0` means something
different. Refused. The environment stays, and it adopts the elaborator's own
innermost-first convention (finding 6) so the two cannot drift.

**4. ⚑ The quantity is printed, ALWAYS, and the arc already measured why.**
Finding 7 says both forms round-trip, so this is a free choice, and the arc has
already made it once: `doc.sh`'s **case 14** is a control row whose entire
content is that `dg-msg` **drops both quantities** and `dg-doc` keeps them.
Eliding `w` because it is the default is the same move, one layer down — the
printer deciding on the reader's behalf that a value is not worth carrying.

The general answer, and it is `Doc`'s: **"show it only sometimes" is a rendering
policy, and rendering policies live at the exit, where the width and the faces
already are.** The quantity is emitted inside `(d-tag "term-qty" …)`, which is
zero-width (finding 15), so a consumer that wants it dimmed or dropped has a
handle and the value is never destroyed. Same for `t-pi`'s `Seat`: `->` vs `=>`
is the effect membrane, a different token rather than a defaultable field, and it
is never elidable.

**5. The `Doc` shapes, and this is the algebra's first honest test.**
Every former has one of two shapes:

- keyword form: `(d-group "(" ++ tag kw ++ nest 2 (line ++ arg)* ++ ")")`
- application: the same without the keyword, with the head in its place.

`d-nest 2` matches `dg-doc`'s own indent (`diag.chiral:523`, and eight more). The breaks:

- **`brk-space` everywhere between tokens.** Flat gives `" "`, broken gives a
  newline plus the indent — which is exactly the separator an S-expression wants.
- **`brk-soft` is used NOWHERE**, and that is a finding rather than an omission:
  a soft break between two tokens flattens to `""` and **fuses them into one
  token**. In a printer whose output must re-parse, `brk-soft` is never correct
  between atoms. §6's G2 is that as a checked row.
- **`brk-hard` in exactly one place**: between `t-case`'s arms. Arms are one per
  line by intent, not by width — the same call `dg-chain-doc` made for E97's
  frames (`diag.chiral:704`).

So all three `Brk` arms are needed, none is missing, and the closed sum is
exactly right for the first real consumer. That is the test E158 could not run on
itself.

**6. ⚑ Nothing is added to `Doc`, and the thing that looked like a gap is not
one.** The obvious candidate for a seventh constructor is "a token that must not
be broken from its neighbour" — and the six-constructor algebra already has it:
that is `d-text` of the whole token, or a `d-cat` with no `d-line` between the
parts. `Doc`'s closure is not strained by this element. (§6 records the one place
a `Doc` genuinely cannot express what a *later* element might want, and the
answer there is E158's own: a separate type that **converts into** `Doc`, the way
`doc->rendering` does, never a seventh arm.)

**7. `parens` and `sp` do not get ported; they get SPLIT.**
Today `(parens (sp a b))` produces `"(a b)"` — one `Str`, in which the paren pair
and the grouping decision are the same object, so neither can be chosen later.
In `Doc` they are three separate things: `d-text "("` (structure, always
emitted), `d-line (brk-space)` (a decision point), and `d-group` (who makes the
decision). That split **is** the rewrite; everything else follows from it.

**8. What crosses: nothing.** Every signature is `->`. The
`(module typing/pretty (cat A) (alt upper))` line stays and its derived port set
stays empty — the module binds no extern before or after. Writing the result is
the caller's `put`, at a port it already holds.

## 5. Chirality example (fleshed)

A **replacement** for `lib/typing/pretty.chiral`, not a patch: nothing in the
current file's 51 lines survives except the header's intent and the `(module …)`
line. Mechanical recursion is elided with `; …`; what is written out is what a
later run must get *right*.

```chirality
; E14/E181: the pretty-printer (display, NON-trusted). Pure (->): a display
; function provably crosses no port. Exhaustive over the REAL Term -- sixteen
; arms, no <k> catch-all, so a new former is a compile error rather than a
; silent "<Whatever>". Returns Doc: the width is an argument to the EXIT.
;
; ⚑ THE OUTPUT IS SOURCE. `parse` + `elab` + `core->term` of it is the term it
; was given. Binder names are INVENTED and that is free rather than lossy --
; core->term (module/loader.chiral:39) drops the author's names and Term is
; nameless, so any naming that resolves back to the same INDICES is exactly
; right. The one obligation is that an invented name must not shadow a free one
; (resolve, surface.chiral:119, searches locals first); pp-safe-prefix is that,
; computed rather than assumed.
(import "prelude/prelude")        ; Str, I64, str-cat, str-len, i64->str
(import "prelude/list")           ; length, reverse -- ERASED param: (length Str ns)
(import "prelude/doc")            ; Doc, d-*, brk-*, doc-concat
(import "surface/syntax")         ; Term (16 arms), KArm, RfAtom, Seat
(import "typing/qtt")             ; Qty
(import "typing/refine")          ; SymOp

(module typing/pretty (cat A) (alt upper))

; ─── the two shapes every former has ─────────────────────────────────────────
; `parens`/`sp` were Str functions, so a paren pair and a group boundary were
; ONE object. Here they are three: d-text "(" is structure, d-line is the
; decision point, d-group is who decides. See §4.7.
(declare pp-lines (-> (List Doc) Doc))          ; a brk-space BEFORE each element
(declare pp-form  (-> Str (List Doc) Doc))      ; (kw d ...)
(declare pp-call  (-> (List Doc) Doc))          ; (head d ...)

(def pp-lines
  (lam (ds)
    (case ds
      (nil (d-text ""))
      ((cons d rest) (d-cat (d-cat (d-line (brk-space)) d) (pp-lines rest))))))

(def pp-form
  (lam (kw ds)
    (d-group
      (d-cat (d-text "(")
        (d-cat (d-tag "term-kw" (d-text kw))
          (d-cat (d-nest 2 (pp-lines ds)) (d-text ")")))))))

(def pp-call
  (lam (ds)
    (case ds
      (nil (d-text "()"))                       ; unreachable: a spine has a head
      ((cons h rest)
        (d-group
          (d-cat (d-text "(")
            (d-cat h (d-cat (d-nest 2 (pp-lines rest)) (d-text ")")))))))))

; ─── names ───────────────────────────────────────────────────────────────────
; The environment is INNERMOST-FIRST, matching the elaborator's own ctx
; (push-all, surface.chiral:95; ctx-find counts from the head). The old file
; used the opposite convention and its own nlen/get-at -- both deleted: nlen was
; a live duplicate of lowering/tal/erase.chiral:34, and both are prelude/list's
; `length` under another name.
(declare pp-fresh   (-> Str (List Str) Str))     ; prefix, env -> the new binder
(declare pp-name-at (-> (List Str) I64 Str))     ; env, index -> a name, or "#i"

(def pp-fresh (lam (p ns) (str-cat p (i64->str (length Str ns)))))

; "#i" for an out-of-range index keeps the printer TOTAL over any Term, in scope
; or not. It is the one output that is not source, and it means the term was
; malformed -- which is worth seeing rather than crashing on.
(def pp-name-at
  (lam (ns i) ; … walk ns for i; (str-cat "#" (i64->str i)) when it runs out
    ""))                                        ; Str, not Doc -- see the declare

; ⚑ THE ONE CORRECTNESS OBLIGATION, computed. "x" unless the terms carry a free
; name of the form x<digits>; otherwise a prefix LONGER than every free name,
; which cannot equal one. Two branches, both total, no search. It takes a LIST
; because r-mismatch prints two terms and they must share a vocabulary.
(declare pp-free-names  (-> Term (List Str) (List Str)))   ; global/prim/primty/con/tcon
(declare pp-safe-prefix (-> (List Term) Str))

; ─── the leaf spellings ──────────────────────────────────────────────────────
; pp-qty is NOT dg-qty-name: that one prints "omega" (diag.chiral:286) and the
; surface token is `w` (parse.chiral:55). Two spellings, two functions, neither
; a duplicate of the other.
(declare pp-qty  (-> Qty Str))
(declare pp-seat (-> Seat Str))
(declare pp-op   (-> SymOp Str))
(declare pp-quote(-> Str Str))                  ; \n \t \" \\ and NOTHING else

(def pp-qty  (lam (q) (case q ((q0) "0") ((q1) "1") ((qw) "w"))))
(def pp-seat (lam (s) (case s ((s-pure) "->") ((s-proc) "=>"))))
; ⚑ NOT spelled `symop->s`: that name is taken, at
; lowering/upper/closconv-driver.chiral:31, and typing/ may not import lowering/.
(def pp-op   (lam (o) (case o ((s-ge) ">=") ((s-gt) ">") ((s-le) "<=")
                             ((s-lt) "<")  ((s-ne) "!="))))

; ─── the walk: sixteen arms, no catch-all ────────────────────────────────────
(declare pp-term  (-> Str (List Str) Term Doc))
(declare pp-args  (-> Str (List Str) (List Term) (List Doc)))
(declare pp-spine (-> Str (List Str) Term (List Doc) (List Doc)))  ; app spine, flattened
(declare pp-arms  (-> Str (List Str) (List KArm) (Maybe Term) Doc))
(declare pp-atoms (-> Str (List Str) (List RfAtom) (List Doc)))

(def pp-term
  (lam (p ns t)
    (case t
      ((t-var i)     (d-tag "term-var" (d-text (pp-name-at ns i))))
      ((t-type n)    (pp-form "type" (cons (d-text (i64->str n)) nil)))

      ; (-> (q x DOM) COD) / (=> …). The quantity is ALWAYS emitted, tagged --
      ; see §4.4. The Seat picks the keyword; it is a token, not a default.
      ((t-pi q s dm cd)
        (let (nm (pp-fresh p ns))
          (pp-form (pp-seat s)
            (cons (pp-call (cons (d-tag "term-qty" (d-text (pp-qty q)))
                           (cons (d-text nm)
                           (cons (pp-term p ns dm) nil))))
            (cons (pp-term p (cons nm ns) cd) nil)))))

      ((t-lam bd)
        (let (nm (pp-fresh p ns))
          (pp-form "lam" (cons (pp-call (cons (d-text nm) nil))
                         (cons (pp-term p (cons nm ns) bd) nil)))))

      ; ⚑ THE SPINE IS FLATTENED. t-app is binary and left-nested; the surface
      ; is n-ary, and -- the layout reason -- nested groups cannot break an
      ; argument list as ONE decision. ((f a) b) parses back correctly and is
      ; still wrong here. See §2 finding 9.
      ((t-app f a)   (pp-call (pp-spine p ns t nil)))

      ((t-let q v bd)
        (let (nm (pp-fresh p ns))
          (pp-form "let"
            (cons (pp-call (cons (d-tag "term-qty" (d-text (pp-qty q)))
                           (cons (d-text nm)
                           (cons (pp-term p ns v) nil))))
            (cons (pp-term p (cons nm ns) bd) nil)))))

      ; ⚑ REVERSED. The field order is (tm ty); the surface is (the ty e).
      ((t-ann tm ty) (pp-form "the" (cons (pp-term p ns ty)
                                    (cons (pp-term p ns tm) nil))))

      ((t-global n)  (d-tag "term-name" (d-text n)))
      ((t-prim n)    (d-tag "term-name" (d-text n)))
      ((t-primty n)  (d-tag "term-name" (d-text n)))
      ((t-lit-i v)   (d-tag "term-lit"  (d-text (i64->str v))))
      ((t-lit-s v)   (d-tag "term-lit"  (d-text (pp-quote v))))

      ; `dn` is NOT printed: resolve recovers the home from the sig
      ; (surface.chiral:125) and the surface has no qualified-constructor form.
      ; Nullary prints bare -- (Nil) is not a surface application.
      ((t-con dn cn args)
        (case args
          (nil (d-tag "term-name" (d-text cn)))
          (_   (pp-call (cons (d-tag "term-name" (d-text cn))
                              (pp-args p ns args))))))
      ((t-tcon dn args)
        (case args
          (nil (d-tag "term-name" (d-text dn)))
          (_   (pp-call (cons (d-tag "term-name" (d-text dn))
                              (pp-args p ns args))))))

      ; NOT "(case ...)" -- the Python baseline elides it (pretty.py:53) and a
      ; source printer may not. Arms are one per HARD line; the default is the
      ; `_` arm (parse-arm, parse.chiral:317-322).
      ((t-case sc ar df)
        (d-group
          (d-cat (d-text "(")
            (d-cat (d-tag "term-kw" (d-text "case"))
              (d-cat (d-nest 2 (d-cat (d-cat (d-line (brk-space)) (pp-term p ns sc))
                                      (pp-arms p ns ar df)))
                     (d-text ")"))))))

      ; (refine BASE (op operand) …) -- not the baseline's {b | v > 3}.
      ((t-refine bs ats)
        (pp-form "refine" (cons (pp-term p ns bs) (pp-atoms p ns ats)))))))

; the app spine, head-outermost, built by walking left and accumulating right.
(def pp-spine
  (lam (p ns t acc)
    (case t
      ((t-app f a) (pp-spine p ns f (cons (pp-term p ns a) acc)))
      (_           (cons (pp-term p ns t) acc)))))

; ⚑ one arm = one HARD line, and `nvars` fresh binders pushed in the order
; push-all/elab-arms use (surface.chiral:95, :251-259) -- the spec run must read
; those two sites rather than guess the direction.
(def pp-arms
  ; ⚑ EVERY branch is a PARENTHESISED (pattern body) PAIR -- parse-arms
  ; (parse.chiral:296-310) refuses anything else with "bad case branch (want
  ; (pattern body))". So an arm is `((cn x0 x1) BODY)`, NOT `(cn x0 x1) BODY`
  ; as two siblings, and the default is `(_ D)`. A nullary arm may be spelled
  ; `(cn BODY)` or `((cn) BODY)` -- parse-arm takes both (parse.chiral:317-332).
  (lam (p ns ar df) ; … one ((cn x0 …) BODY) per arm, d-line (brk-hard) between; then (_ D)
    (d-text "")))
```

**What is deliberately NOT in the snippet:** `pp-name-at`'s walk, `pp-free-names`'s
fold, `pp-quote`'s four escapes, `pp-args`/`pp-atoms`' maps and `pp-arms`' body —
all mechanical, none carrying a decision. What is written out is every place a
later run could get the *meaning* wrong: the reversed `t-ann`, the dropped `dn`,
the flattened spine, the always-emitted quantity, the innermost-first
environment, and the two names that may not be spelled the obvious way.

## 6. Use / modify notes

- **Lands in:** `lib/typing/pretty.chiral` (**replaced**, ~51 → ~180 lines) and
  `lib/typing/diag.chiral` (one `import`, three call sites, one `def` and one
  `declare` deleted). Plus a new `tools/test/pretty.sh` and
  `tools/test/samples/e181_pretty.prog`.
  **Not touched:** `lib/prelude/doc.chiral` — nothing is added to the algebra
  (§4.6), and two mutants in two other lanes' phases enforce that;
  `lib/surface/syntax.chiral` — E181 reads `Term`, it does not change it;
  `lib/protocol/render*.chiral`; `tools/test/{diag,doc,row,face,render-doc}.sh`
  — all five stay byte-unchanged (see G7), which finding 12 measures as
  *achievable* rather than merely intended.

- **⚑ The BUILD RULE applies to this element, and its deliverable is the first
  in this arc to enter the closure.** Finding 13 measures `typing/diag` inside
  `prog/compiler.prog`'s closure, so adoption pulls `typing/pretty` in with it.
  E174 and E175 recorded *"outside the closure → no fixpoint, no promotion"*
  about `protocol/render`, and E158 commit 4 about `protocol/render-doc` — but
  **c4 still carried the obligation** for its comment edit to `prelude/doc.chiral`
  and observed a byte-identical binary. **E181 is the first that must promote a
  CHANGED one.** The obligation is the full one: `B1 < blob > chirality.new`,
  test it, promote it, then run the promoted binary over the same blob and
  byte-compare — **and the new binary must be verified non-zero before `cmp`,
  because `cmp` of two empty files passes** (`HANDOFF-DIAGNOSTICS-ARC.md`, the
  binding decision under `protocol/render`). The blob moves (755,238 B today)
  whatever else happens, because `typing/diag` gains an import line.
  ⚑ **Do this against a re-promoted binary.** Finding 13's table measures
  `bin/chirality-bin` a generation behind the tree since the master merge
  (`bc321a8`): `B1(blob) ≠ B1` and `B1(blob)(blob) ≠ B1(blob)` today, with the
  fixpoint at the second generation. Whoever runs G9 on the stale binary will
  read a red row as E181's.

- **Conformance target — a NEW `tools/test/pretty.sh`, Phase 18** (13–17 are
  taken; 8–12 are names still owed and must not be reused). Lane A's phases are
  18–20; this takes the first.
  **⚑ Every row reads EMITTED OUTPUT, not shapes.** Nine toothless rows were
  found across this arc, and the classic form for a printer is a row that asserts
  the `Doc` tree has the constructors you expected — which is the same
  information twice. The fixture builds terms, calls `doc->str` at a stated
  width, and `put`s the result (`ports/stdio.port:11`); every comparison is in
  bash over those bytes. The fixture **makes no assertion and always exits 0**
  (E158 commit 4's second upgrade), and every mutant pins the **full verdict
  line**, so a mutant that reddens a row it was not paired with fails the same
  assertion as one that reddens nothing.

  ⚑ **Byte-exact goldens ARE correct here, and this is not a contradiction of
  `doc.sh:11-16`.** That header refuses to inherit E157's byte-identity because
  `dg-msg`'s *wording* is a choice, and pinning a choice freezes it. `pp-term`'s
  output is not a wording: `(lam (x0) x0)` is the grammar. Pinning it pins the
  language, which is the thing that must not drift.

  | | row | mutant that must redden it |
  |---|---|---|
  | **G1** | **All sixteen formers reach the output, byte-exact at width 10⁶.** One case per constructor plus `KArm` and `RfAtom`; each expected string written from the *grammar*, never captured from a run. | delete the `t-tcon` arm → `load: non-exhaustive case` (**measured**, §2 finding 14). ⚑ **Audit fix — the seventeenth-constructor mutant does NOT belong here.** `Term` is cased exhaustively by five other modules in the same blob (`typing/kernel`, `typing/diag`, `lowering/upper/closconv-driver`, `lowering/compile-front`, `module/loader`), and `load: non-exhaustive case` names no site — so a new constructor reddens for reasons that say nothing about `pp-term`, and would redden identically if `pp-term` had a `_` catch-all. Coverage is asserted by **arm deletion**, one arm at a time; that is the mutant with teeth |
  | **G2** | **⚑ `brk-soft` is never correct between atoms** (§4.5). The output at width 10⁶ and at width 12 must yield the **same TOKEN SEQUENCE**, tokenised the way `sexp.chiral`'s `is-delim` (`:72-74`) does it — whitespace, `(`, `)`, `"` and `;` END an atom. ⚑⚑ **Audit fix — the row as first written could not fail, and this is the ninth-plus instance of the arc's own hazard.** It borrowed `doc.sh`'s `dt-strip-ws` (`samples/e158_doc.prog:72-75`), which **deletes every whitespace byte** — exactly the byte the mutant removes. Under the mutant `(type 0)` becomes `(type0)` at wide width and `(type\n  0)` at width 12; strip-ws maps **both** to `(type0)`, and so does the clean printer's pair, so the row passes either way. **Whitespace must be a DELIMITER here, never deleted** — that inversion is the whole row. | swap `brk-space` for `brk-soft` in `pp-lines` → at wide width `(type 0)` fuses to `(type0)` and `(f a b)` to `(fab)`; the token sequences then differ between the two widths and the row convicts, and G1 convicts too, which is why G2 comes second. ⚑ Not `lam`/`x0`: `(` ends an atom, so `(lam(x0) …)` re-lexes correctly and never fuses — the fusion is only ever between two **atoms** |
  | **G3** | **The group decision happens on a real term.** A three-argument application: one line at width 40, one argument per line at width 12, indent exactly 2. | replace `d-group` with its body in `pp-call` → always broken; drop the `d-nest 2` → indent 0. Two mutants, two named lines |
  | **G4** | **The spine is flat.** `(t-app (t-app f a) b)` prints `(f a b)`, not `((f a) b)`. | restore the binary arm (`pp-form`-per-`t-app`) — the Python baseline's shape |
  | **G5** | **⚑ THE CONTROL THAT STATES THE WIN, and it is doc.sh case 14's shape one layer down.** `(t-let (qw) …)` emits `w` and `(t-pi (q1) …)` emits `1`. Both round-trip either way (finding 7), so this row is asserting a *choice about evidence*, and it must be able to fail. | elide `w` as the default — the Python baseline's `q = "" if t[1] == terms.W` |
  | **G6** | **No invented name shadows a free one.** A term containing `(t-global "x0")` under one binder: the binder must not print `x0`, and `x0` must still print as `x0`. | hardcode the prefix to `"x"` (delete `pp-safe-prefix`'s second branch) → the binder prints `x0` and the row convicts |
  | **G7** | **Adoption is real and the frozen gates did not move.** `dg-term-tag` has **zero** call sites and zero definitions left; `typing/diag` imports `typing/pretty`; `diag.sh`, `doc.sh`, `row.sh`, `face.sh` and `render-doc.sh` are byte-identical by sha256 (five pins now, not four). ⚑ **Assemble every needle from fragments** — Phase 17's E154 census went red on a clean tree because a mutant's `sed` expression spelled the needle in the gate script, and this gate greps `tools/` too. | re-add one `dg-term-tag` call in `diag.chiral` → the census sees it; and any edit to one of the five pinned scripts |
  | **G8** | **⚑ THE ROW THAT CAN ONLY PASS AFTER THE REWRITE.** A probe root importing `typing/pretty` **and** `surface/syntax` **and** `lowering/tal/erase` compiles. Today it is refused twice over — `load: data redeclared: Term` and `duplicate label … nlen` (§2 finding 3, both measured). | restore the local `Term` (or the local `nlen`) → the original refusal returns, verbatim |
  | **G9** | **The compiler still builds itself.** Phase-agnostic, but it belongs on this element's checklist because it is the first in the arc whose **deliverable** enters the closure: build-new → test → promote → byte-compare (finding 13). ⚑ **The new binary must be checked non-zero before `cmp`** — `cmp` of two empty files passes, and that is a standing binding decision, not a nicety. ⚑ **Precondition:** finding 13 measures `bin/chirality-bin` a generation stale today; run this against a re-promoted binary or the row convicts E181 of the master merge's residue. | not a mutant row — a BUILD RULE step, and it fails by not reproducing. Its one *checkable* control is the emptiness guard: point the `cmp` at two zero-byte files and it must refuse, not pass |

  Fixture placement follows E174/E175: every term is spelled **once** and read by
  every row, so a width row and a byte row can never be describing two different
  fixtures. ⚑ And the fixture lives under `tools/`, which is inside a
  neighbouring gate's scan surface — Phase 16 went red once because a fixture's
  line breaks tripped `face.sh`'s line-based arity scanner. **Its formatting is
  part of its contract.**

- **Open questions — the honest residue. Nothing here is deferred to an element
  that does not exist; where a follow-on would be needed I name the band and
  stop.**

  1. **Does `dg-term-tag` really go, and what does the diagnostic look like
     afterwards?** §4.1 says yes and finding 12 measures that Phase 14 survives
     it. The cost is real and should be seen before it is accepted: for the seven
     `Term` arms with no name payload, `dg-term-tag` prints prose (`"a lambda"`,
     `"an application"`) and `pp-term` prints structure — so an `r-mismatch`
     between two large function types gets **longer**. That is what E157 widened
     the payload *for*, and the answer is the width argument at the exit, not a
     flattener kept alive beside the printer. ⚑ But note the third call site,
     `dg-decl-doc`'s `dc-ty` arm, is **graded by nothing today** (finding 12);
     if it is changed, G1 must gain a row for it or the change is unmeasured.
  2. **The round-trip is not asserted by E181, and it is the property the whole
     design is for.** `parse` + `elab` + `core->term` lives behind
     `lib/module/loader.chiral`, which `typing/` does not and **cannot** import
     once E181 lands: `loader.chiral:14` imports `typing/diag`, and E181 makes
     `typing/diag` import `typing/pretty` — so a `typing/pretty → module/loader`
     edge would close a cycle. The direction argument is a structural refusal,
     not a preference.
     So E181's gate pins the *text* (G1) and E146's gate pins the *law*
     (`parse(source(v)) ≡ v`) — which is Lane B's, by `docs/decisions/decision-lane-split.md`. **This is a
     seam between the lanes and it should be written into E146's SPEC**, not
     assumed. If it needs a Lane-A element of its own, the number is in
     **E184–E189** and **this pre-run cannot mint it**; it is named, not shelved.
  3. **Five new `d-tag` keys** — `term-kw`, `term-var`, `term-lit`, `term-name`,
     `term-qty` — are free at the renderer (finding 15) and are exactly the
     ad-hoc population **E179** (already minted, Lane A queue #4) exists to make
     authoritative. E181 should not pre-empt E179's registry design; it should
     add its keys the way `dg-doc`'s thirteen sites already do, and E179 should
     inherit eighteen sites instead of thirteen.
  4. **`pp-name-at`'s `"#i"` fallback is the one output that is not source.**
     It is kept because it makes the printer total over a malformed term, and
     because a `#3` in a diagnostic is worth seeing. It does mean G1 cannot claim
     *"every output of `pp-term` re-parses"* without a well-formedness side
     condition. Stated, not smoothed over.
  5. **A `Term` printer is not a `Core` printer, and E146 may discover it wants
     the latter.** Finding 4: `Core` still has the author's names, and anything
     emitting source *from the elaborator's output* would rather print those than
     invent. E181 is correct for the checker's `Term` — which is what
     `r-mismatch` carries and what E146's catalog row names — and a second walk
     over `Core` would be the duplicate-owner defect again. Recorded so the E146
     SPEC rejects it deliberately rather than never considering it.
  6. **`nlen`'s duplicate is fixed as a side effect, and that should be a
     deliberate line in the SPEC** rather than a silent consequence of deleting
     the file's contents. It is a live E154 violation (finding 3) that no gate
     can currently see; G8 is the row that makes it visible.

- **Related:** [[E158-doc-formatter]] (the algebra this consumes, and `dg-doc`,
  whose `r-mismatch` arm is the forcing call site — E181 is `Doc`'s first
  consumer outside the arc's own modules) · [[E157-typed-diagnostics]] (`Reason`
  carries the two `Term`s; its goldens must not move) · [[E175-face-restore]] and
  [[E174-r-row-width]] (built beneath E158; untouched here) · **E146** value→source
  (Lane B — E181 is its prerequisite, and open question 2 is the seam) · **E179**
  the face registry (open question 3) · **E173** the total matcher (drafted on
  master; unrelated to this walk).
