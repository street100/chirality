# Family 3 — The compiler pipeline (E15–E19)

**Elements:** E15 reference interpreter · E16 lowering · E17 optimizer · E18 TAL
checker + reference tal interpreter · E19 x86-64 codegen (already chirality).

**State of the family.** This is the healthiest family in the catalog: one of its
five elements (E19) is *already self-hosted* and proven — `lib/emit-core.chiral` +
`lib/mach.chiral` + `lib/mach-x64.chiral` + `lib/mach-listing.chiral` +
`lib/asm-reloc.chiral` + `lib/emit-x64.chiral` emit real x86-64 that passes
differential tests against the reference tal machine (`tests/test_native.py`), and
`lib/tal-ir.chiral` already carries the IR as chirality data. The other four are sound
Python (all Tier R — our own port source; E16/E17 additionally Tier F for opt
ideas) with the preserve-check discipline genuinely load-bearing: lowering and
every optimizer pass re-check at the floor (`tal.check_fn`), and the tests pin
that an ill-typed pass output raises. The port path for E15–E18 is therefore
mostly mechanical *given two prerequisites this audit names precisely*: (1) the
chirality-side tal IR must grow **types** (tal-ir's `TFn` is deliberately type-erased;
the Python side re-derives types from `native.py` `LIB_SIGS` — a self-hosted
checker cannot), and (2) E15/E16 need family 1's Term/Value/Sig-as-chirality-data
(E13/E2/E3) before they can start. E17 and the E18 checker need neither kernel
port and are the family's earliest self-host wins. Verdicts: two PROPER, three
EXTEND, zero REDO — but three sharp latent defects were found and are listed in
the footer.

Floor agreement (settled; recorded, not relitigated): I64 is two's-complement,
div/mod Euclidean; the fold imports the reference's own arithmetic
(`optimize.py:28` `from .impl_pure import wrap64, i64_div, i64_mod`), the native
drop implements the Euclidean correction in `mach-x64.chiral:99–109`
(`x-div-fix`/`x-mod-fix`), and `tests/test_optimize.py:47`
(`test_fold_preserves_negative_division`) pins all three floors to the same
values. A port bonus falls out below (E17): self-hosting makes the agreement
*structural* — a chirality-written fold computes with the language's own prims, so
fold-vs-runtime divergence becomes inexpressible.

---

## E15 — Reference interpreter (golden semantics, tree-walk + TCO)   [SELF-HOST · Tier R]

**Lives now:**
- `scaffold/chirality/runtime.py:36` (`class RT`), `:55` (`global_value`, lazy global
  forcing), `:65` (`run`, the tree-walk loop), `:85–104` (App-spine unwinding +
  `tail_jump` — the TCO mechanism), `:105–121` (Con/Case), `:122–130` (`Global`
  dispatching to the tal floor when lowered — the linker seam), `:141` (`apply1`:
  clo/talf/pap), `:158–164` (bridge verification of extern returns — the inbound
  membrane), `:169` (`run_main`).
- Value forms documented at `runtime.py:14–21`.
- CPython crutches: `sys.setrecursionlimit` (`:40–41`), `IMPLS` host-dict
  (`:29`), Python exceptions `RuntimeErrorChirality`/alarms.

**Verdict:** PROPER — sound as-is; the pass is a port. No scaffold shortcut found
in the semantics itself. (The one semantic subtlety — 0-quantity lets erased,
0-quantity *arguments* still evaluated but checked pure — is deliberate and
documented at `runtime.py:5–8`; keep it.)

**Explainer.** This is the golden semantics: everything else (fold, tal machine,
native) is tested *against* it, so the port must be value-identical, not merely
similar. Three invariants a future pass must carry over exactly: (1) **TCO by
spine unwinding** — `run` collects the application spine, applies all but the
last argument recursively, and turns the last closure call into loop iteration
(`:92–104`); a naive recursive `apply` diverges from this on long event loops.
(2) **Erasure**: a 0-quantity `Let` pushes `("erased",)` without evaluating
(`:75–79`); the checker guarantees nothing reads it. (3) **The two seams that
must survive the port**: the linker seam (`Global` checks `self.tal` first and
returns a `talf` partial application that executes on the tal machine, `:122–130`)
and the inbound bridge (`apply1` verifies every extern's returned value against
its declared type before it enters typed land, `:158–164`). What the port cannot
copy: the `IMPLS` name→Python-function dict (`:29`). A chirality-in-chirality interpreter
still needs *some* prim dispatch — during bootstrap the natural shape is a
`(Str, List Val) -> Val` dispatcher that cases on the prim name and calls the
language's own externs (so `+` is implemented by `+`). This is the one genuinely
NEW seam, and it is small but must be designed once (it is also where the E23
FFI-crutch retirement will eventually land). Also note: the port is *written*
tail-recursively and initially *runs on* this very Python RT, which does TCO —
so the port's own event loops don't grow the host stack; when it later runs
native, TCO becomes the backend's problem (calls are real calls —
`bytes-tal.chiral:11–13` names that honest limit).

**Translation dossier.**

*Source exemplar* — the TCO core, `runtime.py:85–104`:

```python
if k == "App":
    # unwind the application spine so the final call is a tail call
    spine = []
    f = t
    while f[0] == "App":
        spine.append(f[2])
        f = f[1]
    spine.reverse()
    fv = self.run(f, env)
    tail_jump = None
    for i, arg_t in enumerate(spine):
        av = self.run(arg_t, env)
        result, tail = self.apply1(fv, av)
        if tail is None:
            fv = result
        elif i == len(spine) - 1:
            tail_jump = tail          # last call: iterate, not recurse
        else:
            fv = self.run(tail[1], tail[0])
    if tail_jump is None:
        return fv
    env, t = tail_jump
    continue
```

and `apply1`, `runtime.py:141–166` (returns either a value or an
`(env, body)` continuation the caller runs in tail position).

*Target sketch* — every construct below is modeled on an existing exemplar,
cited inline. **Precondition (a finding, not a sketch):** `Term` and `Sig` as
chirality data do not exist yet; they are family 1's E13/E2 deliverable. The sketch
assumes a `Term` datatype declared in exactly the style of `TInstr`
(`lib/tal-ir.chiral:19–34` — one `data` with one constructor per node kind,
typed fields).

```lisp
; runtime values — data decl style: TInstr, lib/tal-ir.chiral:19
(data Val ()
  (v-i64 (n I64))
  (v-str (s Str))
  (v-bytes (b Bytes))
  (v-con (cname Str) (fields (List Val)))
  (v-clo (env (List Val)) (body Term))
  (v-pap (name Str) (args (List Val)) (remaining I64))
  (v-erased))

; env lookup by de-Bruijn index — recursion shape: alist-get, collections.chiral:61
(def env-nth (-> (List Val) I64 Val)
  (lam (env i)
    (case env
      (nil (halt Val "run: unbound variable"))     ; halt: asm-reloc.chiral:52
      ((cons h t)
        (case (=i i 0) (true h) (false (env-nth t (- i 1))))))))

; apply one argument: value or a tail continuation — Maybe/Pair: prelude.chiral:10,13
(data App1R ()
  (app1-val (v Val))
  (app1-tail (env (List Val)) (body Term)))

(declare rt-run (-> Sig (List Val) Term Val))      ; declare: emit-core.chiral:56

(def rt-apply1 (-> Sig Val Val App1R)
  (lam (sig f a)
    (case f
      ((v-clo env body) (app1-tail (cons a env) body))  ; NB: see recipe step T4
      ((v-pap name args remaining)
        (case (=i remaining 1)
          (true (app1-val (prim-dispatch sig name (append Val args (cons a nil)))))
          (false (app1-val (v-pap name (append Val args (cons a nil)) (- remaining 1))))))
      (_ (halt App1R "cannot apply non-function")))))   ; default branch: place, asm-reloc.chiral:45
```

The `run` loop itself: chirality has no `while`/`continue`; the loop becomes
tail-recursion on `(rt-run sig env t)` — the `tail_jump` case is literally
`(rt-run sig env2 body2)` in tail position, which the host RT iterates
(`runtime.py:85–104` is the machine that makes that free). `prim-dispatch` is
the NEW seam: a `(Str, List Val)` case chain in the style of `op-bytes`
(`mach-x64.chiral:112–122` — nested `str-eq` cases ending in `halt`).

**Missing constructs (findings, not sketches):** none at the syntax level — but
`Term`, `Sig`, and a global-definition table as chirality data are family-1
prerequisites; the lazy `self.globals` cache (`runtime.py:43`, mutation) has no
chirality equivalent and must become either (a) re-evaluation per reference
(semantically fine, slow) or (b) an explicitly threaded
`(List (Pair Str Val))` cache in the run state — thread it like `EmitR` threads
the label counter (`emit-core.chiral:54`).

*Mechanical recipe.*
1. COPY: the value-form taxonomy (`runtime.py:14–21`) → the `Val` data decl,
   one constructor per line of that docstring.
2. COPY: the per-node semantics of `run` (`:65–139`) → one `case` branch per
   Term constructor; the order and the erasure rule copy verbatim.
3. TRANSLATE (rule: Python `while True:`+`continue` → tail self-call): the
   iterate-don't-recurse cases (`Let`, `Case`, `Ann`, `tail_jump`) become tail
   calls to `rt-run`.
4. TRANSLATE (rule: Python list-append env `env + [v]` with index
   `env[len(env)-1-i]` → chirality cons-front env with index `env-nth env i`): the
   de-Bruijn convention flips from append-at-end to cons-at-front, so indexing
   simplifies — this is the one *representation* change; test it against the
   Python on nested lets before anything else.
5. TRANSLATE (rule: mutation → threaded state record): `self.globals` cache and
   `self._result_ty` memo → threaded alist or dropped (re-derive per call).
6. NEW (small): `prim-dispatch` — the extern table as a `str-eq` case chain over
   the prims of `lib/prelude.chiral:23–55`, each implemented by the prim itself.
7. NEW (decision, not code): what the ported interpreter does at a `Global`
   that is lowered — keep the linker seam by calling into the tal-machine port
   (E18) or drop it and run everything upper during bootstrap. Either is
   defensible; say which in the pass plan.

**Dependencies:** family 1's E13 (Term as data) and E2/E3 (Sig, global defs as
data) must land first. Unblocks: differential self-testing (the chirality
interpreter vs. the Python one on the same terms) — the first
oracle-of-ourselves. Not on the critical path of E16–E18.

**Est. pass size:** M (1–2 sessions) once family-1 data forms exist. If it runs
long, slice at: (a) pure fragment without paps/externs, (b) prim dispatch +
bridge seam, (c) global/linker seam.

---

## E16 — Lowering: pure→tal, register/slot alloc, non-tail case outlining, preserve-check   [SELF-HOST · Tier R (+F for ideas)]

**Lives now:**
- `scaffold/chirality/lower.py:29` (`ttype`: upper type value → tal type), `:45`
  (`talty_to_val`, the inverse), `:55` (`data_fields`: constructor field types
  via kernel evaluation), `:73` (`_peel`: Pi-chain → parts, rejects dependent
  codomains), `:87` (`prim_sigs`), `:107` (`class Low`: `fresh()` register
  counter `:116`, `fn` `:121`, `tail` `:134`, `ann_ty` `:162`, `expr` `:168`),
  `:170–205` (non-tail case **outlining**), `:283` (`lower_all` with the
  preserve-check at `:308–310` and the rollback of installed sigs at `:311–315`).
- Eligibility doctrine: `lower.py:10–16` (docstring) — pure, non-dependent,
  ω-quantity arrows over ground types; effects/closures/partial
  application/erased-in-types stay upper.
- Tests: `tests/test_tal.py:44–53` (coverage: pure fragment lowers, crossings
  skipped with reasons), `:86–100` (preserve-check catches a lying signature
  and bad operands).

**Verdict:** EXTEND — the core is sound and the preserve-check makes its own
bugs non-shippable, but three named missing pieces: (1) `q != K.W` binders never
lower (`lower.py:296–297` — 0/1-quantity arrows are wholesale ineligible, so
erasure and linear args never reach the floor); (2) an erased *let* lowers as a
dummy `("const", d, I64, 0)` (`:152–154`, `:245–247`) regardless of the binder's
declared type — sound only because the checker proves it unread, but it burns a
register and would type-clash if erasure ever became partial; (3) non-tail case
outlining passes the *entire* enclosing register file as parameters
(`:185–205`) — correct, preserve-checked, but O(live-regs) per call and the
comment at `:171–177` honestly names join blocks as the unbuilt alternative.
None of these block the port; port them as-is and carry the three as extension
edges.

**Explainer.** The load-bearing idea (docs/joining-law.md, quoted at
`lower.py:1–8`): the connector's preservation is *discharged at the floor*, not
trusted — `lower_all` installs the declared signature first so recursion sees it
(`:303–304`), compiles, then `tal.check_fn` re-checks the output; on failure it
rolls back the installed sigs including the outlined `name$N` children
(`:311–315`). The trap that isn't obvious: **`Ineligible` is control flow, not
error** — `lower_all` catches it per definition and records a *reason* string
(`skipped`), which `chirality lower` reports; the port must not turn this into
`halt`. Second trap: register allocation here is *virtual and monotonic* —
`fresh()` never reuses, which is the unstated single-assignment invariant E17's
fold silently relies on (see footer). Third: `data_fields` (`:55–70`) calls
`K.eval_term` to instantiate constructor field types at the case's type
arguments, and `_peel` (`:73–84`) calls `K.uses_below`/`K.close_apply` — **the
lowering pass has a real dependency on the kernel's NbE**, so its port is gated
on family 1's E3/E13, not just on tal data forms. Fourth: `expr` threads an
`expected` type downward (`ann_ty` keeps annotations only when non-dependent,
`:162–166`) because parameterized constructors need a lowerable annotation to
pick their tal type (`:224–231`) — the expected-type plumbing is easy to drop in
a port and everything still typechecks until the first `(cons ...)` under a
polymorphic data type fails.

**Translation dossier.**

*Source exemplar* — the outlining decision, `lower.py:168–205` (abridged to the
decision core; quote the file for the full body):

```python
def expr(self, t, env, instrs, expected):
    k = t[0]
    if k == "Case":
        # non-tail case, by outlining: the case becomes its own function
        # whose params are the enclosing registers plus the scrutinee, ...
        if expected is None:
            raise Ineligible("non-tail case needs an expected type from context")
        src, sty = self.expr(t[1], env, instrs, None)
        ...
        name = f"{self.name}${self.ncase}"
        self.ncase += 1
        params = [ty for (_, ty) in env] + [sty]
        self.env_tal.fn_sigs[name] = (tuple(params), expected)
        sub = Low(self.sig, self.env_tal, name)
        ...
        instrs.append(("call", d, name,
                       [r for (r, _) in env] + [src], expected))
        return d, expected
```

and the type map, `lower.py:29–42` (`ttype`).

*Target sketch* — constructs cited inline. **Preconditions (findings):** the
typed tal vocabulary (`TalTy`, typed instructions or a signature table) must
exist in chirality first — that is E18 slice (a) below; and `Sig`/`Term`/kernel-eval
as chirality data are family 1 (E3/E13). Fallible computation needs an Either-style
result type, which the prelude lacks — declare one in the exact shape of `Maybe`
(`prelude.chiral:13–15`); that is a two-line library add, not a language gap:

```lisp
; Either-shape result: modeled on Maybe, prelude.chiral:13
(data LowR ((A (type 0)))
  (low-skip (why Str))          ; Ineligible, as data — NEVER halt here
  (low-ok (val A)))

; tal type map — case-over-constructors: ttype mirrors asm-size, asm-reloc.chiral:21
(def ttype (-> Sig TyVal (Maybe TalTy))
  (lam (sig tyv)
    (case tyv
      ((vprimty n)
        (case (str-eq n "I64") (true (some tt-i64))        ; str-eq chain: op-bytes, mach-x64.chiral:112
          (false (case (str-eq n "Str") (true (some tt-str))
            (false (case (str-eq n "Bytes") (true (some tt-bytes))
              (false none)))))))
      ((vtcon dname targs) (ttype-args sig dname targs))   ; helper, same recursion as emit-args, emit-core.chiral:18
      (_ none))))

; lowering state: fresh-register counter + outlined extras, threaded —
; the EmitR pattern, emit-core.chiral:54 (data EmitR () (emit-r (asm ...) (next I64)))
(data LowSt ()
  (low-st (nregs I64) (ncase I64) (extra (List TalFnT))))
```

The `Low.expr`/`Low.tail` pair becomes two mutually recursive defs — use
`(declare ...)` exactly as `emit-core.chiral:56` declares `emit-code` before
`emit-branches` uses it. Every `self.fresh()` becomes "return the value AND the
bumped `LowSt`" — the same shape `emit-branches` already threads `lbl` through
`EmitR` (`emit-core.chiral:59–78`), so the port has a worked in-repo model for
its hardest idiom.

*Mechanical recipe.*
1. COPY: the eligibility doctrine (`lower.py:10–16`) as the port's header
   comment; it is the spec.
2. TRANSLATE (rule: `Optional[X]` return → `(Maybe X)`; `raise Ineligible(s)` →
   `(low-skip s)` propagated by casing): `ttype`, `_peel`, `prim_sigs`,
   `ann_ty`.
3. TRANSLATE (rule: mutable `self.nregs/self.ncase/self.extra` → threaded
   `LowSt`, per the `EmitR` pattern): `fresh`, `expr`, `tail`. Each returns
   `(Pair result LowSt)` (nested-`Pair` returns are established practice: the
   branch header in `TCode` is `((tag, binds), code)` as nested pairs,
   `tal-ir.chiral:39–46`).
4. TRANSLATE (rule: kernel calls stay kernel calls): `K.eval_term`,
   `K.close_apply`, `K.uses_below` → the family-1 ports of the same names; do
   not re-derive field types any other way — `data_fields` instantiating field
   types through real NbE evaluation is what makes parameterized data lower
   correctly.
5. COPY: `lower_all`'s install-sig-first-then-check-then-rollback protocol
   (`:302–315`) — the rollback of `name$N` children on failure is easy to
   forget and leaves poisoned signatures in the env.
6. NEW (small): the `skipped` report — a `(List (Pair Str Str))` name→reason
   alist (`alist-put`, `collections.chiral:73`) instead of a dict.
7. NEW (named, deferred): join-block lowering as the outlining alternative, and
   0/1-quantity arrow eligibility — both are extension edges, not part of the
   port pass.

**Dependencies:** E18 slice (a) (typed tal vocabulary in chirality) and family 1
E3+E13 (kernel eval + term/Sig data). Unblocks: a fully chirality compile path
upper-source → tal → (E19) native, i.e. the self-hosting spine.

**Est. pass size:** L — slice it: (L1) type maps `ttype`/`talty_to_val`/
`_peel`/`prim_sigs`/`data_fields` (S, testable alone against Python on the demo
sigs); (L2) `expr`/`tail` for the non-outlining fragment + `fn` (M); (L3)
outlining + `lower_all` + preserve wiring + skipped-report (M).

---

## E17 — Optimizer: const-fold, DCE, specialize/partial-eval/pregen   [SELF-HOST · Tier R (+F: Jones–Gomard–Sestoft ideas)]

**Lives now:**
- `scaffold/chirality/optimize.py:33–34` (`_PURE_NOALLOC`, `_FOLDABLE` — the honesty
  sets: what may be dropped, what may be folded), `:37` (`_fold_prim` —
  delegates to `impl_pure.wrap64/i64_div/i64_mod`; the comment at `:38–40` is
  the floor-agreement law), `:54` (`_uses_in_block`), `:89` (`_fold_block`:
  constant env + static branch selection at `:127–138`), `:152` (`_dead_block`:
  drop-unused to fixpoint), `:182` (`_remap_block`), `:223` (`specialize`: the
  pregen primitive; register-permutation plan documented `:232–238`), `:280`
  (`optimize`: fold∘dead to a size fixpoint, then preserve-check).
- Tests: `tests/test_optimize.py` — fold shrinks and agrees (`:35–45`),
  Euclidean division preserved under fold (`:47–60`), whole-demo
  meaning-preservation (`:62–79`), ill-typed pass output rejected (`:82–91`),
  specialize is smaller-and-equal / collapses dispatch / runs natively
  (`:94–129`).

**Verdict:** EXTEND — fold, DCE, and specialize are sound and preserve-checked;
named missing pieces: comparisons don't fold (`_FOLDABLE` is `{+,-,*,/,%}`
only, `:34` — a constant `(<=i 3 5)` scrutinee survives), branch selection only
fires on *nullary* constructors (`:134` requires `not dsts`), `specialize`
bindings accept only I64 and nullary cons (`:255–263`), and there is no
inlining/CSE (fine — honest scope, `:18–24` explicitly disclaims cost claims,
edges 2/3). One latent defect found, shared with E18: `_fold_block` never
invalidates `cenv[dst]` on a `const` of STR/BYTES or on a `con` **with**
fields (`:97–101`, `:114–118` pop nothing) — sound today only because `Low.fresh()`
never reuses a register, an invariant no checker states or enforces. See footer
redo item 2.

**Explainer.** The organizing discipline (`:11–16`): every pass is tal→tal with
its output re-run through `tal.check_fn` — an optimizer bug is a floor alarm,
never a shipped artifact. The subtle part of `specialize` is the register plan
(`:232–238`): parameters occupy registers `0..n-1`; unbound params are remapped
to the low block in order, bound params to the rest, and since
`#unbound + #bound == n` the remap is a *permutation of the parameter block
only* — every non-parameter register is untouched, so `_remap_block` with
`remap.get(r, r)` is safe. A port that gets this wrong will still be *caught*
(preserve-check) but will fail confusingly; port the plan comment verbatim.
The floor-agreement trap: `_fold_prim` returns `None` for division by zero
(`i64_div` returns `None`, `impl_pure.py:28–35`), and the fold *skips* rather
than folds — the runtime raises there, and folding a crash into a constant
would change meaning. **The self-hosting dividend:** a chirality-written fold
computes `(+ a b)` with the language's own `+` — which *is* `wrap64` on the
reference and the wrapping native add at the floor — so the fold/runtime
agreement that Python maintains by a deliberate import (`:28`) becomes true by
construction. The only care point that survives the port is the zero-divisor
guard: chirality `(/ a 0)` halts, so the chirality fold must test `(=i b 0)` *before*
computing, exactly where Python tests `is None` after.

**Translation dossier.**

*Source exemplar* — `optimize.py:37–51`:

```python
def _fold_prim(op, a, b):
    # Delegate to the runtime's own arithmetic so a folded value is bit-for-bit
    # what execution would produce (wrapping +,-,*; Euclidean /,%). Any other
    # rule here silently reintroduces the fold/runtime divergence.
    if op == "+":
        return wrap64(a + b)
    ...
    if op == "/":
        return i64_div(a, b)
```

and the constant env / static dispatch, `optimize.py:104–138`.

*Target sketch* — all constructs cited; assumes E18 slice (a)'s typed IR:

```lisp
; a known register fact — data decl: TInstr style, tal-ir.chiral:19
(data CFact ()
  (cf-i64 (n I64))        ; ('i', int)
  (cf-tag (tag I64)))     ; ('c', cname) — tags, since chirality tal-ir uses tag numbers

; cenv: register -> fact, an I64-keyed alist — alist-get with =i:
; collections.chiral:61 (caller-supplied eq is the point of the design)
;   (alist-get I64 CFact =i cenv r)

; the fold table: the language's own prims ARE the reference arithmetic
(def fold-prim (-> Str I64 I64 (Maybe I64))          ; Maybe: prelude.chiral:13
  (lam (op a b)
    (case (str-eq op "+") (true (some (+ a b)))      ; str-eq chain: op-bytes, mach-x64.chiral:112
      (false (case (str-eq op "-") (true (some (- a b)))
        (false (case (str-eq op "*") (true (some (* a b)))
          (false (case (str-eq op "/")
            (true (case (=i b 0) (true none)         ; the zero-divisor guard, BEFORE computing
                    (false (some (/ a b)))))
            (false (case (str-eq op "%")
              (true (case (=i b 0) (true none) (false (some (% a b)))))
              (false none))))))))))))
```

The use-set for DCE: `(List I64)` with a member test in the shape of
`any-list` (`collections.chiral:52`); `_fold_block`/`_dead_block` recurse over
the block exactly as `emit-code` recurses over `TCode`
(`emit-core.chiral:80–97` — `t-seq`/`t-ret`/`t-case` is the same three-way case).
The fixpoint loop in `optimize` (`:280–289`) becomes a tail-recursive def
comparing `_size` before/after — recursion-instead-of-loops is the standing
convention (`bytes-tal.chiral:11–12`).

**Missing construct (finding):** none — but note the chirality tal-ir represents
branch selectors as *tag numbers*, not constructor names (`tal-ir.chiral:9–11`),
so the port's static-dispatch match is `(=i tag known-tag)` where Python
compares `cname == known[1]` — a rule-governed rename, listed in the recipe.

*Mechanical recipe.*
1. COPY: `_PURE_NOALLOC` and `_FOLDABLE` as the port's two honesty lists (case
   chains over instruction constructors / op strings); copy the comment at
   `:31–33` — it is the DCE soundness argument.
2. TRANSLATE (rule: dict cenv → I64-keyed alist with `=i`; `cenv.pop(dst)` →
   `alist-put` of a `cf-unknown` or a filtered rebuild): `_fold_block`. **Add
   what Python lacks:** pop/overwrite `dst` on *every* defining instruction
   (fixes the latent staleness in the same motion — see footer item 2).
3. TRANSLATE (rule: cname strings → tag I64s per `tal-ir.chiral:9–11`): branch
   selection and `specialize`'s `('con', dname, cname)` binding becomes
   `(cf-tag n)`.
4. COPY: the specialize register plan (`:232–238`) comment and both loops
   verbatim; the permutation argument is representation-independent.
5. TRANSLATE (rule: mutation-free remap): `_remap_block` is already pure —
   near-verbatim, one case branch per instruction constructor, same shape as
   `emit-instr` (`emit-core.chiral:29–44`).
6. NEW (small): fold comparisons (`=i/<i/<=i` → `cf-tag 0/1`) so constant
   scrutinees select branches — a 6-line extension the Python never had;
   optional but cheap and makes specialize-through-guards actually collapse.

**Dependencies:** E18 slice (a) (typed IR + chirality `check-fn` for the
preserve-check — the discipline is void without it). Independent of family 1
entirely. Unblocks: pregen/staging work (Fork C) on a fully-chirality substrate.

**Est. pass size:** M — fold+DCE one session, remap+specialize+pipeline the
second. If sliced: (a) fold + DCE + fixpoint, (b) remap + specialize.

---

## E18 — TAL checker + reference tal interpreter   [SELF-HOST · Tier R; IR already chirality at `lib/tal-ir.chiral`]

**Lives now:**
- Types + IR doc: `scaffold/chirality/tal.py:10–44` (the floor's instruction set,
  including the milestone-4 sys face and the honest bput limit at `:28–32`).
- Checker: `tal.py:73` (`TalEnv`), `:84` (`check_fn`), `:91–187`
  (`_check_block` — per-instruction typing, terminator checking, per-branch
  regty copies at `:178–181`, exhaustiveness at `:184–185`, `sysface` marking
  at `:151`/`:156`), `:190` (`_check_args`), `:199` (`_fields`).
- Interpreter: `tal.py:208` (`TalMachine` — "the trusted drop"), `:225–261`
  (`_block`), `:263–271` (`_sys`: **ctypes `libc.syscall`**, `_pins` buffer
  lifetime), `:273–279` (`_bptr`: **ctypes `from_buffer` address-of**).
- IR as chirality: `lib/tal-ir.chiral:19–34` (`TInstr`), `:41–46` (`TCode`),
  `:48–49` (`TFn` — **note: name, nparams, nregs, code; NO types**).
- The type gap's workaround: `native.py:69–97` (`LIB_SIGS` — Python-side
  signatures for the chirality-authored library), `native.py:259–316` (`tfn_to_tal`
  — the reverse shuttle that re-derives types, hardcoding "cases scrutinize
  Bool only" at `:263–265` and comparison-prims-return-BOOL at `:279–280`).
- Tests: `tests/test_tal.py` (agreement + preserve-check), and every use of
  `check_fn` from E16/E17.

**Verdict:** EXTEND — the checker is sound for its vocabulary and genuinely
independent of the kernel (the point, `tal.py:5–8`); the interpreter is honest
about being host-substrate. Named missing pieces: (1) **the chirality-side IR is
type-erased** — `TFn` carries no param/ret/instruction types, so the self-hosted
checker's input vocabulary does not exist yet in chirality; today the types live
only in Python (`LIB_SIGS`, instruction annotations on `tal.py` tuples) and the
reverse shuttle's Bool-only hardcoding is the visible scar; (2) bput after
escape is unchecked (documented, `:28–32`); (3) the sys allowlist is any
immediate (`:146–148` checks immediacy only; docs/status-ledger.md names this a
seed); (4) register single-assignment is not enforced (`regty[dst]` silently
overwrites, `:104` etc.) — the invariant E17's fold leans on. CPython crutches
in the interpreter, each with a named port story below: bytearray cells, dict
regty, Python recursion, exceptions, ctypes syscall + pin list.

**Explainer.** Two artifacts share this file and their ports diverge sharply.
**The checker** is pure, first-order, and dependency-light — it consults data
declarations only through the `data_fields` closure and prim/fn signatures
through `TalEnv`; port-wise it is the family's cleanest target *once the typed
vocabulary exists in chirality*. The one structural subtlety: branch checking
copies the register file per branch (`rt2 = dict(regty)`, `:178`) and the
default branch gets the *unextended* copy (`:182–183`) — flow-sensitivity by
copying, which in chirality is free (alists are persistent; "copy" is just reuse).
**The interpreter** is the scaffold's trusted drop, and three of its crutches
are not portable to upper chirality at all: (a) `bput` mutates a `bytearray` in
place — upper chirality `Bytes` is immutable, so a chirality reference machine either
represents cells functionally (bput = copy-with-one-byte-changed via the
existing `bslice`/`bcat` prims — O(n) per write, semantically exact, honest
reference cost) or delegates cells to the tal floor itself; (b) `_sys`
(`:263–271`) issues a *real* syscall through ctypes — upper chirality structurally
cannot cross (that is the whole membrane), so **a self-hosted TalMachine cannot
execute sysface functions, by design**; the honest resolution is that the
ported reference machine covers the pure fragment only and refuses
`ti-sys`/`ti-bptr` (checking `TalFn.sysface` — the mark exists for exactly this,
`:41–44`), leaving the native drop as the only executor of the sys face. That
is not a regression: it is the membrane holding. (c) `_bptr`'s pin list is a
lifetime hack the functional representation simply doesn't need. Finally the
finding that shapes the whole family: **retiring `LIB_SIGS` + `tfn_to_tal`'s
Bool-only reverse shuttle requires a chirality `TSig`/typed-`TFn`** — once tal
signatures are chirality data, hand-authored libraries (`sys-tal.chiral`,
`bytes-tal.chiral`) can declare their own types and the chirality checker can check
them with no Python in the loop.

**Translation dossier.**

*Source exemplar* — the checker's core discipline, `tal.py:164–185`:

```python
elif term[0] == "case":
    _, src, branches, default = term
    sty = regty.get(src)
    if sty is None or sty[0] != "Data":
        raise TalError(f"{fn.name}: case on non-data register of type {sty}")
    ctors, order = env.data_fields(sty)
    covered = set()
    for cname, dsts, blk in branches:
        if cname not in ctors:
            raise TalError(...)
        covered.add(cname)
        ftys = ctors[cname]
        if len(dsts) != len(ftys):
            raise TalError(...)
        rt2 = dict(regty)
        for d, fty in zip(dsts, ftys):
            rt2[d] = fty
        _check_block(env, fn, blk, rt2)
    if default is not None:
        _check_block(env, fn, default, dict(regty))
    elif covered != set(order):
        raise TalError(f"{fn.name}: non-exhaustive tal case on {sty[1]}")
```

*Target sketch* — the missing typed vocabulary first (this IS slice (a); every
construct modeled on cited exemplars):

```lisp
; tal types as data — variant decl: Asm, asm-reloc.chiral:12
(data TalTy ()
  (tt-i64) (tt-str) (tt-bytes)
  (tt-data (dname Str) (targs (List TalTy))))

; structural equality — recursion shape: nb-beq-go's compare-then-recurse
; (bytes-tal.chiral:51), with the list walk of append (collections.chiral:15)
(declare talty-eq (-> TalTy TalTy Bool))            ; declare: emit-core.chiral:56

; a signature, and the checker env — single-ctor record: EmitR, emit-core.chiral:54
(data TSig () (tsig (doms (List TalTy)) (ret TalTy)))
(data TalCEnv ()
  (talcenv (fn-sigs (List (Pair Str TSig)))         ; alists: collections.chiral:61
           (prim-sigs (List (Pair Str TSig)))
           (datas (List (Pair Str DataShape)))))    ; DataShape: ctor tag -> field tys

; the register file: I64-keyed alist, flow-sensitivity is persistence
;   (alist-put I64 TalTy =i regty dst tt-i64)

; check results carry the alarm as data (the checker is consulted by lower_all,
; which must SKIP, not die) — Either-shape modeled on Maybe, prelude.chiral:13
(data ChkR ()
  (chk-err (msg Str))
  (chk-ok (regty (List (Pair I64 TalTy)))))
```

The `_check_block` port is one `case` per `TInstr` constructor — the identical
dispatch shape as `emit-instr` (`emit-core.chiral:29–44`) — threading `regty`
forward and returning `ChkR`. Branch checking passes the *same* `regty` value
into each branch (persistent alist = Python's `dict(regty)` copy for free) and
the coverage check compares the covered tag list against the declaration's tag
count with `length` (`collections.chiral:9`).

The interpreter port: values as a sum —

```lisp
(data TalVal ()                                     ; data decl: TInstr, tal-ir.chiral:19
  (tv-i64 (n I64))
  (tv-bytes (b Bytes))                              ; functional cells: bput = copy, see recipe
  (tv-con (tag I64) (fields (List TalVal))))
```

registers as `(List (Pair I64 TalVal))`; `bput` implemented with the existing
prims `(bcat (bslice b 0 i) (bcat one-byte (bslice b (+ i 1) (blen b))))` —
every prim cited from `prelude.chiral:46–55`. `ti-sys`/`ti-bptr`: refuse with
`halt` (`asm-reloc.chiral:52` shape) — the reference machine covers the pure
fragment; sysface execution is the native drop's alone.

*Mechanical recipe.*
1. NEW (small, the gate for E16/E17): slice (a) — `TalTy`, `talty-eq`, `TSig`,
   `TalCEnv`, `DataShape`, plus typed headers for hand-authored libraries so
   `LIB_SIGS` (`native.py:69–97`) can eventually retire. ~60 lines of decls +
   one structural equality. This is the family's single most unblocking
   artifact.
2. COPY: the per-instruction typing rules (`tal.py:93–158`) — one case branch
   per `TInstr` constructor; the rules are representation-independent
   (const-value/type agreement, arg checking, dst assignment, sysface marking
   → a `Bool` field threaded in `ChkR` or a per-fn summary).
3. TRANSLATE (rule: `raise TalError(msg)` → `(chk-err msg)` propagated by
   casing; the *caller* decides skip-vs-halt): the whole checker. Error
   messages compose with `str-cat`/`i64->str` (`mach-listing.chiral:16–18` shows
   the idiom at length).
4. TRANSLATE (rule: dict regty → persistent I64 alist; `dict(regty)` copies →
   plain reuse): `_check_block`'s branch discipline.
5. TRANSLATE (rule: cname strings → tag numbers per `tal-ir.chiral:9–11`):
   branch identity and coverage.
6. COPY: the interpreter's pure-fragment dispatch (`tal.py:229–261`) into the
   `TalVal` world.
7. TRANSLATE (rule: bytearray mutation → functional byte-cell update via
   bslice/bcat): `bnew/bget/bput/blen`. State the O(n)-per-write cost in the
   header comment; it is a *reference* machine.
8. NEW (decision, small): the sys-face refusal — check `sysface` and halt with
   a message naming the native drop as the executor. Document that this is the
   membrane, not a gap.
9. NEW (add while here): enforce single-assignment in the chirality checker
   (reject a second definition of a register) — one `alist-has` test per dst
   (`collections.chiral:86`). This closes footer item 2 structurally and the
   Python checker should gain the same rule when touched.

**Dependencies:** none upstream (slice (a) is self-contained over
prelude/collections). Unblocks E17 (preserve-check in chirality), E16 (typed
vocabulary), and the `LIB_SIGS`/reverse-shuttle retirement (flagged E51
candidate below).

**Est. pass size:** L — slices: (a) typed vocabulary + `talty-eq` + typed lib
headers (S); (b) checker (M — the biggest single chunk, ~100 dense Python
lines); (c) pure-fragment interpreter with functional cells (M); (d) sys-face
refusal + single-assignment rule + differential test vs Python checker on the
whole lowered demo (S).

---

## E19 — x86-64 codegen: encoding, SysV assignment, relocation, Mach interface   [ALREADY CHIRALITY · Tier R (SPEC: Intel SDM, psABI) + F (encoder cross-checks)]

**Lives now (verified by listing `scaffold/lib/`):**
- `lib/asm-reloc.chiral` (86 lines) — `Asm` chunk type (`:12–19`), two-pass
  place/materialize assembler (`:37–75`), `assemble` (`:78–82`).
- `lib/mach.chiral` (94) — the frozen `Mach` contract: one 22-field record
  (`:26–49`) + one projection def per field (`:51–94`).
- `lib/mach-x64.chiral` (321) — all ISA knowledge: byte combinators (`:14–20`),
  slot/frame discipline (`:23–30`), encodings, Euclidean div/mod fix
  (`:76–109`), heap face (`:130–193`), byte cells (`:195–251`), sys face
  (`:253–290`), the conforming `x64` value (`:293–321`).
- `lib/mach-listing.chiral` (74) — the second conforming Mach (proof of
  target-independence).
- `lib/emit-core.chiral` (139) — target-independent codegen over `Mach` +
  `tal-ir`.
- `lib/emit-x64.chiral` (10) — wiring only.
- `lib/tal-ir.chiral` (49) — the IR data (audited under E18).
- Host residue (E20/E23's problem, not E19's): `native.py:346–454`
  (`NativeBackend`: loader mmap/W^X/mprotect, arena pointer poke, CFUNCTYPE
  trampoline) and the shuttle `native.py:151–246` (`tal_to_tfn`).
- Tests: `tests/test_native.py` (differential vs TalMachine, whole demo),
  `tests/test_backend.py` (two machines, one codegen; `emit-core` greps clean
  of ISA tokens, `:64–69`).

**Verdict:** PROPER — this is the exemplar the other families copy. Two small
hardening findings (not REDO): (1) **>6-arg silent miscodegen**: `arg-modrm`
(`mach-x64.chiral:53–59`) falls through to `141` for any `i ≥ 5`, so argument 6
(index 6) would encode as r9 and silently collide with argument index 5 —
nothing guards arity anywhere on the path (`tal_to_tfn` doesn't either). No
current function exceeds 6 params (`nb-copy`/`nb-rep-go` peak at 5), but the
failure mode is silent wrong code, the exact class `op-bytes` refuses loudly
(`:122` halts on an unknown op). Fix: `halt` in `arg-modrm`/`x-store-arg` for
`i > 5`, mirroring `op-bytes`. (2) **Stale doc line**: `native.py:24–26` still
says "native / and % truncate (host floors)" — falsified by `x-div-fix`/
`x-mod-fix` (`mach-x64.chiral:76–109`) and pinned Euclidean by
`test_optimize.py:47`; one-line docstring fix.

**Explainer — what made this port/authorship mechanical (the template).** The
file set decomposes along conformance seams so no file ever needed more than one
kind of knowledge: `tal-ir` mirrors the Python IR shape (its header says so:
"This mirrors the executable subset of scaffold/chirality/tal.py",
`tal-ir.chiral:2`), `emit-core` knows control flow but zero ISA (grep-enforced
by a test), `mach` freezes the contract, `mach-x64` knows only encodings, and
`asm-reloc` knows only offsets — P4 as file layout. The Euclidean-div encoding
detail worth naming: `b8` splits a 64-bit immediate as
`(bcat (pack-u32 v) (pack-u32 (/ v 4294967296)))` (`mach-x64.chiral:17–18`) and
is *correct for negative v only because `/` is Euclidean* — truncating division
would mis-encode every negative movabs immediate. Settled-decision dividends
show up as working code here; don't relitigate. The remaining Python around
E19 is deliberately not codegen: the loader (mmap→write→mprotect R+X, arena
poke) and the ctypes trampoline are E20/E23/E28 catalog rows.

**The conventions it established (the port template for every family):**

1. **Python tagged tuple → `data` constructor, types added, names kebabed with
   a module prefix.** `("const", dst, ty, val)` → `(ti-const (dst I64) (val
   I64))` (`tal-ir.chiral:20`) — note the *type is dropped or represented, never
   implicit*; prefixes namespace the flat global scope (`ti-`/`t-` tal IR,
   `a-` asm chunks, `x-` x64 encodings, `nb-` native byte lib, `mach-`
   projections, `emit-` codegen).
2. **Python `None`/optional → `Maybe`; 2-tuples → `Pair`, nested for wider
   records** — a branch is `((tag, binds), code)` "as nested pairs"
   (`tal-ir.chiral:39–46`).
3. **Records = single-constructor `data` + one projection def per field via an
   exhaustive one-branch case** (`mach.chiral:51–94`). Verbose but mechanical;
   22 fields were tolerable.
4. **Dicts → alists with a caller-supplied equality** (`place`/`resolve`,
   `asm-reloc.chiral:37–52`, over `alist-put`/`alist-get`,
   `collections.chiral:61–84`).
5. **Mutation → threaded state records**: the fresh-label counter rides in
   `EmitR (asm, next)` (`emit-core.chiral:54`) and is threaded through every
   recursive call — the single most reused idiom for porting Python
   `self.x += 1`.
6. **Exceptions → `halt` for genuinely fatal, data for recoverable**: unknown
   label (`asm-reloc.chiral:52`), wrong-size encoder (`:60`), unknown op
   (`mach-x64.chiral:122`) halt; anything a caller handles returns
   `Maybe`/tagged data.
7. **Dict-dispatch → nested `str-eq`/`=i` case chains** (`op-bytes`,
   `arg-modrm`); loops → recursion with an index parameter (`emit-args`,
   `x-sysargs`); byte building → `b1/b2/b4/b8` + `bcat`/`bc3` combinators over
   `pack-u32`.
8. **Forward `(declare name type)` for use-before-def recursion**
   (`emit-code`, `emit-core.chiral:56`); `(the T expr)` at `nil` and other
   inference-poor positions.
9. **One Python function : one chirality def, same name** where a Python original
   exists (`tal-ir` ↔ `tal.py`'s instruction set is the worked case) — the
   *mirror is auditable by reading the two files side by side*, which is the
   real reason the port stayed mechanical.
10. **Prove modularity with a second conformer**: `mach-listing` exists to make
    target-independence a test (`test_backend.py:64–93`), not a claim. Port
    passes should budget the cheap second instance when a contract is claimed.

**Translation dossier:** not applicable in the port direction — E19 *is* the
target. The remaining work is the two hardening items above (recipe: NEW, ~10
lines: `halt` guard in `arg-modrm`/`sys-modrm` beyond their register banks;
one-line docstring fix in `native.py`). Encoder cross-checks against nasm/LLVM
MC remain licensed by Tier F with the Intel SDM as authority.

**Dependencies:** none; done. What *depends on it*: every family's dossier
should copy conventions 1–10; E18 slice (a) extends `tal-ir` in its style.

**Est. pass size:** S (hardening only).

---

## Family footer

### Redo list (ranked by downstream poison)

1. **tal-ir type erasure / `LIB_SIGS` Python residue** (E18, scars visible at
   `native.py:69–97` and `tfn_to_tal`'s Bool-only hardcoding
   `native.py:263–313`). Not a REDO of built code — the erasure was a sound
   milestone choice — but it is the one representation decision that *blocks*
   self-hosting E16–E18 and forces every hand-authored tal library to keep a
   Python-side type table. Fix = E18 slice (a) (`TalTy`/`TSig` in chirality, typed
   library headers). Everything else in the family queues behind it.
2. **Unstated single-assignment invariant** (E17×E18). `optimize._fold_block`
   keeps stale `cenv` facts across a redefining `const STR/BYTES` or fielded
   `con` (`optimize.py:97–101`, `:114–118` — no pop), and `tal.check_fn` lets
   `regty[dst]` be silently overwritten. Sound today only because
   `Low.fresh()` (`lower.py:116`) is monotonic. Latent miscompile class if any
   future pass or hand-authored TFn reuses a register. Fix cheaply twice:
   pop-on-every-def in fold; reject-redefinition in the checker (Python now,
   chirality port by construction — recipe step 9 of E18).
3. **>6-arg silent miscodegen** (E19). `arg-modrm` (`mach-x64.chiral:53–59`)
   aliases arg index ≥5 onto r9 with no guard anywhere on the path. Currently
   unreachable (max arity in tree is 5) but the failure is silent wrong machine
   code. Fix: `halt` past the register bank, mirroring `op-bytes`
   (`mach-x64.chiral:122`); optionally also refuse in `lower_all`.
4. **Stale floor claim in `native.py:24–26`** ("native / and % truncate") —
   contradicts the built Euclidean correction and the settled decision;
   doc-rot in the exact place a future porter will read first. One line.

### Ordering (dependency-respecting)

1. **E19 hardening** (S; independent, do alongside anything).
2. **E18 slice (a)** — typed tal vocabulary in chirality (S; unblocks everything).
3. **E18 slice (b)** — the chirality tal checker (M).
4. **E17** — optimizer port (M; needs (a)+(b) for the preserve-check; no
   kernel dependency — the family's first full self-host win after E19).
5. **E18 slices (c)+(d)** — pure-fragment reference machine + sys-face refusal
   (M; can interleave with E17).
6. **E16** — lowering port (L, 3 slices; gated on family 1's E3/E13 —
   `data_fields`/`_peel` call real kernel eval).
7. **E15** — reference interpreter port (M; gated on family 1's E13/E2;
   last because it is the golden oracle — keep the Python one authoritative
   until the chirality one differentially matches it everywhere).

### Cross-family flags

- **To family 1 (E13/E2/E3):** E15 and E16 are *hard-gated* on Term, Sig, and
  kernel-eval (`eval_term`/`close_apply`/`uses_below`) existing as chirality data +
  defs. When family 1 designs Term-as-data, it should copy the `TInstr`
  conventions (`tal-ir.chiral:19`) — one `data`, one constructor per node kind,
  tag numbers where names don't need to survive. Coordinate before either
  family sketches the Term decl twice.
- **To E20/E23/E28 (substrate):** `native.py`'s loader (mmap/W^X/mprotect,
  arena poke at `:404–421`), `alloc_bytes` marshalling (`:433–448`), `decode`
  (`:321–341`), and the `CFUNCTYPE` trampoline (`:426`) are the pipeline's host
  residue — none of it is E15–E19 work; do not let a pipeline pass absorb it.
- **Candidate E51 — "retire the shuttle":** once E18 slice (a) lands and
  hand-authored libraries carry chirality-side `TSig`s, `native.py`'s
  `tal_to_tfn`/`tfn_to_tal` + `LIB_SIGS` (`:69–97`, `:151–316`) become dead
  weight whose deletion is a milestone in itself (the compile path becomes
  chirality end-to-end from tal). No current catalog element owns that deletion.
- **Candidate E52 — "IR well-formedness":** single-assignment (redo item 2) is
  an IR invariant no element owns; cheapest home is the E18 checker, but if a
  future SSA/reg-alloc pass (E16's Tier-F reading) arrives, it should be stated
  once as a checked property, not re-discovered.
- **To whoever audits family 6 (E38 cost):** `optimize.py:18–24`'s honest
  boundary ("meaning-preserving only, no graded-cost claim") is the exact seam
  Fork A's semiring enrichment will type; the fixpoint-by-size loop
  (`optimize.py:280–289`) is where a cost measure would first attach.
