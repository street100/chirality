<!-- Curated chirality reference for the worked-example pre-run. Dense on purpose:
this REPLACES per-run grepping of glossary.md / PRINCIPLES.md and reading a
lib/*.chiral style file. If a specific fact you need is missing, grep for just
that one fact — do not read those files in full. -->

# chirality idioms & vocabulary (worked-example reference)

## Surface syntax (S-expressions)
- `(import "prelude")` — pull a lib.
- `(data Name ((A (type 0))) (ctor1 (field T) ...) (ctor2 ...))` — a closed sum;
  params are QTT-annotated binders. Exhaustive `case` is coverage-checked.
- `(declare name TYPE)` then `(def name TYPE (lam (a b) BODY))` — or
  `(def name (lam (a b) BODY))` with the type inline.
- `(case scrut (pat BODY) ((ctor x y) BODY) (nil BODY))` — pattern match.
- `(let ((x v) (y w)) BODY)`, `(the T expr)` (type ascription).
- Comments start with `;`.

## QTT quantities (the usage semiring on every binder)
- Binder shape `(q x T)`: `q = 0` erased (compile-time only, no runtime use),
  `q = 1` linear (used exactly once — resources, capabilities), otherwise
  unrestricted (write `(x T)` or `(w x T)`).
- Type params are almost always erased: `(0 A (type 0))`.
- Linear resource: `(1 c Sock)` — must be consumed exactly once; the checker
  rejects drop or reuse. This is how chirality makes "use-after-free" untypeable.

## The effect membrane (the load-bearing chirality idea)
- Two typed facets (`decision-effect-facets`, 2026-07-21): **possession** =
  linear port values held; **exercise** = the effect row, the crossings a term
  performs (inferred from the call graph; `->` = empty row, `=>` = nonempty).
  Holding ≠ crossing: pure code may transport/repack ports (the `RecvR`
  pattern) without crossing.
- Signature: `(-> (0 A (type 0)) A (List A))` pure; `(=> (1 c Sock) Bytes Unit)`
  process. Purity is a *typed fact* — an empty row, provably no crossing.
- Every crossing takes its capability as a parameter (ambient externs like
  `print`/`time-mono` are being reified behind Console/Clock/Env caps).
  Authority = the set of ports held; crossings ⊆ caps-in-scope holds by
  construction. No ambient authority.
- Alarms + counter effects are crossings (`halt` is an ordinary extern).
  Handlers = the process at the other end of the port; a captured
  continuation's resumption multiplicity is its QTT quantity (captured linear
  ports ⇒ one-shot); abort = synthesized cancel closing the captured inventory.

## Errors are values, not control flow (ties E26 alarms)
- No exceptions. A fallible op returns an explicit result sum:
  `(data PR () (p-ok (v X) (pos I64)) (p-err (msg Str) (pos I64)))`, and the
  caller must `case` on it. The error path is in the signature.

## Boundary sums: parse once, reasons as values (STANDING DIRECTIVE — apply as much as physically possible)
- When a boundary classifies something (an op name, a skip reason, a syscall
  result, a request kind), retype the classification as a **closed sum at the
  boundary** and pass the VALUE downstream — never a `Str` tag, sentinel int,
  log line, or re-check. Downstream code then cases totally: no defensive
  halt, no drift between producer and consumer, and pure code STAYS pure
  (a lookup that can't fail needs no effect row).
- The precedents to mirror (`docs/pattern-boundary-sums.md` for the full
  reference): the closed `Op` sum — op names parsed ONCE at the erase
  boundary, which deleted the "unknown prim" halt and kept `op-bytes`/
  `emit-instr` off the effect membrane (E70; mach-x64.chiral:166-168); `SkReason`
  — a lowering skip carries `(sk-extern op)` / `(sk-callee name)` instead of a
  discarded string, so the blame chain exists at the entry gate BY
  CONSTRUCTION (E97); crossing results as errno-or-value sums
  (`WinsizeR`/`TermiosR`/`RawR`, term.chiral) instead of sentinel returns.
- The test: if a `Str`/`I64` in a signature encodes WHICH-OF-N-THINGS, it is a
  sum wearing a disguise — mint the sum. If information exists at point A and
  is re-derived or absent at point B, carry it as a field instead.

## Totality
- Functions are total: structural recursion on a decreasing argument, or a
  numeric measure. No unbounded `while`. "Ran out of input" is a returned
  `*-err`, never a throw or a hang.

## Refinement types
- `(refine I64 (>= 0) (< 64))` — an I64 with proven bounds; `(refine I64 (<> 0))`
  — a nonzero divisor. Predicates are decided by the refinement engine (E9).
  The legal operators are exactly `>=` `>` `<=` `<` `<>` (refine.py `_OPS`);
  there is no `/=` or `!=`.

## The floor: I64 + Bytes, no floats
- **No floats cross the seam.** Everything numeric is `I64` (two's-complement,
  wrapping). Embeddings/similarity/loss stay outside; they cross as ids/`Str`.
- `Bytes` = `[len][payload]` cells; ops `blen`/`bget`/`bslice`/`bcat`, `Str`
  via `str->bytes`/`bytes->str`. I64 ops: `=i` `<i` `<=i` `+` `-` `*`,
  `and`/`or`/`not`, `if`.

## Categories (how real a construct's typing is)
- **A, typed** — correctness by proof (the kernel's judgment).
- **B, untyped** — substrate the language cannot type (raw syscalls, the arena).
- **C, bridge** — a typed module over an untyped referent, governed by evidence
  (e.g. a loader that wraps `mmap`). Most REPLACE-CRUTCH work lands here.

## Kinds (from the catalog)
- **SELF-HOST** — host Python that must become chirality source (shrink the TCB).
- **REPLACE-CRUTCH** — a CPython/ctypes/libc convenience to shed.
- **BUILD-PROPER** — a designed feature not yet built.

## Style: real snippets read like `lib/fsm.chiral` / `lib/json.chiral`
- `data`+`case` state machines, QTT-erased type params, `->` throughout,
  result sums for parsers, structural recursion with a reversed accumulator
  flipped once. Keep the snippet a **skeleton** (declare the helpers, define the
  spine); elide mechanical byte-loops with a `; …` comment.

## Authoring: estimates are frozen, then annotated (not overwritten)
- An example is the FROZEN RATIONALE tier, so a size/count projection (`≈ 80 L`,
  `~20 fields`) stays as the prediction it was. When the real figure is known,
  leave the estimate standing and add a dated note beside it: the measured
  number, the command that produced it, and where the maintained figure lives
  (catalog / LEDGER / bank). The prediction-vs-outcome delta is calibration data
  about our own estimating; a bare stale estimate is not, because an implementer
  copies it. Pattern: `E166-mach-c.md` §5 + §6.
- A claim that is simply WRONG (not a prediction) is a different repair:
  strike the original through, state the measured truth, and say when and how —
  `E166-mach-c.md` §2 finding 1.
