# S13 — vim-like modal editing — IMPLEMENTATION SPEC

Stage 3 of 5. Source of truth for the implementer. Reads with
`.planning/scriba-examples/S13-vim-modes.md` (the worked example).

## §1 Goal

Add modal editing to scriba. Five modes, everything modal, no operation left on
an Emacs chord. Mode is the puffer's editing state (orthogonal to the Str/chirality/
manas render modes).

## §2 Types (new file `TUI/scriba/vim-mode.chiral`)

```
(data VimMode ()
  (vm-normal)
  (vm-insert)
  (vm-visual (linewise Bool))
  (vm-command)
  (vm-chat))

(data Pending ()
  (pending-none)
  (pending-op (op Str)))   ; "d" "c" "y"

(def mode-name (-> VimMode Str) ...)  ; "Normal" "Insert" "Visual"/"Visual Line" "Command" "Chat"
```

## §3 Escape handling — the one parser change (`key-parser.chiral` + `command-loop.chiral`)

`parse-key` already returns `(none, pos)` for a lone ESC and `(some k-meta ...)`
for ESC+x. `read-keyseq` currently maps that `none` to `ki-unknown` (beep). Change
`read-keyseq` so a lone ESC becomes `ki-key (keyseq (cons k-escape nil))`:

- read ESC, poll stdin for a following byte with `timeoutlen` (~80ms).
- a byte within timeoutlen -> existing meta/CSI path (ESC x -> M-x), as today.
- timeout with no byte -> `k-escape`.

`k-escape` stays unbound in `normal-keymap`; it is bound in insert/visual/command/
chat keymaps (-> Normal / cancel). The minipuffer-loop already has a `(k-escape none)`
arm that is currently dead because `read-keyseq` never emits k-escape; this change
makes it live, so `:w`/`:e` prompts cancel on ESC too. This is a bonus, not a new risk.

## §4 Per-mode keymaps (`keymap.chiral`)

Reuse existing op names wherever they already exist. New op names are flagged.

`normal-keymap` (vm-normal):
- h->backward-char, j->next-line, k->previous-line, l->forward-char (all exist)
- 0->beginning-of-line, $->end-of-line, ^->first-non-blank (NEW: first-non-blank)
- w->forward-word, b->backward-word, e->end-of-word (NEW x3)
- x->delete-char (exists), u->undo, C-r->redo, p->yank (all exist)
- /->isearch-forward, ?->isearch-backward (exist)
- i,a,o,O,A,I -> mode transition to Insert (dispatch, not ops)
- v,V -> mode transition to Visual (dispatch)
- : -> mode transition to Command (dispatch)
- g c -> mode transition to Chat (dispatch; also bind :chat)

`visual-keymap` (vm-visual):
- h/j/k/l/w/b/e/0/$ extend the region (reuse the movement ops; the loop routes
  them to extend-region instead of move-cursor while linewise/charwise)
- y->copy-region, d->kill-region, c->kill-region + enter Insert (exist/NEW)
- ESC->normal, v->normal (toggle off)

`insert-keymap` (vm-insert): the existing self-insert path (printable -> insert,
Enter -> newline, Backspace -> delete); ESC->normal. Arrow keys move. No other
bindings.

`command-keymap` (vm-command): the existing minipuffer; parse the line and dispatch
:w save, :q quit, :q! quit-force, :wq save+quit, :e PATH open, :help, :chat.
Enter executes, ESC cancels.

`chat-keymap` (vm-chat): prompt line; Enter sends to the agent (existing chat-send
path), ESC->normal (file parked). The prompt reuses the minipuffer render.

## §5 Operator + motion + pending (`vim-mode.chiral`)

Normal-mode d/c/y are pending operators, not one-key ops. State machine:

- (pending-none, key d/c/y) -> (pending-op "d"/"c"/"y").
- (pending-op op, key motion) -> apply: d+w delete-word, d+d delete-line, d+$ kill-to-end,
  c+w change-word, c+c change-line, y+y yank-line, y+w yank-word.
- (pending-op op, key not-a-motion) -> beep, clear pending.
- Any other key while pending-none -> normal dispatch.

Motions that resolve a pending op: w b e $ 0 ^ (and the same letter d/c/y for the
line op). Counts (3dd, 2j) are out of scope for this slice (noted in the example).

## §6 Loop threading (`command-loop.chiral`)

`command-loop-inner` gains `mode` and `pending` params, threaded through every
recursion exactly like `chat` was. Signature becomes:

```
(=> Keymap (Puffer Str) (Maybe (Puffer Str)) (Pair I64 I64) I64 Str Rendering
    (List (Pair Str Mode)) (List ScribaOp) VimMode Pending Unit)
```

Dispatch is mode-first: read keyseq -> branch on mode -> pick the keymap for that
mode -> lookup -> route. Insert mode uses the existing self-insert branch; Command
and Chat use the existing minipuffer-read. The existing Emacs `default-keymap` stays
reachable via a Normal-mode binding (C-x drops into the current Emacs dispatch).

`scriba-main.chiral` starts the loop in `vm-normal` / `pending-none`.

## §7 Mode display (`command-loop.chiral`)

`status-left` and `status-line-str` gain a `mode-name` param; `emit-status` threads
the VimMode and leads the line with `-- MODE --`:

```
-- INSERT --       name [chirality] 3:1 modified
-- VISUAL LINE --  name [chirality] 3:1
-- NORMAL --       name [Str] 357:1
-- COMMAND --      :w
-- CHAT --         prompt
```

The render mode (Str/chirality/manas) stays in its existing bracket.

## §8 File-by-file

- `TUI/scriba/vim-mode.chiral` (NEW): VimMode, Pending, mode-name, the operator+motion
  resolver (pure, ->).
- `TUI/scriba/key-parser.chiral`: lone-ESC timeout -> k-escape (keep parse-key pure;
  put the poll in read-keyseq).
- `TUI/scriba/keymap.chiral`: normal/visual/insert/command/chat keymaps; add the new
  op names to the registry via init-loader.
- `TUI/scriba/init-loader.chiral`: register the NEW ops (forward-word, backward-word,
  end-of-word, first-non-blank, extend-region variants, kill-region, copy-region,
  change-line/word, delete-line/word, yank-line/word). Reuse the existing ops.
- `TUI/scriba/command-loop.chiral`: thread mode+pending; mode-first dispatch; status
  bar mode; the Command/Chat handlers.
- `TUI/scriba/scriba-main.chiral`: init mode/pending.

## §9 Verification (acceptance)

Build gate: `bin/scriba` (B1 compile, exit 0). PTY checks, in order:
1. Start in Normal; status bar shows `-- NORMAL --`.
2. i -> `-- INSERT --`; type chars self-insert; ESC -> `-- NORMAL --`.
3. h/j/k/l move; j at a line end stays put (no crash).
4. v -> `-- VISUAL --`; h extends; y returns to Normal; p pastes.
5. : -> `-- COMMAND --`; `:w` saves (status shows `saved`); ESC cancels back to Normal.
6. dd deletes a line; yy yanks; p puts; u undoes.
7. :e PATH opens a file (content appears).
8. g c (or :chat) -> `-- CHAT --`; prompt sends to the agent; ESC -> Normal.
9. A lone ESC in Normal beeps and stays Normal (no text leak); ESC+x still M-x.

The operator+count resolver is pure and unit-testable without a PTY.
