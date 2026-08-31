# S16 — manas compose (pick a pipeline, bind a config, pre-flight, dispatch)

Worked example. Pipeline stage 1 of 5 (example -> audit -> spec -> audit -> implement).

## §1 Scope

Slice 12 gave scriba a **read-only manas colorer**. S14 made the library
**editable** — the buffer holds a *typed* `Config`/`Pipeline` value and edits are
total transforms over it. S15 **fired a run and rendered it live** — but it fired a
*hardcoded* pair (`doc-refine-pipeline` + `smoke-local-config`, crafted inputs;
`command-loop.chiral:700` `runview-fire`). S16 is the **top of the cockpit**: the
glue that lets you *choose* what S14 holds and *hand it to* what S15 renders — and
the **pre-flight bind check** wedged in between, so the gap between "configured" and
"runnable" is closed **at selection time**, not discovered mid-run.

The move, in three beats:

1. **pick a `Pipeline`** from the library (S14's typed values — the pickable
   process), and
2. **bind a backend** = **pick a `Config` profile** (`all-profiles` —
   `profiles.chiral:51`; selecting a Config IS the model-mixing, and the SAME
   pipeline runs under any profile — the swap property, E135), then
3. **pre-flight** the pair with E135's `bind-config` (`bind.chiral:52`) — a **pure**
   check over the *values*, no network — and only on `bind-ok` **dispatch** into
   S15's `runview-drive`. A `bind-miss` is a **visible pre-flight failure you SEE
   before any model is called**, never a mid-fan-out crash.

**In scope** — the buildable capstone over S14 + S15 + E134 + E135:

1. two new minipuffer prompt kinds — **pick-a-pipeline** (candidates = pipeline
   ids) and **pick-a-config** (candidates = `all-profiles` ids) — mirroring S14's
   author-mode prompt kinds (`minipuffer.chiral:35`);
2. a **pure** compose core `compose-preflight : Pipeline -> Config -> BindResult`
   (pipeline's needed slots `bind-config`'d against the chosen config) — the
   acceptance-critical, unit-testable, no-PTY function (the S16 sibling of S14's
   `apply-edit` and S15's `runview-render`);
3. a **one-keybind dispatch** `compose-fire` that generalizes `runview-fire`
   (`command-loop.chiral:700`): on `bind-ok` -> S15's `runview-drive`; on `bind-miss`
   -> a rendered red pre-flight line, **never fires**.

**Out of scope** (this is compose/select/pre-flight/dispatch, the glue):

- *editing* a field value (rebind a slot's model, toggle a GATE agent, set STOP) —
  that is **S14** (`manas-mode.chiral` `apply-edit`). S16 *picks* whole values; it
  does not mutate their fields.
- *rendering* the running manifest — that is **S15** (`manas-runview.chiral`
  `runview-render`/`runview-drive`). S16 *hands off to* it; the run's live paint is
  S15's job.
- **ad-hoc compose** (build a NEW `Pipeline` by picking individual agents + setting
  GATE/ORDER/COMBINER/STOP from scratch) and **persisting** any composed value back
  to source — deferred; see §7.2 (persistence gated on **E146**).

This slice ends at **a chosen (pipeline, config) pair, pre-flight-checked as a
value, dispatched with one keybind into the S15 run-view** — the connective tissue
from library (14) to run (15).

## §2 Research (what already exists, on both sides)

**Every piece S16 composes is already a built value or a public function** — S16 is
almost pure wiring, because the two slices it glues and the two engine elements it
gates on are all shipped.

The **pickable library** is concrete typed data:

- **`all-profiles`** (`profiles.chiral:51`) — the four `Config` values
  (`smoke-local`, `cheap-local`, `quality-local`, `quality`), each a
  `(config id (List Binding))`; `config-id` (`profiles.chiral:15`) reads the id;
  `profile-by-id` (`profiles.chiral:60`) resolves an id to `(Maybe Config)` (a miss
  is a **value**). These are exactly the "bind a backend" choices — the model mix.
- **`doc-refine-pipeline`** (`doc-refine.chiral:124`) — the one shipped `Pipeline`
  value; `pipeline-id` (E136) reads its id; `expert-pool` + `expert-by-id`
  (`doc-refine.chiral:88`,`:100`) + `expert-slot-of` (`doc-refine.chiral:18`) map a
  declared expert-id to the **slot** it binds. There is not yet an `all-pipelines`
  registry (only one pipeline exists) — adding one is the trivial analog of
  `all-profiles` (§7.1), not a new element.

The **pre-flight** is E135, already the exact function S16 needs:

- **`bind-config : (-> Config (List Str) BindResult)`** (`bind.chiral:52`) — **PURE
  `->`**; the membrane PROVES no network. It takes the deduped **slots-needed**
  directly and returns a **`BindResult`** (`types.chiral:42`):
  ```
  (data BindResult ()
    (bind-ok   (bindings (List Binding)))
    (bind-miss (missing-slots (List Str)) (config-id Str)))
  ```
  A slot the config doesn't bind is a **`bind-miss` carrying WHICH slots + the
  config id** — the caller cases it; "Python raised `KeyError`; here it's a value"
  (`types.chiral:39-44`).

The **GATE** is E134 (`run-gate`, `gate.chiral:113`) — pure, total, routes which
agents fire; S16 does not re-run it at selection time (see §4 on the *conservative*
slot set), but it is the routing E135 pre-flights against.

The **dispatch target** and the **entry pattern** are both shipped in S15's wiring:

- **`runview-drive`** (`manas-runview.chiral:181`) — `(=> Backend Str (List Pipeline)
  (List Expert) Config Str (List (Pair Str Str)) (Pair I64 I64) RunView)` — fire one
  run, repaint per stage; effect row exactly `be-chat`. S16 calls this with the
  **chosen** pipeline + config instead of the hardcoded pair.
- **`runview-fire`** (`command-loop.chiral:700`) — the `:run` entry that today
  hardcodes `doc-refine-pipeline` + `smoke-local-config`; S16 **generalizes it** to
  a `(pipe, config)` pair. Its special-casing (effectful, returns into a mode,
  ordered before the dispatch) is the exact template.
- **`manas-enter`** (`command-loop.chiral:662`) — the `:manas <id>` lookup entry;
  its `profile-by-id`/`"doc-refine"` id-resolution is the template for turning a
  *picked id* back into a *value*.
- **the minipuffer** (`minipuffer.chiral:28`) — `Prompt` sum + `complete`-over-
  candidates; S14 already extended it with four `prompt-manas-*` kinds
  (`minipuffer.chiral:35-38`) whose candidate lists come from the typed value. S16
  adds **two more** (pick-pipeline / pick-config) — the identical extension.

So S16 is **two minipuffer prompt kinds + one pure pre-flight function + one
generalized dispatch entry** — no new orchestration data, no new engine, no new
render primitives.

## §3 Conventional approach (hand-wired config, and the KeyError deep in the run)

The normal way to "configure the thing with pipelines and features and run it" is
to hand-edit two files and then hope they agree. You open a pipeline YAML and a
config file:

```yaml
# pipelines/doc-refine.yaml
agents: [claim-vs-source, coverage-vs-spec, cross-doc-drift, anchor-sharpen,
         example-completeness, example-organization, curate-merge]
combiner: curate-merge
```
```yaml
# configs/smoke-local.yaml   (the backend bindings — "add backends" here)
binds:
  cheap-verifier: { model: qwen2.5:0.5b, num_ctx: 8192 }
  reasoner:       { model: qwen2.5:0.5b, num_ctx: 16384 }
  # combiner:     <-- you deleted this line while trimming, or never added it
```
```bash
$ python run.py --pipeline doc-refine --config smoke-local
```

Nothing cross-checks the two before the run. The runner fans out, calls the
verifier and the five reasoners fine — seconds each, real model calls — and then
reaches the combiner:

```
  … 6 agents fanned out (18s) …
  Traceback (most recent call last):
    File "runner.py", line 88, in call_combiner
      model = binds["combiner"]
  KeyError: 'combiner'
```

Three things are wrong, all the same wrongness:

- **The gap between "configured" and "runnable" is invisible until run time.** The
  config *looks* complete; whether it *covers this pipeline's slots* is a fact
  nobody computed. You discover it by firing.
- **The failure is far from the decision.** The `KeyError` surfaces in
  `call_combiner`, pages and seconds away from the config edit that caused it —
  *after* six models were already called (and billed, if any were cloud).
- **"Same pipeline, different backend" is a copy-paste hope.** Swapping
  `--config smoke-local` for `--config quality` gives no guarantee `quality` covers
  the same slots; you re-run and re-hope. There is no *check* that a config is a
  valid backend for a pipeline — only a *run* that either survives or throws.

The pipeline and the config are two stringly-typed blobs; their *agreement* is
never a value, so it is never checked until the network is already in flight.

## §4 The chirality idea — compose is a typed selection, gated by a pure pre-flight

In scriba, "configure and run" is not editing two files and firing a script. It is:
**pick a `Pipeline` value, pick a `Config` value, and run `bind-config` over the
pair — a pure function of the values, no network — so a config that doesn't cover
the pipeline's slots is a `bind-miss` you SEE before any model is called.**

The whole shift is that **the agreement between a pipeline and a config is a value**
(`BindResult`), computed *before* the effect:

```
                pick Pipeline          pick Config
  library (S14) ────────────►  (pipe) ────────────► (config)
                                        │
                                        ▼   compose-preflight  (PURE ->, no be-chat)
                                   bind-config config (pipeline-slots pipe)
                                        │
                        ┌───────────────┴────────────────┐
                   (bind-miss missing cid)          (bind-ok bindings)
                        │                                 │
                  red pre-flight line               runview-drive  (=> be-chat)
                  — NEVER fires                      — dispatch into S15 run-view
```

**Why chirality helps — the three §3 wrongnesses become structural:**

- **"Configured vs runnable" is closed at selection.** `bind-config` is pure, so the
  moment you have the (pipe, config) pair — *before* `runview-drive` ever crosses
  the `be-chat` seam — you know whether every slot the pipeline needs is bound. The
  §3 `KeyError` has no run-time to hide in: the missing slot is a `bind-miss` value
  on screen at pick time.
- **The failure sits at the decision.** A `bind-miss` renders as a red pre-flight
  line naming the missing slots + the config id, *at the moment you picked the
  config* — not a stack trace after 18s of fan-out. And **zero models were called**:
  the pure pre-flight gates the effect, so a bad pair costs nothing.
- **The swap property is a checked guarantee.** "Same pipeline, different backend" =
  pick the same `Pipeline`, a different `Config`; `bind-config` re-checks coverage
  for the new profile. All four shipped profiles bind doc-refine's three slots
  (`{cheap-verifier, reasoner, combiner}`), so each pre-flights `bind-ok` — the swap
  property is *why* they cover the same slots, and the pre-flight *proves* it per
  pick instead of hoping.

This is the S16 form of the pure/effectful split that runs through the whole
cockpit: **`compose-preflight` is pure `->` (the check over values); `runview-drive`
is `=>` (the `be-chat` fire).** The membrane guarantees the pre-flight cannot
sneak a network call, and the dispatch only reaches the effect on `bind-ok`.

**The conservative slot set (a decision, called out).** At *selection* time the doc
being refined isn't chosen yet, so S16 cannot run the GATE (E134) to learn the
*exact* fired subset. Instead the pre-flight binds the pipeline's **declared**
slot set — every expert-id it references, plus the combiner — which is a
**superset** of any GATE outcome. If the config covers that, it covers any fired
subset; so a `bind-ok` here is *sufficient* for any run of this pipeline. (This
mirrors `plan-run`'s own runtime bind — `plan.chiral:110-112` builds
`dedup(slots-of fired ++ combiner-slot)` and returns `plan-unbound` on a
`bind-miss` — S16 just computes the conservative superset *before* the run instead
of the exact set *during* it. The runtime check still stands as a backstop.)

## §5 Chirality example (fleshed)

### §5.1 The pickable registries (values + id lists)

Config picking already has `all-profiles` (`profiles.chiral:51`). Pipeline picking
wants the analog — a one-line registry beside `doc-refine-pipeline` (currently one
entry; grows as pipelines are minted):

```
; in doc-refine.chiral (or a profile/pipelines.chiral sibling), the analog of all-profiles:
(def all-pipelines (List Pipeline)
  (cons doc-refine-pipeline nil))
```

The picker candidate lists are the ids over those registries (pure), reusing
`config-id` / `pipeline-id`:

```
(def config-ids (-> (List Config) (List Str))
  (lam (cs)
    (case cs
      (nil nil)
      ((cons c rest) (cons (config-id c) (config-ids rest))))))

(def pipeline-ids (-> (List Pipeline) (List Str))
  (lam (ps)
    (case ps
      (nil nil)
      ((cons p rest) (cons (pipeline-id p) (pipeline-ids rest))))))
```

### §5.2 The pure compose core (the acceptance-critical function)

The needed-slots of a pipeline: each declared expert-id (plus the combiner) mapped
to its slot via `expert-by-id` + `expert-slot-of`, deduped (`dedup-str`, imported
from `gate.chiral`). A dangling id contributes no slot (total). This is the
conservative superset of §4:

```
(def ids-slots (-> (List Str) (List Expert) (List Str))
  (lam (ids pool)
    (case ids
      (nil nil)
      ((cons id rest)
        (case (expert-by-id id pool)
          ((some e) (cons (expert-slot-of e) (ids-slots rest pool)))
          (none     (ids-slots rest pool)))))))            ; dangling id -> no slot

(def pipeline-slots (-> Pipeline (List Expert) (List Str))
  (lam (p pool)
    (case p
      ((pipeline id whn g o eids cmb stp yd)
        (dedup-str (ids-slots (cons cmb eids) pool))))))    ; combiner slot ++ fired slots
```

`compose-preflight` is then just `bind-config` over that slot set — **pure `->`,
no network, unit-testable on hand-built values** (the S16 sibling of `apply-edit`
/ `runview-render`). It returns E135's own `BindResult` unchanged — no new sum:

```
; PURE. bind-ok (bindings) when the config covers every slot the pipeline needs;
; bind-miss (missing-slots config-id) when it does not — a VALUE the caller cases,
; never a crash. This is the gate between "configured" and "runnable".
(def compose-preflight (-> Pipeline Config (List Expert) BindResult)
  (lam (pipe config pool)
    (bind-config config (pipeline-slots pipe pool))))
```

### §5.3 The two picker prompt kinds (minipuffer extension)

Two new `Prompt` constructors beside S14's four (`minipuffer.chiral:35-38`),
identical machinery — only the label + candidate source differ:

```
; in minipuffer.chiral's Prompt sum, beside the S14 prompt-manas-* kinds:
  (prompt-manas-pick-pipeline)   ; candidates = (pipeline-ids all-pipelines)
  (prompt-manas-pick-config)     ; candidates = (config-ids all-profiles)
```

and their prompt labels (beside `minipuffer.chiral:165-168`):

```
  (prompt-manas-pick-pipeline "Run pipeline: ")
  (prompt-manas-pick-config   "Bind config: ")
```

The candidate list is the safety rail exactly as in S14: you can only confirm an id
that resolves in the registry, so a typo'd pipeline/config name is never a
selection. `profile-by-id` / a `pipeline-by-id` (the `manas-enter` id-resolution
pattern, `command-loop.chiral:665-669`) turn the confirmed id back into the value.

### §5.4 The two-step selection state (the S13 pending pattern)

Compose is two picks then a fire — the two-step shape S13 already threads with a
small pending sum. The pipeline chosen in step 1 rides a tiny sum while step 2's
config prompt is open:

```
(data ComposePick ()
  (pick-none)                              ; no compose in progress
  (pick-pipeline-chosen (pipe Pipeline)))  ; step 1 done; awaiting the config pick
```

This mirrors S14's `Pending`/`vm-manas`-carrying-state discipline: the arity of the
loop is unchanged; the chosen pipeline is carried in the sum, not a global.

### §5.5 The one-keybind dispatch (generalize runview-fire)

`compose-fire` is `runview-fire` (`command-loop.chiral:700`) with the hardcoded pair
replaced by the picked `(pipe, config)` **and the pre-flight gate added**. On
`bind-ok` it hands off to S15's `runview-drive`; on `bind-miss` it renders the
pre-flight failure and returns to the compose state — **it never enters the
effectful driver on a miss**:

```
; the pure pre-flight GATES the effectful fire. bind-miss -> a rendered red line,
; NO be-chat. bind-ok -> runview-drive (S15), landing in vm-runview over the run.
(def compose-fire
  (=> Keymap (Puffer Str) (Maybe (Puffer Str)) (Pair I64 I64) I64 Rendering
      (List (Pair Str Mode)) (List ScribaOp) Pipeline Config Unit)
  (lam (km puf chat dims scroll old-rendering renderers ops pipe config)
    (case (compose-preflight pipe config expert-pool)        ; PURE — no network yet
      ((bind-miss missing cid)
        ; a VALUE, never a halt: paint the pre-flight failure, stay put, no be-chat.
        (let (msg (str-cat "PRE-FLIGHT  " (str-cat cid
                    (str-cat " missing: " (join-comma missing)))))
          (let (rendering (r-lines (cons (r-face "manas-bad" (r-text msg false)) nil)))
            (let (_ (render-to-ansi-full rendering dims))
              (command-loop-inner km puf chat dims scroll ""
                rendering renderers ops vm-normal pending-none)))))
      ((bind-ok bindings)
        ; covered — fire. Same tail as runview-fire: runview-drive blocks through the
        ; run, then land in vm-runview over the finished RunView.
        (let (b (backend rv-endpoint))
          (let (rv (runview-drive b rv-req (cons pipe nil) expert-pool
                     config rv-doc rv-extra dims))
            (let (rendering (runview-render rv dims scroll))
              (let (_ (render-to-ansi-full rendering dims))
                (command-loop-inner km puf chat dims scroll ""
                  rendering renderers ops (vm-runview rv) pending-none)))))))))
```

The keybind (one chord — the "one keybind from library to run-view" the slice
promises) enters the pick-pipeline prompt; confirming it stores
`(pick-pipeline-chosen pipe)` and opens the pick-config prompt; confirming *that*
resolves the config id and calls `compose-fire pipe config`. `default-keymap` stays
reachable throughout (ESC at any prompt cancels, exactly as the S14 prompts do).

## §6 Three walkthroughs (pick -> pre-flight -> dispatch)

### §6.1 The happy path: pick doc-refine, bind smoke-local, fire

```
  <compose keybind>          open the pick-pipeline prompt
  (minipuffer: "Run pipeline: ")     candidates = (pipeline-ids all-pipelines) = ["doc-refine"]
  Enter                      pick doc-refine  -> (pick-pipeline-chosen doc-refine-pipeline)
  (minipuffer: "Bind config: ")      candidates = (config-ids all-profiles)
                                     = ["smoke-local","cheap-local","quality-local","quality"]
  s m o k e … Enter          pick smoke-local -> profile-by-id -> smoke-local-config
```

- `compose-preflight doc-refine-pipeline smoke-local-config expert-pool` runs PURE:
  `pipeline-slots` = `dedup [combiner, cheap-verifier, reasoner, reasoner, reasoner,
  reasoner, reasoner, combiner]` = `{combiner, cheap-verifier, reasoner}`;
  `bind-config` finds all three bound in `smoke-local` -> **`bind-ok bindings`**.
- `compose-fire` takes the `bind-ok` arm and calls `runview-drive` — control passes
  to **S15**, which renders the GATE decision (still pure, before any `be-chat`) and
  then repaints one row per expert as each returns (§6 of S15). One keybind carried
  the chosen pair from the library all the way into the live run-view.
- **The §3-bullet-1 payoff:** "configured vs runnable" was settled *at the config
  pick* — the run started only because coverage was already proven.

### §6.2 The swap property: same pipeline, bind quality instead

```
  <compose keybind>  ->  pick doc-refine  ->  (minipuffer: "Bind config: ")
  q u a l i t y  Enter    pick quality -> quality-config
```

- `compose-preflight doc-refine-pipeline quality-config expert-pool` — the SAME
  `pipeline-slots` `{combiner, cheap-verifier, reasoner}`; `quality-config` binds
  all three (`cheap-verifier -> qwen3:1.7b`, `reasoner -> qwen3:8b`,
  `combiner -> deepseek-v4-pro`) -> **`bind-ok`**.
- Identical pipeline, identical GATE, **different backend mix** — the run S15 renders
  now shows `reasoner -> qwen3:8b` and a cloud combiner instead of the all-`0.5b`
  smoke run. **Selecting the Config IS the model-mixing** (`profiles.chiral:5-7`):
  one pipeline, four backends, each a proven-covered pick.
- **The §3-bullet-3 payoff:** the swap is a *checked* guarantee, not a copy-paste
  hope — `bind-config` re-proved coverage for `quality` before a single call.

### §6.3 The bind-miss pre-flight: a config that doesn't cover the pipeline

The four shipped profiles all cover doc-refine (that IS the swap property), so a
`bind-miss` arises from a **mismatched pair** — reachable *today* because S14 lets
you edit a config. Suppose S14 was used to leave `smoke-local` with only
`cheap-verifier` + `reasoner` bound (the combiner binding dropped), then compose:

```
  <compose keybind>  ->  pick doc-refine  ->  bind (the edited) smoke-local
```

- `compose-preflight` runs PURE: `pipeline-slots` still needs `combiner`, but the
  edited config binds only `{cheap-verifier, reasoner}` ->
  **`bind-miss (cons "combiner" nil) "smoke-local"`**.
- `compose-fire` takes the `bind-miss` arm: it paints
  ```
  PRE-FLIGHT  smoke-local missing: combiner
  ```
  as a `manas-bad` (red) line and returns to Normal — **`runview-drive` is never
  called, `be-chat` never crosses, zero models are touched.**
- **The §3-bullet-2 payoff:** this is the §3 `KeyError: 'combiner'` — but caught as
  a *value* at the config pick, before the fan-out, with the missing slot named. The
  failure sits at the decision that caused it, not 18s and six model calls later.
- **un-representable path:** there is no way to enter the run with an uncovered
  config — the only route to `runview-drive` is the `bind-ok` arm of `compose-fire`,
  and `bind-ok` *is* the proof of coverage. "Fire a pipeline its config doesn't
  cover" is not a reachable state.

## §7 Use / modify notes, honest residue, anchors

### §7.1 Use / modify notes

- **S14 is the library, reused not replaced:** S16 *picks* the `Config`/`Pipeline`
  values S14 holds and edits; the pick candidates are their ids
  (`config-id`/`pipeline-id`). The `manas-bad` face (added by S15) renders the
  pre-flight failure — no new faces.
- **S15 is the dispatch target, reused not replaced:** `compose-fire`'s `bind-ok`
  tail is `runview-fire`'s body verbatim (`command-loop.chiral:704-709`), with the
  chosen `(pipe, config)` in place of the hardcoded pair. `runview-drive`/
  `runview-render`/`vm-runview` are unchanged — S16 adds no run-view code.
- **The minipuffer is reused, extended by two kinds** exactly as S14 extended it by
  four (`minipuffer.chiral:35-38`) — same `complete`-over-candidates, candidates
  drawn from the registries.
- **`all-pipelines` is a one-line registry addition**, the analog of `all-profiles`
  (`profiles.chiral:51`) — beside `doc-refine-pipeline`. Not a new element (no E#);
  it grows as pipelines are minted. Currently one entry, so the pipeline picker is a
  1-choice list until more pipelines exist — honest, not a phantom.
- **`compose-preflight` is pure (`->`)** — unit-testable on hand-built
  `(Pipeline, Config)` pairs with zero network, exactly like S14's `apply-edit` and
  S15's `runview-render`. Only `compose-fire` is `=>` (and only its `bind-ok` arm
  reaches `be-chat`). This is the S16 pure-preflight-vs-effectful-fire split.
- **Zero engine change.** `bind-config` (E135), `run-gate` (E134), `plan-run`,
  `runview-drive` are all reused as public functions. S16 adds `pipeline-slots` +
  `compose-preflight` (scriba-side pure helpers), two prompt kinds, one dispatch
  entry.

### §7.2 Honest residue (what S16 does NOT cover)

- **Ad-hoc compose (build a NEW pipeline from the agent pool).** S16-MVP picks an
  *existing* `Pipeline` value. Constructing a *new* in-memory `Pipeline` by choosing
  agents from `expert-pool` and setting ORDER/COMBINER/STOP/GATE from scratch is
  feasible with the same constructor machinery S14 uses — but a composed pipeline
  that only lives in memory **vanishes on exit**: it cannot be re-selected from the
  library (the whole point of "the top of the cockpit"), so shipping it without
  persistence is a half-feature. **Persisting a composed value back to source needs
  E146** (the value->source serializer: `config->source`/`pipeline->source`, the
  structural reverse of E141; catalog E146 explicitly names "S16 compose (minting
  new `Config`/`Pipeline` must persist)"). **Decision: ad-hoc compose is RESIDUE,
  deferred, gated on E146** — see §7.4.
- **Persistence of the *selection* / re-run.** Even for picked (not composed) pairs,
  writing a chosen pipeline+config as a saved "run recipe" is not in scope; the pick
  is transient (like S14's in-memory edit and S15's in-memory manifest). A saved
  recipe is again an E146 write-back concern.
- **Choosing the *doc* to run on.** `compose-fire` reuses S15's crafted inputs
  (`rv-req`/`rv-doc`/`rv-extra`, `manas-runview.chiral:204-210`) so the run is
  reproducible. Picking the *target document* (a file-prompt feeding `rv-doc`) is a
  natural third pick but is input-selection, orthogonal to pipeline/config compose —
  left to the implementation (it reuses `prompt-file`, already built).
- **The GATE isn't run at selection time.** S16 pre-flights the **conservative**
  slot superset (all declared expert-ids + combiner), not the exact GATE-fired
  subset — because the doc isn't chosen at pick time (§4). This can over-report a
  `bind-miss` for a slot only a *never-fired* agent needs; that is the safe
  direction (a `bind-ok` here guarantees any run binds), and the runtime `plan-run`
  bind (`plan.chiral:110-112`) is the exact backstop. A *doc-aware* pre-flight (run
  the pure GATE first, bind only fired slots) is a refinement, not MVP.
- **Multi-pipeline registry.** With one shipped pipeline the picker is trivial; the
  compose UX (search/preview across many pipelines) only matters once more pipelines
  are minted — not an S16 concern, just a consequence of the current library size.

### §7.3 Relational anchors

- **Gate:** **S14** (`manas-mode.chiral` — the typed library values S16 picks from) +
  **S15** (`manas-runview.chiral` — the run-view S16 dispatches into) + **E134**
  (`gate.chiral` `run-gate` — the routing the pre-flight is measured against) +
  **E135** (`bind.chiral` `bind-config` — the pure pre-flight itself, `BindResult`).
  Without S14 there is nothing to pick; without S15 nothing to hand off to; without
  E135 no pre-flight value.
- **Seed:** **`runview-fire`** (`command-loop.chiral:700` — the `:run` entry S16
  generalizes) and **`manas-enter`** (`command-loop.chiral:662` — the id->value
  resolution pattern).
- **Pattern:** **S14** (the `prompt-manas-*` minipuffer extension + the
  candidate-list safety rail, `minipuffer.chiral:35`) and **S13** (the two-step
  pending sum `ComposePick` mirrors).
- **Deferred to:** **E146** (value->source serializer) — the persistence half of
  ad-hoc compose (§7.2/§7.4).
- **Feeds:** the run S16 dispatches is the `RunManifest` S15 renders and (optionally,
  E139 `be-log`) persists — S16 is the "top of the cockpit" the whole 12->14->15->16
  arc builds toward.

### §7.4 Ad-hoc-compose scope decision (RESIDUE, justified) + minting

**Decision: MVP S16 = pick-existing-pipeline + pick-config + E135 pre-flight + fire
into S15. Ad-hoc compose (build a new pipeline from the agent pool) is RESIDUE,
deferred, gated on E146.**

Justification (a gradient, not a flat cut):

1. **The slice's own gate is `S14 + S15 + E134 + E135`** — none of those four
   delivers a *persisted new pipeline*. The buildable capstone over exactly those
   gates is picking + binding + pre-flighting *existing* values. That is the honest
   MVP boundary.
2. **In-memory ad-hoc construction is feasible** (it's the same constructor
   machinery S14 uses to edit) — this is the nuance, not a hard "impossible". But
   an ad-hoc pipeline that exists only in RAM **cannot be re-selected from the
   library**, which is the defining purpose of "the top of the cockpit". You would
   compose it, run it once, and lose it.
3. **The value therefore lives in persistence, and persistence is E146** — the
   value->source serializer that writes a `Pipeline`/`Config` back to
   `doc-refine.chiral`/`profiles.chiral`. E146 is **minted** (catalog line E146;
   LEDGER `E146 | manas-moe | design`) and explicitly scopes "S16 compose (minting
   new `Config`/`Pipeline` must persist)" — so this deferral points at a real,
   cataloged dep, not a phantom.

**Minting:** nothing new to mint. E146 already exists and already names S16. The one
non-E addition S16 itself needs — `all-pipelines` (a registry `def`, the analog of
`all-profiles`) — is a trivial in-file value, not an element, so it is not a catalog
row. No follow-on E#/S# is invented here.

---

*File written: `.planning/scriba-examples/S16-manas-compose.md`*
