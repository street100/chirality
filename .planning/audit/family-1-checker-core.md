# Family 1 — Checker stack, part 1 of 2 (E1–E7)

**Elements:** E1 s-expression reader · E2 surface elaborator · E3 NbE eval/quote/conv ·
E4 bidirectional infer/check + universes · E5 QTT semiring + usage vectors ·
E6 data/constructors/coverage/ctor-unification · E7 strict positivity / variance.

**State of the family.** This is the healthiest family in the catalog: every element
is IMPLEMENTED, tested (191 green per the memory ledger), and written as tuple-tag
functional Python that maps almost one-for-one onto chirality data + case. There are
no algorithmic REDOs. The real work is a **shared substrate the catalog does not
yet name**: (a) a `Term`/`Value`/`Qty` data-type family in chirality (coordinating with
E13, family 2), (b) a `Res`/Either error type plus a bind discipline — the entire
checker's control flow is exceptions today and chirality has no early-exit sugar, and
(c) a functional `Sig` (threaded, alist-backed — `lib/collections.chiral` already
declares this destiny in its header). Two scaffold shortcuts are papered over and
must be planned around, not silently ported: type-level `case` gets stuck on
neutral scrutinees (`data.py:54`), and constructor fields cannot depend on earlier
fields (`data.py:134–135`, = catalog E48). One honest structural fact discovered:
**the self-hosted checker cannot prove itself total under its own current
termination pillars** (mutual recursion via `declare`, non-structural descent) —
it will sit in the `sig.totality` ledger as classified-not-proven until E50/E47 land.

---

## E1 — S-expression reader   [SELF-HOST · Tier R]

**Lives now:** `scaffold/chirality/sexp.py:1–95` (whole file): `Sym` `:8–14`,
`ReadError` `:16–19`, `read_all` `:22–30`, `_tokenize` `:33–72`, `_parse` `:75–95`.
Consumed by `surface.py:28` (`from .sexp import read_all, Sym`).

**Verdict:** PROPER — a straight port; small, single-pass, no lookahead beyond one
character. Named translation obligations below; none change the algorithm.

**Explainer.** The reader is deliberately dumb: four token kinds (`(`, `)`, atom,
string), `;`-comments, line counting for error provenance. Every toplevel form is
returned paired with its line (`read_all` → `[(form, line)]`), and that pairing is
load-bearing — `surface.py:61–65` wraps every kernel error in `file:line`. Four
CPython conveniences hide in 95 lines. (1) **Atoms fall back through `int()`**
(`sexp.py:93`): Python's `int()` is bignum and accepts underscores, so `1_0` reads
as the literal 10 and `99999999999999999999999` reads as a literal wider than I64.
The chirality reader must define literal policy: digits (with optional leading `-`)
only, and out-of-I64-range is a read error — arithmetic wrap semantics are settled
(Euclidean/two's-complement, `docs/chirality-division-euclidean` memory) but *literal
range at read time is currently undecided*; naming it is a finding. (2) **`Sym` is
a `str` subclass** so symbol equality is string equality — port as plain `Str` +
`str-eq`; a distinct wrapper buys nothing. (3) **The escape map is a dict literal**
(`sexp.py:56`) with a `.get(c, c)` unknown-escape passthrough — port as a case on
byte values; keep the passthrough (it is behavior, not an accident). (4)
**`_parse` recurses on nesting depth** — unbounded Python recursion; the chirality port
recurses too (fine — bounded by input), but note the reader loops are *numeric
loops with a symbolic bound* `(blen src)`, which today's termination classifier
cannot prove (the guard compares against an `App`, not a var/constant —
`data.py:550–553`); the reader will be classified not-proven-total unless written
countdown-style (see recipe step 6). Also: no `Char` type exists — the lexer works
on `Bytes` via `bget` returning `I64`, so character constants are numeric literals
with comments (`40` = `(`), a papercut worth a named-constants block.

**Translation dossier.**

*Source exemplar* — the atom/dispatch heart, `sexp.py:66–71` and `:89–95`:

```python
        else:
            j = i
            while j < n and src[j] not in ' \t\r\n();"':
                j += 1
            toks.append(("atom", src[i:j], line))
            i = j
    ...
    if kind == "str":
        return ("#str", val), i + 1, line
    # atom: integer or symbol
    try:
        return int(val), i + 1, line
    except ValueError:
        return Sym(val), i + 1, line
```

*Target sketch* — every construct cited to an existing exemplar:

```lisp
; data with typed fields: modeled on TInstr, lib/tal-ir.chiral:19-34
(data Sexp ()
  (s-int  (v I64))
  (s-str  (v Str))
  (s-sym  (name Str))
  (s-list (items (List Sexp))))          ; recursive field: List, lib/prelude.chiral:17-19

(data Tok ()
  (t-open  (line I64))
  (t-close (line I64))
  (t-atom  (s Str) (line I64))
  (t-str   (s Str) (line I64)))

; byte classification: bget/=i/case on Bool, modeled on wsplit1, lib/wire.chiral:33-40
(def delim? (-> I64 Bool)
  (lam (c)
    (or (=i c 32) (or (=i c 9) (or (=i c 13)
    (or (=i c 10) (or (=i c 40) (or (=i c 41)
    (or (=i c 59) (=i c 34))))))))))      ; or: lib/prelude.chiral:65-66

; the atom scan: countdown parameter `rem` so the numeric measure proves
; (guard (<=i rem 0) gives lo=1 on the false path; step -1 is in-bounds).
; recursion + case shape modeled on rev-onto, lib/collections.chiral:21-25
(def scan-atom (-> Bytes I64 I64 I64)     ; src, i, rem -> end index
  (lam (src i rem)
    (case (<=i rem 0)
      (true i)
      (false
        (case (delim? (bget src i))
          (true i)
          (false (scan-atom src (+ i 1) (- rem 1))))))))

; atom -> Sexp: int-or-symbol. str->i64 junk-parses to 0 (prelude:41 comment),
; so digits must be validated FIRST -- a helper `all-digits?` over bytes.
(def atom->sexp (-> Str Sexp)
  (lam (s)
    (case (all-digits? s)
      (true (s-int (str->i64 s)))
      (false (s-sym s)))))
```

The reader's error channel needs the family-wide `Res` type (see family header /
E4 dossier); `read-all : (-> Str (Res (List (Pair Sexp I64))))` pairs each
toplevel form with its line, modeled on `Pair` (`lib/prelude.chiral:10–11`).

*Mechanical recipe.*
1. COPY: token-kind state machine of `_tokenize` (`sexp.py:33–72`), branch for
   branch, as a `case` ladder on `(bget src i)`.
2. COPY: `_parse` recursive descent (`sexp.py:75–95`) — list accumulation via
   `cons` + `reverse` (`lib/collections.chiral:27–29`).
3. TRANSLATE (rule: exceptions→`Res`): `ReadError` becomes `(bad "read error at
   line ...")` threaded up the return; message built with `str-cat`/`i64->str`
   as in `lit-label` (`lib/emit-core.chiral:26–27`).
4. TRANSLATE (rule: str-subclass→plain Str): drop `Sym`; symbols are `Str`.
5. NEW (small): `all-digits?` + explicit I64-range check for literals — decide
   and document reject-vs-wrap for out-of-range literals. Also a named-constants
   block for byte codes (no char literals in chirality).
6. NEW (small): countdown-`rem` loop shape so the lexer proves total, or accept
   not-proven classification and note it in the ledger.

**Dependencies:** none (Bytes/Str floor exists in `lib/prelude.chiral`). Unblocks E2.
File loading for `import` is NOT this element — see E2/cross-family flags.

**Est. pass size:** S.

---

## E2 — Surface elaborator   [SELF-HOST · Tier R]

**Lives now:** `scaffold/chirality/surface.py` (whole file): `Elab` `:41–47`,
`load_file/load_str` `:51–72`, `toplevel` `:74–136`, `top_profile` `:144–200`,
`top_target` `:202–216`, `top_data/_top_data_body` `:218–261`, `elab` `:265–316`,
`resolve` `:318–333`, `apply` `:335–348`, `arrow` `:350–367`, `lam` `:369–380`,
`let` `:382–404`, `case` `:406–429`, `do_` `:431–451`, `used_ports` `:454–487`,
`verify_profiles/verify_targets` `:490–536`.

**Verdict:** EXTEND — the elaboration algorithm (name→de Bruijn, desugaring) is
sound and ports cleanly; three named missing pieces: (a) file loading for
`(import ...)` has no chirality-side substrate (no `open`/`openat` sys slice exists —
`lib/sys-tal.chiral` has read/write/lseek/memfd/ftruncate only); (b) error
provenance (`file:line:` wrapping, `surface.py:61–65`) needs the `Res` discipline
to carry and re-wrap messages; (c) the elaborator is also the *installer* — it
mutates `sig` at every toplevel — so it is where the functional-Sig threading
decision bites first.

**Explainer.** The elaborator is scope-list + syntax-directed dispatch. The scope
is a Python list of names appended innermost-last, and `resolve` scans backwards
(`surface.py:320–322`) computing `("Var", len(scope)-1-i)` — in chirality, cons the
scope innermost-*first* and the position IS the de Bruijn index (translation rule
T2 below); this inversion is the one place a port can silently flip binding.
`resolve`'s fall-through order is semantic: scope shadows atoms shadows
constructors shadows data shadows globals shadows prims (`surface.py:318–333`) —
copy the order exactly. The desugarings each have one trap. `arrow`
(`:350–367`): every non-last binder is a *pure* Pi and only the last arrow of
`=>` is effectful (`eff and is_last`, `:366`) — that single boolean is the whole
effect-membrane surface encoding. `do_` (`:431–451`) is *recursive* sugar: a
plain step becomes a linear `Let` of `#u` plus a unit-destructuring `Case`; a
`(<- x e)` bind is a quantity-1 `Let` — both shapes are pure Term-building,
trivially portable. `top_data` pre-registers a provisional `DataDecl`
(`:229–238`) so recursive field types resolve, with rollback on failure — under
a threaded Sig the rollback is free (discard the candidate Sig), which *deletes*
a whole class of `try/except`+`del` cleanup code (`surface.py:102–106`,
`:234–238`, `kernel.py:552–553`, `data.py:443–445`). `used_ports`/`verify_*`
(`:454–536`) are pure walks over the finished Sig and port directly. The `QUANTS`
dict (`surface.py:34`) keys mixed `0, 1, Sym("w")` — a CPython heterogeneous-key
convenience; in chirality it is a 3-arm case on the sexp atom.

**Translation dossier.**

*Source exemplar* — `resolve`, `surface.py:318–333`:

```python
    def resolve(self, s, scope):
        name = str(s)
        for i in range(len(scope) - 1, -1, -1):
            if scope[i] == name:
                return ("Var", len(scope) - 1 - i)
        if name in K.CORE_ATOMS or name in self.sig.atom_types:
            return ("PrimTy", name)
        if name in self.sig.ctor_home:
            return ("Con", self.sig.ctor_home[name], name, [])
        if name in self.sig.data:
            return ("TCon", name, [])
        if name in self.sig.global_types:
            return ("Global", name)
        if name in self.sig.prim_types:
            return ("Prim", name)
        raise SurfaceError(f"unknown name {name}")
```

*Target sketch* (Term ctors from the shared term-rep pass, E3/E13; every
construct cited):

```lisp
; scope-index: innermost-first scope list, position = de Bruijn index.
; Maybe-returning recursion modeled on alist-get, lib/collections.chiral:61-71
(def scope-index (-> (List Str) Str (Maybe I64))
  (lam (sc name)
    (case sc
      (nil (the (Maybe I64) none))
      ((cons h t)
        (case (str-eq h name)
          (true (some 0))
          (false
            (case (scope-index t name)
              (none (the (Maybe I64) none))
              ((some r) (some (+ r 1))))))))))

; resolve: the shadowing ladder, in source order. alist-has over the threaded
; Sig registries (alists per lib/collections.chiral header comment, :1-5)
(def resolve (-> Sig (List Str) Str (Res Term))
  (lam (sg sc name)
    (case (scope-index sc name)
      ((some ix) (ok (tm-var ix)))
      (none
        (case (atom-type? sg name)
          (true (ok (tm-primty name)))
          (false
            (case (alist-get Str Str str-eq (sig-ctor-home sg) name)
              ((some dn) (ok (tm-con dn name nil)))
              (none ...))))))))   ; data -> global -> prim -> (bad "unknown name")
```

Toplevel driver: `toplevel : (=> Sig (Pair Sexp I64) (Res Sig))` — takes and
returns Sig (rule T5), the case-on-head shape modeled on `emit-instr`'s
constructor dispatch (`lib/emit-core.chiral:29–44`).

*Mechanical recipe.*
1. COPY: the dispatch skeletons of `elab` (`:265–316`) and `toplevel` (`:74–136`)
   as case ladders on `Sexp`; keep every arity/shape validation branch.
2. COPY: `arrow`/`lam`/`let`/`case`/`do_` desugarings (`:350–451`) — pure
   Term-builders; fold with `reverse`d binder lists exactly as the Python does.
3. TRANSLATE (rule T2, scope inversion): `scope + [name]` → `(cons name scope)`;
   `len(scope)-1-i` → position. Verify with the existing Python as oracle on
   the whole `lib/` corpus (elaborate both, compare terms).
4. TRANSLATE (rule T4): `sig.data`/`ctor_home`/`global_types`/`prim_types`/
   `targets`/`profiles` dicts → alists keyed by `str-eq`; `loaded` set →
   `List Str` + member test (`any-list`, `lib/collections.chiral:52–56`).
5. TRANSLATE (rule T5): every installing function takes `Sig`, returns
   `(Res Sig)`; drop all rollback `try/except del` blocks — failure discards
   the candidate Sig.
6. TRANSLATE (rule T3): `SurfaceError` → `bad`; line-wrapping becomes a
   `res-context : (-> Str (Res A) (Res A))` helper prefixing `name:line:`.
7. NEW: file loading for `import` — blocked on an `openat` sys slice
   (cross-family flag); until then the driver takes pre-concatenated source
   (the `load_str` path, `:67–72`, is the porting seam).
8. NEW (small): line tracking through elaboration if sub-form errors should
   cite sub-form lines (Python only cites the toplevel form's line — match
   that first, improve later).

**Dependencies:** E1 (Sexp), the shared Term data (E3/E13 coordination), E4–E7
(it calls `check_def`/`check_data`/`declare_extern`). Port it LAST in the
family; it is the integration point. Unblocks: self-hosted `chirality check`.

**Est. pass size:** M.

---

## E3 — NbE: eval / quote / conv (+ eta)   [SELF-HOST · Tier P, verified Tier O]

**Lives now:** `scaffold/chirality/kernel.py`: `eval_term` `:220–249`, `vapp`
`:252–258`, `close_apply` `:261–263`, `conv` `:268–304`, `subtype` `:307–316`
(shared with E4), `quote` `:334–368`, `Sig.global_value` `:152–165` (the
value cache + recursion guard). Value forms documented `:44–49`.

**Verdict:** PROPER — textbook closure-based NbE; the pass is a straight port
onto the shared Value data type. Two named seam decisions ride along (below).

**Explainer.** Values mirror terms; closures are `(env, term)` pairs; neutrals
are spines `("VNe", head, [args])` with heads `NVar`(level)/`NGlobal`/`NPrim`.
Quote converts levels back to indices via `lvl - 1 - head[1]` (`kernel.py:357`).
Conv is type-directed-free: it eta-expands whenever *either* side is a `VLam`
(`:270–274`), compares Pi domains/codomains under a fresh neutral, and falls to
`conv_hooks` (refine.py's seam) before failing. The traps a port must not lose:
(1) **env ordering** — Python appends (`env + [a]`, `:237,255`) and indexes from
the far end (`env[len(env)-1-t[1]]`, `:223`); chirality should cons-front so `Var i`
is `nth i` (rule T2). (2) **Neutral spine order** — args append at the tail
(`:257`); if the port cons-fronts the spine it must reverse in `quote` (`:361–363`
folds left-to-right); recommend keeping append (`append`,
`lib/collections.chiral:15–19`) so quote stays a copy. (3) **`Sig.global_value`
is a mutating cache with a re-entrancy guard** (`_evaluating`, `:158–163`) that
turns a recursive *bare value* definition into an error instead of a hang. The
functional port has three options: recompute every time (correct, slow),
thread the cache through Sig (correct, invasive), or pre-compute at install
time (each `finish_def` evaluates the body once and stores the value —
recursion guard becomes unnecessary because installation is ordered). Option 3
matches the threaded-Sig shape best; the recursion-in-bare-value error must
then be raised at install. (4) **Stuck case**: `_eval_case` (`data.py:44–54`,
element E6) raises on neutral scrutinees — the *evaluator* is where the fix
lands if case-on-neutral is ever supported (a `VCase` neutral form + quote/conv
arms). Porting eval as-is preserves the scaffold limit; say so in the port's
header. (5) Eval and vapp are **mutually recursive** — use the proven
`declare` pattern (`lib/emit-core.chiral:56` declares `emit-code` before
`emit-branches` uses it) — and will be classified not-proven-total (forward
reference, `data.py:666–669`); that is expected and honest.

**Translation dossier.**

*Source exemplar* — `eval_term`/`vapp` core, `kernel.py:231–237, 252–258`:

```python
    if k == "Pi":
        return ("VPi", t[1], t[2], t[3], eval_term(sig, env, t[4]), (env, t[5]))
    if k == "Lam":
        return ("VLam", t[1], (env, t[2]))
    if k == "App":
        return vapp(sig, eval_term(sig, env, t[1]), eval_term(sig, env, t[2]))
    if k == "Let":
        return eval_term(sig, env + [eval_term(sig, env, t[3])], t[4])
...
def vapp(sig, f, a):
    if f[0] == "VLam":
        env, body = f[2]
        return eval_term(sig, env + [a], body)
    if f[0] == "VNe":
        return ("VNe", f[1], f[2] + [a])
    raise KernelError(f"cannot apply {f[0]}")
```

*Target sketch* — the shared term-rep data plus the eval core. The data decls
are the single most load-bearing NEW artifact of the family (coordinate with
E13, which owns `uses_below`/`shift_close` over the same type):

```lisp
; Term: one recursive data type. Heterogeneous Python tuples become one ctor
; per tag; Case branches use the nested-Pair trick PROVEN in lib/tal-ir.chiral:41-46
; ("one recursive type, no mutual data: a branch is ((tag, binds), code)").
(data Qty () (q0) (q1) (qw))
(data Term ()
  (tm-type   (lvl I64))
  (tm-var    (ix I64))
  (tm-pi     (q Qty) (eff Bool) (name Str) (dom Term) (cod Term))
  (tm-lam    (name Str) (body Term))
  (tm-app    (f Term) (a Term))
  (tm-let    (q Qty) (name Str) (val Term) (body Term))
  (tm-ann    (e Term) (ty Term))
  (tm-lit-i  (v I64))
  (tm-lit-s  (v Str))
  (tm-primty (name Str))
  (tm-global (name Str))
  (tm-prim   (name Str))
  (tm-tcon   (dname Str) (args (List Term)))
  (tm-con    (dname Str) (cname Str) (args (List Term)))
  (tm-case   (scrut Term)
             (branches (List (Pair (Pair Str (List Str)) Term)))
             (dflt (Maybe Term)))
  (tm-refine (base Term) (atoms (List (Pair Str Term)))))

; Neutral heads are non-recursive; declare before Value (ordering, not mutual
; data -- Term does not mention Value, so the chain Term -> NeHead -> Value works)
(data NeHead () (n-var (lvl I64)) (n-global (name Str)) (n-prim (name Str)))

(data Value ()
  (v-type   (lvl I64))
  (v-primty (name Str))
  (v-lit-i  (v I64))
  (v-lit-s  (v Str))
  (v-pi     (q Qty) (eff Bool) (name Str) (dom Value)
            (cod-env (List Value)) (cod Term))       ; closure inlined: (env, term)
  (v-lam    (name Str) (env (List Value)) (body Term))
  (v-tcon   (dname Str) (args (List Value)))
  (v-con    (dname Str) (cname Str) (args (List Value)))
  (v-ne     (head NeHead) (args (List Value))))
; NOTE: refine.py's refinement VALUE form must join this closed type -- the
; Python quote/conv/check hooks keyed on unknown value forms have no open
; equivalent here. See "seam architecture" cross-family flag.

; eval core: mutual recursion via declare, per lib/emit-core.chiral:56
(declare eval-term (-> Sig (List Value) Term (Res Value)))

(def vapp (-> Sig Value Value (Res Value))
  (lam (sg f a)
    (case f
      ((v-lam name env body) (eval-term sg (cons a env) body))
      ((v-ne h args) (ok (v-ne h (append Value args (cons a nil)))))
      (_ (bad "cannot apply a non-function")))))

(def eval-term
  (lam (sg env t)
    (case t
      ((tm-var ix) (list-nth Value env ix))          ; NEW helper, see recipe
      ((tm-lam name body) (ok (v-lam name env body)))
      ((tm-pi q eff name dom cod)
        (case (eval-term sg env dom)
          ((bad m) (bad m))
          ((ok dv) (ok (v-pi q eff name dv env cod)))))
      ((tm-app f a)
        (case (eval-term sg env f)
          ((bad m) (bad m))
          ((ok fv) (case (eval-term sg env a)
            ((bad m) (bad m))
            ((ok av) (vapp sg fv av))))))
      ...)))                                          ; remaining arms 1:1
```

(`case`/`let`/`the` shapes as in `emit-code`, `lib/emit-core.chiral:80–97`;
polymorphic `append` call as `lib/emit-core.chiral:15`.)

*Mechanical recipe.*
1. NEW (the family's keystone, shared with E13/family 2): the
   `Qty/Term/NeHead/Value` declarations above, plus `Res`
   (`(data Res ((A (type 0))) (ok (val A)) (bad (msg Str)))` — modeled on
   `Maybe`, `lib/prelude.chiral:14–16`) and a `list-nth` helper in
   `lib/collections.chiral` (shape of `alist-get`). ~60 lines; do it as its own
   mini-pass so E3–E7 and family 2 build on one artifact.
2. COPY: `eval_term`/`vapp`/`close_apply` arm-for-arm (rule T1: tuple tag →
   ctor; rule T2: env append→cons-front, far-end index→`list-nth`).
3. COPY: `conv` (`:268–304`) — keep the eta-first check order (either-side
   VLam before the tag comparison) and the Pi quantity/eff equality (`:284`);
   pairwise arg comparison via a two-list `all-conv2` recursion (zip-style, no
   zip exists — same shape as `uadd` in E5).
4. COPY: `quote` (`:334–368`) — level-to-index arithmetic `lvl - 1 - head-lvl`
   verbatim; spine fold as a `foldl` (`lib/collections.chiral:46–50`).
5. TRANSLATE (rule T3): `KernelError` raises → `bad`; the `Res` case-ladder is
   the tax (see redo list item 1 for the sugar question).
6. TRANSLATE (Sig cache): replace `global_value`'s mutate-and-guard with
   install-time evaluation stored in the Sig (decision recorded in the pass);
   recursion-in-bare-value becomes an install-time error.
7. Tier-O verification: golden corpus — run the Python checker and the chirality
   checker on `lib/*.chiral` + `tests/` fixtures, compare quoted normal forms.

**Dependencies:** term-rep mini-pass (step 1). Unblocks E4 (infer/check calls
eval/conv/quote everywhere) and E6.

**Est. pass size:** M (S if the term-rep mini-pass lands separately first — do that).

---

## E4 — Bidirectional infer/check + universes/cumulativity   [SELF-HOST · Tier P, verified Tier O]

**Lives now:** `scaffold/chirality/kernel.py`: `infer` `:373–453`, `check`
`:456–501`, `subtype` `:307–316`, `expect_universe` `:504–508`,
`strip_binder/close_binder` `:511–522`, `Ctx` `:170–201` (incl. `narrow`
`:189–200`), toplevel ops `declare_def/finish_def/check_def/declare_atom/
declare_extern` `:531–584`.

**Verdict:** EXTEND — the bidirectional core is sound and ports directly; named
missing/decide pieces: (a) cumulativity is *shallow* — `subtype` covers only
`Type l ≤ Type l'` (`:311–312`) plus hook-installed refinement subtyping; Pi
types are compared by `conv`, i.e. **invariant** (no contravariant-domain /
covariant-codomain subtyping, no cumulativity under binders). The port should
copy this as-is (it is a coherent, conservative choice) but the dossier names
it: full cumulativity is a *decision*, not an omission to silently fix.
(b) The exceptions→`Res` translation is heaviest here — `infer`/`check` is one
big raise-happy dispatch. (c) The `rules` object (`sig.rules.on_apply/
on_binder/erased_allow`, effects module, E12) and the hook lists are consulted
at fixed points — the port must pin the seam representation (cross-family flag).

**Explainer.** The judgment is standard bidirectional: `infer` returns
`(type_value, usage_vector)`, `check` returns `usage_vector`, and `Lam` is
check-only (`:450–451` refuses to infer a bare lambda). The traps: (1) **App
inference evaluates the argument only when the codomain is dependent**
(`:423–427`, guarded by `uses_below(fty[5][1], 1)` peeking into the closure's
term) — eager evaluation would run and get stuck on runtime recursion; the
non-dependent branch substitutes a throwaway neutral. Copy exactly; this is a
hard-won fix. (2) **`check` re-runs `on_binder` at every lambda** (`:462–470`) —
the "type-level Pi smuggle" audit fix: a Pi produced by type-level computation
never passed formation-time checks, so a lambda could otherwise bind a linear
domain at `w`. The comment block is load-bearing; port it as a comment too.
(3) **Usage accounting is positional**: `Var` builds a one-hot vector
(`u[n-1-t[1]] = 1`, `:380–382`); `strip_binder`/`close_binder` (`:511–522`)
check the *last* slot against the declared quantity and drop/fold it. Under
cons-front vectors the one-hot position and the "last slot" flip to the head —
same inversion as E2's scope (rule T2); get it wrong and linearity silently
checks the wrong binder. (4) **`Ctx` keeps entries and NbE env in lockstep**
(`:180–184`): `bind` appends a fresh neutral at the current level. `narrow`
(`:189–200`) replaces one entry's *type* while sharing the env — path-
sensitivity's seam (E10); a functional Ctx (two parallel lists) makes both
trivial. (5) **`finish_def` rollback** (`:552–553`): delete-on-failure
disappears under threaded Sig. (6) `declare_extern`'s arity loop (`:579–583`)
applies the codomain closure to dummy neutrals with *wrong levels* — harmless
because only arity and the eff bit are extracted, but a port must not "fix" it
into something that reads the values. (7) `expect_universe` runs with
`allow_eff=False` (`:505`) — types are pure; keep.

**Translation dossier.**

*Source exemplar* — the App rule, `kernel.py:415–428`:

```python
    if k == "App":
        fty, uf = infer(sig, ctx, t[1], allow_eff)
        if fty[0] != "VPi":
            raise KernelError(f"applying a non-function of type {show_value(sig, len(ctx), fty)}")
        q = fty[1]
        arg_allow = sig.rules.on_apply(sig, ctx, fty, allow_eff)
        ua = check(sig, ctx, t[2], fty[4], arg_allow)
        # only evaluate the argument if the codomain is actually dependent;
        # eager evaluation would run (and get stuck on) runtime recursion
        if uses_below(fty[5][1], 1):
            arg_v = eval_term(sig, ctx.env, t[2])
        else:
            arg_v = ("VNe", ("NVar", len(ctx)), [])
        return close_apply(sig, fty[5], arg_v), uadd(uf, uscale(q, ua))
```

*Target sketch* (Ctx as data modeled on `EmitR`, `lib/emit-core.chiral:54`;
mutual `infer`/`check` via `declare`, `lib/emit-core.chiral:56`):

```lisp
(data CtxE () (ctx-e (name Str) (q Qty) (ty Value)))
(data Ctx  () (mk-ctx (entries (List CtxE)) (env (List Value))))

(def ctx-bind (-> Ctx Str Qty Value Ctx)
  (lam (c name q tyv)
    (case c
      ((mk-ctx es env)
        (mk-ctx (cons (ctx-e name q tyv) es)
                (cons (v-ne (n-var (length CtxE es)) nil) env))))))

(declare infer (-> Sig Ctx Term Bool (Res (Pair Value (List Qty)))))
(declare check (-> Sig Ctx Term Value Bool (Res (List Qty))))

; the App arm, Res-threaded; nested case-unwrap shape as in emit-branches,
; lib/emit-core.chiral:69-78 (case on a returned record, destructure, continue)
((tm-app f a)
  (case (infer sg c f allow)
    ((bad m) (bad m))
    ((ok r) (case r ((pair fty uf)
      (case fty
        ((v-pi q eff name dom cod-env cod)
          (case (check sg c a dom (rule-on-apply sg eff allow))
            ((bad m) (bad m))
            ((ok ua)
              (let (argv (case (uses-below cod 1)     ; uses-below: E13
                           (true (eval-term sg (ctx-env c) a))
                           (false (ok (v-ne (n-var (ctx-len c)) nil)))))
                ...))))                                ; close-apply, pair result
        (_ (bad "applying a non-function"))))))))
```

*Mechanical recipe.*
1. COPY: every `infer` arm (`:373–453`) and `check` arm (`:456–501`) in order;
   keep the arm ORDER of `check` (Lam, Let, ext-terms, hooks, fall-through to
   infer+subtype) — it is semantic.
2. COPY: `subtype` (`:307–316`): Type-cumulativity first, hooks, then conv.
3. COPY: `strip_binder`/`close_binder` with rule T2's inversion (last slot →
   head of cons-front usage vector — verify against Python oracle with a
   deliberately-failing linearity test from `tests/test_kernel.py`).
4. TRANSLATE (rule T3): raises → `bad` with `str-cat` messages; error TEXT can
   simplify (the Python interpolates `show_value` — pretty-printing is E14,
   non-trusted; a first pass may cite ctor names only).
5. TRANSLATE (rule T5): `declare_def/finish_def/declare_atom/declare_extern`
   take and return Sig; drop rollbacks.
6. TRANSLATE (seam pinning): `sig.rules.*` calls become direct calls into the
   ported effects module (E12, family 2) — record that the runtime-pluggable
   rules object becomes a compile-time module boundary (cross-family flag).
7. NEW (small): `uses-below` on the closure body — E13's walker must expose the
   closure's Term (the `fty[5][1]` peek); the inlined-closure Value above makes
   that a plain field access.

**Dependencies:** E3 (eval/conv/quote), E5 (usage vectors), E13/family 2
(`uses_below`). Unblocks E6 (its handlers call `infer`/`check` re-entrantly).

**Est. pass size:** L — slice as: (L1) infer/check pure fragment (no ext-terms,
no hooks) against literals/Pi/Lam/App/Let; (L2) toplevel ops + subtype + the
seam pinning; (L3) golden-corpus differential run vs Python.

---

## E5 — QTT quantity semiring + usage-vector linearity   [SELF-HOST · Tier P]

**Lives now:** `scaffold/chirality/kernel.py`: `qadd` `:64–69`, `qmul` `:72–79`,
`qjoin` `:82–84`, `qfits` `:87–90`, `uzero/uadd/uscale/ujoin` `:93–106`;
consumed at `infer` `:380–382, 428, 436`, `check` `:474, 481`, `data.py:187–191,
229–234, 248`.

**Verdict:** PROPER — six one-liner algebra functions plus four vector maps;
the cleanest port in the catalog.

**Explainer.** The semiring is `{0, 1, ω}` with saturation: `1+1 = ω`, anything
times/plus ω is ω (except 0·ω = 0), and `qjoin` (across case branches) saturates
*divergent* use to ω — a branch using a variable once and another using it zero
times joins to ω, which then only fits a ω binder. `qfits` is EXACT for 0 and 1
(`computed == declared`, `:87–90`): declared-0 must be used 0 times, declared-1
exactly once — this is the McBride/Atkey exact-usage reading, not "at most".
The Python representation is heterogeneous — ints `0`/`1` and the string
`"w"` (`terms.py:11`) — a CPython convenience that a typed port *improves* by
construction with a 3-ctor `Qty` data type. Usage vectors are plain lists
zipped positionally with the context; `zip` truncation never bites because all
vectors at a given point have length = len(ctx) by construction (an invariant
worth a comment, since the chirality two-list recursion will silently truncate the
same way). The only decision: grade-vector generalization (Fork A of
`docs/decision-graded-kernel.md` — the cost semiring enriches the SAME
positions) — port the 3-point semiring now, but name the functions so the
semiring is swappable (`qadd`, not `linear-add`), matching the settled
decision that cost is a kernel semiring enrichment.

**Translation dossier.**

*Source exemplar* — `kernel.py:64–90`:

```python
def qadd(a, b):
    if a == 0:
        return b
    if b == 0:
        return a
    return W  # 1+1 and anything involving W saturate

def qmul(a, b):
    if a == 0 or b == 0:
        return 0
    if a == 1:
        return b
    if b == 1:
        return a
    return W

def qjoin(a, b):
    """Merge usage across case branches: divergent use saturates to W."""
    return a if a == b else W

def qfits(computed, declared):
    if declared == W:
        return True
    return computed == declared
```

*Target sketch* (all shapes from `lib/prelude.chiral` helpers `not/and/or/max`,
`:59–76`, and two-list recursion from `append`, `lib/collections.chiral:15–19`):

```lisp
(data Qty () (q0) (q1) (qw))

(def qeq (-> Qty Qty Bool)
  (lam (a b)
    (case a
      (q0 (case b (q0 true) (_ false)))
      (q1 (case b (q1 true) (_ false)))
      (qw (case b (qw true) (_ false))))))

(def qadd (-> Qty Qty Qty)
  (lam (a b)
    (case a
      (q0 b)
      (q1 (case b (q0 (the Qty q1)) (_ qw)))
      (qw qw))))

(def qmul (-> Qty Qty Qty)
  (lam (a b)
    (case a
      (q0 q0)
      (q1 b)
      (qw (case b (q0 (the Qty q0)) (_ qw))))))

(def qjoin (-> Qty Qty Qty)
  (lam (a b) (case (qeq a b) (true a) (false qw))))

(def qfits (-> Qty Qty Bool)
  (lam (c d) (case d (qw true) (_ (qeq c d)))))

(def uzero (-> I64 (List Qty))               ; replicate; countdown proves total
  (lam (n) (case (<=i n 0) (true nil) (false (cons q0 (uzero (- n 1)))))))

(def uadd (-> (List Qty) (List Qty) (List Qty))
  (lam (u v)
    (case u
      (nil nil)
      ((cons a t)
        (case v
          (nil nil)
          ((cons b s) (cons (qadd a b) (uadd t s))))))))
; uscale = map-list Qty Qty (qmul q) u -- lib/collections.chiral:31-35
; ujoin  = same two-list shape as uadd with qjoin
```

*Mechanical recipe.*
1. COPY: truth tables above — verified against the Python by exhaustive 3×3
   enumeration (9 cases each; write the test in chirality too).
2. TRANSLATE (rule T6): int/`"w"` mixed rep → `Qty`; all `== 0`/`== W`
   comparisons → case arms.
3. TRANSLATE: `zip` comprehensions → two-list recursion (shape above); state
   the both-vectors-same-length invariant in a comment.
4. NEW: none. (Fork A enrichment later replaces `Qty` with the grade vector at
   the same seam — the function names ARE the seam.)

**Dependencies:** none. Do it FIRST — it is the smallest self-contained slice
of kernel semantics and shakes out the port workflow. Unblocks E4, E6.

**Est. pass size:** S.

---

## E6 — Data: constructors, case coverage, ctor-param unification   [SELF-HOST · Tier P, verified Tier O]

**Lives now:** `scaffold/chirality/data.py`: `DataDecl` `:14–20`, `install` `:23–31`,
`_eval_tcon/_eval_con/_eval_case` `:36–54`, `lookup_ctor` `:96–100`,
`_check_tcon` `:103–117`, `_ctor_field_types` `:120–135`, `_infer_ctor_params`
`:138–162`, `_check_con` `:165–191`, `_check_case` `:194–248`, `_ensure_escapes`
`:251–257`, `check_data` `:419–447`. Surface entry: `surface.py:218–261`.

**Verdict:** EXTEND — the checking algorithms are sound; two papered-over limits
must be carried as *named* limits in the port and one dead helper dropped:
(a) **telescope limit** — `_ctor_field_types` evaluates every field type in the
params-only env (`env = list(targs)`, `:127`) and the comment says it plainly
(`:134`: "fields may not depend on earlier fields (scaffold limit), only
params") = catalog **E48**; the port must reproduce the limit *and* leave the
seam visible (the env is where a telescope extension would thread earlier
field values). (b) **stuck type-level case** — `_eval_case` raises on neutral
scrutinees (`:54`: "scaffold limit: no case on neutral values in types"); a
properly dependent checker needs a neutral case value with conv/quote support —
extension work, not this port. (c) `_occurs` (`:262–285`) is **dead code**
(only self-referential; `_positivity` uses its own local `mentions`) — do not
port it.

**Explainer.** Four algorithms live here. (1) **TCon checking** (`:103–117`):
parameters check left-to-right, each earlier arg's *value* entering the env for
the next parameter's type (`env.append(...)`, `:113`) — parameters DO telescope
even though fields don't; parameter usage is erased (`K.check(..., False)` with
the ctx untouched, `:112`). (2) **Ctor checking** (`:165–191`) is
expected-type-driven; when no expected type exists, `_infer_ctor_params`
(`:138–162`) solves type args *only from bare-Var fields* — deliberately
bounded, and **sound-by-recheck**: the guess becomes the expected type and
every argument is re-checked against the instantiated fields, so a wrong guess
fails there rather than being trusted (`:146–150` comment). The de Bruijn
arithmetic `p = nparams - 1 - fty[1]` (`:156`) recurs in E7 — parameters bind
outermost. Field-usage accounting scales each arg's usage by the field
quantity (`:188–190`). (3) **Case checking** (`:194–248`): scrutinee must infer
to a `VTCon`; branch fields are instantiated per-branch; the FIRST branch's
inferred type becomes the expected type for the rest when no annotation exists,
laundered through `_ensure_escapes` (`:251–257` — quote at inner level, refuse
if it `uses_below` the branch binders, `shift_close` down, re-eval in the outer
env: a precise little dance, copy it exactly). Branch-binder usage is checked
against field quantities *positionally* (`ub[len(ctx) + i]`, `:229–232`) then
truncated (`ub[:len(ctx)]`) and `ujoin`ed across branches; the scrutinee's
usage adds ONCE at the end (`:248`). Coverage: exhaustive-or-default against
`decl.order` (`:242–244`) — no default means every ctor named. `narrow_hooks`
run per-branch BEFORE binding fields (`:216–221`) — order matters for the
refinement seam (E10). (4) **check_data** (`:419–447`): params form a
telescoping ctx; each field must be a universe inhabitant, strictly positive
(E7), and non-linear-at-non-1; `sig.data` self-registration before field
checking makes recursive data resolve; `ctor_home` fills only after success.
CPython conveniences: dicts for `ctors` (declaration order preserved separately
in `order` — the port keeps `order` as THE list and makes `ctors` an alist);
`covered` as a set (→ `List Str` + `any-list`/`str-eq` member).

**Translation dossier.**

*Source exemplar* — the coverage + join core, `data.py:229–248`:

```python
        for i, (name, (q, fname, ftyv)) in enumerate(zip(names, ftys)):
            used = ub[len(ctx) + i]
            if not K.qfits(used, q):
                raise KernelError(f"in branch {cname}: field binder {name} declared {q} but used {used} time(s)")
        ub = ub[:len(ctx)]
        joined = ub if joined is None else K.ujoin(joined, ub)

    if default is not None:
        if result_ty is None:
            result_ty, ud = K.infer(sig, ctx, default, allow_eff)
        else:
            ud = K.check(sig, ctx, default, result_ty, allow_eff)
        joined = ud if joined is None else K.ujoin(joined, ud)
    elif covered != set(decl.order):
        missing = [c for c in decl.order if c not in covered]
        raise KernelError(f"non-exhaustive case on {dname}: missing {', '.join(missing)}")
```

*Target sketch* (member/filter over `Str` lists — `any-list`/`filter`,
`lib/collections.chiral:37–56`; `DataDecl` as data modeled on `TFn`,
`lib/tal-ir.chiral:48–49`):

```lisp
(data Field () (field (q Qty) (fname Str) (fty Term)))
(data DataDecl ()
  (data-decl (name Str)
             (params (List (Pair Str Term)))
             (ctors (List (Pair Str (List Field))))   ; alist; order IS the list
             (sp-params (List Bool))))                 ; E7's variance cache

(def str-member (-> (List Str) Str Bool)
  (lam (xs s) (any-list Str (lam (x) (str-eq x s)) xs)))

; coverage: ctor order minus covered, via filter (lib/collections.chiral:37-44)
(def missing-ctors (-> (List Str) (List Str) (List Str))
  (lam (order covered)
    (filter Str (lam (c) (not (str-member covered c))) order)))

; per-branch binder-usage check: walk the first k slots of the usage vector
; (cons-front layout: branch binders are at the HEAD after checking the body)
(def check-branch-uses (-> Str (List Qty) (List Field) (Res (List Qty)))
  (lam (cname ub ftys)
    (case ftys
      (nil (ok ub))                       ; rest of ub is the outer-ctx usage
      ((cons f rest)
        (case f ((field q fname fty)
          (case ub
            (nil (bad "usage vector underrun"))
            ((cons used ub2)
              (case (qfits used q)
                (true (check-branch-uses cname ub2 rest))
                (false (bad (str-cat "branch " (str-cat cname
                              (str-cat ": field binder " fname))))))))))))))
```

*Mechanical recipe.*
1. COPY: `_check_tcon`, `_check_con`, `_check_case`, `check_data` control flow,
   arm for arm, Res-threaded (rule T3); keep the narrow-hooks-before-bind order
   and the scrutinee-usage-added-once shape.
2. COPY: `_ensure_escapes` exactly (quote → `uses-below` → `shift-close` →
   re-eval); its three helpers are E13's walkers.
3. COPY: `_infer_ctor_params` — the speculative `K.infer` inside `try/except`
   (`:158–161`) becomes a plain case on `(Res ...)`: `bad` → leave unsolved.
   The exception-to-value translation is *cleaner* than the original here.
4. TRANSLATE (rule T4/T7): `ctors` dict → alist with `order` as the master
   list; `covered` set → `List Str`; `sig.ctor_home` → alist.
5. TRANSLATE (rule T2): branch-binder usage slots `ub[len(ctx)+i]` → head-side
   slots of the cons-front vector (sketch above); differential-test against
   Python on a deliberately over/under-using branch.
6. NEW (named limit, not new code): port the telescope limit as a comment +
   the env seam (`:127`); flag E48. Port the stuck-case raise as `bad` with
   the same "scaffold limit" text; flag the neutral-case extension.
7. DROP: `_occurs` (`data.py:262–285`) — dead.

**Dependencies:** E3, E4, E5; `DataDecl` shape feeds E7 (sp-params field).
Unblocks E7 and the E2 integration.

**Est. pass size:** L — slice as: (L1) DataDecl + check_data + TCon/Con checking;
(L2) case checking + coverage + `_ensure_escapes`; (L3) `_infer_ctor_params` +
differential corpus (the `(the ...)`-tax tests from the constructor-inference
increment are the oracle set).

---

## E7 — Strict positivity / variance analysis   [SELF-HOST · Tier P, verified Tier O]

**Lives now:** `scaffold/chirality/data.py`: `_positivity` `:288–385` (inner
`is_hit` `:308–311`, `mentions` `:313–336`, `sp_in` `:338–344`, `walk`
`:348–383`), `_compute_sp_params` `:388–406`, `_check_strict_positive`
`:409–414`; called from `check_data` `:435` (per-field) and `:442` (variance
cache). Design: `docs/totality.md` pillar 1; `decision-graded-kernel` Fork B.

**Verdict:** PROPER — the algorithm is clean and self-contained; the port is a
straight rewrite of one walker. The Python's mutable `reason[0]` cell and
closure-captured helpers translate to Maybe-returning recursion (a rule-governed
rewrite, stated below).

**Explainer.** One function, two modes, selected by `target`: `("name", D)`
checks a datatype's own recursive occurrences; `("var", idx)` measures a
*parameter's* variance — and `_compute_sp_params` runs the second mode per
parameter to cache `sp_params : [Bool]` on the decl, which the first mode then
consults when a recursive occurrence routes through a container (`sp_in`,
`:338–344`). The invariants: (1) an occurrence **anywhere in a Pi domain** is
refused — even doubly-negated (`:359–364` comment: "a double negative is still
refused"), because strict (not just) positivity is what forecloses the
diverging fixpoint; (2) a **bare head occurrence** is fine unless its own args
mention the target (non-uniform nesting refused, `:351–356`); (3) nesting
through a container parameter is fine ONLY if that container is strictly
positive in that parameter (`:367–373`) — this is what admits
`(cons (hd A) (tl (List A)))` and the `TCode` branches-through-`List`/`Pair`
shape (`lib/tal-ir.chiral:41–46`) while refusing routes through unknown-variance
parameters; (4) the type under definition is **assumed positive in itself**
(`sp_in`: `con == under → True`, `:340–342`) — the standard convention that
breaks self-recursion, and the reason declaration ORDER matters: a later type
can route through an earlier one's cached sp_params, never through a
not-yet-checked one (no mutual data exists, so no cross-decl cycle — if mutual
data ever lands, this cache needs a fixpoint, name that now). (5) `mentions`
tracks binder depth so `("var", idx)` hits shift under Pi/Lam/Case binders
(`:313–336`) — the de Bruijn arithmetic `t[1] == target[1] + depth` (`:311`)
must survive translation exactly. The per-param cache is the memory ledger's
"per-param variance cache, allows covariant-container recursion". CPython
conveniences: the `reason = [None]` mutable cell + early-return-via-check
(`:346–349`) — pure Python closure trickery, not algorithm; and
`getattr(d, "sp_params", None)` defensiveness (`:343`) that a typed DataDecl
makes unnecessary.

**Translation dossier.**

*Source exemplar* — the decision core, `data.py:348–376`:

```python
    def walk(t, depth):
        if reason[0] is not None:
            return
        if is_hit(t, depth):
            if t[0] == "TCon":
                for a in t[2]:
                    if mentions(a, depth):
                        reason[0] = "as a nested (non-uniform) type argument"
                        return
            return  # a bare head occurrence is strictly positive
        k = t[0]
        if k == "Pi":
            # strict positivity: no occurrence anywhere in an arrow domain, at
            # any nesting depth (a double negative is still refused), because
            # that is what forecloses the diverging fixpoint
            if mentions(t[4], depth):
                reason[0] = "to the left of a function arrow"
                return
            walk(t[5], depth + 1)   # the codomain is a positive position
        elif k == "TCon":
            for i, a in enumerate(t[2]):
                if mentions(a, depth):
                    if not sp_in(t[1], i):
                        reason[0] = f"through a non-positive parameter of {t[1]}"
                        return
                    walk(a, depth)
```

*Target sketch* (Maybe-returning walk modeled on `alist-get`'s shape,
`lib/collections.chiral:61–71`; first-Just combination via case):

```lisp
(data PTarget () (pt-name (dname Str)) (pt-var (ix I64)))

(def maybe-or (-> (0 A (type 0)) (Maybe A) (Maybe A) (Maybe A))
  (lam (A x y) (case x ((some v) (some v)) (none y))))

(declare pos-mentions (-> PTarget I64 Term Bool))
(declare pos-walk (-> Sig Str PTarget I64 Term (Maybe Str)))

; the Pi arm: refuse any mention in the domain, recurse into the codomain
((tm-pi q eff name dom cod)
  (case (pos-mentions tgt depth dom)
    (true (some "to the left of a function arrow"))
    (false (pos-walk sg under tgt (+ depth 1) cod))))

; the TCon arm: indexed walk over args consulting the sp cache
(def pos-args (-> Sig Str PTarget I64 Str I64 (List Term) (Maybe Str))
  (lam (sg under tgt depth con i args)
    (case args
      (nil (the (Maybe Str) none))
      ((cons a rest)
        (case (pos-mentions tgt depth a)
          (false (pos-args sg under tgt depth con (+ i 1) rest))
          (true
            (case (sp-in sg under con i)
              (false (some (str-cat "through a non-positive parameter of " con)))
              (true (maybe-or Str (pos-walk sg under tgt depth a)
                                  (pos-args sg under tgt depth con (+ i 1) rest))))))))))

; variance cache: one Bool per parameter, fold over ctors' fields
; (map/fold shapes: lib/collections.chiral:31-50); parameter p sits at
; de Bruijn index (nparams - 1 - p) -- COPY the arithmetic verbatim
```

*Mechanical recipe.*
1. COPY: `is_hit`/`mentions` (`:308–336`) as two Bool-returning defs; the
   binder-depth increments per arm are the whole content — verify with the
   Python oracle on `(data Bad () (mk (f (=> Bad X))))` (must refuse) and
   `List`/`Pair`/`TCode` (must accept, with `sp_params = [true, ...]`).
2. TRANSLATE (rule T8, stated): the `reason[0]` cell + early returns → a
   `(Maybe Str)`-returning walk where `some` short-circuits via `maybe-or`
   and arm-level case; first-reason-wins order is preserved by evaluation
   order of the case ladder.
3. COPY: `_compute_sp_params` (`:388–406`) — per-param loop over all ctor
   fields, `idx = nparams - 1 - p` verbatim; result stored in the DataDecl's
   `sp-params` field (E6's data shape already carries it).
4. COPY: `sp_in` with the `con == under → true` convention and its comment.
5. NEW (flag only): if mutual data ever lands (it does not exist today), the
   sp cache needs a fixpoint iteration — record in the port header.
6. DROP: nothing here (the dead `_occurs` is E6's droppage; positivity never
   used it).

**Dependencies:** the Term data (E3 step 1) and E6's DataDecl; runs inside
`check_data`, so it lands with or immediately after E6 L1. Unblocks: nothing
downstream waits on it except totality claims (E11's pillar 1, family 2).

**Est. pass size:** M.

---

# Family footer

## Redo list (ranked by downstream poison)

1. **Exceptions-as-control-flow, family-wide** (`KernelError`/`SurfaceError`/
   `ReadError` raised ~60 places; caught for backtracking at `data.py:158–161`,
   `data.py:87–90`; for rollback at `kernel.py:552`, `surface.py:102–106`,
   `data.py:443`). Not a Python bug — but the port MUST decide the `Res` type
   and its threading discipline before ANY element ports, or every pass gets
   rewritten when the discipline lands. chirality has no early-exit sugar (`do` is
   Unit-effect/linear sequencing, `surface.py:431–451`, not a Maybe/Res bind),
   so the checker port is case-ladder-heavy by construction. Poisons: all of
   E1–E14.
2. **Stuck type-level case** (`data.py:54`) — `case` on a neutral scrutinee
   raises; blocks dependent-type idioms the self-hosted checker itself may
   want (type-level functions defined by case). Port carries the limit; the
   fix (neutral `VCase` + conv/quote arms) is extension work touching E3+E6.
3. **Telescope limit** (`data.py:127,134` — fields cannot depend on earlier
   fields) = **E48**. Port preserves it; the env-threading seam must stay
   visible in the ported `_ctor_field_types` so E48 lands as an extension,
   not a rewrite.
4. **Mutable Sig + value cache** (`kernel.py:117,152–165` and every installer).
   Decide threaded-Sig + install-time value evaluation before E3; retrofitting
   functional state into a half-ported kernel is the expensive path.
5. **Reader literal policy** (`sexp.py:93`) — bignum `int()` with underscore
   acceptance; define I64-range + digits-only at read time (small, but it is a
   floor-agreement question: the reference reader and the self-hosted reader
   must accept the same literals).
6. **Dead code**: `data.py:262–285` `_occurs` — never called; do not port.

## Ordering (dependency-respecting passes)

1. **P0 — term-rep mini-pass** (NEW, shared): `Qty`/`Term`/`NeHead`/`Value`/
   `Res`/`Ctx`/`DataDecl` data decls + `list-nth`/`str-member`/`maybe-or`/zip-
   style helpers into `lib/collections.chiral`-adjacent source. Coordinate with
   family 2 (E13 owns `uses_below`/`shift_close` over the same `Term`).
2. **E5** — semiring + usage vectors (S; also the workflow shakedown).
3. **E1** — reader (S; independent, parallelizable with E5).
4. **E3** — eval/vapp/conv/quote (M).
5. **E4** — infer/check/subtype + toplevel ops (L, 3 slices).
6. **E6** — data module (L, 3 slices; L1 can start once E4-L1 lands).
7. **E7** — positivity/variance (M; with or right after E6-L1).
8. **E2** — elaborator + verify (M; the integration pass, needs everything).

Throughout: differential verification against the Python checker as the Tier-O
oracle (run both on `scaffold/lib/*.chiral` + `scaffold/demo/*.chiral` +
`tests/` accept/reject fixtures; compare verdicts and quoted normal forms).

## Cross-family flags

- **E13 coordination (family 2):** the `Term` data declaration is shared
  substrate — P0 above should be co-owned; `uses_below`/`shift_close` are
  consumed here at `kernel.py:424`, `data.py:255–257`.
- **E8 (family 2):** `_linear_data` keys its `seen` set on
  `repr(tyv[2])` (`data.py:72`) — structural-equality-via-repr-string is a
  CPython crutch with no chirality equivalent; the port needs a Value
  structural-equality (quote + Term equality) or a depth-bound-only walk.
  Flagged here because the DataDecl/Value shapes P0 fixes determine the answer.
- **E12 (family 2):** `sig.rules` (consulted at `kernel.py:410,420,432,469,477`)
  and the hook lists (`check/narrow/subtype/conv/quote/linear/def_hooks`)
  are the kernel-seam pattern (dossier-spec pattern 1). In a self-hosted
  checker with a CLOSED `Term`/`Value` data type, dict-keyed handler dispatch
  collapses into case arms and hook lists become either (a) explicit
  `(List (-> ...))` closure lists (first-class functions exist —
  `lib/collections.chiral:31–56`) or (b) compile-time module boundaries with
  direct calls. **No catalog element owns this decision; candidate E51:
  "seam representation in the self-hosted kernel."** The refinement VALUE form
  joining the closed `Value` type (E9/E10, family 2) is the concrete forcing
  case.
- **E28–E33 (family 4):** `(import ...)` needs a file-open sys slice
  (`openat`) plus read-to-Bytes; `lib/sys-tal.chiral` has none today. Without
  it the self-hosted elaborator can only check pre-fed source.
- **E11/E47/E50 (family 2/VI):** the ported checker itself will NOT prove
  total under the current pillars — `eval-term`/`vapp`, `infer`/`check`,
  `emit`-style mutual defs are forward-declared mutual recursion
  (`data.py:666–669` explicitly refuses), and descent is on `Term` under
  closures, invisible to the structural rule. The self-hosted checker lands in
  the classified-not-proven column of its own ledger; honest, but it means the
  `(total)` profile gate cannot include the checker until E50 (mutual/
  lexicographic) or E47 (sized types) lands.
- **E15 (family 3):** deep NON-tail recursion in `conv`/`eval`/`_positivity`
  runs on the upper interpreter during bootstrap (`runtime.py` has TCO for
  tail calls only) — checker recursion depth on large terms is bounded by the
  host Python stack twice over (interpreter recursion × checked-term depth).
  Worth a stress fixture before the bootstrap flips.
- **Candidate E51+:** `Res`/Either type + a bind/short-circuit discipline
  (surface sugar or library idiom) — used by every SELF-HOST element; today it
  exists nowhere in `lib/`. Also `list-nth` and zip-style two-list helpers for
  `lib/collections.chiral`.
- **E49 (real surface):** the case-ladder tax the `Res` discipline imposes is
  a concrete input to the stage-4 surface design (a `let-ok`/monadic-bind
  form would delete ~40% of the ported checker's line count).
