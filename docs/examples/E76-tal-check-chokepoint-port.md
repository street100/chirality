---
element: E76
slug: tal-check-chokepoint-port
title: Syscall chokepoint: an enumerated `(crossing → number)` registry at the tal floor. Every `ti-sys` immediate must equal its crossing's registered number; a `sys` op in an unregistered function is refused at tal-check (binds name↔number, closing the "nb-sys-write could carry open's number" hole). A profile bounds the permitted subset (never a syscall no crossing declares). The type-level half of "closed by type, not by number" ([[trust-boundary]] WATCH-4)
kind: BUILD-PROPER
reference_class: OURS/PAPER
ours_source: chirality/tal.py (SYSCALL_TABLE + check_fn sys arm)
status: drafted
updated: 2026-08-04
---

# E76 — Syscall chokepoint: port the tal-floor `(crossing → number)` registry into the chirality tal-check, with the Linux number table behind a swappable target seam

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E76 — the tal-floor syscall chokepoint: an enumerated
  `(crossing → number)` registry, enforced at tal-check so every `sys` op's
  immediate equals its function's registered number and an unregistered `sys`
  op is refused (default-deny by absence).
- **Kind:** BUILD-PROPER (port half). The *mechanism* is proven in
  `chirality/tal.py`; this element ports it into the chirality tal-check and factors the
  Linux number table into a swappable target module.
- **Why chirality needs its own:** the enforcement lives **only** in the Python
  seed (`tal.py check_fn`). The chirality port `lib/tal-check.chiral` (E18) *deferred*
  the sysface rules — so rung-1 **phase B (delete `scaffold/chirality/*.py`) silently
  drops the syscall chokepoint** unless it is ported first. This is a phase-B
  prerequisite, and it is the P1 thesis ("closed by type, not by number") made
  mechanical — a demonstrable security story, not cleanup.

## 2. Research

- **Reference class:** OURS — `chirality/tal.py` lines 92–120 (`SYSCALL_TABLE`) and
  208–229 (the `sys` arm of `check_fn`). PAPER context: capability-based OS
  default-deny (`docs/decision-syscall-governance.md`, author-ratified 2026-07-28).
- **Key findings (the load-bearing facts):**
  1. The registry is a flat **`(fn-name → Linux-x86-64-number)` map**, 15 rows
     today (`nb-sys-read`→0, `nb-sys-write`→1, `nb-sys-mmap`→9, …
     `nb-sys-execveat`→322). Numbers are canonical `unistd_64.h` values.
  2. `check_fn`'s `sys` arm enforces **exactly two bindings**: (a) `fn.name` must
     be *in* the registry — else refuse (**default-deny by absence**); (b) the
     `ti-sys` immediate `nr` must **equal** the registered number — else refuse
     (the "`nb-sys-write` could carry `open`'s number" hole). Then it marks
     `fn.sysface = True` (also set by `bptr`), the flag a floor uses to know a
     body reached the sys face.
  3. **The seam is clean:** the *two checks* are a pure type rule (chirality-permanent
     — rung 2 still needs them); the *table* is Linux psABI data (swappable — it
     is what "chirality is the kernel" replaces at rung 2). WATCH-2/WATCH-3
     ("concentrate psABI knowledge so rung 2 swaps one artifact") already mandate
     this split.
  4. **Out of scope here (owed, not built):** the profile-permitted-*subset* gate
     + load-time enforcement (E76 remainder), the seccomp derivation (E77), and
     number-in-type attenuation (E78). This element ports the *basic mechanism*.

## 3. Conventional (other-language) approach

How it is done in the Python seed — a module-global dict + an inline check that
raises:

```python
# chirality/tal.py — the Linux number table is a module-global dict...
SYSCALL_TABLE = {
    "nb-sys-read": 0, "nb-sys-write": 1, "nb-sys-mmap": 9,
    "nb-sys-exit-group": 231, "nb-sys-execveat": 322,  # ... 15 rows
}

# ...and the check is inline in check_fn, raising on violation:
elif op == "sys":
    _, dst, nr, srcs = ins
    permitted = SYSCALL_TABLE.get(fn.name)          # (a) registered?
    if permitted is None:
        raise TalError(f"{fn.name}: not in registry -- default-deny (E76)")
    if nr != permitted:                             # (b) name<->number bound?
        raise TalError(f"{fn.name}: issues {nr}, registered for {permitted} (E76)")
    _check_args(env, fn, "sys", [I64]*len(srcs), srcs, regty)
    regty[dst] = I64
    fn.sysface = True                               # reached the sys face
```

- **Assumptions it bakes in:** (1) the table is a **module-global** — invisible,
  ambient, one-per-process (chirality has no module-global config; WATCH-1 says
  configuration is per-runtime). (2) **exceptions** for the reject path — chirality
  has no exceptions; a checker returns a result sum. (3) Linux numbers are
  **hardcoded into the trusted checker** — the very coupling rung 2 must sever.

## 4. The chirality idea

Split the one Python arm into **a permanent type rule + a swappable data module**,
joined at a named seam.

- **Chirality features in play:** categories A/B/C (the *rule* is A-typed and trusted;
  the *number table* is B-referent Linux data behind a C-style target module);
  errors-as-values (`CkR`, no exceptions); the profile/target seam
  (`decision-profiles` — a manifest over a frozen port set with a target
  requirement); the effect membrane (a `sys` op only appears in an E51-bound
  `=>` crossing, and the arm marks the sysface bit that the row check reads).
- **The reframing:** `lib/tal-check.chiral` gains a `sys` arm that takes the
  **registry as a value** (threaded in, not a global) and enforces the two
  bindings, returning `CkR`. The registry itself is provided by
  `lib/target-linux.chiral` — the one artifact a rung-2 backend swaps. The trusted
  checker no longer contains a single Linux number.
- **What chirality makes impossible here:** an *unregistered* `sys` op does not
  type-check (default-deny is a checker verdict, not a lint); a registered
  crossing *cannot be re-pointed* at another number (the immediate is checked
  against the value, not the name); and a Linux constant **cannot become
  load-bearing in the trusted rule** — it lives only in the swappable target
  value (WATCH-2 enforced structurally).

## 5. Chirality example (fleshed)

> **IMPLEMENTATION NOTE (correction surfaced at implement time, 2026-08-04).**
> The pre-run below assumed the chokepoint's home is the SSA checker
> (`ck-instr` over `lib/tal-ssa.chiral` `Instr`). Verifying against the code
> showed that is **wrong**: in chirality a `sys` never appears in the SSA `Instr` —
> the `nb-sys-*` crossings are hand-authored `TIFn`s (`ti-sys` in the **erased
> tal-ir**, `lib/sys-tal.chiral`), which `ck-fn` never checks. So the chokepoint
> lives in a **walk over the tal-ir wrappers** (`lib/sys-check.chiral` `ck-tifn`/
> `ck-tiprog`), the faithful analog of `tal.py check_fn`'s `sys` arm applied to
> the IR where `sys` actually occurs. The **seam is unchanged** (permanent
> mechanism + `ck-sys` two-binding rule vs the swappable `target-linux` number
> table); only the *home IR* moved. The snippet below is kept as the rationale;
> the shipped shape is `ck-sys : (-> SysReg Str I64 SysR)` + the `TCode` walk.

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
; ============================================================================
; lib/target-linux.chiral  — THE SWAPPABLE BACKEND. Pure B-referent data: the
; Linux x86-64 permitted set. A rung-2 backend replaces THIS FILE and nothing
; else. No number in the trusted checker; every number lives here.
; ============================================================================
(import "prelude")

(data SysRow () (sys-row (name Str) (num I64)))            ; one crossing binding
(data SysReg () (sys-reg (rows (List SysRow))))            ; the permitted set

(def linux-syscalls (-> Unit SysReg)                      ; the 15-row registry
  (lam (u)
    (sys-reg
      (cons (sys-row "nb-sys-read"       0)
      (cons (sys-row "nb-sys-write"      1)
      (cons (sys-row "nb-sys-mmap"       9)
      ; … nb-sys-close 3, lseek 8, mprotect 10, munmap 11, poll 7, nanosleep 35,
      ;   send-fd 46, ftruncate 77, clock-gettime 228, memfd 319 …
      (cons (sys-row "nb-sys-exit-group" 231)
      (cons (sys-row "nb-sys-execveat"   322)
            (nil))))))))))

; ----------------------------------------------------------------------------
; lib/tal-check.chiral  — THE PERMANENT MECHANISM. A total structural lookup +
; the two-binding check, returning CkR (errors-as-values). No Linux data here.
; ----------------------------------------------------------------------------

; default-deny by ABSENCE: an unregistered name returns none
(def sys-lookup (-> SysReg Str (Opt I64))
  (lam (reg nm)
    (case reg ((sys-reg rows) (row-find rows nm)))))       ; structural over rows

; the E76 chokepoint, the `sys` arm of ck-instr. `fname` = the enclosing fn's
; name (threaded from ck-fn); `reg` = the target registry (threaded, not global).
; CkR = (ck-ok REnv) | (ck-err Str) — the E18 result sum. Returns the register
; env with dst:I64 AND the sysface bit set (so the caller marks the fn).
(def ck-sys (-> SysReg Str Reg I64 (List Reg) REnv CkR)
  (lam (reg fname dst nr srcs renv)
    (case (sys-lookup reg fname)
      ; (a) not registered -> refuse (default-deny, not discipline)
      (none (ck-err (bcat fname
              ": syscall crossing not in permitted registry -- default-deny")))
      ; (b) registered -> the immediate MUST equal the registered number
      ((some permitted)
        (if (=i nr permitted)
            (ck-args-then reg srcs dst renv)              ; args:I64, dst:I64, sysface
            (ck-err (bcat fname
              ": ti-sys number does not match registered number (E76)")))))))
```

- **Knobs to modify:** swap `linux-syscalls` for a different target's registry
  (the whole rung-2 move); add a crossing = one `sys-row` + its `nb-sys-*` def;
  a later profile narrows the registry to a permitted *subset* before it reaches
  `ck-sys` (E76 remainder — a filter over `rows`, unchanged mechanism).
- **Deliberately omitted:** the `bptr` sysface arm (marks sysface, no registry
  check — port alongside, trivial); `_check_args` byte-plumbing (`ck-args-then`
  elided); the profile-subset gate, seccomp (E77), and number-in-type (E78).

## 6. Use / modify notes

- **Lands in (as shipped):** the mechanism → **new** `lib/sys-check.chiral`
  (`SysRow`/`SysReg`/`SysR`, `sys-lookup`, `ck-sys` two-binding rule, and the
  `ck-ti-instr`/`ck-ti-code`/`ck-tifn`/`ck-tiprog` walk over the tal-ir); the
  swappable data → **new** `lib/target-linux.chiral` (`linux-syscalls`); the
  applied gate → `lib/sys-linkage.chiral` `checked-sys-lib`
  (`ck-tiprog linux-syscalls sys-lib`). `tal-check.chiral` is left untouched
  (stays the pure SSA floor its header promises).
- **Conformance target:** differential vs `tal.py check_fn`'s `sys` arm over the
  three verdicts: (1) **registered + matching number** → accept, sysface set;
  (2) **unregistered fn** → reject (default-deny); (3) **registered but wrong
  number** → reject (name↔number binding). Plus: the full suite stays green, and
  swapping the target value demonstrably re-points the numbers.
- **Open questions (for the implementation run):**
  1. **How the registry reaches `ck-fn`** — threaded as a `ck-prog`/`ck-fn`
     parameter (preferred; matches WATCH-1 per-runtime, no global) vs a fixed
     import. The example threads it; confirm the E18 `ck-fn` signature can carry it.
  2. **Where `fname` comes from** in the E18 IR — `ck-fn` has the `TalFn` name;
     confirm it is in scope at the `ck-instr` call (thread it if not).
  3. **The sysface bit** — E18 `ck-fn`'s return shape must carry "reached the sys
     face" (a bool alongside `CkR`, or a field on the ok verdict).
- **Related:** [[trust-boundary]] (WATCH-4, the debt this pays), E18 (the
  tal-check this extends), E77 (seccomp — same permitted set, OS-level, deferred),
  E78 (number-in-type attenuation), E51 (the bound crossings the sysface marks).
