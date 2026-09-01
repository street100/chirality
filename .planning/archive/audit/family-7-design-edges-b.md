> **ARCHIVED 2026-09-01. Superseded. The port these seven dossiers de-risked has LANDED: the checker, the analyses, the pipeline, the substrate and the sys/format layers are chirality in `lib/` and `prog/`. Successors are `docs/examples/` (the worked examples) and `docs/elements/specs/`, both TRACKED.** ⚑ Every source line cited below is an evicted `scaffold/chirality/*.py` path. Nothing here can be re-run. Its cross-family "candidate element" flags were checked 2026-09-01 before archiving and **every one resolved to a minted element** (E51 built, E42 built, E52 design-unresolved, E20/E21/E23/E26/E32 all minted), so no unminted phantom is lost with the file.

# Family 7 — Design edges B: theory & surface (E45–E50)

**Elements:** E45 reflective floor · E46 proof-presentation/auditor layer ·
E47 sized types · E48 dependent records/telescopes · E49 real surface syntax ·
E50 mutual + lexicographic termination.

**State of the family.** All six are designed-but-unbuilt; none has a line of
implementation code, so every verdict below is UNBUILT. But the family splits
sharply by *distance to a mechanical pass*. E47 (one slice) and E50 (both
slices) sit directly on top of `data.py`'s `check_termination` — the walk,
the bounds lattice, and the acceptance test they need are already written, and
the extension is rule-governed. E48 is a bounded diff to `data.py` +
`surface.py` whose exact trap is already solved in `kernel.py`'s App rule.
E49 and E46 each have a small mechanical seed (a conformance harness; a
witness-retaining ledger) and a large author-gated remainder. E45 is a pure
decision element: the deliverable is the decision note, and the mechanism
gates on capabilities (E40/E43) and staging (Fork C). The family's biggest
single finding: the totality checker discards its own witnesses (it knows
*which* position decreases and throws that away), which cheaply poisons E46
and E47 — retain the witness in any totality pass.

---

## E45 — Reflective floor: what is reconfigurable from inside   [BUILD-PROPER · Tier P]

**Lives now:**
- `docs/open-edges.md:31–34` — edge 5, the oldest open edge: "Pin exactly what
  is and is not reconfigurable from inside the language. Sits between the A and
  B halves of the kernel, and between [[modules-bridges]] (reflect-raw) and
  [[modules-broker]]."
- `docs/modules-core.md:71–75` — `reflect-typed`: "Staged metaprogramming over
  typed terms. Type preserving, total, a function from typed term to typed term."
- `docs/modules-bridges.md:63–68` — `reflect-raw`: "Substrate mutating self
  modification, bounded above by the reflective floor … effectful and gated,
  not a pure term to term function. The boundary it cannot cross is an open edge."
- `docs/trust-boundary.md:92–93` — "The reflective floor (edge 5) is the last
  such hatch and must be gated by a capability itself."
- `docs/decision-graded-kernel.md:94` — explicitly NOT decided there ("edge 5
  is untouched here; it remains open").
- `docs/bootstrap-sequence.md:53–55`, `docs/view-implementation.md:110–117`
  (roadmap stage 2 names it a load-bearing edge), `docs/status-ledger.md:77`
  (DESIGNED), `docs/view-security.md:138–139`.

**Verdict:** UNBUILT (design docs only; and unlike the other five, not even the
*design* is pinned — edge 5 is explicitly open and stage-2-blocking).

**Explainer:** The design already splits reflection in two by the splitting law:
`reflect-typed` (category A: pure, total, typed term→term, compile/stage time)
and `reflect-raw` (category C: effectful mutation of running structure, gated).
The floor is the line reflect-raw cannot cross. The scaffold gives the question
a concrete face it did not have when edge 5 was written: **the reflective
surface of chirality today is the `Sig` object** (`kernel.py:111–150`) — its
registries (`ext_check`, `ext_eval`, `check_hooks`, `def_hooks`, `rules`,
`global_defs`, `profiles`, …) are exactly "what can be reconfigured," and today
they are reconfigured only from Python, only at load (`data.py:23–31
install(sig)`, `refine.py:43–50 install(sig)`, wired in `surface.py:42–46
Elab.__init__`). So the current floor is trivially "everything is below it":
no chirality-expressible path mutates any registry. The trap for a future pass is
treating this as one knob; it is a *ladder* of reconfiguration powers, and the
decision is where on the ladder the floor sits and what mechanism holds it
there. The scaffold's `spawn` + link-at-load (status-ledger: SEEDED staging)
already implements the weakest rung — installing new defs into a *child* —
which suggests the cascade framing below.

**Translation dossier:**
- *Source exemplar* — the acts the floor governs are exactly these, quoted from
  `refine.py:43–50` (a whole type-system feature arriving as registry writes):
  ```python
  def install(sig):
      sig.ext_check["Refine"] = _check_refine
      sig.ext_eval["Refine"] = _eval_refine
      sig.check_hooks.append(_check_against)
      sig.subtype_hooks.append(_subtype)
      ...
  ```
  and the trust statement it must preserve, `docs/trust-boundary.md:92–93`:
  "The reflective floor (edge 5) is the last such hatch and must be gated by a
  capability itself."
- *Target sketch* — the deliverable is `docs/decision-reflective-floor.md`, in
  the shape of `docs/decision-graded-kernel.md` (forks → decision → why → what
  it does not decide). The decision space to lay out, NOT decide:
  - **D1 (the ladder).** Which rung is reachable from inside a running node:
    (i) nothing — reflection exists only across stage boundaries
    (reflect-typed at generation time); (ii) additive-only — install new
    defs/data/profiles, which `spawn` + link-at-load already does for a child;
    (iii) hook-level — install new checker modules (a runtime `install(sig)`,
    i.e. refine.py-grade power); (iv) judgment-level — replace `rules` /
    kernel functions. The design texts clearly intend (iv) below the floor
    forever; the live question is (ii) vs (iii).
  - **D2 (the gate).** Capability-gated reflect-raw (trust-boundary's demand):
    the reconfiguration act is a linear port minted by the component broker —
    ties E40 (capability model) and E43 (broker AUTH/AUDIT). Options: a
    porttype like the existing `(porttype …)` linear atoms (`surface.py:108–126`)
    vs a profile clause (frozen at composition like the port set).
  - **D3 (structural vs policy).** Is the floor a kernel property (no term
    former reaches Sig — invariant in the substrate, principle 5) or a broker
    policy (the port exists, is never granted)? Edge 5's own text ("between
    the A and B halves of the kernel, and between modules-bridges and
    modules-broker") says the answer is *both seams at once* and must be
    drawn consistently.
  - **D4 (the dissolving option).** Per `bootstrap-sequence`/`process-and-runtime`,
    a runtime stages further runtimes. Option: *self-modification is always
    birth, never mutation* — "modifying" the checker means spawning a child
    stage with a different Sig, and the parent's Sig is immutable by
    construction. This collapses much of edge 5 into the staging modality
    (Fork C) plus the profile freeze, and matches what the scaffold already
    does (`spawn` re-verifies the staged profile, `cli.py:102–114`). Name it
    as the structurally attractive option; the cost (no in-place hot-patch,
    ever) is the author's call.
  - Tier-P reading: B.C. Smith "Reflection and Semantics in Lisp" (3-Lisp);
    Wand & Friedman "The Mystery of the Tower Revealed"; Kiczales et al.
    *The Art of the Metaobject Protocol* (for the "which registries are open"
    ladder); Amin & Rompf "Collapsing Towers of Interpreters" (POPL 2018 —
    directly on D4's stage-cascade framing); Taha & Sheard on MetaOCaml for
    the reflect-typed half.
- *Mechanical recipe* —
  1. NEW (small): write the Sig-registry census — one table, every field of
     `Sig.__init__` (`kernel.py:114–150`), classified by which D1 rung touches
     it and what breaks if it moves at runtime. This is the context artifact
     that makes the eventual decision (and any later pass) mechanical, and it
     is pure reading of code already audited here.
  2. NEW (author): the decision note per D1–D4. Not delegable.
  3. TRANSLATE (after decision): if D4 wins, the "implementation" is a
     conformance statement over existing mechanisms (spawn + profile freeze +
     capability port), not new machinery.

**Dependencies:** gates on the author decision (roadmap stage 2 names it);
mechanism depends on E40/E43 (capability + broker) and Fork C staging. Blocks:
nothing in this family, but trust-boundary makes it the last hatch before
"discipline becomes enforcement" — it blocks the E1–E14 self-host *trust story*,
not the code.

**Est. pass size:** S for the census + decision note. Mechanism unsized until D1–D4 settle.

---

## E46 — Proof-presentation / auditor layer (Isar-equivalent)   [BUILD-PROPER · Tier P]

**Lives now:**
- `docs/open-edges.md:58–60` — edge 10: "The auditor facing proof presentation
  layer (an Isar equivalent). Bounded novel work; no off the shelf equivalent
  exists for this module set. Sits inside [[modules-core]] (reflect-typed)."
- `docs/view-implementation.md:88–95` — one of the five named `gap` modules.
- Proto-auditor output that already exists (the seed to grow, not discard):
  - `surface.py:490–514 verify_profiles` — per-profile conformance rows
    (target rows, port violations, totality violations with reasons);
  - `chirality/cli.py:43–59` — the report renderer ("`profile p: VALID (target
    totalizer: 1/1; port set: respected; total: proven)`", per-def
    "`def spin not proven total: <reason>`"), format also quoted in
    `docs/totality.md:129–133`;
  - `sig.totality` reason strings (`data.py:481–494`), refinement failure
    messages (`refine.py:220–222` "cannot prove … satisfies {I64 | …}");
  - `pretty.py`, the display floor, with the trust rule stated at
    `kernel.py:13–15`: display "is reached only when the kernel raises an
    error; a bug there cannot unsound the checker."

**Verdict:** UNBUILT (edge 10; the verify report is a seed, not the layer).

**Explainer:** chirality's checkers currently produce *verdicts with reasons for
failure* but no *evidence for success*. `_totality_reason` (`data.py:603`)
computes, per self-call, the exact set of decreasing argument positions
(`calls`, `data.py:652`) and then reduces it to a boolean at
`data.py:720–722` — the witness (which position, by which measure, structural
or numeric, against which bound) is discarded. Same shape in refinement: the
entailment that succeeds leaves no record. An Isar-equivalent needs affirmative
per-obligation evidence: *claim, checker, witness, verdict*. The
architecturally load-bearing invariant is already stated in the kernel header:
presentation is never trusted — the auditor layer must be a *renderer of
re-checkable claims*, not a second judgment, or it grows the TCB. That is
precisely Isar's design point (the document replays through the kernel) and
the reason this element cannot be closed by prettifying the verify report
alone. The honest scaffolding order: retain witnesses first (mechanical),
decide the document semantics second (author).

**Translation dossier:**
- *Source exemplar* — the verdict-without-witness reduction,
  `data.py:719–726`:
  ```python
  if not calls:
      return None                 # no self-call: total by construction
  if set.intersection(*calls):
      return None                 # a uniform decreasing position: well-founded
  return ("no argument position decreases in every recursive call by a "
          "measure the checker can see ...")
  ```
  and the report row it should feed, `chirality/cli.py:49–50`:
  ```python
  tot = f"; total: {'proven' if not total_viol else 'violated'}"
  print(f"profile {pname}: {'VALID' if ok else 'INVALID'} "
  ```
- *Target sketch* — two layers, only the first pass-ready now:
  1. **Obligation ledger (mechanical seed).** Extend the classifier verdicts
     from `None | reason` to a small record: for totality,
     `sig.totality[name] = None` becomes e.g. `("structural", {0})` /
     `("numeric-const", {1})` / `("none",)` on success and the reason string on
     failure — the data is already in `calls`/`dec` (`data.py:626–652`), it is
     only dropped. `verify_profiles` (`surface.py:508–511`) then reports *how*
     each def proved, not just that it did. Output stays the existing report
     grammar (`cli.py:50–59`) with one more clause per row — an additive
     change in syntax-evolution's sense.
  2. **The Isar-equivalent proper (author-gated).** Decision space:
     - **D1 evidence object:** reason-ledger (above) vs kernel derivation
       traces. The ledger keeps the kernel untouched (classify-then-gate
       discipline, spec pattern 5); traces grow the kernel's output surface.
     - **D2 document semantics:** write-once generated report (what `verify`
       is) vs re-runnable document where reading = re-checking (Isar's
       identity; the de Bruijn/AUTOMATH criterion). D2 decides whether the
       layer is `pretty.py`-class (untrusted, display) or a new checked
       artifact format.
     - **D3 scope:** per-def obligations vs whole-composite conformance
       (targets/profiles are the natural audit unit — `target-tomodachi` is
       the named consumer).
     - Tier-P reading: Wenzel, "Isar — a Generic Interpretative Approach to
       Readable Formal Proof Documents" (TPHOLs 1999) and his thesis; Necula,
       "Proof-Carrying Code" (POPL 1997) for the evidence-vs-recheck
       distinction; the AUTOMATH "small checkable kernel + readable text"
       lineage. No source to avoid — Isabelle is Tier-O at most.
- *Mechanical recipe* —
  1. TRANSLATE: widen `_totality_reason`'s success return to carry the winning
     measure kind + position set (rule: everywhere `dec.add(j)` fires, tag j
     with which of the four branches fired; return the intersection with its
     tags). ~15 lines in `data.py`, plus `verify_profiles`/`cli.py` rendering.
  2. COPY: the report grammar from `cli.py:43–59` (extend, don't replace —
     `totality.md:129–133` quotes it as the stable format).
  3. NEW: the D1–D3 decision note, then the document format. NEW dominates
     layer 2 — the context artifact that would fix that is an **obligation
     inventory**: one table of every judgment the scaffold discharges today
     (totality per def, refinement entailments, port-set rows, target rows,
     preserve-check, bridge verify) with its current output string and file:line.
     With that table, layer 2 becomes schema design over known rows.

**Dependencies:** none to start (layer 1 is free-standing); layer 2 gates on
D1/D2 author decisions; consumes E47/E50 witnesses as they land (richer
measures = richer rows). Unblocks: the chirality-verify story of edge 9/18
becoming *auditable*, not just judged.

**Est. pass size:** S (layer 1). Layer 2: L, needs slicing — slice by D3
(per-def ledger doc first, composite conformance doc second).

---

## E47 — Sized types (termination promotion)   [BUILD-PROPER · Tier P, verification Tier O]

**Lives now:**
- `docs/totality.md:145–156` — the promotion path: "The fuller one is **sized
  types**: a size index on a datatype turns 'smaller' from a syntactic fact
  into a typed measure, subsuming both structural and numeric descent, and a
  size index is close enough to a cost grade that if sized types land they
  reuse the semiring machinery."
- `docs/decision-graded-kernel.md:52–63` (item 2 names sized types the
  promotion path), `docs/open-edges.md:55–57` (edge 9 needs "the sized-types
  promotion so numeric recursion can clear the bar").
- The checker it promotes: `data.py:481–494 check_termination`,
  `data.py:603–726 _totality_reason` (read in full for this audit).

**Verdict:** UNBUILT (designed in totality.md/decision-graded-kernel; no code).

**Explainer:** Everything sized types need at the *use* site already exists in
`_totality_reason`; what is missing is the *supply* side — today every size
fact is learned syntactically inside the body (a `case` mints size tokens at
`data.py:674–679`; a comparison guard mints bounds at `data.py:680–684` via
`_guard_bound`), and nothing is learned from the def's *type*. That is the
precise sense in which the checker "classifies only": a def whose
boundedness lives in its signature rather than in an inline guard cannot
prove. The promotion therefore has two slices of very different weight.
**Slice A (type-seeded bounds, pass-ready):** the refinement module already
puts bounds *in types* — `lib/mem-linear.chiral:27` types an offset as
`(refine I64 (>= 0) (< n))` — and `VRefine`'s constraint `(lo, hi, ex, sym)`
(`refine.py:61`) is the same lattice as the walk's `(lo, hi, lt, gt)` bounds
tuple (`data.py:537`). Seeding the walk's `bounds` map from the parameters'
declared types is a mechanical join of two existing structures. **Slice B
(sized data, the full feature):** a size index on datatypes so `case` gives
the tail a *typed* size `s` with the scrutinee at `s+1`, subsuming the
structural token. That slice is gated by a real decision the docs flag: is
the size a grade factor (reusing Fork A's semiring seat) or a
refinement-like erased index (like `(Pool n)`)? Do not build slice B before
that decision; do build slice A now.

**Translation dossier:**
- *Source exemplar 1* — where the walk is seeded, `data.py:715–716`:
  ```python
  try:
      walk(t, nparams, {i: (i, False) for i in range(nparams)}, {})
  ```
  (the final `{}` is the empty `bounds` map — the promotion point). And the
  consumption site that will just work once bounds are seeded,
  `data.py:637–650` (the numeric-measure branch of the App case):
  ```python
  nd = _num_delta(a, depth, nparams)
  if nd is not None and nd[0] == j and nd[1] != 0:
      lo, hi, lt, gt = bounds.get(j, _NOBOUND)
      d = nd[1]
      if d > 0 and hi is not None and hi <= _I64_MAX - d:
          dec.add(j)      # i <= hi < MAX-d+1: i+d cannot overflow
      ...
      elif d == 1 and _passes_unchanged(args, lt, depth):
          dec.add(j)
  ```
- *Source exemplar 2* — the type-side supply. The Pi-spine walk to copy,
  `kernel.py:578–583` (`declare_extern`):
  ```python
  while tyv[0] == "VPi":
      arity += 1
      is_port = is_port or tyv[2]
      tyv = close_apply(sig, tyv[5], ("VNe", ("NVar", arity), []))
  ```
  and the constraint to translate, `refine.py:32–35`: "A constraint is
  `(lo, hi, excluded, sym)` … `sym`, a frozenset of (op, level) symbolic
  bounds keyed by the operand variable's de Bruijn level."
- *Target sketch (slice A)* — a `.chiral`-visible example that should flip from
  classified to proven, every construct cited from the corpus: a counting loop
  whose bound is in the *type*, modeled on `row-bytes`
  (`demo/sprites.chiral:58–63`) with its inline guard removed and the
  refinement from `lib/mem-linear.chiral:27` moved onto the parameter:
  ```lisp
  ; (refine I64 ...) parameter position: exemplar lib/mem-linear.chiral:27
  ; recursion shape: exemplar demo/sprites.chiral:58-63 (row-bytes)
  (def count-up (-> (0 n I64) (refine I64 (>= 0) (< n)) I64 I64)
    (lam (n i acc)
      (count-up n (+ i 1) (+ acc 1))))
  ```
  **Finding, stated honestly:** as written this still needs the guard because
  the *recursive occurrence* `(+ i 1)` must be re-proven `< n` to type-check
  the call — which is exactly the point: with slice A, the bounds map knows
  `i < n` at entry, and the `d == 1 and _passes_unchanged(...)` arm at
  `data.py:648` fires with no body guard. The re-check obligation on the
  argument is the refinement module's job and is what keeps the measure sound
  (`totality.md:80–85`'s two conditions are both visible in the seeded bound).
  No new surface syntax is required for slice A. Slice B (sized data
  declarations) DOES need a construct chirality does not have — a size slot on
  `data` — and that is a finding, not a sketch: its shape must be co-designed
  with the grade-vector binder reservation (`syntax-evolution.md:33–48`).
- *Mechanical recipe* —
  1. COPY: the VPi spine walk from `kernel.py:578–583` into a new
     `_param_bounds(sig, name)` helper in `data.py` (the def's type value is
     `sig.global_types[name]`, available inside `check_termination` — the hook
     runs after the def type-checks, `kernel.py:544–551`).
  2. TRANSLATE (rule: lattice-to-lattice, both already documented): for each
     parameter whose domain is `VRefine(("VPrimTy","I64"), (lo, hi, ex, sym))`,
     emit a bounds entry `{level: (lo, hi, lt, gt)}` where `lt = {L for
     ("<", L) in sym}`, `gt = {L for (">", L) in sym}`; `>=`/`<=` symbolic ops
     drop (the walk only uses strict symbolic bounds, `data.py:577–581`);
     `ex` drops (holes never prove termination). Levels agree by construction:
     parameter *i* is de Bruijn level *i* on both sides (`refine.py:57`,
     `data.py:610–612`).
  3. TRANSLATE: seed the call at `data.py:716` with the computed map instead
     of `{}`. Meet (don't replace) with guard-learned bounds — `_meet`
     (`data.py:585–590`) is already the right operator.
  4. NEW (small): tests mirroring `tests/test_kernel.py TestTermination` —
     the type-bounded loop proves; the same loop with `w`-typed bound does
     not; wraparound exclusion still enforced (the `hi <= _I64_MAX - d` arm
     is untouched, so this is a re-run, not new logic).
  5. Slice B is NOT pass-ready: the context artifact that would make it so is
     `docs/decision-sized-types.md` deciding (a) grade-factor vs erased-index
     home, (b) the size algebra (ℕ+∞ suffices per Abel), (c) the surface slot
     (must respect the reserved binder superset). Tier-P reading: Abel,
     "Type-Based Termination: A Polymorphic Lambda-Calculus with Sized
     Higher-Order Types" / "MiniAgda: Integrating Sized and Dependent Types";
     Barthe et al. on CIC-hat; Hughes–Pareto–Sabry "Proving the Correctness of
     Reactive Systems Using Sized Types" (POPL 1996). Verification Tier O:
     accept/reject corpora against Agda's sized types, never its source.

**Dependencies:** slice A: none (E9/E10 refinement is built; the join is
internal to data.py). Slice B: the decision note above + Fork A (E38) for the
grade-home option; feeds E50 (a size is the natural lexicographic component)
and E46 (witness rows say "numeric, bound from type"). Unblocks edge 9's
promotion so `(total)` profiles stop rejecting signature-bounded loops.

**Est. pass size:** S (slice A). Slice B: L — slice as (decision note) →
(size on one datatype + case rule) → (subsumption of the structural token).

---

## E48 — Dependent records / telescopes (field dependence)   [BUILD-PROPER · Tier P]

**Lives now:**
- **The guard**, `data.py:120–135` (`_ctor_field_types`) — the scaffold limit
  is a *comment plus a scoping regime*, not a check:
  ```python
  fields = decl.ctors[cname]
  out = []
  env = list(targs)
  for (q, fname, fty) in fields:
      ftyv = K.eval_term(sig, env, fty)
      ...
      out.append((q, fname, ftyv))
      # fields may not depend on earlier fields (scaffold limit), only params
  return out
  ```
  (`env = list(targs)` at `data.py:127` never grows — later field types are
  evaluated in the params-only environment.)
- What actually *enforces* the limit: `surface.py:258` elaborates each field
  type under `list(pscope)` — the params-only scope — so an earlier field
  name is simply "unknown name" at elaboration. The kernel-side comment
  claims an invariant the surface upholds.
- Sibling sites that assume params-only field indices: `_check_con`
  (`data.py:184–191`), `_check_case` binder loop (`data.py:212–223`),
  `_compute_sp_params` (`data.py:388–406`: "the p-th parameter sits at de
  Bruijn index (nparams − 1 − p) inside a field type"), `_infer_ctor_params`
  (`data.py:153–162`: solves only bare `Var` field types).
- Design placement: `docs/modules-core.md:40–43` ("with dependent, region, and
  subtype deferred to later slices"); `docs/open-edges.md:236–238` (build
  order records dependent as deferred).

**Verdict:** UNBUILT (the feature). The pass, however, is EXTEND-shaped: the
kernel seam already carries it, and the diff is confined to `data.py` +
`surface.py`.

**Explainer:** A telescope makes each constructor field's type live under
binders for the *earlier fields*, not just the type parameters — `(mk (len
I64) (buf (refine I64 (< len))))`. The pivotal architectural fact this audit
confirms: **the kernel needs no change.** `kernel.py`'s `infer`/`check` never
see a constructor — `Con`/`Case`/`TCon` route through `sig.ext_check`
(`kernel.py:444–448, 483–488`), and the data module owns field instantiation
entirely. The task brief asked what lifting takes "in kernel.py check/infer
for ctor param dependence"; the honest answer is *nothing in kernel.py* — and
that is the seam pattern working as designed. The one genuine trap is already
solved elsewhere in the kernel: when a later field's type depends on an
earlier field's *value*, you must evaluate the earlier argument — but eagerly
evaluating a runtime-recursive argument gets stuck. `kernel.py:423–427` (App)
solves exactly this with a dependence test:
```python
# only evaluate the argument if the codomain is actually dependent;
# eager evaluation would run (and get stuck on) runtime recursion
if uses_below(fty[5][1], 1):
    arg_v = eval_term(sig, ctx.env, t[2])
else:
    arg_v = ("VNe", ("NVar", len(ctx)), [])
```
Copy that discipline per field. Second trap, found during this audit: `Var`
evaluation is `env[len(env) - 1 - t[1]]` (`kernel.py:222–223`) — a field type
whose index overruns the env would *silently wrap via Python negative
indexing* rather than fail. Today the surface scoping makes that unreachable;
the telescope pass grows the index space per field and should add an explicit
range assert (defense for the day another front-end feeds Con terms directly).
Third: variance/positivity index arithmetic (`_compute_sp_params`,
`_positivity`) assumes field types index only params; each field at position
*f* must offset by *f* once fields bind.

**Translation dossier:**
- *Source exemplar* — the App-rule dependence test quoted above
  (`kernel.py:423–427`), plus the case-binder loop that must thread neutrals,
  `data.py:212–223`:
  ```python
  ftys = _ctor_field_types(sig, decl, cname, targs)
  ...
  for name, (q, fname, ftyv) in zip(names, ftys):
      ctx2 = ctx2.bind(name, q, ftyv)
  ```
- *Target sketch* — surface, grounded: the refinement-on-field shape already
  exists at parameter level in `lib/mem-linear.chiral:27`
  (`(refine I64 (>= 0) (< n))` with `n` an earlier binder); the telescope
  moves the same form into a `data` field list, whose syntax
  (`(ctor (q fname ty) ...)`) is unchanged — only the *scope* of `ty` widens:
  ```lisp
  ; field-list shape: exemplar lib/emit-core.chiral:54 (data EmitR ...);
  ; refine-with-variable-bound: exemplar lib/mem-linear.chiral:27
  (data Packet ()
    (packet (len I64) (payload (refine I64 (>= 0) (< len)))))
  ```
  This is additive in syntax-evolution's sense: no existing program wrote a
  field name in a later field's type (it was an unknown-name error), so
  widening the scope reinterprets nothing.
- *Mechanical recipe* —
  1. TRANSLATE (`surface.py:240–261 _top_data_body`; rule: scope grows left
     to right, same as `arrow`'s binder loop at `surface.py:350–362`): keep
     `fscope = list(pscope)`, elaborate each `fty` under `fscope`, then
     `fscope.append(fname)`.
  2. TRANSLATE (`data.py:120–135 _ctor_field_types`): thread values —
     signature becomes `_ctor_field_types(sig, decl, cname, targs,
     field_vals)`; inside the loop `env = list(targs) + field_vals[:i]`.
     Callers choose what to thread:
     - `_check_con` (`data.py:184–191`): interleave — evaluate field *i*'s
       type, check `args[i]`, then COPY the `kernel.py:423–427` pattern:
       evaluate `args[i]` to a value only if a later field's type
       `uses_below` the binder for field *i*; else push a fresh neutral.
     - `_check_case` (`data.py:212–223`): push the *branch binder neutrals* —
       `ctx2.bind` already mints them (`kernel.py:180–184`); evaluate field
       *i+1*'s type in `targs + [neutral_0..neutral_i]`. No new machinery.
     - `_eval_con`/`_eval_case` (`data.py:40–54`): unchanged — values carry
       evaluated args; the case body env `env + list(args)` (`data.py:50`)
       is already telescope-correct because args are in field order.
  3. TRANSLATE (index arithmetic; rule: every `nparams - 1 - p` over a field
     type at position *f* becomes `nparams + f - 1 - p`): `_compute_sp_params`
     (`data.py:393–400`), `_infer_ctor_params`'s bare-`Var` test
     (`data.py:156`), and `_positivity`'s depth base per field.
  4. NEW (small): the range assert on `Var` eval or a data.py-side check that
     elaborated field indices are in range; linear-kind walk `_linear_data`
     (`data.py:69–91`) needs a decision for fields whose type depends on a
     *runtime* earlier field — conservative answer (treat un-evaluable as
     "judged at instantiation") already exists at `data.py:89–90`, reuse it.
  5. NEW (tests): a `Packet`-style decl round-trips; a field referencing a
     later field still errors; `_check_case` narrows `payload` by `len` in a
     branch (composes with `refine.py`'s `_narrow` for free — the binder's
     type IS a refinement mentioning the sibling binder's level).
- Tier-P reading: de Bruijn, "Telescopic mappings in typed lambda calculus";
  standard Σ-type/record treatments (ATTAPL ch. 2; Dybjer on inductive
  families for where this eventually leads). Oracle (Tier O): what
  Agda/Idris2 accept for dependent record declarations, behaviorally.

**Dependencies:** none hard (refinement built; the sketch's payoff example
uses it). Feeds E9's future (refinements over non-parameter variables get
their natural home) and the eventual inductive-families story. Honest kernel
diff size: **kernel.py ±0 lines**; data.py ~50–70 lines touched;
surface.py ~5; tests ~60.

**Est. pass size:** M (1–2 sessions; the positivity index arithmetic is the
part to do slowly).

---

## E49 — Real surface syntax (stage 4)   [SELF-HOST/OURS · Tier R]

**Lives now:**
- `scaffold/chirality/sexp.py:1–95` (the whole reader: symbols, i64, strings,
  lists, `;` comments — 95 lines, read in full);
- `scaffold/chirality/surface.py:1–24` — the current form inventory, and line 3:
  "This is scaffold surface only; the real surface syntax is stage 4 work.";
- `.planning/ROADMAP.md:44–49` — Stage 4 "The typed core … surface syntax,
  typed reflection … Status: open.";
- `docs/syntax-evolution.md` (whole note — the staged plan);
- `docs/modules-core.md:64–69` — the `syntax` module: "every surface is a
  rendering of it [the canonical IR] … that rendering is lossless: a surface
  may not drop linearity, capabilities, or effects";
- `docs/status-ledger.md:61` — "Surface syntax … (scaffold s-expr; real
  surface is stage 4)";
- Corpus: 15 `lib/*.chiral` + 16 `demo/*.chiral` files — the entire ground truth
  of what the surface must express.

**Verdict:** UNBUILT (the stage-4 surface). The s-expr surface it replaces or
graduates is IMPLEMENTED and is the Tier-R port source.

**Explainer / audit of the staged plan vs surface.py:** The audit's sharpest
finding here: **`docs/syntax-evolution.md` is not a stage-4 syntax spec — and
nothing else is either.** The note governs the *evolution of the s-expr
surface*: two reservations on occupied slots (the grade-vector binder
`(q x Ty)` and the effect label `=>`), a list of additive forms (staging
brackets, `(op expr)` refinement operands, nested/literal patterns, qualified
imports), and a resolved ruling that the alleged token irregularities (`w` vs
`0/1`, `the`'s type-first order) are Lisp-family-regular and stay. Checked
against `surface.py`, the note is accurate: the binder slot is parsed at
exactly three sites (`QUANTS` at `surface.py:34`, arrow binders at
`surface.py:356–359`, let bindings at `surface.py:393–396`, data fields at
`surface.py:250–255`) and holds one scalar; `=>` is one boolean threaded as
`eff and is_last` (`surface.py:366`); the do-bind `(<- x e)` the note marks
"built 2026-07-06" is real (`surface.py:431–451`, `_is_do_bind:543`);
refinement operands already take the variable case (`surface.py:297–314`),
partially delivering the note's "variable-bound refinements" additive item.
So the two documents cohere. What does NOT exist: any decision that stage 4
is a *different notation* at all, vs the s-expr surface graduated (reservations
honored, additive forms landed, elaborator self-hosted per E2). The tension
is real and unowned: `surface.py:3` calls this surface "scaffold only," while
`syntax-evolution.md` invests in its long-term regularity ("a reader's
recognition of `(1 x Ty)` or `=>` is an asset") and `design-principles`'
Lisp-family framing cuts against a gratuitous re-skin. That is an author
decision; name it, don't decide it.

**Stage 4 as a translation problem (old surface → new surface over the SAME
core):**
- **What stays (the invariant set):** the kernel term language
  (`kernel.py:31–47` — stage 4 produces the same 10 core tags + 3 extension
  tags); the toplevel declaration vocabulary (`import/data/declare/def/
  porttype/extern/target/profile`, `surface.py:74–136`); binder quantities and
  their semantics; the effect bit; the two reserved slots *as semantics*
  (whatever the new grammar looks like, `0/1/w` must remain the usage
  projection and `=>` the widest effect — `syntax-evolution.md:41–47, 60–66`);
  the losslessness law (`modules-core.md:66–69`) — the new surface may not
  drop a quantity, port, or effect that the s-expr surface expresses.
- **What changes:** `sexp.py` (the reader) and the *recognition* half of
  `surface.py` (`elab`'s head dispatch, `surface.py:265–316`); nothing below
  `Elab.toplevel`'s outputs.
- **The conformance harness (the mechanical, buildable-now part):** dual
  front-end equivalence over the corpus. For every file in `lib/` + `demo/`,
  the stage-4 rendering must elaborate to alpha-equal kernel terms and an
  identical Sig. The equality judge already exists: `K.conv` for values,
  structural equality for terms (they are tuples), and `chirality verify` output
  for the composite. This is the same shape as the repo's floor-agreement
  discipline (spec pattern 4) applied one layer up: two surfaces, one core,
  agreement checked, s-expr remains golden until the author retires it.
- *Target sketch* — deliberately none for the grammar: **inventing stage-4
  syntax here would violate the dossier's own ground rule** (never invent
  surface syntax); the grammar is the author's fork. The sketch that IS
  grounded is the harness driver, modeled on the existing CLI verbs
  (`cli.py:23`: `check|run|verify|lower`): a `chirality conform old.chiral new.m4`
  verb that loads both through their front-ends and diffs
  `sig.global_defs` / `sig.global_types` / `sig.profiles`.
- *Mechanical recipe* —
  1. COPY: `sexp.py` + `surface.py` are the Tier-R port source and the
     reference front-end; freeze them as the golden side of the harness.
  2. NEW (small): the conform verb (term diff is tuple equality; Sig diff is
     dict comparison over names — ~80 lines).
  3. NEW (author-gated): the grammar decision — (a) s-expr graduated vs
     (b) new notation; if (b), a `docs/decision-surface.md` must restate the
     two reservations and the losslessness law as constraints on the new
     grammar *before* any parser is written. The context artifact that makes
     the eventual pass mechanical either way: a **form inventory table** —
     every construct in `surface.py:5–24`'s docstring × every corpus exemplar
     file:line × its kernel elaboration — which is one afternoon of extraction
     from files already enumerated here.

**Dependencies:** the grammar fork is co-gated with the grade-vector binder
(Fork A / E38) and implicit arguments (`syntax-evolution.md:69–91`: "design
implicit arguments together with the grade-vector binder … and the checker's
inference story (stage 4)") — deciding stage-4 syntax before Fork A's binder
shape would re-occupy the reserved slot. Harness: no dependencies. Unblocks:
E2's self-hosted elaborator has to pick a surface to parse; the harness is
also its acceptance test.

**Est. pass size:** S (harness + form inventory). Grammar + second front-end:
L, gated; slice as decision → reader → forms in `surface.py` docstring order.

---

## E50 — Mutual/bidirectional termination + lexicographic measures   [BUILD-PROPER · Tier P, verification Tier O]

**Lives now:**
- The gap, named exactly: `docs/totality.md:94–101` — "**lexicographic /
  multi-argument descent** — no single position decreases every call, though a
  tuple of them does; **size-change** recursion …; **mutual recursion** — the
  self-only check cannot see a partner it calls through a forward `declare`."
- The refusal sites in code:
  - acceptance test, `data.py:719–726` (`set.intersection(*calls)` — the
    single-position rule);
  - mutual refusal, `data.py:661–669` (the `Global` branch):
    ```python
    if t[1] in sig.global_types and t[1] not in sig.global_defs:
        raise _NotStructural(
            f"calls {t[1]}, which is declared but not yet defined -- "
            "mutual recursion is not yet checked for totality")
    ```
- The machinery it extends: `_totality_reason`'s walk (`data.py:603–726`),
  `_passes_unchanged` (`data.py:593–600` — already the "argument passed
  unchanged" test lexicographic needs for its `=` entries), the
  classify-then-gate plumbing (`check_termination` `data.py:481–494`,
  `sig.totality`/`require_total` `kernel.py:129–132`, `def_hooks` firing in
  `finish_def` `kernel.py:544–551`), and the declare/def mutual-group surface
  (`surface.py:85–98`).
- Corpus motivation for the mutual slice, already written and currently
  classified-not-proven: `lib/emit-core.chiral:56` `(declare emit-code (=> Mach
  TCode I64 EmitR))` with `emit-branches` calling `emit-code` (line 68) and
  `emit-code` (defined after) calling back `emit-branches`.

**Verdict:** UNBUILT (both slices; totality.md names them as the remaining
gaps). This is the family's most pass-ready element.

**Explainer:** The walk already computes, per self-call, the full set of
positions that *strictly decrease* (`dec`, `data.py:626–652`) by either
measure. Lexicographic descent needs one more letter per position — `=`
(passed unchanged) — and a different acceptance test: instead of "some
position decreases in *every* call," find an ordering of positions such that
each call decreases at its first non-`=` position. With `{<, =, ?}` per
(call, position), that is the textbook call-matrix criterion, and the greedy
algorithm is sound and complete for the lexicographic fragment: repeatedly
pick a position that is `<` or `=` in every remaining call and `<` in at
least one; delete the calls it decreases; succeed when none remain. Mutual
recursion is the same matrices across a *group*: a call from `f` to `g`
relates `f`'s parameters to `g`'s arguments, and the size-change principle
(compose matrices along cycles; every idempotent composition must have a `<`
on its diagonal) decides the group. The scaffold's plumbing is friendlier
than it looks: a def in a mutual group is exactly one that trips the
`data.py:667` refusal, so the *reason string is the pending marker* — defer
those defs, and when `finish_def` completes the last member (no group member
left in `global_types − global_defs`), run the group analysis and overwrite
each member's `sig.totality` entry. Two soundness notes the pass must keep:
(1) the numeric measure's guard-recheck argument (`totality.md:66–75`) is
per-position and survives lexicographic combination unchanged — the wraparound
exclusion arms at `data.py:641–644` are untouched; (2) `=` for the numeric
measure must mean *value-identical* (same `Var`, the `_passes_unchanged`
test), never "same bound" — a re-derived bound is not an unchanged value.

**Translation dossier:**
- *Source exemplar 1* — the status alphabet is one line away. Current `dec`
  accumulation (`data.py:626–631`):
  ```python
  dec = set()
  for j, a in enumerate(args):
      # structural: a case-bound field strictly smaller than param j
      if a[0] == "Var":
          tok = size.get(depth - 1 - a[1])
          if tok is not None and tok[0] == j and tok[1]:
              dec.add(j)
  ```
  The `=` case is the same lookup with `tok[1]` false — `tok == (j, False)`
  means "param j itself, unshrunken" (seeded at `data.py:716`); for numerics
  it is `_passes_unchanged`'s test specialized to position j.
- *Source exemplar 2* — the acceptance test to replace (`data.py:720–722`):
  ```python
  if set.intersection(*calls):
      return None                 # a uniform decreasing position: well-founded
  ```
- *Target sketch (Python, the pass's actual target)* — `calls` becomes a list
  of dicts `{j: '<' | '='}` (absent = unknown). Acceptance:
  ```python
  def _lex_ok(calls, nparams):
      calls = [c for c in calls if c]        # drop nothing; empty dict = fail fast
      while calls:
          for j in range(nparams):
              if all(c.get(j) in ("<", "=") for c in calls) \
                      and any(c.get(j) == "<" for c in calls):
                  calls = [c for c in calls if c.get(j) != "<"]
                  break
          else:
              return False
      return True
  ```
  The single-position rule is the first iteration of this loop, so every
  currently-proven def stays proven (no regression by construction).
- *Target sketch (.chiral acceptance case, every construct from the corpus)* —
  the two-list merge, modeled on `filter`'s nested case
  (`lib/collections.chiral:37–44`) and `row-bytes`' comparison guard
  (`demo/sprites.chiral:60`):
  ```lisp
  (def merge (-> (List I64) (List I64) (List I64))
    (lam (xs ys)
      (case xs
        (nil ys)
        ((cons x xt)
          (case ys
            (nil xs)
            ((cons y yt)
              (case (<=i x y)
                (true  (cons x (merge xt ys)))
                (false (cons y (merge xs yt))))))))))
  ```
  Call 1: `{0:'<', 1:'='}`; call 2: `{0:'=', 1:'<'}`. Intersection of
  `<`-sets is empty (today: classified, reason at `data.py:723–726`);
  `_lex_ok` proves it in order (0, 1). This is the regression test.
- *Mechanical recipe — slice 1, lexicographic (self-recursion only):*
  1. TRANSLATE (rule: everywhere `dec.add(j)` fires write `status[j] = '<'`;
     where the same test succeeds with "unshrunken token / passed-unchanged"
     write `'='` unless already `'<'`): `data.py:626–652`. ~12 lines.
  2. TRANSLATE: replace `set.intersection(*calls)` (`data.py:721`) with
     `_lex_ok(calls, nparams)` above. Keep the reason string, extend its text
     to say "…by any lexicographic ordering of positions."
  3. COPY: `tests/test_kernel.py TestTermination`'s test shape; add `merge`
     (proves), `merge` with an argument swapped on one call (must NOT prove —
     `{0:'<',1:'?'}` + `{0:'?',1:'<'}` fails `_lex_ok`), and the existing
     corpus re-run (`verify-total.chiral` stays VALID).
- *Mechanical recipe — slice 2, mutual (size-change over the group):*
  4. TRANSLATE: parametrize the walk's self-call test (`data.py:625`
     `head[1] == name`) over a set `group_names`; record calls as
     `(callee, matrix)` where matrix maps *callee* positions to
     `{'<','='}` facts about *caller* parameters (the existing `size`/
     `bounds` machinery is caller-side and unchanged — only the recording
     target widens).
  5. TRANSLATE (the deferral): in `check_termination`, when
     `_totality_reason` trips the `data.py:667` forward-reference refusal,
     record `sig.totality[name] = reason` as today, plus stash `(name, body)`
     on a `sig` pending list. In `finish_def`'s hook pass, after a def lands,
     if no name referenced by the pending group remains in
     `sig.global_types − sig.global_defs` (the exact test at
     `data.py:667–668`), run the group analysis and overwrite each member's
     verdict.
  6. NEW (the only genuinely new algorithm, and it is fully paper-specified):
     size-change closure — compose call matrices over the group's call graph
     to a transitive closure; accept iff every idempotent matrix from a node
     to itself has `<` at some diagonal position (Lee–Jones–Ben-Amram), or,
     for a cheaper first cut, run `_lex_ok` per strongly-connected component
     with a shared position table (foetus-style). ~60–80 lines. Tier-P
     reading: Lee, Jones, Ben-Amram, "The Size-Change Principle for Program
     Termination" (POPL 2001); Abel, "foetus — Termination Checker for Simple
     Functional Programs"; avoid Agda's `Agda.Termination` source (named
     avoid-column in `docs/decision-inspiration-policy.md:57`). Tier-O
     verification: accept/reject corpus checked against Agda/Idris2 verdicts.
  7. NEW (tests): the `emit-code`/`emit-branches` group from
     `lib/emit-core.chiral` as the live corpus case — whichever verdict the
     analysis returns, pin it with its reason; a two-def even/odd style group
     (write with `case` on a `Nat`-like data from `prelude.chiral`) that must
     prove; a two-def ping/pong on an unchanged argument that must not.
- **Interlock with the profile gate:** `verify_profiles`
  (`surface.py:505–511`) reads `sig.totality` at verify time, i.e. after all
  defs load — group overwrites land before it looks, so edge 9's `(total)`
  gate needs zero changes. `sig.require_total` (load-time, `data.py:493–494`)
  is the one behavioral decision: a pending group member cannot be judged at
  its own `finish_def`. Options: (a) `require_total` defers the error to
  group completion (error cites the group), or (b) forward-declared defs are
  exempt until the group closes. Name (a) as the sound default; it is 5 lines.

**Dependencies:** none for slice 1. Slice 2 is self-contained but should land
after slice 1 (it reuses the status alphabet). Feeds E46 (per-def witness
becomes "lexicographic on (0,1)" / "size-change via g"), E47 slice B (a size
index is the natural matrix entry), and edge 9/18's "is totality
compositional" question — a group verdict is the first non-per-def totality
fact, the same scoping refinement `totality.md:141–143` says the port-set
check wants (cross-family: E44).

**Est. pass size:** S (slice 1) + M (slice 2). Both are the family's
closest-to-mechanical passes; do them first.

---

# Footer

## Redo list (scaffold shortcuts that poison downstream work, ranked)

No REDO verdicts — all six elements are UNBUILT and the adjacent built code is
sound. Shortcuts *adjacent* to this family that a pass should clean en route:

1. **`_totality_reason` discards its witness** (`data.py:719–726` reduces the
   per-call decreasing-position data to a boolean). Poisons E46 (no
   affirmative evidence rows) and dulls E47/E50 reporting. Fix rides any
   totality pass; ~15 lines.
2. **The E48 guard is a comment enforced at a different layer**
   (`data.py:135` comment; `surface.py:258` scoping is the actual enforcement)
   — plus the latent `Var` negative-index wrap in `eval_term`
   (`kernel.py:222–223`) that scoping currently makes unreachable. Harmless
   today; a silent-aliasing hazard the moment field index space grows.
   Cross-family (E3/E13 kernel robustness): add the range assert.
3. **`surface.py:3` vs `syntax-evolution.md` frame the same surface as
   "scaffold only" vs "long-term asset."** Not a code defect; a documentation
   contradiction that will misdirect the E49 pass unless the author resolves
   the graduate-vs-replace fork explicitly.

## Ordering (dependency-respecting sequence for the family's passes)

1. **E50 slice 1** — lexicographic acceptance (S; pure extension of the
   existing walk; no decisions).
2. **E47 slice A** — type-seeded bounds from `VRefine` params (S; joins two
   built structures; no decisions). Include the witness-retention fix
   (redo item 1) in whichever of passes 1–2 goes first.
3. **E50 slice 2** — mutual groups via deferral + size-change (M; reuses
   pass 1's alphabet; unlocks `lib/emit-core.chiral` defs for `(total)`
   profiles).
4. **E48** — telescopes in data.py/surface.py (M; independent of 1–3; kernel
   untouched).
5. **E46 layer 1** — obligation ledger + richer verify rows (S; consumes the
   witnesses from 1–3).
6. **E49 harness + form inventory** (S; anytime; do before any grammar work).
7. **Author decisions, in the order they unblock:** reflective-floor note
   (E45, roadmap stage 2 wants it early and it blocks no code here) ·
   decision-sized-types (gates E47 slice B; co-ordered with Fork A/E38) ·
   stage-4 grammar fork (gates E49's second front-end; co-ordered with Fork
   A's binder shape and the implicit-arguments co-design).
8. **E47 slice B**, then **E46 layer 2**, then **E49 grammar/front-end** — all
   post-decision, in that order (each consumes the previous one's artifacts).

## Cross-family flags

- **→ E38 (Fork A, graded kernel):** E47 slice B's size-index home
  (grade-factor vs erased index) is really Fork A's call —
  `decision-graded-kernel.md:58–60` already reserves the seat. The E38 pass
  should decide it explicitly rather than leave it to a sized-types pass.
- **→ E2 (surface elaborator) / E1 (reader):** E49's conformance harness is
  also E2's acceptance test; nested/literal patterns
  (`syntax-evolution.md:107–109`) have no catalog element of their own — they
  belong to E2/E49's scope, worth a line in the catalog.
- **→ E44 / edge 18:** E50 slice 2 produces the first *group-scoped* totality
  verdict — the same reachability/compositionality refinement
  `totality.md:141–143` and edge 9 name for the port-set check. Whoever builds
  E44 should reuse the group machinery, not re-derive it.
- **→ E40/E43 (capabilities/broker):** E45's D2 gate is a broker grant; the
  reflective-floor decision note should be co-read by the broker family.
- **→ E3/E13 (kernel/terms):** the `eval_term` Var negative-index wrap
  (`kernel.py:222–223`) — add a bounds assert; found via E48 analysis, owned
  by the kernel family.
- **Candidate E51:** the **obligation ledger / witness registry** — the shared
  artifact between the totality classifier, refinement entailment, verify
  rows, preserve-check, and E46's document layer. It is currently smeared
  across `sig.totality`, exception strings, and report tuples; naming it one
  element would give E46, E47, and E50 a common landing surface.
