# S14 — manas author mode (structured config/pipeline editing)

Worked example. Pipeline stage 1 of 5 (example -> audit -> spec -> audit -> implement).

## §1 Scope

Slice 12 gave scriba a **read-only manas colorer**: a `manas` render mode that
paints `manas/orchestration/{agents,processes,configs,SCHEMA}.md` by schema —
firmness tags, field keys, headers (`init-loader.chiral` `manas-line-face` +
`render.chiral` `manas-tag`/`manas-field`/`manas-header` faces). It reads the
library as **text**. This element makes the library **editable and checked** —
and the pivot is that what you edit is **not the `.md` text** but the **typed
chirality values** the engine actually runs on:

- the four `Config` profiles (`profiles.chiral` — `smoke-local`, `cheap-local`,
  `quality-local`, `quality`), each a list of `Binding`s (SLOT -> model, num-ctx);
- the `doc-refine` `Pipeline` (`doc-refine.chiral` — GATE / ORDER / COMBINER /
  STOP) and its 7-agent `Expert` pool.

These are E133 types populated by E140 values. In the conventional world an
orchestration config is a YAML/markdown blob edited as free text — a typo in a
slot name or a stop policy is a silent runtime `KeyError`. Here the config **is a
typed value**, and the author mode offers **only schema-valid edits**: you cannot
bind a SLOT that doesn't exist, cannot reference an agent outside the pool, cannot
write a malformed STOP. **Field validation is the type checker, not a linter.**

**In scope** — editing *existing* typed values, three structured edits:

1. rebind a SLOT's model in a `Config` (smoke-local `reasoner`: `qwen2.5:0.5b` ->
   `qwen3:8b`);
2. toggle an agent in a pipeline's GATE rule (drop/add `example-organization` in
   doc-refine's `"carries examples?"` rule);
3. set a pipeline's STOP (`stop-until-dry 8` -> a different cap, or a different
   `StopPolicy` variant).

**Out of scope** (this is author, not run): firing a pipeline, streaming a
`RunManifest`, binding-then-dispatching. Those are S15 (run-view) and S16
(compose). This slice ends at a **checked, edited typed value in the buffer** —
what S16 later dispatches and S15 later renders.

## §2 Research (what already exists, on both sides)

**The typed values are already built and concrete.** E133 (`types.chiral`) is the
closed data model; E140 (`profiles.chiral`, `doc-refine.chiral`) is four `Config`
values + one `Pipeline` + a 7-`Expert` pool, all as real chirality constructors with
`find`-based lookups (`profile-by-id`, `expert-by-id`, `expert-slot-of`,
`pipeline-gate`). Author mode does not invent a data model — it **edits these**.

The pieces that make an edit schema-safe are also already values:

- `Config` = `(config id (List Binding))`; `Binding` = `(binding slot model num-ctx)`
  with **`num-ctx : I64`** (the float wall — a context length is a bounded int).
- `Order` and `StopPolicy` are **closed sums**, minted deliberately as sums rather
  than `Str` tags (types.chiral §"boundary-sums directive"): `order-fan-out |
  order-chain | order-branch`; `stop-single | stop-capped I64 | stop-until-dry I64`.
- `GateRule` = `(gate-rule condition (List Str))` — the expert-ids it fires.
- `expert-pool` is the 7 agents; `expert-by-id` resolves an id to an `Expert` or
  `none` (a miss is a **value**, "never a `KeyError`" — profiles.chiral).

**scriba's editing machinery is already built and PTY-verified:**

- the `manas` render mode + `manas-*` faces (slice 12) — the SEED colorer.
- the **minipuffer** (S8, `minipuffer.chiral`): a modal single-line prompt with
  `complete`-over-candidates. Its `Prompt` sum (`prompt-op`/`prompt-file`/
  `prompt-puffer`/`prompt-search`) is exactly the shape a "pick a model / pick an
  agent / pick a STOP" prompt extends.
- the **mode-threading pattern** (S13, `vim-mode.chiral` + command-loop): a closed
  editing-state sum threaded through the loop, dispatched mode-first, with a small
  *pending* sum for two-step operations. Author mode is the same shape with a
  different state.

So this element is **largely wiring + one typed-value renderer + one edit sum**,
not new orchestration data and not new text-editing primitives.

## §3 Conventional approach (config as text — and why it rots)

The normal way to "edit the orchestration library" is to open a YAML/markdown
file and type. A config profile is a nested map:

```yaml
smoke-local:
  binds:
    cheap-verifier: { model: qwen2.5:0.5b, num_ctx: 8192 }
    reasoner:       { model: qwen2.5:0.5b, num_ctx: 16384 }
    combiner:       { model: qwen2.5:0.5b, num_ctx: 16384 }
```

Three mis-edits, each a **silent** break:

- **Typo'd slot key** — you rename `reasoner:` to `reasonr:` (or add it under the
  wrong indent). The loader happily builds a dict with a `reasonr` key; nothing
  cross-checks it against the pipeline's required slots. At run time the runner
  does `binds["reasoner"]` and raises `KeyError: 'reasoner'` — a *runtime*
  failure, far from the edit.
- **Wrong-typed field** — `num_ctx: 16k` (a string). YAML accepts it; it breaks
  later, inside arithmetic, as a `TypeError` with no line pointing back here.
- **Malformed policy tag** — the pipeline's `STOP: loop-until-dry 8` becomes
  `loop-untl-dry 8`. The dispatcher does a which-of-N string match on the tag,
  falls through the `if/elif` chain, and either defaults silently or raises.

A stringly-typed config **cannot tell a valid edit from a broken one at edit
time**. The editor is a dumb text box; the schema lives only in the runner's head
(and in prose in `SCHEMA.md`). Every mis-edit is discovered by *running* it.

## §4 The chirality idea — the buffer holds a typed value; edits are typed transforms

The author mode's model of record is **not the buffer text** — it's a typed value
threaded through the loop (exactly as S13 threads `VimMode` and slice 11 parks the
chat buffer). A closed sum says which library object is open:

```
(data ManasDoc ()
  (doc-config   (config Config))
  (doc-pipeline (pipeline Pipeline)))
```

The manas render mode (slice 12) becomes a **value renderer**: instead of coloring
`.md` lines, it walks the `ManasDoc` and emits a `Rendering` tree — each field a
labelled, face-tagged, navigable row (reusing `r-face`/`r-lines`/`manas-field`).

Edits are a second closed sum — the *only* transformations the mode can apply:

```
(data ManasEdit ()
  (edit-rebind  (slot Str) (model Str) (num-ctx I64))  ; a Config Binding
  (edit-gate    (condition Str) (expert-id Str))       ; toggle an agent in a GATE rule
  (edit-stop    (policy StopPolicy)))                  ; replace a pipeline STOP
```

and the mode's core is one **pure** function:

```
(def apply-edit (-> ManasDoc ManasEdit ManasDoc) ...)   ; total, unit-testable, no PTY
```

**Why chirality helps — the mis-edits of §3 are un-representable:**

- `edit-rebind`'s `num-ctx` field is `I64` by the E133 type. There is no
  `ManasDoc` value carrying a string context length — `(binding "reasoner"
  "qwen3:8b" "16k")` fails to type-check (`Str` where `I64` is required). The
  YAML `TypeError` is a **compile-time** rejection.
- the slot to rebind and the agent to toggle are **chosen from the value's own
  candidate list** (the config's existing `Binding` slots; `expert-pool` ids via
  `expert-by-id`). `reasonr` is never a candidate, and a toggled agent must
  resolve in the pool — you cannot reference a slot or agent that does not exist.
  The `KeyError` is structurally impossible.
- STOP is `edit-stop` over the closed `StopPolicy` sum — you pick one of exactly
  **three** constructors. There is no `loop-untl-dry` to type; a fourth policy is
  not a value. And because chirality totality forbids an unbounded loop (doc-refine.chiral
  §STOP), `stop-until-dry`'s cap is **non-optional** — the editor cannot produce an
  uncapped orchestration loop even if the author tries.

The effectful shell (minipuffer prompt, re-render) stays thin, matching every
other scriba mode; the checking lives entirely in the types.

## §5 Chirality example (fleshed)

The author state threaded through the loop (a render-mode pairing: the `manas`
render mode from slice 12 + this editing capability):

```
(data ManasDoc ()
  (doc-config   (config Config))
  (doc-pipeline (pipeline Pipeline)))

(data ManasEdit ()
  (edit-rebind  (slot Str) (model Str) (num-ctx I64))
  (edit-gate    (condition Str) (expert-id Str))
  (edit-stop    (policy StopPolicy)))
```

Structured input reuses the minipuffer, extended with author-mode prompt kinds
whose **candidate lists come from the typed value**:

```
(data ManasPrompt ()
  (mp-model  (slot Str))   ; rebind a slot; candidates = known model strings
  (mp-expert)              ; toggle an agent; candidates = (expert-id) over expert-pool
  (mp-stop-kind)           ; pick single | capped | until-dry (the 3 constructors)
  (mp-cap))                ; enter an I64 cap (digits validated)
```

The edit resolver — pure, total, the acceptance-critical core:

```
; edit-stop just swaps the pipeline's StopPolicy field (all others carried through).
(def set-stop (-> Pipeline StopPolicy Pipeline)
  (lam (p sp)
    (case p
      ((pipeline id whn g o eids cmb stp yd)
        (pipeline id whn g o eids cmb sp yd)))))   ; stp -> sp
```

Each concrete edit is a value-to-value rewrite (before/after are real
constructors copied from the source, not prose):

**Edit 1 — rebind smoke-local's `reasoner`** (`profiles.chiral`):

```
; before
(binding "reasoner" "qwen2.5:0.5b" 16384)
; after  (edit-rebind "reasoner" "qwen3:8b" 16384)
(binding "reasoner" "qwen3:8b" 16384)
```

**Edit 2 — toggle `example-organization` out of doc-refine's GATE** (`doc-refine.chiral`):

```
; before  — the "carries examples?" rule fires two agents
(gate-rule "carries examples?"
  (cons "example-completeness" (cons "example-organization" nil)))
; after   (edit-gate "carries examples?" "example-organization")  — toggled off
(gate-rule "carries examples?"
  (cons "example-completeness" nil))
```

**Edit 3 — change doc-refine's STOP** (`doc-refine.chiral`):

```
; before
(stop-until-dry 8)
; after   (edit-stop (stop-until-dry 4))   — same variant, tighter cap
(stop-until-dry 4)
; or      (edit-stop (stop-capped 2))      — different variant entirely
(stop-capped 2)
```

The loop change is the S13 pattern exactly: `command-loop-inner` gains a
`ManasDoc` field (threaded through every recursion like `VimMode`/`Pending`);
entering author mode on a manas-mode buffer routes keys to the structured
dispatch; the minipuffer supplies constrained input; `apply-edit` transforms the
value; the value renderer re-renders. `default-keymap` stays reachable.

## §6 Three edit walkthroughs (keystroke -> typed transform -> re-render)

Each walkthrough is `keys` -> the `ManasEdit` constructed -> `apply-edit`'s
value rewrite -> what re-renders. The minipuffer's candidate list is the safety
rail: a non-candidate cannot be confirmed.

### §6.1 Rebind a SLOT's model

```
  m                     open the model-rebind prompt for the selected Binding
  (minipuffer: "Model for slot reasoner:")   candidates = known models
  q w e n 3 : 8 b       (Tab completes against the candidate list)
  Enter
```

- constructed: `(edit-rebind "reasoner" "qwen3:8b" 16384)` — `slot` is the
  **selected** binding's slot (not typed, so un-typo-able); `num-ctx` carried
  from the old binding.
- `apply-edit` rewrites that one `Binding` inside `smoke-local`'s `binds` list;
  every other binding is carried through unchanged.
- the `reasoner` row re-renders with the new model string under `manas-field`.
- **un-representable mis-edit:** there is no path that sets `reasoner`'s `num-ctx`
  to a string, and no path that binds a slot the config never had — the slot came
  from the value, and `num-ctx` is `I64`.

### §6.2 Toggle an agent in a GATE rule

```
  g                     open the gate-toggle prompt for the selected GATE rule
  (minipuffer: "Toggle agent in \"carries examples?\":")
                        candidates = (expert-id) over expert-pool (7 agents)
  Tab                   cycle to example-organization
  Enter
```

- constructed: `(edit-gate "carries examples?" "example-organization")`.
- `apply-edit` finds the rule by `condition`, and toggles the id in its
  `expert-ids` list: present -> removed, absent -> added (added only if
  `expert-by-id` resolves it in the pool).
- the GATE rule re-renders with one fewer (or one more) agent id.
- **un-representable mis-edit:** the toggle candidate list is the pool, so a
  misspelled agent (`exampl-organizaton`) is never offered and a non-pool id
  cannot be confirmed. The conventional "GATE references a dead agent" bug has no
  representation.

### §6.3 Set the pipeline STOP

```
  s                     open the stop-kind prompt
  (minipuffer: "STOP: [single | capped | until-dry]")   candidates = 3 constructors
  Enter                 pick until-dry
  (minipuffer: "cap:")  digits only
  4  Enter
```

- constructed: `(edit-stop (stop-until-dry 4))` — the kind pick chose the
  constructor; the cap prompt validated I64 digits.
- `apply-edit` calls `set-stop` (§5) — the pipeline's `stop` field is replaced,
  all seven other fields carried through by the single-ctor `case`.
- the STOP row re-renders.
- **un-representable mis-edit:** the kind pick is over the closed sum's three
  constructors — no fourth policy exists to select; and choosing `until-dry` or
  `capped` *forces* the cap prompt, so an uncapped loop cannot be produced (chirality
  totality, enforced at the type). `loop-untl-dry` is not a string here; it is a
  constructor that does or does not exist.

### §6.4 Field validation = the type checker (no separate linter)

There is no validation pass. The reason a broken edit cannot land is that the only
way to change the buffer is `apply-edit : ManasDoc -> ManasEdit -> ManasDoc`, and
its inputs are typed constructors. A `ManasDoc` that violates the schema is not a
"config that fails validation" — it is **a value that does not exist**. The
`manas-*` faces (slice 12) still color the rendered value; the checking is upstream
of rendering, in construction.

## §7 Use / modify notes, honest residue, anchors

### §7.1 Use / modify notes

- **Slice 12 is the seed, reused not replaced:** the `manas-tag`/`manas-field`/
  `manas-header` faces stay; only the renderer's *input* changes from a text line
  to a `ManasDoc` field. Colorer and author mode share the face set.
- **The minipuffer is reused, extended:** `ManasPrompt` mirrors the existing
  `Prompt` sum; `complete`-over-candidates is unchanged — the candidates just come
  from the typed value (`expert-pool` ids, the config's slots, the 3 STOP
  constructors) instead of the op/file list.
- **`apply-edit` is pure (`->`)** — unit-testable without a PTY, like S13's
  `resolve-pending`. The effectful shell is the thin minipuffer + re-render.
- **ORDER is a natural fourth edit** (`order-fan-out | order-chain | order-branch`,
  a 3-constructor pick identical in shape to STOP) but only the three edits above
  are specced for this slice; ORDER/COMBINER-reassignment are the same pattern when
  needed.

### §7.2 Honest residue (what S14 does NOT cover)

- **Persistence back to source.** The buffer holds the edited typed value; writing
  it back to `profiles.chiral` / `doc-refine.chiral` (or the `.md` library) needs a
  **value -> source serializer**. E141 is the *deserializer* (JSON/source -> value);
  the reverse pretty-printer is not built. Stage-1 shows the in-memory transform +
  re-render; write-back is deferred (a serializer, or reuse of a pretty-printer, is
  its own piece — not minted here, so not claimed as done).
- **Agent I/O contracts stay prose.** An `Expert`'s `lens`/`sees`/`returns` are
  `Str` (types.chiral: "typed I/O is target work"). Author mode can edit `slot`
  (constrained to the pool's slots) and the prose fields as free text, but
  structured editing of an agent's typed I/O contract is out of scope until those
  fields are themselves typed.
- **Creating new objects vs editing existing.** S14 edits values that already
  exist. Minting a *new* `Config`/`Pipeline`/`Expert` from scratch (naming it,
  adding bindings for slots the config never had, wiring a new agent into the pool)
  is a larger surface — the ad-hoc assembly side belongs to S16 (compose), not here.
- **Adding a slot vs rebinding one.** Rebinding an existing slot's model is in
  scope; introducing a slot the pipeline doesn't reference (or a binding for a
  missing slot) requires cross-checking the pipeline's required slots — that is
  E135 preflight (`BindResult`/`bind-miss`) territory, not author mode.
- **Shape-valid is not runnable.** Author mode checks *shape* (the slot exists, the
  policy is well-formed). Whether `qwen3:8b` is actually pulled on the worker is a
  **runtime availability** question — E135 preflight (`preflight-missing`/
  `preflight-cloud`), orthogonal to this slice.

### §7.3 Relational anchors

- **Gate:** E133 (`types.chiral` — the sums the editor edits) + E140
  (`profiles.chiral` + `doc-refine.chiral` — the concrete values). Without the typed
  values there is nothing to structure-edit.
- **Seed:** slice 12 (the Tier-1 manas colorer — faces + `manas` render mode).
- **Pattern:** slice 13 (`vim-mode.chiral` — the threaded editing-state sum +
  minipuffer dispatch this mirrors) and S8 (`minipuffer.chiral` — the constrained
  prompt).
- **Feeds S15** (run-view): the edited/selected typed value is what a run fires,
  producing the `RunManifest` S15 streams.
- **Feeds S16** (compose): S16 picks a `Pipeline`, binds a `Config` profile
  (E134 GATE + E135 config-bind), and dispatches — assembling and running the
  objects S14 makes editable.

---

*File written: `.planning/scriba-examples/S14-manas-author-mode.md`*
