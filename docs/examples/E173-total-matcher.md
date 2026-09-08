---
element: E173
slug: total-matcher
title: A total matcher over `Str`
kind: BUILD-PROPER
reference_class: PAPER
ours_source: (none)
status: drafted
updated: 2026-09-01
---

# E173 — A total matcher over `Str`

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E173. Everything a text scan needs past a literal substring:
  a byte class, bounded repetition, alternation, a zero-width assertion, and a
  line-state pass (inside/outside a fenced block, inside/outside an inline span).
- **Kind:** BUILD-PROPER. Nothing in `lib/` matches text past
  `str-find`/`str-find-from` (`lib/prelude/prelude.chiral:84-85`), which lower to
  the naive scan `nb-bfind-from` (`lib/lowering/tal/bytes.chiral:355-380`:
  `nb-match` at offset `i`, else recurse at `i+1`).
- **Why chirality needs its own:** two live consumers, both measured.
  1. `prog/prose-lint.prog:186-188` prints three checks as `NOT-CHECKED` on every
     run because it cannot express them: `not-but`, `parallel-no`, and skipping
     code. It also spells 31 literal needles as 13 lines of `cons` chains
     (`prog/prose-lint.prog:105-121`) and makes one full-buffer pass per needle,
     which `docs/elements/ledger.md:320` records as the whole of its 2.4x gap against
     the awk version it replaces.
  2. Zero-Python. `.planning/ZERO-PYTHON-SCOPE.md:131-137` puts **3,560 LOC
     behind E173**, against 244 behind E150 and 205 unblocked today, and
     sequences the goal as E173, then E148, then E150.
     *(Audit repoint 2026-09-01: this read `:14` / **3,535 LOC**. The line cite
     landed on the call-site table, and that doc re-measured its own figures
     upward — `:131-137` is the honest total it carries today.)*

**Bank check (the cardinal rule).** `docs/banks/` holds ten banks
(`docs/banks/INDEX.md:23-33`), and the tenth is [[banks/text]] — *a payload, a
way to name a part of it, and total functions between those*, refracting the
regex engine, the string library, the Unix text tools and the editor buffer.
That bank is the authority here, and it confirms this element rather than
retiring it: shard **D**, *the matcher, returning spans*, is homed at `lib/text/`
and carries **E173, `design`**, with shards A/B/C (the byte floor, the derived
string ops, the sequence ops) **built** below it. So E173 is a real gap and not
a phantom, and the bank says which gap.

The word "Thompson" does appear in `docs/banks/verification.md:177` and
`docs/banks/evidence-and-split.md:418`, and in both places it means Ken
Thompson's trusting-trust attack, unrelated to the Thompson NFA of the
reference class.

~~A **text/matching bank does not exist and is owed** once this element is
built; it is listed in §6 as an open item and not deferred to an unminted E#.~~
⛑ **Discharged.** `docs/banks/text.md` exists and names E173 as shard D. This
paragraph, and §6 open question 4, were written against a nine-bank tree. Struck
rather than deleted, per the authoring rule at the foot of §6.

## 2. Research

**Reference class: PAPER.** Thompson (1968) NFA simulation, Pike's VM with
capture slots (the sam / Plan 9 line, later Go and Rust `regex`), Brzozowski
(1964) derivatives, Antimirov (1996) partial derivatives.

### Finding 1: the corpus was measured, and it is a poor fit for regex

Census over every `.py` in the tree, by AST (`re.<fn>(...)` call sites with a
literal or f-string first argument), 2026-08-31:

```
python3 - <<'EOF'   # full script: scratchpad census.py, method in §6
# walks ast, collects re.compile/search/match/findall/finditer/sub/split/fullmatch
EOF
```

138 AST-visible call sites. Counting the way `.planning/ZERO-PYTHON-SCOPE.md`
counts (grep for `re.` lines) gives **143 today across 13 of 14 files**, against
the 141 that doc recorded the same day; the ±2 is line-vs-call and same-day
drift, and neither number changes the ranking. Per file, grep method:
`ledger-lint` 57, `pack` 36, `capture` 15, `frontier` 14, `doc` 8,
`syscall-map` 4, `paren-audit` 2, the two smoke tests 1 each, the four
`docs/examples/refs/gen-*.py` 1-2 each.

Feature histogram over the 138 (a site can score in several rows):

| construct | sites | consequence for the shape |
|---|---|---|
| `*` / `+` | 108 | repetition is unavoidable |
| `\d \w \s \S \D` | 85 | shorthand classes, all ASCII byte ranges |
| capture group | 77 | **submatch extraction is load-bearing** (§4) |
| `[...]` | 65 | byte classes |
| `^` anchor | 36 | line-shaped; 47 sites use `re.match`/`fullmatch`, which anchor implicitly, 17 of them also carrying a `^` |
| alternation | 24 | 20 of these alternate literals, e.g. `py|chirality` |
| `?` | 24 | optional literal groups |
| `.` | 23 | any-byte |
| `{n,m}` | 19 | counted repetition (`\d{4}`, `[0-9a-f]{64}`) |
| lazy `+?` | 10 | leftmost-first, so a longest-match engine changes answers |
| lookahead | 3 | `ledger-lint.py:246,413`, `capture.py:283` |
| lookbehind | 1 | `ledger-lint.py:836` |
| **backreference** | **0** | mechanically confirmed |

Three of the four lookaround sites are one-byte-class assertions:
`(?![-A-Z])` (`ledger-lint.py:246`), `(?![A-Za-z0-9_?!*<>=+-])`
(`ledger-lint.py:413`), `(?<!\\)` (`ledger-lint.py:836`). All three fit the
same zero-width slot as `\b` (21 sites), which is itself a two-byte-window test.
The one real lookahead is `capture.py:283`,
`^(\d+)\.\s+(.*(?:\n(?![\d]+\.\s|##|\s*$).*)*)`, and it means "take lines until
one starts a new item", which is the line-state pass of this element rather than
a matcher feature.

**Zero backreferences plus one-byte-window lookaround means nothing in the
corpus requires backtracking.** That is the single most size-relevant fact here.

### Finding 2: 24 patterns are built at runtime, so a pattern must be a value

`rf"..."` sites (17) plus `re.escape` sites (5) build a pattern from data:
`pack.py:133` `rf"\b{p}0*{n}{sfx}\b"`, `ledger-lint.py:413` splicing an
identifier into a `(def ...)` probe, `pack.py:426` `re.escape(b)`. If the
pattern type is a `Str` of regex syntax, E173 must also ship a syntax parser, an
escaper, and a `p-err` path at every construction site. If the pattern type is a
closed `data` sum built by constructors, dynamic construction is free, escaping
never exists as a concept, and a malformed pattern is unrepresentable.

### Finding 3: the two bounded algorithms cost differently *here*

- **Thompson/Pike VM.** Compile to an instruction array, simulate a thread list.
  Time `O(n·m)`, space `O(m·k)` for k capture slots. Handles lazy quantifiers by
  thread priority, which the 10 lazy sites need. Cost in chirality: the
  epsilon-closure walks a **cyclic** program graph, so `add-thread` is neither
  structural nor a single decreasing argument. It proves only with an explicit
  fuel parameter bounded by the program length, and the tightness of that fuel is
  a fact the checker cannot see.
- **Brzozowski derivatives.** `d_a(r)` is structural on `r`, so it proves with no
  measure at all. But the derivative term grows, and the count of distinct
  derivatives under ACI normalisation is the DFA state count, `2^O(m)`. Bounded
  and honest, and a bad type under P2.
- **Antimirov partial derivatives.** `pd_a(r)` returns a *set*, and the set of
  reachable states is bounded by `‖r‖ + 1`, linear in the pattern. It is the NFA
  simulation written as a pure function over pattern terms: no compile stage, no
  program counter, no cyclic graph, and every recursive call lands on a strict
  subterm. The arrow is `O(|input| × |pat|)` states visited, with a
  term-representation factor discussed in §5.

### Finding 4: totality here forbids the combinator shape outright

`docs/definitions/totality.md:105-107`: a definition **used as a value** (passed
to a higher-order function rather than called), whose future call sites are out
of view, "poisons the whole group's verdict". A parser-combinator matcher, where
a pattern *is* a function `Str -> Maybe (Str, a)` handed to `seq` and `alt`, is
exactly that shape. It cannot be proven total in this tree. The first-order
`data` sum plus an interpreter is the shape totality leaves standing, and it is
also the shape Finding 2 wants.

Two supporting facts from the same source. `docs/definitions/totality.md:80-89`:
a numeric measure proves when the step is exactly `±1` under a strict `<i i n`
guard with `n` passed unchanged, measure `n - i`, no wraparound guard owed. That
is precisely the input scan. And `docs/definitions/totality.md:97-104`: since
E50 (2026-07-28) mutual and lexicographic recursion prove with a **declared**
measure on the forward `declare`s, so a two-argument descent is available if
needed. (`lib/typing/totality.chiral:11-13` says E50 is out of scope; that is
the scope of *that module*, and the language-level fact in `totality.md` is the
current one.)

## 3. Conventional (other-language) approach

The awk implementation the native tool replaces, `tools/prose-lint/prose-lint.sh:75-98`:

```awk
FNR == 1 { fence = 0 }
/^[ \t]*```/ { fence = !fence; lines[FILENAME]++; next }
fence { lines[FILENAME]++; next }
{
  gsub(/`[^`]*`/, "", $0)                                   # blank inline spans
  c["antithesis"]      = gsub(/, (but |and |though |yet )?(not|never|rather than) [a-z]/, "&")
  c["copula-negation"] = gsub(/(is|are|was|were|isn.t|aren.t) not (just |merely |simply )?[a-z]/, "&")
  c["not-but"]         = gsub(/not [a-z]+ but /, "&")
  c["parallel-no"]     = gsub(/[Nn]o [a-z]+, no [a-z]+|[Nn]ever [a-z]+, never /, "&")
  c["slop-word"]       = gsub(/[Dd]elve|[Tt]apestry|[Ss]eamless|.../, "&")
}
```

and the Python side, `tools/doc/doc.py:130-131` (one of the 77 capture sites):

```python
pm = re.match(r"([A-Za-z0-9_/.-]+\.(?:py|chirality))(?::(\d+)(?:[–-](\d+))?)?$", span)
```

**Assumptions it bakes in:**

- **Unbounded work is invisible in the type.** `re.match` has the type
  `str -> Match | None` in every language that offers it. Nothing in the
  signature says the call may pin a core. `PRINCIPLES.md:117-119` names this case
  by name: "a regex that ReDoS-es never opens a file or a socket. To an I/O-only
  effect system it is pure and harmless, and it still pins a core indefinitely."
- **Patterns are strings.** A pattern is text parsed at runtime, so every one of
  the 24 dynamic sites carries an escaping obligation and a parse-failure path,
  both of which are handled by convention rather than by a type.
- **Match failure is `None`, or an exception, or an empty list**, depending on
  which of the eight entry points was called.
- **Codepoints, ambiently.** Python `re` runs over `str`, so `[a-z]` and `.` mean
  something decoder-dependent, and the decode happens before the scan.
- **`gsub` mutates `$0` in place** and the eight checks run in a fixed order over
  the mutated line, so the checks are coupled through hidden state.

## 4. The chirality idea

**Features in play:** totality (the measure decides the algorithm), P2's cost-in-
the-type, boundary sums (the STANDING DIRECTIVE), errors as values, the I64/Bytes
floor, QTT-erased type params, and a pure `->` arrow throughout.

**The reframing, in four moves.**

1. **The pattern is a closed sum, so a malformed pattern has no representation.**
   `Cls`, `Assert` and `Pat` are `data` declarations. A pattern is built by
   constructor application, which is the boundary-sum directive applied to the
   thing regex libraries hand you as a string. Escaping stops existing: a literal
   is `(p-lit s)` for any `s`. The 24 dynamic sites become ordinary function
   calls returning a `Pat`, and E173 ships no syntax parser.
2. **The totality checker picks the algorithm; taste does not.** Finding 4
   removes combinators. Between the two survivors, Antimirov's `pd` recurses only
   on strict subterms of `Pat`, so it proves under the structural rule with no
   declared measure and no fuel; a Pike VM's epsilon-closure needs a fuel
   parameter whose bound the checker takes on faith. The shape that types with
   the least ceremony wins, which is P4 (`PRINCIPLES.md:122`) doing its job.
3. **The state-set bound is the arrow.** Antimirov's `|PD(r)| <= ‖r‖ + 1` is what
   makes the cost `O(|input| × |pat|)` rather than exponential, and the single
   line that enforces it is the sort-and-dedup of the residual set. Without it
   the set grows and the result is a backtracker wearing a set. The bound lives
   in one function, so the arrow's honesty is auditable in one place.
4. **Bytes rather than codepoints.** The scan is over `Bytes` via `bget`. This is
   already the tree's settled answer: `prog/prose-lint.prog:43-45` explains that
   a UTF-8 lead byte is `>= 194` and so fails an ASCII range test, "which is the
   answer we want anyway". The em-dash needle stays a three-byte literal and the
   `[a-z]` class stays a byte range. `lib/protocol/utf8.chiral` exists for the
   cases that genuinely need codepoints and stays out of this element.

**What chirality makes impossible here:**

- **A backtracking matcher.** Not by a rule against it. The recursive descent
  over `(pattern, position)` that backtracking needs has neither a structural
  argument nor a single decreasing numeric one, so it does not prove total and
  the default gate rejects it.
- **A pattern that fails to parse.** There is no pattern syntax.
- **A silently unbounded scan.** The residual set is `(List Pat)`; the dedup that
  bounds it is a call you can see, and its absence is a code review finding
  rather than a latent ReDoS.
- **An effectful matcher.** The whole module is `->`. Reading the file is the
  caller's `=>`; matching crosses nothing.

## 5. Chirality example (fleshed)

```chirality
; lib/text/matcher.chiral: E173. A total matcher over Str, by Antimirov
; partial derivatives. Pure `->` throughout: matching crosses no port.
(import "prelude/prelude")   ; str-len, str->bytes, bget, blen, <i, <=i, =i, +, -, and, or
(import "prelude/list")      ; append, list-sort, list-dedup-adj, any-list
(import "prelude/ord")       ; Ord = (lt) (eq) (gt)

; ── 1. Cls: a byte class as a value ──────────────────────────────────────────
; BYTES, not codepoints (prose-lint.prog:43-45). A UTF-8 lead byte is >= 194 and
; fails every ASCII range here, which is the answer the checks want.
(data Cls ()
  (c-byte  (b I64))                     ; exactly this byte
  (c-range (lo I64) (hi I64))           ; lo..hi inclusive
  (c-any)                               ; any byte except 10 (awk's `.`)
  (c-not   (inner Cls))
  (c-or    (l Cls) (r Cls)))

(def cls-lower Cls (c-range 97 122))
(def cls-digit Cls (c-range 48 57))
; \w, spelled once here instead of 85 times across the corpus
(def cls-word Cls
  (c-or (c-range 48 57)
    (c-or (c-range 65 90) (c-or (c-range 97 122) (c-byte 95)))))

(declare cls-has (-> Cls I64 Bool))
(def cls-has (lam (c b) (case c
  ((c-byte  x)     (=i b x))
  ((c-range lo hi) (and (<=i lo b) (<=i b hi)))
  ((c-any)         (not (=i b 10)))
  ((c-not inner)   (not (cls-has inner b)))
  ((c-or l r)      (or (cls-has l b) (cls-has r b))))))

; ── 2. Assert: the whole zero-width budget the corpus needs ──────────────────
; All four lookaround sites in the Python corpus are one-byte-window tests
; (ledger-lint.py:246,413,836 and \b at 21 sites), so this sum covers them and
; a general lookaround engine is never built.
(data Assert ()
  (a-bol)                               ; prev byte is 10, or offset 0
  (a-eol)                               ; next byte is 10, or at end
  (a-wordb)                             ; \b : prev and here differ on cls-word
  (a-not-before (c Cls))                ; (?![...])
  (a-not-after  (c Cls)))               ; (?<![...])

; the one-byte window an Assert decides against. -1 means "off the end".
(data Ctx () (ctx (prev I64) (here I64)))

(declare holds (-> Ctx Assert Bool))
(def holds (lam (k a) (case a
  ((a-bol) (case k ((ctx p h) (or (<i p 0) (=i p 10)))))
  ; … a-eol, a-wordb, a-not-before, a-not-after: the same one-line shape
  )))

; ── 3. Pat: the pattern IS a value, so escaping does not exist ───────────────
; p-lit is kept beside p-cls so a literal run stays one node: the driver's
; prefilter can hand it straight to the str-find-from primitive
; (prelude.chiral:82 -> nb-bfind-from, bytes.chiral:355), which is what closes
; prose-lint's 2.4x gap (LEDGER.md:293).
(data Pat ()
  (p-nil)                               ; matches the empty string
  (p-lit  (s Str))
  (p-cls  (c Cls))
  (p-ast  (a Assert))                   ; zero-width
  (p-cat  (l Pat) (r Pat))
  (p-alt  (l Pat) (r Pat))
  (p-star (inner Pat)))

; `not <word> but `: prose-lint's not-but check, spelled as a value.
(def pat-not-but Pat
  (p-cat (p-lit "not ")
    (p-cat (p-cls cls-lower)
      (p-cat (p-star (p-cls cls-lower)) (p-lit " but ")))))

; ── 4. nullable: can p accept here, with assertions decided against ctx ──────
; Structural on p. Every recursive call is a strict subterm, so this proves
; under the structural rule with no declared measure (totality.md:46-58).
(declare nullable (-> Ctx Pat Bool))
(def nullable (lam (k p) (case p
  ((p-nil)      true)
  ((p-lit s)    (=i 0 (str-len s)))
  ((p-cls c)    false)
  ((p-ast a)    (holds k a))
  ((p-cat l r)  (and (nullable k l) (nullable k r)))
  ((p-alt l r)  (or  (nullable k l) (nullable k r)))
  ((p-star q)   true))))

; ── 5. pd: the partial derivative. The whole algorithm is these seven arms ───
; pd k b p = the set of residual patterns after consuming byte b at window k.
; Structural on p in every arm; the `p-star` arm rebuilds `(p-star q)` in the
; RESULT and never recurses into it, which is why the star does not diverge.
(declare pd      (-> Ctx I64 Pat (List Pat)))
(declare pd-cat  (-> (List Pat) Pat (List Pat)))   ; suffix each residual with r

(def pd (lam (k b p) (case p
  ((p-nil)     nil)
  ((p-cls c)   (case (cls-has c b) (true (cons (p-nil) nil)) (false nil)))
  ((p-ast a)   nil)                     ; zero-width: consumes nothing
  ((p-lit s)   ; peel one byte; a nonempty tail stays a p-lit node
    ; … (=i b (bget (str->bytes s) 0)) -> (cons (p-lit (str-sub s 1 (str-len s))) nil)
    nil)
  ((p-alt l r) (append Pat (pd k b l) (pd k b r)))
  ((p-cat l r) (append Pat (pd-cat (pd k b l) r)
                 (case (nullable k l) (true (pd k b r)) (false nil))))
  ((p-star q)  (pd-cat (pd k b q) (p-star q))))))

(def pd-cat (lam (ps r) (case ps
  (nil nil)
  ((cons h t) (cons (p-cat h r) (pd-cat t r))))))

; ── 6. norm: THE line that makes the arrow bounded ──────────────────────────
; Antimirov: the reachable state set has at most ‖pat‖ + 1 members. Sorting and
; deduping the residual set is what holds the run at that bound. Delete this
; call and the matcher is a backtracker wearing a set.
;
; pat-cmp is a NON-recursive wrapper over the recursive pat-cmp-go, mirroring
; str-cmp over su-cmp-bytes (string.chiral:91-92). That matters: totality.md:105
; says a recursive definition passed as a VALUE poisons its group's verdict, and
; the wrapper is what keeps the comparator out of that shape. Call form copied
; from row-infer.chiral:103-104.
(declare pat-cmp-go (-> Pat Pat Ord))
(declare pat-cmp    (-> Pat Pat Ord))
(def pat-cmp (lam (a b) (pat-cmp-go a b)))
; … pat-cmp-go: tag order first, then fields, structural on both

(declare norm (-> (List Pat) (List Pat)))
(def norm (lam (ps) (list-dedup-adj Pat pat-cmp (list-sort Pat pat-cmp ps))))

; ── 7. the driver ───────────────────────────────────────────────────────────
; Total by the NUMERIC measure: `i` steps by exactly +1 under the strict guard
; (<i i n) with `n` passed unchanged, so the measure is n - i and no wraparound
; guard is owed (totality.md:80-89). The arrow's cost is |input| x |pat|:
; n steps, each over a set the norm call holds at ‖pat‖ + 1.
(declare step-set (-> Ctx I64 (List Pat) (List Pat)))
(def step-set (lam (k b ps) (case ps
  (nil nil)
  ((cons h t) (append Pat (pd k b h) (step-set k b t))))))

(declare at-byte (-> Bytes I64 I64))    ; b[i], or -1 off either end
(declare accepts (-> Ctx (List Pat) Bool))

; does `pat` match starting exactly at `from`? Returns the end offset, or -1.
(declare run-from (-> Bytes I64 I64 (List Pat) I64 I64))
(def run-from (lam (bs i n ps best)
  (let ((k    (ctx (at-byte bs (- i 1)) (at-byte bs i)))
        (best2 (case (accepts k ps) (true i) (false best))))
    (case (<i i n)
      (false best2)
      (true
        (let ((ps2 (norm (step-set k (bget bs i) ps))))
          (case ps2
            (nil best2)                 ; set empty: no continuation survives
            ((cons h t) (run-from bs (+ i 1) n ps2 best2)))))))))

; ── 8. the line-state pass: the third NOT-CHECKED check ─────────────────────
; This is vt-parser's shape with four states instead of ten
; (protocol/vt-parser.chiral:11-20 for the PState idiom). Blanking an inline
; span is LENGTH-PRESERVING, so offsets found on the blanked copy are still
; valid on the original: the same rule su-lower states at string.chiral:96-99,
; and the same trick doc.py:174 uses (" " * len(m.group(0))).
(data LState () (ls-prose) (ls-fence))
(declare line-step (-> LState Str (Pair LState Bool)))   ; snd = scan this line?
(declare blank-spans (-> Str Str))                       ; `...` -> spaces
; … line-step: a leading ```-run toggles the state and the line is never scanned
```

**Knobs to modify:**

- `Cls` constructors. Adding `c-set` over a 256-bit bitmap is a pure speedup
  with no change to `pd`.
- `p-lit` and the prefilter. The literal-prefix fast path is where the 2.4x lives;
  the correctness of `pd` does not depend on it.
- Match semantics. `run-from` as written keeps the **longest** end offset. Swapping
  `best2` for a first-accept return gives leftmost-shortest. The 10 lazy sites in
  the Python corpus want leftmost-first, which is a third variant and a real
  decision (§6).
- `norm`. Any dedup that preserves the set works; `list-dedup-adj` after
  `list-sort` is the tree's existing idiom.

**Deliberately omitted:**

- **Capture groups.** 77 sites need them and the first consumer needs none. See §6.
- Counted repetition `{n,m}`. Expand to `p-cat` chains at construction; 19 sites,
  all with small literal bounds.
- A regex-syntax parser. There is no pattern syntax to parse, on purpose.
- Codepoint classes. `lib/protocol/utf8.chiral` owns that and stays out.

## 6. Use / modify notes

- **Lands in:** `lib/text/matcher.chiral` (new directory `lib/text/`; extension
  `.chiral` per `MAP.md`, module key `text/matcher`). Its first consumer edit
  is `prog/prose-lint.prog`.
- **Conformance target:** `tools/prose-lint/prose-lint.sh --summary` over
  `docs/` + `.planning/` + root `*.md`. The chirality version must reproduce the
  awk per-check totals for all eight checks, including the three that
  `prog/prose-lint.prog:186-188` prints as NOT-CHECKED, with code fences and
  inline spans excluded the same way. The awk baseline is
  `tools/prose-lint/prose-lint.sh:75-98`, and `.planning/PROSE-BASELINE.tsv` is
  the frozen per-file record. Second gate: the run is no slower than the awk one,
  since removing the 31 full-buffer passes is the stated reason for the element.

### Two slices, both inside E173

Per the deferral rule, this is a split of E173's own work and mints no new
element.

- **Slice 1, no captures.** `Cls` / `Assert` / `Pat` / `nullable` / `pd` /
  `norm` / `run-from` / the line-state pass. Retires all three of prose-lint's
  NOT-CHECKED checks, which need counts and never need a submatch. Projected
  ≈ 220 lines. *(Estimate, 2026-08-31, frozen per the authoring rule; annotate
  with the measured figure rather than overwriting.)*
- **Slice 2, captures.** The 77 group sites in the five Python tools. Tagged
  partial derivatives carry a slot assignment through `pd`, which is the
  research-grade part of the element and the part slice 1 exists to de-risk.

### Open questions

1. **Captures: tagged derivatives, or a narrower primitive?** Unsettled, and
   deliberately so. The 77 capture sites are dominated by four shapes that are
   not really regex work: table-cell extraction (`^\|\s*E(\d+)\s*\|`, at
   `ledger-lint.py:270,576,1144`, `capture.py:290`, `frontier.py:460`, and more),
   delimited-span extraction (`` `([^`]+)` `` at `doc.py:127`,
   `ledger-lint.py:47,381,464`, `pack.py:762`), frontmatter fields
   (`^related:\s*\[([^\]]*)\]` at `ledger-lint.py:310`, `pack.py:414`), and
   integer-after-literal (`E(\d+)`). A split-on-delimiter plus a span scanner
   plus an integer scanner may cover most of them with no tagging at all.
   **What would settle it:** classify all 77 into "served by split/scan" versus
   "needs a real submatch", from the same census script, before writing a line
   of tagging. That is a one-turn measurement and it decides whether slice 2 is
   40 lines or 200.
2. **Match semantics.** Longest, shortest, or leftmost-first. 10 lazy-quantifier
   sites in the corpus assume Perl leftmost-first. Partial derivatives give a
   set with no priority order, so leftmost-first needs an ordered residual list
   and a dedup that keeps first occurrence, which changes `norm`. Slice 1's
   consumer (counting) is indifferent, so this can be measured against the real
   sites rather than guessed.
3. **Does `pat-cmp` passed to `list-sort` trip the value-poison rule?** The
   `str-cmp` / `su-cmp-bytes` split (`string.chiral:91-92`) is the tree's existing
   dodge and `row-infer.chiral:103-104` is a live precedent, so the answer is
   probably no. Confirm on the first `chirality check` of the module rather than
   designing around it.
4. ~~**A text/matching bank is owed.** `docs/banks/` has no bank for matching,
   scanning, or strings (§1). Write it after the element is built, when the
   shards have real homes to cite.~~
   ⛑ **Discharged 2026-09-01, and it did not wait for the element.**
   `docs/banks/text.md` exists, refracting the regex engine / string library /
   Unix text tools / editor buffer into twelve shards A-L. This element is
   shard **D**, homed at `lib/text/`, state `design`. What the bank owes E173 on
   the way out is a state flip on that one row, not a new file.

### Stale paths hit while writing this

**All three discharged 2026-08-31, in the round-off pass this list triggered.**
Kept as written, annotated rather than deleted, per the authoring rule above.

- ~~`tools/pack/pack.py:40-42` still points at `examples/_TEMPLATE.md`,
  `examples/_CHEATSHEET.md` and `examples/INDEX.md`. The live tree has them under
  `docs/examples/`, so `pack.py E<#> <slug>` fails with `FileNotFoundError` on
  `_CHEATSHEET.md`. Same rot at `:179,188,455,774`. This run used a
  path-corrected copy in scratchpad.~~
  ⛑ **Already false when this was written.** Commit `e85dcdd` (*pack, doc and
  frontier point at docs/examples after the hoist*) had repointed all five sites.
  `python3 tools/pack/pack.py E13` and `E173 --audit example` both run against
  the real tree, 2026-08-31.
- ~~`docs/examples/_CHEATSHEET.md` names `lib/fsm.chiral` and `lib/json.chiral` as
  the style exemplars. Neither exists; `lib/protocol/json.chiral` and
  `lib/protocol/vt-parser.chiral` are the live equivalents.~~
  ⛑ **Fixed 2026-08-31** to exactly those two files, both opened and confirmed as
  exemplars first: `vt-parser.chiral` for `data`+`case` with a reversed accumulator
  flipped once, `json.chiral` for the parser result sum.
- ~~The template's `ours_source` placeholder is `scaffold/chirality/<file>.py`,
  which the hoist replaced with `lib/`.~~
  ⛑ **Fixed 2026-08-31**, and the correction is not `lib/`: the field names a
  *Python baseline*, and the only Python left in this tree is
  `tools/<name>/<name>.py`. The placeholder is now that, with a frontmatter
  comment saying the field is transitional because zero-Python deletes its
  referent. `pack.py`'s substitution key moved with it, and its OURS resolver now
  says a compiler `.py` is gone rather than printing a `scaffold/chirality/` path.

- **Related:** [[banks/text]] (the bank this element is shard D of),
  [[arcs/text-tools-arc]] (the arc that holds it, as P1),
  [[E11-totality-checker]] (the measure that picks the algorithm),
  [[E148]] `getdents64` and [[E150]] argv (the other two zero-Python gates),
  [[banks/verification]] (conformance against the awk baseline),
  [[E01-sexp-reader]] (the tree's other byte-level scanner).
