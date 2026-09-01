> **Tracked row: `FD-03` in `records/findings.md`.** That row is what survives a fresh clone; this file is the long-form measurement and stays because `USER-LAYER-GAP.md` §10 still carries the refuted table.

# FINDING — do captured closures in records lower?

**Stage `P1a` of `.planning/USER-LAYER-TRACKER.md`. Measurement run, 2026-08-30.
Compiler: `scaffold/build/B1` (`bin/chirality-resolve.sh` → `chirality_blob_file` → B1).
Fixtures: `scaffold/tests/samples/_wip/p1a-*.chiral` (39), all committed-tree
sources, nothing under `scaffold/lib/` touched.**

---

## §0 · The question, and the answer

> Can a chirality `data` record hold a function field whose value is a CLOSURE THAT
> CAPTURED something — and can that closure be applied after being pulled back
> out of the record — such that the whole thing LOWERS?

**YES. It lowers, it runs, and it is expressible today with a one-token change to
the fixture that was read as a refusal.**

⚑ **The premise the `P1a` brief was dispatched on is wrong.** The `k≥1` refusals
recorded in `USER-LAYER-GAP.md` §10 are **not about capture**. The discriminator
is purely syntactic: a **bare `(lam …)` written directly in a data-constructor
argument position** is never registered as a closure-conversion site. Everything
else — a named global, a partial application, a call that *returns* a function, or
the same bare lambda wrapped in `(the (-> …) …)` — is registered and lowers,
**with or without captures**.

Three measurements make this unambiguous:

| | capture? | shape of the fn-field argument | result |
|---|---|---|---|
| `p1a-01` | **no** | bare `(lam (x) (+ x 1))` in ctor position | **REFUSED** |
| `p1a-14` | **yes** | `(the (-> I64 I64) (lam (x) (+ x k)))`, same position | **lowered, ran, exit 0** |
| `p1a-11` | **yes** | `(mk-adder k)` — a call returning a closure | **lowered, ran, exit 0** |

`p1a-01` has zero captures and is refused. `p1a-14` captures `k` and passes. So
"captured closures do not lower" is falsified in both directions by a single pair
of fixtures.

**`flag2.chiral` — the fixture that produced the "REFUSED" row — is repaired by two
mechanical edits and then compiles and runs (`p1a-38`, exit 0, mutant 255):**
1. wrap each constructor-position lambda in `(the (-> I64 I64) …)`;
2. give the projector global `voc-draw` a **full binder chain** — `(lam (v x) …)`
   for the type `(-> Voc (-> I64 I64))`, not `(lam (v) …)`.

Neither edit changes what the program *means*. Both are load-bearing for
lowering, and both are recorded below with the pass that requires them.

---

## §1 · What was measured

Every row below was compiled with `B1 < blob > elf`; `rc` is B1's exit and the
text is B1's exact stderr. Rows marked *ran* were executed; each was
**mutant-checked** (perturb the expected constant → the run must exit non-zero),
so `exit 0` is a live assertion, not a vacuous one. Mutants confirmed for
`p1a-14/18/19/24/27/28/36/37/38/39` (all returned 255).

### §1.1 · Reproduction of the three prior results — all three reproduce exactly

| Fixture | rc | B1 stderr |
|---|---|---|
| `flag2-k0.chiral` | 0 | *(none)* — **ran, exit 0** |
| `flag2-ctl.chiral` | 1 | `no emitted label for entry compile-main \| skip chain for compile-main: compile-main: extern does not lower: higher-order application` |
| `flag2.chiral` | 1 | `… skip chain for compile-main: compile-main <- mk-a: extern does not lower: lambda stays upper` |

### §1.2 · The boundary — what the refusal actually tracks

| # | Shape | rc | B1 stderr / run |
|---|---|---|---|
| `p1a-01` | **no capture**, bare `(lam (x) (+ x 1))` in ctor arg, consumed across a fn boundary | 1 | `compile-main: extern does not lower: higher-order application` |
| `p1a-02` | capture, built **and** consumed in the SAME function | 1 | `compile-main: extern does not lower: lambda stays upper` |
| `p1a-03` | capture, ONE instance (not three), across a boundary | 1 | `… higher-order application` |
| `p1a-04` | capture, field arrow `=>` instead of `->` | 1 | `… higher-order application` |
| `p1a-05` | capture, arity-2 field `(-> I64 I64 I64)` | 1 | `… higher-order application` |
| `p1a-06` | capture, consumed through a named `use` helper | 1 | `compile-main <- mk-a: … lambda stays upper` |
| `p1a-07` | **named global** in ctor arg, record built inside a `lam` | 0 | **ran, exit 0** |
| `p1a-08` | capturing lam `let`-bound first, then stored | 1 | `load: cannot infer an un-annotated lambda` *(elaborator, not lowering)* |
| `p1a-09` | capturing closure, **no record at all** (`((mk-adder 1) 10)`) | 0 | **ran, exit 0** |
| `p1a-10` | **partial application** of a curried global `(addk k)` in ctor arg | 0 | **ran, exit 0** |
| `p1a-11` | closure returned by a named global `(mk-adder k)` in ctor arg | 0 | **ran, exit 0** |
| `p1a-12` | bare lam as a **function argument** (classic HOF), no record | 0 | **ran, exit 0** |
| `p1a-13` | **capturing** bare lam as a function argument, no record | 0 | **ran, exit 0** |
| `p1a-14` | **`(the (-> I64 I64) (lam (x) (+ x k)))` in ctor arg** | 0 | **ran, exit 0** |
| `p1a-15` | same, no capture | 0 | **ran, exit 0** |
| `p1a-18` | **three** capturing `the`-lam instances, inline `case` — `flag2-ctl` repaired | 0 | **ran, exit 0** |
| `p1a-19` | same, consumed through a named `use` helper | 0 | **ran, exit 0** |
| `p1a-24` | **buffer-as-object**: a record of THREE closures all capturing one `Doc`, three accessor globals, applied across boundaries | 0 | **ran, exit 0** |
| `p1a-27` | TWO `cs-lam` sites on the SAME arrow family, dispatched at runtime | 0 | **ran, exit 0** |
| `p1a-28` | the capture is a **`Str`** (a real payload), not an `I64` | 0 | **ran, exit 0** |
| `p1a-36` | **two different payload types** (`Str`-backed, `I64`-backed) in ONE homogeneous `(List Buf)`, iterated by one loop | 0 | **ran, exit 0** |
| `p1a-37` | **effectful** `(=> I64 I64)` field with a capture — the live `ScribaOp` shape | 0 | **ran, exit 0** |
| `p1a-39` | extracted closure `let`-bound to `f`, then applied twice | 0 | **ran, exit 0** |

The `p1a-01` vs `p1a-14`/`p1a-15` pair is the whole finding: identical programs,
identical capture status, differing only by `(the (-> I64 I64) …)`.

### §1.3 · The second, independent limitation — the closure-returning projector

Separate from the above, and the reason `flag2.chiral`'s error differed from
`flag2-ctl.chiral`'s:

| # | Shape | rc | B1 stderr / run |
|---|---|---|---|
| `p1a-16` | 3 capturing instances via `(mk-adder k)` **+ projector global** `voc-draw : (-> Voc (-> I64 I64))` with body `(lam (v) …)` | 1 | `compile-main <- voc-draw: extern does not lower: body is not a lambda chain` |
| `p1a-17` | same via partial application | 1 | `… body is not a lambda chain` |
| `p1a-21` | ONE capturing `the`-lam + that projector | 1 | `… body is not a lambda chain` |
| `p1a-22` | `the`-lam with **no capture** + that projector | 1 | `… body is not a lambda chain` |
| `p1a-23` | partial-app site + that projector | 1 | `… body is not a lambda chain` |
| `p1a-25` | **named global**, record built in a fn, + that projector | 1 | `… body is not a lambda chain` |
| `p1a-26` | named global, record built **inline at the call site**, + that projector | 1 | `… body is not a lambda chain` |
| `p1a-31` | projector eta-expanded as `(lam (v) (the (-> I64 I64) (lam (y) …)))` | 1 | `compile-main <- voc-draw: extern does not lower: higher-order application` |
| `p1a-32` | same, with a capturing site | 1 | `… higher-order application` |
| **`p1a-33`** | **projector written as `(lam (v y) …)` — a full binder chain** | **0** | **ran, exit 0** |
| **`p1a-38`** | **`flag2.chiral` repaired: 3 capturing `the`-lams + `(lam (v x) …)` projector** | **0** | **ran, exit 0** |

### §1.4 · The three "projector works" outliers, explained

`p1a-20`, `p1a-30`, `p1a-34` all pass with a one-lam projector. They are **not**
counter-examples to §1.3 — they are the `specialize-singletons` pass firing, and
they stop passing the moment a second instance exists:

| # | Shape | rc | result |
|---|---|---|---|
| `p1a-20` | one-lam projector, **one** top-level `Voc` constant `va` | 0 | ran, exit 0 |
| `p1a-30` | same + an unused def | 0 | ran, exit 0 |
| `p1a-34` | same, argument routed through an opaque `idv` | 0 | ran, exit 0 |
| `p1a-29` | `va` defined **and** a second inline `(voc add1 1)` at the call site | 1 | `… body is not a lambda chain` |
| `p1a-35` | **two** `Voc` constants (`va`, `vb`) | 1 | `… body is not a lambda chain` |

`specialize-singleton.chiral:65-95` is the authority: `find-con-global` matches only
a global whose **whole body** is a bare `(t-con …)` (so `va` qualifies; `mk-a`,
whose body is a `t-lam`, never does), and `find-singleton` then requires
`count-inline == 1` — *"a fn-bearing type built >1 time returns `none` here"*. All
five rows follow exactly. This is a **measurement trap worth recording**: the
"dictionary shape works" reading is an artifact of a one-instance fixture, and the
pass is documented as being deliberately hard-capped at one instance.

⚑ It also means `flag2-k0.chiral`'s pass is **genuine closure conversion**, not the
specializer: it builds three `Voc` constants, so `count-inline == 3` and
`specialize-singletons` is inert for it. The k=0 row in §10 is sound.

---

## §2 · Which pass refuses, and why

### §2.1 · The bare-lambda-in-constructor refusal — `closconv.chiral:791`

Closure conversion walks a term with an **expected type** so it can recognise an
escaping lambda literal. `lam-lit` (`closconv.chiral:743-752`) accepts a lambda as
a closure site in exactly two cases:

* `(c-ann (c-lam …) ty)` where `ty` is an arrow — accepted **regardless of the
  expected type**; or
* a bare `(c-lam …)` — accepted **only if the expected type is `(some arrow)`**.

The application path threads expected types properly. `cwalk-app`
(`closconv.chiral:805-812`) computes `(callee-doms sig ctx (app-head t) nargs)` and
hands it to both `scan-fvargs` and `cwalk-args` — which is why a bare lambda as a
*function argument* is a site (`p1a-12`, `p1a-13` both pass).

The constructor path does not. `cwalk-struct`'s `c-con` arm is one line:

```
; closconv.chiral:791
((c-con h nm as)     (cwalk-list sig (scan-fvargs sig st ctx none as) ctx as))
```

Two `none`s do the damage:

* `scan-fvargs … ctx **none** as` → `fv-site` runs with `slot = none`, so it falls
  through to `fv-own`, which types the argument by **its own** type. A
  `(c-global add1)` still resolves to `(-> I64 I64)` and *is* registered as a
  nullary `cs-g` site — **this is exactly why the k=0 named-global shape works**
  (`flag2-k0`, `p1a-07`).
* `cwalk-list … ctx as` → `cwalk sig st ctx **none** x` for every argument, so
  `lam-lit` sees `expected = none` and returns `none` for a bare `c-lam`. The
  lambda is **never registered as a closure site**.

Downstream, that single omission produces both observed messages:

* the un-rewritten `c-lam` survives into the lowerer and hits
  `lower.chiral:248` → `er-skip "lambda stays upper"` (when the constructor's
  enclosing def is what gets walked first — `flag2`, `p1a-02`, `p1a-06`);
* or the family for that arrow has **zero sites**, so `keep-fams`
  (`closconv-driver.chiral:104-113`) drops it, the `(d 10)` var-head application in
  the consuming `case` arm is never rewritten to `$apply`, and it hits
  `lower.chiral:280` → `er-skip "higher-order application"` (`flag2-ctl`,
  `p1a-01`, `p1a-03/04/05`).

Which of the two you see is an artifact of walk order, not of a different defect.

**The information needed to fix it is already in the `SigV`.** The driver builds a
ctor-name → field-types map (`d-datas->ctors`, `closconv-driver.chiral:84-91`) and
`sv-ctor-fields` (`closconv.chiral:902-907`) looks up a ctor's field types by
name — but that map is consumed **only** by `arm-ctx` (`:913-917`), the *case-arm*
side. The *construction* side never asks. The fix is to make `:791` symmetric with
`:805-812`: resolve `(sv-ctor-fields (sv-ctors sig) nm)` and thread it as the
expected-type list into `scan-fvargs` and a `cwalk-args`-style walk instead of
`none`/`cwalk-list`.

### §2.2 · The projector refusal — `closconv.chiral:590` + `lower.chiral:404`

`def-ctx` (`closconv.chiral:582-596`) opens a def with

```
(peel-lam-exact (cc-llen (peel-pi-doms ty)) body)
```

— the body's lambda chain must be **exactly as long as the type's arrow chain**.
`voc-draw : (-> Voc (-> I64 I64))` peels to **two** domains, but its body
`(lam (v) (case v ((voc d n) d)))` is **one** lambda, so `peel-lam-exact` returns
`none` and `def-ctx` returns `none`. Consequences:

* `collect-defs` (`:922-928`) **skips the def entirely** — its body is never walked
  for closure sites;
* `rewrite-one` (`closconv-driver.chiral:218-227`) returns the def **unchanged** on
  a `none` `def-ctx`, so its type is never rewritten (`(-> I64 I64)` never becomes
  the `$cloN` TCon);
* the lowerer therefore builds two binders from the type, `strip-lams body 2`
  fails, and `lower.chiral:404` fires `le-skip "body is not a lambda chain"`.

`p1a-31`/`p1a-32` show the eta-expansion must be at the **def binder** level: a
nested `(the (-> …) (lam (y) …))` inside the outer lambda still fails
`peel-lam-exact` (the `c-ann` node interrupts the chain) and degrades to
`higher-order application`.

This is a **pre-existing, capture-independent** limitation (`p1a-22` has no
captures and fails). It is not about returning closures per se — after
currying, `(-> Voc (-> I64 I64))` and `(-> Voc I64 I64)` are the same type, so the
rule reduces to: **write every binder your type declares.** `p1a-33`/`p1a-38`
confirm it costs one identifier.

---

## §3 · Does E147 cover this?

**E147 is BUILT (2026-08-16) and does NOT cover it. It is a different site in the
same file, one level down.**

`SELF-IMPLEMENT-CATALOG.md` row E147 — *"a captured FUNCTION value applied INSIDE
a `$apply` arm must itself route through `$apply`"* — fixed `arm-body`
(`closconv.chiral:1024-1055`) running the remapped arm body through `rw` with an
**empty** de-Bruijn context, by passing `(arm-rw-ctx fields)` = the kept field
types reversed. `kept-tys`/`arm-rw-ctx` are present in the tree at
`closconv.chiral:1043-1051` as the catalog describes, gated by
`scaffold/tests/samples/e147_nested_ho.chiral`.

E147 is about the **consumption** side of an *already-registered* site — giving
`rw` the capture types so a nested application whose head is a captured function
resolves and dispatches. The `:791` defect is on the **registration** side: with a
bare constructor-position lambda there is no site, no `$clo` ctor, no `fields`, and
so nothing for `arm-rw-ctx` to be a context *of*. E147's fix could not fire.

Notably, the two share a symptom (`higher-order application`) and a root pattern —
*a walk that lost a type context* — which is why they read as the same bug and are
not. E147 lost the **arm** context; this loses the **constructor-argument**
context.

---

## §4 · The `Flow`/`PureFn` hypothesis — REFUTED

> Hypothesis under test: chirality's orchestration engine defunctionalizes by hand
> into closed `PureFn`/`Flow` sums because stored capturing closures do not lower.

**The file says otherwise, in its own words.** `scaffold/lib/manas/core/flow.chiral:71-73`:

> "`PureFn` is the closed sum of the deterministic transforms a flow-pure step can
> carry — **a value (so the SG1 codec stays total; boundary-as-closed-sum,
> `docs/pattern-boundary-sums.md`), NOT an opaque closure.**"

The stated reason is **serialisability and codec totality**, not lowering. A `Flow`
has to round-trip through the SG1 persist codec; a closure has no representation to
encode, so a closed sum is required *whether or not* closures lower. It is also the
standing repo pattern (`feedback-boundary-sums`, `docs/pattern-boundary-sums.md`):
retype every boundary classification as a closed sum. The header's other stated
motive — `flow-ty : Flow -> (Maybe Arrow)`, a **pure compositional checker** that
must be total over every case — likewise requires an inspectable value, not an
opaque function.

There is no closure/lowering rationale anywhere in `scaffold/lib/manas/` (the only
`does not lower` notes there are about `map-list` in leaf blobs — `bind.chiral:48`,
`gate.chiral:111`, `assemble.chiral:17`, `manifest.chiral:189` — an unrelated issue).

**So the corroborating evidence in `USER-LAYER-GAP.md` §10 should be withdrawn.**
`Flow` is a closed sum for persistence and checkability. It says nothing about
whether captured closures lower, and the measurements in §1 say they do.

⚑ But the withdrawal is not free: `Flow`'s reason **also applies to `Buf`** if a
buffer list ever has to be persisted, inspected, or checked as a value. That is a
real design constraint on D-U7 option (b) — just a different one than was recorded,
and one the lane can decide on purpose rather than inherit from a miscompile.

---

## §5 · What would have to change for D-U7 option (b) to be expressible

**Nothing.** It is expressible today. `p1a-24` is buffer-as-object (a record of
three closures over one captured document, three accessor globals, applied across
function boundaries); `p1a-36` is the additivity shape (two different payload types
in one homogeneous `(List Buf)`, one loop); `p1a-37` is the effectful-field shape
that matches live `ScribaOp`. All three lower, run, and fail their mutants.

The cost is **two conventions**, both one token, both stateable in a module header:

1. **Every closure stored in a constructor field is written
   `(the <its arrow type> (lam …))`.** Bare `(lam …)` in constructor-argument
   position is not registered as a closure site (§2.1). *(A named global, a partial
   application, or any call that returns the closure also works — the annotation is
   only needed for a literal lambda.)*
2. **Every def whose declared type has N arrows binds N parameters.** A
   closure-returning accessor `(-> Buf (-> I64 I64))` must be written
   `(lam (b x) …)`, not `(lam (b) …)` (§2.2). In practice the natural accessor
   (`(-> Buf I64 I64)`, applying the closure inside) already satisfies this —
   `p1a-24`'s three accessors do.

Both are conventions the compiler *should not* need, and both are cheap, bounded
fixes if the lane would rather push the invariant into the substrate than the
style guide:

* **Fix A (`closconv.chiral:791`, ~1 line + a helper).** Thread the ctor's field
  types as expected types into the constructor-argument walk, exactly as
  `cwalk-app` already does for callee domains. `sv-ctor-fields` (`:902`) and the
  `SigV` ctor map (`closconv-driver.chiral:84-91`) already exist and are already
  built for every data decl — only the construction side fails to consult them.
  This makes convention 1 unnecessary. **It is not a design question; it is an
  asymmetry between two arms of the same `case`.**
* **Fix B (`closconv.chiral:590`).** Accept a body whose lambda chain is *shorter*
  than its type's arrow chain by eta-expanding it during `def-ctx`. Strictly
  larger than Fix A and touches every def, so it is a real change with real
  regression surface — convention 2 is the cheaper answer for now.

Neither is proposed here; this run measures only. If the lane wants Fix A, it needs
a catalog row minted before it is named as a dep (deferral rule).

---

## §6 · Consequences for `.planning/USER-LAYER-GAP.md` §10

*(Not applied — this run's write surface is this file plus `scaffold/tests/samples/_wip/` only.)*

The three-row table under D-U7 and the `⚑⚑ STATUS 2026-08-30` block are wrong on
their central claim and should be replaced. Specifically:

* **"k≥1, real capture → REFUSED"** — the refusal is real for the fixture but is
  caused by the *bare lambda*, not by k≥1. `p1a-14`/`p1a-18`/`p1a-24` are k≥1 and
  pass. The row as written reads as a language limitation and is not one.
* **"the live evidence cited for it (`RendererFn` ×3, `ScribaOp` ×31) is all k=0
  … so 'proven expressible today' was proven for the wrong shape"** — the *premise*
  is correct (those really are k=0) but the *conclusion* does not follow: k≥1 is
  independently measured to work. The original claim was under-evidenced but true.
* **"chirality's own orchestration engine defunctionalizes by hand … which is what one
  builds when captured closures in records do not lower"** — refuted at source, §4.
* **"the falsifier is minimal and may be malformed"** — this caveat was correct and
  is now discharged: it *was* malformed, in one specific way.
* **The dictionary-shape / one-instance cap claim survives and is now measured**
  (`p1a-20` vs `p1a-35`): the projector-global shape works at one instance and
  fails at two, exactly as `specialize-singleton.chiral:78-95` documents.
* **`flag2-k0`'s pass is genuine closconv**, not the specializer (three instances →
  `count-inline == 3` → the pass is inert). That row stands.

**Options (a)/(c)/(d) are not reached.** The brief asked which of them the evidence
favours *if* (b) is inexpressible; (b) is expressible, so the fallback question is
moot. For the record, nothing measured here weakens (b) relative to them, and
`p1a-36` is the direct positive evidence for the additivity property (b) was chosen
for. The one genuine constraint this run *adds* to (b) is the `Flow` rationale in
§4: a record of closures cannot be persisted or structurally inspected, so if the
buffer list ever needs a codec or a compositional checker, that — not lowering — is
the argument that would push toward (a).

⚑ **The `P1` additivity gate stays armed and is unaffected.** It fires on the
*second* document type touching a shared sum. `p1a-36` shows two payload types
coexisting with no shared sum at the fixture scale; it does not pre-empt the gate at
the real scale.

---

## §7 · Fixtures

All under `scaffold/tests/samples/_wip/`, none committed by this run.
`flag1*.chiral`, `flag2*.chiral` pre-existed; `p1a-01`…`p1a-39` are this run's.

The load-bearing four, if only four are kept:

| Fixture | Proves |
|---|---|
| `p1a-01-nocap-inline.chiral` | the refusal is not about capture (no capture, refused) |
| `p1a-14-the-annotated-lam.chiral` | the refusal is about the bare lambda (capture + `the`, passes) |
| `p1a-24-buffer-as-object.chiral` | D-U7 (b) itself: a record of closures over one captured document |
| `p1a-36-heterogeneous-buffer-list.chiral` | the additivity property: two payload types, one list, one loop |

Plus `p1a-38-projector-full-chain-capture.chiral` — `flag2.chiral` repaired — as the
direct rebuttal to the row that blocked the lane.
