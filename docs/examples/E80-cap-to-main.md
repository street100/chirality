---
element: E80
slug: cap-to-main
title: Capability reification to `main` (profile-grants-to-entry): the profile hands the entry point its reified ambient caps (Console/Clock/Timer/Env/NetCap) the way `spawn` hands `node-main` its peer port — `main` grows from `(=> Unit Unit)` to receive the granted linear porttypes; closes the ambient-authority violations named in decision-effect-facets and unblocks E29's deferred NetCap third (forward contract in the E29 SPEC §6) + the shared Clock/Timer/Env edge (added 2026-08-01, author-ratified: build, not defer)
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: drafted
updated: 2026-08-02
---

# E80 — Capability reification to `main` (profile-grants-to-entry)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E80 — the profile hands the entry point its reified ambient
  capabilities (Console / Clock / Timer / Env / NetCap) as **linear ports**, the
  way `spawn` already hands `node-main` its peer `Sock`. `main` grows from
  `(=> Unit Unit)` to `(=> (1 g Grant) Unit)`, so a whole program's authority
  has a **named, typed root** instead of leaking in ambiently.
- **Kind:** BUILD-PROPER. The cap side is *half built*: `Clock`/`Timer`/`Env`
  porttypes and their cap-gated ops (`time-mono`/`sleep-ms`/`env-view`, which
  thread the cap back via RecvR) already exist (`lib/ports/ports.chiral`). What is
  **missing is the source of a cap** — `main` is `(=> Unit Unit)` and holds
  nothing, so `env-view` is *uncallable from a real program*, and `print` /
  `env-get` stay ambient (`ports.chiral:92,95` flags `env-get` inline as "AMBIENT
  (the named violation) … retirement rides cap reification"). E80 builds the
  grant seam that mints caps and hands them to `main`.
- **Why chirality needs its own:** "no ambient authority" (the effect-membrane
  thesis) is only *true* once the **entry's** authority is itself a typed grant —
  otherwise the base case of the authority tree is a hole. E80 closes the
  remaining ambient violations (`print`/`env-get`) and unblocks E29's deferred
  NetCap third + the shared Clock/Timer/Env edge (both waited on exactly this).

## 2. Research

- **Reference class:** OURS (design from spec — no port source). Sources:
  `docs/decision-effect-facets.md` (the recorded direction: caps "handed to
  `main` by the profile the way `spawn` already hands `node-main` its peer
  port"), `docs/banks/capability.md`, and the built `spawn`→`node-main`
  precedent (`prog/demo/duo.chiral:17`, `prog/demo/node-render.chiral:72,87`).
  2026-09-04: the `spawn : (=> Str Sock)` extern this cited at line 88 of the
  pre-split port floor is declared nowhere in the live tree, so the call site is
  the only verified referent left.
- **Key findings:**
  1. **The precedent is already in the tree.** `spawn : (=> Str Sock)` mints a
     peer; the child `node-main : (=> (1 peer Sock) Unit)` receives it linearly;
     the parent calls `(node-main peer)`. E80 lifts this same shape to the
     *top-level* entry, with **the profile** (not a parent's `spawn`) as the
     minter of authority.
  2. **Half of E80 is already built.** `Clock`/`Timer`/`Env` + `time-mono`/
     `sleep-ms`/`env-view` exist and are RecvR-threaded (`lib/ports/clock.port:21-34`).
     The one missing thing is *where a cap comes from*: nothing mints one for app
     code. E80 is precisely the mint-and-hand-to-`main` seam, not the ops.
  3. **The profile is the authority root.** Today `(profile headless (ports
     print env-get) …)` puts the *ambient externs* in the frozen port set
     (`demo/profile-headless.chiral:12–14`), so any code in the composite can
     reach them. E80 moves entry authority *out of the ambient port set* into
     `main`'s linear parameter — authority becomes per-program and traceable to a
     declared grant.
  4. **Linearity makes it airtight.** The grant is a *linear bundle*: every cap
     must be consumed exactly once (or explicitly closed). `main` cannot silently
     drop authority, cannot duplicate it — the checker forces the grant to be
     fully accounted, the same discipline that makes `(1 c Sock)` leak-proof.

## 3. Conventional (other-language) approach

Outside chirality, ambient authority is the default. In C the entry is
`int main(int argc, char **argv, char **envp)` — it gets args/env, but the rest
of the OS surface is globally reachable from anywhere:

```c
/* any function, anywhere — no capability, no declaration, no trace */
void deep_in_the_call_graph(void) {
    printf("hello");              /* ambient stdout            */
    getenv("SECRET_KEY");         /* ambient environment       */
    int s = socket(AF_INET, ...); /* ambient network authority */
}
```

- **Assumptions it bakes in:** any code can perform any effect (no authority is
  tracked); the console, environment, clock, and network are *globals*; you
  cannot read a function's type and know what it can reach. Least-authority is a
  *convention* (pass fewer globals by hand), never a guarantee. chirality-today's
  residual version of this is `print : (=> Str Unit)` / `env-get : (=> Str Str)`
  — ambient externs any composite member can call.

## 4. The chirality idea

- **Chirality features in play:** ports & capabilities, the `->`/`=>` effect
  membrane, QTT linearity (`1`), profiles & targets, categories A/B/C (the mint
  is a C-bridge over a B floor).
- **The reframing:** every crossing takes its cap as a parameter, so authority =
  caps-in-scope and `crossings ⊆ caps-held` holds by construction. **The entry
  is the base case.** `main : (=> (1 g Grant) Unit)` receives a linear bundle of
  the reified caps; **the profile declares the grant**; the checker enforces that
  `main` consumes *exactly* the granted caps; and the loader (the psABI-entry
  floor — E32's "env = entry-stack data", E34's entry stub) mints the real ports
  and calls `main` with them. Ambient `print`/`env-get` retire to their
  `Console`/`Env`-gated successors.
- **What chirality makes impossible here:** a function performing an effect whose cap
  isn't in scope (untypeable); the entry wielding authority the profile didn't
  grant (the grant *is* the ceiling); silently dropping or duplicating authority
  (linearity); ambient reach at all (there is no global `print` — only
  `console-put` over a `Console` that traces back to the grant).

## 5. Chirality example (fleshed)

```chirality
(import "prelude")

; ---- reify the two still-ambient caps (Clock/Timer/Env already built) --------
; ports.chiral has Clock/Timer/Env + cap-gated time-mono/sleep-ms/env-view. The
; ambient holdouts are print/put/trace (-> Console) and socket authority
; (-> NetCap, E29's deferred third). Successors thread the cap back (RecvR).
(porttype Console)
(porttype NetCap)

(data OutR ()
  (out-r (1 c Console)))                          ; the cap survives the write
(extern console-put (=> (1 c Console) Str OutR))  ; print, but authority-carrying

; ---- the grant: one linear bundle the PROFILE hands the entry ----------------
; The top-level analog of node-main's (1 peer Sock). Every field is linear, so
; the record is linear: main must account for every cap exactly once.
(data Grant ()
  (grant (1 con Console)
         (1 clk Clock)
         (1 tmr Timer)
         (1 env Env)
         (1 net NetCap)))

; ---- main grows from (=> Unit Unit) to receive the grant ---------------------
; Authority now has a named root: every crossing main's call graph performs is
; traceable to a cap unpacked here. No ambient print; no ambient env-get.
(declare shutdown (=> (1 con Console) (1 clk Clock) (1 tmr Timer)
                      (1 env Env) (1 net NetCap) Unit))   ; consumes/closes caps

(declare main (=> (1 g Grant) Unit))
(def main
  (lam (g)
    (case g
      ((grant con clk tmr env net)
        ; greet stdout, RECOVERING the Console cap, then thread survivors on:
        (case (console-put con "hello, chirality")
          ((out-r con2)
            ; con2/clk/tmr/env/net are each still owed a consumer or a close
            ; before main returns Unit -- linearity is the account. ; …
            (shutdown con2 clk tmr env net)))))))

; ---- the profile is the authority ROOT: it declares the grant ----------------
; Today: (profile app (ports print env-get) (target app)) -- ambient externs in
; the frozen set. E80: the ambient holdouts leave the port set; the profile
; GRANTS caps to the entry, and the target requires main to consume exactly them.
(target app
  (require main (=> (1 g Grant) Unit)))            ; entry consumes the grant

(profile app
  (grants Console Clock Timer Env NetCap)          ; NEW clause: reified entry authority
  (ports console-put time-mono sleep-ms env-view)  ; cap-gated ops -- no ambient print/env-get
  (target app))
```

- **Knobs to modify:** the grant as a bundled `Grant` record (shown) vs `main`
  taking individual linear params `(=> (1 con Console) (1 clk Clock) … Unit)` —
  the checker contract is identical; the record is more ergonomic, individual
  params match the catalog's "granted linear porttypes" wording. Which caps a
  given profile grants (a headless profile might `(grants Console Env)` and no
  NetCap — least authority per profile). Whether `print`/`put`/`trace` retire
  fully or keep an ambient debug alias behind a build flag.
- **Deliberately omitted:** the loader/entry-stub **minting** (the B-substrate:
  how the real fd-1 `Console`, the monotonic `Clock`, the entry-stack `Env`, and
  the socket `NetCap` are constructed at psABI entry and passed to `main`) — the
  C-bridge floor, E34-entry-stub / E32-env-as-entry-stack territory. The
  **checker rule** that enforces `grants`-set == `Grant` fields (a `surface.py`
  `verify_profiles` extension). NetCap's own operations (socket/connect over
  NetCap) — that's E29's surface; E80 only *delivers* the cap.

## 6. Use / modify notes

- **Lands in:** `lib/ports.chiral` (`Console`/`NetCap` porttypes + the
  `console-put` successor; retire ambient `print`/`env-get` from the default port
  set), the **entry/loader** (mint-and-call-`main` — the B→C bridge), and
  `surface.py` profile verification (the new `(grants …)` clause + the
  grants-set == `Grant`-fields check, beside `verify_profiles`).
- **Conformance target:** a demo whose `main : (=> (1 g Grant) Unit)` greets the
  console and reads one env key, built under a profile that `(grants Console
  Env)`, runs and produces output **identical** to today's ambient version —
  **but** a build that calls ambient `print` (not in the port set) or leaves any
  granted cap unconsumed is **REJECTED**. The negative test is the point: ambient
  reach and dropped authority become type errors, not review comments.
- **Open questions:**
  - `Grant`-as-record vs individual linear params on `main` (knob above; likely
    record for one-grant ergonomics) — decidable at spec time.
  - Do command-line **args** arrive through the grant as an `Args`/`Env`-adjacent
    cap, or stay plain entry-stack data? The env-as-entry-stack precedent (E32)
    leans "data", but a cap keeps the authority story uniform — a small design
    call for the spec.
  - The `(grants …)` surface keyword vs reusing the `(ports …)` frozen-set entry
    for cap porttypes — spec's call, checker-mechanical either way.
- **Related:** [[E80-cap-to-main]], `decision-effect-facets` (the recorded
  direction), `banks/capability` (the refraction), [[E29-sockets]] (NetCap
  third, forward contract in its SPEC §6), [[E32-clock-exit-env]]
  (Clock/Timer/Env + env-as-entry-stack), [[E34-elf-writer]] (the entry stub
  that mints at psABI entry), [[E33-process-spawn]] (the spawn→node-main
  precedent this mirrors).
