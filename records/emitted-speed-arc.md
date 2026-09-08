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
carry arc-local ids `X1` to `X9` per
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

### ES-03 E189 named one high half where the machine offers two

- state:    FIXED
- claim:    `E189`, minted 2026-09-05 at `e04168f`, read its subject as "the one member of the sum E96/E108 left unbound" and titled it "`op-mulhi` gets a surface extern: the high half of a 64-by-64 product" (`docs/elements/catalog.md:505`, `docs/elements/ledger.md:327`). It said nothing about the emission's sign. `.planning/AI-LANE-NUMERICS.md:66`, the source it was minted from, states the gap as "bind a surface name to the existing op; no new op required".
- measured: **RESCOPE.** The emission is signed, so the row's boundary moved and its deliverable survives whole. `op-mulhi` emits `x-imul-rcx-1op`, `48 F7 E9`, which is `F7 /5`, the one-operand signed `imul`, and the comment two lines above it has said so since it was written. No unsigned `F7 /4` path exists under `lib/lowering/x64/`: the three `F7`-opcode instructions there are `/7` idiv, `/3` neg and `/5` imul, and the ModRM byte `E1` that `F7 /4` needs over `rcx` appears once in the whole tree, inside `and rcx, -8`. So the row named one high half where the machine offers two, and it stops one ModRM byte short of the second. The three verdicts it is not: **not HOLDS**, because binding what exists leaves `C17`'s demand unreachable behind a name that reads as though it were served; **not AMEND**, because the delta is a new `Op` constructor, a new byte constant, a second extern and a second clobber key, which is the size of a deliverable; **not SUPERSEDE**, because Shape B keeps `op-mulhi`'s constructor, its bytes and its emission and adds `mulhu` beside them, so nothing the row promised is retired and the row is still what gets built. Shape A, unsigned only, would have made it SUPERSEDE, and the verdict therefore turns on the shape `emitted-speed/X7` settled. **Not REOPEN**: E189's four other claims each re-verified true on 2026-09-08, so nothing outside the trigger's reach is wrong. Both rows re-scoped in place, each carrying a `⚑` with the wording it replaces.
- evidence: `lib/lowering/x64/mach.chiral:313`, `:319`, `:373`, `:621`, `:195`, `:267`; `lib/prelude/prelude.chiral:36-39`, `:44-50`, `:58-71`; `lib/lowering/tal/erase.chiral:100`; `lib/crypto/poly1305.chiral:11-14`; `docs/benchmarks/OPT-CANDIDATES-2026-09.md:333`; `docs/examples/E108-shift-ops.md:74-79`; `docs/goals/emitted-speed.md:115`; `.planning/AI-LANE-NUMERICS.md:66`; `docs/arcs/parts/emitted-speed-X7.md` §2 and §5 decision 5; `docs/elements/catalog.md:505`; `docs/elements/ledger.md:327`; commits `e04168f`, `8a865cf`
- checked:  2026-09-08
- element:  `E189`, re-scoped in place, designed by `emitted-speed/X7`. The roster row at `docs/arcs/emitted-speed-arc.md:277` still carries `unminted` in its element cell and `designed` as its status; setting that cell to `E189` is the one write this verdict implies that sat outside this run's surface
