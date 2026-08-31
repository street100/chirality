# Scaffold audit against the design base

Date: 2026-07-05. Scope: `scaffold/` compared against PRINCIPLES.md,
`docs/vocabulary.md`, `docs/modules-core.md`, `docs/error-and-alarm.md`,
`docs/permission-model.md`, `docs/decision-b-in-type.md`,
`docs/target-tomodachi.md`, plus a fresh-eyes read of the kernel and runtime.
Each finding: what diverged, which doc it diverges from, disposition.

## Soundness (kernel)

- F1 **Effects in erased positions.** A quantity-0 let, argument, or
  constructor field had its usage scaled by 0 but was still evaluated at
  runtime, so `(let (0 x (print "hi")) ...)` type-checked as pure-looking and
  printed anyway. Violates P4 (resource use on the membrane) and the QTT
  reading of 0 as "absent at runtime". FIXED: erased positions are checked
  with effects forbidden, and the runtime does not evaluate 0-quantity lets.
- F2 **Bare port values alias.** Quantities constrain binders, not values, so
  a port returned bare (`sock-connect`, `sock-send`) could be re-bound at w
  and consumed twice; double-close then surfaced as a runtime alarm instead of
  a type error. Violates [[decision-b-in-type]] (B-ness lives in the type) and
  the permission model's move-only grants. FIXED structurally: port types and
  every data type transitively holding one are linear kinds, and the kernel
  now rejects (a) a Pi binder of linear kind at any quantity but 1, (b) a let
  binder of linear kind not declared 1, (c) a constructor field of linear kind
  not declared 1, at declaration where concrete and at every instantiation
  otherwise, (d) applying a function whose instantiated parameter is linear
  kind at any quantity but 1 (closes the polymorphic smuggle: `(if Sock ...)`).

## Design conformance

- F3 **Closed stream was a sentinel, not a type.** `sock-recv` signaled a
  closed peer as zero-length bytes and the demo compared lengths.
  [[error-and-alarm]] wants divergence named in the type. FIXED: `RecvR` gained
  `recv-closed`, carrying the port back; the demo now cases on it.
- F4 **Alarm paths faked totality with dead constructors.** `dead-st` connected
  to "" in unreachable code because nothing could inhabit `St` after `exit`.
  The doc-honest shape is the halt counter effect from [[error-and-alarm]].
  FIXED: new primitive `halt : (-> (0 A (type 0)) (=> Str A))`, the fatal
  counter effect; alarm paths close what they hold, then halt. Dead
  constructors deleted.
- F5 **The wayland protocol error was stringly.** [[error-and-alarm]] requires
  an alarm to carry what diverged from what; the handler printed a fixed
  message and dropped the error body. FIXED: the demo parses object id, code,
  and message out of `wl_display.error` and halts with them.
- F6 **Redraw on every event line.** The idle-bound claim in
  [[target-tomodachi]] is about spending nothing without cause; redrawing an
  unchanged mood on every `WindowFocusChanged` spends without cause. FIXED:
  `mood-eq` in the mood contract; redraw only on mood change.
- F7 **Prims not placed on the two axes.** Every module is supposed to sit in
  a typeability category ([[axis-typeability]]); the prim table mixed pure A
  operations and C port operations without saying so. FIXED: each prim carries
  its category (A or C) in the registry and the README says which is which.
- F8 **Memory bound not in the port's type.** target-tomodachi promises the
  buffer supply carries its size in the port type; the scaffold checked pool
  bounds at runtime only. CLOSED to the extent the design licenses
  (2026-07-05, memory-model pass): `(porttype Pool (n I64))` is value-indexed,
  `(pool-create 16384) : (PoolR 16384)` by dependent application, write and
  close take the bound as an erased (0) parameter, `(Pool 4096)` and
  `(Pool 16384)` are distinct types, the bridge verifies the claimed size at
  the crossing, and the tomodachi target requires the bound through `wl-init`.
  Offsets within the bound are now a COMPILE-TIME obligation too (2026-07-06):
  `lib/mem-linear.chiral` `mem-put-checked` refines the offset to
  `{I64 | >= 0, < n}` against the pool's capacity, so an out-of-bounds or
  guarded-in-bounds write is decided by the type-checker (symbolic refinements:
  `< n` collapses to a constant at a concrete pool, threads through generic
  code). The raw `mem-put`/`pool-write` stays for a computed offset the fragment
  cannot prove (a strided `(* y k)` write), which keeps the runtime witness.
  What stays runtime: those unprovable offsets, and any whole-assembly sum
  (edge 18).
- F9 **Mock never exercised server-initiated buffer release.** Real
  compositors send `wl_buffer.release` after commits; the skip path was
  untested. FIXED: mock sends release after each buffered commit.

## Restructure round (same day, after the author rejected demo-first framing)

The first build optimized for reaching the demo; the author's correction was
that the language doing what it was meant to do outranks the demo. Findings
and what changed:

- F10 **The kernel was a monolith.** ADTs, case, exhaustiveness, the effect
  rules, and the port discipline were all kernel code, against modules-core's
  "keep the kernel small". FIXED: the kernel is now the QTT core only, with
  two explicit seams: term-former handlers (data module registers TCon/Con/
  Case checking and evaluation) and judgment rules (effects module owns what
  the membrane permits, consulted at application, binder formation, and
  erased positions). The kernel does not know what a constructor, an effect,
  or a port is.
- F11 **Primitives were defined in python, not in the language.** The prim
  table owned names, types, and arities, so the language floor was outside
  the language. FIXED: `extern` and `porttype` declarations in chirality source
  own every primitive's type; `lib/prelude.chiral` is the A floor,
  `lib/ports.chiral` the C floor; python holds only implementations, split
  `impl_pure.py` / `impl_ports.py` along the splitting-law seam; the runtime
  links declarations to bindings at load and fails on a missing binding.
- F12 **No profile, no conformance.** decision-profiles says a profile is a
  testable manifest and conformance is type-checking; the scaffold had
  neither. FIXED in miniature: `(target name (require ...))` declares a
  requirement type; `demo/profile-tomodachi.chiral` is the manifest plus
  target; `chirality verify` judges each requirement by subtyping. Honest limit:
  named-crossings-at-named-types only; whole-assembly properties (edge 18)
  and connector preservation are not checked.

## Accepted scaffold limits (re-affirmed, README)

No totality, no erasure of 0-arguments in general (only 0-lets are skipped),
one coarse effect bit rather than the algebra, checker divergeable by
type-level recursion, no positivity check, strict `if`, `str->i64` junk to 0,
version-1 Wayland binds, single buffer. All remain listed in
`scaffold/README.md`; none contradict a settled decision, they are stage 4/5
work arriving early at most.
