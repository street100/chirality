---
element: E106
slug: linear-cap-collection
title: Linear collection of caps: a container that HOLDS N move-only `porttype` values (e.g. `Session`/`Sock`/`Fd`) and threads them linearly — the TUI `mux` (T9) NEED, `TUI/PRIMITIVE-AUDIT.md`. **Stage 1 = the pivotal determination:** does the existing checker accept `List`/`Map` instantiated at a `porttype` element, and thread it move-only? If it type-checks, the element is prove-it + linear-safe helpers; if the checker rejects it (expected — `collections.chiral` helpers `length`/`append`/`rev-onto` DISCARD or re-`cons` the head, which is a use/drop of a linear value; and `(List A)`'s param is `(type 0)`, so whether a linear atom even inhabits that universe is open), the element is a purpose-built linear/affine vector with linearity-PRESERVING ops (push/pop/swap-remove/foreach-consume — no length-by-discard, no duplicating map). Conformance = a behavioral sample that holds ≥2 linear caps in the container, services one, and closes all exactly once (B1-compiled, exit 42), plus a negative test that the unrestricted `length` is REJECTED over a linear element
kind: BUILD-PROPER
reference_class: OURS/PAPER/IMPL
ours_source: (none)
status: drafted
updated: 2026-08-11
---

# E106 — Linear collection of caps: a container that HOLDS N move-only `porttype` values (e.g. `Session`/`Sock`/`Fd`) and threads them linearly — the TUI `mux` (T9) NEED, `TUI/PRIMITIVE-AUDIT.md`. **Stage 1 = the pivotal determination:** does the existing checker accept `List`/`Map` instantiated at a `porttype` element, and thread it move-only? If it type-checks, the element is prove-it + linear-safe helpers; if the checker rejects it (expected — `collections.chiral` helpers `length`/`append`/`rev-onto` DISCARD or re-`cons` the head, which is a use/drop of a linear value; and `(List A)`'s param is `(type 0)`, so whether a linear atom even inhabits that universe is open), the element is a purpose-built linear/affine vector with linearity-PRESERVING ops (push/pop/swap-remove/foreach-consume — no length-by-discard, no duplicating map). Conformance = a behavioral sample that holds ≥2 linear caps in the container, services one, and closes all exactly once (B1-compiled, exit 42), plus a negative test that the unrestricted `length` is REJECTED over a linear element

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E106, a dynamic container that HOLDS N move-only `porttype` caps
  (`Sock`/`Session`/`Fd`) and threads each linearly — the `mux` (T9) NEED from
  `TUI/PRIMITIVE-AUDIT.md`.
- **Kind:** BUILD-PROPER.
- **Why chirality needs its own:** `mux` services many client sessions from one loop.
  It side-steps *mutation* by threading one cap at a time (mux SCOPE "concurrent
  progress, serial mutation"), but it must still **hold** the other N−1 caps in a
  structure between servicings. Nothing in the tree does this: `List`/`Pair`/
  `Maybe` are declared over a `(type 0)` element (`prelude.chiral:10-19`) and
  `collections.chiral`'s helpers assume *unrestricted* values. The Stage-1 question
  was whether the checker even ACCEPTS `List`/`Map` at a linear element — settled
  below against B1.

## 2. Research

- **Reference class:** OURS/PAPER/IMPL.
  - PAPER — Quantitative Type Theory (Atkey, *Syntax and Semantics of QTT*;
    McBride, *I Got Plenty o' Nuttin'*): each binder is annotated by an element of
    a usage *semiring*; `0` = erased/irrelevant, `1` = **linear** (used exactly
    once), `ω` = unrestricted. chirality's `(q x T)` binders ARE this. Linear (drop
    both weakening AND contraction ⇒ *exactly once*) is stronger than affine (keep
    weakening ⇒ *at most once*); chirality's `q=1` is fully linear — the checker
    rejects a drop as well as a reuse, which is why cap cleanup is guaranteed, not
    merely deduplicated.
  - IMPL — Rust `Vec<T>` holds a non-`Copy` (move-only) `T`: `push` moves in,
    `pop`/`into_iter` move out, and there is no length-by-clone. The container is
    the borrow/move discipline made concrete for a dynamic collection — the exact
    shape chirality needs, but enforced by QTT quantities instead of the borrow
    checker.
- **Stage-1 ground truth (measured through B1, not asserted).** The checker has
  explicit linearity machinery: `is-linear` (kernel.chiral:63) judges a value
  linear iff its type constant is a registered `porttype` (`ldatas`/`latoms`
  registry). Two gates enforce "a non-1 field may not hold a linear value":
  - **declaration** — `check-dfields`→`linear-bad?` (loader.chiral:208-209).
  - **constructor application** — `ctor-field-types` (kernel.chiral:683-684),
    which instantiates each field type under the concrete type-args.

  Probes (blob = `prelude` + `ports` + `collections` + probe, compiled by
  `scaffold/build/B1`):

  | Probe | B1 result (verbatim) |
  |---|---|
  | `(cons a nil)` with `a : Env`/`Sock` (linear) into `List` | **REJECTED** `load: linear field hd` |
  | unrestricted `length` over a `(1 xs (List Env))` | **REJECTED** `load: linear binder usage mismatch` |
  | drop the tail of a linear container in a `case` arm | **REJECTED** `load: field binder usage mismatch` |
  | a container ctor with a NON-`1` field over a porttype: `(bv-cons (hd Env) …)` | **REJECTED at decl** `load: linear field declared non-1: hd` |
  | a container whose fields are declared `1`: `(lv-cons (1 hd A) (1 tl (LVec A)))`, held 2 caps, drained each once | **ACCEPTED at the type level** — the linear discipline holds (drop AND reuse both rejected). No native run yet: draining calls the porttype's close (`env-close`/`sock-close`), which is absent from the lowering table (`crossing-wraps.chiral`), so B1 emits no entry (`no emitted label for entry compile-main`). A control `=>` entry that drains a *lowering* crossing (`close` on a raw fd) does compile-and-**run to exit 42** — the shape is reachable; the missing piece is an `nb-*`-backed cap close, not the container (§6). |

- **Verdict:** `List`/`Map` at a `porttype` element is **REJECTED** — their element
  field (`hd A`, `k K`, `v V`) is unrestricted, and storing a linear cap there is a
  "linear field" error *by construction* (an unrestricted field could be dropped or
  duplicated, which would drop/duplicate the cap). E106 is therefore **build a new
  linear container type**, not prove-it-and-add-helpers. The fix is small and
  principled: a container whose element and tail fields are declared quantity-`1`,
  exactly the `ports.chiral` `RecvR` pattern `(1 sock Sock)`. That type-checks and
  threads move-only (drop AND discard both rejected, per the table).

## 3. Conventional (other-language) approach

Rust — a growable collection of move-only sessions, the direct analog of `mux`:

```rust
struct Session { /* owns a TcpStream — move-only, not Copy */ }

let mut pool: Vec<Session> = Vec::new();
pool.push(accept()?);                 // move a session in
let ready = poll(&pool);              // pick one
let s = pool.swap_remove(ready);      // move it OUT (O(1): last fills the hole)
let s = service(s)?;                  // consume + hand a fresh one back
pool.push(s);                         // move it back in
for s in pool { s.close(); }          // drain: each moved exactly once
```

- **Assumptions it bakes in that chirality refuses:** `Vec::len()` reads the length by
  *borrowing* — chirality has no borrow, so "how many do I hold" cannot be a free
  read; it must thread the container back (see `sv-count` below). `swap_remove`
  panics out of bounds (partiality) — chirality returns a result sum. Ambient
  allocation and `Drop`-on-scope-exit (implicit cleanup) — chirality makes the close
  an explicit consuming crossing the signature exposes.

## 4. The chirality idea

- **Chirality features in play:** QTT quantity `1` (linear, exactly-once) on the
  container's fields; the effect membrane (`->` pure repack vs `=>` when a crossing
  runs); ports/capabilities (`Sock` is an opaque linear atom, `ports.chiral:12`);
  boundary sums (every fallible/return-a-cap op is a closed sum with `1`-fielded
  arms, the `RecvR` shape).
- **The reframing:** the collection is not `List<Cap>` (rejected). It is a
  purpose-built sum whose *cons carries its element and tail at quantity 1*. Once
  the fields are `1`, the whole type registers as linear (`is-linear` reads
  `ldatas`), so the checker threads the container itself move-only for free — the
  same discipline the elements have. Every op that would "look without consuming"
  (`length`, `map`) is replaced by one that **returns the container back** in a
  result sum: no operation discards a cap, because the type won't let it.
- **What chirality makes impossible here:** dropping a held cap (leak), aliasing the
  container into two owners (double-close), and reading a count "for free" while
  the caps quietly persist unaccounted. Cleanup is not a `Drop` you can forget —
  the only way to end a `SockVec`'s life is `sv-drain`, which closes each cap
  exactly once.

## 5. Chirality example (fleshed)

A monomorphic linear cap vector for `mux`. Monomorphic on purpose: the polymorphic
`(data LVec ((A (type 0))) …)` form type-checks identically (verified — the `1`
field admits any `A`), but polymorphic higher-order code does not lower to native
during bootstrap yet (the same status as `collections.chiral`), and `mux` is real
code that must run. Fields at quantity `1` are the whole trick; the result sums
(`CountR`/`DetachR`) mirror `ports.chiral`'s `RecvR` — a returned cap is always a
`1`-field of a sum, never a bare `Pair` (whose fields are unrestricted).

```chirality
(import "prelude")
(import "ports")            ; Sock, sock-recv/-send/-close, RecvR, poll2

; ── the container ─────────────────────────────────────────────────────────────
; both fields quantity-1: the cap is held linearly, the tail is held linearly, so
; the whole SockVec registers linear (is-linear reads ldatas) and threads move-only.
(data SockVec ()
  (sv-nil)
  (sv-cons (1 hd Sock) (1 tl SockVec)))

; push = move a cap in. Pure: repacking a port is not a crossing (-> , empty row).
(def sv-push (-> (1 s Sock) (1 v SockVec) SockVec)
  (lam (s v) (sv-cons s v)))

; ── count WITHOUT discarding — the linearity-preserving replacement for `length` ─
; the unrestricted `length` is REJECTED here (it drops the head); instead thread
; the vector back beside the tally.  count-r's vector field is quantity-1.
(data CountR () (count-r (n I64) (1 v SockVec)))
(declare sv-count (-> (1 v SockVec) CountR))
(def sv-count
  (lam (v)
    (case v
      (sv-nil (count-r 0 sv-nil))
      ((sv-cons h t)
        (case (sv-count t)
          ((count-r n t2) (count-r (+ 1 n) (sv-cons h t2))))))))   ; head put back

; ── detach the cap at index i — the swap-remove analog (returns cap + rest) ──────
; a returned cap rides a 1-field of a sum, never a bare Pair. det-none = out of
; range (a value, not a panic); the untouched vector still comes back on that arm.
(data DetachR ()
  (det-none (1 v SockVec))
  (det-r    (1 s Sock) (1 rest SockVec)))
(declare sv-detach-at (-> (1 v SockVec) I64 DetachR))
(def sv-detach-at
  (lam (v i)
    (case v
      (sv-nil (det-none sv-nil))
      ((sv-cons h t)
        (case (=i i 0)
          (true  (det-r h t))                                  ; pull this one out
          (false (case (sv-detach-at t (- i 1))
                   ((det-none t2)   (det-none (sv-cons h t2)))  ; not found, rebuild
                   ((det-r s t2)    (det-r s (sv-cons h t2))))))))))  ; splice around

; ── drain: the ONLY end of a SockVec — close every held cap exactly once ─────────
; process (=>): sock-close is a crossing. Structural recursion ⇒ total.
(declare sv-drain (=> (1 v SockVec) Unit))
(def sv-drain
  (lam (v)
    (case v
      (sv-nil unit)
      ((sv-cons h t)
        (case (sock-close h)
          (unit (sv-drain t)))))))

; ── the mux servicing step (skeleton) ────────────────────────────────────────────
; hold N sessions; pick a ready index (poll over the held fds); detach it, service
; it once (recv/send threads the SAME cap back via RecvR), push it back, loop.
; "concurrent progress, serial mutation": only the serviced cap is ever mutated.
(declare mux-step (=> (1 v SockVec) (=> I64 SockVec)))
(def mux-step
  (lam (v ready)
    (case (sv-detach-at v ready)
      ((det-none v2) v2)                        ; index gone: hand the pool back
      ((det-r s rest)
        (case (sock-recv s 4096)
          ((recv-r bs s2)     (sv-push s2 rest))   ; … echo/route bs, cap back in
          ((recv-closed s2)   (case (sock-close s2) (unit rest)))  ; peer gone: close, drop from pool
          ((recv-err m)       rest))))))            ; recv-err carries NO Sock (ports.chiral:31): sock-recv already consumed the cap on error, so it is gone — just hand the rest of the pool back
; … the outer loop: build the pollset from the held caps, block, dispatch the
;   ready index into mux-step, recurse on the returned SockVec (E42 supervisor land).
```

- **Knobs to modify:** the element type (`Sock` → `Fd`/`LSock`/a future `Session`
  porttype); the pick policy (`poll2` for 2, `nb-poll` over an fd cell for N);
  whether `recv-closed` drops the cap from the pool (shown) or keeps a
  tombstone. For a non-lowering, checker-only context the polymorphic
  `(data LVec ((A (type 0))) (lv-nil) (lv-cons (1 hd A) (1 tl (LVec A))))` is a
  drop-in and works over any porttype.
- **Deliberately omitted:** the outer poll/event loop and pollset marshalling
  (the E42 alarm-supervisor's territory, `TUI/PRIMITIVE-AUDIT.md` LONG ROAD); a
  true O(1) swap-remove (the shown splice is O(n) but linearity-clean — the Vec
  last-into-hole trick is an optimization, not a correctness need); balancing/order
  (a `SockVec` is a bag, not a keyed map).

## 6. Use / modify notes

- **Lands in:** a new `lib/lincoll.chiral` (or `TUI/vt-core/session-pool.chiral`) —
  a sibling to `collections.chiral`, NOT an edit to it (the `List`/`Map` helpers stay
  unrestricted; this is the linear-fielded cousin). Imports `prelude` + `ports`.
- **Conformance target:** a B1-compiled behavioral sample that (1) holds ≥2 linear
  caps in the container, (2) services one, and (3) closes all exactly once, exit 42
  — plus the negative that the unrestricted `length` over the linear container is
  REJECTED (`linear binder usage mismatch`). The Stage-1 `accept` probe proves the
  positive shape at the TYPE level (the `1`-fielded container type-checks and threads
  move-only), but it does NOT yet run natively: draining consumes each cap via the
  porttype's close (`env-close`/`sock-close`/`fd-close`/`pool-close`/`lsock-close`),
  and NONE of those is in the lowering table (`crossing-wraps.chiral`), so B1 emits no
  entry for an `=>` main that calls them (`no emitted label for entry compile-main`,
  reproduced). A control `=>` entry that drains a *lowering* crossing — `close` on a
  raw fd — does compile-and-run to exit 42, so the exit-42 behavior is reachable in
  principle; what is missing is an `nb-*`-backed cap close, not the container
  discipline. So the behavioral exit-42 conformance run is a PREREQUISITE-gated
  deliverable: it needs an `nb-*`-backed porttype close landed first (no porttype has
  one today), or an "upper"/interpreted run during bootstrap.
- **Open questions:** (a) is the polymorphic `LVec A` worth landing now (blocked on
  the same List-lowering work) or is a monomorphic `SockVec` enough for T9? (b)
  should `mux` want swap-remove's O(1) (needs an array-backed linear vector, a
  bigger build) or is the O(n) splice fine at expected N? (c) does a keyed linear
  map (`Session`-id → cap) become a separate element, since the AVL `Map`'s `k K`/
  `v V` fields are unrestricted and would need the same `1`-field retype?
- **Related:** [[ports]] (the `porttype` floor + `RecvR` result-sum pattern this
  copies), [[collections]] (the unrestricted `List`/`Map` this deliberately does
  NOT reuse), the effect-facets decision (possession vs exercise — holding N caps
  is possession, `sv-drain` is exercise), E42 alarm-supervisor (the mux loop's
  driver). TUI need: `TUI/PRIMITIVE-AUDIT.md` T9/mux.
