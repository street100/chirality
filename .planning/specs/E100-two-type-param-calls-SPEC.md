---
element: E100
slug: two-type-param-calls
title: 2-type-param + fn-param call lowering: `alist-get`/`alist-put` (2 type params + fn param) callable from compile-main through B1, completing the case-on-call fix train; conformance includes deleting every inlined alist copy from scriba files
kind: BUILD-PROPER
example: examples/E100-two-type-param-calls.md
status: audited
updated: 2026-08-13
---

# E100 SPEC — 2-type-param + fn-param call lowering: `alist-get`/`alist-put` (2 type params + fn param) callable from compile-main through B1, completing the case-on-call fix train; conformance includes deleting every inlined alist copy from scriba files

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

> RESIDUAL (re-opened 2026-08-13): the type-side `term->ntalty` `t-pi` fix below
> landed 2026-08-10. This SPEC is extended in place for the fn-param APPLICATION
> residual: closconv's `$apply` defunctionalization for a fn-arg whose codomain
> is a recursive type (`msg->json : (-> Msg Json)`) fails to emit a label
> (`no emitted label ... $apply0`), blocking `backend.chiral` `be-chat` and the
> orch stack. Residual sections are marked RESIDUAL in each of §1-§6.

## 1. Deliverable

- **After this runs:** `alist-get` and `alist-put` (2 erased type params + a fn param) survive B1's front-to-lowering pipeline and are emitted from `compile-main`'s reachable graph. Every inlined `alist-get`/`alist-put` copy is deleted from `scriba/*.chiral` and those call sites resolve to the real `collections.chiral` defs via `(import "collections")`. `scriba/scriba-test-b1.chiral` test2 (`alist-get`) and test3 (`test3-two-type` minimal repro) both pass through B1.
- **Non-goals:** does NOT implement E97 (`SkReason`/`LowerOut` diagnostic ledger — E97 landed 2026-08-09, fixpoint 721146B; E100 proceeds with E97 diagnostics active); does NOT touch the Map (AVL) functions also in `collections.chiral` (those carry `(-> K K Ord)` not `(-> K K Bool)` and are separate shapes); does NOT fix any other scriba B1 blocker (import handler, effect chain threshold); does NOT alter the public mirror or add new test infrastructure (uses the existing `scriba-test-b1.chiral` gate).

### 1a. RESIDUAL deliverable

- **After this runs:** `backend.chiral` `be-chat` compiles through B1 as written. `chat-body`'s `(map-list Msg Json msg->json msgs)` — a fn-arg whose codomain is the recursive `Json` sum — defunctionalizes through closconv into a `$clo0` cell plus a `$apply0` dispatcher, and the `$apply0` dispatcher BODY emits a ground label. The skip chain `compile-main <- be-chat <- chat-body <- map-list <- $apply0` is empty. `collections.chiral`, `json.chiral`, and `backend.chiral` are byte-identical before and after; the change is confined to `closconv.chiral` (per decision #9a, `lower.chiral` stays unchanged).
- **Non-goals (residual):** does NOT hand-specialize any caller (no inlined `msg->json` or `map-list` copy in `backend.chiral`); does NOT change `collections.chiral`/`json.chiral`/`backend.chiral`; does NOT cover the capture-heavy `be-chat-stream` variant (effectful `(=> Str Unit)` fn param, non-nullary `$clo` ctor) — see §6; does NOT add new test infrastructure beyond the existing `a5_be_chat.chiral` sample + the B1 blob build.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** BUILD (E100 postdates the conformance map snapshot; no existing map rows to conform against — this is a new capability).
- **Live code already built that this composes with:**
  - `scaffold/lib/collections.chiral` (117–135) — `alist-get` and `alist-put` definitions using `cond` (not case-on-call), 2 erased type params `(0 K (type 0)) (0 V (type 0))` followed by fn param `(-> K K Bool)`. These are the defs that must route through unchanged.
  - `scaffold/lib/compile-front.chiral` — the bridge (front half): `build-emap`/`ty-erased` correctly computes q=0 binder positions for every global; `tnc-keep` correctly drops erased-position args at call sites; `peel-def` produces `NDef` with `ty-erased` positions embedded. The pipeline works for 1-type-param + fn-param shapes (`find`, post `e9e5aae`) but silently drops 2-type-param + fn-param shapes.
  - `scaffold/lib/specialize-singleton.chiral` — monomorphizes singleton vtables before closconv.
  - `scaffold/lib/closconv-driver.chiral` — defunctionalizes HO defs before peel.
  - `scaffold/lib/lowspec.chiral` — `NTalTy`, `NCore`, `NArm`, `NDef` types consumed by lowering.
  - `scaffold/lib/scriba/scriba-test-b1.chiral` — 5-test gate; test1 (`find`, 1-type-param + fn) passes; test2 (`alist-get`, 2-type-params + fn) and test3 (`test3-two-type` minimal repro) currently fail; test4 (command-loop chain) and test5 (full editor ELF) are aspirational.
  - `scaffold/lib/scriba/render.chiral:71-80` — `lookup-renderer`, an inlined alist-get replacement (hard-wired `str-eq` over `(List (Pair Str RendererFn))`); still present, no collections import (section header: "inline alist lookup, no collections import").
  - `scaffold/lib/scriba/keymap.chiral:75-79` — `lookup-keymap`, already a thin collections `alist-get` delegate (`(import "collections")` at :12; `(alist-get KeySeq Str keyseq-eq bs ks)`); the inlined copy was deleted 2026-08-10.
- **True delta:** the peel/lowering fix (likely in `compile-front.chiral` or the lowering it feeds) so 2 erased params are correctly dropped; deletion of ~25 lines of inlined alist copies across render.chiral and keymap.chiral; addition of `(import "collections")` to those files; replacement of inlined `lookup-renderer`/`lookup-keymap` bodies with `alist-get` calls.

### 2a. RESIDUAL baseline (the `$apply` defunctionalization machinery)

- **Landed type side (the precedent):** `compile-front.chiral:58` — `term->ntalty`'s `t-pi` case maps a surviving arrow type to `nt-word`, so a fn-param whose type survives the peel is carried as a word. Simple fn-args (inline `lam`, case-body `unbox`, `str-eqf`, `inc`) are substituted away by specialize-singletons and never reach defunctionalization; `alist-get`/`alist-put`/`map-list` with those fn-args compile and run through B1 (landed 2026-08-10).
- **The fn-param axis (verified):** a fn-arg that survives as a VALUE (a top-level `Global` returning a recursive type — `msg->json : (-> Msg Json)`) cannot be monomorphized away, so closconv defunctionalizes it: it mints a `$clo<i>` data sum (one ctor per capture site) plus a `$apply<i>` dispatcher (a `case` over the closure cell, one arm per site). The `$clo` cell and its capture fields lower fine; the `$apply0` dispatcher BODY is what fails to emit a label.
- **Synthesis sites (live source, verified):** `closconv.chiral` — the `$clo`/`$apply` assembly header at :961; `apply-ty` :981 (builds `(-> $clo doms cod)` via `mk-pi` :971); `clo-name` :995 / `apply-name` :996 / `ctor-name` :997; `build-arms` :1000 (one `carm` per site, body = `arm-body`); `apply-body` :1007 (wraps `mk-lams` :965 over the `case`); `arm-body` :951 (the per-site arm). `closconv-driver.chiral` — `synth-one` :122 installs the `$clo` DataDecl (`data-decl dname nil ctors` at :133) and the `$apply` def (`pair aname (pair aty abody)` at :134); `build-sites` :113, `dom->clo` :147, `rewrite-ty` :163, `closconv-sig` :196 drive the rewrite.
- **The precise failure (do not re-derive):** for the nullary `cs-g` site, `arm-body`'s `cs-g` case emits `(remap (g-subst n m d) gbody)` — it INLINES the captured Global's body. So `$apply0`'s body is not the clean `($k0_0 (msg->json m))` the example sketches; it is `(lam (clo m) (case clo ($k0_0 <inlined (case m ((msg r c) (j-obj ...)))>)))` — a nested `case m` that reconstructs the recursive `Json` via `j-obj`/`j-arr` inside the dispatcher arm, and that nested reconstruction emits no ground label. The example's `($k0_0 (msg->json m))` is the TARGET first-order shape the fix should produce.
- **Consumption sites (live source, verified):** `lower.chiral` — `skip-reason` :83 / `eligible?` :94 / `lower-def` :98 / `lower-all` :103 gate each def; `compile-fn` :399 is the body-emission entry; `tail` :331 / `tail-case` :344 / `tail-branches` :357 / `tail-default` :369 lower tail position; `expr` :234 / `expr-app` :272 / `emit-call` :282 / `expr-con` :288 / `expr-case` :298 lower non-tail position; `outline` :308 / `build-outline` :319 outline a non-tail `case`. `compile-emit.chiral:192` is where a missing entry label surfaces as `no emitted label for entry <entry>`.
- **E97 skip-chain is live:** the skip chain `compile-main <- be-chat <- chat-body <- map-list <- $apply0` already names the offender. Because the chain is PRESENT (not a bare "no emitted label"), the def passed the peel and the lowering phase produced the `low-skip "$apply0" <reason>` record — the residual is in body emission, not the `term->ntalty` peel.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Front peel vs lowering — which site is the root cause? | DEFERRED (E97) | Resolved during implementation by E97 `SkReason`/`LowerOut` diagnosis. Two candidate sites (peel miscounts erased binders when there are 2+; lowering mangled entry symbol). Do not guess — E97 names the blocker. |
| 2 | Does the fix generalize to N≥2 erased type params, or hard-code the 2-param case? | RESOLVED (general) | `compile-front.chiral` `ty-erased` already counts all q=0 positions correctly (recursive walk of t-pi chain). The peel should work for arbitrary N; if it doesn't, the fix is to make it general, not special-case 2. |
| 3 | Any interaction with the case-on-call cond-conversion train? | RESOLVED | None — orthogonal. The cond-conversion train (`d5bc02a`, `7cd80fc`, `e9e5aae`) fixed `case` on a call result; E100 is about the call itself surviving the peel when the callee has 2+ erased params. `collections.chiral` already uses `cond` — the def body is not the variable. |
| 4 | E100 sequencing relative to E97 | RESOLVED | E97 landed 2026-08-09 — `skip-diag.chiral` live, `compile-back.chiral:19` imports it, `blame-chain` wired, fixpoint 721146B. E100 proceeds with E97 diagnostics active; no sequencing gate remains. |
| 5 | Should the fix touch `compile-front.chiral` peel, or the lowering stage it feeds? | RESOLVED (diagnose-at-impl) | E97 `SkReason`/`LowerOut` names the blocker at implementation time. The SPEC change plan covers both sites in ordered steps; the impl run diagnoses with E97 output first (Step 2), then applies the fix to whichever site the SkReason names (Step 3). No pre-selection needed. |
| 6 | Can `render.chiral` and `keymap.chiral` import `collections` without triggering the collections import poison? | RESOLVED | Yes — after the 2-type-param fix lands, the collections import poison (which is the same shape) will be resolved. The scriba-test-b1.chiral blob already imports collections without issue for test1 (`find`). The poison was never the import itself but the 2-type-param defs in the blob. |
| 7 | Where does the RESIDUAL fix land: closconv `$apply` body synthesis vs `lower.chiral` `$apply` consumption? | RESOLVED (closconv synthesis; lower.chiral unchanged) | Per decision #9 (a): `arm-body` :951 builds the `$apply` arm via `(remap (g-subst n m d) gbody)` — de-Bruijn remap only, never `rw`. A fn-value global (`as-str`) in value position survives bare because `fob` :444 falls through Globals to `(_ true)` and `rw` :1011 (whose job, :1015, is "a function-value Global → its nullary Con") is never run over the synthesized arm. The fix is in `closconv.chiral` (compose `rw` with the `remap` on the synthesized arm body); `lower.chiral` and its `lc-global` guard stay unchanged. |
| 8 | Does the RESIDUAL fix generalize to all fn-value globals left bare in a synthesized `$apply` arm, or special-case `as-str`? | RESOLVED (general) | Same as the type-side precedent: the `term->ntalty` `t-pi` fix was ONE general case arm; this `$apply` fix is the fn-application sibling. `rw` must run over EVERY synthesized `$apply` arm body so ANY fn-value global in value position becomes its nullary `Con` (`$clo` ctor), not just `as-str`. `backend.chiral`/`json.chiral`/`collections.chiral` stay byte-identical; no hand-specialization of any caller. |
| 9 | Which synthesis strategy: (a) compose `rw` over the synthesized `$apply` arm bodies (closconv), or (b) switch `arm-body`'s `cs-g` to emit a saturated direct call to the captured Global? | RESOLVED (a) | Compose `rw` with the existing `remap` on the synthesized `$apply` arm bodies in closconv, so a fn-value global (`as-str`) gets wrapped in its `$clo` cell and the defunctionalization output is fully first-order. Author's call (2026-08-13, corrected post-diagnosis): closconv owns the first-order-output invariant (`fob` :413, `rw` :1011); the `remap`-only verbatim lift is the bug. `lower.chiral` and the oracle guard (lower.py:339-342) stay unchanged. Option (b) would make B1 lower a term the oracle declares Ineligible — a correctness regression, not a fix. |
| 10 | Is the capture-heavy `be-chat-stream` variant in scope for this residual? | RESOLVED (out of scope) | The example deliberately omits it. It exercises a non-nullary `$clo` ctor and `arm-body`'s de-Bruijn re-addressing for a capture closing over `model`/`stream` — a harder shape, listed as §6 residue. The fix must not regress the nullary path while leaving the capture-heavy path for a follow-on. |

## 4. Change plan (ordered, commit-sized)

### Step 1 — E97 diagnostic instrument (prerequisite, separate impl run)
- **Target:** `scaffold/lib/lower.chiral` — `LowerOut` ledger + `SkReason` sum
- **Change:** E97 lands first. After E97, any skip reason surfaces as a value instead of vanishing silently. This gives E100's impl run a concrete `sk-callee "alist-get"` or `sk-extern "alist-get"` at the entry gate.
- **Size:** L (separate E97 run; E100 unblocked after)

### Step 2 — Diagnose: peel vs lowering (using E97)
- **Target:** `scaffold/lib/compile-front.chiral` — `peel-def` and `build-emap` path vs the lowering stage
- **Change:** Run the `scriba-test-b1.chiral` test3 blob through B1 with E97 active. Read the `LowerOut`/`SkReason` to determine whether the skip is in the peel (miscount of erased binders) or lowering (mangled entry symbol / arg-slot mismatch). If peel: `peel-def` rejects the def (returns `none` silently, becoming `sk-callee` under E97). If lowering: the `NDef` is emitted but lowering can't find/match it.
- **Size:** S (diagnosis only — one test run + reading E97 output)

### Step 3 — Fix the peel or lowering (depending on Step 2 diagnosis)
- **Target (peel path):** `scaffold/lib/compile-front.chiral` — `peel-def` (line 181) and/or `build-emap` (line 159) and/or `ty-erased` (line 154)
- **Target (lowering path):** `scaffold/lib/lower.chiral` — the monomorphic instantiation of multi-erased-type-param defs
- **Change:** If peel: the `term->ntalty-list (ty-kept-doms ty)` in `peel-def` may be rejecting the type when it encounters `t-var` at an erased position (already handled — `(t-var i) (some (nt-word))`). The actual failure is more likely in the closconv or specialize-singletons stage, where the 2-erased-param shape may be left in a form the peel can't process. Trace the exact `NDef` or `none` path with E97 output. If lowering: fix the entry symbol construction or arg-slot mapping so the second erased param is dropped cleanly.
- **Size:** M

### Step 4 — Verify test2 and test3 pass through B1
- **Target:** `scaffold/lib/scriba/scriba-test-b1.chiral`
- **Change:** Build the scriba-test-b1 blob (prelude + collections + ports + term + puffer + render + command-loop + keymap + init-loader + scriba-test-b1) and pipe through B1. Both test2 (`alist-get` through B1) and test3 (`test3-two-type` minimal repro) must emit labels for their entries. Verify with: build blob → `B1 < blob > /dev/null 2>&1` — expect no "no emitted label" for either entry.
- **Size:** S (test run)

### Step 5 — Delete inlined alist copies from scriba files
- **Target:** `scaffold/lib/scriba/render.chiral` — `lookup-renderer` (lines 71-80)
- **Change:** Delete the inlined `lookup-renderer` def. Replace with `(declare lookup-renderer (-> (List (Pair Str RendererFn)) Str (Maybe RendererFn)))` and a thin wrapper using real `alist-get`:
  ```chirality
  (import "collections")
  (def lookup-renderer (lam (reg name) (alist-get Str RendererFn (lam (a b) (case a ((rf fn1) (case b ((rf fn2) false))))) reg name)))
  ```
  Actually, simpler: `RendererFn` wraps a function — equality isn't structural. Since the lookup is always for a specific `type-name` string and we need to match the `str-eq` on the key, define a helper:
  ```chirality
  (declare renderer-eq (-> Str Str Bool))
  (def renderer-eq str-eq)
  (def lookup-renderer (lam (reg name) (alist-get Str RendererFn renderer-eq reg name)))
  ```
- **Size:** S (delete ~10 lines, add ~6 lines)

### Step 6 — Delete inlined alist copy from keymap.chiral
- **Target:** `scaffold/lib/scriba/keymap.chiral` — `lookup-keymap` (lines 75-79; already converted — `(import "collections")` at :12, delegate body at :75-79)
- **Change:** Delete the inlined `lookup-keymap` def. Add `(import "collections")`. Replace with a thin wrapper using real `alist-get`:
  ```chirality
  (def lookup-keymap (-> KeySeq Keymap (Maybe Str))
    (lam (ks km)
      (case km
        ((keymap bs)
          (alist-get KeySeq Str keyseq-eq bs ks)))))
  ```
  This extracts the bindings list from the Keymap wrapper and delegates to the real `alist-get` with `keyseq-eq` as the equality function. Keeps the same type signature.
- **Size:** S (delete ~13 lines, add ~6 lines)

### Step 7 — Verify full B1 self-compile fixpoint
- **Target:** `scaffold/build/B1` (the native compiler binary)
- **Change:** After all lib changes, rebuild B1: sync changed files to public mirror, `./build.sh`, verify FIXPOINT (byte-identical B1==B2). If the fix touches `compile-front.chiral` (which IS in the self-compile path), the first rebuild will produce a new B1; a second rebuild must produce a byte-identical B1.
- **Size:** M (two rebuild passes)

### 4a. RESIDUAL change plan (the `$apply` dispatcher-body lowering fix)

### Step 8 — E97 skip-chain diagnosis (read the reason, do not guess)
- **Target:** the live E97 skip chain (`skip-diag.chiral` wired via `compile-back.chiral:19`) + `compile-emit.chiral:192` (the `no emitted label for entry` elf-err) + `lower.chiral` `lower-def` :98 / `lower-all` :103 (the `low-skip "$apply0" <reason>` record)
- **Change:** Build the `a5_be_chat` blob (prelude + collections + json + http + backend + `scaffold/samples/a5_be_chat.chiral`) and pipe through B1. Read the skip chain `compile-main <- be-chat <- chat-body <- map-list <- $apply0`. Record the exact `low-skip "$apply0" <reason>` string — one of `lower.chiral`'s skip values (`case on unknown data`, `branch not a ctor`, `call target not lowered`, `con: unknown data`, `body is not a lambda chain`, `partial application`, `over-application`, or an `expr-con`/`tail-case` reconstruction skip). The chain being PRESENT (not bare) already proves the def passed the peel and failed body emission; the reason names the exact site. No guessing.
- **Size:** S

### Step 9 — Fix closconv: compose `rw` over the synthesized `$apply` arm bodies (primary, per #9a)
- **Target:** `scaffold/lib/closconv.chiral` — `arm-body` :951 (the `cs-g` arm `(remap (g-subst n m d) gbody)`), `fob` :444 (falls through bare Globals to `(_ true)`), `rw` :1011 (whose job, :1015, is "a function-value Global → its nullary Con")
- **Change:** Per decision #9 (a), the fix is HERE. `arm-body` builds the `$apply` arm via de-Bruijn `remap` ONLY — it never runs `rw`, so a fn-value global (`as-str`) in value position survives bare (the verbatim lift). Compose `rw` with the `remap` on the synthesized arm body, so ANY fn-value global becomes its nullary `Con` (`$clo` ctor) and the defunctionalization output is fully first-order — honoring `fob` :413's own contract ("lifted verbatim into an `$apply` arm, lowers first-order"). One general composition, no special-case for `as-str`. `lower.chiral` untouched.
- **Size:** M (the primary fix)

### Step 10 — Confirm lower.chiral unchanged (no change, per #9a)
- **Target:** `scaffold/lib/lower.chiral` — `expr` :234, the `(lc-global n)` arm at :242, the fallthrough `(_ (er-skip (str-cat "reference stays upper: " n)))` at :246
- **Change:** Per decision #9 (a), `lower.chiral` is NOT the fix site — its `lc-global` guard is the oracle-ratified invariant (lower.py:339-342 "post-closconv: a Global used as a VALUE is already a Con"). With Step 9 making closconv emit fully-first-order output, the bare fn-value global never reaches `lower.chiral`, so this arm is unchanged. Do NOT add a function-pointer instruction or diverge B1 from the oracle.
- **Size:** S (read + confirm)

### Step 11 — Conformance gate: `a5_be_chat` compiles, `be-chat` emits
- **Target:** `scaffold/samples/a5_be_chat.chiral` (golden, untouched) + the B1 blob build
- **Change:** Build the `a5_be_chat` blob and pipe through B1. Assert the skip chain `compile-main <- be-chat <- chat-body <- map-list <- $apply0` is EMPTY; `$apply0` and `be-chat` emit labels. Assert `git diff` is empty on `collections.chiral`/`json.chiral`/`backend.chiral`. The live run (endpoint up) exits 42 = a real assistant reply came back; the hermetic gate is label emission, not the live round-trip.
- **Size:** S (test run)

### Step 12 — test-native green + self-host fixpoint
- **Target:** `scaffold/lib/closconv.chiral` (the fix, per decision #9a) → sync to `../chirality`, `./build.sh`
- **Change:** Sync all changed files as one batch (`closconv.chiral` IS in the self-compile path), `./build.sh`, `chirality test-native` green, then self-host: `B1 < blob | cmp - B1` byte-identical (FIXPOINT B1==B2). Copy `bin/chirality-bin.new` back as `scaffold/build/B1`. Two-rebuild fixpoint because `closconv.chiral` changes the compiler itself.
- **Size:** M

## 5. Conformance gate

- **Golden behavior:** `scriba/scriba-test-b1.chiral` test2 (`test2-alist-get` calling the real `alist-get`) and test3 (`test3-two-type` minimal 2-type-param + fn-param repro) both pass through B1 — their entry labels are emitted, no "no emitted label" error. `lookup-renderer` and `lookup-keymap` call the real `alist-get` from `collections.chiral` instead of inlined copies, and the full scriba blob with collections imported compiles without the 2-type-param poison.
- **Tests to add:** no new test files — `scriba-test-b1.chiral` test2 and test3 ARE the gate. The existing `chirality test-native` suite must still pass. The Python `test_collections.py` suite must still pass (verifies alist-get/alist-put semantics unchanged).
- **Green line:** test2 and test3 go from FAIL (no emitted label) → PASS (label emitted, binary runs). `chirality test` baseline passes (698 tests). B1 fixpoint holds (B1==B2 byte-identical).
- **Done when:** `alist-get` and `alist-put` are callable from `compile-main` through B1; test2 and test3 pass; zero inlined `alist-get`/`alist-put` copies remain in any scriba file (verified by `grep -r "Inlined to avoid.*alist-get" scaffold/lib/scriba/` returning empty); B1 self-compile fixpoint holds.

### 5a. RESIDUAL conformance gate

- **Golden behavior:** `scaffold/samples/a5_be_chat.chiral` compiles through B1 and, run against a live endpoint, exits 42 (a live assistant reply came back). `be-chat` emits a label; the skip chain `compile-main <- be-chat <- chat-body <- map-list <- $apply0` is empty; `$apply0` emits a ground label.
- **Hermetic gate (label emission, no endpoint needed):** `be-chat` and `$apply0` emit labels when the `a5_be_chat` blob is piped through B1 — no "no emitted label ... $apply0". The exit-42 assertion is confirming but non-hermetic (needs the ollama endpoint up); label emission is the deterministic green line.
- **Byte-identity:** `collections.chiral`, `json.chiral`, `backend.chiral` are byte-identical before and after (verified by `git diff` empty on those three files). The change is confined to `closconv.chiral` (per decision #9a; `lower.chiral` unchanged).
- **Green line:** `chirality test-native` passes (the gate floor). B1 self-host fixpoint holds: `B1 < blob | cmp - B1` byte-identical (B1==B2).
- **Done when:** a recursive-codomain fn-arg (`msg->json : (-> Msg Json)`) defunctionalizes through closconv and its `$apply0` dispatcher body lowers to a ground label; `be-chat` compiles as written; `a5_be_chat` exits 42 (hermetic: label emission); self-host fixpoint holds.

## 6. Residue & links

- **Deliberately unbuilt:**
  - E97 (`SkReason`/`LowerOut` diagnostic ledger) — landed 2026-08-09 (fixpoint 721146B). E100's diagnosis uses E97's `SkReason`/`LowerOut`.
  - `alist-has` (also 2-type-param + fn-param) — same shape, should route automatically once `alist-get` works. No scriba call site currently uses it, so no inlined copy to delete.
  - Map (AVL) functions in `collections.chiral` — `m-lookup`, `m-insert`, `m-delete`, etc. These carry `(-> K K Ord)` not `(-> K K Bool)` and may hit a different peel/lowering shape. Separate element.
  - Full scriba blob compilation (test4, test5) — blocked on the B1 effect chain threshold, not on 2-type-param calls. Separate elements.
  - `window.chiral:15` `(import "collections")` — currently flagged as part of the collections import poison. After E100 fixes the 2-type-param shape, this import should be safe; but the file's own B1 blockers (Keymap + Puffer combination, etc.) are separate.
  - Public mirror sync — deferred to the implementation run after fixpoint confirmed.
- **Follow-on:** the scriba files that currently inline `alist-get` become importers of the real `collections.chiral`. This unblocks `alist-has`, `alist-put` for scriba call sites that need keymap insertion (e.g., `define-key`). It also removes the last collections import poison argument — once 2-type-param calls route, `(import "collections")` is no longer a label-killer in scriba blobs.
- **Related:** [[E97-skip-chain-diagnostics]] (landed prerequisite — the diagnostic that makes this blocker self-naming), [[E100-two-type-param-calls]] (the worked example), [[pattern-boundary-sums]] (the discipline under E97), case-on-call fix train (`d5bc02a`/`7cd80fc`/`e9e5aae`) as context.

### 6a. RESIDUAL residue & links

- **Deliberately unbuilt (residual):**
  - The capture-heavy `be-chat-stream` variant (`backend.chiral:114`, the `(=> Str Unit)` fn param) — a non-nullary `$clo` ctor with de-Bruijn re-addressing in `arm-body`. Out of scope per decision #10; the nullary fix must not regress it, and it becomes a follow-on element if the orch stream path needs it.
  - Effectful fn-params generally (`(=> ...)` arrow fn-args) — the `$apply` dispatcher for an effectful capture is a separate shape (the `$clo` arrow carries the effect flag in `apply-ty`'s `pi-effs`), not exercised by `msg->json`.
  - The `Map` (AVL) `(-> K K Ord)` fn-param shape — already residue above, now confirmed adjacent to the recursive-codomain residual but distinct (the `Ord` codomain is non-recursive).
  - Public mirror sync of the residual fix — deferred to the implementation run after fixpoint.
- **Follow-on:** once the `$apply` dispatcher lowers for recursive-codomain fn-args, the orch stack (`compile-main <- be-chat <- ...`) unblocks without touching `backend.chiral`. An inline `lam` returning `Json` must land in the SAME first-order dispatcher as the `msg->json` Global (the example's knob) — that is the generalization test, not a separate element.
- **Related (residual):** [[E97-skip-chain-diagnostics]] (the skip chain that names `$apply0`), [[E100-two-type-param-calls]] (the worked example, §5 residual), [[pattern-boundary-sums]] (the boundary-sum discipline under E97). The residual is a defunctionalization-lowering gap: it extends E100, it does not mint a new element.
