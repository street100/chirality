---
element: U13
slug: typed-document-seam
title: The renderer takes the typed value, not `Str` — where the heterogeneity is packed (D-U7)
kind: SURFACE-D
reference_class: EXTERNAL
ours_source: (none)
status: drafted
updated: 2026-08-30
---

# U13 — The renderer takes the typed value, not `Str`

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** U13 — delete `Str` from the renderer's *input* position, so a
  mode renders the buffer's **typed value**; and settle **D-U7**, where the
  resulting heterogeneity is packed when one buffer list holds documents of
  different types.
- **Kind:** SURFACE-D (BUILD-PROPER). It gates U14 (`Mode` grows keymap + ops +
  views), U15 (extension → document type as a checked binding) and U17 (N views
  per type) — this example covers all four, because they are **one** decision:
  what a mode *is* and what a buffer list *holds* cannot be settled separately.
- **Why chirality needs its own:** the defect is a *type*, not a missing feature.
  `TUI/scriba/render.chiral:16` —
  `(data RendererFn () (rf (fn (-> Str (Pair I64 I64) I64 Rendering))))` (the
  decl heads at `:16`, the field is `:17`). The
  buffer already knows its type (`puffer.chiral:36`, `(Puffer A)`) and already
  hands the typed value out (`puffer.chiral:70`,
  `puffer-value : (-> (0 A (type 0)) (Puffer A) (PufValueR A))`), but the
  renderer signature throws it away. So every mode reparses text it already
  had — **the Emacs mistake baked into a five-line declaration.** Nothing
  downstream of it can be a typed document until this changes.
- **Not in scope:** the per-type surface readers (U18, gated on D-U2), any
  concrete document type (U20–U24), the block algebra (U16/E158). This example
  settles the *seam*, and uses one type (`.fol`) only as a witness.

## 2. Research

- **Reference class:** EXTERNAL — no in-tree OURS baseline exists. The
  comparator is **GNU Emacs's major-mode architecture** (`auto-mode-alist`,
  `major-mode`, `font-lock-defaults`, `revert-buffer-function`, buffer-local
  variables, `derived-mode-p`), with **org-mode's `org-element-parse-buffer`**
  as the concrete re-parse cost, and **Self / Smalltalk-80 morphic
  "object-is-its-own-view"** as the prior art for the shape chirality actually
  wants. A secondary contrast is the LSP `TextDocument` model, which is also
  string-typed at the seam and therefore inherits the same defect one process
  boundary further out.

**Load-bearing findings** — the four that decide the design. (1) and (2) are
external; (3) and (4) are measured in this tree and are the ones that overturn
the recommendation's *argument*.

1. **Emacs's uniformity is in the data, and it is total.** A buffer is
   characters; `major-mode` is a buffer-local *symbol*; `auto-mode-alist` is an
   alist of regexp → mode-function, i.e. a naming **convention** with no
   checkable content. The mode function then installs `font-lock-defaults`, a
   keymap and a syntax table — every one of which re-derives structure from the
   characters. org-mode's own API concedes the cost in its name:
   `org-element-parse-buffer` builds a fresh parse tree on demand and *caches
   it*, because the buffer cannot hold it. The cache-invalidation problem org
   has is a direct consequence of the seam being `Str`.
2. **Nothing in Emacs's model can give a second view of one value without a
   second parse.** `org-agenda` does not read a parsed org value; it re-scans
   the files. This is the exact capability U17 asks for and the exact one the
   conventional shape structurally cannot have.
3. **The polymorphism scriba already has has never been cashed** (verified
   2026-08-30, `grep -ro '(Puffer Str)' TUI/scriba/*.chiral | wc -l` = **152**;
   `(Puffer A)` = **7**, all in generic helpers). `SCRIBA-PRIMITIVE-CHECKLIST`
   §1's *"the buffer is a typed lens on a port"* is true in the type and false
   in every instance. That is *why* nobody noticed the renderer takes a `Str`:
   with one instantiation, `A` and `Str` are indistinguishable.
4. **A closure-bearing record with N live instances lowers today — but only in
   one of its two shapes**, and the shapes are told apart by
   `scaffold/lib/specialize-singleton.chiral`. This is §4's central finding and
   the thing that decides D-U7; see the two-shapes table there.

## 3. Conventional (other-language) approach

Emacs, in the form every editor repeats. The registry is a naming convention;
the mode is a bag of buffer-local settings; the value does not exist.

```elisp
;; 1. the registry: a regexp, and a symbol. Nothing is checked; nothing binds
;;    the extension to a *type*, because there is no type.
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

;; 2. the mode: install fontification, a keymap, a syntax table. Every one of
;;    these re-derives structure from characters the buffer already contains.
(define-derived-mode org-mode outline-mode "Org"
  (setq-local font-lock-defaults '(org-font-lock-keywords t))
  (setq-local outline-regexp org-outline-regexp)
  (setq-local indent-line-function 'org-indent-line))

;; 3. the value, when it is finally wanted, is PARSED OUT OF THE TEXT — and
;;    then cached, because the buffer has nowhere to keep it.
(defun org-agenda-get-day-entries (file date &rest args)
  (with-current-buffer (org-get-agenda-file-buffer file)
    (org-with-wide-buffer
     (goto-char (point-min))
     (while (re-search-forward org-heading-regexp nil t)   ; <- scan #2
       ...))))
```

- **Assumptions it bakes in:**
  - **One data type for every document** (characters), so every distinction
    that matters is recovered by scanning. Structure is a *derived, discardable*
    property of text, never a stored one.
  - **Ambient mutable state as the interface.** A mode is what it `setq-local`s;
    there is no value naming what a mode is, so there is no way to ask whether a
    mode implements an operation — only to call and see. Absence is a runtime
    surprise (`void-function`), never a case to handle.
  - **The extension is decoration.** `auto-mode-alist` is regexps over a file
    name; a wrong row is a silently wrong mode, and nothing anywhere can refuse
    it.
  - **N views require N parses**, and therefore a cache, and therefore a cache
    invalidation bug. Two truths by construction — exactly what U19's round-trip
    gate exists to prevent.
  - **Optionality is untyped.** `revert-buffer-function`, `write-contents-functions`
    and `buffer-undo-list` are hooks/variables that may or may not be meaningful
    for a given buffer, with no type distinguishing a buffer that owns bytes on
    disk from one that is a fold over other buffers (`*Occur*`, `*Help*`,
    `*Agenda*`). The distinction is real and is nowhere in the model.

## 4. The chirality idea

**Uniformity moves out of the data and into the port.** `docs/live-environment.md`
already states the target: *"uniformity lives in a common port vocabulary (list,
inspect, send-op), and each session's payload type differs per instance."* U13 is
that sentence applied to `render.chiral`. The extension does not select a bag of
settings; it **names a document type**, and the type selects value, reader,
renderer, keymap, ops and views at once (U15). N views over one value cost N
projections and **zero** reparses (U17), because nothing was ever parsed twice.

### D-U7 — where the heterogeneity is packed

`.planning/USER-LAYER-GAP.md` §10 offers four shapes and recommends **(b)
buffer-as-object**. **This example confirms (b) — and rejects the argument the
gap doc gives for it**, which cites the wrong evidence, in a way that matters:

> ⚑ *Audit note (2026-08-30): the gap doc has since been patched with this
> section's findings, so the wording quoted below is the pre-patch text. Kept as
> the frozen rationale for **why** the doc changed — do not re-file it. See §6's
> contradictions block.*

the piece of evidence it leans on hardest is the *counter*-example.

#### The single most important technical question: does `specialize-singleton` bite?

`.planning/LANGUAGE-INVENTORY.md` §4 records that an *indexed* record-of-functions
parses and type-checks but **does not lower**, and that `specialize-singleton`'s
guard admits **exactly one** instance. If that applied to option (b), (b) would
be dead — a buffer list is by definition N instances. It does **not** apply, and
the reason is precise and worth stating as a standing rule, because the ergonomic
temptation points the wrong way.

Verified 2026-08-30 by reading the pass and both consumers. There are **two**
shapes of function-bearing record in this tree, and the compiler treats them
completely differently:

| | **Dictionary shape** (`Mach`, `Alloc`) | **Vocabulary shape** (`RendererFn`, `ScribaOp`) |
|---|---|---|
| How a field is reached | a **projector global**: `mach.chiral:64` — `(def mach-pro (lam (m) (case m ((mach a b c …) a))))`, then `((mach-con m) dst val)` (`emit-core.chiral:149`) | an **inline `case` in the body**: `command-loop.chiral:98` — `((rf f) (render-ok (f val dims scroll) puf2))` |
| Which pass must handle it | `specialize-singletons` (`compile-front.chiral:329`, runs **before** closconv). `proj-idx` (`:99-118`) matches exactly `(t-lam (t-case (t-var 0) [one arm] ))` and `sp-rw` rewrites exactly one `(t-app (t-global proj) m)`. ⚑ *Audit 2026-08-30: what routes a type into this pass is a **bare-ctor global**, not the presence of projectors — see the correction below the table.* | `closconv-sig`. `closconv-driver.chiral:74-76` — the ctor→field-type map exists precisely to *"route a fn-typed field APPLICATION through `$apply`"* |
| Instances permitted | **exactly 1.** `find-singleton` (`:78-84`) requires `count-inline == 1`; >1 returns `none`, the dict threads as a runtime fn value, and the lowerer er-skips it — a visible compile failure. (The `16d6d1a` relaxation to `>= 1` was an order-dependent silent miscompile and was reverted.) | **N.** Measured live: `RendererFn` **3** (`init-loader.chiral:614-616`), `ScribaOp` **31** in one list (`init-loader.chiral:583-613`, `cmd-types.chiral:10-11`), the latter with an **effectful** `(=> (Puffer Str) (Puffer Str))` field |
| Type parameter permitted | **no** — an index makes every accessor a two-lambda chain, `proj-idx` matches nothing, nothing is rewritten (the §4 GAP) | **not needed** — the record is ground; the payload type is captured and erased |

**So the answer is: the limitation does not bite option (b) — conditionally.**
Option (b) is safe **iff the vocabulary is consumed by inline `case`, never by
projector globals.** And this is the trap worth writing down, because it is the
*natural* thing to do to a 7-field record: writing

```chirality
(def buf-draw (-> Buf (-> (Pair I64 I64) I64 Rendering))   ; ⚠ DO NOT
  (lam (b) (case b ((buf nm tn draw vs k cl pv) draw))))
```

converts `Buf` from the vocabulary shape into the dictionary shape — a global
that extracts a fn-typed field and returns it unapplied. **The ergonomic move is
the one to avoid.** A later run must state this as a rule in the module header,
and the cheapest guard is that `Buf` gets **no accessor globals at all**.

⚑ **Audit correction (2026-08-30) — the pass named here is the wrong one.**
`specialize-singletons` never takes responsibility for `Buf` in *either* world.
Its only entry is `find-singleton` (`specialize-singleton.chiral:85-94`), whose
second gate is `find-con-global` (`:65-76`): it matches a global whose **whole
body** is a bare `(t-con <dname> <ctor> args)`. `Mach` has exactly one such global per blob
(`mach-x64.chiral:1651` `(def x64 Mach (mach …))`, or `mach-c.chiral:270`, or
`mach-listing.chiral:50`); a buffer is built *inside* a `lam` (§5's `fol-buf`),
so `find-con-global` returns `none`, `collect-singles` yields `nil`, and
`specialize-singletons` returns the sig unchanged (`:229`) — with or without
accessor globals. `proj-idx`/`sp-rw` run only *after* a singleton is found. So
the accessor-global hazard, if it is one, lives downstream in closconv/lowering
(an unsaturated higher-order return), not in this pass. What actually breaks is
**unmeasured**; see the FLAG in the audit report.

*(Second-order note: relaxing `proj-idx`/`sp-rw` to tolerate leading params —
LANGUAGE-INVENTORY §4's named lift — would not help here either, because the
whole pass is inert for `Buf` (the correction above): the singleton guard at
`:78-84` is independent of the index, and neither gate is reachable for a type
built inside a `lam`. U13 does not need that lift and should not be sequenced
behind it.)*

#### What overturns the gap doc's argument, and what survives it

`.planning/USER-LAYER-GAP.md` §10 D-U7 argues (b) is *"proven expressible today"*
because `RendererFn` has three live instances **"and `Mach` is a 12-field
record-of-functions that is the compiler's conformance seam. A wider record with
more instances is the same shape, not a new capability."**

**That last sentence is false, and it is exactly backwards.** `Mach` is the
*dictionary* shape: it is the compiler's conformance seam **because** it is
specialized away, and it is the one record in the tree that is structurally
capped at one instance per blob (`specialize-singleton.chiral:6-12`, `:78-84`).
Citing it as evidence that a wider record with more instances is fine is citing
the counter-example. It is also **37** fields, not 12 (`mach.chiral:26-62`; the
projector's `case` at `:64` binds 37 names — 34 field *lines*, and the last line
carries three).

**The recommendation survives on better evidence than the doc gave it.** The
strong witness is not `RendererFn` (3 instances) but **`ScribaOp` (31 instances
in one list, effectful field, `case`-destructured and applied at the call site)**,
which the gap doc does not mention and which is an order of magnitude more
convincing. Both are the vocabulary shape.

#### The construction shape (b) should use

`closconv.chiral:613` — `(cs-g (g Str) (k I64) (fields …))`, *"a k-ary **partial
application** of Global g (k=0 = g as a value)"*. The three live
`(rf default-str-renderer)` rows are `cs-g` sites with k=0. Building a buffer by
partially applying top-level globals over the typed value — `(fol-draw d)` —
is the **same site kind with k=1**. Not a lambda literal, not a new capability:
the captured document becomes a `$clo` ctor field, and the application at the
seam routes through the synthesized `$apply`. §5 is written this way on purpose.

#### The other three options, and the honest cost of (b)

- **(a) a closed `DocValue` sum.** Rejected, and not on taste: it puts the
  heterogeneity in a **shared file every new type must edit**, which fails the
  `SCRIBA-PRIMITIVE-CHECKLIST` §5 acceptance test (*one registry row and one new
  module*) at the first new type. It also forces every renderer to hold an arm
  for every *other* type's variant — an unrepresentable state made representable
  and then hand-waved with `r-hole`.
- **(c) one registry per type.** Correct and free for the *registry*, and it
  does nothing for the **buffer list**, which is S19's actual object. It solves
  the easy half.
- **(d) `Str` + a memoised parse.** This is Emacs's cache, imported. Two truths,
  which is the thing U19's `parse(print(v)) ≡ v` gate exists to forbid. It is
  also not cheaper: it needs everything (b) needs *plus* an invalidation story.
- **⚑ The honest cost of (b), stated because the acceptance test deserves an
  honest answer.** (b) is **source-additive**: a new document type is one
  `cons` into the registry list and one new module; no shared sum, no shared
  exhaustive `case`, no merge point. It is **not recompile-free**:
  `closconv-driver.chiral:107-112` mints one `$clo` **ctor per closure site** and
  one `$apply` per **family** — and a family is keyed by its *arrow signature*,
  not merely its arity (`closconv.chiral:608`) — so the generated exhaustive case grows with
  every new type and the blob must be rebuilt — the same whole-program cost
  `SCRIBA-STATE.md` records for a `Flow`/`PureFn` ctor change. The difference
  between (a) and (b) is **who edits the case**: in (a) a human edits a shared
  file; in (b) the pass mints it and no source file outside the new module
  changes. That is the whole win, and it is a real one, but "additive" here
  means *additive in source*, not *incremental in build*.

### The vocabulary — the actual deliverable of D-U7

D-U7's deliverable is not the packing choice; it is **which operations every
lane must implement and which are optional per lane.** Taking
`.planning/USER-LAYER-GAP.md` §5's five lanes against the nine candidate
operations:

| Operation | text | value | derived | stream | remote | verdict |
|---|---|---|---|---|---|---|
| `name` / `type-name` | ✓ | ✓ | ✓ | ✓ | ✓ | **required** |
| `draw` (default rendering) | ✓ | ✓ | ✓ | ✓ | ✓ | **required** |
| `views` (alternates, U17) | 1 | N | N | 1 | 1 | **required** (the list may be a singleton; the *field* is not optional) |
| `key` (one keystroke → successor) | ✓ | ✓ | ✓ | ✓ | ✓ | **required** |
| `close` | noop | noop | noop | **releases the port** | **releases the port** | **required** — and this is *why* it is required: it is the only field that makes the linear lanes typeable at all |
| `save` / `print` (U19) | ✓ | ✓ | ✗ | ✗ | ✗ | optional |
| `undo` / `redo` | ✓ | ✓ | ✗ | ✗ | ✗ | optional |
| `refresh` | ✗ | ✗ | ✓ | ✓ | ✓ | optional |
| `jump-to-source` (U51) | ✗ | ✗ | ✓ | ✗ | ✗ | optional, **and only inside `derived`** |

**The finding this matrix produces — and the reason it is not four `Maybe`
fields.** Read the four optional rows as columns: `save`+`undo` are present in
exactly `{text, value}`, `refresh` in exactly `{derived, stream, remote}`. The
partition is **total and disjoint** — no lane has both, no lane has neither. So
"optional" here is not four independent absences; it is **one closed two-variant
sum**, which is the standing boundary-sums directive applied at the seam:

> A buffer either **owns its bytes** (it can be printed and undone) or it is
> **derived from something else** (it can be refreshed, and may be able to point
> back at its source). Nothing is both, and the type should say so.

Four `Maybe` fields would make `(buf … (some print) … (some refresh) …)` — a
buffer that can be saved *and* refreshed — representable, and then every
consumer would need a defensive arm for a state the lane table says cannot
exist. The two-variant `Provenance` sum makes it **untypeable**, and `jump-to-source`
becomes a `Maybe` *inside* the `derived` variant, where it belongs (stream and
remote are derived but unanchored).

- **What chirality makes impossible here:**
  - **A mode cannot reparse**, because it is never handed text — the value is
    already in its closures.
  - **A save-and-refresh buffer is untypeable** (the `Provenance` split above).
  - **A buffer cannot be constructed without naming its release**: `close` is a
    required field, so no lane can be built that has no answer for its port.
    ⚑ *Audit correction (2026-08-30): a required field forces the release to be
    **named**, not **called**. Making a leak untypeable needs `close` at
    quantity 1, which this example deliberately does not use — see the "linear
    lanes" knob in §5 and S20b. Stated as untypeability, this bullet overclaimed.*
  - **`Buf` cannot be passed *directly* to its own operations.** E7 strict
    positivity (`scaffold/lib/data.chiral:267-269`) refuses a recursive
    occurrence in a field's arrow **domain**, by name — *"to the left of a
    function arrow"* (`:268`) — while permitting it in the **codomain** (`:269`,
    the walk recurses into `cod`; a bare head hit returns `pos-ok` at `:265`).
    So `(op (=> Buf Key Buf))` is rejected by the checker and
    `(key (=> KeySeq KeyR))` is accepted. **The type checker enforces the
    object discipline** for every operation declared as a field of `Buf` itself:
    each is a closure that has already captured its own state and hands back its
    successor. This is the strongest argument for (b) in the whole analysis and
    it is not in the gap doc.
    ⚑ *Audit correction (2026-08-30): the enforcement is **per declaration** and
    does not traverse a data-type indirection. `walk` recurses through a
    `(t-tcon n as)` only into the type **arguments** `as` (`data.chiral:270`,
    `walk-args` `:283-297`); it never resolves `n` to its own declaration. A
    parameterless intermediate — such as §5's own `Provenance`, which `Buf`
    holds and which itself mentions `Buf` — is therefore invisible to the walk
    in both directions. See the FLAG in the audit report.*
  - **The extension cannot be a sniffer.** U15's row binds extension → type name
    → module; E160 (module coordinate as a *checked declaration*, BUILT) is the
    in-tree precedent for refusing a declaration that contradicts fact.

## 5. Chirality example (fleshed)

Three files: the vocabulary, the registry, and one document type's module (the
copy target — this is what "one new module" means).

```chirality
; ══ TUI/scriba/buffer-object.chiral — NEW. The vocabulary. ══════════════════
(import "prelude")
(import "render")   ; Rendering, Face
(import "keymap")   ; KeySeq, Keymap

; U17: a named alternate rendering of the SAME value. Zero reparses — the
; closure below already holds the typed document, so a view is a projection.
(data View ()
  (view (name Str) (draw (-> (Pair I64 I64) I64 Rendering))))

; U51: where a row of a derived buffer came from, so `gd` can go back.
(data SrcRef ()
  (src-ref (buffer-id I64) (offset I64)))

; The key result, as a closed sum rather than a bare successor: "the mode
; consumed it" and "the mode declined it" are different facts and the global
; keymap must not re-derive which happened. (docs/pattern-boundary-sums.md.)
(data KeyR ()
  (k-took   (b Buf))     ; consumed; here is the successor buffer
  (k-passed (b Buf))     ; not mine — hand the key to the global keymap
  (k-closed))            ; the buffer asked to go away (close already ran)

; ── D-U7's deliverable: the optional half is ONE closed sum, not four Maybes.
; Measured over §5's lane table, `save`+`undo` and `refresh` partition the five
; lanes totally and disjointly. Making that a sum means "a buffer that is both
; saved and refreshed" is UNTYPEABLE, so no consumer needs a defensive arm.
(data Provenance ()
  ; text · value — the buffer owns its bytes.
  (owned   (print (-> Unit Str))          ; U19: parse(print(v)) ≡ v
           (undo  (-> Unit Buf))
           (redo  (-> Unit Buf)))
  ; derived · stream · remote — the buffer is a fold over something else.
  (derived (refresh (=> Unit Buf))
           (source  (Maybe (-> I64 SrcRef)))))   ; row -> origin; U51 only

; ── The buffer. GROUND: no type parameter, no existential. The document type
; is captured by the closures in these fields and erased by closure conversion.
; One (List Buf) therefore holds buffers of DIFFERENT document types.
;
; ⚑ E7 (data.chiral:267-269) decides this record's shape, not taste: `Buf` may
;   occur to the RIGHT of a field arrow and nowhere else IN THIS DECL. A DIRECT
;   occurrence in a domain is refused by name ("to the left of a function
;   arrow", :268). So no field declared here takes the buffer as a parameter;
;   every operation is a closure over its own state. NOTE (audit 2026-08-30):
;   the walk does not follow a `t-tcon` to its own decl, so an occurrence
;   reached THROUGH another data type (e.g. Provenance below) is unchecked —
;   the discipline is convention there, not construction. See §4's correction.
;
; ⚑ NO ACCESSOR GLOBALS FOR THIS TYPE. `(def buf-draw (lam (b) (case b …)))`
;   turns Buf into the Mach-shaped DICTIONARY: a global that extracts a fn-typed
;   field and returns it unapplied. Destructure inline, at the use site, exactly
;   as command-loop.chiral:98 already does for RendererFn. (Audit 2026-08-30: the
;   mechanism is NOT specialize-singleton — that pass never fires on Buf either
;   way; see §4. What actually breaks is unmeasured.)
(data Buf ()
  (buf
    (name      Str)                                 ; what `:ls` shows
    (type-name Str)                                 ; the U15 registry key
    (draw      (-> (Pair I64 I64) I64 Rendering))   ; dims, scroll -> the view
    (views     (List View))                         ; U17; may be a singleton
    (key       (=> KeySeq KeyR))                    ; one keystroke
    (close     (=> Unit Unit))                      ; releases whatever it holds
    (prov      Provenance)))

; U14: a Mode is what a document TYPE brings — renderer + faces + KEYMAP + OPS
; + views, the three of which `render.chiral:24`'s (mode renderer faces) lacks.
; U15: `exts` is the binding, not a sniffer. The registry stays a homogeneous
; (List DocMode); adding a type is one cons and one module, nothing else.
(data OpenR ()
  (open-ok  (b Buf))
  (open-err (why Str) (line I64)))   ; -> E157's typed Reason when it lands

(data DocMode ()
  (doc-mode
    (type-name Str)
    (exts      (List Str))                 ; ".fol" — the semantic handle
    (faces     (List (Pair Str Face)))
    (keys      Keymap)                     ; U14's missing half
    (ops       (List Str))                 ; ops this type permits
    (open      (=> Str Str OpenR))))       ; path, text -> a Buf, or a reason

; ── The seam itself. U13 in one line: RendererFn is DELETED. There is no
; `Str` anywhere below, and no reparse is expressible.
;   was: render.chiral:16  (rf (fn (-> Str (Pair I64 I64) I64 Rendering)))
(declare render-buf (-> Buf (Pair I64 I64) I64 Rendering))
(def render-buf
  (lam (b dims scroll)
    (case b ((buf nm tn draw vs k cl pv) (draw dims scroll)))))

; U17's payoff, and the thing Emacs structurally cannot do: pick another
; rendering of the SAME value. No parse happens here or anywhere.
(declare render-view (-> Buf Str (Pair I64 I64) I64 (Maybe Rendering)))
(declare view-find   (-> (List View) Str (Maybe View)))
(def render-view
  (lam (b vn dims scroll)
    (case b ((buf nm tn draw vs k cl pv)
      (case (view-find vs vn)
        (none          none)
        ((some v) (case v ((view _ vd) (some (vd dims scroll))))))))))
; …  view-find: structural recursion on vs, str-eq on the name.

; The absent operation is a VALUE the caller cases on — not a void-function.
(declare buf-print (-> Buf (Maybe Str)))
(def buf-print
  (lam (b)
    (case b ((buf nm tn draw vs k cl pv)
      (case pv
        ((owned pr un rd)   (some (pr unit)))
        ((derived rf src)   none))))))     ; a derived buffer has no bytes: say so
```

```chirality
; ══ TUI/scriba/modes/fol-mode.chiral — the COPY TARGET. One new document type
; ══ is exactly this file plus one cons into the registry. Nothing else moves.
(import "buffer-object")
(import "fol")   ; FolDoc, fol-parse, fol-print — this type's own reader (U18)

; Every field below is a k=1 PARTIAL APPLICATION of a top-level global over the
; document. closconv.chiral:613 calls that a `cs-g` site — the SAME site kind as
; the three (rf default-str-renderer) rows live in init-loader.chiral:614-616
; today, with k=1 instead of k=0. Nothing new is asked of the compiler.
(declare fol-draw    (-> FolDoc (Pair I64 I64) I64 Rendering))   ; r-tree + r-section
(declare fol-agenda  (-> FolDoc (Pair I64 I64) I64 Rendering))   ; r-table over the SAME value
(declare fol-columns (-> FolDoc (Pair I64 I64) I64 Rendering))   ; r-table, properties
(declare fol-key     (=> FolDoc KeySeq KeyR))
(declare fol-print   (-> FolDoc Unit Str))                       ; U19's print
(declare fol-undo    (-> FolDoc Unit Buf))
(declare fol-redo    (-> FolDoc Unit Buf))
(declare fol-close   (=> Unit Unit))                             ; value lane: a noop

(declare fol-buf (-> Str FolDoc Buf))
(def fol-buf
  (lam (nm d)
    (buf nm "fol"
      (fol-draw d)                                    ; cs-g, k=1
      (cons (view "agenda"  (fol-agenda  d))
        (cons (view "columns" (fol-columns d)) nil))  ; U17: 3 views, 1 value, 0 parses
      (fol-key d)
      fol-close
      (owned (fol-print d) (fol-undo d) (fol-redo d)))))

(declare fol-open (=> Str Str OpenR))
(def fol-open
  (lam (path text)
    (case (fol-parse text)                            ; the ONLY parse, ever
      ((fol-ok d)       (open-ok (fol-buf path d)))
      ((fol-err why ln) (open-err why ln)))))

; The one registry row (U15). The extension NAMES the type; it is not sniffed.
(declare fol-mode DocMode)
(def fol-mode
  (doc-mode "fol"
    (cons ".fol" nil)
    fol-faces
    fol-keymap                                        ; U14: modes bind keys now
    (cons "cycle-fold" (cons "todo-next" (cons "promote" nil)))
    fol-open))
```

```chirality
; ══ TUI/scriba/init-loader.chiral — the ONLY edit outside the new module. ═════
; Compare init-loader.chiral:614-616 today: three (pair Str Mode) rows.
(def default-modes (-> Unit (List DocMode))
  (lam (_)
    (cons text-mode                     ; type 7: the value IS a Str. One type
      (cons chirality-mode                  ; among N — not a fallback interface.
        (cons manas-mode
          (cons fol-mode nil))))))      ; <- the entire cost of a new type
```

- **Knobs to modify:**
  - **The optional half.** `Provenance`'s two variants are measured off §5's
    five lanes. A sixth lane that is genuinely both-or-neither would need a
    third variant — and would need to justify itself against the lane table
    first, because the partition being total is the whole reason this is a sum.
  - **`key`'s result.** `KeyR` here is three-way. If per-buffer prefix-argument
    state or a pending-operator lands (S21), it grows an arm; it must stay a
    closed sum and must never become a `Maybe Buf` plus a convention.
  - **`views` as a list vs. a fixed record.** A list keeps `Buf` ground and lets
    a type ship any number; a record per type would reintroduce a type param.
  - **The linear lanes.** `stream`/`remote` need `close` (and the captured port)
    at quantity 1 — `(1 close (=> Unit Unit))`, which is legal surface syntax on
    a *field* (`parse.chiral:495`) but makes `Buf` itself non-droppable and so
    unable to sit in an unrestricted `(List Buf)`. **That is S20b's open edge,
    not U13's**, and it is why this example instantiates `text`/`value`/`derived`
    only. Nothing above needs to change to admit them later — a linear variant
    is a second `Buf`-shaped type, not an edit to this one.
  - **`OpenR`'s error.** `(why Str) (line I64)` is a placeholder for E157's typed
    `Reason`; swap it and delete nothing else.

- **Deliberately omitted:**
  - Any real document type. `fol` is a witness for the seam; its surface syntax
    is U18 and is gated on **D-U2**, which this run does not touch.
  - `view-find`, `fol-faces`, `fol-keymap`, the `fol-*` bodies, and the whole
    `fol-parse`/`fol-print` reader — mechanical, and each belongs to its own row.
  - The buffer-list plumbing in `command-loop.chiral`. `(Puffer Str)` appears 152×;
    turning `render-puffer` (`command-loop.chiral:85-101`) into `render-buf` is
    the blast radius, and it is S19's job to own the list.
  - Fontification (U5 / D-U1) and the block algebra (U16 / E158) — both hang off
    this seam and neither is decided by it.

## 6. Use / modify notes

- **Lands in:** `TUI/scriba/buffer-object.chiral` (new — `Buf`, `View`, `KeyR`,
  `Provenance`, `DocMode`, `OpenR`, `render-buf`, `render-view`);
  `TUI/scriba/render.chiral` (**delete** `RendererFn` at `:16` and `Mode` at
  `:24`; `Rendering` and `Face` stay untouched);
  `TUI/scriba/command-loop.chiral:85-101` (`render-puffer` → `render-buf`);
  `TUI/scriba/init-loader.chiral:614-616` (the registry rows);
  `TUI/scriba/modes/<type>-mode.chiral` (one per document type).
- **Conformance target:** scriba compiles with B1, self-hosts, and renders the
  three existing modes with **byte-identical** output to today's `RendererFn`
  path — the seam changes, the pixels do not. Plus the new capability that
  proves the point: one `.fol` buffer rendering under two different `View`s with
  `fol-parse` called **exactly once** (assert by counting; a reparse is the
  defect this element exists to delete).
- **The cheapest falsifiers, in order — run these before writing anything else.**
  Each is a ~20-line program compiled with B1; all four are green-or-dead, and
  falsifiers 2–4 are the ones that would actually change the design. *(Falsifier
  3 was added by the audit, 2026-08-30.)*
  1. **N instances of the vocabulary shape with k=1 captures.** A record with a
     function field, three instances built by partially applying three globals
     over three *differently typed* payloads, in one list, `case`-destructured
     and applied. This is the `cs-g` k=1 claim. *(Expected green — `ScribaOp`
     with 31 k=0 instances is already live.)*
  2. **E7 on the self-returning field.** `(data B () (b (k (=> I64 B))))` must
     type-check, and `(data B () (b (k (=> B I64))))` must be **refused** with
     *"to the left of a function arrow"*. The whole object discipline rests on
     this reading of `data.chiral:267-269`.
  3. **E7 through an indirection** *(added by the audit, 2026-08-30)*.
     `(data P () (p (f (-> B I64)))) (data B () (b (q P)))` — a `B` in an arrow
     **domain**, reached through a parameterless intermediate. Reading `walk`
     (`data.chiral:258-297`) this is **expected to type-check**, i.e. the object
     discipline is NOT enforced across a data-type hop, and §5's own
     `Buf`→`Provenance`→`Buf` cycle is exactly that hop. Run it before relying
     on the "by construction" wording anywhere.
  4. **A second `Puffer` instantiation.** `(Puffer I64)` beside `(Puffer Str)` in
     one program. The 7 `(Puffer A)` sites prove the generic path type-checks;
     **nothing in the tree has ever instantiated it at a second concrete type**,
     and 152 of 159 sites are `Str`. If this is red, it is red *before* U13 and
     is a bigger finding than U13.
- **Open questions:**
  - **Totality of `key`.** `(key (=> KeySeq KeyR))` returning a successor `Buf`
    is a productive loop with no structurally decreasing argument. The command
    loop is already a `=>` process with guaranteed tail calls, so this is
    plausibly fine, but the interaction between the totality checker and a
    self-returning field is unmeasured. Falsifier 2 above will surface it.
  - **Does the derived lane keep `undo`?** Modelled here as no (`derived` has no
    `undo` field). `*Occur*` in Emacs has an undo list and it is meaningless.
    Named so it is a decision, not an oversight.
  - **`ops` as `(List Str)`.** A list of op *names* is a which-of-N string —
    a boundary-sums finding in embryo. It is a `Str` here only because the op
    registry (`ScribaOp`, `cmd-types.chiral:10`) is already keyed by name; if S21
    retypes that, this field follows and should not be allowed to drift.
  - **Where does `type-name` come from once `RendererFn` is gone?**
    `puffer-port-type` (`puffer.chiral:54`) still carries it on the `Puffer`.
    Two carriers of one fact — resolve toward `Buf` when S19 lands the list.
- **⚑ Contradictions found in `.planning/USER-LAYER-GAP.md` — report, do not
  patch here** (a pre-run writes only under `examples/`).
  **⚑ ALL THREE WERE APPLIED to the gap doc on 2026-08-30, before this audit
  ran** (verified `USER-LAYER-GAP.md` §5 lane table + §10 D-U7). They are kept
  below as the frozen finding; do NOT re-file them. Two numbers below are also
  *wrong in this example and right in the patched doc* — see the strikethroughs.
  1. **§10 D-U7's evidence sentence is wrong.** *"`Mach` is a 12-field
     record-of-functions … a wider record with more instances is the same shape,
     not a new capability."* `Mach` is the **dictionary** shape, is capped at
     **one** instance per blob by `specialize-singleton.chiral:78-84`, and is
     therefore the counter-example, not the witness. It is also ~~**34**~~ **37**
     fields (`mach.chiral:26-62`), not 12. The recommendation (b) is nevertheless
     **correct**; the witness is `ScribaOp`'s ~~32~~ **31** instances plus the
     `cs-g` partial-application site kind, and the decisive argument is E7
     positivity — *audit note: see §4's correction, that argument holds only
     per-declaration.* **APPLIED** — the doc now reads 37 / 31.
  2. **§10 D-U7 understates its own deliverable.** It calls the optional
     operations "which are optional per lane", implying independent flags. The
     lane table it points at shows the optionality is a **total, disjoint
     two-way partition**, i.e. a closed sum. Four `Maybe`s would admit states
     the same table says are impossible. **APPLIED** — §10 D-U7 now carries the
     `owned`/`derived` sum.
  3. **§5's lane table omits `close`.** The table's columns are save / undo /
     refresh / jump-to-source / holds-a-linear-port. `close` is not among them,
     yet it is the operation that makes "holds a linear port" typeable — it is
     required of every lane and is load-bearing for exactly the two lanes the
     table flags. It should be a column. **APPLIED** — the table now has a
     `close` column and a ⚑ note dated 2026-08-30. *(The column list quoted here
     is also stale: the live table has no jump-to-source column; it is folded
     into the `derived` row's Refresh cell.)*
- **Related:** [[live-environment]] · [[pattern-boundary-sums]] ·
  [[splitting-law]] · [[decision-user-layer-extensibility]] · U14 · U15 · U17 ·
  U18 (D-U2) · U19 · U51 · U52 (S20b) · S19 · S20b · S21 · E7 · E69 · E157 ·
  E158 · E160
