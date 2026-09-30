---
row: checker-core/CK20
arc: checker-core
title: the captured quantity of a closure
kind: law
origin: new
req: 3, 1
status: blocked
updated: 2026-09-30
---

# checker-core/CK20: the captured quantity of a closure

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** a closure that captures a value of a linear type is itself used
  exactly once, on every path, including the path where it leaves the body that
  holds the value through a return. PRB-101's probe is refused at load, and the
  refusal is read by an assertion with an admit control beside it.
- **Serves:** requirement 3 of [[arcs/checker-core-arc]], "A rule the tree
  records as refusing refuses every case it claims to refuse". The rule is
  E159's binder rule, which [[banks/capability]] shard B.3 records as the reason
  "A held port cannot be *copied* into two authorities"
  (`docs/banks/capability.md:145-150`). Requirement 1 is served by the new
  refusal's assertion.
- **Goal:** [[goals/self-hosting]], condition 4, through requirements 1 and 3.

## 2. What the tree holds

- **Bank:** [[banks/capability]] shard B names q1 linearity as one of four
  mechanisms where "pulling any one leaks" (`docs/banks/capability.md:131-134`)
  and places it at `is-linear` and `linear-binder-bad`
  (`docs/banks/capability.md:145-150`). The bank says nothing of closures. No
  bank holds a refraction of the judgment itself, as the arc records.

| what exists | where | rung | reached by |
|---|---|---|---|
| linearity judged on the type: a registered porttype atom or a linear data, and `_ false` for everything else, `v-pi` included | `lib/typing/kernel.chiral:321-330` | IMPLEMENTED | `linear-binder-bad`, the loader's field rule |
| the binder rule: a linear type binds at `1` only | `lib/typing/kernel.chiral:360-361`, called at the Pi binder `:865-869` and the let binders `infer-let2` and `check-let2` | ENFORCED, Phase 6 at `tools/test/run-tests.sh:147` | every compile |
| the data-field twin of the same rule, on the same `is-linear` | `lib/module/loader.chiral:495-496` | IMPLEMENTED, asserted nowhere (`CK15`) | data install |
| the Pi carries a binder quantity and a one-bit seat, and nothing for its closure | `lib/surface/syntax.chiral:21`, `lib/typing/kernel.chiral:26` | IMPLEMENTED | every arrow |
| the seat is compared by equality, and so is the binder quantity | `lib/surface/syntax.chiral:11`, `conv-struct` at `lib/typing/kernel.chiral:708-716` | IMPLEMENTED | `conv` |
| `subtype` has no arm for `v-pi`; an arrow falls through to `conv` | `lib/typing/kernel.chiral:799-810` | IMPLEMENTED | `subsume` |
| lam introduction audits its own binder and returns the captured usage once | `check-body`, `lib/typing/kernel.chiral:945-951`, through `strip-binder` at `:633-637` | IMPLEMENTED | every lam |
| application scales the argument's usage by the binder quantity, the QTT app rule | `infer-app2`, `lib/typing/kernel.chiral:886-895`, the scale at `:893` | IMPLEMENTED | every application |
| the surface arrow: a head of `->` or `=>` and a list of binders `(q name ty)` | `lib/surface/parse.chiral:182-183`, `:417-441` | IMPLEMENTED | every signature |
| a design that relies on a captured linear value forcing single use | `docs/examples/E39-effect-row.md:157-159` | DESIGNED | nothing |

**Probes, run 2026-09-30.** Each is a file fed to `bin/chirality check`. The
live binary is `bin/chirality-bin`. Three instrumented compilers were built
from a scratch copy of `lib/` and `prog/` with one edit each to
`lib/typing/kernel.chiral`, through the resolver and the live binary as
`bin/chirality:68-70` prints, and selected with `CHIRALITY_COMPILE`. Nothing
under `lib/` or `prog/` in the tree was touched.

- **P1** refuses a lam whose captured usage, after `strip-binder`, is non-zero
  at a binder whose type `is-linear` accepts.
- **P2** is P1 with a lam that is the direct body of a lam exempted, which is a
  curried spine `(lam (a b) …)`.
- **P3** is P2 plus a refusal of an application, outside head position, whose
  result is a `v-pi` and whose applied spine took an argument of linear type.

| source | live | P1 | P2 | P3 |
|---|---|---|---|---|
| PRB-101: `mk` of `(=> (1 b Backend) (=> I64 Unit))` returning `(lam (x) (backend-close b))`, then `(twice (mk (backend-open …)))` | OK | refused | OK | refused, partial application |
| CK-05's `mk2`: the handle bound at `1` in a let and the same closure returned | kernel OK, then `body is not a lambda chain` at lowering | refused at load | refused at load | refused at load |
| control: the closure passed to `twice` inside the body that holds `b` | `linear binder usage mismatch` | refused | refused | refused |
| the closure over `b` passed to a `(1 f (=> I64 Unit))` parameter and called once | OK | refused | refused | refused |

**Census, same day.** 303 check targets: the 198 `.chiral` files under `lib/`
and `prog/`, and the 105 files carrying `^(def compile-main` there. On the live
binary 274 check OK and 29 fail on refusals unrelated to this row; each probe
leaves the 29 as they are.

- P1 reddens **113 of 274**: 52 of 178 modules, 61 of 96 roots, among them
  `prog/prapanca/backend.chiral`, `lib/capability/session.chiral` and
  `lib/runtime/supervisor.chiral`.
- P2 reddens **0 of 274**. Every capture of a linear value in the tree is a
  multi-binder lam over a linear first parameter.
- P3 reddens **0 of 274**. No program in the tree applies such a spine partially
  and keeps the result.

## 3. The delta

The kernel judges linearity by kind and quantity by grade, and the two meet at
binders only. A closure is the one value whose type is formed without looking at
what it holds, so a linear value captured by a lam is carried on an arrow the
kind judgment calls unrestricted. The grade survives only while the captured
variable stays in the context being scaled (`:893`); a return moves the closure
out of that context. Missing:

1. a place on the arrow that says the closure is used once;
2. a lam rule that refuses a linear capture into an arrow not so marked;
3. `is-linear` answering true for a marked arrow, which puts every existing
   binder rule (Pi, let, data field) in force over closures with no new site;
4. an arrow after a linear argument in a curried spine being marked, at
   introduction and elimination alike, or P1's 113 targets redden and PRB-101
   still checks through partial application;
5. a written form for the mark, for the positions no derivation reaches: a
   parameter that takes a linear closure, an annotation, a declared result;
6. the refusal asserted with its control.

**Verdict:** a real delta.

## 4. The shapes

### Shape A: a multiplicity on the arrow
- **Form:** `t-pi` and `v-pi` gain a field `m` of type `Qty`, `q1` for a closure
  used once and `qw` for an unrestricted one. The lam arm refuses a linear
  capture unless `m` is `q1`. `is-linear` gains a `v-pi` arm reading `m`.
  `conv-struct` compares `m` beside `q` and `s`. The spine rule sets `m` to `q1`
  on a codomain arrow whose binder's domain is linear or whose own `m` is `q1`,
  both in `check-body` and in `infer-app2`. The precedent is Walker's
  containment rule for qualified types (ATTAPL, 2005, ch. 1), Alms's arrow
  qualifier (Tov and Pucella, POPL 2011), and System F°'s kinded arrow
  (Mazurak, Zhao and Zdancewic, TLDI 2010), where a closure's qualifier bounds
  the qualifiers of what it captures and a curried arrow after a linear argument
  inherits it. None of the three is pinned in this tree.
- **Costs:** a field on the Pi, so every pattern over `t-pi` or `v-pi` changes
  arity: 33 `(t-pi ` sites and 7 `v-pi` sites over 10 files under `lib/` and
  `prog/`. A new `Subject` arm with its renderings in `lib/typing/diag.chiral`.
  A printer case in `lib/surface/pretty.chiral`, or a `type mismatch` between a
  marked and an unmarked arrow prints two identical types. A surface spelling.
- **Forbids:** returning, duplicating or dropping a closure over a linear value;
  passing it where an unrestricted arrow is expected. Wanted, each of them.

### Shape B: a capture annotation on the lam
- **Form:** the lam records the set of linear variables it captured, and the
  checker consults it at the binder where the closure comes to rest.
- **Costs:** the set names variables of the body that built the closure. After a
  return those variables are out of scope, and the caller holds a type only.
  Carrying the set across the return means summarising it into the type, which
  is Shape A.
- **Forbids:** nothing across a return, which is the defect.

### Shape C: no linear capture at all
- **Form:** P1 as the rule. A lam may not capture a value of linear type.
- **Costs:** P1 measured 113 of 274 passing targets red, every one a curried
  spine. With the spine exempted (P2), it still refuses the in-body pattern that
  checks today and that `docs/examples/E39-effect-row.md:157-159` builds its
  one-shot continuation on.
- **Forbids:** every continuation over a linear value. Unwanted.

### Shape D: fold the mark into the seat
- **Form:** `Seat` grows from two points to four, pure or proc crossed with once
  or many.
- **Costs:** the seat is the arrow's effect, and [[records/findings]] FD-62 and
  `memory-discipline/M9` grow it into an effect row that carries region entries
  and a row variable. The mark would ride on `E39`'s row and change with it.
- **Forbids:** keeping this row correct without `M9`. Unwanted.

### Shape E: linear values only through continuations
- **Form:** the Linear Haskell reading, where the multiplicity sits on the
  binder and a linear value is never returned by a function, so every extern
  that mints one takes a continuation.
- **Costs:** every extern whose result is a linear porttype changes shape, and
  E159's rule that such a mint crosses as `=>` is rebuilt around a different
  discipline.
- **Forbids:** the tree's kind-based linearity (`lib/typing/kernel.chiral:321`,
  "linearity is a property of the type"). Unwanted.

## 5. The call

- **Chosen:** Shape A. B reduces to A at the return, C refuses the one capture
  that is sound, D ties the row to `M9`, and E replaces the rule E159 and the
  capability bank rest on. A keeps the kind judgment and the grade judgment
  separate and adds the mark to the kind side, where `is-linear` already sits.

**The rules, as the SPEC will state them.**

1. **Lam.** Checking `(t-lam b)` against `v-pi qp s dom cod m`: after
   `strip-binder`, if the captured usage is non-zero at any binder whose type is
   linear and `m` is not `q1`, refuse with `(r-linear (subj-lam-capture) m)`.
2. **Linear arrow.** `is-linear` answers true for `v-pi` with `m` at `q1`, so
   `linear-binder-bad` and `linear-bad?` refuse it at `0` and ω.
3. **Spine.** The codomain instance of a `v-pi` whose domain is linear, or whose
   `m` is `q1`, has its `m` set to `q1` if it is a `v-pi`. Applied where
   `check-body` instantiates `cod` and where `infer-app2` does.
4. **Conversion.** `conv-struct` compares `m` by equality. An unmarked function
   passes where a marked one is wanted by eta, `(lam (x) (g x))`, which checks
   against either.

**Soundness.** The rule rests on the containment rule of the qualified-type
literature in Shape A: a closure is at least as restricted as what it captures,
and a restricted value is used once. That literature proves it over calculi
with qualifiers and no grades. The composition with QTT grades on binders is
argued here and proved nowhere: rule 1 reads the grade only to learn whether a
captured variable is used, rule 2 feeds the result into the existing binder
rule, and the usage algebra of `lib/typing/qtt.chiral` is untouched. FD-62
records that the one mechanised seal proof covers a non-substructural calculus;
this row adds no seal and does not lean on FD-62. Once `M9` lands, a seal over
linear arrows is the composition FD-62 names, and `M9`'s design owes it.

**The seal.** The author's 2026-09-30 ruling on E159 ([[records/author-calls]],
the `ruled` row) makes the buffer effectful and the seal its own item, and
`memory-discipline/M8` now carries an unrestricted, region-tagged handle
(`docs/arcs/memory-discipline-arc.md:101`). `M9` closes an escaping closure by
the region in its effect (`docs/arcs/memory-discipline-arc.md:102`). This row
closes it by the linearity of what it captured. The two sit on different fields
of the arrow and each refuses its own case without the other.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Is the mark keyed to the captured value's kind, or to any `1` binder it captures? | RESOLVED: the kind | `lib/typing/kernel.chiral:321`: "linearity is a property of the type"; E159's rule reads `is-linear` (`:360-361`). A `1` binder over `I64` stays an audit and makes no closure linear |
| 2 | Exactly once, or at most once? | RESOLVED: exactly once | `strip-binder` audits by `qfits` against `q1` (`lib/typing/kernel.chiral:633-637`); a dropped closure drops the handle it holds |
| 3 | Subsumption from unmarked to marked, or equality? | RESOLVED: equality, eta as the coercion | the seat and the binder quantity are compared by equality (`lib/surface/syntax.chiral:11`, `lib/typing/kernel.chiral:714-715`) |
| 4 | The surface spelling of a marked arrow | **NEEDS-AUTHOR** | below |
| 5 | The mint rule of E159 for a def returning a linear closure | RESOLVED: unchanged | a closure is built from values already in the linear context; nothing crosses. `ty-result` walks past every arrow (`lib/typing/kernel.chiral:338`) and stays as it is |

### NEEDS-AUTHOR 4: how a linear arrow is written

**In plain words.** Rules 3's derivation covers every curried spine, which is
every site the tree has (P2 and P3, 0 of 274). A written mark is needed only
where no derivation reaches: a parameter that takes a linear closure, as in the
fourth probe row, an annotation `(the T (lam …))`, and a declared result that
returns a closure over a handle bound inside the body, as `mk2`. Zero sites in
the tree need it today. Every new program that passes a one-shot continuation
over a handle needs it, `E39`'s `handle-div` among them.

**Measurement.** Quantities are written as a leading numeral on a binder,
`(1 b Backend)` (`lib/surface/parse.chiral:437-441`), and an unnamed binder gets
`2` (`:441`). A two-item `(1 T)` in a binder list therefore reads as a binder,
so the numeral-prefix form collides with it and the options below leave it out.

**Options.** (a) two new heads `->1` and `=>1`, the quantity written on the
arrow the way it is written on a binder; (b) the lollipop heads `-o` and `=o`;
(c) a wrapper `(once T)` legal only around an arrow.

**Recommendation:** (a). It spells the field it sets, reuses the numeral the
binder already uses, and leaves the seat on the head where it is.

## 6. The mint packet

- **Elements:** one. The mark, the lam rule, the `is-linear` arm and the spine
  rule constrain each other: without rule 3, rule 1 reddens 113 targets;
  without rule 1, rule 2 has nothing to judge.
- **Band:** `UNASSIGNED`. The arc reserves no block.
- **Catalog row:**
  `| E<NN> | **A closure over a linear value is linear**: the Pi carries a multiplicity `m`; a lam whose captured usage touches a linear binder checks only against an arrow at `m = 1`; `is-linear` answers true for such an arrow, so E159's binder rules and E8's field rule hold over closures; the arrow after a linear argument in a curried spine is marked at introduction and elimination. Refuses PRB-101 and CK-05's `mk2`; the census over 274 passing targets reddens none | design; `lib/surface/syntax.chiral`, `lib/typing/kernel.chiral`, `lib/typing/diag.chiral`, `lib/surface/parse.chiral`, `lib/surface/pretty.chiral` | qualified types with closure containment, Walker ATTAPL ch. 1, Alms, System F° (law) | SH |`
- **Ledger row:**
  `| E<NN> | kernel | design | A closure over a linear value is linear: the Pi's multiplicity, the lam capture rule, `is-linear` over arrows, the spine rule. Check: a gate phase with PRB-101, `mk2` and the parameter case refused and the in-body single use admitted; BUILD RULE `C1 == C2` | `checker-core/CK20` | SH |`
- **Size:** about 12 files and 200 lines. The field is 40 pattern sites over 10
  files (`grep -rn '(t-pi \|(v-pi '` over `lib/` and `prog/`, 2026-09-30),
  about one line each. The probe kernels put rules 1 and 3 at about 45 lines;
  the `Subject` arm about 8 lines across the tables at
  `lib/typing/diag.chiral:80-91`, `:173-191`, `:352-365`; the spelling about 15
  lines in `parse-arrow` and the elaborator; the printer about 5; a gate script
  with four probes and two controls about 60, plus one `run_phase` line.
- **Related:** [[arcs/checker-core-arc]], `checker-core/CK18`,
  `checker-core/CK15`, `memory-discipline/M9`, [[records/findings]] FD-62,
  `records/lenses/problems.md` PRB-101, `records/checker-core.md` CK-05.

### Needed and unrostered

| what | why this row needs it | where it would go |
|---|---|---|
| a pinned source for the containment rule | §5's soundness names Walker, Alms and System F°, and no pin in the tree carries any of them | a `research` run, an `FD` row |
| E39's one-shot continuation typed with a marked arrow | `docs/examples/E39-effect-row.md:157-159` passes a capture of `s2` to `handle-div`; under this row that parameter must be a linear arrow or the lam is refused | `E39`'s design, homed on the enforcement arc |
| the capability bank's shard B.3 sentence | "A held port cannot be *copied* into two authorities" (`docs/banks/capability.md:150`) is false through a returned closure until this row builds | a `doc-audit` of [[banks/capability]] |
| the author-call row for NEEDS-AUTHOR 4 | the rule that a NEEDS-AUTHOR earns a row | [[records/author-calls]], opened by the orchestrator |
