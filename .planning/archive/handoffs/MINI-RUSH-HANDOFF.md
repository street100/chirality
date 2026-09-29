# MINI-RUSH HANDOFF — scriba-as-representation-layer + a Pi-style chirality coding agent

> **Audience:** a FRESH chat session with zero prior context. This file is self-contained.
> Read it top-to-bottom, read the 4 orientation files named at the end, then start at
> "First concrete step". Do NOT re-derive scope — it is fixed below.
>
> **Status of this doc:** audited 2026-08-13, then IMPLEMENTED through 2026-08-14.
> The plan below is now largely landed. Shipped (all committed): E131 native SSE
> streaming (chat-* shim retired), A1 file tools, A2 native bash crossing, A3
> E129/E130 sockets+HTTP, A4 Pi-minimal tool loop (agent/), A5 streaming verified
> against shredtower ollama, R1+R2 (command loop wired, fn-field lowering), and the
> scriba fixes F1/F2/F3 (multi-key quit, rt_sigaction SIGHUP, real nav/edit ops +
> TextZipper bridge). §5/§7 are historical; see §7 "Where it stands" for next steps.

---

## 1. The bar (what "done" means)

**scriba is the chirality representation layer, driven by a Pi-style minimal coding agent,
running on ANY host terminal, with everything written in chirality.**

Concretely:
- **scriba** is the editor / port-viewer resident: buffers, keymap, dispatch,
  undo, mark/region, search, modes, a generic *"view any port through a mode"*
  system, and a window-tree pane layout. It just emits ANSI to fd 0/1 on whatever
  terminal the user already has (xterm, Ghostty, tmux — doesn't care).
- **The agent** is a minimal coding agent modeled on **Pi** (Mario Zechner / Armin
  Ronacher, `@earendil-works/pi-coding-agent`, MIT). Apply Pi's *design*, not its code:
  - **4 primitive tools only** — `read`, `write`, `edit`, `bash` — each implemented
    **as a chirality port/crossing**.
  - Tiny system prompt; **extend-by-composition**; the agent can build its own new
    functionality (write+compile new chirality, acquire the resulting port).
  - **BYOK / provider-agnostic** tool-call loop, refined down from the existing
    `manas` orchestration cycle.
- **Model calls are all-chirality, no TLS.** Native chirality sockets carry **plain HTTP/1.1**
  to a **local / mesh model endpoint** (e.g. shredtower) over **Tailscale** — WireGuard
  supplies transport crypto at the network layer, so chirality needs no TLS. An
  OpenAI-compatible `/v1/chat/completions` endpoint is assumed.

## 2. Explicitly DROPPED / DEFERRED — do not build these

A fresh session's biggest risk is rebuilding the abandoned terminal/OS arc. **Do not.**

- ❌ The chirality terminal **app / emulator** (old T15 / T17, `TUI/emulator/`).
- ❌ The pluggable **`Terminal` *port* abstraction** (T13 / T14 / T16). scriba writes
  ANSI straight to fd 0/1. No port indirection over the host terminal.
- ❌ **pty multiplexing** across real ptys (T9). Pane layout is scriba's own window
  tree drawing into one host terminal, not multiple ptys.
- ❌ The **auth-fabric / crypto / chirality-as-OS (rung-2)** arc. Tailscale/WireGuard is
  the crypto; no chirality TLS, no capability-OS ceremony for this rush.
- ❌ **Cloud HTTPS.** Out of scope — local/mesh plain-HTTP endpoint only.

The `vt-core`, `mux`, `surface`, `apc`, `session` libs under `TUI/` belong to the
dropped arc. This rush does **not** depend on them. Ignore them unless a slice below
names one.

## 3. Constraint restated (load-bearing)

All-chirality run path. The ONLY sanctioned non-chirality in the model path is
**WireGuard/Tailscale at the network layer** (outside the process). Inside the process:
chirality native sockets → plain HTTP/1.1 → local model. No CPython in the run path of the
shipped binaries (see §4.6 for where Python still lurks and must be removed).

---

## 4. Audited current state

Verdicts are grounded in the tree. `built` = compiles+runs today; `stub` = compiles but
body is a placeholder; `missing` = not present. **Native vs Python:** the repo has TWO
runtimes — the **native B1-compiled ELF** (the real product) and the legacy **CPython
reference runtime** (`scaffold/chirality/impl_ports.py`, a test oracle). A crossing is
"all-chirality" only when it has a **native TAL wrapper** in `sys-tal.chiral`; if it only has
an `@impl(...)` in `impl_ports.py`, the native binary can't run it.

### 4.1 scriba (`TUI/scriba/*.chiral`)

The tree **compiles green** via `bin/scriba` to a ~291 KB ELF that runs and prints
`scriba ok` (per `SCOPE.md`). But `scriba-main.chiral` is a **stub**: it does
`term-raw 0` → `put "scriba ok\n"` → `term-restore` → exit. The real editor loop is NOT
wired into `compile-main`. Slice-by-slice against `.planning/SCRIBA-SLICES.md`:

| Slice | File | Verdict | Notes |
|---|---|---|---|
| Puffer accessors | `puffer.chiral` | **built** | `puffer-value` / `puffer-port-type` now have real bodies (were declares-only in SLICES). |
| Buffer / text zipper | `str-edit.chiral` (26 KB) | **built** | Core editing ops present. |
| Keymap | `keymap.chiral`, `cmd-types.chiral` | **built** | `default-keymap`, keyseq lookup. |
| Dispatch | `dispatch.chiral` | **built** | Gate was the fn-typed data field (ScribaOp.fn), not an effect-chain cap — R2 lifted it via defunctionalization. |
| Command loop | `command-loop.chiral` | **built (partial)** | Reads key + lookup + quit. Not driven from `scriba-main`. |
| Key parser | `key-parser.chiral` (10 KB) | **built** | ANSI/escape decode. |
| Render → ANSI | `render.chiral` | **built** | `render-to-ansi` / `-full` / `-delta` implemented (tree walk emits ANSI). `-delta` is Phase-1 (full re-render, no true diff yet). |
| Renderer registry / modes | `render.chiral` (registry), faces | **partial/stub** | Inline alist renderer registry exists; `r-face` node exists but **no face registry / no mode system / no syntax highlighting** (SLICES slice 7, ~200+ LOC missing). |
| File I/O wiring | `file-io.chiral` | **stub-wired** | Uses `openat`/`read`/`close` externs (native wrappers exist, §4.2) but save/open not driven from the loop. |
| init loader | `init-loader.chiral` | **stub** | `init-load` always returns `init-default`; runtime compile-and-load deferred ("Knob 1"). |
| Undo | (SLICES slice 3) | **missing** | No history on the zipper. ~100 LOC. |
| Mark / region | `mark-region.chiral`, `kill-ring.chiral` | **partial** | Kill ring exists; mark/region wiring incomplete. |
| Search | — | **missing** | No isearch / query-replace. ~120 LOC. |
| Window tree (layout POLICY) | `window.chiral` (15 KB) | **built** | Rect→view layout present. (Session-holding "mechanism" was delegated to the dropped `mux` lib — for this rush, single host terminal, so scriba's own tree is enough.) |

**Generic "view any port via a mode" system:** immature. The rendering tree + inline
renderer registry are the substrate, but there is no face registry and no mode
abstraction that binds *a port kind → a view*. This is the heart of "R = representation
layer" and is largely **to build**.

### 4.2 File-tool crossings (read / write / edit)

**Built, native.** `openat`/`read`/`write`/`close` have native TAL wrappers in
`scaffold/lib/sys-tal.chiral` (`nb-sys-openat` nr for openat, `nb-sys-read` nr 0,
`nb-sys-write` nr 1, `nb-sys-close` nr 3; plus `nb-sys-open-rw` O_RDWR sibling and
`nb-fcntl`). Surface externs are in `scaffold/lib/ports.chiral` (`open-rw`, etc.).
`file-io.chiral` already calls them. **An agent `read`/`write`/`edit` tool = a thin chirality
wrapper over these** (open → read/write loop → close; `edit` = read + string-splice via
`str-edit` + write). No new syscall crossing needed. This is the cheapest of the 4 tools.

### 4.3 `bash` / exec-with-captured-stdout — **THE TOOL-SIDE GAP**

- **Surface exists:** `scaffold/lib/proc.chiral` (E33) gives a typed, linear
  `proc-spawn : (=> (List Str) SpawnRes)` returning a `Child` carrying **captured stdout
  bytes** + a linear `Reap`; `run-filter` spawns, drains stdout, checks exit. This is
  exactly the shape an agent `bash` tool wants.
- **BUT the backing is CPython.** `raw-proc-spawn` and `wait` are bound only by
  `impl_ports.py` (`@impl("raw-proc-spawn")` at line ~480, `@impl("wait")`). The comment
  in `proc.chiral` says so: *"Backed by Python host binding (impl_ports.py) for now; the
  native TAL path (nb-run-cmd in sys-tal.chiral) is the follow-up."*
- **Native pieces present:** `sys-tal.chiral` has `nb-run-elf` (fork→dup2→exec-elf→wait),
  `nb-sys-dup2`, `nb-sys-exec-elf`, `nb-sys-socketpair`, wait4 decode.
- **Native pieces MISSING:** **no `pipe(2)` crossing**, and **no `nb-run-cmd`** that
  wires fork + `pipe` + `dup2(pipe_w→1)` + `execve` + drain-the-read-end + `wait4`. So
  today the native binary **cannot run a command and capture its stdout** — only the
  Python runtime can. **Gap = build a native `pipe` crossing + a native `nb-run-cmd`
  spawn-and-capture crossing, then rebind `raw-proc-spawn`/`wait` to it.** (Note
  `nb-run-elf` execs an ELF path; `bash`/general commands also need `execve` of an
  arbitrary program with argv/envp — the E33 `argv->pkt` framing already exists.)

### 4.4 HTTP + sockets — **LANDED (E129 + E130); only streaming chat-\* remains**

- **Non-streaming HTTP is native now.** `http-request : (=> Str Str Bytes HttpR)` is a
  chirality `def` over the socket caps (`http.chiral` ~line 308: `http-request-on` over a
  linear `Sock`, then `http-request` = open/connect/request/close). **E130** swapped the
  Python urllib shim out; `impl_ports.py` line ~343 reads "E130 retired the
  @impl('http-request') urllib shim". The native ELF can issue HTTP/1.1 today.
- **AF_INET TCP connect landed (E129).** `sys-tal.chiral` ~line 922 `nb-sock-connect-in-t`
  runs `socket(AF_INET, SOCK_STREAM, 0)` + `connect(sockaddr_in ip:port)` (two syscalls,
  a packed 16-byte sockaddr_in built by a pure `pack-sa-in`); the surface extern is
  `nb-sock-connect-in : (=> Bytes ConnR)` in `ports.chiral` ~line 88. This is the mesh /
  Tailscale client crossing — reach an IP:port with zero TLS.
- **Native AF_UNIX sockets (E125/E126/E127)** remain: `nb-sock-connect-t`,
  `nb-sock-send-go-t`, recv, `nb-sys-socketpair-t`, wired via `target-linux.chiral`
  (`nb-sys-connect` nr 42) + `sys-linkage.chiral`.
- **⚠️ Streaming still rides CPython.** `chat-open`/`chat-read`/`chat-close` are still
  `extern`s (`http.chiral` ~line 356) bound by `impl_ports.py` (`@impl("chat-open")` etc.),
  explicitly **deferred to E131** (SSE / chunked streaming). Not needed for the
  `stream=false` tool-call loop — only for a live streaming UI.

**What remains:** the only open transport piece is the streaming response codec (E131).
`backend.chiral` needs no change — its seam is `base : Str` (`be-url`); point it at
`http://<tailscale-host>:<port>` and the non-streaming model call is all-chirality end to end.

### 4.5 manas / coordinator / backend (`scaffold/lib/{manas,coordinator,backend,http,json,fsm}.chiral`)

All **built** (pure-chirality, but ride the Python `http-request` today, §4.4). Shapes:
- **`backend.chiral`** — the model seam. `Backend = (backend (base Str))`; `be-chat`
  POSTs `/v1/chat/completions` with a `chat-body` (model, messages, stream=false),
  digs `choices[0].message.content` via `chat-content`; `ChatR = chat-ok | chat-bad`.
  Streaming variant `be-chat-stream` drains a `ChatStream`. **OpenAI-compatible already**
  → a local endpoint plugs in by changing `base` only.
- **`manas.chiral`** — a batch/record driver (`Turn`, `Outcome`, `cycle-step`,
  `run-batch`), an example/audit loop. **Has no tool-calling loop** — it drives prompts
  and records outcomes.
- **`coordinator.chiral`** — `run-cycle` = build messages from hits + `be-chat`. RAG-ish
  glue.

**To refine into a Pi-minimal agent:** *keep* `backend.chiral` (the model seam) and
`json.chiral` (message/tool encoding); *keep* the `fsm.chiral`/`Step` state machinery as the
loop skeleton. *Drop / set aside* the batch-record framing in `manas.chiral`
(`Turn`/`run-batch`) and the RAG `coordinator`. *Build new* a **tool-call loop**: send
messages + tool schemas → parse the model's tool-call from the JSON response → dispatch to
one of the 4 primitive tools (§4.2–4.4) → append the tool result as a message → repeat
until the model stops calling tools. That loop + a tiny system prompt is the agent.

### 4.6 Where CPython still lurks in the RUN path

The native binary uses native crossings for everything with a `sys-tal` wrapper
(read/write/openat/close/mmap/poll/dup2/socketpair/sock-send/recv/sock-connect(AF_UNIX)/
fork+exec+wait via `nb-run-elf`). CPython (`impl_ports.py`, 49 `@impl`s) is the run path
ONLY for the reference runtime and for externs **with no native wrapper**. For this rush,
the offenders that must go all-chirality:

| Extern(s) | Python `@impl` | Native status | Status |
|---|---|---|---|
| `http-request` | **retired** (E130) | **native** (`http.chiral` def over sockets) | done |
| `chat-open`/`chat-read`/`chat-close` | yes (SSE shim) | **none** | deferred E131 (streaming) |
| AF_INET TCP connect | n/a | **native** (E129 `nb-sock-connect-in`) | done |
| `raw-proc-spawn`, `wait` (agent `bash`) | yes | **none** (no pipe/nb-run-cmd) | A2: native pipe + spawn-capture crossing |
| `read`/`write`/`openat`/`close` (agent read/write/edit) | yes (oracle) | **native present** | nothing — already all-chirality in the ELF |

Everything else (`env-*`, `secret-*`, `pool-*`, `read-key`, `time-mono`, `sleep-ms`,
`print`/`put`, tty ioctls) is either already native or not on this rush's critical path.

---

## 5. The work — grouped R / A / I, ordered

Sizes: XS≈trivial, S≈½ day, M≈1–2 days, L≈multi-day. Dependencies noted.

### Phase R — scriba as the representation layer
- **R1 — Wire the real command loop into `scriba-main`.** `S`. Files: `scriba-main.chiral`,
  `command-loop.chiral`. Replace the `scriba ok` stub with term-raw → init → loop →
  restore. Depends on R2 (done — fn-typed data fields now lower).
- **R2 — Arrow-typed data fields lower.** ~~`M`~~ **DONE.** The "effect-chain cap" premise
  was wrong (4-5 sequential effectful ops and effectful mutual recursion both compile
  through B1). The real gate was a function VALUE stored in a data field — `ScribaOp.fn
  : (=> (Puffer Str) (Puffer Str))` — which `lc-global` refused to lower. Fixed in
  `closconv.chiral` `cwalk-struct` (route fn-typed field args through `scan-fvargs`, so the
  existing `$clo`/`$apply` defunctionalization machinery handles them). Fixpoint converges
  at 1003896; the compiler self-image grows +16KB from defunctionalizing its own Mach
  fn-typed fields (redundant with specialize-singletons but correct — test-native green).
- **R3 — Face registry + mode system (view-any-port).** `L`. Files: `render.chiral` +
  new `modes.chiral`. A registry `port-kind → renderer/mode`; syntax faces; the generic
  port-viewer. This IS the representation-layer thesis.
- **R4 — Undo history.** `S`–`M`. File: `str-edit.chiral`. History on the zipper.
- **R5 — Search (isearch / query-replace).** `M`. New file. Depends on R1.
- **R6 — File open/save driven from the loop.** `S`. File: `file-io.chiral` + keymap.
  Crossings already native (§4.2).
- (Mark/region finish, `kill-ring` wiring — `S`, optional for MVP.)

### Phase A — the Pi-style agent
- **A1 — `read`/`write`/`edit` tools as chirality ports.** `S`. New `agent/tools-fs.chiral`
  over `ports.chiral` file crossings + `str-edit`. No new syscalls.
- **A2 — Native `bash` crossing (spawn + capture stdout).** `M`–`L`. Files:
  `sys-tal.chiral` (new `pipe` crossing + `nb-run-cmd`), `target-linux.chiral` (syscall
  rows), `sys-linkage.chiral` (wiring), `proc.chiral` (rebind `raw-proc-spawn`/`wait` to
  native). §4.3. **The tool-side infra lift.**
- **A3 — HTTP-on-native-sockets.** ~~`M`–`L`~~ **DONE (E129 + E130).** AF_INET connect
  (`nb-sock-connect-in`) and the `http.chiral` rewrite over socket caps both landed; urllib
  shim retired. Only streaming `chat-*` remains (deferred E131). See §4.4.
- **A4 — Tool-call loop (Pi-minimal).** `M`. New `agent/agent.chiral` refined from
  `manas`/`fsm`. Tiny prompt, 4 tools, dispatch-on-tool-call, loop. Depends on A1–A3.
- **A5 — Point `backend.chiral` at the local endpoint.** `XS`. Just the `base` URL /
  model id (config). Depends on A3 — **now unblocked.**

### Phase I — integration
- **I1 — Chat mode sharing the editor buffer.** `M`. A scriba mode (R3) whose buffer is
  the conversation; keybind sends the buffer/region to A4.
- **I2 — Agent tool-calls flow through scriba.** `M`. Tool effects (read/write/edit)
  render as buffer/window updates; `bash` output into a buffer.
- **I3 — Self-extend loop.** `L`. Agent writes new chirality → compiles with B1 (§6) → the
  binary acquires the new port. The capstone; depends on everything.

**Critical path to a first real model turn:** A3 is **done**. Remaining: A5 (XS, point
`backend.chiral` at the endpoint) → A4 (tool-call loop). A2 (native bash crossing) is the
one infra lift still open; streaming (E131) is deferrable. Do A5 + A4 next — that makes
the "all-chirality model call" claim real.

---

## 6. Build discipline (from `CLAUDE.md` — non-negotiable)

- **B1 compiles everything. Python compiles nothing, ever.** The existing compiler
  `scaffold/build/B1` (== `../chirality/bin/chirality-bin`) compiles a NEW binary from a blob:
  `B1 < blob > out`. Flow = **build-new → test → promote**. Nothing replaces itself in
  place.
- **Non-compiler programs (scriba, the agent, tests):** just compile with B1 and run —
  no ceremony. `bin/scriba` already does the resolve+blob+B1 dance (and sets
  `ulimit -s unlimited` — B1 deep-recurses on big blobs).
- **Compiler-blob sources (only when the compiler's OWN sources changed):** after
  promoting, run the promoted binary over the same blob once more and byte-compare —
  `B1 < blob | cmp - B1` must reproduce itself (self-hosting fixpoint, ~1s).
- **`python3 tools/selfhost.py` and `scaffold/chirality/impl_ports.py` are LEGACY** — a test
  oracle pending retirement, NEVER part of any build, never a fallback. The whole point of
  §4.6 is deleting Python from THIS rush's run path.
- The committed tree must be the tree that built the committed binary — sync via
  `bin/make-public.sh` only.

**New crossings (A2, A3):** adding a syscall wrapper means editing `sys-tal.chiral` (the
hand-TAL crossing), adding a syscall-number row in `target-linux.chiral`, wiring it in
`sys-linkage.chiral`, and giving it a surface `extern` in `ports.chiral`. Follow the
existing `nb-sock-connect-t` / `nb-sys-connect` (nr 42) precedent verbatim. Then rebuild
and test the native binary — do NOT lean on the Python `@impl`.

---

## 7. Where it stands (updated 2026-08-14) + what to read first

**Landed since the 2026-08-13 audit (all committed):**
- E131 native SSE streaming: chat-open/chat-read/chat-close are chirality defs over the
  socket floor (ChatStream data carrier, pure framing + process spine). impl_ports.py
  chat-* shim + _delta_content deleted. Rationale: examples/E131-sse-stream.md + SPEC.
- A1 file tools (agent/tools-fs.chiral), A2 native bash crossing (nb-run-cmd over
  pipe2+execve), A4 tool-call loop (agent/agent.chiral). All zero-CPython.
- A5: streaming verified against shredtower ollama (100.64.0.5:11434) via
  scaffold/samples/stream-ollama.chiral, chirality-only, exit 0.
- R1 (command loop wired into scriba-main), R2 (fn-typed data fields lower).
- Scriba editor fixes (PTY-tested): F1 multi-key keyseq so C-x C-c quits, F3 real
  nav/edit ops + Zipper/TextZipper bridge, F2 rt_sigaction crossing so terminal close
  exits 0 (not SIGHUP), plus the reversed-str-find-args fix (search/split were dead).
- Step 1 DONE (2026-08-14): agent/agent.chiral wired at shredtower, one real
  tool-call turn verified end to end. Found + fixed an E130 residual on the way:
  http-request did not decode Transfer-Encoding: chunked (ollama/Go sends chunked,
  no Content-Length), so the non-streaming path returned raw chunk framing and
  parse-turn silently dropped the response. Fix = find-chunked (header detect) +
  de-chunk (recursive decode) in http.chiral parse-response; non-chunked path
  unchanged. Driver: scaffold/samples/agent-probe.chiral; resolver path via
  scaffold/lib/agent -> ../../agent symlink. Verified: agent-probe.elf exit 0,
  AGENT-ANSWER carries the bash tool's captured stdout (hello-from-tool-call).

**TUI state, honestly (updated 2026-08-14, end of stage):** scriba IS the TUI. It
compiles via bin/scriba and RUNS in a raw terminal (PTY-tested throughout this stage).
Working: term-raw + multi-key key parser; self-insert (typing); char/line movement
across newlines; delete/backspace forward and backward across lines (backspace at a
line start deletes the newline / joins, and deletes an empty line); C-x C-f / C-x C-s
file open/save; chirality syntax colors (R3 face + mode system); cursor tracking with the
visible block following the program cursor (within a line); Enter and Shift+Enter
insert a newline; C-x C-a chat-send (buffer -> agent -> appended reply); robust key
handling (an unrecognized key beeps and keeps going, never quits — only C-x C-c or
terminal EOF exits). A status/mode line + keybind help (M-h) is DONE (bottom row shows
buffer name + mode + cursor row:col + dirty marker + keybind hint). Since this
snapshot was written, the remaining editor gaps have all landed (see "OPEN, in
order" below, all DONE 2026-08-14): undo/redo (C-_/M-_), isearch + query-replace
(C-s/C-r/M-%), mark/region + kill-ring (C-SPC/C-w/M-w/C-y), creating a new file
(the `open-create` O_CREAT|O_TRUNC crossing, so shrinking saves truncate
byte-exact), and save-as (the minipuffer modal prompt, C-x C-f / C-x C-w). The
terminal-emulator / Terminal-port arc (T13-T17, pty mux; vt-core/session/mux/surface/
emulator under TUI/) is DROPPED per §2, scoped-not-built. Remaining known limit:
long-line cursor wrap desyncs (needs a cell-grid renderer — flagged do-not-half-fix).

**Editor-correctness pass (2026-08-14, all PTY-verified + committed):** the
cursor-offset fix (zipper-bridge path now carries the flat-text offset) made the
cursor actually move, which exposed a series of latent str-edit boundary bugs, all
now fixed — C-b segfault + at-whitespace-back? negative slice, advance-by segfault at
line end (strict < vs <=), delete not re-rendering (try-dispatch now returns the
puffer and the loop re-renders every dispatched op), the r-lines flat renderer (chirality
buffer no longer 2-column indented by r-tree), the key-handling conflation
(unrecognized keys no longer quit; Enter/Shift+Enter insert newlines via kitty CSI-u),
and backspace/backward-char crossing popping the wrong end of the line list.

**Scriba-as-a-tool, lined up (deps noted; SLICES = .planning/SCRIBA-SLICES.md):**
DONE this stage (committed): R6 file open/save, R3 face registry + mode system,
I1 chat mode, self-insert, cursor tracking, cross-line delete/backspace, robust key
handling, r-lines flat rendering, status/mode line + keybind help.
OPEN, in order:
1. **DONE 2026-08-14** Undo history on the zipper (SLICES 3) — C-_ undo / M-_ redo, PTY-verified, committed.
2. **DONE 2026-08-14** Search / isearch + query-replace (SLICES 6) — C-s/C-r isearch, M-% query-replace, PTY-verified, committed.
3. **DONE 2026-08-14** Mark/region finish + kill-ring wiring (SLICES 2) — C-SPC/C-w/M-w + kill->ring->yank, PTY-verified, committed.
4. **DONE 2026-08-14** New file: O_CREAT crossing (scaffold/lib) — `open-create` (O_CREAT|O_TRUNC) landed; save-puffer truncates. Fixpoint byte-identical, native create/truncate + PTY shrinking-save verified, committed.
5. **DONE 2026-08-14** Save-as / choose path: implement the minipuffer — 8 S8 functions implemented, C-x C-f prompts for a path, C-x C-w save-as (creates the file via open-create), C-g cancels. PTY-verified, committed.
6. **DONE 2026-08-14** I2 agent tool-calls render through scriba (single-buffer transcript) — agent-run-transcript entry point, C-x C-a renders "> tool: arg" + result + final answer. PTY-verified against ollama; agent-probe still green. (Window panes deferred to mux.)
7. **DONE 2026-08-14** I3 self-extend (minimal loop) — fs-write uses open-create (write tool creates files); self-extend-probe proves write->compile->run against ollama (ELF exits 42). Full hot-acquire deferred: needs chirality runtime dynamic loading — **minted E132** (was "Knob 1", uncataloged; catalog + ledger rows minted 2026-08-14).

Critical path to "scriba drives the agent": I2 -> I3. Undo/search/mark/new-file/save-as
are editor ergonomics, parallel, not on the agent line. The "fine-grain orchestration
editing" (manas/pi lens) = I2 (see the agent work) + I3 (let it extend itself) + lifting
the orchestration config (models/tools/pipeline) into a first-class scriba mode.

**Read first:** agent/agent.chiral + agent/tools-fs.chiral (the agent),
scaffold/lib/http.chiral (chat-open/chat-read/chat-close, http-request),
TUI/scriba/command-loop.chiral + init-loader.chiral (editor loop + ops), and
.planning/SCRIBA-SLICES.md (the live scriba tracker).
