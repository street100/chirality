---
element: E100
slug: two-type-param-calls
title: 2-type-param + fn-param call lowering: `alist-get`/`alist-put` (2 type params + fn param) callable from compile-main through B1, completing the case-on-call fix train; conformance includes deleting every inlined alist copy from scriba files
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: reviewed
updated: 2026-08-13
---

# E100 — 2-type-param + fn-param call lowering: `alist-get`/`alist-put` callable from compile-main through B1

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E100, make a call to a function with **two erased type params
  plus a first-class function param** (`alist-get`/`alist-put` in
  `collections.chiral`) survive B1's native front-to-lowering pipeline, so the
  def is actually emitted and reachable from `compile-main`. As first drafted the
  def chain for that exact shape was silently dropped, worked around by hand-inlined
  copies of `alist-get`/`alist-put` scattered across the scriba files (those copies
  are now deleted; the type side has since landed — see the residual below).
- **Kind:** BUILD-PROPER (a designed monomorphic-lowering capability; the
  2-type-param + fn-param type side landed 2026-08-10, the reopened residual is
  the fn-param application side).
- **Why chirality needs its own:** self-hosting. B1 must compile `collections.chiral`
  as written — generic associative lookup/insert is the substrate every scriba
  registry stands on. The **definition of done includes deleting every inlined
  `alist-get`/`alist-put` copy from the scriba files** once the real def routes
  through: no more copy-paste polymorphism.
- **Residual (re-opened 2026-08-13):** the 2026-08-10 `term->ntalty` fix landed
  the TYPE side of this shape. `alist-get`/`alist-put`/`map-list` now peel and
  compile through B1 when the fn param is a simple value (`inc`, `str-eqf`, the
  case-body `unbox`, an inline `lam`): specialize-singletons monomorphizes those
  away and the call lowers first-order. What still fails is the fn-param
  APPLICATION side. In `backend.chiral`, `chat-body` calls
  `(map-list Msg Json msg->json msgs)` where `msg->json : (-> Msg Json)` and
  `Json` is the recursive sum in `json.chiral` (`j-null`/`j-bool`/`j-num`/`j-str`/
  `j-arr`/`j-obj`). That fn-arg survives as a value, so closconv defunctionalizes
  it into a `$clo0` cell plus a `$apply0` dispatcher, and the dispatcher body
  fails to emit a label (`no emitted label ... $apply0`). The orch stack is
  blocked: `compile-main <- be-chat <- chat-body <- map-list <- $apply0`.

## 2. Research

- **Reference class:** OURS — `collections.chiral` (the real
  `alist-get`/`alist-put`), `compile-front.chiral` (specialize-singletons /
  closconv / the peel), the lowering that consumes the peeled form, and
  `scriba/scriba-test-b1.chiral` (the ready-made gate: test2 = `alist-get`
  through B1, test3 = the minimal 2-type-param + fn-param repro).
- **Key findings (load-bearing):**
  1. **The shape is the variable, not the count of type params alone.** After
     `e9e5aae`, the 1-type-param + fn-param shape (`find`) compiles through B1.
     The residual failure is specifically **2 erased type params + a fn param**
     (`alist-get`/`alist-put`, `test3-two-type`). So the front handles *one*
     erased binder ahead of a value fn param but drops when a *second* erased
     binder precedes it. (RESOLVED 2026-08-10 by the `term->ntalty` `t-pi` fix —
     the type side now peels; this finding is historical context for the
     reopened residual, findings #5–#6.)
  2. **It is a silent skip, which is exactly the E97 class.** The def chain
     "silently drops" — no emitted label for the entry, no diagnosis. E97
     (`SkReason` / `LowerOut` ledger) retypes that discarded skip reason into a
     value the skip carries. **With E97 landed, this blocker names itself** —
     the front will report `(sk-callee "alist-get")` or `(sk-extern …)` at the
     entry gate instead of vanishing. E100's diagnosis therefore *depends on*
     E97 as the tool, not on guessing.
  3. **Two candidate failure sites, not one confirmed root cause.** The shape
     can die in (a) the **front peel** — specialize-singletons / closconv
     mis-counting or mis-ordering the erased binders when there are two of them
     ahead of the fn param, so the peeled arity or the closure environment is
     wrong; or (b) the **lowering** — multi-erased-type-param instantiation
     producing a mangled/duplicate entry symbol or an argument-slot mismatch
     when the second erased param is dropped. This example does **not** assert
     which; the E97 diagnostic is what disambiguates them. (RESOLVED 2026-08-10 —
     the `term->ntalty` `t-pi` fix was the peel-site fix; kept as historical.
     The reopened residual's unconfirmed site is the `$apply0` dispatcher body,
     findings #5–#6.)
  4. **The adjacent case-on-call fix train is context, not the cause.**
     `collections.chiral` now uses `(let ((r (p h))) (cond (r …) (else …)))` in
     `filter`/`any-list`/`alist-get`/`alist-put` (train: `d5bc02a`, `7cd80fc`,
     `171350c` reverted by `aaabaae`, `e9e5aae`, plus the 2026-08-09
     cond-conversion). That train fixed *case-on-a-call-result*; it did **not**
     fix the two-erased-type-param call itself (that type-side residual is now
     RESOLVED by `term->ntalty`; the reopened residual is the `$apply0`
     defunctionalization, findings #5–#6).
  5. **The specialize-singleton vs defunctionalize split is the real axis.**
     A fn-arg B1 can monomorphize away (an inline `lam`, a case-body fn like
     `unbox`, `str-eqf`, `inc`) never reaches closconv's synth: specialize-singletons
     substitutes it and the call lowers first-order, so no closure cell is ever
     minted. A fn-arg that is a top-level `Global` returning a RECURSIVE type
     (`msg->json : (-> Msg Json)`) cannot be substituted away, so closconv
     defunctionalizes it: it mints a `$clo<i>` data sum (one ctor per capture
     site) and a `$apply<i>` dispatcher (a `case` over the closure cell, one arm
     per site). The `$clo` cell and its capture fields lower fine; the `$apply0`
     dispatcher BODY is what fails to emit a label.
  6. **The failure locus is closconv's synth, not collections/backend/json.**
     `closconv.chiral` builds the defunctionalization family: `clo-name`/`apply-name`
     at :995-996 mint the `$clo<i>`/`$apply<i>` names, `ctor-name` at :997 mints
     `$k<i>_<j>`, and the `$apply` dispatcher assembly at :961+ (`apply-ty` at
     :981, `build-arms` at :1000, `apply-body` at :1007) is the term that does
     not lower. The driver that INSTALLS the `$clo` DataDecl and the `$apply`
     defs is `closconv-driver.chiral`. The E97 skip chain names the offender:
     `compile-main <- be-chat <- chat-body <- map-list <- $apply0`.
     `term->ntalty`'s `t-pi` case (compile-front.chiral:58) already maps the
     surviving arrow type to `nt-word`; the gap is the dispatcher body itself,
     whose arm reconstructs a recursive `Json` and emits no ground label.

## 3. Conventional (other-language) approach

Outside chirality, a generic associative-list lookup with a caller-supplied equality
is unremarkable — the compiler either **monomorphizes** (Rust/C++ stamp one copy
per `<K,V>` instantiation) or **erases + boxes** (Java/Go, one body, type params
gone at runtime, the `eq` passed as an interface/closure). In Python it is just:

```python
def alist_get(eq, xs, k):          # K, V purely notional — no binders at all
    for (hk, hv) in xs:
        if eq(hk, k):              # eq is a first-class value, closes over nothing
            return ("some", hv)
    return ("none",)
```

- **Assumptions it bakes in:**
  - **Type params have no runtime existence and no ordering discipline** — the
    conventional compiler never has to *count how many erased binders precede a
    value binder*, because erasure is uniform and total. chirality carries erased
    (`q=0`) binders through the surface form explicitly, and the front must
    peel/close them in the right order — the exact spot the 2-param shape breaks.
  - **A dropped instantiation is a hard error**, or there is no separate
    "lowering" that can silently omit a body. Here the def chain can vanish with
    no label and no message.
  - **`eq` is an untyped runtime closure.** chirality wants it as a typed value fn
    param `(-> K K Bool)` alongside the two erased type params — a mixed
    erased/relevant binder list, which is what the peel mishandles.

## 4. The chirality idea

- **Chirality features in play:** QTT erasure (`(0 K (type 0))` — the two type
  params are compile-time-only, `q=0`); the closconv/specialize-singletons peel
  in `compile-front.chiral`; monomorphic lowering of an erased-polymorphic def;
  and — as the *diagnostic instrument* — the E97 boundary sum (`SkReason` +
  `LowerOut` ledger), a live instance of the boundary-sums standing directive
  (`docs/pattern-boundary-sums.md`).
- **The reframing:** chirality does not erase-and-box uniformly. Type params are
  real surface binders marked `q=0`; the front *peels* them (specialize the
  singleton type args, closure-convert the value fn param) so the emitted body
  is monomorphic and the erased binders leave no runtime slot. The bug is a
  **peel/lowering arithmetic error on a mixed binder list** — two `q=0` binders
  then one relevant fn binder — not a semantics gap. The correct frame is: fix
  the binder-counting/instantiation so the second erased param is dropped
  cleanly and the entry symbol + arg slots match the call site. (RESOLVED
  2026-08-10 by the `term->ntalty` `t-pi` fix — the type-side peel landed; this
  reframing is historical context. The reopened residual is the `$apply0`
  dispatcher body, reframed below.)
- **What chirality makes impossible here (once fixed):** the **silent drop itself**.
  Under the boundary-sums discipline a skipped def cannot leave a bare hole —
  the skip *is* a `SkReason` value threaded through `LowerOut`, so
  "no emitted label for `alist-get`" becomes `(sk-callee "alist-get")` reported
  at the entry gate by construction. The copy-paste-polymorphism workaround
  (inlined alist copies) also becomes untypeable-as-acceptable: with the real
  def routing, the duplicates are dead and must be deleted.
- **The fn-param residual reframing:** a first-class fn param has exactly two
  fates. The cheap one is specialize-singletons: when the fn-arg is
  syntactically present (a `lam`, a case body, a known `Global` like `inc` or
  `str-eqf`), B1 substitutes it and the call is first-order, so no closure
  exists. The fallback is defunctionalization: when the fn-arg survives as a
  value, closconv closes over its captured environment in a `$clo` cell and
  replaces the saturated call with a `$apply<i>` dispatch (a `case` on the
  closure cell, one arm per capture site). The residual is that the dispatcher
  is minted but its body is not lowered: the codomain is the recursive `Json`
  sum, the arm reconstructs `j-obj`/`j-arr` from the captured `msg->json`, and
  the `$apply0` label is never emitted. The chirality-idea fix is to make the
  dispatcher a first-order lowering artifact, not a hole: the captured body is
  monomorphized and the `case` lowers, or the dispatcher is rewritten into
  first-order arms the lowering already understands.
- **What chirality makes impossible once fixed:** a fn-arg whose codomain is a
  recursive type stops being a compiler cliff. `msg->json` (a `Global` returning
  `Json`) and an inline `lam` returning `Json` must land in the same first-order
  dispatcher, so the orchestrator stack compiles as written with no
  hand-specialization of any caller.

## 5. Chirality example (fleshed)

The shape, from `collections.chiral` (117–135) and the B1 gate
(`scriba-test-b1.chiral`) — type annotations are as-written in the source,
value-param names come from the `lam` binders. This is the def the lowering must
carry end-to-end.

```chirality
; ── The two-type-param + fn-param shape (the thing that must lower) ──
; Two ERASED type params (q=0), then a relevant value fn param `eq`,
; then the alist and the key. `cond` (not case-on-call) is already in place.
(def alist-get (-> (0 K (type 0)) (0 V (type 0))
                   (-> K K Bool) (List (Pair K V)) K (Maybe V))
  (lam (K V eq xs k)                        ; eq = fn param, xs = alist, k = key
    (case xs
      (nil none)
      ((cons h t)
        (case h
          ((pair hk hv)
            ; parse-once: bind the call result, THEN cond — never case-on-call
            (let ((r (eq hk k)))
              (cond (r (some hv))
                    (else (alist-get K V eq t k))))))))))   ; recursive call carries BOTH type args

; alist-put — same binder shape, returns the extended list
(def alist-put (-> (0 K (type 0)) (0 V (type 0))
                   (-> K K Bool) (List (Pair K V)) K V (List (Pair K V)))
  (lam (K V eq xs k v)
    ; … same nil / (cons h t) / (pair hk hv) spine …
    ; (let ((r (eq hk k))) (cond (r (cons (pair k v) t))
    ;                            (else (cons (pair hk hv) (alist-put K V eq t k v)))))
    ))

; ── The B1 gate (scriba-test-b1.chiral) — copy these, they already exist ──
; test2: the real alist-get through B1 (2 type params + fn param) — must PASS
(def test2-alist-get (=> I64 (Maybe Str))
  (lam (n)
    (alist-get Str Str str-eq
               (cons (pair "a" "A") (cons (pair "b" "B") nil)) "a")))

; test3: the MINIMAL 2-type-param + fn-param repro (no lib deps) — must PASS
(def test3-two-type (-> (0 K (type 0)) (0 V (type 0))
                        (-> K K Bool) (List (Pair K V)) K (Maybe V))
  (lam (K V eq xs k)
    ; … nil / cons / pair spine, `(let ((r (eq hk k))) (cond …))`,
    ;   recursive tail `(test3-two-type K V eq t k)` — the exact failing shape …
    ))
```

- **Knobs to modify:** the two erased type params (`K`, `V` — the count and
  order of `q=0` binders ahead of the fn param is the axis under test); the fn
  param type (`(-> K K Bool)`); swap `alist-get`→`alist-put` to check the
  return-a-list variant; point the gate at the minimal `test3-two-type` first to
  isolate the front from any lib dependency.
- **Deliberately omitted:** the fix itself (this is a pre-run, not an
  implementation); the exact byte-loop / cons spine of `alist-put`; and any
  assertion of *which* site (peel vs lowering) is the root cause — that is
  what the E97 diagnostic decides during implementation.

### The residual: the `$apply0` defunctionalization call chain

The TYPE side is fixed. This snippet is the APPLICATION side. `chat-body`
(backend.chiral) maps `msg->json` over the message list; `msg->json` returns the
recursive `Json` sum, so the fn-arg is not singleton-substituted and closconv
defunctionalizes it. The defs below are as-written in `json.chiral`,
`collections.chiral`, and `backend.chiral` (unchanged, they are the conformance
surface):

```chirality
; ── json.chiral: Json is RECURSIVE (the codomain that trips the dispatcher) ──
; (data Json ()
;   (j-null)
;   (j-bool (b Bool))
;   (j-num (lexeme Str))
;   (j-str (s Str))
;   (j-arr (items (List Json)))          ; (List Json) recurses into Json
;   (j-obj (fields (List (Pair Str Json)))))   ; (Pair Str Json) recurses too

; ── collections.chiral: the 2-type-param + fn-param shape being applied ──
(def map-list (-> (0 A (type 0)) (0 B (type 0)) (-> A B) (List A) (List B))
  (lam (A B f xs)
    (case xs
      (nil nil)
      ((cons h t) (cons (f h) (map-list A B f t))))))

; ── backend.chiral: the fn-arg returning the recursive type ──
(def msg->json (-> Msg Json)             ; top-level Global, codomain = recursive Json
  (lam (m)
    (case m ((msg r c)
      (j-obj (cons (pair "role" (j-str r))
              (cons (pair "content" (j-str c)) nil)))))))

(def chat-body (-> Str (List Msg) Bool Bytes)
  (lam (model msgs stream)
    (str->bytes
      (json-show
        (j-obj
          (cons (pair "model" (j-str model))
           (cons (pair "messages" (j-arr (map-list Msg Json msg->json msgs)))
            (cons (pair "stream" (j-bool stream)) nil))))))))
;                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
; `msg->json` survives as a value -> closconv mints $clo0 + $apply0, and the
; $apply0 dispatcher body fails to emit a label. Skip chain:
;   compile-main <- be-chat <- chat-body <- map-list <- $apply0
```

The dispatcher closconv would synthesize (the shape at `closconv.chiral` :961-1009,
not committed source). `msg->json` closes over nothing, so the site is nullary:

```chirality
; ── the defunctionalization residue closconv mints (the thing that fails) ──
; (data $clo0 () ($k0_0))                ; one ctor per capture site; nullary here

; apply-ty : (-> $clo0 Msg Json)         ; leading $clo arrow is pure
; (def $apply0 (-> $clo0 Msg Json)
;   (lam (clo m)                          ; d=1 domain arg (Msg), then codomain Json
;     (case clo
;       ($k0_0 (msg->json m)))))          ; the arm body: the saturated call
```

`map-list`'s `(f h)` lowers to `($apply0 f h)`. The `$clo0` cell and the `$apply0`
type both carry `nt-word` (the `t-pi` case already landed). The failure is the
`$apply0` BODY: its arm reconstructs `Json` from the captured `msg->json`, and
that body emits no ground label. The fix is a lowering change to that dispatcher
body (make it first-order, monomorphizing the captured `Global`), not a change
to any of the three caller files.

- **Knobs to modify (residual):** swap `msg->json` for an inline `lam` returning
  `Json` (must land in the same dispatcher); vary the capture arity (a fn-arg
  closing over `model`/`stream` produces a non-nullary `$clo` ctor and exercises
  the de-Bruijn re-addressing in `arm-body`); keep `collections.chiral`,
  `json.chiral`, and `backend.chiral` byte-identical and assert the fix lands
  in `lower.chiral` (the recursive-codomain reconstruction; `closconv.chiral`/
  `closconv-driver.chiral` unchanged, per the SPEC's decision #9a).
- **Deliberately omitted (residual):** the actual dispatcher-body lowering fix
  (pre-run, not implementation); the precise reason the recursive-`Json` arm
  fails to lower (peel arithmetic vs lowering gap, disambiguated during
  implementation); the capture-heavy `be-chat-stream` variant.

## 6. Use / modify notes

- **Lands in:** the TYPE-side fix already landed in `scaffold/lib/compile-front.chiral`
  (`term->ntalty`'s `t-pi` case; the specialize-singletons / closconv / peel).
  The RESIDUAL lands in `scaffold/lib/lower.chiral` (reconstruct the recursive
  codomain so the inlined `$apply` dispatcher body emits a ground label);
  `scaffold/lib/closconv.chiral`/`closconv-driver.chiral` are UNCHANGED (their
  `$clo`/`$apply` synthesis is correct as minted, per decision #9a). `scaffold/lib/collections.chiral`, `scaffold/lib/json.chiral`,
  and `scaffold/lib/backend.chiral` are CORRECT AS WRITTEN and stay untouched:
  no hand-specialization of `msg->json` or any caller. The scriba files
  (`scriba/*.chiral`) lose their inlined `alist-get`/`alist-put` copies. No new
  file: a compiler lowering fix plus deletions.
- **Conformance target:**
  1. `scriba/scriba-test-b1.chiral` **test2** (`alist-get` through B1) and
     **test3** (`test3-two-type` minimal repro) both PASS (TYPE side, already
     green since 2026-08-10).
  2. **`backend.chiral` `be-chat` compiles through B1 as written**: the skip chain
     `compile-main <- be-chat <- chat-body <- map-list <- $apply0` is empty,
     `$apply0` emits a label, and no def is silently dropped.
  3. `collections.chiral`, `json.chiral`, and `backend.chiral` are byte-identical
     before and after; the change is confined to `lower.chiral`.
  4. Every inlined `alist-get`/`alist-put` copy is deleted from the scriba files
     and those call sites resolve to the real `collections.chiral` def (already
     done 2026-08-10 — no inlined copies remain; `keymap.chiral`/`command-loop.chiral`
     call `collections.chiral` directly).
  5. The full B1 self-compile still reaches FIXPOINT (byte-identical B1==B2).
- **Open questions:**
  - Front peel vs lowering — resolved *during* implementation by the E97
    `SkReason`/`LowerOut` diagnosis, not before. E100 should be sequenced
    **after E97** so the blocker names itself.
  - Why exactly does the recursive-`Json` arm fail to lower while a ground-codomain
    fn-arg (`inc`, `str-eqf`) never reaches defunctionalization? Is the gap the
    dispatcher `case` over the `$clo` cell, the `nt-word`-vs-`nt-data` codomain,
    or both? Disambiguate during implementation.
  - Does the dispatcher fix generalize to any fn-arg returning a recursive type,
    or only to the nullary-capture (`Global`) site? Prefer general.
  - Does the fix generalize to N≥2 erased type params, or does it hard-code the
    2-param case? (Prefer general — the peel should count binders, not special-case.)
  - Any interaction with the case-on-call cond-conversion train (should be none;
    that train is orthogonal context).
- **Related:** [[E97-skip-chain-diagnostics]] (the diagnostic that makes this
  blocker self-naming — E100 depends on it), [[pattern-boundary-sums]]
  (the discipline under E97), and the case-on-call fix train
  (`d5bc02a`/`7cd80fc`/`e9e5aae`) as context. The residual is a
  defunctionalization-lowering gap: it extends E100, it does not mint a new
  element.
