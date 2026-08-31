# chirality scaffold

The stage 9 host-language scaffold, pulled forward (2026-07-05) so the
`docs/target-tomodachi.md` target can run before self-hosting. Python because
the sandbox has no other toolchain and the stdlib covers unix sockets with
fd-passing, memfd, and mmap; the scaffold is throwaway by design (stage 9 ends
by tearing it out), and the real backend remains "own typed backend, no compile
to C" per `docs/decision-backend.md`.

The scaffold is structured after the design's own module architecture, not for
implementation convenience. The kernel is the minimal trusted core; everything
else attaches through named seams.

## The modules, mapped to docs/module-map.md

Host side (`chirality/`):

| design module | file | what it is here |
|---|---|---|
| (syntax) | `terms.py` | the pure syntactic layer beneath the kernel: term constants and the de Bruijn walkers (`uses_below`, `shift_close`). Depends on nothing; syntax below judgment |
| kernel | `kernel.py` | the QTT judgment core only: eval, conversion, subtyping, inference/checking, reify, install. Seams: term-former handlers (`sig.ext_check/ext_eval`), judgment rules (`sig.rules`), and value-form hooks (`check/subtype/conv/quote_hooks`). It does not know what a constructor, an effect, a port, or a refinement is. Depends only on `terms.py` |
| (display) | `pretty.py` | the term/value printer, reached only when the kernel raises an error. Not trusted: a bug here changes a message, it cannot make an ill-typed program check |
| types | `data.py` | parametric data, constructors, case, exhaustiveness; registers its handlers and its linear-kind contribution through the seams |
| effects | `effects.py` | the membrane rules, consulted at exactly three judgment points: application, binder formation, erased positions. One coarse bit (pure/process) instead of the algebra, but placed where the algebra goes |
| refinement | `refine.py` | refinement types (base narrowed by a decidable predicate) behind the value-form hooks; I64 constant-bound fragment (sound + complete) plus a symbolic slice `v<n` over in-scope variables (sound, path-sensitive) |
| surface | `sexp.py`, `surface.py` | s-expression surface and elaborator (real surface is stage 4) |
| bridges (C floor) | `impl_ports.py` | host bindings for the port and process externs |
| (A floor) | `impl_pure.py` | host bindings for the pure externs |
| bridge connector (inbound) | `bridge.py` | every value a host binding returns is verified against the extern's declared type at the crossing; a lying implementation is a membrane alarm, not a crash downstream |
| lowering connector | `lower.py` | compiles the eligible pure fragment to tal, then discharges its obligation with the preserve-check: the tal checker re-checks every compiled body against the tal image of its declared type |
| tal (the floor) | `tal.py` | typed assembly at scaffold scale: a register IR whose every instruction is typed, its own checker independent of the kernel, and the interpreter that is the trusted drop |
| runtime | `runtime.py` | evaluator with tail-call iteration; links externs to bindings at load (the staging story's link step, in miniature); executes lowered functions on the tal machine under `MET_TAL=1` |
| — | `alarms.py`, `cli.py` | shared alarm exceptions; check/run/verify/lower commands |

Language side (`lib/`, `demo/`): the primitives are declared **in chirality
source**, not in python. `lib/prelude.chiral` is the category A floor (data
types plus pure externs); `lib/ports.chiral` is the category C floor
(`porttype Sock/Fd/Pool` as opaque linear atoms, every port and process
crossing as a typed `extern`, including `halt`, the fatal alarm counter
effect). The host implements against these declarations and `run` fails at
link if an extern has no binding. `lib/wire.chiral` (Wayland codec) is pure A
code. `demo/` holds `mood`, `behavior` (the swappable pack, pure by type),
`sprites`, `tomodachi`, and `profile-tomodachi.chiral`.

## The orchestration substrate (manas layer)

A general, Lisp-machine-like orchestration module set sits on top of the floor —
the reusable capabilities an app needs to drive local models over HTTP. manas is
one *conformance profile* of it, not the reason it exists. **Full reference and
the manas-agent handoff contract: [`docs/orchestration.md`](orchestration.md).**

| module | what it is |
|---|---|
| `lib/collections.chiral` | list / `Maybe` / association-list combinators (`map-list`, `foldr`, `find`, `cat-maybes`, `maybe-then`, `str-join`, …) |
| `lib/json.chiral` | JSON parse + serialise; escapes, raw UTF-8, `\u` surrogate pairs; `obj-get`/`as-str`/`as-arr` accessors |
| `lib/http.chiral` | `http-request` (`=>`), transport-failure-as-data, and a pull-based streaming port (`ChatStream` / `chat-open`/`read`/`close`) |
| `lib/fsm.chiral` | a general Mealy machine (`Step`, `run-fsm`) with early-halt; the cycle's control spine |
| `lib/backend.chiral` | the replaceable model-backend seam — OpenAI-compatible (`be-chat`, `be-chat-stream`, `be-health`, `be-models`, `be-embed`, `be-search`) |
| `lib/manas.chiral` | the conformance profile: a circuit-breaker cycle + headless batch driver (worked example of composing the above) |

Two surface-layer ergonomics land with it, both zero-kernel-change: **`cond`**
(`(cond (c e)… (else z))` desugars to a nested Bool `case`) and
**`tools/balance.py`** (a paren-balance checker that localises the `))))` miscount
to a line). Orchestration modules are tested against mock backends injected at the
extern seam (`runtime.IMPLS`), never a real model.

## Profiles and targets (G9 in miniature)

A profile is an import manifest plus a frozen port set plus the target it
must satisfy; conformance is type-checking:

    python3 -m chirality verify demo/profile-tomodachi.chiral
    -> profile tomodachi: VALID (target tomodachi: 8/8; port set: respected; memory: linear)

A requirement is a named crossing at a named type, judged by subtyping. The
port set freezes which crossings the composite may use: `used_ports` walks
every definition, and a port outside the set names the defs that touch it.
Four profiles ship, all over the same module base: `profile-tomodachi`
(single runtime; `time-mono` deliberately outside its set), `profile-headless`
(the behavior pack driven from an event list; two ports only), and the two
node profiles below with complementary sets. The behavior-pack requirements
are pure arrows, so confinement (a pack cannot touch a port) is part of the
target itself.

## Multiple runtimes (the node model in miniature)

`demo/node-sensor.chiral` and `demo/node-render.chiral` split the tomodachi
into two runtimes: the sensor holds the niri port and the behavior pack and
offers a listening port; the renderer holds the compositor port and the pool
and connects. Moods cross between them as `mood-name` lines: a remote node is
just a node you hold a port to. Their profiles are complementary by
construction: the sensor's frozen set has no pool and no fd-passing (it
cannot draw); the renderer's has no listen/accept (it cannot offer a door)
and it imports no behavior. `tests/test_nodes.py` runs both against the
mocks: events flow niri -> sensor -> renderer -> frames.

## Staging as a language operation (spawn)

Runtimes are not only assembled by a human running the CLI twice: staging is
a crossing of the language. `spawn : (=> Str Sock)` stages the profile at a
path into a new runtime and returns the one linear port to it; consuming the
port is the teardown (spawn = stage, teardown = move, per
docs/process-and-runtime.md). The staged side self-verifies before running:
its profile must be valid (target satisfied, port set respected) and it must
provide `node-main : (=> (1 peer Sock) Unit)`, the typed entry the port is
handed to; a refused staging reaches the parent as the port closing.
`demo/duo.chiral` is the whole two-node tomodachi from one command: the
sensor stages its own renderer. And because spawn is an ordinary extern,
who may create runtimes is governed like any crossing: it sits in the
profile's frozen port set or that profile cannot stage anything.

## Memory disciplines (one substrate, chosen per profile)

The memory model's flexibility is composition-time: a profile picks its
allocation discipline the way it picks any module, and the runtime stays
anti-flexible (no allocator, size in the type, conservation by linearity —
docs/memory-model.md). The scaffold shows this with two discipline libraries
over the *same* substrate, the value-indexed linear `(Pool n)`:

- `lib/mem-linear.chiral` — write at explicit offsets, close once; adds nothing
  over the pool but a name.
- `lib/mem-region.chiral` — a bump-allocated arena: a linear `Region` wrapping
  the pool and a cursor, `mem-alloc` advancing it, the whole arena freed as a
  unit. No kernel feature, no collector, no runtime allocator.

A profile carries an optional `(memory <discipline>)` clause that `verify`
reports; an unknown discipline is a surface error. Two honesty limits: the
erased bound cannot be read at runtime, so the region carries a runtime
capacity witness and over-capacity is a `halt` alarm (not an allocator saying
no); and this region *library* is not the deferred **region types** feature —
it is linear + ω code, and region types (which would carry the cursor in the
type) remain deferred. A pool *offset*, though, is now compile-time checkable:
`mem-put-checked` refines the write offset to `{I64 | >= 0, < n}` against the
pool capacity, so a provable offset (a literal or one guarded into range) needs
no runtime bound check — the offset half of F8. The raw `mem-put`/`pool-write`
stays for a computed offset the constant/variable fragment cannot yet prove.
`tests/test_memory.py` type-checks both disciplines over the one substrate,
exercises the profile clause, the offset bounds, and runs the arena for real. `fd-close` was added to the port floor so
a pool kept local (a scratch region, never shared) can discharge its memfd —
previously only `sock-send-fd` could.

## De-Pythoning, milestones 1-4: the emitter is chirality, the code is native

The trusted drop below tal was a Python interpreter (`TalMachine`). It no
longer has to be. The emitter is chirality and produces real machine code that
runs on the CPU; `chirality/native.py` shrinks Python to a shuttle (tal.TalFn ->
the `TFn` chirality value) plus a loader (mmap RWX + ctypes, the few lines a
syscall milestone removes). The codegen itself is the language.

The backend is split the way the design splits everything: a
target-independent core over a frozen interface, and conforming
implementations behind it (a target is a conformance obligation, not a
configuration).

- `lib/mach.chiral` — the `Mach` interface: ten operations (prologue, spill
  param, load arg, const, tag, binop, call, ret, load-scrutinee, cond-jump).
  A target is a value of this type, nothing more.
- `lib/emit-core.chiral` — tal -> a machine's operations. This is the whole
  codegen (frame layout, argument marshalling, case dispatch, self-calls) and
  it names no register and no opcode; a grep test asserts it mentions no ISA
  token at all.
- `lib/asm-reloc.chiral` — target-independent relocation: an `Asm` stream of
  bytes/labels/relocations, two-pass placement and resolution, each
  relocation carrying its own size and encoder function.
- `lib/mach-x64.chiral` — x86-64 as one conforming `Mach`: all the
  instruction-set knowledge the backend has lives in this one file
  (SysV amd64, the memory-machine strategy of every register in a stack slot,
  rax/rcx scratch). `lib/emit-x64.chiral` is now a four-line shim binding
  `emit-core` to it.
- `lib/mach-listing.chiral` — a second conforming `Mach` that emits a readable
  listing instead of bytes. It exists to prove `emit-core` is genuinely
  target-independent: the identical codegen drives it unchanged.

    python3 -m chirality check lib/emit-core.chiral    # the codegen type-checks
    # tests/test_backend.py drives both machines through the one emit-core
    # tests/test_native.py runs the x64 path and executes the output

`tests/test_native.py` is the proof: every lowered tomodachi function in the
native subset is compiled by the chirality emitter and its result differentially
checked against `TalMachine`, plus recursion (`fib`) and the boxed-data suite.

Milestone 1 was the heap-free fragment: I64 and all-nullary "enum" data
(both a single machine word), arithmetic, comparison, direct calls, case,
recursion. `(declare name ty)` was added to the surface for the mutual
recursion the emitter needs (`emit-code`/`emit-branches`).

Milestone 2 spends the memory decision the discipline work settled: **data
with fields is boxed** — a pointer to a cell `[tag][field0]…` bump-allocated
from an arena; the region discipline of docs/memory-model.md, at the metal.
The representation is static because tal is typed (no runtime tagging): enum
types stay immediate, any type with a fielded constructor boxes uniformly
(its nullary constructors too). The `Mach` interface grew the heap face —
`alo` (allocate + store tag/fields), `fld` (bind a field at branch entry),
`lsb` (dispatch on a boxed scrutinee's tag), `fin` (once-per-program trailing
material) — and both machines conform: x64 emits RIP-relative bump sequences
against `heapptr`/`heapend` cells the loader points at a fresh RW arena; the
listing renders `alloc tag`/`r0.1` lines, proving the heap decisions live in
`emit-core`, not the target. Arena exhaustion is a `ud2` fault — the arena
alarm that refuses to corrupt.

Milestone 3 is variable-length data: a Str/Bytes value is one word, a
pointer to a `[len][payload]` cell — literals in a labeled data section
after the code, fresh cells from the same arena (the representation decision
is recorded in `.planning/SCAFFOLD-NEXT.md` as scaffold-scale, pending
ratification). The floor gained four instructions (`bnew` dynamic-size
alloc, `bget`/`bput` byte load and initialization write, `blen`) and the
`Mach` byte face (`bnw/bgt/bpt/bln/lea/dat`). The string/bytes primitives
are **not host calls**: `lib/bytes-tal.chiral` is the byte library authored
in chirality *at the tal level* — hand-written typed assembly as tal-ir data,
exercising the design's claim that tal is human-writable — reverse-shuttled
through the tal checker (the preserve-check for hand-tal) and emitted with
every batch; the shuttle rewrites `str-cat`/`bcat`/`pack-u32`/… to `nb-*`
calls (at the floor Str and Bytes are the same cells, so one library serves
both). With this, **the entire lowered pure fragment of the tomodachi runs
natively (48/48, including four functions lower.py synthesizes by outlining
non-tail cases)**, differentially verified: the Wayland wire encoder and
sprite rows byte-exact against `TalMachine`, the library against the host
prims. Everything still upper is upper by design: the eleven effectful
crossings and the genuinely dependent `if`/`draw`/`draw-rows`.

Milestone 4 (first slice) opens the sys face — tal's C category in
miniature (the design keeps raw hardware access at the tal floor). Two
instructions: `sys` (a Linux syscall: number immediate, args from slots
into rdi/rsi/rdx/r10/r8/r9) and `bptr` (the payload address of a byte cell
— the len word is chirality's, not the kernel's). `lib/sys-tal.chiral` authors
`write(2)`, `read(2)`, `lseek(2)`, `memfd_create(2)`, `ftruncate(2)`,
`mmap(2)`, and `munmap(2)` as hand-tal (all-integer crossings but for memfd's
empty name — a fresh one-byte NUL cell rather than reading past a payload;
`mmap` is the first crossing to use the full six-register syscall bank); the
checker marks every function containing the sys face (`TalFn.sysface`) and the
backend refuses the mark anywhere outside the deliberate sys library. Lowered
pure code has no surface path to these instructions, so the membrane holds
structurally. The reference machine performs the *same* real syscall through
libc, so native and reference are differentially tested against actual pipes
and against a chirality-side arena the language builds end to end: it creates an
anonymous file (`memfd_create`), sizes it (`ftruncate`), and maps it
(`mmap` MAP_SHARED), writing and reading through the mapping and releasing it
(`munmap`) — no borrowed Python loader `mmap`. This is the mechanism that
removes the port implementations from Python; the socket/poll/spawn leaves are
the remaining slices.

Honest limits of the native fragment: no reclamation inside the arena (it
frees as a unit with the compiled batch); `bput` is an initialization write
whose write-once discipline is authored, not yet checked (TAL's typed init
flags are the eventual answer) — though a fresh cell's payload is zero on
both floors by contract (reference `bytearray(n)`, native's zero-mapped
arena), so an unwritten byte reads as 0 identically either way; native `/` and `%` are Euclidean, agreeing
with the reference interpreter and the fold path (SMT-LIB alignment; a
branchless correction after `idiv` supplies the non-negative remainder), and
a guard around `idiv` closes the two inputs where raw `idiv` would fault
(`#DE`): `INT_MIN / -1` takes a branch that returns the wrapped `INT_MIN`
(remainder 0) — agreeing with the reference/fold across the whole I64 domain
— and a zero divisor traps deliberately (`ud2`), native's fatal-error idiom
until the effect floor lands, matching that the reference/fold treat `÷0` as
a fatal alarm (`PortError`) rather than a value; strings are byte-indexed UTF-8
(coincides with the host on ASCII — the demo's domain); library recursion
is call-per-byte, so very large buffers could exhaust the stack; the sys
face carries no typed effect yet (edge 16) — its confinement is the sysface
mark plus the absence of any surface path, not an effect type. Closures
are a later milestone; each slice removes more Python.

## The lowering connector and the tal floor

    python3 -m chirality lower demo/tomodachi.chiral
    -> lowered to tal, preserve-checked: 48 / stay upper: 14

Types are carried from the upper level down: an eligible definition's
declared type maps to a tal signature, its body compiles to typed register
instructions, and the tal checker (not the kernel) re-checks the compiled
body against that signature. That re-check is the preserve-check discharging
the connector, so a lowering bug is caught at the floor. The split lands on
the design's own line: the entire pure fragment lowers (wire codec, behavior
pack, sprite pixels, 48 functions including four outlined non-tail cases);
every crossing stays upper because an effect arrow is ineligible by
construction. `MET_TAL=1 chirality run` executes
the lowered fragment on the tal machine; the e2e suite runs the whole demo
both ways and the frames are identical. Non-tail case lowers by outlining
(the case becomes its own preserve-checked function). Honest limits: no
closures, no partial application, quantities not carried to the floor
(only unrestricted arrows lower today), and the reference drop below tal is
the python interpreter, trusted (the native drop is the chirality emitter).

## Optimization and pregeneration (preserve-checked tal → tal)

`modules-staging` names the staging module's operations as stage, specialize,
pregen, link-and-load. The scaffold has link-at-load and `spawn` (staging a
residual into a live runtime); `chirality/optimize.py` adds the other face.
Every pass is a tal → tal transform whose output is re-run through the tal
checker: correctness is discharged by the *same* preserve-check that
discharges lowering (`joining-law`), so an optimizer bug produces ill-typed
tal and is caught at the floor, never shipped. The invariant is in the
substrate, not asserted about the pass — a broken fold is a floor alarm, and
`tests/test_optimize.py` pins that with a deliberately ill-typed pass output.

- `fold` — constant-fold arithmetic and *statically select* a case branch
  whose scrutinee is a known constructor (dispatch collapses).
- `dead` — drop pure, non-allocating instructions whose result is unused
  (calls, allocations, writes, and the sys face are always kept).
- `specialize(fn, bindings)` — the **pregen primitive**: bind static
  arguments (an `I64` value or a nullary constructor) and produce a residual
  taking the remaining parameters, folded through. This is partial
  evaluation — the pregen twin of `spawn` (spawn stages a residual into a
  runtime; specialize *is* the residual). The residual is preserve-checked
  and runs as real machine code: the tests specialize `axpy(a,x)` on `a=5`
  and check the residual native-compiles and equals the original, and
  collapse a four-way `Dir` dispatch to a constant.

HONEST BOUNDARY: these transforms are meaning-preserving only. They make no
graded-cost claim — that mechanism is the cost gradient (open edges 2/3),
unresolved. "Optimize" here is operational (fold determined work, drop dead
instructions, bind generation-time arguments); a cost-typed account of what
they buy waits on that decision. The optimizer is scaffold python today,
like `lower.py`; moving it to chirality over `tal-ir` is a later de-Pythoning
step.

## Refinement types (the next type-system module)

The settled type-system build order is refinement → linear → capability
(`modules-core`); linear kinds are in (audit F2), and `chirality/refine.py` adds
refinement — a base type narrowed by a decidable predicate. A bound that is
otherwise a runtime check (a pool offset, a byte index, a nonzero divisor —
the honest limits scattered below) becomes a compile-time typing obligation:

    (def recip (-> (refine I64 (<> 0)) I64) (lam (d) (/ 100 d)))
    (def ok  I64 (recip 5))    ; checks
    (def bad I64 (recip 0))    ; rejected: cannot prove 0 satisfies {I64 | v <> 0}

Refinement is a **module behind the kernel's value-form seams**, not kernel
code: the kernel gained four hook lists (check / subtype / conv / quote) that
it consults for value forms it does not understand, and `refine.py` registers
against them — the same discipline that keeps data and effects out of the
kernel. Subtyping is entailment (a stronger refinement flows where a weaker is
expected) plus forgetting (a refined value is usable as its base).

Scaffold fragment (recorded pending author ratification, like the byte-cell
representation): the base is I64 and the predicate is a conjunction of
constant-bound atoms `v >= c`, `v > c`, `v <= c`, `v < c`, `v <> c`. That is
an interval-with-holes, so entailment is decidable, total, sound *and*
complete — no solver, no approximation, and rejection is conservative (a value
that cannot be proven in range is a type error, never a silent pass). The
symbolic slice — predicates over in-scope variables (`v < n`) with
path-sensitivity (learning the bound from a `case` or comparison-guarded branch)
— is now built and sound (syntactic entailment, no arithmetic between variables);
a symbolic bound collapses to a constant on instantiation, keeping subtyping
sound. Only arithmetic-expression bounds (`v < n+1`) remain out. This retires the
constant-bound checks, types a nonzero divisor, and types pool offsets and
non-constant loop indices.

## Run

    python3 -m chirality check demo/tomodachi.chiral
    python3 -m chirality verify demo/profile-tomodachi.chiral
    python3 -m chirality lower demo/tomodachi.chiral
    python3 -m chirality run demo/tomodachi.chiral          # MET_TAL=1 for the floor

Two-node form (start the sensor first; it listens on MET_NODE_SOCKET):

    MET_NODE_SOCKET=/tmp/tomo.sock python3 -m chirality run demo/node-sensor.chiral &
    MET_NODE_SOCKET=/tmp/tomo.sock python3 -m chirality run demo/node-render.chiral

On a real niri session `WAYLAND_DISPLAY` and `NIRI_SOCKET` are already set and
the creature appears bottom-right as a layer-shell overlay. `MET_IDLE_MS`
overrides the behavior pack's idle deadline. Customize by editing
`demo/behavior.chiral`. Verify headless (no compositor needed):

    python3 -m unittest discover -s tests

## What is real

- A minimal kernel: the trusted judgment core (quantities, evaluation,
  conversion, subtyping, checker, reify, install) is `kernel.py`, ~400 lines
  of body. The pure syntax beneath it (`terms.py`) and the pretty-printer
  above it (`pretty.py`, not trusted) are separate files, so the trusted
  judgment file contains judgment only. Data, effects, and refinement are
  modules behind seams, not kernel code.
- Quantities 0/1/ω by resource counting: linear ports must move exactly once
  on every path, erased binders cannot reach runtime positions, case branches
  must agree on linear usage.
- Linear kinds (audit F2, per decision-b-in-type): a `porttype`, and any data
  type transitively holding one, may only be bound or held at quantity 1,
  judged at declaration where concrete and at every instantiation otherwise,
  including through type parameters. Generic containers cannot hold ports; a
  port-carrying shape needs its own declaration with 1-fields (see `RecvR`).
- Erased means erased (audit F1): quantity-0 positions must be effect-free
  and 0-quantity lets are not evaluated at runtime.
- The memory bound lives in the port's type (docs/memory-model.md):
  `(porttype Pool (n I64))` is value-indexed, `(pool-create 16384)` has type
  `(PoolR 16384)` by ordinary dependent application, pool operations carry
  the bound as an erased parameter, and the bridge verifies the size claim
  at the crossing. Offsets within the bound stay a runtime check until
  refinement types land. Pools are zeroized before release, the typed form
  of the bhumi drop-hygiene rule. Two disciplines (linear, region) compose
  over this one substrate and a profile names its choice (see above).
- `lib/collections.chiral`: list functions and association lists in chirality,
  the library floor the self-hosted checker will stand on.
- The orchestration substrate (`lib/{collections,json,http,fsm,backend,manas}`):
  a general module set for driving local models over an OpenAI-compatible HTTP
  seam — JSON parse/serialise, a pull-based streaming port, a Mealy state
  machine, and a swappable backend interface, with manas as a conformance
  profile. Effectful, runs on the RT interpreter; tested against mock backends
  at the extern seam. Reference + handoff contract: `docs/orchestration.md`.
- Pure `->` versus process `=>` arrows; applying a process arrow inside a
  pure function is a type error. The membrane in miniature, and its rules
  live in the effects module, not the kernel.
- Primitives are language declarations (`extern`, `porttype`) with host
  bindings, split A/C; missing bindings fail at link, before anything runs.
- Alarm shape (audit F3-F5): a closed stream is the `recv-closed`
  constructor; `wl_display.error` is parsed and the alarm carries object,
  code, and message; the fatal response is the polymorphic `halt` counter
  effect, so alarm paths close what they hold and halt.
- The whole Wayland client is chirality source over one typed socket port:
  registry, layer-shell handshake, shm pool via fd-passing, ARGB frames. No
  libwayland. The niri event stream is a second typed port; the poll deadline
  is the only time the program has; redraws happen only on mood change.

## What is stubbed or missing (honest list)

- The evaluator is a python tree-walk. No performance claim of any kind;
  "highly optimized" in the target note is a typed claim about the eventual
  stage 5 backend, and there are no numbers until that exists.
- Totality is partly enforced. Strict positivity of data declarations IS
  checked (data.py): a recursive occurrence to the left of any arrow, nested
  through a container parameter that is not itself strictly positive, or under
  a type-level application, is rejected, which forecloses the diverging
  fixpoint that non-positive datatypes encode. Container nesting through a
  strictly-positive parameter is allowed (per-parameter variance is computed
  and cached at declaration). What is still missing: structural-recursion and
  coverage-productivity checks on function definitions, so a directly
  diverging recursive *function* is not yet rejected; and Principle 5's
  total-by-default policy is settled (docs/decision-graded-kernel.md, Fork B)
  but only positivity of the three is built. The nesting check is conservative
  in one direction only (it may over-reject an exotic container whose variance
  it cannot confirm; it never admits a genuinely negative occurrence).
- Erasure is partial: 0-quantity lets are skipped, but 0-quantity arguments
  are still evaluated (pure by F1, so unobservable short of divergence).
- The orchestration substrate is functional but unwired to a real worker: every
  test uses a mock backend at the extern seam (ccbox blocks TCP), so a real
  HTTP/model run is owed on the host. `be-chat-stream` has no live caller yet;
  transcript persistence, retry/backoff, per-call timeouts, and worker
  `train-*` endpoints are not built. See the gap list in `docs/orchestration.md`.
- Effects are one coarse bit, not the effect algebra (open edge 16). `halt`
  is the one counter effect; environment failures (`sock-connect` to a bad
  path, pool bounds) are still runtime `PortError` exits, not typed alarms.
- The target/verify mechanism checks named crossings at named types plus the
  frozen port set. It does not check whole-assembly properties (open edge 18)
  or the staging connector's preservation; the lowering connector's
  preservation IS checked (the tal re-check), the bridge's inbound half is
  dynamic verification, and its outbound half (confinement beyond purity) is
  not built.
- Node-to-node crossings are typed on each side but carry no capability
  material (no Adhikara): the mood wire is trusted-peer plaintext. Edge 17
  (cross-node alarms) untouched: a node learns of its peer only through
  recv-closed.
- The staging check is one-sided: the child verifies itself at staging, but
  the parent cannot state the port protocol it expects of the child in the
  spawn type (`spawn` returns a bare Sock). Typing the crossing between
  runtimes end to end is the port-protocol work of edge 14 plus the
  Adhikara correspondence of edge 7.
- The pool bound is in the type (F8 closed), and a provable offset is now
  compile-time checked (`mem-put-checked`, refinement types); a *computed*
  offset the fragment cannot prove (a strided `(* y k)`) keeps the runtime
  check, and whole-assembly memory sums are edge 18. Space as a graded cost
  has no mechanism yet: edges 2, 3.
- Case on a neutral value in a type is a hard error, not a stuck term.
- The prelude `if` is strict; use `case` for effectful branching. `str->i64`
  returns 0 on junk. Wayland: version-1 binds, no seat/input, single 64x64
  buffer, layer-shell required (niri, sway, river yes; GNOME no).
- In-sandbox verification is against protocol mocks; only a real compositor
  proves the rendering path end to end.
