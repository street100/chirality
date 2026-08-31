# Family 2 — The checker stack, part 2 of 2 (E8–E14)

**Elements:** E8 linear-kind decision for data · E9 refinement decision procedure ·
E10 path-sensitivity / occurrence typing · E11 totality (structural + numeric-measure
termination) · E12 effect membrane rules · E13 de Bruijn machinery · E14 pretty-printer.

**State of the family.** This half of the checker stack is in unusually good shape as
*port source*: every element is implemented, tested, and documented, and none is a
scaffold-shortcut needing a wholesale REDO. The algorithms are almost entirely pure
functions over tuples — the exact shape `lib/tal-ir.chiral` + `lib/emit-core.chiral`
already proved portable. What stands between "Python that works" and "chirality that is
the checker" is a small, nameable set of CPython conveniences: exceptions as control
flow (every element), frozensets and dict-keyed maps (E9, E10, E11), a `repr()`-keyed
memo set (E8), and Python's unbounded integers silently absorbing `k±1` at the I64
extremes (E9, E11 — the one place a naive port would be *unsound*, not just broken).
Each has a mechanical translation rule, given below. The family's one genuine layout
question — E10's guard tracking living in three modules — resolves to a deliberate
consolidation at port time (a shared guard-facts module), not a redo of the Python.
All sketches below consume family 1's deliverable: the `Term`/`Value`/`Ctx`/`Sig`
data declarations (E3–E5). Nothing here can land before those.

Conventions used in the sketches: `Term` is the closed chirality datatype mirroring the
kernel's term tuples (family 1, modeled on how `lib/tal-ir.chiral:19-49` mirrors
`tal.py`); `t-var`, `t-app`, `t-pi`, `t-lam`, `t-let`, `t-case`, `t-con`, `t-refine`,
`t-lit-i64`, `t-global`, `t-prim`, `t-ann` name its constructors. Every construct in
every sketch is cited to an existing `.chiral` file.

---

## E8 — Linear-kind decision for data (`_linear_data`)   [SELF-HOST · Tier P]

**Lives now:**
- `scaffold/chirality/data.py:66` — `_LINEAR_ABSTRACT_DEPTH = 64` (the non-uniform-nesting bound)
- `scaffold/chirality/data.py:69-91` — `_linear_data(sig, tyv, seen)` (the walk)
- `scaffold/chirality/data.py:30` — registration: `sig.linear_hooks.append(_linear_data)`
- `scaffold/chirality/kernel.py:205-215` — `is_linear` (the seam that calls it; atoms + `linear_data` set handled kernel-side)
- Consumers that make it matter: `effects.py:32-38` (`on_binder`), `data.py:127-135`
  (`_ctor_field_types`, instantiation-time), `data.py:436-441` (`check_data`, declaration-time)
- Tests: `scaffold/tests/test_kernel.py:123-138` (non-uniform nesting), `:240-260`
  (pair smuggle, wrapper at 1 ok / at w rejected)

**Verdict:** EXTEND — the algorithm (co-inductive walk with cycle-break and depth
bound, defer-to-instantiation on anything undecidable) is sound and stays; two
CPython crutches must be replaced in the port: the `repr()`-keyed seen set and the
swallowed exception on un-evaluable field types.

**Explainer.** The judgment "is this type a linear kind" must be *never falsely
negative for a type that actually holds a port* — a false "not linear" would let a
socket bind at `w` and alias. The walk achieves this with three moves. (1) A field
declared `q == 1` makes the data linear outright (`data.py:84-85`). (2) A field whose
evaluated type is linear (recursively) makes it linear (`data.py:87-88`). (3) All
three escape hatches — cycle-break on a repeated `(name, args)` key, the depth-64
bound for non-uniform recursive types whose key never repeats, and an un-evaluable
field type — answer "not linear *here*", which is safe only because the same check
re-fires at every concrete instantiation (`_ctor_field_types`, `on_binder`), where a
real port is met at shallow depth. That invariant — *deferral is sound because
instantiation re-judges* — is the thing a port must preserve; it is stated in the
comment at `data.py:59-65` and must survive translation verbatim. The two crutches:
the seen key is `(tyv[1], repr(tyv[2]))` (`data.py:72`) — `repr` of a Python value
list as a hashable proxy for structural equality; and the `try/except KernelError:
pass` at `data.py:86-90` uses exception-swallowing where the port needs an eval that
can *decline* (see the family-wide Result flag). Note also the walk consults the
declaration's field *quantity* before its type, so a `(1 f T)` field decides without
evaluating `T` — keep that ordering; it is what lets porttype wrappers with abstract
fields judge cheaply.

**Translation dossier.**

*Source exemplar* — `scaffold/chirality/data.py:69-91`:

```python
def _linear_data(sig, tyv, seen):
    if tyv[0] != "VTCon":
        return False
    key = (tyv[1], repr(tyv[2]))
    if key in seen:
        return False
    if len(seen) >= _LINEAR_ABSTRACT_DEPTH:
        return False   # non-uniform nesting: defer to the instantiation check
    seen.add(key)
    decl = sig.data.get(tyv[1])
    if decl is None:
        return False
    env = list(tyv[2])
    for cname, fields in decl.ctors.items():
        for (q, fname, fty) in fields:
            if q == 1:
                return True
            try:
                if K.is_linear(sig, K.eval_term(sig, env, fty), seen):
                    return True
            except KernelError:
                pass  # un-evaluable field type: judged at instantiation
    return False
```

*Target sketch* (constructs cited per line; `Value`, `Sig`, `sig-data-get`,
`val-eq`, `eval-term-opt` are family-1 / shared-lib deliverables — see cross-family
flags):

```
; seen is a threaded list of (dname, arg-values) keys; depth rides as its length.
; data decl with typed fields: modeled on lib/tal-ir.chiral:41-46
(data LinKey () (lin-key (dname Str) (args (List Value))))

(def lin-key-eq (-> LinKey LinKey Bool)
  (lam (a b)
    (case a ((lin-key n1 a1)                       ; nested ctor case: lib/emit-core.chiral:63-67
      (case b ((lin-key n2 a2)
        (and (str-eq n1 n2) (val-list-eq a1 a2)))))))) ; and: lib/prelude.chiral:62-63

(def lin-data (-> Sig Value (List LinKey) Bool)
  (lam (sig tyv seen)
    (case tyv
      ((v-tcon dname args)
        (case (or (any-list LinKey (lam (k) (lin-key-eq k (lin-key dname args))) seen)
                  (<=i 64 (length LinKey seen)))   ; any-list: lib/collections.chiral:52-56
          (true false)                             ; cycle or depth: defer to instantiation
          (false
            (case (sig-data-get sig dname)         ; alist lookup: lib/collections.chiral:61-71
              (none false)
              ((some decl)
                (lin-fields sig args (cons (lin-key dname args) seen)
                            (decl-all-fields decl)))))))
      (_ false))))                                 ; default branch: demo/sprites.chiral:49

(def lin-fields (-> Sig (List Value) (List LinKey) (List Field) Bool)
  (lam (sig env seen fs)
    (case fs
      (nil false)
      ((cons f rest)                               ; structural recursion: lib/collections.chiral:9-13
        (case f ((field q fname fty)
          (case (=i q 1)
            (true true)
            (false
              (case (eval-term-opt sig env fty)    ; Maybe-returning eval replaces try/except
                (none (lin-fields sig env seen rest))   ; un-evaluable: judged at instantiation
                ((some ftyv)
                  (case (is-linear sig ftyv seen)
                    (true true)
                    (false (lin-fields sig env seen rest)))))))))))))
```

*Mechanical recipe:*
1. COPY — the decision structure (VTCon-only, cycle-break, depth 64, q==1 first,
   recurse on evaluated field type, defer on failure) verbatim; the comment block
   `data.py:59-65` should be carried over as the file comment.
2. TRANSLATE — mutable `seen` set → threaded `(List LinKey)` parameter (rule:
   closure/argument mutation → threaded parameter; proven by `rev-onto`,
   `lib/collections.chiral:22-25`). `repr()` key → structural `lin-key-eq` over
   values (rule: hashable-proxy key → explicit structural equality). Dict
   `sig.data.get` → alist lookup (`lib/collections.chiral:61-71`). Nested `for` with
   early `return True` → recursion returning `Bool` with `true` short-circuit (as in
   `any-list`).
3. NEW — `val-eq`/`val-list-eq` (structural equality on values; cheapest sound form:
   quote both and compare terms) and `eval-term-opt` (a `(Maybe Value)`-returning
   eval). Both are *shared* NEW utilities every family-2 element wants — flagged
   cross-family, should be built once in family 1's pass, not here.

**Dependencies:** family 1's `Value`/`Sig` decls and `is_linear` seam (E3–E5); the
shared `val-eq` + `eval-term-opt` utilities; E6 (data-decl representation) for
`decl-all-fields`. Unblocks: the whole port discipline in the self-hosted checker.

**Est. pass size:** S (once `val-eq`/`eval-term-opt` exist; without them, don't start).

---

## E9 — Refinement decision procedure: interval-with-holes + symbolic bounds, `entails`   [SELF-HOST · Tier P, verification Tier O]

**Lives now:**
- `scaffold/chirality/refine.py:61` — `TOP = (None, None, frozenset(), frozenset())`
- `refine.py:64-91` — `_atom` / `_sym_atom` / `build` (constraint construction)
- `refine.py:94-119` — `satisfies` / `is_empty`
- `refine.py:122-141` — `entails` (the decision procedure proper)
- `refine.py:144-153` — `_const_atoms` (constraint → atoms, for quote)
- `refine.py:158-197` — `_eval_refine` / `_check_refine` (the Refine term former)
- `refine.py:202-249` — the four value hooks: `_check_against`, `_subtype`, `_conv`, `_quote`
- `refine.py:43-50` — `install` (the seam wiring: `ext_check`/`ext_eval` +
  check/subtype/conv/quote/narrow hooks)
- `scaffold/chirality/terms.py:18` — `Refine` in `EXT_TERMS`; `terms.py:48-50, 79-81` —
  walkers traverse Refine operands
- Tests: `scaffold/tests/test_refine.py:38-74` (constraint algebra directly),
  `:77-119` (checker + subtyping + well-formedness), `:171-212` (symbolic slice)

**Verdict:** PROPER — the fragment (I64, conjunction of constant/bare-variable
atoms) is the settled design (recorded pending author ratification,
`refine.py:13-29`), the constant part is sound *and* complete, the symbolic part is
sound-by-syntactic-subset, and the code is already pure functions over tuples. The
pass is a straight port — with two soundness-critical port traps that must be
handled at construction time (below), and one representation decision (canonical
lists for the two frozensets).

**Explainer.** A constraint is `(lo, hi, excluded, sym)`. Three invariants carry all
the soundness. (1) **entails = interval containment + hole coverage + sym subset**
(`refine.py:122-141`): every value satisfying c1 must satisfy c2, checked as lo/hi
containment, then every c2-hole either outside c1's range or in c1's holes, then
`sym2 <= sym1` — *syntactic* subset by (op, level), deliberately no arithmetic
between variables. (2) **Vacuous entailment via `is_empty`** (`refine.py:105-119`,
tested at `test_refine.py:62-74`): an uninhabited c1 entails everything; without
this check the procedure is incomplete and rejects valid subtypings. The punch-out
walk is guarded by `hi - lo + 1 <= len(ex)` so it never walks a huge span. (3)
**Symbolic bounds collapse to constants at instantiation** (`refine.py:158-173` +
`kernel.py:415-428`): a bound is stored by de Bruijn *level* (absolute, stable under
NbE); when the enclosing Pi is applied to a literal, the kernel evaluates the
argument *because the codomain is dependent* (`uses_below(fty[5][1], 1)` at
`kernel.py:424` — which is true only because `terms.py:48-50` makes `uses_below`
traverse Refine operands), and re-evaluating the Refine term folds `< n` into `< 5`.
Break any link in that chain — level-keying, operand traversal in the walkers, or
re-evaluation on application — and subtyping at instantiation is silently unsound
(tested at `test_refine.py:204-207`). Also load-bearing: `satisfies` returns `False`
whenever `sym` is non-empty (`refine.py:96-97`) — a literal can never discharge a
symbolic bound; and `_subtype` allows base `<:` refinement only when the constraint
is `TOP` (`refine.py:230-231`).

**The port traps (unbounded-int reliance).** Python integers absorb `k ± 1` at the
I64 extremes; chirality I64 wraps (settled, `docs/decision-division-euclidean` per the
floor agreement). Concretely: `_atom(c, ">", MAX)` sets `lo = MAX + 1` — in Python a
value no i64 reaches (constraint correctly uninhabited); in wrapping I64 it becomes
`MIN`, turning `{v > MAX}` into `TOP` — **an unsound acceptance**. Symmetrically
`"<" MIN` → `hi = MAX` = TOP. And `is_empty`'s span guard `hi - lo + 1` wraps for
huge ranges, spuriously enabling the punch-out walk. The port must normalize at
construction: `> MAX` and `< MIN` produce the canonical empty constraint
(`lo=some 1, hi=some 0` works); and the punch-out check must be reformulated
span-arithmetic-free (walk upward from `lo` through members of `ex`, stopping after
at most `length ex` steps or on passing `hi` — bounded by `|ex|+1` iterations, no
subtraction). These are NEW lines, small, and they are the *only* NEW logic in the
element.

**Translation dossier.**

*Source exemplar* — `scaffold/chirality/refine.py:122-141`:

```python
def entails(c1, c2):
    """Does every value satisfying c1 satisfy c2? (c1 is at least as strong.)"""
    if is_empty(c1):
        return True   # nothing satisfies c1, so it entails every c2 vacuously
    lo1, hi1, ex1, sym1 = c1
    lo2, hi2, ex2, sym2 = c2
    if lo2 is not None and (lo1 is None or lo1 < lo2):
        return False
    if hi2 is not None and (hi1 is None or hi1 > hi2):
        return False
    # every value c2 forbids, c1 must also forbid (or place outside its range)
    for x in ex2:
        outside = (lo1 is not None and x < lo1) or (hi1 is not None and x > hi1)
        if not outside and x not in ex1:
            return False
    # every symbolic bound c2 demands, c1 must also carry (syntactic, by level --
    # same variable; sound but incomplete, no arithmetic between variables)
    if not sym2 <= sym1:
        return False
    return True
```

*Target sketch:*

```
; constraint: constant interval-with-holes + symbolic (op, level) bounds.
; data w/ Maybe/List/Pair fields: lib/tal-ir.chiral:41-46. ex and sym are kept
; SORTED and DEDUPED at insertion so structural equality is order-insensitive
; (replaces frozenset equality in _conv, refine.py:239).
(data Cn ()
  (cn (lo (Maybe I64)) (hi (Maybe I64))
      (ex (List I64))
      (sym (List (Pair Str I64)))))

(def lo-covers (-> (Maybe I64) (Maybe I64) Bool)    ; c2's lo demand met by c1's lo
  (lam (l1 l2)
    (case l2
      (none true)
      ((some k2) (case l1 (none false) ((some k1) (<=i k2 k1)))))))

(def hole-covered (-> (Maybe I64) (Maybe I64) (List I64) I64 Bool)
  (lam (lo1 hi1 ex1 x)
    (or (case lo1 (none false) ((some l) (<i x l)))     ; or: lib/prelude.chiral:65-66
    (or (case hi1 (none false) ((some h) (<i h x)))
        (any-list I64 (lam (e) (=i e x)) ex1)))))       ; any-list: lib/collections.chiral:52-56

(def cn-entails (-> Cn Cn Bool)
  (lam (c1 c2)
    (case (cn-empty c1)
      (true true)                                        ; vacuous entailment
      (false
        (case c1 ((cn lo1 hi1 ex1 sym1)                  ; nested case: lib/emit-core.chiral:63-67
          (case c2 ((cn lo2 hi2 ex2 sym2)
            (and (lo-covers lo1 lo2)
            (and (hi-covers hi1 hi2)
            (and (all-list I64 (lam (x) (hole-covered lo1 hi1 ex1 x)) ex2)
                 (sym-subset sym2 sym1))))))))))))       ; syntactic subset, by (op, level)
```

The value form `VRefine` becomes a constructor of family 1's `Value`; the four hooks
become branches in the checker's `check-against`/`subtype`/`conv`/`quote` (see
cross-family flag on seam shape). The surface already exists —
`(refine I64 (>= 0) (< n))` at `lib/mem-linear.chiral:27` is the exemplar for the
term former.

*Mechanical recipe:*
1. COPY — the atom set (`>=`, `>`, `<=`, `<`, `<>` — `refine.py:40`), the entailment
   logic, the vacuous-entailment order (empty check FIRST), the `satisfies`-refuses-
   symbolic rule, `_subtype`'s three cases (refine/refine → conv base + entails;
   refine → base forget; base → refine only if TOP), `_conv`'s exact-equality rule,
   the collapse mechanism's comments (`refine.py:22-29, 55-60`).
2. TRANSLATE — `None` bounds → `(Maybe I64)` (`lib/tal-ir.chiral:46`); frozensets →
   sorted deduped lists with `sorted-insert` (NEW helper, see flags) so structural
   equality replaces set equality; `min`/`max` on bounds → `lib/prelude.chiral:72-76`;
   op-string dispatch → `str-eq` chain (`demo/sprites.chiral:16-22`); early-return
   `for` loops → `any-list`/`all-list` (`all-list` is a trivial NEW twin of
   `any-list`).
3. NEW — (a) extreme-bound normalization in `cn-atom`: `>` at `9223372036854775807`
   and `<` at `-9223372036854775808` yield the canonical empty constraint (literals
   of this size appear in chirality source already: `tests/test_kernel.py:563`); (b) the
   span-arithmetic-free punch-out walk in `cn-empty` (≤ `|ex|+1` iterations — which
   the totality checker can prove via the structural descent on `ex`); (c)
   `sorted-insert`, `all-list`, `sym-subset` list helpers. All small; the element is
   pass-ready.

**Dependencies:** family 1's `Value`/`Term`/eval/quote/check (E3, E4); E13 walkers
(Refine-operand traversal is load-bearing). Unblocks E10 (narrowing produces these
constraints) and the typed pool-offset story (`mem-put-checked`). Verification is
Tier O: emit the constraint corpus in SMT-LIB and differential-test `cn-entails` /
`cn-empty` against Z3/CVC5 — never read the solver (policy §Tier O).

**Est. pass size:** M (constraint algebra + term former + four hook branches; the
algebra alone is S and independently testable — do it first).

---

## E10 — Path-sensitivity / occurrence typing   [SELF-HOST · Tier P]

**Lives now** (deliberately spread across three modules — see explainer):
- `scaffold/chirality/refine.py:258-333` — the refinement slice: `_LEARN` table
  (`:272-279`), `_unann` (`:282-285`), `_operand` (`:288-294`), `_narrow` (`:297-333`)
- `scaffold/chirality/kernel.py:138-140` — `sig.narrow_hooks` seam declaration
- `scaffold/chirality/kernel.py:189-200` — `Ctx.narrow` (retype-in-place, env untouched)
- `scaffold/chirality/data.py:216-221` — the hook's one call site, in `_check_case`
- `scaffold/chirality/data.py:540-582` — `_guard_bound`: the *totality checker's own*
  guard-fact extraction (kept local so E11 does not depend on the refine module,
  comment at `data.py:544-545`)
- Tests: `scaffold/tests/test_refine.py:122-168` (`TestPathSensitivity`),
  `:171-212` (`TestSymbolicRefinement`)

**Verdict:** EXTEND — the mechanism is sound and the seam placement is right; two
named extensions for the port: (1) consolidate the twice-written guard-fact
extraction into one shared module (the layout question, answered below), (2) the
named incompleteness that narrowing fires only on a *directly-scrutinized* primitive
comparison — no let-bound guards, no `and`/`or`/`not` composition of guards, and the
branch names `true`/`false` are hardcoded to the prelude's `Bool` constructors.

**Explainer.** When a `case` scrutinee is `(Prim <i|<=i|=i)` applied to two operands,
each branch *proves* a bound on any variable operand; `_narrow` computes the learned
atoms from the `_LEARN` table (keyed by op × which-side × which-branch,
`refine.py:272-279`), folds them into the variable's existing constraint (TOP if it
was bare I64), and returns a narrowed context. The soundness argument lives in
`Ctx.narrow`'s docstring (`kernel.py:191-195`) and must be preserved word-for-word:
the *value* is unchanged — `c.env = self.env` — only the ascribed type shrinks,
along a path where the guard proves the tighter type holds. Narrowing re-types by
*level* (`len(ctx) - 1 - var[1]`, `refine.py:331`), and a symbolic bound records the
other operand's level (`refine.py:330`) — both index→level conversions are exactly
where an off-by-one would silently mis-narrow a *different* variable, so the port
should test the false-branch negation cases first (`test_refine.py:150-155` is the
regression that catches sign errors in `_LEARN`). **The layout question:** the
guard-fact extraction is written twice — `refine.py:272-333` (learning refinement
constraints) and `data.py:540-582` (learning `(lo, hi, lt, gt)` bounds for the
termination measure) — with the same spine-unwind, the same op set, the same
true/false split, different fact vocabularies. The duplication is *principled* in
Python (the totality check must not import the refinement module; module
independence), but it is one algorithm, and porting it twice invites divergence.
Verdict on layout: consolidate at port time into one pure `guard-facts` chirality module
(a comparison scrutinee + branch name → list of per-variable facts), imported by
both the refine and totality modules — a pure library import creates no seam
coupling; the Python concern (installing refine changes totality behavior) does not
apply to importing a pure function. Both consumers then project the shared facts
into their own domains.

**Translation dossier.**

*Source exemplar* — `scaffold/chirality/refine.py:297-333` (core):

```python
def _narrow(sig, ctx, scrut, cname):
    if cname not in ("true", "false"):
        return None
    # unwind the comparison application: (Prim op) applied to two operands
    t, args = scrut, []
    while t[0] == "App":
        args.append(t[2]); t = t[1]
    args.reverse()
    if t[0] != "Prim" or t[1] not in ("<i", "<=i", "=i") or len(args) != 2:
        return None
    op, is_true = t[1], cname == "true"
    k0, k1 = _operand(_unann(args[0])), _operand(_unann(args[1]))
    if k0 is None or k1 is None:
        return None
    nctx, changed = ctx, False
    for me, other, var_left in ((k0, k1, True), (k1, k0, False)):
        ...
        for group in _LEARN[(op, var_left, is_true)]:
            for o in group:
                if other[0] == "const":
                    c = _atom(c, o, other[1])
                else:
                    c = _sym_atom(c, o, len(ctx) - 1 - other[1][1])
        nctx = nctx.narrow(len(ctx) - 1 - var[1], ("VRefine", _I64, c))
        changed = True
    return nctx if changed else None
```

*Target sketch* (the consolidated shared module plus the refine-side projection):

```
; --- guard-facts: ONE extraction, two consumers (refine narrowing, totality bounds)
(data Operand () (op-const (k I64)) (op-var (ix I64)) (op-other))

(data GFact ()                       ; what a guarded branch proves about one variable
  (gf (level I64) (op Str) (bound Operand)))   ; bound: a constant or the other var's level

(def guard-operand (-> Term Operand)
  (lam (t)
    (case t
      ((t-lit-i64 k) (op-const k))
      ((t-var i) (op-var i))
      ((t-ann inner ty) (guard-operand inner))   ; unann: skip the annotation
      (_ op-other))))                            ; default: demo/sprites.chiral:49

(declare guard-facts (-> Term Str I64 (List GFact)))   ; declare: lib/emit-core.chiral:56
; (spine unwind + the _LEARN dispatch as a case over (op, var-left, is-true);
;  the Python dict _LEARN, refine.py:272-279, becomes an 12-arm case — rule:
;  tuple-keyed dict -> case dispatch, as cpx does chars, demo/sprites.chiral:16-22)

; --- refine-side consumer: project facts into a narrowed Ctx
(def narrow-hook (-> Sig Ctx Term Str (Maybe Ctx))
  (lam (sig ctx scrut cname)
    (fold-narrow sig ctx (guard-facts scrut cname (ctx-len ctx)))))
    ; folding facts into ctx-narrow: accumulator threading, lib/collections.chiral:46-50
```

`Ctx.narrow` itself is family 1's `Ctx` territory: with `Ctx` as a list of entries,
narrow = rebuild the list with one entry's type replaced (a `list-set-at` helper —
NEW, trivial, flagged) while the env list is *shared untouched* — in chirality's
immutable lists that sharing is automatic, which makes the soundness invariant
(value unchanged) structural rather than by-discipline. That is a small *win* over
the Python.

*Mechanical recipe:*
1. COPY — the `_LEARN` truth table contents exactly (all twelve entries, including
   equality's two-atom `>=`+`<=` group and false-equality's `<>` hole); the
   true/false-only gate; the both-operands loop (a var-vs-var guard narrows *both*
   sides symbolically).
2. TRANSLATE — dict-keyed `_LEARN` → case dispatch (rule above); spine unwind →
   recursive `term-spine` returning `(Pair Term (List Term))` (same shape as
   `data.py:729-736`, shared with E11); mutable `nctx, changed` → fold with `(Maybe
   Ctx)` accumulator; index↔level conversions kept as explicit `(- (- n 1) ix)`
   expressions with the regression tests ported first.
3. NEW — the consolidation itself (the `guard-facts` module boundary — a design
   move, small code); `list-set-at` for `Ctx.narrow`. If the author prefers keeping
   the two extractions separate (matching the Python layout), the recipe degrades
   gracefully: port `_narrow` here and `_guard_bound` in E11, accepting the
   duplication — but say so in the pass plan, don't drift into it.

**Dependencies:** E9 (constraints), family 1's `Ctx` (E4) with `list-set-at`; E6
(`_check_case` is the only call site — the hook loop at `data.py:216-221` ports as
part of E6's case checker). Unblocks E11's symbolic measure (shared `guard-facts`)
and keeps `mem-put-checked` callers checkable.

**Est. pass size:** S (given E9; the `_LEARN` table is the bulk and it is a copy).

---

## E11 — Totality: structural + numeric-measure termination   [SELF-HOST · Tier P, verification Tier O]

**Lives now:**
- `scaffold/chirality/data.py:477-494` — `_NotStructural`, `check_termination` (the
  `def_hooks` entry; classify-then-gate via `sig.require_total`)
- `data.py:497-532` — `_I64_MAX`/`_I64_MIN`, `_lit_i64`, `_num_delta` (constant-step
  recognition)
- `data.py:537-582` — `_NOBOUND`, `_guard_bound` (guard-fact extraction for bounds —
  shared with E10's consolidation)
- `data.py:585-600` — `_meet`, `_passes_unchanged`
- `data.py:603-726` — `_totality_reason` (the walk: size tokens, bounds, calls)
- `data.py:729-736` — `_term_spine`
- `scaffold/chirality/kernel.py:127-133` — `def_hooks` / `totality` / `require_total`
  seam; `kernel.py:540-554` — `finish_def` runs the hooks post-check
- Docs: `docs/totality.md` (the criterion, the wraparound argument, the promotion
  path); profile gate wired via `surface.py verify_profiles` + `demo/verify-total.chiral`
- Tests: `scaffold/tests/test_kernel.py:516-621` (`TestTermination` — including the
  vacuous-extreme-bound and symbolic-bound-must-stay-fixed negatives), `:624-653`
  (`TestTotalityProfile`)

**Verdict:** PROPER — a sound, deliberately incomplete classifier whose named gaps
(lexicographic/mutual/size-change: E50; sized types: E47) are *separate catalog
elements*, not defects here. The pass is a straight port. The soundness-critical
invariants are the densest in the family and are listed below; they must survive
translation exactly, and the negative tests must be ported *first*.

**Explainer.** The criterion: a self-recursive def is proven total iff some fixed
argument position decreases in *every* self-call (`set.intersection(*calls)`,
`data.py:721-722`) by a measure the walk can see. Three measures: **structural** — a
case-bound field carries its scrutinee's size root with `smaller=True`
(`data.py:674-679`), so nested matches keep descending; **constant-bounded numeric**
— a `±k` step of a parameter toward a constant bound the guards on the path
establish; **symbolic** — a `±1` step against a strict var-vs-var bound whose bound
variable is passed *unchanged*. The soundness invariants a port must preserve:

1. **The wraparound exclusion** (`data.py:641-644`, `docs/totality.md:72-76`): an
   increment `d > 0` proves only when `hi <= MAX - d` (decrement dually) — without
   it, `i <= MAX` then `(+ i 1)` "proves" a loop that wraps `MAX → MIN` and never
   stops. Two's-complement I64 is settled; this guard is what makes the measure sound
   over it. Pinned by `test_kernel.py:558-564`. Note `MAX - d` cannot itself wrap
   (`d ≥ 1`), so the check ports as plain wrapping arithmetic — but the *bound
   construction* in `_guard_bound`'s `const_of` computes `k ± 1` (`data.py:560-567`),
   which hits the same unbounded-int trap as E9: normalize `k±1` at the extremes
   (drop the fact rather than wrap it).
2. **The symbolic measure's two side conditions** (`data.py:645-650`,
   `docs/totality.md:78-86`): step exactly `±1` (a larger step could overflow past a
   near-MAX bound) and the bound variable passed unchanged (`_passes_unchanged`,
   `data.py:593-600` — position L must receive the very variable at level L). Pinned
   by `test_kernel.py:609-621`.
3. **The two named unanalyzable shapes** raise early: self-used-as-value
   (`data.py:662-665`) and forward-reference/mutual (`data.py:666-669`) — the check
   distinguishes them via `name in sig.global_types and name not in sig.global_defs`,
   which works *only because* `finish_def` runs the hook before installing the def
   (`kernel.py:545-554`). That ordering is part of the element's contract.
4. **Bounds only accumulate under guards on the path** (`data.py:680-684` copies the
   bound map per branch); size tokens survive plain `let` rebinding only
   (`data.py:699-706`); `Ann` walks the term, skips the type (`data.py:709-711`) —
   sound for *runtime* termination because annotations never run; type-level
   divergence remains the accepted scaffold limit (`scaffold/AUDIT.md` accepted
   limits).
5. **Classify, don't enforce** (`data.py:490-494`, `docs/totality.md:104-119`): the
   verdict lands in `sig.totality[name]` (None = proven); `require_total` and the
   profile `(total)` clause are the two gates. The port keeps the classify-then-gate
   shape (dossier-spec proven-pattern 5).

CPython conveniences: `calls` accumulated by closure mutation; `size`/`bounds` as
dicts keyed by level; frozenset `lt`/`gt`; `_NotStructural` exception for early
abort. All have proven translation rules (below). Verification is Tier O: the
accept/reject corpus in `TestTermination` ports directly, and Agda/Idris2 serve as
what-ought-to-terminate oracles for new cases.

**Translation dossier.**

*Source exemplar* — `scaffold/chirality/data.py:637-650` (the numeric-measure heart):

```python
                    nd = _num_delta(a, depth, nparams)
                    if nd is not None and nd[0] == j and nd[1] != 0:
                        lo, hi, lt, gt = bounds.get(j, _NOBOUND)
                        d = nd[1]
                        if d > 0 and hi is not None and hi <= _I64_MAX - d:
                            dec.add(j)      # i <= hi < MAX-d+1: i+d cannot overflow
                        elif d < 0 and lo is not None and lo >= _I64_MIN - d:
                            dec.add(j)      # i >= lo > MIN+d: i+d cannot underflow
                        # symbolic strict bound i < n (unchanged n): step +/-1 is
                        # safe -- i < n <= MAX so i+1 <= n cannot overflow; the
                        # measure n - i decreases while n stays fixed
                        elif d == 1 and _passes_unchanged(args, lt, depth):
                            dec.add(j)
                        elif d == -1 and _passes_unchanged(args, gt, depth):
                            dec.add(j)
```

*Target sketch* (state threading via a result record — the proven EmitR pattern):

```
; per-variable bound: constant interval + strict symbolic lt/gt level sets
(data Bnd () (bnd (lo (Maybe I64)) (hi (Maybe I64))
                  (lt (List I64)) (gt (List I64))))       ; data: lib/tal-ir.chiral:41-46

; the walk returns its accumulated per-call decreasing sets (or the failure reason):
; closure-mutated `calls` -> threaded result record, the rule PROVEN by EmitR's
; label-counter threading, lib/emit-core.chiral:54-97
(data TotR ()
  (tot-calls (calls (List (List I64))))     ; one decreasing-position set per self-call
  (tot-fail (reason Str)))

(declare walk-tot (-> Str Term I64 (List (Pair I64 SizeTok)) (List (Pair I64 Bnd))
                      (List (List I64)) TotR))

; the numeric-measure arm, one self-call argument:
(def num-dec (-> I64 I64 Bnd (List Term) I64 Bool)     ; j d bound args depth
  (lam (j d b args depth)
    (case b ((bnd lo hi lt gt)
      (case (<i 0 d)
        (true (or (case hi (none false)
                    ((some h) (<=i h (- 9223372036854775807 d))))  ; the wraparound exclusion
                  (and (=i d 1) (passes-unchanged args lt depth))))
        (false (or (case lo (none false)
                     ((some l) (<=i (- -9223372036854775808 d) l)))
                   (and (=i d -1) (passes-unchanged args gt depth)))))))))
```

`_meet` ports as a four-field rebuild using `max`/`min` lifted over `Maybe`
(`lib/prelude.chiral:72-76`); `size`/`bounds` dicts → alists keyed by I64 level
(`lib/collections.chiral:61-84`, with `=i` as the key equality); the final
`set.intersection(*calls)` → a fold intersecting I64 lists (`foldl`,
`lib/collections.chiral:46-50`, with a `list-intersect` NEW helper); `_term_spine` →
the shared spine function from E10's module.

*Mechanical recipe:*
1. COPY — the decision table above verbatim (all four arms, in order); `_num_delta`'s
   three accepted shapes (`(+ p k)`, `(+ k p)`, `(- p k)` — note *no* `(- k p)`,
   that asymmetry is deliberate: `k - p` is not a step of `p`); `_guard_bound`'s
   const_of table; `_passes_unchanged`'s exact condition; the two early-abort
   messages; the final reason string; the classify-then-gate shape of
   `check_termination`.
2. TRANSLATE — `_NotStructural` exception → the `TotR` sum (rule:
   exception-as-early-abort → sum-typed result, threaded; every recursive walk arm
   `case`s its recursive result and propagates `tot-fail` — the same shape
   `emit-branches` uses to thread `EmitR`, `lib/emit-core.chiral:69-78`); dicts →
   level-keyed alists; frozensets `lt`/`gt` → I64 lists (dedup on insert); per-branch
   copied `nbounds` → alists are persistent, copying is free (a port *win* — the
   `if nbounds is bounds` copy-on-write dance at `data.py:682-683` disappears).
3. NEW — `k±1` extreme normalization in the `const_of` port (drop the fact at an
   extreme rather than wrap); `list-intersect`; nothing else. The negative tests
   (`test_kernel.py:543-621`) must be in the port's test corpus before the positive
   ones.

**Dependencies:** family 1's `Term` + `Sig` (`global_types` vs `global_defs`
distinction and the `finish_def` hook ordering are contract); E10's shared
`guard-facts` (or accept the duplication explicitly); E6 (Case shape). Unblocks: the
`(total)` profile gate in the self-hosted verifier; E47/E50 extend this walk later.

**Est. pass size:** M (the walk is the family's largest single function; the
constraint helpers and `_num_delta`/`_guard_bound` are S and separately testable —
slice as: helpers+tests, then the walk, then the gate wiring).

---

## E12 — Effect membrane rules: pure `->` vs process `=>`   [SELF-HOST · Tier P]

**Lives now:**
- `scaffold/chirality/effects.py:21-46` — the whole module: `Rules.on_apply` (`:22-30`),
  `Rules.on_binder` (`:32-38`), `Rules.erased_allow` (`:40-42`), `install` (`:45-46`)
- Kernel consult points (the *placement*, which is the design's): `kernel.py:410`
  (Pi formation), `kernel.py:420` (application), `kernel.py:432` + `kernel.py:477`
  (let binders), `kernel.py:469` (lambda binding — the type-level-Pi-smuggle fix,
  comment at `kernel.py:464-468`), `data.py:189` (erased constructor fields)
- The eff bit itself is carried structurally on Pi: `kernel.py:33` (term),
  `conv` compares it at `kernel.py:284`
- Tests: `scaffold/tests/test_kernel.py:300-316` (effect in pure rejected / in
  process ok / via pure alias rejected), `:276-297` (effects in erased positions)

**Verdict:** PROPER — *as the element the catalog names*. The module is 46 lines,
pure decision logic, and its load-bearing content is the placement: three named
judgment points, consulted by the kernel, decided outside it. The port is nearly
transcription. What the single coarse bit papers over is real but belongs to E39
(effect algebra / typed rows, edge 16) — named here so the port doesn't accidentally
harden the papering into the self-hosted checker's bones.

**Explainer.** The rules: (1) `on_apply` — applying an effectful arrow requires
`allow_eff`; also re-judges the *instantiated* parameter's linear kind (closing the
polymorphic smuggle where a Pi's declared domain was a type variable,
`effects.py:26-29`); returns the argument's allowance via `erased_allow`. (2)
`on_binder` — a linear-kind type binds only at quantity 1 (this is where the port
discipline is *enforced*; the judgment comes from E8/is_linear). (3) `erased_allow`
— a quantity-0 position must be pure, because it is absent at runtime
(`scaffold/AUDIT.md` F1 is the soundness bug this fixed). **What the one bit papers
over (edge 16, `docs/open-edges.md:164-169`):** (a) every `=>` is the same effect —
a file write, a socket send, and `halt` are indistinguishable in the type; there are
no rows, so a function's type cannot say *which* crossings it makes (the frozen-port-
set check does that at the profile layer instead, coarsely). (b) No handling/masking
— `allow_eff` is a boolean threaded downward; an effect can be permitted or
forbidden, never discharged, so there is no resumable-alarm story (alarms and
counter-effects are just externs typed `=>`, `lib/ports.chiral`; recoverable-vs-fatal
is not in the type, contra `docs/error-and-alarm`'s intent). (c) `erased_allow`
conflates erasure with purity — sound (the safe direction) but coarser than a
grade. (d) One structural coupling worth naming: `on_binder` houses the *linearity*
discipline inside the *effects* module — the membrane placement is the design's
(`effects.py:1-15`), but a port should keep the two rules separable so E39 (rows)
can replace the eff rule without touching the port discipline. None of this is a
defect to fix in this pass; it is scope E39 owns. The port's job is to keep the
three consult points exactly where they are.

**Translation dossier.**

*Source exemplar* — `scaffold/chirality/effects.py:22-42`:

```python
    def on_apply(self, sig, ctx, fty, allow_eff):
        """fty is the VPi being applied. Returns allow_eff for the argument."""
        q, eff = fty[1], fty[2]
        if eff and not allow_eff:
            raise KernelError("effectful application inside a pure function (use => not ->)")
        self.on_binder(sig, ctx, fty[4], q, "function parameter")
        return self.erased_allow(q, allow_eff)

    def on_binder(self, sig, ctx, tyv, q, what):
        if q != 1 and K.is_linear(sig, tyv):
            raise KernelError(...)

    def erased_allow(self, q, allow_eff):
        return allow_eff if q != 0 else False
```

*Target sketch* — the Rules object is a record of functions, the pattern already
proven by `Mach` (`lib/mach.chiral:26-52`: a data with function-typed fields plus
accessor defs):

```
; judgment rules: what the membrane permits, decided outside the kernel core.
; record-of-functions + accessors: lib/mach.chiral:26-52. CheckR is the shared
; Result type (cross-family flag): (data CheckR ((A (type 0))) (chk-err (msg Str)) (chk-ok (val A)))
(data Rules ()
  (rules
    (on-apply  (-> Sig Ctx Value Bool (CheckR Bool)))   ; VPi being applied, allow-eff
    (on-binder (-> Sig Ctx Value Q Str (CheckR Unit)))
    (erased-allow (-> Q Bool Bool))))

(def mk-rules Rules
  (rules
    (lam (sig ctx fty allow)
      (case fty ((v-pi q eff nm dom cod)
        (case (and eff (not allow))                       ; and/not: lib/prelude.chiral:59-63
          (true (chk-err "effectful application inside a pure function (use => not ->)"))
          (false (case (rule-on-binder sig ctx dom q "function parameter")
                   ((chk-err e) (chk-err e))
                   ((chk-ok u) (chk-ok (rule-erased-allow q allow)))))))))
    (lam (sig ctx tyv q what)
      (case (and (not (=q q q-one)) (is-linear sig tyv nil))
        (true (chk-err (str-cat what " has linear type but wrong quantity")))  ; str-cat: lib/emit-core.chiral:27
        (false (chk-ok unit))))
    (lam (q allow) (case (=q q q-zero) (true false) (false allow)))))
```

*Mechanical recipe:*
1. COPY — the three rules' decision logic and the three kernel consult points
   (Pi formation, application, binders — including the lambda-binding-site check
   `kernel.py:464-469`, whose comment explains why it exists: type-level-computed Pi
   values never pass formation).
2. TRANSLATE — class-with-methods → Mach-style record of functions (or, if the port
   checker is monolithic-with-profiles, three plain defs — either is grounded;
   record preserves the seam, defs are simpler; decide with family 1's Sig shape);
   raise → `CheckR` sum.
3. NEW — nothing beyond the shared `CheckR`. Genuinely S.

**Dependencies:** family 1's quantity type (E5) and `Value` (E3); E8 (`is_linear`).
Unblocks the whole `check`/`infer` port (family 1 calls these at three points).
E39 later replaces the eff-bit rule behind the same record.

**Est. pass size:** S.

---

## E13 — De Bruijn machinery: `uses_below` / `shift_close`   [SELF-HOST · Tier R (OURS)]

**Lives now:**
- `scaffold/chirality/terms.py:21-52` — `uses_below` (free-variable-below-bound test)
- `terms.py:55-83` — `shift_close` (lower free indices by delta; precondition: the
  lowered range is unused)
- `terms.py:11-18` — `W`, `CORE_ATOMS`, `LIT_TYPE`, `EXT_TERMS` (the constants that
  ride along)
- Consumers: `kernel.py:424` (dependent-codomain test — E9's collapse mechanism
  rides on this), `data.py:251-257` (`_ensure_escapes`: `uses_below` guards
  `shift_close`'s precondition)
- Tests: indirectly via `test_kernel.py` (branch-type escape) and
  `test_refine.py:204-207` (collapse depends on `uses_below` seeing Refine operands)

**Verdict:** PROPER — two standard structural walkers; the port is transcription.
One invariant and one port-side *improvement* to name.

**Explainer.** Both walkers carry per-former knowledge of every binder shape in the
language, including the extension formers (Case binds `len(names)`, Refine's
operands are traversed — `terms.py:48-50, 79-81`). The invariant: **any new term
former must appear in both walkers (and in `data.py`'s `_occurs`/`mentions`
twins)** — in Python a missed former falls into the silent catch-alls (`return
False` at `terms.py:51`, `return t` at `terms.py:82`) and the bug is invisible until
a de Bruijn index corrupts (E9's symbolic collapse was exactly one missed traversal
away from unsound). In the port, `Term` is a closed datatype and `case` without a
default is exhaustiveness-checked by the checker itself (`data.py:242-244`), so **the
port should NOT use a default branch** — a missing former becomes a compile error.
That is a structural upgrade the self-hosting buys for free; write it into the pass
plan. `shift_close`'s precondition ("valid only when none of the lowered range is
used", `terms.py:56`) is caller-discharged via `uses_below` (`data.py:254-256`); the
pair must be ported together and the precondition comment kept.

**Translation dossier.**

*Source exemplar* — `scaffold/chirality/terms.py:21-33` (head of `uses_below`):

```python
def uses_below(t, bound):
    """Does the term use any free variable with index < bound?"""
    def go(t, depth):
        k = t[0]
        if k == "Var":
            return depth <= t[1] < depth + bound
        if k == "Pi":
            return go(t[4], depth) or go(t[5], depth + 1)
        if k == "Lam":
            return go(t[2], depth + 1)
        ...
```

*Target sketch:*

```
(def ub-go (-> Term I64 I64 Bool)                ; t depth bound
  (lam (t depth bound)
    (case t                                       ; NO default branch: exhaustive on purpose
      ((t-var i) (and (<=i depth i) (<i i (+ depth bound))))   ; and: lib/prelude.chiral:62
      ((t-pi q eff nm dom cod) (or (ub-go dom depth bound)
                                   (ub-go cod (+ depth 1) bound)))
      ((t-lam nm body) (ub-go body (+ depth 1) bound))
      ((t-app f a) (or (ub-go f depth bound) (ub-go a depth bound)))
      ((t-case scrut brs dflt)
        (or (ub-go scrut depth bound)
        (or (any-list Br (lam (b) (ub-br b depth bound)) brs)   ; any-list: lib/collections.chiral:52-56
            (case dflt (none false) ((some d) (ub-go d depth bound))))))
      ((t-refine base atoms)
        (or (ub-go base depth bound)
            (any-list RAtom (lam (a) (case a ((ratom op operand)
                                       (ub-go operand depth bound)))) atoms)))
      ...)))                                      ; every remaining former, spelled out

(def uses-below (-> Term I64 Bool)
  (lam (t bound) (ub-go t 0 bound)))
```

`shift_close` is the same skeleton returning `Term` (constructor rebuilds — the
shape `emit-instr` uses over `TInstr`, `lib/emit-core.chiral:29-44`). Both are
structural recursion — proven total by E11's structural rule, another self-hosting
dividend.

*Mechanical recipe:*
1. COPY — every per-former arm, including the binder-depth increments (Case's
   `+ len(names)` — port as `(+ depth (length Str names))`), and the docstring
   preconditions.
2. TRANSLATE — chained `if k ==` → exhaustive `case` (rule: tag dispatch → case, as
   in `emit-instr`); Python's `depth <= i < depth + bound` → `and` of `<=i`/`<i`.
3. NEW — none. Smallest pass in the family; do it first, it is also the port's
   first exercise of the Term datatype.

**Dependencies:** only family 1's `Term` decl (which must include *all* formers —
flagged to family 1). Unblocks: E9 (collapse), E6 (`_ensure_escapes`), the kernel's
dependent-application test.

**Est. pass size:** S.

---

## E14 — Pretty-printer   [SELF-HOST · Tier R (OURS) · non-trusted, low priority]

**Lives now:**
- `scaffold/chirality/pretty.py:15-16` — `show_value` (quote, then render)
- `pretty.py:19-59` — `show_term` (the renderer)
- `kernel.py:324-331` — the lazy-import shims keeping `K.show_value`/`K.show_term`
  (comment: display is not judgment; reached only on error paths)
- Consumers: every `KernelError` message; `refine.py:252-255` (`_show_atoms`)

**Verdict:** EXTEND — sound *as a non-trusted display layer* (a bug here changes an
error message, `pretty.py:3-6`), but three named gaps for the port: Case renders as
the literal stub `"(case ...)"` (`pretty.py:53`), string literals lean on Python
`repr` (`pretty.py:28` — the port needs an escaping helper that doesn't exist in the
prelude), and out-of-scope variables print `#i` (`pretty.py:31` — keep, it is honest).

**Explainer.** The design point that must survive the port is the *placement*:
display sits outside the trusted judgment file, reached only when an error is being
raised, so the TCB claim ("the checker is ours and small") never includes rendering.
In the port this means the pretty module imports the term datatype and quote, and
nothing in eval/conv/subtype/infer/check imports it — with `CheckR`-style errors the
natural shape is that judgment returns structured error *data* and only the driver
renders it, which is strictly better than the Python (where messages are formatted
at raise time inside the kernel). Name that as the port shape: **errors carry terms,
the driver pretty-prints**. The renderer itself is a straight fold to `Str` via
`str-cat`. The `names` list threads binder names for readable variables; indexing it
needs `list-nth` (NEW, trivial). Precedence/parenthesization is the s-expression
surface's — everything is parenthesized, so there is no precedence logic to port.

**Translation dossier.**

*Source exemplar* — `scaffold/chirality/pretty.py:32-43`:

```python
    if k == "Pi":
        arrow = "=>" if t[2] else "->"
        q = "" if t[1] == terms.W else f"{t[1]} "
        dom = show_term(t[4], names)
        cod = show_term(t[5], names + [t[3]])
        return f"({arrow} ({q}{t[3]} {dom}) {cod})"
    if k == "Lam":
        return f"(lam ({t[1]}) {show_term(t[2], names + [t[1]])})"
```

*Target sketch:*

```
(def show-pi (-> Q Bool Str Term Term (List Str) Str)
  (lam (q eff nm dom cod names)
    (let (arrow (case eff (true "=>") (false "->")))     ; let: lib/emit-core.chiral:68
      (str-cat "(" (str-cat arrow (str-cat " ("
        (str-cat (show-q q) (str-cat nm (str-cat " "
          (str-cat (show-term dom names) (str-cat ") "
            (str-cat (show-term cod (append Str names (cons nm nil)))  ; append: lib/collections.chiral:15-19
                     ")"))))))))))))
```

(f-string → `str-cat` chain, the rule proven by `lit-label`,
`lib/emit-core.chiral:26-27`; a `str-cat-all (-> (List Str) Str)` fold helper — NEW,
trivial — makes this bearable.)

*Mechanical recipe:*
1. COPY — the per-former render shapes and the `names`-threading discipline
   (append the binder name when descending under a binder).
2. TRANSLATE — f-strings → `str-cat`/`str-cat-all`; `repr` for str literals → a
   quote-and-escape helper; `str(v)` for i64 → `i64->str` (`lib/prelude.chiral:40`).
3. NEW — (a) real Case rendering (branches + binder names — small, and worth doing
   since case is most of what errors point at); (b) `str-escape` (backslash-quote a
   Str literal; `str-sub`/`str-find`/`str-cat` in the prelude suffice); (c)
   `list-nth`, `str-cat-all` helpers; (d) the errors-as-data shape (a design line in
   the pass plan, not much code).

**Dependencies:** family 1's `Term` + quote (E3); E13 (nothing hard, but Term must
exist). Blocks nothing — schedule last.

**Est. pass size:** S.

---

# Family footer

## Redo list (ranked by downstream poisoning)

No element in this family is a wholesale REDO — the verdicts are 4×PROPER, 3×EXTEND.
The redo list is the *port-blocking shortcuts*, ranked:

1. **Exceptions-as-control-flow, family-wide** (`KernelError` throughout;
   `_NotStructural` at `data.py:477-478`; the swallowed `except KernelError` at
   `data.py:86-90`). Not one element's defect but the single decision that gates
   every checker pass in families 1 and 2: the port needs a shared `CheckR`/Result
   sum and the threading discipline (the EmitR pattern, `lib/emit-core.chiral:54-97`,
   already proves the shape). Decide once, in family 1's first pass, before any
   family-2 element starts. Ties to E26 (alarms) — see cross-family flags.
2. **Unbounded-integer reliance at the I64 extremes** (E9 `refine.py:71-75`
   `_atom`'s `k±1`; `refine.py:117` `is_empty`'s span arithmetic; E11
   `data.py:560-567` `const_of`'s `k±1`). The only place a *naive* port is unsound
   rather than broken: `{v > MAX}` wrapping to `TOP` accepts everything. Fix is
   normalize-at-construction (empty constraint / dropped fact) plus the
   span-arithmetic-free punch-out walk. Must be in the E9/E11 pass plans as explicit
   NEW steps with negative tests.
3. **`repr()`-keyed seen set** (E8, `data.py:72`). A hashable-proxy crutch with no
   chirality equivalent; needs the shared `val-eq` structural equality. Poisons only E8,
   but `val-eq` is wanted by family 1's conv debugging too — build it once.
4. **Guard-fact extraction written twice** (E10 `refine.py:272-333` vs E11
   `data.py:540-582`). Principled duplication in Python (module independence),
   pointless in the port (a pure library import couples nothing). Consolidate into
   one `guard-facts` module before porting either consumer, or the two copies will
   diverge in chirality exactly as they were starting to in Python (two fact
   vocabularies for one algorithm).
5. **Pretty-printer Case stub + Python `repr`** (E14, `pretty.py:53, 28`). Cosmetic,
   non-trusted, last.

## Ordering (dependency-respecting sequence for the family's passes)

All passes gate on family 1 landing the `Term`/`Value`/`Ctx`/`Sig` data declarations
and the `CheckR` decision (redo item 1). Then:

1. **E13** (S) — the walkers; first exercise of the Term datatype; everything else
   consumes them; exhaustive-case discipline established here.
2. **E12** (S) — the membrane record; family 1's `check`/`infer` port needs its three
   consult points defined.
3. **E9** (M) — constraint algebra first (pure, standalone, Z3-oracle-testable per
   Tier O), then the term former + four hook branches.
4. **E10** (S) — the shared `guard-facts` module + the narrow hook (needs E9 and
   family 1's Ctx with `list-set-at`).
5. **E11** (M) — the termination walk, reusing `guard-facts` and the spine helper;
   negative tests ported first; then the classify ledger + `require_total` +
   `(total)` profile gate.
6. **E8** (S) — needs `val-eq`/`eval-term-opt`; otherwise independent; slots
   anywhere after E12 but is only *load-bearing* once family 1's binder checks call
   `is-linear`.
7. **E14** (S) — last; establishes the errors-carry-terms rendering shape.

## Cross-family flags

- **[→ family 1, blocking] The Term/Value/Ctx/Sig representation** (E3–E5). Every
  sketch above consumes it. Two requirements from this family: the `Term` datatype
  must include *all* formers including `Refine` with its operand list (so E13's
  walkers and E11's walk can be exhaustive — no silent catch-alls), and `Ctx` must
  support `narrow` (entry retype by level, env shared) — trivially structural with
  immutable lists, but it must be in the Ctx interface from day one.
- **[→ family 1 / candidate E51] Seam architecture under self-hosting.** The Python
  seams (`ext_check`/`ext_eval` dicts, hook *lists*, `rules` object) exist so
  modules can attach without editing the kernel. In the self-hosted checker the Term
  type is one closed data declaration, so the term-former seams naturally become
  case branches, and the value hooks either become branches too or stay open as
  Mach-style records of functions (`lib/mach.chiral:26-52` proves the pattern). This
  is a real design decision — *how does the kernel-seam pattern survive when the
  syntax is closed* — that no catalog element currently owns. Propose **E51: seam
  architecture for the self-hosted checker**.
- **[→ E26 / candidate E52] The Result/error discipline.** Redo item 1. The alarms
  element (E26) owns exceptions-as-control-flow at the *runtime* level; the checker
  needs the same decision at the *judgment* level (structured error data, rendered
  by the driver — see E14). One decision should cover both or explicitly split them.
- **[→ E27 / shared library] Checker support helpers** missing from
  `lib/collections.chiral`: `all-list`, `list-nth`, `list-set-at`, `list-intersect`,
  `sorted-insert` (canonical sets-as-lists), `str-cat-all`, `str-escape`, `val-eq` /
  `term-eq`, `eval-term-opt`. All S-sized; batch them as the opening slice of
  whichever family-2 pass runs first, or extend E27's pass.
- **[→ family 1] `finish_def` hook ordering is contract** (`kernel.py:545-554`): the
  def-hooks run after the body checks but *before* the def is installed — E11's
  mutual-recursion detection reads `global_types`-but-not-`global_defs`. The family-1
  port of `finish_def` must preserve this ordering or E11 silently stops detecting
  forward references.
- **[→ E39, scope guard] What E12's coarse bit papers over** (rows, handlers,
  recoverable-vs-fatal in the type — edge 16) is E39's scope. The E12 pass should
  keep the eff rule and the linear-binder rule separable inside the Rules record so
  E39 can replace one without touching the other.
- **[observation, no owner needed] Self-hosting upgrades soundness in three places
  for free:** exhaustive case replaces silent walker catch-alls (E13), persistent
  lists make `Ctx.narrow`'s value-unchanged invariant and E11's per-branch bound
  copying structural (E10, E11), and the ported walkers are themselves provable
  total by the ported E11 (structural recursion) — the checker checking itself.
  Worth a line in the eventual TCB story.
