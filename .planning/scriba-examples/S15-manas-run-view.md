# S15 — manas run-view (the run-manifest cockpit, Tier 2)

Worked example. Pipeline stage 1 of 5 (example -> audit -> spec -> audit -> implement).

## §1 Scope

Slice 12 gave scriba a **read-only manas colorer** (text). S14 made the library
**editable** — the buffer holds a *typed* `Config`/`Pipeline` value and edits are
total transforms over it. Both are **static**: nothing runs. S15 is the first
slice that **fires the engine and watches it run** — the Tier-2 cockpit.

The move: fire a pipeline from scriba and render the run **inline as it happens**,
as a live-updating buffer over the typed `RunManifest`, instead of the
end-of-run JSON dump the headless driver prints today
(`scaffold/samples/manas-run.chiral`). Concretely the view shows, in order:

1. the **GATE decision** — which individuals fired + the routing reason (from the
   PURE `plan-run`, before any network call);
2. each agent's **fan-out call** as it returns — SLOT -> bound-model, the SEES
   cut, and **parsed-ok as a face** (a failed agent is a red row you can *see*);
3. the **combiner** + the **final yield**, rendered structurally.

**The entry point it fires:** `guarded-run`
(`scaffold/lib/manas/pipeline/guarded.chiral`), whose type is
`(=> Backend I64 Str (List Pipeline) (List Expert) Config Str (List (Pair Str Str)) (Pair I64 (Pair Str RunManifest)))`
— its effect row is exactly **`be-chat`** (the backend network crossing). S15 is
the first scriba slice whose core is **effectful** (S13/S14 cores were pure `->`).

**In scope** — one run, rendered incrementally:

1. a new run-view mode (`vm-runview`) that holds the in-flight/finished run state;
2. a **value renderer** `runview-render : RunView -> Rendering` (reuses S14's
   `mf-row`/`mh-row` row helpers + the manas faces, i.e. "I2 transcript rendering");
3. an effectful driver `runview-drive` that renders the GATE plan, then repaints
   **once per expert** as each `be-chat` returns, then the combiner + yield.

**Out of scope** (deferred, see §7.2): true token-by-token streaming
(`be-chat-stream`'s `(=> Str Unit)` on-delta callback — the engine is currently
non-streaming); non-blocking/async runs (scriba is synchronous today); *choosing*
which pipeline/profile to fire (that is S16 compose); write-back/persistence.

This slice ends at **a finished run rendered as a navigable buffer over its
`RunManifest`** — what S16 later launches with one keybind from the library view.

## §2 Research (what already exists, on both sides)

**The engine is built and the run is one call.** `guarded-run` (E138) wraps
`run-pipeline` with E67's circuit breaker; `run-pipeline`
(`scaffold/lib/manas/pipeline/runner.chiral`) is the effectful shell whose body is
already the exact shape S15 wants to *narrate*:

```
plan-run (PURE) -> fan-experts (be-chat, N times) -> call-combiner (be-chat) -> assemble-manifest (PURE)
```

Every piece S15 renders is already a typed value or a callable primitive:

- **`plan-run`** (`plan.chiral`, **PURE `->`**) returns a `PlanOutcome`: `plan-ok
  (pipeline-id) (config-id) (routing) (fired) (comb) (bindings)` on success, or
  `plan-no-route` / `plan-no-fire (reason)` / `plan-unbound (missing) (config-id)`.
  Because it is pure, S15 can render the **GATE decision before any network call**.
- **`call-expert`** (`runner.chiral`, `=> ... ExpertOutcome`) returns an
  `ExpertOutcome`: `expert-ok (findings) (raw-response)` on a good `be-chat`, or
  `expert-bad (raw-response) (reason)` on `chat-bad` (an HTTP failure). This IS
  the per-expert unit S15 repaints on.
- **`RunManifest`** (`types.chiral`, E133) — the 15-field record the whole run
  produces (`run-id`/`request`/…/`routing-decision`/`fired-expert-ids`/
  `expert-calls`/`combiner-patches`/`final-yield`/…). This is the value the view
  is a total render of.
- **`ExpertCall`** (`types.chiral`) — the 9-field per-call record inside the
  manifest (`expert-id`/`slot`/`bound-model`/`num-ctx`/`prompt-sha256`/
  `response-sha256`/`parsed-ok`/`accepted-into-merge`/`duration-ms`). `parsed-ok`
  is a `Bool` — the face-tagged pass/fail signal. **Note (runner.chiral):**
  `parsed-ok` means "the `be-chat` call succeeded", NOT "the JSON parsed" — a
  `false` is a *backend failure* (the same thing the breaker counts).
- **`manifest-to-json`** + accessors (`contract/manifest.chiral`, E141/E139) —
  useful for a raw view / debug, but S15 renders the value *structurally*, not as
  JSON (that is the whole payoff over the headless driver).

**scriba's render + effect-in-loop machinery is built and PTY-verified:**

- **the value-render pattern** (S14, `manas-mode.chiral`): `manas-doc-render :
  ManasDoc -> (Pair I64 I64) -> I64 -> Rendering` walks a typed value into an
  `r-lines` of face-tagged `mf-row`/`mh-row` rows (`manas-field`/`manas-header`
  faces, already in `render.chiral`'s `default-faces`). S15's `runview-render` is
  the same shape over a different value.
- **the mode-variant-carrying-state pattern** (S14): `vm-manas (doc ManasDoc)`
  rides the open value *inside* the `VimMode` constructor, so
  `command-loop-inner`'s arity never changes. S15 adds `vm-runview (rv RunView)`
  identically.
- **effect-then-repaint-in-a-loop** (S13/I1, `command-loop.chiral` `vim-chat-prompt`):
  `(chat-ask prompt)` runs a synchronous network call, then the loop renders the
  reply and recurses. S15's driver is this loop with `call-expert` in place of
  `chat-ask` and a repaint **between** calls.

So S15 is **largely one value renderer + one effectful driver + one mode
variant**, reusing the engine's own primitives — not new orchestration and not
new render primitives.

## §3 Conventional approach (opaque logs / an end-of-run blob — and why it's blind)

The normal way to watch an orchestration run is to tail its logs, or (the
headless `manas-run.chiral` today) print the whole manifest as JSON at the end:

```
=== MANAS RUN MANIFEST ===
{"run_id":"…","request":"…","fired_expert_ids":["claim-vs-source","anchor-sharpen",
"example-completeness","example-organization","coverage-vs-spec","cross-doc-drift"],
"expert_calls":[{"expert_id":"claim-vs-source","slot":"reasoner","bound_model":
"qwen2.5:0.5b","num_ctx":16384,"parsed_ok":true,…},{"expert_id":"anchor-sharpen",
… "parsed_ok":false,"response_sha256":"…"} …], "combiner_patches":[…], "final_yield":"…"}
```

Three things are lost:

- **Structure is flattened into text.** "Which individuals fired and why" is a
  `fired_expert_ids` array buried in a blob; the GATE *reason* (`routing_decision`)
  is one string field next to fourteen others. You reconstruct the run's shape by
  eye.
- **You watch nothing.** The blob prints once, at the end. During the run —
  which is N sequential model calls, seconds each — the terminal is silent (or
  scrolling opaque HTTP logs). You cannot see the fan-out progress.
- **A failed agent is a needle far from the decision.** `anchor-sharpen`'s
  `"parsed_ok":false` is one boolean in the middle of a JSON array. In a
  logs-only setup it is worse: a stack trace pages away from the GATE line that
  decided to fire that agent. The failure is *disconnected* from the structure
  that caused it.

The run is a rich typed value, but the terminal only ever gets **a string of it,
once**. There is no live structure to navigate.

## §4 The chirality idea — the buffer is a live render of the typed run, not a log tail

The cockpit's model of record is **the `RunManifest` being built**, not text
scrolling by. Because the run is a *value*, the view is a **total render of that
value** (exactly as S14's buffer is a total render of a `Config`/`Pipeline`), and
because the engine builds it in named stages (`plan-run` -> fan-out -> combiner ->
assemble), the render can be **repainted at each stage** as the value grows.

The in-flight run is a small record that grows monotonically:

```
(data RunView ()
  (run-view
    (req      Str)                  ; the request being run
    (phase    RunPhase)             ; where the run is (status line + which rows are live)
    (routing  Str)                  ; the GATE reason (empty until planned)
    (fired    (List Str))           ; fired expert ids — the plan (empty until planned)
    (done     (List ExpertOutcome)) ; expert outcomes SO FAR (grows one per be-chat)
    (yield    Str)                  ; combiner yield ("" until combined)
    (final    (Maybe RunManifest)))) ; none until the run finishes; the persisted record
```

The phase is a closed sum — the compiler forces the renderer + status line to
handle every stage, so "forgot to render the combining state" is a type error:

```
(data RunPhase ()
  (rv-planning)                 ; before plan-run returns
  (rv-planned)                  ; GATE decided, no calls yet
  (rv-calling  (idx I64))       ; mid fan-out, expert idx of (len fired) in flight
  (rv-combining)                ; fan-out done, combiner in flight
  (rv-done)                     ; finished — `final` is (some manifest)
  (rv-failed   (reason Str)))   ; plan-no-route / plan-no-fire / plan-unbound — a VALUE
```

**Why chirality helps — the three losses of §3 are structural gains here:**

- **Structure is the render, not a blob.** `runview-render` walks the value into
  face-tagged rows: a `GATE` header carrying the routing reason + the fired set;
  one row per `ExpertOutcome` (`SLOT -> model`, ok/bad); a `COMBINER` row; a
  `YIELD` block. The shape you see *is* the run's shape — no reconstruction.
- **The GATE decision is visible before any network call.** `plan-run` is PURE,
  so the moment S15 has the request it can render "these 6 fired, because
  `<routing>`" — the decision is on screen while the *first* `be-chat` is still in
  flight.
- **A failed agent is a typed row you can SEE in place.** An `expert-bad` outcome
  (or a persisted `ExpertCall` with `parsed-ok:false`) renders as a `manas-bad`
  (red) row **right under the GATE line that fired it** — not a buried exception,
  not a boolean in an array. The `case` on `ExpertOutcome` *forces* the failure
  branch to be rendered; you cannot forget to show it.

The effectful shell (the run driver + repaint) stays thin and mirrors
`vim-chat-prompt`; the checking/structure lives in the typed value and its render.

## §5 Chirality example (fleshed)

### §5.1 A distinct filename (the collision)

The slice's suggested `manas-run.chiral` **collides** with the existing headless
driver `scaffold/samples/manas-run.chiral` (which fires the same engine and dumps
JSON). Two files of the same basename with opposite jobs (a headless sample vs a
scriba resident) is a footgun in the blob and in the reader's head. **Name the
scriba module `TUI/scriba/manas-runview.chiral`** — it says "the run *view*",
sits with the other scriba residents, and cannot be confused with the sample. The
sample stays the headless baseline this slice improves on.

### §5.2 The run-view state + the value renderer (pure)

The mode variant carries the run state inside `VimMode`, exactly as `vm-manas`
carries a `ManasDoc` (`vim-mode.chiral`):

```
; in vim-mode.chiral, beside vm-manas:
(vm-runview (rv RunView))
```

The renderer is pure `->`, reusing S14's `mf-row`/`mh-row` (the `manas-field`/
`manas-header` faces) plus two new pass/fail faces. Each `ExpertOutcome` becomes
one face-tagged row; a bad outcome is a `manas-bad` row:

```
; one expert outcome -> one face-tagged row (SLOT -> model is carried by the plan;
; here we render the id + ok/bad — the persisted ExpertCall adds slot/model/ms).
(def outcome-row (-> ExpertOutcome Rendering)
  (lam (oc)
    (case oc
      ((expert-ok  findings raw) (r-face "manas-ok"  (r-text (str-cat "  OK   " (raw-head raw)) false)))
      ((expert-bad raw reason)   (r-face "manas-bad" (r-text (str-cat "  BAD  " reason) false))))))

(def outcome-rows (-> (List ExpertOutcome) (List Rendering))
  (lam (ocs)
    (case ocs
      (nil nil)
      ((cons o rest) (cons (outcome-row o) (outcome-rows rest))))))
```

`runview-render` walks the whole `RunView` — GATE header, the fired plan, the
outcome rows so far, then (when present) the combiner yield:

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

`mh-row`, `mf-row`, `join-comma`, `rrows-append` are S14's helpers
(`manas-mode.chiral`) reused verbatim — the "reuse I2 transcript rendering" the
slice asks for is exactly this: the same `r-lines`-of-`r-face`-rows tree that
S14's value view and the chat transcript already emit. **Two faces are added** to
`default-faces` (the slice-12 precedent for `manas-field`/`manas-header`):
`manas-ok` (green) and `manas-bad` (red).

### §5.3 The effectful driver (the live-updating loop)

The driver mirrors `vim-chat-prompt`'s render-then-block-then-recurse shape, but
walks the engine's own stages. It reuses the **engine primitives** (`plan-run`,
`call-expert`, `call-combiner`, `assemble-manifest`) rather than calling
`run-pipeline` as a black box — because the black box returns only at the end,
and per-expert repaint needs a seam *between* the calls. **Zero engine change:**
those four are already public defs in `plan.chiral`/`runner.chiral`.

```
; runview-drive: fire one run, repainting the RunView after each stage. Effect
; row: exactly (be-chat) — the same row as run-pipeline (it calls the same prims).
(def runview-drive
  (=> Backend Str (List Pipeline) (List Expert) Config Str (List (Pair Str Str))
      (Pair I64 I64) (List (Pair Str Mode)) RunView)
  (lam (b req pipes pool config doc extra dims renderers)
    (case (plan-run req pipes pool config doc extra)            ; PURE — no network yet
      ((plan-no-route listing)    (rv-fail req "no-route"))     ; a VALUE, never a halt
      ((plan-no-fire  reason)     (rv-fail req reason))
      ((plan-unbound  missing cid)(rv-fail req "unbound"))
      ((plan-ok pid cid routing fired comb bindings)
        (let (rv0 (rv-planned-of req routing fired))            ; GATE decided
          (let (_ (repaint-runview rv0 dims renderers))         ; paint BEFORE any be-chat
            (let (outs (fan-render b fired bindings doc extra rv0 dims renderers nil))
              ; ^ per-expert: call-expert, cons the outcome, repaint, recurse
              (let (comb-oc (call-combiner b comb (gather-findings outs)
                              (ids-of-experts fired) (bnd-model bindings (exp-slot comb))))
                (let (m (assemble-manifest req pid cid routing fired bindings outs comb-oc))
                  (rv-done-of req routing fired outs comb-oc m))))))))))))
```

The fan-out is the incremental heart — `call-expert`, then repaint, then recurse
(structural recursion on the fired list -> total). It is `run-pipeline`'s
`fan-experts` with a **repaint seam** added:

```
(declare fan-render
  (=> Backend (List Expert) (List Binding) Str (List (Pair Str Str))
      RunView (Pair I64 I64) (List (Pair Str Mode)) (List ExpertOutcome)
      (List ExpertOutcome)))
(def fan-render
  (lam (b exps bindings doc extra rv dims renderers acc)
    (case exps
      (nil (reverse ExpertOutcome acc))
      ((cons e rest)
        (let (oc (call-expert b e doc extra (bnd-model bindings (exp-slot e))))  ; be-chat
          (let (acc2 (append ExpertOutcome acc (cons oc nil)))
            (let (rv2 (rv-with-done rv acc2))                 ; grow the RunView
              (let (_ (repaint-runview rv2 dims renderers))   ; REPAINT — the live update
                (fan-render b rest bindings doc extra rv2 dims renderers acc2)))))))))
```

`repaint-runview` is `runview-render` + the proven mid-effect paint
(`render-to-ansi-full`, the primitive `vim-chat-prompt` already uses after a
network call). The driver returns the final `RunView` (with `final = (some m)`),
and the caller enters `vm-runview` on it for post-run navigation.

### §5.4 The loop entry (effectful, special-cased like chat-send)

Firing a run is effectful and returns into a mode, so it is special-cased in the
loop by opname exactly as `chat-send`/`find-file` are (`command-loop.chiral`
`dispatch-op`). Entered from vm-manas (S16 wires the keybind) or `:run`:

```
(def manas-run-enter
  (=> Keymap (Puffer Str) (Maybe (Puffer Str)) (Pair I64 I64) I64 Rendering
      (List (Pair Str Mode)) (List ScribaOp) Config Pipeline Str Unit)
  (lam (km puf chat dims scroll old-rendering renderers ops config pipe req)
    (let (b (backend mesh-endpoint))                          ; the Backend ctor
      (let (rv (runview-drive b req (cons pipe nil) expert-pool config
                  the-doc the-extra dims renderers))
        ; run finished — hand control back in run-view mode over the final RunView
        (let (rendering (runview-render rv dims scroll))
          (command-loop-inner km puf chat dims scroll ""
            rendering renderers ops (vm-runview rv) pending-none))))))
```

`(backend mesh-endpoint)` is the `Backend` ctor the headless sample uses
(`(backend "http://100.64.0.5:11434")`). In vm-runview, keys are navigation only
(scroll the finished manifest, ESC -> Normal) — the run is already done; there is
no editing (S16 owns re-run/compose).

## §6 Three walkthroughs (the GATE, a good call, a failed call)

The doc-refine run from the headless sample fires **six** experts + a combiner
(seven `be-chat` crossings). Here it is, staged, in the cockpit.

### §6.1 The GATE decision renders first (pure, before any network)

```
  :run                       fire the current pipeline/config
  (plan-run runs — PURE)     GATE decided with zero network
```

- `plan-run` returns `plan-ok "doc-refine" "smoke-local" routing fired comb bindings`.
- `runview-render` paints immediately, `phase = rv-planned`:
  ```
  RUN  refine this doc: check it against reality, sharpen anchors, …
  GATE  6 rules matched  ->  claim-vs-source, anchor-sharpen, example-completeness,
                              example-organization, coverage-vs-spec, cross-doc-drift
  COMBINER  (planning)
  YIELD
  ```
- **The payoff of §3-bullet-2:** you see *which individuals fired and why* while
  the first model call is still in flight. In the headless world this line does
  not exist until the whole run ends.

### §6.2 A good expert call repaints its row (per-expert incremental)

```
  (call-expert claim-vs-source on smoke-local's reasoner slot -> qwen2.5:0.5b)
  (be-chat returns chat-ok -> expert-ok)
```

- `fan-render` conses the `expert-ok` outcome, grows the `RunView`, and repaints:
  ```
  GATE  6 rules matched  ->  claim-vs-source, anchor-sharpen, …
    OK   claim-vs-source        (reasoner -> qwen2.5:0.5b)
  COMBINER  (calling 1/6)
  ```
- the `OK` row is a `manas-ok` (green) face. The next `be-chat` blocks the loop
  (see §7.2 — synchronous), then its row appears. **Real incremental rendering
  without token-streaming:** one repaint per expert as its call returns.

### §6.3 A failed call is a red row under the GATE that fired it

```
  (call-expert anchor-sharpen -> be-chat returns chat-bad 500 -> expert-bad)
```

- `fan-render` conses an `expert-bad "…" "http-500"`; `outcome-row`'s `case`
  takes the `expert-bad` branch and emits a `manas-bad` (red) row **in place**:
  ```
    OK   claim-vs-source        (reasoner -> qwen2.5:0.5b)
    BAD  http-500               anchor-sharpen
    OK   example-completeness   (reasoner -> qwen2.5:0.5b)
  ```
- **The payoff of §3-bullet-3:** the failure sits directly under the GATE line
  that decided to fire `anchor-sharpen` — the decision and its failed consequence
  are adjacent, not a stack trace pages away. In the persisted manifest this is
  the `ExpertCall` with `parsed-ok:false`; the render surfaces it as a face, not
  a boolean in an array. The `ExpertOutcome` sum *forces* this branch to render —
  a silently-dropped failure is not representable.

### §6.4 The combiner + yield close the run

```
  (call-combiner over the six outcomes' findings -> be-chat -> combiner-ok)
  (assemble-manifest — PURE — builds the 15-field RunManifest)
```

- `phase -> rv-done`, `final = (some m)`, `yield` = the combiner text:
  ```
  COMBINER  curate-merge  (accepted 5 of 6)
  YIELD  <the merged refinement>
  ```
- control returns to `command-loop-inner` in `vm-runview` over the final
  `RunManifest`; the buffer is now navigable (scroll the calls, ESC -> Normal).
  A routing failure instead yields `rv-failed reason` (from `plan-no-route`/
  `plan-no-fire`/`plan-unbound`) — a rendered red line, never a crash.

## §7 Use / modify notes, honest residue, anchors

### §7.1 Use / modify notes

- **S14 is the seed, reused not replaced:** `mf-row`/`mh-row`/`join-comma`/
  `rrows-append` and the `manas-header`/`manas-field` faces carry over; S15 adds
  `manas-ok`/`manas-bad` and one new value type (`RunView`). Same value-render
  discipline, a running value instead of a static one.
- **The mode variant is the S14 pattern exactly:** `vm-runview (rv RunView)` rides
  the state inside `VimMode`, so `command-loop-inner`'s arity is unchanged; the
  status line gets one arm in `mode-name` ("Run").
- **The driver is the `vim-chat-prompt` pattern:** effect (`call-expert`) then
  repaint (`render-to-ansi-full`) then recurse. The one addition over chat is the
  **stage seam** — repaint between calls, driven off the engine's own
  plan/fan/combine/assemble structure.
- **Zero engine change.** `runview-drive` reuses `plan-run`/`call-expert`/
  `call-combiner`/`assemble-manifest` (already public). It intentionally does NOT
  call `guarded-run`/`run-pipeline` as a black box, because those return only at
  the end; per-expert repaint needs the seam. The breaker count `guarded-run`
  adds is orthogonal (a post-run fold) and can be recomputed from the final
  manifest if the cockpit wants to show it.
- **`runview-render` and `outcome-row` are pure (`->`)** — unit-testable on a
  hand-built `RunView`/`ExpertOutcome` with zero network, exactly like S14's
  `apply-edit` and S13's `resolve-pending`. Only `runview-drive`/`fan-render`
  are `=>` (the `be-chat` row).

### §7.2 Honest residue (what S15 does NOT cover)

- **True token-by-token streaming.** S15's first cut repaints **once per expert**
  (each `be-chat` returns whole, then the row appears) — real incremental
  rendering, but not intra-response streaming. The engine is deliberately
  **non-streaming**: `run-pipeline` uses `be-chat`, not `be-chat-stream` (its
  header notes "non-streaming be-chat … no on-delta fn-param"; deferred to S15 per
  MANAS-STATE-VS-GOAL §8). Token-streaming means threading a `be-chat-stream`
  `(=> Str Unit)` on-delta callback down through `call-expert` -> `fan-render` ->
  repaint, so a row grows as tokens arrive. That is a deeper cut touching the
  engine's `be-chat` seam (E138's signature) and the `Rendering` layer's
  `r-stream (source-id Str)` node (already in `render.chiral`, currently unused).
  **This needs its own sub-slice** — I did NOT invent a number; **flag for
  minting**: a slice "manas run-view — token streaming (be-chat-stream on-delta)"
  gated on `be-chat-stream` existing. Do not claim it done here.
- **Non-blocking / async runs.** scriba is **synchronous**: `runview-drive` blocks
  the editor during each `be-chat` (just as `vim-chat-prompt` blocks during
  `chat-ask` today — the "how chat handles it" answer is honestly *it doesn't*).
  So "live-updating" = incremental repaint **between** synchronous calls, not a
  background stream you can keep typing over. True non-blocking needs an
  async/select substrate scriba does not have; it is not in S15 and not faked.
- **Choosing/assembling what to fire.** S15 fires a *given* `Pipeline` + `Config`
  (`the-doc`/`the-extra` reuse the sample's crafted inputs). Picking a pipeline,
  binding a profile, and the one-keybind launch from the library view are **S16
  (compose)** — S15 is only the render of a run once fired.
- **Persistence / re-run.** The finished `RunManifest` lives in the `vm-runview`
  state; writing it to disk (be-log, E139) or re-firing is not in scope. `be-log`
  is *optional* for this slice (the slice row: "E139 be-log optional") — the
  cockpit renders the in-memory value; logging it is a separate crossing.
- **Retrieval / context chunks.** `context-chunks-used` renders as-is (the sample
  runs with no retrieval — `assemble-prompt`'s context is `nil`), so the row is
  empty; wiring real retrieval is engine work, not the view.
- **Per-call detail (`num-ctx`/`sha256`/`duration-ms`).** §6 renders the ok/bad +
  slot->model summary; the finished manifest's `ExpertCall` carries the full nine
  fields. A drill-in row that expands one call's shas/duration is a natural
  extension (an `r-section` collapse), left to the implementation.

### §7.3 Relational anchors

- **Gate:** **E138** (`guarded.chiral`/`runner.chiral` — the run loop S15 fires) +
  **E141** (`contract/manifest.chiral` — the `RunManifest` it renders). **E139**
  (`be-log`) is optional. Without the run loop there is nothing to fire; without
  the manifest type there is no value to render.
- **Seed:** **S14** (`manas-mode.chiral` — the `mf-row`/`mh-row` value-render
  helpers + `manas-*` faces, reused) and **slice 12** (the manas colorer / face
  precedent).
- **Pattern:** **S13** (`vim-mode.chiral` — the `VimMode` variant carrying state;
  `vm-runview` mirrors `vm-manas`) and **I1** (`chat.chiral` + `command-loop.chiral`
  `vim-chat-prompt` — the effect-then-repaint-then-recurse loop, and the
  `chat-send` opname special-casing S15's entry mirrors).
- **Baseline improved on:** `scaffold/samples/manas-run.chiral` — the headless
  driver that prints the manifest JSON at the end; S15 turns that end-of-run dump
  into the live structural cockpit.
- **Fed by S16** (compose): S16 chooses the `Pipeline` + binds the `Config`
  profile and launches the run S15 renders — one keybind from library (14) to
  run-view (15).

---

*File written: `.planning/scriba-examples/S15-manas-run-view.md`*
