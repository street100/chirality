# Design-session prep: D1 cost gradient, D2 variable-length data, D3 closures

Companion to `SCAFFOLD-NEXT.md`. Each section: the minimal decision list
(from the research sweep, with the docs' own framing), the directly relevant
prior art (named once, mapped to the specific decision it informs — reading
list, not adopted positions), and what the scaffold can already show. No
decisions are proposed here beyond what the docs already lean toward; the
author steers.

---

## D1 — Cost gradient (edge 3) + membrane reach (edge 2)

**Decisions** (per open-edges.md and ROADMAP stage 2/3):
1. Posture: totality-by-default / graded cost in the type / runaway shapes
   hard to express — or a stated combination.
2. Placement: does cost enrich the kernel's quantity structure, or live in
   an elaboration module the kernel checks? (This is the exact question
   stage 3 is blocked on.)
3. Grade structure rich enough to state the tomodachi idle bound as a type.
4. Edge 2 menu: termination? information flow? or grade-and-stop.
5. Ratify backflow F1: erased (0) positions are effect-free.

**Prior art mapped to decision 2 (the load-bearing one):**
- Atkey, *Syntax and Semantics of Quantitative Type Theory* — QTT is
  defined over an **arbitrary resource semiring**; {0,1,ω} is one instance.
  So "enrich the kernel" has a precise technical shape: pick a product
  semiring (usage × cost) and the checker's resource-counting arithmetic
  extends unchanged in form. The scaffold's qadd/qmul/qfits are already the
  generic shape (~40 lines); swapping the semiring is mechanically small.
  That cuts both ways: cheap to put in the kernel, and cheap to keep out
  (a graded modality module using the same arithmetic behind the seam).
- Granule (Orchard et al.) — multiple grade semirings coexisting in one
  language (naturals for exact use, intervals for bounds, lattices for
  security levels). Evidence that edge 2's "grade them and stop" is
  technically coherent: information flow as one more grade dimension rather
  than a separate subsystem — which matches the project's no-new-subsystems
  rule.
- Hofmann's LFPL / Hoffmann's RAML — space bounds as typed potential /
  amortized analysis. Relevant as the *contrast*: those infer bounds; the
  chirality notes commit to declared over-approximate bounds ("fuel", not a
  predictor). Confirms the honesty framing already in time-and-clocks.md.

**Scaffold evidence to bring:** the idle bound is structural today (poll
deadline is the only time; no port ops between events); the value-indexed
Pool shows a bound-in-type surviving contact; F1/F2 backflow. A useful
session exercise: write the tomodachi idle bound in each of the three
postures on paper and see which one the existing checker shape absorbs.

---

## D2 — Variable-length data below tal (milestone-3 gate; a silence)

**Decisions:**
1. The value shape: proposal on the table is one word per value — a boxed
   cell `[len][payload…]` in the arena (Str = same cell + UTF-8 claim).
   Fits the slot machine unchanged; len is a runtime witness beside the
   payload, the same pattern as mem-region's capacity witness.
2. Where grown buffers (str-cat, bcat) allocate: same bump arena (frees as
   a unit) is the scaffold-scale answer; anything else waits on edges 2/3.
3. The floor vocabulary this adds (edge-6 territory): dynamic-size alloc
   (size from a register), byte-granular load, and **initialization writes
   into a cell under construction** — the one design-sensitive bit, since
   tal is otherwise SSA-shaped.

**Prior art:**
- Morrisett et al., *From System F to Typed Assembly Language* — TAL tracks
  **partial initialization in the type** (tuple fields typed as
  initialized-or-not, writes flip the flag). Direct precedent for decision
  3: initialization writes are type-distinguished from mutation, so the
  floor stays honest without inventing a mutability story.
- Xi & Harper, DTAL — singleton/index types carrying array lengths in typed
  assembly. This is precisely the "offsets become typed when refinement
  lands" future the docs defer; the runtime length word is its scaffold
  stand-in, and the two are compatible (the word becomes the witness the
  index refines).

**Scaffold facts:** 19 first-order prims gate everything; all are loops over
bytes, writable in chirality as recursive tal functions once the three floor ops
exist — the string library becomes self-hosted and differentially tested
like milestones 1–2. String literals are representation-neutral prep (M3).

---

## D3 — Closures (milestone-4 gate; total silence)

**Decisions:**
1. Representation: typed closure conversion vs defunctionalization.
2. Environment layout at the floor.
3. Indirect calls (the current floor has direct calls to labels only).
4. Whether the self-hosted checker needs closures at all — enumerate its
   language needs first (cheap prep; currently a silence).

**Prior art:**
- Morrisett et al. (same paper) — typed closure conversion via existential
  packages ⟨code ptr, env⟩ : ∃α. …  Types are preserved through the
  conversion, which is exactly the preserve-check story the lowering
  connector already tells; the canonical answer to decisions 1–3 if
  closures are wanted at the floor.
- Reynolds' defunctionalization (+ typed variants, Pottier/Gauthier) —
  whole-program alternative: function values become data constructors,
  indirect calls become case dispatch. Note the audit already narrowed the
  dump's "dispatch evaporates" hint to a specialize-internal technique, so
  adopting defunctionalization globally would be a new decision, not a
  ratification.

**Existing machinery likely already covers the linearity half — verify,
don't invent:** a closure environment is morally a data cell holding
captured fields. The linear-kinds rule (F2: anything transitively holding a
quantity-1 value is itself quantity-1, judged at every instantiation)
extends to it unchanged — a closure capturing a port would *be* linear by
the same judgment. If that holds under scrutiny, D3's design surface shrinks
to representation + indirect calls only.

---

## Suggested session order

D1 first (ROADMAP-named starter; the only hard block). D2 is small enough to
ride as the second half of a D1 session — it is a scaffold-scale
ratification like milestone 2's region decision, not the full cost
mechanism. D3 after its prep question (checker needs) is answered; edge 14
(one-step-or-two) whenever the port-protocol work wants to move — its test
case (node wire + staging) is already built.
