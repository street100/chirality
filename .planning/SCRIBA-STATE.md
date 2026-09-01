# scriba — current state & handoff (2026-08-16)

Read this first in a new chat picking up scriba/manas cockpit work. It captures
the mode model, what's built, the known gaps, and how to build/test.

## ⚑ 2026-08-21 — WHAT'S LEFT lives in `.planning/SCRIBA-PRIMITIVE-CHECKLIST.md`

This file records what is BUILT. The open work — the emacs-primitive floor still
missing before the user layer can be built additively — is now cataloged as
**S18–S30 + E148** in `.planning/SCRIBA-PRIMITIVE-CHECKLIST.md`, with gates, sizes,
a serial build order, and the three owed author decisions (D-S1/D-S2/D-S3).

Measured 2026-08-21: **8,738 of 9,724 non-test lines (90%) are live in the binary**;
986 L are written-but-inert (`window` 400 · `flook` 264 · `help` 249 · `render-str` 41
· `list-utils` 32 — imported by nobody, confirmed absent from the resolved blob). The
blocking finding is structural, not a missing feature: loop state is **11 positional
params threaded through 436 sites** (76 of 142 defs in `command-loop.chiral`), so every
new surface must add a param or smuggle itself into a `VimMode` payload — done 5×
already. `S18` (the `Scriba` state record) is the gate; async is LAST and gates nothing.

## 2026-08-21 — CHAT is a real top-level mode (the chatter, plugged in)

CHAT was the odd one out among the top-level modes. PIPELINE rides in `vm-manas (ol Outline)` and
RUN in `vm-runview (rv RunView)` — each carries its state inside the variant, so its dispatch reads
it and the resize arm re-renders it. CHAT carried **nothing**: the transcript lived in a private
recursion inside `chatter-chat-loop`, `vm-chat` was an inert arm that beeped, a resize could not
repaint, and there was no way to scroll. It now has the same shape as its peers.

- **New `TUI/scriba/chat-view.chiral`** (pure, mirrors `manas-runview`): `Exchange` (moved out of
  `command-loop`), `ChatView` = transcript + `ConvState` + scroll, and `chat-render`. `vm-chat` now
  carries the `ChatView`; `chat-dispatch` routes keys (`i`/Enter compose · `j`/`k` + arrows/page
  scroll · `G` newest · ESC out); the resize arm re-wraps to the new width.
- **Two rendering bugs the DC-4b structure had exposed and this fixes.** (1) A reply or lane row
  was ONE `r-text`, so a long answer ran off the frame — and a *fused* reply CONTAINS newlines
  (`fuse-branch` joins lanes with `"\n"`), which went into the terminal raw and corrupted the
  frame. Rows are now split on `"\n"` and word-wrapped to width, with continuations indented under
  their lead. (2) The whole transcript was rendered every repaint, so a long chat pushed itself
  off-screen with no way back; the view now keeps a scroll offset measured BACKWARD from the
  bottom (0 = pinned to the newest, which is what you want while talking).
- **`:ask` lands on the same surface.** It used to build its own two-row Rendering, so a one-shot
  ask silently dropped the lanes and ran a long reply off the frame. One renderer now, one truth.
- **`chat-tag` deleted.** It re-derived a display tag from the message — only ever needed because
  the turn returned prose and the caller had to guess what happened. `turn-seq-view` returns the
  tag it actually used, so there is no second implementation to drift.
- *Verified:* PTY-driven on the committed-resolver build (1270136 B) — `:chat` → `i` → a compound
  message → `compound(2) → …` with `· analyze [audit: well-formed]` and `· decide ⇠ factual
  [audit: -]` lanes, wrapped and indented, then `k` scrolls without corrupting the frame; and
  `:ask` painting the same view and landing back in Normal with `ask: compound(2)`. Full manas
  suite (13 gates) + live `CONFORM: true`.
- ⚑ **`scriba-test-b1` link failure — FIXED (S3).** It could not link (`unknown name null-port`)
  on either resolver. `null-port` was a **phantom**: referenced in `scriba-test-b1.chiral` (as
  `(null-port unit)`) and in `flook.chiral` (bare), and DEFINED NOWHERE in the tree. `Port` is a
  single nullary constructor — `(data Port () (port))`, ports.chiral:186 — so the value both sites
  wanted is `(port)`, which is what `command-loop` has always passed. Both fixed. `scriba-test-b1`
  now links, compiles and runs: under a PTY it starts the editor and takes `:q`. **Its headless
  exit code is 1 BY DESIGN** — `compile-main` runs `test5-full-editor`, which launches the real
  editor and returns 1 from the `raw-err`/`ws-err` arms when there is no TTY. The gate it actually
  guards is COMPILATION, and that gate is green again.
- ⚑ **New finding while in there: `flook.chiral` is abandoned and has more phantoms.** Nothing
  imports it (no closure builds it), and besides `null-port` it uses an undefined effect label
  `flook-list` in four signatures, so it cannot compile standalone. Left as-is — the `null-port`
  half is fixed because it was shared with a live file; finishing or deleting flook is its own
  call. It has never been in any build, so nothing regresses either way.

## 2026-08-17 — Flow skill library in the catalog + `:ask` chatter

Wire edit→run for the L0/skill-grower Flow library, plus the general chatter's
cockpit entry.

- **`:manas` catalog now has a SKILLS group** (`7838921`). The catalog was
  `PIPELINES ++ CONFIGS ++ SAVED`; it is now `PIPELINES ++ SKILLS ++ CONFIGS ++
  SAVED` (indices aligned). SKILLS is the whole Flow-based fractal library:
  `{ doc-edit, code-test, evidence-sift, evidence-sift-refined, research, decision }`.
  New `scaffold/lib/manas/profile/skills.chiral` is the SKILL REGISTRY (`all-skills`
  = `SkillEntry` name+Flow+Config+pool+sample, `skill-names`/`skill-by-name`,
  `all-skill-configs`). scriba: `catalog-render` (manas-mode.chiral) grew the SKILLS
  group; `build-catalog` (command-loop.chiral) appends the skill entries and unions
  5 new smoke configs (code-test-smoke/research-smoke/decision-smoke/doc-edit-smoke/
  evidence-sift-smoke) into CONFIGS; Enter on a skill routes to `skill-open-view`,
  which paints the branch/per-perspective/backtrack fractal read-only via SG6's
  `flow-view` with a ":run to run" hint.
- **Enter on a skill RUNS it → run-view** (`853e29f`). `flow-runview-fire` opens the
  mesh Backend, runs `run-flow-stop` on the skill's sample under its config, closes
  the linear handle, renders; `flow-manifest->runview` maps the `RunManifest` to a
  finished S15 `RunView` (each ExpertCall → an RvCall row, parsed-ok=OK else BAD;
  synthesized pure calls render as OK code rows), reusing `runview-render`.
  `SkillEntry` carries pool + sample so a skill is one-keystroke runnable. PTY-proven
  end-to-end: `:manas` → Enter on `evidence-sift-refined` (deterministic, model-free)
  → RUN with OK rows; the model skills fire the same path on the 0.5b mesh.
- **`:ask <msg>` routes a message through the chatter** (`8cc6c1a`). `chatter-ask`
  (command-loop.chiral) calls `turn : (=> (1 Backend) Str Str)` — classify → route →
  run the routed skill's Flow → verbalize → paint. Backend INLINED into the `turn`
  call (moved once, mirroring `flow-load-view`). One-shot today (type → one routed
  answer → Normal); the interactive loop + memory are C5/C6 in
  `.planning/CHATTER-STATE.md` (the authoritative chatter handoff).

Builds (committed resolver): 1175928 B (`7838921`) → 1180024 B (`853e29f`) →
1192312 B (`8cc6c1a`). After any Flow/PureFn ctor change, recompile scriba
(`flow-view.chiral` has an exhaustive Flow case).

## The model (as the user articulated it — do NOT rescope)

scriba is a **port viewer**, not a file viewer. Its modes are **two levels**:

- **Top-level modes** are peers — each a distinct way to view/interact with a port:
  - **EDITOR** — text editing. The ONE top-level mode that carries **submodes**.
  - **CHAT** — talk to an AI. A different mode entirely.
  - **PIPELINE** (manas) — author a pipeline setup.
  - **RUN** — watch a run (run-view).
- **Editor submodes** = the vim states: `normal` / `insert` / `visual` / `command`.

You **swap** between top-level modes. "File editing is one mode with submodes;
chat is a different mode entirely." No multiplexing/windows/tiling — just swap.

### How the dispatch encodes this (034b573)
- `command-loop-inner` routes the TOP-LEVEL modes (Editor/Chat/Pipeline/Run).
- `editor-dispatch` owns the EDITOR submodes → `normal/insert/visual-dispatch`.
- **`VimMode` is still ONE flat sum** for threading (vm-normal appears 72×,
  vm-manas 17×, …). The *dispatch* carries the two levels; the *type* wasn't
  split — that's a ~130-site mechanical follow-up if wanted, clean on top of this.
- Where fixes go: editor key → `editor-dispatch`; new top-level mode → new
  `command-loop-inner` arm; mode-internal → that mode's dispatcher
  (`manas-author-dispatch`, `runview-nav-dispatch`).

## What's built (editor)

Vim surface is rich and PTY-verified (S13 + extensions):
- Motions: `h j k l  w b e  0 ^ $  gg G  f F t T {c}  %`
- Edits: `x  r{c}  ~  J  dd dw d$  cc cw  yy yw  p  u  C-r`
- Text objects: `d/c/y` + `i/a` + `w " ' \` ( { [` (e.g. `ciw`, `di"`, `ca(`)
- Counts: `{n}` prefix — `3dd`, `2j`, `5w` (in the `Pending` sum)
- Marks: `m{a}` / `` `{a} ``  ·  Registers: `"{r}yy` `"{r}dd` `"{r}p`
  (marks+registers ride in `KillRing` — no `Puffer`-shape churn)
- Mode entry: `i a o O A I`, `v V`, `:`, `g c`

Files (all create-capable now):
- `:e <newpath>` opens a NEW empty buffer (created on `:w`); `:e <path>` opens.
- `:w` saves (PROMPTS `Save as:` when the buffer is unnamed = `*scratch*`).
- `:w <path>` / `:saveas [path]` save-as; `:f [path]` / `:file` DECLARE the path
  without saving. `save-puffer` writes a final newline (POSIX; kills the zsh `%`).

Display/UX:
- Empty `*scratch*` typing fixed (was dropping the first char).
- `:`/chat prompt clears its row (no status bleed); `:` shows in the command line.
- Location (minipuffer) prompt keeps the caret after the typed text.
- **Alternate screen buffer** on run — clean terminal on quit (like vim/less).
- Dynamic per-mode status hint (`mode-hint`); `:help` = a mode-organized vim ref.

## What's built (manas pipeline editor — PARTIAL)

Enter author mode: `:manas doc-refine` (the pipeline) or `:manas <config-id>`.
The renderer (`manas-doc-render`) already SHOWS every level. Editable now:

| key | level | 
|-----|-------|
| `m` | Config binding (slot→model) |
| `g` | GATE membership (toggle an agent in a rule) |
| `s` | STOP policy |
| `o` | ORDER (fan-out/chain/branch) |
| `c` | COMBINER agent |
| `y` | YIELD prose |
| `w` | WHEN match text |

## KNOWN GAPS — the important ones (read before building more)

1. **DONE 2026-08-16 (`1f68ef7`) — edit→run.** Author-mode `:run` now fires the
   CURRENT edited `ManasDoc`, not the static pipeline. `runview-fire-doc` cases on
   the live doc: `(doc-pipeline p)` fires the edited pipeline `p` + `smoke-local-config`;
   `(doc-config c)` fires `doc-refine-pipeline` + the edited config `c`. `:` is now
   handled in author mode (`manas-command-line` + a `:` arm in `manas-author-dispatch`,
   reading via `vim-line-read`); `run` → `runview-fire-doc`, cancel repaints author
   mode with the doc intact, unknown cmd beeps and stays in `vm-manas`. Live PTY vs
   mesh: baseline `:run` = 6 OK rows incl. `claim-vs-source`; `g`-toggle that gate
   OFF then `:run` = 5 OK rows, `claim-vs-source` absent from GATE header + outcomes —
   the edit drove the run. (`:compose` still fires from `all-pipelines`; folding the
   edited doc into compose is part of gap 2's browser work.)
   - **⚑ ENGINE FINDING (not a scriba gap):** `plan-run` (`scaffold/lib/manas/pipeline/plan.chiral:97`)
     never consults the pipeline's `Order`, so an `o` ORDER edit changes the author
     view but produces an identical run. Run-visible author edits today = `g` (GATE →
     fired set) + config binds; ORDER/YIELD/STOP are authored-but-not-actuated by the
     engine. Actuating ORDER is engine work — see gap 3.
2. **BROWSER DONE 2026-08-16 (`9e65ade`); on-disk library still open.** Bare
   `:manas` now opens a picker (`manas-browse`) over the merged rail
   `(pipeline-ids all-pipelines) ++ (config-ids all-profiles)`; pick → author mode.
   `manas-enter` was generalized off its `doc-refine` hardcode to `pipeline-by-id`
   first then `profile-by-id`, so both the browser AND `:manas <id>` now cover
   EVERY library value. Live PTY: bare `:manas`→`Open setup:`; `doc`⇥→`doc-refine`
   (pipeline), `quality-l`⇥→`quality-local` (config); pick→author render.
   New closed-sum prompt `prompt-manas-browse`. **UX caveat:** the picker is
   **Tab-completion**, not a scrollable/inline candidate list — you type a prefix +
   ⇥. A real list view is polish, not cataloged (not a phantom). **Still open (the
   "different setups" depth):** pipelines/configs remain **static compiled-in
   values** (`scaffold/lib/manas/profile/*`, `manas/pipeline/compose.chiral`) — no
   **on-disk** library to add/save setups without recompiling. That's persistence =
   gap 4. `:compose` still fires from `all-pipelines`, not a currently-edited doc.
3. **Edit coverage — SLICE A DONE 2026-08-16 (`91f452c`); slices B/C/D open.**
   - **DONE (slice A): GATE rule + Config binding add/remove.** Four whole-unit
     `ManasEdit` variants (`edit-gate-add`/`edit-gate-del`/`edit-bind-add`/`edit-bind-del`)
     via the S14 set-fn→apply-edit→handler→key pattern; keys `G`/`X` (+/− rule),
     `B`/`R` (+/− binding); dup-condition + dup-slot guards are identity; explicit
     `apply-edit` arms (no silent `_ d` no-op). Mode hint updated. Unit test T1–T8
     exit 0 (mesh-free), PTY-proven all four (add changes the render, remove takes
     it away). Build 979320 B.
   - **DONE (slice B) 2026-08-16 (`cd0ca89`): expert-pool (`expert-ids`) add/remove.**
     `edit-expert-add`/`edit-expert-del`; `experts-add` guards (id must resolve in
     `expert-pool` + no dup → identity) / `experts-del`; keys `e`/`E`; + an `EXPERTS`
     render row in `pipeline-rows` (was invisible before). Unit T9–T12 exit 0; PTY:
     remove drops it, non-pool add is a no-op, add-back proven at value level (the
     re-appended tail id sits past the ~120-col render truncation — display artifact;
     value membership proven by T9). **Minor UX residue:** the EXPERTS row (and any
     long row) truncates at terminal width — no wrap/scroll. Cosmetic, not cataloged.
   - **OPEN (slice C, DESIGN-BLOCKED): per-Expert fields** (lens/sees/returns/slot/
     tools). Experts are a SHARED pool referenced by id → needs a design call FIRST:
     add a `doc-expert` ManasDoc view, or treat the pool as its own editable doc.
     Run the design/spec before implementing.
   - **OPEN (slice D, ENGINE): actuate ORDER** — `plan-run` (`plan.chiral:97`)
     ignores the pipeline `Order`, so the already-built `o` ORDER editor changes the
     author view but not the run. Engine change against the manas MoE golden (that
     arc is "complete" + live-verified — treat with care; CONFORM check).
4. **PERSISTENCE DONE 2026-08-16 (P1–P4) — the setup library ships.** Edit a setup,
   save it under a name, browse saved setups, reload + run — the whole loop closes.
   Plan/detail: `.planning/SCRIBA-PERSIST-PLAN.md`.
   - **P1** (`ecf638f`) pure JSON codec `manas/pipeline/persist.chiral` (total encoders +
     decoders, reuses `json.chiral`; round-trip fixpoint over the static library).
   - **P2** (`f65ec90`) `:w <path>` saves the edited doc as JSON (`doc->json` +
     `save-string-to-path`, crossing-free).
   - **P3** (`f58c2be`) `:load <path>` reads → decodes → author mode; clean
     `WriteR`/`LoadR` result sums.
   - **P4** (`7cfb675`) named-setup LIBRARY: `:save <name>` → `setups/<name>.json` +
     `setups/index.json`; the `:manas` browser lists saved setups and loads them on
     pick. **Enumeration = index file, NOT getdents** (no getdents/mkdir crossings
     exist; matches test-runner's manifest precedent). PTY-proven the browser loads
     DISK content (hand-set `order:chain` → renders `order-chain`), idempotent index.
   - **Residue (optional, not blocking):** `:compose`-fires-the-edited-doc (edit→run
     already runs the edited pipeline; compose adds config-choice). `setups-dir` is
     cwd-relative (resolves from repo root as `bin/scriba` runs) — an absolute/config
     path would need `getenv`+`mkdir` crossings. VimMode type still flat (~130-site
     mechanical split, low value).

## Build & test (B1 only — Python compiles NOTHING)

```
# build the ELF once (fast, ~0.75s; resolver cached):
B1=./scaffold/build/B1; RESOLVE=./scaffold/build/resolve
blob=$(mktemp); echo 'scriba/scriba-main' | "$RESOLVE" > "$blob"
for l in crossing-wraps sys-check target-linux sys-tal sys-linkage; do cat scaffold/lib/$l.chiral >> "$blob"; echo >> "$blob"; done
ulimit -s unlimited; "$B1" < "$blob" > /tmp/scriba.elf && chmod +x /tmp/scriba.elf
# then drive /tmp/scriba.elf under a PTY (fork a bash exec'ing it, type keys).
# bin/scriba does the same build+exec interactively.
```
Balance-check every edit before building (hand-nested parens bite):
`python3 -c "..."` counting `(`/`)` outside strings/comments; expect depth 0.

## File map (TUI/scriba/)
- `command-loop.chiral` (~1600 lines) — the loop, all dispatch, all handlers.
- `vim-mode.chiral` — VimMode + Pending sums, resolve-pending, key extractors.
- `keymap.chiral` — normal/visual/insert keymaps (hand-nested cons lists).
- `manas-mode.chiral` — ManasDoc/ManasEdit, apply-edit, the value renderer.
- `str-edit.chiral` — flat-text ops (motions, text objects, find/till, brackets).
- `file-io.chiral` — find-file/new-file/save-puffer. `minipuffer.chiral` — prompts.
- `kill-ring.chiral` — kill ring + named registers + named marks.
