---
element: E181
slug: pretty-term-doc
title: **A term printer that prints the checker's terms** — `typing/pretty.chiral` repointed at the real sixteen-constructor `Term`, returning `Doc`, and adopted by `dg-doc`
kind: BUILD-PROPER
example: docs/examples/E181-pretty-term-doc.md
status: audited
updated: 2026-08-31
---

# E181 SPEC — **A term printer that prints the checker's terms**

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

> **⚑ The pack did not run, and was not repointed.** `tools/pack/pack.py` probes
> `examples/`; this tree's corpus is `docs/examples/`, and
> `tools/pack/MIGRATION-NOTES.md` records the tool as **not repointed on
> purpose**. Per the brief this SPEC was written **by hand** against the tree —
> the disposition E158's, E174's and E175's SPECs took. Every citation, count,
> byte string and blob size below was **read or executed live on 2026-08-31** in
> `/workspace/chirality-verify` @ `e158-doc` (`b634630`).
>
> **⚑ THE WHOLE ELEMENT WAS BUILT AND RUN IN A SCRATCH TREE BEFORE THIS FILE WAS
> WRITTEN.** A full replacement `lib/typing/pretty.chiral` (30 bindings, all
> sixteen `Term` arms) plus the three-site adoption in `lib/typing/diag.chiral`
> was assembled in `/workspace/e181-probe/tree` (a **real directory copy**, `lib`
> verified not a symlink) and `tools/test/run-tests.sh` was run against it:
> **`242 passed, 0 failed`, `gate PASSED`, 88 roots built** — byte-for-byte the
> same verdict as the clean tree, with Phases 13/14/15/16/17 unchanged at
> 30/26/41/38/19. **Eight of §5's mutants were executed** against that tree and
> each convicted at a named output line or a named compiler error. The full
> BUILD RULE was run end to end: blob **755,238 → 764,555 B**, new binary
> **1,147,256 B**, suite green **under the new binary**, and **`N1 == N2`** —
> the fixpoint at generation one. So the numbers below are measurements, not
> predictions, and where one contradicts the example it is called out in §6.
> **The probe tree is torn down; §6 carries the RUN log.**

## 1. Deliverable

- **After this runs:** `lib/typing/pretty.chiral` is **replaced** — its own
  five-constructor `Term` (`:15-20`), its `Str`-typed `show-term`, and its six
  hand-rolled helpers (`sp`, `parens`, `names-snoc`, `nlen`, `get-at`,
  `nth-name`) are gone, and in their place is a **`(-> Str (List Str) Term Doc)`
  walk over `lib/surface/syntax.chiral`'s real **sixteen**-constructor `Term`,
  with **no `_` catch-all**, so a seventeenth former is a compile error rather
  than a silent `<Whatever>`. 51 lines → ~200. Thirty bindings, every one
  `pp-`-prefixed and every one censused to zero pre-existing hits (§2).

- **`lib/typing/diag.chiral` adopts it and `dg-term-tag` retires.** One
  `import`, three call sites (`:544`, `:547`, `:663`), one `declare` (`:506`)
  and one `def` (`:669-687`) deleted. `r-mismatch`'s two terms share **one**
  invented vocabulary through a `let`-bound prefix; `dg-decl-doc`'s `dc-ty` arm
  takes the single-term convenience. **Measured effect on the forcing consumer:**

  | | today (`dg-term-tag`) | after E181 |
  |---|---|---|
  | `r-mismatch` of two `t-primty` | `type mismatch (none) expected I64 actual Str` | **identical bytes** |
  | `r-mismatch` of two `t-pi` | `… expected a function type actual a function type` | `… expected (-> (1 x0 I64) Str) actual (=> (w x0 Str) I64)` |
  | the same at width 20 | *(unchanged — nothing to break)* | the arrow breaks and indents under `expected` |

  The first row is why **Phase 14 stays green and `doc.sh` is not touched**: its
  case 7 grades `r-mismatch` over exactly the two terms on which the flat
  accessor and the source printer agree. That was luck in the example; it is now
  a run.

- **A new Phase 18** — `tools/test/pretty.sh` + `tools/test/samples/e181_pretty.prog`,
  registered in `run-tests.sh` and `tools/test/MIGRATION-NOTES.md`. **Every row
  reads EMITTED OUTPUT**, never the shape of a `Doc` tree: the fixture builds
  terms, calls `doc->str` at a stated width and `put`s the bytes
  (`lib/ports/stdio.port:11`); every comparison is in bash over those bytes. The
  fixture **makes no assertion and always exits 0**; every mutant is RUN.

- **⚑ `bin/chirality-bin` is rebuilt and promoted.** E181 is the first element in
  this arc whose **deliverable enters `prog/compiler.prog`'s closure**:
  `typing/diag` is in the blob, so `typing/diag` importing `typing/pretty` pulls
  the printer in with it. Measured: blob **755,238 → 764,555 B** (57 modules +
  the root, before and after), emitted compiler **1,130,872 → 1,147,256 B**,
  **`N1 == N2`**. See decision 19 and §4's Commit 3 for the sequence and for the
  precondition that keeps a merge's residue from being read as E181's defect.

- **Non-goals** (each with a home, and every follow-on already MINTED):
  - **`Doc` gains nothing.** Its algebra is closed at six constructors and E181
    adds nothing to it. `lib/prelude/doc.chiral` is **not touched** — and two
    mutants in two other lanes' phases (`doc.sh` M5, `render-doc.sh` M10) redden
    if it is. The thing that looked like a gap ("a token that must not be broken
    from its neighbour") is `d-text` of the whole token.
  - **E179 — the face registry.** E181 introduces five `d-tag` keys (`term-kw`,
    `term-var`, `term-lit`, `term-name`, `term-qty`) the way `dg-doc`'s thirteen
    sites already do. `lookup-face` synthesizes `(face name -1 -1 0)` for an
    unknown key (`lib/protocol/render.chiral:164-167`) and `d-tag` is zero-width
    in **both** `doc-fits` (`:123`) and `doc-best` (`:151`), so a new key can
    never move a break and never fails. E179 inherits **eighteen** ad-hoc sites
    instead of thirteen. Minted (`SELF-IMPLEMENT-CATALOG.md:443`).
  - **E176 — `str-sub` is unclamped and segfaults.** E181 does not fix it and
    **does not build on it**: decision 6 forbids `str-sub` and
    `str-starts-with` anywhere in `pretty.chiral`. Minted (`:440`).
  - **E146 value→source** is **Lane B's** and E181 must not pre-empt it. E181 is
    its prerequisite and the round-trip law is the seam (decision 23).
  - **`lib/surface/syntax.chiral`** — E181 *reads* `Term`; it does not change it.
  - **`lib/protocol/render*.chiral`**, `lib/prelude/{doc,string,list}.chiral`,
    and **all five existing gate scripts** — `diag.sh`, `doc.sh`, `row.sh`,
    `face.sh`, `render-doc.sh` — stay **byte-unchanged**. §5 G8 is that as a
    checked row with five sha256 pins.
  - **`doc.sh:36-37`'s sentence** — *"any `pretty.chiral` behaviour"* is named there
    as not a row of Phase 14, and it stays true after E181: `pretty.chiral`'s
    behaviour is Phase 18's. Nothing to correct, and `doc.sh` may not move
    anyway.

## 2. Baseline (what already exists — do NOT respec these)

**The target, re-measured.** `lib/typing/pretty.chiral` is 51 lines. It declares
`(data Term () (t-type) (t-var) (t-lam (nm Str) …) (t-app) (t-let (nm Str) …))`
at `:15-20` — **five** formers, and its `t-lam`/`t-let` carry an `nm Str` the
real ones do not. `show-term : (-> (List Str) Term Str)` (`:40`) flattens at
every step. `sp` (`:22`) and `parens` (`:23`) are `Str` functions.

**`Term` has SIXTEEN constructors**, not fifteen: `lib/surface/syntax.chiral:18-34`,
where `t-lit-i` and `t-lit-s` share line `:30`. Plus `KArm` (`:35`), `RfAtom`
(`:15`) and `Seat` (`:12`). `lib/typing/diag.chiral:501` already says *"the real
16-constructor `Term`"*.

**⚑ The file is UNIMPORTABLE, not merely unimported — both refusals reproduced
this session**, verbatim:

```
(import "typing/pretty") (import "surface/syntax")     -> load: data redeclared: Term
(import "typing/pretty") (import "lowering/tal/erase") -> duplicate label (an object def
                                                          collides with the linked runtime): nlen
```

`nlen` is defined at `pretty.chiral:28-29` **and** at
`lib/lowering/tal/erase.chiral:34-35`. It is the **only** defining duplicate in
the file — checked, not assumed: `^\((def|declare|extern|data) (nlen|get-at|nth-name|names-snoc|show-term|sp|parens)\b`
over `lib prog tools` returns `erase.chiral:34,35` and nothing else. **Both
colliding modules are themselves inside `prog/compiler.prog`'s blob**, so the
file could not have been adopted at all, and Phase 7 sweeps *roots*
(`grep -rl '^(def compile-main' lib prog`) — none of which reaches it. Its
current contents are verified by nothing.

**The names exist one layer up and the bridge drops them.**
`lib/surface/surface.chiral:52-64` declares `Core`, in which `c-pi` (`:55`),
`c-lam` (`:56`) and `c-let` (`:57`) each carry a `bname Str`.
`lib/module/loader.chiral:17-18` states the consequence in its own words —
*"Drops the surface-only binder NAMES (Term is de-Bruijn)"* — and `:39` is the
line: `((c-lam bn body) (t-lam (core->term body)))`.

**`resolve` searches locals first**, `lib/surface/surface.chiral:117-132`:
`ctx-find` before atoms, ctors, datas, globals, prims. That is the whole hazard
and it is one-directional.

**The elaborator's binder order**, which the printer adopts: `push-all` (`:95`)
conses each name on, `elab-arms` (`:251-259`) calls `push-all ctx vars`, and
`ctx-find` counts from the head. So for `(karm "Cons" 2 body)`, **index 1 is the
FIRST pattern variable and index 0 is the second.** Today's `pretty.chiral` uses
the opposite convention (`names-snoc` + `names[len-1-i]`, `:25-38`).

**The surface, and therefore the target grammar.** `parse-list`
(`lib/surface/parse.chiral:173-192`) dispatches on the head symbol —
`type -> => lam let case do cond the refine` — and everything else is an
application. There is **no precedence to recover**. A quantity token is `0`, `1`
or the symbol `w` (`is-quant`, `:50-56`); `try-qbinder` (`:61-80`) reads a
`(q name rhs)` triple for arrow binders, let bindings and fields alike, and
binders default to `2` (= `qw`) when the token is absent — so printing the
quantity and eliding it **both round-trip**. `parse-let` (`:251-270`) accepts a
single `(q name rhs)` binding, which is exactly `t-let`'s shape. A case branch
must be a parenthesised `(pattern body)` pair (`parse-arms`, `:296-310`) — the
error text is `bad case branch (want (pattern body))` — and `parse-arm`
(`:314-333`) takes a bare ctor symbol, a `(ctor x y)` list, or `_` for the
default. A refinement atom is `(op operand)` (`parse-ratoms`, `:393`), with the
ops spelled `>= > <= < !=` (`loader.chiral:21-24`, `SymOp` at
`lib/typing/refine.chiral:11`). `t-ann`'s fields are `(tm ty)`
(`syntax.chiral:25`) and the surface is `(the ty e)` (`parse-the`, `:219-230`).
Chirality's string escapes are `\n \t \" \\` and **nothing else**
(`lib/protocol/render.chiral:175-176`). An atom ends at whitespace, `(`, `)`,
`"` or `;` (`is-delim`, `lib/surface/sexp.chiral:74`).

**`Doc`, unchanged.** Six constructors, `d-text` atomic, `d-line` the only place
a line is introduced, `d-tag` zero-width, no `d-union`
(`lib/prelude/doc.chiral:77-83`; the no-`d-union` reasoning is the comment at
`:70-76`, and `Brk` is `:65-68`). `brk-hard` never flattens — `doc-fits` returns
false the moment it meets one in flat mode: the CODE is `((brk-hard) false)` at
**`:131`**; `:60-64` is the comment that states it.

**What `prelude/list` actually has**: `any-list append cat-maybes concat dd-skip
filter find foldl foldr head length list-dedup-adj list-sort map-list ms-* rev-onto
reverse`. **There is no index/`nth`** — so `pp-name-at` is written here, not
imported (correcting the example, §6).

**The compiler's closure, measured this session.** `prog/compiler.prog`'s blob is
**755,238 bytes**, **57 `(end-module …)` markers plus the un-marked root** (the
root gets none — `chirality-resolve.sh`'s `chirality_blob_file`, deliberately).
It contains `dg-term-tag` **7×** and `(end-module "typing/diag")` /
`(end-module "prelude/doc")`; `show-term` and `(end-module "typing/pretty")`
appear **0×**.

**⚑ `bin/chirality-bin` is at its own fixpoint TODAY** — re-measured after
master's promotion at `b634630`: `bin/chirality-bin < blob > C1` gives
**1,130,872 bytes, byte-identical to `bin/chirality-bin`**. The example's finding
13 measured it one generation stale (`B1 ≠ C1 ≠ C2 = C3`); that was the master
merge's residue, it was promoted to `C2` by the author, and **the staleness is
gone**. What survives is the *class*, and §5's G9-precondition is the guard.

**E154 census for every name E181 introduces**, word-boundaried
(`(^|[^A-Za-z0-9_-])NAME([^A-Za-z0-9_-]|$)`) over `lib prog tools`, excluding
`pretty.chiral` itself — **thirty names, zero hits, all of them**:
`pp-lines pp-form pp-call pp-fresh pp-name-at pp-free-names pp-free-list
pp-free-arms pp-free-atoms pp-free-mb pp-xlike pp-xlike-go pp-any-xlike
pp-max-len pp-safe-prefix pp-qty pp-seat pp-op pp-esc1 pp-esc-go pp-quote
pp-term pp-term-doc pp-args pp-spine pp-arms pp-arm pp-arm-go pp-atoms pp-of`.
⚑ **The census must be word-boundaried**: a fixed-string `grep -F pp-args`
returns 16 hits, every one of them `app-args` in
`lib/lowering/upper/closconv.chiral`.
⚑ `symop->s` **already exists**, at `lib/lowering/upper/closconv-driver.chiral:31`
with the identical body — so `pp-op` may not be spelled that way, and
`typing/` importing `lowering/` is the wrong direction anyway. `dg-qty-name`
(`diag.chiral:286`) prints `"omega"` where the surface token is `w`, so `pp-qty`
is a second function and not a duplicate.

**The suite, live, clean tree**: `242 passed, 0 failed`, `gate PASSED`,
88 compile-only roots. Phase tallies 6 · 7 · 31 · 12 · 32 · 30 · 26 · 41 · 38 · 19.
⚑ The handoff's *"268 assertions"* does **not** reproduce; the top line
`run-tests.sh` prints is **242** and the tallies sum to 242 (§6).

## 3. Decisions

Every row is **RESOLVED with a citation**, **BINDING** (settled by the example
and re-verified here), or **DEFERRED to a MINTED element**. Nothing is silently
resolved, and **no `NEEDS-AUTHOR` row remains** — the one this SPEC raised
(decision 20) was answered by the author at `e43e349`.

| # | Question | Disposition | Rationale / owner |
|---|---|---|---|
| 1 | One printer or two — a "pretty" one for diagnostics and a faithful one for E146? | **BINDING — ONE, and its output is SOURCE** | `LANES.md` forbids Lane B writing a term printer, so E181 must be the printer E146 uses or Lane B is blocked or in violation. Two printers over one sum is the duplicate-owner defect this repo has fixed four times (`str-cmp`, `list-sort`, `list-dedup-adj`, `Ord`) — and `dg-term-tag` is the live fifth. The "a display form would be nicer" premise is false here: the surface is S-expressions, so the source form *is* the readable form. ⚑ **Do NOT lean on a gate for this.** `doc.sh`'s G6 enumerates only `lib/prelude/doc.chiral`'s own bindings; a Lane-B printer under different names is **not** mechanically caught. The enforcement is `LANES.md` file ownership plus review. |
| 2 | De Bruijn: invent names, or print indices? | **BINDING — INVENT, and the question dissolves** | `Term` is nameless (`loader.chiral:17-18,39`), so an invented name is not a lossy approximation of a lost name — it is a **free choice**, and any naming that resolves back to the same indices is exactly right. Between invented names there is no hazard **by construction**: the binder at depth `d` is `prefix ++ d`, and two binders in scope simultaneously have different depths. Against **free** names there is one hazard in one direction (decision 5). |
| 3 | Print `#0` instead and skip the whole apparatus? | **REFUSED, with its cost named** | It needs no prefix and no environment. It is also not chirality source (killing decision 1), and it is **less** readable in exactly the case that motivates the element — an `r-mismatch` between two function types where every `#0` means something different. Measured: `expected (-> (1 x0 I64) Str) actual (=> (w x0 Str) I64)`. |
| 4 | Elide the default quantity `w`? | **BINDING — NEVER. Always printed, tagged** | Both forms round-trip (`parse-binder`/`parse-lbind` default to `2`), so this is a choice about **evidence**, and the arc already made it one layer up: `doc.sh` case 14 is a control row whose whole content is that `dg-msg` drops both quantities and `dg-doc` keeps them. Eliding by default is the printer deciding on the reader's behalf. The quantity rides inside `(d-tag "term-qty" …)`, zero-width in both `doc-fits:123` and `doc-best:151`, so a consumer can dim or drop it at the **exit**, where the width and the faces already are, and the value is never destroyed. Same for `Seat`: `->` vs `=>` is the effect membrane, a token and not a defaultable field. |
| 5 | The invented-name obligation, and how it is discharged | **BINDING — a COMPUTED prefix, `pp-safe-prefix : (-> (List Term) Str)`** | `resolve` (`surface.chiral:117-132`) searches locals first, so the hazard is **not** capture-avoidance: it is a `t-global "x0"` printed under an invented binder named `x0` re-elaborating to the binder. One direction, and computable from the term. It takes a **`(List Term)`** and not a `Term` because `r-mismatch` prints **two** terms and they must share one vocabulary or the diagnostic invents two for one comparison. |
| 6 | ⚑ How the escape branch is spelled — and what it may NOT call | **RESOLVED — a prefix LONGER than every free name; and NO `str-sub`, NO `str-starts-with`** | **(a) The shape, per the author (FLAG 3, answered):** `"x"` unless some free name has the form `x⟨digits⟩`; otherwise `(bytes->str (brepeat (str->bytes "x") (+ maxlen 1)))` — a run of x's one longer than the longest free name, so `prefix ++ digits` **cannot equal** any free name. Two branches, both total, no search and no counter threaded through the walk. The alternative (`x`, `x_`, `x__`, …) buys cosmetics in a rare branch at the price of needing its own correctness argument; a proof is not traded for typography. **The ugliness is real and is accepted, measured:** `(t-lam (t-app (t-global "x0") (t-var 0)))` prints **`(lam (xxx0) (x0 xxx0))`**. **(b) The implementation may not use `str-sub` or `str-starts-with`** — `str-sub` is unclamped and **segfaults** (E176, minted, `SELF-IMPLEMENT-CATALOG.md:440`), and `str-starts-with` (`prelude/string.chiral:15-17`) is *built on the false comment that it clamps*. The x⟨digits⟩ test is therefore byte-level: `str->bytes`, `blen`, `bget`, first byte `120`, the rest in `48..57`. Building E181 on a known segfault to save six lines would be the exact defect E176 exists to record. |
| 7 | Does `Doc` need a seventh constructor? | **BINDING — NO, and nothing in `lib/prelude/doc.chiral` is touched** | The candidate ("a token that must not be broken from its neighbour") is already `d-text` of the whole token, or a `d-cat` with no `d-line` between the parts. Enforced, not agreed: `doc.sh` **M5** and `render-doc.sh` **M10** add an arm and assert the compile is refused. If a later element genuinely needs one, that is an **element** — and the pattern is E158's own: a separate type that **converts into** `Doc`, the way `doc->rendering` does. |
| 8 | What happens to `parens` and `sp`? | **BINDING — SPLIT into three objects; that split IS the rewrite** | `(parens (sp a b))` makes the paren pair and the grouping decision **one `Str`**, so neither can be chosen later. In `Doc` they are `d-text "("` (structure, always emitted), `d-line (brk-space)` (a decision point) and `d-group` (who decides). Everything else follows. |
| 9 | Does `dg-term-tag` really retire at all three sites? | **RESOLVED — YES, at `:544`, `:547`, `:663`, and it is measured rather than hoped** | The whole suite under the adopted tree reports **`242 passed, 0 failed`, gate PASSED, 88 roots** — byte-identical to the clean verdict, Phase 14 at **26/26**. The reason Phase 14 survives: `samples/e158_doc.prog:169-171` grades `r-mismatch` over `(t-primty "I64")`/`(t-primty "Str")`, and the flat accessor's `t-primty` arm (`diag.chiral:681`) and the source printer's both emit the bare name — **measured identical bytes**: `type mismatch (none) expected I64 actual Str`. That matters because `doc.sh` is one of five scripts §5 G8 pins. |
| 10 | Two entry points, or one? | **RESOLVED — TWO, and the second is not sugar** | `pp-of : (-> Str Term Doc)` takes an explicit prefix and is what `r-mismatch` uses, `let`-binding **one** prefix over both terms. `pp-term-doc : (-> Term Doc)` computes the prefix from the single term and is what `dg-decl-doc`'s `dc-ty` arm uses. Collapsing them would either lose the shared vocabulary or push a prefix argument into every one-term call site. |
| 11 | The environment's direction | **RESOLVED — innermost-first, the elaborator's own, and MEASURED** | `push-all` (`surface.chiral:95`) and `elab-arms` (`:251-259`) cons; `ctx-find` counts from the head. So for `(karm "Cons" 2 (t-app (t-var 1) (t-var 0)))` the printer must emit **`((Cons x0 x1) (x0 x1))`** — index 1 is the first pattern variable. Measured exactly that. Today's file uses the opposite convention, which is a second spelling of one fact and is deleted. |
| 12 | `t-ann`'s field order | **BINDING — REVERSED at the printer** | `(t-ann (tm Term) (ty Term))` (`syntax.chiral:25`) against `(the ty e)` (`parse-the`, `parse.chiral:219-230`). Emitting fields in declaration order silently produces a term that re-elaborates to a **different** annotation. Measured: `(t-ann (t-lit-i 1) (t-primty "I64"))` prints `(the I64 1)`. |
| 13 | `t-con`'s `dn` and `t-tcon`'s `dn` | **RESOLVED — `dn` is NOT printed** | `resolve` recovers the home from the signature (`surface.chiral:124-127`, `(assoc name (se-ctors sig))`), and the surface has **no qualified-constructor syntax** — printing `dn` would not parse. `t-tcon`'s `dn` *is* the type's name and is printed as the head. |
| 14 | Nullary `t-con` / `t-tcon` | **RESOLVED — printed BARE** | `(Nil)` is a surface *application* of `Nil` to nothing, not a constructor reference; `resolve` gives `(c-con home name nil)` for the bare symbol. Measured: `Nil`, `Unit`. |
| 15 | `t-case`: the arm shape, the default, and the break | **RESOLVED — parenthesised `(pattern body)` pairs, `(_ D)` for the default, `brk-hard` between arms** | `parse-arms` (`parse.chiral:296-310`) refuses anything else with `bad case branch (want (pattern body))`, so an arm is `((cn x0 x1) BODY)` and **never** two siblings. A nullary arm is spelled `((cn) BODY)` — `parse-arm` accepts both that and the bare-symbol form. `brk-hard` is the same call `dg-chain-doc` makes for E97's frames (`diag.chiral:704`): one arm per line by **intent**, not by width. ⚑ **The measured consequence, stated rather than smoothed over:** `doc-fits` refuses a hard break in flat mode (`doc.chiral:131`; the comment is `:60-64`), so the enclosing group **never flattens** and a `(case …)` is multi-line at *every* width, 10⁶ included. **Flip condition, named so it is not a matter of taste:** if a consumer ever needs a one-line `case`, the change is `brk-space` between arms plus a gate row at two widths — an element, not a tweak, because it changes what E97's own convention means. |
| 16 | `pp-name-at`'s out-of-range fallback | **RESOLVED — keep `"#i"`** | It makes the printer **total** over any `Term`, in scope or not, and a `#3` in a diagnostic is worth seeing rather than crashing on. It is the one output that is not source, so §5 G1 cannot claim *"every output re-parses"* without a well-formedness side condition. Stated, not smoothed. |
| 17 | Which phase number? | **RESOLVED — 18** | `run-tests.sh:10-27` and `tools/test/MIGRATION-NOTES.md:19-31` record **8–12 as names still owed** to unported old-tree phases; reusing one would make an unported gate look ported. 13–17 are taken (E157/E158/E174/E175/E158c4). `LANES.md` gives Lane A **18, 19, 20**; E181 takes the first. Registration in `run-tests.sh` is a **required line** and §5 makes it a checked row — an unregistered `pretty.sh` is a gate that never runs. |
| 18 | Byte-exact goldens — legal here, or E157's mistake repeated? | **RESOLVED — LEGAL, and this is not a contradiction of `doc.sh:11-16`** | That header refuses to inherit E157's byte-identity because `dg-msg`'s **wording** is a choice and pinning a choice freezes it. `pp-term`'s output is not a wording: `(lam (x0) x0)` **is the grammar**. Pinning it pins the language, which is the thing that must not drift. ⚑ Every expected string in §5 G1 was written from the grammar **before** the probe ran and then matched byte-for-byte; none was captured from a run and back-filled. |
| 19 | Does the fixpoint obligation fire? | **RESOLVED — YES, for the first time in this arc, and the full sequence is measured** | `typing/diag` is in the blob (7× `dg-term-tag`, `(end-module "typing/diag")`), so adoption pulls `typing/pretty` in. E174/E175/E158c4 each recorded *"outside the closure → no fixpoint"* about `protocol/render` and `protocol/render-doc` — their **deliverables**; E158 c2 was inside but its later edit was a **comment**, and it observed a byte-identical binary. **E181 is the first that must promote a CHANGED one.** Measured end to end: blob 755,238 → **764,555 B**; `B1 < blob2 > N1` = **1,147,256 B**; the whole suite green **under `N1`** (`CHIRALITY_COMPILE=N1`, 242/0, gate PASSED); `N1 < blob2 > N2`, **`N1 == N2`** — one generation. **The `cmp` is stability, never correctness** — Phase 18 is what says the printer is right. |
| 20 | ⚑ `LANES.md` said *"neither lane writes `bin/chirality-bin`"*, and E181 must | **RESOLVED by the author — `LANES.md` clarified at `e43e349`** | The clause contradicted the BUILD RULE it cited and has been rewritten (`LANES.md:89-102`): what is forbidden is **hand-editing it, or replacing it in place**; what is **required**, of a lane whose deliverable enters the compiler's closure, is to **promote** it — build-new → test → promote, fixpoint verified, the new binary checked non-zero before every `cmp`. **E181 is named there as the first element in this arc inside the closure, so E181 promotes.** Two obligations ride with it, and both are now change-plan steps rather than open questions: **(a)** the precondition — §4 Commit 3 Step 0 and §5 **G12(ii)**; **(b)** telling Lane B the moment the promotion lands — §4 **Commit 4**. |
| 21 | FLAG 2 — does `pretty.sh` carry the non-cross-assertion scan over itself? | **RESOLVED — YES, per the author** | `doc.sh`'s G7 scans **only** `doc.sh` and `samples/e158_doc.prog` (`gm_goldens "$HERE/doc.sh"`, `gm_in_fixture "$FIXTURE"`). A new gate that byte-asserted `dg-msg`'s wording would be legal and **unpoliced**. Extending the scan to the new pair is four lines and closes the hole before it is one. §5 **G10**, with mutant **M13**. |
| 22 | `nlen`'s duplicate | **RESOLVED — fixed as a DELIBERATE line, not a side effect** | It is a live E154 violation (`pretty.chiral:28` vs `erase.chiral:34`) that no gate can see, because nothing in the tree ever co-compiles the file. §5 **G9** is the row that makes it visible, and it is the one row that **cannot pass before the rewrite**. `get-at` and `nth-name` are deleted for a different reason — the walk is written here, since `prelude/list` has **no index function** (§2). |
| 23 | The round-trip law — who asserts `parse(source(t)) ≡ t`? | **DEFERRED to E146 (Lane B), and the direction is a STRUCTURAL refusal** | `parse` + `elab` + `core->term` lives behind `lib/module/loader.chiral`, which `typing/` does not and **cannot** import once E181 lands: `loader.chiral:14` imports `typing/diag`, and E181 makes `typing/diag` import `typing/pretty`, so a `typing/pretty → module/loader` edge closes a cycle. E181's gate pins the **text** (G1); E146's gate pins the **law**. ⚑ **This is a seam between the lanes and it must be written into E146's SPEC**, not assumed. If it needs a Lane-A element of its own the band is **E184–E189** — **this SPEC does not mint one**, per the deferral rule; it is named, not shelved. |
| 24 | A `Core` printer instead — `Core` still has the author's names | **REFUSED here, and recorded for E146** | E181 is correct for the checker's `Term`, which is what `r-mismatch` carries and what E146's catalog row names. A second walk over `Core` would be the duplicate-owner defect again. Recorded so the E146 SPEC **rejects it deliberately** rather than never considering it. |
| 25 | The five new `d-tag` keys | **DEFERRED to E179 — MINTED (`SELF-IMPLEMENT-CATALOG.md:443`)** | Free at the renderer (`lookup-face:164-167` synthesizes; `d-tag` zero-width at `doc.chiral:123,151`). E181 adds them the way `dg-doc`'s thirteen sites already do and does **not** pre-empt E179's registry design. E179 inherits eighteen sites. |
| 26 | `dg-decl-doc`'s `dc-ty` arm is graded by **nothing** today | **RESOLVED — E181 grades it** | `samples/e158_doc.prog`'s fixture rows 5 and 6 use `dc-data`, so `:663` is changed by E181 and measured by nothing. §5 **G1** gains a row that renders a `dc-ty` `Decl` through `dg-decl-doc` and pins the bytes. Cheap, and it converts an ungraded site into a graded one instead of leaving a silent edit. |

### ⚑ ANSWERED — `LANES.md` clarified at `e43e349`, and what it settled

> The clause this SPEC raised is gone. `LANES.md:89-102` now reads: what is
> forbidden on `bin/chirality-bin` is **hand-editing it, or replacing it in
> place**. What is *required*, of a lane whose deliverable **enters the
> compiler's closure**, is to promote it — build-new → test → promote, with the
> fixpoint verified and the new binary checked non-zero before every `cmp`.
> `LANES.md` names **E181 as the first element in this arc inside the closure**,
> and records that E174, E175 and E158-c4 measured *outside* it and correctly did
> not promote. **So E181 promotes, and Commit 3 stays exactly where it is.**
>
> **Obligation (a) — the precondition.** On the **unmodified** tree, `B1(blob)`
> must already equal `bin/chirality-bin`, so a staleness inherited from a merge
> is caught as the merge's and not blamed on the element. `LANES.md` records the
> near miss: the binary was two generations stale, `C1 ≠ C2`, `C2 = C3`, and
> promoting `C1` would have installed a binary that does not reproduce itself.
> This is **§4 Commit 3 Step 0** and **§5 G12(ii)**, and it **passes today** —
> re-measured by this SPEC's audit: `C1` is byte-identical to `bin/chirality-bin`
> at 1,130,872 B.
>
> **Obligation (b) — tell Lane B.** After the promotion, any Lane-B measurement
> taken against the *old* `bin/chirality-bin` was taken against a different
> compiler, and a byte comparison across the merge will differ for a reason that
> has nothing to do with Lane B. It is a **required step of Commit 4**, not a
> courtesy: an obligation that lived only inside a NEEDS-AUTHOR block disappears
> the moment the block is answered, which is exactly how it would be missed.

## 4. Change plan (ordered, commit-sized)

**Standing rules for every commit below.**

- **`bin/chirality-bin` compiles everything. Python compiles nothing, ever.**
  Build-new → test → promote; nothing replaces itself in place.
- **⚑ Any scratch tree a mutant harness runs against MUST be a real directory
  copy of `lib/`, never a symlink.** `cp -a` copies a symlink *as* a symlink, so
  every `sed -i` then writes **through it into the tree under test** — nineteen
  phantom failures, once, including a `Rendering` that had silently grown a tenth
  constructor. Check `[ -L "$SCRATCH/lib" ] && exit 1` before believing any
  number measured outside the repo. (This spec run checked it.)
- **Every new name is censused with `grep -R`, not `grep -r`** — `-r` does not
  follow symlinks and would let a skipped file read as a clean census
  (`tools/test/MIGRATION-NOTES.md:86-87`, `doc.sh:357-359`) — and **word-boundaried**, or `pp-args`
  reads as sixteen hits of `app-args`. Re-run it; do not trust §2.
- **⚑ Assemble every needle from fragments in the gate script.** Phase 17's E154
  census went red **on a clean tree** because a mutant's `sed` expression spelled
  `(declare doc->rendering …)` at the start of a line *in the gate script itself*
  and the census greps `tools/`. `pretty.sh` greps `tools/` too.
- **⚑ A fixture under `tools/` is inside a neighbouring gate's scan surface, so
  its formatting is part of its contract.** Phase 16 went red once because a new
  fixture's `render-to-ansi` call was split over two lines and `face.sh`'s
  G7(c) arity scanner is **line-based**. `e181_pretty.prog` must **not spell
  `render-to-ansi` at all**, and must not begin any line with
  `(def|data|declare) <a prelude/doc or render-doc name>` — `doc.sh`'s G6 and
  `render-doc.sh`'s G7 both census `lib prog tools` for exactly that.
- **The five existing gate scripts and the three pinned fixtures stay
  byte-unchanged**: `diag.sh`, `doc.sh`, `row.sh`, `face.sh`, `render-doc.sh`,
  `samples/e157_diag.prog`, `samples/e158_doc.prog`, `samples/e174_row.prog`.
- Module keys are **root-relative** (`MAP.md:46-55`); the **extension is the kind**
  and the **directory is the role** (`MAP.md:3-16`) — note master renamed
  `LAYOUT.md` → `MAP.md`.
- **No `_` arm anywhere in `pp-term`.** Coverage is a compile-time invariant and
  §5 G1's mutant depends on it.

### Commit 1 — the printer, and its adoption, together

- **Targets:** `lib/typing/pretty.chiral` (**REPLACED**, 51 → ~200 L) ·
  `lib/typing/diag.chiral` (**EDIT**: +1 import, 3 call sites, −1 `declare`,
  −1 `def`).
- **⚑ These are one commit on purpose.** `pretty.chiral` is compiled by
  **nothing** — Phase 7 sweeps roots and none reaches it — so a commit that lands
  the rewrite un-adopted lands content **no gate touches**, which is the exact
  state E181 exists to end. Adoption is also what deletes `dg-term-tag`, so the
  two halves are one change. The tree is green before and after; it is never red
  in between (**measured**: 242/0 on the adopted tree with the *old* binary).
- **`lib/typing/pretty.chiral` — the shape, in dependency order:**
  1. **Header + imports.** `prelude/prelude`, `prelude/list` (`length`,
     `reverse` — note the **erased** type parameter: `(length Str ns)`,
     `(reverse Doc acc)`), `prelude/doc`, `surface/syntax`, `typing/qtt`,
     `typing/refine`. The `(module typing/pretty (cat A) (alt upper))` line
     **stays** and its derived port set stays empty — every signature is `->`.
  2. **The two shapes.** `pp-lines : (-> Brk (List Doc) Doc)` — a `d-line` of the
     GIVEN break **before** each element. ⚑ **It takes the `Brk`, and that is not
     cosmetic**: decision 15 requires `brk-hard` between `case` arms, and with a
     `brk-space`-only `pp-lines` nothing in this plan can produce one — the
     thirty-name census (§2) leaves no room for a second line-builder, so the
     break becomes the argument. `pp-form : (-> Str (List Doc) Doc)` —
     `d-group ( "(" ++ d-tag "term-kw" kw ++ d-nest 2 (pp-lines (brk-space) ds) ++ ")" )`.
     `pp-call : (-> (List Doc) Doc)` — the same with the head in the keyword's
     place. The `t-case` arm builds the same shape with `(brk-hard)`. `d-nest 2`
     matches `dg-doc`'s own indent (`diag.chiral:523` and eight more).
  3. **Names.** `pp-fresh p ns = p ++ (length Str ns)`. `pp-name-at ns i` walks
     from the head, falling back to `"#" ++ i` (decision 16).
  4. **Free names.** `pp-free-names : (-> Term (List Str) (List Str))`,
     accumulator-passing, with `pp-free-list` / `pp-free-arms` / `pp-free-atoms`
     / `pp-free-mb`. It collects **every name `pp-term` actually emits**:
     `t-global`, `t-prim`, `t-primty`, `t-con`'s `cn`, `t-tcon`'s `dn`, and each
     `KArm`'s `cn` — **not** `t-con`'s `dn`, which is never printed.
  5. **`pp-safe-prefix`** per decision 6: `pp-xlike` (byte-level, no `str-sub`),
     `pp-any-xlike`, `pp-max-len`, and `brepeat` for the escape branch.
  6. **Leaves.** `pp-qty` (`"0"`/`"1"`/`"w"` — **not** `dg-qty-name`'s
     `"omega"`), `pp-seat` (`"->"`/`"=>"`), `pp-op` (**not** spelled `symop->s`),
     `pp-quote` + `pp-esc1`/`pp-esc-go` for `\n \t \" \\` and nothing else.
  7. **The walk.** `pp-term` over sixteen arms with **no `_`**, plus `pp-args`,
     `pp-spine` (the app spine flattened head-outermost by walking left and
     accumulating right), `pp-arms`/`pp-arm`/`pp-arm-go` (decision 11 —
     `pp-arm-go` pushes each fresh binder as it emits it and `reverse Doc`s the
     accumulated pattern names), `pp-atoms`.
  8. **The two entry points**, `pp-of` and `pp-term-doc` (decision 10).
- **⚑ Two paren traps, both hit by this spec run.** (a) The `cond`-inside-`let`-
  inside-`case` shape of a byte dispatcher is one closer deep and was written
  wrong first try (`load: parse: unexpected )`). Split the per-byte escape into
  its own top-level `pp-esc1` — a `cond` whose arms are all one line — and the
  block becomes flat. (b) `(-> (0 A (type 0)) (List A) I64)`: `length` and
  `reverse` take the **erased type argument first**.
- **`lib/typing/diag.chiral` — the four edits, exactly:**
  1. After `:58`, `(import "typing/pretty")`.
  2. `:540-547`, the `r-mismatch` arm: wrap the `d-group` in
     `(let (pfx (pp-safe-prefix (cons e (cons a nil)))) …)` — **one closing paren
     more on the arm** — and replace `(d-text (dg-term-tag e))` with
     `(pp-of pfx e)` and `(d-text (dg-term-tag a))` with `(pp-of pfx a)`.
  3. `:663`, `dg-decl-doc`'s `dc-ty` arm: `(d-text (dg-term-tag t))` →
     `(pp-term-doc t)`.
  4. Delete `(declare dg-term-tag …)` (`:506`) and the whole `(def dg-term-tag …)`
     block with its four comment lines — the comment is `:665-668`, the `def`
     `:669-687`. ⚑ **The two prose mentions at
     `:493` and `:498` stay** — they are the paragraph explaining *why* E158
     shipped a flat accessor, they are history, and rewriting them is not this
     element's business. §5 G8's census therefore counts **defining occurrences
     and call sites**, not the string.
- **Verify:** `bin/chirality test` — the whole suite, expecting the clean
  verdict unchanged. `chirality check` on `lib/typing/pretty.chiral` is **not**
  sufficient and must not be mistaken for it: a file with no root that reaches it
  is exactly what E181 is fixing.

### Commit 2 — the gate: `tools/test/pretty.sh` + fixture + registration

- **Targets:** `tools/test/samples/e181_pretty.prog` (**NEW**) ·
  `tools/test/pretty.sh` (**NEW**) · `tools/test/run-tests.sh` (**EDIT** — the
  phase-18 comment line in the header table and the `run_phase` line) ·
  `tools/test/MIGRATION-NOTES.md` (**EDIT** — one row and one paragraph).
- The fixture spells **every term once** and every row reads it, so a width row
  and a byte row can never be describing two different fixtures (the E174/E175
  convention). It `put`s; it asserts nothing; it exits 0.
- `pretty.sh` follows `face.sh`/`render-doc.sh`: an `ok`/`bad` tally, a `mutlib`
  that copies `lib/` into a scratch directory (**checked not to be a symlink**),
  one named mutant per row, and **the full verdict line pinned** for every
  mutant so a mutant that reddens a row it was not paired with fails the same
  assertion as one that reddens nothing.
- **Registration is a checked row** (§5 G8), asserted `row.sh`'s way —
  `grep -cE "^run_phase 18 .* pretty.sh$" run-tests.sh`, run against a **different
  file** from the one doing the grep.

### Commit 3 — the promotion (decision 20, answered at `e43e349`)

- **Targets:** `bin/chirality-bin` (**REBUILT**).
- **⚑ Step 0 — the PRECONDITION, and it is the durable fix for the class FLAG 1
  named.** *Before* touching anything, on the **unmodified** tree:

  ```
  chirality_blob_file "lib:prog" prog/compiler.prog > blob.pre
  ( ulimit -s unlimited; bin/chirality-bin < blob.pre > B1check )
  [ -s B1check ] && cmp B1check bin/chirality-bin
  ```

  If that fails, **the staleness belongs to a merge and not to E181** — stop,
  promote to the tree's own fixpoint first (that may take more than one
  generation: master measured `B1 → C1 → C2 = C3`), and only then start. A
  single build-new/compare pass can report a failure that has nothing to do with
  the element, and that is exactly how E181 would be convicted of the master
  merge's residue. **Measured today: it passes** — `C1` is byte-identical to
  `bin/chirality-bin` at 1,130,872 B.
- **Then the full BUILD RULE**, in order:
  1. `chirality_blob_file "lib:prog" prog/compiler.prog > blob` — expect
     **764,555 B** (was 755,238).
  2. `( ulimit -s unlimited; bin/chirality-bin < blob > chirality-bin.new )` —
     expect **1,147,256 B**.
  3. **`[ -s chirality-bin.new ]` BEFORE any `cmp`.** A `cmp` of two empty files
     **passes**; this is a standing binding decision of the arc, not a nicety.
  4. **Test it**: `CHIRALITY_COMPILE=$PWD/chirality-bin.new tools/test/run-tests.sh`
     — expect `242 passed, 0 failed`, `gate PASSED`, 88 roots. (**Measured.**)
  5. **Promote**: `chmod +x` and move it to `bin/chirality-bin`.
  6. **The self-hosting check**: run the promoted binary over the *same* blob and
     byte-compare. `N1 == N2`, **measured** — one generation. If it ever differs,
     iterate; a difference is not automatically a defect (master's own merge took
     two), but an *unbounded* one is.
- **The `cmp` is stability, never correctness.** Phase 18 is what says the
  printer is right.

### Commit 4 — the state rows say built

- **Targets:** `docs/examples/INDEX.md` (E181 row → `implemented`) ·
  `docs/elements/catalog.md:445` · `docs/elements/ledger.md:300` ·
  `HANDOFF-DIAGNOSTICS-ARC.md` (the status table, the Lane A queue, and the
  *"Also unadopted"* paragraph — `dg-doc` now has a consumer).
- ⚑ **Flip BOTH authorities in the same change.** A landing that flips one and
  not the other has happened **three times** in this arc (E158's row, E174's row,
  and `LEDGER.md:283`). `.planning/` is untracked, so git will not catch it.
- **⚑ TELL LANE B — decision 20's obligation (b), and a required step of this
  commit.** `LANES.md` (`:89-102`) makes it one: the moment E181's promotion
  lands, every Lane-B measurement taken against the *old* `bin/chirality-bin` was
  taken against a **different compiler**, and a byte comparison across the merge
  will differ for a reason that has nothing to do with Lane B — the inverted
  *"the binary is stale"* diagnosis this repo has already been caught by. The
  step: a dated line in `HANDOFF-DIAGNOSTICS-ARC.md` naming the promotion, the
  new binary's size, and the fact that `N1 == N2`, in **this** commit. It is
  tracked, so unlike `.planning/` the merge carries it.

## 5. Conformance gate — `tools/test/pretty.sh`, Phase 18

**Every row reads emitted bytes.** The classic toothless shape for a printer is a
row asserting the `Doc` tree has the constructors you expected — the same
information twice. **Ten toothless or self-matching rows have been found in this
arc**, one of them this element's own G2 (§6), so every row below names a mutant
and states how to run it.

**The fixture prints, at width 10⁶ unless stated.** These are the **measured**
outputs, and every one was written from the grammar in §2 before the probe ran:

| # | term | expected bytes |
|---|---|---|
| 1 | `(t-lam (t-var 0))` | `(lam (x0) x0)` |
| 2 | `(t-type 0)` | `(type 0)` |
| 3 | `(t-pi (q1) (s-pure) (t-primty "I64") (t-primty "Str"))` | `(-> (1 x0 I64) Str)` |
| 4 | `(t-pi (qw) (s-proc) (t-primty "I64") (t-var 0))` | `(=> (w x0 I64) x0)` |
| 5 | `(t-app (t-app (t-global "f") (t-global "a")) (t-global "b"))` | `(f a b)` |
| 6 | `(t-let (qw) (t-lit-i 1) (t-var 0))` | `(let (w x0 1) x0)` |
| 7 | `(t-ann (t-lit-i 1) (t-primty "I64"))` | `(the I64 1)` |
| 8 | `(t-global "f")` | `f` |
| 9 | `(t-prim "str-cat")` | `str-cat` |
| 10 | `(t-primty "I64")` | `I64` |
| 11 | `(t-lit-i 42)` | `42` |
| 12 | `(t-lit-s "a⟨LF⟩b\"c\\d⟨TAB⟩e")` | `"a\nb\"c\\d\te"` |
| 13 | `(t-con "List" "Nil" nil)` | `Nil` |
| 14 | `(t-con "Box" "mk" [1])` | `(mk 1)` |
| 15 | `(t-tcon "Unit" nil)` | `Unit` |
| 16 | `(t-tcon "List" [I64])` | `(List I64)` |
| 17 | `(t-case (t-var 0) [karm Nil 0 → 0, karm Cons 2 → (t-app (t-var 1) (t-var 0))] (some 9))` | `(case⏎  #0⏎  ((Nil) 0)⏎  ((Cons x0 x1) (x0 x1))⏎  (_ 9))` |
| 18 | `(t-refine (t-primty "I64") [(r-atom (s-gt) 3)])` | `(refine I64 (> 3))` |
| 19 | `(t-lam (t-app (t-global "x0") (t-var 0)))` | `(lam (xxx0) (x0 xxx0))` |
| 20 | `dg-decl-doc "declared"` of a `dc-ty` `Decl` (decision 26) | the label, `" type "`, then the printed term |

| | row | mutant that must redden it |
|---|---|---|
| **G1** | **All sixteen formers reach the output, byte-exact at width 10⁶**, plus `KArm`, `RfAtom` and the `dc-ty` site — the table above. `t-var` is graded *inside* a binder (row 1) and *out of scope* (row 17's `#0`), because those are two different code paths. | **M1 `delete-the-t-tcon-arm`** — remove one arm and nothing else → **RUN: `load: non-exhaustive case`.** ⚑ **The seventeenth-constructor mutant does NOT belong here** and would be a false row: `Term` is cased exhaustively by **four** other modules in the same blob (`typing/kernel`, `typing/diag`, `lowering/upper/closconv-driver`, `lowering/compile-front` — **not** `module/loader`, which cases `Core` and never `Term`: `((t-` matches it **zero** times), and `load: non-exhaustive case` names **no site**. ⚑ **Measured by this SPEC's audit, not argued**: a seventeenth `Term` former added to `syntax.chiral` on the *clean, un-E181'd* tree already refuses `prog/compiler.prog` with exactly that message — so it would redden identically if `pp-term` had a `_` catch-all. Coverage is asserted by **arm deletion, one arm at a time**. |
| **G2** | **⚑ `brk-soft` is never correct between atoms.** The output at width 10⁶ and at width 12 must be the **same TOKEN SEQUENCE**, tokenised the way `is-delim` (`sexp.chiral:74`) does it — whitespace, `(`, `)`, `"` and `;` END an atom. ⚑⚑ **Whitespace is a DELIMITER here and must never be deleted.** The row as first drafted borrowed `doc.sh`'s `dt-strip-ws` (`samples/e158_doc.prog:72-75`), which deletes **every whitespace byte** — exactly the byte the mutant removes — so `(type 0)` and `(type0)` both mapped to `(type0)` and **the row passed either way**. That inversion is the whole row. | **M2 `soft-break-between-atoms`** — `(brk-space)` → `(brk-soft)` at `pp-form`'s and `pp-call`'s calls to `pp-lines`. **RUN, at width 10⁶: `(lam(x0)x0)`, `(type0)`, `(->(1x0I64)Str)`, `(fab)`, `(let(wx01)x0)`, `(theI641)`.** The token sequences then differ between the two widths and the row convicts. ⚑ Not `lam`/`x0`: `(` ends an atom, so `(lam(x0)…)` re-lexes correctly — the fusion is only ever between two **atoms**, which is why the mutant must be read at a *wide* width. |
| **G3** | **The group decision happens on a real term.** `(frobnicate alpha beta gamma)` is one line at width 40; at width 12 it is one argument per line with indent **exactly 2**. | **M3 `pp-call-loses-its-group`** (`d-group` → `d-nest 0`) → **RUN: broken at width 40 too.** · **M4 `pp-call-loses-its-nest`** (drop `d-nest 2`) → **RUN: indent 0 — `alpha` at column 1.** Two mutants, two named lines. |
| **G4** | **The spine is flat.** `(t-app (t-app f a) b)` prints `(f a b)`. | **M5 `binary-app-arm`** — the Python baseline's shape, `(pp-call [pp-term f, pp-term a])`. **RUN: `((f a) b)`.** |
| **G5** | **⚑ THE CONTROL THAT STATES THE WIN** — `doc.sh` case 14's shape one layer down. `(t-let (qw) …)` emits `w` and `(t-pi (q1) …)` emits `1`. Both round-trip (§2), so this row asserts a **choice about evidence** and it must be able to fail. | **M6 `elide-the-default-quantity`** — `pp-qty`'s `(qw)` arm returns `""`. **RUN: `(let ( x0 1) x0)`.** |
| **G6** | **No invented name shadows a free one.** A term carrying `(t-global "x0")` under one binder: the binder must not print `x0`, and `x0` must still print as `x0`. | **M7 `hardcode-the-prefix`** — delete `pp-safe-prefix`'s escape branch. **RUN: `(lam (x0) (x0 x0))` instead of `(lam (xxx0) (x0 xxx0))`.** |
| **G7** | **The arm binders agree with the elaborator.** `(karm "Cons" 2 (t-app (t-var 1) (t-var 0)))` prints `((Cons x0 x1) (x0 x1))` — index 1 is the **first** pattern variable (`push-all`, `surface.chiral:95`; `elab-arms`, `:251-259`). ⚑ A row that printed only the pattern would pass under the mutant; the **body** is what makes the direction observable. | **M8 `pattern-order-inverted`** — drop the `reverse Doc` in `pp-arm-go`. **RUN: `((Cons x1 x0) (x0 x1))`** — the pattern and the body disagree. |
| **G8** | **Adoption is real and the frozen gates did not move.** (a) `dg-term-tag` has **zero definitions and zero call sites** left (two *prose* mentions at `diag.chiral:493,498` remain and are expected — count `^\((def|declare) dg-term-tag` and `\(dg-term-tag ` separately, needles **assembled from fragments**). (b) `typing/diag` imports `typing/pretty`. (c) **Five** sha256 pins — `diag.sh`, `doc.sh`, `row.sh`, `face.sh`, `render-doc.sh` — plus the three pinned fixtures. (d) Phase 18 is registered in `run-tests.sh`. | **M9 `re-add-a-dg-term-tag-call`** in a copy of `diag.chiral` → the census sees it. · **M10 `touch-a-pinned-gate`** — append one line to a **copy of each** of the five (pinning four while exercising one is the same hole, one file smaller); every pin must move. · **M11 `drop-the-registration`** — delete the `run_phase 18` line from a copy of `run-tests.sh`. |
| **G9** | **⚑ THE ROW THAT CAN ONLY PASS AFTER THE REWRITE.** A probe root importing `typing/pretty` **and** `surface/syntax` **and** `lowering/tal/erase` compiles and runs. Today it is refused **twice over**. This is also the row that makes `nlen`'s E154 duplicate visible (decision 22). | **M12 `restore-the-local-Term`** → **RUN: `load: data redeclared: Term`.** · **M13 `restore-the-local-nlen`** → **RUN: `duplicate label (an object def collides with the linked runtime): nlen`.** Two different messages, so the row cannot pass by reading the wrong failure. |
| **G10** | **The non-cross-assertion, extended to this gate** (decision 21 / FLAG 2). `pretty.sh` carries **no byte-equality assertion naming `dg-msg`**, and `samples/e181_pretty.prog` names it **zero** times in code. E181's goldens pin the **grammar**; E157's exit keeps its own wording, and the two must not be tied together. ⚑ Build the needle from fragments (`PAT="dg""-msg"`) or the row matches its own source, exactly as `doc.sh:405-412` records. | **M14 `cross-assert-dg-msg`** — append one golden row naming the baseline exit to a **copy** of `pretty.sh`, and one reference to a copy of the fixture. Both halves must go red. |
| **G11** | **E154 census, tree-wide, for all thirty `pp-` names** — `grep -R` (not `-r`), word-boundaried, over `lib prog tools`, minus `pretty.chiral` itself. Zero defining duplicates. | **M15 `redefine-pp-term`** — add `(def pp-term …)` to a sibling in the same blob (`prelude/string.chiral`, `doc.sh` M6's device) → the census must catch it. Without this row the census is asserting that `grep` is deterministic. |
| **G11b** | **⚑ Decision 6(b), made checkable — `lib/typing/pretty.chiral` names neither `str-sub` nor `str-starts-with`.** `str-sub` **segfaults** (E176) and `str-starts-with` rests on the false comment that it clamps, so a later hand reaching for either re-imports a known crash into a file with no `_` arm to hide behind. Prose in §4 is not a row: this arc's own standing rule is that a constraint that matters is a checked row with a mutant. ⚑ The needle is **assembled from fragments** (`P1="str""-sub"`), because `pretty.sh` lives under `tools/` and would otherwise match its own source. | **M16 `reintroduce-str-sub`** — rewrite `pp-xlike`'s byte test as `(str-eq (str-sub s 0 1) "x")` in a **copy** of `pretty.chiral`; the census must see it. Pair it with the fixture reference so both halves move, `doc.sh`'s G7 shape. |
| **G12** | **The compiler still builds itself.** Not a mutant row — a **BUILD RULE step**, and it fails by not reproducing: blob → `chirality-bin.new` → suite under the new binary → promote → `N1 == N2`. ⚑ **Two guards, both standing decisions.** (i) **The new binary is checked non-zero *before* any `cmp`** — a `cmp` of two empty files passes. (ii) **The precondition** of §4 Commit 3: `B1(blob) == B1` on the unmodified tree *first*, or a merge's residue is read as E181's defect. | The one **checkable** control is guard (i): point the `cmp` at two zero-byte files and it must **refuse**, not pass. Guard (ii) is checked by running it — it passes today. |

**Placement.** The fixture lives under `tools/`, inside `face.sh`'s and
`render-doc.sh`'s scan surfaces (§4's standing rules). It must not spell
`render-to-ansi`, and no line may begin `(def|data|declare) <a prelude/doc or
render-doc name>`.

## 6. Residue & links

### RUN log — what was executed for this SPEC, 2026-08-31, `e158-doc` @ `b634630`

Probes ran in `/workspace/e181-probe` (**never `/tmp`**) against
`/workspace/e181-probe/tree`, a real directory copy of the worktree.
**Torn down after; nothing outside `docs/elements/specs/` and `docs/examples/INDEX.md`
was written in the repo.**

1. **The two refusals reproduced**, verbatim — §2. The premise of G9 holds.
2. **The blob and closure measured**: 755,238 B, **57 modules + the root**,
   `dg-term-tag` 7×, `typing/pretty` 0×.
3. **`bin/chirality-bin` is at its own fixpoint** — `C1` byte-identical at
   1,130,872 B. FLAG 1's staleness is gone; the *class* is guarded by §4's
   precondition.
4. **A full replacement `pretty.chiral` was written and compiled** — 30
   bindings, sixteen arms, imported **together with** `surface/syntax` **and**
   `lowering/tal/erase` in one root. It compiled and ran (exit 13 =
   `str-len "(lam (x0) x0)"`).
5. **All twenty G1 goldens emitted and read** (§5's table).
6. **Eight mutants RUN and convicting**: M1 (`load: non-exhaustive case`), M2
   (`(type0)`, `(fab)`, `(let(wx01)x0)`), M3 (broken at 40), M4 (indent 0), M5
   (`((f a) b)`), M6 (`(let ( x0 1) x0)`), M7 (`(lam (x0) (x0 x0))`), M8
   (`((Cons x1 x0) (x0 x1))`).
7. **Adoption applied to `diag.chiral`** — import, both `r-mismatch` sites under
   one shared prefix, the `dc-ty` site, and the `declare`/`def` deleted.
8. **The whole suite run against the adopted tree with the OLD binary**:
   `242 passed, 0 failed`, `gate PASSED`, 88 roots — **identical to the clean
   baseline**, Phases 13–17 at 30/26/41/38/19.
9. **The full BUILD RULE run**: blob 764,555 B → `N1` 1,147,256 B → suite green
   **under `N1`** → **`N1 == N2`**.
10. **The E154 census** over all thirty new names: zero hits.
11. **The forcing consumer probed before and after** — the table in §1.

### SPEC AUDIT — independent re-run, 2026-08-31, `e158-doc` @ `e43e349`

The gate re-ran the "built it first" claim rather than reading it. In
`/workspace/e181-audit/tree` — a **real directory copy**, `lib` verified not a
symlink — a replacement `pretty.chiral` was written **from §4's shape alone**
(thirty `pp-` bindings, sixteen arms, no `_`, no `str-sub`, no
`str-starts-with`) and put through the same sequence. **The claim held.**

- **Both refusals reproduce** verbatim on the unmodified tree
  (`load: data redeclared: Term`; `duplicate label … : nlen`), and a root
  importing `typing/pretty` **and** `surface/syntax` **and** `lowering/tal/erase`
  compiles and runs against the rewrite. **G9's premise and its two mutants are real.**
- **All twenty G1 goldens reproduce byte-for-byte** from an independent
  implementation — including `(lam (xxx0) (x0 xxx0))`, `((Cons x0 x1) (x0 x1))`,
  the multi-line `(case …)` at width 10⁶, and row 20's `declared type I64`.
  Goldens that fall out of a *second* implementation are grammar, not capture.
- **All eight claimed mutants convict with the claimed strings**: M1
  `load: non-exhaustive case` · M2 `(lam(x0)x0) (type0) (->(1x0I64)Str) (fab)
  (let(wx01)x0) (theI641)` · M3 broken at 40 · M4 `alpha` at column 1 ·
  M5 `((f a) b)` · M6 `(let ( x0 1) x0)` · M7 `(lam (x0) (x0 x0))` ·
  M8 `((Cons x1 x0) (x0 x1))`.
- **G2 was checked both ways.** Under M2 the rewritten row **FAILS**
  (`(|frobnicatealphabetagamma|)|` vs `(|frobnicate|alpha|beta|gamma|)|`) while
  the `dt-strip-ws` shape it replaced **PASSES**. The toothless row was real and
  the rewrite closes it.
- **G1's refusal of a seventeenth-constructor mutant is confirmed by running
  it**: a 17th `Term` former added to `syntax.chiral` on the *clean* tree already
  refuses `prog/compiler.prog` with `load: non-exhaustive case`, naming no site.
- **Adoption**: `242 passed, 0 failed`, gate PASSED, 88 roots, Phase 14 at 26/26
  — byte-identical to the clean verdict. `dg-term-tag` drops to the **two prose
  occurrences**. The §1 forcing-consumer table reproduces exactly, both rows.
- **BUILD RULE**: precondition passes (`C1` byte-identical to `bin/chirality-bin`
  at 1,130,872 B); blob 755,238 → **763,954 B** (57 → 58 `^(end-module` markers);
  `N1` **1,151,352 B**; suite green **under `N1`** (242/0, gate PASSED, 88 roots);
  **`N1 == N2`, fixpoint at generation one.** The two byte figures differ from
  §1's 764,555 / 1,147,256 because the audit's file is not the author's — the
  deltas bracket (+8,716 vs +9,317; +20,480 vs +16,384, both exact multiples of
  4,096, i.e. page-aligned ELF segments). **The class, the sequence and the
  one-generation fixpoint are confirmed; the two exact figures are the
  implementation's own and must be re-measured on the real file at Commit 3.**
- **The blob's `(end-module …)` count was re-checked with the anchor**: `57` for
  `^(end-module "`. An unanchored `grep -c '(end-module '` returns **68** and
  `grep -o '(end-module "…")'` returns **65** — which is where the example's "65
  modules" came from. §2's correction is right, and the anchor is the reason.

### SPEC AUDIT — FLAGS (author-tier, not resolved here)

> **FLAG A — the home. `MAP.md`'s rule is that the directory is the ROLE, and
> this SPEC never asks whether `typing/` is E181's.** Decision 1 settles that the
> printer's output **is chirality source**; its grammar is `surface/parse`'s, its
> type is `surface/syntax`'s `Term`, and `MAP.md:104-107` gives `typing/` as
> *"what a type is, and every check on it"* against `surface/` as *"what you
> write, and how it is read"* — this is that sentence's unwritten second
> direction. The SPEC rewrites the file in place and never states why the home
> is still right. It may well be (the forcing consumer is `typing/diag`, and
> decision 23's no-cycle argument is about `module/loader`, not about the
> directory). But `MAP.md:85-86` records in its own words that this rule is
> **prose with nothing checking it, and that prose is how three files drifted
> into `ports/`**. If the answer is that it moves, it must move **before** E146
> takes a dependency on the module key.
>
> **FLAG B — decision 15's hard break is CONTAGIOUS, and the SPEC states only
> half of it.** Measured this session:
> `(t-lam (t-case (t-var 0) [karm Nil 0 → 0] none))` at width 10⁶ prints
> `(lam⏎  (x0)⏎  (case⏎    x0⏎    ((Nil) 0)))` — the **`lam`** breaks too.
> `doc-fits` refuses a hard break anywhere inside the group it is measuring
> (`doc.chiral:131`), so a `case` does not merely make itself multi-line: it makes
> **every enclosing form** multi-line, at every width, all the way out to
> `dg-doc`'s own `d-group`. An `r-mismatch` over a term containing a `case`
> therefore renders as a multi-line diagnostic at width 10⁶. Decision 15 names
> the flip condition for the `case` form alone; the blast radius is the whole
> enclosing document, and the author should decide with that in view.
>
> **FLAG C — the deferral in decision 23 is correctly *named* and cannot be
> *minted* here.** Lane A's band is **E184–E189**; an audit has no authority to
> mint, and neither does an implement run. If the round-trip seam needs a Lane-A
> row rather than a paragraph in E146's SPEC, the author mints it — otherwise
> decision 23's "written into E146's SPEC" is the whole of it, and E146's SPEC
> author must be told.

### Corrections to the example (each measured, none re-litigated)

- **"65 modules"** in finding 13 does **not** reproduce. The blob carries **57
  `(end-module …)` markers plus the un-marked root**. The byte count (755,238) is
  right.
- **Finding 13's fixpoint table is now HISTORY.** It measured `bin/chirality-bin`
  one generation stale; the author promoted the tree to its fixpoint at
  `b634630` and `C1 == B1` today. The *lesson* survives as §4's precondition and
  §5 G12(ii) — which is the durable form of it.
- **Finding 3's "`nlen` and `get-at` are hand-rolled duplicates of
  `prelude/list`'s `length` and an index"** is half wrong: `prelude/list` has
  **no index function** (its bindings are listed in §2). `nlen` duplicates
  `length`; `get-at` duplicates nothing and its replacement (`pp-name-at`) is
  written here. Also: `nlen` is the file's **only** defining duplicate — `sp`
  and `parens` have no defining occurrence anywhere else.
- **`is-delim` is at `sexp.chiral:74`** (the comment naming the set is `:72-73`).
- **`resolve`** is declared at `surface.chiral:117` and defined at `:118`; the
  `ctx-find`-first line is `:119`.
- **A consequence the example did not measure**: because `brk-hard` never
  flattens, the whole `(case …)` form is multi-line at **every** width. Decision
  15 keeps it and names the flip condition.
- **The `dc-ty` site is graded by nothing today** — the example flagged it as a
  risk; decision 26 grades it rather than leaving it.

### Residue this element does NOT close

- **The round-trip law** is E146's, and the `typing/ → module/loader` edge is a
  cycle (decision 23). **Written into E146's SPEC, not assumed.**
- **`pp-name-at`'s `"#i"`** is the one output that is not source (decision 16).
- **The escape prefix is ugly** (`xxx0`) and stays ugly, on purpose (decision 6).
- **Eighteen ad-hoc `d-tag` keys** now await **E179**.
- **`str-sub` still segfaults** — **E176**, and E181 is written not to touch it.
- **`prog/` still has no consumer of `dg-doc`.** E181 makes the compiler's own
  `typing/diag` render terms through `Doc`, which closes the *"built but
  unadopted"* row for `dg-doc` inside `lib/`; the Lane-A "done" bar in
  `LANES.md` also wants a real `prog/` consumer, and that is queue item 6, not
  this element.

### Links

`docs/examples/E181-pretty-term-doc.md` (the rationale) ·
`docs/elements/specs/E158-doc-formatter-SPEC.md` (the algebra; decision 12 there is
what deferred this) · `docs/elements/specs/E175-face-restore-SPEC.md` (the shape this
file mirrors) · `HANDOFF-DIAGNOSTICS-ARC.md` (the chain, and the arc's binding
decisions) · `LANES.md` (the seam, and the `bin/chirality-bin` clause clarified at `e43e349`) ·
`docs/elements/catalog.md:445` · `docs/elements/ledger.md:300` ·
**E146** (Lane B — E181 is its prerequisite) · **E176**, **E179**, **E182**
(minted residue).

---

## Author decisions on the spec audit's three FLAGs (2026-08-31)

### FLAG A — the home MOVES: `typing/pretty.chiral` → `surface/pretty.chiral`

The audit was right that the SPEC rewrote the file in place without ever asking,
and `MAP.md` settles it once asked. Measured:

- **The input type is surface's** — `Term` is `lib/surface/syntax.chiral:18`.
- **The output grammar is surface's** — the printer emits chirality source, the
  inverse of `surface/parse`.
- `MAP.md:105-106`: `typing/` is *"what a type is, and every check on it"*;
  `surface/` is *"what you write, and how it is read"*. **A printer checks
  nothing.** It is the *written* direction of that same sentence — parse reads,
  pretty writes. That symmetry is the role, and role is what names a directory.

The one pull toward `typing/` is that the forcing consumer is `typing/diag`. That
is a **consumer**, and consumers do not determine homes — if they did, every
library would live beside its first caller, which is the altitude defect this repo
has already corrected four times.

**It moves inside E181, not later**, for the reason the audit gives: **E146 takes
a dependency on the module key**, and a key that moves after a dependent exists is
a rename with consumers. Root-relative keys make the directory the identity
(`MAP.md:46-55`), so this is not cosmetic — `(import "surface/pretty")` and
`(import "typing/pretty")` are *different modules*.

⚑ Recorded while measuring this: **`lib/typing/totality.chiral:29` declares a
THIRD local `Term`**, after `pretty.chiral:15`'s. E181 removes one of the two
duplicates; `totality`'s survives and is nobody's element yet. Named here, not
minted — a pre-run/spec cannot mint, and Lane A's band is E184–E189.

### FLAG B — the contagious hard break is ACCEPTED, and now stated in full

Measured by the audit: a `case` does not merely print multi-line, it forces
**every enclosing form** multi-line at every width, out to `dg-doc`'s own
`d-group`, because `doc-fits` refuses a hard break anywhere inside the group it
measures (`doc.chiral:131`). So an `r-mismatch` over a term containing a `case`
is a multi-line diagnostic even at width 10⁶.

**Accepted, because it is correct rather than merely tolerable.** A `case` *is*
structurally multi-line; a form containing one is too. Flattening it would produce
the single-line soup this element exists to stop, and `dg-chain-doc` already makes
the same call at `diag.chiral:704`. Decision 15 stands.

What was wrong was the *statement*, not the behaviour: decision 15 named the flip
condition for the `case` form alone while the blast radius is the whole enclosing
document. That is now written down, so the next reader meets it as a design fact
and not as a bug report.

### FLAG C — nothing to mint; it is a lane hand-off

`E146` is minted (`catalog:411`, `ledger:131`) and is **Lane B's**. The round-trip
law `parse(source(v)) ≡ v` is its row, not E181's — the loader is off `typing/`'s
import path, so E181 cannot gate it. Decision 23's "written into E146's SPEC" is
therefore the whole obligation, and it is discharged by **telling Lane B**, not by
minting a Lane-A row for work Lane A does not own.

Two things Lane B must be told, both crossing the seam and neither gate-enforceable:
1. **E181's printer is the one E146 uses** — and it now lives at
   **`surface/pretty`**, not `typing/pretty` (FLAG A).
2. **The promotion changes the compiler.** Any Lane-B measurement taken against
   the pre-E181 binary was taken against a different one.
