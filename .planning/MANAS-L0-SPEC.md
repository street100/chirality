# manas L0 — recursive Flow + branch⇄backtrack + tiny-step contract — SPEC (2026-08-17)

Implements L0 of `MANAS-SKILL-GROWER.md` (rev2). User: re-open the manas core (modular,
in-dev), shape the ⊕ rows +. This is the core-type + engine design pass. Nothing here
is implemented yet; §7 sequences the slices.

## 0. Principle (the acceptance criterion, not a slogan)
Every leaf = a **tiny step**: one small question + `sees` context on all sides + a small
typed return, sized for a **tiny model**. A composition is CORRECT only if every leaf
runs green on the 0.5b `smoke-local` config (**TINY-MODEL-GREEN**). A leaf that needs a
bigger model is under-decomposed = a defect.

## 0.5 THE GUARANTEE — typed composition (compose whatever with whatever, safely)
User bar: *"as long as we can compose whatever with whatever within a type system, we're
good."* Recursive `Flow` gives **structural** nestability; the **type system** gives
**safe** nestability. Every Flow is a **typed arrow** `in-Ty → out-Ty`; a pure
compositional checker `flow-ty` decides if a composition is legal. **Any Flow nests in
any composite IFF `flow-ty` approves.** This fulfils the Expert type's own TODO
("LENS/SEES/RETURNS are prose... typed I/O is target work") — `sees`/`returns` become
**types**.

```
(data Ty ()                 ; payload types — a small CLOSED sum, EXTENSIBLE (modular/in-dev)
  (ty-doc) (ty-span) (ty-findings) (ty-patch) (ty-verdict)
  (ty-perspectives) (ty-part) (ty-text))         ; ty-text = the opaque escape hatch
(data Arrow () (arrow (dom Ty) (cod Ty)))
```
**Modular choice:** the leaf `flow-step` carries its own `(in-ty, out-ty)` — the Flow is
**self-typing**, so `Expert` is UNTOUCHED in L0 (deriving a step's arrow from a typed
Expert `sees`/`returns` is a later, additive refinement). The **compositional
type-checker** is the whole point:
```
flow-ty : (-> Flow (Maybe Arrow))
;  flow-step e i o -> arrow(i, o)                 ; leaf carries its own arrow
;  flow-chain [f…] -> fold: compose iff cod(fᵢ) = dom(fᵢ₊₁), else NONE
;  flow-fan  [f…]c -> all dom equal (=A); combiner : product(cods) -> B ⇒ arrow(A,B)
;  flow-gate rls c -> like fan over the gated experts
;  flow-branch p pp bt -> p:A->ty-perspectives; pp:(A×Perspective)->P; bt:(List P)->B ⇒ arrow(A,B)
```
**Composition rule:** a Flow is well-formed iff `flow-ty` returns `some`. The editor,
the builder's accept-gate, and `run-flow` all refuse an ill-typed Flow. Ty-compatibility
starts as equality (subtyping is a later, additive refinement). `flow-ty` is PURE →
unit-testable offline (no mesh). Door open to promoting `Ty` to full chirality types (skills
as dependently-typed programs) later.

## 1. The recursive Flow type — ADDED alongside the flat Pipeline (NOT a re-cut)
The flat `Pipeline` (and everything typed against it — scriba outline/N2/persist) stays
UNTOUCHED. `Flow` is a NEW, parallel composition type; the legacy pipeline is **lifted**
into it. Purely additive → zero churn to the shipped editor/persistence.
```
; a Flow is the fractal composition tree. The leaf is a tiny step (self-typing).
; SHIPPED (scaffold/lib/manas/core/flow.chiral, slice 1). Self-typing rule: a node
; that refs an Expert/combiner BY ID (untyped in L0) carries EXPLICIT arrow fields;
; a node that composes Flow CHILDREN derives its arrow. So flow-fan carries out-ty
; (its combiner is by-id) and flow-branch carries in-ty (its perspectivist is by-id);
; both were added vs the design sketch so every case self-types.
(data Flow ()
  (flow-step   (expert-id Str) (in-ty Ty) (out-ty Ty)) ; LEAF: one tiny step + its arrow
  (flow-gate   (rules (List GateRule)) (combiner Str) (in-ty Ty) (out-ty Ty)) ; today's GATE (self-typed: refs experts by id)
  (flow-fan    (steps (List Flow)) (combiner Str) (out-ty Ty)) ; parallel on shared (derived) dom; combiner by-id -> carries out-ty
  (flow-chain  (steps (List Flow)))                    ; sequence: output -> next input (fully derived)
  (flow-branch (perspectivist Str)                     ; a tiny step that EMITS perspectives (by id: A -> ty-perspectives)
               (in-ty Ty)                              ; A, the branch input (carried — perspectivist is by-id)
               (per-perspective Flow)                  ; the sub-flow run for EACH perspective (arrow derived)
               (backtrack Flow)))                      ; paired consolidate+audit sub-flow; branch cod B = backtrack's cod (derived)
```
`flow-ty` on `flow-branch` requires per-perspective AND backtrack to type-check
(`some`), then types the branch as `arrow(in-ty, cod(backtrack))`. No product type
in L0, so per-perspective's dom is left opaque (honest residue).
`Flow` is recursive → **pipelines nest** (a branch's `per-perspective` and `backtrack`
are themselves Flows). The "big question" never exists — only tiny leaves + operators.

**The lift** (preserves doc-refine by construction, no type change):
```
pipeline->flow : (-> Pipeline Flow)     ; a flat Pipeline -> (flow-gate its-gate its-combiner)
```
A fractal pipeline is authored as a `Flow` directly; a legacy flat one is lifted. `Pipeline`
itself is unchanged. (Later, a `FlowPipeline` record can carry a `Flow root` for
natively-fractal skills — additive, when the editor learns to author them.)

### Semantics of each Flow case (what `run-flow` does)
| Case | Run semantics | Result |
|---|---|---|
| `flow-step e` | one `be-chat` on `e`'s slot-bound model, `sees` injected | one ExpertOutcome |
| `flow-chain [f…]` | run f₁, feed its output as the next's input, … | the last's outcome |
| `flow-fan [f…] c` | run all fᵢ on the same input in parallel, `c` merges | CombinerOutcome |
| `flow-gate rules c` | fire the rules whose condition matches (today's plan-run→fan→combine) | CombinerOutcome |
| `flow-branch p pp bt` | `p` emits perspectives → run `pp` once per perspective (recursion) → `bt` consolidates+audits the **individual** per-perspective outputs | the backtrack's outcome |

## 2. doc-refine maps in with ZERO behavior change (modularity proof)
Today's `doc-refine` (gate + fan-out + curate-merge) **is** exactly:
```
(pipeline "doc-refine" "<when>"
  (flow-gate doc-refine-gate "curate-merge")   ; <- the whole current pipeline is ONE flow-gate
  (stop-until-dry 8) "revised_doc + ...")
```
So `run-flow` on a `flow-gate` calls the existing `plan-run`→`fan-experts`→`call-combiner`
path unchanged. The flat model is the degenerate Flow — no regression, and the CONFORM
golden still holds for doc-refine. New power (chain / branch / backtrack / nesting) is
strictly additive.

## 3. The ⊕ slots — shaped (capability classes; a Config binds each → model)
| Slot | The tiny job (one small ask) | Returns | Notes |
|---|---|---|---|
| cheap-verifier | a single cheap check | pass/fail + 1 reason | ✓ exists |
| reasoner | one small reasoning step | one small conclusion | ✓ exists |
| combiner | merge a handful of small results | merged text + accepted ids | ✓ exists |
| **perspectivist** ⊕ | "what 2–4 distinct angles/questions apply here?" | a short `(List Perspective)` | drives `flow-branch`; small fan-out degree |
| **auditor** ⊕ | "does THIS consolidated result hold? contradiction/gap?" | verdict + ≤N reasons | used in `backtrack`; ≠ combiner (checks, doesn't merge) |
| **editor** ⊕ | "rewrite THIS span to satisfy THIS point" | a minimal patch | doc-EDIT; needs the write effect (L6) to land |
| **code-context** ⊕ | "what does THIS symbol/example do?" | one small fact | language-aware `sees` for code |
| **author** ⊕ | "draft the Part (Expert/Flow) for THIS role, as JSON" | a JSON Part | the tool-builder's producing slot |

`Perspective = (perspective (question Str) (sees-extra (List Str)))` — the perspectivist
emits a small list; the branch injects each into `per-perspective`'s `sees`.

## 4. The tiny-step contract + lint (L0.5)
Every `flow-step`'s Expert must satisfy:
- **small question** — `lens` asks ONE thing (heuristics: single clause, no "and also",
  bounded length);
- **context on all sides** — `sees` non-empty and names the surrounding context it needs;
- **small return** — `returns` is a bounded typed shape.

`bin/manas-lint.py` (new) flags violations statically (question too big / `sees` thin);
the runtime gate is **TINY-MODEL-GREEN** (§0). A skill isn't "done" until lint-clean +
tiny-model-green.

## 5. The audit step is first-class (L0.3)
`backtrack` is a Flow, typically `flow-chain([<consolidate>, <audit>])`:
- **consolidate** (combiner slot): merge the individual per-perspective outputs;
- **audit** (auditor slot): check the merged result — contradictions, gaps, does it
  answer the branch's question. A failed audit is a VALUE (verdict), which STOP can loop
  on or which flags upward. Audit never silently passes.

## 6. Engine: `run-flow` (recursive interpreter)
`run-flow : (=> (1 b Backend) Flow <ctx> Result)` — one recursive interpreter, cases per
§1 table. Reuses `call-expert`/`call-combiner`/`plan-run`/`assemble-manifest`. The
RunManifest grows a tree shape (nested calls) so scriba's run-view (S15/S17) renders the
fractal — each branch/backtrack a nested, streamable node. STOP loops the root Flow.

## 7. Slices (each a later single-lens agent; core-type + engine)
1. **DONE 2026-08-17 (`5eef5b4`) — Flow type + `flow-ty` + `flow-gate` (additive).**
   New `manas/core/flow.chiral` (Flow/Ty/Arrow/flow-ty/pipeline->flow/run-flow) +
   `flow-test.chiral` + `manas-flow-conform.chiral`. `run-flow`'s flow-gate arm is a
   **literal `(run-pipeline …)`** call (runner.chiral UNTOUCHED) → conformance by
   construction. Gates green: (a) flow-ty unit test exit 0 (doc-refine→ty-doc→ty-doc,
   ill-typed chain→none) — INDEP-VERIFIED; (b) doc-refine `CONFORM: true` live vs the
   golden + structural (literal delegation). Additive confirmed: runner/types/profile/
   scriba untouched, scriba rebuilds identical (1044856 B) — the agent's "scriba
   zb-move broken" was a FALSE ALARM (did not reproduce). **Slice-1 limitations
   (owned by slices 2/3):** a hand-authored `flow-gate` NOT backed by a pipeline in
   `pipes` → `plan-no-route`; `flow-step` run is a single call-expert; chain/fan/branch
   RUN = honest `"flow-unimplemented"` marker.
2. **DONE 2026-08-17 — `flow-chain` + `flow-fan` actuation in `run-flow` + the typed seam.**
   `refine-ok : (-> Ty Str Bool)` (NAMED refine-ok — `refine` is the reserved
   refinement-type surface form, parse.chiral:187) — MINIMAL/LENIENT per-Ty validators
   (ty-doc/ty-text/most = non-empty; ty-findings = a "["/"kind" shape), sharpen
   additively. `flow-chain` = sequential output→input: run fᵢ on the running text,
   REFINE its yield against `flow-out-ty fᵢ` at the seam (false ⇒ typed-error RunR
   `flow-refine-fail:<ty>`, stop — never a silent continue), the refined yield feeds
   fᵢ₊₁; calls + raws concat FLAT (no RunManifest change). `flow-fan` = same doc to
   every child (sequential exec, independent inputs), each yield wrapped as a Finding,
   the by-id combiner merges; manifest = children's calls + the synthesized combiner
   call. Backend q1-linear, moved once per path (B1-enforced). empty chain/fan +
   unresolved combiner = honest empty RunR. `flow-branch` stays `"flow-unimplemented"`
   (slice 3). Gates green: (a) PURE refine-ok unit tests in flow-test.chiral (ty-doc
   ""/non-empty, ty-findings shape/non-shape) — B1 compiles, exit 0; (b) LIVE
   (`100.64.0.5:11434`, `samples/manas-flow-live.chiral`): a 2-step chain
   (example-completeness→curate-merge) proved `step2-prompt-contains-step1-output: true`
   (step1 178B), a 2-lens fan (coverage-vs-spec + cross-doc-drift → curate-merge)
   produced 3 expert-calls (2 children + combiner), exit 0. Additive confirmed:
   only flow.chiral + flow-test.chiral touched (+ the new live sample); doc-refine
   still `CONFORM: true`; scriba rebuilds identical (1044856 B).
3. **DONE 2026-08-17 — `flow-branch` + backtrack (the fractal heart).**
   `Perspective = (perspective (question Str) (sees-extra (List Str)))` + `parse-perspectives`
   (LENIENT: JSON-array-of-objects preferred — the runner's forced-JSON shape, one object
   per perspective; one-perspective-per-non-empty-line fallback for non-JSON), both in
   `flow.chiral` (NOT core/types — additive, keeps the shared model pristine). `flow-branch`
   run: resolve+run the perspectivist by id → `refine-ok ty-perspectives` → parse (empty ⇒
   honest `flow-branch-no-perspectives` RunR) → run `per-perspective` ONCE PER perspective
   **recursively via run-flow** (question injected into doc + `(pair "perspective" q)` +
   `sees-extra` into extra), threading the q1 linear Backend sequentially, collecting each
   yield (the individuals) → run `backtrack` **recursively via run-flow** on the joined
   individuals. Manifest = perspectivist call ∷ per-perspective calls ++ backtrack calls
   (FLAT concat, no RunManifest change). Backend moved exactly once per path (B1-enforced).
   The `perspectivist`/`auditor` slot Experts + their Config bindings live in the LIVE
   sample, NOT the shared profile. Gates green: (a) PURE `parse-perspectives` unit tests in
   flow-test.chiral (multi-line→N, single→1, empty→0, blank-lines-dropped→2, JSON-array→2) —
   B1 exit 0; (b) LIVE (`100.64.0.5:11434`, `samples/manas-flow-branch-live.chiral`): a
   `flow-branch` proved per-perspective ran once PER perspective (N≥2 across runs: 3/6/13)
   + backtrack consolidate+audit = 2 calls (total = 1+N+2, matched every run), AND a NESTED
   case (per-perspective = a flow-chain) executed end-to-end (total = 1+2N+2, matched) —
   THE compose-at-every-level proof. Additive confirmed: only flow.chiral + flow-test.chiral
   (+ the new live sample) touched; doc-refine still `CONFORM: true`; flow.chiral is absent
   from scriba's build closure and the `zb-move` build error reproduces identically with
   the changes stashed (the documented false alarm — not this slice).
4. **DONE 2026-08-17 — STOP loop** actuation (`run-flow-stop` loops the root Flow).
   `stop-continue? : (-> StopPolicy I64 Str Str Bool)` — PURE, TOTAL over StopPolicy:
   `stop-single`→false (one pass); `stop-capped n`→`(<i (+ iter 1) n)`; `stop-until-dry n`
   →`(and (<i (+ iter 1) n) (not (str-eq cur prev)))` — the DRY signal is OUTPUT
   STABILIZATION (cur==prev ⇒ dry), model-agnostic. `run-flow-stop` (=> matching run-flow
   +StopPolicy) = the effectful loop via a `run-flow-stop-loop` helper: run the Flow once
   per iteration, feed the yield FORWARD as the next input, consult stop-continue?, thread
   the q1 linear Backend through every iteration (moved once/path, B1-enforced), concat
   calls+raws FLAT into one composite "flow-stop" RunManifest (no RunManifest type change).
   ALWAYS TERMINATES — every policy is cap-bounded (the cap IS the bound; even until-dry is
   capped). ADDITIVE — only flow.chiral (3 new defs + 1 import comment) + flow-test.chiral
   (+ the new live sample) touched; run-flow and every existing case byte-unchanged, so
   doc-refine conformance holds by construction. Gates green: (a) PURE stop-continue? unit
   tests in flow-test.chiral (single→false; capped-2 true@0/false@1/false@2 = runs iters 0,1
   then stops; until-dry dry(cur==prev)→false, changed&under-cap→true, at-cap→false) — B1
   exit 0; (b) LIVE (`100.64.0.5:11434`, `samples/manas-flow-stop-live.chiral`): a 1-step
   Flow (coverage-vs-spec, 1 call/iteration) ran SINGLE=1, CAPPED-2=2 (= 2× single-pass),
   UNTIL-DRY=3 (bounded by cap 3 — the tiny model kept changing output so the cap
   terminated it), exit 0.
5. **DONE 2026-08-17 — tiny-step lint + the TINY-MODEL-GREEN acceptance gate.**
   Implemented in **chirality, NOT python** (`bin/manas-lint.py` superseded — the BUILD RULE
   forbids a python source-parser; the lint runs on Expert VALUES, more robust than
   parsing source). Three additive defs in `flow.chiral`:
   - `lint-expert : (-> Expert (List Str))` — FLAG list for one Expert; empty = a
     well-formed tiny step. Flags: `lens-conjunction` (lens has `" and "`/`" then "`/
     `" & "`/`";"` — multiple asks welded into one leaf), `lens-too-long`
     (`(<i lint-max-lens (str-len lens))`, `lint-max-lens = 160` — one short ask;
     doc-refine's tightest lens is ~50 chars, so 160 is generous headroom), `sees-empty`
     (`str-eq sees ""` — no context on all sides).
   - `lint-pool : (-> (List Expert) (List (Pair Str (List Str))))` — (expert-id → flags),
     advisory. Baseline over doc-refine's real `expert-pool` = ALL CLEAN (every shipped
     expert is a genuine tiny step; curate-merge is the longest at 141 chars, still < 160).
   - `manifest-all-green? : (-> RunManifest Bool)` — the runtime acceptance gate. TRUE iff
     BOTH non-green signals the engine emits are ABSENT: (a) a `flow-refine-fail:<ty>`
     routing (the typed-seam rejection — an under-decomposed leaf whose yield failed
     refine-ok, empty call list), and (b) any ExpertCall with `parsed-ok=false` (a leaf
     whose be-chat call did not succeed on its bound model). A genuinely empty manifest
     (no failure routing, no calls) = green. NB: `parsed-ok` means "the call succeeded"
     (runner.chiral), so on a healthy mesh a well-formed tiny step is always green and the
     gate goes false exactly when a leaf cannot complete on its assigned tier.
   Gates green: (a) PURE `flow-test.chiral` (exit 0): `lint-expert` on a BIG-question
   expert (200-char lens with `" and "` + empty sees) returns all three flags; on a tiny
   well-formed expert (coverage-vs-spec) returns nil; `manifest-all-green?` = true on an
   all-parsed-ok manifest + true on an empty one, false on a parsed-ok=false call, false
   on a `flow-refine-fail`-routed manifest; `lint-pool` over doc-refine's pool PRINTED
   (all clean). (b) LIVE (`100.64.0.5:11434`, `samples/manas-flow-green-live.chiral`, 0.5b
   smoke-local): a well-decomposed 2-step chain (coverage-vs-spec → cross-doc-drift, both
   ty-doc) via `run-flow-stop` → `manifest-all-green? = true` (2 green leaf calls, gate
   ACCEPTS); a flow-step whose slot is bound to an unservable model (`no-such-model:0.5b`)
   → chat-bad → parsed-ok=false → `manifest-all-green? = false` (gate REJECTS the
   under-provisioned leaf), exit 0. Additive confirmed: only `flow.chiral` + `flow-test.chiral`
   (+ the new live sample) touched; no existing def changed; doc-refine still `CONFORM: true`.
6. **scriba**: outline + run-view render the nested Flow (N-arc extends to nested nodes).

Slices 1–2 preserve doc-refine and add chain/fan. Slice 3 is the heart (branch⇄backtrack
recursion). 4–5 are the loop + the tiny-model discipline. 6 surfaces it in the cockpit.
Downstream (specialize, doc-edit, tool-builder — `MANAS-SKILL-GROWER.md` L3/L5) composes
on this.
