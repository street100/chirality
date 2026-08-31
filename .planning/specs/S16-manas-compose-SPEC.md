# S16 — manas compose (pick a pipeline, bind a config, pre-flight, dispatch) — IMPLEMENTATION SPEC

Stage 3 of 5 (example → audit → spec → audit → implement). Source of truth for
the implementer. Reads with `.planning/scriba-examples/S16-manas-compose.md`
(the worked example, audited PASS — its glue design is verified: `bind-config`
at `bind.chiral:52` is the exact pure pre-flight, `runview-fire` at
`command-loop.chiral:700` is the exact fire it generalizes, the `bind-ok`/`bind-miss`
sum is real, ad-hoc compose is correctly deferred to E146, and it mints nothing).
The example stays the rationale; this SPEC is the contract.

**Gate:** S14 (`TUI/scriba/manas-mode.chiral` — the typed library values S16 picks:
`Config`/`Pipeline`) + S15 (`TUI/scriba/manas-runview.chiral` — `runview-drive`
`:181`/`runview-render` `:98`, the dispatch target) + E134 (`gate.chiral` `run-gate` —
the routing the pre-flight is a conservative superset of) + E135 (`bind.chiral:52`
`bind-config` — the pure pre-flight; `BindResult`). All landed. Seed: `runview-fire`
(`command-loop.chiral:700` — the `:run` fire S16 generalizes) + `manas-enter`
(`command-loop.chiral:662` — the id→value resolution pattern). Pattern: S14 (the
`prompt-manas-*` minipuffer extension + the candidate-list safety rail,
`minipuffer.chiral:35-38`; and `manas-edit-stop`'s chained two-prompt read,
`command-loop.chiral:610-621`).

**Scope:** pick an *existing* `Pipeline` + pick a `Config`, run E135's **pure**
`bind-config` pre-flight over the pair, and on `bind-ok` fire into S15's
`runview-drive`; a `bind-miss` renders as a red pre-flight line with **zero
network**. **Ad-hoc compose** (mint a new `Pipeline` from the agent pool) and any
**persistence** are OUT — deferred to **E146** (§6 D6, §9). Choosing the *target
doc* reuses `prompt-file` and is orthogonal — OUT (§9). S16 ends at **a chosen
(pipeline, config) pair, pre-flight-checked as a value, dispatched into the S15
run-view (or a red pre-flight line, never fired).**

---

## §1 Deliverable + acceptance test

**Deliverable (one sentence):** scriba gains a `:compose` command that reads two
candidate-constrained picks (a `Pipeline` from `all-pipelines`, a `Config` from
`all-profiles`), runs the **pure** `compose-preflight : (-> Pipeline Config (List
Expert) BindResult)` over the pair *before any network*, and on `bind-ok` fires
S15's `runview-drive` with the chosen pair (landing in the existing `vm-runview`
mode) — while a `bind-miss` paints a `manas-bad` pre-flight line naming the missing
slots + config id and returns to Normal, **never crossing `be-chat`** — all reusing
E135's `bind-config`, S15's `runview-drive`/`runview-render`, and S14's minipuffer
extension pattern with **zero engine change and no new `VimMode`**.

**Acceptance test (two legs):**

1. **Unit (pure, no PTY, no network — the acceptance-critical leg):** a new B1 test
   sample `scaffold/tests/samples/s16_compose.chiral` (exit-code idiom, mirroring
   `scaffold/tests/samples/e135_bind.chiral`) drives `compose-preflight` over the
   shipped library values and byte-checks the `BindResult`:
   - `pipeline-slots doc-refine-pipeline expert-pool` = the 3-slot conservative
     superset `{combiner, cheap-verifier, reasoner}` (length 3, all three members);
   - `compose-preflight doc-refine-pipeline smoke-local-config expert-pool` →
     `bind-ok` with 3 bindings (a covering config — the smoke-local proof);
   - `compose-preflight doc-refine-pipeline verifier-only expert-pool` → `bind-miss`
     carrying `reasoner` **and** `combiner` in `missing-slots` + `config-id`
     `"verifier-only"` (a config that binds only `cheap-verifier`).

   Exit 0 = all assertions hold:
   `chirality_blob scaffold/lib scaffold/tests/samples/s16_compose | scaffold/build/B1 > /tmp/s16.elf && chmod +x /tmp/s16.elf && /tmp/s16.elf; echo $?` → `0`.

2. **Build + PTY smoke (the wiring gate):** `bin/scriba` builds (B1 compile, exit 0).
   In a PTY, mesh reachable (`100.64.0.5:11434`):
   - `:compose` → pick-pipeline minipuffer (`"Run pipeline: "`, candidates =
     `["doc-refine"]`); Enter → pick-config minipuffer (`"Bind config: "`,
     candidates = `["smoke-local","cheap-local","quality-local","quality"]`); pick
     `smoke-local` → pre-flight passes → the S15 run-view renders (GATE line, then
     one row per expert), ESC → Normal.
   - **negative:** with S14 used to drop `smoke-local`'s `combiner` binding (or any
     non-covering config), `:compose` → doc-refine → that config → a red
     `PRE-FLIGHT  <cid> missing: combiner` line, **no run**, stays Normal.

The unit leg is the contract (it proves the pre-flight is a faithful pure value with
no network). The PTY leg is the wiring/liveness smoke.

---

## §2 Baseline delta — files created / modified

Grounded in the live tree. Line anchors are as-read at spec time. **S16 is almost
pure glue** — every effectful piece it needs is already a shipped public def.

### 2.1 `scaffold/lib/manas/pipeline/compose.chiral` — **NEW** (the pure compose core + the pipeline registry)

The pure core lives in the **manas library**, not in scriba, because
`pipeline-slots` is genuinely a library concern — it is the *conservative
selection-time* analog of `plan-run`'s *runtime* bind (`plan.chiral:110`:
`dedup-str (append Str (slots-of fired) (cons (exp-slot comb) nil))`), and
`compose-preflight` is pure glue over E135's `bind-config`. A library home keeps it
unit-testable as a `scaffold/tests/samples/` sample with **no scriba, no PTY**
(exactly like `e135_bind.chiral`) and keeps scriba thin. (Deviation from the slice
row's `manas-mode.chiral` file list — RESOLVED §6 D2.)

Imports (all shipped):

```
(import "prelude")                 ; Str, Bool, List, Pair, Maybe, str-eq, cons, nil, some, none
(import "manas/core/types")        ; Pipeline, Expert, Config, BindResult
(import "manas/core/bind")         ; bind-config
(import "manas/core/gate")         ; dedup-str
(import "manas/core/match")        ; pipeline-id
(import "manas/profile/profiles")  ; all-profiles, config-id
(import "manas/profile/doc-refine"); doc-refine-pipeline, expert-pool, expert-by-id, expert-slot-of
```

Import reachability is the E135/E140-proven path: the manas library sits under the
resolver libdir `scaffold/lib/manas/*`; `compose.chiral` is a sibling of `plan.chiral`
under `manas/pipeline/`. No new search-path work.

Contents (defined in §3): `ids-slots`, `pipeline-slots`, `compose-preflight`,
`all-pipelines`, `pipeline-by-id`, `pipeline-ids`, `config-ids`.

### 2.2 `TUI/scriba/minipuffer.chiral` — **MODIFIED** (two compose prompt kinds)

Extend the existing `Prompt` sum (`minipuffer.chiral:28-38`) with two constructors
beside S14's four, and add their two `mp-prompt-label` arms (`minipuffer.chiral:162-172`)
— the identical extension S14 made, reusing the built-and-verified
`minipuffer-read`/`complete`-over-candidates machinery unchanged:

```
; in the Prompt sum, beside prompt-manas-cap (:38):
  (prompt-manas-pick-pipeline)   ; :compose step 1 — candidates = (pipeline-ids all-pipelines)
  (prompt-manas-pick-config)     ; :compose step 2 — candidates = (config-ids all-profiles)

; in mp-prompt-label, beside prompt-manas-cap (:172):
  (prompt-manas-pick-pipeline "Run pipeline: ")
  (prompt-manas-pick-config   "Bind config: ")
```

`mp-prompt-label` is an **exhaustive `case` over `Prompt`**, so the two constructors
and their two label arms must land in the **same commit** (else coverage fails) —
this is S16's only coverage-atomicity constraint (§6 D3, §7). Nothing else in
minipuffer changes.

### 2.3 `TUI/scriba/command-loop.chiral` — **MODIFIED** (the `:compose` entry + two effectful defs)

Three additive touch-points, all mirroring the shipped `manas-enter`/`runview-fire`
wiring:

- **entry**: the `vim-command-run` chain (`command-loop.chiral:873`, the
  `str-eq cmd "…"` cascade that already dispatches `"run"` → `runview-fire`) gains a
  `(str-eq cmd "compose")` arm → `compose-enter`, before the `beep-recurse`
  fallthrough.
- **`compose-enter`** (NEW effectful helper, sibling of `manas-enter` `:662`): reads
  the two picks via chained `minipuffer-read`, resolves each id to its value, and
  calls `compose-fire`. Detailed §4.1.
- **`compose-fire`** (NEW effectful helper, sibling of `runview-fire` `:700`): runs
  the **pure** `compose-preflight` gate, then either paints a `manas-bad` pre-flight
  line (→ `vm-normal`) or fires `runview-drive` (→ `vm-runview`). Detailed §4.2.

`compose-enter` and `compose-fire` are new top-level `def`s ordered **before**
`vim-command-run` (like `runview-fire`), so the entry arm can reference them. One new
import: `(import "manas/pipeline/compose")` for `compose-preflight`/`all-pipelines`/
`pipeline-by-id`/`pipeline-ids`/`config-ids`. `join-comma` (S14, `manas-mode.chiral`),
`profile-by-id`/`all-profiles` (`profiles.chiral`), `backend`/`rv-endpoint`/`rv-req`/
`rv-doc`/`rv-extra`/`runview-drive`/`runview-render` (S15, `manas-runview.chiral`) are
already in scope (used by `manas-enter`/`runview-fire`), and the `manas-bad` face is
already in `default-faces` (added by S15) — **no render.chiral edit**.

### 2.4 `scaffold/tests/samples/s16_compose.chiral` — **NEW** (the unit gate)

An exit-code test sample mirroring `e135_bind.chiral` (`compile-main (=> I64 I64)`,
returns 0 iff all assertions hold). Imports `manas/pipeline/compose` +
`manas/core/types` + `manas/profile/{profiles,doc-refine}` and asserts the three §1
leg-1 properties. **No PTY, no network, no fork.** Detailed §8.1.

### 2.5 No other file changes

- **`TUI/scriba/vim-mode.chiral` — NO CHANGE.** S16 adds **no new `VimMode` variant**:
  the `bind-ok` fire lands in S15's existing `vm-runview` (the finished-run mode) and
  the `bind-miss` line lands in `vm-normal`. The two picks are read by chained
  synchronous `minipuffer-read` inside `compose-enter` (like `manas-edit-stop`'s
  chained STOP+cap prompts, `command-loop.chiral:610-621`), so **no editing-state sum
  and no loop-arity change** (RESOLVED §6 D1). This is why S16 has **no
  coverage-atomic mode commit** (contrast S14 commit-4 / S15 commit-3): no `VimMode`
  variant is added, so `mode-name` and the two `case mode` arms (dispatch `:999`,
  resize `:1006`) are untouched.
- **`TUI/scriba/keymap.chiral` — NO CHANGE.** The slice row names `keymap.chiral` for a
  "one keybind". S16 ships the buildable entry consistent with the live dispatch: a
  `:compose` **command** (the `:run`/`:manas` sibling), not a new keymap chord —
  exactly as S14 D5 shipped `:manas <id>` as a bare command. A dedicated chord is
  optional UX polish, out of S16 (§6 D5). No keymap edit warranted.
- **`init-loader.chiral`/`dispatch.chiral` — NO CHANGE.** Firing is not a `RendererFn`
  or a `ScribaOp` (the same type-mismatch reason `runview-fire`/`manas-enter` are
  special-cased); no new loop param means the `command-loop-inner` forward-declare in
  `dispatch.chiral` is untouched. The compose core is pulled into the scriba blob
  transitively (`command-loop → compose → {bind, doc-refine, profiles}`, already
  reached via `manas-enter`/`runview-fire`).

---

## §3 The pure compose core (`compose.chiral`)

### 3.1 `ids-slots` / `pipeline-slots` — the conservative slot superset (pure, total)

Map each declared id (combiner ++ fired expert-ids) to the slot it binds via
`expert-by-id` + `expert-slot-of`, deduped. A dangling id contributes no slot
(total). This is the **conservative superset** of any GATE outcome (§5): the doc
isn't chosen at pick time, so S16 binds every *declared* slot, not the exact fired
subset — a `bind-ok` here is *sufficient* for any run of this pipeline (the runtime
`plan-run` bind, `plan.chiral:110`, is the exact backstop).

```
; each id -> its slot (dangling id -> dropped). Explicit structural recursion, not
; `map` — map-list does not lower in an isolated leaf blob on this branch (bind.chiral
; :49 / E134 finding), so the core mirrors bind-config's hand-written form.
(def ids-slots (-> (List Str) (List Expert) (List Str))
  (lam (ids pool)
    (case ids
      (nil nil)
      ((cons id rest)
        (case (expert-by-id id pool)
          ((some e) (cons (expert-slot-of e) (ids-slots rest pool)))
          (none     (ids-slots rest pool)))))))

; the pipeline's needed slots: combiner ++ every declared expert-id, deduped.
(def pipeline-slots (-> Pipeline (List Expert) (List Str))
  (lam (p pool)
    (case p
      ((pipeline id whn g o eids cmb stp yd)
        (dedup-str (ids-slots (cons cmb eids) pool))))))
```

Field order is the E133 `Pipeline` ctor `(pipeline id when gate order expert-ids
combiner stop yield-desc)` (verified against `doc-refine.chiral:124` and S14's
`set-stop`); `cmb` is the combiner id `Str`, `eids` the `(List Str)` of declared
expert-ids. For `doc-refine-pipeline` this yields `{combiner, cheap-verifier,
reasoner}` (curate-merge→combiner, claim-vs-source→cheap-verifier, the five
reasoning lenses→reasoner, deduped — 3 slots).

### 3.2 `compose-preflight` — the pure gate (returns E135's `BindResult` unchanged)

`bind-config` over the conservative slot set. **Pure `->`, no network,
unit-testable on the shipped values** (the S16 sibling of S14's `apply-edit` and
S15's `runview-render`). No new sum — it returns E135's own `BindResult`
(`types.chiral:42-44`):

```
; PURE. bind-ok (bindings) when the config covers every slot the pipeline needs;
; bind-miss (missing-slots config-id) when it does not — a VALUE the caller cases,
; never a crash. The gate between "configured" and "runnable", computed BEFORE the
; effect (the membrane proves bind-config crosses no be-chat).
(def compose-preflight (-> Pipeline Config (List Expert) BindResult)
  (lam (pipe config pool)
    (bind-config config (pipeline-slots pipe pool))))
```

### 3.3 The pickable registries (values + candidate-id lists, pure)

Config picking already has `all-profiles` (`profiles.chiral:51`) + `config-id`
(`:15`). Pipeline picking wants the analog registry beside the one shipped pipeline
— a **one-line `def`, not an element** (grows as pipelines are minted; currently a
1-choice picker, honest not a phantom):

```
(def all-pipelines (List Pipeline)
  (cons doc-refine-pipeline nil))

; id -> value, the analog of profile-by-id (:60). A miss is a VALUE.
(def pipeline-by-id (-> Str (List Pipeline) (Maybe Pipeline))
  (lam (want ps)
    (case ps
      (nil none)
      ((cons p rest)
        (case (str-eq (pipeline-id p) want)
          (true  (some p))
          (false (pipeline-by-id want rest)))))))

; candidate-id lists for the two minipuffer prompts (explicit recursion, see §3.1).
(def pipeline-ids (-> (List Pipeline) (List Str))
  (lam (ps) (case ps (nil nil) ((cons p rest) (cons (pipeline-id p) (pipeline-ids rest))))))
(def config-ids (-> (List Config) (List Str))
  (lam (cs) (case cs (nil nil) ((cons c rest) (cons (config-id c) (config-ids rest))))))
```

`pipeline-id` is E136 (`match.chiral:23`); `config-id` is `profiles.chiral:15`. The
candidate lists are the safety rail exactly as in S14: a typo'd pipeline/config name
is never confirmable, and `pipeline-by-id`/`profile-by-id` turn a confirmed id back
into the value (the `manas-enter` id→value pattern, `command-loop.chiral:665-669`).

---

## §4 The dispatch threading (`command-loop.chiral`)

### 4.1 `compose-enter` — the two-step pick (`=>`, chained `minipuffer-read`)

`minipuffer-read` is a blocking `=>` returning `(Maybe Str)` (`command-loop.chiral:229`),
so the two picks **chain synchronously in one def** — no pending sum, no new mode
(§6 D1), exactly as `manas-edit-stop` chains its STOP-kind then cap prompts
(`command-loop.chiral:610-621`). ESC/cancel at either prompt (`none`) returns to
Normal; an id that doesn't resolve beeps (defensive — the candidate rail already
prevents it):

```
(def compose-enter
  (=> Keymap (Puffer Str) (Maybe (Puffer Str)) (Pair I64 I64) I64 Rendering
      (List (Pair Str Mode)) (List ScribaOp) Unit)
  (lam (km puf chat dims scroll old-rendering renderers ops)
    (case (minipuffer-read prompt-manas-pick-pipeline (pipeline-ids all-pipelines) dims)
      (none (beep-recurse km puf chat dims scroll old-rendering renderers ops vm-normal pending-none))
      ((some pid)
        (case (pipeline-by-id pid all-pipelines)
          (none (beep-recurse km puf chat dims scroll old-rendering renderers ops vm-normal pending-none))
          ((some pipe)
            (case (minipuffer-read prompt-manas-pick-config (config-ids all-profiles) dims)
              (none (beep-recurse km puf chat dims scroll old-rendering renderers ops vm-normal pending-none))
              ((some cid)
                (case (profile-by-id cid all-profiles)
                  (none (beep-recurse km puf chat dims scroll old-rendering renderers ops vm-normal pending-none))
                  ((some config)
                    (compose-fire km puf chat dims scroll old-rendering renderers ops pipe config)))))))))))
```

### 4.2 `compose-fire` — the pure gate GATES the effectful fire (`=>`)

`runview-fire`'s body (`command-loop.chiral:700-709`) with the hardcoded
`(cons doc-refine-pipeline nil)` + `smoke-local-config` replaced by the chosen
`(pipe, config)` **and the pre-flight added**. On `bind-miss`: paint a red line, no
`be-chat`, back to Normal. On `bind-ok`: the `runview-fire` tail verbatim, landing in
`vm-runview` over the finished run:

```
(def compose-fire
  (=> Keymap (Puffer Str) (Maybe (Puffer Str)) (Pair I64 I64) I64 Rendering
      (List (Pair Str Mode)) (List ScribaOp) Pipeline Config Unit)
  (lam (km puf chat dims scroll old-rendering renderers ops pipe config)
    (case (compose-preflight pipe config expert-pool)          ; PURE — no network yet
      ((bind-miss missing cid)
        ; a VALUE, never a halt: paint the pre-flight failure, stay put, no be-chat.
        (let (msg (str-cat "PRE-FLIGHT  " (str-cat cid (str-cat " missing: " (join-comma missing)))))
          (let (rendering (r-lines (cons (r-face "manas-bad" (r-text msg false)) nil)))
            (let (_ (render-to-ansi-full rendering dims))
              (command-loop-inner km puf chat dims scroll ""
                rendering renderers ops vm-normal pending-none)))))
      ((bind-ok bindings)
        ; covered — fire. runview-fire's tail with the chosen pair.
        (let (b (backend rv-endpoint))
          (let (rv (runview-drive b rv-req (cons pipe nil) expert-pool
                     config rv-doc rv-extra dims))            ; blocks through the run
            (let (rendering (runview-render rv dims scroll))
              (let (_ (render-to-ansi-full rendering dims))
                (command-loop-inner km puf chat dims scroll ""
                  rendering renderers ops (vm-runview rv) pending-none)))))))))
```

- `runview-drive`'s signature (`manas-runview.chiral:181`) is
  `(=> Backend Str (List Pipeline) (List Expert) Config Str (List (Pair Str Str))
  (Pair I64 I64) RunView)` — `pipe` replaces `doc-refine-pipeline`, `config` replaces
  `smoke-local-config`; the pool (`expert-pool`), request (`rv-req`), doc (`rv-doc`),
  and extra (`rv-extra`) stay the S15 crafted inputs (choosing the doc is deferred,
  §9). All are already in scope in `command-loop.chiral` (used by `runview-fire`).
- `join-comma` (S14, `manas-mode.chiral`), `r-lines`/`r-face`/`r-text`/
  `render-to-ansi-full` (render), and the `manas-bad` face (S15) are all reused —
  **no new render code, no new face**.

### 4.3 Entry: `:compose` in `vim-command-run`

Insert into the `vim-command-run` `str-eq` cascade (`command-loop.chiral:873`), beside
the `(str-eq cmd "run") (true (runview-fire …))` arm and before the `beep-recurse`
fallthrough:

```
(case (str-eq cmd "compose")
  (true  (compose-enter km puf chat dims scroll old-rendering renderers ops))
  (false … existing "run" arm / beep-recurse …))
```

`emit-status` renders `-- NORMAL --` before `:compose` (a command runs from Command
mode and returns to Normal or `vm-runview`); no new `mode-name` arm (§2.5).

---

## §5 The effect-membrane story (why S16 is honest — pure pre-flight vs effectful fire)

This is the S16 form of the pure/effectful split that runs through the whole cockpit
(S14-pure `apply-edit`, S15-pure `runview-render`):

- **`compose-preflight` is pure `->`.** `bind-config` (`bind.chiral:52`) is `->`, so
  the membrane *proves* the pre-flight crosses no network. The moment you have the
  (pipe, config) pair — *before* `runview-drive` ever reaches `be-chat` — you know
  whether every slot the pipeline needs is bound. A `bind-miss` is a value on screen
  at pick time; the conventional `KeyError: 'combiner'` (example §3) has no run-time
  to hide in.
- **Only `compose-fire`'s `bind-ok` arm is `=>`.** The `bind-miss` arm paints and
  returns with **zero `be-chat`** — a bad pair costs nothing. The only route to
  `runview-drive` is the `bind-ok` arm, and `bind-ok` *is* the proof of coverage, so
  "fire a pipeline its config doesn't cover" is un-representable.
- **The conservative slot set (a decision, §3.1).** At *selection* time the doc isn't
  chosen, so S16 cannot run the GATE (E134) to learn the exact fired subset; it binds
  the pipeline's **declared** slots — a superset of any GATE outcome. If the config
  covers that, it covers any fired subset (a `bind-ok` here is *sufficient*). This
  over-reports a `bind-miss` only for a slot a *never-fired* agent needs — the safe
  direction — and the runtime `plan-run` bind (`plan.chiral:110`, `plan-unbound`) is
  the exact backstop. A doc-aware pre-flight (run the pure GATE first, bind only fired
  slots) is a refinement, not MVP (§9).
- **The swap property is a checked guarantee.** All four shipped profiles bind
  doc-refine's `{cheap-verifier, reasoner, combiner}`, so each pre-flights `bind-ok` —
  same pipeline, different backend mix, coverage re-proved per pick, not copy-paste
  hoped.

---

## §6 Dispositioned decisions

- **D1 — no `ComposePick` sum, no new `VimMode`; two picks chain in one def.**
  **RESOLVED.** The example §5.4 proposes a `ComposePick` two-step pending sum
  (mirroring S13's `Pending`) and §5.5's `compose-fire` threads loop state. But the
  live `minipuffer-read` is a **blocking `=>` returning `(Maybe Str)`**
  (`command-loop.chiral:229`), and `manas-edit-stop` already chains **two** synchronous
  `minipuffer-read`s (STOP kind, then cap) in one effectful def with no pending sum
  (`command-loop.chiral:610-621`). So compose's two picks chain identically in one
  `compose-enter`; the `bind-ok` fire lands in S15's existing `vm-runview`, the
  `bind-miss` line in `vm-normal`. **No editing-state sum, no new `VimMode`, no
  loop-arity change.** This is the S16 analog of S14 D1/D2 (the example's illustrative
  state-threading form yields to the buildable chained-read form; deliverable
  unchanged). CONFIRMED against `minipuffer-read`'s signature and `manas-edit-stop`.

- **D2 — pure core home: manas library (`compose.chiral`), not scriba
  (`manas-mode.chiral`).** **RESOLVED.** The slice row names `manas-mode.chiral`, but
  `pipeline-slots` is the conservative selection-time analog of `plan-run`'s runtime
  bind (`plan.chiral:110`) and `compose-preflight` is pure glue over `bind-config` —
  both are library concerns. A library home (`scaffold/lib/manas/pipeline/compose.chiral`,
  sibling of `plan.chiral`) makes them unit-testable as a `scaffold/tests/samples/`
  sample with no scriba/PTY (mirroring `e135_bind.chiral`, exactly the test the task
  directs) and keeps scriba thin. Deviation from the slice-row file list, resolved by
  inspection — the analog of S14 D6 / S15 D2 (the example/row's illustrative home
  yields to the right one). CONFIRMED: `bind-config`/`dedup-str`/`pipeline-id`/
  `expert-by-id`/`expert-slot-of`/`all-profiles` are all reachable public defs.

- **D3 — the only coverage-atomic constraint is the `Prompt` extension.**
  **RESOLVED.** Because S16 adds no `VimMode` variant (D1), the S14/S15 "mode variant
  + all its exhaustive `case` arms land together" constraint **does not apply**. The
  one coverage constraint is the `Prompt` sum: `mp-prompt-label` is an exhaustive
  `case` over `Prompt` (`minipuffer.chiral:162`), so the two new constructors and their
  two label arms land in the **same commit** (commit 2, §7).

- **D4 — the pre-flight binds the conservative declared-slot superset.**
  **RESOLVED (scoped).** `pipeline-slots` binds the combiner ++ every declared
  expert-id's slot (§3.1), a superset of any GATE-fired subset, because the doc isn't
  chosen at pick time (§5). A `bind-ok` is therefore *sufficient* for any run; the
  over-report direction is safe; `plan-run`'s runtime bind (`plan.chiral:110`) is the
  backstop. Doc-aware pre-flight (pure GATE first) is a refinement, out of S16 (§9).

- **D5 — entry UX: `:compose` command, not a keymap chord.** **RESOLVED (scoped).**
  Mechanism: a `:compose` command in `vim-command-run` (§4.3) — the minimal buildable
  entry matching the live dispatch (`:run`/`:manas` siblings), exactly as S14 D5
  shipped `:manas <id>` as a bare command. The slice row's `keymap.chiral` "one
  keybind" is aspirational UX polish, explicitly out of S16, low stakes — no keymap
  edit (§2.5).

- **D6 — ad-hoc compose (mint a new pipeline) is RESIDUE, deferred to E146.**
  **RESOLVED.** MVP S16 picks *existing* `Pipeline`/`Config` values (the buildable
  capstone over the S14 + S15 + E134 + E135 gate — none of which delivers a persisted
  new pipeline). In-memory ad-hoc construction is feasible (same constructor machinery
  S14 edits with), but an ad-hoc pipeline that only lives in RAM **vanishes on exit** —
  it cannot be re-selected from the library (the defining purpose of "the top of the
  cockpit"), so shipping it without persistence is a half-feature. The value lives in
  persistence, and persistence is **E146** (the value→source serializer;
  `SELF-IMPLEMENT-CATALOG.md:411` + `LEDGER.md:129`, which **explicitly name "S16
  compose (minting new Config/Pipeline must persist)"**) — CONFIRMED minted, so this
  deferral names a real cataloged dep per the CLAUDE.md deferral rule, not a phantom.
  **Do NOT implement ad-hoc compose or write-back under S16.**

- **D7 — `all-pipelines` is a `def`, not a new element.** **RESOLVED.** The one non-E
  addition S16 needs is a one-line registry (the analog of `all-profiles`
  `profiles.chiral:51`) — a trivial in-file value, not a catalog row. Currently one
  entry, so the pipeline picker is a 1-choice list until more pipelines are minted
  (honest, not a phantom). **Nothing new to mint** (E146 already exists and already
  names S16).

- **NEEDS-AUTHOR:** none. Every primitive S16 relies on is a verified public def
  (`bind-config` `bind.chiral:52`, `all-profiles`/`config-id`/`profile-by-id`
  `profiles.chiral:51/15/60`, `doc-refine-pipeline`/`expert-pool`/`expert-by-id`/
  `expert-slot-of` `doc-refine.chiral:124/88/100/18`, `pipeline-id` `match.chiral:23`,
  `dedup-str` `gate.chiral:104`, `runview-drive`/`runview-render` `manas-runview.chiral:181/98`,
  `runview-fire`/`manas-enter`/`minipuffer-read` `command-loop.chiral:700/662/229`) and
  every deviation (D1/D2) is mechanically buildable and resolved above.

---

## §7 Commit-sized change plan

Each commit is independently B1-compilable and testable. Order respects deps (the
pure library core before the scriba dispatch that calls it; the `Prompt` extension +
its labels together for coverage). **No coverage-atomic mode commit** — S16 adds no
`VimMode` (§6 D1/D3).

1. **`manas: compose core (compose.chiral) — all-pipelines + pipeline-slots + compose-preflight + unit test`**
   — new `scaffold/lib/manas/pipeline/compose.chiral` with §3's `ids-slots`/
   `pipeline-slots`/`compose-preflight`/`all-pipelines`/`pipeline-by-id`/
   `pipeline-ids`/`config-ids` (pure imports only); new
   `scaffold/tests/samples/s16_compose.chiral` (§8.1). **Gate:** the test ELF exits 0
   (§1 leg 1). Does not touch scriba, so `bin/scriba` is unchanged.

2. **`scriba: compose pickers (pick-pipeline + pick-config Prompt kinds + labels)`**
   — extend the `Prompt` sum (2 ctors) + `mp-prompt-label` (2 arms) in
   `minipuffer.chiral` (§2.2). **One commit** because `mp-prompt-label`'s exhaustive
   `case` over `Prompt` requires both label arms with the new ctors (§6 D3). **Gate:**
   blob compiles (`Prompt` coverage stays exhaustive).

3. **`scriba: :compose dispatch (compose-enter + compose-fire, gate on bind-ok) + PTY smoke`**
   — `command-loop.chiral`: `(import "manas/pipeline/compose")`, `compose-enter` +
   `compose-fire` (§4.1/§4.2), the `:compose` arm in `vim-command-run` (§4.3). This
   pulls the compose core into the scriba blob (already effectful via
   `runview-fire`), so `bin/scriba` grows here. **Gate:** `bin/scriba` builds (exit 0);
   PTY smoke (§8.2).

---

## §8 Conformance / test gate

### 8.1 Unit test (`scaffold/tests/samples/s16_compose.chiral`) — the contract

Idiom per `e135_bind.chiral`: `compile-main (=> I64 I64)` returns 0 iff all assertions
hold, else 1. Build+run per §1 leg 1. All pure — **no PTY, no network, no fork**.

**T1 — `pipeline-slots` is the 3-slot conservative superset.** Assert
`(pipeline-slots doc-refine-pipeline expert-pool)` has length 3 and contains
`"combiner"`, `"cheap-verifier"`, and `"reasoner"` (membership, order-agnostic — the
dedup of curate-merge→combiner ++ the 7 declared ids' slots). Proves the
declared-superset computation (§3.1).

**T2 — a covering config pre-flights `bind-ok`.** Assert
`(compose-preflight doc-refine-pipeline smoke-local-config expert-pool)` is
`bind-ok` with 3 bindings (`case` the `BindResult`; `bind-miss` → fail; `bind-ok bs`
→ `=i (len bs) 3`). Proves the smoke-local proof profile covers doc-refine's slots
via the pure pre-flight — with no network (the §5 payoff: coverage settled before any
`be-chat`).

**T3 — a non-covering config pre-flights `bind-miss` with the missing slots + id.**
Build `verifier-only = (config "verifier-only" (cons (binding "cheap-verifier"
"qwen2.5:0.5b" 8192) nil))`. Assert
`(compose-preflight doc-refine-pipeline verifier-only expert-pool)` is `bind-miss`
whose `missing-slots` contains **both** `"reasoner"` and `"combiner"` (membership)
and whose `config-id` `str-eq`s `"verifier-only"` (`bind-ok` → fail). Proves the
§3-example `KeyError` is caught as a value at pick time, naming which slots + the
config, before any fan-out — the un-representable-bad-fire guarantee (§5).

### 8.2 Build + PTY smoke — the wiring gate

`bin/scriba` builds (B1 compile, exit 0). PTY, mesh reachable, in order:
1. `:compose` → `"Run pipeline: "` (candidates `["doc-refine"]`); Enter → `"Bind
   config: "` (candidates `["smoke-local","cheap-local","quality-local","quality"]`).
2. pick `smoke-local` → the pre-flight passes → the S15 run-view renders (the `RUN`/
   `GATE` lines immediately, then one `manas-ok`/`manas-bad` row per expert), ESC →
   `-- NORMAL --`.
3. **swap:** `:compose` → doc-refine → `quality` → pre-flight `bind-ok` → the run
   renders with the `quality` backend mix (`reasoner → qwen3:8b`, cloud combiner).
4. **negative (bind-miss):** with a non-covering config (S14 used to drop
   `smoke-local`'s combiner binding, or any config missing a doc-refine slot) →
   `:compose` → doc-refine → that config → a red `PRE-FLIGHT  <cid> missing: …` line,
   **no run**, stays Normal.
5. cancel: ESC at either prompt returns to Normal, no run.

### 8.3 Self-host note

S16 touches only scriba (`TUI/scriba/*`) + a new manas-library leaf
(`scaffold/lib/manas/pipeline/compose.chiral`) + a test sample — **no compiler source
changes**, so the B1-reproduces-itself self-host check (CLAUDE.md BUILD RULE) is
**not** triggered. Build-new → test → done.

---

## §9 Honest residue (scope must NOT expand it)

- **No ad-hoc compose / no minting a new pipeline.** S16 picks *existing* `Pipeline`
  values. Constructing a new in-memory `Pipeline` from `expert-pool` + setting
  GATE/ORDER/COMBINER/STOP from scratch is feasible but vanishes on exit without
  persistence — deferred to **E146** (value→source serializer, `CATALOG:411`/
  `LEDGER:129`, which names "S16 compose") — §6 D6. Not done here.
- **No persistence of the selection / re-run recipe.** Even for a picked pair, saving
  a "run recipe" is an E146 write-back concern — out (like S14's in-memory edit and
  S15's in-memory manifest).
- **No target-doc picker.** `compose-fire` reuses S15's crafted `rv-req`/`rv-doc`/
  `rv-extra` (`manas-runview.chiral:203-210`) so the run is reproducible. Picking the
  target document (a `prompt-file` feeding `rv-doc` — `prompt-file` is already built,
  `command-loop.chiral:1066`) is orthogonal input-selection, left to a follow-on — not
  an S16 concern, not deferred to any named element (no phantom).
- **No doc-aware pre-flight.** S16 binds the conservative declared-slot superset, not
  the exact GATE-fired subset (§5). A doc-aware pre-flight (run the pure GATE first,
  bind only fired slots) is a refinement, out — the runtime `plan-run` bind
  (`plan.chiral:110`) is the backstop.
- **No keymap chord.** Entry is the `:compose` command (§6 D5); a dedicated chord is
  UX polish, out, not deferred to any element.
- **Multi-pipeline picker UX.** With one shipped pipeline the picker is a 1-choice
  list; search/preview across many pipelines only matters once more are minted — a
  consequence of the current library size, not an S16 concern.

### Relational anchors

Gate S14 (`manas-mode.chiral` — the values picked) + S15 (`manas-runview.chiral`
`runview-drive`/`runview-render` — the dispatch target) + E134 (`gate.chiral`
`run-gate` — the routing the pre-flight supersets) + E135 (`bind.chiral:52`
`bind-config`/`BindResult` — the pure pre-flight). Seed `runview-fire`
(`command-loop.chiral:700` — the fire generalized) + `manas-enter`
(`command-loop.chiral:662` — id→value resolution). Pattern S14 (`prompt-manas-*`
minipuffer extension + candidate rail, `minipuffer.chiral:35`; `manas-edit-stop`'s
chained two-prompt read, `command-loop.chiral:610`). Deferred to E146 (value→source
serializer — the persistence half of ad-hoc compose). Feeds: the run S16 dispatches
is the `RunManifest` S15 renders and (optionally, E139 `be-log`) persists — S16 is
the "top of the cockpit" the 12→14→15→16 arc builds toward.

---

*Spec written: `.planning/specs/S16-manas-compose-SPEC.md`. Implementation runs
follow this SPEC; the example stays the rationale.*
