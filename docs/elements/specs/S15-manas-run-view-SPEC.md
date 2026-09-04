# S15 — manas run-view (the run-manifest cockpit, Tier 2) — IMPLEMENTATION SPEC

> ⚑ **TRIAGE 2026-09-04 — DONE-ALREADY.** 0 of 0 steps are executable at HEAD.
> `prog/scriba/manas-runview.chiral` + `scriba-runview-test.prog` exist.
> Bucket and evidence: `records/spec-tier-triage.md`. This file was not
> rewritten and its `status:` was not changed.

Stage 3 of 5 (example → audit → spec → audit → implement). Source of truth for
the implementer. Reads with `docs/examples/S15-manas-run-view.md`
(the worked example, audited PASS — its reused-primitive design is verified: the
four engine prims are real public defs, `plan-run` is pure so the GATE renders
pre-network, and it reuses S14's render helpers + one `VimMode` variant with zero
engine change). The example stays the rationale; this SPEC is the contract.

**Gate:** E138 (`scaffold/lib/manas/pipeline/{plan,runner}.chiral` — the run loop
S15 fires) + E141 (`scaffold/lib/manas/core/types.chiral` `RunManifest` — the value
it renders). Both landed. E139 (`be-log`) is **optional** for S15 (per SCRIBA-SLICES
row 15). Seed: S14 (`TUI/scriba/manas-mode.chiral` — `mf-row`/`mh-row`/`join-comma`/
`rrows-append` + the `manas-*` faces, reused) + slice 12 (the manas colorer / face
precedent). Pattern: S13 (`vim-mode.chiral` — a `VimMode` variant carrying state;
`vm-runview` mirrors `vm-manas`) + I1 (`chat.chiral` + `command-loop.chiral`
`vim-chat-prompt` — the effect-then-repaint-then-recurse loop; `runview-drive` is
shaped like it).

**Scope:** fire ONE run and render it incrementally — GATE plan pre-network, one
repaint per `call-expert` return, then combiner + yield. **Per-expert incremental,
NOT token-streaming** (the engine is non-streaming `be-chat`); true token-by-token
streaming is **S17** (§6 D6, §9). **Synchronous/blocking is accepted** — the driver
blocks per `be-chat` exactly as chat mode blocks per `chat-ask` today. Choosing
*which* pipeline/profile to fire is **S16**. S15 ends at **a finished run rendered
as a navigable buffer over its `RunManifest`.**

---

## §1 Deliverable + acceptance test

**Deliverable (one sentence):** scriba gains a `vm-runview` run-view mode whose
buffer is a total render of an in-flight/finished `RunView` value — `:run` fires
the doc-refine pipeline against the mesh, `runview-render` paints the PURE `plan-run`
GATE decision *before any network call*, `runview-drive` repaints one `manas-ok`/
`manas-bad` row per `call-expert` return, then the combiner + final yield close the
run and control lands in `vm-runview` over the finished manifest — all reusing the
four public engine prims (`plan-run`/`call-expert`/`call-combiner`/`assemble-manifest`)
with **zero engine change**.

**Acceptance test (two legs):**

1. **Unit (pure, no PTY, no network — the acceptance-critical leg):** a new B1 test
   root `scriba/scriba-runview-test` drives `runview-render` over three hand-built
   `RunView` values (a `rv-planned`, a mid-fan `rv-calling` with one `expert-ok` +
   one `expert-bad` `RvCall`, and a `rv-done`) and byte-checks the rendered rows
   (GATE line carries the routing reason + fired set; the OK row carries
   `SLOT -> model`; the BAD row carries the reason). Exit 0 = all assertions hold:
   `chirality_blob scaffold/lib scriba/scriba-runview-test | scaffold/build/B1 > /tmp/rt.elf && chmod +x /tmp/rt.elf && /tmp/rt.elf; echo $?` → `0`.

2. **Build + PTY smoke (the wiring gate):** `bin/scriba` builds (B1 compile, exit 0).
   In a PTY, with the mesh reachable (`100.64.0.5:11434`): `:run` fires the run.
   The `GATE` line renders **immediately** (`-- Run --` status; the fired set +
   routing reason on screen while the first model call is still in flight); then one
   row repaints per expert as its `be-chat` returns (green `OK`, red `BAD`); then a
   `COMBINER` row and a `YIELD` block close it; ESC returns to Normal.

The unit leg is the contract (it proves the render is faithful with no network). The
PTY leg is the wiring/liveness smoke; a routing failure or an unreachable mesh must
render as a red line, never crash (`rv-failed` / `expert-bad`).

---

## §2 Baseline delta — files created / modified

Grounded in the live tree. Line anchors are as-read at spec time.

### 2.1 `TUI/scriba/manas-runview.chiral` — **NEW** (the pure render core + the effectful driver)

**Filename is deliberate (the collision):** the slice row names `manas-run.chiral`,
which **collides** with the existing headless driver `scaffold/samples/manas-run.chiral`
(fires the same engine, dumps JSON). Two files of the same basename with opposite
jobs is a blob/reader footgun. Name the scriba module **`manas-runview.chiral`** — it
says "the run *view*", sits with the other scriba residents, cannot be confused with
the sample. (Example §5.1; RESOLVED §6 D1.)

Imports (the pure-core set in commit 1; the driver adds two in commit 2):

```
(import "prelude")                     ; Str, Bool, I64, List, Pair, Maybe, str-cat, str-eq, i64->str, cons, nil
(import "render")                      ; Rendering, r-face, r-lines, r-text
(import "manas-mode")                  ; mf-row, mh-row, join-comma, rrows-append  (S14 helpers, reused)
(import "manas/core/types")            ; ExpertOutcome, Expert, Binding, RunManifest, CombinerOutcome
; --- added in commit 2 (the effectful driver) ---
(import "backend")                     ; backend (the Backend ctor), Backend
(import "manas/pipeline/plan")         ; plan-run, PlanOutcome, assemble-manifest, ids-of-experts, bnd-model, exp-slot
(import "manas/pipeline/runner")       ; call-expert, call-combiner, gather-findings
(import "manas/profile/profiles")      ; smoke-local-config  (the crafted config the sample fires)
(import "manas/profile/doc-refine")    ; doc-refine-pipeline, expert-pool  (the crafted pipeline + pool)
```

Import reachability is the S14-proven path: the scriba resolver's libdir is hardcoded
`scaffold/lib`; scriba is on it via `scaffold/lib/scriba -> ../../TUI/scriba`; the
manas library sits under the same libdir at `scaffold/lib/manas/*`; `manas-mode` is
already a scriba resident. No new search-path work. (Verified against S14 §2.1, which
imports the same manas modules from the same home.)

Contents (defined in §3/§4): the `RunView` / `RunPhase` / `RvCall` sums; the pure
`runview-render` + `outcome-row` + `phase-tag` + the `rv-*` constructor helpers; the
effectful `runview-drive` + `fan-render` + the crafted-input constants.

### 2.2 `TUI/scriba/render.chiral` — **MODIFIED** (two new faces)

`runview-render` emits `r-face "manas-ok"` (a good expert row) and `r-face "manas-bad"`
(a failed expert / routing-failure row). Those two faces are **not** in `default-faces`
(only `manas-tag`/`manas-field`/`manas-header` are, `render.chiral:114-116`). Add them,
mirroring the slice-12 precedent, keeping fg to the 0-7 SGR indices already in use
(green = 2 as `comment`, red = 1 as `keyword`/`error`):

```
(cons (pair "manas-ok"   (face "manas-ok"   2 -1 1))
(cons (pair "manas-bad"  (face "manas-bad"  1 -1 2))
```

inserted into `default-faces` (`render.chiral:108-117`) after the `manas-header` row.
(Emitting an unknown face name is not a compile error — `lookup-face` falls back to a
default — so the renderer *compiles* without this edit; the edit is what makes the OK
row green and the BAD row red. Kept in commit 1 to keep the renderer self-consistent.)

### 2.3 `TUI/scriba/vim-mode.chiral` — **MODIFIED** (the run-view mode state)

`VimMode` gains one variant that **carries the in-flight/finished run** (exactly as
`vm-manas` carries a `ManasDoc`, `vim-mode.chiral:28`):

```
(data VimMode ()
  (vm-normal) (vm-insert) (vm-visual (linewise Bool)) (vm-command) (vm-chat)
  (vm-manas (doc ManasDoc))
  (vm-runview (rv RunView)))          ; S15 — the RunView rides in the mode
```

`mode-name` (`vim-mode.chiral:43-51`) gains the arm `((vm-runview rv) "Run")`.

This requires `vim-mode.chiral` to `(import "manas-runview")` for the `RunView` type
(it already imports `manas-mode` for `ManasDoc`, `vim-mode.chiral:13`). `manas-runview`
does **not** import `vim-mode` (it needs none of it), so the dependency stays acyclic
(`vim-mode → {manas-mode, manas-runview}`, `manas-runview → {render, manas-mode,
manas library}` — none reach back to `vim-mode`). Carrying `RunView` inside the
variant keeps `command-loop-inner`'s arity unchanged (§2.4), confining churn to the
exhaustive `case`s over `VimMode` (§7 coverage note).

### 2.4 `TUI/scriba/command-loop.chiral` — **MODIFIED** (nav dispatch + resize arm + fire entry)

Four additive touch-points, all mirroring the S14 `vm-manas` wiring:

- **`case mode` dispatch arm** (`command-loop-inner`, `command-loop.chiral:953-959`,
  beside `((vm-manas d) …)` at `:959`): add
  `((vm-runview rv) (runview-nav-dispatch km puf chat dims scroll old-rendering renderers ops rv ks))`.
- **resize arm** (`command-loop-inner` false branch, `command-loop.chiral:960-970`,
  beside the `((vm-manas d) …)` re-render at `:962-965`): add a `((vm-runview rv) …)`
  arm re-rendering via `runview-render rv dims (puffer-scroll puf dims)` →
  `render-to-ansi-full` → recurse in `mode`. (Only fires on terminal resize; without
  it a resize repaints the parked Str buffer over the finished run.)
- **`runview-nav-dispatch`** (NEW effectful helper, sibling of `manas-author-dispatch`
  `:628`): in `vm-runview` keys are **navigation only** — the run is already finished.
  ESC → `command-loop-inner … vm-normal pending-none`; any other key →
  `beep-recurse … (vm-runview rv) pending-none`. (Scroll-the-manifest is residue, §9.)
- **entry**: `vim-command-run` (`command-loop.chiral:1810`, the `str-eq cmd "…"` chain
  that already dispatches `manas ` → `manas-enter`) gains a `:run` arm → `runview-fire`
  (§4.3). `runview-fire` fires the run and enters `vm-runview` over the finished value.

`runview-nav-dispatch` and `runview-fire` are new top-level `def`s in
`command-loop.chiral` (the effectful shell — like `manas-enter`/`manas-author-dispatch`),
ordered before `vim-command-run`/`command-loop-inner` so both can reference them.

### 2.5 `TUI/scriba/scriba-runview-test.chiral` — **NEW** (the unit gate)

A B1 test root mirroring `scriba-test-b1.chiral`'s idiom (functions returning an I64
exit code; `compile-main` ANDs them; exit 0 = pass). Imports `manas-runview` +
`manas/core/types` and asserts `runview-render` over three hand-built `RunView` values
(§8.1). **No network, no fork, no PTY** — the whole point of the pure render core.

### 2.6 No other file changes

- **init-loader.chiral:** `vm-runview` is not a registered render-`Mode` (its renderer
  takes a `RunView`, not the `Str` a `RendererFn` takes) and firing is not a
  `ScribaOp` (`(=> (Puffer Str) (Puffer Str))`) — the same type-mismatch reason S14's
  author mode and I1's chat-send are special-cased in the loop rather than registered.
  The manas engine is pulled into the blob transitively (`command-loop → vim-mode →
  manas-runview → runner`). **No edit.**
- **dispatch.chiral:** because `RunView` rides *inside* `VimMode` (§2.3),
  `command-loop-inner`'s arity is unchanged, so its forward-declare
  (`dispatch.chiral`, the exact signature S14 relied on) needs **no edit**.

---

## §3 The pure render core (`manas-runview.chiral`)

### 3.1 The three sums

The in-flight run is a small record that grows monotonically. `RunPhase` is a closed
sum so the compiler forces `phase-tag` + the renderer to handle every stage:

```
(data RunPhase ()
  (rv-planning)                 ; before plan-run returns
  (rv-planned)                  ; GATE decided, no calls yet
  (rv-calling  (idx I64))       ; mid fan-out — expert idx of (len fired) in flight
  (rv-combining)                ; fan-out done, combiner in flight
  (rv-done)                     ; finished — `final` is (some manifest)
  (rv-failed   (reason Str)))   ; plan-no-route / plan-no-fire / plan-unbound — a VALUE

(data RunView ()
  (run-view
    (req      Str)              ; the request being run
    (phase    RunPhase)         ; where the run is
    (routing  Str)              ; the GATE reason ("" until planned)
    (fired    (List Str))       ; fired expert ids — the plan ("" until planned)
    (done     (List RvCall))    ; per-expert results SO FAR (grows one per be-chat)
    (yield    Str)              ; combiner yield ("" until combined)
    (final    (Maybe RunManifest)))) ; none until finished; the run record
```

**`RvCall` — the id/slot/model-bearing per-expert row (RESOLVED deviation, §6 D2).**
The example declares `done : (List ExpertOutcome)`, but `ExpertOutcome`
(`types.chiral:115`: `expert-ok (findings)(raw)` / `expert-bad (raw)(reason)`) carries
**no** expert id, slot, or bound model — yet the example's §6 walkthroughs render
`OK  claim-vs-source  (reasoner -> qwen2.5:0.5b)`. To render that faithfully, `done`
bundles the fired `Expert`'s id+slot and its bound model **at cons-time in
`fan-render`** (which has the `Expert` + `bindings` + `ExpertOutcome` all in hand —
see §4.2), never at engine level:

```
(data RvCall ()
  (rv-call (id Str) (slot Str) (model Str) (outcome ExpertOutcome)))
```

This is a scriba-side render bundle only — **zero engine change** (the engine's
`fan-experts` still returns bare `(List ExpertOutcome)`; `fan-render` is scriba's own
repaint variant). The example's §5.2 `outcome-row` (bare `ExpertOutcome`, an invented
`raw-head` helper) is **superseded** by this cleaner form.

### 3.2 `outcome-row` — one `RvCall` → one face-tagged row (pure)

Cases on the bundled `ExpertOutcome`; a bad outcome is a `manas-bad` row (forced by
the `case` — a silently-dropped failure is not representable):

```
(def outcome-row (-> RvCall Rendering)
  (lam (rc)
    (case rc
      ((rv-call id slot model oc)
        (case oc
          ((expert-ok  fs raw)
            (r-face "manas-ok"  (r-text (str-cat "  OK   " (str-cat id (str-cat "   (" (str-cat slot (str-cat " -> " (str-cat model ")")))))) false)))
          ((expert-bad raw reason)
            (r-face "manas-bad" (r-text (str-cat "  BAD  " (str-cat reason (str-cat "   " id))) false))))))))

(def outcome-rows (-> (List RvCall) (List Rendering))
  (lam (rcs)
    (case rcs
      (nil nil)
      ((cons r rest) (cons (outcome-row r) (outcome-rows rest))))))
```

### 3.3 `phase-tag` — the closed-sum status string (pure, total)

```
(def phase-tag (-> RunPhase Str)
  (lam (p)
    (case p
      (rv-planning        "(planning)")
      (rv-planned         "(planned)")
      ((rv-calling idx)   (str-cat "(calling " (str-cat (i64->str idx) ")")))
      (rv-combining       "(combining)")
      (rv-done            "(done)")
      ((rv-failed reason) (str-cat "(failed: " (str-cat reason ")"))))))
```

### 3.4 `runview-render` — the total value renderer (pure `-> Rendering`)

Walks the whole `RunView` into `r-lines` of face-tagged rows, reusing S14's
`mh-row` (`manas-mode.chiral:473`), `mf-row` (`:472`), `join-comma` (`:448`) and
`rrows-append` (`:495`) —
this is the "reuse I2 transcript rendering" the slice asks for (the same
`r-lines`-of-`r-face`-rows tree S14's value view emits). `dims`/`scroll` are carried
for parity with the S14 renderer shape; S15 renders the whole value (no windowing —
scroll residue, §9):

```
(def runview-render (-> RunView (Pair I64 I64) I64 Rendering)
  (lam (rv dims scroll)
    (case rv
      ((run-view req phase routing fired done yield final)
        (r-lines
          (cons (mh-row (str-cat "RUN  " req))
          (cons (mf-row (str-cat "GATE  " (str-cat routing (str-cat "  ->  " (join-comma fired)))))
            (rrows-append (outcome-rows done)
              (cons (mf-row (str-cat "COMBINER  " (phase-tag phase)))
              (cons (mf-row (str-cat "YIELD  " yield)) nil))))))))))
```

### 3.5 `rv-*` constructor helpers (pure)

Small total builders the driver uses to grow the `RunView` between stages:

```
(def rv-fail       (-> Str Str RunView) …)                 ; (run-view req (rv-failed reason) "" nil nil "" none)
(def rv-planned-of (-> Str Str (List Str) RunView) …)      ; phase rv-planned, routing+fired set, done nil
(def rv-with-calls (-> RunView (List RvCall) I64 RunView) …) ; replace done + set phase (rv-calling idx)
(def rv-done-of    (-> Str Str (List Str) (List RvCall) Str RunManifest RunView) …) ; phase rv-done, final (some m)
```

Each is one `case (run-view …)` re-constructor (the S14 `set-stop` pattern); all
seven fields carried, only phase/done/yield/final rewritten. `fired` here is the
`(List Str)` of ids — the driver passes `(ids-of-experts fired-experts)`
(`plan.chiral:80`) since `plan-ok`'s `fired` is `(List Expert)`.

---

## §4 The effectful driver + dispatch threading

### 4.1 `runview-drive` — fire one run, repaint per stage (`=>`, row exactly `(be-chat)`)

Mirrors `run-pipeline`'s body (`runner.chiral:121-135`) but reuses the four **public**
prims directly with a **repaint seam between the calls** — it deliberately does NOT
call `run-pipeline`/`guarded-run` as a black box, because the black box returns only
at the end and per-expert repaint needs the seam (example §7.1; RESOLVED §6 D3). The
plan branch renders the GATE **before any network** (`plan-run` is PURE, `plan.chiral:97`):

```
(def runview-drive
  (=> Backend Str (List Pipeline) (List Expert) Config Str (List (Pair Str Str)) (Pair I64 I64) RunView)
  (lam (b req pipes pool config doc extra dims)
    (case (plan-run req pipes pool config doc extra)          ; PURE — no network yet
      ((plan-no-route listing)     (rv-fail req "no-route"))   ; a VALUE, never a halt
      ((plan-no-fire  reason)      (rv-fail req reason))
      ((plan-unbound  missing cid) (rv-fail req "unbound"))
      ((plan-ok pid cid routing fired comb bindings)
        (let ((fids (ids-of-experts fired)))
          (let ((rv0 (rv-planned-of req routing fids)))
            (let ((_ (repaint-runview rv0 dims)))             ; PAINT before any be-chat
              (let ((calls (fan-render b fired bindings doc extra rv0 dims nil)))
                (let ((comb-oc (call-combiner b comb (gather-findings (outcomes-of calls))
                                 fids (bnd-model bindings (exp-slot comb)))))
                  (let ((m (assemble-manifest req pid cid routing fired bindings
                             (outcomes-of calls) comb-oc)))
                    (rv-done-of req routing fids calls (yield-of comb-oc) m)))))))))))
```

- `repaint-runview rv dims` = `render-to-ansi-full (runview-render rv dims 0) dims`
  (the proven mid-effect paint `vim-chat-prompt` uses after a network call,
  `command-loop.chiral:806`); scroll 0 = top during the live run.
- `outcomes-of : (-> (List RvCall) (List ExpertOutcome))` — unwrap the bundles to feed
  `gather-findings` (`runner.chiral:174`) and `assemble-manifest` (`plan.chiral:164`),
  which are typed on `(List ExpertOutcome)`. Assembling from the *raw* outcomes keeps
  the manifest byte-identical to the headless path (`RvCall` is a render-only wrapper).
- `yield-of : (-> CombinerOutcome Str)` — the combiner text (`""` on `combiner-bad`);
  same shape as `runner.chiral`'s `yield-of` / `plan.chiral` accessors (re-declared
  locally to avoid a cross-module private-def dependency; total `case`).

### 4.2 `fan-render` — the incremental heart (`=>`, `(be-chat)` N times)

`run-pipeline`'s `fan-experts` (`runner.chiral:99-105`) with a **repaint seam** and the
`RvCall` bundling. Structural recursion on the fired list → total; carries an idx for
the `rv-calling` phase:

```
(declare fan-render
  (=> Backend (List Expert) (List Binding) Str (List (Pair Str Str)) RunView (Pair I64 I64) (List RvCall) (List RvCall)))
(def fan-render
  (lam (b exps bindings doc extra rv dims acc)
    (case exps
      (nil (reverse RvCall acc))
      ((cons e rest)
        (let ((slot  (exp-slot e))
              (model (bnd-model bindings (exp-slot e))))
          (let ((oc (call-expert b e doc extra model)))        ; be-chat — blocks (synchronous, §6 D5)
            (let ((acc2 (append RvCall acc (cons (rv-call (exp-id-of e) slot model oc) nil))))
              (let ((rv2 (rv-with-calls rv acc2 (len-rvcall acc2))))
                (let ((_ (repaint-runview rv2 dims)))           ; REPAINT — the live update
                  (fan-render b rest bindings doc extra rv2 dims acc2))))))))))
```

`call-expert` (`runner.chiral:97`), `bnd-model` (`plan.chiral:58`), `exp-slot`
(`plan.chiral:47`) are public. `exp-id-of` reads the `Expert` id — `plan.chiral`'s
`exp-id` (`:46`) is private to that module, so `fan-render` uses a local one-line
`case`-accessor (or `ids-of-experts` over a singleton). `reverse`/`append`/`len` come
from `collections`; add `(import "collections")` in commit 2 if not already pulled.

### 4.3 `runview-fire` — the `:run` entry (effectful, special-cased like `chat-send`)

Firing is effectful and returns into a mode, so it is special-cased by command name
in `vim-command-run` exactly as `manas ` → `manas-enter` is (`command-loop.chiral:1257`).
Fires the crafted doc-refine run (the sample's inputs, §4.4), then hands control to
`vm-runview` over the finished value:

```
(def runview-fire
  (=> Keymap (Puffer Str) (Maybe (Puffer Str)) (Pair I64 I64) I64 Rendering (List (Pair Str Mode)) (List ScribaOp) Unit)
  (lam (km puf chat dims scroll old-rendering renderers ops)
    (let ((b (backend rv-endpoint)))                           ; the Backend ctor (backend.chiral:24)
      (let ((rv (runview-drive b rv-req (cons doc-refine-pipeline nil) expert-pool
                   smoke-local-config rv-doc rv-extra dims)))  ; blocks through the run
        (let ((rendering (runview-render rv dims scroll)))
          (let ((_ (render-to-ansi-full rendering dims)))
            (command-loop-inner km puf chat dims scroll ""
              rendering renderers ops (vm-runview rv) pending-none)))))))
```

Wired into the `vim-command-run` chain (`command-loop.chiral:1810`) as
`(case (str-eq cmd "run") (true (runview-fire km puf chat dims scroll old-rendering renderers ops)) (false …))`,
before the existing `manas `/`beep-recurse` fallthrough.

### 4.4 Crafted-input constants (in `manas-runview.chiral`, the sample's inputs)

The sample `scaffold/samples/manas-run.chiral:33-48` crafts a doc + extra so all six
doc-refine experts fire (7 `be-chat` crossings). S15 re-declares them (a scriba module
can't import a sample; no blob collision since the sample isn't in the scriba graph),
prefixed `rv-` to avoid any future clash:

```
(def rv-endpoint Str "http://100.64.0.5:11434")     ; the mesh (sample :47; chat.chiral:19 uses the same host)
(def rv-req Str "refine this doc: check it against reality, sharpen anchors, complete its examples")
(def rv-doc Str "…")                                 ; the sample's the-doc (fires code/paths + examples)
(def rv-extra (List (Pair Str Str)) …)               ; the sample's the-extra ("spec" + "sibling_docs" keys)
```

`smoke-local-config` (`profiles.chiral:21`), `doc-refine-pipeline` + `expert-pool`
(`doc-refine.chiral`) are the same public values the sample fires (`samples/manas-run.chiral:50`).

### 4.5 Status bar

`emit-status` threads `VimMode` through `mode-name`, so `(vm-runview rv)` renders
`-- Run --` automatically via the §2.3 arm. As in S14, `emit-cursor-goto` points at
the parked Str buffer's cursor (harmless cosmetic artifact — cursor suppression is out
of S15, §9).

---

## §5 The synchronous / effect-membrane story (why S15 is honest)

- **The run pulls the effectful engine into the scriba blob.** From commit 3 on,
  `vim-mode → manas-runview → runner → backend → http → sockets` (the `be-chat`
  network crossing) is in the scriba graph, so the scriba ELF grows and the `bin/scriba`
  compile gets heavier. **This is expected** — it is the price of a cockpit that fires,
  not just colors. (Commits 1-2 create `manas-runview.chiral` as an orphan not yet in
  the scriba graph, so `bin/scriba` is unchanged until commit 3.)
- **Synchronous/blocking is accepted.** `runview-drive` blocks the editor during each
  `be-chat` exactly as `vim-chat-prompt` blocks during `chat-ask` today
  (`command-loop.chiral:792-807`, `chat.chiral:52`). "Live-updating" = incremental
  repaint **between** synchronous calls, not a background stream you keep typing over.
  True non-blocking needs an async/select substrate scriba does not have (§9) — it is
  not in S15 and not faked.
- **The membrane proves the row.** `plan-run` is pure `->` (`plan.chiral:97`) — the
  GATE renders with zero network. Only `runview-drive`/`fan-render` are `=>`, and their
  effect row is exactly `(be-chat)` (the same row as `run-pipeline`, since they call
  the same prims). `runview-render`/`outcome-row`/`phase-tag` are pure `->`
  (unit-testable, §8.1).

---

## §6 Dispositioned decisions

- **D1 — filename (the collision).** **RESOLVED.** New module is
  `TUI/scriba/manas-runview.chiral`, **not** `manas-run.chiral` — the slice-row name
  collides with the headless `scaffold/samples/manas-run.chiral` (`:1`), which fires the
  same engine and dumps JSON. Cited: two same-basename files with opposite jobs is a
  blob/reader footgun (example §5.1). The sample stays the headless baseline S15
  improves on.

- **D2 — `done` carries id/slot/model: `(List RvCall)`, not `(List ExpertOutcome)`.**
  **RESOLVED.** The example declares `done : (List ExpertOutcome)`, but
  `ExpertOutcome` (`types.chiral:115`) carries neither the expert id, the slot, nor the
  bound model — while the example's §6 walkthrough renders
  `OK  claim-vs-source  (reasoner -> qwen2.5:0.5b)`. `fan-render` has the `Expert` +
  `bindings` + outcome all in hand at cons-time, so it bundles them into a scriba-side
  `RvCall` (§3.1). **Zero engine change** (`fan-experts` still returns bare outcomes;
  `assemble-manifest` still gets `(outcomes-of calls)` so the manifest is byte-identical
  to the headless path). The example's §5.2 `outcome-row` (bare outcome + an invented
  `raw-head`) is superseded. This is the S15 analog of S14's D1/D2 — the example's
  illustrative form yields to the buildable one, deliverable unchanged.

- **D3 — reuse the four prims vs call `run-pipeline`/`guarded-run` as a black box.**
  **RESOLVED.** `runview-drive` reuses `plan-run`/`call-expert`/`call-combiner`/
  `assemble-manifest` directly (all public: `plan.chiral:97,164`, `runner.chiral:97,136`),
  **not** `run-pipeline` (`runner.chiral:187`) or `guarded-run` (`guarded.chiral`),
  because those return only at the end and per-expert repaint needs a seam *between* the
  calls (example §7.1). The breaker count `guarded-run` adds is orthogonal (a post-run
  fold, recomputable from the final manifest if the cockpit ever wants it). **Zero
  engine change** — those four are already public top-level defs (CONFIRMED against
  `plan.chiral`/`runner.chiral` at spec time).

- **D4 — mode home: `VimMode` variant vs a new loop param.** **RESOLVED.** Carry the
  run inside `(vm-runview (rv RunView))` (§2.3), not as a new `command-loop-inner`
  parameter — the exact S14 D2 reasoning: `command-loop-inner` is threaded through
  many recursive call sites and forward-declared in `dispatch.chiral`; a new parameter
  forces every one, while `vm-manas`/`vm-visual` already carry payload. Confines churn
  to the `case`s over `VimMode` (§7).

- **D5 — synchronous/blocking is in scope.** **RESOLVED (accepted, per task).** S15's
  driver blocks per `be-chat` exactly as `vim-chat-prompt` blocks per `chat-ask`
  (`command-loop.chiral:792`, `chat.chiral:52`). Incremental = repaint between calls.
  Non-blocking/async is residue (§9), not S15, not faked.

- **D6 — per-expert incremental, NOT token streaming.** **RESOLVED (deferred to a real
  slice).** The engine is deliberately non-streaming (`run-pipeline` uses `be-chat`,
  not `be-chat-stream`; `runner.chiral:11-13` header). S15 repaints **once per expert**
  (each `be-chat` returns whole, then the row appears). TRUE token-by-token streaming
  — threading `be-chat-stream`'s `(=> Str Unit)` on-delta callback through the driver +
  the `r-stream` render node (`render.chiral:10`, currently unused) — is **S17**
  ("manas run-view — token streaming (be-chat-stream on-delta)", `SCRIBA-SLICES.md`
  row 17, minted 2026-08-16, gated `S15 + be-chat-stream`). CONFIRMED S17 exists, so
  this deferral names a real cataloged slice per the CLAUDE.md deferral rule — **not a
  phantom**. Do NOT implement token streaming under S15.

- **D7 — no persistence / no be-log.** **RESOLVED.** The finished `RunManifest` lives
  in the `vm-runview` state; writing it to disk (`be-log`, E139) is **optional** for
  S15 (SCRIBA-SLICES row 15: "E139 be-log optional") and out of scope — the cockpit
  renders the in-memory value; logging it is a separate crossing (§9). Re-run/compose
  is S16.

- **D8 — the fired config/pipeline is fixed (the sample's).** **RESOLVED (scoped).**
  S15 fires the crafted doc-refine run (`smoke-local-config` + `doc-refine-pipeline` +
  the sample's `rv-doc`/`rv-extra`, §4.4). *Choosing* which pipeline/profile to fire,
  binding a backend, and the one-keybind launch from the library view are **S16**
  (compose, `SCRIBA-SLICES.md` row 16) — S15 is only the render of a run once fired.

- **NEEDS-AUTHOR:** none. Every primitive the example relies on is a verified public
  def (`plan-run`, `call-expert`, `call-combiner`, `assemble-manifest`, `gather-findings`,
  `ids-of-experts`, `bnd-model`, `exp-slot`, `empty-manifest`) and every render helper
  it reuses is a verified public def in `manas-mode.chiral`. The one design gap (D2) is
  mechanically buildable and resolved above.

---

## §7 Commit-sized change plan

Each commit is independently B1-compilable and testable. Order respects deps (the pure
core before the driver that grows it; the `VimMode` variant and all three of its
exhaustive-`case` arms land together so the coverage checker stays satisfied).

1. **`manas-runview: RunView/RunPhase/RvCall + runview-render pure core + faces + unit test`**
   — new `manas-runview.chiral` with the §3 sums + `outcome-row`/`phase-tag`/
   `runview-render`/`rv-*` helpers (pure imports only: prelude, render, manas-mode,
   manas/core/types); the two `default-faces` entries in `render.chiral` (§2.2); new
   `scriba-runview-test.chiral` (§8.1). **Gate:** the test ELF exits 0 (§1 leg 1). Does
   not touch the scriba graph (`manas-runview` is still an orphan), so `bin/scriba` is
   unchanged.

2. **`manas-runview: runview-drive + fan-render effectful driver`** — add the driver
   imports (backend, plan, runner, profiles, doc-refine, collections) + `runview-drive`/
   `fan-render`/`outcomes-of`/`yield-of` + the `rv-*` crafted-input constants (§4.1/§4.2/
   §4.4). **Gate:** the module type-checks/compiles into a leaf blob (still an orphan to
   scriba — no `bin/scriba` change yet; the `be-chat` row is proved by the membrane).

3. **`scriba: vm-runview variant + nav dispatch + resize arm (atomic w/ coverage)`** —
   `vim-mode.chiral` variant + `mode-name` arm + `(import "manas-runview")` (§2.3);
   `command-loop.chiral` `case mode` dispatch arm (`:959`) + resize arm (`:962`) +
   `runview-nav-dispatch` (§2.4). **One atomic commit** because the new `VimMode`
   variant without *all three* exhaustive-`case` arms (`mode-name`, the dispatch `case
   mode`, the resize `case mode`) fails coverage — this is the S15 analog of S14's
   commit-4 coverage constraint. This commit first pulls the manas engine into the
   scriba blob (§5), so `bin/scriba` grows here. **Gate:** `bin/scriba` builds (exit 0).

4. **`scriba: :run fire entry + PTY smoke`** — the `vim-command-run` `:run` arm +
   `runview-fire` (§4.3). **Gate:** `bin/scriba` builds; PTY smoke (§8.2).

---

## §8 Conformance / test gate

### 8.1 Unit tests (`scriba-runview-test.chiral`) — the contract

Idiom per `scriba-test-b1.chiral`: each test returns `I64` (0 = pass, 1 = fail);
`compile-main` ANDs them. Build+run per §1 leg 1. All pure — **no PTY, no network, no
fork**.

**T1 — the GATE line (a `rv-planned` view).** Build
`rv = (run-view "refine X" (rv-planned) "6 rules matched" (cons "claim-vs-source" (cons "anchor-sharpen" nil)) nil "" none)`.
`runview-render rv dims 0` → assert the second row's text is
`"GATE  6 rules matched  ->  claim-vs-source, anchor-sharpen"` (the routing reason +
`join-comma` of the fired ids). Proves the GATE renders from a pure value with no
network (the §3-payoff: the decision is on screen before any `be-chat`).

**T2 — a good row and a bad row (a mid-fan `rv-calling` view).** Build a `done` list
of two `RvCall`s: `(rv-call "claim-vs-source" "reasoner" "qwen2.5:0.5b" (expert-ok nil "…"))`
and `(rv-call "anchor-sharpen" "reasoner" "qwen2.5:0.5b" (expert-bad "…" "http-500"))`.
Assert `outcome-row` of the first is a `manas-ok` face whose text contains
`"OK   claim-vs-source"` and `"(reasoner -> qwen2.5:0.5b)"`; of the second is a
`manas-bad` face whose text contains `"BAD  http-500"` and `"anchor-sharpen"`. Proves
the failure is a typed row you can SEE in place, and that the `case` on `ExpertOutcome`
**forces** the bad branch (a dropped failure is not representable).

**T3 — the finished run (a `rv-done` view).** Build `rv` with `phase = rv-done`,
`yield = "the merged refinement"`, `final = (some m)` for a hand-built `RunManifest`.
Assert the `COMBINER` row text = `"COMBINER  (done)"` (via `phase-tag rv-done`) and the
`YIELD` row text = `"YIELD  the merged refinement"`. Proves the combiner + yield close
the render and `phase-tag` is a faithful readback of the closed `RunPhase` sum.

**T4 — a routing failure (a `rv-failed` view).** `rv = (rv-fail "req" "no-route")`;
assert the `COMBINER` row text = `"COMBINER  (failed: no-route)"` and there are no
`outcome-rows`. Proves a routing failure renders as a value (a red status line), never
a crash — the `plan-no-route`/`plan-no-fire`/`plan-unbound` branches of the driver.

### 8.2 Build + PTY smoke — the wiring gate

`bin/scriba` builds (B1 compile, exit 0). PTY, mesh reachable, in order:
1. `:run` → `-- Run --`; the `RUN`/`GATE` lines render **immediately** (fired set +
   routing reason on screen while the first model call is still in flight).
2. per-expert repaint — one `manas-ok` (green) or `manas-bad` (red) row appears as each
   `be-chat` returns; the `COMBINER  (calling N)` status advances.
3. combiner + yield — the `COMBINER  (done)` row and the `YIELD  …` block close the run.
4. ESC → `-- Normal --` (the finished run is dropped from live state — §9).
5. (liveness/failure) an unreachable mesh or a routing failure renders a red
   `BAD`/`(failed: …)` line, never a crash.

### 8.3 Self-host note

S15 touches only scriba (`TUI/scriba/*`) + `render.chiral` (a face-table data edit) and
imports the (unchanged) manas library + engine — **no compiler source changes**, so the
B1-reproduces-itself self-host check (CLAUDE.md BUILD RULE) is **not** triggered.
Build-new → test → done.

---

## §9 Honest residue (scope must NOT expand it)

- **No token-by-token streaming.** S15 repaints once per expert (each `be-chat` returns
  whole). Intra-response streaming (thread `be-chat-stream`'s `(=> Str Unit)` on-delta
  through the driver + the `r-stream` node) is **S17** (row 17, minted 2026-08-16,
  gated `S15 + be-chat-stream`) — §6 D6. Not done here.
- **No non-blocking / async.** The driver blocks the editor per `be-chat` (like
  `vim-chat-prompt` per `chat-ask`). True non-blocking needs an async/select substrate
  scriba does not have — out, not faked (§6 D5).
- **No compose / choosing what to fire.** S15 fires a *fixed* crafted run
  (`smoke-local-config` + `doc-refine-pipeline` + the sample's inputs). Picking a
  pipeline, binding a profile, and the one-keybind launch from the library view are
  **S16** (compose, row 16) — §6 D8.
- **No persistence / re-run.** The finished `RunManifest` lives in the `vm-runview`
  state; writing it to disk (`be-log`, E139) is **optional** and out (§6 D7); re-firing
  is S16.
- **No retrieval.** `context-chunks-used` renders empty (the crafted run has no
  retrieval — `assemble-prompt`'s context is `nil`, `runner.chiral:71`); wiring real
  retrieval is engine work, not the view.
- **No per-call drill-in.** The rows render id + ok/bad + `slot -> model`; the finished
  manifest's `ExpertCall` (`types.chiral:131`) carries the full nine fields
  (`num-ctx`/`sha256`/`duration-ms`). A drill-in row (an `r-section` collapse) is a
  natural extension, out of the first cut.
- **No scroll / cursor.** `runview-render` renders the whole value (no windowing); the
  terminal cursor tracks the parked Str buffer (cosmetic). Scroll-the-manifest and
  cursor suppression are UX polish, out of S15 — not deferred to any named slice (no
  phantom).

### Relational anchors

Gate E138 (`plan.chiral`/`runner.chiral`) + E141 (`types.chiral` `RunManifest`); E139
optional. Seed S14 (`manas-mode.chiral` render helpers + `manas-*` faces) + slice 12
(the colorer). Pattern S13 (`vim-mode.chiral` variant-carries-state) + I1 (`chat.chiral`
+ `command-loop.chiral` `vim-chat-prompt` effect-then-repaint loop). Baseline improved
on: `scaffold/samples/manas-run.chiral` (the headless JSON dump). Fed to S17 (token
streaming) + S16 (compose — chooses the run S15 renders).

---

*Spec written: `docs/elements/specs/S15-manas-run-view-SPEC.md`. Implementation runs
follow this SPEC; the example stays the rationale.*
