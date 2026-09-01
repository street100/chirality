# Novelty inventory — what the substrate infects (2026-08-22)

**Why this exists.** Asked whether chirality has "40 novel things" and answered with four.
That was wrong, and the reason is the point: **almost none of these are novel ideas,
and almost all of them are novel *here*.** A socket with linear error semantics, a
buffer pool with its size in the type, a display layer with a write-cap, and a model
endpoint that is a consumed capability are the *same substrate* showing through in
different clothes.

**Read with `docs/decision-*` and `PRINCIPLES.md`.** Three tiers, honestly separated —
inflating tier 2 into tier 1 is the credibility error `chirality-demo-strategy` warns about.

- **T1 — idea-novel** (I know no precedent; a claim about my knowledge, not the literature)
- **T2 — novel in position** (old idea, new placement — this is where nearly everything sits)
- **T3 — table stakes** (ordinary, merely absent or recently added)

---

## T1 · Idea-novel, as far as I know

1. **Time and space as ports on the same membrane as I/O.** Non-termination and
   unbounded allocation are *crossings*, not separate analyses — so a ReDoS is caught by
   the mechanism that catches a file write. (`PRINCIPLES.md` P3.)
2. **Linearity making the reflective floor structural.** `freeze : (1 b SigB) -> Frozen`
   — after the consume, the write-capable handle no longer exists to name, so
   reconfiguration is **unexpressible**, not forbidden. (`reflect-floor.chiral`, E45.)
3. **The full stack combination, self-hosted to a typed floor.** QTT + effect membrane +
   refinements + dependent types, compiling itself to typed assembly with exactly one
   trusted drop. Idris 2 has QTT; F* has refinements; CakeML/CompCert have verified
   compilation. The combination, self-hosting, I know nowhere else.
4. **Residential liveness over a capability mesh** — Emacs's feel on Erlang's structure,
   with types carrying authority. (`docs/live-environment.md`, its own first-fusion claim.)

## T2 · Novel in position — the substrate showing through

### Linearity turns resource APIs into something else (SYS)
5. **`RecvR`: "a real error is a corpse"** — the `-err` arm *drops* the socket handle
   because the kernel is done with it; only success and half-close thread a live cap on.
   The error taxonomy **is** the resource lifecycle.
6. **fd-passing** — the `Fd` is consumed on success (the kernel moved it) and returned on
   error. Linearity models SCM_RIGHTS exactly.
7. **`Pool n`** — buffer size in the **type**; `(Pool 16384)` and `(Pool 4096)` are
   different types and the bridge verifies the claim at the crossing.
8. **`proc-spawn`** — fork-returns-twice sealed inside one category-B primitive; the
   surface is a single return with a **linear Reap obligation**. Forgetting to reap is
   untypeable.
9. **`socketpair`** — two connected linear caps, hermetic. A test fixture that is a type.
10. **Clock/Timer as linear caps** — time is a port you hold.
11. **`Env`** — a linear, keyed, read-only *view*, not `getenv`.
12. **pty as a cap**, with write authority split from read.
13. **`adopt-fd`** — introducing a raw fd into linearity; runtime no-op, type-level everything.

### QTT creates machinery with no analogue elsewhere (CG, MEM)
14. **`lincoll`** — `List`/`Map` at a porttype element is **rejected by the checker**, so a
    purpose-built linear container had to exist. A data structure that exists because of a
    quantity semiring.
15. **`be-peek`** — a struct-returning crossing so a linear handle can be *used* while a
    fresh `q1` handle threads onward. Pure QTT laundering.
16. **porttype carriers** (E123/E144) — an opaque linear atom lowering to a word or a
    string, erasure proven.
17. **`preserve-check`** — lowering re-checks types at every drop; compilation that does
    not lose the type.
18. **Two-level defunctionalization** — a captured function applied *inside* a `$apply`
    arm routes through `$apply` again (E147).
19. **Erased normal form** — `0`-quantity bindings erased structurally, not optimized away.
20. **A typed assembly floor with a deliberately tiny universe**, where a mnemonic that is
    not a real opcode is *the tell of an altitude error*.

### The membrane rewrites ordinary control flow (EF, RF)
21. **`->` vs `=>`** — purity is a different arrow, enforced. A display function *provably*
    crosses no port.
22. **Totality by default**, partial as the marked case — a merge sort must argue its measure.
23. **Effect rows inferred from crossings**, not declared.
24. **Two effect facets** — possession vs exercise, joined by construction. Holding ≠ crossing.
25. **Alarms as crossings** — a fired timer notifies a resident at the other end of a port
    and reads back a continuation. No ambient timer heap; the pending set is a threaded value.
26. **Graded continuations** — resumption multiplicity graded by the continuation's QTT
    quantity. Captured linear ports force one-shot; port-free capture permits backtracking.
    Derived, not decreed.
27. **Refinements in crossing signatures** — `(refine I64 (> 0))`, so "read at least one
    byte" is checked.

### Capability-as-port reshapes security primitives (TR)
28. **No ambient authority** — authority *is* the set of ports held.
29. **Split checker** — a small trusted core re-checking untrusted certificate producers,
    aimed at a self-hosting compiler's trusting-trust problem.
30. **Profiles freeze a port set**; composition checked by subtyping against a target, so
    "replaceable" means conformance, not a version string.
31. **Seccomp generated from the crossing registry** — the denylist is the complement of a
    set the compiler already knows.
32. **Foreign as a B referent hanging off the side** — reachable only through a typed
    orchestrator, with *no port to unwrapped foreign*, so bypassing the wrapper is
    unexpressible. **This is the untyped-compartment story: dynamism beside the typed path
    is designed; dynamism as the floor of it is what's refused.**
33. **Split-role tiering (T0–T3)** with the honest verb — detection, not prevention, named
    as a downgrade.

### Orchestration on typed values instead of config (ORCH)
34. **Pipelines/Configs/Experts/GateRules as typed chirality values** — not YAML, not a DSL.
    The thing you edit is the thing that runs.
35. **`Backend` as a linear porttype** — a model endpoint is a capability, consumed once per turn.
36. **Min-privilege grants per specialist** — own payload plus dependencies' *typed egress*,
    never a sibling's prose.
37. **Golden-manifest conformance** — structural agreement on stable fields, ignoring
    non-deterministic model text. Testing an LLM pipeline without asserting on prose.
38. **Code-prior routing** — markers decide, the model sees only residue. A measured
    dispatch rule, not a preference.
39. **Flow as a typed fractal** — branch is a perspective sub-pipeline with a paired
    consolidate, not "more agents".

### The display stack is typed values, not text (TUI/scriba)
40. **`Puffer`** — a buffer is a typed lens over a **port**, polymorphic in content type.
41. **`Rendering`** — a closed-sum display tree; the renderer never reparses.
42. **`Mode`** — renderer + faces bound **per port type**: a stylesheet keyed by a typed
    interface rather than by selector matching over untyped markup.
43. **`Surface`/`Layer` with per-layer write-cap** — *"a trusted overlay is just the top
    layer whose cap only the trusted authority holds."*
44. **Terminal as a port with three backends** — real, emulator, co-resident; callers untouched.
45. **`r-stream`** — a process rendered as a node in the tree, so scriba needs no ANSI parser.
46. **Undo as past/future zipper stacks** restoring text *and* cursor, per buffer, polymorphic.

### Meta
47. **Test-runner in chirality** — no shell or Python in the loop.
48. **A Rocq external-spec leg** where the fixpoint is honestly labelled *stability, not
    correctness*.
49. **The banks discipline** — refracting a monolith into shards with principled homes,
    lint-enforced.
50. **The worked-example pipeline** with *turn economy* as the explicit design driver.

## T3 · Table stakes (ordinary; interest is only that they were absent)
Floats (E153, still unbuilt) · fs crossings (E148/E149) · argv (E150) · multi-root
resolve (E155) · string ownership (E151) · sort (E152) · label mangling (E154).

---

## The correction that produced this doc

I claimed "a dynamic substrate is closed." **Wrong.** `docs/axis-altitude.md` already has
the untyped compartment: foreign code is a **B referent hanging off the side**, reachable
only through a typed orchestrator, and *"the runtime is built with no port to unwrapped
foreign, so using a driver that has not been wrapped is not expressible."*

What is actually closed is narrower: **dynamism as the floor of the typed lowering path.**
Beside it, in a compartment holding only the ports you handed it, it is designed — and
one of the reasons for modularity.

This also corrects the sharpest limit I named. Lock-free queues, RCU, hazard pointers
**can** exist here: racy internals in B, typed port outside, blast radius bounded by
capability. What you lose is not the capability but the **proof** — containment and
detection instead, exactly P5's own verb-honesty. The real closure is small:
**you cannot have an ungoverned path.** Everything else is which category it lives in and
what you may claim about it.
