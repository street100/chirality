---
element: E45
slug: reflective-floor
title: Reflective floor (what is reconfigurable from inside)
kind: BUILD-PROPER
example: examples/E45-reflective-floor.md
status: audited
updated: 2026-08-02
---

# E45 SPEC — Reflective floor (what is reconfigurable from inside)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.
> **The line is DRAWN** (`decision-reflective-floor.md`, edge 5 / docket D3
> settled 2026-07-27): the running judgment is *staged-in, never granted-to, not
> swappable after staging* — reconfiguration is *unexpressible*, not merely
> forbidden. This SPEC carries that line into a mechanism.

## 1. Deliverable

- **After this runs:** a chirality-side **type-level** artifact (`lib/reflect-floor.chiral`)
  pins the floor as two types and one linear move — a **linear** write-capable
  builder `SigB` (staging-phase only; `install-*` consume-and-return it), a
  **read-only** `Frozen` judgment (no write field, no `unfreeze`), and
  `freeze : (1 SigB) -> Frozen` — the single **linear consume** that draws the
  floor: after it, the write-capable handle no longer exists to name, so
  reconfiguration is *untypeable*, not runtime-refused. Read-only reflection
  (`reflect-formers : Frozen -> List Former`) is expressible; a writeback
  (`Frozen -> SigB`) is not. The succession wall (`recheck`/`stage-successor`) is
  the forward seam to E52. **This is the structural floor made checkable at the
  type level** (the E40 pattern: type-level enforcement, no runtime code).
- **Non-goals (the DECIDED interim, §3 #1):** **no early freeze of the Python
  `kernel.py` `Sig`.** Mid-transition the core is still Python and `Sig` is
  mutable regardless of the chirality-level types; the floor is honored as
  **discipline**, and becomes structural **enforcement** only when `kernel-core`
  is itself chirality carrying this split (a constraint ON the §I/E52 port, not a
  standalone Python edit now). Also out: E58's full read-only reflection API,
  E57 staging machinery, the E52 certificate internals, rung-2 hot self-upgrade.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** **BUILD-L** (E45) — "not built; `Sig` exposes
  every seam as mutable Python attrs." A sibling DECISION-M row ("pin the line")
  is now **satisfied**: `decision-reflective-floor.md` drew the exact `SigB→Frozen`
  line 2026-07-27 — the map row's "exact line NOT drawn" is stale post-decision
  (owed a doc-audit; not this SPEC's surface).
- **Live code this composes with (do NOT respec):**
  - **QTT linearity** (E5/E8) — `freeze` is a `(1 b SigB)` linear consume; the
    checker already rejects reuse/duplication of a linear binder, which is exactly
    what makes the post-freeze write-handle unnameable. No new mechanism.
  - **`kernel.py` `Sig`** (`kernel.py:112`) — the live mutable judgment
    (`ext_check`/`ext_eval`, `rules`, `check_hooks`/`subtype_hooks`/`conv_hooks`/
    `quote_hooks`/`narrow_hooks`/`linear_hooks`/`def_hooks`). E45 pins the
    *type-level split* that the future chirality port of this object must honor; it
    does **not** freeze the Python object now (§3 #1).
  - **E52 `recheck` / `Cert`** — the succession certificate is the payload the
    stager's core re-checks; E45 declares the `recheck` seam, E52 owns its body.
- **True delta:** the chirality `SigB`/`Frozen`/`freeze` type-level artifact + the
  read-only reflection boundary + the forward succession seam — plus the
  **named constraint** on the §I/E52 kernel-core port (carry this split).

## 3. Decisions

Every open question from the example §6, dispositioned.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | The bootstrap-transition mutable path (Python `Sig` is mutable regardless of the chirality types). | **RESOLVED (decided 2026-07-22): accept the interim discipline as the stated rung boundary — no early partial freeze in the Python `Sig`.** | The whole language is discipline-not-enforcement on CPython by design, and the threat model carries **no Python-level adversary at this rung** (`trust-boundary:25-49` — CPython, libc, and the ~1000-line Python checker are trusted Category-A/B by design); an early freeze would add code to throwaway scaffold to defend an out-of-model threat. E45 becomes structural enforcement when `kernel-core` is chirality with `Frozen` unforgeable. "Frozen" is honored, not enforced, until then — the rung boundary the whole language already states. |
| 2 | Do `def_hooks` (post-def callbacks) count as judgment seams that must freeze, or are they staging-only? | **RESOLVED-conservative: `SigB` carries the full seam set the example lists — `def_hooks` freeze with the rest.** Reclassifying a hook as staging-only (never verdict-affecting) is an optimization DEFERRED to the kernel-core-port seam inventory. | The sound default freezes anything that *could* register verdict-affecting behavior; a post-def hook that can install a rule must freeze. Narrowing it is safe only after the port enumerates each hook's reach — deferred, not guessed. |
| 3 | Rung-2 live re-staging of one's own core (hot self-upgrade) vs succession-always-a-fresh-peer. | **DEFERRED → rung 2** (couples the live-environment workload). | Out of rung-1 scope; succession-as-fresh-peer is the rung-1 model. The `Frozen` type does not preclude a later rung-2 certified self-upgrade. |

No blocking NEEDS-AUTHOR: #1 is decided-and-cited, #2 takes the sound conservative
default (narrowing deferred), #3 is a clean rung-2 deferral. Frontmatter `draft`.

## 4. Change plan (ordered, commit-sized)

### Step 1 — the SigB / Frozen type split + the linear freeze
- **Target:** `lib/reflect-floor.chiral` (NEW) + opaque seam stand-ins (`Former`,
  `Rules`, `VHook`).
- **Change:** `data SigB` (linear builder: `formers`/`membrane`/`vhooks`),
  `install-former`/`install-vhook` (`(1 b SigB) -> … -> SigB`, linear update),
  `data Frozen` (read-only, no write field), `freeze : (-> (1 b SigB) Frozen)`
  (consumes the builder via `case`). Transcribe example §5 near-verbatim.
- **Size:** ~M.

### Step 2 — the read-only reflection boundary
- **Target:** `lib/reflect-floor.chiral` + `scaffold/tests/test_reflect_floor.py` (NEW).
- **Change:** `reflect-formers : (-> Frozen (List Former))` (read: fine). The
  **negative** is the point: reuse of a `freeze`-consumed `SigB` is a linearity
  rejection, and there is no `(-> Frozen SigB)` value definable — the writeback
  is unexpressible.
- **Size:** ~S.

### Step 3 — the succession seam (forward to E52)
- **Target:** `lib/reflect-floor.chiral`.
- **Change:** declare `recheck : (-> Frozen Cert Verdict)` and
  `stage-successor : (=> (1 self Frozen) Cert StageR)` — the wall shape
  (accept → spawn successor; reject → refuse). The `recheck` **body** is E52's;
  E45 pins the seam a successor must pass.
- **Size:** ~S.

### Step 4 — the named constraint on the kernel-core port
- **Target:** this SPEC / the §I/E52 port checklist (doc, not code).
- **Change:** record that when `kernel.py`'s `Sig` is ported to the chirality
  `kernel-core`, it MUST carry the `SigB→Frozen` split with `freeze` at
  link/load completion; the Python `Sig` stays interim-discipline (no freeze).
- **Size:** ~S (doc).

## 5. Conformance gate

- **Golden behavior (type-level, the E40 pattern):** `freeze` consumes its
  `SigB` (a second use is a **linearity rejection** at check time); `Frozen`
  exposes only read queries; a writeback `(-> Frozen SigB)` is **not definable**
  (no constructor path Frozen→SigB) — reconfiguration is unexpressible, not
  runtime-refused. The Python suite is **unchanged** (interim discipline; no
  Python freeze).
- **Tests to add (`scaffold/tests/test_reflect_floor.py`, NEW):**
  1. **Linear consume:** `freeze b` typechecks; a program using `b` again after
    `freeze` is rejected (`kernel.py:541`: "binder b declared 1 but used 2
    time(s)") — the floor-drawing move.
  2. **Read-only:** `reflect-formers` over a `Frozen` typechecks and runs.
  3. **Writeback unexpressible:** no total `(-> Frozen SigB)` is definable (an
    attempt hits "empty case"/no-constructor — the negative that IS the element).
- **Green line:** 430 → **≥ 433**; every existing (Python) test green (no `Sig`
  change); `ledger-lint` clean.
- **Done when:** the `SigB→Frozen` linear consume typechecks, reusing the
  consumed builder is a linearity rejection, and a writeback is unexpressible —
  the floor is structural at the type level, with the Python `Sig` untouched.

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - *The actual Python `Sig` freeze* — the DECIDED interim discipline (§3 #1);
    becomes structural enforcement at the chirality `kernel-core` port (§I/[[E52-certificate-split]]).
  - *`recheck` body* — the succession re-check → [[E52-certificate-split]].
  - *Full read-only reflection API* (`reflect-typed`) → [[E58]].
  - *Staging machinery* (how a successor enters) → [[E57]].
  - *Hot self-upgrade* → rung 2 (§3 #3).
  - *`def_hooks` staging-only narrowing* → the kernel-core-port seam inventory (§3 #2).
- **Doc-rot noted:** the CONFORMANCE-MAP "Reflective floor (pin the line)" row
  still says "exact line NOT drawn" — stale post-`decision-reflective-floor`
  (2026-07-27); owed a doc-audit.
- **Links:** [[E52-certificate-split]] (succession payload / `recheck`), [[E58]]
  (`reflect-typed`, the read-only reflection this bounds), [[E57]] (staging),
  [[E12-effect-membrane]] (the bootstrap bridge where the floor is interim
  discipline), `docs/decision-reflective-floor.md` (the drawn line, edge 5),
  `docs/decision-split-checker.md` (`kernel-core`), [[E05-qtt-semiring]] /
  [[E08-linear-kinds]] (the linear consume that makes writeback unnameable).
