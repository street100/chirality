---
element: E187
slug: stated-invented-names
title: **The `sk-defunc` blame channel: `closconv` states why it dropped a family**
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: reviewed
updated: 2026-09-05
---

# E187 — **The `sk-defunc` blame channel: `closconv` states why it dropped a family**

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

⚑ **This pre-run's finding is that the element as minted is spent.** E185 and
E186 between them answered all three name families, and §1 measures that at HEAD
rather than inheriting the row. What survives is one channel, and it is not the
one the row names. Read §1 before §5: the snippet is the survivor, not the row.

⚑ **The EXAMPLE-level audit, 2026-09-05, re-ran the load-bearing measurements at
HEAD and the finding survives all of them.** The structural argument of §1.3 was
attacked directly and held; the corrections below are citation precision, not
substance. What the audit changed is §6 question 1, which the pre-run routed to
the SPEC stage and which is an author call, so the audit left it stating two
options and answering neither. The banner below records the answer.

| what the audit attacked | how it failed |
|---|---|
| `$clo<i>` carries content of its own, so a second channel is owed | it does not. `(data-decl dname nil ctors)` (`closconv-driver.chiral:186`) has no type parameters, and `term->ntalty`'s `t-tcon` arm (`compile-front.chiral:68`) derives `(nt-data dn nil)` from any `Core` spelling of it with no channel. `apply-ptys` (`:131-133`) covers the one position where the name is not recoverable from `Core` |
| some position other than the dispatcher's leading parameter needs the statement | none found. `datas->n` (`compile-front.chiral:254-261`) takes no `sp` parameter and the constructors' fields go through `field-tys->n` (`:238-245`), which E186 ruled `concrete`. A capture whose own type IS a `$clo` is a `t-tcon` and lands on the same derived arm |
| `apply-ty`'s domain content is read somewhere, so §1.4 falls | it is not. `peel-def` (`compile-front.chiral:211-223`) reaches `ty-kept-doms` only in its `(none)` branch, `sp-get` hits for every `$apply<i>`, and `ty-erased` (`:167-170`) returns nil because every `mk-pi` binder is `(c-pi 2 …)` (`closconv.chiral:1137-1144`). `build-emap` (`:172-175`, called at `:345`) reads only that same erased vector |
| the drop-consistency worry needs `ck-prog` | it does not. `lib/lowering/tal/erase.chiral:193-194` and `:249-250` refuse by constructor name on the live path, and `ck-con` (`check.chiral:183-196`) refuses by data name on the checked one |
| the arity prices in §5 are guessed | measured. `CState` has three fields (`closconv.chiral:618`) so `dsk` is a fourth; `CCOut` has two (`closconv-driver.chiral:142`) so it is a third, which is where E188's own residue note says *fourth* and is wrong; `fr-ok` has four (`compile-front.chiral:315-316`) so it is a fifth; `back-program` (`compile-back.chiral:297-301`) already passes `nil nil` as `lower-defs`' seed `TFn` and seed `SkRec` lists, so the seat exists |
| `sk-defunc` has a caller after all | it has none. Four grep hits in the tree, three of them the declaration and the two destructuring accessors, one of them a comment |

**Six citation corrections landed in place**: `arm-body` ends at `:1126` and not
`:1134`; the `shape-eq`/`shapes-eq` pair ends at `:356` and not `:363`;
`ctors->n` ends at `:253`; `aty`'s second read is `closconv-driver.chiral:208`
and not `:211`; the `erase` refusals are at `:193-194` and `:249-250` in
`lib/lowering/tal/`; the `e186-capture-fields.prog` pattern line is `:287` and
not `:286`, which is the one place E188's residue note was right and this pre-run
was not. **Two wording corrections**: `st-add-gsite` discards `g` and the
condition in its own arms rather than handing them to `st-add-pois`, whose type
`(-> CState Core CState)` has no seat for either; and the accessor at
`skip-diag.chiral:29` is `skwhy-tag`, not `skwhy-kind`. **One string aligned**:
§5's `"no declared type"` now matches the discriminant `skip-diag.chiral:12`
already names.

⚑ **The author answered §6 question 1 on 2026-09-05: option (i), re-scope E187
in place.** The element is retitled to the `sk-defunc` blame channel of §1.6 and
§5, and the type-statement clauses are struck from all four registry rows. Each
row records what E187 was and that E185 and E186 consumed it, so a reader who
followed the old subject can see what happened. `E189` is not spent: it is the
last free number in Lane A's `E184-E189` band, shared with
[[arcs/diagnostics-arc]], and spending a scarce contested number is what produced
the two-`E173` collision this tree records. The example is marked `reviewed` on
the same run. ⚑ **Only §1's scope bullets and §6's question 1 move.** §1.1
through §1.6 are the measurement that caused the re-scope and they stand as
written; the file keeps its `stated-invented-names` slug for the same reason,
as the provenance of what this artifact was minted to examine.

## 1. Scope

- **Element:** E187 as re-scoped, routing `sk-defunc` from `st-add-gsite` to the
  user, so `closconv` states WHY it dropped a family. §1.6 is the measurement
  and §5 is the snippet.
- **As minted:** `closconv` writing down the lowering-level type of the three
  name families it mints, `$clo<i>`, `$apply<i>` and `$k<i>_<j>`. §1.1 through
  §1.5 measure that subject SPENT at HEAD, which is what the re-scope rests on.
- **Kind:** BUILD-PROPER.
- **Why chirality needs its own:** no exceptions and no ambient reporting, so a
  classification made inside the pass reaches the user only as a value riding a
  data type. `st-add-gsite` makes the classification, `st-add-pois` has no seat
  for it, and the boundary sum the STANDING DIRECTIVE names is the only shape
  available. Nothing downstream of `closconv` can reconstruct which condition
  fired, because the poisoned family is gone by then.

### 1.1 The row's citations are stale at HEAD, and the numbers are corrected here

E188 landed nine commits into `lib/lowering/upper/` after E187's row was written,
and every line citation in that row moved. Measured at `a381156`:

| the row says | HEAD | delta |
|---|---|---|
| name spellings at `closconv.chiral:1112-1114` | `clo-name` `:1179`, `apply-name` `:1180`, `ctor-name` `:1181` | +67 |
| `apply-ty` at `:1096-1098` | `:1163-1165` | +67 |
| `arm-body` at `:1051-1058` | `:1109-1126` | +58 at the head, and the body was rewritten |
| `shape-eq` at `:335-356`, `cod-key-eq` at `:365-380` | `:340-356`, `:365-380` | `shape-eq` +5, `cod-key-eq` exact |
| `field-tys->n` / `datas->n` at `compile-front.chiral:238-261` | `:238-245` and `:254-261` | exact |
| 1,820 lines of live rewriting in `lib/lowering/upper/` | 1,936: `closconv` 1,414, `closconv-driver` 290, `specialize-singleton` 232 | +116 |

The same +67 stale span sits in `docs/elements/catalog.md:503`,
`docs/elements/ledger.md:325`, `docs/examples/INDEX.md:170` and
`docs/arcs/enforcement-arc.md:329`. `ledger-lint` check R lands a citation on its
symbol and does not catch a line number that has drifted past it, which is the
same class E186's SPEC left standing for E185's row.

⚑ **One claim in the row is now false rather than stale.** "1,820 lines of live
rewriting still say nothing at the lowering type level" no longer holds for
`closconv-driver`: it imports `lowering/lowspec` at `:25` and computes `NTalTy`
directly in `word-ptys` and `apply-ptys` (`:127-133`). E185 is what changed that.

### 1.2 The three names sort by WHAT KIND OF THING they are, and that decides the element

The row treats the three as three instances of one job. They are not, and the
split is structural:

| name | what it is | how it reaches the lowering type level | who owns it |
|---|---|---|---|
| `$apply<i>` | a **global** | `peel-globals` → `peel-def` (`compile-front.chiral:211-233`), which consults the stated map first via `sp-get` (`:201-204`) | **E185, built** |
| `$clo<i>` | a **data declaration** | `datas->n` (`:254-261`), and its own TYPE is `(nt-data "$clo<i>" nil)` | see 1.3 |
| `$k<i>_<j>` | a **constructor of that data** | `ctors->n` → `field-tys->n` (`:238-253`) | **E186, ruled `concrete`** |

E185's channel is keyed by global name, `(List (Pair Str (List NTalTy)))`, and
`peel-def` consults it for every global. Extending it to another GLOBAL is free.
Neither of the other two names is a global, so neither passes through `peel-def`
at all. That is the fact the row calls "a path the `NDef` channel does not
reach", and it is verified: `datas->n`'s signature is
`(-> (List DataDecl) (List NData))` with no `sp` parameter, and `sp` reaches
globals only through `peel-def` and `peel-globals`.

### 1.3 The `$clo<i>` half is not an independent half

`$clo<i>` is minted as `(data-decl dname nil ctors)` at
`closconv-driver.chiral:186`. It has **no type parameters** and **no content of
its own**: its whole payload is its constructors, which are the `$k<i>_<j>`
family. So:

1. **`$clo<i>`'s own lowering type is already stated.** It appears as a type at
   exactly one position, the dispatcher's leading parameter, and E185's
   `apply-ptys` writes `(nt-data (clo-name i) nil)` there
   (`closconv-driver.chiral:131-133`). Everywhere else `term->ntalty`'s `t-tcon`
   arm (`compile-front.chiral:68`) produces the same value from the `Core` type,
   with no channel needed, because a data NAME is a thing `Core` can spell.
2. **Its remaining content is the `$k<i>_<j>` field types**, which E186 ruled
   `concrete`, and `concrete` is what `site-fields->term`
   (`closconv-driver.chiral:153-163`) already writes and what `field-tys->n`
   already peels.

The second stated channel is therefore the mechanism the **erased-field** answer
would have needed. E186 rejected that answer. Building the channel now transports
a value identical to the one the existing peel computes, and nothing downstream
reads a difference. `docs/elements/specs/E186-capture-field-types-SPEC.md` §3
priced it as "the cost of the answer this ruling rejects" and it is correct.

### 1.4 E185's named residue cannot be retired, by the standing ruling

The row says E187 "retires E185's residue: `apply-ty` still spells the
dispatcher's domains from one family member". Measured at HEAD, that residue has
two properties that together close it:

- **Its content is read by nothing.** `apply-ty`'s output `aty` becomes the Sig
  global's type for `$apply<i>` (`closconv-driver.chiral:206`, `:208`). Three
  readers touch it afterwards. `peel-def` takes `(ty-cod ty)` and, because
  `sp-get` hits, skips `ty-kept-doms` entirely (`compile-front.chiral:213-221`).
  `peel-def` and `build-emap` both take `(ty-erased ty 0)`, which returns nil
  because `mk-pi` gives every binder q=2. So only the pi-chain DEPTH and the
  CODOMAIN survive; the domain types themselves are dead at HEAD.
- **No honest replacement exists in `Core`.**
  `docs/decisions/decision-erased-word-level.md` rules that the erased-word type
  lives strictly at the lowering type level and that `Core` gains no word
  spelling. There is no `Core` term that spells the domain honestly, and
  `closconv-sig` runs after the typecheck (`compile-front.chiral:369`), so no
  kernel judgment would catch a substitute either.

An annotation that nothing reads and that the ruling forbids repairing is not a
build. The standing comment at `closconv.chiral:1146-1162` is the correct and
final disposition, and it already says so in the source.

### 1.5 The one drop-consistency worry, and why it is already guarded

If a capture's source type fails `term->ntalty`, `field-tys->n` returns `(none)`,
`ctors->n` returns `(none)`, and `datas->n` drops the whole `$clo<i>` data while
`peel-def` still emits the `$apply<i>` NDef whose leading parameter names it.
That inconsistency is real and it is **loud on the live path**: `lib/lowering/tal/erase.chiral:193-194`
answers `con: unknown constructor $k<i>_<j>` and `:249-250` answers
`branch: unknown constructor`, both named refusals rather than wrong code, and
both reached without `ck-prog`. `ck-con` (`check.chiral:183-196`) answers
`con: unknown data type` at `:190` on the checked path. The historically hit instance is
[[banks/erasure]] shard **D**: type-kinded captures used to be word-ified into
`$clo` fields, a `t-type` field failed `term->ntalty`, and the whole `$apply`
vanished. E100 built `field-erased?` and closed it. There is no gap to name here.

### 1.6 What survives: one channel, and it is E188's

`SkReason` gained `sk-defunc` in E188 and **no caller constructs it**. Verified at
HEAD: `lib/lowering/skip-diag.chiral:15` declares it and `:26`, `:29` destructure
it. `grep -rn sk-defunc lib/ prog/ tools/` returns four lines: those three, plus
the comment at `:11` that names the two discriminants. No line constructs it.

`st-add-gsite` (`closconv.chiral:700-706`) holds both facts the blame needs, the
global's name `g` and which of two conditions fired, an untyped global or a
family/global arity mismatch. Both die in its own two refusing arms (`:703`,
`:706`): each calls `(st-add-pois st key)` and `st-add-pois` (`:676-678`) is
typed `(-> CState Core CState)`, so there is no seat for a name or a reason. All
it appends is the family KEY, to `CState`'s `pois`, a `(List Core)` (`:618`). Downstream the user gets
`keep-fams` dropping the family (`closconv-driver.chiral:96-106`), the source def
left unrewritten, and `compile-fn` refusing it with `body is not a lambda chain`,
which is the SYMPTOM. [[records/enforcement-arc]] EN-22 measured exactly that
string on E188's own control fixture.

That is a channel of the same shape E187 was minted to extend, running from the
pass that knows the fact to the report that needs it, and it is the only one
left. §5 builds it.

## 2. Research

- **Reference class:** OURS, plus `IMPL`/`PAPER` for the conventional contrast.
  `.planning/RESEARCH-EN15-prior-art.md` §6 and §7 are the surveys E185 and E186
  already ran, and this run reuses their findings rather than repeating them.
  New reading here is the tree itself at HEAD.
- **Key findings:**
  1. **A defunctionalizing pass in a typed compiler restates the type because its
     IR forces it to.** MLton's closure conversion (Cejtin, Jagannathan and
     Weeks, 2000) mints one datatype per arrow type with one constructor per
     lambda plus a dispatching `apply`, and MLton's SSA IR is typed, so the
     invented datatype carries a declaration and `apply`'s argument type IS that
     datatype. The statement is not a channel there. It is the only way to write
     the IR down at all.
  2. **Field types stay concrete in every published shape.** Research §7: Pottier
     and Gauthier's `succ : Arrow int int`, Minamide/Morrisett/Harper's
     existential pack with concrete fields inside, Huang and Yallop's
     label-context entry. E186 took the same answer, and it is why the `$k` half
     is closed rather than open.
  3. **The dispatcher's argument position is the one place merge pressure
     exists.** A capture constructor is applied at exactly one site, its own
     definition site, so nothing forces its fields to merge; the shared
     dispatcher's argument is constrained by every family member at once. That
     asymmetry is what makes one name need a channel and two names not.
  4. **A refusal that names the wrong stage is the failure mode this tree already
     has a pattern for.** `SkReason` and `SkRec` (E97) exist precisely so a
     lowering skip carries `(sk-extern op)` or `(sk-callee name)` instead of a
     discarded string. `sk-defunc` is the third arm of that sum, minted and
     unreached.

## 3. Conventional (other-language) approach

MLton, whose closure conversion is the direct counterpart to this pass. The pass
invents a datatype and an apply function, and the IR they land in is typed, so
the invented names are declared where they are used.

```sml
(* what MLton's closure conversion produces for one arrow type, sketched in SML.
   The invented datatype is DECLARED, so its constructor field types and the
   dispatcher's argument type are both written down by construction. *)
datatype clo0 =
    K0_0 of int              (* one constructor per lambda, fields = its captures *)
  | K0_1 of string * int
  | K0_2                     (* a capture-free lambda *)

fun apply0 (c: clo0, x: int) : int =
    case c of
        K0_0 n        => n + x
      | K0_1 (s, n)   => n + x + size s
      | K0_2          => x
```

- **Assumptions it bakes in:**
  - **The IR has a declaration form for a type the source never wrote.** Any
    invented name gets a real declaration, so "state it" is not a separate step.
  - **One type language spans the whole compiler.** MLton's SSA types serve the
    front and the back, so the erasure the family key performs and the type the
    dispatcher carries are expressed in the same vocabulary. There is no seam
    where a value is one word at runtime and its declared type disagrees.
  - **A refused site is a compile-time error the pass raises immediately.** No
    poison list, no family dropped silently, no downstream refusal wearing a
    different stage's message.
  - **Ambient reporting.** The pass prints or raises. Nothing has to thread a
    reason value through four data types to reach the user.

## 4. The chirality idea

- **Chirality features in play:** the categories A/B/C split across the two type
  languages; boundary sums (the STANDING DIRECTIVE) as the mechanism for blame;
  totality, so a refusal is a returned value; errors as values, so no raise
  exists to carry the reason.
- **The reframing.** chirality has **two** type languages and a ruling that keeps
  them apart. `Core` is the kernel's, checked by `conv`. `NTalTy` is the lowering
  level's, checked by `tal-ty=?` whose first arm makes `nt-word` match everything.
  `docs/decisions/decision-erased-word-level.md` rules the erased word lives
  strictly in the second, because a `Word` that converts with `I64` and with
  `(List Str)` makes those two convert with each other, which is transitivity
  collapsing the source type system.

  That ruling is what makes a **channel** the only shape available. `closconv`
  emits a `Sig`, and a `Sig` global holds a `Term`, and no `Term` spells the
  erased word. So the pass says the honest thing beside its output rather than
  inside it. `CCOut` (`closconv-driver.chiral:142`) is that channel and E185
  built it.

  The same argument, run over the blame, gives the same shape. `keep-fams` drops
  a poisoned family and the reason dies at `st-add-pois` because `CState`'s
  `pois` is a list of family keys with nowhere to put a name. The fix is not a
  message and not a log line: it is the boundary sum this tree already mints,
  `SkReason`, carried out beside the rewritten `Sig` on the same channel.
- **What chirality makes impossible here:**
  - **A word type in the kernel.** By ruling. So the erasure cannot be stated in
    `Core` at all, and an element scoped as "state it in the pass's own output"
    has no legal target.
  - **A discarded reason.** `st-add-gsite` knows `g` and knows which condition
    fired; the directive says a classification made at a boundary is retyped as a
    sum and passed as a VALUE. A `Str` or a dropped key is that rule broken.
  - **A raise.** No exceptions, so the reason must ride a data type to the
    caller. `FR`, `BR` and `CAllR` are that ride, and `BR` already carries
    `(skips (List SkRec))` (`compile-back.chiral:125`) while `FR` does not.

## 5. Chirality example (fleshed)

The survivor from §1.6: route `sk-defunc` from `st-add-gsite` to the user. Five
widenings and one recording site. Elided arms marked `; …`.

```chirality
; ---- lib/lowering/upper/closconv.chiral -------------------------------------
(import "lowering/skip-diag")   ; SkReason / SkRec.  compile-back and typing/diag
                                ; already co-blob this module, so no new name
                                ; collision is introduced (cf. E154).

; CState gains a FOURTH field.  `pois` stays a (List Core): it is the family-key
; set keep-fams filters on, and it is doing its job.  The blame is a second,
; independent list, because a key is not a name and a name is not a reason.
(data CState () (cstate (fams  (List Family))
                        (ho    (List Core))
                        (pois  (List Core))
                        (dsk   (List SkRec))))

; every CState op gains one field in its pattern and rebuilds it unchanged.
(def st-add-pois (-> CState Core CState)
  (lam (st key)
    (case (st-ensure-fam st key) ((cstate fs ho po dk) (cstate fs ho (key-add po key) dk)))))
; …  st-ensure-fam / st-add-site / st-add-ho are the same one-field edit.

; the new op: poison AND say why.  `g` and the condition are both in hand here,
; which is the whole reason this is the recording site.
(def st-pois-defunc (-> CState Core Str Str CState)
  (lam (st key g why)
    (case (st-add-pois st key) ((cstate fs ho po dk)
      (cstate fs ho po (cons (mk-skrec g (sk-defunc g why)) dk))))))

; the E188 guard, unchanged in behaviour, now naming its two refusals.
(def st-add-gsite (-> SigV CState Core Str I64 (List (Pair I64 Core)) CState)
  (lam (sig st key g k fields)
    (case (arity sig g)
      ((none)    (st-pois-defunc st key g "no declared type"))
      ((some ar) (case (=i ar (+ k (cc-llen (peel-pi-doms key))))
                   (true  (st-add-site st key (cs-g g k fields)))
                   (false (st-pois-defunc st key g "family arity disagrees with the global's")))))))

(def collect (-> SigV CState)
  (lam (sig)
    (case sig ((sigv tys defs ctors) (collect-defs sig (cstate nil nil nil nil) defs)))))

; ---- lib/lowering/upper/closconv-driver.chiral ------------------------------
; CCOut gains a THIRD field.  Same argument as E185's second: a Sig cannot carry
; it, so it rides beside the Sig.
(data CCOut () (ccout (sig    Sig)
                      (stated (List (Pair Str (List NTalTy))))
                      (dsk    (List SkRec))))

(def closconv-sig (-> Sig CCOut)
  (lam (s)
    (case s ((mk-sig g p d la ld tg pf km sh)
      (let (sv (build-sigv s))
        (case (collect sv) ((cstate fams ho pois dsk)
          (case (keep-fams fams pois)
            (nil (ccout s nil dsk))          ; closure-free, and a refusal still reports
            ((cons kf kr)
              ; …  synth-fams as today
              (ccout (mk-sig ; …
                     ) stated dsk))))))))))

; ---- lib/lowering/compile-front.chiral --------------------------------------
; fr-ok gains a FIFTH field.  fr-err is untouched: a poisoned family is not an
; error, it is a named skip, which is exactly keep-fams' own granularity.
(data FR () (fr-ok (defs  (List NDef)) (datas (List NData)) (prims (List NPrim))
                   (ports (Maybe (List Str))) (dsk (List SkRec)))
            (fr-err (msg Str)))

(def bridge-sig (-> CCOut Str FR)
  (lam (cc name)
    (case cc ((ccout sig sp dsk)
    ; …  glookup / peel-globals / has-def unchanged
      (fr-ok defs (datas->n (sig-datas sig)) (prims->n (sig-prims sig))
             (ports-manifest (sig-profiles sig)) dsk)))))

; ---- lib/lowering/compile-back.chiral ---------------------------------------
; back-program's LAST TWO arguments to lower-defs are already the seed TFn and
; seed SkRec lists and are already `nil nil`.  The seat exists; only the entry
; needs to offer it.
(def back-program (-> (List NDef) (List NData) (List NPrim) (List SkRec) BR)
  (lam (defs ndatas nprims seed)
    (lower-defs (program-lits defs)
                (app-ts (nprims->table nprims) prim-table)
                (def-sigs defs) (ndatas->ddatas ndatas) defs nil seed)))

; ---- lib/lowering/compile-all.chiral ----------------------------------------
; the join.  format-blame already renders a SkRec chain; the front's skips just
; have to arrive.
(def compile-all (=> Str Str CAllR)
  (lam (src entry)
    (case (compile-front src entry)
      ((fr-err m) (ca-err m))
      ((fr-ok defs datas prims ports dsk)
        (case (back-program defs datas prims dsk)
          ((br-err m) (ca-err m))
          ((br-ok fns lits skips)
            (case (emit-elf-m fns lits entry ports)
              ((elf-ok b) (ca-ok b))
              ((elf-err m) (case skips
                (nil (ca-err m))
                ((cons s r) (ca-err (str-cat m (str-cat " | " (format-blame entry skips))))))))))))))
```

- **Knobs to modify:**
  - **The `why` strings.** Two conditions today. If a third refusal joins
    `st-add-gsite`, it gets a third string. A future run may prefer a nested sum
    over a `Str` here, which is the STANDING DIRECTIVE applied one level deeper;
    this pre-run keeps `Str` because `SkReason`'s other two arms carry `Str`
    payloads and matching them costs nothing.
  - **Where the seed enters the back.** `back-program` gaining a parameter is one
    option; `compile-all` calling `lower-defs` directly is another and it skips a
    signature change at the cost of reaching past the back's entry.
  - **Whether `pois` and `dsk` merge.** They are kept separate above because
    `keep-fams` filters on keys and a key is not a name. A SPEC may argue for one
    list of pairs.
- **Deliberately omitted:**
  - **A second stated channel through `datas->n`.** §1.3 measures it as
    transporting a value identical to what `field-tys->n` already computes, under
    E186's `concrete` ruling. It is not in this snippet on purpose.
  - **Any edit to `apply-ty`.** §1.4: its domain content is read by nothing, and
    the ruling forbids the only honest replacement.
  - **The `$clo<i>` drop-consistency check.** §1.5: `lib/lowering/tal/erase.chiral:193-194` and `:249-250`
    already refuse by name on the live path.
  - **`prog/e186-capture-fields.prog`'s pattern update.** Mechanical, one line at
    `:287`, and it must land in the same commit as the `CCOut` widening or that
    probe stops compiling.

## 6. Use / modify notes

- **Lands in:** `lib/lowering/upper/closconv.chiral`,
  `lib/lowering/upper/closconv-driver.chiral`, `lib/lowering/compile-front.chiral`,
  `lib/lowering/compile-back.chiral`, `lib/lowering/compile-all.chiral`, and
  `prog/e186-capture-fields.prog` for the pattern. All six are inside the blob, so
  the full BUILD RULE applies: `build-new → test → promote` with the fixpoint
  verified and the Step-0 precondition checked first.
- **Conformance target:** a fixture outside `lib/` and `prog/` whose `cs-g` site
  trips `st-add-gsite`'s arity arm compiles today to
  `... : extern does not lower: body is not a lambda chain`, and after the change
  reports the defunctionalization refusal by name, with `g` in it.
  `tools/test/samples/e188_slot_break.prog` is the shape already in the tree that
  reaches the guard, and it is the natural base. Non-regression: the blob's
  fixpoint holds and `tools/test/apply-spine.sh` stays at `11 ok, 0 FAIL`. ⚑ The
  emitted code must be BYTE-IDENTICAL over `lib/` and `prog/`, because E188
  measured a guard-off rebuild identical there, so no family in this tree is
  poisoned and no blame should appear.
- **Open questions:**
  1. **Is E187 still a whole element? ANSWERED 2026-09-05 by the author:
     option (i), re-scope in place.** The pre-run's answer was **no, as minted**,
     and the EXAMPLE-level audit confirmed every measurement it rests on. The
     type-statement content is fully consumed: `$apply<i>` by E185, `$k<i>_<j>`
     by E186, `$clo<i>` by E186 because it has no content of its own (§1.3), and
     `apply-ty`'s residue by the ruling (§1.4). Only §1.6's blame channel
     survives, and it entered the tree from E188 rather than from this row.

     - **(i) Re-scope E187 in place. TAKEN.** The type-statement clauses are
       struck from `docs/elements/catalog.md`, `docs/elements/ledger.md`,
       `docs/examples/INDEX.md` and `docs/arcs/enforcement-arc.md`, the element
       is retitled to the `sk-defunc` blame channel, and §5 stands as its
       example. Each row records what E187 WAS and that E185 and E186 consumed
       it, rather than erasing the old subject. The dependency edges stay honest
       as history and gain `←E188`. Four row rewrites, no free number consumed,
       and the whole thing is reversible.
     - **(ii) Retire E187 as consumed and mint the channel fresh. REJECTED.**
       Clean provenance, at the price of the band: `E189` is the LAST free number
       in Lane A's `E184-E189` block and it is shared with
       [[arcs/diagnostics-arc]]. Spending a scarce contested number is what
       produced the two-`E173` collision this tree records, and the next Lane A
       mint would have needed a band decision first.

     **The re-scope run mints nothing and `E189` stays free.** It also leaves the
     artifact's filename at the `stated-invented-names` slug: the slug is the
     provenance of what this example was minted to examine, `pack.py` resolves
     the element by globbing `E187-*`, and the INDEX link and the self-wikilink
     in **Related** below both point at the current name.
  2. **Does the blame channel warrant a full element on its own?** It is six
     files, all inside the blob, so it is a full BUILD RULE run with a fixpoint,
     and it has a real observable (the refusal message changes on a fixture that
     already exists). That is element-sized. It is also pure plumbing with no
     choice between shapes the codebase does not settle, which is the build rule's
     own test for whether the pipeline is owed at all
     (`docs/definitions/working-discipline.md`). ⚑ The audit adds one shape
     choice the pre-run left implicit and §5's knobs half-name: `pois` and `dsk`
     as two lists against one list of pairs. `keep-fams` (`closconv-driver.chiral:96-106`)
     filters on `key-in? pois key`, so merging them makes every membership test
     project a pair, and `st-add-pois` is called from three sites of which only
     `st-add-gsite`'s two carry a name; the third passes a higher-order key,
     a type with no global attached. One list of pairs therefore needs a `Maybe Str`
     or a fourth `SkReason` arm. That is a genuine fork, and it is what tips
     question 2 toward yes. The SPEC stage should answer
     that against the rule rather than by size.
  3. **The stale spans in §1.1. CLOSED for the doc tier, OPEN in the source.**
     E187's four homes were repaired at `4d00373` and E185's rows at the
     re-scope run, which recorded the live lines: `apply-ty` at
     `closconv.chiral:1163-1165`, its one call site at
     `closconv-driver.chiral:206`, `arm-body` at `closconv.chiral:1109-1126`.
     `docs/examples/INDEX.md`'s E185 row carried no drifted citation.
     `ledger-lint` check R lands a citation on its symbol and does not flag a
     span that has drifted past it, so the class keeps recurring.
     ⚑ **Three COMPILER SOURCE comments carry the same drift and are left
     standing on purpose**: `lib/lowering/compile-front.chiral:194`,
     `lib/lowering/upper/closconv-driver.chiral:119` and
     `lib/lowering/upper/closconv.chiral:1153` all cite `shape-eq` at
     `closconv.chiral:335-356` where it is `:340-356`. A comment-only edit under
     `lib/` owes the full BUILD RULE with a fixpoint, so it is not a doc-tier
     repair. The natural home is this element's own implementation run, which
     already touches `closconv` and `closconv-driver`.
  4. **Does `format-blame` render `sk-defunc` acceptably?** `skwhy-tag`
     (`skip-diag.chiral:29`) already returns `"defunc"` and `skwhy-name` returns
     the global. Unverified whether the rendered line reads well beside the
     `extern` and `callee` arms; a SPEC should pin the exact string.
- **Related:** [[E187-stated-invented-names]] · [[E185]] (built the channel and
  populated it for the one name that is a global) · [[E186]] (ruled the fields
  `concrete`, which is what closes the other two names) · [[E188]] (minted
  `sk-defunc` and left it unreached; §1.6 is its residue) · [[E97]] (`SkReason`
  and `SkRec`, the boundary sum this extends) · [[E100]] (`field-erased?`, the
  built guard §1.5 rests on) · [[banks/erasure]] (shards D, F and G) ·
  [[decisions/decision-erased-word-level]] (why §1.4 cannot be repaired) ·
  [[records/enforcement-arc]] EN-15, EN-18, EN-21, EN-22 ·
  [[arcs/enforcement-arc]]
