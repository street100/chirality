# S13 — vim-like modal editing (Normal / Insert / Visual / Command)

Worked example. Pipeline stage 1 of 5 (example -> audit -> spec -> audit -> implement).

## §1 Scope

scriba today is **modeless**: every printable key self-inserts, and commands are
Emacs-style prefix chords (C-x C-f, C-x C-c). This element adds **modal editing**:
a persistent editing-mode state with vim keybindings. Four modes, vim-standard:

- **Normal** (default) — keys are commands: h/j/k/l movement, i/a/o/O enter Insert,
  v/V enter Visual, : enters Command, dd/yy/p delete/yank/put, u undo.
- **Insert** — typing self-inserts; ESC returns to Normal.
- **Visual** — v (char-wise) / V (line-wise); movement extends the selection;
  y/d/c operate on it; ESC returns to Normal.
- **Command** — ":" line (minipuffer-style): :w save, :q quit, :e path open,
  :wq, :q!.

The mode is the puffer's **editing state**, not a render mode. The existing Str/chirality/
manas modes are render modes (syntax faces) and stay orthogonal.

**Everything is modal.** No operation stays on an Emacs chord. Every current
binding maps into a mode (Normal key, Command entry, or a new mode where the four
do not fit):

| current | modal home |
|---|---|
| C-x C-f open | `:e path` (Command) |
| C-x C-s save | `:w` (Command) |
| C-x C-w save-as | `:w path` (Command) |
| C-x C-c quit | `:q` / `:q!` (Command) |
| C-f/b/n/p move | l / h / j / k (Normal) |
| C-d delete-char | x (Normal) |
| C-_ / M-_ undo/redo | u / C-r (Normal) |
| C-s / C-r isearch | / / ? (Normal) |
| M-% query-replace | `:%s/old/new/` (Command) |
| C-SPC mark | v / V (Visual) |
| C-w / M-w / C-y kill/copy/yank | d / y / p (Normal + Visual operators) |
| M-h help | `:help` (Command, opens a help buffer) |
| C-x C-a / C-c C-c chat | **new mode, see below** |

The one operation the four modes do not fit is **chat**. The `*chat*` buffer is a
different interaction than editing a file: it is an outbound prompt + an appended
agent reply, and its keys (send, swap back to the file) are not motions or text
edits. So the element adds a fifth mode:

- **Chat** (vm-chat) — entered from Normal via a binding (g + c, or `:chat`); the
  minipuffer becomes the prompt line, Enter sends to the agent, the reply appends,
  ESC returns to Normal with the file buffer parked. This reuses the existing
  chat-append + agent-run path (Slice 11) unchanged; only the entry/send keys move
  behind the mode.

If more distinct interactions surface later, the mode is a closed sum, so adding a
sixth is a one-line constructor plus its keymap.

## §2 Research (what vim does, and what maps onto scriba)

- **Operator + motion + count.** dd = operator `d` + motion `d` (line). dw, cw, y$.
  A count prefixes: 3dd, 2j. This composes; scriba's flat-movement already has
  single-char and line motions, so operators compose on top of them.
- **Register / kill-ring.** scriba already has a KillRing (S2 slice, C-w/M-w/C-y).
  Vim's unnamed register + yank/put maps onto the existing kill-ring; yy = kill-line
  to ring without deleting? No — yy = copy line, dd = cut line, p = yank. All
  expressible with the existing str-edit + kill-ring machinery.
- **Visual mode = a live mark/region.** scriba already has mark/region
  (set-mark/kill-region/copy-region, S2). Vim visual mode is a modal region where
  movement keys extend the mark instead of moving the cursor. So visual mode is a
  mode flag that reroutes movement ops to extend the region.
- **Command mode = the existing minipuffer.** The minipuffer (S8) already prompts
  for a line (C-x C-f/C-x C-w use it). ":" is a thin binding that reads a line and
  dispatches :w/:q/:e/:wq/:q! to the existing save-puffer/find-file/quit paths.

So this element is **largely wiring + one new state machine**, not new text-editing
primitives. The heavy lifting (movement, delete, yank, region, minipuffer, save/
open) is already built and PTY-verified.

## §3 Conventional approach (how a non-modal editor would fake it)

Keep one flat keymap and bind vim keys directly (h -> backward-char, i -> a
toggle-self-insert flag, dd -> kill-line). Problem: vim keys are **context-dependent**
(dd in Insert types "dd"; d in Normal is a pending operator; d$ in Normal is
delete-to-end). A flat keymap cannot express "same key, different meaning by mode",
nor "pending operator awaiting a motion". You end up with a hand-rolled mode flag
smeared through every handler — exactly the thing the type system is for.

## §4 The chirality idea — a mode type, per-mode keymaps, operator pending state

The mode is a **sum type threaded through the loop** (like `chat` is threaded today):

```
(data VimMode ()
  (vm-normal)
  (vm-insert)
  (vm-visual (linewise Bool))
  (vm-command))
```

The loop already threads a puffer + parked chat buffer; it gains one more threaded
field, the mode. Key dispatch becomes **mode-first**:

```
(case mode
  (vm-insert  ; printable self-inserts; ESC -> normal; everything else = vim bindings
    ...)
  (vm-normal  ; h/j/k/l/w/b/e motions, i/a/o/O/A/I/O, d/c/y operators, v/V, :, u, p
    ...)
  (vm-visual  ; movement extends region; y/d/c apply; ESC/`v` exits
    ...)
  (vm-command ; minipuffer line; :w/:q/:e dispatch
    ...))
```

Normal mode needs a **pending-operator** state for d/c/y + a motion or doubled
(dd/cc/yy). That is another small sum:

```
(data Pending ()
  (pending-none)
  (pending-op (op Str)))   ; "d" | "c" | "y"
```

The vim keymap is a second keymap beside `default-keymap` (which stays, for the
Emacs bindings to remain reachable). A `Keymap` already is an alist
KeySeq -> opname, so a `normal-keymap` and a `visual-keymap` are the same shape.

Why chirality helps: the mode and pending state are **closed sums**, so the compiler
forces every mode to handle every key class (no "forgot visual mode handles y").
The operator+count is a pure (pending, count, motion -> edit) function; the
effectful shell (dispatch + re-render) stays thin, matching the existing
command-loop shape.

## §5 Chirality example (fleshed)

Mode state threaded through the loop:

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

(def mode-name (-> VimMode Str)
  (lam (m) (case m
    (vm-normal "Normal")
    (vm-insert "Insert")
    (vm-visual (linewise l) (case l (true "Visual Line") (false "Visual")))
    (vm-command "Command")
    (vm-chat "Chat"))))
```

Normal-mode key dispatch (representative subset; full map is the implementation):

```
(def vim-normal-keymap Keymap
  (keymap
    (cons (pair (keyseq (cons (k-char 104) nil)) "vim-backward-char")  ; h
    (cons (pair (keyseq (cons (k-char 106) nil)) "vim-next-line")      ; j
    (cons (pair (keyseq (cons (k-char 107) nil)) "vim-previous-line")  ; k
    (cons (pair (keyseq (cons (k-char 108) nil)) "vim-forward-char")   ; l
    (cons (pair (keyseq (cons (k-char 105) nil)) "vim-insert")         ; i
    (cons (pair (keyseq (cons (k-char 97) nil)) "vim-insert-after")    ; a
    (cons (pair (keyseq (cons (k-char 118) nil)) "vim-visual")         ; v
    (cons (pair (keyseq (cons (k-char 86) nil)) "vim-visual-line")     ; V (Shift)
    (cons (pair (keyseq (cons (k-char 58) nil)) "vim-command")         ; :
    (cons (pair (keyseq (cons (k-char 100) nil)) "vim-delete")         ; d (pending)
    (cons (pair (keyseq (cons (k-char 121) nil)) "vim-yank")           ; y (pending)
    (cons (pair (keyseq (cons (k-char 112) nil)) "vim-put")            ; p
    (cons (pair (keyseq (cons (k-char 117) nil)) "vim-undo")           ; u
    nil)))))))))))))))
```

The pending operator resolves a motion into an edit (pure core over the existing
str-edit + kill-ring):

```
; d + motion -> delete the region the motion covers; c + motion -> delete then enter
; insert; y + motion -> copy to ring. dd = operator + "d" motion = line.
```

The loop change is exactly the `chat`-threading pattern already proven this session:
command-loop-inner gains `mode` and `pending` params; every recursion threads them;
the dispatch chain picks a keymap by mode first.

## §6 Mode transitions, escape handling, and the puffer bar

### §6.1 Mode transition table (the state machine)

Every transition is a pure (VimMode, Key -> Maybe VimMode) step; the loop calls it
and re-renders. The full set:

```
              i a o O A I                      v / V
  Normal  ----------------> Insert    Normal -----------> Visual
    ^                          |          ^                 |
    | ESC                      |          | ESC (or v)      |
    +--------------------------+          +-----------------+

              :             Enter (execute)
  Normal ----------> Command ----------------> back to Normal
                       | ESC (cancel)
                       +------------------------> back to Normal
```

- **Normal -> Insert**: i (before cursor), a (after), o (line below), O (above),
  A (end of line), I (first non-blank).
- **Normal -> Visual**: v (char-wise), V (line-wise).
- **Normal -> Command**: `:`.
- **Insert -> Normal**: ESC only.
- **Visual -> Normal**: ESC, or v toggles off. c (change) deletes the selection and
  drops to Insert; d/y apply the op and return to Normal.
- **Command -> Normal**: Enter executes (:w/:q/:e/:wq/:q!), ESC cancels.
- **Normal stays Normal** for motions and operators (h/j/k/l/w/b/e, d/c/y pending,
  dd, u, p).
- **Normal -> Chat**: g + c (or `:chat`); the minipuffer becomes the prompt line.
- **Chat -> Normal**: ESC (file buffer parked); Enter sends the prompt to the agent
  and stays in Chat.

### §6.2 Escape handling (needs a read timeout — the one parser change)

ESC is the primary exit key, and it collides with the meta prefix (ESC x = M-x).
Today the parser cannot tell a lone ESC from the prefix: `read-key` returns the raw
bytes and `parse-key` returns `(none, pos)` for a bare ESC, so it lands as ki-unknown
and beeps; the `k-escape` branch in `parse-single-byte` is unreachable because
`parse-key` intercepts ESC first. The code comment already flags this
("read-more-until-complete ... needs a timeout/select").

So the element adds vim's `timeoutlen` (~50-100ms):

- `read-keyseq` reads ESC, then polls for a following byte.
- A byte within timeoutlen -> the meta/CSI path (ESC x -> M-x), as today.
- timeoutlen elapses with no byte -> a lone `k-escape`.

`k-escape` is bound only in the Insert and Visual keymaps (-> Normal) and Command
(-> cancel); in Normal it stays unbound. This is the single parser change the element
requires and it is orthogonal to the mode machinery (the mode code consumes a
`k-escape` key exactly like any other).

### §6.3 Mode display on the puffer bar

The puffer/status bar (`emit-status` -> `status-line-str` -> `status-left`) already
renders ` name [render-mode] row:col modified msg`, where render-mode is Str/chirality/
manas. The element threads the VimMode alongside `msg` and leads the line with it,
vim-style:

```
  -- INSERT --       name [chirality] 3:1 modified
  -- VISUAL LINE --  name [chirality] 3:1
  -- NORMAL --       name [Str] 357:1
  -- COMMAND --      :w
  -- CHAT --         prompt line
```

`mode-name` (§5) supplies the string. `emit-status` gains one param (the VimMode);
the render mode (Str/chirality/manas) stays in its bracket so editing-mode and
render-mode are shown side by side and never conflated.

## §7 Use / modify notes

- **Emacs bindings stay reachable.** `default-keymap` is unchanged; a Normal-mode
  binding (C-x, or a : command) drops into the existing Emacs command path. The
  status bar shows the mode name (Normal/Insert/Visual/Command) via mode-name.
- **Counts (3dd, 2j).** A leading digit in Normal mode accumulates a count; deferred
  to the implementation (the op model already threads a single integer where needed).
- **Replace mode (R) and marks/registers beyond the kill-ring are out of scope** for
  this element; the kill-ring is the register.
- **Insert-mode keybindings** are the existing self-insert + Enter/Backspace; only
  ESC is special (return to Normal). No new text ops.
- **The operator+count core is pure** (->), so it is unit-testable without a PTY;
  the effectful shell is the thin dispatch, as everywhere else in scriba.
