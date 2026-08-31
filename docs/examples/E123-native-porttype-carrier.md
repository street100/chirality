---
element: E123
slug: native-porttype-carrier
title: "Native porttype carrier / erasure: give opaque linear atoms a runtime carrier so a porttype-carrying crossing lowers to native"
kind: BUILD-PROPER
reference_class: PAPER
ours_source: (none — greenfield; Python floor never modeled porttypes as carriers)
status: drafted
updated: 2026-08-12
---

# E123 — Native `porttype` carrier / erasure

> One worked example, produced by the `worked-example` pre-run. This is a
> BACKEND-INTERNAL element, so the primary deliverable is a **SIZE VERDICT**
> (§6) grounded in the real lowering path, not a conventional-language port.

## 1. Scope

- **Element:** E123 — give each `porttype` opaque linear atom (`Sock`/`LSock`/
  `Fd`/`Clock`/`Timer`/`Env`/`Pool n`) a **runtime carrier** so a crossing whose
  argument or return is a porttype value LOWERS to native machine code.
- **Kind:** BUILD-PROPER (a designed-but-unbuilt bridge between the checker's
  opaque-atom judgment and the backend's word-typed SSA).
- **Why chirality needs its own:** it is the **prerequisite for EVERY native cap
  crossing**. Today porttypes live ONLY in the checker (`data.chiral:333`
  `tv-atom`, registered in `kernel.chiral` `latoms`); the backend has no carrier
  for them, so a porttype-typed def is silently dropped and its entry label is
  never emitted (`compile-emit.chiral:192` `no emitted label for entry`). This
  blocks the native leg of E107 (fd-closes), the E106 native `sv-drain`
  milestone, and all pool-native work (E120/E122) + T7.

## 2. Research

- **Reference class:** PAPER — opaque-newtype / `repr(transparent)` erasure. The
  live authorities read for sizing: `compile-front.chiral` `term->ntalty`
  (28–39), `lower.chiral` `ttype` (34–56) + `UT` (26), `tal-ssa.chiral` `TalTy`
  (21–22), `tal-erase.chiral` (whole), `crossing-wraps.chiral` (whole),
  `ports.chiral` (porttype decls), `loader.chiral` (161–173 atom install),
  `kernel.chiral` `latoms`/`is-linear` (51–67).
- **Key findings (load-bearing, verified in-tree):**
  1. **The carrier decision happens at the FRONT peel, not in `tal-erase`.**
     A checker type `Term` is turned into an `NTalTy` by `term->ntalty`
     (`compile-front.chiral:30`). Its `t-primty` case (32–35) maps ONLY
     `I64`/`Str`/`Bytes`; every other primty — i.e. every nullary porttype —
     falls to `(none)`. `none` means "stays upper", so `peel-def` drops the def
     and no entry label is emitted. **This is the exact reported failure**, and
     exactly why a plain `I64` fd lowers (`I64`→`nt-i64`) but a `porttype Sock`
     does not (`Sock`→`none`→skip).
  2. **A nullary porttype is a `t-primty "Sock"`** (`loader.chiral:161–173`
     installs the name in `latoms`; `loader.chiral:43` `c-primty → t-primty`;
     `kernel.chiral:507` `t-primty n : Type 0`). So the fix targets the existing
     `t-primty` case — no new `Term` constructor.
  3. **`tal-erase` mostly DROPS types.** `i-prim`/`i-call` ignore their `ty`
     field on erase; porttypes have no constructors, so they are never built
     with `i-con` nor scrutinized in a `case`. Once a porttype is assigned a
     one-word carrier upstream, it flows through SSA / reg-alloc / preserve-check
     / emit as an ordinary word register — the backend needs **zero** porttype
     awareness.
  4. **The crossings already route.** `crossing-wraps.chiral:36–38` already maps
     `sock-close`/`lsock-close`/`fd-close` → `nb-sys-close`. The ONLY thing
     stopping them lowering is the dropped carrier, not the wrapper table.
  5. **`Pool n` is different and harder.** It is an *indexed* porttype
     (`ports.chiral:19`); the indexed surface form is flagged DEFERRED in the
     parser (`parse.chiral:39`), and `Pool n` currently hits the `t-tcon` branch
     → `nt-data "Pool" [...]` (a boxed data type), which is the WRONG carrier
     (E122 wants the `[base|size]` cell). Pool is a separate, larger decision.

## 3. Conventional (other-language) approach

Outside chirality this is `repr(transparent)` / opaque-newtype erasure: a type that
is nominally distinct at the type layer shares the representation of its single
underlying field at runtime.

```rust
// Rust: a socket handle is a distinct TYPE, but ABI-identical to its raw fd.
#[repr(transparent)]
struct Sock(RawFd);            // RawFd = i32
extern "C" { fn close(fd: RawFd) -> c_int; }
fn sock_close(s: Sock) { unsafe { close(s.0); } }  // erases to close(i32)
```

- **What the Python floor did instead:** nothing to port — `native.py`/`tal.py`
  never modeled porttypes at all. Their crossing signatures take a **raw `I64`
  fd directly** (`native.py:123` `nb-sys-openat: ([BYTES], I64)`,
  `native.py:141` `nb-sys-send-fd: ([I64,BYTES,I64], I64)`); E106's exit-42 was a
  raw-fd control run. The opaque-linear-atom layer is a chirality-only invention, so
  the checker↔backend carrier bridge is **greenfield in both compilers** — there
  is no erasure logic to port.
- **Assumptions the conventional form bakes in:** the newtype guarantee is a
  *compiler convention* with no proof obligation — nothing stops a second copy
  of `Sock(fd)`, a use-after-`close`, or leaking the fd. chirality refuses exactly
  that: the carrier is erased at the type layer ONLY; the checker's linearity
  (`1 s Sock`) still forbids drop/reuse at compile time.

## 4. The chirality idea

- **Chirality features in play:** the opaque **porttype** atom + QTT linearity (`1 s
  Sock` = use-exactly-once), the `->`/`=>` effect membrane (crossings route
  through E51 wrappers), the closed-sum / boundary-sums discipline, and the
  I64+word floor (every fd/handle is one machine word).
- **The reframing:** a porttype **erases to its carrier at the front peel**
  (`term->ntalty`), so by the time the backend sees it, it is already a
  `tt-i64`. The checker's opacity + linearity guarantees are preserved because
  they were discharged *before* erasure — erasure is a pure type-level identity
  (`Sock` ⟼ `I64`), never a runtime coercion. Carriers:
  `Sock`/`LSock`/`Fd` → `nt-i64` (the fd); `Clock`/`Timer`/`Env` → `nt-i64`
  (their handle is a single word: a clockid / timer fd / env slot); `Pool n` →
  the `[base|size]` cell (E122) — the one non-word carrier, deferred.
- **What chirality makes impossible here:** the `repr(transparent)` escape hatch. The
  carrier is invisible to surface code — you cannot fabricate, copy, or re-read a
  `Sock` from its erased `I64`, because the erasure exists only inside the
  compiler, past the linearity check that already proved single-use.

## 5. Chirality example (fleshed)

The change is one case in the front peel. Today (`compile-front.chiral:30`):

```chirality
; BEFORE: a porttype primty falls through to (none) -> def dropped -> no label.
(def term->ntalty (lam (t)
  (case t
    ((t-primty n)
      (case (str-eq n "I64") (true (some (nt-i64)))
        (false (case (str-eq n "Str") (true (some (nt-str)))
          (false (case (str-eq n "Bytes") (true (some (nt-bytes))) (false (none))))))))
    ((t-tcon dn args) ...) ((t-var i) (some (nt-word))) (_ (none)))))
```

The E123 idea — parse the porttype carrier ONCE at this boundary (boundary-sums:
a carrier is a closed choice, not a scattered `str-eq` chain). Consult the sig's
`latoms` registry (the atoms the checker already recorded) + a small carrier map,
so the classification is a value, not a re-derivation:

```chirality
; a porttype's runtime carrier — the closed choice, minted at the erase boundary
(data Carrier () (car-word) (car-cell))          ; word = one machine word (fd/handle)

; the fd/handle porttypes: every opaque linear atom whose carrier is ONE word.
; (Pool is indexed -> car-cell, handled on the t-tcon path, deferred — see §6.)
(declare porttype-carrier (-> Str (Maybe Carrier)))
(def porttype-carrier (lam (n)
  (case (str-mem n (cons "Sock" (cons "LSock" (cons "Fd"
                    (cons "Clock" (cons "Timer" (cons "Env" nil)))))))
    (true  (some (car-word)))
    (false (none)))))

; AFTER: primty tries the numeric/bytes floor, THEN the porttype carrier.
;   Sock/LSock/Fd/Clock/Timer/Env : t-primty  ->  nt-i64  (the erased fd/handle)
((t-primty n)
  (case (str-eq n "I64")   (true (some (nt-i64)))
  (false (case (str-eq n "Str")   (true (some (nt-str)))
  (false (case (str-eq n "Bytes") (true (some (nt-bytes)))
  (false (case (porttype-carrier n)
    ((some (car-word)) (some (nt-i64)))          ; erase to its one-word carrier
    ((some (car-cell)) (some (nt-bytes)))        ; (Pool path — deferred)
    (none              (none)))))))))))
```

That single case is the whole functional change for the fd/handle porttypes.
Because the def now peels, `close`/`sock-close`/`fd-close` reach `tal-erase`,
where `crossing-wraps` already routes them to `nb-sys-close`, and the entry
label is emitted.

- **Knobs to modify:** the porttype→carrier set (add a new fd-backed cap = one
  membership entry); the `car-cell` branch when `Pool` lands.
- **Deliberately omitted:** the `Pool n` cell carrier and its `t-tcon` handling;
  the parser's deferred indexed-porttype form; any real fd wired end-to-end
  (this is design only, no B1 run).

## 6. Use / modify notes — **SIZE VERDICT**

- **Lands in:** `scaffold/lib/compile-front.chiral` (`term->ntalty`, the primary
  and possibly ONLY functional site). NOT `tal-erase.chiral`/`compile-back.chiral`
  as the catalog row assumed — the carrier is decided at the front peel; once a
  porttype is `nt-i64`, erase/SSA/emit are untouched. This is the key sizing
  finding and a correction to the catalog's stated home.

- **### SIZE VERDICT: S (small)** for the fd/handle porttypes
  (`Sock`/`LSock`/`Fd`/`Clock`/`Timer`/`Env`) — the E107 / E106 unblock. It is
  **one mapping added to one pure function** (`term->ntalty`), ~10–15 lines
  (or a tiny `Carrier` sum + membership helper per boundary-sums). It does **not**
  ripple through `tal-ssa` / reg-alloc / preserve-check / `tal-erase` /
  `compile-back` / emit: a porttype erased to `nt-i64` flows as an ordinary word
  register, and the crossing wrappers (`sock-close`/`lsock-close`/`fd-close`)
  already exist in `crossing-wraps.chiral`. Symmetric safety touch (XS): the twin
  `t-primty`-shaped map in `lower.chiral:ttype` (`u-prim` → I64/Str/Bytes-else-
  none) — likely dead for porttypes once the front assigns the carrier, but it is
  the only place a ripple could hide, so it must be checked/mirrored.

  **Adding `Pool n` pushes the element to M**, and it should be dispositioned
  separately: (a) the indexed-porttype surface form is DEFERRED in the parser
  (`parse.chiral:39`) and may not load from source yet; (b) its carrier is E122's
  `[base|size]` cell (`nt-bytes`-like, NOT a word), and `Pool n` currently hits
  the `t-tcon` → `nt-data "Pool"` branch, the wrong representation. Recommend
  E123 scope to the single-word porttypes (S) and hand `Pool` to E120/E122.

- **Conformance target:** a def taking/returning a `porttype Sock` (e.g. a
  `sock-close`/`fd-close` crossing) emits an entry label and lowers to a native
  ELF whose crossing is `nb-sys-close` on the erased fd — the same exit behavior
  the raw-`I64` control run (E106 exit-42) already produces, now with the
  checker's linearity intact. No B1 run in THIS pass (design only).

- **Open decisions for the spec:**
  1. **Carrier declaration site:** hardcode the fd/handle set inside
     `term->ntalty`, or declare carriers alongside `(porttype Sock)` in
     `ports.chiral` (e.g. `(porttype-carrier Sock word)`) and consult a registry
     built like `latoms`? The registry is the boundary-sums-clean answer but adds
     a loader field; the hardcode is the S path.
  2. **`Clock`/`Timer`/`Env` carriers:** confirm each is genuinely one word
     (clockid / timerfd / env-slot) vs. needing a cell — assumed `nt-i64` here.
  3. **`Pool n`:** in-scope for E123 or deferred to E120/E122? (Recommend defer.)
  4. **`ttype`/`UT` path:** confirm it is dead for porttypes, or mirror the map
     there too.
  5. **Preserve-check:** spot-confirm `tal-check` sees a consistent `tt-i64`
     end-to-end (expected, since the carrier is assigned before compile-fn) — no
     change anticipated, but name it in the gate.

- **Related:** [[E107-cap-close]], [[E106-linear-caps-utf8]], [[E120-pool]],
  [[E122-pool-native]], [[E70-crossing-wraps]], [[E51-syscall-wrappers]].
