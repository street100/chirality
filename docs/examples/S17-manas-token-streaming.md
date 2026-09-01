# S17 — manas run-view: token streaming (be-chat-stream on-delta)

Worked example. Pipeline stage 1 of 5 (example -> audit -> spec -> audit -> implement).

## §1 Scope

S15 made the run **structured** — the cockpit renders the typed `RunManifest` as it
is built, repainting **once per expert** as each `be-chat` returns (`manas-runview.chiral`
`runview-drive`/`fan-render`). That is real incremental rendering, but the per-expert
row is **blank until that expert's whole response arrives**: on a slow model each row
is a ~2–9s freeze, and the terminal shows nothing between the GATE line and the
finished `OK`/`BAD` row. S17 makes the **wait itself visible** — the model's tokens
appear live on the current expert's row as they are generated, not just the finished
row.

The move is one seam-swap: S15's fan-out calls **`be-chat`** (whole response, then one
repaint); S17 calls **`be-chat-stream`** (`backend.chiral:122`) and threads its 4th
argument — the **`(=> Str Unit)` on-delta callback** — down through the run-view driver,
so each token/chunk paints the instant it arrives. The GATE decision, the fired set, the
finished rows, and the manifest stay exactly the typed value S15 renders; only the
**in-flight** expert's row goes from "blank, then whole" to "tokens flowing".

**In scope** — the streaming upgrade of the run-view's **expert** calls:

1. a streaming analog of `call-expert` — **`call-expert-stream`** (`runner.chiral`) —
   identical to `call-expert` but over `be-chat-stream`, taking the `(=> Str Unit)`
   on-delta as one extra parameter (S15 deliberately scoped this out — `runner.chiral:9`
   *"non-streaming be-chat (not be-chat-stream, so no on-delta fn-param)"* — S17 is the
   slice that reverses it, gated on `be-chat-stream` existing);
2. a **streaming marker** on `RunView` (which expert is live + its slot/model) so
   `runview-render` draws the current-expert row as an open "▸ streaming" row that the
   on-delta appends to;
3. the on-delta itself — the coordinator-proven `(lam (d) (put d))` — threaded through
   `fan-render` so tokens paint inline on that row; when the call returns its `ChatR`,
   the row **collapses to the normal `OK`/`BAD` row** exactly as S15 renders today.

**Out of scope** (deferred, see §7.2): non-blocking/async streaming (the stream is a
**synchronous** linear `drain-stream` loop — the editor still blocks during a run, as in
S15); concurrent multi-expert streams (experts still stream one at a time down the
sequential fan-out); retrieval (`assemble-prompt`'s context stays `nil`); persistence
(`be-log`). Combiner streaming is a one-line same-mechanism sibling — **§7.2 decides it
in-scope-optional**.

This slice is the home of the **MANAS-STATE-VS-GOAL §8 deferred "streaming trim"**
(§8 ⚠️, lines 208–212: *"TRUE token-by-token streaming (thread the `(=> Str Unit)`
on-delta) … deferred to S17"*). It ends at **a run whose in-flight expert row grows
token-by-token, then settles into the typed `RvCall` S15 already renders**.

## §2 Research (what already exists, on both sides)

**The streaming primitive is built, sample-verified, and its shape is frozen.**
`be-chat-stream` (`backend.chiral:122`) is:

```
(def be-chat-stream (=> Backend Str (List Msg) (=> Str Unit) ChatR) …)
```

Its 4th argument is the on-delta `(=> Str Unit)`. Internally it opens the SSE stream
(`chat-open`, E131) and hands it to `drain-stream` (`backend.chiral:113`), which threads
the **linear** `(1 s ChatStream)` handle and, per content delta, does
`(do (on-delta d) (drain-stream s2 on-delta (str-cat acc d)))` — i.e. **the callback
fires synchronously, once per SSE frame, as bytes arrive**; the full text is accumulated
in `acc` and returned in a `ChatR` at `chunk-done` (`chat-ok acc`) or, on a mid-stream
break, `chunk-err -> (chat-bad st acc)`. So `be-chat-stream` returns **the same `ChatR`
as `be-chat`** (`chat-ok text` / `chat-bad status raw`), only with tokens observed along
the way. A mid-stream failure is **not silent** — it comes back as `chat-bad`, which the
breaker counts exactly like a non-stream failure.

The **decode side is understood**: the callback receives a **text delta** — the
`{choices:[{delta:{content}}]}` field of one SSE `data:` frame (`backend.chiral:11–12`,
`http.chiral` `json-delta`), already parsed to a `Str` by the time it reaches on-delta.
S17 never touches the wire; it receives strings.

**The proven synchronous stream-and-paint loop already exists — twice:**

- **`coordinator.chiral` `run-cycle`** (`coordinator.chiral:37–42`) — the minimal
  end-to-end cycle passes `(lam (d) (put d))` as the on-delta, streaming a completion to
  stdout one `put` per delta. This is the exact on-delta S17 uses.
- **`samples/stream-ollama.chiral`** — a chirality-only `chat-open -> chat-read loop ->
  (put d) -> chat-close` smoke test against the live mesh, `exit 0` on clean `[DONE]`.
  Proves the loop end-to-end against a real endpoint.

So the "how does a UI stream a model?" question is **answered and shipped** — as a
`put`-per-delta loop, not as new machinery.

**Honest correction (do not repeat the S17-row's premise):** scriba's **chat mode does
NOT token-stream today.** `chat.chiral` `chat-send` calls `chat-ask` -> `agent-run-transcript`
(`chat.chiral:52–64`), a **blocking full-turn** tool-call loop that returns the whole
transcript as one string, then `chat-append` splices it in. There is no on-delta into the
chat buffer. So S17 is actually scriba's **first** token-streaming surface — but it is
**not speculative**: it is built on the engine-side `be-chat-stream`/`drain-stream`
primitive that `coordinator.chiral` and `stream-ollama.chiral` already drive against the
live mesh. The proven pattern to cite is **those two**, not chat mode.

**S15's run-view is the frame S17 grows into.** `RunView`/`RunPhase`/`RvCall`
(`manas-runview.chiral:37–61`), `runview-render` (`:98`), `runview-drive` (`:181`),
`fan-render` (`:162`), and `repaint-runview` (`:153`) are all shipped. S17 changes
`fan-render`'s call (`be-chat` -> `be-chat-stream` via `call-expert-stream`), adds a
streaming marker, and adds one render arm — everything else is reused verbatim.

So S17 is **one streaming call wrapper + one `RunView` marker + one render arm + a
`(lam (d) (put d))` on-delta** — no new engine primitive, no new render node.

## §3 Conventional approach (raw SSE bytes + a hand-managed scroll buffer)

The normal way to token-stream a model into a TUI is to open the SSE byte-stream
yourself and hand-manage a growing buffer:

```python
buf = ""
with client.stream("POST", url, json={"stream": True}) as r:
    for line in r.iter_lines():
        if not line.startswith("data: "):        # frame framing, by hand
            continue
        payload = line[len("data: "):]
        if payload == "[DONE]":
            break
        delta = json.loads(payload)["choices"][0]["delta"].get("content", "")
        buf += delta                              # accumulate
        sys.stdout.write(delta); sys.stdout.flush()   # and hope the cursor is right
        # …and separately keep the "which agent, ok or failed" state somewhere else
```

Three things are wrong, all the same wrongness — **the stream is a side-channel, cut off
from the run's structure:**

- **The wire format leaks into the UI.** You parse `data: `/`[DONE]` framing and dig
  `choices[0].delta.content` in the render loop. A malformed frame, a provider that puts
  the text under a different key, an error frame mid-stream — each is a raw-bytes edge you
  handle by hand, in the place that is supposed to be drawing.
- **The partial text and the run's structure drift apart.** `buf` is a mutable string;
  "which agent is this", "did it fail", "which agents fired and why" live in *other*
  variables. A mid-stream HTTP error writes some bytes to `buf`, then throws — the buffer
  is half-full, the structured state says "in progress", and nothing reconciles them.
- **Streaming is bolted onto the structure, not part of it.** The GATE decision, the
  fired set, the per-agent pass/fail — the structural view you built for the non-stream
  case — is now a separate thing from the scroll buffer. You maintain two models of the
  run and pray they agree.

The tokens flow, but as an opaque byte-stream beside the run, not as a controlled part
of it.

## §4 The chirality idea — the stream is a typed callback threaded through the SAME total render

In scriba, token-streaming is not a raw byte-loop beside the structure. It is: **the
`be-chat-stream` on-delta is a typed `(=> Str Unit)` callback; the run-view is still the
total render of the typed `RunView`; the stream is a controlled effect threaded through
that render, not a side-channel.** The GATE / fired-set / finished rows / manifest are
the typed value around the stream; the stream is one expert's row, live.

```
  runview-drive  (=> be-chat-stream)
        │  plan-run (PURE)  → GATE painted before any network (S15, unchanged)
        ▼
  fan-render, per fired expert e:
        │  set RunView phase = (rv-streaming id slot model) ; paint the OPEN row prefix
        │  call-expert-stream b e … model  (lam (d) (put d))     ← tokens flow INLINE
        │        └─ be-chat-stream → drain-stream: on-delta d per SSE frame  → (put d)
        │  ← ChatR (chat-ok full-text | chat-bad status raw)
        │  cons the settled RvCall (expert-ok/expert-bad) into `done`
        ▼  repaint the RunView  → the open row COLLAPSES to the normal OK/BAD row (S15)
```

**Why chirality helps — the three §3 wrongnesses become structural:**

- **The wire never reaches the UI.** on-delta receives a **`Str`** — `drain-stream`
  already parsed the SSE frame and dug out `delta.content` (`backend.chiral` / `http.chiral`
  `json-delta`). scriba's callback is `(lam (d) (put d))`: it prints a string. Framing,
  `[DONE]`, provider key differences, error frames — all handled **below** the membrane,
  in the frozen primitive, once. The UI streams text, not bytes.
- **The partial text and the structure cannot drift — because the structure is
  authoritative and the text is transient.** The `(=> Str Unit)` callback returns `Unit`:
  it can **only paint**, it cannot thread a value (and scriba has **no mutable refs** —
  `command-loop.chiral:457`). So the accumulating text is **not** stored in `RunView`; it
  is painted inline by `put` (coordinator-style), and the **authoritative full text
  arrives in the returned `ChatR`** (`chat-ok acc`), which `fan-render` maps to a settled
  `RvCall`. A mid-stream failure returns `chat-bad` -> `expert-bad`, so the row settles
  **red** — the §3 half-full-buffer-then-throw is not representable: there is no run-time
  in which the structure disagrees with what settled.
- **Streaming is part of the total render, not bolted on.** The live row is drawn from a
  `RunView` field/phase (`rv-streaming id slot model`), so "expert X is streaming on its
  slot's model" is the **same typed value** the GATE and finished rows come from. The
  render describes the whole run *including* which row is live; the tokens are that row's
  content, flowing.

This is the S17 form of the cockpit's pure/effectful split: `runview-render` stays **pure
`->`** (it draws the frame, including the open streaming-row prefix, from the value);
`call-expert-stream`/`fan-render` are **`=>`** — and the on-delta's own effect row is just
`put` (the terminal-write crossing scriba's repaint already uses). The membrane
guarantees the pure render cannot sneak a token, and the stream cannot sneak past the
structure.

**The subtle honesty (called out).** During a stream the terminal briefly shows bytes
that are **not** in the `RunView` value — the only moment in the whole cockpit where the
screen is ahead of the typed value. This is deliberate and bounded: a `(=> Str Unit)`
callback with no ref cell **cannot** fold text into a value, and scriba's no-refs
discipline is a feature, not a gap. The reconciliation is immediate — the next repaint
(driven off the returned `ChatR`) redraws the row from the settled `RvCall`, from scratch
(`render-to-ansi-full` clears then draws), so the transient stream is replaced, never
merged. The "purer" alternative — a mutable stream-cell the callback appends to and the
renderer reads — is exactly the ref scriba refuses; see §7.2.

## §5 Chirality example (fleshed)

### §5.1 `call-expert-stream` — the streaming wrapper (engine, runner.chiral)

The only engine change: a streaming twin of `call-expert` (`runner.chiral:66`). It is
`call-expert` with `be-chat` swapped for `be-chat-stream` and the on-delta threaded in as
one extra parameter — **prompt assembly, the JSON instruction, `parse-findings`, and the
`expert-ok`/`expert-bad` mapping are byte-identical**, so a streamed call and a
non-streamed call produce the same `ExpertOutcome`. This keeps the one place that knows
the SEES prompt + the findings shape single-sourced (S17 does not duplicate it in scriba):

```
; runner.chiral, beside call-expert. Identical body; be-chat -> be-chat-stream + on-delta.
; The full text still arrives in the ChatR (drain-stream's acc), so parse-findings runs on
; the SAME string call-expert would have parsed — parsed_ok semantics unchanged. Row:
; (be-chat-stream) = the same backend seam as (be-chat), now with an on-delta.
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
```

**Decision (call-expert-stream vs direct be-chat-stream in the driver):** the wrapper
lives in `runner.chiral`, not inlined in scriba's `fan-render`. Reason: `call-expert`
owns the SEES-prompt + JSON-instruction + `parse-findings` contract; a scriba-side
`be-chat-stream` call would have to duplicate all of it and could drift from the
non-stream path. The wrapper adds exactly one parameter and reuses everything. (A
`call-combiner-stream` sibling is the same one-line change over `call-combiner`
(`runner.chiral:87`) — §7.2.)

### §5.2 The `RunView` streaming marker (scriba)

The `(=> Str Unit)` callback cannot store the growing text, so `RunView` carries only
**who is streaming** — enough for `runview-render` to draw the open row's prefix. Add one
`RunPhase` arm beside `rv-calling` (`manas-runview.chiral:37–43`):

```
(data RunPhase ()
  (rv-planning)
  (rv-planned)
  (rv-calling   (idx I64))
  (rv-streaming (idx I64) (id Str) (slot Str) (model Str))  ; S17: expert idx is LIVE, tokens flowing
  (rv-combining)
  (rv-done)
  (rv-failed    (reason Str)))
```

`phase-tag` (`:83`) gets its forced arm (the closed sum makes "forgot the streaming
state" a type error):

```
      ((rv-streaming idx id slot model) (str-cat "(streaming " (str-cat (i64->str idx) ")")))
```

No new field on the `run-view` record and **no new `RvCall`** — the finished rows in
`done` are unchanged; the streaming row is a *transient* draw off the phase, replaced by a
settled `RvCall` the instant the call returns.

### §5.3 The open streaming row in `runview-render` (pure)

`runview-render` (`:98`) draws the same frame — `RUN` / `GATE` / the `done` rows via
`outcome-rows` — and, when `phase` is `rv-streaming`, appends **one open row** whose
prefix ends exactly where the tokens will flow. The prefix is a `manas-ok`-faced `r-text`
(reusing S15's faces + row helpers); the on-delta puts deltas right after it:

```
; the open streaming row: "  ▸▸   <id>   (<slot> -> <model>)  " — cursor parks at the end,
; on-delta appends tokens here. Reuses r-face + r-text; NO new render node.
(def streaming-row (-> Str Str Str Rendering)
  (lam (id slot model)
    (r-face "manas-ok"
      (r-text (str-cat "  >>   " (str-cat id (str-cat "   (" (str-cat slot (str-cat " -> " (str-cat model ")  ")))))) false))))
```

and the render appends it when live (otherwise the frame is exactly S15's):

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
                (_                                              ; every other phase = S15 frame
                  (cons (mf-row (str-cat "COMBINER  " (phase-tag phase)))
                  (cons (mf-row (str-cat "YIELD  " yield)) nil))))))))))))
```

**On the render node (`r-stream`):** the growing token text is **not** a stored value, so
it is **not** rendered by a `Rendering` node during the stream — it is raw `put` output,
coordinator-style. The existing `r-stream (source-id Str)` node (`render.chiral:10`,
drawn as `[source-id — live stream]`, encoded in `TUI/apc.chiral`) is the **APC
side-channel placeholder** — a marker for the structured-terminal tier that "a live
stream renders here", carrying **no text**. So S17 needs **no new render node**: the
synchronous in-buffer path prints tokens with `put`. If the structured/APC side-channel
tier (`TUI/apc.chiral`) wants to advertise the live row, `runview-render` may drop an
`(r-stream (str-cat "expert:" id))` marker at the streaming row — reusing the **already
built** node, no change. (Extending `r-stream` to *carry* the accumulating text — the
purer total-render form — is an optional axis that touches `render.chiral` **and**
`TUI/apc.chiral`'s encoder/decoder; it is not required and is contained in those two files,
not a new element — §7.2.)

### §5.4 The on-delta + `fan-render` (the live seam)

The on-delta is coordinator's callback verbatim — `(lam (d) (put d))` — and `fan-render`
(`:162`) sets the streaming phase + paints the open prefix **before** the call, then
settles the row **after**:

```
(def fan-render
  (lam (b exps bindings doc extra rv dims acc)
    (case exps
      (nil (reverse RvCall acc))
      ((cons e rest)
        (let ((slot  (exp-slot e)))
          (let ((model (bnd-model bindings slot)))
            (let ((id (expert-id e)))
              ; 1. mark this expert LIVE and paint the frame + open row prefix; cursor
              ;    parks at the end of streaming-row (the last put position).
              (let ((rv-live (rv-streaming-of rv acc id slot model)))
                (let ((_ (repaint-runview rv-live dims)))
                  ; 2. stream: each delta puts INLINE right after the prefix (coordinator
                  ;    run-cycle:40–42 does exactly (lam (d) (put d))). Synchronous.
                  (let ((oc (call-expert-stream b e doc extra model (lam (d) (put d)))))
                    ; 3. settle: cons the RvCall (full text from the ChatR), repaint —
                    ;    the open row COLLAPSES to the S15 OK/BAD row (redrawn from scratch).
                    (let ((acc2 (append RvCall acc (cons (rv-call id slot model oc) nil))))
                      (let ((rv2 (rv-with-calls rv acc2 (len-rvcall acc2))))
                        (let ((_ (repaint-runview rv2 dims)))
                          (fan-render b rest bindings doc extra rv2 dims acc2))))))))))))))))
```

`rv-streaming-of` is a small pure builder (the S17 sibling of `rv-with-calls`,
`:124`) that sets `phase = (rv-streaming (len-rvcall acc) id slot model)` and keeps `done
= acc`. `repaint-runview`/`rv-with-calls`/`rv-call`/`len-rvcall` are S15's, reused.
`runview-drive` (`:181`) is **unchanged** — it already calls `fan-render`; the streaming
lives entirely inside it.

**Why the inline `put` is not corrupted by the settle repaint:** `render-to-ansi-full`
(`repaint-runview`) clears the screen and redraws from `(1,1)` (`render.chiral:468`), so
the transient streamed bytes are wiped and the settled `RvCall` row is drawn fresh — the
stream is **replaced, never merged**. The one caveat is the streaming row's own length:
a very long line clips at the right edge under `ansi-nowrap` (`render.chiral:287`, the
known cursor/wrap limitation) — acceptable residue (§7.2).

## §6 Three walkthroughs (open the row, tokens flow, settle)

The doc-refine sample fires **six** experts + a combiner. S17 streams each expert row.

### §6.1 The open row appears before the first token (from the typed phase)

```
  :run  →  plan-run (PURE) → GATE painted (S15, pre-network, unchanged)
  fan-render on claim-vs-source: phase = (rv-streaming 0 "claim-vs-source" "reasoner" "qwen2.5:0.5b")
```

- `repaint-runview` paints the frame + the open row prefix; the cursor parks at its end:
  ```
  RUN  refine this doc: check it against reality, sharpen anchors, …
  GATE  6 rules matched  ->  claim-vs-source, anchor-sharpen, …
    >>   claim-vs-source   (reasoner -> qwen2.5:0.5b)  ▮        ← cursor here, no tokens yet
  COMBINER  (streaming 0)
  ```
- **The payoff of §3-bullet-3:** the live row is drawn from the **typed phase**, sitting
  in the same structure as the GATE and the (empty) finished set — not a scroll buffer off
  to the side. "claim-vs-source is streaming on reasoner→qwen2.5:0.5b" is a value.

### §6.2 Tokens flow inline as the model generates (the live update)

```
  be-chat-stream → drain-stream: on-delta "The" ; on-delta " claim" ; on-delta " that" ; …
  each → (put d)  — appended right after the prefix, in place
```

- The row grows token-by-token, no repaint per token (no screen clear) — exactly
  `coordinator.chiral:40–42`'s `(lam (d) (put d))`:
  ```
    >>   claim-vs-source   (reasoner -> qwen2.5:0.5b)  The claim that the loader reads▮
  ```
- **The payoff of §3-bullet-1:** the callback prints a **`Str`** — the SSE framing,
  `[DONE]`, `delta.content` digging are all handled once, below the membrane, in
  `drain-stream`. The UI streams text, never bytes.

### §6.3 The row settles into the typed RvCall (reconciliation)

```
  drain-stream hits chunk-done → chat-ok <full text>  → call-expert-stream → expert-ok
  fan-render conses (rv-call "claim-vs-source" "reasoner" "qwen2.5:0.5b" (expert-ok …))
  repaint (render-to-ansi-full: clear + redraw)
```

- the transient stream is wiped; the row is redrawn from the settled value as the S15
  `manas-ok` (green) `OK` row, and the next expert's open row begins:
  ```
    OK   claim-vs-source        (reasoner -> qwen2.5:0.5b)
    >>   anchor-sharpen   (reasoner -> qwen2.5:0.5b)  ▮
  ```
- **A mid-stream failure settles red:** if the stream breaks (`chunk-err st` ->
  `chat-bad st acc`), `call-expert-stream` returns `expert-bad r "http-<st>"`, and
  `outcome-row`'s `case` (`:73`) forces the `manas-bad` row **in place** — the §3
  half-full-buffer-then-throw is not representable, because what settles is the typed
  `ExpertOutcome`, not a dangling buffer:
  ```
    OK   claim-vs-source        (reasoner -> qwen2.5:0.5b)
    BAD  http-500               anchor-sharpen
    >>   example-completeness   (reasoner -> qwen2.5:0.5b)  ▮
  ```
- **un-representable path:** there is no run-time in which the structure and the screen
  disagree past the settle — the only authority for a finished row is its `RvCall`, and
  the repaint redraws from scratch. The stream is ahead of the value **only** while live,
  then reconciled.

The combiner + yield close the run exactly as S15 (§6.4 there) — with a
`call-combiner-stream` the combiner's yield streams too (§7.2).

## §7 Use / modify notes, honest residue, anchors

### §7.1 Use / modify notes

- **S15 is the frame, reused not replaced:** `RunView`/`RvCall`/`outcome-row`/
  `runview-render`/`runview-drive`/`repaint-runview`/`rv-with-calls` all carry over;
  S17 adds one `RunPhase` arm (`rv-streaming`), one pure builder (`rv-streaming-of`), one
  render arm (`streaming-row`), and swaps `fan-render`'s call. No new faces (`manas-ok`/
  `manas-bad` from S15 render the open + settled rows).
- **The engine delta is one wrapper.** `call-expert-stream` in `runner.chiral` mirrors
  `call-expert` (be-chat -> be-chat-stream + on-delta); prompt/parse/outcome mapping is
  identical, so a streamed run's `RunManifest` is byte-identical to a non-streamed one
  (`parse-findings` runs on the same full text). This is S17's own cataloged delta (the
  slice is gated on `be-chat-stream`), **not a new element** — see §7.3.
- **The on-delta is the proven `(lam (d) (put d))`** — `coordinator.chiral:40–42` and
  `samples/stream-ollama.chiral` already drive this loop against the live mesh. S17 threads
  it through `fan-render`; it is not new machinery. (**Note:** scriba **chat** mode does
  NOT stream — `chat.chiral` blocks on `agent-run-transcript` — so S17 is scriba's first
  streaming surface, but on a shipped, sample-verified primitive.)
- **`runview-render` stays pure (`->`).** It draws the open-row *prefix* from the typed
  phase; the *tokens* are `put` by the effectful on-delta. The membrane keeps the render
  from streaming and the stream from mutating the value — the S17 pure/effectful split.
- **No new render node.** The existing `r-stream (source-id Str)` (`render.chiral:10`) is
  the APC side-channel placeholder; S17's synchronous path uses `put`. `r-stream` may
  optionally be dropped in as a side-channel marker (already built), or extended to carry
  text (optional, touches `render.chiral` + `TUI/apc.chiral`, contained — §7.2).

### §7.2 Honest residue (what S17 does NOT cover)

- **Non-blocking / async streaming.** The stream is a **synchronous** linear
  `drain-stream` loop (`backend.chiral:113`) — the editor blocks during the run exactly as
  S15 blocks per `be-chat` (and chat mode blocks on `agent-run-transcript`). Tokens flow
  *within* a call, but you cannot type over a running stream. True non-blocking needs an
  async/select substrate scriba does not have; **not in S17, not faked.**
- **Concurrent multi-expert streaming.** Experts still stream **one at a time** down the
  sequential `fan-render` — one open row at a time. Fanning six streams into six live rows
  at once is the async substrate above, not this slice.
- **Combiner streaming — in-scope-optional (decision).** `call-combiner-stream` over
  `call-combiner` (`runner.chiral:87`) is the **same one-line** change (be-chat ->
  be-chat-stream + on-delta), and the combiner's yield is where the *final* text appears —
  so streaming it is high-value and trivial. **Decision: fold it in** (both
  `call-expert-stream` and `call-combiner-stream`), with an `rv-streaming`-style
  combiner-live phase; if scoping tight, the combiner is the one deferrable half (experts
  are the N-way wait that hurts most). Either way it is the *same mechanism*, not a new
  capability — **nothing new to mint.**
- **The "purer" total-render form (a stream cell).** Storing the growing text *in* the
  `RunView` (so `runview-render` is a total render of the live text, not just its prefix)
  needs a mutable cell the `(=> Str Unit)` callback appends to and the renderer reads —
  exactly the **mutable ref scriba refuses** (`command-loop.chiral:457` — "no mutable
  refs"). S17 deliberately takes the transient-`put` path instead (coordinator's shape),
  reconciling to the value at `ChatR` return. A ref-backed or `r-stream`-carries-text
  variant is a **design axis**, contained in `render.chiral` (+ `TUI/apc.chiral` for the
  side-channel), **not a new element** — recorded here so it is not silently resolved.
- **Per-line repaint cost / long-line wrap.** on-delta `put`s inline (no full clear per
  token — O(delta) per token, not O(screen)), so cost is fine; but a streaming line longer
  than the terminal width **clips at the right edge** under `ansi-nowrap`
  (`render.chiral:287`, the known cursor/wrap limitation — a cell-grid renderer, the
  dropped vt-core/grid work, is the real fix). A line-local `render-to-ansi-delta`
  (`render.chiral:476`) repaint of just the streaming row is a natural optimization, left
  to implementation.
- **Retrieval / prompt shape.** `call-expert-stream` keeps `assemble-prompt`'s context
  `nil` (no retrieval, as S15) — wiring retrieval is engine work, orthogonal to streaming.

### §7.3 Relational anchors + minting

- **Gate:** **S15** (`manas-runview.chiral` — the run-view frame S17 grows) +
  **`be-chat-stream`** (`backend.chiral:122` — exists, the primitive threaded). Without
  S15 there is no frame to stream into; without `be-chat-stream` no on-delta.
- **Seed:** **`coordinator.chiral`** `run-cycle` (`:37–42` — the `(lam (d) (put d))`
  on-delta) and **`samples/stream-ollama.chiral`** (the `chat-read -> put` loop,
  mesh-verified) — the proven synchronous stream-and-paint precedent S17 reuses. **NOT
  `chat.chiral`** (it does not stream — §2 correction).
- **Pattern:** **S15**'s pure/effectful split (`runview-render` pure, `fan-render`
  effectful) and its closed-sum `RunPhase` (S17 adds `rv-streaming`, forced by the case).
- **Baseline improved on:** S15's per-expert *incremental* render — S17 turns each
  "blank, then whole row" into "tokens flowing, then settled row".
- **Home of:** MANAS-STATE-VS-GOAL **§8** deferred "streaming trim" (§8 ⚠️, lines
  208–212) — this slice closes it.
- **Minting:** **nothing new to mint.** S17 is already minted (SCRIBA-SLICES row 17,
  2026-08-16). Its parts — `call-expert-stream`/`call-combiner-stream` (runner.chiral),
  `rv-streaming` + `streaming-row` + `rv-streaming-of` (manas-runview.chiral) — are **S17's
  own delta**, not follow-on elements. No new E#/S# is invented; the `be-chat-stream`
  primitive and `r-stream` node already exist. The optional `r-stream`-carries-text /
  ref-cell variant (§7.2) is contained in `render.chiral` + `TUI/apc.chiral`, not a
  cataloged element.

---

*File written: `.planning/scriba-examples/S17-manas-token-streaming.md`*
