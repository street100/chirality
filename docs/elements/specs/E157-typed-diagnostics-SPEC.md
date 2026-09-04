---
element: E157
slug: typed-diagnostics
title: **Diagnostics as typed values** — a closed `Reason` sum with evidence, replacing the `str-cat`'d message inside `ld-err`/`ck-err`.
kind: BUILD-PROPER
example: examples/E157-typed-diagnostics.md
status: audited
updated: 2026-08-23
---

# E157 SPEC — **Diagnostics as typed values** — a closed `Reason` sum with evidence, replacing the `str-cat`'d message inside `ld-err`/`ck-err`.

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `scaffold/lib/diag.chiral` exists and owns a closed `Reason`
  sum plus its accessors; **all eight containers of the checker/loader error
  closure** — `TcR`, `CkR`, `FtR`, `UR`, `CaseR`, `EscR` (kernel), `LoadR`, `ChkR`
  (loader) — carry a **`Reason`, not a `Str`** (§2: the closure is forced, not
  chosen); every construction site in `loader.chiral` and
  `kernel.chiral` builds a reason **carrying the evidence it already had in scope**;
  and `dg-msg : (-> Reason Str)` reproduces today's message text at the one place
  the text is finally needed.
- 2026-09-04: the 2026-08-31 migration moved the tree out of scaffold/. The pre-migration paths kept here name no live directory.

- **Non-goals:**
  - Width-aware or structured formatting — **E158** (`Doc`). This element's exit
    stays `(-> Reason Str)` and is deliberately no prettier than today.
  - **Source positions** — measured absent (decision 1); `Site` is dropped.
  - Severities/warnings, `SkReason` rewriting, and the scriba jump-to-site UI.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E157 postdates the map snapshot. Treat as
  **BUILD**, with the live-code check below standing in as the build-state authority.

- **Live code (compose with these; do NOT respec them):**
  - **`XErr` + `x-msg`** — `loader.chiral:60-73`. **The taxonomy already exists for
    the extern family** (`x-redeclared` / `x-not-a-type` / `x-linear-pure`), written
    by E159 with the right intent stated in its header, and collapsed to `Str` at
    its three call sites (`:464`, `:472`, `:480`) because `LoadR`'s field is `Str`.
  - **`SkReason` / `SkRec` + the blame chain** — `skip-diag.chiral` (E97), built and
    working, with the **accessor-function discipline** its header records. `r-skipped`
    **joins it by reference**; it is not rewritten.
  - **⚑ The containers are a re-wrapping NETWORK of EIGHT, not three**
    *(corrected at the spec audit, 2026-08-24 — the draft said "the three containers";
    measured, that scope does not type-check).* Kernel's six: `TcR`/`tc-err`
    (`kernel.chiral:409`), `CkR`/`ck-err` (`:410`), `FtR`/`ft-err` (`:412`),
    `UR`/`u-err` (`:413`), `CaseR`/`cr-err` (`:416`), `EscR`/`esc-err` (`:417`).
    Loader's two: `LoadR`/`ld-err` (`loader.chiral:55`), `ChkR`/`bad!` (`:56`).
    **All eight carry `(msg Str)` and all eight re-wrap each other's payload
    verbatim** — `((tc-err m) (ld-err m))` at `loader.chiral:396`, `((ck-err m)
    (tc-err m))` at `kernel.chiral:890`, and 40-odd more of the same shape. The
    consequence is not stylistic: widen `ck-err` while `tc-err` stays `Str` and
    `kernel.chiral:890` **is a type error**. The closure is forced, not chosen.
  - **`LinErr` + `lin-msg` — a THIRD typed sum flattened at birth**
    (`kernel.chiral:350-361`). `lin-let` / `lin-pi` each carry a `Qty`, and all
    **three** of its construction sites throw the sum away in the same breath:
    `(tc-err (lin-msg (lin-pi q)))` at `:867`, `(tc-err (lin-msg (lin-let q)))`
    at `:907`, `(ck-err (lin-msg (lin-let q)))` at `:986`. Identical defect to
    `XErr` — and **two of the three land in `tc-err`**, which is independent
    proof that `tc-err` cannot be left outside the closure.
  - **`PosR`/`pos-bad` (`data.chiral:186`) — evidence bound, then dropped.**
    `loader.chiral:528` reads `((pos-bad r) (bad! (str-cat "not strictly positive: " fname)))`:
    the reason `r` — one of **nine** distinct literals built at `data.chiral:263-291` —
    is bound by the very pattern that detects the failure and never used. `PosR` is
    **not** in the forced closure (its payload never flows into a widened field), so
    it is an *opportunity*, not an obligation; §4 Step 2 takes it because the
    evidence is already in hand.
  - **The type vocabulary** `Reason` needs, all already built: `Term` (`syntax.chiral:18`),
    `Qty` (`qtt.chiral`), `DataDecl` + `Ctor` (`data.chiral:32-33`).

- **⚑ True delta (measured 2026-08-24; supersedes the draft's "three field-type
  widenings; ~9 construction-site rewrites", which was wrong by an order of
  magnitude):** one new module; **eight field-type widenings** (the closure above);
  **~50 originating construction sites** that must build a reason from evidence
  (`loader.chiral` 13: `:405,428,438,464,472,480,494,516,528,531,533,555,576` ·
  `kernel.chiral` 37: 7 `ck-err` + 30 `tc-err`); **~90 re-wrap sites** that only
  change type, not shape; **~14 boundary sites** where the closure meets a
  container outside it (decision 7); and one renderer. Total occurrences of the
  eight constructors across `scaffold/lib/`: **216**, in **6 files**
  (`kernel` 84 lines · `loader` 27 · `parse` 14 · `load-batch` 6 · `optimize` 1 ·
  `compile-front` 1), plus **9 lines of chirality test fixture** (`test-module-kind.sh`
  8, `probe-main.chiral` 1). **No new checking behaviour, and no new diagnostic.**
  Every message this produces is a message the compiler already produces — what
  changes is that the *reason survives as a value* between detection and rendering.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Does the loader have source positions for `Site` to carry? | **RESOLVED — NO, by measurement** | `Core` (`surface.chiral:50-66`) has **16 constructors and zero positions** *(spec audit 2026-08-24: the draft said `:50-62` / 13; counted, it is `c-lit-i` through `c-case` = 16, ending at `:66`)*; `DataDecl` (`data.chiral:33`) none; `Ctor` (`data.chiral:32`) none; `LItem` (`loader.chiral:77`) none. Positions exist **only in the reader** (`sexp.chiral:20,21,26,41`, plus E101's `pos-line`/`pos-col` helpers) and die at the reader→elaborator boundary. Threading them would touch all 16 `Core` constructors and the whole elaborator — a separate element, not this one. **Consequence: `Site` is DROPPED from E157**, and with it the example's "jump to both sites". |
| 1b | Then what evidence does a redeclare actually carry? | **RESOLVED — the incumbent DECLARATION, not its location** | Two empty `Site`s would carry nothing a string didn't, so `Site` would have been ceremony. What *is* in hand at the detection point is the incumbent itself: `d : DataDecl` at `loader.chiral:555,576`, `x` at `:464`. `r-redeclared` therefore carries **both declarations**. Strictly more than the name, renders as a structural diff under E158, and is honest about what the compiler knows. |
| 2 | One shared `Reason`, or one per container — is this gated on E154? | **RESOLVED — one shared; NOT gated** | The example flagged the two `CkR`s (`kernel.chiral:410`, `tal-check.chiral:30`) as a possible E154 blocker. **Measurement refutes it:** the live compiler blob contains `data CkR` exactly **once** (`blob.chiral:4042`, kernel's) — `tal-check` is not co-blobbed, so the two never meet. The collision is **latent and pre-existing**; E157 neither creates nor is blocked by it. *(This corrects the example's finding 2, which was too cautious.)* **⚑ Operational hazard added at the spec audit, 2026-08-24:** the two types never *meet*, but they share both names, and `tal-check.chiral` holds **27 of the tree's 55 `ck-err` occurrences** — more than kernel's 25. A tree-wide `ck-err` rewrite therefore corrupts `tal-check` silently. No module imports both (measured), so the rule is mechanical and must be stated in §4: **Step 2 edits `kernel.chiral` only; `tal-check.chiral` is out of scope and must be byte-unchanged.** |
| 3 | Does `XErr` retire, or become a `Subject`? | **RESOLVED — retire it** | Its three arms map exactly onto `r-redeclared` / `r-mismatch` / `r-arrow`. The example audit measured that **`extern redeclared` is asserted by no test on either floor**, so no golden pins its wording — retirement is cheap. Keeping both would leave two taxonomies for one job, which is the ownership defect E151/E152/E156 exist to end. |
| 4 | Where does `here` come from at the call sites? | **DISSOLVED by decision 1** | No positions ⇒ no `here`. The rewrites pass declarations, not locations. |
| 5 | Does `diag.chiral` stay below the checker without a cycle? | **RESOLVED — yes** | Measured import graph: `qtt`→`prelude`; `syntax`→`qtt`,`refine`; `skip-diag`→`prelude`; `data`→`prelude`,`syntax`; `refine`→`prelude`; `surface`→`prelude`; `collections`→`prelude`; `kernel`→`qtt`,`refine`,`syntax`,`data`; `loader`→`surface`,`kernel`,`collections`. So `diag` importing `qtt`+`syntax`+`data`+`skip-diag` sits **beside** `kernel` and **above** the leaves, and `loader`/`kernel` importing `diag` closes no cycle. |
| 6 | Should diagnostics get its own `docs/banks/` bank? | **RESOLVED — its OWN bank, cross-cutting into `effect-and-alarm`** *(promoted from NEEDS-AUTHOR at the spec audit, 2026-08-24: the bank schema decides it)* | The schema is "the full refraction of **ONE** concept". These are two. An **alarm** is a *runtime* divergence "raised as a typed effect… answered by a counter-effect: re-key, re-derive, relocate, repair from survivors, quarantine, halt" (`error-and-alarm.md:38-48`); a **compiler diagnostic** crosses no membrane, has no counter-effect, and lives entirely in the checker's return values. Folding one into the other would make `banks/effect-and-alarm` refract two concepts — the one thing the schema forbids — while CLAUDE.md's standing rule for a concept with no bank is "**build one rather than guessing**". What they genuinely share is the principle *"diagnostic by construction, not a stringly 'something went wrong'"* (`error-and-alarm.md:38`), which is precisely a **§3 cross-cut**, not a merge. **Deliverable:** `tools/doc/doc.py new-bank diagnostic E157 E158 E97 E159`, with `banks/effect-and-alarm` §6 gaining it as an anchor. **Still non-blocking for §4** — and deferring the *writing* to the `doc-audit` lane breaks no deferral rule, because that lane is a standing skill, not an unminted `E#`. |
| 7 | Given a forced closure of eight containers, how does the widening LAND — big-bang, or a transitional `(r-legacy (msg Str))` arm on a ratchet? | **RESOLVED — neither: close the closure, and name its 14-site boundary** | **Against `r-legacy`:** an arm whose meaning is *"not yet a reason"* is a string where a sum belongs, by construction — the exact finding `pattern-boundary-sums` licenses the audit charters to raise, against a **standing author directive to apply that pattern "as much as physically possible"**. A ratchet (the E151 / `ledger-lint` check L precedent) would make it *bounded*, not *principled*, and per the deferral rule a ratchet-to-zero needs a terminal element to drive it — **not minted, and a spec run cannot mint one**. So the transitional arm buys staging at the price of re-introducing the defect the element exists to remove, plus a phantom dep. **Why it is not needed:** measurement says the closure is already **closed**. All eight containers live in `kernel.chiral` + `loader.chiral`, and they touch the outside world at exactly **14 enumerated sites**. That is a module boundary, not a migration front. **EGRESS (8) — render with `dg-msg`, which §1 already provides:** `optimize.chiral:250` (`ck-err`→`chk-err`) · `parse.chiral:579,596,619,672,695,704` (`ld-err`→`step-err`) · `compile-front.chiral:328` (`ld-err`→`fr-err`, which prefixes `"load: "` and **must keep doing so** — `test_e42_supervisor.py:59` pins `load: linear binder usage mismatch`). **INGRESS (6) — one arm, `(r-relayed (from Relay) (msg Str))`:** `load-batch.chiral:80` (`batch-err`), `:103` (`step-err`), `:109` (`p-err`, `"data-group: "` prefix) · `parse.chiral:1315,1437` (`step-err`), `:1443` (`p-err`, same prefix). **Why `r-relayed` is not `r-legacy` in a hat:** it asserts a **true and durable fact about the architecture** — this reason was produced by the reader/batch layer, which owns its own taxonomy (`StepR` `parse.chiral:447`, `p-err`) — not "we ran out of time". Its domain is closed and enumerable, nothing downstream ever cases on the `Str`, and it needs no ratchet and no drain element, because typing the *reader's* diagnostics is a different element about a different module, not unfinished E157. The `from` field is the seam where such an element would plug in. **⚑ CORRECTED 2026-08-24 (author): `from` was drafted as `Str` — which is the SAME defect this row rejected `r-legacy` for, one slot over.** `from` encodes WHICH-OF-N over a closed, already-enumerated set of outside taxonomies, and the standing directive is explicit: *if a `Str`/`I64` in a signature encodes which-of-N-things, it is a sum wearing a disguise — mint the sum.* Rejecting `r-legacy` on that directive and then re-introducing it in a field is exactly the failure the directive exists to catch. So `from` is a closed sum: `(data Relay () (rl-batch) (rl-step) (rl-parse))` — `BatchR`/`batch-err`, `StepR`/`step-err` (`parse.chiral:447`), and the reader's `p-err`, which is the whole enumerated ingress domain. `msg Str` STAYS a `Str`: it is an opaque payload, not a classification, and nothing downstream cases on it. **The invariant that keeps this honest, and it is a §5 gate row: no ORIGINATING site may construct `r-relayed`** — all ~50 detection sites know their reason; `r-relayed` outside the 6 named lines is the failure. |

| 8 | `LinErr` (`kernel.chiral:350-361`) is a THIRD typed sum flattened at birth — in scope or out? | **RESOLVED — IN SCOPE, retire it** | Not a courtesy inclusion: **its collapse sites are already inside the forced closure.** Of its three flattening sites (`:867`, `:907`, `:986`), two land in `tc-err`, which widens regardless — so those lines are being rewritten either way. Leaving `LinErr` would mean a `Reason` payload *constructed by flattening a different sum*, which is precisely the defect E157 exists to remove, re-created one level down. `lin-let`/`lin-pi` flow into `r-usage` **as the sum they already are**; `lin-msg` retires into `dg-msg`. Cost: two arms. Same disposition as `XErr` (decision 3), for the same reason. |
| 9 | `"let binder usage mismatch"` (`kernel.chiral:648`) is pinned by NO test on either floor — gate row, or a minted element? | **RESOLVED — a gate row in THIS element; nothing minted** | It is an originating `ck-err` site *inside* the closure, so Step 2 rewrites it whether or not it is tested. Shipping a rewrite of an untested message and leaving it untested is how the gap survives the atomic commit. Minting an element for one assertion would be ceremony — and the deferral rule cuts the other way here: a follow-on named but not minted is the phantom, so the cheap honest move is to close it now. **Hardened from the draft's "should add one"** to gate row 7 (§5), which is a requirement. |

**⚑ Scope note 2 — the SIZE, added at the spec audit 2026-08-24.** The measured
delta (§2) is roughly **ten times** the draft's: eight containers, ~50 originating
sites, ~90 re-wraps, in the compiler's own sources under a `C1==C2` fixpoint
obligation. Decision 7 removes the *risk* (a closed closure with a 14-site named
boundary beats a staged migration behind a `r-legacy` escape hatch), but it cannot
remove the *size*, and **the closure means Steps 2 and 3 cannot be split into
separately-green commits** — `kernel.chiral:890` is `((ck-err m) (tc-err m))`, so
neither half type-checks alone. If the author wants this landed in smaller pieces
the seam would have to be somewhere else entirely, and minting an `E157b` is
author-tier and outside a spec run's write surface. **⚑ And the risk was OVERSTATED (author, 2026-08-24).** "A failure leaves the tree uncompilable until fixed or reverted" misreads the build rule. `CLAUDE.md`: the flow is **build-new → test → promote**, and *nothing replaces itself in place*. `scaffold/build/B1` is a committed artifact that keeps compiling the committed blob no matter what the working tree says, so a broken source tree cannot brick the toolchain — the downside of a failed atomic change is **a `git revert`**, not a lost compiler. Implement in a **git worktree** and the working tree is not even dirtied. That makes this element materially cheaper than it was priced, which argues *for* landing it whole. **Not a blocker:** as written
§4 is executable in one large commit with a sound gate.

**⚑ Scope note the author should see, not a blocker.** Decision 1 removes the
example's headline demo ("jump to both sites of a redeclare"). What survives is
still the element's actual thesis — *the reason survives as a value instead of
being flattened at birth* — and it is what unblocks E158. But if the reason you
wanted E157 was the navigation, **the position-threading element is the one that
buys it, and it is not yet minted**; per the deferral rule that row must be minted
before any work is deferred to it, and a spec run's write surface cannot mint it.

## 4. Change plan (ordered, commit-sized)

### Step 1 — `diag.chiral`: the sum, alone, imported by nobody
- **Target:** `scaffold/lib/diag.chiral` (NEW)
- **Change:** `Relay` (decision 7) + `Subject` + `Reason` (seven arms incl. `r-relayed`, `Site` dropped per decision 1;
  `r-redeclared` carries two declarations, `r-mismatch` two `Term`s, `r-usage`
  two `Qty`s, `r-arrow`/`r-unbound` their names, `r-skipped` a `(List SkRec)`).
  All accessors — `dg-reason-tag`, `dg-subject-name`, `dg-msg` — behind the
  **accessor-function pattern** (no `case` on these types in any caller's arm).
  E154: every internal `dg-`-prefixed, and **census the names against all
  `.chiral` files before committing** (the E152 precedent).
- **Size:** M. Gate: it compiles as a leaf blob and a probe cases every arm.

> **⚑ Restructured at the spec audit, 2026-08-24.** The draft's Steps 2–3 widened
> three fields and left `tc-err` at `Str`, which **does not compile** —
> `kernel.chiral:890` is `((ck-err m) (tc-err m))`. The closure (§2) is forced, so
> the plan below widens all eight together. Kernel and loader are compiler sources,
> so the **full five-step promotion ceremony + `C1==C2` fixpoint** applies (the E156
> precedent), and Steps 2 and 3 **cannot be split into separate green commits** —
> they are one type-checkable unit. Step order is still the commit order; only
> Step 2+3 land together.

### Step 2 — the kernel closure widens (6 containers)
- **Target:** `scaffold/lib/kernel.chiral` — `:409`, `:410`, `:412`, `:413`, `:416`,
  `:417` (the six declarations) · the **7 originating `ck-err`** and **30
  originating `tc-err`** sites · the ~45 intra-kernel re-wrap sites (type only,
  shape unchanged) · `:350-361` (`LinErr`: `lin-let`/`lin-pi` now flow into
  `r-usage` **as the sum they already are**, and `lin-msg` retires into `dg-msg`) ·
  `:867`, `:907`, `:986` (its three flattening sites).
- **Change:** all six err arms take `(why Reason)`; add `(import "diag")`. The
  headline evidence rewrite: `"linear binder usage mismatch"` at **`:636`**
  (`strip-binder`) becomes `(r-usage (subj-binder …) declared observed)` — both
  quantities are live at `:634-636` in `(qfits (last-qty u) q)` and are currently
  thrown away — **and its twin `"let binder usage mismatch"` at `:648`
  (`close-binder`) takes the same rewrite**, over `(qfits (last-qty ub) q)`.
- **⚑ `tal-check.chiral` is OUT OF SCOPE and must be byte-unchanged** (decision 2):
  it declares its own `CkR`/`ck-err` and holds 27 of the tree's 55 `ck-err`
  occurrences. No tree-wide `ck-err` rewrite.
- **Size:** XL.

### Step 3 — the loader closure widens (2 containers) + `XErr` retires
- **Target:** `scaffold/lib/loader.chiral` — `:55`, `:56`, `:60-73` (delete `XErr`
  + `x-msg`), and **all 13 originating sites**: `:405`, `:428`, `:438`, `:464`,
  `:472`, `:480`, `:494`, `:516`, `:528`, `:531`, `:533`, `:555`, `:576`
  *(spec audit 2026-08-24: the draft listed 8 and missed `:405`, `:516`, `:528`,
  `:531`, `:533`)*, plus the 17 intra-loader re-wrap sites.
- **Change:** `(ld-err (why Reason))`, `(bad! (why Reason))`; add `(import "diag")`;
  each site constructs a reason from what it **already binds** — notably `:555`/`:576`,
  where `d`/`x` is bound by the very pattern that detects the clash and then
  discarded, and `:528`, where `PosR`'s reason `r` is bound and discarded (§2).
- **Size:** L. **Lands in the same commit as Step 2** — neither type-checks alone.

### Step 4 — the 14 boundary sites (decision 7)
- **Target:** EGRESS (`dg-msg` at the crossing) — `optimize.chiral:250` ·
  `parse.chiral:579,596,619,672,695,704` · `compile-front.chiral:328` (keep the
  `"load: "` prefix). INGRESS (`r-relayed`) — `load-batch.chiral:80,103,109` ·
  `parse.chiral:1315,1437,1443`.
- **Change:** as decision 7. **No container outside the closure changes type**;
  `StepR`, `BatchR`, `Checked`, `FrontR`, `PosR` all keep their `Str` payloads.
- **Size:** S.

### Step 5 — the chirality-side fixtures follow the type
- **Target:** `scaffold/tests/test-module-kind.sh` (8 lines, e.g. `:528`, `:551`,
  `:629`, `:661`, `:718` — `((ld-err msg) 1)`) · `scaffold/tools/probe-main.chiral:39`
  (`((ld-err m) (do (trace m) 22))` → `(trace (dg-msg m))`).
- **Why it is its own step:** these are chirality programs compiled by B1, so they
  break with the type — and **`test-module-kind.sh` is `run-native.sh` Phase 8**,
  i.e. the suite goes red until this lands. The draft named neither.
- **Size:** S.
- 2026-09-04: pre-migration scaffold/ path.

### Step 6 — the gate
- **Target:** `tools/test/samples/e157_diag.chiral` + a `run-native.sh` Phase 10
- **Change:** as §5.
- **Size:** M.

## 5. Conformance gate

- **Golden behavior:** every message the compiler emits today, it emits **byte for
  byte** after this change. The hard golden, measured at the example audit, is
  **`linear binder usage mismatch`** — asserted literally on both floors:
  `test-check-cli.sh:50,54` · `test-linear-mint.sh:205` (native) ·
  `test_e106_linear_cap.py:126` · `test_e42_supervisor.py:130,134` (oracle) — all
  six citations **verified live at the spec audit, 2026-08-24**. Because
  **`kernel.chiral:636`** *(not `:313` — the draft's citation and the catalog row's
  are both stale; E159/E161 shifted the file)* is Step 2's target, **those six
  assertions are the differential** — native and oracle must keep agreeing. Note
  `test_e42_supervisor.py:59` pins the **prefixed** form `load: linear binder usage
  mismatch`, so `compile-front.chiral:328`'s `"load: "` is inside the golden.
  `"let binder usage mismatch"` (`:648`) is pinned by **no** test on either floor —
  measured — so Step 2 should add one rather than rely on it.

- **Tests to add** — `e157_diag.chiral`, and it must have **teeth on the evidence,
  not only on the text**:
  1. **Text preservation** — each rewritten site still renders its exact string.
  2. **⚑ Evidence survival** — `r-redeclared` returns **both declarations and they
     differ**, and `r-usage` returns declared ≠ observed. *This row is the whole
     point:* row 1 alone passes with the evidence dropped, which is exactly the
     E156 lesson — *a gate fixture can be blind to its own mutant*.
  3. **Named mutants** — for each assertion, a stated corruption and the exit it
     must produce (the E161/E156 convention).
  4. **Exhaustiveness** — a probe casing every `Reason` arm compiles.
  5. **⚑ The `r-relayed` containment invariant (decision 7)** — a grep gate:
     `r-relayed` is constructed at **exactly the 6 ingress lines** and nowhere else.
     An originating detection site that reaches for it has re-created the string
     defect under a new name, and this is the only row that can see that.
     **Stronger now that `from` is a closed `Relay` sum:** the check is against a
     **finite constructor set** (`rl-batch`/`rl-step`/`rl-parse`) rather than
     string-matching, and an exhaustive `case` over `Relay` makes a new ingress
     source a compile error instead of a silently-accepted new string.
  7. **⚑ The untested twin (decision 9)** — `"let binder usage mismatch"`
     (`kernel.chiral:648`, `close-binder`) gets its FIRST assertion on the native
     floor, with a named mutant, closing a gap that predates this element. Its
     evidence row too: declared ≠ observed over `(qfits (last-qty ub) q)`.
  6. **Closure integrity** — no container outside the closure changed type:
     `StepR`, `BatchR`, `Checked`, `FrontR`, `PosR` still declare `(msg Str)` /
     `(reason Str)`, and `tal-check.chiral` is byte-unchanged (decision 2).

- **Green line:** native suite **11 phases → 12**, `163 assertions + 82 roots` →
  ≥ `178 + 82`, exit 0. **Phase 8 (`test-module-kind.sh`) goes red between Step 2
  and Step 5** and is expected to — Step 5 is what returns it.
  ⚑ *Baseline re-measured 2026-08-25 at `6acbf9a`* (`ulimit -s unlimited; bash
  scaffold/tests/run-native.sh`, 5m35.806s, `ok` lines counted, Phase 7's own
  `82 compiled, 0 failed` line read). This line read *"**9 phases → 10** (Phases
  1–9 confirmed live in `run-native.sh`), `135 assertions + 81 roots` → ≥ `150 + 81`"*,
  which was true when the SPEC was written and is not now: E166 added Phase 10 and
  E155 added Phase 11. Corrected rather than left as history because E157 is
  UNBUILT and this is the gate its implementer runs — the delta the SPEC asks for
  (**+15 assertions, a new phase, root count unchanged**) is preserved exactly;
  only the floor it is measured from moved.

- **Oracle: `638 ran / 22F / 88E` — measured live 2026-08-24, `python3 -m unittest
  discover -s tests` from `scaffold/`, 120s.** The figure is right; the draft's
  *reason* was not. ⚑ *Corrected at the spec audit:* the draft said "Step 2/3 touch
  `surface.py`-visible forms". **They do not** — E157 changes `scaffold/lib/*.chiral`
  only and introduces **no new surface form**; `chirality/surface.py` is untouched. The
  differential leg is real but narrower: the `*_chirality.py` tests that run chirality
  sources on the Python floor and assert on the **constructor tag** —
  `test_bidir_selfhost.py:151,160` (`r[1] == "tc-err"` / `"ck-err"`),
  `test_kernel_fulladt_chirality.py:142,244,322`. Widening a payload **must not move a
  tag**, so these five are the load-bearing rows, and a tag change is the regression
  they catch. Note the baseline is **already red** (110 non-passing of 638): "must
  not regress" is measured against that red line, not a green one. `ledger-lint`
  A–M clean.

- **Done when:** the native suite is green at 10 phases with the evidence rows
  passing **and their mutants failing**, the oracle is no worse than baseline, the
  self-host fixpoint holds (`C1==C2`) — noting that **the fixpoint is stability, not
  correctness**, so it is a necessary check and never the gate.

## 6. Residue & links

- **Deliberately unbuilt:**
  - **Source positions / `Site`** — measured absent (decision 1). **No home yet: the
    element is NOT minted**, and per the deferral rule it must be before anything is
    deferred to it. Flagged for the author rather than pointed at a phantom.
    *Spec audit 2026-08-24: confirmed non-blocking — E157 as scoped parks **no** work
    on it. `Site` is dropped outright, not postponed, so there is no phantom dep in
    this SPEC. What the author loses is the example's headline demo, not any part of
    §4.*
  - **⚑ FLAGGED, outside this SPEC's write surface — the catalog row for E157 cites
    `kernel.chiral:313` for `(ck-err "linear binder usage mismatch")`. Measured
    2026-08-24: it is at `:636`, with the untested twin `"let binder usage mismatch"`
    at `:648`. This SPEC is corrected; `docs/elements/catalog.md` (and any
    LEDGER echo) is not, and an audit may only write the artifact under audit.**
  - **Structured formatting** — E158 (`Doc`), which this unblocks.
  - **The `CkR` name collision** — latent, pre-existing, orthogonal (decision 2).
  - **A diagnostics bank** — decision 6 (**now RESOLVED: its own bank**), doc tier,
    `doc-audit`'s lane. `tools/doc/doc.py new-bank diagnostic E157 E158 E97 E159`.
  - **Typed reader/batch diagnostics** — `StepR`/`p-err`/`BatchR` keep `Str`
    payloads and reach the closure through `r-relayed` (decision 7). This is a
    **statement of the current architecture, not a deferral**: no work is parked on
    an unminted element, and `r-relayed`'s `from` field is the seam if one is ever
    minted.
  - **`SkReason` migration** — E97 works; `r-skipped` joins by reference.

- **Follow-on:** **E158** is the direct consumer — it renders exactly this `Reason`.
  The scriba-side navigation is gated on the unminted position element, not on E158.

- **Related:** [[pattern-boundary-sums]] (the directive) · [[error-and-alarm]]
  (`:38`, the settled *diagnostic-by-construction* rule) ·
  [[banks/effect-and-alarm]] (§X2 — the runtime-alarm shard this is NOT) ·
  [[certificate-discipline]]. Elements: **E158** · **E97** · **E159** · **E101**.
