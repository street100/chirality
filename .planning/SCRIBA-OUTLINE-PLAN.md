# scriba manas mode → navigable structured editor (outline) — plan (2026-08-16)

User direction: the manas mode must be a **meaningful, navigable structured view**,
not a flat render + blind single-key edits on "dumb JSON". A **cursor outline** (chosen
2026-08-16): single view, everything visible as one map; a cursor moves through
**layers** and the **identities** within them; act on the *selected* thing. Plus a
**catalog** (see what's available) and a clear **library home** for saved manifests.

## The model

### Identity = a closed sum (boundary-sums discipline)
```
(data Focus ()
  (foc-field       (which Str))            ; scalar layer: WHEN|ORDER|STOP|COMBINER|YIELD
  (foc-layer       (which Str))            ; a collapsible header: GATE|EXPERTS|CONFIG
  (foc-gate-rule   (cond Str))             ; one GATE rule identity
  (foc-gate-member (cond Str) (id Str))    ; a member inside a rule (deepest gate id)
  (foc-expert      (id Str))               ; one expert in the pool
  (foc-binding     (slot Str)))            ; one Config binding
```
This IS the "map of layers and identities" — every navigable thing is one `Focus`.

### Outline state (rides in vm-manas)
```
(data Outline () (outline (doc ManasDoc) (cursor I64) (expanded (List Str))))
```
`vm-manas (doc ManasDoc)` → `vm-manas (ol Outline)` (~29 sites; helpers
`outline-doc`/`outline-with-doc` keep the edit handlers terse). `cursor` = index into
the flattened visible-node list; `expanded` = open layer keys.

### Flatten + render
```
(data OutlineNode () (onode (depth I64) (focus Focus) (text Str) (expandable Bool)))
outline-nodes : Outline -> (List OutlineNode)   ; walk doc, honor `expanded`, indent children
```
Render each node as a row (indent by depth, ▾/▸ marker if expandable); wrap the
cursor's row in a NEW `manas-cursor` face (reverse/highlight — add to `default-faces`).

### Navigation (vm-manas dispatch)
`j`/`k` move cursor (clamped); `l`/Enter expand a layer (or drill an identity, N4);
`h` collapse/parent; `gg`/`G`-home optional. Edit keys act on `(cursor-focus ol)`.

## Slices (serial, one agent each; verify + fold between)

- **N1 — navigable outline (read-only nav + display).** `Focus`/`OutlineNode`/`Outline`,
  `outline-nodes` flatten, `manas-cursor` face + cursor-highlight render, `j/k/l/h/Enter`
  nav, the vm-manas payload change (helpers to bound the churn). **Existing edits keep
  working** (operate on `outline-doc`, unchanged targeting) — no regression; N2 retargets
  them. This is the "meaningful display" win. ← dispatch first
- **N2 — selection-targeted editing.** Retarget the edit keys to `cursor-focus`:
  `e` edit the focused identity, `x`/`d` remove it, `a`/`o` add a sibling in the focused
  layer. Retires blind name-prompts + first-applicable (supersedes PL5).
- **N3 — catalog top level + library home.** The outermost outline lists pipelines /
  configs / saved setups; Enter drills into one. Canonical **`library/`** dir (saved
  setups + `library/index.json`), superseding ad-hoc `setups/`. This is "see what's
  available" + the manifest home (supersedes PL4).
- **N4 — drill into an expert identity.** `foc-expert` + Enter → the expert's fields
  (lens/sees/returns/slot/tools) as the deepest layer, editable. This is the 3C
  per-Expert feature, now natural in the outline (resolves the doc-expert design fork:
  the pool is navigated in place, edited by identity — no separate doc kind).

## Supersedes / folds in
PL4 (browser list-view) → N3. PL5 (m/g name-targeting) → N2. 3C per-Expert → N4.
3D actuate-ORDER is orthogonal (engine) and stays separate.

## Status
- [x] **N1 navigable outline** — DONE 2026-08-16 (`2b4c2a7`). `Focus`/`OutlineNode`/
  `Outline` + `outline-nodes` flatten + `outline-render` (indent, ▸/▾ markers, cursor
  row in a new `manas-cursor` reverse-video face) + `j/k/l/h`+arrows nav. vm-manas
  payload `(doc)`→`(ol Outline)` swept ~29 sites via `outline-doc`/`outline-with-doc`
  (clamps cursor)/`outline-of`; edit logic kept verbatim → no regression. PTY-proven:
  outline renders with layer markers+counts, cursor moves, GATE→4 rules, EXPERTS→7,
  `h` collapses, config outline, yield-edit + `:w` still work. 1032568 B. Per-rule
  member expansion (`foc-gate-member`) deferred to N2. (PTY timing more sensitive now —
  bigger repaint; use generous leads.)
- [x] **N2 selection edits** — DONE 2026-08-16 (`2da3540`). Verbs `e`/`a`/`d` act on
  `cursor-focus`; per-rule member expansion (`foc-gate-member`); retired the
  first-applicable/blind letter keys (m/g/G/X/B/R/e/E). Reuses all set-fns. PTY-proven
  cursor-targeting: delete the 2ND gate rule → 1st survives; specific-expert delete;
  add rule/expert/member; member-level delete; scalar + binding edit. 1036664 B.
  (Supersedes PL5.)
- [x] **N3 catalog view (discovery)** — DONE 2026-08-17 (`2c02633`). New `vm-catalog`
  mode; bare `:manas` → grouped navigable list (PIPELINES/CONFIGS/SAVED), j/k over
  entries (headers skipped), Enter opens (compiled → `manas-enter`; saved →
  `load-doc-from-path`), ESC back. `setups/` surfaced as SAVED (home, not renamed).
  `manas-browse` removed. PTY-proven: groups render, cursor moves, Enter opens
  doc-refine, save→catalog→reload round trip. 1044856 B. (Supersedes PL4.) Residue:
  unused `prompt-manas-browse` Prompt variant left in minipuffer.chiral (dropping it
  forces an exhaustive-match sweep — trivial cleanup, noted).
- [ ] N4 expert-identity drill — `foc-expert` + Enter → the expert's fields
  (lens/sees/returns/slot/tools) as the deepest layer, editable. Absorbs 3C. OPTIONAL
  finisher (both user asks met by N1–N3).

## ⚑ Both user asks MET (2026-08-17)
#1 "see what's available + a clear home" → N3 catalog. #2 "meaningful navigable
editing" → N1 outline + N2 selection edits. N4 is an optional finisher.
