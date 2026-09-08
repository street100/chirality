---
node: records-emitted-speed-arc
layer: navigation
related: [records/README, status-ledger, arcs/emitted-speed-arc, goals/emitted-speed, benchmarks/OPT-CANDIDATES-2026-09, implementation/optimizer-inventory, index]
status: current
updated: 2026-09-08
---

# Emitted speed arc

Every row is a claim this repo makes about what its compiled code costs, beside
what was actually observed.

Row format, states and the rules for adding, changing and retiring a row are in
[[records/README]]. Prefix is `ES`.

The arc's roster lives in [[arcs/emitted-speed-arc]], opened 2026-09-08 on
[[goals/emitted-speed]]. Its reserved element block is **none**, so its rows
carry arc-local ids `X1` to `X6` per
`docs/decisions/decision-work-ids.md`.

## What the optimization survey claimed, and what holds

### ES-01 the certificate family's license moved out of the compiler

- state:    FIXED
- claim:    `docs/benchmarks/OPT-CANDIDATES-2026-09.md` §F-vi read that `re-check` at `lib/lowering/upper/optimize.chiral:250` adopts every residual through `chk-ok`, and gave that as the structural fact licensing the certificate family `F28` to `F30`. A concurrent session's commits `b613a8f` and `38ecdba` carried out PRB-70's ruling of 2026-09-08 while that survey stood.
- measured: The cited fact is stale and the classification holds. `Checked` and `chk-ok` now live at `prog/optimizer-census.prog:75-76`; `opt-tfns` at `lib/lowering/compile-back.chiral:247-250` applies `(fold t)` unjudged; `lib/lowering/upper/optimize.chiral` retains the names only in comments at `:18` and `:21`, verified by grep returning those two lines and no code. The ruling took `lowering/tal/check` out of the compiler closure and `tools/test/tal-check.sh` G18 moved from `20 ok, 1 FAIL` to `21 ok, 0 FAIL`. **The A classification of `F28` to `F30` is unaffected**, because `docs/definitions/category-bridge.md` makes provability the test and where a check runs is a trusted-base question. Those two axes were collapsed once in this file's first reading and separated by the author on the same day. `docs/benchmarks/OPT-CANDIDATES-2026-09.md` §F-vi amended in place with the correction and the reason. Measured for the ruling and recorded in `prog/optimizer-census.prog`: forcing the guard to answer `chk-ok` emits a byte-identical blob, so it bought no shipped byte.
- evidence: `prog/optimizer-census.prog:75-76`, `lib/lowering/compile-back.chiral:247-250`, `lib/lowering/upper/optimize.chiral:18`, `:21`, commits `b613a8f`, `38ecdba`, `5a5aa64`
- checked:  2026-09-08
- element:  `crypto-primitives/K1` does not own this. No roster row owns it; it is survey residue

### ES-02 the inventory's line citations were repointed by the session that broke them

- state:    FIXED
- claim:    `docs/implementation/optimizer-inventory.md` and `docs/benchmarks/OPT-CANDIDATES-2026-09.md` cite `lib/lowering/upper/optimize.chiral` and `compile-back.chiral` at lines the same day's compiler commits shifted, and `ledger-lint` does not check `.md` line spans, so nothing would have caught it.
- measured: Repaired at `5a5aa64` by the concurrent session rather than by this one. `optimize.chiral:129` to `:140`, `:181` to `:192`, `:238` to `:249`, `:252` to `:263`, `:254` to `:265`, and `compile-back.chiral:240` to `:247`, across rows `A5`, `A8`, `A33`, `A58`, `B20` and the inventory's pass table. That commit also rewrote the inventory's preserve-check row from "ported and live, in the type" to "ported, and OUT of the compiler since 2026-09-08", keeping both readings. The residue this session found and fixed was §F-vi's prose, which carried the same stale fact as a rationale rather than as a citation and was missed by a line-number sweep. **A repoint pass corrects citations and does not read the prose that leans on them.**
- evidence: `git show 5a5aa64 -- docs/implementation/optimizer-inventory.md docs/benchmarks/OPT-CANDIDATES-2026-09.md`
- checked:  2026-09-08
- element:  none
