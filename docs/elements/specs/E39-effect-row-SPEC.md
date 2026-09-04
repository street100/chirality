---
element: E39
slug: effect-row
title: Effect algebra / typed rows (alarms, counter-effects)
kind: BUILD-PROPER
example: examples/E39-effect-row.md
status: audited
updated: 2026-07-27
---

# E39 SPEC — Effect algebra / typed rows (alarms, counter-effects)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.
>
> **Review class: trusted-core carrier edit.** The `eff` field on the Pi/VPi
> carrier is part of the kernel value form. This is reviewed as a kernel change
> (conv, eval, quote), never as a module change — even though the *judgment*
> seams (infer/check) keep their shape and the membrane policy stays in
> `effects.py`. The carrier tuple widens its position-2 field type in place;
> the seat count is FROZEN (`docs/decision-effect-facets.md`, "The carrier").

## 1. Deliverable

- **After this runs:** the coarse pure/process `eff` **bool** on the Pi/VPi
  carrier is a typed **effect row** — a canonical set of crossing-names — and
  the three membrane seams read it structurally: `conv` keeps row **equality**
  while `subtype` compares rows by **subsumption** (directional, contravariant
  domains — Step 3), `effects.py` gates by **set-containment**
  (not boolean), and a function's row is **inferred from the crossings it
  transitively performs** (the call graph), with `->` = the empty row and `=>`
  = a nonempty row. The coarse bit survives as the `empty?/nonempty?`
  projection of the row, so every existing membrane behavior is unchanged.
- **Non-goals (residue in §6):** the `with-handler`/`raise` surface sugar and
  the synthesized-cancel branch elaboration (E26 — the example already
  *verified* these need zero new kernel forms, so they are a downstream
  untrusted elaborator, not part of this carrier edit); row **polymorphism**
  (the row-variable seat is reserved in the carrier but unpopulated); declared
  row **bounds** at module/profile boundaries (E51); capability reification of
  the ambient **Console** externs (Lane-1 follow-on commit after this carrier
  edit — see disposition d; Clock/Timer/Env reification is **E32's**, per its
  author-resolved 2026-07-27 dispositions); cross-node alarm mobility
  (edge 17); grade↔row interaction (E38).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** E39 is **REFACTOR (L)** — "Replace eff bool with
  a typed effect ROW; conv equality→row subsumption; effects.py seams→set
  containment; allow_eff threading bool→row; surface.py per-arrow effect;
  terms.py Pi pos-2 field type; prim_is_port derivation." The sibling
  **DECISION** row is closed: edge 16 was resolved 2026-07-21
  (`docs/decision-effect-facets.md`), so the row shape is now buildable as an
  **EXTEND of the existing bit**. E39 **gates E26** (alarms) and is the stated
  remaining gate on **E51** (sys-face linkage: "remaining gate is the E39 row
  shape"). The membrane itself (`E12`, coarse bit) is **CONFORMS/Built** — this
  spec grows it, it does not rebuild it.
- **Live code this composes with (verified present, do NOT respec):**
  - `terms.py:62` — the Pi carrier is the tuple `("Pi", q, eff, name, dom, cod)`;
    position-2 `eff` is a plain bool today; the shift/traversal treats it as an
    opaque leaf annotation (no de-Bruijn shift on it).
  - `kernel.py:239` eval `Pi→VPi` carries `t[2]` through; `kernel.py:352` quote
    carries it back; `kernel.py:291-292` conv compares `VPi` and the effect at
    `a[2] != b[2]` (`# quantity and effect are part of the type`).
  - `effects.py` — `on_apply` (l.22, the guard `if eff and not allow_eff` l.25)
    and `erased_allow` (l.40) are the boolean membrane seams; `allow_eff`
    threads through `K.infer`/`K.check`, `data.py`, `refine.py`.
  - `surface.py:372` — `cod = ("Pi", q, eff and is_last, bname, ty, cod)`: the
    per-arrow attachment point (effect rides the LAST arrow only).
  - `kernel.py:586-592` (`declare_extern`) — the existing **derivation** of
    `prim_is_port` from the eff bit (`is_port = is_port or tyv[2]`): the seed
    set for row inference, and a direct reshape site (bit read → row-nonempty
    read). `lower.py:91` / `surface.py:184,488` are its consumers.
  - `runtime.py:174` — `mainty[0] == "VPi" and mainty[2]`: main's process-gate
    reads the bit directly (the membrane's observable projection site).
  - `bridge.py:26,77` — VPi walkers used by `bridge.verify` placement.
- **True delta:** widen the position-2 field at every carrier site (bool → a
  frozen **seat record** carrying the `Row` + the reserved grade/totality
  seats); keep `conv` **equality** and put row *subsumption* in `subtype` (a
  new VPi case with correct variance — see Step 3); make `effects.py`
  set-containment; add a monotone call-graph **row-inference** pass at
  elaboration time (two-pass load unit); keep the coarse bit alive as
  `row_nonempty?`. The seat count is frozen in this one edit; no new kernel
  *term* form is introduced.
  [2nd-order audit 2026-07-22: earlier draft put subsumption in `conv`
  (unsound — contravariant domains at `kernel.py:294` + symmetric equality
  reuse) and ran inference post-checking in `lower.py` (incoherent — the Pi
  field is the checking *permission* at `kernel.py:480`, consumed before any
  lower pass). Both corrected below; the same correction is noted in the bank
  §5a, the LANE-1 handoff, and the example §6.]

## 3. Decisions

Every open question from example §6, dispositioned. RESOLVED items are
derivable from a settled doc (cited); genuinely novel design is surfaced.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| a | Concrete row **representation** — set-of-crossing-names vs porttype-keyed structure | **RESOLVED — set-of-crossing-names** | The reshape (`docs/banks/effect-and-alarm.md` §5a + `docs/decision-effect-facets.md`) fixes the `effects.py` seams as **set-containment** and subtyping as **row subsumption** (in `subtype`, not `conv` — Step 3) — both are subset operations over a set of names, which is a *set* representation, not a porttype-keyed map. **Canonical form = the sorted, de-duplicated tuple of crossing-names** (`row_key`); this is a *total* canonical form (total order on names ⇒ unique normal form), which is exactly what the call-graph fixpoint needs for its "reached?" equality test. **Determinism implication:** inference is a monotone fixpoint over the finite lattice `℘(crossing-names)`; the sorted-key form gives decidable, order-independent equality, so the fixpoint is deterministic — this is the property Lane prep depends on. A porttype-keyed structure would carry more than subsumption/containment require and is rejected as over-build: an abstraction that constrains nothing is overhead. The **row-variable seat** is reserved as a second, unpopulated field (`Row = (names, rowvar=None)`) per `decision-effect-facets` "The carrier". |
| b | **Recoverable-vs-fatal in the type** — which `KontMsg` constructors the alarm protocol offers | **RESOLVED — carried by the handler extern's declared continuation type, not by a row-entry field** | Example §5 + the verified zero-new-kernel-forms hypothesis: `KontMsg` is an ordinary `data` decl; a fatal-only alarm's handler extern declares its continuation at `(=> (1 m (KontMsg-cancel)) Res)` offering `k-cancel` alone, a recoverable one offers both. Enforcement is structural — if the sum has no `k-resume`, the CPS `case m` cannot write a resume branch (`data`/`case` do the work). No new row-entry shape is needed: **the row names the crossing; the crossing's extern signature carries the `KontMsg`.** The *surface naming* of alarm protocols (the `with-handler`/`raise` sugar that picks the sum) is E26's, deferred with non-goal §1. |
| c | **Declared-row syntax** at module/profile boundaries | **DEFERRED → E51** (per-arrow *attachment* is in scope here; boundary *bounds* are not) | `decision-effect-facets`: "declared bounds only at module/profile boundaries." E39 delivers the per-arrow row *attachment point* (`surface.py:372`) that inference writes into, but the boundary-declared-bound clause (analogous to the profile `(total)` clause) is where the row meets the sys seam — E51's stated job ("threads the row through the sys seam"). Building the boundary syntax now would front-run E51's threading and is scoped out (P2, don't over-build). |
| d | **Cap reification** — the **Console** porttype handed to `main` by the profile, closing the ambient writers `print/put/trace` | **DEFERRED → Lane-1 follow-on commit (NOT E51)** | Out of the *carrier edit's* scope — reification consumes the row mechanism rather than constituting it, so it must not entangle the trusted-core diff. But it stays **Lane 1's obligation**: `.planning/handoffs/LANE-1-effect-row.md` scopes it into this lane explicitly (the P1 no-ambient-authority closure `decision-effect-facets` names), and it is a `lib/ports.chiral` + profile change, not a sys-tal routing change. Sequencing: carrier edit lands green (commits 1–5 below), reification lands on top as the lane's next commit. [Orchestrator audit 2026-07-22: earlier draft deferred this to E51, conflicting with the lane handoff — reconciled as above.] [Audit 2026-07-27: **Clock/Timer/Env reification moved OUT of this row** — the E32 SPEC (author-resolved 2026-07-27) now owns it, with the Clock/Timer **split** (its decision #4) and errno-carrying `TimeR`/`SleepR`/`EnvR` sums, superseding this SPEC's earlier single-`Clock` scope and the lane handoff's listing. Step 7 narrows to Console. The Console writers' shape at E51-bind time is a **flagged author question** (E51 SPEC decision 5 binds them ambient) — surfaced in the audit report, not resolved here.] |
| e | **`env-get` as a row entry** — incoming deferral, E32 SPEC decision 1 (2026-07-27) | **RESOLVED — discharged by this SPEC's mechanism** | Ratification is structurally forced by Step 5's seed: every extern whose type carries an effect arrow enters the row under its own crossing name (`prim_is_port`, `kernel.py:586-592`); `env-get` is declared `(=> Str Str)`, so it is a row entry `{env-get}` with no exemption path. E32's provisional stance ("a crossing is an observation or mutation of the world, not a syscall") is confirmed by construction. |
| f | **errno alarm-vs-value** — incoming deferral, E51 SPEC decision 2b (2026-07-27) | **RESOLVED (mechanism) / residue (classification)** | The half deferred here — recoverable-vs-fatal *placement in the type* — is disposition (b): the crossing's handler extern carries the `KontMsg` sum; no row-entry field. The *per-errno classification* (which wrapper errnos become alarm crossings vs ordinary result values) is per-wrapper alarm-protocol design that needs E26's alarm surface on top of this row — it rides **E26 + the sys wrappers** (E51's own text: "Decisions 2a/2b stay the convention those wrappers follow"; errno-as-value demo rides E29). Named in §6 residue. |
| g | **row⇄sysface correspondence (E39 half)** — incoming deferral, E51 SPEC decision 4 (2026-07-27) | **RESOLVED — discharged by disposition (a)** | The concrete row shape E51 waits on is settled here: set-of-crossing-names, sorted-tuple canonical form. E51's binding table keys on extern name, which is exactly the row's entry name — forward-compatible as its SPEC states. The row's tal shadow stays **E70** (the other half of that deferral, untouched here). |

No blocking NEEDS-AUTHOR → frontmatter stays `status: draft`.

## 4. Change plan (ordered, commit-sized)

### Step 1 — The `Row` value + canonical form (new leaf module)
- **Target:** new `scaffold/chirality/row.py` (small; a leaf, imported by kernel/
  effects/surface/lower).
- **Change:** define `Row = (names: tuple[str,...], rowvar)` where `names` is
  always stored as the sorted, de-duplicated tuple (the canonical `row_key`)
  and `rowvar` is the **reserved, frozen** seat (always `None` this build).
  Helpers: `EMPTY_ROW`; `row_of(iterable)`; `row_union(a,b)`;
  `row_subsumes(sub, sup)` = `set(sub.names) <= set(sup.names)` (and `rowvar`
  compat: `None` on both for now); `row_nonempty(r)` = `bool(r.names)`;
  `row_key(r)` for fixpoint equality. Truthiness of a `Row` = `row_nonempty`
  (so legacy `if eff:` reads keep working during migration).
- **Size:** ~S.

### Step 2 — Widen the carrier's position-2 field (bool → frozen seat record)
- **Target:** `surface.py:372` (build), `terms.py:62` (traversal),
  `kernel.py:239` (eval), `kernel.py:352` (quote).
- **Change:** position-2 becomes a **seat record** `Seats = (row: Row,
  grades: None, totality: None)` — the row populated now, the grade-vector and
  totality-mark seats laid down **reserved** (always `None` this build). This
  is the decision's "seat count frozen now" clause honored in full
  (`decision-effect-facets` "The carrier"; LANE-1 "Freeze the seat count now;
  do not fork the slot"): E38 grades and Lane-2 totality later *populate* a
  reserved seat — they never reshape the carrier again. The record sits at
  position 2 so positions 3/4/5 (`name`/`dom`/`cod`) — and every walker over
  them — are untouched (minimal trusted-core diff; adding a new field to
  `Seats` later is the forbidden fork). Truthiness shim lives on `Seats`
  (= `row_nonempty(seats.row)`). `->` builds `Seats(EMPTY_ROW)`; a parsed
  `=>` gets its row **stamped by Step 5's elaboration-time inference** (no
  placeholder is ever visible to the checker — see Step 5's ordering). Also
  parse an *optional* explicit per-arrow row annotation (attachment only — no
  boundary-bound checking; decision (c)). `terms.py:62` keeps position-2 an
  opaque leaf (no shift); `kernel.py:239`/`:352` carry it through eval/quote.
- **Size:** ~M.
  [2nd-order audit: earlier draft widened only the row field, silently
  narrowing the decision's full seat-freeze — E38/Lane-2 would each have
  needed another carrier surgery. Corrected to the full frozen record.]

### Step 3 — Row subsumption lands in `subtype`; `conv` keeps equality
- **Target:** `kernel.py:291-292` (conv, comment only + `Seats` read),
  `kernel.py:315-324` (`subtype` — gains its first `VPi` case).
- **Change:** `conv`'s VPi branch stays **strict equality** —
  `row_key(a[2].row) == row_key(b[2].row)` (and quantity equal) — because
  `conv` is a symmetric definitional-equality relation reused in positions
  where subsumption is wrong: it compares Pi **domains** at `kernel.py:294`
  (contravariant) and is the equality base for VTCon/VCon/VNe args and
  `refine.py:227,239`. Directional subsumption goes into **`subtype`** as a
  new `VPi` case: `subtype(a, b)` (a usable where b expected) holds iff
  quantities equal, `row_subsumes(a.row, b.row)` (pure fits an effectful
  hole, never the reverse), **domains flipped** `subtype(b.dom, a.dom)`
  (contravariant), codomains `subtype(a.cod, b.cod)`. The single directional
  call site is `check`'s `subtype(ity, expected)` at `kernel.py:506` — pinned
  red-then-green by conformance tests 3 and 5.
- **Size:** ~M (small diff, highest review scrutiny — trusted core).
  [2nd-order audit: earlier draft put `row_subsumes` inside `conv`, which
  accepts `(-> (-> A B) C) <: (-> (=> A B) C)` — an effectful function
  through a pure-parameter hole via the contravariant domain — and breaks
  conv's symmetry. Corrected: conv = equality, subtype = subsumption.]

### Step 4 — `effects.py` seams + `allow_eff`→`allow_row` threading (total)
- **Target:** `effects.py:22-42` (`on_apply`, `erased_allow`); the `allow_eff`
  parameter across `kernel.py` `K.infer`/`K.check`, `data.py`, `refine.py`.
- **Change:** `allow_eff` (bool) → `allow_row` (the row permitted in this
  context; a `->` context = `EMPTY_ROW`). `on_apply`'s guard `if eff and not
  allow_eff` → `if not row_subsumes(fn_row, allow_row)`. `erased_allow`
  returns `EMPTY_ROW` at quantity 0, else passes `allow_row` through. The
  rename is NOT purely mechanical — these sites **create** the value from a
  bare literal and must each become `EMPTY_ROW` explicitly (a `False` fed to
  `row_subsumes` is an `AttributeError`, not a wrong answer):
  `kernel.py:513` (`expect_universe` → `infer(..., False)`), `kernel.py:552`
  (`finish_def` → `check(..., False)`), `data.py:112`, `refine.py:177`,
  `refine.py:187`; and `kernel.py:480` sources the value from the Pi field
  itself (`eff` → `seats.row` after Step 2). Behavior with only
  empty/stamped rows is verdict-identical to today.
- **Size:** ~L (broad; the six enumerated sites are the non-mechanical part).
  [2nd-order audit: earlier draft named target *files* only; the bare-literal
  sites above would have crashed a faithful mechanical rename.]

### Step 5 — Row inference at ELABORATION time (two-pass load unit)
- **Target:** `surface.py` load-unit elaboration (new pre-check pass), seeded
  by `sig.prim_is_port` (derived at `kernel.py:592`).
- **Change:** the load unit becomes **parse-all → infer → stamp → check**:
  (1) parse the unit's toplevel forms without checking; (2) build the
  name-level call graph from def bodies (call targets are globals/externs by
  name — syntactically computable); (3) run the monotone fixpoint over
  `℘(crossing-names)`: a def's row = `row_union` of the rows of externs it
  calls (an extern's row = its own crossing name, seeded from
  `prim_is_port`) and of the (already-computed or in-SCC) rows of globals it
  calls, iterated to fixpoint by `row_key` equality — handles recursion and
  mutual recursion; imports are already loaded so their rows are final;
  (4) stamp each declared Pi's `=>` seat with its inferred row; (5) run
  `check_def` in declaration order as today. The kernel then *enforces* the
  stamp structurally: `on_apply` demands callee-row ⊆ context-row, where the
  context row descends from the stamped declaration via `kernel.py:480` — an
  under-stamped row is **rejected** at the offending apply; an over-stamped
  row is sound over-approximation (declared-but-unperformed crossings).
  Inference is an untrusted producer; the judgment re-checks — certificate
  discipline, per the decision ("row inference … untrusted producers").
  Holding ≠ crossing falls out: holding a `Sock` contributes nothing to the
  call-graph union; calling `sock-close` contributes `{sock-close}`.
  **Determinism caveat (Lane-prep coupling):** every `Row` must be built
  through `row_of` (which sorts); no Python set/dict iteration order may
  reach a stored tuple directly — the canonical form is only as good as
  "always re-sort, never trust insertion order."
  **Named edge:** a crossing-free def declared `=>` infers `EMPTY_ROW` and
  becomes pure (its `=>` is vacuous) — verify no existing test declares a
  crossing-free `main` before relying on gate test §5.1; if one exists, the
  main gate reads the declared surface marker, not row-nonemptiness, and
  says so in a comment.
- **Size:** ~L (the genuinely new logic + the load restructure).
  [2nd-order audit: earlier draft ran inference in `lower.py` AFTER checking
  — but the Pi field is the checking *permission* (`kernel.py:480`), so the
  precise row must exist before `check_def`. Inference moved to elaboration;
  this is also the decision's own wording ("inferred by elaboration").]

### Step 6 — Main gate + `bridge.verify` projection
- **Target:** `runtime.py:174`; `bridge.py:26,77` placement.
- **Change:** `mainty[2]` (bool read) → `row_nonempty(mainty[2].row)`; VPi
  walkers in `bridge.py` treat position-2 as a `Seats`. This is the
  coarse-bit projection that keeps the membrane's observable behavior
  identical (modulo Step 5's named crossing-free-`=>` edge).
- **Size:** ~S.

### Step 7 — Console reification (the lane's P1 closure; separate commit)
- **Target:** `lib/ports.chiral:70-72` (the ambient writers) + the profile
  machinery (`sig.profiles`, `surface.py` profile forms) + `runtime.py` main
  invocation.
- **Ordering (author, 2026-07-28): E51's v1 binding lands FIRST.** E51's
  audited design rests on "transport swap, must not touch decls" — Console-
  first would invalidate that premise. This step then re-threads the bound
  wrappers when it lands (a mechanical wrapper update: the writers' signatures
  gain the Console parameter and the E51 table rows re-point). Steps 1–6
  landed 2026-07-28; this step is the element's open remainder.
- **Change:** reify **Console** as a porttype; the ambient writers
  `print`/`put`/`trace` take the capability as a parameter; the profile hands
  it to `main` the way `spawn` hands `node-main` its peer port
  (decision-effect-facets: "reified as porttypes in the port floor, handed to
  `main` by the profile"). Lands as its **own commit after Steps 1-6 are
  green** — it consumes the row mechanism and must not entangle the carrier
  diff (disposition d). **Clock/Timer/Env reification is E32's** (audit
  2026-07-27, disposition d): its SPEC delivers those porttypes with the
  Clock/Timer split and errno-carrying sums — do not build them here. The
  ordering of this commit against E51's v1 binding of the same three writers
  is the flagged author question in disposition d.
- **Size:** ~M (was ~M for three capabilities; Console-only is the smaller
  end of it).
  [2nd-order audit: earlier draft left reification in disposition-(d) prose
  with no step and no gate test — an implementer running the plan to green
  would have shipped the lane with its motivating P1 closure unbuilt.]

## 5. Conformance gate

- **Golden behavior:** the effect membrane is now row-typed but bit-compatible:
  the pure/process wall stands exactly where it did (via `row_nonempty`), while
  the row additionally records *which* crossings and is inferred from the call
  graph rather than from what a function holds.
- **Tests to add** (new `scaffold/tests/test_effect_row.py`; regression in
  `test_process_externs.py` / `test_kernel.py`):
  1. **Membrane regression (all floors):** every existing membrane test in
     `test_process_externs.py` + `test_kernel.py` stays green with the bit read
     as `row_nonempty` — the reference checker's accept/reject verdicts are
     unchanged, and reference-vs-native execution of the membrane examples
     still agrees.
  2. **Pure plumbing stays pure (holding ≠ crossing):** a `->` function that
     takes a `RecvR` holding a `Sock`, repacks it, and returns it — crossing
     *nothing* — type-checks as pure (`EMPTY_ROW`). Checker-verdict test.
  3. **Nonempty-row call in a `->` context rejected:** a `->` function body
     that calls a crossing (nonempty row) is **rejected** at `on_apply`
     (set-containment, Step 4; the directional case is `subtype`, Step 3)
     — pins the subsumption orientation of Steps 3-4. Checker-verdict test
     (expect type error).
  4. **Row inferred from the call graph, not port-holding:** two functions over
     the same `Sock` — one that only holds/returns it infers `EMPTY_ROW`, one
     that calls `sock-close` infers `{sock-close}` — asserted on the inferred
     row directly (Step 5). Differential across the reference checker's
     inference; execution unaffected.
  5. **Contravariant-domain rejection (pins Step 3's subtype placement):**
     `(-> (-> A B) C)` must NOT be accepted where `(-> (=> A B) C)` is
     expected in the direction that would run an effectful function through a
     pure-parameter hole; and `conv` on two Pis differing only in row is
     False both ways (equality stays symmetric). Checker-verdict test.
  6. **No-ambient-authority (pins Step 7):** after reification, an ambient
     `print` crossing with no Console capability in scope is rejected; a
     profile-handed Console makes the same program check. Checker-verdict
     test (lands with Step 7's commit).
- **Green line:** **281 → ≥ 287** (baseline 281 test fns across 22 test files
  all green; ≥6 new); `ledger-lint.py` clean; CONFORMANCE-MAP E39 row flips
  REFACTOR→built after implementation.
- **Done when:** the carrier's position-2 field is the frozen `Seats` record
  at every site, `conv` is equality and `subtype` carries row subsumption
  with correct variance, `effects.py` is set-containment, a function's row is
  elaboration-time call-graph-inferred with a deterministic canonical form,
  the ambient Console writers are reified (Step 7 commit; Clock/Timer/Env
  ride E32), tests 1-6 pass, and the 281 baseline is still green with zero
  new kernel term forms.
- 2026-09-04: the Python oracle was cut, and scaffold/ went with it in the 2026-08-31 migration. The citations it left are kept as a record and have no live successor.

## 6. Residue & links

- **Deliberately unbuilt (with homes):**
  - `with-handler`/`raise` surface sugar + synthesized-cancel branch
    elaboration → **E26** (untrusted elaborator; zero-new-kernel-forms already
    verified by the example, so no kernel work owed).
  - Row **polymorphism** — the `rowvar` seat is reserved and frozen but
    unpopulated → higher-order effectful code; neighbors **E38** grade seats.
  - Declared row **bounds** at module/profile boundaries → **E51**.
  - Capability **reification** of the ambient Console writers → **Lane-1
    follow-on commit** (Step 7, disposition d); Clock/Timer/Env reification →
    **E32** (its SPEC, author-resolved 2026-07-27).
  - Per-errno **alarm-vs-value classification** (incoming deferral, E51
    disposition 2b) → the placement mechanism is disposition (b) here; the
    classification itself rides **E26 + the sys wrappers** (disposition f).
  - Cross-node alarm **mobility** (continuations move within a node only) →
    **edge 17** (carries evidence only).
  - Grade↔row **interaction** → **E38**.
- **Follow-on (this unblocks):** **E26** (alarms ride the row), **E51** (threads
  the row through the sys seam — the real self-host gate), **E70** (lowers the
  row).
- **Related:** [[E39-effect-row]] · `docs/decision-effect-facets.md` (edge 16,
  the carrier) · `docs/banks/effect-and-alarm.md` §5a (the authoritative reshape
  list) · [[E12]] (the coarse-bit membrane being grown) · [[E38]] (grade seats).
