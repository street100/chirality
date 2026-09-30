---
row: enforcement/N26
arc: enforcement
title: the `->`/`=>` membrane refused at the call
kind: law
origin: new
req: 1
status: draft
updated: 2026-09-30
---

# enforcement/N26: the `->`/`=>` membrane refused at the call

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.
>
> ⚑ **This row is pre-minted.** It carries `E171`, at ledger state `design`
> (`docs/elements/ledger.md:121`). `tools/pack/pack.py enforcement/N26 --start`
> printed `enforcement/N26 already carries E171. The design stage is behind it;
> use --spec`, then scaffolded this file and moved the roster row from `open`
> to `designed`, as it did for `N25`. So §6 writes no mint. It states the
> amended catalog and ledger rows for `E171`.

## 1. The obligation

- **The row:** the kernel refuses an application of an effectful Pi made at a
  pure seat. The seat a body runs at is the seat of the Pi its lambda is checked
  against; a def body other than a lambda runs pure; an argument at a
  quantity-0 position is checked pure. The rule is complete on today's bit and
  is written as one predicate that `enforcement/N25` later widens to row
  subsumption without touching the rest.
- **Serves:** requirement 1 of [[arcs/enforcement-arc]], "A capability sits at
  ENFORCED, or its ledger row says why it does not." `E171` is at `design`.
- **Goal:** [[goals/enforcement]], condition 1.

## 2. What the tree holds

Measured 2026-09-30 at `4b4523c` plus the working tree.

- **Bank:** [[banks/effect-and-alarm]]. Shard 1 is the bit, carried and refused
  nowhere (`docs/banks/effect-and-alarm.md:105-121`). Shard 2 is the three
  membrane rules, reached by nothing (`:123-128`). [[banks/memory]] names the
  seal's consumer through `memory-discipline/M9`.

| what exists | where | rung | reached by |
|---|---|---|---|
| the seat: one bit | `(data Seat () (s-pure) (s-proc))`, `lib/surface/syntax.chiral:12` | IMPLEMENTED | every arrow |
| the elaborator puts the bit on the innermost binder only | `build-pis`, `lib/surface/surface.chiral:101-106` | IMPLEMENTED | every arrow |
| the seat compared by equality | `seat=`, `lib/typing/kernel.chiral:559-563` | IMPLEMENTED | `conv`; a `=>` value where `->` is wanted is refused, `prog/samples/e42_reject_pure_as_process.prog:11-21` |
| the bit read as "does this type cross" | `seat-crosses`, `ty-crosses`, `lib/typing/kernel.chiral:313-319` | IMPLEMENTED | the fn/proc export split |
| application: the head's Pi seat is bound and ignored | `infer-app2`, `lib/typing/kernel.chiral:886-894` | IMPLEMENTED | every application |
| a lambda checked against a Pi: the seat is bound and ignored | `check-body`'s `t-lam` arm, `lib/typing/kernel.chiral:945-951` | IMPLEMENTED | every lambda |
| the kernel's own record of the gap | `lib/typing/kernel.chiral:14-15`, `:898`, `:1001` | IMPLEMENTED | nothing |
| every def body checked against its declared type | `load-def`, `lib/module/loader.chiral:388-400`; the declared form at `:432-438` | IMPLEMENTED | the compiler |
| the model's rule 1, on-apply | `on-apply-ok`, `lib/typing/effects.chiral:35-36` | SEEDED | nothing in the blob (`docs/elements/ledger.md:113`) |
| the model's rule 2, erased-allow: a quantity-0 position is pure | `lib/typing/effects.chiral:39-40` | SEEDED | the same |
| the model's rule 3, on-binder: a linear type is bound only at 1 | `lib/typing/effects.chiral:44-46` | SEEDED | the same |
| rule 3 built in the kernel | `linear-binder-bad`, `lib/typing/kernel.chiral:360`, read at `:867` and `:907` | IMPLEMENTED | Pi formation and `let` (E159) |
| crossings declared `=>`, including "may halt" | `halt`, `exit`, `lib/ports/process.port:13-14`; `put`, `lib/ports/stdio.port:11`; the compiler's own `store-params`, `lib/lowering/mach/emit-core.chiral:518`, and `emit-args-res`, `:178`, over `=>` fields of `Mach`, `lib/lowering/mach/mach.chiral:28-29` | IMPLEMENTED | the compiler |
| pure externs that issue no syscall, stated at the declaration | `backend-close`, `prog/prapanca/backend.chiral:40-44` | IMPLEMENTED | trusted as declared |

**The defect is live at HEAD.** A root holding `(def observe (=> Str I64) …)`
and `(def check (-> Str I64) (lam (s) (observe s)))`, resolved with
`chirality_blob_file "lib:prog"` and compiled by `bin/chirality-bin`
(1,253,752 bytes), compiles, prints `crossed` and exits 7. The minting run's
probe 3 (`docs/elements/catalog.md:491`) reproduces unchanged.

**What reddens when the refusal lands.** A session probe (an s-expression walk
over every `.chiral`, `.prog` and `.port` under `lib/` and `prog/`, head types
from each file's import closure, the ambient seat taken from the Pi each lambda
is checked against by the innermost-binder rule, quantity-0 arguments walked
pure) finds **7 call sites in 6 defs in 6 files, all under `prog/`, 0 under
`lib/`**. By class:

| class | sites | where | today |
|---|---|---|---|
| a `->` test printer calling `put` | 3 | `prog/samples/prapanca-divide-live.prog:38` (`show-chunks`, declared `:32`); `prog/samples/prapanca-evidence-sift-refined-live.prog:98` (`dump-pure`, `:91`); `prog/samples/prapanca-parse-robust-test.prog:19` (`dump`, `:18`) | three Phase 7 roots, compiling |
| a `->` test predicate calling the `=>` planner `assign-plan` (`prog/prapanca/chatter/turn.chiral:401`) | 2 | `prog/prapanca/chatter/turn-test.prog:453`, `:457`, in `depth-ok` (`:447`) | one Phase 7 root, compiling |
| a pure-seat call in a file no root loads | 1 | `prog/scriba/flook.chiral:132`, `find-file` inside `flook-open-file`, whose declared type names the unbound `flook-list` (`:104-106`) and has no importer | dead today |
| the membrane's own demo | 1 | `prog/demo/_eff.chiral:3`, `(put 42)` in a `(-> I64 Unit)` body | refused today by the argument mismatch (`docs/elements/catalog.md:491`, item 5) |

**So five sites in four compiling roots redden**, and each is fixed by
retyping one def `=>`: `show-chunks`, `dump-pure`, `dump`, `depth-ok`. Re-running
the probe with those four retyped leaves no new site, because every caller is
already `=>`. The compiler's own blob is clean: it already types what crosses
or may halt `=>`. Quantity-0 positions: 0 sites. Probe limits: 7 lambdas had no
expected type (0 sites under them); 144 application heads in pure seats
resolved to no type, and are names used outside their file's import closure.

## 3. The delta

1. **An ambient seat.** `check` and `infer` carry no seat, so no judgment knows
   whether it runs pure.
2. **The refusal.** `infer-app2` binds the head's seat and never reads it.
3. **Rule 2.** An argument at a quantity-0 position is checked at the caller's
   seat. An effectful call there would be erased and never run.
4. **A diagnostic.** No `Judg` arm says "effectful application at a pure seat"
   (`lib/typing/diag.chiral:99-100` is the table).
5. **The four roots** and the demo, retyped and repaired.

Rule 3 stays out of the delta: E159 built it (`lib/typing/kernel.chiral:360`).
Transitivity stays out too. Every def body is checked against its
declared arrow (`lib/module/loader.chiral:388-400`), so a `->` def reaches a
crossing only through a callee whose type says it crosses, which the refusal
catches, or through an extern declared `->`, which is the trust root. A
call-graph pass adds nothing the per-call check misses.

**Verdict:** a real delta.

## 4. The shapes

### Shape A: an ambient seat threaded through the judgment
- **Form:** `infer`, `check` and the 38 helpers that take `(sig c …)` take the
  ambient seat. `check-body`'s `t-lam` arm checks the body at the seat of the
  Pi it is checked against. `infer-app2` refuses when `(seat-sub s amb)` is
  false, and checks an argument at a quantity-0 domain with the ambient pure.
  Top-level callers pass `(s-pure)`.
- **Costs:** one parameter on 38 helper heads and their call sites, most of
  them one token each; the loader's eight `infer`/`check` calls.
- **Forbids:** an effectful call at a pure seat, directly, through a callback
  parameter, through a data field (the `Mach` fields), or through a partial
  application. Wanted: P2 in the catalog's words, "One atom with no exemptions
  is what makes the effect typing total" (`docs/elements/catalog.md:491`).

### Shape B: a post-check pass over Core using declared global types
- **Form:** after load, walk each `->` def's body and refuse a call to a global
  whose declared type crosses.
- **Costs:** a second walker outside the kernel.
- **Forbids:** nothing a local carries. A callback parameter, a `Mach` field
  and a let-bound partial application have no global type, so the pass must
  re-infer them, which is the kernel's job done twice. Unwanted.

### Shape C: infer the obligation from the call graph
- **Form:** `lib/typing/row-infer.chiral` computes whether each def crosses; a
  `->` def found crossing is refused, or the annotation is dropped.
- **Costs:** a producer the checker trusts, SEEDED today.
- **Forbids:** the written arrow as the claim. `N25`'s NEEDS-AUTHOR 1 recommends
  that the kernel check what is written and that inference stay an untrusted
  producer (`docs/arcs/parts/enforcement-N25.md`, §5), and every def already
  writes its arrow. Unwanted.

### Shape D: call the model in `lib/typing/effects.chiral`
- **Form:** Shape A's threading, with the check delegated to `on-apply-ok` over
  `(List Str)` rows, `->` as `row-empty`.
- **Costs:** `effects.chiral` declares its own `(data Qtt () (q0) (q1) (qw))`
  (`:32`) beside the kernel's `Qty`, so importing it into the kernel adds a
  second quantity sum.
- **Forbids:** carrying over when `N25` lands. `N25` puts rows and their algebra
  in the kernel as terms of kind `Row`, and the closed-name model cannot say a
  region `s`. The delegation is rewritten then. Unwanted.

### Shape E: the ambient kept in `Ctx`
- **Form:** a constructor on `(data Ctx () (ctx-nil) (ctx-bind …))`
  (`lib/typing/kernel.chiral:404`) that records the seat.
- **Costs:** every de Bruijn lookup and `ctx-len` learns to skip it.
- **Forbids:** nothing wanted, and it puts a non-binder in the binder list.
  Unwanted against Shape A's plain parameter.

## 5. The call

- **Chosen:** Shape A. It is the only shape that sees every head type the kernel
  already computes, and it writes the rule as one predicate over whatever the
  Pi carries, so `N25` widens the predicate and leaves the rest.

**The predicate, on today's bit.** `(seat-sub callee amb)`: true when
`(seat-crosses callee)` is false, else `(seat-crosses amb)`. Beside `seat=` at
`lib/typing/kernel.chiral:559`.

**Why `N25` needs no rewrite of this row.** Under `N25`'s Shape B the Pi's
seat becomes a record holding a row, and `N25` §5 already writes subsumption
over rows and routes `seat-crosses` through `row-crosses`. What changes here
when `N25` lands: `seat-sub`'s body becomes that subsumption, and the ambient
the `t-lam` arm passes is the row evaluated at the lambda's fresh variable,
which `N25`'s own eval change produces beside the codomain. The threading, the
refusal site, the quantity-0 rule, the `Judg` arm and the corpus stay. Every
program the bit refuses is refused by the row: a pure ambient is the empty row
and a crossing callee's row holds an entry. Under `N25`'s recommended reading of
a bare `=>` as the top row, every program the bit accepts is accepted by the
row too.

**The seal.** `memory-discipline/M9`'s block `(=> (0 s (type 0)) … A)` is made
pure by a seal rule that removes the region entries from its type
(`docs/arcs/memory-discipline-arc.md:102`). The refusal reads the head's type
at the call, so a sealed block, whose type no longer crosses, is accepted, and
this row names no exemption and needs nothing from `M9`. The consequence for
`M9`: a seal written as a `->` library def that applies its `=>` argument is
refused here, so the seal is a kernel rule.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Direction: may a `->` body reach a crossing | RESOLVED: no | P2 and P3, `docs/elements/catalog.md:491` |
| 2 | Infer the obligation or check the annotation | RESOLVED: check the written arrow | every def body is checked against its arrow, `lib/module/loader.chiral:388-400`; transitivity follows by induction (§3) |
| 3 | Granularity against E160/E161's module port set | RESOLVED: per arrow, independent of the module coordinate | E161 made the type the authority, `lib/typing/kernel.chiral:305`; `crossings` stays sense (a) BINDS |
| 4 | The seat of a body between curried binders | RESOLVED: pure, the innermost binder carries the bit | `build-pis`, `lib/surface/surface.chiral:101-106` |
| 5 | A top-level def whose type lacks an arrow | RESOLVED: pure | P2; 0 sites measured |
| 6 | Rule 2, quantity-0 arguments | RESOLVED: checked pure | `lib/typing/effects.chiral:39-40`; 0 sites measured |
| 7 | Rule 3, on-binder | RESOLVED: built | E159, `lib/typing/kernel.chiral:360` |
| 8 | An exemption for debug output in pure code | RESOLVED: none | P2; `M9`'s seal is the one sanctioned route |
| 9 | Blast radius | RESOLVED: 5 sites in 4 roots, retyped in the build | §2 |
| 10 | Extern honesty: a `->` extern that crosses | DEFERRED: unrostered, below | declared types are the trust root this rule reads |

No NEEDS-AUTHOR. No register row is owed.

## 6. The mint packet

- **Elements:** one, `E171`, already minted. The threading, the predicate and
  the refusal constrain each other and land in one kernel edit. Nothing is
  minted.
- **Band:** none drawn. `E171` predates the arc's block `E184-E189`.
- **Catalog row, amended:**
  `| E171 | **The `->`/`=>` membrane, enforced at the CALL.** The kernel threads the seat a body runs at: the seat of the Pi a lambda is checked against, pure for a non-arrow def and for a quantity-0 argument. `infer-app` refuses an application whose Pi crosses at a seat that does not, through one predicate `seat-sub` that E39 widens to row subsumption. Rule 3 of the model is E159's. Transitivity follows from checking every body against its written arrow; externs are the trust root | Not built. Measured 2026-09-30: the refusal is absent at HEAD (a `(-> Str I64)` def calling a `=>` def prints and exits 7); 0 sites under `lib/`; 5 sites in 4 `prog/` roots redden and are retyped `=>`. Relations: ←E12 · ←E159 · →E39 widens `seat-sub` · `memory-discipline/M9`'s seal is accepted as a kernel rule | `OURS` (`lib/typing/kernel.chiral` as the destination; `PRINCIPLES.md` P2/P3 as the contract; `docs/banks/effect-and-alarm.md`) | SH |`
- **Ledger row, amended:**
  `| E171 | membrane | design | The `->`/`=>` membrane refused at the call, on the one-bit seat. Check: a gate phase with a refusing fixture per class (direct call, callback parameter, `Mach`-style field, partial application saturating at a pure seat, quantity-0 argument, non-arrow def) and accepting controls (a `=>` body, a curried `=>` returning a closure, the E42 sample still refused by `conv`), each with a mutant that drops the refusal; the four retyped roots compile; BUILD RULE `C1 == C2` | | SH |`
- **SPEC:** none exists for `E171`. `design-to-spec` writes it from this file.
- **Size:** about 9 files and 190 lines. `lib/typing/kernel.chiral`: the
  parameter on 38 helper heads and their call sites, `seat-sub` at about 4
  lines, the refusal and the quantity-0 rule at about 10, the `t-lam` arm at 2,
  and the comments at `:14-15`, `:898`, `:1001` rewritten. `lib/module/loader.chiral`:
  8 call sites. `lib/typing/totality-check.chiral` and
  `lib/typing/kernel-core.chiral`: their `infer` calls. `lib/typing/diag.chiral`:
  one `Judg` arm and its text, about 3 lines. Four `prog/` declarations retyped
  and `prog/demo/_eff.chiral:3` repaired to `(put "x")` so it is refused for the
  membrane. A gate script at about 90 lines with 8 fixtures. Basis: the counts
  in §2 and a grep of `(lam (sig c` in `lib/typing/kernel.chiral`.
- **Related:** [[arcs/enforcement-arc]] `N25`; [[arcs/memory-discipline-arc]]
  `M9`; `E12`; `E159`; `E39`; [[banks/effect-and-alarm]].

### Needed and unrostered

| what | why this row needs it | where it would go |
|---|---|---|
| a check that every extern declared `->` issues no syscall | the refusal trusts declared arrows; 43 externs open with `->`, 35 of them in `lib/prelude/prelude.chiral`, and `prog/prapanca/backend.chiral:40-44` states its no-syscall claim in a comment | an `enforcement` row beside `N20`'s extern census |
| `M9`'s seal must be a kernel rule | a `->` def that applies its `=>` block is refused here (§5) | carried into `memory-discipline/M9`'s design |
| `prog/scriba/flook.chiral` names the unbound type `flook-list` and has no importer | it is one of the seven sites and cannot load today | a revisit of the scriba subtree |
| `lib/typing/effects.chiral:1-6` still says "effects.py stays the oracle", and its three rules are superseded once `E171` and `E39` land | the model this row declines to call (Shape D) | a `doc-audit` of that file, or `N25`'s SPEC |
| the ledger row `E171` cites `ports/stdio.chiral:11` and a 1,102,200-byte compiler | the file is `lib/ports/stdio.port:11` and the binary is 1,253,752 bytes today | a clerical edit with the amended row above |
