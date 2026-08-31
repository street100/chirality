# scriba — the primitive floor for the user layer (S18–S30 + E148)

**Minted 2026-08-21.** The question this answers: *what is still missing from
scriba's editor primitives before the user layer can be built additively?* — where
"user layer" = the chatter/cockpit/skill surfaces and whatever comes after them.

Companion docs — **read these for what is already DONE, not this one**:
`.planning/SCRIBA-STATE.md` (mode model + handoff) · `.planning/SCRIBA-SLICES.md`
(S1–S17, the historical slice ledger) · `.planning/CHATTER-STATE.md` (the user layer
that is already riding on this floor) · `TUI/CATALOG.md` (`T#`, the terminal
substrate below scriba — a different lane).

This doc is the **scriba ledger** that `.planning/LEDGER.md §Z` flags as owed
("flagged to migrate to a scriba ledger"). `E88`/`E92` are cited there, not moved.

---

## §0 · Measured baseline — **at HEAD `1cafe80`, 2026-08-21**

Measured against the **committed tree**, not the working tree, so the numbers are
reproducible (`git show HEAD:<file>`). A concurrent session had uncommitted scriba
work in flight when this was written — re-measure before quoting these in a spec.

| Measure | Value | How |
|---|---|---|
| scriba source, non-test | **9,366 L** | `TUI/scriba/*.chiral` (9,968 L) minus 602 L of tests |
| …compiled into the running binary | **8,380 L (89%)** | resolved blob from `scriba/scriba-main` |
| …written but **inert** (imported by nobody) | **986 L (10%)** | `window` 400 · `flook` 264 · `help` 249 · `render-str` 41 · `list-utils` 32 |
| Registered named ops (the command registry) | **31** | `init-loader.chiral` `init-default` |
| `:` commands | **~20, hardcoded** | one nested `case` chain, `command-loop.chiral:1838` |
| Loop-state parameters, threaded positionally | **11** | `command-loop-inner`, `command-loop.chiral:2064` |
| Defs threading that state | **74 of 144** | `lam (km puf chat …` in `command-loop.chiral` |
| Argument sites passing it | **436** | occurrences of `renderers ops` |
| `VimMode` variants carrying a session payload | **4** (`vm-manas`, `vm-runview`, `vm-catalog`, `vm-chat`; `vm-visual`'s `linewise` is a mode flag, not session state) | `vm-visual`, `vm-manas`, `vm-runview`, `vm-catalog`, `vm-chat` (5 with `vm-chat cv`) |

**⚑ In-flight work adjacent to S20 (noticed 2026-08-21):** the working tree carries an
untracked `TUI/scriba/chat-view.chiral` (197 L) plus uncommitted `command-loop.chiral` /
`vim-mode.chiral` edits from a concurrent session — `ChatView` being factored out of the
loop. That is the same seam **S20** formalizes (a surface's session value belongs with
its buffer, not in a `VimMode` payload). Reconcile before speccing S20; do not spec
around it.

**⚑ CORRECTED 2026-08-23: `scaffold/lib/scriba` IS `TUI/scriba`.** It is a
**symlink** — `ls -l` gives `scaffold/lib/scriba -> ../../TUI/scriba`. There is one
directory, one set of files, and **nothing to sync**: `bin/make-public.sh:37`
deliberately does not mirror `lib/scriba` at all. Edit one file.

The old text said the two trees were "byte-identical (verified `diff -rq`, clean)"
and told you to keep them synced via `make-public.sh`. `diff -rq` returning clean
was the **symptom, not the mechanism** — which is precisely the A3 hazard
`.planning/BUILD-ORDER.md` §A3 records (three wrong calls about this same symlink
web, each from indirect evidence when `ls -l` answered it outright), biting the
doc that records it. The resolver reads `scaffold/lib/scriba/` and lands on the
same inode either way.

---

## §1 · What is already DONE (so nobody rebuilds it)

Emacs primitive → scriba, **live in the binary**:

- **Buffer** — `Puffer`, 9 fields, polymorphic `(Puffer A)` over a *port*, not just
  text (`puffer.chiral:41`). Richer than emacs's: the buffer is a typed lens on a port.
- **Point / mark / region** — `mark` field + `mark-region.chiral`.
- **Kill ring, named registers, named marks** — `kill-ring.chiral`.
- **Undo / redo** — per-buffer past/future zipper stacks (`puffer.chiral:37`); restores
  text *and* cursor.
- **Minibuffer** — `minipuffer.chiral` + `completion.chiral` (prefix completion,
  longest-common-prefix, closed-sum prompt kinds).
- **Keymap as data** — `keymap.chiral`, alist `KeySeq → opname`, prefix keys,
  per-submode maps (normal/insert/visual).
- **Named command registry + dispatch** — `ScribaOp` (name, fn, docstring) →
  `try-dispatch` (`cmd-types.chiral`, live since E92). This is emacs's
  `interactive`-command indirection, and it works.
- **Major mode** — `Mode` = renderer + face set, registry keyed by the buffer's
  `type-name` (`render.chiral:24`); 3 modes registered (Str / chirality / manas).
- **Faces / SGR** — `Face` registry + `r-face` render node.
- **Echo area + mode line** — the `msg` param + `emit-status` + per-mode `mode-hint`.
- **Error barrier** — structural, not a handler: ops are total `(-> Puffer Puffer)`,
  every crossing returns a closed result sum. A failed command cannot unwind the loop.
  Emacs needs `condition-case` for this; chirality gets it from the membrane.
- **Editing surface** — full vim motions/edits/text-objects/counts/marks/registers,
  isearch + query-replace, file open/save/create, alternate screen (S13 + slices 2–7).
- **Cockpit surfaces** — manas author mode, run-view with token streaming, compose,
  catalog, saved-setup library, `:flow`, `:ask`, `:chat` (S14–S17 + chatter C1–C6b/DC).

**Read that list before adding anything.** The cardinal working error here is naming
a primitive that is already built (the banks discipline, applied to scriba).

---

## §2 · The catalog — what is NOT done

Row format: `S# · title · state · gate · size · evidence`. **State** is `design`
(specced-able now), `blocked` (named gate first), or `decide` (an author decision
must land before the row is specced).

### Tier A — the state floor · BLOCKING the user layer

The whole tier is one finding: **there is no "editor" value.** State is 11 positional
params threaded through 436 sites, so every new surface must either add a param
(74 signatures) or smuggle itself into a `VimMode` payload (done 5× already).

| S# | Element | State | Gate | Size |
|----|---------|-------|------|------|
| **S18** | **`Scriba` editor-state record** — **the editor's OWN state only.** ⚑ Constraint (P4): a single record makes "add to central state" the cheap path and "make it its own node" the expensive one — the gradient that produced Emacs's single image, which `docs/live-environment.md` explicitly inverts. **Authority-bearing state (anything holding a port) does not go in this record**; it earns a node (see S20b). One value replacing the 11-param thread (`km puf chat dims scroll msg old-rendering renderers ops mode pending`), with accessors + `with-*` updaters. Every dispatcher takes `(=> Scriba …)`. | design | — | **BUILT 2026-08-23** (`5a88be3` record + harness, `130062f` migration). ⚑ *Every figure in this cell was low.* Measured: **78** signatures (plus 78 binder lines = **156** declaration edits), **367** arg sites over 318 lines, **78** threading defs. **Net LOC is 0**, not −200 — `command-loop.chiral` is 2,545 lines before and after; the win is bytes (155,291 → 132,287, −14.8%) against +10,463 B of new module. And it was **not one 11-param thread but NINE shapes** — 58 defs on an 8-param prefix, 15 on a 7-param one, `try-dispatch` on a `km`-less sub-run, and `isearch-loop` threading the same state **in a different order**. That is the strongest argument for the record and it was missing from this row. R2 (pairwise-distinct field types) caught a real name capture: `manas-prompt1` bound a `Str` named `s`. Gate: type-check + a differential PTY edit-smoke (`bin/scriba-edit-smoke.py`), frames byte-identical incl. raw md5s — and it walks ~12 of 79 defs, touching none of the ~40 manas/catalog/runview/chat defs that need a live endpoint. |
| **S19** | **Buffer list + switching.** `(List Puffer)` + a current index inside `Scriba`; the `(Maybe (Puffer Str))` `chat` slot retires into it. Commands: list / next / prev / by-name / kill. | design | S18 · **D-S3** | ~150 L |
| **S20** | **Buffer-local state slot** — for state with an **empty port set only** (`Outline`, `Catalog`, view/scroll positions). ⚑ **NOT for the chatter** — see the P3 finding below. | design | S19 | ~60 L |
| **S20b** | **Split the orchestrator into its own node.** scriba opens `(backend-open rv-endpoint)` inline at 3+ sites (`command-loop.chiral:1327,1439,1473`) and its blob carries 87 network references — **the editor process holds network authority.** `docs/live-environment.md` decides this case by name: *"an AI-orchestrator earns its own node (authority plus containment), a fontifier does not (empty port set)."* The chatter is the orchestrator. Give it its own node; scriba holds a port to it. | design | S19 · splitting-law | see note |
| **S21** | **`:` command registry.** Ex-commands as data — name + fn + doc + arg shape, one lookup — retiring the ~20-arm nested `case` (`command-loop.chiral:1838`, a single 4,000-char line). Mirrors `ScribaOp`, which is the working template. | design | S18 | ~150 L, retires ~45 case arms |

**The ConvState symptom, and why the first fix was wrong (P3 audit, 2026-08-22).**
`chatter-chat` enters CHAT at `cv-empty` (`command-loop.chiral:1833`) and the transcript
+ `ConvState` ride in `(vm-chat cv)`; ESC drops the variant, so **leaving CHAT destroys
the conversation memory C6a built.** Real regression. But "give it a buffer-local slot"
was the *conventional* fix — it keeps authority-bearing state inside the editor's own
value, and P3 governs the ports: scriba's port set already includes the network only
because the orchestrator was never split out.

`docs/live-environment.md` decides this exact case: the environment *"is not an address
space; it is a society of staged runtimes over ports,"* and runtime granularity is
*"read off each thing's type per instance: an AI-orchestrator earns its own node
(authority plus containment), a fontifier does not (empty port set)."* The splitting law
agrees — editor (no network) and chatter (holds a `Backend`) have different port sets,
therefore different types, therefore a **real** split, not a spurious one.

So the fix is **S20b** — but state what it actually buys, at which level, and where it
does not reach (corrected 2026-08-22; the first draft of this said "for free" and
"dissolves", which flattened three different things into one):

1. **Conversation content leaves the editor; a handle does not.** The transcript and
   `ConvState` stop being editor state — that part is real. What scriba must still
   retain across ESC is a **re-attach handle to the node**, which is one value instead
   of a whole transcript. A simplification, **not** "free".
2. **scriba's port set loses the network.** This one is unqualified — the editor stops
   holding `Backend`/network authority. It is the P3 claim actually holding.
3. **`S28` changes shape; the requirement relocates rather than vanishing.** The hard
   half goes: the editor is no longer blocked *inside a crossing it makes*. The
   remaining half stays: the main loop must still poll **two** sources (stdin and the
   node's port) to stay live while work runs — the same `poll.chiral` machinery, aimed
   at a different fd. Cancellation gets genuinely easier (send the node a cancel, or
   simply stop reading) but "async is free now" would be wrong.

**What "its own node" concretely means today (measured 2026-08-22, spec input).** The
*"society of staged runtimes over ports"* is design, not built — there is no actor or
mailbox mechanism anywhere (`\bactor\b`, `\bmailbox\b`: zero files), and "node" in the
tree means AST/doc nodes. What DOES exist and composes into the shape:
- `proc-spawn` (E33, `proc.chiral:124`) — fork+execve+wait4 behind a typed surface with
  a linear Reap obligation. **Single-return**, though: spawn → wait → result. Not a
  long-lived conversational peer on its own.
- `socketpair` (E126, `ports.chiral:91`) — a hermetic pair of **two connected linear
  `Sock` caps**, no network, no listener. This is the missing half: spawn a child
  holding one end, keep the other.
So S20b is buildable from parts that exist. It is not blocked on new substrate — which
makes the linear-handle question below the *only* real obstacle, not one of several.

**⚑ The hard edge S20b inherits — do not spec it without an answer.** A port is a
linear porttype (E137). Holding one across keystrokes is exactly what the current code
had to avoid: `command-loop.chiral:1735` — *"nothing linear is held across a keystroke,
which is precisely what let CHAT become a normal mode instead of a blocking loop."*
Today the chatter dodges this by opening and closing a `Backend` **per turn**. S20b
must answer the same question for a long-lived node handle: an unrestricted
re-attach token (session id) with linearity enforced only at the crossing, a handle
re-opened per interaction, or something else. **This is the design content of S20b,
and it is the reason S20b is not a strictly-cheaper S20.**

S20 stays, scoped down to empty-port-set view state (`Outline`, `Catalog`, scroll).

### Tier B — wire what is already written

986 L of audited code is inert because nothing imports it.

| S# | Element | State | Gate | Size |
|----|---------|-------|------|------|
| **S22** | **`describe-key` / `apropos` / generated `:help`.** `help.chiral` (249 L) already reads `lookup-op` + `lookup-keymap` + `complete`. Today's `:help` is a hand-written static vim reference — it can drift from the registries and has no way to answer "what is this key bound to". | design | S21 | ~60 L of wiring |
| **S23** | **Window tree wiring.** `window.chiral` (400 L, audited, two FIXes applied) is a rect-splitting binary tree over `(Puffer Str)`. It needs a buffer list to point at, a slot in `Scriba`, a render pass over leaves, and split/focus/close keys. | design | S18, S19 | ~200 L (the 400 L tree is written) |
| **S24** | **flook (dired) wiring.** `flook.chiral` (264 L) renders a directory as a typed `(List FileInfo)` puffer. Its three filesystem crossings are `declare`-only stubs — listing needs **E148** (getdents+stat, and `FileInfo` carries size+mtime so stat is not optional), delete/rename need **E149**. | blocked | **E148 + E149** · S19 | ~80 L after the crossings |
| **E148** | **CORE — directory READ: `getdents64` + `stat`.** No enumeration *or* stat crossing exists anywhere in the tree (verified: zero hits in `scaffold/lib/*.chiral`). Also retires the setup library's `index.json` enumeration (`SCRIBA-STATE.md` P4) and `test-runner`'s bundled manifest (`test-runner.chiral:7`). | design | — | ~120 L core |
| **E149** | **CORE — filesystem MUTATION: `unlink` + `rename` + `mkdir`.** Split from E148 on purpose: write authority is its own grant (the T7/T8 cap-splitting pattern), so a directory *viewer* need not hold delete power. | design | — | ~100 L core |
| **E150** | **CORE — own `argv`.** A chirality program cannot read its own command line (`proc.chiral`'s argv is outgoing-only), so every entry point is stdin-driven and `scriba <file>` is not expressible. Not a scriba row — but scriba is its first consumer. | design | — | ~80 L core |

### Tier C — an author decision lands first

| S# | Element | State | Gate | Size |
|----|---------|-------|------|------|
| **S11** | **init-file load** (the row exists since the S-series; the code is a stub — `init-loader.chiral:633` returns `init-default`). What a user's `~/.config/scriba/init.chiral` may change, and by what mechanism. | decide → blocked | **D-S1** · E132 | ~200 L after the decision |
| **S25** | **Hooks / extension points.** Zero occurrences of "hook" in the tree. The idiomatic chirality answer is probably a closed event sum + a handler list in `Scriba`, not emacs advice. | decide | **D-S2** · S18 | ~120 L |
| **S26** | **Edit-stable markers.** `Mark` is a `TextZipper` *snapshot* (`mark-region.chiral:19`); an edit elsewhere in the buffer silently invalidates a stored offset. Emacs markers adjust with insertions. Needed the moment the user layer anchors anything into text (citations, diagnostics, chat references to a file region). | design | S18 | ~150 L |
| **S27** | **Overlays / text properties.** Faces come only from the mode's renderer fn — there is no per-range annotation independent of the renderer, so a surface cannot highlight a span it did not itself render. | design | S26 | ~250 L |

### Tier D — async · LAST, and deliberately so

Async is a different layer: it is the effect substrate (`E42` supervisor, `E31` poll),
not the editor object model. **Nothing in Tiers A–C depends on it, and none of them
get harder if async lands after.** It bites the *experience* of a long model call,
not the *architecture* of the user layer.

| S# | Element | State | Gate | Size |
|----|---------|-------|------|------|
| **S28** | **Interruptible run.** Poll stdin alongside the backend socket inside the run/turn loop so a key can cancel a crossing in flight. Today a `:run`/`:ask`/`:chat` turn blocks the editor entirely — streaming paints tokens but reads no input, and there is no cancel key (verified: zero `read-key`/`poll` in `manas-runview.chiral`). `scaffold/lib/poll.chiral` (E31/T3, N-fd) is built and unused by scriba. | design | S18 | ~150 L |
| **S29** | **Background work + completion into the loop.** ⚑ E42 is **BUILT** (`supervisor.chiral`, v1) — this row is gated on ADOPTING it, not on building it; corrected 2026-08-22. A command that starts work, returns to the loop, and lands its result as an event later — the substrate under "run three skills while I keep editing". | blocked | **E42** (BUILT — `supervisor.chiral` v1; adoption is the gate) · S25 (the event shape) · T9 | large; gated |

### Tier F — rehomed from the E# set (2026-08-21)

Scriba-app elements that were carrying core `E#` numbers. `LEDGER.md §APP` had flagged
them "pending migration to S#" for months; the migration is now executed and the
E-rows are cite stubs. **Both are BUILT** — they are listed for provenance and so the
`S#` space is complete, not as open work.

| S# | Element | State | Was | Note |
|----|---------|-------|-----|------|
| **S31** | Mark + region system | **built 2026-08-14** | E88 | `mark-region.chiral`, imported by `init-loader.chiral:17`, live in the blob; `set-mark`/`kill-region`/`copy-region` registered ops, PTY-verified (SLICES 2). Both catalog rows read `design`/`Not built` until corrected 2026-08-21 |
| **S32** | Effect-chain decoupling (`try-dispatch`) | **built 2026-08-14** | E92 | the op-dispatch indirection the whole command layer rests on |

### Tier E — cheap, after the floor

| S# | Element | State | Gate | Size |
|----|---------|-------|------|------|
| **S30** | **Keyboard macros** — record/replay a `KeySeq` stream. Nearly free once keymaps and commands are both data: it is a list of keys plus a replay driver. | design | S21 | ~120 L |

### Not cataloged — and not phantoms

Deliberately out of scope; named here so a later pass does not "discover" them as gaps:

- **Abbrev / snippets** — an editing convenience with no user-layer dependency.
- **Narrowing** — the port-viewer model makes a narrowed view a different *puffer*
  over the same port, not a mode of one buffer. Revisit only if S19 makes it cheap.
- **Recursive minibuffer edit** — `minipuffer` prompts are already closed sums with
  explicit cancel; recursion buys nothing here.
- **Auto-save / backup files** — belongs with a persistence policy, not the floor.
- **`VimMode` type split** (two-level types) — the ~130-site mechanical split noted in
  `SCRIBA-STATE.md`; **S18 and S20 remove most of its motivation**, so re-evaluate
  after Tier A rather than doing it.

---

## §2b · Environment hazards (measured 2026-08-22 — trust these over intuition)

- **`grep -r` does not follow symlinks; `grep -R` does.** This is standard POSIX
  behaviour, not a broken environment — I first recorded it as "recursive grep silently
  returns nothing in `TUI/`", which was the symptom, not the cause. The foundation
  modules are symlinked, so `-r` skips them: `grep -rl 'data Ord' TUI/` finds nothing
  while `grep -Rl` finds `TUI/samples/collections.chiral`. **Use `-R` or a Python
  file-walk** (which is what `ledger-lint` checks L/M do).
- **⚑ CORRECTED — I had this INVERTED.** I recorded "the local `B1` is one generation
  behind `blob.chiral`". The opposite is true, measured 2026-08-22:
  **`B1(regenerated blob) == scaffold/build/B1`, byte-identical** — the binary is
  current with the *sources*. It is **`scaffold/build/blob.chiral` that is stale**: it
  carries zero occurrences of `kept-tys`/`arm-rw-ctx` while `closconv.chiral` carries 8,
  i.e. it predates the E147 fix. Compiling that stale blob is what produced the
  byte-3040 difference I mistook for a stale binary.
  Consequences: (a) **regenerate the blob before any fixpoint check** —
  `. bin/chirality-resolve.sh; chirality_blob scaffold/lib sys-linkage compile-front
  compile-back compile-emit compile-all compile-driver`, which is **pure shell, no Python**, is a
  post-order DFS over the imports, and reproduces the blob deterministically; (b) the
  fixpoint can then be stated the simple way — *the new compiler reproduces itself* —
  with a clean pre-change baseline; (c) `scaffold/build/` is gitignored, so none of
  this is a repo-integrity problem.
- **This sandbox runs as uid 0, which MASKS permission errors.** Measured 2026-08-22: I proved
  "a chirality program can read its own argv" twice using `open-rw` (`O_RDWR`) on
  `/proc/self/cmdline`, which is mode `-r--r--r--`. As uid 65534 the same call returns **EACCES
  (13)**. The capability claim survived — via `openat` with `O_RDONLY` — but the route I named
  and recorded was wrong, and *running the test twice did not catch it* because both runs had
  `CAP_DAC_OVERRIDE`. **Any probe touching file permissions must be re-run under a dropped uid**,
  or reasoned about from the mode bits.
- **ELF size is NOT a signal that code did or didn't land — the image is zero-padded.**
  Measured 2026-08-22 during E152: adding 66 lines to `collections.chiral` left the
  compiler at exactly **1,024,376 B**, yet **307,039 bytes differ** and real content
  grew 1,021,937 → 1,023,799 B. So "same size" means padding absorbed it, not that the
  code was dropped. I twice read an identical size as evidence (once for the dead
  `puffer` helpers, once for the E151b steps) — those conclusions happened to be right,
  but the reasoning was not. **Compare content, or compare behaviour; never size.**
- **Do not reason about file identity from `stat` or from mutation experiments — use
  `ls -l`.** The shared foundation paths are SYMLINKS. I got this wrong twice: once from
  inode numbers, once by concluding "hardlinks" from a mutation experiment that a
  symlink satisfies equally well. `os.path.realpath` (or `ls -l`) is the direct answer.

## §3 · Decisions owed (block their rows, nothing else)

- **D-S1 — the extensibility model. → RESOLVED 2026-08-22:
  `docs/decision-user-layer-extensibility.md`.** Not a fork. The user layer extends
  **in chirality, live** (code, not data); `E45` freezes *the judgment* — the capability
  kernel — and the user layer sits above that line, so nothing was ever in tension.
  The thesis's own precondition (*"extension-language equals implementation-language
  is only true once chirality is self-hosted"*) was met at the 2026-08-05 fixpoint.
  Consequences: **`S11` stays an init-file loader and is blocked on `E132`** — do NOT
  build a throwaway data-config format; the registries `S18`/`S21` build ARE the seam
  `E132` lands into; saved setups stay data because they *are* data. **Do not
  re-open.** Original framing kept below for provenance:

- ~~**D-S1 — the extensibility model.**~~ Is the user layer *data* (ops, keymaps, modes,
  setups loaded from disk into the registries that already exist) or *code* (chirality
  compiled at runtime and linked into a resident binary, = E132)? This is not a
  preference: `reflect-floor.chiral` (E45) makes post-staging reconfiguration
  **unexpressible by construction** — `freeze : (1 b SigB) -> Frozen`, no writeback.
  Emacs's "redefine anything, live" is the opposite stance. The compatible reading is
  that the *judgment* is frozen while the *user layer* is data over registries. Decide
  explicitly, in writing, before S11 is specced.
- **D-S2 — the hook shape. → MERGED INTO D-S1 (2026-08-22).** Minting this separately
  was a **false split: a hook IS extensibility**, a different feature reaching the same
  effect, and deciding the two apart invited two mechanisms where one belongs. See
  `docs/decision-user-layer-extensibility.md` §"Hooks are not a second mechanism":
  advice dissolves into re-registration; the only thing a hook adds over that is
  *plurality* (N observers without one owning the command), so it is a handler list
  plus a closed event sum, not a mechanism. **`S25` is the observation half of the one
  extension model**, not a rival to it.

- **D-S3 — does `chat` retire into the buffer list? → RESOLVED YES (user, 2026-08-21).**
  Chat becomes an ordinary buffer: a `type-name`, a mode, an entry in the buffer list,
  its `ChatView`+`ConvState` in the S20 buffer-local slot. The distinguished
  `(Maybe (Puffer Str))` slot dies with S19. **Do not re-open.**

---

## §4 · Build order — the checklist

> **⚑ This is the scriba-lane order. The CROSS-LANE order — where these rows sit
> relative to the stdlib elements (E150–E152), the mechanism fixes (E154/E155), and
> async — is `.planning/BUILD-ORDER.md`.** Notably: **E151/E152 land BEFORE S18**,
> because S18–S24 will otherwise re-write sort and string ordering locally, which is
> exactly how the altitude leak happened the first time.

Serial. Each row: build → B1 rebuild → PTY-verify → commit before the next.

```
[ ] D-S3   decide: chat becomes an ordinary buffer?            (writing, ~30 min)
[x] S18    Scriba editor-state record   BUILT 2026-08-23 (5a88be3 + 130062f)
[ ] S21    : command registry
[ ] S19    buffer list + switching
[ ] S20    buffer-local state slot                             ← restores ConvState across ESC
[ ] S22    describe-key / apropos / generated :help
[ ] S23    window tree wiring                                  ← 400 L already written
[ ] E148   getdents64 crossing (CORE)
[ ] S24    flook wiring                                        ← 264 L already written
--- the floor is done here; the user layer can be built additively ---
[ ] D-S1   decide: extensibility model (vs E45 / E132)
[ ] D-S2   decide: hook shape
[ ] S25    hooks / extension points
[ ] S26    edit-stable markers
[ ] S11    init-file load                                      (gated on D-S1 + E132)
[ ] S27    overlays / text properties
[ ] S30    keyboard macros
--- async, as its own arc ---
[ ] S28    interruptible run (poll stdin beside the socket)
[ ] S29    background work + completion events                 (gated on E42)
```

**S21 before S19** is deliberate: the registry is what buffer-switching commands get
registered *into*, and doing it second means writing them twice.

---

## §5 · Acceptance — how we know the floor is done

The floor is finished when **adding a new user-layer surface touches exactly two
things: one registry row and one new module.** Specifically, adding a surface must
require:

- **zero** new `command-loop-inner` arms,
- **zero** new `VimMode` variants,
- **zero** new threaded parameters,
- **zero** edits to the `:`-command dispatch.

Today, adding one surface costs an arm in a 4,000-char nested `case`, a `VimMode`
variant to smuggle its state, and — if it needs anything the loop does not already
carry — 74 signature edits. That delta is the whole point of this checklist.

Per-row gates are the usual ones: a mesh-free unit test with real assertions, a
`bin/scriba` build that compiles clean, and a PTY run proving the behavior end to end.
Rows that change a `Flow`/`PureFn` constructor require a scriba recompile
(`flow-view.chiral` has an exhaustive `Flow` case).

---

## §6 · Pipeline discipline

`S#` rows follow the repo pipeline where the row warrants it —
**example → audit → spec → audit → implement** — but scriba slices have historically
gone spec-first (`.planning/specs/S1,S2,S13–S17`), which is right for rows whose
design content is low (S18, S22, S23, S24, S30 are mechanical). Rows with real design
content — **S20, S25, S26, S27, S29** — should get a written spec before code.
`E148` is a core crossing and takes the full `E#` pipeline with a web-verified ABI
(`getdents64`, nr 217, linux_dirent64) per the standing "verify blackbox/ABI facts
against sources, never from memory" rule.

## §7 · Sibling axis — the language, not the editor

Missing **language/stdlib** primitives are a different lane and live in
`.planning/LANGUAGE-INVENTORY.md` (minted the same day): the 32-extern floor, what the
88 lib modules do and don't cover, and the six elements minted from it — E148/E149
(fs read/mutation), E150 (argv), E151 (string stdlib, retiring 4 duplicate `str-cmp`
defs), E152 (sort), E153 (the `F64` float tower). The user layer will reach for those
independently of anything in Tiers A–D above.

## §8 · Anchors

⚑ **The layer ABOVE this floor is `.planning/USER-LAYER-GAP.md`** (minted 2026-08-30,
lane `U#`): the editor / document / knowledge-base / agenda surfaces this checklist's
§5 acceptance test exists to make cheap. It assumes every row here is done and does
not restate them. `S#` stays this file's number space; `U#` is that one's.

`.planning/SCRIBA-STATE.md` · `.planning/SCRIBA-SLICES.md` (S1–S17) ·
`.planning/CHATTER-STATE.md` · `.planning/LEDGER.md` §Z + SYS (E148) ·
`.planning/SELF-IMPLEMENT-CATALOG.md` (E42, E45, E132, E148) · `TUI/CATALOG.md` (T3,
T9, T18, T19) · `TUI/PRIMITIVE-AUDIT.md` (the substrate below this floor) ·
`docs/live-environment.md` (the cockpit thesis D-S1 must answer to).
