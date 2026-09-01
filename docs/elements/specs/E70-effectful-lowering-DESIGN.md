# E70 — effectful lowering, drawn out (worked examples + implementation notes)

Companion to `E70-effectful-lowering-SPEC.md` (the contract) and the example
(the rationale). Works the row shadow + the re-derivation check through on the
*actual* substrate — which corrects a simplification the example carried.

## 0. The finding that reshapes the picture (verified 2026-08-02)

There are **two different rows**, and the example's "shadow = `{fd-write}`"
quietly conflated them:

| object | what it holds | for `inc = (lam (n) (+ n 1))` | who reads it |
|---|---|---|---|
| the Pi **seat** row (in the *type*) | EFFECTFUL crossings only | **empty** (`inc` is pure `->`) | the membrane / the `=>` gate (`lower.py:298`, via `Seats.__bool__`) |
| **`sig.def_rows[name]`** | the monotone call-graph closure of **every** crossing reached — pure prims *by their own name* included | **`{'+'}`** | the E51/E70 **shadow** artifact |

Verified: `def_rows[inc] = {'+'}`, `def_rows[twice] = {'+'}` (transitive), yet
`inc`'s Pi seat is empty; no prelude prim is a `prim_is_port`. So:

- **The shadow E70 carries down and checks is `def_rows`, not the seat.** It
  contains pure prims (`+`, `bget`, …) *and* effectful crossings. The example's
  `{fd-write}` was the effectful *projection* of a real, broader shadow.
- The check "reachable ⊆ declared" therefore catches a lowering/optimizer bug
  that makes the body reach **any** unexpected extern — not only a syscall.
- **`sysface` = `def_rows ∩ sys-crossings`** — the effectful projection, exactly
  the one-bit prototype generalized.
- Opening the `=>` gate (the seat) and carrying/checking the shadow (`def_rows`)
  are **two separate mechanisms** that happen to land together in E70.

`def_rows` is built by `surface._infer_row` (the monotone closure; deterministic
via `row_of`'s sort). `row.py` gives `row_subsumes` (the ⊆ test) and `row_union`
(the merge) — reuse both; E70 re-derives the *reachable* side and compares.

## 1. Worked example A — a pure function (the invariant that must not regress)

`inc = (lam (n) (+ n 1))`, `def_rows[inc] = {'+'}`, Pi seat empty.

Lowered body (tal): `... ("prim", d, "+", [n, one], I64) ; ("ret", d)`.

Re-derivation from the tal body: the one `prim` op contributes its opname `'+'`
→ **reachable = {'+'}**. Declared = `def_rows[inc] = {'+'}`. `{'+'} ⊆ {'+'}` →
`row-ok`. The pure case is not special-cased; it falls out because `def_rows`
already names the prims. (An empty-shadow function whose body somehow emitted a
`+` would be caught — the check has teeth even with no effects in sight.)

## 2. Worked example B — an effectful function (the gate + the table)

`(def log (=> (1 f Fd) Str Unit) (lam (f s) (put f s)))` where `put` is the
console/write crossing bound by E51 as `(bind-sys "put" "wrap-put")` and
`wrap-put` is the hand-tal wrapper holding the actual `sys` op.

- **Upper**: `def_rows[log] = {'put'}` (the crossing `put` is reached); the Pi
  seat is nonempty (`log` is `=>`).
- **Today**: `lower.py:298` rejects `log` (`any(e …)` — the seat is truthy).
- **After E70**: the gate opens; `log` lowers like a pure function — the `put`
  call compiles to `("call", d, "wrap-put", [f, s], …)` (a call into the E51
  wrapper).
- **Re-derivation** from the lowered body: the `call wrap-put` op → **invert the
  E51 binding table** (`wrap-put` → `put`) → contributes `'put'`. reachable =
  `{'put'}`. Declared `def_rows[log] = {'put'}`. `⊆` → `row-ok`.

The binding table is presented as the mapping *witness*, itself re-checked (the
wrappers preserve-check), never trusted — this is the example's "check across
the table," made concrete: **shadow in upper names, body in floor symbols, table
between them.**

## 3. Worked example C — `row-escape` (the negative test, the whole point)

Take `log`'s lowered body but corrupt it (a lowering/optimizer bug) so it also
calls `wrap-trace` (bound from crossing `trace`), which `def_rows[log]` does not
name:

- reachable = `{'put', 'trace'}`; declared = `{'put'}`.
- `row_subsumes({'put','trace'}, {'put'})` → **false** → raise
  `row-escape(fn="log", crossing="trace")`. The module is rejected at the floor;
  the miscompile never ships. This is `check_fn`'s new obligation earning its
  keep.

## 4. Worked example D — E69's `apply-*` (the cluster seam)

After E69 lands, an effectful `apply_*` dispatches over closure constructors
whose arms cross differently:
```
apply_F(clo, x) = case clo of
  (k0 …) -> … (put …) …          ; arm row {'put'}
  (k1 …) -> … (fd-write …) …     ; arm row {'fd-write'}
```
`apply_F`'s shadow = **`row_union`** of the arm reachable-sets =
`{'put','fd-write'}` — computed, not declared (it is synthesized; §5). This is
the concrete meaning of "E70 lowers E69's `apply-*` rows"; `row_union` is built,
no rowvar/polymorphism (the sum is closed).

## 5. The re-derivation walk (algorithm sketch — not code)

Over a lowered tal body, accumulate `reachable` (a set of crossing-names):

| tal op | contributes |
|---|---|
| `("prim", _, op, …)` | `op` (e.g. `'+'`) — a pure-prim crossing name |
| `("bget"/"blen"/…)` inlined intrinsic | the crossing name of the extern it inlined (`bget`/`blen` — the mapping must be explicit; §6 #1) |
| `("call", _, f, …)` where `f` is an E51 wrapper | invert the binding table → the upper crossing name |
| `("call", _, f, …)` where `f` is a lowered def | union `shadow(f)` — **declared** for user defs, **computed** for synthesized `low.extra`/`apply-*` |
| `("sys", …)` | direct syscall — appears only in hand-tal wrappers, not lowered defs |
| `("case", …)` | recurse every arm + default; the body's reachable is the union |

Then `row_subsumes(reachable, declared)` (declared = `def_rows[name]`), else
`row-escape`. Two shadow modes, exactly as the SPEC says: **verify** against the
declared row for user defs; **compute** it bottom-up for synthesized functions
(`low.extra` at `lower.py:313`, `apply-*` at §4).

Hook points: the walk lives beside the type re-check in `tal.py check_fn`; the
row field rides the typed tal signature (the **same carrier E69 extends** with
quantities — build one extended signature, not two); the gate is the `any(e …)`
relaxation at `lower.py:298` (lower `=>` carrying `def_rows[name]`).

## 6. Open implementation questions (surfaced by drawing it out)

1. **The tal-op → crossing-name table is the crux and is underspecified.** Every
   emitting op must declare its crossing contribution: `prim` → its opname;
   `bget`/`blen` (inlined intrinsics) → the extern they replaced; `call
   wrapper` → the inverted E51 name; `call def` → the callee shadow. Getting
   `def_rows`'s vocabulary to line up with the tal ops' contributions is the
   real work — draw it as a table (example E, TODO) with each of today's tal
   ops mapped, and diff it against what `_infer_row` names upper-side, or the
   two sides will disagree and every effectful function will `row-escape`.
2. **Pure prims in the checked shadow — keep or project away?** The built
   `def_rows` includes them, so the *cheap* check includes them (and gains the
   "no unexpected extern" property for free). Alternative: check only the
   effectful projection (fewer names, but loses the pure-extern safety). Lean
   **keep** (it is what the substrate already computes, and it is strictly more
   catching). Note this is a genuine choice, not forced.
3. **Where `sysface` is computed** now that it is a projection: `def_rows ∩
   sys-crossings` needs the set of sys-crossing names (the E51-bound ones). That
   set is derivable from `sys-bindings` — one intersection, computed once.
4. **Carrier coordination with E69** — the row field and E69's quantities field
   are one extended tal signature. Build order (E69 first) means E69 introduces
   the carrier; E70 adds the row column. Do not fork it (SPEC §6).

## 7. Example E — the tal-op → crossing-name table (the crux, drawn)

Built from the real emitter tables (`native.py` `_conv_code`, `_PRIMS`,
`PRIM2LIB`; `sys-linkage.chiral` `sys-bindings`). This is where the upper
shadow and the floor re-derivation must agree, and drawing it out reveals the
decision that makes them agree.

**The emitter's upper-extern → tal-op map** (`_conv_code`, in order):
- `name ∈ _PRIMS` (`+ - * / % =i <i <=i mulhi sar shr`) → `ti-prim <name>`
- `name == "bget"` → `ti-bget` ; `name ∈ {blen, str-len}` → `ti-blen`
- `name ∈ PRIM2LIB` → `ti-call <nb-*>` (the pure byte/str intrinsics — `bcat`/
  `str-cat`→`nb-bcat`, `str-eq`→`nb-beq`, `bslice`/`str-sub`→`nb-bslice`, …)
- an E51 crossing (`put`, `print`, `trace`, …) → `ti-call <wrap-*>` (E70's gate)
- a user def call → `ti-call <def>`

**The re-derivation table** (per tal op → its `reachable` contribution):

| tal op | contributes | via |
|---|---|---|
| `ti-prim op` | `op` | direct (matches `def_rows`'s `'+'` etc.) |
| `ti-bget` | `bget` | direct |
| `ti-blen` | `blen` **and** `str-len` | direct (many-to-one — see the crux) |
| `ti-call nb-*` | the PRIM2LIB **preimage** (e.g. `nb-bcat` → `{bcat, str-cat}`) | invert PRIM2LIB — **many-to-one** |
| `ti-call wrap-*` | the `sys-bindings` **preimage** (`wrap-put` → `put`) | invert sys-bindings — 1:1 today |
| `ti-call <def>` | `shadow(def)` (declared for user, computed for `low.extra`/`apply-*`) | union |
| `ti-con`/`ti-cona`/`ti-const`/`ti-lit` | — | not crossings |
| `ti-sys`/`ti-bptr`/`ti-bnew`/`ti-bput` | (hand-tal only; the wrapper's own shadow) | n/a in lowered defs |

**THE CRUX (and its resolution).** Inverting `nb-*`/`ti-blen` is **many-to-one**
(`nb-blen ← {blen, str-len}`, `nb-bcat ← {bcat, str-cat}`, `nb-id ← {str->bytes,
bytes->str}`). So re-deriving *up* into upper names yields a **superset**, and a
`⊆` check against a declared row that names only `blen` would **false-`row-
escape`**. This is exactly the wall the doc warned about.

Resolution — **run the check in FLOOR vocabulary, not upper names**:
- *Carry-down is a function; invert-up is a relation.* Map the DECLARED shadow
  (`def_rows`, upper names) *down* through PRIM2LIB + sys-bindings once at
  lowering (`blen`→`nb-blen`, `put`→`wrap-put`, `+`→`+`), producing a
  floor-symbol declared shadow on the tal sig.
- Re-derive `reachable` from the tal body directly in floor symbols (`ti-call
  nb-blen` → `nb-blen`, `ti-prim +` → `+`) — **exact, no inversion**.
- Compare floor-vs-floor with `row_subsumes`. No many-to-one ambiguity, no false
  escapes.

This refines the example's "check across the table": the **table is applied to
the declared shadow (carry-down), not used to invert the body up.** It is the
one design decision that makes the check sound, and it is now on paper.

Residual note: `ti-blen`'s two upper preimages (`blen`, `str-len`) both carry
down to `nb-blen`, so floor-vocabulary also *dedups* them for free — another
reason the floor is the right comparison space.

## 7b. IMPLEMENTATION FINDINGS (2026-08-02, scoping against live code post-E69)

Grounding the pass against the built substrate — now that **E69 is landed** —
surfaced two corrections and pinned the real crux.

**Finding 1 — the check must be the EFFECTFUL PROJECTION, not full `def_rows`.**
Decision §6 #2 ("keep pure prims in the checked shadow — lean keep") is **unsound
once E69 conversion is real.** `def_rows` is computed at elaboration, over the
*higher-order* program; E69 then *defunctionalizes*, and a converted body can
statically reach pure prims its pre-conversion `def_rows` never named. Verified:
`apply-it = (lam (f x) (f x))` has `def_rows = {}` (the call `(f x)` is dynamic),
but after E69 its body is `($apply0 f x)` whose arm reaches `+` → the full-`def_rows`
check FALSE-`row-escape`s `apply-it` (reachable `{'+'}` ⊄ declared `{}`). The pure
prims are not part of the *effect claim* (`+` is not a port; the Pi seat is empty),
so the sound check is **reachable EFFECTFUL crossings ⊆ declared EFFECTFUL row**
(the Pi seat row = `def_rows ∩ port-crossings`). On the pure fragment this is
vacuous (no effectful crossing lowers yet) — so the check has teeth only once the
gate opens: **check + gate + emission are one integrated unit, not separable
stages.** (Verified the projection-free upper-vocab check is otherwise clean:
0 mismatches across prelude/collections and E69-converted programs *except* the
`apply-it` pure-prim case above.)

**Finding 2 — the check runs on the lower.py tal IR (UPPER vocab), so §7's
PRIM2LIB-inversion concern does not arise at the check.** `check_fn` sees the
lowered `TalFn` body, whose ops carry UPPER names (`('prim', d, '+', …)`,
`('call', d, '<def>', …)`) — the `nb-*`/`ti-*` floor translation happens later in
`native.py`'s machine conversion, which the check never touches. So the
re-derivation compares upper-vs-upper: `prim op → op`, `call <def> → shadow(def)`.
The floor-vocabulary carry-down of §7 is a *native-backend* concern, not the
`check_fn` obligation. (`def_rows` is the transitive LEAF-crossing set — a
`call <def>` contributes the callee's `def_rows`, not the def name.)

**THE CRUX — opening the gate is necessary but NOT sufficient; the E51 rep seam
is the real work.** With `lower.py:302` bypassed, a first-order effectful def
STILL fails: `(def hello (=> Str Unit) (lam (s) (put s)))` → `Ineligible: extern
put does not lower`, because `put` (a port, `is_port=True`) is excluded from
`prim_sigs`. Emission must route the crossing through its E51 wrapper — but the
wrapper is a *representation seam*, not a type-preserving call:
- `put : (=> Str Unit)` but `wrap-put : (BYTES) -> I64` (`_WRAP_SIGS`, native.py:634).
- So `(put s)` must lower to: `s:Str → BYTES` (identity at the floor — `str->bytes`
  is `nb-id`), `call wrap-put(s) : I64`, then **synthesize the `Unit` result**
  from the discarded byte-count (`con Unit`). The wrapper returns the raw crossing
  result; the seam produces the extern's declared result (DESIGN §2 / E51).
- `lower_all` must be handed the E51 `bindings` (`build_sys_linkage`, native.py:640)
  and register the `_WRAP_SIGS` into `env_tal.fn_sigs`; the **native backend must
  compile the wrappers alongside** the lowered defs so effectful code actually
  RUNS native (not just type-checks).

So E70's valuable half (effectful code lowering AND running native) is a real
E51-integration effort touching the rep seam (Str↔BYTES, Unit↔count), `lower.py`'s
App emitter, `lower_all`'s env wiring, and `native.py`'s wrapper compilation. It
deserves a focused session.

**Refined seam design (cleaner than a lower.py rep cast).** Because `nb-id` is
`(BYTES)→BYTES` and `str->bytes`/`bytes->str` both map to it, **Str and Bytes are
the SAME machine representation** — the Str/Bytes distinction is a tal-TYPE fact,
erased at the floor. So keep the crossing as **`prim put`** in the tal IR (upper
vocab, `put`'s own `(Str)→Unit` sig), exactly as `str-cat` stays `prim str-cat`
until `native.py` rewrites it to `nb-bcat`. The `put→wrap-put` translation +
`Unit`-from-count then lives ENTIRELY in `native.py _conv_code` (a `prim` whose
name is in `sys_bindings` → `ti-call wrap-put` on the same-rep arg + produce the
`Unit` tag, discarding the count) — no Str→Bytes cast in the tal IR. The tal
checker needs `put` in a sig table to accept `prim put`; add a **separate
`crossing_sigs`** to `env_tal` (not `prim_sigs`, keeping the pure membrane clean)
that `check_fn`'s `prim` handler also consults and the row check reads to identify
effectful crossings.

Build order once taken up (~6 integration points):
(a) `lower_all`: build `crossing_sigs` from the E51 `bindings` (`put→(Str)→Unit`),
    wire into `env_tal`; register `_WRAP_SIGS`.
(b) `lower.py` App emitter: a bound port crossing lowers as `prim <name>` via
    `crossing_sigs` (no rep cast — Str==Bytes at the floor).
(c) `native.py`: admit the E51 wrappers into the native lib + `_conv_code`:
    `prim <name>` where `name ∈ sys_bindings` → `ti-call wrap-<name>` + synthesize
    the `Unit` result from the discarded byte-count.
(d) open the `=>` gate `:302` for defs whose crossings are all E51-bound.
(e) the effectful-projection row check in `check_fn` (Finding 1: reachable
    effectful ⊆ declared effectful, effectful = `∈ crossing_sigs`) + `row-escape`
    negative test.
(f) `sysface = shadow ∩ sys-crossings`.

**RISK POINT RESOLVED (verified 2026-08-02): native syscall codegen ALREADY
EXISTS — step (c) is wiring, not new codegen.** `lib/sys-tal.chiral` defines
`nb-sys-write`/`-read`/`-mmap`/… as hand-tal `TFn`s using `ti-sys` (e.g.
`nb-sys-write = (ti-sys 4 1 …)`, syscall 1 = write). `native.py compile()` runs
`tfn_to_tal` (which already handles `ti-sys`/`ti-bnew`/`ti-bput`/`ti-bptr`) over
all ~40 lib fns — every `nb-sys-*` included — and emits real x86 syscall
instructions via `emit-x64.chiral`; the E21 arena / socket / process-extern tests
exercise them natively. The hard part is built. So step (c) becomes:
- The E51 **wrappers** (`wrap-put`/`wrap-print`/`wrap-trace`, `sys-linkage.chiral`)
  are hand-tal `TFn`s that `tfn_to_tal` already handles and that CALL `nb-sys-write`
  (compiles for free). They are refused from the native lib today ONLY by the
  membrane at `native.py:478` (`fn.sysface != name.startswith("nb-sys-")` — a
  wrapper is `sysface=True` via `ti-bptr` but named `wrap-*`). Step (c) = **relax
  that membrane to admit `wrap-*`** (the deliberate sys library too) + add them to
  `self.lib_tfns`, then route `prim <crossing>` → `ti-call wrap-<crossing>`.
  (`wrap-print` does two writes — payload + `\n` — so route to the WRAPPER; do not
  inline a single `nb-sys-write`.)
This downgrades E70 from a large risky integration to a **moderate wiring effort**.

Gate/native coupling: (d) exposes effectful defs to native compile, so (c) must
land with (d) — but (c) is now small, so implement (a)–(f) together, one tested
commit per step, against the 410-green baseline. Differential-test observables
(capture `put`/`print` stdout) vs the interpreter path.

## 8. Rounded off — ready to implement

Nothing left as a sketch. The shadow object (`def_rows`), the two-rows
distinction, the re-derivation walk (§5), and the tal-op table with its
floor-vocabulary resolution (§7) are all concrete. Build order: E69 first
(carrier), then E70 Step 1 (carry `def_rows` **down through the tables** onto
the shared tal sig), Step 2 (`tal_row_check` in floor vocabulary), Step 3 (open
`lower.py:298`), Step 4 (`sysface = shadow ∩ sys-crossings`).
