# S17 — manas run-view: token streaming (be-chat-stream on-delta) — IMPLEMENTATION SPEC

Stage 3 of 5 (example → audit → spec → audit → implement). Source of truth for
the implementer. Reads with `.planning/scriba-examples/S17-manas-token-streaming.md`
(the worked example, audited PASS — its three premise corrections are verified
against code: `r-stream (source-id Str)` exists at `render.chiral:10` so there is
**NO new render node**; `chat.chiral` blocks via `agent-run-transcript` so it is
**NOT** the streaming precedent; the real precedent is `coordinator.chiral:37-42`
`be-chat-stream … (lam (d) (put d))` + `scaffold/samples/stream-ollama.chiral`; and
scriba has **no mutable ref** (`command-loop.chiral:457`) so the growing text is
painted transiently, not stored). The example stays the rationale; this SPEC is the
contract.

**Gate:** S15 (`TUI/scriba/manas-runview.chiral` — the run-view frame S17 upgrades:
`RunView`/`RunPhase`/`RvCall`, `runview-render` `:98`, `fan-render` `:162`,
`runview-drive` `:181`, `repaint-runview` `:153`, `rv-with-calls` `:124`,
`len-rvcall` `:138` — all shipped) + `be-chat-stream` (`scaffold/lib/backend.chiral:122`
— the primitive threaded; its 4th arg is the `(=> Str Unit)` on-delta, returns the
same `ChatR` as `be-chat`). Both landed. Seed: `coordinator.chiral:37-42` `run-cycle`
(the proven `(lam (d) (put d))` on-delta over `be-chat-stream`) + `stream-ollama.chiral`
(the `chat-read → put` loop, mesh-verified). Pattern: S15's pure/effectful split
(`runview-render` pure `->`, `fan-render` effectful `=>`) + its closed-sum `RunPhase`
(S17 adds `rv-streaming`, forced by the exhaustive `case`).

**Scope:** upgrade S15's per-expert *incremental* render (blank row, then whole row
per `be-chat` return) to **token-by-token streaming** — each fired expert's row grows
inline as the model generates, then settles into the exact `RvCall` row S15 already
renders. The seam-swap is `be-chat` → `be-chat-stream` behind a new `call-expert-stream`
twin, threading the coordinator-proven `(lam (d) (put d))` on-delta down through
`fan-render`; a new `rv-streaming` `RunPhase` marker drives the open-row prefix.
**The combiner streams too** (`call-combiner-stream`, §6 D4 — the example §7.2
"fold it in" decision). **Synchronous/blocking is accepted** (as S15/chat mode);
async and concurrent multi-expert streams are residue (§9). **No stored growing
text** (no mutable ref — the tokens are `put` transiently and reconciled to the
returned `ChatR`). **A streamed run's `RunManifest` is byte-identical to a
non-streamed one** given the same final responses — a spec invariant (§5) and a gate
(§8). S17 ends at **a run whose in-flight expert (and combiner) row grows
token-by-token, then settles into the typed `RvCall`/manifest S15 already renders.**

---

## §1 Deliverable + acceptance test

**Deliverable (one sentence):** the manas run-view streams — `runner.chiral` gains an
additive `call-expert-stream` (and `call-combiner-stream`) twin identical to
`call-expert`/`call-combiner` but over `be-chat-stream` with a `(=> Str Unit)`
on-delta parameter (so the twin's `ExpertOutcome`/`CombinerOutcome` is equal to the
non-stream call's given the same final text — the manifest stays byte-identical);
`manas-runview.chiral` gains one `rv-streaming` `RunPhase` marker (which expert +
slot/model is live), one `streaming-row` open-row renderer, one `rv-streaming-of`
pure builder, and swaps `fan-render`/`runview-drive`'s calls to the streaming twins
with the `(lam (d) (put d))` on-delta — so each fired expert's (and the combiner's)
row grows token-by-token, then the settle repaint (full clear + redraw) replaces the
transient stream with the authoritative settled row — all reusing S15's `vm-runview`
mode, faces, and row helpers with **no new render node, no new `VimMode`, and no
change to the `:run`/`:compose` fire entries**.

**Acceptance test (two legs):**

1. **Unit (pure, no PTY, no network — the acceptance-critical leg):** a new B1 test
   root `TUI/scriba/scriba-runview-stream-test.chiral` (mirroring
   `scriba-runview-test.chiral`'s idiom — functions returning an `I64` exit code,
   `compile-main` ANDs them; exit 0 = pass) drives `runview-render` over a `RunView`
   carrying an `rv-streaming` phase and byte-checks the **open streaming row prefix**
   (`"  >>   claim-vs-source   (reasoner -> qwen2.5:0.5b)  "`) and `phase-tag`
   (`"(streaming 0)"`), plus re-asserts the S15 settle path (an `rv-done` view still
   renders the `OK`/`BAD` rows unchanged). Build+run:
   `chirality_blob scaffold/lib TUI/scriba/scriba-runview-stream-test | scaffold/build/B1 > /tmp/rs.elf && chmod +x /tmp/rs.elf && /tmp/rs.elf; echo $?` → `0`.

2. **Build + PTY smoke (the wiring + liveness + byte-identical gate):** `bin/scriba`
   builds (B1 compile, exit 0). In a PTY, mesh reachable (`100.64.0.5:11434`):
   `:run` fires. The `GATE` line renders pre-network (S15, unchanged); then for the
   **first** fired expert an **open `>>` row** appears (id + `slot -> model`, cursor
   parked at the end) **before any token**, then tokens paint inline on that row as
   the model generates, then the row **settles** to the green `OK` / red `BAD` row S15
   renders and the next expert's open row begins; the combiner's yield streams the
   same way; ESC returns to Normal. **Byte-identical check:** the settled manifest is
   the normal S15 manifest — same fired set, same per-expert `OK`/`BAD` outcomes, same
   combiner yield structure — i.e. streaming changed only *when the text is observed*,
   not *what settled*.

The unit leg is the contract for the pure render (open-row prefix faithful with no
network). The PTY leg is the wiring/liveness smoke **and** the byte-identical-manifest
gate (§5, §8.2). A mid-stream failure must settle **red** (`chat-bad` → `expert-bad`),
never crash.

---

## §2 Baseline delta — files created / modified

Grounded in the live tree. Line anchors are as-read at spec time.

### 2.1 `scaffold/lib/manas/pipeline/runner.chiral` — **MODIFIED** (two additive streaming twins)

**This is the one engine-file change** (unlike S15/S16, which touched no engine
file). It is **purely additive**: two new top-level `def`s beside `call-expert`
(`:66`) and `call-combiner` (`:87`); **`call-expert`/`call-combiner` are byte-for-byte
unchanged**, and every other def (`parse-findings` `:46`, `assemble-prompt` use,
`fan-experts` `:99`, `run-pipeline` `:121`) is untouched. `runner.chiral` is the right
home because it is *the* `be-chat` wrapper's home — the ONLY manas-pipeline module
that crosses the backend seam (`runner.chiral:4-6`), and the single source of the SEES
prompt + JSON instruction + `parse-findings` + `expert-ok`/`expert-bad` mapping (§6
D3). Putting the streaming twin anywhere else would duplicate that contract and let it
drift. The two twins are:

```
; runner.chiral, beside call-expert (:66). IDENTICAL body; be-chat -> be-chat-stream +
; the on-delta threaded as one extra parameter. drain-stream's acc (backend.chiral:118)
; accumulates the full assistant text and returns it in chat-ok acc — the SAME string
; call-expert's be-chat returns — so parse-findings runs on the same text and the
; ExpertOutcome is EQUAL to call-expert's (the byte-identical-manifest invariant, §5).
(def call-expert-stream (=> Backend Expert Str (List (Pair Str Str)) Str (=> Str Unit) ExpertOutcome)
  (lam (b ex doc extra model on-delta)
    (case (be-chat-stream b model
            (cons (msg "user"
                    (str-cat (assemble-prompt ex doc extra nil)
                      "\n\nReturn ONLY a JSON array of objects, each with string fields \"kind\", \"target\", \"body\". No prose."))
                  nil)
            on-delta)
      ((chat-ok t)    (expert-ok (parse-findings t) t))
      ((chat-bad s r) (expert-bad r (str-cat "http-" (i64->str s)))))))

; beside call-combiner (:87). Same one-line change (be-chat -> be-chat-stream + on-delta);
; render-findings / assemble-prompt / the CombinerOutcome mapping are byte-identical.
(def call-combiner-stream (=> Backend Expert (List Finding) (List Str) Str (=> Str Unit) CombinerOutcome)
  (lam (b ex findings fired-ids model on-delta)
    (case (be-chat-stream b model
            (cons (msg "user" (assemble-prompt ex (render-findings findings) nil nil)) nil)
            on-delta)
      ((chat-ok t)    (combiner-ok t fired-ids t))
      ((chat-bad s r) (combiner-bad r (str-cat "http-" (i64->str s)))))))
```

One import addition: `be-chat-stream` from `backend` — but `runner.chiral` already
`(import "backend")` (`:17`); the twins reference `be-chat-stream` (public,
`backend.chiral:122`) from the same import, **no import-list change** (only the comment
`; be-chat (…)` on `:17` widens to name `be-chat-stream` too). The `Msg`/`msg`/`ChatR`
ctors, `assemble-prompt`, `render-findings`, `parse-findings`, `expert-ok`/`expert-bad`/
`combiner-ok`/`combiner-bad` are all already in scope (used by the non-stream twins).

### 2.2 `TUI/scriba/manas-runview.chiral` — **MODIFIED** (the streaming marker + open row + on-delta swap)

The whole scriba-side delta lives here — S15's frame is reused, not replaced. Five
touch-points:

- **the `rv-streaming` `RunPhase` arm** (§3.1) — one new constructor beside
  `rv-calling` (`:40`), carrying `idx`/`id`/`slot`/`model` (enough for the open row);
- **`phase-tag`'s forced arm** (§3.1) — the closed sum makes "forgot the streaming
  state" a type error (`:83-91`);
- **`streaming-row`** (§3.2) — the open `>>` row renderer (pure, reuses `manas-ok` +
  `r-face`/`r-text`, **no new node**);
- **`runview-render`'s `rv-streaming` arm** (§3.2) — appends `streaming-row` when live;
  every other phase renders the exact S15 frame (`:98-107`);
- **`rv-streaming-of`** (§3.3) — a pure builder (the sibling of `rv-with-calls` `:124`)
  that sets `phase = (rv-streaming (len-rvcall acc) id slot model)`, `done = acc`;
- **`fan-render`** (§4.1) — swaps `call-expert` → `call-expert-stream … (lam (d) (put d))`
  and paints the open row *before* the call (`:162-173`);
- **`runview-drive`** (§4.2) — swaps `call-combiner` → `call-combiner-stream …
  (lam (d) (put d))` and paints the combiner open row before it (`:193`).

One import addition: `(import "ports")` for `put` (the terminal-write crossing the
on-delta uses — the same import `coordinator.chiral:20` adds for its `(lam (d) (put d))`;
`manas-runview.chiral` does not yet import it). The `runner` import (`:29`) widens to
name `call-expert-stream`/`call-combiner-stream` (same module, no new import line).

### 2.3 `TUI/scriba/scriba-runview-stream-test.chiral` — **NEW** (the unit gate)

A B1 test root mirroring `scriba-runview-test.chiral` (functions → `I64` exit code;
`compile-main` ANDs them; exit 0 = pass). Imports `manas-runview` + `manas/core/types`
and asserts `runview-render` over an `rv-streaming` `RunView` (the open-row prefix +
`phase-tag`) plus the unchanged S15 settle rows. **No network, no fork, no PTY** — the
whole point of the pure render core. Detailed §8.1.

### 2.4 No other file changes

- **`render.chiral` — NO CHANGE.** `r-stream (source-id Str)` already exists
  (`render.chiral:10`); it is the **APC side-channel placeholder** (carries a source-id,
  **no text**), not the streaming path. S17's synchronous path paints tokens with
  `put`, so **no new render node** and no face change (`manas-ok`/`manas-bad` from S15
  render both the open and settled rows). (`runview-render` *may* optionally drop an
  `(r-stream (str-cat "expert:" id))` marker at the streaming row for the APC tier —
  reusing the already-built node — but that is not required and is not specced here;
  the buildable path is `put`.) (§6 D6.)
- **`vim-mode.chiral` — NO CHANGE.** S17 reuses S15's `vm-runview` mode verbatim; it
  adds **no new `VimMode` variant** (§6 D5). The `rv-streaming` marker rides *inside*
  `RunPhase`, which rides inside `RunView`, which the existing `(vm-runview (rv RunView))`
  already carries — so `mode-name` and the two `case mode` arms (dispatch, resize) are
  untouched. This is why S17 has **no coverage-atomic mode commit** (contrast S15
  commit-3): no `VimMode` variant is added.
- **`command-loop.chiral` — NO CHANGE.** The `:run` fire entry (`runview-fire` `:701`)
  and S16's `:compose` fire (`compose-fire` `:737`) both call `runview-drive`
  *unchanged in signature* — the streaming lives **entirely inside**
  `fan-render`/`runview-drive`, which they already invoke. So both `:run` and
  `:compose` inherit streaming for free with **zero fire-entry change** (§6 D5).
  `runview-nav-dispatch` (`:679`) operates on a **finished** (`rv-done`) `RunView` —
  `rv-streaming` never lands in `vm-runview` state (it exists only mid-drive) — so nav
  is untouched.
- **`init-loader.chiral`/`dispatch.chiral` — NO CHANGE.** No new render-`Mode`, no new
  `ScribaOp`, no loop-arity change (same reasons S15 §2.6 cites). The streaming twins
  are pulled into the scriba blob transitively (already reached via
  `command-loop → manas-runview → runner`).

---

## §3 The pure render delta (`manas-runview.chiral`)

### 3.1 The `rv-streaming` marker + `phase-tag` arm (closed sum, forced)

One new `RunPhase` arm carries **who is streaming** — the `(=> Str Unit)` callback
cannot store the growing text (§5), so the marker holds only `idx`/`id`/`slot`/`model`,
enough for `runview-render` to draw the open row's prefix. Deliberately **unified**:
the same marker serves an expert *and* the combiner (the combiner streams with a
synthetic `idx = (len fired)` and its own `id`/`slot`/`model` — §4.2), so one arm
covers both (§6 D1):

```
(data RunPhase ()
  (rv-planning)
  (rv-planned)
  (rv-calling   (idx I64))
  (rv-streaming (idx I64) (id Str) (slot Str) (model Str))  ; S17: idx is LIVE, tokens flowing
  (rv-combining)
  (rv-done)
  (rv-failed    (reason Str)))
```

`phase-tag` (`:83`) gets its forced arm (the closed sum makes "forgot the streaming
state" a **type error** — the S17 analog of S15's coverage discipline):

```
      ((rv-streaming idx id slot model) (str-cat "(streaming " (str-cat (i64->str idx) ")")))
```

**No new field on the `run-view` record and no new `RvCall`.** The finished rows in
`done` are unchanged; the streaming row is a *transient* draw off the phase, replaced
by a settled `RvCall` the instant the call returns.

### 3.2 `streaming-row` + `runview-render`'s `rv-streaming` arm (pure)

`streaming-row` is one `manas-ok`-faced `r-text` whose prefix ends exactly where the
tokens flow; the on-delta `put`s deltas right after it. Reuses `r-face`/`r-text` —
**no new node**:

```
(def streaming-row (-> Str Str Str Rendering)
  (lam (id slot model)
    (r-face "manas-ok"
      (r-text (str-cat "  >>   " (str-cat id (str-cat "   (" (str-cat slot (str-cat " -> " (str-cat model ")  ")))))) false))))
```

`runview-render` (`:98`) appends it when `phase` is `rv-streaming`; every other phase
renders the **exact S15 frame** (`RUN` / `GATE` / `outcome-rows done` / `COMBINER` /
`YIELD`), so the change is one added `case` arm, nothing else moves:

```
(def runview-render (-> RunView (Pair I64 I64) I64 Rendering)
  (lam (rv dims scroll)
    (case rv
      ((run-view req phase routing fired done yield final)
        (r-lines
          (cons (mh-row (str-cat "RUN  " req))
          (cons (mf-row (str-cat "GATE  " (str-cat routing (str-cat "  ->  " (join-comma fired)))))
            (rrows-append (outcome-rows done)
              (case phase
                ((rv-streaming idx id slot model)               ; S17: the live row, appended
                  (cons (streaming-row id slot model)
                  (cons (mf-row (str-cat "COMBINER  " (phase-tag phase))) nil)))
                (_                                              ; every other phase = the S15 frame
                  (cons (mf-row (str-cat "COMBINER  " (phase-tag phase)))
                  (cons (mf-row (str-cat "YIELD  " yield)) nil))))))))))))
```

`runview-render` stays **pure `->`** — it draws the open-row *prefix* from the typed
phase; the *tokens* are `put` by the effectful on-delta (§5). The membrane keeps the
render from streaming and the stream from mutating the value.

### 3.3 `rv-streaming-of` — the pure builder (sibling of `rv-with-calls`)

Sets the streaming phase (idx = calls-so-far), keeps `done = acc` (the settled calls),
carries every other field — the S15 `set-stop`/`rv-with-calls` re-constructor pattern:

```
(def rv-streaming-of (-> RunView (List RvCall) Str Str Str RunView)
  (lam (rv acc id slot model)
    (case rv
      ((run-view req phase routing fired done yield final)
        (run-view req (rv-streaming (len-rvcall acc) id slot model) routing fired acc yield final)))))
```

---

## §4 The effectful delta (`manas-runview.chiral`)

### 4.1 `fan-render` — the live seam (`=>`, `(be-chat-stream)` N times)

S15's `fan-render` (`:162`) with the call swapped to `call-expert-stream … (lam (d)
(put d))` and the open row painted **before** the call. Structural recursion → total;
the on-delta is coordinator's callback verbatim (`coordinator.chiral:40-42`):

```
(def fan-render
  (lam (b exps bindings doc extra rv dims acc)
    (case exps
      (nil (reverse RvCall acc))
      ((cons e rest)
        (let ((slot  (exp-slot e)))
          (let ((model (bnd-model bindings slot)))
            (let ((id (expert-id e)))
              (let ((rv-live (rv-streaming-of rv acc id slot model)))
                (let ((_ (repaint-runview rv-live dims)))         ; 1. paint OPEN row; cursor parks at its end
                  (let ((oc (call-expert-stream b e doc extra model (lam (d) (put d)))))  ; 2. tokens flow INLINE
                    (let ((acc2 (append RvCall acc (cons (rv-call id slot model oc) nil))))
                      (let ((rv2 (rv-with-calls rv acc2 (len-rvcall acc2))))
                        (let ((_ (repaint-runview rv2 dims)))     ; 3. SETTLE: clear+redraw, S15 OK/BAD row
                          (fan-render b rest bindings doc extra rv2 dims acc2))))))))))))))
```

`expert-id` (imported `:31`), `exp-slot`, `bnd-model` (imported `:28`), `rv-with-calls`,
`len-rvcall`, `repaint-runview`, `rv-call`, `append`/`reverse` are all S15's, reused.
`put` comes from the new `(import "ports")` (§2.2). The three-step shape (open →
stream → settle) is exactly example §5.4/§6.

**Why the inline `put` is not corrupted by the settle repaint:** `repaint-runview`
calls `render-to-ansi-full`, which **clears the screen and redraws from `(1,1)`**
(`manas-runview.chiral:153-155` → `render.chiral` full-repaint), so the transient
streamed bytes are wiped and the settled `RvCall` row is drawn fresh — the stream is
**replaced, never merged** (§5).

### 4.2 `runview-drive` — combiner streaming (`=>`, one changed call)

S15's `runview-drive` (`:181`) with the combiner call swapped to
`call-combiner-stream … (lam (d) (put d))`, painting the combiner open row before it
via the **same** `rv-streaming` marker (synthetic idx = `(len-rvcall calls)`, the
combiner's own id/slot/model). Only the combiner arm changes; the `plan-run` gate,
the GATE pre-network paint, and the `fan-render` fan-out are S15's:

```
      ((plan-ok pid cid routing fired comb bindings)
        (let ((fids (ids-of-experts fired)))
          (let ((rv0 (rv-planned-of req routing fids)))
            (let ((_ (repaint-runview rv0 dims)))
              (let ((calls (fan-render b fired bindings doc extra rv0 dims nil)))
                (let ((cslot (exp-slot comb)))
                  (let ((cmodel (bnd-model bindings cslot)))
                    ; combiner open row (same rv-streaming marker; idx past the last expert)
                    (let ((rvc (rv-streaming-of (rv-with-calls rv0 calls (len-rvcall calls))
                                 calls (expert-id comb) cslot cmodel)))
                      (let ((_ (repaint-runview rvc dims)))
                        (let ((comb-oc (call-combiner-stream b comb (gather-findings (outcomes-of calls))
                                         fids cmodel (lam (d) (put d)))))
                          (let ((m (assemble-manifest req pid cid routing fired bindings
                                     (outcomes-of calls) comb-oc)))
                            (rv-done-of req routing fids calls (yield-of comb-oc) m))))))))))))))
```

- `assemble-manifest` still receives `(outcomes-of calls)` (the **bare**
  `ExpertOutcome`s) + `comb-oc` — **exactly** S15's arguments — so the manifest is
  byte-identical to the non-streamed path (§5). `RvCall` stays a render-only wrapper.
- The failure arms (`plan-no-route`/`plan-no-fire`/`plan-unbound` → `rv-fail`) are
  S15's, unchanged (a routing failure is a value, never a halt).
- If commit 3 (combiner streaming) is dropped for scope (§6 D4, §7), this arm reverts
  to S15's `call-combiner` line — commits 1 (expert twin only) and 2 stand alone.

---

## §5 The membrane + byte-identical story (why S17 is honest)

- **Transient paint, not stored text (no mutable ref).** The `(=> Str Unit)` on-delta
  returns **`Unit`** — it can only paint, it cannot thread a value — and scriba has
  **no mutable ref** (`command-loop.chiral:457`: "no mutable refs, no global variables").
  So the accumulating text is **not** stored in `RunView` (the marker carries only
  `idx`/`id`/`slot`/`model`); it is `put` inline (coordinator-style), and the
  **authoritative full text arrives in the returned `ChatR`** (`chat-ok acc`, where
  `acc` is `drain-stream`'s accumulation, `backend.chiral:113-120`), which
  `fan-render`/`runview-drive` map to a settled `RvCall`/manifest. The **only** moment
  the screen is ahead of the typed value is mid-stream; the next repaint
  (`render-to-ansi-full`, full clear + redraw) reconciles it from the settled value.
  A mid-stream failure comes back as `chat-bad` → `expert-bad` (settles **red**), so
  the conventional "half-full buffer, then throw" is **not representable** — there is
  no run-time in which the structure disagrees with what settled.
- **`runview-render` is pure `->`; only `fan-render`/`runview-drive` are `=>`.** The
  membrane proves the render cannot sneak a token and the stream cannot sneak past the
  structure. The on-delta's own effect row is just `put` (the terminal-write crossing
  scriba's repaint already uses).
- **INVARIANT — the manifest is byte-identical to a non-streamed run** (given the same
  final responses). Guaranteed **by construction**, not merely by test:
  (a) `call-expert-stream`/`call-combiner-stream` are `call-expert`/`call-combiner`
  with only `be-chat` → `be-chat-stream` + the on-delta;
  (b) `drain-stream` returns `chat-ok acc` where `acc = str-cat` of every delta = the
  full assistant text = **exactly** the `chat-ok t` text a non-stream `be-chat` returns
  (`backend.chiral:100-102` vs `:118-119`);
  (c) the `ChatR → ExpertOutcome`/`CombinerOutcome` `case` arms are **textually
  identical** between twin and original;
  therefore `parse-findings` runs on the same string, and `assemble-manifest` is fed
  the same `(outcomes-of calls)` + `comb-oc` — the manifest cannot differ. This is the
  §8 gate (unit + PTY smoke) and the reason E141's golden conformance still holds for a
  streamed run.

---

## §6 Dispositioned decisions

- **D1 — one unified `rv-streaming` marker (idx/id/slot/model) for experts AND the
  combiner.** **RESOLVED.** The example §5.2 shows `rv-streaming` for the expert row.
  Rather than mint a second combiner-live phase, the same marker serves the combiner
  (synthetic `idx = (len-rvcall calls)`, the combiner's own id/slot/model, §4.2). One
  constructor, one `phase-tag` arm, one `runview-render` arm cover both — minimal
  surface, one coverage obligation. CONFIRMED: the combiner is an `Expert`
  (`call-combiner`'s 2nd arg, `runner.chiral:87`), so `expert-id`/`exp-slot`/`bnd-model`
  apply to it exactly as to a fired expert.

- **D2 — the twins are additive; `call-expert`/`call-combiner` are unchanged.**
  **RESOLVED (per task constraint).** `call-expert-stream`/`call-combiner-stream`
  **duplicate** the (identical) `ChatR → outcome` mapping rather than factoring a
  shared `expert-of-chatr`/`combiner-of-chatr` tail, keeping `call-expert`/
  `call-combiner` byte-for-byte unchanged (a purely additive engine edit). The
  byte-identical invariant is therefore guaranteed by the *textual identity* of the
  two-line mapping + `drain-stream`'s `acc` semantics (§5), not by a single-sourced
  helper. (The shared-tail extraction — stronger single-sourcing (P5), and it would
  make the equal-outcome claim a *pure* unit test — is noted and **rejected** to honor
  the task's "call-expert unchanged / additive" constraint; it would edit
  `call-expert`'s body. Recorded here so it is not silently resolved.)

- **D3 — home: `runner.chiral` (the be-chat wrapper's home), not scriba.**
  **RESOLVED.** `call-expert-stream` lives beside `call-expert` in `runner.chiral`, not
  inlined in scriba's `fan-render`. `runner.chiral` is the ONLY manas-pipeline module
  that crosses the backend seam (`:4-6`) and the single source of the SEES prompt + JSON
  instruction + `parse-findings` + outcome mapping. A scriba-side `be-chat-stream` call
  would duplicate all of it and could drift from the non-stream path. The twin adds
  exactly one parameter and reuses everything. This is S17's one engine touch — additive
  (D2), gated by "B1 LOWERS it" exactly as E138's own gate was (`runner.chiral:13`).

- **D4 — combiner streaming is IN SCOPE (`call-combiner-stream`).** **RESOLVED
  (fold it in).** The example §7.2 decides: the combiner's yield is where the *final*
  text appears, so streaming it is high-value, and it is the **same one-line mechanism**
  (be-chat → be-chat-stream + on-delta) reusing the same `rv-streaming` marker (D1) —
  nothing new to mint. S17 includes both twins. **Separability:** if scoping tight,
  the combiner (commit 3) is the one deferrable half — commits 1 (expert twin) + 2
  (expert streaming, the N-way wait that hurts most) stand alone, and §4.2's combiner
  arm reverts to S15's `call-combiner` line. Kept in.

- **D5 — no new `VimMode`, no fire-entry change; streaming lives inside the driver.**
  **RESOLVED.** S17 reuses S15's `vm-runview` verbatim (the `rv-streaming` marker rides
  inside the `RunView` the mode already carries), and the `:run`/`:compose` fires
  (`runview-fire` `:701` / `compose-fire` `:737`) call `runview-drive` unchanged in
  signature — so both inherit streaming with **zero `command-loop.chiral`/`vim-mode.chiral`
  change** (§2.4). The task's "thread streaming into the fire entry" resolves to *no
  fire-entry edit*: the threading is entirely within `fan-render`/`runview-drive`.
  CONFIRMED against `runview-fire`/`compose-fire`/`runview-nav-dispatch` (the latter
  only ever sees a finished `rv-done` view).

- **D6 — no new render node; `r-stream` already exists.** **RESOLVED.**
  `r-stream (source-id Str)` is at `render.chiral:10` (carries a source-id, no text) —
  the APC side-channel placeholder, NOT the streaming path. The synchronous in-buffer
  path paints tokens with `put`, so S17 needs no new node and no `render.chiral` edit.
  The SCRIBA-SLICES row-17 phrase "a new `r-stream` render node" is the **pre-audit**
  description; the audited example corrects it (the node exists). Extending `r-stream`
  to *carry* the accumulating text (the purer total-render form) is an optional axis
  contained in `render.chiral` + `TUI/apc.chiral`, **not** required and **not** a new
  element (§9).

- **D7 — synchronous / blocking is in scope; async + concurrent are residue.**
  **RESOLVED (accepted, as S15/chat).** The stream is a **synchronous** linear
  `drain-stream` loop (`backend.chiral:113`) — the on-delta fires once per SSE frame as
  bytes arrive, and the editor blocks during the run exactly as S15 blocks per `be-chat`
  and chat mode blocks per `agent-run-transcript`. One open streaming row at a time
  (experts stream one-at-a-time down the sequential `fan-render`). Non-blocking/async
  and concurrent multi-expert streams need a select substrate scriba does not have —
  out, not faked (§9).

- **NEEDS-AUTHOR:** none. Every primitive is a verified public def: `be-chat-stream`
  (`backend.chiral:122`), `drain-stream` (`:113`), `be-chat`/`be-url`/`chat-open`/
  `chat-read`/`chat-close` (backend), `put` (`ports`, per `coordinator.chiral:20`),
  `assemble-prompt`/`render-findings`/`parse-findings`/`gather-findings` (runner),
  `expert-ok`/`expert-bad`/`combiner-ok`/`combiner-bad` (`types.chiral:115,121`),
  `expert-id` (`doc-refine`, imported `manas-runview.chiral:31`), `exp-slot`/`bnd-model`/
  `ids-of-experts`/`assemble-manifest`/`yield-of` (plan, `:157` for `yield-of`), and
  every S15 helper reused (`runview-render`/`fan-render`/`runview-drive`/`rv-with-calls`/
  `len-rvcall`/`repaint-runview`/`rv-call`/`outcomes-of`/`rv-planned-of`/`rv-done-of`/
  `rv-fail`). Every deviation (D1/D2/D5/D6) is mechanically buildable and resolved above.

---

## §7 Commit-sized change plan

Each commit is independently B1-compilable and testable. Order respects deps (the
engine twins before the scriba driver that calls them; the closed-sum `rv-streaming`
arm and its two forced `case` sites — `phase-tag` + `runview-render` — land together
for coverage). **No coverage-atomic *mode* commit** — S17 adds no `VimMode` (§6 D5).

1. **`runner: call-expert-stream + call-combiner-stream — streaming twins over be-chat-stream (additive; call-expert/call-combiner unchanged, manifest byte-identical)`**
   — the two additive `def`s in `scaffold/lib/manas/pipeline/runner.chiral` (§2.1).
   **Gate:** B1 LOWERS `runner.chiral` (the E138 gate for this file, `runner.chiral:13`);
   the byte-identical invariant holds by construction (§5) and is smoke-verified in
   commit 3. Touches no scriba, so `bin/scriba` is unchanged.

2. **`manas-runview: rv-streaming marker + phase-tag/runview-render arms + streaming-row + rv-streaming-of + fan-render on-delta (expert streaming) + unit test`**
   — `manas-runview.chiral`: the `rv-streaming` `RunPhase` arm + `phase-tag` arm +
   `streaming-row` + `runview-render`'s `rv-streaming` arm + `rv-streaming-of` +
   `fan-render`'s call swap (§3/§4.1) + `(import "ports")`; new
   `scriba-runview-stream-test.chiral` (§8.1). **One atomic commit** because the new
   `rv-streaming` constructor without *both* forced `case` sites (`phase-tag`,
   `runview-render`) fails coverage — the S17 analog of S15's coverage constraint. This
   pulls `call-expert-stream` into the scriba blob, so `bin/scriba` grows here.
   **Gate:** the test ELF exits 0 (§1 leg 1); `bin/scriba` builds (exit 0).

3. **`manas-runview: combiner streaming (runview-drive call-combiner-stream + rv-streaming marker) + PTY smoke`**
   — `runview-drive`'s combiner arm swap (§4.2). No new coverage obligation
   (`rv-streaming` already lands in commit 2; this only changes the effectful driver).
   **Gate:** `bin/scriba` builds (exit 0); PTY smoke (§8.2), including the
   byte-identical-manifest check. Separable per §6 D4.

---

## §8 Conformance / test gate

### 8.1 Unit test (`scriba-runview-stream-test.chiral`) — the contract

Idiom per `scriba-runview-test.chiral`: each test returns `I64` (0 = pass); `compile-main`
ANDs them. Build+run per §1 leg 1. All pure — **no PTY, no network, no fork**.

**T1 — the open streaming row (an `rv-streaming` view).** Build
`rv = (run-view "refine X" (rv-streaming 0 "claim-vs-source" "reasoner" "qwen2.5:0.5b") "6 rules matched" (cons "claim-vs-source" nil) nil "" none)`.
Assert `runview-render rv dims 0` contains the open-row prefix
`"  >>   claim-vs-source   (reasoner -> qwen2.5:0.5b)  "` (via `streaming-row`) and the
`COMBINER` row text `"COMBINER  (streaming 0)"` (via `phase-tag`). Proves the live row
is drawn faithfully from the **typed phase** with no network — the payoff that "expert
X is streaming on its slot's model" is a value.

**T2 — the settle path is unchanged (an `rv-done` view).** Re-run S15's settle
assertion: a `done` list of `(rv-call "claim-vs-source" "reasoner" "qwen2.5:0.5b"
(expert-ok nil "…"))` + `(rv-call "anchor-sharpen" "reasoner" "qwen2.5:0.5b"
(expert-bad "…" "http-500"))` renders the green `OK   claim-vs-source` and red
`BAD  http-500   anchor-sharpen` rows exactly as before (`outcome-row` untouched).
Proves S17 replaced *when text is observed*, not *what settles* — the transient stream
is reconciled to the same `RvCall` S15 renders.

**T3 — `phase-tag` totality over the extended sum.** Assert `phase-tag (rv-streaming 3
"curate-merge" "combiner" "qwen3:8b")` = `"(streaming 3)"` (the combiner-live case,
D1) and the S15 tags (`(planned)`/`(calling N)`/`(done)`) are unchanged. Proves the
closed sum's readback stays faithful with the new arm.

**Byte-identical-manifest note (why it is not a pure unit test here):** the invariant
"`call-expert-stream` yields the same `ExpertOutcome` as `call-expert` given the same
final text" is guaranteed **by construction** (§5) — but exercising `call-expert-stream`
requires a `Backend` (it calls `be-chat-stream`, a live socket), and **there is no
fake-backend seam** in the tree to inject a canned `ChatR` purely. So the invariant is
specced as (a) a **spec invariant** (§5, by textual identity + `drain-stream` acc
semantics) and (b) a **PTY-smoke assertion** (§8.2 — the settled manifest is the normal
S15 manifest). A pure equal-outcome test would need a mock backend (out of scope,
residue §9); it is **not faked**.

### 8.2 Build + PTY smoke — the wiring + liveness + byte-identical gate

`bin/scriba` builds (B1 compile, exit 0). PTY, mesh reachable, in order:
1. `:run` → the `RUN`/`GATE` lines render pre-network (S15, unchanged).
2. **open row** — for the first fired expert an `>>` open row appears (id +
   `slot -> model`, cursor parked at its end) **before any token**.
3. **tokens flow** — deltas paint inline on that row as the model generates (no screen
   clear per token — `(lam (d) (put d))`, coordinator-style).
4. **settle** — the row collapses to the green `OK` (or red `BAD` on a mid-stream
   break) row S15 renders (full clear + redraw), and the next expert's open row begins.
5. **combiner** — the combiner's yield streams the same way, then closes the run.
6. ESC → `-- Normal --`.
7. **byte-identical check** — the settled manifest matches a non-streamed run's manifest
   in structure: same fired set, same per-expert `OK`/`BAD` outcomes, same combiner
   yield shape (streaming changed only *when* text is observed, not *what* settled).
8. (liveness/failure) an unreachable mesh or a mid-stream break settles a red
   `BAD`/`(failed: …)` line, never a crash.

### 8.3 Self-host note

S17 touches scriba (`TUI/scriba/*`) + one additive engine-library edit
(`scaffold/lib/manas/pipeline/runner.chiral` — two new `def`s, no compiler source) —
**no compiler source changes**, so the B1-reproduces-itself self-host check
(CLAUDE.md BUILD RULE) is **not** triggered. Build-new → test → done.

---

## §9 Honest residue (scope must NOT expand it)

- **No non-blocking / async streaming.** The stream is a synchronous linear
  `drain-stream` loop — the editor blocks during the run (as S15 per `be-chat`, chat
  mode per `agent-run-transcript`). Tokens flow *within* a call; you cannot type over a
  running stream. True non-blocking needs an async/select substrate scriba does not
  have — not in S17, not faked (§6 D7). Not deferred to any named element (no phantom).
- **No concurrent multi-expert streaming.** Experts stream one at a time down the
  sequential `fan-render` — one open row at a time. Six live rows at once is the async
  substrate above.
- **No stored growing text / no total-render of the live text.** Storing the
  accumulating text *in* `RunView` (so `runview-render` totally renders the live text,
  not just its prefix) needs a mutable cell the `(=> Str Unit)` callback appends to —
  exactly the ref scriba refuses (`command-loop.chiral:457`, §5). S17 takes the
  transient-`put` path, reconciling at `ChatR` return. A ref-backed or
  `r-stream`-carries-text variant is a design axis contained in `render.chiral` +
  `TUI/apc.chiral` — **not a new element** (§6 D6). Recorded so it is not silently
  resolved.
- **No pure equal-outcome test of the twins** (no fake-backend seam — §8.1). The
  byte-identical invariant is by-construction + PTY-smoke-verified. A mock backend is
  the enabling refinement, out of S17.
- **Long-line wrap.** on-delta `put`s inline (O(delta) per token, no full clear), so
  cost is fine; but a streaming line longer than the terminal width **clips at the
  right edge** under `ansi-nowrap` (the known cursor/wrap limitation — a cell-grid
  renderer is the real fix). Acceptable residue; a line-local `render-to-ansi-delta`
  repaint of just the streaming row is a natural optimization, left to implementation.
- **No retrieval.** `call-expert-stream` keeps `assemble-prompt`'s context `nil` (as
  S15) — retrieval is orthogonal engine work.

### Relational anchors

Gate S15 (`manas-runview.chiral` — the frame S17 grows) + `be-chat-stream`
(`backend.chiral:122` — the primitive threaded). Seed `coordinator.chiral:37-42`
(`(lam (d) (put d))`) + `samples/stream-ollama.chiral` (the mesh-verified `chat-read →
put` loop) — **NOT** `chat.chiral` (it blocks on `agent-run-transcript`, does not
stream). Pattern S15's pure/effectful split + closed-sum `RunPhase` (S17 adds
`rv-streaming`). Baseline improved on: S15's per-expert *incremental* render — S17
turns each "blank, then whole row" into "tokens flowing, then settled row". Home of:
MANAS-STATE-VS-GOAL §8 deferred "streaming trim" — this slice closes it. **Minting:
nothing new** (S17 already minted, SCRIBA-SLICES row 17; `be-chat-stream` and
`r-stream` already exist; the twins + `rv-streaming` + `streaming-row` + `rv-streaming-of`
are S17's own delta).

---

*Spec written: `.planning/specs/S17-manas-token-streaming-SPEC.md`. Implementation
runs follow this SPEC; the example stays the rationale.*
