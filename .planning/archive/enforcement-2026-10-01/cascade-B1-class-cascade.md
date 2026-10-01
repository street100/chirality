# B1: bug-class cascade (agent report, 2026-10-01, HEAD 2faa028)
Legend: d=lib/typing/diag.chiral, k=kernel.chiral, ld=module/loader.chiral, ce=lowering/compile-emit.chiral, cf=lowering/compile-front.chiral, rt=tools/test/run-tests.sh, SL=status-ledger.md. "unrun" = fixture exists, no dispatched script names it (run by hand at HEAD). Probes in scratchpad/bc/probe/. Judg 38 at d:99-113; Reason 10 at d:123-143.
Cells: J judgment | R rule | C closure+path | P positive | N negative | G dispatched phase | M rule mutant | L ledger | first missing | owner.

## Memory
- use-after-free/double-free: J r-usage d:129, r-linear d:131 | R partial k:645,:657,:1197, qfits qtt.chiral:40; minted Fd captured by returned closure closed twice checks OK (probe c4; PRB-101 OPEN) | C yes | P check-cli.sh:60-66 | N check-cli.sh:69; e124_reject_double_close, e124_reject_use_after_move, e126_reject_double_close, e170_reject_cap_reuse refuse, unrun | G ph3 rt:144, ph6 rt:147 | M qfits-q1-accepts-all check-cli:149; strip/close-binder-off linear-mint:489,:498 | L SL:161-162 ENFORCED (binders; silent on PRB-101) | first R | owner checker-core/CK20.
- null deref: by construction; but (extern str-len (-> I64 I64)) then (str-len 0) compiles and SIGSEGVs (probe null, exit 139) | first: R of FFI row | E75 (design, no arc, UNS-26) -> enforcement beside N27.
- aliasing/shared mutation: J r-usage/r-linear, jg-linear-field d:108, jg-linear-field-decl d:113 | R partial k binders, k:1041, ld:542; Bytes immutable (bytes.chiral:603-610), mutation only via linear Pool (pool.port:13,:27); holes adopt-fd (fd.port:32) mints two Fds for one descriptor (probe alias OK), CK20 | C partial; mem-linear, mem-region, arena zero importers | P yes | N partial; e106 rejects unrun | G partial ph6; ph4 gates clause parse only | M partial; none for field rule | L SL:162 ENFORCED binders; SL:178 IMPLEMENTED wrong -> SEEDED | first R | CK20; CK15 (E8); memory-discipline/M6, M8/M9.
- buffer overread/overwrite: J partial jg-refine-unproved d:107 (N18 Q3 no new arm) | R no: bget, bslice, str-sub declared bare (prelude.chiral:83,:97-98); (blen b) refused as atom (k:1432) | N no: (bget (str->bytes "abc") 99) exits 0 | L no row; SL:214 implies mem-put-checked bounds pool offset, it is in mem-linear.chiral:26 nothing imports | first R | N22 (open), N18 (designed, blocked AC:94,:96), N20/E198, N19, diagnostics/L5 (E176).
- uninitialized read: J no | surface by construction (every binder bound; fresh cells zero by contract x64/mach.chiral:649-655, pin test_native CUT); TAL undefined register caught only by ck-fn outside closure | first J or a pin for zero contract | unrostered -> memory-discipline (M2/E82, M3/E83 must keep zero contract).
- stack exhaustion: J no | _recurse-ceiling.prog KNOWN_FAIL rt:173 (fails on unrelated arrow error) | runner hides it: bin/chirality:149 (programs), :70,:124,:173 (compiler) ulimit -s unlimited | first J | unrostered -> memory-discipline.

## Effects and authority
- undeclared syscall: J no (SysR (sbad Str) sys-check.chiral:19; elf-err Str ce:354,:357) | R ck-tiprog sys-check:72 called ce:353; H8 ce:356 | C yes via target-linux.manifest:9 | P syscall-manifest.sh:113,:128-133 | N poisons :115-121; H8 :138-143,:161 | G ph5 rt:146 | M partial: poisons alter registry data; no mutant of ck-tiprog or manifest-offender | L SL:192 SEEDED wrong -> ENFORCED (ledger.md:199 says so) | first J | unrostered (no EV row covers ElfR/SysR) -> errors-as-values; M: N11.
- IO from pure: J jg-pure-crossing d:111, jg-extern-pure-crossing d:112 | R k:900, ld:471 | C yes | P membrane.sh:138-141 | N :97-128 | G ph36 rt:383 | M m1-m4 :232-259 | L SL:190 SEEDED wrong -> ENFORCED | effect row lacks J | N25 (E39, blocked AC:538-539).
- dependency exceeding grant: J no (SheetErr ld:280-281 arrives as r-relayed rl-shape Str, load-batch:83) | R partial cat-fenced ld:295-327 refuses (cat A) module binding a crossing; no per-dependency fence; H8 per program only | P no (Phase 8 absent, rt:18) | L no row for E161; grants DESIGNED SL:200-202 | first J | unrostered: E161 no roster row, sys-face-arc:356 disclaims Phase 8 -> errors-as-values for J, sys-face (beside SF20) for Phase 8; TA11.
- secret wrong exit: J r-mismatch d:127 | R k conversion | C yes | P unrun e170_port_twin | N unrun e170_reject_secret_leak "type mismatch" | G no (Phase 12 unported rt:22) | L SL:195 SEEDED (execution); refusal half IMPLEMENTED | first G | LE22 (E168 Phase 12 script), LE23 (E170); CU1-CU7 for execution.
- ambient authority: J no | R partial: Env linear cap (clock.port:19,:28-30); path naming ambient (file.port:14-15, AT_FDCWD sys.chiral:33), raw-I64 fd crossings (fd.port:34); H8 only fence | L DESIGNED SL:200-207 | first J | unrostered; R: TA9, TA12.

## Resources and termination
- non-termination: J no (TotalR tot-holdout Str totality-check:131 -> fr-err Str cf:372) | R cf:371, tot-gate totality-check:153, opt-in | C yes | P profile-target.sh:113,:119 | N profile-target.sh:108 (gate-run.log:50) | G ph4 rt:145 | M partial total-clause-dead (profile-target:259) turns off demand not classifier | L SL:191 SEEDED "no phase gates" wrong since 2026-09-05 | first J | unrostered -> checker-core (CK12 group); default flip E47 (UNS-12 no arc).
- unbounded allocation: J no; runtime fixed arena traps (x64/mach:459-461) | L DESIGNED SL:200, gap #3 SL:229 right | first J | E38 (UNS-05, no arc; homing-triage proposes enforcement); memory-discipline/M5 (E85).
- handle/fd leaks: J r-usage | R partial k:645,:657, case merge; raw-I64 fds (file.port:14-15) never linear; CK20; inheritance TA4 | P linear-mint:196,:316 | N check-cli:73; linear-mint:183,:208,:327; six more unrun (e124/e126_reject_drop, e42_reject_drop_cap, e106_reject_drop_tail, e170_reject_cap_lost, e168_reject_cap_drop) | G ph3, ph6 | M qfits-q1-accepts-all, close-binder-off | L SL:161-162 ENFORCED caps | first R | CK20; TA4, TA1.
- time/fuel budget: all no | L DESIGNED SL:200 right | first J | E38 (UNS-05) -> enforcement.

## Data at boundaries
- non-exhaustive: J d:105 + jg-empty-case | R k:1332,:1334 | C yes | P every root; row.sh:347 | N diag.sh:173-176 | G ph13 rt:216 | M no: nothing mutates k:1332 (arity M1, pretty M1, row M6 use refusal as oracle) | L inside SL:191 Totality SEEDED; gate makes it ENFORCED | first M | N11 (blocked); CK13 for 11 arms.
- unsound recursive data: J d:113 | R partial ld:539 direct; nullary mutual cycle admitted (probe mutual; PRB-16 OPEN) | N no fixture (arity.sh:567 sed needle) | L SL:163 ENFORCED wrong -> IMPLEMENTED | first R | CK14 (E7), CK16 (E79).
- out-of-range: J d:104-107 | R partial k:1452-1453,:1432; PRB-17 (refine I64 (> 9223372036854775807)) admits 0 (probe wrap); PRB-48 | P recording.sh:277-282 | N recording.sh:278; e170_reject_recv_zero unrun | G ph30 rt:366 | M no (recording M1-M6 mutate pricing) | L SL:189 SEEDED "no phase exercises" wrong | first R | CK10 (E9); N22.
- unchecked parse results: J partial (refined consumer) | R partial only refined consumers (sock.port:69); str->i64 (prelude:150) maps junk to 0, no failure arm | G partial ph30 tests a literal | first J | unrostered -> errors-as-values.
- integer overflow, div by zero: J no (<> exists refine.chiral:11; / declared bare prelude:62) | divisor 0 traps ud2 (x64/mach:259,:287; probe exit 132); overflow wraps silently (probe exit 7) | first J | unrostered -> enforcement with N22.
- FFI/ABI: J partial d:109, d:112; r-arity/r-mismatch could carry | R partial arrow kind checked (ld:471, ce:350, E204); declared signature not compared: (extern str-len (-> I64 I64)) segfaults (probe abi2 exit 139), extra arg accepted (probe abi exit 3) | P extern-honesty:126-135 | N :102-110 | G ph37 rt:389 | M m1-load-off :215, m2-emit-off :224 | L no row | first R signature half | E75 (UNS-26) -> enforcement beside N27.
- config drift: all no | first J | file-types/K1 (E163, blocked two calls).

## Compilation fidelity
- miscompilation: J no (TckR (tck-err Str) tal/check:47) | R ck-fn :290, ck-prog :308-309 outside closure, no call site | C no (PRB-70); fold adopted unjudged compile-back:243-247 | P/N tal-check.sh | G no (undispatched rt:355-359); opt-census red | M partial 3 by hand | L SL:174 IMPLEMENTED wrong -> SEEDED; SL:196 stale | first J | EV7; C: N8 (E18), N12; rewrites N23, N24, N7 (E17).
- non-reproducible build: rule is cmp | by hand 1,261,944 B identical | G no | L banner only (SL:11-20,:100) | first G | LE24 (blocked AC:113); DDC OT (O1, E53).

## Concurrency (all cells no)
- data races: absent by omission (no thread crossing among 40 rows; fork locked to fork+exec proc.chiral:4) | J | nearest M9.
- deadlock: expressible with spawn and pipes | J | nearest TA7, TA8.
- TOCTOU: path naming file.port:14 | J | nearest TA9.
- memory ordering: no shared-memory threads | J | nearest M9.

## Mechanism gaps
- types erased before emit: emit-elf-m takes NFn (ce:346) | C | N8 (E18), N12, N6 (E16).
- effectful never lowers: eff-lower only via sig-driver (zero importers) | C | N9 (E70) after N25.
- no reference semantics: tal/eval, tal/spec, evidence/interp zero importers | C | N13 (eval-prim repair unrostered); tal/spec OT (GAP-08), E71 OT (O2).

22 *_reject_* fixtures skipped by name at rt:179, named by no script; all refuse at HEAD: e168 x5, e170 x6, e106 x4, e124 x3, e126 x2, e42 x2.

## bug-classes.md wrong at HEAD
use-after-free "refuses" -> partial (PRB-101 probe c4). unsound recursive "refuses" -> partial, ungated. out-of-range "refuses, UNASSIGNED" -> partial (PRB-17), owners CK10 (E9), N22. undeclared syscall ce:296 -> :296 comment, call :353, refusal :354, Str not Judg. non-termination "no suite phase fails" -> ph4 profile-target:108, mutant :259 (SL:191, CK12 "Wanted" stale). miscompilation "only caller upper/optimize also absent" -> optimize in closure (compile-back:16), no longer calls check; check importers optimizer-census.prog, tal-check.sh; fold ships unjudged. FFI "declared only", blank element -> E204 refuses arrow-kind lie (ld:471, ce:350, ph37); signature half open; E204, E75. buffer overread blank element -> N18-N22 (E198), L5 (E176). secret "type-checks" -> leak refused ungated. div by zero none -> runtime trap ud2 exit 132; overflow wraps. uninit none -> by construction surface, pin CUT. dependency grant partial -> also ungated. :110,:123 -> Judg :99-113; Reason 10 :123-143; effects has two arms. :166,:170 run-tests.sh:363, 87 roots -> :444, 96 roots of 107 swept. :206 unmeasured -> 4 of 38 Judg in a base refusal row (6 with mutant-leg/render reads).

## Closure re-measured
61 modules: 51 lib/**.chiral 17,566 LOC + 9 .port + target-linux.manifest (382 lines). lib/ 95 files 26,510 LOC. 2026-09-04: 60 modules, 50 files 16,736 / 95 files 25,934. Moved in: lowering/upper/optimize (265) via compile-back:16 (inferred; shallow clone).
Outside, doc's set: 8 modules 1,105 LOC (6.3%): tal/check 312, tal/eval 187, eff-lower 183, row-infer 137, tal/spec 126, kernel-core 60, reflect-floor 54, effects 46. Plus six uncounted (441): sig-derive 108, evidence/interp 109, sig-driver 77, mem-region 75, ty-cmp 40, mem-linear 32 -> 1,546 (8.8%). evidence/ddc 213 OT. No roster row owns closure-assertion gate.

## Notes
Vocabulary cannot say: uninitialized read, stack exhaustion, ambient authority, unbounded allocation, fuel, overflow, config drift, four concurrency. Div-by-zero and unchecked parse could reuse jg-refine-unproved; FFI could reuse r-arity/r-mismatch.
Reverse-order set (R and G exist, J missing; verdict a Str): E76 chokepoint and H8 (ce:354,:357), termination (cf:372), E161 fence (relayed Str), floor checker (TckR, outside closure). Only EV7 rosters any.
By-construction breaks: null deref already breaks via re-typed extern (probe null); uninit breaks when M2/M3 hand out non-fresh memory (pin CUT); races/ordering break on clone/futex manifest row or MAP_SHARED Pool (sys.chiral:1041) crossing sock-send-fd (TA5, TA6); immutable Bytes keeps aliasing safe, breaks with M8 in-place region unless M9 seals.
Cheapest next cells, no author call: dispatch 22 rejects via LE22 Phase 12; named mutants for k:1332 and the classifier (N11); correct SL rungs :163, :174, :178, :189, :190, :191, :192. PRB-14 still OPEN owner none though E171 refuses its probe.
