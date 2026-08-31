# AUTH-HARNESS-MAP — the authority model vs. the harness that must enforce it

**Written 2026-08-22**, pulling together auth/custody material scattered across
`docs/` + `.planning/` and checking every claim against the live compiler.
Purpose: straighten out which elements exist, which are misfiled, and what this
refactor actually has to build.

Method note: every BUILT/NOT-BUILT below is a **measured** claim (a B1 compile, a
grep with zero use-sites), not a doc reading. Where a doc and the code disagree the
code wins and the disagreement is recorded as a finding — the A5 claim-altitude
rule from `BUILD-ORDER.md` §1.

---

## §1 · The model — settled, and it is coherent

Four documents carry it. Nothing here needs re-deciding.

| doc | status | what it settles |
|---|---|---|
| `docs/decision-syscall-governance.md` | settled 2026-07-28 | The syscall surface is closed by **default-deny at one enforced chokepoint**, NOT by enumerating 362 syscalls. Three mechanisms in dependency order: **E76** chokepoint (name↔number + registry), **E77** rung-1 seccomp derived from the permitted set, **E78** number-in-type attenuation so a profile narrows per component. |
| `docs/permission-model.md` | draft, partly designed | Auth **is** a held linear port; there is no separate permission record. Four grant ops: **Move** (linearity), **Attenuate** (subtyping), **Delegate** (an attenuable dimension), **Revoke**. Only Move is enforced. |
| `docs/decision-deployment-custody.md` | settled 2026-07-26 | *"no ambient authority anywhere; auth = linear ports; configuring auth = ordinary typed code."* Trust comes from **certify-at-staging**, not from who edited a file. Names **C6 (dev-profile ambient threading)** as the unbuilt ergonomics lever. |
| `docs/banks/capability.md` | bank | Non-forgeability = a **conjunction of four mechanisms**, and *"pulling any one leaks"*: (1) porttype has no constructor, (2) the frozen port set, (3) q=1 linearity, (4) the reflective floor (E45). |

**The one honest caveat, from the custody decision itself, kept verbatim so it is
not overstated:** *"At rung 1 the whole model is discipline on a Linux we do not
control, not enforcement — only metal (rung 2) converts it."*

---

## §2 · What is actually enforced by B1 — measured

The compiler that compiles everything. Each row was run.

| mechanism | state | evidence |
|---|---|---|
| **q=1 linearity at function binders** | **ENFORCED** | `(1 f Fd)` used twice → `load: linear binder usage mismatch`, exit 1. Dropping it → same error. |
| **linearity through a `let` rebind** | **ENFORCED** | let-rebinding a linear *param* then closing twice → rejected. |
| **porttype opacity** | **BUILT** | `parse.chiral:674` `handle-porttype`; no data constructors, so a `Sock` is unspeakable in surface syntax. |
| **E76 registry + name↔number** | **BUILT in chirality, NOT ENFORCED** | `sys-check.chiral` (`ck-tiprog`, default-deny by absence) + `target-linux.chiral` (40-row swappable `SysReg`). But `checked-sys-lib` has **one definition site and zero use sites** tree-wide. `compile-emit.chiral` imports `sys-linkage` for `link-lib` only. |
| **the frozen port set** (`profile` / `target`) | ⚑ **CORRECTED 2026-08-25 — no longer absent; parse/judge/store BUILT, enforcement UNMEASURED** | `parse.chiral:1276–1287` dispatches `profile` and `target` alongside `declare`/`data`/`extern`/`porttype` — E2's slice landed 2026-08-22 (`eb7ec6a`) after this row was written, and the manifest reaches `FR` via `compile-front.chiral:320` `(ports-manifest (sig-profiles sig))`. What this row was right about is now one layer down and is stated by the code itself, `parse.chiral:722-723`: *"This slice PARSES + JUDGES + STORES; ENFORCEMENT (emit refusing an off-manifest crossing) reads sig-profiles later and is not here."* Whether emit actually refuses was **not measured in the 2026-08-25 run** and must not be asserted either way here. The stale half is left visible so the drift is readable, ~~*"`profile`/`target` exist solely in `scaffold/chirality/surface.py:213,215` — the legacy oracle. Zero `(profile …)` or `(target …)` forms in the tree."*~~ — counted 2026-08-25, the tree holds **12** such forms across five files under `scaffold/demo/` (`profile-duo`, `profile-headless`, `profile-node-render`, `profile-node-sensor`, `verify-total`). |
| **E77 seccomp / E78 attenuation / E45 reflective floor / E80 cap-reify** | not built | ledger `design`. |
| **the `->`/`=>` effect membrane, at the CALL** | **NOT ENFORCED in B1 — real only in the retired Python oracle** | ⚑ Measured 2026-08-25 against the promoted B1 (1,077,624 B at `4f64d91`), each program resolved with `bin/chirality-resolve.sh` and RUN. A `(-> I64 I64)` def calling the `=>` extern `backend-open` → exit 42. One calling the bound crossing `put` (`scaffold/lib/ports/stdio.chiral:11`, `(=> Str Unit)`) → **writes to stdout**. `(def check (-> Str I64) (lam (s) (observe s)))` beside `(def observe (=> Str I64) …)` → prints, exit 7. `(module tfloor (cat A) (alt upper))` does not catch it either — `crossings` is sense (a) BINDS (`scaffold/tests/test-module-kind.sh:717-719`). The three seams (`on_apply`/`on_binder`/`erased_allow`) exist only at `scaffold/chirality/effects.py:23,38,46`; `kernel.chiral:897` / `:998` / `:14-15` say so in the native compiler's own comments. Minted as **E171**. |

### The through-line

Non-forgeability is a conjunction of four mechanisms. **Two are real in B1**
(porttype opacity, linearity). **One was real only in the retired Python oracle**
(the frozen port set) — ⚑ **no longer true as written: its parse/judge/store half
landed natively at `eb7ec6a`, 2026-08-22, and only its enforcement half is
unmeasured (see the row above).** **One is unbuilt** (E45). The bank's own rule — *"pulling
any one leaks"* — means the conjunction does not currently hold in the native
build path.

**⚑ Added 2026-08-25: the effect membrane is a FIFTH mechanism, and it is on the
oracle-only side of that split too.** It was missing from the table above, which
is how an enforcement inventory ends up flattering: the row that is absent reads
as the row that is fine. Knowing a process's ports by typing it — P3's
*"the port-check is the type-check"* — does not hold for a `def` today, so the
capability story leans on `->`-vs-`=>` at exactly the point nothing checks it.
E171 is the home; `docs/banks/effect-and-alarm.md` §5d is the depth tier.

The E76 chokepoint is the sharpest instance: manifest built, checker built,
verdict computed, **verdict discarded**. Its only enforcement is
`scaffold/tests/test_e76_chokepoint.py:111` asserting `checked-sys-lib == sok`
in Python — which per the BUILD RULE is "never part of any build."

---

## §3 · FINDING — two pure-arrow externs mint linear capabilities unrestricted

**New, measured 2026-08-22. Not covered by any existing element.**

A linear porttype's protection depends on its value being tracked at quantity 1.
An extern declared with the **pure** arrow `->` returns a value that never enters
the linear context, so a porttype minted that way is **unrestricted** — freely
duplicable and freely droppable.

Two externs do this:

```
scaffold/lib/ports.chiral:123   (extern adopt-fd     (-> I64 Fd))
scaffold/lib/backend.chiral:32  (extern backend-open (-> Str Backend))
```

**⚑ Both citations are now STALE, and the finding they name is CLOSED — verified
live 2026-08-25.** E159 flipped both arrows and the `ports.chiral` split moved one
file: today they are `scaffold/lib/ports/fd.chiral:32` `(extern adopt-fd (=> I64
Fd))` and `scaffold/lib/backend.chiral:36` `(extern backend-open (=> Str
Backend))`, the second with E159's reasoning in the four comment lines above it
(*"a mint of a linear result must cross, or the handle never enters the q1
context and the porttype's single-use discipline is vacuous"*). The block is kept
as written because the rest of this section reasons about it. Note the scope of
what E159 fixed: **declaration hygiene on an extern whose result is a linear
porttype** — not a call-graph purity check, which is the separate, still-open
hole in §2's new membrane row (E171).

Measured against the promoted B1 — all three **compile clean, exit 0**:

```
(let (f (adopt-fd 999)) (do (fd-close f) (do (fd-close f) 0)))   ; forge + double-close
(let (f (adopt-fd 1))   0)                                        ; leak (never closed)
(let (b (backend-open "http://x")) (do (backend-close b) (do (backend-close b) 0)))
```

**⚑ THIS SECTION'S DIAGNOSIS WAS WRONG — corrected 2026-08-22, fixed in `7b2b87e`.**
The `adopt-pty` "control" was false: its failure is `no emitted label for entry
compile-main` — a LOWERING failure (no `prim2lib` row, so it never reaches the
checker), and its CORRECT single-close fails identically. I truncated stderr at 70
chars, saw `exit=1`, and read a lowering error as a linearity refusal. Flipping both
arrows closes nothing — measured.

**The real hole is the BINDER QUANTITY.** `parse.chiral`'s `parse-lbind` binds a plain
`(let (f v) …)` at quantity 2 = ω, and `qfits` accepts any number of uses of an ω
binder; `(-> Fd Unit)` is likewise an ω-quantified parameter of a linear type.
`check_data` already had exactly this rule for a data FIELD — the missing twins were
the **let binder** and the **Pi binder**. Only the `(1 f Fd)` parameter control was
real, and it was the actual clue: the explicit `1` is the discriminator.

**Why it matters.** This is capability-bank Shard B mechanism 1 — *"the only way
to obtain one is a host-bound `extern`"*. The extern exists, and hands the
capability out unrestricted from an arbitrary `I64`. `adopt-fd 999` mints an `Fd`
for a descriptor the program was never granted.

**Scope honesty:** at rung 1 an `Fd` is a raw integer anyway, so this does not
*create* new machine authority — the process could already syscall on fd 999.
What it breaks is the **type-level** discipline that the whole model rests on,
and it is exactly the tier E77 (seccomp) and rung 2 are supposed to be the
belt-and-suspenders *for*, not a substitute for.

---

## §4 · Elements — existing, misfiled, and needed

### Exist and are correctly motivated

| element | ledger | what it covers here |
|---|---|---|
| **E76** remainder | `design` | *"profile-permitted-subset + load-time gate owed."* The **load-time gate** is the dead-verdict fix; the **permitted-subset** is per-program narrowing. Both gaps are already named. |
| **E77** | `design` | seccomp-bpf default-deny derived from the E76 set — the OS-level half at rung 1. |
| **E78** | `design` | number-in-type attenuation — `write` but not `socket`, as a subtyping fact. |
| **E80** | `design` | capability reification to `main` (profile-grants-to-entry). |
| **E45** | `design` | reflective floor — mechanism 4 of non-forgeability. DECISION-gated on open-edge 5. |
| **E155** | Wave 4 | resolver named-collision error. **Becomes a prerequisite** if `ports.chiral` is split: the resolver dedups on **basename**, first-occurrence-wins (`bin/chirality-resolve.sh`, `resolve.chiral:15`), so splitting takes the silent-drop surface from 1 name to ~9. |

### Ledger corrections owed (A5 claim-altitude)

1. **E76 catalog says "first slice BUILT 2026-07-28 (registry + name↔number binding in `tal.py check_fn`)"** — that is the *Python* build. The chirality port (`sys-check.chiral`) also exists but is inert. The row should distinguish *ported* from *enforced*.
2. **`sys-check.chiral:12`** cites the mechanism as living in `lib/tal-check.chiral`. It lives in `sys-check.chiral`. A stale citation in the security-critical file.
3. **`permission-model.md`'s** *"everything that does the work already exists"* is already flagged as a stale overclaim by CONFORMANCE-MAP:84. It reads as settled; it is not.

### NOT YET MINTED — proposed, deliberately not deferred to a phantom

Per the deferral rule these are **proposals**, not deferrals. Nothing above depends
on them until they are minted with catalog + ledger rows in one change.

- ~~**[proposed] Linear-result externs.**~~ **MINTED AND BUILT as E159**
  (`LEDGER.md:284`, `built`) — verified 2026-08-25: both externs now carry `=>`
  (`scaffold/lib/ports/fd.chiral:32`, `scaffold/lib/backend.chiral:36`). Kept, struck
  through, so the §3 finding's disposition is readable here rather than only in the
  ledger. ⚑ It closed **declaration hygiene**, not the membrane: a `->` def may
  still CALL an `=>` one (§2's membrane row, E171).
- ~~**[proposed] `profile` / `target` in the native front end.**~~ **DONE as E2's
  slice, `eb7ec6a` (2026-08-22)** — verified 2026-08-25: `parse.chiral:1276–1287`
  dispatches both, and 12 `(profile …)`/`(target …)` forms live under
  `scaffold/demo/`. Struck through rather than deleted so the disposition is
  readable here. ⚑ What survives of it: **E76's remainder still needs the
  ENFORCEMENT half** — `parse.chiral:722-723` says the emit-side refusal of an
  off-manifest crossing "is not here", and this run did not measure whether it
  exists elsewhere.

---

## §5 · What this refactor has to build, in order

1. ~~**`profile`/`target` in `parse.chiral`** — the frozen port set does not exist in
   the native compiler. Everything else in the chain presupposes it.~~ **DONE at
   `eb7ec6a` (2026-08-22), verified 2026-08-25** — `parse.chiral:1276–1287`.
   The chain's first open link is now item 2, and what item 1 was really guarding
   (an off-manifest crossing being *refused*) is `parse.chiral:722-723`'s explicit
   non-goal for that slice.
2. **The load-time gate (E76)** — `emit-elf` refuses unless the verdict is `sok`.
   Turns an existing dead check into physics. Small.
3. **Per-program narrowing (E76 remainder)** — check *this program's* crossings
   against the profile's subset, not the whole library against the whole table.
   This is the only step that makes two configurations differ.
4. **The linear-result extern rule** — close §3.
5. **The `ports.chiral` split into port registries** — downstream of 1–3, and
   gated on **E155**. On its own it is worth **0 bytes**: measured, a program
   importing `ports` and one importing nothing are both exactly 33,144 B, because
   `native-lib ++ link-lib` is appended unconditionally at `compile-emit.chiral:189`.

**The measurement that reorders it all:** the split is source organization until
something checks the declaration. Steps 1–3 are what make a port registry mean
anything.

---

## §6 · Anchors

`docs/decision-syscall-governance.md` · `docs/permission-model.md` ·
`docs/decision-deployment-custody.md` · `docs/banks/capability.md` ·
`docs/banks/port.md` · `.planning/specs/E80-cap-to-main-SPEC.md` ·
`.planning/RUNG2-SECURITY-MODEL.md` · `.planning/BUILD-ORDER.md` (§1 A5, Wave 4)
