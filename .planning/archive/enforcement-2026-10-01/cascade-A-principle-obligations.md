# A: principles -> obligations (agent report, 2026-10-01, HEAD 2faa028)

Keys: PR=PRINCIPLES.md, DPr=design-principles.md, SR=split-role, CD=certificate-discipline, TB=trust-boundary, OE=open-edges, BC=bug-classes, SL=status-ledger (docs/definitions/); d-x = docs/decisions/decision-x.md; AC=records/author-calls.md; UNS/GAP=records/lenses/unspoken.md, gaps.md; cat=docs/elements/catalog.md. OT = ownership-and-trust, build-deferred.

## P1 express everything / deny by default / expressible not modifiable
- P1.a ti-sys immediate = registered number; sys op in unregistered fn refused at one chokepoint. PR:45-49; d-syscall-governance:24-40. BC:54 (E76). SL:192 files SEEDED though ph5 gates. Owner syscall-custody/SC1 E76 built. Limit: seven registry rows carry 16 indistinguishably (syscall-custody:74).
- P1.b seccomp-bpf default-deny at process start on rung 1. d-syscall-governance:42-49. SC3 E77 open (req 4).
- P1.c profile attenuates syscall reach as subtyping over refinement on immediate. :51-56. BC:56. SC2 E78 open (req 3).
- P1.d who widened the permitted set is recorded where read. :36-40; cat:479. SC4 E162 open (req 5).
- P1.e no ambient crossing; print/put/trace/env-get/time-mono/sleep-ms become porttypes handed to main; extern crossing with no cap param refused. d-effect-facets:20-24,41-49,148. BC:58 none. UNROSTERED -> enforcement effect group beside N25-N27.
- P1.f no linear cap minted from raw value (adopt-fd mints Fd from I64). d-tool-capability:146-150; TB:101-106. tool-authority/TA6 displaces adopt-fd on recvmsg only; general rule UNROSTERED -> tool-authority.
- P1.g naming authority structural; module outside lib/ports/ declaring naming crossing refused; hold opens only beneath handed dirfd. d-tool-capability:63-65,132-144,162-165. TA12, TA1, TA9 open. "Nothing in this document is checked by anything" (:257).
- P1.h every checking module in compiler closure; closure assertion refuses absence. PR:31-32; BC:183-189; goal self-hosting:52-60. Self-hosting cond 4(a) via checker-core req2, lowering-and-emit, substrate-floor. Assertion tool UNROSTERED ("needs minting" BC:188-189) -> lowering-and-emit (rosters resolver E87). sys-face has no closure req.
- P1.i a tool judging chirality source is chirality and reached. goal enforcement cond 5; N10 designed blocked.
- P1.j B lives in the type; pure-looking signature over B referent refused. d-b-in-type:26-33. bridge/C1-C3 open; sys-face/SF20 open. cheri-floor E63 OT, hardware-blocked.
- P1.k no writable-executable segment. PR:37-38; TB:44-45; SL:215 (RWX PT_LOAD). substrate-floor/SU1 E20 open; AC:111 ruled E20.
- P1.l whole reachable language memory-safe: bounds, no uninitialized read. TB:104-106. BC:46,47 none; GAP-25. Bounds: N18,N19,N20/E198,N22; diagnostics/L5 E176. Uninitialized read UNROSTERED. Goal coverage waits AC:94; clamp vs trap AC:96-97.

## P2 everything a process, type is the whole cost
- P2.a ->body applying => callee refused at call. N26 E171 built ph36. SL:190 still SEEDED. One bit only.
- P2.b extern declared -> reaches no crossing. N27 E204 built ph37. BC:55 element cell omits E204.
- P2.c Pi carries effect row; body exceeding row refused. d-effect-facets:34-40,77-83. N25 E39 designed, blocked AC:538-539; memory-discipline/M9 waits. Trusted-core edit.
- P2.d row tal shadow + preserve-check over effect claim so => lowers. :130-134. BC:94. N9 E70 open.
- P2.e usage/time/space/info-flow grades in one semiring; cost > grade refused. d-graded-kernel:29-49. BC:65,67 design. UNROSTERED: E38 homeless (UNS-05), no goal condition (GAP-21). Over-approximate.
- P2.f totality property; non-terminating def refused with a judgment. BC:64 partial, tot-holdout string, no Judg arm. checker-core/CK12 E11 built; no phase reddens (SL:237-238). Numeric recursion waits E47.
- P2.g compile-time evaluation (fold/specialize/pregen) only of total subterms. d-graded-kernel:61-64. UNROSTERED -> enforcement req 7.
- P2.h quantity-0 position requires empty row + totality. d-effect-facets:127-129. UNROSTERED (AC:118 adjacent) -> N25 design.
- P2.i closure quantity follows capture; port-capturing closure never omega. :57-63,177-186. BC:43 claims refuses and is breached. checker-core/CK20 designed: (twice (mk (backend-open ...))) checks OK.
- P2.j 1-continuation never dropped; cancel synthesized+rechecked. :64-71. BC:66. N25.
- P2.k recoverable vs fatal structural. :188-198. N25 (E39 SPEC disposition b).
- P2.l binding time modality. d-graded-kernel:66-75. SL:194. UNROSTERED E57 (UNS-17). OT.
- P2.m suspension never crosses a node. :124-126. UNROSTERED -> N25 design.

## P3 govern the ports
- P3.a port-check is type-check: crossing outside profile port set refused at check, not only at emit. PR:84-85; goal enforcement:159-160. SL:180 IMPLEMENTED. Emit-time H8 is tree state with no row; check-time move UNROSTERED -> syscall-custody req 3. No mutant on manifest-offender.
- P3.b port set profile-invariant; loaded artifact cannot widen resident set. d-profiles:26-28. runtime-loading/RL3 open.
- P3.c profile valid only if three checks pass (connector invariants, substrate via ports, composite satisfies by subtyping). d-profiles:61-63,87-91. bridge/C1-C3 ports leg; E44 whole-assembly UNROSTERED (UNS-09). OT.
- P3.d space a port: allocation and stack depth carry a bound. PR:87-90. BC:65,48. Allocation memory-discipline/M5; stack exhaustion UNROSTERED -> substrate-floor.
- P3.e lib/ports/ holds crossing declarations only; extern outside refused. PR:98-102. TA12 covers five naming crossings; other 21 declaring files UNROSTERED -> tool-authority.
- P3.f info-flow lattice grade; non-interference typed proof. OE:60-78. BC:57. E44, E59 UNROSTERED (UNS-19). OT.
- P3.g constant-time checked as preserve-check's first customer. SL:222-224. E60 UNROSTERED (UNS-20). OT.
- P3.h outbound confinement; irreversible crossing passes pre-commit gate. OE:329-335,447-459. E73 UNROSTERED (UNS-24). OT.
- P3.i inbound B referent enters A only as evidence re-checked by generic bridge-preserve-check. OE:301-323; CD:53-56. SL:179 CUT. bridge/C5 open; E55 no row (UNS-16). OT.
- P3.j live ports move-only; no shared mutable handle crosses. OE:368-371. BC:103 none. UNROSTERED; no arc fits, goal tier first.

## P4 safe path cheap path
- P4.a total by default without profile clause; unproven def refused unless marked partial. CK12 opt-in; flip waits E47 UNROSTERED (UNS-12) -> checker-core.
- P4.b checked compile is default, never a flag. d-floor-check-per-compile:75-78. N8. Decision draft under veto.
- P4.c declaring a port set cheaper than declining. SC5 E164.
- P4.d minimum tier defaults high; lowering loud opt-in. SR:92-95. E74 UNROSTERED (UNS-25). OT.
- P4.e no gate enumerates bad sites where a default-deny chokepoint exists. UNROSTERED.
- P4.f each conservative checker's false-reject tax measured, sacrifice stated. PR:137-142. Partial N12,N15,N16, CK10; ck-prog measured 0 of 38,333.

## P5 split the truth, rung per obligation
- P5.a [T0] every shipped program target well-typed under ck-prog. N8 E18; goal cond 3. T0 pins no value (EN-20).
- P5.b [T0] type preservation over every lowering def. N6/E16, N14-N17. T0 discharge unsettled.
- P5.c [T1 detection] source and target evaluators agree on value over lowering defs. N13 designed blocked; LE20 E169, LE19 E15. eval-prim repair no row. Writers not independent.
- P5.d [T1] adopted rewrite carries value-agreement evidence or refused. N23,N24,N7/E17; AC:117 ruled both. Must respect PRB-70.
- P5.e non-lowering def routed with stated fate, never dropped. N1/E184, N4/E187 built.
- P5.f verb honesty: detection never filed as prevention, each row names rung. UNROSTERED. Doc-tier.
- P5.g [T2/T3] split is one type, guarded combine, move-only zeroed shares, reconstruction an effect, verification in type. E54 UNROSTERED (UNS-15); E56 on bridge/C4; E40 seed custody-executes/CU3-CU5. OT.
- P5.h plain Shamir cannot satisfy integrity. UNROSTERED (E74,E54). OT.
- P5.i provider below named minimum non-conforming, gap visible in type. E74. OT.
- P5.j [T0 to floor] zeroing survives tal. CU4 partial (AC:53); floor property E56 UNROSTERED. OT.
- P5.k combine requires disjoint provenance tags. SR:46-53. E54,E62 (UNS-22). OT.
- P5.l member holds only its typed port set. E54. OT.
- P5.m divergence a typed effect consumer must handle. N25.
- P5.n foreign parts at honest rung, contained at port set. bridge/C1-C3.
- P5.o certificate strength named per site. CD:58-64. E52 UNROSTERED, no lens row. OT.
- P5.p detect and reconcile unowned substrate. OE:427-445. E73,E62. OT.

## M mediator
- M.a kernel-spec small human-audited rule table as data. J5; ownership/O2 E71; E52 unrostered.
- M.b kernel-core re-checks certificates from every untrusted producer. J2; E52. OT.
- M.c demanded statement fixed at socket; no one-program check claimed as preservation. J5.
- M.d L1 emits L0-checkable derivation per artifact. E52 UNROSTERED. OT.
- M.e lowered output checked by floor checker, not widened conv. d-erased-word-level. N2,N3,N5,N8,N15. tal-ty=? not transitive.
- M.f trusted-core edit reviewed alone. N25 carries edit; discipline UNROSTERED.
- M.g judgment frozen at staging; Frozen->SigB writeback untypeable. d-reflective-floor:27-40; reflect-floor.chiral. J2; E45 UNROSTERED (UNS-10). OT. Zero importers.
- M.h no uncertified succession. E45. OT.  M.i migrated state conforms. E45. OT.  M.j succession initiation a linear cap. E45. OT.  M.k atomic port hand-over at cutover. E45. OT.
- M.l N distinct-formulation cores; disagreement refused. independent-judgment/J1, J3; goal conds 1-2.
- M.m quorum refuses <2 live legs. J4. Every chirality-native quorum fails leg2-disjoint? (OE:688-692).
- M.n referee compares verdicts; Prov carries formulation axis; divergence names legs. UNROSTERED -> independent-judgment.
- M.o each pair of cores owes encoding/adequacy/conservativity via hub. UNROSTERED -> independent-judgment.
- M.p only strict order exchanges soundness; cycle refused. UNROSTERED -> independent-judgment.
- M.q ck-prog runs every shipping compile in own process over written TAL; output withheld on tck-err; G18 keeps polarity. d-floor-check-per-compile:33-45,131-141,242-252. N8; goal cond 3. Draft.
- M.r one checked entry: every compile/run/check/BUILD RULE gen/Phase 7 root through it; binary withholds output until spawned checker answers tck-ok. :170-174,254-260. Queued under N8. 28 scripts call binary directly.
- M.s gate reddens when per-compile check cut; mutant compiler refused. :176-179. N8; N11.
- M.t a condition holds compiler's and checker's own time and memory. PR:66-69. UNROSTERED -> goal enforcement (author amendment).
- M.u fixpoint C1==C2 non-empty run as a phase. goal self-hosting:33-37. BC:86 verified, no gate. self-hosting cond 1; lowering-and-emit/LE24 open; placement AC:113 unreviewed.
- M.v trusting-trust: DDC. ownership/O1 E53. OT.
- M.w shipped form carries own re-derivation; kernel-spec size budget. ownership/O3 E72. OT.
- M.x tal/spec.chiral reached as golden object. ownership/O2 E71; cond 3 no row (GAP-08). OT.
- M.y ledger distinguishes error from adversary enforcement. UNROSTERED (GAP-06) -> independent-judgment req 4.
- M.z N tiny independent proof checkers over one proof object. E52. OT.

## DP reader-side regularity
- DP.a folder, reference interpreter, native code compute one value. DPr:37-40. SL:164 filed ENFORCED; eval-prim 0 for comparisons. N24,N13; repair UNROSTERED.
- DP.b note tense matches build status. enforcement req 1; ledger-lint worklist only.
- DP.c no surface form two meanings (multiplicity int vs symbol). AC:538 ruling.

## Classes bug-classes.md lacks (none visible to N21, which quantifies over BC classes; EN-35 failure mode)
judgment reconfigured / uncertified successor (M.g-k); writable-executable image (P1.k); cap forged from raw value (P1.f, M.j); compile path bypasses check (M.r, M.s); checking rule written never run (P1.h; BC files as systemic finding not row); def silently dropped (P5.e); vacuous certificate / producer-chosen statement (M.c, M.d, P5.o); correlated agreement / soundness cycle among cores (P5.k, M.l, M.n-p); below-minimum tier / T2 where integrity required (P4.d, P5.h, P5.i); secret residue survives drop (P5.j); covert/timing channel (P3.f, P3.g, P5.l); irreversible effect unconfined (P3.h, P5.p); B referent behind A signature / enters unverified (P1.j, P3.i); crossing declared outside registry (P1.g, P3.e); profile composite fails requirement (P3.c); syscall via non-chirality path / unattributable widening (P1.b, P1.d); non-total subterm run at compile time (P2.g); effectful/partial term in erased position (P2.h); continuation escapes node / recoverable-fatal confused / binding time confused (P2.m, P2.k, P2.l); checker false-rejects safe code (P4.f); mediator over budget (M.t); executors disagree on a value (DP.a); trusting-trust backdoor survives fixpoint (M.v); detection filed as prevention / note tense ahead of build (P5.f, DP.b, doc tier).

## No owner at any tier -> suggested home
P1.e -> enforcement effect group; P1.f general -> tool-authority; P1.h assertion tool -> lowering-and-emit; P1.l uninit read -> enforcement bounds group after AC:94; P2.e -> goal condition first (author), then arc; P2.g -> enforcement req 7; P2.h, P2.m -> N25 design; P2.l E57 -> OT arc; P3.a -> syscall-custody req 3; P3.c, P3.f E44/E59 -> OT arc; P3.d stack -> substrate-floor; P3.e -> tool-authority; P3.g E60 -> OT arc; P3.h, P5.p E73 -> OT arc (+bridge); P3.j race-freedom -> goal tier first; P4.a E47 -> checker-core (CK12 names flip); P4.d, P5.h, P5.i E74 -> OT arc; P4.e, P4.f general, P5.f -> enforcement reqs 6, 3, 1; P5.g, P5.k, P5.l E54/E62 -> OT arc; P5.j E56 -> custody-executes after CU4; P5.o, M.d, M.z (E52, no lens row either) -> OT arc (its text says nineteen OT elements owed a row, :53-60); M.f -> enforcement with N25; M.g-M.k E45 -> OT arc; M.n-M.p -> independent-judgment; M.t -> goal enforcement (author amendment); M.y -> independent-judgment req 4.

## Source disagreements
1 DPr:12-15 says PRINCIPLES has seven incl. "compute is inert until it touches a port"; PR:18 five. 2 d-profiles:49-50 cites P4 content as P5. 3 three cores (d-scope:116-117, SL:30-31, goal IJ:15) vs N unchosen (d-self-verification:23,67-68; goal IJ:27). 4 outbound confinement owner E44 (OE:441-442,450,517-518) vs E73 (cat:282). 5 inbound bridge CONFORMS (cat:282)/BUILT (OE:431) vs CUT (SL:179). 6 preserve-check "already used" (CD:15-17)/"BUILT structural" (OE:317-319) vs never was one (d-preserve-check:86-92; SL:196). 7 checker assurance = differential testing of diverse impls (d-split-checker:101-105) vs external judgment cut, agreement with itself (goal IJ:121). 8 TCB: TB:20-39 keeps CPython-trusted vs SL:122-126,146; TB:55-56 E76 at tal-check vs BC:54 at emit. 9 mediator budget homed in edge 3 (PR:238-239) but OE:86-89 omits it. 10 d-graded-kernel:56-58 says recursion check classifying not enforcing; it refuses under (total). 11 custody-executes:190 cites AC:52; row is AC:53. 12 P1 states no honest limit (presentability/D4).

## Decisions adding/removing obligations
split-checker removes type-checker quorum, adds M.a-d. self-verification §0 adds M.l, removes DDC/different target as legs, moves DDC to OT. reflective-floor adds M.h-k. graded-kernel adds P2.e, keeps termination/staging out of semiring, info-flow stage 7-8. effect-facets adds P1.e, P2.i-k; removes deriving => from holding a port. syscall-governance removes modelling all 362 syscalls; adds P1.a-c. preserve-check adds T1 (P5.c), P5.e; removes ttype Maybe as tier line; ck-prog not a preserve-check. floor-check-per-compile (draft) adds M.q-s; per-rewrite half to N7; budget unowned. erased-word-level removes widening conv (reason 1 applies equally to tal-ty=?, which reason 4 relies on; non-transitivity adds N15). profiles removes re-proof at boundaries, adds P3.b-c. tool-capability removes path scoping by refinement, adds P1.g; TA9 holds dirfd open. SR adds tier carrier E74. OE edge 1 removes effect-row obligation on elaboration; residue unstateable. OE edge 2 non-interference composite proof. d-scope: OT rows still owe roster rows.

Stale lens: UNS-06 (unspoken:73-75) reads E39 unhomed; N25 holds it after AC:537.
