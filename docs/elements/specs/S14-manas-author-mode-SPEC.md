# S14 — manas author mode (structured config/pipeline editing) — IMPLEMENTATION SPEC

> ⚑ **TRIAGE 2026-09-04 — DONE-ALREADY.** 0 of 0 steps are executable at HEAD.
> `prog/scriba/manas-mode.chiral` + `scriba-manas-test.prog` exist. Bucket and
> evidence: `records/spec-tier-triage.md`. This file was not rewritten and its
> `status:` was not changed.

Stage 3 of 5 (example → audit → spec → audit → implement). Source of truth for
the implementer. Reads with `docs/examples/S14-manas-author-mode.md`
(the worked example, audited PASS — its typed-value/constructor design is
verified correct). The example stays the rationale; this SPEC is the contract.

**Gate:** E133 (`scaffold/lib/manas/core/types.chiral` — the sums the editor
edits) + E140 (`scaffold/lib/manas/profile/{profiles,doc-refine}.chiral` — the
concrete values). Both landed. Seed: slice 12 (the manas colorer + `manas-*`
faces). Pattern: S13 (`vim-mode.chiral` — threaded editing-state sum) + S8
(`minipuffer.chiral` — constrained prompt).

**Scope:** author/edit only. Firing a pipeline, streaming a `RunManifest`, and
bind-then-dispatch are S15/S16 and are OUT (see §9 residue). S14 ends at a
**checked, edited typed value re-rendered in the terminal**.

---

## §1 Deliverable + acceptance test

**Deliverable (one sentence):** scriba gains a `vm-manas` author mode that opens
an *existing* compiled manas library value (a `Config` profile or the doc-refine
`Pipeline`) as a typed `ManasDoc`, applies one of three schema-safe typed edits
via a candidate-constrained minipuffer, and re-renders the transformed value —
the mis-edit is un-representable because the only buffer transform is
`apply-edit : (-> ManasDoc ManasEdit ManasDoc)` over closed sums.

**Acceptance test (two legs):**

1. **Unit (pure, no PTY, the acceptance-critical leg):** a new B1 test root
   `scriba/scriba-manas-test` runs the three example edits (§6.1–§6.3 of the
   example) through `apply-edit` and byte-checks the rewritten field. Exit 0 =
   all three assertions hold. Build+run:
   `chirality_blob scaffold/lib scriba/scriba-manas-test | scaffold/build/B1 > /tmp/mt.elf && chmod +x /tmp/mt.elf && /tmp/mt.elf; echo $?` → `0`.

2. **Build+PTY smoke:** `bin/scriba` builds (B1 compile, exit 0). In a PTY:
   `:manas smoke-local` enters author mode (status shows `-- MANAS --`, the
   config renders as labelled `manas-field` rows); `m` on the `reasoner` slot
   opens the model prompt with the config's own slots as candidates; picking a
   model re-renders that row; ESC returns to Normal.

The unit leg is the contract. The PTY leg is the wiring smoke (no assertions on
timing/network — there is none in S14).

---

## §2 Baseline delta — files created / modified

Grounded in the live scriba tree. Line anchors are as-read at spec time.

### 2.1 `TUI/scriba/manas-mode.chiral` — **NEW** (the pure core + the value renderer)

Mirrors `vim-mode.chiral`'s shape: a mostly-pure module owning the closed sums and
the total decision/transform functions, plus the value renderer (which is pure
`->`, producing a `Rendering`). Imports:

```
(import "prelude")
(import "render")                      ; Rendering, r-face, r-lines, r-text
(import "manas/core/types")            ; Config, Binding, GateRule, Order, StopPolicy, Pipeline, Expert
(import "manas/profile/profiles")      ; smoke/cheap/quality-local/quality Configs, all-profiles, profile-by-id, config-id
(import "manas/profile/doc-refine")    ; doc-refine-pipeline, expert-pool, expert-by-id, expert-id, pipeline-gate
```

The import path is proven reachable: the scriba resolver's libdir is
**hardcoded `scaffold/lib`** (`scaffold/lib/resolve.chiral` `compile-main` →
`(bundle (str->bytes "scaffold/lib") root)`), scriba is on it via the symlink
`scaffold/lib/scriba -> ../../TUI/scriba`, the manas library is under the same
libdir at `scaffold/lib/manas/*`, and `TUI/scriba/prelude.chiral` is a symlink to
`scaffold/lib/prelude.chiral` (identical prelude) — so the manas modules'
`(import "prelude")` and scriba's resolve to the same source. No new search-path
work. (Verified against `bin/scriba`, `bin/chirality-resolve.sh`, and the symlinks.)

Contents (defined in detail in §3 and §5):

- `ManasDoc` sum (`doc-config` / `doc-pipeline`), `ManasEdit` sum
  (`edit-rebind` / `edit-gate` / `edit-stop`).
- `apply-edit : (-> ManasDoc ManasEdit ManasDoc)` (total) + its three field
  rewriters `rebind-slot` / `toggle-gate` / `set-stop`.
- candidate extractors `config-slots` / `expert-pool-ids` / `stop-kinds`.
- `manas-doc-render : (-> ManasDoc (Pair I64 I64) I64 Rendering)` — the value
  renderer (§5).

### 2.2 `TUI/scriba/minipuffer.chiral` — **MODIFIED** (author-mode prompt kinds)

The example's `ManasPrompt` sum does not thread through `minipuffer-read`/
`minipuffer-loop`, which are typed on the existing `Prompt` sum
(`minipuffer.chiral:28`, `command-loop.chiral:193,229`). **Resolution:** extend the
existing `Prompt` sum rather than mint a parallel one, so the built-and-verified
minipuffer machinery is reused unchanged (only the label + call-site candidate
list differ). Two edits, both additive:

- `Prompt` (`minipuffer.chiral:28-32`) gains four constructors:
  `(prompt-manas-model)`, `(prompt-manas-expert)`, `(prompt-manas-stop)`,
  `(prompt-manas-cap)`.
- `mp-prompt-label` (`minipuffer.chiral:156-162`) gains four arms:
  `"Model for slot: "`, `"Toggle agent: "`, `"STOP [single|capped|until-dry]: "`,
  `"cap: "`.

Nothing else in minipuffer changes — `minipuffer-start/insert/delete/complete/
confirm/cancel/render/keymap` are label-agnostic and candidate-list-driven.

### 2.3 `TUI/scriba/vim-mode.chiral` — **MODIFIED** (the author-mode editing state)

`VimMode` gains one variant that **carries the open document** (exactly as
`vm-visual` carries `linewise` at `vim-mode.chiral:22`):

```
(data VimMode ()
  (vm-normal) (vm-insert) (vm-visual (linewise Bool)) (vm-command) (vm-chat)
  (vm-manas (doc ManasDoc)))          ; author mode — the ManasDoc rides in the mode
```

`mode-name` (`vim-mode.chiral:39-46`) gains the arm `((vm-manas d) "Manas")`.

This requires `vim-mode.chiral` to `(import "manas-mode")` for the `ManasDoc`
type. `manas-mode.chiral` does **not** import `vim-mode` (it needs none of it), so
the dependency is acyclic. Carrying `ManasDoc` inside the variant is the
deliberate deviation from the example's "command-loop-inner gains a `ManasDoc`
field" (§4/§5 of the example): it keeps `command-loop-inner`'s arity unchanged
(see §2.6) and confines the churn to the two exhaustive `case`s over `VimMode`.

### 2.4 `TUI/scriba/command-loop.chiral` — **MODIFIED** (dispatch arm + entry + resize)

Four additive touch-points; all mirror existing S13 helpers:

- **`case mode` dispatch arm** (`command-loop-inner`, `command-loop.chiral:839-844`):
  add `((vm-manas d) (manas-author-dispatch km puf chat dims scroll old-rendering renderers ops d ks))`.
- **resize arm** (`command-loop-inner` false branch, `command-loop.chiral:845-849`):
  currently re-renders via `render-puffer` unconditionally. Branch on the mode so
  author mode re-renders the value: `(case mode ((vm-manas d) …manas-doc-render…) (_ …render-puffer…))`.
  (Only fires on terminal resize; without the branch a resize repaints the parked
  Str buffer over the value.)
- **`manas-author-dispatch`** (NEW effectful helper, sibling of `insert-dispatch`
  `:766` / `visual-dispatch` `:792`): reads the pressed `KeySeq`; on `m`/`g`/`s`
  opens the matching minipuffer prompt with candidates drawn from `d`, builds the
  `ManasEdit`, applies `apply-edit`, re-renders via `manas-render-into`, recurses
  in `(vm-manas d')`; on ESC/`q` exits to `vm-normal` (the edited doc is dropped —
  no write-back, §9). Detailed in §4.
- **`manas-render-into`** (NEW effectful helper, sibling of `run-op-into` `:535`):
  `manas-doc-render` the doc → `render-to-ansi-full` → recurse in `(vm-manas d')`.
- **entry**: `vim-command-run` (`command-loop.chiral:717-720`) gains a `:manas <id>`
  arm — look the id up (`profile-by-id all-profiles` for a Config; the literal
  `doc-refine-pipeline` when id = `"doc-refine"`), wrap in a `ManasDoc`, paint it
  and recurse in `(vm-manas doc)`; unknown id → `beep-recurse`. Detailed in §4.

### 2.5 `TUI/scriba/render.chiral` — **NO CHANGE** (faces already present)

The brief names render.chiral "for the typed-value face-rendering", but the
`manas-tag` / `manas-field` / `manas-header` faces were added by slice 12 and are
already in `default-faces` (`render.chiral:114-116`). The value renderer emits
those existing face names; it lives in `manas-mode.chiral` (§5), not render.chiral,
because it takes a `ManasDoc` (not the `Str` a `RendererFn` takes — see §2.6).
**No render.chiral edit is required.** (Deviation from the brief's file list,
resolved by inspection.)

### 2.6 `TUI/scriba/init-loader.chiral` and `TUI/scriba/dispatch.chiral` — **NO CHANGE**

- **init-loader (mode registration):** the brief names init-loader "for mode
  registration/load". Verified type mismatch: the render-`Mode` registry entries
  are `RendererFn = (-> Str (Pair I64 I64) I64 Rendering)` (`render.chiral:16-17`)
  — keyed on the buffer's **Str** content; and `ScribaOp` ops are
  `(=> (Puffer Str) (Puffer Str))` (`cmd-types.chiral`). The author-mode edits
  transform a **`ManasDoc`**, fitting **neither** registry (the same reason
  find-file/save/chat are special-cased in the loop rather than registered). So
  author mode is **not** a registered render-Mode and its edits are **not**
  ScribaOps; it is a threaded editing state with bespoke dispatch, exactly as the
  example §5 states. The manas library is pulled into the blob by
  `manas-mode.chiral`'s imports (§2.1), reached transitively from `scriba-main`
  via `command-loop → vim-mode → manas-mode`. **No init-loader edit is required.**
- **dispatch.chiral (forward-declare):** `dispatch.chiral:51-52` forward-declares
  `command-loop-inner` with an exact signature. Because `ManasDoc` rides inside
  `VimMode` (§2.3) rather than as a new loop parameter, `command-loop-inner`'s
  arity is **unchanged** and this declare needs **no edit**. (This is the payoff
  of the §2.3 choice — the example's "new field" would have forced this declare
  plus ~40 recursive call sites.)

### 2.7 `TUI/scriba/scriba-manas-test.chiral` — **NEW** (the unit gate)

A B1 test root mirroring `scriba-test-b1.chiral`'s idiom (functions returning an
I64 exit code; `compile-main` runs them; exit 0 = pass). Asserts the three
example edits through `apply-edit`. Detailed in §8.

---

## §3 The pure edit core (`manas-mode.chiral`)

### 3.1 The two sums (copied from the example §5, verified against E133 field order)

```
(data ManasDoc ()
  (doc-config   (config Config))
  (doc-pipeline (pipeline Pipeline)))

(data ManasEdit ()
  (edit-rebind  (slot Str) (model Str) (num-ctx I64))   ; a Config Binding rewrite
  (edit-gate    (condition Str) (expert-id Str))        ; toggle an agent in a GATE rule
  (edit-stop    (policy StopPolicy)))                    ; replace a Pipeline STOP
```

`num-ctx` is `I64` by the E133 `Binding` type (`types.chiral:28`) — this is where
the YAML "16k-as-string" mis-edit becomes a compile-time rejection; there is no
`ManasEdit` value carrying a string context length.

### 3.2 `apply-edit` — total, the acceptance-critical function

Cases on both the `ManasDoc` and the `ManasEdit`. The cross terms (an
edit-rebind against an open Pipeline, an edit-gate/edit-stop against an open
Config) are **identity no-ops** — total and honest; the dispatch (§4) only
*offers* the applicable edit for the open doc kind, but `apply-edit` stays total
regardless:

```
(def apply-edit (-> ManasDoc ManasEdit ManasDoc)
  (lam (d e)
    (case d
      ((doc-config c)
        (case e
          ((edit-rebind slot model nctx) (doc-config (rebind-slot c slot model nctx)))
          (_ d)))                                  ; gate/stop don't apply to a Config
      ((doc-pipeline p)
        (case e
          ((edit-gate cond eid) (doc-pipeline (toggle-gate p cond eid)))
          ((edit-stop sp)       (doc-pipeline (set-stop p sp)))
          (_ d))))))                               ; rebind doesn't apply to a Pipeline
```

### 3.3 `set-stop` — swap the Pipeline's STOP (all seven other fields carried)

Verbatim from the example §5, against the E133 `Pipeline` field order
(`types.chiral:82-89`: `id when gate order expert-ids combiner stop yield-desc`):

```
(def set-stop (-> Pipeline StopPolicy Pipeline)
  (lam (p sp)
    (case p
      ((pipeline id whn g o eids cmb stp yd)
        (pipeline id whn g o eids cmb sp yd)))))    ; stp -> sp
```

### 3.4 `rebind-slot` — rewrite one Binding's model+num-ctx inside a Config

Walk the `(List Binding)`, replace the binding whose `slot` matches (str-eq),
carry the rest unchanged. num-ctx from the edit (the dispatch carries the old
binding's num-ctx forward — §4.1 — unless a cap edit is added later):

```
(def rebind-binds (-> (List Binding) Str Str I64 (List Binding))
  (lam (bs slot model nctx)
    (case bs
      (nil nil)
      ((cons b rest)
        (case b
          ((binding s m n)
            (case (str-eq s slot)
              (true  (cons (binding s model nctx) (rebind-binds rest slot model nctx)))
              (false (cons b (rebind-binds rest slot model nctx))))))))))

(def rebind-slot (-> Config Str Str I64 Config)
  (lam (c slot model nctx)
    (case c ((config id bs) (config id (rebind-binds bs slot model nctx))))))
```

### 3.5 `toggle-gate` — toggle an expert-id in a GATE rule's list

Find the `GateRule` by `condition` (str-eq); toggle `eid` in its `expert-ids`:
present → removed; absent → **added only if `expert-by-id eid expert-pool`
resolves** (a non-pool id cannot be added — the structural "GATE references a
dead agent" guard). Operates on the Pipeline's `gate` field (`(List GateRule)`).

```
(def gate-has? (-> (List Str) Str Bool) …)              ; str-eq membership
(def gate-remove (-> (List Str) Str (List Str)) …)      ; drop all str-eq matches
(def toggle-ids (-> (List Str) Str (List Str))
  (lam (ids eid)
    (case (gate-has? ids eid)
      (true  (gate-remove ids eid))
      (false (case (expert-by-id eid expert-pool)       ; add only if it resolves
               (none ids)
               ((some _) (cons eid ids)))))))
(def toggle-rules (-> (List GateRule) Str Str (List GateRule)) …)   ; find by condition, toggle
(def toggle-gate (-> Pipeline Str Str Pipeline)
  (lam (p cond eid)
    (case p ((pipeline id whn g o eids cmb stp yd)
      (pipeline id whn (toggle-rules g cond eid) o eids cmb stp yd)))))
```

### 3.6 Candidate extractors (feed the minipuffer)

```
(def config-slots     (-> Config (List Str)) …)   ; the config's own binding slots
(def expert-pool-ids  (-> (List Expert) (List Str)) …)   ; map expert-id over expert-pool
(def stop-kinds       (List Str) (cons "single" (cons "capped" (cons "until-dry" nil))))
```

`config-slots` and `expert-pool-ids` are the safety rail: a slot/agent the value
does not contain is never a candidate, so `reasonr` / `exampl-organizaton` cannot
be confirmed (example §6.1/§6.2). `stop-kinds` is the closed-sum's three
constructor tags — no fourth policy exists to type.

---

## §4 Loop threading + author-mode dispatch (`command-loop.chiral`)

### 4.1 `manas-author-dispatch` (sibling of `visual-dispatch`)

Signature (mirrors `visual-dispatch` `:792-793`, with the `ManasDoc` in hand
rather than an lw `Bool`):

```
(=> Keymap (Puffer Str) (Maybe (Puffer Str)) (Pair I64 I64) I64 Rendering
    (List (Pair Str Mode)) (List ScribaOp) ManasDoc KeySeq Unit)
```

Body: `case` the single printable char of `ks` (via a `key-motion-char`-style
one-char extractor — reuse `key-motion-char` from `vim-mode.chiral:89`, already in
scope through the import graph):

- **`"m"` (rebind a slot)** — only meaningful when `d` is `doc-config`. Prompt
  `prompt-manas-model` with candidates = a **model catalogue** (see the decision
  in §6, item D3) — actually the SLOT is chosen first: raise `prompt-manas-model`
  labelled with the target slot, candidates = the known model strings. Build
  `(edit-rebind slot model old-nctx)` where `slot` and `old-nctx` come from the
  selected `Binding` (never typed → un-typo-able; num-ctx `I64` carried forward).
  `apply-edit` → `manas-render-into`.
- **`"g"` (toggle a GATE agent)** — only meaningful when `d` is `doc-pipeline`.
  Raise `prompt-manas-expert`, candidates = `expert-pool-ids expert-pool`. Build
  `(edit-gate condition expert-id)` (`condition` = the selected rule's condition,
  not typed). `apply-edit` → `manas-render-into`.
- **`"s"` (set STOP)** — only meaningful when `d` is `doc-pipeline`. Raise
  `prompt-manas-stop` (candidates = `stop-kinds`); on `capped`/`until-dry` raise
  `prompt-manas-cap` (digit input) and parse the cap; build
  `(edit-stop (stop-single))` / `(stop-capped n)` / `(stop-until-dry n)`.
  `apply-edit` → `manas-render-into`.
- **`k-escape` / `"q"`** — `clear-mark`-free exit: recurse in `vm-normal`
  `pending-none` (the edited `d` is discarded; §9 write-back residue).
- **any other key** — `beep-recurse … (vm-manas d) pending-none`.

The minipuffer is entered exactly as find-file does (`handle-find-file` `:899` →
`minipuffer-read prompt-file nil dims`), but with the author-mode `Prompt` kind
and the candidate list from `d`. Cancel (none) returns to `(vm-manas d)`
unchanged.

**Selecting *which* binding/rule** for `m`/`g`: S14 targets the **first
applicable** binding/rule (the config's first `Binding`; the named GATE rule by
condition prompt). A cursor/selection model over rendered rows is not in S14 —
see §6 D4 (NEEDS-AUTHOR) and §9.

### 4.2 `manas-render-into` (sibling of `run-op-into`)

```
(=> Keymap (Puffer Str) (Maybe (Puffer Str)) (Pair I64 I64) I64 Rendering
    (List (Pair Str Mode)) (List ScribaOp) ManasDoc Unit)
```

`manas-doc-render d dims scroll` → `render-to-ansi-full` → `command-loop-inner …
(vm-manas d) pending-none`. (No `try-dispatch`, no `render-puffer` — the value is
the model of record.)

### 4.3 Entry: `:manas <id>` in `vim-command-run`

Add before the fallback `beep-recurse` in the `vim-command-run` chain
(`command-loop.chiral:720`): when `cmd` starts `"manas "`, take `id = (str-sub cmd
6 (str-len cmd))`; then

```
(case (str-eq id "doc-refine")
  (true  (…enter vm-manas with (doc-pipeline doc-refine-pipeline)…))
  (false (case (profile-by-id id all-profiles)
           ((some c) (…enter vm-manas with (doc-config c)…))
           (none     (beep-recurse … vm-normal pending-none)))))
```

Entering = `manas-doc-render` the doc, `render-to-ansi-full`, recurse in
`(vm-manas doc)`. This is the only S14 entry: **edit an existing compiled
value** (no deserialize, no minting — §9).

### 4.4 Status bar

`emit-status` already threads `VimMode` through `mode-name`
(`command-loop.chiral:434-449`); `(vm-manas d)` renders `-- MANAS --`
automatically via the §2.3 `mode-name` arm. `emit-cursor-goto` points at the
parked Str buffer's cursor (harmless cosmetic artifact in author mode; cursor
suppression is out of S14 scope — noted §9, not deferred to any element).

---

## §5 The value renderer (`manas-doc-render`, in `manas-mode.chiral`)

Pure `-> Rendering`, reusing the slice-12 faces. Walks the `ManasDoc` and emits
`r-lines` of face-tagged rows (the example §4: "each field a labelled,
face-tagged, navigable row"):

- `doc-config (config id binds)` → a `manas-header` row for the id, then one
  `manas-field` row per `Binding` `"slot  model  num-ctx"`.
- `doc-pipeline (pipeline id when gate order eids combiner stop yield)` → a
  `manas-header` id row; `manas-field` rows for ORDER (`order-*` tag), each GATE
  rule (`condition -> id, id`), STOP (`stop-*` tag + cap), COMBINER, YIELD.

Signature matches the pattern of `manas-renderer` (`init-loader.chiral:249`) minus
the Str input:

```
(def manas-doc-render (-> ManasDoc (Pair I64 I64) I64 Rendering) …)
```

Reuses `r-face` / `r-lines` / `r-text` (render.chiral) and the existing
`manas-tag`/`manas-field`/`manas-header` face names. It emits `StopPolicy` /
`Order` as their constructor tags (rendering the closed sum, not a free string),
so the rendered STOP row is a faithful readback of the typed value.

---

## §6 Dispositioned decisions

- **D1 — ManasPrompt vs extending `Prompt`.** **RESOLVED.** Extend the existing
  `Prompt` sum (§2.2), not a parallel `ManasPrompt`. Cited: `minipuffer-read`/
  `minipuffer-loop` are typed on `Prompt` (`command-loop.chiral:193,229`,
  `minipuffer.chiral:28`); a parallel sum cannot thread through them. The example's
  `ManasPrompt` (its §5) was illustrative; the buildable form is the four `Prompt`
  constructors. The candidate-list-from-value idea is preserved (call-site lists).

- **D2 — `ManasDoc` home: new loop param vs a `VimMode` variant.** **RESOLVED.**
  Carry it inside `(vm-manas (doc ManasDoc))` (§2.3), not as a new
  `command-loop-inner` parameter. Cited: `command-loop-inner` is threaded through
  ~40 recursive call sites and forward-declared in `dispatch.chiral:51-52`; a new
  parameter forces every one. `vm-visual` already carries payload
  (`vim-mode.chiral:22`), so the variant-carries-state pattern is established. The
  example's "new field" (its §4/§5) is superseded by this cleaner, lower-churn
  form; the deliverable is unchanged.

- **D3 — model candidate source for `m`.** **RESOLVED (scoped).** The rebind
  prompt's candidate list = the **union of model strings appearing across
  `all-profiles`** (a small `dedup` over every `Binding`'s `model` field). This is
  the honest "known models" list drawn from the value world (no network probe of
  what ollama has — that is E135 preflight, §9). A free-typed model string is
  still *representable* (it's a `Str` field), so the guarantee here is weaker than
  the slot/agent rails (which are closed over the value); this is the correct
  scope — model *availability* is a runtime question (§9), only slot/agent/stop
  *shape* is structurally closed.

- **D4 — which binding/rule is targeted.** **RESOLVED (orchestrator 2026-08-16).**
  S14 is **name-targeted**: the slot/agent/rule to edit is chosen by the minipuffer
  candidate prompt (config's `Binding` by slot name; GATE rule by its condition),
  drawn from the value's own candidate list. Row-cursor navigation (arrow-key
  selection over `manas-field` rows) is deliberately **out of S14 scope** — a future
  UX-polish enhancement, NOT deferred to any named slice (no phantom): it can be
  added later without redoing the edit core. First-applicable/name-targeted is the
  MVP author interaction and is sufficient to prove the typed-editing thesis.
  **IMPLEMENTATION NOTE (2026-08-16):** shipped as **first-applicable** (this D4
  wording said "name-targeted" but §2.2 defines only the four value-prompt kinds —
  model/expert/stop/cap — with no slot/condition *selector* prompt, and §4.1 says
  first-applicable; the wording was internally inconsistent). `m` rebinds the
  config's first `Binding`, `g` toggles the first GATE rule, `s` prompts policy+cap.
  True name-targeting needs two more minipuffer prompt kinds (a selector) — a small
  follow-on polish, out of S14 scope, not cataloged (not a phantom).

- **D5 — entry UX (`:manas <id>`).** **RESOLVED (orchestrator 2026-08-16).**
  Mechanism: a `:manas <id>` command in `vim-command-run` (§4.3) — the minimal
  buildable entry matching the existing command dispatch. S14 **ships the bare
  command** (no id-completion); the id-completion picker over `all-profiles` +
  `"doc-refine"` is optional polish, explicitly out of S14 scope, low stakes.

- **D6 — no render.chiral / init-loader.chiral / dispatch.chiral edits.**
  **RESOLVED.** See §2.5/§2.6 — grounded in the face set already existing
  (slice 12) and the `RendererFn`/`ScribaOp` type mismatch. The brief's file list
  named these; inspection shows no edit is warranted.

- **D7 — write-back on exit.** **RESOLVED (orchestrator 2026-08-16).** S14 is a
  **no-persistence checked-transform + re-render slice** — exiting author mode
  discards the edited in-memory `ManasDoc`, producing **no on-disk effect** (exactly
  the audited example's Stage-1 scope, §7.2). This is the correct sequencing: the
  typed edit core is a prerequisite for any persistent version, so it lands first.
  Write-back is formally deferred to newly-minted **E146** (value→source serializer,
  the structural reverse of E141's deserializer — cataloged + ledgered 2026-08-16,
  so this deferral names a real element per the CLAUDE.md deferral rule, not a
  phantom). **Do NOT implement write-back under S14.**

---

## §7 Commit-sized change plan

Each commit is independently B1-compilable and testable. Order respects deps
(the pure core before the dispatch that calls it; the `VimMode` variant and both
its exhaustive-`case` arms land together so the coverage checker stays satisfied).

1. **`manas-mode: ManasDoc/ManasEdit + apply-edit core + candidate extractors`**
   — new `manas-mode.chiral` (§3) importing the manas library; new
   `scriba-manas-test.chiral` (§8) asserting the three example edits. Gate: the
   test ELF exits 0.
2. **`minipuffer: author-mode Prompt kinds + labels`** — extend `Prompt` +
   `mp-prompt-label` (§2.2). Gate: blob compiles (Prompt coverage stays
   exhaustive across `key-eq`-style matches and `mp-prompt-label`).
3. **`manas-mode: value renderer (manas-doc-render)`** — the §5 renderer in
   `manas-mode.chiral`. Gate: compiles; a test can `manas-doc-render` a known doc
   and structurally check a row.
4. **`scriba: vm-manas VimMode variant + author-mode dispatch`** — atomic:
   `vim-mode.chiral` variant + `mode-name` arm (§2.3); `command-loop.chiral`
   `case mode` arm + resize-arm branch + `manas-author-dispatch` +
   `manas-render-into` (§4.1/§4.2). One commit because the variant without the
   `command-loop-inner` arm fails coverage. Gate: `bin/scriba` builds (exit 0).
5. **`scriba: :manas <id> entry + PTY smoke`** — the `vim-command-run` arm (§4.3);
   confirm `manas-mode` is pulled into the blob via the import graph. Gate:
   `bin/scriba` builds; PTY smoke (§1 leg 2).

---

## §8 Conformance / test gate

### 8.1 Unit tests (`scriba-manas-test.chiral`) — the contract

Idiom per `scriba-test-b1.chiral`: each test returns `I64` (0 = pass, 1 = fail);
`compile-main` ANDs them (returns 0 iff all pass). Build+run per §1 leg 1.

**T1 — rebind smoke-local `reasoner`** (example §6.1). Construct
`d = (doc-config smoke-local-config)` and
`e = (edit-rebind "reasoner" "qwen3:8b" 16384)`. Assert `(apply-edit d e)`'s
`reasoner` binding has model `"qwen3:8b"` and **num-ctx `16384`** (carried), and
that the other two bindings (`cheap-verifier`, `combiner`) are **unchanged**
(model still `"qwen2.5:0.5b"`). Exact assertion: extract the `reasoner` `Binding`
from the result's binds, `str-eq` its model to `"qwen3:8b"` AND `=i` its num-ctx
`16384`; `str-eq` the `cheap-verifier` model to `"qwen2.5:0.5b"`.

**T2 — toggle `example-organization` out of the `"carries examples?"` GATE**
(example §6.2). `d = (doc-pipeline doc-refine-pipeline)`,
`e = (edit-gate "carries examples?" "example-organization")`. Assert the result's
`"carries examples?"` rule `expert-ids` = `(cons "example-completeness" nil)`
(exactly one id; `example-organization` removed). Assert a **second** apply of
the same edit **re-adds** it (toggle round-trips: length back to 2, membership
restored — verifying the add path resolves through `expert-by-id`). Assert
`(edit-gate "carries examples?" "no-such-agent")` on the original is a **no-op**
(the id doesn't resolve in `expert-pool`, so it isn't added — list unchanged).

**T3 — set doc-refine STOP** (example §6.3). `d = (doc-pipeline
doc-refine-pipeline)`. `(apply-edit d (edit-stop (stop-until-dry 4)))` → the
pipeline's `stop` is `(stop-until-dry 4)` (same variant, cap 4). `(apply-edit d
(edit-stop (stop-capped 2)))` → `stop` is `(stop-capped 2)` (different variant).
Assert by `case`-ing the result's `stop` field and `=i`-ing the cap; assert the
other seven Pipeline fields are carried (e.g. `str-eq` the pipeline id to
`"doc-refine"`, ORDER still `order-fan-out`).

**T4 — cross-term totality (identity no-ops).** `(apply-edit (doc-config
smoke-local-config) (edit-stop (stop-single)))` = the input unchanged; `(apply-edit
(doc-pipeline doc-refine-pipeline) (edit-rebind "reasoner" "x" 1))` = the input
unchanged. Asserts `apply-edit` is total and the dispatch-guaranteed-inapplicable
combinations are inert.

All four are pure — **no PTY, no network, no fork** — satisfying the example's
"`apply-edit` is unit-testable without a PTY, like S13's `resolve-pending`" (§7.1).

### 8.2 Build + PTY smoke — the wiring gate

`bin/scriba` builds (B1 compile, exit 0). PTY, in order:
1. `:manas smoke-local` → `-- MANAS --`; the three bindings render as
   `manas-field` rows.
2. `m` → model prompt; the config's slots/known-models offered as candidates;
   pick `qwen3:8b`, Enter → the `reasoner` row re-renders with the new model.
3. `:manas doc-refine` → the pipeline renders (GATE/ORDER/STOP rows).
4. `g` → agent-toggle prompt (7 `expert-pool` ids as candidates); toggling
   `example-organization` re-renders the `"carries examples?"` rule with one
   fewer id.
5. `s` → STOP prompt (`single|capped|until-dry`); `until-dry` then cap `4` →
   the STOP row re-renders `stop-until-dry 4`.
6. ESC → `-- NORMAL --` (edited value discarded — §9).
7. `:manas nope` → beep, stays Normal (unknown id).

### 8.3 Self-host note

S14 touches only scriba (`TUI/scriba/*`) + imports the (unchanged) manas library
— **no compiler source changes**, so the B1-reproduces-itself self-host check
(CLAUDE.md BUILD RULE) is not triggered. Build-new → test → done.

---

## §9 Honest residue (carried verbatim-in-spirit from the example §7.2 — scope must NOT expand it)

- **No value→source serializer (write-back).** The buffer holds the edited typed
  value; writing it back to `profiles.chiral` / `doc-refine.chiral` is **out**.
  E141 is the *deserializer* (source/JSON → value); the reverse pretty-printer is
  unbuilt and **not cataloged** — a follow-on element must be minted (CLAUDE.md
  deferral rule) before write-back; **do not implement under S14**. S14 is
  in-memory transform + re-render only (§6 D7).
- **Edit-existing only.** S14 edits values that already exist in the compiled
  library. Minting a *new* `Config`/`Pipeline`/`Expert` from scratch is S16
  (compose) — **out**.
- **Structured agent-I/O editing is out.** An `Expert`'s `lens`/`sees`/`returns`
  are `Str` (`types.chiral:67` — "typed I/O is target work"); they stay prose,
  not structure-edited, until those fields are themselves typed.
- **Adding a slot ≠ rebinding one.** Rebinding an existing slot's model is in
  scope; introducing a slot the pipeline doesn't reference needs the E135
  preflight cross-check (`BindResult`/`bind-miss`, `types.chiral:42-44`) — **out**.
- **Shape-valid ≠ runnable.** S14 checks *shape* (slot exists, policy
  well-formed). Whether `qwen3:8b` is pulled on the worker is E135 preflight
  (`preflight-missing`/`preflight-cloud`, `types.chiral:106-109`) — orthogonal,
  **out**. (This is why D3's model list is honestly weaker than the slot/agent
  rails.)
- **Cursor artifact.** In author mode the terminal cursor tracks the parked Str
  buffer (`emit-cursor-goto`), not the rendered value rows — cosmetic; cursor
  suppression/row-selection is out of S14 (see §6 D4).

### Relational anchors

Gate E133 + E140. Seed slice 12 (faces + colorer). Pattern S13
(`vim-mode.chiral`) + S8 (`minipuffer.chiral`). Feeds S15 (run-view — the
edited/selected value is what a run fires) and S16 (compose — assembles + runs
the objects S14 makes editable).

---

*Spec written: `docs/elements/specs/S14-manas-author-mode-SPEC.md`. Implementation
runs follow this SPEC; the example stays the rationale.*
