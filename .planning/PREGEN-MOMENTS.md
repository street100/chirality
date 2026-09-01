# pregen moments — where pregeneration earns its keep

**2026-08-06**
**Research against:** `scaffold/chirality/optimize.py`, `docs/modules-staging.md`,
`scaffold/bench/TRAIT-OPTS.md`, `scaffold/bench/OPT-LEDGER.md`, `scaffold/bench/OPTIMIZATIONS-TODO.md`

---

## Current state

| Primitive | Status | What it does |
|-----------|--------|-------------|
| `specialize(fn, bindings)` | **BUILT** | Bind static args → residual. Preserve-checked. The pregen primitive. |
| `autospec` (auto-pregen) | **BUILT** (bounded) | Const-arg call sites → specialized residuals. Recursion guards, size caps (<48 instrs), 3 cascade rounds, D-2 deterministic. |
| `fold` (const-fold) | **BUILT** | Arithmetic collapse + dispatch-on-known-constructor |
| `dead` (DCE) | **BUILT** | Drop pure unused instructions |
| Stage (binding-time spine) | **GAP** | Assign each computation a stage (compile/init/runtime). Gating decision. |
| Pregen cache/library | **GAP** | Serialize residuals, cache them, ship as deterministic pattern library |
| Link-and-load | **GAP** | Install generated code into running process |
| Fact-carrying lowering | **GAP** | Refinement + quantity facts survive into tal — the architectural prize |

---

## The pregen pattern — where it applies

The pattern is: you have a function `f(config, input) → output` where `config`
is known at compile/init/link time but `input` is runtime. `specialize(f,
{0: config_value})` produces a residual `f_specialized(input) → output` where
every decision gated on `config` is folded out.

This is the Futamura projection: a program that interprets a static
configuration becomes a program that IS that configuration.

### Category 1 — static dispatch tables

Any function that pattern-matches on a static table and dispatches:

```chirality
; Before — generic dispatch
(def dispatch (-> Key (Map Key Op) (Puffer A) (Puffer A))
  (lam (key keymap puf)
    (case (map-lookup keymap key)
      ((some op) (op puf))
      (none puf))))

; After pregen — keymap is static, dispatch IS the keymap
; specialize(dispatch, {1: scriba-keymap}) produces:
(def dispatch-scriba (-> Key (Puffer A) (Puffer A))
  (lam (key puf)
    (case key
      ((k-char 102) (forward-char puf))      ; f
      ((k-char 98)  (backward-char puf))     ; b
      ((k-char 110) (next-line puf))          ; n
      ((k-char 112) (previous-line puf))      ; p
      ...
      (_ puf))))
```

**Where this lives in scriba:**
- S3 command loop — `dispatch(key, keymap, puffer)` with static keymap
- S2 renderer lookup — `lookup-renderer(registry, type-name)` with static registry
- manas coordinator — tool dispatch with static tool table
- HTTP routing — route dispatch with static route table
- Any FSM — `step(state, event, transition-table)` with static table

**The chirality module that makes this ergonomic:** a `pregen/dispatch.chiral` module
that provides `specialize-dispatch` — given a function and a static table, produce
the residual. The table is a `(Map Key Op)` and the residual is a `case` tree.

### Category 2 — static data constants

Any computation where large portions of the input are constants known at
compile time:

```chirality
; ELF header writer — 120 bytes of mostly-constant header fields
; specialize(elf-write-header, {entry: 0x4000, arch: x86-64, ...})
; produces a residual that just writes the 120-byte header, no branching
```

**Where this lives:**
- E34 ELF writer — header fields are compile-time constants
- PNG writer — IHDR chunk is fixed for test output
- scriba ANSI escape sequences — color table is static, escape codes are static
- scriba mode line — format string is static, values are dynamic

**The module:** `pregen/data.chiral` — given a function that constructs data from
a mix of static and dynamic inputs, specialize on the static subset to produce a
residual that just writes/allocates.

### Category 3 — configuration-driven code generation

Any time you generate code from a declarative spec:

```chirality
; scriba init file: (bind-key "C-x C-f" find-file)
; (bind-key "C-x C-s" save-puffer)
; ...
; Pregen: the init file IS a pregen spec. Compile the init into a residual
; command loop that has all user keybindings folded in.
```

**Where this lives:**
- S11 init loader — the init file defines static keybindings, renderers, ops
- manas pipeline config — which models to use, what order to run them
- Any "configure then run" pattern

**The module:** `pregen/config.chiral` — takes a config value and a program
parameterized by config, produces a residual specialized to that config.

### Category 4 — type-driven code generation

Where the type of a value determines what code runs:

```chirality
; A generic pretty-printer: (pretty (0 A (type 0)) (-> A Str))
; Specialize on A=Json → residual that knows the Json constructors
; Specialize on A=(List FileInfo) → residual that knows FileInfo layout
```

**Where this lives:**
- Pretty-printers (E14)
- Serializers (JSON, wire format)
- Renderers (any `A → Rendering` can pregen on A's structure)

**The module:** `pregen/type-directed.chiral` — given a type and a generic
function over that type, specialize to the type's constructors.

---

## The natural pregen library

Four modules that make pregen a first-class workflow rather than a compiler
internal:

### `lib/pregen/dispatch.chiral`

```chirality
; Given a static map and a generic dispatch function, produce a case-tree
; residual. The map keys become case patterns; the values become the arms.
(declare specialize-dispatch
  (-> (0 K (type 0)) (0 V (type 0))
      (Map K V)                           ; static
      (-> K V (Puffer A) (Puffer A))      ; generic dispatch
      (-> K (Puffer A) (Puffer A))))      ; residual: key → handler
```

For scriba: `(specialize-dispatch Key Op scriba-keymap generic-dispatch)` produces
the command loop's dispatch table as a `case` tree. At init time. Once.

### `lib/pregen/data.chiral`

```chirality
; Given a data constructor function and the static arguments, produce a
; residual that allocates/writes only the dynamic parts. The static parts
; are folded into the allocation.
(declare specialize-data
  (-> (0 A (type 0))
      (List I64)                          ; which args are static (by index)
      (List A)                            ; their static values
      (-> ... A)                          ; generic constructor
      (-> ... A)))                        ; residual: takes only dynamic args
```

For scriba: the mode line format is static ("-U:** %s All (%d,%d) (%s)"). The
values are dynamic. Pregen folds the format string into the render function.

### `lib/pregen/config.chiral`

```chirality
; Given a config value and a program parameterized by it, produce the
; specialized residual. This is the "configure → compile → run" pattern
; made explicit as a type.
(data Configured (C (type 0)) (P (type 0))
  (configured
    (config C)                            ; the static config
    (program (-> C P))                    ; the generic program
    (residual P)))                        ; specialized(program, {0: config})
```

For scriba: `(Configured ScribaConfig CommandLoop)` — the init file produces a
`ScribaConfig`. `configured` specializes the command loop on it. The residual IS
the running editor.

### `lib/pregen/cache.chiral`

```chirality
; A persistent cache of pregenerated residuals, keyed by (fn-name, bindings).
; Lookup is O(1) via a Map. On miss, specialize and store. On hit, return
; the cached residual. The cache is deterministic (D-2): same inputs → same
; artifact, same hash.
(declare pregen-cache
  (-> (Map (Pair Str (List I64)) TIFn)    ; the cache
      Str                                 ; fn name
      (List I64)                          ; static arg values
      TIFn                                ; generic fn
      (Pair (Map ... TIFn) TIFn)))        ; updated cache + residual
```

This is the OPT-LEDGER item #19's "deterministic pattern library (D-2)." The
cache lives in `~/.cache/scriba/pregen/` or is embedded in the binary. Residuals
are named by `(target, binding-hash)` so Stage1==Stage2 byte-identity holds.

---

## Where pregen earns its keep in scriba — ranked by impact

### Rank 1 — Command loop dispatch

**What:** `dispatch(key, keymap, puffer)` with a ~100-entry static keymap.

**Without pregen:** Map lookup per keystroke. O(log n) or O(n) depending on map
implementation. 100+ keys checked per keystroke.

**With pregen:** The keymap IS the dispatch function. `case` tree over `Key`
constructors. O(1) per keystroke — it's a jump table. The compiler folds the
entire map into the code.

**Lines to enable:** ~30 (specialize-dispatch call at init time)
**Payoff:** every keystroke for the life of the editor. This is the single
highest-leverage pregen moment.

### Rank 2 — Renderer registry

**What:** `lookup-renderer(registry, type-name)` called on every render frame
(up to 60fps).

**Without pregen:** Linear scan or alist lookup per frame per window.

**With pregen:** `(case type-name ("Str" str-renderer) ("(List FileInfo)"
dired-renderer) ...)` — constant-time dispatch per frame.

**Lines to enable:** ~20
**Payoff:** every frame, forever.

### Rank 3 — Static ANSI escape sequences

**What:** Color codes, cursor positioning, clear-screen, box-drawing characters.
These are string constants. The rendering engine emits them by composing static
format strings with dynamic values.

**Without pregen:** String concatenation at render time. `(bcat CLEAR_SCREEN
(bcat MOVE_CURSOR ...))`.

**With pregen:** The format string IS the code. `(put CLEAR_SCREEN)` is one
instruction, not a concat. The color table becomes immediate SGR sequences.

**Lines to enable:** ~40 (specialize-data for the ANSI module)
**Payoff:** every render frame, every ANSI escape.

### Rank 4 — Init file compilation

**What:** `~/.config/scriba/init.chiral` defines keybindings, renderers, ops.
Currently loaded as chirality source and interpreted.

**With pregen:** The init file IS a pregen spec. The startup sequence:
1. Compile init.chiral → ScribaConfig value
2. Specialize command loop on config → residual
3. The residual IS the running editor — no interpretation, no runtime lookup

**Lines to enable:** ~50 (configured + specialize-dispatch)
**Payoff:** startup time, every keystroke. The config doesn't just configure —
it becomes the program.

### Rank 5 — Type-directed renderer generation

**What:** `str-renderer`, `dired-renderer`, `json-tree-renderer`. Each is a
generic function over a type.

**With pregen:** `specialize(str-renderer, {0: Str})` — the fact that the type
is `Str` is static. The generic "is it a Str? is it a List?" checks fold out.
The residual IS the Str renderer, no type dispatch.

**Lines to enable:** ~30 (specialize-type-directed)
**Payoff:** once per renderer, at init time. But the residual is smaller and
faster.

---

## What's blocking (honest)

1. **Stage (binding-time spine) is a design gap.** The compiler needs to know
   what's compile-time vs init-time vs runtime. Currently it's all one phase.
   `specialize` works on explicit bindings but there's no type-level distinction
   between "this argument is static" and "this argument is dynamic."

2. **The pregen cache is in-memory only.** No serialization. Residuals die
   with the process. A persistent cache (`~/.cache/scriba/pregen/`) would
   survive across sessions. Needs a serialization format for TAL functions
   (the OPTIMIZATIONS-TODO mentions rd-packed's certificate format as the
   pilot).

3. **Fact-carrying lowering is the architectural prize.** Refinement facts
   (bounds, nonzero, alignment) surviving into TAL unlocks the next tier of
   pregen: bounds checks that fold out because the type proves the index is
   in range. Without this, pregen only folds what's statically obvious.

4. **The unbounded pregen policy is gated on the staging modality (Fork C).**
   Current autospec is bounded (max 48 instructions, no self-recursion). For
   pregen to be fully general, the compiler needs to decide "this is worth
   specializing" vs "this would blow up code size." That's a design decision,
   not an implementation gap.

---

## What to build now (pregen modules that don't need the gaps closed)

Four modules that can be built today on the existing `specialize` + `autospec`:

| Module | What it does | Lines | Gated on |
|--------|-------------|-------|----------|
| `lib/pregen/dispatch.chiral` | Static map → case tree | ~50 | nothing |
| `lib/pregen/data.chiral` | Static struct fields → direct write | ~40 | nothing |
| `lib/pregen/config.chiral` | Config value → specialized program | ~40 | nothing |
| `lib/pregen/cache.chiral` | In-memory cache of residuals | ~30 | nothing |

These make pregen ergonomic. They're pure chirality — no new crossings, no compiler
changes. They call `specialize` (which exists in Python; the chirality port is E17)
and wrap it in a clean API. When E17 lands as chirality-in-chirality, the modules switch
from Python FFI to native.

The big payoff: scriba's command loop dispatch. `specialize-dispatch` with the
static keymap. That one call makes every keystroke O(1) instead of map-lookup.
~30 lines of chirality, zero new infrastructure.
