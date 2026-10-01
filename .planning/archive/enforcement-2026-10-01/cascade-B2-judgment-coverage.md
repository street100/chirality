# B2: judgment-vocabulary cascade (agent report, 2026-10-01, HEAD 2faa028)

Counts: 38 Judg (diag.chiral:99-113), 10 Reason (:123-143; r-arity is the tenth, bug-classes says 9).
All 38 Judg built in kernel.chiral (32 sites) or loader.chiral (9), both in closure, on path (compile-front:368 -> load-batch -> parse handle-def -> loader -> kernel).
Verdict key: ENFORCED = dispatched negative fixture + run rule mutant; "ENFORCED, no M" = ledger rung but not cond 4; renderer mutants not counted.
Probes in scratchpad/s4/probes/p01..p12, results scratchpad/s4/probe-results.txt; all 12 refuse with intended message.

## Per-constructor verdicts
- ENFORCED (fixture + rule mutant): jg-pure-crossing (K:900, membrane.sh R1-R10, ph36, m1/m2/m4); jg-extern-pure-crossing (L:471, extern-honesty L1-L4, ph37, m1-load-off); r-usage lam+let (check-cli, linear-mint; qfits/qjoin/strip/close mutants), field site K:1197 IMPLEMENTED; r-arity (K:1055,1110; arity.sh G5,G6 ph24; M5,M6).
- ENFORCED, no M: jg-lam-nonfn (face.sh:657-666 M10 ph16); jg-nonexhaustive (diag.sh:174, pretty, row, arity; no mutant on all-covered?/finish-case); jg-refine-unproved (recording.sh:278-283 ph30); r-redeclared (diag:148,153,163; L:566 no fixture); r-mismatch (K:986 subsume; check-cli:76, membrane:146, face); r-linear (K:876,1001 via linear-mint; K:920 none); r-arrow (L:491; linear-mint, diag); r-relayed (LB:81..110; rl-shape none).
- IMPLEMENTED (refuses, no dispatched fixture), probed: jg-infer-lam p09, jg-apply-nonfn p08, jg-esc-binders p02, jg-dup-branch p06, jg-scrut-nondata p05, jg-empty-case p12, jg-refine-i64 p03, jg-refine-opnd-form p04, jg-ctor-other-data p07, jg-no-prior-declare p11, jg-not-positive p01, jg-field-nontype p10.
- IMPLEMENTED, fixture exists but undispatched (phase 7 skips *_reject_*): jg-linear-field (e106_reject_list_cap), jg-linear-field-decl (e106_reject_nonlinear_field), r-usage field (e170_reject_cap_reuse, e106_reject_drop_tail, e126_reject_drop). Also e42/e124/e126, e170_reject_secret_leak.
- IMPLEMENTED, not probed: jg-pi-dom, jg-pi-cod, jg-ann-nontype, jg-branch-nonctor, jg-branch-arity, jg-refine-base, jg-refine-opnd-i64, jg-type-as-value, jg-ctor-nondata, jg-ctor-infer-params, jg-def-ty-nontype, jg-declare-ty-nontype, jg-extern-nontype, jg-dparam-nontype.
- IMPLEMENTED at best, no reaching source found: jg-var-range (elaborator assigns indices), jg-scrut-unknown, jg-not-a-ctor (defensive), r-unbound (elaborator's `unknown name` fires first).
- SEEDED dead arms: jg-tcon-arity (guard K:1054), jg-ctor-arity (guard K:1109; doc.sh:206 renderer golden only).
- unused: r-skipped (constructed nowhere in lib/ prog/; only renderer goldens).

## Counts
Dispatched negative fixture: 5/38 Judg; 8/10 Reason (r-unbound, r-skipped none) -> 13/48.
Rule mutant run: 2/38 Judg; 3/10 Reason -> 5/48.
Per group (bug-classes:111-119): type+arity 1/17 (+r-mismatch, r-arity; mutant r-arity only); case 1/10, none; refine 1/5, none; linearity 3/4, r-usage only; positivity 0/1; scope 1/4 (r-redeclared), none on a site; skips 0/1 constructed nowhere; effects 2/2, 2/2.

## Structural finding
Typed Reason from def/declare/extern refusals is flattened to a string at parse.chiral:580 and :673 (`step-err (dg-msg m)`) and re-wrapped as r-relayed (rl-batch) at load-batch:81. Only data-group refusals reach compile-front.chiral:369 with the rule-site Reason. Refusal gates must compare text.

## Status-ledger ENFORCED rows (status-ledger.md:156-166)
- QTT core: ENFORCED for 4 check-cli rows only; 5/38 Judg dispatched, 2/38 mutant; subsume/conv no rule mutant. Correction: state arm count or file 33 arms IMPLEMENTED.
- Quantities: ENFORCED lam/let; field audit K:1197 IMPLEMENTED; qadd/qmul tables unasserted (CK9).
- Linear types: binder/arrow ENFORCED no M; field leg IMPLEMENTED (K:1041, L:542 only undispatched e106); K:920 no fixture; nothing mutates linear-binder-bad, load-extern-linear, is-linear.
- Strict positivity: no fixture anywhere -> IMPLEMENTED (p01 refuses). PRB-16 mutual cycle accepted.
- Floor agreement of arithmetic prims: SEEDED; eval-prim returns (v-i64 0) for =i <i <=i (eval.chiral:86-95), fold-cmp folds them (optimize.chiral:68-73). Demote.
- E173 matcher: ENFORCED behavioural; ledger says 18 assertions/12 mutants, run shows 20/14.
- E200 span composite: ENFORCED behavioural, fine.

## Owners
Rostered: checker-core/CK7 (conv, eta), CK8 (7 inference arms), CK9 (field-binder audit, qtt tables), CK10 (4 refinement arms), CK13 (11 case/ctor arms), CK14 (positivity, PRB-16), CK15 (linear-field pair), CK19 (coverage census); diagnostics/V3 (dead arms); lowering-and-emit/LE7 (E97, r-skipped chain); LE22/LE23 (port Phase 12: e168, e170 rejects); substrate-floor/SU13 (phase for e106 rejects, after LE22); enforcement/N11 (mutant witness), N21 (classes -> gate or reason); N23, N24, N13 (floor agreement); N26 E171, N27 E204 built.
Unrostered: six loader declaration judgments (def-ty-nontype, declare-ty-nontype, no-prior-declare, extern-nontype, dparam-nontype, field-nontype) only in aggregate under checker-core req 1; r-unbound; rl-shape fence (sh-cat-crosses L:283-288); K:920 and L:566 sites; writing the missing rule mutants (no CK row asks).
Doc corrections: bug-classes.md:108-119 (10 Reason; effect constructors exist; r-skipped refuses nothing); checker-core arc G6/CK13/req1 (doc.sh:206 is renderer golden on unreachable arm; denominator 38 not 36); lowering-and-emit-arc.md:94 (LE7 G1 says joined into r-skipped, nothing builds it); diag.chiral:33 still says 36.
