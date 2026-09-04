---
element: E128
slug: apc-handshake
title: APC structured-side-channel **handshake**: the wire negotiation protocol that *sets* `term-structured?`'s bit — an APC query (`ESC _ ? … ST`) the emulator answers with an APC reply, so a dumb terminal stays silent and a timeout ⇒ `false` (aligned with E112's APC transport). Split out of E112 (the codec consumes the `Bool`; this negotiates it) 2026-08-12 by the E112 spec-revision. Its spec resolves the exact query/reply bytes + timeout
kind: BUILD-PROPER
example: examples/E128-apc-handshake.md
status: audited
updated: 2026-08-12
---

# E128 SPEC — APC structured-side-channel **handshake**: the wire negotiation protocol that *sets* `term-structured?`'s bit — an APC query (`ESC _ ? … ST`) the emulator answers with an APC reply, so a dumb terminal stays silent and a timeout ⇒ `false` (aligned with E112's APC transport). Split out of E112 (the codec consumes the `Bool`; this negotiates it) 2026-08-12 by the E112 spec-revision. Its spec resolves the exact query/reply bytes + timeout

> ⚑ **TRIAGE 2026-09-04 — NEEDS-REPLAN.** 0 of 4 steps are executable at HEAD.
> Every target is a `TUI/` path; repoint at `lib/protocol/apc.chiral` and
> `tools/test/samples/`. Intent survives whole. Bucket and evidence:
> `records/spec-tier-triage.md`. This file was not rewritten and its `status:`
> was not changed.

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `TUI/apc.chiral` (beside E112's codec) gains the handshake —
  a `HandshakeR` result sum, the pure envelope helpers `apc-query : (-> Str Bytes)`
  (nonce → `ESC _ ? chirality1:<nonce> ST`) and `reply-ok? : (-> Bytes Str Bool)`, and
  the crossing `negotiate : (-> (0 dl I64) (=> (1 t Terminal) (1 c Clock)
  HandshakeR))` that writes the query out the `Terminal`'s write authority, reads a
  reply within a `dl`-ms deadline (`poll-fds` / `poll-timeout`), and returns
  `hs-structured`/`hs-plain`/`hs-err` — threading the linear `Terminal` (and
  `Clock`) on **every** arm. The `Terminal` acquisition path calls `negotiate` once
  and stamps `structured` onto the cap, which is exactly the `Bool` E112's
  `term-structured?` reads. Observable delta: against a chirality-emulator responder the
  acquired cap reports `structured`; against a dumb terminal it reports `plain`
  within `dl` ms and the terminal shows nothing (the APC query is discarded).
- **Non-goals (residue §6):** the chirality-emulator's *responder* side (it answers the
  query — home T15, the (M) backend); the reply **feature-bitset** schema (v1 is a
  one-bit presence probe — a version tag only); retry-on-partial-read.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E128 postdates the CONFORMANCE-MAP snapshot;
  BUILD-PROPER. Split from E112 (2026-08-12): E112 *consumes* `term-structured?`'s
  `Bool`, E128 *sets* it. Nothing in the negotiation exists yet.
- **Live code this composes with (name; do NOT respec):**
  - `scaffold/lib/poll.chiral:14,68` — `PollR = poll-ready | poll-timeout | poll-err`
    + `poll-fds : (=> (List I64) I64 PollR)` (the deadline-into-ms-timeout read —
    **built**; the exact mechanism the timed read uses).
  - `scaffold/lib/ports.chiral:121,136` — `(porttype Clock)` + `time-mono : (=> (1 c
    Clock) TimeR)` (**built** — the nonce source).
  - `TUI/docs/TERMINAL-PORT-DESIGN.md:109` — the verbatim signature `term-structured?
    : (=> (1 t Terminal) (Pair Bool Terminal))`, negotiated once at acquisition, and
    §2's degrade rule.
- **Dependencies NOT yet built (E128 is implement-gated on them):** the **`Terminal`
  port** (`porttype Terminal`, `term-write`, `term-structured?`) and **E112's
  `TUI/apc.chiral`** — both are **designed + audited but not implemented** (E112 is
  `audited`; the Terminal port is T13/E112's deliverable, TERMINAL-PORT-DESIGN §2).
  E128's spec is complete and implement-ready *as a contract*; its **implementation
  runs after E112 + the Terminal port land** (§4 gate).
- **True delta:** the `HandshakeR` sum + `apc-query`/`reply-ok?` pure helpers + the
  `negotiate` crossing + the one-line acquisition wiring that stamps the bit. Built
  on `poll`+`Clock` (present); slots into `apc.chiral`+the Terminal port (E112).

## 3. Decisions

Every open question from the example §6, dispositioned. RESOLVED only when
derivable from a settled doc / the transport (cite); genuinely novel design →
NEEDS-AUTHOR, surfaced, never answered on the author's behalf.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | The query/reply byte grammar (E112 spec dec #5 handed this to E128) | **RESOLVED → `ESC _ ? chirality1:<nonce> ST` query / `ESC _ ! chirality1:<nonce> ST` reply** | Derivable from the transport: ECMA-48 APC (`ESC _`…`ST`, decimal 27 95 … 27 92) with a **marker byte** right after `ESC _` — `?` (63) query, `!` (33) reply — which cannot collide with an E112 render frame (whose first payload byte is a constructor tag `t/s/S/h/T/r`). Payload stays printable (graphic ASCII). Version tag `chirality1` gates protocol evolution. Constants are **decimal** (reader is decimal-only, `sexp.chiral:133`). |
| 2 | The read deadline `dl` | **RESOLVED → 50 ms default, caller-overridable** | Prior-art default for terminal capability probes (DA1/XTVERSION/kitty-query all use ~tens of ms); folds straight into `poll-fds`'s ms timeout (`poll.chiral:68`). `dl` is a parameter (erased-usage size-arg), so a caller on a slow link can raise it. Sub-ms precision (`ppoll`/`timerfd`) is unneeded — deferred (§6). |
| 3 | Nonce — required, or presence-of-reply enough? | **RESOLVED → required, from the `Clock`** | A leftover byte sequence in the input buffer could mimic a reply; echoing a per-acquisition nonce (derived from `time-mono`, `ports.chiral:136`) and requiring it back in `reply-ok?` makes the match sound. Cheap (one `Clock` read already on the acquisition path) and closes a real false-positive. |
| 4 | Reply capability schema — presence-bit vs feature bitset | **DEFERRED → v1 presence-only; feature bitset = follow-on (home T15)** | v1 answers one question: "are you a chirality emulator that speaks structured APC?" — a `Bool`. A feature/version negotiation (which block-id scheme, image support, …) is a richer reply the emulator (T15) and a later E128 revision own. The `chirality1` version tag reserves the evolution slot. |
| 5 | Home + implement ordering | **RESOLVED → `TUI/apc.chiral` beside E112; implement AFTER E112 + Terminal port** | The pure helpers live beside E112's codec (same file, same transport); `negotiate` + the acquisition wiring live on the Terminal port impl. Both are E112/T13 surfaces — **not built yet** (§2). E128's implement run is gated on them; the spec is a ready contract. Not `blocked` (no author call owed) — dependency-sequenced. |

No NEEDS-AUTHOR: #1–#3/#5 derive from the transport / built substrate; #4 is a
named DEFER with a home. Spec-audited (`audited`); implementation is
dependency-sequenced after E112 + the Terminal port land.

## 4. Change plan (ordered, commit-sized)

> **Gate:** Steps 1–4 run **after** E112 (`TUI/apc.chiral` codec) and the `Terminal`
> port (`porttype Terminal` + `term-write` + acquisition) are implemented. The
> design is turnkey; do not begin until those land.

### Step 1 — `HandshakeR` + the pure envelope codec
- **Target:** `TUI/apc.chiral` (beside E112's `enc`/`dec`).
- **Change:** `(data HandshakeR () (hs-structured (1 t Terminal)) (hs-plain (1 t
  Terminal)) (hs-err (msg Str) (1 t Terminal)))`; `apc-query : (-> Str Bytes)`
  building `ESC _ ? chirality1: <nonce> ESC \` (decimal 27/95/63/33/92 constants);
  `reply-ok? : (-> Bytes Str Bool)` checking a well-formed `ESC _ ! chirality1:<nonce>
  ST` that echoes the nonce. Pure `->`, allocation-bounded.
- **Size:** ~S

### Step 2 — the `negotiate` crossing
- **Target:** `TUI/apc.chiral` (or the Terminal port impl beside `term-write`).
- **Change:** `negotiate : (-> (0 dl I64) (=> (1 t Terminal) (1 c Clock)
  HandshakeR))` — mint a nonce from `time-mono` (thread `Clock`), `term-write` the
  query (thread `Terminal`), `poll-fds [readfd] dl`: `poll-timeout → hs-plain`;
  `poll-ready → read → (case (reply-ok? bytes nonce) (true hs-structured) (false
  hs-plain))`; `poll-err → hs-err`. The linear `Terminal`+`Clock` return on **every**
  arm (checker-enforced; `case`, never `let`).
- **Size:** ~M

### Step 3 — wire into `Terminal` acquisition
- **Target:** the `Terminal` port impl (acquisition path, beside `term-structured?`).
- **Change:** on acquire, call `negotiate` once; stamp `structured = true` on the
  cap for `hs-structured`, `false` for `hs-plain`/`hs-err`. `term-structured?` (E112)
  then reads it. One `case` on the `HandshakeR`.
- **Size:** ~S

### Step 4 — conformance sample
- **Target:** `TUI/samples/` — a compile-with-B1-and-run driver with a **mock
  responder** (a socketpair/pty peer that replies with a well-formed APC reply for
  the "structured" case, and one that stays silent for the "plain"/timeout case).
- **Change:** structured-peer → `hs-structured` (exit 42); silent-peer → `hs-plain`
  within `dl` ms; corrupted/nonce-mismatched reply → `hs-plain`. All-pass ⇒ 42.
- **Size:** ~S

## 5. Conformance gate

- **Golden behavior:** a well-formed nonce-echoing APC reply within `dl` ms →
  `hs-structured` (cap reports `structured`); no reply within `dl` → `hs-plain`
  (cap reports `plain`, terminal shows nothing — APC discarded); a
  malformed/nonce-mismatched reply → `hs-plain` (never a false `structured`); the
  linear `Terminal`+`Clock` thread on every arm.
- **Tests to add:** the Step-4 mock-responder sample (compile-with-B1, exit 42 iff
  structured/plain/malformed all classify right) + a checker-rejection negative
  (dropping the `Terminal` on any arm fails the linearity check, mirroring the E106
  pattern). Native compile+run (no fixpoint — non-compiler program).
- **Green line:** the TUI sample is a B1 compile-and-run program (not the pytest
  oracle); gate = the sample's exit 42 + no regression. ledger-lint clean.
- **Done when:** the mock-responder sample exits 42 (structured/plain/malformed all
  correct, cap threaded once) — runnable only after E112 + the Terminal port land.

## 6. Residue & links

- **Deliberately unbuilt:** the chirality-emulator **responder** (answers the query —
  home **T15**, the (M) backend); the reply **feature-bitset** schema (§3 dec #4 —
  follow-on E128 revision + T15); **retry-on-partial-read**; sub-ms timer precision
  (`ppoll`/`timerfd`, §3 dec #2).
- **Implement-gated on:** **E112** (`apc.chiral` codec) + the **`Terminal` port**
  (T13/E112) — both audited/designed, not built. E128 lands after them.
- **Follow-on:** completes the (M)-tier negotiation so E112's `term-draw` tier
  selection has a real bit to switch on; the writer-identity / trusted-display
  surface (the differentiator) rides the structured channel once negotiated.
- **Related:** [[E128-apc-handshake]] · [[E112-apc-sidechannel]] (consumes the bit) ·
  `TERMINAL-PORT-DESIGN.md` (§2 degrade, §8 item 4) · E31 `poll` (timed read) ·
  E32 `Clock` (nonce) · T13/T15 (Terminal port + (M) backend) · [[pattern-boundary-sums]].
