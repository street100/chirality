---
element: E18
slug: tal-check
title: TAL checker + reference tal interpreter
kind: SELF-HOST
reference_class: PAPER
ours_source: scaffold/chirality/tal.py
status: drafted
updated: 2026-07-13
---

# E18 — TAL checker + reference tal interpreter

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E18, the typed-assembly floor: a checker that re-verifies every
  lowered instruction against its type annotation, plus a reference interpreter
  that defines what checked programs *mean*.
- **Kind:** SELF-HOST.
- **Why chirality needs its own:** `tal.py` is the floor of the trusted stack —
  types are preserved and checked all the way down, and below tal sits the one
  trusted drop. Today that floor is Python. Self-hosting it shrinks the TCB to
  the point where the only unverified step left is the drop itself, and the IR
  is *already* chirality (`lib/tal-ir.chiral`) — only the judgment and the oracle
  remain in the host language.

## 2. Research

- **Reference class:** PAPER — Morrisett, Walker, Crary, Glew, *From System F
  to Typed Assembly Language* (TOPLAS 1999), read against the OURS docstring in
  `scaffold/chirality/tal.py`.
- **Key findings:**
  1. **Register-file typing Γ.** TAL types the machine state, not just
     expressions: a map `reg → type` is threaded instruction by instruction,
     and each instruction has one local rule that reads Γ and extends it. Our
     `check_fn` is exactly this at scaffold scale (a dict from register name to
     taltype tuple).
  2. **Annotations, not inference.** Every value-producing instruction carries
     its result type (`const`/`prim`/`call`/`con` all take a `taltype` field),
     so checking is local, syntax-directed, and needs no unification — the
     right shape for a small trusted checker.
  3. **Independence is the point.** The tal checker must not share code with
     the kernel: preserve-and-recheck only catches lowering bugs if the floor
     judgment is a second, independent implementation of "well-typed".
  4. **The interpreter is the meaning.** Soundness at the floor is
     progress+preservation phrased operationally: a program the checker accepts
     never gets stuck in the reference interpreter. The interpreter is the
     oracle the real (Category-B) drop must agree with.

## 3. Conventional (other-language) approach

How `scaffold/chirality/tal.py` does it — idiomatic checker-in-Python:

```python
class TalError(Exception): ...

def check_fn(env, fn):
    regs = dict(zip(fn.params_names, fn.params))   # mutable Γ
    for ins in fn.body[0]:
        op = ins[0]
        if op == "const":
            _, dst, ty, val = ins
            if not (-2**63 <= val < 2**63):
                raise TalError(f"{fn.name}: const {val} is out of I64 range")
            regs[dst] = ty
        elif op == "call":
            ...
        else:
            raise TalError(f"{fn.name}: bad instruction {op}")  # runtime catch-all

# interpreter: byte cells are raw ctypes buffers, mutated in place
buf = ctypes.create_string_buffer(n)
return ctypes.addressof(buf)
```

- **Assumptions it bakes in:**
  - **Errors are control flow** — `raise TalError` means the checker's
    signature says nothing about failure; callers must *know* to catch.
  - **Ambient mutation** — Γ is a dict updated in place; the interpreter's
    byte cells are ctypes buffers with real addresses, mutated ambiently.
  - **Open dispatch** — instructions are strings matched by `elif`; a new
    instruction with no rule is discovered at *run* time by the catch-all.
  - **Partiality** — nothing stops the interpreter looping forever on
    mutually recursive tal calls.
  - Unbounded Python ints, range-checked ad hoc at each `const`.

## 4. The chirality idea

How chirality's model reframes it.

- **Chirality features in play:** exhaustive `case` over closed `data` (the IR is
  a sum, not strings); errors as result sums; totality via structural
  recursion + a fuel measure; refinement on the fuel; the `->`/`=>` membrane;
  categories A/B/C; the I64 wall.
- **The reframing:** the checker becomes a *pure total function* from IR to a
  result value — `Γ` is an explicit assoc structure returned extended, not a
  dict mutated. Per-instruction rules are branches of one exhaustive `case`
  over the `Instr` sum from `lib/tal-ir.chiral`. The reference interpreter goes
  pure too: ctypes buffers become an explicit `Store` threaded through
  evaluation, and general tal recursion is tamed with a strictly decreasing
  fuel `I64` — "out of fuel" is a returned constructor, not a hang. The whole
  pair is `->` (Category A); the *production* drop below tal stays Category B
  and is governed by agreement with this oracle.
- **What chirality makes impossible here:**
  - An instruction constructor with **no typing rule** — coverage checking
    turns Python's runtime `bad instruction` catch-all into a compile error.
  - A checker that **throws** — `CkR` puts the error path in the signature.
  - **Hidden store mutation** — every `bput` is visible as store-in,
    store-out; the interpreter is replayable by construction.
  - **Nontermination** — no fuel, no step; the meaning function is total.

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
(import "prelude")   ; Maybe (some/none), Pair, List, Bool, Str, I64

; ---------- the CHECKER's typed IR (E18's own; mirrors tal.py's tuples) -------
; NOT lib/tal-ir.chiral: that is the type-ERASED executable IR (TInstr/TCode/TFn,
; register-numbered, no types) the emitter+interpreter consume. The CHECKER reads
; type ANNOTATIONS (tal.py: const/prim/call/con carry a taltype), so E18 defines
; this typed IR; the relation to tal-ir is erasure (see Use/modify).
(data TalTy ()
  (tt-i64) (tt-str) (tt-bytes)
  (tt-data (dn Str) (targs (List TalTy))))          ; ("Data", dname, targs)

; registers are I64 INDICES (tal.py: regty keyed by int), not names.
(data Instr ()
  (i-const (dst I64) (ty TalTy) (val I64))           ; dst := literal, checked vs ty
  (i-prim  (dst I64) (op Str) (srcs (List I64)) (ty TalTy))
  (i-call  (dst I64) (f Str)  (srcs (List I64)) (ty TalTy))
  (i-con   (dst I64) (dn Str) (cn Str) (srcs (List I64)) (ty TalTy))
  (i-bnew  (dst I64) (len I64))                       ; len:I64 -> dst:Bytes
  (i-bget  (dst I64) (ptr I64) (idx I64))             ; Bytes[I64] -> dst:I64
  (i-bput  (ptr I64) (idx I64) (val I64))             ; init write, no dst
  (i-blen  (dst I64) (src I64)))                      ; len Bytes -> dst:I64

; blocks/terminators: Block <-> Term <-> Branch are mutually recursive (E79).
(data Block  () (block (instrs (List Instr)) (term Term)))
(data Term ()
  (t-ret  (src I64))
  (t-case (src I64) (branches (List Branch)) (dflt (Maybe Block))))
(data Branch () (branch (cn Str) (dsts (List I64)) (body Block)))

(data TFn () (tfn (name Str) (params (List TalTy)) (ret TalTy)
                  (body Block) (nregs I64)))
(data Prog () (prog (fns (List TFn))))
(data TalSig () (talsig (args (List TalTy)) (ret TalTy)))

; ---------- the judgment: errors are values --------------------------------
(data REnv ()                                         ; Gamma: I64 reg -> TalTy
  (renv-nil)
  (renv-cons (r I64) (t TalTy) (rest REnv)))
(data CkR ()
  (ck-ok  (env REnv))     ; rule fired: Gamma extended with the dst register
  (ck-err (msg Str)))     ; Python's `raise TalError` becomes a returned value

; elided helpers (bodies mechanical), forward-declared:
(declare renv-get    (-> REnv I64 (Maybe TalTy)))     ; pure lookup
(declare tal-ty=?    (-> TalTy TalTy Bool))           ; structural equality
(declare const-fits? (-> TalTy I64 Bool))             ; literal inhabits its ty
(declare prim-sig    (-> Str (Maybe TalSig)))         ; extern -> sig
(declare prog-sig    (-> Prog Str (Maybe TalSig)))    ; tal fn -> sig
(declare ck-app      (-> REnv TalSig (List I64) I64 TalTy CkR))  ; args typed, dst set
(declare ck-con      (-> Prog REnv I64 Str Str (List I64) TalTy CkR))

; ---------- one instruction, one local rule (exhaustive over Instr) --------
(declare ck-instr (-> Prog REnv Instr CkR))
(def ck-instr
  (lam (prog env i)
    (case i
      ((i-const dst ty v)
        (case (const-fits? ty v)                      ; case-on-Bool, not value-if
          (true  (ck-ok (renv-cons dst ty env)))
          (false (ck-err "const: literal does not inhabit its annotation"))))
      ((i-prim dst ext srcs ty)
        (case (prim-sig ext)
          ((some sig) (ck-app env sig srcs dst ty))
          (none       (ck-err "prim: no tal signature"))))
      ((i-call dst f srcs ty)
        (case (prog-sig prog f)
          ((some sig) (ck-app env sig srcs dst ty))
          (none       (ck-err "call: unknown tal function"))))
      ((i-con dst dn cn srcs ty)
        (ck-con prog env dst dn cn srcs ty))          ; ctor fields vs decl
      ((i-bnew dst n)
        (case (renv-get env n)
          ((some t) (case (tal-ty=? t (tt-i64))
                      (true  (ck-ok (renv-cons dst (tt-bytes) env)))
                      (false (ck-err "bnew: length is not I64"))))
          (none     (ck-err "bnew: unbound length register"))))
      ; i-bget / i-blen produce I64; i-bput has no dst. Source-typing (ptr:Bytes,
      ; idx:I64) is via the same ck-app arity/type check, elided here.
      ((i-bget dst ptr idx) (ck-ok (renv-cons dst (tt-i64) env)))
      ((i-bput ptr idx v)   (ck-ok env))
      ((i-blen dst src)     (ck-ok (renv-cons dst (tt-i64) env))))))

; ---------- blocks, terminators, fn, prog (elided spines) ------------------
(declare ck-block (-> Prog REnv Block TalTy CkR))     ; fold ck-instr; check term
(declare ck-term  (-> Prog REnv Term TalTy CkR))      ; t-ret vs decl; t-case cover
(declare ck-fn    (-> Prog TFn CkR))                  ; seed Gamma from params
(declare ck-prog  (-> Prog CkR))                      ; fold ck-fn over the program

; ---------- reference interpreter: the Category-A oracle --------------------
(data Val ()
  (v-i64  (n I64))
  (v-str  (s Str))
  (v-cell (id I64))                                   ; a cell is an ID, not an address
  (v-con  (dn Str) (cn Str) (fields (List Val))))
(data Store ()                                        ; cell id -> Bytes, append-only
  (st-nil)
  (st-cons (id I64) (b Bytes) (rest Store)))
(data RunR ()
  (r-ok  (v Val) (st Store))
  (r-err (msg Str))    ; soundness: ck-ok programs NEVER return r-err
  (r-oot))             ; fuel exhausted -- totality without banning tal recursion

; fuel strictly decreases at every i-call: the measure that makes eval total.
; no ctypes.addressof -- bnew appends a fresh id, bput returns a new Store.
(declare tal-eval
  (-> (refine I64 (>= 0)) Prog Store TFn (List Val) RunR))
; eval-block / eval-instr mirror ck-block / ck-instr shape-for-shape ; …
```

- **Knobs to modify:** the `TalTy` sum (add `tt-fun` when first-class code
  pointers land); the `prim-sig` table; the fuel budget and who supplies it;
  the `Store` representation (assoc list here — swap for a region/arena view
  later); which terminators exist beyond `t-ret`/`t-case`.
- **Deliberately omitted:** the `syscall` instruction rule (immediate-number
  check — belongs with the port story); the initialization-write discipline on
  fresh cells (see open questions); the Category-B production drop itself; any
  label/jump control flow (scaffold tal is structured blocks only).

## 6. Use / modify notes

- **Lands in:** `lib/tal-check.chiral` (checker) + `lib/tal-eval.chiral`
  (reference interpreter), replacing the two halves of `scaffold/chirality/tal.py`.
  **The typed IR above (`TalTy`/`Instr`/`Block`/`Term`/`TFn`/`Prog`) is E18's own**
  — it mirrors `tal.py`'s *type-annotated* tuples (`const`/`prim`/`call`/`con`
  carry a taltype); it is **not** `lib/tal-ir.chiral`, which is the type-**erased**
  executable IR (`TInstr`/`TCode`/`TFn`, register-numbered, no types) the emitter
  and the trusted drop consume. The two are connected by **erasure** (the checker
  types the annotated IR; erasing the type fields yields the tal-ir the machine
  runs) — matching `tal.py`, where the same tuple carries the type and the
  interpreter ignores it.
- **Conformance target:** golden agreement with `tal.py` — every program
  `check_fn` accepts, `ck-fn` accepts, and every reject maps to a `ck-err`
  with the same reason class; on the scaffold test programs `tal-eval`
  produces the same values as the Python interpreter; and no `ck-ok` program
  ever evaluates to `r-err` (the operational soundness check).
- **Open questions:** (a) should fresh byte cells be **linear**
  (`(1 c Cell)`) so bput-before-read initialization is a typed fact instead of
  a convention? (b) fuel source — a refinement-bounded constant or a budget
  granted through a port? (c) how the real trusted drop attests agreement
  with `tal-eval` (evidence hooks, sampling vs exhaustive on the golden set)?
  (d) **the typed↔erased IR relationship** — does the self-host keep two IRs
  (this typed checker IR + the erased `tal-ir`, connected by an erasure step, as
  `tal.py` effectively does), or extend `tal-ir` with type annotations so there
  is one? `tal.py` reads annotations (does not infer), so a typed IR is required
  either way; whether erasure is a separate pass or the annotations just live on
  `tal-ir` is the design call.
- **Related:** [[E18-tal-check]]; [[E16-lowering]] — the lowering connector emits
  the **typed** IR this checker's `check-fn` re-judges (E16/E17 both consume it);
  `lib/tal-ir.chiral` — the erased executable sibling; [[E09-refinement]] — the
  refinement engine that decides the fuel and index bounds used here.
